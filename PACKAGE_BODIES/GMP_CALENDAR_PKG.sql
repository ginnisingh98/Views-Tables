--------------------------------------------------------
--  DDL for Package Body GMP_CALENDAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMP_CALENDAR_PKG" as
/* $Header: GMPDCALB.pls 120.25.12010000.9 2010/01/29 09:00:10 vpedarla ship $ */

invalid_string_value       EXCEPTION;
v_cp_enabled    BOOLEAN := FALSE;
V_YES           NUMBER := 1;
V_WPS           CONSTANT VARCHAR2(4) := 'WPS';
V_APS           CONSTANT VARCHAR2(4) := 'APS';
V_FROM_RSRC     VARCHAR2(40) ;
V_TO_RSRC       VARCHAR2(16) ;
no_of_secs      CONSTANT REAL := 86400;
p_orgn_code     VARCHAR2(3);

TYPE  ref_cursor_typ is REF CURSOR;

TYPE cal_shift_typ is RECORD
( cal_date    DATE,
  shift_num   PLS_INTEGER,
  from_time   PLS_INTEGER,
  to_time     PLS_INTEGER
);
calendar_record  cal_shift_typ;
TYPE cal_tab is table of cal_shift_typ index by BINARY_INTEGER;
new_rec  cal_tab;

--BUG6732449 Kbanddyo- changed the length of cal_desc from 40 to 240.
TYPE cal_detail_typ is RECORD
(calendar_no     VARCHAR2(16),
 calendar_desc   VARCHAR2(240),
 orgn_code       VARCHAR2(4),
 organization_id PLS_INTEGER,
 posted          PLS_INTEGER
);

cursor_rec  cal_detail_typ;
TYPE tab_cal_typ is table of cal_detail_typ INDEX BY BINARY_INTEGER;
plsqltbl_rec  tab_cal_typ;

PROCEDURE log_message(pBUFF  IN  VARCHAR2) IS
BEGIN
     IF fnd_global.conc_request_id > 0  THEN
         FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);
     ELSE
         null;
     END IF;
EXCEPTION
     WHEN others THEN
        RETURN;
END log_message;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    rsrc_extract                                                          |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    The following procedure rows into msc_st_department_resources         |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_instance_id - Instance Id                                           |
REM|    p_db_link - Database Link                                             |
REM|    return_status - Status return variable                                |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    8/17/99 - Changed to Dynamic SQL , added db_link                      |
REM|    10/13/99 - Added deleted_flag in the insert statement                 |
REM|    11/23/99 - Changed value of aggregate_resource_flag from 1 to 2       |
REM|    01/12/00 - Added owning_department_id column in the Insert statement  |
REM|             - Bug# 1140113                                               |
REM|    4/03/00 - using mtl_organization_id from ic_whse_mst instead of       |
REM|            - organization_id from mtl_parameters - Bug# 1252322          |
REM|    4/18/00 - Fixed Bug# 1273557 - Department count is Zero               |
REM|            - Changes made to the insert statement, changed               |
REM|            - s.organization_id to w.mtl_organization_id                  |
REM|    12/26/01 - Adding Code changes for Resource Utilization and Resource  |
REM|               Efficiency - B2163006                                      |
REM|    12/20/02 - Sridhar Gidugu  B2714583, Populated 3 new columns for      |
REM|                               msc_st_department_resources                |
REM|                               1.Resource_excess_type,                    |
REM|                               2.Resource_shortage_type                   |
REM|                               3.User_time_fence                          |
REM|    01/09/03 - Sridhar Gidugu  Used mrp_planning_exception_sets           |
REM|                               instead of mrp_planning_exception_sets_v   |
REM|                               also added extra join with Organization_id |
REM|    01/22/03 - Sridhar Gidugu  Insert statement for Resource Groups       |
REM|    05/11/03 - Rajesh Patangya Used to_number(NULL) in palce of NULL      |
REM|    05/20/03 - Sridhar Gidugu  B2971120 Populating new columns            |
REM|                               Over_utilized_percent and                  |
REM|                               under_utilized_percent in dept_rsc table   |
REM|  04/21/2004   - Navin Sinha - B3577871 -ST:OSFME2: collections failing   |
REM|                                in planning data pull.                    |
REM|                                Added handling of NO_DATA_FOUND Exception.|
REM|                                And return the return_status as TRUE.     |
REM+==========================================================================+
*/

PROCEDURE rsrc_extract(p_instance_id IN PLS_INTEGER,
                       p_db_link     IN VARCHAR2,
                       return_status OUT NOCOPY BOOLEAN) IS

ins_dept_res     varchar2(25000);
ins_res_group    varchar2(25000);
ins_res_instance varchar2(25000);
dep_ref_cursor ref_cursor_typ;

BEGIN

/*  New changes made for msc_st_department_resources- using mtl_organization_id
    from ic_whse_mst instead of organization_id from mtl_parameters
    table  - Bug # 1252322
    Commented the Where clause resource_whse_code is NOT NULL as whse code in
    ic_whse_mst is never NULL - 04/03/2000
*/
    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

    /* populate the org_string */
     IF gmp_calendar_pkg.org_string(p_instance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;
	/* note that we introduced substr(resources) as the
	final msc table has the column at 10 char only. If and when the MSC
	column width increases we shall remove substr */

    ins_dept_res := ' INSERT INTO msc_st_department_resources '
               || ' ( organization_id,  '
               || ' sr_instance_id, '
               || ' resource_id, '
               || ' department_id, '
               || ' resource_code, '
               || ' resource_description,  '
               || ' department_code, '
               || ' owning_department_id, '
               || ' line_flag, '
               || ' aggregated_resource_flag, '
               || ' capacity_units, '
               || ' available_24_hours_flag, '
               || ' resource_cost,  '
               || ' ctp_flag,     '
               || ' deleted_flag,  '
               || ' resource_excess_type,  '
               || ' resource_shortage_type,  '
               || ' user_time_fence,  '
               || ' over_utilized_percent,  '    /* B2971120 */
               || ' under_utilized_percent,  '   /* B2971120 */
               || ' efficiency,  '
               || ' utilization,  '
               || ' planning_exception_set,  '
               || ' resource_group_name,  '
               || ' bottleneck_flag,  '
               || ' chargeable_flag, '
               || ' capacity_tolerance, '
               || ' batchable_flag, '
               || ' batching_window, '
               || ' min_capacity, '
               || ' max_capacity, '
               || ' unit_of_measure, '
               || ' idle_time_tolerance, '
               || ' sds_scheduling_window, '
               || ' batching_penalty, '
               || ' schedule_to_instance, '
               || ' resource_type ' /*B4487118 - HLINK GC:(RV): MULTIPLE ROWS ARE DISPALYED FOR A RESOURCE IN THE RV*/
               || ') '
               || '  SELECT p.organization_id , '
               || '  :instance_id, '
               || '  ((r.resource_id * 2) + 1),' /* B1177070 encoded */
               || '  ((p.organization_id * 2) + 1) department_id,' /* B1177070 encoded */
               || '  r.resources , '
               || '  m.resource_desc, ' /*Sowmya-Changed from resources to resource_desc*/
               || '  p.organization_code   , '
               || '  ((p.organization_id * 2) + 1)  , ' /* B1177070 */
               || '  2, '            /* Line Flag */
               || '  2, '      /* Yes = 1 and No = 2 resource Flag */
               || '  r.assigned_qty, '
               || '  2, '      /* Avail 24 hrs flag */
               || '  r.nominal_cost, '
               || '  1,'     /* for ATP to check Resources (RDP)*/
               || '  2, '
               || '  mrp.resource_excess_type, '      /*  B2714583 */
               || '  mrp.resource_shortage_type, '    /* B2714583 */
               || '  mrp.user_time_fence, '    /* B2714583 */
               || '  mrp.over_utilized_percent, '    /* B2971120 */
               || '  mrp.under_utilized_percent, '    /* B2971120 */
               || '  r.efficiency, ' /* B2163006 */
               || '  r.utilization, ' /* B2163006 */
               || '  r.planning_exception_set, ' /* B2714583 */
               || '  r.group_resource, '
               || '  NULL, '
               || '  decode(r.capacity_constraint,1,1,2), '
               || '  r.capacity_tolerance, '
               || '  r.batchable_flag, '    /* B4157063 Resource Batching */
               || '  r.batch_window, '      /* B4157063 Resource Batching */
               || '  r.min_capacity, '
               || '  r.max_capacity, '
               || '  r.capacity_um, '
               || '  r.idle_time_tolerence, '
               || '  r.sds_window, '
               || '  NULL, '
            /* If the Resource is scheduled to Instance, then value is Yes else No */
               || '  decode(r.schedule_ind,2,1,2), '
               || '  1 '/*B4487118 - HLINK GC:(RV): MULTIPLE ROWS ARE DISPALYED FOR A RESOURCE IN THE RV*/
/*sowsubra - ME changes - Start*/
/* Replace the use of sy_orgn_mst with mtl_parameters and hr_organization_units */
               || '  FROM   cr_rsrc_dtl'||p_db_link||' r, '
               || '         cr_rsrc_mst'||p_db_link||' m, '
               || '         mrp_planning_exception_sets'||p_db_link||' mrp, '
               || '         mtl_parameters'||p_db_link||' p, '
               || '         hr_organization_units'||p_db_link||' hr '
               || '  WHERE  r.organization_id = p.organization_id '
               || '  AND    r.resources = m.resources '
               || '  AND    p.organization_id = hr.organization_id '
               || '  AND    nvl(hr.date_to,sysdate) >= sysdate '
               || '  AND    r.planning_exception_set = mrp.exception_set_name '
               || '  AND    p.organization_id = mrp.organization_id '
               || '  AND    p.process_enabled_flag = '||''''||'Y'||'''' ;

        IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
         ins_dept_res := ins_dept_res
               ||'   AND p.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
        END IF;
/*sowsubra - ME changes - End*/

         ins_dept_res := ins_dept_res
               || '  AND    r.delete_mark = 0 '
               || '  UNION ALL '
               || '  SELECT p.organization_id , '
               || '  :instance_id1, '
               || '  ((r.resource_id * 2) + 1),' /* B1177070 encoded */
               || '  ((p.organization_id * 2) + 1),' /* B1177070 encoded */
               || '  r.resources ,'
               || '  m.resource_desc, ' /*Sowmya-Changed from resources to resource_desc*/
               || '  p.organization_code   , '
               || '  ((p.organization_id * 2) + 1)  , ' /* B1177070 */
               || '  2, '            /* Line Flag */
               || '  2, '      /* Yes = 1 and No = 2 resource Flag */
               || '  r.assigned_qty, '
               || '  2, '      /* Avail 24 hrs flag */
               || '  r.nominal_cost, '
               || '  1,'     /* for ATP to check Resources (RDP)*/
               || '  2, '
               || '  to_number(NULL), '      /*  B2714583 */
               || '  to_number(NULL), '      /*  B2714583 */
               || '  to_number(NULL), '      /*  B2714583 */
               || '  to_number(NULL), '      /*  B2971120 */
               || '  to_number(NULL), '      /*  B2971120 */
               || '  r.efficiency, ' /* B2163006 */
               || '  r.utilization, ' /* B2163006 */
               || '  r.planning_exception_set, ' /* B2714583 */
               || '  r.group_resource, '
               || '  NULL, '
               || '  decode(r.capacity_constraint,1,1,2), '
               || '  r.capacity_tolerance, '
               || '  r.batchable_flag, '    /* B4157063 Resource Batching */
               || '  r.batch_window, '      /* B4157063 Resource Batching */
               || '  r.min_capacity, '
               || '  r.max_capacity, '
               || '  r.capacity_um, '
               || '  r.idle_time_tolerence, '
               || '  r.sds_window, '
               || '  NULL, '
       /* If the Resource is scheduled to Instance, then value is Yes else No */
               || '  decode(r.schedule_ind,2,1,2), '
               || '  1 ' /*B4487118 - HLINK GC:(RV): MULTIPLE ROWS ARE DISPALYED FOR A RESOURCE IN THE RV*/
               || '  FROM   cr_rsrc_dtl'||p_db_link||' r, '
/*sowsubra - ME changes - Start*/
/* Replace the use of sy_orgn_mst with mtl_parameters and hr_organization_units */
               || '         mtl_parameters'||p_db_link||' p, '
               || '         cr_rsrc_mst'||p_db_link||' m, '
               || '         hr_organization_units'||p_db_link||' hr '
               || '  where  r.organization_id = p.organization_id '
               || '  AND    r.resources = m.resources '
               || '  AND    r.planning_exception_set IS NULL '
               || '  AND    p.organization_id = hr.organization_id '
               || '  AND    nvl(hr.date_to,sysdate) >= sysdate '
               || '  AND    p.process_enabled_flag = '||''''||'Y'||''''
               || '  AND    r.delete_mark = 0 ' ;

        IF gmp_calendar_pkg.g_in_str_org IS NOT NULL THEN
         ins_dept_res := ins_dept_res
               ||'   AND p.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
        END IF;
/*sowsubra - ME changes - end*/
         EXECUTE IMMEDIATE  ins_dept_res USING p_instance_id, p_instance_id;

    /* Insert into MSC_ST_RESOURCE_GROUPS for Bottleneck Resources
       Sending only those resources that are used in Planning for APS
    */
    ins_res_group := ' INSERT INTO msc_st_resource_groups '
          || ' ( group_code,  '
          || '   meaning, '
          || '   description,  '
          || '   from_date,  '
          || '   to_date,  '
          || '   enabled_flag,  '
          || '   sr_instance_id '
          || ' ) '
          || '   SELECT distinct crd.group_resource , '
          || '   crm.resource_desc,'
          || '   crm.resource_desc,'
          || '   sysdate,'
          || '   NULL,'
          || '   1,'
          || '   :instance_id '
/*sowsubra - ME changes - Start*/
          || '  FROM   mtl_parameters'||p_db_link||' p, '
          || '         hr_organization_units'||p_db_link||' hr, '
          || '         cr_rsrc_dtl'||p_db_link||' crd, '
          || '         cr_rsrc_mst'||p_db_link||' crm '
          || '  WHERE  p.organization_id = crd.organization_id '
          || '  AND    p.organization_id = hr.organization_id '
          || '  AND    nvl(hr.date_to,sysdate) >= sysdate '
          || '  AND    p.process_enabled_flag = '||''''||'Y'||''''
          || '  AND    crd.resources = crm.resources '
          || '  AND    crd.group_resource = crm.resources '
          || '  AND    crd.delete_mark = 0 ';

        IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
         ins_res_group := ins_res_group
          ||'   AND EXISTS ( SELECT 1 FROM mtl_system_items'||p_db_link||' msi'
          ||'   WHERE msi.organization_id = p.organization_id )' ;
        END IF;
/*sowsubra - ME changes - End*/

         EXECUTE IMMEDIATE  ins_res_group USING p_instance_id;

	/* Now extract the resource instances too -
	The instance extraction was put under resource avaialbility extraction
	but to keep it in synch with Discrete collection, it is being
	moved here. */

     ins_res_instance := ' INSERT INTO msc_st_dept_res_instances '
         ||' ( sr_instance_id, '
         ||'   res_instance_id, '
         ||'   resource_id, '
         ||'   department_id, '
         ||'   organization_id, '
         ||'   serial_number, '
         ||'   equipment_item_id, '
         ||'   last_known_setup, '
         ||'   effective_start_date, '
         ||'   effective_end_date, '
         ||'   deleted_flag '
         ||' ) '
	 ||' SELECT :instance_id, '
	 ||'   ((gri.instance_id * 2) + 1), '
	 ||'   ((gri.resource_id * 2) + 1) x_resource_id,  '
	 ||'   ((m.organization_id * 2) + 1) department_id, ' /* encoded */
	 ||'   m.organization_id,  '
	 ||'   NVL(gri.eqp_serial_number, to_char(gri.instance_number)),  '
	 ||'   gri.equipment_item_id,  '
	 ||'   gri.last_setup_id, ' -- Conc Prog routine will populate this
	 ||'   gri.eff_start_date,  '
	 ||'   gri.eff_end_date, '
         ||'   2 '
	 ||' FROM  '
 	 ||'   gmp_resource_instances'||p_db_link||' gri,  '
	 ||'   cr_rsrc_dtl'||p_db_link||' c, '
         ||'   hr_organization_units'||p_db_link||' hr, '
	 ||'   mtl_parameters'||p_db_link||' m '
	 ||' WHERE  '
	 ||'   gri.resource_id = c.resource_id '
         || '  AND m.organization_id = hr.organization_id '
         || '  AND nvl(hr.date_to,sysdate) >= sysdate '
         ||'   AND c.schedule_ind = 2 '
	 ||'   AND c.organization_id = m.organization_id  '
	 ||'   AND m.process_enabled_flag = '||''''||'Y'||''''
	 ||'   AND gri.inactive_ind = 0  '
         ||'   AND c.delete_mark = 0 ';

     IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
         ins_res_instance := ins_res_instance
             ||'   AND m.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
     END IF;

     EXECUTE IMMEDIATE  ins_res_instance USING p_instance_id;

    return_status := TRUE;

EXCEPTION
     WHEN invalid_string_value  THEN
        log_message('APS string is Invalid, check for Error condition' );
        return_status := FALSE;
     WHEN NO_DATA_FOUND THEN /* B3577871 */
        log_message('NO_DATA_FOUND exception raised in Procedure: Gmp_calendar_pkg.Rsrc_extract ' );
        return_status := TRUE;
     WHEN  OTHERS THEN
        log_message('Error in department/Res Group Insert: '||p_instance_id);
        log_message(sqlerrm);
        return_status := FALSE;

END rsrc_extract;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    populate_rsrc_cal                                                     |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_org_id - Organization id                                            |
REM|    p_cal_id - calendar_id                                                |
REM|    p_instance_id - Instance Id                                           |
REM|    p_delimiter - Delimiter                                               |
REM|    p_db_link - Data Base Link                                            |
REM|    p_nra_enabled - flag to build net resource available                  |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    9/1/99 - Main Proc calls the populate_cal_dates                       |
REM|             Update trading Partners and net_rsrc_insert procedure.       |
REM|                                                                          |
REM|    9/7/99 - Changed the Main Procedure, removed UNION ALL for main cursor|
REM|    9/28/99 - Changed the main query ordering by Organization Id and      |
REM|            - changed logic for populating plsqltbl                       |
REM|    4/03/00 - using mtl_organization_id from ic_whse_mst instead of       |
REM|            - organization_id from mtl_parameters - Bug# 1252322          |
REM|    5/03/00 - Add instance code as a prefix to the calendar code          |
REM|            - Bug # 1288143                                               |
REM|    7/07/00 - Anchor Date Problem Fixed in the Calendar Code              |
REM|            - Bug # 1337084.                                              |
REM|    7/12/00 - Removed the Debugging Statement shcl.calendar_id in         |
REM|            - (121,126) - bug#1353845                                     |
REM|    10/18/01 - B2041247 - Modified the cursor to consider Calendars       |
REM|            associated with the OPM Plants                                |
REM|                                                                          |
REM|    7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix    |
REM|  04/21/2004   - Navin Sinha - B3577871 -ST:OSFME2: collections failing   |
REM|                                in planning data pull.                    |
REM|                                Added handling of NO_DATA_FOUND Exception.|
REM|                                And return the return_status as TRUE.     |
REM|                                                                          |
REM|   07-May-2004 - Sowmya - B3599089 - ST: ORG SPECIFIC COMPLETE COLLETION  |
REM|                          FOR OPM ORGS TAKING MORE TIME.                  |
REM|                          As the varaibale l_org_specific was not getting |
REM|                          refreshed,the resource availability             |
REM|                          was getting collected irrespective of whether or|
REM|                          not the org is enabled. To overcome this, added |
REM|                          if clause containing the l_cur%NOTFOUND.So when |
REM|                          the no values are returned the l_org_specific= 0|
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE populate_rsrc_cal(p_run_date    IN date,
                            p_instance_id IN PLS_INTEGER,
                            p_delimiter   IN varchar2,
                            p_db_link     IN varchar2,
                            p_nra_enabled IN NUMBER,
                            return_status OUT NOCOPY BOOLEAN) IS

union_cal_ref   ref_cursor_typ;
upd_res_avl     varchar2(25000);
inst_resavl     varchar2(25000);
sql_allcal      varchar2(25000);
sql_regen       varchar2(25000);
inst_stmt       varchar2(25000);
ins_res_avl     varchar2(25000);
ins_res_shft    varchar2(25000);
Upd_Process_Org varchar2(25000);
stmt_no         integer;
l_prev_calendar VARCHAR2(14) ;
l_calendar_no 	VARCHAR2(14) ;
v_icode         varchar2(4);
simulation_set  varchar2(10) ;
v_errbuf        varchar2(2000) ;
v_retcode       number ;
res_passed      varchar2(40);

BEGIN

v_icode         := '';
simulation_set  := NULL;
ins_res_shft    := NULL;
inst_resavl     := NULL;
upd_res_avl     := NULL;
sql_allcal 	:= NULL;
sql_regen       := NULL;
ins_res_avl     := NULL;
Upd_Process_Org := NULL;
l_prev_calendar := NULL;
l_calendar_no 	:= NULL;
v_errbuf        := null;
v_retcode       := 0;

log_message(' Into populate_rsrc_cal ');
time_stamp;

     /* Following statements are added to include the instance Code as
        a Prefix to the Calendar Code, this done to maintain the uniqueness
        of a calendar code across instances, prior to this change the
        calendar code was not prefixed with Instance code and this caused
        unique constraint problems - Bug# 1288143
     */

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

    /* Retrieving the Instance code from MSC_APPS_INSTANCES table - Bug#1288143 */
     stmt_no := 05;
     inst_stmt :=  '  SELECT instance_code '
                 || '  FROM   msc_apps_instances'
                 || '  WHERE  instance_id = :instance_id ';

     EXECUTE IMMEDIATE inst_stmt INTO v_icode USING p_instance_id ;
     stmt_no := 10;

    /* populate the org_string */
     IF gmp_calendar_pkg.org_string(p_instance_id) THEN
        NULL ;
     ELSE
        RAISE invalid_string_value  ;
     END IF;
     /* mtl_parameters.organization_id - Bug# 1252322 */

    /* Select All the calendars which have calendar_code associated with
       resources and if not associated then organization calendar_code  */
      stmt_no := 15;
           sql_allcal := sql_allcal
                 || ' SELECT unique cal.calendar_code, '
                 || ' cal.description, '
                 || ' mp.organization_code, '
                 || ' mp.organization_id organization_id, '
                 || ' 0  '
                 || ' FROM bom_calendars'||p_db_link||' cal, '
                 || '      hr_organization_units'||p_db_link||' hr, '
                 || '      mtl_parameters'||p_db_link||' mp, '
                 || '      cr_rsrc_dtl'||p_db_link||' crd  '
                 || ' WHERE mp.organization_id = hr.organization_id '
                 || ' AND   nvl(hr.date_to,sysdate) >= sysdate '
                 || ' AND   mp.process_enabled_flag = '||''''||'Y'||''''
                 || ' AND   crd.organization_id = mp.organization_id '
                 || ' AND   NVL(crd.calendar_code,mp.calendar_code)=cal.calendar_code'
                 || ' AND   crd.delete_mark = 0 ' ;

       IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
           sql_allcal := sql_allcal
                 ||'   AND mp.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
       END IF;
           sql_allcal := sql_allcal
                 || ' ORDER BY 1,4 ';

     stmt_no := 20;
     OPEN  union_cal_ref FOR sql_allcal ;
     LOOP
        FETCH union_cal_ref INTO cursor_rec;
        EXIT WHEN union_cal_ref%NOTFOUND;

	IF l_prev_calendar is NULL OR
	   l_prev_calendar <> cursor_rec.calendar_no THEN
	   l_prev_calendar := cursor_rec.calendar_no ;
	   l_calendar_no := v_icode ||':'||cursor_rec.calendar_no ;

       log_message(l_calendar_no ||'**'|| cursor_rec.organization_id);
       time_stamp;

	   retrieve_calendar_detail(l_calendar_no,
                                    cursor_rec.calendar_no,
                                    p_run_date,
                                    p_db_link,
                                    p_instance_id,
                                    V_APS,
                                    return_status
                                    );
	END IF ;
	update_trading_partners(cursor_rec.organization_id,
                                   l_calendar_no,
                                   return_status
                                   );
	IF p_nra_enabled = 3 THEN
        /* REGENERATE THE CALENDAR AND THEN INSERT IT INTO MSC TABLE */
        res_passed := 'DONOT_RETRIEVE_CALENDAR' ;

       log_message(' Calling resource calendar recalculate ' );
       time_stamp;

	sql_regen :=  sql_regen ||' begin '
                         ||' gmp_calendar_pkg.insert_gmp_resource_avail'||p_db_link
                         ||'    (:p1, '
		         ||'	 :p2, '
		         ||'	 :p3, '
		         ||'	 :p4, '
		         ||'	 NULL, '
		         ||'	 :p5); '
       		         ||' end ; '  ;

         EXECUTE IMMEDIATE  sql_regen USING
                                OUT v_errbuf ,
		            	OUT v_retcode,
		            	cursor_rec.organization_id  ,
		            	res_passed,
		            	cursor_rec.calendar_no ;
	END IF ;
        log_message(' After Source Call = ' || v_errbuf ||  ' REG '|| v_retcode );
        time_stamp;
        sql_regen := NULL;

     END LOOP; /* End loop for Main Cursor */

     CLOSE union_cal_ref;

     /* B4751574 Rajesh All the process orgs should have organization_type=2 */
      BEGIN
       stmt_no := 29 ;
       Upd_Process_Org := 'UPDATE MSC_ST_TRADING_PARTNERS'
       ||' SET organization_type = 2'
       ||' WHERE sr_tp_id in (SELECT organization_id '
       ||'                    FROM  mtl_parameters'||p_db_link
       ||'                    WHERE process_enabled_flag = '||''''||'Y'||'''' || ')'
       ||' AND partner_type = 3' ;

       EXECUTE IMMEDIATE  Upd_Process_Org;
       log_message('Trading Partner Update is Done' );
       time_stamp;

      EXCEPTION
        WHEN NO_DATA_FOUND THEN
           NULL ;
        WHEN OTHERS THEN
          log_message('Error in UPDATE TRADING_PARTNERS  '||stmt_no);
          log_message(SQLERRM);
          return_status := FALSE;
      END ;

     /* ======================= Staging table Inserts ===================*/

       stmt_no := 30;
       ins_res_avl := ' INSERT INTO msc_st_net_resource_avail '
            || '       ( organization_id, '
            || '         sr_instance_id, '
            || '         resource_id, '
            || '         department_id, '
            || '         simulation_set, '
            || '         shift_num, '
            || '         shift_date, '
            || '         from_time, '
            || '         to_time, '
            || '         capacity_units, '
            || '         deleted_flag '
            || '       ) '
            || '    SELECT '
            || '         gra.organization_id,  '
            || '         :instance_id, '
            || '         ((gra.resource_id*2)+1), '
            || '         ((gra.organization_id*2)+1) department_id, ' /* encoded */
            || '         :simulation_set, '
            || '         gra.shift_num, '
            || '         gra.shift_date, '
            || '         gra.from_time, '
            || '         gra.to_time, '
            || '         gra.resource_units, '
            || '         2 '
            || '    FROM '
            || '         gmp_resource_avail'||p_db_link||' gra, '
            || '         mtl_parameters'||p_db_link||'  m,   '
            || '         cr_rsrc_dtl'||p_db_link||'  crd   '
            || '    WHERE nvl(gra.resource_instance_id,0) = 0 '
            || '      AND nvl(crd.calendar_code,m.calendar_code) = gra.calendar_code '
            || '      AND gra.organization_id = crd.organization_id   '
            || '      AND gra.organization_id = m.organization_id   '
            || '      AND gra.resource_id = crd.resource_id   '
            || '      AND m.process_enabled_flag = '||''''||'Y'||''''
            || '      AND crd.delete_mark  = 0 ';

       IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
           ins_res_avl := ins_res_avl
            ||'       AND gra.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
       END IF;

     EXECUTE IMMEDIATE ins_res_avl USING p_instance_id, simulation_set;
     log_message('Resource Calendar Insertion Is Done' );
     time_stamp;

       stmt_no := 31;
       inst_resavl := ' INSERT INTO msc_st_net_res_inst_avail '
            || '       ( res_instance_id, '
            || '         serial_number, '
            || '         equipment_item_id, '
            || '         Organization_Id, '
            || '         Resource_Id, '
            || '         Shift_Num, '
            || '         Shift_Date, '
            || '         From_Time, '
            || '         To_Time, '
            || '         Department_id, '
            || '         sr_instance_id '
            || '       ) '
            || '       SELECT  '
            || '         ((gri.instance_id*2)+1), '
            || '         NVL(gri.eqp_serial_number, to_char(gri.instance_number)), '
            || '         gri.equipment_item_id, '
            || '         gra.organization_id, '
            || '         ((gra.resource_id*2)+1), ' /* B4223622 */
            || '         gra.shift_num, '
            || '         gra.shift_date, '
            || '         gra.from_time, '
            || '         gra.to_time, '
            || '         ((gra.organization_id*2)+1) department_id, '/* encoded */
            || '         :instance_id '
            || '    FROM '
            || '         gmp_resource_instances'||p_db_link||' gri, '
            || '         gmp_resource_avail'||p_db_link||' gra, '
            || '         mtl_parameters'||p_db_link||'  m,   '
            || '         cr_rsrc_dtl'||p_db_link||'  crd   '
            || '   WHERE gri.resource_id = gra.resource_id '
            || '     AND gri.instance_id = gra.resource_instance_id '
            || '     AND gri.inactive_ind = 0 '
            || '     AND nvl(crd.calendar_code,m.calendar_code) = gra.calendar_code '
            || '     AND gra.organization_id = crd.organization_id   '
            || '     AND gra.organization_id = m.organization_id   '
            || '     AND gra.resource_id = crd.resource_id   '
            || '     AND m.process_enabled_flag = '||''''||'Y'||''''
            || '     AND crd.delete_mark  = 0 ';

       IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
           inst_resavl := inst_resavl
            ||'      AND gra.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
       END IF;

     EXECUTE IMMEDIATE inst_resavl USING p_instance_id;
     log_message('Resource Calendar Instance Insertion Is Done' );
     time_stamp;

	/* Insert for msc_st_resource_shifts Starts here - 2213101 */
        -- bug: 8486550 Vpedarla modified the shift_num column insertion for msc_st_resource_shifts

       stmt_no := 32;
       ins_res_shft := ' INSERT INTO msc_st_resource_shifts '
               || '       ( department_id,                  '
               || '         shift_num,                      '
               || '         resource_id,                    '
               || '         deleted_flag,                   '
               || '         sr_instance_id,                 '
               || '         capacity_units                  '
               || '       )                                 '
               || ' SELECT unique '
               || '         ((m.organization_id*2)+1) , ' /* encoded */
               || '         decode(sign(gtmp.shift_num - 99999),0,0,1,(gtmp.shift_num - 99999),-1 ,gtmp.shift_num), '
               || '         ((crd.resource_id*2)+1),  '
               || '         2,                        '
               || '         :instance_id,             '
               || '         crd.assigned_qty          '
               || ' FROM  gmp_calendar_detail_gtmp'||p_db_link||'  gtmp, '
               || '       mtl_parameters'||p_db_link||'  m,   '
               || '       cr_rsrc_dtl'||p_db_link||'  crd   '
               || ' WHERE NVL(crd.calendar_code,m.calendar_code) = gtmp.calendar_code '
               || ' AND   m.organization_id = crd.organization_id   '
               || ' AND   m.process_enabled_flag = '||''''||'Y'||''''
               || ' AND   crd.delete_mark  = 0 ';

       IF gmp_calendar_pkg.g_in_str_org  IS NOT NULL THEN
           ins_res_shft := ins_res_shft
               ||'  AND  m.organization_id ' || gmp_calendar_pkg.g_in_str_org ;
       END IF;

     EXECUTE IMMEDIATE ins_res_shft USING p_instance_id;
     log_message('Resource Shift Insertion Is Done' );
     time_stamp;

     stmt_no := 33;
     upd_res_avl := 'UPDATE msc_st_net_resource_avail '
         ||' SET to_time   = 86400 '
         ||' WHERE to_time = 86399 '
         ||'   AND shift_num >= 99999 ' ;
     EXECUTE IMMEDIATE upd_res_avl;

     stmt_no := 34;
     upd_res_avl := NULL ;
     upd_res_avl := 'UPDATE msc_st_net_resource_avail '
         ||' SET shift_num = (shift_num - 99999) '
         ||' WHERE shift_num >= 99999 ' ;
     EXECUTE IMMEDIATE upd_res_avl;
     COMMIT ;

     return_status := TRUE;
     log_message(' Done populate_rsrc_cal ');
     time_stamp;

EXCEPTION
    WHEN invalid_string_value  THEN
      log_message('APS string is Invalid, check for Error condition' );
      return_status := FALSE;
    WHEN NO_DATA_FOUND THEN /* B3577871 */
      log_message(' NO_DATA_FOUND exception : Gmp_calendar_pkg.Populate_rsrc_cal ' );
      return_status := TRUE;
    WHEN OTHERS THEN
      log_message('Error in Populate Rsrc cal construct: '||stmt_no);
      log_message('Error : '||v_icode);
      log_message(SQLERRM);
      return_status := FALSE;

END populate_rsrc_cal;  /* End of Main Procedure */

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    update_trading_partners                                               |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|    This procedure updates the following table :                          |
REM|                                                                          |
REM|                      1. msc_st_trading_partners                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_org_id - Organization_id                                            |
REM|    p_cal_code - Calendar_code                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    8/30/99 - Removed the existing Trading Partner Procedure and changed  |
REM|              to a single Update Procedure.                               |
REM|    10/1/99 - Changed Updating Trading Partners,                          |
REM|            - Updated Organization_typw with a value 2 and changed        |
REM|            - partner_type = 3                                            |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE update_trading_partners(p_org_id      IN PLS_INTEGER,
                                  p_cal_code    IN varchar2,
                                  return_status OUT NOCOPY BOOLEAN) IS
BEGIN

    IF return_status THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

    -- The Following Update statement the Trading Parters table with the
    -- Calendar Code for the Organization that uses the Calendar.
      UPDATE MSC_ST_TRADING_PARTNERS
-- No need to update calendar code B5926204 Rajesh Patangya
--    SET calendar_code = p_cal_code,
      SET organization_type = 2
      WHERE sr_tp_id = p_org_id
      AND partner_type = 3;


      return_status := TRUE;
EXCEPTION
    WHEN OTHERS THEN
      log_message('Failure:Trading Partners Update Occured ');
      return_status := FALSE;

end update_trading_partners; /* End of Updating Trading partners */

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    retrieve_calendar_detail                                              |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_org_id - Organization id                                            |
REM|    p_cal_id - calendar_id                                                |
REM|    p_instance_id - Instance Id                                           |
REM|    p_delimiter - Delimiter                                               |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created 5th Aug 1999 by Sridhar Gidugu (OPM Development Oracle US)    |
REM|    9/20/99 - created the Retrieve calendar Procedure                     |
REM|    10/13/99 - Added deleted_flag in the insert statement                 |
REM|    10/18/99 - Changed value of Exception set Id from 1 to -1             |
REM|    12/09/99 - Added Code to include all Calendar Days                    |
REM|    12/17/99 - Fixed Code for Bug# 1117565                                |
REM|    02/01/00 - next seq and prior seqs are made same as seq number in     |
REM|             - msc_calendar_dates insert, bug#1175906                     |
REM|             - similarly for next date and prior date are same as calendar|
REM|             - dates                                                      |
REM|    03/01/00 - Added Code to not to include rows which have               |
REM|               shift_duration as zero seconds - Bug#1221285               |
REM|    03/20/03 - Added Inserts to msc_st_shift_times table - 2213101        |
REM|    03/20/03 - Added Inserts to msc_st_shift_dates table - 2213101        |
REM|                                                                          |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE retrieve_calendar_detail( p_calendar_code IN VARCHAR2,
                                    p_cal_desc      IN VARCHAR2,
                                    p_run_date      IN DATE,
                                    p_db_link       IN VARCHAR2,
                                    p_instance_id   IN PLS_INTEGER,
                                    p_usage         IN VARCHAR2,
                                    return_status   OUT NOCOPY BOOLEAN) IS
  n_calendar_code varchar2(40);
  cal_count       number ;
  cal_start_date  date;
  cal_end_date    date;
  get_shift_time  varchar2(15000);
  sql_cal         varchar2(15000);
  cal_cur         ref_cursor_typ;
  i               integer ;
  j               integer ;
  stmt_no         integer ;
  wps_index       integer ;
  ins_stmt        VARCHAR2(10000) ;
  ins_stmt1       VARCHAR2(10000) ;
  temp_from_date  DATE ;
  temp_to_date    DATE ;
  temp_to_time    NUMBER ;
  temp_shift_num  NUMBER ;

  TYPE w_st_dt IS TABLE OF bom_cal_week_start_dates.week_start_date%TYPE;
  week_st_date w_st_dt ;

  TYPE w_next_dt IS TABLE OF bom_cal_week_start_dates.week_start_date%TYPE;
  week_next_date w_next_dt ;

BEGIN
log_message(' retrieve_calendar_detail begin ');
time_stamp;
 /* 12/13/02 - Rajesh Patangya B2710601, Added database link  */
  i              := 0;
  j              := 0;
  cal_count      := 0;
  wps_index      := 0;
  ins_stmt       := null;
  get_shift_time := null;
  sql_cal        := null;
  ins_stmt       := null;
  ins_stmt1      := null;
  temp_from_date := null ;
  temp_to_date   := null ;
  temp_to_time   := 0 ;
  temp_shift_num := 0 ;

    /* Insert for Net Resource starts here, The following select statement gets
      the period that are availble for a given calendar, From time and To Time
      are taken in seconds here.
    */

    IF return_status
    THEN
       v_cp_enabled := TRUE;
    ELSE
       v_cp_enabled := FALSE;
    END IF;

       sql_cal := ' SELECT sd.shift_date calendar_date, '
	       || '        sd.shift_num shift_no, '
	       || '        st.from_time from_time, '
	       || '        st.to_time to_time '
               || ' FROM   bom_calendars'||p_db_link||' cal, '
	       || '        bom_shift_dates'||p_db_link||' sd, '
               || '        bom_shift_times'||p_db_link||' st '
               || ' WHERE  cal.calendar_code = :curr_cal_code '
               || ' AND sd.calendar_code = cal.calendar_code '
               || ' AND st.calendar_code = sd.calendar_code '
               || ' AND sd.shift_num = st.shift_num '
               || ' AND sd.seq_num is not null '
               || ' ORDER BY  calendar_date,from_time,to_time  ';

       IF new_rec.COUNT > 0
       THEN
          new_rec.delete;
       END IF;

       /*Sowmya - nra_enabled changes - added this chk as the code is
	 passed in as description here only*/

       stmt_no := 10;
       IF p_usage ='APS' THEN
       /*Sowmya - Also introduced a new variable to hold the calendar code to
         be inserted in gtmp table. The gtmp table will have the calendar code
         thats not associated to the instance. This change has been
         done esp. when the user choses to generate and collect the resource
         data. */
           n_calendar_code := p_cal_desc;
           OPEN cal_cur FOR sql_cal USING p_cal_desc;
         log_message('For APS means gmp +MSC rsce avail table');
         log_message(n_calendar_code || '-' || p_cal_desc);
       ELSE
           log_message('For WPS means gmp reosurce avail only table');
           log_message(p_calendar_code || '-' || p_cal_desc);
           n_calendar_code := p_calendar_code;
           OPEN cal_cur FOR sql_cal USING p_calendar_code;
       END IF;

     stmt_no := 20;
     i := 0;
     LOOP
       FETCH cal_cur INTO  calendar_record;
       EXIT WHEN cal_cur%NOTFOUND;

       /*  Check for the First record  */
       IF i = 0 THEN

         /*  Check if the first row to time is spilling over  */
         IF calendar_record.to_time  <  calendar_record.from_time THEN
           i := i + 1;
           new_rec(i).cal_date := calendar_record.cal_date ;
           log_message(calendar_record.cal_date);
           new_rec(i).shift_num := calendar_record.shift_num ;
           new_rec(i).from_time := calendar_record.from_time;
           new_rec(i).to_time := no_of_secs ;

         /* Add more record for the spilled over shift  */

           i := i +1 ;
           new_rec(i).cal_date := calendar_record.cal_date + 1 ;
           new_rec(i).shift_num := calendar_record.shift_num ;
           new_rec(i).from_time := 0 ;
           new_rec(i).to_time := calendar_record.to_time;
         ELSE
           /* Else Store the values in the PL/sql table */

           i := i + 1;
           new_rec(i).cal_date := calendar_record.cal_date ;
           new_rec(i).shift_num := calendar_record.shift_num ;
           new_rec(i).from_time := calendar_record.from_time;
           new_rec(i).to_time := calendar_record.to_time;

         END IF;

       /*   If not the first record, then check if the Calendar date
            is greater than the Previous cal date in the PL/sql table */
     ELSE
       IF calendar_record.cal_date >  new_rec(i).cal_date  THEN

          /*  Check if the Date, to_time is spilling over */
         IF calendar_record.to_time  <  calendar_record.from_time  THEN
           i := i + 1;
           new_rec(i).cal_date := calendar_record.cal_date;
           new_rec(i).from_time := calendar_record.from_time;
           new_rec(i).shift_num := calendar_record.shift_num;
           new_rec(i).to_time := no_of_secs;

          /* Add more record for the spilled over shift  */
             i := i + 1;
             new_rec(i).cal_date := calendar_record.cal_date + 1;
             new_rec(i).shift_num := calendar_record.shift_num;
             new_rec(i).from_time := 0;
             new_rec(i).to_time := calendar_record.to_time ;
         ELSE
             /* Else Store the values in the PL/sql table */

             i := i + 1 ;
             new_rec(i).cal_date := calendar_record.cal_date ;
             new_rec(i).shift_num := calendar_record.shift_num ;
             new_rec(i).from_time := calendar_record.from_time;
             new_rec(i).to_time := calendar_record.to_time;

         END IF;

       /*  If not the first record, then check if the Calendar date
           is equal to the Previous cal date in the PL/sql table */

     ELSIF calendar_record.cal_date =  new_rec(i).cal_date THEN

        /*  Checking if the Cursor from_time is greater than Previous record to_time */

          IF calendar_record.from_time >  new_rec(i).to_time  THEN
             /*  Check if the Date, to_time is spilling over */
             IF calendar_record.to_time  <  calendar_record.from_time  THEN
               i := i + 1;
               new_rec(i).cal_date := calendar_record.cal_date;
               new_rec(i).from_time := calendar_record.from_time;
               new_rec(i).shift_num := calendar_record.shift_num;
               new_rec(i).to_time := no_of_secs;

           /*  Add more record for the spilled over shift  */
                 i := i + 1;
                 new_rec(i).cal_date := calendar_record.cal_date + 1 ;
                 new_rec(i).from_time := 0 ;
                 new_rec(i).shift_num := calendar_record.shift_num;
                 new_rec(i).to_time := calendar_record.to_time ;
             ELSE
                i := i + 1;
                new_rec(i).cal_date := calendar_record.cal_date ;
                new_rec(i).shift_num := calendar_record.shift_num ;
                new_rec(i).from_time := calendar_record.from_time;
                new_rec(i).to_time := calendar_record.to_time;
            END IF ;
         ELSE      /* Merge time !!!
                      Shifts Merge is the start time of the shift is Less than
                      the Previous record to_time
               Checking if the record that is Merged is spilling Over to next day */
             IF calendar_record.to_time < calendar_record.from_time THEN
                new_rec(i).to_time := no_of_secs ;
               /* Add more record for the spilled over shift  */
                 i := i + 1;
                 new_rec(i).cal_date := calendar_record.cal_date + 1;
                 new_rec(i).from_time := 0 ;
                 new_rec(i).shift_num := calendar_record.shift_num;
                 new_rec(i).to_time := calendar_record.to_time ;
              ELSE
                IF  calendar_record.to_time > new_rec(i).to_time THEN
                  new_rec(i).to_time := calendar_record.to_time ;
                END IF ;
              END IF  ;
          END IF ; /* End OF Merge time  */

       /*  checking if the Calendar date is less than the Previous cal date
           in the PL/sql table This check is useful when two shifts in a day
           are crossing Midnight Then in that case we need to compare the start
           time with the Previously completed shift end time and the dates too. */

        ELSIF calendar_record.cal_date <  new_rec(i).cal_date THEN
            IF calendar_record.to_time > no_of_secs THEN
              IF calendar_record.to_time - no_of_secs > new_rec(i).to_time THEN
                 new_rec(i).to_time := calendar_record.to_time - no_of_secs ;
              END IF;
            END IF ;

        END IF ; /* End if for date check */
     END IF; /* End if for i = 0 */

     END LOOP;

     /*  cal count gives the Number of rows after the Calendar is exploded */
     cal_count := new_rec.COUNT ;
     /*  Calendar Start date and End dates are Calculated here  */
     cal_start_date := new_rec(1).cal_date;
     cal_end_date := new_rec(cal_count).cal_date;

     CLOSE cal_cur;

     /* 12/13/02 - Rajesh Patangya B2710601, Added database link  */
     wps_index := 1 ;
     ins_stmt := 'INSERT INTO gmp_calendar_detail_gtmp'||p_db_link
                          ||' ( '
                          ||'   calendar_code, '
                          ||'   shift_num, '
                          ||'   shift_date, '
                          ||'   from_time, '
                          ||'   to_time, '
                          ||'   from_date, '
                          ||'   to_date '
                          ||' ) '
                          ||' VALUES '
                          ||' ( :p1,:p2,:p3,:p4,:p5,:p6,:p7)';

   /*  ins_stmt1 := 'INSERT INTO temp_cal'||p_db_link
                          ||' ( '
                          ||'   calendar_code, '
                          ||'   shift_num, '
                          ||'   shift_date, '
                          ||'   from_time, '
                          ||'   to_time, '
                          ||'   from_date, '
                          ||'   to_date '
                          ||' ) '
                          ||' VALUES '
                          ||' ( :p1,:p2,:p3,:p4,:p5,:p6,:p7)';
*/

   log_message(n_calendar_code  || '-GTMP-' || new_rec.COUNT);
   FOR wps_index IN 1..new_rec.COUNT
   LOOP

     temp_from_date := (new_rec(wps_index).cal_date +
                         (new_rec(wps_index).from_time/86400)) ;

     IF new_rec(wps_index).to_time = 86400 THEN
      temp_to_time   := new_rec(wps_index).to_time - 1 ;
      temp_shift_num := new_rec(wps_index).shift_num  + 99999 ;
     ELSE
      temp_to_time   := new_rec(wps_index).to_time  ;
      temp_shift_num := new_rec(wps_index).shift_num;
     END IF ;

      temp_to_date   := (new_rec(wps_index).cal_date + (temp_to_time /86400)) ;

     EXECUTE IMMEDIATE ins_stmt USING
                                n_calendar_code,
                                temp_shift_num,
                                new_rec(wps_index).cal_date,
                                new_rec(wps_index).from_time,
                                temp_to_time,
                                temp_from_date,
                                temp_to_date ;
   END LOOP;

     /*TDD - Sowmya -  As the calendar is a bom calendar, the calendar details will be
     collected by discrete collection. This package just collects msc_st_shift_times
     which to have cleaned calendar data.*/
     stmt_no := 41;
     IF p_usage = 'APS' THEN

        -- bug: 8486550 Vpedarla modified the shift_num column insertion for msc_st_shift_times

          get_shift_time := '  INSERT INTO msc_st_shift_times '
          || '   ( shift_num,      '
          || '     calendar_code,  '
          || '     from_time,      '
          || '     to_time,        '
          || '     deleted_flag,   '
          || '     sr_instance_id  '
          || '   )                 '
          || ' SELECT distinct decode(sign(gtmp.shift_num - 99999),0,0,1,(gtmp.shift_num - 99999),-1 ,gtmp.shift_num) shift_num , '
          || '     :v_calendar ,         '
          || '     from_time,            '
          || '     to_time,              '
          || '     2  ,                  '
          || '     :instance_id          '
          || ' FROM gmp_calendar_detail_gtmp'||p_db_link||' gtmp '
          || ' WHERE calendar_code = :curr_cal_code   '
          || ' ORDER BY  shift_num,from_time,to_time  ';

          EXECUTE IMMEDIATE get_shift_time USING n_calendar_code,
                            p_instance_id, n_calendar_code;

     END IF ; /*  End if for usage */
    return_status := TRUE;
    log_message(' Done retrieve Calendar Detail ');
    time_stamp;

EXCEPTION
   WHEN  NO_DATA_FOUND THEN
    log_message('Calendar has no days set in the Calendar Detail : '||p_calendar_code);
    log_message(sqlerrm);
    return_status := FALSE;
   WHEN  OTHERS THEN
    log_message('Error in retrieve Calendar Detail : ');
    log_message(sqlerrm);
    return_status := FALSE;

END retrieve_calendar_detail;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc_insert                                                       |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_org_id - Organization id                                            |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_calendar_id - calendar_id                                           |
REM|    p_instance_id - Instance Id                                           |
REM|    p_usage - Used foir APS or WPS                                        |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM|    7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix    |
REM| B3161696 - 26-SEP-2003 TARGETTED RESOURCE AVAILABILITY PLACEHOLDER BUG   |
REM|                                                                          |
REM+==========================================================================+
*/
PROCEDURE net_rsrc_insert(p_org_id         IN PLS_INTEGER,
                          p_orgn_code      IN varchar2,
                          p_simulation_set IN varchar2,
                          p_db_link        IN varchar2,
                          p_instance_id    IN PLS_INTEGER,
                          p_run_date       IN DATE ,
                          p_calendar_code  IN varchar2,
                          p_usage          IN varchar2,
                          return_status    OUT NOCOPY BOOLEAN) IS

/* Local array definition */
TYPE interval_typ_r is RECORD
(
  resource_count        PLS_INTEGER,
  resource_id           PLS_INTEGER,
  instance_id           PLS_INTEGER,
  instance_number       number,
  shift_num             number,
  from_date             date,
  to_date               date
);

interval_record_r       interval_typ_r;
ri_shift_interval	ref_cursor_typ;

sqlstmt		        VARCHAR2(32700) ;
sql_stmt1		VARCHAR2(32700) ;
g_calendar_code         VARCHAR2(10)  ;
stmt_no		 	INTEGER;
i         		INTEGER ;
j         		INTEGER ;
    /* B3347284, Performance Issue */
first_index             NUMBER ;
last_index              NUMBER ;
end_index               NUMBER ;
first_in                NUMBER ;
last_in                 NUMBER ;

TYPE rsrc_cnt IS TABLE OF cr_rsrc_dtl.assigned_qty%TYPE;
resource_count rsrc_cnt ;

TYPE rsrc_id  IS TABLE OF cr_rsrc_dtl.resource_id%TYPE;
resource_id   rsrc_id ;

TYPE inst_id  IS TABLE OF gmp_resource_instances.instance_id%TYPE;
instance_id   inst_id ;

TYPE inst_num  IS TABLE OF gmp_resource_instances.instance_number%TYPE;
instance_number inst_num ;

/* B3482001 - taking shift number from gmp_calendar_detail_gtmp */
TYPE shift_no  IS TABLE OF gmp_calendar_detail_gtmp.shift_num%TYPE;
shift_num  shift_no ;

TYPE f_dt   IS TABLE OF bom_shift_dates.shift_date%TYPE;
f_date f_dt ;

TYPE t_dt   IS TABLE OF bom_shift_dates.shift_date%TYPE;
t_date t_dt ;

BEGIN

  sqlstmt		:= NULL;
  sql_stmt1		:= NULL;
  g_calendar_code       := NULL;
  stmt_no		:= 0 ;
  i         		:= 1;
  j         		:= 1;
  first_index           := 0 ;
  last_index            := 0 ;
  end_index             := 0 ;
  first_in              := 0 ;
  last_in               := 0 ;

     stmt_no := 72;
     -- Rajesh Patangya B4724360, When the calendar is not assigned to
     -- resource then organization calendar should be considered
     sqlstmt :=  ' SELECT calendar_code '
         || '  FROM  mtl_parameters'||p_db_link
         || '  WHERE organization_id = :orgn_id1 ';

     EXECUTE IMMEDIATE sqlstmt INTO g_calendar_code USING p_org_id ;

     IF g_calendar_code IS NULL THEN
        log_message('Warning : '||p_org_id||
              ' does not have manufacturing calendar, continuing ...') ;
     END IF;

    /* Interval Cursor gives the all the point of inflections  */

    /*sowsubra - resource model ME changes - The orgn_code in cr_rsrc_dtl
    has been replaced with the organization_id in all the below union
    statements */

    stmt_no := 73;
       sql_stmt1 :=  ' SELECT /*+ ALL_ROWS */ '
            || ' decode(rt.interval_date,rt.lead_idate,rt.assigned_qty,decode(rt.rsum,0,rt.assigned_qty,rt.assigned_qty-rt.rsum)) resource_count  '
            || ' ,rt.resource_id '
            || ' ,0 instance_id '
            || ' ,0 instance_number '
            || ' ,rt.shift_num '
            || ' ,rt.interval_date	from_date  '
            || ' ,rt.lead_idate		to_date '
            || ' FROM '
            || ' ( '
            || ' SELECT '
            || ' t.resource_id '
            || ' ,t.shift_num  '
            || ' ,t.interval_date '
            || ' ,t.assigned_qty  '
            || ' ,nvl(sum(u.resource_units),0) rsum  '
            || ' ,max(t.lead_idate) lead_idate '
            || ' FROM '
            || ' ( '
            || ' SELECT unique resource_id,instance_number,from_date, '
            || ' to_date to_date1,resource_units '
            || ' FROM ( '
            || ' SELECT un.resource_id, '
            || '        gri.instance_number, '
            || '        un.from_date,  '
            || '        un.to_date,    '
            || '        1 resource_units'
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
            || '        gmp_resource_instances'||p_db_link||' gri '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.resource_id = gri.resource_id  '
            || ' AND    un.instance_id  = gri.instance_id  '
            || ' AND    crd.schedule_ind = 2 '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    crd.organization_id = :orgn_id1 '
            || ' AND    nvl(crd.calendar_code,:g_default_code1)=:l_cal_code1';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND    nvl(un.instance_id,0) <> 0  '
            || ' UNION ALL '
            || ' SELECT un.resource_id, '
            || '        gri.instance_number, '
            || '        un.from_date,  '
            || '        un.to_date,    '
            || '        1 resource_units'
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
            || '        gmp_resource_instances'||p_db_link||' gri '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.resource_id = gri.resource_id  '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    crd.schedule_ind = 2 '
            || ' AND    nvl(un.instance_id,0) = 0  '
            || ' AND    crd.organization_id = :orgn_id2 '
            || ' AND    nvl(crd.calendar_code,:g_default_code2)=:l_cal_code2';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND    gri.instance_number in '
            || '      ( select tgri.instance_number '
            || '      FROM gmp_resource_instances'||p_db_link||' tgri '
            || '      WHERE tgri.resource_id = crd.resource_id '
            || '      AND rownum <= un.resource_units '
            || '      ) '
            || ' UNION ALL  '
            || ' SELECT un.resource_id, '
            || '        0 instance_number,  '
            || '        un.from_date,  '
            || '        un.to_date,    '
            || '        un.resource_units '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||'  un'
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    crd.organization_id = :orgn_id3 '
            || ' AND    nvl(crd.calendar_code,:g_default_code3)=:l_cal_code3';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND NOT EXISTS '
            || ' (SELECT 1 '
            || '  FROM gmp_resource_instances'||p_db_link||' gri '
            || '  WHERE gri.resource_id = un.resource_id ) '
            || ' ) '
            || ' ) u, '
            || ' 	( '
            || ' 	SELECT resource_id,shift_num,interval_date, '
            || '          assigned_qty,lead_idate '
            || ' 	FROM '
            || ' 		( '
            || ' 	        SELECT resource_id,shift_num,interval_date, '
            || '                 assigned_qty '
            || ' 			,lead(resource_id,1) over(order by '
            || '  resource_id,interval_date,shift_num) as lead_rid '
            || ' 			,lead(interval_date,1) over(order by '
            || '  resource_id,interval_date,shift_num) as lead_idate '
            || ' 			,lead(shift_num,1) over(order by '
            || '  resource_id,interval_date,shift_num) as lead_snum '
            || ' 		FROM '
            || ' 			( '
            || ' SELECT unique cmd.resource_id, '
            || ' 0 , '
            || ' exp.shift_num, '
            || ' 0 , '
            || ' cmd.interval_date, '
            || ' cmd.assigned_qty '
            || ' FROM ( '
            || ' SELECT un.resource_id resource_id, '
            || '        gri.instance_number instance_number,'
            || '        0 shift_num,'
            || '        0 resource_count,'
            || '        un.from_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
            || '        gmp_resource_instances'||p_db_link||' gri '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.resource_id = gri.resource_id  '
            || ' AND    un.instance_id  = gri.instance_id  '
            || ' AND    crd.schedule_ind = 2 '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    nvl(un.instance_id,0) <> 0  '
            || ' AND    crd.organization_id = :orgn_id4 '
            || ' AND    nvl(crd.calendar_code,:g_default_code4)=:l_cal_code4';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' UNION ALL '
            || ' SELECT un.resource_id resource_id, '
            || '        gri.instance_number instance_number,'
            || '        0 shift_num,'
            || '        0 resource_count,'
            || '        un.to_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
            || '        gmp_resource_instances'||p_db_link||' gri '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.resource_id = gri.resource_id  '
            || ' AND    un.instance_id  = gri.instance_id  '
            || ' AND    crd.schedule_ind = 2 '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    nvl(un.instance_id,0) <> 0  '
            || ' AND    crd.organization_id = :orgn_id5 '
            || ' AND    nvl(crd.calendar_code,:g_default_code5)=:l_cal_code5';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' UNION ALL '
            || ' SELECT un.resource_id resource_id, '
            || '        gri.instance_number instance_number,'
            || '        0 shift_num,'
            || '        0 resource_count,'
            || '        un.from_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
            || '        gmp_resource_instances'||p_db_link||' gri '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.resource_id = gri.resource_id  '
            || ' AND    crd.schedule_ind = 2 '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    nvl(un.instance_id,0) = 0 '
            || ' AND    crd.organization_id = :orgn_id6 '
            || ' AND    nvl(crd.calendar_code,:g_default_code6)=:l_cal_code6';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND    gri.instance_number in '
            || '      ( select tgri.instance_number '
            || '      FROM gmp_resource_instances'||p_db_link||' tgri '
            || '      WHERE tgri.resource_id = crd.resource_id '
            || '      AND rownum <= un.resource_units '
            || '      ) '
            || ' UNION ALL '
            || ' SELECT un.resource_id resource_id, '
            || '        gri.instance_number instance_number,'
            || '        0 shift_num,'
            || '        0 resource_count,'
            || '        un.to_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
            || '        gmp_resource_instances'||p_db_link||' gri '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.resource_id = gri.resource_id  '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    crd.schedule_ind = 2 '
            || ' AND    nvl(un.instance_id,0) = 0  '
            || ' AND    crd.organization_id = :orgn_id7 '
            || ' AND    nvl(crd.calendar_code,:g_default_code7)=:l_cal_code7 ';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc7 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND    gri.instance_number in '
            || '      ( select tgri.instance_number '
            || '      FROM gmp_resource_instances'||p_db_link||' tgri '
            || '      WHERE tgri.resource_id = crd.resource_id '
            || '      AND rownum <= un.resource_units '
            || '      ) '
            || ' UNION ALL '
            || ' SELECT un.resource_id, '
            || '        0 instance_number,  '
            || '        0 shift_num,'
            || '        0 resource_count,'
            || '        un.from_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    crd.organization_id = :orgn_id8 '
            || ' AND    nvl(crd.calendar_code,:g_default_code8)=:l_cal_code8 ';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc8 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND NOT EXISTS '
            || '       (SELECT 1 '
            || '        FROM gmp_resource_instances'||p_db_link||' gri '
            || '        WHERE gri.resource_id = un.resource_id ) '
            || ' UNION ALL '
            || ' SELECT un.resource_id, '
            || '        0 instance_number,  '
            || '        0 shift_num,'
            || '        0 resource_count,'
            || '        un.to_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un '
            || ' WHERE  crd.resource_id = un.resource_id  '
            || ' AND    crd.delete_mark = 0 '
            || ' AND    crd.organization_id = :orgn_id9 '
            || ' AND    nvl(crd.calendar_code,:g_default_code9)=:l_cal_code9';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc9 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || ' AND NOT EXISTS '
            || '       (SELECT 1 '
            || '        FROM gmp_resource_instances'||p_db_link||' gri '
            || '        WHERE gri.resource_id = un.resource_id ) '
            || '    )   cmd,  '
            || '        gmp_calendar_detail_gtmp'||p_db_link||' exp  '
            || '      WHERE  exp.calendar_code = :CAL91 '
            || '        AND  cmd.interval_date  BETWEEN '
            || '             exp.from_date AND exp.to_date '
            || ' UNION ALL '
            || ' SELECT crd.resource_id , '
            || '        0 , '
            || '        exp.shift_num,  '
            || '        0 , '
            || '        exp.from_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_calendar_detail_gtmp'||p_db_link||' exp  '
            || ' WHERE  crd.delete_mark = 0 '
            || ' AND    crd.organization_id = :orgn_id10 '
            || ' AND    nvl(crd.calendar_code,:g_default_code10)=:l_cal_code10 ';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc10 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || '  AND    exp.calendar_code = :CAL101 '
            || ' UNION ALL '
            || ' SELECT crd.resource_id , '
            || '        0 , '
            || '        exp.shift_num,  '
            || '        0 , '
            || '        exp.to_date interval_date, '
            || '        crd.assigned_qty assigned_qty '
            || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
            || '        gmp_calendar_detail_gtmp'||p_db_link||' exp  '
            || ' WHERE  crd.delete_mark = 0 '
            || ' AND    crd.organization_id = :orgn_id11 '
            || ' AND    nvl(crd.calendar_code,:g_default_code11)=:l_cal_code11 ';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc and :trsrc11 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
            || '  AND    exp.calendar_code = :CAL111 ' /* Sowmya. BOM calendars */
            || ' 			) '
            || ' 		) '
            || ' 	WHERE '
            || ' 		resource_id = lead_rid '
            || ' 	    AND trunc(interval_date) = trunc(lead_idate) '
            || ' 	    AND interval_date < lead_idate '
            || ' 	    AND shift_num = lead_snum  '
            || ' 	) t '
            || ' WHERE '
            || ' 	    t.interval_date >= u.from_date(+) '
            || '  AND t.lead_idate <= u.to_date1 (+) '
            || ' 	AND t.resource_id = u.resource_id(+) '
            || ' GROUP BY '
            || ' 	 t.resource_id '
            || ' 	,t.shift_num '
            || ' 	,t.interval_date '
            || ' 	,t.assigned_qty '
            || ' ) rt '
            || ' WHERE '
            || ' 	(rt.interval_date = rt.lead_idate OR rt.rsum=0) '
            || ' 	OR '
            || ' 	(    rt.interval_date <> rt.lead_idate '
            || '   AND rt.rsum <> 0 '
            || '   AND rt.assigned_qty>rsum) '
            || ' ORDER BY 2,6,5 ';


    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
-- RDP B4724360 Pass correct parameters
    OPEN ri_shift_interval FOR sql_stmt1 USING
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_calendar_code ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_calendar_code ,
        p_org_id,g_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC ,
        p_calendar_code  ;

    ELSE

-- RDP B4724360 Pass correct parameters
       OPEN ri_shift_interval FOR sql_stmt1 USING
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,p_calendar_code,
          p_org_id,g_calendar_code,p_calendar_code,p_calendar_code ;

    END IF;

    /* B3347284, Performance Issue */
    stmt_no := 73;
    LOOP
       FETCH ri_shift_interval BULK COLLECT INTO resource_count, resource_id,
             instance_id, instance_number, shift_num, f_date, t_date ;
       EXIT WHEN ri_shift_interval%NOTFOUND;
    END LOOP ;
    CLOSE ri_shift_interval;

    stmt_no := 74;
    IF (resource_id.FIRST > 0) THEN    /* Only if any resource */

       first_index :=  resource_id.FIRST ;
       last_index  :=  resource_id.LAST ;
       end_index   := ceil(last_index/50000) ;

       first_in  := first_index ;
       last_in   := 50000 ;

        IF last_index >=  last_in THEN
          NULL ;
        ELSE
         last_in := last_index ;
        END IF;

     FOR j IN first_index..end_index LOOP

       IF (p_usage = 'WPS') THEN   /* Usage WPS     */

        FORALL i IN first_in..last_in
          INSERT INTO gmp_resource_avail
          (
          instance_id, organization_id, resource_id,
          calendar_code, resource_instance_id, shift_num,
          shift_date, from_time, to_time,
          resource_units, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login
          )  VALUES
          (
            p_instance_id,
            p_org_id,
            resource_id(i),
            p_calendar_code,
            instance_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 ),
            resource_count(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
          );

       END IF;   /* Usage */

        first_in  := last_in + 1;
        last_in   := last_in + 50000 ;

        IF last_index >=  last_in THEN
          NULL ;
        ELSE
         last_in := last_index ;
        END IF;

    -- B5083216, commit ends the session, if called remotely
    -- COMMIT;                 /* Save remaining records */
     END LOOP ;

    END IF;   /* Only if any resource */

    /* NAMIT_RAC */
    /* Moved this select statement above. This procedure will not be called
      for APS. So this Select statement will never get executed. To handle this,
       moving this select statement in procedure populate_rsrc_cal*/
    /* Insert for msc_st_resource_shifts Starts here - 2213101 */

  return_status := TRUE;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_message('NO DATA FOUND exception: Gmp_calendar_pkg.net_rsrc_insert');
    return_status := TRUE;
  WHEN OTHERS THEN
    log_message('Error in Net Resource Insert: '||stmt_no);
    log_message(sqlerrm);
    return_status := FALSE;

end net_rsrc_insert;


/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    insert_gmp_resource_avail                                             |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_orgn_code - Orgn Code                                               |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    errbuf and retcode                                                    |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM| B3161696 - 26-SEP-2003 TARGETTED RESOURCE AVAILABILITY PLACEHOLDER BUG   |
REM| sowsubra - calendar convergence ME changes -                             |
REM| Replace the calendar id with calendar code,orgn_code with organization_id|
REM| B4724360 - 12-DEC-2005 Modified code to TO ADD TIME OR A SHIFT TO A      |
REM|                        PLANT RESOURCE                                    |
REM+==========================================================================+
*/
PROCEDURE insert_gmp_resource_avail(errbuf          OUT NOCOPY varchar2,
                                    retcode         OUT NOCOPY number  ,
                                    p_org_id        IN PLS_INTEGER ,
                                    p_from_rsrc     IN varchar2 ,
                                    p_to_rsrc       IN varchar2 ,
                                    p_calendar_code IN varchar2   ) IS

TYPE cal_shift_typ is RECORD
(
  calendar_no     varchar2(16),
  calendar_desc   varchar2(40)
);

TYPE cal_shift_tab is table of cal_shift_typ index by BINARY_INTEGER;
cal_shift_record	cal_shift_typ;
cal_shift_rec		cal_shift_tab;

  i                 integer ;
  cal_index         integer ;
  ret_status        boolean ;
  stmt_no	    integer ;

  cal_detail_ref    ref_cursor_typ;
  get_org_code      ref_cursor_typ;
  delete_stmt       VARCHAR2(9000) ;
  sql_get_cal       VARCHAR2(9000) ;
  sql_get_orgn      VARCHAR2(9000) ;
  sql_get_def_cal   VARCHAR2(9000) ;

-- 8578876 Vpedarla
  Called_from       VARCHAR2(100) ;
  sql_1             VARCHAR2(9000) ;
  sql_2             VARCHAR2(9000) ;
  sql_ref_1         ref_cursor_typ;
  sql_ref_2         ref_cursor_typ;
  bom_result        NUMBER ;
  resource_result   VARCHAR2(1000);
  res_count         NUMBER;
  VRESOURCE_FROM    VARCHAR2(1000);
  VRESOURCE_TO      VARCHAR2(1000);
-- 8578876 Vpedarla end

BEGIN
  cal_index         := 1 ;
  i                 := 1 ;
  stmt_no           := 0 ;
  delete_stmt       := NULL ;
  sql_get_cal       := NULL ;
  sql_get_orgn      := NULL ;
  sql_get_def_cal   := NULL ;
  Called_from       := V_WPS ;
  sql_1             := NULL ;
  sql_2             := NULL ;
  bom_result        := 0 ;
  res_count         := 1 ;
  resource_result   := NULL;
  VRESOURCE_FROM    := NULL;
  VRESOURCE_TO      := NULL;

  IF (NVL(P_FROM_RSRC,'RETRIEVE') = 'DONOT_RETRIEVE_CALENDAR') THEN
    Called_from  := V_APS ;
     -- Called for APS Regenerate
     V_FROM_RSRC := NULL;
     V_TO_RSRC   := NULL ;
  ELSE
     Called_from := V_WpS ;
     V_FROM_RSRC := p_from_rsrc;
     V_TO_RSRC   := p_to_rsrc ;
  END IF;

log_message('into insert_gmp_resource_avail - ' ||p_org_id||'**'|| p_calendar_code );

IF (Called_from = V_APS) THEN

   sql_1 :=  ' SELECT count(*) from '
         ||  ' ( select  min(LAST_UPDATE_DATE) lud from gmp_resource_avail '
         ||  ' where CALENDAR_CODE = :cal_code '
         ||  ' and ORGANIZATION_ID = :orgn_id ) gmp, '
         ||  ' (select min(LAST_UPDATE_DATE) lud from bom_shift_dates '
         ||  ' where CALENDAR_CODE  = :cal_code ) bom '
         ||  ' WHERE bom.lud >  gmp.lud ' ;

   OPEN  sql_ref_1 FOR sql_1 USING p_calendar_code, p_org_id , p_calendar_code;
   FETCH sql_ref_1 INTO bom_result;
   CLOSE sql_ref_1;

   log_message('bom_result -'||bom_result);

   sql_2 := ' select RESOURCES  '
         ||  ' FROM ( '
         ||  ' select crd.RESOURCES  from '
         ||  ' (select RESOURCES , RESOURCE_id , c.LAST_UPDATE_DATE '
         ||  '   from cr_rsrc_dtl c , mtl_parameters m '
         ||  '  where c.ORGANIZATION_ID = :orgn_id '
         ||  '  AND  c.ORGANIZATION_ID = m.organization_id '
         ||  ' and nvl(c.CALENDAR_CODE,m.CALENDAR_CODE) = :cal_code ) crd , '
         ||  ' ( select  min(LAST_UPDATE_DATE) lud , resource_id  from gmp_resource_avail '
         ||  ' where CALENDAR_CODE = :cal_code '
         ||  ' and ORGANIZATION_ID = :orgn_id '
         ||  ' group by resource_id ) gmp '
         ||  ' where  crd.LAST_UPDATE_DATE > gmp.lud AND crd.resource_id = gmp.resource_id '
         ||  ' Union '
         ||  ' select RESOURCES '
         ||  ' from cr_rsrc_dtl c , mtl_parameters m '
         ||  ' where c.ORGANIZATION_ID = :orgn_id '
         ||  ' AND  c.ORGANIZATION_ID = m.organization_id '
         ||  ' and nvl(c.CALENDAR_CODE,m.CALENDAR_CODE) = :cal_code '
         ||  ' AND NOT exists ( select 1 from gmp_resource_avail gmp '
         ||  ' where gmp.CALENDAR_CODE = :cal_code '
         ||  ' and gmp.ORGANIZATION_ID = :orgn_id '
         ||  ' and c.resource_id = gmp.resource_id ) ) '
         ||  ' order by 1  ';

   OPEN  sql_ref_2 FOR sql_2 USING p_org_id, p_calendar_code , p_calendar_code , p_org_id ,
    p_org_id ,p_calendar_code,p_calendar_code, p_org_id;
   LOOP
   FETCH sql_ref_2 INTO resource_result;
   EXIT WHEN sql_ref_2%NOTFOUND;
   IF res_count = 1 THEN
   VRESOURCE_FROM := resource_result ;
   VRESOURCE_TO   := resource_result ;
   ELSE
   VRESOURCE_TO   := resource_result ;
   END IF;
    res_count := res_count + 1 ;
   END LOOP;
   CLOSE sql_ref_2;

   log_message(VRESOURCE_FROM||'**'||VRESOURCE_TO||'**'||res_count);

   IF res_count > 1 THEN
        V_FROM_RSRC := VRESOURCE_FROM;
        V_TO_RSRC   := VRESOURCE_TO ;
   END IF;
END IF;

IF (Called_from = V_APS and ( res_count>1 OR  bom_result>0 ) ) OR  (Called_from = V_WPS)   THEN

   stmt_no := 1 ;
    sql_get_orgn :=  ' SELECT  m.organization_code '
         ||' FROM    hr_organization_units hr, '
         ||'         mtl_parameters m '
         ||' WHERE  m.organization_id = :orgn_id  '
         ||' AND    m.organization_id = hr.organization_id '
         ||' AND    nvl(hr.date_to,sysdate) >= sysdate '
         ||' AND    m.process_enabled_flag = '||''''||'Y'||'''';

     OPEN get_org_code FOR sql_get_orgn USING p_org_id;
     FETCH get_org_code INTO p_orgn_code;
     CLOSE get_org_code;


   stmt_no := 2 ;
   IF cal_shift_rec.COUNT > 0 THEN
      cal_shift_rec.DELETE;
   END IF;

   stmt_no := 3 ;
   -- RDP B4724360 Case I - Calendar is blank
   IF p_calendar_code IS NULL THEN

    sql_get_cal := ' SELECT  DISTINCT cal.calendar_code, '
         ||'         cal.description '
         ||'  FROM   bom_calendars   cal,  '
         ||'         hr_organization_units hr, '
         ||'         mtl_parameters  m,  '
         ||'         cr_rsrc_dtl crd  '
         ||'  WHERE  m.organization_id = :orgn_id  '
         ||'    AND  m.organization_id = hr.organization_id '
         ||'    AND  nvl(hr.date_to,sysdate) >= sysdate '
         ||'    AND  m.process_enabled_flag = '||''''||'Y'||''''
         ||'    AND  crd.organization_id = m.organization_id '
         ||'    AND  NVL(crd.calendar_code,m.calendar_code)=cal.calendar_code '
         ||'    AND  crd.delete_mark = 0 ' ;

      IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NULL) THEN
      -- Case A - From Resource is entered and To Resource is blank
        sql_get_cal := sql_get_cal || ' AND crd.resources >= :frsrc ' ;
        OPEN  cal_detail_ref FOR sql_get_cal USING p_org_id,v_from_rsrc ;

      ELSE
        -- Case B - From and TO resources are entered
        IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
          sql_get_cal := sql_get_cal || ' AND crd.resources BETWEEN :frsrc and :trsrc ';
           OPEN  cal_detail_ref FOR sql_get_cal USING p_org_id,v_from_rsrc,v_to_rsrc ;

        ELSIF ( v_from_rsrc IS NULL AND v_to_rsrc IS NULL) THEN
        -- Case C - From and TO resources are blank
           OPEN  cal_detail_ref FOR sql_get_cal USING p_org_id;
        END IF ;
      END IF;

   ELSE
   -- Case II Calendar is entered
   -- Case A- Both from and To resources are entered

    sql_get_cal :=  ' SELECT  cal.calendar_code, '
         ||'         substr(cal.description,1,40) '
         ||'  FROM   bom_calendars cal  '
         ||'  WHERE  cal.calendar_code = :cal_code ';

       OPEN  cal_detail_ref FOR sql_get_cal USING p_calendar_code ;
--  log_message('Calendar Code Is Passed = ' || p_calendar_code);

   END IF;   /* Calendar_code */

   LOOP
      FETCH cal_detail_ref INTO  cal_shift_record;
      EXIT WHEN cal_detail_ref%NOTFOUND;
      cal_shift_rec(cal_index).calendar_no     :=
                                     cal_shift_record.calendar_no;
      cal_shift_rec(cal_index).calendar_desc   :=
                                     cal_shift_record.calendar_desc ;
      cal_index := cal_index + 1;
   END LOOP;
   CLOSE cal_detail_ref;
    log_message('The Calendar Detail Size is = ' || cal_shift_rec.COUNT);

   FOR i in 1..cal_shift_rec.COUNT
   LOOP

     stmt_no := 1 ;
     delete_stmt := 'DELETE FROM gmp_resource_avail '||
                    ' WHERE CALENDAR_CODE = :cal_code ' ||
                    '   AND organization_id = :org_id1 ';

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
     delete_stmt := delete_stmt ||' AND resource_id in (select resource_id '
                            ||' FROM cr_rsrc_dtl '
                            ||' WHERE organization_id = :org_id2 '
                            ||' AND resources BETWEEN :frsrc and :trsrc ) ';
     EXECUTE IMMEDIATE delete_stmt USING cal_shift_rec(i).calendar_no, p_org_id,
                   p_org_id, v_from_rsrc, v_to_rsrc;

    ELSIF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NULL) THEN
     delete_stmt := delete_stmt ||' AND resource_id in (select resource_id '
                            ||' FROM cr_rsrc_dtl '
                            ||' WHERE organization_id = :org_id2 '
                            ||' AND resources > :frsrc ) ';
     EXECUTE IMMEDIATE delete_stmt USING cal_shift_rec(i).calendar_no, p_org_id,
                   p_org_id, v_from_rsrc;

    ELSIF (v_from_rsrc IS NULL AND v_to_rsrc IS NULL) THEN

     EXECUTE IMMEDIATE delete_stmt USING cal_shift_rec(i).calendar_no, p_org_id;
    END IF ;
     log_message('Deletion from Resource Avail Table is DONE');

	IF (NVL(P_FROM_RSRC,'RETRIEVE') <> 'DONOT_RETRIEVE_CALENDAR') THEN
          log_message('Calling retrieve_calendar_detail');
          retrieve_calendar_detail(cal_shift_rec(i).calendar_no,
                                   cal_shift_rec(i).calendar_desc,
                                   null,
                                   null,
                                   null,
                                   V_WPS,
                                   ret_status)  ;

          /* Summary rows for WPS */

         IF ret_status THEN
          log_message('Calling  net_rsrc_insert WPS Summary Rows');
         ELSE
          log_message('FAILED retrieve_calendar_detail');
         END IF;

	END IF ;

          net_rsrc_insert(p_org_id,   /*sowsubra - org_id is passed.*/
                          p_orgn_code,
                          null,
                          null,
                          0,
                          sysdate,
                          cal_shift_rec(i).calendar_no,
                          V_WPS,
                          ret_status)  ;

       -- B5083216, commit ends the session, if called remotely
       IF (NVL(P_FROM_RSRC,'RETRIEVE') <> 'DONOT_RETRIEVE_CALENDAR') THEN
          -- Called for APS Regenerate
          COMMIT ;
       END IF;

          /* Instance number rows for WPS */
         IF ret_status THEN
          log_message('Calling  net_rsrc_avail_calculate WPS Instance Rows');
         ELSE
          log_message('FAILED net_rsrc_insert WPS Summary Rows');
         END IF;
          net_rsrc_avail_calculate(null,
                                   p_org_id,
                                   cal_shift_rec(i).calendar_no,
                                   null,
                                   ret_status)  ;

   END LOOP ;

       -- B5083216, commit ends the session, if called remotely
       IF (NVL(P_FROM_RSRC,'RETRIEVE') <> 'DONOT_RETRIEVE_CALENDAR') THEN
          -- Called for APS Regenerate
          COMMIT ;
       END IF;

 END IF;  -- Bug: 8578876 end

   retcode := 0 ;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
     log_message('Manufacturing Calendar is not assigned to '|| p_orgn_code);
     retcode := 1 ;
   WHEN OTHERS THEN
     log_message(sqlerrm);
     retcode := 1 ;

END insert_gmp_resource_avail;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc_avail_calculate                                              |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_nstance_id - Instance_id                                            |
REM|    p_orgn_code - Orgn Code                                               |
REM|    p_instance_id - Instance Id                                           |
REM|    p_db_link - Data Base Link                                            |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    return_status                                                         |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM|    7th Mar 2003 -- Performance issue fix and B2671540 00:00 shift fix    |
REM| B3161696 - 26-SEP-2003 TARGETTED RESOURCE AVAILABILITY PLACEHOLDER BUG   |
REM|                                                                          |
REM+==========================================================================+
*/

PROCEDURE net_rsrc_avail_calculate(p_instance_id   IN PLS_INTEGER,
                                   p_org_id        IN PLS_INTEGER,
                                   p_calendar_code IN varchar2,
                                   p_db_link       IN varchar2,
                                   return_status   OUT NOCOPY BOOLEAN) IS

/* Local array definition */
TYPE interval_typ is RECORD
(
  resource_id     PLS_INTEGER,
  resource_instance_id  PLS_INTEGER,
  shift_date      date,
  shift_num       number,
  resource_units  number,
  from_time       number,
  to_time         number
);

TYPE interval_tab is table of interval_typ index by BINARY_INTEGER;
interval_record		interval_typ;

ri_assembly	        ref_cursor_typ;
ri_shift_interval	ref_cursor_typ;
sql_del		        varchar2(32700) ;
sqlupt 		        varchar2(32700) ;
sql_stmt1		varchar2(32700) ;
sql_assembly		varchar2(32700) ;
sqlstmt     		varchar2(32700) ;
g_calendar_code         VARCHAR2(10)  ;
stmt_no		 	integer ;
i         		integer ;
first_index             number ;
last_index              number ;
end_index               number ;
first_in                number ;
last_in                 number ;

TYPE rsrc_cnt IS TABLE OF cr_rsrc_dtl.assigned_qty%TYPE;
resource_count rsrc_cnt ;

TYPE rsrc_id  IS TABLE OF cr_rsrc_dtl.resource_id%TYPE;
resource_id   rsrc_id ;

TYPE inst_id  IS TABLE OF gmp_resource_instances.instance_id%TYPE;
instance_id   inst_id ;

TYPE inst_num  IS TABLE OF gmp_resource_instances.instance_number%TYPE;
instance_number inst_num ;

/* B3482001 - taking shift number from gmp_calendar_detail_gtmp */
TYPE shift_no  IS TABLE OF gmp_calendar_detail_gtmp.shift_num%TYPE;
shift_num  shift_no ;

TYPE f_dt   IS TABLE OF mr_shcl_dtl.calendar_date%TYPE;
f_date f_dt ;

TYPE t_dt   IS TABLE OF mr_shcl_dtl.calendar_date%TYPE;
t_date t_dt ;

BEGIN
  sql_del		:= NULL;
  sqlupt 		:= NULL;
  sql_stmt1		:= NULL;
  sql_assembly		:= NULL;
  first_index           := 0 ;
  last_index            := 0 ;
  end_index             := 0 ;
  first_in              := 0 ;
  last_in               := 0 ;
  stmt_no		:= 0 ;
  i         		:= 1;
  g_calendar_code       := NULL;

     -- Rajesh Patangya B4724360, When the calendar is not assigned to
     -- resource then organization calendar should be considered
     sqlstmt :=  ' SELECT calendar_code '
         || '  FROM  mtl_parameters'||p_db_link
         || '  WHERE organization_id = :orgn_id1 ';

     EXECUTE IMMEDIATE sqlstmt INTO g_calendar_code USING p_org_id ;

     IF g_calendar_code IS NULL THEN
        log_message('Warning : '||p_org_id||
              ' does not have manufacturing calendar, continuing ...') ;
     END IF;

    /* Interval Cursor gives the all the point of inflections  */
    /*  03/26/02 Rajesh Patangya B2282409, Filter extra resource information */
    stmt_no := 63;
       sql_stmt1 :=  ' SELECT /*+ ALL_ROWS */ '
                  || '  decode(rt.interval_date,rt.lead_idate,rt.assigned_qty,'
                  || '  (rt.assigned_qty-nvl(rt.rsum,0))) resource_count '
                  || '  ,rt.resource_id '
                  || '  ,rt.instance_id '
                  || '  ,rt.shift_num '
                  || '  ,rt.interval_date '
                  || '  ,rt.lead_idate    '
                  || ' FROM '
                  || ' ( '
                  || ' SELECT '
                  || '  t.resource_id '
                  || '  ,t.instance_id '
                  || '  ,t.shift_num  '
                  || '  ,t.interval_date '
                  || '  ,t.assigned_qty  '
                  || '  ,nvl(u.resource_units,0) rsum  '
                  || '  ,max(t.lead_idate) lead_idate '
                  || ' FROM ( '
                  || ' SELECT unique resource_id,instance_id,from_date, '
                  || ' to_date to_date1,resource_units '
                  || ' FROM ( '
                  || ' SELECT un.resource_id, '
                  || '        gri.instance_id, '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        1 resource_units'
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.organization_id = :orgn_id1 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code1)=:l_cal_code1'
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc1 and :trsrc2 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id, '
                  || '        gri.instance_id, '
                  || '        un.from_date,  '
                  || '        un.to_date,    '
                  || '        1 resource_units'
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.organization_id = :orgn_id2 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code2)=:l_cal_code2'
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc2 and :trsrc2 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances'||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || '   ) '
                  || ' ) u, '
                  || ' 	( '
                  || '  SELECT	resource_id,instance_id, shift_num, '
                  || '          interval_date,assigned_qty,lead_idate '
                  || ' 	FROM '
                  || ' 		( '
                  || ' 		SELECT '
                  || ' 			resource_id,instance_id,shift_num, '
                  || '                  interval_date,1 assigned_qty, '
                  || ' 			lead(resource_id,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_rid, '
                  || ' 			lead(instance_id,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_iid, '
                  || ' 			lead(interval_date,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_idate, '
                  || ' 			lead(shift_num,1) over(order by '
    || ' resource_id,instance_id,interval_date,shift_num) as lead_snum '
                  || ' 		FROM '
                  || ' 			( '
                  || ' SELECT unique cmd.resource_id, '
                  || ' cmd.instance_id, '
                  || ' exp.shift_num, '
                  || ' 1 , '
                  || ' cmd.interval_date '
                  || ' FROM ( '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.from_date interval_date '
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.organization_id = :orgn_id3 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code3)=:l_cal_code3'
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc3 and :trsrc3 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.to_date interval_date '
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    un.instance_id  = gri.instance_id  '
                  || ' AND    crd.organization_id = :orgn_id4 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code4)=:l_cal_code4'
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) <> 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc4 and :trsrc4 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.from_date interval_date '
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.organization_id = :orgn_id5 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code5)=:l_cal_code5'
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc5 and :trsrc5 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances'||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || ' UNION ALL '
                  || ' SELECT un.resource_id resource_id, '
                  || '        gri.instance_id instance_id,'
                  || '        0 shift_num,'
                  || '        1 resource_count,'
                  || '        un.to_date interval_date '
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_rsrc_unavail_dtl_v'||p_db_link||' un, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.resource_id = un.resource_id  '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.organization_id = :orgn_id6 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code6)=:l_cal_code6'
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 '
                  || ' AND    nvl(un.instance_id,0) = 0  ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc6 and :trsrc6 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    gri.instance_number in '
                  || '      ( select tgri.instance_number '
                  || '      FROM gmp_resource_instances'||p_db_link||' tgri '
                  || '      WHERE tgri.resource_id = crd.resource_id '
                  || '      AND rownum <= un.resource_units '
                  || '      ) '
                  || '    )   cmd,  '
                  || '        gmp_calendar_detail_gtmp'||p_db_link||' exp  '
                  || '      WHERE  exp.calendar_code = :curr_cal1 '
                  || '        AND  cmd.interval_date  BETWEEN '
                  || '             exp.from_date AND exp.to_date '
                  || ' UNION ALL '
                  || ' SELECT crd.resource_id , '
                  || '        gri.instance_id, '
                  || '        exp.shift_num,  '
                  || '        1 , '
                  || '        (exp.shift_date + '
                  || '               (exp.from_time/86400)) interval_date '
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_calendar_detail_gtmp'||p_db_link||' exp, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.organization_id = :orgn_id7 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code7)=:l_cal_code7'
                  || ' AND    exp.calendar_code = :curr_cal2 '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.delete_mark = 0 '
                  || ' AND    crd.schedule_ind = 2 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc7 and :trsrc7 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' UNION ALL '
                  || ' SELECT crd.resource_id , '
                  || '        gri.instance_id, '
                  || '        exp.shift_num,  '
                  || '        1 , '
                  || '        (exp.shift_date + '
                  || '               (exp.to_time/86400)) interval_date '
                  || ' FROM   cr_rsrc_dtl'||p_db_link||'  crd, '
                  || '        gmp_calendar_detail_gtmp'||p_db_link||' exp, '
                  || '        gmp_resource_instances'||p_db_link||' gri '
                  || ' WHERE  crd.organization_id = :orgn_id8 '
                  || ' AND    nvl(crd.calendar_code,:g_default_cal_code8)=:l_cal_code8'
                  || ' AND    exp.calendar_code = :curr_cal3 '
                  || ' AND    crd.resource_id = gri.resource_id  '
                  || ' AND    crd.delete_mark = 0 ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
    sql_stmt1 := sql_stmt1 || '  AND crd.resources BETWEEN :frsrc8 and :trsrc8 ' ;
    END IF ;

    sql_stmt1 := sql_stmt1
                  || ' AND    crd.schedule_ind = 2 '
                  || '                  ) '
                  || '          ) '
                  || '    WHERE resource_id = lead_rid '
                  || '      AND instance_id = lead_iid '
                  || '      AND trunc(interval_date) = trunc(lead_idate) '
                  || '      AND interval_date < lead_idate '
                  || '      AND shift_num = lead_snum  '
                  || '  ) t '
                  || ' WHERE '
                  || '      t.interval_date >= u.from_date(+) '
                  || '  AND t.lead_idate <= u.to_date1 (+) '
                  || '  AND t.resource_id = u.resource_id(+) '
                  || '  AND t.instance_id = u.instance_id(+) '
                  || ' GROUP BY '
                  || '   t.resource_id '
                  || '  ,t.instance_id '
                  || '  ,t.shift_num '
                  || '  ,t.interval_date '
                  || '  ,u.resource_units '
                  || '  ,t.assigned_qty '
                  || ' ) rt '
                  || ' WHERE '
                  || '  decode(rt.interval_date,rt.lead_idate,rt.assigned_qty,'
                  || '        (rt.assigned_qty - nvl(rt.rsum,0))) > 0 '
                  || '  ORDER BY rt.resource_id ,rt.instance_id, '
                  || '  rt.interval_date,rt.shift_num ' ;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN

-- HW B4309093 Pass correct parameters
    OPEN ri_shift_interval FOR sql_stmt1 USING
      p_org_id,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_org_id,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_org_id,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_org_id,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_org_id,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_org_id,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_calendar_code,
      p_org_id,p_calendar_code,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC,
      p_org_id,p_calendar_code,p_calendar_code,p_calendar_code,V_FROM_RSRC, V_TO_RSRC;

    ELSE

-- HW B4309093 Pass correct parameters
    OPEN ri_shift_interval FOR sql_stmt1 USING
        p_org_id,g_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,p_calendar_code,
        p_org_id,g_calendar_code,p_calendar_code,p_calendar_code ;

    END IF;

    /* B3347284, Performance Issue */
    stmt_no := 664;
    LOOP
       FETCH ri_shift_interval BULK COLLECT INTO resource_count, resource_id,
                                     instance_id, shift_num, f_date, t_date ;
       EXIT WHEN ri_shift_interval%NOTFOUND;
   END LOOP ;
   CLOSE ri_shift_interval;

    stmt_no := 665;

    IF resource_id.FIRST > 0 OR resource_id.LAST > 0 THEN

       first_index :=  resource_id.FIRST ;
       last_index  :=  resource_id.LAST ;
       end_index   := ceil(last_index/50000) ;

       first_in  := first_index ;
       last_in   := 50000 ;

        IF last_index >=  last_in THEN
          NULL ;
        ELSE
         last_in := last_index ;
        END IF;

/*sowsubra - calendar convergence ME changes - organization_id is used in place
of organization code in gmp_resource_avail*/

      FOR j IN first_index..end_index LOOP

        FORALL i IN first_in..last_in
        INSERT INTO gmp_resource_avail
         (
          instance_id, organization_id, resource_id,
          calendar_code, resource_instance_id, shift_num,
          shift_date, from_time, to_time,
          resource_units, creation_date, created_by,
          last_update_date, last_updated_by, last_update_login
         )  VALUES
         (
            p_instance_id,
            p_org_id,
            resource_id(i),
            p_calendar_code,
            instance_id(i),
            shift_num(i),
            trunc(f_date(i)),
            ((f_date(i) - trunc(f_date(i))) * 86400 ),
            ((t_date(i) - trunc(t_date(i))) * 86400 ),
            resource_count(i),
            sysdate,
            FND_GLOBAL.USER_ID,
            sysdate,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.USER_ID
          )                     ;

        first_in  := last_in + 1;
        last_in   := last_in + 50000 ;

        IF last_index >=  last_in THEN
          NULL ;
        ELSE
         last_in := last_index ;
        END IF;

    -- B5083216, commit ends the session, if called remotely
    -- COMMIT ;
      END LOOP ;

   END IF;

   /* This logic introduced for Net resource availablility to
       write consolidated rows once final available rows are in place */
   stmt_no := 666;
   sql_assembly :=  ' SELECT  /*+ ALL_ROWS */ '
   || '        net.resource_id , '
   || '        net.resource_instance_id, '
   || '        net.shift_date  , '
   || '        net.shift_num   , '
   || '        net.resource_units , '
   || '        min(net.from_time) from_time, '
   || '        max(net.lead_tt) to_time '
   || ' FROM  ( '
   || '        SELECT resource_id , '
   || '               resource_instance_id, '
   || '               shift_date  , '
   || '               shift_num , '
   || '               from_time , '
   || '               to_time , '
   || '               resource_units , '
   || '  lead(resource_id,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_rid, '
   || '  lead(resource_instance_id,1) over(order by resource_id, '
   || '  resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_iid, '
   || '  lead(shift_date,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_sdt, '
   || '  lead(shift_num,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_sn, '
   || '  lead(from_time,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_ft, '
   || '  lead(to_time,1) over(order by resource_id,resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_tt, '
   || '  lead(resource_units,1) over(order by resource_id, '
   || '  resource_instance_id, '
   || '  shift_date, shift_num,from_time,to_time,resource_units) as lead_rc '
   || '          FROM gmp_resource_avail'
   || '          WHERE organization_id = :orgn_id1 '
   || '            AND calendar_code = :cal_code ' ;

   IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN

   sql_assembly := sql_assembly ||' AND resource_id in (select resource_id '
                          ||' from cr_rsrc_dtl'||p_db_link
                          ||' WHERE organization_id = :orgn_id2 '
                          ||' AND resources BETWEEN :frsrc and :trsrc )' ;
   END IF ;

   sql_assembly := sql_assembly || '              ) net '
   || '      WHERE net.resource_id          = net.lead_rid '
   || '        AND net.resource_instance_id = net.lead_iid '
   || '        AND net.shift_num      = net.lead_sn '
   || '        AND net.shift_date     = net.lead_sdt '
   || '        AND net.to_time        = net.lead_ft '
   || '        AND net.resource_units = net.lead_rc '
   || ' GROUP BY '
   || '        net.resource_id , '
   || '        net.resource_instance_id , '
   || '        net.shift_date , '
   || '        net.shift_num , '
   || '        net.resource_units ' ;

    stmt_no := 66;

    IF (v_from_rsrc IS NOT NULL AND v_to_rsrc IS NOT NULL) THEN
     OPEN ri_assembly FOR sql_assembly USING p_org_id, p_calendar_code,
          p_org_id, v_from_rsrc, v_to_rsrc ;
    ELSE
     OPEN ri_assembly FOR sql_assembly USING p_org_id, p_calendar_code ;
    END IF;

    LOOP
       FETCH ri_assembly INTO  interval_record;
       EXIT WHEN ri_assembly%NOTFOUND;

     sql_del := 'DELETE FROM gmp_resource_avail'
             || ' WHERE organization_id  = :org_id1 '
             || '   AND calendar_code = :cal_code '
             || '   AND resource_id = :prid '
             || '   AND resource_instance_id = :piid '
             || '   AND shift_date = :psdt '
             || '   AND shift_num  = :psn  '
             || '   AND from_time  >= :pft '
             || '   AND to_time  <= :ptt '
             || '   AND resource_units = :prc ' ;

   stmt_no := 67;
       EXECUTE immediate sql_del USING
       p_org_id , p_calendar_code ,
       interval_record.resource_id,
       interval_record.resource_instance_id,
       trunc(interval_record.shift_date),
       interval_record.shift_num,
       interval_record.from_time, interval_record.to_time,
       interval_record.resource_units  ;

   stmt_no := 68;
         net_rsrc_avail_insert(
            p_instance_id,
            p_org_id,
            interval_record.resource_instance_id,
            p_calendar_code,
            interval_record.resource_id,
            interval_record.resource_units,
            interval_record.shift_num,
            interval_record.shift_date,
            interval_record.from_time,
            interval_record.to_time
            );

    -- B5083216, commit ends the session, if called remotely
    -- COMMIT ;
    END LOOP;
    CLOSE ri_assembly;

     stmt_no := 69;

   -- Bug: 8916018 Vpedarla commented the below dynamic sql.
   /*     sqlupt := 'UPDATE gmp_resource_avail'
            ||' SET to_time   = 86400 '
            ||' WHERE to_time = 86399 '
            ||'   AND shift_num >= 99999 ' ;  */

   /*  EXECUTE immediate sqlupt ;
     sqlupt := null ;
     sqlupt := 'UPDATE gmp_resource_avail'
            ||' SET shift_num = (shift_num - 99999) '
            ||' WHERE shift_num >= 99999 ' ;

      EXECUTE immediate sqlupt ;  */

       UPDATE gmp_resource_avail
       SET to_time   = 86400 , shift_num = (shift_num - 99999)
       WHERE shift_num >= 99999
       AND calendar_code = p_calendar_code
       AND organization_id = p_org_id
       AND resource_id <> 0 ;
       -- Bug: 8916018 Vpedarla end.

    -- B5083216, commit ends the session, if called remotely
    -- COMMIT ;

    return_status := TRUE ;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    log_message('NO DATA FOUND exception: net_rsrc_avail_calculate');
    return_status := TRUE;
  WHEN OTHERS THEN
    log_message('Error in Net Resource Instance Insert: '||stmt_no);
    log_message(sqlerrm);
    return_status := FALSE ;

end net_rsrc_avail_calculate;

/*
REM+==========================================================================+
REM| PROCEDURE NAME                                                           |
REM|    net_rsrc_avail_insert                                                 |
REM|                                                                          |
REM| Type                                                                     |
REM|    public                                                                |
REM|                                                                          |
REM| DESCRIPTION                                                              |
REM|    The following procedure inserts rows into gmp_resource_avail          |
REM|                                                                          |
REM| Input Parameters                                                         |
REM|    p_instance_id - Instance Id                                           |
REM|    p_orgn_code - Plant Code                                              |
REM|    p_resource_instance_id - Resource Instance Id                         |
REM|    p_Calendar_id - Calendar id                                           |
REM|    p_resource_id - Resource Id                                           |
REM|    p_assigned_qty -  Resource units                                      |
REM|    p_shift_num - Shift number                                            |
REM|    p_calendar_date - Calendar date                                       |
REM|    p_from_time - shift starting time                                     |
REM|    p_to_time - Shift Ending time                                         |
REM|                                                                          |
REM| Output Parameters                                                        |
REM|    None                                                                  |
REM|                                                                          |
REM| HISTORY                                                                  |
REM|    Created on 4th Jan 2002 By Rajesh Patangya                            |
REM|                                                                          |
REM+==========================================================================+
*/

PROCEDURE net_rsrc_avail_insert(p_instance_id          IN PLS_INTEGER,
                                p_org_id               IN PLS_INTEGER,
                                p_resource_instance_id IN PLS_INTEGER,
                                p_calendar_code        IN VARCHAR2,
                                p_resource_id          IN PLS_INTEGER,
                                p_assigned_qty         IN NUMBER,
                                p_shift_num            IN PLS_INTEGER,
                                p_calendar_date        IN DATE,
                                p_from_time            IN NUMBER,
                                p_to_time              IN NUMBER ) IS

BEGIN
   IF nvl(p_from_time,0) = 0  AND nvl(p_to_time,0) = 0 THEN
     NULL ;
   ELSE
     INSERT INTO gmp_resource_avail (
     instance_id, plant_code, resource_id,
     calendar_code, resource_instance_id, shift_num,
     shift_date, from_time, to_time,
     resource_units, creation_date, created_by,
     last_update_date, last_updated_by, last_update_login )
     VALUES (
             p_instance_id,
             p_org_id,
             p_resource_id,
             p_calendar_code,
             p_resource_instance_id,
             p_shift_num,
             p_calendar_date,
             p_from_time,
             p_to_time,
             p_assigned_qty,
             sysdate,
             FND_GLOBAL.USER_ID,
             sysdate,
             FND_GLOBAL.USER_ID,
             FND_GLOBAL.USER_ID ) ;
    END IF;
EXCEPTION
  WHEN  OTHERS THEN
     log_message('Error in Net Resource Avail Insert ');
     log_message(sqlerrm);

END net_rsrc_avail_insert;

/*
REM+=========================================================================+
REM| FUNCTION NAME                                                           |
REM|    ORG_STRING                                                           |
REM| DESCRIPTION                                                             |
REM|    To find out the organization string                                  |
REM| HISTORY                                                                 |
REM| 12/21/2005   Rajesh Patangya                                            |
REM+=========================================================================+
*/
FUNCTION ORG_STRING(instance_id IN PLS_INTEGER) return BOOLEAN IS

 sql_stmt         varchar2(7000);
 c_str            ref_cursor_typ ;
 l_aps_compatible PLS_INTEGER ;
 org_str          varchar2(32767) ;
 in_position      PLS_INTEGER ;

BEGIN
 sql_stmt           := NULL ;
 l_aps_compatible   := 0 ;
 org_str            := NULL ;
 in_position        := -10 ;

    SELECT MSC_CL_GMP_UTILITY.is_aps_compatible
    INTO l_aps_compatible  FROM DUAL ;

    IF l_aps_compatible = 1 THEN

--       sql_stmt := 'SELECT MSC_CL_PULL.get_org_str(' || instance_id || ') FROM dual ' ;
--       OPEN c_str FOR sql_stmt ;
--
--       FETCH c_str INTO org_str ;
--       log_message(' String From APS : ' || org_str);
--       CLOSE c_str ;
       /* Bug 5148376 per base bug changes */
       org_str := MSC_CL_PULL.get_org_str(instance_id);

         in_position := instr(org_str,'IN');

         /* B3450303, For all org or specific org, APS will provide valid org string
            We have to find the IN part in the string, otherwise have to raise
            Exception message for error condition */

         IF in_position > 0 THEN
         	gmp_calendar_pkg.g_in_str_org  := org_str ;
        	return TRUE  ;
         ELSE
         	gmp_calendar_pkg.g_in_str_org := NULL ;
        	return FALSE ;
         END IF;
    ELSE
     /* For older patchset This value should be TRUE */
        gmp_calendar_pkg.g_in_str_org := NULL ;
        return TRUE  ;
    END IF;

EXCEPTION
     WHEN OTHERS THEN
       log_message('Error in org_string ');
       log_message(sqlerrm);
       gmp_calendar_pkg.g_in_str_org := NULL ;
       return FALSE ;
END ORG_STRING;

/*
REM+=========================================================================+
REM| PROCEDURE NAME                                                          |
REM|    time_stamp                                                           |
REM| DESCRIPTION                                                             |
REM|                                                                         |
REM| HISTORY                                                                 |
REM| 12/21/2005   Rajesh Patangya                                            |
REM+=========================================================================+
*/
PROCEDURE time_stamp IS

  cur_time VARCHAR2(25) ;
BEGIN
  cur_time := NULL ;

   SELECT to_char(sysdate,'DD-MON-RRRR HH24:MI:SS')
   INTO cur_time FROM sys.dual ;

   log_message(cur_time);
EXCEPTION
   WHEN OTHERS THEN
     log_message('Failure occured in time_stamp');
     log_message(sqlerrm);
     RAISE;
END time_stamp ;

END gmp_calendar_pkg;

/
