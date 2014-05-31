CREATE TABLE articles (
  id serial,
  content varchar(1000) NOT NULL,
  created_at timestamp
);


CREATE TABLE comments (
  id serial,
  username varchar(50) NOT NULL,
  content varchar(1000) NOT NULL,
  votes integer,
  article_id integer NOT NULL,
  created_at timestamp
);

INSERT INTO comments (username, content, votes, article_id, created_at) VALUES ('alex.am', 'Great question... 42', 0, 1, NOW());

INSERT INTO articles (content, created_at) VALUES ('What is life?', NOW());
