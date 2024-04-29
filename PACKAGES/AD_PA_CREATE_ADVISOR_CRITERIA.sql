--------------------------------------------------------
--  DDL for Package AD_PA_CREATE_ADVISOR_CRITERIA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AD_PA_CREATE_ADVISOR_CRITERIA" AUTHID CURRENT_USER as
/* $Header: adpaincs.pls 115.2 2004/06/02 12:07:33 sallamse ship $*/

Procedure insert_criteria(p_advisor_criteria_id           varchar2,
                p_advisor_criteria_description            varchar2,
                p_pre_seeded_flag                         varchar2,
                p_last_updated_by                         number default 1,
                p_created_by                              number default 1);

Procedure insert_criteria_prod(p_advisor_criteria_id      varchar2,
                p_product_abbreviation                    varchar2,
                p_product_family_abbreviation             varchar2,
                p_require_family_pack                     varchar2,
                p_require_mini_pack                       varchar2,
                p_require_high_priority                   varchar2,
                p_last_updated_by                         number default 1,
                p_created_by                              number default 1);

end ad_pa_create_advisor_criteria;

 

/
