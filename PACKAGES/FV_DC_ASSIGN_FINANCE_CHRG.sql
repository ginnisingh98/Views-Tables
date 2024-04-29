--------------------------------------------------------
--  DDL for Package FV_DC_ASSIGN_FINANCE_CHRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_DC_ASSIGN_FINANCE_CHRG" AUTHID CURRENT_USER as
-- $Header: FVDCAAFS.pls 120.7.12010000.3 2009/03/19 19:05:19 sasukuma ship $
  PROCEDURE accrue_finance_charge
  (
    p_errbuf        OUT NOCOPY VARCHAR2,
    p_retcode       OUT NOCOPY NUMBER,
    p_invoice_date_type  VARCHAR2,
    p_gl_date       VARCHAR2
  );

  PROCEDURE assign_finance_charge
  (
    p_errbuf  OUT NOCOPY VARCHAR2,
    p_retcode OUT NOCOPY NUMBER
  );
END;

/
