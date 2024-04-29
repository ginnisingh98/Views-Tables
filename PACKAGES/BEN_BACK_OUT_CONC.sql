--------------------------------------------------------
--  DDL for Package BEN_BACK_OUT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_BACK_OUT_CONC" AUTHID CURRENT_USER as
/* $Header: benbocon.pkh 115.3 2003/05/13 17:23:38 mmudigon ship $ */
--
/* ============================================================================
*    Name
*       Back-out Life Events Concurrent Manager Process
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Back-out Life Events.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      13-Jul-99   isen       115.0      Created
*      04-Oct-99   gperry     115.1      Added p_bckt_stat_cd to process and
*                                        multithread.
*      27-Apr-03   mmudigon   115.3      Absences July FP enhancements
*
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
  ,p_life_event_id            in     number
  ,p_from_ocrd_date           in     varchar2
  ,p_to_ocrd_date             in     varchar2
  ,p_organization_id          in     number   default null
  ,p_location_id              in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_debug_messages           in     varchar2 default 'N'
  ,p_bckt_stat_cd             in     varchar2 default 'UNPROCD'
  ,p_abs_ler                  in     varchar2 default 'N');
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
  ,p_from_ocrd_date        in     varchar2
  ,p_to_ocrd_date          in     varchar2
  ,p_life_event_id         in     number
  ,p_organization_id       in     number
  ,p_location_id           in     number
  ,p_benfts_grp_id         in     number
  ,p_legal_entity_id       in     number
  ,p_bckt_stat_cd          in     varchar2
  ,p_abs_ler               in     varchar2);
--
End ben_back_out_conc;

 

/
