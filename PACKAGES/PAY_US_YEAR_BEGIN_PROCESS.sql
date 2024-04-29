--------------------------------------------------------
--  DDL for Package PAY_US_YEAR_BEGIN_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_YEAR_BEGIN_PROCESS" AUTHID CURRENT_USER AS
/* $Header: payusyearbegin.pkh 120.0.12010000.2 2009/10/07 03:51:55 emunisek ship $ */
--
/*
*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 1996 Oracle Corporation.                        *
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

    Name        : pay_us_year_begin_process



    Change List
    -----------
     Date        Name      Vers    Bug No    Description
     ----        ----      ------  -------   ---------------
    09-Nov-2004	 schauhan  115.0   3625425   Initial Version
    06-Oct-2009  emunisek  115.1   8985595   Added new parameter p_clr_wis_eic
                                             to the procedure reset_overrides
                                             to enable the "Clear Wisconsin EIC"
                                             in "Year Begin Process".An overloaded
                                             function was created with new parameter
                                             to maintain integrity of any other
                                             reference to this procedure.

*/
PROCEDURE  reset_overrides
              (errbuf                      out nocopy varchar2
              ,retcode                     out nocopy number
	      ,p_business_group            in  varchar2
	      ,p_curr_year                 in  varchar2
	      ,p_clr_ind_add_ovr           in  varchar2
	      ,p_clr_ind_eic               in  varchar2
	      ,p_clr_sui_wb_ovr            in  varchar2
	      ,p_clr_pa_head_tax           in  varchar2
	      ,p_clr_fed_eic_filing_status in  varchar2
	     );

/*Created for Bug8985595 to allow the clearing of Wisconsin EIC through Year Begin
Process */

PROCEDURE  reset_overrides
              (errbuf                      out nocopy varchar2
              ,retcode                     out nocopy number
	      ,p_business_group            in  varchar2
	      ,p_curr_year                 in  varchar2
	      ,p_clr_ind_add_ovr           in  varchar2
	      ,p_clr_ind_eic               in  varchar2
	      ,p_clr_sui_wb_ovr            in  varchar2
	      ,p_clr_pa_head_tax           in  varchar2
	      ,p_clr_fed_eic_filing_status in  varchar2
	      ,p_clr_wis_eic               in  varchar2
	     );


end pay_us_year_begin_process;

/
