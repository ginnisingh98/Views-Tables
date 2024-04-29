--------------------------------------------------------
--  DDL for Package QP_PRICE_REQUEST_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_PRICE_REQUEST_CONTEXT" AUTHID CURRENT_USER as
/* $Header: QPXVPRES.pls 120.0 2005/06/02 00:44:21 appldev noship $ */

/* function to set request id */
PROCEDURE Set_Request_Id ;

/* function to get current request id */
FUNCTION Get_Request_Id
return number;

--needed for HTML Qualifiers UI
--return transaction_id attribute under namespace 'qp_context'
FUNCTION get_transaction_id RETURN NUMBER;

-- set transaction_id attribute under namespace 'qp_context'
PROCEDURE set_transaction_id(p_transaction_id IN NUMBER);
--needed for HTML Qualifiers UI

/* function to release Pricing Lock after Calling Application is done
  with reading from the Interface Tables
  This API is going to be picked up by Integration Team as the last step of
  Pricing Engine call */
FUNCTION Release_Pricing_Lock
return integer;

END QP_Price_Request_Context;

 

/
