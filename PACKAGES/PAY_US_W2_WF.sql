--------------------------------------------------------
--  DDL for Package PAY_US_W2_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_W2_WF" 
/* $Header: pyusw2wf.pkh 115.5 2002/12/04 21:06:03 meshah noship $ *
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2000 Oracle Corporation.                        *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material AUTHID CURRENT_USER is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************

    Name        : pay_us_w2_wf

    Description : Contains workflow code for W2 Notification workflow

    Uses        :

    Change List
    -----------
    Date        Name    Vers   Description
    ----        ----    ----   -----------
    22-MAR-2002 meshah  115.0  Created.
    26-MAR-2002 fusman  115.1  Added dbdrv command.
    27-MAR-2002 fusman  115.2  Changed pls.
    17-MAY-2002 fusman  115.3  Added set verify off.
    19-AUG-2002 fusman  115.3  Added whenever OS error command.
    04-DEC-2002 meshah  115.5  nocopy.
  *******************************************************************/
  AS

  gv_itemtype VARCHAR2(80) := 'HRSSA';


 PROCEDURE get_w2_notifier(itemtype   in varchar2
		   	    ,itemkey  in varchar2
		   	    ,actid    in number
		   	    ,funcmode in varchar2
		   	    ,result   out nocopy varchar2
		   	     );

 /******************************************************************
  **
  ** Description:
  **     Gets the next payroll rep who needs to be notified and sets
  ** 	 the forward from/to item attributes as proper.
  **
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/

END pay_us_w2_wf;

 

/
