--------------------------------------------------------
--  DDL for Package BEN_FORFEITURE_CONCURRENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_FORFEITURE_CONCURRENT" AUTHID CURRENT_USER as
/* $Header: benforfs.pkh 115.1 2002/12/31 01:58:23 ikasire noship $ */
--
/* ============================================================================
*    Name
*       Process Forfeiture Concurrent Manager Processes for Contributions
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Contribution Forfeiture Calculation.
*
*    History
*      Date        Who        Version    What?
*      -------     ---------  -------    --------------------------------------
*      14-Sep-01   pbodla     115.0      Created
*      30-Dec-02   ikasire    115.1      nocopy changes Plus dbdrv
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
g_rec         ben_type.g_report_rec ;
--
-- ============================================================================
--                        << Procedure: process_forfeitures >>
--  Description:
--      this procedure determines the forfeitures for the selected plan.
--
-- ============================================================================
procedure process_forfeitures (
             p_validate              in varchar2 default 'N'
            ,p_pl_id                 in number
            ,p_business_group_id     in number
            ,p_effective_date        in date
            ,p_person_id             in number   default null
            ,p_person_type_id        in number   default null
            ,p_person_selection_rule_id in number   default null);
--
------------------------------------------------------------------
--            PROCESS
------------------------------------------------------------------
procedure process(errbuf                        out nocopy varchar2
                 ,retcode                       out nocopy number
                 ,p_benefit_action_id        in     number   default null
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_organization_id          in     number   default null
                 ,p_frfs_perd_det_cd         in     varchar2 default null
                 ,p_person_id                in     number   default null -- For Future Enhancement.
                 ,p_person_type_id           in     number   default null -- For Future Enhancement.
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_typ_id                in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_comp_selection_rule_id   in     number   default null
                 ,p_person_selection_rule_id in     number   default null -- For Future Enhancement.
                 ,p_debug_messages           in     varchar2 default 'N'
                 ,p_audit_log_flag           in     varchar2 default 'N'
                 ,p_commit_data_flag         in     varchar2 default 'Y'
                 ) ;

-- 9999 Some of the parameters may not be necessary.
procedure do_multithread
             (errbuf                     out nocopy    varchar2
             ,retcode                    out nocopy    number
             ,p_benefit_action_id        in     number
             ,p_effective_date           in     varchar2
             ,p_validate                 in     varchar2 default 'N'
             ,p_business_group_id        in     number
             ,p_thread_id                in     number
--              ,p_organization_id          in     number   default null
--              ,p_frfs_perd_det_cd         in     varchar2 default null
--              ,p_person_id                in     number   default null -- For Future Enhancement.
--              ,p_person_type_id           in     number   default null -- For Future Enhancement.
--              ,p_pgm_id                   in     number   default null
--              ,p_pl_typ_id                in     number   default null
--              ,p_pl_id                    in     number   default null
--              ,p_comp_selection_rule_id   in     number   default null
--              ,p_person_selection_rule_id in     number   default null -- For Future Enhancement.
--              ,p_debug_messages           in     varchar2 default 'N'
--              ,p_audit_log_flag           in     varchar2 default 'N'
--              ,p_commit_data_flag         in     varchar2 default 'Y'
             ) ;
End ben_forfeiture_concurrent;

 

/
