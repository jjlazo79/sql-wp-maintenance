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




-- Extract posts with feature image and metayoast
SELECT 
 p.ID,
 p.post_content,
 p.post_title,
 p.post_excerpt,
 p.post_name as url,
 users.user_nicename as author,
 pm2.meta_value as metadesc,
 pm3.meta_value as metatitle,
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
WHERE post_type = 'post' AND post_status = 'publish'
