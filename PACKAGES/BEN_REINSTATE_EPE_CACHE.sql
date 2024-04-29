--------------------------------------------------------
--  DDL for Package BEN_REINSTATE_EPE_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_REINSTATE_EPE_CACHE" AUTHID CURRENT_USER as
/* $Header: berepech.pkh 120.0 2005/05/28 11:38:55 appldev noship $*/
--
/*
+==============================================================================+
|			 Copyright (c) 1997 Oracle Corporation		       |
|			    Redwood Shores, California, USA		       |
|				All rights reserved.			       |
+==============================================================================+
--
History
  Version    Date	Who	   What?
  ---------  ---------	---------- --------------------------------------------
  115.0      01-Apr-05	ikasire    Created.
  -----------------------------------------------------------------------------
*/
--
type g_pilepe_inst_row is record
     (  ALWS_DPNT_DSGN_FLAG           	BEN_ELIG_PER_ELCTBL_CHC.ALWS_DPNT_DSGN_FLAG%type
       ,APPROVAL_STATUS_CD            	BEN_ELIG_PER_ELCTBL_CHC.APPROVAL_STATUS_CD%type
       ,ASSIGNMENT_ID                 	BEN_ELIG_PER_ELCTBL_CHC.ASSIGNMENT_ID%type
       ,AUTO_ENRT_FLAG                	BEN_ELIG_PER_ELCTBL_CHC.AUTO_ENRT_FLAG%type
       ,BNFT_PRVDR_POOL_ID            	BEN_ELIG_PER_ELCTBL_CHC.BNFT_PRVDR_POOL_ID%type
       ,BUSINESS_GROUP_ID             	BEN_ELIG_PER_ELCTBL_CHC.BUSINESS_GROUP_ID%type
       ,CMBN_PLIP_ID                  	BEN_ELIG_PER_ELCTBL_CHC.CMBN_PLIP_ID%type
       ,CMBN_PTIP_ID                  	BEN_ELIG_PER_ELCTBL_CHC.CMBN_PTIP_ID%type
       ,CMBN_PTIP_OPT_ID              	BEN_ELIG_PER_ELCTBL_CHC.CMBN_PTIP_OPT_ID%type
       ,COMP_LVL_CD                   	BEN_ELIG_PER_ELCTBL_CHC.COMP_LVL_CD%type
       ,CRNTLY_ENRD_FLAG              	BEN_ELIG_PER_ELCTBL_CHC.CRNTLY_ENRD_FLAG%type
       ,CRYFWD_ELIG_DPNT_CD           	BEN_ELIG_PER_ELCTBL_CHC.CRYFWD_ELIG_DPNT_CD%type
       ,CTFN_RQD_FLAG                 	BEN_ELIG_PER_ELCTBL_CHC.CTFN_RQD_FLAG%type
       ,DFLT_FLAG                     	BEN_ELIG_PER_ELCTBL_CHC.DFLT_FLAG%type
       ,DPNT_CVG_STRT_DT_CD           	BEN_ELIG_PER_ELCTBL_CHC.DPNT_CVG_STRT_DT_CD%type
       ,DPNT_CVG_STRT_DT_RL           	BEN_ELIG_PER_ELCTBL_CHC.DPNT_CVG_STRT_DT_RL%type
       ,DPNT_DSGN_CD                  	BEN_ELIG_PER_ELCTBL_CHC.DPNT_DSGN_CD%type
       ,ELCTBL_FLAG                   	BEN_ELIG_PER_ELCTBL_CHC.ELCTBL_FLAG%type
       ,ELIG_FLAG                     	BEN_ELIG_PER_ELCTBL_CHC.ELIG_FLAG%type
       ,ELIG_OVRID_DT                 	BEN_ELIG_PER_ELCTBL_CHC.ELIG_OVRID_DT%type
       ,ELIG_OVRID_PERSON_ID          	BEN_ELIG_PER_ELCTBL_CHC.ELIG_OVRID_PERSON_ID%type
       ,ELIG_PER_ELCTBL_CHC_ID        	BEN_ELIG_PER_ELCTBL_CHC.ELIG_PER_ELCTBL_CHC_ID%type
       ,ENRT_CVG_STRT_DT              	BEN_ELIG_PER_ELCTBL_CHC.ENRT_CVG_STRT_DT%type
       ,ENRT_CVG_STRT_DT_CD           	BEN_ELIG_PER_ELCTBL_CHC.ENRT_CVG_STRT_DT_CD%type
       ,ENRT_CVG_STRT_DT_RL           	BEN_ELIG_PER_ELCTBL_CHC.ENRT_CVG_STRT_DT_RL%type
       ,ERLST_DEENRT_DT               	BEN_ELIG_PER_ELCTBL_CHC.ERLST_DEENRT_DT%type
       ,FONM_CVG_STRT_DT              	BEN_ELIG_PER_ELCTBL_CHC.FONM_CVG_STRT_DT%type
       ,INELIG_RSN_CD                 	BEN_ELIG_PER_ELCTBL_CHC.INELIG_RSN_CD%type
       ,INTERIM_ELIG_PER_ELCTBL_CHC_ID	BEN_ELIG_PER_ELCTBL_CHC.INTERIM_ELIG_PER_ELCTBL_CHC_ID%type
       ,IN_PNDG_WKFLOW_FLAG           	BEN_ELIG_PER_ELCTBL_CHC.IN_PNDG_WKFLOW_FLAG%type
       ,LER_CHG_DPNT_CVG_CD           	BEN_ELIG_PER_ELCTBL_CHC.LER_CHG_DPNT_CVG_CD%type
       ,MGR_OVRID_DT                  	BEN_ELIG_PER_ELCTBL_CHC.MGR_OVRID_DT%type
       ,MGR_OVRID_PERSON_ID           	BEN_ELIG_PER_ELCTBL_CHC.MGR_OVRID_PERSON_ID%type
       ,MNDTRY_FLAG                   	BEN_ELIG_PER_ELCTBL_CHC.MNDTRY_FLAG%type
       ,MUST_ENRL_ANTHR_PL_ID         	BEN_ELIG_PER_ELCTBL_CHC.MUST_ENRL_ANTHR_PL_ID%type
       ,OBJECT_VERSION_NUMBER         	BEN_ELIG_PER_ELCTBL_CHC.OBJECT_VERSION_NUMBER%type
       ,OIPLIP_ID                     	BEN_ELIG_PER_ELCTBL_CHC.OIPLIP_ID%type
       ,OIPL_ID                       	BEN_ELIG_PER_ELCTBL_CHC.OIPL_ID%type
       ,OIPL_ORDR_NUM                 	BEN_ELIG_PER_ELCTBL_CHC.OIPL_ORDR_NUM%type
       ,PER_IN_LER_ID                 	BEN_ELIG_PER_ELCTBL_CHC.PER_IN_LER_ID%type
       ,PGM_ID                        	BEN_ELIG_PER_ELCTBL_CHC.PGM_ID%type
       ,PIL_ELCTBL_CHC_POPL_ID        	BEN_ELIG_PER_ELCTBL_CHC.PIL_ELCTBL_CHC_POPL_ID%type
       ,PLIP_ID                       	BEN_ELIG_PER_ELCTBL_CHC.PLIP_ID%type
       ,PLIP_ORDR_NUM                 	BEN_ELIG_PER_ELCTBL_CHC.PLIP_ORDR_NUM%type
       ,PL_ID                         	BEN_ELIG_PER_ELCTBL_CHC.PL_ID%type
       ,PL_ORDR_NUM                   	BEN_ELIG_PER_ELCTBL_CHC.PL_ORDR_NUM%type
       ,PL_TYP_ID                     	BEN_ELIG_PER_ELCTBL_CHC.PL_TYP_ID%type
       ,PROCG_END_DT                  	BEN_ELIG_PER_ELCTBL_CHC.PROCG_END_DT%type
       ,PRTT_ENRT_RSLT_ID             	BEN_ELIG_PER_ELCTBL_CHC.PRTT_ENRT_RSLT_ID%type
       ,PTIP_ID                       	BEN_ELIG_PER_ELCTBL_CHC.PTIP_ID%type
       ,PTIP_ORDR_NUM                 	BEN_ELIG_PER_ELCTBL_CHC.PTIP_ORDR_NUM%type
       ,ROLL_CRS_FLAG                 	BEN_ELIG_PER_ELCTBL_CHC.ROLL_CRS_FLAG%type
       ,SPCL_RT_OIPL_ID               	BEN_ELIG_PER_ELCTBL_CHC.SPCL_RT_OIPL_ID%type
       ,SPCL_RT_PL_ID                 	BEN_ELIG_PER_ELCTBL_CHC.SPCL_RT_PL_ID%type
       ,WS_MGR_ID                     	BEN_ELIG_PER_ELCTBL_CHC.WS_MGR_ID%type
       ,YR_PERD_ID                    	BEN_ELIG_PER_ELCTBL_CHC.YR_PERD_ID%type
  );
--
type g_pilepe_inst_tbl is table of g_pilepe_inst_row
  index by binary_integer;
--
g_currepe_row                   g_pilepe_inst_row;
g_currcobjepe_row               g_pilepe_inst_row;
--
procedure get_perpilepe_list
  (p_per_in_ler_id in     number
  ,p_inst_set      in out NOCOPY g_pilepe_inst_tbl
  );
--
g_epe_instance     g_pilepe_inst_tbl;
--
procedure EPE_GetEPEDets
  (p_elig_per_elctbl_chc_id in     number
  ,p_per_in_ler_id          in     number
  ,p_inst_row               in out NOCOPY g_pilepe_inst_row
  );
--
procedure get_pilcobjepe_dets
  (p_per_in_ler_id  in     number
  ,p_pgm_id         in     number
  ,p_pl_id          in     number
  ,p_oipl_id        in     number
  --
  ,p_inst_row       in out NOCOPY g_pilepe_inst_row
  );
--
procedure init_context_pileperow;
--
procedure init_context_cobj_pileperow;
--
------------------------------------------------------------------------
-- DELETE CACHED DATA
------------------------------------------------------------------------
procedure clear_down_cache;
--
END ben_reinstate_epe_cache;

 

/
