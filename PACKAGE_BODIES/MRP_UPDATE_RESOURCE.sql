--------------------------------------------------------
--  DDL for Package Body MRP_UPDATE_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_UPDATE_RESOURCE" AS
/* $Header: MRPFCAVB.pls 115.6 99/07/16 12:20:37 porting shi $ */

TYPE ResRecTyp IS RECORD (
	OPERATION				 NUMBER,
	ORGANIZATION_ID				 NUMBER,
	LINE_ID					 NUMBER,
	DEPARTMENT_ID				 NUMBER,
	RESOURCE_ID				 NUMBER,
 	RESOURCE_HOURS                           NUMBER,
 	MAX_RATE                                 NUMBER,
 	RESOURCE_UNITS                           NUMBER,
 	STATUS                                   NUMBER,
 	APPLIED                                  NUMBER,
 	RESOURCE_START_DATE            		 DATE,
 	RESOURCE_END_DATE                        DATE,
 	UPDATED                          	 NUMBER,
 	LAST_UPDATE_DATE                 	 DATE,
 	LAST_UPDATED_BY                  	 NUMBER,
 	CREATION_DATE                   	 DATE,
 	CREATED_BY                       	 NUMBER,
 	LAST_UPDATE_LOGIN                        NUMBER);

TYPE ResTabTyp IS TABLE OF ResRecTyp
	INDEX by binary_integer;

g_resource_exist        boolean;
g_error_stat		VARCHAR2(300);
g_compile_designator    VARCHAR2(20);
g_simulation_set	VARCHAR2(10);
g_res_group		VARCHAR2(30);
g_cutoff_date		DATE;
g_query_id		NUMBER:=0;
g_org_id		NUMBER:=0;
g_department_id		NUMBER:=0;
g_line_id		NUMBER:=0;
g_resource_id		NUMBER:=0;
g_change_rec 		ResRecTyp;
g_res_tab		ResTabTyp;
g_tmp_tab		ResTabTyp;
i 			binary_integer;
j                       binary_integer;
k 			binary_integer;
OP_ADD_DAY		CONSTANT INTEGER :=0;
OP_ADD                  CONSTANT INTEGER :=1;
OP_DEL                  CONSTANT INTEGER :=2;
OP_SET			CONSTANT INTEGER :=3;
OP_DEL_DAY		CONSTANT INTEGER :=4;

-- Cursor used to apply simulation for Calculate Resource Supply for ATP
CURSOR C_BRC IS
	SELECT
			DECODE(brc.action_type,1,OP_DEL_DAY,3,OP_ADD_DAY,
				DECODE(sign(brc.capacity_change),-1,
				OP_DEL,OP_ADD)),
			dept.organization_id,
			NULL,
			bdr.department_id,
			bdr.resource_id,
			decode(brc.action_type,1,
				(nvl(sum(decode(bdr.available_24_hours_flag,
				1,24,2,
				((decode(least(shifts.to_time,shifts.from_time),
				shifts.to_time,shifts.to_time + 24*3600,
				shifts.to_time) - shifts.from_time)/3600))),0)),
				(decode(least(nvl(brc.from_time,0),
				nvl(brc.to_time,1)),
				nvl(brc.to_time,1),
				24 * 3600 + nvl(brc.to_time,1),
				nvl(brc.to_time,1)) -
				nvl(brc.from_time,0))/3600),
			NULL,
			decode(brc.action_type,1,bdr.capacity_units,
				abs(brc.capacity_change)),
			0,
			NULL,
			decode(brc.action_type,3,cal.prior_date,brc.from_date),
			decode(brc.action_type,2,nvl(brc.to_date,g_cutoff_date),
				3,cal.prior_date,brc.from_date),
			2,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			SYSDATE,
			FND_GLOBAL.USER_ID,
			FND_GLOBAL.LOGIN_ID
	FROM 	bom_resources res,
		bom_departments dept,
		bom_shift_times shifts,
		mtl_parameters mp,
	 	bom_calendar_dates cal,
		bom_department_resources bdr,
		bom_resource_changes brc
	WHERE	res.organization_id = dept.organization_id
	AND	bdr.resource_id = res.resource_id
	AND	dept.organization_id = g_org_id
	AND	NVL(bdr.share_from_dept_id,bdr.department_id)
			= dept.department_id
	AND	share_from_dept_id is null
	AND	brc.shift_num = shifts.shift_num(+)
	AND	(mp.calendar_code = shifts.calendar_code
		OR shifts.calendar_code IS NULL)
	AND	mp.organization_id = dept.organization_id
	AND	cal.calendar_date = brc.from_date
	AND 	cal.exception_set_id = mp.calendar_exception_set_id
	AND	cal.calendar_code = mp.calendar_code
	AND	bdr.ctp_flag = 1
	AND	nvl(bdr.resource_group_name,'-1') =
			nvl(g_res_group,nvl(bdr.resource_group_name,'-1'))
	AND	brc.department_id = bdr.department_id
	AND	brc.resource_id = bdr.resource_id
	AND	brc.simulation_set = g_simulation_set
        AND     (brc.from_date >= trunc(sysdate)
		OR brc.to_date >= trunc(sysdate))
	GROUP BY '-1',dept.organization_id, bdr.department_id, bdr.resource_id,
		brc.action_type, brc.to_time, brc.from_time, bdr.capacity_units,
		brc.capacity_change, brc.from_date, cal.prior_date, brc.to_date,
		brc.shift_num;


CURSOR C_MFQ IS
       SELECT
			NUMBER1,
			NUMBER2,
			NUMBER3,
			NUMBER4,
			NUMBER5,
                        nvl(NUMBER6,0),
                        nvl(NUMBER7,0),
                        nvl(NUMBER8,0),
			0,
			2,
                        DATE1,
                        DATE2,
			2,
                        LAST_UPDATE_DATE,
                        LAST_UPDATED_BY,
                        CREATION_DATE,
                        CREATED_BY,
                        LAST_UPDATE_LOGIN
	FROM MRP_FORM_QUERY
	WHERE query_id = g_query_id
	ORDER BY number2, number3, number4, number5, number1;

CURSOR C_CAR  IS
       SELECT
	      0,
	      organization_id,
	      line_id,
	      department_id,
	      resource_id,
              decode(line_id, null, resource_hours,1),
              nvl(max_rate,0),
              nvl(resource_units,0),
	      status,
   	      applied,
              resource_start_date,
              resource_end_date,
              updated,
 	LAST_UPDATE_DATE,
        LAST_UPDATED_BY,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN
        FROM  CRP_AVAILABLE_RESOURCES
        WHERE (compile_designator=g_compile_designator)
	AND (organization_id = g_org_id)
        AND (    (line_id = g_line_id)
        	OR (  (line_id IS NULL) AND (g_line_id IS NULL)))
        AND (    (department_id = g_department_id)
                 OR (  (department_id IS NULL) AND (g_department_id IS NULL)))
        AND (    (resource_id = g_resource_id)
                 OR (  (resource_id IS NULL) AND (g_resource_id IS NULL)))
	order by resource_start_date;

---------------------------------------------------------------
-- apply simulation
-- used by calculate resource supply for ATP
---------------------------------------------------------------
PROCEDURE apply_simulation(p_org_id IN NUMBER,
			   p_res_group IN VARCHAR2,
			   p_simulation_set IN VARCHAR2,
			   p_cutoff_date IN VARCHAR2)
IS
   first_record		BOOLEAN :=TRUE;
   changed_resource	BOOLEAN :=TRUE;
BEGIN
   g_compile_designator := '-1';
   g_org_id := p_org_id;
   g_res_group := p_res_group;
   g_simulation_set := p_simulation_set;
   g_cutoff_date := to_date(p_cutoff_date,'YYYY/MM/DD HH24:MI:SS');
   g_department_id         :=0;
   g_line_id               :=0;
   g_resource_id           :=0;

  -- load the simulation changes, if there are changes then
  -- re-query data from crp_available_resources

   OPEN C_BRC;
   LOOP
	FETCH C_BRC INTO g_change_rec;
	IF C_BRC%NOTFOUND THEN
	   IF not first_record THEN
	      update_table;
	   END IF;
           CLOSE C_BRC;
	   commit;
	   exit;
	END IF;

        IF    (g_change_rec.organization_id = g_org_id )
       	   AND (    (g_change_rec.line_id = g_line_id)
               	OR (  (g_change_rec.line_id IS NULL) AND (g_line_id IS NULL)))
           AND (    (g_change_rec.department_id = g_department_id)
               	OR (  (g_change_rec.department_id IS NULL)
			AND (g_department_id IS NULL)))
           AND (    (g_change_rec.resource_id = g_resource_id)
                 OR (  (g_change_rec.resource_id IS NULL)
			AND (g_resource_id IS NULL))) THEN

            changed_resource :=FALSE;
        ELSE

            changed_resource :=TRUE;
        END IF;


	IF changed_resource THEN

	   IF not first_record THEN
	   -- update the change for the previous resource
	      update_table;
	   END IF;

           g_org_id :=g_change_rec.organization_id;
           g_department_id :=g_change_rec.department_id;
           g_resource_id :=g_change_rec.resource_id;
           g_line_id :=g_change_rec.line_id;

	   -- initialize the table for next resource
	   initialize_table;

	END IF;

   	calculate_change;
        first_record :=FALSE;

   END LOOP;
EXCEPTION when others THEN
   IF (C_BRC%ISOPEN) THEN
	close C_BRC;
   END IF;
END apply_simulation;

---------------------------------------------------------------
-- apply change
---------------------------------------------------------------
PROCEDURE apply_change( p_query_id IN NUMBER,
			p_compile_designator IN VARCHAR2 ) IS
   first_record		BOOLEAN :=TRUE;
   changed_resource	BOOLEAN :=TRUE;
BEGIN
   g_compile_designator :=p_compile_designator;
   g_query_id := p_query_id;
   g_org_id                :=0;
   g_department_id         :=0;
   g_line_id               :=0;
   g_resource_id           :=0;


  -- load from mrp_form_query for the changes, if the resource changes
  -- re-query data from crp_available_resources

   OPEN C_MFQ;
   LOOP
        FETCH C_MFQ INTO g_change_rec;

	IF C_MFQ%NOTFOUND THEN
	   IF not first_record THEN
	      update_table;
	   END IF;
           CLOSE C_MFQ;
	   commit;
	   exit;
	END IF;

        IF    (g_change_rec.organization_id = g_org_id )
       	   AND (    (g_change_rec.line_id = g_line_id)
               	OR (  (g_change_rec.line_id IS NULL) AND (g_line_id IS NULL)))
           AND (    (g_change_rec.department_id = g_department_id)
               	OR (  (g_change_rec.department_id IS NULL)
			AND (g_department_id IS NULL)))
           AND (    (g_change_rec.resource_id = g_resource_id)
                 OR (  (g_change_rec.resource_id IS NULL)
			AND (g_resource_id IS NULL))) THEN

            changed_resource :=FALSE;
        ELSE

            changed_resource :=TRUE;
        END IF;


	IF changed_resource THEN

	   IF not first_record THEN
	   -- update the change for the previous resource
	      update_table;
	   END IF;

           g_org_id :=g_change_rec.organization_id;
           g_department_id :=g_change_rec.department_id;
           g_resource_id :=g_change_rec.resource_id;
           g_line_id :=g_change_rec.line_id;

	   -- initialize the table for next resource
	   initialize_table;

	END IF;

   	calculate_change;

        first_record :=FALSE;

   END LOOP;
EXCEPTION when others THEN

   IF (C_MFQ%ISOPEN) THEN
	close C_MFQ;
   END IF;
   raise_application_error(-20000, sqlerrm);
END apply_change;

---------------------------------------------------------------------
-- to get the values into PL/SQL tables
---------------------------------------------------------------------
PROCEDURE initialize_table IS
BEGIN

   -- load from crp_available_resources for all the records
   -- related to the same resource
   j :=0;
   g_res_tab.delete;
   OPEN C_CAR;
   LOOP
	   j := j+1;
	   FETCH C_CAR INTO g_res_tab(j);
	   if C_CAR%NOTFOUND then
             if C_CAR%ROWCOUNT=0 then
               g_resource_exist :=false;
             end if;
             exit;
           end if;

   END LOOP;
   IF C_CAR%ROWCOUNT >0 THEN
     g_resource_exist :=true;
   END IF;
   CLOSE C_CAR;
EXCEPTION WHEN others THEN
  IF (C_CAR%ISOPEN) THEN
	close C_CAR;
  END IF;

END initialize_table;

---------------------------------------------------------------------
-- to
---------------------------------------------------------------------
PROCEDURE calculate_change IS
v_start_record 		number;
v_end_record            number;

BEGIN

IF g_resource_exist THEN
-- try to find which records in res_tab are affected by the change

    -- try to find which record the change start date falls

 j:=g_res_tab.FIRST;
 IF (g_change_rec.resource_start_date <
	g_res_tab(j).resource_start_date ) THEN
     -- the change record starts before the range
	v_start_record :=0;
 ELSE
    --find the first record whose start date is greater than change's start date
    --then the previous record will be where the change starts
	While (j is not null) and
	   (    g_change_rec.resource_start_date >=
		g_res_tab(j).resource_start_date    )
	LOOP
	   j:=g_res_tab.next(j);
	END LOOP;
   IF j is null THEN
	-- if j is null, then the change is on or outside the last record
	i :=g_res_tab.LAST;
	IF ( g_res_tab(i).resource_end_date is null ) THEN
	   v_start_record :=g_res_tab.LAST;
	   v_end_record :=g_res_tab.LAST;
	ELSE
	  IF (g_change_rec.resource_start_date <=
		g_res_tab(i).resource_end_date ) THEN
	        v_start_record :=g_res_tab.LAST;
           	v_end_record :=g_res_tab.LAST;
	   ELSE
	  	v_start_record :=g_res_tab.LAST+1;
          	v_end_record :=g_res_tab.LAST+1;

	   END IF;
	END IF;
   ELSE
	-- otherwise, the change is inside the range
	-- but it could be on a record or in a gap between two records
	IF (g_change_rec.resource_start_date <=
                g_res_tab(j-1).resource_end_date ) THEN
	--change falls on the previos record
		v_start_record := j-1;
	ELSE
	--change falls on the gap between record j-1 and record j
		v_start_record := j-0.5;
	END IF;
	--go to the previous record to find where change ends
	j:=j-1;
   END IF;
 END IF;

-- try to find which record the change end date fall

 -- if the change does not have end date, the change extends till the end
 -- but it could be on the last record, or outside the range
 IF ( g_change_rec.resource_end_date is null ) THEN
        i :=g_res_tab.LAST;
        IF ( g_res_tab(i).resource_end_date is null ) THEN
	-- falls on the last record
           v_end_record :=g_res_tab.LAST;
        ELSE
	--falls outside the last record
          v_end_record :=g_res_tab.LAST+1;
        END IF;

 ELSE
     IF (    g_change_rec.resource_end_date <
	     g_res_tab(1).resource_start_date    ) THEN
	-- the change ends before the first record
	v_end_record :=0;
     ELSE

        While (j is not null) and
           	 (   g_change_rec.resource_end_date >=
                     g_res_tab(j).resource_start_date    )
        LOOP
              j:=g_res_tab.next(j);
        END LOOP;

        IF j is null THEN
	-- if j is null, then the change ends on or outside the last record
           i :=g_res_tab.LAST;
           IF ( g_res_tab(i).resource_end_date is null ) THEN
              v_end_record :=g_res_tab.LAST;
           ELSE
          	IF (g_change_rec.resource_end_date <=
                	g_res_tab(i).resource_end_date ) THEN
                	v_end_record :=g_res_tab.LAST;
           	ELSE
              		v_end_record :=g_res_tab.LAST+1;
           	END IF;
	   END IF;

        ELSE
	   IF (g_change_rec.resource_end_date <=
                g_res_tab(j-1).resource_end_date ) THEN
	   -- change ends on the previous record
	        v_end_record := j-1;
	   ELSE
	   -- change ends in the gap between record j-1 and record j
		v_end_record := j-0.5;
	   END IF;
   	END IF;
     END IF;
 END IF;

-- flush the records to tmp_tab
   k:=0;
   g_tmp_tab.delete;

 IF g_change_rec.operation <> OP_SET THEN

    IF ( v_start_record =0 ) THEN
	   IF g_change_rec.operation not in (OP_DEL, OP_DEL_DAY) THEN
	   	k:=k+1;
	   	g_tmp_tab(k) := g_change_rec;
	   	IF (v_end_record <> 0) THEN
	      		g_tmp_tab(k).resource_end_date :=
			g_res_tab(1).resource_start_date -1;
	   	END IF;

		-- if add non working day, set the updated field as 1
		-- so that when re-plan, it will be treated as work day

	 	IF g_change_rec.operation = OP_ADD_DAY THEN
			g_tmp_tab(k).updated :=1;
		END IF;
	   END IF;
   END IF;

   j:=g_res_tab.FIRST;
   While (j is not null)
   LOOP
      IF (j < v_start_record) or (j > v_end_record) THEN
		-- no change, just copy the old record
		k:=k+1;
		g_tmp_tab(k):=g_res_tab(j);

      ELSIF (j > v_start_record) and (j<v_end_record) THEN
	       -- the whole record is affected, change the qty
			k:=k+1;
			g_tmp_tab(k):=g_res_tab(j);
			IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units +
                              g_change_rec.resource_units ;
			   g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours +
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate+
                             g_change_rec.max_rate;
			ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units -
                              g_change_rec.resource_units ;
			   g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours -
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate-
                             g_change_rec.max_rate;
			END IF;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;


      ELSIF (j=v_start_record) and (j = v_end_record) THEN
		   -- need to cut the record into three records

             IF (g_change_rec.resource_start_date <>
                        g_res_tab(j).resource_start_date ) THEN
                        -- need to change the date for the first record
                        k:=k+1;
                        g_tmp_tab(k):=g_res_tab(j);
                        g_tmp_tab(k).resource_end_date:=
                             g_change_rec.resource_start_date - 1;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;

	     END IF;

	     -- add a new record
	     -- delete work day and add non working day would be caught
	     -- here only if it falls inside the range and not in a gap,
             --	because v_start_record will always = v_end_record in these cases

	     IF g_change_rec.operation <> OP_DEL_DAY THEN
			k:=k+1;
                        g_tmp_tab(k):=g_change_rec;

                        IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units +
                              g_change_rec.resource_units ;
                           g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours +
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate+
                             g_change_rec.max_rate;
                        ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units -
                              g_change_rec.resource_units ;
                           g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours -
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate-
                             g_change_rec.max_rate;

			-- don't add onto the quantity of the original record
			ELSIF g_change_rec.operation = OP_ADD_DAY THEN
			   g_tmp_tab(k).updated :=1;

                        END IF;
	     END IF;

             IF (g_change_rec.resource_end_date <>
                        g_res_tab(j).resource_end_date ) or
		( g_res_tab(j).resource_end_date is null and
		g_change_rec.resource_end_date is not null) THEN
                        -- need to change the date for the third record
                        k:=k+1;
                        g_tmp_tab(k):=g_res_tab(j);
                        g_tmp_tab(k).resource_start_date:=
                             g_change_rec.resource_end_date + 1;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;

	     END IF;


      ELSIF (j=v_start_record) and (j <> v_end_record) THEN
		   -- need to cut the record

             IF (g_change_rec.resource_start_date <>
                        g_res_tab(j).resource_start_date ) THEN
                        -- need to change the date
                        k:=k+1;
                        g_tmp_tab(k):=g_res_tab(j);
                        g_tmp_tab(k).resource_end_date:=
                             g_change_rec.resource_start_date - 1;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;

	     END IF;

			-- and add a new record
			k:=k+1;
                        g_tmp_tab(k):=g_change_rec;
                        g_tmp_tab(k).resource_end_date:=
                             g_res_tab(j).resource_end_date;
                        IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units +
                              g_change_rec.resource_units ;
                           g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours +
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate+
                             g_change_rec.max_rate;
                        ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units -
                              g_change_rec.resource_units ;
                           g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours -
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate-
                             g_change_rec.max_rate;
                        END IF;

      ELSIF (j=v_end_record) and (j <> v_start_record) THEN
		   -- need to cut the record

			--  add a new record
			k:=k+1;
                        g_tmp_tab(k):=g_change_rec;
                        g_tmp_tab(k).resource_start_date:=
                             g_res_tab(j).resource_start_date;
                        IF g_change_rec.operation = OP_ADD THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units +
                              g_change_rec.resource_units ;
                           g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours +
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate+
                             g_change_rec.max_rate;
                        ELSIF g_change_rec.operation = OP_DEL THEN
                           g_tmp_tab(k).resource_units :=
                              g_res_tab(j).resource_units -
                              g_change_rec.resource_units ;
                           g_tmp_tab(k).resource_hours :=
                              g_res_tab(j).resource_hours -
                              g_change_rec.resource_hours ;
                           g_tmp_tab(k).max_rate:=
                             g_res_tab(j).max_rate-
                             g_change_rec.max_rate;
                        END IF;

             IF (g_change_rec.resource_end_date <>
                        g_res_tab(j).resource_end_date ) or
		(g_change_rec.resource_end_date is not null and
		g_res_tab(j).resource_end_date is null )THEN
                        -- need to change the date
                        k:=k+1;
                        g_tmp_tab(k):=g_res_tab(j);
                        g_tmp_tab(k).resource_start_date:=
                             g_change_rec.resource_end_date + 1;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;
	     END IF;
      END IF;

      -- if change starts or ends in the gap, need to insert new row
      IF g_change_rec.operation not in  (OP_DEL_DAY, OP_DEL) THEN

         IF (v_start_record >j ) and (v_start_record <j+1 ) THEN
               k:=k+1;
               g_tmp_tab(k):=g_change_rec;
	    IF (g_change_rec.resource_end_date >=
                        g_res_tab(j+1).resource_start_date or
		g_change_rec.resource_end_date is null) THEN
		--the change extends over the gap, need to change the end date
		g_tmp_tab(k).resource_end_date:=
			g_res_tab(j+1).resource_start_date-1;
	    END IF;
	 ELSIF (v_end_record >j ) and (v_end_record <j+1 ) THEN
            k:=k+1;
            g_tmp_tab(k):=g_change_rec;
            IF (g_change_rec.resource_start_date <=
                        g_res_tab(j).resource_end_date ) THEN
                --the change extends over the gap, need to change start date
                g_tmp_tab(k).resource_start_date:=
                        g_res_tab(j).resource_end_date+1;
            END IF;
	 END IF;
      END IF;

      j:=g_res_tab.next(j);
   END LOOP;

   -- if the record falls outside the original range, add a new row
   i := g_res_tab.LAST;
   IF (v_end_record = i+1) THEN
	   IF g_change_rec.operation not in (OP_DEL_DAY, OP_DEL) THEN
	   	k:=k+1;
           	g_tmp_tab(k):=g_change_rec;
	   	IF (v_start_record <> i +1 ) THEN
           		g_tmp_tab(k).resource_start_date:=
				g_res_tab(i).resource_end_date +1;
	   	END IF;
	 	IF g_change_rec.operation = OP_ADD_DAY THEN
			g_tmp_tab(k).updated :=1;
		END IF;
	   END IF;
   END IF;

 ELSIF g_change_rec.operation= OP_SET THEN

        i := g_res_tab.LAST;

	IF (v_start_record = 0) THEN

	--if change falls before the range, add a row, go to the end record
	--cut record if needed, then go to the next record
	   k:=k+1;
           g_tmp_tab(k):=g_change_rec;
	   -- if the set record ends outside the range, don't have to loop
	   IF (v_end_record = i+1) THEN
		j:='';
	   ELSIF (v_end_record=0) THEN
	   -- the change ends before the range, loop from record1
		j:=g_res_tab.FIRST;
	   ELSIF (v_end_record > trunc(v_end_record)) THEN
	   -- change falls on a gap, go to the record after the gap
		j:=trunc(v_end_record)+1;
	  -- if the set record ends outside the range, don't have to loop
	   ELSIF (v_end_record < i+1) THEN
	   -- go to where the set record ends and add row if needed
             	j:=v_end_record;

             IF (g_change_rec.resource_end_date <
                        g_res_tab(j).resource_end_date ) or
		(g_res_tab(j).resource_end_date is null and
		g_change_rec.resource_end_date is not null) THEN

                -- need to add row for the date change
                K:=K+1;
                g_tmp_tab(k):=g_res_tab(j);
                g_tmp_tab(k).resource_start_date :=
                        g_change_rec.resource_end_date +1;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;

             END IF;
    	     --go to the next record, and ready for loop
	     j:=j+1;
	   END IF;
	ELSE
	   j:=g_res_tab.FIRST;
	END IF;

        IF j < i+1 THEN
	While ( j is not null ) LOOP
	   IF (j < v_start_record) or (j > v_end_record) THEN
		-- no change
		   k:=k+1;
                   g_tmp_tab(k):=g_res_tab(j);

	   ELSIF (j=v_start_record) THEN

	     IF (g_change_rec.resource_start_date >
			g_res_tab(j).resource_start_date ) THEN
		-- need to insert row with date change only first
		K:=K+1;
		g_tmp_tab(k):=g_res_tab(j);
		g_tmp_tab(k).resource_end_date :=
			g_change_rec.resource_start_date -1;
                        g_tmp_tab(k).status :=0;
                        g_tmp_tab(k).applied:=2;
                        g_tmp_tab(k).last_update_date := sysdate;
                        g_tmp_tab(k).last_updated_by :=
                          g_change_rec.last_updated_by;

	     END IF;

	     -- add new row
	     K:=K+1;
             g_tmp_tab(k):=g_change_rec;

	     IF (v_end_record > trunc(v_end_record)) THEN
             -- change ends on a gap,
               j:=trunc(v_end_record);
             ELSIF (v_end_record < i+1) THEN
	     -- go the where the set record ends, and add row if needed
	        j:=v_end_record;
                IF (g_change_rec.resource_end_date <
                        g_res_tab(j).resource_end_date ) or
		   (g_change_rec.resource_end_date is not null and
		    g_res_tab(j).resource_end_date is null) THEN

                -- need to add row for the date change
                   K:=K+1;
                   g_tmp_tab(k):=g_res_tab(j);
                   g_tmp_tab(k).resource_start_date :=
                        g_change_rec.resource_end_date +1;
                   g_tmp_tab(k).status :=0;
                   g_tmp_tab(k).applied:=2;
                   g_tmp_tab(k).last_update_date := sysdate;
                   g_tmp_tab(k).last_updated_by :=
                      g_change_rec.last_updated_by;
		END IF;
             END IF;

	   END IF;

	   -- if change starts on a gap
	   IF (v_start_record > j) and (v_start_record < j+1) THEN
             -- add new row
             K:=K+1;
             g_tmp_tab(k):=g_change_rec;

	     IF (v_end_record > trunc(v_end_record)) THEN
              -- change ends on a gap,
                j:=trunc(v_end_record);
             ELSIF (v_end_record < i+1) THEN
             -- go to where the set record ends, and add row if needed
                j:=v_end_record;
                IF (g_change_rec.resource_end_date <
                        g_res_tab(j).resource_end_date ) or
		   (g_change_rec.resource_end_date is not null and
		    g_res_tab(j).resource_end_date is null)  THEN

                -- need to add row for the date change
                   K:=K+1;
                   g_tmp_tab(k):=g_res_tab(j);
                   g_tmp_tab(k).resource_start_date :=
                        g_change_rec.resource_end_date +1;
                   g_tmp_tab(k).status :=0;
                   g_tmp_tab(k).applied:=2;
                   g_tmp_tab(k).last_update_date := sysdate;
                   g_tmp_tab(k).last_updated_by :=
                      g_change_rec.last_updated_by;
	        END IF;
             END IF;
	   END IF;

	   j:=g_res_tab.next(j);

	END LOOP;
       END IF;

	-- if the set record starts outside the range
	i:=g_res_tab.LAST;
	IF (v_start_record = i+1 ) THEN
               -- need to add row for the date change
                K:=K+1;
                g_tmp_tab(k):=g_change_rec;
	END IF;

 END IF;

ELSE --user enters a resource which is not in crp_available_resource table

   g_tmp_tab.delete;
   g_tmp_tab(1) := g_change_rec;
END IF;

 g_res_tab :=g_tmp_tab;

END calculate_change;


------------------------------------------------------------------------
--to update crp_available_resources table
-----------------------------------------------------------------------------
PROCEDURE update_table IS
m 	INTEGER;
BEGIN
  if g_resource_exist then
   delete crp_available_resources
	where compile_designator = g_compile_designator
	and   organization_id = g_org_id
        AND (    (line_id = g_line_id)
                OR (  (line_id IS NULL) AND (g_line_id IS NULL)))
        AND (    (department_id = g_department_id)
                 OR (  (department_id IS NULL) AND (g_department_id IS NULL)))
        AND (    (resource_id = g_resource_id)
                 OR (  (resource_id IS NULL) AND (g_resource_id IS NULL)));
  end if;

   For m in 1 .. g_res_tab.LAST LOOP

      -- only insert the resources with positive quantity
      IF (g_res_tab(m).resource_hours > 0 AND
	 g_res_tab(m).resource_units > 0) OR
	 g_res_tab(m).max_rate >0 THEN

	INSERT INTO crp_available_resources
                (compile_designator,
                 organization_id,
                 line_id,
                 department_id,
                 resource_id,
                 resource_hours,
                 max_rate,
                 resource_units,
                 resource_start_date,
                 resource_end_date,
                 status,
                 applied,
		 updated,
                 last_update_date,
                 last_updated_by,
                 creation_date,
                 created_by,
                 last_update_login)
               VALUES
                (g_compile_designator,
                 g_res_tab(m).organization_id,
                 g_res_tab(m).line_id,
                 g_res_tab(m).department_id,
                 g_res_tab(m).resource_id,
		 decode( g_res_tab(m).department_id, null, 0,
                  greatest(0,least(24,g_res_tab(m).resource_hours))),
                 greatest(0,g_res_tab(m).max_rate),
		 decode( g_res_tab(m).department_id, null, 1,
		  greatest(0,round(g_res_tab(m).resource_units,6))),
                 g_res_tab(m).resource_start_date,
                 g_res_tab(m).resource_end_date,
              	 g_res_tab(m).status,
                 g_res_tab(m).applied,
		 g_res_tab(m).updated,
                 g_res_tab(m).last_update_date,
                 g_res_tab(m).last_updated_by,
                 g_res_tab(m).creation_date,
                 g_res_tab(m).created_by,
                 g_res_tab(m).last_update_login);
	END IF;
   END LOOP;

END update_table;

END;

/
