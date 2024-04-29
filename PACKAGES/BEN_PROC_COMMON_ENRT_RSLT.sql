--------------------------------------------------------
--  DDL for Package BEN_PROC_COMMON_ENRT_RSLT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PROC_COMMON_ENRT_RSLT" AUTHID CURRENT_USER as
/* $Header: benprcme.pkh 120.2.12010000.1 2008/07/29 12:28:30 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
    Common Enrollment Results Process
Purpose

--------------------------------------------------------------------------------
History

Version Date        Author         Comments
-------+-----------+--------------+----------------------------------------
110.0   02-JUN-1998 stee           Created
110.1   18-JUN-1998 maagrawa       Two new parameters added
                                   p_pgm_id and p_pl_id
115.2   31-Oct-1998 stee           Added person_id and proc_cd
                                   to process_post_enrollment.
115.3   10-Dec-1998 bbulusu        added per_in_ler_id to process_post_result
115.4   10-Feb-1999 yrathman       Added set_elcn_made_or_asnd_dt procedure
115.5   29-Jun-1999 stee           Removed update_cobra_info procedure.
115.6   31-Jul-2000 pzclark        Added a wrapper to procedure
                                   process_post_enrollment to allow self
                                   service java code to call using varchar2
                                   'TRUE' or 'FALSE' instead of booleans.
115.7   15-Aug-2000 maagrawa       Added procedure process_post_enrt_calls_w
                                   (wrapper for self-service).
115.8   17-May-2001 maagrawa       Added parameter self_service_flag to
                                   process_post_results for performance.
115.10  28-Dec-2001 ikasire        added dbdrv lines
115.11  02-jan-2002 tjesumic       2170324 paramter for proc_cd2 to proc_cd5 added
115.12  11-Oct-2004 kmahendr       bug#3944970 - added two parameters to post_results
115.13  03-Dec-2004 ikasire        Bug 3988565 Changed effective_date data type to Date
115.14  16-Nov-06   vvprabhu       Bug 5664300 - parameter p_called_from_ss added
115.15                             to process_post_results
*/
--------------------------------------------------------------------------------
--
procedure set_elcn_made_or_asnd_dt
    (p_per_in_ler_id     in number   default null
    ,p_pgm_id            in number
    ,p_pl_id             in number
    ,p_enrt_mthd_cd      in varchar2
    ,p_business_group_id in number
    ,p_effective_date    in date
    ,p_validate          in boolean  default false
   );
--
  procedure process_post_results
    (p_flx_cr_flag       in varchar2 default 'N'
    ,p_person_id         in number
    ,p_enrt_mthd_cd      in varchar2
    ,p_effective_date    in date
    ,p_business_group_id in number
    ,p_validate          in boolean  default false
    ,p_per_in_ler_id     in number   default null
    ,p_self_service_flag in boolean  default false
    ,p_pgm_id            in number   default null
    ,p_pl_id             in number   default null
    ,p_called_frm_ss     in boolean  default false
    );
--
  procedure process_post_enrollment
  (p_per_in_ler_id     in  number   default null
  ,p_pgm_id            in  number
  ,p_pl_id             in  number
  ,p_enrt_mthd_cd      in  varchar2
  ,p_cls_enrt_flag     in  boolean  default  true
  ,p_proc_cd           in  varchar2 default  null
  ,p_proc_cd2          in  varchar2 default  null
  ,p_proc_cd3          in  varchar2 default  null
  ,p_proc_cd4          in  varchar2 default  null
  ,p_proc_cd5          in  varchar2 default  null
  ,p_person_id         in  number
  ,p_business_group_id in  number
  ,p_effective_date    in  date
  ,p_validate          in  boolean  default false
  );
--
  procedure process_post_enrollment_w
  (p_per_in_ler_id     in  number
  ,p_pgm_id            in  number
  ,p_pl_id             in  number
  ,p_enrt_mthd_cd      in  varchar2
  ,p_cls_enrt_flag     in  varchar2
  ,p_proc_cd           in  varchar2
  ,p_person_id         in  number
  ,p_business_group_id in  number
  ,p_effective_date    in  date
  ,p_validate          in  varchar2
  );
--
  procedure process_post_enrt_calls_w
  (p_validate               in varchar2 default 'N'
  ,p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number default null
  ,p_flx_cr_flag            in varchar2 default 'N'
  ,p_enrt_mthd_cd           in varchar2
  ,p_proc_cd                in varchar2 default null
  ,p_cls_enrt_flag          in varchar2 default 'N'
  ,p_business_group_id      in number
  ,p_effective_date         in date );
--
--OVERLOADED PROCEDURE with p_self_service_flag for Coversion purpose
--Always pass p_self_service_flag = 'N' when this api is called
--for other ssben purpose
--
  procedure process_post_enrt_calls_w
  (p_validate               in varchar2 default 'N'
  ,p_person_id              in number
  ,p_per_in_ler_id          in number
  ,p_pgm_id                 in number default null
  ,p_pl_id                  in number default null
  ,p_flx_cr_flag            in varchar2 default 'N'
  ,p_enrt_mthd_cd           in varchar2
  ,p_proc_cd                in varchar2 default null
  ,p_cls_enrt_flag          in varchar2 default 'N'
  ,p_business_group_id      in number
  ,p_effective_date         in date
  ,p_self_service_flag      in varchar2  );
--
 end;

/
