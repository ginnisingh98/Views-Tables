--------------------------------------------------------
--  DDL for Package BEN_IREC_BACK_OUT_CONC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_IREC_BACK_OUT_CONC" AUTHID CURRENT_USER as
/* $Header: benircbo.pkh 120.0 2005/05/28 09:04 appldev noship $ */
--
/* ============================================================================
*    Name
*       Back-out iRecruitment Life Events Concurrent Manager Processes
*
*    Purpose
*       This is a new package added to backout data created by the
*       iRecruitment
*       This package houses the  procedure which would be called from
*       the concurrent manager.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      8-Sep-2004   hmani    115.0      Created
*
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
             ,p_person_id             in     number
             ,p_ocrd_date             in     varchar2
             ,p_assignment_id           in     number
             ,p_life_event_id         in     number
             ,p_bckt_stat_cd          in     varchar2
             ) ;


procedure process
              (errbuf                     out nocopy    varchar2
                 ,retcode                    out nocopy    number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_person_id                in     number
                 ,p_assignment_id            in     number
                 ,p_life_event_id            in     number
                 ,p_ocrd_date                in     varchar2
                 ,p_person_selection_rule_id in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
                ) ;

procedure p_back_out_irec_le
		(p_per_in_ler_id           in  number,
   		p_bckt_stat_cd            in  varchar2 default 'VOIDD',
   		p_business_group_id       in  number,
		p_effective_date          in  date);


end ben_irec_back_out_conc;

 

/
