--------------------------------------------------------
--  DDL for Package GMA_LOCK_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMA_LOCK_RECORD" AUTHID CURRENT_USER AS
/* $Header: GMALOCKS.pls 115.1 2003/05/06 02:14:48 kmoizudd ship $  */
  FUNCTION Lock_record (V_Table_name VARCHAR2,V_Column_name VARCHAR2,V_Column_val NUMBER,V_Last_update_date DATE) RETURN NUMBER;

END GMA_LOCK_RECORD;

 

/
