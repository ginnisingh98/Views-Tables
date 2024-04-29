--------------------------------------------------------
--  DDL for Package JL_BR_SPED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_SPED_PKG" AUTHID CURRENT_USER AS
/* $Header: jlspedas.pls 120.1.12010000.2 2008/11/13 08:03:57 pakumare noship $ */

---------------------------------------------------------------------------
--   PUBLIC FUNCTIONS/PROCEDURES                                         --
---------------------------------------------------------------------------
   FUNCTION IS_INVOICE_FINAL
                  (p_customer_trx_id IN  NUMBER) RETURN VARCHAR2;

   FUNCTION COPY_GDF_ATTRIBUTES
                  (p_request_id IN NUMBER,
                   p_called_from IN VARCHAR2) RETURN NUMBER;

   FUNCTION COPY_GDF_ATTRIBUTES_API
                  (p_customer_trx_id IN NUMBER) RETURN NUMBER;

   FUNCTION CREATE_VOID_CM
                  (p_inv_customer_trx_id IN NUMBER,
                   p_trx_type_id IN NUMBER,
                   p_CM_amount IN NUMBER) RETURN NUMBER;

   PROCEDURE SET_TRX_LOCK_STATUS
                  (p_customer_trx_id IN NUMBER);

END JL_BR_SPED_PKG;



/
