--------------------------------------------------------
--  DDL for Package BEN_PURGE_BCKDT_VOIDED
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PURGE_BCKDT_VOIDED" AUTHID CURRENT_USER as
/* $Header: benprbck.pkh 120.1.12010000.1 2008/07/29 12:28:23 appldev ship $ */
/* ========================================================================
 * Name
 *	Close Enrollment
 * Purpose
 *  This package is used to purge the benmngle rows for the bckt and voided life
 *   events
 * History
 *   Date        Who        Ver     What?
 *   ---------   ---------- ------  ----------------------------
 *   11 Nov 03   kmahendr   110.0   Created.
 *   17 May 04   kmahendr   115.1   Added additional parameters.
 *
 ===========================================================================
*/
--
-- Global varaibles.
--
type g_cache_person_process_object is record
        (person_id                ben_person_actions.person_id%type
        ,person_action_id         ben_person_actions.person_action_id%type
        ,object_version_number    ben_person_actions.object_version_number%type
    );
type g_cache_person_process_rec is table of g_cache_person_process_object
    index by binary_integer;
g_debug		                    boolean := FALSE;
--
-- Procedure declaration.
--
Procedure purge_single_person
            (p_effective_date          in  date
            ,p_business_group_id       in  number
            ,p_person_id                in  Number     default NULL
            ,p_life_event_id            in     number   default null
            ,p_from_ocrd_date           in     date default null
            ,p_to_ocrd_date             in     date
            ,p_life_evt_typ_cd          in     varchar2 default null
            ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
            ,p_audit_log_flag           in     varchar2 default 'N'
            ,p_delete_life_evt          in     varchar2 default 'N'
            );
--
Procedure process
            (errbuf                        out nocopy varchar2
            ,retcode                       out nocopy number
            ,p_benefit_action_id        in     number
            ,p_effective_date           in     varchar2
            ,p_business_group_id        in     number
            ,p_Person_id                in     number     default NULL
            ,p_Person_selection_rl      in     number     default NULL
            ,p_life_event_id            in     number   default null
            ,p_from_ocrd_date           in     varchar2 default null
            ,p_to_ocrd_date             in     varchar2
            ,p_organization_id          in     number   default null
            ,p_location_id              in     number   default null
            ,p_benfts_grp_id            in     number   default null
            ,p_legal_entity_id          in     number   default null
            ,p_payroll_id               in     number   default null
            ,p_life_evt_typ_cd          in     varchar2 default null
            ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
            ,p_audit_log_flag           in     varchar2 default 'N'
            ,p_delete_life_evt          in     varchar2 default 'N'
	    ,p_delete_ptnl_life_evt     in     varchar2 default 'N'
            ) ;
--
Procedure do_multithread
            (errbuf                     out nocopy varchar2
            ,retcode                    out nocopy number
            ,p_benefit_action_id        in     number
            ,p_thread_id                in     number
            ,p_effective_date           in     varchar2
            ,p_business_group_id        in     number
            ,p_life_event_id            in     number   default null
            ,p_from_ocrd_date           in     varchar2  default null
            ,p_to_ocrd_date             in     varchar2
            ,p_organization_id          in     number   default null
            ,p_location_id              in     number   default null
            ,p_benfts_grp_id            in     number   default null
            ,p_legal_entity_id          in     number   default null
            ,p_payroll_id               in     number   default null
            ,p_life_evt_typ_cd          in     varchar2 default null
            ,p_bckt_stat_cd             in     varchar2 default 'VOIDD'
            ,p_audit_log_flag           in     varchar2 default 'N'
            ,p_delete_life_evt          in     varchar2 default 'N'
            );
--
Procedure restart
            (errbuf                        out nocopy varchar2
            ,retcode                       out nocopy number
            ,p_benefit_action_id        in     number
            );
--
--
End ;

/
