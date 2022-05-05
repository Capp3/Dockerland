<?php

    namespace pachno\core\modules\publish\cli;

    use pachno\core\framework\cli\Command;

    /**
     * CLI command class, publish -> extract
     *
     * @package pachno
     * @subpackage publish
     */
    class Extract extends Command
    {

        public function do_execute()
        {
            $this->cliEcho("Extracting articles ... \n", 'white', 'bold');
            $articles = tables\Articles::getTable()->getAllArticles();

            $this->cliEcho("Articles found: ");
            $this->cliEcho(count($articles) . "\n", 'green', 'bold');

            foreach ($articles as $article_id => $article) {
                $filename = PACHNO_MODULES_PATH . 'publish' . DS . 'fixtures' . DS . urlencode($article->getName());
                if (!file_exists($filename) || $this->getProvidedArgument('overwrite', 'no') == 'yes') {
                    $this->cliEcho("Saving ");
                    file_put_contents($filename, $article->getContent());
                } else {
                    $this->cliEcho("Skipping ");
                }
                $this->cliEcho($article->getName() . "\n", 'white', 'bold');
            }
        }

        protected function _setup()
        {
            $this->_command_name = 'extract_articles';
            $this->_description = "Extracts all articles from the database";
            $this->addOptionalArgument('overwrite', "Set to 'yes' to overwrite existing articles");
        }

    }
