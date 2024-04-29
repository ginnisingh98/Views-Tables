--------------------------------------------------------
--  DDL for Package PAY_US_EXTRA_PER_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_EXTRA_PER_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyusnra.pkh 120.2.12010000.1 2008/07/27 23:54:07 appldev ship $ */
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

    Package Name        : PAY_US_EXTRA_PER_INFO_LEG_HOOK
    Package File Name   : pui_pkb.pkb

    Description : This package will be called from Before Process Hook
                  hr_person_extra_info_api.create_person_extra_info and
		  hr_person_extra_info_api.update_person_extra_info for US
                  legislation. It is used to check for the Non Resident Status
		  of the employee.


    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    vaprakas       21-NOV-2006  115.0  5601735  Created.
    vaprakas       06-DEC-2006  115.1  5607135  Corrected rem dbdrv comments
    vaprakas       11-DEC-2006  115.2  5607135  Corrected rem dbdrv comments

*/

/*procedure update_tax_rules(p_period_of_service_id in number,
                           p_final_process_date in date) ;
			   */
procedure person_check_nra_status_create(P_PERSON_ID in NUMBER
,P_INFORMATION_TYPE in VARCHAR2
,P_PEI_INFORMATION_CATEGORY in VARCHAR2
,P_PEI_INFORMATION5 in VARCHAR2
,P_PEI_INFORMATION9 in VARCHAR2);


procedure person_check_nra_status_update(P_PERSON_EXTRA_INFO_ID in NUMBER
,P_PEI_INFORMATION_CATEGORY in VARCHAR2
,P_PEI_INFORMATION1 in VARCHAR2
,P_PEI_INFORMATION2 in VARCHAR2
,P_PEI_INFORMATION5 in VARCHAR2
,P_PEI_INFORMATION9 in VARCHAR2);

end PAY_US_EXTRA_PER_INFO_LEG_HOOK  ;

/
