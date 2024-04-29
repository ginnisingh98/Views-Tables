--------------------------------------------------------
--  DDL for Package BEN_BENBATCH_PERSONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BENBATCH_PERSONS" AUTHID CURRENT_USER as
/* $Header: benbatpe.pkh 120.2.12010000.1 2008/07/29 12:03:05 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation		       |
|			   Redwood Shores, California, USA		       |
|			        All rights reserved.			       |
+==============================================================================+

Name
	Benefit Batch Persons.
Purpose
	This package is used to create Person actions for batch related
        tasks.
History
        Date             Who        Version    What?
        ----             ---        -------    -----
        11-AUG-98        GPERRY     110.0      Created after moving code
                                               from benmngle.pkh
        26-AUG-98        GPERRY     115.1      Added p_person_selection_rule_id
                                               parameter.
        23-SEP-98        GPERRY     115.2      Added p_commit_data parameter
                                               for use with Prasads stuff.
        29-SEP-98        GPERRY     115.3      Added num persons out nocopy parameter.
        21-APR-99        GPERRY     115.4      Changes for temporal mode.
        03-AUG-99        GPERRY     115.5      Performance enhancements.
        22-DEC-99        GPERRY     115.6      Bug 2752 fixed.
                                               WWBUG 1096742.
                                               Life event mode supports all
                                               selection criteria.
        29-Jun-00        mhoyes     115.7      Added p_mode_cd to
                                               create_normal_person_actions.
        18-Sep-00        pbodla     115.8      - Healthnet changes : PB : Added parameter
                                               p_lmt_prpnip_by_org_typ_id
        02-Jul-02        pbodla     115.9      - ABSNCES - in case of absence mode
                                                 consider persons with absence
                                                 potential life events.
        15-Jul-02        pbodla     115.10     - ABSENCES - Fixed typo
        16-Jul-02        mmudigon   115.11     - Added driver commands
        31-Jan-03        pbodla     115.12     - GRADE/STEP - modified
                                                 create_life_person_actions
                                                 to support extra parameters.
        06-Feb-03        pbodla     115.13     - GRADE/STEP - modified
                                                 p_asg_events_to_all_sel_dt to date type
        01-Aug-03        rpgupta    115.15     - Grade/step changes
        14-Oct-04        abparekh   115.16     - GSP Rate Sync changes : Added p_lf_evt_oper_cd
                                                     to procedure create_life_person_actions
        03-Jan-06        nhunur     115.17     - cwb - changes for person type param.
        09-Aug-07        vvprabhu   115.18      Bug 5857493 - added g_audit_flag to
                                                 control person selection rule error logging
*/
-----------------------------------------------------------------------
-- Type definitions use max chunk size for limits
--
type l_number_type is varray(200) of number;
  g_audit_flag       boolean :=false;
-----------------------------------------------------------------------
procedure create_life_person_actions
          (p_benefit_action_id        in  number,
           p_business_group_id        in  number,
           p_person_id                in  number,
           p_ler_id                   in  number,
           p_person_type_id           in  number,
           p_benfts_grp_id            in  number,
           p_location_id              in  number,
           p_legal_entity_id          in  number,
           p_payroll_id               in  number,
           p_pstl_zip_rng_id          in  number,
           p_organization_id          in  number,
           p_person_selection_rule_id in  number,
           p_effective_date           in  date,
           p_chunk_size               in  number,
           p_threads                  in  number,
           p_num_ranges               out nocopy number,
           p_num_persons              out nocopy number,
           p_commit_data              in  varchar2,
           p_lmt_prpnip_by_org_flag   in  varchar2,
           -- GRADE/STEP : Added for grade/step benmngle
           p_org_heirarchy_id         in  number   default null,
           p_org_starting_node_id     in  number   default null,
           p_grade_ladder_id          in  number   default null,
           p_asg_events_to_all_sel_dt in  date     default null,
           p_rate_id                  in  number   default null ,
           p_per_sel_dt_cd            in  varchar2 default null,
           p_per_sel_dt_from          in  date     default null,
           p_per_sel_dt_to            in  date     default null,
           p_year_from                in  number   default null,
           p_year_to                  in  number   default null,
           p_cagr_id                  in  number   default null,
           p_qual_type                in  number   default null,
           p_qual_status              in  varchar2 default null,
	   -- 2940151
           p_per_sel_freq_cd          in     varchar2 default 'Y',
           p_id_flex_num              in     number   default null,
           p_concat_segs              in     varchar2 default null,
           -- end 2940151
           -- ABSENCES
           p_mode                     in  varchar2 default null,
           p_lf_evt_oper_cd           IN  varchar2 default null   /* GSP Rate Sync */
           );
-----------------------------------------------------------------------
procedure create_normal_person_actions
  (p_benefit_action_id        in     number
  ,p_mode_cd                  in     varchar2
  ,p_business_group_id        in     number
  ,p_person_id                in     number
  ,p_ler_id                   in     number
  ,p_person_type_id           in     number
  ,p_benfts_grp_id            in     number
  ,p_location_id              in     number
  ,p_legal_entity_id          in     number
  ,p_payroll_id               in     number
  ,p_pstl_zip_rng_id          in     number
  ,p_organization_id          in     number
  ,p_ler_override_id          in     number
  ,p_person_selection_rule_id in     number
  ,p_effective_date           in     date
  ,p_mode                     in     varchar2
  ,p_chunk_size               in     number
  ,p_threads                  in     number
  ,p_num_ranges                  out nocopy number
  ,p_num_persons                 out nocopy number
  ,p_commit_data              in     varchar2
  ,p_lmt_prpnip_by_org_flag   in     varchar2
  ,p_popl_enrt_typ_cycl_id    in     number default NULL
  ,p_cwb_person_type          in     varchar2 default NULL
  ,p_lf_evt_ocrd_dt           in     date
  );
-----------------------------------------------------------------------
procedure create_restart_person_actions
          (p_benefit_action_id        in  number,
           p_effective_date           in  date,
           p_chunk_size               in  number,
           p_threads                  in  number,
           p_num_ranges               out nocopy number,
           p_num_persons              out nocopy number,
           p_commit_data              in  varchar2);
-----------------------------------------------------------------------
end ben_benbatch_persons;

/
