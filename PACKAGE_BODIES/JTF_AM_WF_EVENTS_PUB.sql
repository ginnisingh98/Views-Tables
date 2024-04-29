--------------------------------------------------------
--  DDL for Package Body JTF_AM_WF_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AM_WF_EVENTS_PUB" AS
  /* $Header: jtfamwpb.pls 120.3 2006/08/18 07:05:01 mpadhiar noship $ */

  /*****************************************************************************************
   ******************************************************************************************/

  /* Package variables. */

  G_PKG_NAME         VARCHAR2(30) := 'JTF_AM_WF_EVENTS_PUB';

  /*****Commented out this function for Enh. No 3076744 by SBARAT, 13/09/2004 and  new one has been written below*****/

  /*FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2*/
  /* Return Item_Key according to Resource Event to be raised
     Item_Key is <Event_Name>-jtf_rs_wf_event_guid_s.nextval */
  /*IS
  l_key varchar2(240);
  BEGIN
     SELECT p_event_name ||'-'|| JTF_AM_WF_SR_EVENT_S.nextval INTO l_key FROM DUAL;
     RETURN l_key;
  END item_key;*/

  /*************************End of Comments***********************/


  /*********** Modified function Item_Key for all document types done for Enh. No 3076744 by SBARAT, 15/09/2004***********/

  FUNCTION item_key(p_event_name  IN VARCHAR2) RETURN VARCHAR2
  /* Return Item_Key according to Resource Event to be raised
     Item_Key is <Event_Name>-jtf_rs_wf_event_guid_s.nextval */
  IS
  l_key		varchar2(240);
  l_str		varchar2(1000);
  l_doc_type	varchar2(10);
  l_sequence	varchar2(10);
  BEGIN
     SELECT Upper(Substr(p_event_name,22,(Instr(p_event_name,'.',1,5)-22))) into l_doc_type from dual;
     l_str:='SELECT JTF_AM_WF_'||l_doc_type||'_EVENT_S.nextval FROM DUAL';
     EXECUTE IMMEDIATE l_str Into l_sequence;
     l_key:=p_event_name ||'-'|| l_sequence;
     RETURN l_key;
  END item_key;

  /****************** End of Changes for Enh. No 3076744 by SBARAT, 15/09/2004***************/


  PROCEDURE assign_sr_resource
  (P_API_VERSION           IN  NUMBER,
   P_INIT_MSG_LIST         IN  VARCHAR2,
   P_COMMIT                IN  VARCHAR2,
   P_CONTRACT_ID           IN  NUMBER   ,
   P_CUSTOMER_PRODUCT_ID   IN  NUMBER   ,
   P_CATEGORY_ID           IN  NUMBER   ,
   P_INVENTORY_ITEM_ID     IN  NUMBER   ,
   P_INVENTORY_ORG_ID      IN  NUMBER   ,
   P_PROBLEM_CODE          IN  VARCHAR2 ,
   P_SR_REC                IN  JTF_ASSIGN_PUB.JTF_SERV_REQ_REC_TYPE,
   P_SR_TASK_REC           IN  JTF_ASSIGN_PUB.JTF_SRV_TASK_REC_TYPE,
   P_BUSINESS_PROCESS_ID   IN  NUMBER,
   P_BUSINESS_PROCESS_DATE IN  DATE,
   X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY NUMBER,
   X_MSG_DATA              OUT NOCOPY VARCHAR2,
   --Added for Bug # 5386560
   P_INVENTORY_COMPONENT_ID IN  NUMBER   DEFAULT NULL
   --Added for Bug # 5386560 Ends here
   ) IS

   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.sr.assign';

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables


    IF(p_sr_rec.SERVICE_REQUEST_ID is not null)
    THEN
       wf_event.AddParameterToList('SERVICE_REQUEST_ID',p_sr_rec.SERVICE_REQUEST_ID,l_list);
    ELSE
       wf_event.AddParameterToList('SERVICE_REQUEST_ID',p_sr_task_rec.SERVICE_REQUEST_ID, l_list);
    END IF;

    wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_list);
    wf_event.AddParameterToList('CUSTOMER_PRODUT_ID',p_customer_product_id,l_list);
    wf_event.AddParameterToList('CATEGORY_ID',p_category_id,l_list);
    wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_inventory_item_id,l_list);
    wf_event.AddParameterToList('INVENTORY_ORG_ID',p_inventory_org_id,l_list);
    --Added for Bug # 5386560
    wf_event.AddParameterToList('INVENTORY_COMPONENT_ID',p_inventory_component_id,l_list);
    --Added for Bug # 5386560 Ends here
    wf_event.AddParameterToList('PROBLEM_CODE',p_problem_code,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);
    wf_event.AddParameterToList('TASK_ID',p_sr_task_rec.task_id, l_list);
    wf_event.AddParameterToList('TASK_TYPE_ID',p_sr_task_rec.task_type_id, l_list);
    wf_event.AddParameterToList('TASK_STATUS_ID',p_sr_task_rec.task_status_id,l_list);
    wf_event.AddParameterToList('TASK_PRIORITY_ID',p_sr_task_rec.task_priority_id,l_list);

    IF(p_sr_rec.PARTY_ID is not null)
    THEN
       wf_event.AddParameterToList('PARTY_ID',p_sr_rec.PARTY_ID,l_list);
    ELSE
       wf_event.AddParameterToList('PARTY_ID',p_sr_task_rec.PARTY_ID, l_list);
    END IF;
    IF(p_sr_rec.COUNTRY is not null)
    THEN
       wf_event.AddParameterToList('COUNTRY',p_sr_rec.COUNTRY,l_list);
    ELSE
       wf_event.AddParameterToList('COUNTRY',p_sr_task_rec.COUNTRY, l_list);
    END IF;

    IF(p_sr_rec.PARTY_SITE_ID is not null)
    THEN
       wf_event.AddParameterToList('PARTY_SITE_ID',p_sr_rec.PARTY_SITE_ID,l_list);
    ELSE
       wf_event.AddParameterToList('PARTY_SITE_ID',p_sr_task_rec.PARTY_SITE_ID, l_list);
    END IF;

    IF(p_sr_rec.CITY is not null)
    THEN
       wf_event.AddParameterToList('CITY',p_sr_rec.CITY,l_list);
    ELSE
       wf_event.AddParameterToList('CITY',p_sr_task_rec.CITY, l_list);
    END IF;
    IF(p_sr_rec.POSTAL_CODE is not null)
    THEN
       wf_event.AddParameterToList('POSTAL_CODE',p_sr_rec.POSTAL_CODE,l_list);
    ELSE
       wf_event.AddParameterToList('POSTAL_CODE',p_sr_task_rec.POSTAL_CODE, l_list);
    END IF;
    IF(p_sr_rec.STATE is not null)
    THEN
       wf_event.AddParameterToList('STATE',p_sr_rec.STATE,l_list);
    ELSE
       wf_event.AddParameterToList('STATE',p_sr_task_rec.STATE, l_list);
    END IF;
    IF(p_sr_rec.AREA_CODE  is not null)
    THEN
       wf_event.AddParameterToList('AREA_CODE',p_sr_rec.AREA_CODE ,l_list);
    ELSE
       wf_event.AddParameterToList('AREA_CODE',p_sr_task_rec.AREA_CODE, l_list);
    END IF;
    IF(p_sr_rec.COUNTY is not null)
    THEN
       wf_event.AddParameterToList('COUNTY',p_sr_rec.COUNTY,l_list);
    ELSE
       wf_event.AddParameterToList('COUNTY',p_sr_task_rec.COUNTY, l_list);
    END IF;
    IF(p_sr_rec.COMP_NAME_RANGE is not null)
    THEN
       wf_event.AddParameterToList('COMP_NAME_RANGE',p_sr_rec.COMP_NAME_RANGE,l_list);
    ELSE
       wf_event.AddParameterToList('COMP_NAME_RANGE',p_sr_task_rec.COMP_NAME_RANGE, l_list);
    END IF;
    IF(p_sr_rec.PROVINCE is not null)
    THEN
       wf_event.AddParameterToList('PROVINCE',p_sr_rec.PROVINCE,l_list);
    ELSE
       wf_event.AddParameterToList('PROVINCE',p_sr_task_rec.PROVINCE, l_list);
    END IF;
    IF(p_sr_rec.INCIDENT_SEVERITY_ID is not null)
    THEN
       wf_event.AddParameterToList('INCIDENT_SEVERITY_ID',p_sr_rec.INCIDENT_SEVERITY_ID,l_list);
    ELSE
       wf_event.AddParameterToList('INCIDENT_SEVERITY_ID',p_sr_task_rec.INCIDENT_SEVERITY_ID, l_list);
    END IF;
    IF(p_sr_rec.SERVICE_REQUEST_ID is not null)
    THEN
       wf_event.AddParameterToList('INCIDENT_URGENCY_ID',p_sr_rec.INCIDENT_URGENCY_ID,l_list);
    ELSE
       wf_event.AddParameterToList('INCIDENT_URGENCY_ID',p_sr_task_rec.INCIDENT_URGENCY_ID, l_list);
    END IF;
    IF(p_sr_rec.SERVICE_REQUEST_ID is not null)
    THEN
       wf_event.AddParameterToList('PROBLEM_CODE',p_sr_rec.PROBLEM_CODE,l_list);
    ELSE
       wf_event.AddParameterToList('PROBLEM_CODE',p_sr_task_rec.PROBLEM_CODE, l_list);
    END IF;

    IF(p_sr_rec.INCIDENT_STATUS_ID is not null)
    THEN
       wf_event.AddParameterToList('INCIDENT_STATUS_ID',p_sr_rec.INCIDENT_STATUS_ID,l_list);
    ELSE
       wf_event.AddParameterToList('INCIDENT_STATUS_ID',p_sr_task_rec.INCIDENT_STATUS_ID, l_list);
    END IF;

    IF(p_sr_rec.PLATFORM_ID is not null)
    THEN
       wf_event.AddParameterToList('PLATFORM_ID',p_sr_rec.PLATFORM_ID,l_list);
    ELSE
       wf_event.AddParameterToList('PLATFORM_ID',p_sr_task_rec.PLATFORM_ID, l_list);
    END IF;

    IF(p_sr_rec.SUPPORT_SITE_ID is not null)
    THEN
       wf_event.AddParameterToList('SUPPORT_SITE_ID',p_sr_rec.SUPPORT_SITE_ID,l_list);
    ELSE
       wf_event.AddParameterToList('SUPPORT_SITE_ID',p_sr_task_rec.SUPPORT_SITE_ID, l_list);
    END IF;
    IF(p_sr_rec.CUSTOMER_SITE_ID is not null)
    THEN
       wf_event.AddParameterToList('CUSTOMER_SITE_ID',p_sr_rec.CUSTOMER_SITE_ID,l_list);
    ELSE
       wf_event.AddParameterToList('CUSTOMER_SITE_ID',p_sr_task_rec.CUSTOMER_SITE_ID, l_list);
    END IF;
    IF(p_sr_rec.SR_CREATION_CHANNEL is not null)
    THEN
       wf_event.AddParameterToList('SR_CREATION_CHANNEL',p_sr_rec.SR_CREATION_CHANNEL,l_list);
    ELSE
       wf_event.AddParameterToList('SR_CREATION_CHANNEL',p_sr_task_rec.SR_CREATION_CHANNEL, l_list);
    END IF;
    IF(p_sr_rec.INVENTORY_ITEM_ID is not null)
    THEN
       wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_sr_rec.INVENTORY_ITEM_ID,l_list);
    ELSE
       wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_sr_task_rec.INVENTORY_ITEM_ID, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM12 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM12',p_sr_rec.SQUAL_NUM12,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM12',p_sr_task_rec.SQUAL_NUM12, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM13 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM13',p_sr_rec.SQUAL_NUM13,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM13',p_sr_task_rec.SQUAL_NUM13, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM13 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM13',p_sr_rec.SQUAL_NUM13,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM13',p_sr_task_rec.SQUAL_NUM13, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM14 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM14',p_sr_rec.SQUAL_NUM14,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM14',p_sr_task_rec.SQUAL_NUM14, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM15 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM15',p_sr_rec.SQUAL_NUM15,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM15',p_sr_task_rec.SQUAL_NUM15, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM16 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM16',p_sr_rec.SQUAL_NUM16,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM16',p_sr_task_rec.SQUAL_NUM16, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM17 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM17',p_sr_rec.SQUAL_NUM17,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM17',p_sr_task_rec.SQUAL_NUM17, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_NUM18 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM18',p_sr_rec.SQUAL_NUM18,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM18',p_sr_task_rec.SQUAL_NUM18, l_list);
    END IF;
     IF(p_sr_rec.SQUAL_NUM19  is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_NUM19',p_sr_rec.SQUAL_NUM19 ,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_NUM19',p_sr_task_rec.SQUAL_NUM19 , l_list);
    END IF;
    IF(p_sr_rec.SQUAL_CHAR11 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_CHAR11',p_sr_rec.SQUAL_CHAR11,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_CHAR11',p_sr_task_rec.SQUAL_CHAR11, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_CHAR13 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_CHAR13',p_sr_rec.SQUAL_CHAR13,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_CHAR13',p_sr_task_rec.SQUAL_CHAR13, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_CHAR20 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_CHAR20',p_sr_rec.SQUAL_CHAR20,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_CHAR20',p_sr_task_rec.SQUAL_CHAR20, l_list);
    END IF;
    IF(p_sr_rec.SQUAL_CHAR21 is not null)
    THEN
       wf_event.AddParameterToList('SQUAL_CHAR21',p_sr_rec.SQUAL_CHAR21,l_list);
    ELSE
       wf_event.AddParameterToList('SQUAL_CHAR21',p_sr_task_rec.SQUAL_CHAR21, l_list);
    END IF;
    /********** Start of addition by SBARAT on 10/01/2005 for Enh 4112155 ***************/
    IF(p_sr_rec.ITEM_COMPONENT is not null)
    THEN
       wf_event.AddParameterToList('ITEM_COMPONENT',p_sr_rec.ITEM_COMPONENT,l_list);
    ELSE
       wf_event.AddParameterToList('ITEM_COMPONENT',p_sr_task_rec.ITEM_COMPONENT, l_list);
    END IF;
    IF(p_sr_rec.ITEM_SUBCOMPONENT is not null)
    THEN
       wf_event.AddParameterToList('ITEM_SUBCOMPONENT',p_sr_rec.ITEM_SUBCOMPONENT,l_list);
    ELSE
       wf_event.AddParameterToList('ITEM_SUBCOMPONENT',p_sr_task_rec.ITEM_SUBCOMPONENT, l_list);
    END IF;
    /********** End of addition by SBARAT on 10/01/2005 for Enh 4112155 ***************/

    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_sr_resource;

 /*********** Added by SBARAT on 01/11/2004 for Enh-3919046 ***********/

 PROCEDURE assign_dr_resource
  (P_API_VERSION           IN  NUMBER,
   P_INIT_MSG_LIST         IN  VARCHAR2,
   P_COMMIT                IN  VARCHAR2,
   P_CONTRACT_ID           IN  NUMBER   ,
   P_CUSTOMER_PRODUCT_ID   IN  NUMBER   ,
   P_CATEGORY_ID           IN  NUMBER   ,
   P_INVENTORY_ITEM_ID     IN  NUMBER   ,
   P_INVENTORY_ORG_ID      IN  NUMBER   ,
   P_PROBLEM_CODE          IN  VARCHAR2 ,
   P_DR_REC                IN  JTF_ASSIGN_PUB.JTF_DR_REC_TYPE,
   P_BUSINESS_PROCESS_ID   IN  NUMBER,
   P_BUSINESS_PROCESS_DATE IN  DATE,
   X_RETURN_STATUS         OUT NOCOPY VARCHAR2,
   X_MSG_COUNT             OUT NOCOPY NUMBER,
   X_MSG_DATA              OUT NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.dr.assign';

 BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables


    wf_event.AddParameterToList('SERVICE_REQUEST_ID',p_dr_rec.SERVICE_REQUEST_ID, l_list);

    wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_list);
    wf_event.AddParameterToList('CUSTOMER_PRODUT_ID',p_customer_product_id,l_list);
    wf_event.AddParameterToList('CATEGORY_ID',p_category_id,l_list);
    wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_inventory_item_id,l_list);
    wf_event.AddParameterToList('INVENTORY_ORG_ID',p_inventory_org_id,l_list);

    IF (p_problem_code IS NOT NULL)
    THEN
      wf_event.AddParameterToList('PROBLEM_CODE',p_problem_code,l_list);
    ELSE
      wf_event.AddParameterToList('PROBLEM_CODE',p_dr_rec.PROBLEM_CODE, l_list);
    END IF;

    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);
    wf_event.AddParameterToList('TASK_ID',p_dr_rec.task_id, l_list);
    wf_event.AddParameterToList('TASK_TYPE_ID',p_dr_rec.task_type_id, l_list);
    wf_event.AddParameterToList('TASK_STATUS_ID',p_dr_rec.task_status_id,l_list);
    wf_event.AddParameterToList('TASK_PRIORITY_ID',p_dr_rec.task_priority_id,l_list);

    wf_event.AddParameterToList('PARTY_ID',p_dr_rec.PARTY_ID, l_list);
    wf_event.AddParameterToList('COUNTRY',p_dr_rec.COUNTRY, l_list);
    wf_event.AddParameterToList('PARTY_SITE_ID',p_dr_rec.PARTY_SITE_ID, l_list);
    wf_event.AddParameterToList('CITY',p_dr_rec.CITY, l_list);
    wf_event.AddParameterToList('POSTAL_CODE',p_dr_rec.POSTAL_CODE, l_list);
    wf_event.AddParameterToList('STATE',p_dr_rec.STATE, l_list);
    wf_event.AddParameterToList('AREA_CODE',p_dr_rec.AREA_CODE, l_list);
    wf_event.AddParameterToList('COUNTY',p_dr_rec.COUNTY, l_list);
    wf_event.AddParameterToList('COMP_NAME_RANGE',p_dr_rec.COMP_NAME_RANGE, l_list);
    wf_event.AddParameterToList('PROVINCE',p_dr_rec.PROVINCE, l_list);
    wf_event.AddParameterToList('INCIDENT_SEVERITY_ID',p_dr_rec.INCIDENT_SEVERITY_ID, l_list);
    wf_event.AddParameterToList('INCIDENT_URGENCY_ID',p_dr_rec.INCIDENT_URGENCY_ID, l_list);
    wf_event.AddParameterToList('INCIDENT_STATUS_ID',p_dr_rec.INCIDENT_STATUS_ID, l_list);
    wf_event.AddParameterToList('PLATFORM_ID',p_dr_rec.PLATFORM_ID, l_list);
    wf_event.AddParameterToList('SUPPORT_SITE_ID',p_dr_rec.SUPPORT_SITE_ID, l_list);
    wf_event.AddParameterToList('CUSTOMER_SITE_ID',p_dr_rec.CUSTOMER_SITE_ID, l_list);
    wf_event.AddParameterToList('SR_CREATION_CHANNEL',p_dr_rec.SR_CREATION_CHANNEL, l_list);
    wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_dr_rec.INVENTORY_ITEM_ID, l_list);
    wf_event.AddParameterToList('SQUAL_NUM12',p_dr_rec.SQUAL_NUM12, l_list);
    wf_event.AddParameterToList('SQUAL_NUM13',p_dr_rec.SQUAL_NUM13, l_list);
    wf_event.AddParameterToList('SQUAL_NUM13',p_dr_rec.SQUAL_NUM13, l_list);
    wf_event.AddParameterToList('SQUAL_NUM14',p_dr_rec.SQUAL_NUM14, l_list);
    wf_event.AddParameterToList('SQUAL_NUM15',p_dr_rec.SQUAL_NUM15, l_list);
    wf_event.AddParameterToList('SQUAL_NUM16',p_dr_rec.SQUAL_NUM16, l_list);
    wf_event.AddParameterToList('SQUAL_NUM17',p_dr_rec.SQUAL_NUM17, l_list);
    wf_event.AddParameterToList('SQUAL_NUM18',p_dr_rec.SQUAL_NUM18, l_list);
    wf_event.AddParameterToList('SQUAL_NUM19',p_dr_rec.SQUAL_NUM19 , l_list);
    wf_event.AddParameterToList('SQUAL_CHAR11',p_dr_rec.SQUAL_CHAR11, l_list);
    wf_event.AddParameterToList('SQUAL_CHAR13',p_dr_rec.SQUAL_CHAR13, l_list);
    wf_event.AddParameterToList('SQUAL_CHAR20',p_dr_rec.SQUAL_CHAR20, l_list);
    wf_event.AddParameterToList('SQUAL_CHAR21',p_dr_rec.SQUAL_CHAR21, l_list);
    wf_event.AddParameterToList('ATTRIBUTE1',p_dr_rec.ATTRIBUTE1, l_list);
    wf_event.AddParameterToList('ATTRIBUTE2',p_dr_rec.ATTRIBUTE2, l_list);
    wf_event.AddParameterToList('ATTRIBUTE3',p_dr_rec.ATTRIBUTE3, l_list);
    wf_event.AddParameterToList('ATTRIBUTE4',p_dr_rec.ATTRIBUTE4, l_list);
    wf_event.AddParameterToList('ATTRIBUTE5',p_dr_rec.ATTRIBUTE5, l_list);
    wf_event.AddParameterToList('ATTRIBUTE6',p_dr_rec.ATTRIBUTE6, l_list);
    wf_event.AddParameterToList('ATTRIBUTE7',p_dr_rec.ATTRIBUTE7, l_list);
    wf_event.AddParameterToList('ATTRIBUTE8',p_dr_rec.ATTRIBUTE8, l_list);
    wf_event.AddParameterToList('ATTRIBUTE9',p_dr_rec.ATTRIBUTE9, l_list);
    wf_event.AddParameterToList('ATTRIBUTE10',p_dr_rec.ATTRIBUTE10, l_list);
    wf_event.AddParameterToList('ATTRIBUTE11',p_dr_rec.ATTRIBUTE11, l_list);
    wf_event.AddParameterToList('ATTRIBUTE12',p_dr_rec.ATTRIBUTE12, l_list);
    wf_event.AddParameterToList('ATTRIBUTE13',p_dr_rec.ATTRIBUTE13, l_list);
    wf_event.AddParameterToList('ATTRIBUTE14',p_dr_rec.ATTRIBUTE14, l_list);
    wf_event.AddParameterToList('ATTRIBUTE15',p_dr_rec.ATTRIBUTE15, l_list);


    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_dr_resource;

 /*********** End of addition by SBARAT on 01/11/2004 for Enh-3919046 ***********/


/********************** Start of Addition for Enh. No 3076744 by SBARAT, 20/09/2004 ************************/

 PROCEDURE assign_task_resource
  (P_API_VERSION			IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT               	IN   VARCHAR2,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   P_TASK_ID               	IN   JTF_TASKS_VL.TASK_ID%TYPE,
   P_CONTRACT_ID           	IN   NUMBER,
   P_CUSTOMER_PRODUCT_ID   	IN   NUMBER,
   P_CATEGORY_ID           	IN   NUMBER,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.task.assign';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_task_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);
    wf_event.AddParameterToList('TASK_ID',p_task_id,l_list);
    wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_list);
    wf_event.AddParameterToList('CUSTOMER_PRODUCT_ID',p_customer_product_id,l_list);
    wf_event.AddParameterToList('CATEGORY_ID',p_category_id,l_list);


    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_task_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_task_resource;


 PROCEDURE assign_esc_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST        	IN   VARCHAR2,
   P_COMMIT               	IN   VARCHAR2,
   P_ESC_REC		   	IN   JTF_ASSIGN_PUB.Escalations_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.esc.assign';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_esc_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('SOURCE_OBJECT_ID',p_esc_rec.source_object_id,l_list);
    wf_event.AddParameterToList('SOURCE_OBJECT_TYPE',p_esc_rec.source_object_type,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);


    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_esc_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_esc_resource;


 PROCEDURE assign_def_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_CONTRACT_ID           	IN   NUMBER,
   P_CUSTOMER_PRODUCT_ID   	IN   NUMBER,
   P_CATEGORY_ID           	IN   NUMBER,
   P_DEF_MGMT_REC			IN   JTF_ASSIGN_PUB.JTF_DEF_MGMT_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   ) IS


   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.def.assign';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_def_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('CONTRACT_ID',p_contract_id,l_list);
    wf_event.AddParameterToList('CUSTOMER_PRODUCT_ID',p_customer_product_id,l_list);
    wf_event.AddParameterToList('CATEGORY_ID',p_category_id,l_list);

    wf_event.AddParameterToList('SQUAL_CHAR01',p_def_mgmt_rec.squal_char01,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR02',p_def_mgmt_rec.squal_char02,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR03',p_def_mgmt_rec.squal_char03,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR04',p_def_mgmt_rec.squal_char04,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR05',p_def_mgmt_rec.squal_char05,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR06',p_def_mgmt_rec.squal_char06,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR07',p_def_mgmt_rec.squal_char07,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR08',p_def_mgmt_rec.squal_char08,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR09',p_def_mgmt_rec.squal_char09,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR10',p_def_mgmt_rec.squal_char10,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR11',p_def_mgmt_rec.squal_char11,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR12',p_def_mgmt_rec.squal_char12,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR13',p_def_mgmt_rec.squal_char13,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR14',p_def_mgmt_rec.squal_char14,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR15',p_def_mgmt_rec.squal_char15,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR16',p_def_mgmt_rec.squal_char16,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR17',p_def_mgmt_rec.squal_char17,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR18',p_def_mgmt_rec.squal_char18,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR19',p_def_mgmt_rec.squal_char19,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR20',p_def_mgmt_rec.squal_char20,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR21',p_def_mgmt_rec.squal_char21,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR22',p_def_mgmt_rec.squal_char22,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR23',p_def_mgmt_rec.squal_char23,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR24',p_def_mgmt_rec.squal_char24,l_list);
    wf_event.AddParameterToList('SQUAL_CHAR25',p_def_mgmt_rec.squal_char25,l_list);

    wf_event.AddParameterToList('SQUAL_NUM01',p_def_mgmt_rec.squal_num01,l_list);
    wf_event.AddParameterToList('SQUAL_NUM02',p_def_mgmt_rec.squal_num02,l_list);
    wf_event.AddParameterToList('SQUAL_NUM03',p_def_mgmt_rec.squal_num03,l_list);
    wf_event.AddParameterToList('SQUAL_NUM04',p_def_mgmt_rec.squal_num04,l_list);
    wf_event.AddParameterToList('SQUAL_NUM05',p_def_mgmt_rec.squal_num05,l_list);
    wf_event.AddParameterToList('SQUAL_NUM06',p_def_mgmt_rec.squal_num06,l_list);
    wf_event.AddParameterToList('SQUAL_NUM07',p_def_mgmt_rec.squal_num07,l_list);
    wf_event.AddParameterToList('SQUAL_NUM08',p_def_mgmt_rec.squal_num08,l_list);
    wf_event.AddParameterToList('SQUAL_NUM09',p_def_mgmt_rec.squal_num09,l_list);
    wf_event.AddParameterToList('SQUAL_NUM10',p_def_mgmt_rec.squal_num10,l_list);
    wf_event.AddParameterToList('SQUAL_NUM11',p_def_mgmt_rec.squal_num11,l_list);
    wf_event.AddParameterToList('SQUAL_NUM12',p_def_mgmt_rec.squal_num12,l_list);
    wf_event.AddParameterToList('SQUAL_NUM13',p_def_mgmt_rec.squal_num13,l_list);
    wf_event.AddParameterToList('SQUAL_NUM14',p_def_mgmt_rec.squal_num14,l_list);
    wf_event.AddParameterToList('SQUAL_NUM15',p_def_mgmt_rec.squal_num15,l_list);
    wf_event.AddParameterToList('SQUAL_NUM16',p_def_mgmt_rec.squal_num16,l_list);
    wf_event.AddParameterToList('SQUAL_NUM17',p_def_mgmt_rec.squal_num17,l_list);
    wf_event.AddParameterToList('SQUAL_NUM18',p_def_mgmt_rec.squal_num18,l_list);
    wf_event.AddParameterToList('SQUAL_NUM19',p_def_mgmt_rec.squal_num19,l_list);
    wf_event.AddParameterToList('SQUAL_NUM20',p_def_mgmt_rec.squal_num20,l_list);
    wf_event.AddParameterToList('SQUAL_NUM21',p_def_mgmt_rec.squal_num21,l_list);
    wf_event.AddParameterToList('SQUAL_NUM22',p_def_mgmt_rec.squal_num22,l_list);
    wf_event.AddParameterToList('SQUAL_NUM23',p_def_mgmt_rec.squal_num23,l_list);
    wf_event.AddParameterToList('SQUAL_NUM24',p_def_mgmt_rec.squal_num24,l_list);
    wf_event.AddParameterToList('SQUAL_NUM25',p_def_mgmt_rec.squal_num25,l_list);

    wf_event.AddParameterToList('ATTRIBUTE1',p_def_mgmt_rec.attribute1,l_list);
    wf_event.AddParameterToList('ATTRIBUTE2',p_def_mgmt_rec.attribute2,l_list);
    wf_event.AddParameterToList('ATTRIBUTE3',p_def_mgmt_rec.attribute3,l_list);
    wf_event.AddParameterToList('ATTRIBUTE4',p_def_mgmt_rec.attribute4,l_list);
    wf_event.AddParameterToList('ATTRIBUTE5',p_def_mgmt_rec.attribute5,l_list);
    wf_event.AddParameterToList('ATTRIBUTE6',p_def_mgmt_rec.attribute6,l_list);
    wf_event.AddParameterToList('ATTRIBUTE7',p_def_mgmt_rec.attribute7,l_list);
    wf_event.AddParameterToList('ATTRIBUTE8',p_def_mgmt_rec.attribute8,l_list);
    wf_event.AddParameterToList('ATTRIBUTE9',p_def_mgmt_rec.attribute9,l_list);
    wf_event.AddParameterToList('ATTRIBUTE10',p_def_mgmt_rec.attribute10,l_list);
    wf_event.AddParameterToList('ATTRIBUTE11',p_def_mgmt_rec.attribute11,l_list);
    wf_event.AddParameterToList('ATTRIBUTE12',p_def_mgmt_rec.attribute12,l_list);
    wf_event.AddParameterToList('ATTRIBUTE13',p_def_mgmt_rec.attribute13,l_list);
    wf_event.AddParameterToList('ATTRIBUTE14',p_def_mgmt_rec.attribute14,l_list);
    wf_event.AddParameterToList('ATTRIBUTE15',p_def_mgmt_rec.attribute15,l_list);


    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);


    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_def_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_def_resource;


 PROCEDURE assign_acc_resource
  (P_API_VERSION			IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_ACCOUNT_REC			IN   JTF_ASSIGN_PUB.JTF_Account_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT            	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.acc.assign';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_acc_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('CITY',p_account_rec.city,l_list);
    wf_event.AddParameterToList('POSTAL_CODE',p_account_rec.postal_code,l_list);
    wf_event.AddParameterToList('STATE',p_account_rec.state,l_list);
    wf_event.AddParameterToList('PROVINCE',p_account_rec.province,l_list);
    wf_event.AddParameterToList('COUNTY',p_account_rec.county,l_list);
    wf_event.AddParameterToList('COUNTRY',p_account_rec.country,l_list);
    wf_event.AddParameterToList('INTEREST_TYPE_ID',p_account_rec.interest_type_id,l_list);
    wf_event.AddParameterToList('PRIMARY_INTEREST_ID',p_account_rec.primary_interest_id,l_list);
    wf_event.AddParameterToList('SECONDARY_INTEREST_ID',p_account_rec.secondary_interest_id,l_list);
    wf_event.AddParameterToList('CONTACT_INTEREST_TYPE_ID',p_account_rec.contact_interest_type_id,l_list);
    wf_event.AddParameterToList('CONTACT_PRIMARY_INTEREST_ID',p_account_rec.contact_primary_interest_id,l_list);
    wf_event.AddParameterToList('CONTACT_SECONDARY_INTEREST_ID',p_account_rec.contact_secondary_interest_id,l_list);
    wf_event.AddParameterToList('PARTY_SITE_ID',p_account_rec.party_site_id,l_list);
    wf_event.AddParameterToList('PARTY_ID',p_account_rec.party_id,l_list);
    wf_event.AddParameterToList('PARTNER_ID',p_account_rec.partner_id,l_list);
    wf_event.AddParameterToList('NUM_OF_EMPLOYEES',p_account_rec.num_of_employees,l_list);
    wf_event.AddParameterToList('CATEGORY_CODE',p_account_rec.category_code,l_list);
    wf_event.AddParameterToList('PARTY_RELATIONSHIP_ID',p_account_rec.party_relationship_id,l_list);
    wf_event.AddParameterToList('SIC_CODE',p_account_rec.sic_code,l_list);
    wf_event.AddParameterToList('ATTRIBUTE1',p_account_rec.attribute1,l_list);
    wf_event.AddParameterToList('ATTRIBUTE2',p_account_rec.attribute2,l_list);
    wf_event.AddParameterToList('ATTRIBUTE3',p_account_rec.attribute3,l_list);
    wf_event.AddParameterToList('ATTRIBUTE4',p_account_rec.attribute4,l_list);
    wf_event.AddParameterToList('ATTRIBUTE5',p_account_rec.attribute5,l_list);
    wf_event.AddParameterToList('ATTRIBUTE6',p_account_rec.attribute6,l_list);
    wf_event.AddParameterToList('ATTRIBUTE7',p_account_rec.attribute7,l_list);
    wf_event.AddParameterToList('ATTRIBUTE8',p_account_rec.attribute8,l_list);
    wf_event.AddParameterToList('ATTRIBUTE9',p_account_rec.attribute9,l_list);
    wf_event.AddParameterToList('ATTRIBUTE10',p_account_rec.attribute10,l_list);
    wf_event.AddParameterToList('ATTRIBUTE11',p_account_rec.attribute11,l_list);
    wf_event.AddParameterToList('ATTRIBUTE12',p_account_rec.attribute12,l_list);
    wf_event.AddParameterToList('ATTRIBUTE13',p_account_rec.attribute13,l_list);
    wf_event.AddParameterToList('ATTRIBUTE14',p_account_rec.attribute14,l_list);
    wf_event.AddParameterToList('ATTRIBUTE15',p_account_rec.attribute15,l_list);
    wf_event.AddParameterToList('ORG_ID',p_account_rec.org_id,l_list);


    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);


    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_acc_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_acc_resource;


 PROCEDURE assign_oppr_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_OPPR_REC         		IN   JTF_ASSIGN_PUB.JTF_Oppor_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   ) IS


   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.oppr.assign';

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_oppr_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    --Get the item key
    l_key := item_key(l_event_name);

    -- initialization of object variables

    wf_event.AddParameterToList('LEAD_ID',p_oppr_rec.lead_id,l_list);
    wf_event.AddParameterToList('LEAD_LINE_ID',p_oppr_rec.lead_line_id,l_list);
    wf_event.AddParameterToList('CITY',p_oppr_rec.city,l_list);
    wf_event.AddParameterToList('POSTAL_CODE',p_oppr_rec.postal_code,l_list);
    wf_event.AddParameterToList('STATE',p_oppr_rec.state,l_list);
    wf_event.AddParameterToList('PROVINCE',p_oppr_rec.province,l_list);
    wf_event.AddParameterToList('COUNTY',p_oppr_rec.county,l_list);
    wf_event.AddParameterToList('COUNTRY',p_oppr_rec.country,l_list);
    wf_event.AddParameterToList('INTEREST_TYPE_ID',p_oppr_rec.interest_type_id,l_list);
    wf_event.AddParameterToList('PRIMARY_INTEREST_ID',p_oppr_rec.primary_interest_id,l_list);
    wf_event.AddParameterToList('SECONDARY_INTEREST_ID',p_oppr_rec.secondary_interest_id,l_list);
    wf_event.AddParameterToList('CONTACT_INTEREST_TYPE_ID',p_oppr_rec.contact_interest_type_id,l_list);
    wf_event.AddParameterToList('CONTACT_PRIMARY_INTEREST_ID',p_oppr_rec.contact_primary_interest_id,l_list);
    wf_event.AddParameterToList('CONTACT_SECONDARY_INTEREST_ID',p_oppr_rec.contact_secondary_interest_id,l_list);
    wf_event.AddParameterToList('PARTY_SITE_ID',p_oppr_rec.party_site_id,l_list);
    wf_event.AddParameterToList('AREA_CODE',p_oppr_rec.area_code,l_list);
    wf_event.AddParameterToList('PARTY_ID',p_oppr_rec.party_id,l_list);
    wf_event.AddParameterToList('COMP_NAME_RANGE',p_oppr_rec.comp_name_range,l_list);
    wf_event.AddParameterToList('PARTNER_ID',p_oppr_rec.partner_id,l_list);
    wf_event.AddParameterToList('NUM_OF_EMPLOYEES',p_oppr_rec.num_of_employees,l_list);
    wf_event.AddParameterToList('CATEGORY_CODE',p_oppr_rec.category_code,l_list);
    wf_event.AddParameterToList('PARTY_RELATIONSHIP_ID',p_oppr_rec.party_relationship_id,l_list);
    wf_event.AddParameterToList('SIC_CODE',p_oppr_rec.sic_code,l_list);
    wf_event.AddParameterToList('TARGET_SEGMENT_CURRENT',p_oppr_rec.target_segment_current,l_list);
    wf_event.AddParameterToList('TOTAL_AMOUNT',p_oppr_rec.total_amount,l_list);
    wf_event.AddParameterToList('CURRENCY_CODE',p_oppr_rec.currency_code,l_list);
    wf_event.AddParameterToList('PRICING_DATE',p_oppr_rec.pricing_date,l_list);
    wf_event.AddParameterToList('CHANNEL_CODE',p_oppr_rec.channel_code,l_list);
    wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_oppr_rec.inventory_item_id,l_list);
    wf_event.AddParameterToList('OPP_INTEREST_TYPE_ID',p_oppr_rec.opp_interest_type_id,l_list);
    wf_event.AddParameterToList('OPP_PRIMARY_INTEREST_ID',p_oppr_rec.opp_primary_interest_id,l_list);
    wf_event.AddParameterToList('OPP_SECONDARY_INTEREST_ID',p_oppr_rec.opp_secondary_interest_id,l_list);
    wf_event.AddParameterToList('OPCLSS_INTEREST_TYPE_ID',p_oppr_rec.opclss_interest_type_id,l_list);
    wf_event.AddParameterToList('OPCLSS_PRIMARY_INTEREST_ID',p_oppr_rec.opclss_primary_interest_id,l_list);
    wf_event.AddParameterToList('OPCLSS_SECONDARY_INTEREST_ID',p_oppr_rec.opclss_secondary_interest_id,l_list);
    wf_event.AddParameterToList('ATTRIBUTE1',p_oppr_rec.attribute1,l_list);
    wf_event.AddParameterToList('ATTRIBUTE2',p_oppr_rec.attribute2,l_list);
    wf_event.AddParameterToList('ATTRIBUTE3',p_oppr_rec.attribute3,l_list);
    wf_event.AddParameterToList('ATTRIBUTE4',p_oppr_rec.attribute4,l_list);
    wf_event.AddParameterToList('ATTRIBUTE5',p_oppr_rec.attribute5,l_list);
    wf_event.AddParameterToList('ATTRIBUTE6',p_oppr_rec.attribute6,l_list);
    wf_event.AddParameterToList('ATTRIBUTE7',p_oppr_rec.attribute7,l_list);
    wf_event.AddParameterToList('ATTRIBUTE8',p_oppr_rec.attribute8,l_list);
    wf_event.AddParameterToList('ATTRIBUTE9',p_oppr_rec.attribute9,l_list);
    wf_event.AddParameterToList('ATTRIBUTE10',p_oppr_rec.attribute10,l_list);
    wf_event.AddParameterToList('ATTRIBUTE11',p_oppr_rec.attribute11,l_list);
    wf_event.AddParameterToList('ATTRIBUTE12',p_oppr_rec.attribute12,l_list);
    wf_event.AddParameterToList('ATTRIBUTE13',p_oppr_rec.attribute13,l_list);
    wf_event.AddParameterToList('ATTRIBUTE14',p_oppr_rec.attribute14,l_list);
    wf_event.AddParameterToList('ATTRIBUTE15',p_oppr_rec.attribute15,l_list);
    wf_event.AddParameterToList('ORG_ID',p_oppr_rec.org_id,l_list);


    wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
    wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);


    -- Raise Event
    wf_event.raise(
                   p_event_name        => l_event_name
                  ,p_event_key         => l_key
                  ,p_event_data        => null
                  ,p_parameters        => l_list
                  );

    l_list.DELETE;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_oppr_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_oppr_resource;


  PROCEDURE assign_lead_resource
  (P_API_VERSION           	IN   NUMBER,
   P_INIT_MSG_LIST         	IN   VARCHAR2,
   P_COMMIT                	IN   VARCHAR2,
   P_LEAD_REC                	IN   JTF_ASSIGN_PUB.JTF_Lead_rec_type,
   P_LEAD_BULK_REC           	IN   JTF_TERRITORY_PUB.JTF_Lead_BULK_rec_type,
   P_BUSINESS_PROCESS_ID   	IN   NUMBER,
   P_BUSINESS_PROCESS_DATE 	IN   DATE,
   X_RETURN_STATUS         	OUT  NOCOPY VARCHAR2,
   X_MSG_COUNT             	OUT  NOCOPY NUMBER,
   X_MSG_DATA              	OUT  NOCOPY VARCHAR2
   ) IS

   l_api_version            CONSTANT   NUMBER       := 1.0;
   l_api_name               CONSTANT   VARCHAR2(30) := 'ASSIGN_RESOURCE';
   l_sysdate                date                    := trunc(sysdate);

   l_list                   WF_PARAMETER_LIST_T;
   l_key                    varchar2(240);
   l_exist                  varchar2(30);
   l_event_name             varchar2(240)           := 'oracle.apps.jtf.jasg.lead.assign';
   i				    Number;

  BEGIN

    x_return_status := fnd_api.g_ret_sts_success;
    savepoint asg_lead_publish_save;

    IF NOT fnd_api.compatible_api_call(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
       RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --Initialize the message List if P_INIT_MSG_LIST is NOT NULL and set to TRUE
    if p_init_msg_list is not NULL AND fnd_api.to_boolean(p_init_msg_list)
    then
       fnd_msg_pub.Initialize;
    end if;

    IF (p_lead_bulk_rec.PARTY_ID.COUNT > 0)
    THEN
	i := p_lead_bulk_rec.PARTY_ID.FIRST;
	WHILE (i <= p_lead_bulk_rec.PARTY_ID.LAST)
	LOOP

      --Get the item key
      l_key := item_key(l_event_name);

      -- initialization of object variables
      -- Code modified by SBARAT on 14/07/2005 for bug# 4164758
      -- checking existancy before initializing

      IF p_lead_bulk_rec.SALES_LEAD_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('SALES_LEAD_ID',p_lead_bulk_rec.SALES_LEAD_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('SALES_LEAD_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.SALES_LEAD_LINE_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('SALES_LEAD_LINE_ID',p_lead_bulk_rec.SALES_LEAD_LINE_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('SALES_LEAD_LINE_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.CITY.Exists(i)
      THEN
    	   wf_event.AddParameterToList('CITY',p_lead_bulk_rec.CITY(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('CITY',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.POSTAL_CODE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('POSTAL_CODE',p_lead_bulk_rec.POSTAL_CODE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('POSTAL_CODE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.STATE.Exists(i)
      THEN
     	   wf_event.AddParameterToList('STATE',p_lead_bulk_rec.STATE(i),l_list);
      ELSE
     	   wf_event.AddParameterToList('STATE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PROVINCE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PROVINCE',p_lead_bulk_rec.PROVINCE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PROVINCE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.COUNTY.Exists(i)
      THEN
    	   wf_event.AddParameterToList('COUNTY',p_lead_bulk_rec.COUNTY(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('COUNTY',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.COUNTRY.Exists(i)
      THEN
    	   wf_event.AddParameterToList('COUNTRY',p_lead_bulk_rec.COUNTRY(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('COUNTRY',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.INTEREST_TYPE_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('INTEREST_TYPE_ID',p_lead_bulk_rec.INTEREST_TYPE_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('INTEREST_TYPE_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PRIMARY_INTEREST_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PRIMARY_INTEREST_ID',p_lead_bulk_rec.PRIMARY_INTEREST_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PRIMARY_INTEREST_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.SECONDARY_INTEREST_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('SECONDARY_INTEREST_ID',p_lead_bulk_rec.SECONDARY_INTEREST_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('SECONDARY_INTEREST_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PARTY_SITE_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PARTY_SITE_ID',p_lead_bulk_rec.PARTY_SITE_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PARTY_SITE_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.AREA_CODE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('AREA_CODE',p_lead_bulk_rec.AREA_CODE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('AREA_CODE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PARTY_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PARTY_ID',p_lead_bulk_rec.PARTY_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PARTY_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.COMP_NAME_RANGE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('COMP_NAME_RANGE',p_lead_bulk_rec.COMP_NAME_RANGE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('COMP_NAME_RANGE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PARTNER_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PARTNER_ID',p_lead_bulk_rec.PARTNER_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PARTNER_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.NUM_OF_EMPLOYEES.Exists(i)
      THEN
    	   wf_event.AddParameterToList('NUM_OF_EMPLOYEES',p_lead_bulk_rec.NUM_OF_EMPLOYEES(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('NUM_OF_EMPLOYEES',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.CATEGORY_CODE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('CATEGORY_CODE',p_lead_bulk_rec.CATEGORY_CODE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('CATEGORY_CODE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PARTY_RELATIONSHIP_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PARTY_RELATIONSHIP_ID',p_lead_bulk_rec.PARTY_RELATIONSHIP_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PARTY_RELATIONSHIP_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.SIC_CODE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('SIC_CODE',p_lead_bulk_rec.SIC_CODE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('SIC_CODE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.BUDGET_AMOUNT.Exists(i)
      THEN
    	   wf_event.AddParameterToList('BUDGET_AMOUNT',p_lead_bulk_rec.BUDGET_AMOUNT(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('BUDGET_AMOUNT',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.CURRENCY_CODE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('CURRENCY_CODE',p_lead_bulk_rec.CURRENCY_CODE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('CURRENCY_CODE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PRICING_DATE.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PRICING_DATE',p_lead_bulk_rec.PRICING_DATE(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PRICING_DATE',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.SOURCE_PROMOTION_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('SOURCE_PROMOTION_ID',p_lead_bulk_rec.SOURCE_PROMOTION_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('SOURCE_PROMOTION_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.INVENTORY_ITEM_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_lead_bulk_rec.INVENTORY_ITEM_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('INVENTORY_ITEM_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.LEAD_INTEREST_TYPE_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('LEAD_INTEREST_TYPE_ID',p_lead_bulk_rec.LEAD_INTEREST_TYPE_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('LEAD_INTEREST_TYPE_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.LEAD_PRIMARY_INTEREST_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('LEAD_PRIMARY_INTEREST_ID',p_lead_bulk_rec.LEAD_PRIMARY_INTEREST_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('LEAD_PRIMARY_INTEREST_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.LEAD_SECONDARY_INTEREST_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('LEAD_SECONDARY_INTEREST_ID',p_lead_bulk_rec.LEAD_SECONDARY_INTEREST_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('LEAD_SECONDARY_INTEREST_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.PURCHASE_AMOUNT.Exists(i)
      THEN
    	   wf_event.AddParameterToList('PURCHASE_AMOUNT',p_lead_bulk_rec.PURCHASE_AMOUNT(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('PURCHASE_AMOUNT',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE1.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE1',p_lead_bulk_rec.ATTRIBUTE1(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE1',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE2.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE2',p_lead_bulk_rec.ATTRIBUTE2(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE2',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE3.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE3',p_lead_bulk_rec.ATTRIBUTE3(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE3',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE4.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE4',p_lead_bulk_rec.ATTRIBUTE4(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE4',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE5.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE5',p_lead_bulk_rec.ATTRIBUTE5(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE5',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE6.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE6',p_lead_bulk_rec.ATTRIBUTE6(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE6',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE7.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE7',p_lead_bulk_rec.ATTRIBUTE7(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE7',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE8.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE8',p_lead_bulk_rec.ATTRIBUTE8(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE8',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE9.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE9',p_lead_bulk_rec.ATTRIBUTE9(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE9',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE10.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE10',p_lead_bulk_rec.ATTRIBUTE10(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE10',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE11.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE11',p_lead_bulk_rec.ATTRIBUTE11(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE11',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE12.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE12',p_lead_bulk_rec.ATTRIBUTE12(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE12',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE13.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE13',p_lead_bulk_rec.ATTRIBUTE13(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE13',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE14.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE14',p_lead_bulk_rec.ATTRIBUTE14(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE14',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ATTRIBUTE15.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ATTRIBUTE15',p_lead_bulk_rec.ATTRIBUTE15(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ATTRIBUTE15',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.ORG_ID.Exists(i)
      THEN
    	   wf_event.AddParameterToList('ORG_ID',p_lead_bulk_rec.ORG_ID(i),l_list);
      ELSE
    	   wf_event.AddParameterToList('ORG_ID',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.SQUAL_NUM06.Exists(i)
      THEN
         wf_event.AddParameterToList('SQUAL_NUM06',p_lead_bulk_rec.SQUAL_NUM06(i),l_list);
      ELSE
         wf_event.AddParameterToList('SQUAL_NUM06',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.SQUAL_NUM01.Exists(i)
      THEN
         wf_event.AddParameterToList('SQUAL_NUM01',p_lead_bulk_rec.SQUAL_NUM01(i),l_list);
      ELSE
         wf_event.AddParameterToList('SQUAL_NUM01',NULL,l_list);
      END IF;

      IF p_lead_bulk_rec.CAR_CURRENCY_CODE.Exists(i)
      THEN
         wf_event.AddParameterToList('CAR_CURRENCY_CODE',p_lead_bulk_rec.CAR_CURRENCY_CODE(i),l_list);
      ELSE
         wf_event.AddParameterToList('CAR_CURRENCY_CODE',NULL,l_list);
      END IF;

      wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
      wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);

      -- Raise Event
      wf_event.raise(
                     p_event_name        => l_event_name
                    ,p_event_key         => l_key
                    ,p_event_data        => null
                    ,p_parameters        => l_list
                    );

      l_list.DELETE;

	i:=p_lead_bulk_rec.PARTY_ID.NEXT(i);

      END LOOP;

    ELSE

      --Get the item key
      l_key := item_key(l_event_name);

      -- initialization of object variables

	wf_event.AddParameterToList('SALES_LEAD_ID',p_lead_rec.SALES_LEAD_ID,l_list);
	wf_event.AddParameterToList('SALES_LEAD_LINE_ID',p_lead_rec.SALES_LEAD_LINE_ID,l_list);
	wf_event.AddParameterToList('CITY',p_lead_rec.CITY,l_list);
	wf_event.AddParameterToList('POSTAL_CODE',p_lead_rec.POSTAL_CODE,l_list);
	wf_event.AddParameterToList('STATE',p_lead_rec.STATE,l_list);
	wf_event.AddParameterToList('PROVINCE',p_lead_rec.PROVINCE,l_list);
	wf_event.AddParameterToList('COUNTY',p_lead_rec.COUNTY,l_list);
	wf_event.AddParameterToList('COUNTRY',p_lead_rec.COUNTRY,l_list);
	wf_event.AddParameterToList('INTEREST_TYPE_ID',p_lead_rec.INTEREST_TYPE_ID,l_list);
	wf_event.AddParameterToList('PRIMARY_INTEREST_ID',p_lead_rec.PRIMARY_INTEREST_ID,l_list);
	wf_event.AddParameterToList('SECONDARY_INTEREST_ID',p_lead_rec.SECONDARY_INTEREST_ID,l_list);
      wf_event.AddParameterToList('CONTACT_INTEREST_TYPE_ID',p_lead_rec.CONTACT_INTEREST_TYPE_ID,l_list);
      wf_event.AddParameterToList('CONTACT_PRIMARY_INTEREST_ID',p_lead_rec.CONTACT_PRIMARY_INTEREST_ID,l_list);
      wf_event.AddParameterToList('CONTACT_SECONDARY_INTEREST_ID',p_lead_rec.CONTACT_SECONDARY_INTEREST_ID,l_list);
	wf_event.AddParameterToList('PARTY_SITE_ID',p_lead_rec.PARTY_SITE_ID,l_list);
	wf_event.AddParameterToList('AREA_CODE',p_lead_rec.AREA_CODE,l_list);
	wf_event.AddParameterToList('PARTY_ID',p_lead_rec.PARTY_ID,l_list);
	wf_event.AddParameterToList('COMP_NAME_RANGE',p_lead_rec.COMP_NAME_RANGE,l_list);
	wf_event.AddParameterToList('PARTNER_ID',p_lead_rec.PARTNER_ID,l_list);
	wf_event.AddParameterToList('NUM_OF_EMPLOYEES',p_lead_rec.NUM_OF_EMPLOYEES,l_list);
	wf_event.AddParameterToList('CATEGORY_CODE',p_lead_rec.CATEGORY_CODE,l_list);
	wf_event.AddParameterToList('PARTY_RELATIONSHIP_ID',p_lead_rec.PARTY_RELATIONSHIP_ID,l_list);
	wf_event.AddParameterToList('SIC_CODE',p_lead_rec.SIC_CODE,l_list);
	wf_event.AddParameterToList('BUDGET_AMOUNT',p_lead_rec.BUDGET_AMOUNT,l_list);
	wf_event.AddParameterToList('CURRENCY_CODE',p_lead_rec.CURRENCY_CODE,l_list);
	wf_event.AddParameterToList('PRICING_DATE',p_lead_rec.PRICING_DATE,l_list);
	wf_event.AddParameterToList('SOURCE_PROMOTION_ID',p_lead_rec.SOURCE_PROMOTION_ID,l_list);
	wf_event.AddParameterToList('INVENTORY_ITEM_ID',p_lead_rec.INVENTORY_ITEM_ID,l_list);
	wf_event.AddParameterToList('LEAD_INTEREST_TYPE_ID',p_lead_rec.LEAD_INTEREST_TYPE_ID,l_list);
	wf_event.AddParameterToList('LEAD_PRIMARY_INTEREST_ID',p_lead_rec.LEAD_PRIMARY_INTEREST_ID,l_list);
	wf_event.AddParameterToList('LEAD_SECONDARY_INTEREST_ID',p_lead_rec.LEAD_SECONDARY_INTEREST_ID,l_list);
	wf_event.AddParameterToList('PURCHASE_AMOUNT',p_lead_rec.PURCHASE_AMOUNT,l_list);
	wf_event.AddParameterToList('ATTRIBUTE1',p_lead_rec.ATTRIBUTE1,l_list);
	wf_event.AddParameterToList('ATTRIBUTE2',p_lead_rec.ATTRIBUTE2,l_list);
	wf_event.AddParameterToList('ATTRIBUTE3',p_lead_rec.ATTRIBUTE3,l_list);
	wf_event.AddParameterToList('ATTRIBUTE4',p_lead_rec.ATTRIBUTE4,l_list);
	wf_event.AddParameterToList('ATTRIBUTE5',p_lead_rec.ATTRIBUTE5,l_list);
	wf_event.AddParameterToList('ATTRIBUTE6',p_lead_rec.ATTRIBUTE6,l_list);
	wf_event.AddParameterToList('ATTRIBUTE7',p_lead_rec.ATTRIBUTE7,l_list);
	wf_event.AddParameterToList('ATTRIBUTE8',p_lead_rec.ATTRIBUTE8,l_list);
	wf_event.AddParameterToList('ATTRIBUTE9',p_lead_rec.ATTRIBUTE9,l_list);
	wf_event.AddParameterToList('ATTRIBUTE10',p_lead_rec.ATTRIBUTE10,l_list);
	wf_event.AddParameterToList('ATTRIBUTE11',p_lead_rec.ATTRIBUTE11,l_list);
	wf_event.AddParameterToList('ATTRIBUTE12',p_lead_rec.ATTRIBUTE12,l_list);
	wf_event.AddParameterToList('ATTRIBUTE13',p_lead_rec.ATTRIBUTE13,l_list);
	wf_event.AddParameterToList('ATTRIBUTE14',p_lead_rec.ATTRIBUTE14,l_list);
	wf_event.AddParameterToList('ATTRIBUTE15',p_lead_rec.ATTRIBUTE15,l_list);
	wf_event.AddParameterToList('ORG_ID',p_lead_rec.ORG_ID,l_list);
      wf_event.AddParameterToList('BUSINESS_PROCESS_ID',p_business_process_id,l_list);
      wf_event.AddParameterToList('BUSINESS_PROCESS_DATE',p_business_process_date,l_list);

      -- Raise Event
      wf_event.raise(
                     p_event_name        => l_event_name
                    ,p_event_key         => l_key
                    ,p_event_data        => null
                    ,p_parameters        => l_list
                    );

      l_list.DELETE;

    END IF;

    EXCEPTION when OTHERS then
       ROLLBACK TO asg_lead_publish_save;
       x_return_status := fnd_api.g_ret_sts_unexp_error;

 END assign_lead_resource;

/********************** End of Addition for Enh. No 3076744 by SBARAT, 20/09/2004 ************************/

END jtf_am_wf_events_pub;

/
