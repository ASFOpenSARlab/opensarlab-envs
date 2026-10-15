export ISCE_HOME=$(python -c "import isce, os; print(os.path.dirname(isce.__file__))")
export PATH="$ISCE_HOME/applications:$PATH"