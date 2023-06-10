cd python_from_java

echo "Starting the Job Server in a different shell"

osascript -e 'tell app "Terminal"
    do script "cd ~/code/multi_lang_beam_summit_2023/python_from_java && . job_server_venv/bin/activate && python -m apache_beam.runners.portability.local_job_service_main -p 10001"
end tell'


echo "Waiting 25 seconds for the Job Server to start"
sleep 25


echo "Running the pipeline"

cd python-from-java-beam-summit
mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.multilanguage.RunInferenceExample     -Dexec.args="--runner=PortableRunner --jobEndpoint=localhost:10001" -Pportable-runner
