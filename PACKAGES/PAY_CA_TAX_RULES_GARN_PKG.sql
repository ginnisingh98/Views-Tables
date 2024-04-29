--------------------------------------------------------
--  DDL for Package PAY_CA_TAX_RULES_GARN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CA_TAX_RULES_GARN_PKG" AUTHID CURRENT_USER as
/* $Header: pycadiat.pkh 120.1 2005/10/05 22:01:18 saurgupt noship $ */

--
PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
			X_classification_id   NUMBER,
                        X_legislation_code    VARCHAR2,
                        X_taxability_rules_date_id      out nocopy NUMBER,
                        X_valid_date_from       in out nocopy DATE,
                        X_valid_date_to         in out nocopy DATE,
                        X_session_date          DATE,
                        X_BOX1         IN OUT nocopy VARCHAR2,
                        X_BOX2         IN OUT nocopy VARCHAR2);
--
FUNCTION get_classification_id (p_classification_name VARCHAR2,
				p_legislation_code VARCHAR2) RETURN NUMBER;
--
END pay_ca_tax_rules_garn_pkg;

 

/
