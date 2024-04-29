--------------------------------------------------------
--  DDL for Package IGS_CA_COMPUTE_DA_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_COMPUTE_DA_VAL_PKG" 
/* $Header: IGSCA15S.pls 120.1 2005/08/16 22:18:10 appldev noship $ */
/*****************************************************
||  Created By : Navin Sidana
||  Created On : 10/13/2004
||  Purpose : Package for computing date alias values.
||  Known limitations, enhancements or remarks :
||  Change History :
||  Who             When            What
||  nsidana         10/13/2004      Created
||  skpandey        17-AUG-2005     Bug:4356272
||                                  Added an additional parameter "app_type" in cal_da_elt_val and cal_da_elt_ofst_val function
*****************************************************/
AUTHID CURRENT_USER AS

TYPE t_ofst_rec IS RECORD(ofst_lvl VARCHAR2(30),
                          dt_alias VARCHAR2(30),
			  da_seq_num NUMBER,
			  offset_cal_type VARCHAR2(30),
			  offset_ci_sequence_number NUMBER,
                          day_offset NUMBER,
			  week_offset NUMBER,
			  month_offset NUMBER,
			  year_offset NUMBER,
			  ofst_override VARCHAR2(1)
			  );

FUNCTION cal_da_elt_val(p_sys_date_type  IN  VARCHAR2,
          	        p_cal_type       IN  VARCHAR2,
		        p_seq_number     IN  NUMBER,
			p_org_unit       IN VARCHAR2,
			p_prog_type      IN VARCHAR2,
			p_prog_ver       IN VARCHAR2,
			p_app_type       IN VARCHAR2 DEFAULT NULL
		        ) RETURN DATE;

FUNCTION cal_da_elt_ofst_val(p_dt_alias     IN  VARCHAR2,
			     p_da_seq_num   IN NUMBER,
			     p_cal_type     IN  VARCHAR2,
			     p_seq_number   IN  NUMBER,
			     p_org_unit     IN VARCHAR2,
			     p_prog_type    IN VARCHAR2,
			     p_prog_ver     IN VARCHAR2,
			     p_app_type     IN VARCHAR2 DEFAULT NULL
			     ) RETURN DATE;

END igs_ca_compute_da_val_pkg;

 

/
