--------------------------------------------------------
--  DDL for Package BEN_PER_ASG_ELIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PER_ASG_ELIG" AUTHID CURRENT_USER as
/* $Header: benperel.pkh 120.1.12010000.2 2009/09/25 01:48:15 krupani ship $ */
--
g_allow_contingent_wrk varchar2(1);  -- Bug 8920881
procedure clear_down_cache(p_per_asg_cache_only boolean default false);

function eligible
  (p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_elig_obj_id                    in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_save_results                   in     boolean
  ) return boolean;

procedure eligible
  (p_person_id                      in     number
  ,p_assignment_type                in     varchar2
  ,p_elig_obj_id                    in     number
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_save_results                   in     boolean
);

function eligible
  (p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_elig_obj_id                    in     number   default null
  ,p_effective_date                 in     date
  ,p_business_group_id              in     number
  ,p_allow_contingent_wrk           in     varchar2 default 'N'        -- Bug 8920881
  ) return varchar2;

function elp_eligible
  (p_person_id                      in     number   default null
  ,p_assignment_id                  in     number   default null
  ,p_eligy_prfl_id                  in     number
  ,p_effective_date                 in     date
  ,p_pl_id                          in     number
  ,p_node_pl_id                     in     number
  ,p_business_group_id              in     number
  ) return varchar2;

end ben_per_asg_elig;

/
