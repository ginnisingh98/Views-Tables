--------------------------------------------------------
--  DDL for Package BEN_ICD_PLAN_DESIGN_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ICD_PLAN_DESIGN_SETUP" AUTHID CURRENT_USER as
/* $Header: benicdsetup.pkh 120.0 2007/04/17 20:07:05 maagrawa noship $ */


procedure create_setup(p_element_type_id in number
                ,p_business_group_id in number
                ,p_effective_date  in date
                ,p_pl_typ_id       in number
                ,p_pl_id           in number
                ,p_pl_name         in varchar2 default null
                ,p_pl_typ_name     in varchar2 default null
                ,p_elig_prfl_id    in number default null
                ,p_opt_name        in varchar2 default null
                ,p_option_level    in varchar2 default 'N');

procedure refresh_setup(p_element_type_id in number
                       ,p_business_group_id in number
                       ,p_effective_date  in date);

procedure delete_setup(p_element_type_id in number
                      ,p_business_group_id in number
                      ,p_effective_date in date);

end ben_icd_plan_design_setup;

/
