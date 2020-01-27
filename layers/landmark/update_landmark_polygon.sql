DROP TRIGGER IF EXISTS trigger_flag ON osm_landmark_polygon;
DROP TRIGGER IF EXISTS trigger_refresh ON landmark_polygon.updates;

-- etldoc:  osm_landmark_polygon ->  osm_landmark_polygon

-- Handle updates

CREATE SCHEMA IF NOT EXISTS landmark_polygon;

CREATE TABLE IF NOT EXISTS landmark_polygon.updates(id serial primary key, t text, unique (t));
CREATE OR REPLACE FUNCTION landmark_polygon.flag() RETURNS trigger AS $$
BEGIN
    INSERT INTO landmark_polygon.updates(t) VALUES ('y')  ON CONFLICT(t) DO NOTHING;
    RETURN null;
END;
$$ language plpgsql;

CREATE OR REPLACE FUNCTION landmark_polygon.refresh() RETURNS trigger AS
  $BODY$
  BEGIN
    RAISE LOG 'Refresh landmark_polygon';
    PERFORM update_landmark_polygon();
    DELETE FROM landmark_polygon.updates;
    RETURN null;
  END;
  $BODY$
language plpgsql;

CREATE TRIGGER trigger_flag
    AFTER INSERT OR UPDATE OR DELETE ON osm_landmark_polygon
    FOR EACH STATEMENT
    EXECUTE PROCEDURE landmark_polygon.flag();

CREATE CONSTRAINT TRIGGER trigger_refresh
    AFTER INSERT ON landmark_polygon.updates
    INITIALLY DEFERRED
    FOR EACH ROW
    EXECUTE PROCEDURE landmark_polygon.refresh();
