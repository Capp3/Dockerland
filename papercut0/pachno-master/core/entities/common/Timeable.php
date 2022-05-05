<?php

    namespace pachno\core\entities\common;

    use pachno\core\entities\Issue;

    /**
     * Timeable item class
     *
     * @package pachno
     * @subpackage core
     */
    class Timeable
    {

        /**
         * The time units
         *
         * @var array
         */
        protected static $units = ['months', 'weeks', 'days', 'hours', 'minutes'];

        public static function getUnits()
        {
            return self::$units;
        }

        /**
         * Get time units with points filled with 0.
         *
         * @return array
         */
        public static function getZeroedUnitsWithPoints()
        {
            return array_fill_keys(self::getUnitsWithPoints(), 0);
        }

        /**
         * Get time units with points.
         *
         * @return array
         */
        public static function getUnitsWithPoints()
        {
            $units = self::$units;
            $units[] = 'points';

            return $units;
        }

        /**
         * Get time units without.
         *
         * @param array $without
         *
         * @return array
         */
        public static function getUnitsWithout(array $without)
        {
            return array_diff(self::$units, $without);
        }

        /**
         * Formats hours and minutes
         *
         * @param $hours
         * @param $minutes
         *
         * @return integer|string
         */
        public static function formatHoursAndMinutes($hours, $minutes)
        {
            if (!$hours && !$minutes) return 0;
            if (!$minutes) return $hours;
            if (strlen($minutes) == 1) $minutes = '0' . $minutes;

            return $hours . ':' . $minutes;
        }

        /**
         * Formats log time
         *
         * @param      $log
         * @param      $previous_value
         * @param      $current_value
         * @param bool $append_minutes
         * @param bool $subtract_hours
         *
         * @return string
         */
        public static function formatTimeableLog($time, $previous_value, $current_value, $append_minutes = false, $subtract_hours = false)
        {
            if (!$append_minutes && !$subtract_hours) return $time;

            $old_time = unserialize($previous_value);
            $new_time = unserialize($current_value);

            if ($append_minutes) {
                if (isset($old_time['hours']) && isset($old_time['minutes'])) {
                    $old_time['hours'] += (int)floor($old_time['minutes'] / 60);
                }
                if (isset($new_time['hours']) && isset($new_time['minutes'])) {
                    $new_time['hours'] += (int)floor($new_time['minutes'] / 60);
                }
            }
            if ($subtract_hours) {
                if (isset($old_time['minutes'])) {
                    $old_time['minutes'] = $old_time['minutes'] % 60;
                }
                if (isset($new_time['minutes'])) {
                    $new_time['minutes'] = $new_time['minutes'] % 60;
                }
            }

            return Issue::getFormattedTime($old_time) . ' &rArr; ' . Issue::getFormattedTime($new_time);
        }

    }