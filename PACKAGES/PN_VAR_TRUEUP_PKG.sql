--------------------------------------------------------
--  DDL for Package PN_VAR_TRUEUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PN_VAR_TRUEUP_PKG" AUTHID CURRENT_USER AS
-- $Header: PNVRTRPS.pls 120.0 2007/10/03 14:29:57 rthumma noship $

/**Global variables*/

TYPE ALLOW_REC is RECORD(
     rolling_allow  NUMBER,
     allow_applied  NUMBER,
     start_date     DATE,
     end_date       DATE,
     abatement_id NUMBER
    );
TYPE ALLOW_TBL is TABLE of ALLOW_REC INDEX BY BINARY_INTEGER;

FUNCTION can_do_trueup( p_var_rent_id IN NUMBER
                       ,p_period_id   IN NUMBER)
RETURN BOOLEAN;

PROCEDURE post_summary_trueup ( p_var_rent_id IN NUMBER
                               ,p_period_id   IN NUMBER
			       ,p_proration_rule IN VARCHAR2);

PROCEDURE insert_invoice_trueup ( p_var_rent_id IN NUMBER
                                 ,p_period_id   IN NUMBER);
/*Procedures to calculate true up abatements*/
PROCEDURE apply_abatements(p_var_rent_id NUMBER,
                 p_period_id IN NUMBER,
                 p_flag IN VARCHAR2);
PROCEDURE apply_allow(p_var_rent_id IN NUMBER,
               p_period_id IN NUMBER,
               p_inv_id IN NUMBER,
	       p_allow_t IN ALLOW_TBL,
	       p_allow_tu_t IN ALLOW_TBL,
               x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE apply_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER,
           x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE populate_abat(p_var_rent_id IN NUMBER,
           p_period_id IN NUMBER,
           p_inv_id IN NUMBER);
PROCEDURE reset_abatements(p_var_rent_id IN NUMBER
          );
FUNCTION get_dated_allow(p_allow_t ALLOW_TBL,
                         p_start_date DATE,
			 p_end_date DATE) RETURN ALLOW_TBL;
PROCEDURE populate_neg_rent(p_var_rent_id IN NUMBER,
                p_period_id IN NUMBER
               ,p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE apply_def_neg_rent(p_var_rent_id IN NUMBER,
               p_period_id IN NUMBER,
               p_inv_id IN NUMBER,
               x_abated_rent IN OUT NOCOPY NUMBER);
PROCEDURE calculate_trueup( p_var_rent_id IN NUMBER
                           ,p_prd_date    IN DATE);

PROCEDURE trueup_batch_process( errbuf           OUT NOCOPY VARCHAR2
                               ,retcode          OUT NOCOPY VARCHAR2
                               ,p_property_code  IN VARCHAR2
                               ,p_lease_num_low  IN VARCHAR2
                               ,p_lease_num_high IN VARCHAR2
                               ,p_vr_num_low     IN VARCHAR2
                               ,p_vr_num_high    IN VARCHAR2
                               ,p_date           IN VARCHAR2);

PROCEDURE set_trueup_flag(l_flag VARCHAR2);

END PN_VAR_TRUEUP_PKG;

/
