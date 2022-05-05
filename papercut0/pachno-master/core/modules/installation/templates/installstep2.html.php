<?php include_component('installation/header'); ?>
<div class="installation_box">
    <h2 style="margin-top: 0;">Database information</h2>
    <?php if (isset($error)): ?>
        <div class="message-box type-error">
            <?= fa_image_tag('exclamation-triangle'); ?>
            <span class="message">
                An error occured when trying to validate the connection details:<br>
                <?php echo $error; ?>
            </span>
        </div>
    <?php endif; ?>
    <?php if ($preloaded): ?>
        <div class="message-box type-info">
            <?= fa_image_tag('exclamation-circle'); ?>
            <span class="message">
                <span class="title">
                    It looks like you've already completed this step
                </span>
                <span>
                    Please review the details and the click "Continue" to go the next step
                </span>
            </span>
        </div>
    <?php endif; ?>
    <p>Pachno uses a database to store information. To be able to connect to - and store information in - your database, we need some connection information.<br>
    <form accept-charset="utf-8" action="index.php" method="post" id="database_connection">
        <input type="hidden" name="step" value="3">
        <dl class="install_list">
            <dt>
                <label for="db_username">Username</label>
            </dt>
            <dd><input type="text" class="username" name="db_username" placeholder="Database username" id="db_username" value="<?php if (isset($username)) echo $username; ?>"></dd>
            <dt>
                <label for="db_password">Password</label>
            </dt>
            <dd><input type="password" class="password" name="db_password" id="db_password" value="<?php if (isset($password)) echo $password; ?>" placeholder="Database password"></dd>
            <dt>
                <label for="db_name">Table prefix</label><br>
            </dt>
            <dd>
                <input type="text" name="db_prefix" class="small" id="db_prefix" value="pachno_">
                <span class="helptext">If specified, all table names are prefixed. Useful when installing in a shared database.</span>
            </dd>
        </dl>
        <br style="clear: both;">
        <div>
            <label for="connection_type_dsn">DSN</label><input type="radio" style="vertical-align: text-top;" name="connection_type" value="dsn" id="connection_type_dsn"<?php if ($selected_connection_detail == 'dsn'): ?> checked<?php endif; ?> onclick="$('#dsn_info').show();$('#custom_info').hide()">&nbsp;&nbsp;
            <label for="connection_type_custom">Custom</label><input type="radio" style="vertical-align: text-top;" name="connection_type" value="custom" id="connection_type_custom"<?php if ($selected_connection_detail == 'custom'): ?> checked<?php endif; ?> onclick="$('#dsn_info').hide();$('#custom_info').show()">
        </div>
        <dl class="install_list" style="<?php if ($selected_connection_detail != 'dsn') echo 'display: none;'; ?>" id="dsn_info">
            <dt style="padding-bottom: 10px;">
                <label for="db_dsn">DSN</label>
            </dt>
            <dd>
                <input type="text" class="dsn" name="db_dsn" id="db_dsn"<?php if (isset($dsn)): ?> value="<?php echo $dsn; ?>"<?php endif; ?>>
                <i><a href="http://www.php.net/manual/en/pdo.construct.php" target="_blank">What is a DSN?</a></i>
            </dd>
        </dl>
        <dl class="install_list" style="<?php if ($selected_connection_detail != 'custom') echo 'display: none;'; ?>" id="custom_info">
            <dt>
                <label for="db_type">Database type</label>
            </dt>
            <dd>
                <select name="db_type" id="db_type">
                <?php foreach (\b2db\Core::getDrivers() as $db_type => $db_desc): ?>
                    <option value="<?php echo $db_type; ?>"<?php if (isset($b2db_dbtype) && $b2db_dbtype == $db_type): ?> selected<?php endif; ?><?php if (!extension_loaded("pdo_{$db_type}")) echo ' disabled title="PHP extension missing"'; ?>><?php echo $db_desc; ?></option>
                <?php endforeach; ?>
                </select>
            </dd>
            <dt>
                <label for="db_hostname">Database hostname:port</label>
            </dt>
            <dd>
                <input type="text" name="db_hostname" id="db_hostname" value="<?php if (isset($hostname)) echo $hostname; ?>"> :
                <input type="text" name="db_port" class="smallest" placeholder="default" id="db_port" value="<?php if (isset($port)) echo $port; ?>">
            </dd>
            <dt>
                <label for="db_name">Database name</label>
            </dt>
            <dd>
                <input type="text" name="db_name" class="small" id="db_name" value="<?php echo (isset($db_name)) ? $db_name : 'pachno'; ?>">
                <span class="helptext">The database used to store Pachno tables <i>(must already exist!)</i></span>
            </dd>
        </dl>
        <div class="message-box type-warning">
            <?= fa_image_tag('exclamation-triangle'); ?>
            <span class="message">
            <span class="title">
                Pressing "Continue" on this page will write to your database.
            </span>
            The installation routine will overwrite any pre-existing tables from previous installations, if pointed to an existing Pachno database
        </span>
        </div>
        <div style="display: flex; width: 100%; align-items: center; justify-content: center; flex-direction: row; margin: 30px 0 20px;">
            <button type="submit" onclick="document.getElementById('continue_button').classList.add('disabled');document.getElementById('database_connection').classList.add('submitting');" id="continue_button" style="margin-left: auto;">
                <span class="name"><?= __('Continue'); ?></span>
                <?= fa_image_tag('spinner', ['class' => 'fa-spin icon indicator']); ?>
            </button>
        </div>
    </form>
    <p id="connection_status"></p>
</div>
<?php include_component('installation/footer'); ?>
