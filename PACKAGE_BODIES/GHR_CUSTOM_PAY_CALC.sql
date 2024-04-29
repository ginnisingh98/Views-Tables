--------------------------------------------------------
--  DDL for Package Body GHR_CUSTOM_PAY_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GHR_CUSTOM_PAY_CALC" as
/* $Header: ghcustpc.pkb 120.0.12010000.2 2009/05/26 10:29:06 utokachi noship $ */
--
-- ----------------------------------------------------------------------------
-- |                     Private Global Definitions                           |
-- ----------------------------------------------------------------------------
--
g_package  varchar2(33) := 'ghr_custom_pay_calc.';  -- Global package name
--
-- ----------------------------------------------------------------------------
-- |-------------------------------< custom_pay_calc >-------------------------|
-- ----------------------------------------------------------------------------
--
procedure custom_pay_calc
  (p_pay_data_rec              IN     ghr_pay_calc.pay_calc_in_rec_type
  ,p_pay_data_out_rec          IN OUT NOCOPY ghr_pay_calc.pay_calc_out_rec_type
  ,p_message_set               IN OUT NOCOPY BOOLEAN
  ,p_calculated                IN OUT NOCOPY BOOLEAN
  ) IS
--
  l_proc       varchar2(72) := g_package||'custom_pay_calc';
--
Begin
  hr_utility.set_location('Entering:'||l_proc, 5);
  --
  /*************** Add custom code here **************/

  --  /**************** EXAMPLE *********************************
  -- below is an example of what you may code if you knew how
  -- to calculate for example a pay basis of 'PW' . Hopefully it would be a bit more
  -- complicated than this otherwise we could have done it!!!!
  -- NOTE: You need to set ALL out parameters
  --IF NOT p_calculated THEN
  --  IF p_pay_data_rec.pay_basis = 'PW' THEN
  --    p_pay_data_out_rec.basic_pay        := 4444;
  --    p_pay_data_out_rec.locality_adj     := 10;
  --    p_pay_data_out_rec.adj_basic_pay    := 4454;
  --    p_pay_data_out_rec.total_salary     := 4454;
  --    p_pay_data_out_rec.other_pay_amount := 0;
  --    p_pay_data_out_rec.au_overtime      := 0;
  --    p_pay_data_out_rec.availability_pay := 0;
  --
  --    p_calculated := TRUE;
  --    p_message_set := FALSE;
  --  END IF;
  --END IF;
  --  ***********************************************************/
  --
  --
  hr_utility.set_location('Leaving:'||l_proc, 10);
end custom_pay_calc;
--
end ghr_custom_pay_calc;

/
