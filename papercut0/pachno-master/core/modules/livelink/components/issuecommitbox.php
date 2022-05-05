<?php

    /** @var \pachno\core\entities\Branch $branch */
    /** @var \pachno\core\entities\Commit $commit */
    /** @var \pachno\core\entities\Project $project */

?>
<div class="comment" id="commit_<?php echo $commit->getID(); ?>">
    <div id="commit_view_<?php echo $commit->getID(); ?>" class="comment_main">
        <div id="commit_<?php echo $commit->getID(); ?>_header" class="commentheader">
            <div class="commenttitle">
                <?php include_component('main/userdropdown', array('user' => $commit->getAuthor(), 'size' => 'large')); ?>
            </div>
            <div class="comment_hash">
                <a href="javascript:void(0)" onclick="Pachno.UI.Backdrop.show('<?php echo make_url('get_partial_for_backdrop', array('key' => 'livelink_getcommit', 'commit_id' => $commit->getID())); ?>');"><?php echo $commit->getRevisionString(); ?></a>
            </div>
            <div class="commentdate" id="commit_<?php echo $commit->getID(); ?>_date">
                <?php echo \pachno\core\framework\Context::getI18n()->formatTime($commit->getDate(), 9); ?>
            </div>
        </div>

        <div class="commentbody article commit_main" id="commit_<?php echo $commit->getID(); ?>_body">
            <?php echo \pachno\core\helpers\TextParser::parseText(trim($commit->getLog()), false, null, array('target' => $commit)); ?>
        </div>
    </div>
</div>
