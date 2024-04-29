--------------------------------------------------------
--  DDL for Package PAY_CN_ENTRY_VALUE_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CN_ENTRY_VALUE_LEG_HOOK" AUTHID CURRENT_USER as
/* $Header: pycnlhee.pkh 120.0.12000000.1 2007/02/06 16:36:53 appldev noship $ */
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_ENTRY_VALUE                                   --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Generic Procedure to be called for CN localization  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Bug      Description                      --
--------------------------------------------------------------------------
-- 1.0   07-Oct-06  abhjain  5563042  Created this procedure            --
--------------------------------------------------------------------------
PROCEDURE check_entry_value(p_effective_date       IN DATE
                           ,p_element_entry_id     IN NUMBER
                           ,p_effective_start_date IN DATE
                           ,p_effective_end_date   IN DATE
                           ,p_entry_information2   IN VARCHAR2
                           ,p_entry_information3   IN VARCHAR2
                           ,p_entry_information4   IN VARCHAR2
                           ,p_entry_information5   IN VARCHAR2
                           ,p_entry_information6   IN VARCHAR2
                           ,p_entry_information7   IN VARCHAR2
                           ,p_entry_information8   IN VARCHAR2
                           ,p_entry_information9   IN VARCHAR2
                           );
END pay_cn_entry_value_leg_hook;

 

/
