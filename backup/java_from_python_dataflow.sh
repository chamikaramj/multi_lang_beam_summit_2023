echo "Deleting any previous output"
gsutil rm gs://apache-beam-testing-chamikara/javacount/output*

cd java_from_python

echo "Starting up the expansion service in a different shell"

osascript -e 'tell app "Terminal"
    do script "cd ~/code/multi_lang_beam_summit_2023/java_from_python && java -jar beam-examples-multi-language-2.48.0.jar 12345"
end tell'

echo "Waiting 25 seconds for the expansion service to start"
sleep 25

echo "Activating the virtual environment"
. venv/bin/activate

echo "Running the pipeline"
export GCP_PROJECT=apache-beam-testing
export GCS_BUCKET=apache-beam-testing-chamikara
export TEMP_LOCATION=gs://$GCS_BUCKET/tmp
export GCP_REGION=us-central1
export JOB_NAME="javacount-`date +%Y%m%d-%H%M%S`"
export NUM_WORKERS="1"

python javacount.py \
      --runner DataflowRunner \
      --temp_location $TEMP_LOCATION \
      --project $GCP_PROJECT \
      --region $GCP_REGION \
      --job_name $JOB_NAME \
      --num_workers $NUM_WORKERS \
      --input "gs://dataflow-samples/shakespeare/kinglear.txt" \
      --output "gs://$GCS_BUCKET/javacount/output" \
      --expansion_service_port 12345


echo "Once the pipeline is finished run 'gsutil cat gs://apache-beam-testing-chamikara/javacount/output*' to print output"

deactivate