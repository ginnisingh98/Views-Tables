--------------------------------------------------------
--  DDL for Package Body PA_VEND_INV_CHARGE_ACCOUNT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_VEND_INV_CHARGE_ACCOUNT" AS
/* $Header: PAXTMPWB.pls 120.1 2005/08/08 10:51:43 sbharath noship $ */

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
    RETURN BOOLEAN
	-- ========================================================
        -- award_set_id                    IN NUMBER DEFAULT NULL)
	-- ========================================================
    IS

    BEGIN

      fb_flex_seg	:= null;
      fnd_message.set_name('FND','FLEXWK-UPGRADE FUNC MISSING');
      fnd_message.set_token('FUNC', 'PA_VEND_INV_CHARGE_ACCOUNT');
      fb_error_msg	:= fnd_message.get_encoded;
      RETURN FALSE;

    END BUILD;

END PA_VEND_INV_CHARGE_ACCOUNT;

/
