<?php

    namespace pachno\core\modules\main\cli;

    use pachno\core\framework\cli\Command;

    /**
     * CLI command class, main -> help
     *
     * @package pachno
     * @subpackage core
     */
    class Help extends Command
    {

        public function do_execute()
        {
            $this->cliEcho("Pachno CLI help\n", 'white', 'bold');

            if ($this->hasProvidedArgument(2)) {
                $module_command = explode(':', $this->getProvidedArgument(2));
                $module_name = (count($module_command) == 2) ? $module_command[0] : 'main';
                $command = (count($module_command) == 2) ? $module_command[1] : $module_command[0];

                $commands = self::getAvailableCommands();

                if (array_key_exists($module_name, $commands) && array_key_exists($command, $commands[$module_name])) {
                    $this->cliEcho("\n");
                    $class = $commands[$module_name][$command];
                    $this->cliEcho("Usage: ", 'white', 'bold');
                    $this->cliEcho(Command::getCommandLineName() . " ");
                    if ($module_name != 'main') {
                        $this->cliEcho($module_name . ':', 'green', 'bold');
                    }
                    $this->cliEcho($class->getCommandName() . " ", 'green', 'bold');

                    $hasArguments = false;
                    foreach ($class->getRequiredArguments() as $argument => $description) {
                        $this->cliEcho($argument . ' ', 'magenta', 'bold');
                        $hasArguments = true;
                    }
                    foreach ($class->getOptionalArguments() as $argument => $description) {
                        $this->cliEcho('[' . $argument . '] ', 'magenta');
                        $hasArguments = true;
                    }
                    $this->cliEcho("\n");
                    $this->cliEcho($class->getDescription(), 'white', 'bold');
                    $this->cliEcho("\n\n");

                    if ($hasArguments) {
                        $this->cliEcho("Argument descriptions:\n", 'white', 'bold');
                        foreach ($class->getRequiredArguments() as $argument => $description) {
                            $this->cliEcho("  {$argument}", 'magenta', 'bold');
                            if ($description != '') {
                                $this->cliEcho(" - {$description}");
                            } else {
                                $this->cliEcho(" - No description provided");
                            }
                            $this->cliEcho("\n");
                        }
                        foreach ($class->getOptionalArguments() as $argument => $description) {
                            $this->cliEcho("  [{$argument}]", 'magenta');
                            if ($description != '') {
                                $this->cliEcho(" - {$description}");
                            } else {
                                $this->cliEcho(" - No description provided");
                            }
                            $this->cliEcho("\n");
                        }
                        $this->cliEcho("\n");
                        $this->cliEcho("Parameters must be passed either in the order described above\nor in the following format:\n");
                        $this->cliEcho("--parameter_name=value", 'magenta');
                        $this->cliEcho("\n\n");
                    }
                } else {
                    $this->cliEcho("\n");
                    $this->cliEcho("Unknown command\n", 'red', 'bold');
                    $this->cliEcho("Type " . Command::getCommandLineName() . ' ', 'white', 'bold');
                    $this->cliEcho('help', 'green', 'bold');
                    $this->cliEcho(" for more information about the cli tool.\n\n");
                }
            } else {
                $this->cliEcho("\n");
                $this->cliEcho("To suppress colour output (useful for automation scripts), set environment variable PACHNO_CLI_NO_COLOR to 1.\n");
                $this->cliEcho("\n");
                $this->cliEcho("Below is a list of available commands:\n");
                $this->cliEcho("Type ");
                $this->cliEcho(Command::getCommandLineName() . ' ', 'white', 'bold');
                $this->cliEcho('help', 'green', 'bold');
                $this->cliEcho(' command', 'magenta');
                $this->cliEcho(" for more information about a specific command.\n\n");
                $commands = $this->getAvailableCommands();

                foreach ($commands as $module_name => $module_commands) {
                    if ($module_name != 'main' && count($module_commands) > 0) {
                        $this->cliEcho("\n{$module_name}:\n", 'green', 'bold');
                    }
                    ksort($module_commands, SORT_STRING);
                    foreach ($module_commands as $command_name => $command) {
                        if ($module_name != 'main') $this->cliEcho("  ");
                        $this->cliEcho("{$command_name}", 'green', 'bold');
                        $this->cliEcho(" - {$command->getDescription()}\n");
                    }

                    if (count($commands) > 1 && $module_name == 'api') {
                        $this->cliEcho("\nModule commands, use ");
                        $this->cliEcho("module_name:command_name", 'green');
                        $this->cliEcho(" to run:");
                    }
                }

                $this->cliEcho("\n");
            }
        }

        protected function _setup()
        {
            $this->_command_name = 'help';
            $this->_description = "Prints out help information";
            $this->addOptionalArgument('command', "Show help for the command specified");
        }

    }
