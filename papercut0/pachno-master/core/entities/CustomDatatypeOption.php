<?php

    namespace pachno\core\entities;

    /**
     * @Table(name="\pachno\core\entities\tables\CustomFieldOptions")
     */
    class CustomDatatypeOption extends DatatypeBase
    {

        protected static $_items = [];

        /**
         * This options value
         *
         * @var string|integer
         * @Column(type="string", length=200)
         */
        protected $_value = null;

        /**
         * Custom field key value
         *
         * @var integer
         * @Column(type="integer", length=10)
         * @Relates(class="\pachno\core\entities\CustomDatatype")
         */
        protected $_customfield_id;

        /**
         * Return the options color (if applicable)
         *
         * @return string
         */
        public function getColor()
        {
            return $this->_itemdata;
        }

        public function canBeDeleted()
        {
            return true;
        }

        /**
         * Return the options icon (if applicable)
         *
         * @return string
         */
        public function getIcon()
        {
            return $this->_itemdata;
        }

        public function isBuiltin()
        {
            return false;
        }

        public function getValue()
        {
            return $this->_value;
        }

        public function setValue($value)
        {
            $this->_value = $value;
        }

        /**
         * @param int $customdatatype
         */
        public function setCustomdatatype($customdatatype)
        {
            $this->_customfield_id = $customdatatype;
        }

        public function getType()
        {
            return parent::getItemtype();
        }

        public function getFontAwesomeIcon()
        {
            return $this->getCustomdatatype()->getFontAwesomeIcon();
        }

        /**
         * @return CustomDatatype
         */
        public function getCustomdatatype(): CustomDatatype
        {
            if (!$this->_customfield_id instanceof CustomDatatype) {
                $this->_b2dbLazyLoad('_customfield_id');
            }

            return $this->_customfield_id;
        }

        public function getFontAwesomeIconStyle()
        {
            return $this->getCustomdatatype()->getFontAwesomeIconStyle();
        }
    }
