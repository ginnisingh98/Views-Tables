--------------------------------------------------------
--  DDL for Package IEB_SYNC_SERVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEB_SYNC_SERVER" AUTHID CURRENT_USER AS
/* $Header: IEBSVRS.pls 115.13 2003/10/03 19:57:03 gpagadal noship $ */

g_pkg_name     CONSTANT VARCHAR2(30)  := 'IEB_SYNC_SERVER';

PROCEDURE GET_WB_SERVER_LIST (
 p_language IN varchar2,
 p_order_by IN varchar2,
 p_asc      IN varchar2,
 x_wb_servers_list OUT NOCOPY SYSTEM.IEB_WB_SERVERS_DATA_NST,
 x_return_status   OUT NOCOPY VARCHAR2 );

PROCEDURE SYNC_SERVER (
 p_language IN varchar2,
 x_return_status   OUT NOCOPY VARCHAR2 );

PROCEDURE INSERT_SVC_CAT_ENTRIES (
 p_language IN varchar2,
 p_wbsvr_id  IN number,
 x_return_status   OUT NOCOPY VARCHAR2 );

PROCEDURE SYNC_CAT_ENTRIES (
 p_language IN varchar2,
 x_return_status   OUT NOCOPY VARCHAR2 );


END IEB_SYNC_SERVER;


 

/
