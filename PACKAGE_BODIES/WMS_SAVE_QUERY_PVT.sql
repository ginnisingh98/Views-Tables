--------------------------------------------------------
--  DDL for Package Body WMS_SAVE_QUERY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_SAVE_QUERY_PVT" AS
/* $Header: WMSVSQRB.pls 115.3 2003/01/15 19:18:18 piwong noship $ */

PROCEDURE insert_query_row(p_query_type  wms_saved_queries.query_type%TYPE,
			   p_query_name  wms_saved_queries.query_name%TYPE,
			   p_org_id      wms_saved_queries.organization_id%TYPE,
			   p_user_id     wms_saved_queries.user_id%TYPE,
			   p_login_id    wms_saved_queries.last_update_login%TYPE,
			   p_table       save_query_table,
			   x_return_status OUT NOCOPY varchar2)
  IS
     l_user_id   NUMBER(15);
     l_login_id  NUMBER(15);
     l_sysdate   DATE;
BEGIN
   x_return_status := 'S';
   l_sysdate := SYSDATE;

   FOR i IN p_table.first..p_table.last LOOP
      INSERT INTO wms_saved_queries
	(query_type,
	 query_name,
	 field_name,
	 field_type,
	 field_value,
	 last_update_date,
	 last_updated_by,
	 last_update_login,
	 creation_date,
	 created_by,
	 organization_id,
	 user_id)
	VALUES
	(p_query_type,
	 p_query_name,
	 p_table(i).field_name,
	 p_table(i).field_type,
	 p_table(i).field_value,
	 l_sysdate,
	 p_user_id,
	 p_login_id,
	 l_sysdate,
	 p_user_id,
	 p_org_id,
	 p_user_id);
   END LOOP;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
END insert_query_row;

PROCEDURE update_query_row(p_query_type  wms_saved_queries.query_type%TYPE,
			   p_query_name  wms_saved_queries.query_name%TYPE,
			   p_org_id      wms_saved_queries.organization_id%TYPE,
			   p_user_id     wms_saved_queries.user_id%TYPE,
			   p_login_id    wms_saved_queries.last_update_login%TYPE,
			   p_table       save_query_table,
			   x_return_status OUT NOCOPY varchar2) IS
BEGIN
   x_return_status := 'S';

   FOR i IN p_table.first..p_table.last LOOP
      UPDATE wms_saved_queries
	SET field_value = p_table(i).field_value,
	    field_type = p_table(i).field_type
	WHERE query_type = p_query_type
	and query_name = p_query_name
	and field_name = p_table(i).field_name
	AND organization_id = p_org_id
	AND user_id = p_user_id;
   END LOOP;

   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
END;

PROCEDURE update_query_row(p_query_type   wms_saved_queries.query_type%TYPE,
			   p_query_name   wms_saved_queries.query_name%TYPE,
			   p_field_name   wms_saved_queries.field_name%TYPE,
			   p_field_value  wms_saved_queries.field_value%TYPE,
			   p_field_type   wms_saved_queries.field_type%TYPE,
			   p_org_id       wms_saved_queries.organization_id%TYPE,
			   p_user_id      wms_saved_queries.user_id%TYPE,
			   x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
   x_return_status := 'S';

   UPDATE WMS_SAVED_QUERIES
     SET field_value = p_field_value, field_type = p_field_type
     WHERE query_type = p_query_type
     and query_name = p_query_name
     and field_name = p_field_name
     AND organization_id = p_org_id
     AND user_id = p_user_id;

   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';

END update_query_row;

PROCEDURE delete_query_row(p_query_type   wms_saved_queries.query_type%TYPE,
			   p_query_name   wms_saved_queries.query_name%TYPE,
			   p_field_name   wms_saved_queries.field_name%TYPE,
			   p_org_id       wms_saved_queries.organization_id%TYPE,
			   p_user_id      wms_saved_queries.user_id%TYPE,
			   x_return_status OUT NOCOPY VARCHAR2)
IS
BEGIN
   x_return_status := 'S';

   DELETE
     FROM WMS_SAVED_QUERIES
     WHERE query_type = p_query_type
     and query_name = p_query_name
     and field_name = p_field_name
     AND organization_id = p_org_id
     AND user_id = p_user_id;

   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';

END delete_query_row;

PROCEDURE delete_query(p_query_type   wms_saved_queries.query_type%TYPE,
		       p_query_name   wms_saved_queries.query_name%TYPE,
		       p_org_id       wms_saved_queries.organization_id%TYPE,
		       p_user_id      wms_saved_queries.user_id%TYPE,
		       x_return_status OUT NOCOPY VARCHAR2)
  IS
BEGIN
   x_return_status := 'S';

   DELETE
     FROM WMS_SAVED_QUERIES
     WHERE query_type = p_query_type
     and query_name = p_query_name
     AND organization_id = p_org_id
     AND user_id = p_user_id;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
END delete_query;

END wms_save_query_pvt;


/
