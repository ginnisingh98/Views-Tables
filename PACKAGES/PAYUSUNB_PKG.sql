--------------------------------------------------------
--  DDL for Package PAYUSUNB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAYUSUNB_PKG" AUTHID CURRENT_USER as
/* $Header: payusunb.pkh 120.0.12010000.1 2008/07/27 21:56:38 appldev ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1999 Oracle Corporation Ltd.,                   *
   *                   Redwood Shores, California.                  *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation Ltd,     *
   *  Redwood Shores, California, USA.                              *
   *                                                                *
   *                                                                *
   ******************************************************************
   Change List
   -----------
   Date         Name        Vers   Bug No   Description
   -----------  ----------  -----  -------  -----------------------------------
   29-SEP-1999  mcpham      110.0           Created.
   26-NOV-2001  meshah      115.1           added dbdrv command.
   06-DEC-2002  tclewis     115.2           added NOCOPY directive.
   25-JUN-2003	vinaraya    115.4           Changed the prc_process_data
                                            procedure declaration.
   30-JUN-2003  vinaraya    115.5  2963239  Removed the function
                                            fnc_get_ptd_start_dt and pragma
					    restrict references.
--
*/
PROCEDURE range_cursor ( IN_pactid IN  NUMBER,
                         OUT_sqlstr OUT NOCOPY VARCHAR2
                       );
PROCEDURE action_creation ( IN_pactid    IN NUMBER,
                            IN_stperson  IN NUMBER,
                            IN_endperson IN NUMBER,
                            IN_chunk     IN NUMBER
                          );
PROCEDURE sort_action ( IN_payactid   IN     VARCHAR2,
                        IO_sqlstr     IN OUT NOCOPY VARCHAR2,
                        OUT_len       OUT    NOCOPY NUMBER
                      );
FUNCTION fnc_get_parameter(IN_name           IN VARCHAR2,
                           IN_parameter_list IN VARCHAR2) RETURN VARCHAR2;
PROCEDURE prc_process_data( IN_pact_id			 IN pay_payroll_actions.payroll_action_id%TYPE,
                            IN_chunk_no			 IN NUMBER,
                            IN_commit_count		 IN NUMBER DEFAULT 1000,
			    IN_prc_lockingactid		 IN pay_assignment_actions.assignment_action_id%TYPE,
		            IN_prc_lockedactid		 IN pay_assignment_actions.assignment_action_id%TYPE,
	                    IN_prc_assignment_id	 IN pay_assignment_actions.assignment_id%TYPE,
	                    IN_prc_tax_unit_id		 IN pay_assignment_actions.tax_unit_id%TYPE,
	                    IN_prc_person_id		 IN per_all_assignments_f.person_id%TYPE,
	                    IN_prc_location_id		 IN per_all_assignments_f.location_id%TYPE,
	                    IN_prc_organization_id	 IN per_all_assignments_f.organization_id%TYPE,
	                    IN_prc_assignment_number	 IN per_all_assignments_f.assignment_number%TYPE );
--
END PAYUSUNB_PKG;

/
