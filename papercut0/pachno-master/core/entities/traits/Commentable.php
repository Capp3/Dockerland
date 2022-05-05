<?php

    namespace pachno\core\entities\traits;

    use pachno\core\entities\Comment;

    /**
     * Trait for things that can have comments
     *
     * @package pachno
     * @subpackage traits
     */
    trait Commentable
    {

        /**
         * An array of \pachno\core\entities\Comments
         *
         * @var array
         * @Relates(class="\pachno\core\entities\Comment", collection=true, foreign_column="target_id")
         */
        protected $_comments;

        protected $_num_comments;

        /**
         * Retrieve all comments for this issue
         *
         * @return Comment[]
         */
        public function getComments()
        {
            $this->_populateComments();

            return $this->_comments;
        }

        /**
         * Populate comments array
         */
        protected function _populateComments()
        {
            if ($this->_comments === null) {
                $this->_b2dbLazyLoad('_comments');
            }
        }

        public function countComments()
        {
            return $this->getCommentCount();
        }

        /**
         * Return the number of comments
         *
         * @return integer
         */
        public function getCommentCount()
        {
            if ($this->_num_comments === null) {
                if ($this->_comments !== null)
                    $this->_num_comments = count($this->_comments);
                else
                    $this->_num_comments = $this->_b2dbLazyCount('_comments');
            }

            return $this->_num_comments;
        }

    }
