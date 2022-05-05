<?php

    namespace pachno\core\entities\common;

    use pachno\core\entities\Team;
    use pachno\core\entities\User;

    /**
     * Ownable item class
     *
     * @author Daniel Andre Eikeland <zegenie@zegeniestudios.net>
     * @version 3.1
     * @license http://opensource.org/licenses/MPL-2.0 Mozilla Public License 2.0 (MPL 2.0)
     * @package pachno
     * @subpackage core
     */

    /**
     * Ownable item class
     *
     * @package pachno
     * @subpackage core
     */
    abstract class Ownable extends IdentifiableScoped
    {

        /**
         * The project owner if team
         *
         * @var Team
         * @Column(type="integer", length=10)
         * @Relates(class="\pachno\core\entities\Team")
         */
        protected $_owner_team;

        /**
         * The project owner if user
         *
         * @var User
         * @Column(type="integer", length=10)
         * @Relates(class="\pachno\core\entities\User")
         */
        protected $_owner_user;

        public function setOwner(Identifiable $owner)
        {
            if ($owner instanceof Team) {
                $this->_owner_user = null;
                $this->_owner_team = $owner;
            } else {
                $this->_owner_team = null;
                $this->_owner_user = $owner;
            }
        }

        public function clearOwner()
        {
            $this->_owner_team = null;
            $this->_owner_user = null;
        }

        public function toJSON($detailed = true)
        {
            $jsonArray = [
                'id' => $this->getID(),
                'owner' => $this->hasOwner() ? $this->getOwner()->toJSON() : null
            ];

            return $jsonArray;
        }

        public function hasOwner()
        {
            return (bool)($this->getOwner() instanceof Identifiable);
        }

        public function getOwner()
        {
            $this->_b2dbLazyLoad('_owner_team');
            $this->_b2dbLazyLoad('_owner_user');

            if ($this->_owner_team instanceof Team) {
                return $this->_owner_team;
            } elseif ($this->_owner_user instanceof User) {
                return $this->_owner_user;
            } else {
                return null;
            }
        }

    }