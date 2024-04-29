--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CHANGE_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CHANGE_LOG_PKG" AS
/* $Header: ISCCHGLB.pls 120.2 2005/08/19 11:14:20 kxliu noship $ */

  ---------------------
  --  PUBLIC PROCEDURES
  ---------------------

PROCEDURE Update_Del_Detail_Log(p_detail_list		IN LOG_TAB_TYPE,
                                p_dml_type		IN VARCHAR2,
				x_return_status		OUT NOCOPY VARCHAR2) IS
BEGIN

  FORALL i IN p_detail_list.FIRST..p_detail_list.LAST
     INSERT INTO isc_dbi_wdd_change_log (
        DELIVERY_DETAIL_ID,
        DML_TYPE,
        LAST_UPDATE_DATE)
     VALUES (p_detail_list(i), p_dml_type, sysdate);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Del_Detail_Log;

PROCEDURE Update_Trip_Stop_Log(p_stop_list		IN LOG_TAB_TYPE,
                               p_dml_type		IN VARCHAR2,
			       x_return_status		OUT NOCOPY VARCHAR2) IS
BEGIN

  FORALL i IN p_stop_list.FIRST..p_stop_list.LAST
     INSERT INTO isc_dbi_wts_change_log (
        STOP_ID,
        DML_TYPE,
        LAST_UPDATE_DATE)
     VALUES (p_stop_list(i), p_dml_type, sysdate);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Trip_Stop_Log;

PROCEDURE Update_Fte_Invoice_Log (p_invoice_list	IN LOG_TAB_TYPE,
				  p_dml_type		IN VARCHAR2,
				  x_return_status	OUT NOCOPY VARCHAR2) IS
BEGIN

  FORALL i IN p_invoice_list.FIRST..p_invoice_list.LAST
     INSERT INTO isc_dbi_fih_change_log (
        INVOICE_HEADER_ID,
        DML_TYPE,
        LAST_UPDATE_DATE)
     VALUES (p_invoice_list(i), p_dml_type, sysdate);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Update_Fte_Invoice_Log;

END ISC_DBI_CHANGE_LOG_PKG;

/
