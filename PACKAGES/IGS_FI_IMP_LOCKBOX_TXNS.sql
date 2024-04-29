--------------------------------------------------------
--  DDL for Package IGS_FI_IMP_LOCKBOX_TXNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_IMP_LOCKBOX_TXNS" AUTHID CURRENT_USER AS
/* $Header: IGSFI58S.pls 115.7 2002/11/29 00:26:39 nsidana ship $ */
  /******************************************************************
  Created By         :Sanjeeb Rakshit
  Date Created By    :25-APR-2001
  Purpose            :This package implements one procedure which insert rows to credits table
                      from interface table if everything is fine else updates the interface table
                      and writes appropriate message in the log file.

  remarks            :
  Change History
  Who      When        What
  agairola 24-Apr-2002 for the bug fix 2336504, removed the parameter p_credit_class
  sykrishn  05-FEB-2002 --- Removed parameter credit source from this package
  sarakshi 25-APR-2001  implementation of the package from scratch.
   ******************************************************************/

PROCEDURE import_lockbox(    errbuf  OUT NOCOPY  VARCHAR2,
                             retcode OUT NOCOPY  NUMBER,
                             p_receipt_lockbox_number igs_fi_crd_int_all.receipt_lockbox_number%TYPE DEFAULT  NULL,
                             p_credit_instrument      igs_fi_crd_int_all.credit_instrument%TYPE ,
                             p_credit_type_id         igs_fi_crd_int_all.credit_type_id%TYPE ,
                             p_org_id                 NUMBER
                             );

END igs_fi_imp_lockbox_txns;

 

/
