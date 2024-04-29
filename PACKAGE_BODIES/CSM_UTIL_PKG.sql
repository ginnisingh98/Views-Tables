--------------------------------------------------------
--  DDL for Package Body CSM_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_UTIL_PKG" AS
/* $Header: csmeutlb.pls 120.16.12010000.5 2009/08/13 12:30:04 saradhak ship $ */
error EXCEPTION;
g_invalid_argument_exception exception;
g_null_primary_key_exception exception;
g_element_not_found_exception exception;

g_debug_level    NUMBER;  -- variable containing debug level
g_object_name    VARCHAR(255):= 'CSM_UTIL_PKG';

g_initialize_log BOOLEAN := FALSE;

--Table to contain information regarding the master tables to be updated
--either thru concurrent job or workflow activities.
g_acc_refresh_desc_tbl Acc_Refresh_Desc_Tbl_Type := Acc_Refresh_Desc_Tbl_Type();

--a null list
g_null_user_list asg_download.user_list;

--g_buffer varchar(1024);

/***
  Function that returns debug level.
  0 = No debug
  1 = Log errors
  2 = Log errors and functional messages
  3 = Log errors, functional messages and SQL statements
  4 = Full Debug
***/
FUNCTION Get_Debug_Level RETURN NUMBER
IS
BEGIN
  /*** has debug mode already been retrieved ***/
  IF g_debug_level IS NULL THEN
    /*** no -> get it from profile ***/
    g_debug_level := FND_PROFILE.VALUE( 'JTM_DEBUG_LEVEL');
  END IF;
  RETURN g_debug_level;
END Get_Debug_Level;


/**
 Paramaters:
   mesg: The message to be logged
*/
procedure pvt_log (mesg varchar2)
IS
BEGIN
 NULL;
END;


/* logs messages using the JTT framework */
/* log_level: fnd_log.statement, fnd_log.procedure, fnd_log.event, fnd_log.exception, fnd_log.error */
PROCEDURE LOG(message IN VARCHAR2,
              module IN VARCHAR2 DEFAULT 'CSM',
              log_level IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT)
IS
l_message VARCHAR2(4000);
BEGIN
  l_message := message;
  IF g_initialize_log = TRUE THEN
     IF (log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        FND_LOG.STRING(log_level, module, l_message);
     END IF;
  ELSE
     fnd_log_repository.init();
     g_initialize_log := TRUE;
     IF (log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
        fnd_log.string(log_level, module, l_message);
     END IF;
  END IF;
END LOG;

/**
  Initializes g_acc_refresh_desc_tbl with the informatoin pertaining to
  master tables to be updated
  either through concurrent job or workflow activities.
*/
procedure initialize_g_table_desc_tbl
IS
i NUMBER := 0;
BEGIN
  IF (g_acc_refresh_desc_tbl IS NULL OR g_acc_refresh_desc_tbl.COUNT = 0) THEN

/*    -- CSM_TXN_SUB_TYPES
    i := i +1;
    g_acc_refresh_desc_tbl.EXTEND;
    g_acc_refresh_desc_tbl(i).BACKEND_TABLE_NAME    := 'CSI_IB_TXN_TYPES';
    g_acc_refresh_desc_tbl(i).ACC_TABLE_NAME        := 'CSM_IB_TXN_TYPES_ACC';
    g_acc_refresh_desc_tbl(i).ACC_SEQUENCE_NAME     := 'CSM_IB_TXN_TYPES_ACC_S';
    g_acc_refresh_desc_tbl(i).PRIMARY_KEY_COLUMN    := 'SUB_TYPE_ID';
    g_acc_refresh_desc_tbl(i).PUBLICATION_ITEM_NAME := 'CSF_M_TXN_SUB_TYPES';
    g_acc_refresh_desc_tbl(i).ACCESS_QUERY :=
        'select cit.sub_type_id
         from
           csi_ib_txn_types cit,
           csi_source_ib_types cst,
           csi_txn_types ctt,
           csi_instance_statuses cis
        where  cst.sub_type_id = cit.sub_type_id
          and    cst.transaction_type_id = ctt.transaction_type_id
          and    cit.src_return_reqd = ''N''
          and    cit.non_src_reference_reqd = ''N''
          and    ctt.source_transaction_type = ''FIELD_SERVICE_REPORT''
          and    ctt.source_application_id = 513
          and    cis.instance_status_id(+) = cit.src_status_id
          and    cis.terminated_flag(+) <> ''Y''';
*/

    --CSM_OBJECT_MAPPINGS
    i := i +1;
    g_acc_refresh_desc_tbl.EXTEND;
    g_acc_refresh_desc_tbl(i).BACKEND_TABLE_NAME    := 'JTF_OBJECT_MAPPINGS';
    g_acc_refresh_desc_tbl(i).ACC_TABLE_NAME        := 'CSM_OBJECT_MAPPINGS_ACC';
    g_acc_refresh_desc_tbl(i).ACC_SEQUENCE_NAME     := 'CSM_OBJECT_MAPPINGS_ACC_S';
    g_acc_refresh_desc_tbl(i).PRIMARY_KEY_COLUMN    := 'MAPPING_ID';
    g_acc_refresh_desc_tbl(i).PUBLICATION_ITEM_NAME := 'CSF_M_OBJECT_MAPPINGS';
    g_acc_refresh_desc_tbl(i).ACCESS_QUERY :=
       'select jom.mapping_id
        from jtf_object_mappings jom
        WHERE jom.source_object_code IN (''PARTY'', ''TASK'', ''SR'', ''CP'',''OKS_COV_NOTE'',''SD'')
        AND NVL(jom.end_date, SYSDATE) >= SYSDATE';

 END IF;
NULL;
END initialize_g_table_desc_tbl;


/**
 Returns the record representing the information needed
 to refresh/sync an acc table with backend

 Arguments:
   p_acc_table_name : the ACC table name for which the refresh information
     is to be retrieved

 Return Value: the record representing the information needed
 to refresh/sync an acc table with backend
 */
function get_Acc_Refresh_Desc_Rec(p_acc_table_name varchar2)
return Acc_Refresh_Desc_Rec_Type
IS
BEGIN

FOR i IN 1 .. g_acc_refresh_desc_tbl.COUNT LOOP
  IF (g_acc_refresh_desc_tbl(i).ACC_TABLE_NAME = p_acc_table_name) THEN
    RETURN g_acc_refresh_desc_tbl(i);
  END IF;
END LOOP;

RAISE g_element_not_found_exception;

END get_Acc_Refresh_Desc_Rec;


FUNCTION get_all_omfs_palm_user_list RETURN asg_download.user_list
IS
i NUMBER;
l_all_omfs_palm_users_list asg_download.user_list;

  CURSOR l_omfs_palm_users_csr
  IS
  SELECT usr.USER_ID
  FROM   asg_user_pub_resps		pubresp
   ,     asg_user               usr
  WHERE  usr.enabled = 'Y'
  AND    pubresp.user_name = usr.user_name
  AND	 pubresp.pub_name ='SERVICEP';
  --Cursor when data routed to owner profile is set
  CURSOR l_route_omfs_palm_users_csr
  IS
  SELECT usr.USER_ID
  FROM   asg_user_pub_resps		pubresp
   ,     asg_user               usr
  WHERE  usr.enabled = 'Y'
  AND    pubresp.user_name = usr.user_name
  AND	 pubresp.pub_name ='SERVICEP'
  AND    usr.USER_ID = usr.OWNER_ID;
BEGIN
  i := 0;
  IF csm_profile_pkg.Get_Route_Data_To_Owner ='Y' THEN
    FOR r_omfs_palm_users_rec IN l_route_omfs_palm_users_csr LOOP
                  i := i + 1;
                  l_all_omfs_palm_users_list(i) := r_omfs_palm_users_rec.user_id;
    END LOOP;
  ELSE
    FOR r_omfs_palm_users_rec IN l_omfs_palm_users_csr LOOP
                  i := i + 1;
                  l_all_omfs_palm_users_list(i) := r_omfs_palm_users_rec.user_id;
    END LOOP;
  END IF;

RETURN l_all_omfs_palm_users_list;

END get_all_omfs_palm_user_list;

/**
 Returns the list containing the RESOURCE_ID of all the OMFS Palm Users
 */
FUNCTION get_all_omfs_palm_res_list RETURN asg_download.user_list
IS
i NUMBER;
l_all_omfs_palm_resource_list asg_download.user_list;

CURSOR l_omfs_palm_resources_csr
IS
SELECT usr.resource_id
FROM   asg_user_pub_resps	pubresp
 ,     asg_user             usr
WHERE  usr.enabled 			= 'Y'
AND    pubresp.user_name 	= usr.user_name
AND	   pubresp.pub_name 	= 'SERVICEP';

CURSOR l_route_omfs_palm_res_csr
IS
SELECT usr.resource_id
FROM   asg_user_pub_resps	pubresp
 ,     asg_user             usr
WHERE  usr.enabled 			= 'Y'
AND    pubresp.user_name 	= usr.user_name
AND    pubresp.pub_name 	= 'SERVICEP'
AND    usr.USER_ID = usr.OWNER_ID;

BEGIN
  i := 0;
  IF csm_profile_pkg.Get_Route_Data_To_Owner ='Y' THEN
      FOR r_omfs_palm_resource_rec IN l_route_omfs_palm_res_csr LOOP
                    i := i + 1;
                    l_all_omfs_palm_resource_list(i) := r_omfs_palm_resource_rec.resource_id;
      END LOOP;
  ELSE
      FOR r_omfs_palm_resource_rec IN l_omfs_palm_resources_csr LOOP
                    i := i + 1;
                    l_all_omfs_palm_resource_list(i) := r_omfs_palm_resource_rec.resource_id;
      END LOOP;
  END IF;

RETURN l_all_omfs_palm_resource_list;

END get_all_omfs_palm_res_list;


Function GetLocalTime(p_server_time date, p_userid number)
return date
is
v_client_timezone varchar2(100);
v_server_timezone varchar2(100);
client_time date;

begin
v_client_timezone := FND_PROFILE.VALUE_SPECIFIC('HZ_CLIENT_TIMEZONE',p_userid,NULL,170);


v_server_timezone := FND_PROFILE.VALUE_SPECIFIC('HZ_SERVER_TIMEZONE',NULL,NULL,170);


if v_client_timezone is null
or v_server_timezone is null
then
return p_server_time;

else

client_time := p_server_time - (v_server_timezone - v_client_timezone);

END if;

return client_time;

   -- Enter further code below as specified in the Package spec.
END GetLocalTime;

Function GetLocalTime(p_server_time date, p_user_name varchar2)
return date
is
cursor c_user_id (p_user_name varchar2)
is
  select user_id
  from asg_user
  where user_name = p_user_name;

l_user_id asg_user.user_id%TYPE;

begin

--select user_id into l_user_id
--from asg_user
--where user_name = p_user_name;

OPEN c_user_id(p_user_name);
FETCH c_user_id INTO l_user_id;
CLOSE c_user_id;

return GetLocalTime(p_server_time, l_user_id);

END GetLocalTime;

Function GetServerTime(p_client_time date, p_user_name varchar2)
return date
is
cursor c_user_id (p_user_name varchar2)
is
  select user_id
  from asg_user
  where user_name = p_user_name;

l_user_id asg_user.user_id%TYPE;

v_client_timezone varchar2(100);
v_server_timezone varchar2(100);
l_server_time date;

begin

--select user_id into l_user_id
--from asg_user
--where user_name = p_user_name;

OPEN c_user_id(p_user_name);
FETCH c_user_id INTO l_user_id;
CLOSE c_user_id;

v_client_timezone := FND_PROFILE.VALUE_SPECIFIC('HZ_CLIENT_TIMEZONE',l_user_id,NULL,170);


v_server_timezone := FND_PROFILE.VALUE_SPECIFIC('HZ_SERVER_TIMEZONE',NULL,NULL,170);


if v_client_timezone is null
or v_server_timezone is null
then
return p_client_time;

else

l_server_time := p_client_time - (v_client_timezone - v_server_timezone);

END if;

return l_server_time;

END GetServerTime;



Function Get_Responsibility_ID(p_userid in number)
RETURN NUMBER
IS
/********************************************************
 Name:
   GET_RESPONSIBILITY_ID

 Purpose:
   Get the responsibility id to determine the rule_id for
   the state_transitions

 Arguments:

 Known Limitations:
   - Because we check on rule_id this function is only usable
     for jtf_state_transitions

 Notes:
   Following rules are implemented:
   1 ) User has no responsibility
       - Get the profile value

   2) User has one responsibility with a matching rule_id:
      - Use this responsibility_id

   3) User has multiple responsibilities:
      - Check if all responsibilities have the same set of rules,
      a) if this is the case then use one of these responsibilities,
         when a responisibility has no rules we don't count this
      b) if not, use the profile


********************************************************/

  l_resp_id NUMBER;
  l_rule_id NUMBER;

  l_cnt_resp NUMBER;
  l_cnt_rule NUMBER;

  l_responsibility_id NUMBER;
  l_diff BOOLEAN;
  l_last_rec BOOLEAN;

  TYPE RULE_TABLE_TYPE IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;
  RULE_TABLE RULE_TABLE_TYPE;

CURSOR C_USER_RESP ( p_user_id NUMBER ) IS
 SELECT RESPONSIBILITY_ID
 FROM   FND_USER_RESP_GROUPS
 WHERE  NVL( START_DATE , SYSDATE) <= SYSDATE
 AND    NVL( END_DATE ,   SYSDATE) >= SYSDATE
 AND    USER_ID = p_user_id;

CURSOR C_STATE_RULE ( p_resp_id NUMBER ) IS
 SELECT RULE_ID
 FROM JTF_STATE_RESPONSIBILITIES
 WHERE RESPONSIBILITY_ID = p_resp_id ;

BEGIN
  l_cnt_resp := 0;
  l_diff := FALSE;
  l_responsibility_id := NULL;
  /* Fetch all responsibility ids */
  FOR r_resp_record  IN C_USER_RESP( p_userid) LOOP
    l_resp_id := r_resp_record.RESPONSIBILITY_ID;
    l_cnt_resp := l_cnt_resp + 1;
    /*Check if the responsibility has state rules*/
    l_last_rec := FALSE;
    l_cnt_rule := 0;
    OPEN C_STATE_RULE( p_resp_id => l_resp_id );
    WHILE l_diff <> TRUE AND l_last_rec <> TRUE LOOP
      FETCH C_STATE_RULE INTO l_rule_id;
      IF C_STATE_RULE%NOTFOUND THEN
        l_last_rec := TRUE;
      ELSE
       l_cnt_rule := l_cnt_rule + 1;
       /* Check if this is the first time we check/ fill the pl/sql table */
       IF RULE_TABLE.EXISTS( 1 ) AND l_responsibility_id IS NOT NULL THEN
         /* Pl/sql table already filled, compare rule id with table value */
         /* Because we sort this is ok */
         /* First check if our current record set isn't larger than the table record set */
        /* RAVIR Added for loop as sort by is removed Jan 6, 2003 */
	FOR i in 1..l_cnt_rule LOOP
         IF RULE_TABLE.EXISTS( i ) THEN
           IF RULE_TABLE(i) <> l_rule_id THEN
             /* ids are different, so use the profile */
             l_diff := TRUE;
           END IF;
         --ELSE
          -- l_diff := TRUE;
         END IF;
       END LOOP ;
       ELSE
	 /* First time, so fill the Pl/sql table */
         RULE_TABLE(l_cnt_rule) := l_rule_id;
       END IF;
      END IF;
    END LOOP;
    CLOSE C_STATE_RULE;
    IF l_cnt_rule <> 0 THEN
     /* Set l_responsibility_id, we have a valid responsibility id with state rule(s)*/
     l_responsibility_id := l_resp_id;
    END IF;
  END LOOP;
  IF l_diff = TRUE OR l_responsibility_id IS NULL THEN
    /* No responsibility found or rules per responisibilities are different, get profileval */
    l_responsibility_id := CSM_PROFILE_PKG.GetDefaultStatusResponsibility(p_userid);
  END IF;
  return l_responsibility_id;
END GET_RESPONSIBILITY_ID;


/*
  Modified by :
  Ravi Ranjan 06/19/2002:

  l_value := wf_engine.GetActivityAttrNumber(..)

  Replaced By:
  l_value := wf_engine.GetActivityAttrText(..)
*/

Function MakeDirtyForUser ( p_publication_item in varchar2,
							p_accessList in number,  --1 access_id
							p_resourceList in number,  --1 user_id
							p_dmlList in char,
							p_timestamp in date)
return boolean
is
l_markdirty	boolean;
l_resourcelist number;

cursor l_rs_resource_extns_csr (p_user_id fnd_user.user_id%type) is
select resource_id
from  jtf_rs_resource_extns
where user_id = p_user_id
AND   SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
AND   NVL(end_date_active, SYSDATE)
;

begin
	 -- getthe resource_id, since make dirty requires resource_id
	open l_rs_resource_extns_csr(p_resourcelist);
	fetch l_rs_resource_extns_csr into l_resourcelist;
	close l_rs_resource_extns_csr;
	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  l_resourcelist,
										  p_dmllist,
										  p_timestamp);
	return l_markdirty;
end;

Function MakeDirtyForUser ( p_publication_item in varchar2,
							p_accessList in asg_download.access_list,
							p_resourceList in asg_download.user_list,
							p_dmlList in asg_download.dml_list,
							p_timestamp in date)
return boolean
is
l_markdirty	boolean;
l_resourcelist asg_download.user_list;

cursor l_rs_resource_extns_csr (p_user_id fnd_user.user_id%type) is
select resource_id
from jtf_rs_resource_extns
where user_id = p_user_id
AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
AND NVL(end_date_active, SYSDATE)
;

begin


	if p_resourcelist.count > 0 then
	   for l_ind in 1..p_resourcelist.count loop
	   	 -- getthe resource_id, since make dirty requires resource_id
		 	open l_rs_resource_extns_csr(p_resourcelist(l_ind));
			fetch l_rs_resource_extns_csr into l_resourcelist(l_ind);
			close l_rs_resource_extns_csr;
	   end loop;
    end if;

	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  l_resourcelist,
										  p_dmllist,
										  p_timestamp);

	return l_markdirty;

end;


Function MakeDirtyForUser ( p_publication_item in varchar2,
							p_accessList in asg_download.access_list,
							p_resourceList in asg_download.user_list,
							p_dmlList in char,
							p_timestamp in date)
return boolean
is
l_markdirty	boolean;
l_resourcelist asg_download.user_list;

cursor l_rs_resource_extns_csr (p_user_id fnd_user.user_id%type) is
select resource_id
from jtf_rs_resource_extns
where user_id = p_user_id
AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
AND NVL(end_date_active, SYSDATE)
;

BEGIN
	if p_accesslist.count > 0 THEN
	   for l_ind in 1..p_resourcelist.count LOOP
	   	 -- getthe resource_id, since make dirty requires resource_id
		 	open l_rs_resource_extns_csr(p_resourcelist(l_ind));
 			fetch l_rs_resource_extns_csr into l_resourcelist(l_ind);
	 		close l_rs_resource_extns_csr;
	   end loop;
 end if;

--logm('Before markdirty:' || 'pub:' || p_publication_item || 'access_id:' || p_accesslist(0) || ' ' || l_resourcelist(0) );

IF p_accesslist.count > 0 THEN
	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  l_resourcelist,
										  p_dmllist,
										  p_timestamp);
	return l_markdirty;

END IF;
end;

FUNCTION MakeDirtyForUser(p_publication_item in varchar2,
							    p_accessList in number,
							    p_resourceList in number,
							    p_dmlList in char,
							    p_timestamp in date,
           p_pkvalueslist IN asg_download.pk_list)
RETURN BOOLEAN
IS
l_markdirty	boolean;
l_resourcelist number;

cursor l_rs_resource_extns_csr (p_user_id fnd_user.user_id%type) is
select resource_id
from jtf_rs_resource_extns
where user_id = p_user_id
AND SYSDATE BETWEEN NVL(start_date_active, SYSDATE)
AND NVL(end_date_active, SYSDATE);

BEGIN
	 -- getthe resource_id, since make dirty requires resource_id
	open l_rs_resource_extns_csr(p_resourcelist);
	fetch l_rs_resource_extns_csr into l_resourcelist;
	close l_rs_resource_extns_csr;

	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  l_resourcelist,
										  p_dmllist,
										  p_timestamp,
            p_pkvalueslist);
	return l_markdirty;

END MakeDirtyForUser;


Function MakeDirtyForResource ( p_publication_item in varchar2,
							    p_accessList in asg_download.access_list,
							    p_resourceList in asg_download.user_list,
							    p_dmlList in char,
							    p_timestamp in date)
return boolean
is
l_markdirty	boolean;

begin

	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  p_resourcelist,
										  p_dmllist,
										  p_timestamp);
	return l_markdirty;

end MakeDirtyForResource;

Function MakeDirtyForResource ( p_publication_item in varchar2,
							    p_accessList in number,
							    p_resourceList in number,
							    p_dmlList in char,
							    p_timestamp in date)
return boolean
is
l_markdirty	boolean;

begin

	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  p_resourcelist,
										  p_dmllist,
										  p_timestamp);
	return l_markdirty;

end MakeDirtyForResource;

FUNCTION MakeDirtyForResource(p_publication_item in varchar2,
							    p_accessList in number,
							    p_resourceList in number,
							    p_dmlList in char,
							    p_timestamp in date,
           p_pkvalueslist IN asg_download.pk_list)
RETURN BOOLEAN
IS
l_markdirty	boolean;

BEGIN
	l_markdirty := asg_download.MarkDirty(p_publication_item,
										  p_accesslist,
										  p_resourcelist,
										  p_dmllist,
										  p_timestamp,
            p_pkvalueslist);

 	return l_markdirty;

END MakeDirtyForResource;


FUNCTION GetAsgDmlConstant( p_dml in char)
return char
is
/********************************************************
 Name:
   GetAsgDmlConstant

 Purpose:
   Converts the DML constants defined in Workflows to the ones
   understood by ASG. Presently, both the constant sets are same.

 Arguments:
   p_dml: DML constant defined in WorkFlow

 Returns:
   DML constant understood by ASG

 Exceptions:
   g_invalid_argument_exception:
     In case the passed parameter dml type is not in ('I', 'U', 'D')

*********************************************************/
begin
  --convert the passed parameter to one of the ASG constants
  if (p_dml = 'I') then
      return ASG_DOWNLOAD.INS;
  elsif (p_dml = 'U') then
      return ASG_DOWNLOAD.UPD;
  elsif (p_dml = 'D') then
      return ASG_DOWNLOAD.DEL;
  --In case the passed parameter dml type is not in ('I', 'U', 'D')
  --throw invalid argument exception
  else raise g_invalid_argument_exception;
  end if;
end;

/**
*  Check if the passed resource is a palm resource
*/

FUNCTION is_palm_resource(p_resource_id IN NUMBER)
RETURN BOOLEAN
IS
CURSOR l_is_palm_resource_csr(p_resource_id IN jtf_rs_resource_extns.resource_id%TYPE)
IS--R12 on multiple responsibility
SELECT 1
FROM   asg_user_pub_resps	pubresp
 ,     asg_user             usr
WHERE  usr.enabled 			= 'Y'
AND    pubresp.user_name 	= usr.user_name
AND	   pubresp.pub_name 	= 'SERVICEP'
AND    usr.resource_id 		= p_resource_id;

/*CURSOR l_is_palm_resource_csr(p_resource_id IN jtf_rs_resource_extns.resource_id%type)
IS
  select  fnd_user_resp.user_id
  from    asg_pub_responsibility   asg_resp,
          asg_pub,
          fnd_user_resp_groups  fnd_user_resp,
          fnd_application  fnd_app,
          jtf_rs_resource_extns  res
  where   asg_resp.pub_id = asg_pub.pub_id
  and     asg_pub.name = 'SERVICEP'
  and     asg_resp.responsibility_id =  fnd_user_resp.responsibility_id
  and     fnd_app.application_id = fnd_user_resp.responsibility_application_id
  and     fnd_user_resp.user_id = res.user_id
  AND     SYSDATE BETWEEN nvl(fnd_user_resp.start_date, sysdate) AND nvl(fnd_user_resp.end_date, sysdate)
  and     fnd_app.application_short_name = 'CSM'
  and     res.resource_id = p_resource_id;
*/
l_is_palm_resource_rec l_is_palm_resource_csr%ROWTYPE;

BEGIN
   OPEN l_is_palm_resource_csr(p_resource_id);
   FETCH l_is_palm_resource_csr INTO l_is_palm_resource_rec;
   IF l_is_palm_resource_csr%FOUND THEN
      CLOSE l_is_palm_resource_csr;
      RETURN TRUE;
   ELSE
      CLOSE l_is_palm_resource_csr;
      RETURN FALSE;
   END IF;

EXCEPTION
  WHEN OTHERS THEN
   IF l_is_palm_resource_csr%ISOPEN THEN
      CLOSE l_is_palm_resource_csr;
   END IF;
END is_palm_resource;

FUNCTION is_palm_user(p_user_id IN NUMBER)
RETURN BOOLEAN
IS
CURSOR l_responsibilities_csr (b_user_id NUMBER)--R12 For multiple responsibility
IS
SELECT 1
FROM   asg_user_pub_resps	pubresp
 ,     asg_user             usr
WHERE  usr.enabled 			= 'Y'
AND    pubresp.user_name 	= usr.user_name
AND	   pubresp.pub_name 	= 'SERVICEP'
AND    usr.user_id 			= b_user_id;


/*  cursor l_responsibilities_csr (b_user_id number) is
    select    fnd_user_resp.user_id
    from    asg_pub_responsibility   asg_resp,
          asg_pub,
          fnd_user_resp_groups  fnd_user_resp,
          fnd_application  fnd_app
    where   asg_resp.pub_id = asg_pub.pub_id
      and     asg_pub.name = 'SERVICEP'
      and     asg_resp.responsibility_id =  fnd_user_resp.responsibility_id
      and     fnd_app.application_id = fnd_user_resp.responsibility_application_id
      and     fnd_app.application_short_name = 'CSM'
      and     fnd_user_resp.user_id = p_user_id
      AND     SYSDATE BETWEEN nvl(fnd_user_resp.start_date, sysdate) AND nvl(fnd_user_resp.end_date, sysdate)
  ;
*/
  l_responsibilities_rec l_responsibilities_csr%ROWTYPE;
BEGIN
    open l_responsibilities_csr (p_user_id);
    fetch l_responsibilities_csr into l_responsibilities_rec;
    if (l_responsibilities_csr%notfound) then
      close l_responsibilities_csr;
      RETURN FALSE;
    else --intersection is non-void
      close l_responsibilities_csr;
      RETURN TRUE;
    end if;
    --close the cursor
EXCEPTION
   WHEN OTHERS THEN
     --close the cursor if open
     if (l_responsibilities_csr%isopen) then
       close l_responsibilities_csr;
     end if;
     RAISE;
END is_palm_user;

function get_tl_omfs_palm_users(p_language varchar2)
  return asg_download.user_list
AS

l_tl_omfs_palm_users_list asg_download.user_list;
i NUMBER;

CURSOR l_tl_omfs_palm_users_csr is
--R12 For multiple responsibility
   select usr.USER_ID
   FROM  asg_user_pub_resps		pubresp
   ,     asg_user               usr
   WHERE usr.LANGUAGE = p_language
   AND   usr.enabled = 'Y'
   AND   pubresp.user_name = usr.user_name
   AND	 pubresp.pub_name ='SERVICEP';

CURSOR l_route_tl_omfs_palm_users_csr is
--R12 For multiple responsibility
   select usr.USER_ID
   FROM  asg_user_pub_resps		pubresp
   ,     asg_user               usr
   WHERE usr.LANGUAGE = p_language
   AND   usr.enabled = 'Y'
   AND   pubresp.user_name = usr.user_name
   AND	 pubresp.pub_name ='SERVICEP'
   AND   usr.USER_ID = usr.OWNER_ID;
BEGIN
  i := 0;
  IF csm_profile_pkg.Get_Route_Data_To_Owner ='Y' THEN
      FOR r_tl_omfs_palm_users_rec in l_route_tl_omfs_palm_users_csr LOOP
                    i := i + 1;
                    l_tl_omfs_palm_users_list(i) := r_tl_omfs_palm_users_rec.user_id;
      END LOOP;
  ELSE
      FOR r_tl_omfs_palm_users_rec in l_tl_omfs_palm_users_csr LOOP
                    i := i + 1;
                    l_tl_omfs_palm_users_list(i) := r_tl_omfs_palm_users_rec.user_id;
      END LOOP;
  END IF;
  return l_tl_omfs_palm_users_list;

END get_tl_omfs_palm_users;

function get_tl_omfs_palm_resources(p_language varchar2)
  return asg_download.user_list
AS

l_tl_omfs_palm_resource_list asg_download.user_list;
i NUMBER;

CURSOR l_tl_omfs_palm_resources_csr is
--R12 For multiple responsibility
   select usr.RESOURCE_ID
   FROM  asg_user_pub_resps		pubresp
   ,     asg_user               usr
   WHERE usr.LANGUAGE = p_language
   AND   usr.enabled = 'Y'
   AND   pubresp.user_name = usr.user_name
   AND	 pubresp.pub_name ='SERVICEP';

CURSOR l_route_tl_omfs_palm_res_csr is
--R12 For multiple responsibility
   select usr.RESOURCE_ID
   FROM  asg_user_pub_resps		pubresp
   ,     asg_user               usr
   WHERE usr.LANGUAGE = p_language
   AND   usr.enabled = 'Y'
   AND   pubresp.user_name = usr.user_name
   AND	 pubresp.pub_name ='SERVICEP'
   AND   usr.USER_ID = usr.OWNER_ID;
BEGIN
  i := 0;
  IF csm_profile_pkg.Get_Route_Data_To_Owner ='Y' THEN
      FOR r_tl_omfs_palm_resource_rec in l_route_tl_omfs_palm_res_csr LOOP
                    i := i + 1;
                    l_tl_omfs_palm_resource_list(i) := r_tl_omfs_palm_resource_rec.resource_id;
      END LOOP;
  ELSE
      FOR r_tl_omfs_palm_resource_rec in l_tl_omfs_palm_resources_csr LOOP
                    i := i + 1;
                    l_tl_omfs_palm_resource_list(i) := r_tl_omfs_palm_resource_rec.resource_id;
      END LOOP;
  END IF;

  return l_tl_omfs_palm_resource_list;

END get_tl_omfs_palm_resources;

/* get language for the specified user_id */
FUNCTION get_user_language(p_user_id IN NUMBER)
return VARCHAR2
IS
CURSOR c_language_csr(p_user_id number) IS
SELECT language
FROM asg_user
WHERE user_id = p_user_id;

l_language asg_user.language%TYPE;

BEGIN
   OPEN c_language_csr(p_user_id);
   FETCH c_language_csr INTO l_language;
   CLOSE c_language_csr;

   RETURN l_language;

END get_user_language;

FUNCTION get_user_name(p_user_id IN number)
RETURN varchar2
IS
l_user_name asg_user.user_name%TYPE;

CURSOR l_get_user_name(p_user_id IN number)
IS
SELECT user_name
FROM asg_user
WHERE user_id = p_user_id;

BEGIN
  OPEN l_get_user_name(p_user_id);
  FETCH l_get_user_name INTO l_user_name;
  CLOSE l_get_user_name;

  RETURN l_user_name;
END get_user_name;

/**
   Refreshes the specified application level ACC tables
   Also adds the entries in the System Dirty Queue for all the
   OMFS Palm users if the entry gets updated, deleted or inserted in the ACC table
*/
PROCEDURE refresh_app_level_acc (
  p_backend_table_name varchar2,
  p_primary_key_column varchar2,
  p_acc_table_name varchar2,
  p_acc_sequence_name varchar2,
  p_tl_table_name varchar2,
  p_publication_item_name varchar2,
  p_access_query varchar2,
  p_primary_key_value number)

IS
l_access_id number;
l_pk_value  number;
l_last_update_date date;
l_prev_language varchar2(24);
l_language varchar2(24);

l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_acc_table_name varchar2(30);
l_acc_sequence_name varchar2(50);
l_backend_table_name varchar2(30);
l_tl_table_name varchar2(30);
l_primary_key_column varchar2(30);
l_publication_item_name varchar2(30);
l_access_query varchar2(2048);
l_primary_key_value number;

l_dsql varchar2(2048);
l_upd_dsql varchar2(1024);
l_cursorid NUMBER;
l_result NUMBER;

l_changed_records_cur Changed_Records_Cur_Type;

l_tl_omfs_palm_resource_list asg_download.user_list;
l_all_omfs_palm_resource_list asg_download.user_list;
--contains the same access ID n times (where n = number of users for which
--to insert into SDQ)
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;

i NUMBER;
l_mark_dirty BOOLEAN;

begin --refresh_app_level_acc
    l_backend_table_name    := p_backend_table_name;
    l_primary_key_column    := p_primary_key_column;
    l_acc_table_name        := p_acc_table_name;
    l_acc_sequence_name     := p_acc_sequence_name;
    l_tl_table_name         := p_tl_table_name;
    l_publication_item_name := p_publication_item_name;
    l_access_query          := p_access_query;
    l_primary_key_value     := p_primary_key_value;

    --initialize the list of all omfs palm resources
    l_all_omfs_palm_resource_list := get_all_omfs_palm_res_list;


    /********** DELETES *****************/
   --Delete deleted entries in backend from the ACC

 IF l_primary_key_value IS NULL THEN
   -- Mark Dirty 'D' the SDQ
    l_dsql :=
         ' SELECT access_id '
      ||   ' FROM '
      ||   l_acc_table_name
      ||   ' WHERE '
      ||       l_primary_key_column
      ||       ' not in ( '
      ||           l_access_query
      ||   ' )';

      open l_changed_records_cur for l_dsql;

      LOOP
        FETCH l_changed_records_cur INTO l_access_id;
        EXIT WHEN l_changed_records_cur%NOTFOUND;
        -- process data record
        --add for all the users into the SDQ
        --nullify the access list
        l_single_access_id_list := l_null_access_list;
        i := 0;

        FOR i in 1 .. l_all_omfs_palm_resource_list.COUNT LOOP
          l_single_access_id_list(i) := l_access_id;
        END LOOP;
        --mark dirty the SDQ
        l_mark_dirty := MakeDirtyForResource(l_publication_item_name,
                         l_single_access_id_list,
                         l_all_omfs_palm_resource_list,
                         ASG_DOWNLOAD.DEL,
                         sysdate);
      END LOOP;


   --generate the sql for deleting removed values from ACC table
   l_dsql :=
         'DELETE FROM '
      || l_acc_table_name
      || ' WHERE access_id '
      || ' IN
         ( '
      || l_dsql
      ||   ' )';

   --open database cursor
   l_cursorid := DBMS_SQL.open_cursor;
   --parse and execute the sql
   DBMS_SQL.parse(l_cursorid, l_dsql, DBMS_SQL.v7);
   l_result := DBMS_SQL.execute(l_cursorid);
   DBMS_SQL.close_cursor (l_cursorid);

 END IF;   --END l_primary_key_value IS NULL (for delete case)

   /********** END DELETES **************/


   /******* UPDATES *********/
   -- a) Updates to non TL table

   l_dsql :=
         ' SELECT '
      ||   ' acc.access_id'
      ||   ' AS ACCESS_ID, b.'
      ||     l_primary_key_column
      ||     ' , b.LAST_UPDATE_DATE
           FROM '
      ||     l_backend_table_name
      ||   ' b ,'
      ||     l_acc_table_name
      ||   ' acc
           WHERE
              b.'
      ||      l_primary_key_column
      ||    ' = acc.'
      ||      l_primary_key_column
      ||    ' AND
              b.LAST_UPDATE_DATE > acc.LAST_UPDATE_DATE'
      ;

     IF l_primary_key_value IS NOT NULL THEN
        l_dsql := l_dsql || ' AND b.' ||  l_primary_key_column || ' = '
            || l_primary_key_value;
     END IF;

      open l_changed_records_cur for l_dsql;

      LOOP
        FETCH l_changed_records_cur INTO l_access_id, l_pk_value, l_last_update_date;
        EXIT WHEN l_changed_records_cur%NOTFOUND;
        -- process data record
        --get the users with this language
        l_tl_omfs_palm_resource_list := get_tl_omfs_palm_resources(l_language);

        --add for all the users into the SDQ
        --nullify the access list
        l_single_access_id_list := l_null_access_list;

        FOR i in 1 .. l_all_omfs_palm_resource_list.COUNT LOOP
          l_single_access_id_list(i) := l_access_id;
        END LOOP;
        --mark dirty the SDQ
        l_mark_dirty := MakeDirtyForResource(l_publication_item_name,
                         l_single_access_id_list,
                         l_all_omfs_palm_resource_list,
                         ASG_DOWNLOAD.UPD,
                         sysdate);

        --update the ACC table
        l_upd_dsql := 'UPDATE ' || l_acc_table_name
            || ' SET LAST_UPDATE_DATE = (SELECT LAST_UPDATE_DATE FROM '
            || l_backend_table_name
            || ' WHERE ' || l_primary_key_column || ' = ' || l_pk_value
            || '), LAST_UPDATED_BY = fnd_global.user_id WHERE '
            ||  ' access_id  = ' || l_access_id;

        --open database cursor
        l_cursorid := DBMS_SQL.open_cursor;
        --parse and execute the sql
        DBMS_SQL.parse(l_cursorid, l_upd_dsql, DBMS_SQL.v7);
        l_result := DBMS_SQL.execute(l_cursorid);
        DBMS_SQL.close_cursor (l_cursorid);

      END LOOP;
    -- END Updates to non TL table


   -- b) Updates to TL table

   IF ( l_tl_table_name IS NOT NULL ) THEN

     l_dsql :=
         ' SELECT acc.access_id, '
      ||   ' b.'
      ||     l_primary_key_column
      ||   ' , b.LAST_UPDATE_DATE, b.LANGUAGE
           FROM '
      ||     l_tl_table_name
      ||   ' b ,'
      ||     l_acc_table_name
      ||   ' acc
           WHERE
              b.'
      ||      l_primary_key_column
      ||    ' = acc.'
      ||      l_primary_key_column
      ||    ' AND
              b.LAST_UPDATE_DATE > acc.LAST_UPDATE_DATE'
      ;

      IF l_primary_key_value IS NOT NULL THEN
        l_dsql := l_dsql || ' AND b.' ||  l_primary_key_column || ' = '
            || l_primary_key_value;
      END IF;

      open l_changed_records_cur for l_dsql;

      LOOP
        FETCH l_changed_records_cur INTO l_access_id, l_pk_value, l_last_update_date, l_language;
        EXIT WHEN l_changed_records_cur%NOTFOUND;
        -- process data record
        --add for the users with same language as the language in TL into the SDQ
        l_tl_omfs_palm_resource_list := get_tl_omfs_palm_resources (l_language);
        --nullify the access list
        l_single_access_id_list := l_null_access_list;
        FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
          l_single_access_id_list(i) := l_access_id;
        END LOOP;
        --mark dirty the SDQ
        l_mark_dirty := MakeDirtyForResource(l_publication_item_name,
                         l_single_access_id_list,
                         l_tl_omfs_palm_resource_list,
                         ASG_DOWNLOAD.UPD,
                         sysdate);

        --update the ACC table
        l_upd_dsql := 'UPDATE ' || l_acc_table_name
            || ' SET LAST_UPDATE_DATE = (SELECT LAST_UPDATE_DATE FROM '
            || l_tl_table_name
            || ' WHERE ' || l_primary_key_column || ' = ' || l_pk_value
            || '), LAST_UPDATED_BY = fnd_global.user_id WHERE '
            || ' access_id = ' || l_access_id;

        --open database cursor
        l_cursorid := DBMS_SQL.open_cursor;
        --parse and execute the sql
        DBMS_SQL.parse(l_cursorid, l_upd_dsql, DBMS_SQL.v7);
        l_result := DBMS_SQL.execute(l_cursorid);
        DBMS_SQL.close_cursor (l_cursorid);

      END LOOP;

   END IF; --END IF l_tl_table_name is not null

   /******* END UPDATES ****/

   /******* INSERTS *******/
    --Insert new entries in backend to the SDQ and ACC

    -- Mark Dirty 'I' the SDQ
    l_dsql :=
         ' SELECT '
      ||     l_acc_sequence_name || '.nextval, '
      ||     l_primary_key_column
      ||   ' FROM '
      ||       l_backend_table_name
      ||   ' WHERE '
      ||       l_primary_key_column
      ||       ' in ( '
      ||       l_access_query
      ||       ' ) AND '
      ||       l_primary_key_column
      ||       ' not in
               ( SELECT '
      ||           l_primary_key_column
      ||       ' FROM '
      ||           l_acc_table_name
      ||   ' )';


      IF l_primary_key_value IS NOT NULL THEN
        l_dsql := l_dsql || ' AND ' ||  l_primary_key_column || ' = '
            || l_primary_key_value;
     END IF;

      open l_changed_records_cur for l_dsql;

      LOOP
        FETCH l_changed_records_cur INTO l_access_id, l_pk_value;
        EXIT WHEN l_changed_records_cur%NOTFOUND;
        -- process data record
        --add for all the users into the SDQ
        --nullify the access list
        l_single_access_id_list := l_null_access_list;
        i := 0;
        FOR i in 1 .. l_all_omfs_palm_resource_list.COUNT LOOP
          l_single_access_id_list(i) := l_access_id;
        END LOOP;

        --mark dirty the SDQ
        l_mark_dirty := MakeDirtyForResource(
            p_publication_item     => l_publication_item_name,
            p_accessList           => l_single_access_id_list,
            p_resourceList         => l_all_omfs_palm_resource_list,
            p_dmlList             => ASG_DOWNLOAD.INS,
            p_timestamp            => sysdate);

    --generate the sql for inserting new values into ACC table
    l_dsql :=
         'INSERT INTO '
      || l_acc_table_name
      || ' ( access_id, '
      || l_primary_key_column
      || ', CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN)
         SELECT ' || l_access_id || ', b.'
      ||   l_primary_key_column
      ||   ', fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           NVL(b.LAST_UPDATE_DATE, sysdate),
           fnd_global.user_id
         FROM '
      ||   l_backend_table_name
      ||   ' b '
      ||   ' WHERE '
      ||       l_primary_key_column
      ||       ' = '
      ||       l_pk_value
      ||       ' AND '
      ||       l_primary_key_column
      ||       ' not in
               ( SELECT '
      ||           l_primary_key_column
      ||       ' FROM '
      ||           l_acc_table_name
      ||   ' )';


     IF l_primary_key_value IS NOT NULL THEN
        l_dsql := l_dsql || ' AND ' ||  l_primary_key_column || ' = '
            || l_primary_key_value;
     END IF;

   --open database cursor
   l_cursorid := DBMS_SQL.open_cursor;
   --parse and execute the sql
   DBMS_SQL.parse(l_cursorid, l_dsql, DBMS_SQL.v7);
   l_result := DBMS_SQL.execute(l_cursorid);
   DBMS_SQL.close_cursor (l_cursorid);

   /********** END INSERTS **************/

   END LOOP;

   EXCEPTION
    WHEN others THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      csm_util_pkg.log('Error in refresh_app_level_acc:' || l_sqlerrno || ':' ||  l_sqlerrmsg);
END refresh_app_level_acc;

/**
   Refreshes all the application level ACC tables
   Also adds the entries in the System Dirty Queue for all the
   OMFS Palm users if the entry gets updated, deleted or inserted in the ACC table
*/
PROCEDURE refresh_all_app_level_acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_dummy number;
l_last_run_date date;

CURSOR l_upd_last_run_date_csr
IS
SELECT 1
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_UTIL_PKG'
AND procedure_name = 'REFRESH_ALL_APP_LEVEL_ACC'
FOR UPDATE OF last_run_date NOWAIT
;

BEGIN
  l_last_run_date := SYSDATE;
  --initialize the table information descriptions
  initialize_g_table_desc_tbl;

  --iterate over all the tables to be refreshed
  FOR i in 1 .. g_acc_refresh_desc_tbl.COUNT LOOP
    refresh_app_level_acc (
      p_backend_table_name => g_acc_refresh_desc_tbl(i).BACKEND_TABLE_NAME,
      p_primary_key_column => g_acc_refresh_desc_tbl(i).PRIMARY_KEY_COLUMN,
      p_acc_table_name => g_acc_refresh_desc_tbl(i).ACC_TABLE_NAME,
      p_acc_sequence_name => g_acc_refresh_desc_tbl(i).ACC_SEQUENCE_NAME,
      p_tl_table_name => g_acc_refresh_desc_tbl(i).TL_TABLE_NAME,
      p_publication_item_name => g_acc_refresh_desc_tbl(i).PUBLICATION_ITEM_NAME,
      p_access_query => g_acc_refresh_desc_tbl(i).ACCESS_QUERY,
      p_primary_key_value => null
      );
  END LOOP;

  -- update last_run_date
  OPEN l_upd_last_run_date_csr;
  FETCH l_upd_last_run_date_csr INTO l_dummy;
  IF l_upd_last_run_date_csr%FOUND THEN
    UPDATE jtm_con_request_data
    SET last_run_date = l_last_run_date
    WHERE CURRENT OF l_upd_last_run_date_csr;
  END IF;
  CLOSE l_upd_last_run_date_csr;

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_UTIL_PKG.refresh_all_app_level_acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_UTIL_PKG.refresh_all_app_level_acc :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_UTIL_PKG.REFRESH_ALL_APP_LEVEL_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END refresh_all_app_level_acc;

/***
  This function returns a translated error message string. If p_api_error is FALSE, it gets
  message with MESSAGE_NAME = p_message from FND_NEW_MESSAGES and replaces any tokens with
  the supplied token values. If p_api_error is TRUE, it just returns the api error in the
  FND_MSG_PUB message stack.
***/
FUNCTION GET_ERROR_MESSAGE_TEXT
         (
           p_api_error      IN BOOLEAN  DEFAULT FALSE
         , p_message        IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE DEFAULT NULL
         , p_token_name1    IN VARCHAR2 DEFAULT NULL
         , p_token_value1   IN VARCHAR2 DEFAULT NULL
         , p_token_name2    IN VARCHAR2 DEFAULT NULL
         , p_token_value2   IN VARCHAR2 DEFAULT NULL
         , p_token_name3    IN VARCHAR2 DEFAULT NULL
         , p_token_value3   IN VARCHAR2 DEFAULT NULL
         )
RETURN VARCHAR2 IS
  l_fnd_message VARCHAR2(4000);
  l_counter     NUMBER;
  l_msg_data    VARCHAR2(2000);
  l_msg_dummy   NUMBER;
BEGIN
  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log ( 'CSM_UTIL_PKG.Get_error_message_text' );
  END IF;

  /*** Is this an API error? ***/
  IF NOT p_api_error THEN
    /*** no -> retrieve error message p_message and replace tokens ***/
    FND_MESSAGE.Set_Name
      ( application => 'CSL'
      , name        => p_message
      );
    IF p_token_name1 IS NOT NULL
    THEN
     FND_MESSAGE.Set_Token
       ( token => p_token_name1
       , value => p_token_value1
       );
    END IF;
    IF p_token_name2 IS NOT NULL
    THEN
      FND_MESSAGE.Set_Token
        ( token => p_token_name2
        , value => p_token_value2
        );
    END IF;
    IF p_token_name3 IS NOT NULL
    THEN
     FND_MESSAGE.Set_Token
       ( token => p_token_name3
       , value => p_token_value3
       );
    END IF;

    l_fnd_message := FND_MESSAGE.Get;
  ELSE
    /*** API error -> retrieve error from message stack ***/
    IF FND_MSG_PUB.Count_Msg > 0 THEN
      FND_MSG_PUB.Get
        ( p_msg_index     => 1
        , p_encoded       => FND_API.G_FALSE
        , p_data          => l_msg_data
        , p_msg_index_out => l_msg_dummy
        );
      l_fnd_message := l_msg_data;
      FOR l_counter
      IN 2 .. FND_MSG_PUB.Count_Msg
      LOOP
        FND_MSG_PUB.Get
          ( p_msg_index     => l_counter
          , p_encoded       => FND_API.G_FALSE
          , p_data          => l_msg_data
          , p_msg_index_out => l_msg_dummy
          );
        l_fnd_message := l_fnd_message || FND_GLOBAL.Newline || l_msg_data;
      END LOOP;
    END IF;
  END IF;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving CSM_UTIL_PKG.Get_error_message_text'
    );
  END IF;
  RETURN l_fnd_message;
EXCEPTION WHEN OTHERS THEN

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    log
    ( 'Exception occurred in CSM_UTIL_PKG.Get_error_message_text:' || ' ' || sqlerrm);
  END IF;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving CSM_UTIL_PKG.Get_error_message_text');
  END IF;

  RETURN l_fnd_message;
END GET_ERROR_MESSAGE_TEXT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure when a record was successfully
  applied and needs to be deleted from the in-queue.
***/
PROCEDURE DELETE_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     OUT NOCOPY VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
l_tracking_id NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Entering  DELETE_RECORD');
    log
    ( 'Check and clear TRACKING deferred record');
  END IF;

-- Remove tracking table record if this record is deferred.
-- reqd if tracking records are reapplied via MFS Admin pages
  IF asg_defer.is_deferred(p_user_name, p_tranid,p_pub_name, p_seqno)=FND_API.G_TRUE THEN
     BEGIN
       SELECT TRACKING_ID INTO l_tracking_id
       FROM CSM_DEFERRED_NFN_INFO
       WHERE DEFERRED_TRAN_ID=p_tranid
       AND   CLIENT_ID=p_user_name
       AND   SEQUENCE = p_seqno
       AND   OBJECT_NAME=p_pub_name
       AND   OBJECT_ID=p_pk;

       CSM_ACC_PKG.Delete_Acc
         ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEFERRED_TRANSACTIONS')
          ,P_ACC_TABLE_NAME         => 'CSM_DEFERRED_TRANSACTIONS_ACC'
          ,P_PK1_NAME               => 'TRACKING_ID'
          ,P_PK1_NUM_VALUE          => l_tracking_id
          ,P_USER_ID                => asg_base.get_user_id(p_user_name)
          );
       DELETE FROM CSM_DEFERRED_NFN_INFO
       WHERE TRACKING_ID=l_tracking_id;
     EXCEPTION
      WHEN OTHERS THEN
       NULL;
     END;
  END IF;

  asg_apply.delete_row(p_user_name,
                       p_tranid,
                       p_pub_name,
                       p_seqno,
                       x_return_status);


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** error occurred ***/
    fnd_msg_pub.Add_Exc_Msg( g_object_name, 'DELETE_RECORD', 'Unknown error');
    p_error_msg := GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    (  'Leaving DELETE_RECORD');
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    log
    ( 'Exception occurred in DELETE_RECORD:' || ' ' || sqlerrm);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'DELETE_RECORD', sqlerrm);
  p_error_msg := GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving DELETE_RECORD');
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END DELETE_RECORD;

/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure
  when a record failed to be processed and needs to be deferred and rejected from mobile.
***/
PROCEDURE DEFER_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2,
           p_dml_type      IN VARCHAR2
         ) IS

CURSOR c_err_msg
IS
SELECT ERROR_DESCRIPTION FROM ASG_DEFERRED_TRANINFO
WHERE DEVICE_USER_NAME = p_user_name
AND   DEFERRED_TRAN_ID = p_tranid
AND   OBJECT_NAME = p_pub_name
AND   SEQUENCE = p_seqno;

l_error_msg VARCHAR2(4000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Entering DEFER_RECORD');
  END IF;

  asg_defer.defer_row(p_user_name,
                      p_tranid,
                      p_pub_name,
                      p_seqno,
                      p_error_msg,
                      x_return_status);
  /*** check if defer was successfull ***/
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** no -> log and return error  ***/
    IF g_debug_level >= CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      log
      ( 'asg_defer.defer_row failed:' || ' ' || p_error_msg
      );
    END IF;

    IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      log
      ( 'Leaving DEFER_RECORD');
    END IF;
    RETURN;
  END IF;


  l_error_msg := p_error_msg;

  IF ( p_error_msg IS NULL) THEN
   OPEN c_err_msg;
   FETCH c_err_msg INTO l_error_msg;
   CLOSE c_err_msg;
  END IF;


/*Removed reject row and replaced with deferred notification and tracking logic*/
  -- 12.1.3
  csm_notification_event_pkg.notify_deferred(p_user_name,p_tranid,
                     p_pub_name,p_seqno, p_dml_type,p_pk,l_error_msg);



  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving DEFER_RECORD');
  END IF;
EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    log
    ( 'Exception occurred in DEFER_RECORD:' || ' ' || sqlerrm);
  END IF;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving DEFER_RECORD');
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END DEFER_RECORD;

/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure
  when the PK of the inserted record is created in the API.
  We need to remove the local PK from local
***/
PROCEDURE REJECT_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Entering REJECT_RECORD');
  END IF;

  asg_defer.reject_row(p_user_name,
                       p_tranid,
                       p_pub_name,
                       p_seqno,
                       p_error_msg,
                       x_return_status);
  /*** check if reject was successfull ***/
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** no -> log error  ***/
    IF g_debug_level >= CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      log
      ( 'asg_defer.reject_row failed:' || ' ' || p_error_msg);
    END IF;
  END IF;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving REJECT_RECORD');
  END IF;
EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    log
    ( 'Exception occurred in REJECT_RECORD:' || ' ' || sqlerrm);
  END IF;

  IF g_debug_level = CSM_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    log
    ( 'Leaving REJECT_RECORD');
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END REJECT_RECORD;

/* Two functions to check if field service palm is enabled. */

FUNCTION IS_FIELD_SERVICE_PALM_ENABLED
RETURN BOOLEAN
IS
  l_option_value VARCHAR2(1);
  l_responsibility_id NUMBER;
  l_application_id  NUMBER;

 CURSOR l_get_resp_id IS
  SELECT resp.APPLICATION_ID, resp.RESPONSIBILITY_ID
  FROM FND_RESPONSIBILITY resp, fnd_application app
  WHERE resp.RESPONSIBILITY_KEY = 'OMFS_PALM'
  AND SYSDATE BETWEEN nvl(resp.start_date, sysdate) AND nvl(resp.end_date, sysdate)
  AND app.application_id = resp.application_id
  AND app.application_short_name = 'CSM';

BEGIN
  OPEN l_get_resp_id;
  FETCH l_get_resp_id INTO l_application_id, l_responsibility_id;
  CLOSE l_get_resp_id;

  l_option_value := fnd_profile.value_specific('JTM_MOB_APPS_ENABLED', null,
                                     l_responsibility_id, l_application_id);

--  CSM_UTIL_PKG.LOG('YL: IS_FIELD_SERVICE_PALM_ENABLED = ' || l_option_value);

  IF ( l_option_value = 'Y' ) THEN
    RETURN TRUE;
  END IF;

  RETURN FALSE;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
--    CSM_UTIL_PKG.LOG('YL: IS_FIELD_SERVICE_PALM_ENABLED EXCEPTION ');
    RETURN FALSE;
  WHEN OTHERS THEN
--    CSM_UTIL_PKG.LOG('YL: IS_FIELD_SERVICE_PALM_ENABLED EXCEPTION ');
    RAISE;
END IS_FIELD_SERVICE_PALM_ENABLED;

  /* GET_TASK_ESC_LEVEL
  */
  FUNCTION GET_TASK_ESC_LEVEL( p_task_id IN NUMBER) RETURN VARCHAR2
  IS
    CURSOR l_esc_csr (b_task_id NUMBER) IS
      SELECT esc.escalation_level
      FROM jtf_tasks_b tasks,
         jtf_task_references_vl ref,
         jtf_tasks_b esc
      WHERE ref.object_id = tasks.task_id
         and ref.object_type_code = 'TASK'
         and ref.reference_code = 'ESC'
         and ref.task_id = esc.task_id
         and esc.source_object_type_code = 'ESC'
         and tasks.task_id = b_task_id;
    l_esc VARCHAR2(30) := NULL;
  BEGIN
    OPEN l_esc_csr (p_task_id);
    FETCH l_esc_csr INTO l_esc;
    IF (l_esc_csr%NOTFOUND) THEN
       l_esc := NULL;
    END IF;
    CLOSE l_esc_csr;
    RETURN l_esc;
  EXCEPTION
    WHEN OTHERS THEN
      CLOSE l_esc_csr;
      RETURN NULL;
  END GET_TASK_ESC_LEVEL;

FUNCTION item_name(p_item_name IN varchar2)
RETURN varchar2
IS
BEGIN
  RETURN p_item_name;
END item_name;

FUNCTION is_flow_history(p_flowtype IN VARCHAR2)
RETURN BOOLEAN
IS
l_err_msg VARCHAR2(4000);

BEGIN
   IF p_flowtype = 'HISTORY' THEN
         RETURN TRUE;
   ELSE
         RETURN FALSE;
   END IF ;

EXCEPTION
   WHEN OTHERS THEN
     l_err_msg := 'Failed csm_util_pkg.is_flow_history : ' || p_flowtype;
     CSM_UTIL_PKG.LOG(l_err_msg, 'CSM_UTIL_PKG.IS_FLOW_HISTORY', FND_LOG.LEVEL_ERROR);
     RETURN FALSE;
END is_flow_history;

FUNCTION get_debrief_header_id(p_debrief_header_id in CSF_DEBRIEF_HEADERS.DEBRIEF_HEADER_ID%TYPE)
RETURN NUMBER
IS
BEGIN
   RETURN p_debrief_header_id;
END get_debrief_header_id;


/*R12-Function to return nullable number type for not null numbers*/
FUNCTION get_number(p_number IN NUMBER)
RETURN NUMBER
IS
BEGIN
   RETURN p_number;
END get_number;

/*R12-Function to return nullable varchar type for not null varchar2*/
FUNCTION get_varchar(p_varchar IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
   RETURN p_varchar;
END get_varchar;

/*R12-Function to return nullable date type for not null date*/
FUNCTION get_date(p_date IN DATE)
RETURN DATE
IS
BEGIN
   RETURN p_date;
END get_date;

/*R12-Function to get owner's full/group name*/
FUNCTION get_owner_name(p_owner_type_code IN VARCHAR2,p_owner_id IN NUMBER,p_language IN VARCHAR2)
RETURN VARCHAR2
IS

 CURSOR c_grp_name(b_grp_id NUMBER,b_lang VARCHAR2) IS
  SELECT TL.GROUP_NAME
  FROM  JTF_RS_GROUPS_B B,
        JTF_RS_GROUPS_TL TL
  WHERE B.GROUP_ID = b_grp_id
  AND   B.GROUP_ID = TL.GROUP_ID
  AND   TL.LANGUAGE=b_lang;

 CURSOR c_owner_name(b_owner_id NUMBER) IS
  SELECT PF.FULL_NAME
  FROM   JTF_RS_RESOURCE_EXTNS RES,
         PER_ALL_PEOPLE_F PF
  WHERE  RES.resource_id = b_owner_id
  AND    RES.SOURCE_ID=PF.PERSON_ID;

l_name JTF_RS_RESOURCE_EXTNS.SOURCE_NAME%TYPE := NULL;

BEGIN
 IF NVL(p_owner_type_code,'NULL')='RS_GROUP' THEN
   OPEN c_grp_name(p_owner_id,p_language);
   FETCH c_grp_name INTO l_name;
   CLOSE c_grp_name;
 ELSIF NVL(p_owner_type_code,'NULL')='RS_EMPLOYEE' THEN
   OPEN c_owner_name(p_owner_id);
   FETCH c_owner_name INTO l_name;
   CLOSE c_owner_name;
 END IF;

 RETURN l_name;

END get_owner_name;

/*to return the notification's Text attribute ignoring if the attribute doesn't exist*/
FUNCTION get_wf_attrText(p_notification_id IN NUMBER,p_attribute IN VARCHAR2)
RETURN VARCHAR2
IS
BEGIN
 RETURN  wf_notification.getAttrText(p_notification_id,p_attribute,true);
END;

FUNCTION Get_Datediff_For_Req_UOM(
							 p_start_date	IN DATE,
							 p_end_date 	IN DATE,
							 p_class    	IN MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE,
							 p_to_uom  		IN CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE,
							 p_min_uom  	IN CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE
							 )
RETURN NUMBER
IS
l_datediffmin	  NUMBER;
l_converted_value NUMBER;
l_conversion_rate NUMBER;
l_base_value      NUMBER;
l_actual_value    NUMBER;
l_uom_min		  CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE;
l_base_uom  	  CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE;
l_base_conversion_rate NUMBER;

--Cursor Declarations
CURSOR c_base_uom(c_uom_class MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE)
IS
SELECT UOM_CODE
FROM   MTL_UNITS_OF_MEASURE
WHERE  UOM_CLASS     = c_uom_class
AND    base_uom_flag = 'Y';

CURSOR c_actual_conversion(c_uom_class MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE,
						   c_convert_to_uom  CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE)
IS
SELECT	conversion_rate
FROM    MTL_UOM_CONVERSIONS
WHERE   UOM_CLASS = c_uom_class
AND		UOM_CODE  = c_convert_to_uom
AND     inventory_item_id = 0;

CURSOR c_base_conversion(c_uom_class MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE,
						   c_convert_to_uom  CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE)
IS
SELECT	conversion_rate
FROM    MTL_UOM_CONVERSIONS
WHERE   UOM_CLASS = c_uom_class
AND		UOM_CODE  = c_convert_to_uom
AND     inventory_item_id = 0;

BEGIN
	--Get the difference in Minutes
	l_datediffmin :=((p_end_date-p_start_date)*24*60);

	OPEN  c_base_uom(p_class);
	FETCH c_base_uom INTO l_base_uom;
	CLOSE c_base_uom;

	OPEN  c_base_conversion(p_class,p_min_uom);
	FETCH c_base_conversion INTO l_base_conversion_rate;
	CLOSE c_base_conversion;

	OPEN  c_actual_conversion(p_class,p_to_uom);
	FETCH c_actual_conversion INTO l_conversion_rate;
	CLOSE c_actual_conversion;

	--converting to base uom
	l_base_value   := l_base_conversion_rate * l_datediffmin;
	--converting to actual uom required
	l_actual_value := l_base_value / l_conversion_rate ;

	RETURN(ROUND(l_actual_value,2));

EXCEPTION
  	WHEN OTHERS THEN
	IF g_debug_level >= CSM_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    	log 	( 'Exception occurred in Get_Datediff_For_Req_UOM :' || ' ' || sqlerrm);
  	END IF;

   	RAISE;

END Get_Datediff_For_Req_UOM;

--12.1
FUNCTION is_mfs_group(p_group_id NUMBER) RETURN BOOLEAN
IS
CURSOR c_mfs_group(b_group_id NUMBER) IS
  SELECT 1
  FROM ASG_USER
  WHERE GROUP_ID=b_group_id;

l_mfs_grp  NUMBER:=0;
BEGIN

OPEN c_mfs_group(p_group_id);
FETCH c_mfs_group INTO l_mfs_grp;
CLOSE c_mfs_group;

IF l_mfs_grp=1 THEN
 RETURN TRUE;
END IF;

RETURN FALSE;
END is_mfs_group;

--12.1
FUNCTION get_group_owner(p_group_id NUMBER) RETURN NUMBER
IS
CURSOR c_group_owner(b_group_id NUMBER) IS
 	SELECT USER_ID
	FROM ASG_USER
	WHERE OWNER_ID=USER_ID
	AND GROUP_ID=b_group_id;

/*
CURSOR c_group_owner(b_group_id NUMBER) IS
 	SELECT USER_ID
	FROM ASG_USER
	WHERE ROLE_CODE  = 'MFS_OWNER'
	AND GROUP_ID=b_group_id;*/

l_grp_owner  NUMBER;
BEGIN

OPEN c_group_owner(p_group_id);
FETCH c_group_owner INTO l_grp_owner;
CLOSE c_group_owner;

RETURN NVL(l_grp_owner,-1);

END get_group_owner;

--12.1
FUNCTION from_same_group(p_member1_resource_id NUMBER,p_member2_resource_id NUMBER) RETURN BOOLEAN
IS
CURSOR c_from_same_group(b_owner NUMBER,b_member NUMBER)
IS
SELECT 1
FROM JTF_RS_GROUP_MEMBERS memG
WHERE RESOURCE_ID = b_member
AND EXISTS (SELECT 1 FROM JTF_RS_GROUP_MEMBERS ownG
            WHERE ownG.GROUP_ID=memG.GROUP_ID
            AND ownG.RESOURCE_ID=b_owner);

l_temp NUMBER :=0;
BEGIN

 OPEN c_from_same_group(p_member1_resource_id,p_member2_resource_id);
 FETCH c_from_same_group INTO l_temp;
 CLOSE c_from_same_group;

 IF l_temp=1 THEN
  RETURN TRUE;
 END IF;

 RETURN FALSE;
END from_same_group;

--function to get owner id for any user
FUNCTION get_owner(p_user_id NUMBER) RETURN NUMBER
IS
 CURSOR c_get_owner(b_user_id NUMBER)
 IS
 SELECT OWNER_ID
 FROM   ASG_USER
 WHERE  USER_ID= p_user_id;

 l_owner_id  NUMBER;
BEGIN

 OPEN c_get_owner(p_user_id);
 FETCH c_get_owner INTO l_owner_id;
 CLOSE c_get_owner;

 RETURN NVL(l_owner_id,-1);

END get_owner;

--12.1 function to get Group name for a group
FUNCTION get_group_name(p_group_id NUMBER, p_language VARCHAR2) RETURN VARCHAR2
IS
 CURSOR c_get_group_name(b_group_id NUMBER, b_language VARCHAR2)
 IS
 SELECT GROUP_NAME--group_desc is a nullable column hence group_name is selected
 FROM   jtf_rs_groups_tl
 WHERE  GROUP_ID = b_group_id
 AND    LANGUAGE = b_language;

 l_group_name  VARCHAR2(60) := NULL;
BEGIN

  IF p_group_id IS NOT NULL THEN
    OPEN  c_get_group_name(p_group_id,p_language);
    FETCH c_get_group_name INTO l_group_name;
    CLOSE c_get_group_name;
  END IF;

 RETURN l_group_name;

END get_group_name;

/*returns True if the asg user name passed is just/being created by mmu*/
FUNCTION is_new_mmu_user(p_user_name IN VARCHAR2) RETURN BOOLEAN
IS
 l_exists NUMBER;
BEGIN

  select 1 INTO l_exists
  from asg_user
  where cookie is not null    --user has not synch'ed yet
  and  enabled ='Y'
  and user_name = p_user_name;

  select 1 INTO l_exists
  from asg_user_pub_resps ar, asg_user au
  where synch_disabled='N'              -- is being created by MMU
  and ar.pub_name='SERVICEP'
  and au.useR_name=ar.user_name
  and au.user_name = p_user_name;

return false;

EXCEPTION
 WHEN Others THEN
  return true;
END is_new_mmu_user;


END CSM_UTIL_PKG;

/
