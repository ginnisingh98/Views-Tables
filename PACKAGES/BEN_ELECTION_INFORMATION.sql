--------------------------------------------------------
--  DDL for Package BEN_ELECTION_INFORMATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ELECTION_INFORMATION" AUTHID CURRENT_USER as
/* $Header: benelinf.pkh 120.0.12010000.2 2009/08/03 15:14:10 krupani ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|                       Copyright (c) 1998 Oracle Corporation                  |
|                          Redwood Shores, California, USA                     |
|                               All rights reserved.                           |
+==============================================================================+
--
Name
	Determine Election Information
Purpose
	This process creates or updates the participant's record with
	information about plans and options elected.  This process
	determines the effective date of new elections.  The enrollment
	coverage end date for comp objects de-enrolled is in a later
	function.
History
	Date		Who		Version	What?
	----		---		-------	-----
	20 Apr 98	jcarpent	110.0		Created
     19 Oct 98    jcarpent    115.7       Removed election_rate_information
                                          From header only.
     27 Oct 98    jcarpent    115.8       Added election_rate_info back.
     18 Dec 98    jcarpent    115.9       Added p_enrt_mthd_cd to
                                          election_rate_info..
     19 May 99    lmcdonal    115.10      Overloaded election_information with
                                          parm to set different save points.
     20 Jul 99    jcarpent    115.11      Added bnft_amt_change.
     12 Aug 99    gperry      115.13      backport of 115.10
     12 Aug 99    gperry      115.14      backport of 115.12
     14 Sep 99    shdas       115.15      changed election_information to add\                                           bnft_val
     12-Nov-1999  jcarpent    115.16      Added bnft/chc globals.
     15-Aug-2000  maagrawa    115.17      Added procedure election_information_w
                                          (Wrapper for self-service).
     14-Dec-2000  maagrawa    115.18      Overloaded the self-service wrapper.
     03-Jan-2001  ikasire     115.19      added commit and uncommented exit
                                          rollback
     05-Jan-2001  maagrawa    115.20      Added parameters enrt_cvg_strt_dt,
                                          enrt_cvg_thru_dt to procedure
                                          election_information and _w.
     15-Jan-2001  maagrawa    115.21      Modified the self-service wrapper
                                          to handle multiple rates.
     16-Jan-01    mhoyes      115.91    - Added calculate only mode parameter
                                          to election_rate_information.
     09-Mar-01    maagrawa    115.92      Added rt_strt_dt and rt_end_dt
                                          parameters.
     24-Jul-2001  mmorishi    115.24      Added rt_strt_dt_cd and person_id
                                          parms to election_information_w.
     17-Aug-2001  maagrawa    115.25      Added parameter p_rt_update_mode
                                          to election_information_w.
     08-Feb-2002  gsheelum    115.26 2218845 added default null to
                                            param P_RT_UPDATE_MODE
     08-Feb-2002  gsheelum    115.27     GSCC compliance comments
     10-Oct-2002  shdas       115.28     Added parameters to election_information_w
     02-Dec-2002  kmullapu    115.29     Added out nocopy param to election_information_w
     24-Jan-2003  ikasire     115.30     nocopy changes
     01-Oct-2003  mmudigon    115.31     Bug 2775742. new param p_ele_changed
     23-Aug-04    mmudigon    115.32     CFW. Added p_act_item_flag
                                              2534391 :NEED TO LEAVE ACTION ITEMS
     09-sep-04    mmudigon    115.33     CFW. p_act_item_flag no longer needed
     30-Nov-04    ikasire     115.34     SSBEN Datatype changes from varchar2 to date
                                         Bug 3988565
     02-Dec-04    ikasire     115.35     BUG 4031416 Externalized backout_future_coverage
                                         procedure for calling from beninelg
     22-Dec-04    maagrawa    115.36     Added more parms to election_information_w
                                         to have both procedures in sync.
     23-Dec-04    tjesumic    115.37     new param p_prtt_enrt_rslt_id added backout_future_coverage
     07-Feb-05    tjesumic    115.38     backout_future_coverage removed # 4118315
     13-Apr-05    ikasire     115.39     Added a new parameter to manage_enrt_bnft procedure
     02-Aug-09    krupani     115.40     8716870: Imputed Income Enhancement. Added new parameter p_imp_cvg_strt_dt
                                         to election_information and election_rate_information procedure
*/
/*
-- ----------------------------------------------------------------------------
-- |---------------------< BACKOUT_FUTURE_COVERAGE >-------------------------|
-- --------------------------------------------------------------------------+
procedure  backout_future_coverage(p_per_in_ler_id in number,
                         p_business_group_id       in number,
                         p_person_id               in number,
                         p_pgm_id                  in number default null ,
                         p_pl_id                   in number default null ,
                         p_lf_evt_ocrd_dt          in date ,
                         p_effective_date          in date ,
                         p_prtt_enrt_rslt_id       in out nocopy number) ;
--
*/
-- ----------------------------------------------------------------------------
-- |-------------------< election_rate_information >-------------------------|
-- ---------------------------------------------------------------------------+
procedure election_rate_information
  (p_calculate_only_mode in     boolean default false
  ,p_enrt_mthd_cd        in     varchar2
  ,p_effective_date      in     date
  ,p_prtt_enrt_rslt_id   in     number
  ,p_per_in_ler_id       in     number
  ,p_person_id           in     number
  ,p_pgm_id              in     number
  ,p_pl_id               in     number
  ,p_oipl_id             in     number
  ,p_enrt_rt_id          in     number
  ,p_prtt_rt_val_id      in out nocopy number
  ,p_rt_val              in     number
  ,p_ann_rt_val          in     number
  ,p_enrt_cvg_strt_dt    in     date
  ,p_acty_ref_perd_cd    in     varchar2
  ,p_datetrack_mode      in     varchar2
  ,p_business_group_id   in     number
  ,p_bnft_amt_changed    in     boolean default false
  ,p_ele_changed         in     boolean default null
  ,p_rt_strt_dt          in     date    default null
  ,p_rt_end_dt           in     date    default null
  --
  ,p_prv_rt_val             out nocopy number
  ,p_prv_ann_rt_val         out nocopy number
  ,p_imp_cvg_strt_dt     in  date default NULL      -- Enh 8716870
  );
-- ----------------------------------------------------------------------------
-- |--------------------------< election_information >-------------------------|
-- --------------------------------------------------------------------------+
-- OVERLOADED, SEE BELOW.
procedure election_information
  (p_validate               in boolean default FALSE
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in out nocopy number
  ,p_effective_date         in date
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_cvg_strt_dt       in  date  default null
  ,p_enrt_cvg_thru_dt       in  date  default null
  ,p_enrt_rt_id1            in number default null
  ,p_prtt_rt_val_id1        in out nocopy number
  ,p_rt_val1                in number default null
  ,p_ann_rt_val1            in number default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in out nocopy number
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_rt_strt_dt2            in date   default null
  ,p_rt_end_dt2             in date   default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in out nocopy number
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_rt_strt_dt3            in date   default null
  ,p_rt_end_dt3             in date   default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in out nocopy number
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_rt_strt_dt4            in date   default null
  ,p_rt_end_dt4             in date   default null
  ,p_enrt_rt_id5            in number default null
  ,p_prtt_rt_val_id5        in out nocopy number
  ,p_rt_val5                in number default null
  ,p_ann_rt_val5            in number default null
  ,p_rt_strt_dt5            in date   default null
  ,p_rt_end_dt5             in date   default null
  ,p_enrt_rt_id6            in number default null
  ,p_prtt_rt_val_id6        in out nocopy number
  ,p_rt_val6                in number default null
  ,p_ann_rt_val6            in number default null
  ,p_rt_strt_dt6            in date   default null
  ,p_rt_end_dt6             in date   default null
  ,p_enrt_rt_id7            in number default null
  ,p_prtt_rt_val_id7        in out nocopy number
  ,p_rt_val7                in number default null
  ,p_ann_rt_val7            in number default null
  ,p_rt_strt_dt7            in date   default null
  ,p_rt_end_dt7             in date   default null
  ,p_enrt_rt_id8            in number default null
  ,p_prtt_rt_val_id8        in out nocopy number
  ,p_rt_val8                in number default null
  ,p_ann_rt_val8            in number default null
  ,p_rt_strt_dt8            in date   default null
  ,p_rt_end_dt8             in date   default null
  ,p_enrt_rt_id9            in number default null
  ,p_prtt_rt_val_id9        in out nocopy number
  ,p_rt_val9                in number default null
  ,p_ann_rt_val9            in number default null
  ,p_rt_strt_dt9            in date   default null
  ,p_rt_end_dt9             in date   default null
  ,p_enrt_rt_id10           in number default null
  ,p_prtt_rt_val_id10       in out nocopy number
  ,p_rt_val10               in number default null
  ,p_ann_rt_val10           in number default null
  ,p_rt_strt_dt10           in date   default null
  ,p_rt_end_dt10            in date   default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in out nocopy varchar2
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_object_version_number  in out nocopy number
  ,p_prtt_enrt_interim_id   out nocopy number
  ,p_business_group_id	    in  number
  ,p_pen_attribute_category in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30        in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_actn_warning      out nocopy boolean
  ,p_bnf_actn_warning       out nocopy boolean
  ,p_ctfn_actn_warning      out nocopy boolean);
-- ----------------------------------------------------------------------------
-- |--------------------------< election_information >-------------------------|
-- --------------------------------------------------------------------------+
-- OVERLOADED, SEE ABOVE.
procedure election_information
  (p_validate               in boolean default FALSE
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in out nocopy number
  ,p_effective_date         in date
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_cvg_strt_dt       in  date  default null
  ,p_enrt_cvg_thru_dt       in  date  default null
  ,p_enrt_rt_id1            in number default null
  ,p_prtt_rt_val_id1        in out nocopy number
  ,p_rt_val1                in number default null
  ,p_ann_rt_val1            in number default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in out nocopy number
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_rt_strt_dt2            in date   default null
  ,p_rt_end_dt2             in date   default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in out nocopy number
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_rt_strt_dt3            in date   default null
  ,p_rt_end_dt3             in date   default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in out nocopy number
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_rt_strt_dt4            in date   default null
  ,p_rt_end_dt4             in date   default null
  ,p_enrt_rt_id5            in number default null
  ,p_prtt_rt_val_id5        in out nocopy number
  ,p_rt_val5                in number default null
  ,p_ann_rt_val5            in number default null
  ,p_rt_strt_dt5            in date   default null
  ,p_rt_end_dt5             in date   default null
  ,p_enrt_rt_id6            in number default null
  ,p_prtt_rt_val_id6        in out nocopy number
  ,p_rt_val6                in number default null
  ,p_ann_rt_val6            in number default null
  ,p_rt_strt_dt6            in date   default null
  ,p_rt_end_dt6             in date   default null
  ,p_enrt_rt_id7            in number default null
  ,p_prtt_rt_val_id7        in out nocopy number
  ,p_rt_val7                in number default null
  ,p_ann_rt_val7            in number default null
  ,p_rt_strt_dt7            in date   default null
  ,p_rt_end_dt7             in date   default null
  ,p_enrt_rt_id8            in number default null
  ,p_prtt_rt_val_id8        in out nocopy number
  ,p_rt_val8                in number default null
  ,p_ann_rt_val8            in number default null
  ,p_rt_strt_dt8            in date   default null
  ,p_rt_end_dt8             in date   default null
  ,p_enrt_rt_id9            in number default null
  ,p_prtt_rt_val_id9        in out nocopy number
  ,p_rt_val9                in number default null
  ,p_ann_rt_val9            in number default null
  ,p_rt_strt_dt9            in date   default null
  ,p_rt_end_dt9             in date   default null
  ,p_enrt_rt_id10           in number default null
  ,p_prtt_rt_val_id10       in out nocopy number
  ,p_rt_val10               in number default null
  ,p_ann_rt_val10           in number default null
  ,p_rt_strt_dt10           in date   default null
  ,p_rt_end_dt10            in date   default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in out nocopy varchar2
  ,p_called_from_sspnd      in varchar2    -- flag not other spec
  ,p_effective_start_date   out nocopy date
  ,p_effective_end_date     out nocopy date
  ,p_object_version_number  in out nocopy number
  ,p_prtt_enrt_interim_id   out nocopy number
  ,p_business_group_id      in  number
  ,p_pen_attribute_category in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute1         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute2         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute3         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute4         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute5         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute6         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute7         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute8         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute9         in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute10        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute11        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute12        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute13        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute14        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute15        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute16        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute17        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute18        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute19        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute20        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute21        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute22        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute23        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute24        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute25        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute26        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute27        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute28        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute29        in  varchar2  default hr_api.g_varchar2
  ,p_pen_attribute30        in  varchar2  default hr_api.g_varchar2
  ,p_dpnt_actn_warning      out nocopy boolean
  ,p_bnf_actn_warning       out nocopy boolean
  ,p_ctfn_actn_warning      out nocopy boolean
  ,p_imp_cvg_strt_dt        in  date default NULL      -- 8716870
  );

-- ----------------------------------------------------------------------------
-- |-------------------------< election_information_w >------------------------|
-- --------------------------------------------------------------------------+
procedure election_information_w
  (p_validate               in varchar2 default 'N'
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in number
  ,p_effective_date         in date
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_rt_id             in number default null
  ,p_prtt_rt_val_id         in number
  ,p_rt_val                 in number default null
  ,p_ann_rt_val             in number default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in varchar2
  ,p_effective_start_date   in date
  ,p_object_version_number  in number
  ,p_business_group_id      in number
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in number
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in number
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in number
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_person_id              in number default null
  ,p_enrt_cvg_strt_dt       in date   default null
  ,p_enrt_cvg_thru_dt       in date   default null
  ,p_rt_update_mode         in varchar2 default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_rt_strt_dt_cd1         in varchar2 default null
  ,p_return_status          out nocopy varchar2
  );

--
--  Overloaded.
--
procedure election_information_w
  (p_validate               in varchar2 default 'N'
  ,p_elig_per_elctbl_chc_id in number
  ,p_prtt_enrt_rslt_id      in number
  ,p_effective_date         in date
  ,p_person_id              in number default null
  ,p_enrt_mthd_cd           in varchar2
  ,p_enrt_bnft_id           in number
  ,p_bnft_val               in number default null
  ,p_enrt_rt_id1            in number default null
  ,p_prtt_rt_val_id1        in number default null
  ,p_rt_val1                in number default null
  ,p_ann_rt_val1            in number default null
  ,p_rt_strt_dt1            in date   default null
  ,p_rt_end_dt1             in date   default null
  ,p_rt_strt_dt_cd1         in varchar2 default null
  ,p_enrt_rt_id2            in number default null
  ,p_prtt_rt_val_id2        in number default null
  ,p_rt_val2                in number default null
  ,p_ann_rt_val2            in number default null
  ,p_rt_strt_dt2            in date   default null
  ,p_rt_end_dt2             in date   default null
  ,p_enrt_rt_id3            in number default null
  ,p_prtt_rt_val_id3        in number default null
  ,p_rt_val3                in number default null
  ,p_ann_rt_val3            in number default null
  ,p_rt_strt_dt3            in date   default null
  ,p_rt_end_dt3             in date   default null
  ,p_enrt_rt_id4            in number default null
  ,p_prtt_rt_val_id4        in number default null
  ,p_rt_val4                in number default null
  ,p_ann_rt_val4            in number default null
  ,p_rt_strt_dt4            in date   default null
  ,p_rt_end_dt4             in date   default null
  ,p_datetrack_mode         in varchar2
  ,p_suspend_flag           in varchar2
  ,p_effective_start_date   in date
  ,p_object_version_number  in number
  ,p_business_group_id      in number
  ,p_enrt_cvg_strt_dt       in date
  ,p_enrt_cvg_thru_dt       in date
  ,p_rt_update_mode         in varchar2 default null
  ,p_api_error              out nocopy boolean);

-- ----------------------------------------------------------------------------
-- |-----------------------------< MANAGE_ENRT_BNFT >-------------------------|
-- --------------------------------------------------------------------------+
procedure MANAGE_ENRT_BNFT
  (p_prtt_enrt_rslt_id     IN     number
  ,p_enrt_bnft_id          in     number default null
  ,p_object_version_number in out nocopy number
  ,p_business_group_id     in     number
  ,p_effective_date        in     date
  ,p_per_in_ler_id         in     number
  ,p_created_by            in     varchar2 default null
  ,p_creation_date         in     date     default null
);
--
-- Globals for use by bensuenr, suspend_enrollment
--
g_enrt_bnft_id           number;
g_bnft_val               number;
g_elig_per_elctbl_chc_id number;
--
end ben_election_information;

/
