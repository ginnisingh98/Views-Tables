--------------------------------------------------------
--  DDL for Package Body AHL_LTP_SPACE_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_SPACE_SCHEDULE_PVT" AS
/* $Header: AHLVSPSB.pls 120.2 2006/05/25 09:51:23 anraj noship $ */
--
G_PKG_NAME  VARCHAR2(30)  := 'AHL_LTP_SPACE_SCHEDULE_PVT';
G_DEBUG     VARCHAR2(1)   := AHL_DEBUG_PUB.is_log_enabled;
--
--
-- PACKAGE
--    AHL_LTP_SPACE_SCHEDULE_PVT
--
-- PURPOSE
--    This package is a Private API for assigning Spaces to a visit information in
--    Advanced Services Online.  It contains specification for pl/sql records and tables
--
--
--
-- NOTES
--
--
--
-- HISTORY
-- 02-May-2002    ssurapan      Created.
--
-- Ref cursor
TYPE search_visits_csr is REF CURSOR;
-- Search query tbl
TYPE search_query_tbl IS TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
--
PROCEDURE OPEN_FOR_CURSOR(p_x_ref_csr          IN OUT NOCOPY search_visits_csr,
                          p_search_query_tbl   IN            search_query_tbl,
                          p_sql_str            IN            VARCHAR2)
 IS
BEGIN
  --
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'Inside open for cursor');
   END IF;

  IF p_search_query_tbl.COUNT = 0 THEN
    OPEN p_x_ref_csr FOR p_sql_str;
  ELSIF p_search_query_tbl.COUNT = 1 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1);
  ELSIF p_search_query_tbl.COUNT = 2 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1),
                                   p_search_query_tbl(2);
  ELSIF p_search_query_tbl.COUNT = 3 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1),
                                   p_search_query_tbl(2),
                                   p_search_query_tbl(3);
  ELSIF p_search_query_tbl.COUNT = 4 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1),
                                   p_search_query_tbl(2),
                                   p_search_query_tbl(3),
                                   p_search_query_tbl(4);
  ELSIF p_search_query_tbl.COUNT = 5 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1),
                                   p_search_query_tbl(2),
                                   p_search_query_tbl(3),
                                   p_search_query_tbl(4),
                                   p_search_query_tbl(5);
  ELSIF p_search_query_tbl.COUNT = 6 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1),
                                   p_search_query_tbl(2),
                                   p_search_query_tbl(3),
                                   p_search_query_tbl(4),
                                   p_search_query_tbl(5),
                                   p_search_query_tbl(6);
  ELSIF p_search_query_tbl.COUNT = 7 THEN
    OPEN p_x_ref_csr FOR p_sql_str USING p_search_query_tbl(1),
                                   p_search_query_tbl(2),
                                   p_search_query_tbl(3),
                                   p_search_query_tbl(4),
                                   p_search_query_tbl(5),
                                   p_search_query_tbl(6),
                                   p_search_query_tbl(7);

  ELSE
    null;
  END IF;
  --
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of open for cursor');
   END IF;
 --
END OPEN_FOR_CURSOR;
-- To get number of visits for Days
FUNCTION Get_number_of_Visits
         (p_plan_id   NUMBER,
          p_plan_flag VARCHAR2,
          p_space_id  NUMBER,
          p_start_date DATE)

RETURN NUMBER IS

-- To get primary plan visits
CURSOR number_of_prim_visits_cur (c_plan_id    IN NUMBER,
                                  c_space_id   IN NUMBER,
                                  c_visit_id   IN NUMBER,
                                  c_start_period  IN DATE,
                                  c_visit_end_date IN DATE)
IS
SELECT count(*)
FROM ahl_space_assignments a,
     ahl_visits_b b
WHERE a.visit_id  = c_visit_id
AND	a.visit_id = b.visit_id
AND	b.simulation_plan_id = c_plan_id
AND	a.space_id = c_space_id
AND	trunc(c_start_period) between trunc(b.start_date_time) and trunc(c_visit_end_date)
-- anraj: Consider only visits which are not simulation deleted
AND	NVL(SIMULATION_DELETE_FLAG,'N') = 'N';

-- To get simulation visits and primary visits not associated simulated plan
CURSOR number_of_sim_visits_cur
                      (c_plan_id        IN NUMBER,
                       c_space_id       IN NUMBER,
                       c_visit_id       IN NUMBER,
                       c_start_period   IN DATE,
                       c_visit_end_date IN DATE)
IS
SELECT count(*)
FROM ahl_space_assignments a,
     ahl_visits_b b
WHERE a.visit_id  = c_visit_id
AND a.visit_id = b.visit_id
AND  a.space_id = c_space_id
AND  simulation_plan_id IN (select simulation_plan_id FROM ahl_simulation_plans_vl
      WHERE primary_plan_flag = 'Y')
AND  b.visit_id NOT IN (select asso_primary_visit_id from ahl_visits_b
        WHERE simulation_plan_id = c_plan_id )
AND trunc(c_start_period) between trunc(b.start_date_time) and trunc(c_visit_end_date);

--
CURSOR get_visit_cur (c_space_id   IN NUMBER)
IS
SELECT A.visit_id,start_date_time,
      trunc(b.close_date_time) close_date_time
FROM ahl_space_assignments a,
          ahl_visits_b B
WHERE a.visit_id = B.visit_id
AND  a.space_id = c_space_id
-- anraj:Do not consider visits which are deleted or cancelled
AND status_code NOT IN('DELETED','CANCELLED');
  --
  l_visit_id      NUMBER;
  l_count         NUMBER := 0;
  l_return_status VARCHAR2(1);
  l_dummy         NUMBER := 0;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_start_date    DATE := TRUNC(p_start_date);
  l_visit_end_date        DATE;
  l_visit_close_date      DATE;
  l_space_assignment_id   NUMBER;
  l_visit_start_date      DATE;
  l_found            BOOLEAN := FALSE;
  l_ctr              NUMBER:=0;
BEGIN
    --
    OPEN get_visit_cur(p_space_id);
    LOOP
    FETCH get_visit_cur INTO l_visit_id,l_visit_start_date,l_visit_close_date;
    EXIT WHEN get_visit_cur%NOTFOUND;
     --Assign when close date time exists
	 IF l_visit_close_date IS NOT NULL THEN
	    l_visit_end_date := l_visit_close_date;
	 END IF;
	 --
    IF p_plan_flag = 'Y' THEN
    --
    OPEN number_of_prim_visits_cur(p_plan_id, p_space_id,l_visit_id,l_start_date,
                              TRUNC(NVL(l_visit_end_date,l_visit_start_date)));
    FETCH number_of_prim_visits_cur INTO l_count;
    CLOSE number_of_prim_visits_cur;

    ELSE
    --
    IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( 'afetr simul:'||l_count);
    END IF;
    -- simulation visits
    OPEN number_of_prim_visits_cur(p_plan_id, p_space_id,l_visit_id,l_start_date,
                              TRUNC(NVL(l_visit_end_date,l_visit_start_date)));
    FETCH number_of_prim_visits_cur INTO l_dummy;
    CLOSE number_of_prim_visits_cur;

    -- primary visits
    OPEN number_of_sim_visits_cur(p_plan_id, p_space_id,l_visit_id,l_start_date,
                              TRUNC(NVL(l_visit_end_date,l_visit_start_date)));
    FETCH number_of_sim_visits_cur INTO l_count;
    CLOSE number_of_sim_visits_cur;

    IF G_DEBUG='Y' THEN
      Ahl_Debug_Pub.debug( 'INSIDE COUNT 3:'||l_count);
    END IF;
    --
    END IF;
        l_ctr:=l_ctr+l_count+l_dummy;

	END LOOP;
    CLOSE get_visit_cur;

      RETURN l_ctr;

END Get_number_of_Visits;

-- To get the visits assigned at department level for Days
FUNCTION Get_assigned_dept_Visits
         (p_plan_id   NUMBER,
          p_plan_flag VARCHAR2,
          p_department_id  NUMBER,
          p_start_date DATE)

RETURN NUMBER IS

-- To get primary plan visits
-- This cursor is opened for both visits in the Primary as well as Non_Primary Simulation Plans
-- If we are calling this incase of a Primary Visit , this will always return 1
-- If we are calling this incase of a Non Primary Simulated Visit
-- Will return 0 for the corresponding  primary visit, as simulation_plan_id will not be equal to the c_plan_id
-- Will return 0 for a visit which does not have a simulated visit
-- Will return 1 for the Simulation visit
CURSOR number_of_prim_visits_cur
                            (	c_plan_id        IN NUMBER,
										c_visit_id       IN NUMBER,
										c_start_period   IN DATE,
										c_visit_end_date IN DATE,
										c_dept_id        IN NUMBER)
IS
SELECT count(*)
FROM ahl_visits_b
WHERE visit_id  = c_visit_id
AND simulation_plan_id = c_plan_id
AND department_id = c_dept_id
AND trunc(c_start_period) between trunc(start_date_time) and trunc(c_visit_end_date)
-- anraj: Consider only visits which are not simulation deleted
AND NVL(SIMULATION_DELETE_FLAG,'N') = 'N';

-- To get simulation visits and primary visits not associated simulated plan
-- This is called for only Non Primary Simulation plans
-- Will return 1 for the visits which does not have a corresponding visit in this Simulation plan
-- Will retun 0 for all other cases
CURSOR number_of_sim_visits_cur
              (c_plan_id        IN NUMBER,
		       c_visit_id       IN NUMBER,
		       c_start_period   IN DATE,
		       c_visit_end_date IN DATE)
IS
SELECT count(*)
FROM ahl_visits_b
WHERE visit_id  = c_visit_id
AND  simulation_plan_id IN (select simulation_plan_id FROM ahl_simulation_plans_vl
      WHERE primary_plan_flag = 'Y')
AND  visit_id NOT IN (select asso_primary_visit_id from ahl_visits_b
        WHERE simulation_plan_id = c_plan_id )
AND trunc(c_start_period) between trunc(start_date_time) and trunc(c_visit_end_date);

--Get all the visits assigned to department (with or without space assignment)
CURSOR get_visit_cur (c_dept_id    IN NUMBER)
    IS
SELECT visit_id,TRUNC(start_date_time),
       TRUNC(close_date_time)
from ahl_visits_vl
WHERE department_id = c_dept_id
AND start_date_time IS NOT NULL
-- anraj:Do not consider visits which are deleted or cancelled
AND status_code NOT IN('DELETED','CANCELLED');

  --
  l_visit_id      NUMBER;
  l_count         NUMBER := 0;
  l_return_status VARCHAR2(1);
  l_dummy         NUMBER := 0;
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(2000);
  l_start_date    DATE := TRUNC(p_start_date);
  l_visit_end_date        DATE;
  l_visit_close_date      DATE;
  l_space_assignment_id   NUMBER;
  l_visit_start_date      DATE;
  l_found            BOOLEAN := FALSE;
  l_ctr              NUMBER:=0;
BEGIN
	--
   OPEN get_visit_cur(p_department_id);
   LOOP
		FETCH get_visit_cur INTO l_visit_id,l_visit_start_date,l_visit_close_date;
		EXIT WHEN get_visit_cur%NOTFOUND;
		--Assign when close date time exists
		IF l_visit_close_date IS NOT NULL THEN
			l_visit_end_date := l_visit_close_date;
      ELSE
			l_visit_end_date := l_visit_start_date;
		END IF;

		IF p_plan_flag = 'Y' THEN
		--
			IF G_DEBUG='Y' THEN
				Ahl_Debug_Pub.debug( 'after plan flag visit id :'||l_visit_id);
				Ahl_Debug_Pub.debug( 'after plan flag start date:'||l_start_date);
				Ahl_Debug_Pub.debug( 'after plan flag visit start date:'||l_visit_start_date);
				Ahl_Debug_Pub.debug( 'after plan flag visit end date:'||l_visit_end_date);
			END IF;
		--
			OPEN number_of_prim_visits_cur(p_plan_id, l_visit_id,l_start_date,
                              TRUNC(NVL(l_visit_end_date,l_visit_start_date)),p_department_id);
			FETCH number_of_prim_visits_cur INTO l_count;
			CLOSE number_of_prim_visits_cur;
			Ahl_Debug_Pub.debug( 'after primary :'||l_count);
		ELSE
		--
			IF G_DEBUG='Y' THEN
				Ahl_Debug_Pub.debug( 'afetr simul:'||l_visit_id);
			END IF;
			-- simulation visits
			OPEN number_of_prim_visits_cur(p_plan_id, l_visit_id,l_start_date,
                               TRUNC(NVL(l_visit_end_date,l_visit_start_date)),p_department_id);
			FETCH number_of_prim_visits_cur INTO l_dummy;
			CLOSE number_of_prim_visits_cur;
			-- primary visits
			OPEN number_of_sim_visits_cur(p_plan_id, l_visit_id,l_start_date,
                              TRUNC(NVL(l_visit_end_date,l_visit_start_date)));
			FETCH number_of_sim_visits_cur INTO l_count;
			CLOSE number_of_sim_visits_cur;

			IF G_DEBUG='Y' THEN
				Ahl_Debug_Pub.debug( 'INSIDE COUNT 3:'||l_count);
			END IF;
			--
		END IF;
      l_ctr:=l_ctr+l_count+l_dummy;
	END LOOP;
   CLOSE get_visit_cur;

	IF G_DEBUG='Y' THEN
		Ahl_Debug_Pub.debug( 'l_ctr:'||l_ctr);
   END IF;
   RETURN l_ctr;
END Get_assigned_dept_Visits;
--

FUNCTION Get_Number_of_Dvisits
         (p_dept_id   NUMBER,
          p_plan_id    NUMBER,
          p_plan_flag  VARCHAR2,
          p_start_date DATE,
          p_end_date   DATE)

RETURN NUMBER IS
-- To get primary plan visits only
CURSOR number_of_prim_visits_cur (	c_visit_id   IN NUMBER,
												c_start_date IN DATE,
												c_end_date   IN DATE,
												c_visit_end_date IN DATE,
												c_plan_id    IN NUMBER)
IS
SELECT COUNT(*)
FROM ahl_visits_b
WHERE  visit_id           = c_visit_id
AND  simulation_plan_id = c_plan_id
AND (	(	(TRUNC(start_date_time) BETWEEN trunc(c_start_date)  AND trunc(c_end_date))
OR (trunc(c_visit_end_date) BETWEEN trunc(c_start_date) AND trunc(c_end_date)))
OR ((c_start_date between trunc(start_date_time) and trunc(c_visit_end_date) )
OR trunc(c_end_date) between trunc(start_date_time) and trunc(c_visit_end_date)))
-- anraj: Consider only visits which are not simulation deleted
AND NVL(SIMULATION_DELETE_FLAG,'N') = 'N';
--
CURSOR get_visit_cur (c_dept_id    IN NUMBER)
IS
SELECT visit_id,TRUNC(start_date_time),TRUNC(close_date_time)
FROM ahl_visits_vl
WHERE department_id = c_dept_id
AND start_date_time IS NOT NULL
-- anraj:Do not consider visits which are deleted or cancelled
AND status_code NOT IN('DELETED','CANCELLED');

-- To get simulation plan visits and primary visits not associated to simulation
-- plan
CURSOR number_of_sim_visits_cur ( c_visit_id   IN NUMBER,
                                  c_start_date IN DATE,
                                  c_end_date   IN DATE,
                                  c_visit_end_date IN DATE,
                                  c_plan_id    IN NUMBER)
IS
SELECT COUNT(*)
FROM ahl_visits_b
WHERE  visit_id           = c_visit_id
AND  simulation_plan_id in (select simulation_plan_id from ahl_simulation_plans_vl where primary_plan_flag = 'Y')
AND  visit_id NOT IN (select asso_primary_visit_id from ahl_visits_b WHERE simulation_plan_id = c_plan_id )
AND (	(	(TRUNC(start_date_time) BETWEEN trunc(c_start_date)  AND trunc(c_end_date))
OR (trunc(c_visit_end_date) BETWEEN trunc(c_start_date) AND trunc(c_end_date)))
OR ((c_start_date between trunc(start_date_time) and trunc(c_visit_end_date) )
OR trunc(c_end_date) between trunc(start_date_time) and trunc(c_visit_end_date)));
  --
  l_return_status    VARCHAR2(1);
  l_dummy            NUMBER := 0;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_count            NUMBER;
  l_visit_id         NUMBER;
  l_visit_start_date DATE;
  l_start_date       DATE := TRUNC(p_start_date)+1;
  l_end_date         DATE := TRUNC(p_end_date);
  l_visit_end_date   DATE;
  l_visit_close_date DATE;
  l_simulation_plan_id  NUMBER;
  l_plan_flag           VARCHAR2(1);
  l_ctr                 NUMBER:=0;
BEGIN
    --
    OPEN get_visit_cur(p_dept_id);
    LOOP
    FETCH get_visit_cur INTO l_visit_id,l_visit_start_date,l_visit_close_date;
    EXIT WHEN get_visit_cur%NOTFOUND;
    --
    IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( 'plan id:'||p_plan_id);
       Ahl_Debug_Pub.debug( 'visit id:'||l_visit_id);
    END IF;
     --Assign when close date time exists
	 IF l_visit_close_date IS NOT NULL THEN
	    l_visit_end_date := l_visit_close_date;
		ELSE
	    l_visit_end_date := l_visit_start_date;
	 END IF;

     IF p_plan_flag = 'Y' THEN
       OPEN number_of_prim_visits_cur(l_visit_id,
                                      l_start_date,
                                      l_end_date,
                                      TRUNC(NVL(l_visit_end_date,l_visit_start_date)),
                                      p_plan_id);
       FETCH number_of_prim_visits_cur INTO l_count;
       IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug( 'ROWCOUNT 2:'||number_of_prim_visits_cur%ROWCOUNT);
  	   END IF;
       CLOSE number_of_prim_visits_cur;
       --
     ELSE
      -- simulated visits
      OPEN number_of_sim_visits_cur(l_visit_id,
                                    l_start_date,
                                    l_end_date,
                                    TRUNC(NVL(l_visit_end_date,l_visit_start_date)),
                                    p_plan_id);
      FETCH number_of_sim_visits_cur INTO l_count;
      IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug( 'ROWCOUNT 2:'||number_of_sim_visits_cur%ROWCOUNT);
      END IF;
      --
      CLOSE number_of_sim_visits_cur;
      -- Primary visits
      OPEN number_of_prim_visits_cur(l_visit_id,
                                     l_start_date,
                                     l_end_date,
                                     TRUNC(NVL(l_visit_end_date,l_visit_start_date)),
                                     p_plan_id);
      FETCH number_of_prim_visits_cur INTO l_dummy;
      --
      IF G_DEBUG='Y' THEN
         Ahl_Debug_Pub.debug( 'ROWCOUNT 2:'||number_of_prim_visits_cur%ROWCOUNT);
	  END IF;
      CLOSE number_of_prim_visits_cur;
     END IF;
        l_ctr:=l_ctr+l_count+l_dummy;
     --
    END LOOP;
    CLOSE get_visit_cur;
    RETURN l_ctr;

END Get_Number_of_Dvisits;
-- To get number of visits
FUNCTION Get_count_of_Visits
         (p_space_id   NUMBER,
          p_plan_id    NUMBER,
          p_plan_flag  VARCHAR2,
          p_start_date DATE,
          p_end_date   DATE)

RETURN NUMBER IS
-- To get primary plan visits only
CURSOR number_of_prim_visits_cur (c_visit_id   IN NUMBER,
                                   c_start_date IN DATE,
                                   c_space_id   IN NUMBER,
                                   c_end_date   IN DATE,
                                   c_visit_end_date IN DATE,
                                   c_plan_id    IN NUMBER)
IS
	SELECT COUNT(*)
	FROM ahl_space_assignments a,ahl_visits_b b
	WHERE  a.visit_id           = c_visit_id
	AND  a.visit_id           = b.visit_id
	AND  b.simulation_plan_id = c_plan_id
	AND  a.space_id           = c_space_id
	AND (((TRUNC(start_date_time) BETWEEN trunc(c_start_date)  AND trunc(c_end_date))
	OR (trunc(c_visit_end_date) BETWEEN trunc(c_start_date) AND trunc(c_end_date)))
	OR ((c_start_date between trunc(start_date_time) and trunc(c_visit_end_date) )
	OR trunc(c_end_date) between trunc(start_date_time) and trunc(c_visit_end_date)))
	-- anraj: Consider only visits which are not simulation deleted
	AND NVL(SIMULATION_DELETE_FLAG,'N') = 'N';
--
CURSOR get_visit_cur (c_space_id IN NUMBER)
IS
	SELECT	A.visit_id,
				start_date_time,
				trunc(b.close_date_time) close_date_time
   FROM ahl_space_assignments a,
          ahl_visits_b B
   WHERE a.visit_id = B.visit_id
   AND  a.space_id = c_space_id
	--anraj:Do not consider visits which are deleted or cancelled
	AND status_code NOT IN('DELETED','CANCELLED');

-- To get simulation plan visits and primary visits not associated to simulation
-- plan
CURSOR number_of_sim_visits_cur (c_visit_id   IN NUMBER,
                                  c_start_date IN DATE,
                                  c_space_id   IN NUMBER,
                                  c_end_date   IN DATE,
                                  c_visit_end_date IN DATE,
                                  c_plan_id    IN NUMBER)
IS
SELECT COUNT(*)
FROM ahl_space_assignments a,ahl_visits_b b
WHERE  a.visit_id           = c_visit_id
AND  a.visit_id           = b.visit_id
AND  b.simulation_plan_id in (select simulation_plan_id
	 from ahl_simulation_plans_vl where primary_plan_flag = 'Y')
AND  b.visit_id NOT IN (select asso_primary_visit_id from ahl_visits_b
     WHERE simulation_plan_id = c_plan_id )
AND  a.space_id           = c_space_id
AND (((TRUNC(start_date_time) BETWEEN trunc(c_start_date)  AND trunc(c_end_date))
OR (trunc(c_visit_end_date) BETWEEN trunc(c_start_date) AND trunc(c_end_date)))
OR ((c_start_date between trunc(start_date_time) and trunc(c_visit_end_date) )
OR trunc(c_end_date) between trunc(start_date_time) and trunc(c_visit_end_date)));

--
  l_return_status    VARCHAR2(1);
  l_dummy            NUMBER := 0;
  l_msg_count        NUMBER;
  l_msg_data         VARCHAR2(2000);
  l_count            NUMBER;
  l_visit_id         NUMBER;
  l_visit_start_date DATE;
  l_start_date       DATE := TRUNC(p_start_date)+1;
  l_end_date         DATE := TRUNC(p_end_date);
  l_visit_end_date   DATE;
  l_visit_close_date DATE;
  l_simulation_plan_id  NUMBER;
  l_plan_flag           VARCHAR2(1);
  l_ctr              NUMBER:=0;
BEGIN
    --
    OPEN get_visit_cur(p_space_id);
    LOOP
    FETCH get_visit_cur INTO l_visit_id,l_visit_start_date,l_visit_close_date;
    EXIT WHEN get_visit_cur%NOTFOUND;
   --
    IF G_DEBUG='Y' THEN
       Ahl_Debug_Pub.debug( 'plan id:'||p_plan_id);
       Ahl_Debug_Pub.debug( 'visit id:'||l_visit_id);
    END IF;
     --Assign when close date time exists
	 IF l_visit_close_date IS NOT NULL THEN
	    l_visit_end_date := l_visit_close_date;
	  ELSE
	    l_visit_end_date := l_visit_start_date;

	 END IF;

  IF p_plan_flag = 'Y' THEN
    OPEN number_of_prim_visits_cur(l_visit_id,
                                   l_start_date,
                                   p_space_id,
                                   l_end_date,
                                   TRUNC(NVL(l_visit_end_date,l_visit_start_date)),
                                   p_plan_id);
    FETCH number_of_prim_visits_cur INTO l_count;
      IF G_DEBUG='Y' THEN
       --
       Ahl_Debug_Pub.debug( 'ROWCOUNT 2:'||number_of_prim_visits_cur%ROWCOUNT);
	   --
	  END IF;
    CLOSE number_of_prim_visits_cur;
    --
   ELSE
    -- simulated visits
    OPEN number_of_sim_visits_cur(l_visit_id,
                                   l_start_date,
                                   p_space_id,
                                   l_end_date,
                                   TRUNC(NVL(l_visit_end_date,l_visit_start_date)),
                                   p_plan_id);
    FETCH number_of_sim_visits_cur INTO l_count;
   IF G_DEBUG='Y' THEN
     --
     Ahl_Debug_Pub.debug( 'ROWCOUNT 2:'||number_of_sim_visits_cur%ROWCOUNT);
   END IF;
   --
    CLOSE number_of_sim_visits_cur;
    -- Primary visits
    OPEN number_of_prim_visits_cur(l_visit_id,
                                   l_start_date,
                                   p_space_id,
                                   l_end_date,
                                   TRUNC(NVL(l_visit_end_date,l_visit_start_date)),
                                   p_plan_id);
    FETCH number_of_prim_visits_cur INTO l_dummy;
     --
     IF G_DEBUG='Y' THEN
       --
       Ahl_Debug_Pub.debug( 'ROWCOUNT 2:'||number_of_prim_visits_cur%ROWCOUNT);
	 END IF;
	 --
    CLOSE number_of_prim_visits_cur;
    --
  END IF;
        l_ctr:=l_ctr+l_count+l_dummy;
     --
    END LOOP;
    CLOSE get_visit_cur;
     RETURN l_ctr;

END Get_count_of_Visits;
-- To Check space Unavailability
FUNCTION Check_Unavilable_Space
         (p_space_id  NUMBER,
          p_start_date DATE,
          p_end_date DATE)

RETURN BOOLEAN IS

 CURSOR space_unavailable_cur (c_space_id   IN NUMBER,
                               c_start_date IN DATE,
                               c_end_date   IN DATE)
 IS
 SELECT space_unavailability_id
  FROM ahl_space_unavailable_b
WHERE space_id = c_space_id
  AND (trunc(start_date) between c_start_date and c_end_date
     or trunc(end_date) between c_start_date and c_end_date);
--
  l_space_unavailability_id         NUMBER;
  l_start_date      DATE := trunc(p_start_date);
  l_end_date        DATE := trunc(p_end_date);
  l_found boolean;
BEGIN

    OPEN space_unavailable_cur(p_space_id,l_start_date,l_end_date);
    LOOP
    FETCH space_unavailable_cur INTO l_space_unavailability_id;
    EXIT WHEN space_unavailable_cur%NOTFOUND;
     IF l_space_unavailability_id IS NOT NULL THEN
       l_found := TRUE;
     ELSE
       l_found := FALSE;
     END IF;
     END LOOP;
     CLOSE space_unavailable_cur;
     RETURN l_found;

END Check_Unavilable_Space;
-- To Convert lookup code to meaning or vice versa
PROCEDURE Check_lookup_name_Or_Id
 ( p_lookup_type      IN FND_LOOKUPS.lookup_type%TYPE,
   p_lookup_code      IN FND_LOOKUPS.lookup_code%TYPE ,
   p_meaning          IN FND_LOOKUPS.meaning%TYPE,
   p_check_id_flag    IN VARCHAR2,
   x_lookup_code      OUT NOCOPY VARCHAR2,
   x_return_status    OUT NOCOPY VARCHAR2)
IS


BEGIN
      IF (p_lookup_code IS NOT NULL) THEN
        IF (p_check_id_flag = 'Y') THEN
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND lookup_code = p_lookup_code
            AND SYSDATE BETWEEN start_date_active
            AND NVL(end_date_active,SYSDATE);
        ELSE
           x_lookup_code := p_lookup_code;
        END IF;
     ELSE
          SELECT lookup_code INTO x_lookup_code
           FROM FND_LOOKUP_VALUES_VL
          WHERE lookup_type = p_lookup_type
            AND meaning     = p_meaning
            AND SYSDATE BETWEEN start_date_active
            AND NVL(end_date_active,SYSDATE);
    END IF;
      x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN TOO_MANY_ROWS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      RAISE;
END;
--
-- To Process Display Perod for Days
PROCEDURE Get_UOM_DAYS (
   p_start_date                  IN          DATE,
   p_org_id                      IN          NUMBER,
   p_simulation_plan_id          IN          NUMBER,
   p_plan_flag                   IN          VARCHAR2,
   p_dept_id                     IN          NUMBER default null,
   p_dept_name                   IN          VARCHAR2 default null,
   p_space_id                    IN          NUMBER default null,
   p_space_name                  IN          VARCHAR2 default null,
   p_space_category              IN          VARCHAR2 default null,
   x_scheduled_visits_tbl        OUT  NOCOPY scheduled_visits_tbl,
   x_display_rec                 OUT  NOCOPY display_rec_type)
   IS
  --
	CURSOR space_un_cur  (c_space_id IN NUMBER,
                        c_date in DATE)
	IS
	SELECT space_id
		FROM AHL_SPACE_UNAVAILABLE_B
   WHERE space_id = c_space_id
   AND trunc(c_date) between trunc(start_date) and trunc(end_date);

	--
	l_sql_string              VARCHAR2(30000);
	l_sql_string1             VARCHAR2(30000);
	--
	l_dummy                    NUMBER;
	l_count                    NUMBER;
	l_found                    BOOLEAN;
	l_date                     varchar2(10);
	l_start_date               DATE := trunc(p_start_date);
	l_end_date                 DATE;
	l_space_id                 NUMBER;
	l_visit_type_code          VARCHAR2(30);
	l_inventory_item_id        NUMBER;
	l_idx                      NUMBER;
	--
	l_org_id      number;
	l_department_id        NUMBER;
	l_space_name     VARCHAR2(80);
	l_space_category   VARCHAR2(30);
	l_meaning          VARCHAR2(80);
	l_description          VARCHAR2(240);
	l_dept_code            VARCHAR2(10);
	l_org_name             VARCHAR2(240);

	--
	l_dept_cur       search_visits_csr;
	l_bind_idx       NUMBER := 1;
	l_bind_index     NUMBER := 1;
	l_space_cur      search_visits_csr;
	-- Table of bind variables.
	l_tempbind_tbl  search_query_tbl;
	l_temp_tbl      search_query_tbl;
	--

	BEGIN
	--
		--SELECT Clause
		l_sql_string := 'select distinct(a.department_id),b.description, b.department_code,c.name';
		-- From Clause
		l_sql_string := l_sql_string || ' from ahl_visits_vl a , bom_departments b, hr_all_organization_units c';
   -- Where Clause
   l_sql_string := l_sql_string || ' where visit_id not in (select visit_id from ahl_space_assignments)';
   l_sql_string := l_sql_string || ' and a.department_id = b.department_id';
   l_sql_string := l_sql_string || ' and a.organization_id = c.organization_id';
   l_sql_string := l_sql_string || ' and a.department_id is not null';
   l_sql_string := l_sql_string || ' and a.start_date_time is not null';
   -- Org id is not null
   IF p_org_id IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and a.organization_id = :ORG_ID';
   l_tempbind_tbl(l_bind_idx) := p_org_id;
   l_bind_idx := l_bind_idx + 1;

   END IF;

   -- Dept id is not null
   IF p_dept_name IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(b.description) like upper(:D' || l_bind_idx || ')';
   l_tempbind_tbl(l_bind_idx) := p_dept_name;
   l_bind_idx := l_bind_idx + 1;

   END IF;
   -- space category is not null
   IF p_space_category IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(a.space_category_code) like :SPACE_CATEGORY';
   l_tempbind_tbl(l_bind_idx) := p_space_category;
   l_bind_idx := l_bind_idx + 1;
   END IF;

	--anraj: for getting departments which do not have visits assigned to it
	-- this is needs to be done only if the user has not specified a category code
	IF p_space_category IS NULL THEN
		l_sql_string := l_sql_string || ' UNION  select	b.department_id, b.description, b.department_code, c.name ' ;
		l_sql_string := l_sql_string || ' FROM	  bom_departments b, hr_all_organization_units c, mtl_parameters m ' ;
		l_sql_string := l_sql_string || ' WHERE  b.organization_id = c.organization_id ';
		l_sql_string := l_sql_string || ' AND    m.organization_id = c.organization_id  ';
		l_sql_string := l_sql_string || ' AND	  b.description is not null ';
		l_sql_string := l_sql_string || ' AND    m.eam_enabled_flag = ''Y'' ';

		-- Dept id is not null
		IF p_dept_name IS NOT NULL THEN
			l_sql_string := l_sql_string || ' and upper(b.description) like upper(:D' || l_bind_idx || ')';
			l_tempbind_tbl(l_bind_idx) := p_dept_name;
			l_bind_idx := l_bind_idx + 1;
		END IF;

		IF p_org_id IS NOT NULL THEN
			l_sql_string := l_sql_string || ' AND    b.organization_id = :ORG_ID';
			l_tempbind_tbl(l_bind_idx) := p_org_id;
			l_bind_idx := l_bind_idx + 1;
		END IF;

		l_sql_string := l_sql_string || ' AND b.department_id NOT  IN' ;
		l_sql_string := l_sql_string || ' ( select unique department_id from ahl_visits_b' ;
		IF p_org_id IS NOT NULL THEN
			l_sql_string := l_sql_string || ' WHERE organization_id = :ORG_ID';
			l_tempbind_tbl(l_bind_idx) := p_org_id;
			l_bind_idx := l_bind_idx + 1;
		END IF;
		l_sql_string := l_sql_string || ' AND department_id IS NOT NULL';
		l_sql_string := l_sql_string || ' AND visit_id NOT IN (SELECT visit_id FROM ahl_space_assignments))';
		l_sql_string := l_sql_string || ' and 	exists ( SELECT ''x'' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = B.DEPARTMENT_ID) ' ;
END IF;


   --
  AHL_DEBUG_PUB.debug( 'l_sql_string:'||l_sql_string);
  AHL_DEBUG_PUB.debug( 'p_org_id:'||p_org_id);
  AHL_DEBUG_PUB.debug( 'p_dept_name:'||p_dept_name);
  --Space info

   --SELECT Clause
   l_sql_string1 := ' SELECT distinct(a.space_id), space_name, space_category, meaning,';
   l_sql_string1 := l_sql_string1 || ' a.bom_department_id, department_code, d.description,';
   l_sql_string1 := l_sql_string1 || ' a.organization_id, e.name org_name ';
   -- From Clause
   l_sql_string1 := l_sql_string1 || ' from ahl_spaces_vl a , ahl_space_assignments b, fnd_lookup_values_vl c,';
   l_sql_string1 := l_sql_string1 || ' bom_departments d, hr_all_organization_units e ';
   -- Where Clause
   l_sql_string1 := l_sql_string1 || ' where c.lookup_type(+)   = ''AHL_LTP_SPACE_CATEGORY''';
   l_sql_string1 := l_sql_string1 || ' and c.lookup_code(+)    = a.space_category';
   l_sql_string1 := l_sql_string1 || ' and a.bom_department_id = d.department_id';
   l_sql_string1 := l_sql_string1 || ' and a.space_id = b.space_id(+)';
   l_sql_string1 := l_sql_string1 || ' and a.organization_id   = d.organization_id';
   l_sql_string1 := l_sql_string1 || ' and a.organization_id   = e.organization_id';

   -- Org id is not null
   IF p_org_id IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and a.organization_id = :ORG_ID';
   l_temp_tbl(l_bind_index) := p_org_id;
   l_bind_index := l_bind_index + 1;

   END IF;

   -- Dept Name is not null
   IF p_dept_name IS NOT NULL THEN
		l_sql_string1 := l_sql_string1 || ' and upper(d.description) like upper(:D' || l_bind_index || ')';
		l_temp_tbl(l_bind_index) := p_dept_name;
		l_bind_index := l_bind_index + 1;
   END IF;


   -- Space Name is not null
   IF p_space_name IS NOT NULL THEN
		l_sql_string1 := l_sql_string1 || ' and upper(a.space_name) like upper (:S' || l_bind_index || ')';
		l_temp_tbl(l_bind_index) := p_space_name;
		l_bind_index := l_bind_index + 1;
   END IF;

   -- Space Category is not null
   IF p_space_category IS NOT NULL THEN
		l_sql_string1 := l_sql_string1 || ' and a.space_category = :SPACE_CATEGORY';
		l_temp_tbl(l_bind_index) := p_space_category;
		l_bind_index := l_bind_index + 1;
   END IF;



  --
  AHL_DEBUG_PUB.debug( 'l_sql_string1:'||l_sql_string1);
  AHL_DEBUG_PUB.debug( 'p_org_id:'||p_org_id);
  AHL_DEBUG_PUB.debug( 'p_space_category:'||p_space_category);
  AHL_DEBUG_PUB.debug( 'p_dept_name:'||p_dept_name);
  -- Department details
  OPEN_FOR_CURSOR(p_x_ref_csr => l_dept_cur,
                  p_search_query_tbl => l_tempbind_tbl,
                  p_sql_str => l_sql_string);
   --
   l_idx := 0;
   LOOP
    FETCH l_dept_cur INTO l_department_id, l_description, l_dept_code, l_org_name;
    EXIT WHEN l_dept_cur%NOTFOUND;

    IF (l_department_id IS NOT NULL  AND p_space_name IS NULL )THEN
      --
        IF l_start_date IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
		--
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date);

         AHL_DEBUG_PUB.debug( 'l_count:'||l_count);

         IF l_count = 1 THEN
         x_scheduled_visits_tbl(l_idx).value_1 := 'S';
         ELSIF l_count > 1 THEN
         x_scheduled_visits_tbl(l_idx).value_1 := 'M';
         ELSE
         x_scheduled_visits_tbl(l_idx).value_1 := 'A';
         END IF;
         x_display_rec.field_1                            := to_char( l_start_date ,'dd/mm');
         x_display_rec.start_period_1                     :=   l_start_date;
         x_display_rec.end_period_1                       :=   l_start_date;
         END IF;
          IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'space ID:'||x_scheduled_visits_tbl(l_idx).space_id);
          AHL_DEBUG_PUB.debug( 'value 1:'||x_scheduled_visits_tbl(l_idx).value_1);
          --
          END IF;
          --
          IF l_start_date+1 IS NOT NULL THEN
          --Initialize count value
          l_count := 0;
          AHL_DEBUG_PUB.debug( 'before count 2:'||l_count);
          --
          l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                               p_plan_flag,
			    							   l_department_id,
											   l_start_date+1);

          IF G_DEBUG='Y' THEN
          --
          AHL_DEBUG_PUB.debug( 'count 2:'||l_count);
	      --
          END IF;
          IF l_count = 1 THEN
          x_scheduled_visits_tbl(l_idx).value_2 := 'S';
          ELSIF l_count > 1 THEN
          x_scheduled_visits_tbl(l_idx).value_2 := 'M';
          ELSE
          x_scheduled_visits_tbl(l_idx).value_2 := 'A';
          END IF;
          x_display_rec.field_2                            := to_char( l_start_date + 1 ,'dd/mm');
          x_display_rec.start_period_2                     := l_start_date + 1;
          x_display_rec.end_period_2                       := l_start_date + 1;
          END IF;
          --
          IF l_start_date+2 IS NOT NULL THEN
          --Initialize count value
          l_count := 0;
          --
          l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                               p_plan_flag,
											   l_department_id,
											   l_start_date+2);

          IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug( 'count 3:'||l_count);
          END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_3 := 'A';
          END IF;
           x_display_rec.field_3                            := to_char( l_start_date + 2 ,'dd/mm');
           x_display_rec.start_period_3                     := l_start_date + 2;
           x_display_rec.end_period_3                       := l_start_date + 2;
          END IF;
         --
         IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'value 3:'||x_scheduled_visits_tbl(l_idx).value_3);
         END IF;
         --
         IF l_start_date+3 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
        AHL_DEBUG_PUB.debug( 'before count 4:'||l_count);
        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+3);


        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'count 4:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_4 := 'A';
          END IF;
           x_display_rec.field_4                            := to_char( l_start_date + 3 ,'dd/mm');
           x_display_rec.start_period_4                     := l_start_date + 3;
           x_display_rec.end_period_4                       := l_start_date + 3;
       END IF;
       --
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'value 4:'||x_scheduled_visits_tbl(l_idx).value_4);
       END IF;
       --
        IF l_start_date+4 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;

        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+4);

          IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'count 5:'||l_count);
          END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_5 := 'A';
          END IF;
           x_display_rec.field_5                            := to_char( l_start_date + 4 ,'dd/mm');
           x_display_rec.start_period_5                     := l_start_date + 4;
           x_display_rec.end_period_5                       := l_start_date + 4;
       END IF;
       --
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'value 5:'||x_scheduled_visits_tbl(l_idx).value_5);
       END IF;
       --
        IF l_start_date+5 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+5);

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'count 6:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_6 := 'A';
          END IF;
           x_display_rec.field_6                            := to_char( l_start_date + 5 ,'dd/mm');
           x_display_rec.start_period_6                     := l_start_date + 5;
           x_display_rec.end_period_6                       := l_start_date + 5;
       END IF;
       --
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'value 6:'||x_scheduled_visits_tbl(l_idx).value_6);
       END IF;
	   --
        IF l_start_date+6 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+6);

       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'count 7:'||l_count);
       END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_7 := 'A';
          END IF;
           x_display_rec.field_7                            := to_char( l_start_date + 6 ,'dd/mm');
           x_display_rec.start_period_7                     := l_start_date + 6;
           x_display_rec.end_period_7                       := l_start_date + 6;
       END IF;
       --
       IF G_DEBUG='Y' THEN
         AHL_DEBUG_PUB.debug( 'value 7:'||x_scheduled_visits_tbl(l_idx).value_7);
       END IF;
       --
        IF l_start_date+7 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+7);

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'count 8:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_8 := 'A';
          END IF;
           x_display_rec.field_8                            := to_char( l_start_date + 7 ,'dd/mm');
           x_display_rec.start_period_8                     := l_start_date + 7;
           x_display_rec.end_period_8                       := l_start_date + 7;
       END IF;
       --
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'value 8:'||x_scheduled_visits_tbl(l_idx).value_8);
       END IF;
       --
        IF l_start_date+8 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+8);


        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'count 9:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_9 := 'A';
          END IF;
           x_display_rec.field_9                            := to_char( l_start_date + 8 ,'dd/mm');
           x_display_rec.start_period_9                     := l_start_date + 8;
           x_display_rec.end_period_9                       := l_start_date + 8;
       END IF;
       --
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'value 9:'||x_scheduled_visits_tbl(l_idx).value_9);
       END IF;
       --
        IF l_start_date+9 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
		--
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+9);

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'count 10:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_10 := 'A';
          END IF;
           x_display_rec.field_10                           := to_char( l_start_date + 9 ,'dd/mm');
           x_display_rec.start_period_10                    := l_start_date + 9;
           x_display_rec.end_period_10                      := l_start_date + 9;
          END IF;
          --
          IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug( 'value 10:'||x_scheduled_visits_tbl(l_idx).value_10);
          END IF;
          --
          IF l_start_date+10 IS NOT NULL THEN
          --Initialize count value
          l_count := 0;
          --
          l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                               p_plan_flag,
											   l_department_id,
											   l_start_date+10);

         IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'count 11:'||l_count);
         END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_11 := 'A';
          END IF;
           x_display_rec.field_11                           := to_char( l_start_date + 10 ,'dd/mm');
           x_display_rec.start_period_11                    := l_start_date + 10;
           x_display_rec.end_period_11                      := l_start_date + 10;
          END IF;
          --
          IF G_DEBUG='Y' THEN
             AHL_DEBUG_PUB.debug( 'value 11:'||x_scheduled_visits_tbl(l_idx).value_11);
          END IF;
         --
         IF l_start_date+11 IS NOT NULL THEN
         --Initialize count value
         l_count := 0;
         --
         l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                              p_plan_flag,
											  l_department_id,
											  l_start_date+11);

         IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'count 12:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_12 := 'A';
          END IF;
           x_display_rec.field_12                           := to_char( l_start_date + 11 ,'dd/mm');
           x_display_rec.start_period_12                    := l_start_date + 11;
           x_display_rec.end_period_12                      := l_start_date + 11;
       END IF;
       --
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'value 12:'||x_scheduled_visits_tbl(l_idx).value_12);
       END IF;
       --
        IF l_start_date+12 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;
        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+12);

        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'count 13:'||l_count);
        END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_13 := 'A';
          END IF;
           x_display_rec.field_13                           := to_char( l_start_date + 12 ,'dd/mm');
           x_display_rec.start_period_13                    := l_start_date + 12;
           x_display_rec.end_period_13                      := l_start_date + 12;
       END IF;
       --
       IF G_DEBUG='Y' THEN
          AHL_DEBUG_PUB.debug( 'value 13:'||x_scheduled_visits_tbl(l_idx).value_13);
       END IF;
       --
        IF l_start_date+13 IS NOT NULL THEN
        --Initialize count value
        l_count := 0;

        --
        l_count :=  Get_assigned_dept_Visits(p_simulation_plan_id,
                                             p_plan_flag,
											 l_department_id,
											 l_start_date+13);

         IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.debug( 'count 14:'||l_count);
         END IF;

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'M';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_14 := 'A';
          END IF;
           x_display_rec.field_14                           := to_char( l_start_date + 13 ,'dd/mm');
           x_display_rec.start_period_14                    := l_start_date + 13;
           x_display_rec.end_period_14                      := l_start_date + 13;
       END IF;
       --
        IF G_DEBUG='Y' THEN
           AHL_DEBUG_PUB.debug( 'value 14:'||x_scheduled_visits_tbl(l_idx).value_14);
        END IF;
           x_scheduled_visits_tbl(l_idx).space_id            := null;
           x_scheduled_visits_tbl(l_idx).space_name          := null;
           x_scheduled_visits_tbl(l_idx).department_code     := l_dept_code;
           x_scheduled_visits_tbl(l_idx).department_name     := l_description;
           x_scheduled_visits_tbl(l_idx).department_id       := l_department_id;
           x_scheduled_visits_tbl(l_idx).space_category_mean := null;
           x_scheduled_visits_tbl(l_idx).Space_Category      := null;
           x_scheduled_visits_tbl(l_idx).org_name            := l_org_name;
           x_display_rec.start_period                    := l_start_date;
           x_display_rec.end_period                      := x_display_rec.end_period_14;
       --
       l_idx := l_idx + 1;
       END IF; --Dept id

    END LOOP;
    CLOSE l_dept_cur;
  -- Space info

  OPEN_FOR_CURSOR(p_x_ref_csr => l_space_cur,
                  p_search_query_tbl => l_temp_tbl,
                  p_sql_str => l_sql_string1);
    --
    LOOP
    FETCH l_space_cur INTO l_space_id, l_space_name , l_space_category,
	                       l_meaning, l_department_id,l_dept_code, l_description,
						   l_org_id, l_org_name;
    EXIT WHEN l_space_cur%NOTFOUND;
     --
  	 IF  l_space_id IS NOT NULL THEN
        IF l_start_date IS NOT NULL THEN
        --
		--Check for space capabilities
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                             p_plan_flag,l_space_id,l_start_date);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_1 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_1                            := to_char( l_start_date ,'dd/mm');
           x_display_rec.start_period_1                     := l_start_date;
           x_display_rec.end_period_1                       := l_start_date;
       END IF;
   IF G_DEBUG='Y' THEN
   --
   AHL_DEBUG_PUB.debug( 'space ID:'||x_scheduled_visits_tbl(l_idx).space_id);
   AHL_DEBUG_PUB.debug( 'value 1:'||x_scheduled_visits_tbl(l_idx).value_1);
   --
   END IF;
       --
        IF l_start_date+1 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                                  p_plan_flag,l_space_id,l_start_date+1);
   IF G_DEBUG='Y' THEN
    --
    AHL_DEBUG_PUB.debug( 'count 2:'||l_count);
	--
   END IF;
          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+1);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_2 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_2                            := to_char( l_start_date + 1 ,'dd/mm');
           x_display_rec.start_period_2                     := l_start_date + 1;
           x_display_rec.end_period_2                       := l_start_date + 1;
       END IF;
       --
   IF G_DEBUG='Y' THEN
     --
     AHL_DEBUG_PUB.debug( 'value 2:'||x_scheduled_visits_tbl(l_idx).value_2);
	 --
   END IF;
       --
        IF l_start_date+2 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                             p_plan_flag,l_space_id,l_start_date+2);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+2);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_3 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_3                            := to_char( l_start_date + 2 ,'dd/mm');
           x_display_rec.start_period_3                     := l_start_date + 2;
           x_display_rec.end_period_3                       := l_start_date + 2;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 3:'||x_scheduled_visits_tbl(l_idx).value_3);
   END IF;
       --
        IF l_start_date+3 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                       p_plan_flag,l_space_id,l_start_date+3);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+3);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_4 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_4                            := to_char( l_start_date + 3 ,'dd/mm');
           x_display_rec.start_period_4                     := l_start_date + 3;
           x_display_rec.end_period_4                       := l_start_date + 3;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 4:'||x_scheduled_visits_tbl(l_idx).value_4);
   END IF;
       --
        IF l_start_date+4 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                                   p_plan_flag,l_space_id,l_start_date+4);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+4);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_5 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_5                            := to_char( l_start_date + 4 ,'dd/mm');
           x_display_rec.start_period_5                     := l_start_date + 4;
           x_display_rec.end_period_5                       := l_start_date + 4;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 5:'||x_scheduled_visits_tbl(l_idx).value_5);
   END IF;
       --
        IF l_start_date+5 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                                    p_plan_flag,l_space_id,l_start_date+5);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+5);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_6 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_6                            := to_char( l_start_date + 5 ,'dd/mm');
           x_display_rec.start_period_6                     := l_start_date + 5;
           x_display_rec.end_period_6                       := l_start_date + 5;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 6:'||x_scheduled_visits_tbl(l_idx).value_6);
    END IF;
	   --
        IF l_start_date+6 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                                     p_plan_flag,l_space_id,l_start_date+6);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+6);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_7 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_7                            := to_char( l_start_date + 6 ,'dd/mm');
           x_display_rec.start_period_7                     := l_start_date + 6;
           x_display_rec.end_period_7                       := l_start_date + 6;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      --
      AHL_DEBUG_PUB.debug( 'value 7:'||x_scheduled_visits_tbl(l_idx).value_7);
	  --
   END IF;
       --
        IF l_start_date+7 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                                  p_plan_flag,l_space_id,l_start_date+7);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+7);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_8 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_8                            := to_char( l_start_date + 7 ,'dd/mm');
           x_display_rec.start_period_8                     := l_start_date + 7;
           x_display_rec.end_period_8                       := l_start_date + 7;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 8:'||x_scheduled_visits_tbl(l_idx).value_8);
   END IF;
       --
        IF l_start_date+8 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                              p_plan_flag,l_space_id,l_start_date+8);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+8);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_9 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_9                            := to_char( l_start_date + 8 ,'dd/mm');
           x_display_rec.start_period_9                     := l_start_date + 8;
           x_display_rec.end_period_9                       := l_start_date + 8;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 9:'||x_scheduled_visits_tbl(l_idx).value_9);
   END IF;
       --
        IF l_start_date+9 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                              p_plan_flag,l_space_id,l_start_date+9);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+9);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_10 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_10                           := to_char( l_start_date + 9 ,'dd/mm');
           x_display_rec.start_period_10                    := l_start_date + 9;
           x_display_rec.end_period_10                      := l_start_date + 9;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 10:'||x_scheduled_visits_tbl(l_idx).value_10);
   END IF;
       --
        IF l_start_date+10 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                             p_plan_flag,l_space_id,l_start_date+10);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+10);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_11 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_11                           := to_char( l_start_date + 10 ,'dd/mm');
           x_display_rec.start_period_11                    := l_start_date + 10;
           x_display_rec.end_period_11                      := l_start_date + 10;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 11:'||x_scheduled_visits_tbl(l_idx).value_11);
   END IF;
       --
        IF l_start_date+11 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                            p_plan_flag,l_space_id,l_start_date+11);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+11);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_12 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_12                           := to_char( l_start_date + 11 ,'dd/mm');
           x_display_rec.start_period_12                    := l_start_date + 11;
           x_display_rec.end_period_12                      := l_start_date + 11;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 12:'||x_scheduled_visits_tbl(l_idx).value_12);
   END IF;
       --
        IF l_start_date+12 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                                     p_plan_flag,l_space_id,l_start_date+12);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+12);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_13 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_13                           := to_char( l_start_date + 12 ,'dd/mm');
           x_display_rec.start_period_13                    := l_start_date + 12;
           x_display_rec.end_period_13                      := l_start_date + 12;
       END IF;
       --
   IF G_DEBUG='Y' THEN
       AHL_DEBUG_PUB.debug( 'value 13:'||x_scheduled_visits_tbl(l_idx).value_13);
   END IF;
       --
        IF l_start_date+13 IS NOT NULL THEN
        --
        l_count :=  Get_number_of_Visits(p_simulation_plan_id,
                           p_plan_flag, l_space_id,l_start_date+13);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'M';
          ELSIF l_count = 0 THEN
           OPEN space_un_cur(l_space_id,l_start_date+13);
           FETCH space_un_cur INTO l_dummy;
           IF space_un_cur%FOUND THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'U';
           ELSE
           x_scheduled_visits_tbl(l_idx).value_14 := 'A';
           END IF;
           CLOSE space_un_cur;
          END IF;
           x_display_rec.field_14                           := to_char( l_start_date + 13 ,'dd/mm');
           x_display_rec.start_period_14                    := l_start_date + 13;
           x_display_rec.end_period_14                      := l_start_date + 13;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 14:'||x_scheduled_visits_tbl(l_idx).value_14);
   END IF;
       --
       x_scheduled_visits_tbl(l_idx).space_id            := l_space_id;
       x_scheduled_visits_tbl(l_idx).space_name          := l_space_name;
       x_scheduled_visits_tbl(l_idx).department_code     := l_dept_code;
       x_scheduled_visits_tbl(l_idx).department_name     := l_description;
       x_scheduled_visits_tbl(l_idx).department_id       := l_department_id;
       x_scheduled_visits_tbl(l_idx).space_category_mean := l_meaning;
       x_scheduled_visits_tbl(l_idx).Space_Category      := l_space_category;
       x_scheduled_visits_tbl(l_idx).org_name            := l_org_name;
       x_display_rec.start_period                    := l_start_date;
       x_display_rec.end_period                      := x_display_rec.end_period_14;

       --
       l_idx := l_idx + 1;
       END IF; --Space id

    END LOOP;
    CLOSE l_space_cur;
 --

END Get_UOM_DAYS;
--
PROCEDURE Get_UOM_WEEKS (
   p_start_date                  IN          DATE,
   p_org_id                      IN          NUMBER,
   p_simulation_plan_id          IN          NUMBER,
   p_plan_flag                   IN          VARCHAR2,
   p_dept_id                     IN          NUMBER default null,
   p_dept_name                   IN          VARCHAR2 default null,
   p_space_id                    IN          NUMBER default null,
   p_space_name                  IN          VARCHAR2 default null,
   p_space_category              IN          VARCHAR2 default null,
   x_scheduled_visits_tbl        OUT  NOCOPY scheduled_visits_tbl,
   x_display_rec                 OUT  NOCOPY display_rec_type)
   IS
  --
  l_sql_string              VARCHAR2(30000);
  l_sql_string1             VARCHAR2(30000);
  --
  l_dummy                    NUMBER;
  l_count                    NUMBER;
  l_found                    BOOLEAN;
  l_date                     varchar2(10);
  l_start_date               DATE := trunc(p_start_date);
  l_end_date                 DATE;
  l_space_id                 NUMBER;
  l_visit_type_code          VARCHAR2(30);
  l_inventory_item_id        NUMBER;
  l_idx                      NUMBER;
  --
  l_org_id      number;
  l_department_id        NUMBER;
  l_space_name     VARCHAR2(80);
  l_space_category   VARCHAR2(30);
  l_meaning          VARCHAR2(80);
  l_description          VARCHAR2(240);
  l_dept_code            VARCHAR2(10);
  l_org_name             VARCHAR2(240);

  --
  l_dept_cur       search_visits_csr;
  l_bind_idx       NUMBER := 1;
  l_bind_index     NUMBER := 1;
  l_space_cur      search_visits_csr;
  -- Table of bind variables.
  l_tempbind_tbl  search_query_tbl;
  l_temp_tbl      search_query_tbl;
  --

 BEGIN
  --

   --SELECT Clause
   l_sql_string := 'select distinct(a.department_id),b.description, b.department_code,c.name';
   -- From Clause
   l_sql_string := l_sql_string || ' from ahl_visits_vl a , bom_departments b, hr_all_organization_units c';
   -- Where Clause
   l_sql_string := l_sql_string || ' where visit_id not in (select visit_id from ahl_space_assignments)';
   l_sql_string := l_sql_string || ' and a.department_id = b.department_id';
   l_sql_string := l_sql_string || ' and a.organization_id = c.organization_id';
   l_sql_string := l_sql_string || ' and a.department_id is not null';
   l_sql_string := l_sql_string || ' and a.start_date_time is not null';
   -- Org id is not null
   IF p_org_id IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and a.organization_id = :ORG_ID';
   l_tempbind_tbl(l_bind_idx) := p_org_id;
   l_bind_idx := l_bind_idx + 1;

   END IF;

   -- Dept id is not null
   IF p_dept_name IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(b.description) like upper(:D' || l_bind_idx || ')';
   l_tempbind_tbl(l_bind_idx) := p_dept_name;
   l_bind_idx := l_bind_idx + 1;

   END IF;
   -- space category is not null
   IF p_space_category IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(a.space_category_code) like :SPACE_CATEGORY';
   l_tempbind_tbl(l_bind_idx) := p_space_category;
   l_bind_idx := l_bind_idx + 1;
   END IF;

	--anraj: for getting departments which do not have visits assigned to it
	-- Needs to be done only if the user has not specified a category code in the search
	IF p_space_category IS NULL THEN
		l_sql_string := l_sql_string || ' UNION  select	b.department_id, b.description, b.department_code, c.name ' ;
		l_sql_string := l_sql_string || ' FROM	  bom_departments b, hr_all_organization_units c, mtl_parameters m ' ;
		l_sql_string := l_sql_string || ' WHERE  b.organization_id = c.organization_id ';
		l_sql_string := l_sql_string || ' AND    m.organization_id = c.organization_id  ';
		l_sql_string := l_sql_string || ' AND	  b.description is not null ';
		l_sql_string := l_sql_string || ' AND    m.eam_enabled_flag = ''Y'' ';

		IF p_org_id IS NOT NULL THEN
			l_sql_string := l_sql_string || ' AND    b.organization_id = :ORG_ID';
			l_tempbind_tbl(l_bind_idx) := p_org_id;
			l_bind_idx := l_bind_idx + 1;
		END IF;

		-- Dept id is not null
	   IF p_dept_name IS NOT NULL THEN
			l_sql_string := l_sql_string || ' and upper(b.description) like upper(:D' || l_bind_idx || ')';
			l_tempbind_tbl(l_bind_idx) := p_dept_name;
			l_bind_idx := l_bind_idx + 1;
		END IF;


		l_sql_string := l_sql_string || ' AND b.department_id NOT  IN' ;
		l_sql_string := l_sql_string || ' ( select unique department_id from ahl_visits_b' ;
		IF p_org_id IS NOT NULL THEN
			l_sql_string := l_sql_string || ' WHERE organization_id = :ORG_ID';
			l_tempbind_tbl(l_bind_idx) := p_org_id;
			l_bind_idx := l_bind_idx + 1;
		END IF;
		l_sql_string := l_sql_string || ' AND department_id IS NOT NULL';
		l_sql_string := l_sql_string || ' AND visit_id NOT IN (SELECT visit_id FROM ahl_space_assignments))';
		l_sql_string := l_sql_string || ' and 	exists ( SELECT ''x'' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = B.DEPARTMENT_ID) ' ;
	END IF; -- category code null


   --
  AHL_DEBUG_PUB.debug( 'l_sql_string:'||l_sql_string);
  AHL_DEBUG_PUB.debug( 'p_org_id:'||p_org_id);
  AHL_DEBUG_PUB.debug( 'p_dept_name:'||p_dept_name);
  --Space info

   --SELECT Clause
   l_sql_string1 := ' SELECT distinct(a.space_id), space_name, space_category, meaning,';
   l_sql_string1 := l_sql_string1 || ' a.bom_department_id, department_code, d.description,';
   l_sql_string1 := l_sql_string1 || ' a.organization_id, e.name org_name ';
   -- From Clause
   l_sql_string1 := l_sql_string1 || ' from ahl_spaces_vl a , ahl_space_assignments b, fnd_lookup_values_vl c,';
   l_sql_string1 := l_sql_string1 || ' bom_departments d, hr_all_organization_units e ';
   -- Where Clause
   l_sql_string1 := l_sql_string1 || ' where c.lookup_type(+)   = ''AHL_LTP_SPACE_CATEGORY''';
   l_sql_string1 := l_sql_string1 || ' and c.lookup_code(+)    = a.space_category';
   l_sql_string1 := l_sql_string1 || ' and a.bom_department_id = d.department_id';
   l_sql_string1 := l_sql_string1 || ' and a.space_id = b.space_id(+)';
   l_sql_string1 := l_sql_string1 || ' and a.organization_id   = d.organization_id';
   l_sql_string1 := l_sql_string1 || ' and a.organization_id   = e.organization_id';

   -- Org id is not null
   IF p_org_id IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and a.organization_id = :ORG_ID';
   l_temp_tbl(l_bind_index) := p_org_id;
   l_bind_index := l_bind_index + 1;

   END IF;

   -- Dept Name is not null
   IF p_dept_name IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and upper(d.description) like upper(:D' || l_bind_index || ')';
   l_temp_tbl(l_bind_index) := p_dept_name;
   l_bind_index := l_bind_index + 1;

   END IF;


   -- Space Name is not null
   IF p_space_name IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and upper(a.space_name) like upper (:S' || l_bind_index || ')';
   l_temp_tbl(l_bind_index) := p_space_name;
   l_bind_index := l_bind_index + 1;

   END IF;

   -- Space Category is not null
   IF p_space_category IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and a.space_category = :SPACE_CATEGORY';
   l_temp_tbl(l_bind_index) := p_space_category;
   l_bind_index := l_bind_index + 1;

   END IF;

  AHL_DEBUG_PUB.debug( 'l_sql_string1:'||l_sql_string1);

  -- Department details
  OPEN_FOR_CURSOR(p_x_ref_csr => l_dept_cur,
                  p_search_query_tbl => l_tempbind_tbl,
                  p_sql_str => l_sql_string);
   --
   l_idx := 0;
   LOOP
    FETCH l_dept_cur INTO l_department_id, l_description, l_dept_code, l_org_name;
    EXIT WHEN l_dept_cur%NOTFOUND;
    --
    IF (l_department_id IS NOT NULL  AND p_space_name IS NULL )THEN
      --
        IF l_start_date IS NOT NULL THEN
            x_display_rec.start_period_1 := l_start_date-1;
            x_display_rec.end_period_1 := x_display_rec.start_period_1 + 7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_1,
                                          x_display_rec.end_period_1);
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'count W1:'||l_count);
   END IF;
          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'M';
          ELSE
            x_scheduled_visits_tbl(l_idx).value_1 := 'A';
           END IF;
           x_display_rec.field_1                            := to_char( l_start_date ,'dd/mm');
           x_display_rec.start_period_1                     := x_display_rec.start_period_1;
           x_display_rec.end_period_1                       := x_display_rec.end_period_1;
       END IF;

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'SPACE ID:'||x_scheduled_visits_tbl(l_idx).space_id);
      AHL_DEBUG_PUB.debug( 'value 1:'||x_scheduled_visits_tbl(l_idx).value_1);
    END IF;
       --
        IF x_display_rec.end_period_1 IS NOT NULL THEN
            x_display_rec.start_period_2 := x_display_rec.end_period_1;
            x_display_rec.end_period_2 := x_display_rec.start_period_2 + 7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_2,
                                          x_display_rec.end_period_2);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_2 := 'A';
          END IF;
           x_display_rec.field_2                            := to_char( x_display_rec.start_period_2 + 1  ,'dd/mm');
           x_display_rec.start_period_2                     := x_display_rec.start_period_2;
           x_display_rec.end_period_2                       := x_display_rec.end_period_2;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 2:'||x_scheduled_visits_tbl(l_idx).value_2);
   END IF;
       --
        IF x_display_rec.end_period_2 IS NOT NULL THEN
            x_display_rec.start_period_3 := x_display_rec.end_period_2;
            x_display_rec.end_period_3 := x_display_rec.start_period_3 + 7;
        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_3,
                                          x_display_rec.end_period_3);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_3 := 'A';
          END IF;
           x_display_rec.field_3                            := to_char( x_display_rec.start_period_3+1 ,'dd/mm');
           x_display_rec.start_period_3                     := x_display_rec.start_period_3;
           x_display_rec.end_period_3                       := x_display_rec.end_period_3;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 3:'||x_scheduled_visits_tbl(l_idx).value_3);
   END IF;
      --
        IF x_display_rec.end_period_3 IS NOT NULL THEN
            x_display_rec.start_period_4 := x_display_rec.end_period_3;
            x_display_rec.end_period_4 := x_display_rec.start_period_4+7;
        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_4,
                                          x_display_rec.end_period_4);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_4 := 'A';
          END IF;
           x_display_rec.field_4                            := to_char( x_display_rec.start_period_4+1 ,'dd/mm');
           x_display_rec.start_period_4                     := x_display_rec.start_period_4;
           x_display_rec.end_period_4                       := x_display_rec.end_period_4;
       END IF;
      --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 4:'||x_scheduled_visits_tbl(l_idx).value_4);
   END IF;
      --
        IF x_display_rec.end_period_4 IS NOT NULL THEN
            x_display_rec.start_period_5 := x_display_rec.end_period_4;
            x_display_rec.end_period_5  := x_display_rec.start_period_5+7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_5,
                                          x_display_rec.end_period_5);



          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_5 := 'A';
          END IF;
           x_display_rec.field_5                            := to_char( x_display_rec.start_period_5 + 1,'dd/mm');
           x_display_rec.start_period_5                     := x_display_rec.start_period_5;
           x_display_rec.end_period_5                       := x_display_rec.end_period_5;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 5:'||x_scheduled_visits_tbl(l_idx).value_5);
   END IF;
       --
        IF x_display_rec.end_period_5 IS NOT NULL THEN
            x_display_rec.start_period_6 := x_display_rec.end_period_5;
            x_display_rec.end_period_6 := x_display_rec.start_period_6+7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_6,
                                          x_display_rec.end_period_6);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_6 := 'A';
           END IF;
           x_display_rec.field_6                            := to_char( x_display_rec.start_period_6 + 1,'dd/mm');
           x_display_rec.start_period_6                     := x_display_rec.start_period_6;
           x_display_rec.end_period_6                       := x_display_rec.end_period_6;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 6:'||x_scheduled_visits_tbl(l_idx).value_6);
   END IF;
       --
        IF x_display_rec.end_period_6 IS NOT NULL THEN
           x_display_rec.start_period_7 := x_display_rec.end_period_6;
           x_display_rec.end_period_7 := x_display_rec.start_period_7 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_7,
                                          x_display_rec.end_period_7);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_7 := 'A';
           END IF;
           x_display_rec.field_7                            := to_char( x_display_rec.start_period_7 + 1,'dd/mm');
           x_display_rec.start_period_7                     := x_display_rec.start_period_7;
           x_display_rec.end_period_7                       := x_display_rec.end_period_7;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 7:'||x_scheduled_visits_tbl(l_idx).value_7);
   END IF;
       --
        IF x_display_rec.end_period_7 IS NOT NULL THEN
           x_display_rec.start_period_8 := x_display_rec.end_period_7;
           x_display_rec.end_period_8 := x_display_rec.start_period_8+7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_8,
                                          x_display_rec.end_period_8);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_8 := 'A';
          END IF;
           x_display_rec.field_8                            := to_char( x_display_rec.start_period_8 + 1,'dd/mm');
           x_display_rec.start_period_8                     := x_display_rec.start_period_8;
           x_display_rec.end_period_8                       := x_display_rec.end_period_8;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 8:'||x_scheduled_visits_tbl(l_idx).value_8);
   END IF;
       --
        IF x_display_rec.end_period_8 IS NOT NULL THEN
           x_display_rec.start_period_9 := x_display_rec.end_period_8;
           x_display_rec.end_period_9 := x_display_rec.start_period_9 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_9,
                                          x_display_rec.end_period_9);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_9 := 'A';
          END IF;
           x_display_rec.field_9                            := to_char( x_display_rec.start_period_9 + 1 ,'dd/mm');
           x_display_rec.start_period_9                     := x_display_rec.start_period_9;
           x_display_rec.end_period_9                       := x_display_rec.end_period_9;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 9:'||x_scheduled_visits_tbl(l_idx).value_9);
   END IF;
       --
        IF x_display_rec.end_period_9 IS NOT NULL THEN
           x_display_rec.start_period_10 := x_display_rec.end_period_9;
           x_display_rec.end_period_10 := x_display_rec.start_period_10 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_10,
                                          x_display_rec.end_period_10);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'M';
          ELSE
            x_scheduled_visits_tbl(l_idx).value_10 := 'A';
          END IF;
           x_display_rec.field_10                           := to_char( x_display_rec.start_period_10 + 1,'dd/mm');
           x_display_rec.start_period_10                    := x_display_rec.start_period_10;
           x_display_rec.end_period_10                      := x_display_rec.end_period_10;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 10:'||x_scheduled_visits_tbl(l_idx).value_10);
   END IF;
       --
        IF x_display_rec.end_period_10 IS NOT NULL THEN
           x_display_rec.start_period_11 := x_display_rec.end_period_10;
           x_display_rec.end_period_11 := x_display_rec.start_period_11 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_11,
                                          x_display_rec.end_period_11);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_11 := 'A';
          END IF;
           x_display_rec.field_11                           := to_char( x_display_rec.start_period_11 + 1 ,'dd/mm');
           x_display_rec.start_period_11                    := x_display_rec.start_period_11;
           x_display_rec.end_period_11                      := x_display_rec.end_period_11;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 11:'||x_scheduled_visits_tbl(l_idx).value_11);
   END IF;
       --
        IF x_display_rec.end_period_11 IS NOT NULL THEN
           x_display_rec.start_period_12 := x_display_rec.end_period_11;
           x_display_rec.end_period_12 := x_display_rec.start_period_12 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_12,
                                          x_display_rec.end_period_12);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_12 := 'A';
          END IF;
           x_display_rec.field_12                           := to_char( x_display_rec.start_period_12 + 1,'dd/mm');
           x_display_rec.start_period_12                    := x_display_rec.start_period_12;
           x_display_rec.end_period_12                      := x_display_rec.end_period_12;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 12:'||x_scheduled_visits_tbl(l_idx).value_12);
   END IF;
       --
        IF x_display_rec.end_period_12 IS NOT NULL THEN
           x_display_rec.start_period_13 := x_display_rec.end_period_12;
           x_display_rec.end_period_13 := x_display_rec.start_period_13 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_13,
                                          x_display_rec.end_period_13);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_13 := 'A';
          END IF;
           x_display_rec.field_13                           := to_char( x_display_rec.start_period_13 + 1 ,'dd/mm');
           x_display_rec.start_period_13                    := x_display_rec.start_period_13;
           x_display_rec.end_period_13                      := x_display_rec.end_period_13;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 13:'||x_scheduled_visits_tbl(l_idx).value_13);
   END IF;
       --
        IF x_display_rec.end_period_13 IS NOT NULL THEN
           x_display_rec.start_period_14 := x_display_rec.end_period_13;
           x_display_rec.end_period_14 := x_display_rec.start_period_14 +7;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_14,
                                          x_display_rec.end_period_14);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_14 := 'A';
          END IF;
           x_display_rec.field_14                           := to_char( x_display_rec.start_period_14 + 1 ,'dd/mm');
           x_display_rec.start_period_14                    := x_display_rec.start_period_14;
           x_display_rec.end_period_14                      := x_display_rec.end_period_14;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 14:'||x_scheduled_visits_tbl(l_idx).value_14);
   END IF;
           x_scheduled_visits_tbl(l_idx).space_id            := null;
           x_scheduled_visits_tbl(l_idx).space_name          := null;
           x_scheduled_visits_tbl(l_idx).department_code     := l_dept_code;
           x_scheduled_visits_tbl(l_idx).department_name     := l_description;
           x_scheduled_visits_tbl(l_idx).department_id       := l_department_id;
           x_scheduled_visits_tbl(l_idx).space_category_mean := null;
           x_scheduled_visits_tbl(l_idx).Space_Category      := null;
           x_scheduled_visits_tbl(l_idx).org_name            := l_org_name;
           x_display_rec.start_period                    := l_start_date;
           x_display_rec.end_period                      := x_display_rec.end_period_14;

       --
       l_idx := l_idx + 1;
       END IF;
       --
    END LOOP;
    CLOSE l_dept_cur;

  -- Space info

  OPEN_FOR_CURSOR(p_x_ref_csr => l_space_cur,
                  p_search_query_tbl => l_temp_tbl,
                  p_sql_str => l_sql_string1);
    --
    LOOP
    FETCH l_space_cur INTO l_space_id, l_space_name , l_space_category,
	                       l_meaning, l_department_id,l_dept_code, l_description,
						   l_org_id, l_org_name;
    EXIT WHEN l_space_cur%NOTFOUND;
    --
    IF  l_space_id IS NOT NULL THEN
        IF l_start_date IS NOT NULL THEN
            x_display_rec.start_period_1 := l_start_date-1;
            x_display_rec.end_period_1 := x_display_rec.start_period_1 + 7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_1,
                                        x_display_rec.end_period_1);

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'count W1:'||l_count);
   END IF;
          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_1,
                                       x_display_rec.end_period_1) THEN
               x_scheduled_visits_tbl(l_idx).value_1 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_1 := 'A';
           END IF;
          END IF;
           x_display_rec.field_1                            := to_char( l_start_date ,'dd/mm');
           x_display_rec.start_period_1                     := x_display_rec.start_period_1;
           x_display_rec.end_period_1                       := x_display_rec.end_period_1;
       END IF;

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'SPACE ID:'||x_scheduled_visits_tbl(l_idx).space_id);
      AHL_DEBUG_PUB.debug( 'value 1:'||x_scheduled_visits_tbl(l_idx).value_1);
    END IF;
       --
        IF x_display_rec.end_period_1 IS NOT NULL THEN
            x_display_rec.start_period_2 := x_display_rec.end_period_1;
            x_display_rec.end_period_2 := x_display_rec.start_period_2 + 7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_2,
                                        x_display_rec.end_period_2);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_2,
                                       x_display_rec.end_period_2) THEN
               x_scheduled_visits_tbl(l_idx).value_2 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_2 := 'A';
           END IF;
          END IF;
           x_display_rec.field_2                            := to_char( x_display_rec.start_period_2 + 1  ,'dd/mm');
           x_display_rec.start_period_2                     := x_display_rec.start_period_2;
           x_display_rec.end_period_2                       := x_display_rec.end_period_2;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 2:'||x_scheduled_visits_tbl(l_idx).value_2);
   END IF;
       --
        IF x_display_rec.end_period_2 IS NOT NULL THEN
            x_display_rec.start_period_3 := x_display_rec.end_period_2;
            x_display_rec.end_period_3 := x_display_rec.start_period_3 + 7;
        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_3,
                                        x_display_rec.end_period_3);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_3,
                                       x_display_rec.end_period_3) THEN
               x_scheduled_visits_tbl(l_idx).value_3 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_3 := 'A';
           END IF;
          END IF;
           x_display_rec.field_3                            := to_char( x_display_rec.start_period_3+1 ,'dd/mm');
           x_display_rec.start_period_3                     := x_display_rec.start_period_3;
           x_display_rec.end_period_3                       := x_display_rec.end_period_3;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 3:'||x_scheduled_visits_tbl(l_idx).value_3);
   END IF;
      --
        IF x_display_rec.end_period_3 IS NOT NULL THEN
            x_display_rec.start_period_4 := x_display_rec.end_period_3;
            x_display_rec.end_period_4 := x_display_rec.start_period_4+7;
        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_4,
                                        x_display_rec.end_period_4);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_4,
                                       x_display_rec.end_period_4) THEN
               x_scheduled_visits_tbl(l_idx).value_4 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_4 := 'A';
           END IF;
          END IF;
           x_display_rec.field_4                            := to_char( x_display_rec.start_period_4+1 ,'dd/mm');
           x_display_rec.start_period_4                     := x_display_rec.start_period_4;
           x_display_rec.end_period_4                       := x_display_rec.end_period_4;
       END IF;
      --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 4:'||x_scheduled_visits_tbl(l_idx).value_4);
   END IF;
      --
        IF x_display_rec.end_period_4 IS NOT NULL THEN
            x_display_rec.start_period_5 := x_display_rec.end_period_4;
            x_display_rec.end_period_5  := x_display_rec.start_period_5+7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_5,
                                        x_display_rec.end_period_5);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_5,
                                       x_display_rec.end_period_5) THEN
               x_scheduled_visits_tbl(l_idx).value_5 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_5 := 'A';
           END IF;
          END IF;
           x_display_rec.field_5                            := to_char( x_display_rec.start_period_5 + 1,'dd/mm');
           x_display_rec.start_period_5                     := x_display_rec.start_period_5;
           x_display_rec.end_period_5                       := x_display_rec.end_period_5;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 5:'||x_scheduled_visits_tbl(l_idx).value_5);
   END IF;
       --
        IF x_display_rec.end_period_5 IS NOT NULL THEN
            x_display_rec.start_period_6 := x_display_rec.end_period_5;
            x_display_rec.end_period_6 := x_display_rec.start_period_6+7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_6,
                                        x_display_rec.end_period_6);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_6,
                                       x_display_rec.end_period_6) THEN
               x_scheduled_visits_tbl(l_idx).value_6 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_6 := 'A';
           END IF;
          END IF;
           x_display_rec.field_6                            := to_char( x_display_rec.start_period_6 + 1,'dd/mm');
           x_display_rec.start_period_6                     := x_display_rec.start_period_6;
           x_display_rec.end_period_6                       := x_display_rec.end_period_6;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 6:'||x_scheduled_visits_tbl(l_idx).value_6);
   END IF;
       --
        IF x_display_rec.end_period_6 IS NOT NULL THEN
           x_display_rec.start_period_7 := x_display_rec.end_period_6;
           x_display_rec.end_period_7 := x_display_rec.start_period_7 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_7,
                                        x_display_rec.end_period_7);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_7,
                                       x_display_rec.end_period_7) THEN
               x_scheduled_visits_tbl(l_idx).value_7 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_7 := 'A';
           END IF;
          END IF;
           x_display_rec.field_7                            := to_char( x_display_rec.start_period_7 + 1,'dd/mm');
           x_display_rec.start_period_7                     := x_display_rec.start_period_7;
           x_display_rec.end_period_7                       := x_display_rec.end_period_7;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 7:'||x_scheduled_visits_tbl(l_idx).value_7);
   END IF;
       --
        IF x_display_rec.end_period_7 IS NOT NULL THEN
           x_display_rec.start_period_8 := x_display_rec.end_period_7;
           x_display_rec.end_period_8 := x_display_rec.start_period_8+7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_8,
                                        x_display_rec.end_period_8);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_8,
                                       x_display_rec.end_period_8) THEN
               x_scheduled_visits_tbl(l_idx).value_8 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_8 := 'A';
           END IF;
          END IF;
           x_display_rec.field_8                            := to_char( x_display_rec.start_period_8 + 1,'dd/mm');
           x_display_rec.start_period_8                     := x_display_rec.start_period_8;
           x_display_rec.end_period_8                       := x_display_rec.end_period_8;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 8:'||x_scheduled_visits_tbl(l_idx).value_8);
   END IF;
       --
        IF x_display_rec.end_period_8 IS NOT NULL THEN
           x_display_rec.start_period_9 := x_display_rec.end_period_8;
           x_display_rec.end_period_9 := x_display_rec.start_period_9 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_9,
                                        x_display_rec.end_period_9);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_9,
                                       x_display_rec.end_period_9) THEN
               x_scheduled_visits_tbl(l_idx).value_9 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_9 := 'A';
           END IF;
          END IF;
           x_display_rec.field_9                            := to_char( x_display_rec.start_period_9 + 1 ,'dd/mm');
           x_display_rec.start_period_9                     := x_display_rec.start_period_9;
           x_display_rec.end_period_9                       := x_display_rec.end_period_9;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 9:'||x_scheduled_visits_tbl(l_idx).value_9);
   END IF;
       --
        IF x_display_rec.end_period_9 IS NOT NULL THEN
           x_display_rec.start_period_10 := x_display_rec.end_period_9;
           x_display_rec.end_period_10 := x_display_rec.start_period_10 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_10,
                                        x_display_rec.end_period_10);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_10,
                                       x_display_rec.end_period_10) THEN
               x_scheduled_visits_tbl(l_idx).value_10 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_10 := 'A';
           END IF;
          END IF;
           x_display_rec.field_10                           := to_char( x_display_rec.start_period_10 + 1,'dd/mm');
           x_display_rec.start_period_10                    := x_display_rec.start_period_10;
           x_display_rec.end_period_10                      := x_display_rec.end_period_10;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 10:'||x_scheduled_visits_tbl(l_idx).value_10);
   END IF;
       --
        IF x_display_rec.end_period_10 IS NOT NULL THEN
           x_display_rec.start_period_11 := x_display_rec.end_period_10;
           x_display_rec.end_period_11 := x_display_rec.start_period_11 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_11,
                                        x_display_rec.end_period_11);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_11,
                                       x_display_rec.end_period_11) THEN
               x_scheduled_visits_tbl(l_idx).value_11 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_11 := 'A';
           END IF;
          END IF;
           x_display_rec.field_11                           := to_char( x_display_rec.start_period_11 + 1 ,'dd/mm');
           x_display_rec.start_period_11                    := x_display_rec.start_period_11;
           x_display_rec.end_period_11                      := x_display_rec.end_period_11;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 11:'||x_scheduled_visits_tbl(l_idx).value_11);
   END IF;
       --
        IF x_display_rec.end_period_11 IS NOT NULL THEN
           x_display_rec.start_period_12 := x_display_rec.end_period_11;
           x_display_rec.end_period_12 := x_display_rec.start_period_12 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_12,
                                        x_display_rec.end_period_12);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_12,
                                       x_display_rec.end_period_12) THEN
               x_scheduled_visits_tbl(l_idx).value_12 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_12 := 'A';
           END IF;
          END IF;
           x_display_rec.field_12                           := to_char( x_display_rec.start_period_12 + 1,'dd/mm');
           x_display_rec.start_period_12                    := x_display_rec.start_period_12;
           x_display_rec.end_period_12                      := x_display_rec.end_period_12;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 12:'||x_scheduled_visits_tbl(l_idx).value_12);
   END IF;
       --
        IF x_display_rec.end_period_12 IS NOT NULL THEN
           x_display_rec.start_period_13 := x_display_rec.end_period_12;
           x_display_rec.end_period_13 := x_display_rec.start_period_13 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_13,
                                        x_display_rec.end_period_13);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_13,
                                       x_display_rec.end_period_13) THEN
               x_scheduled_visits_tbl(l_idx).value_13 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_13 := 'A';
           END IF;
          END IF;
           x_display_rec.field_13                           := to_char( x_display_rec.start_period_13 + 1 ,'dd/mm');
           x_display_rec.start_period_13                    := x_display_rec.start_period_13;
           x_display_rec.end_period_13                      := x_display_rec.end_period_13;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 13:'||x_scheduled_visits_tbl(l_idx).value_13);
   END IF;
       --
        IF x_display_rec.end_period_13 IS NOT NULL THEN
           x_display_rec.start_period_14 := x_display_rec.end_period_13;
           x_display_rec.end_period_14 := x_display_rec.start_period_14 +7;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_14,
                                        x_display_rec.end_period_14);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_14,
                                       x_display_rec.end_period_14) THEN
               x_scheduled_visits_tbl(l_idx).value_14 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_14 := 'A';
           END IF;
          END IF;
           x_display_rec.field_14                           := to_char( x_display_rec.start_period_14 + 1 ,'dd/mm');
           x_display_rec.start_period_14                    := x_display_rec.start_period_14;
           x_display_rec.end_period_14                      := x_display_rec.end_period_14;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 14:'||x_scheduled_visits_tbl(l_idx).value_14);
   END IF;
           x_scheduled_visits_tbl(l_idx).space_id            := l_space_id;
           x_scheduled_visits_tbl(l_idx).space_name          := l_space_name;
           x_scheduled_visits_tbl(l_idx).department_code     := l_dept_code;
           x_scheduled_visits_tbl(l_idx).department_name     := l_description;
           x_scheduled_visits_tbl(l_idx).department_id       := l_department_id;
           x_scheduled_visits_tbl(l_idx).space_category_mean := l_meaning;
           x_scheduled_visits_tbl(l_idx).Space_Category      := l_space_category;
           x_scheduled_visits_tbl(l_idx).org_name            := l_org_name;
           x_display_rec.start_period                    := l_start_date;
           x_display_rec.end_period                      := x_display_rec.end_period_14;

       --
       l_idx := l_idx + 1;
       END IF;

    END LOOP;
    CLOSE l_space_cur;
 --

END Get_UOM_WEEKS;
--
PROCEDURE Get_UOM_MONTHS (
   p_start_date                  IN          DATE,
   p_org_id                      IN          NUMBER,
   p_simulation_plan_id          IN          NUMBER,
   p_plan_flag                   IN          VARCHAR2,
   p_dept_id                     IN          NUMBER default null,
   p_dept_name                   IN          VARCHAR2 default null,
   p_space_id                    IN          NUMBER default null,
   p_space_name                  IN          VARCHAR2 default null,
   p_space_category              IN          VARCHAR2 default null,
   x_scheduled_visits_tbl        OUT  NOCOPY scheduled_visits_tbl,
   x_display_rec                 OUT  NOCOPY display_rec_type)
   IS
  --
  l_sql_string              VARCHAR2(30000);
  l_sql_string1             VARCHAR2(30000);
  --
  l_dummy                    NUMBER;
  l_count                    NUMBER;
  l_found                    BOOLEAN;
  l_date                     varchar2(10);
  l_start_date               DATE := trunc(p_start_date);
  l_end_date                 DATE;
  l_space_id                 NUMBER;
  l_visit_type_code          VARCHAR2(30);
  l_inventory_item_id        NUMBER;
  l_idx                      NUMBER;
  --
  l_org_id      NUMBER;
  l_department_id        NUMBER;
  l_space_name     VARCHAR2(80);
  l_space_category   VARCHAR2(30);
  l_meaning          VARCHAR2(80);
  l_description          VARCHAR2(240);
  l_dept_code            VARCHAR2(10);
  l_org_name             VARCHAR2(240);

  --
  l_dept_cur       search_visits_csr;
  l_bind_idx       NUMBER := 1;
  l_bind_index     NUMBER := 1;
  l_space_cur      search_visits_csr;
  -- Table of bind variables.
  l_tempbind_tbl  search_query_tbl;
  l_temp_tbl      search_query_tbl;
  --

 BEGIN
  --

   --SELECT Clause
   l_sql_string := 'select distinct(a.department_id),b.description, b.department_code,c.name';
   -- From Clause
   l_sql_string := l_sql_string || ' from ahl_visits_vl a , bom_departments b, hr_all_organization_units c';
   -- Where Clause
   l_sql_string := l_sql_string || ' where visit_id not in (select visit_id from ahl_space_assignments)';
   l_sql_string := l_sql_string || ' and a.department_id = b.department_id';
   l_sql_string := l_sql_string || ' and a.organization_id = c.organization_id';
   l_sql_string := l_sql_string || ' and a.department_id is not null';
   l_sql_string := l_sql_string || ' and a.start_date_time is not null';
   -- Org id is not null
   IF p_org_id IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and a.organization_id = :ORG_ID';
   l_tempbind_tbl(l_bind_idx) := p_org_id;
   l_bind_idx := l_bind_idx + 1;

   END IF;

   -- Dept Name is not null
   IF p_dept_name IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(b.description) like upper(:D' || l_bind_idx || ')';
   l_tempbind_tbl(l_bind_idx) := p_dept_name;
   l_bind_idx := l_bind_idx + 1;

   END IF;
/*
   -- visit type is not null
   IF p_visit_type IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(a.visit_type_code) like :VISIT_TYPE';
   l_tempbind_tbl(l_bind_idx) := p_visit_type;
   l_bind_idx := l_bind_idx + 1;

   END IF;

   -- item id is not null
   IF p_item_id IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and a.inventory_item_id = :ITEM_ID';
   l_tempbind_tbl(l_bind_idx) := p_item_id;
   l_bind_idx := l_bind_idx + 1;

   END IF;
*/
   -- space category is not null
   IF p_space_category IS NOT NULL THEN
   l_sql_string := l_sql_string || ' and upper(a.space_category_code) like :SPACE_CATEGORY';
   l_tempbind_tbl(l_bind_idx) := p_space_category;
   l_bind_idx := l_bind_idx + 1;
   END IF;
   --
  AHL_DEBUG_PUB.debug( 'l_sql_string:'||l_sql_string);
  AHL_DEBUG_PUB.debug( 'p_org_id:'||p_org_id);
  AHL_DEBUG_PUB.debug( 'p_dept_name:'||p_dept_name);
  --Space info

   --SELECT Clause
   l_sql_string1 := ' SELECT distinct(a.space_id), space_name, space_category, meaning,';
   l_sql_string1 := l_sql_string1 || ' a.bom_department_id, department_code, d.description,';
   l_sql_string1 := l_sql_string1 || ' a.organization_id, e.name org_name ';
   -- From Clause
   l_sql_string1 := l_sql_string1 || ' from ahl_spaces_vl a , ahl_space_assignments b, fnd_lookup_values_vl c,';
   l_sql_string1 := l_sql_string1 || ' bom_departments d, hr_all_organization_units e ';
   -- Where Clause
   l_sql_string1 := l_sql_string1 || ' where c.lookup_type(+)   = ''AHL_LTP_SPACE_CATEGORY''';
   l_sql_string1 := l_sql_string1 || ' and c.lookup_code(+)    = a.space_category';
   l_sql_string1 := l_sql_string1 || ' and a.bom_department_id = d.department_id';
   l_sql_string1 := l_sql_string1 || ' and a.space_id = b.space_id(+)';
   l_sql_string1 := l_sql_string1 || ' and a.organization_id   = d.organization_id';
   l_sql_string1 := l_sql_string1 || ' and a.organization_id   = e.organization_id';

   -- Org id is not null
   IF p_org_id IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and a.organization_id = :ORG_ID';
   l_temp_tbl(l_bind_index) := p_org_id;
   l_bind_index := l_bind_index + 1;

   END IF;

   -- Dept Name is not null
   IF p_dept_name IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and upper(d.description) like upper (:D' || l_bind_index || ')';
   l_temp_tbl(l_bind_index) := p_dept_name;
   l_bind_index := l_bind_index + 1;

   END IF;

   -- Space Name is not null
   IF p_space_name IS NOT NULL THEN
   l_sql_string1 := l_sql_string1 || ' and upper(a.space_name) like upper (:S' || l_bind_index || ')';
   l_temp_tbl(l_bind_index) := p_space_name;
   l_bind_index := l_bind_index + 1;

   END IF;

   -- Space Category is not null
   IF p_space_category IS NOT NULL THEN
		l_sql_string1 := l_sql_string1 || ' and a.space_category = :SPACE_CATEGORY';
		l_temp_tbl(l_bind_index) := p_space_category;
		l_bind_index := l_bind_index + 1;
   END IF;

	--anraj: for getting departments which do not have visits assigned to it
	--done only if the user has not specified category code in the search
	IF p_space_category IS NULL THEN
		l_sql_string := l_sql_string || ' UNION  select	b.department_id, b.description, b.department_code, c.name ' ;
		l_sql_string := l_sql_string || ' FROM	  bom_departments b, hr_all_organization_units c, mtl_parameters m ' ;
		l_sql_string := l_sql_string || ' WHERE  b.organization_id = c.organization_id ';
		l_sql_string := l_sql_string || ' AND    m.organization_id = c.organization_id  ';
		l_sql_string := l_sql_string || ' AND	  b.description is not null ';
		l_sql_string := l_sql_string || ' AND    m.eam_enabled_flag = ''Y'' ';
		IF p_org_id IS NOT NULL THEN
			l_sql_string := l_sql_string || ' AND    b.organization_id = :ORG_ID';
			l_tempbind_tbl(l_bind_idx) := p_org_id;
			l_bind_idx := l_bind_idx + 1;
		END IF;

		-- Dept id is not null
		IF p_dept_name IS NOT NULL THEN
			l_sql_string := l_sql_string || ' and upper(b.description) like upper(:D' || l_bind_idx || ')';
			l_tempbind_tbl(l_bind_idx) := p_dept_name;
			l_bind_idx := l_bind_idx + 1;
		END IF;


		l_sql_string := l_sql_string || ' AND b.department_id NOT  IN' ;
		l_sql_string := l_sql_string || ' ( select unique department_id from ahl_visits_b' ;
		IF p_org_id IS NOT NULL THEN
			l_sql_string := l_sql_string || ' WHERE organization_id = :ORG_ID';
			l_tempbind_tbl(l_bind_idx) := p_org_id;
			l_bind_idx := l_bind_idx + 1;
		END IF;
		l_sql_string := l_sql_string || ' AND department_id IS NOT NULL';
		l_sql_string := l_sql_string || ' AND visit_id NOT IN (SELECT visit_id FROM ahl_space_assignments))';
		l_sql_string := l_sql_string || ' and 	exists ( SELECT ''x'' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = B.DEPARTMENT_ID) ' ;
	END IF;


  AHL_DEBUG_PUB.debug( 'l_sql_string1:'||l_sql_string1);

  -- Department details
  OPEN_FOR_CURSOR(p_x_ref_csr => l_dept_cur,
                  p_search_query_tbl => l_tempbind_tbl,
                  p_sql_str => l_sql_string);
   --
   l_idx := 0;
   LOOP
    FETCH l_dept_cur INTO l_department_id, l_description, l_dept_code, l_org_name;
    EXIT WHEN l_dept_cur%NOTFOUND;
    --
    IF (l_department_id IS NOT NULL  AND p_space_name IS NULL )THEN
      --
        IF l_start_date IS NOT NULL THEN
            x_display_rec.start_period_1 := l_start_date-1;

            SELECT ADD_MONTHS(x_display_rec.start_period_1,1) INTO
            x_display_rec.end_period_1 FROM DUAL;
            --
            l_count :=  Get_Number_of_Dvisits(l_department_id,
                                              p_simulation_plan_id,
                                              p_plan_flag,
                                              x_display_rec.start_period_1,
                                              x_display_rec.end_period_1);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'M';
          ELSE
            x_scheduled_visits_tbl(l_idx).value_1 := 'A';
          END IF;
           x_display_rec.field_1                            := to_char( l_start_date ,'mm/yy');
           x_display_rec.start_period_1                     := x_display_rec.start_period_1;
           x_display_rec.end_period_1                       := x_display_rec.end_period_1;
       END IF;
       --
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'value 1:'||x_display_rec.field_1);
     AHL_DEBUG_PUB.debug( 'start 1:'||x_display_rec.start_period_1);
     AHL_DEBUG_PUB.debug( 'end 1:'||x_display_rec.end_period_1);
   END IF;
       --
        IF x_display_rec.end_period_1 IS NOT NULL THEN
           x_display_rec.start_period_2:= x_display_rec.end_period_1;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_2,1) INTO
            x_display_rec.end_period_2 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_2,
                                          x_display_rec.end_period_2);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_2 := 'A';
          END IF;
           x_display_rec.field_2                           := to_char( x_display_rec.start_period_2 + 1 ,'mm/yy');
           x_display_rec.start_period_2                    := x_display_rec.start_period_2;
           x_display_rec.end_period_2                      := x_display_rec.end_period_2;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 2:'||x_display_rec.field_2);
    AHL_DEBUG_PUB.debug( 'start 2:'||x_display_rec.start_period_2);
    AHL_DEBUG_PUB.debug( 'end 2:'||x_display_rec.end_period_2);
   END IF;
       --
        IF x_display_rec.end_period_2 IS NOT NULL THEN
           x_display_rec.start_period_3:= x_display_rec.end_period_2;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_3,1) INTO
            x_display_rec.end_period_3 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_3,
                                          x_display_rec.end_period_3);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_3 := 'A';
          END IF;
           x_display_rec.field_3                           := to_char( x_display_rec.start_period_3 + 1,'mm/yy');
           x_display_rec.start_period_3                    := x_display_rec.start_period_3;
           x_display_rec.end_period_3                      := x_display_rec.end_period_3;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 3:'||x_display_rec.field_3);
    AHL_DEBUG_PUB.debug( 'start 3:'||x_display_rec.start_period_3);
    AHL_DEBUG_PUB.debug( 'end 3:'||x_display_rec.end_period_3);
   END IF;
       --
        IF x_display_rec.end_period_3 IS NOT NULL THEN
           x_display_rec.start_period_4:= x_display_rec.end_period_3;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_4,1) INTO
            x_display_rec.end_period_4 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                          p_simulation_plan_id,
                                          p_plan_flag,
                                          x_display_rec.start_period_4,
                                          x_display_rec.end_period_4);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'M';
          ELSE
            x_scheduled_visits_tbl(l_idx).value_4 := 'A';
          END IF;
           x_display_rec.field_4                            := to_char( x_display_rec.start_period_4 + 1,'mm/yy');
           x_display_rec.start_period_4                     := x_display_rec.start_period_4;
           x_display_rec.end_period_4                       := x_display_rec.end_period_4;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 4:'||x_display_rec.field_4);
    AHL_DEBUG_PUB.debug( 'start 4:'||x_display_rec.start_period_4);
    AHL_DEBUG_PUB.debug( 'end 4:'||x_display_rec.end_period_4);
   END IF;
       --
        IF x_display_rec.end_period_4 IS NOT NULL THEN
           x_display_rec.start_period_5:= x_display_rec.end_period_4;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_5,1) INTO
            x_display_rec.end_period_5 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_5,
                                        x_display_rec.end_period_5);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_5 := 'A';
          END IF;
           x_display_rec.field_5                            := to_char( x_display_rec.start_period_5 + 1,'mm/yy');
           x_display_rec.start_period_5                     := x_display_rec.start_period_5;
           x_display_rec.end_period_5                       := x_display_rec.end_period_5;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 5:'||x_scheduled_visits_tbl(l_idx).value_5);
   END IF;
       --
        IF x_display_rec.end_period_5 IS NOT NULL THEN
           x_display_rec.start_period_6:= x_display_rec.end_period_5;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_6,1) INTO
            x_display_rec.end_period_6 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_6,
                                        x_display_rec.end_period_6);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_6 := 'A';
          END IF;
           x_display_rec.field_6                            := to_char( x_display_rec.start_period_6 + 1,'mm/yy');
           x_display_rec.start_period_6                     := x_display_rec.start_period_6;
           x_display_rec.end_period_6                       := x_display_rec.end_period_6;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 6:'||x_scheduled_visits_tbl(l_idx).value_6);
   END IF;
       --
            IF x_display_rec.end_period_6 IS NOT NULL THEN
           x_display_rec.start_period_7:= x_display_rec.end_period_6;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_7,1) INTO
            x_display_rec.end_period_7 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_7,
                                        x_display_rec.end_period_7);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_7 := 'A';
          END IF;
           x_display_rec.field_7                            := to_char( x_display_rec.start_period_7 + 1,'mm/yy');
           x_display_rec.start_period_7                     := x_display_rec.start_period_7;
           x_display_rec.end_period_7                       := x_display_rec.end_period_7;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 7:'||x_scheduled_visits_tbl(l_idx).value_7);
   END IF;
       --
        IF x_display_rec.end_period_7 IS NOT NULL THEN
           x_display_rec.start_period_8:= x_display_rec.end_period_7;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_8,1) INTO
            x_display_rec.end_period_8 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_8,
                                        x_display_rec.end_period_8);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_8 := 'A';
          END IF;
           x_display_rec.field_8                            := to_char( x_display_rec.start_period_8 + 1,'mm/yy');
           x_display_rec.start_period_8                     := x_display_rec.start_period_8;
           x_display_rec.end_period_8                       := x_display_rec.end_period_8;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 8:'||x_scheduled_visits_tbl(l_idx).value_8);
   END IF;
       --
        IF x_display_rec.end_period_8 IS NOT NULL THEN
           x_display_rec.start_period_9:= x_display_rec.end_period_8;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_9,1) INTO
            x_display_rec.end_period_9 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_9,
                                        x_display_rec.end_period_9);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_9 := 'A';
          END IF;
           x_display_rec.field_9                            := to_char( x_display_rec.start_period_9 + 1,'mm/yy');
           x_display_rec.start_period_9                     := x_display_rec.start_period_9;
           x_display_rec.end_period_9                       := x_display_rec.end_period_9;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 9:'||x_scheduled_visits_tbl(l_idx).value_9);
   END IF;
       --
        IF x_display_rec.end_period_9 IS NOT NULL THEN
           x_display_rec.start_period_10:= x_display_rec.end_period_9;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_10,1) INTO
            x_display_rec.end_period_10 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_10,
                                        x_display_rec.end_period_10);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'M';
          ELSE
            x_scheduled_visits_tbl(l_idx).value_10 := 'A';
          END IF;
           x_display_rec.field_10                           := to_char( x_display_rec.start_period_10 + 1,'mm/yy');
           x_display_rec.start_period_10                    := x_display_rec.start_period_10;
           x_display_rec.end_period_10                      := x_display_rec.end_period_10;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 10:'||x_scheduled_visits_tbl(l_idx).value_10);
   END IF;
       --
        IF x_display_rec.end_period_10 IS NOT NULL THEN
           x_display_rec.start_period_11:= x_display_rec.end_period_10;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_11,1) INTO
            x_display_rec.end_period_11 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_11,
                                        x_display_rec.end_period_11);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'M';
          ELSE
            x_scheduled_visits_tbl(l_idx).value_11 := 'A';
          END IF;
           x_display_rec.field_11                           := to_char( x_display_rec.start_period_11 + 1,'mm/yy');
           x_display_rec.start_period_11                    := x_display_rec.start_period_11;
           x_display_rec.end_period_11                      := x_display_rec.end_period_11;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 11:'||x_scheduled_visits_tbl(l_idx).value_11);
   END IF;
       --
        IF x_display_rec.end_period_11 IS NOT NULL THEN
           x_display_rec.start_period_12:= x_display_rec.end_period_11;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_12,1) INTO
            x_display_rec.end_period_12 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_12,
                                        x_display_rec.end_period_12);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_12 := 'A';
          END IF;
           x_display_rec.field_12                           := to_char( x_display_rec.start_period_12 + 1,'mm/yy');
           x_display_rec.start_period_12                    := x_display_rec.start_period_12;
           x_display_rec.end_period_12                      := x_display_rec.end_period_12;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 12:'||x_scheduled_visits_tbl(l_idx).value_12);
   END IF;
       --
        IF x_display_rec.end_period_12 IS NOT NULL THEN
           x_display_rec.start_period_13:= x_display_rec.end_period_12;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_13,1) INTO
            x_display_rec.end_period_13 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_13,
                                        x_display_rec.end_period_13);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_13 := 'A';
          END IF;
           x_display_rec.field_13                           := to_char( x_display_rec.start_period_13 + 1,'mm/yy');
           x_display_rec.start_period_13                    := x_display_rec.start_period_13;
           x_display_rec.end_period_13                      := x_display_rec.end_period_13;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 13:'||x_scheduled_visits_tbl(l_idx).value_13);
   END IF;
       --
        IF x_display_rec.end_period_13 IS NOT NULL THEN
           x_display_rec.start_period_14:= x_display_rec.end_period_13;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_14,1) INTO
            x_display_rec.end_period_14 FROM DUAL;

        l_count :=  Get_Number_of_Dvisits(l_department_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_14,
                                        x_display_rec.end_period_14);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'M';
          ELSE
           x_scheduled_visits_tbl(l_idx).value_14 := 'A';
        END IF;
           x_display_rec.field_14                           := to_char( x_display_rec.start_period_14 + 1,'mm/yy');
           x_display_rec.start_period_14                    := x_display_rec.start_period_14;
           x_display_rec.end_period_14                      := x_display_rec.end_period_14;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 14:'||x_scheduled_visits_tbl(l_idx).value_14);
   END IF;
       --
           x_scheduled_visits_tbl(l_idx).space_id            := null;
           x_scheduled_visits_tbl(l_idx).space_name          := null;
           x_scheduled_visits_tbl(l_idx).department_code     := l_dept_code;
           x_scheduled_visits_tbl(l_idx).department_name     := l_description;
           x_scheduled_visits_tbl(l_idx).department_id       := l_department_id;
           x_scheduled_visits_tbl(l_idx).space_category_mean := null;
           x_scheduled_visits_tbl(l_idx).Space_Category      := null;
           x_scheduled_visits_tbl(l_idx).org_name            := l_org_name;
           x_display_rec.start_period                    := l_start_date;
           x_display_rec.end_period                      := x_display_rec.end_period_14;

        --
       l_idx := l_idx + 1;
       END IF;

    END LOOP;
    CLOSE l_dept_cur;

  -- Space info

  OPEN_FOR_CURSOR(p_x_ref_csr => l_space_cur,
                  p_search_query_tbl => l_temp_tbl,
                  p_sql_str => l_sql_string1);
    --
    LOOP
    FETCH l_space_cur INTO l_space_id, l_space_name , l_space_category,
	                       l_meaning, l_department_id,l_dept_code, l_description,
						   l_org_id, l_org_name;
    EXIT WHEN l_space_cur%NOTFOUND;
    --
    IF  l_space_id IS NOT NULL THEN
        IF l_start_date IS NOT NULL THEN
            x_display_rec.start_period_1 := l_start_date-1;

            SELECT ADD_MONTHS(x_display_rec.start_period_1,1) INTO
            x_display_rec.end_period_1 FROM DUAL;


        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_1,
                                        x_display_rec.end_period_1);


          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_1 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_1,
                                       x_display_rec.end_period_1) THEN
               x_scheduled_visits_tbl(l_idx).value_1 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_1 := 'A';
           END IF;
          END IF;
           x_display_rec.field_1                            := to_char( l_start_date ,'mm/yy');
           x_display_rec.start_period_1                     := x_display_rec.start_period_1;
           x_display_rec.end_period_1                       := x_display_rec.end_period_1;
       END IF;
       --
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'value 1:'||x_display_rec.field_1);
     AHL_DEBUG_PUB.debug( 'start 1:'||x_display_rec.start_period_1);
     AHL_DEBUG_PUB.debug( 'end 1:'||x_display_rec.end_period_1);
   END IF;
       --
        IF x_display_rec.end_period_1 IS NOT NULL THEN
           x_display_rec.start_period_2:= x_display_rec.end_period_1;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_2,1) INTO
            x_display_rec.end_period_2 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_2,
                                        x_display_rec.end_period_2);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_2 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_2,
                                       x_display_rec.end_period_2) THEN
               x_scheduled_visits_tbl(l_idx).value_2 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_2 := 'A';
           END IF;
          END IF;
           x_display_rec.field_2                           := to_char( x_display_rec.start_period_2 + 1,'mm/yy');
           x_display_rec.start_period_2                    := x_display_rec.start_period_2;
           x_display_rec.end_period_2                      := x_display_rec.end_period_2;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'SPACE ID:'||l_space_id);
    AHL_DEBUG_PUB.debug( 'value 2:'||x_display_rec.field_2);
    AHL_DEBUG_PUB.debug( 'start 2:'||x_display_rec.start_period_2);
    AHL_DEBUG_PUB.debug( 'end 2:'||x_display_rec.end_period_2);
   END IF;
       --
        IF x_display_rec.end_period_2 IS NOT NULL THEN
           x_display_rec.start_period_3:= x_display_rec.end_period_2;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_3,1) INTO
            x_display_rec.end_period_3 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_3,
                                        x_display_rec.end_period_3);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_3 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_3,
                                       x_display_rec.end_period_3) THEN
               x_scheduled_visits_tbl(l_idx).value_3 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_3 := 'A';
           END IF;
          END IF;
           x_display_rec.field_3                           := to_char( x_display_rec.start_period_3 + 1,'mm/yy');
           x_display_rec.start_period_3                    := x_display_rec.start_period_3;
           x_display_rec.end_period_3                      := x_display_rec.end_period_3;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 3:'||x_display_rec.field_3);
    AHL_DEBUG_PUB.debug( 'start 3:'||x_display_rec.start_period_3);
    AHL_DEBUG_PUB.debug( 'end 3:'||x_display_rec.end_period_3);
   END IF;
       --
        IF x_display_rec.end_period_3 IS NOT NULL THEN
           x_display_rec.start_period_4:= x_display_rec.end_period_3;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_4,1) INTO
            x_display_rec.end_period_4 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_4,
                                        x_display_rec.end_period_4);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_4 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_4,
                                       x_display_rec.end_period_4) THEN
               x_scheduled_visits_tbl(l_idx).value_4 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_4 := 'A';
           END IF;
          END IF;
           x_display_rec.field_4                            := to_char( x_display_rec.start_period_4 + 1,'mm/yy');
           x_display_rec.start_period_4                     := x_display_rec.start_period_4;
           x_display_rec.end_period_4                       := x_display_rec.end_period_4;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 4:'||x_display_rec.field_4);
    AHL_DEBUG_PUB.debug( 'start 4:'||x_display_rec.start_period_4);
    AHL_DEBUG_PUB.debug( 'end 4:'||x_display_rec.end_period_4);
   END IF;
       --
        IF x_display_rec.end_period_4 IS NOT NULL THEN
           x_display_rec.start_period_5:= x_display_rec.end_period_4;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_5,1) INTO
            x_display_rec.end_period_5 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_5,
                                        x_display_rec.end_period_5);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_5 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_5,
                                       x_display_rec.end_period_5) THEN
               x_scheduled_visits_tbl(l_idx).value_5 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_5 := 'A';
           END IF;
          END IF;
           x_display_rec.field_5                            := to_char( x_display_rec.start_period_5 + 1,'mm/yy');
           x_display_rec.start_period_5                     := x_display_rec.start_period_5;
           x_display_rec.end_period_5                       := x_display_rec.end_period_5;
       END IF;
       --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'value 5:'||x_scheduled_visits_tbl(l_idx).value_5);
   END IF;
       --
        IF x_display_rec.end_period_5 IS NOT NULL THEN
           x_display_rec.start_period_6:= x_display_rec.end_period_5;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_6,1) INTO
            x_display_rec.end_period_6 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_6,
                                        x_display_rec.end_period_6);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_6 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_6,
                                       x_display_rec.end_period_6) THEN
               x_scheduled_visits_tbl(l_idx).value_6 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_6 := 'A';
           END IF;
          END IF;
           x_display_rec.field_6                            := to_char( x_display_rec.start_period_6 + 1,'mm/yy');
           x_display_rec.start_period_6                     := x_display_rec.start_period_6;
           x_display_rec.end_period_6                       := x_display_rec.end_period_6;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 6:'||x_scheduled_visits_tbl(l_idx).value_6);
   END IF;
       --
            IF x_display_rec.end_period_6 IS NOT NULL THEN
           x_display_rec.start_period_7:= x_display_rec.end_period_6;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_7,1) INTO
            x_display_rec.end_period_7 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_7,
                                        x_display_rec.end_period_7);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_7 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_7,
                                       x_display_rec.end_period_7) THEN
               x_scheduled_visits_tbl(l_idx).value_7 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_7 := 'A';
           END IF;
          END IF;
           x_display_rec.field_7                            := to_char( x_display_rec.start_period_7 + 1,'mm/yy');
           x_display_rec.start_period_7                     := x_display_rec.start_period_7;
           x_display_rec.end_period_7                       := x_display_rec.end_period_7;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 7:'||x_scheduled_visits_tbl(l_idx).value_7);
   END IF;
       --
        IF x_display_rec.end_period_7 IS NOT NULL THEN
           x_display_rec.start_period_8:= x_display_rec.end_period_7;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_8,1) INTO
            x_display_rec.end_period_8 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_8,
                                        x_display_rec.end_period_8);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_8 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_8,
                                       x_display_rec.end_period_8) THEN
               x_scheduled_visits_tbl(l_idx).value_8 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_8 := 'A';
           END IF;
          END IF;
           x_display_rec.field_8                            := to_char( x_display_rec.start_period_8 + 1,'mm/yy');
           x_display_rec.start_period_8                     := x_display_rec.start_period_8;
           x_display_rec.end_period_8                       := x_display_rec.end_period_8;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 8:'||x_scheduled_visits_tbl(l_idx).value_8);
   END IF;
       --
        IF x_display_rec.end_period_8 IS NOT NULL THEN
           x_display_rec.start_period_9:= x_display_rec.end_period_8;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_9,1) INTO
            x_display_rec.end_period_9 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_9,
                                        x_display_rec.end_period_9);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_9 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_9,
                                       x_display_rec.end_period_9) THEN
               x_scheduled_visits_tbl(l_idx).value_9 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_9 := 'A';
           END IF;
          END IF;
           x_display_rec.field_9                            := to_char( x_display_rec.start_period_9 + 1,'mm/yy');
           x_display_rec.start_period_9                     := x_display_rec.start_period_9;
           x_display_rec.end_period_9                       := x_display_rec.end_period_9;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 9:'||x_scheduled_visits_tbl(l_idx).value_9);
   END IF;
       --
        IF x_display_rec.end_period_9 IS NOT NULL THEN
           x_display_rec.start_period_10:= x_display_rec.end_period_9;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_10,1) INTO
            x_display_rec.end_period_10 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_10,
                                        x_display_rec.end_period_10);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_10 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_10,
                                       x_display_rec.end_period_10) THEN
               x_scheduled_visits_tbl(l_idx).value_10 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_10 := 'A';
           END IF;
          END IF;
           x_display_rec.field_10                           := to_char( x_display_rec.start_period_10 + 1,'mm/yy');
           x_display_rec.start_period_10                    := x_display_rec.start_period_10;
           x_display_rec.end_period_10                      := x_display_rec.end_period_10;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 10:'||x_scheduled_visits_tbl(l_idx).value_10);
   END IF;
       --
        IF x_display_rec.end_period_10 IS NOT NULL THEN
           x_display_rec.start_period_11:= x_display_rec.end_period_10;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_11,1) INTO
            x_display_rec.end_period_11 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_11,
                                        x_display_rec.end_period_11);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_11 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_11,
                                       x_display_rec.end_period_11) THEN
               x_scheduled_visits_tbl(l_idx).value_11 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_11 := 'A';
           END IF;
          END IF;
           x_display_rec.field_11                           := to_char( x_display_rec.start_period_11 + 1,'mm/yy');
           x_display_rec.start_period_11                    := x_display_rec.start_period_11;
           x_display_rec.end_period_11                      := x_display_rec.end_period_11;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 11:'||x_scheduled_visits_tbl(l_idx).value_11);
   END IF;
       --
        IF x_display_rec.end_period_11 IS NOT NULL THEN
           x_display_rec.start_period_12:= x_display_rec.end_period_11;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_12,1) INTO
            x_display_rec.end_period_12 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_12,
                                        x_display_rec.end_period_12);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_12 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_12,
                                       x_display_rec.end_period_12) THEN
               x_scheduled_visits_tbl(l_idx).value_12 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_12 := 'A';
           END IF;
          END IF;
           x_display_rec.field_12                           := to_char( x_display_rec.start_period_12 + 1,'mm/yy');
           x_display_rec.start_period_12                    := x_display_rec.start_period_12;
           x_display_rec.end_period_12                      := x_display_rec.end_period_12;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 12:'||x_scheduled_visits_tbl(l_idx).value_12);
   END IF;
       --
        IF x_display_rec.end_period_12 IS NOT NULL THEN
           x_display_rec.start_period_13:= x_display_rec.end_period_12;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_13,1) INTO
            x_display_rec.end_period_13 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_13,
                                        x_display_rec.end_period_13);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_13 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_13,
                                       x_display_rec.end_period_13) THEN
               x_scheduled_visits_tbl(l_idx).value_13 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_13 := 'A';
           END IF;
          END IF;
           x_display_rec.field_13                           := to_char( x_display_rec.start_period_13 + 1,'mm/yy');
           x_display_rec.start_period_13                    := x_display_rec.start_period_13;
           x_display_rec.end_period_13                      := x_display_rec.end_period_13;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 13:'||x_scheduled_visits_tbl(l_idx).value_13);
   END IF;
       --
        IF x_display_rec.end_period_13 IS NOT NULL THEN
           x_display_rec.start_period_14:= x_display_rec.end_period_13;
           --
            SELECT ADD_MONTHS(x_display_rec.start_period_14,1) INTO
            x_display_rec.end_period_14 FROM DUAL;

        l_count :=  Get_count_of_Visits(l_space_id,
                                        p_simulation_plan_id,
                                        p_plan_flag,
                                        x_display_rec.start_period_14,
                                        x_display_rec.end_period_14);

          IF l_count = 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'S';
          ELSIF l_count > 1 THEN
           x_scheduled_visits_tbl(l_idx).value_14 := 'M';
          ELSIF l_count = 0 THEN
             IF Check_Unavilable_Space(l_space_id,
                                       x_display_rec.start_period_14,
                                       x_display_rec.end_period_14) THEN
               x_scheduled_visits_tbl(l_idx).value_14 := 'U';
             ELSE
                x_scheduled_visits_tbl(l_idx).value_14 := 'A';
           END IF;
        END IF;
           x_display_rec.field_14                           := to_char( x_display_rec.start_period_14 + 1,'mm/yy');
           x_display_rec.start_period_14                    := x_display_rec.start_period_14;
           x_display_rec.end_period_14                      := x_display_rec.end_period_14;
       END IF;
       --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'value 14:'||x_scheduled_visits_tbl(l_idx).value_14);
   END IF;
           x_scheduled_visits_tbl(l_idx).space_id            := l_space_id;
           x_scheduled_visits_tbl(l_idx).space_name          := l_space_name;
           x_scheduled_visits_tbl(l_idx).department_code     := l_dept_code;
           x_scheduled_visits_tbl(l_idx).department_name     := l_description;
           x_scheduled_visits_tbl(l_idx).department_id       := l_department_id;
           x_scheduled_visits_tbl(l_idx).space_category_mean := l_meaning;
           x_scheduled_visits_tbl(l_idx).Space_Category      := l_space_category;
           x_scheduled_visits_tbl(l_idx).org_name            := l_org_name;
           x_display_rec.start_period                    := l_start_date;
           x_display_rec.end_period                      := x_display_rec.end_period_14;

       --
       l_idx := l_idx + 1;
       END IF;

    END LOOP;
    CLOSE l_space_cur;
 --

END Get_UOM_MONTHS;

--  Procedure name    : Search_Scheduled_Visits
--  Type        : Private
--  Function    : This procedure calculates number of visits scheduled at department or space level
--                based on start date, and various combinations of search criteria UOM (Days,Weeks, Months).
--                Restricted to 14 days, 14 weeks , 14 months due to technical reasons.
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Search Scheduled vists Parameters :
--           p_search_visits_rec       IN  Search_visits_rec_type      Required
--           X_Scheduled_visits_tbl    OUT Scheduled_visits_tbl
--
--
--
PROCEDURE Search_Scheduled_Visits (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2   := FND_API.g_false,
   p_validation_level        IN      NUMBER     := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2   := 'JSP',
   p_search_visits_Rec       IN      search_visits_rec_type,
   x_scheduled_visit_tbl         OUT NOCOPY scheduled_visits_tbl,
   x_display_rec                 OUT  NOCOPY display_rec_type,
   x_return_status               OUT NOCOPY  VARCHAR2,
   x_msg_count                   OUT NOCOPY  NUMBER,
   x_msg_data                    OUT NOCOPY  VARCHAR2
)
IS
 -- Get plan info
CURSOR get_plan_id_cur (c_plan_id IN NUMBER)
 IS
 SELECT simulation_plan_id,
        primary_plan_flag
   FROM  ahl_simulation_plans_vl
  WHERE simulation_plan_id = c_plan_id;
-- New changes
 CURSOR l_org_id_cur (c_org_id IN NUMBER,
                      c_name   IN VARCHAR2)
   IS
   SELECT organization_id,name
     FROM hr_all_organization_units
   WHERE (organization_id = c_org_id
         OR name = c_name);
  --Get Item id or Desc

-- AnRaj: Split the cursor, perf bug 5208300, index was not being hit because of logical OR
/*
   CURSOR l_item_id_cur (  c_item_description   IN VARCHAR2,
				               c_item_id     IN NUMBER)
   IS
      SELECT   distinct(inventory_item_id)
      FROM     MTL_SYSTEM_ITEMS_VL
      WHERE    (inventory_item_id      = c_item_id OR concatenated_segments  = c_item_description);
*/
   CURSOR l_item_id_cur ( c_item_id     IN NUMBER)
   IS
      SELECT   distinct(inventory_item_id)
      FROM     MTL_SYSTEM_ITEMS_VL
      WHERE    inventory_item_id  = c_item_id;

   CURSOR l_item_name_cur ( c_item_description IN VARCHAR2)
   IS
      SELECT   distinct(inventory_item_id)
      FROM     MTL_SYSTEM_ITEMS_VL
      WHERE    concatenated_segments  = c_item_description;


 --Cursor to filter visit type and item type (space capabilities)
 CURSOR Space_capblts_cur (C_visit_type IN VARCHAR2,
                           C_item_id IN NUMBER,
						   C_space_id IN NUMBER)
  IS
  SELECT 1 FROM ahl_space_capabilities
   WHERE visit_type = c_visit_type
     AND inventory_item_id = c_item_id
     AND space_id = c_space_id;

  l_api_name        CONSTANT VARCHAR2(30) := 'SEARCH_SCHEDULED_VISITS';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  l_dummy                    NUMBER;
  l_start_date               DATE;
  l_simulation_plan_id       NUMBER;
  l_plan_flag                VARCHAR2(1);
  l_idx                      NUMBER;
  --
  l_scheduled_visits_tbl  scheduled_visits_tbl;
  l_display_rec           display_rec_type;
  l_search_visits_Rec       search_visits_rec_type := p_search_visits_rec;

BEGIN
  --------------------Initialize ----------------------------------
  -- Standard Start of API savepoint
  SAVEPOINT Search_Scheduled_Visits;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt. Search Scheduled Visits','+SPANT+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      p_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'l_search_visits_Rec.start_date'||l_search_visits_Rec.start_date);
   END IF;
   --
   ---------------------start API Body------------------------------------
   -- Get org id  from org name or vice versa
   IF (l_search_visits_Rec.ORG_ID IS NOT NULL AND
       l_search_visits_Rec.ORG_ID <> FND_API.G_MISS_NUM) OR
	   (l_search_visits_Rec.ORG_NAME IS NOT NULL AND
	    l_search_visits_Rec.ORG_NAME <> FND_API.G_MISS_CHAR)
	   THEN
	   --
	   OPEN l_org_id_cur(l_search_visits_Rec.ORG_ID,l_search_visits_Rec.ORG_NAME);
	   FETCH l_org_id_cur INTO l_search_visits_Rec.ORG_ID,l_search_visits_Rec.ORG_NAME;
	   IF l_org_id_cur%NOTFOUND THEN
          Fnd_Message.set_name('AHL', 'AHL_LTP_INVALID_ORG');
          Fnd_Message.Set_Token('ORG',NVL(l_search_visits_Rec.ORG_NAME,l_search_visits_Rec.ORG_ID));
          Fnd_Msg_Pub.ADD;
          CLOSE l_org_id_cur;
          RAISE Fnd_Api.G_EXC_ERROR;
		  --
	   END IF;
	   CLOSE l_org_id_cur;
	--
	END IF;
     --For Space Category
      IF l_search_visits_Rec.space_category_mean IS NOT NULL AND
         l_search_visits_Rec.space_category_mean <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_LTP_SPACE_CATEGORY',
                  p_lookup_code  => NULL,
                  p_meaning      => l_search_visits_Rec.space_category_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_search_visits_Rec.space_category,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_SP_CATEGORY_NOT_EXIST');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
     ELSE
        -- Id presents
         IF l_search_visits_Rec.space_category IS NOT NULL AND
            l_search_visits_Rec.space_category <> Fnd_Api.G_MISS_CHAR
         THEN
           l_search_visits_Rec.space_category := l_search_visits_Rec.space_category;
        END IF;
     END IF;

     --For Visit type
      IF l_search_visits_Rec.visit_type_mean IS NOT NULL AND
         l_search_visits_Rec.visit_type_mean <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_PLANNING_VISIT_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => l_search_visits_Rec.visit_type_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_search_visits_Rec.visit_type_code,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_TYPE_INVALID');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
       ELSE
        -- Id presents
         IF l_search_visits_Rec.visit_type_code IS NOT NULL AND
            l_search_visits_Rec.visit_type_code <> Fnd_Api.G_MISS_CHAR
         THEN
           l_search_visits_Rec.visit_type_code := l_search_visits_Rec.visit_type_code;
        END IF;
      END IF;

      -- AnRaj: Changed the code by splitting the cursor, perf bug 5208300, index was not being hit because of OR
      -- For Item based on the name,
      IF (l_search_visits_Rec.item_description IS NOT NULL AND l_search_visits_Rec.item_description <> Fnd_Api.G_MISS_CHAR)
      THEN
         OPEN  l_item_name_cur(l_search_visits_Rec.item_description);
         FETCH l_item_name_cur INTO l_search_visits_rec.item_id;
		   IF l_item_name_cur%NOTFOUND THEN
            Fnd_Message.set_name('AHL', 'AHL_LTP_ITEM_NOT_EXIST');
            Fnd_Message.Set_Token('ITEM',NVL(l_search_visits_Rec.ITEM_DESCRIPTION,l_search_visits_Rec.ITEM_ID));
            Fnd_Msg_Pub.ADD;
            CLOSE l_item_name_cur;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
		   CLOSE l_item_name_cur;
      END IF;

      IF (l_search_visits_Rec.item_id IS NOT NULL AND l_search_visits_Rec.item_id <> Fnd_Api.G_MISS_NUM)
      THEN
         OPEN  l_item_id_cur (l_search_visits_Rec.item_id);
         FETCH l_item_id_cur INTO l_search_visits_rec.item_id;
		   IF l_item_id_cur%NOTFOUND THEN
            Fnd_Message.set_name('AHL', 'AHL_LTP_ITEM_NOT_EXIST');
            Fnd_Message.Set_Token('ITEM',NVL(l_search_visits_Rec.ITEM_DESCRIPTION,l_search_visits_Rec.ITEM_ID));
            Fnd_Msg_Pub.ADD;
            CLOSE l_item_id_cur;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
		 CLOSE l_item_id_cur;
      END IF;
      -- AnRaj: Bug fix for 5208300 end.

     --For Display Period
      IF l_search_visits_Rec.display_period_mean IS NOT NULL AND
         l_search_visits_Rec.display_period_mean <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_LTP_DISPLAY_PERIOD',
                  p_lookup_code  => NULL,
                  p_meaning      => l_search_visits_Rec.display_period_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_search_visits_Rec.display_period_code,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_DISPLAY_INVALID');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
     ELSE
        -- Id presents
         IF l_search_visits_Rec.display_period_code IS NOT NULL AND
            l_search_visits_Rec.display_period_code <> Fnd_Api.G_MISS_CHAR
         THEN
           l_search_visits_Rec.display_period_code := l_search_visits_Rec.display_period_code;
        END IF;
     END IF;
  --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'l_search_visits_Rec.plan_id'||l_search_visits_Rec.plan_id);
      AHL_DEBUG_PUB.debug( 'l_search_visits_Rec.plan_name'||l_search_visits_Rec.plan_name);
      AHL_DEBUG_PUB.debug( 'l_search_visits_Rec.item_id'||l_search_visits_Rec.item_id);
      AHL_DEBUG_PUB.debug( 'l_search_visits_Rec.visit_type'||l_search_visits_Rec.visit_type_code);
   END IF;
  --Get plan id
   OPEN get_plan_id_cur(l_search_visits_Rec.plan_id);
   FETCH get_plan_id_cur INTO l_simulation_plan_id,l_plan_flag;
     IF get_plan_id_cur%NOTFOUND THEN
        Fnd_Message.set_name('AHL', 'AHL_LTP_INVALID_PLAN');
        Fnd_Msg_Pub.ADD;
      CLOSE get_plan_id_cur;
      RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
    CLOSE get_plan_id_cur;
   --
   l_start_date :=  trunc(l_search_visits_Rec.start_date);

--      l_start_date := TO_CHAR(l_search_visits_Rec.start_date, 'DD-MM-YYYY ');
   --
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'l_simulation_plan_id:'||l_simulation_plan_id);
      AHL_DEBUG_PUB.debug( 'l_plan_flag:'||l_plan_flag);
      AHL_DEBUG_PUB.debug( 'l_start_date:'||l_start_date);

   END IF;
   --
	IF l_search_visits_Rec.display_period_code  = 'DAYS'   THEN
   --
		Get_Uom_Days (
				p_start_date           => l_start_date,
				p_org_id               => l_search_visits_Rec.ORG_ID,
				p_simulation_plan_id   => l_simulation_plan_id,
				p_plan_flag            => l_plan_flag,
				p_dept_id              => l_search_visits_Rec.department_id,
				p_dept_name            => l_search_visits_Rec.department_name,
				p_space_id             => l_search_visits_Rec.space_id,
				p_space_name           => l_search_visits_Rec.space_name,
				p_space_category       => l_search_visits_Rec.space_category,
				-- p_visit_type           => l_search_visits_Rec.visit_type_code,
				-- p_item_id              => l_search_visits_Rec.item_id,
				x_scheduled_visits_tbl => l_scheduled_visits_tbl,
				x_display_rec          => l_display_rec);
		-- Assign to out record
		IF l_scheduled_visits_tbl.count > 0 then
			FOR i IN l_scheduled_visits_tbl.first..l_scheduled_visits_tbl.last
			LOOP
				--Space id is not null
			  IF l_scheduled_visits_tbl(i).space_id IS NOT NULL
			   THEN
					OPEN Space_capblts_cur(l_search_visits_Rec.visit_type_code,
					l_search_visits_Rec.item_id,l_scheduled_visits_tbl(i).space_id);
						FETCH Space_capblts_cur INTO l_dummy;
						IF Space_capblts_cur%FOUND THEN
							x_scheduled_visit_tbl(i)  := l_scheduled_visits_tbl(i);
							x_display_rec             := l_display_rec;
						END IF;
					CLOSE Space_capblts_cur;
				--Department not null
				ELSE
					x_scheduled_visit_tbl(i)  := l_scheduled_visits_tbl(i);
					x_display_rec             := l_display_rec;
				END IF;
			  --
			END LOOP;
		END IF;
		--In case of null records send display record
		IF l_display_rec.field_1 IS NULL THEN
		--
			x_display_rec.field_1         := to_char( l_start_date ,'dd/mm');
         x_display_rec.field_2         := to_char( l_start_date + 1,'dd/mm');
         x_display_rec.field_3         := to_char( l_start_date + 2 ,'dd/mm');
         x_display_rec.field_4         := to_char( l_start_date + 3,'dd/mm');
         x_display_rec.field_5         := to_char( l_start_date + 4,'dd/mm');
         x_display_rec.field_6         := to_char( l_start_date + 5,'dd/mm');
         x_display_rec.field_7         := to_char( l_start_date + 6,'dd/mm');
         x_display_rec.field_8         := to_char( l_start_date + 7,'dd/mm');
         x_display_rec.field_9         := to_char( l_start_date + 8 ,'dd/mm');
         x_display_rec.field_10         := to_char( l_start_date + 9 ,'dd/mm');
         x_display_rec.field_11         := to_char( l_start_date + 10 ,'dd/mm');
         x_display_rec.field_12         := to_char( l_start_date + 11 ,'dd/mm');
         x_display_rec.field_13         := to_char( l_start_date + 12 ,'dd/mm');
         x_display_rec.field_14         := to_char( l_start_date + 13 ,'dd/mm');
		  --
		END IF;
	END IF; -- Days

 -- For Weeks
 IF l_search_visits_Rec.display_period_code  = 'WEEKS'   THEN
     --
     Get_Uom_Weeks (
          p_start_date           => l_start_date,
          p_org_id               => l_search_visits_Rec.ORG_ID,
		  p_simulation_plan_id   => l_simulation_plan_id,
		  p_plan_flag            => l_plan_flag,
          p_dept_id              => l_search_visits_Rec.department_id,
          p_dept_name            => l_search_visits_Rec.department_name,
          p_space_id             => l_search_visits_Rec.space_id,
		  p_space_name           => l_search_visits_Rec.space_name,
          p_space_category       => l_search_visits_Rec.space_category,
          x_scheduled_visits_tbl => l_scheduled_visits_tbl,
          x_display_rec          => l_display_rec);
		  -- Assign to out record
		  IF l_scheduled_visits_tbl.count > 0 then
		  FOR i IN l_scheduled_visits_tbl.first..l_scheduled_visits_tbl.last
		  LOOP
		      --Space id is not null
			  IF l_scheduled_visits_tbl(i).space_id IS NOT NULL
			   THEN
			  OPEN Space_capblts_cur(l_search_visits_Rec.visit_type_code,
			   l_search_visits_Rec.item_id,l_scheduled_visits_tbl(i).space_id);
			  FETCH Space_capblts_cur INTO l_dummy;
			  IF Space_capblts_cur%FOUND THEN
		      x_scheduled_visit_tbl(i)  := l_scheduled_visits_tbl(i);
			  x_display_rec             := l_display_rec;
			  END IF;
			  CLOSE Space_capblts_cur;
			  --Department not null
			  ELSE
		      x_scheduled_visit_tbl(i)  := l_scheduled_visits_tbl(i);
			  x_display_rec             := l_display_rec;
			  END IF;
			  --
		  END LOOP;
		  END IF;
		  --
		  --In case of null records send display record
		  IF l_display_rec.field_1 IS NULL THEN
		   --
           x_display_rec.field_1         := to_char( l_start_date ,'dd/mm');
           x_display_rec.field_2         := to_char( l_start_date + 7,'dd/mm');
           x_display_rec.field_3         := to_char( to_date(x_display_rec.field_2,'dd/mm')  + 7 ,'dd/mm');
           x_display_rec.field_4         := to_char( to_date(x_display_rec.field_3,'dd/mm')  + 7,'dd/mm');
           x_display_rec.field_5         := to_char( to_date(x_display_rec.field_4, 'dd/mm')  + 7,'dd/mm');
           x_display_rec.field_6         := to_char( to_date(x_display_rec.field_5,'dd/mm')  + 7,'dd/mm');
           x_display_rec.field_7         := to_char( to_date(x_display_rec.field_6, 'dd/mm')  + 7,'dd/mm');
           x_display_rec.field_8         := to_char( to_date(x_display_rec.field_7, 'dd/mm')  + 7,'dd/mm');
           x_display_rec.field_9         := to_char( to_date(x_display_rec.field_8, 'dd/mm')  + 7 ,'dd/mm');
           x_display_rec.field_10        := to_char( to_date(x_display_rec.field_9, 'dd/mm')   + 7 ,'dd/mm');
           x_display_rec.field_11        := to_char( to_date(x_display_rec.field_10, 'dd/mm') + 7 ,'dd/mm');
           x_display_rec.field_12        := to_char( to_date(x_display_rec.field_11, 'dd/mm') + 7 ,'dd/mm');
           x_display_rec.field_13        := to_char( to_date(x_display_rec.field_12, 'dd/mm') + 7 ,'dd/mm');
           x_display_rec.field_14        := to_char( to_date(x_display_rec.field_13, 'dd/mm') + 7 ,'dd/mm');
		   --
		  END IF;

 END IF;

 -- For Months
 IF l_search_visits_Rec.display_period_code  = 'MONTHS'   THEN

     Get_Uom_Months (
          p_start_date           => l_start_date,
          p_org_id               => l_search_visits_Rec.ORG_ID,
		  p_simulation_plan_id   => l_simulation_plan_id,
		  p_plan_flag            => l_plan_flag,
          p_dept_id              => l_search_visits_Rec.department_id,
		  p_dept_name            => l_search_visits_Rec.department_name,
          p_space_id             => l_search_visits_Rec.space_id,
		  p_space_name           => l_search_visits_Rec.space_name,
          p_space_category       => l_search_visits_Rec.space_category,
          x_scheduled_visits_tbl => l_scheduled_visits_tbl,
          x_display_rec          => l_display_rec);
		  -- Assign to out record
		  IF l_scheduled_visits_tbl.count > 0 then
		  FOR i IN l_scheduled_visits_tbl.first..l_scheduled_visits_tbl.last
		  LOOP
		      --Space id is not null
			  IF l_scheduled_visits_tbl(i).space_id IS NOT NULL
			   THEN
			  OPEN Space_capblts_cur(l_search_visits_Rec.visit_type_code,
			   l_search_visits_Rec.item_id,l_scheduled_visits_tbl(i).space_id);
			  FETCH Space_capblts_cur INTO l_dummy;
			  IF Space_capblts_cur%FOUND THEN
		      x_scheduled_visit_tbl(i)  := l_scheduled_visits_tbl(i);
			  x_display_rec             := l_display_rec;
			  END IF;
			  CLOSE Space_capblts_cur;
			  --Department not null
			  ELSE
		      x_scheduled_visit_tbl(i)  := l_scheduled_visits_tbl(i);
			  x_display_rec             := l_display_rec;
			  END IF;
              --
		  END LOOP;
		  END IF;

            SELECT ADD_MONTHS(x_display_rec.start_period_1,1) INTO
            x_display_rec.end_period_1 FROM DUAL;

		  --In case of null records send display record
		  IF l_display_rec.field_1 IS NULL THEN
		   --
           x_display_rec.field_1         := to_char( l_start_date ,'mm/yy');
		   --
           SELECT ADD_MONTHS(l_start_date,1) INTO
           x_display_rec.end_period_1 FROM DUAL;
		   --
           x_display_rec.field_2         := to_char(x_display_rec.end_period_1,'mm/yy');
           --
           SELECT ADD_MONTHS(x_display_rec.end_period_1,1) INTO
           x_display_rec.end_period_2 FROM DUAL;
		   --
           x_display_rec.field_3         := to_char(x_display_rec.end_period_2,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_2,1) INTO
           x_display_rec.end_period_3 FROM DUAL;
		   --
           x_display_rec.field_4         := to_char(x_display_rec.end_period_3,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_3,1) INTO
           x_display_rec.end_period_4 FROM DUAL;
		   --
           x_display_rec.field_5         := to_char(x_display_rec.end_period_4,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_4,1) INTO
           x_display_rec.end_period_5 FROM DUAL;
		   --
           x_display_rec.field_6         := to_char(x_display_rec.end_period_5,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_5,1) INTO
           x_display_rec.end_period_6 FROM DUAL;
		   --
           x_display_rec.field_7         := to_char(x_display_rec.end_period_6,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_6,1) INTO
           x_display_rec.end_period_7 FROM DUAL;
		   --
           x_display_rec.field_8         := to_char(x_display_rec.end_period_7,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_7,1) INTO
           x_display_rec.end_period_8 FROM DUAL;
		   --
           x_display_rec.field_9         := to_char(x_display_rec.end_period_8,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_8,1) INTO
           x_display_rec.end_period_9 FROM DUAL;
		   --
           x_display_rec.field_10         := to_char(x_display_rec.end_period_9,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_9,1) INTO
           x_display_rec.end_period_10 FROM DUAL;
		   --
           x_display_rec.field_11         := to_char(x_display_rec.end_period_10,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_10,1) INTO
           x_display_rec.end_period_11 FROM DUAL;
		   --
           x_display_rec.field_12         := to_char(x_display_rec.end_period_11,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_11,1) INTO
           x_display_rec.end_period_12 FROM DUAL;
		   --
           x_display_rec.field_13         := to_char(x_display_rec.end_period_12,'mm/yy');
		   --
           SELECT ADD_MONTHS(x_display_rec.end_period_12,1) INTO
           x_display_rec.end_period_13 FROM DUAL;
		   --
           x_display_rec.field_14         := to_char(x_display_rec.end_period_13,'mm/yy');
		   --

		   --
		  END IF;

     --
   END IF;

  ---------------------------End of Body---------------------------------------
  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;

   --Standard check for commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Search Scheduled Visits','+SPANT+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Search_Scheduled_Visits;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);

   IF G_DEBUG='Y' THEN
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt.Search Scheduled Visits','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Search_Scheduled_Visits;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt.Search Scheduled Visits','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO Search_Scheduled_Visits;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_SCHEDULE_PVT',
                            p_procedure_name  =>  'SEARCH_SCHEDULED_VISITS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
            AHL_DEBUG_PUB.log_app_messages (
                x_msg_count, x_msg_data, 'SQL ERROR' );
            AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt.Search Scheduled Visits','+SPANT+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

END Search_Scheduled_Visits;

--
PROCEDURE Get_Visit_Duration
         (p_visit_id                IN  NUMBER,
          x_visit_duration          OUT NOCOPY NUMBER,
          x_return_status	    OUT NOCOPY VARCHAR2,
          x_msg_count		    OUT NOCOPY NUMBER,
          x_msg_data		    OUT NOCOPY VARCHAR2 )
IS
  --
  CURSOR get_visit_cur (c_visit_id IN NUMBER)
  IS
   SELECT start_date_time
      FROM AHL_VISITS_B
    WHERE visit_id = c_visit_id;

  /* Modified by mpothuku on 01/25/05 to include the status_code clause */
  CURSOR get_task_end_cur (c_visit_id IN NUMBER)
     IS
   SELECT max(end_date_time)
     FROM ahl_visit_tasks_vl
    WHERE visit_id = c_visit_id
	and status_code <> 'DELETED' ;

  --
  l_api_name        CONSTANT VARCHAR2(30) := 'GET_VISIT_DURATION';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_init_msg_list            VARCHAR2(30) := fnd_api.g_true;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  l_visit_start_time         DATE;
  l_visit_end_time           DATE;
  l_duration                 NUMBER;
  l_visit_time				 DATE;
  l_due_time				 NUMBER;

BEGIN
  --
  -- Standard Start of API savepoint
  SAVEPOINT get_visit_duration;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt.get_visit_duration','+SPSL+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --
  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'inside get visit duration :'||p_visit_id);
  --
  AHL_DEBUG_PUB.debug( 'before call'||p_visit_id);
  END IF;
  --
 IF p_visit_id IS NOT NULL THEN
    --Visit Start date
     OPEN get_visit_cur(p_visit_id);
     FETCH get_visit_cur INTO l_visit_start_time;
     CLOSE get_visit_cur;
     --
     IF  l_visit_start_time IS NOT NULL  THEN
	  --Get Last Task end date
      OPEN get_task_end_cur(p_visit_id);
	  FETCH get_task_end_cur INTO l_visit_end_time;
	  CLOSE get_task_end_cur;
     END IF;
   END IF;

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'visit start time :'||to_char(l_visit_start_time, 'dd/mm/yy hh:mi:ss:'));
      AHL_DEBUG_PUB.debug( 'visit end time :'||to_char(l_visit_end_time,'dd/mm/yy hh:mi:ss:'));
   END IF;

   IF (l_visit_start_time IS NOT NULL AND l_visit_end_time IS NOT NULL) THEN

      l_visit_time :=   l_visit_start_time;

    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'l_visit time :'||to_char(l_visit_time, 'dd/mm/yy hh:mi:ss'));
      AHL_DEBUG_PUB.debug( 'l_visit end time :'||to_char(l_visit_end_time, 'dd/mm/yy hh:mi:ss'));
    END IF;
	  l_due_time := l_visit_end_time  - l_visit_time;
    IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'l_due_time :'||l_due_time);
    END IF;
	  /* Changes made by mpothuku on 01/24/05 for bug #4137916 */
      --l_duration := 24* trunc(l_due_time) + abs(to_char(l_visit_end_time, 'hh24')- to_char(l_visit_time, 'hh24'));
	  l_duration := trunc(24 * l_due_time) ;

	  /* mpothuku End */
     IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'l_due_time :'||l_duration);
     END IF;
      --End of modification

      IF G_DEBUG='Y' THEN
      --
      AHL_DEBUG_PUB.debug( 'duration :'||l_duration);
      --
      END IF;
     --

     END IF;
     x_visit_duration := abs(l_duration);
   --
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Get visit duration','+SPSL+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO get_visit_duration;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt.Get visit duration','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
  END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO get_visit_duration;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit duration','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN OTHERS THEN
    ROLLBACK TO get_visit_duration;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_SCHEDULE_PVT',
                            p_procedure_name  =>  'GET_VISIT_DURATION',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit duration','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
END Get_Visit_Duration;
--
PROCEDURE Get_Visit_End_Date
         (p_visit_id                IN  NUMBER,
          x_visit_end_date          OUT NOCOPY DATE,
          x_return_status	    OUT NOCOPY VARCHAR2,
          x_msg_count		    OUT NOCOPY NUMBER,
          x_msg_data		    OUT NOCOPY VARCHAR2 )

IS
  --
  CURSOR get_visit_cur (c_visit_id IN NUMBER)
  IS
   SELECT start_date_time
      FROM AHL_VISITS_B
    WHERE visit_id = c_visit_id;

  CURSOR get_task_end_cur (c_visit_id IN NUMBER)
     IS
   SELECT max(end_date_time)
     FROM ahl_visit_tasks_vl
    WHERE visit_id = c_visit_id;

  --
  l_api_name        CONSTANT VARCHAR2(30) := 'GET_VISIT_END_DATE';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  l_init_msg_list            VARCHAR2(30) := FND_API.g_true;
  l_visit_start_time         DATE;
  l_visit_end_time           DATE;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT get_visit_end_date;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt.get_visit_end_date','+SUAVL+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --
  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'inside get visit end date :'||p_visit_id);
  END IF;
  --
  IF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.G_MISS_NUM )THEN
     OPEN get_visit_cur(p_visit_id);
     FETCH get_visit_cur INTO l_visit_start_time;
     CLOSE get_visit_cur;
     --
     IF l_visit_start_time IS NOT NULL THEN
	  --Get Last Task end date
      OPEN get_task_end_cur(p_visit_id);
	  FETCH get_task_end_cur INTO l_visit_end_time;
	  CLOSE get_task_end_cur;
     END IF;
	END IF;

   IF G_DEBUG='Y' THEN
   --
    AHL_DEBUG_PUB.debug( 'after start date proc isit end date :'||l_visit_end_time);
    AHL_DEBUG_PUB.debug( 'after start date proc isit start time :'||l_visit_start_time);
   END IF;
   --
    IF l_visit_end_time IS NOT NULL THEN
        x_visit_end_date := l_visit_end_time;
      END IF;
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'x_visit_end_date:'||x_visit_end_date);
   END IF;

  --Standard check to count messages
   IF G_DEBUG='Y' THEN
   -- Debug info
   Ahl_Debug_Pub.debug( 'End of private api Get visit end date','+SPSL+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO get_visit_end_date;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt.Get visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO get_visit_end_date;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN
        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN OTHERS THEN
    ROLLBACK TO get_visit_end_date;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_SCHEDULE_PVT',
                            p_procedure_name  =>  'GET_VISIT_END_DATE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

END Get_Visit_End_Date;
---
PROCEDURE Get_Visit_Due_by_Date(
          p_visit_id                IN    NUMBER,
          x_due_by_date             OUT NOCOPY   DATE,
          x_return_status	    OUT NOCOPY   VARCHAR2,
          x_msg_count		    OUT NOCOPY   NUMBER,
          x_msg_data		    OUT NOCOPY   VARCHAR2 )
 IS
  --
  l_api_name        CONSTANT VARCHAR2(30) := 'GET_VISIT_DUE_BY_DATE';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  l_init_msg_list            VARCHAR2(30) := FND_API.g_true;
  l_commit                   VARCHAR2(10);
  l_validation_level         NUMBER := FND_API.g_valid_level_full;
  --
   l_count1 NUMBER;
   l_count2 NUMBER;
   l_date  DATE;

   -- To find whether a visit exists
   CURSOR c_visit (x_id IN NUMBER) IS
      SELECT COUNT(*)
      FROM Ahl_Visit_Tasks_B
      WHERE VISIT_ID = x_id;

   -- To find the total number of tasks for a visit
   CURSOR c_visit_task (x_id IN NUMBER) IS
      SELECT COUNT(*)
      FROM Ahl_Visit_Tasks_B
      WHERE VISIT_ID = x_id AND UNIT_EFFECTIVITY_ID IS NOT NULL;

  -- To find due date for a visit related with tasks
   CURSOR c_due_date (x_id IN NUMBER) IS
     SELECT MAX(T1.due_date)
     FROM ahl_unit_effectivities_app_v T1, ahl_visit_tasks_b T2
     WHERE T1.unit_effectivity_id = T2.unit_effectivity_id AND T2.visit_id = x_id;

BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT get_visit_due_by_date;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   -- Debug info.
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt.get_visit_due_by_date','+SPSL+');
   --
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --
  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'inside visit id due by date :'||p_visit_id);
  --
  END IF;
      OPEN c_visit(p_visit_id);
      FETCH c_visit INTO l_count1;
      IF c_visit%FOUND THEN         --Tasks found for visit
           CLOSE c_visit;
            OPEN c_visit_task(p_visit_id);
            FETCH c_visit_task INTO l_count2;
            IF c_visit_task%FOUND THEN  --Tasks found for visit checking for unit_effectivity_id
                CLOSE c_visit_task;
                OPEN c_due_date(p_visit_id);
                FETCH c_due_date INTO x_due_by_date;
                  IF c_due_date%FOUND THEN     --Tasks found for visit
                        CLOSE c_due_date;
                  END IF;
            ELSE
                CLOSE c_visit_task;
            END IF;
      ELSE
           CLOSE c_visit;
      END IF;
   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'inside visit due by date :'||x_due_by_date);
   END IF;

  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Get visit due by date','+SPSL+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;
  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO get_visit_due_by_date;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt.Get visit due by date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO get_visit_due_by_date;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit due by date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;
WHEN OTHERS THEN
    ROLLBACK TO get_visit_due_by_date;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_SCHEDULE_PVT',
                            p_procedure_name  =>  'GET_VISIT_DUE_BY_DATE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit due by date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

END Get_Visit_Due_by_Date;
--
PROCEDURE Derive_Visit_End_Date
         (p_visits_end_date_tbl      IN OUT NOCOPY visits_end_date_tbl,
          x_return_status	     OUT NOCOPY VARCHAR2,
          x_msg_count		     OUT NOCOPY NUMBER,
          x_msg_data		     OUT NOCOPY VARCHAR2 )
 IS
  --
  l_api_name        CONSTANT VARCHAR2(30) := 'DERIVE_VISIT_END_DATE';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  l_init_msg_list            VARCHAR2(30) := FND_API.g_true;
  l_commit                   VARCHAR2(10);
  l_validation_level         NUMBER := FND_API.g_valid_level_full;
  l_visit_end_date           DATE;
BEGIN
  -- Standard Start of API savepoint
  SAVEPOINT Derive_visit_end_date;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   --
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   --
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt Derive visit end date','+SPSL+');
   --
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(l_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --
  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'inside derieve visit end date :');
  END IF;

  IF (p_visits_end_date_tbl.COUNT > 0) THEN
     FOR i IN p_visits_end_date_tbl.FIRST..p_visits_end_date_tbl.LAST
      LOOP
         Get_Visit_End_Date
           (p_visit_id         => p_visits_end_date_tbl(i).visit_id,
            x_visit_end_date   => l_visit_end_date,
            x_return_status    => l_return_status,
            x_msg_count	       => l_msg_count,
            x_msg_data	       => l_msg_data);

    IF (l_return_status <>  FND_API.G_RET_STS_SUCCESS) THEN
	      l_msg_count := FND_MSG_PUB.count_msg;
	      IF l_msg_count > 0 THEN
	        RAISE FND_API.G_EXC_ERROR;
	      END IF;
     END IF;

       IF l_return_status = 'S'  THEN
          p_visits_end_date_tbl(i).visit_id       := p_visits_end_date_tbl(i).visit_id;
          p_visits_end_date_tbl(i).visit_end_date := l_visit_end_date;
       END IF;
      END LOOP;
   END IF;

   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Derive visit end date','+SPSL+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Derive_visit_end_date;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Derive visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Derive_visit_end_date;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Derive visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN OTHERS THEN
    ROLLBACK TO Derive_visit_end_date;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_SCHEDULE_PVT',
                            p_procedure_name  =>  'DERIEVE_VISIT_END_DATE',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt Derive visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

END Derive_Visit_End_Date;
--
--  Procedure name    : Get_Visit_Details
--  Type        : Private
--  Function    : This procedure shows all the visits scheduled at department or space level
--                based on start date, and various combinations of search criteria UOM (Days,Weeks, Months).
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER                Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--         Based on this flag, the API will set the default attributes.
--      p_module_type                   In      VARCHAR2     Default  NULL
--         This will be null.
--  Standard out Parameters :
--      x_return_status                 OUT     VARCHAR2               Required
--      x_msg_count                     OUT     NUMBER                 Required
--      x_msg_data                      OUT     VARCHAR2               Required
--
--  Search Scheduled vists Parameters :
--           p_search_visits_rec       IN  Search_visits_rec_type      Required
--           X_Visit_details_tbl      OUT visit_details_tbl
--
--
PROCEDURE Get_Visit_Details (
   p_api_version             IN      NUMBER,
   p_init_msg_list           IN      VARCHAR2  := FND_API.g_false,
   p_commit                  IN      VARCHAR2   := FND_API.g_false,
   p_validation_level        IN      NUMBER     := FND_API.g_valid_level_full,
   p_module_type             IN      VARCHAR2   := 'JSP',
   p_search_visits_Rec       IN      search_visits_rec_type,
   x_visit_details_tbl       OUT NOCOPY visit_details_tbl,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)
IS

-- AnRaj: Query changed for performance issues
-- Bug #:4919582, query number:1
 CURSOR get_visit_detail_cur (c_space_id   IN NUMBER,
                              c_visit_type IN VARCHAR2,
                              c_item_id    IN NUMBER)
  IS
SELECT   VST.visit_id,
         VST.visit_number,
         VST.visit_name,
         VST.status_code,
         CSI.serial_number,
         AHL_UTILITY_PVT.GET_UNIT_NAME(VST.ITEM_INSTANCE_ID) unit_name,
         mtl.CONCATENATED_SEGMENTS item_description,
         FLVT.MEANING visit_type_mean,
         trunc(VST.start_date_time) start_date_time,
         trunc(VST.CLOSE_DATE_TIME) close_date_time,
         (
            SELECT   MAX(DUE_DATE)
            FROM     AHL_UNIT_EFFECTIVITIES_B A,
                     AHL_VISIT_TASKS_B B
            WHERE    A.UNIT_EFFECTIVITY_ID = B.UNIT_EFFECTIVITY_ID
            AND      B.VISIT_ID = VST.VISIT_ID
            GROUP BY VISIT_ID
         ) due_by
FROM     AHL_VISITS_VL VST,
         CSI_ITEM_INSTANCES CSI ,
         MTL_SYSTEM_ITEMS_B_KFV mtl,
         FND_LOOKUP_VALUES_VL FLVT,
         ahl_space_assignments SPS
where    VST.ITEM_INSTANCE_ID = CSI.INSTANCE_ID(+)
and      VST.INVENTORY_ITEM_ID = mtl.INVENTORY_ITEM_ID(+)
AND      VST.ITEM_ORGANIZATION_ID = mtl.ORGANIZATION_ID(+)
AND      FLVT.LOOKUP_TYPE(+) = 'AHL_PLANNING_VISIT_TYPE'
AND      FLVT.LOOKUP_CODE(+) = VST.VISIT_TYPE_CODE
AND      VST.visit_id = SPS.visit_id
AND      SPS.space_id = c_space_id;

-- AnRaj: Query changed for performance issues
-- Bug #:4919582, query number:2
 CURSOR get_visit_dept_cur (c_dept_id   IN NUMBER,
                            c_visit_type IN VARCHAR2,
                            c_item_id    IN NUMBER)
  IS
  SELECT    VST.visit_id,
            VST.visit_number,
            VST.visit_name,
            VST.status_code,
            CSI.serial_number,
            AHL_UTILITY_PVT.GET_UNIT_NAME(VST.ITEM_INSTANCE_ID) unit_name,
            mtl.CONCATENATED_SEGMENTS item_description,
            FLVT.MEANING visit_type_mean,
            trunc(VST.start_date_time) start_date_time,
            trunc(VST.CLOSE_DATE_TIME) close_date_time,
            (
               SELECT   MAX(DUE_DATE)
               FROM     AHL_UNIT_EFFECTIVITIES_B A,
                        AHL_VISIT_TASKS_B B
               WHERE    A.UNIT_EFFECTIVITY_ID = B.UNIT_EFFECTIVITY_ID
               AND      B.VISIT_ID = VST.VISIT_ID
               GROUP BY VISIT_ID
            ) due_by
   FROM     AHL_VISITS_VL VST,
            CSI_ITEM_INSTANCES CSI ,
            MTL_SYSTEM_ITEMS_B_KFV mtl,
            FND_LOOKUP_VALUES_VL FLVT
   where    VST.ITEM_INSTANCE_ID = CSI.INSTANCE_ID(+)
   and      VST.INVENTORY_ITEM_ID = mtl.INVENTORY_ITEM_ID(+)
   AND      VST.ITEM_ORGANIZATION_ID = mtl.ORGANIZATION_ID(+)
   AND      FLVT.LOOKUP_TYPE(+) = 'AHL_PLANNING_VISIT_TYPE'
   AND      FLVT.LOOKUP_CODE(+) = VST.VISIT_TYPE_CODE
   AND      VST.department_id = c_dept_id;


 CURSOR visit_wd_detail_cur (c_plan_id        IN NUMBER,
                             c_visit_id       IN NUMBER,
                             c_start_period   IN DATE,
                             c_end_period     IN DATE,
                             c_visit_end_date IN DATE)
  IS
 SELECT distinct(a.visit_id) visit_id,
        a.visit_number,
        serial_number,
		b.status_code,
        item_description,
		b.visit_name,
		unit_name,
		b.simulation_plan_id,
        visit_type_mean,
        a.start_date_time, due_by,
		trunc(b.close_date_time) close_date_time
  FROM ahl_visit_details_v a , ahl_visits_vl b
  WHERE a.visit_id = c_visit_id
    AND a.visit_id = b.visit_id
    AND a.simulation_plan_id = c_plan_id
    AND (((trunc(b.start_date_time) between trunc(c_start_period) and trunc(c_end_period))
	 OR
	   (trunc(c_visit_end_date) between trunc(c_start_period) and trunc(c_end_period) ))

	OR ((trunc(c_start_period) between trunc(b.start_date_time) and trunc(c_visit_end_date))
	 OR
	    (trunc(c_end_period) between trunc(b.start_date_time) and trunc(c_visit_end_date))))
	--Added by mpothuku on 03/29 to fix issue #203 in forum
	AND (nvl(b.simulation_delete_flag, 'N') <> 'Y')
	AND b.status_code not in ('CANCELLED', 'DELETED');

 -- To get simulation visits and primary visits which are not associated to simulation plan
 CURSOR visit_wd1_detail_cur (c_plan_id        IN NUMBER,
                             c_visit_id       IN NUMBER,
                             c_start_period   IN DATE,
                             c_end_period     IN DATE,
                             c_visit_end_date IN DATE)
  IS
 SELECT DISTINCT(a.visit_id) visit_id,
        b.visit_number,
        serial_number,
		b.status_code,
        item_description,
		b.visit_name,
		unit_name,
		b.simulation_plan_id,
        visit_type_mean,
        b.start_date_time, due_by,
		trunc(b.CLOSE_DATE_TIME) close_date_time
  FROM ahl_visit_details_v a ,
       ahl_visits_vl b
  WHERE a.visit_id = b.visit_id
    AND a.simulation_plan_id in (select simulation_plan_id
        from ahl_simulation_plans_vl where primary_plan_flag = 'Y')
    AND a.visit_id = c_visit_id
    AND  b.visit_id NOT IN (select asso_primary_visit_id from ahl_visits_b
        WHERE simulation_plan_id = c_plan_id )
    AND (((trunc(b.start_date_time) between trunc(c_start_period) and trunc(c_end_period))
	 OR
	   (trunc(c_visit_end_date) between trunc(c_start_period) and trunc(c_end_period) ))


	OR ((trunc(c_start_period) between trunc(b.start_date_time) and trunc(c_visit_end_date))
	 OR
    (trunc(c_end_period) between trunc(b.start_date_time) and trunc(c_visit_end_date))))

	--Added by mpothuku on 03/29 to fix issue #203 in forum
	AND b.status_code not in ('CANCELLED', 'DELETED');

-- Get plan info
CURSOR get_plan_id_cur (c_plan_id IN NUMBER)
 IS
 SELECT simulation_plan_id,
        primary_plan_flag
   FROM  ahl_simulation_plans_vl
  WHERE simulation_plan_id = c_plan_id;
-- New changes
 CURSOR l_org_id_cur (c_org_id IN NUMBER,
                      c_name   IN VARCHAR2)
   IS
   SELECT organization_id,name
     FROM hr_all_organization_units
   WHERE (organization_id = c_org_id
         OR name = c_name);
 -- Get dept info
 CURSOR l_dept_id_cur (c_org_id    IN NUMBER,
                       c_dept_id   IN NUMBER,
                       c_dept_name IN VARCHAR2)
   IS
   SELECT department_id,department_code,description
     FROM bom_departments
   WHERE organization_id = c_org_id
     AND (department_id = c_dept_id
	   OR description   = c_dept_name);
 -- Get space info
 CURSOR l_space_id_cur (c_space_id    IN NUMBER,
                        c_space_name  IN VARCHAR2,
                        c_dept_id     IN NUMBER)
   IS
   SELECT space_id,space_name
     FROM AHL_SPACES_VL
   WHERE bom_department_id = c_dept_id
     AND (space_id         = c_space_id
	   OR space_name       = c_space_name);
  -- Get visits associated at department level
 CURSOR visit_dept_cur ( c_dept_id    IN NUMBER,
                         c_visit_type IN VARCHAR2,
						 c_item_id    IN NUMBER)
 IS
 SELECT visit_id, visit_name, visit_type_code,
        trunc(start_date_time) start_date_time,
		trunc(close_date_time) close_date_time
  FROM ahl_visits_vl
 WHERE department_id = c_dept_id
   AND start_date_time IS NOT NULL;
  --
   -- AnRaj: Split the cursor, perf bug 5208300, index was not being hit because of logical OR
  --Get Item id or Desc
 /*
 CURSOR l_item_id_cur (c_item_description   IN VARCHAR2,
	               c_item_id     IN NUMBER)
   IS
   SELECT distinct(inventory_item_id),concatenated_segments
     FROM MTL_SYSTEM_ITEMS_VL
   WHERE (inventory_item_id   = c_item_id
	   OR concatenated_segments     = c_item_description);
 */
CURSOR l_item_name_cur (c_item_description   IN VARCHAR2)
IS
   SELECT   distinct(inventory_item_id),concatenated_segments
   FROM     MTL_SYSTEM_ITEMS_VL
   WHERE    concatenated_segments     = c_item_description;

CURSOR l_item_id_cur (c_item_id     IN NUMBER)
IS
   SELECT   distinct(inventory_item_id),concatenated_segments
   FROM     MTL_SYSTEM_ITEMS_VL
   WHERE    inventory_item_id   = c_item_id;

  --
  l_api_name        CONSTANT VARCHAR2(30) := 'GET_VISIT_DETAILS';
  l_api_version     CONSTANT NUMBER       := 1.0;
  l_msg_count                NUMBER;
  l_return_status            VARCHAR2(1);
  l_msg_data                 VARCHAR2(2000);
  i   NUMBER;
  --
  l_plan_flag                VARCHAR2(1);
  l_start_period               DATE;
  l_end_period                 DATE;
  l_search_visits_Rec  search_visits_rec_type   := p_search_visits_Rec;
  --
  l_get_visit_detail_rec   get_visit_detail_cur%ROWTYPE;
  l_visit_wd_detail_rec    visit_wd_detail_cur%ROWTYPE;
  l_visit_wd1_detail_rec   visit_wd1_detail_cur%ROWTYPE;
  l_visit_dept_rec         visit_dept_cur%ROWTYPE;
  l_get_visit_dept_rec     get_visit_dept_cur%ROWTYPE;
  l_visit_end_date         DATE;
  l_count NUMBER := 0;
  --
BEGIN
   --
  -- Standard Start of API savepoint
  SAVEPOINT Get_visit_details;
   -- Check if API is called in debug mode. If yes, enable debug.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.enable_debug;
   END IF;
   -- Debug info.
   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt Get visit details','+SPSL+');
   END IF;
   -- Standard call to check for call compatibility.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
     FND_MSG_PUB.initialize;
   END IF;
    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                      l_api_version,
                                      l_api_name,G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
  --
  --
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'get visit details DID:'||l_search_visits_Rec.department_id);
    AHL_DEBUG_PUB.debug( 'get visit details ONA:'||l_search_visits_Rec.org_name);
    AHL_DEBUG_PUB.debug( 'get visit details OID:'||l_search_visits_Rec.org_id);
    AHL_DEBUG_PUB.debug( 'inside visit detailsSP :'||l_search_visits_Rec.space_id);
    AHL_DEBUG_PUB.debug( 'inside visit detailsITEM :'||l_search_visits_Rec.item_id);
    AHL_DEBUG_PUB.debug( 'inside visit detailsITEMDES :'||l_search_visits_Rec.item_description);
	END IF;
   -- Get org id  from org name or vice versa
   IF (l_search_visits_Rec.ORG_ID IS NOT NULL AND
       l_search_visits_Rec.ORG_ID <> FND_API.G_MISS_NUM) OR
	   (l_search_visits_Rec.ORG_NAME IS NOT NULL AND
	    l_search_visits_Rec.ORG_NAME <> FND_API.G_MISS_CHAR)
	   THEN
	   --
	   OPEN l_org_id_cur(l_search_visits_Rec.ORG_ID,l_search_visits_Rec.ORG_NAME);
	   FETCH l_org_id_cur INTO l_search_visits_Rec.ORG_ID,l_search_visits_Rec.ORG_NAME;
	   IF l_org_id_cur%NOTFOUND THEN
          Fnd_Message.set_name('AHL', 'AHL_LTP_INVALID_ORG');
          Fnd_Message.Set_Token('ORG',NVL(l_search_visits_Rec.ORG_NAME,l_search_visits_Rec.ORG_ID));
          Fnd_Msg_Pub.ADD;
          CLOSE l_org_id_cur;
          RAISE Fnd_Api.G_EXC_ERROR;
		  --
	   END IF;
	   CLOSE l_org_id_cur;
	--
	END IF;
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( 'get visit details DID:'||l_search_visits_Rec.department_id);
    AHL_DEBUG_PUB.debug( 'get visit details DNA:'||l_search_visits_Rec.department_name);
    AHL_DEBUG_PUB.debug( 'get visit details OID:'||l_search_visits_Rec.org_id);
	END IF;

  -- Get Dept id  from dept name or vice versa
   IF ((l_search_visits_Rec.DEPARTMENT_ID IS NOT NULL AND
       l_search_visits_Rec.DEPARTMENT_ID <> FND_API.G_MISS_NUM) OR
	   (l_search_visits_Rec.DEPARTMENT_NAME IS NOT NULL AND
	    l_search_visits_Rec.DEPARTMENT_NAME <> FND_API.G_MISS_CHAR))
	   THEN
	   --
	   OPEN l_dept_id_cur(l_search_visits_Rec.ORG_ID,
	                      l_search_visits_Rec.department_id,
						  l_search_visits_Rec.department_name);
	   FETCH l_dept_id_cur INTO l_search_visits_Rec.department_id,
	                            l_search_visits_Rec.department_code,
	                            l_search_visits_Rec.department_name;
	   IF l_dept_id_cur%NOTFOUND THEN
          Fnd_Message.set_name('AHL', 'AHL_LTP_INVALID_DEPT');
          Fnd_Message.Set_Token('DEPT',NVL(l_search_visits_Rec.DEPARTMENT_NAME,l_search_visits_Rec.DEPARTMENT_ID));
          Fnd_Msg_Pub.ADD;
          CLOSE l_dept_id_cur;
          RAISE Fnd_Api.G_EXC_ERROR;
		  --
	   END IF;
	   CLOSE l_dept_id_cur;
	--
	END IF;
    --
     --For Space Category
      IF l_search_visits_Rec.space_category_mean IS NOT NULL AND
         l_search_visits_Rec.space_category_mean <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_LTP_SPACE_CATEGORY',
                  p_lookup_code  => NULL,
                  p_meaning      => l_search_visits_Rec.space_category_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_search_visits_Rec.space_category,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_SP_CATEGORY_NOT_EXIST');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
     ELSE
        -- Id presents
         IF l_search_visits_Rec.space_category IS NOT NULL AND
            l_search_visits_Rec.space_category <> Fnd_Api.G_MISS_CHAR
         THEN
           l_search_visits_Rec.space_category := l_search_visits_Rec.space_category;
        END IF;
     END IF;

     --For Visit type
      IF l_search_visits_Rec.visit_type_mean IS NOT NULL AND
         l_search_visits_Rec.visit_type_mean <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_PLANNING_VISIT_TYPE',
                  p_lookup_code  => NULL,
                  p_meaning      => l_search_visits_Rec.visit_type_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_search_visits_Rec.visit_type_code,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_VISIT_TYPE_INVALID');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
       ELSE
        -- Id presents
         IF l_search_visits_Rec.visit_type_code IS NOT NULL AND
            l_search_visits_Rec.visit_type_code <> Fnd_Api.G_MISS_CHAR
         THEN
           l_search_visits_Rec.visit_type_code := l_search_visits_Rec.visit_type_code;
        END IF;
      END IF;

     --For Display Period
      IF l_search_visits_Rec.display_period_mean IS NOT NULL AND
         l_search_visits_Rec.display_period_mean <> Fnd_Api.G_MISS_CHAR
         THEN
             Check_lookup_name_Or_Id (
                  p_lookup_type  => 'AHL_LTP_DISPLAY_PERIOD',
                  p_lookup_code  => NULL,
                  p_meaning      => l_search_visits_Rec.display_period_mean,
                  p_check_id_flag => 'Y',
                  x_lookup_code   => l_search_visits_Rec.display_period_code,
                  x_return_status => l_return_status);

         IF NVL(l_return_status, 'X') <> 'S'
         THEN
            Fnd_Message.SET_NAME('AHL','AHL_LTP_DISPLAY_INVALID');
            Fnd_Msg_Pub.ADD;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
     ELSE
        -- Id presents
         IF l_search_visits_Rec.display_period_code IS NOT NULL AND
            l_search_visits_Rec.display_period_code <> Fnd_Api.G_MISS_CHAR
         THEN
           l_search_visits_Rec.display_period_code := l_search_visits_Rec.display_period_code;
        END IF;
     END IF;

  --
  -- Get space id or space name
  IF ((l_search_visits_Rec.space_name IS NOT NULL AND
     l_search_visits_Rec.space_name <> FND_API.G_MISS_CHAR) OR
	 (l_search_visits_Rec.space_id IS NOT NULL AND
	 l_search_visits_Rec.space_id <> FND_API.G_MISS_NUM)) THEN
	 --
	   OPEN l_space_id_cur(l_search_visits_Rec.SPACE_ID,l_search_visits_Rec.SPACE_NAME,
	                       l_search_visits_Rec.DEPARTMENT_ID);
	   FETCH l_space_id_cur INTO l_search_visits_Rec.SPACE_ID,l_search_visits_Rec.SPACE_NAME;
	   IF l_space_id_cur%NOTFOUND THEN
          Fnd_Message.set_name('AHL', 'AHL_LTP_INVALID_SPACE');
          Fnd_Message.Set_Token('SPACE',NVL(l_search_visits_Rec.SPACE_NAME,l_search_visits_Rec.SPACE_ID));
          Fnd_Msg_Pub.ADD;
          CLOSE l_space_id_cur;
          RAISE Fnd_Api.G_EXC_ERROR;
		  --
	   END IF;
	   CLOSE l_space_id_cur;
	  --
     END IF;

      -- AnRaj: Changed the code by splitting the cursor, perf bug 5208300, index was not being hit because of OR
      IF (l_search_visits_Rec.item_description IS NOT NULL AND l_search_visits_Rec.item_description <> Fnd_Api.G_MISS_CHAR)
      THEN
         OPEN  l_item_name_cur(l_search_visits_Rec.item_description);
         FETCH l_item_name_cur INTO l_search_visits_rec.item_id,l_search_visits_rec.item_description;
         IF l_item_name_cur%NOTFOUND THEN
            Fnd_Message.set_name('AHL', 'AHL_LTP_ITEM_NOT_EXIST');
            Fnd_Message.Set_Token('ITEM',NVL(l_search_visits_Rec.ITEM_DESCRIPTION,l_search_visits_Rec.ITEM_ID));
            Fnd_Msg_Pub.ADD;
            CLOSE l_item_name_cur;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
         CLOSE l_item_name_cur;
      END IF;

      IF (l_search_visits_Rec.item_id IS NOT NULL AND l_search_visits_Rec.item_id <> Fnd_Api.G_MISS_NUM)
      THEN
         OPEN l_item_id_cur (l_search_visits_Rec.item_id);
         FETCH l_item_id_cur INTO l_search_visits_rec.item_id,l_search_visits_rec.item_description;
		   IF l_item_id_cur%NOTFOUND THEN
            Fnd_Message.set_name('AHL', 'AHL_LTP_ITEM_NOT_EXIST');
            Fnd_Message.Set_Token('ITEM',NVL(l_search_visits_Rec.ITEM_DESCRIPTION,l_search_visits_Rec.ITEM_ID));
            Fnd_Msg_Pub.ADD;
            CLOSE l_item_id_cur;
            RAISE Fnd_Api.G_EXC_ERROR;
         END IF;
		   CLOSE l_item_id_cur;
      END IF;
      -- AnRaj: Bug fix for 5208300 end.

  --Get plan id
   OPEN get_plan_id_cur(l_search_visits_Rec.plan_id);
   FETCH get_plan_id_cur INTO l_search_visits_Rec.plan_id,l_plan_flag;
     IF get_plan_id_cur%NOTFOUND THEN
        Fnd_Message.set_name('AHL', 'AHL_LTP_INVALID_PLAN');
        Fnd_Msg_Pub.ADD;
      CLOSE get_plan_id_cur;
      RAISE Fnd_Api.G_EXC_ERROR;
     END IF;
    CLOSE get_plan_id_cur;
    --Assign dates
	l_start_period := trunc(l_search_visits_Rec.start_period);
	l_end_period   := trunc(l_search_visits_Rec.end_period);
	--
   IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.debug( ' SPACEID:'||l_search_visits_Rec.space_id);
    AHL_DEBUG_PUB.debug( ' ORGID:'||l_search_visits_Rec.org_id);
    AHL_DEBUG_PUB.debug( ' DEPTID:'||l_search_visits_Rec.department_id);
    AHL_DEBUG_PUB.debug( ' VISITTYPE:'||l_search_visits_Rec.visit_type_code);
    AHL_DEBUG_PUB.debug( ' ITEMID:'||l_search_visits_Rec.item_id);
    AHL_DEBUG_PUB.debug( ' PLANID:'||l_search_visits_Rec.plan_id);
    AHL_DEBUG_PUB.debug( 'STARTPERIOD:'||l_start_period);
    AHL_DEBUG_PUB.debug( 'ENDPERIOD:'||l_end_period);
  END IF;
	----------------- To get the visit If space id is available
 IF l_search_visits_Rec.SPACE_ID IS NOT NULL
   THEN
     -- For space id
      OPEN get_visit_detail_cur(l_search_visits_Rec.SPACE_ID,
	                            l_search_visits_Rec.visit_type_code,
								l_search_visits_Rec.item_id);
      i := 0;
      LOOP
      FETCH get_visit_detail_cur INTO  l_get_visit_detail_rec;
      EXIT WHEN get_visit_detail_cur%NOTFOUND;

     IF get_visit_detail_cur%FOUND THEN
    --If close end date  ecists then consider it else derived end date
	IF l_get_visit_detail_rec.close_date_time IS NOT NULL
	  THEN
       l_visit_end_date := l_get_visit_detail_rec.close_date_time;
	   ELSE
       l_visit_end_date := l_get_visit_detail_rec.start_date_time;
	  END IF;

    IF l_plan_flag = 'Y' THEN

   IF G_DEBUG='Y' THEN
      AHL_DEBUG_PUB.debug( 'after plan flag y visit id:'||l_get_visit_detail_rec.visit_id ||'-'||i);
      AHL_DEBUG_PUB.debug( 'after plan flag y start period:'||l_start_period ||'-'||i);
      AHL_DEBUG_PUB.debug( 'after plan flag y end period:'||l_end_period ||'-'||i);
      AHL_DEBUG_PUB.debug( 'after plan flag y visit end date:'||l_visit_end_date ||'-'||i);
      AHL_DEBUG_PUB.debug( 'after plan flag y visit start date:'||l_get_visit_detail_rec.start_date_time ||'-'||i);

   END IF;

           OPEN visit_wd_detail_cur(l_search_visits_Rec.plan_id,
                                    l_get_visit_detail_rec.visit_id,
                                    l_start_period,l_end_period,
                                    trunc(nvl(l_visit_end_date, l_get_visit_detail_rec.start_date_time)));
           FETCH visit_wd_detail_cur INTO   l_visit_wd_detail_rec;
           --
           IF  visit_wd_detail_cur%FOUND THEN
		   --Check for visit has been assigned to multiple spaces
		    select count(*) into l_count from ahl_space_assignments
			  where visit_id = l_visit_wd_detail_rec.visit_id;
			--Get plan flag
			SELECT primary_plan_flag INTO x_visit_details_tbl(i).plan_flag
			     FROM ahl_simulation_plans_vl
				 WHERE simulation_plan_id =  l_visit_wd_detail_rec.simulation_plan_id;
			--
           x_visit_details_tbl(i).visit_number     := l_visit_wd_detail_rec.visit_number;
           x_visit_details_tbl(i).visit_type       := l_visit_wd_detail_rec.visit_type_mean;
           x_visit_details_tbl(i).visit_name       := l_visit_wd_detail_rec.visit_name;
           x_visit_details_tbl(i).visit_id         := l_visit_wd_detail_rec.visit_id;
           x_visit_details_tbl(i).visit_status     := l_visit_wd_detail_rec.status_code;
           x_visit_details_tbl(i).unit_name        := l_visit_wd_detail_rec.unit_name;
           x_visit_details_tbl(i).item_description := l_visit_wd_detail_rec.item_description;
           x_visit_details_tbl(i).serial_number    := l_visit_wd_detail_rec.serial_number;
           x_visit_details_tbl(i).start_date       := l_visit_wd_detail_rec.start_date_time;
           x_visit_details_tbl(i).end_date         := l_visit_wd_detail_rec.close_date_time;
           x_visit_details_tbl(i).due_by           := l_visit_wd_detail_rec.due_by;
		   --
           IF l_count = 1 then
              x_visit_details_tbl(i).yes_no_type      := 'No';
			ELSE
              x_visit_details_tbl(i).yes_no_type      := 'Yes';
            END IF;
			--
           END IF;
          CLOSE visit_wd_detail_cur;
         END IF;
          i := i+1;
     END IF;
       END LOOP;
      CLOSE get_visit_detail_cur;

     --Simulation plan visits and primary visits not associated to simlation plan
      OPEN get_visit_detail_cur(l_search_visits_Rec.space_id,
	                            l_search_visits_Rec.visit_type_code,
								l_search_visits_Rec.item_id);
      i := 0;
      LOOP
      FETCH get_visit_detail_cur INTO  l_get_visit_detail_rec;
      EXIT WHEN get_visit_detail_cur%NOTFOUND;
       IF get_visit_detail_cur%FOUND THEN
   IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'visit details start period:'||l_start_period||'-'||i);
  AHL_DEBUG_PUB.debug( 'visit details end period:'||l_end_period||'-'||i);
  END IF;
     IF l_get_visit_detail_rec.close_date_time IS NOT NULL THEN
	    l_visit_end_date := l_get_visit_detail_rec.close_date_time;
		ELSE
	    l_visit_end_date := l_get_visit_detail_rec.start_date_time;
	 END IF;

          IF l_plan_flag = 'N' THEN
           --primary visits not associated simulation plan
           OPEN visit_wd1_detail_cur(l_search_visits_Rec.plan_id,
                                    l_get_visit_detail_rec.visit_id,
                                    l_start_period,l_end_period,
                                    trunc(nvl(l_visit_end_date, l_get_visit_detail_rec.start_date_time)));
           FETCH visit_wd1_detail_cur INTO   l_visit_wd1_detail_rec;
           IF  visit_wd1_detail_cur%FOUND THEN
		   --Check for visit has been assigned to multiple spaces
		    select count(*) into l_count from ahl_space_assignments
			  where visit_id = l_visit_wd1_detail_rec.visit_id;
			--Get plan flag
			SELECT primary_plan_flag INTO x_visit_details_tbl(i).plan_flag
			     FROM ahl_simulation_plans_vl
				 WHERE simulation_plan_id =  l_visit_wd1_detail_rec.simulation_plan_id;
			--
           x_visit_details_tbl(i).visit_number     := l_visit_wd1_detail_rec.visit_number;
           x_visit_details_tbl(i).visit_type       := l_visit_wd1_detail_rec.visit_type_mean;
           x_visit_details_tbl(i).visit_id         := l_visit_wd1_detail_rec.visit_id;
           x_visit_details_tbl(i).visit_status     := l_visit_wd1_detail_rec.status_code;
           x_visit_details_tbl(i).item_description := l_visit_wd1_detail_rec.item_description;
           x_visit_details_tbl(i).visit_name       := l_visit_wd1_detail_rec.visit_name;
           x_visit_details_tbl(i).unit_name        := l_visit_wd1_detail_rec.unit_name;
           x_visit_details_tbl(i).serial_number    := l_visit_wd1_detail_rec.serial_number;
           x_visit_details_tbl(i).start_date       := l_visit_wd1_detail_rec.start_date_time;
           x_visit_details_tbl(i).end_date         := l_visit_wd1_detail_rec.close_date_time;
           x_visit_details_tbl(i).due_by           := l_visit_wd1_detail_rec.due_by;
           IF l_count = 1 then
              x_visit_details_tbl(i).yes_no_type      := 'No';
			ELSE
              x_visit_details_tbl(i).yes_no_type      := 'Yes';
            END IF;

           END IF;
           CLOSE visit_wd1_detail_cur;
           -- simulated visits
           OPEN visit_wd_detail_cur(l_search_visits_Rec.plan_id,
                                    l_get_visit_detail_rec.visit_id,
                                    l_start_period,l_end_period,
                                    trunc(nvl(l_visit_end_date, l_get_visit_detail_rec.start_date_time)));
           FETCH visit_wd_detail_cur INTO   l_visit_wd_detail_rec;
           --
           IF  visit_wd_detail_cur%FOUND THEN
		   --Check for visit has been assigned to multiple spaces
		    select count(*) into l_count from ahl_space_assignments
			  where visit_id = l_visit_wd_detail_rec.visit_id;
			--Get plan flag
			SELECT primary_plan_flag INTO x_visit_details_tbl(i).plan_flag
			     FROM ahl_simulation_plans_vl
				 WHERE simulation_plan_id =  l_visit_wd_detail_rec.simulation_plan_id;
			--
           x_visit_details_tbl(i).visit_number     := l_visit_wd_detail_rec.visit_number;
           x_visit_details_tbl(i).visit_type       := l_visit_wd_detail_rec.visit_type_mean;
           x_visit_details_tbl(i).visit_id         := l_visit_wd_detail_rec.visit_id;
           x_visit_details_tbl(i).visit_status     := l_visit_wd_detail_rec.status_code;
           x_visit_details_tbl(i).item_description := l_visit_wd_detail_rec.item_description;
           x_visit_details_tbl(i).visit_name       := l_visit_wd_detail_rec.visit_name;
           x_visit_details_tbl(i).unit_name        := l_visit_wd_detail_rec.unit_name;
           x_visit_details_tbl(i).serial_number    := l_visit_wd_detail_rec.serial_number;
           x_visit_details_tbl(i).start_date       := l_visit_wd_detail_rec.start_date_time;
           x_visit_details_tbl(i).end_date         := l_visit_wd_detail_rec.close_date_time;
           x_visit_details_tbl(i).due_by           := l_visit_wd_detail_rec.due_by;

           IF l_count = 1 then
              x_visit_details_tbl(i).yes_no_type      := 'No';
			ELSE
              x_visit_details_tbl(i).yes_no_type      := 'Yes';
            END IF;

           END IF;
          CLOSE visit_wd_detail_cur;
           --
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'visit number:'||l_visit_wd1_detail_rec.visit_number);
	END IF;
	--
    END IF;
          i := i+1;
      END IF;

       END LOOP;
      CLOSE get_visit_detail_cur;
 END IF;
----------------- To get the visits If Department id is available
 IF (l_search_visits_Rec.DEPARTMENT_ID IS NOT NULL AND
     l_search_visits_Rec.SPACE_ID IS NULL )
   THEN
     -- For space id
      OPEN visit_dept_cur(l_search_visits_Rec.DEPARTMENT_ID,
	                      l_search_visits_Rec.visit_type_code,
						  l_search_visits_Rec.item_id);
      i := 0;
      LOOP
      FETCH visit_dept_cur INTO  l_visit_dept_rec;
      EXIT WHEN visit_dept_cur%NOTFOUND;
       IF visit_dept_cur%FOUND THEN
     IF l_visit_dept_rec.close_date_time IS NOT NULL THEN
	    l_visit_end_date := l_visit_dept_rec.close_date_time;
		ELSE
	    l_visit_end_date := l_visit_dept_rec.start_date_time;
	 END IF;

       IF l_plan_flag = 'Y' THEN
          --
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'after plan flag y dept.plan_id:'||l_search_visits_Rec.plan_id ||'-'||i);
     AHL_DEBUG_PUB.debug( 'after plan flag y dept.visit_id:'||l_visit_dept_rec.visit_id ||'-'||i);
     AHL_DEBUG_PUB.debug( 'after plan flag y dept display start_period:'||l_start_period ||'-'||i);
     AHL_DEBUG_PUB.debug( 'after plan flag y dept diaplay end_period:'||l_end_period ||'-'||i);
     AHL_DEBUG_PUB.debug( 'after plan flag y dept visit_end_date:'||l_visit_end_date ||'-'||i);
     AHL_DEBUG_PUB.debug( 'after plan flag y dept visit start_date:'||l_visit_dept_rec.start_date_time ||'-'||i);
  END IF;

		  --

           OPEN visit_wd_detail_cur(l_search_visits_Rec.plan_id,
                                    l_visit_dept_rec.visit_id,
                                    l_start_period,l_end_period,
                                    trunc(nvl(l_visit_end_date, l_visit_dept_rec.start_date_time)));
           FETCH visit_wd_detail_cur INTO   l_visit_wd_detail_rec;
           --
           IF  visit_wd_detail_cur%FOUND THEN
           --Get plan flag
           SELECT primary_plan_flag INTO x_visit_details_tbl(i).plan_flag
                    FROM ahl_simulation_plans_vl
           WHERE simulation_plan_id =  l_visit_wd_detail_rec.simulation_plan_id;
			--
           x_visit_details_tbl(i).visit_number     := l_visit_wd_detail_rec.visit_number;
           x_visit_details_tbl(i).visit_type       := l_visit_wd_detail_rec.visit_type_mean;
           x_visit_details_tbl(i).visit_name       := l_visit_wd_detail_rec.visit_name;
           x_visit_details_tbl(i).visit_id         := l_visit_wd_detail_rec.visit_id;
           x_visit_details_tbl(i).visit_status     := l_visit_wd_detail_rec.status_code;
           x_visit_details_tbl(i).unit_name       := l_visit_wd_detail_rec.unit_name;
           x_visit_details_tbl(i).item_description := l_visit_wd_detail_rec.item_description;
           x_visit_details_tbl(i).serial_number    := l_visit_wd_detail_rec.serial_number;
           x_visit_details_tbl(i).start_date       := l_visit_wd_detail_rec.start_date_time;
           x_visit_details_tbl(i).end_date         := l_visit_wd_detail_rec.close_date_time;
           x_visit_details_tbl(i).due_by           := l_visit_wd_detail_rec.due_by;

           END IF;
          CLOSE visit_wd_detail_cur;
         END IF;


          i := i+1;
     END IF;
       END LOOP;
      CLOSE visit_dept_cur;

     --Simulation plan visits and primary visits not associated to simlation plan
      OPEN get_visit_dept_cur(l_search_visits_Rec.department_id,
	                          l_search_visits_Rec.visit_type_code,
							  l_search_visits_Rec.item_id);
      i := 0;
      LOOP
      FETCH get_visit_dept_cur INTO  l_get_visit_dept_rec;
      EXIT WHEN get_visit_dept_cur%NOTFOUND;
       IF get_visit_dept_cur%FOUND THEN
  IF G_DEBUG='Y' THEN
  AHL_DEBUG_PUB.debug( 'visit details start period:'||l_start_period||'-'||i);
  AHL_DEBUG_PUB.debug( 'visit details end period:'||l_end_period||'-'||i);
  END IF;

     IF l_get_visit_dept_rec.close_date_time IS NOT NULL THEN
	    l_visit_end_date := l_get_visit_dept_rec.close_date_time;
		ELSE
	    l_visit_end_date := l_get_visit_dept_rec.start_date_time;
	 END IF;

		  IF l_plan_flag = 'N' THEN
           --primary visits not associated simulation plan
           OPEN visit_wd1_detail_cur(l_search_visits_Rec.plan_id,
                                    l_get_visit_dept_rec.visit_id,
                                    l_start_period,l_end_period,
                                    trunc(nvl(l_visit_end_date, l_get_visit_dept_rec.start_date_time)));
           FETCH visit_wd1_detail_cur INTO   l_visit_wd1_detail_rec;
           IF  visit_wd1_detail_cur%FOUND THEN
			--Get plan flag
			SELECT primary_plan_flag INTO x_visit_details_tbl(i).plan_flag
			     FROM ahl_simulation_plans_vl
				 WHERE simulation_plan_id =  l_visit_wd1_detail_rec.simulation_plan_id;
			--
           x_visit_details_tbl(i).visit_number     := l_visit_wd1_detail_rec.visit_number;
           x_visit_details_tbl(i).visit_type       := l_visit_wd1_detail_rec.visit_type_mean;
           x_visit_details_tbl(i).item_description := l_visit_wd1_detail_rec.item_description;
           x_visit_details_tbl(i).visit_id         := l_visit_wd1_detail_rec.visit_id;
           x_visit_details_tbl(i).visit_status     := l_visit_wd1_detail_rec.status_code;
           x_visit_details_tbl(i).visit_name       := l_visit_wd1_detail_rec.visit_name;
           x_visit_details_tbl(i).unit_name        := l_visit_wd1_detail_rec.unit_name;
           x_visit_details_tbl(i).serial_number    := l_visit_wd1_detail_rec.serial_number;
           x_visit_details_tbl(i).start_date       := l_visit_wd1_detail_rec.start_date_time;
           x_visit_details_tbl(i).end_date         := l_visit_wd1_detail_rec.close_date_time;
           x_visit_details_tbl(i).due_by           := l_visit_wd1_detail_rec.due_by;
           END IF;
           CLOSE visit_wd1_detail_cur;
           -- simulated visits
           OPEN visit_wd_detail_cur(l_search_visits_Rec.plan_id,
                                    l_get_visit_dept_rec.visit_id,
                                    l_start_period,l_end_period,
                                    trunc(nvl(l_visit_end_date, l_get_visit_dept_rec.start_date_time)));
           FETCH visit_wd_detail_cur INTO   l_visit_wd_detail_rec;
           --
           IF  visit_wd_detail_cur%FOUND THEN
           --Get plan flag
		   SELECT primary_plan_flag INTO x_visit_details_tbl(i).plan_flag
			    FROM ahl_simulation_plans_vl
 		 WHERE simulation_plan_id =  l_visit_wd_detail_rec.simulation_plan_id;
			--
           x_visit_details_tbl(i).visit_number     := l_visit_wd_detail_rec.visit_number;
           x_visit_details_tbl(i).visit_type       := l_visit_wd_detail_rec.visit_type_mean;
           x_visit_details_tbl(i).item_description := l_visit_wd_detail_rec.item_description;
           x_visit_details_tbl(i).visit_id         := l_visit_wd_detail_rec.visit_id;
           x_visit_details_tbl(i).visit_status     := l_visit_wd_detail_rec.status_code;
           x_visit_details_tbl(i).visit_name       := l_visit_wd_detail_rec.visit_name;
           x_visit_details_tbl(i).unit_name        := l_visit_wd_detail_rec.unit_name;
           x_visit_details_tbl(i).serial_number    := l_visit_wd_detail_rec.serial_number;
           x_visit_details_tbl(i).start_date       := l_visit_wd_detail_rec.start_date_time;
           x_visit_details_tbl(i).end_date         := l_visit_wd_detail_rec.close_date_time;
           x_visit_details_tbl(i).due_by           := l_visit_wd_detail_rec.due_by;

           END IF;
          CLOSE visit_wd_detail_cur;
           --
   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'visit number:'||l_visit_wd1_detail_rec.visit_number);
   END IF;
	--
    END IF;
          i := i+1;
      END IF;

       END LOOP;
      CLOSE get_visit_dept_cur;
 END IF;
 -----

   IF G_DEBUG='Y' THEN
     AHL_DEBUG_PUB.debug( 'total records:'||x_visit_details_tbl.count);
   END IF;

  --Standard check to count messages
   l_msg_count := Fnd_Msg_Pub.count_msg;

   IF l_msg_count > 0 THEN
      X_msg_count := l_msg_count;
      X_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
      RAISE Fnd_Api.G_EXC_ERROR;
   END IF;
   -- Debug info
   IF G_DEBUG='Y' THEN
   Ahl_Debug_Pub.debug( 'End of private api Get visit details','+SPSL+');
   -- Check if API is called in debug mode. If yes, disable debug.
   Ahl_Debug_Pub.disable_debug;
   --
   END IF;

  EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Get_visit_details;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => x_msg_data);
   IF G_DEBUG='Y' THEN

        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Get visit details','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
   END IF;

WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Get_visit_details;
    X_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'UNEXPECTED ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt. Derive visit end date','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;
    END IF;
WHEN OTHERS THEN
    ROLLBACK TO Get_visit_details;
    X_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
    fnd_msg_pub.add_exc_msg(p_pkg_name        =>  'AHL_LTP_SPACE_SCHEDULE_PVT',
                            p_procedure_name  =>  'GET_VISIT_DETAILS',
                            p_error_text      => SUBSTR(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get( p_encoded => FND_API.G_FALSE,
                               p_count => x_msg_count,
                               p_data  => X_msg_data);
   IF G_DEBUG='Y' THEN

        -- Debug info.
        AHL_DEBUG_PUB.log_app_messages (
             x_msg_count, x_msg_data, 'SQL ERROR' );
        AHL_DEBUG_PUB.debug( 'ahl_ltp_space_schedule_pvt Get visit details','+SPSL+');
        -- Check if API is called in debug mode. If yes, disable debug.
        AHL_DEBUG_PUB.disable_debug;

   END IF;
 END Get_Visit_Details;
--To Get derived end date
FUNCTION get_derived_end_date
         (p_visit_id   NUMBER)

RETURN DATE IS

  CURSOR get_visit_cur (c_visit_id IN NUMBER)
  IS
   SELECT start_date_time
      FROM AHL_VISITS_B
    WHERE visit_id = c_visit_id;

  CURSOR get_task_end_cur (c_visit_id IN NUMBER)
     IS
   SELECT max(end_date_time)
     FROM ahl_visit_tasks_vl
    WHERE visit_id = c_visit_id;

  l_start_date_time          DATE;
  l_visit_end_time           DATE;
  --
BEGIN
  --
  IF G_DEBUG='Y' THEN
    AHL_DEBUG_PUB.enable_debug;
    AHL_DEBUG_PUB.debug( 'enter ahl_ltp_space_schedule_pvt Get derived end date','+SPSL+');
  END IF;
  --
  IF (p_visit_id IS NOT NULL AND p_visit_id <> FND_API.G_MISS_NUM )THEN
     OPEN get_visit_cur(p_visit_id);
     FETCH get_visit_cur INTO l_start_date_time;
     CLOSE get_visit_cur;
   IF l_start_date_time IS NOT NULL THEN
     --
	  OPEN get_task_end_cur(p_visit_id);
	  FETCH get_task_end_cur INTO l_visit_end_time;
	  CLOSE get_task_end_cur;
	END IF;
   END IF;

   IF G_DEBUG='Y' THEN
   AHL_DEBUG_PUB.debug( 'visit end time'||l_visit_end_time);
   END IF;
   --
   RETURN l_visit_end_time;
--
END get_derived_end_date;
--
END AHL_LTP_SPACE_SCHEDULE_PVT;

/
