--------------------------------------------------------
--  DDL for Package PA_VEND_INV_CHARGE_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_VEND_INV_CHARGE_ACCOUNT" AUTHID CURRENT_USER AS
/* $Header: PAXTMPWS.pls 120.1 2005/08/08 10:51:11 sbharath noship $ */
    FUNCTION BUILD (
        fb_flex_num 			IN NUMBER DEFAULT 101,
        expenditure_organization_id 	IN VARCHAR2 DEFAULT NULL,
        expenditure_type 		IN VARCHAR2 DEFAULT NULL,
        pa_billable_flag 		IN VARCHAR2 DEFAULT NULL,
        project_id 			IN VARCHAR2 DEFAULT NULL,
        task_id 			IN VARCHAR2 DEFAULT NULL,
        vendor_id 			IN VARCHAR2 DEFAULT NULL,
        fb_flex_seg 			IN OUT NOCOPY VARCHAR2,
        fb_error_msg 			IN OUT NOCOPY VARCHAR2)
        RETURN BOOLEAN;

	-- ==========================================================
        -- award_set_id                    IN NUMBER DEFAULT NULL)
	-- ==========================================================

END PA_VEND_INV_CHARGE_ACCOUNT;

 

/
