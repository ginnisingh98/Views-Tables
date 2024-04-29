--------------------------------------------------------
--  DDL for Package IGS_FI_TRAN_LOCKBOX_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_TRAN_LOCKBOX_TXNS" AUTHID CURRENT_USER AS
/* $Header: IGSFI55S.pls 115.6 2002/11/29 00:25:56 nsidana ship $ */

/***************************************************************
   Created By		:	bayadav
   Date Created By	:	2001/04/25
   Purpose		:       To upload data from 'AR_CASH_RECEIPTS' AR Cash Receipts
                                table into 'IGS_FI_CRD_INT_ALL' credit interface table
   Known Limitations,Enhancements or Remarks:
   Change History	:
   Who			When		What
   vvutukur           21-Nov-2002       Enh#2584986.Added new parameter p_d_gl_date parameter.
   sykrishn           19-FEB-2002	Removed DEFAULT NULL for param p_lockbox_num as part of SFCR023 - 2227831
 ***************************************************************/

PROCEDURE     transfer_lockbox(ERRBUF    	  OUT NOCOPY  VARCHAR2,
                               RETCODE		  OUT NOCOPY  NUMBER,
                               p_person_id        IN   igs_pe_person_v.person_id%TYPE      DEFAULT NULL,
                               p_person_id_group  IN   igs_pe_persid_group_v.group_id%TYPE DEFAULT NULL,
                               p_lockbox_num      IN   ar_lockboxes.lockbox_number%TYPE,
                               p_txn_date_low     IN   VARCHAR2 DEFAULT NULL,
                               p_txn_date_high    IN   VARCHAR2 DEFAULT NULL,
                               p_org_id           IN   NUMBER,
			       p_d_gl_date        IN   VARCHAR2
			       );
END igs_fi_tran_lockbox_txns;

 

/
