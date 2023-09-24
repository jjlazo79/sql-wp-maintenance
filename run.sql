-- Clear all revisions except last 5
DELETE
FROM wp_posts
WHERE post_type = "revision"
  AND ID NOT IN(SELECT ID
                FROM (SELECT ID
                      FROM wp_posts
                      WHERE post_type = 'revision'
                      ORDER BY ID
                      DESC LIMIT 5)
                 rev)



-- Delete orphans postmetas
DELETE postmeta
FROM wp_postmeta AS postmeta
	LEFT JOIN wp_posts AS posts
	ON posts.ID = postmeta.post_id
WHERE posts.ID IS NULL



-- Extract posts with feature image, categories, tags and metayoast
SELECT 
 p.ID,
 p.post_content,
 p.post_title,
 p.post_excerpt,
 p.post_name as url,
 p.post_date,
 users.user_nicename as author,
 pm2.meta_value as metadesc,
 pm3.meta_value as metatitle,
 GROUP_CONCAT(DISTINCT c.`name`) as categories,
GROUP_CONCAT(DISTINCT t.`name`) as tags,
 (SELECT guid
    FROM   wp_posts
    WHERE  id = pm4.meta_value) AS image
FROM wp_posts p
LEFT JOIN wp_users users
    ON p.post_author = users.ID
LEFT JOIN wp_postmeta pm2
    ON p.ID = pm2.post_id
    AND pm2.meta_key = '_yoast_wpseo_metadesc'
LEFT JOIN wp_postmeta pm3
    ON p.ID = pm3.post_id
    AND pm3.meta_key = '_yoast_wpseo_title'
LEFT JOIN wp_postmeta pm4
    ON p.ID = pm4.post_id
    AND pm4.meta_key = '_thumbnail_id'
LEFT JOIN wp_term_relationships cr
    ON (p.`id`=cr.`object_id`)
LEFT JOIN wp_term_taxonomy ct
    ON (ct.`term_taxonomy_id`=cr.`term_taxonomy_id`
    AND ct.`taxonomy`='category')
LEFT JOIN wp_terms c
    ON (ct.`term_id`=c.`term_id`)
LEFT JOIN wp_term_relationships tr
    ON (p.`id`=tr.`object_id`)
LEFT JOIN wp_term_taxonomy tt
    ON (tt.`term_taxonomy_id`=tr.`term_taxonomy_id`
    AND tt.`taxonomy`='post_tag')
LEFT JOIN wp_terms t
    ON (tt.`term_id`=t.`term_id`)
WHERE post_type = 'post' AND post_status = 'publish'


-- Check Autoloaded Data Size
SELECT SUM(LENGTH(option_value)) as autoload_size
FROM wp_options
WHERE autoload='yes';


-- This will show you the autoloaded data size, how many entries are in the table, and the first 10 entries by size
SELECT 'autoloaded data in KiB' as name, ROUND(SUM(LENGTH(option_value))/ 1024) as value
FROM wp_options
WHERE autoload='yes'
    UNION
    SELECT 'autoloaded data count', count(*)
    FROM wp_options
    WHERE autoload='yes'
        UNION
        (SELECT option_name, length(option_value)
        FROM wp_options
        WHERE autoload='yes'
        ORDER BY length(option_value)
        DESC LIMIT 10)


-- Sort Top Autoloaded Data
SELECT option_name, length(option_value) AS option_value_length
FROM wp_options
WHERE autoload='yes'
ORDER BY option_value_length
DESC LIMIT 10;


-- Clean up WordPress Sessions
DELETE 
FROM `wp_options` 
WHERE `option_name`
LIKE '_wp_session_%'

