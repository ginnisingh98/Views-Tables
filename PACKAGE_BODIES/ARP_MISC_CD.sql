--------------------------------------------------------
--  DDL for Package Body ARP_MISC_CD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_MISC_CD" AS
/* $Header: ARPLMCDB.pls 120.3 2006/06/09 16:23:23 hyu ship $ */

FUNCTION ins_misc_cash_distributions (last_updated_by         NUMBER,
                                      last_update_date        DATE,
                                      last_update_login       NUMBER,
                                      created_by              NUMBER,
                                      creation_date           DATE,
                                      cash_receipt_id         NUMBER,
                                      code_combination_id     NUMBER,
                                      set_of_books_id         NUMBER,
                                      gl_date                 DATE,
                                      percent                 NUMBER,
                                      amount                  NUMBER,
                                      comments                VARCHAR2,
                                      gl_posted_date          DATE,
                                      apply_date              DATE,
                                      posting_control_id      NUMBER,
                                      request_id              NUMBER,
                                      program_application_id  NUMBER,
                                      program_id              NUMBER,
                                      program_update_date     DATE,
                                      acctd_amount            NUMBER,
                                      ussgl_tran_code         VARCHAR2,
                                      ussgl_tran_code_context VARCHAR2,
                                      created_from            VARCHAR2,
                                      reversal_gl_date        DATE,
                                      --BUG#5201086
                                      p_cash_receipt_history_id    NUMBER   DEFAULT NULL)
          RETURN NUMBER
IS
    CURSOR get_id IS
       SELECT AR_MISC_CASH_DISTRIBUTIONS_S.NEXTVAL
       FROM   DUAL;
    misc_id    NUMBER;
BEGIN
arp_standard.debug('ins_misc_cash_distributions +');

    /*-----------------------*
     | get unique identifier |
     *-----------------------*/

    OPEN get_id;
    FETCH get_id INTO misc_id;
    CLOSE get_id;

    /*---------------*
     | Insert Record |
     *---------------*/

   INSERT INTO AR_MISC_CASH_DISTRIBUTIONS(MISC_CASH_DISTRIBUTION_ID,
                                          LAST_UPDATED_BY,
                                          LAST_UPDATE_DATE,
                                          LAST_UPDATE_LOGIN,
                                          CREATED_BY,
                                          CREATION_DATE,
                                          CASH_RECEIPT_ID,
                                          CODE_COMBINATION_ID,
                                          SET_OF_BOOKS_ID,
                                          GL_DATE,
                                          PERCENT,
                                          AMOUNT,
                                          COMMENTS,
                                          GL_POSTED_DATE,
                                          APPLY_DATE,
                                          ATTRIBUTE_CATEGORY,
                                          ATTRIBUTE1,
                                          ATTRIBUTE2,
                                          ATTRIBUTE3,
                                          ATTRIBUTE4,
                                          ATTRIBUTE5,
                                          ATTRIBUTE6,
                                          ATTRIBUTE7,
                                          ATTRIBUTE8,
                                          ATTRIBUTE9,
                                          ATTRIBUTE10,
                                          ATTRIBUTE11,
                                          ATTRIBUTE12,
                                          ATTRIBUTE13,
                                          ATTRIBUTE14,
                                          ATTRIBUTE15,
                                          POSTING_CONTROL_ID,
                                          REQUEST_ID,
                                          PROGRAM_APPLICATION_ID,
                                          PROGRAM_ID,
                                          PROGRAM_UPDATE_DATE,
                                          ACCTD_AMOUNT,
                                          USSGL_TRANSACTION_CODE,
                                          USSGL_TRANSACTION_CODE_CONTEXT,
                                          CREATED_FROM,
                                          REVERSAL_GL_DATE,
                                          ORG_ID,
                                          --BUG#5201086
                                          cash_receipt_history_id)
    VALUES(misc_id,
           last_updated_by,
           last_update_date,
           last_update_login,
           created_by,
           creation_date,
           cash_receipt_id,
           code_combination_id,
           set_of_books_id,
           gl_date,
           percent,
           amount,
           comments,
           gl_posted_date,
           apply_date,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           NULL,
           posting_control_id,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           acctd_amount,
           ussgl_tran_code,
           ussgl_tran_code_context,
           created_from,
           reversal_gl_date,
           arp_standard.sysparm.org_id,
           --BUG5201086
           p_cash_receipt_history_id);


arp_standard.debug('   misc_id:'||misc_id);
arp_standard.debug('ins_misc_cash_distributions -');

    RETURN(misc_id);

END ins_misc_cash_distributions;






PROCEDURE upd_reversal_gl_date(misc_cash_dist_id    NUMBER,
                           rev_gl_date          DATE,
                           p_last_updated_by    NUMBER,
                           p_last_update_date   DATE,
                           p_last_update_login  NUMBER,
                           --BUG5201086
                           p_cash_receipt_history_id    NUMBER   DEFAULT NULL
						   ) IS
BEGIN
arp_standard.debug('upd_reversal_gl_date +');

    UPDATE AR_MISC_CASH_DISTRIBUTIONS
    SET REVERSAL_GL_DATE = rev_gl_date,
	LAST_UPDATED_BY = p_last_updated_by,
	LAST_UPDATE_DATE = p_last_update_date,
	LAST_UPDATE_LOGIN = p_last_update_login,
    cash_receipt_history_id = p_cash_receipt_history_id
    WHERE MISC_CASH_DISTRIBUTION_ID = misc_cash_dist_id;
arp_standard.debug('upd_reversal_gl_date -');

END upd_reversal_gl_date;

END arp_misc_cd;

/
