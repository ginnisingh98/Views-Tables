--------------------------------------------------------
--  DDL for Package MSC_CL_SUPPLY_ODS_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_SUPPLY_ODS_LOAD" AUTHID CURRENT_USER AS
/*$Header: MSCLSUPS.pls 120.1 2007/10/08 06:42:25 rsyadav noship $*/
FUNCTION  IS_SUPPLIES_LOAD_DONE RETURN boolean;
FUNCTION  create_supplies_tmp_ind RETURN  boolean;
FUNCTION  drop_supplies_tmp_ind RETURN boolean;
PROCEDURE LOAD_SUPPLY;
PROCEDURE LOAD_STAGING_SUPPLY;
-- Load Supply information from staging tables
-- into the supply temp table.
PROCEDURE LOAD_ODS_SUPPLY;
-- Load Supply information from staging tables
-- into the supply temp table.

PROCEDURE LOAD_PAYBACK_SUPPLIES;
END MSC_CL_SUPPLY_ODS_LOAD;

/
