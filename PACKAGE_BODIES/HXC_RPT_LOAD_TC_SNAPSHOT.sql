--------------------------------------------------------
--  DDL for Package Body HXC_RPT_LOAD_TC_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RPT_LOAD_TC_SNAPSHOT" AS
/* $Header: hxcrpttcsnpsht.pkb 120.12.12010000.7 2010/02/17 15:27:14 asrajago ship $ */

  g_res_list_cs     VARCHARTABLE;
  g_request_id      VARCHAR2(30);
  g_debug           BOOLEAN := hr_utility.debug_enabled;


  newline           VARCHAR2(1) :=
'
';

-- RESOURCE_WHERE_CLAUSE
-- Creates the dynamic query which filters out all the active assignments
-- available in the given date range.  The pulled out active assignments
-- are stored in a data structure and used later to filter out timecards.

PROCEDURE resource_where_clause (   p_date_from       IN DATE
			         ,  p_date_to         IN DATE
				 ,  p_org_id          IN NUMBER DEFAULT NULL
				 ,  p_locn_id         IN NUMBER DEFAULT NULL
				 ,  p_payroll_id      IN NUMBER DEFAULT NULL
				 ,  p_supervisor_id   IN NUMBER DEFAULT NULL
				 ,  p_person_id       IN NUMBER DEFAULT NULL
                                   )
AS

  l_base_query VARCHAR2(6000)
      := 'SELECT person_id
            FROM per_all_assignments_f
           WHERE assignment_status_type_id IN ( SELECT assignment_status_type_id
                                                  FROM per_assignment_status_types
                                                 WHERE user_status IN ( ''Active Assignment''
                                                                        ,''Active Contingent Assignment'') )
             AND assignment_type IN (''E'',''C'')
             AND business_group_id = FND_GLOBAL.per_business_group_id
             AND (     effective_start_date BETWEEN ''p_date_from''
                                                AND ''p_date_to''
                    OR effective_end_date BETWEEN ''p_date_from''
                                              AND ''p_date_to''
	            OR ''p_date_from'' BETWEEN effective_start_date
                                           AND effective_end_date
	            OR ''p_date_to''  BETWEEN effective_Start_date
                                          AND effective_end_date )';


  l_resource_list        NUMTABLE;
  l_res_list_cs_buff     VARCHAR2(400);
  l_rlc_cnt              PLS_INTEGER := 0;
  l_resource_cur         SYS_REFCURSOR;


BEGIN

    -- Public Procedure resource_where_clause
    -- Takes in all the data filter parameters specified while the request
    --     was submitted.
    -- Browses thru all the parameters passed and checks if they are not
    --     NULL. If not NULL, a relevant AND clause is attached to the
    --     dynamic sql string.
    -- Execute the dynamic sql and pull out the active resources, 20 at a
    --     time.
    -- Store these results in a plsql table of VARCHAR2 type, each element
    --     having a comma separated list of 20 person_ids.

    IF g_debug
    THEN
       hr_utility.trace('Resource_where_clause');
       hr_utility.trace('Parameters');
       hr_utility.trace('==========');
       hr_utility.trace('p_date_from     '||p_date_from);
       hr_utility.trace('p_date_to       '||p_date_to);
       hr_utility.trace('p_org_id        '||p_org_id);
       hr_utility.trace('p_locn_id       '||p_locn_id);
       hr_utility.trace('p_payroll_id    '||p_payroll_id);
       hr_utility.trace('p_supervisor_id '||p_supervisor_id);
       hr_utility.trace('p_person_id     '||p_person_id);
    END IF;

    l_base_query := REPLACE(l_base_query,'p_date_from',TO_CHAR(p_date_from));
    l_base_query := REPLACE(l_base_query,'p_date_to',TO_CHAR(p_date_to));

    IF p_org_id IS NOT NULL
    THEN
        l_base_query := l_base_query||'
              AND organization_id = '||p_org_id;
    END IF;
    IF p_payroll_id IS NOT NULL
    THEN
        l_base_query := l_base_query||'
              AND payroll_id = '||p_payroll_id;
    END IF;
    IF p_supervisor_id IS NOT NULL
    THEN
        l_base_query := l_base_query||'
              AND supervisor_id = '||p_supervisor_id;
    END IF;
    IF p_locn_id IS NOT NULL
    THEN
        l_base_query := l_base_query||'
              AND location_id = '||p_locn_id;
    END IF;
    IF p_person_id IS NOT NULL
    THEN
        l_base_query := l_base_query||'
              AND person_id = '||p_person_id;
    END IF;


    IF g_debug
    THEN
       hr_utility.trace('Dynamic query to be executed is ');
       hr_utility.trace(l_base_query);
    END IF;

    g_res_list_cs      := VARCHARTABLE(' ');
    l_rlc_cnt          := g_res_list_cs.FIRST;
    l_res_list_cs_buff := ' ';

    OPEN l_resource_cur FOR l_base_query;
    LOOP
        FETCH l_resource_cur
         BULK COLLECT
         INTO l_resource_list LIMIT 20;
        EXIT WHEN l_resource_list.COUNT=0;
        FOR j IN l_resource_list.FIRST..l_resource_list.LAST
        LOOP
            l_res_list_cs_buff := l_res_list_cs_buff||', '||l_resource_list(j);
        END LOOP;
        g_res_list_cs(l_rlc_cnt) := l_res_list_cs_buff;
        IF g_debug
        THEN
           hr_utility.trace('Resource List No.'||l_rlc_cnt);
           hr_utility.trace('---> '||g_res_list_cs(l_rlc_cnt));
        END IF;

        l_resource_list.DELETE;
        l_rlc_cnt          := l_rlc_cnt + 1;
        l_res_list_cs_buff := ' ';

        g_res_list_cs.EXTEND(1);

    END LOOP;
    CLOSE l_resource_cur;

    IF g_debug
    THEN
       hr_utility.trace('resource_where_clause completed alright');
    END IF;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          hr_utility.trace('No Active Resources For the given criteria ');

END resource_where_clause;



-- LOAD_TC_LEVEL_INFO
-- Loads the timecard level information into HXC_RPT_TC_RESOURCE_TEMP
-- for all the relevant employees whose person ids are provided as parameter.

PROCEDURE load_tc_level_info( p_resource_list     IN VARCHAR2,
                              p_tc_from           IN DATE,
                              p_tc_to             IN DATE,
                              p_request_id        IN VARCHAR2 DEFAULT NULL)
AS

  l_tc_query  VARCHAR2(2000) :=
          ' INSERT INTO hxc_rpt_tc_resource_temp
                        ( resource_id,
                          tc_start_time,
                          tc_stop_time,
                          tc_bb_id,
                          resource_name,
                          request_id )
                  SELECT  resource_id,
                          start_time,
                          stop_time,
                          time_building_block_id,
                          MIN(full_name||'' [''||COALESCE(DECODE(current_employee_flag,''Y'',employee_number),
						          DECODE(current_npw_flag,''Y'',npw_number),
						          '' ''
						         )||'']''),
                          ''p_request_id''
                    FROM  hxc_time_building_blocks hxc,
                          per_all_people_f ppf
                   WHERE  scope       = ''TIMECARD''
                     AND  person_id = resource_id
                     AND  start_time >= effective_start_date
                     AND  stop_time  <= effective_end_date
                     AND  start_time >= ''p_date_from''
                     AND  TRUNC(stop_time)  <= ''p_date_to''
                     AND  resource_id IN ( ';

BEGIN


    -- Public Procedure load_tc_level_info
    -- Takes in a comma separated list of resource ids, the timecard start date,
    --     stop_date and request id.
    -- Attaches the parameters to the timecard query defined above, in the date
    --     and the resource_id AND clauses.
    -- Execute the query, which selects from HXC_TIME_BUILDING_BLOCKS and PER_ALL
    --     _PEOPLE_F and inserts into HXC_RPT_TC_RESOURCE_TEMP


    IF g_debug
    THEN
       hr_utility.trace('load_tc_level_info');
       hr_utility.trace('Parameters ');
       hr_utility.trace('===========');
       hr_utility.trace('p_resource_list  :'||p_resource_list);
       hr_utility.trace('p_tc_from        :'||p_tc_from);
       hr_utility.trace('p_tc_to          :'||p_tc_to);
       hr_utility.trace('p_request_id     :'||p_request_id);
    END IF;



    l_tc_query := REPLACE(l_tc_query,'p_date_from',TO_CHAR(p_tc_from));
    l_tc_query := REPLACE(l_tc_query,'p_date_to',TO_CHAR(p_tc_to));
    l_tc_query := REPLACE(l_tc_query,'p_request_id',TO_CHAR(p_request_id));


    l_tc_query := l_tc_query||p_resource_list||')';
    l_tc_query :=
           l_tc_query||'
                 GROUP
                    BY  resource_id,
                        start_time,
                        stop_time,
                        time_building_block_id ';

    IF g_debug
    THEN
       hr_utility.trace('Timecard select query is ');
       hr_utility.trace(l_tc_query);
    END IF;
    EXECUTE IMMEDIATE l_tc_query;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
          hr_utility.trace('No Timecards found for resource list '||p_resource_list);

END load_tc_level_info;





-- CLEAR_HISTORY_DATA
-- If chosen to regenerate all data and clear history data, deletes all information
-- already collected from HXC_RPT_TC_HIST_LOG and HXC_RPT_TC_DETAILS_ALL.

PROCEDURE clear_history_data
AS

BEGIN

     -- Public Procedure clear_history_data
     -- Delete from HXC_RPT_TC_HIST_LOG
     -- Delete from HXC_RPT_TC_DETAILS_ALL
     -- Commit the changes.

     IF g_debug
     THEN
        hr_utility.trace('Started clear_history_data');
     END IF;

     DELETE FROM hxc_rpt_tc_hist_log;

     DELETE FROM hxc_rpt_tc_details_all;

     COMMIT;

     IF g_debug
     THEN
        hr_utility.trace('clear_history_data completed alright');
     END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          NULL;

END clear_history_data;



-- FETCH_HISTORY_FROM_DATE
-- If chosen to use previously loaded data, this procedure determines from what
-- date new changes would have come, or in other words, finds out last date till
-- changes where recorded, so that this time history has to be fetched from that
-- last recorded date.

PROCEDURE fetch_history_from_date
AS

  resource_id_tab NUMTABLE;
  start_time_tab  DATETABLE;
  stop_time_tab   DATETABLE;
  history_tab     DATETABLE;

  CURSOR get_history_date
      IS SELECT /*+ LEADING(gt)
                    USE_NL(gt hist)
		    INDEX(hist HXC_RPT_TC_HIST_LOG_PK) */
                hist.resource_id,
                hist.tc_start_time,
                hist.tc_stop_time,
                hist.history_till_date
           FROM hxc_rpt_tc_hist_log hist,
                hxc_rpt_tc_resource_temp gt
          WHERE gt.resource_id   = hist.resource_id
            AND gt.tc_start_time = hist.tc_start_time
            AND gt.tc_stop_time  = hist.tc_stop_time ;

BEGIN

     -- Public Procedure fetch_history_from_date
     -- Look into HXC_RPT_TC_HIST_LOG to find out upto which details are
     --      captured into HXC_RPT_TC_DETAILS_ALL for all the
     --      resource_id-tc_start_time-tc_stop_time combinations loaded
     --      right now into HXC_RPT_TC_RESOURCE_TEMP.
     -- Update these values as history_from_date in HXC_RPT_TC_RESOURCE_TEMP
     --      for corresponding resource_id-tc_start_time-tc_stop_time
     --      combinations.
     -- For those combinations which there is no record in HXC_RPT_TC_HIST_LOG
     --      update history_from_date as hr_general.start_of_time


     IF g_debug
     THEN
        hr_utility.trace('Started fetch_history_from_date ');
     END IF;

     OPEN get_history_date;
     FETCH get_history_date
      BULK COLLECT INTO resource_id_tab,
                        start_time_tab,
                        stop_time_tab,
                        history_tab;
     CLOSE get_history_date;

     IF g_debug
     THEN
        hr_utility.trace('Fetched values for get_history_date ');
        hr_utility.trace('Total number of rows fetched :'||resource_id_tab.COUNT);
     END IF;

     IF resource_id_tab.COUNT > 0
     THEN
        FORALL i IN resource_id_tab.FIRST..resource_id_tab.LAST
             UPDATE hxc_rpt_tc_resource_temp
                SET history_from_date = history_tab(i)
              WHERE resource_id   = resource_id_tab(i)
                AND tc_start_time = start_time_tab(i)
                AND tc_stop_time  = stop_time_tab(i);
     END IF;

     history_tab.DELETE;
     resource_id_tab.DELETE;
     start_time_tab.DELETE;
     stop_time_tab.DELETE;

     UPDATE hxc_rpt_tc_resource_temp
        SET history_from_date = hr_general.start_of_time
      WHERE history_from_date IS NULL ;

     IF g_debug
     THEN
        hr_utility.trace('fetch_history_from_date completed alright');
     END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         NULL;

END fetch_history_from_date;



-- UPDATE_LAYOUT_IDS
-- Updates the timecard records captured in HXC_RPT_TC_RESOURCE_TEMP with
-- their layout_ids from HXC_TIME_ATTRIBUTES table.

PROCEDURE update_layout_ids
AS

  CURSOR get_layout_ids
      IS SELECT /*+ LEADING(gt)
                    INDEX(hau HXC_TIME_ATTRIBUTE_USAGES_FK2)
		    INDEX(ha HXC_TIME_ATTRIBUTES_PK) */
                gt.tc_bb_id,
                ha.attribute1
           FROM hxc_rpt_tc_resource_temp    gt,
                hxc_time_attribute_usages hau,
                hxc_time_attributes       ha
          WHERE gt.tc_bb_id = hau.time_building_block_id
            AND hau.time_building_block_ovn = 1
            AND hau.time_attribute_id = ha.time_attribute_id
            AND ha.attribute_category = 'LAYOUT';

  l_tbb_tab       NUMTABLE ;
  l_layout_id_tab NUMTABLE ;

BEGIN

     -- Public Procedure update_layout_ids
     -- Join HXC_RPT_TC_RESOURCE_TEMP, HXC_TIME_ATTRIBUTE_USAGES, and
     --      HXC_TIME_ATTRIBUTES to pick out Attribute1 from
     --      LAYOUT Attribute_categroy. -- This is the layout_id.
     -- Update HXC_RPT_TC_RESOURCE_TEMP with the corresponding layout_id
     --      for each of the timecard records.

      IF g_debug
      THEN
         hr_utility.trace('Starting update_layout_ids');
      END IF;

      OPEN get_layout_ids;
      LOOP
         FETCH get_layout_ids
          BULK COLLECT
          INTO l_tbb_tab,
               l_layout_id_tab LIMIT 1000;
         EXIT WHEN l_layout_id_tab.COUNT = 0;

         IF g_debug
         THEN
            hr_utility.trace('Fetched from get_layout_ids');
            hr_utility.trace('Number of rows fetched '||l_layout_id_tab.COUNT);
         END IF;

         IF l_layout_id_tab.COUNT > 0
         THEN
             FORALL i IN l_layout_id_tab.FIRST..l_layout_id_tab.LAST
                UPDATE hxc_rpt_tc_resource_temp
                   SET layout_id = l_layout_id_tab(i)
                 WHERE tc_bb_id  = l_tbb_tab(i) ;
         END IF;
         l_layout_id_tab.DELETE;
         l_tbb_tab.DELETE;

      END LOOP;
      CLOSE get_layout_ids;

      IF g_debug
      THEN
         hr_utility.trace('update_layout_ids completed alright');
      END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No layout ids found for the timecards, something wrong ');

END update_layout_ids;


-- UPDATE_LAST_TOUCHED_DATE
-- For those records which are already recorded in the past and are being
-- reused, update the last touched date, last updated date and last updated
-- user.


PROCEDURE update_last_touched_date
AS

  CURSOR get_last_touched_date
      IS SELECT /*+ ORDERED
                    INDEX(det HXC_RPT_TC_DETAILS_FK2)
		    INDEX(bb HXC_TIME_BUILDING_BLOCKS_PK) */
                bb.time_building_block_id,
                bb.object_version_number,
	        bb.date_to,
	        bb.last_update_date,
                bb.last_updated_by
           FROM hxc_time_building_blocks bb,
                hxc_rpt_tc_details_all det,
	        hxc_rpt_tc_resource_temp gt
          WHERE bb.scope                  = 'DETAIL'
            AND bb.time_building_block_id = det.detail_bb_id
            AND bb.object_version_number  = det.detail_bb_ovn
            AND det.tc_bb_id              = gt.tc_bb_id
            AND det.date_to               <> bb.date_to ;

  bb_id_tab        NUMTABLE;
  bb_ovn_tab       NUMTABLE;
  date_to_tab      DATETABLE;
  update_date_tab  DATETABLE;
  update_user_tab  NUMTABLE;


BEGIN

      -- Public Procedure update_last_touched_date
      -- Used for those detail records that are already collected in
      --      HXC_RPT_TC_DETAILS_ALL table.
      -- For those records in HXC_RPT_TC_DETAILS_ALL which belong to
      --      the timecard records in HXC_RPT_TC_RESOURCE_TEMP, get the
      --      last_updated_date, last_updated_by, and date_to values
      --      from HXC_TIME_BUILDING_BLOCKS table, if the date_to column
      --      is different.
      -- Update all such records with the last_updated_date, last_updated_by
      --      and date_to columns in HXC_RPT_TC_DETAILS_ALL


      IF g_debug
      THEN
         hr_utility.trace('Starting update_last_touched_date');
      END IF;

      OPEN get_last_touched_date;

      FETCH get_last_touched_date
       BULK COLLECT INTO bb_id_tab,
                         bb_ovn_tab,
                         date_to_tab,
                         update_date_tab,
                         update_user_tab;

      CLOSE get_last_touched_date;

      IF g_debug
      THEN
         hr_utility.trace('Fetched from get_last_touched_date');
         hr_utility.trace('Total number of rows fetched '||bb_id_tab.COUNT);
      END IF;

      IF bb_id_tab.COUNT > 0
      THEN
         FORALL i IN bb_id_tab.FIRST..bb_id_tab.LAST
             UPDATE hxc_rpt_tc_details_all
                SET last_update_date = update_date_tab(i),
                    last_updated_by = update_user_tab(i),
                    last_updated_by_user = NULL,
                    date_to          = date_to_tab(i)
              WHERE detail_bb_id = bb_id_tab(i)
                AND detail_bb_ovn = bb_ovn_tab(i);
      END IF;

      bb_id_tab.DELETE;
      bb_ovn_tab.DELETE;
      date_to_tab.DELETE;
      update_date_tab.DELETE;


  EXCEPTION
    WHEN NO_DATA_FOUND THEN
         hr_utility.trace('update_last_touched_date threw NO DATA FOUND');

END update_last_touched_date;


-- UPDATE_TIMECARD_COMMENTS
-- For all the records recorded in a previous run in HXC_RPT_TC_DETAILS_ALL
-- updates the timecard comments, if they were changed.


PROCEDURE update_timecard_comments
AS

   CURSOR get_timecard_comments
       IS SELECT /*+ INDEX(det HXC_RPT_TC_DETAILS_FK2)*/
                 comment_text,
                 detail_bb_id,
                 detail_bb_ovn
            FROM hxc_time_building_blocks bb,
                 hxc_rpt_tc_details_all   det,
                 hxc_rpt_tc_resource_temp   gt
           WHERE bb.time_building_block_id = det.tc_bb_id
             AND bb.object_version_number  = det.tc_bb_ovn
             AND bb.comment_text           IS NOT NULL
             AND det.tc_bb_id              = gt.tc_bb_id
             AND det.request_id            = gt.request_id;

    comment_tab   VARCHARTABLE;
    det_bb_tab    NUMTABLE;
    det_ovn_tab   NUMTABLE;

BEGIN

    -- Public Procedure update_timecard_comments
    -- For all the records previously loaded into HXC_RPT_TC_DETAILS_ALL
    --      query from HXC_TIME_BUILDING_BLOCKS, their relevant timecard
    --      comments.
    -- Update HXC_RPT_TC_DETAILS_ALL with the comments picked up above.

    IF g_debug
    THEN
       hr_utility.trace('Starting update_timecard_comments');
    END IF;


    OPEN get_timecard_comments;

    FETCH get_timecard_comments
     BULK COLLECT INTO comment_tab,
                       det_bb_tab,
                       det_ovn_tab ;
    CLOSE get_timecard_comments;

    IF g_debug
    THEN
       hr_utility.trace('Fetched from get_timecard_comments');
       hr_utility.trace('Total number of rows fetched '||det_bb_tab.COUNT);
    END IF;

    IF det_bb_tab.COUNT > 0
    THEN
       FORALL i IN det_bb_tab.FIRST..det_bb_tab.LAST
            UPDATE hxc_rpt_tc_details_all
               SET tc_comments = comment_tab(i)
             WHERE detail_bb_id    = det_bb_tab(i)
               AND detail_bb_ovn   = det_ovn_tab(i);
    END IF;

    det_bb_tab.DELETE;
    det_ovn_tab.DELETE;
    comment_tab.DELETE;

    IF g_debug
    THEN
       hr_utility.trace('Completed update_timecard_comments alright');
    END IF;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         NULL;

END update_timecard_comments;




-- LOAD_DETAIL_INFO
-- Now that all history records are processed, new detail information
-- is put into HXC_RPT_TC_DETAILS_ALL table.


PROCEDURE load_detail_info ( p_request_sysdate IN DATE)
AS

BEGIN

    -- Public Procedure load_detail_info
    -- Insert into HXC_RPT_TC_DETAILS_ALL detail information
    --      and day information from HXC_TIME_BUILDING_BLOCKS
    -- WHERE clauses are placed taking care that data is picked up
    --      only from the history_from_date already recorded -- meaning
    --      we need data that is not existing only. Anyways, at this
    --      point, an already existing detail is picked up again, the request
    --      will error out, as there is a primary key on detail bb id and ovn
    --      in HXC_RPT_TC_DETAILS_ALL.

    IF g_debug
    THEN
       hr_utility.trace('load_detail_info begins '||p_request_sysdate);
    END IF;

    INSERT INTO hxc_rpt_tc_details_all
                ( resource_id,
                  tc_start_time,
                  tc_stop_time,
                  tc_bb_id,
                  tc_bb_ovn,
                  day_bb_id,
                  day_bb_ovn,
                  day_start_time,
                  day_stop_time,
                  detail_bb_id,
                  detail_bb_ovn,
                  hours_measure,
                  layout_id,
                  detail_comments,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  date_from,
                  date_to,
                  request_id,
                  resource_name,
                  day_date_to,
                  status )
          SELECT  gt.resource_id,
                  gt.tc_start_time,
                  gt.tc_stop_time,
                  day.parent_building_block_id,
                  day.parent_building_block_ovn,
                  day.time_building_block_id,
                  day.object_version_number,
                  NVL(detail.start_time,day.start_time),
                  NVL(detail.stop_time,day.stop_time),
                  detail.time_building_block_id,
                  detail.object_version_number,
                  NVL(detail.measure,(detail.stop_time-detail.start_time)*24),
                  gt.layout_id,
                  detail.comment_text,
                  detail.creation_date,
                  detail.created_by,
                  detail.last_update_date,
                  detail.last_updated_by,
                  detail.date_from,
                  detail.date_to,
                  gt.request_id,
                  gt.resource_name,
                  day.date_to,
                  detail.approval_status
            FROM  hxc_rpt_tc_resource_temp    gt,
                  hxc_time_building_blocks  day,
                  hxc_time_building_blocks  detail
           WHERE  gt.tc_bb_id                = day.parent_building_block_id
             AND  gt.resource_id             = day.resource_id
             AND  day.time_building_block_id = detail.parent_building_block_id
             AND  day.object_version_number  = detail.parent_building_block_ovn
             AND  detail.resource_id         = day.resource_id
             AND  detail.creation_date       > gt.history_from_date ;

        IF g_debug
        THEN
           hr_utility.trace('load_detail_info completed alright');
        END IF;

   EXCEPTION
       WHEN NO_DATA_FOUND THEN
           hr_utility.trace('No detail data found, something wrong with this list ');

END load_detail_info;


-- POPULATE_ATTRIBUTES
-- For all the detail time loaded via this request into HXC_RPT_TC_DETAILS_ALL
-- populate the relevant (those visible to the user; no hidden values ) time attributes
-- from HXC_TIME_ATTRIBUTES.


PROCEDURE populate_attributes(p_layout_id IN  NUMBER,
                              p_alias_tab OUT NOCOPY ALIASTAB )
AS

  l_curr_layout NUMBER(15);
  element_where VARCHAR2(50) ;

  CURSOR get_layout_fields ( p_curr_layout  NUMBER)
  IS SELECT 'MAX(DECODE('||DECODE(ATTRIBUTE_CATEGORY,
                                  'ELEMENT','SUBSTR(ATTRIBUTE_CATEGORY,1,7)','ATTRIBUTE_CATEGORY'
                                  )
                    ||','''||attribute_category||''',ha.'||attribute||'))',
             attribute_category,
             component_name,
             row_num
       FROM (  SELECT hlc.layout_id,
                      hlc.layout_component_id,
                      REGEXP_REPLACE(hlc.component_name,'.*- ') component_name,
                      DECODE( hlcq.qualifier_attribute26,
                              'Dummy Element Context','ELEMENT',
                              SUBSTR(hlcq.qualifier_attribute26,1,30)
                             ) attribute_category,
                      SUBSTR(hlcq.qualifier_attribute27,1,30) attribute,
                      RANK() OVER ( ORDER BY hlc.layout_component_id ) row_num
                 FROM hxc_layouts                hl,
	              hxc_layout_components      hlc,
	              hxc_layout_comp_qualifiers hlcq
                WHERE hlc.layout_id                     = hl.layout_id
                  AND hl.layout_id                      = p_curr_layout
                  AND hl.layout_type                    = 'TIMECARD'
                  AND hlcq.layout_component_id          = hlc.layout_component_id
                  AND hlcq.qualifier_attribute25        = 'FLEX'
                  AND hlcq.qualifier_attribute_category IN ('LOV','CHOICE_LIST',
					                    'PACKAGE_CHOICE_LIST',
					                    'TEXT_FIELD',
			  		                    'DESCRIPTIVE_FLEX')
             );


  dynamic_header VARCHAR2(1000);
  l_dynamic_header VARCHAR2(1000) :=
  'BEGIN
     DECLARE
        TYPE numtable IS TABLE OF NUMBER;
        TYPE varchartable IS TABLE OF VARCHAR2(150);
        det_bb_id_tab numtable;
        det_bb_ovn_tab numtable;
        cla_reason_tab  varchartable;
        cla_comments_tab varchartable;
        cla_type_tab  varchartable;
        ';

  dynamic_cursor_select VARCHAR2(1000);
  l_dynamic_cursor_select VARCHAR2(1000) :=
  '     CURSOR get_attributes IS
         SELECT det.detail_bb_id,
                det.detail_bb_ovn,
                MAX(DECODE(ATTRIBUTE_CATEGORY,''REASON'',ha.ATTRIBUTE1)),
                MAX(DECODE(ATTRIBUTE_CATEGORY,''REASON'',ha.ATTRIBUTE2)),
                MAX(DECODE(ATTRIBUTE_CATEGORY,''REASON'',ha.ATTRIBUTE3)),
                ';
  dynamic_cursor_where VARCHAR2(2000);
  l_dynamic_cursor_where VARCHAR2(2000) := '
         FROM  hxc_rpt_tc_resource_temp gt,
               hxc_rpt_tc_details_all  det,
               hxc_time_attribute_usages hau,
               hxc_time_attributes  ha
        WHERE  gt.tc_bb_id = det.tc_bb_id
          AND  gt.layout_id = curr_layout_id
          AND  gt.request_id = det.request_id
          AND  det.detail_bb_id = hau.time_building_block_id
          AND  det.detail_bb_ovn = hau.time_building_block_ovn
          AND  ha.time_attribute_id = hau.time_attribute_id
          AND  (ha.attribute_category in (''REASON'',';

  dynamic_cursor_group_by VARCHAR2(500);
  l_dynamic_cursor_group_by VARCHAR2(500) :=
   '

         GROUP by det.detail_bb_id,
                det.detail_bb_ovn ; ';

  dynamic_cursor_open VARCHAR2(1000);
  l_dynamic_cursor_open VARCHAR2(1000) :=
   '
   BEGIN
     OPEN get_attributes;
     FETCH get_attributes BULK COLLECT INTO det_bb_id_tab,
                                            det_bb_ovn_tab,
                                            cla_reason_tab,
                                            cla_comments_tab,
                                            cla_type_tab,
                                            ';
  dynamic_cursor_close VARCHAR2(1000) ;
  l_dynamic_cursor_close VARCHAR2(1000) :=
   '
     CLOSE get_attributes;';

  dynamic_update VARCHAR2(2000);
  l_dynamic_update VARCHAR2(2000) :=
   ' IF det_bb_id_tab.COUNT > 0 THEN
     FORALL i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
             UPDATE hxc_rpt_tc_details_all
                SET cla_reason = cla_reason_tab(i),
                    cla_comments = cla_comments_tab(i),
                    cla_type     = cla_type_tab(i),';
  dynamic_update_where VARCHAR2(1000);
  l_dynamic_update_where VARCHAR2(1000) :=
   '
              WHERE detail_bb_id = det_bb_id_tab(i)
                AND detail_bb_ovn = det_bb_ovn_tab(i);
          END IF;      ';

  dynamic_footer VARCHAR2(200);
  l_dynamic_footer VARCHAR2(200) :=
  '
      END;
   END;';

  dynamic_query LONG;

  l_layout_fld_column VARCHAR2(200);
  l_layout_fld_where  VARCHAR2(200);
  l_layout_fld_rownum NUMBER(15);
  l_layout_fld_name   VARCHAR2(30);
  alias_cnt  NUMBER := 0;


  -- INITIALIZE_DYNAMIC_VARIABLES
  -- The dynamic pl/sql block bits and pieces are constant variables -- you cant
  -- alter them each time this function is accessed, because they have to be
  -- reused. The constant variables are all having 'l_' prefixed and the real
  -- dynamic strings are all equated to these constant variables at the start of
  -- the parent procedure.

  PROCEDURE initialize_dynamic_variables
  AS

  BEGIN

     -- Private Procedure initialize_dynamic_variables
     -- Initialize all the dynamic variables with the dynamic string constants

     IF g_debug
     THEN
        hr_utility.trace('Starting initialize_dynamic_variables');
     END IF;

     dynamic_header           := l_dynamic_header;
     dynamic_cursor_select    := l_dynamic_cursor_select;
     dynamic_cursor_where     := l_dynamic_cursor_where;
     dynamic_cursor_group_by  := l_dynamic_cursor_group_by;
     dynamic_cursor_open      := l_dynamic_cursor_open;
     dynamic_cursor_close     := l_dynamic_cursor_close;
     dynamic_update           := l_dynamic_update;
     dynamic_update_where     := l_dynamic_update_where;
     dynamic_footer           := l_dynamic_footer;
     element_where            := ' ) ';

     IF g_debug
     THEN
        hr_utility.trace('initialize_dynamic_variables completed alright');
     END IF;


  END initialize_dynamic_variables;



BEGIN

    -- Public Procedure populate_attributes
    -- This one is one of the most processing intensive one in this whole
    --       request.
    -- Has dynamic sql bits and pieces, which when processed and joined
    --       together yield a plsql block which picks out the attributes
    --       relevant for the detail records.
    -- This is how the plsql block will look like -- this is from a test run
    --       which is pasted here for future reference.

    -- Dynamic Pl/Sql Block
    -- --------------------
    --
    -- BEGIN
    --      DECLARE
    --         TYPE numtable IS TABLE OF NUMBER;
    --         TYPE varchartable IS TABLE OF VARCHAR2(200);
    --         det_bb_id_tab numtable;
    --         det_bb_ovn_tab numtable;
    --         cla_reason_tab  varchartable;
    --         cla_comments_tab varchartable;
    --         cla_type_tab  varchartable;
    --         display_val1  varchartable;
    --            display_val3  varchartable;
    --
    --      CURSOR get_attributes IS
    --          SELECT det.detail_bb_id,
    --                 det.detail_bb_ovn,
    --                 MAX(DECODE(ATTRIBUTE_CATEGORY,'REASON',ha.ATTRIBUTE1)),
    --                 MAX(DECODE(ATTRIBUTE_CATEGORY,'REASON',ha.ATTRIBUTE2)),
    --                 MAX(DECODE(ATTRIBUTE_CATEGORY,'REASON',ha.ATTRIBUTE3)),
    --                 MAX(DECODE(ATTRIBUTE_CATEGORY,'APPROVAL',ha.Attribute10))
    --            ,MAX(DECODE(ATTRIBUTE_CATEGORY,'Dummy Cost Context',ha.Attribute1))
    --          FROM  hxc_rpt_tc_resource_temp gt,
    --                hxc_rpt_tc_details_all  det,
    --                hxc_time_attribute_usages hau,
    --                hxc_time_attributes  ha
    --         WHERE  gt.tc_bb_id = det.tc_bb_id
    --           AND  gt.layout_id = 7
    --           AND  gt.request_id = det.request_id
    --           AND  det.detail_bb_id = hau.time_building_block_id
    --           AND  det.detail_bb_ovn = hau.time_building_block_ovn
    --           AND  ha.time_attribute_id = hau.time_attribute_id
    --           AND  (ha.attribute_category in ('REASON','APPROVAL','Dummy Cost Context') )
    --          GROUP by det.detail_bb_id,
    --                 det.detail_bb_ovn ;
    --
    --    BEGIN
    --      OPEN get_attributes;
    --      FETCH get_attributes BULK COLLECT INTO det_bb_id_tab,
    --                                             det_bb_ovn_tab,
    --                                             cla_reason_tab,
    --                                             cla_comments_tab,
    --                                             cla_type_tab,
    --                                             display_val1,
    --                                             display_val3;
    --      CLOSE get_attributes;
    --  IF det_bb_id_tab.COUNT > 0 THEN
    --      FORALL i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
    --              UPDATE hxc_rpt_tc_details_all
    --                 SET cla_reason = cla_reason_tab(i),
    --                     cla_comments = cla_comments_tab(i),
    --                     cla_type     = cla_type_tab(i),
    --                     attribute1 = display_val1(i),
    --                     attribute3 = display_val3(i)
    --               WHERE detail_bb_id = det_bb_id_tab(i)
    --                 AND detail_bb_ovn = det_bb_ovn_tab(i);
    --           END IF;

    --       END;
    --    END;


    --  This block is created by concatenating a set of bits, which are processed
    --  after picking values from the tables.  Explanation goes below.
    --
    --  1. Dynamic_header -- This has the header info for the block, with the
    --     Declare statement, types declared and the plsql table objects defined
    --     which are common for all detail records -- the detail bb ids, ovns
    --     and CLA reasons. CLA reasons are not present for all detail records,
    --     but for all records having them, they have the same structure, so the query
    --     is hardcoded here.
    --  2. Dynamic_cursor_select -- This holds the select placeholders or the columns to
    --     be selected from. Here I chose to select all the attributes at one shot, so
    --     used GROUP BY and MAX to have them in separate columns. Which columns are to be
    --     selected, is determined by the get_layout_fields query.
    --  3. Dynamic_cursor_where -- This will attach a WHERE clause to the query putting
    --     in which all attribute categories you have to look at.  REASON is added by
    --     default to pick up the CLA reasons.
    --  4. Dynamic_cursor_group_by -- This will attach a GROUP BY clause to the query
    --     putting in all the relevant column names.
    --  5. Dynamic_cursor_open -- This will create the OPEN and FETCH statement for the
    --     dynamic cursor.
    --  6. Dynamic_cursor_close -- Will create the close statement for the cursor.
    --  7. Dynamic_update -- Holds the static string to update the time detail records.
    --     The results of get_layout_fields query will determine what other columns
    --     are to be put in.
    --  8. Dynamic_update_where -- WHERE clause for the above dynamic update clause, again
    --     building the WHERE clauses depending upon what is thrown out of get_layout_fields.
    --  9. Dynamic_footer -- Footer for the block, holding END statements.


    -- A critical factor in this dynamic block builder is the get_layout_fields cursor
    -- which selects out the layout fields -- essentially meaning the user enterable
    -- components in the layouts. The four values returned for each user enterable components
    -- are --
    --       * l_layout_fld_column
    --               prints out something like this.
    --                 MAX(DECODE(ATTRIBUTE_CATEGORY,'Dummy Cost Context',ha.Attribute1))
    --       * l_layout_fld_where
    --                 'Dummy Cost Context' ( inserted in ATTRIBUTE_CATEGORY IN (..) )
    --       * l_layout_fld_name
    --                  For eg. Hours Type
    --       * l_layout_fld_rownum
    --                  The rank in terms of layout_component_id. Plays a key role because
    --                  this determines which of the 30 Attributes in HXC_RPT_TC_DETAILS_ALL
    --                  are used for this component.
    --
    --    Inline comments are put in below for reference.
    --
    --

    IF g_debug
    THEN
       hr_utility.trace('populate_attributes');
       hr_utility.trace('Parameter - p_layout_id : '||p_layout_id);
    END IF;

    l_curr_layout := p_layout_id;
    initialize_dynamic_variables;
    p_alias_tab := ALIASTAB();
    OPEN get_layout_fields( l_curr_layout) ;
    LOOP
       FETCH get_layout_fields INTO l_layout_fld_column,
                                    l_layout_fld_where,
                                    l_layout_fld_name,
                                    l_layout_fld_rownum;
       EXIT WHEN get_layout_fields%NOTFOUND;

       IF g_debug
       THEN
          hr_utility.trace('Ftetched from get_layout_fields ');
          hr_utility.trace('l_layout_fld_column :'||l_layout_fld_column);
          hr_utility.trace('l_layout_fld_where :'||l_layout_fld_where);
          hr_utility.trace('l_layout_fld_name :'||l_layout_fld_name);
          hr_utility.trace('l_layout_fld_rownum :'||l_layout_fld_rownum);
       END IF;

       IF l_layout_fld_where NOT LIKE 'OTL_ALIAS%'
       THEN
           dynamic_header := dynamic_header||'display_val'||l_layout_fld_rownum||'  varchartable;
           ';
           dynamic_cursor_select := dynamic_cursor_select||l_layout_fld_column||'
           ,';
           dynamic_cursor_where  := dynamic_cursor_where||''''||l_layout_fld_where||''',';
           dynamic_cursor_open  := dynamic_cursor_open||'display_val'||l_layout_fld_rownum||',';
           dynamic_update := dynamic_update||'attribute'||l_layout_fld_rownum||
                             ' = display_val'||l_layout_fld_rownum||'(i),';
           IF l_layout_fld_where = 'ELEMENT'
           THEN
              element_where := ' OR substr(ha.attribute_category,1,7) = ''ELEMENT'')';
              IF g_debug
              THEN
                 hr_utility.trace('Attribute category is Element ');
                 hr_utility.trace('element_where : '||element_where);
              END IF;
           END IF;
       ELSE
          IF g_debug
          THEN
             hr_utility.trace('This is an alias value ');
          END IF;
          p_alias_tab.EXTEND;
          alias_cnt := alias_cnt+1;
          p_alias_tab(alias_cnt).layout_id := p_layout_id;
          p_alias_tab(alias_cnt).alias_column := l_layout_fld_rownum;
          p_alias_tab(alias_cnt).alias_name := l_layout_fld_name;
       END IF;
    END LOOP;
    CLOSE get_layout_fields;


    dynamic_cursor_select := RTRIM(dynamic_cursor_select,',');
    dynamic_cursor_where  := RTRIM(dynamic_cursor_where,',');
    dynamic_cursor_where  := REPLACE(dynamic_cursor_where,'curr_layout_id',l_curr_layout);
    dynamic_cursor_open   := RTRIM(dynamic_cursor_open,',');
    dynamic_cursor_open   := dynamic_cursor_open||';';
    dynamic_update        := RTRIM(dynamic_update,',');
    dynamic_cursor_where  := dynamic_cursor_where||')'||element_where;

    IF g_debug
    THEN
        hr_utility.trace('Dynamic Pl/Sql Block created ');
        hr_utility.trace('------------------------------');
        hr_utility.trace(' ');
        hr_utility.trace(dynamic_header);
	hr_utility.trace(dynamic_cursor_select);
	hr_utility.trace(dynamic_cursor_where);
	hr_utility.trace(dynamic_cursor_group_by);
	hr_utility.trace(dynamic_cursor_open);
	hr_utility.trace(dynamic_cursor_close);
	hr_utility.trace(dynamic_update);
	hr_utility.trace(dynamic_update_where);
	hr_utility.trace(dynamic_footer);
        hr_utility.trace('/');
    END IF;

    dynamic_query := dynamic_header||
                     dynamic_cursor_select||
                     dynamic_cursor_where||
                     dynamic_cursor_group_by||
                     dynamic_cursor_open||
                     dynamic_cursor_close||
                     dynamic_update||
                     dynamic_update_where||
                     dynamic_footer;

    BEGIN
        EXECUTE IMMEDIATE dynamic_query;
      EXCEPTION
         WHEN OTHERS THEN
             hr_utility.trace('Execute Immediate in populate attributes threw Sql Error : '||SQLCODE);
             RAISE;
    END;

    IF g_debug
    THEN
       hr_utility.trace('populate_attributes completed alright ');
    END IF;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        hr_utility.trace('No data found from Populate attributes');

END populate_attributes;


-- TRANSLATE_ATTRIBUTES
-- Translates the attributes already loaded into HXC_RPT_TC_DETAILS_ALL table
-- against the queries in HXC_RPT_LAYOUT_COMP_QUERIES


PROCEDURE translate_attributes(p_layout_id NUMBER)
AS

  CURSOR get_layout_queries( p_layout NUMBER)
      IS SELECT attribute||' = '''||component_name||':  ''||NVL(('||query||'hx.'||attribute||'),hx.'||attribute||')'
           FROM hxc_rpt_layout_comp_queries
          WHERE layout_id = p_layout;

  l_update VARCHAR2(4000);
  l_curr_layout NUMBER(15);

  l_update_predicate VARCHAR2(4000) :=
  '    UPDATE /*+ INDEX(hx HXC_RPT_TC_DETAILS_FK2) */
              hxc_rpt_tc_details_all hx
          SET ';

  l_update_where VARCHAR2(4000) :=
  '     WHERE tc_bb_id IN ( SELECT tc_bb_id
                              FROM hxc_rpt_tc_resource_temp gt
                             WHERE layout_id = current_layout
                           )
          AND request_id = THIS_REQUEST_ID';

  curr_query VARCHAR2(2000);

BEGIN

    -- Public Procedure translate_attributes
    -- Get the queries associated with layout components from HXC_RPT_LAYOUT_COMP_QUERIES
    --         one by one thru get_layout_queries
    -- Create the dynamic update sql string attaching this query for all the detail
    --         records belonging to timecards having this layout id.
    -- Execute the dynamic update;  repeat all the above steps for each component in the
    --         corresponding layout, which has a record in HXC_RPT_LAYOUT_COMP_QUERIES.


    IF g_debug
    THEN
       hr_utility.trace('translate_attributes');
       hr_utility.trace('Parameter - p_layout_id : '||p_layout_id);
    END IF;
    l_curr_layout := p_layout_id;
    OPEN get_layout_queries(l_curr_layout);
    LOOP
       FETCH get_layout_queries
        INTO curr_query;
       EXIT WHEN get_layout_queries%NOTFOUND;
       l_update := l_update_predicate||curr_query||l_update_where;
       l_update := REPLACE(l_update,'current_layout',l_curr_layout);
       l_update := REPLACE(l_update,'THIS_REQUEST_ID',g_request_id);
       IF g_debug
       THEN
          hr_utility.trace('Dynamic Update query is ');
          hr_utility.trace(l_update);
       END IF;

       BEGIN
           EXECUTE IMMEDIATE l_update;
         EXCEPTION
           WHEN OTHERS THEN
               hr_utility.trace('Execute Immediate in translate_attributes threw Sql Error : '||SQLCODE);
       END;

    END LOOP;
    CLOSE get_layout_queries;

    IF g_debug
    THEN
       hr_utility.trace('translate_attributes completed alright ');
    END IF;

  EXCEPTION
       WHEN NO_DATA_FOUND THEN
           hr_utility.trace('No Data Found from translate_attributes ');

END translate_attributes;



-- TRANSLATE_ALIASES
-- This procedure loads and translates all the Alternate Name components
-- associated with the timecard, for a given layout.

PROCEDURE translate_aliases(p_layout_id NUMBER,
                            p_alias_tab ALIASTAB)
AS


  CURSOR get_alias_defs (p_layout_id NUMBER)
      IS SELECT DISTINCT alias_definition_id
           FROM hxc_rpt_tc_resource_temp
          WHERE layout_id = p_layout_id
            AND alias_definition_id <> 0;

  l_curr_layout NUMBER;
  alias_exists  NUMBER;
  l_curr_alias 	NUMBER;

  CURSOR get_alias_columns ( p_alias_def NUMBER)
  IS SELECT 'MAX(DECODE(bld_blk_info_type_id,'||hmc.bld_blk_info_type_id||','
            ||DECODE(segment,'ATTRIBUTE_CATEGORY','LTRIM(ha.'||segment||','''||building_block_category||' - '')','ha.'||segment)||'))',
            hatc.component_type
       FROM hxc_mapping_components        hmc,
            hxc_alias_types               hat,
            hxc_alias_type_components     hatc,
            hxc_alias_definitions         had,
            hxc_bld_blk_info_type_usages  bldu,
            hxc_bld_blk_info_types        bld
      WHERE had.alias_type_id             = hat.alias_type_id
        AND hatc.alias_type_id            = hat.alias_type_id
        AND hmc.mapping_component_id      = hatc.mapping_component_id
        AND bld.bld_blk_info_type_id      = hmc.bld_blk_info_type_id
        AND bld.bld_blk_info_type_id      = hmc.bld_blk_info_type_id
        AND bld.bld_blk_info_type_id      = bldu.bld_blk_info_type_id
        AND had.alias_definition_id       = p_alias_def
      ORDER
         BY hatc.component_type ;

  l_alias_column VARCHAR2(500);

  dynamic_cursor VARCHAR2(2000);
  l_dynamic_cursor VARCHAR2(2000) :=
  '   alias_value varchartable;
      CURSOR get_alias_attributes IS
      SELECT detail_bb_id,
             detail_bb_ovn,
             ';

  dynamic_where VARCHAR2(2000);
  l_dynamic_where VARCHAR2(2000) :=
  '         '' ''
       FROM hxc_rpt_tc_details_all det,
            hxc_rpt_tc_resource_temp gt,
	      hxc_time_attribute_usages hau,
	      hxc_time_attributes ha
      WHERE gt.tc_bb_id = det.tc_bb_id
        AND gt.layout_id = curr_layout_id
        AND gt.alias_definition_id = curr_alias_id
        AND gt.request_id = det.request_id
        AND hau.time_building_block_id = detail_bb_id
        AND hau.time_building_block_ovn = detail_bb_ovn
        AND ha.time_attribute_id = hau.time_attribute_id
      GROUP
         BY detail_bb_id,
            detail_bb_ovn ;';

  dynamic_cursor2_head VARCHAR2(500);
  l_dynamic_cursor2_head VARCHAR2(500) :=
  ' CURSOR get_alias_values (';

  dynamic_cursor2 VARCHAR2(2000);
  l_dynamic_cursor2 VARCHAR2(2000) :=
  '                         ) IS
     SELECT alias_value_name
       FROM hxc_alias_values
      WHERE alias_definition_id = curr_alias_def
        AND ';


  dynamic_header VARCHAR2(2000);
  l_dynamic_header VARCHAR2(2000) :=
 'BEGIN
     DECLARE
        TYPE numtable IS TABLE OF NUMBER;
        TYPE varchartable IS TABLE OF VARCHAR2(200);
        det_bb_id_tab numtable;
        det_bb_ovn_tab numtable;
        ';
  alias_attribute VARCHAR2(30);

  dynamic_core VARCHAR2(2000);
  l_dynamic_core VARCHAR2(2000) :=
  ' BEGIN
        OPEN get_alias_attributes;
        FETCH get_alias_attributes
         BULK COLLECT INTO det_bb_id_tab,
                           det_bb_ovn_tab,
                           ';
  dynamic_core2 VARCHAR2(2000);
  l_dynamic_core2 VARCHAR2(2000) :=
  '                        alias_value;
        CLOSE get_alias_attributes;
        IF det_bb_id_tab.COUNT > 0
        THEN
        FOR i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
        LOOP
           OPEN get_alias_values(';

   dynamic_core3 VARCHAR2(2000);
   l_dynamic_core3 VARCHAR2(2000) :=
   '       FETCH get_alias_values INTO alias_value(i);
           CLOSE get_alias_values;
        END LOOP;

        FORALL i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
           UPDATE hxc_rpt_tc_details_all
              set attributeATTR_COL = ''ALIASNAME:  ''||alias_value(i)
            WHERE detail_bb_id = det_bb_id_tab(i)
              AND detail_bb_ovn = det_bb_ovn_tab(i);
        END IF;
    END;
  END;
   ';

   dynamic_query LONG;

   l_attr_col NUMBER;
   l_alias_name VARCHAR2(30);


   -- INITIALIZE_DYNAMIC_VARIABLES
   -- The dynamic pl/sql block bits and pieces are constant variables -- you cant
   -- alter them each time this function is accessed, because they have to be
   -- reused. The constant variables are all having 'l_' prefixed and the real
   -- dynamic strings are all equated to these constant variables at the start of
   -- the parent procedure.

   PROCEDURE initialize_dynamic_variables
   AS
   BEGIN

       -- Private Procedure initialize_dynamic_variables
       -- Initializes all dynamic variables with the constant values, each time
       --      translate_aliases is called.

       IF g_debug
       THEN
          hr_utility.trace('initialize_dynamic_variables');
       END IF;

       dynamic_cursor        := l_dynamic_cursor;
       dynamic_where         := l_dynamic_where;
       dynamic_cursor2_head  := l_dynamic_cursor2_head;
       dynamic_cursor2       := l_dynamic_cursor2;
       dynamic_header        := l_dynamic_header;
       dynamic_core          := l_dynamic_core;
       dynamic_core2         := l_dynamic_core2;
       dynamic_core3         := l_dynamic_core3;
   END initialize_dynamic_variables;


BEGIN


    -- Public Procedure translate_aliases
    -- Like Populate_attributes, this is also very much processing intensive.
    -- Creates a dynamic pl/sql block from the sql string bits and pieces,
    --       depending on the alias definition ids and executes the same
    --       loading the translated alias values into HXC_RPT_TC_DETAILS_ALL.
    -- Pasted below is a sample Pl/Sql block created in one of the test runs.

    -- -----------------------------
    --
    -- BEGIN
    --      DECLARE
    --         TYPE numtable IS TABLE OF NUMBER;
    --         TYPE varchartable IS TABLE OF VARCHAR2(100);
    --         det_bb_id_tab numtable;
    --         det_bb_ovn_tab numtable;
    --         ATTRIBUTE1tab varchartable;
    --         ATTRIBUTE2tab varchartable;
    --         alias_value varchartable;
    --       CURSOR get_alias_attributes IS
    --       SELECT detail_bb_id,
    --              detail_bb_ovn,
    --              MAX(DECODE(bld_blk_info_type_id,1,LTRIM(ha.ATTRIBUTE_CATEGORY,'ELEMENT - '))),
    --              MAX(DECODE(bld_blk_info_type_id,201,ha.ATTRIBUTE1)),
    --          ' '
    --        FROM hxc_rpt_tc_details_all det,
    --             hxc_rpt_tc_resource_temp gt,
    --             hxc_time_attribute_usages hau,
    -- 	    hxc_time_attributes ha
    --       WHERE gt.tc_bb_id = det.tc_bb_id
    --         AND gt.layout_id = 7
    --         AND gt.request_id = det.request_id
    --         AND hau.time_building_block_id = detail_bb_id
    --         AND hau.time_building_block_ovn = detail_bb_ovn
    --         AND ha.time_attribute_id = hau.time_attribute_id
    --       GROUP
    --          BY detail_bb_id,
    --             detail_bb_ovn ;
    --
    --  CURSOR get_alias_values (p_ATTRIBUTE1 VARCHAR2
    --                          ,p_ATTRIBUTE2 VARCHAR2
    --                           ) IS
    --      SELECT alias_value_name
    --        FROM hxc_alias_values
    --       WHERE alias_definition_id = 13546
    --         AND NVL(ATTRIBUTE1,'0') = NVL(p_ATTRIBUTE1,'0')
    --         AND NVL(ATTRIBUTE2,'0') = NVL(p_ATTRIBUTE2,'0')
    --          ;
    --
    --  BEGIN
    --         OPEN get_alias_attributes;
    --         FETCH get_alias_attributes
    --          BULK COLLECT INTO det_bb_id_tab,
    --                            det_bb_ovn_tab,
    --                            ATTRIBUTE1tab,
    --                            ATTRIBUTE2tab,
    --                            alias_value;
    --         CLOSE get_alias_attributes;
    --         IF det_bb_id_tab.COUNT > 0
    --         THEN
    --            FOR i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
    --            LOOP
    --                OPEN get_alias_values(ATTRIBUTE1tab(i)
    --                                     ,ATTRIBUTE2tab(i)
    --                                      );
    --                FETCH get_alias_values INTO
    --                       alias_value(i);
    --                CLOSE get_alias_values;
    --            END LOOP;
    --            FORALL i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
    --                UPDATE hxc_rpt_tc_details_all
    --                   set attribute2 = 'Hours Type  :  '||alias_value(i)
    --                 WHERE detail_bb_id = det_bb_id_tab(i)
    --                   AND detail_bb_ovn = det_bb_ovn_tab(i);
    --         END IF;
    --    END;
    --  END;
    --

    --  From populate_attributes, p_alias_tab, a plsql table would have been populated
    --        if this current layout is having atleast one alias value associated.
    --  Browse thru that to find out the alias attribute ( attribute to be used in HXC_
    --        RPT_TC_DETAILS_ALL table.
    --  Find out the alias definition pref associated for all the resources, in this
    --        layout and attach them to the table.
    --  Open get_alias_columns, passing on this alias definition id, and get the columns
    --        to look at for the alias attributes in HXC_TIME_ATTRIBUTES.
    --  Attach this to the dynamic strings and do the formatting.
    --  Concatenate all the dynamic sql strings, and execute the pl/sql block.



    IF g_debug
    THEN
       hr_utility.trace('translate_aliases');
       hr_utility.trace('Parameters ');
       hr_utility.trace('p_layout_id : '||p_layout_id);
       IF p_alias_tab.COUNT > 0
       THEN
          FOR i IN p_alias_tab.FIRST..p_alias_tab.LAST
          LOOP
             hr_utility.trace('Alias number '||i);
             hr_utility.trace('Layout : '||p_alias_tab(i).layout_id);
             hr_utility.trace('Name   : '||p_alias_tab(i).alias_name);
             hr_utility.trace('Column : '||p_alias_tab(i).alias_column);
          END LOOP;
       END IF;
    END IF;

    l_curr_layout := p_layout_id;

    IF p_alias_tab.COUNT > 0
    THEN
       FOR i IN p_alias_tab.FIRST..p_alias_tab.LAST
       LOOP

          IF g_debug
          THEN
             hr_utility.trace('Processing Alias No. '||i);
             hr_utility.trace('Alias Name :'||p_alias_tab(i).alias_name);
          END IF;

          l_attr_col := p_alias_tab(i).alias_column;
          l_alias_name := p_alias_tab(i).alias_name;

          UPDATE hxc_rpt_tc_resource_temp
             SET alias_definition_id =  NVL( hxc_preference_evaluation.resource_preferences
                                                          (resource_id,
                                                           'TC_W_TCRD_ALIASES',
                                                            i,
                                                            tc_start_time),0)
           WHERE layout_id = l_curr_layout;

           IF g_debug
           THEN
               hr_utility.trace('Updated alias definition ids for current list of resources ');
           END IF;

          OPEN get_alias_defs(l_curr_layout);
          LOOP
             FETCH get_alias_defs
              INTO l_curr_alias;
             EXIT WHEN get_alias_defs%NOTFOUND;

             IF g_debug
             THEN
                hr_utility.trace('Fetched from get_alias_defs ');
             END IF;


             initialize_dynamic_variables;

             OPEN get_alias_columns(l_curr_alias);
             LOOP
                 FETCH get_alias_columns
                  INTO l_alias_column,
                       alias_attribute;
                 EXIT WHEN get_alias_columns%NOTFOUND;

                 IF g_debug
                 THEN
                    hr_utility.trace('Fetched from get_alias_columns ');
                 END IF;

                 dynamic_cursor := dynamic_cursor||l_alias_column||',
                 ';
                 dynamic_header := dynamic_header||'
                 '||alias_attribute||'tab varchartable;';
                 dynamic_core := dynamic_core||alias_attribute||'tab,
                                         ';
                 dynamic_core2 := dynamic_core2||alias_attribute||'tab(i)
                                           ,';
                 dynamic_cursor2_head := dynamic_cursor2_head||'p_'||alias_attribute||' VARCHAR2
                                             ,';
                 dynamic_cursor2 :=
                 dynamic_cursor2||'NVL('||alias_attribute||',''0'')'||' = '||'NVL(p_'||alias_attribute||',''0'')
                    AND ';

             END LOOP;
             CLOSE get_alias_columns;
             dynamic_cursor       := RTRIM(dynamic_cursor,',');
             dynamic_header       := RTRIM(dynamic_header,',');
             dynamic_where        := REPLACE(dynamic_where,'curr_layout_id',l_curr_layout);
             dynamic_where        := REPLACE(dynamic_where,'curr_alias_id',l_curr_alias);
             dynamic_core2        := RTRIM(dynamic_core2,',');
             dynamic_core2        := dynamic_core2||');';
             dynamic_cursor2_head := RTRIM(dynamic_cursor2_head,',');
             dynamic_cursor2      := RTRIM(dynamic_cursor2,'AND ');
             dynamic_cursor2      := dynamic_cursor2||';';
             dynamic_cursor2      := REPLACE(dynamic_cursor2,'curr_alias_def',l_curr_alias);
             dynamic_core3        := REPLACE(dynamic_core3,'ATTR_COL',l_attr_col);
             dynamic_core3        := REPLACE(dynamic_core3,'ALIASNAME',l_alias_name);
             dynamic_query := dynamic_header||
                              dynamic_cursor||
                              dynamic_where||
                              dynamic_cursor2_head||
                              dynamic_cursor2||
                              dynamic_core||
                              dynamic_core2||
                              dynamic_core3;

             IF g_debug
             THEN
                hr_utility.trace('Dynamic Pl/Sql block created ');
                hr_utility.trace('-----------------------------');
                hr_utility.trace(' ');
                hr_utility.trace(dynamic_header);
                hr_utility.trace(dynamic_cursor);
                hr_utility.trace(dynamic_where);
                hr_utility.trace(dynamic_cursor2_head);
                hr_utility.trace(dynamic_cursor2);
                hr_utility.trace(dynamic_core);
                hr_utility.trace(dynamic_core2);
                hr_utility.trace(dynamic_core3);
             END IF;

             BEGIN

                   EXECUTE IMMEDIATE dynamic_query;

                EXCEPTION
                  WHEN OTHERS THEN
                      hr_utility.trace('Execute Immediate in translate_aliases threw Sql Error :'
                                           ||SQLCODE);
                      RAISE;
             END;

          END LOOP;
          CLOSE get_alias_defs;
       END LOOP;
    END IF;

    IF g_debug
    THEN
       hr_utility.trace('translate_aliases completed alright ');
    END IF;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No Data Found in translate aliases, something wrong ');

END translate_aliases;


-- TRANSLATE_CLA_REASONS
-- Translates the CLA reasons captured earlier against the lookup values.


PROCEDURE translate_cla_reasons
AS

  CURSOR get_cla_reasons
      IS SELECT flv.meaning,
                rtrim(substr(flv.lookup_type,5,6),'_A'),
                det.detail_bb_id,
                det.detail_bb_ovn
           FROM hxc_rpt_tc_details_all  det,
                hxc_rpt_tc_resource_temp  gt,
                fnd_lookup_values       flv
          WHERE gt.request_id           = det.request_id
            AND gt.resource_id          = det.resource_id
            AND gt.tc_start_time        = det.tc_start_time
            AND gt.tc_stop_time         = det.tc_stop_time
            AND flv.lookup_code         = det.cla_reason
            AND flv.language            = userenv('LANG')
            AND flv.lookup_type         IN ( 'HXC_CHANGE_AUDIT_REASONS',
                                             'HXC_LATE_AUDIT_REASONS')
            AND flv.view_application_id = 3
            AND flv.security_group_id   = FND_GLOBAL.lookup_security_group(flv.lookup_type,
                                                                           flv.view_application_id);

  l_meaning_tab       VARCHARTABLE;
  l_type_tab          VARCHARTABLE;
  l_det_bb_id_tab     NUMTABLE;
  l_det_bb_ovn_tab    NUMTABLE;


BEGIN

      -- Public Procedure translate_cla_reasons
      -- Fetch all the lookup codes for CLA reasons from HXC_RPT_TC_DETAILS_ALL
      --      wherever they exist.
      -- Fetch the corresponding Lookup names from FND_LOOKUP_VALUES.
      -- Update HXC_RPT_TC_DETAILS_ALL with the relevant lookup names

      IF g_debug
      THEN
         hr_utility.trace('translate_cla_reasons');
      END IF;


      OPEN get_cla_reasons;
      FETCH get_cla_reasons BULK COLLECT INTO l_meaning_tab,
                                              l_type_tab,
                                              l_det_bb_id_tab,
                                              l_det_bb_ovn_tab ;

      CLOSE get_cla_reasons;

      IF g_debug
      THEN
         hr_utility.trace('Fetched from get_cla_reasons ');
         hr_utility.trace('Total Number of rows : '||l_meaning_tab.COUNT);
      END IF;

      IF l_meaning_tab.COUNT > 0
      THEN
         FORALL i IN l_meaning_tab.FIRST..l_meaning_tab.LAST
             UPDATE hxc_rpt_tc_details_all
                SET cla_reason     = l_meaning_tab(i)
              WHERE detail_bb_id   = l_det_bb_id_tab(i)
                AND detail_bb_ovn  = l_det_bb_ovn_tab(i)
                AND cla_type       = l_type_tab(i) ;

         l_meaning_tab.DELETE;
         l_det_bb_id_tab.DELETE;
         l_det_bb_ovn_tab.DELETE;
         l_type_tab.DELETE;

      END IF;

      IF g_debug
      THEN
         hr_utility.trace('translate_cla_reasons completed alright');
      END IF;


   EXCEPTION
      WHEN NO_DATA_FOUND THEN
          IF g_debug
          THEN
              hr_utility.trace('No Data Found from translate_cla_reasons');
          END IF;

END translate_cla_reasons;



-- UPDATE_TRANSACTION_IDS
-- Finds out the relevant transaction_ids and transaction_detail_ids for the
-- chosen detail records from HXC_RPT_TC_DETAILS_ALL.

PROCEDURE  update_transaction_ids(p_record_save    IN VARCHAR2)
AS

  -- Bug 8888812
  -- Calling this cursor with a diff name now, because
  -- we no longer store DEPOSIT transactions in these tables.
  CURSOR get_old_transaction_details
      IS SELECT /*+ INDEX(det HXC_RPT_TC_DETAILS_FK1) */
                htd.transaction_id,
                htd.transaction_detail_id,
                det.detail_bb_id,
                det.detail_bb_ovn
           FROM hxc_rpt_tc_details_all   det,
                hxc_rpt_tc_resource_temp   gt,
                hxc_transaction_details  htd,
                hxc_transactions         ht
          WHERE gt.tc_start_time        = det.tc_start_time
            AND gt.tc_stop_time         = det.tc_stop_time
            AND gt.resource_id          = det.resource_id
            AND det.detail_bb_id        = htd.time_building_block_id
            AND det.detail_bb_ovn       = htd.time_building_block_ovn
            AND htd.transaction_id      = ht.transaction_id
            AND det.transaction_id IS NULL
            AND ht.type                 = 'DEPOSIT'
            AND ht.status               = 'SUCCESS'
            AND htd.status              = 'SUCCESS';

  -- Bug 8888812
  -- New cursor written to pick up records from
  -- the new set of tables.
  CURSOR get_transaction_details
      IS SELECT /*+ INDEX(det HXC_RPT_TC_DETAILS_FK1) */
                htd.transaction_id,
                htd.transaction_detail_id,
                det.detail_bb_id,
                det.detail_bb_ovn
           FROM hxc_rpt_tc_details_all   det,
                hxc_rpt_tc_resource_temp   gt,
                hxc_dep_transaction_details  htd,
                hxc_dep_transactions         ht
          WHERE gt.tc_start_time        = det.tc_start_time
            AND gt.tc_stop_time         = det.tc_stop_time
            AND gt.resource_id          = det.resource_id
            AND det.detail_bb_id        = htd.time_building_block_id
            AND det.detail_bb_ovn       = htd.time_building_block_ovn
            AND htd.transaction_id      = ht.transaction_id
            AND ht.type                 = 'DEPOSIT'
            AND ht.status               = 'SUCCESS'
            AND htd.status              = 'SUCCESS';



--
--
--  The following complex cursor pulls out the records from
--  hxc_rpt_tc_details_all, grouped by creation_date.
--
--  After the update above, the records would have transaction_id
--  populated if they belong to a SUBMIT action. The inner query
--  with DENSE_RANK would pull out these records with a
--  Dense Rank -- Rank with consecutive values.  For details on
--   how this works, check the Oracle 10g documentation.
--  Ranks are partitioned by resource_id, start_time, and stop_time
--  and are ordered by creation date.
--
--  The outer query would pull out the distinct records (ie.grouped by
--  dense rank, creation_date, and PERCENT_RANK. Percent rank works
--  the same way as RANK, but gives a value between 0 and 1 for the
--  Ranks. This percent rank is the decimal factor to be added to
--  the transaction_id to generate the pseudo transaction_id
--  which is a decimal between the preceeding and succeeding
--  transaction_ids.
--
--


  CURSOR get_working_trans
      IS SELECT DISTINCT creation_date,
	        transaction_id,
		resource_id,
		tc_start_time,
		tc_stop_time,
	        dense,
		ROUND(PERCENT_RANK() OVER(PARTITION BY resource_id,
                                                       tc_start_time,
                                                       tc_stop_time
					  ORDER BY creation_date),5)
  	   FROM ( SELECT creation_date,
	                 transaction_id,
			 DENSE_RANK() OVER(PARTITION BY det.resource_id,
                                                        det.tc_start_time,
                                                        det.tc_stop_time
                                               ORDER BY creation_date) dense,
		         det.resource_id,
		         det.tc_start_time,
		         det.tc_stop_time
                  FROM hxc_rpt_tc_details_all det,
                       hxc_rpt_tc_resource_temp temp
	         WHERE temp.resource_id = det.resource_id
	           AND temp.tc_start_time = det.tc_start_time
	           AND temp.tc_stop_time = det.tc_stop_time
		)
	  ORDER BY resource_id,
	           tc_start_time,
	           tc_stop_time,
	           dense ;



  det_bb_id_tab           NUMTABLE;
  det_bb_ovn_tab          NUMTABLE;
  det_trans_id_tab        NUMTABLE;
  det_trans_detail_id_tab NUMTABLE;

  res_id_tab              NUMTABLE;
  start_timetab           DATETABLE;
  stop_timetab            DATETABLE;
  creation_tab            DATETABLE;
  trans_tab               FLOATTABLE;
  fac_tab                 FLOATTABLE;
  densetab                NUMTABLE;



BEGIN

    -- Public Procedure update_transaction_ids
    -- Joins HXC_RPT_TC_DETAILS_ALL against HXC_TRANSACTION_DETAILS,
    --       and HXC_TRANSACTIONS to pick up all the transactions and
    --       transaction_details for a successful deposit.
    -- Update HXC_RPT_TC_DETAILS_ALL with the corresponding values.
    -- If p_record_save is set to Y, we need to give pseudo transaction_ids
    --       to the working status timecards.  Do it in the following way.

    --  Note: This needs to be carried out only for Self Service time entry.
    --       Timekeeper time entries create transaction records even for
    --       Working status timecards.  Such timecards wont be affected
    --       at all because the FORALL update works on those records with
    --       transaction_id as NULL.
    --
    -- Eg.  The timecard has been acted upon multiple ways in the following
    --  way. Actions in Initcaps are timecard actions, and those are the ones
    --  to look for transaction id in.
    --
    --    Action                Transaction_id
    --    =======              ================
    --    entered
    --      Saved                 NULL
    --      edited
    --      Saved                 NULL
    --      edited
    --      Submitted             234
    --      Deleted               335
    --      entered again.
    --      Saved                 NULL
    --      edited
    --      Saved                 NULL
    --      Submitted             436
    --
    --   If you observe the above table, all actions except Save creates transaction
    --   records in hxc_transactions, and have a transaction_id.
    --
    --   We need to populate some pseudo transaction_id to the Save actions, and this
    --   can be done in the following way.
    --
    --      entered
    --      Saved                 1
    --      edited
    --      Saved                 1.1
    --      edited
    --      Submitted             234
    --      Deleted               335
    --      entered again.
    --      Saved                 335.1
    --      edited
    --      Saved                 335.2
    --      Submitted             436
    --
    -- Here we are settling for a decimal value between the previous and next
    -- valid transaction_ids ordered by the sequence of action.  These pseudo
    -- transactions would be generated by the logic that follows.
    --
    -- The following sample data is the output of the cursor get_working_trans
    -- for a sequence of save, save, save, submit, save, submit.


    --    10/22/2008 4:49:14 AM		8110	1/7/2008	1/13/2008 11:59:59 PM	1	0
    --    10/22/2008 4:50:09 AM		8110	1/7/2008	1/13/2008 11:59:59 PM	2	0.09091
    --    10/22/2008 4:50:38 AM		8110	1/7/2008	1/13/2008 11:59:59 PM	3	0.22727
    --    10/22/2008 4:51:12 AM	196362	8110	1/7/2008	1/13/2008 11:59:59 PM	4	0.27273
    --    10/22/2008 6:39:21 AM		8110	1/7/2008	1/13/2008 11:59:59 PM	5	0.5
    --    10/22/2008 6:40:05 AM	196366	8110	1/7/2008	1/13/2008 11:59:59 PM	6	0.77273
    --
    --
    --   Note that transaction_id is populated only for the submit actions.
    --   The logic that follows would populate 1 for the first record.
    --   The FORALL update below would update transaction_id plus the 'dense'
    --   value from the cursor( the decimal column -- the last one ) as the pseudo
    --   transaction id.
    --
    --   After the update the data would look like this.  Note that only those records
    --   with transaction_id as NULL would have the pseudo values populated.
    --
    --    10/22/2008 4:49:14 AM	1	       8110	1/7/2008	1/13/2008 11:59:59 PM	1	0
    --    10/22/2008 4:50:09 AM	1.09091	       8110	1/7/2008	1/13/2008 11:59:59 PM	2	0.09091
    --    10/22/2008 4:50:38 AM	1.22727	       8110	1/7/2008	1/13/2008 11:59:59 PM	3	0.22727
    --    10/22/2008 4:51:12 AM	196362         8110	1/7/2008	1/13/2008 11:59:59 PM	4	0.27273
    --    10/22/2008 6:39:21 AM	196362.5       8110	1/7/2008	1/13/2008 11:59:59 PM	5	0.5
    --    10/22/2008 6:40:05 AM	196366         8110	1/7/2008	1/13/2008 11:59:59 PM	6	0.77273



    IF g_debug
    THEN
       hr_utility.trace('update_transaction_ids');
    END IF;

    OPEN get_transaction_details;

    FETCH get_transaction_details
     BULK COLLECT INTO det_trans_id_tab,
                       det_trans_detail_id_tab,
                       det_bb_id_tab,
                       det_bb_ovn_tab;

    CLOSE get_transaction_details;

    IF g_debug
    THEN
        hr_utility.trace('Fetched from get_transaction_details ');
        hr_utility.trace('Total Number of rows : '||det_trans_id_tab.COUNT);
    END IF;

    IF det_bb_id_tab.COUNT > 0
    THEN
        FORALL i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
            UPDATE hxc_rpt_tc_details_all
               SET transaction_id        = det_trans_id_tab(i),
                   transaction_detail_id = det_trans_detail_id_tab(i)
             WHERE detail_bb_id          = det_bb_id_tab(i)
               AND detail_bb_ovn         = det_bb_ovn_tab(i);


       det_bb_id_tab.DELETE;
       det_bb_ovn_tab.DELETE;
       det_trans_id_tab.DELETE;
       det_trans_detail_id_tab.DELETE;
    END IF;

    -- Bug 8888812
    -- In case the restructuring upgrade is not complete,
    -- you may have some old timecards with the old structure.
    -- Pick them up and do the same procedure as above.
    IF NOT hxc_upgrade_pkg.txn_upgrade_completed
    THEN
        OPEN get_old_transaction_details;

        FETCH get_old_transaction_details
         BULK COLLECT INTO det_trans_id_tab,
                           det_trans_detail_id_tab,
                           det_bb_id_tab,
                           det_bb_ovn_tab;

        CLOSE get_old_transaction_details;

        IF g_debug
        THEN
            hr_utility.trace('Fetched from get_transaction_details ');
            hr_utility.trace('Total Number of rows : '||det_trans_id_tab.COUNT);
        END IF;

        IF det_bb_id_tab.COUNT > 0
        THEN
            FORALL i IN det_bb_id_tab.FIRST..det_bb_id_tab.LAST
                UPDATE hxc_rpt_tc_details_all
                   SET transaction_id        = det_trans_id_tab(i),
                       transaction_detail_id = det_trans_detail_id_tab(i)
                 WHERE detail_bb_id          = det_bb_id_tab(i)
                   AND detail_bb_ovn         = det_bb_ovn_tab(i);


           det_bb_id_tab.DELETE;
           det_bb_ovn_tab.DELETE;
           det_trans_id_tab.DELETE;
           det_trans_detail_id_tab.DELETE;
        END IF;
    END IF;


    -- If record_save option is Yes
    IF p_record_save = 'Y'
    THEN
       -- Get the cursor to pick out the transaction_ids
       -- and the decimal factor to be added to the transaction_ids
       -- to generate the pseudo transactions.

       OPEN get_working_trans;

       FETCH get_working_trans
        BULK COLLECT INTO creation_tab,
                          trans_tab,
                          res_id_tab,
                          start_timetab,
                          stop_timetab,
                          densetab,
                          fac_tab;


       CLOSE get_working_trans;

       -- If the first transaction is NULL, assign 1 to it.

       -- Bug 7707609
       -- If any other transaction is NULL, assign the previous one to it,
       -- if the factor obtained from above query is not zero.
       -- If it is zero, it means that this is the first ever transaction
       -- for the given timecard.

       IF trans_tab.COUNT > 0
       THEN
          FOR i IN trans_tab.FIRST..trans_tab.LAST
          LOOP
             IF trans_tab(i) IS NULL
             THEN
                IF ( NOT trans_tab.EXISTS(i-1) )  -- For the first record
                  OR ( fac_tab(i) = 0 )           -- For the first record for each timecard.
                THEN
                   trans_tab(i) := 1;
                ELSE
                   trans_tab(i) := trans_tab(i-1);
                END IF;
             END IF;
          END LOOP;
       END IF;


       -- This is to take care of large timecards created using templates.
       -- For such timecards, all the details would not have the same
       -- creation_date -- may differ by one second or two seconds.
       -- This may be a bug in Time Store, but this would make the
       -- transactions look like two Save operations, because they have
       -- different creation_dates and would be ranked differently.
       -- For these guys, equate the decimal factor of the latest
       -- one to the earlier ones, so that only one Save comes up.

       IF trans_tab.COUNT > 0
       THEN
          FOR i IN trans_tab.FIRST..trans_tab.LAST
          LOOP
             IF trans_tab.EXISTS(i+1)
             THEN
                IF trans_tab(i) = trans_tab(i+1)
                 AND ((creation_tab(i+1) - creation_tab(i))*24*60*60) <=2
                THEN
                   fac_tab(i) := fac_tab(i+1);
                END IF;
             END IF;
          END LOOP;
       END IF;



       IF creation_tab.COUNT > 0
       THEN
           FORALL i IN creation_tab.FIRST..creation_tab.LAST
              UPDATE hxc_rpt_tc_details_all
                 SET transaction_id = trans_tab(i)+fac_tab(i)
               WHERE resource_id = res_id_tab(i)
                 AND tc_start_time = start_timetab(i)
                 AND tc_stop_time = stop_timetab(i)
                 AND creation_date = creation_tab(i)
                 AND transaction_id IS NULL;


           res_id_tab.DELETE;
           start_timetab.DELETE;
           stop_timetab.DELETE;
           creation_tab.DELETE;
           trans_tab.DELETE;
       END IF;

    END IF;


    IF g_debug
    THEN
       hr_utility.trace('update_transaction_ids completed alright');
    END IF;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         IF g_debug
         THEN
             hr_utility.trace('No Data Found from update_transaction_ids');
         END IF;

END update_transaction_ids;


-- TRANSLATE_CREATED_BY
-- Translates the created by user ids to "user_name(resource_name)" format.

PROCEDURE translate_created_by
AS

  CURSOR get_created_user ( p_request_id VARCHAR2 )
      IS SELECT /*+ ORDERED */
                det.detail_bb_id,
                det.detail_bb_ovn,
                fnd.user_name||newline||'['||
                ppf.full_name||']'
           FROM hxc_rpt_tc_resource_temp gt,
                hxc_rpt_tc_details_all det,
                fnd_user               fnd,
                per_all_people_f       ppf
          WHERE gt.tc_bb_id           = det.tc_bb_id
            AND gt.request_id         = p_request_id
            AND det.created_by        = fnd.user_id
            AND fnd.employee_id       = ppf.person_id
            AND det.day_start_time BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
            AND det.created_by_user IS NULL ;

   l_bb_id_tab numtable;
   l_bb_ovn_tab numtable;
   l_person_tab varchartable;

BEGIN


    -- Public Procedure translate_created_by
    -- Find out user_name for the corresponding user_ids from FND_USER
    --       and full_name from PER_ALL_PEOPLE_F for the employee_ids from
    --       FND_USER.
    -- Update HXC_RPT_TC_DETAILS_ALL with the corresponding values.

    IF g_debug
    THEN
       hr_utility.trace('translate_created_by');
    END IF;


    OPEN get_created_user(g_request_id);

    FETCH get_created_user BULK COLLECT INTO l_bb_id_tab,
                                             l_bb_ovn_tab,
                                             l_person_tab ;

    CLOSE get_created_user;

    IF g_debug
    THEN
       hr_utility.trace('Fetched from get_created_user ');
       hr_utility.trace('Total number of rows fetched : '||l_bb_id_tab.COUNT);
    END IF;

    IF l_bb_id_tab.COUNT > 0
    THEN
       FORALL i IN l_bb_id_tab.FIRST..l_bb_id_tab.LAST
           UPDATE hxc_rpt_tc_details_all
              SET created_by_user  = l_person_tab(i)
            WHERE detail_bb_id     = l_bb_id_tab(i)
              AND detail_bb_ovn    = l_bb_ovn_tab(i);

       l_bb_id_tab.DELETE;
       l_bb_ovn_tab.DELETE;
       l_person_tab.DELETE;

    END IF;

    IF g_debug
    THEN
       hr_utility.trace('translate_created_by completed alright');
    END IF;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No Data Found from translate_created_by, something wrong');


END translate_created_by;



-- TRANSLATE_LAST_UPDATED_BY
-- Translates the created by user ids to "user_name(resource_name)" format.

PROCEDURE translate_last_updated_by
AS

  CURSOR get_updated_user  ( p_request_id VARCHAR2)
      IS SELECT /*+ ORDERED */
                det.detail_bb_id,
                det.detail_bb_ovn,
                fnd.user_name||newline||'['||
                ppf.full_name||']'
           FROM hxc_rpt_tc_resource_temp gt,
                hxc_rpt_tc_details_all det,
                fnd_user               fnd,
                per_all_people_f       ppf
          WHERE gt.tc_bb_id           = det.tc_bb_id
            AND gt.request_id         = p_request_id
            AND det.last_updated_by   = fnd.user_id
            AND fnd.employee_id       = ppf.person_id
            AND det.day_start_time BETWEEN ppf.effective_start_date
                                       AND ppf.effective_end_date
            AND det.last_updated_by_user IS NULL ;

   l_bb_id_tab  NUMTABLE;
   l_bb_ovn_tab NUMTABLE;
   l_person_tab VARCHARTABLE;

BEGIN

    -- Public Procedure translate_last_updated_by
    -- Find out user_name for the corresponding user_ids from FND_USER
    --       and full_name from PER_ALL_PEOPLE_F for the employee_ids from
    --       FND_USER.
    -- Update HXC_RPT_TC_DETAILS_ALL with the corresponding values.


    IF g_debug
    THEN
       hr_utility.trace('translate_last_updated_by');
    END IF;



    OPEN get_updated_user(g_request_id);

    FETCH get_updated_user BULK COLLECT INTO l_bb_id_tab,
                                             l_bb_ovn_tab,
                                             l_person_tab ;

    CLOSE get_updated_user;


    IF g_debug
    THEN
       hr_utility.trace('Fetched from get_updated_user ');
       hr_utility.trace('Total number of rows fetched : '||l_bb_id_tab.COUNT);
    END IF;


    IF l_bb_id_tab.COUNT > 0
    THEN
       FORALL i IN l_bb_id_tab.FIRST..l_bb_id_tab.LAST
           UPDATE hxc_rpt_tc_details_all
              SET last_updated_by_user  = l_person_tab(i)
            WHERE detail_bb_id          = l_bb_id_tab(i)
              AND detail_bb_ovn         = l_bb_ovn_tab(i);

       l_bb_id_tab.DELETE;
       l_bb_ovn_tab.DELETE;
       l_person_tab.DELETE;

    END IF;


    IF g_debug
    THEN
       hr_utility.trace('translate_last_updated_by completed alright');
    END IF;


  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         hr_utility.trace('No Data Found from translate_last_updated_by, something wrong');

END translate_last_updated_by;



-- LOG_TIME_CAPTURE
-- Makes an entry in HXC_RPT_TC_HIST_LOG with the timecard identification
-- parameters, for future reference.

PROCEDURE log_time_capture ( p_request_id      IN VARCHAR2,
                             p_request_sysdate IN DATE )
AS

resource_id_tab NUMTABLE;
start_time_tab  DATETABLE;
stop_time_tab   DATETABLE;

BEGIN

     -- Public Procedure log_time_capture
     -- If the timecard is already recorded in HXC_RPT_TC_HIST_LOG, update the
     --        history_till_date column with the request date.
     -- Delete from HXC_RPT_TC_RESOURCE_TEMP all records which are updated as above.
     -- For all the distinct timecard records existing in HXC_RPT_TC_RESOURCE_TEMP,
     --        insert a relevant record into HXC_RPT_TC_HIST_LOG.

     IF g_debug
     THEN
        hr_utility.trace('log_time_capture');
     END IF;


     UPDATE hxc_rpt_tc_hist_log
        SET request_id        = p_request_id,
            history_till_date = p_request_sysdate
      WHERE (resource_id,
             tc_start_time,
             tc_stop_time)
         IN ( SELECT resource_id,
                     tc_start_time,
                     tc_stop_time
                FROM hxc_rpt_tc_resource_temp )
       RETURNING resource_id,
                 tc_start_time,
                 tc_stop_time BULK COLLECT INTO resource_id_tab,
                                                start_time_tab,
                                                stop_time_tab ;

    IF g_debug
    THEN
       hr_utility.trace('Updated hxc_rpt_tc_hist_log ');
       hr_utility.trace('Total Number of timecards updated here : '||resource_id_tab.COUNT);
    END IF;

    IF resource_id_tab.COUNT > 0
    THEN
       FORALL i IN resource_id_tab.FIRST..resource_id_tab.LAST
            DELETE FROM hxc_rpt_tc_resource_temp
                  WHERE resource_id   = resource_id_tab(i)
                    AND tc_start_time = start_time_tab(i)
                    AND tc_stop_time  = stop_time_tab(i);

    END IF;

    INSERT INTO hxc_rpt_tc_hist_log
                 ( resource_id,
                   tc_start_time,
                   tc_stop_time,
                   request_id,
                   history_till_date )
        SELECT resource_id,
               tc_start_time,
               tc_stop_time,
               MIN(p_request_id),
               MIN(p_request_sysdate)
          FROM hxc_rpt_tc_resource_temp
         GROUP BY resource_id,
                  tc_start_time,
                  tc_stop_time;


    resource_id_tab.DELETE;
    start_time_tab.DELETE;
    stop_time_tab.DELETE;


    IF g_debug
    THEN
       hr_utility.trace('log_time_capture completed alright');
    END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF g_debug
       THEN
          hr_utility.trace('No Data Found from log_time_capture ');
       END IF;

END log_time_capture;



-- LOAD_TC_SNAPSHOT
-- Main action block for Load Timecard Snapshot Concurrent Program.


PROCEDURE load_tc_snapshot ( errbuf          OUT NOCOPY VARCHAR2    ,
                             retcode         OUT NOCOPY NUMBER      ,
                             p_date_from     IN  VARCHAR2           ,
                             p_date_to       IN  VARCHAR2           ,
                             p_data_regen    IN  VARCHAR2           ,
                             p_record_save   IN  VARCHAR2           ,
                             p_org_id        IN  NUMBER DEFAULT NULL,
                             p_locn_id       IN  NUMBER DEFAULT NULL,
                             p_payroll_id    IN  NUMBER DEFAULT NULL,
                             p_supervisor_id IN  NUMBER DEFAULT NULL,
                             p_person_id     IN  NUMBER DEFAULT NULL ) AS


CURSOR get_layout_ids
    IS SELECT DISTINCT layout_id
         FROM hxc_rpt_tc_resource_temp;

 l_layout_id    NUMBER(15);
 l_alias_tab    ALIASTAB;
 l_where_clause VARCHAR2(6000);
 timecard_exists NUMBER := 0;

BEGIN


   -- Public Procedure load_tc_snapshot
   -- Get the relevant time filter parameters.
   -- Get the request id and sysdates.
   -- Pass on the parameters to create the resources list ( comma separated, groups
   --        of 20).
   -- If chosen to delete history data and recreate, delete all info from
   --        HXC_RPT_TC_HIST_LOG and HXC_RPT_TC_DETAILS_ALL.
   -- For each valid list of resources picked, execute load_tc_level_info.
   -- Execute fetch_history_from_date to get the date from which history has to
   --        be considered for each timecard.
   -- If chosen to reuse history data, execute update_last_touched_date.
   -- Update the layout_ids for the timecards.
   -- Load the detail and day level info to HXC_RPT_TC_DETAILS_ALL.
   -- Update the timecard comments.
   -- Loop thru all the distinct layout_ids picked out.
   -- For each layout id
   --     * Populate the attributes for the details
   --     * Translate the attributes to user readable format.
   --     * Translate the alias values, if any.
   -- Translate CLA reasons and type, if any.
   -- Update transaction_ids for the records.
   -- Translate the created by user_ids to user_names and employee names.
   -- Translate the last updated by user_ids to user_names and employee names.
   -- Log the time capture for each timecard records in HXC_RPT_TC_HIST_LOG for
   --     future reference.
   -- Clear HXC_RPT_TC_RESOURCE_TEMP, for the next iteration ( next 20 resources ).

   g_request_sysdate := SYSDATE;
   g_request_id      := FND_GLOBAL.CONC_PRIORITY_REQUEST;

   IF g_debug
   THEN
      hr_utility.trace('Load Timecard Snapshot ');
      hr_utility.trace('Parameters');
      hr_utility.trace('==========');
      hr_utility.trace('p_date_from     '||p_date_from);
      hr_utility.trace('p_date_to       '||p_date_to);
      hr_utility.trace('p_data_regen    '||p_data_regen);
      hr_utility.trace('p_record_save   '||p_record_save);
      hr_utility.trace('p_org_id        '||p_org_id);
      hr_utility.trace('p_locn_id       '||p_locn_id);
      hr_utility.trace('p_payroll_id    '||p_payroll_id);
      hr_utility.trace('p_supervisor_id '||p_supervisor_id);
      hr_utility.trace('p_person_id     '||p_person_id);
      hr_utility.trace('Priority Request Id '||g_request_id);
      hr_utility.trace('Request starts execution at '||
                    TO_CHAR(g_request_sysdate,'dd-MON-yyyy HH:MI:SS'));
   END IF;

   resource_where_clause (     p_date_from       =>  fnd_date.canonical_to_date(p_date_from)
                            ,  p_date_to       	 =>  fnd_date.canonical_to_date(p_date_to)
		            ,  p_org_id        	 =>  p_org_id
		            ,  p_locn_id       	 =>  p_locn_id
		            ,  p_payroll_id    	 =>  p_payroll_id
		            ,  p_supervisor_id 	 =>  p_supervisor_id
		            ,  p_person_id     	 =>  p_person_id
                         );

   IF p_data_regen = 'Y'
   THEN
      IF g_debug
      THEN
         hr_utility.trace('Clearing history...');
      END IF;
      clear_history_data;
   END IF;


   DELETE FROM hxc_rpt_tc_resource_temp;

   IF g_debug
   THEN
      hr_utility.trace('Cleared hxc_rpt_tc_resource_temp, just in case the last run crashed');
      hr_utility.trace(SQLCODE);
   END IF;


   FOR i in g_res_list_cs.FIRST..g_res_list_cs.LAST
   LOOP
       -- Bug 9137834
       -- Added the Exception block for list of resources.
       BEGIN
           IF (g_res_list_cs(i) IS NOT NULL) AND (g_res_list_cs(i) <> ' ')
       	   THEN
       	      IF g_debug
       	      THEN
       	         hr_utility.trace('Processing resource list '||i);
       	         hr_utility.trace(g_res_list_cs(i));
       	      END IF;
       	      load_tc_level_info ( p_resource_list    => ltrim(g_res_list_cs(i),'  ,'),
       	                           p_tc_from          => fnd_date.canonical_to_date(p_date_from),
       	                           p_tc_to            => fnd_date.canonical_to_date(p_date_to),
       	                           p_request_id       => g_request_id);


       	      SELECT count(*)
       	        INTO timecard_exists
       	        FROM hxc_rpt_tc_resource_temp
       	       WHERE rownum < 2;

       	      IF timecard_exists = 0
       	      THEN
       	         IF g_debug
       	         THEN
       	            hr_utility.trace('No timecards exist for this resource list ');
       	            hr_utility.trace(g_res_list_cs(i));
       	         END IF;

       	      ELSE

       	         fetch_history_from_date;

       	         IF p_data_regen <> 'Y'
       	         THEN
       	            IF g_debug
       	            THEN
       	               hr_utility.trace('Using history data, so update Last Touched Dates');
       	            END IF;
       	            update_last_touched_date;
       	         END IF;

       	         update_layout_ids;

       	         load_detail_info(p_request_sysdate => g_request_sysdate);

       	         update_timecard_comments;

       	         OPEN get_layout_ids;
       	         LOOP
       	            -- Bug 9137834
       	            -- Added exception handling for layouts so that if
       	            -- one layout fails, the rest continue.
       	            BEGIN
       	                FETCH get_layout_ids
       	            	 INTO l_layout_id;
       	            	EXIT WHEN get_layout_ids%NOTFOUND;

       	            	IF g_debug
       	            	THEN
       	            	   hr_utility.trace('Processing Layout '||l_layout_id);
       	            	END IF;

       	            	  populate_attributes (p_layout_id => l_layout_id,
       	            	                       p_alias_tab => l_alias_tab);

       	            	  translate_attributes(p_layout_id => l_layout_id);

       	            	  translate_aliases   (p_layout_id => l_layout_id,
       	            	                       p_alias_tab => l_alias_tab);

       	             EXCEPTION
       	                  WHEN OTHERS THEN
       	                      hr_utility.trace('Error Stack ');
       	                      hr_utility.trace(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
       	                      hr_utility.trace('Exception '||SQLERRM||' while processing layout '||l_layout_id);
       	            END;

       	         END LOOP;
       	         CLOSE get_layout_ids;

       	         translate_cla_reasons;
       	         update_transaction_ids(p_record_save);
       	         translate_created_by;
       	         translate_last_updated_by;
       	         log_time_capture(p_request_id      => g_request_id,
       	                          p_request_sysdate => g_request_sysdate );

       	         IF g_debug
       	         THEN
       	            hr_utility.trace('Finished processing for resource list '||i);
       	            hr_utility.trace('Clear the resource table and COMMIT the data collection ');
       	         END IF;
       	         DELETE FROM hxc_rpt_tc_resource_temp;
       	         COMMIT;
       	      END IF;

       	   END IF;

        EXCEPTION
           WHEN OTHERS THEN
               hr_utility.trace('Error Stack ');
               hr_utility.trace(DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
               hr_utility.trace('Exception '||SQLERRM||' while processing the following list ');
               hr_utility.trace(g_res_list_cs(i));
       END;


   END LOOP;

   IF g_debug
   THEN
      hr_utility.trace('Request Finishes execution at '||to_char(SYSDATE,'dd-MON-yyyy HH:MI:SS')
                      ||' and took '||ROUND(((SYSDATE-g_request_sysdate)*24*60),2)||' minutes to complete');
   END IF;



 EXCEPTION
    WHEN NO_DATA_FOUND THEN
          NULL;


END load_tc_snapshot;


-- INSERT_QUERIES
-- Used by hxcldvo.lct to load records into HXC_RPT_LAYOUT_COMP_QUERIES.

PROCEDURE insert_queries(p_vo_name VARCHAR2,
                         p_query   VARCHAR2)
AS

  layout_tab      NUMTABLE;
  layout_comp_tab NUMTABLE;
  comp_tab        VARCHARTABLE;
  attribute_tab   VARCHARTABLE;

  CURSOR get_comp_rank ( p_vo_name   VARCHAR2)
  IS SELECT layout_id,
            layout_component_id,
            component_name,
            attribute
       FROM (
             SELECT /*+ INDEX( hlc  HXC_LAYOUT_COMPONENTS_FK1 )
                        INDEX( hlcq HXC_LAYOUT_COMP_QUALIFIERS_FK1) */
                      hlc.layout_id                                           ,
                      hlc.layout_component_id                                 ,
	              REGEXP_REPLACE(hlc.component_name,'.*- ') component_name,
                      hlcq.qualifier_attribute1      vo_name,
		      'ATTRIBUTE'||RANK() OVER ( PARTITION BY hlc.layout_id
        		                             ORDER BY hlc.layout_component_id ) AS attribute
               FROM hxc_layouts                hl,
	            hxc_layout_components      hlc,
        	    hxc_layout_comp_qualifiers hlcq
              WHERE hlc.layout_id                     = hl.layout_id
                AND hl.layout_type                    = 'TIMECARD'
                AND hlcq.layout_component_id          = hlc.layout_component_id
                AND hlcq.qualifier_attribute25        = 'FLEX'
                AND hlcq.qualifier_attribute_category IN ('LOV',
                                                          'CHOICE_LIST',
	                       			          'PACKAGE_CHOICE_LIST',
					                  'TEXT_FIELD',
					                  'DESCRIPTIVE_FLEX')
        ) layout_all
      WHERE layout_all.vo_name = p_vo_name ;


BEGIN


     -- Public Procedure insert_queries
     -- Not used by Load Timecard Snapshot Request.
     -- Used by hxcldvo.lct to load records into HXC_RPT_LAYOUT_COMP_QUERIES
     -- Inserts the relevant layout information and column name of
     --     HXC_RPT_TC_DETAILS_ALL that carries a given component.

     OPEN get_comp_rank ( p_vo_name);

     FETCH get_comp_rank BULK COLLECT
                         INTO  layout_tab,
                               layout_comp_tab,
                               comp_tab,
                               attribute_tab ;
     CLOSE get_comp_rank;

     IF layout_comp_tab.COUNT > 0
     THEN

         FORALL i IN layout_comp_tab.FIRST..layout_comp_tab.LAST
            DELETE FROM hxc_rpt_layout_comp_queries
                  WHERE layout_component_id = layout_comp_tab(i);

         FORALL i IN layout_tab.FIRST..layout_tab.LAST
            DELETE FROM hxc_rpt_layout_comp_queries
                  WHERE layout_id = layout_tab(i)
                    AND attribute = attribute_tab(i);

         FORALL i IN layout_comp_tab.FIRST..layout_comp_tab.LAST
             INSERT INTO hxc_rpt_layout_comp_queries
                         ( layout_id,
                           layout_component_id,
                           component_name,
                           query,
                           attribute )
                  VALUES ( layout_tab(i),
                           layout_comp_tab(i),
                           comp_tab(i),
                           p_query,
                           attribute_tab(i) );


     END IF;




END insert_queries;



END HXC_RPT_LOAD_TC_SNAPSHOT;


/
