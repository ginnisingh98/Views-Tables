--------------------------------------------------------
--  DDL for Package Body MSC_X_NETTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_X_NETTING_PKG" AS
/* $Header: MSCXNETB.pls 120.6 2008/01/07 10:15:08 dejoshi ship $ */

TYPE ExcpTblTyp IS TABLE OF VARCHAR2(80);

lv_exception_type ExcpTblTyp := ExcpTblTyp();
lv_exception_grp  ExcpTblTyp := ExcpTblTyp();

--================================================================================
-- LAUNCH_PLANS
--=================================================================================
PROCEDURE LAUNCH_ENGINE (p_errbuf OUT NOCOPY VARCHAR2,
         p_retcode 		OUT NOCOPY VARCHAR2,
         p_early_order 		IN VARCHAR2,
         p_changed_order 	IN VARCHAR2,
         p_forecast_accuracy 	IN VARCHAR2,
         p_forecast_mismatch 	IN VARCHAR2,
         p_late_order 		IN VARCHAR2,
         p_material_excess 	IN VARCHAR2,
         p_material_shortage 	IN VARCHAR2,
         p_performance 		IN VARCHAR2,
         p_potential_late_order IN VARCHAR2,
         p_response_required 	IN VARCHAR2,
         p_custom_exception 	IN VARCHAR2) IS


l_errbuf    Varchar2(1000);
l_retcode      Varchar2(240);
BEGIN

	select meaning
	BULK COLLECT INTO   lv_exception_grp
	from  mfg_lookups
	where lookup_type = 'MSC_X_EXCEPTION_GROUP'
	order by lookup_code;

	select meaning
	BULK COLLECT INTO   lv_exception_type
	from mfg_lookups
	where lookup_type = 'MSC_X_EXCEPTION_TYPE'
	order by lookup_code;

         IF (p_late_order in (to_char(2), 'N') and
	    p_material_shortage in (to_char(2), 'N') and
	              p_response_required in (to_char(2), 'N') and
	              p_potential_late_order in (to_char(2), 'N') and
	              p_forecast_mismatch in (to_char(2), 'N') and
	              p_early_order in (to_char(2), 'N') and
	              p_material_excess in (to_char(2), 'N') and
	              p_changed_order in (to_char(2), 'N') and
	              p_forecast_accuracy in (to_char(2), 'N') and
	              p_performance in (to_char(2), 'N') and
             p_custom_exception in (to_char(2), 'N')) THEN

            return;
         ELSE

      -- initialize the pmf setup
      msc_pmf_pkg.process_pmf_thresholds;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Launch Regular Exception at: ' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
      start_netting(p_early_order,
         p_changed_order,
         p_forecast_accuracy,
         p_forecast_mismatch,
         p_late_order,
         p_material_excess,
         p_material_shortage,
         p_performance,
         p_potential_late_order,
         p_response_required,
         p_custom_exception);
   END IF;

END LAUNCH_ENGINE;

--===============================================================================
-- START_NETTING
--===============================================================================
PROCEDURE START_NETTING (p_early_order	IN VARCHAR2,
         p_changed_order 		IN VARCHAR2,
         p_forecast_accuracy 		IN VARCHAR2,
         p_forecast_mismatch 		IN VARCHAR2,
         p_late_order 			IN VARCHAR2,
         p_material_excess 		IN VARCHAR2,
         p_material_shortage 		IN VARCHAR2,
         p_performance 			IN VARCHAR2,
         p_potential_late_order 	IN VARCHAR2,
         p_response_required 		IN VARCHAR2,
         p_custom_exception 		IN VARCHAR2) IS


l_max_refresh_number    	Number;
l_errbuf       			Varchar2(1000);
l_retcode         		Varchar2(240);
l_retnum       			Number;
l_late_order_refnum     	Number;
l_material_shortage_refnum 	Number;
l_response_required_refnum 	Number;
l_forecast_mismatch_refnum 	Number;
l_early_order_refnum    	Number;
l_material_excess_refnum   	Number;
l_changed_order_refnum     	Number;
l_forecast_accuracy_refnum 	Number;
l_performance_refnum    	Number;

--========================================================
-- create the constructor the plsql table
--========================================================
t_item_list    		number_arr  := number_arr();
t_company_list    	number_arr  := number_arr();
t_company_site_list  	number_arr  := number_arr();
t_customer_list      	number_arr  := number_arr();
t_customer_site_list 	number_arr  := number_arr();
t_supplier_list      	number_arr  := number_arr();
t_supplier_site_list 	number_arr  := number_arr();
t_group_list      	number_arr  := number_arr();
t_type_list    		number_arr  := number_arr();
t_trxid1_list     	number_arr  := number_arr();
t_trxid2_list     	number_arr  := number_arr();
t_date1_list      	date_arr := date_arr();
t_date2_list      	date_arr := date_arr();
a_company_id            number_arr  := number_arr();
a_company_name          publisherList  := publisherList();
a_company_site_id       number_arr  := number_arr();
a_company_site_name     pubsiteList := pubsiteList();
a_item_id               number_arr  := number_arr();
a_item_name             itemnameList   := itemnameList();
a_item_desc             itemdescList   := itemdescList();
a_exception_type        number_arr  := number_arr();
a_exception_type_name   exceptypeList  := exceptypeList();
a_exception_group       number_arr  := number_arr();
a_exception_group_name  excepgroupList := excepgroupList();
a_trx_id1               number_arr  := number_arr();
a_trx_id2               number_arr  := number_arr();
a_customer_id           number_arr  := number_arr();
a_customer_name         customerList   := customerList();
a_customer_site_id      number_arr  := number_arr();
a_customer_site_name    custsiteList   := custsiteList();
a_customer_item_name 	itemnameList   := itemnameList();
a_supplier_id           number_arr  := number_arr();
a_supplier_name         supplierList   := supplierList();
a_supplier_site_id      number_arr  := number_arr();
a_supplier_site_name    suppsiteList   := suppsiteList();
a_supplier_item_name    itemnameList   := itemnameList();
a_number1               number_arr  := number_arr();
a_number2               number_arr  := number_arr();
a_number3               number_arr  := number_arr();
a_threshold             number_arr  := number_arr();
a_lead_time             number_arr  := number_arr();
a_item_min_qty          number_arr  := number_arr();
a_item_max_qty          number_arr  := number_arr();
a_order_number          ordernumberList   := ordernumberList();
a_release_number        releasenumList := releasenumList();
a_line_number           linenumList := linenumList();
a_end_order_number      ordernumberList   := ordernumberList();
a_end_order_rel_number  releasenumList := releasenumList();
a_end_order_line_number linenumList := linenumList();
a_creation_date         date_arr := date_arr();
a_tp_creation_date      date_arr := date_arr();
a_date1           	date_arr := date_arr();
a_date2        		date_arr := date_arr();
a_date3         	date_arr := date_arr();
a_date4      		date_arr := date_arr();
a_date5            	date_arr := date_arr();
a_exception_basis	exceptbasisList := exceptbasisList();

l_request_id		Number;
l_refreshnum		Number;


BEGIN

   -------------------------------------------------------------------
   -- Make sure the the exeption group is exist in  msc_plan_org_status
   -- for the first run.  Use this table for set the refresh number
   -- for each run by exception group.  Status column will be
   -- populated with refresh number
   -------------------------------------------------------------------
   --dbms_output.put_line('Start populating exception group');

   populate_exception_org;

   ---------------------------------------------------------------------
   --if records are loaded during the prior run of the
        --planning engine and as a result refresh numbers are updated
        --and these records are not picked up.  Therefore, get the refresh
        --number before the engine run.  If any record is loaded during
        --the engine run with later refresh number, then the record
        --will be included in the next run.
   ---------------------------------------------------------------------
   begin
   	select nvl(max(last_refresh_number),0)
        into   l_max_refresh_number
        from   msc_sup_dem_entries
        where  last_refresh_number > G_ZERO;
   exception
   	when no_data_found then
   		l_max_refresh_number := 0;
   end;

--dbms_output.put_line('Max refresh number ' || l_max_refresh_number);
   -------------------------------------------------------------
   --Make sure delete all the exceptions where the quantity = 0
   --in msc_sup_dem_entries because later on this transaction
   --will be purged.
   -------------------------------------------------------------

        Delete_Exec_Order_Dependency(l_max_refresh_number);


   -------------------------------------------------------------------
   -- Deleting all old exceptions depending on the profile option set
   -------------------------------------------------------------------

   DELETE_EXCEP (); --added for bug#6729356

   /*-----------------------------------------------------------
   CHANGED_ORDER group need to be called first if it set to Y
   before purging the transaction in msc_sup_dem_entries where
   quantity = 0.
   Cancelled Order (exception_34) will base on a cancelled PO
   where quantity = 0 to generate.
   Other exceptions which are depending on Execution Entities
   will not capture any transactions where quantity = 0 to generate.

   The reason behind is
   when we use the 'D' sync indicator during the data upload the records
   that need to be deleted are not removed from the table (msc_sup_dem_entries).
   Instead the quantity is set to zero and the transaction id is updated
   to ensure that the exceptions for the items deleted are recomputed
   The current netting engine will only consider this (quantity = 0)
   for non-execution entities exceptions.
   -----------------------------------------------------------*/
        IF (p_changed_order in (to_char(1), 'Y')) THEN

      select   status
         into  l_changed_order_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP8
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_changed_order_refnum);

         msc_x_netting4_pkg.compute_changed_order(l_changed_order_refnum,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
            t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list,
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP8
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;

   ---------------------------------------------------------------
   -- purge the execution order where quantity = 0
   ---------------------------------------------------------------
        Purge_Zqty_Exec_Order(l_max_refresh_number);

   IF (p_late_order in (to_char(1), 'Y')) THEN

      select   status
         into  l_late_order_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP1
         and   sr_instance_id = G_SR_INSTANCE_ID;

         --dbms_output.put_line('Late Order refresh_number : ' || l_late_order_refnum);

         msc_x_netting1_pkg.compute_late_order(l_late_order_refnum,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
            t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list,
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);


         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP1
      and   sr_instance_id = G_SR_INSTANCE_ID;

        END IF;
        IF (p_material_shortage in (to_char(1), 'Y')) THEN

      select   status
         into  l_material_shortage_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP2
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_material_shortage_refnum);

	 MSC_EXCHANGE_BUCKETING.start_bucketing( l_material_shortage_refnum );


         msc_x_netting2_pkg.compute_material_shortage(l_material_shortage_refnum,
            t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
            t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list,
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP2
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;

        IF (p_response_required in (to_char(1), 'Y')) THEN

      select   status
         into  l_response_required_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP3
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_response_required_refnum);

         msc_x_netting3_pkg.compute_response_required(
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP3
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;

        IF (p_forecast_mismatch in (to_char(1), 'Y')) THEN

      select   status
         into  l_forecast_mismatch_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP5
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_forecast_mismatch_refnum);
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'forecast mismatch refnum ' || l_forecast_mismatch_refnum);

         msc_x_netting1_pkg.compute_forecast_mismatch(l_forecast_mismatch_refnum,
                     t_company_list,
            t_company_site_list,
            t_customer_list,
            t_customer_site_list,
            t_supplier_list,
            t_supplier_site_list,
               t_item_list,
            t_group_list,
            t_type_list,
            t_trxid1_list,
            t_trxid2_list,
            t_date1_list,
            t_date2_list,
            a_company_id,
            a_company_name,
            a_company_site_id,
            a_company_site_name,
            a_item_id,
            a_item_name,
            a_item_desc,
            a_exception_type,
            a_exception_type_name ,
            a_exception_group,
            a_exception_group_name,
            a_trx_id1,
            a_trx_id2 ,
            a_customer_id,
            a_customer_name,
            a_customer_site_id,
            a_customer_site_name ,
            a_customer_item_name,
            a_supplier_id ,
            a_supplier_name ,
            a_supplier_site_id ,
            a_supplier_site_name,
            a_supplier_item_name,
            a_number1,
            a_number2,
            a_number3  ,
            a_threshold,
            a_lead_time,
            a_item_min_qty,
            a_item_max_qty,
            a_order_number,
            a_release_number,
            a_line_number,
            a_end_order_number,
            a_end_order_rel_number ,
            a_end_order_line_number,
            a_creation_date,
            a_tp_creation_date ,
            a_date1,
            a_date2,
            a_date3,
            a_date4,
            a_date5,
            a_exception_basis);


         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP5
      and   sr_instance_id = G_SR_INSTANCE_ID;


   END IF;
        IF (p_early_order in (to_char(1), 'Y')) THEN
      select   status
         into  l_early_order_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP6
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_early_order_refnum);

         msc_x_netting1_pkg.compute_early_order(l_early_order_refnum,
         t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
                 t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list,
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP6
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;
        IF (p_material_excess in (to_char(1),'Y')) THEN


      select   status
         into  l_material_excess_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP7
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_material_excess_refnum);

        --- call to bucketing

         IF (p_material_shortage in (to_char(2),'N')) THEN
	 	MSC_EXCHANGE_BUCKETING.start_bucketing( l_material_excess_refnum );


	 END IF;

         msc_x_netting2_pkg.compute_material_excess(l_material_excess_refnum,
            t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
            t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list,
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP7
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;
        IF (p_forecast_accuracy in (to_char(1), 'Y')) THEN

      select   status
         into  l_forecast_accuracy_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP9
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_forecast_accuracy_refnum);

         msc_x_netting4_pkg.compute_forecast_accuracy(
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP9
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;
        IF (p_performance in (to_char(1), 'Y')) THEN

      select   status
         into  l_performance_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP10
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_performance_refnum);

         msc_x_netting4_pkg.compute_performance(
         a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = l_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP10
      and   sr_instance_id = G_SR_INSTANCE_ID;

   END IF;
   IF (p_custom_exception in (to_char(1),'Y')) THEN
      msc_x_netting4_pkg.compute_custom_exception;
   END IF;


   --================================================
   -- insert to the msc_x_exception_details table by bulk
   --=================================================

   populate_exception_data(a_company_id,
            a_company_name,
            a_company_site_id,
            a_company_site_name,
            a_item_id,
            a_item_name,
            a_item_desc,
            a_exception_type,
            a_exception_type_name ,
            a_exception_group,
            a_exception_group_name,
            a_trx_id1,
            a_trx_id2 ,
            a_customer_id,
            a_customer_name,
            a_customer_site_id,
            a_customer_site_name ,
            a_customer_item_name,
            a_supplier_id ,
            a_supplier_name ,
            a_supplier_site_id ,
            a_supplier_site_name,
            a_supplier_item_name,
            a_number1,
            a_number2,
            a_number3  ,
            a_threshold,
            a_lead_time,
            a_item_min_qty,
            a_item_max_qty,
            a_order_number,
            a_release_number,
            a_line_number,
            a_end_order_number,
            a_end_order_rel_number ,
            a_end_order_line_number,
            a_creation_date,
            a_tp_creation_date ,
            a_date1,
            a_date2,
            a_date3,
            a_date4,
            a_date5,
            a_exception_basis);

   -------------------------------------------------------------
   -- ARCHIVE THE old exceptions
   ------------------------------------------------------------

   archive_exception(   t_company_list,
            t_company_site_list,
            t_customer_list,
            t_customer_site_list,
            t_supplier_list,
            t_supplier_site_list,
            t_item_list,
            t_group_list,
            t_type_list,
            t_trxid1_list,
            t_trxid2_list,
            t_date1_list,
            t_date2_list);

   --------------------------------------------------------------------
   --update item name, desc, customer item name, supplier item name
   --------------------------------------------------------------------

   IF (p_material_shortage in (to_char(1),'Y') or
       p_material_excess in (to_char(1), 'Y')) THEN

	IF (l_material_shortage_refnum is null OR l_material_shortage_refnum >= l_material_excess_refnum) THEN

		l_refreshnum := l_material_excess_refnum;
	ELSIF (l_material_excess_refnum is null OR l_material_shortage_refnum <= l_material_excess_refnum) THEN
		l_refreshnum := l_material_shortage_refnum;

	END IF;
	--dbms_output.put_line('update item ' || l_refreshnum);
	update_item(l_refreshnum);

   END IF;


   ----------------------------------------------------------------
   --potential late order exceptions are dependending on late order
   --and response required exceptions.  Therefore, the potential late
   --order group will be running after these two groups.
   ----------------------------------------------------------------
   Potential_lo_netting(l_max_refresh_number,p_potential_late_order);


   --------------------------------------------------------------------------
   --Here is deleting only Planning Entities.
   --Delete all transactions from msc_sup_dem_entries with quantity = 0 for
   --the planning entities (means not the execution entites -- SO, PO, asn).
   --When we use the 'D' sync indicator during the data upload the records
   --that need to be deleted are not removed from the table. Instead the
   --quantity is set to zero and the transaction id is updated to ensure that
   --the exceptions for the items deleted are recomputed. After exceptions
   --are computed we purge these records from the table.
   ---------------------------------------------------------------------------
   --dbms_output.put_line('Delete zero qty for Planning Entities');
   delete /*+ PARALLEL(sd) */ from msc_sup_dem_entries sd
   where sd.plan_id = G_PLAN_ID
   and sd.quantity = 0
   and nvl(sd.last_update_login,-1) = -99
   and sd.last_refresh_number <= l_max_refresh_number ;


    --------------------------------------------------------------------------
    --Deleting the disable serial number record
    --------------------------------------------------------------------------
   DELETE from msc_serial_numbers msn
   WHERE NVL(msn.disable_date,sysdate+1)<=sysdate OR
             serial_txn_id not in (select transaction_id from msc_sup_dem_entries);

   --=================================================================
   -- A profile option to set the workflow notification on/off
   -- By default it is set to "Y" and let it  launch the workflow
   -- notification.  If it is set to 'N', no need to send and set
   -- the flag back to normal in msc_x_exception_details table
   --====================================================================


   -----------------------------------------------------------
   --Clean up at the end of the netting engine run
   -----------------------------------------------------------
   clean_up_process;

   commit;

   IF (nvl(FND_PROFILE.VALUE('MSC_LAUNCH_EXCEPTION_NOTIFICATION'),'Y') = 'Y') THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Launch workflow process' || ':' ||to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));

    	-- launch the cp exception workflow program
      l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                   'MSC', -- application
                   'MSCXEWF', -- program
                   NULL,  -- description
                   NULL, -- start time
                   FALSE); -- sub_request

                COMMIT;

                IF l_request_id=0 THEN
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Launch Exception Workflow request failed');
         	   begin
         		update msc_x_exception_details
         		set version = null, last_update_login = null
         		where plan_id = -1
         		and version = 'CURRENT'
         		and exception_group in (1,2,3,4,5,6,7,8,9,10);
      		   exception
         		when others then
         		null;
      		   end;
                ELSE
                   FND_FILE.PUT_LINE(FND_FILE.LOG,'Launch Exception Workflow request :'|| to_char(l_request_id));
                END IF;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Workflow process completed at' || ':' || to_char(sysdate, 'DD-MON-YYYY HH24:MI:SS'));
   ELSE
      --Reset the records for which the no notifications need to sent
      begin
         update msc_x_exception_details
         set version = null, last_update_login = null
         where plan_id = -1
         and version = 'CURRENT'
         and exception_group in (1,2,3,4,5,6,7,8,9,10);
      exception
         when others then
         null;
      end;
   END IF;


   -----------------------------------------------------------
   --Transaction complete
   -----------------------------------------------------------
   commit;

END START_NETTING;

--------------------------------------------------------------------
--PROCEDURE POTENTIAL_LO_NETTING
--------------------------------------------------------------------
PROCEDURE POTENTIAL_LO_NETTING (p_max_refresh_number in Number,
            p_potential_late_order in VARCHAR2) AS

l_potential_late_order_refnum Number;


--========================================================
-- create the constructor the plsql table
--========================================================
t_item_list    		number_arr  := number_arr();
t_company_list    	number_arr  := number_arr();
t_company_site_list  	number_arr  := number_arr();
t_customer_list      	number_arr  := number_arr();
t_customer_site_list 	number_arr  := number_arr();
t_supplier_list      	number_arr  := number_arr();
t_supplier_site_list 	number_arr  := number_arr();
t_group_list      	number_arr  := number_arr();
t_type_list    		number_arr  := number_arr();
t_trxid1_list     	number_arr  := number_arr();
t_trxid2_list     	number_arr  := number_arr();
t_date1_list      	date_arr := date_arr();
t_date2_list      	date_arr := date_arr();
a_company_id            number_arr  := number_arr();
a_company_name          publisherList  := publisherList();
a_company_site_id       number_arr  := number_arr();
a_company_site_name     pubsiteList := pubsiteList();
a_item_id               number_arr  := number_arr();
a_item_name             itemnameList   := itemnameList();
a_item_desc             itemdescList   := itemdescList();
a_exception_type        number_arr  := number_arr();
a_exception_type_name   exceptypeList  := exceptypeList();
a_exception_group       number_arr  := number_arr();
a_exception_group_name  excepgroupList := excepgroupList();
a_trx_id1               number_arr  := number_arr();
a_trx_id2               number_arr  := number_arr();
a_customer_id           number_arr  := number_arr();
a_customer_name         customerList   := customerList();
a_customer_site_id      number_arr  := number_arr();
a_customer_site_name    custsiteList   := custsiteList();
a_customer_item_name 	itemnameList   := itemnameList();
a_supplier_id           number_arr  := number_arr();
a_supplier_name         supplierList   := supplierList();
a_supplier_site_id      number_arr  := number_arr();
a_supplier_site_name    suppsiteList   := suppsiteList();
a_supplier_item_name    itemnameList   := itemnameList();
a_number1               number_arr  := number_arr();
a_number2               number_arr  := number_arr();
a_number3               number_arr  := number_arr();
a_threshold             number_arr  := number_arr();
a_lead_time             number_arr  := number_arr();
a_item_min_qty          number_arr  := number_arr();
a_item_max_qty          number_arr  := number_arr();
a_order_number          ordernumberList   := ordernumberList();
a_release_number        releasenumList := releasenumList();
a_line_number           linenumList := linenumList();
a_end_order_number      ordernumberList   := ordernumberList();
a_end_order_rel_number  releasenumList := releasenumList();
a_end_order_line_number linenumList := linenumList();
a_creation_date         date_arr := date_arr();
a_tp_creation_date      date_arr := date_arr();
a_date1           	date_arr := date_arr();
a_date2        		date_arr := date_arr();
a_date3         	date_arr := date_arr();
a_date4      		date_arr := date_arr();
a_date5            	date_arr := date_arr();
a_exception_basis	exceptbasisList := exceptbasisList();

BEGIN
IF (p_potential_late_order in (to_char(1), 'Y')) THEN

      select   status
         into  l_potential_late_order_refnum
         from  msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   organization_id = G_GROUP4
         and   sr_instance_id = G_SR_INSTANCE_ID;
         --dbms_output.put_line('Max refresh_number : ' || l_potential_late_order_refnum);

         msc_x_netting3_pkg.compute_potential_late_order(l_potential_late_order_refnum,
            t_company_list,
         t_company_site_list,
         t_customer_list,
         t_customer_site_list,
         t_supplier_list,
         t_supplier_site_list,
            t_item_list,
         t_group_list,
         t_type_list,
         t_trxid1_list,
         t_trxid2_list,
         t_date1_list,
         t_date2_list,        a_company_id,
         a_company_name,
         a_company_site_id,
         a_company_site_name,
         a_item_id,
         a_item_name,
         a_item_desc,
         a_exception_type,
         a_exception_type_name ,
         a_exception_group,
         a_exception_group_name,
         a_trx_id1,
         a_trx_id2 ,
         a_customer_id,
         a_customer_name,
         a_customer_site_id,
         a_customer_site_name ,
         a_customer_item_name,
         a_supplier_id ,
         a_supplier_name ,
         a_supplier_site_id ,
         a_supplier_site_name,
         a_supplier_item_name,
         a_number1,
         a_number2,
         a_number3  ,
         a_threshold,
         a_lead_time,
         a_item_min_qty,
         a_item_max_qty,
         a_order_number,
         a_release_number,
         a_line_number,
         a_end_order_number,
         a_end_order_rel_number ,
         a_end_order_line_number,
         a_creation_date,
         a_tp_creation_date ,
         a_date1,
         a_date2,
         a_date3,
         a_date4,
         a_date5,
         a_exception_basis);

         update   msc_plan_org_status
      set   status = p_max_refresh_number,
         status_date = sysdate
      where    plan_id = G_PLAN_ID
      and   organization_id = G_GROUP4
      and   sr_instance_id = G_SR_INSTANCE_ID;
   END IF;

   --================================================
   -- insert to the msc_x_exception_details table by bulk
   --=================================================

   populate_exception_data(a_company_id,
            a_company_name,
            a_company_site_id,
            a_company_site_name,
            a_item_id,
            a_item_name,
            a_item_desc,
            a_exception_type,
            a_exception_type_name ,
            a_exception_group,
            a_exception_group_name,
            a_trx_id1,
            a_trx_id2 ,
            a_customer_id,
            a_customer_name,
            a_customer_site_id,
            a_customer_site_name ,
            a_customer_item_name,
            a_supplier_id ,
            a_supplier_name ,
            a_supplier_site_id ,
            a_supplier_site_name,
            a_supplier_item_name,
            a_number1,
            a_number2,
            a_number3  ,
            a_threshold,
            a_lead_time,
            a_item_min_qty,
            a_item_max_qty,
            a_order_number,
            a_release_number,
            a_line_number,
            a_end_order_number,
            a_end_order_rel_number ,
            a_end_order_line_number,
            a_creation_date,
            a_tp_creation_date ,
            a_date1,
            a_date2,
            a_date3,
            a_date4,
            a_date5,
            a_exception_basis);

   -------------------------------------------------------------
   -- ARCHIVE THE old exceptions
   ------------------------------------------------------------

   archive_exception(   t_company_list,
            t_company_site_list,
            t_customer_list,
            t_customer_site_list,
            t_supplier_list,
            t_supplier_site_list,
            t_item_list,
            t_group_list,
            t_type_list,
            t_trxid1_list,
            t_trxid2_list,
            t_date1_list,
            t_date2_list);


END potential_lo_netting;

--------------------------------------------------------------------
--FUNCTION does_exception_org_exist
--------------------------------------------------------------------
FUNCTION DOES_EXCEPTION_ORG_EXIST (p_org_id IN Number) RETURN Number IS

l_ret_flag  Number := 0;

BEGIN


    select 1 into l_ret_flag
    from dual
    where exists ( select 1
         from msc_plan_org_status
         where plan_id = G_PLAN_ID
         and   sr_instance_id = G_SR_INSTANCE_ID
         and   organization_id = p_org_id
      );

   return l_ret_flag;

EXCEPTION

   when NO_DATA_FOUND then
      l_ret_flag := 0;
      return l_ret_flag;
END does_exception_org_exist;

-----------------------------------------------------------------------
--  PROCEDURE POPULATE_EXCEPTION_ORG
--insert the organization_id that is not existing for the plan_id = -1
-----------------------------------------------------------------------
PROCEDURE POPULATE_EXCEPTION_ORG IS

l_count  Number := 0;

BEGIN

select count(*)
into  l_count
from  msc_plan_org_status
where plan_id = -1
and   organization_id in (G_GROUP1,G_GROUP2,G_GROUP3,
      G_GROUP4,G_GROUP5,G_GROUP6,
      G_GROUP7,G_GROUP8,G_GROUP9,G_GROUP10);

IF (l_count <> 10) THEN

IF  ( does_exception_org_exist (G_GROUP1) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP1);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP1, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP2) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP2);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP2, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP3) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP3);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP3, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP4) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP4);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP4, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP5) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP5);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP5, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP6) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP6);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP6, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP7) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP7);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP7, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP8) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP8);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP8, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP9) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP9);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP9, G_SR_INSTANCE_ID, 0, sysdate);
END IF;
IF  ( does_exception_org_exist (G_GROUP10) <> 1) THEN
   --dbms_output.put_line('Inserting... ' || G_GROUP10);
   insert into msc_plan_org_status(plan_id, organization_id, sr_instance_id,status, status_date)
   values   (G_PLAN_ID, G_GROUP10, G_SR_INSTANCE_ID, 0, sysdate);
END IF;

END IF;

EXCEPTION
   when others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.populate_exception_org');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      return;
END POPULATE_EXCEPTION_ORG;


-----------------------------------------------------------------------------------
--FUNCTION GENERATE_COMPLEMENT_EXCEPTION
-----------------------------------------------------------------------------------
FUNCTION GENERATE_COMPLEMENT_EXCEPTION(p_company_id IN Number,
                                        p_company_site_id IN Number,
                                        p_item_id IN Number,
                                        p_refresh_number IN Number,
               p_type in NUMBER,
               p_role in NUMBER) RETURN Boolean IS
l_return_flag Boolean;
l_max_rf_num Number;
plans_rf_num Number;
tps_role Number;
BEGIN

        BEGIN
                if p_type in (SUPPLY_PLANNING,DEMAND_PLANNING) then
                     if (p_role = SELLER) then
                           select nvl(max(sd.last_refresh_number),-1)
            into l_max_rf_num
                           from msc_sup_dem_entries sd
                           where sd.plan_id = G_PLAN_ID
            and sd.publisher_id = p_company_id
                           and sd.publisher_site_id = p_company_site_id
                           and sd.inventory_item_id = p_item_id
                           and trunc(sd.key_date) >= trunc(sysdate);
                        elsif (p_role = BUYER) then
                           select nvl(max(sd.last_refresh_number),-1)
            into l_max_rf_num
            from msc_sup_dem_entries sd
            where sd.plan_id = G_PLAN_ID
            and sd.publisher_id = p_company_id
            and sd.publisher_site_id = p_company_site_id
            and sd.inventory_item_id = p_item_id
                           and trunc(sd.key_date) >= trunc(sysdate);
                        end if;

                elsif p_type in (VMI) then
                        if (p_role = SELLER) then
                                 select nvl(max(sd.last_refresh_number),-1)
            into l_max_rf_num
                           from msc_sup_dem_entries sd
                           where sd.plan_id = G_PLAN_ID
            and sd.publisher_id = p_company_id
               and sd.publisher_site_id = p_company_site_id
                           and sd.inventory_item_id = p_item_id
                           and ((trunc(sd.ship_date) >= trunc(sysdate)) or sd.publisher_order_type = 15);
	   /* Bug# 4303597 -- added OR condition so that refresh_number of updated ASN is selected */
                        elsif (p_role = BUYER) then
            select nvl(max(sd.last_refresh_number),-1)
            into l_max_rf_num
                     from msc_sup_dem_entries sd
                     where sd.plan_id = G_PLAN_ID
            and sd.publisher_id = p_company_id
                     and sd.publisher_site_id = p_company_site_id
                     and sd.inventory_item_id = p_item_id;
                        end if;
                end if;

        EXCEPTION
                WHEN NO_DATA_FOUND THEN
                        --dbms_output.put_line('No data found for item ' || p_item_id);
                        l_return_flag := FALSE;
        END;


        --dbms_output.put_line('Plans refresh # := ' || p_refresh_number);
        --dbms_output.put_line('Entry refresh # := ' || l_max_rf_num);

         if p_refresh_number >= l_max_rf_num then
                l_return_flag := TRUE;
        else
                  l_return_flag := FALSE;
        end if;
        return l_return_flag;
END GENERATE_COMPLEMENT_EXCEPTION;

------------------------------------------------------------------
-- DELETE_ITEM
------------------------------------------------------------------
PROCEDURE Delete_Item(l_type in varchar2, l_key in varchar2) IS

cursor get_notification_c (l_type in varchar2, l_key in varchar2) IS
select notification_id
      from wf_item_activity_statuses
      where item_type = l_type
      and item_key like l_key
      union
      select notification_id
      from wf_item_activity_statuses_h
      where item_type = l_type
      and item_key like l_key;

l_item_key     Varchar2(100);
l_notification_id Number;

BEGIN

open get_notification_c (l_type, l_key);
loop
   fetch get_notification_c into l_notification_id;
    exit when (l_notification_id is null or get_notification_c%NOTFOUND or get_notification_c%NOTFOUND is null) ;

update wf_notifications set
      end_date = sysdate
    where notification_id = l_notification_id;
end loop;
close get_notification_c;



    update wf_items set
      end_date = sysdate
    where item_type = l_type
    and item_key like l_key;

    update wf_item_activity_statuses set
      end_date = sysdate
    where item_type = l_type
    and item_key like l_key;

    update wf_item_activity_statuses_h set
      end_date = sysdate
    where item_type = l_type
    and item_key like l_key;

    wf_purge.total(l_type,l_key,sysdate,false);

EXCEPTION
  WHEN OTHERS THEN
        return;
END Delete_Item;

------------------------------------------------------------------
-- delete_wf_notification
------------------------------------------------------------------
PROCEDURE delete_wf_notification(p_type in varchar2, p_key in varchar2) IS

cursor get_notification_c (p_type In Varchar2,
         p_key in varchar2) IS

select (max(notification_id))
from  wf_item_activity_statuses
where item_type = p_type
and   item_key like p_key || '%'
and   notification_id is not null;

l_item_key     Varchar2(100);
l_notification_id Number;
BEGIN

open get_notification_c (p_type, p_key);
loop
   fetch get_notification_c into l_notification_id;
    exit when (l_notification_id is null or get_notification_c%NOTFOUND or get_notification_c%NOTFOUND is null) ;
FND_FILE.PUT_LINE(FND_FILE.LOG,'inside PROCEDURE delete_wf_notification : l_notification_id =  '||l_notification_id);
      wf_notification.cancel(l_notification_id);

  end loop;
close get_notification_c;

EXCEPTION
  WHEN OTHERS THEN
   --dbms_output.put_line('Error in delete wf nid ' || sqlerrm);
   FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in delete wf nid '||sqlerrm);
        return;
END delete_wf_notification;

--------------------------------------------------------------------------
-- Function GET_MESSAGE_TYPE
----------------------------------------------------------------------
FUNCTION GET_MESSAGE_TYPE(p_exception_code in Number) RETURN Varchar2 IS
    l_message_type   Varchar2(100);
BEGIN

/*
   if (p_exception_code in (17,18,37,38,41,42) ) then
       return l_message_type;
   end if;

   if (p_exception_code <= 16) then
       return lv_exception_type(p_exception_code);
   elsif (p_exception_code <= 36) then
       return lv_exception_type(p_exception_code-2);
   elsif (p_exception_code <= 40) then
       return lv_exception_type(p_exception_code-4);
   elsif (p_exception_code <= 51) then
       return lv_exception_type(p_exception_code-6);
   else
       return l_message_type;
   end if;
   */
   select meaning
   into  l_message_type
   from  mfg_lookups
   where lookup_type = 'MSC_X_EXCEPTION_TYPE'
   and   lookup_code = p_exception_code;

   return l_message_type;
EXCEPTION
   when others then
      l_message_type := null;
      return l_message_type;
END get_message_type;

--------------------------------------------------------------------------
-- Function GET_MESSAGE_GROUP
----------------------------------------------------------------------
FUNCTION GET_MESSAGE_GROUP(p_exception_group in Number) RETURN Varchar2 IS
    l_message_group   Varchar2(100);
BEGIN

/*  This code is added for performance.
    But this is not currently used since QA has not tested it .....
 if (p_exception_group = -99) then
    return lv_exception_grp(1);
 elsif (p_exception_group <= 10) then
    return lv_exception_grp(p_exception_group+1);
 else
    return l_message_group;
 end if;
   */

   select meaning
   into  l_message_group
   from  mfg_lookups
   where lookup_type = 'MSC_X_EXCEPTION_GROUP'
   and   lookup_code = p_exception_group;

   return l_message_group;
EXCEPTION
    when others then
      l_message_group := null;
      return l_message_group;

END get_message_group;


-----------------------------------------------------------------
-- procedure UPDATE_EXCEPTION_SUMMARY
-----------------------------------------------------------------
PROCEDURE UPDATE_EXCEPTIONS_SUMMARY( p_company_id IN Number,
                              p_company_site_id IN Number,
                              p_item_id IN Number,
                              p_exception_type IN Number,
                              p_exception_group IN Number) IS

l_exception_exists Number;

BEGIN

        l_exception_exists := does_exception_exist(p_company_id,
                                p_company_site_id,
                                p_item_id,
                                p_exception_type,
                                p_exception_group);
--dbms_output.put_line('Exception item exist ' || l_exception_exists);
        if l_exception_exists = 1 then
                update_item_exception(p_company_id,
                                        p_company_site_id,
                                        p_item_id,
                                        p_exception_type,
                                        p_exception_group);
        else
      add_item_exception(p_company_id,
                                   p_company_site_id,
                                   p_item_id,
                                   p_exception_type,
                                   p_exception_group);
        end if;

EXCEPTION
   when others then
      ----dbms_output.put_line('Error ' || sqlerrm);
      return;
END UPDATE_EXCEPTIONS_SUMMARY;

--------------------------------------------------------------------------
--procedure ADD_EXCEPTION_DETAILS
--------------------------------------------------------------------------
PROCEDURE ADD_EXCEPTION_DETAILS (p_company_id IN Number,
            p_company_name IN Varchar2,
                                p_company_site_id IN Number,
                                p_company_site_name In Varchar2,
                                p_item_id In Number,
                                p_item_name In Varchar2,
                                p_item_description In Varchar2,
                                p_exception_type IN Number,
                                p_exception_type_name In Varchar2,
                                p_exception_group In Number,
                                p_exception_group_name IN Varchar2,
                                p_trx_id1 IN Number,
                                p_trx_id2 IN Number,
                                p_customer_id IN Number,
                                p_customer_name IN Varchar2,
                                p_customer_site_id IN Number,
                                p_customer_site_name in varchar2,
                                p_customer_item_name iN varchar2,
                                p_supplier_id IN Number,
                                p_supplier_name In Varchar2,
                                p_supplier_site_id IN Number ,
                                p_supplier_site_name In Varchar2,
                                p_supplier_item_name In Varchar2,
                                p_quantity3 IN Number ,
                                p_quantity1 In Number,
                                p_quantity2 In Number,
                                p_threshold In Number,
                                p_lead_time In Number,
                                p_item_min_qty In Number,
                                p_item_max_qty In Number,
                                p_order_number IN Varchar2 ,
                                p_release_number IN Varchar2,
                                p_line_number IN Varchar2,
                                p_end_order_number IN Varchar2,
                                p_end_order_rel_number In Varchar2,
                                p_end_order_line_number IN Varchar2,
                                p_actual_date IN Date,
                                p_tp_actual_date IN Date,
                                p_creation_date IN Date,
                                p_tp_creation_date IN Date,
                                p_other_date IN Date
                                , p_replenishment_method IN NUMBER
                              ) IS
   l_ex_dtl_id Number;
   l_user_id       Number  := fnd_global.user_id;
BEGIN
    select msc_x_exception_details_s.nextval
    into l_ex_dtl_id
    from dual;

 insert into msc_x_exception_details ( exception_detail_id,
                                       exception_type,
                                       exception_type_name,
                                       exception_group,
                                       exception_group_name,
                                        number3,
                                        date1,
                                        date2,
                                        date3,
                                        order_creation_date1,
                                        order_creation_date2,
                                        transaction_id1,
                                        transaction_id2,
                                        number1,
                                        number2,
                                        threshold,
                                        lead_time,
                                        item_min_qty,
                                        item_max_qty,
                                        version,
                                        plan_id,
               sr_instance_id,
               company_id,
               company_name,
                                        company_site_id,
                                        company_site_name,
                                        inventory_item_id,
                                        item_name,
                                        item_description,
                                        last_update_date,
                                        last_updated_by,
                                        last_update_login,
                                        creation_date,
                                        created_by,
               customer_id,
               customer_name,
               customer_site_id,
               customer_site_name,
               customer_item_name,
               supplier_id,
               supplier_name,
                                        supplier_site_id,
                                        supplier_site_name,
                                        supplier_item_name,
                                        order_number,
                                        release_number,
                                        line_number,
                                        end_order_number,
                                        end_order_rel_number,
                                        end_order_line_number
                                      , replenishment_method
                                      )

   values (l_ex_dtl_id,
            p_exception_type,
            p_exception_type_name,
            p_exception_group,
            p_exception_group_name,
            p_quantity3,
            trunc(p_actual_date),
            trunc(p_tp_actual_date),
            trunc(p_other_date),
            trunc(p_creation_date),
            trunc(p_tp_creation_date),
            p_trx_id1,
            p_trx_id2,
            p_quantity1,
            p_quantity2,
            p_threshold,
            p_lead_time,
            p_item_min_qty,
            p_item_max_qty,
                'CURRENT',
                G_PLAN_ID,
      G_SR_INSTANCE_ID,
      p_company_id,
                p_company_name,
                p_company_site_id,
                p_company_site_name,
                p_item_id,
                p_item_name,
                p_item_description,
                sysdate,
                l_user_id,
                G_MAGIC_NUMBER,
                sysdate,
                l_user_id,
      p_customer_id,
      p_customer_name,
      p_customer_site_id,
      p_customer_site_name,
      p_customer_item_name,
      p_supplier_id,
      p_supplier_name,
                p_supplier_site_id,
                p_supplier_site_name,
                p_supplier_item_name,
                p_order_number,
                p_release_number,
                p_line_number,
                p_end_order_number,
                p_end_order_rel_number,
                p_end_order_line_number
              , p_replenishment_method
              );

EXCEPTION
   when others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.add_exception_details');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      return;
END ADD_EXCEPTION_DETAILS;

--------------------------------------------------------------------------
--procedure UPDATE_ITEM_EXCEPTION
--------------------------------------------------------------------------
PROCEDURE UPDATE_ITEM_EXCEPTION( p_company_id IN Number,
             p_company_site_id IN Number,
                                 p_item_id IN Number,
                                 p_exception_type IN Number,
                                 p_exception_group IN Number) IS
BEGIN
--dbms_output.put_line('Update msc_item_exceptions');
   update msc_item_exceptions ex
   set ex.exception_count = ex.exception_count + 1,
      ex.last_update_date = sysdate
   where ex.plan_id = G_PLAN_ID
   and ex.company_id = p_company_id
   and ex.company_site_id = p_company_site_id
    and ex.inventory_item_id = p_item_id
    and ex.exception_type = p_exception_type
   and ex.exception_group = p_exception_group
    and ex.version = 0;

EXCEPTION
   when others then
      --dbms_output.put_line('Error ' || sqlerrm);
      return;
END UPDATE_ITEM_EXCEPTION;

-------------------------------------------------------------------------------
-- ADD_ITEM_EXCEPTION
--------------------------------------------------------------------------
PROCEDURE ADD_ITEM_EXCEPTION(    p_company_id IN Number,
                                p_company_site_id IN Number,
                                p_item_id IN Number,
                                p_exception_type IN Number,
                                p_exception_group IN Number) IS
   l_version Number := 0;
BEGIN
 --dbms_output.put_line('Add item exception ');
   insert into msc_item_exceptions( plan_id,
               sr_instance_id,
               company_id,
               company_site_id,
               organization_id,
               inventory_item_id,
               version,
               exception_type,
               exception_group,
               exception_count,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login)
   values (G_PLAN_ID,
      G_SR_INSTANCE_ID,
      p_company_id,
      p_company_site_id,
      p_company_site_id,
      p_item_id,
      l_version,
      p_exception_type,
      p_exception_group,
      1,
      sysdate,
      -1,
      sysdate,
      -1,
      G_MAGIC_NUMBER);
EXCEPTION
   when others then
      --dbms_output.put_line('Error ' || sqlerrm);
      return;

END ADD_ITEM_EXCEPTION;

------------------------------------------------------------------------
-- DOES_EXCEPTION_EXIST
-------------------------------------------------------------------------
FUNCTION DOES_EXCEPTION_EXIST(p_company_id IN Number,
            p_company_site_id IN Number,
            p_item_id IN Number,
            p_exception_type IN Number,
            p_exception_group IN Number) RETURN Number IS
   l_ret_flag Number := -1;
   l_count Number;
BEGIN


    select 1 into l_ret_flag
    from dual
    where exists (   select 1
               from msc_item_exceptions ex
                        where ex.plan_id = G_PLAN_ID
                        and ex.company_id = p_company_id
               and ex.company_site_id = p_company_site_id
                        and ex.inventory_item_id = p_item_id
                        and ex.exception_type = p_exception_type
                        and ex.exception_group = p_exception_group
                        and ex.version = 0
            --and nvl(ex.last_update_login,-1) = G_MAGIC_NUMBER
      );

   return l_ret_flag;
EXCEPTION
      when NO_DATA_FOUND then
         l_ret_flag := -1;
         return l_ret_flag;
END DOES_EXCEPTION_EXIST;

----------------------------------------------------------------
-- Function get_total_qty
-----------------------------------------------------------------
FUNCTION GET_TOTAL_QTY( p_order_number IN VARCHAR2,
                        p_release_number IN VARCHAR2,
                        p_line_number IN VARCHAR2,
                        p_company_id IN Number,
                        p_company_site_id IN NUMBER,
                        p_tp_id IN NUMBER,
                        p_tp_site_id IN Number,
                        p_item_id IN NUMBER)
RETURN NUMBER IS
        l_total_qty number:= 0;

BEGIN

   --for all cases, the tp view org is the po org.
   --to compare the po quantity and so quantity, need to
   --get the tp_quantity of the so.
        SELECT  sum(sd.tp_quantity)
        INTO    l_total_qty
        FROM    msc_sup_dem_entries sd
        WHERE   sd.plan_id = G_PLAN_ID
        AND     sd.publisher_id = p_company_id
        AND     sd.publisher_site_id = p_company_site_id
        AND     sd.inventory_item_id = p_item_id
        AND     sd.customer_id = p_tp_id
        AND     sd.customer_site_id = p_tp_site_id
        AND     sd.publisher_order_type = SALES_ORDER
        AND     sd.end_order_number = p_order_number
        AND     nvl(sd.end_order_rel_number, -1) = nvl(p_release_number, -1)
        AND     nvl(sd.end_order_line_number, -1) =  nvl(p_line_number, -1);

   If (l_total_qty is null) then
      l_total_qty := 0;
   end if;
      return l_total_qty;

EXCEPTION
    when NO_DATA_FOUND then
        l_total_qty := 0;
        return l_total_qty;

END GET_TOTAL_QTY;

-----------------------------------------------------------------
-- Function does_so_exist
-----------------------------------------------------------------
FUNCTION DOES_SO_EXIST( p_order_number IN VARCHAR2,
                        p_release_number IN VARCHAR2,
                        p_line_number IN VARCHAR2,
         p_company_id IN Number,
                        p_company_site_id IN NUMBER,
         p_tp_id IN Number,
                        p_tp_site_id IN NUMBER,
                        p_item_id IN NUMBER)
RETURN NUMBER IS
        l_return_code  Number := 0;

BEGIN
        SELECT  1
        INTO    l_return_code
        FROM    dual
        WHERE EXISTS (SELECT sd.order_number
                        FROM msc_sup_dem_entries sd
                       WHERE sd.plan_id = G_PLAN_ID
          AND sd.publisher_id = p_company_id
                         AND sd.publisher_site_id = p_company_site_id
                         AND sd.publisher_order_type = SALES_ORDER
                         AND sd.end_order_number = p_order_number
                         AND nvl(sd.end_order_rel_number, -1) =
                                nvl(p_release_number, -1)
                         AND nvl(sd.end_order_line_number, -1) =
                                nvl(p_line_number, -1)
          AND sd.customer_id = p_tp_id
                         AND sd.customer_site_id = p_tp_site_id
                         AND sd.inventory_item_id = p_item_id);

        return l_return_code;
EXCEPTION
        when NO_DATA_FOUND then
         l_return_code := 0;
                return l_return_code;
END DOES_SO_EXIST;
-----------------------------------------------------------------
--  Function does_po_exist
-----------------------------------------------------------------
FUNCTION DOES_PO_EXIST( p_end_order_number IN VARCHAR2,
                        p_end_order_rel_number IN VARCHAR2,
                        p_end_order_line_number IN VARCHAR2,
         p_company_id IN NUMBER,
         p_company_site_id IN NUMBER,
                        p_tp_id IN NUMBER,
                        p_tp_site_id IN NUMBER,
                        p_item_id IN NUMBER)
RETURN NUMBER IS
        l_return_code  Number := 0;

BEGIN
        SELECT  1
        INTO    l_return_code
        FROM    dual
        WHERE EXISTS (SELECT sd.order_number
                        FROM msc_sup_dem_entries sd
                       WHERE sd.plan_id = G_PLAN_ID
                         AND sd.publisher_id = p_company_id
                         AND sd.publisher_site_id = p_company_site_id
                         AND sd.publisher_order_type = PURCHASE_ORDER
                         AND sd.order_number = p_end_order_number
                         AND nvl(sd.release_number, -1) =
                                nvl(p_end_order_rel_number, -1)
                         AND nvl(sd.line_number, -1) =
                                nvl(p_end_order_line_number, -1)
                         AND sd.supplier_id = p_tp_id
                         AND sd.supplier_site_id = p_tp_site_id
                         AND sd.inventory_item_id = p_item_id);

        return l_return_code;
EXCEPTION
        when NO_DATA_FOUND then
                return l_return_code;
END DOES_PO_EXIST;

-----------------------------------------------------------------
--  Function does_shiprcpt_exist
-----------------------------------------------------------------
FUNCTION DOES_SHIPRCPT_EXIST( p_order_number IN VARCHAR2,
                        p_release_number IN VARCHAR2,
                        p_line_number IN VARCHAR2,
         p_company_id IN NUMBER,
         p_company_site_id IN NUMBER,
                        p_tp_id IN NUMBER,
                        p_tp_site_id IN NUMBER,
                        p_item_id IN NUMBER)
RETURN NUMBER IS
        l_return_code  Number := 0;

BEGIN
        SELECT  1
        INTO    l_return_code
        FROM    dual
        WHERE EXISTS (SELECT sd.order_number
                        FROM msc_sup_dem_entries sd
                       WHERE sd.plan_id = G_PLAN_ID
                         AND sd.publisher_id = p_company_id
                         AND sd.publisher_site_id = p_company_site_id
                         AND sd.publisher_order_type = SHIPMENT_RECEIPT
                         AND sd.end_order_number = p_order_number
                         AND nvl(sd.end_order_rel_number, -1) =
                                nvl(p_release_number, -1)
                         AND nvl(sd.end_order_line_number, -1) =
                                nvl(p_line_number, -1)
                         AND sd.supplier_id = p_tp_id
                         AND sd.supplier_site_id = p_tp_site_id
                         AND sd.inventory_item_id = p_item_id);

        return l_return_code;
EXCEPTION
        when NO_DATA_FOUND then
         l_return_code := 0;
                return l_return_code;
END DOES_SHIPRCPT_EXIST;

-----------------------------------------------------------------
-- Function does_detail_excep_exist
-----------------------------------------------------------------
FUNCTION DOES_DETAIL_EXCEP_EXIST( p_company_id IN Number,
                        p_company_site_id IN NUMBER,
         p_item_id IN NUMBER,
                        p_exception_type IN NUMBER,
                        p_trx_id1 IN NUMBER,
                        p_trx_id2 IN NUMBER)
RETURN NUMBER IS
        l_exception_detail_id  Number := 0;

BEGIN


   if p_trx_id2 is null then
        SELECT ed.exception_detail_id
          INTO   l_exception_detail_id
          FROM msc_x_exception_details ed
         WHERE ed.plan_id = G_PLAN_ID
           AND ed.inventory_item_id = p_item_id
           AND ed.company_id = p_company_id
           AND ed.company_site_id = p_company_site_id
           AND ed.exception_type = p_exception_type
           AND ed.transaction_id1 = p_trx_id1;
   else

        SELECT ed.exception_detail_id
          INTO l_exception_detail_id
          FROM msc_x_exception_details ed
         WHERE ed.plan_id = G_PLAN_ID
           AND ed.inventory_item_id = p_item_id
           AND ed.company_id = p_company_id
           AND ed.company_site_id = p_company_site_id
           AND ed.exception_type = p_exception_type
           AND ed.transaction_id1 = p_trx_id1
           AND ed.transaction_id2 = p_trx_id2;
   end if;

        return l_exception_detail_id;

EXCEPTION
        when NO_DATA_FOUND then
      l_exception_detail_id := 0;
                return l_exception_detail_id;
END DOES_DETAIL_EXCEP_EXIST;

------------------------------------------------------------
FUNCTION DOES_LO_EXIST  (p_company_id IN Number,
         p_company_site_id IN Number,
         p_item_id In Number,
         p_exception_type In number,
                        p_trx_id In number)
RETURN NUMBER IS

l_ret_flag      Number := -1;
BEGIN

   SELECT   1
   INTO  l_ret_flag
   FROM  dual
   WHERE EXISTS (SELECT 'x'
         FROM  msc_x_exception_details
         WHERE plan_id = G_PLAN_ID
         AND   company_id = p_company_id
         AND   company_site_id = p_company_site_id
         AND   inventory_item_id = p_item_id
         AND   exception_type = p_exception_type
         AND   transaction_id1 = p_trx_id);
return l_ret_flag;

exception
        when NO_DATA_FOUND then
                l_ret_flag := -1;
                return l_ret_flag;
END DOES_LO_EXIST;


-------------------------------------------------------------
--This is procedure is call when ods netting is run and also when loading
--data.
--delete all dependent exceptions when deleting or purging any entry
--in msc_sup_dem_entries.  We use the 'D' or 'P' sync indicator
-- during the data upload that the record needs to removed.  Currently,
--the entry in msc_sup_dem_entries is set with the quantity = 0

PROCEDURE DELETE_EXEC_ORDER_DEPENDENCY (p_refresh_number IN Number) IS
CURSOR  delete_entry_c IS
SELECT  distinct sd.transaction_id,
   med.company_id,
        med.company_site_id,
        med.inventory_item_id,
        med.customer_id,
        med.customer_site_id,
        med.supplier_id,
        med.supplier_site_id,
        med.exception_group,
        med.exception_type,
        med.exception_detail_id
FROM    msc_sup_dem_entries sd, msc_x_exception_details med
WHERE   sd.plan_id = G_PLAN_ID
AND     sd.quantity = 0
AND	nvl(sd.last_update_login,-1) = -99
AND     sd.last_refresh_number >= p_refresh_number
AND     med.plan_id = sd.plan_id
AND     med.transaction_id1 = sd.transaction_id
UNION
SELECT  distinct sd.transaction_id,
   med.company_id,
        med.company_site_id,
        med.inventory_item_id,
        med.customer_id,
        med.customer_site_id,
        med.supplier_id,
        med.supplier_site_id,
        med.exception_group,
        med.exception_type,
        med.exception_detail_id
FROM    msc_sup_dem_entries sd, msc_x_exception_details med
WHERE   sd.plan_id = G_PLAN_ID
AND     sd.quantity = 0
AND	nvl(sd.last_update_login, -1) = -99
AND     sd.last_refresh_number >= p_refresh_number
AND     med.plan_id = sd.plan_id
AND     med.transaction_id2 = sd.transaction_id;


l_company_id      Number;
l_company_site_id        Number;
l_item_id         Number;
l_customer_id     Number;
l_customer_site_id   Number;
l_supplier_id     Number;
l_supplier_site_id   Number;
l_exception_group Number;
l_exception_type        Number;
l_exception_detail_id   Number;
l_transaction_id        Number;
l_sr_instance_id  Number;
l_item_type Varchar2(20) := 'MSCSNDNT';
l_item_key Varchar2(100) := null;
l_row       Number;
BEGIN
--dbms_output.put_line('Start delete qty = 0');
        open delete_entry_c;
        loop

                fetch delete_entry_c into l_transaction_id,
                                        l_company_id,
                                        l_company_site_id,
                                        l_item_id,
                                        l_customer_id,
                                        l_customer_site_id,
                                        l_supplier_id,
                                        l_supplier_site_id,
                                        l_exception_group,
                                        l_exception_type,
                                        l_exception_detail_id;
                exit when delete_entry_c%NOTFOUND;

               l_item_key :=  to_char(l_exception_group) || '-' ||
                        to_char(l_exception_type) || '-' ||
               to_char(l_item_id) || '-' ||
                        to_char(l_company_id) || '-' ||
               to_char(l_company_site_id) || '-' ||
               to_char(l_customer_id) || '-' ||
               to_char(l_customer_site_id) || '-' ||
               to_char(l_supplier_id) || '-' ||
               to_char(l_supplier_site_id) || '-' ||
               to_char(l_exception_detail_id) || '%';

               delete_wf_notification(l_item_type, l_item_key);
                 BEGIN
            --dbms_output.put_line('---Maintaining exceptions details');
                      delete msc_x_exception_details
                      where   plan_id = G_PLAN_ID
                      and  company_id = l_company_id
                      and  company_site_id = l_company_site_id
                      and  inventory_item_id = l_item_id
                      and  exception_type = l_exception_type
                      and  exception_detail_id = l_exception_detail_id;

                      l_row := SQL%ROWCOUNT;
                      --dbms_output.put_line('archive detail exception ' || l_row);

                      --dbms_output.put_line('---Maintaining item exceptions');
                      update  msc_item_exceptions
                      set     exception_count = exception_count - l_row,
                        last_update_date = sysdate
                      where   plan_id = G_PLAN_ID
                      and  company_id = l_company_id
                      and     company_site_id = l_company_site_id
                      and     inventory_item_id = l_item_id
                      and     exception_type = l_exception_type;

                      l_row := SQL%ROWCOUNT;
                      --dbms_output.put_line('archive item exception ' || l_row);

                  EXCEPTION
                       when others then
                               return;
            END;

        end loop;
        close delete_entry_c;

exception
        when others then
                return;
END DELETE_EXEC_ORDER_DEPENDENCY;

---------------------------------------------------------------------

PROCEDURE DELETE_EXCEP IS

l_company_id      Number;
l_company_site_id        Number;
l_item_id         Number;
l_customer_id     Number;
l_customer_site_id   Number;
l_supplier_id     Number;
l_supplier_site_id   Number;
l_exception_group Number;
l_exception_type        Number;
l_exception_detail_id   Number;
l_sr_instance_id  Number;
l_item_type Varchar2(20) := 'MSCSNDNT';
l_item_key Varchar2(100) := null;
l_row       Number;
p_days      Number;


CURSOR  delete_excep_c (p_days in number)IS
SELECT  company_id,
        company_site_id,
        inventory_item_id,
        customer_id,
        customer_site_id,
        supplier_id,
        supplier_site_id,
        exception_group,
        exception_type,
        exception_detail_id
FROM    msc_x_exception_details
WHERE   nvl(plan_id,G_PLAN_ID) = G_PLAN_ID     --6603563
and trunc(last_update_date ) < trunc(sysdate) - p_days;


BEGIN

p_days := nvl(FND_PROFILE.VALUE('MSC_PURGE_EXCEPTION_DAYS'),0);

FND_FILE.PUT_LINE(FND_FILE.LOG,'p_days '||p_days);
If (p_days > 0) then

        open delete_excep_c(p_days);
        loop

                fetch delete_excep_c into l_company_id,
                                        l_company_site_id,
                                        l_item_id,
					l_customer_id,
                                        l_customer_site_id,
                                        l_supplier_id,
                                        l_supplier_site_id,
                                        l_exception_group,
                                        l_exception_type,
                                        l_exception_detail_id;
                exit when delete_excep_c%NOTFOUND;

	       l_item_key :=  to_char(l_exception_group) || '-' ||
               to_char(l_exception_type) || '-' ||
               to_char(l_item_id) || '-' ||
               to_char(l_company_id) || '-' ||
               to_char(l_company_site_id) || '-' ||
               to_char(l_customer_id) || '-' ||
               to_char(l_customer_site_id) || '-' ||
               to_char(l_supplier_id) || '-' ||
               to_char(l_supplier_site_id) || '-' ||
               to_char(l_exception_detail_id) || '%';

		delete_wf_notification(l_item_type, l_item_key);

                 BEGIN

                      delete msc_x_exception_details
                      where   exception_detail_id = l_exception_detail_id;

                      l_row := SQL%ROWCOUNT;

                      update  msc_item_exceptions
                      set     exception_count = exception_count - l_row,
                        last_update_date = sysdate
                      where   plan_id = G_PLAN_ID
                      and  company_id = l_company_id
                      and     company_site_id = l_company_site_id
                      and     inventory_item_id = l_item_id
                      and     exception_type = l_exception_type;

                      l_row := SQL%ROWCOUNT;


                  EXCEPTION
                       when others then
                               return;
            END;

        end loop;
        close delete_excep_c;
       end if;
exception
        when others then
                return;
END DELETE_EXCEP;

-------------------------------------------------------------------------
-- PROCEDURE PURGE_ZQTY_EXEC_ORDER
------------------------------------------------------------------------
PROCEDURE PURGE_ZQTY_EXEC_ORDER (p_refresh_number IN Number) IS

BEGIN

     DELETE /*+ PARALLEL(sd) */ from msc_sup_dem_entries sd
     WHERE      sd.plan_id = G_PLAN_ID
     AND sd.quantity = 0
     AND sd.publisher_order_type in
            (PURCHASE_ORDER,SALES_ORDER,ASN,SHIPMENT_RECEIPT)
     AND nvl(last_update_login,-1) = -99
     AND sd.last_refresh_number >= p_refresh_number;

EXCEPTION
        when others then
                return;

END PURGE_ZQTY_EXEC_ORDER;
---------------------------------------------------------------------
--procedure DELETE_OBSOLETE_EXCEPTIONS
---------------------------------------------------------------------
PROCEDURE delete_obsolete_exceptions(p_company_id IN Number,
            p_company_site_id IN Number,
            p_customer_id   in Number,
            p_customer_site_id In Number,
            p_supplier_id IN Number,
                                p_supplier_site_id IN Number,
                                p_exception_group IN Number,
                                p_curr_exc_type  in Number,
                                p_obs_exc_type  in Number,
                                p_item_id   in Number,
                                p_bkt_start_date  in Date,
                                p_bkt_end_date    in Date,
                                p_type In Number,
                                p_transaction_id1 In Number,
                                p_transaction_id2 IN number
            ) IS

l_exception_detail_id   Number;
l_row          number := 0;
l_item_type       Varchar2(20) := 'MSCSNDNT';
l_item_key     Varchar2(100) := null;
v_exception_group   Number ;


BEGIN
l_item_key :=   to_char(p_exception_group) || '-' ||
      to_char(p_curr_exc_type) || '-' ||
      to_char(p_item_id) || '-' ||
      to_char(p_company_id) || '-' ||
      to_char(p_company_site_id) || '-' ||
      to_char(p_customer_id) || '-' ||
      to_char(p_customer_site_id) || '-' ||
      to_char(p_supplier_id) || '-' ||
      to_char(p_supplier_site_id) || '%';

delete_wf_notification(l_item_type, l_item_key);

IF (p_obs_exc_type is not null) THEN
   l_item_key :=   to_char(p_exception_group) || '-' ||
      to_char(p_obs_exc_type) || '-' ||
      to_char(p_item_id) || '-' ||
      to_char(p_company_id) || '-' ||
      to_char(p_company_site_id) || '-' ||
      to_char(p_customer_id) || '-' ||
      to_char(p_customer_site_id) || '-' ||
      to_char(p_supplier_id) || '-' ||
      to_char(p_supplier_site_id) || '%';

      FND_FILE.PUT_LINE(FND_FILE.LOG,'for 1 : l_item_key'||l_item_key);
   delete_wf_notification(l_item_type, l_item_key);

   -- added for VMI Exceptions: notification deletion behaviour

IF (p_obs_exc_type in (G_EXCEP29, G_EXCEP30)) then

v_exception_group := G_MATERIAL_EXCESS ;

l_item_key :=   to_char(v_exception_group) || '-' ||
      to_char(p_obs_exc_type) || '-' ||
      to_char(p_item_id) || '-' ||
      to_char(p_company_id) || '-' ||
      to_char(p_company_site_id) || '-' ||
      to_char(p_customer_id) || '-' ||
      to_char(p_customer_site_id) || '-' ||
      to_char(p_supplier_id) || '-' ||
      to_char(p_supplier_site_id) || '%';

      FND_FILE.PUT_LINE(FND_FILE.LOG,'for 2 : l_item_key = '||l_item_key);
   delete_wf_notification(l_item_type, l_item_key);

END IF;
END IF;

IF (p_type = EXECUTION_ORDER) then
        IF (p_curr_exc_type is not null) THEN
      delete from msc_x_exception_details ex
      where ex.plan_id = G_PLAN_ID
      and   ex.company_id = p_company_id
      and   ex.company_site_id = p_company_site_id
      and   nvl(ex.customer_id,-1) = nvl(p_customer_id,-1)
      and   nvl(ex.customer_site_id,-1) = nvl(p_customer_site_id,-1)
      and   nvl(ex.supplier_id,-1) = nvl(p_supplier_id, -1)
      and   nvl(ex.supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
      and   ex.inventory_item_id = p_item_id
      and   ex.exception_type = p_curr_exc_type
      and   ex.transaction_id1 = p_transaction_id1
      and   ex.transaction_id2 = p_transaction_id2
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

      l_row := SQL%ROWCOUNT;
      ----dbms_output.put_line('item row delete ' || l_row);

      update msc_item_exceptions ex
      set   ex.exception_count = ex.exception_count - l_row,
      ex.last_update_date = sysdate
      where ex.plan_id = G_PLAN_ID
      and   ex.company_id = p_company_id
      and   ex.company_site_id = p_company_site_id
      and   ex.inventory_item_id = p_item_id
      and   ex.exception_type = p_curr_exc_type
      and   ex.version = 0
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;
      ----dbms_output.put_line('delete item exception');
   END IF;

   IF (p_obs_exc_type is not null) THEN
      l_row := 0;

         delete from msc_x_exception_details ex
         where ex.plan_id = G_PLAN_ID
         and   ex.company_id = p_company_id
         and   ex.company_site_id = p_company_site_id
         and   nvl(ex.customer_id,-1) = nvl(p_customer_id,-1)
         and   nvl(ex.customer_site_id,-1) = nvl(p_customer_site_id,-1)
         and   nvl(ex.supplier_id,-1) = nvl(p_supplier_id, -1)
         and   nvl(ex.supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
         and   ex.inventory_item_id = p_item_id
         and   ex.exception_type = p_obs_exc_type
         and   ex.transaction_id1 = p_transaction_id1
         and   ex.transaction_id2 = p_transaction_id2
         and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

         l_row := SQL%ROWCOUNT;
         ----dbms_output.put_line('item row delete ' || l_row);

         update msc_item_exceptions ex
         set   ex.exception_count = ex.exception_count - l_row,
         ex.last_update_date = sysdate
         where ex.plan_id = G_PLAN_ID
         and   ex.company_id = p_company_id
         and   ex.company_site_id = p_company_site_id
         and   ex.inventory_item_id = p_item_id
         and   ex.exception_type  = p_obs_exc_type
         and   ex.version = 0
         and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;
         ----dbms_output.put_line('delete item exception');
      END IF;

ELSIF (p_type in (SUPPLY_PLANNING,DEMAND_PLANNING,VMI)) then

   IF (p_curr_exc_type is not null) THEN
      delete from msc_x_exception_details ex
      where ex.plan_id = G_PLAN_ID
      and   ex.company_id = p_company_id
      and   ex.company_site_id = p_company_site_id
      and   nvl(ex.customer_id,-1) = nvl(p_customer_id,-1)
      and   nvl(ex.customer_site_id,-1) = nvl(p_customer_site_id,-1)
      and   nvl(ex.supplier_id,-1) = nvl(p_supplier_id, -1)
      and   nvl(ex.supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
      and   ex.inventory_item_id = p_item_id
      and   ex.exception_type = p_curr_exc_type
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

      l_row := SQL%ROWCOUNT;
      ----dbms_output.put_line('detail row delete ' || l_row);

            update msc_item_exceptions ex
            set   ex.exception_count = ex.exception_count - l_row,
            ex.last_update_date = sysdate
            where ex.plan_id = G_PLAN_ID
            and   ex.company_id = p_company_id
            and   ex.company_site_id = p_company_site_id
            and   ex.inventory_item_id = p_item_id
            and   ex.exception_type = p_curr_exc_type
            and   ex.version = 0
            and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;
         ----dbms_output.put_line('delete item exception');
      END IF;
      IF (p_obs_exc_type is not null) THEN
         l_row := 0;
            delete from msc_x_exception_details ex
            where ex.plan_id = G_PLAN_ID
            and   ex.company_id = p_company_id
            and   ex.company_site_id = p_company_site_id
            and   nvl(ex.customer_id,-1) = nvl(p_customer_id,-1)
            and   nvl(ex.customer_site_id,-1) = nvl(p_customer_site_id,-1)
            and   nvl(ex.supplier_id,-1) = nvl(p_supplier_id, -1)
            and   nvl(ex.supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
            and   ex.inventory_item_id = p_item_id
            and   ex.exception_type = p_obs_exc_type
            and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

         l_row := SQL%ROWCOUNT;
         ----dbms_output.put_line('detail row delete ' || l_row);

            update msc_item_exceptions ex
            set   ex.exception_count = ex.exception_count - l_row,
            ex.last_update_date = sysdate
            where ex.plan_id = G_PLAN_ID
            and   ex.company_id = p_company_id
            and   ex.company_site_id = p_company_site_id
            and   ex.inventory_item_id = p_item_id
            and   ex.exception_type = p_obs_exc_type
            and   ex.version = 0
            and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;
         ----dbms_output.put_line('delete item exception');
      END IF;
ELSE
   IF (p_curr_exc_type is not null) THEN
      delete from msc_x_exception_details ex
      where ex.plan_id = G_PLAN_ID
      and   ex.company_id = p_company_id
      and   ex.company_site_id = p_company_site_id
      and   nvl(ex.customer_id,-1) = nvl(p_customer_id,-1)
      and   nvl(ex.customer_site_id,-1) = nvl(p_customer_site_id,-1)
      and   nvl(ex.supplier_id,-1) = nvl(p_supplier_id, -1)
      and   nvl(ex.supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
      and   ex.inventory_item_id = p_item_id
      and   ex.exception_type = p_curr_exc_type
      and   ex.date1 = p_bkt_start_date
      and   ex.date2 = p_bkt_end_date
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

      l_row := SQL%ROWCOUNT;
      ----dbms_output.put_line('detail row delete ' || l_row);

            update msc_item_exceptions ex
            set   ex.exception_count = ex.exception_count - l_row,
            ex.last_update_date = sysdate
            where ex.plan_id = G_PLAN_ID
            and   ex.company_id = p_company_id
            and   ex.company_site_id = p_company_site_id
            and   ex.inventory_item_id = p_item_id
            and   ex.exception_type = p_curr_exc_type
            and   ex.version = 0
            and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;
         ----dbms_output.put_line('delete item exception');
      END IF;
      IF (p_obs_exc_type is not null) THEN
         l_row := 0;
            delete from msc_x_exception_details ex
            where ex.plan_id = G_PLAN_ID
            and   ex.company_id = p_company_id
            and   ex.company_site_id = p_company_site_id
            and   nvl(ex.customer_id,-1) = nvl(p_customer_id,-1)
            and   nvl(ex.customer_site_id,-1) = nvl(p_customer_site_id,-1)
            and   nvl(ex.supplier_id,-1) = nvl(p_supplier_id, -1)
            and   nvl(ex.supplier_site_id,-1) = nvl(p_supplier_site_id,-1)
            and   ex.inventory_item_id = p_item_id
            and   ex.exception_type = p_obs_exc_type
            and   ex.date1 = p_bkt_start_date
            and   ex.date2 = p_bkt_end_date
            and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

         l_row := SQL%ROWCOUNT;
         ----dbms_output.put_line('detail row delete ' || l_row);

            update msc_item_exceptions ex
            set   ex.exception_count = ex.exception_count - l_row,
            ex.last_update_date = sysdate
            where ex.plan_id = G_PLAN_ID
            and   ex.company_id = p_company_id
            and   ex.company_site_id = p_company_site_id
            and   ex.inventory_item_id = p_item_id
            and   ex.exception_type = p_obs_exc_type
            and   ex.version = 0
            and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;
         ----dbms_output.put_line('delete item exception');
      END IF;
END IF;

exception
        when others then
              	MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.delete_obsolete_exceptions');
      		MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
                return;

END delete_obsolete_exceptions;

----------------------------------------------------------------------
--PROCEDURE CLEAN_UP_PROCESS
--Clean up process only for the seeded exception group
-------------------------------------------------------------------------
PROCEDURE clean_up_process IS

BEGIN

   --dbms_output.put_line('Update the magic number');


   --Update the last_update_login back to null to ensure accurate archival
   --when exceptions are generated in the next round

   update   msc_item_exceptions ex
   set   ex.last_update_login = null,
      ex.last_update_date = sysdate
   where    ex.plan_id = G_PLAN_ID
   --and   ex.version = 0
   and   exception_group in (1,2,3,4,5,6,7,8,9,10)
   and   nvl(ex.last_update_login,-1) = G_MAGIC_NUMBER;

   --update the if the count is 0 to older version
   update msc_item_exceptions ex
   set   ex.version = version + 1,
      ex.last_update_date = sysdate
   where    ex.plan_id = G_PLAN_ID
   --and   ex.version = 0
   and   exception_group in (1,2,3,4,5,6,7,8,9,10)
   and   ex.exception_count = 0;

   -- In prior release, we have kept a history of all the exceptions
   -- occuring during netting for intelligent analysis use such as
   -- exception convergence; overtime or latency of a plan in msc_item_exceptions
   -- table.  The current usage is using the latest version of the data and
   -- not all the history data.  If the table is maintaining all the history
   -- data, in the rolling of the netting engine run for a period of time,
   -- the table will grow quickly and create a performance problem.  Therefore,
   -- the table is arhived based on the user defined profile option and only keep
   -- certain number of version.  Default verion = 20

   delete    msc_item_exceptions ex
   where    plan_id = G_PLAN_ID
   and   exception_group in (1,2,3,4,5,6,7,8,9,10)
   and      version > 20;

EXCEPTION
        when others then
                return;

END CLEAN_UP_PROCESS;


--==============================================================================
-- PROCEDURE add_to_detail_tbl
--==============================================================================
PROCEDURE ADD_TO_EXCEPTION_TBL(p_company_id IN Number,
   p_company_name       IN Varchar2,
         p_company_site_id    IN Number,
         p_company_site_name  IN Varchar2,
         p_item_id      IN Number,
        p_item_name     IN Varchar2,
        p_item_description    IN Varchar2,
        p_exception_type   IN Number,
        p_exception_type_name    IN Varchar2,
        p_exception_group  IN Number,
        p_exception_group_name   IN Varchar2,
        p_trx_id1       IN Number,
        p_trx_id2       IN Number,
        p_customer_id      IN Number,
        p_customer_name    IN Varchar2,
        p_customer_site_id    IN Number,
        p_customer_site_name  IN varchar2,
        p_customer_item_name  IN Varchar2,
        p_supplier_id      IN Number,
         p_supplier_name   IN Varchar2,
        p_supplier_site_id    IN Number,
        p_supplier_site_name  IN Varchar2,
        p_supplier_item_name  IN Varchar2,
        p_number1       IN Number,
        p_number2       IN Number,
        p_number3       IN Number,
        p_threshold     IN Number,
        p_lead_time     IN Number,
        p_item_min_qty     IN Number,
        p_item_max_qty     IN Number,
        p_order_number     IN Varchar2 ,
        p_release_number   IN Varchar2,
        p_line_number      IN Varchar2,
        p_end_order_number    IN Varchar2,
        p_end_order_rel_number  IN Varchar2,
        p_end_order_line_number IN Varchar2,
        p_creation_date    	IN Date,
        p_tp_creation_date    	IN Date,
        p_date1      		IN Date,
        p_date2   		IN Date,
        p_date3       		IN Date,
        p_date4			IN Date,
        p_date5			IN Date,
        p_exception_basis	IN Varchar2,
   a_company_id            IN OUT NOCOPY  number_arr,
   a_company_name          IN OUT NOCOPY  publisherList,
   a_company_site_id       IN OUT NOCOPY  number_arr,
   a_company_site_name     IN OUT NOCOPY  pubsiteList,
   a_item_id               IN OUT NOCOPY  number_arr,
   a_item_name             IN OUT NOCOPY  itemnameList,
   a_item_desc             IN OUT NOCOPY  itemdescList,
   a_exception_type        IN OUT NOCOPY  number_arr,
   a_exception_type_name   IN OUT NOCOPY  exceptypeList,
   a_exception_group       IN OUT NOCOPY  number_arr,
   a_exception_group_name  IN OUT NOCOPY  excepgroupList,
   a_trx_id1               IN OUT NOCOPY  number_arr,
   a_trx_id2               IN OUT NOCOPY  number_arr,
   a_customer_id           IN OUT NOCOPY  number_arr,
   a_customer_name         IN OUT NOCOPY  customerList,
   a_customer_site_id      IN OUT NOCOPY  number_arr,
   a_customer_site_name    IN OUT NOCOPY  custsiteList,
   a_customer_item_name IN OUT NOCOPY  itemnameList,
   a_supplier_id           IN OUT NOCOPY  number_arr,
   a_supplier_name         IN OUT NOCOPY  supplierList,
   a_supplier_site_id      IN OUT NOCOPY  number_arr,
   a_supplier_site_name    IN OUT NOCOPY  suppsiteList,
   a_supplier_item_name    IN OUT NOCOPY  itemnameList,
   a_number1               IN OUT NOCOPY  number_arr,
   a_number2               IN OUT NOCOPY  number_arr,
   a_number3               IN OUT NOCOPY  number_arr,
   a_threshold             IN OUT NOCOPY  number_arr,
   a_lead_time             IN OUT NOCOPY  number_arr,
   a_item_min_qty          IN OUT NOCOPY  number_arr,
   a_item_max_qty          IN OUT NOCOPY  number_arr,
   a_order_number          IN OUT NOCOPY  ordernumberList,
   a_release_number        IN OUT NOCOPY  releasenumList,
   a_line_number           IN OUT NOCOPY  linenumList,
   a_end_order_number      IN OUT NOCOPY  ordernumberList,
   a_end_order_rel_number  IN OUT NOCOPY  releasenumList,
   a_end_order_line_number IN OUT NOCOPY  linenumList,
   a_creation_date         IN OUT  NOCOPY date_arr,
   a_tp_creation_date      IN OUT  NOCOPY date_arr,
   a_date1           	   IN OUT  NOCOPY date_arr,
   a_date2        	   IN OUT  NOCOPY date_arr,
   a_date3                 IN OUT  NOCOPY date_arr,
   a_date4		   IN OUT  NOCOPY date_arr,
   a_date5		   IN OUT  NOCOPY date_arr,
   a_exception_basis	   IN OUT  NOCOPY exceptbasisList) IS

BEGIN

   a_company_id.EXTEND;
   a_company_name.EXTEND;
   a_company_site_id.EXTEND;
   a_company_site_name.EXTEND;
   a_item_id.EXTEND;
   a_item_name.EXTEND;
   a_item_desc.EXTEND;
   a_exception_type.EXTEND;
   a_exception_type_name.EXTEND;
   a_exception_group.EXTEND;
   a_exception_group_name.EXTEND;
   a_trx_id1.EXTEND;
   a_trx_id2.EXTEND;
   a_customer_id.EXTEND;
   a_customer_name.EXTEND;
   a_customer_site_id.EXTEND;
   a_customer_site_name.EXTEND;
   a_customer_item_name.EXTEND;
   a_supplier_id.EXTEND;
   a_supplier_name.EXTEND;
   a_supplier_site_id.EXTEND;
   a_supplier_site_name.EXTEND;
   a_supplier_item_name.EXTEND;
   a_number1.EXTEND;
   a_number2.EXTEND;
   a_number3.EXTEND;
   a_threshold.EXTEND;
   a_lead_time.EXTEND;
   a_item_min_qty.EXTEND;
   a_item_max_qty.EXTEND;
   a_order_number.EXTEND;
   a_release_number.EXTEND;
   a_line_number.EXTEND;
   a_end_order_number.EXTEND;
   a_end_order_rel_number.EXTEND;
   a_end_order_line_number.EXTEND;
   a_creation_date.EXTEND;
   a_tp_creation_date.EXTEND;
   a_date1.EXTEND;
   a_date2.EXTEND;
   a_date3.EXTEND;
   a_date4.EXTEND;
   a_date5.EXTEND;
   a_exception_basis.EXTEND;

   --FND_FILE.PUT_LINE(FND_FILE.LOG, 'Count ' || a_company_id.COUNT);

      a_company_id(a_company_id.COUNT) := p_company_id;
   a_company_name(a_company_id.COUNT) := p_company_name;
   a_company_site_id(a_company_id.COUNT) := p_company_site_id;
   a_company_site_name(a_company_id.COUNT) := p_company_site_name;
   a_item_id(a_company_id.COUNT) :=  p_item_id;
   a_item_name(a_company_id.COUNT) := p_item_name;
   a_item_desc(a_company_id.COUNT) := p_item_description;
   a_exception_type(a_company_id.COUNT) :=  p_exception_type;
   a_exception_type_name(a_company_id.COUNT) := p_exception_type_name;
   a_exception_group(a_company_id.COUNT) :=  p_exception_group;
   a_exception_group_name(a_company_id.COUNT) :=  p_exception_group_name;
   a_trx_id1(a_company_id.COUNT) := p_trx_id1;
   a_trx_id2(a_company_id.COUNT) :=  p_trx_id2;
   a_customer_id(a_company_id.COUNT) := p_customer_id;
   a_customer_name(a_company_id.COUNT) :=  p_customer_name;
   a_customer_site_id(a_company_id.COUNT) :=  p_customer_site_id;
   a_customer_site_name(a_company_id.COUNT) := p_customer_site_name;
   a_customer_item_name(a_company_id.COUNT) := p_customer_item_name;
   a_supplier_id(a_company_id.COUNT) := p_supplier_id;
   a_supplier_name(a_company_id.COUNT) := p_supplier_name;
   a_supplier_site_id(a_company_id.COUNT) :=  p_supplier_site_id;
   a_supplier_site_name(a_company_id.COUNT) := p_supplier_site_name;
   a_supplier_item_name(a_company_id.COUNT) := p_supplier_item_name;
   a_number1(a_company_id.COUNT) := p_number1;
   a_number2(a_company_id.COUNT) := p_number2;
   a_number3(a_company_id.COUNT) := p_number3;
   a_threshold(a_company_id.COUNT) := p_threshold;
   a_lead_time(a_company_id.COUNT) := p_lead_time;
   a_item_min_qty(a_company_id.COUNT) := p_item_min_qty;
   a_item_max_qty(a_company_id.COUNT) := p_item_max_qty;
   a_order_number(a_company_id.COUNT) := p_order_number;
   a_release_number(a_company_id.COUNT) := p_release_number;
   a_line_number(a_company_id.COUNT) := p_line_number;
   a_end_order_number(a_company_id.COUNT) := p_end_order_number;
   a_end_order_rel_number(a_company_id.COUNT) := p_end_order_rel_number;
   a_end_order_line_number(a_company_id.COUNT) := p_end_order_line_number;
   a_creation_date(a_company_id.COUNT) :=  p_creation_date;
   a_tp_creation_date(a_company_id.COUNT) :=  p_tp_creation_date;
   a_date1(a_company_id.COUNT) := p_date1;
   a_date2(a_company_id.COUNT) := p_date2;
   a_date3(a_company_id.COUNT) := p_date3;
   a_date4(a_company_id.COUNT) := p_date4;
   a_date5(a_company_id.COUNT) := p_date5;
   a_exception_basis(a_company_id.COUNT) := p_exception_basis;




EXCEPTION
   when others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.add_to_exception_tbl');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      --dbms_output.put_line('add_to_exception_tbl error ' || sqlerrm);
      return;
END add_to_exception_tbl;

--===================================================================
-- PROCEDURE POPULATE_EXCEPTION_DATA
--===================================================================
PROCEDURE POPULATE_EXCEPTION_DATA(
   a_company_id            IN  number_arr,
   a_company_name          IN  publisherList,
   a_company_site_id       IN  number_arr,
   a_company_site_name     IN  pubsiteList,
   a_item_id               IN  number_arr,
   a_item_name             IN  itemnameList,
   a_item_desc             IN  itemdescList,
   a_exception_type        IN  number_arr,
   a_exception_type_name   IN  exceptypeList,
   a_exception_group       IN  number_arr,
   a_exception_group_name  IN  excepgroupList,
   a_trx_id1               IN  number_arr,
   a_trx_id2               IN  number_arr,
   a_customer_id           IN  number_arr,
   a_customer_name         IN  customerList,
   a_customer_site_id      IN  number_arr,
   a_customer_site_name    IN  custsiteList,
   a_customer_item_name IN  itemnameList,
   a_supplier_id           IN  number_arr,
   a_supplier_name         IN  supplierList,
   a_supplier_site_id      IN  number_arr,
   a_supplier_site_name    IN  suppsiteList,
   a_supplier_item_name    IN  itemnameList,
   a_number1               IN  number_arr,
   a_number2               IN  number_arr,
   a_number3               IN  number_arr,
   a_threshold             IN  number_arr,
   a_lead_time             IN  number_arr,
   a_item_min_qty          IN  number_arr,
   a_item_max_qty          IN  number_arr,
   a_order_number          IN  ordernumberList,
   a_release_number        IN  releasenumList,
   a_line_number           IN  linenumList,
   a_end_order_number      IN  ordernumberList,
   a_end_order_rel_number  IN  releasenumList,
   a_end_order_line_number IN  linenumList,
   a_creation_date         IN  date_arr,
   a_tp_creation_date      IN  date_arr,
   a_date1           	   IN  date_arr,
   a_date2        	   IN  date_arr,
   a_date3            	   IN  date_arr,
   a_date4		   IN  date_arr,
   a_date5		   IN  date_arr,
   a_exception_basis	   IN  exceptbasisList) IS

l_exist     Number := 0;
l_row       Number;
errors         Number;


BEGIN
--dbms_output.put_line('Populate exception data ' || a_company_id.COUNT);

IF a_company_id IS NOT NULL AND a_company_id.COUNT > 0 THEN
   FORALL i in 1..a_company_id.COUNT
     insert into msc_x_exception_details (
       exception_detail_id,
       exception_type,
       exception_type_name,
       exception_group,
       exception_group_name,
       date1,
       date2,
       date3,
       date4,
       date5,
       order_creation_date1,
       order_creation_date2,
       transaction_id1,
       transaction_id2,
       number1,
       number2,
       number3,
       threshold,
       lead_time,
       item_min_qty,
       item_max_qty,
       version,
       plan_id,
       sr_instance_id,
       company_id,
       company_name,
       company_site_id,
       company_site_name,
       inventory_item_id,
       item_name,
       item_description,
       last_update_date,
       last_updated_by,
       last_update_login,
       creation_date,
       created_by,
       customer_id,
       customer_name,
       customer_site_id,
       customer_site_name,
       customer_item_name,
       supplier_id,
       supplier_name,
       supplier_site_id,
       supplier_site_name,
       supplier_item_name,
       order_number,
       release_number,
       line_number,
       end_order_number,
       end_order_rel_number,
       end_order_line_number,
       exception_basis
     )
     values (
       msc_x_exception_details_s.nextval,
       a_exception_type(i),
       a_exception_type_name(i),
       a_exception_group(i),
       a_exception_group_name(i),
       trunc(a_date1(i)),
       trunc(a_date2(i)),
       trunc(a_date3(i)),
       trunc(a_date4(i)),
       trunc(a_date5(i)),
       trunc(a_creation_date(i)),
       trunc(a_tp_creation_date(i)),
       a_trx_id1(i),
       a_trx_id2(i),
       a_number1(i),
       a_number2(i),
       a_number3(i),
       a_threshold(i),
       a_lead_time(i),
       a_item_min_qty(i),
       a_item_max_qty(i),
       'CURRENT',
       G_PLAN_ID,
       G_SR_INSTANCE_ID,
       a_company_id(i),
       a_company_name(i),
       a_company_site_id(i),
       a_company_site_name(i),
       a_item_id(i),
       a_item_name(i),
       a_item_desc(i),
       sysdate,
       fnd_global.user_id,
       G_MAGIC_NUMBER,
       sysdate,
       fnd_global.user_id,
       a_customer_id(i),
       a_customer_name(i),
       a_customer_site_id(i),
       a_customer_site_name(i),
       a_customer_item_name(i),
       a_supplier_id(i),
       a_supplier_name(i),
       a_supplier_site_id(i),
       a_supplier_site_name(i),
       a_supplier_item_name(i),
       a_order_number(i),
       a_release_number(i),
       a_line_number(i),
       a_end_order_number(i),
       a_end_order_rel_number(i),
       a_end_order_line_number(i),
       a_exception_basis(i)
     );



 FOR i in 1..a_company_id.COUNT LOOP
      l_exist := does_exception_exist(a_company_id(i),
                                 a_company_site_id(i),
                                 a_item_id(i),
                                 a_exception_type(i),
                                a_exception_group(i));
      IF (l_exist = 1) THEN
               update   msc_item_exceptions
               set   exception_count = exception_count + 1,
               last_update_date = sysdate
               where    plan_id = G_PLAN_ID
               and   company_id = a_company_id(i)
               and   company_site_id = a_company_site_id(i)
               and   inventory_item_id = a_item_id(i)
               and   exception_type = a_exception_type(i)
               and   exception_group = a_exception_group(i)
            and   version = 0;


      ELSE
      insert into msc_item_exceptions( plan_id,
            sr_instance_id,
            company_id,
            company_site_id,
            organization_id,
            inventory_item_id,
            version,
            exception_type,
            exception_group,
            exception_count,
            last_update_date,
            last_updated_by,
            creation_date,
            created_by,
            last_update_login)
      values      (G_PLAN_ID,
            G_SR_INSTANCE_ID,
            a_company_id(i),
            a_company_site_id(i),
            -1,
            a_item_id(i),
            0,
            a_exception_type(i),
            a_exception_group(i),
            1,
            sysdate,
            -1,
            sysdate,
            -1,
            G_MAGIC_NUMBER
            );
      END IF;
 END LOOP;
END IF;

EXCEPTION
   when others then
   	--dbms_output.put_line('Error in Populate_exception_date ' || sqlerrm);
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.populate_exception_data');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      return;
END POPULATE_EXCEPTION_DATA;

----------------------------------------------------------------
--PROCEDURE ADD_TO_DELETE_TBL
--------------------------------------------------------------
PROCEDURE add_to_delete_tbl ( p_company_id in number,
            p_company_site_id in number,
            p_customer_id in number,
            p_customer_site_id in number,
            p_supplier_id in number,
            p_supplier_site_id in number,
            p_item_id   in number,
            p_group in number,
            p_type in number,
            p_trxid1 in number,
            p_trxid2 in number,
            p_date1 in date,
            p_date2 in date,
            t_company_list IN OUT NOCOPY number_arr,
            t_company_site_list IN OUT NOCOPY number_arr,
            t_customer_list IN OUT NOCOPY number_arr,
            t_customer_site_list IN OUT NOCOPY number_arr,
            t_supplier_list IN OUT NOCOPY number_arr,
            t_supplier_site_list IN OUT NOCOPY number_arr,
            t_item_list IN OUT NOCOPY number_arr,
            t_group_list IN OUT NOCOPY number_arr,
            t_type_list IN OUT NOCOPY number_arr,
            t_trxid1_list IN OUT NOCOPY number_arr,
            t_trxid2_list IN OUT NOCOPY number_arr,
            t_date1_list IN OUT NOCOPY date_arr,
            t_date2_list IN OUT NOCOPY date_arr) IS


l_counter Number := 0;

BEGIN

--FND_FILE.PUT_LINE(FND_FILE.LOG, 'Add to plsql table list');
--dbms_output.put_line('Add to plsql delete table list');

   t_item_list.EXTEND;
   t_company_list.EXTEND;
   t_company_site_list.EXTEND;
   t_customer_list.EXTEND;
   t_customer_site_list.EXTEND;
   t_supplier_list.EXTEND;
   t_supplier_site_list.EXTEND;
   t_group_list.EXTEND;
   t_type_list.EXTEND;
   t_trxid1_list.EXTEND;
   t_trxid2_list.EXTEND;
   t_date1_list.EXTEND;
   t_date2_list.EXTEND;

--FND_FILE.PUT_LINE(FND_FILE.LOG, 'Count ' || t_item_list.COUNT);
--   dbms_output.put_line('Count ' || t_item_list.COUNT);

   t_item_list(t_item_list.COUNT) := p_item_id;
   t_company_list(t_item_list.COUNT) := p_company_id;
   t_company_site_list(t_item_list.COUNT) := p_company_site_id;
   t_customer_list(t_item_list.COUNT) := p_customer_id;
   t_customer_site_list(t_item_list.COUNT) := p_customer_site_id;
   t_supplier_list(t_item_list.COUNT) := p_supplier_id;
   t_supplier_site_list(t_item_list.COUNT) := p_supplier_site_id;
   t_group_list(t_item_list.COUNT) := p_group;
   t_type_list(t_item_list.COUNT) := p_type;
   t_trxid1_list(t_item_list.COUNT) := p_trxid1;
   t_trxid2_list(t_item_list.COUNT) := p_trxid2;
   t_date1_list(t_item_list.COUNT) := p_date1;
   t_date2_list(t_item_list.COUNT) := p_date2;

EXCEPTION
   WHEN others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.add_to_delete_tbl');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      --dbms_output.put_line('add_to_delete_tbl error ' || sqlerrm);
      return;
END add_to_delete_tbl;

--------------------------------------------------------------------
--archive_exception
--------------------------------------------------------------------

PROCEDURE archive_exception (t_company_list In number_arr,
         t_company_site_list in number_arr,
         t_customer_list in number_arr,
         t_customer_site_list in number_arr,
         t_supplier_list in number_arr,
         t_supplier_site_list in number_arr,
         t_item_list In number_arr,
         t_group_list in number_arr,
         t_type_list in number_arr,
         t_trxid1_list in number_arr,
         t_trxid2_list in number_arr,
         t_date1_list in date_arr,
         t_date2_list in date_arr) IS


l_row       number:= 0;
l_item_type       Varchar2(20) := 'MSCSNDNT';
l_item_key     Varchar2(100) := null;
i        Number;
t_count1    number_arr  := number_arr();
t_count2    number_arr  := number_arr();
t_count3    number_arr  := number_arr();

BEGIN

--FND_FILE.PUT_LINE(FND_FILE.LOG, 'Delete in batch:' || t_item_list.COUNT);
--dbms_output.put_line('Delete batch ' || t_item_list.COUNT);

  IF (t_item_list is not null and t_item_list.COUNT > 0) THEN

   --======================================================================
   -- archive the order execution exceptions
   --======================================================================
         FORALL i in 1..t_item_list.COUNT
         delete msc_x_exception_details
         where inventory_item_id = t_item_list(i)
         and   company_id = t_company_list(i)
         and   company_site_id = t_company_site_list(i)
         and   nvl(customer_id,-1) = nvl(t_customer_list(i),-1)
         and   nvl(customer_site_id,-1) = nvl(t_customer_site_list(i),-1)
         and   nvl(supplier_id,-1) = nvl(t_supplier_list(i),-1)
         and   nvl(supplier_site_id ,-1) = nvl(t_supplier_site_list(i),-1)
         and   exception_group = t_group_list(i)
         and   exception_type = t_type_list(i)
      and   transaction_id1 = t_trxid1_list(i)
      and   nvl(transaction_id2,-1) = nvl(t_trxid2_list(i),-1)
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER
      and   nvl(LAST_UPDATE_LOGIN,0) <> -99;
      --checking the key in case the record is not to be deleted.This is updated only for cursor exception_34.


         FOR i in 1..t_item_list.COUNT LOOP
             t_count1.EXTEND;
             t_count1(t_count1.COUNT) := SQL%BULK_ROWCOUNT(i);
     --dbms_output.put_line('delete trx ' || t_trxid1_list(i) || '-' || t_count1(i) || ' Comp ' || t_company_list(i) || t_company_site_list(i) );
     --dbms_output.put_line('item ' || t_item_list(i) ||  ' Cust ' || t_customer_list(i) || t_customer_site_list(i) );
          --dbms_output.put_line(' supp ' || t_supplier_list(i) || t_supplier_site_list(i) );
            --FND_FILE.PUT_LINE(FND_FILE.LOG,'delete trx ' || t_trxid1_list(i) || '-' || t_count1(i));
         END LOOP;

   FORALL   i in 1..t_item_list.COUNT
            update msc_item_exceptions ex
            set      ex.exception_count = ex.exception_count - t_count1(i),
               ex.last_update_date = sysdate
            where    ex.plan_id = G_PLAN_ID
            and   ex.company_id = t_company_list(i)
            and      ex.company_site_id = t_company_site_list(i)
            and      ex.inventory_item_id = t_item_list(i)
            and   ex.exception_group = t_group_list(i)
            and      ex.exception_type = t_type_list(i)
            and      ex.version = 0
            and      nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

   --===============================================================
   -- archive bucket data with date range
   --===============================================================
         FORALL i in 1..t_item_list.COUNT
         delete msc_x_exception_details
         where inventory_item_id = t_item_list(i)
         and   company_id = t_company_list(i)
         and   company_site_id = t_company_site_list(i)
         and   nvl(customer_id,-1) = nvl(t_customer_list(i),-1)
         and   nvl(customer_site_id,-1) = nvl(t_customer_site_list(i),-1)
         and   nvl(supplier_id,-1) = nvl(t_supplier_list(i),-1)
         and   nvl(supplier_site_id ,-1) = nvl(t_supplier_site_list(i),-1)
         and   exception_group = t_group_list(i)
         and   exception_type = t_type_list(i)
      and   transaction_id1 is null
      and   transaction_id2 is null
         and   t_date1_list(i) is not null
         and   t_date2_list(i) is not null
      and   date1 = t_date1_list(i)
      and   date2 = t_date2_list(i)
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

         FOR i in 1..t_item_list.COUNT LOOP
             t_count2.EXTEND;
             t_count2(t_count2.COUNT) := SQL%BULK_ROWCOUNT(i);
          --FND_FILE.PUT_LINE(FND_FILE.LOG,'delete date ' || t_date1_list(i) || '-' || t_count2(i));
         END LOOP;

   FORALL   i in 1..t_item_list.COUNT
            update msc_item_exceptions ex
            set      ex.exception_count = ex.exception_count - t_count2(i),
               ex.last_update_date = sysdate
            where    ex.plan_id = G_PLAN_ID
            and   ex.company_id = t_company_list(i)
            and      ex.company_site_id = t_company_site_list(i)
            and      ex.inventory_item_id = t_item_list(i)
            and   ex.exception_group = t_group_list(i)
            and      ex.exception_type = t_type_list(i)
            and      ex.version = 0
            and      nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

   --===============================================================
   -- archive bucket data without date range
   --===============================================================
         FORALL i in 1..t_item_list.COUNT
         delete msc_x_exception_details
         where inventory_item_id = t_item_list(i)
         and   company_id = t_company_list(i)
         and   company_site_id = t_company_site_list(i)
         and   nvl(customer_id,-1) = nvl(t_customer_list(i),-1)
         and   nvl(customer_site_id,-1) = nvl(t_customer_site_list(i),-1)
         and   nvl(supplier_id,-1) = nvl(t_supplier_list(i),-1)
         and   nvl(supplier_site_id ,-1) = nvl(t_supplier_site_list(i),-1)
         and   exception_group = t_group_list(i)
         and   exception_type = t_type_list(i)
         and   transaction_id1 is null
         and   transaction_id2 is null
         and   t_date1_list(i) is null
         and   t_date2_list(i) is null
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

         FOR i in 1..t_item_list.COUNT LOOP
             t_count3.EXTEND;
             t_count3(t_count3.COUNT) := SQL%BULK_ROWCOUNT(i);
          --FND_FILE.PUT_LINE(FND_FILE.LOG,'delete date ' || t_type_list(i) || '-' || t_count3(i));
         END LOOP;

   FORALL   i in 1..t_item_list.COUNT
            update msc_item_exceptions ex
            set      ex.exception_count = ex.exception_count - t_count3(i),
               ex.last_update_date = sysdate
            where    ex.plan_id = G_PLAN_ID
            and   ex.company_id = t_company_list(i)
            and      ex.company_site_id = t_company_site_list(i)
            and      ex.inventory_item_id = t_item_list(i)
            and   ex.exception_group = t_group_list(i)
            and      ex.exception_type = t_type_list(i)
            and      ex.version = 0
            and      nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

--======================================================================
   -- archive the potential late order  exceptions
   --======================================================================
         FORALL i in 1..t_item_list.COUNT
         delete msc_x_exception_details
         where inventory_item_id = t_item_list(i)
         and   company_id = t_company_list(i)
         and   company_site_id = t_company_site_list(i)
         and   nvl(customer_id,-1) = nvl(t_customer_list(i),-1)
         and   nvl(customer_site_id,-1) = nvl(t_customer_site_list(i),-1)
         and   nvl(supplier_id,-1) = nvl(t_supplier_list(i),-1)
         and   nvl(supplier_site_id ,-1) = nvl(t_supplier_site_list(i),-1)
         and   exception_group = msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER
         and   exception_type = msc_x_netting_pkg.G_EXCEP13
      and   transaction_id1 = t_trxid1_list(i)
      and   nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

         FOR i in 1..t_item_list.COUNT LOOP
             t_count1.EXTEND;
             t_count1(t_count1.COUNT) := SQL%BULK_ROWCOUNT(i);
            --FND_FILE.PUT_LINE(FND_FILE.LOG,'delete trx ex: ' || t_trxid1_list(i) || '-' || t_count1(i) || '-' || t_type_list(i));
--dbms_output.put_line('delete trx ex: ' || t_trxid1_list(i) || '-' || t_count1(i) || '-' || t_type_list(i));
         END LOOP;

   FORALL   i in 1..t_item_list.COUNT
            update msc_item_exceptions ex
            set      ex.exception_count = ex.exception_count - t_count1(i),
               ex.last_update_date = sysdate
            where    ex.plan_id = G_PLAN_ID
            and   ex.company_id = t_company_list(i)
            and      ex.company_site_id = t_company_site_list(i)
            and      ex.inventory_item_id = msc_x_netting_pkg.G_POTENTIAL_LATE_ORDER
            and   ex.exception_group = msc_x_netting_pkg.G_EXCEP13
            and      ex.exception_type = t_type_list(i)
            and      ex.version = 0
            and      nvl(last_update_login,-1) <> G_MAGIC_NUMBER;

   --===================================================================
   -- clean up the old workflow notification
   --=====================================================================
          FOR i in t_item_list.FIRST..t_item_list.LAST LOOP

         l_item_key := to_char(t_group_list(i)) || '-' ||
            to_char(t_type_list(i)) || '-' ||
            to_char(t_item_list(i)) || '-' ||
            to_char(t_company_list(i)) || '-' ||
            to_char(t_company_site_list(i)) || '-' ||
            to_char(t_customer_list(i)) || '-' ||
            to_char(t_customer_site_list(i)) || '-' ||
            to_char(t_supplier_list(i)) || '-' ||
            to_char(t_supplier_site_list(i)) || '%';

      delete_wf_notification(l_item_type, l_item_key);
   END LOOP;
  END IF;



--dbms_output.put_line('Done with delete ');


EXCEPTION
   when others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.archive_exception');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      return;
END archive_exception;

------------------------------------------------------------------------
--update item desc, customer item name, supplier item name
--------------------------------------------------------------------

PROCEDURE update_item (p_refresh_number in Number) IS

cursor update_item_c1 IS
select distinct publisher_id,
	publisher_site_id,
	customer_id,
	customer_site_id,
	inventory_item_id,
	item_name,
	item_description,
	customer_item_name,
	supplier_item_name
from  msc_sup_dem_entries  sd
where plan_id = -1
and publisher_order_type in (3,14)
and last_refresh_number > p_refresh_number
and exists (select 1
        from msc_x_exception_details
         where plan_id = -1
           and inventory_item_id = sd.inventory_item_id
           and  exception_type in (5,25)
           and company_id = sd.publisher_id
           and company_site_id = sd.publisher_site_id
           and customer_id = sd.customer_id
           and customer_site_id = sd.customer_site_id)
union all
select distinct supplier_id,
	supplier_site_id,
	publisher_id,
	publisher_site_id,
	inventory_item_id,
	item_name,
	item_description,
	customer_item_name,
	supplier_item_name
from  msc_sup_dem_entries  sd
where plan_id = -1
and publisher_order_type = 2
and last_refresh_number > p_refresh_number
and exists (select 1
        from msc_x_exception_details
         where plan_id = -1
           and inventory_item_id = sd.inventory_item_id
           and  exception_type in (5,25)
           and company_id = sd.supplier_id
           and company_site_id = sd.supplier_site_id
           and customer_id = sd.publisher_id
           and customer_site_id = sd.publisher_site_id);

cursor update_item_c2 IS
select distinct publisher_id,
	publisher_site_id,
	supplier_id,
	supplier_site_id,
	inventory_item_id,
	item_name,
	item_description,
	customer_item_name,
	supplier_item_name
from  msc_sup_dem_entries  sd
where plan_id = -1
and publisher_order_type = 2
and last_refresh_number > p_refresh_number
and exists (select 1
        from msc_x_exception_details
         where plan_id = -1
           and inventory_item_id = sd.inventory_item_id
           and  exception_type in (6,26)
           and company_id = sd.publisher_id
           and company_site_id = sd.publisher_site_id
           and supplier_id = sd.supplier_id
           and supplier_site_id = sd.supplier_site_id)
union all
select distinct customer_id,
	customer_site_id,
	publisher_id,
	publisher_site_id,
	inventory_item_id,
	item_name,
	item_description,
	customer_item_name,
	supplier_item_name
from  msc_sup_dem_entries  sd
where plan_id = -1
and publisher_order_type in (3,14)
and last_refresh_number > p_refresh_number
and exists (select 1
        from msc_x_exception_details
         where plan_id = -1
           and inventory_item_id = sd.inventory_item_id
           and  exception_type in (6,26)
           and company_id = sd.customer_id
           and company_site_id = sd.customer_site_id
           and supplier_id = sd.publisher_id
           and supplier_site_id = sd.publisher_site_id);

  b_publisher_id         	msc_x_netting_pkg.number_arr;
  b_publisher_site_id    	msc_x_netting_pkg.number_arr;
  b_supplier_id         	msc_x_netting_pkg.number_arr;
  b_supplier_site_id    	msc_x_netting_pkg.number_arr;
  b_customer_id         	msc_x_netting_pkg.number_arr;
  b_customer_site_id    	msc_x_netting_pkg.number_arr;
  b_item_id			msc_x_netting_pkg.number_arr;
  b_item_name        		msc_x_netting_pkg.itemnameList;
  b_item_desc        		msc_x_netting_pkg.itemdescList;
  b_customer_item_name     	msc_x_netting_pkg.itemnameList;
  b_supplier_item_name     	msc_x_netting_pkg.itemnameList;


BEGIN

open update_item_c1;
fetch update_item_c1 bulk collect into
	b_publisher_id,
	b_publisher_site_id,
	b_customer_id,
	b_customer_site_id,
	b_item_id,
	b_item_name,
	b_item_desc,
	b_customer_item_name,
	b_supplier_item_name;
close update_item_c1;
--dbms_output.put_line('Count of 5-25 ' || b_publisher_id.COUNT);
IF (b_publisher_id is not null and b_publisher_id.COUNT > 0) THEN
   FORALL j in 1..b_publisher_id.COUNT

	update msc_x_exception_details
	set item_name = b_item_name(j),
		item_description = b_item_desc(j),
		customer_item_name = b_customer_item_name(j),
		supplier_item_name = b_supplier_item_name(j)
	where plan_id = -1
	and company_id = b_publisher_id(j)
	and company_site_id = b_publisher_site_id(j)
	and customer_id = b_customer_id(j)
	and customer_site_id = b_customer_site_id(j)
	and inventory_item_id = b_item_id(j)
	and exception_type in (5,25);
END IF;

open update_item_c2;
fetch update_item_c2 bulk collect into
	b_publisher_id,
	b_publisher_site_id,
	b_supplier_id,
	b_supplier_site_id,
	b_item_id,
	b_item_name,
	b_item_desc,
	b_customer_item_name,
	b_supplier_item_name;
close update_item_c2;
--dbms_output.put_line('Count ' || b_publisher_id.COUNT);
IF (b_publisher_id is not null and b_publisher_id.COUNT > 0) THEN
   FORALL j in 1..b_publisher_id.COUNT

	update msc_x_exception_details
	set item_name = b_item_name(j),
		item_description = b_item_desc(j),
		customer_item_name = b_customer_item_name(j),
		supplier_item_name = b_supplier_item_name(j)
	where plan_id = -1
	and company_id = b_publisher_id(j)
	and company_site_id = b_publisher_site_id(j)
	and supplier_id = b_supplier_id(j)
	and supplier_site_id = b_supplier_site_id(j)
	and inventory_item_id = b_item_id(j)
	and exception_type in (6,26);
END IF;



EXCEPTION
   when others then
      MSC_SCE_LOADS_PKG.LOG_MESSAGE('Error in MSC_X_NETTING_PKG.update_item');
      MSC_SCE_LOADS_PKG.LOG_MESSAGE(SQLERRM);
      --dbms_output.put_line('Error in update item');
      return;
END UPDATE_ITEM;

END MSC_X_NETTING_PKG;


/
