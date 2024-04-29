--------------------------------------------------------
--  DDL for Package AP_SLA_PROCESSING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_SLA_PROCESSING_PKG" AUTHID CURRENT_USER AS
/* $Header: apslapps.pls 120.5 2006/07/19 19:02:47 hredredd noship $ */

PROCEDURE preaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
);

PROCEDURE extract
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
);


PROCEDURE postprocessing
(
  p_application_id               IN            NUMBER,
  p_accounting_mode              IN            VARCHAR2
);

PROCEDURE postaccounting
(
  p_application_id               IN            NUMBER,
  p_ledger_id                    IN            INTEGER,
  p_process_category             IN            VARCHAR2,
  p_end_date                     IN            DATE,
  p_accounting_mode              IN            VARCHAR2,
  p_valuation_method             IN            VARCHAR2,
  p_security_id_int_1            IN            INTEGER,
  p_security_id_int_2            IN            INTEGER,
  p_security_id_int_3            IN            INTEGER,
  p_security_id_char_1           IN            VARCHAR2,
  p_security_id_char_2           IN            VARCHAR2,
  p_security_id_char_3           IN            VARCHAR2,
  p_report_request_id            IN            INTEGER
);

FUNCTION Derive_Cash_Posted_Flag
 (P_event_id          IN      NUMBER
 ,P_distribution_id   IN      NUMBER
 ,P_dist_amount       IN      NUMBER
 ,P_calling_sequence  IN      VARCHAR2
) RETURN VARCHAR2;


FUNCTION Get_Amt_Already_Accounted
 (P_event_id                  IN    NUMBER
 ,P_invoice_payment_id        IN    NUMBER
 ,P_invoice_distribution_id   IN    NUMBER
 ,P_calling_sequence          IN    VARCHAR2
) RETURN NUMBER;

END ap_sla_processing_pkg;

 

/
