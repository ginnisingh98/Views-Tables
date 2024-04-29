--------------------------------------------------------
--  DDL for Package AR_CC_ERROR_MAPPINGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_CC_ERROR_MAPPINGS_PKG" AUTHID CURRENT_USER AS
/* $Header: ARCCMAPS.pls 120.0 2005/03/22 22:35:49 jypandey noship $ */

PROCEDURE Check_Unique(p_rowid IN ROWID,p_cc_error_code IN VARCHAR2,p_cc_trx_category IN VARCHAR2,p_receipt_method_id IN NUMBER);

PROCEDURE Insert_Row(x_rowid OUT NOCOPY ROWID,
                     p_cc_error_code IN VARCHAR2,
                     p_cc_error_text IN VARCHAR2,
                     p_receipt_method_id IN NUMBER,
		     p_cc_trx_category IN VARCHAR2,
                     p_cc_action_code IN VARCHAR2,
                     p_no_days IN NUMBER,
                     p_subsequent_action_code IN VARCHAR2,
                     p_error_notes IN VARCHAR2,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
                     p_creation_date IN DATE,
                     p_created_by IN NUMBER,
                     x_object_version_number OUT NOCOPY NUMBER);

PROCEDURE Update_Row(p_rowid IN ROWID,
                     p_cc_error_code IN VARCHAR2,
                     p_cc_error_text IN VARCHAR2,
                     p_receipt_method_id IN NUMBER,
		     p_cc_trx_category IN VARCHAR2,
                     p_cc_action_code IN VARCHAR2,
                     p_no_days IN NUMBER,
                     p_subsequent_action_code IN VARCHAR2,
                     p_error_notes IN VARCHAR2,
                     p_last_update_date IN DATE,
                     p_last_updated_by IN NUMBER,
                     p_last_update_login IN NUMBER,
		     x_object_version_number OUT NOCOPY NUMBER);

PROCEDURE Delete_Row(p_rowid IN ROWID);

PROCEDURE Lock_Row(p_rowid IN ROWID,
                   p_object_version_number IN NUMBER);

END AR_CC_ERROR_MAPPINGS_PKG ;

 

/
