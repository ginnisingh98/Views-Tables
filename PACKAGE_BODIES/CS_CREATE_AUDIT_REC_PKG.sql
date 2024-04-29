--------------------------------------------------------
--  DDL for Package Body CS_CREATE_AUDIT_REC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CREATE_AUDIT_REC_PKG" AS
/* $Header: csxsraucb.pls 120.1 2005/07/19 01:38:57 appldev noship $ */

PROCEDURE Create_Initial_Audit_Manager
  (x_errbuf         OUT  NOCOPY VARCHAR2,
   x_retcode        OUT  NOCOPY VARCHAR2
  ) IS
BEGIN
  -- Parent Processing
  AD_CONC_UTILS_PKG.submit_subrequests
    (x_errbuf                    => x_errbuf,
     x_retcode                   => x_retcode,
     x_workerconc_app_shortname  => 'CS', --l_product,
     x_workerconc_progname       => 'CSSRAUDCWKR',
     x_batch_size                => 1000,
     x_num_workers               => 3
    );
END;

PROCEDURE Create_Initial_Audit_Worker
  (x_errbuf     OUT NOCOPY VARCHAR2,
   x_retcode    OUT NOCOPY VARCHAR2,
   x_batch_size IN NUMBER,
   x_worker_id  IN NUMBER,
   x_num_workers IN NUMBER
  ) IS

l_loop_counter    NUMBER;

CURSOR c_sr_current(c_start_rowid rowid,c_end_rowid rowid)  IS
SELECT
  INCIDENT_ID        ,
  LAST_UPDATE_DATE   ,
  LAST_UPDATED_BY   ,
  CREATION_DATE   ,
  CREATED_BY     ,
  CREATION_TIME   ,
  LAST_UPDATE_LOGIN ,
  INCIDENT_STATUS_ID  ,
  NULL OLD_INCIDENT_STATUS_ID ,
  'N' CHANGE_INCIDENT_STATUS_FLAG ,
  INCIDENT_TYPE_ID           ,
  NULL OLD_INCIDENT_TYPE_ID      ,
  'N' CHANGE_INCIDENT_TYPE_FLAG ,
  INCIDENT_URGENCY_ID      ,
  NULL OLD_INCIDENT_URGENCY_ID ,
  'N' CHANGE_INCIDENT_URGENCY_FLAG ,
  INCIDENT_SEVERITY_ID        ,
  NULL OLD_INCIDENT_SEVERITY_ID   ,
  'N' CHANGE_INCIDENT_SEVERITY_FLAG,
  RESPONSIBLE_GROUP_ID        ,
  NULL OLD_RESPONSIBLE_GROUP_ID   ,
  'N' CHANGE_RESPONSIBLE_GROUP_FLAG ,
  INCIDENT_OWNER_ID            ,
  NULL OLD_INCIDENT_OWNER_ID       ,
  'N' CHANGE_INCIDENT_OWNER_FLAG ,
  EXPECTED_RESOLUTION_DATE,
  NULL OLD_EXPECTED_RESOLUTION_DATE  ,
  'N' CHANGE_RESOLUTION_FLAG       ,
  OWNER_GROUP_ID GROUP_ID         ,
  NULL OLD_GROUP_ID        ,
  'N' CHANGE_GROUP_FLAG  ,
  OBLIGATION_DATE   ,
  NULL OLD_OBLIGATION_DATE ,
  'N' CHANGE_OBLIGATION_FLAG    ,
  SITE_ID                  ,
  NULL OLD_SITE_ID             ,
  'N' CHANGE_SITE_FLAG       ,
  BILL_TO_CONTACT_ID    ,
  NULL OLD_BILL_TO_CONTACT_ID  ,
  'N' CHANGE_BILL_TO_FLAG    ,
  SHIP_TO_CONTACT_ID    ,
  NULL OLD_SHIP_TO_CONTACT_ID ,
  'N' CHANGE_SHIP_TO_FLAG   ,
  INCIDENT_DATE        ,
  NULL OLD_INCIDENT_DATE   ,
  'N' CHANGE_INCIDENT_DATE_FLAG  ,
  CLOSE_DATE                ,
  NULL OLD_CLOSE_DATE           ,
  'N' CHANGE_CLOSE_DATE_FLAG  ,
  CUSTOMER_PRODUCT_ID    ,
  NULL OLD_CUSTOMER_PRODUCT_ID ,
  'N' CHANGE_CUSTOMER_PRODUCT_FLAG        ,
  PLATFORM_ID                      ,
  NULL OLD_PLATFORM_ID                 ,
  'N' CHANGE_PLATFORM_ID_FLAG        ,
  PLATFORM_VERSION_ID           ,
  NULL OLD_PLATFORM_VERSION_ID      ,
  'N' CHANGE_PLAT_VER_ID_FLAG     ,
  CP_COMPONENT_ID            ,
  NULL OLD_CP_COMPONENT_ID       ,
  'N' CHANGE_CP_COMPONENT_ID_FLAG ,
  CP_COMPONENT_VERSION_ID    ,
  NULL OLD_CP_COMPONENT_VERSION_ID,
  'N' CHANGE_CP_COMP_VER_ID_FLAG ,
  CP_SUBCOMPONENT_ID         ,
  NULL OLD_CP_SUBCOMPONENT_ID    ,
  'N' CHANGE_CP_SUBCOMPONENT_ID_FLAG ,
  CP_SUBCOMPONENT_VERSION_ID    ,
  NULL OLD_CP_SUBCOMPONENT_VERSION_ID ,
  'N' CHANGE_CP_SUBCOMP_VER_ID_FLAG ,
  LANGUAGE_ID                  ,
  NULL OLD_LANGUAGE_ID             ,
  'N' CHANGE_LANGUAGE_ID_FLAG   ,
  TERRITORY_ID             ,
  NULL OLD_TERRITORY_ID          ,
  'N' CHANGE_TERRITORY_ID_FLAG ,
  CP_REVISION_ID          ,
  NULL OLD_CP_REVISION_ID     ,
  'N' CHANGE_CP_REVISION_ID_FLAG ,
  INV_ITEM_REVISION         ,
  NULL OLD_INV_ITEM_REVISION    ,
  'N' CHANGE_INV_ITEM_REVISION,
  INV_COMPONENT_ID       ,
  NULL OLD_INV_COMPONENT_ID  ,
  'N' CHANGE_INV_COMPONENT_ID   ,
  INV_COMPONENT_VERSION    ,
  NULL OLD_INV_COMPONENT_VERSION  ,
  'N' CHANGE_INV_COMPONENT_VERSION  ,
  INV_SUBCOMPONENT_ID          ,
  NULL OLD_INV_SUBCOMPONENT_ID     ,
  'N' CHANGE_INV_SUBCOMPONENT_ID ,
  INV_SUBCOMPONENT_VERSION  ,
  NULL OLD_INV_SUBCOMPONENT_VERSION  ,
  'N' CHANGE_INV_SUBCOMP_VERSION   ,
  RESOURCE_TYPE               ,
  NULL OLD_RESOURCE_TYPE          ,
  'N'  CHANGE_RESOURCE_TYPE_FLAG ,
  NULL OLD_GROUP_TYPE              ,
  GROUP_TYPE                 ,
  'N' CHANGE_GROUP_TYPE_FLAG    ,
  NULL OLD_OWNER_ASSIGNED_TIME  ,
  OWNER_ASSIGNED_TIME        ,
  'N' CHANGE_ASSIGNED_TIME_FLAG          ,
  INV_PLATFORM_ORG_ID               ,
  NULL OLD_INV_PLATFORM_ORG_ID          ,
  'N' CHANGE_PLATFORM_ORG_ID_FLAG     ,
  COMPONENT_VERSION              ,
  NULL OLD_COMPONENT_VERSION         ,
  'N' CHANGE_COMP_VER_FLAG         ,
  SUBCOMPONENT_VERSION        ,
  NULL OLD_SUBCOMPONENT_VERSION   ,
  'N' CHANGE_SUBCOMP_VER_FLAG   ,
  PRODUCT_REVISION                   ,
  NULL OLD_PRODUCT_REVISION              ,
  'N' CHANGE_PRODUCT_REVISION_FLAG     ,
  INVENTORY_ITEM_ID               ,
  NULL OLD_INVENTORY_ITEM_ID          ,
  'N' CHANGE_INVENTORY_ITEM_FLAG    ,
  INV_ORGANIZATION_ID          ,
  NULL OLD_INV_ORGANIZATION_ID     ,
  'N' CHANGE_INV_ORGANIZATION_FLAG   ,
  STATUS_FLAG                   ,
  NULL OLD_STATUS_FLAG              ,
  'N' CHANGE_STATUS_FLAG          ,
  PRIMARY_CONTACT_ID         ,
  'N' CHANGE_PRIMARY_CONTACT_FLAG  ,
  NULL OLD_PRIMARY_CONTACT_ID     ,
  SECURITY_GROUP_ID
FROM CS_INCIDENTS_ALL_B a
WHERE ROWID BETWEEN c_start_rowid AND c_end_rowid
  AND NOT EXISTS (SELECT b.incident_id
                  FROM   cs_incidents_audit_b b
                  WHERE a.incident_id = b.incident_id
                  AND (b.upgrade_flag_for_create = 'Y'
                   OR (b.OLD_INCIDENT_STATUS_ID IS NULL
                  AND b.INCIDENT_STATUS_ID IS NOT NULL
                  AND b.CHANGE_INCIDENT_STATUS_FLAG = 'Y') )  );

CURSOR c_sr_audit(c_incident_id number) IS
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
FROM CS_INCIDENTS_AUDIT_B
WHERE INCIDENT_ID = c_incident_id
ORDER BY creation_date desc, incident_audit_id DESC;

l_request_id         NUMBER;
l_incident_audit_id  NUMBER;
l_audit_count        NUMBER;
l_audit_rec          c_sr_audit%ROWTYPE;
l_create_audit_rec   c_sr_current%ROWTYPE;

l_worker_id            NUMBER;
l_product              VARCHAR2(30) := 'CS';
l_table_name           VARCHAR2(30) := 'CS_INCIDENTS_ALL_B';
l_table_owner          VARCHAR2(30);
l_update_name          VARCHAR2(30) := 'csxsraucb.pls.115.0';
l_start_rowid          ROWID;
l_end_rowid            ROWID;
l_rows_processed       NUMBER;
l_status               VARCHAR2(30);
l_industry             VARCHAR2(30);
l_retstatus            BOOLEAN;
l_any_rows_to_process  BOOLEAN;

BEGIN
  --
  -- get schema name of the table for ROWID range processing
  --
  l_retstatus := fnd_installation.get_app_info(
                     l_product, l_status, l_industry, l_table_owner);

  IF ((l_retstatus = FALSE) OR (l_table_owner IS NULL)) THEN
      RAISE_APPLICATION_ERROR(-20001,
         'Cannot get schema name for product : '||l_product);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, '  X_Worker_Id : '||x_worker_id);
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'X_Num_Workers : '||x_num_workers);

  --
  -- Worker processing
  --
  -- The following could be coded to use EXECUTE IMMEDIATE inorder to remove
  -- build time dependencies as the processing could potentially reference
  -- some tables that could be obsoleted in the current release
  BEGIN -- AB1

  ad_parallel_updates_pkg.initialize_rowid_range(
           ad_parallel_updates_pkg.ROWID_RANGE,
           l_table_owner,
           l_table_name,
           l_update_name,
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
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Processing: l_start_row_id='||l_start_rowid
      || '; l_end_rowid=' || l_end_rowid);
    OPEN c_sr_current(l_start_rowid, l_end_rowid);
    l_loop_counter := 0;
    LOOP --{Loop2
    FETCH c_sr_current INTO l_create_audit_rec;
    EXIT WHEN c_sr_current%NOTFOUND;

    l_request_id := l_create_audit_rec.incident_id;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '  Service Request Id : '||l_request_id);
    SELECT COUNT(incident_audit_id) INTO l_audit_count
    FROM cs_incidents_audit_b
    WHERE incident_id= l_request_id;

    IF l_audit_count >0 THEN
      OPEN c_sr_audit(l_request_id);
      LOOP --{Loop3
      FETCH c_sr_audit INTO l_audit_rec;
      EXIT WHEN c_sr_audit%NOTFOUND;

      if l_audit_rec.CHANGE_INCIDENT_STATUS_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_STATUS_ID := l_audit_rec.OLD_INCIDENT_STATUS_ID ;
      end if;
      if l_audit_rec.CHANGE_INCIDENT_TYPE_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_TYPE_ID := l_audit_rec.OLD_INCIDENT_TYPE_ID      ;
      end if;
      if l_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_URGENCY_ID := l_audit_rec.OLD_INCIDENT_URGENCY_ID ;
      end if;
      if l_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_SEVERITY_ID := l_audit_rec.OLD_INCIDENT_SEVERITY_ID   ;
      end if;
      if l_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG = 'Y' then
        l_create_audit_rec.RESPONSIBLE_GROUP_ID := l_audit_rec.OLD_RESPONSIBLE_GROUP_ID   ;
      end if;
      if l_audit_rec.CHANGE_INCIDENT_OWNER_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_OWNER_ID := l_audit_rec.OLD_INCIDENT_OWNER_ID       ;
      end if;
      if l_audit_rec.CHANGE_RESOLUTION_FLAG = 'Y' then
        l_create_audit_rec.EXPECTED_RESOLUTION_DATE := l_audit_rec.OLD_EXPECTED_RESOLUTION_DATE  ;
      end if;
      if l_audit_rec.CHANGE_GROUP_FLAG = 'Y' then
        l_create_audit_rec.GROUP_ID := l_audit_rec.OLD_GROUP_ID        ;
      end if;
      if l_audit_rec.CHANGE_OBLIGATION_FLAG = 'Y' then
        l_create_audit_rec.OBLIGATION_DATE := l_audit_rec.OLD_OBLIGATION_DATE ;
      end if;
      if l_audit_rec.CHANGE_SITE_FLAG = 'Y' then
        l_create_audit_rec.SITE_ID := l_audit_rec.OLD_SITE_ID             ;
      end if;
      if l_audit_rec.CHANGE_BILL_TO_FLAG = 'Y' then
       l_create_audit_rec.BILL_TO_CONTACT_ID := l_audit_rec.OLD_BILL_TO_CONTACT_ID  ;
      end if;
      if l_audit_rec.CHANGE_SHIP_TO_FLAG = 'Y' then
        l_create_audit_rec.SHIP_TO_CONTACT_ID := l_audit_rec.OLD_SHIP_TO_CONTACT_ID ;
      end if;
      if l_audit_rec.CHANGE_INCIDENT_DATE_FLAG = 'Y' then
        l_create_audit_rec.INCIDENT_DATE := l_audit_rec.OLD_INCIDENT_DATE   ;
      end if;
      if l_audit_rec.CHANGE_CLOSE_DATE_FLAG = 'Y' then
        l_create_audit_rec.CLOSE_DATE := l_audit_rec.OLD_CLOSE_DATE          ;
      end if;
      if l_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG = 'Y' then
        l_create_audit_rec.CUSTOMER_PRODUCT_ID := l_audit_rec.OLD_CUSTOMER_PRODUCT_ID ;
      end if;
      if l_audit_rec.CHANGE_PLATFORM_ID_FLAG = 'Y' then
        l_create_audit_rec.PLATFORM_ID := l_audit_rec.OLD_PLATFORM_ID   ;
      end if;
      if l_audit_rec.CHANGE_PLAT_VER_ID_FLAG = 'Y' then
        l_create_audit_rec.PLATFORM_VERSION_ID := l_audit_rec.OLD_PLATFORM_VERSION_ID      ;
      end if;
      if l_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG = 'Y' then
        l_create_audit_rec.CP_COMPONENT_ID := l_audit_rec.OLD_CP_COMPONENT_ID       ;
      end if;
      if l_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG = 'Y' then
        l_create_audit_rec.CP_COMPONENT_VERSION_ID := l_audit_rec.OLD_CP_COMPONENT_VERSION_ID;
      end if;
      if l_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG = 'Y' then
        l_create_audit_rec.CP_SUBCOMPONENT_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_ID    ;
      end if;
      if l_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG = 'Y' then
        l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID := l_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ;
      end if;
      if l_audit_rec.CHANGE_LANGUAGE_ID_FLAG = 'Y' then
        l_create_audit_rec.LANGUAGE_ID := l_audit_rec.OLD_LANGUAGE_ID             ;
      end if;
      if l_audit_rec.CHANGE_TERRITORY_ID_FLAG = 'Y' then
        l_create_audit_rec.TERRITORY_ID := l_audit_rec.OLD_TERRITORY_ID          ;
      end if;
      if l_audit_rec.CHANGE_CP_REVISION_ID_FLAG = 'Y' then
        l_create_audit_rec.CP_REVISION_ID := l_audit_rec.OLD_CP_REVISION_ID     ;
      end if;
      if l_audit_rec.CHANGE_INV_ITEM_REVISION = 'Y' then
        l_create_audit_rec.INV_ITEM_REVISION := l_audit_rec.OLD_INV_ITEM_REVISION    ;
      end if;
      if l_audit_rec.CHANGE_INV_COMPONENT_ID   = 'Y' then
        l_create_audit_rec.INV_COMPONENT_ID := l_audit_rec.OLD_INV_COMPONENT_ID  ;
      end if;
      if l_audit_rec.CHANGE_INV_COMPONENT_VERSION   = 'Y' then
        l_create_audit_rec.INV_COMPONENT_VERSION := l_audit_rec.OLD_INV_COMPONENT_VERSION  ;
      end if;
      if l_audit_rec.CHANGE_INV_SUBCOMPONENT_ID  = 'Y' then
        l_create_audit_rec.INV_SUBCOMPONENT_ID := l_audit_rec.OLD_INV_SUBCOMPONENT_ID     ;
      end if;
      if l_audit_rec.CHANGE_INV_SUBCOMP_VERSION   = 'Y' then
        l_create_audit_rec.INV_SUBCOMPONENT_VERSION := l_audit_rec.OLD_INV_SUBCOMPONENT_VERSION  ;
      end if;
      if l_audit_rec.CHANGE_RESOURCE_TYPE_FLAG = 'Y' then
        l_create_audit_rec.RESOURCE_TYPE := l_audit_rec.OLD_RESOURCE_TYPE          ;
      end if;
      if l_audit_rec.CHANGE_GROUP_TYPE_FLAG = 'Y' then
        l_create_audit_rec.GROUP_TYPE := l_audit_rec.OLD_GROUP_TYPE              ;
      end if;
      if l_audit_rec.CHANGE_ASSIGNED_TIME_FLAG = 'Y' then
        l_create_audit_rec.OWNER_ASSIGNED_TIME := l_audit_rec.OLD_OWNER_ASSIGNED_TIME  ;
      end if;
      if l_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG = 'Y' then
        l_create_audit_rec.INV_PLATFORM_ORG_ID := l_audit_rec.OLD_INV_PLATFORM_ORG_ID ;
      end if;
      if l_audit_rec.CHANGE_COMP_VER_FLAG = 'Y' then
        l_create_audit_rec.COMPONENT_VERSION := l_audit_rec.OLD_COMPONENT_VERSION  ;
      end if;
      if l_audit_rec.CHANGE_SUBCOMP_VER_FLAG = 'Y' then
        l_create_audit_rec.SUBCOMPONENT_VERSION := l_audit_rec.OLD_SUBCOMPONENT_VERSION   ;
      end if;
      if l_audit_rec.CHANGE_PRODUCT_REVISION_FLAG = 'Y' then
        l_create_audit_rec.PRODUCT_REVISION := l_audit_rec.OLD_PRODUCT_REVISION  ;
      end if;
      if l_audit_rec.CHANGE_INVENTORY_ITEM_FLAG = 'Y' then
        l_create_audit_rec.INVENTORY_ITEM_ID := l_audit_rec.OLD_INVENTORY_ITEM_ID          ;
      end if;
      if l_audit_rec.CHANGE_INV_ORGANIZATION_FLAG = 'Y' then
        l_create_audit_rec.INV_ORGANIZATION_ID := l_audit_rec.OLD_INV_ORGANIZATION_ID     ;
      end if;
      if l_audit_rec.CHANGE_STATUS_FLAG = 'Y' then
        l_create_audit_rec.STATUS_FLAG := l_audit_rec.OLD_STATUS_FLAG;
      end if;
      if l_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG = 'Y' then
        l_create_audit_rec.PRIMARY_CONTACT_ID := l_audit_rec.OLD_PRIMARY_CONTACT_ID  ;
      end if;

      end loop; --{Loop3
    close c_sr_audit;
    end if;

    if l_create_audit_rec.INCIDENT_STATUS_ID is not null then
      l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INCIDENT_TYPE_ID is not null then
      l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INCIDENT_URGENCY_ID is not null then
      l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INCIDENT_SEVERITY_ID is not null then
      l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG := 'Y';
    end if;
    if l_create_audit_rec.RESPONSIBLE_GROUP_ID is not null then
      l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INCIDENT_OWNER_ID is not null then
      l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG := 'Y';
    end if;
    if l_create_audit_rec.EXPECTED_RESOLUTION_DATE is not null then
      l_create_audit_rec.CHANGE_RESOLUTION_FLAG := 'Y';
    end if;
    if l_create_audit_rec.GROUP_ID is not null then
      l_create_audit_rec.CHANGE_GROUP_FLAG := 'Y';
    end if;
    if l_create_audit_rec.OBLIGATION_DATE is not null then
      l_create_audit_rec.CHANGE_OBLIGATION_FLAG := 'Y';
    end if;
    if l_create_audit_rec.SITE_ID is not null then
      l_create_audit_rec.CHANGE_SITE_FLAG := 'Y';
    end if;
    if l_create_audit_rec.BILL_TO_CONTACT_ID is not null then
      l_create_audit_rec.CHANGE_BILL_TO_FLAG := 'Y';
    end if;
    if l_create_audit_rec.SHIP_TO_CONTACT_ID is not null then
      l_create_audit_rec.CHANGE_SHIP_TO_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INCIDENT_DATE is not null then
      l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CLOSE_DATE is not null then
      l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CUSTOMER_PRODUCT_ID is not null then
      l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG := 'Y';
    end if;
    if l_create_audit_rec.PLATFORM_ID is not null then
      l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.PLATFORM_VERSION_ID is not null then
      l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CP_COMPONENT_ID is not null then
      l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CP_COMPONENT_VERSION_ID is not null then
      l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CP_SUBCOMPONENT_ID is not null then
       l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID is not null then
      l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.LANGUAGE_ID is not null then
      l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.TERRITORY_ID is not null then
      l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.CP_REVISION_ID is not null then
      l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INV_ITEM_REVISION is not null then
      l_create_audit_rec.CHANGE_INV_ITEM_REVISION := 'Y';
    end if;
    if l_create_audit_rec.INV_COMPONENT_ID is not null then
      l_create_audit_rec.CHANGE_INV_COMPONENT_ID := 'Y';
    end if;
    if l_create_audit_rec.INV_COMPONENT_VERSION is not null then
      l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION := 'Y';
    end if;
    if l_create_audit_rec.INV_SUBCOMPONENT_ID is not null then
      l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID := 'Y';
    end if;
    if l_create_audit_rec.INV_SUBCOMPONENT_VERSION is not null then
      l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION := 'Y';
    end if;
    if l_create_audit_rec.RESOURCE_TYPE is not null then
      l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG := 'Y';
    end if;
    if l_create_audit_rec.GROUP_TYPE is not null then
      l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG := 'Y';
    end if;
    if l_create_audit_rec.OWNER_ASSIGNED_TIME is not null then
      l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INV_PLATFORM_ORG_ID is not null then
     l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG := 'Y';
    end if;
    if l_create_audit_rec.COMPONENT_VERSION is not null then
      l_create_audit_rec.CHANGE_COMP_VER_FLAG := 'Y';
    end if;
    if l_create_audit_rec.SUBCOMPONENT_VERSION is not null then
      l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG := 'Y';
    end if;
    if l_create_audit_rec.PRODUCT_REVISION is not null then
      l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INVENTORY_ITEM_ID is not null then
      l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG := 'Y';
    end if;
    if l_create_audit_rec.INV_ORGANIZATION_ID is not null then
      l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG := 'Y';
    end if;
    if l_create_audit_rec.STATUS_FLAG is not null then
      l_create_audit_rec.CHANGE_STATUS_FLAG := 'Y';
    end if;
    if l_create_audit_rec.PRIMARY_CONTACT_ID is not null then
      l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG := 'Y';
    end if;

    SELECT cs_incidents_audit_s1.NEXTVAL INTO l_incident_audit_id FROM DUAL;

    INSERT INTO cs_incidents_audit_b (
      INCIDENT_ID        ,
      INCIDENT_AUDIT_ID        ,
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
      OWNER_ASSIGNED_TIME ,
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
      OLD_PRIMARY_CONTACT_ID,
      OBJECT_VERSION_NUMBER             ,
      UPGRADE_FLAG_FOR_CREATE           ,
      SECURITY_GROUP_ID ) VALUES (
      l_create_audit_rec.INCIDENT_ID        ,
      l_incident_audit_id   ,
      l_create_audit_rec.CREATION_DATE , -- last_update_date should be same as creation_date
      l_create_audit_rec.CREATED_BY, -- last_updated_by should be same as created_by
      l_create_audit_rec.CREATION_DATE   ,
      l_create_audit_rec.CREATED_BY     ,
      l_create_audit_rec.LAST_UPDATE_LOGIN ,
      l_create_audit_rec.CREATION_TIME    ,
      l_create_audit_rec.INCIDENT_STATUS_ID  ,
      l_create_audit_rec.OLD_INCIDENT_STATUS_ID ,
      l_create_audit_rec.CHANGE_INCIDENT_STATUS_FLAG ,
      l_create_audit_rec.INCIDENT_TYPE_ID           ,
      l_create_audit_rec.OLD_INCIDENT_TYPE_ID      ,
      l_create_audit_rec.CHANGE_INCIDENT_TYPE_FLAG ,
      l_create_audit_rec.INCIDENT_URGENCY_ID      ,
      l_create_audit_rec.OLD_INCIDENT_URGENCY_ID ,
      l_create_audit_rec.CHANGE_INCIDENT_URGENCY_FLAG ,
      l_create_audit_rec.INCIDENT_SEVERITY_ID        ,
      l_create_audit_rec.OLD_INCIDENT_SEVERITY_ID   ,
      l_create_audit_rec.CHANGE_INCIDENT_SEVERITY_FLAG,
      l_create_audit_rec.RESPONSIBLE_GROUP_ID        ,
      l_create_audit_rec.OLD_RESPONSIBLE_GROUP_ID   ,
      l_create_audit_rec.CHANGE_RESPONSIBLE_GROUP_FLAG ,
      l_create_audit_rec.INCIDENT_OWNER_ID            ,
      l_create_audit_rec.OLD_INCIDENT_OWNER_ID       ,
      l_create_audit_rec.CHANGE_INCIDENT_OWNER_FLAG ,
      l_create_audit_rec.EXPECTED_RESOLUTION_DATE,
      l_create_audit_rec.OLD_EXPECTED_RESOLUTION_DATE  ,
      l_create_audit_rec.CHANGE_RESOLUTION_FLAG       ,
      l_create_audit_rec.GROUP_ID              ,
      l_create_audit_rec.OLD_GROUP_ID        ,
      l_create_audit_rec.CHANGE_GROUP_FLAG  ,
      l_create_audit_rec.OBLIGATION_DATE   ,
      l_create_audit_rec.OLD_OBLIGATION_DATE ,
      l_create_audit_rec.CHANGE_OBLIGATION_FLAG    ,
      l_create_audit_rec.SITE_ID                  ,
      l_create_audit_rec.OLD_SITE_ID             ,
      l_create_audit_rec.CHANGE_SITE_FLAG       ,
      l_create_audit_rec.BILL_TO_CONTACT_ID    ,
      l_create_audit_rec.OLD_BILL_TO_CONTACT_ID  ,
      l_create_audit_rec.CHANGE_BILL_TO_FLAG    ,
      l_create_audit_rec.SHIP_TO_CONTACT_ID    ,
      l_create_audit_rec.OLD_SHIP_TO_CONTACT_ID ,
      l_create_audit_rec.CHANGE_SHIP_TO_FLAG   ,
      l_create_audit_rec.INCIDENT_DATE        ,
      l_create_audit_rec.OLD_INCIDENT_DATE   ,
      l_create_audit_rec.CHANGE_INCIDENT_DATE_FLAG  ,
      l_create_audit_rec.CLOSE_DATE                ,
      l_create_audit_rec.OLD_CLOSE_DATE           ,
      l_create_audit_rec.CHANGE_CLOSE_DATE_FLAG  ,
      l_create_audit_rec.CUSTOMER_PRODUCT_ID    ,
      l_create_audit_rec.OLD_CUSTOMER_PRODUCT_ID ,
      l_create_audit_rec.CHANGE_CUSTOMER_PRODUCT_FLAG        ,
      l_create_audit_rec.PLATFORM_ID                      ,
      l_create_audit_rec.OLD_PLATFORM_ID                 ,
      l_create_audit_rec.CHANGE_PLATFORM_ID_FLAG        ,
      l_create_audit_rec.PLATFORM_VERSION_ID           ,
      l_create_audit_rec.OLD_PLATFORM_VERSION_ID      ,
      l_create_audit_rec.CHANGE_PLAT_VER_ID_FLAG     ,
      l_create_audit_rec.CP_COMPONENT_ID            ,
      l_create_audit_rec.OLD_CP_COMPONENT_ID       ,
      l_create_audit_rec.CHANGE_CP_COMPONENT_ID_FLAG ,
      l_create_audit_rec.CP_COMPONENT_VERSION_ID    ,
      l_create_audit_rec.OLD_CP_COMPONENT_VERSION_ID,
      l_create_audit_rec.CHANGE_CP_COMP_VER_ID_FLAG ,
      l_create_audit_rec.CP_SUBCOMPONENT_ID         ,
      l_create_audit_rec.OLD_CP_SUBCOMPONENT_ID    ,
      l_create_audit_rec.CHANGE_CP_SUBCOMPONENT_ID_FLAG ,
      l_create_audit_rec.CP_SUBCOMPONENT_VERSION_ID    ,
      l_create_audit_rec.OLD_CP_SUBCOMPONENT_VERSION_ID ,
      l_create_audit_rec.CHANGE_CP_SUBCOMP_VER_ID_FLAG ,
      l_create_audit_rec.LANGUAGE_ID                  ,
      l_create_audit_rec.OLD_LANGUAGE_ID             ,
      l_create_audit_rec.CHANGE_LANGUAGE_ID_FLAG   ,
      l_create_audit_rec.TERRITORY_ID             ,
      l_create_audit_rec.OLD_TERRITORY_ID          ,
      l_create_audit_rec.CHANGE_TERRITORY_ID_FLAG ,
      l_create_audit_rec.CP_REVISION_ID          ,
      l_create_audit_rec.OLD_CP_REVISION_ID     ,
      l_create_audit_rec.CHANGE_CP_REVISION_ID_FLAG ,
      l_create_audit_rec.INV_ITEM_REVISION         ,
      l_create_audit_rec.OLD_INV_ITEM_REVISION    ,
      l_create_audit_rec.CHANGE_INV_ITEM_REVISION,
      l_create_audit_rec.INV_COMPONENT_ID       ,
      l_create_audit_rec.OLD_INV_COMPONENT_ID  ,
      l_create_audit_rec.CHANGE_INV_COMPONENT_ID   ,
      l_create_audit_rec.INV_COMPONENT_VERSION    ,
      l_create_audit_rec.OLD_INV_COMPONENT_VERSION  ,
      l_create_audit_rec.CHANGE_INV_COMPONENT_VERSION  ,
      l_create_audit_rec.INV_SUBCOMPONENT_ID          ,
      l_create_audit_rec.OLD_INV_SUBCOMPONENT_ID     ,
      l_create_audit_rec.CHANGE_INV_SUBCOMPONENT_ID ,
      l_create_audit_rec.INV_SUBCOMPONENT_VERSION  ,
      l_create_audit_rec.OLD_INV_SUBCOMPONENT_VERSION  ,
      l_create_audit_rec.CHANGE_INV_SUBCOMP_VERSION   ,
      l_create_audit_rec.RESOURCE_TYPE               ,
      l_create_audit_rec.OLD_RESOURCE_TYPE          ,
      l_create_audit_rec.CHANGE_RESOURCE_TYPE_FLAG ,
      l_create_audit_rec.OLD_GROUP_TYPE              ,
      l_create_audit_rec.GROUP_TYPE                 ,
      l_create_audit_rec.CHANGE_GROUP_TYPE_FLAG    ,
      l_create_audit_rec.OLD_OWNER_ASSIGNED_TIME  ,
      l_create_audit_rec.OWNER_ASSIGNED_TIME  ,
      l_create_audit_rec.CHANGE_ASSIGNED_TIME_FLAG          ,
      l_create_audit_rec.INV_PLATFORM_ORG_ID               ,
      l_create_audit_rec.OLD_INV_PLATFORM_ORG_ID          ,
      l_create_audit_rec.CHANGE_PLATFORM_ORG_ID_FLAG     ,
      l_create_audit_rec.COMPONENT_VERSION              ,
      l_create_audit_rec.OLD_COMPONENT_VERSION         ,
      l_create_audit_rec.CHANGE_COMP_VER_FLAG         ,
      l_create_audit_rec.SUBCOMPONENT_VERSION        ,
      l_create_audit_rec.OLD_SUBCOMPONENT_VERSION   ,
      l_create_audit_rec.CHANGE_SUBCOMP_VER_FLAG   ,
      l_create_audit_rec.PRODUCT_REVISION                   ,
      l_create_audit_rec.OLD_PRODUCT_REVISION              ,
      l_create_audit_rec.CHANGE_PRODUCT_REVISION_FLAG     ,
      l_create_audit_rec.INVENTORY_ITEM_ID               ,
      l_create_audit_rec.OLD_INVENTORY_ITEM_ID          ,
      l_create_audit_rec.CHANGE_INVENTORY_ITEM_FLAG    ,
      l_create_audit_rec.INV_ORGANIZATION_ID          ,
      l_create_audit_rec.OLD_INV_ORGANIZATION_ID     ,
      l_create_audit_rec.CHANGE_INV_ORGANIZATION_FLAG   ,
      l_create_audit_rec.STATUS_FLAG                   ,
      l_create_audit_rec.OLD_STATUS_FLAG              ,
      l_create_audit_rec.CHANGE_STATUS_FLAG          ,
      l_create_audit_rec.PRIMARY_CONTACT_ID         ,
      l_create_audit_rec.CHANGE_PRIMARY_CONTACT_FLAG  ,
      l_create_audit_rec.OLD_PRIMARY_CONTACT_ID ,
      1,
      'Y',
      l_create_audit_rec.SECURITY_GROUP_ID) ;

    l_loop_counter := l_loop_counter+1;

    END LOOP; --{Loop2

    CLOSE c_sr_current;

    l_rows_processed := l_loop_counter;

    ad_parallel_updates_pkg.processed_rowid_range(
               l_rows_processed,
               l_end_rowid);
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

    END LOOP; --{Loop1

    x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

  EXCEPTION
    WHEN OTHERS THEN
      x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
      RAISE;
  END; --AB1

EXCEPTION
  WHEN OTHERS THEN
    x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
    RAISE;
END Create_Initial_Audit_Worker;

END CS_CREATE_AUDIT_REC_PKG;

/
