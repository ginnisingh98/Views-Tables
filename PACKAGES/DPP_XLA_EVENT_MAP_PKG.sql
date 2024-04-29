--------------------------------------------------------
--  DDL for Package DPP_XLA_EVENT_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_XLA_EVENT_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: dpptxems.pls 120.0.12010000.1 2008/10/30 09:29:12 anbbalas noship $ */

procedure LOAD_ROW (
  p_owner                	IN VARCHAR2,
  P_PP_TRANSACTION_TYPE 	IN VARCHAR2,
  P_ENTITY_CODE 		IN VARCHAR2,
  P_EVENT_CLASS_CODE 		IN VARCHAR2,
  P_EVENT_TYPE_CODE 		IN VARCHAR2
  );

end DPP_XLA_EVENT_MAP_PKG;

/
