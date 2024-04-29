--------------------------------------------------------
--  DDL for Package BEN_ENROLLMENT_ACTION_ITEMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ENROLLMENT_ACTION_ITEMS" AUTHID CURRENT_USER as
/* $Header: benactcm.pkh 120.2.12010000.1 2008/07/29 12:02:44 appldev ship $ */
--
  --
  -- Globals used
  --
  g_package                       varchar2(80) := 'ben_enrollment_action_items';

  --
  -- Constants used
  --
  YES_FOUND                       constant varchar2(30) := 'Y';
  NOT_FOUND                       constant varchar2(30) := 'N';
  YES_DONE                        constant varchar2(3)  := 'Y';
  NOT_DONE                        constant varchar2(3)  := 'N';
  USE_DPNT                        constant varchar2(5)  := 'DPNT';
  USE_BNF                         constant varchar2(5)  := 'BNF';
  --
  -- date track mode constants
  --
  DTMODE_INSERT                   constant varchar2(30) := hr_api.g_insert;
  DTMODE_UPDATE                   constant varchar2(30) := hr_api.g_update;
  DTMODE_CORRECT                  constant varchar2(30) := hr_api.g_correction;
  DTMODE_DELETE                   constant varchar2(30) := hr_api.g_delete;
  DTMODE_ZAP                      constant varchar2(30) := hr_api.g_zap;
  DTMODE_SYSDATE                  constant varchar2(30) := hr_api.g_sys;
  DTMODE_STARTOFTIME              constant varchar2(30) := hr_api.g_sot;
  DTMODE_ENDOFTIME                constant varchar2(30) := hr_api.g_eot;

  -- cursor to get pl data and to see if bnfs are required.
  -- If bnf's are not rqd,  action item isn't rqd either.
  cursor g_bnf_pl (p_prtt_enrt_rslt_id number
                   ,p_effective_date date) is
  select decode(pl.bnf_dsgn_cd, 'R', 'Y', null, null, 'N') rqd,
         pl.pl_id,
         pl.susp_if_bnf_ssn_nt_prv_cd,
         pl.susp_if_bnf_dob_nt_prv_cd,
         pl.susp_if_bnf_adr_nt_prv_cd,
         pl.susp_if_ctfn_not_bnf_flag,
         pl.bnf_ctfn_determine_cd,
         pl.bnf_ctfn_rqd_flag,
         pl.bnf_dsge_mnr_ttee_rqd_flag
    from ben_pl_f pl,
         ben_prtt_enrt_rslt_f pen
   where pen.prtt_enrt_rslt_id = p_prtt_enrt_rslt_id
     and pen.pl_id = pl.pl_id
     and p_effective_date between
         pen.effective_start_date and pen.effective_end_date
     and p_effective_date between
         pl.effective_start_date and pl.effective_end_date;

  g_bnf_pl_rec g_bnf_pl%rowtype;

--
-- ----------------------------------------------------------------------------
-- |-----------------------< determine_action_items >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_action_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean default false
  ,p_enrt_bnft_id               in     number default null
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag                  out nocopy varchar2
  ,p_dpnt_actn_warning             out nocopy boolean
  ,p_bnf_actn_warning              out nocopy boolean
  ,p_ctfn_actn_warning             out nocopy boolean
  --,p_pcp_actn_warning              out boolean
  --,p_pcp_dpnt_actn_warning         out boolean
  );
  --
  -- this procedure is the main driver/entry point for action items
  -- determines if desginated dependents and benficiaries meet all the criteria
  -- for PL, PGM, and PTIP where necessary.
-- Added by Anil
-- ----------------------------------------------------------------------------
-- |--------------------< process_cwb_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_cwb_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2);
--
-- ----------------------------------------------------------------------------
-- |----------------------< process_dpnt_actn_items >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_dpnt_actn_items
  (p_validate                   in     boolean  default false
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_dpnt_actn_warning             out nocopy boolean
  --Bug No 4525608 to capture the certification required warning
  ,p_ctfn_actn_warning             out nocopy boolean);
  --End Bug 4525608
--
-- ----------------------------------------------------------------------------
-- |--------------------< process_pcp_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_pcp_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_pcp_actn_warning             out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |--------------------< process_pcp_dpnt_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_pcp_dpnt_actn_items
  (p_validate                   in     boolean  default FALSE
  ,p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_pcp_dpnt_actn_warning             out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< process_bnf_actn_items >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure process_bnf_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean  default false
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_bnf_actn_warning              out nocopy boolean);
--
-- ----------------------------------------------------------------------------
-- |---------------------< complete_this_action_item >-----------------------|
-- ----------------------------------------------------------------------------
--
procedure complete_this_action_item
  (p_prtt_enrt_actn_id  in number
  ,p_effective_date     in date
  ,p_validate           in boolean  default false
  ,p_datetrack_mode     in varchar2 default hr_api.g_correction
  ,p_post_rslt_flag     in varchar2 default 'Y');
  --
  -- this procedure will set the completed date for a single open action item
  -- for a participant result both dependent and beneficiary
--
-- ----------------------------------------------------------------------------
-- |--------------------< determine_other_actn_items >------------------------|
-- ----------------------------------------------------------------------------
--
procedure determine_other_actn_items
  (p_prtt_enrt_rslt_id          in     number
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_validate                   in     boolean  default false
  ,p_enrt_bnft_id               in     number   default NULL
  ,p_datetrack_mode             in     varchar2 default hr_api.g_correction
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_rslt_object_version_number in out nocopy number
  ,p_suspend_flag               in out nocopy varchar2
  ,p_ctfn_actn_warning             out nocopy boolean
  );
   --
   -- this procedure determines all other enrollment action items that need to
   -- be written. We are checking the participant enrollment results looking for
   -- certifications, ENRTCTFN, and required specific rates.
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_dpnt_ctfn >---------------------------|
-- ----------------------------------------------------------------------------
--
function check_dpnt_ctfn
  (p_prtt_enrt_actn_id in number
  ,p_elig_cvrd_dpnt_id in number
  ,p_effective_date    in date)
return boolean;
   --
   -- this function checks for certifications for an enrollment result.
   -- check if certifications were provided.  For this dependent check
   -- if the dpnt_dsgn_ctfn_rqd_flag is 'Y' then write action item
   -- if the dpnt_dsgn_ctfn_recd_dt IS NULL.  The recd_dt is filled in via
   -- a form interface.
   -- we are also checking for at least one optional certification.
   -- optional means dpnt_dsgn_ctfn_rqd_flag is 'N' for the ctfn_prvdd entry
   -- with the dpnt_dsgn_ctfn_recd_dt not NULL.  Returns 'Y' or 'N'
--
-- ----------------------------------------------------------------------------
-- |--------------------------< check_bnf_ctfn >------------------------------|
-- ----------------------------------------------------------------------------
--
function check_bnf_ctfn
  (p_prtt_enrt_actn_id in number
  ,p_pl_bnf_id         in number
  ,p_effective_date    in date)
return boolean;
   --
   -- this function checks for certifications for an enrollment result.
   -- check if certifications were provided.  For this beneficiary check
   -- if the bnf_ctfn_rqd_flag is 'Y' then write action item
   -- if the bnf_ctfn_recd_dt IS NULL.  The bnf_ctfn_recd_dt is filled in via
   -- a form interface.  Returns TRUE or FALSE.
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_dob >--------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function checks if the person has a date of birth.
--
function check_dob
  (p_person_id  in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_adrs >-------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function checks if the person has an address.
--
function check_adrs
  (p_prtt_enrt_rslt_id  in number
  ,p_dpnt_bnf_person_id in number
  ,p_effective_date     in date
  ,p_business_group_id  in number)
return boolean;
--
-- ----------------------------------------------------------------------------
-- |-----------------------------< check_legid >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function checks if the person has an SSN or National Identifier.
--
function check_legid
  (p_person_id         in number
  ,p_effective_date    in date
  ,p_business_group_id in number)
return boolean;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_actn_typ_id >------------------------------|
-- ----------------------------------------------------------------------------
--
-- This function returns the action type id for a certain actn type code.
--
function get_actn_typ_id
  (p_type_cd           in varchar2
  ,p_business_group_id in number)
return number;
--
-- ----------------------------------------------------------------------------
-- |-------------------------< get_prtt_enrt_actn_id >------------------------|
-- ----------------------------------------------------------------------------
--
procedure get_prtt_enrt_actn_id
  (p_actn_typ_id           in     number
  ,p_prtt_enrt_rslt_id     in     number
  ,p_elig_cvrd_dpnt_id     in     number default null
  ,p_pl_bnf_id             in     number default null
  ,p_effective_date        in     date
  ,p_business_group_id     in     number
  ,p_prtt_enrt_actn_id        out nocopy number
  ,p_cmpltd_dt                out nocopy date
  ,p_object_version_number in out nocopy number);
--
-- ----------------------------------------------------------------------------
-- |-----------------------< write_new_action_item >--------------------------|
-- ----------------------------------------------------------------------------
--
procedure write_new_action_item
  (p_prtt_enrt_rslt_id          in     number
  ,p_rslt_object_version_number in out nocopy number
  ,p_actn_typ_id                in     number
  ,p_elig_cvrd_dpnt_id          in     number   default null
  ,p_pl_bnf_id                  in     number   default null
  ,p_rqd_flag                   in     varchar2 default 'Y'
  ,p_cmpltd_dt                  in     date     default null
  ,p_effective_date             in     date
  ,p_business_group_id          in     number
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_object_version_number         out nocopy number
  ,p_prtt_enrt_actn_id             out nocopy number);
--
procedure process_action_item
  (p_prtt_enrt_actn_id          in out nocopy number
  ,p_actn_typ_id                in     number
  ,p_cmpltd_dt                  in     date
  ,p_object_version_number      in out nocopy number
  ,p_effective_date             in     date
  ,p_rqd_data_found             in     boolean
  ,p_prtt_enrt_rslt_id          in     number
  ,p_elig_cvrd_dpnt_id          in     number   default null
  ,p_pl_bnf_id                  in     number   default null
  ,p_rqd_flag                   in     varchar2 default 'Y'
  ,p_post_rslt_flag             in     varchar2 default 'Y'
  ,p_business_group_id          in     number
  ,p_datetrack_mode             in     varchar2
  ,p_rslt_object_version_number in out nocopy number);
--
procedure process_new_ctfn_action(
           p_prtt_enrt_rslt_id    in number,
           p_elig_cvrd_dpnt_id    in number default null,
           p_pl_bnf_id            in number default null,
           p_actn_typ_cd          in varchar2,
           p_ctfn_rqd_flag        in varchar2,
           p_ctfn_recd_dt         in date  default null,
           p_business_group_id    in number,
           p_effective_date       in date,
           p_prtt_enrt_actn_id    out nocopy number);
--
--
-- ----------------------------------------------------------------------------
-- |----------------------------< check_enrt_ctfn >---------------------------|
-- ----------------------------------------------------------------------------
--
function check_enrt_ctfn
  (p_prtt_enrt_actn_id in number
  ,p_prtt_enrt_rslt_id in number
  ,p_effective_date    in date)
return boolean;
--
--
end ben_enrollment_action_items;
--

/
