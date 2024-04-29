--------------------------------------------------------
--  DDL for Package OPI_DBI_JOBS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_JOBS_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDJOBSS.pls 120.2 2006/04/05 01:09:17 vganeshk noship $ */

 PROCEDURE GET_JOBS_INITIAL_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

 PROCEDURE GET_JOBS_INCR_LOAD(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2);

 FUNCTION GET_OPM_ITEM_COST(l_organization_id NUMBER,
 			   l_inventory_item_id NUMBER,
 			   l_txn_date DATE)
RETURN NUMBER;

 FUNCTION GET_ODM_ITEM_COST(l_organization_id NUMBER,
 			    l_inventory_item_id NUMBER)
RETURN NUMBER;

END OPI_DBI_JOBS_PKG;

 

/
