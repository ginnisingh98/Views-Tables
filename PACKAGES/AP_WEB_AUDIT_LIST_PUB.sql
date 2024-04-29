--------------------------------------------------------
--  DDL for Package AP_WEB_AUDIT_LIST_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_AUDIT_LIST_PUB" AUTHID CURRENT_USER AS
/* $Header: apwpalas.pls 115.2 2004/07/01 07:47:48 jrautiai noship $ */

TYPE Employee_Rec_Type   IS  RECORD
  (business_group_id   per_all_people_f.business_group_id%TYPE,
   person_id           per_all_people_f.person_id%TYPE,
   employee_number     per_all_people_f.employee_number%TYPE,
   national_identifier per_all_people_f.national_identifier%TYPE,
   email_address       per_all_people_f.email_address%TYPE
  );

TYPE Audit_Rec_Type   IS  RECORD
  (audit_reason_code   ap_aud_auto_audits.audit_reason_code%TYPE,
   start_date          DATE,
   end_date            DATE
  );

TYPE Date_Range_Type   IS  RECORD
  (start_date          DATE,
   end_date            DATE
  );

/*========================================================================
 | PUBLIC PROCEDUDE Audit_Employee
 |
 | DESCRIPTION
 |   This procedure adds a employee to the Internet Expenses automated
 |   audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Public API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Standard API parameters
 |
 | PARAMETERS
 |   p_api_version      IN  Standard API paramater
 |   p_init_msg_list    IN  Standard API paramater
 |   p_commit           IN  Standard API paramater
 |   p_validation_level IN  Standard API paramater
 |   x_return_status    OUT Standard API paramater
 |   x_msg_count        OUT Standard API paramater
 |   x_msg_data         OUT Standard API paramater
 |   p_emp_rec          IN  Employee record containg criteria used to find a given employee
 |   p_audit_rec        IN  Audit record containg information about the record to be created
 |   x_auto_audit_id    OUT Identifier of the new record created, if multiple created returns -1.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 05-Dec-2002           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Audit_Employee(p_api_version      IN  NUMBER,
                         p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                         p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                         p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                         x_return_status    OUT NOCOPY VARCHAR2,
                         x_msg_count        OUT NOCOPY NUMBER,
                         x_msg_data         OUT NOCOPY VARCHAR2,
                         p_emp_rec          IN  Employee_Rec_Type,
                         p_audit_rec        IN  Audit_Rec_Type,
                         x_auto_audit_id    OUT NOCOPY NUMBER);

/*========================================================================
 | PUBLIC PROCEDUDE Deaudit_Employee
 |
 | DESCRIPTION
 |   This procedure removes a employee from the Internet Expenses automated
 |   audit list.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Public API
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |   Standard API parameters
 |
 | PARAMETERS
 |   p_api_version      IN  Standard API paramater
 |   p_init_msg_list    IN  Standard API paramater
 |   p_commit           IN  Standard API paramater
 |   p_validation_level IN  Standard API paramater
 |   x_return_status    OUT Standard API paramater
 |   x_msg_count        OUT Standard API paramater
 |   x_msg_data         OUT Standard API paramater
 |   p_emp_rec          IN  Employee record containg criteria used to find a given employee
 |   p_date_range_rec   IN  Record containg date range
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 29-Jun-2004           J Rautiainen      Created
 |
 *=======================================================================*/
PROCEDURE Deaudit_Employee(p_api_version      IN  NUMBER,
                           p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
                           p_commit           IN  VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                           x_return_status    OUT NOCOPY VARCHAR2,
                           x_msg_count        OUT NOCOPY NUMBER,
                           x_msg_data         OUT NOCOPY VARCHAR2,
                           p_emp_rec          IN  Employee_Rec_Type,
                           p_date_range_rec   IN  Date_Range_Type);

END AP_WEB_AUDIT_LIST_PUB;


 

/
