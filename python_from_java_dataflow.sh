cd python_from_java

echo "Deleting any previous output"
gsutil rm gs://apache-beam-testing-chamikara/multi-language-beam/output*

echo "Running the pipeline"

cd python-from-java-beam-summit

export GCP_PROJECT=apache-beam-testing
export GCP_BUCKET=apache-beam-testing-chamikara
export GCP_REGION=us-central1

mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.multilanguage.SklearnMnistClassification \
    -Dexec.args="--runner=DataflowRunner --project=$GCP_PROJECT \
                 --region=$GCP_REGION \
                 --gcpTempLocation=gs://$GCP_BUCKET/multi-language-beam/tmp \
                 --output=gs://$GCP_BUCKET/multi-language-beam/output" \
    -Pdataflow-runner

echo "Once the pipeline is finished run 'gsutil cat gs://apache-beam-testing-chamikara/multi-language-beam/output*' to print output"
