--------------------------------------------------------
--  DDL for Package Body ASP_CONTACT_PREF_SECURITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASP_CONTACT_PREF_SECURITY_PUB" AS
/* $Header: aspctpsb.pls 120.1.12010000.2 2009/08/12 22:32:27 hekkiral ship $ */


  PROCEDURE  DELETE_NO_ACCESS_CONTACTS
     (
      ERRBUF       OUT NOCOPY VARCHAR2,
      RETCODE      OUT NOCOPY VARCHAR2,
      P_DEBUG      IN  VARCHAR2
     )

     IS

     set_err_var VARCHAR2(1);

     l_party_id			NUMBER;
     l_category			VARCHAR2(64) ;
     l_preference_code		VARCHAR2(64) ;
     l_object_version_number	NUMBER;

     --l_value_varchar2		VARCHAR2(1) := FND_API.G_MISS_CHAR;
     --l_value_number		NUMBER := FND_API.G_MISS_NUM;
     --l_value_date		DATE     := FND_API.G_MISS_DATE;

     l_return_status		VARCHAR2(1);
     l_msg_count		NUMBER;
     l_msg_data			VARCHAR2(2000);
     l_comit_size               NUMBER ;
     l_count                    NUMBER ;

     CURSOR C_INACTIVE_CONTACTS IS
     SELECT
       PP.PARTY_ID,
       PP.VALUE_NUMBER,
       PP.OBJECT_VERSION_NUMBER
     FROM
       HZ_RELATIONSHIPS HR,
       HZ_PARTY_PREFERENCES PP
     WHERE
           PP.MODULE = 'SALES_BOOKMARKS'
     AND   PP.CATEGORY = 'BOOKMARKED_PARTY_RELATIONSHIP'
     AND   PP.PREFERENCE_CODE = 'PARTY_ID'
     AND   PP.VALUE_NUMBER = HR.PARTY_ID
     AND   ( (TRUNC(SYSDATE) NOT BETWEEN TRUNC(NVL(HR.START_DATE,SYSDATE)) AND TRUNC(NVL(HR.END_DATE,SYSDATE)))
             OR HR.STATUS <> 'A')
     AND   HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
     AND   HR.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
     AND   HR.DIRECTIONAL_FLAG = 'F';


     CURSOR C_SALES_TEAM_ACCESS IS
     SELECT
       PP.PARTY_ID,
       PP.VALUE_NUMBER,
       PP.OBJECT_VERSION_NUMBER
     FROM
       HZ_RELATIONSHIPS HR,
       HZ_PARTY_PREFERENCES PP,
       JTF_RS_RESOURCE_EXTNS res,
       PER_ALL_PEOPLE_F per
     WHERE
           PP.MODULE = 'SALES_BOOKMARKS'
     AND   PP.CATEGORY = 'BOOKMARKED_PARTY_RELATIONSHIP'
     AND   PP.PREFERENCE_CODE = 'PARTY_ID'
     AND   PP.VALUE_NUMBER = HR.PARTY_ID
     AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(HR.START_DATE,SYSDATE)) AND TRUNC(NVL(HR.END_DATE,SYSDATE))
     AND   HR.STATUS = 'A'
     AND   HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
     AND   HR.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
     AND   HR.DIRECTIONAL_FLAG = 'F'
     AND   TRUNC(NVL(per.effective_end_date, SYSDATE)) >= TRUNC(SYSDATE)
     AND   res.category = 'EMPLOYEE'
     AND   res.source_id = per.person_id
     AND   PP.PARTY_ID = per.PARTY_ID
     AND NOT EXISTS(
     SELECT  1
     FROM    as_accesses_all
     WHERE   sales_lead_id IS NULL
     AND     lead_id IS NULL
     AND     customer_id = Hr.object_id -- organization in the relationship
     AND     salesforce_id = res.resource_id)
     AND NOT EXISTS (
     SELECT  jrrm.group_id,resource_id
     FROM    jtf_rs_rep_managers jrrm ,
             jtf_rs_group_usages jrgu

     WHERE   jrgu.usage  in ('SALES', 'PRM')
     AND     jrgu.group_id = jrrm.group_id
     AND     jrrm.start_date_active  <= trunc(SYSDATE)
     AND     NVL(jrrm.end_date_active, SYSDATE) >= trunc(SYSDATE)
     AND     jrrm.parent_resource_id = jrrm.resource_id
     AND     jrrm.parent_resource_id = res.resource_id
     AND     jrrm.hierarchy_type = 'MGR_TO_MGR');


     CURSOR C_MANAGER_ACCESS IS
     SELECT
       PP.PARTY_ID,
       PP.VALUE_NUMBER,
       PP.OBJECT_VERSION_NUMBER
     FROM
       HZ_RELATIONSHIPS HR,
       HZ_PARTY_PREFERENCES PP,
       JTF_RS_RESOURCE_EXTNS res,
       PER_ALL_PEOPLE_F per
     WHERE
           PP.MODULE = 'SALES_BOOKMARKS'
     AND   PP.CATEGORY = 'BOOKMARKED_PARTY_RELATIONSHIP'
     AND   PP.PREFERENCE_CODE = 'PARTY_ID'
     AND   PP.VALUE_NUMBER = HR.PARTY_ID
     AND   TRUNC(SYSDATE) BETWEEN TRUNC(NVL(HR.START_DATE,SYSDATE)) AND TRUNC(NVL(HR.END_DATE,SYSDATE))
     AND   HR.STATUS = 'A'
     AND   HR.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
     AND   HR.OBJECT_TABLE_NAME  = 'HZ_PARTIES'
     AND   HR.DIRECTIONAL_FLAG = 'F'
     AND   TRUNC(NVL(per.effective_end_date, SYSDATE)) >= TRUNC(SYSDATE)
     AND   res.category = 'EMPLOYEE'
     AND   res.source_id = per.person_id
     AND   PP.PARTY_ID = per.PARTY_ID
     AND NOT EXISTS(
     SELECT 1
     FROM JTF_RS_REP_MANAGERS jrrm,
          JTF_RS_GROUP_USAGES jrgu,
          AS_ACCESSES_ALL aaa
     WHERE jrgu.usage IN ('SALES', 'PRM')
       AND jrgu.group_id = jrrm.group_id
       AND jrrm.hierarchy_type IN ('MGR_TO_MGR', 'MGR_TO_REP')
       AND jrrm.resource_id = aaa.salesforce_id
       AND TRUNC(jrrm.start_date_active) <= TRUNC(SYSDATE)
       AND TRUNC(NVL(jrrm.end_date_active, SYSDATE)) >= TRUNC(SYSDATE)
       AND aaa.sales_group_id = jrrm.group_id
       AND aaa.lead_id IS NULL
       AND aaa.sales_lead_id IS NULL
       AND aaa.customer_id = Hr.object_id -- organization in the relationship
       AND jrrm.parent_resource_id = res.resource_id
       AND jrrm.parent_resource_id <> jrrm.resource_id
     UNION ALL
     SELECT  1
     FROM    as_accesses_all
     WHERE   sales_lead_id IS NULL
     AND     lead_id IS NULL
     AND     customer_id = Hr.object_id -- organization in the relationship
     AND     salesforce_id = res.resource_id)
     AND EXISTS (
     SELECT  jrrm.group_id,resource_id
     FROM    jtf_rs_rep_managers jrrm ,
             jtf_rs_group_usages jrgu
     WHERE   jrgu.usage  in ('SALES', 'PRM')
     AND     jrgu.group_id = jrrm.group_id
     AND     jrrm.start_date_active  <= trunc(SYSDATE)
     AND     NVL(jrrm.end_date_active, SYSDATE) >= trunc(SYSDATE)
     AND     jrrm.parent_resource_id = jrrm.resource_id
     AND     jrrm.parent_resource_id = res.resource_id
     AND     jrrm.hierarchy_type = 'MGR_TO_MGR');

     l_cust_access VARCHAR2(1);

     BEGIN

     l_category			:= 'BOOKMARKED_PARTY_RELATIONSHIP';
     l_preference_code		:= 'PARTY_ID';

      set_err_var     := 'N';
      l_comit_size    := 10000;
      l_count         := 0;

      l_cust_access              := FND_PROFILE.VALUE('ASN_CUST_ACCESS');

      For C_INACTIVE_CONTACTS_REC IN C_INACTIVE_CONTACTS
      LOOP

        BEGIN

        HZ_PREFERENCE_PUB.REMOVE(
                P_PARTY_ID              =>      C_INACTIVE_CONTACTS_REC.PARTY_ID,
                P_CATEGORY              =>      l_category,
                P_PREFERENCE_CODE       =>      l_preference_code,
                --P_VALUE_VARCHAR2        =>      l_value_varchar2,
                P_VALUE_NUMBER          =>      C_INACTIVE_CONTACTS_REC.VALUE_NUMBER,
                --P_VALUE_DATE            =>      l_value_date,
                P_OBJECT_VERSION_NUMBER =>      C_INACTIVE_CONTACTS_REC.OBJECT_VERSION_NUMBER,
                X_RETURN_STATUS         =>      l_return_status,
                X_MSG_COUNT             =>      l_msg_count,
                X_MSG_DATA              =>      l_msg_data);

        l_count := l_count + 1;
        if(l_count >= l_comit_size) then
         commit;
         l_count := 0;
        end if;

        EXCEPTION
        WHEN fnd_api.g_exc_error
        THEN
          fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        WHEN fnd_api.g_exc_unexpected_error
        THEN
          fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        WHEN OTHERS
        THEN
          fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
        END;

      END LOOP;

      commit;

      IF l_cust_access = 'T' THEN -- 7650889 delete contacts based on security profile ASN: Customer Access Privilege
        l_count         := 0;

        For C_SALES_TEAM_ACCESS_REC IN C_SALES_TEAM_ACCESS
        loop

          BEGIN

          HZ_PREFERENCE_PUB.REMOVE(
           	  P_PARTY_ID			=>	C_SALES_TEAM_ACCESS_REC.PARTY_ID,
        	  P_CATEGORY			=>	l_category,
        	  P_PREFERENCE_CODE		=>	l_preference_code,
        	--P_VALUE_VARCHAR2		=>	l_value_varchar2,
        	  P_VALUE_NUMBER		=>	C_SALES_TEAM_ACCESS_REC.VALUE_NUMBER,
        	--P_VALUE_DATE			=>	l_value_date,
        	  P_OBJECT_VERSION_NUMBER	=>	C_SALES_TEAM_ACCESS_REC.OBJECT_VERSION_NUMBER,
        	  X_RETURN_STATUS		=>	l_return_status,
        	  X_MSG_COUNT			=>	l_msg_count,
        	  X_MSG_DATA			=>	l_msg_data);

          l_count := l_count + 1;
          if(l_count >= l_comit_size) then
           commit;
           l_count := 0;
          end if;


          EXCEPTION
           WHEN fnd_api.g_exc_error
          THEN
          fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
          WHEN fnd_api.g_exc_unexpected_error
          THEN
           fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
          WHEN OTHERS
          THEN
            fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
          END;

       END LOOP;

        commit;
        l_count := 0;

        For C_MANAGER_ACCESS_REC IN C_MANAGER_ACCESS
              loop

                BEGIN

                HZ_PREFERENCE_PUB.REMOVE(
                	P_PARTY_ID		=>	C_MANAGER_ACCESS_REC.PARTY_ID,
                	P_CATEGORY		=>	l_category,
                	P_PREFERENCE_CODE	=>	l_preference_code,
                	--P_VALUE_VARCHAR2	=>	l_value_varchar2,
                	P_VALUE_NUMBER		=>	C_MANAGER_ACCESS_REC.VALUE_NUMBER,
                	--P_VALUE_DATE		=>	l_value_date,
                	P_OBJECT_VERSION_NUMBER	=>	C_MANAGER_ACCESS_REC.OBJECT_VERSION_NUMBER,
                	X_RETURN_STATUS		=>	l_return_status,
                	X_MSG_COUNT		=>	l_msg_count,
                	X_MSG_DATA		=>	l_msg_data);

                  l_count := l_count + 1;
                  if(l_count >= l_comit_size) then
                  commit;
                  l_count := 0;
                  end if;


               EXCEPTION
                WHEN fnd_api.g_exc_error
                THEN
                  fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
                WHEN fnd_api.g_exc_unexpected_error
                THEN
                  fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
                WHEN OTHERS
                THEN
                  fnd_file.put_line(fnd_file.log, SQLCODE||':'||SQLERRM);
                END;

             END LOOP;

        commit;
      END IF;

      EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      WHEN fnd_api.g_exc_unexpected_error
      THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);
      WHEN OTHERS
      THEN
        fnd_file.put_line(fnd_file.log, sqlcode||':'||sqlerrm);


   END DELETE_NO_ACCESS_CONTACTS;

END ASP_CONTACT_PREF_SECURITY_PUB;

/
