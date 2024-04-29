--------------------------------------------------------
--  DDL for Package BEN_CLOSE_ENROLLMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_CLOSE_ENROLLMENT" AUTHID CURRENT_USER as
/* $Header: benclenr.pkh 120.1.12010000.1 2008/07/29 12:04:12 appldev ship $ */
/* ========================================================================
 * Name
 *	Close Enrollment
 * Purpose
 *  This package is used to update the enrollment record to indicate
 *  the participant has been enrolled.
 * History
 *   Date        Who        Ver     What?
 *   ---------   ---------- ------  ----------------------------
 *   07 May 98   maagrawa   110.0   Created.
 *   18 Jun 98   maagrawa   110.1   Two new parameters added p_pgm_id and
 *                                  p_pl_id
 *   01-Sep-1998 Hugh Dang  115.4   Remove pgm_id, pl_id from parameter list.
 *                                  Add one more procedure to close any
 *                                  un-resolved enrollment.
 *                                  <<Major modification in this ver.>>
 *   10-Dec-1998 Hugh Dang  115.5   Remove couple procedure declaration.
 *   11-Dec-1998 Hugh Dang  115.6   Add parmeter into close single enrollment.
 *   20-Dec-1998 Hugh Dang  115.7   Add restart procedure and add audit log.
 *   22-Feb-1998 Hugh Dang  115.8   Change p_effective_date data type for
 *                                  process and multithreads.
 *   16-APR-1999 pbodla     115.9   p_close_cd added to close_single_enrollment.
 *   16-APR-1999 pbodla     115.10
 *   02-Jun-1999 jcarpent   115.11  Added close_uneai_flag and uneai_eff_date
 *   05-Sep-2000 pbodla     115.12  - Bug 5422 : Allow different enrollment periods
 *                                  for programs for a scheduled  enrollment.
 *                                  p_popl_enrt_typ_cycl_id is removed.
 *
 *   13-Mar-2001 pbodla     115.13  - Bug 1674123 : close_cd paramter is
 *                                    can be passed from concurrent program.
 *   06-Jul-2001 stee       115.14  - Added reopen_single_life_event
 *                                    procedure. Bug # 1700853.
 *   04-Mar-2002 shdas      115.15  - Added procedures close_single_enrollment_ss
 *                                    and close_enrt_n_run_benmngle_ss for selfservice.
 *
rem  24-Dec-02   bmanyam     115.17    NOCOPY Changes
rem  14-Mar-2007 rgajula     115.18    Bug 5929635 - New parameter p_source added to reopen_single_life_event.
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
g_debug		                    boolean := FALSE;
--
-- Procedure declaration.
--
Procedure close_single_enrollment
            (p_per_in_ler_id           in  number
            ,p_effective_date          in  date
            ,p_business_group_id       in  number
            ,p_validate                in  boolean    default FALSE
            ,p_batch_flag              in  boolean    default FALSE
            ,p_person_action_id        in  Number     default NULL
            ,p_object_version_number   in  number     default NULL
            ,p_audit_log               in  varchar2   default 'N'
            ,p_close_cd                in  varchar2   default NULL
            ,p_close_uneai_flag        in  varchar2
            ,p_uneai_effective_date    in  date
            );
Procedure process
            (errbuf                       out nocopy varchar2
            ,retcode                      out nocopy number
            ,p_benefit_action_id       in     number
            ,p_effective_date          in     varchar2
            ,p_business_group_id       in     number
            ,p_pgm_id                  in     number     default NULL
            ,p_pl_nip_id               in     number     default NULL
            ,p_location_id             in     number     default NULL
            ,p_ler_id                  in     number     default NULL
            --
            -- PB : 5422 :
            -- ,p_popl_enrt_typ_cycl_id   in     number     default NULL
            ,p_lf_evt_ocrd_dt          in     varchar2       default NULL
            ,p_Person_id               in     number     default NULL
            ,p_Person_selection_rl     in     number     default NULL
            ,p_validate                in     varchar2   default 'N'
            ,p_debug_messages          in     varchar2   default 'N'
            ,p_audit_log               in     varchar2   default 'N'
            ,p_uneai_effective_date    in     varchar2 default null
            ,p_close_uneai_flag        in     varchar2 default 'Y'
            ,p_close_cd                in     varchar2 default 'NORCLOSE' -- 1674123
            ) ;
Procedure do_multithread
            (errbuf                     out nocopy varchar2
            ,retcode                    out nocopy number
            ,p_validate              in     varchar2   default 'N'
            ,p_benefit_action_id     in     number
            ,p_thread_id             in     number
            ,p_effective_date        in     varchar2
            ,p_business_group_id     in     number
            ,p_audit_log             in     varchar2   default 'N'
            );
Procedure restart
            (errbuf                        out nocopy varchar2
            ,retcode                       out nocopy number
            ,p_benefit_action_id        in     number
            );
--
Procedure reopen_single_life_event
            (p_per_in_ler_id           in     number
            ,p_person_id               in     number
            ,p_lf_evt_ocrd_dt          in     date
            ,p_effective_date          in     date
            ,p_business_group_id       in     number
            ,p_object_version_number   in     number
            ,p_validate                in     boolean  default FALSE
	    ,p_source                  in     varchar2 default 'reopen'  --Bug 5929635
            );
--
procedure close_single_enrollment_ss
  (p_per_in_ler_id           in     number
  ,p_effective_date          in     date
  ,p_business_group_id       in     number
  ,p_validate                in     boolean  default FALSE
  ,p_batch_flag              in     boolean  default FALSE
  ,p_person_action_id        in     Number   default NULL
  ,p_object_version_number   in     Number   default NULL
  ,p_audit_log               in     varchar2 default 'N'
  ,p_close_cd                in     varchar2 default 'FORCE'
  ,p_close_uneai_flag        in     varchar2 default NULL
  ,p_uneai_effective_date    in     date     default NULL
  );
--
procedure close_enrt_n_run_benmngle_ss
  (p_person_id               in     number
  ,p_mode                    in     varchar2 default 'L'
  ,p_per_in_ler_id           in     number
  ,p_effective_date          in     date
  ,p_run_date                in     date
  ,p_business_group_id       in     number
  ,p_validate                in     boolean  default FALSE
  ,p_batch_flag              in     boolean  default FALSE
  ,p_person_action_id        in     Number   default NULL
  ,p_object_version_number   in     Number   default NULL
  ,p_audit_log               in     varchar2 default 'N'
  ,p_close_cd                in     varchar2 default 'FORCE'
  ,p_close_uneai_flag        in     varchar2 default NULL
  ,p_uneai_effective_date    in     date     default NULL
  );
--
End ben_close_enrollment;

/
