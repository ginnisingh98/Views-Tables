--------------------------------------------------------
--  DDL for Package PSA_XFR_TO_GL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSA_XFR_TO_GL_PKG" AUTHID CURRENT_USER AS
/* $Header: PSAMFG2S.pls 120.2 2006/09/15 10:59:49 agovil noship $*/

 PROCEDURE Transfer_to_gl  (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_parent_req_id      IN  NUMBER,
                            p_summary_flag       IN  VARCHAR2,
                            p_pst_ctrl_id        IN  NUMBER);

 PROCEDURE Mfar_trx_to_gl  (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_summary_flag       IN  VARCHAR2);

 PROCEDURE Mfar_rcpt_to_gl (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_summary_flag       IN  VARCHAR2);

 PROCEDURE Mfar_adj_to_gl  (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_summary_flag       IN  VARCHAR2);

  PROCEDURE Misc_rct_to_gl (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2);

 PROCEDURE Populate_global_variables;

 PROCEDURE Upd_seg_in_gl_interface ;

 -- Bug 3621280
 PROCEDURE Reverse_core_entries_if_any (errbuf               OUT NOCOPY VARCHAR2,
                                        retcode              OUT NOCOPY VARCHAR2,
                                        p_set_of_books_id    IN  NUMBER,
                                        p_error_message      OUT NOCOPY VARCHAR2);


 FUNCTION Get_entered_dr_rct (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER,
                              p_discount    IN NUMBER  DEFAULT NULL,
                              p_ue_discount IN NUMBER  DEFAULT NULL) RETURN NUMBER;

 FUNCTION Get_entered_cr_rct (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER,
                              p_discount    IN NUMBER  DEFAULT NULL,
                              p_ue_discount IN NUMBER  DEFAULT NULL)  RETURN NUMBER;

 FUNCTION Get_entered_cr_crm (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER) RETURN NUMBER;

 FUNCTION Get_entered_dr_crm (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER) RETURN NUMBER;

 FUNCTION get_entered_dr_adj (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER) RETURN NUMBER;

 FUNCTION Get_entered_cr_adj (p_lookup_code IN NUMBER,
                              p_amount      IN NUMBER) RETURN NUMBER;

 FUNCTION Get_adj_ccid (p_adjustment_id IN NUMBER) RETURN NUMBER;


 FUNCTION Get_entered_dr_rct_clear (p_lookup_code IN NUMBER,
                                    p_amount      IN NUMBER,
                                    p_curr_status IN VARCHAR2,
                                    p_prev_status IN VARCHAR2) RETURN NUMBER;

 FUNCTION Get_entered_cr_rct_clear (p_lookup_code IN NUMBER,
                                    p_amount      IN NUMBER,
                                    p_curr_status IN VARCHAR2,
                                    p_prev_status IN VARCHAR2) RETURN NUMBER;

  FUNCTION clear_reversal_lines(p_lookup_code IN NUMBER,
                               p_amount IN NUMBER,
                               p_crh_status IN VARCHAR2,
                               p_crh_first_record_flag IN VARCHAR2,
                               p_rev_crh_id IN NUMBER) RETURN varchar2 ;


 FUNCTION Get_misc_ard_id (p_misc_cash_dist_id IN NUMBER) RETURN NUMBER;

 FUNCTION Get_adj_ard_id (p_adjustment_id IN NUMBER) RETURN NUMBER;

 PROCEDURE Mfar_rcpt_to_gl_CB
			   (errbuf               OUT NOCOPY VARCHAR2,
                            retcode              OUT NOCOPY VARCHAR2,
                            p_set_of_books_id    IN  NUMBER,
                            p_gl_date_from       IN  VARCHAR2,
                            p_gl_date_to         IN  VARCHAR2,
                            p_gl_posted_date     IN  VARCHAR2,
                            p_summary_flag       IN  VARCHAR2);

 PROCEDURE Misc_rct_to_gl_CB
			  (errbuf               OUT NOCOPY VARCHAR2,
                           retcode              OUT NOCOPY VARCHAR2,
                           p_set_of_books_id    IN  NUMBER,
                           p_gl_date_from       IN  VARCHAR2,
                           p_gl_date_to         IN  VARCHAR2,
                           p_gl_posted_date     IN  VARCHAR2);

END PSA_xfr_to_gl_pkg ;

 

/
