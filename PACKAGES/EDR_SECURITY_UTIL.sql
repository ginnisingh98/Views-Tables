--------------------------------------------------------
--  DDL for Package EDR_SECURITY_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_SECURITY_UTIL" AUTHID CURRENT_USER AS
/*  $Header: EDRSECWS.pls 120.0.12000000.1 2007/01/18 05:55:26 appldev ship $ */

PROCEDURE add_drop_policy (ERRBUF OUT NOCOPY VARCHAR2, RETCODE OUT NOCOPY VARCHAR2, ACTION IN VARCHAR2);

--Bug 3187777: Start
--This function would strip the occurence of { } and \ from a string making sure
--that all escaping done for Oracle Text has been removed

FUNCTION STRIP_SPECIAL_CHAR(qry varchar2) RETURN VARCHAR2;
--Bug 3187777: End

END edr_security_util;

 

/
