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
