--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_013
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_013" AUTHID CURRENT_USER AS
/* $Header: IGSAD91S.pls 115.9 2003/12/09 13:07:30 pbondugu ship $ */


PROCEDURE prc_address_usages (
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER )   ;

 /*
  ||  Created By : prabhat.patel@Oracle.com
  ||  Created On : 06-Jul-2001
  ||  Purpose : This procedure is for importing person type Information.
  ||            DLD: Import Person Type.  Enh Bug# 2853521.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
 */

PROCEDURE prc_pe_type (
 p_source_type_id IN NUMBER,
 p_batch_id       IN NUMBER
 );

PROCEDURE PRC_PE_ACAD_HIST (
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2
);

PROCEDURE prc_pe_cred_details  (
p_interface_run_id  igs_ad_interface_all.interface_run_id%TYPE,
p_rule     VARCHAR2,
p_enable_log   VARCHAR2
) ;

END  IGS_AD_IMP_013;

 

/
