--------------------------------------------------------
--  DDL for Package BEN_MANAGE_DEFAULT_ENRT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_MANAGE_DEFAULT_ENRT" AUTHID CURRENT_USER as
/* $Header: beneadeb.pkh 120.0.12010000.2 2009/07/29 13:51:19 pvelvano ship $ */
/* ===========================================================================+
 * Name
 *   Manage Default enrollment
 * Purpose
 *      This package is used to check validity of parameters passed in via SRS
 *      or via a PL/SQL function or procedure. This package will make a call
 *      to process default enrollment for all comp. object for each person
 *      that their default enrollment date is over due.
 *
 * Version Date        Author    Comment
 * -------+-----------+---------+----------------------------------------------
 * 110.0   25 Mar 1998 Hugh Dang Initial Created.
 * 115.2   28 Oct 1998 Hugh Dang Add new procedure default_comp_obj
 *                               declaration.
 * 115.3   24 Nov 1998 Hugh Dang Remove some of record declaration and add
 *                               master flag on master multi will not kill
 *                               itself in order to submit report and complete
 *                               its task.
 * 115.4   20-Dec-1998 Hugh Dang Add audit log parameter into procedure. and
 *                               remove p_mode paramater from Process.
 * 115.5   22-Feb-1999 Hugh Dang Chagne p_effective_date data type from date
 *                               to varchar2
 * 115.6   22-May-2000 GPERRY    Added l_number_type varray.
 * 115.8   03-Jul-2001 tmathers  9i compliance fix.
 *
 * 115.9   19-dec-2002 pabodla   NOCOPY Changes
 * 115.10  19-dec-2002 pabodla   Added dbdrv commands
 * 115.12  13-sep-2004 vvprabhu  Bug 3876613 Procedure Default_Comp_obj_w added
 * 115.13  05-nov-2004 vvprabhu  Bug 3978573 parameter p_called_frm_ss added to
 *                               Default_Comp_Obj to suppress multirowedit
 * 115.14  28-Jul-2008 velvanop  Fidelity Enhancement Bug No: 8716679
 *                               The enhancement request is to reinstate elections from an intervening event
 *                               with a life event that is backed out and reprocessed. The objective is to allow
 *                               customers to have the ability to determine whether elections made for
 *                               intervening events should be brought forward for a backed out life events.
 * ==========================================================================+
 */
--
-- Global Cursors and Global variables.
--
g_debug		    boolean := FALSE;
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
-- Type definitions use max chunk size for limits
--
type l_number_type is varray(200) of number;
--
Procedure process
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number
  ,p_effective_date           in     varchar2
  ,p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number   default null
  ,p_person_type_id           in     number   default null
  ,p_business_group_id        in     number
  ,p_popl_enrt_typ_cycl_id    in     number   default null
  ,p_person_selection_rule_id in     number   default null
  ,p_ler_id                   in     number   default null
  ,p_organization_id          in     number   default null
  ,p_benfts_grp_id            in     number   default null
  ,p_location_id              in     number   default null
  ,p_legal_entity_id          in     number   default null
  ,p_payroll_id               in     number   default null
  ,p_debug_messages           in     varchar2 default 'N'
  ,p_audit_log                in     varchar2 default 'N'
  );
Procedure restart
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_benefit_action_id        in     number
  );
Procedure do_multithread
  (errbuf                        out nocopy varchar2
  ,retcode                       out nocopy number
  ,p_validate                 in     varchar2 default 'N'
  ,p_benefit_action_id        in     number
  ,p_thread_id                in     number
  ,p_effective_date           in     varchar2
  ,p_business_group_id        in     number
  ,p_audit_log                in     varchar2 default 'N'
  );
Procedure process_default_enrt
  (p_validate                 in     varchar2 default 'N'
  ,p_person_id                in     number default null
  ,p_person_action_id         in     number default null
  ,p_object_version_number    in out nocopy number
  ,p_business_group_id        in     number
  ,p_effective_date           in     date
  ,p_batch_flag               in     Boolean default FALSE
  ,p_audit_log                in     varchar2 default 'N'
  );

--Added extra parameters to default only the explicit elections
--from intervening LE. Parameter 'p_reinstate_dflts_flag' controls
--normal defaulting process and defaulting only the explicit elections
--from intervening lifevent(parameter p_prev_per_in_ler_id

Procedure Default_Comp_obj
  (p_validate           in     Boolean default FALSE
  ,p_per_in_ler_id      in     Number
  ,p_person_id          in     Number
  ,p_business_group_id  in     Number
  ,p_effective_date     in     Date
  ,p_pgm_id             in     Number
  ,p_pl_nip_id          in     Number
  ,p_susp_flag             out nocopy Boolean
  ,p_batch_flag         in     Boolean default FALSE
  ,p_cls_enrt_flag      in     Boolean default TRUE
  ,p_called_frm_ss      in     Boolean default FALSE  -- Bug 3978573
  ,p_reinstate_dflts_flag in varchar2 default 'N' -- Enhancement Bug :8716679
  ,p_prev_per_in_ler_id in Number default null -- Enhancement Bug :8716679
  );

Procedure Default_Comp_obj_w
  (p_validate           in     varchar2 default 'TRUE'
  ,p_per_in_ler_id      in     Number
  ,p_person_id          in     Number
  ,p_business_group_id  in     Number
  ,p_effective_date     in     Date
  ,p_pgm_id             in     Number
  ,p_pl_nip_id          in     Number default null
  ,p_susp_flag             out nocopy varchar2
  ,p_batch_flag         in     varchar2 default 'FALSE'
  ,p_cls_enrt_flag      in     varchar2 default 'FALSE'
  );
End ben_manage_default_enrt;

/
