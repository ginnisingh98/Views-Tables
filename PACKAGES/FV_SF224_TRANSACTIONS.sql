--------------------------------------------------------
--  DDL for Package FV_SF224_TRANSACTIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_SF224_TRANSACTIONS" AUTHID CURRENT_USER AS
/* $Header: FVSF224S.pls 120.5.12010000.1 2008/07/28 06:32:02 appldev ship $  */

    PROCEDURE main (  p_errbuf        OUT NOCOPY VARCHAR2,
                      p_retcode       OUT NOCOPY NUMBER,
                      p_set_of_books_id       IN NUMBER,
                      p_gl_period             IN VARCHAR2,
                      p_run_mode              IN VARCHAR2,
                      p_partial_or_full       IN VARCHAR2,
                      p_business_activity     IN VARCHAR2,
                      p_gwa_reporter_category IN VARCHAR2,
                      p_alc                   IN  VARCHAR2);

    PROCEDURE extract   (    p_errbuf  OUT NOCOPY VARCHAR2,
                             p_retcode OUT NOCOPY NUMBER,
                             p_set_of_books_id IN NUMBER);


  PROCEDURE fv_ap_refund_populate
  (
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY NUMBER,
    p_set_of_books_id IN  NUMBER,
    p_org_id          IN  NUMBER,
    P_gl_period_low   IN  VARCHAR2,
    p_gl_period_high  IN  VARCHAR2
  );
END fv_sf224_transactions;

/
