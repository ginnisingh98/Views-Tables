--------------------------------------------------------
--  DDL for Package WMS_TASK_ACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_TASK_ACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSTACPS.pls 120.0.12000000.1 2007/01/16 06:57:11 appldev ship $ */

TYPE query_type_table_type IS TABLE OF wms_saved_queries.query_type%TYPE INDEX BY BINARY_INTEGER;
TYPE field_name_table_type IS TABLE OF wms_saved_queries.field_name%TYPE INDEX BY BINARY_INTEGER;
TYPE field_value_table_type IS TABLE OF wms_saved_queries.field_value%TYPE INDEX BY BINARY_INTEGER;
TYPE organization_id_table_type IS TABLE OF wms_saved_queries.organization_id%TYPE INDEX BY BINARY_INTEGER;

PROCEDURE TASK_ACTION_CONC_PROG
(
	errbuf		OUT NOCOPY	VARCHAR2,
	retcode		OUT NOCOPY	VARCHAR2,
	p_query_name	IN		VARCHAR2,
	p_action	IN		VARCHAR2,
	p_action_name	IN		VARCHAR2
);

PROCEDURE TASK_ACTION
(
	p_query_name		IN		VARCHAR2,
	p_action_name		IN		VARCHAR2,
	p_action		IN		VARCHAR2,
	p_online		IN		VARCHAR2,
	x_rowcount		OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
);

PROCEDURE SUBMIT_REQUEST
(
	p_query_name		IN		VARCHAR2,
	p_action		IN		VARCHAR2,
	p_action_name		IN		VARCHAR2,
	x_request_id		OUT NOCOPY	NUMBER,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_return_message	OUT NOCOPY	VARCHAR2
);

END WMS_TASK_ACTION_PVT;

 

/
