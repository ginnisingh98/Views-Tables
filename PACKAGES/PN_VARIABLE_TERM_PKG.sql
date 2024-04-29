--------------------------------------------------------
--  DDL for Package PN_VARIABLE_TERM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VARIABLE_TERM_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVTERMS.pls 120.3 2007/04/17 06:52:35 piagrawa noship $
g_currency_code pn_var_rents_all.currency_code%TYPE;

PROCEDURE create_payment_term_batch(
        errbuf                OUT NOCOPY  VARCHAR2,
        retcode               OUT NOCOPY  VARCHAR2,
        p_lease_num_from      IN  VARCHAR2,
        p_lease_num_to        IN  VARCHAR2,
        p_location_code_from  IN  VARCHAR2,
        p_location_code_to    IN  VARCHAR2,
        p_vrent_num_from      IN  VARCHAR2,
        p_vrent_num_to        IN  VARCHAR2,
        p_period_num_from     IN  NUMBER,
        p_period_num_to       IN  NUMBER,
        p_responsible_user    IN  NUMBER,
        p_period_id           IN  NUMBER,
    p_org_id              IN  NUMBER DEFAULT NULL,
    p_period_date         IN  VARCHAR2 DEFAULT NULL
   );


PROCEDURE create_payment_terms(
         p_lease_id               IN       NUMBER
        ,p_period_id              IN       NUMBER
        ,p_payment_amount         IN       NUMBER
        ,p_invoice_date           IN       DATE
        ,p_var_rent_id            IN       NUMBER
        ,p_var_rent_inv_id        IN       NUMBER
        ,p_location_id            IN       NUMBER
        ,p_var_rent_type          IN       VARCHAR2
        ,p_org_id                 IN       NUMBER
   );

PROCEDURE  get_schedule_status ( p_lease_id IN NUMBER,
                                 p_schedule_date IN DATE,
                                 x_payment_status_lookup_code OUT NOCOPY VARCHAR2) ;

FUNCTION find_volume_continuous (p_var_rent_id IN NUMBER,
                                 p_period_id IN NUMBER,
                                 p_invoice_date IN DATE
                                )
RETURN VARCHAR2;

FUNCTION find_volume_continuous_for (p_var_rent_id IN NUMBER,
                                     p_period_id IN NUMBER,
                                     p_invoice_date IN DATE,
                                     p_rent_type IN VARCHAR2
                                    )
RETURN VARCHAR2;

FUNCTION get_period(p_vr_id IN NUMBER,
                    p_date  IN DATE
                   )
RETURN NUMBER;

FUNCTION get_line(p_prd_id IN NUMBER,
                  p_line_id IN NUMBER
                 )
RETURN NUMBER;

FUNCTION get_inv_date(p_prd_id IN NUMBER,
                      p_date IN DATE
                     )
RETURN DATE ;

PROCEDURE create_reversal_terms(
      p_payment_term_id        IN       NUMBER
     ,p_var_rent_inv_id        IN       NUMBER
     ,p_var_rent_type          IN       VARCHAR2
   );

END pn_variable_term_pkg;



/
