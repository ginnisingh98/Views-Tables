--------------------------------------------------------
--  DDL for Package Body HZ_PURGE_GEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_PURGE_GEN" AS
PROCEDURE IDENTIFY_CANDIDATES(p_init_msg_list IN VARCHAR2 := FND_API.G_FALSE,
                         x_return_status  OUT NOCOPY  VARCHAR2,
                         x_msg_count OUT NOCOPY  NUMBER,
                         x_msg_data OUT NOCOPY   VARCHAR2,
                         check_flag boolean, con_prg boolean, regid_proc boolean) IS
appid number;
sql_count number;
total_parties number;
parties_count1 number;
parties_count2 number;
single_party number;


cursor repopulate is
select party_id from hz_purge_gt;


BEGIN


SAVEPOINT identify_candidates;
IF FND_API.to_Boolean(p_init_msg_list) THEN
FND_MSG_PUB.initialize;
END IF;
x_return_status := FND_API.G_RET_STS_SUCCESS;
delete from hz_application_trans_gt; 
open repopulate;
fetch repopulate into single_party;
close repopulate;
--delete and insert records into hz_purge_gt for an application
appid:=671;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 671, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from IBE_SH_SHP_LISTS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IBE_ORD_ONECLICK_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IBE_ORD_ONECLICK_ALL
 yy where yy.BILL_TO_PTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IBE_ORD_ONECLICK_ALL
 yy where yy.SHIP_TO_PTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from IBE_MSITE_PRTY_ACCSS xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from IBE_SH_SHP_LISTS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IBE_ORD_ONECLICK_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IBE_ORD_ONECLICK_ALL
 yy where yy.BILL_TO_PTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IBE_ORD_ONECLICK_ALL
 yy where yy.SHIP_TO_PTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from IBE_MSITE_PRTY_ACCSS xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=690;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 690, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from JTF_TASKS_B xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_TASKS_B xx where xx.SOURCE_OBJECT_ID =  temp.party_id 
 and (SOURCE_OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.NEW_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.OLD_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.NEW_SOURCE_OBJECT_ID =  temp.party_id 
 and (NEW_SOURCE_OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.OLD_SOURCE_OBJECT_ID =  temp.party_id 
 and (OLD_SOURCE_OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_TASK_CONTACTS xx where xx.CONTACT_ID =  temp.party_id 
 and (CONTACT_TYPE_CODE = 'CUST'))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_REFERENCES_B
 yy where yy.OBJECT_ID=xx.PARTY_SITE_ID
 and object_type_code in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTY_SITES' and rtrim(ltrim(upper(select_id))) = 'PARTY_SITE_ID')))

 or exists (select 'Y' from JTF_TASK_REFERENCES_B xx where xx.OBJECT_ID =  temp.party_id 
 and (OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASKS_B
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_AUDITS_B
 yy where yy.NEW_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_AUDITS_B
 yy where yy.OLD_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_PHONES
 yy where yy.PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_TASK_PHONES zz where zz.PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_NOTES_B
 yy where yy.SOURCE_OBJECT_ID=xx.PARTY_SITE_ID
 and source_object_code  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTY_SITES')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_NOTE_CONTEXTS
 yy where yy.NOTE_CONTEXT_TYPE_ID=xx.PARTY_SITE_ID
 and NOTE_CONTEXT_TYPE  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTY_SITES')))

 or exists (select 'Y' from JTF_NOTES_B xx where xx.SOURCE_OBJECT_ID =  temp.party_id 
 and (source_object_code  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTIES' )))

 or exists (select 'Y' from JTF_NOTE_CONTEXTS xx where xx.NOTE_CONTEXT_TYPE_ID =  temp.party_id 
 and (NOTE_CONTEXT_TYPE  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTIES')))

 or exists (select 'Y' from JTF_IH_INTERACTIONS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_RS_RESOURCE_EXTNS xx where xx.SOURCE_ID =  temp.party_id 
 and (category IN ( 'PARTY' , 'PARTNER')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_RS_RESOURCE_EXTNS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
 and category  =   'PARTNER'))

 or exists (select 'Y' from JTF_UM_APPROVERS xx where xx.ORG_PARTY_ID =  temp.party_id 
 and (ROWNUM < 2))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TERR_VALUES_ALL
 yy where yy.LOW_VALUE_CHAR_ID=xx.PARTY_SITE_ID
 and TERR_QUAL_ID in ( select TERR_QUAL_ID from JTF_TERR_QUAL_ALL where QUAL_USG_ID in (-1511, -1435, -1078, -1064, -1063, -1037, -1014, -1002,  -1001))))

 or exists (select 'Y' from JTF_TERR_VALUES_ALL xx where xx.LOW_VALUE_CHAR_ID =  temp.party_id 
 and (TERR_QUAL_ID in ( select TERR_QUAL_ID from JTF_TERR_QUAL_ALL where QUAL_USG_ID in (-1511, -1435, -1078, -1064, -1063, -1037, -1014, -1002,  -1001))))

 or exists (select 'Y' from JTF_TASK_ASSIGNMENTS xx where xx.RESOURCE_ID =  temp.party_id 
 and (RESOURCE_TYPE_CODE  IN (SELECT object_code FROM jtf_objects_b WHERE LTRIM(RTRIM(UPPER(from_table))) = 'HZ_PARTIES' AND RTRIM(LTRIM(UPPER(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_PERZ_QUERY_PARAM xx where xx.PARAMETER_VALUE =  to_char(temp.party_id) 
 and (parameter_name = 'CUSTOMER_ID' AND query_id IN (SELECT q.query_id FROM  jtf_perz_query q, jtf_perz_query_param p WHERE q.query_type= 'JTF_TASK' AND q.application_id = 690 AND  p.query_id = q.query_id AND p.parameter_name = 'CUSTOMER' AND p.parameter_value = 'NAME')))

 or exists (select 'Y' from JTF_PERZ_QUERY_PARAM xx where xx.PARAMETER_VALUE =  to_char(temp.party_id) 
 and (parameter_name = 'CUSTOMER_ID' AND query_id IN (SELECT q.query_id FROM  jtf_perz_query q, jtf_perz_query_param p WHERE q.query_type= 'JTF_TASK' AND q.application_id = 690 AND  p.query_id = q.query_id AND p.parameter_name = 'CUSTOMER' AND p.parameter_value = 'NUMBER')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_RS_RESOURCE_EXTNS
 yy where yy.SUPPORT_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from JTF_TTY_NAMED_ACCTS xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from JTF_TASKS_B xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_TASKS_B xx where xx.SOURCE_OBJECT_ID =  temp.party_id 
 and (SOURCE_OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.NEW_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.OLD_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.NEW_SOURCE_OBJECT_ID =  temp.party_id 
 and (NEW_SOURCE_OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_TASK_AUDITS_B xx where xx.OLD_SOURCE_OBJECT_ID =  temp.party_id 
 and (OLD_SOURCE_OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_TASK_CONTACTS xx where xx.CONTACT_ID =  temp.party_id 
 and (CONTACT_TYPE_CODE = 'CUST'))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_REFERENCES_B
 yy where yy.OBJECT_ID=xx.PARTY_SITE_ID
 and object_type_code in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTY_SITES' and rtrim(ltrim(upper(select_id))) = 'PARTY_SITE_ID')))

 or exists (select 'Y' from JTF_TASK_REFERENCES_B xx where xx.OBJECT_ID =  temp.party_id 
 and (OBJECT_TYPE_CODE in (select object_code from jtf_objects_b where ltrim(rtrim(upper(from_table))) = 'HZ_PARTIES' and rtrim(ltrim(upper(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASKS_B
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_AUDITS_B
 yy where yy.NEW_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_AUDITS_B
 yy where yy.OLD_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TASK_PHONES
 yy where yy.PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_TASK_PHONES zz where zz.PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from JTF_RS_RESOURCE_EXTNS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID and category in ('PARTY', 'PARTNER' ))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_NOTES_B
 yy where yy.SOURCE_OBJECT_ID=xx.PARTY_SITE_ID
 and source_object_code  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTY_SITES')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_NOTE_CONTEXTS
 yy where yy.NOTE_CONTEXT_TYPE_ID=xx.PARTY_SITE_ID
 and NOTE_CONTEXT_TYPE  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTY_SITES')))

 or exists (select 'Y' from JTF_NOTES_B xx where xx.SOURCE_OBJECT_ID =  temp.party_id 
 and (source_object_code  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTIES' )))

 or exists (select 'Y' from JTF_NOTE_CONTEXTS xx where xx.NOTE_CONTEXT_TYPE_ID =  temp.party_id 
 and (NOTE_CONTEXT_TYPE  IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'NOTES' and ojt.from_table ='HZ_PARTIES')))

 or exists (select 'Y' from JTF_IH_INTERACTIONS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from JTF_RS_RESOURCE_EXTNS xx where xx.SOURCE_ID =  temp.party_id 
 and (category IN ( 'PARTY' , 'PARTNER')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_RS_RESOURCE_EXTNS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
 and category  =   'PARTNER'))

 or exists (select 'Y' from JTF_UM_APPROVERS xx where xx.ORG_PARTY_ID =  temp.party_id 
 and (ROWNUM < 2))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_TERR_VALUES_ALL
 yy where yy.LOW_VALUE_CHAR_ID=xx.PARTY_SITE_ID
 and TERR_QUAL_ID in ( select TERR_QUAL_ID from JTF_TERR_QUAL_ALL where QUAL_USG_ID in (-1511, -1435, -1078, -1064, -1063, -1037, -1014, -1002,  -1001))))

 or exists (select 'Y' from JTF_TERR_VALUES_ALL xx where xx.LOW_VALUE_CHAR_ID =  temp.party_id 
 and (TERR_QUAL_ID in ( select TERR_QUAL_ID from JTF_TERR_QUAL_ALL where QUAL_USG_ID in (-1511, -1435, -1078, -1064, -1063, -1037, -1014, -1002,  -1001))))

 or exists (select 'Y' from JTF_TASK_ASSIGNMENTS xx where xx.RESOURCE_ID =  temp.party_id 
 and (RESOURCE_TYPE_CODE  IN (SELECT object_code FROM jtf_objects_b WHERE LTRIM(RTRIM(UPPER(from_table))) = 'HZ_PARTIES' AND RTRIM(LTRIM(UPPER(select_id))) = 'PARTY_ID')))

 or exists (select 'Y' from JTF_PERZ_QUERY_PARAM xx where xx.PARAMETER_VALUE =  to_char(temp.party_id) 
 and (parameter_name = 'CUSTOMER_ID' AND query_id IN (SELECT q.query_id FROM  jtf_perz_query q, jtf_perz_query_param p WHERE q.query_type= 'JTF_TASK' AND q.application_id = 690 AND  p.query_id = q.query_id AND p.parameter_name = 'CUSTOMER' AND p.parameter_value = 'NAME')))

 or exists (select 'Y' from JTF_PERZ_QUERY_PARAM xx where xx.PARAMETER_VALUE =  to_char(temp.party_id) 
 and (parameter_name = 'CUSTOMER_ID' AND query_id IN (SELECT q.query_id FROM  jtf_perz_query q, jtf_perz_query_param p WHERE q.query_type= 'JTF_TASK' AND q.application_id = 690 AND  p.query_id = q.query_id AND p.parameter_name = 'CUSTOMER' AND p.parameter_value = 'NUMBER')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from JTF_RS_RESOURCE_EXTNS
 yy where yy.SUPPORT_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from JTF_TTY_NAMED_ACCTS xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=510;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 510, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OKC_K_PARTY_ROLES_B xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from OKC_CONTACTS xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_CONTACTS')))

 or exists (select 'Y' from OKC_RULES_B xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from OKC_RULES_B xx where xx.OBJECT2_ID1 =  to_char(temp.party_id) 
 and (jtot_object2_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from OKC_RULES_B xx where xx.OBJECT3_ID1 =  to_char(temp.party_id) 
 and (jtot_object3_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_RULES_B
 yy where yy.OBJECT1_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_RULES_B
 yy where yy.OBJECT2_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object2_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_RULES_B
 yy where yy.OBJECT3_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object3_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_RULES_B zz where zz.OBJECT1_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_RULES_B zz where zz.OBJECT2_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object2_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_RULES_B zz where zz.OBJECT3_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object3_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))))

 or exists (select 'Y' from OKC_K_ITEMS xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_K_ITEMS
 yy where yy.OBJECT1_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_K_ITEMS zz where zz.OBJECT1_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OKC_K_PARTY_ROLES_B xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from OKC_CONTACTS xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_CONTACTS')))

 or exists (select 'Y' from OKC_RULES_B xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from OKC_RULES_B xx where xx.OBJECT2_ID1 =  to_char(temp.party_id) 
 and (jtot_object2_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from OKC_RULES_B xx where xx.OBJECT3_ID1 =  to_char(temp.party_id) 
 and (jtot_object3_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_RULES_B
 yy where yy.OBJECT1_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_RULES_B
 yy where yy.OBJECT2_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object2_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_RULES_B
 yy where yy.OBJECT3_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object3_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_RULES_B zz where zz.OBJECT1_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_RULES_B zz where zz.OBJECT2_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object2_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_RULES_B zz where zz.OBJECT3_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object3_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))))

 or exists (select 'Y' from OKC_K_ITEMS xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_PARTY')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKC_K_ITEMS
 yy where yy.OBJECT1_ID1=to_char(xx.PARTY_SITE_ID)
 and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKC_K_ITEMS zz where zz.OBJECT1_ID1=to_char(yy.PARTY_SITE_USE_ID) and jtot_object1_code IN (SELECT ojt.object_code FROM jtf_objects_b ojt  ,jtf_object_usages oue WHERE ojt.object_code = oue.object_code AND oue.object_user_code = 'OKX_P_SITE_USE'))));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OZF_REQUEST_HEADERS_ALL_B xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CUST_TRD_PRFLS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CLAIMS_ALL xx where xx.BROKER_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CLAIMS_ALL xx where xx.CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_ACT_BUDGETS xx where xx.BUDGET_SOURCE_ID =  temp.party_id 
 and (BUDGET_SOURCE_TYPE='PTNR'))

 or exists (select 'Y' from OZF_ACT_BUDGETS xx where xx.VENDOR_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_OFFERS xx where xx.BUYING_GROUP_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CODE_CONVERSIONS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_RESALE_BATCHES_ALL xx where xx.PARTNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_REQUEST_HEADERS_ALL_B xx where xx.PARTNER_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OZF_REQUEST_HEADERS_ALL_B xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CUST_TRD_PRFLS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CLAIMS_ALL xx where xx.BROKER_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CLAIMS_ALL xx where xx.CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_ACT_BUDGETS xx where xx.BUDGET_SOURCE_ID =  temp.party_id 
 and (BUDGET_SOURCE_TYPE='PTNR'))

 or exists (select 'Y' from OZF_ACT_BUDGETS xx where xx.VENDOR_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_OFFERS xx where xx.BUYING_GROUP_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_CODE_CONVERSIONS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_RESALE_BATCHES_ALL xx where xx.PARTNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OZF_REQUEST_HEADERS_ALL_B xx where xx.PARTNER_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=206;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 206, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from LNS_LOAN_HEADERS_ALL xx where xx.PRIMARY_BORROWER_ID =  temp.party_id 
 )

 or exists (select 'Y' from LNS_PARTICIPANTS xx where xx.HZ_PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from LNS_LOAN_HEADERS_ALL xx where xx.PRIMARY_BORROWER_ID =  temp.party_id 
 )

 or exists (select 'Y' from LNS_PARTICIPANTS xx where xx.HZ_PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=204;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 204, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from XLE_ENTITY_PROFILES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from XLE_ETB_PROFILES xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from XLE_ENTITY_PROFILES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from XLE_ETB_PROFILES xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=454;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 454, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from ISC_BOOK_SUM2_PDUE_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from ISC_BOOK_SUM2_PDUE2_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from ISC_BOOK_SUM2_BKORD_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from ISC_BOOK_SUM2_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from ISC_FS_TASKS_F
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from ISC_FS_TASKS_F xx where xx.CUSTOMER_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from ISC_BOOK_SUM2_PDUE_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from ISC_BOOK_SUM2_PDUE2_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from ISC_BOOK_SUM2_BKORD_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from ISC_BOOK_SUM2_F xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from ISC_FS_TASKS_F
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from ISC_FS_TASKS_F xx where xx.CUSTOMER_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=542;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 542, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from CSI_ITEM_INSTANCES xx where xx.OWNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CSI_T_TXN_LINE_DETAILS
 yy where yy.LOCATION_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CSI_T_TXN_LINE_DETAILS
 yy where yy.INSTALL_LOCATION_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from CSI_I_PARTIES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.SHIP_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_PARTY_DETAILS xx where xx.PARTY_SOURCE_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.SHIP_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.BILL_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.TECHNICAL_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.SERVICE_ADMIN_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.BILL_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.SERVICE_ADMIN_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.TECHNICAL_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CSI_SYSTEMS_B
 yy where yy.INSTALL_SITE_USE_ID=xx.PARTY_SITE_ID
));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from CSI_ITEM_INSTANCES xx where xx.OWNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CSI_T_TXN_LINE_DETAILS
 yy where yy.LOCATION_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CSI_T_TXN_LINE_DETAILS
 yy where yy.INSTALL_LOCATION_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from CSI_I_PARTIES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.SHIP_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_PARTY_DETAILS xx where xx.PARTY_SOURCE_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.SHIP_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.BILL_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.TECHNICAL_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_SYSTEMS_B xx where xx.SERVICE_ADMIN_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.BILL_TO_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.SERVICE_ADMIN_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSI_T_TXN_SYSTEMS xx where xx.TECHNICAL_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CSI_SYSTEMS_B
 yy where yy.INSTALL_SITE_USE_ID=xx.PARTY_SITE_ID
));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=515;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 515, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OKS_BILLING_PROFILES_B xx where xx.OWNED_PARTY_ID1 =  to_char(temp.party_id) 
 )

 or exists (select 'Y' from OKS_K_DEFAULTS xx where xx.SEGMENT_ID1 =  to_char(temp.party_id) 
 and (JTOT_OBJECT_CODE = 'OKX_PARTY'))

 or exists (select 'Y' from OKS_SERV_AVAIL_EXCEPTS xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (JTOT_OBJECT1_CODE = 'OKX_PARTY'));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OKS_BILLING_PROFILES_B xx where xx.OWNED_PARTY_ID1 =  to_char(temp.party_id) 
 )

 or exists (select 'Y' from OKS_K_DEFAULTS xx where xx.SEGMENT_ID1 =  to_char(temp.party_id) 
 and (JTOT_OBJECT_CODE = 'OKX_PARTY'))

 or exists (select 'Y' from OKS_SERV_AVAIL_EXCEPTS xx where xx.OBJECT1_ID1 =  to_char(temp.party_id) 
 and (JTOT_OBJECT1_CODE = 'OKX_PARTY'));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=275;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 275, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from PA_CI_ACTIONS xx where xx.ASSIGNED_TO =  temp.party_id 
 )

 or exists (select 'Y' from PA_CONTROL_ITEMS xx where xx.OWNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_PERCENT_COMPLETES xx where xx.PUBLISHED_BY_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_PROJECT_REQUESTS xx where xx.CUST_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_PROJECT_SETS_B xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_RESOURCE_TXN_ATTRIBUTES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_CI_IMPACTS xx where xx.IMPLEMENTED_BY =  temp.party_id 
 )

 or exists (select 'Y' from PA_CONTROL_ITEMS xx where xx.LAST_MODIFIED_BY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_CONTROL_ITEMS xx where xx.CLOSED_BY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from PA_CI_ACTIONS xx where xx.ASSIGNED_TO =  temp.party_id 
 )

 or exists (select 'Y' from PA_CONTROL_ITEMS xx where xx.OWNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_PERCENT_COMPLETES xx where xx.PUBLISHED_BY_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_PROJECT_REQUESTS xx where xx.CUST_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_PROJECT_SETS_B xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_RESOURCE_TXN_ATTRIBUTES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_CI_IMPACTS xx where xx.IMPLEMENTED_BY =  temp.party_id 
 )

 or exists (select 'Y' from PA_CONTROL_ITEMS xx where xx.LAST_MODIFIED_BY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PA_CONTROL_ITEMS xx where xx.CLOSED_BY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=665;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 665, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from WSH_CARRIERS xx where xx.CARRIER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from WSH_CARRIER_SITES
 yy where yy.CARRIER_SITE_ID=xx.PARTY_SITE_ID
));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from WSH_CARRIERS xx where xx.CARRIER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from WSH_CARRIER_SITES
 yy where yy.CARRIER_SITE_ID=xx.PARTY_SITE_ID
));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=451;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 451, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OPI_DBI_COGS_F xx where xx.CUSTOMER_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OPI_DBI_COGS_F xx where xx.CUSTOMER_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=666;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 666, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from IBW_SITE_VISITS xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from IBW_SITE_VISITS xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=691;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 691, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from PV_GE_PTNR_RESPS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PARTNER_PROFILES xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_ENTY_ATTR_VALUES xx where xx.ENTITY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_LEAD_ASSIGNMENTS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_ASSIGNMENT_LOGS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_SEARCH_ATTR_VALUES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_LEAD_PSS_LINES xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_GE_PARTY_NOTIFICATIONS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PG_ENRL_REQUESTS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PG_MEMBERSHIPS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PARTNER_PROFILES xx where xx.PARTNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_REFERRALS_B xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_REFERRALS_B xx where xx.CUSTOMER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from PV_REFERRALS_B
 yy where yy.CUSTOMER_PARTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from PV_REFERRALS_B xx where xx.CUSTOMER_CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_LEAD_ASSIGNMENTS xx where xx.RELATED_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PARTNER_ACCESSES xx where xx.PARTNER_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from PV_GE_PTNR_RESPS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PARTNER_PROFILES xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_ENTY_ATTR_VALUES xx where xx.ENTITY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_LEAD_ASSIGNMENTS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_ASSIGNMENT_LOGS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_SEARCH_ATTR_VALUES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_LEAD_PSS_LINES xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_GE_PARTY_NOTIFICATIONS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PG_ENRL_REQUESTS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PG_MEMBERSHIPS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PARTNER_PROFILES xx where xx.PARTNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_REFERRALS_B xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_REFERRALS_B xx where xx.CUSTOMER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from PV_REFERRALS_B
 yy where yy.CUSTOMER_PARTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from PV_REFERRALS_B zz where zz.CUSTOMER_ORG_CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from PV_REFERRALS_B xx where xx.CUSTOMER_CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_LEAD_ASSIGNMENTS xx where xx.RELATED_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from PV_PARTNER_ACCESSES xx where xx.PARTNER_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=777;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 777, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OKE_K_FUNDING_SOURCES_PM_HV xx where xx.K_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OKE_K_FUNDING_SOURCES xx where xx.K_PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OKE_K_FUNDING_SOURCES_PM_HV xx where xx.K_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from OKE_K_FUNDING_SOURCES xx where xx.K_PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=867;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 867, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from AHL_DOCUMENTS_B xx where xx.SOURCE_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AHL_SUPPLIER_DOCUMENTS xx where xx.SUPPLIER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AHL_RECIPIENT_DOCUMENTS xx where xx.RECIPIENT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AHL_DOC_REVISIONS_B xx where xx.APPROVED_BY_PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from AHL_DOCUMENTS_B xx where xx.SOURCE_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AHL_SUPPLIER_DOCUMENTS xx where xx.SUPPLIER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AHL_RECIPIENT_DOCUMENTS xx where xx.RECIPIENT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AHL_DOC_REVISIONS_B xx where xx.APPROVED_BY_PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=222;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 222, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from HZ_ORGANIZATION_PROFILES xx where xx.DISPLAYED_DUNS_PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_CUST_ACCOUNTS xx where xx.SELLING_PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_CUSTOMER_PROFILES xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_CUST_ACCOUNTS xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from HZ_CUST_ACCT_SITES_ALL
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID
 and nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_RELATIONSHIPS xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F'))

 or exists (select 'Y' from HZ_RELATIONSHIPS xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F'));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from HZ_ORGANIZATION_PROFILES xx where xx.DISPLAYED_DUNS_PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_CUST_ACCOUNTS xx where xx.SELLING_PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_CUSTOMER_PROFILES xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_CUST_ACCOUNTS xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from HZ_CUST_ACCT_SITES_ALL
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID
 and nvl(STATUS, 'A') in ('A','I')))

 or exists (select 'Y' from HZ_RELATIONSHIPS xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F'))

 or exists (select 'Y' from HZ_RELATIONSHIPS xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F'));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from AMS_PARTY_SOURCES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_PARTNERS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_PARTNERS xx where xx.PREFERRED_VAD_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_PARTNERS xx where xx.PRIMARY_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_EVENT_REGISTRATIONS xx where xx.REGISTRANT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_EVENT_REGISTRATIONS xx where xx.ATTENDANT_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_CHANNELS_B xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_IBA_POSTINGS_B xx where xx.CUSTOMER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_IBA_POSTINGS_B xx where xx.AFFILIATE_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_COMPETITOR_PRODUCTS_B xx where xx.COMPETITOR_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_RESOURCES xx where xx.RESOURCE_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_TCOP_CONTACT_SUMMARY xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_VENUES_B xx where xx.PARTY_ID =  temp.party_id 
 and (OBJECT_TYPE='VENU'))

 or exists (select 'Y' from AMS_IMP_SOURCE_LINES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_LIST_ENTRIES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_LIST_ENTRIES xx where xx.PARENT_PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from AMS_PARTY_SOURCES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_PARTNERS xx where xx.PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_PARTNERS xx where xx.PREFERRED_VAD_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_PARTNERS xx where xx.PRIMARY_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_EVENT_REGISTRATIONS xx where xx.REGISTRANT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_EVENT_REGISTRATIONS xx where xx.ATTENDANT_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_CHANNELS_B xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_IBA_POSTINGS_B xx where xx.CUSTOMER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_IBA_POSTINGS_B xx where xx.AFFILIATE_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_COMPETITOR_PRODUCTS_B xx where xx.COMPETITOR_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_ACT_RESOURCES xx where xx.RESOURCE_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_TCOP_CONTACT_SUMMARY xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_VENUES_B xx where xx.PARTY_ID =  temp.party_id 
 and (OBJECT_TYPE='VENU'))

 or exists (select 'Y' from AMS_IMP_SOURCE_LINES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_LIST_ENTRIES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AMS_LIST_ENTRIES xx where xx.PARENT_PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=694;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 694, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from PRP_PROPOSALS xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from PRP_PROPOSALS xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from CS_INCIDENTS_ALL_B xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from CS_HZ_SR_CONTACT_POINTS xx where xx.PARTY_ID =  temp.party_id 
 and (CONTACT_TYPE <> 'EMPLOYEE'))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CS_ESTIMATE_DETAILS
 yy where yy.INVOICE_TO_ORG_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CS_ESTIMATE_DETAILS
 yy where yy.SHIP_TO_ORG_ID=xx.PARTY_SITE_ID
));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from CS_INCIDENTS_ALL_B xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from CS_HZ_SR_CONTACT_POINTS xx where xx.PARTY_ID =  temp.party_id 
 and (CONTACT_TYPE <> 'EMPLOYEE'))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CS_ESTIMATE_DETAILS
 yy where yy.INVOICE_TO_ORG_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from CS_ESTIMATE_DETAILS
 yy where yy.SHIP_TO_ORG_ID=xx.PARTY_SITE_ID
));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=660;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 660, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OE_PRICE_ADJ_ATTRIBS xx where xx.PRICING_ATTR_VALUE_FROM =  to_char(temp.party_id) 
 and (pricing_context = 'ASOPARTYINFO'  AND pricing_attribute = 'QUALIFIER_ATTRIBUTE1'  OR pricing_context = 'CUSTOMER' AND pricing_attribute ='QUALIFIER_ATTRIBUTE16'  OR pricing_context = 'CUSTOMER_GROUP' AND pricing_attribute = 'QUALIFIER_ATTRIBUTE3'  OR pricing_context = 'PARTY' AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OE_PRICE_ADJ_ATTRIBS
 yy where yy.PRICING_ATTR_VALUE_FROM=to_char(xx.PARTY_SITE_ID)
 and pricing_context = 'ASOPARTYINFO'  AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')  OR pricing_context = 'CUSTOMER' AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18')));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OE_PRICE_ADJ_ATTRIBS xx where xx.PRICING_ATTR_VALUE_FROM =  to_char(temp.party_id) 
 and (pricing_context = 'ASOPARTYINFO'  AND pricing_attribute = 'QUALIFIER_ATTRIBUTE1'  OR pricing_context = 'CUSTOMER' AND pricing_attribute ='QUALIFIER_ATTRIBUTE16'  OR pricing_context = 'CUSTOMER_GROUP' AND pricing_attribute = 'QUALIFIER_ATTRIBUTE3'  OR pricing_context = 'PARTY' AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2')))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OE_PRICE_ADJ_ATTRIBS
 yy where yy.PRICING_ATTR_VALUE_FROM=to_char(xx.PARTY_SITE_ID)
 and pricing_context = 'ASOPARTYINFO'  AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')  OR pricing_context = 'CUSTOMER' AND pricing_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18')));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=661;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 661, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from QP_QUALIFIERS xx where xx.QUALIFIER_ATTR_VALUE =  to_char(temp.party_id) 
 and ((qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE1'  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute ='QUALIFIER_ATTRIBUTE16'  OR qualifier_context = 'CUSTOMER_GROUP' AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE3'  OR qualifier_context = 'PARTY' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2'))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from QP_QUALIFIERS
 yy where yy.QUALIFIER_ATTR_VALUE=to_char(xx.PARTY_SITE_ID)
 and (qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18'))));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from QP_QUALIFIERS xx where xx.QUALIFIER_ATTR_VALUE =  to_char(temp.party_id) 
 and ((qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE1'  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute ='QUALIFIER_ATTRIBUTE16'  OR qualifier_context = 'CUSTOMER_GROUP' AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE3'  OR qualifier_context = 'PARTY' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2'))))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from QP_QUALIFIERS
 yy where yy.QUALIFIER_ATTR_VALUE=to_char(xx.PARTY_SITE_ID)
 and (qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18'))));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=8405;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8405, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from IGP_AC_ACCOUNTS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.SCHOOL_PARTY_ID =  temp.party_id 
 and (nvl(STATUS,'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_ACAD_HIST
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))
 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_ACAD_HIST
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))

 or exists (select 'Y' from HZ_EMPLOYMENT_HISTORY
 xx where xx.EMPLOYED_BY_PARTY_ID =  temp.party_id 
 and (nvl(STATUS,'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_EMP_DTL
 yy where yy.EMPLOYMENT_HISTORY_ID=xx.EMPLOYMENT_HISTORY_ID
))
 or exists (select 'Y' from HZ_EMPLOYMENT_HISTORY
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_EMP_DTL
 yy where yy.EMPLOYMENT_HISTORY_ID=xx.EMPLOYMENT_HISTORY_ID
))

 or exists (select 'Y' from HZ_PERSON_INTEREST
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_EXTRACURR_ACT
 yy where yy.PERSON_INTEREST_ID=xx.PERSON_INTEREST_ID
))

 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.SCHOOL_PARTY_ID =  temp.party_id 
 and (nvl(STATUS,'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_TRANSCRIPT
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))
 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_TRANSCRIPT
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))

 or exists (select 'Y' from IGS_PE_HZ_PARTIES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_CREDITS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_INV_INT_ALL xx where xx.PERSON_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_PARTY_VENDRS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_PP_STD_ATTRS xx where xx.PERSON_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_P_SA_NOTES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_REFUNDS xx where xx.PERSON_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from IGP_AC_ACCOUNTS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.SCHOOL_PARTY_ID =  temp.party_id 
 and (nvl(STATUS,'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_ACAD_HIST
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))
 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_ACAD_HIST
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))

 or exists (select 'Y' from HZ_EMPLOYMENT_HISTORY
 xx where xx.EMPLOYED_BY_PARTY_ID =  temp.party_id 
 and (nvl(STATUS,'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_EMP_DTL
 yy where yy.EMPLOYMENT_HISTORY_ID=xx.EMPLOYMENT_HISTORY_ID
))
 or exists (select 'Y' from HZ_EMPLOYMENT_HISTORY
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_EMP_DTL
 yy where yy.EMPLOYMENT_HISTORY_ID=xx.EMPLOYMENT_HISTORY_ID
))

 or exists (select 'Y' from HZ_PERSON_INTEREST
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_HZ_EXTRACURR_ACT
 yy where yy.PERSON_INTEREST_ID=xx.PERSON_INTEREST_ID
))

 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.SCHOOL_PARTY_ID =  temp.party_id 
 and (nvl(STATUS,'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_TRANSCRIPT
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))
 or exists (select 'Y' from HZ_EDUCATION
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IGS_AD_TRANSCRIPT
 yy where yy.EDUCATION_ID=xx.EDUCATION_ID
))

 or exists (select 'Y' from IGS_PE_HZ_PARTIES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_CREDITS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_INV_INT_ALL xx where xx.PERSON_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_PARTY_VENDRS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_PP_STD_ATTRS xx where xx.PERSON_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_P_SA_NOTES xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from IGS_FI_REFUNDS xx where xx.PERSON_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from ASO_QUOTE_HEADERS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from ASO_SHIPMENTS
 yy where yy.SHIP_TO_PARTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from ASO_QUOTE_HEADERS_ALL xx where xx.CUST_PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from ASO_QUOTE_HEADERS_ALL xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from ASO_SHIPMENTS
 yy where yy.SHIP_TO_PARTY_SITE_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from ASO_QUOTE_HEADERS_ALL xx where xx.CUST_PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from PON_BIDDING_PARTIES xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BID_ITEM_PRICES xx where xx.BID_TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_AUCTION_HEADERS_ALL xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_AUCTION_HEADERS_ALL xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_AUCTION_EVENTS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BIDDERS_LISTS xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BIDDERS_LISTS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_ATTRIBUTE_LISTS xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_ATTRIBUTE_LISTS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BID_HEADERS xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BID_HEADERS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_TE_RECIPIENTS xx where xx.TO_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from PON_BIDDING_PARTIES xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BID_ITEM_PRICES xx where xx.BID_TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_AUCTION_HEADERS_ALL xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_AUCTION_HEADERS_ALL xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_AUCTION_EVENTS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BIDDERS_LISTS xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BIDDERS_LISTS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_ATTRIBUTE_LISTS xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_ATTRIBUTE_LISTS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BID_HEADERS xx where xx.TRADING_PARTNER_CONTACT_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_BID_HEADERS xx where xx.TRADING_PARTNER_ID =  temp.party_id 
 )

 or exists (select 'Y' from PON_TE_RECIPIENTS xx where xx.TO_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=695;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 695, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from IEX_DELINQUENCIES_ALL xx where xx.PARTY_CUST_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IEX_CASE_CONTACTS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from IEX_DELINQUENCIES_ALL xx where xx.PARTY_CUST_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from IEX_CASE_CONTACTS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from OKL_TRX_AR_INVOICES_B xx where xx.IBT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OKL_CNSLD_AR_HDRS_B xx where xx.IBT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OKL_TXL_RCPT_APPS_B xx where xx.ILE_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKL_RELOCATE_ASSETS_B
 yy where yy.PAC_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKL_RELOCATE_ASSETS_B zz where zz.PAC_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKL_RELOCATE_ASSETS_B zz where zz.IST_ID = yy.PARTY_SITE_USE_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKL_RELOCATE_ASSETS_B zz where zz.IST_ID = yy.PARTY_SITE_USE_ID )));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from OKL_TRX_AR_INVOICES_B xx where xx.IBT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OKL_CNSLD_AR_HDRS_B xx where xx.IBT_ID =  temp.party_id 
 )

 or exists (select 'Y' from OKL_TXL_RCPT_APPS_B xx where xx.ILE_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from OKL_RELOCATE_ASSETS_B
 yy where yy.PAC_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKL_RELOCATE_ASSETS_B zz where zz.PAC_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKL_RELOCATE_ASSETS_B zz where zz.IST_ID = yy.PARTY_SITE_USE_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_PARTY_SITE_USES
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from OKL_RELOCATE_ASSETS_B zz where zz.IST_ID = yy.PARTY_SITE_USE_ID )));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from AS_SALES_CREDITS_DENORM xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_CREDITS_DENORM
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_LEAD_CONTACTS_ALL
 yy where yy.PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_CURRENT_ENVIRONMENT
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEADS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_LEADS xx where xx.PRIMARY_CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_SALES_LEADS xx where xx.PRIMARY_CNT_PERSON_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEADS
 yy where yy.PRIMARY_CONTACT_PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEADS zz where zz.PRIMARY_CONTACT_PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from AS_AP_ACCOUNT_PLANS xx where xx.CUST_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEAD_CONTACTS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEAD_CONTACTS
 yy where yy.PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from AS_SALES_LEAD_CONTACTS xx where xx.CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_ACCESSES_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_ACCESSES_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_ACCESSES_ALL xx where xx.PARTNER_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_ACCESSES_ALL xx where xx.PARTNER_CONT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_INTERESTS_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_INTERESTS_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_ACCESSES_ALL
 yy where yy.PARTNER_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_LEADS xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_SALES_LEAD_CONTACTS xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEADS_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_LEADS_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_LEADS_ALL xx where xx.CLOSE_COMPETITOR_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEADS_ALL xx where xx.INCUMBENT_PARTNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEAD_COMPETITORS xx where xx.COMPETITOR_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from AS_LEAD_CONTACTS_ALL xx where xx.CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEAD_CONTACTS_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_LEAD_CONTACTS_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_CREDITS xx where xx.PARTNER_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_CREDITS
 yy where yy.PARTNER_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_CREDITS_DENORM xx where xx.PARTNER_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_CREDITS_DENORM
 yy where yy.PARTNER_ADDRESS_ID=xx.PARTY_SITE_ID
));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from AS_SALES_CREDITS_DENORM xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_CREDITS_DENORM
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_LEAD_CONTACTS_ALL
 yy where yy.PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_CURRENT_ENVIRONMENT
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEADS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_LEADS xx where xx.PRIMARY_CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_SALES_LEADS xx where xx.PRIMARY_CNT_PERSON_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEADS
 yy where yy.PRIMARY_CONTACT_PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEADS zz where zz.PRIMARY_CONTACT_PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from AS_AP_ACCOUNT_PLANS xx where xx.CUST_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEAD_CONTACTS
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_CONTACT_POINTS
 xx where xx.OWNER_TABLE_ID =  temp.party_id 
 and (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_LEAD_CONTACTS
 yy where yy.PHONE_ID=xx.CONTACT_POINT_ID
))
 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_CONTACT_POINTS
 yy where yy.OWNER_TABLE_ID=xx.PARTY_SITE_ID 
 and OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_SALES_LEAD_CONTACTS zz where zz.PHONE_ID = yy.CONTACT_POINT_ID )))

 or exists (select 'Y' from AS_SALES_LEAD_CONTACTS xx where xx.CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_ACCESSES_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_ACCESSES_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_ACCESSES_ALL xx where xx.PARTNER_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_ACCESSES_ALL xx where xx.PARTNER_CONT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_INTERESTS_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_INTERESTS_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_INTERESTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_ACCESSES_ALL
 yy where yy.PARTNER_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_LEADS xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_SALES_LEAD_CONTACTS xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEADS_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_LEADS_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_LEADS_ALL xx where xx.CLOSE_COMPETITOR_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEADS_ALL xx where xx.INCUMBENT_PARTNER_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEAD_COMPETITORS xx where xx.COMPETITOR_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_SITE_ID=xx.PARTY_SITE_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.OBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))
 or exists (select 'Y' from HZ_RELATIONSHIPS
 xx where xx.SUBJECT_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I') AND subject_table_name = 'HZ_PARTIES'  AND object_table_name = 'HZ_PARTIES'
AND directional_flag = 'F')
 and exists 
 (select 'Y' from HZ_ORG_CONTACTS
 yy where yy.PARTY_RELATIONSHIP_ID=xx.RELATIONSHIP_ID 
 and nvl(STATUS, 'A') in ('A','I')
 and exists 
 (select 'Y' from AS_LEAD_CONTACTS_ALL zz where zz.CONTACT_ID = yy.ORG_CONTACT_ID )))

 or exists (select 'Y' from AS_LEAD_CONTACTS_ALL xx where xx.CONTACT_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from AS_LEAD_CONTACTS_ALL xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_LEAD_CONTACTS_ALL
 yy where yy.ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_CREDITS xx where xx.PARTNER_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_CREDITS
 yy where yy.PARTNER_ADDRESS_ID=xx.PARTY_SITE_ID
))

 or exists (select 'Y' from AS_SALES_CREDITS_DENORM xx where xx.PARTNER_CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from HZ_PARTY_SITES
 xx where xx.PARTY_ID =  temp.party_id 
 and (nvl(STATUS, 'A') in ('A','I'))
 and exists
(select 'Y' from AS_SALES_CREDITS_DENORM
 yy where yy.PARTNER_ADDRESS_ID=xx.PARTY_SITE_ID
));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=0;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 0, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from FND_USER xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from FND_USER xx where xx.PERSON_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from UMX_REG_REQUESTS xx where xx.REQUESTED_FOR_PARTY_ID =  temp.party_id 
 and (ROWNUM < 2));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from FND_USER xx where xx.CUSTOMER_ID =  temp.party_id 
 )

 or exists (select 'Y' from FND_USER xx where xx.PERSON_PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from UMX_REG_REQUESTS xx where xx.REQUESTED_FOR_PARTY_ID =  temp.party_id 
 and (ROWNUM < 2));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from IGW_PROP_PERSONS_TCA_V xx where xx.PERSON_PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from IGW_PROP_PERSONS_TCA_V xx where xx.PERSON_PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=511;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 511, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from CSC_CUSTOMERS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSC_CUSTOMIZED_PLANS xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from CSC_CUSTOMERS xx where xx.PARTY_ID =  temp.party_id 
 )

 or exists (select 'Y' from CSC_CUSTOMIZED_PLANS xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--delete and insert records into hz_purge_gt for an application
appid:=800;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 800, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from PER_ALL_PEOPLE_F xx where xx.PARTY_ID =  temp.party_id 
 and (effective_end_date = to_date('12/31/4712','MM/DD/YYYY')));
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from PER_ALL_PEOPLE_F xx where xx.PARTY_ID =  temp.party_id 
 and (effective_end_date = to_date('12/31/4712','MM/DD/YYYY')));
end if;


--delete and insert records into hz_purge_gt for an application
appid:=174;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 174, temp.party_id from hz_purge_gt temp where 


 exists (select 'Y' from ECX_TP_HEADERS xx where xx.PARTY_ID =  temp.party_id 
 );
 else 
delete from hz_purge_gt temp where 


 exists (select 'Y' from ECX_TP_HEADERS xx where xx.PARTY_ID =  temp.party_id 
 );
end if;


--FUN_TRX_BATCHES;INITIATOR_ID
appid:=435;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 435, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 435 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.INITIATOR_ID from FUN_TRX_BATCHES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.INITIATOR_ID from FUN_TRX_BATCHES xx 
 );
end if;
--FUN_TRX_HEADERS;RECIPIENT_ID
appid:=435;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 435, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 435 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.RECIPIENT_ID from FUN_TRX_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.RECIPIENT_ID from FUN_TRX_HEADERS xx 
 );
end if;
--FUN_DIST_LINES;PARTY_ID
appid:=435;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 435, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 435 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from FUN_DIST_LINES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from FUN_DIST_LINES xx 
 );
end if;
--FUN_SUPPLIER_MAPS;VENDOR_SITE_ID
appid:=435;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 435, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 435 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.VENDOR_SITE_ID from FUN_SUPPLIER_MAPS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.VENDOR_SITE_ID from FUN_SUPPLIER_MAPS
 yy 
));
end if;
--FEM_PARTY_PROFITABILITY;PARTY_ID
appid:=272;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 272, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 272 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from FEM_PARTY_PROFITABILITY xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from FEM_PARTY_PROFITABILITY xx 
 );
end if;
--IBE_SH_QUOTE_ACCESS;PARTY_ID
appid:=671;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 671, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 671 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IBE_SH_QUOTE_ACCESS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IBE_SH_QUOTE_ACCESS xx 
 );
end if;
--IBE_ACTIVE_QUOTES_ALL;PARTY_ID
appid:=671;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 671, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 671 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IBE_ACTIVE_QUOTES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IBE_ACTIVE_QUOTES_ALL xx 
 );
end if;
--JTF_TTY_NAMED_ACCTS;PARTY_SITE_ID
appid:=690;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 690, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 690 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.PARTY_SITE_ID from JTF_TTY_NAMED_ACCTS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.PARTY_SITE_ID from JTF_TTY_NAMED_ACCTS
 yy 
));
end if;
--JTF_FM_PROCESSED_V;PARTY_ID
appid:=690;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 690, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 690 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from JTF_FM_PROCESSED_V xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from JTF_FM_PROCESSED_V xx 
 );
end if;
--JTF_FM_CONTENT_HISTORY_V;PARTY_ID
appid:=690;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 690, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 690 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from JTF_FM_CONTENT_HISTORY_V xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from JTF_FM_CONTENT_HISTORY_V xx 
 );
end if;
--FTE_LOCATION_PARAMETERS;FACILITY_CONTACT_ID
appid:=716;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 716, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 716 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.FACILITY_CONTACT_ID from FTE_LOCATION_PARAMETERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.FACILITY_CONTACT_ID from FTE_LOCATION_PARAMETERS xx 
 );
end if;
--OZF_CLAIMS_HISTORY_ALL;BROKER_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BROKER_ID from OZF_CLAIMS_HISTORY_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BROKER_ID from OZF_CLAIMS_HISTORY_ALL xx 
 );
end if;
--OZF_CLAIMS_HISTORY_ALL;CONTACT_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CONTACT_ID from OZF_CLAIMS_HISTORY_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CONTACT_ID from OZF_CLAIMS_HISTORY_ALL xx 
 );
end if;
--OZF_CLAIM_LINES_HIST_ALL;BUY_GROUP_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BUY_GROUP_PARTY_ID from OZF_CLAIM_LINES_HIST_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BUY_GROUP_PARTY_ID from OZF_CLAIM_LINES_HIST_ALL xx 
 );
end if;
--OZF_RESALE_BATCHES_ALL;PARTNER_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTNER_CONTACT_PARTY_ID from OZF_RESALE_BATCHES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTNER_CONTACT_PARTY_ID from OZF_RESALE_BATCHES_ALL xx 
 );
end if;
--OZF_CLAIM_LINES_ALL;BUY_GROUP_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BUY_GROUP_PARTY_ID from OZF_CLAIM_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BUY_GROUP_PARTY_ID from OZF_CLAIM_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;SHIP_FROM_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;SOLD_FROM_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SOLD_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SOLD_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;BILL_TO_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;BILL_TO_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;SHIP_TO_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;SHIP_TO_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;END_CUST_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_LINES_INT_ALL;END_CUST_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_CONTACT_PARTY_ID from OZF_RESALE_LINES_INT_ALL xx 
 );
end if;
--OZF_RESALE_HEADERS_ALL;BILL_TO_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
end if;
--OZF_RESALE_HEADERS_ALL;BILL_TO_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
end if;
--OZF_RESALE_HEADERS_ALL;SHIP_TO_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
end if;
--OZF_RESALE_HEADERS_ALL;SHIP_TO_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_PARTY_ID from OZF_RESALE_HEADERS_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;SHIP_FROM_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;SOLD_FROM_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SOLD_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SOLD_FROM_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;BILL_TO_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;BILL_TO_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;SHIP_TO_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;SHIP_TO_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;END_CUST_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_RESALE_LINES_ALL;END_CUST_CONTACT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_CONTACT_PARTY_ID from OZF_RESALE_LINES_ALL xx 
 );
end if;
--OZF_REQUEST_HEADERS_ALL_B;END_CUST_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_PARTY_ID from OZF_REQUEST_HEADERS_ALL_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUST_PARTY_ID from OZF_REQUEST_HEADERS_ALL_B xx 
 );
end if;
--OZF_ACTIVITY_CUSTOMERS;PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from OZF_ACTIVITY_CUSTOMERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from OZF_ACTIVITY_CUSTOMERS xx 
 );
end if;
--OZF_REQUEST_HEADERS_ALL_B;RESELLER_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.RESELLER_PARTY_ID from OZF_REQUEST_HEADERS_ALL_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.RESELLER_PARTY_ID from OZF_REQUEST_HEADERS_ALL_B xx 
 );
end if;
--OZF_OFFERS;AUTOPAY_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTOPAY_PARTY_ID from OZF_OFFERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTOPAY_PARTY_ID from OZF_OFFERS xx 
 );
end if;
--OZF_ACCOUNT_ALLOCATIONS;PARENT_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARENT_PARTY_ID from OZF_ACCOUNT_ALLOCATIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARENT_PARTY_ID from OZF_ACCOUNT_ALLOCATIONS xx 
 );
end if;
--OZF_ACCOUNT_ALLOCATIONS;ROLLUP_PARTY_ID
appid:=682;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 682, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 682 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ROLLUP_PARTY_ID from OZF_ACCOUNT_ALLOCATIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ROLLUP_PARTY_ID from OZF_ACCOUNT_ALLOCATIONS xx 
 );
end if;
--XLE_REGISTRATIONS;ISSUING_AUTHORITY_ID
appid:=204;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 204, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 204 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ISSUING_AUTHORITY_ID from XLE_REGISTRATIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ISSUING_AUTHORITY_ID from XLE_REGISTRATIONS xx 
 );
end if;
--XLE_REG_FUNCTIONS;AUTHORITY_ID
appid:=204;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 204, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 204 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTHORITY_ID from XLE_REG_FUNCTIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTHORITY_ID from XLE_REG_FUNCTIONS xx 
 );
end if;
--XLE_REGISTRATIONS;ISSUING_AUTHORITY_SITE_ID
appid:=204;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 204, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 204 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.ISSUING_AUTHORITY_SITE_ID from XLE_REGISTRATIONS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.ISSUING_AUTHORITY_SITE_ID from XLE_REGISTRATIONS
 yy 
));
end if;
--XLE_REG_FUNCTIONS;AUTHORITY_SITE_ID
appid:=204;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 204, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 204 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.AUTHORITY_SITE_ID from XLE_REG_FUNCTIONS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.AUTHORITY_SITE_ID from XLE_REG_FUNCTIONS
 yy 
));
end if;
--ISC_DR_REPAIR_ORDERS_F;CUSTOMER_ID
appid:=454;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 454, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 454 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from ISC_DR_REPAIR_ORDERS_F xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from ISC_DR_REPAIR_ORDERS_F xx 
 );
end if;
--CSI_ITEM_INSTANCES;LOCATION_ID
appid:=542;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 542, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 542 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.LOCATION_ID from CSI_ITEM_INSTANCES
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.LOCATION_ID from CSI_ITEM_INSTANCES
 yy 
));
end if;
--CSI_ITEM_INSTANCES;INSTALL_LOCATION_ID
appid:=542;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 542, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 542 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_LOCATION_ID from CSI_ITEM_INSTANCES
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_LOCATION_ID from CSI_ITEM_INSTANCES
 yy 
));
end if;
--CSI_T_TXN_SYSTEMS;INSTALL_SITE_USE_ID
appid:=542;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 542, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 542 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_SITE_USE_ID from CSI_T_TXN_SYSTEMS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_SITE_USE_ID from CSI_T_TXN_SYSTEMS
 yy 
));
end if;
--OKS_QUALIFIERS;QUALIFIER_ATTR_VALUE
appid:=515;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 515, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 515 and appl.party_id=temp.party_id) and 

 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.QUALIFIER_ATTR_VALUE from OKS_QUALIFIERS xx 
 where ((qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE1'  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute ='QUALIFIER_ATTRIBUTE16'  OR qualifier_context = 'CUSTOMER_GROUP' AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE3'  OR qualifier_context = 'PARTY' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2'))));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.QUALIFIER_ATTR_VALUE from OKS_QUALIFIERS xx 
 where ((qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE1'  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute ='QUALIFIER_ATTRIBUTE16'  OR qualifier_context = 'CUSTOMER_GROUP' AND qualifier_attribute = 'QUALIFIER_ATTRIBUTE3'  OR qualifier_context = 'PARTY' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE1', 'QUALIFIER_ATTRIBUTE2'))));
end if;
--OKS_QUALIFIERS;QUALIFIER_ATTR_VALUE
appid:=515;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 515, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 515 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  to_char(xx.PARTY_SITE_ID)
 in (select /*+ parallel(yy)*/ yy.QUALIFIER_ATTR_VALUE from OKS_QUALIFIERS
 yy 
 where (qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18'))));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  to_char(xx.PARTY_SITE_ID)
 in (select /*+ parallel(yy)*/ yy.QUALIFIER_ATTR_VALUE from OKS_QUALIFIERS
 yy 
 where (qualifier_context = 'ASOPARTYINFO'  AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE10','QUALIFIER_ATTRIBUTE11')  OR qualifier_context = 'CUSTOMER' AND qualifier_attribute IN ('QUALIFIER_ATTRIBUTE17', 'QUALIFIER_ATTRIBUTE18'))));
end if;
--WSH_PARTY_SITES_V;PARTY_SITE_ID
appid:=665;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 665, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 665 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.PARTY_SITE_ID from WSH_PARTY_SITES_V
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.PARTY_SITE_ID from WSH_PARTY_SITES_V
 yy 
));
end if;
--IBW_PAGE_VIEWS;PARTY_ID
appid:=666;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 666, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 666 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IBW_PAGE_VIEWS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IBW_PAGE_VIEWS xx 
 );
end if;
--IBW_PAGE_VIEWS;PARTY_RELATIONSHIP_ID
appid:=666;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 666, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 666 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_RELATIONSHIP_ID from IBW_PAGE_VIEWS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_RELATIONSHIP_ID from IBW_PAGE_VIEWS xx 
 );
end if;
--OKE_POOL_PARTIES;PARTY_ID
appid:=777;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 777, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 777 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from OKE_POOL_PARTIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from OKE_POOL_PARTIES xx 
 );
end if;
--AHL_SUBSCRIPTIONS_B;REQUESTED_BY_PARTY_ID
appid:=867;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 867, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 867 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.REQUESTED_BY_PARTY_ID from AHL_SUBSCRIPTIONS_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.REQUESTED_BY_PARTY_ID from AHL_SUBSCRIPTIONS_B xx 
 );
end if;
--AHL_SUBSCRIPTIONS_B;SUBSCRIBED_FRM_PARTY_ID
appid:=867;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 867, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 867 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SUBSCRIBED_FRM_PARTY_ID from AHL_SUBSCRIPTIONS_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SUBSCRIBED_FRM_PARTY_ID from AHL_SUBSCRIPTIONS_B xx 
 );
end if;
--AHL_ROUTES_B;OPERATOR_PARTY_ID
appid:=867;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 867, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 867 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.OPERATOR_PARTY_ID from AHL_ROUTES_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.OPERATOR_PARTY_ID from AHL_ROUTES_B xx 
 );
end if;
--XDP_ORDER_HEADERS;CUSTOMER_ID
appid:=535;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 535, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 535 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from XDP_ORDER_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from XDP_ORDER_HEADERS xx 
 );
end if;
--FND_ATTACHED_DOCUMENTS;PK1_VALUE
appid:=222;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 222, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 222 and appl.party_id=temp.party_id) and 

 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.PK1_VALUE from FND_ATTACHED_DOCUMENTS xx 
 where (entity_name = 'HZ_PARTIES'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.PK1_VALUE from FND_ATTACHED_DOCUMENTS xx 
 where (entity_name = 'HZ_PARTIES'));
end if;
--HZ_EMAIL_DOMAINS;PARTY_ID
appid:=222;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 222, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 222 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from HZ_EMAIL_DOMAINS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from HZ_EMAIL_DOMAINS xx 
 );
end if;
--HZ_CODE_ASSIGNMENTS;OWNER_TABLE_ID
appid:=222;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 222, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 222 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.OWNER_TABLE_ID from HZ_CODE_ASSIGNMENTS xx 
 where (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I')));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.OWNER_TABLE_ID from HZ_CODE_ASSIGNMENTS xx 
 where (OWNER_TABLE_NAME='HZ_PARTIES' AND nvl(STATUS, 'A') in ('A','I')));
end if;
--HZ_CODE_ASSIGNMENTS;OWNER_TABLE_ID
appid:=222;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 222, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 222 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.OWNER_TABLE_ID from HZ_CODE_ASSIGNMENTS
 yy 
 where OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.OWNER_TABLE_ID from HZ_CODE_ASSIGNMENTS
 yy 
 where OWNER_TABLE_NAME='HZ_PARTY_SITES' AND nvl(STATUS, 'A') in ('A','I')));
end if;
--HZ_WORK_CLASS;EMPLOYMENT_HISTORY_ID
appid:=222;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 222, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 222 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.EMPLOYED_BY_PARTY_ID from HZ_EMPLOYMENT_HISTORY
 xx 
 where (nvl(STATUS,'A') in ('A','I'))
 and  xx.EMPLOYMENT_HISTORY_ID 
 in (select /*+ parallel(yy)*/ yy.EMPLOYMENT_HISTORY_ID from HZ_WORK_CLASS
 yy 
 where nvl(STATUS, 'A') in ('A','I')))
 or  temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_EMPLOYMENT_HISTORY
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.EMPLOYMENT_HISTORY_ID 
 in (select /*+ parallel(yy)*/ yy.EMPLOYMENT_HISTORY_ID from HZ_WORK_CLASS
 yy 
 where nvl(STATUS, 'A') in ('A','I')));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.EMPLOYED_BY_PARTY_ID from HZ_EMPLOYMENT_HISTORY
 xx 
 where (nvl(STATUS,'A') in ('A','I'))
 and  xx.EMPLOYMENT_HISTORY_ID 
 in (select /*+ parallel(yy)*/ yy.EMPLOYMENT_HISTORY_ID from HZ_WORK_CLASS
 yy 
 where nvl(STATUS, 'A') in ('A','I')))
 or  temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_EMPLOYMENT_HISTORY
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.EMPLOYMENT_HISTORY_ID 
 in (select /*+ parallel(yy)*/ yy.EMPLOYMENT_HISTORY_ID from HZ_WORK_CLASS
 yy 
 where nvl(STATUS, 'A') in ('A','I')));
end if;
--AMS_IBA_PL_SITES_B;SITE_CATEGORY_OBJECT_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SITE_CATEGORY_OBJECT_ID from AMS_IBA_PL_SITES_B xx 
 where (SITE_CATEGORY_TYPE = 'AFFILIATES'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SITE_CATEGORY_OBJECT_ID from AMS_IBA_PL_SITES_B xx 
 where (SITE_CATEGORY_TYPE = 'AFFILIATES'));
end if;
--AMS_PARTY_MARKET_SEGMENTS;PARTY_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_PARTY_MARKET_SEGMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_PARTY_MARKET_SEGMENTS xx 
 );
end if;
--AMS_AGENDAS_B;COORDINATOR_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.COORDINATOR_ID from AMS_AGENDAS_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.COORDINATOR_ID from AMS_AGENDAS_B xx 
 );
end if;
--AMS_TCOP_CHANNEL_SUMMARY;PARTY_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_CHANNEL_SUMMARY xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_CHANNEL_SUMMARY xx 
 );
end if;
--AMS_TCOP_CONTACTS;PARTY_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_CONTACTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_CONTACTS xx 
 );
end if;
--AMS_TCOP_PRVW_CONTACTS;PARTY_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_PRVW_CONTACTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_PRVW_CONTACTS xx 
 );
end if;
--AMS_TCOP_PRVW_FTG_DTLS;PARTY_ID
appid:=530;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 530, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 530 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_PRVW_FTG_DTLS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from AMS_TCOP_PRVW_FTG_DTLS xx 
 );
end if;
--PRP_EMAIL_RECIPIENTS;PARTY_ID
appid:=694;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 694, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 694 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from PRP_EMAIL_RECIPIENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from PRP_EMAIL_RECIPIENTS xx 
 );
end if;
--PRP_PROPOSALS;CONTACT_PARTY_ID
appid:=694;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 694, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 694 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CONTACT_PARTY_ID from PRP_PROPOSALS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CONTACT_PARTY_ID from PRP_PROPOSALS xx 
 );
end if;
--CS_ESTIMATE_DETAILS;BILL_TO_PARTY_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from CS_ESTIMATE_DETAILS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from CS_ESTIMATE_DETAILS xx 
 );
end if;
--CS_ESTIMATE_DETAILS;SHIP_TO_PARTY_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from CS_ESTIMATE_DETAILS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from CS_ESTIMATE_DETAILS xx 
 );
end if;
--CS_INCIDENTS_ALL_B;SITE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--CS_INCIDENTS_AUDIT_B;SITE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SITE_ID from CS_INCIDENTS_AUDIT_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SITE_ID from CS_INCIDENTS_AUDIT_B
 yy 
));
end if;
--CS_INCIDENTS_ALL_B;BILL_TO_SITE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.BILL_TO_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.BILL_TO_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--CS_INCIDENTS_ALL_B;SHIP_TO_SITE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SHIP_TO_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SHIP_TO_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--CS_INCIDENTS_ALL_B;INSTALL_SITE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--CS_INCIDENTS_AUDIT_B;BILL_TO_CONTACT_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_ID from CS_INCIDENTS_AUDIT_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_ID from CS_INCIDENTS_AUDIT_B xx 
 );
end if;
--CS_INCIDENTS_ALL_B;BILL_TO_PARTY_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from CS_INCIDENTS_ALL_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_PARTY_ID from CS_INCIDENTS_ALL_B xx 
 );
end if;
--CS_INCIDENTS_ALL_B;SHIP_TO_PARTY_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from CS_INCIDENTS_ALL_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from CS_INCIDENTS_ALL_B xx 
 );
end if;
--CS_CHG_SUB_RESTRICTIONS;VALUE_OBJECT_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.VALUE_OBJECT_ID from CS_CHG_SUB_RESTRICTIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.VALUE_OBJECT_ID from CS_CHG_SUB_RESTRICTIONS xx 
 );
end if;
--CS_INCIDENTS_ALL_B;BILL_TO_CONTACT_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_ID from CS_INCIDENTS_ALL_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BILL_TO_CONTACT_ID from CS_INCIDENTS_ALL_B xx 
 );
end if;
--CS_INCIDENTS_ALL_B;SHIP_TO_CONTACT_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_ID from CS_INCIDENTS_ALL_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CONTACT_ID from CS_INCIDENTS_ALL_B xx 
 );
end if;
--CS_INCIDENTS_ALL_B;CUSTOMER_SITE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.CUSTOMER_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.CUSTOMER_SITE_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--CS_INCIDENTS_ALL_B;INSTALL_SITE_USE_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_SITE_USE_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INSTALL_SITE_USE_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--CS_INCIDENTS_ALL_B;INCIDENT_LOCATION_ID
appid:=170;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 170, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 170 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INCIDENT_LOCATION_ID from CS_INCIDENTS_ALL_B
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INCIDENT_LOCATION_ID from CS_INCIDENTS_ALL_B
 yy 
));
end if;
--IGP_AC_ACCOUNT_INTS;PARTY_ID
appid:=8405;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8405, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8405 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGP_AC_ACCOUNT_INTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGP_AC_ACCOUNT_INTS xx 
 );
end if;
--IGP_US_REG_VIEWERS;ORG_PARTY_ID
appid:=8405;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8405, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8405 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ORG_PARTY_ID from IGP_US_REG_VIEWERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ORG_PARTY_ID from IGP_US_REG_VIEWERS xx 
 );
end if;
--IGS_PE_STAT_DETAILS;PERSON_PROFILE_ID
appid:=8405;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8405, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8405 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PERSON_PROFILES
 xx 
 where (nvl(STATUS, 'A') in ('A','I') and effective_end_date is null)
 and  xx.PERSON_PROFILE_ID 
 in (select /*+ parallel(yy)*/ yy.PERSON_PROFILE_ID from IGS_PE_STAT_DETAILS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PERSON_PROFILES
 xx 
 where (nvl(STATUS, 'A') in ('A','I') and effective_end_date is null)
 and  xx.PERSON_PROFILE_ID 
 in (select /*+ parallel(yy)*/ yy.PERSON_PROFILE_ID from IGS_PE_STAT_DETAILS
 yy 
));
end if;
--IGS_FI_REFUNDS;PAY_PERSON_ID
appid:=8405;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8405, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8405 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PAY_PERSON_ID from IGS_FI_REFUNDS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PAY_PERSON_ID from IGS_FI_REFUNDS xx 
 );
end if;
--QA_RESULTS;PARTY_ID
appid:=250;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 250, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 250 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from QA_RESULTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from QA_RESULTS xx 
 );
end if;
--ASO_QUOTE_HEADERS_ALL;END_CUSTOMER_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
end if;
--ASO_QUOTE_HEADERS_ALL;END_CUSTOMER_CUST_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_CUST_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_CUST_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
end if;
--ASO_QUOTE_HEADERS_ALL;END_CUSTOMER_PARTY_SITE_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.END_CUSTOMER_PARTY_SITE_ID from ASO_QUOTE_HEADERS_ALL
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.END_CUSTOMER_PARTY_SITE_ID from ASO_QUOTE_HEADERS_ALL
 yy 
));
end if;
--ASO_QUOTE_LINES_ALL;END_CUSTOMER_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
end if;
--ASO_QUOTE_LINES_ALL;END_CUSTOMER_CUST_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_CUST_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.END_CUSTOMER_CUST_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
end if;
--ASO_QUOTE_LINES_ALL;END_CUSTOMER_PARTY_SITE_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.END_CUSTOMER_PARTY_SITE_ID from ASO_QUOTE_LINES_ALL
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.END_CUSTOMER_PARTY_SITE_ID from ASO_QUOTE_LINES_ALL
 yy 
));
end if;
--ASO_QUOTE_HEADERS_ALL;INVOICE_TO_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
end if;
--ASO_QUOTE_LINES_ALL;INVOICE_TO_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
end if;
--ASO_SHIPMENTS;SHIP_TO_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from ASO_SHIPMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_PARTY_ID from ASO_SHIPMENTS xx 
 );
end if;
--ASO_QUOTE_HEADERS_ALL;INVOICE_TO_PARTY_SITE_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INVOICE_TO_PARTY_SITE_ID from ASO_QUOTE_HEADERS_ALL
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INVOICE_TO_PARTY_SITE_ID from ASO_QUOTE_HEADERS_ALL
 yy 
));
end if;
--ASO_QUOTE_LINES_ALL;INVOICE_TO_PARTY_SITE_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INVOICE_TO_PARTY_SITE_ID from ASO_QUOTE_LINES_ALL
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.INVOICE_TO_PARTY_SITE_ID from ASO_QUOTE_LINES_ALL
 yy 
));
end if;
--ASO_QUOTE_HEADERS_ALL;INVOICE_TO_CUST_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_CUST_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_CUST_PARTY_ID from ASO_QUOTE_HEADERS_ALL xx 
 );
end if;
--ASO_QUOTE_HEADERS_ALL;SOLD_TO_PARTY_SITE_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SOLD_TO_PARTY_SITE_ID from ASO_QUOTE_HEADERS_ALL
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.SOLD_TO_PARTY_SITE_ID from ASO_QUOTE_HEADERS_ALL
 yy 
));
end if;
--ASO_QUOTE_LINES_ALL;INVOICE_TO_CUST_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_CUST_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.INVOICE_TO_CUST_PARTY_ID from ASO_QUOTE_LINES_ALL xx 
 );
end if;
--ASO_SHIPMENTS;SHIP_TO_CUST_PARTY_ID
appid:=697;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 697, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 697 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CUST_PARTY_ID from ASO_SHIPMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHIP_TO_CUST_PARTY_ID from ASO_SHIPMENTS xx 
 );
end if;
--PON_SUPPLIER_ACCESS;BUYER_TP_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.BUYER_TP_CONTACT_ID from PON_SUPPLIER_ACCESS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.BUYER_TP_CONTACT_ID from PON_SUPPLIER_ACCESS xx 
 );
end if;
--PON_BIDDING_PARTIES;TRADING_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_BIDDING_PARTIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_BIDDING_PARTIES xx 
 );
end if;
--PON_BIDDING_PARTIES;ACK_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ACK_PARTNER_CONTACT_ID from PON_BIDDING_PARTIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ACK_PARTNER_CONTACT_ID from PON_BIDDING_PARTIES xx 
 );
end if;
--PON_OPTIMIZE_CONSTRAINTS;TRADING_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_OPTIMIZE_CONSTRAINTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_OPTIMIZE_CONSTRAINTS xx 
 );
end if;
--PON_OPTIMIZE_CONSTRAINTS;TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_OPTIMIZE_CONSTRAINTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_OPTIMIZE_CONSTRAINTS xx 
 );
end if;
--PON_ACKNOWLEDGEMENTS;TRADING_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_ACKNOWLEDGEMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_ACKNOWLEDGEMENTS xx 
 );
end if;
--PON_ACKNOWLEDGEMENTS;TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_ACKNOWLEDGEMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_ACKNOWLEDGEMENTS xx 
 );
end if;
--PON_AUCTION_SUMMARY;TRADING_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_AUCTION_SUMMARY xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_AUCTION_SUMMARY xx 
 );
end if;
--PON_AUCTION_SUMMARY;TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_AUCTION_SUMMARY xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_AUCTION_SUMMARY xx 
 );
end if;
--PON_SUPPLIER_ACTIVITIES;TRADING_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_SUPPLIER_ACTIVITIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_SUPPLIER_ACTIVITIES xx 
 );
end if;
--PON_AUCTION_HEADERS_ALL;DRAFT_LOCKED_BY_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_LOCKED_BY_CONTACT_ID from PON_AUCTION_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_LOCKED_BY_CONTACT_ID from PON_AUCTION_HEADERS_ALL xx 
 );
end if;
--PON_AUCTION_HEADERS_ALL;DRAFT_UNLOCKED_BY_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_UNLOCKED_BY_CONTACT_ID from PON_AUCTION_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_UNLOCKED_BY_CONTACT_ID from PON_AUCTION_HEADERS_ALL xx 
 );
end if;
--PON_AUCTION_HEADERS_ALL;SCORING_LOCK_TP_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SCORING_LOCK_TP_CONTACT_ID from PON_AUCTION_HEADERS_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SCORING_LOCK_TP_CONTACT_ID from PON_AUCTION_HEADERS_ALL xx 
 );
end if;
--PON_AUCTION_EVENTS;TRADING_PARTNER_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_AUCTION_EVENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_CONTACT_ID from PON_AUCTION_EVENTS xx 
 );
end if;
--PON_BID_HEADERS;SURROG_BID_CREATED_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_CREATED_CONTACT_ID from PON_BID_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_CREATED_CONTACT_ID from PON_BID_HEADERS xx 
 );
end if;
--PON_BID_HEADERS;SCORE_OVERRIDE_TP_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SCORE_OVERRIDE_TP_CONTACT_ID from PON_BID_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SCORE_OVERRIDE_TP_CONTACT_ID from PON_BID_HEADERS xx 
 );
end if;
--PON_BID_HEADERS;SHORTLIST_TPC_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHORTLIST_TPC_ID from PON_BID_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SHORTLIST_TPC_ID from PON_BID_HEADERS xx 
 );
end if;
--PON_BID_HEADERS;DRAFT_UNLOCKED_BY_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_UNLOCKED_BY_CONTACT_ID from PON_BID_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_UNLOCKED_BY_CONTACT_ID from PON_BID_HEADERS xx 
 );
end if;
--PON_BID_HEADERS;DRAFT_LOCKED_BY_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_LOCKED_BY_CONTACT_ID from PON_BID_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.DRAFT_LOCKED_BY_CONTACT_ID from PON_BID_HEADERS xx 
 );
end if;
--PON_CONTRACTS;AUTHORING_PARTY_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTHORING_PARTY_ID from PON_CONTRACTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTHORING_PARTY_ID from PON_CONTRACTS xx 
 );
end if;
--PON_THREADS;OWNER_PARTY_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.OWNER_PARTY_ID from PON_THREADS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.OWNER_PARTY_ID from PON_THREADS xx 
 );
end if;
--PON_SUPPLIER_ACTIVITIES;TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_SUPPLIER_ACTIVITIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_SUPPLIER_ACTIVITIES xx 
 );
end if;
--PON_SUPPLIER_ACCESS;SUPPLIER_TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SUPPLIER_TRADING_PARTNER_ID from PON_SUPPLIER_ACCESS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SUPPLIER_TRADING_PARTNER_ID from PON_SUPPLIER_ACCESS xx 
 );
end if;
--PON_PARTY_LINE_EXCLUSIONS;TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_PARTY_LINE_EXCLUSIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_PARTY_LINE_EXCLUSIONS xx 
 );
end if;
--PON_PF_SUPPLIER_FORMULA;TRADING_PARTNER_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_PF_SUPPLIER_FORMULA xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TRADING_PARTNER_ID from PON_PF_SUPPLIER_FORMULA xx 
 );
end if;
--PON_BID_HEADERS;SURROG_BID_CREATED_TP_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_CREATED_TP_ID from PON_BID_HEADERS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_CREATED_TP_ID from PON_BID_HEADERS xx 
 );
end if;
--PON_CONTRACTS;AUTHORING_PARTY_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTHORING_PARTY_CONTACT_ID from PON_CONTRACTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.AUTHORING_PARTY_CONTACT_ID from PON_CONTRACTS xx 
 );
end if;
--PON_THREAD_ENTRIES;FROM_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.FROM_ID from PON_THREAD_ENTRIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.FROM_ID from PON_THREAD_ENTRIES xx 
 );
end if;
--PON_THREAD_ENTRIES;FROM_COMPANY_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.FROM_COMPANY_ID from PON_THREAD_ENTRIES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.FROM_COMPANY_ID from PON_THREAD_ENTRIES xx 
 );
end if;
--PON_TE_RECIPIENTS;TO_COMPANY_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.TO_COMPANY_ID from PON_TE_RECIPIENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.TO_COMPANY_ID from PON_TE_RECIPIENTS xx 
 );
end if;
--PON_ACKNOWLEDGEMENTS;SURROG_BID_ACK_CONTACT_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_ACK_CONTACT_ID from PON_ACKNOWLEDGEMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_ACK_CONTACT_ID from PON_ACKNOWLEDGEMENTS xx 
 );
end if;
--PON_ACKNOWLEDGEMENTS;SURROG_BID_ACK_TP_ID
appid:=396;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 396, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 396 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_ACK_TP_ID from PON_ACKNOWLEDGEMENTS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.SURROG_BID_ACK_TP_ID from PON_ACKNOWLEDGEMENTS xx 
 );
end if;
--JTF_PERZ_DATA_V;ATTRIBUTE_VALUE
appid:=514;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 514, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 514 and appl.party_id=temp.party_id) and 

 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.ATTRIBUTE_VALUE from JTF_PERZ_DATA_V xx 
 where (attribute_name = 'customer ID' and application_id = 514 and perz_data_type in ('CSS_PROFILE_DEFECT_TEMPLATE','CSS_PROFILE_ENH_TEMPLATE') and profile_name like 'CSS_514%'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.ATTRIBUTE_VALUE from JTF_PERZ_DATA_V xx 
 where (attribute_name = 'customer ID' and application_id = 514 and perz_data_type in ('CSS_PROFILE_DEFECT_TEMPLATE','CSS_PROFILE_ENH_TEMPLATE') and profile_name like 'CSS_514%'));
end if;
--JTF_PERZ_QUERY_PARAM_V;PARAMETER_VALUE
appid:=514;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 514, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 514 and appl.party_id=temp.party_id) and 

 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.PARAMETER_VALUE from JTF_PERZ_QUERY_PARAM_V xx 
 where (parameter_name in ('CUSTOMER_ID','SR_CUSTOMER_ID') and application_id = 514 and query_type like 'ADV_SEARCH_%' and profile_name like 'CSS_514%' ));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.PARAMETER_VALUE from JTF_PERZ_QUERY_PARAM_V xx 
 where (parameter_name in ('CUSTOMER_ID','SR_CUSTOMER_ID') and application_id = 514 and query_type like 'ADV_SEARCH_%' and profile_name like 'CSS_514%' ));
end if;
--OKL_EXT_SELL_INVS_B;CUSTOMER_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from OKL_EXT_SELL_INVS_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from OKL_EXT_SELL_INVS_B xx 
 );
end if;
--OKL_OPEN_INT;PARTY_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from OKL_OPEN_INT xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from OKL_OPEN_INT xx 
 );
end if;
--OKL_INS_POLICIES_B;INT_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.INT_ID from OKL_INS_POLICIES_B xx 
 where (IPY_TYPE = 'THIRD_PARTY_POLICY'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 to_char(temp.party_id)  in (select /*+ parallel(xx)*/ xx.INT_ID from OKL_INS_POLICIES_B xx 
 where (IPY_TYPE = 'THIRD_PARTY_POLICY'));
end if;
--OKL_INS_POLICIES_B;AGENT_SITE_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  to_char(xx.PARTY_SITE_ID)
 in (select /*+ parallel(yy)*/ yy.AGENT_SITE_ID from OKL_INS_POLICIES_B
 yy 
 where IPY_TYPE = 'THIRD_PARTY_POLICY'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  to_char(xx.PARTY_SITE_ID)
 in (select /*+ parallel(yy)*/ yy.AGENT_SITE_ID from OKL_INS_POLICIES_B
 yy 
 where IPY_TYPE = 'THIRD_PARTY_POLICY'));
end if;
--OKL_INS_POLICIES_B;AGENCY_SITE_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.AGENCY_SITE_ID from OKL_INS_POLICIES_B
 yy 
 where IPY_TYPE = 'THIRD_PARTY_POLICY'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.AGENCY_SITE_ID from OKL_INS_POLICIES_B
 yy 
 where IPY_TYPE = 'THIRD_PARTY_POLICY'));
end if;
--OKL_INS_POLICIES_B;AGENCY_SITE_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.AGENCY_SITE_ID from OKL_INS_POLICIES_B
 yy 
 where IPY_TYPE = 'THIRD_PARTY_POLICY'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.AGENCY_SITE_ID from OKL_INS_POLICIES_B
 yy 
 where IPY_TYPE = 'THIRD_PARTY_POLICY'));
end if;
--OKL_INS_POLICIES_B;ISU_ID
appid:=540;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 540, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 540 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ISU_ID from OKL_INS_POLICIES_B xx 
 where (IPY_TYPE = 'THIRD_PARTY_POLICY'));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ISU_ID from OKL_INS_POLICIES_B xx 
 where (IPY_TYPE = 'THIRD_PARTY_POLICY'));
end if;
--AMW_ASSESSMENTS_B;ASSESSMENT_OWNER_ID
appid:=242;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 242, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 242 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ASSESSMENT_OWNER_ID from AMW_ASSESSMENTS_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ASSESSMENT_OWNER_ID from AMW_ASSESSMENTS_B xx 
 );
end if;
--AMW_AP_EXECUTIONS;EXECUTED_BY
appid:=242;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 242, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 242 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.EXECUTED_BY from AMW_AP_EXECUTIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.EXECUTED_BY from AMW_AP_EXECUTIONS xx 
 );
end if;
--AMW_CONSTRAINTS_B;ENTERED_BY_ID
appid:=242;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 242, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 242 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ENTERED_BY_ID from AMW_CONSTRAINTS_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ENTERED_BY_ID from AMW_CONSTRAINTS_B xx 
 );
end if;
--AMW_VIOLATIONS;REQUESTED_BY_ID
appid:=242;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 242, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 242 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.REQUESTED_BY_ID from AMW_VIOLATIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.REQUESTED_BY_ID from AMW_VIOLATIONS xx 
 );
end if;
--AMW_CERTIFICATION_B;CERTIFICATION_OWNER_ID
appid:=242;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 242, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 242 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CERTIFICATION_OWNER_ID from AMW_CERTIFICATION_B xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CERTIFICATION_OWNER_ID from AMW_CERTIFICATION_B xx 
 );
end if;
--AS_SALES_CREDITS_DENORM;CLOSE_COMPETITOR_ID
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CLOSE_COMPETITOR_ID from AS_SALES_CREDITS_DENORM xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CLOSE_COMPETITOR_ID from AS_SALES_CREDITS_DENORM xx 
 );
end if;
--AS_LEADS_LOG;CUSTOMER_ID
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from AS_LEADS_LOG xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from AS_LEADS_LOG xx 
 );
end if;
--AS_LEADS_LOG;ADDRESS_ID
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.ADDRESS_ID from AS_LEADS_LOG
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.ADDRESS_ID from AS_LEADS_LOG
 yy 
));
end if;
--AS_LEADS_LOG;CLOSE_COMPETITOR_ID
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CLOSE_COMPETITOR_ID from AS_LEADS_LOG xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CLOSE_COMPETITOR_ID from AS_LEADS_LOG xx 
 );
end if;
--AS_CURRENT_ENVIRONMENT;CUSTOMER_ID
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from AS_CURRENT_ENVIRONMENT xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.CUSTOMER_ID from AS_CURRENT_ENVIRONMENT xx 
 );
end if;
--AS_SALES_LEADS;REFERRED_BY
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.REFERRED_BY from AS_SALES_LEADS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.REFERRED_BY from AS_SALES_LEADS xx 
 );
end if;
--AS_SALES_LEADS;INCUMBENT_PARTNER_PARTY_ID
appid:=279;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 279, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 279 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.INCUMBENT_PARTNER_PARTY_ID from AS_SALES_LEADS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.INCUMBENT_PARTNER_PARTY_ID from AS_SALES_LEADS xx 
 );
end if;
--IGW_PROP_LOCATIONS;PARTY_ID
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8404 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGW_PROP_LOCATIONS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGW_PROP_LOCATIONS xx 
 );
end if;
--IGW_PERSON_DEGREES;PARTY_ID
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8404 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGW_PERSON_DEGREES xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGW_PERSON_DEGREES xx 
 );
end if;
--IGW_PERSON_BIOSKETCH;PARTY_ID
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8404 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGW_PERSON_BIOSKETCH xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGW_PERSON_BIOSKETCH xx 
 );
end if;
--IGW_PROP_PERSONS_TCA_V;ORG_PARTY_ID
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8404 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.ORG_PARTY_ID from IGW_PROP_PERSONS_TCA_V xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.ORG_PARTY_ID from IGW_PROP_PERSONS_TCA_V xx 
 );
end if;
--IGW_PROP_PERSON_SUPPORT;LOCATION_PARTY_ID
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8404 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.LOCATION_PARTY_ID from IGW_PROP_PERSON_SUPPORT xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.LOCATION_PARTY_ID from IGW_PROP_PERSON_SUPPORT xx 
 );
end if;
--IGW_PROP_PERSON_SUPPORT;PI_PARTY_ID
appid:=8404;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8404, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8404 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PI_PARTY_ID from IGW_PROP_PERSON_SUPPORT xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PI_PARTY_ID from IGW_PROP_PERSON_SUPPORT xx 
 );
end if;
--CSC_CUST_PLANS;PARTY_ID
appid:=511;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 511, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 511 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from CSC_CUST_PLANS xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from CSC_CUST_PLANS xx 
 );
end if;
--ECX_TP_HEADERS;PARTY_SITE_ID
appid:=174;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 174, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 174 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.PARTY_SITE_ID from ECX_TP_HEADERS
 yy 
));
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel (xx)*/ xx.PARTY_ID from HZ_PARTY_SITES
 xx 
 where (nvl(STATUS, 'A') in ('A','I'))
 and  xx.PARTY_SITE_ID 
 in (select /*+ parallel(yy)*/ yy.PARTY_SITE_ID from ECX_TP_HEADERS
 yy 
));
end if;
--IGF_AP_FA_BASE_REC_ALL;PERSON_ID
appid:=8406;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8406, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8406 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PERSON_ID from IGF_AP_FA_BASE_REC_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PERSON_ID from IGF_AP_FA_BASE_REC_ALL xx 
 );
end if;
--IGF_AW_FUND_MAST_ALL;PARTY_ID
appid:=8406;
 if(regid_proc = true) then 
insert into hz_application_trans_gt(app_id,party_id) select 8406, temp.party_id from hz_purge_gt temp  where not exists(select 'Y' from hz_application_trans_gt appl where appl.app_id = 8406 and appl.party_id=temp.party_id) and 

 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGF_AW_FUND_MAST_ALL xx 
 );
 else 
delete /*+ parallel(temp) */ from hz_purge_gt temp where 
 temp.party_id  in (select /*+ parallel(xx)*/ xx.PARTY_ID from IGF_AW_FUND_MAST_ALL xx 
 );
end if;
 if(regid_proc = true) then 
delete from hz_purge_gt temp where temp.party_id in (select appl.party_id from hz_application_trans_gt appl) ;
end if;


EXCEPTION
WHEN OTHERS THEN
ROLLBACK to identify_candidates;
x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_OTHERS_EXCEP' );
FND_MESSAGE.SET_TOKEN( 'ERROR' ,SQLERRM );
FND_MSG_PUB.ADD;
FND_MSG_PUB.Count_And_Get(
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data );
RAISE FND_API.G_EXC_ERROR;
END IDENTIFY_CANDIDATES;
END HZ_PURGE_GEN;

/
