--------------------------------------------------------
--  DDL for Package GMO_OPER_CERT_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_OPER_CERT_UTL" AUTHID CURRENT_USER AS
 /*  $Header: GMOUOPCS.pls 120.1 2007/06/21 06:13:22 rvsingh noship $ */
  g_debug               VARCHAR2 (5)  := NVL(fnd_profile.VALUE ('AFLOG_LEVEL'),-1);
  g_pkg_name   CONSTANT VARCHAR2 (30) := 'GMO_OPER_CERT_UTL';
PROCEDURE validate_login (
     p_user_name IN            VARCHAR2
    ,p_password        IN            VARCHAR2
    ,x_return_status      OUT NOCOPY    VARCHAR2);
END gmo_oper_cert_utl;

/
