--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_PROCESS" AUTHID CURRENT_USER as
/* $Header: benenrol.pkh 120.1 2006/05/03 09:38:25 nkkrishn noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
        Enrollment Process
Purpose
        This is a wrapper procedure for Benefits enrollments,
        dependents and beneficiaries designation for Enrollments conversion,
        ongoing mass updates.
History
	Date		Who		Version	What?
	----		---		-------	-----
	01 Nov 05	ikasire 	115.0		Created
        02 May 06       nkkrishn        115.11          Fixed Beneficiary upload
*/
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< ENROLLMENT_INFORMATION >-------------------------|
-- -------------------------------------------------------------------------------+
procedure enrollment_information_detail
  (p_validate               in boolean  default false
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_ended_pl_id            in number   default null
  ,p_ended_opt_id           in number   default null
  ,p_ended_bnft_val         in number   default null
  ,p_effective_date         in date
  ,p_person_id              in number
  ,p_bnft_val               in number   default null
  ,p_acty_base_rt_id1       in number   default null
  ,p_rt_val1                in number   default null
  ,p_ann_rt_val1            in number   default null
  ,p_rt_strt_dt1            in date     default null
  ,p_rt_end_dt1             in date     default null
  ,p_acty_base_rt_id2       in number   default null
  ,p_rt_val2                in number   default null
  ,p_ann_rt_val2            in number   default null
  ,p_rt_strt_dt2            in date     default null
  ,p_rt_end_dt2             in date     default null
  ,p_acty_base_rt_id3       in number   default null
  ,p_rt_val3                in number   default null
  ,p_ann_rt_val3            in number   default null
  ,p_rt_strt_dt3            in date     default null
  ,p_rt_end_dt3             in date     default null
  ,p_acty_base_rt_id4       in number   default null
  ,p_rt_val4                in number   default null
  ,p_ann_rt_val4            in number   default null
  ,p_rt_strt_dt4            in date     default null
  ,p_rt_end_dt4             in date     default null
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date     default null
  ,p_enrt_cvg_thru_dt       in date     default null
  ,p_orgnl_enrt_dt          in date     default null);
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< POST_ENROLLMENT >------------------------------|
-- -------------------------------------------------------------------------------+
--
  procedure post_enrollment
  (p_validate               in boolean default false
  ,p_person_id              in number
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number default null
  -- ,p_flx_cr_flag            in varchar2 default 'N'
  ,p_proc_cd                in varchar2 default null
  ,p_business_group_id      in number
  ,p_effective_date         in date );
  --
-- --------------------------------------------------------------------------------
-- |-----------------------------< ENROLLMENT_INFORMATION >-------------------------|
-- -------------------------------------------------------------------------------+
procedure create_enrollment
  (p_validate               in boolean  default false
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_ended_pl_id            in number   default null
  ,p_ended_opt_id           in number   default null
  ,p_ended_bnft_val         in number   default null
  ,p_effective_date         in date
  ,p_person_id              in number
  ,p_bnft_val               in number   default null
  ,p_acty_base_rt_id1       in number   default null
  ,p_rt_val1                in number   default null
  ,p_ann_rt_val1            in number   default null
  ,p_rt_strt_dt1            in date     default null
  ,p_rt_end_dt1             in date     default null
  ,p_acty_base_rt_id2       in number   default null
  ,p_rt_val2                in number   default null
  ,p_ann_rt_val2            in number   default null
  ,p_rt_strt_dt2            in date     default null
  ,p_rt_end_dt2             in date     default null
  ,p_acty_base_rt_id3       in number   default null
  ,p_rt_val3                in number   default null
  ,p_ann_rt_val3            in number   default null
  ,p_rt_strt_dt3            in date     default null
  ,p_rt_end_dt3             in date     default null
  ,p_acty_base_rt_id4       in number   default null
  ,p_rt_val4                in number   default null
  ,p_ann_rt_val4            in number   default null
  ,p_rt_strt_dt4            in date     default null
  ,p_rt_end_dt4             in date     default null
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date     default null
  ,p_enrt_cvg_thru_dt       in date     default null
  ,p_orgnl_enrt_dt          in date     default null
  ,p_proc_cd                in varchar2 default null
  ,p_record_typ_cd          in varchar2 );
--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_DEPENDENT >-------------------------|
-- -------------------------------------------------------------------------------+
procedure process_dependent
  (p_validate               in boolean  default false
  ,p_person_id              in number
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_effective_date         in date
  ,p_contact_person_id      in number
  ,p_business_group_id      in number
  ,p_cvg_strt_dt            in date     default null
  ,p_cvg_thru_dt            in date     default null
  ,p_multi_row_actn         in boolean  default false
  ,p_record_typ_cd          in varchar2 );

--
-- --------------------------------------------------------------------------------
-- |-----------------------------< PROCESS_BENEFICIARY >-------------------------|
-- -------------------------------------------------------------------------------+
procedure process_beneficiary
  (p_validate               in boolean  default false
  ,p_person_id              in number
  ,p_pgm_id                 in number   default null
  ,p_pl_id                  in number   default null
  ,p_opt_id                 in number   default null
  ,p_bnft_val               in number   default null
  ,p_ler_id                 in number
  ,p_life_event_date        in date
  ,p_effective_date         in date
  ,p_bnf_person_id          in number
  ,p_business_group_id      in number
  ,p_dsgn_strt_dt           in date     default null
  ,p_dsgn_thru_dt           in date     default null
  ,p_prmry_cntngnt_cd       in varchar2
  ,p_pct_dsgd_num           in number
  ,p_amt_dsgd_val           in number    default null
  ,p_amt_dsgd_uom           in varchar2  default null
  ,p_addl_instrn_txt        in varchar2  default null
  ,p_multi_row_actn         in boolean   default true
  ,p_organization_id        in number    default null
  ,p_ttee_person_id         in number    default null
  ,p_record_typ_cd          in varchar2 );
--
--
end ben_enrollment_process;

 

/
