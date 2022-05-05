<?php use pachno\core\entities\LogItem;

if ($item instanceof \pachno\core\entities\LogItem): ?>
    <li class="<?php if ($showtrace) echo 'header-break' ?>">
        <?php if ($showtrace): ?>
            <span class="date"><?= \pachno\core\framework\Context::getI18n()->formatTime($item->getTime(), 6); ?></span>
            <?php include_component('main/userdropdown', array('user' => $item->getUser(), 'userstate' => false)); ?>
        <?php endif; ?>
        <?php include_component('main/logitemtext', ['item' => $item]); ?>
    </li>
<?php endif; ?>
