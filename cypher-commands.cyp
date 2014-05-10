// Cypher commands for Intro to Cypher

// get pairs of nodes that are connected in any direction
MATCH (a)--(b)
RETURN a, b;

// get pairs of nodes which have an outgoing relationship 
// will have half as many results as the first query
MATCH (a)-->(b)
RETURN a, b;

// nodes that have an outgoing relationship
MATCH (a)-->()
RETURN a;

// a specific property
MATCH (a)-->()
RETURN a.name;

// relationship type
MATCH (a)-[r]->()
RETURN a.name, type(r);

// optionally find a relationship. if not null
MATCH (a)
OPTIONAL MATCH (a)-[r]->()
RETURN a.name, type(r);

// specify the relationship type
MATCH (a)-[:ACTED_IN]->(m)
RETURN a.name, m.title;

// movies, actors, roles
MATCH (a)-[r:ACTED_IN]->(m)
RETURN a.name, r.roles, m.title;

// actors and directors
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN a.name, m.title, d.name;

// alias the fields returned
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN a.name AS actor, m.title AS movie, d.name AS director;

// another version
MATCH (a)-[:ACTED_IN]->(m), (m)<-[:DIRECTED]-(d)
RETURN a.name, m.title, d.name;

// and another version
MATCH (a)-[:ACTED_IN]->(m), (d)-[:DIRECTED]->(m)
RETURN a.name, m.title, d.name;

// paths, paths are everywhere
MATCH p=(a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN p;

// only want them nodes
MATCH p=(a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN nodes(p);

// split up the paths
MATCH p1=(a)-[:ACTED_IN]->(m), p2=(d)-[:DIRECTED]->(m)
RETURN p1, p2;

// actor, director pairs 
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN a.name, d.name, count(*);

// pairs with aliases
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN a.name AS actor, d.name AS director, count(m) AS count;

// films that actors / directors worked on
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN a.name, d.name, collect(m.title);

// top 5 actor / director pairs
MATCH (a)-[:ACTED_IN]->(m)<-[:DIRECTED]-(d)
RETURN a.name, d.name, count(*) AS count
ORDER BY count DESC
LIMIT 5;

// relationships are unique - can't traverse the same one twice
MATCH (a)-[:ACTED_IN]->(m)<-[:ACTED_IN]-(a)
RETURN a.name, m.title;

// all nodes
MATCH (n)
RETURN n;

// all nodes scan + property check
MATCH (n)
WHERE n.name = "Tom Hanks"
RETURN n;

// concise version 
MATCH (n {name:"Tom Hanks"})
RETURN n;

// label scan version (much faster if we have different node types)
MATCH (tom:Person)
WHERE tom.name="Tom Hanks"
RETURN tom;

// Tom Hanks' movies
MATCH (tom:Person)-[:ACTED_IN]->(movie:Movie)
WHERE tom.name="Tom Hanks"
RETURN movie.title;

// Directors who worked with Tom Hanks
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(movie),
      (director)-[:DIRECTED]->(movie)
RETURN director.name;

// Remove duplicates
MATCH (tom:Person)-[:ACTED_IN]->()<-[:DIRECTED]-(director)
WHERE tom.name="Tom Hanks"
RETURN DISTINCT director.name;

// add indexes
CREATE INDEX ON :Person(name);
CREATE INDEX ON :Movie(title);

// Movies ft. Tom Hanks & Kevin Bacon
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(movie),
      (kevin:Person {name:"Kevin Bacon"})-[:ACTED_IN]->(movie)
RETURN DISTINCT movie.title;

// Movies in which Keanue Reeves played Neo
MATCH (actor:Person {name:"Keanu Reeves"})-[r:ACTED_IN]->(movie)
WHERE "Neo" IN (r.roles)
RETURN movie.title;

// using the ANY function
MATCH (actor:Person {name:"Keanu Reeves"})-[r:ACTED_IN]->(movie)
WHERE ANY( x IN r.roles WHERE x = "Neo")
RETURN DISTINCT movie.title;

// Actors who worked with Tom Hanks and are older than him
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(movie)<-[:ACTED_IN]-(a:Person)
WHERE a.born < tom.born
RETURN DISTINCT a.name;

// alias the age difference
MATCH (tom:Person {name:"Tom Hanks"})-[:ACTED_IN]->(movie)<-[:ACTED_IN]-(a:Person)
WHERE a.born < tom.born
RETURN DISTINCT a.name, (tom.born - a.born) AS diff;

// Actors who worked with Gene Hackman
MATCH (gene:Person {name:"Gene Hackman"})-[:ACTED_IN]->(movie)<-[:ACTED_IN]-(actor)
RETURN DISTINCT actor.name;

// Actors who worked with Gene Hackman and were directors of their own films
MATCH (gene:Person {name:"Gene Hackman"})-[:ACTED_IN]->(movie)<-[:ACTED_IN]->(director)
WHERE (director)-[:DIRECTED]->()
RETURN DISTINCT director.name;

// Actors who worked with Keanu but not when he worked with Gene Hackman
MATCH (keanu:Person {name:"Keanu Reeves"}) -[:ACTED_IN]->(movie)<-[:ACTED_IN]-(actor),
      (hugo:Person {name:"Hugo Weaving"})
WHERE NOT (hugo)-[:ACTED_IN]->(movie)
RETURN DISTINCT actor.name;

// Movies ft. Kevin Bacon
MATCH (kevin:Person {name:"Kevin Bacon"})-[:ACTED_IN]->(movie)
RETURN DISTINCT movie.title;

// Create Mystic River
CREATE (m:Movie {title:"Mystic River", released:1993});

// Check it got created
MATCH (m:Movie {title:"Mystic River"})
RETURN m;

// Add a missing property to the movie
MATCH (movie:Movie {title:"Mystic River"})
SET movie.tagline = "We bury our sins here, Dave. We wash them clean."
RETURN movie;

// Change an existing property
MATCH (movie:Movie {title:"Mystic River"})
SET movie.released = 2003
RETURN movie;

// Link Kevin to the movie
MATCH (movie:Movie {title:"Mystic River"}), (kevin:Person {name:"Kevin Bacon"})
MERGE (kevin)-[r:ACTED_IN]->(movie)
ON CREATE SET r.roles=["Sean", "Bob"]

// check they're linked
MATCH (kevin:Person {name:"Kevin Bacon"})-[:ACTED_IN]->(movie)
RETURN movie.title;

// finding Emil
MATCH (matrix:Movie {title:"The Matrix"})<-[r:ACTED_IN]-(a)
WHERE a.name =~ ".*Emil.*"
RETURN a;

// deleting Emil
MATCH (emil:Person {name:"Emil Eifrem"})
DELETE emil;

// deleting Emil's relationships 
MATCH (emil:Person {name:"Emil Eifrem"})-[r]-()
DELETE r;

// delete Emil & his relationships
MATCH (emil:Person {name: "Emil Eifrem"})
OPTIONAL MATCH (emil)-[r]-()
DELETE r, emil;

// find Clint Eastwood
MERGE (p:Person {name:"Clint Eastwood"})
RETURN p

// update Clint
MERGE (p:Person {name:"Clint Eastwood"})
  ON CREATE SET p.created = timestamp()
  ON MATCH SET p.accessed = coalesce(p.accessed,0)+1
RETURN p

// Create KNOWS relationships between anyone, Actors or Directors, who worked together
MATCH (a)-[:ACTED_IN|:DIRECTED]->()<-[:ACTED_IN|:DIRECTED]-(b)
CREATE UNIQUE (a)-[:KNOWS]-(b);

// Keanu's friends of friends
MATCH (keanu:Person {name:"Keanu Reeves"})-[:KNOWS*2]-(fof)
RETURN DISTINCT fof.name;

// Bacon number
MATCH p=shortestPath((charlize:Person)-[:KNOWS*]-(bacon:Person))
WHERE charlize.name="Charlize Theron" AND bacon.name="Kevin Bacon"
RETURN length(p);

// with inline property matching
MATCH (bacon:Person {name:"Kevin Bacon"}), (charlize:Person {name:"Charlize Theron"}),
      p=shortestPath((charlize)-[:KNOWS*]-(bacon))
RETURN length(p);






