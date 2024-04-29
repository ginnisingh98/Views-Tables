--------------------------------------------------------
--  DDL for Package Body PAGTCX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAGTCX" AS
/* $Header: PAXTGTCB.pls 120.1 2005/08/09 04:53:54 avajain noship $ */

  PROCEDURE  Summary_Validation_Extension (
	       P_Timecard_Table         IN Pa_Otc_Api.Timecard_Table DEFAULT PAGTCX.dummy
	    ,  P_Module                 IN VARCHAR2 DEFAULT NULL
            ,  X_expenditure_id         IN NUMBER DEFAULT NULL
            ,  X_incurred_by_person_id  IN NUMBER
            ,  X_expenditure_end_date   IN DATE
            ,  X_exp_class_code         IN VARCHAR2
            ,  X_status                 OUT NOCOPY VARCHAR2
            ,  X_comment                OUT NOCOPY VARCHAR2
            ,  P_Action_Code            IN VARCHAR2 DEFAULT NULL ) /* Added for Bug#3036106 */
  IS

  BEGIN
    X_status  := 'APPROVED';    -- Initialize output parameter
    X_comment := NULL;          -- Initialize output parameter

    -- Add your summary-level validation logic here

  EXCEPTION

    -- Add your exception handling logic here

    WHEN  OTHERS  THEN
      NULL;

  END  summary_validation_extension;

END PAGTCX;

/
