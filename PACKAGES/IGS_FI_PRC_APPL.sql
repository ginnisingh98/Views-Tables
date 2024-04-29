--------------------------------------------------------
--  DDL for Package IGS_FI_PRC_APPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PRC_APPL" AUTHID CURRENT_USER AS
/* $Header: IGSFI56S.pls 115.10 2002/11/29 00:26:14 nsidana ship $ */

/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 25-Apr-2001
Purpose           : This function is used when the user has not passed
                    any low date, returns the min effective date from the
                    credits table

Known limitations,
enhancements,
remarks            :
Change History
Who      When          What
smadathi  20-NOV-2002  Enh. Bug 2584986. Added new parameter GL Date to procedure mass_application
                       and mass_apply
schodava  19-Sep-2002  Enh # 2564643 - Subaccount Removal
		       Modified procedures mass_application, mass_apply
agairola 23-May-2002   Added the procedure get_cal_details for bug 2378182
agairola 20-Mar-2002   Created a wrapper procedure mass_apply for the refunds
sykrishn  24-jAN-2002  Declaration of PL/SQL table for enh 2191470 -SFCR020
******************************************************************/

/* The Pl/SQL table introduced in the earlier version intermdiate check in as the design was reverted back
Hence the spec will look similar to older versions */



  PROCEDURE mass_application ( errbuf           OUT NOCOPY  VARCHAR2,
                               retcode          OUT NOCOPY  NUMBER,
                               p_org_id              NUMBER,
                               p_person_id           igs_fi_inv_int_all.person_id%TYPE,
                               p_person_id_grp       igs_pe_prsid_grp_mem_all.group_id%TYPE DEFAULT NULL,
                               p_credit_number       igs_fi_credits_all.credit_number%TYPE,
                               p_credit_type_id      igs_fi_credits_all.credit_type_id%TYPE,
                               p_credit_date_low     VARCHAR2,
                               p_credit_date_high    VARCHAR2,
			       p_d_gl_date           VARCHAR2
			       ) ;

  PROCEDURE mass_apply(p_person_id           igs_fi_inv_int_all.person_id%TYPE,
                       p_person_id_grp       igs_pe_prsid_grp_mem_all.group_id%TYPE DEFAULT NULL,
                       p_credit_number       igs_fi_credits_all.credit_number%TYPE,
                       p_credit_type_id      igs_fi_credits_all.credit_type_id%TYPE,
                       p_credit_date_low     VARCHAR2,
                       p_credit_date_high    VARCHAR2,
		       p_d_gl_date           DATE
		       ) ;

  PROCEDURE get_cal_details(p_fee_cal_type        igs_ca_inst.cal_type%TYPE,
                            p_fee_seq             igs_ca_inst.sequence_number%TYPE,
                            p_end_dt         OUT NOCOPY  igs_ca_inst.end_dt%TYPE,
                            p_message        OUT NOCOPY  fnd_new_messages.message_name%TYPE,
                            p_status         OUT NOCOPY  BOOLEAN);


END igs_fi_prc_appl;

 

/
