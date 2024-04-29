--------------------------------------------------------
--  DDL for Package BEN_LF_EVT_CLPS_RESTORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_LF_EVT_CLPS_RESTORE" AUTHID CURRENT_USER as
/* $Header: benleclr.pkh 120.0.12010000.5 2010/05/03 09:59:58 pvelvano ship $ */
--
-- This flag is set when the results are restored, and used by
-- BENAUTHE to display message about reinstating of results.
--
g_bckdt_pil_restored_flag   varchar2(1)  :=  'N';
/*
g_bckdt_pil_restored_cd codes are

  ALL - If all the backed out results are being restored
  PART - Part of the enrollments are restored
  NONE - None of the enrollments are restored
  DEFAULT - Defaults are applied

*/
g_bckdt_pil_restored_cd     varchar2(30) := 'NONE';
g_bckdt_pil_pgm_id          number ;
g_bckdt_pil_plnip_id        number ;
g_bckdt_pil_prvs_stat_cd    varchar2(30)  :=  null;
g_bckdt_ler_name            ben_ler_f.name%type;
g_ler_name_cs_bckdt         ben_ler_f.name%type;
g_pil_id_cs_bckdt           number;

/*Bug 9538592: If the interim and suspended enrollment corresponds to same plan,option and plantype. In a case where epe table has
only one record for the plan, on resinstating the enrollments of the backedout life event, pen_id in epe table is set with the suspended enrollment result.
On reprocessing the backedout life event, new enrollment result record should be created with out making the reinstated result as both interim
and suspended when the certification has been denied before backing out the life event and reprocessing it*/
g_create_new_result varchar2(1) default 'N';

/*Added for Bug 7426609 */
g_reinstate_interim_flag boolean:= false;
g_reinstate_interim_chc_id number;
/*Ended for Bug 7426609 */

--g_default_epe_rec ben_elig_per_elctbl_chc%rowtype;
type g_default_epe_table is table of ben_elig_per_elctbl_chc.elig_per_elctbl_chc_id%type index by binary_integer;
g_reinstated_defaults g_default_epe_table;
--
procedure get_ori_bckdt_pil(p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_bckdt_per_in_ler_id out nocopy number
                          );
--
function  ele_made_for_bckdt_pil (
                           p_bckdt_per_in_ler_id      in number
                           ,p_person_id                in number
                           ,p_business_group_id        in number
                           ,p_effective_date           in date
                          )return varchar2;
--
--
function comp_ori_new_pil_outcome(
                           p_person_id       in number
                           ,p_business_group_id   in number
                           ,p_ler_id              in number
                           ,p_effective_date      in date
                           ,p_per_in_ler_id       in number
                           ,p_bckdt_per_in_ler_id in number
                          ) return varchar2;
--
procedure void_literature(p_person_id            in number
                          ,p_business_group_id   in number
                          ,p_effective_date      in date
                          ,p_ler_id              in number
                          ,p_per_in_ler_id       in number
                         );
--
procedure pad_cmnt_to_rsnd_lit(
                          p_person_id            in number
                          ,p_business_group_id   in number
                          ,p_effective_date      in date
                          ,p_ler_id              in number
                          ,p_per_in_ler_id       in number
                          ,p_cmnt_txt            in varchar2
                         );
--
procedure extend_enrt_date(p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                           );
--
procedure p_lf_evt_clps_restore
                          (p_validate               in boolean default false
                          ,p_person_id              in number
                          ,p_business_group_id      in number
                          ,p_effective_date         in date
                          ,p_per_in_ler_id          in number
                          ,p_bckdt_per_in_ler_id    in number
                          );
--
procedure update_ptnl_per_for_ler(p_ptnl_ler_for_per_id       in number
                          ,p_business_group_id        in number
                          ,p_ptnl_ler_for_per_stat_cd in varchar2
                          ,p_effective_date           in date);
--
-- This procedure called from BENAUTHE to package globals back to form
--
procedure p_reinstate_info_to_form (
                           p_pil_restored_flag out nocopy varchar2,
                           p_pil_restored_cd   out nocopy varchar2,
                           p_bckdt_ler_name    out nocopy varchar2);
--
procedure  reinstate_the_prev_enrt_rslt(
                             p_person_id            in number
                            ,p_business_group_id   in number
                            ,p_ler_id              in number
                            ,p_effective_date      in date
                            ,p_per_in_ler_id       in number
                            ,p_bckdt_per_in_ler_id in number
                           ) ;

/* Function added for Bug 8716679*/
function check_pl_typ_defaulted(p_pl_typ_id in number,
                               p_pgm_id in number
			       ) return varchar2 ;

/* Function added for Bug 8716679*/
function call_defaults(p_per_in_ler_id in number,
                       p_bckdt_per_in_ler_id in number,
		       p_effective_date date,
		       p_person_id number
			       ) return varchar2;
 /* Bug 8900007:Record to hold the enrollments created from carryforward logic*/
 type g_bckdt_pen_sspnd_rec is record
       (EFFECTIVE_END_DATE date,
          BUSINESS_GROUP_ID number,
          EFFECTIVE_START_DATE date,
          ENRT_CVG_STRT_DT date,
          ENRT_CVG_THRU_DT date,
          ENRT_MTHD_CD VARCHAR2(100),
          OBJECT_VERSION_NUMBER number,
          OIPL_ID number,
          PERSON_ID number,
          PER_IN_LER_ID number,
          PGM_ID number,
          PL_ID number,
          PL_TYP_ID number,
          PRTT_ENRT_RSLT_ID number,
          PRTT_ENRT_RSLT_STAT_CD VARCHAR2(100),
          PTIP_ID number,
          RPLCS_SSPNDD_RSLT_ID number,
          SSPNDD_FLAG VARCHAR2(100));

  TYPE g_bckdt_sspndd_pen_tbl is TABLE OF g_bckdt_pen_sspnd_rec INDEX BY BINARY_INTEGER;
  g_bckdt_sspndd_pen_list g_bckdt_sspndd_pen_tbl;
/* End Bug 8900007*/

/* Bug 8900007: Procedure reinstate_pcs_per_pen and reinstate_pea_per_pen
are made public. To be called from bencfwsu.pkb */
procedure reinstate_pcs_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_rslt_object_version_number in number
                            ,p_business_group_id        in number
                            ,p_prtt_enrt_actn_id        in number
                            ,p_effective_date           in date
                            ,p_bckdt_prtt_enrt_actn_id  in number
                            ,p_per_in_ler_id            in number
                            ,p_bckdt_per_in_ler_id      in number
                           );

procedure reinstate_pea_per_pen(
                             p_person_id                in number
                            ,p_bckdt_prtt_enrt_rslt_id  in number
                            ,p_prtt_enrt_rslt_id        in number
                            ,p_rslt_object_version_number in number
                            ,p_business_group_id        in number
                            ,p_per_in_ler_id            in number
                            ,p_effective_date           in date
                            ,p_bckdt_per_in_ler_id      in number
                            ,p_pl_bnf_id                in number default null
                            ,p_elig_cvrd_dpnt_id        in number default null
                            ,p_old_pl_bnf_id            in number default null
                            ,p_old_elig_cvrd_dpnt_id    in number default null
                           );

--
end ben_lf_evt_clps_restore;

/
