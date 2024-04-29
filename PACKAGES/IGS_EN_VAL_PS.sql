--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PS" AUTHID CURRENT_USER AS
/* $Header: IGSEN57S.pls 120.1 2006/02/08 04:18:53 bdeviset noship $ */

-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed following functions
-- enrp_val_ho_cic_prc
-- enrp_val_hpo_cic_prc
-- enrp_val_hpo_cic_ps
-- enrp_val_hpo_crs_cic
-- enrp_val_hpo_vis_cic


  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_STRT_END_DT
  --                            removed .
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  --bdeviset    08-FEB-2006     Bug No. 3696557. Absoleting the file
  -------------------------------------------------------------------------------------------
END IGS_EN_VAL_PS;

 

/
