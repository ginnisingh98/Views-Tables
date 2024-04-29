--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_007
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_007" AUTHID CURRENT_USER AS
/* $Header: IGSAD85S.pls 115.7 2002/11/29 06:36:50 gmuralid ship $ */
/*
 ||  Change History :
 ||  Who             When            What
 ||  ssawhney       15 nov       Bug no.2103692:Person Interface DLD
 ||                              prc_pe_intl_dtls changed to prc_pe_visa_pass
 ||  adhawan        19 nov       Bug no.2103692:Person Interface DLD
 ||                              prc_pe_hlth_ins_dtls changed to prc_pe_hlth_dtls
    */

PROCEDURE prc_pe_mltry_dtls(
  p_source_type_id IN NUMBER,
  p_batch_id IN VARCHAR2 );

PROCEDURE prc_pe_hlth_dtls(
  p_source_type_id IN	NUMBER,
  p_batch_id IN NUMBER );

PROCEDURE prc_pe_id_types(
  p_source_type_id IN	NUMBER,
  p_batch_id IN NUMBER );

-- structure of International Details Import has now changed.

PROCEDURE prc_pe_hz_citizenship(
  p_source_type_id	IN	NUMBER,
  p_batch_id	IN	NUMBER	   );

PROCEDURE prc_pe_fund_source(
  p_source_type_id	IN	NUMBER,
  p_batch_id	IN	NUMBER	   );


PROCEDURE prc_pe_intl_dtls(
  p_source_type_id IN	NUMBER,
  p_batch_id IN NUMBER  );


END igs_ad_imp_007;

 

/
