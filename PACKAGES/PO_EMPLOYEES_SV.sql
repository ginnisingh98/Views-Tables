--------------------------------------------------------
--  DDL for Package PO_EMPLOYEES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_EMPLOYEES_SV" AUTHID CURRENT_USER AS
/*$Header: POXEMEMS.pls 115.4 2002/11/25 23:32:36 sbull ship $*/
/*===========================================================================
  FUNCTION NAME:	get_employee()

  DESCRIPTION:		This procedure checks if the user logged into the
                        application is an employee and returns Employee
                        Information.

  PARAMETERS:

  DESIGN REFERENCES:	POXPOMPO.doc

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	Asarkar created      06/94
                        Siyer   Modified     04/95
                        SIYER   Modified     05/95
===========================================================================*/


FUNCTION GET_EMPLOYEE (emp_id OUT NOCOPY number,
		   emp_name OUT NOCOPY varchar2,
		   location_id OUT NOCOPY number,
		   location_code OUT NOCOPY varchar2,
		   is_buyer OUT NOCOPY BOOLEAN,
                   emp_flag OUT NOCOPY BOOLEAN
		   )
	RETURN BOOLEAN ;

/*===========================================================================
  PROCEDURE NAME:	online_user

  DESCRIPTION:		This procedure determines whether a person is an
			online employee.  It returns TRUE if employee is
			online, and FALSE if employee is offline.

  PARAMETERS:		x_person_id	IN	 NUMBER

  DESIGN REFERENCES:	POXDOAPP.dd

  ALGORITHM:		IF the person's user ID exists in the FND_USER table,
			then the person is an online employee.

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/1	created
===========================================================================*/

  PROCEDURE test_online_user (x_person_id NUMBER);

  FUNCTION online_user (x_person_id NUMBER) RETURN BOOLEAN;


/*===========================================================================
  PROCEDURE NAME:	get_employee_name

  DESCRIPTION:		This procedure returns the employee name for a
			given employee id.

  PARAMETERS:		x_emp_id    IN   NUMBER

  DESIGN REFERENCES:	POXDOAPP.dd

  ALGORITHM:

  NOTES:

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:	cmok	5/17	created
===========================================================================*/

  PROCEDURE test_get_employee_name (x_emp_id   IN NUMBER);

  PROCEDURE get_employee_name (x_emp_id    IN   NUMBER,
			       x_emp_name  OUT NOCOPY  VARCHAR2);


/*===========================================================================
  PROCEDURE NAME:       derive_employee_info()

  DESCRIPTION:		This procedure derives missing information about an
                        employee record based on information that is known
                        about the record.


  PARAMETERS:	        p_emp_record IN OUT RCV_SHIPMENT_OBJECT_SV.Employee_id_record_type

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:                uses dbms_sql to create WHERE clause based on the
                        p_emp_record components that have values.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       10/25/96      Raj Bhakta
===========================================================================*/

 PROCEDURE derive_employee_info(p_emp_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Employee_id_record_type);


/*===========================================================================
  PROCEDURE NAME:       validate_employee_info()

  DESCRIPTION:		This procedure validates information about the employee
                        record and based on certain business rules returns
                        error status and error messages.


  PARAMETERS:	        p_emp_record IN OUT RCV_SHIPMENT_OBJECT_SV.Employee_id_record_type

  DESIGN REFERENCES:

  ALGORITHM:

  NOTES:                uses dbms_sql to create WHERE clause based on the
                        p_emp_record components that have values.

  OPEN ISSUES:

  CLOSED ISSUES:

  CHANGE HISTORY:       10/25/96      Raj Bhakta
===========================================================================*/

 PROCEDURE validate_employee_info(p_emp_record IN OUT NOCOPY RCV_SHIPMENT_OBJECT_SV.Employee_id_record_type);

 FUNCTION get_emp_name(x_person_id IN NUMBER) RETURN VARCHAR2;

END PO_EMPLOYEES_SV;

 

/
