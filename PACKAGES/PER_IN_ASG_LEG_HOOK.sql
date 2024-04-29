--------------------------------------------------------
--  DDL for Package PER_IN_ASG_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IN_ASG_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: peinlhas.pkh 120.0 2005/05/31 10:13:46 appldev noship $ */

PROCEDURE check_asg_update (p_datetrack_update_mode   IN VARCHAR2
                           ,p_effective_date           IN DATE
                           ,p_assignment_id            IN NUMBER
			   ,p_segment1                 IN VARCHAR2 -- tax unit
			   ,p_segment2                 IN VARCHAR2 -- pf_org
			   ,p_segment3                 IN VARCHAR2 -- pt_org
			   ,p_segment4                 IN VARCHAR2 -- esi_org
			   ,p_segment5                 IN VARCHAR2 -- factory
			   ,p_segment6                 IN VARCHAR2 -- estb
			   ,p_segment8                 IN VARCHAR2 -- PGA flag
			   ,p_segment9                 IN VARCHAR2 -- Sub Interest
			   ,p_segment10                IN VARCHAR2 -- Director
			   ,p_segment11                IN VARCHAR2 -- Specified
                           ) ;

END  per_in_asg_leg_hook;

 

/
