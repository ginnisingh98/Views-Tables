--------------------------------------------------------
--  DDL for Package BEN_CWB_CUSTOM_PERSON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_CUSTOM_PERSON_PKG" AUTHID CURRENT_USER as
/* $Header: bencwbpr.pkh 120.0 2005/05/28 04:00:51 appldev noship $ */
-- --------------------------------------------------------------------------
-- |---------------------------< get_custom_name >---------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom name
--
function get_custom_name(p_person_id        in number
                        ,p_assignment_id    in number
                        ,p_legislation_code in varchar2
                        ,p_group_pl_id      in number
                        ,p_lf_evt_ocrd_dt   in date
                        ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment1 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment1
--
function get_custom_segment1(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment2 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment2
--
function get_custom_segment2(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment3 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment3
--
function get_custom_segment3(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment4 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment4
--
--
function get_custom_segment4(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment5 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment5
--
--
function get_custom_segment5(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment6 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment6
--
--
function get_custom_segment6(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment7 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment7
--
--
function get_custom_segment7(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment8 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment8
--
--
function get_custom_segment8(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment9 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment9
--
--
function get_custom_segment9(p_person_id        in number
                            ,p_assignment_id    in number
                            ,p_legislation_code in varchar2
                            ,p_group_pl_id      in number
                            ,p_lf_evt_ocrd_dt   in date
                            ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment10 >------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment10
--
--
function get_custom_segment10(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return varchar2;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment11 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment11
--
function get_custom_segment11(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment12 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment12
--
function get_custom_segment12(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment13 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment13
--
function get_custom_segment13(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment14 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment14
--
--
function get_custom_segment14(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment15 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment15
--
--
function get_custom_segment15(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment16 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment16
--
--
function get_custom_segment16(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment17 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment17
--
--
function get_custom_segment17(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment18 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment18
--
--
function get_custom_segment18(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment19 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment19
--
--
function get_custom_segment19(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--
-- --------------------------------------------------------------------------
-- |-------------------------< get_custom_segment20 >-------------------------|
-- --------------------------------------------------------------------------
-- Description
--   This function returns the custom_segment20
--
--
function get_custom_segment20(p_person_id        in number
                             ,p_assignment_id    in number
                             ,p_legislation_code in varchar2
                             ,p_group_pl_id      in number
                             ,p_lf_evt_ocrd_dt   in date
                             ,p_effective_date   in date)
return number;
--


end BEN_CWB_CUSTOM_PERSON_PKG;


 

/
