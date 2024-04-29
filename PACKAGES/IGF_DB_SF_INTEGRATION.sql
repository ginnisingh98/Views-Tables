--------------------------------------------------------
--  DDL for Package IGF_DB_SF_INTEGRATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_SF_INTEGRATION" AUTHID CURRENT_USER AS
/* $Header: IGFDB06S.pls 120.0 2005/06/01 13:59:54 appldev noship $ */
/***********************************************************************************************

  Created By     :  Sarakshi
  Date Created By:  24-Dec-2001
  Purpose        :  This package declares procedure/function needed for the implementation of transfering
                    Disbursement Details to SF.

  Known limitations,enhancements,remarks:
  Change History
  Who     When        What
vvutukur 20-Nov-2002 Enh#2584986.Added p_d_gl_date parameter to transfer_disb_dtls_to_sf.
********************************************************************************************** */
PROCEDURE transfer_disb_dtls_to_sf(
                   errbuf             OUT NOCOPY   VARCHAR2,
                   retcode            OUT NOCOPY   NUMBER,
                   p_award_year       IN    VARCHAR2,
                   p_base_id          IN    igf_ap_fa_con_v.base_id%TYPE,
                   p_person_group_id  IN    igs_pe_persid_group_v.group_id%TYPE,
                   p_fund_id          IN    igf_aw_fund_mast.fund_id%TYPE,
                   p_term_calendar    IN    VARCHAR2,
		   p_d_gl_date        IN    VARCHAR2 DEFAULT NULL
                 );

END IGF_DB_SF_INTEGRATION;

 

/
