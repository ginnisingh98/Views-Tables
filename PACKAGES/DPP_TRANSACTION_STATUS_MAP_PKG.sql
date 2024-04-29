--------------------------------------------------------
--  DDL for Package DPP_TRANSACTION_STATUS_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_TRANSACTION_STATUS_MAP_PKG" AUTHID CURRENT_USER as
/* $Header: dppttsms.pls 120.0.12010000.1 2008/10/30 09:28:54 anbbalas noship $ */

procedure LOAD_ROW (
  p_owner    		IN VARCHAR2,
  P_FROM_STATUS		IN VARCHAR2,
  P_TO_STATUS   	IN VARCHAR2,
  P_ENABLED_FLAG	IN VARCHAR2
  );

end DPP_TRANSACTION_STATUS_MAP_PKG;

/
