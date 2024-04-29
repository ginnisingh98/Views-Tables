--------------------------------------------------------
--  DDL for Package BEN_CONC_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CONC_REPORTS" AUTHID CURRENT_USER as
/*$Header: becncrep.pkh 115.4 2003/01/20 09:28:15 vsethi noship $*/
--
/*
Name
   Benefits Concurrent reports process
Purpose
  This is a batch process that accepts parameters from conc request window
  and submits reports.
History
  Version Date       Author     Comment
  -------+----------+----------+------------------------------------------------
  115.0   28-SEP-02  nhunur    Created
  115.3   30-Dec-2002 mmudigon NOCOPY
  115.4   20-Jan-02  vsethi    Made procedure rep_person_selection_rule as public
  ------------------------------------------------------------------------------
*/
--
procedure process
    (errbuf                     out nocopy    varchar2
    ,retcode                    out nocopy    number
    ,p_report_name              in     varchar2
    ,p_effective_date           in     varchar2
    ,p_benefit_action_id        in     number   default null
    ,p_pgm_id                   in     number   default null
    ,p_pl_nip_id                in     number   default null
    ,p_plan_in_pgm_flag         in     varchar2 default 'N'
    ,p_organization_id          in     number   default null
    ,p_location_id              in     number   default null
    ,p_person_id                in     number   default null
    ,p_ler_id                   in     number   default null
    ,p_lf_evt_ocrd_dt           in     varchar2 default null
    ,p_person_selection_rule_id in     number   default null
    ,p_comp_selection_rule_id   in     number   default null
    ,p_business_group_id        in     number
    ,p_reporting_group_id       in     number   default null
    ,p_svc_area_id	        in     number   default null
    ,p_assignment_type          in     varchar2 default null
    ,p_cvg_strt_dt	        in     varchar2 default null
    ,p_cvg_end_dt		in     varchar2 default null
    ,p_person_type_id           in     number   default null
    ,p_ben_sel_flag             in     varchar2 default 'Y'
    ,p_flx_sum_flag     	in     varchar2 default 'Y'
    ,p_actn_items_flag     	in     varchar2 default 'Y'
    ,p_cov_dpnt_flag     	in     varchar2 default 'Y'
    ,p_prmy_care_flag           in     varchar2 default 'Y'
    ,p_beneficaries_flag        in     varchar2 default 'Y'
    ,p_certifications_flag      in     varchar2 default 'Y'
    ,p_disp_epe_flxfld_flag     in     varchar2 default 'Y'
    ,p_disp_flex_fields         in     varchar2 default 'Y'
  )  ;
 --
 procedure rep_person_selection_rule
     (p_person_id                in  Number
     ,p_business_group_id        in  Number
     ,p_person_selection_rule_id in  Number
     ,p_effective_date           in  Date
     ,p_batch_flag               in  Boolean default FALSE
     ,p_return                   in out nocopy varchar2
     ,p_err_message              in out nocopy varchar2 );
 --
end ben_conc_reports;

 

/
