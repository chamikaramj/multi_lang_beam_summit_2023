echo "Deleting any previous output"
rm java_from_python/output/*

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
python javacount.py --runner DirectRunner --environment_type=DOCKER --input input1 --output output/counts --expansion_service_port 12345

echo "Once the pipeline is finished run 'cat java_from_python/output/*' to print the output"

deactivate
