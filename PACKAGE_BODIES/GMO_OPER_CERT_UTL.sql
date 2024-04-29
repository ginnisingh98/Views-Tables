--------------------------------------------------------
--  DDL for Package Body GMO_OPER_CERT_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_OPER_CERT_UTL" AS
 /*  $Header: GMOUOPCB.pls 120.1 2007/06/21 06:12:57 rvsingh noship $ */
  g_debug               VARCHAR2 (5)  := NVL(fnd_profile.VALUE ('AFLOG_LEVEL'),-1);
  g_pkg_name   CONSTANT VARCHAR2 (30) := 'GMO_OPER_CERT_UTL';
PROCEDURE validate_login (
     p_user_name IN            VARCHAR2
    ,p_password        IN            VARCHAR2
    ,x_return_status      OUT NOCOPY    VARCHAR2)
  IS
  isValid BOOLEAN;
  BEGIN
  isValid := FND_USER_PKG.ValidateLogin(username => p_user_name,password => p_password);
  IF(isValid) THEN
   x_return_status := 'T';
   ELSE
   x_return_status := 'F';
   END IF;
END validate_login;
END gmo_oper_cert_utl;

/
