--------------------------------------------------------
--  DDL for Package Body GHR_CUSTOM_PAY_CAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CUSTOM_PAY_CAP" as
/* $Header: ghcupcap.pkb 120.0.12010000.2 2009/05/26 10:27:14 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ghr_custom_pay_cap.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< custom_hook >-----------------------------|
-- ----------------------------------------------------------------------------
--
procedure custom_hook
  (p_pay_cap_in_data  IN     ghr_pay_caps.pay_cap_in_rec_type
  ,p_pay_cap_out_data IN OUT NOCOPY ghr_pay_caps.pay_cap_out_rec_type
  ) IS
--
  l_proc       varchar2(72) := g_package||'custom_pay_calc';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  /*************** Add custom code here **************/

  --  /**************** EXAMPLE *********************************
  -- below is an example of what you may code if pay cap for total
  -- salary of all people in pay_plan 'XX' was 1 million!
  --
  -- DO NOT do raise_error here as that will be handled by setting
  -- messsage_set to TRUE
  --
  --  IF p_pay_cap_in_data.pay_plan = 'XX'
  --    AND p_pay_cap_in_data.total_salary > 1000000 THEN
  --    p_pay_cap_out_data.open_fields := TRUE;
  --    p_pay_cap_out_data.message_set := TRUE;
  --    hr_utility.set_message(8301,'GHR_38999_PAY_CAP5');
  --  END IF;
  --END IF;
  --  ***********************************************************/
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end custom_hook;
--
end ghr_custom_pay_cap;

/
