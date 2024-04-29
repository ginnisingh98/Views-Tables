--------------------------------------------------------
--  DDL for Package Body IEX_COLLECTORS_TO_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_COLLECTORS_TO_RESOURCE" AS
/* $Header: iexctrab.pls 120.6 2006/07/18 21:19:47 acaraujo noship $ */
    /*-----------------------------------------------------------------------
		UPDATE_COLLECTORS

	This procedure takes the following primary parameters in the process
            1. P_debug to enable or disable the log messages.
    ------------------------------------------------------------------------*/

PROCEDURE MERGE_COLLECTORS(P_DEBUG IN VARCHAR2);

PROCEDURE UPDATE_COLLECTORS
(
ERRBUF     OUT NOCOPY VARCHAR2,
RETCODE    OUT NOCOPY VARCHAR2,
P_RESP1    IN  VARCHAR2,
P_RESP2    IN  VARCHAR2,
P_RESP3    IN  VARCHAR2,
P_RESP4    IN  VARCHAR2,
P_RESP5    IN  VARCHAR2,
P_debug    IN  VARCHAR2
)
IS
l_date_time VARCHAR2(25);
l_colcount NUMBER;
BEGIN

 IF (p_debug = 'Y') THEN
  dbms_session.set_sql_trace(TRUE);
 END IF;

 fnd_file.put_line(FND_FILE.LOG,'Updating collector resources started ');
 fnd_file.put_line(FND_FILE.LOG,'Parameter : p_debug := ' || P_debug);

 fnd_file.put_line(FND_FILE.LOG,' Parameter : Responsibility 1 :=  '|| P_resp1);
 fnd_file.put_line(FND_FILE.LOG,' Parameter : Responsibility 2 :=  '|| p_resp2);
 fnd_file.put_line(FND_FILE.LOG,' Parameter : Responsibility 3 :=  '|| p_resp3);
 fnd_file.put_line(FND_FILE.LOG,' Parameter : Responsibility 4 :=  '|| p_resp4);
 fnd_file.put_line(FND_FILE.LOG,' Parameter : Responsibility 5 :=  '|| p_resp5);

 If (P_debug = 'Y') then
   Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
   fnd_file.put_line(FND_FILE.LOG,'Date and Time Before starting the update on ar_collectors '|| l_date_time );
 End If;

 /* kasreeni 07/14/2005  Changed to Merge_Collectors as function  */
 /* kasreeni 07/14/2005  Missed a COMMIT, when no responsibility selected */
 MERGE_COLLECTORS(P_DEBUG);

 IF P_RESP1 IS NOT NULL THEN
  UPDATE_COLLECTORS_PVT(p_resp => P_RESP1,p_debug => p_debug);
 END IF;

 IF P_RESP2 IS NOT NULL THEN
  UPDATE_COLLECTORS_PVT(p_resp => P_RESP2,p_debug => p_debug);
 END IF;

 IF P_RESP3 IS NOT NULL THEN
  UPDATE_COLLECTORS_PVT(p_resp => P_RESP3,p_debug => p_debug);
 END IF;

 IF P_RESP4 IS NOT NULL THEN
  UPDATE_COLLECTORS_PVT(p_resp => P_RESP4,p_debug => p_debug);
 END IF;

 IF P_RESP5 IS NOT NULL THEN
  UPDATE_COLLECTORS_PVT(p_resp => P_RESP5,p_debug => p_debug);
 END IF;

 IF (P_RESP1 IS NULL AND P_RESP2 IS NULL AND P_RESP3 IS NULL AND P_RESP4 IS NULL AND P_RESP5 IS NULL) THEN
  fnd_file.put_line(FND_FILE.LOG,' Select atleast one responsibility in the parameters ');
 END IF;

END;

/* BEGIN KASREENI 05/17/2005 Made it as procedure to normalize */
PROCEDURE MERGE_COLLECTORS ( P_DEBUG IN VARCHAR2)
IS
l_colcount NUMBER;
l_date_time VARCHAR2(25);
BEGIN
If (P_debug = 'Y') then
   Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
   fnd_file.put_line(FND_FILE.LOG,'Date and Time Before starting the update on ar_collectors '|| l_date_time );
 End If;

    UPDATE ar_collectors ARC set
     resource_type = 'RS_RESOURCE',
     resource_id =
       ( SELECT max(jtfrs.resource_id)
         FROM  jtf_rs_resource_extns jtfrs
         WHERE
         jtfrs.source_id is NOT NULL
         AND  jtfrs.category = 'EMPLOYEE'
         AND Trunc(start_date_active) <= Trunc(sysdate)
         AND Nvl(Trunc(end_date_active),sysdate) >= Trunc(sysdate)
         AND arc.employee_id = jtfrs.source_id)
    WHERE employee_id is not null
    AND resource_id is null;

    l_colcount := sql%rowcount;
    fnd_file.put_line(FND_FILE.LOG, l_colcount || ' Record(s) updated in ar_collectors by merging Resource' ) ;
    Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
    If (P_debug = 'Y') then
       fnd_file.put_line(FND_FILE.LOG,'Date and Time After finishing the update on ar_collectors'|| l_date_time );
    End If;
    if (l_colcount > 0) then
        COMMIT;
    end if;

   Exception when others  then
      fnd_file.put_line(FND_FILE.LOG, 'Error while update the ar_collectors' ||  sqlerrm);
END;
/* END KASREENI 05/17/2005 MADE IT AS PROCEDURE TO NORMALIZE */

PROCEDURE UPDATE_COLLECTORS_PVT
(
p_resp     IN  VARCHAR2,
P_debug    IN  VARCHAR2
)
IS
l_date_time      VARCHAR2(20);
l_return_status   VARCHAR2(5);
l_msg_count       NUMBER;
l_msg_data        VARCHAR2(100);
l_resource_id     NUMBER;
l_resource_number NUMBER;

l_Role_id         NUMBER;
l_role_relate_id  NUMBER;
l_responsibility_id NUMBER;

CURSOR C_ROLE_ID IS
    SELECT role_id from JTF_RS_ROLES_B WHERE ROLE_CODE = 'IEX_AGENT' and ROLE_TYPE_CODE = 'COLLECTIONS';

--Bug4930348. Use Responsibility Id. Fix by LKKUMAR on 16-Jan-2006. Start.
CURSOR C_RESPONSIBILITY IS
  SELECT RESPONSIBILITY_ID FROM fnd_responsibility_vl fr
  WHERE responsibility_name LIKE P_RESP;


CURSOR INSERT_RESOURCE IS
  SELECT jtfrs.resource_id,SOURCE_ID,SOURCE_NAME,jtfrs.user_name
    from fnd_user_resp_groups furg,  fnd_responsibility_vl fr, jtf_rs_resource_extns jtfrs
    WHERE fr.responsibility_id = furg.responsibility_id
    AND jtfrs.user_id = furg.user_id
    AND furg.start_date < sysdate and (furg.end_date is null or furg.end_date > sysdate)
    AND jtfrs.source_id is not null and jtfrs.user_id is not null
    AND jtfrs.category = 'EMPLOYEE'
--    AND fr.responsibility_name like P_RESP --Bug4930348.
    AND fr.responsibility_id = l_responsibility_id --Bug4930348.
    AND jtfrs.RESOURCE_ID NOT IN
    (SELECT resource_id FROM
        ar_collectors  ac
        WHERE employee_id is not null
        AND ac.employee_id = jtfrs.source_id
	AND ac.resource_id = jtfrs.resource_id
	AND ac.resource_type =  'RS_RESOURCE' )
   AND jtfrs.user_id is not null
  ORDER BY 1;
--Bug4930348. Use Responsibility Id. Fix by LKKUMAR on 16-Jan-2006. End.

l_collector_id NUMBER;

l_colcount NUMBER;
l_check  NUMBER;

BEGIN

 fnd_file.put_line(FND_FILE.LOG,'Updating collector resource pvt started for Responsibility  ' || P_RESP);
 --RETCODE := 'TRUE';
--Bug4930348. Use Responsibility Id. Fix by LKKUMAR on 16-Jan-2006. Start.
OPEN  C_RESPONSIBILITY;
FETCH C_RESPONSIBILITY INTO l_responsibility_id;
CLOSE C_RESPONSIBILITY;

If (P_debug = 'Y') then
  fnd_file.put_line(FND_FILE.LOG, 'Responsibility Id Fetched is ' || l_responsibility_id );
End If;
--Bug4930348. Use Responsibility Id. Fix by LKKUMAR on 16-Jan-2006. End.



 SELECT to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
 fnd_file.put_line(FND_FILE.LOG,'Starting the conversion  ' || l_date_time);


 --   Inserting in to AR_COLLECTORS

 If (P_debug = 'Y') then
   Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
   fnd_file.put_line(FND_FILE.LOG,'Date and Time After finishing the update '|| l_date_time );
 End If;


 --   Inserting in to AR_COLLECTORS
 FOR I IN INSERT_RESOURCE LOOP
   If (P_debug = 'Y') then
   Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
     fnd_file.put_line(FND_FILE.LOG,'Date and Time Before starting the Insert '|| l_date_time );
   End If;
  BEGIN
    SELECT  AR_COLLECTORS_S.NEXTVAL
    INTO    L_COLLECTOR_ID
    FROM    DUAL;
  Exception when others then
    If (P_debug = 'Y') then
     fnd_file.put_line(FND_FILE.LOG,'Error while selecting the colector_id sequence ' || SQLERRM);
    End If;
  END;
  If (p_debug = 'Y') then
    fnd_file.put_line(FND_FILE.LOG,'Before Starting to insert Resouce_id ' || i.resource_id  || ' For Responsibility ' || p_resp);
  End If;

  BEGIN
    INSERT INTO AR_COLLECTORS
    (COLLECTOR_ID      ,
     LAST_UPDATED_BY    ,
     LAST_UPDATE_DATE   ,
     LAST_UPDATE_LOGIN  ,
     CREATION_DATE      ,
     CREATED_BY         ,
     NAME               ,
     EMPLOYEE_ID        ,
     DESCRIPTION        ,
     STATUS             ,
     RESOURCE_ID        ,
     RESOURCE_TYPE       )
    VALUES
     (l_collector_id     ,
      FND_GLOBAL.user_id  ,
      sysdate             ,
      FND_GLOBAL.login_id ,
      sysdate             ,
      FND_GLOBAL.user_id  ,
      i.user_name     ,
      i.source_id         ,
      i.source_name      ,
      'A',
      i.resource_id,
      'RS_RESOURCE' ) ;

      l_colcount := NVL(l_colcount,0) + 1;

  Exception When Others then
      fnd_file.put_line(FND_FILE.LOG, 'Error while Inserting into AR_COLLECTORS'  || SQLERRM);
  END;
  BEGIN
   SELECT 1
   INTO l_check
   FROM
   jtf_rs_resource_extns jtfrs,JTF_RS_ROLE_RELATIONS jtrr, JTF_RS_ROLES_B jtv
   WHERE
   jtrr.role_resource_id = jtfrs.resource_id
   AND jtv.role_id = jtrr.role_id
   AND jtv.ROLE_CODE = 'IEX_AGENT'
   AND jtrr.ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
   AND jtfrs.source_id is not null
   AND jtfrs.resource_id = i.resource_id;

   If (p_debug = 'Y') then
     fnd_file.put_line(FND_FILE.LOG,'Role  found for resource id ' || i.resource_id);
   End If;

  Exception when no_data_found then
    If (p_debug = 'Y') then
       fnd_file.put_line(FND_FILE.LOG,'Role not found for resource id ' || i.resource_id);
       fnd_file.put_line(FND_FILE.LOG,'Creating  Role for resource id ' || i.resource_id);
    End If;
     OPEN C_ROLE_ID;
     FETCH C_ROLE_ID into l_Role_id;
     CLOSE C_ROLE_ID;
     BEGIN
      JTF_RS_ROLE_RELATE_PUB.create_resource_role_relate
      (P_API_VERSION            =>  1.0,
       P_INIT_MSG_LIST          => 'T',
       P_COMMIT                 => 'F',
       P_ROLE_RESOURCE_TYPE     => 'RS_INDIVIDUAL' ,
       P_ROLE_RESOURCE_ID       => i.RESOURCE_ID,
       P_ROLE_ID                => l_Role_ID,
       P_ROLE_CODE              => 'COLLECTIONS',
       P_START_DATE_ACTIVE      => TRUNC(SYSDATE),
       X_RETURN_STATUS          => l_return_status,
       X_MSG_COUNT              => l_msg_count,
       X_MSG_DATA               => l_msg_data,
       X_ROLE_RELATE_ID         => l_role_relate_id
       );
       If (p_debug = 'Y') then
         fnd_file.put_line(FND_FILE.LOG,'After Creating role for resource_id: ' || i.resource_id || ' Responsibility: ' ||
         p_resp || ' Return Status ' || l_return_status || ' Role Relate id ' || l_role_relate_id);
       End If;
     Exception when others then
         fnd_file.put_line(FND_FILE.LOG,'Error while creating the Role for the resource_id ' || i.resource_id || SQLERRM);
     END;
   END;

  End Loop;

 COMMIT;

 Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
 fnd_file.put_line(FND_FILE.LOG,'Date and Time Finish '|| l_date_time );
 fnd_file.put_line(FND_FILE.LOG,'No. of Collector(s) Added  '|| l_colcount);


EXCEPTION WHEN OTHERS THEN
   fnd_file.put_line(FND_FILE.LOG,'Error in update_colectors_pvt for Responsibility ' || P_RESP);
	-- Begin - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
	FND_FILE.put_line(FND_FILE.LOG, 'EXCEPTION!!!!! -> ' || SQLERRM );
	-- End - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception

END UPDATE_COLLECTORS_PVT;



PROCEDURE UPDATE_RESOURCES
(
ERRBUF     OUT NOCOPY VARCHAR2,
RETCODE    OUT NOCOPY VARCHAR2,
P_debug    IN VARCHAR2
)
IS
  l_return_status   VARCHAR2(5);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(100);
  l_resource_id     NUMBER;
  l_resource_number NUMBER;
  l_date_time       VARCHAR2(20);
  l_Role_id         NUMBER;
  l_role_relate_id  NUMBER;

  /*

  CURSOR INSERT_RESOURCES IS
    SELECT employee_id,inactive_date,description,name,resource_id FROM
     ar_collectors  ac
     WHERE employee_id is not null
     AND employee_id not in (SELECT jtr.source_id
     FROM JTF_RS_ROLE_RELATIONS jtrr, JTF_RS_ROLES_B jtv,
     JTF_RS_RESOURCE_EXTNS jtr
     WHERE jtv.ROLE_CODE = 'IEX_AGENT' AND jtv.role_id = jtrr.role_id
     AND jtrr.role_resource_id = jtr.resource_id
     AND jtrr.ROLE_RESOURCE_TYPE = 'RS_INDIVIDUAL'
     AND jtr.source_id is not null)
     AND employee_id not in (SELECT jtr.source_id from
     jtf_rs_resource_extns jtr where source_id is not null)
     AND resource_id is not null
     ORDER BY 1;

 */

  /* PROGRAM: To convert Collectors without Resource ID into Collector with Resource ID.
     1.Get the Collector IN ar_collector without Resource ID
     2.Create the Resource
     3.Add the Collector Agent for Role for created Resource
     3.Update the resource in AR_COLLECTOR.  */

  --Bug4929658. Fix By LKKUMAR on 12-Jan-2005. Include source phone, job title, email, addresses. Start.
  CURSOR INSERT_RESOURCES IS
    SELECT ac.collector_id, ac.name, ac.employee_id, ac.inactive_date, ac.description, ac.resource_id,
       fuser.user_id, fuser.user_name,  pemp.employee_number,
        pemp.full_name, pemp.first_name, pemp.last_name ,
	--New Columns
	hp.primary_phone_number,
	hp.person_title,
        hp.address1,
	hp.address2,
	hp.address3,
	hp.address4,
	hp.city,
	hp.postal_code,
	hp.state,
	hp.county,
	hp.country,
	hp.email_address
	FROM
     ar_collectors ac, FND_USER fuser, per_all_people_f pemp  ,hz_parties hp
     WHERE ac.employee_id is not null
     AND ac.employee_id not in (SELECT jtr.source_id from
     jtf_rs_resource_extns jtr where source_id is not null)
     AND ac.resource_id is  null
     AND ac.employee_id = fuser.employee_id
     and ac.employee_id = pemp.person_id
     and pemp.party_id = hp.party_id
     ORDER BY 1;
  --Bug4929658. Fix By LKKUMAR on 12-Jan-2005. Include source phone, job title, email, addresses. End.


  CURSOR c_ppf(p_person_id IN NUMBER) IS
   SELECT employee_number,
    full_name,
    first_name,
    middle_names,
    last_name,
    email_address,
    business_group_id,
    office_number,
    internal_location,
    mailstop
   FROM   per_all_people_f
   WHERE  person_id = p_person_id
   ORDER  BY effective_start_date DESC;

  CURSOR C_ROLE_ID is
    SELECT role_id from JTF_RS_ROLES_B WHERE ROLE_CODE = 'IEX_AGENT' and ROLE_TYPE_CODE = 'COLLECTIONS';

   l_colcount NUMBER;   /* Counter for no. of collectors */

  CURSOR update_resource IS
  SELECT
  DISTINCT
  FU.USER_NAME,
  FU.USER_ID,
  FU.EMPLOYEE_ID,
  JRS.RESOURCE_ID
    FROM
     FND_USER_RESP_GROUPS FURG,
     FND_RESPONSIBILITY FR ,
     FND_USER FU,
     JTF_RS_RESOURCE_EXTNS JRS
    WHERE
     FURG.RESPONSIBILITY_ID = FR.RESPONSIBILITY_ID
     AND JRS.SOURCE_ID = FU.EMPLOYEE_ID
     AND FU.USER_ID = FURG.USER_ID
     AND TRUNC(NVL(FU.START_DATE,SYSDATE))   <= TRUNC(SYSDATE)
     AND TRUNC(NVL(FU.END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
     AND TRUNC(NVL(FURG.END_DATE,SYSDATE)) >= TRUNC(SYSDATE)
     AND TRUNC(NVL(JRS.START_DATE_ACTIVE,SYSDATE)) <= TRUNC(SYSDATE)
     AND TRUNC(NVL(JRS.END_DATE_ACTIVE,SYSDATE)) >= TRUNC(SYSDATE)
     AND FU.EMPLOYEE_ID IS NOT NULL
     AND JRS.USER_ID IS NULL
     AND JRS.USER_NAME IS NULL
     AND JRS.CATEGORY = 'EMPLOYEE'
     AND FR.MENU_ID IN (
                        SELECT DISTINCT FCMF.MENU_ID
			FROM
                        FND_COMPILED_MENU_FUNCTIONS FCMF, FND_FORM_FUNCTIONS FFF
                        WHERE FCMF.FUNCTION_ID = FFF.FUNCTION_ID
                        AND FFF.FUNCTION_NAME = 'IEXRCALL');


  TYPE EMP_ID_LIST          is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  TYPE USER_ID_LIST         is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  TYPE USER_NAME_LIST       is TABLE of VARCHAR2(240) INDEX BY BINARY_INTEGER;
  TYPE RESOURCE_ID_LIST     is TABLE of NUMBER INDEX BY BINARY_INTEGER;
  g_bulk_fetch_rows         NUMBER   := 10000;
  L_CHECK_ROLE              NUMBER;
  L_EMPLOYEE_ID             EMP_ID_LIST;
  L_USER_NAME               USER_NAME_LIST;
  L_USER_ID                 USER_ID_LIST;
  L_RESOURCE_ID_LST          RESOURCE_ID_LIST;


BEGIN
   Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
   fnd_file.put_line(FND_FILE.LOG,'Date and Time Start conversion  '|| l_date_time );

  OPEN C_ROLE_ID;
  FETCH C_ROLE_ID INTO l_Role_id;
  CLOSE C_ROLE_ID;

  l_colcount := 0;

  if l_Role_id is NULL then
     FND_FILE.put_line(FND_FILE.LOG, 'No COLLECTOR ROLE seeded in the system ' );
     FND_FILE.put_line(FND_FILE.LOG, '  ');
     RETCODE := 'FALSE';
     return;
  end if;

 OPEN update_resource;
  LOOP
    FETCH update_resource BULK COLLECT INTO
      L_USER_NAME,
      L_USER_ID,
      L_EMPLOYEE_ID,
      L_RESOURCE_ID_LST
    LIMIT g_bulk_fetch_rows;
   IF L_USER_NAME.COUNT = 0 THEN
     EXIT;
   END IF;

     FOR i IN L_USER_ID.FIRST .. L_USER_ID.LAST
     LOOP

     BEGIN
     --UPdate the JTF_RS_RESOURCE_EXTNS Table with the value from FND_USER.
       UPDATE JTF_RS_RESOURCE_EXTNS
          SET USER_ID                     =  L_USER_ID(i),
	      USER_NAME                   =  L_USER_NAME(i),
              last_update_date            = SYSDATE,
              last_updated_by             = -1
        WHERE SOURCE_ID = L_EMPLOYEE_ID(I)
	       AND CATEGORY = 'EMPLOYEE'
	       -- Begin - Bug#5383877 - Andre Araujo - 07/18/2006 - With this statement there will be no updates
	       --AND  L_USER_ID(I) NOT IN (SELECT NVL(USER_ID,-1) FROM JTF_RS_RESOURCE_EXTNS WHERE CATEGORY = 'EMPLOYEE');
	       and user_id is null;
	       -- End - Bug#5383877 - Andre Araujo - 07/18/2006 - With this statement there will be no updates
    EXCEPTION WHEN OTHERS THEN
      -- Begin - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
      --NULL;
      FND_FILE.put_line(FND_FILE.LOG, 'EXCEPTION!!!!! -> ' || SQLERRM );
      -- End - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
    END;

    -- Check whether Collections Role Exists for the Resource and Create if Role does'nt exist.
     BEGIN
      SELECT ROLE_ID INTO L_CHECK_ROLE
        FROM JTF_RS_ROLE_RELATIONS_VL JRR,
             JTF_RS_RESOURCE_EXTNS JRE
        WHERE
          JRE.SOURCE_ID = L_EMPLOYEE_ID(I)
          AND JRR.ROLE_RESOURCE_ID = JRE.RESOURCE_ID
          AND JRR.ROLE_CODE = 'IEX_AGENT';
     EXCEPTION WHEN NO_DATA_FOUND THEN
      BEGIN
       JTF_RS_ROLE_RELATE_PUB.create_resource_role_relate
         (P_API_VERSION        =>  1.0,
          P_INIT_MSG_LIST      => 'T',
          P_COMMIT             => 'T',
          P_ROLE_RESOURCE_TYPE => 'RS_INDIVIDUAL' ,
          P_ROLE_RESOURCE_ID   => L_RESOURCE_ID_LST(I),
          P_ROLE_ID            => l_Role_ID,
          P_ROLE_CODE          => 'COLLECTIONS',
          P_START_DATE_ACTIVE  => TRUNC(SYSDATE),
          X_RETURN_STATUS      => l_return_status,
          X_MSG_COUNT          => l_msg_count,
          X_MSG_DATA           => l_msg_data,
          X_ROLE_RELATE_ID     => l_role_relate_id
         );
	 COMMIT;
        EXCEPTION
         WHEN OTHERS THEN
	         FND_FILE.put_line(FND_FILE.LOG, 'Error while creting roles' || l_msg_data );
				-- Begin - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
				FND_FILE.put_line(FND_FILE.LOG, SQLERRM );
				-- End - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
        END;
       WHEN OTHERS THEN --NULL;
				-- Begin - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
				FND_FILE.put_line(FND_FILE.LOG, 'EXCEPTION!!!!! -> ' || SQLERRM );
				-- End - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
      END;
     END LOOP;
    END LOOP;
   CLOSE update_resource;
 COMMIT;



  If (P_debug = 'Y') then
        fnd_file.put_line(FND_FILE.LOG,'Role id ' || l_Role_ID);
  end if;

  /* Begin Kasreeni 05/17/2004 Merge Existing Collectors */
  MERGE_COLLECTORS(P_DEBUG);
  /* End Kasreeni 05/17/2004 Merge Existing Collectors */

  FOR I in insert_resources loop
   BEGIN
  --Bug4929658. Fix By LKKUMAR on 12-Jan-2005. Include source phone, job title, email, addresses. Start.
   /*
    JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
     P_API_VERSION               => 1.0,
     P_INIT_MSG_LIST             => FND_API.G_TRUE,
     P_COMMIT                    => FND_API.G_TRUE,
     P_CATEGORY                  => 'EMPLOYEE',
     P_SOURCE_ID                 => i.employee_id,
     P_START_DATE_ACTIVE         => SYSDATE,
     P_END_DATE_ACTIVE           => i.inactive_date,
     P_COMMISSIONABLE_FLAG       => 'Y',
     P_HOLD_PAYMENT              => 'N',
     P_USER_ID                   => i.user_id,
     P_USER_NAME                 => i.user_name,
     P_RESOURCE_NAME             => i.full_name,
     P_SOURCE_NUMBER             => i.employee_number,
     P_SOURCE_NAME               => i.full_name,
     P_SOURCE_FIRST_NAME         => i.first_name,
     P_SOURCE_LAST_NAME          => i.last_name,
     P_TRANSACTION_NUMBER        => NULL,
     X_RETURN_STATUS             => l_return_status,
     X_MSG_COUNT                 => l_msg_count,
     X_MSG_DATA                  => l_msg_data,
     X_RESOURCE_ID               => l_resource_id,
     X_RESOURCE_NUMBER           => l_resource_number
     );
     */
   JTF_RS_RESOURCE_PUB.CREATE_RESOURCE(
   P_API_VERSION               => 1.0,
   P_INIT_MSG_LIST             => FND_API.G_TRUE,
   P_COMMIT                    => FND_API.G_TRUE,
   P_CATEGORY                  => 'EMPLOYEE',
   P_SOURCE_ID                 => i.employee_id,
   P_ADDRESS_ID                => NULL,
   P_CONTACT_ID                => NULL,
   P_MANAGING_EMP_ID           => NULL,
   P_MANAGING_EMP_NUM          => NULL,
   P_START_DATE_ACTIVE         => SYSDATE,
   P_END_DATE_ACTIVE           => i.inactive_date,
   P_TIME_ZONE                 => NULL,
   P_COST_PER_HR               => NULL,
   P_PRIMARY_LANGUAGE          => NULL,
   P_SECONDARY_LANGUAGE        => NULL,
   P_SUPPORT_SITE_ID           => NULL,
   P_IES_AGENT_LOGIN           => NULL,
   P_SERVER_GROUP_ID           => NULL,
   P_INTERACTION_CENTER_NAME   => NULL,
   P_ASSIGNED_TO_GROUP_ID      => NULL,
   P_COST_CENTER               => NULL,
   P_CHARGE_TO_COST_CENTER     => NULL,
   P_COMP_CURRENCY_CODE        => NULL,
   P_COMMISSIONABLE_FLAG       => 'Y',
   P_HOLD_REASON_CODE          => NULL,
   P_HOLD_PAYMENT              => 'N',
   P_COMP_SERVICE_TEAM_ID      => NULL,
   P_USER_ID                   => i.user_id,
   P_TRANSACTION_NUMBER        => NULL,
   X_RETURN_STATUS             => l_return_status,
   X_MSG_COUNT                 => l_msg_count,
   X_MSG_DATA                  => l_msg_data,
   X_RESOURCE_ID               => l_resource_id,
   X_RESOURCE_NUMBER           => l_resource_number,
   P_RESOURCE_NAME             => i.full_name,
   P_SOURCE_NAME               => i.full_name,
   P_SOURCE_NUMBER             => i.employee_number,
   P_SOURCE_JOB_TITLE          => i.person_title,
   P_SOURCE_EMAIL              => i.email_address,
   P_SOURCE_PHONE              => i.primary_phone_number,
   P_SOURCE_ORG_ID             => NULL,
   P_SOURCE_ORG_NAME           => NULL,
   P_SOURCE_ADDRESS1           => i.address1,
   P_SOURCE_ADDRESS2           => i.address2,
   P_SOURCE_ADDRESS3           => i.address3,
   P_SOURCE_ADDRESS4           => i.address4,
   P_SOURCE_CITY               => i.city,
   P_SOURCE_POSTAL_CODE        => i.postal_code,
   P_SOURCE_STATE              => i.state,
   P_SOURCE_PROVINCE           => NULL,
   P_SOURCE_COUNTY             => i.county,
   P_SOURCE_COUNTRY            => i.country,
   P_SOURCE_MGR_ID             => NULL,
   P_SOURCE_MGR_NAME           => NULL,
   P_SOURCE_BUSINESS_GRP_ID    => NULL,
   P_SOURCE_BUSINESS_GRP_NAME  => NULL,
   P_SOURCE_FIRST_NAME         => i.first_name,
   P_SOURCE_LAST_NAME          => i.last_name,
   P_SOURCE_MIDDLE_NAME        => NULL,
   P_SOURCE_CATEGORY           => NULL,
   P_SOURCE_STATUS             => NULL,
   P_SOURCE_OFFICE             => NULL,
   P_SOURCE_LOCATION           => NULL,
   P_SOURCE_MAILSTOP           => NULL,
   P_USER_NAME                 => i.user_name,
   P_SOURCE_MOBILE_PHONE       => NULL,
   P_SOURCE_PAGER              => NULL,
   P_ATTRIBUTE1                => NULL,
   P_ATTRIBUTE2                => NULL,
   P_ATTRIBUTE3                => NULL,
   P_ATTRIBUTE4                => NULL,
   P_ATTRIBUTE5                => NULL,
   P_ATTRIBUTE6                => NULL,
   P_ATTRIBUTE7                => NULL,
   P_ATTRIBUTE8                => NULL,
   P_ATTRIBUTE9                => NULL,
   P_ATTRIBUTE10               => NULL,
   P_ATTRIBUTE11               => NULL,
   P_ATTRIBUTE12               => NULL,
   P_ATTRIBUTE13               => NULL,
   P_ATTRIBUTE14               => NULL,
   P_ATTRIBUTE15               => NULL,
   P_ATTRIBUTE_CATEGORY        => NULL
   );
  --Bug4929658. Fix By LKKUMAR on 12-Jan-2005. Include source phone, job title, email, addresses. End.

     IF (l_return_status <> 'S') then
         fnd_file.put_line(FND_FILE.LOG,'Error while creating resource ' || i.name || '  Status  ' || l_return_status);

     ELSE
         l_colcount := l_colcount + 1;
         If (P_debug = 'Y') then
               fnd_file.put_line(FND_FILE.LOG,'Successfully completed for employee id ' || i.employee_id ||
                  'Status ' || l_return_status || ' ' || 'Resource id  '
		  || l_resource_id || ' Resource Number ' || l_resource_number);
      END IF;

         BEGIN
            UPDATE AR_COLLECTORS
            SET resource_id = l_resource_id
            WHERE collector_id = i.collector_id;

            If (p_debug = 'Y') then
                 fnd_file.put_line(FND_FILE.LOG,'After  updating for AR_COLLECTORS with resource_id ' || i.employee_id || ' ' || i.resource_id);
            End If;

         EXCEPTION WHEN OTHERS THEN
            fnd_file.put_line(FND_FILE.LOG,'Error occured while updating AR_COLLECTORS '
               || ' with  employee id  ' || i.employee_id );
             FND_FILE.put_line(FND_FILE.log, ' ');
				-- Begin - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception
				FND_FILE.put_line(FND_FILE.LOG, 'EXCEPTION!!!!! -> ' || SQLERRM );
				-- End - Bug#5383877 - Andre Araujo - 07/18/2006 - Since I am here correcting the exception

         END;

         JTF_RS_ROLE_RELATE_PUB.create_resource_role_relate
         (P_API_VERSION     =>  1.0,
          P_INIT_MSG_LIST   => 'T',
          P_COMMIT     => 'F',
          P_ROLE_RESOURCE_TYPE => 'RS_INDIVIDUAL' ,
          P_ROLE_RESOURCE_ID  => L_RESOURCE_ID,
          P_ROLE_ID       => l_Role_ID,
          P_ROLE_CODE => 'COLLECTIONS',
          P_START_DATE_ACTIVE => TRUNC(SYSDATE),
          X_RETURN_STATUS    => l_return_status,
          X_MSG_COUNT            => l_msg_count,
          X_MSG_DATA           => l_msg_data,
          X_ROLE_RELATE_ID     => l_role_relate_id
         );
         If (P_debug = 'Y') then
            fnd_file.put_line(FND_FILE.LOG,' Role API returns = ' || l_return_status ||
             '  ' || l_role_relate_id);
         end if;
     end if;


    EXCEPTION WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG,'Error while creating resource ' || i.name || ' ' || SQLERRM);
      FND_FILE.put_line(FND_FILE.log, ' ');
    END;


     l_resource_id := NULL;
     l_resource_number := NULL;
  END LOOP;
   Select to_char(sysdate,'DD-MON-YYYY HH24:MM:SS') into l_date_time from dual;
   fnd_file.put_line(FND_FILE.LOG,'Date and Time Finish   '|| l_date_time );
   FND_FILE.put_line(FND_FILE.LOG,'No. of. Resources Added := ' || l_colcount);

  COMMIT;

END;

End IEX_COLLECTORS_TO_RESOURCE;

/
