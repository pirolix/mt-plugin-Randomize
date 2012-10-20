<?php
// $Id$

function smarty_block_mtrandomize ($args, $content, &$ctx, &$repeat) {
    $localized_values = array ('separator');
    if (!isset ($content)) {
        $ctx->localize ($localized_values);
        $ctx->stash ('separator', sprintf ('---%s---', md5 (rand ())));
    } else {
        $separator = $ctx->stash ('separator');
        $pattern = sprintf ('/^\s*%s|%s\s*$/', $separator, $separator);
        $content = preg_replace ($pattern, '', $content);
        $contents = explode ($separator, $content);
        shuffle ($contents);
        if ($args['lastn'])
            $contents = array_slice ($contents, 0, $args['lastn']);
        $content = implode ('', $contents);
        $ctx->restore ($localized_values);
    }
    return $content;
}
?>