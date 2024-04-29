--------------------------------------------------------
--  DDL for Package PAY_MAG_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_MAG_UTILS" AUTHID CURRENT_USER AS
/* $Header: pymagutl.pkh 120.1 2005/10/10 12:03:04 meshah noship $ */
--
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1993 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_mag_utils

    Description : Contains procedures and functions used by magnetic reports.

    Uses        :

    Change List
    -----------
    Date        Name     Vers    Bug No     Description
    ----        ----     ----    ------     -----------
    10-OCT-96   ATAYLOR  40.0               Created.
    01-NOV-96   GPERRY   40.1               Added Insert Lookups procedure and
					    Write procedure to support simple
                                            debugging of 1099R reports.
    06-NOV-96   GPERRY   40.2               Added function date_earned.
    12-NOV-96   HEKIM    40.3               Added function org_info_exists.
    20-MAR-97   HEKIM    40.4               Added udf_Exists and Delete_udf.
    11-SEP-97   MFENDER  110.1              Fixed untranslatable dates.
    17-AUG-99   rthakur  115.2              Added function get_parameter.
    18-jan-2002 fusman   115.5              Added dbdrv commands.

*/
--
	g_message	VARCHAR2(240);
--
--
FUNCTION Lookup_Formula 	( p_session_date      IN DATE,
			  	  p_business_group_id IN NUMBER,
			  	  p_legislation_code  IN VARCHAR2,
			  	  p_formula_name      IN VARCHAR2 ) RETURN NUMBER;
--
--
FUNCTION Lookup_Format 		( p_period_end        IN DATE,
				  p_report_type       IN VARCHAR2,
				  p_state             IN VARCHAR2 ) RETURN VARCHAR2;
--
--
FUNCTION Bal_db_Item 		( p_db_item_name      IN VARCHAR2 ) RETURN NUMBER;
--
--
FUNCTION Lookup_Jurisdiction_Code
				( p_state	      IN VARCHAR2 ) RETURN VARCHAR2;
--
--
PROCEDURE Check_Report_Unique 	( p_business_group_id IN NUMBER,
				  p_period_end        IN DATE,
				  p_report_type       IN VARCHAR2,
				  p_state             IN VARCHAR2 );
--
--
FUNCTION Create_Payroll_Action ( p_report_type       IN  VARCHAR2,
  				 p_state	     IN  VARCHAR2,
  				 p_trans_legal_co_id IN  VARCHAR2,
  				 p_business_group_id IN  NUMBER,
  				 p_period_end        IN  DATE,
				 p_param_text        IN  VARCHAR2
							  DEFAULT NULL ) RETURN NUMBER;
--
--
FUNCTION Create_Assignment_Action ( p_payroll_action_id IN NUMBER,
  				    p_assignment_id     IN NUMBER,
  				    p_tax_unit_id       IN NUMBER ) RETURN NUMBER;
--
--
PROCEDURE Error_Payroll_Action ( p_payroll_action_id NUMBER );
--
--
PROCEDURE Get_Dates		( p_report_type   	 VARCHAR2,
  				  p_year          	 VARCHAR2,
  				  p_year_start    IN OUT nocopy DATE,
  				  p_year_end      IN OUT nocopy DATE,
  				  p_rep_year      IN OUT nocopy VARCHAR2 );
--
--
PROCEDURE Update_Action_Status ( p_payroll_action_id NUMBER );
--
--
PROCEDURE Main ( p_report_format IN VARCHAR2 );
--
--
PROCEDURE Insert_Lookup
  ( p_lookup_code      IN VARCHAR2,
    p_lookup_type      IN VARCHAR2,
    p_application_id   IN NUMBER DEFAULT 800,
    p_created_by       IN NUMBER DEFAULT 1,
    p_creation_date    IN DATE DEFAULT to_date('01/01/1901','DD/MM/YYYY'),
    p_enabled_flag     IN VARCHAR2 DEFAULT 'Y',
    p_last_updated_by  IN NUMBER DEFAULT 1,
    p_last_update_date IN DATE DEFAULT to_date('01/01/1901','DD/MM/YYYY'),
    p_meaning          IN VARCHAR2,
    p_effective_date   IN DATE DEFAULT to_date('01/01/1901','DD/MM/YYYY') );
--
--
PROCEDURE Write ( p_action     IN VARCHAR2,
                  p_sequence   IN NUMBER   DEFAULT NULL,
                  p_message    IN VARCHAR2 DEFAULT NULL,
                  p_write_mode IN BOOLEAN  DEFAULT TRUE);
--
--
FUNCTION  Org_Info_Exists ( p_org_info_type IN VARCHAR2) RETURN BOOLEAN;
--
--
FUNCTION Date_Earned ( p_report_date              IN DATE,
                       p_assignment_id            IN NUMBER,
                       p_ass_effective_start_date IN DATE,
                       p_ass_effective_end_date   IN DATE,
                       p_per_effective_start_date IN DATE,
                       p_per_effective_end_date   IN DATE) RETURN NUMBER;
--
PRAGMA RESTRICT_REFERENCES(Date_Earned, WNDS, WNPS);
--
FUNCTION udf_Exists (p_udf_name in varchar2) RETURN NUMBER;
--
PROCEDURE Delete_udf (p_udf_name in varchar2);
--
--
FUNCTION get_parameter(name in varchar2,
				   end_name in varchar2,
                       parameter_list varchar2) return varchar2;
pragma restrict_references(get_parameter, WNDS, WNPS);
--
END Pay_Mag_Utils;

 

/
