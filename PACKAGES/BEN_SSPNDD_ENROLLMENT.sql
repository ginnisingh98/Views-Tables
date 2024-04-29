--------------------------------------------------------
--  DDL for Package BEN_SSPNDD_ENROLLMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_SSPNDD_ENROLLMENT" AUTHID CURRENT_USER as
/* $Header: bensuenr.pkh 120.7.12010000.1 2008/07/29 12:31:22 appldev ship $ */
-------------------------------------------------------------------------------
/*
+=============================================================================+
|                    Copyright (c) 1997 Oracle Corporation                    +
|                       Redwood Shores, California, USA                       +
|                            All rights reserved.                             +
+=============================================================================+
Name
	Suspend Enrollment
Purpose
   This package is used to update the enrollment result to indicate
   it to be suspended and assign a interiem coverage if it's required
   and available.
History
  Date        Who        Version  What?
  ----------- ---------- -------  ---------------------------------------------
  12 May 1998 maagrawa   110.0    Created.
  22 Jul 1998 maagrawa   110.1    p_rslt_object_version_number argument added.
  22 Sep 1998 bbulusu    110.2    removed p_enrt_mthd_cd from
                                  p_suspend_enrollment
  30 Oct 1998 Hdang 	 115.5    Add unsuspend procedure declaration.
  05 Nov 1998 Hdang      115.6    Add per_in_ler_id in unsuspend_enrollment.
  07 Aug 2002 ikasire    115.8    Bug 2502633 Interim Ehnacements
                                  added a global variable g_use_new_result
  24 dec 2002 hmani      115.9    for nocopy changes
  23 Aug 2004 mmudigon   115.10   CFW. Added p_act_item_flag to proc
                                  suspend_enrollment
                                  2534391 :NEED TO LEAVE ACTION ITEMS
  05 Sep 2004 ikasire    115.11   FIDOML Override Enhancements
  09 sep 2004 mmudigon   115.12   CFW. p_act_item_flag no longer needed
  29 Jun 2005 ikasire    115.13   Bug 4422667 getting into loop issue
  26 Aug 2005 ikasire    115.14   Bug 4558512 Reinstatement unsuspend code
                                  return incorrect coverage dates
  15 Sep 2005 ikasire    115.15   Bug 4450214 Added cfw condition bases on
                                  g_cfw_flag and modified the cfw cursor to
                                  to function as per the changed process in
                                  election_information.
  22 Sep 2005 ikasire    115.16   Bug 4622534 for carrforward dependents from default
                                  rule
  21 Jul 2006 rtagarra	 115.17   Bug 5402072 :Leapfrog of 115.16 and same as 115.16.
  28 sep 2006 ssarkar    115.18   Bug 5529258 : get_dflt_to_asn_pndg_ctfn_cd is made public
  24-Aug-2007 gsehgal    115.19   bug 6337803 added new global vaiable g_sspnded_rslt_id
===============================================================================
*/
--
-- Global variable declaration
--
g_debug               Boolean := TRUE;
g_use_new_result      Boolean := false ;
g_interim_flag        varchar2(30) := 'N';
g_cfw_flag            varchar2(30) := 'N';
g_cfw_dpnt_flag       varchar2(30) := 'N';
-- 6337803
g_sspnded_rslt_id     ben_prtt_enrt_rslt_f.prtt_enrt_rslt_id%TYPE;
--
-- Gloabal procedure declaration.
--
--
-- ===========================================================================
-- Procedure: Suspend_enrollment
--     Process will handle suspend the enrollment and its apply the interim
--     enrollment if interim available.
--
-- ===========================================================================
--
procedure suspend_enrollment
                      (p_prtt_enrt_rslt_id       in number
                      ,p_effective_date          in date
                      ,p_post_rslt_flag          in varchar2  default 'N'
                      ,p_business_group_id       in number
                      ,p_object_version_number   in out nocopy number
                      ,p_datetrack_mode          in varchar2
                      );
--
-- ===========================================================================
-- Procedure: unsuspend_enrollment
--     Process will handle unsuspend the enrollment and its interim enrollment
--     if there is one.
-- ===========================================================================
--
procedure unsuspend_enrollment
                      (p_prtt_enrt_rslt_id       in number
                      ,p_effective_date          in date
                      ,p_per_in_ler_id           in number default NULL
                      ,p_post_rslt_flag          in varchar2  default 'N'
                      ,p_business_group_id       in number
                      ,p_object_version_number   in out nocopy number
                      ,p_datetrack_mode          in varchar2
                      ,p_called_from             in varchar2 default 'BENSUENR'
                      ,p_cmpltd_dt               in date default null
                      );

-- ===========================================================================
Function get_dflt_to_asn_pndg_ctfn_cd
             (p_dflt_to_asn_pndg_ctfn_rl in number
             ,p_person_id                in number
             ,p_per_in_ler_id            in number
             ,p_assignment_id            in number
             ,p_organization_id          in number
             ,p_business_group_id        in number
             ,p_pgm_id                   in number
             ,p_pl_id                    in number
             ,p_pl_typ_id                in number
             ,p_opt_id                   in number
             ,p_ler_id                   in number
             ,p_elig_per_elctbl_chc_id   in number
             ,p_jurisdiction_code        in varchar2
             ,p_effective_date           in date
             ,p_prtt_enrt_rslt_id        in number
             ,p_interim_epe_id           out nocopy number
             ,p_interim_bnft_amt         out nocopy number
             ) return varchar2 ;

-------------------------------------------------------------------------------
end ben_sspndd_enrollment;

/
