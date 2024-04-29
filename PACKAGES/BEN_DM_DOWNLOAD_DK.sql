--------------------------------------------------------
--  DDL for Package BEN_DM_DOWNLOAD_DK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_DM_DOWNLOAD_DK" AUTHID CURRENT_USER AS
/* $Header: benfdmdddk.pkh 120.0 2006/05/04 04:47:27 nkkrishn noship $ */

--
-- Function to check if the DK already exists in the
-- BEN_DM_RESOLVE_MAPPINGS table.
--
function check_if_dk_exists(p_table_name           in VARCHAR2
                           ,p_column_name          in VARCHAR2
                           ,p_source_id            in NUMBER
                           ,p_business_group_name  in VARCHAR2) return boolean;

--
-- Function to get the resolve_mapping_id from the cache.
--
function get_dk_from_cache(p_table_name           in VARCHAR2
                           ,p_column_name          in VARCHAR2
                           ,p_source_id            in NUMBER
                           ,p_business_group_name  in VARCHAR2) return number;

-- DK Resolve from Table BEN_ACTL_PREM_F
procedure get_dk_frm_apr (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_ACTN_TYP
procedure get_dk_frm_eat (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_ACTY_BASE_RT_F
procedure get_dk_frm_abr (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_BENFTS_GRP
procedure get_dk_frm_bng (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_BNFTS_BAL_F
procedure get_dk_frm_bnb (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_BNFT_PRVDR_POOL_F
procedure get_dk_frm_bpp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_CMBN_PLIP_F
procedure get_dk_frm_cpl (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_CMBN_PTIP_F
procedure get_dk_frm_cbp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_CMBN_PTIP_OPT_F
procedure get_dk_frm_cpt (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_CM_TRGR
procedure get_dk_frm_bcr (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_CM_TYP_F
procedure get_dk_frm_cct (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_COMP_LVL_FCTR
procedure get_dk_frm_clf (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_CVG_AMT_CALC_MTHD_F
procedure get_dk_frm_ccm (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_ENRT_PERD
procedure get_dk_frm_enp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_LEE_RSN_F
procedure get_dk_frm_len (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_LER_F
procedure get_dk_frm_ler (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_OIPLIP_F
procedure get_dk_frm_boi (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_OIPL_F
procedure get_dk_frm_cop (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_OPT_F
procedure get_dk_frm_opt (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_PGM_F
procedure get_dk_frm_pgm (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_PLIP_F
procedure get_dk_frm_cpp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_PL_F
procedure get_dk_frm_pln (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_PL_TYP_F
procedure get_dk_frm_ptp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_PTIP_F
procedure get_dk_frm_ctp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table BEN_YR_PERD
procedure get_dk_frm_yrp (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table FF_FORMULAS_F
procedure get_dk_frm_fra (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table FND_ID_FLEX_STRUCTURES_VL
procedure get_dk_frm_fit (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table FND_USER
procedure get_dk_frm_fus (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table HR_ALL_ORGANIZATION_UNITS
procedure get_dk_frm_aou (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table HR_ALL_ORGANIZATION_UNITS  (BG)
procedure get_dk_frm_ori (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                          ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table HR_LOCATIONS_ALL
procedure get_dk_frm_loc (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PAY_ALL_PAYROLLS_F
procedure get_dk_frm_prl (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PAY_ELEMENT_TYPES_F
procedure get_dk_frm_pet (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PAY_INPUT_VALUES_F
procedure get_dk_frm_ipv (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PAY_ELEMENT_LINKS_F
procedure get_dk_frm_pll (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_ASSIGNMENT_STATUS_TYPES
procedure get_dk_frm_ast (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_GRADES
procedure get_dk_frm_gra (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_JOBS
procedure get_dk_frm_job (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_PAY_BASES
procedure get_dk_frm_pyb (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_PERSON_TYPES
procedure get_dk_frm_prt (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_ABSENCE_ATTENDANCE_TYPES
procedure get_dk_frm_aat (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PER_ABS_ATTENDANCE_REASONS
procedure get_dk_frm_aar (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table HR_SOFT_CODING_KEYFLEX
procedure get_dk_frm_scl (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);

-- DK Resolve from Table PAY_PEOPLE_GROUPS
procedure get_dk_frm_peg (p_business_group_name in VARCHAR2
                         ,p_source_id           in NUMBER
                         ,p_resolve_mapping_id  out nocopy NUMBER);
--
end ben_dm_download_dk;

 

/
