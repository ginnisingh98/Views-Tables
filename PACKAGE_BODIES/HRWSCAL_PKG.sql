--------------------------------------------------------
--  DDL for Package Body HRWSCAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRWSCAL_PKG" as
 /* $Header: hrwscal.pkb 115.0 99/07/17 05:37:19 porting ship $
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
		  Calendar Patterns

    Change List
    -----------
    Date        Name          Vers    Bug No     Description
    ----        ----          ----    ------     -----------
    31-Oct-1995 agladsto      40.0               Initial Creation
    30-JUL-1996 jalloun                          Added error handling.
  */

-- --------------------------------------------------------------------------
-- |---------------------------< Check_Exception_Name >---------------------|
-- --------------------------------------------------------------------------
--
-- PUBLIC
-- Description:
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
					    ) is
--
lv_exception_name hr_pattern_exceptions.exception_name%type;
cursor pattern_exception_cursor is
  select EXCEPTION_ID,
	 PATTERN_ID,
	 EXCEPTION_CATEGORY,
	 EXCEPTION_START_TIME,
	 EXCEPTION_END_TIME,
	 PATTERN_NAME,
	 EXCEPTION_CATEGORY_MEANING
  from   hr_pattern_exceptions_v
  where  upper(exception_name) = upper(p_exception_name);


BEGIN
     open pattern_exception_cursor;
     fetch pattern_exception_cursor into
                       p_EXCEPTION_ID ,
		       p_PATTERN_ID ,
		       p_EXCEPTION_CATEGORY ,
		       p_EXCEPTION_START_TIME ,
		       p_EXCEPTION_END_TIME ,
		       p_PATTERN_NAME,
		       p_EXCEPTION_CATEGORY_MEANING;
     if pattern_exception_cursor%FOUND then
       p_NEW_EXCEPTION_INDICTOR := 'OLD';
     else
       p_NEW_EXCEPTION_INDICTOR := 'NEW';
     end if;

     close pattern_exception_cursor;
END fetch_pattern_excpt_details;
--
END HRWSCAL_PKG;

/
