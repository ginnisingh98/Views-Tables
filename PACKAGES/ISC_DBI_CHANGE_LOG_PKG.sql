--------------------------------------------------------
--  DDL for Package ISC_DBI_CHANGE_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ISC_DBI_CHANGE_LOG_PKG" AUTHID CURRENT_USER AS
/* $Header: ISCCHGLS.pls 120.0 2005/05/25 17:29:30 appldev noship $ */

  ----------------
  --  PUBLIC TYPES
  ----------------

  TYPE log_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  -----------------------------------------------------------
  --  PUBLIC PROCEDURES
  --
  --  P_DML_TYPE can be 'DELETE, 'INSERT' or 'UPDATE'
  --
  --  X_RETURN_STATUS will return one of the following values
  -- 	Success: FND_API.G_RET_STS_SUCCESS
  --    Error  : FND_API.G_RET_STS_ERROR
  --    Unexpected error: FND_API.G_RET_STS_UNEXP_ERROR
  -----------------------------------------------------------

  PROCEDURE Update_Del_Detail_Log(	p_detail_list		IN LOG_TAB_TYPE,
					p_dml_type		IN VARCHAR2,
					x_return_status		OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Trip_Stop_Log(	p_stop_list		IN LOG_TAB_TYPE,
					p_dml_type		IN VARCHAR2,
					x_return_status		OUT NOCOPY VARCHAR2);

  PROCEDURE Update_Fte_Invoice_Log (	p_invoice_list		IN LOG_TAB_TYPE,
					p_dml_type		IN VARCHAR2,
					x_return_status		OUT NOCOPY VARCHAR2);


END ISC_DBI_CHANGE_LOG_PKG;

 

/
