--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_FEE_ROLLV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_FEE_ROLLV" AUTHID CURRENT_USER AS
/* $Header: IGSFI10S.pls 120.0 2005/06/02 03:55:49 appldev noship $ */

  --
  -- Call to  package routine allows the package to be pinned in memory.
  PROCEDURE genp_pin_package
;
  --
  -- Routine to process fee structure data rollover between cal instances
  PROCEDURE finp_prc_fee_rollvr(
    errbuf  out NOCOPY  varchar2,
	retcode out NOCOPY  number,
	p_rollover_fee_type_ci_ind IN VARCHAR ,
	p_rollover_fee_cat_ci_ind IN VARCHAR ,
	P_Source_Calendar  IN VARCHAR2,
	P_Dest_Calendar IN VARCHAR2 ,
	p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
	p_fee_cat IN IGS_FI_F_CAT_CA_INST.fee_cat%TYPE ,
	p_fee_type_ci_status IN            IGS_FI_F_TYP_CA_INST_ALL.fee_type_ci_status%TYPE ,
	p_fee_cat_ci_status IN             IGS_FI_F_CAT_CA_INST.fee_cat_ci_status%TYPE ,
	p_fee_liability_status IN          IGS_FI_F_CAT_FEE_LBL_ALL.fee_liability_status%TYPE,
	p_org_id NUMBER
  );
gv_log_type		IGS_GE_S_LOG_ENTRY.s_log_type%TYPE;
gv_log_creation_dt	IGS_GE_S_LOG_ENTRY.creation_dt%TYPE;
gv_log_key		IGS_GE_S_LOG_ENTRY.key%TYPE;
END IGS_FI_PRC_FEE_ROLLV;

 

/
