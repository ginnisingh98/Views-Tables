--------------------------------------------------------
--  DDL for Package BEN_MANAGE_OPEN_ENRT_WNDW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MANAGE_OPEN_ENRT_WNDW" AUTHID CURRENT_USER as
/* $Header: benmnoew.pkh 120.0.12000000.1 2007/05/31 10:04:41 swjain noship $ */
--
/* ============================================================================
*    Name
*       MANAGE OPEN ENROLLMENT WINDOW Concurrent Manager Process
*
*    Purpose
*       This package simply houses the concurrent manager and multi-thread
*       processes for Managing Open Enrollment Window.
*
*    History
*      Date        Who        Version    What?
*      ---------   ---------  -------    --------------------------------------
*      14-Jul-06   swjain     115.0      Created
* -----------------------------------------------------------------------------
*/
--
-- ============================================================================
--                        << Procedure: Do_Multithread >>
--  Description:
--  	This procedure is called from 'process'.  It calls the update POPL.
-- ============================================================================
procedure do_multithread
                 (errbuf                     out nocopy varchar2
                 ,retcode                    out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_thread_id                in     number
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_lf_evt_ocrd_dt           in     varchar2 default null
                 ,p_ler_id                   in     number   default null
                 ,p_new_enrt_perd_end_dt     in     varchar2 default null
                 ,p_new_procg_end_dt         in     varchar2 default null
                 ,p_new_dflt_enrt_dt         in     varchar2 default null
                 ,p_no_of_days               in     number   default null
                 ,p_audit_log_flag           in     varchar2 default 'N');
-- +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--                   << Procedure: Restart >>
-- *****************************************************************
--
procedure restart (errbuf                 out nocopy varchar2
                  ,retcode                out nocopy number
                  ,p_benefit_action_id    in  number);
--
-- *************************************************************************
-- *                          << Procedure: Process >>
-- *************************************************************************
--  This is what is called from the concurrent manager screen
--
procedure process(errbuf                     out nocopy varchar2
                 ,retcode                    out nocopy number
                 ,p_benefit_action_id        in     number
                 ,p_effective_date           in     varchar2
                 ,p_validate                 in     varchar2 default 'N'
                 ,p_person_id                in     number   default null
                 ,p_person_selection_rule_id in     number   default null
                 ,p_business_group_id        in     number
                 ,p_pgm_id                   in     number   default null
                 ,p_pl_id                    in     number   default null
                 ,p_lf_evt_ocrd_dt           in     varchar2 default null
                 ,p_ler_id                   in     number   default null
                 ,p_new_enrt_perd_end_dt     in     varchar2 default null
                 ,p_new_procg_end_dt         in     varchar2 default null
                 ,p_new_dflt_enrt_dt         in     varchar2 default null
                 ,p_no_of_days               in     number   default null
                 ,p_organization_id          in     number   default null
                 ,p_benfts_grp_id            in     number   default null
                 ,p_location_id              in     number   default null
                 ,p_pstl_zip_rng_id          in     number   default null
                 ,p_rptg_grp_id              in     number   default null
                 ,p_legal_entity_id          in     number   default null
                 ,p_payroll_id               in     number   default null
                 ,p_audit_log_flag           in     varchar2 default 'N');
--
end BEN_MANAGE_OPEN_ENRT_WNDW;  -- End of Package

 

/
