--------------------------------------------------------
--  DDL for Package Body CS_AUDIT_UPGRADE_CON_PRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_AUDIT_UPGRADE_CON_PRG" AS
/* $Header: csxaucpb.pls 120.8 2005/07/26 13:06:13 appldev ship $ */

PROCEDURE Perform_Audit_Upgrade
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2,
   p_audit_date            IN   VARCHAR2,
   p_total_workers         IN   NUMBER
   --x_batch_size      IN  NUMBER,
   --x_num_workers     IN  NUMBER
  ) IS
BEGIN
  -- Parent Processing
  AD_CONC_UTILS_PKG.submit_subrequests
    (x_errbuf     => x_errbuf,
     x_retcode    => x_retcode,
     x_workerconc_app_shortname  => 'CS', --l_product,
     x_workerconc_progname => 'CSVAWUPG',
     x_batch_size           => 1000,
     x_num_workers          => 3,
     x_argument4            => p_audit_date,
     x_argument5            =>  to_char(sysdate, 'yymmddhh24miss') -- to ensure re-runnable
    );
END Perform_Audit_Upgrade;

-- Procedure for Worker Concurrent Program
PROCEDURE Worker_Audit_Upgrade
  (x_errbuf     OUT NOCOPY VARCHAR2,
   x_retcode    OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_worker_id   IN NUMBER,
   x_num_workers IN NUMBER,
   p_audit_date  IN VARCHAR2,
   p_update_date IN VARCHAR2
  ) IS

-- Variables Declared for the API

   l_loop_counter    NUMBER;
   l_create_record   VARCHAR2(1);

CURSOR c_sr_current(c_start_rowid ROWID, c_end_rowid ROWID, p_audit_date DATE) IS
SELECT
  INCIDENT_ID        ,
  INCIDENT_NUMBER   ,
  LAST_UPDATE_DATE   ,
  LAST_UPDATED_BY   ,
  CREATION_DATE   ,
  CREATED_BY     ,
  CREATION_TIME   ,
  LAST_UPDATE_LOGIN ,
  INCIDENT_STATUS_ID  ,
  to_number(NULL) OLD_INCIDENT_STATUS_ID ,
  'N' CHANGE_INCIDENT_STATUS_FLAG ,
  INCIDENT_TYPE_ID           ,
  to_number(NULL) OLD_INCIDENT_TYPE_ID      ,
  'N' CHANGE_INCIDENT_TYPE_FLAG ,
  INCIDENT_URGENCY_ID      ,
  to_number(NULL) OLD_INCIDENT_URGENCY_ID ,
  'N' CHANGE_INCIDENT_URGENCY_FLAG ,
  INCIDENT_SEVERITY_ID        ,
  to_number(NULL) OLD_INCIDENT_SEVERITY_ID   ,
  'N' CHANGE_INCIDENT_SEVERITY_FLAG,
  RESPONSIBLE_GROUP_ID        ,
  to_number(NULL) OLD_RESPONSIBLE_GROUP_ID   ,
  'N' CHANGE_RESPONSIBLE_GROUP_FLAG ,
  INCIDENT_OWNER_ID            ,
  to_number(NULL) OLD_INCIDENT_OWNER_ID       ,
  'N' CHANGE_INCIDENT_OWNER_FLAG ,
  EXPECTED_RESOLUTION_DATE,
  TO_DATE(NULL) OLD_EXPECTED_RESOLUTION_DATE  ,
  'N' CHANGE_RESOLUTION_FLAG       ,
  OWNER_GROUP_ID GROUP_ID         ,
  to_number(NULL) OLD_GROUP_ID        ,
  'N' CHANGE_GROUP_FLAG  ,
  OBLIGATION_DATE   ,
  TO_DATE(NULL) OLD_OBLIGATION_DATE ,
  'N' CHANGE_OBLIGATION_FLAG    ,
  SITE_ID                  ,
  to_number(NULL) OLD_SITE_ID             ,
  'N' CHANGE_SITE_FLAG       ,
  BILL_TO_CONTACT_ID    ,
  to_number(NULL) OLD_BILL_TO_CONTACT_ID  ,
  'N' CHANGE_BILL_TO_FLAG    ,
  SHIP_TO_CONTACT_ID    ,
  to_number(NULL) OLD_SHIP_TO_CONTACT_ID ,
  'N' CHANGE_SHIP_TO_FLAG   ,
  INCIDENT_DATE        ,
  TO_DATE(NULL) OLD_INCIDENT_DATE   ,
  'N' CHANGE_INCIDENT_DATE_FLAG  ,
  CLOSE_DATE                ,
  to_date(NULL) OLD_CLOSE_DATE           ,
  'N' CHANGE_CLOSE_DATE_FLAG  ,
  CUSTOMER_PRODUCT_ID    ,
  to_number(NULL) OLD_CUSTOMER_PRODUCT_ID ,
  'N' CHANGE_CUSTOMER_PRODUCT_FLAG        ,
  PLATFORM_ID                      ,
  to_number(NULL) OLD_PLATFORM_ID                 ,
  'N' CHANGE_PLATFORM_ID_FLAG        ,
  PLATFORM_VERSION_ID           ,
  to_number(NULL) OLD_PLATFORM_VERSION_ID      ,
  'N' CHANGE_PLAT_VER_ID_FLAG     ,
  CP_COMPONENT_ID            ,
  to_number(NULL) OLD_CP_COMPONENT_ID       ,
  'N' CHANGE_CP_COMPONENT_ID_FLAG ,
  CP_COMPONENT_VERSION_ID    ,
  to_number(NULL) OLD_CP_COMPONENT_VERSION_ID,
  'N' CHANGE_CP_COMP_VER_ID_FLAG ,
  CP_SUBCOMPONENT_ID         ,
  to_number(NULL) OLD_CP_SUBCOMPONENT_ID    ,
  'N' CHANGE_CP_SUBCOMPONENT_ID_FLAG ,
  CP_SUBCOMPONENT_VERSION_ID    ,
  to_number(NULL) OLD_CP_SUBCOMPONENT_VERSION_ID ,
  'N' CHANGE_CP_SUBCOMP_VER_ID_FLAG ,
  LANGUAGE_ID                  ,
  to_number(NULL) OLD_LANGUAGE_ID             ,
  'N' CHANGE_LANGUAGE_ID_FLAG   ,
  TERRITORY_ID             ,
  to_number(NULL) OLD_TERRITORY_ID          ,
  'N' CHANGE_TERRITORY_ID_FLAG ,
  CP_REVISION_ID          ,
  to_number(NULL) OLD_CP_REVISION_ID     ,
  'N' CHANGE_CP_REVISION_ID_FLAG ,
  INV_ITEM_REVISION         ,
  to_char(NULL) OLD_INV_ITEM_REVISION    ,
  'N' CHANGE_INV_ITEM_REVISION,
  INV_COMPONENT_ID       ,
  to_number(NULL) OLD_INV_COMPONENT_ID  ,
  'N' CHANGE_INV_COMPONENT_ID   ,
  INV_COMPONENT_VERSION    ,
  to_char(NULL) OLD_INV_COMPONENT_VERSION  ,
  'N' CHANGE_INV_COMPONENT_VERSION  ,
  INV_SUBCOMPONENT_ID          ,
  to_number(NULL) OLD_INV_SUBCOMPONENT_ID     ,
  'N' CHANGE_INV_SUBCOMPONENT_ID ,
  INV_SUBCOMPONENT_VERSION  ,
  to_char(NULL) OLD_INV_SUBCOMPONENT_VERSION  ,
  'N' CHANGE_INV_SUBCOMP_VERSION   ,
  RESOURCE_TYPE               ,
  to_char(NULL) OLD_RESOURCE_TYPE          ,
  'N'  CHANGE_RESOURCE_TYPE_FLAG ,
  to_char(NULL) OLD_GROUP_TYPE              ,
  GROUP_TYPE                 ,
  'N' CHANGE_GROUP_TYPE_FLAG    ,
  to_date(NULL) OLD_OWNER_ASSIGNED_TIME  ,
  OWNER_ASSIGNED_TIME        ,
  'N' CHANGE_ASSIGNED_TIME_FLAG          ,
  INV_PLATFORM_ORG_ID               ,
  to_number(NULL) OLD_INV_PLATFORM_ORG_ID          ,
  'N' CHANGE_PLATFORM_ORG_ID_FLAG     ,
  COMPONENT_VERSION              ,
  to_char(NULL) OLD_COMPONENT_VERSION         ,
  'N' CHANGE_COMP_VER_FLAG         ,
  SUBCOMPONENT_VERSION        ,
  to_char(NULL) OLD_SUBCOMPONENT_VERSION   ,
  'N' CHANGE_SUBCOMP_VER_FLAG   ,
  PRODUCT_REVISION                   ,
  to_char(NULL) OLD_PRODUCT_REVISION              ,
  'N' CHANGE_PRODUCT_REVISION_FLAG     ,
  INVENTORY_ITEM_ID               ,
  to_number(NULL) OLD_INVENTORY_ITEM_ID          ,
  'N' CHANGE_INVENTORY_ITEM_FLAG    ,
  INV_ORGANIZATION_ID          ,
  to_number(NULL) OLD_INV_ORGANIZATION_ID     ,
  'N' CHANGE_INV_ORGANIZATION_FLAG   ,
  STATUS_FLAG                   ,
  to_char(NULL) OLD_STATUS_FLAG              ,
  'N' CHANGE_STATUS_FLAG          ,
  PRIMARY_CONTACT_ID         ,
  'N' CHANGE_PRIMARY_CONTACT_FLAG  ,
  to_number(NULL) OLD_PRIMARY_CONTACT_ID     ,
  SECURITY_GROUP_ID
FROM CS_INCIDENTS_ALL_B
WHERE ROWID BETWEEN c_start_rowid AND c_end_rowid
AND   creation_date > p_audit_date;

CURSOR c_sr_audit(c_incident_id number) IS
SELECT
  INCIDENT_ID        ,
  INCIDENT_AUDIT_ID,
  LAST_UPDATE_DATE   ,
  LAST_UPDATED_BY   ,
  CREATION_DATE   ,
  CREATED_BY     ,
  LAST_UPDATE_LOGIN ,
  CREATION_TIME    ,
  INCIDENT_STATUS_ID  ,
  OLD_INCIDENT_STATUS_ID ,
  CHANGE_INCIDENT_STATUS_FLAG ,
  INCIDENT_TYPE_ID           ,
  OLD_INCIDENT_TYPE_ID      ,
  CHANGE_INCIDENT_TYPE_FLAG ,
  INCIDENT_URGENCY_ID      ,
  OLD_INCIDENT_URGENCY_ID ,
  CHANGE_INCIDENT_URGENCY_FLAG ,
  INCIDENT_SEVERITY_ID        ,
  OLD_INCIDENT_SEVERITY_ID   ,
  CHANGE_INCIDENT_SEVERITY_FLAG,
  RESPONSIBLE_GROUP_ID        ,
  OLD_RESPONSIBLE_GROUP_ID   ,
  CHANGE_RESPONSIBLE_GROUP_FLAG ,
  INCIDENT_OWNER_ID            ,
  OLD_INCIDENT_OWNER_ID       ,
  CHANGE_INCIDENT_OWNER_FLAG ,
  CREATE_MANUAL_ACTION      ,
  ACTION_ID                ,
  EXPECTED_RESOLUTION_DATE,
  OLD_EXPECTED_RESOLUTION_DATE  ,
  CHANGE_RESOLUTION_FLAG       ,
  GROUP_ID              ,
  OLD_GROUP_ID        ,
  CHANGE_GROUP_FLAG  ,
  OBLIGATION_DATE   ,
  OLD_OBLIGATION_DATE ,
  CHANGE_OBLIGATION_FLAG    ,
  SITE_ID                  ,
  OLD_SITE_ID             ,
  CHANGE_SITE_FLAG       ,
  BILL_TO_CONTACT_ID    ,
  OLD_BILL_TO_CONTACT_ID  ,
  CHANGE_BILL_TO_FLAG    ,
  SHIP_TO_CONTACT_ID    ,
  OLD_SHIP_TO_CONTACT_ID ,
  CHANGE_SHIP_TO_FLAG   ,
  INCIDENT_DATE        ,
  OLD_INCIDENT_DATE   ,
  CHANGE_INCIDENT_DATE_FLAG  ,
  CLOSE_DATE                ,
  OLD_CLOSE_DATE           ,
  CHANGE_CLOSE_DATE_FLAG  ,
  CUSTOMER_PRODUCT_ID    ,
  OLD_CUSTOMER_PRODUCT_ID ,
  CHANGE_CUSTOMER_PRODUCT_FLAG        ,
  AUDIT_FIELD                        ,
  OBJECT_VERSION_NUMBER             ,
  PLATFORM_ID                      ,
  OLD_PLATFORM_ID                 ,
  CHANGE_PLATFORM_ID_FLAG        ,
  PLATFORM_VERSION_ID           ,
  OLD_PLATFORM_VERSION_ID      ,
  CHANGE_PLAT_VER_ID_FLAG     ,
  CP_COMPONENT_ID            ,
  OLD_CP_COMPONENT_ID       ,
  CHANGE_CP_COMPONENT_ID_FLAG ,
  CP_COMPONENT_VERSION_ID    ,
  OLD_CP_COMPONENT_VERSION_ID,
  CHANGE_CP_COMP_VER_ID_FLAG ,
  CP_SUBCOMPONENT_ID         ,
  OLD_CP_SUBCOMPONENT_ID    ,
  CHANGE_CP_SUBCOMPONENT_ID_FLAG ,
  CP_SUBCOMPONENT_VERSION_ID    ,
  OLD_CP_SUBCOMPONENT_VERSION_ID ,
  CHANGE_CP_SUBCOMP_VER_ID_FLAG ,
  LANGUAGE_ID                  ,
  OLD_LANGUAGE_ID             ,
  CHANGE_LANGUAGE_ID_FLAG   ,
  TERRITORY_ID             ,
  OLD_TERRITORY_ID          ,
  CHANGE_TERRITORY_ID_FLAG ,
  CP_REVISION_ID          ,
  OLD_CP_REVISION_ID     ,
  CHANGE_CP_REVISION_ID_FLAG ,
  INV_ITEM_REVISION         ,
  OLD_INV_ITEM_REVISION    ,
  CHANGE_INV_ITEM_REVISION,
  INV_COMPONENT_ID       ,
  OLD_INV_COMPONENT_ID  ,
  CHANGE_INV_COMPONENT_ID   ,
  INV_COMPONENT_VERSION    ,
  OLD_INV_COMPONENT_VERSION  ,
  CHANGE_INV_COMPONENT_VERSION  ,
  INV_SUBCOMPONENT_ID          ,
  OLD_INV_SUBCOMPONENT_ID     ,
  CHANGE_INV_SUBCOMPONENT_ID ,
  INV_SUBCOMPONENT_VERSION  ,
  OLD_INV_SUBCOMPONENT_VERSION  ,
  CHANGE_INV_SUBCOMP_VERSION   ,
  RESOURCE_TYPE               ,
  OLD_RESOURCE_TYPE          ,
  CHANGE_RESOURCE_TYPE_FLAG ,
  OLD_GROUP_TYPE              ,
  GROUP_TYPE                 ,
  CHANGE_GROUP_TYPE_FLAG    ,
  OLD_OWNER_ASSIGNED_TIME  ,
  OWNER_ASSIGNED_TIME   ,
  CHANGE_ASSIGNED_TIME_FLAG          ,
  INV_PLATFORM_ORG_ID               ,
  OLD_INV_PLATFORM_ORG_ID          ,
  CHANGE_PLATFORM_ORG_ID_FLAG     ,
  COMPONENT_VERSION              ,
  OLD_COMPONENT_VERSION         ,
  CHANGE_COMP_VER_FLAG         ,
  SUBCOMPONENT_VERSION        ,
  OLD_SUBCOMPONENT_VERSION   ,
  CHANGE_SUBCOMP_VER_FLAG   ,
  PRODUCT_REVISION                   ,
  OLD_PRODUCT_REVISION              ,
  CHANGE_PRODUCT_REVISION_FLAG     ,
  INVENTORY_ITEM_ID               ,
  OLD_INVENTORY_ITEM_ID          ,
  CHANGE_INVENTORY_ITEM_FLAG    ,
  INV_ORGANIZATION_ID          ,
  OLD_INV_ORGANIZATION_ID     ,
  CHANGE_INV_ORGANIZATION_FLAG   ,
  STATUS_FLAG                   ,
  OLD_STATUS_FLAG              ,
  CHANGE_STATUS_FLAG          ,
  PRIMARY_CONTACT_ID         ,
  CHANGE_PRIMARY_CONTACT_FLAG  ,
  OLD_PRIMARY_CONTACT_ID      ,
  SECURITY_GROUP_ID
FROM cs_incidents_audit_b
WHERE INCIDENT_ID = c_incident_id
AND   NVL(UPGRADE_FLAG_FOR_CREATE,'N') = 'N'
AND   NVL(updated_entity_code, 'SR_HEADER') = 'SR_HEADER'
ORDER BY creation_date desc, incident_audit_id desc;

CURSOR c_sr_audit_asc(c_incident_id number) IS
SELECT
  INCIDENT_ID        ,
  INCIDENT_AUDIT_ID           ,
  LAST_UPDATE_DATE   ,
  LAST_UPDATED_BY   ,
  CREATION_DATE   ,
  CREATED_BY     ,
  LAST_UPDATE_LOGIN ,
  CREATION_TIME    ,
  INCIDENT_STATUS_ID  ,
  OLD_INCIDENT_STATUS_ID ,
  CHANGE_INCIDENT_STATUS_FLAG ,
  INCIDENT_TYPE_ID           ,
  OLD_INCIDENT_TYPE_ID      ,
  CHANGE_INCIDENT_TYPE_FLAG ,
  INCIDENT_URGENCY_ID      ,
  OLD_INCIDENT_URGENCY_ID ,
  CHANGE_INCIDENT_URGENCY_FLAG ,
  INCIDENT_SEVERITY_ID        ,
  OLD_INCIDENT_SEVERITY_ID   ,
  CHANGE_INCIDENT_SEVERITY_FLAG,
  RESPONSIBLE_GROUP_ID        ,
  OLD_RESPONSIBLE_GROUP_ID   ,
  CHANGE_RESPONSIBLE_GROUP_FLAG ,
  INCIDENT_OWNER_ID            ,
  OLD_INCIDENT_OWNER_ID       ,
  CHANGE_INCIDENT_OWNER_FLAG ,
  CREATE_MANUAL_ACTION      ,
  ACTION_ID                ,
  EXPECTED_RESOLUTION_DATE,
  OLD_EXPECTED_RESOLUTION_DATE  ,
  CHANGE_RESOLUTION_FLAG       ,
  GROUP_ID              ,
  OLD_GROUP_ID        ,
  CHANGE_GROUP_FLAG  ,
  OBLIGATION_DATE   ,
  OLD_OBLIGATION_DATE ,
  CHANGE_OBLIGATION_FLAG    ,
  SITE_ID                  ,
  OLD_SITE_ID             ,
  CHANGE_SITE_FLAG       ,
  BILL_TO_CONTACT_ID    ,
  OLD_BILL_TO_CONTACT_ID  ,
  CHANGE_BILL_TO_FLAG    ,
  SHIP_TO_CONTACT_ID    ,
  OLD_SHIP_TO_CONTACT_ID ,
  CHANGE_SHIP_TO_FLAG   ,
  INCIDENT_DATE        ,
  OLD_INCIDENT_DATE   ,
  CHANGE_INCIDENT_DATE_FLAG  ,
  CLOSE_DATE                ,
  OLD_CLOSE_DATE           ,
  CHANGE_CLOSE_DATE_FLAG  ,
  CUSTOMER_PRODUCT_ID    ,
  OLD_CUSTOMER_PRODUCT_ID ,
  CHANGE_CUSTOMER_PRODUCT_FLAG        ,
  AUDIT_FIELD                        ,
  OBJECT_VERSION_NUMBER             ,
  PLATFORM_ID                      ,
  OLD_PLATFORM_ID                 ,
  CHANGE_PLATFORM_ID_FLAG        ,
  PLATFORM_VERSION_ID           ,
  OLD_PLATFORM_VERSION_ID      ,
  CHANGE_PLAT_VER_ID_FLAG     ,
  CP_COMPONENT_ID            ,
  OLD_CP_COMPONENT_ID       ,
  CHANGE_CP_COMPONENT_ID_FLAG ,
  CP_COMPONENT_VERSION_ID    ,
  OLD_CP_COMPONENT_VERSION_ID,
  CHANGE_CP_COMP_VER_ID_FLAG ,
  CP_SUBCOMPONENT_ID         ,
  OLD_CP_SUBCOMPONENT_ID    ,
  CHANGE_CP_SUBCOMPONENT_ID_FLAG ,
  CP_SUBCOMPONENT_VERSION_ID    ,
  OLD_CP_SUBCOMPONENT_VERSION_ID ,
  CHANGE_CP_SUBCOMP_VER_ID_FLAG ,
  LANGUAGE_ID                  ,
  OLD_LANGUAGE_ID             ,
  CHANGE_LANGUAGE_ID_FLAG   ,
  TERRITORY_ID             ,
  OLD_TERRITORY_ID          ,
  CHANGE_TERRITORY_ID_FLAG ,
  CP_REVISION_ID          ,
  OLD_CP_REVISION_ID     ,
  CHANGE_CP_REVISION_ID_FLAG ,
  INV_ITEM_REVISION         ,
  OLD_INV_ITEM_REVISION    ,
  CHANGE_INV_ITEM_REVISION,
  INV_COMPONENT_ID       ,
  OLD_INV_COMPONENT_ID  ,
  CHANGE_INV_COMPONENT_ID   ,
  INV_COMPONENT_VERSION    ,
  OLD_INV_COMPONENT_VERSION  ,
  CHANGE_INV_COMPONENT_VERSION  ,
  INV_SUBCOMPONENT_ID          ,
  OLD_INV_SUBCOMPONENT_ID     ,
  CHANGE_INV_SUBCOMPONENT_ID ,
  INV_SUBCOMPONENT_VERSION  ,
  OLD_INV_SUBCOMPONENT_VERSION  ,
  CHANGE_INV_SUBCOMP_VERSION   ,
  RESOURCE_TYPE               ,
  OLD_RESOURCE_TYPE          ,
  CHANGE_RESOURCE_TYPE_FLAG ,
  OLD_GROUP_TYPE              ,
  GROUP_TYPE                 ,
  CHANGE_GROUP_TYPE_FLAG    ,
  OLD_OWNER_ASSIGNED_TIME  ,
  OWNER_ASSIGNED_TIME   ,
  CHANGE_ASSIGNED_TIME_FLAG          ,
  INV_PLATFORM_ORG_ID               ,
  OLD_INV_PLATFORM_ORG_ID          ,
  CHANGE_PLATFORM_ORG_ID_FLAG     ,
  COMPONENT_VERSION              ,
  OLD_COMPONENT_VERSION         ,
  CHANGE_COMP_VER_FLAG         ,
  SUBCOMPONENT_VERSION        ,
  OLD_SUBCOMPONENT_VERSION   ,
  CHANGE_SUBCOMP_VER_FLAG   ,
  PRODUCT_REVISION                   ,
  OLD_PRODUCT_REVISION              ,
  CHANGE_PRODUCT_REVISION_FLAG     ,
  INVENTORY_ITEM_ID               ,
  OLD_INVENTORY_ITEM_ID          ,
  CHANGE_INVENTORY_ITEM_FLAG    ,
  INV_ORGANIZATION_ID          ,
  OLD_INV_ORGANIZATION_ID     ,
  CHANGE_INV_ORGANIZATION_FLAG   ,
  STATUS_FLAG                   ,
  OLD_STATUS_FLAG              ,
  CHANGE_STATUS_FLAG          ,
  PRIMARY_CONTACT_ID         ,
  CHANGE_PRIMARY_CONTACT_FLAG  ,
  OLD_PRIMARY_CONTACT_ID      ,
  SECURITY_GROUP_ID
FROM cs_incidents_audit_b
WHERE INCIDENT_ID = c_incident_id
AND   NVL(UPGRADE_FLAG_FOR_CREATE,'N') = 'N'
AND   NVL(updated_entity_code,'SR_HEADER') = 'SR_HEADER'
ORDER BY creation_date, incident_audit_id asc;

CURSOR c_close_flag(p_incident_status_id NUMBER) IS
SELECT close_flag
FROM   cs_incident_statuses_b
WHERE  incident_status_id = p_incident_status_id;

l_request_id number;
l_incident_audit_id number;
l_audit_count number;
l_audit_rec c_sr_audit%rowtype;
l_audit_rec_asc c_sr_audit_asc%rowtype;
l_create_audit_rec c_sr_current%rowtype;
loop_cnt   number;
l_new_close_flag   VARCHAR2(1) := 'N';
l_old_close_flag   VARCHAR2(1) := 'N';
l_create_flag_close_date   VARCHAR2(1) := 'N';

l_sta_update number :=0;
l_sev_update number :=0;
l_urg_update number :=0;
l_typ_update number :=0;
l_rgp_update number :=0;
l_own_update number :=0;
l_res_update number :=0;
l_grp_update number :=0;
l_obl_update number :=0;
l_sit_update number :=0;
l_bto_update number :=0;
l_sto_update number :=0;
l_idt_update number :=0;
l_cdt_update number :=0;
l_cpd_update number :=0;
l_pid_update number :=0;
l_pvf_update number :=0;
l_cci_update number :=0;
l_cvi_update number :=0;
l_sci_update number :=0;
l_svi_update number :=0;
l_lan_update number :=0;
l_ter_update number :=0;
l_cpr_update number :=0;
l_iiv_update number :=0;
l_ici_update number :=0;
l_icv_update number :=0;
l_isc_update number :=0;
l_isv_update number :=0;
l_rrp_update number :=0;
l_gpt_update number :=0;
l_oat_update number :=0;
l_por_update number :=0;
l_cov_update number :=0;
l_scv_update number :=0;
l_prv_update number :=0;
l_inv_update number :=0;
l_ino_update number :=0;
l_sfl_update number :=0;
l_pci_update number :=0;

l_inc_owner_id  NUMBER := NULL;
l_inc_exp_res_date DATE := NULL;
l_inc_group_id NUMBER := NULL;
l_inc_oblig_date DATE :=  NULL;
l_inc_site_id  NUMBER:=  NULL;
l_inc_billto_contact NUMBER := NULL;
l_inc_shipto_contact NUMBER :=  NULL;
l_inc_inci_date DATE :=  NULL;
l_inc_close_date DATE :=  NULL;
l_inc_cust_prod_id NUMBER := NULL;
l_inc_platf_id NUMBER :=  NULL;
l_inc_platf_ver VARCHAR2(250) := NULL;
l_inc_cp_comp_id NUMBER :=  NULL;
l_inc_cp_comp_ver_id NUMBER :=  NULL;
l_inc_cp_subcomp_id NUMBER := NULL;
l_inc_cp_subcomp_ver_id NUMBER :=  NULL;
l_inc_lang_id NUMBER :=  NULL;
l_inc_terr_id NUMBER :=  NULL;
l_cp_rev_id NUMBER :=  NULL;
l_inc_item_rev VARCHAR2(250) :=  NULL;
l_inc_inv_comp_id NUMBER :=  NULL;
l_inc_inv_comp_ver VARCHAR2(3) :=  NULL;
l_inc_inv_subcomp_id NUMBER :=  NULL;
l_inc_inv_subcomp_ver VARCHAR2(3) :=  NULL;
l_inc_resource_type VARCHAR2(30) :=  NULL;
l_inc_group_type VARCHAR2(30) :=  NULL;
l_inc_owner_assi_time DATE :=  NULL;
l_inc_inv_item_id NUMBER :=  NULL;
l_inc_inv_org_id NUMBER :=  NULL;
l_inc_status_flag VARCHAR2(3) :=   NULL;
 --
  -- the APIs use a combination of TABLE_NAME and UPDATE_NAME to track an
  -- update. The update should be a no-op on a rerun, provided the TABLE_NAME
  -- and UPDATE_NAME do not change.
  --
  -- If you have modified the script for upgrade logic and you want the
  -- script to reprocess the data, you must modify UPDATE_NAME to reflect
  -- the change.
  --
  l_audit_date        DATE;

l_worker_id            NUMBER;
l_product              VARCHAR2(30) := 'CS';
l_table_name           VARCHAR2(30) := 'CS_INCIDENTS_ALL_B';
l_table_owner          VARCHAR2(30);
l_update_name          VARCHAR2(30) := 'csxaucpb.pls'; -- l_update_name will be appended with sysdate, do not make this longer than 18 characters
l_start_rowid          ROWID;
l_end_rowid            ROWID;
l_rows_processed       NUMBER;
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);
l_retstatus            BOOLEAN;
l_any_rows_to_process  BOOLEAN;

BEGIN

  l_retstatus := fnd_installation.get_app_info(
                  l_product, l_status, l_industry, l_table_owner);

  IF ((l_retstatus = FALSE) OR (l_table_owner IS NULL)) THEN
      RAISE_APPLICATION_ERROR(-20001,
         'Cannot get schema name for product : '||l_product);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, '  X_Worker_Id : '||x_worker_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Num_Workers : '||x_num_workers);

  BEGIN -- {begin1

  l_audit_date          := to_date(p_audit_date,'YYYY/MM/DD HH24:MI:SS');
  FND_FILE.Put_Line(fnd_file.log, 'p_audit_date=' || p_audit_date);
  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_update_name || p_update_date,  -- to ensure it is rerunnable
           x_worker_id,
           x_num_workers,
           x_batch_size, 0);

  ad_parallel_updates_pkg.get_rowid_range(
           l_start_rowid,
           l_end_rowid,
           l_any_rows_to_process,
           x_batch_size,
           TRUE);

  WHILE (l_any_rows_to_process) LOOP --{Loop1
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_start_rowid=' || l_start_rowid || ';l_end_rowid=' || l_end_rowid);
   open c_sr_current(l_start_rowid,l_end_rowid,l_audit_date);
   l_loop_counter := 0;
   fnd_file.put_line(fnd_file.log,'Service Requests processed:');
  LOOP -- {Loop2
   fetch c_sr_current into l_create_audit_rec;
   EXIT WHEN c_sr_current%NOTFOUND;
   l_sta_update :=0;
   l_sev_update :=0;
   l_urg_update :=0;
   l_typ_update :=0;
   l_rgp_update :=0;
   l_own_update :=0;
   l_res_update :=0;
   l_grp_update :=0;
   l_obl_update :=0;
   l_sit_update :=0;
   l_bto_update :=0;
   l_sto_update :=0;
   l_idt_update :=0;
   l_cdt_update :=0;
   l_cpd_update :=0;
   l_pid_update :=0;
   l_pvf_update :=0;
   l_cci_update :=0;
   l_cvi_update :=0;
   l_sci_update :=0;
   l_svi_update :=0;
   l_lan_update :=0;
   l_ter_update :=0;
   l_cpr_update :=0;
   l_iiv_update :=0;
   l_ici_update :=0;
   l_icv_update :=0;
   l_isc_update :=0;
   l_isv_update :=0;
   l_rrp_update :=0;
   l_gpt_update :=0;
   l_oat_update :=0;
   l_por_update :=0;
   l_cov_update :=0;
   l_scv_update :=0;
   l_prv_update :=0;
   l_inv_update :=0;
   l_ino_update :=0;
   l_sfl_update :=0;
   l_pci_update :=0;

   l_inc_owner_id := NULL;
   l_inc_exp_res_date := NULL;
   l_inc_group_id := NULL;
   l_inc_oblig_date :=  NULL;
   l_inc_site_id :=  NULL;
   l_inc_billto_contact := NULL;
   l_inc_shipto_contact :=  NULL;
   l_inc_inci_date :=  NULL;
   l_inc_close_date :=  NULL;
   l_inc_cust_prod_id := NULL;
   l_inc_platf_id :=  NULL;
   l_inc_platf_ver := NULL;
   l_inc_cp_comp_id :=  NULL;
   l_inc_cp_comp_ver_id :=  NULL;
   l_inc_cp_subcomp_id := NULL;
   l_inc_cp_subcomp_ver_id :=  NULL;
   l_inc_lang_id :=  NULL;
   l_inc_terr_id :=  NULL;
   l_cp_rev_id :=  NULL;
   l_inc_item_rev :=  NULL;
   l_inc_inv_comp_id :=  NULL;
   l_inc_inv_comp_ver :=  NULL;
   l_inc_inv_subcomp_id :=  NULL;
   l_inc_inv_subcomp_ver :=  NULL;
   l_inc_resource_type :=  NULL;
   l_inc_group_type :=  NULL;
   l_inc_owner_assi_time :=  NULL;
   l_inc_inv_item_id :=  NULL;
   l_inc_inv_org_id :=  NULL;
   l_inc_status_flag :=   NULL;

   l_request_id := l_create_audit_rec.incident_id;
   --l_loop_counter := 0;
   select count(incident_audit_id) into l_audit_count
   from cs_incidents_audit_b
   where incident_id= l_request_id
   and NVL(upgrade_flag_for_create,'N') = 'N'
   and NVL(updated_entity_code, 'SR_HEADER') = 'SR_HEADER';

    fnd_file.put_line(fnd_file.log,'SR Number:' ||l_create_audit_rec.incident_number
      || '; SR ID: ' || l_request_id);
    fnd_file.put_line(fnd_file.log,'l_audit_count:' ||l_audit_count);

  if l_audit_count >0 then
    open c_sr_audit(l_request_id);
    LOOP
      FETCH c_sr_audit into l_audit_rec;
      EXIT WHEN c_sr_audit%NOTFOUND;
      if l_audit_rec.CHANGE_INCIDENT_STATUS_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG := 'Y';
          l_create_audit_rec.OLD_INCIDENT_STATUS_ID := l_audit_rec.OLD_INCIDENT_STATUS_ID ;
          l_create_audit_rec.INCIDENT_STATUS_ID := l_audit_rec.INCIDENT_STATUS_ID ;
          l_sta_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INCIDENT_STATUS_FLAG, 'N') = 'N' then
          l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG := 'N';
        if l_sta_update >0 then
          if l_create_audit_rec.old_INCIDENT_STATUS_ID is not null then
            l_create_audit_rec.INCIDENT_STATUS_ID := l_create_audit_rec.old_INCIDENT_STATUS_ID ;
          end if;
          l_create_audit_rec.OLD_INCIDENT_STATUS_ID := l_audit_rec.OLD_INCIDENT_STATUS_ID ;
          l_sta_update := 0;
        else
          l_create_audit_rec.OLD_INCIDENT_STATUS_ID := l_create_audit_rec.INCIDENT_STATUS_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INCIDENT_TYPE_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG := 'Y';
          l_create_audit_rec.OLD_INCIDENT_TYPE_ID := l_audit_rec.OLD_INCIDENT_TYPE_ID      ;
          l_create_audit_rec.INCIDENT_TYPE_ID := l_audit_rec.INCIDENT_TYPE_ID ;
          l_typ_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INCIDENT_TYPE_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG := 'N';
        if l_typ_update >0 then
          if (l_create_audit_rec.OLD_INCIDENT_TYPE_ID is not null) then
            l_create_audit_rec.INCIDENT_TYPE_ID := l_create_audit_rec.OLD_INCIDENT_TYPE_ID ;
          end if;
          l_create_audit_rec.OLD_INCIDENT_TYPE_ID := l_audit_rec.OLD_INCIDENT_TYPE_ID ;
          l_typ_update := 0;
        else
          l_create_audit_rec.OLD_INCIDENT_TYPE_ID := l_create_audit_rec.INCIDENT_TYPE_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG := 'Y';
        l_create_audit_rec.OLD_INCIDENT_URGENCY_ID := l_audit_rec.OLD_INCIDENT_URGENCY_ID ;
        l_create_audit_rec.INCIDENT_URGENCY_ID := l_audit_rec.INCIDENT_URGENCY_ID ;
        l_urg_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG := 'N';
        if l_urg_update >0 then
          l_create_audit_rec.INCIDENT_URGENCY_ID := l_create_audit_rec.OLD_INCIDENT_URGENCY_ID ;
          l_create_audit_rec.OLD_INCIDENT_URGENCY_ID := l_audit_rec.OLD_INCIDENT_URGENCY_ID ;
          l_urg_update := 0;
        else
          l_create_audit_rec.OLD_INCIDENT_URGENCY_ID := l_create_audit_rec.INCIDENT_URGENCY_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'Y';
          l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID := l_audit_rec.OLD_INCIDENT_SEVERITY_ID   ;
          l_create_audit_rec.INCIDENT_SEVERITY_ID := l_audit_rec.INCIDENT_SEVERITY_ID   ;
          l_sev_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG,'N') = 'N' then
        l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'N';
        if l_sev_update >0 then
          if (l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID is not null) then
            l_create_audit_rec.INCIDENT_SEVERITY_ID := l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID ;
          end if;
          l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID := l_audit_rec.OLD_INCIDENT_SEVERITY_ID ;
          l_sev_update := 0;
        else
          l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID := l_create_audit_rec.INCIDENT_SEVERITY_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG := 'Y';
        l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID := l_audit_rec.OLD_RESPONSIBLE_GROUP_ID   ;
        l_create_audit_rec.RESPONSIBLE_GROUP_ID := l_audit_rec.RESPONSIBLE_GROUP_ID   ;
        l_rgp_update := 1;
      elsif NVL(l_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG := 'N';
        if l_rgp_update >0 then
          l_create_audit_rec.RESPONSIBLE_GROUP_ID := l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID ;
          l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID := l_audit_rec.OLD_RESPONSIBLE_GROUP_ID ;
          l_rgp_update := 0;
        else
          l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID := l_create_audit_rec.RESPONSIBLE_GROUP_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INCIDENT_OWNER_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
        l_create_audit_rec.OLD_INCIDENT_OWNER_ID := l_audit_rec.OLD_INCIDENT_OWNER_ID;
        l_create_audit_rec.INCIDENT_OWNER_ID := l_audit_rec.INCIDENT_OWNER_ID;
        l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG := 'Y';
      	l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_audit_rec.OLD_OWNER_ASSIGNED_TIME;
      	l_create_audit_rec.OWNER_ASSIGNED_TIME := l_audit_rec.OWNER_ASSIGNED_TIME;
      	if (l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME is null and l_audit_count > 1) then
      	  l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_create_audit_rec.creation_date;
      	end if;
        l_oat_update := 1;
        l_own_update := 1;
        if l_audit_rec.CHANGE_RESOURCE_TYPE_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'Y';
          l_create_audit_rec.OLD_RESOURCE_TYPE := l_audit_rec.OLD_RESOURCE_TYPE;
          l_create_audit_rec.RESOURCE_TYPE := l_audit_rec.RESOURCE_TYPE ;
          l_rrp_update := 1;
        elsif nvl(l_audit_rec.CHANGE_RESOURCE_TYPE_FLAG, 'N') = 'N' then
          l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'N';
          if l_rrp_update >0 then
            l_create_audit_rec.RESOURCE_TYPE := l_create_audit_rec.OLD_RESOURCE_TYPE ;
            l_create_audit_rec.OLD_RESOURCE_TYPE := l_audit_rec.OLD_RESOURCE_TYPE ;
            l_rrp_update := 0;
          else
            l_create_audit_rec.OLD_RESOURCE_TYPE := l_create_audit_rec.RESOURCE_TYPE ;
          end if;
        end if;
      elsif NVL(l_audit_rec.CHANGE_INCIDENT_OWNER_FLAG,'N') = 'N' then
        l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG := 'N';
        l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG := 'N';
        if l_own_update >0 then
          l_create_audit_rec.INCIDENT_OWNER_ID := l_create_audit_rec.OLD_INCIDENT_OWNER_ID ;
          l_create_audit_rec.OLD_INCIDENT_OWNER_ID := l_audit_rec.OLD_INCIDENT_OWNER_ID ;
          l_own_update := 0;
        else
          l_create_audit_rec.OLD_INCIDENT_OWNER_ID := l_create_audit_rec.INCIDENT_OWNER_ID ;
        end if;
        if l_oat_update >0 then
	        l_create_audit_rec.OWNER_ASSIGNED_TIME := l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME ;
	        l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_audit_rec.OLD_OWNER_ASSIGNED_TIME ;
	        l_oat_update := 0;
	      else
          if (l_create_audit_rec.OWNER_ASSIGNED_TIME IS NULL) THEN
            l_create_audit_rec.OWNER_ASSIGNED_TIME := l_create_audit_rec.creation_date;
          end if;
	        l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_create_audit_rec.OWNER_ASSIGNED_TIME ;
        end if;

        if NVL(l_audit_rec.CHANGE_RESOURCE_TYPE_FLAG, 'N') = 'N' then
          l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'N';
          if l_rrp_update >0 then
            l_create_audit_rec.RESOURCE_TYPE := l_create_audit_rec.OLD_RESOURCE_TYPE ;
            l_create_audit_rec.OLD_RESOURCE_TYPE := l_audit_rec.OLD_RESOURCE_TYPE ;
            l_rrp_update := 0;
          else
            l_create_audit_rec.OLD_RESOURCE_TYPE := l_create_audit_rec.RESOURCE_TYPE ;
          end if;
        end if;
      end if;

      if l_audit_rec.CHANGE_RESOLUTION_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_RESOLUTION_FLAG := 'Y';
        l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE := l_audit_rec.OLD_EXPECTED_RESOLUTION_DATE  ;
        l_create_audit_rec.EXPECTED_RESOLUTION_DATE := l_audit_rec.EXPECTED_RESOLUTION_DATE  ;
        l_res_update := 1;
      elsif NVL(l_audit_rec.CHANGE_RESOLUTION_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_RESOLUTION_FLAG := 'N';
        if l_res_update >0 then
          l_create_audit_rec.EXPECTED_RESOLUTION_DATE := l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE ;
          l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE := l_audit_rec.OLD_EXPECTED_RESOLUTION_DATE ;
          l_res_update := 0;
        else
          l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE := l_create_audit_rec.EXPECTED_RESOLUTION_DATE ;
        end if;
      end if;

      if l_audit_rec.CHANGE_GROUP_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_GROUP_FLAG := 'Y';
        l_create_audit_rec.OLD_GROUP_ID := l_audit_rec.OLD_GROUP_ID        ;
        l_create_audit_rec.GROUP_ID := l_audit_rec.GROUP_ID        ;
        l_grp_update := 1;
        if l_audit_rec.CHANGE_GROUP_TYPE_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG := 'Y';
          l_create_audit_rec.OLD_GROUP_TYPE := l_audit_rec.OLD_GROUP_TYPE;
          l_create_audit_rec.GROUP_TYPE := l_audit_rec.GROUP_TYPE;
          l_gpt_update := 1;
        end if;
      elsif NVL(l_audit_rec.CHANGE_GROUP_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_GROUP_FLAG := 'N';
        if l_grp_update >0 then
          l_create_audit_rec.GROUP_ID := l_create_audit_rec.OLD_GROUP_ID ;
          l_create_audit_rec.OLD_GROUP_ID := l_audit_rec.OLD_GROUP_ID ;
          l_grp_update := 0;
        else
          l_create_audit_rec.OLD_GROUP_ID := l_create_audit_rec.GROUP_ID ;
        end if;
        if NVL(l_audit_rec.CHANGE_GROUP_TYPE_FLAG, 'N') = 'N' then
          l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG := 'N';
          if l_gpt_update >0 then
            l_create_audit_rec.GROUP_TYPE := l_create_audit_rec.OLD_GROUP_TYPE ;
            l_create_audit_rec.OLD_GROUP_TYPE := l_audit_rec.OLD_GROUP_TYPE ;
            l_gpt_update := 0;
          else
            l_create_audit_rec.OLD_GROUP_TYPE := l_create_audit_rec.GROUP_TYPE ;
          end if;
        end if;
      end if;

      if l_audit_rec.CHANGE_OBLIGATION_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_OBLIGATION_FLAG := 'Y';
        l_create_audit_rec.OLD_OBLIGATION_DATE := l_audit_rec.OLD_OBLIGATION_DATE ;
        l_create_audit_rec.OBLIGATION_DATE := l_audit_rec.OBLIGATION_DATE ;
        l_obl_update := 1;
      elsif NVL(l_audit_rec.CHANGE_OBLIGATION_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_OBLIGATION_FLAG := 'N';
        if l_obl_update >0 then
          l_create_audit_rec.OBLIGATION_DATE := l_create_audit_rec.OLD_OBLIGATION_DATE ;
          l_create_audit_rec.OLD_OBLIGATION_DATE := l_audit_rec.OLD_OBLIGATION_DATE ;
          l_obl_update := 0;
        else
          l_create_audit_rec.OLD_OBLIGATION_DATE := l_create_audit_rec.OBLIGATION_DATE ;
        end if;
      end if;

      if l_audit_rec.CHANGE_SITE_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_SITE_FLAG := 'Y';
        l_create_audit_rec.OLD_SITE_ID := l_audit_rec.OLD_SITE_ID ;
        l_create_audit_rec.SITE_ID := l_audit_rec.SITE_ID ;
        l_sit_update := 1;
      elsif NVL(l_audit_rec.CHANGE_SITE_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_SITE_FLAG := 'N';
        if l_sit_update >0 then
          l_create_audit_rec.SITE_ID := l_create_audit_rec.OLD_SITE_ID ;
          l_create_audit_rec.OLD_SITE_ID := l_audit_rec.OLD_SITE_ID ;
          l_sit_update := 0;
        else
          l_create_audit_rec.OLD_SITE_ID := l_create_audit_rec.SITE_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_BILL_TO_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_BILL_TO_FLAG := 'Y';
        l_create_audit_rec.OLD_BILL_TO_CONTACT_ID := l_audit_rec.OLD_BILL_TO_CONTACT_ID  ;
        l_create_audit_rec.BILL_TO_CONTACT_ID := l_audit_rec.BILL_TO_CONTACT_ID  ;
        l_bto_update := 1;
      elsif NVL(l_audit_rec.CHANGE_BILL_TO_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_BILL_TO_FLAG := 'N';
        if l_bto_update >0 then
          l_create_audit_rec.BILL_TO_CONTACT_ID := l_create_audit_rec.OLD_BILL_TO_CONTACT_ID ;
          l_create_audit_rec.OLD_BILL_TO_CONTACT_ID := l_audit_rec.OLD_BILL_TO_CONTACT_ID ;
          l_bto_update := 0;
        else
          l_create_audit_rec.OLD_BILL_TO_CONTACT_ID := l_create_audit_rec.BILL_TO_CONTACT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_SHIP_TO_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_SHIP_TO_FLAG := 'Y';
        l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID := l_audit_rec.OLD_SHIP_TO_CONTACT_ID ;
        l_create_audit_rec.SHIP_TO_CONTACT_ID := l_audit_rec.SHIP_TO_CONTACT_ID ;
        l_sto_update := 1;
      elsif NVL(l_audit_rec.CHANGE_SHIP_TO_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_SHIP_TO_FLAG := 'N';
        if l_sto_update >0 then
          l_create_audit_rec.SHIP_TO_CONTACT_ID := l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID ;
          l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID := l_audit_rec.OLD_SHIP_TO_CONTACT_ID ;
          l_sto_update := 0;
        else
          l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID := l_create_audit_rec.SHIP_TO_CONTACT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INCIDENT_DATE_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG := 'Y';
        l_create_audit_rec.OLD_INCIDENT_DATE := l_audit_rec.OLD_INCIDENT_DATE   ;
        l_create_audit_rec.INCIDENT_DATE := l_audit_rec.INCIDENT_DATE   ;
        l_idt_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INCIDENT_DATE_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG := 'N';
        if l_idt_update >0 then
          l_create_audit_rec.INCIDENT_DATE := l_create_audit_rec.OLD_INCIDENT_DATE ;
          l_create_audit_rec.OLD_INCIDENT_DATE := l_audit_rec.OLD_INCIDENT_DATE ;
          l_idt_update := 0;
        else
          l_create_audit_rec.OLD_INCIDENT_DATE := l_create_audit_rec.INCIDENT_DATE ;
        end if;
      end if;

      if l_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'Y';
        l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID := l_audit_rec.OLD_CUSTOMER_PRODUCT_ID ;
        l_create_audit_rec.CUSTOMER_PRODUCT_ID := l_audit_rec.CUSTOMER_PRODUCT_ID ;
        l_cpd_update := 1;
      elsif NVL(l_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'N';
        if l_cpd_update >0 then
          l_create_audit_rec.CUSTOMER_PRODUCT_ID := l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID ;
          l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID := l_audit_rec.OLD_CUSTOMER_PRODUCT_ID ;
          l_cpd_update := 0;
        else
          l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID := l_create_audit_rec.CUSTOMER_PRODUCT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_PLATFORM_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_PLATFORM_ID := l_audit_rec.OLD_PLATFORM_ID   ;
        l_create_audit_rec.PLATFORM_ID := l_audit_rec.PLATFORM_ID   ;
        l_pid_update := 1;
      elsif NVL(l_audit_rec.CHANGE_PLATFORM_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG := 'N';
        if l_pid_update >0 then
          l_create_audit_rec.PLATFORM_ID := l_create_audit_rec.OLD_PLATFORM_ID ;
          l_create_audit_rec.OLD_PLATFORM_ID := l_audit_rec.OLD_PLATFORM_ID ;
          l_pid_update := 0;
        else
          l_create_audit_rec.OLD_PLATFORM_ID := l_create_audit_rec.PLATFORM_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_PLAT_VER_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_PLATFORM_VERSION_ID := l_audit_rec.OLD_PLATFORM_VERSION_ID      ;
        l_create_audit_rec.PLATFORM_VERSION_ID := l_audit_rec.PLATFORM_VERSION_ID      ;
        l_pvf_update := 1;
      elsif NVL(l_audit_rec.CHANGE_PLAT_VER_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG := 'N';
        if l_pvf_update >0 then
          l_create_audit_rec.PLATFORM_VERSION_ID := l_create_audit_rec.OLD_PLATFORM_VERSION_ID ;
          l_create_audit_rec.OLD_PLATFORM_VERSION_ID := l_audit_rec.OLD_PLATFORM_VERSION_ID ;
          l_pvf_update := 0;
        else
          l_create_audit_rec.OLD_PLATFORM_VERSION_ID := l_create_audit_rec.PLATFORM_VERSION_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_CP_COMPONENT_ID := l_audit_rec.OLD_CP_COMPONENT_ID       ;
        l_create_audit_rec.CP_COMPONENT_ID := l_audit_rec.CP_COMPONENT_ID       ;
        l_cci_update := 1;
      elsif NVL(l_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'N';
        if l_cci_update >0 then
          l_create_audit_rec.CP_COMPONENT_ID := l_create_audit_rec.OLD_CP_COMPONENT_ID ;
          l_create_audit_rec.OLD_CP_COMPONENT_ID := l_audit_rec.OLD_CP_COMPONENT_ID ;
          l_cci_update := 0;
        else
          l_create_audit_rec.OLD_CP_COMPONENT_ID := l_create_audit_rec.CP_COMPONENT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID := l_audit_rec.OLD_CP_COMPONENT_VERSION_ID;
        l_create_audit_rec.CP_COMPONENT_VERSION_ID := l_audit_rec.CP_COMPONENT_VERSION_ID;
        l_cvi_update := 1;
      elsif NVL(l_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'N';
        if l_cvi_update >0 then
          l_create_audit_rec.CP_COMPONENT_VERSION_ID := l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID ;
          l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID := l_audit_rec.OLD_CP_COMPONENT_VERSION_ID ;
          l_cvi_update := 0;
        else
          l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID := l_create_audit_rec.CP_COMPONENT_VERSION_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_ID    ;
        l_create_audit_rec.CP_SUBCOMPONENT_ID := l_audit_rec.CP_SUBCOMPONENT_ID    ;
        l_sci_update := 1;
      elsif NVL(l_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG := 'N';
        if l_sci_update >0 then
          l_create_audit_rec.CP_SUBCOMPONENT_ID := l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID ;
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_ID ;
          l_sci_update := 0;
        else
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID := l_create_audit_rec.CP_SUBCOMPONENT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ;
        l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID := l_audit_rec.CP_SUBCOMPONENT_VERSION_ID ;
        l_svi_update := 1;
      elsif NVL(l_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'N';
        if l_svi_update >0 then
          l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID := l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ;
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ;
          l_svi_update := 0;
        else
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID := l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_LANGUAGE_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_LANGUAGE_ID := l_audit_rec.OLD_LANGUAGE_ID             ;
        l_create_audit_rec.LANGUAGE_ID := l_audit_rec.LANGUAGE_ID  ;
        l_lan_update := 1;
      elsif NVL(l_audit_rec.CHANGE_LANGUAGE_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG := 'N';
        if l_lan_update >0 then
          l_create_audit_rec.LANGUAGE_ID := l_create_audit_rec.OLD_LANGUAGE_ID ;
          l_create_audit_rec.OLD_LANGUAGE_ID := l_audit_rec.OLD_LANGUAGE_ID ;
          l_lan_update := 0;
        else
          l_create_audit_rec.OLD_LANGUAGE_ID := l_create_audit_rec.LANGUAGE_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_TERRITORY_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_TERRITORY_ID := l_audit_rec.OLD_TERRITORY_ID ;
        l_create_audit_rec.TERRITORY_ID := l_audit_rec.TERRITORY_ID  ;
        l_ter_update := 1;
      elsif NVL(l_audit_rec.CHANGE_TERRITORY_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG := 'N';
        if l_ter_update >0 then
          l_create_audit_rec.TERRITORY_ID := l_create_audit_rec.OLD_TERRITORY_ID ;
          l_create_audit_rec.OLD_TERRITORY_ID := l_audit_rec.OLD_TERRITORY_ID ;
          l_ter_update := 0;
        else
          l_create_audit_rec.OLD_TERRITORY_ID := l_create_audit_rec.TERRITORY_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_CP_REVISION_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_CP_REVISION_ID := l_audit_rec.OLD_CP_REVISION_ID     ;
        l_create_audit_rec.CP_REVISION_ID := l_audit_rec.CP_REVISION_ID     ;
        l_cpr_update := 1;
      elsif NVL(l_audit_rec.CHANGE_CP_REVISION_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG := 'N';
        if l_cpr_update >0 then
          l_create_audit_rec.CP_REVISION_ID := l_create_audit_rec.CP_REVISION_ID ;
          l_create_audit_rec.OLD_CP_REVISION_ID := l_audit_rec.OLD_CP_REVISION_ID ;
          l_cpr_update := 0;
        else
          l_create_audit_rec.OLD_CP_REVISION_ID := l_create_audit_rec.CP_REVISION_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INV_ITEM_REVISION = 'Y' then
        l_create_audit_rec.CHANGE_INV_ITEM_REVISION := 'Y';
        l_create_audit_rec.OLD_INV_ITEM_REVISION := l_audit_rec.OLD_INV_ITEM_REVISION    ;
        l_create_audit_rec.INV_ITEM_REVISION := l_audit_rec.INV_ITEM_REVISION    ;
        l_iiv_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INV_ITEM_REVISION, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INV_ITEM_REVISION := 'N';
        if l_iiv_update >0 then
          l_create_audit_rec.INV_ITEM_REVISION := l_create_audit_rec.OLD_INV_ITEM_REVISION ;
          l_create_audit_rec.OLD_INV_ITEM_REVISION := l_audit_rec.OLD_INV_ITEM_REVISION ;
          l_iiv_update := 0;
        else
          l_create_audit_rec.OLD_INV_ITEM_REVISION := l_create_audit_rec.INV_ITEM_REVISION ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INV_COMPONENT_ID   = 'Y' then
        l_create_audit_rec.CHANGE_INV_COMPONENT_ID := 'Y';
        l_create_audit_rec.OLD_INV_COMPONENT_ID := l_audit_rec.OLD_INV_COMPONENT_ID  ;
        l_create_audit_rec.INV_COMPONENT_ID := l_audit_rec.INV_COMPONENT_ID  ;
        l_ici_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INV_COMPONENT_ID, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INV_COMPONENT_ID := 'N';
        if l_ici_update >0 then
          l_create_audit_rec.INV_COMPONENT_ID := l_create_audit_rec.OLD_INV_COMPONENT_ID ;
          l_create_audit_rec.OLD_INV_COMPONENT_ID := l_audit_rec.OLD_INV_COMPONENT_ID ;
          l_ici_update := 0;
        else
          l_create_audit_rec.OLD_INV_COMPONENT_ID := l_create_audit_rec.INV_COMPONENT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INV_COMPONENT_VERSION   = 'Y' then
        l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION := 'Y';
        l_create_audit_rec.OLD_INV_COMPONENT_VERSION := l_audit_rec.OLD_INV_COMPONENT_VERSION  ;
        l_create_audit_rec.INV_COMPONENT_VERSION := l_audit_rec.INV_COMPONENT_VERSION  ;
        l_icv_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INV_COMPONENT_VERSION, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION := 'N';
        if l_icv_update >0 then
          l_create_audit_rec.INV_COMPONENT_VERSION := l_create_audit_rec.OLD_INV_COMPONENT_VERSION ;
          l_create_audit_rec.INV_COMPONENT_VERSION := l_audit_rec.OLD_INV_COMPONENT_VERSION ;
          l_icv_update := 0;
        else
          l_create_audit_rec.OLD_INV_COMPONENT_VERSION := l_create_audit_rec.INV_COMPONENT_VERSION ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INV_SUBCOMPONENT_ID  = 'Y' then
        l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID := 'Y';
        l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID := l_audit_rec.OLD_INV_SUBCOMPONENT_ID     ;
        l_create_audit_rec.INV_SUBCOMPONENT_ID := l_audit_rec.INV_SUBCOMPONENT_ID     ;
        l_isc_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INV_SUBCOMPONENT_ID, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID := 'N';
        if l_isc_update >0 then
          l_create_audit_rec.INV_SUBCOMPONENT_ID := l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID ;
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID := l_audit_rec.OLD_INV_SUBCOMPONENT_ID ;
          l_isc_update := 0;
        else
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID := l_create_audit_rec.INV_SUBCOMPONENT_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INV_SUBCOMP_VERSION   = 'Y' then
        l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION := 'Y';
        l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION := l_audit_rec.OLD_INV_SUBCOMPONENT_VERSION  ;
        l_create_audit_rec.INV_SUBCOMPONENT_VERSION := l_audit_rec.INV_SUBCOMPONENT_VERSION  ;
        l_isv_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INV_SUBCOMP_VERSION, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION := 'N';
        if l_isv_update >0 then
          l_create_audit_rec.INV_SUBCOMPONENT_VERSION := l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION ;
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION := l_audit_rec.OLD_INV_SUBCOMPONENT_VERSION ;
          l_isv_update := 0;
        else
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION := l_create_audit_rec.INV_SUBCOMPONENT_VERSION ;
        end if;
      end if;

      if l_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'Y';
        l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID := l_audit_rec.OLD_INV_PLATFORM_ORG_ID ;
        l_create_audit_rec.INV_PLATFORM_ORG_ID := l_audit_rec.INV_PLATFORM_ORG_ID ;
        l_por_update := 1;
      elsif NVL(l_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'N';
        if l_por_update >0 then
          l_create_audit_rec.INV_PLATFORM_ORG_ID := l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID ;
          l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID := l_audit_rec.OLD_INV_PLATFORM_ORG_ID ;
          l_por_update := 0;
        else
          l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID := l_create_audit_rec.INV_PLATFORM_ORG_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_COMP_VER_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_COMP_VER_FLAG := 'Y';
        l_create_audit_rec.OLD_COMPONENT_VERSION := l_audit_rec.OLD_COMPONENT_VERSION  ;
        l_create_audit_rec.COMPONENT_VERSION := l_audit_rec.COMPONENT_VERSION  ;
        l_cov_update := 1;
      elsif NVL(l_audit_rec.CHANGE_COMP_VER_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_COMP_VER_FLAG := 'N';
        if l_cov_update >0 then
          l_create_audit_rec.COMPONENT_VERSION := l_create_audit_rec.OLD_COMPONENT_VERSION ;
          l_create_audit_rec.OLD_COMPONENT_VERSION := l_audit_rec.OLD_COMPONENT_VERSION ;
          l_cov_update := 0;
        else
          l_create_audit_rec.OLD_COMPONENT_VERSION := l_create_audit_rec.COMPONENT_VERSION ;
        end if;
      end if;

      if l_audit_rec.CHANGE_SUBCOMP_VER_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
        l_create_audit_rec.OLD_SUBCOMPONENT_VERSION := l_audit_rec.OLD_SUBCOMPONENT_VERSION   ;
        l_create_audit_rec.SUBCOMPONENT_VERSION := l_audit_rec.SUBCOMPONENT_VERSION   ;
        l_scv_update := 1;
      elsif NVL(l_audit_rec.CHANGE_SUBCOMP_VER_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG := 'N';
        if l_scv_update >0 then
          l_create_audit_rec.SUBCOMPONENT_VERSION := l_create_audit_rec.OLD_SUBCOMPONENT_VERSION ;
          l_create_audit_rec.OLD_SUBCOMPONENT_VERSION := l_audit_rec.OLD_SUBCOMPONENT_VERSION ;
          l_scv_update := 0;
        else
          l_create_audit_rec.OLD_SUBCOMPONENT_VERSION := l_create_audit_rec.SUBCOMPONENT_VERSION ;
        end if;
      end if;

      if l_audit_rec.CHANGE_PRODUCT_REVISION_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG := 'Y';
        l_create_audit_rec.OLD_PRODUCT_REVISION := l_audit_rec.OLD_PRODUCT_REVISION  ;
        l_create_audit_rec.PRODUCT_REVISION := l_audit_rec.PRODUCT_REVISION  ;
        l_prv_update := 1;
      elsif NVL(l_audit_rec.CHANGE_PRODUCT_REVISION_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG := 'N';
        if l_prv_update >0 then
          l_create_audit_rec.PRODUCT_REVISION := l_create_audit_rec.OLD_PRODUCT_REVISION ;
          l_create_audit_rec.OLD_PRODUCT_REVISION := l_audit_rec.OLD_PRODUCT_REVISION ;
          l_prv_update := 0;
        else
          l_create_audit_rec.OLD_PRODUCT_REVISION := l_create_audit_rec.PRODUCT_REVISION ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INVENTORY_ITEM_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG := 'Y';
        l_create_audit_rec.OLD_INVENTORY_ITEM_ID := l_audit_rec.OLD_INVENTORY_ITEM_ID          ;
        l_create_audit_rec.INVENTORY_ITEM_ID := l_audit_rec.INVENTORY_ITEM_ID          ;
        l_inv_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INVENTORY_ITEM_FLAG,'N') = 'N' then
        l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG := 'N';
        if l_inv_update >0 then
          l_create_audit_rec.INVENTORY_ITEM_ID := l_create_audit_rec.OLD_INVENTORY_ITEM_ID ;
          l_create_audit_rec.OLD_INVENTORY_ITEM_ID := l_audit_rec.OLD_INVENTORY_ITEM_ID ;
          l_inv_update := 0;
        else
          l_create_audit_rec.OLD_INVENTORY_ITEM_ID := l_create_audit_rec.INVENTORY_ITEM_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_INV_ORGANIZATION_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG := 'Y';
        l_create_audit_rec.OLD_INV_ORGANIZATION_ID := l_audit_rec.OLD_INV_ORGANIZATION_ID     ;
        l_create_audit_rec.INV_ORGANIZATION_ID := l_audit_rec.INV_ORGANIZATION_ID     ;
        l_ino_update := 1;
      elsif NVL(l_audit_rec.CHANGE_INV_ORGANIZATION_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG := 'N';
        if l_ino_update >0 then
          l_create_audit_rec.INV_ORGANIZATION_ID := l_create_audit_rec.OLD_INV_ORGANIZATION_ID ;
          l_create_audit_rec.OLD_INV_ORGANIZATION_ID := l_audit_rec.OLD_INV_ORGANIZATION_ID ;
          l_ino_update := 0;
        else
          l_create_audit_rec.OLD_INV_ORGANIZATION_ID := l_create_audit_rec.INV_ORGANIZATION_ID ;
        end if;
      end if;

      if l_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG = 'Y' then
        l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG := 'Y';
        l_create_audit_rec.OLD_PRIMARY_CONTACT_ID := l_audit_rec.OLD_PRIMARY_CONTACT_ID  ;
        l_create_audit_rec.PRIMARY_CONTACT_ID := l_audit_rec.PRIMARY_CONTACT_ID  ;
        l_pci_update := 1;
      elsif NVL(l_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG, 'N') = 'N' then
        l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG := 'N';
        if l_pci_update >0 then
          l_create_audit_rec.PRIMARY_CONTACT_ID := l_create_audit_rec.OLD_PRIMARY_CONTACT_ID ;
          l_create_audit_rec.OLD_PRIMARY_CONTACT_ID := l_audit_rec.OLD_PRIMARY_CONTACT_ID ;
          l_pci_update := 0;
        else
          l_create_audit_rec.OLD_PRIMARY_CONTACT_ID := l_create_audit_rec.PRIMARY_CONTACT_ID ;
        end if;
      end if;
    end loop;
    close c_sr_audit;

-- Added code to fetch the close_flag for populating the Close_date for
-- the record having the upgrade_flag_for_create as 'Y'.
  BEGIN
    OPEN c_close_flag(l_create_audit_rec.INCIDENT_STATUS_ID);
    FETCH c_close_flag INTO l_create_flag_close_date;
    CLOSE c_close_flag;
    IF (NVL(l_create_flag_close_date,'N') = 'N') THEN
      l_create_audit_rec.CLOSE_DATE := NULL;
      l_create_audit_rec.STATUS_FLAG := 'O';
    ELSE
      l_create_audit_rec.CLOSE_DATE := l_create_audit_rec.CREATION_DATE;
      l_create_audit_rec.STATUS_FLAG := 'C';
    END IF;
    OPEN c_close_flag(l_create_audit_rec.OLD_INCIDENT_STATUS_ID);
    FETCH c_close_flag INTO l_create_flag_close_date;
    CLOSE c_close_flag;
    IF (NVL(l_create_flag_close_date,'N') = 'N') THEN
      l_create_audit_rec.OLD_CLOSE_DATE := NULL;
      l_create_audit_rec.OLD_STATUS_FLAG := 'O';
    ELSE
      l_create_audit_rec.OLD_CLOSE_DATE := l_create_audit_rec.CREATION_DATE;
      l_create_audit_rec.OLD_STATUS_FLAG := 'C';
    END IF;
-- Added this to populate the G_MISS_DATE in some records
     IF (l_create_audit_rec.OWNER_ASSIGNED_TIME > SYSDATE OR
         l_create_audit_rec.OWNER_ASSIGNED_TIME = FND_API.G_MISS_DATE) THEN
       l_create_audit_rec.OWNER_ASSIGNED_TIME := l_create_audit_rec.creation_date;
     END IF;

     IF (l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME > SYSDATE OR
         l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME = FND_API.G_MISS_DATE) THEN
       l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_create_audit_rec.creation_date;
     END IF;

     if (l_create_audit_rec.CLOSE_DATE > sysdate) then
       l_create_audit_rec.CLOSE_DATE := l_create_audit_rec.creation_date;
     end if;

    Update cs_incidents_audit_b
    set    INCIDENT_STATUS_ID = decode(l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_STATUS_ID,l_create_audit_rec.INCIDENT_STATUS_ID),
         CHANGE_INCIDENT_STATUS_FLAG = decode(l_create_audit_rec.INCIDENT_STATUS_ID,NULL,'N','Y'),
         INCIDENT_TYPE_ID  = decode(l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_TYPE_ID,l_create_audit_rec.INCIDENT_TYPE_ID),
        CHANGE_INCIDENT_TYPE_FLAG = decode(l_create_audit_rec.INCIDENT_TYPE_ID,NULL,'N','Y'),
        INCIDENT_URGENCY_ID    = decode(l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_URGENCY_ID,l_create_audit_rec.INCIDENT_URGENCY_ID),
        CHANGE_INCIDENT_URGENCY_FLAG = decode(l_create_audit_rec.INCIDENT_URGENCY_ID,NULL,'N','Y'),
        INCIDENT_SEVERITY_ID    = decode(l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID,l_create_audit_rec.INCIDENT_SEVERITY_ID),
        CHANGE_INCIDENT_SEVERITY_FLAG = decode(l_create_audit_rec.INCIDENT_SEVERITY_ID,NULL,'N','Y'),
        RESPONSIBLE_GROUP_ID     = decode(l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG,'Y',l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID,l_create_audit_rec.RESPONSIBLE_GROUP_ID),
        CHANGE_RESPONSIBLE_GROUP_FLAG = decode(l_create_audit_rec.RESPONSIBLE_GROUP_ID,NULL,'N','Y'),
        INCIDENT_OWNER_ID        = decode(l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_OWNER_ID,l_create_audit_rec.INCIDENT_OWNER_ID),
        CHANGE_INCIDENT_OWNER_FLAG = decode(decode(l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_OWNER_ID,l_create_audit_rec.INCIDENT_OWNER_ID),NULL,'N','Y'),
        EXPECTED_RESOLUTION_DATE= decode(l_create_audit_rec.CHANGE_RESOLUTION_FLAG,'Y',l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE,l_create_audit_rec.EXPECTED_RESOLUTION_DATE),
        CHANGE_RESOLUTION_FLAG = decode(decode(l_create_audit_rec.CHANGE_RESOLUTION_FLAG,'Y',l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE,l_create_audit_rec.EXPECTED_RESOLUTION_DATE),NULL,'N','Y'),
        GROUP_ID            = decode(l_create_audit_rec.CHANGE_GROUP_FLAG,'Y',l_create_audit_rec.OLD_GROUP_ID,l_create_audit_rec.GROUP_ID),
        CHANGE_GROUP_FLAG = decode(decode(l_create_audit_rec.CHANGE_GROUP_FLAG,'Y',l_create_audit_rec.OLD_GROUP_ID,l_create_audit_rec.GROUP_ID),NULL,'N','Y'),
         OBLIGATION_DATE  = decode(l_create_audit_rec.CHANGE_OBLIGATION_FLAG,'Y',l_create_audit_rec.OLD_OBLIGATION_DATE,l_create_audit_rec.OBLIGATION_DATE) ,
        CHANGE_OBLIGATION_FLAG = decode(decode(l_create_audit_rec.CHANGE_OBLIGATION_FLAG,'Y',l_create_audit_rec.OLD_OBLIGATION_DATE,l_create_audit_rec.OBLIGATION_DATE),NULL,'N','Y'),
        SITE_ID                = decode(l_create_audit_rec.CHANGE_SITE_FLAG,'Y',l_create_audit_rec.OLD_SITE_ID,l_create_audit_rec.SITE_ID),
        CHANGE_SITE_FLAG = decode(decode(l_create_audit_rec.CHANGE_SITE_FLAG,'Y',l_create_audit_rec.OLD_SITE_ID,l_create_audit_rec.SITE_ID),NULL,'N','Y'),
        BILL_TO_CONTACT_ID   = decode(l_create_audit_rec.CHANGE_BILL_TO_FLAG,'Y',l_create_audit_rec.OLD_BILL_TO_CONTACT_ID,l_create_audit_rec.BILL_TO_CONTACT_ID) ,
        CHANGE_BILL_TO_FLAG = decode(decode(l_create_audit_rec.CHANGE_BILL_TO_FLAG,'Y',l_create_audit_rec.OLD_BILL_TO_CONTACT_ID,l_create_audit_rec.BILL_TO_CONTACT_ID),NULL,'N','Y'),
        SHIP_TO_CONTACT_ID   = decode(l_create_audit_rec.CHANGE_SHIP_TO_FLAG,'Y',l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID,l_create_audit_rec.SHIP_TO_CONTACT_ID),
        CHANGE_SHIP_TO_FLAG = decode(decode(l_create_audit_rec.CHANGE_SHIP_TO_FLAG,'Y',l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID,l_create_audit_rec.SHIP_TO_CONTACT_ID),NULL,'N','Y'),
        INCIDENT_DATE       = decode(l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_DATE,l_create_audit_rec.INCIDENT_DATE),
        CHANGE_INCIDENT_DATE_FLAG = decode(decode(l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG,'Y',l_create_audit_rec.OLD_INCIDENT_DATE,l_create_audit_rec.INCIDENT_DATE),NULL,'N','Y'),
        CLOSE_DATE               = decode(l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG,'Y',l_create_audit_rec.OLD_CLOSE_DATE,l_create_audit_rec.CLOSE_DATE),
        CHANGE_CLOSE_DATE_FLAG = decode(decode(l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG,'Y',l_create_audit_rec.OLD_CLOSE_DATE,l_create_audit_rec.CLOSE_DATE),NULL,'N','Y'),
        CUSTOMER_PRODUCT_ID   = decode(l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG,'Y',l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID,l_create_audit_rec.CUSTOMER_PRODUCT_ID),
        CHANGE_CUSTOMER_PRODUCT_FLAG = decode(decode(l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG,'Y',l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID,l_create_audit_rec.CUSTOMER_PRODUCT_ID),NULL,'N','Y'),
        PLATFORM_ID           = decode(l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG,'Y',l_create_audit_rec.OLD_PLATFORM_ID,l_create_audit_rec.PLATFORM_ID),
        CHANGE_PLATFORM_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG,'Y',l_create_audit_rec.OLD_PLATFORM_ID,l_create_audit_rec.PLATFORM_ID),NULL,'N','Y'),
        PLATFORM_VERSION_ID     = decode(l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG,'Y',l_create_audit_rec.OLD_PLATFORM_VERSION_ID,l_create_audit_rec.PLATFORM_VERSION_ID),
        CHANGE_PLAT_VER_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG,'Y',l_create_audit_rec.OLD_PLATFORM_VERSION_ID,l_create_audit_rec.PLATFORM_VERSION_ID),NULL,'N','Y'),
        CP_COMPONENT_ID           = decode(l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_COMPONENT_ID,l_create_audit_rec.CP_COMPONENT_ID),
        CHANGE_CP_COMPONENT_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_COMPONENT_ID,l_create_audit_rec.CP_COMPONENT_ID),NULL,'N','Y'),
        CP_COMPONENT_VERSION_ID   = decode(l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID,l_create_audit_rec.CP_COMPONENT_VERSION_ID),
        CHANGE_CP_COMP_VER_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID,l_create_audit_rec.CP_COMPONENT_VERSION_ID),NULL,'N','Y'),
        CP_SUBCOMPONENT_ID      = decode(l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID,l_create_audit_rec.CP_SUBCOMPONENT_ID),
        CHANGE_CP_SUBCOMPONENT_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID,l_create_audit_rec.CP_SUBCOMPONENT_ID),NULL,'N','Y'),
        CP_SUBCOMPONENT_VERSION_ID   = decode(l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID,l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID),
        CHANGE_CP_SUBCOMP_VER_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID,l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID),NULL,'N','Y'),
        LANGUAGE_ID                 = decode(l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG,'Y',l_create_audit_rec.OLD_LANGUAGE_ID,l_create_audit_rec.LANGUAGE_ID),
        CHANGE_LANGUAGE_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG,'Y',l_create_audit_rec.OLD_LANGUAGE_ID,l_create_audit_rec.LANGUAGE_ID),NULL,'N','Y'),
        TERRITORY_ID            = decode(l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG,'Y',l_create_audit_rec.OLD_TERRITORY_ID,l_create_audit_rec.TERRITORY_ID),
        CHANGE_TERRITORY_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG,'Y',l_create_audit_rec.OLD_TERRITORY_ID,l_create_audit_rec.TERRITORY_ID),NULL,'N','Y'),
        CP_REVISION_ID         = decode(l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_REVISION_ID,l_create_audit_rec.CP_REVISION_ID),
        CHANGE_CP_REVISION_ID_FLAG = decode(decode(l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG,'Y',l_create_audit_rec.OLD_CP_REVISION_ID,l_create_audit_rec.CP_REVISION_ID),NULL,'N','Y'),
        INV_ITEM_REVISION        = decode(l_create_audit_rec.CHANGE_INV_ITEM_REVISION,'Y',l_create_audit_rec.OLD_INV_ITEM_REVISION,l_create_audit_rec.INV_ITEM_REVISION),
        CHANGE_INV_ITEM_REVISION = decode(decode(l_create_audit_rec.CHANGE_INV_ITEM_REVISION,'Y',l_create_audit_rec.OLD_INV_ITEM_REVISION,l_create_audit_rec.INV_ITEM_REVISION),NULL,'N','Y'),
        INV_COMPONENT_ID      = decode(l_create_audit_rec.CHANGE_INV_COMPONENT_ID,'Y',l_create_audit_rec.OLD_INV_COMPONENT_ID,l_create_audit_rec.INV_COMPONENT_ID),
        CHANGE_INV_COMPONENT_ID = decode(decode(l_create_audit_rec.CHANGE_INV_COMPONENT_ID,'Y',l_create_audit_rec.OLD_INV_COMPONENT_ID,l_create_audit_rec.INV_COMPONENT_ID),NULL,'N','Y'),
        INV_COMPONENT_VERSION   = decode(l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION,'Y',l_create_audit_rec.OLD_INV_COMPONENT_VERSION,l_create_audit_rec.INV_COMPONENT_VERSION),
        CHANGE_INV_COMPONENT_VERSION = decode(decode(l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION,'Y',l_create_audit_rec.OLD_INV_COMPONENT_VERSION,l_create_audit_rec.INV_COMPONENT_VERSION),NULL,'N','Y'),
        INV_SUBCOMPONENT_ID     = decode(l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID,'Y',l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID,l_create_audit_rec.INV_SUBCOMPONENT_ID),
        CHANGE_INV_SUBCOMPONENT_ID = decode(decode(l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID,'Y',l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID,l_create_audit_rec.INV_SUBCOMPONENT_ID),NULL,'N','Y'),
        INV_SUBCOMPONENT_VERSION = decode(l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION,'Y',l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION,l_create_audit_rec.INV_SUBCOMPONENT_VERSION),
        CHANGE_INV_SUBCOMP_VERSION = decode(decode(l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION,'Y',l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION,l_create_audit_rec.INV_SUBCOMPONENT_VERSION),NULL,'N','Y'),
        RESOURCE_TYPE            = decode(l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG,'Y',l_create_audit_rec.OLD_RESOURCE_TYPE,l_create_audit_rec.RESOURCE_TYPE),
        CHANGE_RESOURCE_TYPE_FLAG = decode(decode(l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG,'Y',l_create_audit_rec.OLD_RESOURCE_TYPE,l_create_audit_rec.RESOURCE_TYPE),NULL,'N','Y'),
        GROUP_TYPE                = decode(l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG,'Y',l_create_audit_rec.OLD_GROUP_TYPE,l_create_audit_rec.GROUP_TYPE),
        CHANGE_GROUP_TYPE_FLAG = decode(decode(l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG,'Y',l_create_audit_rec.OLD_GROUP_TYPE,l_create_audit_rec.GROUP_TYPE),NULL,'N','Y'),
        OWNER_ASSIGNED_TIME= decode(l_create_audit_rec.change_assigned_time_flag,'Y',l_create_audit_rec.creation_date,l_create_audit_rec.owner_assigned_time),
        CHANGE_ASSIGNED_TIME_FLAG = decode(decode(l_create_audit_rec.change_assigned_time_flag,'Y',l_create_audit_rec.creation_date,l_create_audit_rec.owner_assigned_time),NULL,'N','Y'),
        INVENTORY_ITEM_ID = decode(l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG,'Y',l_create_audit_rec.OLD_INVENTORY_ITEM_ID,l_create_audit_rec.INVENTORY_ITEM_ID) ,
        CHANGE_INVENTORY_ITEM_FLAG = decode(decode(l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG,'Y',l_create_audit_rec.OLD_INVENTORY_ITEM_ID,l_create_audit_rec.INVENTORY_ITEM_ID),NULL,'N','Y'),
        INV_ORGANIZATION_ID = decode(l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG,'Y',l_create_audit_rec.OLD_INV_ORGANIZATION_ID,l_create_audit_rec.INV_ORGANIZATION_ID),
        CHANGE_INV_ORGANIZATION_FLAG = decode(decode(l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG,'Y',l_create_audit_rec.OLD_INV_ORGANIZATION_ID,l_create_audit_rec.INV_ORGANIZATION_ID),NULL,'N','Y'),
        STATUS_FLAG = decode(l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG,'Y',l_create_audit_rec.OLD_STATUS_FLAG,l_create_audit_rec.STATUS_FLAG),
        CHANGE_STATUS_FLAG = decode(decode(l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG,'Y',l_create_audit_rec.OLD_STATUS_FLAG,l_create_audit_rec.STATUS_FLAG),NULL,'N','Y'),
        UPGRADE_FLAG_FOR_CREATE = 'X',
        updated_entity_code     = 'SR_HEADER'
    WHERE  incident_id = l_create_audit_rec.incident_id
    AND    upgrade_flag_for_create = 'Y';

  END;

    loop_cnt := 0;
    open c_sr_audit_asc(l_request_id);
    LOOP
      loop_cnt := loop_cnt +1;
      FETCH c_sr_audit_asc into l_audit_rec;
      EXIT WHEN c_sr_audit_asc%NOTFOUND;
      l_create_record := 'N';
      --jen1
      if (loop_cnt =1 and
         l_audit_rec.CHANGE_INCIDENT_STATUS_FLAG ='Y' and
         l_audit_rec.INCIDENT_STATUS_ID is not null and
         l_audit_rec.OLD_INCIDENT_STATUS_ID is null and
         l_audit_rec.CHANGE_INCIDENT_TYPE_FLAG = 'Y' and
         l_audit_rec.INCIDENT_TYPE_ID is not null and
         l_audit_rec.OLD_INCIDENT_TYPE_ID is null and
         l_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG = 'Y' and
         l_audit_rec.INCIDENT_SEVERITY_ID is not null and
         l_audit_rec.OLD_INCIDENT_SEVERITY_ID is null) then
        l_create_record := 'Y';
      end if;
      --jen1
      if l_audit_rec.CHANGE_INCIDENT_STATUS_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_STATUS_ID := l_audit_rec.INCIDENT_STATUS_ID ;
        l_create_audit_rec.OLD_INCIDENT_STATUS_ID := l_audit_rec.OLD_INCIDENT_STATUS_ID ;
        l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG := 'Y';
        if (l_audit_rec.old_incident_status_id is null and
            loop_cnt > 1) then
          l_create_audit_rec.OLD_INCIDENT_STATUS_ID := l_create_audit_rec.INCIDENT_STATUS_ID;
          l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG := 'N';
        end if;
        OPEN c_close_flag(l_audit_rec.INCIDENT_STATUS_ID);
        FETCH c_close_flag INTO l_new_close_flag;
        CLOSE c_close_flag;
        OPEN c_close_flag(l_audit_rec.OLD_INCIDENT_STATUS_ID);
        FETCH c_close_flag INTO l_old_close_flag;
        CLOSE c_close_flag;

        If (nvl(l_new_close_flag,'N') = 'N') THEN
          If (nvl(l_old_close_flag,'N') = 'N') THEN
            l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'N';
            l_create_audit_rec.OLD_CLOSE_DATE := l_create_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CLOSE_DATE := l_create_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CHANGE_STATUS_FLAG := 'N';
            l_create_audit_rec.STATUS_FLAG := 'O';
            l_create_audit_rec.OLD_STATUS_FLAG := 'O';
          Else
            l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'Y';
            l_create_audit_rec.OLD_CLOSE_DATE := l_create_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CLOSE_DATE := NULL;
            l_create_audit_rec.CHANGE_STATUS_FLAG := 'Y';
            l_create_audit_rec.STATUS_FLAG := 'O';
            l_create_audit_rec.OLD_STATUS_FLAG := 'C';
          End If;
        Else
          IF (nvl(l_old_close_flag, 'N') = 'N') THEN
            l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'Y';
            l_create_audit_rec.OLD_CLOSE_DATE := l_create_audit_rec.OLD_CLOSE_DATE;
            l_create_audit_rec.CLOSE_DATE := l_audit_rec.creation_date;
            l_create_audit_rec.CHANGE_STATUS_FLAG := 'Y';
            l_create_audit_rec.STATUS_FLAG := 'C';
            l_create_audit_rec.OLD_STATUS_FLAG := 'O';
          ELSE
            l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'Y';
            l_create_audit_rec.OLD_CLOSE_DATE := l_create_audit_rec.OLD_CLOSE_DATE;
            l_create_audit_rec.CLOSE_DATE := l_audit_rec.creation_date;
            l_create_audit_rec.CHANGE_STATUS_FLAG := 'Y';
            l_create_audit_rec.STATUS_FLAG := 'C';
            l_create_audit_rec.OLD_STATUS_FLAG := 'C';
          END IF;
        End IF;
      ELSE
        l_create_audit_rec.OLD_INCIDENT_STATUS_ID := l_create_audit_rec.INCIDENT_STATUS_ID ;
        l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG := 'N';
        OPEN c_close_flag(l_create_audit_rec.OLD_INCIDENT_STATUS_ID);
        FETCH c_close_flag INTO l_new_close_flag;
        CLOSE c_close_flag;
        If (nvl(l_new_close_flag,'N') = 'N') THEN
            l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'N';
            l_create_audit_rec.OLD_CLOSE_DATE := l_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CLOSE_DATE := l_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CHANGE_STATUS_FLAG := 'N';
            l_create_audit_rec.STATUS_FLAG := 'O';
            l_create_audit_rec.OLD_STATUS_FLAG := 'O';
          Else
            l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'N';
            l_create_audit_rec.OLD_CLOSE_DATE := l_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CLOSE_DATE := l_audit_rec.CLOSE_DATE;
            l_create_audit_rec.CHANGE_STATUS_FLAG := 'N';
            l_create_audit_rec.STATUS_FLAG := 'C';
            l_create_audit_rec.OLD_STATUS_FLAG := 'C';
          End If;
      end if;

      -- Added code for populating the Close_Date and Status_Flag if the
      -- count is 1.
      IF (loop_cnt = 1 AND
          l_create_audit_rec.OLD_INCIDENT_STATUS_ID IS NULL) THEN
        OPEN c_close_flag(l_audit_rec.INCIDENT_STATUS_ID);
        FETCH c_close_flag INTO l_new_close_flag;
        CLOSE c_close_flag;
        IF (NVL(l_new_close_flag,'N') = 'N') THEN
          l_create_audit_rec.CHANGE_STATUS_FLAG := 'Y';
          l_create_audit_rec.STATUS_FLAG := 'O';
          l_create_audit_rec.OLD_STATUS_FLAG := NULL;
        ELSE
          l_create_audit_rec.CHANGE_STATUS_FLAG := 'Y';
          l_create_audit_rec.STATUS_FLAG := 'C';
          l_create_audit_rec.OLD_STATUS_FLAG := NULL;
        END IF;
      END IF;

      --if loop_cnt > 1 then

        if l_audit_rec.CHANGE_INCIDENT_TYPE_FLAG = 'Y' then
          l_create_audit_rec.OLD_INCIDENT_TYPE_ID := l_audit_rec.OLD_INCIDENT_TYPE_ID      ;
          l_create_audit_rec.INCIDENT_TYPE_ID := l_audit_rec.INCIDENT_TYPE_ID;
          l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG := 'Y';
         if (l_audit_rec.OLD_INCIDENT_TYPE_ID is null and
             loop_cnt >1) then
           l_create_audit_rec.OLD_INCIDENT_TYPE_ID := l_create_audit_rec.INCIDENT_TYPE_ID;
           l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG := 'N';
         end if;
        else
          l_create_audit_rec.OLD_INCIDENT_TYPE_ID := l_create_audit_rec.INCIDENT_TYPE_ID      ;
          l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG := 'N';
        end if;

        if l_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG := 'Y';
          l_create_audit_rec.OLD_INCIDENT_URGENCY_ID := l_audit_rec.OLD_INCIDENT_URGENCY_ID ;
          l_create_audit_rec.INCIDENT_URGENCY_ID := l_audit_rec.INCIDENT_URGENCY_ID ;
        else
          l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG := 'N';
          l_create_audit_rec.OLD_INCIDENT_URGENCY_ID := l_create_audit_rec.INCIDENT_URGENCY_ID ;
        end if;

        if l_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG = 'Y' then
            l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID := l_audit_rec.OLD_INCIDENT_SEVERITY_ID;
            l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'Y';
          l_create_audit_rec.INCIDENT_SEVERITY_ID := l_audit_rec.INCIDENT_SEVERITY_ID   ;
         if (l_audit_rec.OLD_INCIDENT_SEVERITY_ID is null and
             loop_cnt >1) then
           l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID := l_create_audit_rec.INCIDENT_SEVERITY_ID;
           l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'N';
         end if;
        else
          l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'N';
          l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID := l_create_audit_rec.INCIDENT_SEVERITY_ID   ;
        end if;

        if l_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG := 'Y';
          l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID := l_audit_rec.OLD_RESPONSIBLE_GROUP_ID   ;
          l_create_audit_rec.RESPONSIBLE_GROUP_ID := l_audit_rec.RESPONSIBLE_GROUP_ID   ;
        end if;

        if nvl(l_audit_rec.CHANGE_INCIDENT_OWNER_FLAG,'N') = 'Y' then
          l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
          l_create_audit_rec.OLD_INCIDENT_OWNER_ID := l_audit_rec.OLD_INCIDENT_OWNER_ID       ;
          l_create_audit_rec.INCIDENT_OWNER_ID := l_audit_rec.INCIDENT_OWNER_ID;
          l_create_audit_rec.OLD_RESOURCE_TYPE := l_audit_rec.OLD_RESOURCE_TYPE;
          l_create_audit_rec.RESOURCE_TYPE := l_audit_rec.RESOURCE_TYPE ;
          l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'Y';
          l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_create_audit_rec.old_OWNER_ASSIGNED_TIME;
          l_create_audit_rec.OWNER_ASSIGNED_TIME := l_audit_rec.CREATION_DATE;
          l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG := 'Y';
          if (l_create_record = 'Y' and
             l_audit_rec.OWNER_ASSIGNED_TIME is null and
             l_audit_rec.OLD_OWNER_ASSIGNED_TIME is null and
             l_create_audit_rec.OWNER_ASSIGNED_TIME is not null and
             l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG = 'Y') then
            l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := null;
          end if;
        else
          l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG := 'N';
          l_create_audit_rec.OLD_INCIDENT_OWNER_ID := l_create_audit_rec.INCIDENT_OWNER_ID       ;
          l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_create_audit_rec.OWNER_ASSIGNED_TIME;
          l_create_audit_rec.OLD_RESOURCE_TYPE := l_create_audit_rec.RESOURCE_TYPE;
          l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'N';
          if (l_create_record = 'Y' --and
            --l_audit_rec.RESOURCE_TYPE is null and
            --l_audit_rec.OLD_RESOURCE_TYPE is null and
            --l_create_audit_rec.RESOURCE_TYPE is not null
             ) then
            l_create_audit_rec.OLD_RESOURCE_TYPE := null;
            l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'Y';
          end if;
          l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG := 'N';
          if (l_create_record = 'Y' and
            l_audit_rec.INCIDENT_OWNER_ID is null and
            l_audit_rec.OLD_INCIDENT_OWNER_ID is null and
            l_create_audit_rec.INCIDENT_OWNER_ID is not null) then
            l_create_audit_rec.OLD_INCIDENT_OWNER_ID := null;
            l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
            l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := null;
            l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG := 'Y';
          end if;
        end if;
        if l_audit_rec.CHANGE_RESOLUTION_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_RESOLUTION_FLAG := 'Y';
          l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE := l_audit_rec.OLD_EXPECTED_RESOLUTION_DATE  ;
          l_create_audit_rec.EXPECTED_RESOLUTION_DATE := l_audit_rec.EXPECTED_RESOLUTION_DATE  ;
        else
          l_create_audit_rec.CHANGE_RESOLUTION_FLAG := 'N';
          l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE := l_create_audit_rec.EXPECTED_RESOLUTION_DATE;
          if (l_create_record = 'Y' and
             l_audit_rec.EXPECTED_RESOLUTION_DATE is null and
             l_audit_rec.OLD_EXPECTED_RESOLUTION_DATE is null and
             l_create_audit_rec.EXPECTED_RESOLUTION_DATE is not null) then
            l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE := null;
            l_create_audit_rec.CHANGE_RESOLUTION_FLAG := 'Y';
          end if;
        end if;

        if nvl(l_audit_rec.CHANGE_GROUP_FLAG, 'N') = 'Y' then
          l_create_audit_rec.CHANGE_GROUP_FLAG := 'Y';
       	  l_create_audit_rec.OLD_GROUP_ID := l_audit_rec.OLD_GROUP_ID        ;
	  l_create_audit_rec.GROUP_ID := l_audit_rec.GROUP_ID        ;
	  l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG := 'Y';
	  l_create_audit_rec.OLD_GROUP_TYPE := l_audit_rec.OLD_GROUP_TYPE;
	  l_create_audit_rec.GROUP_TYPE := l_audit_rec.GROUP_TYPE;
          if (l_create_record = 'Y' ) then
            l_create_audit_rec.OLD_GROUP_TYPE := NULL;
          end if;
        else
          l_create_audit_rec.CHANGE_GROUP_FLAG := 'N';
	  l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG := 'N';
	  l_create_audit_rec.OLD_GROUP_ID := l_create_audit_rec.GROUP_ID;
	  l_create_audit_rec.OLD_GROUP_TYPE := l_create_audit_rec.GROUP_TYPE;
	  if (l_create_record = 'Y' --and
	    --l_audit_rec.GROUP_TYPE is null and
	    --l_audit_rec.OLD_GROUP_TYPE is null and
	    --l_create_audit_rec.GROUP_TYPE is not null
            ) then
            l_create_audit_rec.OLD_GROUP_TYPE := null;
	    l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG := 'Y';
	  end if;
          if (l_create_record = 'Y' and
	    l_audit_rec.GROUP_ID is null and
	    l_audit_rec.OLD_GROUP_ID is null and
	    l_create_audit_rec.GROUP_ID is not null) then
	    l_create_audit_rec.OLD_GROUP_ID := null;
	    l_create_audit_rec.CHANGE_GROUP_FLAG := 'Y';
	  end if;
        end if;

        if l_audit_rec.CHANGE_OBLIGATION_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_OBLIGATION_FLAG := 'Y';
          l_create_audit_rec.OLD_OBLIGATION_DATE := l_audit_rec.OLD_OBLIGATION_DATE ;
          l_create_audit_rec.OBLIGATION_DATE := l_audit_rec.OBLIGATION_DATE ;
        else
          l_create_audit_rec.CHANGE_OBLIGATION_FLAG := 'N';
          l_create_audit_rec.OLD_OBLIGATION_DATE := l_create_audit_rec.OBLIGATION_DATE;
          if (l_create_record = 'Y' and
             l_audit_rec.OBLIGATION_DATE is null and
             l_audit_rec.OLD_OBLIGATION_DATE is null and
             l_create_audit_rec.OBLIGATION_DATE is not null) then
            l_create_audit_rec.OLD_OBLIGATION_DATE := null;
            l_create_audit_rec.CHANGE_OBLIGATION_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_SITE_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_SITE_FLAG := 'Y';
          l_create_audit_rec.OLD_SITE_ID := l_audit_rec.OLD_SITE_ID ;
          l_create_audit_rec.SITE_ID := l_audit_rec.SITE_ID ;
        else
          l_create_audit_rec.CHANGE_SITE_FLAG := 'N';
          l_create_audit_rec.OLD_SITE_ID := l_create_audit_rec.SITE_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.SITE_ID is null and
             l_audit_rec.OLD_SITE_ID is null and
             l_create_audit_rec.SITE_ID is not null) then
            l_create_audit_rec.OLD_SITE_ID := null;
            l_create_audit_rec.CHANGE_SITE_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_BILL_TO_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_BILL_TO_FLAG := 'Y';
          l_create_audit_rec.OLD_BILL_TO_CONTACT_ID := l_audit_rec.OLD_BILL_TO_CONTACT_ID  ;
          l_create_audit_rec.BILL_TO_CONTACT_ID := l_audit_rec.BILL_TO_CONTACT_ID  ;
        else
          l_create_audit_rec.CHANGE_BILL_TO_FLAG := 'N';
          l_create_audit_rec.OLD_BILL_TO_CONTACT_ID := l_create_audit_rec.BILL_TO_CONTACT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.BILL_TO_CONTACT_ID is null and
             l_audit_rec.OLD_BILL_TO_CONTACT_ID is null and
             l_create_audit_rec.BILL_TO_CONTACT_ID is not null) then
            l_create_audit_rec.OLD_BILL_TO_CONTACT_ID := null;
            l_create_audit_rec.CHANGE_BILL_TO_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_SHIP_TO_FLAG = 'Y' then
         l_create_audit_rec.CHANGE_SHIP_TO_FLAG := 'Y';
         l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID := l_audit_rec.OLD_SHIP_TO_CONTACT_ID ;
         l_create_audit_rec.SHIP_TO_CONTACT_ID := l_audit_rec.SHIP_TO_CONTACT_ID ;
        else
          l_create_audit_rec.CHANGE_SHIP_TO_FLAG := 'N';
          l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID := l_create_audit_rec.SHIP_TO_CONTACT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.SHIP_TO_CONTACT_ID is null and
             l_audit_rec.OLD_SHIP_TO_CONTACT_ID is null and
             l_create_audit_rec.SHIP_TO_CONTACT_ID is not null) then
            l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID := null;
            l_create_audit_rec.CHANGE_SHIP_TO_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INCIDENT_DATE_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG := 'Y';
          l_create_audit_rec.OLD_INCIDENT_DATE := l_audit_rec.OLD_INCIDENT_DATE   ;
          l_create_audit_rec.INCIDENT_DATE := l_audit_rec.INCIDENT_DATE   ;
        else
          l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG := 'N';
          if (l_create_record = 'Y' and
             l_audit_rec.INCIDENT_DATE is null and
             l_audit_rec.OLD_INCIDENT_DATE is null and
             l_create_audit_rec.INCIDENT_DATE is not null) then
            l_create_audit_rec.OLD_INCIDENT_DATE := null;
            l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG := 'Y';
          end if;
          l_create_audit_rec.OLD_INCIDENT_DATE := l_create_audit_rec.INCIDENT_DATE;
        end if;

        if l_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'Y';
          l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID := l_audit_rec.OLD_CUSTOMER_PRODUCT_ID ;
          l_create_audit_rec.CUSTOMER_PRODUCT_ID := l_audit_rec.CUSTOMER_PRODUCT_ID ;
        else
          l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'N';
          l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID := l_create_audit_rec.CUSTOMER_PRODUCT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.CUSTOMER_PRODUCT_ID is null and
             l_audit_rec.OLD_CUSTOMER_PRODUCT_ID is null and
             l_create_audit_rec.CUSTOMER_PRODUCT_ID is not null) then
            l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID := null;
            l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_PLATFORM_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_PLATFORM_ID := l_audit_rec.OLD_PLATFORM_ID   ;
          l_create_audit_rec.PLATFORM_ID := l_audit_rec.PLATFORM_ID   ;
        else
          l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG := 'N';
          l_create_audit_rec.OLD_PLATFORM_ID := l_create_audit_rec.PLATFORM_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.PLATFORM_ID is null and
             l_audit_rec.OLD_PLATFORM_ID is null and
             l_create_audit_rec.PLATFORM_ID is not null) then
            l_create_audit_rec.OLD_PLATFORM_ID := null;
            l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_PLAT_VER_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_PLATFORM_VERSION_ID := l_audit_rec.OLD_PLATFORM_VERSION_ID      ;
          l_create_audit_rec.PLATFORM_VERSION_ID := l_audit_rec.PLATFORM_VERSION_ID      ;
        else
          l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG := 'N';
          l_create_audit_rec.OLD_PLATFORM_VERSION_ID := l_create_audit_rec.PLATFORM_VERSION_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.PLATFORM_VERSION_ID is null and
             l_audit_rec.OLD_PLATFORM_VERSION_ID is null and
             l_create_audit_rec.PLATFORM_VERSION_ID is not null) then
            l_create_audit_rec.OLD_PLATFORM_VERSION_ID := null;
            l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_CP_COMPONENT_ID := l_audit_rec.OLD_CP_COMPONENT_ID       ;
          l_create_audit_rec.CP_COMPONENT_ID := l_audit_rec.CP_COMPONENT_ID       ;
        else
          l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'N';
          l_create_audit_rec.OLD_CP_COMPONENT_ID := l_create_audit_rec.CP_COMPONENT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.CP_COMPONENT_ID is null and
             l_audit_rec.OLD_CP_COMPONENT_ID is null and
             l_create_audit_rec.CP_COMPONENT_ID is not null) then
            l_create_audit_rec.OLD_CP_COMPONENT_ID := null;
            l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID := l_audit_rec.OLD_CP_COMPONENT_VERSION_ID;
          l_create_audit_rec.CP_COMPONENT_VERSION_ID := l_audit_rec.CP_COMPONENT_VERSION_ID;
        else
          l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'N';
          l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID := l_create_audit_rec.CP_COMPONENT_VERSION_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.CP_COMPONENT_VERSION_ID is null and
             l_audit_rec.OLD_CP_COMPONENT_VERSION_ID is null and
             l_create_audit_rec.CP_COMPONENT_VERSION_ID is not null) then
            l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID := null;
            l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_ID    ;
          l_create_audit_rec.CP_SUBCOMPONENT_ID := l_audit_rec.CP_SUBCOMPONENT_ID    ;
        else
          l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG := 'N';
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID := l_create_audit_rec.CP_SUBCOMPONENT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.CP_SUBCOMPONENT_ID is null and
             l_audit_rec.OLD_CP_SUBCOMPONENT_ID is null and
             l_create_audit_rec.CP_SUBCOMPONENT_ID is not null) then
            l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID := null;
            l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ;
          l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID := l_audit_rec.CP_SUBCOMPONENT_VERSION_ID ;
        else
          l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'N';
          l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID := l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.CP_SUBCOMPONENT_VERSION_ID is null and
             l_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID is null and
             l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID is not null) then
            l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID := null;
            l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_LANGUAGE_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_LANGUAGE_ID := l_audit_rec.OLD_LANGUAGE_ID             ;
          l_create_audit_rec.LANGUAGE_ID := l_audit_rec.LANGUAGE_ID  ;
        else
          l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG := 'N';
          l_create_audit_rec.OLD_LANGUAGE_ID := l_create_audit_rec.LANGUAGE_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.LANGUAGE_ID is null and
             l_audit_rec.OLD_LANGUAGE_ID is null and
             l_create_audit_rec.LANGUAGE_ID is not null) then
            l_create_audit_rec.OLD_LANGUAGE_ID := null;
            l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_TERRITORY_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_TERRITORY_ID := l_audit_rec.OLD_TERRITORY_ID ;
          l_create_audit_rec.TERRITORY_ID := l_audit_rec.TERRITORY_ID  ;
        else
          l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG := 'N';
          l_create_audit_rec.OLD_TERRITORY_ID :=l_create_audit_rec.TERRITORY_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.TERRITORY_ID is null and
             l_audit_rec.OLD_TERRITORY_ID is null and
             l_create_audit_rec.TERRITORY_ID is not null) then
            l_create_audit_rec.OLD_TERRITORY_ID := null;
            l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_CP_REVISION_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_CP_REVISION_ID := l_audit_rec.OLD_CP_REVISION_ID     ;
          l_create_audit_rec.CP_REVISION_ID := l_audit_rec.CP_REVISION_ID     ;
        else
          l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG := 'N';
          l_create_audit_rec.OLD_CP_REVISION_ID := l_create_audit_rec.CP_REVISION_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.CP_REVISION_ID is null and
             l_audit_rec.OLD_CP_REVISION_ID is null and
             l_create_audit_rec.CP_REVISION_ID is not null) then
            l_create_audit_rec.OLD_CP_REVISION_ID := null;
            l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INV_ITEM_REVISION = 'Y' then
          l_create_audit_rec.CHANGE_INV_ITEM_REVISION := 'Y';
          l_create_audit_rec.OLD_INV_ITEM_REVISION := l_audit_rec.OLD_INV_ITEM_REVISION    ;
          l_create_audit_rec.INV_ITEM_REVISION := l_audit_rec.INV_ITEM_REVISION    ;
        else
          l_create_audit_rec.CHANGE_INV_ITEM_REVISION := 'N';
          l_create_audit_rec.OLD_INV_ITEM_REVISION := l_create_audit_rec.INV_ITEM_REVISION;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_ITEM_REVISION is null and
             l_audit_rec.OLD_INV_ITEM_REVISION is null and
             l_create_audit_rec.INV_ITEM_REVISION is not null) then
            l_create_audit_rec.OLD_INV_ITEM_REVISION := null;
            l_create_audit_rec.CHANGE_INV_ITEM_REVISION := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INV_COMPONENT_ID   = 'Y' then
          l_create_audit_rec.CHANGE_INV_COMPONENT_ID := 'Y';
          l_create_audit_rec.OLD_INV_COMPONENT_ID := l_audit_rec.OLD_INV_COMPONENT_ID  ;
          l_create_audit_rec.INV_COMPONENT_ID := l_audit_rec.INV_COMPONENT_ID  ;
        else
          l_create_audit_rec.CHANGE_INV_COMPONENT_ID := 'N';
          l_create_audit_rec.OLD_INV_COMPONENT_ID := l_create_audit_rec.INV_COMPONENT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_COMPONENT_ID is null and
             l_audit_rec.OLD_INV_COMPONENT_ID is null and
             l_create_audit_rec.INV_COMPONENT_ID is not null) then
            l_create_audit_rec.OLD_INV_COMPONENT_ID := null;
            l_create_audit_rec.CHANGE_INV_COMPONENT_ID := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INV_COMPONENT_VERSION   = 'Y' then
          l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION := 'Y';
          l_create_audit_rec.OLD_INV_COMPONENT_VERSION := l_audit_rec.OLD_INV_COMPONENT_VERSION  ;
          l_create_audit_rec.INV_COMPONENT_VERSION := l_audit_rec.INV_COMPONENT_VERSION  ;
        else
          l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION := 'N';
          l_create_audit_rec.OLD_INV_COMPONENT_VERSION := l_create_audit_rec.INV_COMPONENT_VERSION;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_COMPONENT_VERSION is null and
             l_audit_rec.OLD_INV_COMPONENT_VERSION is null and
             l_create_audit_rec.INV_COMPONENT_VERSION is not null) then
            l_create_audit_rec.OLD_INV_COMPONENT_VERSION := null;
            l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INV_SUBCOMPONENT_ID  = 'Y' then
          l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID := 'Y';
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID := l_audit_rec.OLD_INV_SUBCOMPONENT_ID     ;
          l_create_audit_rec.INV_SUBCOMPONENT_ID := l_audit_rec.INV_SUBCOMPONENT_ID     ;
        else
          l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID := 'N';
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID := l_create_audit_rec.INV_SUBCOMPONENT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_SUBCOMPONENT_ID is null and
             l_audit_rec.OLD_INV_SUBCOMPONENT_ID is null and
             l_create_audit_rec.INV_SUBCOMPONENT_ID is not null) then
            l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID := null;
            l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INV_SUBCOMP_VERSION   = 'Y' then
          l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION := 'Y';
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION := l_audit_rec.OLD_INV_SUBCOMPONENT_VERSION  ;
          l_create_audit_rec.INV_SUBCOMPONENT_VERSION := l_audit_rec.INV_SUBCOMPONENT_VERSION  ;
        else
          l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION := 'N';
          l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION := l_create_audit_rec.INV_SUBCOMPONENT_VERSION;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_SUBCOMPONENT_VERSION is null and
             l_audit_rec.OLD_INV_SUBCOMPONENT_VERSION is null and
             l_create_audit_rec.INV_SUBCOMPONENT_VERSION is not null) then
            l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION := null;
            l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'Y';
          l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID := l_audit_rec.OLD_INV_PLATFORM_ORG_ID ;
          l_create_audit_rec.INV_PLATFORM_ORG_ID := l_audit_rec.INV_PLATFORM_ORG_ID ;
        else
          l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'N';
          l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID := l_create_audit_rec.INV_PLATFORM_ORG_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_PLATFORM_ORG_ID is null and
             l_audit_rec.OLD_INV_PLATFORM_ORG_ID is null and
             l_create_audit_rec.INV_PLATFORM_ORG_ID is not null) then
            l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID := null;
            l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_COMP_VER_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_COMP_VER_FLAG := 'Y';
          l_create_audit_rec.OLD_COMPONENT_VERSION := l_audit_rec.OLD_COMPONENT_VERSION  ;
          l_create_audit_rec.COMPONENT_VERSION := l_audit_rec.COMPONENT_VERSION  ;
        else
          l_create_audit_rec.CHANGE_COMP_VER_FLAG := 'N';
          l_create_audit_rec.OLD_COMPONENT_VERSION := l_create_audit_rec.COMPONENT_VERSION;
          if (l_create_record = 'Y' and
             l_audit_rec.COMPONENT_VERSION is null and
             l_audit_rec.OLD_COMPONENT_VERSION is null and
             l_create_audit_rec.COMPONENT_VERSION is not null) then
            l_create_audit_rec.OLD_COMPONENT_VERSION := null;
            l_create_audit_rec.CHANGE_COMP_VER_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_SUBCOMP_VER_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
          l_create_audit_rec.OLD_SUBCOMPONENT_VERSION := l_audit_rec.OLD_SUBCOMPONENT_VERSION   ;
          l_create_audit_rec.SUBCOMPONENT_VERSION := l_audit_rec.SUBCOMPONENT_VERSION   ;
        else
          l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG := 'N';
          l_create_audit_rec.OLD_SUBCOMPONENT_VERSION := l_create_audit_rec.SUBCOMPONENT_VERSION;
          if (l_create_record = 'Y' and
             l_audit_rec.SUBCOMPONENT_VERSION is null and
             l_audit_rec.OLD_SUBCOMPONENT_VERSION is null and
             l_create_audit_rec.SUBCOMPONENT_VERSION is not null) then
            l_create_audit_rec.OLD_SUBCOMPONENT_VERSION := null;
            l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_PRODUCT_REVISION_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG := 'Y';
          l_create_audit_rec.OLD_PRODUCT_REVISION := l_audit_rec.OLD_PRODUCT_REVISION  ;
          l_create_audit_rec.PRODUCT_REVISION := l_audit_rec.PRODUCT_REVISION ;
       else
          l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG := 'N';
          l_create_audit_rec.OLD_PRODUCT_REVISION := l_create_audit_rec.PRODUCT_REVISION;
          if (l_create_record = 'Y' and
             l_audit_rec.PRODUCT_REVISION is null and
             l_audit_rec.OLD_PRODUCT_REVISION is null and
             l_create_audit_rec.PRODUCT_REVISION is not null) then
            l_create_audit_rec.OLD_PRODUCT_REVISION := null;
            l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INVENTORY_ITEM_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG := 'Y';
          l_create_audit_rec.OLD_INVENTORY_ITEM_ID := l_audit_rec.OLD_INVENTORY_ITEM_ID          ;
          l_create_audit_rec.INVENTORY_ITEM_ID := l_audit_rec.INVENTORY_ITEM_ID          ;
        else
          l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG := 'N';
          l_create_audit_rec.OLD_INVENTORY_ITEM_ID := l_create_audit_rec.INVENTORY_ITEM_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.INVENTORY_ITEM_ID is null and
             l_audit_rec.OLD_INVENTORY_ITEM_ID is null and
             l_create_audit_rec.INVENTORY_ITEM_ID is not null) then
            l_create_audit_rec.OLD_INVENTORY_ITEM_ID := null;
            l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_INV_ORGANIZATION_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG := 'Y';
          l_create_audit_rec.OLD_INV_ORGANIZATION_ID := l_audit_rec.OLD_INV_ORGANIZATION_ID     ;
          l_create_audit_rec.INV_ORGANIZATION_ID := l_audit_rec.INV_ORGANIZATION_ID     ;
        else
          l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG := 'N';
          l_create_audit_rec.OLD_INV_ORGANIZATION_ID := l_create_audit_rec.INV_ORGANIZATION_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.INV_ORGANIZATION_ID is null and
             l_audit_rec.OLD_INV_ORGANIZATION_ID is null and
             l_create_audit_rec.INV_ORGANIZATION_ID is not null) then
            l_create_audit_rec.OLD_INV_ORGANIZATION_ID := null;
            l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG := 'Y';
          end if;
        end if;

        if l_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG = 'Y' then
          l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG := 'Y';
          l_create_audit_rec.OLD_PRIMARY_CONTACT_ID := l_audit_rec.OLD_PRIMARY_CONTACT_ID  ;
          l_create_audit_rec.PRIMARY_CONTACT_ID := l_audit_rec.PRIMARY_CONTACT_ID  ;
        else
          l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG := 'N';
          l_create_audit_rec.OLD_PRIMARY_CONTACT_ID := l_create_audit_rec.PRIMARY_CONTACT_ID;
          if (l_create_record = 'Y' and
             l_audit_rec.PRIMARY_CONTACT_ID is null and
             l_audit_rec.OLD_PRIMARY_CONTACT_ID is null and
             l_create_audit_rec.PRIMARY_CONTACT_ID is not null) then
            l_create_audit_rec.OLD_PRIMARY_CONTACT_ID := null;
            l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG := 'Y';
          end if;
        end if;

-- Added this to populate the G_MISS_DATE in some records
     if (l_create_audit_rec.OWNER_ASSIGNED_TIME > sysdate OR
         l_create_audit_rec.OWNER_ASSIGNED_TIME = FND_API.G_MISS_DATE) then
       l_create_audit_rec.OWNER_ASSIGNED_TIME := l_create_audit_rec.creation_date;
     end if;

    if (l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME > sysdate OR
        l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME = FND_API.G_MISS_DATE) then
      l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME := l_create_audit_rec.creation_date;
    end if;

     if (l_create_audit_rec.CLOSE_DATE > sysdate OR
         l_create_audit_rec.CLOSE_DATE = FND_API.G_MISS_DATE) then
       l_create_audit_rec.CLOSE_DATE := l_create_audit_rec.creation_date;
     end if;
    if (l_create_audit_rec.OLD_CLOSE_DATE > sysdate OR
        l_create_audit_rec.OLD_CLOSE_DATE = FND_API.G_MISS_DATE) then
      l_create_audit_rec.old_CLOSE_DATE := l_create_audit_rec.creation_date;
    end if;

     UPDATE cs_incidents_audit_b
       SET LAST_UPDATE_DATE = sysdate,

           INCIDENT_STATUS_ID = l_create_audit_rec.INCIDENT_STATUS_ID,
           OLD_INCIDENT_STATUS_ID = l_create_audit_rec.OLD_INCIDENT_STATUS_ID,
          CHANGE_INCIDENT_STATUS_FLAG = l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG,

           INCIDENT_TYPE_ID  = l_create_audit_rec.INCIDENT_TYPE_ID         ,
      OLD_INCIDENT_TYPE_ID   = l_create_audit_rec.OLD_INCIDENT_TYPE_ID   ,
      CHANGE_INCIDENT_TYPE_FLAG = l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG,

      INCIDENT_URGENCY_ID    = l_create_audit_rec.INCIDENT_URGENCY_ID  ,
      OLD_INCIDENT_URGENCY_ID = l_create_audit_rec.OLD_INCIDENT_URGENCY_ID,
      CHANGE_INCIDENT_URGENCY_FLAG = l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG,

      INCIDENT_SEVERITY_ID    = l_create_audit_rec.INCIDENT_SEVERITY_ID    ,
      OLD_INCIDENT_SEVERITY_ID = l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID  ,
      CHANGE_INCIDENT_SEVERITY_FLAG = l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG,

      RESPONSIBLE_GROUP_ID     = l_create_audit_rec.RESPONSIBLE_GROUP_ID   ,
      OLD_RESPONSIBLE_GROUP_ID = l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID  ,
      CHANGE_RESPONSIBLE_GROUP_FLAG = l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG,

      INCIDENT_OWNER_ID        = l_create_audit_rec.INCIDENT_OWNER_ID    ,
      OLD_INCIDENT_OWNER_ID    = l_create_audit_rec.OLD_INCIDENT_OWNER_ID   ,
      CHANGE_INCIDENT_OWNER_FLAG = l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG,

      EXPECTED_RESOLUTION_DATE= l_create_audit_rec.EXPECTED_RESOLUTION_DATE,
      OLD_EXPECTED_RESOLUTION_DATE = l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE ,
      CHANGE_RESOLUTION_FLAG = l_create_audit_rec.CHANGE_RESOLUTION_FLAG,

      GROUP_ID            = l_create_audit_rec.GROUP_ID  ,
      OLD_GROUP_ID       = l_create_audit_rec.OLD_GROUP_ID ,
      change_group_flag  = l_create_audit_rec.change_group_flag,

      OBLIGATION_DATE  = l_create_audit_rec.OBLIGATION_DATE ,
      OLD_OBLIGATION_DATE= l_create_audit_rec.OLD_OBLIGATION_DATE ,
      CHANGE_OBLIGATION_FLAG = l_create_audit_rec.CHANGE_OBLIGATION_FLAG,

      SITE_ID                = l_create_audit_rec.SITE_ID  ,
      OLD_SITE_ID           = l_create_audit_rec.OLD_SITE_ID  ,
      CHANGE_SITE_FLAG   = l_create_audit_rec.CHANGE_SITE_FLAG,

      BILL_TO_CONTACT_ID   = l_create_audit_rec.BILL_TO_CONTACT_ID ,
      OLD_BILL_TO_CONTACT_ID = l_create_audit_rec.OLD_BILL_TO_CONTACT_ID ,
      CHANGE_BILL_TO_FLAG  = l_create_audit_rec.CHANGE_BILL_TO_FLAG,

      SHIP_TO_CONTACT_ID   = l_create_audit_rec.SHIP_TO_CONTACT_ID ,
      OLD_SHIP_TO_CONTACT_ID= l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID ,
      CHANGE_SHIP_TO_FLAG = l_create_audit_rec.CHANGE_SHIP_TO_FLAG,

      INCIDENT_DATE       = l_create_audit_rec.INCIDENT_DATE ,
      OLD_INCIDENT_DATE  = l_create_audit_rec.OLD_INCIDENT_DATE ,
      CHANGE_INCIDENT_DATE_FLAG = l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG,

      CLOSE_DATE               = l_create_audit_rec.CLOSE_DATE ,
      OLD_CLOSE_DATE          = l_create_audit_rec.OLD_CLOSE_DATE ,
      CHANGE_CLOSE_DATE_FLAG  = l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG,

      CUSTOMER_PRODUCT_ID   = l_create_audit_rec.CUSTOMER_PRODUCT_ID ,
      OLD_CUSTOMER_PRODUCT_ID= l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID ,
      CHANGE_CUSTOMER_PRODUCT_FLAG = l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG,

      PLATFORM_ID                     = l_create_audit_rec.PLATFORM_ID ,
      OLD_PLATFORM_ID                = l_create_audit_rec.OLD_PLATFORM_ID ,
      CHANGE_PLATFORM_ID_FLAG = l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG,

      PLATFORM_VERSION_ID          = l_create_audit_rec.PLATFORM_VERSION_ID ,
      OLD_PLATFORM_VERSION_ID     = l_create_audit_rec.OLD_PLATFORM_VERSION_ID ,
      CHANGE_PLAT_VER_ID_FLAG = l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG,

      CP_COMPONENT_ID           = l_create_audit_rec.CP_COMPONENT_ID ,
      OLD_CP_COMPONENT_ID      = l_create_audit_rec.OLD_CP_COMPONENT_ID ,
      CHANGE_CP_COMPONENT_ID_FLAG = l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG,

      CP_COMPONENT_VERSION_ID   = l_create_audit_rec.CP_COMPONENT_VERSION_ID ,
      OLD_CP_COMPONENT_VERSION_ID= l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID,
      CHANGE_CP_COMP_VER_ID_FLAG = l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG,

      CP_SUBCOMPONENT_ID      = l_create_audit_rec.CP_SUBCOMPONENT_ID,
      OLD_CP_SUBCOMPONENT_ID   = l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID ,
      CHANGE_CP_SUBCOMPONENT_ID_FLAG = l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG,

      CP_SUBCOMPONENT_VERSION_ID   = l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID ,
      OLD_CP_SUBCOMPONENT_VERSION_ID= l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ,
      CHANGE_CP_SUBCOMP_VER_ID_FLAG = l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG,

      LANGUAGE_ID                 = l_create_audit_rec.LANGUAGE_ID ,
      OLD_LANGUAGE_ID            = l_create_audit_rec.OLD_LANGUAGE_ID ,
      CHANGE_LANGUAGE_ID_FLAG = l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG,

      TERRITORY_ID            = l_create_audit_rec.TERRITORY_ID ,
      OLD_TERRITORY_ID         = l_create_audit_rec.OLD_TERRITORY_ID ,
      CHANGE_TERRITORY_ID_FLAG = l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG,

      CP_REVISION_ID         = l_create_audit_rec.CP_REVISION_ID ,
      OLD_CP_REVISION_ID    = l_create_audit_rec.OLD_CP_REVISION_ID ,
      CHANGE_CP_REVISION_ID_FLAG = l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG,

      INV_ITEM_REVISION        = l_create_audit_rec.INV_ITEM_REVISION ,
      OLD_INV_ITEM_REVISION   = l_create_audit_rec.OLD_INV_ITEM_REVISION ,
      CHANGE_INV_ITEM_REVISION = l_create_audit_rec.CHANGE_INV_ITEM_REVISION,

      INV_COMPONENT_ID      = l_create_audit_rec.INV_COMPONENT_ID ,
      OLD_INV_COMPONENT_ID = l_create_audit_rec.OLD_INV_COMPONENT_ID ,
      CHANGE_INV_COMPONENT_ID = l_create_audit_rec.CHANGE_INV_COMPONENT_ID,

      INV_COMPONENT_VERSION   = l_create_audit_rec.INV_COMPONENT_VERSION ,
      OLD_INV_COMPONENT_VERSION = l_create_audit_rec.OLD_INV_COMPONENT_VERSION ,
      CHANGE_INV_COMPONENT_VERSION = l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION,

      INV_SUBCOMPONENT_ID         = l_create_audit_rec.INV_SUBCOMPONENT_ID ,
      OLD_INV_SUBCOMPONENT_ID    = l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID ,
      CHANGE_INV_SUBCOMPONENT_ID = l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID,

      INV_SUBCOMPONENT_VERSION = l_create_audit_rec.INV_SUBCOMPONENT_VERSION ,
      OLD_INV_SUBCOMPONENT_VERSION = l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION ,
      CHANGE_INV_SUBCOMP_VERSION = l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION,

      RESOURCE_TYPE              = l_create_audit_rec.RESOURCE_TYPE ,
      OLD_RESOURCE_TYPE         = l_create_audit_rec.OLD_RESOURCE_TYPE ,
      change_resource_type_flag    = l_create_audit_rec.change_resource_type_flag,

      OLD_GROUP_TYPE             = l_create_audit_rec.OLD_GROUP_TYPE ,
      GROUP_TYPE                = l_create_audit_rec.GROUP_TYPE ,
      change_group_type_flag    = l_create_audit_rec.change_group_type_flag,

      OLD_OWNER_ASSIGNED_TIME = l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME ,
      OWNER_ASSIGNED_TIME= l_create_audit_rec.OWNER_ASSIGNED_TIME ,
      CHANGE_ASSIGNED_TIME_FLAG = l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG,

      INV_PLATFORM_ORG_ID              = l_create_audit_rec.INV_PLATFORM_ORG_ID ,
      OLD_INV_PLATFORM_ORG_ID         = l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID ,
      CHANGE_PLATFORM_ORG_ID_FLAG = l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG,

      COMPONENT_VERSION             = l_create_audit_rec.COMPONENT_VERSION ,
      OLD_COMPONENT_VERSION        = l_create_audit_rec.OLD_COMPONENT_VERSION ,
      CHANGE_COMP_VER_FLAG = l_create_audit_rec.CHANGE_COMP_VER_FLAG,

      SUBCOMPONENT_VERSION       = l_create_audit_rec.SUBCOMPONENT_VERSION ,
      OLD_SUBCOMPONENT_VERSION  = l_create_audit_rec.OLD_SUBCOMPONENT_VERSION ,
      CHANGE_SUBCOMP_VER_FLAG = l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG,

      PRODUCT_REVISION                  = l_create_audit_rec.PRODUCT_REVISION ,
      OLD_PRODUCT_REVISION             = l_create_audit_rec.OLD_PRODUCT_REVISION ,
      CHANGE_PRODUCT_REVISION_FLAG = l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG,

      INVENTORY_ITEM_ID              = l_create_audit_rec.INVENTORY_ITEM_ID ,
      OLD_INVENTORY_ITEM_ID         = l_create_audit_rec.OLD_INVENTORY_ITEM_ID ,
      CHANGE_INVENTORY_ITEM_FLAG  = decode(l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG,NULL,'N',l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG),

      INV_ORGANIZATION_ID         = l_create_audit_rec.INV_ORGANIZATION_ID ,
      OLD_INV_ORGANIZATION_ID    = l_create_audit_rec.OLD_INV_ORGANIZATION_ID ,
      --CHANGE_INV_ORGANIZATION_FLAG  = decode(l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG,NULL,'N',l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG),
      CHANGE_INV_ORGANIZATION_FLAG  = l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG,

      STATUS_FLAG                  = l_create_audit_rec.STATUS_FLAG ,
      OLD_STATUS_FLAG    = l_create_audit_rec.OLD_STATUS_FLAG,
      CHANGE_STATUS_FLAG = l_create_audit_rec.CHANGE_STATUS_FLAG,

      PRIMARY_CONTACT_ID        = l_create_audit_rec.PRIMARY_CONTACT_ID ,
      OLD_PRIMARY_CONTACT_ID= l_create_audit_rec.OLD_PRIMARY_CONTACT_ID,
      CHANGE_PRIMARY_CONTACT_FLAG = l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG,

      UPGRADE_FLAG_FOR_CREATE = decode(l_create_record, 'Y', 'X', 'U'),
      updated_entity_code   = 'SR_HEADER'
    WHERE incident_audit_id = l_audit_rec.incident_audit_id;
    commit;
    end loop;
    close c_sr_audit_asc;
  end if;

    l_loop_counter := l_loop_counter+1;
  END LOOP; -- } Loop2

    CLOSE c_sr_current;

    ad_parallel_updates_pkg.processed_rowid_range(
         l_loop_counter,
         l_end_rowid);

    --
    -- commit transaction here
    --
    COMMIT;
    --

    -- get new range of rowids
    --
    ad_parallel_updates_pkg.get_rowid_range(
       l_start_rowid,
       l_end_rowid,
       l_any_rows_to_process,
       x_batch_size,
       FALSE);

    END LOOP; -- } Loop1

    x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

    EXCEPTION
      WHEN OTHERS THEN
        x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
        RAISE;
  END; -- } begin1

END Worker_Audit_Upgrade;

END CS_AUDIT_UPGRADE_CON_PRG;

/
