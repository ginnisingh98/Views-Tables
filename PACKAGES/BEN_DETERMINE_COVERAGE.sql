--------------------------------------------------------
--  DDL for Package BEN_DETERMINE_COVERAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DETERMINE_COVERAGE" AUTHID CURRENT_USER as
/* $Header: bencvrge.pkh 120.0.12010000.1 2008/07/29 12:05:42 appldev ship $ */
--------------------------------------------------------------------------------
/*
+==============================================================================+
|           Copyright (c) 1997 Oracle Corporation              |
|              Redwood Shores, California, USA                 |
|                   All rights reserved.                       |
+==============================================================================+
Name:
   Determine Coverage

Purpose:
   Determines proper coverages based on mlt_cd.  Writes to BEN_ENRT_BNFT table.

History:
        Date             Who        Version    What?
        ----             ---        -------    -----
        7  May 97        Ty Hayden  110.0      Created.
        22 Oct 98        T Guy      115.2      No change.
        18 Jan 99        G Perry    115.3      LED V ED
        09 Mar 99        G Perry    115.4      IS to AS.
        07-Jan-01        mhoyes     115.26   - Made round_val and
                                               combine_with_variable_val public.
        23-Jan-01        mhoyes     115.6    - Added calculate only mode for EFC.
        23-Dec-02        lakrish    115.7      NOCOPY changes
*/
--------------------------------------------------------------------------------
--
Type ENBValType      is record
  (enrt_bnft_id     number
  ,val              number
  ,mn_val           number
  ,mx_val           number
  ,mx_wout_ctfn_val number
  ,incrmt_val       number
  ,dflt_val         number
  );
--
FUNCTION round_val
     (p_val                   in number,
     p_effective_date         in date,
     p_lf_evt_ocrd_dt         in date,
     p_rndg_cd                in varchar2,
     p_rndg_rl                in number) return number;
--
PROCEDURE combine_with_variable_val
            (p_vr_val           in number,
             p_val              in number,
             p_vr_trtmt_cd      in varchar2,
             p_combined_val     out nocopy number);
--
PROCEDURE main
  (p_calculate_only_mode    in     boolean default false
  ,p_elig_per_elctbl_chc_id IN     number
  ,p_effective_date         IN     date
  ,p_lf_evt_ocrd_dt         IN     date
  ,p_perform_rounding_flg   IN     boolean default true
  --
  ,p_enb_valrow                out nocopy ben_determine_coverage.ENBValType
  );
--
end ben_determine_coverage;

/
