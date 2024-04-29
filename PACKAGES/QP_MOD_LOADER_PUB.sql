--------------------------------------------------------
--  DDL for Package QP_MOD_LOADER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_MOD_LOADER_PUB" AUTHID CURRENT_USER AS
/* $Header: QPXMLDRS.pls 120.1 2005/06/10 02:45:28 appldev  $ */

G_PROCESS_LST_REQ_TYPE                  VARCHAR2(3); -- shulin

PROCEDURE Load_Mod_List
(	p_process_id	IN	NUMBER,
	p_req_type_code IN	VARCHAR2,
	x_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
	x_errors		OUT NOCOPY /* file.sql.39 change */	VARCHAR2
);

g_temp_status varchar2(30);
g_temp_errors varchar2(5000);

END QP_MOD_LOADER_PUB;

 

/