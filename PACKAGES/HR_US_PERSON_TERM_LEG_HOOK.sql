--------------------------------------------------------
--  DDL for Package HR_US_PERSON_TERM_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_US_PERSON_TERM_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyusterm.pkh 120.1 2008/01/18 13:06:39 jdevasah noship $ */
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

    Package Name        : hr_us_person_term_leg_hook
    Package File Name   : pyusterm.pkh

    Purpose             :

    This package has been created to correctly end date the US
    Specific Federal, State, County, City level Tax Records
    according to the Final Process Date entered by the User.
    This package will be called from Before Process Hook
    hr_periods_of_service_bk1.update_pds_details_b for US
    legislation.
    This package has been introduced due to the Functionality
    provided in RUP that allows user to change (prepone or
    postpone) Final Process Date.


    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sudedas       13-NOV-2006 115.0   5460532 Created.
    vaprakas      16-NOV-2006 115.1   5460532 Modified DBDRV comments
    vaprakas      17-NOV-2006 115.2   5460532 Modified DBDRV comments

*/

procedure update_tax_rules(p_period_of_service_id in number,
                           p_final_process_date in date) ;
end hr_us_person_term_leg_hook ;

/
