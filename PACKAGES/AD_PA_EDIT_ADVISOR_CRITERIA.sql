--------------------------------------------------------
--  DDL for Package AD_PA_EDIT_ADVISOR_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PA_EDIT_ADVISOR_CRITERIA" AUTHID CURRENT_USER as
/* $Header: adpaedcs.pls 115.1 2002/10/10 20:10:31 rlotero ship $*/

Procedure edit_criteriaSet(p_advisor_criteria_id    varchar2,
                  p_product_abbreviation            varchar2,
                  p_require_family_pack             varchar2,
                  p_require_mini_pack               varchar2,
                  p_require_high_priority           varchar2);

end ad_pa_edit_advisor_criteria;

 

/
