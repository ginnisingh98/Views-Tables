--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_VALUE_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_VALUE_INIT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDIVIS.pls 120.1 2005/08/02 01:47:42 achandak noship $ */

-- ---------------------------------------------------------
--  PROCEDURES
-- ---------------------------------------------------------

   PROCEDURE GET_INCEPTION_INV_BALANCE;
   PROCEDURE RUN_FIRST_ETL(errbuf in out NOCOPY varchar2, retcode in out NOCOPY varchar2, p_degree IN NUMBER);
   PROCEDURE INTRANSIT_SETUP(p_mode varchar2);

-- ---------------------------------------------------------
--  FUNCTIONS
   FUNCTION GET_OPM_ITEM_COST( l_organization_id NUMBER,
			    l_inventory_item_id NUMBER,
			    l_txn_date DATE) RETURN NUMBER;
-- ---------------------------------------------------------


End OPI_DBI_INV_VALUE_INIT_PKG;

 

/
