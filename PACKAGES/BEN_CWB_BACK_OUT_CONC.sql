--------------------------------------------------------
--  DDL for Package BEN_CWB_BACK_OUT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CWB_BACK_OUT_CONC" AUTHID CURRENT_USER as
/* $Header: bencwbbo.pkh 120.1.12000000.1 2007/01/19 15:19:44 appldev noship $ */
--
/* ============================================================================
*    Name
*       Back-out Compensation Life Events Concurrent Manager Processes
*
*    Purpose
*       This is a new package added to backout data created by the CWB global
*       budget.
*       This package houses the  procedure which would be called from
*       the concurrent manager.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      16-Jan-04   rpgupta    115.0      Created
*      08-Oct-04   pbodla     115.2      Added proc p_backout_global_cwb_event
*                                        to be called from online call.
*      26-May-06   maagrawa   115.3      New paramete update_summary in
*                                        delete_cwb_data
* -----------------------------------------------------------------------------
*/

procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id    in  number) ;


procedure do_multithread
             (errbuf                  out nocopy    varchar2
             ,retcode                 out nocopy    number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             ,p_ocrd_date             in     varchar2
             ,p_group_pl_id 	      in     number
             ,p_life_event_id         in     number
             ,p_bckt_stat_cd          in     varchar2
             ) ;


procedure delete_cwb_data
		 (p_per_in_ler_id     		in number
                  ,p_business_group_id 		in number
                  ,p_update_summary             in boolean default false
                  ) ;


procedure process
	          (errbuf                     out nocopy    varchar2
                 ,retcode                    out nocopy    number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_group_pl_id              in     number
                 ,p_life_event_id            in     number
                 ,p_ocrd_date                in     varchar2
                 ,p_person_selection_rule_id in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_bckt_stat_cd             in     varchar2 default 'UNPROCD'
                ) ;

procedure p_backout_global_cwb_event
                (
                 p_effective_date           in     date
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_group_pl_id              in     number
                 ,p_life_event_id            in     number   default null
                 ,p_lf_evt_ocrd_dt           in     date
                 ,p_person_id                in     number   default null
                 ,p_bckt_stat_cd             in     varchar2 default 'UNPROCD'
                );

end ben_cwb_back_out_conc;

 

/
