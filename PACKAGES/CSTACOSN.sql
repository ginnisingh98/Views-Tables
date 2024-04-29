--------------------------------------------------------
--  DDL for Package CSTACOSN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTACOSN" AUTHID CURRENT_USER AS
/* $Header: CSTACOSS.pls 115.4 2002/11/08 01:15:33 awwang ship $ */

FUNCTION op_snapshot(
	  I_TXN_TEMP_ID		IN	NUMBER,
	  ERR_NUM		OUT NOCOPY	NUMBER,
	  ERR_CODE		OUT NOCOPY	VARCHAR2,
	  ERR_MSG		OUT NOCOPY	VARCHAR2)
RETURN INTEGER;

END CSTACOSN;

 

/
