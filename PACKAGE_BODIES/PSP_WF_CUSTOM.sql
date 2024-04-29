--------------------------------------------------------
--  DDL for Package Body PSP_WF_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSP_WF_CUSTOM" AS
/* $Header: PSPWFCTB.pls 115.6 2002/11/18 13:25:03 ddubey ship $ */

/*************************************************************************
**Procedure EFFORT_SELECT_CERTIFIER returns the certifier's person_id   **
**for the given employee. It is called from                             **
**PSP_WF_EFF_PKG.SELECT_CERTIFIER.                                      **
**INPUT: an employee's person ID					**
**OUTPUT: return the certifier's person ID				**
**************************************************************************/
PROCEDURE effort_select_certifier(emp_id 	 IN   NUMBER,
                                  certifier_id   OUT NOCOPY  NUMBER)
IS
BEGIN
--insert your customization code here
--emp_id is passed in, return the certifier's person_id for the employee
   NULL;
END effort_select_certifier;

/*************************************************************************
**Procedure EFFORT_SELECT_APPROVER returns the approver's person_id for **
**the given employee. It is called from PSP_WF_EFF_PKG.SELECT_APPROVER. **
**INPUT: an employe's person ID						**
**OUTPUT: return the approver's person ID 				**
**************************************************************************/
PROCEDURE effort_select_approver(emp_id	        IN	NUMBER,
			         approver_id	OUT NOCOPY	NUMBER)
IS
BEGIN
--insert your customization code here
--emp_id is passed, return the approver's person_id
   NULL;
END effort_select_approver;


END psp_wf_custom;


/
