--------------------------------------------------------
--  DDL for Package POA_DBI_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POA_DBI_ITEMS_PKG" AUTHID CURRENT_USER as
/* $Header: poadbiitems.pls 115.5 2003/04/19 00:43:00 mangupta noship $ */
  function  getItemKey(p_item_id IN number,
                       p_org_id IN number,
                       p_category_id IN number,
                       p_vendor_product_num IN varchar2,
		       p_vendor_id IN NUMBER,
                       p_description IN varchar2,
                      p_auto_insert_flag boolean default true) return NUMBER parallel_enable;

  PROCEDURE  refresh(Errbuf      in out NOCOPY Varchar2,
		     Retcode     in out NOCOPY VARCHAR2 );

end poa_dbi_items_pkg;

 

/
