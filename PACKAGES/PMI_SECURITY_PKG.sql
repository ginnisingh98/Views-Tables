--------------------------------------------------------
--  DDL for Package PMI_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PMI_SECURITY_PKG" AUTHID CURRENT_USER AS
/* $Header: PMISECPS.pls 115.8 2002/11/25 20:13:34 csingh ship $ */

  	FUNCTION show_record
		( p_orgn_code VARCHAR2,
              P_orgn_type NUMBER DEFAULT 2,
              P_USER_ID   NUMBER DEFAULT NULL)
		RETURN VARCHAR2;
        	PRAGMA RESTRICT_REFERENCES (show_record, WNDS,WNPS );
END PMI_SECURITY_PKG ;

 

/
