--------------------------------------------------------
--  DDL for Package Body JTF_LOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_LOC_PVT" AS
/* $Header: jtfvhldb.pls 120.2 2005/08/18 22:55:07 stopiwal ship $ */


TYPE loc_area_rec_type IS RECORD(
   location_area_id         NUMBER,
   location_area_code       VARCHAR2(30),
   location_type_code       VARCHAR2(30),
   parent_location_area_id  NUMBER,
   request_id               NUMBER,
   program_application_id   NUMBER,
   program_id               NUMBER,
   program_update_date      DATE,
   start_date_active        DATE,
   end_date_active          DATE,
   location_postal_code_id  number
);

TYPE loc_hierarchy_rec_type IS RECORD(
   location_hierarchy_id  NUMBER,
   location_type_code     VARCHAR2(30),
   area1_id               NUMBER,
   area1_code             VARCHAR2(30),
   area2_id               NUMBER,
   area2_code             VARCHAR2(30),
   country_id             NUMBER,
   country_code           VARCHAR2(30),
   country_region_id      NUMBER,
   country_region_code    VARCHAR2(30),
   state_id               NUMBER,
   state_code             VARCHAR2(30),
   state_region_id        NUMBER,
   state_region_code      VARCHAR2(30),
   city_id                NUMBER,
   city_code              VARCHAR2(30),
   postal_code_id         NUMBER
);


-----------------------------------------------------------------------
-- FUNCTION
--   get_loc_hierarchy_id
-- PURPOSE
--   get hierarchy id if the area is existing in hierarchy table.
-- NOTES
-----------------------------------------------------------------------
FUNCTION get_loc_hierarchy_id(p_hier_rec IN loc_hierarchy_rec_type)
RETURN NUMBER
IS

   l_hier_id  NUMBER;

   CURSOR c_hier IS
   SELECT location_hierarchy_id
     FROM jtf_loc_hierarchies_b
    WHERE location_type_code = p_hier_rec.location_type_code
      AND DECODE(p_hier_rec.location_type_code,
             'AREA1', area1_id,
             'AREA2', area2_id,
             'COUNTRY', country_id,
             'CREGION', country_region_id,
             'STATE', state_id,
             'SREGION', state_region_id,
             'CITY', city_id,
             'POSTAL_CODE', postal_code_id
          ) =
          DECODE(p_hier_rec.location_type_code,
             'AREA1', p_hier_rec.area1_id,
             'AREA2', p_hier_rec.area2_id,
             'COUNTRY', p_hier_rec.country_id,
             'CREGION', p_hier_rec.country_region_id,
             'STATE', p_hier_rec.state_id,
             'SREGION', p_hier_rec.state_region_id,
             'CITY', p_hier_rec.city_id,
             'POSTAL_CODE', p_hier_rec.postal_code_id
          );

BEGIN

   OPEN c_hier;
   FETCH c_hier INTO l_hier_id;
   CLOSE c_hier;

   RETURN l_hier_id;

END;


-----------------------------------------------------------------------
-- PROCEDURE
--   load_hierarchy(
-- PURPOSE
--   load areas to hierarchy table
-- NOTES
--   Create or update depending on the id returned by the function get_loc_hierarchy_id.
-----------------------------------------------------------------------
PROCEDURE load_hierarchy(
   p_area_rec  IN loc_area_rec_type,
   p_hier_rec  IN loc_hierarchy_rec_type
)
IS

   l_hier_id  NUMBER;
   l_count    NUMBER;

   CURSOR c_hier_seq IS
   SELECT jtf_loc_hierarchies_b_s.NEXTVAL
     FROM DUAL;

   CURSOR c_hier_count IS
   SELECT count(*)
     FROM jtf_loc_hierarchies_b
    WHERE location_hierarchy_id = l_hier_id;

BEGIN

   l_hier_id := get_loc_hierarchy_id(p_hier_rec);

   IF l_hier_id IS NOT NULL THEN
      UPDATE jtf_loc_hierarchies_b
         SET location_hierarchy_id = l_hier_id,
             last_update_date = SYSDATE,
             last_updated_by = FND_GLOBAL.user_id,
             last_update_login = FND_GLOBAL.conc_login_id,
             object_version_number = object_version_number + 1,
             request_id = p_area_rec.request_id,
             program_application_id = p_area_rec.program_application_id,
             program_id = p_area_rec.program_id,
             program_update_date = p_area_rec.program_update_date,
             created_by_application_id = 530,
             start_date_active = p_area_rec.start_date_active,
             end_date_active = p_area_rec.end_date_active,
             location_type_code = p_hier_rec.location_type_code,
             area1_id = p_hier_rec.area1_id,
             area1_code = p_hier_rec.area1_code,
             area2_id = p_hier_rec.area2_id,
             area2_code = p_hier_rec.area2_code,
             country_id = p_hier_rec.country_id,
             country_code = p_hier_rec.country_code,
             country_region_id = p_hier_rec.country_region_id,
             country_region_code = p_hier_rec.country_region_code,
             state_id = p_hier_rec.state_id,
             state_code = p_hier_rec.state_code,
             state_region_id = p_hier_rec.state_region_id,
             state_region_code = p_hier_rec.state_region_code,
             city_id = p_hier_rec.city_id,
             city_code = p_hier_rec.city_code,
             postal_code_id = p_hier_rec.postal_code_id
       WHERE location_hierarchy_id = l_hier_id;
   ELSE
      LOOP
         OPEN c_hier_seq;
         FETCH c_hier_seq INTO l_hier_id;
         CLOSE c_hier_seq;

         OPEN c_hier_count;
         FETCH c_hier_count INTO l_count;
         CLOSE c_hier_count;

         EXIT WHEN l_count = 0;
      END LOOP;

      INSERT INTO jtf_loc_hierarchies_b(
         location_hierarchy_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         object_version_number,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         created_by_application_id,
         start_date_active,
         end_date_active,
         location_type_code,
         area1_id,
         area1_code,
         area2_id,
         area2_code,
         country_id,
         country_code,
         country_region_id,
         country_region_code,
         state_id,
         state_code,
         state_region_id,
         state_region_code,
         city_id,
         city_code,
         postal_code_id
      )
      VALUES(
         l_hier_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         SYSDATE,
         FND_GLOBAL.user_id,
         FND_GLOBAL.conc_login_id,
         1,
         p_area_rec.request_id,
         p_area_rec.program_application_id,
         p_area_rec.program_id,
         p_area_rec.program_update_date,
         530,
         p_area_rec.start_date_active,
         p_area_rec.end_date_active,
         p_hier_rec.location_type_code,
         p_hier_rec.area1_id,
         p_hier_rec.area1_code,
         p_hier_rec.area2_id,
         p_hier_rec.area2_code,
         p_hier_rec.country_id,
         p_hier_rec.country_code,
         p_hier_rec.country_region_id,
         p_hier_rec.country_region_code,
         p_hier_rec.state_id,
         p_hier_rec.state_code,
         p_hier_rec.state_region_id,
         p_hier_rec.state_region_code,
         p_hier_rec.city_id,
         p_hier_rec.city_code,
         p_hier_rec.postal_code_id
      );
   END IF;
END;


-----------------------------------------------------------------------
-- PROCEDURE
--   load_loc_areas
-- PURPOSE
--   Construct the hierarchy record from location areas
-- NOTES
-----------------------------------------------------------------------
PROCEDURE load_loc_areas
IS

   l_hier_rec  loc_hierarchy_rec_type;
   l_area_rec  loc_area_rec_type;
   l_area_id   NUMBER;
   l_area_code VARCHAR2(30);
   l_type_code VARCHAR2(30);
   l_parent_id NUMBER;
   l_post_id   NUMBER;

   CURSOR c_loc_areas IS
   SELECT area.location_area_id,
          area.location_area_code,
          area.location_type_code,
          area.parent_location_area_id,
          area.request_id,
          area.program_application_id,
          area.program_id,
          area.program_update_date,
          area.start_date_active,
          area.end_date_active,
          postal.location_postal_code_id
     FROM jtf_loc_areas_vl area, jtf_loc_postal_codes postal
     WHERE area.location_area_id = postal.location_area_id (+);

   CURSOR c_parent_area IS
   SELECT location_area_id,
          location_area_code,
          location_type_code,
          parent_location_area_id
     FROM jtf_loc_areas_vl
    WHERE location_area_id = l_parent_id;

   CURSOR c_postal_codes IS
   SELECT location_postal_code_id
     FROM jtf_loc_postal_codes
    WHERE location_area_id = l_area_id;

BEGIN

   FOR l_area_rec IN c_loc_areas LOOP
      l_hier_rec := NULL;
      l_area_id := l_area_rec.location_area_id;
      l_area_code := l_area_rec.location_area_code;
      l_type_code := l_area_rec.location_type_code;
      l_parent_id := l_area_rec.parent_location_area_id;
      l_post_id   := l_area_rec.location_postal_code_id;

      -- this loop will construct the hierarchy record for this area
      LOOP
         IF l_type_code = 'AREA1' THEN
            l_hier_rec.area1_id := l_area_id;
            l_hier_rec.area1_code := l_area_code;
         ELSIF l_type_code = 'AREA2' THEN
            l_hier_rec.area2_id := l_area_id;
            l_hier_rec.area2_code := l_area_code;
         ELSIF l_type_code = 'COUNTRY' THEN
            l_hier_rec.country_id := l_area_id;
            l_hier_rec.country_code := l_area_code;
         ELSIF l_type_code = 'CREGION' THEN
            l_hier_rec.country_region_id := l_area_id;
            l_hier_rec.country_region_code := l_area_code;
         ELSIF l_type_code = 'STATE' THEN
            l_hier_rec.state_id := l_area_id;
            l_hier_rec.state_code := l_area_code;
         ELSIF l_type_code = 'SREGION' THEN
            l_hier_rec.state_region_id := l_area_id;
            l_hier_rec.state_region_code := l_area_code;
         ELSIF l_type_code = 'CITY' THEN
            l_hier_rec.city_id := l_area_id;
            l_hier_rec.city_code := l_area_code;
         ELSIF l_type_code = 'POSTAL_CODE' THEN
            l_hier_rec.city_id := l_parent_id;
            l_hier_rec.postal_code_id := l_post_id;

            /*
            l_hier_rec.location_type_code := 'POSTAL_CODE';
            OPEN c_postal_codes;
            LOOP
            FETCH c_postal_codes INTO l_post_id;
            EXIT WHEN c_postal_codes%NOTFOUND;
              l_hier_rec.city_id := l_parent_id;
              l_hier_rec.city_code := l_area_code;
              l_hier_rec.postal_code_id := l_post_id;
              --l_hier_rec.city_code := l_area_code;
              load_hierarchy(l_area_rec, l_hier_rec);
            END LOOP;
         CLOSE c_postal_codes;
         */
         END IF;

         EXIT WHEN l_parent_id IS NULL;

         OPEN c_parent_area;
         FETCH c_parent_area INTO l_area_id, l_area_code, l_type_code, l_parent_id;
         IF c_parent_area%NOTFOUND THEN
            CLOSE c_parent_area;
            EXIT;
         END IF;
         CLOSE c_parent_area;
      END LOOP;

      -- insert or update jtf_loc_hierarchies_b table
      l_hier_rec.location_type_code := l_area_rec.location_type_code;
      load_hierarchy(l_area_rec, l_hier_rec);

      -- if this area is a city, load all postal codes
      /*
      IF l_type_code = 'POSTAL_CODE' THEN
         l_hier_rec.location_type_code := 'POSTAL_CODE';
         OPEN c_postal_codes;
         LOOP
         FETCH c_postal_codes INTO l_post_id;
         EXIT WHEN c_postal_codes%NOTFOUND;
            l_hier_rec.postal_code_id := l_post_id;
            load_hierarchy(l_area_rec, l_hier_rec);
         END LOOP;
         CLOSE c_postal_codes;
      END IF;
      */
   END LOOP;
END;


-- Start of Comments
--
-- NAME
--   Load_Locations
--
-- PURPOSE
--   This procedure is created to as a concurrent program wrapper which
--   will call the Load_Loc_Areas and will return errors if any
--
-- NOTES
--
--
-- HISTORY
--   05/03/1999      ptendulk    created
-- End of Comments

PROCEDURE Load_Locations
          (errbuf        OUT NOCOPY /* file.sql.39 change */    VARCHAR2,
           retcode       OUT NOCOPY /* file.sql.39 change */    NUMBER)
IS
BEGIN
-- Call the procedure to refresh the Market Segment

Load_Loc_Areas;

retcode :=0;

EXCEPTION
   WHEN OTHERS THEN
       retcode := 1 ;
END Load_Locations ;

END JTF_Loc_PVT;

/
