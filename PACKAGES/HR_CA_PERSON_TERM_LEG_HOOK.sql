--------------------------------------------------------
--  DDL for Package HR_CA_PERSON_TERM_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_CA_PERSON_TERM_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pycaterm.pkh 120.0.12010000.1 2008/11/12 09:25:05 sneelapa noship $ */
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

    Package Name        : hr_ca_person_term_leg_hook
    Package File Name   : pycaterm.pkh

    Purpose             :

    This package has been created to correctly end date the CA
    Specific Federal, Provindial Tax Records
    according to the Final Process Date entered by the User.
    This package will be called before Process Hook
    hr_periods_of_service_bk1.update_pds_details_b for CA
    legislation.

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sneelapa      24-APR-2008 115.0           Initial version.

*/

procedure update_tax_rules(p_period_of_service_id in number,
                           p_final_process_date in date) ;

end HR_CA_PERSON_TERM_LEG_HOOK;

/
