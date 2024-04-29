--------------------------------------------------------
--  DDL for Package BEN_PREMIUM_PLAN_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREMIUM_PLAN_CONCURRENT" AUTHID CURRENT_USER as
/* $Header: benprplc.pkh 115.1 2003/01/01 00:00:39 mmudigon ship $ */
--
/* ============================================================================
*    Name
*       Premium Process Concurrent Manager Processes for Plan Premiums
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Premium Calculation.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      01-Nov-99   lmcdonal   115.0      Created
*
* -----------------------------------------------------------------------------
*/
--
-- Global Cursors and Global variables.
--
g_record_error  exception;
g_debug         boolean := FALSE;
type rpt_str is table of varchar2(132) index by binary_integer;
g_rpt_cache     rpt_str;
g_rpt_cnt       binary_integer := 0;
-----------------------------------------------
type g_cache_log_file_rec is table of varchar2(255)
     index by binary_integer;
g_cache_log_file g_cache_log_file_rec;
-----------------------------------------------
type g_cache_person_process_object is record
    (person_id                ben_person_actions.person_id%type
    ,person_action_id         ben_person_actions.person_action_id%type
    ,object_version_number    ben_person_actions.object_version_number%type
    ,ler_id                   ben_person_actions.ler_id%type
        );
type g_cache_person_process_rec is table of g_cache_person_process_object
    index by binary_integer;
g_cache_person_process g_cache_person_process_rec;
------------------------------------------------------------------
--            PROCESS
------------------------------------------------------------------
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_first_day_of_month       in     varchar2
                 ,p_mo_num                   in     number
                 ,p_yr_num                   in     number
                 ,p_threads            in     number
                 ,p_chunk_size         in     number
                 ,p_max_errors         in     number
                 ,p_restart            in     boolean default FALSE ) ;

procedure do_multithread
             (errbuf                     out nocopy varchar2
             ,retcode                    out nocopy number
             ,p_validate              in     varchar2 default 'N'
             ,p_benefit_action_id     in     number
             ,p_thread_id             in     number
             ,p_effective_date        in     varchar2
             ,p_business_group_id     in     number
             ,p_mo_num                in     number
             ,p_yr_num                in     number
             ,p_first_day_of_month    in     varchar2
             ) ;
End ben_premium_plan_concurrent;

 

/
