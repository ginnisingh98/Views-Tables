--------------------------------------------------------
--  DDL for Package AD_PA_VALIDATE_CRITERIASET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PA_VALIDATE_CRITERIASET" AUTHID CURRENT_USER as
/* $Header: adpavacs.pls 120.1 2005/08/12 03:23:50 appldev noship $*/

Procedure validate_criteriaset(p_advisor_criteria_id  varchar2);

/* This function returns comma separated patches in column Merged_patches in PatchSummary page . Bug # 2813894 -KKSINGH */
function get_concat_mergepatches(p_ptch_drvr_id number) return varchar2;

/* This function  detemines to enable or disable Details Image in Action Summary page. Bug # 2803063 -KKSINGH */
function get_jobtiming_details(p_action_id number, p_program_run_id number, p_session_id number)
         return number ;

/* This function returns comma separated MiniPacks in column MiniPacks in PatchDetails page . Bug # 2803063 -KKSINGH */

function get_concat_minipks(p_ptch_drvr_id number) return varchar2;

/* This function returns comma separated product family desc for a give product abbr */
function get_cs_prod_fam_name(p_product_abbr varchar2) return varchar2;

/* This function returns comma separated product family abbr for a give product abbr */
function get_cs_prod_fam_abbr(p_product_abbr varchar2) return varchar2;

pragma restrict_references(get_concat_minipks, WNDS, WNPS);

end ad_pa_validate_criteriaset;

 

/
