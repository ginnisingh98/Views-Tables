--------------------------------------------------------
--  DDL for Package PAY_IN_ELE_EXTRA_INFO_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_ELE_EXTRA_INFO_LEG_HOOK" AUTHID CURRENT_USER AS
/* $Header: pyinlhei.pkh 120.0 2005/05/29 05:51 appldev noship $ */
--
--------------------------------------------------------------------------
--                                                                      --
-- Name           : CHECK_TDS_FIELDS                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Checks that if the TDS type is not Fixed Percentage --
--                  then TDS Percentage field must be null and if the   --
--                  TDS type is Fixed Percentage, then TDS Percentage   --
--                  field must be populated                             --
--                                                                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_eei_information1          VARCHAR2                --
--                  p_eei_information2          VARCHAR2                --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   10-Sep-04  abhjain	Created this procedure                  --
--------------------------------------------------------------------------

PROCEDURE check_tds_fields(p_eei_information_category IN VARCHAR2
         		  ,p_eei_information1         IN VARCHAR2
			  ,p_eei_information2         IN VARCHAR2
        		  ) ;


END  pay_in_ele_extra_info_leg_hook;

 

/
