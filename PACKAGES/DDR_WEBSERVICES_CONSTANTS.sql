--------------------------------------------------------
--  DDL for Package DDR_WEBSERVICES_CONSTANTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DDR_WEBSERVICES_CONSTANTS" AUTHID CURRENT_USER AS
/* $Header: ddrpwscs.pls 120.0 2008/02/13 07:08:52 vbhave noship $ */
	   --code for MARKET ITEM SALES DAY
	   g_misd_cd CONSTANT VARCHAR2 (50) := 'MISD';
	   --code for PROMOTION PLAN
	   g_pp_cd CONSTANT VARCHAR2 (50) := 'PP';
	   --code for RETAIL INVENTORY ITEM DAY
	   g_riid_cd CONSTANT VARCHAR2 (50) := 'RIID';
	   --code for RETAIL SALE RETURN ITEM DAY
	   g_rsrid_cd CONSTANT VARCHAR2 (50) := 'RSRID';
   	   --code for RETAILER ORDER ITEM DAY
	   g_roid_cd CONSTANT VARCHAR2 (50) := 'ROID';
	   --code for RETAILER SHIP ITEM DAY
	   g_rsid_cd CONSTANT VARCHAR2 (50) := 'RSID';
	   --code for SALE FORECAST ITEM BY DAY
	   g_sfid_cd CONSTANT VARCHAR2 (50) := 'SFID';
	   --table name for MARKET ITEM SALES DAY
	   g_misd_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_MKT_ITEM_SLS_DAY';
	   --table name for PROMOTION PLAN
	   g_pp_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_PRMTN_PLN';
	   --table name for RETAIL INVENTORY ITEM DAY fact
	   g_riid_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_RTL_INV_ITEM_DAY';
  	   --table name for RETAIL SALE RETURN ITEM DAY fact
	   g_rsrid_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_RTL_SL_RTN_ITM_DAY';
   	   --table name for RETAILER ORDER ITEM DAY
	   g_roid_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_RTL_ORDR_ITEM_DAY';
   	   --table name for RETAILER SHIP ITEM DAY
	   g_rsid_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_RTL_SHIP_ITEM_DAY';
	   --table name for SALE FORECAST ITEM BY DAY
	   g_sfid_fact_tbl CONSTANT VARCHAR2 (30) := 'DDR_B_SLS_FRCST_ITEM_DAY';

	   --file mode read
	   g_file_read_mode CONSTANT VARCHAR2 (1) := 'R';
  	   --file mode write
	   g_file_write_mode CONSTANT VARCHAR2 (1) := 'W';

	   --return status Success
	   g_ret_sts_success CONSTANT VARCHAR2(1):='S';
	   --return status 'Error
	   g_ret_sts_error CONSTANT VARCHAR2(1):='E';
	   --return status 'Unexoected Error
	   g_ret_sts_unexp_error CONSTANT VARCHAR2(1):='U';
	   --return status 'Initialized
	   g_ret_sts_initialize CONSTANT VARCHAR2(1):='I';
	   --return status 'Running
	   g_ret_sts_running CONSTANT VARCHAR2(1):='R';
	   g_api_version NUMBER:=1.0;
END ddr_webservices_constants;

/
