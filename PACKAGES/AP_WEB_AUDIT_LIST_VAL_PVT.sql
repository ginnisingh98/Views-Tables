--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_LIST_VAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_LIST_VAL_PVT" AUTHID CURRENT_USER AS
/* $Header: apwvalvs.pls 120.3 2006/05/04 07:49:30 sbalaji noship $ */

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Employee_Info
 |
 | DESCRIPTION
 |   This procedure validates that a single employee exists for the given
 |   parameter and returns the identifier for the match.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Audit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Employee identifier matching the given parameters.
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN OUT Employee record containg criteria used to find a given employee
 |   x_return_status    OUT   Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Employee_Info(p_emp_rec          IN OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                 x_return_status       OUT NOCOPY VARCHAR2);


/*========================================================================
 | PUBLIC PROCEDUDE Validate_Audit_Info
 |
 | DESCRIPTION
 |   This procedure validates that the audit information used to create
 |   the new record is valid.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Audit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN     Employee record containg criteria used to find a given employee
 |   p_audit_rec     IN OUT Audit record containg information about the record to be created
 |   x_return_status OUT    Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Audit_Info(p_emp_rec          IN             AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                              p_audit_rec        IN  OUT NOCOPY AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                              x_return_status        OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Required_Input
 |
 | DESCRIPTION
 |   This procedure validates that the required parameters are passed to the api.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Audit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec       IN  Employee record containg criteria used to find a given employee
 |   p_audit_rec     IN  Audit record containg information about the record to be created
 |   x_return_status OUT Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Required_Input(p_emp_rec          IN  AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                  p_audit_rec        IN  AP_WEB_AUDIT_LIST_PUB.Audit_Rec_Type,
                                  x_return_status    OUT NOCOPY VARCHAR2);

/*========================================================================
 | PUBLIC PROCEDUDE Validate_Required_Input
 |
 | DESCRIPTION
 |   This procedure validates that the required parameters are passed to the api.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   AP_WEB_AUDIT_LIST_PUB.Deaudit_Employee
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Status whether the validation was succesful or not
 |
 | PARAMETERS
 |   p_emp_rec        IN  Employee record containg criteria used to find a given employee
 |   p_date_range_rec IN  Record containg date range
 |   x_return_status  OUT Status whether the validation was succesful or not
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Jun-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Validate_Required_Input(p_emp_rec          IN  AP_WEB_AUDIT_LIST_PUB.Employee_Rec_Type,
                                  p_date_range_rec   IN  AP_WEB_AUDIT_LIST_PUB.Date_Range_Type,
                                  x_return_status    OUT NOCOPY VARCHAR2);

END AP_WEB_AUDIT_LIST_VAL_PVT;


 

/
