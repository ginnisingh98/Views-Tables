--------------------------------------------------------
--  DDL for Package PAY_US_TAX_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_TAX_WF" 
/* $Header: pyustxwf.pkh 115.1 2004/01/13 06:29:47 rsethupa noship $ *
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

    Name        : pay_us_tax_wf

    Description : Contains workflow code for Tax Notification workflow

    Uses        :

    Change List
    -----------
    Date        Name    Vers   Description
    ----        ----    ----   -----------
    28-SEP-2000 dscully  115.0  Created.
    13-JAN-2004 rsethupa 115.1  Added dbdrv command
                                Added NOCOPY after out
                                parameter in procedures.


  *******************************************************************/
  AS

  gv_itemtype VARCHAR2(80) := 'PYUSTXNT';

  PROCEDURE start_wf(p_transaction_id 	IN pay_stat_trans_audit.stat_trans_audit_id%TYPE,
		     p_process 		IN varchar2
		   );
 /******************************************************************
  **
  ** Description:
  **     initializes and starts workflow process
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/


 PROCEDURE init_tax_notifications(itemtype in varchar2
			,itemkey in varchar2
			,actid in number
			,funcmode in varchar2
			,result out NOCOPY varchar2
			);
 /******************************************************************
  **
  ** Description:
  **	Initializes the item attributes as appropriate.
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/

procedure check_final_notifier( itemtype    in varchar2,
                		itemkey     in varchar2,
               			actid       in number,
               			funcmode    in varchar2,
               			result      out NOCOPY varchar2     );
 /******************************************************************
  **
  ** Description:
  **	Checks if current notifier is the final notifier by
  **	calling custom code in hr_approvals custom.
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/


 PROCEDURE get_next_notifier(itemtype in varchar2
		   	    ,itemkey in varchar2
		   	    ,actid in number
		   	    ,funcmode in varchar2
		   	    ,result out NOCOPY varchar2
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

 PROCEDURE check_for_notification(itemtype in varchar2
				,itemkey in varchar2
				,actid in number
				,funcmode in varchar2
				,result out NOCOPY varchar2
				);
 /******************************************************************
  **
  ** Description:
  **     Checks to see if Submission needs to be forwarded to a
  **	 payroll manager.
  **
  **
  **
  ** Access Status:
  **     Public
  **
  ******************************************************************/

END pay_us_tax_wf;

 

/
