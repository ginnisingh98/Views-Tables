--------------------------------------------------------
--  DDL for Package BEN_COMP_OBJECT_LIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_COMP_OBJECT_LIST" AUTHID CURRENT_USER AS
/* $Header: bebmbcol.pkh 120.0.12010000.2 2009/01/13 07:02:48 krupani ship $ */
--
procedure init_comp_object_list_globals;
--
procedure flush_multi_session_cache
  (p_effective_date    in    date   default null
  ,p_business_group_id in    number default null
  ,p_mode              in    varchar2 default null   -- bug 7700173
  );
--
procedure build_comp_object_list
  (p_benefit_action_id      in number default -1
  ,p_comp_selection_rule_id in number default null
  ,p_effective_date         in date
  ,p_pgm_id                 in number default null
  ,p_business_group_id      in number default null
  ,p_pl_id                  in number default null
  ,p_oipl_id                in number default null
  -- PB : 5422 :
  ,p_asnd_lf_evt_dt         in date default null
  -- ,p_popl_enrt_typ_cycl_id  in number default null
  ,p_no_programs            in varchar2 default 'N'
  ,p_no_plans               in varchar2 default 'N'
  ,p_rptg_grp_id            in number default null
  ,p_pl_typ_id              in number default null
  ,p_opt_id                 in number default null
  ,p_eligy_prfl_id          in number default null
  ,p_vrbl_rt_prfl_id        in number default null
  ,p_thread_id              in number default null
  ,p_mode                   in varchar2
  ,p_person_id              in number default null
  --
  -- PB : Helathnet change.
  --
  ,p_lmt_prpnip_by_org_flag in varchar2 default 'N'
  );
--
/* GSP Rate Sync */
procedure build_gsp_rate_sync_coobj_list
   (p_effective_date         IN DATE
   ,p_business_group_id      IN NUMBER DEFAULT NULL
   ,p_pgm_id                 IN NUMBER DEFAULT NULL
   ,p_pl_id                  IN NUMBER DEFAULT NULL
   ,p_opt_id                 IN NUMBER DEFAULT NULL
   ,p_plip_id                IN NUMBER DEFAULT NULL
   ,p_ptip_id                IN NUMBER DEFAULT NULL
   ,p_oipl_id                IN NUMBER DEFAULT NULL
   ,p_oiplip_id              IN NUMBER DEFAULT NULL
   ,p_person_id              in number default null
   ) ;
--
END ben_comp_object_list;

/
