--------------------------------------------------------
--  DDL for Package BEN_PD_COPY_TO_BEN_FOUR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PD_COPY_TO_BEN_FOUR" AUTHID CURRENT_USER as
/* $Header: bepdccp4.pkh 120.1 2005/12/12 06:19:56 abparekh noship $ */
--
--
--
--
procedure create_CGP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EAN_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EAP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EBN_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EBU_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_ECL_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_ECP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_ECQ_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_ECY_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EDG_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EDI_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EDP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_EDT_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
--
procedure create_ERL_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);
--
procedure create_EHW_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);


procedure create_EJP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);


procedure create_ELU_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_ELN_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_ELR_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_ELS_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_ELV_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_EMP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_ENO_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_EOM_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_EOU_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_EOY_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_EPF_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);


procedure create_EPT_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

procedure create_EPG_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
);

--
--
---------------------------------------------------------------
----------------------< create_EPB_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EPB_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EPN_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EPN_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EPP_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EPP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EPS_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EPS_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EPY_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EPY_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EPZ_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EPZ_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EQT_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EQT_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_ESA_rows >-----------------------
---------------------------------------------------------------
--
procedure create_ESA_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_ESH_rows >-----------------------
---------------------------------------------------------------
--
procedure create_ESH_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_ESP_rows >-----------------------
---------------------------------------------------------------
--
procedure create_ESP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EST_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EST_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;
--
---------------------------------------------------------------
----------------------< create_EWL_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EWL_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;

-- 1. ETD.sql     BEN_ELIG_DPNT_OTHR_PTIP_F

--
---------------------------------------------------------------
----------------------< create_ETD_rows >-----------------------
---------------------------------------------------------------
--
procedure create_ETD_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;



-- 4. ECT.SQL         BEN_ELIG_DSBLTY_CTG_PRTE_F

   --
   ---------------------------------------------------------------
   ----------------------< create_ECT_rows >-----------------------
   ---------------------------------------------------------------
   --
   procedure create_ECT_rows
   (
		 p_validate                       in  number     default 0
		,p_copy_entity_txn_id             in  number
		,p_effective_date                 in  date
		,p_prefix_suffix_text             in  varchar2  default null
		,p_reuse_object_flag              in  varchar2  default null
		,p_target_business_group_id       in  varchar2  default null
		,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 5. EDD.sql  BEN_ELIG_DSBLTY_DGR_PRTE_F
 --
 ---------------------------------------------------------------
 ----------------------< create_EDD_rows >-----------------------
 ---------------------------------------------------------------
 --
 procedure create_EDD_rows
 (
	   p_validate                       in  number     default 0
	  ,p_copy_entity_txn_id             in  number
	  ,p_effective_date                 in  date
	  ,p_prefix_suffix_text             in  varchar2  default null
	  ,p_reuse_object_flag              in  varchar2  default null
	  ,p_target_business_group_id       in  varchar2  default null
	  ,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 6. EDR.sql      BEN_ELIG_DSBLTY_RSN_PRTE_F

--
---------------------------------------------------------------
----------------------< create_EDR_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EDR_rows
(
	  p_validate                       in  number     default 0
	 ,p_copy_entity_txn_id             in  number
	 ,p_effective_date                 in  date
	 ,p_prefix_suffix_text             in  varchar2  default null
	 ,p_reuse_object_flag              in  varchar2  default null
	 ,p_target_business_group_id       in  varchar2  default null
	 ,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 7. EES.sql          BEN_ELIG_EE_STAT_PRTE_F

--
---------------------------------------------------------------
----------------------< create_EES_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EES_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 8. EEI.sql   BEN_ELIG_ENRLD_ANTHR_OIPL_F

--
---------------------------------------------------------------
----------------------< create_EEI_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EEI_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 9. EEG.sql BEN_ELIG_ENRLD_ANTHR_PGM_F
--
---------------------------------------------------------------
----------------------< create_EEG_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EEG_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 10. EAI.sql  BEN_ELIG_ENRLD_ANTHR_PLIP_F

--
---------------------------------------------------------------
----------------------< create_EAI_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EAI_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 11 .EEP.sql  BEN_ELIG_ENRLD_ANTHR_PL_F

--
---------------------------------------------------------------
----------------------< create_EEP_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EEP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;



-- 12. EET.sql BEN_ELIG_ENRLD_ANTHR_PTIP_F


   --
---------------------------------------------------------------
----------------------< create_EET_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EET_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;

-- 13.  EFP.sql  BEN_ELIG_FL_TM_PT_TM_PRTE_F

--
---------------------------------------------------------------
----------------------< create_EFP_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EFP_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 15  EGR   BEN_ELIG_GRD_PRTE_F

--
---------------------------------------------------------------
----------------------< create_EGR_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EGR_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;


-- 17 EHS.sql  BEN_ELIG_HRLY_SLRD_PRTE_F

--
---------------------------------------------------------------
----------------------< create_EHS_rows >-----------------------
---------------------------------------------------------------
--
procedure create_EHS_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;

procedure create_all_elig_prf_ben_rows
(
	 p_validate                       in  number     default 0
	,p_copy_entity_txn_id             in  number
	,p_effective_date                 in  date
	,p_prefix_suffix_text             in  varchar2  default null
	,p_reuse_object_flag              in  varchar2  default null
	,p_target_business_group_id       in  varchar2  default null
	,p_prefix_suffix_cd               in  varchar2  default null
) ;

---------------------------------------------------------------
----------------------< create_ECV_rows >-----------------------
---------------------------------------------------------------
--
PROCEDURE create_ecv_rows (
   p_validate                   IN   NUMBER DEFAULT 0,
   p_copy_entity_txn_id         IN   NUMBER,
   p_effective_date             IN   DATE,
   p_prefix_suffix_text         IN   VARCHAR2 DEFAULT NULL,
   p_reuse_object_flag          IN   VARCHAR2 DEFAULT NULL,
   p_target_business_group_id   IN   VARCHAR2 DEFAULT NULL,
   p_prefix_suffix_cd           IN   VARCHAR2 DEFAULT NULL
) ;



End BEN_PD_COPY_TO_BEN_FOUR;

 

/
