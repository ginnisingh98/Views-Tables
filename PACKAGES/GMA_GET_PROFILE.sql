--------------------------------------------------------
--  DDL for Package GMA_GET_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_GET_PROFILE" AUTHID CURRENT_USER AS
/* $Header: GMAPROFS.pls 115.0 99/07/16 02:46:58 porting shi $ */
 FUNCTION GET_PROFILE_value(appl_short_name VARCHAR2,profile_name VARCHAR2) RETURN VARCHAR2;
 PRAGMA RESTRICT_REFERENCES (GET_PROFILE_value,WNDS,WNPS,RNPS);
END GMA_GET_PROFILE;

 

/
