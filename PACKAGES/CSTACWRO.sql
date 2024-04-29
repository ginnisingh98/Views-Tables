--------------------------------------------------------
--  DDL for Package CSTACWRO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTACWRO" AUTHID CURRENT_USER AS
/* $Header: CSTPACOS.pls 115.3 2002/11/08 23:25:16 awwang ship $ */

FUNCTION overhead (
	   I_OVHD_TYPE			IN 	NUMBER,
	   I_COST_TYPE_ID		IN	NUMBER,
	   I_ORG_ID			IN	NUMBER,
	   I_GROUP_ID			IN	NUMBER,
	   ERR_NUM			OUT NOCOPY	NUMBER,
	   ERR_CODE			OUT NOCOPY	VARCHAR2,
	   ERR_MSG			OUT NOCOPY	VARCHAR2)
RETURN integer;

END CSTACWRO;

 

/
