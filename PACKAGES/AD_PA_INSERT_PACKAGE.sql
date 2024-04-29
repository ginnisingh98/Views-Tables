--------------------------------------------------------
--  DDL for Package AD_PA_INSERT_PACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PA_INSERT_PACKAGE" AUTHID CURRENT_USER as
/* $Header: adpaips.pls 120.1 2006/03/24 03:25:44 msailoz noship $ */

--
-- Procedure to insert/update in table ad_pm_patches
--

procedure insert_ad_pm_patches
(
   bug_number_value            number,
   aru_update_date_value       varchar2,
   product_abbreviation_value  varchar2,
   product_family_abbv_value  varchar2,
   patch_name_value            varchar2,
   conc_request_id             number,
   bug_description_value       varchar2,
   is_family_pack_flag 	       varchar2,
   is_mini_pack_flag	       varchar2,
   is_high_priority_flag       varchar2,
   is_maint_pack_flag          varchar2,
   X_in_reference_family_pack  varchar2,
   X_reference_family_pack     varchar2,
   X_in_reference_mini_pack    varchar2,
   X_reference_mini_pack       varchar2,
   X_in_reference_maint_pack   varchar2,
   X_reference_maint_pack      varchar2,
   X_infobundle_upload_date    varchar2,
   X_creation_date             varchar2,
   X_last_updated_by           number,
   X_created_by                number,
   X_last_update_date          varchar2
);

-- msailoz bug#4956568 Set release name to R12
-- Procedure to insert/update in table ad_pm_patches for R12
--

procedure insert_ad_pm_patches
(
   bug_number_value            number,
   aru_update_date_value       varchar2,
   product_abbreviation_value  varchar2,
   product_family_abbv_value  varchar2,
   patch_name_value            varchar2,
   conc_request_id             number,
   bug_description_value       varchar2,
   is_high_priority_flag       varchar2,
   X_infobundle_upload_date    varchar2,
   X_creation_date             varchar2,
   X_last_updated_by           number,
   X_created_by                number,
   X_last_update_date          varchar2,
   is_code_level_flag           varchar2,
   p_patch_type                varchar2,
   p_entity_abbr                varchar2,
   p_entity_baseline            varchar2
);

--
-- Procedure to insert/update in ad_pm_product_info
--

procedure insert_ad_pm_product_info
 (
  X_product_abbreviation        varchar2,
  X_pseudo_product_flag         varchar2,
  X_product_family_flag         varchar2,
  X_application_short_name      varchar2,
  X_product_name                varchar2,
  X_product_family_abbreviation varchar2,
  X_product_family_name         varchar2,
  X_aru_update_date             varchar2,
  X_currDate                    varchar2 ,
  X_last_updated_by             number,
  X_created_by                  number
 );


--
-- Procedure to insert/update in ad_pm_prod_family_map
--  Added for Bug# 2814295 to update the new AD Patch Advisor
--  table ad_pm_prod_family_map

procedure insert_ad_pm_prod_family_map
 (
  X_product_abbreviation        varchar2,
  X_product_family_abbreviation varchar2,
  X_aru_update_date             varchar2,
  X_currDate                    varchar2,
  X_last_updated_by             number,
  X_created_by                  number
 );


end ad_pa_insert_package;

 

/
