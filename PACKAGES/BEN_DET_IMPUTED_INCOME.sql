--------------------------------------------------------
--  DDL for Package BEN_DET_IMPUTED_INCOME
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DET_IMPUTED_INCOME" AUTHID CURRENT_USER as
/* $Header: bendeimp.pkh 120.0 2005/05/28 04:04:25 appldev noship $ */

  procedure p_comp_imputed_income(
    p_person_id                      in  number
   ,p_enrt_mthd_cd                   in  varchar2
   ,p_business_group_id              in  number
   ,p_per_in_ler_id                  in  number
   ,p_effective_date                 in  date
-- Always supply this param as false unless its FIDO
   ,p_ctrlm_fido_call                in boolean default true
   ,p_validate                       in boolean default false
   ,p_no_choice_flag                 in boolean default false);

END ben_det_imputed_income;

 

/
