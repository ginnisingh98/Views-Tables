--------------------------------------------------------
--  DDL for Package Body JTF_AUTH_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_AUTH_SECURITY_PKG" AS
/* $Header: JTFSEASB.pls 120.2 2005/10/24 05:03:34 psanyal ship $ */
PROCEDURE check_permission (
  x_flag OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_return_status OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  p_user_name IN VARCHAR2,
  p_domain_name IN VARCHAR2 DEFAULT 'CRM_DOMAIN',
  p_permission_name IN VARCHAR2
) IS

  l_cnt NUMBER;
  l_user_name VARCHAR2(255);
  l_domain_name VARCHAR2(255);
  l_permission_name VARCHAR2(255);

BEGIN

  l_cnt := 0;
  l_user_name := UPPER(p_user_name);
  l_domain_name := UPPER(p_domain_name);
  l_permission_name := p_permission_name;

  SELECT COUNT(*) INTO l_cnt
  FROM JTF_AUTH_PERMISSIONS_B A,
       JTF_AUTH_PRINCIPAL_MAPS B,
       JTF_AUTH_ROLE_PERMS C,
       JTF_AUTH_PRINCIPALS_B D,
       JTF_AUTH_PRINCIPALS_B E,
       JTF_AUTH_DOMAINS_B F
  WHERE D.PRINCIPAL_NAME = l_user_name
        AND D.JTF_AUTH_PRINCIPAL_ID =B.JTF_AUTH_PRINCIPAL_ID
	AND B.JTF_AUTH_PARENT_PRINCIPAL_ID = E.JTF_AUTH_PRINCIPAL_ID
	AND E.JTF_AUTH_PRINCIPAL_ID = C.JTF_AUTH_PRINCIPAL_ID
	AND C.JTF_AUTH_PERMISSION_ID = A.JTF_AUTH_PERMISSION_ID
	AND B.JTF_AUTH_DOMAIN_ID = F.JTF_AUTH_DOMAIN_ID
	AND F.DOMAIN_NAME = l_domain_name
	AND A.PERMISSION_NAME = l_permission_name;

  IF (l_cnt>0) THEN
    x_flag := 1;
  ELSE
    x_flag := 0;
  END IF;

  x_return_status := fnd_api.g_ret_sts_success;

EXCEPTION

  -- this shouldn't happen but if it does, its safe to return true

  WHEN TOO_MANY_ROWS THEN
    x_return_status := fnd_api.g_ret_sts_success;
    x_flag := 1;

  WHEN OTHERS THEN
    x_return_status := fnd_api.g_ret_sts_unexp_error;

--  do we need to throw an exception?
--  fnd_message.set_name('JTF', '..');
--  app_exception.raise_exception;

END check_permission;




procedure assign_perm (
  ROLE_NAME in VARCHAR2,
  PERM_NAME in VARCHAR2,
  APP_ID in NUMBER
) is

  cnt	     NUMBER;
  U_ROLE_NAME VARCHAR2(255);

begin
  U_ROLE_NAME := UPPER(ROLE_NAME);

  select count(*) into cnt
  from jtf_auth_principals_b
  where principal_name=U_ROLE_NAME and is_user_flag=0;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1061');
    app_exception.raise_exception;
  end if;

  select count(*) into cnt
  from JTF_AUTH_PERMISSIONS_B
  where PERMISSION_NAME=PERM_NAME;

  if cnt=0 then
    fnd_message.set_name('JTF', 'JTF-1062');
    app_exception.raise_exception;
  end if;


  select count(*) into cnt
  from JTF_AUTH_PRINCIPALS_B A,
       JTF_AUTH_PERMISSIONS_B B,
       JTF_AUTH_ROLE_PERMS C
  where A.JTF_AUTH_PRINCIPAL_ID = C.JTF_AUTH_PRINCIPAL_ID and
	B.JTF_AUTH_PERMISSION_ID = C.JTF_AUTH_PERMISSION_ID and
	A.PRINCIPAL_NAME=U_ROLE_NAME and
	B.PERMISSION_NAME=PERM_NAME and
		A.IS_USER_FLAG=0;

  if cnt=0 then
  insert into JTF_AUTH_ROLE_PERMS(JTF_AUTH_ROLE_PERMISSION_ID, JTF_AUTH_PRINCIPAL_ID, JTF_AUTH_PERMISSION_ID,
				POSITIVE_FLAG, OWNERBASED_FLAG,
				CREATED_BY, CREATION_DATE,
				LAST_UPDATED_BY, LAST_UPDATE_DATE,
				APPLICATION_ID,OBJECT_VERSION_NUMBER)
		select jtf_auth_s1.nextval, A.JTF_AUTH_PRINCIPAL_ID, B.JTF_AUTH_PERMISSION_ID,
		1,0, 0, SYSDATE, 0, SYSDATE, APP_ID,1
		from JTF_AUTH_PRINCIPALS_B A, JTF_AUTH_PERMISSIONS_B B
		where A.PRINCIPAL_NAME=U_ROLE_NAME and
		B.PERMISSION_NAME=PERM_NAME and
		A.IS_USER_FLAG=0;

   end if;


end assign_perm;



END jtf_auth_security_pkg;

/
