<li class="header disabled"><?php echo __('%num article(s) found', array('%num' => $resultcount)); ?></li>
<?php $cc = 0; ?>
<?php if ($resultcount > 0): ?>
    <?php foreach ($articles as $article): ?>
        <?php $cc++; ?>
        <?php if ($article instanceof \pachno\core\entities\Article): ?>
            <li class="issue_open<?php if ($cc == count($articles) && $resultcount == count($articles)): ?> last<?php endif; ?>"><div class="link_container"><?php echo image_tag('tab_publish.png', array('class' => 'informal'), false, 'publish'); ?><a href="<?php echo make_url('publish_article', array('article_name' => $article->getName())); ?>"><?php echo (mb_strlen($article->getName()) <= 32) ? $article->getName() : str_pad(mb_substr($article->getName(), 0, 32), 35, '...'); ?></a></div><span class="informal"><?php echo __('Last updated %updated_at', array('%updated_at' => \pachno\core\framework\Context::getI18n()->formatTime($article->getLastUpdatedDate(), 6))); ?></span><span class="informal url"><?php echo make_url('publish_article', array('article_name' => $article->getName())); ?></span></li>
        <?php endif; ?>
    <?php endforeach; ?>
    <?php if (true || $resultcount - $cc > 0): ?>
        <li class="find_more_issues last">
            <span class="informal"><?php echo __('See %num more articles ...', array('%num' => $resultcount - $cc)); ?></span>
            <div class="hidden url"><?php echo (\pachno\core\framework\Context::isProjectContext()) ? make_url('publish_find_project_articles', array('project_key' => \pachno\core\framework\Context::getCurrentProject()->getKey())) : make_url('publish_find_articles'); ?>?articlename=<?php echo $searchterm; ?></div>
        </li>
    <?php endif; ?>
<?php else: ?>
    <li class="disabled no_issues_found">
        <?php echo __('No articles found matching your query'); ?>
    </li>
<?php endif; ?>
