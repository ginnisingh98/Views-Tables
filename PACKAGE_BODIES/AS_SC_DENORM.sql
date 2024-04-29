--------------------------------------------------------
--  DDL for Package Body AS_SC_DENORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_SC_DENORM" AS
/* $Header: asxopdpb.pls 120.4 2007/03/16 08:18:10 snsarava ship $ */

--
-- HISTORY
-- 04/07/2000       NACHARYA    Created
-- 12/21/2000       SOLIN       Bug 1498351
--                              Change to add a new concurrent program
--                              to refresh as_period_days table
-- 12/22/2000       SOLIN       Bug 1549115
--                              Add a new column BUSINESS_GROUP_NAME in
--                              AS_SALES_CREDITS_DENORM
-- 12/26/2000       SOLIN       Change to have debug message for concurrent
--                              program and trigger
-- 01/29/2001       SOLIN       Change to have dbms_stats.gather_table_stats
--                              for tables AS_SALES_CREDITS_DENORM and
--                              AS_MC_SALES_CREDITS_DEN in concurrent program.
-- 02/21/2001       SOLIN       Bug 1654262.
--                              Change to use daily rate for period rate
--                              in case user doesn't set up any daily rate for
--                              the period.
-- 04/12/2001       SOLIN       Change to fix the problem in incremental mode.
--                              Prevent insufficient rollback segment.
--

PROCEDURE write_log(p_module VARCHAR2, p_debug_source NUMBER, p_fpt number, p_mssg  varchar2) IS
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);

BEGIN

     --IF G_Debug AND p_debug_source = G_DEBUG_TRIGGER THEN
        -- Write debug message to message stack
       IF l_debug THEN
       	AS_UTILITY_PVT.Debug_Message(p_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, p_mssg);
       END IF;
     --END IF;

     IF p_debug_source = G_DEBUG_CONCURRENT THEN
            -- p_fpt (1,2)?(log : output)
            FND_FILE.put(p_fpt, p_mssg);
            FND_FILE.NEW_LINE(p_fpt, 1);
            -- If p_fpt == 2 and debug flag then also write to log file
            IF p_fpt = 2 And G_Debug THEN
               FND_FILE.put(1, p_mssg);
               FND_FILE.NEW_LINE(1, 1);
            END IF;
     END IF;

    EXCEPTION
        WHEN OTHERS THEN
         NULL;
END Write_Log;

-- Why doesn't use dbms_session.set_sql_trace(TRUE) ?
PROCEDURE trace (p_mode in boolean) is
ddl_curs integer;
v_Dummy  integer;
BEGIN
null;
EXCEPTION WHEN OTHERS THEN
 NULL;
END trace;

PROCEDURE Populate_as_period_days(
    ERRBUF                OUT NOCOPY VARCHAR2,
    RETCODE               OUT NOCOPY VARCHAR2,
    p_debug_mode          IN  VARCHAR2,
    p_trace_mode          IN  VARCHAR2) IS
ddl_curs       integer;
v_Dummy        integer;
curr_day       date;
l_status		Boolean;
l_fnd_status        VARCHAR2(2);
l_industry          VARCHAR2(2);
l_oracle_schema     VARCHAR2(32);
l_schema_return     BOOLEAN;
CURSOR c1 IS
    SELECT period_set_name, period_name, start_date, end_date, period_type
    FROM as_period_days;

  l_module CONSTANT VARCHAR2(255) := 'as.plsql.scden.Populate_as_period_days';

BEGIN
    l_schema_return := FND_INSTALLATION.get_app_info('AS', l_fnd_status, l_industry, l_oracle_schema);

    IF p_debug_mode = 'Y' THEN
        G_Debug := TRUE;
    ELSE
        G_Debug := FALSE;
    END IF;

    IF p_trace_mode = 'Y' THEN
        trace(TRUE);
    ELSE
        trace(FALSE);
    END IF;

    ddl_curs := dbms_sql.open_cursor;
    dbms_sql.parse(ddl_curs,'TRUNCATE TABLE ' || l_oracle_schema || '.AS_PERIOD_DAYS drop storage',
        dbms_sql.native);
    dbms_sql.close_cursor(ddl_curs);

    INSERT INTO as_period_days (period_set_name, period_name, period_day,
                start_date,end_date, period_type)
        SELECT period_set_name, period_name, trunc(start_date),
               trunc(start_date), trunc(end_date), period_type
        FROM gl_periods
        WHERE period_set_name =  FND_PROFILE.Value('AS_FORECAST_CALENDAR');
  --      AND adjustment_period_flag = 'N';
    COMMIT;

    FOR chg_tbl IN c1
    LOOP
        curr_day := chg_tbl.start_date + 1;
        WHILE  (curr_Day <= chg_tbl.end_date)
        LOOP
            INSERT INTO as_period_days (
                period_set_name, period_name, period_Day, start_date,
                end_date, period_type)
            VALUES (
                chg_tbl.period_set_name, chg_tbl.period_name, curr_day,
                chg_tbl.start_date, chg_tbl.end_date, chg_tbl.period_type);
            curr_day := curr_day + 1;
        END LOOP;
    END LOOP;
    COMMIT;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ERRBUF := ERRBUF||'Error in Populate_as_period_days:'
               || to_char(sqlcode) || sqlerrm;
        RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error in Populate_as_period_days');
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, sqlerrm);
        Rollback;
        l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
        IF l_status = TRUE THEN
            Write_Log(l_module, G_DEBUG_CONCURRENT, 1,
                'Error, can not complete Concurrent Program') ;
        END IF;
    WHEN OTHERS THEN
        ERRBUF := ERRBUF||'Error Populate_as_period_days:'
               || to_char(sqlcode) || sqlerrm;
        RETCODE := '2';
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error in Populate_as_period_days');
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, sqlerrm);
        Rollback;
        l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
        IF l_status = TRUE THEN
            Write_Log(l_module, G_DEBUG_CONCURRENT, 1,
                'Error, can not complete Concurrent Program') ;
        END IF ;
END Populate_as_period_days;

PROCEDURE clear_snapshots IS
l_fnd_status        VARCHAR2(2);
l_industry          VARCHAR2(2);
l_oracle_schema     VARCHAR2(32);
l_apps_schema       VARCHAR2(64);
l_schema_return     BOOLEAN;

cursor dr_obj is
  SELECT 'drop materialized view log on '||log_owner||'.'||master sqlstmt
   FROM all_snapshot_logs
  WHERE (log_owner = l_oracle_schema and master in ('AS_PERIOD_DAYS','AS_SALES_CREDITS_DENORM','AS_MC_SALES_CREDITS_DEN'))
  --or (log_owner = 'JTF' and master in ('JTF_RS_REP_MANAGERS','JTF_RS_GROUP_USAGES'))
  or (log_owner = l_apps_schema and master in ('ASF_SC_BIN_MV','ASF_SCBINLD_MV'))
  UNION ALL
  SELECT 'drop materialized view '||owner||'.'||name
   FROM user_snapshots
  WHERE name in ('ASF_SC_BIN_MV', 'ASF_SCBINMV_SUM_MV', 'ASF_SCBINLD_MV', 'ASF_SCBINLD_SUMMV', 'ASF_SCBIN_SUMMV')
  UNION ALL
  SELECT 'drop index '||owner||'.'||index_name
   FROM dba_indexes
  WHERE table_owner = l_apps_schema
  and table_name in ('ASF_SCBINLD_SUMMV','ASF_SCBIN_SUMMV');

ddl_curs integer;
BEGIN
  l_schema_return := FND_INSTALLATION.get_app_info('AS', l_fnd_status, l_industry, l_oracle_schema);

  SELECT USER INTO l_apps_schema FROM DUAL;

  ddl_curs := dbms_sql.open_cursor;
  /* Parse implicitly executes the DDL statements */
  FOR chg_tbl in dr_obj LOOP
   dbms_sql.parse(ddl_curs, chg_tbl.sqlstmt,dbms_sql.native) ;
  END LOOP;
  dbms_sql.close_cursor(ddl_curs);
EXCEPTION WHEN OTHERS THEN
 NULL;
END clear_snapshots;

PROCEDURE insert_scd (ERRBUF  OUT NOCOPY Varchar2,
    		      RETCODE OUT NOCOPY Varchar2,
                      p_cnt OUT NOCOPY Number) IS

  l_module CONSTANT VARCHAR2(255) := 'as.plsql.scden.insert_scd';
  --Code added for performance bug#5802537
  l_user_id NUMBER:= NVL(fnd_global.user_id,-1);
  l_login_id NUMBER:= NVL(fnd_global.login_id,-1);
  l_Conc_Request_Id NUMBER:= FND_GLOBAL.Conc_Request_Id;
  l_Conc_Program_Id NUMBER:= FND_GLOBAL.Conc_Program_Id;
  l_Prog_Appl_Id NUMBER:=FND_GLOBAL.Prog_Appl_Id;

BEGIN
   RETCODE := 0;
   --Hint added for performance bug#5802537
   INSERT /*+ APPEND PARALLEL(SCD) */ into as_sales_credits_denorm SCD
       (sales_credit_id,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        sales_group_id,
        sales_group_name,
        salesforce_id,
        employee_person_id,
        sales_rep_name,
        customer_id,
        customer_name,
	competitor_name,
        customer_category,
        customer_category_code,
        address_id,
        lead_id,
        lead_number,
        opp_description,
        decision_date,
        sales_stage_id,
        sales_stage,
        win_probability,
        status_code,
        status,
        channel_code,
        lead_source_code,
        orig_system_reference,
        lead_line_id,
        interest_type_id,
        primary_interest_code_id,
        secondary_interest_code_id,
        product_category_id,
        product_cat_set_id,
        currency_code,
        total_amount,
        sales_credit_amount,
        won_amount,
        weighted_amount,
        c1_currency_code,
        c1_total_amount,
        c1_sales_credit_amount,
        c1_won_amount,
        c1_weighted_amount,
        last_name,
        first_name,
        org_id,
        --interest_type,
        --primary_interest_code,
        --secondary_interest_code,
        opportunity_last_update_date,
        opportunity_last_updated_by,
        request_id,
        program_id,
        program_application_id,
        program_update_date,
        conversion_status_flag,
        credit_type_id,
        quantity,
        uom_code,
        uom_description,
        forecast_rollup_flag,
        win_loss_indicator,
        item_id,
        organization_id,
        item_description,
        partner_customer_id,
        partner_address_id,
        partner_customer_name,
        parent_project,
        sequence,
        employee_number,
        opp_open_status_flag,
        opp_deleted_flag,
        party_type,
        revenue_flag,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        opportunity_last_updated_name,
        opportunity_created_by,
        opportunity_creation_date,
        opportunity_created_name,
        close_reason,
        close_reason_meaning,
        business_group_name,
        source_promotion_id,
	close_competitor_id,
   	owner_salesforce_id,
     	owner_sales_group_id,
	owner_person_name,
      	owner_last_name,
    	owner_first_name,
     	owner_group_name,
        sales_methodology_id,
        forecast_date,
        rolling_forecast_flag,
        opp_worst_forecast_amount,
        opp_forecast_amount,
        opp_best_forecast_amount
        )
Select /*+ PARALLEL(SC) PARALLEL(LEAD) PARALLEL(CUST) PARALLEL(JRS) PARALLEL(CMPTR) PARALLEL(LL) PARALLEL(MTLSITL)
	   PARALLEL(JRS0) PARALLEL(JRS1) PARALLEL(JRS2) PARALLEL(ORG) PARALLEL(PD)
	   USE_HASH(LEAD, CUST) */
  	sc.sales_credit_id,
        sysdate,
        l_user_id,
        sysdate,
        l_user_id,
        l_login_id,
        sc.salesgroup_id,
        sg.group_name,
        nvl(sc.salesforce_id,-1),
        sc.person_id,
        decode(jrs.category,'EMPLOYEE',jrs.source_name,'PARTY',jrs.source_name,Null),
        nvl(lead.customer_id,-1),
        cust.party_name,
	cmptr.party_name,
        arlkp1.meaning,
        cust.category_code,
        lead.address_id,
        nvl(lead.lead_id,-1),
        nvl(lead.lead_number,-1),
        lead.description,
        trunc(lead.decision_date),
        nvl(lead.sales_stage_id,-1),
        sales.name,
        lead.win_probability,
        nvl(lead.status,'-'),
        status.meaning,
        lead.channel_code,
        lead.lead_source_code,
        lead.orig_system_reference,
        nvl(ll.lead_line_id,-1),
        ll.interest_type_id,
        ll.primary_interest_code_id,
        ll.secondary_interest_code_id,
        ll.product_category_id,
        ll.product_cat_set_id,
        lead.currency_code,
        lead.total_amount,
        decode(sc.credit_percent,null,nvl(sc.credit_amount,0),(sc.credit_percent / 100) * ll.total_amount),
        decode(status.WIN_LOSS_INDICATOR,'W',decode(sc.credit_percent,null,nvl(sc.credit_amount,0), (sc.credit_percent / 100) *
		ll.total_amount),0),
        (decode(sc.credit_percent,null,nvl(sc.credit_amount,0), (sc.credit_percent / 100) *
		ll.total_amount)* nvl(lead.win_probability,0)/100),
        G_PREFERRED_CURRENCY,
        ((((nvl(lead.total_amount,0) /denominator_rate) * numerator_rate) / minimum_accountable_unit) *  minimum_accountable_unit),
        ((((decode(sc.credit_percent,null,nvl(sc.credit_amount,0),(sc.credit_percent / 100) * ll.total_amount) /denominator_rate) *
		numerator_rate) / minimum_accountable_unit) *  minimum_accountable_unit),
        ((((decode(status.WIN_LOSS_INDICATOR,'W',decode(sc.credit_percent,null,nvl(sc.credit_amount,0), (sc.credit_percent / 100) *
		ll.total_amount),0) /denominator_rate) * numerator_rate) / minimum_accountable_unit) *  minimum_accountable_unit),
        (((((decode(sc.credit_percent,null,nvl(sc.credit_amount,0), (sc.credit_percent / 100) * ll.total_amount)*
		nvl(lead.win_probability,0)/100) /denominator_rate) * numerator_rate) / minimum_accountable_unit) *
		minimum_accountable_unit),
        decode(jrs.category,'EMPLOYEE',jrs.source_last_name,'PARTY',jrs.source_last_name,Null),
        decode(jrs.category,'EMPLOYEE',jrs.source_first_name,'PARTY',jrs.source_first_name,Null),
        lead.org_id,
        nvl(lead.last_update_date,sysdate),
        nvl(lead.last_updated_by,-1),
        l_Conc_Request_Id,
        l_Conc_Program_Id,
        l_Prog_Appl_Id,
        sysdate,
        pr.conversion_status_flag,
        sc.credit_type_id,
        ll.quantity,
        ll.uom_code,
        mtluom.unit_of_measure_tl,
        status.forecast_rollup_flag,
        status.win_loss_indicator,
        ll.inventory_item_id,
        ll.organization_id,
        mtlsitl.description,
        sc.partner_customer_id,
        sc.partner_address_id,
        decode(jrs.category,'PARTNER',jrs.source_name,Null),
        lead.parent_project,
        null, -- sequence
        decode(jrs.category,'EMPLOYEE',jrs.source_number,'PARTY',jrs.source_number,Null),
        status.opp_open_status_flag,
        lead.deleted_flag,
        cust.party_type,
        ctypes.quota_flag,
        lead.attribute_category,
        lead.attribute1,
        lead.attribute2,
        lead.attribute3,
        lead.attribute4,
        lead.attribute5,
        lead.attribute6,
        lead.attribute7,
        lead.attribute8,
        lead.attribute9,
        lead.attribute10,
        lead.attribute11,
        lead.attribute12,
        lead.attribute13,
        lead.attribute14,
        lead.attribute15,
        jrs0.source_name,
        lead.created_by,
        lead.creation_date,
        jrs1.source_name,
        lead.close_reason,
        aslkp.meaning,
        org.name,
        lead.source_promotion_id,
	lead.close_competitor_id,
   	lead.owner_salesforce_id,
     	lead.owner_sales_group_id,
        decode(jrs2.category,'EMPLOYEE',jrs2.source_name,'PARTY',jrs2.source_name,Null),
        decode(jrs2.category,'EMPLOYEE',jrs2.source_last_name,'PARTY',jrs2.source_last_name,Null),
        decode(jrs2.category,'EMPLOYEE',jrs2.source_first_name,'PARTY',jrs2.source_first_name,Null),
        sg2.group_name,
        lead.sales_methodology_id,
        trunc(nvl(ll.forecast_date, lead.decision_date)),
        ll.rolling_forecast_flag,
        sc.opp_worst_forecast_amount,
        sc.opp_forecast_amount,
        sc.opp_best_forecast_amount
 From
       as_sales_stages_all_tl sales,
       jtf_rs_resource_extns jrs,
       jtf_rs_groups_tl sg,
       jtf_rs_groups_tl sg2,
       as_statuses_vl status,
       hz_parties cust,
       hz_parties cmptr,
       as_lead_lines_all ll,
       as_leads_all lead,
       as_sales_credits sc,
       ar_lookups arlkp1, as_lookups aslkp,
       mtl_system_items_tl mtlsitl,
       mtl_units_of_measure_tl mtluom,
       aso_i_sales_credit_types_v ctypes,
       --as_interest_codes_tl pic, as_interest_codes_tl sic, as_interest_types_tl it,
       jtf_rs_resource_extns jrs0, jtf_rs_resource_extns jrs1,
       jtf_rs_resource_extns jrs2,
       hr_all_organization_units_tl org,
       as_period_rates pr, as_period_days pd
 Where
       ll.lead_id = lead.lead_id
       and ll.lead_line_id = sc.lead_line_id
       and lead.sales_stage_id = sales.sales_stage_id(+)
       and sales.language(+) = G_LANG
       and lead.status = status.status_code
       and cust.party_id = lead.customer_id
       and cmptr.party_id(+) = lead.close_competitor_id
       and jrs.resource_id(+) = sc.salesforce_id
       and jrs2.resource_id(+) = lead.owner_salesforce_id
       and sc.salesgroup_id = sg.group_id(+)
       and sg.language(+) = G_LANG
       and sg2.group_id(+) = lead.owner_sales_group_id
       and sg2.language(+) = G_LANG
       and arlkp1.lookup_type(+) = 'CUSTOMER_CATEGORY'
       and cust.category_code = arlkp1.lookup_code(+)
       and aslkp.lookup_type(+) = 'CLOSE_REASON'
       and lead.close_reason = aslkp.lookup_code(+)
       and ll.uom_code = mtluom.uom_code(+)
       and mtluom.language(+) = G_LANG
       and ll.inventory_item_id = mtlsitl.inventory_item_id(+)
       and ll.organization_id = mtlsitl.organization_id(+)
       and mtlsitl.language(+) = G_LANG
       and sc.credit_type_id = ctypes.sales_credit_type_id
       and lead.last_updated_by = jrs0.user_id (+)
       and lead.created_by = jrs1.user_id (+)
       and lead.org_id = org.organization_id(+)
       and org.language(+) = G_LANG
       and (pr.from_currency = lead.currency_code or pr.from_currency is null)
       and pr.to_currency(+) = G_PREFERRED_CURRENCY
       and pr.conversion_type(+) = G_CONVERSION_TYPE
       and pr.conversion_status_flag(+) = 0
       and pr.period_name(+) = pd.period_name
       and pd.period_day(+) = lead.DECISION_DATE
       and pd.period_type(+) = G_PERIOD_TYPE;
       p_cnt := sql%rowcount;
 EXCEPTION WHEN OTHERS THEN
     ERRBUF := ERRBUF||sqlerrm;
     RETCODE := '1';
     Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error in insert_scd: '||SQLCODE);
     Write_Log(l_module, G_DEBUG_CONCURRENT, 1,substr(sqlerrm,1,700));
     --RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END insert_scd;

PROCEDURE Bulk_update_sc_Denorm (ERRBUF OUT NOCOPY varchar2,
		      	         RETCODE OUT NOCOPY varchar2,
                                 p_last IN Number) IS

  l_module CONSTANT VARCHAR2(255) := 'as.plsql.scden.Bulk_update_sc_Denorm';

BEGIN
       ForALL J in 1 .. p_last
		UPDATE AS_SALES_CREDITS_DENORM
		    SET object_version_number =  nvl(object_version_number,0) + 1, LAST_UPDATE_DATE = SYSDATE,
			LAST_UPDATED_BY = nvl(FND_GLOBAL.User_Id,-1),
			LAST_UPDATE_LOGIN = nvl(FND_GLOBAL.Login_id,-1),
			REQUEST_ID = nvl(FND_GLOBAL.Conc_Request_Id,-1),
 			PROGRAM_ID = nvl(FND_GLOBAL.Conc_Program_Id,-1),
 			PROGRAM_APPLICATION_ID = nvl(FND_GLOBAL.Prog_Appl_Id,-1),
 			PROGRAM_UPDATE_DATE = SYSDATE,
			customer_name = scd_customer_name(J),
			competitor_name = scd_competitor_name(J),
			owner_person_name = scd_owner_person_name(J),
			owner_last_name = scd_owner_last_name(J),
			owner_first_name = scd_owner_first_name(J),
			owner_group_name = scd_owner_group_name(J),
                        party_type = scd_party_type(J),
			customer_category = scd_customer_category(J),
			customer_category_code = scd_customer_category_code(J),
			sales_group_name = scd_sales_group_name(J),
			sales_rep_name = scd_sales_rep_name(J),
			employee_number = scd_employee_number(J),
			first_name = scd_first_name(J),
			last_name = scd_last_name(J),
			--interest_type = Scd_interest_type(J),
			--primary_interest_code = scd_primary_interest_code(J),
			--secondary_interest_code = scd_secondary_interest_code(J),
			sales_stage = scd_sales_stage(J),
			status = scd_status(J),
                        uom_description = scd_uom_description(J),
                        item_description = scd_item_description(J),
                        opportunity_last_updated_name = scd_opp_last_upd_name(J),
                        opportunity_created_name = scd_opp_created_name(J),
                        close_reason_meaning = scd_close_reason_men(J),
                        business_group_name = scd_business_group_name(J),
                        partner_customer_name = scd_partner_cust_name(J)
		WHERE sales_credit_id = scd_sales_credit_id(J);
EXCEPTION
 WHEN OTHERS THEN
    ERRBUF := ERRBUF||sqlerrm;
    RETCODE := '1';
    Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error in Update_Sc_Denorm: ' || SQLCODE);
    Write_Log(l_module, G_DEBUG_CONCURRENT, 1,substr(sqlerrm,1,700));
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Bulk_update_sc_Denorm;

PROCEDURE Refresh_SC_Denorm(ERRBUF OUT NOCOPY varchar2, RETCODE OUT NOCOPY varchar2) IS
CURSOR scd_columns IS
SELECT   /*+ PARALLEL(scdh) */ sales_credit_id,
        cust.party_name,
	cmptr.party_name,
        cust.party_type,
        arlkp.meaning customer_category,
	cust.category_code customer_category_code,
        sg.group_name sales_group_name,
        decode(jrs.category,'EMPLOYEE',jrs.source_name,'PARTY',jrs.source_name,Null) sales_rep_name,
     	decode(jrs.category,'EMPLOYEE',jrs.source_number,'PARTY',jrs.source_number,Null) employee_number,
        decode(jrs.category,'EMPLOYEE',jrs.source_first_name,'PARTY',jrs.source_first_name,Null) first_name,
        decode(jrs.category,'EMPLOYEE',jrs.source_last_name,'PARTY',jrs.source_last_name,Null) last_name,
        sg2.group_name owner_group_name,
        decode(jrs2.category,'EMPLOYEE',jrs2.source_name,'PARTY',jrs2.source_name,Null) owner_person_name,
        decode(jrs2.category,'EMPLOYEE',jrs2.source_first_name,'PARTY',jrs2.source_first_name,Null) owner_first_name,
        decode(jrs2.category,'EMPLOYEE',jrs2.source_last_name,'PARTY',jrs2.source_last_name,Null) owner_last_name,
        --it.interest_type,
        --pic.code primary_interest_code,
        --sic.code secondary_interest_code,
        sales.name sales_stage,
        status.meaning status,
        mtluom.unit_of_measure_tl uom_description,
        mtlsitl.description item_description,
        decode(jrs.category,'PARTNER',jrs.source_name,Null) partner_name,
        aslkp.meaning close_reason_meaning,
        jrs0.source_name lupd_name,
        jrs1.source_name created_name,
        org.name bg_name
    FROM as_sales_credits_denorm scdh,
         as_sales_stages_all_tl sales,
         jtf_rs_resource_extns jrs,
         jtf_rs_groups_tl sg,
         jtf_rs_groups_tl sg2,
         as_statuses_tl status,
         hz_parties cust,
	 hz_parties cmptr,
         ar_lookups arlkp, as_lookups aslkp,
         mtl_system_items_tl mtlsitl,
         mtl_units_of_measure_tl mtluom,
         --as_interest_codes_tl pic, as_interest_codes_tl sic, as_interest_types_tl it,
         jtf_rs_resource_extns jrs0,  jtf_rs_resource_extns jrs1,
 	 jtf_rs_resource_extns jrs2,
         hr_all_organization_units_tl org
    WHERE scdh.sales_stage_id = sales.sales_stage_id(+)
          And sales.language(+) = userenv('LANG')
          And scdh.status_code = status.status_code
          And status.language = userenv('LANG')
          And scdh.salesforce_id = jrs.resource_id(+)
	  And scdh.owner_salesforce_id = jrs2.resource_id(+)
          And scdh.sales_group_id = sg.group_id(+)
          And scdh.owner_sales_group_id = sg2.group_id(+)
          And sg.language(+) = userenv('LANG')
          And sg2.language(+) = userenv('LANG')
          And scdh.customer_id = cust.party_id
	  And cmptr.party_id(+) = scdh.close_competitor_id
          --And it.interest_type_id(+) = scdh.interest_type_id
          --And it.language(+) = userenv('LANG')
          --And pic.interest_code_id(+) = scdh.primary_interest_code_id
          --And pic.language(+) = userenv('LANG')
          --And sic.interest_code_id(+) = scdh.secondary_interest_code_id
          --And sic.language(+) = userenv('LANG')
          And arlkp.lookup_type(+) = 'CUSTOMER_CATEGORY'
          And cust.category_code = arlkp.lookup_code(+)
          And aslkp.lookup_type(+) = 'CLOSE_REASON'
          And scdh.close_reason = aslkp.lookup_code(+)
          And scdh.uom_code = mtluom.uom_code(+)
          And mtluom.language(+) = userenv('LANG')
          And scdh.item_id = mtlsitl.inventory_item_id(+)
          And scdh.organization_id = mtlsitl.organization_id(+)
          And mtlsitl.language(+) = userenv('LANG')
          And scdh.opportunity_last_updated_by = jrs0.user_id
          And scdh.opportunity_created_by = jrs1.user_id
          And scdh.org_id  = org.organization_id(+)
          And org.language(+) = userenv('LANG')
          And (nvl(scdh.customer_name, '#@#') <> nvl(cust.party_name, '#@#') OR
	       nvl(scdh.competitor_name, '#@#') <> nvl(cmptr.party_name, '#@#') OR
               nvl(scdh.customer_category, '#@#') <> nvl(arlkp.meaning, '#@#') OR
               nvl(scdh.customer_category_code, '#@#') <> nvl(cust.category_code, '#@#') OR
               nvl(scdh.sales_group_name, '#@#') <> nvl(sg.group_name, '#@#') OR
               nvl(scdh.owner_group_name, '#@#') <> nvl(sg2.group_name, '#@#') OR
               nvl(scdh.sales_rep_name, '#@#') <> decode(jrs.category,'EMPLOYEE',jrs.source_name,'PARTY',jrs.source_name,'#@#') OR
	       nvl(scdh.employee_number, '#@#') <> decode(jrs.category,'EMPLOYEE',jrs.source_number,'PARTY',jrs.source_number,'#@#') OR
               nvl(scdh.owner_person_name, '#@#') <> decode(jrs2.category,'EMPLOYEE',jrs2.source_name,'PARTY',jrs2.source_name,'#@#') OR
               --nvl(scdh.interest_type, '#@#') <> nvl(it.interest_type, '#@#') OR
               --nvl(scdh.primary_interest_code, '#@#') <> nvl(pic.code, '#@#') OR
               --nvl(scdh.secondary_interest_code, '#@#') <> nvl(sic.code, '#@#') OR
               nvl(scdh.close_reason_meaning, '#@#') <> nvl(aslkp.meaning, '#@#') OR
               nvl(scdh.opportunity_last_updated_name, '#@#') <> nvl(jrs0.source_name, '#@#') OR
               nvl(scdh.opportunity_created_name, '#@#') <> nvl(jrs1.source_name, '#@#') OR
               nvl(scdh.sales_stage, '#@#') <> nvl(sales.name, '#@#') OR
               nvl(scdh.status, '#@#') <> nvl(status.meaning, '#@#') OR
               nvl(scdh.uom_description, '#@#') <> nvl(mtluom.unit_of_measure_tl, '#@#') OR
               nvl(scdh.item_description, '#@#') <> nvl(mtlsitl.description, '#@#') OR
               nvl(scdh.business_group_name, '#@#') <> nvl(org.name, '#@#') OR
               nvl(scdh.partner_customer_name, '#@#') <> decode(jrs.category,'PARTNER',jrs.source_last_name, '#@#'));

l_row_count		        Number:=0;
l_row_updated		        Number:=0;
l_count			        Number:=0;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.scden.Refresh_SC_Denorm';

BEGIN
  RETCODE := 0;
  OPEN scd_columns; LOOP
  BEGIN
    FETCH scd_columns bulk COLLECT
     INTO scd_sales_credit_id,
          scd_customer_name,
	  scd_competitor_name,
	  scd_party_type,
	  scd_customer_category,
	  scd_customer_category_code,
          scd_sales_group_name,
          scd_sales_rep_name,
          scd_employee_number,
          scd_first_name,
          scd_last_name,
	  scd_owner_group_name,
          scd_owner_person_name,
          scd_owner_first_name,
          scd_owner_last_name,
          --scd_interest_type,
	  --scd_primary_interest_code,
	  --scd_secondary_interest_code,
          scd_sales_stage,
          scd_status,
          scd_uom_description,
          scd_item_description,
	  scd_partner_cust_name,
	  scd_close_reason_men,
	  scd_opp_last_upd_name,
          scd_opp_created_name,
          scd_business_group_name LIMIT G_commit_size;

	   IF scd_sales_credit_id.count <= 0 THEN
		CLOSE scd_columns;
		EXIT;
	   END IF;

      l_row_count := l_row_count + scd_sales_credit_id.count;
      Bulk_update_sc_Denorm(ERRBUF, RETCODE, scd_sales_credit_id.last);
      COMMIT;

      IF (scd_columns%NOTFOUND) THEN
      	CLOSE scd_columns;
      	Exit;
      END IF;
      l_count := l_count + scd_sales_credit_id.count;
  END;
  END LOOP;

  COMMIT;
    Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Number of rows processed in AS_SALES_CREDITS_DENORM: '||l_row_count);
    Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Number of rows updated in AS_SALES_CREDITS_DENORM: ' || l_row_updated);
EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ERRBUF := ERRBUF||'Error in Refresh_SC_Denorm: '||to_char(sqlcode);
     RETCODE := FND_API.G_RET_STS_UNEXP_ERROR;
     Write_Log(l_module, G_DEBUG_CONCURRENT, 1,'Error in Refresh_SC_Denorm');
     Write_Log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
     ROLLBACK;
   WHEN OTHERS THEN
     ERRBUF := ERRBUF||'Error in Refresh_SC_Denorm: '||to_char(sqlcode);
     RETCODE := '2';
     Write_Log(l_module, G_DEBUG_CONCURRENT, 1,'Error in Refresh_SC_Denorm');
     Write_Log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
END Refresh_SC_Denorm;

PROCEDURE Main(ERRBUF       OUT NOCOPY Varchar2,
               RETCODE      OUT NOCOPY Varchar2,
               p_mode       IN  Number,
               p_debug_mode IN  Varchar2,
               p_trace_mode IN  Varchar2) IS

l_scd_cnt Number:= 0;
v_CursorID Number;
v_Stmt Varchar2(500);
v_Dummy Integer;
l_status Boolean;
l_fnd_status        VARCHAR2(2);
l_industry          VARCHAR2(2);
l_oracle_schema     VARCHAR2(32);
l_schema_return     BOOLEAN;
l_module CONSTANT VARCHAR2(255) := 'as.plsql.scden.Main';
BEGIN
    l_schema_return := FND_INSTALLATION.get_app_info('AS', l_fnd_status, l_industry, l_oracle_schema);

    IF p_debug_mode = 'Y' THEN G_Debug := TRUE; ELSE G_Debug := FALSE; END IF;

    IF p_trace_mode = 'Y' THEN trace(TRUE); ELSE trace(FALSE); END IF;

    Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Process began @: ' || to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

    RETCODE     := 0;
    l_scd_cnt   := 0;

    -- Write_Log(G_DEBUG_CONCURRENT, 1, 'Please run OSO concurrent program ''Load Sales Credit MViews''' || 'to re-create the snapshots, otherwise OSO concurrent programs will fail');

-- p_mode (1,2) ? (Reload SCD : Refresh SCD)
   IF (p_mode = 1) THEN

        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'LANGUAGE used: '||G_LANG);
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'PREFERRED_CURRENCY used: '||G_PREFERRED_CURRENCY);
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'CONVERSION_TYPE used: '||G_CONVERSION_TYPE);
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'PERIOD_TYPE used: '||G_PERIOD_TYPE);
	--Code commented as per suggestion given in bug#5802537 by Lester
        --Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'DEGREE OF PARALLELISM used: '||as_utility_pvt.get_degree_parallelism);
        EXECUTE IMMEDIATE 'ALTER SESSION ENABLE PARALLEL DML';
        EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_oracle_schema || '.AS_SALES_CREDITS_DENORM';
        clear_snapshots;
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Capturing Index Definitions');
        as_utility_pvt.capture_index_definitions(ERRBUF,RETCODE,'AS_SALES_CREDITS_DENORM',l_oracle_schema);
        IF (RETCODE = 0) THEN
           Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Droping indexes on AS_SALES_CREDITS_DENORM');
	   as_utility_pvt.execute_ind(ERRBUF,RETCODE,'DROP','AS_SALES_CREDITS_DENORM',l_oracle_schema);
           COMMIT;
        END IF;
        IF (RETCODE = 0) THEN
          insert_scd (ERRBUF, RETCODE, l_scd_cnt);
          COMMIT;
        END IF;
        IF (RETCODE = 0) THEN
          Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Building indexes on AS_SALES_CREDITS_DENORM');
	  as_utility_pvt.execute_ind(ERRBUF,RETCODE,'BUILD','AS_SALES_CREDITS_DENORM',l_oracle_schema);
          COMMIT;
        END IF;
        Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Total records inserted into AS_SALES_CREDITS_DENORMS = ' || l_scd_cnt);
   ELSIF (p_mode = 2) THEN
   	Refresh_SC_Denorm(ERRBUF, RETCODE);
   END IF;

   IF (nvl(RETCODE,0) <> 0) THEN
 	l_status := fnd_concurrent.set_completion_status('ERROR',ERRBUF);
        IF l_status = TRUE THEN
          Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program');
        END IF;
   END IF;

   Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Process Completed @: '||to_char(sysdate,'DD-MON-RRRR:HH:MI:SS'));

   EXCEPTION WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		ERRBUF := ERRBUF||'Error in SC Denorm Main:'||to_char(sqlcode)||sqlerrm;
		RETCODE := FND_API.G_RET_STS_UNEXP_ERROR ;
		Write_Log(l_module, G_DEBUG_CONCURRENT, 1,'Error in SC Denorm Main');
     		Write_Log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
		ROLLBACK;
		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
		IF l_status = TRUE THEN
			Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
		END IF;
	WHEN OTHERS THEN
		ERRBUF := ERRBUF||'Error SC Denorm Main:'||to_char(sqlcode)||sqlerrm;
		RETCODE := '2';
		Write_Log(l_module, G_DEBUG_CONCURRENT, 1,'Error in SC Denorm Main');
     		Write_Log(l_module, G_DEBUG_CONCURRENT, 1,sqlerrm);
		ROLLBACK;
		l_status := fnd_concurrent.set_completion_status('ERROR',sqlerrm);
		IF l_status = TRUE THEN
			Write_Log(l_module, G_DEBUG_CONCURRENT, 1, 'Error, can not complete Concurrent Program') ;
		END IF;
END Main;
END AS_SC_DENORM;

/
