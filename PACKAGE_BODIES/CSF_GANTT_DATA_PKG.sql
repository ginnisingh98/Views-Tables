--------------------------------------------------------
--  DDL for Package Body CSF_GANTT_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_GANTT_DATA_PKG" AS
  /*$Header: CSFGTPLB.pls 120.52.12010000.34 2010/04/08 08:35:38 ramchint ship $*/

  g_pkg_name     CONSTANT VARCHAR2(30)       := 'CSF_GANTT_DATA_PKG';

  g_use_custom_chromatics BOOLEAN            := FALSE;
  g_label_on_task         BOOLEAN            := FALSE;
  g_uom_minutes           VARCHAR2(60)       := NULL;
  g_uom_hours             VARCHAR2(60)       := NULL;
  g_resource_id           NUMBER(20);
  g_resource_type         VARCHAR2(250);

  l_default_effort_uom    VARCHAR2(3);
  l_default_effort        NUMBER(10);
  l_rule_id               NUMBER(30);
  l_task_custom_color     VARCHAR2(1);
  l_task_dec_color        NUMBER;
  l_profile_value         VARCHAR2(1);

  -- Tooltip Labels
  g_task_number           VARCHAR2(80);
  g_task_type             VARCHAR2(80);
  g_task_status           VARCHAR2(80);
  g_sr_number             VARCHAR2(80);
  g_sr_type               VARCHAR2(80);
  g_parts                 VARCHAR2(80);
  g_serial                VARCHAR2(80);
  g_lot                   VARCHAR2(80);
  g_address               VARCHAR2(80);
  g_contact               VARCHAR2(80);
  g_phone                 VARCHAR2(80);
  g_planned_start         VARCHAR2(80);
  g_sched_start           VARCHAR2(80);
  g_actual_start          VARCHAR2(80);
  g_estimated_start       VARCHAR2(80);
  g_start                 VARCHAR2(80);
  g_end                   VARCHAR2(80);
  g_travel_time           VARCHAR2(80);
  g_departure             VARCHAR2(80);
  g_option                VARCHAR2(80);
  g_inc_add               VARCHAR2(80);
  g_cust_name             VARCHAR2(80);
  g_timezone              VARCHAR2(80);
  g_product_name          VARCHAR2(80);
  g_planned_effort        VARCHAR2(80);
  g_actual_effort         VARCHAR2(80);
  g_tech_status           VARCHAR2(100);
  g_tech_lat              VARCHAR2(100);
  g_tech_lon              VARCHAR2(100);
  g_tech_dev_tag          VARCHAR2(100);
  g_tech_cur_add		  VARCHAR2(2000);

  g_inc_sched_start_date  VARCHAR2(100);
  g_inc_plan_start_date   VARCHAR2(100);
  g_inc_actul_start_date  VARCHAR2(100);
  g_inc_plan_end_date     VARCHAR2(100);
  g_inc_actul_end_date	  VARCHAR2(100);
  g_task_name 			  VARCHAR2(100);
  g_dc_sched_end_date     VARCHAR2(100);
  g_dc_plan_end_date	  VARCHAR2(100);
  g_dc_actul_end_date	  VARCHAR2(100);

  g_user_id               NUMBER;
  gl_custom_color_tbl     g_custom_color_tbl;
  g_date_format           VARCHAR2(20);
  l_language			 VARCHAR2(300);

  g_server_tz  varchar2(300) := null;
  g_client_tz  varchar2(300) := null;
  g_tz_enabled varchar2(1)   ;
  g_dflt_tz_for_dc varchar2(3);
  g_dflt_tz_for_sc varchar2(3);
  g_off_time      VARCHAR2(80);
  G_PER_TIME   VARCHAR2(80);
  g_commute    VARCHAR2(10);
  g_debug      VARCHAR2(1)        := NVL(fnd_profile.value('AFLOG_ENABLED'), 'N');
  g_debug_level NUMBER       := NVL(fnd_profile.value_specific('AFLOG_LEVEL'), fnd_log.level_event);


  g_excl_travel varchar2(200);

  PROCEDURE set_tooltip_labels;
  PROCEDURE g_get_custom_color;
  FUNCTION convert_to_min
    ( p_duration  number
    , p_uom       varchar2
    , p_uom_min varchar2
    )
  return number;

  -- ---------------------------------
  -- private procedures and functions
  -- ---------------------------------

  -- set global variables to store labels for tooltip
  PROCEDURE set_tooltip_labels IS
  BEGIN
    g_task_number      := fnd_message.get_string('CSF', 'CSF_TASK_NUMBER');
    g_task_type        := fnd_message.get_string('CSF', 'CSF_TASK_TYPE');
    g_task_status      := fnd_message.get_string('CSF', 'CSF_TASK_STATUS');
    g_sr_number        := fnd_message.get_string('CSF', 'CSF_SR_NUMBER');
    g_sr_type          := fnd_message.get_string('CSF', 'CSF_SR_TYPE');
    g_parts            := fnd_message.get_string('CSF', 'CSF_PARTS_REQUIRED');
    g_serial           := fnd_message.get_string('CSF', 'CSF_SERIAL_NUMBER');
    g_lot              := fnd_message.get_string('CSF', 'CSF_LOT_NUMBER');
    g_address          := fnd_message.get_string('CSF', 'CSF_ADDRESS');
    g_contact          := fnd_message.get_string('CSF', 'CSF_CONTACT');
    g_phone            := fnd_message.get_string('CSF', 'CSF_PHONE');
    g_planned_start    := fnd_message.get_string('CSF', 'CSF_PLANNED_START');
    g_sched_start      := fnd_message.get_string('CSF', 'CSF_SCHEDULED_START');
    g_actual_start     := fnd_message.get_string('CSF', 'CSF_ACTUAL_START');
    g_estimated_start  := fnd_message.get_string('CSF', 'CSF_ESTIMATED_START');
    g_start            := fnd_message.get_string('CSF', 'CSF_START');
    g_end              := fnd_message.get_string('CSF', 'CSF_END');
    g_travel_time      := fnd_message.get_string('CSF', 'CSF_TRAVEL_TIME');
    g_departure        := fnd_message.get_string('CSF', 'CSF_DEPARTURE');
    g_option           := fnd_message.get_string('CSF', 'CSF_PLANOPTION');
    g_inc_add          := fnd_message.get_string('CSF', 'CSF_INCIDENT_ADDRESS');
    g_cust_name        := fnd_message.get_string('CSF', 'CSF_CUSTOMER_NAME');
    g_timezone         := fnd_message.get_string('CSF', 'CSF_TIMEZONE');
    g_product_name     := fnd_message.get_string('CSF', 'CSF_PRODUCT_NAME');
    g_per_time         := fnd_message.get_string('CSF','CSF_PERSONAL_TRAVEL_TIME');
    g_off_time         := fnd_message.get_string('CSF','CSF_OFFICIAL_TRAVEL_TIME');
    g_planned_effort   := fnd_message.get_string('CSF','CSF_PLANNED_EFFORT');
    g_actual_effort    := fnd_message.get_string('CSF','CSF_ACTUAL_EFFORT');
    g_tech_status      := fnd_message.get_string('CSF','CSF_GNTTOOL_TECH_STATUS');
    g_tech_lat         := fnd_message.get_string('CSF','CSF_GNTTOOL_TECH_LAT');
    g_tech_lon         := fnd_message.get_string('CSF','CSF_GNTTOOL_TECH_LONG');
    g_tech_dev_tag     := fnd_message.get_string('CSF','CSF_GNTTOOL_TECH_DEV_TAG');
	g_inc_sched_start_date := fnd_message.get_string('CSF','CSF_INC_SCHEDULED_START_DATE');
    g_inc_plan_start_date  := fnd_message.get_string('CSF','CSF_INC_PLANNED_START_DATE');
    g_inc_actul_start_date := fnd_message.get_string('CSF','CSF_INC_ACTUAL_START_DATE');
    g_inc_plan_end_date    := fnd_message.get_string('CSF','CSF_INC_PLANNED_END_DATE');
    g_inc_actul_end_date   := fnd_message.get_string('CSF','CSF_INC_ACTUAL_END_DATE');
    g_task_name 		   := fnd_message.get_string('CSF','CSF_M_TASKNAME');
	g_dc_sched_end_date    := fnd_message.get_string('CSF','CSF_DC_SCHEDULED_END_DATE');
    g_dc_plan_end_date	   := fnd_message.get_string('CSF','CSF_DC_PLANNED_END_DATE');
    g_dc_actul_end_date	   := fnd_message.get_string('CSF','CSF_DC_ACTUAL_END_DATE');
	g_tech_cur_add		   := fnd_message.get_string('CSF','CSF_GNTTOOL_TECH_DEV_ADD');

  END set_tooltip_labels;

  PROCEDURE debug(p_message VARCHAR2, p_module VARCHAR2, p_level NUMBER) IS
  BEGIN
    IF g_debug = 'Y' AND p_level >= g_debug_level THEN
      IF ( p_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL )
      THEN
        fnd_log.string(p_level, 'csf.plsql.CSFGTPLB.' || p_module, p_message);
      END IF;
    END IF;
  END debug;


  PROCEDURE get_message_text
   (  p_api_version              IN         Number
   , p_init_msg_list            IN         Varchar2 DEFAULT NULL
   , x_return_status            OUT NOCOPY Varchar2
   , x_msg_count                OUT NOCOPY Number
   , x_msg_data                 OUT NOCOPY Varchar2
   , p_message_text             OUT NOCOPY jtf_varchar2_table_2000
   , p_message_code             OUT NOCOPY jtf_varchar2_table_2000
   )
   IS
    Cursor c1
    is
    select trim(MESSAGE_TEXT),substr(message_name,5,3)
    from fnd_new_messages
    where application_id=513
    AND  language_code =USERENV('LANG')
    and substr(message_name,1,4) = 'CSF_'
    and translate(substr(message_name,6,2),'0123456789','xxxxxxxxxx') ='xx'
    order by message_name;

  BEGIN
    p_message_text             :=jtf_varchar2_table_2000();
    p_message_code             :=jtf_varchar2_table_2000();
    OPEN c1;
    FETCH c1
    BULK COLLECT INTO p_message_text,p_message_code;
  END get_message_text;

  FUNCTION truncsec(p_str VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
    RETURN SUBSTR(p_str, 1, LENGTH(p_str) - 3);
  END truncsec;

     FUNCTION is_task_escalated(p_task_id NUMBER)
 	     RETURN BOOLEAN IS
 	     l_ref_task_id   NUMBER;
 	     l_escalated     VARCHAR2(10);

 	     CURSOR c_task_ref IS
 	       SELECT task_id
 	         FROM jtf_task_references_b r
 	        WHERE r.reference_code = 'ESC'
 	          AND r.object_type_code = 'TASK'
 	          AND r.object_id = p_task_id;

 	     CURSOR c_esc(b_task_id NUMBER) IS
 	       SELECT DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y')
 	         FROM jtf_tasks_b t
 	            , jtf_task_statuses_b s
 	        WHERE t.task_id = b_task_id
 	          AND t.task_type_id = 22
 	          AND s.task_status_id = t.task_status_id
 	          AND NVL(s.closed_flag, 'N') <> 'Y'
 	          AND NVL(t.deleted_flag, 'N') <> 'Y';
 	   BEGIN
 	     -- Get the Reference Task to the given Task
 	     OPEN c_task_ref;
 	     FETCH c_task_ref INTO l_ref_task_id;
 	     CLOSE c_task_ref;

 	     IF l_ref_task_id IS NULL THEN
 	       RETURN FALSE;
 	     END IF;

 	     -- Check whether the Reference object is an Escalation Task
 	     OPEN c_esc(l_ref_task_id);
 	     FETCH c_esc INTO l_escalated;
 	     CLOSE c_esc;

 	     IF l_escalated = 'Y' THEN
 	       RETURN TRUE;
 	     ELSE
 	       RETURN FALSE;
 	     END IF;


 	   EXCEPTION
 	     WHEN OTHERS THEN
 	       IF c_task_ref%ISOPEN THEN
 	         CLOSE c_task_ref;
 	       END IF;
 	       IF c_esc%ISOPEN THEN
 	         CLOSE c_esc;
 	       END IF;
 	       RETURN FALSE;
 	   END is_task_escalated;

  -- this function returns the translated name of the UOM code
   -- should support a name in plural form too
  FUNCTION get_uom(p_code VARCHAR2, p_plural BOOLEAN DEFAULT FALSE)
    RETURN VARCHAR2 IS
    l_uom VARCHAR2(2000) := NULL;

    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;
  BEGIN
    OPEN c_uom(p_code);
    FETCH c_uom INTO l_uom;
    IF c_uom%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c_uom;
    RETURN l_uom;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_uom%ISOPEN THEN
        CLOSE c_uom;
      END IF;
      RETURN p_code;
  END get_uom;

  FUNCTION get_tooltip_data_gantt(
    p_task_id        NUMBER
  , p_resource_id    NUMBER
  , p_resource_type  VARCHAR2
  , p_start_date     DATE
  , p_end_date       DATE
  , p_inc_tz_code    VARCHAR2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  )
    RETURN VARCHAR2 IS
    -- task and task assignment data




    CURSOR c_task IS
      SELECT /*+ ORDERED use_nl (a tb tt tl sb sl pi ps hl ft)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             tb.task_id
           , tl.task_name
           , tb.task_number
           , tb.source_object_type_code
           , tb.source_object_id
           , tt.NAME task_type
           , sl.NAME task_status
           , a.resource_id
           , a.resource_type_code resource_type
           , tb.planned_start_date
           , tb.planned_end_date
           , scheduled_start_date
           , scheduled_end_date
           , a.actual_start_date
           , a.actual_end_date
           , a.sched_travel_duration
           , a.sched_travel_duration_uom
           , tb.customer_id party_id
           , NVL(sb.assigned_flag, 'N') assigned_flag
           , tb.task_type_id
           , csf_tasks_pub.get_task_address(tb.task_id,tb.address_id,tb.location_id,'Y') small_address
           , pi.party_name party_name
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , tz.ACTIVE_TIMEZONE_CODE ic_tz_code
           , tz.ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
           , tb.planned_effort ||' '|| tb.planned_effort_uom plan_effort
           , tb.actual_effort ||' '|| tb.actual_effort_uom   act_effort
        FROM jtf_task_assignments a
           , jtf_tasks_b tb
           , jtf_task_types_tl tt
           , jtf_tasks_tl tl
           , jtf_task_statuses_b sb
           , jtf_task_statuses_tl sl
           , hz_party_sites ps
           , hz_locations hl
           , hz_parties pi
           , fnd_timezones_b tz
       WHERE a.task_id = p_task_id
         AND resource_id = p_resource_id
         AND resource_type_code = p_resource_type
         AND tb.task_id = a.task_id
         AND tt.LANGUAGE = l_language
         AND tt.task_type_id = tb.task_type_id
         AND sl.LANGUAGE = l_language
         AND sb.task_status_id = a.assignment_status_id
         AND sl.task_status_id = sb.task_status_id
         AND tl.LANGUAGE = l_language
         AND tl.task_id = tb.task_id
         AND ps.party_site_id(+) = tb.address_id
         AND hl.location_id(+) = ps.location_id
         AND pi.party_id(+) = tb.customer_id
         AND NVL(sb.cancelled_flag, 'N') <> 'Y'
         AND tz.UPGRADE_TZ_ID(+) = hl.timezone_id;

    CURSOR c_sr(b_incident_id NUMBER) IS
      SELECT /*+ ORDERED USE_NL */
             i.customer_product_id
           , i.current_serial_number
           , si.concatenated_segments product_name
        FROM cs_incidents_all_b i, mtl_system_items_kfv si
       WHERE si.inventory_item_id(+) = i.inventory_item_id
         AND si.organization_id(+) = i.inv_organization_id
         AND i.incident_id = b_incident_id;

    l_uom       VARCHAR2(2000)        := NULL;
    l_debug        CONSTANT BOOLEAN      := g_debug = 'Y';
    l_Res_Timezone_id   Number;
    l_res_tz_cd varchar2(100);
    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;

    CURSOR c_parts(b_task_id NUMBER) IS
      SELECT 'Y' required
        FROM csp_requirement_headers
       WHERE task_id = b_task_id;

    CURSOR c_ib(b_customer_product_id NUMBER) IS
      SELECT serial_number
           , lot_number
        FROM csi_item_instances
       WHERE instance_id = b_customer_product_id;

    Cursor C_Res_TimeZone Is
     Select TIME_ZONE
     From JTF_RS_RESOURCE_EXTNS
     Where RESOURCE_ID = p_resource_id
     ;
    Cursor c_res_tz
    IS
     SELECT ACTIVE_TIMEZONE_CODE,ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
     FROM fnd_timezones_vl ft
     WHERE UPGRADE_TZ_ID =l_Res_TimeZone_id;

     Cursor c_trip
     IS
        SELECT   object_capacity_id
          FROM   jtf_task_assignments ja
               , jtf_tasks_b jb
         WHERE   ja.task_id = jb.task_id
           AND   ja.task_id = p_task_id
           AND   jb.task_type_id not in (20,21)
		   AND   ja.object_capacity_id is not null
		   and   nvl(jb.deleted_flag,'N') <> 'Y';

     Cursor  c_tasks(l_capacity number)
     IS
       SELECT ja.task_id
         FROM jtf_task_assignments ja ,
              jtf_tasks_b jb                ,
              jtf_task_statuses_b js
        WHERE ja.task_id                  = jb.task_id
          AND js.task_status_id           = jb.task_status_id
          AND ja.object_capacity_id       = l_capacity
          AND ja.resource_id              = p_resource_id
          AND NVL(js.cancelled_flag,'N') <> 'Y'
          AND NVL(js.rejected_flag,'N')  <> 'Y'
          AND NVL(jb.deleted_flag,'N')   <> 'Y'
          AND jb.task_type_id NOT        IN (20,21)
          AND ja.object_capacity_id      IS NOT NULL
      ORDER BY NVL(ja.actual_start_date,jb.scheduled_start_date);

      Cursor c_arr
    IS
       SELECT  ja.task_id
             , ja.actual_travel_duration
             , ja.sched_travel_duration
             , ja.actual_travel_duration_uom
             , ja.sched_travel_duration_uom
         FROM jtf_task_assignments ja ,
              jtf_tasks_b jb
        WHERE ja.task_id        = jb.task_id
         AND jb.task_type_id      IN (21)
         AND ja.task_id= p_task_id;

    Cursor c_terr
	IS
	   SELECT territory_id
   	     FROM csf_dc_resources_v
	    WHERE resource_id = p_resource_id
	      AND resource_type   = p_resource_type;

    l_task_rec  c_task%ROWTYPE;
    l_sr_rec    c_sr%ROWTYPE;
    l_parts_rec c_parts%ROWTYPE;
    l_ib_rec    c_ib%ROWTYPE;
    l_rec       tooltip_data_rec_type := NULL;
    p_color     NUMBER                := 255;
    l_str       VARCHAR2(2000)        := NULL;

    l_ic_planned_start_date   date;
    l_ic_planned_end_date     date;
    l_ic_scheduled_start_date date;
    l_ic_scheduled_end_date   date;
    l_ic_actual_start_date    date;
    l_ic_actual_end_date      date;


    l_dc_planned_start_date   date;
    l_dc_planned_end_date     date;
    l_dc_scheduled_start_date date;
    l_dc_scheduled_end_date   date;
    l_dc_actual_start_date    date;
    l_dc_actual_end_date      date;
    l_actual_start_date       date;
    l_scheduled_start_date    date;
    l_tz_desc                 varchar2(100);
    l_rs_tz_desc              varchar2(100);
    l_rs_ic_tz_present        boolean;
    l_lines                   number;                --bug no 5674408
    l_off_time                varchar2(200);
    l_per_time                varchar2(200);
    l_planned_effort          varchar2(200);
    l_actual_effort           varchar2(200);
    l_task_tbl                jtf_number_table;
    l_capacity                number;
    i                         number;
    j                         number;
    l_first                   number;
    l_last                    number;
	  l_territory               number;
	  l_arr                     c_arr%rowtype;

    l_feed_time               varchar2(100);
    l_status                  varchar2(100);
    l_latitude                varchar2(100);
    l_longitude               varchar2(100);
    l_speed                   varchar2(100);
    l_direction               varchar2(100);
    l_parked_time             varchar2(100);
    l_address                 varchar2(100);
    l_creation_date           varchar2(100);
    l_device_tag              varchar2(100);
    l_status_code_meaning     varchar2(100);
    l_return_status           varchar2(2);
    l_msg_count               NUMBER;
    l_msg_data                varchar2(100);

  BEGIN

  IF l_debug THEN
      debug('Start of function get_tooltip_data_gantt'  , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug('Parameters : Task_Id '||p_task_id , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' Resource_Id '||p_resource_id , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' Resource_type '||p_resource_type , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' Start Date '||to_char(p_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' End Date '||to_char(p_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' Incident timezone code :'||p_inc_tz_code , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' Server timezone code :'||p_server_tz_code , 'get_tooltip_data_gantt', fnd_log.level_procedure);
      debug(' Client timezone code :'||p_client_tz_code , 'get_tooltip_data_gantt', fnd_log.level_procedure);

   END IF;


  open c_terr;
	fetch c_terr into l_territory;
	close c_terr;
	IF l_debug THEN
	  debug(' Territory Id :'||l_territory , 'get_tooltip_data_gantt', fnd_log.level_statement);
  END IF;
    g_excl_travel := csr_scheduler_pub.get_sch_parameter_value(  'spCommuteExcludedTime'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );
   g_commute := csr_scheduler_pub.get_sch_parameter_value(  'spCommutesPosition'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );

   IF l_debug THEN
	  debug(' Excluded Travel time :'||g_excl_travel , 'get_tooltip_data_gantt', fnd_log.level_statement);
	  debug(' Commute  :'||g_commute , 'get_tooltip_data_gantt', fnd_log.level_statement);
   END IF;

    OPEN c_task;
    FETCH c_task INTO l_task_rec;
    IF c_task%NOTFOUND THEN
      CLOSE c_task;
      IF l_debug THEN
    	  debug(' Cursor c_task raised No Data Found exception', 'get_tooltip_data_gantt', fnd_log.level_statement);
    	END IF;
      RAISE NO_DATA_FOUND;
    END IF;
    l_task_tbl := jtf_number_table();

    OPEN c_trip;
    FETCH c_trip into l_capacity;
    CLOSE c_trip;

    IF l_debug THEN
    	  debug(' Object capacity id :'||l_capacity, 'get_tooltip_data_gantt', fnd_log.level_statement);
    END IF;

    OPEN c_tasks(l_capacity);
    FETCH c_tasks BULK COLLECT INTO l_task_tbl;
    CLOSE c_tasks;

    IF l_task_tbl.count > 0
    THEN
      i := l_task_tbl.FIRST;
      j := l_task_tbl.LAST;
      l_first := l_task_tbl(i);
      l_last := l_task_tbl(j);

      IF l_debug THEN
    	  debug(' First Task in the trip :'||l_first, 'get_tooltip_data_gantt', fnd_log.level_statement);
    	  debug(' last Task in the trip :'||l_last, 'get_tooltip_data_gantt', fnd_log.level_statement);
      END IF;
    END IF;

    open c_arr;
    fetch c_arr into l_arr;
    close c_arr;

    IF l_debug THEN
    	  debug(' Task Type Id:'||l_task_rec.task_type_id, 'get_tooltip_data_gantt', fnd_log.level_statement);
    END IF;

    IF l_task_rec.task_type_id NOT IN(20, 21)
    THEN
      l_planned_effort := l_task_rec.plan_effort;
      l_actual_effort  := l_task_rec.act_effort;

      IF l_debug THEN
    	  debug(' Planned Effort :'||l_planned_effort, 'get_tooltip_data_gantt', fnd_log.level_statement);
    	  debug(' Actual Effort :'||l_actual_effort, 'get_tooltip_data_gantt', fnd_log.level_statement);
      END IF;

      IF l_debug THEN
    	  debug(' Scheduled Start Date :'||l_task_rec.scheduled_start_date, 'get_tooltip_data_gantt', fnd_log.level_statement);
    	  debug(' Scheduled End Date :'||l_task_rec.scheduled_end_date, 'get_tooltip_data_gantt', fnd_log.level_statement);
    	  debug(' Actual Start Date :'||l_task_rec.actual_start_date, 'get_tooltip_data_gantt', fnd_log.level_statement);
      END IF;

      IF l_task_rec.scheduled_start_date <> l_task_rec.scheduled_end_date
      THEN
        IF (   l_task_rec.scheduled_start_date <> p_start_date
            OR l_task_rec.scheduled_end_date <> p_end_date
           )
        AND  l_task_rec.actual_start_date is null
        THEN
          CLOSE c_task;
          IF l_debug THEN
          	  debug(' Cursor c_task raised No Data found exception becoz of actual start date is null', 'get_tooltip_data_gantt', fnd_log.level_statement);
          END IF;
          RAISE NO_DATA_FOUND;
        END IF;
      END IF;
      IF l_debug THEN
          debug(' Source Object Id: '||l_task_rec.source_object_id, 'get_tooltip_data_gantt', fnd_log.level_statement);
      END IF;
      OPEN c_sr(l_task_rec.source_object_id);
      FETCH c_sr INTO l_sr_rec;

      IF l_sr_rec.customer_product_id IS NOT NULL THEN
        IF l_debug THEN
          debug(' Customer  Product  Id: '|| l_sr_rec.customer_product_id, 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
        OPEN c_ib(l_sr_rec.customer_product_id);
        FETCH c_ib INTO l_ib_rec;
        CLOSE c_ib;
      ELSE
        l_ib_rec.serial_number  := l_sr_rec.current_serial_number;
        l_ib_rec.lot_number     := NULL;   -- not yet supported

        IF l_debug THEN
          debug(' Serial Number: '|| l_ib_rec.serial_number, 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
      END IF;
   END IF;
   l_rec.incident_customer_name  := l_task_rec.party_name;
   IF l_debug THEN
          debug(' Party Name : '||l_rec.incident_customer_name , 'get_tooltip_data_gantt', fnd_log.level_statement);
    END IF;

   --begin addition for bug 5674408
   IF (LENGTH(NVL(l_task_rec.party_name, 0)) > 80)
   THEN
       l_lines := ceil(length(l_task_rec.party_name)/80) - 1;
       IF l_debug THEN
          debug(' No. of lines  : '||l_lines , 'get_tooltip_data_gantt', fnd_log.level_statement);
       END IF;
       l_rec.incident_customer_name := null;

       for i in 1..l_lines
       loop
           l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1, 80) || fnd_global.local_chr (10);
           l_task_rec.party_name := substrb(l_task_rec.party_name,81);
           IF l_debug THEN
              debug(' Incident Customer name  : '||l_rec.incident_customer_name , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' Party Name  : '||l_task_rec.party_name , 'get_tooltip_data_gantt', fnd_log.level_statement);
           END IF;
       end loop;

       l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1);
       IF l_debug THEN
              debug(' Incident Customer name after the loop  : '||l_rec.incident_customer_name , 'get_tooltip_data_gantt', fnd_log.level_statement);
       END IF;
   END IF;
   --end addition for bug 5674408

   l_Res_TimeZone_id:=NULL;
   IF l_task_rec.task_type_id IN(20, 21)
   THEN
     Open  C_Res_TimeZone ;
     Fetch C_Res_TimeZone into l_Res_TimeZone_id;
     Close C_Res_TimeZone ;
     IF l_debug THEN
              debug(' Resource Timezone : '||l_Res_TimeZone_id , 'get_tooltip_data_gantt', fnd_log.level_statement);
       END IF;
     if l_Res_TimeZone_id is not null
     then
       Open  c_res_tz ;
       Fetch c_res_tz into l_res_tz_cd,l_rs_tz_desc;
       Close c_res_tz ;
       IF l_debug THEN
              debug(' Resource Timezone code : '||l_res_tz_cd , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' Resource Timezone Description : '||l_rs_tz_desc , 'get_tooltip_data_gantt', fnd_log.level_statement);
       END IF;
     end  if;
     if p_timezone_enb
     then
       if l_res_tz_cd is not null
       then
         l_ic_planned_start_date   :=fnd_date.adjust_datetime( l_task_rec.planned_start_date,p_server_tz_code,l_res_tz_cd);
         l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_res_tz_cd);
         l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_res_tz_cd);
         l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_res_tz_cd);
         l_tz_desc                 :=l_rs_tz_desc;
         IF l_debug THEN
              debug(' If timezone is enabled and resource time zone exists then : ' , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_start_date : '||to_char(l_ic_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_end_date : '||to_char(l_ic_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_start_date : '||to_char(l_ic_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_end_date : '||to_char(l_ic_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
       END IF;
       end if;
     else
        l_ic_planned_start_date   :=l_task_rec.planned_start_date;
        l_ic_planned_end_date     :=l_task_rec.planned_end_date;
        l_ic_scheduled_start_date :=p_start_date;
        l_ic_scheduled_end_date   :=p_end_date;
        IF l_debug THEN
              debug(' If timezone is note enabled ' , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_start_date : '||to_char(l_ic_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_end_date : '||to_char(l_ic_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_start_date : '||to_char(l_ic_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_end_date : '||to_char(l_ic_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
       END IF;
     end if;
   END IF;

    IF l_task_rec.actual_start_date is  not null
    THEN

      if p_inc_tz_code ='UTZ'and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        IF l_debug THEN
              debug(' Actual start date : '||l_task_rec.actual_start_date , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_start_date : '||to_char(l_dc_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_end_date : '||to_char(l_dc_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_start_date : '||to_char(l_dc_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_end_date : '||to_char(l_dc_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_actual_start_date : '||to_char(l_dc_actual_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_actual_end_date : '||to_char(l_dc_actual_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
      else
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=l_task_rec.scheduled_start_date;
        l_dc_scheduled_end_date   :=l_task_rec.scheduled_end_date;
        l_dc_actual_start_date    :=p_start_date;
        l_dc_actual_end_date      :=p_end_date;
        IF l_debug THEN
              debug(' Incident timezone code is not UTZ and timezone is not enabled ' , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' Actual start date : '||l_task_rec.actual_start_date , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_start_date : '||to_char(l_dc_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_end_date : '||to_char(l_dc_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_start_date : '||to_char(l_dc_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_end_date : '||to_char(l_dc_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_actual_start_date : '||to_char(l_dc_actual_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_actual_end_date : '||to_char(l_dc_actual_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
      end if;
      l_actual_start_date :=l_dc_actual_start_date;
      if l_task_rec.ic_tz_code is not null and  p_timezone_enb
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_actual_start_date       :=l_ic_actual_start_date;
        l_tz_desc                 :=l_task_rec.tz_desc;
        IF l_debug THEN
              debug(' if l_task_rec.ic_tz_code is not null and  p_timezone_enb then the values : ' , 'get_tooltip_data_gantt', fnd_log.level_statement);

              debug(' l_ic_planned_start_date : '||to_char(l_ic_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_end_date : '||to_char(l_ic_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_start_date : '||to_char(l_ic_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_end_date : '||to_char(l_ic_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_actual_start_date : '||to_char(l_ic_actual_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_actual_end_date : '||to_char(l_ic_actual_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
      end if;
      IF l_debug THEN
              debug(' g_uom_minutes : '||g_uom_minutes , 'get_tooltip_data_gantt', fnd_log.level_statement);
      END IF;
      l_rec.departure_time:=
      TO_CHAR(l_actual_start_date - (
                               inv_convert.inv_um_convert(
                                0
                               , NULL
                               , NVL(l_task_rec.actual_travel_duration, 0)
                               , NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes)
                               , g_uom_hours
                               , NULL
                               , NULL
                               )
                             / 24
                            )
                          ,' hh24:mi'
                      );
        IF l_debug THEN
              debug(' Departure Time : '||l_rec.departure_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
        OPEN c_uom(NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes));
        FETCH c_uom INTO l_uom;
        IF c_uom%NOTFOUND THEN
          l_uom  := NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes);
        END IF;
        CLOSE c_uom;

        IF l_debug THEN
              debug(' l_uom : '||l_uom , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;

        l_rec.travel_time := NVL(l_task_rec.actual_travel_duration, 0) || ' ' || l_uom;
        IF l_debug THEN
              debug(' Travel Time : '||l_rec.travel_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
        IF l_debug THEN
              debug(' Arrival Task Id : '||l_arr.task_id , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' Actual Travel Duration : '||l_arr.actual_travel_duration , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
        IF   p_task_id = l_first
           OR p_task_id = l_arr.task_id
        THEN
           IF p_task_id = l_arr.task_id
           THEN
             if l_arr.actual_travel_duration > 0
              then
                 if l_arr.actual_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_arr.actual_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_arr.actual_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := l_arr.actual_travel_duration|| ' ' || l_uom;
                 end if;
              end if;
           ELSE
              if l_task_rec.actual_travel_duration > 0
              then
                 if l_task_rec.actual_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_task_rec.actual_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_task_rec.actual_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := l_task_rec.actual_travel_duration|| ' ' || l_uom;
                 end if;
              end if;
            END IF;
        END IF;
        IF l_debug THEN
              debug(' Official Travel time : '||l_off_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' Personal Travel Time : '||l_per_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
    ELSE
      if p_inc_tz_code ='UTZ'and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        IF l_debug THEN
              debug(' 1. Incident tz code is  UTZ and time zone  enabled ' , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_start_date : '||to_char(l_dc_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_end_date : '||to_char(l_dc_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_start_date : '||to_char(l_dc_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_end_date : '||to_char(l_dc_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);

        END IF;
      else
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=p_start_date;
        l_dc_scheduled_end_date   :=p_end_date;
        IF l_debug THEN
              debug(' 2. Incident tz code is not UTZ and time zone not enabled ' , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_start_date : '||to_char(l_dc_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_planned_end_date : '||to_char(l_dc_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_start_date : '||to_char(l_dc_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_dc_scheduled_end_date : '||to_char(l_dc_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);

        END IF;
      end if;
      l_scheduled_start_date :=l_dc_scheduled_start_date;
      if l_task_rec.ic_tz_code is not null and  p_timezone_enb and  l_task_rec.task_type_id not in (20, 21)
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_scheduled_start_date    :=l_ic_scheduled_start_date;
        l_tz_desc                 :=l_task_rec.tz_desc;
        IF l_debug THEN
              debug(' if l_task_rec.ic_tz_code is not null and  p_timezone_enb and  l_task_rec.task_type_id not in (20, 21) then: ' , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_start_date : '||to_char(l_ic_planned_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_planned_end_date : '||to_char(l_ic_planned_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_start_date : '||to_char(l_ic_scheduled_start_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);
              debug(' l_ic_scheduled_end_date : '||to_char(l_ic_scheduled_end_date,'dd/mm/yyyy hh24:mi') , 'get_tooltip_data_gantt', fnd_log.level_statement);

        END IF;
      elsif l_res_tz_cd is not null and  p_timezone_enb
      then
        l_scheduled_start_date    :=l_ic_scheduled_start_date;
      end if;

      l_rec.departure_time:=
         TO_CHAR(l_scheduled_start_date - (
                               inv_convert.inv_um_convert(
                                 0
                               , NULL
                               , NVL(l_task_rec.sched_travel_duration, 0)
                               , NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes)
                               , g_uom_hours
                               , NULL
                               , NULL
                               )
                             / 24
                            )
                          ,'hh24:mi'
                       );
       IF l_debug THEN
            debug(' 2. Departure Time : '||l_rec.departure_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
         OPEN c_uom(NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes));
    	 FETCH c_uom INTO l_uom;
         IF c_uom%NOTFOUND THEN
            l_uom  := NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes);
         END IF;
         CLOSE c_uom;
         IF l_debug THEN
            debug(' 2. l_uom : '||l_uom , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;

         l_rec.travel_time := NVL(l_task_rec.sched_travel_duration, 0) || ' ' || l_uom;
         IF l_debug THEN
            debug(' 2. Travel Time : '||l_rec.travel_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
        IF l_debug THEN
            debug(' 2. Arrival Task Id : '||l_arr.task_id , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug(' 2. Scheduled Travel Duration : '||l_arr.sched_travel_duration , 'get_tooltip_data_gantt', fnd_log.level_statement);
        END IF;
         IF   p_task_id = l_first
           OR p_task_id = l_arr.task_id
         THEN
            IF p_task_id = l_arr.task_id
            THEN
                if l_arr.sched_travel_duration > 0
                then
                 if l_arr.sched_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_arr.sched_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_arr.sched_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := NVL(l_task_rec.sched_travel_duration, 0) || ' ' || l_uom;
                 end if;
                end if;
            ELSE
                if l_task_rec.sched_travel_duration > 0
                then
                 if l_task_rec.sched_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_task_rec.sched_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_task_rec.sched_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := l_rec.travel_time;
                 end if;
                end if;
            END IF;
        END IF;
    END IF;
    IF l_debug THEN
            debug(' 2. Official Travel Time : '||l_off_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug(' 2. Personal Travel Time : '||l_per_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
    END IF;
    l_rec.assigned_flag           := l_task_rec.assigned_flag;
    l_rec.is_plan_option          := 'N';

    /*test('P_RESOURCE_ID    :'||p_resource_id);

    test('P_RESOURCE_TYPE       :'||p_resource_type   );
    test(' Gps Code : '||CSF_GPS_PUB.IS_GPS_ENABLED);
    test('P_DATE     :'||to_char(p_start_date,'dd-mon-rrrr hh24:mi:ss') );
    IF l_debug THEN
            debug(' Gps Code : '||CSF_GPS_PUB.IS_GPS_ENABLED , 'get_tooltip_data_gantt', fnd_log.level_statement);
    END IF;

    If CSF_GPS_PUB.IS_GPS_ENABLED='Y'
    THEN

    csf_resource_pub.get_location(
     x_return_status      => l_return_status
    ,x_msg_count          => l_msg_count
    ,x_msg_data           => l_msg_data
    ,p_resource_id        => p_resource_id
    ,p_resource_type      => p_resource_type
    ,p_date               => p_start_date
    ,x_creation_date      => l_creation_date
    ,x_feed_time          => l_feed_time
    ,x_status_code        => l_status
    ,x_latitude           => l_latitude
    ,x_longitude          => l_longitude
    ,x_speed              => l_speed
    ,x_direction          => l_direction
    ,x_parked_time        => l_parked_time
    ,x_address            => l_address
    ,x_device_tag         => l_device_tag
    ,x_status_code_meaning=> l_status_code_meaning
    );
    END IF;
    IF l_debug THEN
            debug('l_feed_time    :'||l_feed_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_status       :'||l_status  , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_latitude     :'||l_latitude , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_longitude    :'||l_longitude , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_speed        :'||l_speed , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_direction    :'||l_direction , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_parked_time  :'||l_parked_time , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_address      :'||l_address  , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_creation_date :'||l_creation_date , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_device_tag    :'||l_device_tag , 'get_tooltip_data_gantt', fnd_log.level_statement);
            debug('l_status_code_meaning :'||l_status_code_meaning, 'get_tooltip_data_gantt', fnd_log.level_statement);
    END IF;
    test('l_feed_time    :'||l_feed_time);
    test('l_status       :'||l_status   );
    test('l_latitude     :'||l_latitude );
    test('l_longitude    :'||l_longitude);
    test('l_speed        :'||l_speed    );
    test('l_direction    :'||l_direction);
    test('l_parked_time  :'||l_parked_time);
    test('l_address      :'||l_address  );
    test('l_creation_date :'||l_creation_date);
    test('l_device_tag    :'||l_device_tag);
    test('l_status_code_meaning :'||l_status_code_meaning);
    */


         l_str :=
          '<TOOLTIP>'
          || '<CENTER fgColor='
          || 0
          || '>'
          || l_task_rec.task_name
          || '</CENTER>'
          || '<LINE></LINE>'
          || '<LABEL>'
          || g_task_number
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.task_number
          || '</VALUE>'
          || '<LABEL>'
          || g_task_type
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.task_type
          || '</VALUE>'
          || '<LABEL>'
          || g_task_status
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.task_status
          || '</VALUE>';
    /*
          If CSF_GPS_PUB.IS_GPS_ENABLED='Y'
          THEN
           l_str :=l_str|| '<LINE></LINE>'
          ||'<LABEL>'
          || g_tech_status
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_status_code_meaning
          || '</VALUE>'
          ||'<LABEL>'
          || g_tech_lat
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_latitude
          || '</VALUE>'
          ||'<LABEL>'
          || g_tech_lon
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_longitude
          || '</VALUE>'
          || '<LABEL>'
          ||  g_address
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_address
          || '</VALUE>'
          ||'<LABEL>'
          || g_tech_dev_tag
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_device_tag
          || '</VALUE>';
          END IF;
		  */
          l_str :=l_str
          || '<LINE></LINE>'
          || '<LABEL>'
          || g_cust_name
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.incident_customer_name
          || '</VALUE>'
          || '<LABEL>'
          ||  g_address
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.small_address
          || '</VALUE>';

    IF  p_timezone_enb
    THEN
          l_str :=
          l_str
          || '<LABEL>'
          || g_timezone
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_tz_desc
          || '</VALUE>';
    END IF;
    IF l_sr_rec.product_name IS NOT NULL THEN
        l_str  :=
        l_str
          || '<LABEL>'
          || g_product_name
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_sr_rec.product_name
          || '</VALUE>';
      IF l_ib_rec.serial_number IS NOT NULL THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_serial
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_ib_rec.serial_number
          || '</VALUE>';
      END IF;
    END IF;
    IF  p_timezone_enb
    THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_planned_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_planned_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_planned_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_planned_effort
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_planned_effort
          || '</VALUE>'
          || '<LABEL>'
          || g_sched_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_scheduled_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_scheduled_end_date,g_date_format||' hh24:mi')
          || '</VALUE>';
        IF l_task_rec.actual_start_date IS NOT NULL THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_actual_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_actual_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_actual_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_actual_effort
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_actual_effort
          || '</VALUE>';

        END IF;
        l_rs_ic_tz_present :=true;
        If (l_task_rec.ic_tz_code is null and l_task_rec.task_type_id not IN (20, 21)) or (l_res_tz_cd is null and l_task_rec.task_type_id IN(20, 21))
        Then
          l_str :=
          l_str|| '<LINE></LINE>';
          l_rs_ic_tz_present:=false;
        end if;
    ELSE
          l_str :=
          l_str|| '<LINE></LINE>';
    END IF;
    IF l_rs_ic_tz_present
    THEN
          l_str :=
          l_str
          || '<LABEL>'
          || g_departure
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.departure_time
          || '</VALUE>'
          || '<LABEL>'
          || g_travel_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.travel_time
          || '</VALUE>';
    IF g_commute = 'PARTIAL'
    THEN
          l_str :=
          l_str
          || '<LABEL>'
          || g_off_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_off_time
          || '</VALUE>'
          || '<LABEL>'
          || g_per_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_per_time
          || '</VALUE>';
    END IF;
            l_str  :=
            l_str|| '<LINE></LINE>';
     END IF;
          l_str  :=
          l_str
          || '<LABEL>'
          || g_planned_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_planned_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_planned_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_sched_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_scheduled_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_scheduled_end_date,g_date_format||' hh24:mi')
          || '</VALUE>';
    IF l_task_rec.actual_start_date IS NOT NULL THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_actual_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_actual_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_actual_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          ;
    END IF;
    IF l_rs_ic_tz_present = false OR p_timezone_enb=False
    THEN
          l_str :=
          l_str
          || '<LABEL>'
          || g_departure
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.departure_time
          || '</VALUE>'
          || '<LABEL>'
          || g_travel_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.travel_time
          || '</VALUE>';
    IF g_commute = 'PARTIAL'
    THEN
          l_str :=
          l_str
          || '<LABEL>'
          || g_off_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_off_time
          || '</VALUE>'
          || '<LABEL>'
          || g_per_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_per_time
          || '</VALUE>';
      END IF;
     END IF;
    l_str  :=l_str|| '</TOOLTIP>';
    IF l_debug THEN
            debug(' Tooltip string :'||l_str , 'get_tooltip_data_gantt', fnd_log.level_statement);
   END IF;
    RETURN l_str;
  END get_tooltip_data_gantt;
  FUNCTION get_tooltip_data_gantt_cust(
    p_task_id        NUMBER
  , p_resource_id    NUMBER
  , p_resource_type  VARCHAR2
  , p_start_date     DATE
  , p_end_date       DATE
  , p_inc_tz_code    VARCHAR2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  )
    RETURN VARCHAR2 IS

     CURSOR c_cust_tooltip is
      SELECT field_name
        FROM csf_gantt_chart_setup
       WHERE user_id = fnd_global.user_id
         AND setup_type = 'TOOLTIP'
      ORDER BY seq_no;

     CURSOR c_cust_default_tooltip is
     SELECT field_name
        FROM csf_gantt_chart_setup
       WHERE user_id = -1
         AND setup_type = 'TOOLTIP'
      ORDER BY seq_no;


    -- task and task assignment data
    CURSOR c_task IS
      SELECT /*+ ORDERED use_nl (a tb tt tl sb sl pi ps hl ft)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             tb.task_id
           , tl.task_name
           , tb.task_number
           , tb.source_object_type_code
           , tb.source_object_id
           , tt.NAME task_type
           , sl.NAME task_status
           , a.resource_id
           , a.resource_type_code resource_type
           , tb.planned_start_date
           , tb.planned_end_date
           , scheduled_start_date
           , scheduled_end_date
           , a.actual_start_date
           , a.actual_end_date
           , a.sched_travel_duration
           , a.sched_travel_duration_uom
           , tb.customer_id party_id
           , NVL(sb.assigned_flag, 'N') assigned_flag
           , tb.task_type_id
           , csf_tasks_pub.get_task_address(tb.task_id,tb.address_id,tb.location_id,'Y') small_address
           , pi.party_name party_name
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , tz.ACTIVE_TIMEZONE_CODE ic_tz_code
           , tz.ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
           , tb.planned_effort ||' '|| tb.planned_effort_uom plan_effort
           , tb.actual_effort ||' '|| tb.actual_effort_uom   act_effort
        FROM jtf_task_assignments a
           , jtf_tasks_b tb
           , jtf_task_types_tl tt
           , jtf_tasks_tl tl
           , jtf_task_statuses_b sb
           , jtf_task_statuses_tl sl
           , hz_party_sites ps
           , hz_locations hl
           , hz_parties pi
           , fnd_timezones_b tz
       WHERE a.task_id = p_task_id
         AND resource_id = p_resource_id
         AND resource_type_code = p_resource_type
         AND tb.task_id = a.task_id
         AND tt.LANGUAGE = l_language
         AND tt.task_type_id = tb.task_type_id
         AND sl.LANGUAGE = l_language
         AND sb.task_status_id = a.assignment_status_id
         AND sl.task_status_id = sb.task_status_id
         AND tl.LANGUAGE = l_language
         AND tl.task_id = tb.task_id
         AND ps.party_site_id(+) = tb.address_id
         AND hl.location_id(+) = ps.location_id
         AND pi.party_id(+) = tb.customer_id
         AND NVL(sb.cancelled_flag, 'N') <> 'Y'
         AND tz.UPGRADE_TZ_ID(+) = hl.timezone_id;

    CURSOR c_sr(b_incident_id NUMBER) IS
      SELECT /*+ ORDERED USE_NL */
             i.customer_product_id
           , i.current_serial_number
           , si.concatenated_segments product_name
        FROM cs_incidents_all_b i, mtl_system_items_kfv si
       WHERE si.inventory_item_id(+) = i.inventory_item_id
         AND si.organization_id(+) = i.inv_organization_id
         AND i.incident_id = b_incident_id;

    l_uom       VARCHAR2(2000)        := NULL;
    l_Res_Timezone_id   Number;
    l_res_tz_cd varchar2(100);
    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;

    CURSOR c_parts(b_task_id NUMBER) IS
      SELECT 'Y' required
        FROM csp_requirement_headers
       WHERE task_id = b_task_id;

    CURSOR c_ib(b_customer_product_id NUMBER) IS
      SELECT serial_number
           , lot_number
        FROM csi_item_instances
       WHERE instance_id = b_customer_product_id;

    Cursor C_Res_TimeZone Is
     Select TIME_ZONE
     From JTF_RS_RESOURCE_EXTNS
     Where RESOURCE_ID = p_resource_id
     ;
    Cursor c_res_tz
    IS
     SELECT ACTIVE_TIMEZONE_CODE,ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
     FROM fnd_timezones_vl ft
     WHERE UPGRADE_TZ_ID =l_Res_TimeZone_id;

     Cursor c_trip
     IS
        SELECT   object_capacity_id
          FROM   jtf_task_assignments ja
               , jtf_tasks_b jb
         WHERE   ja.task_id = jb.task_id
           AND   ja.task_id = p_task_id
           AND   jb.task_type_id not in (20,21)
		   AND   ja.object_capacity_id is not null
		   and   nvl(jb.deleted_flag,'N') <> 'Y';

     Cursor  c_tasks(l_capacity number)
     IS
       SELECT ja.task_id
         FROM jtf_task_assignments ja ,
              jtf_tasks_b jb                ,
              jtf_task_statuses_b js
        WHERE ja.task_id                  = jb.task_id
          AND js.task_status_id           = jb.task_status_id
          AND ja.object_capacity_id       = l_capacity
          AND ja.resource_id              = p_resource_id
          AND NVL(js.cancelled_flag,'N') <> 'Y'
          AND NVL(js.rejected_flag,'N')  <> 'Y'
          AND NVL(jb.deleted_flag,'N')   <> 'Y'
          AND jb.task_type_id NOT        IN (20,21)
          AND ja.object_capacity_id      IS NOT NULL
      ORDER BY NVL(ja.actual_start_date,jb.scheduled_start_date);

      Cursor c_arr
    IS
       SELECT  ja.task_id
             , ja.actual_travel_duration
             , ja.sched_travel_duration
             , ja.actual_travel_duration_uom
             , ja.sched_travel_duration_uom
         FROM jtf_task_assignments ja ,
              jtf_tasks_b jb
        WHERE ja.task_id        = jb.task_id
         AND jb.task_type_id      IN (21)
         AND ja.task_id= p_task_id;

    Cursor c_terr
	IS
	   SELECT territory_id
   	     FROM csf_dc_resources_v
	    WHERE resource_id = p_resource_id
	      AND resource_type   = p_resource_type;

    l_task_rec  c_task%ROWTYPE;
    l_sr_rec    c_sr%ROWTYPE;
    l_parts_rec c_parts%ROWTYPE;
    l_ib_rec    c_ib%ROWTYPE;
    l_rec       tooltip_data_rec_type := NULL;
    p_color     NUMBER                := 255;
    l_str       VARCHAR2(4000)        := NULL;

    l_ic_planned_start_date   date;
    l_ic_planned_end_date     date;
    l_ic_scheduled_start_date date;
    l_ic_scheduled_end_date   date;
    l_ic_actual_start_date    date;
    l_ic_actual_end_date      date;


    l_dc_planned_start_date   date;
    l_dc_planned_end_date     date;
    l_dc_scheduled_start_date date;
    l_dc_scheduled_end_date   date;
    l_dc_actual_start_date    date;
    l_dc_actual_end_date      date;
    l_actual_start_date       date;
    l_scheduled_start_date    date;
    l_tz_desc                 varchar2(100);
    l_rs_tz_desc              varchar2(100);
    l_rs_ic_tz_present        boolean;
    l_lines                   number;                --bug no 5674408
    l_off_time                varchar2(200);
    l_per_time                varchar2(200);
    l_planned_effort          varchar2(200);
    l_actual_effort           varchar2(200);
    l_task_tbl                jtf_number_table;
    l_capacity                number;
    i                         number;
    j                         number;
    l_first                   number;
    l_last                    number;
	  l_territory               number;
	  l_arr                     c_arr%rowtype;

    l_feed_time               varchar2(100);
    l_status                  varchar2(100);
    l_latitude                varchar2(100);
    l_longitude               varchar2(100);
    l_speed                   varchar2(100);
    l_direction               varchar2(100);
    l_parked_time             varchar2(100);
    l_address                 varchar2(100);
    l_creation_date           varchar2(100);
    l_device_tag              varchar2(100);
    l_status_code_meaning     varchar2(100);
    l_return_status           varchar2(2);
    l_msg_count               NUMBER;
    l_msg_data                varchar2(100);

    g_tooltip_fields 		  VARCHAR2(4000);
    l_count     			  NUMBER;
    l_field     			  VARCHAR2(2000);
    l_var     				  VARCHAR2(2000);


  BEGIN


  open c_terr;
	fetch c_terr into l_territory;
	close c_terr;

    g_excl_travel := csr_scheduler_pub.get_sch_parameter_value(  'spCommuteExcludedTime'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );
   g_commute := csr_scheduler_pub.get_sch_parameter_value(  'spCommutesPosition'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );

    OPEN c_task;
    FETCH c_task INTO l_task_rec;
    IF c_task%NOTFOUND THEN
      CLOSE c_task;

      RAISE NO_DATA_FOUND;
    END IF;
    l_task_tbl := jtf_number_table();

    OPEN c_trip;
    FETCH c_trip into l_capacity;
    CLOSE c_trip;

    OPEN c_tasks(l_capacity);
    FETCH c_tasks BULK COLLECT INTO l_task_tbl;
    CLOSE c_tasks;

    IF l_task_tbl.count > 0
    THEN
      i := l_task_tbl.FIRST;
      j := l_task_tbl.LAST;
      l_first := l_task_tbl(i);
      l_last := l_task_tbl(j);
    END IF;

    open c_arr;
    fetch c_arr into l_arr;
    close c_arr;

    IF l_task_rec.task_type_id NOT IN(20, 21)
    THEN
      l_planned_effort := l_task_rec.plan_effort;
      l_actual_effort  := l_task_rec.act_effort;

      IF l_task_rec.scheduled_start_date <> l_task_rec.scheduled_end_date
      THEN
        IF (   l_task_rec.scheduled_start_date <> p_start_date
            OR l_task_rec.scheduled_end_date <> p_end_date
           )
        AND  l_task_rec.actual_start_date is null
        THEN
          CLOSE c_task;

          RAISE NO_DATA_FOUND;
        END IF;
      END IF;
      OPEN c_sr(l_task_rec.source_object_id);
      FETCH c_sr INTO l_sr_rec;

      IF l_sr_rec.customer_product_id IS NOT NULL THEN
        OPEN c_ib(l_sr_rec.customer_product_id);
        FETCH c_ib INTO l_ib_rec;
        CLOSE c_ib;
      ELSE
        l_ib_rec.serial_number  := l_sr_rec.current_serial_number;
        l_ib_rec.lot_number     := NULL;   -- not yet supported
      END IF;
   END IF;
   l_rec.incident_customer_name  := l_task_rec.party_name;

   --begin addition for bug 5674408
   IF (LENGTH(NVL(l_task_rec.party_name, 0)) > 80)
   THEN
       l_lines := ceil(length(l_task_rec.party_name)/80) - 1;
       l_rec.incident_customer_name := null;

       for i in 1..l_lines
       loop
           l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1, 80) || fnd_global.local_chr (10);
           l_task_rec.party_name := substrb(l_task_rec.party_name,81);
       end loop;

       l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1);
   END IF;
   --end addition for bug 5674408

   l_Res_TimeZone_id:=NULL;
   IF l_task_rec.task_type_id IN(20, 21)
   THEN
     Open  C_Res_TimeZone ;
     Fetch C_Res_TimeZone into l_Res_TimeZone_id;
     Close C_Res_TimeZone ;

     if l_Res_TimeZone_id is not null
     then
       Open  c_res_tz ;
       Fetch c_res_tz into l_res_tz_cd,l_rs_tz_desc;
       Close c_res_tz ;
     end  if;
     if p_timezone_enb
     then
       if l_res_tz_cd is not null
       then
         l_ic_planned_start_date   :=fnd_date.adjust_datetime( l_task_rec.planned_start_date,p_server_tz_code,l_res_tz_cd);
         l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_res_tz_cd);
         l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_res_tz_cd);
         l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_res_tz_cd);
         l_tz_desc                 :=l_rs_tz_desc;
       end if;
     else
        l_ic_planned_start_date   :=l_task_rec.planned_start_date;
        l_ic_planned_end_date     :=l_task_rec.planned_end_date;
        l_ic_scheduled_start_date :=p_start_date;
        l_ic_scheduled_end_date   :=p_end_date;
     end if;
   END IF;

    IF l_task_rec.actual_start_date is  not null
    THEN

      if p_inc_tz_code ='UTZ'and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
      else
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=l_task_rec.scheduled_start_date;
        l_dc_scheduled_end_date   :=l_task_rec.scheduled_end_date;
        l_dc_actual_start_date    :=p_start_date;
        l_dc_actual_end_date      :=p_end_date;
      end if;
      l_actual_start_date :=l_dc_actual_start_date;
      if l_task_rec.ic_tz_code is not null and  p_timezone_enb
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_actual_start_date       :=l_ic_actual_start_date;
        l_tz_desc                 :=l_task_rec.tz_desc;
      end if;

      l_rec.departure_time:=
      TO_CHAR(l_actual_start_date - (
                               inv_convert.inv_um_convert(
                                0
                               , NULL
                               , NVL(l_task_rec.actual_travel_duration, 0)
                               , NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes)
                               , g_uom_hours
                               , NULL
                               , NULL
                               )
                             / 24
                            )
                          ,' hh24:mi'
                      );

        OPEN c_uom(NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes));
        FETCH c_uom INTO l_uom;
        IF c_uom%NOTFOUND THEN
          l_uom  := NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes);
        END IF;
        CLOSE c_uom;

        l_rec.travel_time := NVL(l_task_rec.actual_travel_duration, 0) || ' ' || l_uom;
        IF   p_task_id = l_first
           OR p_task_id = l_arr.task_id
        THEN
           IF p_task_id = l_arr.task_id
           THEN
             if l_arr.actual_travel_duration > 0
              then
                 if l_arr.actual_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_arr.actual_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_arr.actual_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := l_arr.actual_travel_duration|| ' ' || l_uom;
                 end if;
              end if;
           ELSE
              if l_task_rec.actual_travel_duration > 0
              then
                 if l_task_rec.actual_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_task_rec.actual_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_task_rec.actual_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := l_task_rec.actual_travel_duration|| ' ' || l_uom;
                 end if;
              end if;
            END IF;
        END IF;
    ELSE
      if p_inc_tz_code ='UTZ'and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
      else
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=p_start_date;
        l_dc_scheduled_end_date   :=p_end_date;
      end if;
      l_scheduled_start_date :=l_dc_scheduled_start_date;
      if l_task_rec.ic_tz_code is not null and  p_timezone_enb and  l_task_rec.task_type_id not in (20, 21)
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_scheduled_start_date    :=l_ic_scheduled_start_date;
        l_tz_desc                 :=l_task_rec.tz_desc;
      elsif l_res_tz_cd is not null and  p_timezone_enb
      then
        l_scheduled_start_date    :=l_ic_scheduled_start_date;
      end if;

      l_rec.departure_time:=
         TO_CHAR(l_scheduled_start_date - (
                               inv_convert.inv_um_convert(
                                 0
                               , NULL
                               , NVL(l_task_rec.sched_travel_duration, 0)
                               , NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes)
                               , g_uom_hours
                               , NULL
                               , NULL
                               )
                             / 24
                            )
                          ,'hh24:mi'
                       );

         OPEN c_uom(NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes));
    	 FETCH c_uom INTO l_uom;
         IF c_uom%NOTFOUND THEN
            l_uom  := NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes);
         END IF;
         CLOSE c_uom;
         l_rec.travel_time := NVL(l_task_rec.sched_travel_duration, 0) || ' ' || l_uom;
         IF   p_task_id = l_first
           OR p_task_id = l_arr.task_id
         THEN
            IF p_task_id = l_arr.task_id
            THEN
                if l_arr.sched_travel_duration > 0
                then
                 if l_arr.sched_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_arr.sched_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_arr.sched_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := NVL(l_task_rec.sched_travel_duration, 0) || ' ' || l_uom;
                 end if;
                end if;
            ELSE
                if l_task_rec.sched_travel_duration > 0
                then
                 if l_task_rec.sched_travel_duration >  to_number(g_excl_travel)
                 then
                   l_off_time := (l_task_rec.sched_travel_duration - to_number(g_excl_travel)) || ' ' || l_uom;
                   l_per_time := g_excl_travel || ' ' || l_uom;
                 elsif l_task_rec.sched_travel_duration < to_number(g_excl_travel)
                 then
                  l_per_time := l_rec.travel_time;
                 end if;
                end if;
            END IF;
        END IF;
    END IF;
    l_rec.assigned_flag           := l_task_rec.assigned_flag;
    l_rec.is_plan_option          := 'N';



    /*test('P_RESOURCE_ID    :'||p_resource_id);

    test('P_RESOURCE_TYPE       :'||p_resource_type   );
    test(' Gps Code : '||CSF_GPS_PUB.IS_GPS_ENABLED);
    test('P_DATE     :'||to_char(p_start_date,'dd-mon-rrrr hh24:mi:ss') );
*/

    If CSF_GPS_PUB.IS_GPS_ENABLED='Y'
    THEN

    csf_resource_pub.get_location(
     x_return_status      => l_return_status
    ,x_msg_count          => l_msg_count
    ,x_msg_data           => l_msg_data
    ,p_resource_id        => p_resource_id
    ,p_resource_type      => p_resource_type
    ,p_date               => p_start_date
    ,x_creation_date      => l_creation_date
    ,x_feed_time          => l_feed_time
    ,x_status_code        => l_status
    ,x_latitude           => l_latitude
    ,x_longitude          => l_longitude
    ,x_speed              => l_speed
    ,x_direction          => l_direction
    ,x_parked_time        => l_parked_time
    ,x_address            => l_address
    ,x_device_tag         => l_device_tag
    ,x_status_code_meaning=> l_status_code_meaning
    );
    END IF;
  /*
    test('l_feed_time    :'||l_feed_time);
    test('l_status       :'||l_status   );
    test('l_latitude     :'||l_latitude );
    test('l_longitude    :'||l_longitude);
    test('l_speed        :'||l_speed    );
    test('l_direction    :'||l_direction);
    test('l_parked_time  :'||l_parked_time);
    test('l_address      :'||l_address  );
    test('l_creation_date :'||l_creation_date);
    test('l_device_tag    :'||l_device_tag);
    test('l_status_code_meaning :'||l_status_code_meaning);
    */

    for tooltip_rec in c_cust_tooltip
    loop
      g_tooltip_fields := g_tooltip_fields || '-' || tooltip_rec.field_name;

      l_count:= nvl(l_count,0) + 1;
    end loop;
    if g_tooltip_fields is null then
       for tooltip_rec in c_cust_default_tooltip
       loop
        g_tooltip_fields := g_tooltip_fields || '-' || tooltip_rec.field_name;

         l_count:= nvl(l_count,0) + 1;
       end loop;
    end if;

    g_tooltip_fields := l_count || g_tooltip_fields || '-';

    if g_tooltip_fields is not null and length(g_tooltip_fields) > 2
    then

      l_count := substr(g_tooltip_fields,1,instr(g_tooltip_fields,'-')-1);

      l_var   := substr(g_tooltip_fields,instr(g_tooltip_fields,'-')+1);

	  l_str :='<TOOLTIP>';
        for i in 1..l_count
        loop
          l_field := substr(l_var,1,instr(l_var,'-')-1);

          l_var := substr(l_var,instr(l_var,'-')+1);

          if l_field = 'TASK_NAME'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_name
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_name
                || '</VALUE>';
          elsif  l_field = 'TASK_NUMBER'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_number
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_number
                || '</VALUE>';
          elsif l_field = 'TASK_TYPE'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_type
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_type
                || '</VALUE>';
          elsif l_field = 'ASSIGNMENT_STATUS'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_status
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_status
                || '</VALUE>';
          elsif l_field = 'TECHNICIAN_STATUS' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
          then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_status
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_status_code_meaning
                || '</VALUE>';
           elsif l_field = 'LATITUDE' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
           then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_lat
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_latitude
                || '</VALUE>';
           elsif l_field = 'LOGITUDE' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
           then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_lon
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_longitude
                || '</VALUE>';
            elsif l_field = 'RESOURCE_GPS_ADD' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
            then
                l_str :=l_str
                || '<LABEL>'
                ||  g_tech_cur_add
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_address
                || '</VALUE>';
            elsif l_field = 'GPS_DEVICE_TAG' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
            then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_dev_tag
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_device_tag
                || '</VALUE>';
            elsif l_field = 'CUSTOMER_NAME'
            then
                l_str :=l_str
                || '<LABEL>'
                || g_cust_name
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_rec.incident_customer_name
                || '</VALUE>';
             elsif l_field = 'ADDRESS'
             then
                l_str :=l_str
                || '<LABEL>'
                ||  g_address
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.small_address
                || '</VALUE>';
             elsif l_field = 'TIMEZONE' AND p_timezone_enb
             then
                l_str :=l_str
                || '<LABEL>'
                || g_timezone
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_tz_desc
                || '</VALUE>';
             elsif l_field = 'PRODUCT_NAME'
             then
              l_str := l_str
                || '<LABEL>'
                || g_product_name
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_sr_rec.product_name
                || '</VALUE>';

             elsif l_field = 'SERIAL_NO'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_serial
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_ib_rec.serial_number
                || '</VALUE>';
             elsif l_field = 'PLANNED_START'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_plan_start_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_planned_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'PLANNED_END'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_plan_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_planned_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'PLANNED_EFFORT'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_planned_effort
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_planned_effort
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_START'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_sched_start_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_scheduled_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_END'    AND   p_timezone_enb
             then
                 l_str  :=l_str
                || '<LABEL>'
                || g_end
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_scheduled_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_START'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_actul_start_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_actual_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_END'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_actul_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_actual_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_EFFORT'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_actual_effort
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_actual_effort
                || '</VALUE>';
             elsif l_field = 'PLANNED_START_DATE_DC'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_planned_start
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_planned_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'PLANNED_END_DATE_DC'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_dc_plan_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_planned_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_START_DATE_DC'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_sched_start
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_scheduled_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_END_DATE_DC'
             then
                 l_str  :=l_str
                || '<LABEL>'
                || g_dc_sched_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_scheduled_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_START_DATE_DC'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_actual_start
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_actual_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_END_DATE_DC'
             then

                l_str  :=l_str
                || '<LABEL>'
                || g_dc_actul_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_actual_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';

             elsif l_field = 'DEPARTURE_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_departure
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_rec.departure_time
                || '</VALUE>';
             elsif l_field = 'TRAVEL_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_travel_time
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_rec.travel_time
                || '</VALUE>';
             elsif l_field = 'COMMUTE_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_off_time
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_off_time
                || '</VALUE>';
             elsif l_field = 'PERSONAL_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_per_time
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_per_time
                || '</VALUE>';
             elsif l_field like 'LINE%'
             then
                 l_str :=l_str|| '<LINE></LINE>';
             end if;
        end loop;
     END IF;-- This is end if for g_tooltip_fields is not null and length(g_tooltip_fields) > 2
	 l_str  :=l_str|| '</TOOLTIP>';

    RETURN l_str;
  END get_tooltip_data_gantt_cust;

  FUNCTION get_tooltip_data_sch_advise(
    p_task_id       NUMBER
  , p_resource_id   NUMBER
  , p_resource_type VARCHAR2
  , p_start_date    DATE
  , p_end_date      DATE
  , p_duration      NUMBER
  , sch_adv_tz      varchar2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  , p_inc_tz_desc    varchar2
  , p_inc_tz_code    VARCHAR2
  )
  RETURN VARCHAR2 IS
  -- task and task assignment data
    CURSOR c_task IS
      SELECT /*+ ORDERED use_nl (a tb tt tl sb sl pi ps hl ft)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             tb.task_id
           , tl.task_name
           , tb.task_number
           , tb.source_object_type_code
           , tb.source_object_id
           , tt.NAME task_type
           , sl.NAME task_status
           , a.resource_id
           , a.resource_type_code resource_type
           , tb.planned_start_date
           , tb.planned_end_date
           , scheduled_start_date
           , scheduled_end_date
           , a.actual_start_date
           , a.actual_end_date
           , a.sched_travel_duration
           , a.sched_travel_duration_uom
           , tb.customer_id party_id
           , NVL(sb.assigned_flag, 'N') assigned_flag
           , tb.task_type_id
           , csf_tasks_pub.get_task_address(tb.task_id,tb.address_id,tb.location_id,'Y') small_address
           , pi.party_name party_name
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , tz.ACTIVE_TIMEZONE_CODE ic_tz_code
           , tz.ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
           , tb.planned_effort ||' '|| tb.planned_effort_uom plan_effort
           , tb.actual_effort ||' '|| tb.actual_effort_uom  act_effort
        FROM jtf_task_assignments a
           , jtf_tasks_b tb
           , jtf_task_types_tl tt
           , jtf_tasks_tl tl
           , jtf_task_statuses_b sb
           , jtf_task_statuses_tl sl
           , hz_party_sites ps
           , hz_locations hl
           , hz_parties pi
           , fnd_timezones_b tz
       WHERE a.task_id = p_task_id
         AND resource_id = p_resource_id
         AND resource_type_code = p_resource_type
         AND tb.task_id = a.task_id
         AND tt.LANGUAGE = l_language
         AND tt.task_type_id = tb.task_type_id
         AND sl.LANGUAGE = l_language
         AND sb.task_status_id = a.assignment_status_id
         AND sl.task_status_id = sb.task_status_id
         AND tl.LANGUAGE = l_language
         AND tl.task_id = tb.task_id
         AND ps.party_site_id(+) = tb.address_id
         AND hl.location_id(+) = ps.location_id
         AND pi.party_id(+) = tb.customer_id
         AND NVL(sb.cancelled_flag, 'N') <> 'Y'
	 AND tz.UPGRADE_TZ_ID(+) = hl.timezone_id;

    CURSOR c_sr(b_incident_id NUMBER) IS
      SELECT /*+ ORDERED USE_NL */
             i.customer_product_id
           , i.current_serial_number
           , si.concatenated_segments product_name
        FROM cs_incidents_all_b i, mtl_system_items_kfv si
       WHERE si.inventory_item_id(+) = i.inventory_item_id
         AND si.organization_id(+) = i.inv_organization_id
         AND i.incident_id = b_incident_id;

    l_uom       VARCHAR2(2000)        := NULL;
    l_Res_Timezone_id   Number;
    l_res_tz_cd varchar2(100);
    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;

    CURSOR c_parts(b_task_id NUMBER) IS
      SELECT 'Y' required
        FROM csp_requirement_headers
       WHERE task_id = b_task_id;

    CURSOR c_ib(b_customer_product_id NUMBER) IS
      SELECT serial_number
           , lot_number
        FROM csi_item_instances
       WHERE instance_id = b_customer_product_id;

    Cursor C_Res_TimeZone Is
     Select TIME_ZONE
     From JTF_RS_RESOURCE_EXTNS
     Where RESOURCE_ID = p_resource_id
     ;
    Cursor c_res_tz
    IS
     SELECT ACTIVE_TIMEZONE_CODE,ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
     FROM fnd_timezones_vl ft
     WHERE UPGRADE_TZ_ID =l_Res_TimeZone_id;

	  Cursor c_terr
	IS
	   SELECT territory_id
   	     FROM csf_dc_resources_v
	    WHERE resource_id = p_resource_id
	      AND resource_type   = p_resource_type;




    l_task_rec  c_task%ROWTYPE;
    l_sr_rec    c_sr%ROWTYPE;
    l_parts_rec c_parts%ROWTYPE;
    l_ib_rec    c_ib%ROWTYPE;
    l_rec       tooltip_data_rec_type := NULL;
    p_color     NUMBER                := 255;
    l_str       VARCHAR2(2000)        := NULL;
    l_ic_planned_start_date   date;
    l_ic_planned_end_date     date;
    l_ic_scheduled_start_date date;
    l_ic_scheduled_end_date   date;
    l_ic_actual_start_date    date;
    l_ic_actual_end_date      date;


    l_dc_planned_start_date   date;
    l_dc_planned_end_date     date;
    l_dc_scheduled_start_date date;
    l_dc_scheduled_end_date   date;
    l_dc_actual_start_date    date;
    l_dc_actual_end_date      date;
    l_actual_start_date       date;
    l_scheduled_start_date    date;
    l_tz_desc                 varchar2(100);
    l_rs_tz_desc              varchar2(100);
    l_rs_ic_tz_present        boolean;
    l_lines                             number;                --bug no 5674408
    l_actual_effort           VARCHAR2(200);
    l_planned_effort          VARCHAR2(200);
    l_territory               NUMBER;

    l_feed_time               varchar2(100);
    l_status                  varchar2(100);
    l_latitude                varchar2(100);
    l_longitude               varchar2(100);
    l_speed                   varchar2(100);
    l_direction               varchar2(100);
    l_parked_time             varchar2(100);
    l_address                 varchar2(100);
    l_creation_date           varchar2(100);
    l_device_tag              varchar2(100);
    l_status_code_meaning     varchar2(100);
    l_return_status           varchar2(2);
    l_msg_count               NUMBER;
    l_msg_data                varchar2(100);

  BEGIN

    open c_terr;
	fetch c_terr into l_territory;
	close c_terr;
    g_excl_travel := csr_scheduler_pub.get_sch_parameter_value(  'spCommuteExcludedTime'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );
   g_commute := csr_scheduler_pub.get_sch_parameter_value(  'spCommutesPosition'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );
    OPEN c_task;
    FETCH c_task INTO l_task_rec;
    IF c_task%NOTFOUND THEN
      CLOSE c_task;
      RAISE NO_DATA_FOUND;
    END IF;

    IF l_task_rec.task_type_id NOT IN(20, 21)
    THEN
      l_planned_effort := l_task_rec.plan_effort;
      l_actual_effort := l_task_rec.act_effort;
      OPEN c_sr(l_task_rec.source_object_id);
      FETCH c_sr INTO l_sr_rec;

      IF l_sr_rec.customer_product_id IS NOT NULL THEN
        OPEN c_ib(l_sr_rec.customer_product_id);
        FETCH c_ib INTO l_ib_rec;
        CLOSE c_ib;
      ELSE
        l_ib_rec.serial_number  := l_sr_rec.current_serial_number;
        l_ib_rec.lot_number     := NULL;   -- not yet supported
      END IF;
    END IF;
    l_rec.incident_customer_name  := l_task_rec.party_name;

    --begin addition for bug 5674408
    IF (LENGTH(NVL(l_task_rec.party_name, 0)) > 80)
    THEN
        l_lines := ceil(length(l_task_rec.party_name)/80) - 1;
        l_rec.incident_customer_name := null;

        for i in 1..l_lines
        loop
            l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1, 80) || fnd_global.local_chr (10);
            l_task_rec.party_name := substrb(l_task_rec.party_name,81);
        end loop;

        l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1);
    END IF;
    --end addition for bug 5674408

    IF l_task_rec.actual_start_date is  not null
    THEN

      if sch_adv_tz ='UTZ' and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_actual_start_date       :=l_dc_actual_start_date;
        if l_task_rec.ic_tz_code is not null and  p_timezone_enb
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_actual_start_date       :=l_ic_actual_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='CTZ' and  p_timezone_enb
      then
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=l_task_rec.scheduled_start_date;
        l_dc_scheduled_end_date   :=l_task_rec.scheduled_end_date;
        l_dc_actual_start_date    :=p_start_date;
        l_dc_actual_end_date      :=p_end_date;

        l_actual_start_date       :=l_dc_actual_start_date;
        if l_task_rec.ic_tz_code is not null and p_timezone_enb
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_actual_start_date       :=l_ic_actual_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='ITZ' and  p_timezone_enb
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_actual_start_date       :=l_ic_actual_start_date;
        l_tz_desc                 := p_inc_tz_desc;
      end if;

      l_rec.departure_time:=
      TO_CHAR(l_actual_start_date - (
                               inv_convert.inv_um_convert(
                                0
                               , NULL
                               , NVL(l_task_rec.actual_travel_duration, 0)
                               , NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes)
                               , g_uom_hours
                               , NULL
                               , NULL
                               )
                             / 24
                            )
                          ,' hh24:mi'
                      );
        OPEN c_uom(NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes));
        FETCH c_uom INTO l_uom;
        IF c_uom%NOTFOUND THEN
          l_uom  := NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes);
        END IF;
        CLOSE c_uom;
        l_rec.travel_time := NVL(l_task_rec.actual_travel_duration, 0) || ' ' || l_uom;
    ELSE
      if sch_adv_tz ='UTZ' and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_scheduled_start_date    :=l_dc_scheduled_start_date;
        if l_task_rec.ic_tz_code is not null
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_scheduled_start_date    :=l_ic_scheduled_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='CTZ'  and  p_timezone_enb
      then
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=p_start_date;
        l_dc_scheduled_end_date   :=p_end_date;
        l_scheduled_start_date    :=l_dc_scheduled_start_date;
        if l_task_rec.ic_tz_code is not null
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_scheduled_start_date    :=l_ic_scheduled_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='ITZ' and  p_timezone_enb
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_inc_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_inc_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_scheduled_start_date    :=l_ic_scheduled_start_date;
        l_tz_desc                 := p_inc_tz_desc;
      end if;
         l_rec.departure_time:=TO_CHAR((l_scheduled_start_date - (nvl(p_duration,0)/1440)),'hh24:mi');
         OPEN c_uom(NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes));
    	   FETCH c_uom INTO l_uom;
         IF c_uom%NOTFOUND THEN
            l_uom  := NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes);
         END IF;
         CLOSE c_uom;
         --l_rec.travel_time := NVL(l_task_rec.sched_travel_duration, 0) || ' ' || l_uom;
         l_rec.travel_time := nvl(p_duration,0) || ' ' || l_uom;
    END IF;
    /*
    If CSF_GPS_PUB.IS_GPS_ENABLED='Y'
    THEN

      csf_resource_pub.get_location(
       x_return_status      => l_return_status
      ,x_msg_count          => l_msg_count
      ,x_msg_data           => l_msg_data
      ,p_resource_id        => p_resource_id
      ,p_resource_type      => p_resource_type
      ,p_date               => p_start_date
      ,x_creation_date      => l_creation_date
      ,x_feed_time          => l_feed_time
      ,x_status_code        => l_status
      ,x_latitude           => l_latitude
      ,x_longitude          => l_longitude
      ,x_speed              => l_speed
      ,x_direction          => l_direction
      ,x_parked_time        => l_parked_time
      ,x_address            => l_address
      ,x_device_tag         => l_device_tag
      ,x_status_code_meaning=> l_status_code_meaning
      );
    END IF;

    */

    l_rec.assigned_flag           := l_task_rec.assigned_flag;
    l_rec.is_plan_option          := 'N';

         l_str :=
          '<TOOLTIP>'
          || '<CENTER fgColor='
          || 0
          || '>'
          || l_task_rec.task_name
          || '</CENTER>'
          || '<LINE></LINE>'
          || '<LABEL>'
          || g_task_number
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.task_number
          || '</VALUE>'
          || '<LABEL>'
          || g_task_type
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.task_type
          || '</VALUE>'
          || '<LABEL>'
          || g_task_status
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.task_status
          || '</VALUE>';
          /*
          If CSF_GPS_PUB.IS_GPS_ENABLED='Y'
          THEN
           l_str :=l_str|| '<LINE></LINE>'
          ||'<LABEL>'
          || g_tech_status
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_status_code_meaning
          || '</VALUE>'
          ||'<LABEL>'
          || g_tech_lat
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_latitude
          || '</VALUE>'
          ||'<LABEL>'
          || g_tech_lon
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_longitude
          || '</VALUE>'
          || '<LABEL>'
          ||  g_address
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_address
          || '</VALUE>'
          ||'<LABEL>'
          || g_tech_dev_tag
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_device_tag
          || '</VALUE>';
          END IF;
          l_str :=l_str
          || '<LINE></LINE>'
          || '<LABEL>'
          || g_cust_name
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.incident_customer_name
          || '</VALUE>'
          || '<LABEL>'
          ||  g_address
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_task_rec.small_address
          || '</VALUE>';
          */
    IF  p_timezone_enb
    THEN
          l_str :=
          l_str
          || '<LABEL>'
          || g_timezone
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_tz_desc
          || '</VALUE>';
    END IF;
    IF l_sr_rec.product_name IS NOT NULL THEN
        l_str  :=
        l_str
          || '<LABEL>'
          || g_product_name
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_sr_rec.product_name
          || '</VALUE>';
      IF l_ib_rec.serial_number IS NOT NULL THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_serial
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_ib_rec.serial_number
          || '</VALUE>';
      END IF;
    END IF;
    IF  p_timezone_enb
    THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_planned_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_planned_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_planned_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_planned_effort
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_planned_effort
          || '</VALUE>'
          || '<LABEL>'
          || g_sched_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_scheduled_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_scheduled_end_date,g_date_format||' hh24:mi')
          || '</VALUE>';
        IF l_task_rec.actual_start_date IS NOT NULL THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_actual_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_actual_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_ic_actual_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_actual_effort
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_actual_effort
          || '</VALUE>';
        END IF;
        l_rs_ic_tz_present :=true;
        If l_task_rec.ic_tz_code is null and sch_adv_tz <>'ITZ'
        Then
          l_str :=
          l_str|| '<LINE></LINE>';
          l_rs_ic_tz_present :=FALSE;
        end if;
    ELSE
          l_str :=
          l_str|| '<LINE></LINE>';
    END IF;
    If l_task_rec.ic_tz_code is not null
    then
          l_str :=
          l_str
          || '<LABEL>'
          || g_departure
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.departure_time
          || '</VALUE>'
          || '<LABEL>'
          || g_travel_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.travel_time
          || '</VALUE>';
      end if;
      if l_rs_ic_tz_present and sch_adv_tz <> 'ITZ'
      then
            l_str  :=
            l_str|| '<LINE></LINE>';
      end if;
      If sch_adv_tz <> 'ITZ' --this condition is used to restrict the tooltip
                               --according to logic we should show only incident timezone if schedule advise window is in same.
      then
          l_str  :=
          l_str
          || '<LABEL>'
          || g_planned_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_planned_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_planned_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_sched_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_scheduled_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_scheduled_end_date,g_date_format||' hh24:mi')
          || '</VALUE>';
          IF l_task_rec.actual_start_date IS NOT NULL THEN
          l_str  :=
          l_str
          || '<LABEL>'
          || g_actual_start
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_actual_start_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          || '<LABEL>'
          || g_end
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || to_char(l_dc_actual_end_date,g_date_format||' hh24:mi')
          || '</VALUE>'
          ;
          END IF;
      End if;--for sch_adv_tz ='ITZ' and l_task_rec.ic_tz_code is not null
       If l_task_rec.ic_tz_code is null
          then
          l_str :=
          l_str
          || '<LABEL>'
          || g_departure
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.departure_time
          || '</VALUE>'
          || '<LABEL>'
          || g_travel_time
          || '</LABEL>'
          || '<VALUE fgColor='
          || 0
          || '>'
          || l_rec.travel_time
          || '</VALUE>';
          end if;
    l_str  :=l_str|| '</TOOLTIP>';
    RETURN l_str;
  END get_tooltip_data_sch_advise;
  FUNCTION get_tooltip_data_sch_advise_cu(
    p_task_id       NUMBER
  , p_resource_id   NUMBER
  , p_resource_type VARCHAR2
  , p_start_date    DATE
  , p_end_date      DATE
  , p_duration      NUMBER
  , sch_adv_tz      varchar2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  , p_inc_tz_desc    varchar2
  , p_inc_tz_code    VARCHAR2
  )
  RETURN VARCHAR2 IS


    CURSOR c_cust_tooltip is
      SELECT field_name
      FROM   csf_gantt_chart_setup
      WHERE  user_id = fnd_global.user_id
      AND    setup_type = 'TOOLTIP'
      ORDER BY seq_no;

  -- task and task assignment data
    CURSOR c_task IS
      SELECT /*+ ORDERED use_nl (a tb tt tl sb sl pi ps hl ft)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             tb.task_id
           , tl.task_name
           , tb.task_number
           , tb.source_object_type_code
           , tb.source_object_id
           , tt.NAME task_type
           , sl.NAME task_status
           , a.resource_id
           , a.resource_type_code resource_type
           , tb.planned_start_date
           , tb.planned_end_date
           , scheduled_start_date
           , scheduled_end_date
           , a.actual_start_date
           , a.actual_end_date
           , a.sched_travel_duration
           , a.sched_travel_duration_uom
           , tb.customer_id party_id
           , NVL(sb.assigned_flag, 'N') assigned_flag
           , tb.task_type_id
           , csf_tasks_pub.get_task_address(tb.task_id,tb.address_id,tb.location_id,'Y') small_address
           , pi.party_name party_name
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , tz.ACTIVE_TIMEZONE_CODE ic_tz_code
           , tz.ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
           , tb.planned_effort ||' '|| tb.planned_effort_uom plan_effort
           , tb.actual_effort ||' '|| tb.actual_effort_uom  act_effort
        FROM jtf_task_assignments a
           , jtf_tasks_b tb
           , jtf_task_types_tl tt
           , jtf_tasks_tl tl
           , jtf_task_statuses_b sb
           , jtf_task_statuses_tl sl
           , hz_party_sites ps
           , hz_locations hl
           , hz_parties pi
           , fnd_timezones_b tz
       WHERE a.task_id = p_task_id
         AND resource_id = p_resource_id
         AND resource_type_code = p_resource_type
         AND tb.task_id = a.task_id
         AND tt.LANGUAGE = l_language
         AND tt.task_type_id = tb.task_type_id
         AND sl.LANGUAGE = l_language
         AND sb.task_status_id = a.assignment_status_id
         AND sl.task_status_id = sb.task_status_id
         AND tl.LANGUAGE = l_language
         AND tl.task_id = tb.task_id
         AND ps.party_site_id(+) = tb.address_id
         AND hl.location_id(+) = ps.location_id
         AND pi.party_id(+) = tb.customer_id
         AND NVL(sb.cancelled_flag, 'N') <> 'Y'
	 AND tz.UPGRADE_TZ_ID(+) = hl.timezone_id;

    CURSOR c_sr(b_incident_id NUMBER) IS
      SELECT /*+ ORDERED USE_NL */
             i.customer_product_id
           , i.current_serial_number
           , si.concatenated_segments product_name
        FROM cs_incidents_all_b i, mtl_system_items_kfv si
       WHERE si.inventory_item_id(+) = i.inventory_item_id
         AND si.organization_id(+) = i.inv_organization_id
         AND i.incident_id = b_incident_id;

    l_uom       VARCHAR2(2000)        := NULL;
    l_Res_Timezone_id   Number;
    l_res_tz_cd varchar2(100);
    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;

    CURSOR c_parts(b_task_id NUMBER) IS
      SELECT 'Y' required
        FROM csp_requirement_headers
       WHERE task_id = b_task_id;

    CURSOR c_ib(b_customer_product_id NUMBER) IS
      SELECT serial_number
           , lot_number
        FROM csi_item_instances
       WHERE instance_id = b_customer_product_id;

    Cursor C_Res_TimeZone Is
     Select TIME_ZONE
     From JTF_RS_RESOURCE_EXTNS
     Where RESOURCE_ID = p_resource_id
     ;
    Cursor c_res_tz
    IS
     SELECT ACTIVE_TIMEZONE_CODE,ACTIVE_TIMEZONE_CODE|| ' (GMT ' ||to_char(trunc(gmt_offset),'S09') || ':' || to_char(abs(gmt_offset - trunc(gmt_offset))*60,'FM900') || ') ' tz_desc
     FROM fnd_timezones_vl ft
     WHERE UPGRADE_TZ_ID =l_Res_TimeZone_id;

	  Cursor c_terr
	IS
	   SELECT territory_id
   	     FROM csf_dc_resources_v
	    WHERE resource_id = p_resource_id
	      AND resource_type   = p_resource_type;




    l_task_rec  c_task%ROWTYPE;
    l_sr_rec    c_sr%ROWTYPE;
    l_parts_rec c_parts%ROWTYPE;
    l_ib_rec    c_ib%ROWTYPE;
    l_rec       tooltip_data_rec_type := NULL;
    p_color     NUMBER                := 255;
    l_str       VARCHAR2(4000)        := NULL;
    l_ic_planned_start_date   date;
    l_ic_planned_end_date     date;
    l_ic_scheduled_start_date date;
    l_ic_scheduled_end_date   date;
    l_ic_actual_start_date    date;
    l_ic_actual_end_date      date;


    l_dc_planned_start_date   date;
    l_dc_planned_end_date     date;
    l_dc_scheduled_start_date date;
    l_dc_scheduled_end_date   date;
    l_dc_actual_start_date    date;
    l_dc_actual_end_date      date;
    l_actual_start_date       date;
    l_scheduled_start_date    date;
    l_tz_desc                 varchar2(100);
    l_rs_tz_desc              varchar2(100);
    l_rs_ic_tz_present        boolean;
    l_lines                             number;                --bug no 5674408
    l_actual_effort           VARCHAR2(200);
    l_planned_effort          VARCHAR2(200);
    l_territory               NUMBER;

    l_feed_time               varchar2(100);
    l_status                  varchar2(100);
    l_latitude                varchar2(100);
    l_longitude               varchar2(100);
    l_speed                   varchar2(100);
    l_direction               varchar2(100);
    l_parked_time             varchar2(100);
    l_address                 varchar2(100);
    l_creation_date           varchar2(100);
    l_device_tag              varchar2(100);
    l_status_code_meaning     varchar2(100);
    l_return_status           varchar2(2);
    l_msg_count               NUMBER;
    l_msg_data                varchar2(100);
	g_tooltip_fields 		  VARCHAR2(4000);
    l_count     			  NUMBER;
    l_field     			  VARCHAR2(2000);
    l_var     				  VARCHAR2(2000);
	l_off_time                varchar2(200);
    l_per_time                varchar2(200);
  BEGIN

    open c_terr;
	fetch c_terr into l_territory;
	close c_terr;
    g_excl_travel := csr_scheduler_pub.get_sch_parameter_value(  'spCommuteExcludedTime'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );
   g_commute := csr_scheduler_pub.get_sch_parameter_value(  'spCommutesPosition'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );
    OPEN c_task;
    FETCH c_task INTO l_task_rec;
    IF c_task%NOTFOUND THEN
      CLOSE c_task;
      RAISE NO_DATA_FOUND;
    END IF;

    IF l_task_rec.task_type_id NOT IN(20, 21)
    THEN
      l_planned_effort := l_task_rec.plan_effort;
      l_actual_effort := l_task_rec.act_effort;
      OPEN c_sr(l_task_rec.source_object_id);
      FETCH c_sr INTO l_sr_rec;

      IF l_sr_rec.customer_product_id IS NOT NULL THEN
        OPEN c_ib(l_sr_rec.customer_product_id);
        FETCH c_ib INTO l_ib_rec;
        CLOSE c_ib;
      ELSE
        l_ib_rec.serial_number  := l_sr_rec.current_serial_number;
        l_ib_rec.lot_number     := NULL;   -- not yet supported
      END IF;
    END IF;
    l_rec.incident_customer_name  := l_task_rec.party_name;

    --begin addition for bug 5674408
    IF (LENGTH(NVL(l_task_rec.party_name, 0)) > 80)
    THEN
        l_lines := ceil(length(l_task_rec.party_name)/80) - 1;
        l_rec.incident_customer_name := null;

        for i in 1..l_lines
        loop
            l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1, 80) || fnd_global.local_chr (10);
            l_task_rec.party_name := substrb(l_task_rec.party_name,81);
        end loop;

        l_rec.incident_customer_name := l_rec.incident_customer_name || SUBSTRB (l_task_rec.party_name, 1);
    END IF;
    --end addition for bug 5674408

    IF l_task_rec.actual_start_date is  not null
    THEN

      if sch_adv_tz ='UTZ' and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_actual_start_date       :=l_dc_actual_start_date;
        if l_task_rec.ic_tz_code is not null and  p_timezone_enb
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_actual_start_date       :=l_ic_actual_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='CTZ' and  p_timezone_enb
      then
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=l_task_rec.scheduled_start_date;
        l_dc_scheduled_end_date   :=l_task_rec.scheduled_end_date;
        l_dc_actual_start_date    :=p_start_date;
        l_dc_actual_end_date      :=p_end_date;

        l_actual_start_date       :=l_dc_actual_start_date;
        if l_task_rec.ic_tz_code is not null and p_timezone_enb
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_actual_start_date       :=l_ic_actual_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='ITZ' and  p_timezone_enb
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(l_task_rec.scheduled_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(l_task_rec.scheduled_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_start_date    :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_ic_actual_end_date      :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
        l_actual_start_date       :=l_ic_actual_start_date;
        l_tz_desc                 := p_inc_tz_desc;
      end if;

      l_rec.departure_time:=
      TO_CHAR(l_actual_start_date - (
                               inv_convert.inv_um_convert(
                                0
                               , NULL
                               , NVL(l_task_rec.actual_travel_duration, 0)
                               , NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes)
                               , g_uom_hours
                               , NULL
                               , NULL
                               )
                             / 24
                            )
                          ,' hh24:mi'
                      );
        OPEN c_uom(NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes));
        FETCH c_uom INTO l_uom;
        IF c_uom%NOTFOUND THEN
          l_uom  := NVL(l_task_rec.actual_travel_duration_uom, g_uom_minutes);
        END IF;
        CLOSE c_uom;
        l_rec.travel_time := NVL(l_task_rec.actual_travel_duration, 0) || ' ' || l_uom;
    ELSE
      if sch_adv_tz ='UTZ' and  p_timezone_enb
      then
        l_dc_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_scheduled_start_date    :=l_dc_scheduled_start_date;
        if l_task_rec.ic_tz_code is not null
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_scheduled_start_date    :=l_ic_scheduled_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='CTZ'  and  p_timezone_enb
      then
        l_dc_planned_start_date   :=l_task_rec.planned_start_date;
        l_dc_planned_end_date     :=l_task_rec.planned_end_date;
        l_dc_scheduled_start_date :=p_start_date;
        l_dc_scheduled_end_date   :=p_end_date;
        l_scheduled_start_date    :=l_dc_scheduled_start_date;
        if l_task_rec.ic_tz_code is not null
        then
          l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,l_task_rec.ic_tz_code);
          l_scheduled_start_date    :=l_ic_scheduled_start_date;
          l_tz_desc                 :=l_task_rec.tz_desc;
        end if;
      elsif sch_adv_tz ='ITZ' and  p_timezone_enb
      then
        l_ic_planned_start_date   :=fnd_date.adjust_datetime(l_task_rec.planned_start_date,p_server_tz_code,p_inc_tz_code);
        l_ic_planned_end_date     :=fnd_date.adjust_datetime(l_task_rec.planned_end_date,p_server_tz_code,p_inc_tz_code);
        l_ic_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_ic_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_scheduled_start_date    :=l_ic_scheduled_start_date;
        l_tz_desc                 := p_inc_tz_desc;
      end if;
         l_rec.departure_time:=TO_CHAR((l_scheduled_start_date - (nvl(p_duration,0)/1440)),'hh24:mi');
         OPEN c_uom(NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes));
    	   FETCH c_uom INTO l_uom;
         IF c_uom%NOTFOUND THEN
            l_uom  := NVL(l_task_rec.sched_travel_duration_uom, g_uom_minutes);
         END IF;
         CLOSE c_uom;
         --l_rec.travel_time := NVL(l_task_rec.sched_travel_duration, 0) || ' ' || l_uom;
         l_rec.travel_time := nvl(p_duration,0) || ' ' || l_uom;
    END IF;

    If CSF_GPS_PUB.IS_GPS_ENABLED='Y'
    THEN

      csf_resource_pub.get_location(
       x_return_status      => l_return_status
      ,x_msg_count          => l_msg_count
      ,x_msg_data           => l_msg_data
      ,p_resource_id        => p_resource_id
      ,p_resource_type      => p_resource_type
      ,p_date               => p_start_date
      ,x_creation_date      => l_creation_date
      ,x_feed_time          => l_feed_time
      ,x_status_code        => l_status
      ,x_latitude           => l_latitude
      ,x_longitude          => l_longitude
      ,x_speed              => l_speed
      ,x_direction          => l_direction
      ,x_parked_time        => l_parked_time
      ,x_address            => l_address
      ,x_device_tag         => l_device_tag
      ,x_status_code_meaning=> l_status_code_meaning
      );
    END IF;



    l_rec.assigned_flag           := l_task_rec.assigned_flag;
    l_rec.is_plan_option          := 'N';

    for tooltip_rec in c_cust_tooltip
    loop
      g_tooltip_fields := g_tooltip_fields || '-' || tooltip_rec.field_name;

      l_count:= nvl(l_count,0) + 1;
    end loop;
    g_tooltip_fields := l_count || g_tooltip_fields || '-';

    if g_tooltip_fields is not null and length(g_tooltip_fields) > 2
    then

      l_count := substr(g_tooltip_fields,1,instr(g_tooltip_fields,'-')-1);

      l_var   := substr(g_tooltip_fields,instr(g_tooltip_fields,'-')+1);

	  l_str :='<TOOLTIP>';
        for i in 1..l_count
        loop
          l_field := substr(l_var,1,instr(l_var,'-')-1);

          l_var := substr(l_var,instr(l_var,'-')+1);

          if l_field = 'TASK_NAME'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_name
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_name
                || '</VALUE>';
          elsif  l_field = 'TASK_NUMBER'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_number
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_number
                || '</VALUE>';
          elsif l_field = 'TASK_TYPE'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_type
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_type
                || '</VALUE>';
          elsif l_field = 'ASSIGNMENT_STATUS'
          then
                l_str := l_str
                || '<LABEL>'
                || g_task_status
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.task_status
                || '</VALUE>';
          elsif l_field = 'TECHNICIAN_STATUS' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
          then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_status
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_status_code_meaning
                || '</VALUE>';
           elsif l_field = 'LATITUDE' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
           then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_lat
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_latitude
                || '</VALUE>';
           elsif l_field = 'LOGITUDE' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
           then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_lon
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_longitude
                || '</VALUE>';
            elsif l_field = 'RESOURCE_GPS_ADD' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
            then
                l_str :=l_str
                || '<LABEL>'
                ||  g_tech_cur_add
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_address
                || '</VALUE>';
            elsif l_field = 'GPS_DEVICE_TAG' AND CSF_GPS_PUB.IS_GPS_ENABLED='Y'
            then
                l_str :=l_str
                ||'<LABEL>'
                || g_tech_dev_tag
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_device_tag
                || '</VALUE>';
            elsif l_field = 'CUSTOMER_NAME'
            then
                l_str :=l_str
                || '<LABEL>'
                || g_cust_name
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_rec.incident_customer_name
                || '</VALUE>';
             elsif l_field = 'ADDRESS'
             then
                l_str :=l_str
                || '<LABEL>'
                ||  g_address
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_task_rec.small_address
                || '</VALUE>';
             elsif l_field = 'TIMEZONE' AND p_timezone_enb
             then
                l_str :=l_str
                || '<LABEL>'
                || g_timezone
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_tz_desc
                || '</VALUE>';
             elsif l_field = 'PRODUCT_NAME'
             then
              l_str := l_str
                || '<LABEL>'
                || g_product_name
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_sr_rec.product_name
                || '</VALUE>';

             elsif l_field = 'SERIAL_NO'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_serial
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_ib_rec.serial_number
                || '</VALUE>';
             elsif l_field = 'PLANNED_START'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_plan_start_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_planned_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'PLANNED_END'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_plan_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_planned_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'PLANNED_EFFORT'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_planned_effort
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_planned_effort
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_START'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_sched_start_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_scheduled_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_END'    AND   p_timezone_enb
             then
                 l_str  :=l_str
                || '<LABEL>'
                || g_end
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_scheduled_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_START'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_actul_start_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_actual_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_END'    AND   p_timezone_enb
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_inc_actul_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_ic_actual_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_EFFORT'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_actual_effort
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_actual_effort
                || '</VALUE>';
             elsif l_field = 'PLANNED_START_DATE_DC' and sch_adv_tz <> 'ITZ' --this condition is used to restrict the tooltip
																			 --according to logic we should show only incident
																			 --timezone if schedule advise window is in same.
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_planned_start
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_planned_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'PLANNED_END_DATE_DC'  and sch_adv_tz <> 'ITZ'  --this condition is used to restrict the tooltip
																			 --according to logic we should show only incident
																			 --timezone if schedule advise window is in same.
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_dc_plan_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_planned_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_START_DATE_DC' and sch_adv_tz <> 'ITZ' --this condition is used to restrict the tooltip
																			   --according to logic we should show only incident
																			   --timezone if schedule advise window is in same.
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_sched_start
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_scheduled_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'SCHEDULED_END_DATE_DC' and sch_adv_tz <> 'ITZ' --this condition is used to restrict the tooltip
																			 --according to logic we should show only incident
																			 --timezone if schedule advise window is in same.
             then
                 l_str  :=l_str
                || '<LABEL>'
                || g_dc_sched_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_scheduled_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_START_DATE_DC'  and sch_adv_tz <> 'ITZ' --this condition is used to restrict the tooltip
																			 --according to logic we should show only incident
																			 --timezone if schedule advise window is in same.
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_actual_start
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_actual_start_date,g_date_format||' hh24:mi')
                || '</VALUE>';
             elsif l_field = 'ACTUAL_END_DATE_DC'    and sch_adv_tz <> 'ITZ' --this condition is used to restrict the tooltip
																			 --according to logic we should show only incident
																			 --timezone if schedule advise window is in same.
             then

                l_str  :=l_str
                || '<LABEL>'
                || g_dc_actul_end_date
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || to_char(l_dc_actual_end_date,g_date_format||' hh24:mi')
                || '</VALUE>';

             elsif l_field = 'DEPARTURE_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_departure
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_rec.departure_time
                || '</VALUE>';
             elsif l_field = 'TRAVEL_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_travel_time
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_rec.travel_time
                || '</VALUE>';
             elsif l_field = 'COMMUTE_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_off_time
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_off_time
                || '</VALUE>';
             elsif l_field = 'PERSONAL_TIME'
             then
                l_str  :=l_str
                || '<LABEL>'
                || g_per_time
                || '</LABEL>'
                || '<VALUE fgColor='
                || 0
                || '>'
                || l_per_time
                || '</VALUE>';
             elsif l_field like 'LINE%'
             then
                 l_str :=l_str|| '<LINE></LINE>';
             end if;
        end loop;
     END IF;-- This is end if for g_tooltip_fields is not null and length(g_tooltip_fields) > 2
	 l_str  :=l_str|| '</TOOLTIP>';
    RETURN l_str;
  END get_tooltip_data_sch_advise_cu;

  FUNCTION convert_to_days(p_duration NUMBER, p_uom VARCHAR2, p_uom_hours VARCHAR2)
    RETURN NUMBER IS
    l_value NUMBER;
  BEGIN
    l_value  :=
      inv_convert.inv_um_convert(
        item_id                      => 0
      , PRECISION                    => 20
      , from_quantity                => p_duration
      , from_unit                    => p_uom
      , to_unit                      => p_uom_hours
      , from_name                    => NULL
      , to_name                      => NULL
      );
    RETURN l_value / 24;
  END convert_to_days;

  FUNCTION get_green
    RETURN NUMBER IS
  BEGIN
    RETURN green;
  END;


  FUNCTION get_gantt_task_color(
    p_task_id              IN NUMBER
  , p_task_type_id         IN NUMBER
  , p_task_priority_id     IN NUMBER
  , p_assignment_status_id IN NUMBER
  , p_task_assignment_id   IN NUMBER
  , p_actual_start_date    IN DATE
  , p_actual_end_date      IN DATE
  , p_actual_effort        IN NUMBER
  , p_actual_effort_uom    IN VARCHAR2
  , p_planned_effort       IN NUMBER
  , p_planned_effort_uom   IN VARCHAR2
  , p_scheduled_start_date IN DATE
  , p_scheduled_end_date   IN DATE
  )
    RETURN NUMBER IS
  --variable for setting color code for gantt

  --variable for storing Profile value set by user
   -- This line is commented by vakulkar fnd_profile.value('CSF_TASK_SIGNAL_COLOR');
  --when you call this function from gantt, it does not get refreshed value from the buffer
  --instead it gets null or old value.
  --but when you use fnd_profile.value_specific function it returns the current value.
  --variable for returning color code for a task
  BEGIN
    l_task_custom_color  := 'N';

    IF p_task_type_id NOT IN(20, 21) THEN
      IF p_actual_start_date IS NOT NULL THEN
        IF p_actual_end_date IS NOT NULL THEN
          IF p_actual_end_date = p_actual_start_date THEN
            --set flag for color code
            l_task_custom_color  := 'Y';
          END IF;   --end if for actual_end_date=actual_start_date
        ELSE
          --     This new case is introduced according the Mini-Design made by Peter
          --     Which was missing in HLD
          --     Changed on 17-dec-2003 for bug 3306656 by vakulkar
          IF NVL(p_actual_effort, 0) = 0 THEN
            IF NVL(p_planned_effort, 0) = 0 THEN
              l_task_custom_color  := 'Y';
            END IF;
          END IF;
        --     End of the code added for the change in mini-design
        END IF;   --end if for actual_end_date is not null
      ELSE   --for actual start date is null
        IF p_scheduled_end_date IS NOT NULL THEN
          IF p_scheduled_end_date = p_scheduled_start_date THEN
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
    IF p_task_type_id IN(20, 21) THEN
      IF p_scheduled_start_date IS NOT NULL AND p_scheduled_end_date IS NOT NULL THEN
        IF p_scheduled_start_date <> p_scheduled_end_date THEN
          IF p_scheduled_end_date > p_scheduled_start_date THEN
            --set the color flag
            l_task_custom_color  := 'Y';
          END IF;   --if scheduled end_date > than start_date
        END IF;   --end if for scheduled_end_date is not equal to start_date
      END IF;   --end if for scheduled_start and end_dates are not null
    END IF;   --end if for task_type_id

    IF l_task_custom_color = 'Y' THEN
      --l_rule_id is the profile value set by the user
      IF l_rule_id IS NOT NULL THEN
        BEGIN
          SELECT background_col_dec
            INTO l_task_dec_color
            FROM jtf_task_custom_colors
           WHERE rule_id = l_rule_id;

          RETURN(l_task_dec_color);
        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            RETURN(
                   jtf_task_custom_colors_pub.get_task_dec_bgcolor(p_task_id, p_task_type_id
                   , p_task_priority_id, p_assignment_status_id)
                  );
        END;
      ELSE
        -- if profile is not set then return JTF VALUE
        RETURN(
               jtf_task_custom_colors_pub.get_task_dec_bgcolor(p_task_id, p_task_type_id
               , p_task_priority_id, p_assignment_status_id)
              );
      END IF;
    ELSE
      RETURN(
             jtf_task_custom_colors_pub.get_task_dec_bgcolor(p_task_id, p_task_type_id
             , p_task_priority_id, p_assignment_status_id)
            );
    END IF;
  END get_gantt_task_color;

  PROCEDURE get_planned_task(
    p_api_version   IN            NUMBER
  , p_init_msg_list IN            VARCHAR2
  , p_request_id    IN            VARCHAR2
  , x_return_status OUT NOCOPY    VARCHAR2
  , x_msg_count     OUT NOCOPY    NUMBER
  , x_msg_data      OUT NOCOPY    VARCHAR2
  , task_id         OUT NOCOPY    jtf_varchar2_table_100
  , start_date      OUT NOCOPY    jtf_date_table
  , end_date        OUT NOCOPY    jtf_date_table
  , color           OUT NOCOPY    jtf_number_table
  , NAME            OUT NOCOPY    jtf_varchar2_table_100
  , tooltip         OUT NOCOPY    jtf_varchar2_table_2000
  , DURATION        OUT NOCOPY    jtf_number_table
  , task_type_id    OUT NOCOPY    jtf_number_table
  , resource_key    OUT NOCOPY    jtf_varchar2_table_2000
  , sch_adv_tz                 In       Varchar2
  ) IS
    l_rec               tooltip_data_rec_type := NULL;

    CURSOR c_planned_task IS
      SELECT DECODE(task_id, -1, ROWNUM, task_id) || plan_option_id
           , start_time
           , end_time
           , 0 color
           , ' ' NAME
           , ' ' tooltip
           ,   TO_NUMBER(SUBSTR(travel_time, 1, INSTR(travel_time, ':', 1) - 1)) * 60
             + TO_NUMBER(SUBSTR(travel_time, INSTR(travel_time, ':', 1) + 1, 5)) travel_time
           , NVL(task_type_id, 0)
           , resource_id || '-' || resource_type || '-' || plan_option_id
        FROM csf_plan_options_v
       WHERE sched_request_id = TO_NUMBER(SUBSTR(p_request_id, 1, INSTR(p_request_id, '-', 1) - 1))
         AND (
                 task_id = -1
              OR task_id =
                   TO_NUMBER(SUBSTR(p_request_id, INSTR(p_request_id, '-', 1) + 1
                     , LENGTH(p_request_id)))
             )
         AND (task_type_id IS NULL OR(task_type_id <> 20 OR task_type_id <> 21));

    l_uom               VARCHAR2(2000)        := NULL;

    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;

    l_api_name CONSTANT VARCHAR2(30)          := 'get_planned_task';
    l_return_status     VARCHAR2(1);

  BEGIN
    task_id       := jtf_varchar2_table_100();
    start_date    := jtf_date_table();
    end_date      := jtf_date_table();
    color         := jtf_number_table();
    NAME          := jtf_varchar2_table_100();
    tooltip       := jtf_varchar2_table_2000();
    DURATION      := jtf_number_table();
    task_type_id  := jtf_number_table();
    resource_key  := jtf_varchar2_table_2000();

    OPEN c_planned_task;
    FETCH c_planned_task
    BULK COLLECT INTO task_id
         , start_date
         , end_date
         , color
         , NAME
         , tooltip
         , DURATION
         , task_type_id
         , resource_key;

    if g_tz_enabled ='Y' and g_dflt_tz_for_sc='CTZ' and task_id.count > 0
    then
      FOR i IN task_id.FIRST .. task_id.LAST
      LOOP
         start_date(i) :=fnd_date.adjust_datetime(start_date(i),g_client_tz,g_server_tz );
         end_date(i)   :=fnd_date.adjust_datetime(end_date(i)  ,g_client_tz,g_server_tz);
      END LOOP;
    end if;

    IF task_id.COUNT IS NULL THEN
      l_return_status  := 'E';
    ELSE
      x_return_status  := fnd_api.g_ret_sts_success;
    END IF;

    IF NOT l_return_status = fnd_api.g_ret_sts_success THEN
      -- just return unexpected error, no message, does
      -- not matter, SchedulerResource.java will just skip this resource
      -- without message, and only generate an error message
      -- when all resources have failed
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --standard call to get message count and the message information
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  --
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
      END IF;
  END get_planned_task;

  FUNCTION get_tooltip_for_plan_task(
    p_task_id       NUMBER
  , p_resource_id   NUMBER
  , p_resource_type VARCHAR2
  , p_start_date    DATE
  , p_end_date      DATE
  , p_duration      NUMBER
  , p_inc_tz_code    VARCHAR2
  , p_server_tz_code VARCHAR2
  , p_client_tz_code VARCHAR2
  , p_timezone_enb   boolean
  , sch_adv_tz      varchar2
  , p_inc_tz_desc    varchar2
  )
    RETURN VARCHAR2 IS
    l_scheduled_start Date;
    l_scheduled_end   VARCHAR2(30);
    l_departure_time  VARCHAR2(20);
    l_travel_time     VARCHAR2(100);
    l_uom             VARCHAR2(15);
    l_str             VARCHAR2(2000) := NULL;

    l_ic_scheduled_start_date date;
    l_ic_scheduled_end_date   date;
    l_dc_scheduled_start_date date;
    l_dc_scheduled_end_date   date;
    l_inc_tz_code VARCHAR2(100);
    l_inc_tz_desc VARCHAR2(100);
    l_off_time varchar2(200);
    l_per_time varchar2(200);
    l_planned_effort varchar2(200);
	l_territory   number;

    CURSOR c_uom(p_code VARCHAR2) IS
      SELECT unit_of_measure_tl
        FROM mtl_units_of_measure_vl
       WHERE uom_code = p_code;

	   Cursor c_terr
	IS
	   SELECT territory_id
   	     FROM csf_dc_resources_v
	    WHERE resource_id = p_resource_id
	      AND resource_type   = p_resource_type;



  BEGIN

    open c_terr;
	fetch c_terr into l_territory;
	close c_terr;
    g_excl_travel := csr_scheduler_pub.get_sch_parameter_value(  'spCommuteExcludedTime'
                                                              , fnd_global.resp_appl_id
                                                              , fnd_global.resp_id
                                                              , fnd_global.user_id
                                                              , l_territory
                                                              , p_resource_type
                                                              , p_resource_id
                                                              );

    IF nvl(p_inc_tz_code,'ERROR') ='ERROR'
    THEN
      l_inc_tz_code :=NULL;
    ELSE
      l_inc_tz_code :=p_inc_tz_code;
    END IF;

    if NVL(p_inc_tz_desc,'ERROR') = 'ERROR'
    then
      l_inc_tz_desc := null;
    else
      l_inc_tz_desc := p_inc_tz_desc;
    end if;

    IF p_timezone_enb
    THEN
      IF sch_adv_tz ='ITZ'
      THEN
        l_ic_scheduled_start_date  := fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
        l_ic_scheduled_end_date    := fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
        l_scheduled_start          := l_ic_scheduled_start_date;
      ELSIF sch_adv_tz = 'UTZ'
      THEN
          l_dc_scheduled_start_date :=fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_client_tz_code);
          l_dc_scheduled_end_date   :=fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_client_tz_code);
          l_scheduled_start         :=l_dc_scheduled_start_date;
          IF p_inc_tz_code is not null and l_inc_tz_code is not null
          THEN
            l_ic_scheduled_start_date  := fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_inc_tz_code);
            l_ic_scheduled_end_date    := fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_inc_tz_code);
          END IF;
      ELSE
          l_dc_scheduled_start_date  := p_start_date;
          l_dc_scheduled_end_date    := p_end_date;
          l_scheduled_start          := l_dc_scheduled_start_date;
          IF p_inc_tz_code is not null and l_inc_tz_code is not null
          THEN
            l_ic_scheduled_start_date  := fnd_date.adjust_datetime(p_start_date,p_server_tz_code,p_inc_tz_code);
            l_ic_scheduled_end_date    := fnd_date.adjust_datetime(p_end_date,p_server_tz_code,p_inc_tz_code);
          END IF;
      END IF;

        l_departure_time   :=
        TO_CHAR
        (l_scheduled_start
            - (inv_convert.inv_um_convert(0, NULL, p_duration, g_uom_minutes, g_uom_hours, NULL
                 , NULL)
               / 24
              )
        , 'hh24:mi'
        );

    ELSE
      l_dc_scheduled_start_date  := p_start_date;
      l_dc_scheduled_end_date    := p_end_date;
      l_scheduled_start          := l_dc_scheduled_start_date;
      l_departure_time   :=
        TO_CHAR
        (l_scheduled_start
            - (inv_convert.inv_um_convert(0, NULL, p_duration, g_uom_minutes, g_uom_hours, NULL
                 , NULL)
               / 24
              )
        , 'hh24:mi'
        );
    END IF;
    OPEN c_uom(g_uom_minutes);
    FETCH c_uom
    INTO l_uom;
    IF c_uom%NOTFOUND THEN
      l_uom  := g_uom_minutes;
    END IF;
    CLOSE c_uom;
      l_travel_time      := p_duration || ' ' || l_uom;
      if p_duration > 0
      then
        if p_duration >  to_number(g_excl_travel)
        then
          l_off_time := (p_duration - to_number(g_excl_travel) )|| ' ' || l_uom;
          l_per_time := g_excl_travel || ' ' || l_uom;
        elsif p_duration < to_number(g_excl_travel)
        then
          l_per_time := l_travel_time;
        end if;
      end if;
      l_str              :=
       '<TOOLTIP>'
       || '<CENTER fgColor='
       || 65280
       || '>'
       || g_option
       || '</CENTER>';


    IF p_timezone_enb
    THEN
       l_str :=
       l_str
       || '<LINE></LINE>'
       || '<LABEL>'
       || g_timezone
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || l_inc_tz_desc
       || '</VALUE>'
       || '<LABEL>'
       || g_sched_start
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || to_char(l_ic_scheduled_start_date,g_date_format||' hh24:mi')
       || '</VALUE>'
       || '<LABEL>'
       || g_end
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || to_char(l_ic_scheduled_end_date,g_date_format||' hh24:mi')
       || '</VALUE>'
       ;
    END IF;
    If sch_adv_tz <> 'ITZ'
    then
       l_str :=
       l_str|| '<LINE></LINE>';
    end if;


    If sch_adv_tz <> 'ITZ'
    then
       l_str :=
       l_str
       || '<LABEL>'
       || g_sched_start
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || to_char(l_dc_scheduled_start_date,g_date_format||' hh24:mi')
       || '</VALUE>'
       || '<LABEL>'
       || g_end
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || to_char(l_dc_scheduled_end_date,g_date_format||' hh24:mi')
       || '</VALUE>'
       || '<LABEL>'
       || g_planned_effort
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || l_planned_effort
       || '</VALUE>';
    End If;
       l_str :=
       l_str
       || '<LABEL>'
       || g_departure
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || l_departure_time
       || '</VALUE>'
       || '<LABEL>'
       || g_travel_time
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || l_travel_time
       || '</VALUE>';
    IF g_commute = 'PARTIAL'
    THEN
          l_str :=
          l_str
       || '<LABEL>'
       || g_off_time
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || l_off_time
       || '</VALUE>'
       || '<LABEL>'
       || g_per_time
       || '</LABEL>'
       || '<VALUE fgColor='
       || 65280
       || '>'
       || l_per_time
       || '</VALUE>';
    END IF;
    l_str :=
          l_str
       || '</TOOLTIP>';

    RETURN l_str;
  END get_tooltip_for_plan_task;

  FUNCTION get_skilled_resources(
    p_task_id       NUMBER
  , p_start         DATE
  , p_end           DATE
  , p_resource_id   NUMBER DEFAULT NULL
  , p_resource_type VARCHAR2 DEFAULT NULL
  )
    RETURN NUMBER IS
    j            NUMBER                           := 0;
    l_levelmatch NUMBER                           := NULL;
    l_start      date;
    l_end        date;

    --modified the following cursor to check for skill_active date range for bug 3418658
    CURSOR c_resource_plan_window(
      p_task_id       NUMBER
    , p_start         DATE
    , p_end           DATE
    , p_resource_id   NUMBER
    , p_resource_type VARCHAR2
    ) IS
  SELECT rs.resource_id
         , rs.resource_type
         , rs.winstart
         , rs.winend
         , rs.count_of_matching_skills
         , rs.skill_level
      FROM (SELECT rs.resource_id
                 , rs.resource_type
                 , GREATEST(
                       MAX(rs.start_date_active)
                     , NVL(MAX(ss.start_date_active), p_start)
                     , p_start
                     ) winstart
                 , LEAST(
                       NVL(MIN(rs.end_date_active + 1), p_end)
                     , NVL(MIN(ss.end_date_active + 1), p_end)
                     , p_end
                     ) winend
                 , COUNT(*) count_of_matching_skills
                 , SUM( 1/rsl.step_value ) skill_level
              FROM csf_resource_skills_b rs
                 , csf_required_skills_b ts
                 , csf_skill_levels_b rsl
                 , csf_skill_levels_b tsl
                 , csf_skills_b ss
             WHERE DECODE(
                       SIGN(rsl.step_value - tsl.step_value)
                     , -1, DECODE(l_levelmatch, 1, 'Y', 'N')
                     , 0, 'Y'
                     , 1, DECODE(l_levelmatch, 3, 'Y', 'N')
                     ) = 'Y'
               AND rsl.skill_level_id = rs.skill_level_id
               AND tsl.skill_level_id = ts.skill_level_id
               AND TRUNC(rs.start_date_active) < p_end
               AND (TRUNC(rs.end_date_active + 1) > p_start OR rs.end_date_active IS NULL)
               AND (rs.resource_id = p_resource_id OR p_resource_id IS NULL)
               AND (rs.resource_type = p_resource_type OR p_resource_type IS NULL)
               AND NVL(ts.disabled_flag, 'N') <> 'Y'
               AND ts.has_skill_type = 'TASK'
               AND ts.has_skill_id = p_task_id
               AND ss.skill_id(+) = rs.skill_id
               AND (
                             ts.skill_type_id NOT IN (2, 3)
                         AND rs.skill_id = ts.skill_id
                         AND ts.skill_type_id = rs.skill_type_id
                         AND TRUNC(ss.start_date_active) < SYSDATE
                         AND TRUNC(NVL(ss.end_date_active, SYSDATE) + 1) > SYSDATE
                     OR      ts.skill_type_id = 2
                         AND rs.skill_id = ts.skill_id
                         AND ts.skill_type_id = rs.skill_type_id
                         AND EXISTS (SELECT 1 FROM mtl_system_items_kfv msi WHERE msi.inventory_item_id = rs.skill_id)
                     OR      ts.skill_type_id = 3
                         AND rs.skill_id = ts.skill_id
                         AND ts.skill_type_id = rs.skill_type_id
                         AND EXISTS (SELECT 1
                                       FROM mtl_item_categories mic
                                      WHERE mic.category_id = rs.skill_id
                                        AND category_set_id = fnd_profile.VALUE('CS_SR_DEFAULT_CATEGORY_SET'))
                   )
             GROUP BY rs.resource_id, rs.resource_type) rs
          , (
              SELECT COUNT(*) count_of_req_skills
                FROM csf_required_skills_b
               WHERE NVL(disabled_flag, 'N') <> 'Y'
                 AND has_skill_type = 'TASK'
                 AND has_skill_id = p_task_id
            ) ts
     WHERE rs.count_of_matching_skills = ts.count_of_req_skills
       AND rs.winstart < rs.winend;


    l_rec        c_resource_plan_window%ROWTYPE;

  BEGIN
    -- Retrieving the profile value that will be used
    -- to determine the satifactory level of the skills
    -- needed to perform the task.
    -- The ff. are the possible profile values:
    --   1 for EQUAL TO or SMALLER THAN
    --   2 for EQUAL TO
    --   3 for EQUAL TO or GREATER THAN
    -- In case the profile return a null, the default value
    -- will be 2 (EQUAL TO).
    l_levelmatch  := NVL(fnd_profile.VALUE('CSF_SKILL_LEVEL_MATCH'), 2);

    l_start := csf_timezones_pvt.date_to_client_tz_date(p_start);
    l_end   := csf_timezones_pvt.date_to_client_tz_date(p_end);
    OPEN c_resource_plan_window(p_task_id, l_start, l_end, p_resource_id, p_resource_type);
    FETCH c_resource_plan_window
     INTO l_rec;

    IF c_resource_plan_window%FOUND THEN
      RETURN 1;
    END IF;

    CLOSE c_resource_plan_window;

    RETURN 0;
  END get_skilled_resources;

  FUNCTION get_resource_name(p_res_id NUMBER, p_res_type VARCHAR2)
    RETURN VARCHAR2 IS
  BEGIN
     RETURN csf_resource_pub.get_resource_name(p_res_id,p_res_type);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_resource_name;

  FUNCTION get_resource_type_name(p_res_type VARCHAR2)
    RETURN VARCHAR2 IS

  BEGIN
     RETURN CSF_RESOURCE_PUB.get_resource_type_name(p_res_type);
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END get_resource_type_name;

  PROCEDURE drag_n_drop(
    p_api_version                IN            NUMBER
  , p_init_msg_list              IN            VARCHAR2
  , p_commit                     IN            VARCHAR2
  , p_task_id                    IN            NUMBER
  , p_task_assignment_id         IN            NUMBER DEFAULT NULL
  , p_object_version_number      IN OUT NOCOPY NUMBER
  , p_old_resource_type_code     IN            VARCHAR2
  , p_new_resource_type_code     IN            VARCHAR2
  , p_old_resource_id            IN            NUMBER
  , p_new_resource_id            IN            NUMBER
  , p_cancel_status_id           IN            NUMBER
  , p_assignment_status_id       IN            NUMBER
  , p_old_object_capacity_id     IN            NUMBER
  , p_new_object_capacity_id     IN            NUMBER
  , p_sched_travel_distance      IN            NUMBER DEFAULT NULL
  , p_sched_travel_duration      IN            NUMBER DEFAULT NULL
  , p_sched_travel_duration_uom  IN            VARCHAR2 DEFAULT NULL
  , p_old_shift_construct_id     IN            NUMBER DEFAULT NULL
  , p_new_shift_construct_id     IN            NUMBER DEFAULT NULL
  , p_shift_changed              IN            BOOLEAN
  , p_task_changed               IN            BOOLEAN
  , p_assignment_changed         IN            BOOLEAN
  , p_time_occupied              IN            NUMBER
  , p_new_sched_start_date       IN            DATE
  , p_new_sched_end_date         IN            DATE
  , p_update_plan_date           in	       VARCHAR2  DEFAULT 'N'
  , p_planned_start_date         IN	       DATE  DEFAULT NULL
  , p_planned_end_date           IN	       DATE  DEFAULT NULL
  , p_planned_effort		 IN	       NUMBER DEFAULT NULL
  , p_planned_effort_uom	 IN	       VARCHAR2  DEFAULT NULL
  , x_return_status              OUT NOCOPY    VARCHAR2
  , x_msg_count                  OUT NOCOPY    NUMBER
  , x_msg_data                   OUT NOCOPY    VARCHAR2
  , x_task_assignment_id         OUT NOCOPY    NUMBER
  , x_task_object_version_number OUT NOCOPY    NUMBER
  , x_task_status_id             OUT NOCOPY    NUMBER
  , x_task_status_name           OUT NOCOPY    VARCHAR2
  , x_task_type_id               OUT NOCOPY    NUMBER
  ) IS
    l_api_name       CONSTANT VARCHAR2(30) := 'drag_n_drop';
    l_api_version    CONSTANT NUMBER       := 1.0;
    l_old_task_obj_ver_number NUMBER;
    l_task_status_id          NUMBER;
    l_start_date              DATE;
    l_end_date                DATE;
    l_old_ta_obj_version      NUMBER;
    l_obj_ver_number          VARCHAR2(20);
    l_planned_effort          NUMBER  := fnd_api.g_miss_num;
    l_planned_effort_uom      VARCHAR2(10) := fnd_api.g_miss_char;

    l_sched_travel_duration     NUMBER:=30 ;
    l_sched_travel_duration_uom VARCHAR2(10);

    l_parent_task_id          NUMBER;

    CURSOR c_task(p_task_id NUMBER) IS
      SELECT object_version_number
           , task_status_id
           , scheduled_start_date
           , scheduled_end_date
	   , parent_task_id
        FROM jtf_tasks_b
       WHERE task_id = p_task_id;

    CURSOR c_assign_obj_ver IS
      SELECT object_version_number
           , actual_start_date
	   , actual_end_date
      FROM   JTF_TASK_ASSIGNMENTS
      WHERE  task_id= p_task_id
      AND    task_assignment_id =p_task_assignment_id;

    CURSOR c_parent_ovn(p_task_id number) IS
      SELECT object_version_number
       FROM  jtf_tasks_b
       WHERE task_id = p_task_id;
  BEGIN
    -- Standard start of API savepoint
    SAVEPOINT drag_n_drop;

    -- Standard call to check for call compatibility
    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name
          , 'csf_gantt_data_pkg') THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status  := fnd_api.g_ret_sts_success;
    IF p_task_changed OR p_assignment_changed THEN
      OPEN c_task(p_task_id);

      FETCH c_task
       INTO l_old_task_obj_ver_number
          , l_task_status_id
          , l_start_date
          , l_end_date
          , l_parent_task_id;

      IF c_task%NOTFOUND THEN
        CLOSE c_task;
        RAISE NO_DATA_FOUND;
      END IF;

      CLOSE c_task;

      OPEN  c_assign_obj_ver;
      FETCH c_assign_obj_ver
      INTO l_old_ta_obj_version,l_start_date,l_end_date;
      IF c_assign_obj_ver%NOTFOUND THEN
        CLOSE c_assign_obj_ver;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_assign_obj_ver;

      IF p_assignment_changed
      OR p_shift_changed
      OR l_start_date IS NOT NULL
      THEN
         l_task_status_id := p_assignment_status_id;
      END IF;

      IF p_planned_effort IS NOT NULL
      AND p_planned_effort_uom IS NOT NULL
      THEN
        l_planned_effort := p_planned_effort;
        l_planned_effort_uom := p_planned_effort_uom;
      END IF;

      IF p_sched_travel_duration IS NOT NULL
      AND p_sched_travel_duration_uom IS NOT NULL
      THEN
        l_sched_travel_duration      := p_sched_travel_duration;
        l_sched_travel_duration_uom  := p_sched_travel_duration_uom;
      END IF;

      /*test('Updating Task ');
      test('Updating Task  p_task_id :'||p_task_id);
      test('Updating Task  l_old_task_obj_ver_number:'||l_old_task_obj_ver_number);
      test('Updating Task p_planned_start_date:'||p_planned_start_date);
      test('Updating Task p_planned_end_date:'||p_planned_end_date);
      test('Updating Task p_new_sched_start_date'||p_new_sched_start_date);
      test('Updating Task p_new_sched_end_date'||p_new_sched_end_date);
      test('Updating Task l_planned_effort :'||l_planned_effort);
      test('Updating Task l_planned_effort_uom :'||l_planned_effort_uom);
      test('Updating Task l_task_status_id ;'||l_task_status_id);
      */

      csf_tasks_pub.update_task(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => p_task_id
      , p_object_version_number      => l_old_task_obj_ver_number
      , p_planned_start_date         => nvl(p_planned_start_date,fnd_api.g_miss_date)
      , p_planned_end_date           => nvl(p_planned_end_date,fnd_api.g_miss_date)
      , p_scheduled_start_date       => p_new_sched_start_date
      , p_scheduled_end_date         => p_new_sched_end_date
      , p_actual_start_date          => fnd_api.g_miss_date
      , p_actual_end_date            => fnd_api.g_miss_date
      , p_planned_effort             => l_planned_effort
      , p_planned_effort_uom         => l_planned_effort_uom
      , p_task_status_id             => l_task_status_id
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;

    END IF;

    IF p_assignment_changed
    OR l_start_date IS NOT NULL
    THEN

     /* test('Assignment Changed creating assignment :');
      test('Assignment Changed p_task_id :'||p_task_id);
      test('Assignment Changed p_new_resource_type_code :'||p_new_resource_type_code);
      test('Assignment Changed p_assignment_status_id :'||p_assignment_status_id);
      test('Assignment Changed p_new_shift_construct_id :'||p_new_shift_construct_id);
      test('Assignment Changed p_new_object_capacity_id:'||p_new_object_capacity_id);
      test('Assignment Changed p_sched_travel_distance :'||p_sched_travel_distance);
      test('Assignment Changed p_sched_travel_duration :'||p_sched_travel_duration);
      test('Assignment Changed p_sched_travel_duration_uom :'||p_sched_travel_duration_uom);
      */



      csf_task_assignments_pub.create_task_assignment(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_false
      , p_task_id                    => p_task_id
      , p_resource_type_code         => p_new_resource_type_code
      , p_resource_id                => p_new_resource_id
      , p_assignment_status_id       => p_assignment_status_id
      , p_shift_construct_id         => p_new_shift_construct_id
      , p_object_capacity_id         => p_new_object_capacity_id
      , p_sched_travel_distance      => p_sched_travel_distance
      , p_sched_travel_duration      => l_sched_travel_duration
      , p_sched_travel_duration_uom  => p_sched_travel_duration_uom
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_assignment_id         => x_task_assignment_id
      , x_ta_object_version_number   => p_object_version_number
      , x_task_object_version_number => x_task_object_version_number
      , x_task_status_id             => x_task_status_id
      );



      IF NVL(x_return_status, 'S') = fnd_api.g_ret_sts_success THEN
      /*test('After Creating Assignment ..');
      test('Assignment Changed x_task_assignment_id :'||x_task_assignment_id);
      test('Assignment Changed p_object_version_number :'||p_object_version_number);
      test('Assignment Changed x_task_object_version_number :'||x_task_object_version_number);
      test('Assignment Changed x_task_status_id :'||x_task_status_id);
      test('Now Updating Assignment ..');
      test('Now Updating Assignment p_task_assignment_id:'||p_task_assignment_id);
      test('Now Updating Assignment l_old_ta_obj_version:'||l_old_ta_obj_version);
      test('Now Updating Assignment p_task_id:'||p_task_id);
      test('Now Updating Assignment p_old_resource_type_code:'||p_old_resource_type_code);
      test('Now Updating Assignment p_old_resource_id :'||p_old_resource_id);
      test('Now Updating Assignment p_cancel_status_id:'||p_cancel_status_id);
      test('Now Updating Assignment p_old_shift_construct_id:'||p_old_shift_construct_id);
      test('Now Updating Assignment p_old_object_capacity_id:'||p_old_object_capacity_id);
      */

        OPEN  c_assign_obj_ver;
        FETCH c_assign_obj_ver
        INTO l_old_ta_obj_version,l_start_date,l_end_date;
        IF c_assign_obj_ver%NOTFOUND THEN
          CLOSE c_assign_obj_ver;
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE c_assign_obj_ver;
        csf_task_assignments_pub.update_task_assignment(
          p_api_version                => 1.0
        , p_init_msg_list              => fnd_api.g_true
        , p_commit                     => fnd_api.g_false
        , p_task_assignment_id         => p_task_assignment_id
        , p_object_version_number      => l_old_ta_obj_version
        , p_task_id                    => p_task_id
        , p_resource_type_code         => p_old_resource_type_code
        , p_resource_id                => p_old_resource_id
        , p_resource_territory_id      => fnd_api.g_miss_num
        , p_assignment_status_id       => p_cancel_status_id
        , p_actual_start_date          => fnd_api.g_miss_date
        , p_actual_end_date            => fnd_api.g_miss_date
        , p_sched_travel_distance      => fnd_api.g_miss_num
        , p_sched_travel_duration      => fnd_api.g_miss_num
        , p_sched_travel_duration_uom  => fnd_api.g_miss_char
        , p_shift_construct_id         => p_old_shift_construct_id
        , p_object_capacity_id         => p_old_object_capacity_id
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
        , x_msg_data                   => x_msg_data
        , x_task_object_version_number => x_task_object_version_number
        , x_task_status_id             => x_task_status_id
        );
        IF NVL(x_return_status, 'S') <> fnd_api.g_ret_sts_success THEN
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSE
       /*test('Now After Updating Assignment ..');
       test('Now After Updating Assignment x_task_object_version_number :'||x_task_object_version_number);
       test('Now After Updating Assignment x_task_status_id :'||x_task_status_id);
       test('Now After Updating Assignment x_return_status :'||x_return_status);
       test('Now After Updating Assignment x_msg_data :'||x_msg_data);
      */
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF p_shift_changed THEN
      OPEN  c_assign_obj_ver;
      FETCH c_assign_obj_ver
      INTO l_old_ta_obj_version,l_start_date,l_end_date;
      IF c_assign_obj_ver%NOTFOUND THEN
        CLOSE c_assign_obj_ver;
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE c_assign_obj_ver;
      csf_task_assignments_pub.update_task_assignment(
        p_api_version                => 1.0
      , p_init_msg_list              => fnd_api.g_true
      , p_commit                     => fnd_api.g_false
      , p_task_assignment_id         => p_task_assignment_id
      , p_object_version_number      => l_old_ta_obj_version
      , p_task_id                    => p_task_id
      , p_resource_type_code         => p_old_resource_type_code
      , p_resource_id                => p_old_resource_id
      , p_resource_territory_id      => fnd_api.g_miss_num
      , p_assignment_status_id       => p_assignment_status_id
      , p_actual_start_date          => fnd_api.g_miss_date
      , p_actual_end_date            => fnd_api.g_miss_date
      , p_sched_travel_distance      => p_sched_travel_distance
      , p_sched_travel_duration      => l_sched_travel_duration
      , p_sched_travel_duration_uom  => p_sched_travel_duration_uom
      , p_shift_construct_id         => p_new_shift_construct_id
      , p_object_capacity_id         => p_new_object_capacity_id
      , x_return_status              => x_return_status
      , x_msg_count                  => x_msg_count
      , x_msg_data                   => x_msg_data
      , x_task_object_version_number => x_task_object_version_number
      , x_task_status_id             => x_task_status_id
      );
      IF NVL(x_return_status, 'S') <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    ELSIF p_task_changed and l_parent_task_id IS NOT NULL
    THEN
       OPEN c_parent_ovn(l_parent_task_id);
       FETCH c_parent_ovn INTO l_obj_ver_number;
       CLOSE c_parent_ovn;

        -- Sync up the Parent and all the other Siblings
        csf_tasks_pub.update_task_longer_than_shift(
          p_api_version            => 1.0
        , p_init_msg_list          => fnd_api.g_true
        , p_commit                 => fnd_api.g_false
        , x_return_status          => x_return_status
        , x_msg_count              => x_msg_count
        , x_msg_data               => x_msg_data
        , p_task_id                => l_parent_task_id
        , p_object_version_number  => l_obj_ver_number
        , p_action                 => csf_tasks_pub.g_action_normal_to_parent
        );
      IF NVL(x_return_status, 'S') <> fnd_api.g_ret_sts_success THEN
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Standard check of p_commit
    IF fnd_api.to_boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info
    fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO drag_n_drop;
      x_return_status  := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO drag_n_drop;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
    WHEN OTHERS THEN
      ROLLBACK TO drag_n_drop;
      x_return_status  := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg('csf_gantt_data_pkg', l_api_name);
      END IF;

      fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);
  END drag_n_drop;

  PROCEDURE g_get_custom_color IS
    CURSOR c_custom_color IS
      SELECT   type_id
             , priority_id
             , assignment_status_id
             , escalated_task
             , background_col_dec
             , background_col_rgb
          FROM jtf_task_custom_colors
         WHERE active_flag = 'Y'
      ORDER BY color_determination_priority;

    i BINARY_INTEGER := 0;
  BEGIN
    IF gl_custom_color_tbl.COUNT = 0 THEN
      FOR rec IN c_custom_color LOOP
        i                                            := i + 1;
        gl_custom_color_tbl(i).task_type_id          := rec.type_id;
        gl_custom_color_tbl(i).task_priority_id      := rec.priority_id;
        gl_custom_color_tbl(i).assignment_status_id  := rec.assignment_status_id;
        gl_custom_color_tbl(i).escalated_task        := rec.escalated_task;
        gl_custom_color_tbl(i).background_col_dec    := rec.background_col_dec;
        gl_custom_color_tbl(i).background_col_rgb    := rec.background_col_rgb;
      END LOOP;
    END IF;
  END g_get_custom_color;

  FUNCTION g_do_match(
    p_task_type_id         IN NUMBER
  , p_task_priority_id     IN NUMBER
  , p_assignment_status_id IN NUMBER
  , p_escalated_task       IN VARCHAR2
  )
    RETURN NUMBER IS
  BEGIN
    FOR i IN gl_custom_color_tbl.FIRST .. gl_custom_color_tbl.LAST LOOP
      IF     NVL(gl_custom_color_tbl(i).task_type_id, p_task_type_id) = p_task_type_id
         AND NVL(gl_custom_color_tbl(i).task_priority_id, p_task_priority_id) = p_task_priority_id
         AND NVL(gl_custom_color_tbl(i).assignment_status_id, p_assignment_status_id) =
                                                                              p_assignment_status_id
         AND NVL(gl_custom_color_tbl(i).escalated_task, p_escalated_task) = p_escalated_task THEN
        RETURN NVL(gl_custom_color_tbl(i).background_col_dec, 0);
      END IF;
    END LOOP;

    RETURN 0;
  END g_do_match;
function convert_to_min
    ( p_duration  number
    , p_uom       varchar2
    , p_uom_min varchar2
    )
  return number
  is
    l_value number;
  begin
    l_value := inv_convert.inv_um_convert
                 ( item_id       => 0
                 , precision     => null
                 , from_quantity => p_duration
                 , from_unit     => nvl(p_uom,g_uom_minutes)
                 , to_unit       => nvl(p_uom_min,g_uom_minutes)
                 , from_name     => null
                 , to_name       => null
                 );
    return l_value;
  end convert_to_min;

  Procedure get_dispatch_task_dtls (
  p_api_version              IN         Number
, p_init_msg_list            IN         Varchar2 DEFAULT NULL
, x_return_status            OUT NOCOPY Varchar2
, x_msg_count                OUT NOCOPY Number
, x_msg_data                 OUT NOCOPY Varchar2
, p_start_date_range         IN         DATE
, p_end_date_range           IN         DATE
, p_res_id                   OUT NOCOPY jtf_number_table
, p_res_type                 OUT NOCOPY jtf_varchar2_table_2000
, p_res_name                 OUT NOCOPY jtf_varchar2_table_2000
, p_res_typ_name             OUT NOCOPY jtf_varchar2_table_2000
, p_res_key                  OUT NOCOPY jtf_varchar2_table_2000
, p_trip_id                  OUT NOCOPY jtf_number_table
, p_shift_start_date         OUT NOCOPY jtf_date_table
, p_shift_end_date           OUT NOCOPY jtf_date_table
, p_block_trip               OUT NOCOPY jtf_number_table
, p_shift_res_key            OUT NOCOPY jtf_varchar2_table_2000
, p_vir_task_id		         OUT NOCOPY jtf_varchar2_table_100
, p_vir_start_date	         OUT NOCOPY jtf_date_table
, p_vir_end_date	         OUT NOCOPY jtf_date_table
, p_vir_color		         OUT NOCOPY jtf_number_table
, p_vir_name		         OUT NOCOPY jtf_varchar2_table_100
, p_vir_duration	         OUT NOCOPY jtf_number_table
, p_vir_task_type_id	     OUT NOCOPY jtf_number_table
, p_vir_tooltip		         OUT NOCOPY jtf_varchar2_table_2000
, p_vir_resource_key	     OUT NOCOPY jtf_varchar2_table_2000
, real_task_id         OUT NOCOPY    jtf_varchar2_table_100
, real_start_date      OUT NOCOPY    jtf_date_table
, real_end_date        OUT NOCOPY    jtf_date_table
, real_color           OUT NOCOPY    jtf_number_table
, real_NAME            OUT NOCOPY    jtf_varchar2_table_2000
, real_tooltip         OUT NOCOPY    jtf_varchar2_table_2000
, real_DURATION        OUT NOCOPY    jtf_number_table
, real_task_type_id    OUT NOCOPY    jtf_number_table
, real_resource_key    OUT NOCOPY    jtf_varchar2_table_2000
, real_parts_required  OUT NOCOPY    jtf_varchar2_table_100
, real_access_hours    OUT NOCOPY    jtf_varchar2_table_100
, real_after_hours     OUT NOCOPY    jtf_varchar2_table_100
, real_customer_conf   OUT NOCOPY    jtf_varchar2_table_100
, real_task_depend     OUT NOCOPY    jtf_varchar2_table_100
, real_child_task      OUT NOCOPY    jtf_varchar2_table_100
, p_vir_avail_type	   OUT NOCOPY    jtf_varchar2_table_2000
, p_show_arr_dep_tasks IN	     varchar2   DEFAULT 'N'
   )
  IS
      l_assignment_id          jtf_number_table;
      l_task_priority_id       jtf_number_table;
      l_status_id			   jtf_number_table;
      l_planned_start_date     jtf_date_table;
      l_planned_end_date	 jtf_date_table;
      l_actual_start_date	 jtf_date_table;
      l_actual_end_date	 		jtf_date_table;
      l_actual_effort		 jtf_number_table;
      l_actual_effort_uom	 jtf_varchar2_table_100;
      l_planned_effort	 jtf_number_table;
      l_planned_effort_uom     jtf_varchar2_table_100;
      l_escalated_task         jtf_varchar2_table_100;
      l_scheduled_start_date	 jtf_date_table;
      l_scheduled_end_date     jtf_date_table;

	  l_task_customer_name      jtf_varchar2_table_1000;
	  l_task_number				jtf_varchar2_table_100;
	  l_Task_Name			    jtf_varchar2_table_1000;
	  l_Task_Priority_Name		jtf_varchar2_table_1000;
	  l_task_City_name			jtf_varchar2_table_1000;
	  l_task_Site_Name  		jtf_varchar2_table_1000;
	  l_task_Postal_Code		jtf_varchar2_table_1000;
	  l_task_attr_list			VARCHAR2(1000);
	  l_task_attr_list_tmp	    VARCHAR2(1000);
      ---------------------------------------------------
      --The below variables are used in color coding proc
      ---------------------------------------------------
      p_cur_task_type_id     NUMBER(10);
      p_cur_task_priority_id NUMBER(10);
      p_cur_task_status_id   NUMBER(10);
      p_cur_escalated_task   VARCHAR2(1);
      p_color                NUMBER(30);
      p_cur_color            NUMBER(30);
      p_rule_id              NUMBER(10);

	  p_vir_avail_key        jtf_varchar2_table_100;

    CURSOR C_Terr_Resource
      IS
 	    SELECT RESOURCE_ID,
			   RESOURCE_TYPE,
			   RESOURCE_NAME,
			   RESOURCE_TYPE_NAME,
			   RES_KEY
		FROM (
		    SELECT  DISTINCT
			        TR.RESOURCE_ID RESOURCE_ID,
					TR.RESOURCE_TYPE RESOURCE_TYPE,
					TR.RESOURCE_NAME RESOURCE_NAME,
					CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME( TR.RESOURCE_TYPE ) RESOURCE_TYPE_NAME,
					TR.RESOURCE_ID||'-'||TR.RESOURCE_TYPE RES_KEY
		    FROM    CSF_SELECTED_RESOURCES_V TR
	  	    MINUS
			SELECT  DISTINCT
					A.RESOURCE_ID RESOURCE_ID,
					A.RESOURCE_TYPE RESOURCE_TYPE,
					A.RESOURCE_NAME RESOURCE_NAME,
					CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(A.RESOURCE_TYPE) RESOURCE_TYPE_NAME,
					A.RESOURCE_ID || '-' || A.RESOURCE_TYPE RES_KEY
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
            AND     D.ROLE_CODE IN ( 'CSF_THIRD_PARTY_SERVICE_PROVID', 'CSF_THIRD_PARTY_ADMINISTRATOR')
			)
        ORDER BY UPPER(RESOURCE_NAME);

    -- cursor to fetch resources having active 'Field Service Representative' role
    CURSOR c_res_technician
    IS
	    SELECT RESOURCE_ID,
			   RESOURCE_TYPE,
			   RESOURCE_NAME,
			   RESOURCE_TYPE_NAME,
			   RES_KEY
		FROM (
			SELECT  DISTINCT
			        RES.RESOURCE_ID RESOURCE_ID,
					RES.RESOURCE_TYPE RESOURCE_TYPE,
					RES.RESOURCE_NAME RESOURCE_NAME,
					CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(RES.RESOURCE_TYPE) RESOURCE_TYPE_NAME,
                    RES.RESOURCE_ID || '-' || RES.RESOURCE_TYPE RES_KEY
            FROM 	CSF_SELECTED_RESOURCES_V RES,
          			JTF_RS_DEFRESROLES_VL ROLES
            WHERE   RES.RESOURCE_ID = ROLES.ROLE_RESOURCE_ID
            AND     ROLES.ROLE_TYPE_CODE = 'CSF_REPRESENTATIVE'
            AND     (SYSDATE >= TRUNC (ROLES.RES_RL_START_DATE) OR ROLES.RES_RL_START_DATE IS NULL)
            AND     (SYSDATE <= TRUNC (ROLES.RES_RL_END_DATE) + 1 OR ROLES.RES_RL_END_DATE IS NULL)
            AND     NVL(ROLES.DELETE_FLAG, 'N') = 'N'
			MINUS
			SELECT  DISTINCT
					A.RESOURCE_ID RESOURCE_ID,
					A.RESOURCE_TYPE RESOURCE_TYPE,
					A.RESOURCE_NAME RESOURCE_NAME ,
					CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(A.RESOURCE_TYPE) RESOURCE_TYPE_NAME ,
					A.RESOURCE_ID || '-' || A.RESOURCE_TYPE RES_KEY
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

      CURSOR C_Resource_Shift(p_start_date DATE, p_end_date DATE) IS
      SELECT object_capacity_id
           , start_date_time
           , end_date_time
           , status blocked_trip
           , res_info.resource_id||'-'||res_info.resource_type resource_key
           , nvl(ca.availability_type,'NULL')
       FROM cac_sr_object_capacity ca,(SELECT TO_NUMBER(
                                         SUBSTR(column_value
                                                , 1
                                                , INSTR(column_value, '-', 1, 1) - 1
                                                )
                                                )resource_id
                                        , SUBSTR(column_value
                                                 , INSTR(column_value, '-', 1, 1) + 1
                                                 ,LENGTH(column_value)
                                                 ) resource_type
                                FROM TABLE(CAST(p_res_key AS jtf_varchar2_table_2000))
                                ) res_info
      WHERE ca.object_type = res_info.resource_type
        AND   ca.object_id   = res_info.resource_id
        AND   TRUNC(ca.start_date_time) >= (p_start_date -1)
        AND   TRUNC(ca.end_date_time)   <= p_end_date;

      CURSOR get_tdu_color(t_rule_id NUMBER) IS
      SELECT background_col_dec
      FROM jtf_task_custom_colors
      WHERE rule_id = t_rule_id;

      CURSOR C_Virtual_Tasks
      IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb)
                 INDEX (t,JTF_TASKS_B_U3)
                 INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             a.task_id || '-' || a.task_assignment_id
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , ' ' task_name
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code resource_key
           , task_assignment_id
           , task_priority_id
           , assignment_status_id
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , t.actual_effort
           , t.actual_effort_uom
           , t.planned_effort
           , t.planned_effort_uom
           , 'N' escalated_task
           , scheduled_start_date
           , scheduled_end_date
      FROM (SELECT TO_NUMBER(SUBSTR(column_value
                                 , 1
                                 , INSTR(column_value, '-', 1, 1) - 1
                                 )
                          )resource_id
                          , SUBSTR(column_value
                                   , INSTR(column_value, '-', 1, 1) + 1
                                   ,LENGTH(column_value)
                                   ) resource_type
                                FROM TABLE(CAST(p_res_key AS jtf_varchar2_table_2000))
                           ) res_info
    	   , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_task_types_b tt
           , jtf_task_statuses_b tsa
           , jtf_task_statuses_b tsb
      WHERE t.task_id = a.task_id
        AND t.task_type_id = tt.task_type_id
        AND (t.task_type_id = 20 OR t.task_type_id = 21)
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND booking_end_date >= booking_start_date
        AND booking_start_date >= (p_start_date_range -1)
        AND TRUNC(booking_end_date) <= TRUNC(p_end_date_range)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsb.task_status_id = t.task_status_id
        AND tsa.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y';


      l_resource_dtls csf_resource_pub.resource_rec_type;
      l_cnt number (10);

      --------------------------------------------------------------------
      --all the variable and cursor used for getting real task information
      --------------------------------------------------------------------
      l_task_depends               varchar2(1);
      l_actual_travel_duration     jtf_number_table;
      l_actual_travel_duration_uom jtf_varchar2_table_100;
      l_task_depend                jtf_varchar2_table_100;
      l_csf_default_effort         NUMBER;

      CURSOR c_icon_setup
      IS
      SELECT active
      FROM   csf_gnticons_setup_v
      WHERE  seq_id = 6;


      CURSOR c_task_bar_info
      IS
      SELECT icon_file_name
      FROM   csf_gnticons_setup_v
      WHERE  INSTR(ICON_FILE_NAME,'TASK') >0
	  AND     nvl(active,'N')='Y'
	  ORDER BY RANKING;



      ---------------------------------------------------------------------------------------------
       --Cursor C1 introduced when show labels on taskbar is true i.e join for hz_parties for showing
       --party name on taskbar and this cursor is without task dependenciea join.
      ---------------------------------------------------------------------------------------------

      CURSOR c1
      IS
      SELECT /*+ ORDERED use_nl (res_info a t tl tt jtp jtpl tsa tsb pi ps l ca cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
			 DISTINCT
             a.task_id || '-' || a.task_assignment_id
		   , t.task_number
		   , tl.task_name
		   , jtpl.name
		   , NVL(l.postal_code,' ')
           , NVL(l.city,' ')
		   , NVL(ps.party_site_name,' ')
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , t.task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code resource_key
           , nvl(pi.party_name,' ') incident_customer_name
		   , nvl(pi.party_name,' ') incident_customer_name1
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , 'N' escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , 'N' task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
      FROM (SELECT TO_NUMBER(SUBSTR(column_value
                                      , 1
		                      , INSTR(column_value, '-', 1, 1) - 1
                                      )
                               )resource_id
                              ,SUBSTR(column_value
                                      , INSTR(column_value, '-', 1, 1) + 1
                                      , LENGTH(column_value)
                                      ) resource_type
                                FROM TABLE(CAST(p_res_key AS jtf_varchar2_table_2000))
                                ) res_info
           , jtf_task_assignments a
           , jtf_tasks_B t
		   , jtf_tasks_tl tl
           , jtf_task_types_b tt
		   , jtf_task_priorities_B jtp
		   , jtf_task_priorities_tl jtpl
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
           , hz_parties pi
		   , hz_party_sites ps
           , hz_locations l
	       , csf_access_hours_b ca
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
	    AND tl.task_id =t.task_id
		AND tl.language=userenv('LANG')
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND jtp.task_priority_id=t.task_priority_id
		AND jtpl.task_priority_id         = jtp.task_priority_id
		AND jtpl.language=userenv('LANG')
		AND booking_start_date <= (p_end_date_range)
        AND booking_end_date >= (p_start_date_range -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
		AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND pi.party_id(+) = t.customer_id
		AND ps.party_site_id(+) = t.address_id
        AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date;

      ---------------------------------------------------------------------------------------------
      --Cursor C3 introduced if task_dependency is set to active in scheduling chart icon setup form
      -- this cursor also has hz_parties join for party name to be shown on task bar
      ---------------------------------------------------------------------------------------------
      CURSOR c3 IS
      SELECT /*+ ORDERED use_nl (res_info a t tt jtp jtpl tsa tsb pi ps l ca jd jdd cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             DISTINCT
             a.task_id || '-' || a.task_assignment_id
		   , t.task_number
		   , tl.task_name
		   , jtpl.name
		   , NVL(l.postal_code,' ')
           , NVL(l.city,' ')
		   , NVL(ps.party_site_name,' ')
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , t.task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code resource_key
           , nvl(pi.party_name,' ') incident_customer_name
		   , nvl(pi.party_name,' ') incident_customer_name1
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , 'N' escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , DECODE(nvl(t.task_id,0),jd.task_id,'Y','N') task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , nvl(jdd.dependent_on_task_id,0) task_dep1
      FROM (SELECT TO_NUMBER(SUBSTR(column_value
                                      , 1
		                      , INSTR(column_value, '-', 1, 1) - 1
                                      )
                               )resource_id
                              ,SUBSTR(column_value
                                      , INSTR(column_value, '-', 1, 1) + 1
                                      , LENGTH(column_value)
                                      ) resource_type
                                FROM TABLE(CAST(p_res_key AS jtf_varchar2_table_2000))
                                ) res_info
	       , jtf_task_assignments a
           , jtf_tasks_b t
		   , jtf_tasks_tl tl
           , jtf_task_types_b tt
		   , jtf_task_priorities_B jtp
		   , jtf_task_priorities_tl jtpl
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	       , hz_parties pi
		   , hz_party_sites ps
           , hz_locations l
	       , csf_access_hours_b ca
           , jtf_task_depends jd
           , jtf_task_depends jdd
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND tl.task_id =t.task_id
		AND tl.language=userenv('LANG')
		AND jtp.task_priority_id=t.task_priority_id
		AND jtpl.task_priority_id         = jtp.task_priority_id
		AND jtpl.language=userenv('LANG')
		AND booking_start_date <= (p_end_date_range)
        AND booking_end_date >= (p_start_date_range -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND jd.task_id(+) = t.task_id
        AND jdd.dependent_on_task_id(+) = t.task_id
        AND pi.party_id(+) = t.customer_id
		AND ps.party_site_id(+) = t.address_id
        AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date;
      ---------------------------------------------------------------------------------------------
      --Cursor C2 introduced when show labels on taskbar is false i.e remove join for hz_parties
      -- the diffrence between c1 and c2 join for hz_parties
      ---------------------------------------------------------------------------------------------
      CURSOR c2 IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb ca cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             a.task_id || '-' || a.task_assignment_id
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code resource_key
           , ' ' incident_customer_name
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , 'N' escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , 'N' task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
      FROM (SELECT TO_NUMBER(SUBSTR(column_value
                                      , 1
		                      , INSTR(column_value, '-', 1, 1) - 1
                                      )
                               )resource_id
                              ,SUBSTR(column_value
                                      , INSTR(column_value, '-', 1, 1) + 1
                                      , LENGTH(column_value)
                                      ) resource_type
                                FROM TABLE(CAST(p_res_key AS jtf_varchar2_table_2000))
                                ) res_info
    	     , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_task_types_b tt
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	         , csf_access_hours_b ca
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND booking_start_date <= (p_end_date_range)
        AND booking_end_date >= (p_start_date_range -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date;
      ---------------------------------------------------------------------------------------------
      --Cursor C4 introduced if task_dependency is set to active in scheduling chart icon setup form
      -- this cursor does not have hz_parties join like c2 but has dependencies join
      ---------------------------------------------------------------------------------------------
      CURSOR C4
      IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb ca jd jdd cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             DISTINCT
             a.task_id || '-' || a.task_assignment_id
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code resource_key
           , ' ' incident_customer_name
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , 'N' escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , DECODE(nvl(t.task_id,0),jd.task_id,'Y','N') task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , nvl(jdd.dependent_on_task_id,0) task_dep1
      FROM (SELECT TO_NUMBER(SUBSTR(column_value
                                      , 1
		                      , INSTR(column_value, '-', 1, 1) - 1
                                      )
                               )resource_id
                              ,SUBSTR(column_value
                                      , INSTR(column_value, '-', 1, 1) + 1
                                      , LENGTH(column_value)
                                      ) resource_type
                                FROM TABLE(CAST(p_res_key AS jtf_varchar2_table_2000))
                                ) res_info
    	     , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_task_types_b tt
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	         , csf_access_hours_b ca
           , jtf_task_depends jd
           , jtf_task_depends jdd
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND booking_start_date <= (p_end_date_range)
        AND booking_end_date >= (p_start_date_range -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND jd.task_id(+) = t.task_id
        AND jdd.dependent_on_task_id(+) = t.task_id
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date;

      TYPE custom_color_rec IS RECORD(
       task_type_id         NUMBER
      , task_priority_id     NUMBER
      , assignment_status_id NUMBER
      , escalated_task       VARCHAR2(1)
      , background_col_dec   NUMBER
      , background_col_rgb   VARCHAR2(12)
      );

      TYPE custom_color_tbl IS TABLE OF custom_color_rec
      INDEX BY BINARY_INTEGER;

      g_custom_color_tbl       custom_color_tbl;

      PROCEDURE get_custom_color IS
        CURSOR c_custom_color IS
        SELECT   type_id
               , priority_id
               , assignment_status_id
               , escalated_task
               , background_col_dec
               , background_col_rgb
            FROM jtf_task_custom_colors
           WHERE active_flag = 'Y'
        ORDER BY color_determination_priority;

        i BINARY_INTEGER := 0;
      BEGIN
        IF g_custom_color_tbl.COUNT = 0
        THEN
          FOR rec IN c_custom_color
	  LOOP
            i := i + 1;
            g_custom_color_tbl(i).task_type_id          := rec.type_id;
            g_custom_color_tbl(i).task_priority_id      := rec.priority_id;
            g_custom_color_tbl(i).assignment_status_id  := rec.assignment_status_id;
            g_custom_color_tbl(i).escalated_task        := rec.escalated_task;
            g_custom_color_tbl(i).background_col_dec    := rec.background_col_dec;
            g_custom_color_tbl(i).background_col_rgb    := rec.background_col_rgb;
          END LOOP;
        END IF;
      END get_custom_color;

      FUNCTION do_match(
        p_task_type_id         IN NUMBER
      , p_task_priority_id     IN NUMBER
      , p_assignment_status_id IN NUMBER
      , p_escalated_task       IN VARCHAR2
      )
        RETURN NUMBER IS
      BEGIN
        FOR i IN g_custom_color_tbl.FIRST .. g_custom_color_tbl.LAST
	LOOP
          IF  NVL(g_custom_color_tbl(i).task_type_id, p_task_type_id) = p_task_type_id
          AND NVL(g_custom_color_tbl(i).task_priority_id, p_task_priority_id) = p_task_priority_id
          AND NVL(g_custom_color_tbl(i).assignment_status_id, p_assignment_status_id) =
                                                                              p_assignment_status_id
          AND NVL(g_custom_color_tbl(i).escalated_task, p_escalated_task) = p_escalated_task THEN
            RETURN g_custom_color_tbl(i).background_col_dec;
          END IF;
        END LOOP;
        RETURN 0;
      END do_match;


  BEGIN

      p_res_id                   :=jtf_number_table();
      p_res_type                 :=jtf_varchar2_table_2000();
      p_res_name                 :=jtf_varchar2_table_2000();
      p_res_typ_name             :=jtf_varchar2_table_2000();
      p_res_key                  :=jtf_varchar2_table_2000();
      --------------------------------------
      --Tables for getting shift information
      --------------------------------------
      p_trip_id                  :=jtf_number_table();
      p_shift_start_date         :=jtf_date_table();
      p_shift_end_date           :=jtf_date_table();
      p_block_trip               :=jtf_number_table();
      p_shift_res_key            :=jtf_varchar2_table_2000();
      p_vir_avail_key            := jtf_varchar2_table_100() ;
      ----------------------------------------------------------
      --tables used for getting virtual task information
      ----------------------------------------------------------
      p_vir_task_id		:= jtf_varchar2_table_100() ;
      p_vir_start_date	:= jtf_date_table();
      p_vir_end_date		:= jtf_date_table();
      p_vir_color		:= jtf_number_table();
      p_vir_name		:= jtf_varchar2_table_100();
      p_vir_duration		:= jtf_number_table();
      p_vir_task_type_id	:= jtf_number_table();
      p_vir_tooltip		:= jtf_varchar2_table_2000();
      p_vir_resource_key 	:= jtf_varchar2_table_2000();
      p_vir_avail_type   := jtf_varchar2_table_2000();

      l_assignment_id         := jtf_number_table();
      l_task_priority_id      := jtf_number_table();
      l_status_id		:= jtf_number_table();
      l_planned_start_date    := jtf_date_table();
      l_planned_end_date	:= jtf_date_table();
      l_actual_start_date	:= jtf_date_table();
      l_actual_end_date	:= jtf_date_table();
      l_actual_effort		:= jtf_number_table();
      l_actual_effort_uom	:= jtf_varchar2_table_100();
      l_planned_effort	:= jtf_number_table();
      l_planned_effort_uom    := jtf_varchar2_table_100();
      l_escalated_task        := jtf_varchar2_table_100();
      l_scheduled_start_date	:= jtf_date_table();
      l_scheduled_end_date    := jtf_date_table();
	  -------------------------------------------------------
	  --Tables for getting taskbar label information
	  -------------------------------------------------------
	  l_task_customer_name      := jtf_varchar2_table_1000();
	  l_task_number 			:=jtf_varchar2_table_100();
	  l_Task_Name			    :=jtf_varchar2_table_1000();
	  l_Task_Priority_Name		:=jtf_varchar2_table_1000();
	  l_task_City_name			:=jtf_varchar2_table_1000();
	  l_task_Site_Name  		:=jtf_varchar2_table_1000();
	  l_task_Postal_Code		:=jtf_varchar2_table_1000();

      -------------------------------------------------------
      --tables used for getting real task information
      -------------------------------------------------------
      real_task_id        := jtf_varchar2_table_100();
      real_start_date     := jtf_date_table();
      real_end_date       := jtf_date_table();
      real_color          := jtf_number_table();
      real_name           := jtf_varchar2_table_2000();
      real_tooltip        := jtf_varchar2_table_2000();
      real_duration       := jtf_number_table();
      real_task_type_id   := jtf_number_table();
      real_resource_key   := jtf_varchar2_table_2000();
      real_parts_required := jtf_varchar2_table_100();
      real_access_hours   := jtf_varchar2_table_100();
      real_after_hours    := jtf_varchar2_table_100();
      real_customer_conf  := jtf_varchar2_table_100();
      real_task_depend    := jtf_varchar2_table_100();
      real_child_task     := jtf_varchar2_table_100();

      l_actual_travel_duration     := jtf_number_table();
      l_actual_travel_duration_uom := jtf_varchar2_table_100();
      l_task_depend                :=jtf_varchar2_table_100();
      --------------------------------------------------------------------------
      -- This was added because  profile values were getting cached
      -- though we change profile values in application and re-login
      -- we were not able to see the changed effects.so decided to
      -- move these profiles intialisation in this procedure
      -- as this procedure gets executed first for populating dispatch
      -- cente gantt.
      ---------------------------------------------------------------------------
      l_default_effort_uom     := fnd_profile.value_specific('CSF_DEFAULT_EFFORT_UOM', g_user_id);
      l_default_effort         := fnd_profile.value_specific('CSF_DEFAULT_EFFORT', g_user_id);
      l_rule_id                := fnd_profile.value_specific('CSF_TASK_SIGNAL_COLOR', g_user_id);
      l_profile_value          := fnd_profile.value_specific('CSF_USE_CUSTOM_CHROMATICS', g_user_id);
      g_label_on_task          := fnd_profile.value_specific('CSF_DISPLAY_LABEL_ON_TASK', g_user_id) = 'Y';
      g_dflt_tz_for_dc         := fnd_profile.value_specific('CSF_DEFAULT_TIMEZONE_DC', g_user_id);
      g_dflt_tz_for_sc         := fnd_profile.value_specific('CSF_DEFAULT_TIMEZONE_SC', g_user_id);
      -------------------------------------------------------------------------------
      -- End for adding profile values
      -------------------------------------------------------------------------------

    -- fetch resources
    IF NVL(FND_PROFILE.value('CSF_DC_DISPLAY_ONLY_TECHNICIANS'), 'N') = 'Y' THEN
      OPEN c_res_technician;
      FETCH c_res_technician
        BULK COLLECT INTO
          p_res_id
        , p_res_type
        , p_res_name
        , p_res_typ_name
        , p_res_key;
      CLOSE c_res_technician;
    ELSE
      OPEN c_terr_resource;
      FETCH c_terr_resource
        BULK COLLECT INTO
          p_res_id
        , p_res_type
        , p_res_name
        , p_res_typ_name
        , p_res_key;
      CLOSE c_terr_resource;
    END IF;

      OPEN C_Resource_Shift(p_start_date_range,p_end_date_range);
      FETCH C_Resource_Shift
      BULK COLLECT INTO p_trip_id,p_shift_start_date,p_shift_end_date,p_block_trip,p_shift_res_key,p_vir_avail_type ;

      if g_tz_enabled ='Y' and g_dflt_tz_for_dc='CTZ' and p_trip_id.count > 0
      then
        FOR i IN p_trip_id.FIRST .. p_trip_id.LAST
        LOOP
          p_shift_start_date(i) :=fnd_date.adjust_datetime(p_shift_start_date(i),g_client_tz,g_server_tz );
          p_shift_end_date(i)   :=fnd_date.adjust_datetime(p_shift_end_date(i)  ,g_client_tz,g_server_tz);
        END LOOP;
      end if;

      IF g_use_custom_chromatics
      THEN
        get_custom_color;
      END IF;

      IF p_show_arr_dep_tasks = 'Y'
      THEN			/* Added this if condition for bug 6676658 */

      OPEN C_Virtual_Tasks;
      FETCH C_Virtual_Tasks
      BULK COLLECT INTO
      p_vir_task_id
    , p_vir_start_date
    , p_vir_end_date
    , p_vir_color
    , p_vir_name
    , p_vir_duration
    , p_vir_task_type_id
    , p_vir_tooltip
    , p_vir_resource_key
    , l_assignment_id
    , l_task_priority_id
    , l_status_id
    , l_planned_start_date
    , l_planned_end_date
    , l_actual_start_date
    , l_actual_end_date
    , l_actual_effort
    , l_actual_effort_uom
    , l_planned_effort
    , l_planned_effort_uom
    , l_escalated_task
    , l_scheduled_start_date
    , l_scheduled_end_date;

      IF p_vir_task_id.COUNT IS NOT NULL AND p_vir_task_id.COUNT > 0
      THEN
      FOR i IN p_vir_task_id.FIRST .. p_vir_task_id.LAST
      LOOP
        ------------------------------------------
        --for scheduled start dates
        ------------------------------------------
        IF l_scheduled_start_date(i) IS NOT NULL AND l_scheduled_end_date(i) IS NOT NULL
        THEN
          IF l_scheduled_end_date(i) = l_scheduled_start_date(i)
      	  THEN
            IF NVL(l_planned_effort(i), 0) = 0 AND p_vir_task_type_id(i) = 20
            THEN
              p_vir_start_date(i)  :=(l_scheduled_start_date(i) - 5 / 1440);
            END IF; --planned effort
          ELSE
            IF     l_scheduled_end_date(i) > l_scheduled_start_date(i) AND NVL(l_planned_effort(i), 0) = 0
            AND p_vir_task_type_id(i) = 20
    	    THEN
              p_vir_start_date(i)  :=(l_scheduled_start_date(i) - 5 / 1440);
            END IF;   --if scheduled_end_date > scheduled_start_date
          END IF;   --if scheduled end_date = scheduled_start_date
        END IF;
        --end if for r.scheduled_start_date is not null and r.scheduled_end_date is not null
        ------------------------------------------
        --end for scheduled start dates
        ------------------------------------------
        ------------------------------------------
        --for scheduled end dates dates
        ------------------------------------------
        IF l_scheduled_start_date(i) IS NOT NULL AND l_scheduled_end_date(i) IS NOT NULL
        THEN
          IF l_scheduled_start_date(i) = l_scheduled_end_date(i)
          THEN
            IF NVL(l_planned_effort(i), 0) = 0 AND p_vir_task_type_id(i) = 21
            THEN
              p_vir_end_date(i)  :=(l_scheduled_start_date(i) + 5 / 1440);
            ELSE
              IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0
              THEN
                l_planned_effort(i):=convert_to_days(l_planned_effort(i),NVL(l_planned_effort_uom(i),g_uom_hours),g_uom_hours);
              END IF;
              p_vir_end_date(i):=(l_scheduled_start_date(i) + NVL(l_planned_effort(i), 0));
            END IF;   --planned effort
          ELSE
            IF l_scheduled_end_date(i) > l_scheduled_start_date(i)
            THEN
              IF NVL(l_planned_effort(i), 0) = 0 AND p_vir_task_type_id(i) = 21
      	      THEN
                p_vir_end_date(i)  :=(l_scheduled_start_date(i) + 5 / 1440);
              ELSE
                IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0
                THEN
                  l_planned_effort(i):=convert_to_days(l_planned_effort(i),NVL(l_planned_effort_uom(i),g_uom_hours),g_uom_hours);
                END IF;
                p_vir_end_date(i)  :=(l_scheduled_start_date(i) + NVL(l_planned_effort(i), 0));
              END IF; --planned effort
            END IF; --if scheduled_end_date > scheduled_start_date
          END IF; --if scheduled end_date = scheduled_start_date
        END IF; --end if for r.scheduled_start_date is not null and r.scheduled_end_date is not null
        ------------------------------------------
        --end for scheduled end dates
        ------------------------------------------
	IF g_use_custom_chromatics
	THEN
	  l_task_custom_color  := 'N';
	  IF l_rule_id IS NOT NULL
	  THEN
	    IF l_actual_start_date(i) IS NOT NULL
  	    THEN
          IF l_actual_end_date(i) IS NOT NULL
   	      THEN
            IF l_actual_end_date(i) = l_actual_start_date(i)
            THEN
	          l_task_custom_color  := 'Y';
                END IF;   --end if for actual_end_date=actual_start_date
              ELSE
                IF NVL(l_actual_effort(i), 0) = 0
    	        THEN
                  IF NVL(l_planned_effort(i), 0) = 0
                  THEN
                    l_task_custom_color  := 'Y';
                  END IF;
                END IF;
              END IF;   --end if for actual_end_date is not null
            ELSE   --for actual start date is null
              IF p_vir_end_date(i) IS NOT NULL
              THEN
                IF p_vir_end_date(i) = p_vir_start_date(i)
	        THEN
                  l_task_custom_color  := 'Y';
                END IF;
              ELSE
                l_task_custom_color  := 'Y';
              END IF;   --end if scheduled end_date is not null
            END IF;   --end if for actual_start_date is not null
          END IF;   --rule id condition for task date usage
          IF l_task_custom_color = 'Y'
          THEN
           IF l_rule_id IS NOT NULL
           THEN
             IF NVL(p_rule_id, 1) <> l_rule_id
             THEN
               OPEN get_tdu_color(l_rule_id);
    	       FETCH get_tdu_color
      	       INTO p_color;
	       IF get_tdu_color%NOTFOUND
	       THEN
                 CLOSE get_tdu_color;
	         IF(NVL(p_cur_task_type_id, -1) <> p_vir_task_type_id(i)
                 OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
                 OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
                 OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
                   )
	         THEN
                   p_vir_color(i):=do_match(p_vir_task_type_id(i),l_task_priority_id(i),l_status_id(i),l_escalated_task(i));
                   p_cur_color             := p_vir_color(i);
                   p_cur_task_type_id      := p_vir_task_type_id(i);
                   p_cur_task_priority_id  := l_task_priority_id(i);
                   p_cur_task_status_id    := l_status_id(i);
                   p_cur_escalated_task    := l_escalated_task(i);
                 ELSE
                   p_vir_color(i)  := p_cur_color;
                 END IF;
               ELSE
                 p_vir_color(i)  := p_color;
                 CLOSE get_tdu_color;
               END IF;
             ELSE
               p_vir_color(i)  := p_color;
             END IF;
           ELSE
	     IF(NVL(p_cur_task_type_id, -1) <> p_vir_task_type_id(i)
   	     OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
  	     OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
	     OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
   	       )
 	     THEN
               p_vir_color(i):=do_match(p_vir_task_type_id(i), l_task_priority_id(i), l_status_id(i),l_escalated_task(i));
  	       p_cur_color             := p_vir_color(i);
	       p_cur_task_type_id      := p_vir_task_type_id(i);
	       p_cur_task_priority_id  := l_task_priority_id(i);
	       p_cur_task_status_id    := l_status_id(i);
	       p_cur_escalated_task    := l_escalated_task(i);
	     ELSE
	       p_vir_color(i)  := p_cur_color;
	     END IF;
           END IF;
         ELSE
           IF (NVL(p_cur_task_type_id, -1) <> p_vir_task_type_id(i)
           OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
           OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
           OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
              )
           THEN
             p_vir_color(i):=do_match(p_vir_task_type_id(i), l_task_priority_id(i), l_status_id(i), l_escalated_task(i));
	     p_cur_color             := p_vir_color(i);
   	     p_cur_task_type_id      := p_vir_task_type_id(i);
	     p_cur_task_priority_id  := l_task_priority_id(i);
	     p_cur_task_status_id    := l_status_id(i);
  	     p_cur_escalated_task    := l_escalated_task(i);
  	   ELSE
             p_vir_color(i)  := p_cur_color;
           END IF;
         END IF;
       ELSE
         IF l_actual_start_date(i) IS NOT NULL
         THEN
           p_vir_color(i)  := yellow;
         ELSE
           p_vir_color(i)  := blue;
         END IF;
       END IF;

       IF g_tz_enabled ='Y' and g_dflt_tz_for_dc='CTZ'
       THEN
         p_vir_start_date(i) :=fnd_date.adjust_datetime(p_vir_start_date(i),g_client_tz,g_server_tz );
         p_vir_end_date(i)   :=fnd_date.adjust_datetime(p_vir_end_date(i)  ,g_client_tz,g_server_tz);
       END IF;
      END LOOP;
      END IF;
      END IF;   -- for p_show_arr_dep_tasks = 'Y'

      l_task_depends :='N';
      FOR i IN c_icon_setup
      LOOP
        l_task_depends :='Y';

      END LOOP;

      IF  l_task_depends ='Y'
      THEN
        IF g_label_on_task
        THEN
          OPEN c3;
          FETCH c3
          BULK COLLECT INTO real_task_id
		   ,l_task_number
		   ,l_Task_Name
		   ,l_Task_Priority_Name
		   ,l_task_Postal_Code
		   ,l_task_City_name
		   ,l_task_Site_Name
           , real_start_date
           , real_end_date
           , real_color
           , real_duration
           , real_task_type_id
           , l_task_priority_id
           , l_status_id
           , real_tooltip
           , real_resource_key
           , real_name
		   , l_task_customer_name
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
           , real_access_hours
           , real_after_hours
           , real_customer_conf
           , real_task_depend
           , real_parts_required
           , real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom
           , l_task_depend
           ;
          CLOSE c3;
        ELSE
          OPEN c4;
          FETCH c4
          BULK COLLECT INTO real_task_id
           , real_start_date
           , real_end_date
           , real_color
           , real_duration
           , real_task_type_id
           , l_task_priority_id
           , l_status_id
           , real_tooltip
           , real_resource_key
           , real_name
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
           , real_access_hours
           , real_after_hours
           , real_customer_conf
           , real_task_depend
           , real_parts_required
           , real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom
           , l_task_depend
           ;
          CLOSE c4;
        END IF;
      ELSIF  nvl(l_task_depends,'N') ='N'
      THEN
        IF g_label_on_task
        THEN
          OPEN c1;
          FETCH c1
          BULK COLLECT INTO real_task_id
		   ,l_task_number
		   ,l_Task_Name
		   ,l_Task_Priority_Name
		   ,l_task_Postal_Code
		   ,l_task_City_name
		   ,l_task_Site_Name
           , real_start_date
           , real_end_date
           , real_color
           , real_duration
           , real_task_type_id
           , l_task_priority_id
           , l_status_id
           , real_tooltip
           , real_resource_key
           , real_name
		   , l_task_customer_name
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
           , real_access_hours
           , real_after_hours
           , real_customer_conf
           , real_task_depend
           , real_parts_required
           , real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom
           ;
          CLOSE c1;
        ELSE
          OPEN c2;
          FETCH c2
          BULK COLLECT INTO real_task_id
           , real_start_date
           , real_end_date
           , real_color
           , real_duration
           , real_task_type_id
           , l_task_priority_id
           , l_status_id
           , real_tooltip
           , real_resource_key
           , real_name
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
           , real_access_hours
           , real_after_hours
           , real_customer_conf
           , real_task_depend
           , real_parts_required
           , real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom
           ;
          CLOSE c2;
        END IF;
      END IF;

	  IF g_label_on_task
      THEN
		OPEN c_task_bar_info;
		LOOP
		FETCH c_task_bar_info into l_task_attr_list_tmp;
		EXIT WHEN c_task_bar_info%notfound;
			l_task_attr_list :=l_task_attr_list||l_task_attr_list_tmp;
		END LOOP;
	 END IF;






    IF real_task_id.COUNT IS NOT NULL AND real_task_id.COUNT > 0
    THEN
    FOR i IN real_task_id.FIRST .. real_task_id.LAST
    LOOP
      IF g_label_on_task
      THEN
		  real_name(i) := ' ';
		  l_task_attr_list_tmp := l_task_attr_list;

		  LOOP
		    EXIT WHEN l_task_attr_list_tmp IS NULL OR LENGTH(l_task_attr_list_tmp) =0;
			IF SUBSTR(l_task_attr_list_tmp,1,8) ='TASK_NUM'
			THEN
			   IF l_task_number(i) IS NOT NULL
			   THEN
				 real_name(i) :=real_name(i)||' '||l_task_number(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)= 'TASK_NAM'
			THEN
			   IF l_Task_Name(i) is NOT NULL
			   THEN
			   real_name(i) :=real_name(i)||' '||l_Task_Name(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CUS'
			THEN
			   IF l_task_customer_name(i) IS NOT NULL
			   THEN
			     real_name(i) :=real_name(i)||' '||l_task_customer_name(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CST'
			THEN
			  IF l_task_Site_Name(i) IS NOT NULL
			  THEN
				real_name(i) :=real_name(i)||' '||l_task_Site_Name(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CIT'
			THEN
			  IF l_task_City_name(i) IS NOT NULL
			  THEN
				real_name(i) :=real_name(i)||' '||l_task_City_name(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_POS'
			THEN
			  IF l_task_Postal_Code(i) IS NOT NULL
			  THEN
			    real_name(i) :=real_name(i)||' '||l_task_Postal_Code(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_PRI'
			THEN
			  IF l_Task_Priority_Name(i) IS NOT NULL
			  THEN
				real_name(i) :=real_name(i)||' '||l_Task_Priority_Name(i);
			  END IF;
			END IF;
			l_task_attr_list_tmp := SUBSTR(l_task_attr_list_tmp,9);
		  END LOOP;


      IF l_task_attr_list IS NULL
      THEN
         IF l_task_number(i) IS NOT NULL
			   THEN
            real_name(i) :=real_name(i)||' '||l_task_number(i);
			   END IF;
      END IF;
	  END IF;--This end if is for g_label_on_task


      IF nvl(l_task_depends,'N') ='Y'
      THEN
        IF to_number(substr(real_task_id(i),1,instr(real_task_id(i),'-')-1)) = l_task_depend(i)
        THEN
          real_task_depend(i) := 'Y';
        END IF;
      END IF;
      ------------------------------------------
      --for scheduled start dates
      ------------------------------------------
      IF l_actual_start_date(i) IS NOT NULL
      THEN
        real_start_date(i)  := l_actual_start_date(i);
      END IF;
      ------------------------------------------
      --end for scheduled start dates
      ------------------------------------------
      ------------------------------------------
      --for scheduled end dates dates
      ------------------------------------------
      IF l_actual_start_date(i) IS NOT NULL
      THEN
        IF l_actual_end_date(i) IS NULL
        THEN
          IF l_actual_effort(i) IS NULL OR l_actual_effort(i) = 0
          THEN
            IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0
            THEN
              l_planned_effort(i):=csf_gantt_data_pkg.convert_to_days(l_planned_effort(i),NVL(l_planned_effort_uom(i),g_uom_hours),g_uom_hours);
            END IF;
            IF l_default_effort IS NOT NULL AND l_default_effort > 0
            THEN
              l_csf_default_effort:=csf_gantt_data_pkg.convert_to_days(l_default_effort,NVL(l_default_effort_uom,g_uom_hours),g_uom_hours);
            END IF;
            real_end_date(i):=(l_actual_start_date(i) + NVL(l_planned_effort(i), NVL(l_csf_default_effort, 0)));
          ELSE
            l_actual_effort(i):=csf_gantt_data_pkg.convert_to_days(l_actual_effort(i),NVL(l_actual_effort_uom(i),g_uom_hours),g_uom_hours);
            real_end_date(i):=(l_actual_start_date(i) + NVL(l_actual_effort(i), 0));
          END IF;
        ELSE
          IF l_actual_end_date(i) <= l_actual_start_date(i)
          THEN
            IF l_actual_effort(i) IS NULL OR l_actual_effort(i) = 0
            THEN -- this is true then calculate the actual end_date based uppon the profile values.
              IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0
    	      THEN
                l_planned_effort(i):=csf_gantt_data_pkg.convert_to_days(l_planned_effort(i),NVL(l_planned_effort_uom(i),g_uom_hours),g_uom_hours);
              END IF;
              IF l_default_effort IS NOT NULL AND l_default_effort > 0
	      THEN
                l_csf_default_effort:=csf_gantt_data_pkg.convert_to_days(l_default_effort,NVL(l_default_effort_uom,g_uom_hours),g_uom_hours);
              END IF;
              real_end_date(i):=(l_actual_start_date(i) + NVL(l_planned_effort(i), NVL(l_csf_default_effort, 0)));
            ELSE  -- if not null then actual effort to the actual_end_date
              l_actual_effort(i):=csf_gantt_data_pkg.convert_to_days(l_actual_effort(i),NVL(l_actual_effort_uom(i),g_uom_hours),g_uom_hours);
              real_end_date(i):=(l_actual_start_date(i) + NVL(l_actual_effort(i), 0));
            END IF;   --end if for actual effort is nul or zero
          ELSE -- actual end date is not null, check if actual_end_date > actual_start_date
            IF l_actual_end_date(i) > l_actual_start_date(i)
     	    THEN
              real_end_date(i):= l_actual_end_date(i);
            END IF;-- end if
          END IF; --end if for r_sch_end_date.actual_end_date = r_sch_end_date.actual_start_date
        END IF; -- end if for actual_end_date is null
        IF l_actual_travel_duration(i) > 0
        THEN
          IF l_actual_travel_duration_uom(i) IS NOT NULL
          THEN
            real_duration(i):=convert_to_min(l_actual_travel_duration(i),l_actual_travel_duration_uom(i),g_uom_minutes);
          END IF;
        ELSE
          real_duration(i):=0;
        END IF;
      ELSE --else for actual_start_date is null
        IF real_start_date(i) IS NOT NULL
        THEN     -- scheduled_start_date is not null then check if scheduled_end_date is null
          IF real_end_date(i) IS NOT NULL
          THEN  -- scheduled_start_date is not null then check if scheduled_start_date=scheduled_end_date
            IF real_start_date(i) = real_end_date(i)
	    THEN
              IF (l_planned_effort(i) IS NULL) OR(l_planned_effort(i) = 0)
    	      THEN
                IF l_default_effort IS NOT NULL AND l_default_effort > 0
	        THEN
                  l_csf_default_effort:=csf_gantt_data_pkg.convert_to_days(l_default_effort,NVL(l_default_effort_uom, g_uom_hours),g_uom_hours);
                END IF;
                real_end_date(i):=(real_start_date(i) + NVL(l_csf_default_effort, 0));
              ELSE
                IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0
                THEN
                  l_planned_effort(i):=csf_gantt_data_pkg.convert_to_days(l_planned_effort(i),NVL(l_planned_effort_uom(i),g_uom_hours),g_uom_hours);
                END IF;
                real_end_date(i):=(real_start_date(i) + NVL(l_planned_effort(i), 0));
              END IF;
            END IF;
          ELSE -- scheduled_end_date is null then check for planned effort null
            IF (l_planned_effort(i) IS NULL) OR(l_planned_effort(i) = 0)
            THEN
              IF l_default_effort IS NOT NULL AND l_default_effort > 0
              THEN
                l_csf_default_effort:=csf_gantt_data_pkg.convert_to_days(l_default_effort,NVL(l_default_effort_uom,g_uom_hours),g_uom_hours);
              END IF;
              real_end_date(i):=(real_start_date(i) + NVL(l_csf_default_effort, 0));
            ELSE       -- declar variable l_planned_effort to get uom coverted into days for actual effort for
              IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0
              THEN
                l_planned_effort(i):=csf_gantt_data_pkg.convert_to_days(l_planned_effort(i),NVL(l_planned_effort_uom(i),g_uom_hours),g_uom_hours);
              END IF;
              real_end_date(i)  :=(real_start_date(i) + NVL(l_planned_effort(i), 0));
            END IF;
          END IF;   -- end if for scheduled_end_date is null
        END IF;   -- end if for scheduled_start_date is not null
      END IF;   -- end if for actual_start_date is not null
      ------------------------------------------
      --end for scheduled end dates
      ------------------------------------------
      IF is_task_escalated(to_number(SUBSTR(real_task_id(i),1,instr(real_task_id(i),'-')-1)))   --added for the bug 7307125
      THEN
          l_escalated_task(i) := 'Y';
      ELSE
          l_escalated_task(i) := 'N';
      END IF;
      IF g_use_custom_chromatics
      THEN
        l_task_custom_color  := 'N';
        IF l_rule_id IS NOT NULL
        THEN
          IF l_actual_start_date(i) IS NOT NULL
          THEN
            IF l_actual_end_date(i) IS NOT NULL
    	    THEN
              IF l_actual_end_date(i) = l_actual_start_date(i)
   	      THEN
	        l_task_custom_color  := 'Y';
              END IF;   --end if for actual_end_date=actual_start_date
            ELSE
              IF NVL(l_actual_effort(i), 0) = 0
              THEN
                IF NVL(l_planned_effort(i), 0) = 0
	        THEN
                  l_task_custom_color  := 'Y';
                END IF;
              END IF;
            END IF;   --end if for actual_end_date is not null
          ELSE   --for actual start date is null
            IF real_end_date(i) IS NOT NULL
  	    THEN
              IF real_end_date(i) = real_start_date(i)
   	      THEN
                l_task_custom_color  := 'Y';
              END IF;
            ELSE
              l_task_custom_color  := 'Y';
            END IF;   --end if scheduled end_date is not null
          END IF;   --end if for actual_start_date is not null
        END IF;   --rule id condition for task date usage
        IF l_task_custom_color = 'Y'
        THEN
          IF l_rule_id IS NOT NULL
          THEN
	    IF NVL(p_rule_id, 1) <> l_rule_id
	    THEN
              OPEN get_tdu_color(l_rule_id);
	      FETCH get_tdu_color
	      INTO p_color;
	      IF get_tdu_color%NOTFOUND
	      THEN
                CLOSE get_tdu_color;
	        IF(NVL(p_cur_task_type_id, -1) <> real_task_type_id(i)
                OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
                OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
                OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
                  )
  	        THEN
                  real_color(i):=do_match(real_task_type_id(i),l_task_priority_id(i),l_status_id(i),l_escalated_task(i));
                  p_cur_color             := real_color(i);
                  p_cur_task_type_id      := real_task_type_id(i);
                  p_cur_task_priority_id  := l_task_priority_id(i);
                  p_cur_task_status_id    := l_status_id(i);
                  p_cur_escalated_task    := l_escalated_task(i);
                ELSE
                  real_color(i)  := p_cur_color;
                END IF;
              ELSE
                real_color(i)  := p_color;
                CLOSE get_tdu_color;
              END IF;
            ELSE
              real_color(i)  := p_color;
            END IF;
          ELSE
  	    IF(NVL(p_cur_task_type_id, -1) <> real_task_type_id(i)
   	    OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
	    OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
 	    OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
	      )
	    THEN
              real_color(i):=do_match(real_task_type_id(i), l_task_priority_id(i), l_status_id(i),l_escalated_task(i));
	      p_cur_color             := real_color(i);
	      p_cur_task_type_id      := real_task_type_id(i);
              p_cur_task_priority_id  := l_task_priority_id(i);
	      p_cur_task_status_id    := l_status_id(i);
	      p_cur_escalated_task    := l_escalated_task(i);
	    ELSE
	      real_color(i)  := p_cur_color;
	    END IF;
          END IF;
        ELSE
          IF (NVL(p_cur_task_type_id, -1) <> real_task_type_id(i)
          OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
          OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
          OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
             )
          THEN
            real_color(i):=do_match(real_task_type_id(i), l_task_priority_id(i), l_status_id(i), l_escalated_task(i));
	    p_cur_color             := real_color(i);
	    p_cur_task_type_id      := real_task_type_id(i);
	    p_cur_task_priority_id  := l_task_priority_id(i);
	    p_cur_task_status_id    := l_status_id(i);
	    p_cur_escalated_task    := l_escalated_task(i);
	  ELSE
            real_color(i)  := p_cur_color;
          END IF;
        END IF;
      ELSE
        IF l_actual_start_date(i) IS NOT NULL --added for the bug 7307125
        THEN
          real_color(i)  := yellow;
        ELSE
          real_color(i)  := blue;
        END IF;
      END IF;
      IF l_escalated_task(i) = 'Y'
        THEN
          real_color(i)  := red;
      END IF;
      IF g_tz_enabled ='Y' and g_dflt_tz_for_dc='CTZ'
      THEN
         real_start_date(i) :=fnd_date.adjust_datetime(real_start_date(i),g_client_tz,g_server_tz );
         real_end_date(i)   :=fnd_date.adjust_datetime(real_end_date(i)  ,g_client_tz,g_server_tz);
      END IF;
    END LOOP;
    END IF;

  END;

   PROCEDURE get_schedule_advise_options
   (
      p_api_version              IN         NUMBER
    , p_init_msg_list            IN         VARCHAR2 DEFAULT NULL
    , x_return_status            OUT NOCOPY VARCHAR2
    , x_msg_count                OUT NOCOPY NUMBER
    , x_msg_data                 OUT NOCOPY VARCHAR2
    , p_display_option           IN         VARCHAR2
    , p_resource_id              IN         NUMBER
    , p_resource_type            IN         VARCHAR2
    , p_req_id                   IN         NUMBER
    , p_par_task                 IN         NUMBER
    , p_task_id                  IN         NUMBER
    , p_res_id                   OUT NOCOPY jtf_number_table
    , p_res_type                 OUT NOCOPY jtf_varchar2_table_2000
    , p_res_name                 OUT NOCOPY jtf_varchar2_table_2000
    , p_res_typ_name             OUT NOCOPY jtf_varchar2_table_2000
    , p_res_key                  OUT NOCOPY jtf_varchar2_table_2000
    , p_cost                     OUT NOCOPY jtf_number_table
    , p_start_date               IN         DATE
    , p_end_date                 IN         DATE
    , sch_adv_tz                 IN         Varchar2
    , inc_tz_code                IN         Varchar2
    , trip_id                    OUT NOCOPY jtf_number_table
    , start_date                 OUT NOCOPY jtf_date_table
    , end_date                   OUT NOCOPY jtf_date_table
    , block_trip                 OUT NOCOPY jtf_number_table
    , p_bck_res_key              OUT NOCOPY jtf_varchar2_table_2000
    , plan_task_key              OUT NOCOPY    jtf_varchar2_table_100
    , plan_start_date            OUT NOCOPY    jtf_date_table
    , plan_end_date              OUT NOCOPY    jtf_date_table
    , plan_color                 OUT NOCOPY    jtf_number_table
    , plan_name                  OUT NOCOPY    jtf_varchar2_table_2000
    , plan_tooltip               OUT NOCOPY    jtf_varchar2_table_2000
    , plan_duration              OUT NOCOPY    jtf_number_table
    , plan_task_type_id          OUT NOCOPY    jtf_number_table
    , plan_resource_key          OUT NOCOPY    jtf_varchar2_table_2000
    , real_task_key              OUT NOCOPY    jtf_varchar2_table_100
    , real_start_date            OUT NOCOPY    jtf_date_table
    , real_end_date              OUT NOCOPY    jtf_date_table
    , real_color                 OUT NOCOPY    jtf_number_table
    , real_name                  OUT NOCOPY    jtf_varchar2_table_2000
    , real_tooltip               OUT NOCOPY    jtf_varchar2_table_2000
    , real_duration              OUT NOCOPY    jtf_number_table
    , real_task_type_id          OUT NOCOPY    jtf_number_table
    , real_resource_key          OUT NOCOPY    jtf_varchar2_table_2000
    , child_task                 OUT Nocopy    jtf_varchar2_table_100
    , real_parts_required        OUT NOCOPY    jtf_varchar2_table_100
    , real_access_hours          OUT NOCOPY    jtf_varchar2_table_100
    , real_after_hours           OUT NOCOPY    jtf_varchar2_table_100
    , real_customer_conf         OUT NOCOPY    jtf_varchar2_table_100
    , real_task_depend           OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_task_id           OUT Nocopy    jtf_varchar2_table_100
    , oth_real_start_date        OUT Nocopy    jtf_date_table
    , oth_real_end_date          OUT Nocopy    jtf_date_table
    , oth_real_color             OUT Nocopy    jtf_number_table
    , oth_real_Name              OUT Nocopy    jtf_varchar2_table_2000
    , oth_real_Duration          OUT Nocopy    jtf_number_table
    , oth_real_task_type_id      OUT Nocopy    jtf_number_table
    , oth_real_resource_key      OUT Nocopy    jtf_varchar2_table_2000
    , oth_real_child_task        OUT Nocopy    jtf_varchar2_table_100
    , oth_real_parts_required    OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_access_hours      OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_after_hours       OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_customer_conf     OUT NOCOPY    jtf_varchar2_table_100
    , oth_real_task_depend       OUT NOCOPY    jtf_varchar2_table_100
   	, p_vir_avail_type	         OUT NOCOPY    jtf_varchar2_table_2000
    )
   IS
     L_RESOURCE_QUERY                 VARCHAR2(4000);
     L_COMMON_WHERE_RESOURCE_QUERY    VARCHAR2(4000);
     L_COMMON_WHERE_PARENT            VARCHAR2(4000);
     L_COMMON_ORDERBY                 VARCHAR2(4000);
     L_RESOURCE_QUERY_COST            VARCHAR2(4000);
     L_COMMON_WHERE_RESOURCE_COST     VARCHAR2(4000);
     L_RESOURCE_QUERY_COST_DAY        VARCHAR2(4000);
     L_COMMON_WHERE_RESOURCE_SINGLE   VARCHAR2(4000);
     L_RESOURCE_SINGLE_QUERY          VARCHAR2(4000);
     L_QUERY                          VARCHAR2(8000);
      ---------------------------------------------------
      --The below variables are used in color coding proc
      ---------------------------------------------------
      p_cur_task_type_id     NUMBER(10);
      p_cur_task_priority_id NUMBER(10);
      p_cur_task_status_id   NUMBER(10);
      p_cur_escalated_task   VARCHAR2(1);
      p_color                NUMBER(30);
      p_cur_color            NUMBER(30);
      p_rule_id              NUMBER(10);

     l_return_status     VARCHAR2(1);

     TYPE SchResType IS REF CURSOR;
     ResInfo SchResType;

    tmp_trip_id				      jtf_number_table;
    l_task_priority_id			      jtf_number_table;
    l_assignment_status_id		      jtf_number_table;
    l_escalated_task			      jtf_varchar2_table_100;

    l_planned_start_date		      jtf_date_table;
    l_planned_end_date			      jtf_date_table;
    l_actual_start_date			      jtf_date_table;
    l_actual_end_date			      jtf_date_table;
    l_actual_effort			      jtf_number_table;
    l_actual_effort_uom			      jtf_varchar2_table_100;
    l_planned_effort			      jtf_number_table;
    l_planned_effort_uom		      jtf_varchar2_table_100;
    l_actual_travel_duration		      jtf_number_table;
    l_actual_travel_duration_uom	      jtf_varchar2_table_100;
    l_status_id				      jtf_number_table;
    l_csf_default_effort		      NUMBER;
    l_task_depends			      varchar2(1);
    l_task_depend			      jtf_varchar2_table_100;
    oth_real_tooltip			      jtf_varchar2_table_2000;


	  l_task_customer_name      jtf_varchar2_table_1000;
	  l_task_number				jtf_varchar2_table_100;
	  l_Task_Name			    jtf_varchar2_table_1000;
	  l_Task_Priority_Name		jtf_varchar2_table_1000;
	  l_task_City_name			jtf_varchar2_table_1000;
	  l_task_Site_Name  		jtf_varchar2_table_1000;
	  l_task_Postal_Code		jtf_varchar2_table_1000;
	  l_task_attr_list			VARCHAR2(1000);
	  l_task_attr_list_tmp	    VARCHAR2(1000);



    CURSOR c_icon_setup
      IS
      SELECT active
      FROM   csf_gnticons_setup_v
      WHERE  seq_id = 6;

    CURSOR get_tdu_color(t_rule_id NUMBER) IS
      SELECT background_col_dec
      FROM jtf_task_custom_colors
      WHERE rule_id = t_rule_id;

	  CURSOR c_task_bar_info
      IS
      SELECT icon_file_name
      FROM   csf_gnticons_setup_v
      WHERE  INSTR(ICON_FILE_NAME,'TASK') >0
	  AND     nvl(active,'N')='Y'
	  ORDER BY RANKING;


    CURSOR c_res_detail IS
      SELECT DISTINCT cs.object_capacity_id cs
                    , ca.object_capacity_id
                    , ca.start_date_time
                    , ca.end_date_time
                    , status blocked_trip
                    , resource_id
					, nvl(ca.availability_type,'NULL')
                 FROM cac_sr_object_capacity ca
                    , (SELECT resource_id || '-' || resource_type || '-' || plan_option_id
                                                                                        resource_id
                            , object_capacity_id
                            , resource_id res_id
                            , resource_type res_typ
                         FROM csf_plan_options_v
                        WHERE sched_request_id = p_req_id
                          AND task_type_id IN(20, 21)
			) cs
                WHERE ca.object_id = cs.res_id
                  AND ca.object_type = cs.res_typ
                  AND ca.start_date_time >= p_start_date -1
                  AND ca.end_date_time <= p_end_date;

     ---------------------------------------------------------------------------------------------
       --Cursor c_real_task_1 introduced when show labels on taskbar is true i.e join for hz_parties for showing
       --party name on taskbar and this cursor is without task dependencies join.
      ---------------------------------------------------------------------------------------------
	CURSOR c_real_task_1 IS

        SELECT
	     cpv.task_id || '-' || cpv.plan_option_id real_task_key
           , cpv.resource_id || '-' || cpv.resource_type || '-' || cpv.plan_option_id real_resource_key
           , cpv.start_time
           , cpv.end_time
		   , t.task_number
		   , tl.task_name
		   , jtpl.name
		   , NVL(l.postal_code,' ')
           , NVL(l.city,' ')
		   , NVL(ps.party_site_name,' ')
           , 0 color
           , ' ' tooltip
           , NVL(
                 TO_NUMBER(SUBSTR(travel_time, 1, INSTR(travel_time, ':', 1) - 1)) * 60
               + TO_NUMBER(SUBSTR(travel_time, INSTR(travel_time, ':', 1) + 1, 5))
             , 0
             ) travel_time
           , t.task_type_id
           , t.task_priority_id
           , a.assignment_status_id
           , a.actual_start_date
           , a.actual_end_date
           , nvl(pi.party_name,' ') incident_customer_name
		   , nvl(pi.party_name,' ') incident_customer_name1
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , 'N' task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
      FROM   csf_plan_options_v cpv
           , jtf_task_assignments a
           , jtf_tasks_b t
		   , jtf_tasks_tl tl
           , jtf_task_types_b tt
		   , jtf_task_priorities_B jtp
		   , jtf_task_priorities_tl jtpl
     	   , hz_parties pi
		   , hz_party_sites ps
           , hz_locations l
   	       , csf_access_hours_b ca
           , csp_requirement_headers cr
           , jtf_task_statuses_b tsa
           , jtf_task_statuses_b tsb
      WHERE cpv.sched_request_id = p_req_id
        AND NVL(cpv.task_type_id, 0) NOT IN(20, 21)
		AND t.task_type_id = tt.task_type_id
		AND tl.task_id =t.task_id
		AND tl.language=userenv('LANG')
		AND jtp.task_priority_id=t.task_priority_id
		AND jtpl.task_priority_id = jtp.task_priority_id
		AND jtpl.language=userenv('LANG')
        AND cpv.start_time >= p_start_date
        AND cpv.end_time <= p_end_date
    	AND cpv.task_id = t.task_id
	    AND cpv.task_id = a.task_id
        AND ca.task_id(+) = t.task_id
        AND pi.party_id(+) = t.customer_id
 	    AND ps.party_site_id(+) = t.address_id
        AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
        AND cr.task_id(+) = t.task_id
	    AND (cpv.task_id <> -1 AND cpv.task_id <> p_task_id)
        AND tsb.task_status_id = t.task_status_id
        AND tsa.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y';

      ---------------------------------------------------------------------------------------------
      --Cursor c_real_task_3 introduced if task_dependency is set to active in scheduling chart icon setup form
      -- this cursor also has hz_parties join for party name to be shown on task bar
      ---------------------------------------------------------------------------------------------
	CURSOR c_real_task_3 IS

   SELECT
	     cpv.task_id || '-' || cpv.plan_option_id real_task_key
           , cpv.resource_id || '-' || cpv.resource_type || '-' || cpv.plan_option_id real_resource_key
           , cpv.start_time
           , cpv.end_time
		   , t.task_number
		   , tl.task_name
		   , jtpl.name
		   , NVL(l.postal_code,' ')
           , NVL(l.city,' ')
		   , NVL(ps.party_site_name,' ')
           , 0 color
           , ' ' tooltip
           , NVL(
                 TO_NUMBER(SUBSTR(travel_time, 1, INSTR(travel_time, ':', 1) - 1)) * 60
               + TO_NUMBER(SUBSTR(travel_time, INSTR(travel_time, ':', 1) + 1, 5))
             , 0
             ) travel_time
           , t.task_type_id
           , t.task_priority_id
           , a.assignment_status_id
           , a.actual_start_date
           , a.actual_end_date
           , nvl(pi.party_name,' ') incident_customer_name
		   , nvl(pi.party_name,' ') incident_customer_name1
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'

             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , DECODE(nvl(t.task_id,0),jd.task_id,'Y','N') task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
	       , nvl(jdd.dependent_on_task_id,0) || '-' || plan_option_id task_dep1
      FROM   csf_plan_options_v cpv
           , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_tasks_tl tl
           , jtf_task_types_b tt
		   , jtf_task_priorities_B jtp
		   , jtf_task_priorities_tl jtpl
    	   , hz_parties pi
		   , hz_party_sites ps
           , hz_locations l
  	       , csf_access_hours_b ca
           , csp_requirement_headers cr
	       , jtf_task_depends jd
           , jtf_task_depends jdd
           , jtf_task_statuses_b tsa
           , jtf_task_statuses_b tsb
      WHERE cpv.sched_request_id = p_req_id
        AND NVL(cpv.task_type_id, 0) NOT IN(20, 21)
        AND t.task_type_id = tt.task_type_id
		AND tl.task_id =t.task_id
		AND tl.language=userenv('LANG')
		AND jtp.task_priority_id=t.task_priority_id
		AND jtpl.task_priority_id = jtp.task_priority_id
		AND jtpl.language=userenv('LANG')
        AND cpv.start_time >= p_start_date
        AND cpv.end_time <= p_end_date
    	AND cpv.task_id = t.task_id
    	AND cpv.task_id = a.task_id
        AND ca.task_id(+) = t.task_id
        AND pi.party_id(+) = t.customer_id
 	    AND ps.party_site_id(+) = t.address_id
        AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
        AND cr.task_id(+) = t.task_id
  	    AND (cpv.task_id <> -1 AND cpv.task_id <> p_task_id)
	    AND jd.task_id(+) = t.task_id
        AND jdd.dependent_on_task_id(+) = t.task_id
        AND tsb.task_status_id = t.task_status_id
        AND tsa.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y';






      ---------------------------------------------------------------------------------------------
      --Cursor c_real_task_2 introduced when show labels on taskbar is false i.e remove join for hz_parties
      -- the diffrence between c1 and c2 join for hz_parties
      ---------------------------------------------------------------------------------------------
	CURSOR c_real_task_2 IS
        SELECT
	     cpv.task_id || '-' || cpv.plan_option_id real_task_key
           , cpv.resource_id || '-' || cpv.resource_type || '-' || cpv.plan_option_id real_resource_key
           , cpv.start_time
           , cpv.end_time
           , 0 color
           , ' ' tooltip
           , NVL(
                 TO_NUMBER(SUBSTR(travel_time, 1, INSTR(travel_time, ':', 1) - 1)) * 60
               + TO_NUMBER(SUBSTR(travel_time, INSTR(travel_time, ':', 1) + 1, 5))
             , 0
             ) travel_time
           , t.task_type_id
           , task_priority_id
           , a.assignment_status_id
           , a.actual_start_date
           , a.actual_end_date
           , ' ' incident_customer_name
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , 'N' task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
      FROM   csf_plan_options_v cpv
           , jtf_task_assignments a
           , jtf_tasks_b t
     	   , csf_access_hours_b ca
           , csp_requirement_headers cr
           , jtf_task_statuses_b tsa
           , jtf_task_statuses_b tsb
      WHERE cpv.sched_request_id = p_req_id
        AND NVL(cpv.task_type_id, 0) NOT IN(20, 21)
        AND cpv.start_time >= p_start_date
        AND cpv.end_time <= p_end_date
    	AND cpv.task_id = t.task_id
	AND cpv.task_id = a.task_id
        AND ca.task_id(+) = t.task_id
        AND cr.task_id(+) = t.task_id
	AND (cpv.task_id <> -1 AND cpv.task_id <> p_task_id)
        AND tsb.task_status_id = t.task_status_id
        AND tsa.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y';

      ---------------------------------------------------------------------------------------------
      --Cursor c_real_task_4 introduced if task_dependency is set to active in scheduling chart icon setup form
      -- this cursor does not have hz_parties join like c2 but has dependencies join
      ---------------------------------------------------------------------------------------------
	CURSOR c_real_task_4 IS
        SELECT
	     cpv.task_id || '-' || cpv.plan_option_id real_task_key
           , cpv.resource_id || '-' || cpv.resource_type || '-' || cpv.plan_option_id real_resource_key
           , cpv.start_time
           , cpv.end_time
           , 0 color
           , ' ' tooltip
           , NVL(
                 TO_NUMBER(SUBSTR(travel_time, 1, INSTR(travel_time, ':', 1) - 1)) * 60
               + TO_NUMBER(SUBSTR(travel_time, INSTR(travel_time, ':', 1) + 1, 5))
             , 0
             ) travel_time
           , t.task_type_id
           , task_priority_id
           , a.assignment_status_id
           , a.actual_start_date
           , a.actual_end_date
           , ' ' incident_customer_name
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , DECODE(nvl(t.task_id,0),jd.task_id,'Y','N') task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , NVL(jdd.dependent_on_task_id,0) || '-' || plan_option_id task_dep1
      FROM   csf_plan_options_v cpv
           , jtf_task_assignments a
           , jtf_tasks_b t
     	   , csf_access_hours_b ca
           , csp_requirement_headers cr
	   , jtf_task_depends jd
           , jtf_task_depends jdd
           , jtf_task_statuses_b tsa
           , jtf_task_statuses_b tsb
      WHERE cpv.sched_request_id = p_req_id
        AND NVL(cpv.task_type_id, 0) NOT IN(20, 21)
        AND cpv.start_time >= p_start_date
        AND cpv.end_time <= p_end_date
    	AND cpv.task_id = t.task_id
	AND cpv.task_id = a.task_id
        AND ca.task_id(+) = t.task_id
        AND cr.task_id(+) = t.task_id
	AND (cpv.task_id <> -1 AND cpv.task_id <> p_task_id)
	AND jd.task_id(+) = t.task_id
        AND jdd.dependent_on_task_id(+) = t.task_id
        AND tsb.task_status_id = t.task_status_id
        AND tsa.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y';

    CURSOR c_planned_task IS
      SELECT DECODE(task_id, -1, ROWNUM, task_id) || plan_option_id plan_task_key
           , resource_id || '-' || resource_type || '-' || plan_option_id plan_resource_key
           , start_time
           , end_time
           , 65280 color
           , ' ' NAME
           , ' ' tooltip
           , NVL(
                 TO_NUMBER(SUBSTR(travel_time, 1, INSTR(travel_time, ':', 1) - 1)) * 60
               + TO_NUMBER(SUBSTR(travel_time, INSTR(travel_time, ':', 1) + 1, 5))
             , 0
             ) travel_time
           , NVL(task_type_id, 0)
        FROM csf_plan_options_v
       WHERE sched_request_id = p_req_id
         AND NVL(task_type_id, 0) NOT IN(20, 21)
         AND start_time >= p_start_date
         AND end_time <= p_end_date
	 AND (task_id = -1 OR task_id = p_task_id);

	 ---------------------------------------------------------------------------------------------
       --Cursor C1 introduced when show labels on taskbar is true i.e join for hz_parties for showing
       --party name on taskbar and this cursor is without task dependenciea join.
      ---------------------------------------------------------------------------------------------

      CURSOR c1
      IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb pi ca cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             a.task_id || '-'|| plan_option_id
			, t.task_number
		    , tl.task_name
		    , jtpl.name
		    , NVL(l.postal_code,' ')
            , NVL(l.city,' ')
		    , NVL(ps.party_site_name,' ')
           , t.scheduled_start_date
           , t.scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , t.task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code || '-'|| plan_option_id resource_key
           , nvl(pi.party_name,' ') incident_customer_name
		   , nvl(pi.party_name,' ') incident_customer_name1
           , t.planned_start_date
           , t.planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , 'N' task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
      FROM (SELECT distinct rr.resource_id, rr.resource_type,pop.plan_option_id,pt.object_capacity_id
	    FROM csf_r_request_tasks rt,
	       csf_r_resource_results rr,
	       csf_r_plan_options pop,
	       csf_r_plan_option_tasks pt,
	       jtf_tasks_b t
   	   WHERE rt.request_task_id = rr.request_task_id
	   AND rr.resource_result_id = POP.resource_result_id
	   AND POP.plan_option_id = pt.plan_option_id
	   AND pt.task_id = t.task_id(+)
	   AND rt.sched_request_id = p_req_id
	   AND nvl(t.task_type_id, 0) not in(20, 21)) res_info
	       , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_task_types_b tt
           , jtf_tasks_tl tl
           , jtf_task_priorities_B jtp
		   , jtf_task_priorities_tl jtpl
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	       , hz_parties pi
	       , hz_party_sites ps
           , hz_locations l
	       , csf_access_hours_b ca
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND tl.task_id =t.task_id
		AND tl.language=userenv('LANG')
		AND jtp.task_priority_id=t.task_priority_id
		AND jtpl.task_priority_id         = jtp.task_priority_id
		AND jtpl.language=userenv('LANG')
		AND booking_start_date <= (p_end_date)
        AND booking_end_date   >= (p_start_date -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND pi.party_id(+) = t.customer_id
		AND ps.party_site_id(+) = t.address_id
        AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date
	    AND a.object_capacity_id <>res_info.object_capacity_id;

      ---------------------------------------------------------------------------------------------
      --Cursor C3 introduced if task_dependency is set to active in scheduling chart icon setup form
      -- this cursor also has hz_parties join for party name to be shown on task bar
      ---------------------------------------------------------------------------------------------
      CURSOR c3 IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb pi ca jd jdd cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             DISTINCT
             a.task_id || '-'|| plan_option_id
			, t.task_number
		    , tl.task_name
		    , jtpl.name
		    , NVL(l.postal_code,' ')
            , NVL(l.city,' ')
		    , NVL(ps.party_site_name,' ')
           , t.scheduled_start_date
           , t.scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , t.task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code || '-'|| plan_option_id resource_key
           , nvl(pi.party_name,' ') incident_customer_name
		   , nvl(pi.party_name,' ') incident_customer_name1
           , t.planned_start_date
           , t.planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , DECODE(nvl(t.task_id,0),jd.task_id,'Y','N') task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , nvl(jdd.dependent_on_task_id,0) || '-' || plan_option_id task_dep1
      FROM (SELECT distinct rr.resource_id, rr.resource_type,pop.plan_option_id,pt.object_capacity_id
	    FROM csf_r_request_tasks rt,
	       csf_r_resource_results rr,
	       csf_r_plan_options pop,
	       csf_r_plan_option_tasks pt,
	       jtf_tasks_b t
   	   WHERE rt.request_task_id = rr.request_task_id
	   AND rr.resource_result_id = POP.resource_result_id
	   AND POP.plan_option_id = pt.plan_option_id
	   AND pt.task_id = t.task_id(+)
	   AND rt.sched_request_id = p_req_id
	   AND nvl(t.task_type_id, 0) not in(20, 21)) res_info
		   , jtf_task_assignments a
           , jtf_tasks_b t
		   , jtf_tasks_tl tl
           , jtf_task_types_b tt
	       , jtf_task_priorities_B jtp
		   , jtf_task_priorities_tl jtpl
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	       , hz_parties pi
	       , hz_party_sites ps
           , hz_locations l
	       , csf_access_hours_b ca
           , jtf_task_depends jd
           , jtf_task_depends jdd
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND tl.task_id =t.task_id
		AND tl.language=userenv('LANG')
		AND jtp.task_priority_id=t.task_priority_id
		AND jtpl.task_priority_id         = jtp.task_priority_id
		AND jtpl.language=userenv('LANG')
		AND booking_start_date <= (p_end_date)
        AND booking_end_date >= (p_start_date -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND jd.task_id(+) = t.task_id
        AND jdd.dependent_on_task_id(+) = t.task_id
        AND pi.party_id(+) = t.customer_id
		AND ps.party_site_id(+) = t.address_id
		AND l.location_id(+) = csf_tasks_pub.get_task_location_id(t.task_id,t.address_id,t.location_id)
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date
    	AND a.object_capacity_id <>res_info.object_capacity_id;

      ---------------------------------------------------------------------------------------------
      --Cursor C2 introduced when show labels on taskbar is false i.e remove join for hz_parties
      -- the diffrence between c1 and c2 join for hz_parties
      ---------------------------------------------------------------------------------------------
      CURSOR c2 IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb ca cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             a.task_id || '-'|| plan_option_id
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code || '-'|| plan_option_id resource_key
           , ' ' incident_customer_name
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , 'N' task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
      FROM (SELECT distinct rr.resource_id, rr.resource_type,pop.plan_option_id,pt.object_capacity_id
	    FROM csf_r_request_tasks rt,
	       csf_r_resource_results rr,
	       csf_r_plan_options pop,
	       csf_r_plan_option_tasks pt,
	       jtf_tasks_b t
   	   WHERE rt.request_task_id = rr.request_task_id
	   AND rr.resource_result_id = POP.resource_result_id
	   AND POP.plan_option_id = pt.plan_option_id
	   AND pt.task_id = t.task_id(+)
	   AND rt.sched_request_id = p_req_id
	   AND nvl(t.task_type_id, 0) not in(20, 21)) res_info
    	   , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_task_types_b tt
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	       , csf_access_hours_b ca
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND booking_start_date <= (p_end_date)
        AND booking_end_date >= (p_start_date -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date
	AND a.object_capacity_id <>res_info.object_capacity_id;
      ---------------------------------------------------------------------------------------------
      --Cursor C4 introduced if task_dependency is set to active in scheduling chart icon setup form
      -- this cursor does not have hz_parties join like c2 but has dependencies join
      ---------------------------------------------------------------------------------------------
      CURSOR C4
      IS
      SELECT /*+ ORDERED use_nl (res_info a t tt tsa tsb ca jd jdd cr)
                     INDEX (t,JTF_TASKS_B_U3)
                     INDEX (a,JTF_TASK_ASSIGNMENTS_N1) */
             DISTINCT
             a.task_id || '-'|| plan_option_id
           , scheduled_start_date
           , scheduled_end_date
           , 0 color
           , NVL(sched_travel_duration, 0)
           , t.task_type_id
           , task_priority_id
           , a.assignment_status_id
           , '0' tooltip
           , a.resource_id || '-' || a.resource_type_code || '-'|| plan_option_id resource_key
           , ' ' incident_customer_name
           , planned_start_date
           , planned_end_date
           , a.actual_start_date
           , a.actual_end_date
           , NVL(a.actual_effort, t.actual_effort)
           , NVL(a.actual_effort_uom, t.actual_effort_uom)
           , t.planned_effort
           , t.planned_effort_uom
           , NVL(
               DECODE(t.task_type_id, 22, DECODE(t.escalation_level, 'DE', 'N', 'NE', 'N', 'Y'))
             , 'N'
             ) escalated_task
           , NVL(accesshour_required, 'N')
           , NVL(after_hours_flag, 'N')
           , NVL(task_confirmation_status, 'N')
           , DECODE(nvl(t.task_id,0),jd.task_id,'Y','N') task_dep
           , DECODE(cr.task_id, t.task_id, 'Y', 'N') parts_req
           , NVL(child_position, 'N') child_task
           , a.actual_travel_duration
           , a.actual_travel_duration_uom
           , nvl(jdd.dependent_on_task_id,0) || '-' || plan_option_id task_dep1
      FROM (SELECT distinct rr.resource_id, rr.resource_type,POP.plan_option_id,pt.object_capacity_id
	    FROM csf_r_request_tasks rt,
	       csf_r_resource_results rr,
	       csf_r_plan_options pop,
	       csf_r_plan_option_tasks pt,
	       jtf_tasks_b t
   	   WHERE rt.request_task_id = rr.request_task_id
	   AND rr.resource_result_id = POP.resource_result_id
	   AND POP.plan_option_id = pt.plan_option_id
	   AND pt.task_id = t.task_id(+)
	   AND rt.sched_request_id = p_req_id
	   AND nvl(t.task_type_id, 0) not in(20, 21)) res_info
    	   , jtf_task_assignments a
           , jtf_tasks_b t
           , jtf_task_types_b tt
           , jtf_task_statuses_b tsb
           , jtf_task_statuses_b tsa
	       , csf_access_hours_b ca
           , jtf_task_depends jd
           , jtf_task_depends jdd
           , csp_requirement_headers cr
      WHERE t.task_id = a.task_id
        AND t.source_object_type_code in( 'SR','TASK')
        AND NVL(t.deleted_flag, 'N') <> 'Y'
        AND t.task_type_id NOT IN (20,21)
        AND t.task_type_id = tt.task_type_id
		AND booking_start_date <= (p_end_date)
        AND booking_end_date >= (p_start_date -1)
        AND a.resource_id = res_info.resource_id
        AND a.resource_type_code = res_info.resource_type
        AND tsa.task_status_id = t.task_status_id
        AND tsb.task_status_id = a.assignment_status_id
        AND NVL(tsa.cancelled_flag, 'N') <> 'Y'
        AND NVL(tsb.cancelled_flag, 'N') <> 'Y'
        AND ca.task_id(+) = t.task_id
        AND jd.task_id(+) = t.task_id
        AND jdd.dependent_on_task_id(+) = t.task_id
        AND cr.task_id(+) = t.task_id
        AND booking_end_date >= booking_start_date
	AND a.object_capacity_id <>res_info.object_capacity_id;


	 TYPE custom_color_rec IS RECORD(
       task_type_id         NUMBER
      , task_priority_id     NUMBER
      , assignment_status_id NUMBER
      , escalated_task       VARCHAR2(1)
      , background_col_dec   NUMBER
      , background_col_rgb   VARCHAR2(12)
      );

      TYPE custom_color_tbl IS TABLE OF custom_color_rec
      INDEX BY BINARY_INTEGER;

      g_custom_color_tbl       custom_color_tbl;

      PROCEDURE get_custom_color IS
        CURSOR c_custom_color IS
        SELECT   type_id
               , priority_id
               , assignment_status_id
               , escalated_task
               , background_col_dec
               , background_col_rgb
            FROM jtf_task_custom_colors
           WHERE active_flag = 'Y'
        ORDER BY color_determination_priority;

        i BINARY_INTEGER := 0;
      BEGIN
        IF g_custom_color_tbl.COUNT = 0
        THEN
          FOR rec IN c_custom_color
	  LOOP
            i := i + 1;
            g_custom_color_tbl(i).task_type_id          := rec.type_id;
            g_custom_color_tbl(i).task_priority_id      := rec.priority_id;
            g_custom_color_tbl(i).assignment_status_id  := rec.assignment_status_id;
            g_custom_color_tbl(i).escalated_task        := rec.escalated_task;
            g_custom_color_tbl(i).background_col_dec    := rec.background_col_dec;
            g_custom_color_tbl(i).background_col_rgb    := rec.background_col_rgb;
          END LOOP;
        END IF;
      END get_custom_color;

      FUNCTION do_match(
        p_task_type_id         IN NUMBER
      , p_task_priority_id     IN NUMBER
      , p_assignment_status_id IN NUMBER
      , p_escalated_task       IN VARCHAR2
      )
        RETURN NUMBER IS
      BEGIN
        FOR i IN g_custom_color_tbl.FIRST .. g_custom_color_tbl.LAST
	LOOP
          IF  NVL(g_custom_color_tbl(i).task_type_id, p_task_type_id) = p_task_type_id
          AND NVL(g_custom_color_tbl(i).task_priority_id, p_task_priority_id) = p_task_priority_id
          AND NVL(g_custom_color_tbl(i).assignment_status_id, p_assignment_status_id) =
                                                                              p_assignment_status_id
          AND NVL(g_custom_color_tbl(i).escalated_task, p_escalated_task) = p_escalated_task THEN
            RETURN g_custom_color_tbl(i).background_col_dec;
          END IF;
        END LOOP;
        RETURN 0;
      END do_match;



   BEGIN


     --- Fix for bug 7282611 forward ported.
     g_server_tz := fnd_timezones.get_server_timezone_code;
     g_client_tz := fnd_timezones.get_client_timezone_code;
     --- end of fix for bug 7282611
     p_res_id                   := jtf_number_table();
     p_res_type                 := jtf_varchar2_table_2000();
     p_res_name                 := jtf_varchar2_table_2000();
     p_res_typ_name             := jtf_varchar2_table_2000();
     p_res_key                  := jtf_varchar2_table_2000();
     p_cost                     := jtf_number_table();

     trip_id                    := jtf_number_table();
     start_date                 := jtf_date_table();
     end_date                   := jtf_date_table();
     block_trip                 := jtf_number_table();
     tmp_trip_id                := jtf_number_table();
     p_bck_res_key              := jtf_varchar2_table_2000();

     ---------------------------------------------------------
     --tables used for getting real/to be plan task parameters
     ---------------------------------------------------------
     plan_task_key              := jtf_varchar2_table_100();
     plan_start_date            := jtf_date_table();
     plan_end_date              := jtf_date_table();
     plan_color                 := jtf_number_table();
     plan_name                  := jtf_varchar2_table_2000();
     plan_tooltip               := jtf_varchar2_table_2000();
     plan_duration              := jtf_number_table();
     plan_task_type_id          := jtf_number_table();
     plan_resource_key          := jtf_varchar2_table_2000();
     real_task_key              := jtf_varchar2_table_100();
     real_start_date            := jtf_date_table();
     real_end_date              := jtf_date_table();
     real_color                 := jtf_number_table();
     real_name                  := jtf_varchar2_table_2000();
     real_tooltip               := jtf_varchar2_table_2000();
     real_duration              := jtf_number_table();
     real_task_type_id          := jtf_number_table();
     real_resource_key          := jtf_varchar2_table_2000();
     child_task                 := jtf_varchar2_table_100();
     real_parts_required        := jtf_varchar2_table_100();
     real_access_hours          := jtf_varchar2_table_100();
     real_after_hours           := jtf_varchar2_table_100();
     real_customer_conf         := jtf_varchar2_table_100();
     real_task_depend           := jtf_varchar2_table_100();
     l_task_priority_id         := jtf_number_table();
     l_assignment_status_id     := jtf_number_table();
     l_escalated_task           := jtf_varchar2_table_100();

     oth_real_task_id           := jtf_varchar2_table_100();
     oth_real_start_date        := jtf_date_table();
     oth_real_end_date          := jtf_date_table();
     oth_real_color             := jtf_number_table();
     oth_real_NAME              := jtf_varchar2_table_2000();
     oth_real_tooltip           := jtf_varchar2_table_2000();
     oth_real_DURATION          := jtf_number_table();
     oth_real_task_type_id      := jtf_number_table();
     oth_real_resource_key      := jtf_varchar2_table_2000();
     oth_real_child_task        := jtf_varchar2_table_100();
     oth_real_parts_required    := jtf_varchar2_table_100();
     oth_real_access_hours      := jtf_varchar2_table_100();
     oth_real_after_hours       := jtf_varchar2_table_100();
     oth_real_customer_conf     := jtf_varchar2_table_100();
     oth_real_task_depend       := jtf_varchar2_table_100();

      p_vir_avail_type 		    := jtf_varchar2_table_2000();

     l_planned_start_date       := jtf_date_table();
     l_planned_end_date         := jtf_date_table();
     l_actual_start_date        := jtf_date_table();
     l_actual_end_date          := jtf_date_table();
     l_actual_effort            := jtf_number_table();
     l_actual_effort_uom        := jtf_varchar2_table_100();
     l_planned_effort           := jtf_number_table();
     l_planned_effort_uom       := jtf_varchar2_table_100();
     l_actual_travel_duration   := jtf_number_table();
     l_actual_travel_duration_uom :=jtf_varchar2_table_100();
     l_status_id                := jtf_number_table();

	 	  -------------------------------------------------------
	  --Tables for getting taskbar label information
	  -------------------------------------------------------
	  l_task_customer_name      := jtf_varchar2_table_1000();
	  l_task_number 			:=jtf_varchar2_table_100();
	  l_Task_Name			    :=jtf_varchar2_table_1000();
	  l_Task_Priority_Name		:=jtf_varchar2_table_1000();
	  l_task_City_name			:=jtf_varchar2_table_1000();
	  l_task_Site_Name  		:=jtf_varchar2_table_1000();
	  l_task_Postal_Code		:=jtf_varchar2_table_1000();

	   g_label_on_task          := fnd_profile.value_specific('CSF_DISPLAY_LABEL_ON_TASK', g_user_id) = 'Y';
       g_dflt_tz_for_dc         := fnd_profile.value_specific('CSF_DEFAULT_TIMEZONE_DC', g_user_id);
       g_dflt_tz_for_sc         := fnd_profile.value_specific('CSF_DEFAULT_TIMEZONE_SC', g_user_id);




L_COMMON_WHERE_RESOURCE_SINGLE:= ' AND (NVL(PT.TASK_ID,0)= :4 OR NVL(PT.TASK_ID,0) = -1)';
L_COMMON_WHERE_RESOURCE_QUERY := ' AND (NVL(PT.TASK_ID,0)= :2 OR NVL(PT.TASK_ID,0) = -1) ';
L_COMMON_WHERE_PARENT         := ' AND NVL(PT.TASK_ID,0) = -1 ';
L_COMMON_ORDERBY              := ' ORDER BY POP.PLAN_OPTION_ID, PT.SCHEDULED_START_DATE ';
L_COMMON_WHERE_RESOURCE_COST  := ' AND (NVL(PT.TASK_ID,0)= :3 OR NVL(PT.TASK_ID,0) = -1)';


L_RESOURCE_QUERY              := ' SELECT  RR.RESOURCE_ID'
			       ||',RR.RESOURCE_TYPE'
			       ||',CSF_RESOURCE_PUB.GET_RESOURCE_NAME (RR.RESOURCE_ID,RR.RESOURCE_TYPE) RESOURCE_NAME'
			       ||',CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(RR.RESOURCE_TYPE ) RESOURCE_TYPE_NAME'
			       ||',RR.RESOURCE_ID||''-''||RR.RESOURCE_TYPE||''-''||POP.PLAN_OPTION_ID RESOURCE_KEY'
			       ||',POP.COST'
			       ||' FROM '
			       ||' CSF_R_REQUEST_TASKS RT,'
			       ||' CSF_R_RESOURCE_RESULTS RR,'
			       ||' CSF_R_PLAN_OPTIONS POP,'
			       ||' CSF_R_PLAN_OPTION_TASKS PT,'
			       ||' JTF_TASKS_B T'
			       ||' WHERE RT.SCHED_REQUEST_ID =:1'
			       ||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21))'
			       ||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID'
			       ||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID'
			       ||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID'
			       ||' AND PT.TASK_ID = T.TASK_ID(+)';

L_RESOURCE_QUERY_COST         := ' SELECT  RR.RESOURCE_ID'
			       ||',RR.RESOURCE_TYPE'
			       ||',CSF_RESOURCE_PUB.GET_RESOURCE_NAME (RR.RESOURCE_ID,RR.RESOURCE_TYPE) RESOURCE_NAME'
			       ||',CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(RR.RESOURCE_TYPE ) RESOURCE_TYPE_NAME'
			       ||',RR.RESOURCE_ID||''-''||RR.RESOURCE_TYPE||''-''||POP.PLAN_OPTION_ID RESOURCE_KEY'
			       ||',POP.COST'
			       ||' FROM '
			       ||' CSF_R_REQUEST_TASKS RT,'
			       ||' CSF_R_RESOURCE_RESULTS RR,'
			       ||' CSF_R_PLAN_OPTIONS POP,'
			       ||' CSF_R_PLAN_OPTION_TASKS PT,'
			       ||' JTF_TASKS_B T'
			       ||' WHERE RT.SCHED_REQUEST_ID =:1'
			       ||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID'
			       ||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID'
			       ||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID'
			       ||' AND PT.TASK_ID = T.TASK_ID(+)'
			       ||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21))'
		 	       ||' AND (RR.RESOURCE_ID,POP.COST)'
			       ||' IN '
			       ||' (SELECT RR.RESOURCE_ID,MIN(POP.COST)'
			       ||' FROM'
			       ||' CSF_R_REQUEST_TASKS RT,'
			       ||' CSF_R_RESOURCE_RESULTS RR,'
			       ||' CSF_R_PLAN_OPTIONS POP,'
			       ||' CSF_R_PLAN_OPTION_TASKS PT,'
			       ||' JTF_TASKS_B T'
			       ||' WHERE RT.SCHED_REQUEST_ID =:2'
       			       ||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID'
			       ||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID'
			       ||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID'
			       ||' AND PT.TASK_ID = T.TASK_ID(+)'
			       ||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21))'
			       ||' GROUP BY RR.RESOURCE_ID)';

L_RESOURCE_QUERY_COST_DAY    :=   ' SELECT RR.RESOURCE_ID '
				||' ,RR.RESOURCE_TYPE '
				||' ,CSF_RESOURCE_PUB.GET_RESOURCE_NAME (RR.RESOURCE_ID,RR.RESOURCE_TYPE) RESOURCE_NAME '
				||' ,CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(RR.RESOURCE_TYPE ) RESOURCE_TYPE_NAME '
				||' ,RR.RESOURCE_ID||''-''||RR.RESOURCE_TYPE||''-''||POP.PLAN_OPTION_ID RESOURCE_KEY '
				||' ,POP.COST '
				||' FROM '
				||' CSF_R_REQUEST_TASKS RT, '
				||' CSF_R_RESOURCE_RESULTS RR, '
				||' CSF_R_PLAN_OPTIONS POP, '
				||' CSF_R_PLAN_OPTION_TASKS PT, '
				||' JTF_TASKS_B T '
				||' WHERE RT.SCHED_REQUEST_ID = :1 '
				||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID '
				||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID '
				||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID '
				||' AND PT.TASK_ID = T.TASK_ID(+) '
				||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21)) '
				||' AND PT.PLAN_OPTION_ID IN ( '
				||' SELECT PLAN_OPTION_ID FROM  '
				||' (SELECT PT.PLAN_OPTION_ID, MIN(trunc(PT.SCHEDULED_START_DATE)) START_TIME,MIN(POP.COST) COST '
				||' FROM '
				||' CSF_R_REQUEST_TASKS RT, '
				||' CSF_R_RESOURCE_RESULTS RR, '
				||' CSF_R_PLAN_OPTIONS POP, '
				||' CSF_R_PLAN_OPTION_TASKS PT, '
				||' JTF_TASKS_B T '
				||' WHERE RT.SCHED_REQUEST_ID = :2 '
				||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID '
				||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID '
				||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID '
				||' AND PT.TASK_ID = T.TASK_ID(+) '
				||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21)) '
				||' GROUP BY PT.PLAN_OPTION_ID '
				||' ) WHERE (TRUNC(START_TIME),COST) IN  '
				||' (select TRUNC(START_TIME), MIN(COST) from '
				||' (SELECT MIN(trunc(PT.SCHEDULED_START_DATE)) START_TIME,MIN(POP.COST) COST '
				||' FROM '
				||' CSF_R_REQUEST_TASKS RT, '
				||' CSF_R_RESOURCE_RESULTS RR, '
				||' CSF_R_PLAN_OPTIONS POP, '
				||' CSF_R_PLAN_OPTION_TASKS PT, '
				||' JTF_TASKS_B T '
				||' WHERE RT.SCHED_REQUEST_ID = :4 '
				||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID '
				||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID '
				||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID '
				||' AND PT.TASK_ID = T.TASK_ID(+) '
				||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21)) '
				||' GROUP BY PT.PLAN_OPTION_ID) '
				||' GROUP BY TRUNC(START_TIME))) ';

L_RESOURCE_SINGLE_QUERY       :=' SELECT  RR.RESOURCE_ID'
			       ||',RR.RESOURCE_TYPE'
			       ||',CSF_RESOURCE_PUB.GET_RESOURCE_NAME (RR.RESOURCE_ID,RR.RESOURCE_TYPE) RESOURCE_NAME'
			       ||',CSF_GANTT_DATA_PKG.GET_RESOURCE_TYPE_NAME(RR.RESOURCE_TYPE ) RESOURCE_TYPE_NAME'
			       ||',RR.RESOURCE_ID||''-''||RR.RESOURCE_TYPE||''-''||POP.PLAN_OPTION_ID RESOURCE_KEY'
			       ||',POP.COST'
			       ||' FROM '
			       ||' CSF_R_REQUEST_TASKS RT,'
			       ||' CSF_R_RESOURCE_RESULTS RR,'
			       ||' CSF_R_PLAN_OPTIONS POP,'
			       ||' CSF_R_PLAN_OPTION_TASKS PT,'
			       ||' JTF_TASKS_B T'
			       ||' WHERE RT.SCHED_REQUEST_ID =:1'
      			       ||' AND RT.REQUEST_TASK_ID = RR.REQUEST_TASK_ID'
			       ||' AND RR.RESOURCE_RESULT_ID = POP.RESOURCE_RESULT_ID'
			       ||' AND POP.PLAN_OPTION_ID = PT.PLAN_OPTION_ID'
			       ||' AND PT.TASK_ID = T.TASK_ID(+)'
			       ||' AND (NVL(T.TASK_TYPE_ID,0) NOT IN (20,21))'
	   		       ||' AND  RR.RESOURCE_ID	   = :2'
			       ||' AND  RR.RESOURCE_TYPE    = :3';

     IF p_par_task is not null and p_par_task > 0
     THEN
       IF p_display_option = 'D'
       THEN

         L_QUERY :=L_RESOURCE_QUERY_COST_DAY||L_COMMON_WHERE_PARENT||L_COMMON_ORDERBY;

       ELSIF p_display_option = 'R'
       THEN

         L_QUERY :=L_RESOURCE_QUERY_COST ||L_COMMON_WHERE_PARENT||L_COMMON_ORDERBY;
       ELSIF p_display_option = 'S'
       THEN

         L_QUERY := L_RESOURCE_SINGLE_QUERY||L_COMMON_WHERE_PARENT||L_COMMON_ORDERBY;
       ELSE
         L_QUERY := L_RESOURCE_QUERY||L_COMMON_WHERE_PARENT||L_COMMON_ORDERBY;
       END IF;
     ELSE
       IF p_display_option = 'D'
       THEN
         L_QUERY := L_RESOURCE_QUERY_COST_DAY||L_COMMON_WHERE_RESOURCE_COST||L_COMMON_ORDERBY;
       ELSIF p_display_option = 'R'
       THEN
		 L_QUERY := L_RESOURCE_QUERY_COST||L_COMMON_WHERE_RESOURCE_COST||L_COMMON_ORDERBY;
       ELSIF p_display_option = 'S'
       THEN
         L_QUERY := L_RESOURCE_SINGLE_QUERY||L_COMMON_WHERE_RESOURCE_SINGLE||L_COMMON_ORDERBY;
       ELSE
         L_QUERY := L_RESOURCE_QUERY||L_COMMON_WHERE_RESOURCE_QUERY||L_COMMON_ORDERBY;
       END IF;
     END IF;
     IF p_par_task is not null and p_par_task > 0
     THEN
	IF  p_display_option = 'D'
	THEN
  	  OPEN  ResInfo FOR L_QUERY USING p_req_id,p_req_id,p_req_id;
          FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
          CLOSE ResInfo;
	ELSIF p_display_option = 'R'
	THEN
  	  OPEN  ResInfo FOR L_QUERY USING p_req_id,p_req_id;
          FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
          CLOSE ResInfo;
        ELSIF p_display_option = 'S'
        THEN
  	  OPEN  ResInfo FOR L_QUERY USING p_req_id,p_resource_id,p_resource_type;
          FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
          CLOSE ResInfo;
        ELSE
  	  OPEN  ResInfo FOR L_QUERY USING p_req_id;
          FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
          CLOSE ResInfo;
        END IF;
     ELSE
       IF p_display_option = 'D'
       THEN
         OPEN  ResInfo FOR L_QUERY USING p_req_id,p_req_id,p_req_id,p_task_id;
         FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
         CLOSE ResInfo;
       ELSIF p_display_option = 'R'
       THEN
         OPEN  ResInfo FOR L_QUERY USING p_req_id,p_req_id,p_task_id;
         FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
         CLOSE ResInfo;
       ELSIF p_display_option = 'S'
       THEN
         OPEN  ResInfo FOR L_QUERY USING p_req_id,p_resource_id,p_resource_type ,p_task_id;
         FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
         CLOSE ResInfo;
       ELSE
         OPEN  ResInfo FOR L_QUERY USING p_req_id,p_task_id;
         FETCH ResInfo BULK COLLECT INTO p_res_id,p_res_type,p_res_name,p_res_typ_name,p_res_key,p_cost;
         CLOSE ResInfo;
       END IF;
     END IF;

     OPEN c_res_detail;
     FETCH c_res_detail
     BULK COLLECT INTO tmp_trip_id
         , trip_id
         , start_date
         , end_date
         , block_trip
         , p_bck_res_key
		 , p_vir_avail_type;
     CLOSE c_res_detail;

    if g_tz_enabled ='Y' and sch_adv_tz='CTZ' and trip_id.count > 0
    then
      IF trip_id.COUNT IS NOT NULL AND trip_id.COUNT > 0
      THEN
        FOR i IN trip_id.FIRST .. trip_id.LAST
        LOOP
          start_date(i) :=fnd_date.adjust_datetime(start_date(i),g_client_tz,g_server_tz );
          end_date(i)   :=fnd_date.adjust_datetime(end_date(i)  ,g_client_tz,g_server_tz);
        END LOOP;
      END IF;
    elsif g_tz_enabled ='Y' and sch_adv_tz='ITZ' and trip_id.count > 0
    then
      IF trip_id.COUNT IS NOT NULL AND trip_id.COUNT > 0
      THEN
        FOR i IN trip_id.FIRST .. trip_id.LAST
        LOOP
          start_date(i) :=fnd_date.adjust_datetime(start_date(i),g_client_tz,inc_tz_code );
          end_date(i)   :=fnd_date.adjust_datetime(end_date(i)  ,g_client_tz,inc_tz_code);
        END LOOP;
      END IF;
    end if;

    OPEN  c_planned_task;
    FETCH c_planned_task
    BULK COLLECT INTO plan_task_key
         , plan_resource_key
         , plan_start_date
         , plan_end_date
         , plan_color
         , plan_name
         , plan_tooltip
         , plan_duration
         , plan_task_type_id;
    CLOSE c_planned_task;

    IF plan_task_key.COUNT IS NOT NULL AND plan_task_key.COUNT > 0
    THEN
      FOR i IN plan_task_key.first..plan_task_key.last
      LOOP
        IF g_tz_enabled ='Y' AND sch_adv_tz='CTZ'
        THEN
          plan_start_date(i):=fnd_date.adjust_datetime(plan_start_date(i),g_client_tz,g_server_tz );
        ELSIF g_tz_enabled ='Y' AND sch_adv_tz='ITZ'
        THEN
          plan_start_date(i):=fnd_date.adjust_datetime(plan_start_date(i),g_client_tz,inc_tz_code );
        END IF;
        IF g_tz_enabled ='Y' AND sch_adv_tz='CTZ'
        THEN
          plan_end_date(i):=fnd_date.adjust_datetime(plan_end_date(i),g_client_tz,g_server_tz);
        ELSIF g_tz_enabled ='Y' AND  sch_adv_tz='ITZ'
        THEN
          plan_end_date(i):=fnd_date.adjust_datetime(plan_end_date(i),g_client_tz,inc_tz_code);
        END IF;
      END LOOP;
    END IF;

    IF g_use_custom_chromatics
    THEN
      get_custom_color;
    END IF;

    l_task_depends :='N';
    FOR i IN c_icon_setup
    LOOP
	  IF i.active is not null
	  THEN
       l_task_depends :=i.active;
	  ELSE
	   l_task_depends :='N';
	  END IF;
    END LOOP;

    IF  l_task_depends ='Y'
    THEN
      IF g_label_on_task
      THEN

        OPEN c3;
        FETCH c3
        BULK COLLECT INTO oth_real_task_id
		   ,l_task_number
		   ,l_Task_Name
		   ,l_Task_Priority_Name
		   ,l_task_Postal_Code
		   ,l_task_City_name
		   ,l_task_Site_Name
           , oth_real_start_date
           , oth_real_end_date
           , oth_real_color
           , oth_real_DURATION
           , oth_real_task_type_id
           , l_task_priority_id
           , l_status_id
           , oth_real_tooltip
           , oth_real_resource_key
           , oth_real_NAME
		   ,l_task_customer_name
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
		, oth_real_access_hours
	   , oth_real_after_hours
	   , oth_real_customer_conf
	   , oth_real_task_depend
           , oth_real_parts_required
	   , oth_real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom
           , l_task_depend
           ;
        CLOSE c3;
      ELSE

        OPEN c4;
        FETCH c4
        BULK COLLECT INTO oth_real_task_id
           , oth_real_start_date
           , oth_real_end_date
           , oth_real_color
           , oth_real_DURATION
           , oth_real_task_type_id
           , l_task_priority_id
           , l_status_id
           , oth_real_tooltip
           , oth_real_resource_key
           , oth_real_NAME
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
	   , oth_real_access_hours
	   , oth_real_after_hours
	   , oth_real_customer_conf
	   , oth_real_task_depend
           , oth_real_parts_required
	   , oth_real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom
           , l_task_depend
           ;
        CLOSE c4;
      END IF;
    ELSIF  nvl(l_task_depends,'N') ='N'
    THEN

      IF g_label_on_task
      THEN

        OPEN c1;
        FETCH c1
        BULK COLLECT INTO oth_real_task_id
		   ,l_task_number
		   ,l_Task_Name
		   ,l_Task_Priority_Name
		   ,l_task_Postal_Code
		   ,l_task_City_name
		   , l_task_Site_Name
           , oth_real_start_date
           , oth_real_end_date
           , oth_real_color
           , oth_real_DURATION
           , oth_real_task_type_id
           , l_task_priority_id
           , l_status_id
           , oth_real_tooltip
           , oth_real_resource_key
           , oth_real_NAME
		   , l_task_customer_name
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
	   , oth_real_access_hours
	   , oth_real_after_hours
	   , oth_real_customer_conf
	   , oth_real_task_depend
           , oth_real_parts_required
	   , oth_real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom;
        CLOSE c1;
      ELSE

        OPEN c2;
        FETCH c2
        BULK COLLECT INTO oth_real_task_id
           , oth_real_start_date
           , oth_real_end_date
           , oth_real_color
           , oth_real_DURATION
           , oth_real_task_type_id
           , l_task_priority_id
           , l_status_id
           , oth_real_tooltip
           , oth_real_resource_key
           , oth_real_NAME
           , l_planned_start_date
           , l_planned_end_date
           , l_actual_start_date
           , l_actual_end_date
           , l_actual_effort
           , l_actual_effort_uom
           , l_planned_effort
           , l_planned_effort_uom
           , l_escalated_task
	   , oth_real_access_hours
	   , oth_real_after_hours
	   , oth_real_customer_conf
	   , oth_real_task_depend
           , oth_real_parts_required
	   , oth_real_child_task
           , l_actual_travel_duration
           , l_actual_travel_duration_uom;
        CLOSE c2;
      END IF;
    END IF;


	IF g_label_on_task
    THEN
		OPEN c_task_bar_info;
		LOOP
		FETCH c_task_bar_info into l_task_attr_list_tmp;
		EXIT WHEN c_task_bar_info%notfound;
			l_task_attr_list :=l_task_attr_list||l_task_attr_list_tmp;
		END LOOP;

	END IF;
    IF oth_real_task_id.COUNT IS NOT NULL AND oth_real_task_id.COUNT > 0
    THEN
      FOR i IN oth_real_task_id.FIRST..oth_real_task_id.LAST
      LOOP
        IF g_label_on_task
        THEN
		  oth_real_NAME(i) := ' ';
		  l_task_attr_list_tmp := l_task_attr_list;
		  LOOP
		    EXIT WHEN l_task_attr_list_tmp IS NULL OR LENGTH(l_task_attr_list_tmp) =0;

			IF SUBSTR(l_task_attr_list_tmp,1,8) ='TASK_NUM'
			THEN
			   IF l_task_number(i) IS NOT NULL
			   THEN
				 oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_task_number(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)= 'TASK_NAM'
			THEN
			   IF l_Task_Name(i) is NOT NULL
			   THEN
			   oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_Task_Name(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CUS'
			THEN
			   IF l_task_customer_name(i) IS NOT NULL
			   THEN
			     oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_task_customer_name(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CST'
			THEN
			  IF l_task_Site_Name(i) IS NOT NULL
			  THEN
				oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_task_Site_Name(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CIT'
			THEN
			  IF l_task_City_name(i) IS NOT NULL
			  THEN
				oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_task_City_name(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_POS'
			THEN
			  IF l_task_Postal_Code(i) IS NOT NULL
			  THEN
			    oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_task_Postal_Code(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_PRI'
			THEN
			  IF l_Task_Priority_Name(i) IS NOT NULL
			  THEN
				oth_real_NAME(i) :=oth_real_NAME(i)||' '||l_Task_Priority_Name(i);
			  END IF;
			END IF;
			l_task_attr_list_tmp := SUBSTR(l_task_attr_list_tmp,9);
		  END LOOP;
	    END IF;--This end if is for g_label_on_task






        IF nvl(l_task_depends,'N') ='Y'
        THEN
          IF oth_real_task_id(i) = l_task_depend(i)
          THEN
            oth_real_task_depend(i) := 'Y';
          END IF;
        END IF;
        IF l_actual_start_date(i) IS NOT NULL THEN
          oth_real_start_date(i)  := l_actual_start_date(i);
        END IF;

        IF l_actual_start_date(i) IS NOT NULL THEN
          IF l_actual_end_date(i) IS NULL THEN
            IF l_actual_effort(i) IS NULL OR l_actual_effort(i) = 0 THEN
              IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0 THEN
                l_planned_effort(i)  :=
                  csf_gantt_data_pkg.convert_to_days(l_planned_effort(i)
                    , NVL(l_planned_effort_uom(i), g_uom_hours), g_uom_hours);
              END IF;

              IF l_default_effort IS NOT NULL AND l_default_effort > 0 THEN
                l_csf_default_effort  :=
                  csf_gantt_data_pkg.convert_to_days(l_default_effort
                  , NVL(l_default_effort_uom, g_uom_hours), g_uom_hours);
              END IF;

              oth_real_end_date(i)  :=
                  (
                   l_actual_start_date(i) + NVL(l_planned_effort(i), NVL(l_csf_default_effort, 0))
                  );
            ELSE
              l_actual_effort(i)  :=
                csf_gantt_data_pkg.convert_to_days(l_actual_effort(i)
                , NVL(l_actual_effort_uom(i), g_uom_hours), g_uom_hours);
              oth_real_end_date(i)         :=(l_actual_start_date(i) + NVL(l_actual_effort(i), 0));
            END IF;
          ELSE
            IF l_actual_end_date(i) <= l_actual_start_date(i) THEN
              IF l_actual_effort(i) IS NULL OR l_actual_effort(i) = 0 THEN
                -- this is true then calculate the actual end_date based uppon the profile values.
                IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0 THEN
                  l_planned_effort(i)  :=
                    csf_gantt_data_pkg.convert_to_days(l_planned_effort(i)
                    , NVL(l_planned_effort_uom(i), g_uom_hours), g_uom_hours);
                END IF;

                IF l_default_effort IS NOT NULL AND l_default_effort > 0 THEN
                  l_csf_default_effort  :=
                    csf_gantt_data_pkg.convert_to_days(l_default_effort
                    , NVL(l_default_effort_uom, g_uom_hours), g_uom_hours);
                END IF;

                oth_real_end_date(i)  :=
                    (
                     l_actual_start_date(i) + NVL(l_planned_effort(i), NVL(l_csf_default_effort, 0))
                    );
              ELSE
                -- if not null then actual effort to the actual_end_date
                l_actual_effort(i)  :=
                  csf_gantt_data_pkg.convert_to_days(l_actual_effort(i)
                  , NVL(l_actual_effort_uom(i), g_uom_hours), g_uom_hours);
                oth_real_end_date(i)         :=(l_actual_start_date(i) + NVL(l_actual_effort(i), 0));
              END IF;   --end if for actual effort is nul or zero
            ELSE
              -- actual end date is not null, check if actual_end_date > actual_start_date
              IF l_actual_end_date(i) > l_actual_start_date(i) THEN
               oth_real_end_date(i)  := l_actual_end_date(i);
              END IF;   -- end if
            END IF;
            --end if for r_sch_end_date.actual_end_date = r_sch_end_date.actual_start_date
          END IF;   -- end if for actual_end_date is null
          IF l_actual_travel_duration IS NOT NULL
          THEN
            IF l_actual_travel_duration_uom IS NOT NULL
            THEN
              oth_real_DURATION(i):=convert_to_min(l_actual_travel_duration(i),l_actual_travel_duration_uom(i),g_uom_minutes);
            END IF;
          ELSE
            oth_real_DURATION(i):=0;
          END IF;
        ELSE   --else for actual_start_date is null
          IF oth_real_start_date(i) IS NOT NULL THEN
            -- scheduled_start_date is not null then check if scheduled_end_date is null
            IF oth_real_end_date(i) IS NOT NULL THEN
              -- scheduled_start_date is not null then check if scheduled_start_date=scheduled_end_date
              IF oth_real_start_date(i) = oth_real_end_date(i) THEN
                IF (l_planned_effort(i) IS NULL) OR(l_planned_effort(i) = 0) THEN
                  IF l_default_effort IS NOT NULL AND l_default_effort > 0 THEN
                    l_csf_default_effort  :=
                      csf_gantt_data_pkg.convert_to_days(l_default_effort
                      , NVL(l_default_effort_uom, g_uom_hours), g_uom_hours);
                  END IF;

                  oth_real_end_date(i)  :=(oth_real_start_date(i) + NVL(l_csf_default_effort, 0));
                ELSE
                  IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0 THEN
                    l_planned_effort(i)  :=
                      csf_gantt_data_pkg.convert_to_days(l_planned_effort(i)
                      , NVL(l_planned_effort_uom(i), g_uom_hours), g_uom_hours);
                  END IF;

                  oth_real_end_date(i)  :=(oth_real_start_date(i) + NVL(l_planned_effort(i), 0));
                END IF;
              END IF;
            ELSE
              -- scheduled_end_date is null then check for planned effort null
              IF (l_planned_effort(i) IS NULL) OR(l_planned_effort(i) = 0) THEN
                IF l_default_effort IS NOT NULL AND l_default_effort > 0 THEN
                  l_csf_default_effort  :=
                    csf_gantt_data_pkg.convert_to_days(l_default_effort
                    , NVL(l_default_effort_uom, g_uom_hours), g_uom_hours);
                END IF;

                oth_real_end_date(i)  :=(oth_real_start_date(i) + NVL(l_csf_default_effort, 0));
              ELSE
                -- declar variable l_planned_effort to get uom coverted into days for actual effort for
                IF l_planned_effort(i) IS NOT NULL AND l_planned_effort(i) > 0 THEN
                  l_planned_effort(i)  :=
                    csf_gantt_data_pkg.convert_to_days(l_planned_effort(i)
                    , NVL(l_planned_effort_uom(i), g_uom_hours), g_uom_hours);
                END IF;

                oth_real_end_date(i)  :=(oth_real_start_date(i) + NVL(l_planned_effort(i), 0));
              END IF;
            END IF;   -- end if for scheduled_end_date is null
          END IF;   -- end if for scheduled_start_date is not null
        END IF;   -- end if for actual_start_date is not null
        ------------------------------------------
        --end for scheduled end dates
        ------------------------------------------
        IF g_use_custom_chromatics
        THEN
          l_task_custom_color  := 'N';
          IF l_rule_id IS NOT NULL
          THEN
            IF l_actual_start_date(i) IS NOT NULL
            THEN
              IF l_actual_end_date(i) IS NOT NULL
    	      THEN
                IF l_actual_end_date(i) = l_actual_start_date(i)
                THEN
	          l_task_custom_color  := 'Y';
                END IF;   --end if for actual_end_date=actual_start_date
              ELSE
                IF NVL(l_actual_effort(i), 0) = 0
                THEN
                  IF NVL(l_planned_effort(i), 0) = 0
	          THEN
                    l_task_custom_color  := 'Y';
                  END IF;
                END IF;
              END IF;   --end if for actual_end_date is not null
            ELSE   --for actual start date is null
              IF oth_real_end_date(i) IS NOT NULL
              THEN
                IF oth_real_end_date(i) = oth_real_start_date(i)
   	        THEN
                  l_task_custom_color  := 'Y';
                END IF;
              ELSE
                l_task_custom_color  := 'Y';
              END IF;   --end if scheduled end_date is not null
            END IF;   --end if for actual_start_date is not null
          END IF;   --rule id condition for task date usage
          IF l_task_custom_color = 'Y'
          THEN
            IF l_rule_id IS NOT NULL
            THEN
              IF NVL(p_rule_id, 1) <> l_rule_id
              THEN
                OPEN get_tdu_color(l_rule_id);
    	        FETCH get_tdu_color
	          INTO p_color;
    	        IF get_tdu_color%NOTFOUND
                THEN
                  CLOSE get_tdu_color;
	          IF(NVL(p_cur_task_type_id, -1) <> oth_real_task_type_id(i)
                  OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
                  OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
                  OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i))
      	          THEN
      	            real_color(i):=do_match(oth_real_task_type_id(i),l_task_priority_id(i),l_status_id(i),l_escalated_task(i));
                    p_cur_color             := oth_real_color(i);
                    p_cur_task_type_id      := oth_real_task_type_id(i);
                    p_cur_task_priority_id  := l_task_priority_id(i);
                    p_cur_task_status_id    := l_status_id(i);
                    p_cur_escalated_task    := l_escalated_task(i);
                  ELSE
                    oth_real_color(i)  := p_cur_color;
                  END IF;
                ELSE
                  oth_real_color(i)  := p_color;
                  CLOSE get_tdu_color;
                END IF;
              ELSE
                oth_real_color(i)  := p_color;
              END IF;
            ELSE
      	      IF(NVL(p_cur_task_type_id, -1) <> oth_real_task_type_id(i)
       	      OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
    	      OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
     	      OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
    	        )
    	      THEN
                oth_real_color(i):=do_match(oth_real_task_type_id(i), l_task_priority_id(i), l_status_id(i),l_escalated_task(i));
    	        p_cur_color             := oth_real_color(i);
    	        p_cur_task_type_id      := oth_real_task_type_id(i);
                p_cur_task_priority_id  := l_task_priority_id(i);
                p_cur_task_status_id    := l_status_id(i);
    	        p_cur_escalated_task    := l_escalated_task(i);
              ELSE
                oth_real_color(i)  := p_cur_color;
    	      END IF;
            END IF;
          ELSE
            IF (NVL(p_cur_task_type_id, -1) <> oth_real_task_type_id(i)
            OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
            OR NVL(p_cur_task_status_id, -1) <> l_status_id(i)
            OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
               )
            THEN
              oth_real_color(i):=do_match(oth_real_task_type_id(i), l_task_priority_id(i), l_status_id(i), l_escalated_task(i));
              p_cur_color             := oth_real_color(i);
    	      p_cur_task_type_id      := oth_real_task_type_id(i);
              p_cur_task_priority_id  := l_task_priority_id(i);
    	      p_cur_task_status_id    := l_status_id(i);
              p_cur_escalated_task    := l_escalated_task(i);
    	    ELSE
              oth_real_color(i)  := p_cur_color;
            END IF;
          END IF;
        ELSE
          IF l_escalated_task(i) = 'Y'
          THEN
            oth_real_color(i)  := red;
          ELSIF l_actual_start_date(i) IS NOT NULL
          THEN
            oth_real_color(i)  := yellow;
          ELSE
            oth_real_color(i)  := blue;
          END IF;
        END IF;

        if g_tz_enabled ='Y' and sch_adv_tz='CTZ'
        then
          oth_real_start_date(i) :=fnd_date.adjust_datetime(oth_real_start_date(i),g_client_tz,g_server_tz );
          oth_real_end_date(i)   :=fnd_date.adjust_datetime(oth_real_end_date(i)  ,g_client_tz,g_server_tz);
        elsif g_tz_enabled ='Y' and sch_adv_tz='ITZ'
        then
          oth_real_start_date(i) :=fnd_date.adjust_datetime(oth_real_start_date(i),g_client_tz,inc_tz_code );
          oth_real_end_date(i)   :=fnd_date.adjust_datetime(oth_real_end_date(i)  ,g_client_tz,inc_tz_code);
        end if;
      END LOOP;
    END IF;

    IF  l_task_depends ='Y'
    THEN
      IF g_label_on_task
      THEN

        OPEN c_real_task_3;
        FETCH c_real_task_3
        BULK COLLECT INTO
	         real_task_key
	       , real_resource_key
	       , real_start_date
	       , real_end_date
		   ,l_task_number
		   ,l_Task_Name
		   ,l_Task_Priority_Name
		   ,l_task_Postal_Code
		   ,l_task_City_name
		   ,l_task_Site_Name
	       , real_color
	       , real_tooltip
	       , real_duration
	       , real_task_type_id
	       , l_task_priority_id
	       , l_assignment_status_id
	       , l_actual_start_date
	       , l_actual_end_date
	       , real_name
		   ,l_task_customer_name
	       , l_escalated_task
	       , real_access_hours
	       , real_after_hours
	       , real_customer_conf
	       , real_task_depend
	       , real_parts_required
	       , child_task
           , l_task_depend;
        CLOSE c_real_task_3;
      ELSE
        OPEN c_real_task_4;
        FETCH c_real_task_4
        BULK COLLECT INTO
	         real_task_key
	       , real_resource_key
	       , real_start_date
	       , real_end_date
	       , real_color
	       , real_tooltip
	       , real_duration
	       , real_task_type_id
	       , l_task_priority_id
	       , l_assignment_status_id
	       , l_actual_start_date
	       , l_actual_end_date
	       , real_name
		   , l_escalated_task
	       , real_access_hours
	       , real_after_hours
	       , real_customer_conf
	       , real_task_depend
	       , real_parts_required
	       , child_task
           , l_task_depend;
        CLOSE c_real_task_4;
      END IF;
    ELSIF  nvl(l_task_depends,'N') ='N'
    THEN
      IF g_label_on_task
      THEN

        OPEN c_real_task_1;
        FETCH c_real_task_1
        BULK COLLECT INTO
             real_task_key
	       , real_resource_key
	       , real_start_date
	       , real_end_date
		   , l_task_number
		   , l_Task_Name
		   , l_Task_Priority_Name
		   , l_task_Postal_Code
		   , l_task_City_name
		   , l_task_Site_Name
	       , real_color
	       , real_tooltip
	       , real_duration
	       , real_task_type_id
	       , l_task_priority_id
	       , l_assignment_status_id
	       , l_actual_start_date
	       , l_actual_end_date
	       , real_name
		   ,l_task_customer_name
	       , l_escalated_task
	       , real_access_hours
	       , real_after_hours
	       , real_customer_conf
	       , real_task_depend
	       , real_parts_required
	       , child_task;
        CLOSE c_real_task_1;
      ELSE
        OPEN c_real_task_2;
        FETCH c_real_task_2
        BULK COLLECT INTO
                 real_task_key
	       , real_resource_key
	       , real_start_date
	       , real_end_date
	       , real_color
	       , real_tooltip
	       , real_duration
	       , real_task_type_id
	       , l_task_priority_id
	       , l_assignment_status_id
	       , l_actual_start_date
	       , l_actual_end_date
	       , real_name
	       , l_escalated_task
	       , real_access_hours
	       , real_after_hours
	       , real_customer_conf
	       , real_task_depend
	       , real_parts_required
	       , child_task;
        CLOSE c_real_task_2;
      END IF;
    END IF;

    IF real_task_key.COUNT IS NOT NULL AND real_task_key.COUNT > 0
    THEN
      FOR i IN real_task_key.first..real_task_key.last
      LOOP
		IF g_label_on_task
        THEN

		  real_name(i) := ' ';
		  l_task_attr_list_tmp := l_task_attr_list;
		  LOOP
		    EXIT WHEN l_task_attr_list_tmp IS NULL OR LENGTH(l_task_attr_list_tmp) =0;

			IF SUBSTR(l_task_attr_list_tmp,1,8) ='TASK_NUM'
			THEN
			   IF l_task_number(i) IS NOT NULL
			   THEN
				 real_name(i) :=real_name(i)||' '||l_task_number(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)= 'TASK_NAM'
			THEN
			   IF l_Task_Name(i) is NOT NULL
			   THEN
			   real_name(i) :=real_name(i)||' '||l_Task_Name(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CUS'
			THEN
			   IF l_task_customer_name(i) IS NOT NULL
			   THEN
			     real_name(i) :=real_name(i)||' '||l_task_customer_name(i);
			   END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CST'
			THEN
			  IF l_task_Site_Name(i) IS NOT NULL
			  THEN
				real_name(i) :=real_name(i)||' '||l_task_Site_Name(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_CIT'
			THEN
			  IF l_task_City_name(i) IS NOT NULL
			  THEN
				real_name(i) :=real_name(i)||' '||l_task_City_name(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_POS'
			THEN
			  IF l_task_Postal_Code(i) IS NOT NULL
			  THEN
			    real_name(i) :=real_name(i)||' '||l_task_Postal_Code(i);
			  END IF;
			ELSIF SUBSTR(l_task_attr_list_tmp,1,8)='TASK_PRI'
			THEN
			  IF l_Task_Priority_Name(i) IS NOT NULL
			  THEN
				real_name(i) :=real_name(i)||' '||l_Task_Priority_Name(i);
			  END IF;
			END IF;
			l_task_attr_list_tmp := SUBSTR(l_task_attr_list_tmp,9);
		  END LOOP;
	    END IF;--This end if is for g_label_on_task

        IF g_tz_enabled ='Y' AND sch_adv_tz='CTZ'
        THEN
          real_start_date(i) :=fnd_date.adjust_datetime(real_start_date(i),g_client_tz,g_server_tz );
        ELSIF g_tz_enabled ='Y' AND sch_adv_tz='ITZ'
        THEN
          real_start_date(i) :=fnd_date.adjust_datetime(real_start_date(i),g_client_tz,inc_tz_code );
        END IF;
        IF g_tz_enabled ='Y' AND sch_adv_tz='CTZ'
        THEN
          real_end_date(i)    :=fnd_date.adjust_datetime(real_end_date(i),g_client_tz,g_server_tz);
        ELSIF g_tz_enabled ='Y' AND sch_adv_tz='ITZ'
        THEN
          real_end_date(i)    :=fnd_date.adjust_datetime(real_end_date(i),g_client_tz,inc_tz_code);
        END IF;

        IF nvl(l_task_depends,'N') ='Y'
        THEN
          IF real_task_key(i) = l_task_depend(i)
          THEN
            real_task_depend(i) := 'Y';
          END IF;
        END IF;

        IF g_use_custom_chromatics
        THEN
          l_task_custom_color  := 'N';
          IF l_rule_id IS NOT NULL
          THEN
            IF real_end_date(i) IS NOT NULL
  	    THEN
              IF real_end_date(i) = real_start_date(i)
   	      THEN
                l_task_custom_color  := 'Y';
              END IF;
            ELSE
              l_task_custom_color  := 'Y';
            END IF;   --end if for scheduled_start_date is not null
          END IF;   --rule id condition for task date usage

	  IF l_task_custom_color = 'Y'
          THEN
            IF l_rule_id IS NOT NULL
            THEN
	      IF NVL(p_rule_id, 1) <> l_rule_id
              THEN
                OPEN get_tdu_color(l_rule_id);
	        FETCH get_tdu_color
	        INTO p_color;
                IF get_tdu_color%NOTFOUND
	        THEN
                  CLOSE get_tdu_color;
                  IF(NVL(p_cur_task_type_id, -1) <> real_task_type_id(i)
                  OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
                  OR NVL(p_cur_task_status_id, -1) <> l_assignment_status_id(i)
                  OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
                     )
  	          THEN
                    real_color(i):=do_match(real_task_type_id(i),l_task_priority_id(i),l_assignment_status_id(i),l_escalated_task(i));
                    p_cur_color             := real_color(i);
                    p_cur_task_type_id      := real_task_type_id(i);
                    p_cur_task_priority_id  := l_task_priority_id(i);
                    p_cur_task_status_id    := l_assignment_status_id(i);
                    p_cur_escalated_task    := l_escalated_task(i);
                  ELSE
                    real_color(i)  := p_cur_color;
                  END IF;
                ELSE
                  real_color(i)  := p_color;
                  CLOSE get_tdu_color;
                END IF;
              ELSE
                real_color(i)  := p_color;
              END IF;
            ELSE
              IF(NVL(p_cur_task_type_id, -1) <> real_task_type_id(i)
              OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
              OR NVL(p_cur_task_status_id, -1) <> l_assignment_status_id(i)
 	      OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
                )
	      THEN
                real_color(i):=do_match(real_task_type_id(i), l_task_priority_id(i), l_assignment_status_id(i),l_escalated_task(i));
                p_cur_color             := real_color(i);
	        p_cur_task_type_id      := real_task_type_id(i);
                p_cur_task_priority_id  := l_task_priority_id(i);
                p_cur_task_status_id    := l_assignment_status_id(i);
	        p_cur_escalated_task    := l_escalated_task(i);
	      ELSE
                real_color(i)  := p_cur_color;
              END IF;
            END IF;
          ELSE
            IF (NVL(p_cur_task_type_id, -1) <> real_task_type_id(i)
            OR NVL(p_cur_task_priority_id, -1) <> l_task_priority_id(i)
            OR NVL(p_cur_task_status_id, -1) <> l_assignment_status_id(i)
            OR NVL(p_cur_escalated_task, 'G') <> l_escalated_task(i)
              )
            THEN
              real_color(i):=do_match(real_task_type_id(i), l_task_priority_id(i), l_assignment_status_id(i), l_escalated_task(i));
	      p_cur_color             := real_color(i);
              p_cur_task_type_id      := real_task_type_id(i);
	      p_cur_task_priority_id  := l_task_priority_id(i);
              p_cur_task_status_id    := l_assignment_status_id(i);
	      p_cur_escalated_task    := l_escalated_task(i);
            ELSE
              real_color(i)  := p_cur_color;
            END IF;
          END IF;
        ELSE
          IF l_escalated_task(i) = 'Y'
          THEN
            real_color(i)  := red;
          ELSIF l_actual_start_date(i) IS NOT NULL
          THEN
            real_color(i)  := yellow;
          ELSE
            real_color(i)  := blue;
          END IF;
        END IF;
      END LOOP;
    END IF;

    IF trip_id.COUNT IS NULL THEN
      l_return_status  := 'E';
    ELSE
      x_return_status  := fnd_api.g_ret_sts_success;
    END IF;
   END get_schedule_advise_options;


   PROCEDURE insert_rows
  ( p_setup_type		IN	varchar2
  , p_tooltip_setup_tbl IN	tooltip_setup_tbl
  , p_delete_rows	IN	boolean
  , p_user_id		IN	number
  , p_login_id     IN   number
  )
  IS
  BEGIN
    if p_delete_rows then
       delete_rows(p_user_id);
    end if;

    for i in p_tooltip_setup_tbl.first..p_tooltip_setup_tbl.last
    loop
       insert into csf_gantt_chart_setup
        (created_by,creation_date,last_updated_by, last_update_date, last_update_login, user_id, setup_type, seq_no, field_name, field_value)
         values (p_user_id, sysdate, p_user_id,sysdate,p_login_id, p_user_id,p_setup_type,p_tooltip_setup_tbl(i).seq_no,p_tooltip_setup_tbl(i).field_name,p_tooltip_setup_tbl(i).field_value);
    end loop;

  END INSERT_ROWS;

  PROCEDURE DELETE_ROWS(p_user_id number)
  is
  begin
    delete from csf_gantt_chart_setup where user_id = p_user_id;
  END DELETE_ROWS;



BEGIN
  -- package instantiation
  set_tooltip_labels;
  g_use_custom_chromatics  := fnd_profile.VALUE('CSF_USE_CUSTOM_CHROMATICS') = 'Y';

  IF g_use_custom_chromatics THEN
    g_get_custom_color;
  END IF;
  g_user_id                := fnd_global.user_id;
  g_uom_minutes           := fnd_profile.value_specific('CSF_UOM_MINUTES', g_user_id);
  g_uom_hours             := fnd_profile.value_specific('CSF_UOM_HOURS', g_user_id);
  g_date_format            := fnd_profile.value_specific('ICX_DATE_FORMAT_MASK');
  l_language               := USERENV('LANG');
  g_resource_id            :=csf_resource_pub.resource_id;
  g_resource_type          :=csf_resource_pub.resource_type;
  g_server_tz := fnd_timezones.get_server_timezone_code;
  g_client_tz := fnd_timezones.get_client_timezone_code;
  g_tz_enabled := 'N';

    -- this function is currently not present in fnd_timezones 1158
    -- copied from AFTZONEB.pls 115.3 and modified
    if  nvl(fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS'),'N') = 'Y'
    then
      g_tz_enabled := 'Y';
   end if;

END CSF_GANTT_DATA_PKG;

/
