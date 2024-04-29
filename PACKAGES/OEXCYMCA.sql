--------------------------------------------------------
--  DDL for Package OEXCYMCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEXCYMCA" AUTHID CURRENT_USER AS
/* $Header: OEXCYCAS.pls 115.1 99/07/16 08:12:18 porting shi $ */
  PROCEDURE GET_RESULT_COLUMN (P_RESULT_TABLE IN VARCHAR2, RESULT_COLUMN OUT VARCHAR2);

END OEXCYMCA;

 

/
