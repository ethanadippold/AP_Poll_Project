
/*Original query to show team, ranks and change.
Error: Would not display teams that were not ranked in both pre and postseason */
SELECT pre.season, pre.team, pre.rank, post.rank, (pre.rank - post.rank) as "Change"
FROM AP_Poll_Script AS pre
JOIN AP_Poll_Script AS post
  ON pre.Team = post.Team AND pre.Season = post.Season
WHERE pre.week='Preseason' and post.week='Postseason';

/* Query to show every preseason ranked team and their postseason ranking
included teams ranked preseason and unranked postseason, but not vice versa*/
SELECT pre.season, pre.team, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change"
FROM AP_Poll_Script AS pre
LEFT JOIN AP_Poll_Script AS post
  ON pre.Team = post.Team AND pre.Season = post.Season AND post.Week = 'Postseason'
WHERE pre.week='Preseason';

/* This one does the exact opposite as the last, showing all teams ranked at the end of the season
compared to where they were at the beginning of the season*/
SELECT post.season, post.team, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change"
FROM AP_Poll_Script AS post
LEFT JOIN AP_Poll_Script AS pre
	ON pre.Team = post.Team AND pre.Season = post.Season AND pre.Week = 'Preseason'
WHERE post.week='Postseason';

/*Now I am going to join my past two queries using UNION as to eliminate
any duplicate values (teams who were ranked both pre and postseason*/
SELECT pre.season, pre.team, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change"
FROM AP_Poll_Script AS pre
LEFT JOIN AP_Poll_Script AS post
  ON pre.Team = post.Team AND pre.Season = post.Season AND post.Week = 'Postseason'
WHERE pre.week='Preseason'
UNION
SELECT post.season, post.team, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change"
FROM AP_Poll_Script AS post
LEFT JOIN AP_Poll_Script AS pre
	ON pre.Team = post.Team AND pre.Season = post.Season AND pre.Week = 'Preseason'
WHERE post.week='Postseason';

/*The only remaining task is to create a metric by which we can judge "change"
If a team was unranked at any point we don't know how much they rose or dropped
(and their value is null) We will have to create a new column that will standardize 
everything and include those teams*/
SELECT pre.season, pre.team, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change", CASE
  WHEN (pre.rank - post.rank) BETWEEN -5 AND 5 THEN 'Properly Rated'
  WHEN (pre.rank - post.rank) > 5 OR pre.rank IS NULL THEN 'Underrated'
  WHEN (pre.rank - post.rank) < -5 OR post.rank IS NULL THEN 'Overrated'
  ELSE 'Anomaly'
END AS Status
FROM AP_Poll_Script AS pre
LEFT JOIN AP_Poll_Script AS post
  ON pre.Team = post.Team AND pre.Season = post.Season AND post.Week = 'Postseason'
WHERE pre.week='Preseason'
UNION
SELECT post.season, post.team, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change", CASE
  WHEN (pre.rank - post.rank) BETWEEN -5 AND 5 THEN 'Properly Rated'
  WHEN (pre.rank - post.rank) > 5 OR pre.rank IS NULL THEN 'Underrated'
  WHEN (pre.rank - post.rank) < -5 OR post.rank IS NULL THEN 'Overrated'
  ELSE 'Anomaly'
END AS Status
FROM AP_Poll_Script AS post
LEFT JOIN AP_Poll_Script AS pre
	ON pre.Team = post.Team AND pre.Season = post.Season AND pre.Week = 'Preseason'
WHERE post.week='Postseason';

/* one last thing I forgot that I made an entire conference table to reference*/
SELECT pre.season, pre.team, conf.conference, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change", CASE
  WHEN (pre.rank - post.rank) BETWEEN -5 AND 5 THEN 'Properly Rated'
  WHEN (pre.rank - post.rank) > 5 OR pre.rank IS NULL THEN 'Underrated'
  WHEN (pre.rank - post.rank) < -5 OR post.rank IS NULL THEN 'Overrated'
  ELSE 'Anomaly'
END AS Status
FROM AP_Poll_Script AS pre
JOIN team_conferences_REFERENCE as conf on pre.team=conf.team AND pre.season = conf.season
LEFT JOIN AP_Poll_Script AS post
  ON pre.Team = post.Team AND pre.Season = post.Season AND post.Week = 'Postseason'
WHERE pre.week='Preseason'
UNION
SELECT post.season, post.team, conf.conference, pre.rank AS "PreRank", post.rank AS "PostRank", (pre.rank - post.rank) as "Change", CASE
  WHEN (pre.rank - post.rank) BETWEEN -5 AND 5 THEN 'Properly Rated'
  WHEN (pre.rank - post.rank) > 5 OR pre.rank IS NULL THEN 'Underrated'
  WHEN (pre.rank - post.rank) < -5 OR post.rank IS NULL THEN 'Overrated'
  ELSE 'Anomaly'
END AS Status
FROM AP_Poll_Script AS post
JOIN team_conferences_REFERENCE as conf on post.team=conf.team AND post.season = conf.season
LEFT JOIN AP_Poll_Script AS pre
	ON pre.Team = post.Team AND pre.Season = post.Season AND pre.Week = 'Preseason'
WHERE post.week='Postseason';
/* I then wanted to come back and edit this so teams who were unranked at some point
get factored into the change column*/
/* This is going to require multiple new CASE functions. Hopefully final edit.*/
SELECT pre.season, pre.team, conf.conference,
  pre.rank AS "PreRank", post.rank AS "PostRank",
  CASE
    WHEN pre.rank IS NULL THEN 35 - post.rank
    WHEN post.rank IS NULL THEN pre.rank - 35
    ELSE pre.rank - post.rank
  END AS "Change",
  CASE
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN -35 AND -21 THEN 'Very Overrated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN -20 AND -6 THEN 'Overrated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN -5 AND 5 THEN 'Properly Rated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN 6 AND 20 THEN 'Underrated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN 21 AND 35 THEN 'Very Underrated'
    ELSE 'Anomaly'
  END AS Status
FROM AP_Poll_Script AS pre
JOIN team_conferences_REFERENCE as conf on pre.team=conf.team AND pre.season = conf.season
LEFT JOIN AP_Poll_Script AS post
  ON pre.Team = post.Team AND pre.Season = post.Season AND post.Week = 'Postseason'
WHERE pre.week='Preseason'
UNION
SELECT post.season, post.team, conf.conference,
  pre.rank AS "PreRank", post.rank AS "PostRank",
  CASE
    WHEN pre.rank IS NULL THEN 35 - post.rank
    WHEN post.rank IS NULL THEN pre.rank - 35
    ELSE pre.rank - post.rank
  END AS "Change",
  CASE
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN -35 AND -21 THEN 'Very Overrated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN -20 AND -6 THEN 'Overrated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN -5 AND 5 THEN 'Properly Rated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN 6 AND 20 THEN 'Underrated'
    WHEN (CASE WHEN pre.rank IS NULL THEN 35 - post.rank WHEN post.rank IS NULL THEN pre.rank - 35 ELSE pre.rank - post.rank END) BETWEEN 21 AND 35 THEN 'Very Underrated'
    ELSE 'Anomaly'
  END AS Status
FROM AP_Poll_Script AS post
JOIN team_conferences_REFERENCE as conf on post.team=conf.team AND post.season = conf.season
LEFT JOIN AP_Poll_Script AS pre
	ON pre.Team = post.Team AND pre.Season = post.Season AND pre.Week = 'Preseason'
WHERE post.week='Postseason'