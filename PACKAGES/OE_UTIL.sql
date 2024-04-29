--------------------------------------------------------
--  DDL for Package OE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UTIL" AUTHID CURRENT_USER AS
/* $Header: oexutls.pls 115.1 99/07/16 08:30:39 porting shi $ */

  PROCEDURE Set_Schedule_Date_Window (
		P_Result		OUT VARCHAR2
  );

  PROCEDURE Reset_Schedule_Date_Window (
		Original_Sch_Window	IN  VARCHAR2,
		P_Result		OUT VARCHAR2
  );


END OE_UTIL;

 

/
