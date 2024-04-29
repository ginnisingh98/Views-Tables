--------------------------------------------------------
--  DDL for Package ZX_USER_EXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZX_USER_EXT_PKG" AUTHID CURRENT_USER AS
/* $Header: zxifusextintpkgs.pls 120.5 2005/12/08 21:57:54 appradha ship $ */
/* ======================================================================*
 | Global Data Types                                                     |
 * ======================================================================*/



/* ======================================================================*
 | Global Structure Data Types                                           |
 * ======================================================================*/

 TYPE extensible_attrs_rec_type IS RECORD (
 BUSINESS_FLOW                 VARCHAR2(30),
 COUNTRY_CODE                  VARCHAR2(30),
 TRANSACTION_SERVICE_TYPE      VARCHAR2(30),
 DERIVATION_LEVEL              VARCHAR2(30),
 TRANSACTION_ID                NUMBER,
 EVENT_ID                      NUMBER
 );

PROCEDURE invoke_third_party_interface (
  p_api_owner_id       IN NUMBER,
  p_service_type_id    IN NUMBER,
  p_context_ccid       IN NUMBER,
  p_data_transfer_mode IN VARCHAR2,
  x_return_status      OUT NOCOPY VARCHAR2
  );

END ZX_USER_EXT_PKG;

 

/
