--------------------------------------------------------
--  DDL for Package Body MTL_CATALOG_SEARCH_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_CATALOG_SEARCH_ITEMS_PKG" as
/* $Header: INVIVCSB.pls 120.1 2005/07/01 12:29:26 appldev ship $ */

procedure delete_row (item_id      NUMBER,
                      org_id       NUMBER,
                      handle       NUMBER) IS

begin

     delete from MTL_CATALOG_SEARCH_ITEMS mtl
     where mtl.inventory_item_id = item_id
      and  mtl.organization_id = org_id
      and  mtl.group_handle_id = handle;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

end delete_row ;


procedure sav_commit is
begin
      commit;
end sav_commit;

END MTL_CATALOG_SEARCH_ITEMS_PKG;

/
