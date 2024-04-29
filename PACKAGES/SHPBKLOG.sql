--------------------------------------------------------
--  DDL for Package SHPBKLOG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."SHPBKLOG" AUTHID CURRENT_USER AS
/* $Header: SHPBLOGS.pls 115.1 99/07/16 08:17:22 porting shi $ */


function BACKLOG_QTY(
	O_LINE_ID		IN 	NUMBER		DEFAULT NULL,
	ITEM_TYPE_CODE		IN	VARCHAR2	DEFAULT NULL
                          )
   return NUMBER;


function ORDER_BACKLOG_AMOUNT(
	O_HEADER_ID		IN	NUMBER		DEFAULT NULL,
	O_BACKLOG_QTY		IN OUT	NUMBER
                          )
   return NUMBER;



pragma restrict_references( BACKLOG_QTY, WNDS, WNPS);
pragma restrict_references( ORDER_BACKLOG_AMOUNT, WNDS, WNPS);

END SHPBKLOG;

 

/
