--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_CHC_CTFN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_CHC_CTFN" AUTHID CURRENT_USER as
/* $Header: benchctf.pkh 120.1 2005/09/13 10:39:48 ikasire noship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|			Copyright (c) 1997 Oracle Corporation                  |
|			   Redwood Shores, California, USA                     |
|			        All rights reserved.	                       |
+==============================================================================+
Name:
    Determine choice certifications.
Purpose:
    This process determines what certifications are necessary for an election and
    then writes them to elctbl_chc_ctfn.
History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        10 Feb 99        T Guy       115.0     Created.
        26 Feb 99        T Guy       115.1     Removed control m's
        13 Apr 99        T Guy       115.2     Added object_version_number
                                               to get_ecf_ctfns and write_ctfns
	28 Apr 99	 Shdas	     115.3     Added organization_id to parameter
	04 May 99	 Shdas	     115.4     Added jurisdiction code
        14 May 99        T Guy       115.5     is to as
        02 Nov 99        maagrawa    115.6     Added new procedure write_ctfn.
                                               Removed local procedures.
        05 Jun 00        stee        115.7     add p_elig_per_elctbl_chc_id
                                               to main.
        20 Aug 04        kmahendr    115.9     Enh 3747490 : Optional certificaction
                                               added parms to write_ctfn
        15 Nov 04        kmahendr    115.10    Added parameter p_mode
        12 Sep 05        ikasire     115.11    Added new procedure update_susp_if_ctfn_flag
*/
-----------------------------------------------------------------------------------
procedure main(p_effective_date         IN date,
               p_person_id              IN number,
               p_elig_per_elctbl_chc_id IN number,
               p_mode                   in varchar2 default null
              );
--
procedure write_ctfn(p_elig_per_elctbl_chc_id in number,
                     p_enrt_bnft_id           in number default null,
                     p_enrt_ctfn_typ_cd       in varchar2,
                     p_rqd_flag               in varchar2,
                     p_ctfn_rqd_when_rl       in number,
                     p_business_group_id      in number,
                     p_effective_date         in date,
                     p_assignment_id          in number,
                     p_organization_id        in number,
                     p_jurisdiction_code      in varchar2,
                     p_pgm_id                 in number,
                     p_pl_id                  in number,
                     p_pl_typ_id              in number,
                     p_opt_id                 in number,
                     p_ler_id                 in number,
                     p_susp_if_ctfn_not_prvd_flag in varchar2 default 'Y',
                     p_ctfn_determine_cd      in varchar2  default null,
                     p_mode                   in varchar2 default null
                     );
--
procedure update_susp_if_ctfn_flag(
                     p_effective_date         in date,
                     p_lf_evt_ocrd_dt         in date,
                     p_person_id              in number,
                     p_per_in_ler_id          in number
                     );

--
end BEN_DETERMINE_CHC_CTFN;


 

/
