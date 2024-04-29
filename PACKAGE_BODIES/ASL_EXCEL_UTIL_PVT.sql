--------------------------------------------------------
--  DDL for Package Body ASL_EXCEL_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASL_EXCEL_UTIL_PVT" AS
/* $Header: aslvxlub.pls 120.1 2005/11/11 02:11:33 vjayamoh noship $ */

-- Session Based Apps Contexts
t_person_id     NUMBER   := -1 ;
t_user_id       NUMBER   := -1 ;
t_salesforce_id NUMBER   := -1 ;
t_salesgroup_id NUMBER   := -1 ;
t_org_id        NUMBER   := 204;

-- module_enabled_flags
t_org_enabled_flag BOOLEAN := FALSE;
/* BLAM */
t_per_enabled_flag BOOLEAN := FALSE;
/* BLAM */
t_cnt_enabled_flag BOOLEAN := FALSE;
t_opp_enabled_flag BOOLEAN := FALSE;
t_lead_enabled_flag BOOLEAN := FALSE;
t_frcst_enabled_flag BOOLEAN := FALSE;
t_qot_enabled_flag BOOLEAN := FALSE;

t_manager_flag  VARCHAR2(1) := 'N';
t_access_profile_rec  AS_ACCESS_PUB.ACCESS_PROFILE_REC_TYPE;
-- Cache the last sync time
t_last_sync_time DATE := NULL;
t_current_sync_time DATE := NULL;

/*
** Get organizations that this sales rep firstly get
** access to since last sync.
** This table actually is a superset of all the new organizations because
** it doesn't know any advanced preference of Organizations.
** TBD: bulk operation.
** Open Issue: The AND / OR of download preference combination.
** Also, wonder if ASL_OPPORTUNITY_ACC, ASL_ORGANIZATION_ACC
**       is a better choice.  It only requires us to implement Sales Team user hook
**       Because join sales team and opportunity is always expensive and not unique at all.
*/
/* BLAM -- Generic routine for org and person, replaced GET_NEW_ORG_REC  */
PROCEDURE GET_NEW_CUST_REC
(p_salesforce_id IN NUMBER,
 p_last_sync_time IN DATE) IS

CURSOR C_NEW_CUST_TEAM(p_salesforce_id NUMBER, p_last_sync_time DATE) IS
SELECT DISTINCT ACC1.customer_id
FROM AS_ACCESSES_ALL ACC1, AS_ACCESSES_ALL ACC2
WHERE  ACC1.salesforce_id =  p_salesforce_id
AND    ACC1.creation_date > p_last_sync_time
AND    ACC1.salesforce_id = ACC2.salesforce_id(+)
AND    ACC1.customer_id   = ACC2.customer_id (+)
AND    ACC2.creation_date(+) <= p_last_sync_time
AND    ACC2.salesforce_id IS NULL;

  l_new_cust_rec ASL_NEW_CUST_REC_TYPE;
BEGIN

 -- Cleanup M_NEW_CUST_TBL
 FOR r_new_cust_team IN C_NEW_CUST_TEAM (p_salesforce_id, p_last_sync_time) LOOP
     IF (r_new_cust_team.customer_id < M_SERVER_PK_ID_MAX) THEN
       l_new_cust_rec.CUSTOMER_ID := r_new_cust_team.customer_id;
       l_new_cust_rec.DOWNLOAD_FLAG := 'N';
       BEGIN
          M_NEW_CUST_TBL(r_new_cust_team.customer_id) := l_new_cust_rec;
       EXCEPTION
          WHEN OTHERS THEN
             NULL;
       END;
     END IF;
 END LOOP;
END GET_NEW_CUST_REC;
/* BLAM */

PROCEDURE GET_NEW_OPP_REC
(p_salesforce_id IN NUMBER,
 p_last_sync_time IN DATE) IS

CURSOR C_NEW_OPP_TEAM(p_salesforce_id NUMBER, p_last_sync_time DATE) IS
SELECT DISTINCT ACC1.customer_id, ACC1.lead_id
FROM AS_ACCESSES_ALL ACC1, AS_ACCESSES_ALL ACC2
WHERE  ACC1.salesforce_id =  p_salesforce_id
AND    ACC1.creation_date > p_last_sync_time
AND    ACC1.salesforce_id = ACC2.salesforce_id(+)
AND    ACC1.customer_id   = ACC2.customer_id (+)
AND    ACC1.lead_id       = ACC2.lead_id     (+)
AND    ACC2.creation_date(+) <= p_last_sync_time
AND    ACC2.salesforce_id IS NULL
AND    ACC1.LEAD_ID IS NOT NULL;

  l_new_opp_rec ASL_NEW_OPPORTUNITY_REC_TYPE;
BEGIN

  FOR r_new_opp_team IN C_NEW_OPP_TEAM(p_salesforce_id, p_last_sync_time) LOOP
    IF (r_new_opp_team.lead_id  < M_SERVER_PK_ID_MAX) THEN
      l_new_opp_rec.OPPORTUNITY_ID := r_new_opp_team.lead_id;
      l_new_opp_rec.CUSTOMER_ID := r_new_opp_team.customer_id;
      l_new_opp_rec.DOWNLOAD_FLAG := 'N';
      BEGIN
         M_NEW_OPP_TBL(r_new_opp_team.lead_id) := l_new_opp_rec;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
    END IF;
  END LOOP;
END GET_NEW_OPP_REC;

PROCEDURE GET_NEW_LEAD_REC
(p_salesforce_id IN NUMBER,
 p_last_sync_time IN DATE) IS

CURSOR C_NEW_LEAD_TEAM(p_salesforce_id NUMBER, p_last_sync_time DATE) IS
SELECT DISTINCT ACC1.customer_id, ACC1.sales_lead_id
FROM AS_ACCESSES_ALL ACC1, AS_ACCESSES_ALL ACC2
WHERE  ACC1.salesforce_id =  p_salesforce_id
AND    ACC1.creation_date > p_last_sync_time
AND    ACC1.salesforce_id = ACC2.salesforce_id(+)
AND    ACC1.customer_id   = ACC2.customer_id (+)
AND    ACC1.sales_lead_id       = ACC2.sales_lead_id     (+)
AND    ACC2.creation_date(+) <= p_last_sync_time
AND    ACC2.salesforce_id IS NULL
AND    ACC1.sales_lead_id IS NOT NULL;

  l_new_lead_rec ASL_NEW_LEAD_REC_TYPE;
BEGIN

  FOR r_new_lead_team IN C_NEW_LEAD_TEAM(p_salesforce_id, p_last_sync_time) LOOP
    IF (r_new_lead_team.sales_lead_id  < M_SERVER_PK_ID_MAX) THEN
      l_new_lead_rec.SALES_LEAD_ID := r_new_lead_team.sales_lead_id;
      l_new_lead_rec.CUSTOMER_ID := r_new_lead_team.customer_id;
      l_new_lead_rec.DOWNLOAD_FLAG := 'N';
      BEGIN
         M_NEW_LEAD_TBL(r_new_lead_team.sales_lead_id) := l_new_lead_rec;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
    END IF;
  END LOOP;
END GET_NEW_LEAD_REC;


PROCEDURE GET_NEW_QOT_REC
(p_salesforce_id IN NUMBER,
 p_last_sync_time IN DATE) IS

  CURSOR C_NEW_QOT_TEAM(p_salesforce_id NUMBER, p_last_sync_time DATE) IS
  SELECT QUOTE_HEADER_ID
  FROM ASO_QUOTE_HEADERS_ALL
  WHERE QUOTE_NUMBER IN (
  SELECT DISTINCT ACC1.quote_number
  FROM ASO_QUOTE_ACCESSES ACC1, ASO_QUOTE_ACCESSES ACC2
  WHERE  ACC1.resource_id =  p_salesforce_id
  AND    ACC1.creation_date > p_last_sync_time
  AND    ACC1.resource_id = ACC2.resource_id(+)
  AND    ACC1.QUOTE_NUMBER   = ACC2.QUOTE_NUMBER (+)
  AND    ACC2.creation_date(+) <= p_last_sync_time
  AND    ACC1.resource_id IS NOT NULL
  AND    ACC2.resource_id IS NULL
  )
  AND MAX_VERSION_FLAG = 'Y';

  l_new_qot_rec ASL_NEW_QUOTE_REC_TYPE;
BEGIN

 -- Cleanup M_NEW_QOT_TBL
 FOR r_new_qot_team IN C_NEW_QOT_TEAM (p_salesforce_id, p_last_sync_time) LOOP
     IF (r_new_qot_team.QUOTE_HEADER_ID < M_SERVER_PK_ID_MAX) THEN
       l_new_qot_rec.QUOTE_HEADER_ID := r_new_qot_team.QUOTE_HEADER_ID;
       l_new_qot_rec.DOWNLOAD_FLAG := 'N';
       BEGIN
          M_NEW_QOT_TBL(r_new_qot_team.QUOTE_HEADER_ID) := l_new_qot_rec;
       EXCEPTION
          WHEN OTHERS THEN
             NULL;
       END;
     END IF;
 END LOOP;
END GET_NEW_QOT_REC;

/*
** save last downloaded Inventory categories
*/
PROCEDURE GET_DOWNLOADED_INV_CATGRY_REC
(p_org_id NUMBER
,p_user_id NUMBER
,p_app_id NUMBER
,p_resp_id NUMBER) IS

/*
  CURSOR C_DOWNLOADED_INV_CATEGORY(p_org_id NUMBER, p_user_id NUMBER, p_app_id NUMBER, p_resp_id NUMBER) IS
  SELECT DISTINCT CATEGORY_ID
  FROM MTL_ITEM_CATEGORIES
  WHERE ORGANIZATION_ID = p_org_id
  AND CATEGORY_ID in
  (SELECT FND_PROFILE.VALUE_SPECIFIC('ASL_EXCEL_INV_CATEGORY',p_user_id,p_resp_id,p_app_id)
   FROM DUAL
  );

*/
  l_inv_categories varchar(2000) := '';

  CURSOR C_DOWNLOADED_INV_CATEGORY(p_org_id NUMBER, p_user_id NUMBER, p_app_id NUMBER, p_resp_id NUMBER) IS
  SELECT DISTINCT CATEGORY_ID
  FROM MTL_ITEM_CATEGORIES
  WHERE ORGANIZATION_ID = p_org_id
  AND INSTR(l_inv_categories, fnd_global.local_chr(39)||to_char(CATEGORY_ID)|| fnd_global.local_chr(39))>0;

  l_old_inv_catgry_rec ASL_OLD_INV_CATEGORY_REC_TYPE;
BEGIN
  SELECT FND_PROFILE.VALUE_SPECIFIC('ASL_EXCEL_INV_CATEGORY',p_user_id, p_resp_id, p_app_id)
  INTO l_inv_categories
  FROM DUAL;

  FOR r_old_inv_catgry_rec IN C_DOWNLOADED_INV_CATEGORY (p_org_id,p_user_id,p_app_id,p_resp_id) LOOP
    IF (r_old_inv_catgry_rec.category_id < M_SERVER_PK_ID_MAX) THEN
      l_old_inv_catgry_rec.category_id := r_old_inv_catgry_rec.category_id;
      BEGIN
        M_OLD_INV_TBL(r_old_inv_catgry_rec.category_id) := l_old_inv_catgry_rec;
      EXCEPTION
      WHEN OTHERS THEN
        NULL;
      END;
    END IF;
  END LOOP;
END GET_DOWNLOADED_INV_CATGRY_REC;



/*
Save last downloaded price list headers
*/
--VJAYAMOH modified as part of sql rep bugs
--Bug 4266530
PROCEDURE GET_DOWNLOADED_PRICE_LIST_REC
(p_org_id NUMBER
,p_user_id NUMBER
,p_app_id NUMBER
,p_resp_id NUMBER) IS

  l_old_price_list_rec ASL_OLD_PRICE_LIST_REC_TYPE;
  l_prof_price_list_headers varchar(1000) := '';
  l_end_index  number :=0;
  l_header_id_string varchar(1000) := '';
  l_count    NUMBER := 0;
  CURSOR l_price_list_headers_c(p_header_id IN NUMBER) IS
      SELECT 1
         FROM QP_LIST_HEADERS_B
           WHERE LIST_HEADER_ID = p_header_id;
BEGIN

SELECT FND_PROFILE.VALUE_SPECIFIC('ASL_EXCEL_PRICE_LIST',p_user_id,p_resp_id,p_app_id) into l_prof_price_list_headers FROM DUAL;
l_prof_price_list_headers := replace( l_prof_price_list_headers ,'(','');
l_prof_price_list_headers := replace( l_prof_price_list_headers ,')','');
l_prof_price_list_headers := replace( l_prof_price_list_headers ,fnd_global.local_chr(39),'');


while (INSTR(l_prof_price_list_headers, ',') > 0)
LOOP
 l_end_index := INSTR(l_prof_price_list_headers, ',');
 l_header_id_string := Substr(l_prof_price_list_headers, 0, l_end_index-1);
 l_prof_price_list_headers := Substr(l_prof_price_list_headers, l_end_index+1, length(l_prof_price_list_headers));

IF (l_header_id_string < M_SERVER_PK_ID_MAX) THEN
OPEN   l_price_list_headers_c(l_header_id_string);
FETCH  l_price_list_headers_c INTO l_count;
IF (l_price_list_headers_c%FOUND) THEN
 BEGIN
   l_old_price_list_rec.list_header_id := l_header_id_string;
   M_OLD_PRICE_LIST_TBL(l_header_id_string) := l_old_price_list_rec;
 EXCEPTION
   WHEN OTHERS THEN
      NULL;
 END;
CLOSE l_price_list_headers_c;
END IF;
END IF;
END LOOP;


IF (l_prof_price_list_headers <> 'ALL' AND (length(l_prof_price_list_headers) > 0) ) THEN
if true then
OPEN   l_price_list_headers_c(l_prof_price_list_headers);
FETCH  l_price_list_headers_c INTO l_count;
IF (l_price_list_headers_c%FOUND) THEN
 BEGIN
 l_old_price_list_rec.list_header_id := l_prof_price_list_headers;
 M_OLD_PRICE_LIST_TBL(l_prof_price_list_headers) := l_old_price_list_rec;
 EXCEPTION
   WHEN OTHERS THEN
      NULL;
 END;
END IF;
END IF;
END IF;


END GET_DOWNLOADED_PRICE_LIST_REC;



/*
** Save Sync Context for a particular sales rep.
** It doesn't do any validation on the passed in values. Assumeably ASF_PAGE
** Already done that.
** If incremental sync is implmented, save the new-added Organization for
** Check_Org_Download Method
** last_sync_time comes from FND_PROFILE 'ASL_EXCEL_LAST_SYNC_TIME'. If the value
** is null, it means this user never synced, set the M_FULL_SYNC to true no matter
** what value client sends over.
*/
PROCEDURE SAVE_SYNC_CONTEXT
(  p_salesforce_id  IN NUMBER,
   p_salesgroup_id  IN NUMBER,
   p_person_id      IN NUMBER,
   p_user_id        IN NUMBER,
   p_full_sync      IN NUMBER,
   x_curr_sync_time_str OUT NOCOPY VARCHAR2
) IS
  l_last_sync_time_str VARCHAR2(60) := NULL;
  l_default_sync_time_str VARCHAR2(60) := NULL;
  l_defined boolean;
  l_full_sync_str VARCHAR2(10) := NULL;
BEGIN

  t_person_id := p_person_id;
  t_user_id   := p_user_id;
  t_salesforce_id := p_salesforce_id;
  t_salesgroup_id := p_salesgroup_id;
  t_manager_flag := CHECK_MANAGER_FLAG(t_salesgroup_id);
  -- t_last_sync_time := p_last_sync_time;

  -- l_last_sync_time_str := FND_PROFILE.VALUE('ASL_EXCEL_LAST_SYNC_TIME');
  BEGIN
     FND_PROFILE.GET_SPECIFIC(name_z    =>  'ASL_EXCEL_LAST_SYNC_TIME',
                              user_id_z  => p_user_id ,
                              val_z      => l_last_sync_time_str,
                              defined_z  => l_defined );
  EXCEPTION
     WHEN OTHERS THEN
        l_last_sync_time_str := NULL;
  END;

  -- Temp solution for retrieving site level profile option
  l_default_sync_time_str := '1970-02-29:02:59:31';

  -- l_last_sync_time_str := '2002-07-29:02:57:31';
  M_FULL_SYNC := TRUE;

  IF (p_full_sync = 0 AND l_last_sync_time_str IS NOT NULL)
  THEN
     IF ((l_default_sync_time_str IS NOT NULL) AND (l_last_sync_time_str <> l_default_sync_time_str)) THEN

        BEGIN
           t_last_sync_time := TO_DATE(l_last_sync_time_str, M_CONVERSION_DATE_FORMAT);
           -- Get the organizations that newly assigned to this sales rep
           -- it can come from Organization sales team, Opportunity Sales Team
           -- LEAD sales team.
           -- If we have user hooks, this part is no longer needed.
/* BLAM */
           M_NEW_CUST_TBL.DELETE;
/* BLAM */
           M_NEW_CNT_TBL.DELETE;
           M_NEW_OPP_TBL.DELETE;
           M_NEW_OPP_LINE_TBL.DELETE;
           /* agmoore - changes for opportunity classifications 2744023 */
           M_NEW_OPP_CLASS_TBL.DELETE;
		   /* lcooper - changes for opportunity issues 2675493 */
           M_NEW_LEAD_TBL.DELETE;
           M_OLD_INV_TBL.DELETE;
           M_OLD_PRICE_LIST_TBL.DELETE;
           M_NEW_CUST_ACCOUNT_TBL.DELETE;

	   /* BLAM */
           IF t_org_enabled_flag = true OR t_per_enabled_flag = true THEN
             GET_NEW_CUST_REC(t_salesforce_id, t_last_sync_time);
           END IF;
	   /* BLAM */

           IF t_opp_enabled_flag = true THEN
           GET_NEW_OPP_REC(t_salesforce_id, t_last_sync_time);
           END IF;

           IF t_lead_enabled_flag = true THEN
           GET_NEW_LEAD_REC(t_salesforce_id, t_last_sync_time);
           END IF;

           IF t_qot_enabled_flag = true THEN
           GET_NEW_QOT_REC(t_salesforce_id, t_last_sync_time);
           GET_DOWNLOADED_INV_CATGRY_REC(t_org_id, t_user_id, null, null);
           GET_DOWNLOADED_PRICE_LIST_REC(t_org_id, t_user_id, null, null);
           END IF;

           M_FULL_SYNC := FALSE;
        EXCEPTION
           WHEN OTHERS THEN
               /*
               ASL_UTIL_LOG_PKG.Create_Log_Entry(
                  p_resource_id  => t_salesforce_id,
                  p_log_type     => 'Excel',
                  p_log_location => 'Save Sync Context',
                  p_log_desc    =>  ' Converting last_sync_time_str has exception ' || SQLERRM );
               */
               M_FULL_SYNC := TRUE;
        END;
     END IF;
  END IF;

  /*
  IF (M_FULL_SYNC = TRUE) THEN
     DBMS_OUTPUT.PUT_LINE(' Doing Full Sync');
  END IF;
  */
  /*
  ** Get the current sysdate for SYNC_TIME of this sync transaction
  */
  SELECT SYSDATE INTO t_current_sync_time FROM DUAL;

  x_curr_sync_time_str := TO_CHAR(t_current_sync_time, M_CONVERSION_DATE_FORMAT);

  IF (M_FULL_SYNC) THEN
     l_full_sync_str := 'TRUE';
  ELSE
     l_full_sync_str := 'FALSE';
  END IF;
  /*
  ASL_UTIL_LOG_PKG.Create_Log_Entry(
   p_resource_id  => t_salesforce_id,
   p_log_type     => 'Excel',
   p_log_location => 'Save Sync Context',
   p_log_desc    => ' It is doing ' || l_full_sync_str || ' last sync time IS ' ||
                    l_last_sync_time_str || ' sync flag passed in is ' || p_full_sync );
  */
END SAVE_SYNC_CONTEXT;

PROCEDURE SET_ACCESS_PROFILE_VALUES
(p_cust_access       IN VARCHAR2
,p_lead_access     IN VARCHAR2
,p_opp_access IN VARCHAR2
,p_mgr_update IN VARCHAR2
,p_admin_update IN VARCHAR2
) IS

BEGIN

    t_access_profile_rec.cust_access_profile_value := p_cust_access;
    t_access_profile_rec.lead_access_profile_value := p_lead_access;
    t_access_profile_rec.opp_access_profile_value := p_opp_access;
    t_access_profile_rec.mgr_update_profile_value := p_mgr_update;
    t_access_profile_rec.admin_update_profile_value := p_admin_update;

END SET_ACCESS_PROFILE_VALUES;
/*
** TBD:
** To save the PL/SQL <-> JDBC communication, combine Check_Organization_New_Download
** and Check_Customer_Updateble together. Right now the problem is the DownloadProcessor.java
** is too generic to split one column 'IY' to 'I' and 'Y'.
** TBD:
** Would it be better to delete all the entries where download_status = 'N'?
*/
/* BLAM Changed references to M_NEW_ORG_TBL to M_NEW_CUST_TBL */
/* and ASL_NEW_ORG_REC_TYPE to ASL_NEW_CUST_REC_TYPE */

FUNCTION Check_Organization_Download
(p_customer_id IN NUMBER
,p_org_creation_date IN DATE
,p_org_update_date   IN DATE
,p_profile_creation_date IN DATE
,p_ploc_update_date  IN DATE
,p_sloc_update_date  IN DATE
,p_bloc_update_date  IN DATE
,p_phone_update_date IN DATE
,p_email_update_date IN DATE
) RETURN VARCHAR2 IS
 l_new_org_rec ASL_NEW_CUST_REC_TYPE;

 l_download_status VARCHAR2(1) := 'I';
BEGIN
 --DBMS_OUTPUT.PUT_LINE('Checking Customer ' || p_customer_id);
 IF (M_FULL_SYNC = FALSE) THEN
    IF (p_customer_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;
    IF ((p_org_creation_date > t_last_sync_time) OR
        (M_NEW_CUST_TBL.EXISTS(p_customer_id))
       )
    THEN
       l_download_status := 'I';
       IF (M_NEW_CUST_TBL.EXISTS(p_customer_id)) THEN
          M_NEW_CUST_TBL(p_customer_id).DOWNLOAD_FLAG := 'Y';
       ELSE
          l_new_org_rec.CUSTOMER_ID := p_customer_id;
          l_new_org_rec.DOWNLOAD_FLAG := 'Y';
          M_NEW_CUST_TBL(p_customer_id) := l_new_org_rec;
       END IF;
    ELSIF  ((p_org_update_date > t_last_sync_time) OR
             (p_profile_creation_date > t_last_sync_time) OR
             (p_ploc_update_date > t_last_sync_time) OR
             (p_sloc_update_date > t_last_sync_time) OR
             (p_bloc_update_date > t_last_sync_time) OR
             (p_phone_update_date > t_last_sync_time) OR
             (p_email_update_date > t_last_sync_time))
    THEN
       l_download_status := 'U';
    ELSE
       l_download_status := 'O';
    END IF;
 END IF;
 -- DBMS_OUTPUT.PUT_LINE('      STATUS IS ' || l_download_status);
 RETURN l_download_status;
END Check_Organization_Download;

/* START BLAM */
FUNCTION Check_Person_Download
(p_customer_id IN NUMBER
,p_per_creation_date IN DATE
,p_per_update_date   IN DATE
,p_profile_creation_date IN DATE
,p_phone_update_date IN DATE
,p_email_update_date IN DATE
) RETURN VARCHAR2 IS
 l_new_per_rec ASL_NEW_CUST_REC_TYPE;
 l_download_status VARCHAR2(1) := 'I';
BEGIN
 --DBMS_OUTPUT.PUT_LINE('Checking Customer ' || p_customer_id);
 IF (M_FULL_SYNC = FALSE) THEN
    IF (p_customer_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;
    IF ((p_per_creation_date > t_last_sync_time) OR
        (M_NEW_CUST_TBL.EXISTS(p_customer_id))
       )
    THEN
       l_download_status := 'I';
       IF (M_NEW_CUST_TBL.EXISTS(p_customer_id)) THEN
          M_NEW_CUST_TBL(p_customer_id).DOWNLOAD_FLAG := 'Y';
       ELSE
          l_new_per_rec.CUSTOMER_ID := p_customer_id;
          l_new_per_rec.DOWNLOAD_FLAG := 'Y';
          M_NEW_CUST_TBL(p_customer_id) := l_new_per_rec;
       END IF;
    ELSIF  ((p_per_update_date > t_last_sync_time) OR
             (p_profile_creation_date > t_last_sync_time) OR
             (p_phone_update_date > t_last_sync_time) OR
             (p_email_update_date > t_last_sync_time))
    THEN
       l_download_status := 'U';
    ELSE
       l_download_status := 'O';
    END IF;
 END IF;
 -- DBMS_OUTPUT.PUT_LINE('      STATUS IS ' || l_download_status);
 RETURN l_download_status;
END Check_Person_Download;
/* BLAM */

FUNCTION Check_Opp_Download
(p_opp_creation_date IN DATE
,p_opp_update_date IN DATE
,p_opportunity_id  IN NUMBER
,p_customer_id     IN NUMBER
,p_customer_update_date IN DATE
,p_contact_party_update_date  IN DATE
,p_contact_person_update_date  IN DATE
,p_rel_update_date IN DATE
) RETURN VARCHAR2  IS

  l_new_opp_rec ASL_NEW_OPPORTUNITY_REC_TYPE;
  l_download_status VARCHAR2(1) := 'I';
BEGIN
  IF (M_FULL_SYNC = FALSE) THEN
    IF (p_opportunity_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;
     IF ((p_opp_creation_date > t_last_sync_time) OR
         (M_NEW_OPP_TBL.EXISTS(p_opportunity_id))
        )
     THEN
        IF (M_NEW_OPP_TBL.EXISTS(p_opportunity_id)
           ) THEN
           M_NEW_OPP_TBL(p_opportunity_id).DOWNLOAD_FLAG := 'Y';
        ELSE
           l_new_opp_rec.OPPORTUNITY_ID := p_opportunity_id;
           l_new_opp_rec.CUSTOMER_ID := p_customer_id;
           l_new_opp_rec.DOWNLOAD_FLAG := 'Y';
           M_NEW_OPP_TBL(p_opportunity_id) := l_new_opp_rec;
        END IF;
     ELSIF ((p_opp_update_date > t_last_sync_time) OR
            (p_customer_update_date > t_last_sync_time) OR
            (p_contact_party_update_date > t_last_sync_time) OR
            (p_contact_person_update_date > t_last_sync_time) OR
            (p_rel_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;

  END IF;

  RETURN l_download_status;
END Check_Opp_Download;

FUNCTION Check_Opp_Det_Download
(p_line_creation_date IN DATE
,p_line_update_date IN DATE
,p_opportunity_id IN NUMBER
,p_opp_line_id  IN NUMBER
) RETURN VARCHAR2 IS
  l_new_opp_line_rec ASL_NEW_OPP_LINE_REC_TYPE;
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_opportunity_id >= M_SERVER_PK_ID_MAX) OR (p_opp_line_id >= M_SERVER_PK_ID_MAX)) THEN
       RETURN l_download_status;
     END IF;
     IF ((p_line_creation_date > t_last_sync_time) OR
         (M_NEW_OPP_TBL.EXISTS(p_opportunity_id) AND (M_NEW_OPP_TBL(p_opportunity_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        l_new_opp_line_rec.OPPORTUNITY_ID := p_opportunity_id;
        l_new_opp_line_rec.OPPORTUNITY_LINE_ID := p_opp_line_id;
        M_NEW_OPP_LINE_TBL(p_opp_line_id) := l_new_opp_line_rec;
     ELSIF ((p_line_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Opp_Det_Download;

/* agmoore - changes for opportunity classifications 2744023 */
FUNCTION Check_Opp_Class_Download
(p_class_creation_date IN DATE
,p_class_update_date IN DATE
,p_opportunity_id IN NUMBER
,p_opp_class_id  IN NUMBER
) RETURN VARCHAR2 IS
  l_new_opp_class_rec ASL_NEW_OPP_CLASS_REC_TYPE;
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_opportunity_id >= M_SERVER_PK_ID_MAX)  OR (p_opp_class_id >= M_SERVER_PK_ID_MAX)) THEN
       RETURN l_download_status;
     END IF;
     IF ((p_class_creation_date > t_last_sync_time) OR
         (M_NEW_OPP_TBL.EXISTS(p_opportunity_id) AND (M_NEW_OPP_TBL(p_opportunity_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        --l_download_status := 'I';
        l_new_opp_class_rec.OPPORTUNITY_ID := p_opportunity_id;
        l_new_opp_class_rec.OPPORTUNITY_CLASS_ID := p_opp_class_id;
        M_NEW_OPP_CLASS_TBL(p_opp_class_id) := l_new_opp_class_rec;
     ELSIF ((p_class_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Opp_Class_Download;

/* lcooper - changes for opportunity issues 2675493 */
FUNCTION Check_Opp_Issues_Download
(p_issue_creation_date  IN DATE,
 p_issue_update_date    IN DATE,
 p_opportunity_id       IN NUMBER,
 p_opp_issue_id         IN NUMBER
) RETURN VARCHAR2 IS
  l_new_opp_issues_rec ASL_NEW_OPP_ISSUES_REC_TYPE;
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_opportunity_id >= M_SERVER_PK_ID_MAX) OR (p_opp_issue_id >= M_SERVER_PK_ID_MAX)) THEN
       RETURN l_download_status;
     END IF;
     IF ((p_issue_creation_date > t_last_sync_time) OR
         (M_NEW_OPP_TBL.EXISTS(p_opportunity_id) AND (M_NEW_OPP_TBL(p_opportunity_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        l_new_opp_issues_rec.OPPORTUNITY_ID         := p_opportunity_id;
        l_new_opp_issues_rec.OPPORTUNITY_ISSUE_ID   := p_opp_issue_id;
        M_NEW_OPP_ISSUES_TBL(p_opp_issue_id)        := l_new_opp_issues_rec;
     ELSIF ((p_issue_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Opp_Issues_Download;

FUNCTION Check_Opp_Credit_Download
(p_credit_creation_date  IN DATE
,p_credit_last_update_date     IN DATE
,p_lead_line_id             IN NUMBER
,p_group_last_update_date     IN DATE
,p_resource_last_update_date  IN DATE
) RETURN VARCHAR2 IS
    l_download_status VARCHAR2(1) := 'I';
BEGIN
  IF (M_FULL_SYNC = TRUE) THEN
    RETURN l_download_status;
  END IF;

  IF (p_lead_line_id >= M_SERVER_PK_ID_MAX) THEN
    RETURN l_download_status;
  END IF;

  IF ((p_credit_creation_date > t_last_sync_time) OR
      (M_NEW_OPP_LINE_TBL.EXISTS(p_lead_line_id))
     )
  THEN
    l_download_status := 'I';
  ELSIF ((p_credit_last_update_date > t_last_sync_time) OR
         (p_group_last_update_date > t_last_sync_time) OR
         (p_resource_last_update_date > t_last_sync_time)
        )
  THEN
    l_download_status := 'U';
  ELSE
    l_download_status := 'O';
  END IF;
  return l_download_status;
END Check_Opp_Credit_Download;

/*
** Assume no body will change the contact party itself
*/
/* BLAM Changed references to M_NEW_ORG_TBL to M_NEW_CUST_TBL */
FUNCTION Check_Contact_Download
(p_contact_creation_date IN DATE
,p_contact_party_id      IN NUMBER
,p_contact_person_id     IN NUMBER
,p_customer_id           IN NUMBER
,p_person_update_date    IN DATE
,p_contact_update_date   IN DATE
,p_loc_update_date       IN DATE
,p_phone_update_date     IN DATE
,p_email_update_date     IN DATE
) RETURN VARCHAR2 IS

  l_download_status VARCHAR2(1) := 'I';
  l_new_contact_rec ASL_NEW_CONTACT_REC_TYPE;
BEGIN
  IF (M_FULL_SYNC = TRUE) THEN
     RETURN l_download_status;
  END IF;

  IF (p_contact_party_id >= M_SERVER_PK_ID_MAX) THEN
    RETURN l_download_status;
  END IF;

  IF ((p_contact_creation_date > t_last_sync_time) OR
      (M_NEW_CUST_TBL.EXISTS(p_customer_id) AND (M_NEW_CUST_TBL(p_customer_id).DOWNLOAD_FLAG = 'Y'))
     )
  THEN
     l_download_status := 'I';
     l_new_contact_rec.CONTACT_PARTY_ID := p_contact_party_id;
     l_new_contact_rec.CONTACT_PERSON_ID := p_contact_person_id;
     l_new_contact_rec.CUSTOMER_ID := p_customer_id;
     M_NEW_CNT_TBL(p_contact_party_id) := l_new_contact_rec;
  ELSIF ((p_person_update_date > t_last_sync_time) OR
         (p_contact_update_date > t_last_sync_time) OR
         (p_loc_update_date > t_last_sync_time) OR
         (p_phone_update_date > t_last_sync_time) OR
         (p_email_update_date > t_last_sync_time)
        )
  THEN
     l_download_status := 'U';
  ELSE
     l_download_status := 'O';
  END IF;

  RETURN l_download_status;
END Check_Contact_Download;

/* BLAM Changed references to M_NEW_ORG_TBL to M_NEW_CUST_TBL */
FUNCTION Check_Notes_Download
(p_note_creation_date  IN DATE
,p_note_source_object_code IN VARCHAR2
,p_note_source_object_id    IN NUMBER
,p_tl_update_date  IN DATE
) RETURN VARCHAR2 IS

 l_download_status VARCHAR2(1) := 'I';

BEGIN
  IF (M_FULL_SYNC = TRUE) THEN
     RETURN l_download_status;
  END IF;

  -- Bug fix for 2656639. If Note Source Object Id is identified to be Mobile
  -- download them anyway.
  IF (p_note_source_object_id >= M_SERVER_PK_ID_MAX) THEN
    RETURN l_download_status;
  END IF;

  IF ((p_note_creation_date > t_last_sync_time) OR
      ((p_note_source_object_code = 'PARTY')
       AND
       (
        (M_NEW_CUST_TBL.EXISTS(p_note_source_object_id) AND (M_NEW_CUST_TBL(p_note_source_object_id).DOWNLOAD_FLAG = 'Y')) OR
        (M_NEW_CNT_TBL.EXISTS(p_note_source_object_id))
       )
      )
      OR
      ((p_note_source_object_code = 'OPPORTUNITY') AND
       (M_NEW_OPP_TBL.EXISTS(p_note_source_object_id) AND (M_NEW_OPP_TBL(p_note_source_object_id).DOWNLOAD_FLAG = 'Y'))
      )
      OR
      ((p_note_source_object_code = 'LEAD' ) AND
       (M_NEW_LEAD_TBL.EXISTS(p_note_source_object_id) AND (M_NEW_LEAD_TBL(p_note_source_object_id).DOWNLOAD_FLAG = 'Y'))
      )
     )
  THEN
     l_download_status := 'I';
  ELSIF ((p_tl_update_date > t_last_sync_time)
        )
  THEN
     l_download_status := 'U';
  ELSE
     l_download_status := 'O';
  END IF;

  RETURN l_download_status;
END Check_Notes_Download;

FUNCTION Check_Lead_Download
(p_lead_creation_date  IN DATE
,p_lead_last_update_date   IN DATE
,p_sales_lead_id           IN NUMBER
,p_customer_id             IN NUMBER
,p_customer_update_date    IN DATE
,p_cnt_party_update_date    IN DATE
,p_rel_last_update_date  IN DATE
,p_cnt_person_update_date   IN  DATE
) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';
  l_new_lead_rec ASL_NEW_LEAD_REC_TYPE;
BEGIN
    IF (M_FULL_SYNC = TRUE) THEN
        RETURN l_download_status;
    END IF;

    IF (p_sales_lead_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;

    IF ((p_lead_creation_date > t_last_sync_time) OR
         (M_NEW_LEAD_TBL.EXISTS(p_sales_lead_id))
        )
    THEN
        l_download_status := 'I';
        IF (M_NEW_LEAD_TBL.EXISTS(p_sales_lead_id)
           ) THEN
           M_NEW_LEAD_TBL(p_sales_lead_id).DOWNLOAD_FLAG := 'Y';
        ELSE
           l_new_lead_rec.SALES_LEAD_ID := p_sales_lead_id;
           l_new_lead_rec.CUSTOMER_ID := p_customer_id;
           l_new_lead_rec.DOWNLOAD_FLAG := 'Y';
           M_NEW_LEAD_TBL(p_sales_lead_id) := l_new_lead_rec;
        END IF;
    ELSIF ((p_lead_last_update_date > t_last_sync_time) OR
            (p_customer_update_date > t_last_sync_time) OR
            (p_cnt_party_update_date > t_last_sync_time) OR
            (p_cnt_person_update_date > t_last_sync_time) OR
            (p_rel_last_update_date > t_last_sync_time)
           )
    THEN
        l_download_status := 'U';
    ELSE
        l_download_status := 'O';
    END IF;
    return l_download_status;
END  Check_Lead_Download;

FUNCTION Check_Lead_Det_Download
(p_line_creation_date  IN DATE
,p_line_last_update_date   IN DATE
,p_sales_lead_id  IN NUMBER
) RETURN VARCHAR2 IS
    l_download_status VARCHAR2(1) := 'I';
BEGIN
    IF ((M_FULL_SYNC = TRUE) OR (p_sales_lead_id >= M_SERVER_PK_ID_MAX)) THEN
        RETURN l_download_status;
    END IF;

    IF ((p_line_creation_date > t_last_sync_time) OR
        (M_NEW_LEAD_TBL.EXISTS(p_sales_lead_id) AND (M_NEW_LEAD_TBL(p_sales_lead_id).DOWNLOAD_FLAG = 'Y'))
       )
    THEN
        l_download_status := 'I';
    ELSIF (p_line_last_update_date > t_last_sync_time)
    THEN
        l_download_status := 'U';
    ELSE
        l_download_status := 'O';
    END IF;
    RETURN l_download_status;

END  Check_Lead_Det_Download;

/* BLAM Changed references to M_NEW_ORG_TBL to M_NEW_CUST_TBL */
FUNCTION Check_CST_SalesTeam_Download
(p_team_creation_date  IN DATE
,p_team_last_update_date  IN DATE
,p_customer_id     IN NUMBER
,p_group_last_update_date IN DATE
,p_resource_last_update_date IN DATE
) RETURN VARCHAR2 IS
   l_download_status VARCHAR2(1) := 'I';
BEGIN

    IF ((M_FULL_SYNC = TRUE) OR (p_customer_id >= M_SERVER_PK_ID_MAX))  THEN
        RETURN l_download_status;
    END IF;

    IF ((p_team_creation_date > t_last_sync_time) OR
        (M_NEW_CUST_TBL.EXISTS(p_customer_id) AND (M_NEW_CUST_TBL(p_customer_id).DOWNLOAD_FLAG = 'Y'))
       )
    THEN
        l_download_status := 'I';
    ELSIF ((p_team_last_update_date > t_last_sync_time) OR
           (p_group_last_update_date > t_last_sync_time) OR
           (p_resource_last_update_date > t_last_sync_time)
          )
    THEN
        l_download_status := 'U';
    ELSE
        l_download_status := 'O';
    END IF;

    RETURN l_download_status;

END  Check_CST_SalesTeam_Download;

FUNCTION Check_Opp_SalesTeam_Download
(p_team_creation_date  IN DATE
,p_team_last_update_date  IN DATE
,p_opportunity_id     IN NUMBER
,p_group_last_update_date IN DATE
,p_resource_last_update_date IN DATE
) RETURN VARCHAR2 IS
    l_download_status VARCHAR2(1) := 'I';
BEGIN

    IF ((M_FULL_SYNC = TRUE) OR (p_opportunity_id >= M_SERVER_PK_ID_MAX))  THEN
        RETURN l_download_status;
    END IF;

    IF ((p_team_creation_date > t_last_sync_time) OR
        (M_NEW_OPP_TBL.EXISTS(p_opportunity_id) AND (M_NEW_OPP_TBL(p_opportunity_id).DOWNLOAD_FLAG = 'Y'))
       )
    THEN
        l_download_status := 'I';
    ELSIF ((p_team_last_update_date > t_last_sync_time) OR
           (p_group_last_update_date > t_last_sync_time) OR
           (p_resource_last_update_date > t_last_sync_time)
          )
    THEN
        l_download_status := 'U';
    ELSE
        l_download_status := 'O';
    END IF;

    RETURN l_download_status;

END  Check_Opp_SalesTeam_Download;


FUNCTION Check_Lead_SalesTeam_Download
(p_team_creation_date  IN DATE
,p_team_last_update_date  IN DATE
,p_lead_id     IN NUMBER
,p_group_last_update_date IN DATE
,p_resource_last_update_date IN DATE
) RETURN VARCHAR2 IS
    l_download_status VARCHAR2(1) := 'I';
BEGIN
    IF ((M_FULL_SYNC = TRUE) OR (p_lead_id >= M_SERVER_PK_ID_MAX))  THEN
        RETURN l_download_status;
    END IF;

    IF ((p_team_creation_date > t_last_sync_time) OR
        (M_NEW_LEAD_TBL.EXISTS(p_lead_id) AND (M_NEW_LEAD_TBL(p_lead_id).DOWNLOAD_FLAG = 'Y'))
       )
    THEN
        l_download_status := 'I';
    ELSIF ((p_team_last_update_date > t_last_sync_time) OR
           (p_group_last_update_date > t_last_sync_time) OR
           (p_resource_last_update_date > t_last_sync_time)
          )
    THEN
        l_download_status := 'U';
    ELSE
        l_download_status := 'O';
    END IF;

    RETURN l_download_status;
END  Check_Lead_SalesTeam_Download;


/* BLAM Changed references to M_NEW_ORG_TBL to M_NEW_CUST_TBL */
FUNCTION Check_Address_Download
(p_customer_id IN NUMBER
,p_add_creation_date IN DATE
,p_add_update_date   IN DATE
) RETURN VARCHAR2 IS
 l_download_status VARCHAR2(1) := 'I';
BEGIN
 IF ((M_FULL_SYNC = TRUE) OR (p_customer_id >= M_SERVER_PK_ID_MAX))  THEN
     RETURN l_download_status;
 END IF;
 IF ((p_add_creation_date > t_last_sync_time) OR
        (M_NEW_CUST_TBL.EXISTS(p_customer_id) AND (M_NEW_CUST_TBL(p_customer_id).DOWNLOAD_FLAG = 'Y'))
       )
    THEN
        l_download_status := 'I';
    ELSIF (p_add_update_date > t_last_sync_time)
    THEN
        l_download_status := 'U';
    ELSE
        l_download_status := 'O';
    END IF;

 RETURN l_download_status;
END Check_Address_Download;


/*
** Passing in a customer, check if it is updateable by this particular
** resource
** For contact access priv, the sql will pass in the object_id to check.
** because contact's updateable belongs to its object that it relates to.
*/
FUNCTION CHECK_CUSTOMER_UPDATEBLE
(p_api_version_number IN NUMBER
,p_init_msg_list      IN VARCHAR2
,p_validation_level IN NUMBER
,p_customer_id IN NUMBER
,p_party_type IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2 IS
  l_access_privilege VARCHAR2(1);
  l_return_status    VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(500);
/* START BLAM */
  l_party_Type	VARCHAR2(30);

  CURSOR C_Get_Party_Type (p_party_id NUMBER) IS
  SELECT party_type
  FROM HZ_PARTIES
  WHERE party_id = p_party_id;
BEGIN

    if p_party_type IS NULL then
      OPEN C_Get_Party_Type (p_customer_id);
      FETCH C_Get_Party_Type into l_party_type;
      IF C_Get_Party_Type%NOTFOUND THEN
        RAISE NO_DATA_FOUND;
      END IF;
      CLOSE C_Get_Party_Type;
    else
      l_party_type := p_party_type;
    end if;

    IF l_party_type = 'ORGANIZATION' THEN
/* END  BLAM */
      AS_ACCESS_PUB.has_organizationAccess
      (p_api_version_number => p_api_version_number
	,p_init_msg_list  => p_init_msg_list
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> t_access_profile_rec
	,p_admin_flag		=> t_manager_flag
	,p_admin_group_id	=> t_salesgroup_id
	,p_person_id		=> t_person_id
	,p_customer_id		=> p_customer_id
	,p_check_access_flag  => 'Y'
	,p_identity_salesforce_id => t_salesforce_id
	,p_partner_cont_party_id => null
	,x_return_status => l_return_status
	,x_msg_count	     => l_msg_count
	,x_msg_data	 => l_msg_data
	,x_access_privilege	 => l_access_privilege
    );
/* START BLAM */

    ELSIF l_party_type = 'PERSON' THEN
      AS_ACCESS_PUB.has_personAccess
      (p_api_version_number => p_api_version_number
	,p_init_msg_list  => p_init_msg_list
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> t_access_profile_rec
	,p_admin_flag		=> t_manager_flag
	,p_admin_group_id	=> t_salesgroup_id
	,p_person_id		=> t_person_id
	,p_security_id		=> null
	,p_security_type	=> null
	,p_person_party_id	=> p_customer_id
	,p_check_access_flag  => 'Y'
	,p_identity_salesforce_id => t_salesforce_id
	,p_partner_cont_party_id => null
	,x_return_status => l_return_status
	,x_msg_count	     => l_msg_count
	,x_msg_data	 => l_msg_data
	,x_access_privilege	 => l_access_privilege
      );
    ELSE
	l_access_privilege := 'N';
    END IF;
/* END BLAM */

    IF (l_access_privilege = 'F')
    THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
WHEN OTHERS THEN
      RETURN 'N';
END CHECK_CUSTOMER_UPDATEBLE;

FUNCTION CHECK_OPPORTUNITY_UPDATEBLE
(p_api_version_number IN NUMBER
,p_init_msg_list      IN VARCHAR2
,p_validation_level IN NUMBER
,p_opportunity_id IN NUMBER
) RETURN VARCHAR2 IS
  l_access_privilege VARCHAR2(1);
  l_return_status    VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(500);
BEGIN

    AS_ACCESS_PUB.has_opportunityAccess
    (p_api_version_number => p_api_version_number
	,p_init_msg_list  => p_init_msg_list
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> t_access_profile_rec
	,p_admin_flag		=> t_manager_flag
	,p_admin_group_id	=> t_salesgroup_id
	,p_person_id		=> t_person_id
	,p_opportunity_id		=> p_opportunity_id
	,p_check_access_flag  => 'Y'
	,p_identity_salesforce_id => t_salesforce_id
	,p_partner_cont_party_id => null
	,x_return_status => l_return_status
	,x_msg_count	     => l_msg_count
	,x_msg_data	 => l_msg_data
	,x_access_privilege => l_access_privilege
    );

    IF (l_access_privilege = 'F')
    THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
WHEN OTHERS THEN
      RETURN 'N';
END CHECK_OPPORTUNITY_UPDATEBLE;

FUNCTION CHECK_LEAD_UPDATEBLE
(p_api_version_number IN NUMBER
,p_init_msg_list      IN VARCHAR2
,p_validation_level IN NUMBER
,p_sales_lead_id IN NUMBER
) RETURN VARCHAR2 IS
  l_access_privilege VARCHAR2(1);
  l_return_status    VARCHAR2(1);
  l_msg_count     NUMBER;
  l_msg_data      VARCHAR2(500);
BEGIN

    AS_ACCESS_PUB.has_leadAccess
    (p_api_version_number => p_api_version_number
	,p_init_msg_list  => p_init_msg_list
	,p_validation_level	=> p_validation_level
	,p_access_profile_rec	=> t_access_profile_rec
	,p_admin_flag		=> t_manager_flag
	,p_admin_group_id	=> t_salesgroup_id
	,p_person_id		=> t_person_id
	,p_sales_lead_id		=> p_sales_lead_id
	,p_check_access_flag  => 'Y'
	,p_identity_salesforce_id => t_salesforce_id
	,p_partner_cont_party_id => null
	,x_return_status => l_return_status
	,x_msg_count	     => l_msg_count
	,x_msg_data	 => l_msg_data
	,x_access_privilege => l_access_privilege
    );

    IF (l_access_privilege = 'F')
    THEN
        RETURN 'Y';
    ELSE
        RETURN 'N';
    END IF;

EXCEPTION
WHEN OTHERS THEN
      RETURN 'N';
END CHECK_LEAD_UPDATEBLE;

/*
FUNCTION CHECK_CUSTOMER_UPDATEBLE(p_customer_id IN NUMBER) RETURN VARCHAR2 IS
  v_dummy VARCHAR2(1);
CURSOR C_CUSTOMER_UPDATEABLE (p_customer_id NUMBER,
                              p_resource_id NUMBER) IS
    SELECT 'X' FROM AS_ACCESSES_ALL
    WHERE salesforce_id = p_resource_id
    AND   customer_id   = p_customer_id
    AND   lead_id       is NULL
    AND   sales_lead_id is NULL;
BEGIN
   OPEN C_CUSTOMER_UPDATEABLE(p_customer_id, t_salesforce_id);
   FETCH C_CUSTOMER_UPDATEABLE INTO v_dummy;
   IF C_CUSTOMER_UPDATEABLE%NOTFOUND
   THEN
      CLOSE C_CUSTOMER_UPDATEABLE;
      RETURN 'N';
   END IF;
   CLOSE C_CUSTOMER_UPDATEABLE;
   RETURN 'Y';
END CHECK_CUSTOMER_UPDATEBLE;
*/

/*
** Given a sales group id, check if this sales rep is manager of this sales group
*/
FUNCTION CHECK_MANAGER_FLAG(p_group_id IN NUMBER) RETURN VARCHAR2 IS
   v_dummy VARCHAR2(1);
CURSOR C_MANAGER_FLAG(p_group_id NUMBER, p_salesforce_id NUMBER) IS
   SELECT 'X' FROM AS_FC_SALESFORCE_V
   WHERE salesforce_id = p_salesforce_id
   AND sales_group_id = p_group_id
   AND member_delete_flag <> 'Y'
   AND rrel_delete_flag <> 'Y'
   AND manager_flag = 'Y';
BEGIN
   OPEN C_MANAGER_FLAG(p_group_id, t_salesforce_id);
   FETCH C_MANAGER_FLAG INTO v_dummy;
   IF C_MANAGER_FLAG%NOTFOUND
   THEN
      CLOSE C_MANAGER_FLAG;
      RETURN 'N';
   END IF;
   CLOSE C_MANAGER_FLAG;
   RETURN 'Y';
END CHECK_MANAGER_FLAG;


FUNCTION GET_SOURCE_NAME(p_source_code_id IN NUMBER) RETURN VARCHAR2 IS
    l_source_name VARCHAR2(2000) := NULL;
    CURSOR C_SOURCE_NAME(p_source_code_id NUMBER) IS
        SELECT name FROM AMS_P_SOURCE_CODES_V
        WHERE SOURCE_CODE_ID = p_source_code_id;
BEGIN
    OPEN C_SOURCE_NAME(p_source_code_id);
    FETCH C_SOURCE_NAME INTO l_source_name;
    IF C_SOURCE_NAME%NOTFOUND
    THEN
        l_source_name := NULL;
    END IF;
    CLOSE C_SOURCE_NAME;
    RETURN l_source_name;
END GET_SOURCE_NAME;

/*
** quote header incremental sync
*/
FUNCTION Check_Quote_Download
(p_qot_creation_date       IN DATE
,p_qot_update_date         IN DATE
,p_qot_header_id           IN NUMBER
,p_cust_accnt_update_date  IN DATE
,p_customer_update_date    IN DATE
,p_org_contact_update_date IN DATE
,p_rel_update_date         IN DATE
,p_contact_party_update_date IN DATE
,p_sold_to_party_update_date IN DATE
,p_related_obj_update_date IN DATE
,p_related_opp_update_date IN DATE

) RETURN VARCHAR2  IS

  l_new_qot_rec ASL_NEW_QUOTE_REC_TYPE;
  l_download_status VARCHAR2(1) := 'I';
BEGIN
  IF (M_FULL_SYNC = FALSE) THEN
     IF (p_qot_header_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
     END IF;
     IF ((p_qot_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_TBL.EXISTS(p_qot_header_id))
        )
     THEN
     IF (M_NEW_QOT_TBL.EXISTS(p_qot_header_id)
           ) THEN
           M_NEW_QOT_TBL(p_qot_header_id).DOWNLOAD_FLAG := 'Y';
     ELSE
           l_new_qot_rec.QUOTE_HEADER_ID := p_qot_header_id;
           l_new_qot_rec.DOWNLOAD_FLAG := 'Y';
           M_NEW_QOT_TBL(p_qot_header_id) := l_new_qot_rec;
     END IF;
     ELSIF ((p_qot_update_date > t_last_sync_time) OR
            (p_cust_accnt_update_date > t_last_sync_time) OR
            (p_customer_update_date > t_last_sync_time) OR
            (p_org_contact_update_date > t_last_sync_time) OR
            (p_rel_update_date > t_last_sync_time) OR
            (p_contact_party_update_date > t_last_sync_time) OR
            (p_sold_to_party_update_date > t_last_sync_time) OR
            (p_related_obj_update_date > t_last_sync_time) OR
            (p_related_opp_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;

  END IF;

  RETURN l_download_status;
END Check_Quote_Download;


/*
** quote detail incremental sync
*/
FUNCTION Check_Quote_Det_Download
(p_quote_line_creation_date IN DATE
,p_quote_line_update_date   IN DATE
,p_quote_line_det_update_date IN DATE
,p_quote_header_id IN NUMBER
,p_quote_line_id   IN NUMBER
,p_quote_line_detail_id       IN NUMBER
) RETURN VARCHAR2 IS
  l_new_qot_det_rec ASL_NEW_QUOTE_DET_REC_TYPE;
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_quote_line_id >= M_SERVER_PK_ID_MAX) OR
         (p_quote_header_id >= M_SERVER_PK_ID_MAX)) THEN
       RETURN l_download_status;
     END IF;
     IF ((p_quote_line_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_TBL.EXISTS(p_quote_header_id) AND (M_NEW_QOT_TBL(p_quote_header_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        l_new_qot_det_rec.QUOTE_HEADER_ID := p_quote_header_id;
        l_new_qot_det_rec.QUOTE_LINE_ID := p_quote_line_id;
        l_new_qot_det_rec.QUOTE_LINE_DETAIL_ID := p_quote_line_detail_id;
        M_NEW_QOT_DET_TBL(p_quote_line_id) := l_new_qot_det_rec;
     ELSIF ((p_quote_line_update_date > t_last_sync_time) OR
            (p_quote_line_det_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Quote_Det_Download;

/*
** quote shipment incremental sync
*/
FUNCTION Check_Quote_Shipment_Download
(p_quote_shipment_creation_date IN DATE
,p_quote_shipment_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_shipment_id IN NUMBER
,p_ship_to_site_update_date     IN DATE
,p_ship_to_relation_update_date IN DATE
,p_ship_to_contact_update_date  IN DATE

) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_quote_header_id >= M_SERVER_PK_ID_MAX))
     THEN
       RETURN l_download_status;
     END IF;
     IF ((p_quote_shipment_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_TBL.EXISTS(p_quote_header_id) AND (M_NEW_QOT_TBL(p_quote_header_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        l_download_status := 'I';
     ELSIF ((p_quote_shipment_update_date > t_last_sync_time) OR
            (p_ship_to_site_update_date > t_last_sync_time) OR
            (p_ship_to_relation_update_date > t_last_sync_time) OR
            (p_ship_to_contact_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Quote_Shipment_Download;

/*
** quote payment incremental sync
*/
FUNCTION Check_Quote_Payment_Download
(p_quote_payment_creation_date IN DATE
,p_quote_payment_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_payment_id IN NUMBER

) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_quote_header_id >= M_SERVER_PK_ID_MAX))
     THEN
       RETURN l_download_status;
     END IF;
     IF ((p_quote_payment_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_TBL.EXISTS(p_quote_header_id) AND (M_NEW_QOT_TBL(p_quote_header_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        l_download_status := 'I';
     ELSIF (p_quote_payment_update_date > t_last_sync_time)
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Quote_Payment_Download;


/*
** quote price adjustment incremental sync
*/
FUNCTION Check_Quote_Price_Adj_Download
(p_price_Adj_creation_date IN DATE
,p_price_Adj_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_line_id   IN NUMBER
,p_price_adjustment_id IN NUMBER

) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF (p_quote_line_id >= M_SERVER_PK_ID_MAX)
     THEN
       RETURN l_download_status;
     END IF;
     IF ((p_price_Adj_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_DET_TBL.EXISTS(p_quote_line_id) )
        )
     THEN
        l_download_status := 'I';
     ELSIF (p_price_Adj_update_date > t_last_sync_time)
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Quote_Price_Adj_Download;

/*
** quote sales team incremental sync
*/
FUNCTION Check_Quote_Salesteam_Download
(p_qot_Salesteam_creation_date IN DATE
,p_qot_Salesteam_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_access_id   IN NUMBER
) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_quote_header_id >= M_SERVER_PK_ID_MAX) )
     THEN
       RETURN l_download_status;
     END IF;
     IF ((p_qot_Salesteam_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_DET_TBL.EXISTS(p_quote_header_id) AND (M_NEW_QOT_TBL(p_quote_header_id).DOWNLOAD_FLAG = 'Y') )
        )
     THEN
        l_download_status := 'I';
     ELSIF (p_qot_Salesteam_update_date > t_last_sync_time)
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;
  return l_download_status;
END Check_Quote_Salesteam_Download;

/*
** quote sales credit incremental sync
*/
FUNCTION Check_Qot_Salescredit_Download
(p_qot_scredit_creation_date IN DATE
,p_qot_scredit_update_date   IN DATE
,p_quote_header_id   IN NUMBER
,p_quote_sales_credit_id   IN NUMBER
) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE) THEN
     IF ((p_quote_header_id >= M_SERVER_PK_ID_MAX) )
     THEN
       RETURN l_download_status;
     END IF;
     IF ((p_qot_scredit_creation_date > t_last_sync_time) OR
         (M_NEW_QOT_TBL.EXISTS(p_quote_header_id) AND (M_NEW_QOT_TBL(p_quote_header_id).DOWNLOAD_FLAG = 'Y'))
        )
     THEN
        l_download_status := 'I';
     ELSIF (p_qot_scredit_update_date > t_last_sync_time)
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;

  return l_download_status;
END Check_Qot_Salescredit_Download;


/*
** Inventory Item incremental sync
*/
FUNCTION Check_Inv_Item_Download
(p_inv_item_creation_date  IN DATE
,p_inv_item_b_update_date  IN DATE
,p_inv_item_tl_update_date IN DATE
,p_inv_catgry_update_date  IN DATE
,p_inv_uom_update_date     IN DATE
,p_inv_category_id   IN NUMBER
,p_inv_item_id       IN NUMBER
) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE AND M_OLD_INV_TBL.EXISTS(p_inv_category_id) )
  THEN
     IF ((p_inv_item_id >= M_SERVER_PK_ID_MAX) )
     THEN
       RETURN l_download_status;
     END IF;
     IF (p_inv_item_creation_date > t_last_sync_time)
     THEN
        l_download_status := 'I';
     ELSIF ( (p_inv_item_b_update_date > t_last_sync_time) OR
             (p_inv_item_tl_update_date > t_last_sync_time) OR
             (p_inv_catgry_update_date > t_last_sync_time) OR
             (p_inv_uom_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;

  return l_download_status;
END Check_Inv_Item_Download;


/*
** price list line incremental sync
*/
FUNCTION Check_Price_List_Download
(p_list_line_creation_date IN DATE
,p_list_line_update_date   IN DATE
,p_line_attr_update_date   IN DATE
,p_list_header_id   IN NUMBER
,p_inv_category_id  IN NUMBER
) RETURN VARCHAR2 IS
  l_download_status VARCHAR2(1) := 'I';

BEGIN

  IF (M_FULL_SYNC = FALSE AND M_OLD_PRICE_LIST_TBL.EXISTS(p_list_header_id) AND
      M_OLD_INV_TBL.EXISTS(p_inv_category_id) )
  THEN
     IF (p_list_line_creation_date > t_last_sync_time)
     THEN
        l_download_status := 'I';
     ELSIF ((p_list_line_update_date > t_last_sync_time) OR
            (p_line_attr_update_date > t_last_sync_time)
           )
     THEN
        l_download_status := 'U';
     ELSE
        l_download_status := 'O';
     END IF;
  END IF;

  return l_download_status;
END Check_Price_List_Download;


/*
** customer account incremental sync
*/
/* BLAM Changed references to M_NEW_ORG_TBL to M_NEW_CUST_TBL */
FUNCTION Check_Cust_Account_Download
(p_customer_id IN NUMBER
,p_cust_accnt_id IN NUMBER
,p_cust_accnt_creation_date IN DATE
,p_cust_update_date   IN DATE
,p_cust_accnt_update_date   IN DATE
,p_loc_update_date      IN DATE
,p_site_update_date     IN DATE
,p_site_use_update_date IN DATE
) RETURN VARCHAR2 IS
 l_new_account_rec ASL_CUSTOMER_ACCOUNT_REC_TYPE;
 l_download_status VARCHAR2(1) := 'I';
BEGIN
 IF (M_FULL_SYNC = FALSE) THEN
    IF (p_customer_id >= M_SERVER_PK_ID_MAX OR p_cust_accnt_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;
    IF ((M_NEW_CUST_TBL.EXISTS(p_customer_id) AND (M_NEW_CUST_TBL(p_customer_id).DOWNLOAD_FLAG = 'Y')) OR
        (p_cust_accnt_creation_date > t_last_sync_time)
       )
    THEN
       l_download_status := 'I';
       l_new_account_rec.CUST_ACCOUNT_ID := p_cust_accnt_id;
       M_NEW_CUST_ACCOUNT_TBL(p_cust_accnt_id) := l_new_account_rec;
    ELSIF  ((p_cust_update_date > t_last_sync_time) OR
            (p_cust_accnt_update_date > t_last_sync_time) OR
            (p_loc_update_date > t_last_sync_time) OR
            (p_site_update_date > t_last_sync_time) OR
            (p_site_use_update_date > t_last_sync_time)
           )
    THEN
       l_download_status := 'U';
    ELSE
       l_download_status := 'O';
    END IF;
 END IF;
 RETURN l_download_status;
END Check_Cust_Account_Download;

/*
** related customer address incremental sync
*/
FUNCTION Check_Rel_Cust_Addr_Download
(p_cust_accnt_id IN NUMBER
,p_cust_rel_creation_date IN DATE
,p_cust_update_date   IN DATE
,p_loc_update_date      IN DATE
,p_site_update_date     IN DATE
) RETURN VARCHAR2 IS
 l_download_status VARCHAR2(1) := 'I';
BEGIN
 IF (M_FULL_SYNC = FALSE) THEN
    IF (p_cust_accnt_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;
    IF ((p_cust_rel_creation_date > t_last_sync_time) OR
        (M_NEW_CUST_ACCOUNT_TBL.EXISTS(p_cust_accnt_id))
       )
    THEN
       l_download_status := 'I';
    ELSIF  ((p_cust_update_date > t_last_sync_time) OR
            (p_loc_update_date > t_last_sync_time) OR
            (p_site_update_date > t_last_sync_time)
           )
    THEN
       l_download_status := 'U';
    ELSE
       l_download_status := 'O';
    END IF;
 END IF;
 RETURN l_download_status;
END Check_Rel_Cust_Addr_Download;

/*
** related customer contact incremental sync
*/
FUNCTION Check_Rel_Cust_Cont_Download
(p_cust_accnt_id IN NUMBER
,p_cust_rel_creation_date IN DATE
,p_cust_update_date   IN DATE
,p_contact_update_date      IN DATE
) RETURN VARCHAR2 IS
 l_download_status VARCHAR2(1) := 'I';
BEGIN
 IF (M_FULL_SYNC = FALSE) THEN
    IF (p_cust_accnt_id >= M_SERVER_PK_ID_MAX) THEN
       RETURN l_download_status;
    END IF;
    IF ((p_cust_rel_creation_date > t_last_sync_time) OR
        (M_NEW_CUST_ACCOUNT_TBL.EXISTS(p_cust_accnt_id))
       )
    THEN
       l_download_status := 'I';
    ELSIF  ((p_cust_update_date > t_last_sync_time) OR
            (p_contact_update_date > t_last_sync_time)
           )
    THEN
       l_download_status := 'U';
    ELSE
       l_download_status := 'O';
    END IF;
 END IF;
 RETURN l_download_status;
END Check_Rel_Cust_Cont_Download;

PROCEDURE SET_DEFAUL_ORG_ID
(p_default_org_id IN NUMBER
) IS
BEGIN
  t_org_id := p_default_org_id;
END SET_DEFAUL_ORG_ID;

PROCEDURE SET_ENABLED_MODULES
(p_module_name IN VARCHAR2
) IS
BEGIN
  IF p_module_name = 'ORGANIZATION' THEN
    t_org_enabled_flag := TRUE;
  END IF;

/* BLAM */
  IF p_module_name = 'PERSON' THEN
    t_per_enabled_flag := TRUE;
  END IF;
/* BLAM */

  IF p_module_name = 'CONTACT' THEN
    t_cnt_enabled_flag := TRUE;
  END IF;

  IF p_module_name = 'OPPORTUNITY' THEN
    t_opp_enabled_flag := TRUE;
  END IF;

  IF p_module_name = 'LEAD' THEN
    t_lead_enabled_flag := TRUE;
  END IF;

  IF p_module_name = 'FORECAST' THEN
    t_frcst_enabled_flag := TRUE;
  END IF;

  IF p_module_name = 'QUOTE' THEN
    t_qot_enabled_flag := TRUE;
  END IF;

END SET_ENABLED_MODULES;

/*
** End of quote incremental sync
*/

/*
*Overload lead/opp dirty flag for incremental sync home page
*display problem caused by a change in the related org.
*/
FUNCTION GET_LEAD_DIRTY
(p_lead_creation_date IN DATE
,p_lead_last_update_date IN DATE
,p_customer_update_date    IN DATE
) RETURN VARCHAR2  IS
BEGIN
  IF (M_FULL_SYNC = FALSE) THEN
    IF   (p_customer_update_date > t_last_sync_time)
     THEN
	IF ((p_lead_creation_date < t_last_sync_time) AND
	    (p_lead_last_update_date < t_last_sync_time)
           )
	THEN
            return 'NI';
	END IF;
     END IF;
  END IF;
  RETURN '';
END GET_LEAD_DIRTY;

FUNCTION GET_OPPORTUNITY_DIRTY
(p_opp_creation_date IN DATE
,p_opp_update_date IN DATE
,p_customer_update_date IN DATE
) RETURN VARCHAR2  IS
BEGIN
  IF (M_FULL_SYNC = FALSE) THEN
    IF   (p_customer_update_date > t_last_sync_time)
     THEN
	IF  ((p_opp_creation_date < t_last_sync_time) AND
             (p_opp_update_date < t_last_sync_time)
            )
	THEN
            return 'NI';
	END IF;
     END IF;
  END IF;
  RETURN '';
END GET_OPPORTUNITY_DIRTY;

END ASL_EXCEL_UTIL_PVT;


/
