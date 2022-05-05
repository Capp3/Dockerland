<?php

    use pachno\core\framework\Context;
    use pachno\core\framework\Settings;
    use pachno\core\framework\Event;

    /**
     * @var \pachno\core\entities\Project $project
     * @var int $access_level
     */

?>
<div class="form-container">
    <?php if ($access_level == Settings::ACCESS_FULL): ?>
    <form
        accept-charset="<?= Context::getI18n()->getCharset(); ?>"
        data-submit-project-settings
        data-project-id="<?= $project->getID(); ?>"
        action="<?= make_url('configure_project_settings', ['project_id' => $project->getID()]); ?>"
        method="post"
        id="project_links"
        data-interactive-form
    >
    <?php endif; ?>
        <div class="form-row">
            <h3><?= __('Project links'); ?></h3>
        </div>
        <div class="helper-text">
            <div class="image-container"><?= image_tag('/unthemed/onboarding_project_links_icon.png', [], true); ?></div>
            <span class="description"><?= __('Project links lets you specify links to various resources related to the project. These links are shown in project overviews, info boxes and more.') ;?></span>
        </div>
        <div class="form-row">
            <?php if ($access_level == Settings::ACCESS_FULL): ?>
                <input type="text" name="homepage" id="homepage" value="<?php echo $project->getHomepage(); ?>" style="width: 100%;">
            <?php elseif ($project->hasHomepage()): ?>
                <a href="<?php echo $project->getHomepage(); ?>"><?php echo $project->getHomepage(); ?></a>
            <?php else: ?>
                <span class="faded_out"><?php echo __('No homepage set'); ?></span>
            <?php endif; ?>
            <label for="homepage"><?php echo __('Homepage'); ?></label>
        </div>
        <div class="form-row">
            <?php if ($access_level == Settings::ACCESS_FULL): ?>
                <input type="text" name="doc_url" id="doc_url" value="<?php echo $project->getDocumentationURL(); ?>" style="width: 100%;">
            <?php elseif ($project->hasDocumentationURL()): ?>
                <a href="<?php echo $project->getDocumentationURL(); ?>"><?php echo $project->getDocumentationURL(); ?></a>
            <?php else: ?>
                <span class="faded_out"><?php echo __('No documentation URL provided'); ?></span>
            <?php endif; ?>
            <label for="doc_url"><?php echo __('Documentation URL'); ?></label>
        </div>
        <div class="form-row">
            <?php if ($access_level == Settings::ACCESS_FULL): ?>
                <input type="text" name="wiki_url" id="wiki_url" value="<?php echo $project->getWikiURL(); ?>" style="width: 100%;">
            <?php elseif ($project->hasWikiURL()): ?>
                <a href="<?php echo $project->getWikiURL(); ?>"><?php echo $project->getWikiURL(); ?></a>
            <?php else: ?>
                <span class="faded_out"><?php echo __('No wiki URL provided'); ?></span>
            <?php endif; ?>
            <label for="wiki_url"><?php echo __('Wiki URL'); ?></label>
        </div>
    <?php Event::createNew('core', 'project/projectinfo', $project)->trigger(); ?>
    <?php if ($access_level == Settings::ACCESS_FULL): ?>
        <div class="form-row submit-container">
            <?= fa_image_tag('spinner', ['class' => 'fa-spin icon indicator submit-indicator']); ?>
        </div>
    </form>
    <?php endif; ?>
</div>
