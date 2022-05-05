<?php

    namespace pachno\core\entities;

    use pachno\core\entities\common\Identifiable;

    /**
     * Notification setting class
     *
     * @author Daniel Andre Eikeland <zegenie@zegeniestudios.net>
     * @version 3.3
     * @license http://opensource.org/licenses/MPL-2.0 Mozilla Public License 2.0 (MPL 2.0)
     * @package pachno
     * @subpackage main
     */

    /**
     * Notification setting class
     *
     * @package pachno
     * @subpackage main
     *
     * @Table(name="\pachno\core\entities\tables\NotificationSettings")
     */
    class NotificationSetting extends Identifiable
    {

        /**
         * The module name
         *
         * @var string
         * @Column(type="string", length=50)
         */
        protected $_module_name;

        /**
         * The setting name
         *
         * @var string
         * @Column(type="string", length=255)
         */
        protected $_name;

        /**
         * Setting value
         *
         * @var string
         * @Column(type="string", length=100)
         */
        protected $_value = '';

        /**
         * Who the notification is for
         *
         * @var User
         * @Column(type="integer", length=10)
         * @Relates(class="\pachno\core\entities\User")
         */
        protected $_user_id;

        /**
         * Return the module name
         *
         * @return string
         */
        public function getModuleName()
        {
            return $this->_module_name;
        }

        /**
         * Set the module name
         *
         * @param string $module_name
         */
        public function setModuleName($module_name)
        {
            $this->_module_name = $module_name;
        }

        /**
         * Return the notification settings name
         *
         * @return string
         */
        public function getName()
        {
            return $this->_name;
        }

        /**
         * Set the notification settings name
         *
         * @param string $name
         */
        public function setName($name)
        {
            $this->_name = $name;
        }

        public function getUser()
        {
            return $this->_b2dbLazyLoad('_user_id');
        }

        public function setUser($uid)
        {
            $this->_user_id = $uid;
        }

        public function isOff()
        {
            return !(bool)$this->isOn();
        }

        public function isOn()
        {
            return (bool)$this->getValue();
        }

        public function getValue()
        {
            return $this->_value;
        }

        public function setValue($value)
        {
            if ($value === true) $value = 1;
            if ($value === false) $value = 0;

            $this->_value = $value;
        }

    }
