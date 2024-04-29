--------------------------------------------------------
--  DDL for Package AS_SC_DENORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_SC_DENORM" AUTHID CURRENT_USER AS
/* $Header: asxopdps.pls 115.28 2003/05/23 23:44:24 xding ship $ */

--
-- HISTORY
-- 04/07/2000       NACHARYA    Created
-- 12/22/2000       SOLIN       Bug 1549115
--                              Add a new column BUSINESS_GROUP_NAME in
--                              AS_SALES_CREDITS_DENORM
-- 06/20/2001       SMALLINA    Bug 1836786

-- Constants
   G_PKG_NAME               Constant VARCHAR2(30):='AS_SC_REFRESH_DENORM';
   G_FILE_NAME              Constant VARCHAR2(12):='asxopdps.pls';
   G_COMMIT_SIZE            Constant Number := 10000;

   -- The following two variables are used to indicate debug message is
   -- written to message stack(G_DEBUG_TRIGGER) or to log/output file
   -- (G_DEBUG_CONCURRENT).
   G_DEBUG_CONCURRENT       CONSTANT NUMBER := 1;
   G_DEBUG_TRIGGER          CONSTANT NUMBER := 2;

 -- Global variables
   G_Debug                  Boolean := True;
   G_LANG	        VARCHAR2(10) := userenv('LANG');
   G_PREFERRED_CURRENCY as_period_rates.TO_CURRENCY%Type := FND_PROFILE.VALUE('AS_PREFERRED_CURRENCY');
   G_CONVERSION_TYPE    as_period_rates.conversion_type%Type :=FND_PROFILE.VALUE('AS_MC_DAILY_CONVERSION_TYPE');
   G_PERIOD_TYPE        as_period_rates.PERIOD_TYPE%Type := FND_PROFILE.VALUE('AS_DEFAULT_PERIOD_TYPE');

Type sales_credit_id_list is Table of as_sales_credits_denorm.sales_credit_id%type Index by Binary_integer;
Type sales_group_name_list is Table of as_sales_credits_denorm.sales_group_name%type Index by Binary_integer;
Type sales_rep_name_list is Table of as_sales_credits_denorm.sales_rep_name%type Index by Binary_integer;
Type employee_number_list is Table of as_sales_credits_denorm.employee_number%type Index by Binary_integer;
Type customer_name_list is Table of as_sales_credits_denorm.customer_name%type Index by Binary_integer;
Type competitor_name_list is Table of as_sales_credits_denorm.competitor_name%type Index by Binary_integer;
Type owner_person_name_list is Table of as_sales_credits_denorm.owner_person_name%type Index by Binary_integer;
Type owner_last_name_list is Table of as_sales_credits_denorm.owner_last_name%type Index by Binary_integer;
Type owner_first_name_list is Table of as_sales_credits_denorm.owner_first_name%type Index by Binary_integer;
Type owner_group_name_list is Table of as_sales_credits_denorm.owner_group_name%type Index by Binary_integer;
Type customer_category_list is Table of as_sales_credits_denorm.customer_category%type Index by Binary_integer;
Type customer_category_code_list is Table of as_sales_credits_denorm.customer_category_code%type Index by Binary_integer;
Type sales_stage_list is Table of as_sales_credits_denorm.sales_stage%type Index by Binary_integer;
Type status_list is Table of as_sales_credits_denorm.status%type Index by Binary_integer;
Type last_name_list is Table of as_sales_credits_denorm.last_name%type Index by Binary_integer;
Type first_name_list is Table of as_sales_credits_denorm.first_name%type Index by Binary_integer;
Type interest_type_list is Table of as_sales_credits_denorm.interest_type%type Index by Binary_integer;
Type primary_interest_code_list is Table of as_sales_credits_denorm.primary_interest_code%type Index by Binary_integer;
Type secondary_interest_code_list is Table of as_sales_credits_denorm.secondary_interest_code%type Index by Binary_integer;
Type uom_description_list is Table of as_sales_credits_denorm.uom_description%type Index by Binary_integer;
Type item_description_list is Table of as_sales_credits_denorm.item_description%type Index by Binary_integer;
Type party_type_list is Table of as_sales_credits_denorm.party_type%type Index by Binary_integer;
Type partner_cust_name_list is Table of as_sales_credits_denorm.partner_customer_name%type Index by Binary_integer;
Type opp_created_name_list is Table of as_sales_credits_denorm.opportunity_created_name%type Index by Binary_integer;
Type opp_last_upd_name_list is Table of as_sales_credits_denorm.opportunity_last_updated_name%type Index by Binary_integer;
Type close_reason_men_list is Table of Varchar2(80) Index by Binary_integer;
Type business_group_name_list is Table of Varchar2(60) Index by Binary_integer;
Type close_reason_list is Table of as_leads_all.close_reason%type Index by Binary_integer;
Type rolling_frcst_flg_list is Table of as_sales_credits_denorm.rolling_forecast_flag%type Index by Binary_integer;
Type frcst_date_list is Table of as_sales_credits_denorm.forecast_date%type Index by Binary_integer;
Type opp_creation_date_list is Table of as_leads_all.creation_date%type Index by Binary_integer;
Type opp_created_by_list is Table of as_leads_all.created_by%type Index by Binary_integer;
Type attribute_category_list is Table of Varchar2(30) Index by Binary_integer;
Type attribute_list is Table of Varchar2(150) Index by Binary_integer;

scd_attribute_category attribute_category_list;
scd_attribute1 attribute_list;
scd_attribute2 attribute_list;
scd_attribute3 attribute_list;
scd_attribute4 attribute_list;
scd_attribute5 attribute_list;
scd_attribute6 attribute_list;
scd_attribute7 attribute_list;
scd_attribute8 attribute_list;
scd_attribute9 attribute_list;
scd_attribute10 attribute_list;
scd_attribute11 attribute_list;
scd_attribute12 attribute_list;
scd_attribute13 attribute_list;
scd_attribute14 attribute_list;
scd_attribute15 attribute_list;
scd_close_reason close_reason_list;
scd_frcst_date frcst_date_list;
scd_rolling_frcst_flg rolling_frcst_flg_list;
scd_opp_creation_date opp_creation_date_list;
scd_opp_created_by opp_created_by_list;
scd_opp_created_name opp_created_name_list;
scd_opp_last_upd_name opp_created_name_list;
scd_opp_last_upd_date opp_creation_date_list;
scd_opp_last_upd_by opp_created_by_list;

scd_sales_credit_id sales_credit_id_list;
scd_close_reason_men close_reason_men_list;
scd_business_group_name business_group_name_list;
scd_partner_cust_name partner_cust_name_list;
scd_sales_group_name sales_group_name_list;
scd_sales_rep_name sales_rep_name_list;
scd_employee_number employee_number_list;
scd_customer_name customer_name_list;
scd_competitor_name competitor_name_list;
scd_owner_group_name owner_group_name_list;
scd_owner_person_name owner_person_name_list;
scd_owner_last_name owner_last_name_list;
scd_owner_first_name owner_first_name_list;
scd_customer_category customer_category_list;
scd_customer_category_code customer_category_code_list;
scd_sales_stage sales_stage_list;
scd_status status_list;
scd_last_name last_name_list;
scd_first_name first_name_list;
scd_interest_type interest_type_list;
scd_primary_interest_code primary_interest_code_list;
scd_secondary_interest_code secondary_interest_code_list;
scd_uom_description uom_description_list;
scd_item_description item_description_list;
scd_party_type party_type_list;

Procedure Populate_as_period_days(
    ERRBUF       OUT NOCOPY VARCHAR2,
    RETCODE      OUT NOCOPY VARCHAR2,
    p_debug_mode IN  VARCHAR2,
    p_trace_mode IN  VARCHAR2);

Procedure insert_scd (ERRBUF  OUT NOCOPY Varchar2,
                      RETCODE OUT NOCOPY Varchar2,
                      p_cnt OUT NOCOPY Number);

Procedure Main(ERRBUF       OUT NOCOPY Varchar2,
    RETCODE      OUT NOCOPY Varchar2,
    p_mode       IN  Number,
    p_debug_mode IN  Varchar2,
    p_trace_mode IN  Varchar2);

Procedure Clear_snapshots;

End AS_SC_DENORM;

 

/
