--------------------------------------------------------
--  DDL for Package OE_BIS_CUST_SAT_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BIS_CUST_SAT_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: OEXBCSSS.pls 115.3 99/08/13 13:10:33 porting ship  $ */

/* Public Procedures  */

  PROCEDURE Load_Summary_Info;
  PROCEDURE Load_Summary_Info2;

  Procedure Populate_Summary_Table(x_errnum  OUT NUMBER,
                                   x_errmesg OUT VARCHAR2);

  Procedure Populate_Summary_Table2(x_errnum  OUT NUMBER,
                                   x_errmesg OUT VARCHAR2);

 -- PRAGMA RESTRICT_REFERENCES (get_Num_of_Workdays, WNDS, WNPS);

END OE_BIS_CUST_SAT_SUMMARY;

 

/
