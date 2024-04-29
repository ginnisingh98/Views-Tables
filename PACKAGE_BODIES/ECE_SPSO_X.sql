--------------------------------------------------------
--  DDL for Package Body ECE_SPSO_X
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECE_SPSO_X" AS
-- $Header: ECSPSOXB.pls 115.4 2004/01/23 11:24:09 hgandiko ship $

Procedure populate_extension_headers(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type)
is

begin

   NULL;

end populate_extension_headers;


Procedure populate_extension_items(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type)
is

begin

   NULL;

end populate_extension_items;

/* Bug 1742567.
Modified the procedure populate_extension_item_det
to include correct parameters
*/

/*Procedure populate_extension_item_det(l_fkey  	IN NUMBER,
				   l_plsql_tbl  IN ece_flatfile_pvt.Interface_tbl_type)
is

begin

   NULL;

end populate_extension_item_det;
*/
Procedure populate_extension_item_det(transaction_id   IN NUMBER,
                                   schedule_id IN NUMBER,
                                  schedule_item_id IN NUMBER)
is

begin
  NULL;

end populate_extension_item_det;

Procedure populate_extension_ship_det(transaction_id   IN NUMBER,
                                      schedule_id IN NUMBER,
                                      schedule_item_id IN NUMBER,
                                      schedule_item_detail_sequence IN NUMBER)
is
begin
  NULL;

end populate_extension_ship_det;


end ECE_SPSO_X;

/
