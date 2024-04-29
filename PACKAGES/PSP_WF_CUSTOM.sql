--------------------------------------------------------
--  DDL for Package PSP_WF_CUSTOM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_WF_CUSTOM" AUTHID CURRENT_USER AS
/* $Header: PSPWFCTS.pls 115.5 2002/11/18 13:24:17 ddubey ship $ */

/*************************************************************************
**Procedure EFFORT_SELECT_CERTIFIER returns the certifier's person_id   **
**for the given employee. It is called from                             **
**PSP_WF_EFF_PKG.SELECT_CERTIFIER.                                      **
**************************************************************************/
PROCEDURE effort_select_certifier(emp_id 	 IN   NUMBER,
                                  certifier_id   OUT NOCOPY  NUMBER);

/*************************************************************************
**Procedure EFFORT_SELECT_APPROVER returns the approver's person_id for **
**the given employee. It is called from PSP_WF_EFF_PKG.SELECT_APPROVER. **
**************************************************************************/
PROCEDURE effort_select_approver(emp_id	        IN   NUMBER,
			         approver_id	OUT NOCOPY  NUMBER);

END psp_wf_custom;


 

/
