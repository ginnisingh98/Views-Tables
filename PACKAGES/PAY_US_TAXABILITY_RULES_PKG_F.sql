--------------------------------------------------------
--  DDL for Package PAY_US_TAXABILITY_RULES_PKG_F
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAXABILITY_RULES_PKG_F" AUTHID CURRENT_USER as
/* $Header: pydia01t.pkh 120.0 2005/05/29 04:19:09 appldev noship $ */

--
PROCEDURE get_or_update(X_MODE                VARCHAR2,
                        X_CONTEXT             VARCHAR2,
                        X_JURISDICTION        VARCHAR2,
                        X_TAX_CAT             VARCHAR2,
                        X_classification_id   NUMBER,
                        X_BOX1  IN OUT NOCOPY VARCHAR2,
                        X_BOX2  IN OUT NOCOPY VARCHAR2,
                        X_BOX3  IN OUT NOCOPY VARCHAR2);
--
FUNCTION get_classification_id (p_classification_name VARCHAR2) RETURN NUMBER;
--
END pay_us_taxability_rules_pkg_f;

 

/
