--------------------------------------------------------
--  DDL for Package BEN_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_RULES" AUTHID CURRENT_USER as
/*$Header: benrules.pkh 120.1.12000000.1 2007/01/19 18:59:28 appldev ship $*/
--
/*
History
  Version Date       Author     Comment
  -------+----------+----------+---------------------------------------------
  115.0   08-Sep-99  maagrawa   Created.
  115.3   30-Jun-06  swjain     Added ler_id in chk_person_selection
  ----------------------------------------------------------------------------
*/

function chk_person_selection
    (p_person_selection_rule_id in number,
     p_person_id                in number,
     p_business_group_id        in number,
     p_effective_date           in date,
     p_ler_id                   in number) return boolean;

function chk_comp_object_selection
           (p_oipl_id                  in number,
            p_pl_id                    in number,
            p_pgm_id                   in number,
            p_pl_typ_id                in number,
            p_opt_id                   in number,
            p_business_group_id        in number,
            p_comp_selection_rule_id   in number,
            p_effective_date           in date) return boolean;

end ben_rules;

 

/
