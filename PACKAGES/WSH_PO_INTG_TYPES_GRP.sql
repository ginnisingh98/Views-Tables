--------------------------------------------------------
--  DDL for Package WSH_PO_INTG_TYPES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_PO_INTG_TYPES_GRP" AUTHID CURRENT_USER AS
/* $Header: WSHPTGPS.pls 115.1 2003/08/22 20:45:42 rlanka noship $ */

TYPE TBL_NUM IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE TBL_V1 IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
TYPE purge_in_rectype IS RECORD(
	caller VARCHAR2(50),
	header_ids TBL_NUM
	);
TYPE purge_out_rectype IS RECORD(
	purge_allowed TBL_V1
	);

TYPE merge_in_rectype IS RECORD(
	caller VARCHAR2(50),
	p_from_vendor_id NUMBER,
	p_from_site_id  NUMBER,
	p_to_vendor_id  NUMBER,
	p_to_site_id    NUMBER
	);

TYPE merge_out_rectype IS RECORD(
	dummy VARCHAR2(50)
	);


TYPE delInfo_in_recType IS RECORD(
	routingRespNum	VARCHAR2(30)
	);

TYPE delInfo_out_recType IS RECORD(
	hasChanged	BOOLEAN
	);


END WSH_PO_INTG_TYPES_GRP;

 

/
