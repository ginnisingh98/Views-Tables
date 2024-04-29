--------------------------------------------------------
--  DDL for Package FV_ECON_BENF_DISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_ECON_BENF_DISC_PVT" AUTHID CURRENT_USER AS
-- $Header: FVAPEBDS.pls 120.2 2005/11/30 05:20:51 bnarang ship $
   FUNCTION EBD_CHECK(x_batch_name IN VARCHAR2,
                   x_invoice_id IN NUMBER,
                   x_check_date IN DATE,
                   x_inv_due_date IN DATE,
                   x_discount_amount IN NUMBER,
                   x_discount_date IN DATE) RETURN CHAR;
END FV_ECON_BENF_DISC_PVT;

 

/
