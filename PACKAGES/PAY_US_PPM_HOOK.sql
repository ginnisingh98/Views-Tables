--------------------------------------------------------
--  DDL for Package PAY_US_PPM_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_US_PPM_HOOK" AUTHID CURRENT_USER AS
/* $Header: payusppmhook.pkh 120.0.12010000.2 2010/01/20 07:00:52 mikarthi noship $ */
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

    Name        : PAY_US_PPM_HOOK
    File Name   : payusppmhook.pkh

    Description : This package is called from the BEFORE INSERT/UPDATE
                  User Hooks. The following are the functionalities present
                  in User Hook

                  1. Validates the Bank Account Number in the Bank Details KFF

                  2. Validates the IAT Transit Code in the Further Information DFF

                  3. Validates the Tranks Code in the Bank Details KFF

    Change List
    -----------
    Name           Date          Version Bug      Text
    -------------- -----------   ------- -------  -----------------------------
    mikarthi       05-Dec-2008   115.0   8806003  Initial Version
    mikarthi       20-Jan-2010   115.4   8904560  Included validation for DFI
                                                  Qualifier and Country Code.
******************************************************************************/


procedure VALIDATE_BANK_DETAILS(P_ORG_PAYMENT_METHOD_ID in NUMBER
                               ,P_SEGMENT3 in VARCHAR2
                               ,P_SEGMENT4 in VARCHAR2
                               ,p_ppm_information1 in VARCHAR2
                               ,p_ppm_information2 in VARCHAR2
                               ,p_ppm_information3 in VARCHAR2
                               ,p_effective_date in date);

procedure UPDATE_BANK_DETAILS(P_PERSONAL_PAYMENT_METHOD_ID in NUMBER
                               ,P_SEGMENT3 in VARCHAR2
                               ,P_SEGMENT4 in VARCHAR2
                               ,p_ppm_information1 in VARCHAR2
                               ,p_ppm_information2 in VARCHAR2
                               ,p_ppm_information3 in VARCHAR2
                               ,p_effective_date in date);

end  PAY_US_PPM_HOOK;

/
