--------------------------------------------------------
--  DDL for Package Body JTF_AUTH_BULKLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AUTH_BULKLOAD_PKG" as
/* $Header: JTFSEABB.pls 120.1 2005/07/02 02:10:03 appldev ship $ */
procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2
) is
  mapping_id NUMBER;
  p_id 	     NUMBER;
  r_id       NUMBER;
  d_id       NUMBER;
  source_id	     NUMBER;
  cnt	     NUMBER;
  count1     NUMBER;
  maps_sources NUMBER;
  seq	     NUMBER;
  U_USER_NAME VARCHAR2(255);
  U_ROLE_NAME VARCHAR2(255);
begin
  U_USER_NAME := UPPER(USER_NAME);
  U_ROLE_NAME := UPPER(ROLE_NAME);

  select count(*) into cnt
  from fnd_user
  where user_name=U_USER_NAME;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1055');
    app_exception.raise_exception;
  end if;

  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1056');
    app_exception.raise_exception;
  end if;

  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  if cnt=0 then

	select jtf_auth_s1.nextval into seq from dual;
	JTF_AUTH_PRINCIPALS_PKG.INSERT_ROW(seq,seq,1,U_USER_NAME,690,null,1,0,U_USER_NAME, null, SYSDATE, 0, SYSDATE, 0, null);

  end if;

  select count(*) into count1
  from jtf_auth_principal_maps c,
       jtf_auth_principals_b a,
       jtf_auth_domains_b d,
       jtf_auth_principals_b b
  where a.principal_name=U_USER_NAME and a.is_user_flag=1
    and a.jtf_auth_principal_id=c.jtf_auth_principal_id
    and b.principal_name=U_ROLE_NAME and b.is_user_flag=0
    and b.jtf_auth_principal_id=c.jtf_auth_parent_principal_id
    and d.domain_name='CRM_DOMAIN'
    and d.jtf_auth_domain_id=c.jtf_auth_domain_id;

  select jtf_auth_principal_id into p_id
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  select jtf_auth_principal_id into r_id
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  select jtf_auth_domain_id into d_id
  from jtf_auth_domains_b where
  domain_name='CRM_DOMAIN';

  if count1=0 then
	  insert into jtf_auth_principal_maps (jtf_auth_principal_id,
		jtf_auth_parent_principal_id, jtf_auth_domain_id,
		created_by, creation_date, last_updated_by, last_update_date,
		application_id, object_version_number) values
		(p_id, r_id, d_id,
		 0,SYSDATE,0,SYSDATE,690,1);
   end if;

   select jtf_auth_s1.nextval into source_id from dual;

   select jtf_auth_principal_mapping_id into mapping_id
   from jtf_auth_principal_maps
   where jtf_auth_principal_id = p_id
     and jtf_auth_parent_principal_id = r_id
     and jtf_auth_domain_id = d_id;

  select count(*) into maps_sources
  from jtf_auth_maps_sources a
  where a.jtf_auth_principal_mapping_id = mapping_id
  and a.ownertable_name = 'JTF_AUTH_PRINCIPALS_B'
  and a.ownertable_key = TO_CHAR(p_id);

   if maps_sources=0 then
   	insert into jtf_auth_maps_sources (JTF_AUTH_MAPS_SOURCE_ID,
   	JTF_AUTH_PRINCIPAL_MAPPING_ID, OWNERTABLE_NAME, OWNERTABLE_KEY,
	CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
	APPLICATION_ID, OBJECT_VERSION_NUMBER) VALUES
	(source_id, mapping_id,	'JTF_AUTH_PRINCIPALS_B',
          TO_CHAR(p_id), 0, SYSDATE, 0, SYSDATE, 690, 1);
   end if;


end ASSIGN_ROLE;

procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2,
  OWNERTABLE_NAME in VARCHAR2,
  OWNERTABLE_KEY in VARCHAR2
) is
  mapping_id NUMBER;
  p_id 	     NUMBER;
  r_id       NUMBER;
  d_id       NUMBER;
  source_id	     NUMBER;
  cnt	     NUMBER;
  count1     NUMBER;
  maps_sources NUMBER;
  key    NUMBER;
  count2 NUMBER;
  seq	     NUMBER;
  U_USER_NAME VARCHAR2(255);
  U_ROLE_NAME VARCHAR2(255);
  U_OWNERTABLE_NAME VARCHAR2(255);
  table_error EXCEPTION;

begin

  U_USER_NAME := UPPER(USER_NAME);
  U_ROLE_NAME := UPPER(ROLE_NAME);
  U_OWNERTABLE_NAME := UPPER(OWNERTABLE_NAME);
  key := OWNERTABLE_KEY;

  select count(*) into count2
  from fnd_lookups
  where lookup_type = 'JTF_AUTH_OWNERTABLE_NAME'
    and lookup_code = U_OWNERTABLE_NAME;

  if count2=0 then

	RAISE table_error;

  end if;

  select count(*) into cnt
  from fnd_user
  where user_name=U_USER_NAME;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1055');
    app_exception.raise_exception;
  end if;

  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1056');
    app_exception.raise_exception;
  end if;


  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  if cnt=0 then

	select jtf_auth_s1.nextval into seq from dual;
	JTF_AUTH_PRINCIPALS_PKG.INSERT_ROW(seq,seq,1,U_USER_NAME,690,null,1,0,U_USER_NAME, null, SYSDATE, 0, SYSDATE, 0, null);

  end if;

  select count(*) into count1
  from jtf_auth_principal_maps c,
       jtf_auth_principals_b a,
       jtf_auth_domains_b d,
       jtf_auth_principals_b b
  where a.principal_name=U_USER_NAME and a.is_user_flag=1
    and a.jtf_auth_principal_id=c.jtf_auth_principal_id
    and b.principal_name=U_ROLE_NAME and b.is_user_flag=0
    and b.jtf_auth_principal_id=c.jtf_auth_parent_principal_id
    and d.domain_name='CRM_DOMAIN'
    and d.jtf_auth_domain_id=c.jtf_auth_domain_id;

  select jtf_auth_principal_id into p_id
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  select jtf_auth_principal_id into r_id
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  select jtf_auth_domain_id into d_id
  from jtf_auth_domains_b where
  domain_name='CRM_DOMAIN';

  if count1 = 0 then

	insert into jtf_auth_principal_maps (jtf_auth_principal_id,
		jtf_auth_parent_principal_id, jtf_auth_domain_id,
		created_by, creation_date, last_updated_by, last_update_date,
		application_id, object_version_number) values
		(p_id, r_id, d_id,
		 0,SYSDATE,0,SYSDATE,690,1);

  end if;

  select jtf_auth_s1.nextval into source_id from dual;

  select jtf_auth_principal_mapping_id into mapping_id
  from jtf_auth_principal_maps
  where jtf_auth_principal_id = p_id
    and jtf_auth_parent_principal_id = r_id
    and jtf_auth_domain_id = d_id;

  select count(*) into maps_sources
  from jtf_auth_maps_sources a
  where a.jtf_auth_principal_mapping_id = mapping_id
  and a.ownertable_name = U_OWNERTABLE_NAME
  and a.ownertable_key = key;

   if maps_sources=0 then
	  insert into jtf_auth_maps_sources (JTF_AUTH_MAPS_SOURCE_ID,
   	JTF_AUTH_PRINCIPAL_MAPPING_ID, OWNERTABLE_NAME, OWNERTABLE_KEY,
	CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
	APPLICATION_ID, OBJECT_VERSION_NUMBER) VALUES
	(source_id, mapping_id,	U_OWNERTABLE_NAME,
          key, 0, SYSDATE, 0, SYSDATE, 690, 1);
   end if;

exception
  when table_error then
    fnd_message.set_name('JTF', 'JTF-1049');
    app_exception.raise_exception;



end ASSIGN_ROLE;

procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2,
  APP_ID in NUMBER
) is
  mapping_id NUMBER;
  p_id 	     NUMBER;
  r_id       NUMBER;
  d_id       NUMBER;
  source_id	     NUMBER;
  cnt	     NUMBER;
  count1     NUMBER;
  maps_sources NUMBER;
  seq	     NUMBER;
  U_USER_NAME VARCHAR2(255);
  U_ROLE_NAME VARCHAR2(255);
begin
  U_USER_NAME := UPPER(USER_NAME);
  U_ROLE_NAME := UPPER(ROLE_NAME);

  select count(*) into cnt
  from fnd_user
  where user_name=U_USER_NAME;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1055');
    app_exception.raise_exception;
  end if;

  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1056');
    app_exception.raise_exception;
  end if;


  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  if cnt=0 then

	select jtf_auth_s1.nextval into seq from dual;
	JTF_AUTH_PRINCIPALS_PKG.INSERT_ROW(seq,seq,1,U_USER_NAME,APP_ID,null,1,0,U_USER_NAME, null, SYSDATE, 0, SYSDATE, 0, null);

  end if;

  select count(*) into count1
  from jtf_auth_principal_maps c,
       jtf_auth_principals_b a,
       jtf_auth_domains_b d,
       jtf_auth_principals_b b
  where a.principal_name=U_USER_NAME and a.is_user_flag=1
    and a.jtf_auth_principal_id=c.jtf_auth_principal_id
    and b.principal_name=U_ROLE_NAME and b.is_user_flag=0
    and b.jtf_auth_principal_id=c.jtf_auth_parent_principal_id
    and d.domain_name='CRM_DOMAIN'
    and d.jtf_auth_domain_id=c.jtf_auth_domain_id;

  select jtf_auth_principal_id into p_id
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  select jtf_auth_principal_id into r_id
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  select jtf_auth_domain_id into d_id
  from jtf_auth_domains_b where
  domain_name='CRM_DOMAIN';

  if count1=0 then
	  insert into jtf_auth_principal_maps (jtf_auth_principal_id,
		jtf_auth_parent_principal_id, jtf_auth_domain_id,
		created_by, creation_date, last_updated_by, last_update_date,
		application_id, object_version_number) values
		(p_id, r_id, d_id,
		 0,SYSDATE,0,SYSDATE,APP_ID,1);
   end if;

   select jtf_auth_s1.nextval into source_id from dual;

   select jtf_auth_principal_mapping_id into mapping_id
   from jtf_auth_principal_maps
   where jtf_auth_principal_id = p_id
     and jtf_auth_parent_principal_id = r_id
     and jtf_auth_domain_id = d_id;

  select count(*) into maps_sources
  from jtf_auth_maps_sources a
  where a.jtf_auth_principal_mapping_id = mapping_id
  and a.ownertable_name = 'JTF_AUTH_PRINCIPALS_B'
  and a.ownertable_key = TO_CHAR(p_id);

  if maps_sources=0 then
   	insert into jtf_auth_maps_sources (JTF_AUTH_MAPS_SOURCE_ID,
   	JTF_AUTH_PRINCIPAL_MAPPING_ID, OWNERTABLE_NAME, OWNERTABLE_KEY,
	CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
	APPLICATION_ID, OBJECT_VERSION_NUMBER) VALUES
	(source_id, mapping_id,	'JTF_AUTH_PRINCIPALS_B',
          TO_CHAR(p_id), 0, SYSDATE, 0, SYSDATE, APP_ID, 1);
   end if;


end ASSIGN_ROLE;

procedure ASSIGN_ROLE (
  USER_NAME in VARCHAR2,
  ROLE_NAME in VARCHAR2,
  OWNERTABLE_NAME in VARCHAR2,
  OWNERTABLE_KEY in VARCHAR2,
  APP_ID in NUMBER
) is
  mapping_id NUMBER;
  p_id 	     NUMBER;
  r_id       NUMBER;
  d_id       NUMBER;
  source_id	     NUMBER;
  cnt	     NUMBER;
  count1     NUMBER;
  count2 NUMBER;
  maps_sources NUMBER;
  key    NUMBER;
  seq	 NUMBER;
  U_USER_NAME VARCHAR2(255);
  U_ROLE_NAME VARCHAR2(255);
  U_OWNERTABLE_NAME VARCHAR2(255);
  table_error EXCEPTION;

begin

  U_USER_NAME := UPPER(USER_NAME);
  U_ROLE_NAME := UPPER(ROLE_NAME);
  U_OWNERTABLE_NAME := UPPER(OWNERTABLE_NAME);
  key := OWNERTABLE_KEY;

  select count(*) into count2
  from fnd_lookups
  where lookup_type = 'JTF_AUTH_OWNERTABLE_NAME'
    and lookup_code = U_OWNERTABLE_NAME;

  if count2=0 then

	RAISE table_error;

  end if;

  select count(*) into cnt
  from fnd_user
  where user_name=U_USER_NAME;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1055');
    app_exception.raise_exception;
  end if;

  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1056');
    app_exception.raise_exception;
  end if;


  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  if cnt=0 then

	select jtf_auth_s1.nextval into seq from dual;
	JTF_AUTH_PRINCIPALS_PKG.INSERT_ROW(seq,seq,1,U_USER_NAME,APP_ID,null,1,0,U_USER_NAME, null, SYSDATE, 0, SYSDATE, 0, null);

  end if;

  select count(*) into count1
  from jtf_auth_principal_maps c,
       jtf_auth_principals_b a,
       jtf_auth_domains_b d,
       jtf_auth_principals_b b
  where a.principal_name=U_USER_NAME and a.is_user_flag=1
    and a.jtf_auth_principal_id=c.jtf_auth_principal_id
    and b.principal_name=U_ROLE_NAME and b.is_user_flag=0
    and b.jtf_auth_principal_id=c.jtf_auth_parent_principal_id
    and d.domain_name='CRM_DOMAIN'
    and d.jtf_auth_domain_id=c.jtf_auth_domain_id;

  select jtf_auth_principal_id into p_id
  from jtf_auth_principals_b
  where principal_name=U_USER_NAME and is_user_flag=1;

  select jtf_auth_principal_id into r_id
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  select jtf_auth_domain_id into d_id
  from jtf_auth_domains_b where
  domain_name='CRM_DOMAIN';

  if count1 = 0 then

	insert into jtf_auth_principal_maps (jtf_auth_principal_id,
		jtf_auth_parent_principal_id, jtf_auth_domain_id,
		created_by, creation_date, last_updated_by, last_update_date,
		application_id, object_version_number) values
		(p_id, r_id, d_id,
		 0,SYSDATE,0,SYSDATE,APP_ID,1);

  end if;

  select jtf_auth_s1.nextval into source_id from dual;

  select jtf_auth_principal_mapping_id into mapping_id
  from jtf_auth_principal_maps
  where jtf_auth_principal_id = p_id
    and jtf_auth_parent_principal_id = r_id
    and jtf_auth_domain_id = d_id;

  select count(*) into maps_sources
  from jtf_auth_maps_sources a
  where a.jtf_auth_principal_mapping_id = mapping_id
  and a.ownertable_name = U_OWNERTABLE_NAME
  and a.ownertable_key = key;

   if maps_sources=0 then
  	insert into jtf_auth_maps_sources (JTF_AUTH_MAPS_SOURCE_ID,
   	JTF_AUTH_PRINCIPAL_MAPPING_ID, OWNERTABLE_NAME, OWNERTABLE_KEY,
	CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
	APPLICATION_ID, OBJECT_VERSION_NUMBER) VALUES
	(source_id, mapping_id,	U_OWNERTABLE_NAME,
          key, 0, SYSDATE, 0, SYSDATE, APP_ID, 1);
   end if;

exception
  when table_error then
    fnd_message.set_name('JTF', 'JTF-1049');
    app_exception.raise_exception;



end ASSIGN_ROLE;

end JTF_AUTH_BULKLOAD_PKG;

/
