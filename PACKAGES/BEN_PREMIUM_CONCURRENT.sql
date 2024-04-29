--------------------------------------------------------
--  DDL for Package BEN_PREMIUM_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PREMIUM_CONCURRENT" AUTHID CURRENT_USER as
/* $Header: benprcon.pkh 115.2 2003/01/01 00:00:30 mmudigon ship $ */
--
/* ============================================================================
*    Name
*       Premium Process Concurrent Manager Processes
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Premium Calculation.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      18-Jun-99   lmcdonal   115.0      Created
*      08-Nov-99   lmcdonal   115.1      p_first_day parm of multithread s/b char.
*                                        Remove some unnecessary globals.
*      31-Dec-02   mmudigon   115.2      NOCOPY and dbdrv commands
*
* -----------------------------------------------------------------------------
*/
--
-- Global Cursors and Global variables.
--
g_record_error	exception;
g_debug		    boolean := FALSE;
type rpt_str is table of varchar2(132) index by binary_integer;
g_rpt_cache     rpt_str;
g_rpt_cnt       binary_integer := 0;
type g_cache_log_file_rec is table of varchar2(255)
     index by binary_integer;
g_cache_log_file g_cache_log_file_rec;
type g_cache_person_process_object is record
   	(person_id                ben_person_actions.person_id%type
   	,person_action_id         ben_person_actions.person_action_id%type
   	,object_version_number    ben_person_actions.object_version_number%type
   	,ler_id                   ben_person_actions.ler_id%type
        );
type g_cache_person_process_rec is table of g_cache_person_process_object
    index by binary_integer;
g_cache_person_process g_cache_person_process_rec;

--
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_person_id                in     number   default null
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_person_selection_rule_id in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_organization_id          in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_debug_messages           in     varchar2 default 'N'
                 ) ;
procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id in     number
                  );
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
End ben_premium_concurrent;

 

/
