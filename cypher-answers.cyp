// Which directors also acted in their movie?
MATCH (d)-[:DIRECTED]->(m)<-[:ACTED_IN]-(d)
RETURN d.name, m.title;

// Who are the 5 busiest actors?
MATCH (a:Person)-[:ACTED_IN]->()
RETURN a.name, count(*) AS count
ORDER BY count DESC
LIMIT 5;

// Recommend 5 actors that Keanu Reeves should work with (but hasn't)
MATCH (keanu:Person)-[:ACTED_IN]->()<-[:ACTED_IN]-(c),
      (c)-[:ACTED_IN]->()<-[:ACTED_IN]-(coc)

WHERE keanu.name="Keanu Reeves"
AND NOT((keanu)-[:ACTED_IN]->()<-[:ACTED_IN]-(coc))
AND coc <> keanu

RETURN coc.name, count(coc)
ORDER BY count(coc) DESC
LIMIT 3;

// Change Kevin Bacon’s role in Mystic River from “Sean” to “Sean Devine”
MATCH (kevin:Person {name:"Kevin Bacon"})-[r:ACTED_IN]->(movie:Movie {title:"Mystic River"})
SET r.roles = [n in r.roles WHERE n <> "Sean"] + "Sean Devine"
RETURN r.roles;

// Add Clint Eastwood as the director of Mystic River
MATCH (movie:Movie {title:"Mystic River"}),
      (clint:Person {name:"Clint Eastwood"}) 
MERGE (clint)-[:DIRECTED]->(movie);

// List all the character roles in the movie “The Matrix”
MATCH (matrix:Movie {title:"The Matrix"})<-[r:ACTED_IN]-()
RETURN r.roles;

// Add KNOWS relationships between all actors who were in the same movie
MATCH (a:Person)-[:ACTED_IN]->()<-[:ACTED_IN]-(b:Person)
CREATE UNIQUE (a)-[:KNOWS]-(b);

// Return Friends-of-Friends of Keanu Reeves who are not immediate friends
MATCH (keanu:Person {name:"Keanu Reeves"})-[:KNOWS*2]-(fof)
WHERE keanu <> fof AND NOT (keanu)-[:KNOWS]-(fof)
RETURN DISTINCT fof.name;

// Names of the people joining Charlize -> Kevin
MATCH p=shortestPath((charlize:Person)-[:KNOWS*]-(bacon:Person))
WHERE charlize.name="Charlize Theron" AND bacon.name="Kevin Bacon"
RETURN [n in nodes(p) | n.name] AS names;

