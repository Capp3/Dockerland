<?php $pachno_response->setTitle(__('Configure theme(s)')); ?>
<div class="content-with-sidebar">
    <?php include_component('configuration/sidebar', ['selected_section' => \pachno\core\framework\Settings::CONFIGURATION_SECTION_THEMES]); ?>
    <div class="configuration-container config-plugins" id="config_themes">
        <h3><?= __('Configure theme(s)'); ?></h3>
        <div class="content faded_out">
            <p>
                <?= __('Select which theme to use for Pachno from this page. You can also download and install new themes.'); ?>
            </p>
        </div>
        <?php if ($theme_error !== null): ?>
            <div class="message-box type-error" id="theme_error">
                <span class="message"><?= fa_image_tag('exclamation-circle') . $theme_error; ?></span>
            </div>
        <?php endif; ?>
        <?php if (!$writable && $is_default_scope): ?>
            <div class="message-box type-warning" id="theme_message_writable_failure">
                <span class="message"><?= fa_image_tag('folder') . __('The themes folder (%themes_path) seems to not be writable. You may not be able to install new themes.', array('%themes_path' => PACHNO_PATH . 'themes')); ?></span>
            </div>
        <?php endif; ?>
        <?php if (!$writable_link && $is_default_scope): ?>
            <div class="message-box type-warning" id="theme_message_writable_link_failure">
                <span class="message"><?= fa_image_tag('folder') . __('The themes public folder (%themes_public_path) seems to not be writable. You may not be able to install new themes.', array('%themes_public_path' => PACHNO_PATH . PACHNO_PUBLIC_FOLDER_NAME . DS . 'themes')); ?></span>
            </div>
        <?php endif; ?>
        <?php if ($theme_message !== null): ?>
            <div class="message-box type-info" id="theme_message">
                <span class="message"><?= fa_image_tag('exclamation-circle') . $theme_message; ?></span>
            </div>
        <?php endif; ?>
        <div style="margin-top: 15px; clear: both;" class="tab_menu inset">
            <ul id="themes_menu">
                <li id="tab_installed" class="selected"><?= javascript_link_tag(image_tag('spinning_16.gif', array('id' => 'installed_themes_indicator', 'style' => 'display: none;')).__('Installed themes (%count)', array('%count' => count($themes))), array('onclick' => "Pachno.UI.tabSwitcher('tab_installed', 'themes_menu');")); ?></li>
                <li id="tab_install"><?= javascript_link_tag(__('Discover new themes'), array('onclick' => "Pachno.UI.tabSwitcher('tab_install', 'themes_menu');")); ?></li>
            </ul>
        </div>
        <div id="themes_menu_panes">
            <div id="tab_installed_pane" style="padding-top: 0;">
                <ul class="themes-list installed plugins-list" id="installed-themes-list">
                    <?php foreach ($themes as $theme_key => $theme): ?>
                        <?php include_component('theme', array('theme' => $theme)); ?>
                    <?php endforeach; ?>
                </ul>
            </div>
            <div id="tab_install_pane" style="padding-top: 0; width: 100%; display: none;">
                <div id="available_themes_loading_indicator"><?= image_tag('spinning_16.gif'); ?></div>
                <div id="available_themes_container" class="available_plugins_container">

                </div>
            </div>
        </div>
    </div>
</div>
<?php if ($is_default_scope): ?>
    <script>
        require(['domReady', 'pachno/index'], function (domReady, Pachno) {
            domReady(function () {
                Pachno.Themes.getAvailableOnline();
                Pachno.Themes.getThemeUpdates();
            });
        });
    </script>
<?php endif; ?>
