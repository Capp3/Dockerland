<?php

    /**
     * @var \pachno\core\entities\IssuetypeScheme $scheme
     * @var \pachno\core\entities\Issuetype $type
     * @var \pachno\core\entities\CustomDatatype[] $custom_fields
     */

use pachno\core\framework\Context; ?>
<div class="configurable-component issue-type-scheme-issue-type form-container" data-issue-type data-id="<?= $type->getID(); ?>" id="issuetype_<?php echo $type->getID(); ?>_box" data-options-url="<?= make_url('configure_issuetypes_scheme_options', ['scheme_id' => $scheme->getID(), 'issue_type_id' => $type->getId()]); ?>">
    <form class="row" accept-charset="<?= Context::getI18n()->getCharset(); ?>" action="<?= make_url('configure_edit_issuetype', ['issuetype_id' => $type->getID()]); ?>" data-interactive-form id="edit_issuetype_<?= $type->getID(); ?>_form">
        <div class="icon">
            <?= fa_image_tag($type->getFontAwesomeIcon(), ['class' => 'issuetype-icon issuetype-' . $type->getType()]); ?>
        </div>
        <div class="name">
            <div class="form-row">
                <input type="text" class="invisible" value="<?php echo $type->getName(); ?>" name="name">
            </div>
        </div>
        <div class="icon">
            <input type="checkbox" class="fancy-checkbox icon dynamic-toggle" id="type_toggle_<?= $type->getId(); ?>" name="is_associated" value="1" <?php if ($scheme->isSchemeAssociatedWithIssuetype($type)) echo 'checked'; ?> data-url="<?php echo make_url('configure_toggle_issuetype_for_scheme', array('issue_type_id' => $type->getID(), 'scheme_id' => $scheme->getID())); ?>">
            <label class="button icon secondary" for="type_toggle_<?= $type->getId(); ?>"><?php echo fa_image_tag('toggle-on', ['class' => 'checked']) . fa_image_tag('toggle-off', ['class' => 'unchecked']) . fa_image_tag('spinner', ['class' => 'fa-spin indicator']); ?></label>
        </div>
        <button class="icon open trigger-open-component" type="button">
            <?= fa_image_tag('angle-right'); ?>
        </button>
    </form>
    <?php /*
    <div class="configurable-component-options">
        <div id="issuetype_<?php echo $type->getID(); ?>_options" class="collapse-target">
            <h5>
                <span class="name"><?= __('Existing fields'); ?></span>
                <span class="dropper-container">
                    <button class="button primary dropper"><?= __('Add field'); ?></button>
                    <span class="dropdown-container list-mode columns two-columns">
                        <span class="column">
                            <span class="header"><?= __('Built-in fields'); ?></span>
                            <?php foreach ($builtin_fields as $item): ?>
                                <?php if (array_key_exists($item, $visiblefields)) continue; ?>
                                <a href="javascript:void(0);" class="list-item">
                                    <span class="name"><?= \pachno\core\entities\tables\IssueFields::getFieldDescription($item); ?></span>
                                </a>
                            <?php endforeach; ?>
                        </span>
                        <span class="column">
                            <span class="header"><?= __('Custom fields'); ?></span>
                            <?php foreach ($custom_fields as $item): ?>
                                <?php if (array_key_exists($key, $visiblefields)) continue; ?>
                                <a href="javascript:void(0);" class="list-item">
                                    <span class="name"><?= $item->getDescription(); ?></span>
                                </a>
                            <?php endforeach; ?>
                        </span>
                    </span>
                </span>
            </h5>
            <div class="configurable-components-list" id="<?php echo $type->getID(); ?>_list">
                <?php foreach ($builtin_fields as $item): ?>
                    <?php if (!array_key_exists($item, $visiblefields)) continue; ?>
                    <?php include_component('issuetypeschemeoption', array('issuetype' => $type, 'scheme' => $scheme, 'key' => $item, 'item' => $item, 'visiblefields' => $visiblefields)); ?>
                <?php endforeach; ?>
                <?php if (count($custom_fields)): ?>
                    <?php foreach ($custom_fields as $key => $item): ?>
                        <?php if (!array_key_exists($key, $visiblefields)) continue; ?>
                        <?php include_component('issuetypeschemeoption', array('issuetype' => $type, 'scheme' => $scheme, 'key' => $key, 'item' => $item, 'visiblefields' => $visiblefields)); ?>
                    <?php endforeach; ?>
                <?php endif; ?>
            </div>
        </div>
    </div> */ ?>
</div>
