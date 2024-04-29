--------------------------------------------------------
--  DDL for Package PAY_GB_WORKING_TAX_CREDIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_GB_WORKING_TAX_CREDIT" AUTHID CURRENT_USER as
/* $Header: pygbwtcp.pkh 115.0 2002/10/25 10:40:24 gbutler noship $
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2002 Oracle Corporation UK Ltd.,                *
   *                   Richmond, England.                           *
   *                                                                *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation UK Ltd,  *
   *  Oracle Park, Bittams Lane, Guildford Road, Chertsey, Surrey,  *
   *  England.                                                      *
   *                                                                *
   ******************************************************************

    Name        : pay_gb_working_tax_credit

    Description : This package contains calculations for use in processing
        	  working tax credits from 06 April 2003 onwards

    Uses        :

    Used By     : WORKING_TAX_CREDIT fast formula

    Change List :

    Version     Date     	Author         Description
    -------     -----    	--------       ----------------

   115.0        4/10/2002   	GBUTLER        Created

*/




/* Primary function to calculate total amount payable to employee */
/* Called by WORKING_TAX_CREDIT fast formula			  */
/* Context parameters: p_assignment_id				  */

/* Function parameters: p_start_date				  */
/*			p_end_date				  */
function calculate_payable
	 (p_assignment_id 		IN NUMBER,
	  p_start_date 			IN DATE,
	  p_end_date   			IN DATE)
	  return number;

function days_between
     	(p_start_date      		IN date,
     	 p_end_date        		IN date)
    return number;

end PAY_GB_WORKING_TAX_CREDIT;

 

/
