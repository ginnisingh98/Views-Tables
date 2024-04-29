--------------------------------------------------------
--  DDL for Package HRWSCAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRWSCAL_PKG" AUTHID CURRENT_USER as
 /* $Header: hrwscal.pkh 115.0 99/07/17 05:37:22 porting ship $*/
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


    Name        : hrwscal_pkg

    Description : This package is the server side agent for
                  form HRWSCAL

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    31-Oct-1995 agladsto      40.0               Initial Creation
    30-JUL-1996 J.ALLOUN                         Added error handling.

  */


--   Fetch pattern exception details
--
Procedure fetch_pattern_excpt_details(
		  p_exception_name in varchar2,
	          p_EXCEPTION_ID out number,
                  p_PATTERN_ID out number,
		  p_EXCEPTION_CATEGORY out varchar2,
		  p_EXCEPTION_START_TIME out date,
		  p_EXCEPTION_END_TIME out date,
		  p_PATTERN_NAME out varchar2,
		  p_NEW_EXCEPTION_INDICTOR out varchar2,
		  p_EXCEPTION_CATEGORY_MEANING out varchar2
					    );

END HRWSCAL_PKG;

 

/
