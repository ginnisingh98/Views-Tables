--------------------------------------------------------
--  DDL for Package Body OPI_DBI_RES_OPM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_DBI_RES_OPM_PKG" AS
/* $Header: OPIDREOB.pls 115.6 2004/07/19 05:17:41 vganeshk noship $ */

g_sysdate                DATE       := SYSDATE;
g_user_id                NUMBER     := nvl(fnd_global.user_id, -1);
g_login_id               NUMBER     := nvl(fnd_global.login_id, -1);
g_global_start_date      DATE       := SYSDATE;
g_global_currency_code   VARCHAR2(10);
g_last_collection_date   DATE;
g_number_max_value       NUMBER;
g_degree                 NUMBER     := 1;
g_ok                     NUMBER(1)  := 0;
g_warning                NUMBER(1)  := 1;
g_error                  NUMBER(1)  := -1;
g_hr_uom                 sy_uoms_mst.um_code%TYPE;

/*
PROCEDURE put_line(p_msg VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    insert into pdong_debug_tbl(msg_seq, msg, msg_date)
    values (pdong_sequence.nextval, p_msg, sysdate);
    commit;
END;
*/

PROCEDURE check_setup_globals(errbuf IN OUT NOCOPY VARCHAR2 , retcode IN OUT NOCOPY VARCHAR2) IS

   l_list dbms_sql.varchar2_table;

   l_from_date  DATE;
   l_to_date    DATE;
   l_missing_day_flag BOOLEAN := FALSE;
   l_err_num    NUMBER;
   l_err_msg    VARCHAR2(255);
   l_min_miss_date DATE;
   l_max_miss_date DATE;
BEGIN

--dbms_output.put_line('starting opi_dbi_res_OPM_pkg.check_setup_globals');

   retcode   := 0;
   l_list(1) := 'BIS_PRIMARY_CURRENCY_CODE';
   l_list(2) := 'BIS_GLOBAL_START_DATE';

   IF (bis_common_parameters.check_global_parameters(l_list)) THEN
      SELECT Trunc(bis_common_parameters.get_global_start_date)
	INTO g_global_start_date FROM dual;

      SELECT bis_common_parameters.get_currency_code
	INTO g_global_currency_code FROM dual;

      select sysdate into l_to_date from dual;

      -- check_missing_date
/*
      fii_time_api.check_missing_date( l_from_date, l_to_date, l_missing_day_flag,
				       l_min_miss_date, l_max_miss_date);
*/
      IF l_missing_day_flag THEN
	 retcode := 2;
	 errbuf  := 'Please check log file for details. ';
	 BIS_COLLECTION_UTILITIES.PUT_LINE('There are missing date in Time Dimension.');

	 BIS_COLLECTION_UTILITIES.PUT_LINE('The range is from ' || l_min_miss_date
					   ||' to ' || l_max_miss_date );
      END IF;
    ELSE
      retcode := 2;
      errbuf  := 'Please check log file for details. ';
      BIS_COLLECTION_UTILITIES.PUT_LINE('Global Parameters are not setup.');

      BIS_COLLECTION_UTILITIES.put_line('Please check that the profile options: BIS_PRIMARY_CURRENCY_CODE and BIS_GLOBAL_START_DATE are setup.');

   END  IF;

   g_hr_uom := fnd_profile.value('SY$UOM_HOURS');

EXCEPTION
   WHEN OTHERS THEN
      retcode := SQLCODE;
      errbuf := 'ERROR in OPI_DBI_RES_PKG.CHECK_SETUP_GLOBALS '
	|| substr(SQLERRM, 1,200);

      BIS_COLLECTION_UTILITIES.PUT_LINE('Error Number: ' ||  retcode);
      BIS_COLLECTION_UTILITIES.PUT_LINE('Error Message: ' || errbuf);

    --dbms_output.put_line('check_setup_globals ' || errbuf);

END check_setup_globals;


PROCEDURE initial_opm_res_avail  (errbuf in out NOCOPY varchar2,
				  retcode in out NOCOPY varchar2)
IS
  l_stmt_num  NUMBER;
  l_rowcount NUMBER;
BEGIN

--dbms_output.put_line('starting initial_opm_res_avail');

   retcode := g_ok;

   l_stmt_num := 10;

   -- populate availability for opm resource

--dbms_output.put_line('Preparing to Insert OPM Resource Availability into opi_dbi_res_avail_stg');
--dbms_output.put_line('g_hr_uom := ' || g_hr_uom);
--dbms_output.put_line('g_global_start_date = ' || to_char(g_global_start_date));

   INSERT /*+ APPEND */ INTO opi_dbi_res_avail_stg
     ( resource_id, organization_id, department_id, transaction_date,
       uom, avail_qty, avail_qty_g, avail_val_b, source,
       creation_date, last_update_date, created_by,
       last_updated_by, last_update_login)
   SELECT /*+ ORDERED */
       r.resource_id            resource_id,
       r.organization_id        organization_id,
       r.department_id          department_id,
       r.shift_date             transaction_date,
       r.usage_um               uom,
       SUM(r.shift_hours * hruom.std_factor / ruom.std_factor)
                                avail_qty,
       SUM(r.shift_hours) avail_qty_g, -- availability in hours
       SUM(r.shift_hours * hruom.std_factor / rcostuom.std_factor * rcost.nominal_cost)
                                 avail_val_b,
       2                         source,
       SYSDATE                   creation_date,
       SYSDATE                   last_update_date,
       g_user_id                 created_by,
       g_user_id                 last_updated_by,
       g_login_id                last_update_login
   FROM
       (
        SELECT /*+ ORDERED */
            rdtl.orgn_code,
            rdtl.resources,
            rdtl.resource_id,
            rmst.resource_class department_id,
            rdtl.usage_um,
            plant.co_code,
            pol.gl_cost_mthd cost_mthd_code,
            whse.mtl_organization_id organization_id,
            ravail.shift_date,
            SUM((ravail.to_time - ravail.from_time)/3600) shift_hours
        FROM
            cr_rsrc_dtl rdtl,
            cr_rsrc_mst_b rmst,
            sy_orgn_mst_b plant,
            gl_plcy_mst pol,
            ic_whse_mst whse,
            gmp_resource_avail ravail
        WHERE
            rmst.resources = rdtl.resources
        AND plant.orgn_code = rdtl.orgn_code
        AND pol.co_code = plant.co_code
        AND whse.whse_code = plant.resource_whse_code
        AND ravail.plant_code = rdtl.orgn_code
        AND ravail.resource_id = rdtl.resource_id
        AND NVL(ravail.resource_instance_id,0) = 0 -- exclude individual resource instances
        AND ravail.shift_date BETWEEN g_global_start_date AND SYSDATE
        AND ravail.shift_date >= trunc(rdtl.creation_date)
        GROUP BY
            rdtl.orgn_code,
            rdtl.resources,
            rdtl.resource_id,
            rmst.resource_class,
            rdtl.usage_um,
            plant.co_code,
            pol.gl_cost_mthd,
            whse.mtl_organization_id,
            ravail.shift_date
       ) r,
       sy_uoms_mst ruom,
       (
        SELECT
            hdr.cost_mthd_code,
            dtl.calendar_code,
            dtl.period_code,
            dtl.start_date,
            dtl.end_date
        FROM
            cm_cldr_hdr_b hdr,
            cm_cldr_dtl dtl
        WHERE
            hdr.calendar_code = dtl.calendar_code
        AND dtl.end_date >= g_global_start_date
        AND dtl.start_date <= sysdate
       ) cal,
       cm_rsrc_dtl rcost,
       sy_uoms_mst rcostuom,
       sy_uoms_mst hruom
   WHERE
       r.cost_mthd_code = cal.cost_mthd_code
   AND r.shift_date BETWEEN cal.start_date AND cal.end_date
   AND rcost.orgn_code = r.orgn_code
   AND rcost.resources = r.resources
   AND rcost.cost_mthd_code = cal.cost_mthd_code
   AND rcost.calendar_code = cal.calendar_code
   AND rcost.period_code = cal.period_code
   AND hruom.um_code = g_hr_uom
   AND ruom.um_code = r.usage_um
   AND rcostuom.um_code = rcost.usage_um
   GROUP BY
       r.resource_id,
       r.organization_id,
       r.department_id,
       r.shift_date,
       r.usage_um;

   l_rowcount := sql%rowcount;

   COMMIT;

   BIS_COLLECTION_UTILITIES.put_line('OPM Resource Availability: ' ||
             to_char(l_rowcount) || ' rows initially collected into staging table at '||
             to_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Exception in initial_opm_res_avail ' || errbuf );

     --dbms_output.put_line('initial_opm_res_avail ' || errbuf);
END initial_opm_res_avail;


PROCEDURE initial_opm_res_actual  (errbuf in out NOCOPY varchar2,
				  retcode in out NOCOPY varchar2) IS
   l_stmt_num  NUMBER;
   l_rowcount NUMBER;

BEGIN

   retcode := g_ok;
   check_setup_globals(errbuf, retcode);

--dbms_output.put_line('Preparing to insert into opi_dbi_res_actual_stg');
--dbms_output.put_line('g_hr_uom = ' || g_hr_uom);
--dbms_output.put_line('g_global_start_date = ' || to_char(g_global_start_date));


   INSERT /*+ APPEND */ INTO opi_dbi_res_actual_stg
     ( resource_id, organization_id, transaction_date,
       actual_qty, uom, actual_qty_g, actual_val_b, source,
       job_id, job_type, assembly_item_id, department_id,
       creation_date, last_update_date, created_by,
       last_updated_by, last_update_login )
   SELECT
       r.resource_id                 resource_id,
       r.organization_id             organization_id,
       r.transaction_date            transaction_date,
       r.actual_qty                  actual_qty,
       r.uom                         uom,
       r.actual_qty_g                actual_qty_g,
       r.actual_qty
        * rcost.nominal_cost         actual_qty_b,
       2                             source,
       r.job_id                      job_id,
       4                             job_type,
       r.assembly_item_id            assembly_item_id,
       r.department_id               department_id,
       SYSDATE                       creation_date,
       SYSDATE                       last_update_date,
       g_user_id                     created_by,
       g_user_id                     last_updated_by,
       g_login_id                    last_update_login
   FROM
       (
       SELECT /*+ ORDERED */
           msi.inventory_item_id         assembly_item_id,
           rtran.doc_id                  job_id,
           rdtl.resource_id              resource_id,
           rdtl.resources                resources,
           rmst.resource_class           department_id,
           whse.mtl_organization_id      organization_id,
           TRUNC(rtran.trans_date)       transaction_date,
           SUM(rtran.resource_usage * prod.cost_alloc)          actual_qty,
           rtran.trans_um                uom,
           rtran.orgn_code               orgn_code,
           SUM(rtran.resource_usage * prod.cost_alloc * hruom.std_factor / ruom.std_factor)  actual_qty_g,
           pol.gl_cost_mthd              cost_mthd_code,
           pol.co_code                   co_code
       FROM
           sy_uoms_mst          hruom,
           opi_dbi_run_log_curr rlc,
           gme_resource_txns    rtran,
           sy_uoms_mst          ruom,
           cr_rsrc_dtl          rdtl,
           cr_rsrc_mst_b        rmst,
           sy_orgn_mst_b        plant,
           gl_plcy_mst          pol,
           ic_whse_mst          whse,
           gme_material_details prod,
           ic_item_mst_b        item,
           mtl_system_items_b   msi
       WHERE
           hruom.um_code = g_hr_uom
       AND rlc.etl_id = 4
       AND rlc.source = 2
       AND rtran.poc_trans_id >= rlc.start_txn_id
       AND rtran.poc_trans_id < rlc.next_start_txn_id
       AND rtran.completed_ind = 1
       AND ruom.um_code = rtran.trans_um
       AND rdtl.orgn_code = rtran.orgn_code
       AND rdtl.resources = rtran.resources
       AND rmst.resources = rdtl.resources
       AND plant.orgn_code = rdtl.orgn_code
       AND pol.co_code = plant.co_code
       AND whse.whse_code = plant.resource_whse_code
       AND prod.batch_id = rtran.doc_id
       AND prod.line_type = 1
       AND item.item_id = prod.item_id
       AND msi.organization_id = whse.mtl_organization_id
       AND msi.segment1 = item.item_no
       GROUP BY
           msi.inventory_item_id,
           rtran.doc_id,
           rdtl.resource_id,
           rdtl.resources,
           rmst.resource_class,
           whse.mtl_organization_id,
           TRUNC(rtran.trans_date),
           rtran.trans_um,
           rtran.orgn_code,
           pol.gl_cost_mthd,
           pol.co_code
       ) r,
       (
       SELECT
           hdr.co_code,
           hdr.cost_mthd_code,
           dtl.calendar_code,
           dtl.period_code,
           dtl.start_date,
           dtl.end_date
       FROM
           gl_plcy_mst pol,
           cm_cldr_hdr_b hdr,
           cm_cldr_dtl dtl
       WHERE
           hdr.co_code = pol.co_code
       AND hdr.cost_mthd_code = pol.gl_cost_mthd
       AND hdr.calendar_code = dtl.calendar_code
       AND dtl.end_date >= g_global_start_date
       AND dtl.start_date <= sysdate
       ) cal,
       cm_rsrc_dtl rcost
   WHERE
       r.co_code = cal.co_code
   AND r.cost_mthd_code = cal.cost_mthd_code
   AND r.transaction_date BETWEEN cal.start_date AND cal.end_date
   AND rcost.orgn_code = r.orgn_code
   AND rcost.resources = r.resources
   AND rcost.cost_mthd_code = cal.cost_mthd_code
   AND rcost.calendar_code = cal.calendar_code
   AND rcost.period_code = cal.period_code
   ;

   l_rowcount := sql%rowcount;

   COMMIT;

   BIS_COLLECTION_UTILITIES.put_line('OPM resource actuals: ' ||
               TO_CHAR(l_rowcount) || ' rows initially collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Exception in initial_opm_res_actual ' || errbuf );

--dbms_output.put_line('initial_opm_res_actual ' || errbuf);

END initial_opm_res_actual;


PROCEDURE initial_opm_res_std  (errbuf in out NOCOPY varchar2,
				retcode in out NOCOPY VARCHAR2,
				p_degree IN    NUMBER    ) IS
 l_stmt_num NUMBER;
 l_rowcount NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_error_flag  BOOLEAN := FALSE;

 l_opi_schema      VARCHAR2(30);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);

BEGIN

DECLARE
    lv_errbuf varchar2(1024);
    lv_retcode NUMBER;
BEGIN
    check_setup_globals(lv_errbuf,lv_retcode);
END;

--dbms_output.put_line('before insert into opi_dbi_res_std_f');

--dbms_output.put_line('g_hr_uom = ' || g_hr_uom);
--dbms_output.put_line('g_global_start_date = ' || to_char(g_global_start_date));

    INSERT INTO opi_dbi_res_std_f
        (resource_id,
        organization_id,
        transaction_date,
        std_usage_qty,
        uom,
        std_usage_qty_g,
        std_usage_val_b,
        std_usage_val_g,
        job_id,
        job_type,
        assembly_item_id,
        department_id,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    select
        jobres.resource_id                       resource_id,
        jobitem.organization_id                  organization_id,
        jobitem.completion_date                  transaction_date,
        sum(DECODE(jobres.scale_type,
          0, jobres.plan_rsrc_usage * jobitem.cost_alloc,
             ((jobres.plan_rsrc_usage * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
          ))                                      std_usage_qty,
        jobres.usage_um                          uom,
        sum(DECODE(jobres.scale_type,
          0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
             ((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
          ))                                      std_usage_qty_g,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                  ((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost)
                                                 std_usage_val_b,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                  ((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost
                 * jobitem.conversion_rate)       std_usage_val_g,
        jobitem.job_id                           job_id,
        jobitem.job_type                         job_type,
        jobitem.assembly_item_id                 assembly_item_id,
        jobres.department_id                     department_id,
        jobitem.source                           source,
        SYSDATE                                  creation_date,
        SYSDATE                                  last_update_date,
        g_user_id                                created_by,
        g_user_id                                last_updated_by,
        g_login_id                               last_update_login
    FROM
        (
            SELECT
                job.organization_id,
                job.assembly_item_id,
                bmatl.plan_qty,
                bmatl.actual_qty,
                bmatl.cost_alloc,
                job.job_id,
                job.completion_date,
                job.conversion_rate,
                job.job_type,
                job.source
            FROM
                opi_dbi_jobs_f job,
                mtl_system_items_b msi,
                ic_item_mst_b i,
                gme_material_details bmatl
            WHERE
                job.job_type = 4
            AND job.std_res_flag = 1
            AND bmatl.batch_id = job.job_id
            AND bmatl.line_type = 1                    -- coproducts
            AND msi.inventory_item_id = job.assembly_item_id
            AND msi.organization_id = job.organization_id
            AND i.item_no = msi.segment1
            AND bmatl.item_id = i.item_id
        ) jobitem,
        (
            SELECT /*+ ORDERED */
                job.job_id,
                job.assembly_item_id,
                bres.scale_type,
                resdtl.usage_um,
                resdtl.resource_id,
                resdtl.orgn_code,
                resdtl.resources,
                resmst.resource_class department_id,
                bres.plan_rsrc_usage * bresuom.std_factor / ruom.std_factor  plan_rsrc_usage,
                bres.plan_rsrc_usage * bresuom.std_factor / hruom.std_factor plan_rsrc_usage_g,
                pol.gl_cost_mthd
            FROM
                opi_dbi_jobs_f job,
                gme_batch_header bhdr,
                gme_batch_steps bstep,
                gme_batch_step_resources bres,
                cr_rsrc_dtl resdtl,
                cr_rsrc_mst_b resmst,
                sy_orgn_mst_b o,
                gl_plcy_mst pol,
                sy_uoms_mst bresuom,
                sy_uoms_mst ruom,
                sy_uoms_mst hruom
            WHERE
                job.std_res_flag = 1
            AND job.job_type = 4
            AND bhdr.batch_id = job.job_id
            AND o.orgn_code = bhdr.plant_code
            AND pol.co_code = o.co_code
            AND bstep.batch_id = job.job_id
            AND bres.batchstep_id = bstep.batchstep_id
            AND resdtl.orgn_code = bhdr.plant_code
            AND resdtl.resources = bres.resources
            AND resmst.resources = resdtl.resources
            AND bresuom.um_code = bres.usage_uom
            AND ruom.um_code = resdtl.usage_um
            AND hruom.um_code = g_hr_uom
        ) jobres,
        (
            SELECT
                hdr.cost_mthd_code,
                dtl.calendar_code,
                dtl.period_code,
                dtl.start_date,
                dtl.end_date
            FROM
                cm_cldr_hdr_b hdr,
                cm_cldr_dtl dtl
            WHERE
                hdr.calendar_code = dtl.calendar_code
            AND dtl.end_date >= g_global_start_date
            AND dtl.start_date <= sysdate
        ) cal,
        cm_rsrc_dtl rescost,
        sy_uoms_mst jobres_uom,
        sy_uoms_mst rescost_uom
    WHERE
        jobres.job_id = jobitem.job_id -- combine all batch resources with all batch coproducts
    AND jobres.assembly_item_id = jobitem.assembly_item_id
    AND cal.cost_mthd_code = jobres.gl_cost_mthd
    AND jobitem.completion_date BETWEEN cal.start_date AND cal.end_date
    AND rescost.resources = jobres.resources
    AND rescost.orgn_code = jobres.orgn_code
    AND rescost.calendar_code = cal.calendar_code
    AND rescost.period_code = cal.period_code
    AND jobres_uom.um_code = jobres.usage_um
    AND rescost_uom.um_code = rescost.usage_um
    group by
       jobitem.organization_id,
       jobres.department_id,
       jobitem.job_id,
       jobitem.job_type,
       jobitem.assembly_item_id,
       jobres.usage_um,
       jobres.resource_id,
       jobitem.completion_date,
       jobitem.source;

l_rowcount := SQL%ROWCOUNT;

      --  update JOb master's flag, for source 2
      UPDATE opi_dbi_jobs_f SET std_res_flag = 0,
	creation_date 		= sysdate,
	last_update_date 	= sysdate,
	created_by		= g_user_id,
        last_updated_by		= g_user_id,
	last_update_login	= g_login_id
	WHERE std_res_flag = 1
	AND source = 2;

      COMMIT;

   BIS_COLLECTION_UTILITIES.put_line('OPM resource std: ' ||
               TO_CHAR(l_rowcount) || ' rows initially collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;
   bis_collection_utilities.wrapup(p_status => FALSE,
				   p_count => 0,
				   p_message => 'failed in complete_refresh_margin.'
				   );

   RAISE_APPLICATION_ERROR(-20000,errbuf);

END initial_opm_res_std;


PROCEDURE incremental_opm_res_avail  (errbuf in out NOCOPY varchar2,
				  retcode in out NOCOPY varchar2)
IS
  l_stmt_num  NUMBER;
  l_last_collection_date DATE;
  l_rowcount NUMBER;
BEGIN

--dbms_output.put_line('starting incremental_opm_res_avail');

   retcode := g_ok;

   l_stmt_num := 10;

   -- get boundary
   SELECT Trunc(last_collection_date)
     INTO l_last_collection_date
     FROM opi_dbi_run_log_curr
     WHERE etl_id = 5
     AND source   = 2;

   -- if not sysdate, start from the day after last_collection_date
   IF l_last_collection_date <> Trunc(Sysdate) THEN
      l_last_collection_date := l_last_collection_date + 1;
   END IF;

--dbms_output.put_line('l_last_collection_date ' || l_last_collection_date );

   -- populate availability for opm resource

--dbms_output.put_line('Preparing to Insert OPM Resource Availability into opi_dbi_res_avail_stg');
--dbms_output.put_line('g_hr_uom := ' || g_hr_uom);
--dbms_output.put_line('g_global_start_date = ' || to_char(g_global_start_date));

   INSERT INTO opi_dbi_res_avail_stg
     ( resource_id, organization_id, department_id, transaction_date,
       uom, avail_qty, avail_qty_g, avail_val_b, source,
       creation_date, last_update_date, created_by,
       last_updated_by, last_update_login)
   SELECT
       r.resource_id            resource_id,
       r.organization_id        organization_id,
       r.department_id          department_id,
       r.shift_date             transaction_date,
       r.usage_um               uom,
       SUM(r.shift_hours * hruom.std_factor / ruom.std_factor)
                                avail_qty,
       SUM(r.shift_hours) avail_qty_g, -- availability in hours
       SUM(r.shift_hours * hruom.std_factor / rcostuom.std_factor * rcost.nominal_cost)
                                 avail_val_b,
       2                         source,
       SYSDATE                   creation_date,
       SYSDATE                   last_update_date,
       g_user_id                 created_by,
       g_user_id                 last_updated_by,
       g_login_id                last_update_login
   FROM
       sy_uoms_mst hruom,
       sy_uoms_mst ruom,
       sy_uoms_mst rcostuom,
       (
        SELECT
            rdtl.orgn_code,
            rdtl.resources,
            rdtl.resource_id,
            rmst.resource_class department_id,
            rdtl.usage_um,
            plant.co_code,
            pol.gl_cost_mthd cost_mthd_code,
            whse.mtl_organization_id organization_id,
            ravail.shift_date,
            SUM((ravail.to_time - ravail.from_time)/3600) shift_hours
        FROM
            cr_rsrc_dtl rdtl,
            cr_rsrc_mst_b rmst,
            sy_orgn_mst_b plant,
            gl_plcy_mst pol,
            ic_whse_mst whse,
            gmp_resource_avail ravail
        WHERE
            rmst.resources = rdtl.resources
        AND plant.orgn_code = rdtl.orgn_code
        AND pol.co_code = plant.co_code
        AND whse.whse_code = plant.resource_whse_code
        AND ravail.plant_code = rdtl.orgn_code
        AND ravail.resource_id = rdtl.resource_id
        AND NVL(ravail.resource_instance_id,0) = 0 -- exclude individual resource instances
        AND ravail.shift_date BETWEEN l_last_collection_date AND SYSDATE
        AND ravail.shift_date >= trunc(rdtl.creation_date)
        GROUP BY
            rdtl.orgn_code,
            rdtl.resources,
            rdtl.resource_id,
            rmst.resource_class,
            rdtl.usage_um,
            plant.co_code,
            pol.gl_cost_mthd,
            whse.mtl_organization_id,
            ravail.shift_date
       ) r,
       (
        SELECT
            hdr.cost_mthd_code,
            dtl.calendar_code,
            dtl.period_code,
            dtl.start_date,
            dtl.end_date
        FROM
            cm_cldr_hdr_b hdr,
            cm_cldr_dtl dtl
        WHERE
            hdr.calendar_code = dtl.calendar_code
        AND dtl.end_date >= g_global_start_date
        AND dtl.start_date <= sysdate
       ) cal,
       cm_rsrc_dtl rcost
   WHERE
       r.cost_mthd_code = cal.cost_mthd_code
   AND r.shift_date BETWEEN cal.start_date AND cal.end_date
   AND rcost.orgn_code = r.orgn_code
   AND rcost.resources = r.resources
   AND rcost.cost_mthd_code = cal.cost_mthd_code
   AND rcost.calendar_code = cal.calendar_code
   AND rcost.period_code = cal.period_code
   AND hruom.um_code = g_hr_uom
   AND ruom.um_code = r.usage_um
   AND rcostuom.um_code = rcost.usage_um
   GROUP BY
       r.resource_id,
       r.organization_id,
       r.department_id,
       r.shift_date,
       r.usage_um;

   l_rowcount := sql%rowcount;

   COMMIT;

   BIS_COLLECTION_UTILITIES.put_line('OPM resource availability: ' ||
               TO_CHAR(l_rowcount) || ' rows incrementally collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Exception in incremental_opm_res_avail ' || errbuf );

     --dbms_output.put_line('incremental_opm_res_avail ' || errbuf);
END incremental_opm_res_avail;



PROCEDURE incremental_opm_res_actual  (errbuf in out NOCOPY varchar2,
				  retcode in out NOCOPY varchar2) IS
   l_stmt_num  NUMBER;
   l_rowcount NUMBER;

BEGIN

   retcode := g_ok;

--dbms_output.put_line('Preparing to insert into opi_dbi_res_actual_stg');
--dbms_output.put_line('g_hr_uom = ' || g_hr_uom);
--dbms_output.put_line('g_global_start_date = ' || to_char(g_global_start_date));


   INSERT INTO opi_dbi_res_actual_stg
     ( resource_id, organization_id, transaction_date,
       actual_qty, uom, actual_qty_g, actual_val_b, source,
       job_id, job_type, assembly_item_id, department_id,
       creation_date, last_update_date, created_by,
       last_updated_by, last_update_login )
   SELECT
       r.resource_id                 resource_id,
       r.organization_id             organization_id,
       r.transaction_date            transaction_date,
       r.actual_qty                  actual_qty,
       r.uom                         uom,
       r.actual_qty_g                actual_qty_g,
       r.actual_qty
        * rcost.nominal_cost         actual_qty_b,
       2                             source,
       r.job_id                      job_id,
       4                             job_type,
       r.assembly_item_id            assembly_item_id,
       r.department_id               department_id,
       SYSDATE                       creation_date,
       SYSDATE                       last_update_date,
       g_user_id                     created_by,
       g_user_id                     last_updated_by,
       g_login_id                    last_update_login
   FROM
       (
       SELECT
           msi.inventory_item_id         assembly_item_id,
           rtran.doc_id                  job_id,
           rdtl.resource_id              resource_id,
           rdtl.resources                resources,
           rmst.resource_class           department_id,
           whse.mtl_organization_id      organization_id,
           TRUNC(rtran.trans_date)       transaction_date,
           SUM(rtran.resource_usage * prod.cost_alloc)          actual_qty,
           rtran.trans_um                uom,
           rtran.orgn_code               orgn_code,
           SUM(rtran.resource_usage * prod.cost_alloc * hruom.std_factor / ruom.std_factor)  actual_qty_g,
           pol.gl_cost_mthd              cost_mthd_code,
           pol.co_code                   co_code
       FROM
           cr_rsrc_dtl          rdtl,
           cr_rsrc_mst_b        rmst,
           sy_orgn_mst_b        plant,
           ic_whse_mst          whse,
           gme_resource_txns    rtran,
           gme_material_details prod,
           ic_item_mst_b        item,
           mtl_system_items_b   msi,
           gl_plcy_mst          pol,
           opi_dbi_run_log_curr rlc,
           sy_uoms_mst          hruom,
           sy_uoms_mst          ruom
       WHERE
           rlc.etl_id = 4
       AND rlc.source = 2
       AND rtran.poc_trans_id >= rlc.start_txn_id
       AND rtran.poc_trans_id < rlc.next_start_txn_id
       AND rtran.completed_ind = 1
       AND prod.batch_id = rtran.doc_id
       AND prod.line_type = 1
       AND item.item_id = prod.item_id
       AND msi.organization_id = whse.mtl_organization_id
       AND msi.segment1 = item.item_no
       AND rdtl.orgn_code = rtran.orgn_code
       AND rdtl.resources = rtran.resources
       AND rmst.resources = rdtl.resources
       AND plant.orgn_code = rdtl.orgn_code
       AND whse.whse_code = plant.resource_whse_code
       AND pol.co_code = plant.co_code
       AND hruom.um_code = g_hr_uom
       AND ruom.um_code = rtran.trans_um
       GROUP BY
           msi.inventory_item_id,
           rtran.doc_id,
           rdtl.resource_id,
           rdtl.resources,
           rmst.resource_class,
           whse.mtl_organization_id,
           TRUNC(rtran.trans_date),
           rtran.trans_um,
           rtran.orgn_code,
           pol.gl_cost_mthd,
           pol.co_code
       ) r,
       (
       SELECT
           hdr.co_code,
           hdr.cost_mthd_code,
           dtl.calendar_code,
           dtl.period_code,
           dtl.start_date,
           dtl.end_date
       FROM
           gl_plcy_mst pol,
           cm_cldr_hdr_b hdr,
           cm_cldr_dtl dtl
       WHERE
           hdr.co_code = pol.co_code
       AND hdr.cost_mthd_code = pol.gl_cost_mthd
       AND hdr.calendar_code = dtl.calendar_code
       AND dtl.end_date >= g_global_start_date
       AND dtl.start_date <= sysdate
       ) cal,
       cm_rsrc_dtl rcost
   WHERE
       r.co_code = cal.co_code
   AND r.cost_mthd_code = cal.cost_mthd_code
   AND r.transaction_date BETWEEN cal.start_date AND cal.end_date
   AND rcost.orgn_code = r.orgn_code
   AND rcost.resources = r.resources
   AND rcost.cost_mthd_code = cal.cost_mthd_code
   AND rcost.calendar_code = cal.calendar_code
   AND rcost.period_code = cal.period_code
   ;

   l_rowcount := sql%rowcount;

   COMMIT;

   BIS_COLLECTION_UTILITIES.put_line('OPM resource actuals: ' ||
               TO_CHAR(l_rowcount) || ' rows incrementally collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;

   BIS_COLLECTION_UTILITIES.PUT_LINE('Exception in incremental_opm_res_actual ' || errbuf );

--dbms_output.put_line('incremental_opm_res_actual ' || errbuf);

END incremental_opm_res_actual;



PROCEDURE incremental_opm_res_std  (errbuf in out NOCOPY varchar2,
				retcode in out NOCOPY VARCHAR2  ) IS
 l_stmt_num NUMBER;
 l_rowcount NUMBER;
 l_err_num NUMBER;
 l_err_msg VARCHAR2(255);
 l_error_flag  BOOLEAN := FALSE;

 l_opi_schema      VARCHAR2(30);
 l_status          VARCHAR2(30);
 l_industry        VARCHAR2(30);

BEGIN

DECLARE
    lv_errbuf varchar2(1024);
    lv_retcode NUMBER;
BEGIN
    check_setup_globals(lv_errbuf,lv_retcode);
END;

--dbms_output.put_line('before insert into opi_dbi_res_std_f');

--dbms_output.put_line('g_hr_uom = ' || g_hr_uom);
--dbms_output.put_line('g_global_start_date = ' || to_char(g_global_start_date));

   DELETE opi_dbi_res_std_f std
     WHERE (job_id, job_type)
     IN ( SELECT job_id, job_type
	  FROM opi_dbi_jobs_f
	  WHERE std_res_flag = 1
	  AND job_type = 4 -- need to extract again
	  );

    INSERT INTO opi_dbi_res_std_f
        (resource_id,
        organization_id,
        transaction_date,
        std_usage_qty,
        uom,
        std_usage_qty_g,
        std_usage_val_b,
        std_usage_val_g,
        job_id,
        job_type,
        assembly_item_id,
        department_id,
        source,
        creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        last_update_login)
    select
        jobres.resource_id                       resource_id,
        jobitem.organization_id                  organization_id,
        jobitem.completion_date                  transaction_date,
        sum(DECODE(jobres.scale_type,
          0, jobres.plan_rsrc_usage * jobitem.cost_alloc,
             ((jobres.plan_rsrc_usage * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
          ))                                      std_usage_qty,
        jobres.usage_um                          uom,
        sum(DECODE(jobres.scale_type,
          0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
             ((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
          ))                                      std_usage_qty_g,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                  ((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost)
                                                 std_usage_val_b,
        sum(DECODE(jobres.scale_type,
               0, jobres.plan_rsrc_usage_g * jobitem.cost_alloc,
                  ((jobres.plan_rsrc_usage_g * jobitem.cost_alloc) / jobitem.plan_qty) * jobitem.actual_qty
               ) * jobres_uom.std_factor / rescost_uom.std_factor * rescost.nominal_cost
                 * jobitem.conversion_rate)       std_usage_val_g,
        jobitem.job_id                           job_id,
        jobitem.job_type                         job_type,
        jobitem.assembly_item_id                 assembly_item_id,
        jobres.department_id                     department_id,
        jobitem.source                           source,
        SYSDATE                                  creation_date,
        SYSDATE                                  last_update_date,
        g_user_id                                created_by,
        g_user_id                                last_updated_by,
        g_login_id                               last_update_login
    FROM
        (
            SELECT
                job.organization_id,
                job.assembly_item_id,
                bmatl.plan_qty,
                bmatl.actual_qty,
                bmatl.cost_alloc,
                job.job_id,
                job.completion_date,
                job.conversion_rate,
                job.job_type,
                job.source
            FROM
                opi_dbi_jobs_f job,
                mtl_system_items_b msi,
                ic_item_mst_b i,
                gme_material_details bmatl
            WHERE
                job.job_type = 4
            AND job.std_res_flag = 1
            AND bmatl.batch_id = job.job_id
            AND bmatl.line_type = 1                    -- coproducts
            AND msi.inventory_item_id = job.assembly_item_id
            AND msi.organization_id = job.organization_id
            AND i.item_no = msi.segment1
            AND bmatl.item_id = i.item_id
        ) jobitem,
        (
            SELECT /*+ ORDERED */
                job.job_id,
                job.assembly_item_id,
                bres.scale_type,
                resdtl.usage_um,
                resdtl.resource_id,
                resdtl.orgn_code,
                resdtl.resources,
                resmst.resource_class department_id,
                bres.plan_rsrc_usage * bresuom.std_factor / ruom.std_factor  plan_rsrc_usage,
                bres.plan_rsrc_usage * bresuom.std_factor / hruom.std_factor plan_rsrc_usage_g,
                pol.gl_cost_mthd
            FROM
                opi_dbi_jobs_f job,
                gme_batch_header bhdr,
                gme_batch_steps bstep,
                gme_batch_step_resources bres,
                cr_rsrc_dtl resdtl,
                cr_rsrc_mst_b resmst,
                sy_orgn_mst_b o,
                gl_plcy_mst pol,
                sy_uoms_mst bresuom,
                sy_uoms_mst ruom,
                sy_uoms_mst hruom
            WHERE
                job.std_res_flag = 1
            AND job.job_type = 4
            AND bhdr.batch_id = job.job_id
            AND o.orgn_code = bhdr.plant_code
            AND pol.co_code = o.co_code
            AND bstep.batch_id = job.job_id
            AND bres.batchstep_id = bstep.batchstep_id
            AND resdtl.orgn_code = bhdr.plant_code
            AND resdtl.resources = bres.resources
            AND resmst.resources = resdtl.resources
            AND bresuom.um_code = bres.usage_uom
            AND ruom.um_code = resdtl.usage_um
            AND hruom.um_code = g_hr_uom
        ) jobres,
        (
            SELECT
                hdr.cost_mthd_code,
                dtl.calendar_code,
                dtl.period_code,
                dtl.start_date,
                dtl.end_date
            FROM
                cm_cldr_hdr_b hdr,
                cm_cldr_dtl dtl
            WHERE
                hdr.calendar_code = dtl.calendar_code
            AND dtl.end_date >= g_global_start_date
            AND dtl.start_date <= sysdate
        ) cal,
        cm_rsrc_dtl rescost,
        sy_uoms_mst jobres_uom,
        sy_uoms_mst rescost_uom
    WHERE
        jobres.job_id = jobitem.job_id -- combine all batch resources with all batch coproducts
    AND jobres.assembly_item_id = jobitem.assembly_item_id
    AND cal.cost_mthd_code = jobres.gl_cost_mthd
    AND jobitem.completion_date BETWEEN cal.start_date AND cal.end_date
    AND rescost.resources = jobres.resources
    AND rescost.orgn_code = jobres.orgn_code
    AND rescost.calendar_code = cal.calendar_code
    AND rescost.period_code = cal.period_code
    AND jobres_uom.um_code = jobres.usage_um
    AND rescost_uom.um_code = rescost.usage_um
    group by
       jobitem.organization_id,
       jobres.department_id,
       jobitem.job_id,
       jobitem.job_type,
       jobitem.assembly_item_id,
       jobres.usage_um,
       jobres.resource_id,
       jobitem.completion_date,
       jobitem.source;

    l_rowcount := SQL%ROWCOUNT;

      --  update JOb master's flag, for source 2
      UPDATE opi_dbi_jobs_f SET std_res_flag = 0,
	creation_date 		= sysdate,
	last_update_date 	= sysdate,
	created_by		= g_user_id,
        last_updated_by		= g_user_id,
	last_update_login	= g_login_id
	WHERE std_res_flag = 1
	AND source = 2;

   BIS_COLLECTION_UTILITIES.put_line('OPM resource std: ' ||
               TO_CHAR(l_rowcount) || ' rows incrementally collected into staging table at ' ||
               To_char(Sysdate, 'hh24:mi:ss dd-mon-yyyy'));

EXCEPTION WHEN OTHERS THEN

   Errbuf:= Sqlerrm;
   Retcode:= SQLCODE;

   ROLLBACK;
   bis_collection_utilities.wrapup(p_status => FALSE,
				   p_count => 0,
				   p_message => 'failed in complete_refresh_margin.'
				   );

   RAISE_APPLICATION_ERROR(-20000,errbuf);

END incremental_opm_res_std;



END opi_dbi_res_opm_pkg;

/
