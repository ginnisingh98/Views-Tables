--------------------------------------------------------
--  DDL for Package GMS_EVT_BILLING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_EVT_BILLING" AUTHID CURRENT_USER AS
-- $Header: gmsinmas.pls 120.1 2005/07/26 14:37:56 appldev ship $

PROCEDURE MANUAL_BILLING( X_project_id IN NUMBER,
                                X_top_Task_id IN NUMBER DEFAULT NULL,
                                X_calling_process IN VARCHAR2 DEFAULT NULL,
                                X_calling_place IN VARCHAR2 DEFAULT NULL,
                                X_amount IN NUMBER DEFAULT NULL,
                                X_percentage IN NUMBER DEFAULT NULL,
                                X_rev_or_bill_date IN DATE DEFAULT NULL,
                                X_bill_extn_assignment_id IN NUMBER DEFAULT NULL,
                                X_bill_extension_id IN NUMBER DEFAULT NULL,
                                X_request_id IN NUMBER DEFAULT NULL);
End GMS_EVT_BILLING;

 

/
