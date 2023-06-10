package org.apache.beam.examples.multilanguage;

import com.google.common.collect.ImmutableList;
import java.util.Arrays;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.coders.Coder;
import org.apache.beam.sdk.coders.IterableCoder;
import org.apache.beam.sdk.coders.RowCoder;
import org.apache.beam.sdk.coders.VarLongCoder;
import org.apache.beam.sdk.extensions.python.PythonExternalTransform;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.PipelineOptions;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.schemas.Schema;
import org.apache.beam.sdk.testing.PAssert;
import org.apache.beam.sdk.transforms.Create;
import org.apache.beam.sdk.util.PythonCallableSource;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.Row;

public class RunInferenceExample {

  void runExample(RunInferenceExampleOptions options) {
    Schema schema =
        Schema.of(
            Schema.Field.of("example", Schema.FieldType.array(Schema.FieldType.INT64)),
            Schema.Field.of("inference", Schema.FieldType.INT32));
    Row row0 = Row.withSchema(schema).addArray(0L, 0L).addValue(0).build();
    Row row1 = Row.withSchema(schema).addArray(1L, 1L).addValue(1).build();

    Coder<Row> coder = (Coder<Row>) RowCoder.of(schema);

    Pipeline pipeline = Pipeline.create(options);
    PCollection<Row> col =
        pipeline
            .apply(Create.<Iterable<Long>>of(Arrays.asList(0L, 0L), Arrays.asList(1L, 1L)))
            .setCoder(IterableCoder.of(VarLongCoder.of()))
            .apply(
                PythonExternalTransform.<PCollection<?>, PCollection<Row>>from(
                    "apache_beam.ml.inference.base.RunInference.from_callable")
                    .withExtraPackages(ImmutableList.of("scikit-learn", "pandas"))
                    .withOutputCoder((coder))
                    .withKwarg(
                        "model_handler_provider",
                        PythonCallableSource.of(
                            "apache_beam.ml.inference.sklearn_inference.SklearnModelHandlerNumpy"))
                    .withKwarg("model_uri", options.getModelPath()));
    PAssert.that(col).containsInAnyOrder(row0, row1);
    pipeline.run().waitUntilFinish();
  }

  public interface RunInferenceExampleOptions extends PipelineOptions {
    @Description(
        "Path to a model file that contains the pickled file of a scikit-learn model trained on MNIST data")
    @Default.String("gs://apache-beam-testing-chamikara/tmp/test_model")
    String getModelPath();

    void setModelPath(String value);
  }

  public static void main(String[] args) {
    RunInferenceExampleOptions options =
        PipelineOptionsFactory.fromArgs(args).as(RunInferenceExampleOptions.class);
    RunInferenceExample example = new RunInferenceExample();
    example.runExample(options);
  }
}
