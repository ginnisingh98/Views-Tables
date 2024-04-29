--------------------------------------------------------
--  DDL for Package Body PJI_CALC_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_CALC_ENGINE" AS
 /* $Header: PJIRX16B.pls 120.1 2005/05/31 08:03:21 appldev  $ */
 PROCEDURE Compute_FP_Measures( p_seeded_measures SYSTEM.PA_Num_Tbl_Type,
 x_custom_measures OUT NOCOPY  SYSTEM.PA_Num_Tbl_Type,
 x_return_status IN OUT NOCOPY VARCHAR2 ,
 x_msg_count IN OUT NOCOPY NUMBER ,
 x_msg_data IN OUT NOCOPY VARCHAR2 ) IS PPF_MSR_BEH_COL NUMBER := p_seeded_measures(1);
 BillableCost NUMBER := p_seeded_measures(2);
 BillLaborHrs NUMBER := p_seeded_measures(3);
 CurBudget2Cost NUMBER := p_seeded_measures(4);
 CurBudget2EquipHrs NUMBER := p_seeded_measures(5);
 CurBudget2PeopleHrs NUMBER := p_seeded_measures(6);
 CurBudget2Revenue NUMBER := p_seeded_measures(7);
 CurBudgetCost NUMBER := p_seeded_measures(8);
 CurBudgetEquipHrs NUMBER := p_seeded_measures(9);
 CurBudgetPeopleHrs NUMBER := p_seeded_measures(10);
 CurBudgetRevenue NUMBER := p_seeded_measures(11);
 ForecastCost NUMBER := p_seeded_measures(12);
 FcstEquipHrs NUMBER := p_seeded_measures(13);
 FcstPeopleHrs NUMBER := p_seeded_measures(14);
 FctRevenue NUMBER := p_seeded_measures(15);
 PeopleRawCost NUMBER := p_seeded_measures(16);
 NonBillPeopleHrs NUMBER := p_seeded_measures(17);
 OrigBudget2Cost NUMBER := p_seeded_measures(18);
 OrigBudget2EquipHrs NUMBER := p_seeded_measures(19);
 OrigBudget2PeopleHrs NUMBER := p_seeded_measures(20);
 OrigBudget2Revenue NUMBER := p_seeded_measures(21);
 OrigBudgetCost NUMBER := p_seeded_measures(22);
 OrigBudgetEquipHrs NUMBER := p_seeded_measures(23);
 OrigBudgetPeopleHrs NUMBER := p_seeded_measures(24);
 OrigBudgetRevenue NUMBER := p_seeded_measures(25);
 OthCommittedCost NUMBER := p_seeded_measures(26);
 PoCommittedCost NUMBER := p_seeded_measures(27);
 Revenue NUMBER := p_seeded_measures(28);
 RawCost NUMBER := p_seeded_measures(29);
 SupInvCommittedCost NUMBER := p_seeded_measures(30);
 TotalBurdenedCost NUMBER := p_seeded_measures(31);
 TotalEquipHrs NUMBER := p_seeded_measures(32);
 LaborBurdenedCost NUMBER := p_seeded_measures(33);
 TotalPeopleHrs NUMBER := p_seeded_measures(34);
  BEGIN  x_custom_measures := SYSTEM.PA_Num_Tbl_Type();
  x_custom_measures.extend(15);
 x_custom_measures(1) := BillableCost + CurBudgetCost;
 x_custom_measures(2) :=  0;
 x_custom_measures(3) :=  0;
 x_custom_measures(4) :=  0;
 x_custom_measures(5) :=  0;
 x_custom_measures(6) :=  0;
 x_custom_measures(7) :=  0;
 x_custom_measures(8) :=  0;
 x_custom_measures(9) :=  0;
 x_custom_measures(10) :=  0;
 x_custom_measures(11) :=  0;
 x_custom_measures(12) :=  0;
 x_custom_measures(13) :=  0;
 x_custom_measures(14) :=  0;
 x_custom_measures(15) :=  0;
  END  Compute_FP_Measures;

  PROCEDURE Compute_AC_Measures( p_seeded_measures SYSTEM.PA_Num_Tbl_Type,
 x_custom_measures OUT NOCOPY  SYSTEM.PA_Num_Tbl_Type,
 x_return_status IN OUT NOCOPY VARCHAR2 ,
 x_msg_count IN OUT NOCOPY NUMBER ,
 x_msg_data IN OUT NOCOPY VARCHAR2 ) IS AdditionalFundingAmount NUMBER := p_seeded_measures(1);
 ArInvoiceAmount NUMBER := p_seeded_measures(2);
 ArCreditMemoAmount NUMBER := p_seeded_measures(3);
 PPF_MSR_CP_COL NUMBER := p_seeded_measures(4);
 FundingAdjustmentAmount NUMBER := p_seeded_measures(5);
 CancelledFundingAmount NUMBER := p_seeded_measures(6);
 ArInvoiceWriteoffAmount NUMBER := p_seeded_measures(7);
 InitialFundingAmount NUMBER := p_seeded_measures(8);
 ArAmountDue NUMBER := p_seeded_measures(9);
 OUT_OF_SCOPE NUMBER := p_seeded_measures(10);
 RevenueAtRisk NUMBER := p_seeded_measures(11);
 RevenueWriteoff NUMBER := p_seeded_measures(12);
  BEGIN  x_custom_measures := SYSTEM.PA_Num_Tbl_Type();
  x_custom_measures.extend(15);
 x_custom_measures(1) :=  0;
 x_custom_measures(2) :=  0;
 x_custom_measures(3) :=  0;
 x_custom_measures(4) :=  0;
 x_custom_measures(5) :=  0;
 x_custom_measures(6) :=  0;
 x_custom_measures(7) :=  0;
 x_custom_measures(8) :=  0;
 x_custom_measures(9) :=  0;
 x_custom_measures(10) :=  0;
 x_custom_measures(11) :=  0;
 x_custom_measures(12) :=  0;
 x_custom_measures(13) :=  0;
 x_custom_measures(14) :=  0;
 x_custom_measures(15) :=  0;
  END  Compute_AC_Measures;
  END Pji_Calc_Engine;

/
