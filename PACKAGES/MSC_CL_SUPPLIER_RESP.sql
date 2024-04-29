--------------------------------------------------------
--  DDL for Package MSC_CL_SUPPLIER_RESP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_SUPPLIER_RESP" AUTHID CURRENT_USER AS
/* $Header: MSCXCSRS.pls 115.3 2004/05/03 22:22:31 pshah ship $ */

/* Constants */
SYS_YES                      CONSTANT NUMBER := 1;
SYS_NO                       CONSTANT NUMBER := 2;
NULL_STRING	             CONSTANT VARCHAR2(7) :='-234567';
G_SR_INSTANCE_ID	     CONSTANT NUMBER := -1;
G_MRP_PO_ACK	             CONSTANT NUMBER := 49;
G_PLAN_ID	             CONSTANT NUMBER := -1;
G_OEM_ID                     CONSTANT NUMBER := 1;
G_SALES_ORDER                CONSTANT NUMBER := 14;
G_PO					     CONSTANT NUMBER := 13;
G_SR_OEM_ID		     CONSTANT NUMBER := -1;
G_ORGANIZATION               CONSTANT NUMBER := 3;

/* Collection variables */
TYPE number_arr IS TABLE OF NUMBER;
TYPE order_numbers IS TABLE OF MSC_ST_SUPPLIES.ORDER_NUMBER%TYPE;
TYPE order_line_numbers IS TABLE OF MSC_ST_SUPPLIES.ORDER_LINE_NUMBER%TYPE;
TYPE dates IS TABLE OF DATE;
TYPE end_order_numbers IS TABLE OF MSC_ST_SUPPLIES.END_ORDER_NUMBER%TYPE;
TYPE end_order_line_nums IS TABLE OF MSC_ST_SUPPLIES.END_ORDER_LINE_NUMBER%TYPE;
TYPE end_order_rel_nums IS TABLE OF MSC_ST_SUPPLIES.END_ORDER_RELEASE_NUMBER%TYPE;
TYPE company_names IS TABLE OF MSC_COMPANIES.COMPANY_NAME%TYPE;
TYPE company_site_names IS TABLE OF MSC_COMPANY_SITES.COMPANY_SITE_NAME%TYPE;
TYPE item_names IS TABLE OF MSC_SUP_DEM_ENTRIES.ITEM_NAME%TYPE;
TYPE item_descriptions IS TABLE OF MSC_SUP_DEM_ENTRIES.ITEM_description%TYPE;
TYPE tp_uom_codes IS TABLE OF MSC_SUP_DEM_ENTRIES.tp_uom_code%TYPE;
TYPE order_types IS TABLE OF MSC_SUP_DEM_ENTRIES.publisher_order_type_desc%TYPE;
TYPE acceptance_required_flags IS TABLE OF MSC_ST_SUPPLIES.ACCEPTANCE_REQUIRED_FLAG%TYPE;
TYPE ack_reference_numbers IS TABLE OF MSC_ST_SUPPLIES.ACK_REFERENCE_NUMBER%TYPE;


/* Procedures */
PROCEDURE PULL_SUPPLIER_RESP(p_dblink      		   IN varchar2,
							 p_instance_id 	       IN      NUMBER,
							 p_return_status          OUT NOCOPY BOOLEAN,
							 p_supplier_response_flag IN NUMBER,
							 p_refresh_id	IN	NUMBER,
							 p_lrn			IN  NUMBER,
							 p_in_org_str   IN  VARCHAR2
							);

PROCEDURE LOAD_SUPPLIER_RESPONSE(p_instance_id IN NUMBER ,
				                 p_is_complete_refresh IN BOOLEAN,
				                 p_is_partial_refresh IN BOOLEAN,
				                 p_is_incremental_refresh IN BOOLEAN,
								 p_temp_supply_table IN VARCHAR2,
								 p_user_id IN NUMBER,
								 p_last_collection_id NUMBER);

PROCEDURE PUBLISH_SUPPLIER_RESPONSE(p_refresh_number IN NUMBER,
				    p_sr_instance_id IN NUMBER,
				    p_return_status OUT NOCOPY BOOLEAN,
				    p_collection_type IN VARCHAR2,
				    p_user_id IN NUMBER,
				    p_in_org_str IN VARCHAR2
				    );

END MSC_CL_SUPPLIER_RESP;

 

/
