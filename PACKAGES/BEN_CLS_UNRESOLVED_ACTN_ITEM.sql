--------------------------------------------------------
--  DDL for Package BEN_CLS_UNRESOLVED_ACTN_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLS_UNRESOLVED_ACTN_ITEM" AUTHID CURRENT_USER as
/* $Header: benuneai.pkh 120.0.12010000.1 2008/07/29 12:32:02 appldev ship $ */
/* ========================================================================
Name:
  Cls_unresolved_act_item
Purpose
  This package is used to all unsolved action items.
History
  Ver    Date        Who         What?
  ------ ----------- ----------- ---------------------------------------------
  115.0  01-Sep-1998 Hugh Dang   Initial Created.
  115.1  12-Dec-1998 Hugh Dang   Remove local procedure and call batch_utils.
  115.2  30-Dec-1998 Hugh Dang   Add audit log flag and new procedure restart.
  115.3  22-Feb-1999 Hugh Dang   Changed p_effective_date data type.
  115.4  11-dec-2002  hmani      NoCopy changes

===========================================================================
*/
--
-- Global type declaration
--
type g_cache_person_process_object is record
   	(person_id                ben_person_actions.person_id%type
   	,person_action_id         ben_person_actions.person_action_id%type
   	,object_version_number    ben_person_actions.object_version_number%type
   	,ler_id                   ben_person_actions.ler_id%type
    );
type g_cache_person_process_rec is table of g_cache_person_process_object
    index by binary_integer;
--
-- Global varaibles.
--
g_debug		     boolean := FALSE;
--
-- ===========================================================================
--                   << Procedure: *cls_per_unresolved_actn_item* >>
-- ===========================================================================
--
procedure cls_per_unresolved_actn_item
            (p_person_id               in  number
            ,p_effective_date          in  date
            ,p_business_group_id       in  number
            ,p_overwrite_flag          in  boolean  default FALSE
            ,p_batch_flag              in  boolean  default FALSE
            ,p_validate                in  boolean  default FALSE
            ,p_person_action_id        in  number   default NULL
            ,p_object_version_number   in  number   default NULL
            ,p_audit_log               in  varchar2 default 'N'
            );
--
-- ===========================================================================
--                   << Procedure: *do_multithread* >>
-- ===========================================================================
--
Procedure do_multithread
            (errbuf                     out nocopy varchar2
            ,retcode                    out nocopy number
            ,p_validate              in     varchar2 default 'N'
            ,p_benefit_action_id     in     number
            ,p_thread_id             in     number
            ,p_effective_date        in     varchar2
            ,p_business_group_id     in     number
            ,p_audit_log             in     varchar2 default 'N'
            );
--
-- ===========================================================================
--                   << Procedure: *Process* >>
-- ===========================================================================
--
Procedure Process
            (errbuf                       out nocopy varchar2
            ,retcode                      out nocopy number
            ,p_benefit_action_id       in     number
            ,p_effective_date          in     varchar2
            ,p_business_group_id       in     number
            ,p_pgm_id                  in     number   default NULL
            ,p_pl_nip_id               in     number   default NULL
            ,p_location_id             in     number   default NULL
            ,p_Person_id               in     number   default NULL
            ,p_Person_selection_rl     in     number   default NULL
            ,p_validate                in     varchar2 default 'N'
            ,p_debug_messages          in     varchar2 default 'N'
            ,p_audit_log               in     varchar2 default 'N'
            );
--
-- ===========================================================================
--                   << Procedure: *Restart* >>
-- ===========================================================================
--
Procedure restart
            (errbuf                        out nocopy varchar2
            ,retcode                       out nocopy number
            ,p_benefit_action_id        in     number
            );
End ben_cls_unresolved_Actn_item;

/
