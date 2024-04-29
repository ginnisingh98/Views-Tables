--------------------------------------------------------
--  DDL for Package DOM_SECURITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DOM_SECURITY_PVT" AUTHID CURRENT_USER AS
/* $Header: DOMVSECS.pls 120.3 2006/08/17 13:41:00 ysireesh noship $ */
/*---------------------------------------------------------------------------+
 | This package contains APIs to reslove docuemnt security mappings          |
 | based on fnd data security                                                |
 +---------------------------------------------------------------------------*/

  G_PKG_NAME 	CONSTANT VARCHAR2(30):= 'DOM_SECURITY_PVT';

  FUNCTION get_oid_user(p_user_name VARCHAR2) RETURN VARCHAR2;

  PROCEDURE get_oid_users
  (
      l_user_names IN DOM_USER_NAMES_ARRAY,
      x_oid_user_names OUT NOCOPY DOM_USER_NAMES_ARRAY
  );

END DOM_SECURITY_PVT;

 

/
