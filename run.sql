## Clear all revisions except last 5
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
                 
## Delete orphans postmetas
DELETE postmeta
FROM wp_postmeta AS postmeta
	LEFT JOIN wp_posts AS posts
	ON posts.ID = postmeta.post_id
WHERE posts.ID IS NULL
