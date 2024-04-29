--------------------------------------------------------
--  DDL for Package WMS_SAVE_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SAVE_QUERY_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSVSQRS.pls 115.2 2003/01/15 19:17:36 piwong noship $ */

TYPE save_query_record IS RECORD
  (
   query_type     wms_saved_queries.query_type%TYPE,
   query_name     wms_saved_queries.query_name%TYPE,
   field_name     wms_saved_queries.field_name%TYPE,
   field_type     wms_saved_queries.field_type%TYPE,
   field_value    wms_saved_queries.field_value%TYPE,
   return_status  VARCHAR2(1));

TYPE save_query_table IS TABLE OF save_query_record
  INDEX BY BINARY_INTEGER;

PROCEDURE insert_query_row(p_query_type  wms_saved_queries.query_type%TYPE,
			   p_query_name  wms_saved_queries.query_name%TYPE,
			   p_org_id      wms_saved_queries.organization_id%TYPE,
			   p_user_id     wms_saved_queries.user_id%TYPE,
			   p_login_id    wms_saved_queries.last_update_login%TYPE,
			   p_table       save_query_table,
			   x_return_status OUT NOCOPY varchar2);

PROCEDURE update_query_row(p_query_type  wms_saved_queries.query_type%TYPE,
			   p_query_name  wms_saved_queries.query_name%TYPE,
			   p_org_id      wms_saved_queries.organization_id%TYPE,
			   p_user_id     wms_saved_queries.user_id%TYPE,
			   p_login_id    wms_saved_queries.last_update_login%TYPE,
			   p_table       save_query_table,
			   x_return_status OUT NOCOPY varchar2);

PROCEDURE update_query_row(p_query_type   wms_saved_queries.query_type%TYPE,
			   p_query_name   wms_saved_queries.query_name%TYPE,
			   p_field_name   wms_saved_queries.field_name%TYPE,
			   p_field_value  wms_saved_queries.field_value%TYPE,
			   p_field_type   wms_saved_queries.field_type%TYPE,
			   p_org_id       wms_saved_queries.organization_id%TYPE,
			   p_user_id      wms_saved_queries.user_id%TYPE,
			   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE delete_query_row(p_query_type   wms_saved_queries.query_type%TYPE,
			   p_query_name   wms_saved_queries.query_name%TYPE,
			   p_field_name   wms_saved_queries.field_name%TYPE,
			   p_org_id       wms_saved_queries.organization_id%TYPE,
			   p_user_id      wms_saved_queries.user_id%TYPE,
			   x_return_status OUT NOCOPY VARCHAR2);

PROCEDURE delete_query(p_query_type   wms_saved_queries.query_type%TYPE,
		       p_query_name   wms_saved_queries.query_name%TYPE,
		       p_org_id       wms_saved_queries.organization_id%TYPE,
		       p_user_id      wms_saved_queries.user_id%TYPE,
		       x_return_status OUT NOCOPY VARCHAR2);

END wms_save_query_pvt;


 

/
