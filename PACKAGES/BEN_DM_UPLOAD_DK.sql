--------------------------------------------------------
--  DDL for Package BEN_DM_UPLOAD_DK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_UPLOAD_DK" AUTHID CURRENT_USER AS
/* $Header: benfdmuddk.pkh 120.0 2006/05/04 04:52:31 nkkrishn noship $ */

-- Function to get target ID for given resolve mapping id.
function get_target_id_for_mapping
         (p_resolve_mapping_id  in NUMBER) return NUMBER;

-- DK Resolve for Table BEN_ACTL_PREM_F
procedure get_dk_frm_apr;

-- DK Resolve for Table BEN_ACTN_TYP
procedure get_dk_frm_eat;

-- DK Resolve for Table BEN_ACTY_BASE_RT_F
procedure get_dk_frm_abr;

-- DK Resolve for Table BEN_BENFTS_GRP
procedure get_dk_frm_bng;

-- DK Resolve for Table BEN_BNFTS_BAL_F
procedure get_dk_frm_bnb;

-- DK Resolve for Table BEN_BNFT_PRVDR_POOL_F
procedure get_dk_frm_bpp;

-- DK Resolve for Table BEN_CMBN_PLIP_F
procedure get_dk_frm_cpl;

-- DK Resolve for Table BEN_CMBN_PTIP_F
procedure get_dk_frm_cbp;

-- DK Resolve for Table BEN_CMBN_PTIP_OPT_F
procedure get_dk_frm_cpt;

-- DK Resolve for Table BEN_CM_TRGR
procedure get_dk_frm_bcr;

-- DK Resolve for Table BEN_CM_TYP_F
procedure get_dk_frm_cct;

-- DK Resolve for Table BEN_COMP_LVL_FCTR
procedure get_dk_frm_clf;

-- DK Resolve for Table BEN_CVG_AMT_CALC_MTHD_F
procedure get_dk_frm_ccm;

-- DK Resolve for Table BEN_ENRT_PERD
procedure get_dk_frm_enp;

-- DK Resolve for Table BEN_LEE_RSN_F
procedure get_dk_frm_len;

-- DK Resolve for Table BEN_LER_F
procedure get_dk_frm_ler;

-- DK Resolve for Table BEN_OIPLIP_F
procedure get_dk_frm_boi;

-- DK Resolve for Table BEN_OIPL_F
procedure get_dk_frm_cop;

-- DK Resolve for Table BEN_OPT_F
procedure get_dk_frm_opt;

-- DK Resolve for Table BEN_PGM_F
procedure get_dk_frm_pgm;

-- DK Resolve for Table BEN_PLIP_F
procedure get_dk_frm_cpp;

-- DK Resolve for Table BEN_PL_F
procedure get_dk_frm_pln;

-- DK Resolve for Table BEN_PL_TYP_F
procedure get_dk_frm_ptp;

-- DK Resolve for Table BEN_PTIP_F
procedure get_dk_frm_ctp;

-- DK Resolve for Table BEN_YR_PERD
procedure get_dk_frm_yrp;

-- DK Resolve for Table FF_FORMULAS_F
procedure get_dk_frm_fra;

-- DK Resolve for Table FND_ID_FLEX_STRUCTURES_VL
procedure get_dk_frm_fit;

-- DK Resolve for Table FND_USER
procedure get_dk_frm_fus;

-- DK Resolve for Table HR_ALL_ORGANIZATION_UNITS
procedure get_dk_frm_aou;

-- DK Resolve for Table HR_ALL_ORGANIZATION_UNITS.Busienss greoup
procedure get_dk_frm_ori;

-- DK Resolve for Table HR_LOCATIONS_ALL
procedure get_dk_frm_loc;

-- DK Resolve for Table PAY_ALL_PAYROLLS_F
procedure get_dk_frm_prl;

-- DK Resolve for Table PAY_ELEMENT_TYPES_F
procedure get_dk_frm_pet;

-- DK Resolve for Table PAY_INPUT_VALUES_F
procedure get_dk_frm_ipv;

-- DK Resolve for Table PAY_ELEMENT_LINKS_F
procedure get_dk_frm_pll;

-- DK Resolve for Table PER_ASSIGNMENT_STATUS_TYPES
procedure get_dk_frm_ast;

-- DK Resolve for Table PER_GRADES
procedure get_dk_frm_gra;

-- DK Resolve for Table PER_JOBS
procedure get_dk_frm_job;

-- DK Resolve for Table PER_PAY_BASES
procedure get_dk_frm_pyb;

-- DK Resolve for Table PER_PERSON_TYPES
procedure get_dk_frm_prt;

-- DK Resolve for Table PER_ABSENCE_ATTENDANCE_TYPES
procedure get_dk_frm_aat;

-- DK Resolve for Table PER_ABS_ATTENDANCE_REASONS
procedure get_dk_frm_aar;

-- DK Resolve for Table HR_SOFT_CODING_KEYFLEX
procedure get_dk_frm_scl;

-- DK Resolve for Table PAY_PEOPLE_GROUPS
procedure get_dk_frm_peg;
--
-- General procedure call all other
Procedure  get_dk_frm_all ;




end ben_dm_upload_dk;

 

/
