--------------------------------------------------------
--  DDL for Package ARP_MISC_CD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARP_MISC_CD" AUTHID CURRENT_USER AS
/* $Header: ARPLMCDS.pls 120.3 2006/06/09 16:22:38 hyu ship $ */

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
          RETURN NUMBER;

PROCEDURE upd_reversal_gl_date(misc_cash_dist_id      NUMBER,
                               rev_gl_date            DATE,
                               p_last_updated_by      NUMBER,
                               p_last_update_date     DATE,
                               p_last_update_login    NUMBER,
                               --BUG#5201086
                               p_cash_receipt_history_id    NUMBER   DEFAULT NULL);

END arp_misc_cd;

 

/
