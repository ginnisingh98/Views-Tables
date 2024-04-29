--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_ELIG_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_ELIG_CONC" AUTHID CURRENT_USER as
/* $Header: benunvel.pkh 120.0 2005/05/28 09:32:43 appldev noship $ */
--
/* ============================================================================
*    Name
*       Eligibility Engine Concurrent Manager Process
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Eligibility Engine
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      01-jun-2004 mmudigon   115.0      Created
* -----------------------------------------------------------------------------
*/
--
-- Global Cursors and Global variables.
--
procedure process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number   default null
  ,p_effective_date           in     varchar2
  ,p_validate                 in     varchar2 default 'N'
  ,p_business_group_id        in     number
  ,p_person_id                in     number
  ,p_assignment_type          in     varchar2
  ,p_elig_obj_type            in     varchar2
  ,p_elig_obj_id              in     number
  ,p_organization_id          in     number   default null
  ,p_location_id              in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_debug_messages           in     varchar2 default 'N');
--
procedure restart
  (errbuf                 out nocopy varchar2
  ,retcode                out nocopy number
  ,p_benefit_action_id in     number);
--
procedure do_multithread
  (errbuf                     out nocopy varchar2
  ,retcode                    out nocopy number
  ,p_validate              in     varchar2 default 'N'
  ,p_benefit_action_id     in     number
  ,p_thread_id             in     number
  ,p_effective_date        in     varchar2
  ,p_business_group_id     in     number
  ,p_person_id             in     number
  ,p_assignment_type       in     varchar2
  ,p_elig_obj_type         in     varchar2
  ,p_elig_obj_id           in     number);
--
End ben_evaluate_elig_conc;

 

/
