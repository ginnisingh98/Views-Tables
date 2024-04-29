--------------------------------------------------------
--  DDL for Package MTL_CATALOG_SEARCH_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MTL_CATALOG_SEARCH_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: INVIVCSS.pls 120.0 2005/05/25 04:38:59 appldev noship $ */

procedure delete_row (item_id      NUMBER,
                      org_id       NUMBER,
                      handle       NUMBER);

Procedure sav_commit ;

END MTL_CATALOG_SEARCH_ITEMS_PKG;

 

/
