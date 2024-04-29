--------------------------------------------------------
--  DDL for Package IGS_AD_IMP_012
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_IMP_012" AUTHID CURRENT_USER AS
/* $Header: IGSAD90S.pls 115.11 2003/10/21 06:40:55 asbala ship $ */

/*
 ||  Change History :
 ||  Who             When            What
 ||  ssawhney       15 nov       Bug no.2103692:Person Interface DLD
 ||                              prc_pe_citizenship is now in IGS_AD_IMP_007
 ||                              it is changed to prc_pe_hz_citizenship.
    */

PROCEDURE prc_pe_cntct_dtls (
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER );
PROCEDURE prc_pe_language (
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER );
PROCEDURE prc_apcnt_ath(
 p_source_type_id IN NUMBER,
 p_batch_id IN NUMBER );

END IGS_AD_IMP_012;

 

/
