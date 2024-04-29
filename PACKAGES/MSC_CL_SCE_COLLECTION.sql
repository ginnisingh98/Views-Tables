--------------------------------------------------------
--  DDL for Package MSC_CL_SCE_COLLECTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_CL_SCE_COLLECTION" AUTHID CURRENT_USER AS
/* $Header: MSCXCSCS.pls 120.1 2005/08/05 02:53:00 pragarwa noship $ */

-- ===== Constants ====
   G_SUPPLIER          CONSTANT NUMBER := 1;
   G_CUSTOMER          CONSTANT NUMBER := 2;
   G_ORGANIZATION      CONSTANT NUMBER := 3;
   G_MY_COMPANY_ID        CONSTANT NUMBER := 1;
   G_CONF_APS          CONSTANT NUMBER := 1;
   G_CONF_APS_SCE      CONSTANT NUMBER := 2;
   G_CONF_SCE          CONSTANT NUMBER := 3;
   G_ERROR                CONSTANT NUMBER := 2;
   G_OEM_ID            CONSTANT NUMBER := 1;

   NO_USER_COMPANY        CONSTANT NUMBER := 1;
   COMPANY_ONLY           CONSTANT NUMBER := 2;
   USER_AND_COMPANY       CONSTANT NUMBER := 3;


-- ===== Data types for Bulk Collections ====
   TYPE companyNames  IS TABLE of msc_companies.company_name%TYPE;
   TYPE companySites IS TABLE of msc_company_sites.company_site_name%TYPE;
--   TYPE customerClassCodes IS TABLE of msc_companies.customer_class_code%TYPE;
--   TYPE calendarCodes IS TABLE of msc_companies.calendar_code%TYPE;
   TYPE number_arr IS TABLE OF NUMBER;
   TYPE date_arr IS TABLE OF DATE;
   TYPE char3_arr IS TABLE OF VARCHAR2(3);
   TYPE char_arr IS TABLE OF VARCHAR2(1);
   TYPE locationCodes IS TABLE OF msc_company_sites.location%TYPE;

   TYPE partnerAddresses IS TABLE OF msc_trading_partner_sites.partner_address%TYPE;
   TYPE countries IS TABLE OF msc_trading_partner_sites.country%TYPE;
   TYPE states IS TABLE OF msc_trading_partner_sites.state%TYPE;
   TYPE cities IS TABLE OF msc_trading_partner_sites.city%TYPE;
   TYPE postalCodes IS TABLE OF msc_trading_partner_sites.postal_code%TYPE;
   TYPE items IS TABLE OF msc_system_items.item_name%TYPE;
   TYPE rowids IS TABLE OF VARCHAR2(100);
   TYPE descriptions IS TABLE OF msc_item_customers.description%TYPE;
   TYPE uomCodes IS TABLE OF msc_item_customers.uom_code%TYPE;
   TYPE plannerCodes IS TABLE OF msc_item_customers.planner_code%TYPE;
   TYPE deliveryCalCodes IS TABLE OF msc_item_suppliers.delivery_calendar_code%TYPE;
   TYPE addressLines IS TABLE OF msc_company_sites.address1%TYPE;
   TYPE counties IS TABLE OF msc_st_trading_partner_sites.county%TYPE;
   TYPE provinces IS TABLE OF msc_st_trading_partner_sites.province%TYPE;
   TYPE users IS TABLE OF fnd_user.user_name%TYPE;

   FUNCTION SCE_TRANSFORM_KEYS(p_instance_id    NUMBER,
                         p_current_user   NUMBER,
                   p_current_date   DATE,
                   p_last_collection_id   NUMBER,
                   p_is_incremental_refresh BOOLEAN,
                   p_is_complete_refresh BOOLEAN,
                   p_is_partial_refresh BOOLEAN,
				   p_is_cont_refresh  BOOLEAN,
                   p_supplier_enabled NUMBER,
                   p_customer_enabled NUMBER) RETURN BOOLEAN;
   PROCEDURE LOG_MESSAGE( pBUFF IN  VARCHAR2);

   PROCEDURE CREATE_NEW_COMPANIES( p_current_user  NUMBER,
                     p_current_date DATE,
                       p_last_collection_id  NUMBER );

   PROCEDURE UPDATE_COMPANY_SITE_NAMES;
   PROCEDURE CREATE_NEW_RELATIONSHIPS;
   PROCEDURE POPULATE_COMPANY_ID_LID;
   PROCEDURE CREATE_NEW_COMPANY_SITES;
   FUNCTION  CLEANSE_DATA_FOR_SCE(p_instance_id NUMBER,
                                  p_my_company  VARCHAR2) RETURN BOOLEAN;
   PROCEDURE COLLECT_COMPANY_SITES;
   PROCEDURE POPULATE_COMPANY_SITE_ID_LID;
   PROCEDURE POPULATE_TP_MAP_TABLE(p_instance_id  NUMBER);
 --  PROCEDURE CREATE_NEW_COMPANY_LOCATIONS (p_instance_id  NUMBER);
 --  PROCEDURE COLLECT_COMPANY_LOCATIONS (p_instance_id  NUMBER);
   PROCEDURE CLEANSE_TP_ITEMS (p_instance_id NUMBER);
   PROCEDURE LOAD_ITEM_CUSTOMERS (p_instance_id NUMBER);
 --  PROCEDURE LOAD_SCE_SUPPLIER_CAPACITY (p_instance_id NUMBER,
 --                      p_current_user   NUMBER,
 --                      p_current_date   DATE,
 --                      p_last_collection_id NUMBER);

   FUNCTION GET_MY_COMPANY return VARCHAR2;

   PROCEDURE PULL_USER_COMPANY(p_dblink       varchar2,
                               p_instance_id       NUMBER,
                               p_return_status OUT NOCOPY BOOLEAN,
                        p_user_company_mode NUMBER);

   PROCEDURE LOAD_USER_COMPANY (p_sr_instance_id NUMBER);

   PROCEDURE PROCESS_COMPANY_CHANGE(p_status OUT NOCOPY NUMBER);

END MSC_CL_SCE_COLLECTION;
 

/
