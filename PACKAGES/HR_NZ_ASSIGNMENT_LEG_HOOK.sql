--------------------------------------------------------
--  DDL for Package HR_NZ_ASSIGNMENT_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_NZ_ASSIGNMENT_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: hrnzlhas.pkh 120.0 2005/05/31 01:39:14 appldev noship $ */
/*
 ******************************************************************
 *                                                                *
 *  Copyright (C) 1999 Oracle Corporation Australia Ltd.,         *
 *                     Brisbane, Australia.                       *
 *                                                                *
 *  All rights reserved.                                          *
 *                                                                *
 *  This material has been provided pursuant to an agreement      *
 *  containing restrictions on its use.  the material is also     *
 *  protected by copyright law.  no part of this material may     *
 *  be copied or distributed, transmitted or transcribed, in      *
 *  any form or by any means, electronic, mechanical, magnetic,   *
 *  manual, or otherwise, or disclosed to third parties without   *
 *  the express written permission of Oracle Corporation          *
 *  Australia Ltd,.                                               *
 *                                                                *
 ******************************************************************/

/*
	Filename: hrnzlhas.pkh (HEADER)
    Author: Philip Macdonald
 	Description: Creates the user hook seed data for the HR_ASSIGNMENT_API package procedures.

 	File Information
 	================

	Note for Oracle HRMS Developers: The data defined in the
	create API calls cannot be changed once this script has
	been shipped to customers. Explicit update or delete API
	calls will need to be added to the end of the script.


 	Change List
 	-----------

 	Version Date      Author     ER/CR No. Description of Change
 	-------+---------+-----------+---------+--------------------------
 	110.0   25-Jun-99 P.Macdonald           Created

 ================================================================= */


  PROCEDURE set_upd_bus_grp_id
  	(p_assignment_id 	NUMBER
	,p_effective_date	DATE);

  PROCEDURE set_cre_bus_grp_id
  	(p_person_id 		NUMBER
	,p_effective_date	DATE);

END hr_nz_assignment_leg_hook;

 

/
