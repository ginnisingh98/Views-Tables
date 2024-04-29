--------------------------------------------------------
--  DDL for Package POS_PASSWORD_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_PASSWORD_UTIL_PKG" AUTHID CURRENT_USER AS
/*$Header: POSPWUTS.pls 120.0 2005/06/01 13:20:59 appldev noship $ */

FUNCTION generate_user_pwd RETURN VARCHAR2;

END POS_PASSWORD_UTIL_PKG;

 

/
