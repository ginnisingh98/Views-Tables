--------------------------------------------------------
--  DDL for Package Body CSF_PLANBOARD_TASKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_PLANBOARD_TASKS" AS
/* $Header: CSFCTPLB.pls 120.18.12010000.14 2010/04/27 09:20:23 vakulkar ship $ */

/* Change history
   Date         Userid     Change
   ----------   --------   ---------------------------------------------------
  06-FEB-2006   srengana   Re-Genesis


*/

  g_use_custom_chromatics boolean;
  -- ================================ --
  -- private functions and procedures --
  -- ================================ --

  ------------------------------------------------------------------------
   -- get the customer and contract name for the SR of the task
  ------------------------------------------------------------------------
  procedure get_customer
    ( p_incident_id in number
    , p_customer    out nocopy varchar2
    , p_contract    out nocopy varchar2
    )
  is
    cursor c ( b_incident_id number ) is
      select   p.party_name
      ,        o.name
      from     cs_incidents_all_b i
      ,        hz_parties p
      ,        okc_k_lines_tl o
      where    i.incident_id = b_incident_id
      and      i.customer_id = p.party_id(+)
      and      i.contract_service_id = o.id(+)
      and      o.language(+) = userenv('lang');
    r c%rowtype;
  begin
    open c(p_incident_id);
    fetch c into r;
    if c%found then
      close c;
      -- could still both be null, though
      p_customer := r.party_name;
      p_contract := r.name;
      return;
    end if;
    close c;
    p_customer := null;
    p_contract := null;
    return;
  end get_customer;

  ------------------------------------------------------------------------
  -- convert travel time to days
  ------------------------------------------------------------------------
  function convert_to_days
    ( p_duration  number
    , p_uom       varchar2
    , p_uom_hours varchar2
    )
  return number
  is
    l_value number;
  begin
    l_value := inv_convert.inv_um_convert
                 ( item_id       => 0
                 , precision     => 2
                 , from_quantity => p_duration
                 , from_unit     => p_uom
                 , to_unit       => p_uom_hours
                 , from_name     => null
                 , to_name       => null
                 );
    return l_value/24;
  end convert_to_days;

  ------------------------------------------------------------------------
  -- see if this task (SR, Task) has notes attached
  ------------------------------------------------------------------------

  function task_has_notes
    ( p_task_id       number
    , p_source_code   varchar2
    , p_source_id     number
    ) return          boolean
  is
    --
    cursor c_note ( b_id number, b_type varchar2 ) is
      select   null tmp
      from     jtf_notes_b
      where    source_object_code = b_type
      and      source_object_id = b_id;

    l_tmp varchar2(1);
    --

  begin
    --
    -- task notes
      open c_note(p_task_id, 'TASK');
      fetch c_note into l_tmp;
      if c_note%found then
        close c_note;
        return true;
      end if;
      close c_note;

    --
    -- source object notes
    If p_source_code = 'SR'
    then
      open c_note(p_source_id, p_source_code);
      fetch c_note into l_tmp;
      if c_note%found then
        close c_note;
        return true;
      end if;
      close c_note;
    end if;
    -- nothing requested or found
    return false;
  end task_has_notes;


  -- =============================== --
  -- public functions and procedures --
  -- =============================== --


  ------------------------------------------------------------------------
  -- populate the planboard
  ------------------------------------------------------------------------
  PROCEDURE populate_planboard_table
    ( p_start_date    in  date
    , p_end_date      in  date
    , p_resource_id   in  number   default null
    , p_resource_type in  varchar2 default null
    , p_shift_reg	  in  varchar2 default null
  	, p_shift_std	  in  varchar2 default null
    , x_pb_tbl        out nocopy pb_tbl_type
    )
  IS
    l_uom_hours               varchar2(3);
    l_rule_id                 number;
    l_tz                      varchar2(3);
    k                         integer;
    m                         integer;
    l_pr                      csf_planboard_tasks.pb_rec_type;
    l_cell                    varchar2(150);
    l_line                    varchar2(100);
    lf                        varchar2(2) ;
    l_incident_id             number;
    l_task_custom_color       varchar2(1);
    l_depend_flag         varchar2(2);
    l_notes_flag          varchar2(2);


    task_id          jtf_number_table;
    real_task_id        jtf_number_table;
    task_number        jtf_varchar2_table_100;
    task_type_id        jtf_number_table;
    trip_task_indicator      jtf_number_table;
    task_priority_id        jtf_number_table;
    source_object_type_code  jtf_varchar2_table_100;
    source_object_name    jtf_varchar2_table_100;
    source_object_id      jtf_number_table;
    planned_start_date      jtf_date_table;
    planned_end_date      jtf_date_table;
    scheduled_start_date    jtf_date_table;
    scheduled_end_date    jtf_date_table;
    task_confirmation_status  jtf_varchar2_table_100;
    parent_task_id        jtf_number_table;
    task_split_flag        jtf_varchar2_table_100;
    assignment_status_id    jtf_number_table;
    actual_start_date      jtf_date_table;
    actual_end_date      jtf_date_table;
    city            jtf_varchar2_table_2000;
    customer          jtf_varchar2_table_400;
    contract          jtf_varchar2_table_400;
    type_name        jtf_varchar2_table_100;
    assignment_status      jtf_varchar2_table_100;
    escalated          jtf_number_table;
    actual_effort        jtf_number_table;
    planned_effort        jtf_number_table;
    resource_id        jtf_number_table;
    resource_type        jtf_varchar2_table_100;
    resource_name      jtf_varchar2_table_2000;
    status_schedulable_flag  jtf_varchar2_table_100;
    type_schedulable_flag    jtf_varchar2_table_100;
    trip_id            jtf_number_table;
    l_avail_type           jtf_varchar2_table_100;
    l_assign_id          jtf_number_table;

    l_prev_resource_id        NUMBER;
    l_prev_resource_type      VARCHAR2(30);
    l_type_name               VARCHAR2(100);
    l_assignment_status       VARCHAR2(100);
    l_real_task_cnt           number; -- added for recalculate all trips
    l_real_task_trip_cnt      number; -- added (for recalculate trip,optimize trip and commit trip)
    l_task_confirm_ctr        number; -- added (for commit_trip)
    l_dep_task_position       number;
    l_dep_trip_id             number;
    l_dep_trip_status         number;
    l_dep_trip_task_ind       number;
    l_dep_source_type         varchar2(60);
    l_escalated               NUMBER;
    l_departure               VARCHAR2(100);
    l_arrival                 VARCHAR2(100);
	l_shift_type              VARCHAR2(50);
    TYPE number_tbl_type IS TABLE OF NUMBER
    INDEX BY VARCHAR2(200);                 --changed the index from binary_integer to varchar2
              --for frontporting bug 5944863
              --the index will now be resource_id||resource_type
              --instead of just resource_id

    l_res_id_map_tbl          number_tbl_type;


    --Newly added code for performance inmprovement
    CURSOR C_virtual_tsk_names
    IS
      Select task_type_id,tt.name
      from jtf_Task_types_tl tt
      where task_type_id in (20,21)
      and   language=userenv('LANG');


    -- for trip status
     TYPE trip_rec IS RECORD(
        object_capacity_id NUMBER,
        status             NUMBER
      );

      TYPE trip_tbl IS TABLE OF trip_rec
      INDEX BY BINARY_INTEGER;

      g_trip_tbl       trip_tbl;

     -- for access hours / after hours
     TYPE access_rec IS RECORD(
        task_id       NUMBER,
        accesshr_set       VARCHAR2(1),
  afterhr_set        VARCHAR2(1)
      );

      TYPE access_tbl IS TABLE OF access_rec
      INDEX BY BINARY_INTEGER;

      g_access_tbl       access_tbl;

     -- for parts requirement
     TYPE parts_rec IS RECORD(
        task_id       NUMBER
      );

      TYPE parts_tbl IS TABLE OF parts_rec
      INDEX BY BINARY_INTEGER;

      g_parts_tbl       parts_tbl ;

      v_restab  csf_resource_tbl := csf_resource_tbl();

    -- cursors
    ----------
   --dependency check
   CURSOR c_depend_check(p_task_id number)
   IS
   SELECT 'Y'
   FROM   jtf_task_depends
   WHERE  p_task_id in (task_id,dependent_on_task_id);


    -- cursor to fetch resources
    CURSOR c_res
    IS
	SELECT RESOURCE_NAME,
		   RESOURCE_ID,
		   RESOURCE_TYPE
	FROM (
		SELECT  RESOURCE_NAME,
                RESOURCE_ID,
                RESOURCE_TYPE
        FROM    CSF_SELECTED_RESOURCES_V
		MINUS
		SELECT  DISTINCT
		        A.RESOURCE_NAME ,
				A.RESOURCE_ID   ,
				A.RESOURCE_TYPE
		FROM    CSF_SELECTED_RESOURCES_V A,
				JTF_RS_DEFRESROLES_VL B,
				JTF_RS_ALL_RESOURCES_VL C,
				JTF_RS_ROLES_B D
		WHERE   B.ROLE_RESOURCE_ID=A.RESOURCE_ID
		AND     C.RESOURCE_ID = B.ROLE_RESOURCE_ID
		AND     C.RESOURCE_TYPE =A.RESOURCE_TYPE
		AND     D.ROLE_ID     = B.ROLE_ID
		AND     B.ROLE_TYPE_CODE ='CSF_THIRD_PARTY'
		AND     NVL( B.DELETE_FLAG, 'N') = 'N'
    	AND     (SYSDATE >= TRUNC (B.RES_RL_START_DATE) OR B.RES_RL_START_DATE IS NULL)
        AND     (SYSDATE <= TRUNC (B.RES_RL_END_DATE) + 1 OR B.RES_RL_END_DATE IS NULL)
		AND     ROLE_CODE IN ( 'CSF_THIRD_PARTY_SERVICE_PROVID', 'CSF_THIRD_PARTY_ADMINISTRATOR')
		)
      ORDER BY UPPER (RESOURCE_NAME);

    -- cursor to fetch resources having active 'Field Service Representative' role
    CURSOR c_res_technician
    IS
	SELECT RESOURCE_NAME,
		   RESOURCE_ID,
		   RESOURCE_TYPE
	FROM (
        SELECT  RES.RESOURCE_NAME,
                RES.RESOURCE_ID,
                RES.RESOURCE_TYPE
        FROM    CSF_SELECTED_RESOURCES_V RES
              , JTF_RS_DEFRESROLES_VL ROLES
        WHERE   RES.RESOURCE_ID = ROLES.ROLE_RESOURCE_ID
        AND     ROLES.ROLE_TYPE_CODE = 'CSF_REPRESENTATIVE'
        AND     (SYSDATE >= TRUNC (ROLES.RES_RL_START_DATE) OR ROLES.RES_RL_START_DATE IS NULL)
        AND     (SYSDATE <= TRUNC (ROLES.RES_RL_END_DATE) + 1 OR ROLES.RES_RL_END_DATE IS NULL)
        AND     NVL(ROLES.DELETE_FLAG, 'N') = 'N'
		MINUS
		SELECT  DISTINCT
		        A.RESOURCE_NAME,
				A.RESOURCE_ID ,
				A.RESOURCE_TYPE
		FROM    CSF_SELECTED_RESOURCES_V A,
				JTF_RS_DEFRESROLES_VL B,
				JTF_RS_ALL_RESOURCES_VL C,
				JTF_RS_ROLES_B D
		WHERE   B.ROLE_RESOURCE_ID=A.RESOURCE_ID
		AND     C.RESOURCE_ID = B.ROLE_RESOURCE_ID
		AND     C.RESOURCE_TYPE =A.RESOURCE_TYPE
		AND     D.ROLE_ID     = B.ROLE_ID
		AND     B.ROLE_TYPE_CODE ='CSF_THIRD_PARTY'
		AND     (SYSDATE >= TRUNC (B.RES_RL_START_DATE) OR B.RES_RL_START_DATE IS NULL)
        AND     (SYSDATE <= TRUNC (B.RES_RL_END_DATE) + 1 OR B.RES_RL_END_DATE IS NULL)
		AND     NVL( B.DELETE_FLAG, 'N') = 'N'
		AND     ROLE_CODE IN ( 'CSF_THIRD_PARTY_SERVICE_PROVID', 'CSF_THIRD_PARTY_ADMINISTRATOR')
		)
      ORDER BY UPPER (resource_name);

  -- Cursor to fetch the tasks for the set of resources.
  CURSOR c_task_all
  IS
  SELECT
               t.task_id
       , decode(t.task_type_id, 20, 0, 21, 0, t.task_id) real_task_id
             , t.task_number
             , t.task_type_id
             , decode(t.task_type_id, 20, 0, 21, 2, 1) trip_task_ind
             , t.task_priority_id
             , t.source_object_type_code
             , t.source_object_name
             , t.source_object_id
             , t.planned_start_date
             , t.planned_end_date
             , t.scheduled_start_date
             , t.scheduled_end_date
             , t.task_confirmation_status
             , t.parent_task_id
             , t.task_split_flag
             , a.assignment_status_id
             , a.actual_start_date
             , a.actual_end_date
             , l.city
             , NULL customer
             , NULL contract
             , null type_name
             , ts1.name
             , 0 escalated
             , a.actual_effort
             , t.planned_effort
             , res.resource_id
             , res.resource_type
             , res.resource_name
             , ts1.schedulable_flag
             , tt.schedule_flag
             , a.object_capacity_id
             ,  a.task_assignment_id
             , cs.availability_type
          FROM  ( SELECT resource_id,
       resource_type,
       resource_name
                 FROM    Table(Cast(v_restab As csf_resource_tbl))
                ) res
             , jtf_task_assignments a
             , jtf_tasks_b t
             , jtf_task_statuses_vl ts1
             , jtf_task_statuses_b ts2
             , jtf_task_types_b tt
             , hz_locations l
             , cac_sr_object_capacity cs
         WHERE a.assignee_role = 'ASSIGNEE'
           AND a.resource_id = res.resource_id
           AND a.resource_type_code = res.resource_type
           AND a.booking_end_date >= p_start_date
           AND a.booking_start_date < p_end_date
     AND a.booking_end_date >= a.booking_start_date
           AND a.assignment_status_id = ts1.task_status_id
           AND nvl(ts1.cancelled_flag,'N') <> 'Y'
           AND t.task_id = a.task_id
          -- AND t.scheduled_start_date is not null        --commented for the bug 6729435
          -- AND t.scheduled_end_date is not null
           AND NVL(t.deleted_flag, 'N') <> 'Y'
           AND t.task_status_id = ts2.task_status_id
           AND nvl(ts2.cancelled_flag,'N') <> 'Y'
           and cs.object_capacity_id(+)= a.object_capacity_id
           AND t.task_type_id = tt.task_type_id
           AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
      ORDER BY res.resource_name
             , nvl(a.actual_start_date,t.scheduled_start_date)
             , DECODE(t.task_type_id, 20, 1, 21, 3, 2)
             , a.task_assignment_id;

             CURSOR c_task
  IS
  SELECT *
  FROM
  (SELECT
               t.task_id
       , decode(t.task_type_id, 20, 0, 21, 0, t.task_id) real_task_id
             , t.task_number
             , t.task_type_id
             , decode(t.task_type_id, 20, 0, 21, 2, 1) trip_task_ind
             , t.task_priority_id
             , t.source_object_type_code
             , t.source_object_name
             , t.source_object_id
             , t.planned_start_date
             , t.planned_end_date
             , t.scheduled_start_date
             , t.scheduled_end_date
             , t.task_confirmation_status
             , t.parent_task_id
             , t.task_split_flag
             , a.assignment_status_id
             , a.actual_start_date
             , a.actual_end_date
             , l.city
             , NULL customer
             , NULL contract
             , null type_name
             , ts1.name
             , 0 escalated
             , a.actual_effort
             , t.planned_effort
             , res.resource_id
             , res.resource_type
             , res.resource_name
             , ts1.schedulable_flag
             , tt.schedule_flag
             , a.object_capacity_id
			       , a.task_assignment_id
             , cs.availability_type
          FROM  ( SELECT resource_id,
       resource_type,
       resource_name
                 FROM    Table(Cast(v_restab As csf_resource_tbl))
                ) res
             , jtf_task_assignments a
             , jtf_tasks_b t
             , jtf_task_statuses_vl ts1
             , jtf_task_statuses_b ts2
             , jtf_task_types_b tt
             , hz_locations l
              , cac_sr_object_capacity cs
         WHERE a.assignee_role = 'ASSIGNEE'
           AND a.resource_id = res.resource_id
           AND a.resource_type_code = res.resource_type
           AND a.booking_end_date >= p_start_date
           AND a.booking_start_date < p_end_date
			AND a.booking_end_date >= a.booking_start_date
           AND a.assignment_status_id = ts1.task_status_id
           AND nvl(ts1.cancelled_flag,'N') <> 'Y'
           AND t.task_id = a.task_id
           AND NVL(t.deleted_flag, 'N') <> 'Y'
            and cs.object_capacity_id(+)= a.object_capacity_id
		   AND t.task_type_id not in (20,21)
           AND t.task_status_id = ts2.task_status_id
           AND nvl(ts2.cancelled_flag,'N') <> 'Y'
           AND t.task_type_id = tt.task_type_id
           AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
	  UNION
		SELECT     /*+ leading(res) use_nl(res a) cardinality(res 5) */
               t.task_id
			 , decode(t.task_type_id, 20, 0, 21, 0, t.task_id) real_task_id
             , t.task_number
             , t.task_type_id
             , decode(t.task_type_id, 20, 0, 21, 2, 1) trip_task_ind
             , t.task_priority_id
             , t.source_object_type_code
             , t.source_object_name
             , t.source_object_id
             , t.planned_start_date
             , t.planned_end_date
             , t.scheduled_start_date
             , t.scheduled_end_date
             , t.task_confirmation_status
             , t.parent_task_id
             , t.task_split_flag
             , a.assignment_status_id
             , a.actual_start_date
             , a.actual_end_date
             , l.city
             , NULL customer
             , NULL contract
             , null type_name
             , ts1.name
             , 0 escalated
             , a.actual_effort
             , t.planned_effort
             , res.resource_id
             , res.resource_type
             , res.resource_name
             , ts1.schedulable_flag
             , tt.schedule_flag
             , a.object_capacity_id
			 , a.task_assignment_id
			 ,csr.availability_type
			 FROM  ( SELECT resource_id,
					 resource_type,
					 resource_name
                 FROM    Table(Cast(v_restab As csf_resource_tbl))
                ) res
             , jtf_task_assignments a
             , jtf_tasks_b t
             , jtf_task_statuses_vl ts1
             , jtf_task_statuses_b ts2
             , jtf_task_types_b tt
             , hz_locations l
			 , cac_sr_object_capacity csr
         WHERE a.assignee_role = 'ASSIGNEE'
           AND a.resource_id = res.resource_id
           AND a.resource_type_code = res.resource_type
           AND a.booking_end_date >= p_start_date
           AND a.booking_start_date < p_end_date
			AND a.booking_end_date >= a.booking_start_date
           AND a.assignment_status_id = ts1.task_status_id
           AND nvl(ts1.cancelled_flag,'N') <> 'Y'
           AND t.task_id = a.task_id
           AND NVL(t.deleted_flag, 'N') <> 'Y'
           AND t.task_status_id = ts2.task_status_id
           AND nvl(ts2.cancelled_flag,'N') <> 'Y'
		   AND t.task_type_id in (20,21)
           AND t.task_type_id = tt.task_type_id
		   AND csr.object_capacity_id(+)=a.object_capacity_id
		    AND (NVL(csr.availability_type,'REGULAR') = decode (nvl(p_shift_reg,'N'),'R','REGULAR')
        or NVL(csr.availability_type,NULL) = decode (nvl(p_shift_std,'N'),'S','STANDBY') )
		   AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
          )
		  ORDER BY resource_name
             , nvl(actual_start_date,scheduled_start_date)
             , DECODE(task_type_id, 20, 1, 21, 3, 2)
             , task_assignment_id;


  procedure set_task_custom_color( p_task_id      in  number
                                 , p_type_id      in  number
                                 , p_priority_id  in  number
                                 , p_status_id    in  number
                                 , p_avail_type   in varchar2
                                 , p_item         out nocopy varchar2)
  is
    l_color varchar2(60) := null;

  begin
   if g_use_custom_chromatics
   then
     if  p_type_id in (20,21) and p_avail_type = 'STANDBY'
     then
         p_item := 'R255G217B255';
     else
         if l_task_custom_color ='Y'
         then
             if l_rule_id is not null
             then
                  begin
                        select background_col_rgb
                        into   p_item
                        from   jtf_task_custom_colors
                        where  rule_id=l_rule_id;
                  exception
                        when no_data_found then
                          p_item := jtf_task_custom_colors_pub.get_task_rgb_bgcolor(
                                      p_task_id,
                                      p_type_id,
                                      p_priority_id,
                                      p_status_id);
                   end ;

             else

                 p_item := jtf_task_custom_colors_pub.get_task_rgb_bgcolor(
                              p_task_id,
                              p_type_id,
                              p_priority_id,
                              p_status_id);
             end if;
        else
             p_item := jtf_task_custom_colors_pub.get_task_rgb_bgcolor(
                          p_task_id,
                          p_type_id,
                          p_priority_id,
                          p_status_id);
        end if;
      end if;-- end if for standy by shift
   end if; -- end if for custom chromatics
  end set_task_custom_color;


    ---Newly added code for performance improvement
      PROCEDURE get_trip_status IS
        CURSOR c_trip_status IS
        SELECT object_capacity_id,status
        FROM   cac_sr_object_capacity
        WHERE  object_capacity_id in (select DISTINCT column_value
                                      FROM TABLE(CAST(trip_id AS jtf_NUMBER_table))
                                      where column_value <> 0);
        i BINARY_INTEGER := 0;
      BEGIN
        IF g_trip_tbl.COUNT = 0
        THEN
          FOR rec IN c_trip_status
        LOOP
            i := i + 1;
            g_trip_tbl(i).object_capacity_id  := rec.object_capacity_id;
            g_trip_tbl(i).status              := rec.status;
          END LOOP;
        END IF;
      END get_trip_status;

   ---Newly added code for performance improvement
      PROCEDURE get_access_status IS
        CURSOR c_access_status IS
        SELECT    task_id
    , NVL(accesshour_required, 'N') access_flag
    , NVL(after_hours_flag, 'N')  after_flag
        FROM   csf_access_hours_b
        WHERE  task_id in (select DISTINCT column_value
                                      FROM TABLE(CAST(real_task_id AS jtf_NUMBER_table))
                                      where column_value <> 0);
        i BINARY_INTEGER := 0;
      BEGIN
        IF g_access_tbl.COUNT = 0
        THEN
          FOR rec IN c_access_status
        LOOP
            i := i + 1;
            g_access_tbl(i).task_id  := rec.task_id;
            g_access_tbl(i).accesshr_set   := rec.access_flag;
      g_access_tbl(i).afterhr_set   := rec.after_flag;
          END LOOP;
        END IF;
      END get_access_status;

     ---Newly added code for performance improvement
      PROCEDURE get_parts_status IS
        CURSOR c_parts_status IS
        SELECT task_id
        FROM   csp_requirement_headers
        WHERE  task_id in (select DISTINCT column_value
                                      FROM TABLE(CAST(real_task_id AS jtf_NUMBER_table))
                                      where column_value <> 0);
        i BINARY_INTEGER := 0;
      BEGIN
        IF g_parts_tbl.COUNT = 0
        THEN
          FOR rec IN c_parts_status
        LOOP
            i := i + 1;
            g_parts_tbl(i).task_id  := rec.task_id;
          END LOOP;
        END IF;
      END get_parts_status;

      FUNCTION do_match(
        p_id         IN NUMBER,
  p_match_type         IN VARCHAR2
      )
      RETURN VARCHAR2 IS
      BEGIN
       IF p_match_type = 'TRIP'
       THEN
        IF g_trip_tbl.COUNT > 0
  THEN
   FOR i IN 1 .. g_trip_tbl.COUNT
       LOOP
           IF  g_trip_tbl(i).object_capacity_id = p_id
           THEN
             RETURN g_trip_tbl(i).status;
           END IF;
          END LOOP;
   END IF;
        RETURN NULL;
       ELSIF p_match_type = 'ACCESS'
       THEN
        IF g_access_tbl.COUNT > 0
  THEN
    FOR i IN 1 .. g_access_tbl.COUNT
       LOOP
          IF  g_access_tbl(i).task_id = p_id
          THEN
      IF g_access_tbl(i).accesshr_set = 'Y'
      THEN
         RETURN 'A ';
      ELSIF g_access_tbl(i).afterhr_set = 'Y'
      THEN
         RETURN 'F ';
      END IF;
          END IF;
         END LOOP;
        END IF;
        RETURN '  ';
       ELSIF p_match_type = 'PARTS'
       THEN
        IF g_parts_tbl.COUNT > 0
  THEN
   FOR i IN 1 .. g_parts_tbl.COUNT
          LOOP
           IF  g_parts_tbl(i).task_id = p_id
           THEN
         RETURN 'S ';
           END IF;
         END LOOP;
        END IF;
          RETURN '  ';
       END IF;
       RETURN NULL;
      END do_match;


  begin

    l_uom_hours          := fnd_profile.value('CSF_UOM_HOURS');
    l_rule_id            := fnd_profile.value_specific('CSF_TASK_SIGNAL_COLOR',fnd_global.user_id);
    lf                   := fnd_global.local_chr(10);
    l_tz                 := fnd_profile.value('CSF_DEFAULT_TIMEZONE_DC');
    l_real_task_cnt      := 0;
    l_task_custom_color  := 'N';
    k :=0;
    m :=0;
    task_id            := jtf_number_table();
    real_task_id          := jtf_number_table();
    task_number          := jtf_varchar2_table_100();
    task_type_id          := jtf_number_table();
    trip_task_indicator        := jtf_number_table();
    task_priority_id          := jtf_number_table();
    source_object_type_code    := jtf_varchar2_table_100();
    source_object_name      := jtf_varchar2_table_100();
    source_object_id        := jtf_number_table();
    planned_start_date        := jtf_date_table();
    planned_end_date        := jtf_date_table();
    scheduled_start_date      := jtf_date_table();
    scheduled_end_date      := jtf_date_table();
    task_confirmation_status    := jtf_varchar2_table_100();
    parent_task_id          := jtf_number_table();
    task_split_flag          := jtf_varchar2_table_100();
    assignment_status_id                   := jtf_number_table();
    actual_start_date        := jtf_date_table();
    actual_end_date         := jtf_date_table();
    city               := jtf_varchar2_table_2000();
    customer             := jtf_varchar2_table_400();
    contract             := jtf_varchar2_table_400();
    type_name           := jtf_varchar2_table_100();
    assignment_status         := jtf_varchar2_table_100();
    escalated             := jtf_number_table();
    actual_effort           := jtf_number_table();
    planned_effort          := jtf_number_table();
    resource_id          := jtf_number_table();
    resource_type          := jtf_varchar2_table_100();
    resource_name        := jtf_varchar2_table_2000();
    status_schedulable_flag               := jtf_varchar2_table_100();
    type_schedulable_flag                   := jtf_varchar2_table_100();
    trip_id              := jtf_number_table();
    l_avail_type          := jtf_varchar2_table_100();
    l_assign_id          := jtf_number_table();


    -- fetch resources
    IF NVL(FND_PROFILE.value('CSF_DC_DISPLAY_ONLY_TECHNICIANS'), 'N') = 'Y' THEN
      OPEN c_res_technician;
      FETCH c_res_technician
        BULK COLLECT INTO
          resource_name
        , resource_id
        , resource_type;
      CLOSE c_res_technician;
    ELSE
      OPEN c_res;
      FETCH c_res
        BULK COLLECT INTO
          resource_name
        , resource_id
        , resource_type;
      CLOSE c_res;
    END IF;

    FOR i IN 1 .. resource_id.COUNT LOOP
      k                                   := k + 1;
      v_restab.extend;
      v_restab(v_restab.Last) := csf_resource(null,null,null,resource_id(i), resource_type(i), resource_name(i),null,null);
      l_pr.resource_id                    := resource_id(i);
      l_pr.resource_type                  := resource_type(i);
      l_pr.resource_name                  := resource_name(i);
      x_pb_tbl(k)                         := l_pr;
      l_res_id_map_tbl(l_pr.resource_id||l_pr.resource_type)  := k;
    END LOOP;
    resource_id                             := jtf_number_table();
    resource_type                           := jtf_varchar2_table_100();
    resource_name                           := jtf_varchar2_table_2000();

   --if p_shift_reg is null and p_shift_std is null
   --then
    OPEN c_task_all;
    FETCH c_task_all
    BULK COLLECT INTO task_id
   , real_task_id
   , task_number
         , task_type_id
         , trip_task_indicator
         , task_priority_id
         , source_object_type_code
         , source_object_name
         , source_object_id
         , planned_start_date
         , planned_end_date
         , scheduled_start_date
         , scheduled_end_date
         , task_confirmation_status
         , parent_task_id
         , task_split_flag
         , assignment_status_id
         , actual_start_date
         , actual_end_date
         , city
         , customer
         , contract
         , type_name
         , assignment_status
         , escalated
         , actual_effort
         , planned_effort
         , resource_id
         , resource_type
         , resource_name
         , status_schedulable_flag
         , type_schedulable_flag
         , trip_id
         , l_assign_id
         , l_avail_type;
         CLOSE c_task_all;
    /*else
      OPEN c_task;
      FETCH c_task
      BULK COLLECT INTO task_id
     , real_task_id
     , task_number
           , task_type_id
           , trip_task_indicator
           , task_priority_id
           , source_object_type_code
           , source_object_name
           , source_object_id
           , planned_start_date
           , planned_end_date
           , scheduled_start_date
           , scheduled_end_date
           , task_confirmation_status
           , parent_task_id
           , task_split_flag
           , assignment_status_id
           , actual_start_date
           , actual_end_date
           , city
           , customer
           , contract
           , type_name
           , assignment_status
           , escalated
           , actual_effort
           , planned_effort
           , resource_id
           , resource_type
           , resource_name
           , status_schedulable_flag
           , type_schedulable_flag
           , trip_id
           , l_assign_id
           , l_avail_type;

       CLOSE c_task;
*/
  -- end if;


   --NEWLY ADDED CURSOR FOR GETTING VIRTUAL TASKS NAMES
    for  i in c_virtual_tsk_names
    loop
      if i.task_type_id = 20
      then
        l_departure := i.name;
      elsif i.task_type_id = 21
      then
        l_arrival := i.name;
      end if;
    end loop;

    get_access_status;
    get_trip_status;
    get_parts_status;
    --END FOR ADDITION


	IF nvl(p_shift_std,'N') ='S' and nvl(p_shift_reg,'N') ='R'
	THEN
	   l_shift_type:=null;
	elsif nvl(p_shift_reg,'N') ='R' then
		l_shift_type:='REGULAR';
	elsif nvl(p_shift_std,'N') ='S' then
	 	l_shift_type:='STANDBY';
	elsif (p_shift_std ='N' and  p_shift_reg ='N' )
		OR (p_shift_std IS NULL AND p_shift_reg IS NULL)
	then
	    l_shift_type:='HIDE';
	end if;
    -- resources and tasks loop
    -----------------------------
    k := null;
    FOR i IN 1 .. task_id.COUNT LOOP
	  IF (task_type_id(i) NOT IN (20, 21)) OR
	     (l_shift_type is Null OR l_shift_type =nvl(l_avail_type(i),'REGULAR'))
	  THEN

      IF l_prev_resource_id IS NULL THEN
        k    := l_res_id_map_tbl(resource_id(i)||resource_type(i));
        l_pr := x_pb_tbl(k);
        l_dep_task_position :=0;
        l_dep_trip_id :=0;
        l_dep_trip_status :=0;
        l_dep_source_type :=null;
        l_real_task_trip_cnt :=0;
        l_task_confirm_ctr := 0;
        m := 1;
      ELSIF l_prev_resource_id||l_prev_resource_type = resource_id(i)||resource_type(i) THEN
        m  := m + 1;
      ELSE
        l_dep_task_position :=0;
        l_dep_trip_id :=0;
        l_dep_trip_status :=0;
        l_dep_source_type :=null;
        l_real_task_trip_cnt :=0;
        l_task_confirm_ctr := 0;
        m                       := 1;
        l_pr.actual_indicator   := RPAD(l_pr.actual_indicator, 15, '0');
        x_pb_tbl(k)             := l_pr;
        k                       := l_res_id_map_tbl(resource_id(i)||resource_type(i));
        l_pr                    := x_pb_tbl(k);
      END IF;

    IF m <= 15 THEN
        -- for SR tasks get the customer and contract name
        --------------------------------------------------
        IF source_object_type_code(i) = 'SR' THEN
          l_incident_id  := source_object_id(i);
          get_customer(l_incident_id, customer(i), contract(i));
        ELSE
          l_incident_id  := NULL;
        END IF;

        l_task_custom_color  := 'N';

        IF task_type_id(i) NOT IN(20, 21) THEN
          IF actual_start_date(i) IS NOT NULL THEN
            IF actual_end_date(i) IS NOT NULL THEN
              IF actual_end_date(i) = actual_start_date(i) THEN
                --set flag for color code
                l_task_custom_color  := 'Y';
              END IF;   --end if for actual_end_date=actual_start_date
            ELSE
              IF NVL(actual_effort(i), 0) = 0 THEN
                IF NVL(planned_effort(i), 0) = 0 THEN
                  l_task_custom_color  := 'Y';
                END IF;
              END IF;
            -- End of the code added for the change in mini-design
            END IF;   --end if for actual_end_date is not null
          ELSE   --for actual start date is null
            IF scheduled_end_date(i) IS NOT NULL THEN
              IF scheduled_end_date(i) = scheduled_start_date(i) THEN
                --set flag for color code
                l_task_custom_color  := 'Y';
              END IF;   --end if for scheduled_end_date=scheduled_start_date
            ELSE
              --set flag for color code
              l_task_custom_color  := 'Y';
            END IF;   --end if scheduled end_date is not null
          END IF;   --end if for actual_start_date is not null
        END IF;   --end if task_type_id

        --    condition for departure and arrival task
        IF task_type_id(i) IN(20, 21) THEN
          IF scheduled_start_date(i) IS NOT NULL AND scheduled_end_date(i) IS NOT NULL THEN
            IF scheduled_start_date(i) <> scheduled_end_date(i) THEN
              IF scheduled_end_date(i) > scheduled_start_date(i) THEN
                --set the color flag
                l_task_custom_color  := 'Y';
              END IF;   --if scheduled end_date > than start_date
            END IF;   --end if for scheduled_end_date is not equal to start_date
          END IF;   --end if for scheduled_start and end_dates are not null
        END IF;   --end if for task_type_id

        -------------------
        -- format task cell
        -------------------

        -- row #1
        ---------
        -- escalated
        IF csf_tasks_pub.is_task_escalated(task_id(i))  THEN
          l_cell  := '!! ';
        ELSE
          l_cell  := NULL;
        END IF;

        IF task_type_id(i) IN(20, 21) THEN
         IF task_type_id(i) = 20 THEN
      l_type_name  := l_departure;
      l_cell       := SUBSTRB(l_cell || l_type_name, 1, 25);
          ELSIF task_type_id(i) = 21 THEN
            l_type_name  := l_arrival;
            l_cell       := SUBSTRB(l_cell || l_type_name, 1, 25);
    END IF;
          IF task_type_id(i) = 20 THEN
            l_real_task_trip_cnt :=0;
            l_task_confirm_ctr := 0;
            l_dep_task_position := m;
            l_dep_trip_id := trip_id(i);
            l_dep_trip_status := do_match(trip_id(i),'TRIP');
            l_dep_trip_task_ind :=trip_task_indicator(i);
            l_dep_source_type   := source_object_type_code(i);
          END IF;
        ELSE
          -- a real task which has status schedulable Y and type schedulable Y
          IF status_schedulable_flag(i) ='Y' AND type_schedulable_flag(i) = 'Y'
             AND source_object_type_code(i) ='SR'
          THEN
            l_real_task_cnt  := l_real_task_cnt + 1;
            IF trip_id(i) = l_dep_trip_id
            THEN
              l_real_task_trip_cnt := l_real_task_trip_cnt + 1;
              IF nvl(task_confirmation_status(i),'N') in ('N','C') THEN
                l_task_confirm_ctr := l_task_confirm_ctr + 1;
              END IF;
            END IF;
          END IF;
            -- display task number instead of SR <nr> now
          l_cell           := SUBSTRB(l_cell || task_number(i), 1, 25);
        END IF;

        -- row #2
        ---------
        l_cell               := l_cell || lf || SUBSTRB(customer(i), 1, 25);

        -- row #3
        ---------
        IF scheduled_start_date(i) NOT BETWEEN p_start_date AND p_end_date THEN
          l_line  := '**:** ';
        ELSE
           -- this if is added to check if actual_start_date is not null then display actual_start_date time
          --or else display scheduled_start_date
          IF l_tz = 'UTZ' THEN
            IF actual_start_date(i) IS NOT NULL THEN
              l_line  :='('|| csf_timezones_pvt.date_to_client_tz_chartime(actual_start_date(i), 'hh24:mi')||') ';
            ELSE
              l_line  := csf_timezones_pvt.date_to_client_tz_chartime(scheduled_start_date(i), 'hh24:mi')|| ' ';
            END IF;
          ELSE
            IF actual_start_date(i) IS NOT NULL THEN
              l_line := '(' || to_char(actual_start_date(i),'hh24:mi')||') ';
            ELSE
              l_line := to_char(scheduled_start_date(i),'hh24:mi') || ' ';
            END IF;
          END IF;
        END IF;

        IF actual_start_date(i) IS NULL THEN
          l_pr.actual_indicator  := l_pr.actual_indicator || '0';
        ELSE
          l_pr.actual_indicator  := l_pr.actual_indicator || '1';
        END IF;

        -- chosen to suppress the assignment status for dep/arr
        IF task_type_id(i) NOT IN(20, 21) THEN
          l_assignment_status  := assignment_status(i);
          l_line               := l_line || ' ' || l_assignment_status;
        END IF;

        l_cell               := l_cell || lf || SUBSTRB(l_line, 1, 25);


        -- row #4
        ---------
        IF contract(i) IS NOT NULL THEN
          l_line  := SUBSTRB(contract(i), 1, 12) || ' ';
        ELSE
          l_line  := NULL;
        END IF;

        IF city(i) IS NOT NULL THEN
          l_line  := l_line || city(i);
        END IF;


        IF l_line is not null THEN
            l_cell := l_cell||lf||SUBSTRB(l_line,1,25);
        END IF;

        --row # 5 added for inspection/R12
          if  source_object_type_code(i) = 'SR' then
            l_depend_flag  :=null;
            l_notes_flag   :=null;

            --access hours/after hours check
          /*  If nvl(access_hours(i),'N')='Y' then
                l_line:='A ';
            elsif nvl(after_hours(i),'N')='Y' then
                l_line:='F ';
            else
                l_line:='  ';
            end if; */

            l_line := do_match(real_task_id(i),'ACCESS');
            -- Customer Confirmation check
            If nvl(task_confirmation_status(i),'N')='C' then
                l_line:=l_line||'V ';
            elsif nvl(task_confirmation_status(i),'N')='R' then
                l_line:=l_line||'C ';
            else
                l_line:=l_line||'  ';
            end if;

            -- Parts check
            /*If nvl(parts_required(i),'N')='Y' then
                l_line:=l_line||'S ';
            else
                l_line:=l_line||'  ';
            end if;*/
       l_line := l_line || do_match(real_task_id(i),'PARTS');

            -- Parent/child check
            If nvl(task_split_flag(i),'N')='D' and parent_task_id(i) is not null then
                l_line:=l_line||'D ';
            elsif nvl(task_split_flag(i),'N')='M' and parent_task_id(i) is null then
                l_line:=l_line||'M ';
            else
                l_line:=l_line||'  ';
            end if;
            -- task dependencies check
            Open c_depend_check(task_id(i));
            Fetch c_depend_check into l_depend_flag;
            close c_depend_check;

            If nvl(l_depend_flag,'N')='Y' then
                l_line:=l_line||'R ';
            else
                l_line:=l_line||'  ';
            end if;

           --notes check
           if task_has_notes(task_id(i), source_object_type_code(i),source_object_id(i))
           then
                 l_line:=l_line||'N ';
           else
                l_line:=l_line||'  ';
           end if;

            if l_line is not null then
                 l_cell := l_cell||lf||l_line;
            end if;
         end if;
      --row # 5 ends here

        -------------------------------------------
        -- put queried record into planboard record
        -------------------------------------------

        IF m = 1 THEN
          l_pr.task_id_1    := task_id(i);
          l_pr.task_cell_1  := l_cell;
          l_pr.other_info_1 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);


          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_1
          );

        ELSIF m = 2 THEN
          l_pr.task_id_2    := task_id(i);
          l_pr.task_cell_2  := l_cell;
          l_pr.other_info_2 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);

          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_2
          );
        ELSIF m = 3 THEN
          l_pr.task_id_3    := task_id(i);
          l_pr.task_cell_3  := l_cell;
          l_pr.other_info_3 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_3
          );
        ELSIF m = 4 THEN
          l_pr.task_id_4    := task_id(i);
          l_pr.task_cell_4  := l_cell;
          l_pr.other_info_4 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_4
          );
        ELSIF m = 5 THEN
          l_pr.task_id_5    := task_id(i);
          l_pr.task_cell_5  := l_cell;
          l_pr.other_info_5 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_5
          );
        ELSIF m = 6 THEN
          l_pr.task_id_6    := task_id(i);
          l_pr.task_cell_6  := l_cell;
          l_pr.other_info_6 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_6
          );
        ELSIF m = 7 THEN
          l_pr.task_id_7    := task_id(i);
          l_pr.task_cell_7  := l_cell;
          l_pr.other_info_7 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_7
          );
        ELSIF m = 8 THEN
          l_pr.task_id_8    := task_id(i);
          l_pr.task_cell_8  := l_cell;
          l_pr.other_info_8 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_8
          );
        ELSIF m = 9 THEN
          l_pr.task_id_9    := task_id(i);
          l_pr.task_cell_9  := l_cell;
          l_pr.other_info_9 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_9
          );
        ELSIF m = 10 THEN
          l_pr.task_id_10    := task_id(i);
          l_pr.task_cell_10  := l_cell;
          l_pr.other_info_10 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_10
          );
        ELSIF m = 11 THEN
          l_pr.task_id_11    := task_id(i);
          l_pr.task_cell_11  := l_cell;
          l_pr.other_info_11 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_11
          );
        ELSIF m = 12 THEN
          l_pr.task_id_12    := task_id(i);
          l_pr.task_cell_12  := l_cell;
          l_pr.other_info_12 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_12
          );
        ELSIF m = 13 THEN
          l_pr.task_id_13    := task_id(i);
          l_pr.task_cell_13  := l_cell;
          l_pr.other_info_13 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_13
          );
        ELSIF m = 14 THEN
          l_pr.task_id_14    := task_id(i);
          l_pr.task_cell_14  := l_cell;
          l_pr.other_info_14 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_14
          );
        ELSIF m = 15 THEN
          l_pr.task_id_15    := task_id(i);
          l_pr.task_cell_15  := l_cell;
          l_pr.other_info_15 := nvl(trip_id(i),-1)||'!'||nvl(do_match(trip_id(i),'TRIP'),-1) || '!'||l_real_task_trip_cnt || '!' || trip_task_indicator(i) || '!' || l_task_confirm_ctr || '!' || source_object_type_code(i);
          set_task_custom_color(
            task_id(i)
          , task_type_id(i)
          , task_priority_id(i)
          , assignment_status_id(i)
          , l_avail_type(i)
          , l_pr.rgb_color_15
          );
        END IF;

        IF l_dep_task_position > 0 and l_real_task_trip_cnt > 0 THEN
           IF l_dep_task_position = 1 THEN
             l_pr.other_info_1:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 2 THEN
             l_pr.other_info_2:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 3 THEN
             l_pr.other_info_3:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 4 THEN
             l_pr.other_info_4:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 5 THEN
             l_pr.other_info_5:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 6 THEN
             l_pr.other_info_6:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 7 THEN
             l_pr.other_info_7:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 8 THEN
             l_pr.other_info_8:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 9 THEN
             l_pr.other_info_9:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 10 THEN
             l_pr.other_info_10:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 11 THEN
             l_pr.other_info_11:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 12 THEN
             l_pr.other_info_12:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 13 THEN
             l_pr.other_info_13:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 14 THEN
             l_pr.other_info_14:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           ELSIF l_dep_task_position = 15 THEN
             l_pr.other_info_15:= nvl(l_dep_trip_id,-1)||'!'||nvl(l_dep_trip_status,-1) || '!'||l_real_task_trip_cnt || '!'|| l_dep_trip_task_ind || '!' || l_task_confirm_ctr || '!' || l_dep_source_type;
           END IF;
        END IF;
      END IF;
      l_prev_resource_id  := resource_id(i);
      l_prev_resource_type := resource_type(i);
	 END IF;-- This end if is for resource trip type
    END LOOP;

    if k is not null then
        l_pr.actual_indicator                   := RPAD(l_pr.actual_indicator, 15, '0');
        x_pb_tbl(k)                             := l_pr;
    end if;
    -- update the indicator in record 1 with the "real" task count
    if x_pb_tbl.COUNT > 0 then
      x_pb_tbl(x_pb_tbl.FIRST).real_task_cnt  := l_real_task_cnt;
    end if;
  EXCEPTION
    -- there were no resources
    WHEN COLLECTION_IS_NULL THEN
      NULL;
  END populate_planboard_table;
BEGIN
  -- getting the indicator if custom color coding will be used.
  g_use_custom_chromatics := fnd_profile.value('CSF_USE_CUSTOM_CHROMATICS') = 'Y' ;
END csf_planboard_tasks;


/
