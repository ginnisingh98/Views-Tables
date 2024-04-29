--------------------------------------------------------
--  DDL for Package Body DOM_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."DOM_SECURITY_PVT" AS
/* $Header: DOMVSECB.pls 120.5 2006/08/17 13:41:20 ysireesh noship $ */
/*---------------------------------------------------------------------------+
 | This package contains APIs to reslove docuemnt security mappings          |
 | based on fnd data security                                                |
 +---------------------------------------------------------------------------*/

  G_PKG_NAME    CONSTANT VARCHAR2(30):= 'DOM_SECURITY_PVT';
  G_LOG_HEAD    CONSTANT VARCHAR2(30):= 'fnd.plsql.DOM_SECURITY_PVT.';
  G_TYPE_SET    CONSTANT VARCHAR2(30):= 'SET';
  G_TYPE_INSTANCE CONSTANT VARCHAR2(30):= 'INSTANCE';
  G_TYPE_UNIVERSAL CONSTANT VARCHAR2(30):= 'UNIVERSAL';


  FUNCTION get_oid_user(p_user_name VARCHAR2) RETURN VARCHAR2
  IS
        l_apps_user_key fnd_oid_util.apps_user_key_type;
        l_user_name fnd_user.user_name%type;
        l_oid_user_name varchar2(256);
  BEGIN

        l_user_name  := p_user_name;
        l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => l_user_name);
        l_oid_user_name := fnd_oid_util.get_oid_nickname(p_user_guid=>
        l_apps_user_key.USER_GUID);

        return l_oid_user_name;

	EXCEPTION
	 WHEN OTHERS THEN
		RETURN NULL;

  END get_oid_user;

  PROCEDURE get_oid_users
  (
        l_user_names IN DOM_USER_NAMES_ARRAY,
        x_oid_user_names OUT NOCOPY DOM_USER_NAMES_ARRAY
  )
  IS
        l_apps_user_key fnd_oid_util.apps_user_key_type;
        BEGIN
	        x_oid_user_names := DOM_USER_NAMES_ARRAY();
                IF (l_user_names.count>0) THEN
		    x_oid_user_names.extend(l_user_names.count);
                    for i in l_user_names.first .. l_user_names.last
                    LOOP
                           l_apps_user_key := fnd_oid_util.get_fnd_user(p_user_name => l_user_names(i));
                           x_oid_user_names(i) := fnd_oid_util.get_oid_nickname(p_user_guid=> l_apps_user_key.USER_GUID);
                   END LOOP;
                END IF;
        END;

END DOM_SECURITY_PVT;

/
