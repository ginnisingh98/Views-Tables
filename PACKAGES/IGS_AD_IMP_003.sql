--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_003" AUTHID CURRENT_USER AS
/* $Header: IGSAD81S.pls 115.7 2003/12/09 11:27:01 rghosh ship $ */
/*
  ||  Created By : pkpatel
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       11-NOV-2001      Bug no.2103692 :For Person Interface DLD
  ||                                Modified the Name of the Procedure PRC_APCNT_ATH_DTLS to PRC_APCNT_ATH
  ||  (reverse chronological order - newest change first)
*/

 PROCEDURE prc_acad_int(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2);


/*
  ||  Created By : pkpatel
  ||  Created On : 22-JUN-2001
  ||  Purpose : This procedure process the Application
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pkpatel       11-NOV-2001      Bug no.2103692 :For Person Interface DLD
  ||                                Modified the Name of the Procedure PRC_APCNT_ATH_DTLS to PRC_APCNT_ATH
  || pbondugu    28-Nov-2003    Removed the procedure PRC_APCNT_ATH (Moved to IGSAD91)
  ||  (reverse chronological order - newest change first)
*/


 PROCEDURE prc_apcnt_indt(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2);

  PROCEDURE prc_apcnt_oth_inst_apld(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2);

   PROCEDURE prc_apcnt_spl_intrst(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2);


   PROCEDURE prc_apcnt_spl_tal(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_category_meaning IN VARCHAR2,
                                   p_rule             IN VARCHAR2);

  PROCEDURE prc_pe_persstat_details(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2);


   PROCEDURE prc_appl_fees(
                                   p_interface_run_id IN NUMBER,
                                   p_enable_log       IN VARCHAR2,
                                   p_rule             IN VARCHAR2);


END IGS_AD_IMP_003;

 

/
