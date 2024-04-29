--------------------------------------------------------
--  DDL for Package Body PAY_US_PPM_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_US_PPM_HOOK" AS
/* $Header: payusppmhook.pkb 120.0.12010000.5 2010/01/20 07:03:16 mikarthi noship $ */
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
    File Name   : payusppmhook.pkb

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

  *****************************************************************************/

/* *****************************************************************************
   Name        : VALIDATE_BANK_DETAILS
   Scope       : LOCAL
   Description : This Function validates the Transit Code and Bank AccountNum
                 During Insert operation
******************************************************************************/

    procedure VALIDATE_BANK_DETAILS(P_ORG_PAYMENT_METHOD_ID in NUMBER
                                   ,P_SEGMENT3 in VARCHAR2
                                   ,P_SEGMENT4 in VARCHAR2
                                   ,p_ppm_information1 in VARCHAR2
                                   ,p_ppm_information2 in VARCHAR2
                                   ,p_ppm_information3 in VARCHAR2
                                   ,p_effective_date in date) is

    l_is_foreign_trans  VARCHAR2(30);
    transit_code        NUMBER;

    begin

        select PMETH_INFORMATION9
        INTO l_is_foreign_trans
        from pay_org_payment_methods_f where ORG_PAYMENT_METHOD_ID = P_ORG_PAYMENT_METHOD_ID
        AND p_effective_date BETWEEN effective_start_date
                         AND effective_end_date;

        hr_utility.trace('l_is_foreign_trans : ' || l_is_foreign_trans);

        if l_is_foreign_trans <> 'Y' or l_is_foreign_trans is null then
        --Not IAT transaction
            if length(P_SEGMENT3) > 17 then
                 hr_utility.trace('Test 1');
                 hr_utility.set_message(801, 'PAY_US_NACHA_INVALD_BANK_ACCNT');
                 hr_utility.raise_error;
            end if;

        else
        --IAT transaction
               if P_SEGMENT4 <> '000000000' then

                 hr_utility.set_message(801, 'PAY_US_IAT_INVALD_TRANSIT_CODE');
                 hr_utility.raise_error;

               end if;

               if (p_ppm_information1 is null) or
                  (p_ppm_information2 is null) or
                  (p_ppm_information3 is null) then

                 hr_utility.set_message(801, 'PAY_US_IAT_NO_TRANSIT_CODE');
                 hr_utility.raise_error;
               end if;

        end if;


    end   VALIDATE_BANK_DETAILS;

    /* *****************************************************************************
       Name        : UPDATE_BANK_DETAILS
       Scope       : LOCAL
       Description : This Function validates the Transit Code and Bank AccountNum
                     During Update operation
    ******************************************************************************/

    procedure UPDATE_BANK_DETAILS(P_PERSONAL_PAYMENT_METHOD_ID in NUMBER
                                   ,P_SEGMENT3 in VARCHAR2
                                   ,P_SEGMENT4 in VARCHAR2
                                   ,p_ppm_information1 in VARCHAR2
                                   ,p_ppm_information2 in VARCHAR2
                                   ,p_ppm_information3 in VARCHAR2
                                   ,p_effective_date in date) is

        l_is_foreign_trans  VARCHAR2(30);
        transit_code        NUMBER;
        L_SEGMENT3          PAY_EXTERNAL_ACCOUNTS.SEGMENT3%TYPE;
        L_SEGMENT4          PAY_EXTERNAL_ACCOUNTS.SEGMENT4%TYPE;
        L_PPM_INFORMATION1  PAY_PERSONAL_PAYMENT_METHODS_F.PPM_INFORMATION1%TYPE;
        L_PPM_INFORMATION2  PAY_PERSONAL_PAYMENT_METHODS_F.PPM_INFORMATION2%TYPE;
        L_PPM_INFORMATION3  PAY_PERSONAL_PAYMENT_METHODS_F.PPM_INFORMATION3%TYPE;

        CURSOR CSR_BANK_SEGMENTS IS
        SELECT EXT.SEGMENT3, EXT.SEGMENT4
        FROM   PAY_PERSONAL_PAYMENT_METHODS_F PPM, PAY_EXTERNAL_ACCOUNTS EXT
        WHERE  PPM.PERSONAL_PAYMENT_METHOD_ID = P_PERSONAL_PAYMENT_METHOD_ID
        AND    EXT.EXTERNAL_ACCOUNT_ID        = PPM.EXTERNAL_ACCOUNT_ID
        AND    P_EFFECTIVE_DATE BETWEEN PPM.EFFECTIVE_START_DATE
                                AND     PPM.EFFECTIVE_END_DATE;

        CURSOR CSR_PPM_INFORMATION IS
        SELECT PPM.PPM_INFORMATION1,
               PPM.PPM_INFORMATION2,
               PPM.PPM_INFORMATION3
        FROM   PAY_PERSONAL_PAYMENT_METHODS_F PPM
        WHERE  PPM.PERSONAL_PAYMENT_METHOD_ID = P_PERSONAL_PAYMENT_METHOD_ID
        AND    P_EFFECTIVE_DATE BETWEEN PPM.EFFECTIVE_START_DATE
                                AND     PPM.EFFECTIVE_END_DATE;

    begin

        select popm.PMETH_INFORMATION9
        INTO l_is_foreign_trans
        from pay_org_payment_methods popm,  pay_Personal_payment_methods pppm
        where popm.ORG_PAYMENT_METHOD_ID =  pppm.ORG_PAYMENT_METHOD_ID
        and pppm.PERSONAL_PAYMENT_METHOD_ID = P_PERSONAL_PAYMENT_METHOD_ID
        AND p_effective_date BETWEEN popm.effective_start_date
                             AND popm.effective_end_date;

        IF (p_segment3 = hr_api.g_varchar2 or p_segment4 = hr_api.g_varchar2) then

          OPEN CSR_BANK_SEGMENTS;
          FETCH CSR_BANK_SEGMENTS INTO L_SEGMENT3, L_SEGMENT4;
          CLOSE CSR_BANK_SEGMENTS;

          if (p_segment3 <> hr_api.g_varchar2) then
            l_segment3 := p_segment3;
          end if;

          if (p_segment4 <> hr_api.g_varchar2) then
            l_segment4 := p_segment4;
          end if;

        end if;


        if l_is_foreign_trans <> 'Y' or l_is_foreign_trans is null then
        --Not IAT transaction
            if length(l_segment3) > 17 then
                 hr_utility.trace('Test 1');
                 hr_utility.set_message(801, 'PAY_US_NACHA_INVALD_BANK_ACCNT');
                 hr_utility.raise_error;
            end if;

        else
        --IAT transaction
            if l_segment4 <> '000000000' then

             hr_utility.set_message(801, 'PAY_US_IAT_INVALD_TRANSIT_CODE');
             hr_utility.raise_error;

            end if;

           if (p_ppm_information1 = hr_api.g_varchar2) then
               OPEN CSR_PPM_INFORMATION;
               FETCH CSR_PPM_INFORMATION INTO L_PPM_INFORMATION1, L_PPM_INFORMATION2, L_PPM_INFORMATION3;
               CLOSE CSR_PPM_INFORMATION;
           ELSE
               L_PPM_INFORMATION1 := P_PPM_INFORMATION1;
               L_PPM_INFORMATION2 := P_PPM_INFORMATION2;
               L_PPM_INFORMATION3 := P_PPM_INFORMATION3;
           end if;

            if (L_PPM_INFORMATION1 is null) or
               (L_PPM_INFORMATION2 is null) or
               (L_PPM_INFORMATION3 is null) then

             hr_utility.set_message(801, 'PAY_US_IAT_NO_TRANSIT_CODE');
             hr_utility.raise_error;
            end if;

        end if;

    end   UPDATE_BANK_DETAILS;

end PAY_US_PPM_HOOK;

/
