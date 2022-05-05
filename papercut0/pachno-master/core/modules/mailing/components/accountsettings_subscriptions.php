<?php

    use pachno\core\modules\mailing\Mailing;

?>
<table class="padded_table" cellpadding="0" cellspacing="0">
    <tr>
        <td style="width: auto; border-bottom: 1px solid #DDD; vertical-align: middle;">
            <input type="checkbox" class="fancy-checkbox" name="mailing_<?= Mailing::NOTIFY_NOT_WHEN_ACTIVE; ?>" value="1" id="mailing_<?= Mailing::NOTIFY_NOT_WHEN_ACTIVE; ?>_yes"<?php if ($pachno_user->getNotificationSetting(Mailing::NOTIFY_NOT_WHEN_ACTIVE, false, 'mailing')->isOn()): ?> checked<?php endif; ?>>
            <label for="mailing_<?= Mailing::NOTIFY_NOT_WHEN_ACTIVE; ?>_yes"><?= fa_image_tag('check-square', ['class' => 'checked'], 'far') . fa_image_tag('square', ['class' => 'unchecked'], 'far') . __("Don't send email notification if I'm currently logged in and active") ?></label></td>
        </td>
    </tr>
</table>
