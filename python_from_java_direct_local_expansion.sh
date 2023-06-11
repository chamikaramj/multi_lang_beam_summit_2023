cd python_from_java

echo "Starting the Job Server in a different shell"

osascript -e 'tell app "Terminal"
    do script "cd ~/code/multi_lang_beam_summit_2023/python_from_java && . job_server_venv/bin/activate && python -m apache_beam.runners.portability.local_job_service_main -p 10002"
end tell'

echo "Starting the Expansion Service in a different shell"

osascript -e 'tell app "Terminal"
    do script "cd ~/code/multi_lang_beam_summit_2023/python_from_java && . expansion_service_venv/bin/activate && python -m apache_beam.runners.portability.expansion_service_main -p 5002 --fully_qualified_name_glob *from_callable*"
end tell'


echo "Waiting 25 seconds for the services to start"
sleep 25


echo "Running the pipeline"

cd python-from-java-beam-summit
mvn compile exec:java -Dexec.mainClass=org.apache.beam.examples.multilanguage.RunInferenceExampleLocalExpansion -Dexec.args="--runner=PortableRunner --jobEndpoint=localhost:10002 --expansionService=localhost:5002" -Pportable-runner
