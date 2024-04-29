--------------------------------------------------------
--  DDL for Package Body PAY_IN_ETW_STRUCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_ETW_STRUCT" AS
/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */

   g_debug     BOOLEAN ;
--------------------------------------------------------------------------
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the elements for ETW        --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Bug#    Date      Userid   Description                               --
--------------------------------------------------------------------------
-- 5332442 26-JUL-06 statkar  Created                                   --
--------------------------------------------------------------------------
PROCEDURE init_code
IS
   l_procedure    CONSTANT VARCHAR2(100):= g_package||'init_code';
   l_message      VARCHAR2(255);
BEGIN
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: '||l_procedure,10);

/* Various Templates are as follows

  ----------------------------------------------------------------
  | Sr#   |   Classification  | Template Name                    |
  ----------------------------------------------------------------
  |   1   |   Fringe Benefits | Fringe Benefits                  |
  |   2   |   Allowances      | Fixed Allowance                  |
  |   3   |   Allowances      | Actual Expense Allowances        |
  |   4   |   Perquisites     | Free Education                   |
  |   5   |   Perquisites     | Company Accommodation            |
  |   6   |   Perquisites     | Loan at Concessional Rate        |
  |   7   |   Perquisites     | Company Movable Assets           |
  |   8   |   Perquisites     | Other Perquisites                |
  |   9   |   Earnings        | Leave Travel Concession          |
  |  10   |   Earnings        | Earnings                         |
  |  11   |   Perquisites     | Transfer of Company Assets       |
  |  12   |   Employer Charges| Employer Charges                 |
  |  13   |   Perquisites     | Lunch                            |
  |  14   |   Perquisites     | Car                              |
  ----------------------------------------------------------------
*/
  ----------------------------------------------------------------
  --  TEMPLATE FOR FRINGE BENEFITS STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,20);
  g_template_obj(1).template_name  := 'Fringe Benefits';
  g_template_obj(1).category       := 'Fringe Benefits';
  g_template_obj(1).priority       := 19000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Fringe Benefits Template start
    ----------------------------------------------------------------
    g_template_obj(1).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(1).er_setup(1).value     := 'N';
    g_template_obj(1).er_setup(1).descr     := 'Exclusion rule for Advances.';
    g_template_obj(1).er_setup(1).tag       := 'ADVANCE';
    g_template_obj(1).er_setup(1).rule_id   :=  null;

    g_template_obj(1).er_setup(2).ff_column := 'CONFIGURATION_INFORMATION3';
    g_template_obj(1).er_setup(2).value     := 'N';
    g_template_obj(1).er_setup(2).descr     := 'Exclusion rule for Medical Benefits.';
    g_template_obj(1).er_setup(2).tag       := 'MEDICAL';
    g_template_obj(1).er_setup(2).rule_id   :=  null;

    g_template_obj(1).er_setup(3).ff_column := 'CONFIGURATION_INFORMATION4';
    g_template_obj(1).er_setup(3).value     := 'N';
    g_template_obj(1).er_setup(3).descr     := 'Exclusion rule for Medical Projection.';
    g_template_obj(1).er_setup(3).tag       := 'MEDPROJ';
    g_template_obj(1).er_setup(3).rule_id   :=  null;

    g_template_obj(1).er_setup(4).ff_column := 'CONFIGURATION_INFORMATION5';
    g_template_obj(1).er_setup(4).value     := 'N';
    g_template_obj(1).er_setup(4).descr     := 'Exclusion rule for Fringe Benefit Taxation.';
    g_template_obj(1).er_setup(4).tag       := 'FBT';
    g_template_obj(1).er_setup(4).rule_id   :=  null;


    ----------------------------------------------------------------
    --  Exclusion Rules for Fringe Benefits Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Fringe Benefits Template start
    ----------------------------------------------------------------
    g_template_obj(1).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(1).iv_setup(1).uom              := 'M';
    g_template_obj(1).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(1).lookup_type      := null;
    g_template_obj(1).iv_setup(1).default_value    := null;
    g_template_obj(1).iv_setup(1).def_value_column := null;
    g_template_obj(1).iv_setup(1).min_value        := null;
    g_template_obj(1).iv_setup(1).warn_or_error    := null;
    g_template_obj(1).iv_setup(1).balance_name     := null;
    g_template_obj(1).iv_setup(1).exclusion_tag    := null;

    g_template_obj(1).iv_setup(2).input_value_name := 'Component Name';
    g_template_obj(1).iv_setup(2).uom              := 'C';
    g_template_obj(1).iv_setup(2).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(2).lookup_type      := null;
    g_template_obj(1).iv_setup(2).default_value    := null;
    g_template_obj(1).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
    g_template_obj(1).iv_setup(2).min_value        := null;
    g_template_obj(1).iv_setup(2).warn_or_error    := null;
    g_template_obj(1).iv_setup(2).balance_name     := null;
    g_template_obj(1).iv_setup(2).exclusion_tag    := null;

    g_template_obj(1).iv_setup(3).input_value_name := 'Benefit Amount';
    g_template_obj(1).iv_setup(3).uom              := 'M';
    g_template_obj(1).iv_setup(3).mandatory_flag   := 'Y';
    g_template_obj(1).iv_setup(3).lookup_type      := null;
    g_template_obj(1).iv_setup(3).default_value    := null;
    g_template_obj(1).iv_setup(3).def_value_column := null;
    g_template_obj(1).iv_setup(3).min_value        := null;
    g_template_obj(1).iv_setup(3).warn_or_error    := null;
    g_template_obj(1).iv_setup(3).balance_name     := 'Reimbursement Amount';
    g_template_obj(1).iv_setup(3).exclusion_tag    := null;

    g_template_obj(1).iv_setup(4).input_value_name := 'Salary under Sec 17';
    g_template_obj(1).iv_setup(4).uom              := 'M';
    g_template_obj(1).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(4).lookup_type      := null;
    g_template_obj(1).iv_setup(4).default_value    := null;
    g_template_obj(1).iv_setup(4).def_value_column := null;
    g_template_obj(1).iv_setup(4).min_value        := null;
    g_template_obj(1).iv_setup(4).warn_or_error    := null;
    g_template_obj(1).iv_setup(4).balance_name     := 'Salary under Section 17';
    g_template_obj(1).iv_setup(4).exclusion_tag    := 'MEDICAL';

    g_template_obj(1).iv_setup(5).input_value_name := 'Maximum Annual Limit';
    g_template_obj(1).iv_setup(5).uom              := 'M';
    g_template_obj(1).iv_setup(5).mandatory_flag   := 'N';
    g_template_obj(1).iv_setup(5).lookup_type      := null;
    g_template_obj(1).iv_setup(5).default_value    := null;
    g_template_obj(1).iv_setup(5).def_value_column := null;
    g_template_obj(1).iv_setup(5).min_value        := 0;
    g_template_obj(1).iv_setup(5).warn_or_error    := 'E';
    g_template_obj(1).iv_setup(5).balance_name     := null;
    g_template_obj(1).iv_setup(5).exclusion_tag    := null;

    g_template_obj(1).iv_setup(6).input_value_name := 'Adjusted Amount';
    g_template_obj(1).iv_setup(6).uom              := 'M';
    g_template_obj(1).iv_setup(6).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(6).lookup_type      := null;
    g_template_obj(1).iv_setup(6).default_value    := null;
    g_template_obj(1).iv_setup(6).def_value_column := null;
    g_template_obj(1).iv_setup(6).min_value        := null;
    g_template_obj(1).iv_setup(6).warn_or_error    := null;
    g_template_obj(1).iv_setup(6).balance_name     := 'Adjusted Advance for Fringe Benefits';
    g_template_obj(1).iv_setup(6).exclusion_tag    := null;

    g_template_obj(1).iv_setup(7).input_value_name := 'Add to Net Pay';
    g_template_obj(1).iv_setup(7).uom              := 'C';
    g_template_obj(1).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(1).iv_setup(7).lookup_type      := 'YES_NO';
    g_template_obj(1).iv_setup(7).default_value    := 'Y';
    g_template_obj(1).iv_setup(7).def_value_column := null;
    g_template_obj(1).iv_setup(7).min_value        := null;
    g_template_obj(1).iv_setup(7).warn_or_error    := null;
    g_template_obj(1).iv_setup(7).balance_name     := null;
    g_template_obj(1).iv_setup(7).exclusion_tag    := null;

    g_template_obj(1).iv_setup(8).input_value_name := 'Medical Benefit';
    g_template_obj(1).iv_setup(8).uom              := 'C';
    g_template_obj(1).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(8).lookup_type      := 'YES_NO';
    g_template_obj(1).iv_setup(8).default_value    := 'Y';
    g_template_obj(1).iv_setup(8).def_value_column := null;
    g_template_obj(1).iv_setup(8).min_value        := null;
    g_template_obj(1).iv_setup(8).warn_or_error    := null;
    g_template_obj(1).iv_setup(8).balance_name     := null;
    g_template_obj(1).iv_setup(8).exclusion_tag    := 'MEDICAL';

    g_template_obj(1).iv_setup(9).input_value_name := 'Annual Projected Value';
    g_template_obj(1).iv_setup(9).uom              := 'M';
    g_template_obj(1).iv_setup(9).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(9).lookup_type      := null;
    g_template_obj(1).iv_setup(9).default_value    := null;
    g_template_obj(1).iv_setup(9).def_value_column := null;
    g_template_obj(1).iv_setup(9).min_value        := null;
    g_template_obj(1).iv_setup(9).warn_or_error    := null;
    g_template_obj(1).iv_setup(9).balance_name     := 'Annual Projection for Reimbursement';
    g_template_obj(1).iv_setup(9).exclusion_tag    := null;

    g_template_obj(1).iv_setup(10).input_value_name := 'Projected Taxable Value';
    g_template_obj(1).iv_setup(10).uom              := 'M';
    g_template_obj(1).iv_setup(10).mandatory_flag   := 'X';
    g_template_obj(1).iv_setup(10).lookup_type      := null;
    g_template_obj(1).iv_setup(10).default_value    := null;
    g_template_obj(1).iv_setup(10).def_value_column := null;
    g_template_obj(1).iv_setup(10).min_value        := null;
    g_template_obj(1).iv_setup(10).warn_or_error    := null;
    g_template_obj(1).iv_setup(10).balance_name     := 'Projected Salary under Section 17';
    g_template_obj(1).iv_setup(10).exclusion_tag    := 'MEDPROJ';



    ----------------------------------------------------------------
    --  Input Values for Fringe Benefits Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Fringe Benefits Template start
    ----------------------------------------------------------------
    g_template_obj(1).bf_setup(1).balance_name     := 'Medical Reimbursement Amount';
    g_template_obj(1).bf_setup(1).iv_name          := 'Benefit Amount';
    g_template_obj(1).bf_setup(1).scale            := 1;
    g_template_obj(1).bf_setup(1).exclusion_tag    := 'MEDICAL';


    g_template_obj(1).bf_setup(2).balance_name     := 'Outstanding Advance for Fringe Benefits';
    g_template_obj(1).bf_setup(2).iv_name          := 'Adjusted Amount';
    g_template_obj(1).bf_setup(2).scale            := -1;
    g_template_obj(1).bf_setup(2).exclusion_tag    := null;


    ----------------------------------------------------------------
    --  Balance Feeds for Fringe Benefits Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Fringe Benefits Template starts
    ----------------------------------------------------------------
    g_template_obj(1).uf_setup.formula_name   := '_FB_CALC';
    g_template_obj(1).uf_setup.status_rule_id := null;
    g_template_obj(1).uf_setup.description    := 'Formula for Fringe Benefits';

      g_template_obj(1).uf_setup.frs_setup(1).result_name      := 'PAYABLE_VALUE';
      g_template_obj(1).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(1).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(1).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(1).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(1).uf_setup.frs_setup(2).result_name      := 'FRINGE_BENEFIT_VALUE';
      g_template_obj(1).uf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(1).uf_setup.frs_setup(2).input_value_name := 'Benefit Amount';
      g_template_obj(1).uf_setup.frs_setup(2).element_name     := null;
      g_template_obj(1).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(1).uf_setup.frs_setup(3).result_name      := 'SALARY_UNDER_SEC171';
      g_template_obj(1).uf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(1).uf_setup.frs_setup(3).input_value_name := 'Salary under Sec 17';
      g_template_obj(1).uf_setup.frs_setup(3).element_name     := null;
      g_template_obj(1).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(3).exclusion_tag    := 'MEDICAL';

      g_template_obj(1).uf_setup.frs_setup(4).result_name      := 'ADJUSTED_ADVANCE';
      g_template_obj(1).uf_setup.frs_setup(4).result_rule_type := 'D';
      g_template_obj(1).uf_setup.frs_setup(4).input_value_name := 'Adjusted Amount';
      g_template_obj(1).uf_setup.frs_setup(4).element_name     := null;
      g_template_obj(1).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(1).uf_setup.frs_setup(5).result_name      := 'ANNUAL_PROJECTED_VALUE';
      g_template_obj(1).uf_setup.frs_setup(5).result_rule_type := 'D';
      g_template_obj(1).uf_setup.frs_setup(5).input_value_name := 'Annual Projected Value';
      g_template_obj(1).uf_setup.frs_setup(5).element_name     := null;
      g_template_obj(1).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(1).uf_setup.frs_setup(6).result_name      := 'PROJECTED_SALARY_UNDER_SEC171';
      g_template_obj(1).uf_setup.frs_setup(6).result_rule_type := 'D';
      g_template_obj(1).uf_setup.frs_setup(6).input_value_name := 'Projected Taxable Value';
      g_template_obj(1).uf_setup.frs_setup(6).element_name     := null;
      g_template_obj(1).uf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(6).exclusion_tag    := 'MEDPROJ';

      g_template_obj(1).uf_setup.frs_setup(7).result_name      := 'TAXABLE_FRINGE_BENEFIT';
      g_template_obj(1).uf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(1).uf_setup.frs_setup(7).input_value_name := 'Taxable Fringe Benefit';
      g_template_obj(1).uf_setup.frs_setup(7).element_name     := ' Taxable Value';
      g_template_obj(1).uf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(7).exclusion_tag    := 'FBT';

      g_template_obj(1).uf_setup.frs_setup(8).result_name      := 'COMPONENT_NAME';
      g_template_obj(1).uf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(1).uf_setup.frs_setup(8).input_value_name := 'Component Name';
      g_template_obj(1).uf_setup.frs_setup(8).element_name     := ' Taxable Value';
      g_template_obj(1).uf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(1).uf_setup.frs_setup(8).exclusion_tag    := 'FBT';



    ----------------------------------------------------------------
    --  Formula Setup for Fringe Benefits Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Fringe Benefits Template starts
    ----------------------------------------------------------------
    g_template_obj(1).ae_setup(1).element_name     := ' Advance';
    g_template_obj(1).ae_setup(1).classification   := 'Advances';
    g_template_obj(1).ae_setup(1).exclusion_tag    := 'ADVANCE';
    g_template_obj(1).ae_setup(1).priority         := -12000;

      g_template_obj(1).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(1).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(1).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(1).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(1).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(1).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(1).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(1).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(1).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).iv_setup(2).input_value_name := 'Advance Amount';
      g_template_obj(1).ae_setup(1).iv_setup(2).uom              := 'M';
      g_template_obj(1).ae_setup(1).iv_setup(2).mandatory_flag   := 'N';
      g_template_obj(1).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(1).ae_setup(1).iv_setup(2).default_value    := null;
      g_template_obj(1).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(1).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(1).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(1).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(1).ae_setup(1).iv_setup(2).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).iv_setup(3).input_value_name := 'Excess Advance';
      g_template_obj(1).ae_setup(1).iv_setup(3).uom              := 'C';
      g_template_obj(1).ae_setup(1).iv_setup(3).mandatory_flag   := 'Y';
      g_template_obj(1).ae_setup(1).iv_setup(3).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(1).ae_setup(1).iv_setup(3).default_value    := 'PENDING';
      g_template_obj(1).ae_setup(1).iv_setup(3).def_value_column := null;
      g_template_obj(1).ae_setup(1).iv_setup(3).min_value        := null;
      g_template_obj(1).ae_setup(1).iv_setup(3).warn_or_error    := null;
      g_template_obj(1).ae_setup(1).iv_setup(3).balance_name     := null;
      g_template_obj(1).ae_setup(1).iv_setup(3).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).iv_setup(4).input_value_name := 'Add to Net Pay';
      g_template_obj(1).ae_setup(1).iv_setup(4).uom              := 'C';
      g_template_obj(1).ae_setup(1).iv_setup(4).mandatory_flag   := 'Y';
      g_template_obj(1).ae_setup(1).iv_setup(4).lookup_type      := 'YES_NO';
      g_template_obj(1).ae_setup(1).iv_setup(4).default_value    := 'Y';
      g_template_obj(1).ae_setup(1).iv_setup(4).def_value_column := null;
      g_template_obj(1).ae_setup(1).iv_setup(4).min_value        := null;
      g_template_obj(1).ae_setup(1).iv_setup(4).warn_or_error    := null;
      g_template_obj(1).ae_setup(1).iv_setup(4).balance_name     := null;
      g_template_obj(1).ae_setup(1).iv_setup(4).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).iv_setup(5).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(1).iv_setup(5).uom              := 'C';
      g_template_obj(1).ae_setup(1).iv_setup(5).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(1).iv_setup(5).lookup_type      := null;
      g_template_obj(1).ae_setup(1).iv_setup(5).default_value    := null;
      g_template_obj(1).ae_setup(1).iv_setup(5).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(1).ae_setup(1).iv_setup(5).min_value        := null;
      g_template_obj(1).ae_setup(1).iv_setup(5).warn_or_error    := null;
      g_template_obj(1).ae_setup(1).iv_setup(5).balance_name     := null;
      g_template_obj(1).ae_setup(1).iv_setup(5).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).bf_setup(1).balance_name     := 'Advance for Fringe Benefits';
      g_template_obj(1).ae_setup(1).bf_setup(1).iv_name          := 'Advance Amount';
      g_template_obj(1).ae_setup(1).bf_setup(1).scale            := 1;
      g_template_obj(1).ae_setup(1).bf_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).bf_setup(2).balance_name     := 'Outstanding Advance for Fringe Benefits';
      g_template_obj(1).ae_setup(1).bf_setup(2).iv_name          := 'Advance Amount';
      g_template_obj(1).ae_setup(1).bf_setup(2).scale            := 1;
      g_template_obj(1).ae_setup(1).bf_setup(2).exclusion_tag    := null;

    g_template_obj(1).ae_setup(1).uf_setup.formula_name   := '_FB_ADV_CALC';
    g_template_obj(1).ae_setup(1).uf_setup.status_rule_id := null;
    g_template_obj(1).ae_setup(1).uf_setup.description    := 'Advance Calculations for Earnings';


      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(1).result_name      := 'PAYABLE_VALUE';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(2).result_name      := 'EXCESS_ADVANCE';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(2).input_value_name := 'Excess Advance';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(2).element_name     := ' Excess Advance';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(3).result_name      := 'COMPONENT_NAME';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(3).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(3).element_name     := ' Excess Advance';
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(1).ae_setup(1).uf_setup.frs_setup(3).exclusion_tag    := null;


    g_template_obj(1).ae_setup(2).element_name     := ' Adjust';
    g_template_obj(1).ae_setup(2).classification   := 'Earnings';
    g_template_obj(1).ae_setup(2).exclusion_tag    := 'ADVANCE';
    g_template_obj(1).ae_setup(2).priority         := 4000;

      g_template_obj(1).ae_setup(2).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(1).ae_setup(2).iv_setup(1).uom              := 'M';
      g_template_obj(1).ae_setup(2).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(2).iv_setup(1).lookup_type      := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).default_value    := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).def_value_column := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).min_value        := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).warn_or_error    := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).balance_name     := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(2).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(2).iv_setup(2).uom              := 'C';
      g_template_obj(1).ae_setup(2).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(2).iv_setup(2).lookup_type      := null;
      g_template_obj(1).ae_setup(2).iv_setup(2).default_value    := 'Fringe Benefits';
      g_template_obj(1).ae_setup(2).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(1).ae_setup(2).iv_setup(2).min_value        := null;
      g_template_obj(1).ae_setup(2).iv_setup(2).warn_or_error    := null;
      g_template_obj(1).ae_setup(2).iv_setup(2).balance_name     := null;
      g_template_obj(1).ae_setup(2).iv_setup(2).exclusion_tag    := null;

      g_template_obj(1).ae_setup(2).bf_setup(1).balance_name     := 'Outstanding Advance for Fringe Benefits';
      g_template_obj(1).ae_setup(2).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(1).ae_setup(2).bf_setup(1).scale            := -1;
      g_template_obj(1).ae_setup(2).bf_setup(1).exclusion_tag    := null;

    g_template_obj(1).ae_setup(3).element_name     := ' Recover';
    g_template_obj(1).ae_setup(3).classification   := 'Voluntary Deductions';
    g_template_obj(1).ae_setup(3).exclusion_tag    := 'ADVANCE';
    g_template_obj(1).ae_setup(3).priority         := 26000;

      g_template_obj(1).ae_setup(3).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(1).ae_setup(3).iv_setup(1).uom              := 'M';
      g_template_obj(1).ae_setup(3).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(3).iv_setup(1).lookup_type      := null;
      g_template_obj(1).ae_setup(3).iv_setup(1).default_value    := null;
      g_template_obj(1).ae_setup(2).iv_setup(1).def_value_column := null;
      g_template_obj(1).ae_setup(3).iv_setup(1).min_value        := null;
      g_template_obj(1).ae_setup(3).iv_setup(1).warn_or_error    := null;
      g_template_obj(1).ae_setup(3).iv_setup(1).balance_name     := null;
      g_template_obj(1).ae_setup(3).iv_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(3).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(3).iv_setup(2).uom              := 'C';
      g_template_obj(1).ae_setup(3).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(3).iv_setup(2).lookup_type      := null;
      g_template_obj(1).ae_setup(3).iv_setup(2).default_value    := null;
      g_template_obj(1).ae_setup(3).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(1).ae_setup(3).iv_setup(2).min_value        := null;
      g_template_obj(1).ae_setup(3).iv_setup(2).warn_or_error    := null;
      g_template_obj(1).ae_setup(3).iv_setup(2).balance_name     := null;
      g_template_obj(1).ae_setup(3).iv_setup(2).exclusion_tag    := null;

      g_template_obj(1).ae_setup(3).iv_setup(3).input_value_name := 'Adjustment Amount';
      g_template_obj(1).ae_setup(3).iv_setup(3).uom              := 'M';
      g_template_obj(1).ae_setup(3).iv_setup(3).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(3).iv_setup(3).lookup_type      := null;
      g_template_obj(1).ae_setup(3).iv_setup(3).default_value    := null;
      g_template_obj(1).ae_setup(3).iv_setup(3).def_value_column := null;
      g_template_obj(1).ae_setup(3).iv_setup(3).min_value        := null;
      g_template_obj(1).ae_setup(3).iv_setup(3).warn_or_error    := null;
      g_template_obj(1).ae_setup(3).iv_setup(3).balance_name     := null;
      g_template_obj(1).ae_setup(3).iv_setup(3).exclusion_tag    := null;

      g_template_obj(1).ae_setup(3).bf_setup(1).balance_name     := 'Outstanding Advance for Fringe Benefits';
      g_template_obj(1).ae_setup(3).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(1).ae_setup(3).bf_setup(1).scale            := -1;
      g_template_obj(1).ae_setup(3).bf_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(3).bf_setup(2).balance_name     := 'Outstanding Advance for Fringe Benefits';
      g_template_obj(1).ae_setup(3).bf_setup(2).iv_name          := 'Adjustment Amount';
      g_template_obj(1).ae_setup(3).bf_setup(2).scale            := -1;
      g_template_obj(1).ae_setup(3).bf_setup(2).exclusion_tag    := null;

    g_template_obj(1).ae_setup(4).element_name     := ' Bills';
    g_template_obj(1).ae_setup(4).classification   := 'Information';
    g_template_obj(1).ae_setup(4).exclusion_tag    := null;
    g_template_obj(1).ae_setup(4).priority         := -12000;

      g_template_obj(1).ae_setup(4).iv_setup(1).input_value_name := 'Bill Amount';
      g_template_obj(1).ae_setup(4).iv_setup(1).uom              := 'M';
      g_template_obj(1).ae_setup(4).iv_setup(1).mandatory_flag   := 'Y';
      g_template_obj(1).ae_setup(4).iv_setup(1).lookup_type      := null;
      g_template_obj(1).ae_setup(4).iv_setup(1).default_value    := null;
      g_template_obj(1).ae_setup(4).iv_setup(1).def_value_column := null;
      g_template_obj(1).ae_setup(4).iv_setup(1).min_value        := null;
      g_template_obj(1).ae_setup(4).iv_setup(1).warn_or_error    := null;
      g_template_obj(1).ae_setup(4).iv_setup(1).balance_name     := 'Bills Submitted';
      g_template_obj(1).ae_setup(4).iv_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(4).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(4).iv_setup(2).uom              := 'C';
      g_template_obj(1).ae_setup(4).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(4).iv_setup(2).lookup_type      := null;
      g_template_obj(1).ae_setup(4).iv_setup(2).default_value    := null;
      g_template_obj(1).ae_setup(4).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(1).ae_setup(4).iv_setup(2).min_value        := null;
      g_template_obj(1).ae_setup(4).iv_setup(2).warn_or_error    := null;
      g_template_obj(1).ae_setup(4).iv_setup(2).balance_name     := null;
      g_template_obj(1).ae_setup(4).iv_setup(2).exclusion_tag    := null;


    ----------------------------------------------------------------
    --  Balance Feeds for Medical Bills  start
    ----------------------------------------------------------------
    g_template_obj(1).ae_setup(4).bf_setup(1).balance_name     := 'Medical Bills';
    g_template_obj(1).ae_setup(4).bf_setup(1).iv_name          := 'Bill Amount';
    g_template_obj(1).ae_setup(4).bf_setup(1).scale            := 1;
    g_template_obj(1).ae_setup(4).bf_setup(1).exclusion_tag    := 'MEDICAL';


    g_template_obj(1).ae_setup(5).element_name     := ' Excess Advance';
    g_template_obj(1).ae_setup(5).classification   := 'Information';
    g_template_obj(1).ae_setup(5).exclusion_tag    := 'ADVANCE';
    g_template_obj(1).ae_setup(5).priority         := 2000;

      g_template_obj(1).ae_setup(5).iv_setup(1).input_value_name := 'Excess Advance';
      g_template_obj(1).ae_setup(5).iv_setup(1).uom              := 'C';
      g_template_obj(1).ae_setup(5).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(5).iv_setup(1).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(1).ae_setup(5).iv_setup(1).default_value    := 'PENDING';
      g_template_obj(1).ae_setup(5).iv_setup(1).def_value_column := null;
      g_template_obj(1).ae_setup(5).iv_setup(1).min_value        := null;
      g_template_obj(1).ae_setup(5).iv_setup(1).warn_or_error    := null;
      g_template_obj(1).ae_setup(5).iv_setup(1).balance_name     := null;
      g_template_obj(1).ae_setup(5).iv_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(5).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(5).iv_setup(2).uom              := 'C';
      g_template_obj(1).ae_setup(5).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(5).iv_setup(2).lookup_type      := null;
      g_template_obj(1).ae_setup(5).iv_setup(2).default_value    := 'Fringe Benefits';
      g_template_obj(1).ae_setup(5).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(1).ae_setup(5).iv_setup(2).min_value        := null;
      g_template_obj(1).ae_setup(5).iv_setup(2).warn_or_error    := null;
      g_template_obj(1).ae_setup(5).iv_setup(2).balance_name     := null;
      g_template_obj(1).ae_setup(5).iv_setup(2).exclusion_tag    := null;

     g_template_obj(1).ae_setup(5).uf_setup.formula_name   := '_FB_EXC_ADV';
     g_template_obj(1).ae_setup(5).uf_setup.status_rule_id := null;
     g_template_obj(1).ae_setup(5).uf_setup.description    := 'Excess Advance Calculations for Fringe Benefits';

      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(1).result_name      := 'ADJUSTMENT_AMT';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(1).result_rule_type := 'I';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(1).input_value_name := 'Adjustment Amount';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(1).element_name     := ' Recover';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(1).exclusion_tag    := null;


      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(2).result_name      := 'RECOVERED_ADVANCE';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(2).element_name     := ' Recover';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(3).result_name      := 'SALARY_SEC171';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(3).input_value_name := 'Pay Value';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(3).element_name     := ' Adjust';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(4).result_name      := 'COMPONENT_NAME_PAY';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(4).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(4).element_name     := ' Adjust';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(5).result_name      := 'COMPONENT_NAME_REC';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(5).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(5).element_name     := ' Recover';
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(1).ae_setup(5).uf_setup.frs_setup(5).exclusion_tag    := null;

    g_template_obj(1).ae_setup(6).element_name     := ' Taxable Value';
    g_template_obj(1).ae_setup(6).classification   := 'Information';
    g_template_obj(1).ae_setup(6).exclusion_tag    := 'FBT';
    g_template_obj(1).ae_setup(6).priority         := 300;

      g_template_obj(1).ae_setup(6).iv_setup(1).input_value_name := 'Taxable Fringe Benefit';
      g_template_obj(1).ae_setup(6).iv_setup(1).uom              := 'M';
      g_template_obj(1).ae_setup(6).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(6).iv_setup(1).lookup_type      := null;
      g_template_obj(1).ae_setup(6).iv_setup(1).default_value    := null;
      g_template_obj(1).ae_setup(6).iv_setup(1).def_value_column := null;
      g_template_obj(1).ae_setup(6).iv_setup(1).min_value        := null;
      g_template_obj(1).ae_setup(6).iv_setup(1).warn_or_error    := null;
      g_template_obj(1).ae_setup(6).iv_setup(1).balance_name     := 'Taxable Fringe Benefit';
      g_template_obj(1).ae_setup(6).iv_setup(1).exclusion_tag    := null;

      g_template_obj(1).ae_setup(6).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(1).ae_setup(6).iv_setup(2).uom              := 'C';
      g_template_obj(1).ae_setup(6).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(1).ae_setup(6).iv_setup(2).lookup_type      := null;
      g_template_obj(1).ae_setup(6).iv_setup(2).default_value    := null;
      g_template_obj(1).ae_setup(6).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(1).ae_setup(6).iv_setup(2).min_value        := null;
      g_template_obj(1).ae_setup(6).iv_setup(2).warn_or_error    := null;
      g_template_obj(1).ae_setup(6).iv_setup(2).balance_name     := null;
      g_template_obj(1).ae_setup(6).iv_setup(2).exclusion_tag    := null;



    ----------------------------------------------------------------
    --  Add. Element Setup for Fringe Benefits Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Fringe Benefits Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR FRINGE BENEFITS ENDS
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR FIXED ALLOWANCES STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,30);
  g_template_obj(2).template_name  := 'Fixed Allowance';
  g_template_obj(2).category       := 'Allowances';
  g_template_obj(2).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Fixed Allowances Template start
    ----------------------------------------------------------------
    g_template_obj(2).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(2).er_setup(1).value     := 'N';
    g_template_obj(2).er_setup(1).descr     := 'Exclusion rule for Projections';
    g_template_obj(2).er_setup(1).tag       := 'PROJECT';
    g_template_obj(2).er_setup(1).rule_id   :=  null;

    g_template_obj(2).er_setup(2).ff_column := 'CONFIGURATION_INFORMATION3';
    g_template_obj(2).er_setup(2).value     := 'N';
    g_template_obj(2).er_setup(2).descr     := 'Exclusion rule for CEA/HEA';
    g_template_obj(2).er_setup(2).tag       := 'EXSEC10';
    g_template_obj(2).er_setup(2).rule_id   :=  null;

    g_template_obj(2).er_setup(3).ff_column := 'CONFIGURATION_INFORMATION4';
    g_template_obj(2).er_setup(3).value     := 'N';
    g_template_obj(2).er_setup(3).descr     := 'Exclusion rule for Advances';
    g_template_obj(2).er_setup(3).tag       := 'ADVANCE';
    g_template_obj(2).er_setup(3).rule_id   :=  null;
    ----------------------------------------------------------------
    --  Exclusion Rules for Fixed Allowances Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Fixed Allowances Template start
    ----------------------------------------------------------------
    g_template_obj(2).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(2).iv_setup(1).uom              := 'M';
    g_template_obj(2).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(2).iv_setup(1).lookup_type      := null;
    g_template_obj(2).iv_setup(1).default_value    := null;
    g_template_obj(2).iv_setup(1).def_value_column := null;
    g_template_obj(2).iv_setup(1).min_value        := null;
    g_template_obj(2).iv_setup(1).warn_or_error    := null;
    g_template_obj(2).iv_setup(1).balance_name     := null;
    g_template_obj(2).iv_setup(1).exclusion_tag    := null;

    g_template_obj(2).iv_setup(2).input_value_name := 'Allowance Amount';
    g_template_obj(2).iv_setup(2).uom              := 'M';
    g_template_obj(2).iv_setup(2).mandatory_flag   := 'Y';
    g_template_obj(2).iv_setup(2).lookup_type      := null;
    g_template_obj(2).iv_setup(2).default_value    := null;
    g_template_obj(2).iv_setup(2).def_value_column := null;
    g_template_obj(2).iv_setup(2).min_value        := null;
    g_template_obj(2).iv_setup(2).warn_or_error    := null;
    g_template_obj(2).iv_setup(2).balance_name     := null;
    g_template_obj(2).iv_setup(2).exclusion_tag    := null;

    g_template_obj(2).iv_setup(3).input_value_name := 'Standard Value';
    g_template_obj(2).iv_setup(3).uom              := 'M';
    g_template_obj(2).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(2).iv_setup(3).lookup_type      := null;
    g_template_obj(2).iv_setup(3).default_value    := null;
    g_template_obj(2).iv_setup(3).def_value_column := null;
    g_template_obj(2).iv_setup(3).min_value        := null;
    g_template_obj(2).iv_setup(3).warn_or_error    := null;
    g_template_obj(2).iv_setup(3).balance_name     := 'Allowances Standard Value';
    g_template_obj(2).iv_setup(3).exclusion_tag    := 'PROJECT';

    g_template_obj(2).iv_setup(4).input_value_name := 'Taxable Value';
    g_template_obj(2).iv_setup(4).uom              := 'M';
    g_template_obj(2).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(2).iv_setup(4).lookup_type      := null;
    g_template_obj(2).iv_setup(4).default_value    := null;
    g_template_obj(2).iv_setup(4).def_value_column := null;
    g_template_obj(2).iv_setup(4).min_value        := null;
    g_template_obj(2).iv_setup(4).warn_or_error    := null;
    g_template_obj(2).iv_setup(4).balance_name     := 'Taxable Allowances';
    g_template_obj(2).iv_setup(4).exclusion_tag    := null;

    g_template_obj(2).iv_setup(5).input_value_name := 'Standard Taxable Value';
    g_template_obj(2).iv_setup(5).uom              := 'M';
    g_template_obj(2).iv_setup(5).mandatory_flag   := 'X';
    g_template_obj(2).iv_setup(5).lookup_type      := null;
    g_template_obj(2).iv_setup(5).default_value    := null;
    g_template_obj(2).iv_setup(5).def_value_column := null;
    g_template_obj(2).iv_setup(5).min_value        := null;
    g_template_obj(2).iv_setup(5).warn_or_error    := null;
    g_template_obj(2).iv_setup(5).balance_name     := 'Taxable Allowances for Projection';
    g_template_obj(2).iv_setup(5).exclusion_tag    := 'PROJECT';

    g_template_obj(2).iv_setup(6).input_value_name := 'Component Name';
    g_template_obj(2).iv_setup(6).uom              := 'C';
    g_template_obj(2).iv_setup(6).mandatory_flag   := 'X';
    g_template_obj(2).iv_setup(6).lookup_type      := null;
    g_template_obj(2).iv_setup(6).default_value    := null;
    g_template_obj(2).iv_setup(6).def_value_column := 'CONFIGURATION_INFORMATION1';
    g_template_obj(2).iv_setup(6).min_value        := null;
    g_template_obj(2).iv_setup(6).warn_or_error    := null;
    g_template_obj(2).iv_setup(6).balance_name     := null;
    g_template_obj(2).iv_setup(6).exclusion_tag    := null;

    g_template_obj(2).iv_setup(7).input_value_name := 'Claim Exemption Sec10';
    g_template_obj(2).iv_setup(7).uom              := 'C';
    g_template_obj(2).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(2).iv_setup(7).lookup_type      := 'YES_NO';
    g_template_obj(2).iv_setup(7).default_value    := 'Y';
    g_template_obj(2).iv_setup(7).def_value_column := null;
    g_template_obj(2).iv_setup(7).min_value        := null;
    g_template_obj(2).iv_setup(7).warn_or_error    := 'W';
    g_template_obj(2).iv_setup(7).balance_name     := null;
    g_template_obj(2).iv_setup(7).exclusion_tag    := 'EXSEC10';

    g_template_obj(2).iv_setup(8).input_value_name := 'Adjusted Amount';
    g_template_obj(2).iv_setup(8).uom              := 'M';
    g_template_obj(2).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(2).iv_setup(8).lookup_type      := null;
    g_template_obj(2).iv_setup(8).default_value    := null;
    g_template_obj(2).iv_setup(8).def_value_column := null;
    g_template_obj(2).iv_setup(8).min_value        := null;
    g_template_obj(2).iv_setup(8).warn_or_error    := null;
    g_template_obj(2).iv_setup(8).balance_name     := 'Adjusted Advance for Allowances';
    g_template_obj(2).iv_setup(8).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for Fixed Allowances Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Fixed Allowances Template start
    ----------------------------------------------------------------
    g_template_obj(2).bf_setup(1).balance_name     := 'Actual Allowance Amount';
    g_template_obj(2).bf_setup(1).iv_name          := 'Allowance Amount';
    g_template_obj(2).bf_setup(1).scale            := 1;
    g_template_obj(2).bf_setup(1).exclusion_tag    := null;



    g_template_obj(2).bf_setup(2).balance_name     := 'Outstanding Advance for Allowances';
    g_template_obj(2).bf_setup(2).iv_name          := 'Adjusted Amount';
    g_template_obj(2).bf_setup(2).scale            :=  -1;
    g_template_obj(2).bf_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Balance Feeds for Fixed Allowances Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Fixed Allowances Template starts
    ----------------------------------------------------------------
    g_template_obj(2).uf_setup.formula_name   := '_FIXED_CALC';
    g_template_obj(2).uf_setup.status_rule_id := null;
    g_template_obj(2).uf_setup.description    := 'Formula for All Fixed Allowances';

      g_template_obj(2).uf_setup.frs_setup(1).result_name      := 'TAXABLE_VALUE';
      g_template_obj(2).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(2).uf_setup.frs_setup(1).input_value_name := 'Taxable Value';
      g_template_obj(2).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(2).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(2).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(2).uf_setup.frs_setup(2).result_name      := 'ALLOWANCE_AMOUNT';
      g_template_obj(2).uf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(2).uf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(2).uf_setup.frs_setup(2).element_name     := null;
      g_template_obj(2).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(2).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(2).uf_setup.frs_setup(3).result_name      := 'STANDARD_TAXABLE_VALUE';
      g_template_obj(2).uf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(2).uf_setup.frs_setup(3).input_value_name := 'Standard Taxable Value';
      g_template_obj(2).uf_setup.frs_setup(3).element_name     := null;
      g_template_obj(2).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(2).uf_setup.frs_setup(3).exclusion_tag    := 'PROJECT';

      g_template_obj(2).uf_setup.frs_setup(4).result_name      := 'L_ERROR_MESG';
      g_template_obj(2).uf_setup.frs_setup(4).result_rule_type := 'M';
      g_template_obj(2).uf_setup.frs_setup(4).input_value_name := null;
      g_template_obj(2).uf_setup.frs_setup(4).element_name     := null;
      g_template_obj(2).uf_setup.frs_setup(4).severity_level   := 'F';
      g_template_obj(2).uf_setup.frs_setup(4).exclusion_tag    := 'EXSEC10';

      g_template_obj(2).uf_setup.frs_setup(5).result_name      := 'ADJUSTED_ADVANCE';
      g_template_obj(2).uf_setup.frs_setup(5).result_rule_type := 'D';
      g_template_obj(2).uf_setup.frs_setup(5).input_value_name := 'Adjusted Amount';
      g_template_obj(2).uf_setup.frs_setup(5).element_name     := null;
      g_template_obj(2).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(2).uf_setup.frs_setup(5).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for Fixed Allowances Template ends
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Add. Element Setup for Fixed Allowances Template starts
    ----------------------------------------------------------------
    g_template_obj(2).ae_setup(1).element_name     := ' Advance';
    g_template_obj(2).ae_setup(1).classification   := 'Advances';
    g_template_obj(2).ae_setup(1).exclusion_tag    := 'ADVANCE';
    g_template_obj(2).ae_setup(1).priority         := -2000;

      g_template_obj(2).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(2).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(2).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(2).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(2).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(2).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(2).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(2).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(2).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).iv_setup(2).input_value_name := 'Advance Amount';
      g_template_obj(2).ae_setup(1).iv_setup(2).uom              := 'M';
      g_template_obj(2).ae_setup(1).iv_setup(2).mandatory_flag   := 'N';
      g_template_obj(2).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(2).ae_setup(1).iv_setup(2).default_value    := null;
      g_template_obj(2).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(2).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(2).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(2).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(2).ae_setup(1).iv_setup(2).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).iv_setup(3).input_value_name := 'Excess Advance';
      g_template_obj(2).ae_setup(1).iv_setup(3).uom              := 'C';
      g_template_obj(2).ae_setup(1).iv_setup(3).mandatory_flag   := 'Y';
      g_template_obj(2).ae_setup(1).iv_setup(3).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(2).ae_setup(1).iv_setup(3).default_value    := 'PENDING';
      g_template_obj(2).ae_setup(1).iv_setup(3).def_value_column := null;
      g_template_obj(2).ae_setup(1).iv_setup(3).min_value        := null;
      g_template_obj(2).ae_setup(1).iv_setup(3).warn_or_error    := null;
      g_template_obj(2).ae_setup(1).iv_setup(3).balance_name     := null;
      g_template_obj(2).ae_setup(1).iv_setup(3).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).iv_setup(4).input_value_name := 'Add to Net Pay';
      g_template_obj(2).ae_setup(1).iv_setup(4).uom              := 'C';
      g_template_obj(2).ae_setup(1).iv_setup(4).mandatory_flag   := 'Y';
      g_template_obj(2).ae_setup(1).iv_setup(4).lookup_type      := 'YES_NO';
      g_template_obj(2).ae_setup(1).iv_setup(4).default_value    := 'Y';
      g_template_obj(2).ae_setup(1).iv_setup(4).def_value_column := null;
      g_template_obj(2).ae_setup(1).iv_setup(4).min_value        := null;
      g_template_obj(2).ae_setup(1).iv_setup(4).warn_or_error    := null;
      g_template_obj(2).ae_setup(1).iv_setup(4).balance_name     := null;
      g_template_obj(2).ae_setup(1).iv_setup(4).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).iv_setup(5).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(1).iv_setup(5).uom              := 'C';
      g_template_obj(2).ae_setup(1).iv_setup(5).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(1).iv_setup(5).lookup_type      := null;
      g_template_obj(2).ae_setup(1).iv_setup(5).default_value    := null;
      g_template_obj(2).ae_setup(1).iv_setup(5).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(2).ae_setup(1).iv_setup(5).min_value        := null;
      g_template_obj(2).ae_setup(1).iv_setup(5).warn_or_error    := null;
      g_template_obj(2).ae_setup(1).iv_setup(5).balance_name     := null;
      g_template_obj(2).ae_setup(1).iv_setup(5).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).bf_setup(1).balance_name     := 'Advance for Allowances';
      g_template_obj(2).ae_setup(1).bf_setup(1).iv_name          := 'Advance Amount';
      g_template_obj(2).ae_setup(1).bf_setup(1).scale            := 1;
      g_template_obj(2).ae_setup(1).bf_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).bf_setup(2).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(2).ae_setup(1).bf_setup(2).iv_name          := 'Advance Amount';
      g_template_obj(2).ae_setup(1).bf_setup(2).scale            := 1;
      g_template_obj(2).ae_setup(1).bf_setup(2).exclusion_tag    := null;

    g_template_obj(2).ae_setup(1).uf_setup.formula_name   := '_FX_ADV_CALC';
    g_template_obj(2).ae_setup(1).uf_setup.status_rule_id := null;
    g_template_obj(2).ae_setup(1).uf_setup.description    := 'Advance Calculations for Fixed Allowances';


      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(1).result_name      := 'PAYABLE_VALUE';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(2).result_name      := 'EXCESS_ADVANCE';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(2).input_value_name := 'Excess Advance';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(2).element_name     := ' Excess Advance';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(3).result_name      := 'COMPONENT_NAME';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(3).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(3).element_name     := ' Excess Advance';
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(2).ae_setup(1).uf_setup.frs_setup(3).exclusion_tag    := null;



    g_template_obj(2).ae_setup(2).element_name     := ' Adjust';
    g_template_obj(2).ae_setup(2).classification   := 'Earnings';
    g_template_obj(2).ae_setup(2).exclusion_tag    := 'ADVANCE';
    g_template_obj(2).ae_setup(2).priority         := 12000;

      g_template_obj(2).ae_setup(2).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(2).ae_setup(2).iv_setup(1).uom              := 'M';
      g_template_obj(2).ae_setup(2).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(2).iv_setup(1).lookup_type      := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).default_value    := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).def_value_column := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).min_value        := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).warn_or_error    := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).balance_name     := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(2).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(2).iv_setup(2).uom              := 'C';
      g_template_obj(2).ae_setup(2).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(2).iv_setup(2).lookup_type      := null;
      g_template_obj(2).ae_setup(2).iv_setup(2).default_value    := null;
      g_template_obj(2).ae_setup(2).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(2).ae_setup(2).iv_setup(2).min_value        := null;
      g_template_obj(2).ae_setup(2).iv_setup(2).warn_or_error    := null;
      g_template_obj(2).ae_setup(2).iv_setup(2).balance_name     := null;
      g_template_obj(2).ae_setup(2).iv_setup(2).exclusion_tag    := null;

      g_template_obj(2).ae_setup(2).bf_setup(1).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(2).ae_setup(2).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(2).ae_setup(2).bf_setup(1).scale            := -1;
      g_template_obj(2).ae_setup(2).bf_setup(1).exclusion_tag    := null;

    g_template_obj(2).ae_setup(3).element_name     := ' Recover';
    g_template_obj(2).ae_setup(3).classification   := 'Voluntary Deductions';
    g_template_obj(2).ae_setup(3).exclusion_tag    := 'ADVANCE';
    g_template_obj(2).ae_setup(3).priority         := 36000;

      g_template_obj(2).ae_setup(3).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(2).ae_setup(3).iv_setup(1).uom              := 'M';
      g_template_obj(2).ae_setup(3).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(3).iv_setup(1).lookup_type      := null;
      g_template_obj(2).ae_setup(3).iv_setup(1).default_value    := null;
      g_template_obj(2).ae_setup(2).iv_setup(1).def_value_column := null;
      g_template_obj(2).ae_setup(3).iv_setup(1).min_value        := null;
      g_template_obj(2).ae_setup(3).iv_setup(1).warn_or_error    := null;
      g_template_obj(2).ae_setup(3).iv_setup(1).balance_name     := null;
      g_template_obj(2).ae_setup(3).iv_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(3).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(3).iv_setup(2).uom              := 'C';
      g_template_obj(2).ae_setup(3).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(3).iv_setup(2).lookup_type      := null;
      g_template_obj(2).ae_setup(3).iv_setup(2).default_value    := null;
      g_template_obj(2).ae_setup(3).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(2).ae_setup(3).iv_setup(2).min_value        := null;
      g_template_obj(2).ae_setup(3).iv_setup(2).warn_or_error    := null;
      g_template_obj(2).ae_setup(3).iv_setup(2).balance_name     := null;
      g_template_obj(2).ae_setup(3).iv_setup(2).exclusion_tag    := null;

      g_template_obj(2).ae_setup(3).iv_setup(3).input_value_name := 'Adjustment Amount';
      g_template_obj(2).ae_setup(3).iv_setup(3).uom              := 'M';
      g_template_obj(2).ae_setup(3).iv_setup(3).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(3).iv_setup(3).lookup_type      := null;
      g_template_obj(2).ae_setup(3).iv_setup(3).default_value    := null;
      g_template_obj(2).ae_setup(3).iv_setup(3).def_value_column := null;
      g_template_obj(2).ae_setup(3).iv_setup(3).min_value        := null;
      g_template_obj(2).ae_setup(3).iv_setup(3).warn_or_error    := null;
      g_template_obj(2).ae_setup(3).iv_setup(3).balance_name     := null;
      g_template_obj(2).ae_setup(3).iv_setup(3).exclusion_tag    := null;

      g_template_obj(2).ae_setup(3).bf_setup(1).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(2).ae_setup(3).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(2).ae_setup(3).bf_setup(1).scale            := -1;
      g_template_obj(2).ae_setup(3).bf_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(3).bf_setup(2).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(2).ae_setup(3).bf_setup(2).iv_name          := 'Adjustment Amount';
      g_template_obj(2).ae_setup(3).bf_setup(2).scale            := 1;
      g_template_obj(2).ae_setup(3).bf_setup(2).exclusion_tag    := null;

    g_template_obj(2).ae_setup(4).element_name     := ' Excess Advance';
    g_template_obj(2).ae_setup(4).classification   := 'Information';
    g_template_obj(2).ae_setup(4).exclusion_tag    := 'ADVANCE';
    g_template_obj(2).ae_setup(4).priority         := 11000;

      g_template_obj(2).ae_setup(4).iv_setup(1).input_value_name := 'Excess Advance';
      g_template_obj(2).ae_setup(4).iv_setup(1).uom              := 'C';
      g_template_obj(2).ae_setup(4).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(4).iv_setup(1).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(2).ae_setup(4).iv_setup(1).default_value    := 'PENDING';
      g_template_obj(2).ae_setup(4).iv_setup(1).def_value_column := null;
      g_template_obj(2).ae_setup(4).iv_setup(1).min_value        := null;
      g_template_obj(2).ae_setup(4).iv_setup(1).warn_or_error    := null;
      g_template_obj(2).ae_setup(4).iv_setup(1).balance_name     := null;
      g_template_obj(2).ae_setup(4).iv_setup(1).exclusion_tag    := null;

      g_template_obj(2).ae_setup(4).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(4).iv_setup(2).uom              := 'C';
      g_template_obj(2).ae_setup(4).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(2).ae_setup(4).iv_setup(2).lookup_type      := null;
      g_template_obj(2).ae_setup(4).iv_setup(2).default_value    := null;
      g_template_obj(2).ae_setup(4).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(2).ae_setup(4).iv_setup(2).min_value        := null;
      g_template_obj(2).ae_setup(4).iv_setup(2).warn_or_error    := null;
      g_template_obj(2).ae_setup(4).iv_setup(2).balance_name     := null;
      g_template_obj(2).ae_setup(4).iv_setup(2).exclusion_tag    := null;

    g_template_obj(2).ae_setup(4).uf_setup.formula_name   := '_FX_EXC_ADV';
    g_template_obj(2).ae_setup(4).uf_setup.status_rule_id := null;
    g_template_obj(2).ae_setup(4).uf_setup.description    := 'Excess Advance Calculations for Fixed allowances';

      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(1).result_name      := 'ADJUSTMENT_AMT';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(1).result_rule_type := 'I';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(1).input_value_name := 'Adjustment Amount';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(1).element_name     := ' Recover';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(1).exclusion_tag    := null;


      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(2).result_name      := 'RECOVERED_ADVANCE';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(2).element_name     := ' Recover';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(3).result_name      := 'SALARY_SEC171';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(3).input_value_name := 'Pay Value';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(3).element_name     := ' Adjust';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(4).result_name      := 'COMPONENT_NAME_PAY';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(4).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(4).element_name     := ' Adjust';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(5).result_name      := 'COMPONENT_NAME_REC';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(5).input_value_name := 'Component Name';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(5).element_name     := ' Recover';
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(2).ae_setup(4).uf_setup.frs_setup(5).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Add. Element Setup for Fixed Allowances Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR FIXED ALLOWANCES ENDS
  ----------------------------------------------------------------

    ----------------------------------------------------------------
  --  TEMPLATE FOR ACTUAL EXPENDITURE ALLOWANCE STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,40);
  g_template_obj(3).template_name  := 'Actual Expense Allowances';
  g_template_obj(3).category       := 'Allowances';
  g_template_obj(3).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Actual Expense Template start
    ----------------------------------------------------------------
    g_template_obj(3).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(3).er_setup(1).value     := 'N';
    g_template_obj(3).er_setup(1).descr     := 'Exclusion rule for Expense Projections.';
    g_template_obj(3).er_setup(1).tag       := 'PROJEXP';
    g_template_obj(3).er_setup(1).rule_id   :=  null;

    g_template_obj(3).er_setup(2).ff_column := 'CONFIGURATION_INFORMATION3';
    g_template_obj(3).er_setup(2).value     := 'N';
    g_template_obj(3).er_setup(2).descr     := 'Exclusion rule for Advances';
    g_template_obj(3).er_setup(2).tag       := 'ADVANCE';
    g_template_obj(3).er_setup(2).rule_id   :=  null;

    g_template_obj(3).er_setup(3).ff_column := 'CONFIGURATION_INFORMATION4';
    g_template_obj(3).er_setup(3).value     := 'N';
    g_template_obj(3).er_setup(3).descr     := 'Exclusion rule for Projections';
    g_template_obj(3).er_setup(3).tag       := 'PROJECT';
    g_template_obj(3).er_setup(3).rule_id   :=  null;

    g_template_obj(3).er_setup(4).ff_column := 'CONFIGURATION_INFORMATION5';
    g_template_obj(3).er_setup(4).value     := 'N';
    g_template_obj(3).er_setup(4).descr     := 'Exclusion rule for Expense Element';
    g_template_obj(3).er_setup(4).tag       := 'EXPELMT';
    g_template_obj(3).er_setup(4).rule_id   :=  null;

    g_template_obj(3).er_setup(5).ff_column := 'CONFIGURATION_INFORMATION6';
    g_template_obj(3).er_setup(5).value     := 'N';
    g_template_obj(3).er_setup(5).descr     := 'Exclusion rule for HRA';
    g_template_obj(3).er_setup(5).tag       := 'HRALLWN';
    g_template_obj(3).er_setup(5).rule_id   :=  null;

    g_template_obj(3).er_setup(6).ff_column := 'CONFIGURATION_INFORMATION7';
    g_template_obj(3).er_setup(6).value     := 'N';
    g_template_obj(3).er_setup(6).descr     := 'Exclusion rule for Ent';
    g_template_obj(3).er_setup(6).tag       := 'ENTALWN';
    g_template_obj(3).er_setup(6).rule_id   :=  null;

    g_template_obj(3).er_setup(7).ff_column := 'CONFIGURATION_INFORMATION8';
    g_template_obj(3).er_setup(7).value     := 'N';
    g_template_obj(3).er_setup(7).descr     := 'Exclusion rule for HRA + Advance';
    g_template_obj(3).er_setup(7).tag       := 'HRAADVN';
    g_template_obj(3).er_setup(7).rule_id   :=  null;

    g_template_obj(3).er_setup(8).ff_column := 'CONFIGURATION_INFORMATION9';
    g_template_obj(3).er_setup(8).value     := 'N';
    g_template_obj(3).er_setup(8).descr     := 'Exclusion rule for Ent + Advance';
    g_template_obj(3).er_setup(8).tag       := 'ENTADVN';
    g_template_obj(3).er_setup(8).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for Actual Expense Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Actual Expense Template start
    ----------------------------------------------------------------
    g_template_obj(3).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(3).iv_setup(1).uom              := 'M';
    g_template_obj(3).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(3).iv_setup(1).lookup_type      := null;
    g_template_obj(3).iv_setup(1).default_value    := null;
    g_template_obj(3).iv_setup(1).def_value_column := null;
    g_template_obj(3).iv_setup(1).min_value        := null;
    g_template_obj(3).iv_setup(1).warn_or_error    := null;
    g_template_obj(3).iv_setup(1).balance_name     := null;
    g_template_obj(3).iv_setup(1).exclusion_tag    := null;

    g_template_obj(3).iv_setup(2).input_value_name := 'Allowance Amount';
    g_template_obj(3).iv_setup(2).uom              := 'M';
    g_template_obj(3).iv_setup(2).mandatory_flag   := 'Y';
    g_template_obj(3).iv_setup(2).lookup_type      := null;
    g_template_obj(3).iv_setup(2).default_value    := null;
    g_template_obj(3).iv_setup(2).def_value_column := null;
    g_template_obj(3).iv_setup(2).min_value        := null;
    g_template_obj(3).iv_setup(2).warn_or_error    := null;
    g_template_obj(3).iv_setup(2).balance_name     := null;
    g_template_obj(3).iv_setup(2).exclusion_tag    := null;

    g_template_obj(3).iv_setup(3).input_value_name := 'Standard Value';
    g_template_obj(3).iv_setup(3).uom              := 'M';
    g_template_obj(3).iv_setup(3).mandatory_flag   := 'Y';
    g_template_obj(3).iv_setup(3).lookup_type      := null;
    g_template_obj(3).iv_setup(3).default_value    := null;
    g_template_obj(3).iv_setup(3).def_value_column := null;
    g_template_obj(3).iv_setup(3).min_value        := null;
    g_template_obj(3).iv_setup(3).warn_or_error    := null;
    g_template_obj(3).iv_setup(3).balance_name     := 'Allowances Standard Value';
    g_template_obj(3).iv_setup(3).exclusion_tag    := 'PROJECT';

    g_template_obj(3).iv_setup(4).input_value_name := 'Taxable Value';
    g_template_obj(3).iv_setup(4).uom              := 'M';
    g_template_obj(3).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(3).iv_setup(4).lookup_type      := null;
    g_template_obj(3).iv_setup(4).default_value    := null;
    g_template_obj(3).iv_setup(4).def_value_column := null;
    g_template_obj(3).iv_setup(4).min_value        := null;
    g_template_obj(3).iv_setup(4).warn_or_error    := null;
    g_template_obj(3).iv_setup(4).balance_name     := 'Taxable Allowances';
    g_template_obj(3).iv_setup(4).exclusion_tag    := null;

    g_template_obj(3).iv_setup(5).input_value_name := 'Standard Taxable Value';
    g_template_obj(3).iv_setup(5).uom              := 'M';
    g_template_obj(3).iv_setup(5).mandatory_flag   := 'X';
    g_template_obj(3).iv_setup(5).lookup_type      := null;
    g_template_obj(3).iv_setup(5).default_value    := null;
    g_template_obj(3).iv_setup(5).def_value_column := null;
    g_template_obj(3).iv_setup(5).min_value        := null;
    g_template_obj(3).iv_setup(5).warn_or_error    := null;
    g_template_obj(3).iv_setup(5).balance_name     := 'Taxable Allowances for Projection';
    g_template_obj(3).iv_setup(5).exclusion_tag    := 'PROJECT';

    g_template_obj(3).iv_setup(6).input_value_name := 'Component Name';
    g_template_obj(3).iv_setup(6).uom              := 'C';
    g_template_obj(3).iv_setup(6).mandatory_flag   := 'X';
    g_template_obj(3).iv_setup(6).lookup_type      := null;
    g_template_obj(3).iv_setup(6).default_value    := null;
    g_template_obj(3).iv_setup(6).def_value_column := 'CONFIGURATION_INFORMATION1';
    g_template_obj(3).iv_setup(6).min_value        := null;
    g_template_obj(3).iv_setup(6).warn_or_error    := null;
    g_template_obj(3).iv_setup(6).balance_name     := null;
    g_template_obj(3).iv_setup(6).exclusion_tag    := null;

    g_template_obj(3).iv_setup(7).input_value_name := 'Actual Expenditure';
    g_template_obj(3).iv_setup(7).uom              := 'M';
    g_template_obj(3).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(3).iv_setup(7).lookup_type      := null;
    g_template_obj(3).iv_setup(7).default_value    := null;
    g_template_obj(3).iv_setup(7).def_value_column := null;
    g_template_obj(3).iv_setup(7).min_value        := 0;
    g_template_obj(3).iv_setup(7).warn_or_error    := 'E';
    g_template_obj(3).iv_setup(7).balance_name     := 'Allowance Expense Amount';
    g_template_obj(3).iv_setup(7).exclusion_tag    := 'PROJEXP';

    g_template_obj(3).iv_setup(8).input_value_name := 'Adjusted Amount';
    g_template_obj(3).iv_setup(8).uom              := 'M';
    g_template_obj(3).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(3).iv_setup(8).lookup_type      := null;
    g_template_obj(3).iv_setup(8).default_value    := null;
    g_template_obj(3).iv_setup(8).def_value_column := null;
    g_template_obj(3).iv_setup(8).min_value        := null;
    g_template_obj(3).iv_setup(8).warn_or_error    := null;
    g_template_obj(3).iv_setup(8).balance_name     := null;
    g_template_obj(3).iv_setup(8).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Input Values for Actual Expense Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Actual Expense Template start
    ----------------------------------------------------------------
    g_template_obj(3).bf_setup(1).balance_name     := 'Actual Allowance Amount';
    g_template_obj(3).bf_setup(1).iv_name          := 'Allowance Amount';
    g_template_obj(3).bf_setup(1).scale            := 1;
    g_template_obj(3).bf_setup(1).exclusion_tag    := null;

    g_template_obj(3).bf_setup(2).balance_name     := 'Adjusted Advance for Allowances';
    g_template_obj(3).bf_setup(2).iv_name          := 'Adjusted Amount';
    g_template_obj(3).bf_setup(2).scale            := 1;
    g_template_obj(3).bf_setup(2).exclusion_tag    := null;

    g_template_obj(3).bf_setup(3).balance_name     := 'Standard House Rent Allowance';
    g_template_obj(3).bf_setup(3).iv_name          := 'Standard Value';
    g_template_obj(3).bf_setup(3).scale            := 1;
    g_template_obj(3).bf_setup(3).exclusion_tag    := 'HRALLWN';

    g_template_obj(3).bf_setup(4).balance_name     := 'Standard Entertainment Allowance';
    g_template_obj(3).bf_setup(4).iv_name          := 'Standard Value';
    g_template_obj(3).bf_setup(4).scale            := 1;
    g_template_obj(3).bf_setup(4).exclusion_tag    := 'ENTALWN';

    g_template_obj(3).bf_setup(5).balance_name     := 'Entertainment Allowance';
    g_template_obj(3).bf_setup(5).iv_name          := 'Pay Value';
    g_template_obj(3).bf_setup(5).scale            := 1;
    g_template_obj(3).bf_setup(5).exclusion_tag    := 'ENTALWN';

    g_template_obj(3).bf_setup(6).balance_name     := 'Adjusted Advance for HRA';
    g_template_obj(3).bf_setup(6).iv_name          := 'Adjusted Amount';
    g_template_obj(3).bf_setup(6).scale            := 1;
    g_template_obj(3).bf_setup(6).exclusion_tag    := 'HRALLWN';

    g_template_obj(3).bf_setup(7).balance_name     := 'Adjusted Advance for Entertainment Allowance';
    g_template_obj(3).bf_setup(7).iv_name          := 'Adjusted Amount';
    g_template_obj(3).bf_setup(7).scale            := 1;
    g_template_obj(3).bf_setup(7).exclusion_tag    := 'ENTALWN';

    g_template_obj(3).bf_setup(8).balance_name     := 'Outstanding Advance for Allowances';
    g_template_obj(3).bf_setup(8).iv_name          := 'Adjusted Amount';
    g_template_obj(3).bf_setup(8).scale            := -1;
    g_template_obj(3).bf_setup(8).exclusion_tag    := null;

    g_template_obj(3).bf_setup(9).balance_name     := 'House Rent Allowance';
    g_template_obj(3).bf_setup(9).iv_name          := 'Pay Value';
    g_template_obj(3).bf_setup(9).scale            := 1;
    g_template_obj(3).bf_setup(9).exclusion_tag    := 'HRALLWN';

    ----------------------------------------------------------------
    --  Balance Feeds for Actual Expense Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Actual Expense Template starts
    ----------------------------------------------------------------
    g_template_obj(3).uf_setup.formula_name   := '_ACTEXP_CALC';
    g_template_obj(3).uf_setup.status_rule_id := null;
    g_template_obj(3).uf_setup.description    := 'Formula for Actual Expense Allowances';

      g_template_obj(3).uf_setup.frs_setup(1).result_name      := 'TAXABLE_VALUE';
      g_template_obj(3).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(3).uf_setup.frs_setup(1).input_value_name := 'Taxable Value';
      g_template_obj(3).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(3).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(3).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(3).uf_setup.frs_setup(2).result_name      := 'ALLOWANCE_AMOUNT';
      g_template_obj(3).uf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(3).uf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(3).uf_setup.frs_setup(2).element_name     := null;
      g_template_obj(3).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(3).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(3).uf_setup.frs_setup(3).result_name      := 'STANDARD_TAXABLE_VALUE';
      g_template_obj(3).uf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(3).uf_setup.frs_setup(3).input_value_name := 'Standard Taxable Value';
      g_template_obj(3).uf_setup.frs_setup(3).element_name     := null;
      g_template_obj(3).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(3).uf_setup.frs_setup(3).exclusion_tag    := 'PROJECT';

      g_template_obj(3).uf_setup.frs_setup(4).result_name      := 'ADJUSTED_ADVANCE';
      g_template_obj(3).uf_setup.frs_setup(4).result_rule_type := 'D';
      g_template_obj(3).uf_setup.frs_setup(4).input_value_name := 'Adjusted Amount';
      g_template_obj(3).uf_setup.frs_setup(4).element_name     := null;
      g_template_obj(3).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(3).uf_setup.frs_setup(4).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Formula Setup for Actual Expense Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Actual Expense Template starts
    ----------------------------------------------------------------
    g_template_obj(3).ae_setup(1).element_name     := ' Expense';
    g_template_obj(3).ae_setup(1).classification   := 'Information';
    g_template_obj(3).ae_setup(1).exclusion_tag    := 'EXPELMT';
    g_template_obj(3).ae_setup(1).priority         := -8000;


      g_template_obj(3).ae_setup(1).iv_setup(1).input_value_name := 'Expense Amount';
      g_template_obj(3).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(3).ae_setup(1).iv_setup(1).mandatory_flag   := 'Y';
      g_template_obj(3).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(3).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(3).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(3).ae_setup(1).iv_setup(1).min_value        := 0;
      g_template_obj(3).ae_setup(1).iv_setup(1).warn_or_error    := 'E';
      g_template_obj(3).ae_setup(1).iv_setup(1).balance_name     := 'Allowance Expense Amount';
      g_template_obj(3).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(1).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(1).iv_setup(2).uom              := 'C';
      g_template_obj(3).ae_setup(1).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(3).ae_setup(1).iv_setup(2).default_value    := null;
      g_template_obj(3).ae_setup(1).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(3).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(3).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(3).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(3).ae_setup(1).iv_setup(2).exclusion_tag    := null;

    g_template_obj(3).ae_setup(2).element_name     := ' Advance';
    g_template_obj(3).ae_setup(2).classification   := 'Advances';
    g_template_obj(3).ae_setup(2).exclusion_tag    := 'ADVANCE';
    g_template_obj(3).ae_setup(2).priority         := -2000;

      g_template_obj(3).ae_setup(2).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(3).ae_setup(2).iv_setup(1).uom              := 'M';
      g_template_obj(3).ae_setup(2).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(2).iv_setup(1).lookup_type      := null;
      g_template_obj(3).ae_setup(2).iv_setup(1).default_value    := null;
      g_template_obj(3).ae_setup(2).iv_setup(1).def_value_column := null;
      g_template_obj(3).ae_setup(2).iv_setup(1).min_value        := null;
      g_template_obj(3).ae_setup(2).iv_setup(1).warn_or_error    := null;
      g_template_obj(3).ae_setup(2).iv_setup(1).balance_name     := null;
      g_template_obj(3).ae_setup(2).iv_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).iv_setup(2).input_value_name := 'Advance Amount';
      g_template_obj(3).ae_setup(2).iv_setup(2).uom              := 'M';
      g_template_obj(3).ae_setup(2).iv_setup(2).mandatory_flag   := 'N';
      g_template_obj(3).ae_setup(2).iv_setup(2).lookup_type      := null;
      g_template_obj(3).ae_setup(2).iv_setup(2).default_value    := null;
      g_template_obj(3).ae_setup(2).iv_setup(2).def_value_column := null;
      g_template_obj(3).ae_setup(2).iv_setup(2).min_value        := null;
      g_template_obj(3).ae_setup(2).iv_setup(2).warn_or_error    := null;
      g_template_obj(3).ae_setup(2).iv_setup(2).balance_name     := null;
      g_template_obj(3).ae_setup(2).iv_setup(2).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).iv_setup(3).input_value_name := 'Excess Advance';
      g_template_obj(3).ae_setup(2).iv_setup(3).uom              := 'C';
      g_template_obj(3).ae_setup(2).iv_setup(3).mandatory_flag   := 'Y';
      g_template_obj(3).ae_setup(2).iv_setup(3).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(3).ae_setup(2).iv_setup(3).default_value    := 'PENDING';
      g_template_obj(3).ae_setup(2).iv_setup(3).def_value_column := null;
      g_template_obj(3).ae_setup(2).iv_setup(3).min_value        := null;
      g_template_obj(3).ae_setup(2).iv_setup(3).warn_or_error    := null;
      g_template_obj(3).ae_setup(2).iv_setup(3).balance_name     := null;
      g_template_obj(3).ae_setup(2).iv_setup(3).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).iv_setup(4).input_value_name := 'Add to Net Pay';
      g_template_obj(3).ae_setup(2).iv_setup(4).uom              := 'C';
      g_template_obj(3).ae_setup(2).iv_setup(4).mandatory_flag   := 'Y';
      g_template_obj(3).ae_setup(2).iv_setup(4).lookup_type      := 'YES_NO';
      g_template_obj(3).ae_setup(2).iv_setup(4).default_value    := 'Y';
      g_template_obj(3).ae_setup(2).iv_setup(4).def_value_column := null;
      g_template_obj(3).ae_setup(2).iv_setup(4).min_value        := null;
      g_template_obj(3).ae_setup(2).iv_setup(4).warn_or_error    := null;
      g_template_obj(3).ae_setup(2).iv_setup(4).balance_name     := null;
      g_template_obj(3).ae_setup(2).iv_setup(4).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).iv_setup(5).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(2).iv_setup(5).uom              := 'C';
      g_template_obj(3).ae_setup(2).iv_setup(5).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(2).iv_setup(5).lookup_type      := null;
      g_template_obj(3).ae_setup(2).iv_setup(5).default_value    := null;
      g_template_obj(3).ae_setup(2).iv_setup(5).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(3).ae_setup(2).iv_setup(5).min_value        := null;
      g_template_obj(3).ae_setup(2).iv_setup(5).warn_or_error    := null;
      g_template_obj(3).ae_setup(2).iv_setup(5).balance_name     := null;
      g_template_obj(3).ae_setup(2).iv_setup(5).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).bf_setup(1).balance_name     := 'Advance for Allowances';
      g_template_obj(3).ae_setup(2).bf_setup(1).iv_name          := 'Advance Amount';
      g_template_obj(3).ae_setup(2).bf_setup(1).scale            := 1;
      g_template_obj(3).ae_setup(2).bf_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).bf_setup(2).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(3).ae_setup(2).bf_setup(2).iv_name          := 'Advance Amount';
      g_template_obj(3).ae_setup(2).bf_setup(2).scale            := 1;
      g_template_obj(3).ae_setup(2).bf_setup(2).exclusion_tag    := null;

    g_template_obj(3).ae_setup(2).uf_setup.formula_name   := '_AE_ADV_CALC';
    g_template_obj(3).ae_setup(2).uf_setup.status_rule_id := null;
    g_template_obj(3).ae_setup(2).uf_setup.description    := 'Advance Calculations for Fixed Allowances';


      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(1).result_name      := 'PAYABLE_VALUE';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(2).result_name      := 'EXCESS_ADVANCE';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(2).input_value_name := 'Excess Advance';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(2).element_name     := ' Excess Advance';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(2).exclusion_tag    := null;


      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(3).result_name      := 'COMPONENT_NAME';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(3).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(3).element_name     := ' Excess Advance';
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(3).ae_setup(2).uf_setup.frs_setup(3).exclusion_tag    := null;


    g_template_obj(3).ae_setup(3).element_name     := ' Adjust';
    g_template_obj(3).ae_setup(3).classification   := 'Earnings';
    g_template_obj(3).ae_setup(3).exclusion_tag    := 'ADVANCE';
    g_template_obj(3).ae_setup(3).priority         := 14000;

      g_template_obj(3).ae_setup(3).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(3).ae_setup(3).iv_setup(1).uom              := 'M';
      g_template_obj(3).ae_setup(3).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(3).iv_setup(1).lookup_type      := null;
      g_template_obj(3).ae_setup(3).iv_setup(1).default_value    := null;
      g_template_obj(3).ae_setup(3).iv_setup(1).def_value_column := null;
      g_template_obj(3).ae_setup(3).iv_setup(1).min_value        := null;
      g_template_obj(3).ae_setup(3).iv_setup(1).warn_or_error    := null;
      g_template_obj(3).ae_setup(3).iv_setup(1).balance_name     := null;
      g_template_obj(3).ae_setup(3).iv_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(3).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(3).iv_setup(2).uom              := 'C';
      g_template_obj(3).ae_setup(3).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(3).iv_setup(2).lookup_type      := null;
      g_template_obj(3).ae_setup(3).iv_setup(2).default_value    := null;
      g_template_obj(3).ae_setup(3).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(3).ae_setup(3).iv_setup(2).min_value        := null;
      g_template_obj(3).ae_setup(3).iv_setup(2).warn_or_error    := null;
      g_template_obj(3).ae_setup(3).iv_setup(2).balance_name     := null;
      g_template_obj(3).ae_setup(3).iv_setup(2).exclusion_tag    := null;

      g_template_obj(3).ae_setup(3).bf_setup(1).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(3).ae_setup(3).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(3).ae_setup(3).bf_setup(1).scale            := -1;
      g_template_obj(3).ae_setup(3).bf_setup(1).exclusion_tag    := null;

    g_template_obj(3).ae_setup(4).element_name     := ' Recover';
    g_template_obj(3).ae_setup(4).classification   := 'Voluntary Deductions';
    g_template_obj(3).ae_setup(4).exclusion_tag    := 'ADVANCE';
    g_template_obj(3).ae_setup(4).priority         := 36000;

      g_template_obj(3).ae_setup(4).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(3).ae_setup(4).iv_setup(1).uom              := 'M';
      g_template_obj(3).ae_setup(4).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(4).iv_setup(1).lookup_type      := null;
      g_template_obj(3).ae_setup(4).iv_setup(1).default_value    := null;
      g_template_obj(3).ae_setup(4).iv_setup(1).def_value_column := null;
      g_template_obj(3).ae_setup(4).iv_setup(1).min_value        := null;
      g_template_obj(3).ae_setup(4).iv_setup(1).warn_or_error    := null;
      g_template_obj(3).ae_setup(4).iv_setup(1).balance_name     := null;
      g_template_obj(3).ae_setup(4).iv_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(4).iv_setup(2).input_value_name := 'Adjustment Amount';
      g_template_obj(3).ae_setup(4).iv_setup(2).uom              := 'M';
      g_template_obj(3).ae_setup(4).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(4).iv_setup(2).lookup_type      := null;
      g_template_obj(3).ae_setup(4).iv_setup(2).default_value    := null;
      g_template_obj(3).ae_setup(4).iv_setup(2).def_value_column := null;
      g_template_obj(3).ae_setup(4).iv_setup(2).min_value        := null;
      g_template_obj(3).ae_setup(4).iv_setup(2).warn_or_error    := null;
      g_template_obj(3).ae_setup(4).iv_setup(2).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(3).ae_setup(4).iv_setup(2).exclusion_tag    := 'ADVANCE';

      g_template_obj(3).ae_setup(4).iv_setup(3).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(4).iv_setup(3).uom              := 'C';
      g_template_obj(3).ae_setup(4).iv_setup(3).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(4).iv_setup(3).lookup_type      := null;
      g_template_obj(3).ae_setup(4).iv_setup(3).default_value    := null;
      g_template_obj(3).ae_setup(4).iv_setup(3).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(3).ae_setup(4).iv_setup(3).min_value        := null;
      g_template_obj(3).ae_setup(4).iv_setup(3).warn_or_error    := null;
      g_template_obj(3).ae_setup(4).iv_setup(3).balance_name     := null;
      g_template_obj(3).ae_setup(4).iv_setup(3).exclusion_tag    := null;

      g_template_obj(3).ae_setup(4).bf_setup(1).balance_name     := 'Outstanding Advance for Allowances';
      g_template_obj(3).ae_setup(4).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(3).ae_setup(4).bf_setup(1).scale            := -1;
      g_template_obj(3).ae_setup(4).bf_setup(1).exclusion_tag    := null;

    g_template_obj(3).ae_setup(5).element_name     := ' Excess Advance';
    g_template_obj(3).ae_setup(5).classification   := 'Information';
    g_template_obj(3).ae_setup(5).exclusion_tag    := 'ADVANCE';
    g_template_obj(3).ae_setup(5).priority         := 12000;

      g_template_obj(3).ae_setup(5).iv_setup(1).input_value_name := 'Excess Advance';
      g_template_obj(3).ae_setup(5).iv_setup(1).uom              := 'C';
      g_template_obj(3).ae_setup(5).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(5).iv_setup(1).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(3).ae_setup(5).iv_setup(1).default_value    := 'PENDING';
      g_template_obj(3).ae_setup(5).iv_setup(1).def_value_column := null;
      g_template_obj(3).ae_setup(5).iv_setup(1).min_value        := null;
      g_template_obj(3).ae_setup(5).iv_setup(1).warn_or_error    := null;
      g_template_obj(3).ae_setup(5).iv_setup(1).balance_name     := null;
      g_template_obj(3).ae_setup(5).iv_setup(1).exclusion_tag    := null;

      g_template_obj(3).ae_setup(5).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(5).iv_setup(2).uom              := 'C';
      g_template_obj(3).ae_setup(5).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(3).ae_setup(5).iv_setup(2).lookup_type      := null;
      g_template_obj(3).ae_setup(5).iv_setup(2).default_value    := null;
      g_template_obj(3).ae_setup(5).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(3).ae_setup(5).iv_setup(2).min_value        := null;
      g_template_obj(3).ae_setup(5).iv_setup(2).warn_or_error    := null;
      g_template_obj(3).ae_setup(5).iv_setup(2).balance_name     := null;
      g_template_obj(3).ae_setup(5).iv_setup(2).exclusion_tag    := null;

    g_template_obj(3).ae_setup(5).uf_setup.formula_name   := '_AE_EXC_ADV';
    g_template_obj(3).ae_setup(5).uf_setup.status_rule_id := null;
    g_template_obj(3).ae_setup(5).uf_setup.description    := 'Excess Advance Calculations for Actual allowances';

      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(1).result_name      := 'ADJUSTMENT_AMT';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(1).result_rule_type := 'I';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(1).input_value_name := 'Adjustment Amount';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(1).element_name     := ' Recover';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(1).exclusion_tag    := null;


      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(2).result_name      := 'RECOVERED_ADVANCE';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(2).element_name     := ' Recover';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(3).result_name      := 'SALARY_SEC171';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(3).input_value_name := 'Pay Value';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(3).element_name     := ' Adjust';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(4).result_name      := 'COMPONENT_NAME_PAY';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(4).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(4).element_name     := ' Adjust';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(5).result_name      := 'COMPONENT_NAME_REC';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(5).input_value_name := 'Component Name';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(5).element_name     := ' Recover';
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(3).ae_setup(5).uf_setup.frs_setup(5).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Add. Element Setup for Actual Expense Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR ACTUAL EXPENDITURE ALLOWANCE ENDS
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR FREE EDUCATION STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,50);
  g_template_obj(4).template_name  := 'Free Education';
  g_template_obj(4).category       := 'Perquisites';
  g_template_obj(4).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Free Education Template start
    ----------------------------------------------------------------
    g_template_obj(4).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(4).er_setup(1).value     := 'N';
    g_template_obj(4).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(4).er_setup(1).tag       := 'PROJECT';
    g_template_obj(4).er_setup(1).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for Free Education Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Free Education Template start
    ----------------------------------------------------------------
    g_template_obj(4).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(4).iv_setup(1).uom              := 'M';
    g_template_obj(4).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(4).iv_setup(1).lookup_type      := null;
    g_template_obj(4).iv_setup(1).default_value    := null;
    g_template_obj(4).iv_setup(1).def_value_column := null;
    g_template_obj(4).iv_setup(1).min_value        := null;
    g_template_obj(4).iv_setup(1).warn_or_error    := null;
    g_template_obj(4).iv_setup(1).balance_name     := null;
    g_template_obj(4).iv_setup(1).exclusion_tag    := null;

    g_template_obj(4).iv_setup(2).input_value_name := 'Benefit Start Date';
    g_template_obj(4).iv_setup(2).uom              := 'D';
    g_template_obj(4).iv_setup(2).mandatory_flag   := 'N';
    g_template_obj(4).iv_setup(2).lookup_type      := null;
    g_template_obj(4).iv_setup(2).default_value    := null;
    g_template_obj(4).iv_setup(2).def_value_column := null;
    g_template_obj(4).iv_setup(2).min_value        := null;
    g_template_obj(4).iv_setup(2).warn_or_error    := null;
    g_template_obj(4).iv_setup(2).balance_name     := null;
    g_template_obj(4).iv_setup(2).exclusion_tag    := null;

    g_template_obj(4).iv_setup(3).input_value_name := 'Benefit End Date';
    g_template_obj(4).iv_setup(3).uom              := 'D';
    g_template_obj(4).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(4).iv_setup(3).lookup_type      := null;
    g_template_obj(4).iv_setup(3).default_value    := null;
    g_template_obj(4).iv_setup(3).def_value_column := null;
    g_template_obj(4).iv_setup(3).min_value        := null;
    g_template_obj(4).iv_setup(3).warn_or_error    := null;
    g_template_obj(4).iv_setup(3).balance_name     := null;
    g_template_obj(4).iv_setup(3).exclusion_tag    := null;

    g_template_obj(4).iv_setup(4).input_value_name := 'Component Name';
    g_template_obj(4).iv_setup(4).uom              := 'C';
    g_template_obj(4).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(4).iv_setup(4).lookup_type      := null;
    g_template_obj(4).iv_setup(4).default_value    := 'Free Education';
    g_template_obj(4).iv_setup(4).def_value_column := null;
    g_template_obj(4).iv_setup(4).min_value        := null;
    g_template_obj(4).iv_setup(4).warn_or_error    := null;
    g_template_obj(4).iv_setup(4).balance_name     := null;
    g_template_obj(4).iv_setup(4).exclusion_tag    := null;

    g_template_obj(4).iv_setup(5).input_value_name := 'Relationship';
    g_template_obj(4).iv_setup(5).uom              := 'C';
    g_template_obj(4).iv_setup(5).mandatory_flag   := 'N';
    g_template_obj(4).iv_setup(5).lookup_type      := 'IN_EDU_RELATION';
    g_template_obj(4).iv_setup(5).default_value    := 'CHILD';
    g_template_obj(4).iv_setup(5).def_value_column := null;
    g_template_obj(4).iv_setup(5).min_value        := null;
    g_template_obj(4).iv_setup(5).warn_or_error    := null;
    g_template_obj(4).iv_setup(5).balance_name     := null;
    g_template_obj(4).iv_setup(5).exclusion_tag    := null;

    g_template_obj(4).iv_setup(6).input_value_name := 'Cost to Employer';
    g_template_obj(4).iv_setup(6).uom              := 'M';
    g_template_obj(4).iv_setup(6).mandatory_flag   := 'N';
    g_template_obj(4).iv_setup(6).lookup_type      := null;
    g_template_obj(4).iv_setup(6).default_value    := null;
    g_template_obj(4).iv_setup(6).def_value_column := null;
    g_template_obj(4).iv_setup(6).min_value        := 0;
    g_template_obj(4).iv_setup(6).warn_or_error    := 'E';
    g_template_obj(4).iv_setup(6).balance_name     := 'Perquisite Employer Contribution';
    g_template_obj(4).iv_setup(6).exclusion_tag    := null;

    g_template_obj(4).iv_setup(7).input_value_name := 'Employee Contribution';
    g_template_obj(4).iv_setup(7).uom              := 'M';
    g_template_obj(4).iv_setup(7).mandatory_flag   := 'N';
    g_template_obj(4).iv_setup(7).lookup_type      := null;
    g_template_obj(4).iv_setup(7).default_value    := null;
    g_template_obj(4).iv_setup(7).def_value_column := null;
    g_template_obj(4).iv_setup(7).min_value        := 0;
    g_template_obj(4).iv_setup(7).warn_or_error    := 'E';
    g_template_obj(4).iv_setup(7).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(4).iv_setup(7).exclusion_tag    := null;

    g_template_obj(4).iv_setup(8).input_value_name := 'Projected Taxable Value';
    g_template_obj(4).iv_setup(8).uom              := 'M';
    g_template_obj(4).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(4).iv_setup(8).lookup_type      := null;
    g_template_obj(4).iv_setup(8).default_value    := null;
    g_template_obj(4).iv_setup(8).def_value_column := null;
    g_template_obj(4).iv_setup(8).min_value        := null;
    g_template_obj(4).iv_setup(8).warn_or_error    := null;
    g_template_obj(4).iv_setup(8).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(4).iv_setup(8).exclusion_tag    := 'PROJECT';

    g_template_obj(4).iv_setup(9).input_value_name := 'Employer Paid Tax';
    g_template_obj(4).iv_setup(9).uom              := 'C';
    g_template_obj(4).iv_setup(9).mandatory_flag   := 'Y';
    g_template_obj(4).iv_setup(9).lookup_type      := 'YES_NO';
    g_template_obj(4).iv_setup(9).default_value    := 'N';
    g_template_obj(4).iv_setup(9).def_value_column := null;
    g_template_obj(4).iv_setup(9).min_value        := null;
    g_template_obj(4).iv_setup(9).warn_or_error    := null;
    g_template_obj(4).iv_setup(9).balance_name     := null;
    g_template_obj(4).iv_setup(9).exclusion_tag    := null;

    g_template_obj(4).iv_setup(10).input_value_name := 'Employer Taxable Amount';
    g_template_obj(4).iv_setup(10).uom              := 'M';
    g_template_obj(4).iv_setup(10).mandatory_flag   := 'X';
    g_template_obj(4).iv_setup(10).lookup_type      := null;
    g_template_obj(4).iv_setup(10).default_value    := null;
    g_template_obj(4).iv_setup(10).def_value_column := null;
    g_template_obj(4).iv_setup(10).min_value        := 0;
    g_template_obj(4).iv_setup(10).warn_or_error    := 'E';
    g_template_obj(4).iv_setup(10).balance_name     := null;
    g_template_obj(4).iv_setup(10).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for Free Education Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Free Education Template start
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Balance Feeds for Free Education Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Free Education Template starts
    ----------------------------------------------------------------
    g_template_obj(4).sf_setup.formula_name   := 'IN_FREE_EDUCATION';
    g_template_obj(4).sf_setup.status_rule_id := null;
    g_template_obj(4).sf_setup.description    := null;

      g_template_obj(4).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(4).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(4).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(4).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(2).result_name      := 'ACTUAL_COST_TO_EMPLOYER';
      g_template_obj(4).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(4).sf_setup.frs_setup(2).input_value_name := 'Cost to Employer';
      g_template_obj(4).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(3).result_name      := 'ACTUAL_EMPLOYEE_CONTRIBUTION';
      g_template_obj(4).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(4).sf_setup.frs_setup(3).input_value_name := 'Employee Contribution';
      g_template_obj(4).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(4).result_name      := 'PROJECTED_VALUE';
      g_template_obj(4).sf_setup.frs_setup(4).result_rule_type := 'D';
      g_template_obj(4).sf_setup.frs_setup(4).input_value_name := 'Projected Taxable Value';
      g_template_obj(4).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(4).exclusion_tag    := 'PROJECT';

      g_template_obj(4).sf_setup.frs_setup(5).result_name      := 'O_STOP_FLAG';
      g_template_obj(4).sf_setup.frs_setup(5).result_rule_type := 'S';
      g_template_obj(4).sf_setup.frs_setup(5).input_value_name := null;
      g_template_obj(4).sf_setup.frs_setup(5).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(6).result_name      := 'EMPR_TAX';
      g_template_obj(4).sf_setup.frs_setup(6).result_rule_type := 'D';
      g_template_obj(4).sf_setup.frs_setup(6).input_value_name := 'Employer Taxable Amount';
      g_template_obj(4).sf_setup.frs_setup(6).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(7).result_name      := 'FED_TO_NET_PAY';
      g_template_obj(4).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(7).input_value_name := null;
      g_template_obj(4).sf_setup.frs_setup(7).element_name     := null;
      g_template_obj(4).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(8).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(4).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(8).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(4).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(9).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(4).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(9).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(4).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(9).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(10).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(4).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(10).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(4).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(10).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(11).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(4).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(11).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(4).sf_setup.frs_setup(11).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(11).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(12).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(4).sf_setup.frs_setup(12).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(12).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(4).sf_setup.frs_setup(12).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(12).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(13).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(4).sf_setup.frs_setup(13).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(13).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(4).sf_setup.frs_setup(13).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(13).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(13).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(14).result_name      := 'COMPONENT_NAME';
      g_template_obj(4).sf_setup.frs_setup(14).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(14).input_value_name := 'Component Name';
      g_template_obj(4).sf_setup.frs_setup(14).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(14).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(14).exclusion_tag    := null;

      g_template_obj(4).sf_setup.frs_setup(15).result_name      := 'NON_REC_VALUE';
      g_template_obj(4).sf_setup.frs_setup(15).result_rule_type := 'I';
      g_template_obj(4).sf_setup.frs_setup(15).input_value_name := 'Non Rec Perquisite';
      g_template_obj(4).sf_setup.frs_setup(15).element_name     := 'Employer Tax Projection Element';
      g_template_obj(4).sf_setup.frs_setup(15).severity_level   := null;
      g_template_obj(4).sf_setup.frs_setup(15).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for Free Education Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Free Education Template starts
    ----------------------------------------------------------------

    g_template_obj(4).ae_setup(1).element_name     := ' Paid MP';
    g_template_obj(4).ae_setup(1).classification   := 'Paid Monetary Perquisite';
    g_template_obj(4).ae_setup(1).exclusion_tag    := 'Perquisite';
    g_template_obj(4).ae_setup(1).priority         := 2000;

      g_template_obj(4).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(4).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(4).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(4).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(4).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(4).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(4).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(4).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(4).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(4).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(4).ae_setup(1).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(4).ae_setup(1).iv_setup(2).uom              := 'C';
      g_template_obj(4).ae_setup(1).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(4).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(4).ae_setup(1).iv_setup(2).default_value    := 'Free Education';
      g_template_obj(4).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(4).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(4).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(4).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(4).ae_setup(1).iv_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Add. Element Setup for Free Education Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR FREE EDUCATION ENDS
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR ACCOMMODATION STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,60);
  g_template_obj(5).template_name  := 'Company Accommodation';
  g_template_obj(5).category       := 'Perquisites';
  g_template_obj(5).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Accommodation Template start
    ----------------------------------------------------------------
    g_template_obj(5).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(5).er_setup(1).value     := 'N';
    g_template_obj(5).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(5).er_setup(1).tag       := 'PROJECT';
    g_template_obj(5).er_setup(1).rule_id   :=  null;


    ----------------------------------------------------------------
    --  Exclusion Rules for Accommodation Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Accommodation Template start
    ----------------------------------------------------------------
    g_template_obj(5).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(5).iv_setup(1).uom              := 'M';
    g_template_obj(5).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(5).iv_setup(1).lookup_type      := null;
    g_template_obj(5).iv_setup(1).default_value    := null;
    g_template_obj(5).iv_setup(1).def_value_column := null;
    g_template_obj(5).iv_setup(1).min_value        := null;
    g_template_obj(5).iv_setup(1).warn_or_error    := null;
    g_template_obj(5).iv_setup(1).balance_name     := null;
    g_template_obj(5).iv_setup(1).exclusion_tag    := null;

    g_template_obj(5).iv_setup(2).input_value_name := 'Benefit Start Date';
    g_template_obj(5).iv_setup(2).uom              := 'D';
    g_template_obj(5).iv_setup(2).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(2).lookup_type      := null;
    g_template_obj(5).iv_setup(2).default_value    := null;
    g_template_obj(5).iv_setup(2).def_value_column := null;
    g_template_obj(5).iv_setup(2).min_value        := null;
    g_template_obj(5).iv_setup(2).warn_or_error    := null;
    g_template_obj(5).iv_setup(2).balance_name     := null;
    g_template_obj(5).iv_setup(2).exclusion_tag    := null;

    g_template_obj(5).iv_setup(3).input_value_name := 'Benefit End Date';
    g_template_obj(5).iv_setup(3).uom              := 'D';
    g_template_obj(5).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(3).lookup_type      := null;
    g_template_obj(5).iv_setup(3).default_value    := null;
    g_template_obj(5).iv_setup(3).def_value_column := null;
    g_template_obj(5).iv_setup(3).min_value        := null;
    g_template_obj(5).iv_setup(3).warn_or_error    := null;
    g_template_obj(5).iv_setup(3).balance_name     := null;
    g_template_obj(5).iv_setup(3).exclusion_tag    := null;

    g_template_obj(5).iv_setup(4).input_value_name := 'Component Name';
    g_template_obj(5).iv_setup(4).uom              := 'C';
    g_template_obj(5).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(5).iv_setup(4).lookup_type      := null;
    g_template_obj(5).iv_setup(4).default_value    := 'Company Accommodation';
    g_template_obj(5).iv_setup(4).def_value_column := null;
    g_template_obj(5).iv_setup(4).min_value        := null;
    g_template_obj(5).iv_setup(4).warn_or_error    := null;
    g_template_obj(5).iv_setup(4).balance_name     := null;
    g_template_obj(5).iv_setup(4).exclusion_tag    := null;

    g_template_obj(5).iv_setup(5).input_value_name := 'Place';
    g_template_obj(5).iv_setup(5).uom              := 'C';
    g_template_obj(5).iv_setup(5).mandatory_flag   := 'Y';
    g_template_obj(5).iv_setup(5).lookup_type      := 'IN_ACCOMMODATION_POPULATION';
    g_template_obj(5).iv_setup(5).default_value    := null;
    g_template_obj(5).iv_setup(5).def_value_column := null;
    g_template_obj(5).iv_setup(5).min_value        := null;
    g_template_obj(5).iv_setup(5).warn_or_error    := null;
    g_template_obj(5).iv_setup(5).balance_name     := null;
    g_template_obj(5).iv_setup(5).exclusion_tag    := null;

    g_template_obj(5).iv_setup(6).input_value_name := 'Property';
    g_template_obj(5).iv_setup(6).uom              := 'C';
    g_template_obj(5).iv_setup(6).mandatory_flag   := 'Y';
    g_template_obj(5).iv_setup(6).lookup_type      := 'IN_ACCOMMODATION_PROPERTY';
    g_template_obj(5).iv_setup(6).default_value    := null;
    g_template_obj(5).iv_setup(6).def_value_column := null;
    g_template_obj(5).iv_setup(6).min_value        := null;
    g_template_obj(5).iv_setup(6).warn_or_error    := null;
    g_template_obj(5).iv_setup(6).balance_name     := null;
    g_template_obj(5).iv_setup(6).exclusion_tag    := null;

    g_template_obj(5).iv_setup(7).input_value_name := 'Cost of Furniture Owned';
    g_template_obj(5).iv_setup(7).uom              := 'M';
    g_template_obj(5).iv_setup(7).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(7).lookup_type      := null;
    g_template_obj(5).iv_setup(7).default_value    := null;
    g_template_obj(5).iv_setup(7).def_value_column := null;
    g_template_obj(5).iv_setup(7).min_value        := 0;
    g_template_obj(5).iv_setup(7).warn_or_error    := 'E';
    g_template_obj(5).iv_setup(7).balance_name     := 'Cost and Rent of Furniture';
    g_template_obj(5).iv_setup(7).exclusion_tag    := null;

    g_template_obj(5).iv_setup(8).input_value_name := 'Rent of Furniture Leased';
    g_template_obj(5).iv_setup(8).uom              := 'M';
    g_template_obj(5).iv_setup(8).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(8).lookup_type      := null;
    g_template_obj(5).iv_setup(8).default_value    := null;
    g_template_obj(5).iv_setup(8).def_value_column := null;
    g_template_obj(5).iv_setup(8).min_value        := 0;
    g_template_obj(5).iv_setup(8).warn_or_error    := 'E';
    g_template_obj(5).iv_setup(8).balance_name     := 'Cost and Rent of Furniture';
    g_template_obj(5).iv_setup(8).exclusion_tag    := null;

    g_template_obj(5).iv_setup(9).input_value_name := 'Rent Paid by Employer';
    g_template_obj(5).iv_setup(9).uom              := 'M';
    g_template_obj(5).iv_setup(9).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(9).lookup_type      := null;
    g_template_obj(5).iv_setup(9).default_value    := null;
    g_template_obj(5).iv_setup(9).def_value_column := null;
    g_template_obj(5).iv_setup(9).min_value        := 0;
    g_template_obj(5).iv_setup(9).warn_or_error    := 'E';
    g_template_obj(5).iv_setup(9).balance_name     := 'Rent Paid by Employer';
    g_template_obj(5).iv_setup(9).exclusion_tag    := null;

    g_template_obj(5).iv_setup(10).input_value_name := 'Employee Contribution';
    g_template_obj(5).iv_setup(10).uom              := 'M';
    g_template_obj(5).iv_setup(10).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(10).lookup_type      := null;
    g_template_obj(5).iv_setup(10).default_value    := null;
    g_template_obj(5).iv_setup(10).def_value_column := null;
    g_template_obj(5).iv_setup(10).min_value        := 0;
    g_template_obj(5).iv_setup(10).warn_or_error    := 'E';
    g_template_obj(5).iv_setup(10).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(5).iv_setup(10).exclusion_tag    := null;

    g_template_obj(5).iv_setup(11).input_value_name := 'Projected Taxable Value';
    g_template_obj(5).iv_setup(11).uom              := 'M';
    g_template_obj(5).iv_setup(11).mandatory_flag   := 'X';
    g_template_obj(5).iv_setup(11).lookup_type      := null;
    g_template_obj(5).iv_setup(11).default_value    := null;
    g_template_obj(5).iv_setup(11).def_value_column := null;
    g_template_obj(5).iv_setup(11).min_value        := null;
    g_template_obj(5).iv_setup(11).warn_or_error    := null;
    g_template_obj(5).iv_setup(11).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(5).iv_setup(11).exclusion_tag    := 'PROJECT';

    g_template_obj(5).iv_setup(12).input_value_name := 'Flat Reference No';
    g_template_obj(5).iv_setup(12).uom              := 'C';
    g_template_obj(5).iv_setup(12).mandatory_flag   := 'N';
    g_template_obj(5).iv_setup(12).lookup_type      := null;
    g_template_obj(5).iv_setup(12).default_value    := null;
    g_template_obj(5).iv_setup(12).def_value_column := null;
    g_template_obj(5).iv_setup(12).min_value        := null;
    g_template_obj(5).iv_setup(12).warn_or_error    := null;
    g_template_obj(5).iv_setup(12).balance_name     := null;
    g_template_obj(5).iv_setup(12).exclusion_tag    := null;

    g_template_obj(5).iv_setup(13).input_value_name := 'Employer Paid Tax';
    g_template_obj(5).iv_setup(13).uom              := 'C';
    g_template_obj(5).iv_setup(13).mandatory_flag   := 'Y';
    g_template_obj(5).iv_setup(13).lookup_type      := 'YES_NO';
    g_template_obj(5).iv_setup(13).default_value    := 'N';
    g_template_obj(5).iv_setup(13).def_value_column := null;
    g_template_obj(5).iv_setup(13).min_value        := null;
    g_template_obj(5).iv_setup(13).warn_or_error    := null;
    g_template_obj(5).iv_setup(13).balance_name     := null;
    g_template_obj(5).iv_setup(13).exclusion_tag    := null;

    g_template_obj(5).iv_setup(14).input_value_name := 'Employer Taxable Amount';
    g_template_obj(5).iv_setup(14).uom              := 'M';
    g_template_obj(5).iv_setup(14).mandatory_flag   := 'X';
    g_template_obj(5).iv_setup(14).lookup_type      := null;
    g_template_obj(5).iv_setup(14).default_value    := null;
    g_template_obj(5).iv_setup(14).def_value_column := null;
    g_template_obj(5).iv_setup(14).min_value        := 0;
    g_template_obj(5).iv_setup(14).warn_or_error    := 'E';
    g_template_obj(5).iv_setup(14).balance_name     := null;
    g_template_obj(5).iv_setup(14).exclusion_tag    := null;


    ----------------------------------------------------------------
    --  Input Values for Accommodation Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Accommodation Template start
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Balance Feeds for Accommodation Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Accommodation Template starts
    ----------------------------------------------------------------
    g_template_obj(5).sf_setup.formula_name   := 'IN_COMPANY_ACCOMMODATION';
    g_template_obj(5).sf_setup.status_rule_id := null;
    g_template_obj(5).sf_setup.description    := null;

      g_template_obj(5).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(5).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(5).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(5).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(2).result_name      := 'ACTUAL_RENT_OF_FURNITURE';
      g_template_obj(5).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(5).sf_setup.frs_setup(2).input_value_name := 'Rent of Furniture Leased';
      g_template_obj(5).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(3).result_name      := 'ACTUAL_RENT_PAID';
      g_template_obj(5).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(5).sf_setup.frs_setup(3).input_value_name := 'Rent Paid by Employer';
      g_template_obj(5).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(4).result_name      := 'ACTUAL_EMPLOYEE_CONTRIBUTION';
      g_template_obj(5).sf_setup.frs_setup(4).result_rule_type := 'D';
      g_template_obj(5).sf_setup.frs_setup(4).input_value_name := 'Employee Contribution';
      g_template_obj(5).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(5).result_name      := 'PROJECTED_VALUE';
      g_template_obj(5).sf_setup.frs_setup(5).result_rule_type := 'D';
      g_template_obj(5).sf_setup.frs_setup(5).input_value_name := 'Projected Taxable Value';
      g_template_obj(5).sf_setup.frs_setup(5).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(5).exclusion_tag    := 'PROJECT';

      g_template_obj(5).sf_setup.frs_setup(6).result_name      := 'O_STOP_FLAG';
      g_template_obj(5).sf_setup.frs_setup(6).result_rule_type := 'S';
      g_template_obj(5).sf_setup.frs_setup(6).input_value_name := null;
      g_template_obj(5).sf_setup.frs_setup(6).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(7).result_name      := 'COST_OF_FURNITURE';
      g_template_obj(5).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(7).input_value_name := 'Cost of Furniture';
      g_template_obj(5).sf_setup.frs_setup(7).element_name     := 'Projected Company Accommodation';
      g_template_obj(5).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(8).result_name      := 'ACTUAL_FURNITURE_PERQUISITE';
      g_template_obj(5).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(8).input_value_name := 'Monthly Furniture Perquisite';
      g_template_obj(5).sf_setup.frs_setup(8).element_name     := 'Projected Company Accommodation';
      g_template_obj(5).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(9).result_name      := 'PROJECTED_EMPLOYEE_CONTRIBUTION';
      g_template_obj(5).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(9).input_value_name := 'Employee Contribution';
      g_template_obj(5).sf_setup.frs_setup(9).element_name     := 'Projected Company Accommodation';
      g_template_obj(5).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(9).exclusion_tag    := 'PROJECT';

      g_template_obj(5).sf_setup.frs_setup(10).result_name      := 'PROJECTED_FURNITURE_PERQUISITE';
      g_template_obj(5).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(10).input_value_name := 'Furniture Perquisite';
      g_template_obj(5).sf_setup.frs_setup(10).element_name     := 'Projected Company Accommodation';
      g_template_obj(5).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(10).exclusion_tag    := 'PROJECT';

      g_template_obj(5).sf_setup.frs_setup(11).result_name      := 'PROJECTED_FURNITURE_COST';
      g_template_obj(5).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(11).input_value_name := 'Furniture Cost';
      g_template_obj(5).sf_setup.frs_setup(11).element_name     := 'Projected Company Accommodation';
      g_template_obj(5).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(11).exclusion_tag    := 'PROJECT';

      g_template_obj(5).sf_setup.frs_setup(12).result_name      := 'EMPR_TAX';
      g_template_obj(5).sf_setup.frs_setup(12).result_rule_type := 'D';
      g_template_obj(5).sf_setup.frs_setup(12).input_value_name := 'Employer Taxable Amount';
      g_template_obj(5).sf_setup.frs_setup(12).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(12).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(13).result_name      := 'ACTUAL_COMP_SAL';
      g_template_obj(5).sf_setup.frs_setup(13).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(13).input_value_name := 'Actual Salary';
      g_template_obj(5).sf_setup.frs_setup(13).element_name     := 'Projected Company Accommodation';
      g_template_obj(5).sf_setup.frs_setup(13).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(13).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(14).result_name      := 'FED_TO_NET_PAY';
      g_template_obj(5).sf_setup.frs_setup(14).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(14).input_value_name := null;
      g_template_obj(5).sf_setup.frs_setup(14).element_name     := null;
      g_template_obj(5).sf_setup.frs_setup(14).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(14).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(15).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(5).sf_setup.frs_setup(15).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(15).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(5).sf_setup.frs_setup(15).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(15).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(15).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(16).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(5).sf_setup.frs_setup(16).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(16).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(5).sf_setup.frs_setup(16).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(16).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(16).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(17).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(5).sf_setup.frs_setup(17).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(17).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(5).sf_setup.frs_setup(17).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(17).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(17).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(18).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(5).sf_setup.frs_setup(18).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(18).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(5).sf_setup.frs_setup(18).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(18).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(18).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(19).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(5).sf_setup.frs_setup(19).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(19).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(5).sf_setup.frs_setup(19).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(19).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(19).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(20).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(5).sf_setup.frs_setup(20).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(20).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(5).sf_setup.frs_setup(20).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(20).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(20).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(21).result_name      := 'COMPONENT_NAME';
      g_template_obj(5).sf_setup.frs_setup(21).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(21).input_value_name := 'Component Name';
      g_template_obj(5).sf_setup.frs_setup(21).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(21).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(21).exclusion_tag    := null;

      g_template_obj(5).sf_setup.frs_setup(22).result_name      := 'NON_REC_VALUE';
      g_template_obj(5).sf_setup.frs_setup(22).result_rule_type := 'I';
      g_template_obj(5).sf_setup.frs_setup(22).input_value_name := 'Non Rec Perquisite';
      g_template_obj(5).sf_setup.frs_setup(22).element_name     := 'Employer Tax Projection Element';
      g_template_obj(5).sf_setup.frs_setup(22).severity_level   := null;
      g_template_obj(5).sf_setup.frs_setup(22).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for Accommodation Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Accommodation Template starts
    ----------------------------------------------------------------

    g_template_obj(5).ae_setup(1).element_name     := ' Paid MP';
    g_template_obj(5).ae_setup(1).classification   := 'Paid Monetary Perquisite';
    g_template_obj(5).ae_setup(1).exclusion_tag    := 'Perquisite';
    g_template_obj(5).ae_setup(1).priority         := 2000;

      g_template_obj(5).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(5).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(5).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(5).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(5).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(5).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(5).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(5).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(5).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(5).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(5).ae_setup(1).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(5).ae_setup(1).iv_setup(2).uom              := 'C';
      g_template_obj(5).ae_setup(1).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(5).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(5).ae_setup(1).iv_setup(2).default_value    := 'Company Accommodation';
      g_template_obj(5).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(5).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(5).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(5).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(5).ae_setup(1).iv_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Add. Element Setup for Accommodation Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR ACCOMMODATION ENDS
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR CONCESSIONAL LOAN STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,70);
  g_template_obj(6).template_name  := 'Loan at Concessional Rate';
  g_template_obj(6).category       := 'Perquisites';
  g_template_obj(6).priority       := 17000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Concessional Loan Template start
    ----------------------------------------------------------------
    g_template_obj(6).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(6).er_setup(1).value     := 'N';
    g_template_obj(6).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(6).er_setup(1).tag       := 'PROJECT';
    g_template_obj(6).er_setup(1).rule_id   :=  null;

   ----------------------------------------------------------------
    --  Exclusion Rules for Concessional Loan Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Concessional Loan Template start
    ----------------------------------------------------------------
    g_template_obj(6).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(6).iv_setup(1).uom              := 'M';
    g_template_obj(6).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(1).lookup_type      := null;
    g_template_obj(6).iv_setup(1).def_value_column := null;
    g_template_obj(6).iv_setup(1).default_value    := null;
    g_template_obj(6).iv_setup(1).min_value        := null;
    g_template_obj(6).iv_setup(1).warn_or_error    := null;
    g_template_obj(6).iv_setup(1).balance_name     := null;
    g_template_obj(6).iv_setup(1).exclusion_tag    := null;

    g_template_obj(6).iv_setup(2).input_value_name := 'Component Name';
    g_template_obj(6).iv_setup(2).uom              := 'C';
    g_template_obj(6).iv_setup(2).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(2).lookup_type      := null;
    g_template_obj(6).iv_setup(2).default_value    := 'Loan at Concessional Rate';
    g_template_obj(6).iv_setup(2).def_value_column := null;
    g_template_obj(6).iv_setup(2).min_value        := null;
    g_template_obj(6).iv_setup(2).warn_or_error    := null;
    g_template_obj(6).iv_setup(2).balance_name     := null;
    g_template_obj(6).iv_setup(2).exclusion_tag    := null;

    g_template_obj(6).iv_setup(3).input_value_name := 'Loan Number';
    g_template_obj(6).iv_setup(3).uom              := 'C';
    g_template_obj(6).iv_setup(3).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(3).lookup_type      := null;
    g_template_obj(6).iv_setup(3).default_value    := null;
    g_template_obj(6).iv_setup(3).def_value_column := null;
    g_template_obj(6).iv_setup(3).min_value        := null;
    g_template_obj(6).iv_setup(3).warn_or_error    := null;
    g_template_obj(6).iv_setup(3).balance_name     := null;
    g_template_obj(6).iv_setup(3).exclusion_tag    := null;

    g_template_obj(6).iv_setup(4).input_value_name := 'Outstanding Balance';
    g_template_obj(6).iv_setup(4).uom              := 'M';
    g_template_obj(6).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(4).lookup_type      := null;
    g_template_obj(6).iv_setup(4).default_value    := null;
    g_template_obj(6).iv_setup(4).def_value_column := null;
    g_template_obj(6).iv_setup(4).min_value        := 0;
    g_template_obj(6).iv_setup(4).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(4).balance_name     := 'Maximum Outstanding Amount';
    g_template_obj(6).iv_setup(4).exclusion_tag    := null;

    g_template_obj(6).iv_setup(5).input_value_name := 'Monthly Installment';
    g_template_obj(6).iv_setup(5).uom              := 'M';
    g_template_obj(6).iv_setup(5).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(5).lookup_type      := null;
    g_template_obj(6).iv_setup(5).default_value    := null;
    g_template_obj(6).iv_setup(5).def_value_column := null;
    g_template_obj(6).iv_setup(5).min_value        := 0;
    g_template_obj(6).iv_setup(5).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(5).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(6).iv_setup(5).exclusion_tag    := null;

    g_template_obj(6).iv_setup(6).input_value_name := 'Loan Type';
    g_template_obj(6).iv_setup(6).uom              := 'C';
    g_template_obj(6).iv_setup(6).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(6).lookup_type      := 'IN_LOAN_TYPE';
    g_template_obj(6).iv_setup(6).default_value    := null;
    g_template_obj(6).iv_setup(6).def_value_column := null;
    g_template_obj(6).iv_setup(6).min_value        := null;
    g_template_obj(6).iv_setup(6).warn_or_error    := null;
    g_template_obj(6).iv_setup(6).balance_name     := null;
    g_template_obj(6).iv_setup(6).exclusion_tag    := null;

    g_template_obj(6).iv_setup(7).input_value_name := 'Loan Principal Amount';
    g_template_obj(6).iv_setup(7).uom              := 'M';
    g_template_obj(6).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(7).lookup_type      := null;
    g_template_obj(6).iv_setup(7).default_value    := null;
    g_template_obj(6).iv_setup(7).def_value_column := null;
    g_template_obj(6).iv_setup(7).min_value        := 0;
    g_template_obj(6).iv_setup(7).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(7).balance_name     := 'Loan Principal Amount';
    g_template_obj(6).iv_setup(7).exclusion_tag    := null;

    g_template_obj(6).iv_setup(8).input_value_name := 'Loan Duration in Months';
    g_template_obj(6).iv_setup(8).uom              := 'N';
    g_template_obj(6).iv_setup(8).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(8).lookup_type      := null;
    g_template_obj(6).iv_setup(8).default_value    := null;
    g_template_obj(6).iv_setup(8).def_value_column := null;
    g_template_obj(6).iv_setup(8).min_value        := 0;
    g_template_obj(6).iv_setup(8).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(8).balance_name     := null;
    g_template_obj(6).iv_setup(8).exclusion_tag    := null;

    g_template_obj(6).iv_setup(9).input_value_name := 'Employer Interest Rate';
    g_template_obj(6).iv_setup(9).uom              := 'N';
    g_template_obj(6).iv_setup(9).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(9).lookup_type      := null;
    g_template_obj(6).iv_setup(9).default_value    := null;
    g_template_obj(6).iv_setup(9).def_value_column := null;
    g_template_obj(6).iv_setup(9).min_value        := 0;
    g_template_obj(6).iv_setup(9).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(9).balance_name     := null;
    g_template_obj(6).iv_setup(9).exclusion_tag    := null;

    g_template_obj(6).iv_setup(10).input_value_name := 'Taxable Flag';
    g_template_obj(6).iv_setup(10).uom              := 'C';
    g_template_obj(6).iv_setup(10).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(10).lookup_type      := 'YES_NO';
    g_template_obj(6).iv_setup(10).default_value    := 'Y';
    g_template_obj(6).iv_setup(10).def_value_column := null;
    g_template_obj(6).iv_setup(10).min_value        := null;
    g_template_obj(6).iv_setup(10).warn_or_error    := null;
    g_template_obj(6).iv_setup(10).balance_name     := null;
    g_template_obj(6).iv_setup(10).exclusion_tag    := null;

    g_template_obj(6).iv_setup(11).input_value_name := 'Principal Amount Balance';
    g_template_obj(6).iv_setup(11).uom              := 'M';
    g_template_obj(6).iv_setup(11).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(11).lookup_type      := null;
    g_template_obj(6).iv_setup(11).default_value    := null;
    g_template_obj(6).iv_setup(11).def_value_column := null;
    g_template_obj(6).iv_setup(11).min_value        := 0;
    g_template_obj(6).iv_setup(11).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(11).balance_name     := null;
    g_template_obj(6).iv_setup(11).exclusion_tag    := null;

    g_template_obj(6).iv_setup(12).input_value_name := 'Projected Taxable Value';
    g_template_obj(6).iv_setup(12).uom              := 'M';
    g_template_obj(6).iv_setup(12).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(12).lookup_type      := null;
    g_template_obj(6).iv_setup(12).default_value    := null;
    g_template_obj(6).iv_setup(12).def_value_column := null;
    g_template_obj(6).iv_setup(12).min_value        := null;
    g_template_obj(6).iv_setup(12).warn_or_error    := null;
    g_template_obj(6).iv_setup(12).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(6).iv_setup(12).exclusion_tag    := 'PROJECT';

    g_template_obj(6).iv_setup(13).input_value_name := 'Employer Paid Tax';
    g_template_obj(6).iv_setup(13).uom              := 'C';
    g_template_obj(6).iv_setup(13).mandatory_flag   := 'Y';
    g_template_obj(6).iv_setup(13).lookup_type      := 'YES_NO';
    g_template_obj(6).iv_setup(13).default_value    := 'N';
    g_template_obj(6).iv_setup(13).def_value_column := null;
    g_template_obj(6).iv_setup(13).min_value        := null;
    g_template_obj(6).iv_setup(13).warn_or_error    := null;
    g_template_obj(6).iv_setup(13).balance_name     := null;
    g_template_obj(6).iv_setup(13).exclusion_tag    := null;

    g_template_obj(6).iv_setup(14).input_value_name := 'Employer Taxable Amount';
    g_template_obj(6).iv_setup(14).uom              := 'M';
    g_template_obj(6).iv_setup(14).mandatory_flag   := 'X';
    g_template_obj(6).iv_setup(14).lookup_type      := null;
    g_template_obj(6).iv_setup(14).default_value    := null;
    g_template_obj(6).iv_setup(14).def_value_column := null;
    g_template_obj(6).iv_setup(14).min_value        := 0;
    g_template_obj(6).iv_setup(14).warn_or_error    := 'E';
    g_template_obj(6).iv_setup(14).balance_name     := null;
    g_template_obj(6).iv_setup(14).exclusion_tag    := null;

    g_template_obj(6).iv_setup(15).input_value_name := 'Additional Information';
    g_template_obj(6).iv_setup(15).uom              := 'C';
    g_template_obj(6).iv_setup(15).mandatory_flag   := 'N';
    g_template_obj(6).iv_setup(15).lookup_type      := 'IN_LOAN_INTEREST_TYPE';
    g_template_obj(6).iv_setup(15).default_value    := null;
    g_template_obj(6).iv_setup(15).def_value_column := null;
    g_template_obj(6).iv_setup(15).min_value        := null;
    g_template_obj(6).iv_setup(15).warn_or_error    := null;
    g_template_obj(6).iv_setup(15).balance_name     := null;
    g_template_obj(6).iv_setup(15).exclusion_tag    := null;


    ----------------------------------------------------------------
    --  Input Values for Concessional Loan Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Concessional Loan Template start
    ----------------------------------------------------------------
    g_template_obj(6).bf_setup(1).balance_name     := 'Maximum Outstanding Amount';
    g_template_obj(6).bf_setup(1).iv_name          := 'Monthly Installment';
    g_template_obj(6).bf_setup(1).scale            := -1;
    g_template_obj(6).bf_setup(1).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Balance Feeds for Concessional Loan Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Concessional Loan Template starts
    ----------------------------------------------------------------
    g_template_obj(6).sf_setup.formula_name   := 'IN_CONCESSION_LOAN';
    g_template_obj(6).sf_setup.status_rule_id := null;
    g_template_obj(6).sf_setup.description    := null;

      g_template_obj(6).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(6).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(6).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(6).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(1).exclusion_tag    := null;

/*      g_template_obj(6).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(6).sf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(6).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(1).exclusion_tag    := null;
*/
      g_template_obj(6).sf_setup.frs_setup(2).result_name      := 'PRINCIPAL_AMOUNT';
      g_template_obj(6).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(6).sf_setup.frs_setup(2).input_value_name := 'Principal Amount Balance';
      g_template_obj(6).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(3).result_name      := 'PROJECTED_VALUE';
      g_template_obj(6).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(6).sf_setup.frs_setup(3).input_value_name := 'Projected Taxable Value';
      g_template_obj(6).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(3).exclusion_tag    := 'PROJECT';

      g_template_obj(6).sf_setup.frs_setup(4).result_name      := 'O_STOP_FLAG';
      g_template_obj(6).sf_setup.frs_setup(4).result_rule_type := 'S';
      g_template_obj(6).sf_setup.frs_setup(4).input_value_name := null;
      g_template_obj(6).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(5).result_name      := 'EMPR_TAX';
      g_template_obj(6).sf_setup.frs_setup(5).result_rule_type := 'D';
      g_template_obj(6).sf_setup.frs_setup(5).input_value_name := 'Employer Taxable Amount';
      g_template_obj(6).sf_setup.frs_setup(5).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(6).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(6).sf_setup.frs_setup(6).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(6).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(6).sf_setup.frs_setup(6).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(7).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(6).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(7).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(6).sf_setup.frs_setup(7).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(8).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(6).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(8).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(6).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(9).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(6).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(9).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(6).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(9).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(10).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(6).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(10).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(6).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(10).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(11).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(6).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(11).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(6).sf_setup.frs_setup(11).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(11).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(12).result_name      := 'COMPONENT_NAME';
      g_template_obj(6).sf_setup.frs_setup(12).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(12).input_value_name := 'Component Name';
      g_template_obj(6).sf_setup.frs_setup(12).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(12).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(13).result_name      := 'NON_REC_VALUE';
      g_template_obj(6).sf_setup.frs_setup(13).result_rule_type := 'I';
      g_template_obj(6).sf_setup.frs_setup(13).input_value_name := 'Non Rec Perquisite';
      g_template_obj(6).sf_setup.frs_setup(13).element_name     := 'Employer Tax Projection Element';
      g_template_obj(6).sf_setup.frs_setup(13).severity_level   := null;
      g_template_obj(6).sf_setup.frs_setup(13).exclusion_tag    := null;

      g_template_obj(6).sf_setup.frs_setup(14).result_name      := 'L_ERROR_MESG';
      g_template_obj(6).sf_setup.frs_setup(14).result_rule_type := 'M';
      g_template_obj(6).sf_setup.frs_setup(14).input_value_name := null;
      g_template_obj(6).sf_setup.frs_setup(14).element_name     := null;
      g_template_obj(6).sf_setup.frs_setup(14).severity_level   := 'W';
      g_template_obj(6).sf_setup.frs_setup(14).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for Concessional Loan Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Concessional Loan Template starts
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Add. Element Setup for Concessional Loan Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR CONCESSIONAL LOAN ENDS
  ----------------------------------------------------------------

    ----------------------------------------------------------------
  --  TEMPLATE FOR COMPANY ASSETS STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_template_obj(7).template_name  := 'Company Movable Assets';
  g_template_obj(7).category       := 'Perquisites';
  g_template_obj(7).priority       := 17000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Company Assets Template start
    ----------------------------------------------------------------
    g_template_obj(7).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(7).er_setup(1).value     := 'N';
    g_template_obj(7).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(7).er_setup(1).tag       := 'PROJECT';
    g_template_obj(7).er_setup(1).rule_id   :=  null;

   ----------------------------------------------------------------
    --  Exclusion Rules for Company Assets Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Company Assets Template start
    ----------------------------------------------------------------
    g_template_obj(7).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(7).iv_setup(1).uom              := 'M';
    g_template_obj(7).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(7).iv_setup(1).lookup_type      := null;
    g_template_obj(7).iv_setup(1).default_value    := null;
    g_template_obj(7).iv_setup(1).def_value_column := null;
    g_template_obj(7).iv_setup(1).min_value        := null;
    g_template_obj(7).iv_setup(1).warn_or_error    := null;
    g_template_obj(7).iv_setup(1).balance_name     := null;
    g_template_obj(7).iv_setup(1).exclusion_tag    := null;

    g_template_obj(7).iv_setup(2).input_value_name := 'Benefit Start Date';
    g_template_obj(7).iv_setup(2).uom              := 'D';
    g_template_obj(7).iv_setup(2).mandatory_flag   := 'N';
    g_template_obj(7).iv_setup(2).lookup_type      := null;
    g_template_obj(7).iv_setup(2).default_value    := null;
    g_template_obj(7).iv_setup(2).def_value_column := null;
    g_template_obj(7).iv_setup(2).min_value        := null;
    g_template_obj(7).iv_setup(2).warn_or_error    := null;
    g_template_obj(7).iv_setup(2).balance_name     := null;
    g_template_obj(7).iv_setup(2).exclusion_tag    := null;

    g_template_obj(7).iv_setup(3).input_value_name := 'Benefit End Date';
    g_template_obj(7).iv_setup(3).uom              := 'D';
    g_template_obj(7).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(7).iv_setup(3).lookup_type      := null;
    g_template_obj(7).iv_setup(3).default_value    := null;
    g_template_obj(7).iv_setup(3).def_value_column := null;
    g_template_obj(7).iv_setup(3).min_value        := null;
    g_template_obj(7).iv_setup(3).warn_or_error    := null;
    g_template_obj(7).iv_setup(3).balance_name     := null;
    g_template_obj(7).iv_setup(3).exclusion_tag    := null;

    g_template_obj(7).iv_setup(4).input_value_name := 'Component Name';
    g_template_obj(7).iv_setup(4).uom              := 'C';
    g_template_obj(7).iv_setup(4).mandatory_flag   := 'X';
    g_template_obj(7).iv_setup(4).lookup_type      := null;
    g_template_obj(7).iv_setup(4).default_value    := 'Company Movable Assets';
    g_template_obj(7).iv_setup(4).def_value_column := null;
    g_template_obj(7).iv_setup(4).min_value        := null;
    g_template_obj(7).iv_setup(4).warn_or_error    := null;
    g_template_obj(7).iv_setup(4).balance_name     := null;
    g_template_obj(7).iv_setup(4).exclusion_tag    := null;

    g_template_obj(7).iv_setup(5).input_value_name := 'Asset Category';
    g_template_obj(7).iv_setup(5).uom              := 'C';
    g_template_obj(7).iv_setup(5).mandatory_flag   := 'Y';
    g_template_obj(7).iv_setup(5).lookup_type      := 'IN_ASSET_TYPE_TEMP';
    g_template_obj(7).iv_setup(5).default_value    := null;
    g_template_obj(7).iv_setup(5).def_value_column := null;
    g_template_obj(7).iv_setup(5).min_value        := null;
    g_template_obj(7).iv_setup(5).warn_or_error    := null;
    g_template_obj(7).iv_setup(5).balance_name     := null;
    g_template_obj(7).iv_setup(5).exclusion_tag    := null;

    g_template_obj(7).iv_setup(6).input_value_name := 'Asset Description';
    g_template_obj(7).iv_setup(6).uom              := 'C';
    g_template_obj(7).iv_setup(6).mandatory_flag   := 'N';
    g_template_obj(7).iv_setup(6).lookup_type      := null;
    g_template_obj(7).iv_setup(6).default_value    := null;
    g_template_obj(7).iv_setup(6).def_value_column := null;
    g_template_obj(7).iv_setup(6).min_value        := null;
    g_template_obj(7).iv_setup(6).warn_or_error    := null;
    g_template_obj(7).iv_setup(6).balance_name     := null;
    g_template_obj(7).iv_setup(6).exclusion_tag    := null;

    g_template_obj(7).iv_setup(7).input_value_name := 'Usage';
    g_template_obj(7).iv_setup(7).uom              := 'C';
    g_template_obj(7).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(7).iv_setup(7).lookup_type      := 'IN_ASSET_USAGE_TYPE';
    g_template_obj(7).iv_setup(7).default_value    := null;
    g_template_obj(7).iv_setup(7).def_value_column := null;
    g_template_obj(7).iv_setup(7).min_value        := null;
    g_template_obj(7).iv_setup(7).warn_or_error    := null;
    g_template_obj(7).iv_setup(7).balance_name     := null;
    g_template_obj(7).iv_setup(7).exclusion_tag    := null;

    g_template_obj(7).iv_setup(8).input_value_name := 'Original Cost or Rental';
    g_template_obj(7).iv_setup(8).uom              := 'M';
    g_template_obj(7).iv_setup(8).mandatory_flag   := 'Y';
    g_template_obj(7).iv_setup(8).lookup_type      := null;
    g_template_obj(7).iv_setup(8).default_value    := null;
    g_template_obj(7).iv_setup(8).def_value_column := null;
    g_template_obj(7).iv_setup(8).min_value        := 0;
    g_template_obj(7).iv_setup(8).warn_or_error    := 'E';
    g_template_obj(7).iv_setup(8).balance_name     := null;
    g_template_obj(7).iv_setup(8).exclusion_tag    := null;

    g_template_obj(7).iv_setup(9).input_value_name := 'Date of Purchase';
    g_template_obj(7).iv_setup(9).uom              := 'D';
    g_template_obj(7).iv_setup(9).mandatory_flag   := 'N';
    g_template_obj(7).iv_setup(9).lookup_type      := null;
    g_template_obj(7).iv_setup(9).default_value    := null;
    g_template_obj(7).iv_setup(9).def_value_column := null;
    g_template_obj(7).iv_setup(9).min_value        := null;
    g_template_obj(7).iv_setup(9).warn_or_error    := 'E';
    g_template_obj(7).iv_setup(9).balance_name     := null;
    g_template_obj(7).iv_setup(9).exclusion_tag    := null;

    g_template_obj(7).iv_setup(10).input_value_name := 'Employee Contribution';
    g_template_obj(7).iv_setup(10).uom              := 'M';
    g_template_obj(7).iv_setup(10).mandatory_flag   := 'N';
    g_template_obj(7).iv_setup(10).lookup_type      := null;
    g_template_obj(7).iv_setup(10).default_value    := null;
    g_template_obj(7).iv_setup(10).def_value_column := null;
    g_template_obj(7).iv_setup(10).min_value        := 0;
    g_template_obj(7).iv_setup(10).warn_or_error    := 'E';
    g_template_obj(7).iv_setup(10).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(7).iv_setup(10).exclusion_tag    := null;

    g_template_obj(7).iv_setup(11).input_value_name := 'Projected Taxable Value';
    g_template_obj(7).iv_setup(11).uom              := 'M';
    g_template_obj(7).iv_setup(11).mandatory_flag   := 'X';
    g_template_obj(7).iv_setup(11).lookup_type      := null;
    g_template_obj(7).iv_setup(11).default_value    := null;
    g_template_obj(7).iv_setup(11).def_value_column := null;
    g_template_obj(7).iv_setup(11).min_value        := null;
    g_template_obj(7).iv_setup(11).warn_or_error    := null;
    g_template_obj(7).iv_setup(11).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(7).iv_setup(11).exclusion_tag    := 'PROJECT';

    g_template_obj(7).iv_setup(12).input_value_name := 'Employer Paid Tax';
    g_template_obj(7).iv_setup(12).uom              := 'C';
    g_template_obj(7).iv_setup(12).mandatory_flag   := 'Y';
    g_template_obj(7).iv_setup(12).lookup_type      := 'YES_NO';
    g_template_obj(7).iv_setup(12).default_value    := 'N';
    g_template_obj(7).iv_setup(12).def_value_column := null;
    g_template_obj(7).iv_setup(12).min_value        := null;
    g_template_obj(7).iv_setup(12).warn_or_error    := null;
    g_template_obj(7).iv_setup(12).balance_name     := null;
    g_template_obj(7).iv_setup(12).exclusion_tag    := null;

    g_template_obj(7).iv_setup(13).input_value_name := 'Employer Taxable Amount';
    g_template_obj(7).iv_setup(13).uom              := 'M';
    g_template_obj(7).iv_setup(13).mandatory_flag   := 'X';
    g_template_obj(7).iv_setup(13).lookup_type      := null;
    g_template_obj(7).iv_setup(13).default_value    := null;
    g_template_obj(7).iv_setup(13).def_value_column := null;
    g_template_obj(7).iv_setup(13).min_value        := 0;
    g_template_obj(7).iv_setup(13).warn_or_error    := 'E';
    g_template_obj(7).iv_setup(13).balance_name     := null;
    g_template_obj(7).iv_setup(13).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for Company Assets Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Company Assets Template start
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Balance Feeds for Company Assets Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Company Assets Template starts
    ----------------------------------------------------------------
    g_template_obj(7).sf_setup.formula_name   := 'IN_MOVABLE_ASSET';
    g_template_obj(7).sf_setup.status_rule_id := null;
    g_template_obj(7).sf_setup.description    := null;

      g_template_obj(7).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(7).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(7).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(7).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(7).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(2).result_name      := 'RENTAL_VALUE';
      g_template_obj(7).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(7).sf_setup.frs_setup(2).input_value_name := 'Original Cost or Rental';
      g_template_obj(7).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(7).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(3).result_name      := 'ACTUAL_EMPLOYEE_CONTRIBUTION';
      g_template_obj(7).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(7).sf_setup.frs_setup(3).input_value_name := 'Employee Contribution';
      g_template_obj(7).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(7).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(4).result_name      := 'PROJECTED_VALUE';
      g_template_obj(7).sf_setup.frs_setup(4).result_rule_type := 'D';
      g_template_obj(7).sf_setup.frs_setup(4).input_value_name := 'Projected Taxable Value';
      g_template_obj(7).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(7).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(4).exclusion_tag    := 'PROJECT';

      g_template_obj(7).sf_setup.frs_setup(5).result_name      := 'O_STOP_FLAG';
      g_template_obj(7).sf_setup.frs_setup(5).result_rule_type := 'S';
      g_template_obj(7).sf_setup.frs_setup(5).input_value_name := null;
      g_template_obj(7).sf_setup.frs_setup(5).element_name     := null;
      g_template_obj(7).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(6).result_name      := 'EMPR_TAX';
      g_template_obj(7).sf_setup.frs_setup(6).result_rule_type := 'D';
      g_template_obj(7).sf_setup.frs_setup(6).input_value_name := 'Employer Taxable Amount';
      g_template_obj(7).sf_setup.frs_setup(6).element_name     := null;
      g_template_obj(7).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(7).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(7).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(7).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(7).sf_setup.frs_setup(7).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(8).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(7).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(8).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(7).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(9).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(7).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(9).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(7).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(9).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(10).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(7).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(10).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(7).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(10).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(11).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(7).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(11).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(7).sf_setup.frs_setup(11).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(11).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(12).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(7).sf_setup.frs_setup(12).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(12).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(7).sf_setup.frs_setup(12).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(12).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(13).result_name      := 'COMPONENT_NAME';
      g_template_obj(7).sf_setup.frs_setup(13).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(13).input_value_name := 'Component Name';
      g_template_obj(7).sf_setup.frs_setup(13).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(13).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(13).exclusion_tag    := null;

      g_template_obj(7).sf_setup.frs_setup(14).result_name      := 'NON_REC_VALUE';
      g_template_obj(7).sf_setup.frs_setup(14).result_rule_type := 'I';
      g_template_obj(7).sf_setup.frs_setup(14).input_value_name := 'Non Rec Perquisite';
      g_template_obj(7).sf_setup.frs_setup(14).element_name     := 'Employer Tax Projection Element';
      g_template_obj(7).sf_setup.frs_setup(14).severity_level   := null;
      g_template_obj(7).sf_setup.frs_setup(14).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for Company Assets Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Company Assets Template starts
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Add. Element Setup for Company Assets Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR COMPANY ASSETS ENDS
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR OTHER PERQUISITES STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,90);
  g_template_obj(8).template_name  := 'Other Perquisites';
  g_template_obj(8).category       := 'Perquisites';
  g_template_obj(8).priority       := 17000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Other Perquisites Template start
    ----------------------------------------------------------------
    g_template_obj(8).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(8).er_setup(1).value     := 'N';
    g_template_obj(8).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(8).er_setup(1).tag       := 'PROJECT';
    g_template_obj(8).er_setup(1).rule_id   :=  null;

    g_template_obj(8).er_setup(2).ff_column := 'CONFIGURATION_INFORMATION5';
    g_template_obj(8).er_setup(2).value     := 'N';
    g_template_obj(8).er_setup(2).descr     := 'Exclusion rule for Club or Credit Card Perq.';
    g_template_obj(8).er_setup(2).tag       := 'CLUBCREDIT';
    g_template_obj(8).er_setup(2).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for Other Perquisites Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Other Perquisites Template start
    ----------------------------------------------------------------
    g_template_obj(8).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(8).iv_setup(1).uom              := 'M';
    g_template_obj(8).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(8).iv_setup(1).lookup_type      := null;
    g_template_obj(8).iv_setup(1).default_value    := null;
    g_template_obj(8).iv_setup(1).def_value_column := null;
    g_template_obj(8).iv_setup(1).min_value        := null;
    g_template_obj(8).iv_setup(1).warn_or_error    := null;
    g_template_obj(8).iv_setup(1).balance_name     := 'Other Perquisites';
    g_template_obj(8).iv_setup(1).exclusion_tag    := null;

    g_template_obj(8).iv_setup(2).input_value_name := 'Component Name';
    g_template_obj(8).iv_setup(2).uom              := 'C';
    g_template_obj(8).iv_setup(2).mandatory_flag   := 'X';
    g_template_obj(8).iv_setup(2).lookup_type      := null;
    g_template_obj(8).iv_setup(2).default_value    := null;
    g_template_obj(8).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
    g_template_obj(8).iv_setup(2).min_value        := null;
    g_template_obj(8).iv_setup(2).warn_or_error    := null;
    g_template_obj(8).iv_setup(2).balance_name     := null;
    g_template_obj(8).iv_setup(2).exclusion_tag    := null;

    g_template_obj(8).iv_setup(3).input_value_name := 'Cost to Employer';
    g_template_obj(8).iv_setup(3).uom              := 'M';
    g_template_obj(8).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(8).iv_setup(3).lookup_type      := null;
    g_template_obj(8).iv_setup(3).default_value    := null;
    g_template_obj(8).iv_setup(3).def_value_column := null;
    g_template_obj(8).iv_setup(3).min_value        := 0;
    g_template_obj(8).iv_setup(3).warn_or_error    := 'E';
    g_template_obj(8).iv_setup(3).balance_name     := 'Perquisite Employer Contribution';
    g_template_obj(8).iv_setup(3).exclusion_tag    := null;

    g_template_obj(8).iv_setup(4).input_value_name := 'Employee Contribution';
    g_template_obj(8).iv_setup(4).uom              := 'M';
    g_template_obj(8).iv_setup(4).mandatory_flag   := 'N';
    g_template_obj(8).iv_setup(4).lookup_type      := null;
    g_template_obj(8).iv_setup(4).default_value    := null;
    g_template_obj(8).iv_setup(4).def_value_column := null;
    g_template_obj(8).iv_setup(4).min_value        := 0;
    g_template_obj(8).iv_setup(4).warn_or_error    := 'E';
    g_template_obj(8).iv_setup(4).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(8).iv_setup(4).exclusion_tag    := null;

    g_template_obj(8).iv_setup(5).input_value_name := 'Official Purpose Expense';
    g_template_obj(8).iv_setup(5).uom              := 'M';
    g_template_obj(8).iv_setup(5).mandatory_flag   := 'N';
    g_template_obj(8).iv_setup(5).lookup_type      := null;
    g_template_obj(8).iv_setup(5).default_value    := null;
    g_template_obj(8).iv_setup(5).def_value_column := null;
    g_template_obj(8).iv_setup(5).min_value        := 0;
    g_template_obj(8).iv_setup(5).warn_or_error    := 'E';
    g_template_obj(8).iv_setup(5).balance_name     := 'Official Purpose Expense';
    g_template_obj(8).iv_setup(5).exclusion_tag    := 'CLUBCREDIT';

    g_template_obj(8).iv_setup(6).input_value_name := 'Projected Taxable Value';
    g_template_obj(8).iv_setup(6).uom              := 'M';
    g_template_obj(8).iv_setup(6).mandatory_flag   := 'X';
    g_template_obj(8).iv_setup(6).lookup_type      := null;
    g_template_obj(8).iv_setup(6).default_value    := null;
    g_template_obj(8).iv_setup(6).def_value_column := null;
    g_template_obj(8).iv_setup(6).min_value        := null;
    g_template_obj(8).iv_setup(6).warn_or_error    := null;
    g_template_obj(8).iv_setup(6).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(8).iv_setup(6).exclusion_tag    := 'PROJECT';

    g_template_obj(8).iv_setup(7).input_value_name := 'Employer Paid Tax';
    g_template_obj(8).iv_setup(7).uom              := 'C';
    g_template_obj(8).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(8).iv_setup(7).lookup_type      := 'YES_NO';
    g_template_obj(8).iv_setup(7).default_value    := 'N';
    g_template_obj(8).iv_setup(7).def_value_column := null;
    g_template_obj(8).iv_setup(7).min_value        := null;
    g_template_obj(8).iv_setup(7).warn_or_error    := null;
    g_template_obj(8).iv_setup(7).balance_name     := null;
    g_template_obj(8).iv_setup(7).exclusion_tag    := null;

    g_template_obj(8).iv_setup(8).input_value_name := 'Employer Taxable Amount';
    g_template_obj(8).iv_setup(8).uom              := 'M';
    g_template_obj(8).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(8).iv_setup(8).lookup_type      := null;
    g_template_obj(8).iv_setup(8).default_value    := null;
    g_template_obj(8).iv_setup(8).def_value_column := null;
    g_template_obj(8).iv_setup(8).min_value        := 0;
    g_template_obj(8).iv_setup(8).warn_or_error    := 'E';
    g_template_obj(8).iv_setup(8).balance_name     := null;
    g_template_obj(8).iv_setup(8).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for Other Perquisites Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Other Perquisites Template start
    ----------------------------------------------------------------
    g_template_obj(8).bf_setup(1).balance_name     := 'Other Perquisites';
    g_template_obj(8).bf_setup(1).iv_name          := 'Cost to Employer';
    g_template_obj(8).bf_setup(1).scale            := -1;
    g_template_obj(8).bf_setup(1).exclusion_tag    := null;

    g_template_obj(8).bf_setup(2).balance_name     := 'Other Perquisites';
    g_template_obj(8).bf_setup(2).iv_name          := 'Employee Contribution';
    g_template_obj(8).bf_setup(2).scale            := -1;
    g_template_obj(8).bf_setup(2).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Balance Feeds for Other Perquisites Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Other Perquisites Template starts
    ----------------------------------------------------------------
    g_template_obj(8).sf_setup.formula_name   := 'IN_OTHER_PERQUISITES';
    g_template_obj(8).sf_setup.status_rule_id := null;
    g_template_obj(8).sf_setup.description    := null;

      g_template_obj(8).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(8).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(8).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(8).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(8).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(2).result_name      := 'PROJECTED_VALUE';
      g_template_obj(8).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(8).sf_setup.frs_setup(2).input_value_name := 'Projected Taxable Value';
      g_template_obj(8).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(8).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(2).exclusion_tag    := 'PROJECT';

      g_template_obj(8).sf_setup.frs_setup(3).result_name      := 'EMPR_TAX';
      g_template_obj(8).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(8).sf_setup.frs_setup(3).input_value_name := 'Employer Taxable Amount';
      g_template_obj(8).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(8).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(4).result_name      := 'FED_TO_NET_PAY';
      g_template_obj(8).sf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(4).input_value_name := 'Pay Value';
      g_template_obj(8).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(8).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(5).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(8).sf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(5).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(8).sf_setup.frs_setup(5).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(6).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(8).sf_setup.frs_setup(6).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(6).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(8).sf_setup.frs_setup(6).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(7).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(8).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(7).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(8).sf_setup.frs_setup(7).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(8).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(8).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(8).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(8).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(9).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(8).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(9).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(8).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(9).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(10).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(8).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(10).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(8).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(10).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(11).result_name      := 'COMPONENT_NAME';
      g_template_obj(8).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(11).input_value_name := 'Component Name';
      g_template_obj(8).sf_setup.frs_setup(11).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(11).exclusion_tag    := null;

      g_template_obj(8).sf_setup.frs_setup(12).result_name      := 'NON_REC_VALUE';
      g_template_obj(8).sf_setup.frs_setup(12).result_rule_type := 'I';
      g_template_obj(8).sf_setup.frs_setup(12).input_value_name := 'Non Rec Perquisite';
      g_template_obj(8).sf_setup.frs_setup(12).element_name     := 'Employer Tax Projection Element';
      g_template_obj(8).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(8).sf_setup.frs_setup(12).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for Other Perquisites Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Other Perquisites Template starts
    ----------------------------------------------------------------

    g_template_obj(8).ae_setup(1).element_name     := ' Paid MP';
    g_template_obj(8).ae_setup(1).classification   := 'Paid Monetary Perquisite';
    g_template_obj(8).ae_setup(1).exclusion_tag    := 'Perquisite';
    g_template_obj(8).ae_setup(1).priority         := 2000;

      g_template_obj(8).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(8).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(8).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(8).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(8).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(8).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(8).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(8).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(8).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(8).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(8).ae_setup(1).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(8).ae_setup(1).iv_setup(2).uom              := 'C';
      g_template_obj(8).ae_setup(1).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(8).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(8).ae_setup(1).iv_setup(2).default_value    := null;
      g_template_obj(8).ae_setup(1).iv_setup(2).def_value_column := 'CONFIGURATION_INFORMATION1';
      g_template_obj(8).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(8).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(8).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(8).ae_setup(1).iv_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Add. Element Setup for Other Perquisites Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR OTHER PERQUISITES ENDS
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR LEAVE TRAVEL CONCESSION STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,100);
  g_template_obj(9).template_name  := 'Leave Travel Concession';
  g_template_obj(9).category       := 'Earnings';
  g_template_obj(9).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Leave Travel Concession Template start
    ----------------------------------------------------------------
    g_template_obj(9).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(9).er_setup(1).value     := 'N';
    g_template_obj(9).er_setup(1).descr     := 'Exclusion rule for Advances.';
    g_template_obj(9).er_setup(1).tag       := 'ADVANCE';
    g_template_obj(9).er_setup(1).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for Leave Travel Concession Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Leave Travel Concession Template start
    ----------------------------------------------------------------
    g_template_obj(9).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(9).iv_setup(1).uom              := 'M';
    g_template_obj(9).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(9).iv_setup(1).lookup_type      := null;
    g_template_obj(9).iv_setup(1).default_value    := null;
    g_template_obj(9).iv_setup(1).def_value_column := null;
    g_template_obj(9).iv_setup(1).min_value        := null;
    g_template_obj(9).iv_setup(1).warn_or_error    := null;
    g_template_obj(9).iv_setup(1).balance_name     := null;
    g_template_obj(9).iv_setup(1).exclusion_tag    := null;

    g_template_obj(9).iv_setup(2).input_value_name := 'Component Name';
    g_template_obj(9).iv_setup(2).uom              := 'C';
    g_template_obj(9).iv_setup(2).mandatory_flag   := 'X';
    g_template_obj(9).iv_setup(2).lookup_type      := null;
    g_template_obj(9).iv_setup(2).default_value    := 'Leave Travel Concession';
    g_template_obj(9).iv_setup(2).def_value_column := null;
    g_template_obj(9).iv_setup(2).min_value        := null;
    g_template_obj(9).iv_setup(2).warn_or_error    := null;
    g_template_obj(9).iv_setup(2).balance_name     := null;
    g_template_obj(9).iv_setup(2).exclusion_tag    := null;

    g_template_obj(9).iv_setup(3).input_value_name := 'Ticket Fare';
    g_template_obj(9).iv_setup(3).uom              := 'M';
    g_template_obj(9).iv_setup(3).mandatory_flag   := 'Y';
    g_template_obj(9).iv_setup(3).lookup_type      := null;
    g_template_obj(9).iv_setup(3).default_value    := null;
    g_template_obj(9).iv_setup(3).def_value_column := null;
    g_template_obj(9).iv_setup(3).min_value        := 0;
    g_template_obj(9).iv_setup(3).warn_or_error    := 'E';
    g_template_obj(9).iv_setup(3).balance_name     := 'Bills Submitted';
    g_template_obj(9).iv_setup(3).exclusion_tag    := null;

    g_template_obj(9).iv_setup(4).input_value_name := 'LTC Journey Block';
    g_template_obj(9).iv_setup(4).uom              := 'C';
    g_template_obj(9).iv_setup(4).mandatory_flag   := 'Y';
    g_template_obj(9).iv_setup(4).lookup_type      := null;
    g_template_obj(9).iv_setup(4).default_value    := null;
    g_template_obj(9).iv_setup(4).def_value_column := null;
    g_template_obj(9).iv_setup(4).min_value        := null;
    g_template_obj(9).iv_setup(4).warn_or_error    := null;
    g_template_obj(9).iv_setup(4).balance_name     := null;
    g_template_obj(9).iv_setup(4).exclusion_tag    := null;

    g_template_obj(9).iv_setup(5).input_value_name := 'Employer Contribution';
    g_template_obj(9).iv_setup(5).uom              := 'M';
    g_template_obj(9).iv_setup(5).mandatory_flag   := 'Y';
    g_template_obj(9).iv_setup(5).lookup_type      := null;
    g_template_obj(9).iv_setup(5).default_value    := null;
    g_template_obj(9).iv_setup(5).def_value_column := null;
    g_template_obj(9).iv_setup(5).min_value        := 0;
    g_template_obj(9).iv_setup(5).warn_or_error    := 'E';
    g_template_obj(9).iv_setup(5).balance_name     := 'Employer Contribution for LTC';
    g_template_obj(9).iv_setup(5).exclusion_tag    := null;

    g_template_obj(9).iv_setup(6).input_value_name := 'Carryover from Prev Block';
    g_template_obj(9).iv_setup(6).uom              := 'C';
    g_template_obj(9).iv_setup(6).mandatory_flag   := 'N';
    g_template_obj(9).iv_setup(6).lookup_type      := 'YES_NO';
    g_template_obj(9).iv_setup(6).default_value    := null;
    g_template_obj(9).iv_setup(6).def_value_column := null;
    g_template_obj(9).iv_setup(6).min_value        := null;
    g_template_obj(9).iv_setup(6).warn_or_error    := null;
    g_template_obj(9).iv_setup(6).balance_name     := null;
    g_template_obj(9).iv_setup(6).exclusion_tag    := null;

    g_template_obj(9).iv_setup(7).input_value_name := 'Exempted';
    g_template_obj(9).iv_setup(7).uom              := 'C';
    g_template_obj(9).iv_setup(7).mandatory_flag   := 'X';
    g_template_obj(9).iv_setup(7).lookup_type      := 'YES_NO';
    g_template_obj(9).iv_setup(7).default_value    := null;
    g_template_obj(9).iv_setup(7).def_value_column := null;
    g_template_obj(9).iv_setup(7).min_value        := null;
    g_template_obj(9).iv_setup(7).warn_or_error    := null;
    g_template_obj(9).iv_setup(7).balance_name     := null;
    g_template_obj(9).iv_setup(7).exclusion_tag    := null;

    g_template_obj(9).iv_setup(8).input_value_name := 'Sec 17 Adjustment Amount';
    g_template_obj(9).iv_setup(8).uom              := 'M';
    g_template_obj(9).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(9).iv_setup(8).lookup_type      := null;
    g_template_obj(9).iv_setup(8).default_value    := null;
    g_template_obj(9).iv_setup(8).def_value_column := null;
    g_template_obj(9).iv_setup(8).min_value        := null;
    g_template_obj(9).iv_setup(8).warn_or_error    := null;
    g_template_obj(9).iv_setup(8).balance_name     := null;
    g_template_obj(9).iv_setup(8).exclusion_tag    := null;

    g_template_obj(9).iv_setup(9).input_value_name := 'Adjusted Amount';
    g_template_obj(9).iv_setup(9).uom              := 'M';
    g_template_obj(9).iv_setup(9).mandatory_flag   := 'X';
    g_template_obj(9).iv_setup(9).lookup_type      := null;
    g_template_obj(9).iv_setup(9).default_value    := null;
    g_template_obj(9).iv_setup(9).def_value_column := null;
    g_template_obj(9).iv_setup(9).min_value        := null;
    g_template_obj(9).iv_setup(9).warn_or_error    := null;
    g_template_obj(9).iv_setup(9).balance_name     := 'Adjusted Advance for Earnings';
    g_template_obj(9).iv_setup(9).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for Leave Travel Concession Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Leave Travel Concession Template start
    ----------------------------------------------------------------
    g_template_obj(9).bf_setup(1).balance_name     := 'Salary under Section 17';
    g_template_obj(9).bf_setup(1).iv_name          := 'Sec 17 Adjustment Amount';
    g_template_obj(9).bf_setup(1).scale            := -1;
    g_template_obj(9).bf_setup(1).exclusion_tag    := null;

    g_template_obj(9).bf_setup(2).balance_name     := 'Outstanding Advance for Earnings';
    g_template_obj(9).bf_setup(2).iv_name          := 'Adjusted Amount';
    g_template_obj(9).bf_setup(2).scale            := -1;
    g_template_obj(9).bf_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Balance Feeds for Leave Travel Concession Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Leave Travel Concession Template starts
    ----------------------------------------------------------------
    g_template_obj(9).uf_setup.formula_name   := '_LTC_CALC';
    g_template_obj(9).uf_setup.status_rule_id := null;
    g_template_obj(9).uf_setup.description    := 'Formula for Leave Travel Concession';

      g_template_obj(9).uf_setup.frs_setup(1).result_name      := 'PAYABLE_VALUE';
      g_template_obj(9).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(9).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(9).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(9).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(9).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(9).uf_setup.frs_setup(2).result_name      := 'EXEMPTED_AMT';
      g_template_obj(9).uf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(9).uf_setup.frs_setup(2).input_value_name := 'Sec 17 Adjustment Amount';
      g_template_obj(9).uf_setup.frs_setup(2).element_name     := null;
      g_template_obj(9).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(9).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(9).uf_setup.frs_setup(3).result_name      := 'CARRY_OVER_FLAG';
      g_template_obj(9).uf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(9).uf_setup.frs_setup(3).input_value_name := 'Carryover from Prev Block';
      g_template_obj(9).uf_setup.frs_setup(3).element_name     := null;
      g_template_obj(9).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(9).uf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(9).uf_setup.frs_setup(4).result_name      := 'EXEMPTED_FLAG';
      g_template_obj(9).uf_setup.frs_setup(4).result_rule_type := 'D';
      g_template_obj(9).uf_setup.frs_setup(4).input_value_name := 'Exempted';
      g_template_obj(9).uf_setup.frs_setup(4).element_name     := null;
      g_template_obj(9).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(9).uf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(9).uf_setup.frs_setup(5).result_name      := 'ADJUSTED_ADVANCE';
      g_template_obj(9).uf_setup.frs_setup(5).result_rule_type := 'D';
      g_template_obj(9).uf_setup.frs_setup(5).input_value_name := 'Adjusted Amount';
      g_template_obj(9).uf_setup.frs_setup(5).element_name     := null;
      g_template_obj(9).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(9).uf_setup.frs_setup(5).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Formula Setup for Leave Travel Concession Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Leave Travel Concession Template starts
    ----------------------------------------------------------------
    g_template_obj(9).ae_setup(1).element_name     := ' Advance';
    g_template_obj(9).ae_setup(1).classification   := 'Advances';
    g_template_obj(9).ae_setup(1).exclusion_tag    := 'ADVANCE';
    g_template_obj(9).ae_setup(1).priority         := -2000;

      g_template_obj(9).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(9).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(9).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(9).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(9).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(9).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(9).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(9).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(9).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).iv_setup(2).input_value_name := 'Advance Amount';
      g_template_obj(9).ae_setup(1).iv_setup(2).uom              := 'M';
      g_template_obj(9).ae_setup(1).iv_setup(2).mandatory_flag   := 'N';
      g_template_obj(9).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(9).ae_setup(1).iv_setup(2).default_value    := null;
      g_template_obj(9).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(9).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(9).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(9).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(9).ae_setup(1).iv_setup(2).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).iv_setup(3).input_value_name := 'Excess Advance';
      g_template_obj(9).ae_setup(1).iv_setup(3).uom              := 'C';
      g_template_obj(9).ae_setup(1).iv_setup(3).mandatory_flag   := 'Y';
      g_template_obj(9).ae_setup(1).iv_setup(3).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(9).ae_setup(1).iv_setup(3).default_value    := 'PENDING';
      g_template_obj(9).ae_setup(1).iv_setup(3).def_value_column := null;
      g_template_obj(9).ae_setup(1).iv_setup(3).min_value        := null;
      g_template_obj(9).ae_setup(1).iv_setup(3).warn_or_error    := null;
      g_template_obj(9).ae_setup(1).iv_setup(3).balance_name     := null;
      g_template_obj(9).ae_setup(1).iv_setup(3).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).iv_setup(4).input_value_name := 'Add to Net Pay';
      g_template_obj(9).ae_setup(1).iv_setup(4).uom              := 'C';
      g_template_obj(9).ae_setup(1).iv_setup(4).mandatory_flag   := 'Y';
      g_template_obj(9).ae_setup(1).iv_setup(4).lookup_type      := 'YES_NO';
      g_template_obj(9).ae_setup(1).iv_setup(4).default_value    := 'Y';
      g_template_obj(9).ae_setup(1).iv_setup(4).def_value_column := null;
      g_template_obj(9).ae_setup(1).iv_setup(4).min_value        := null;
      g_template_obj(9).ae_setup(1).iv_setup(4).warn_or_error    := null;
      g_template_obj(9).ae_setup(1).iv_setup(4).balance_name     := null;
      g_template_obj(9).ae_setup(1).iv_setup(4).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).iv_setup(5).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(1).iv_setup(5).uom              := 'C';
      g_template_obj(9).ae_setup(1).iv_setup(5).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(1).iv_setup(5).lookup_type      := null;
      g_template_obj(9).ae_setup(1).iv_setup(5).default_value    := 'Leave Travel Concession';
      g_template_obj(9).ae_setup(1).iv_setup(5).def_value_column := null;
      g_template_obj(9).ae_setup(1).iv_setup(5).min_value        := null;
      g_template_obj(9).ae_setup(1).iv_setup(5).warn_or_error    := null;
      g_template_obj(9).ae_setup(1).iv_setup(5).balance_name     := null;
      g_template_obj(9).ae_setup(1).iv_setup(5).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).bf_setup(1).balance_name     := 'Advance for Earnings';
      g_template_obj(9).ae_setup(1).bf_setup(1).iv_name          := 'Advance Amount';
      g_template_obj(9).ae_setup(1).bf_setup(1).scale            := 1;
      g_template_obj(9).ae_setup(1).bf_setup(1).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).bf_setup(2).balance_name     := 'Outstanding Advance for Earnings';
      g_template_obj(9).ae_setup(1).bf_setup(2).iv_name          := 'Advance Amount';
      g_template_obj(9).ae_setup(1).bf_setup(2).scale            := 1;
      g_template_obj(9).ae_setup(1).bf_setup(2).exclusion_tag    := null;

    g_template_obj(9).ae_setup(1).uf_setup.formula_name   := '_LTC_ADV_CALC';
    g_template_obj(9).ae_setup(1).uf_setup.status_rule_id := null;
    g_template_obj(9).ae_setup(1).uf_setup.description    := 'Advance Calculations for Earnings';


      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(1).result_name      := 'PAYABLE_VALUE';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(2).result_name      := 'EXCESS_ADVANCE';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(2).input_value_name := 'Excess Advance';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(2).element_name     := ' Excess Advance';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(3).result_name      := 'COMPONENT_NAME';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(3).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(3).element_name     := ' Excess Advance';
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(9).ae_setup(1).uf_setup.frs_setup(3).exclusion_tag    := null;


    g_template_obj(9).ae_setup(2).element_name     := ' Adjust';
    g_template_obj(9).ae_setup(2).classification   := 'Earnings';
    g_template_obj(9).ae_setup(2).exclusion_tag    := 'ADVANCE';
    g_template_obj(9).ae_setup(2).priority         := 14000;

      g_template_obj(9).ae_setup(2).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(9).ae_setup(2).iv_setup(1).uom              := 'M';
      g_template_obj(9).ae_setup(2).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(2).iv_setup(1).lookup_type      := null;
      g_template_obj(9).ae_setup(2).iv_setup(1).default_value    := null;
      g_template_obj(9).ae_setup(2).iv_setup(1).def_value_column := null;
      g_template_obj(9).ae_setup(2).iv_setup(1).min_value        := null;
      g_template_obj(9).ae_setup(2).iv_setup(1).warn_or_error    := null;
      g_template_obj(9).ae_setup(2).iv_setup(1).balance_name     := null;
      g_template_obj(9).ae_setup(2).iv_setup(1).exclusion_tag    := null;

      g_template_obj(9).ae_setup(2).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(2).iv_setup(2).uom              := 'C';
      g_template_obj(9).ae_setup(2).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(2).iv_setup(2).lookup_type      := null;
      g_template_obj(9).ae_setup(2).iv_setup(2).default_value    := 'Leave Travel Concession';
      g_template_obj(9).ae_setup(2).iv_setup(2).def_value_column := null;
      g_template_obj(9).ae_setup(2).iv_setup(2).min_value        := null;
      g_template_obj(9).ae_setup(2).iv_setup(2).warn_or_error    := null;
      g_template_obj(9).ae_setup(2).iv_setup(2).balance_name     := null;
      g_template_obj(9).ae_setup(2).iv_setup(2).exclusion_tag    := null;

      g_template_obj(9).ae_setup(2).bf_setup(1).balance_name     := 'Outstanding Advance for Earnings';
      g_template_obj(9).ae_setup(2).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(9).ae_setup(2).bf_setup(1).scale            := -1;
      g_template_obj(9).ae_setup(2).bf_setup(1).exclusion_tag    := null;

    g_template_obj(9).ae_setup(3).element_name     := ' Recover';
    g_template_obj(9).ae_setup(3).classification   := 'Voluntary Deductions';
    g_template_obj(9).ae_setup(3).exclusion_tag    := 'ADVANCE';
    g_template_obj(9).ae_setup(3).priority         := 36000;

      g_template_obj(9).ae_setup(3).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(9).ae_setup(3).iv_setup(1).uom              := 'M';
      g_template_obj(9).ae_setup(3).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(3).iv_setup(1).lookup_type      := null;
      g_template_obj(9).ae_setup(3).iv_setup(1).default_value    := null;
      g_template_obj(9).ae_setup(3).iv_setup(1).def_value_column := null;
      g_template_obj(9).ae_setup(3).iv_setup(1).min_value        := null;
      g_template_obj(9).ae_setup(3).iv_setup(1).warn_or_error    := null;
      g_template_obj(9).ae_setup(3).iv_setup(1).balance_name     := null;
      g_template_obj(9).ae_setup(3).iv_setup(1).exclusion_tag    := null;

      g_template_obj(9).ae_setup(3).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(3).iv_setup(2).uom              := 'C';
      g_template_obj(9).ae_setup(3).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(3).iv_setup(2).lookup_type      := null;
      g_template_obj(9).ae_setup(3).iv_setup(2).default_value    := 'Leave Travel Concession';
      g_template_obj(9).ae_setup(3).iv_setup(2).def_value_column := null;
      g_template_obj(9).ae_setup(3).iv_setup(2).min_value        := null;
      g_template_obj(9).ae_setup(3).iv_setup(2).warn_or_error    := null;
      g_template_obj(9).ae_setup(3).iv_setup(2).balance_name     := null;
      g_template_obj(9).ae_setup(3).iv_setup(2).exclusion_tag    := null;

      g_template_obj(9).ae_setup(3).iv_setup(3).input_value_name := 'Adjustment Amount';
      g_template_obj(9).ae_setup(3).iv_setup(3).uom              := 'M';
      g_template_obj(9).ae_setup(3).iv_setup(3).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(3).iv_setup(3).lookup_type      := null;
      g_template_obj(9).ae_setup(3).iv_setup(3).default_value    := null;
      g_template_obj(9).ae_setup(3).iv_setup(3).def_value_column := null;
      g_template_obj(9).ae_setup(3).iv_setup(3).min_value        := null;
      g_template_obj(9).ae_setup(3).iv_setup(3).warn_or_error    := null;
      g_template_obj(9).ae_setup(3).iv_setup(3).balance_name     := 'Outstanding Advance for Earnings';
      g_template_obj(9).ae_setup(3).iv_setup(3).exclusion_tag    := null;

      g_template_obj(9).ae_setup(3).bf_setup(1).balance_name     := 'Outstanding Advance for Earnings';
      g_template_obj(9).ae_setup(3).bf_setup(1).iv_name          := 'Pay Value';
      g_template_obj(9).ae_setup(3).bf_setup(1).scale            := -1;
      g_template_obj(9).ae_setup(3).bf_setup(1).exclusion_tag    := null;


    g_template_obj(9).ae_setup(4).element_name     := ' Excess Advance';
    g_template_obj(9).ae_setup(4).classification   := 'Information';
    g_template_obj(9).ae_setup(4).exclusion_tag    := 'ADVANCE';
    g_template_obj(9).ae_setup(4).priority         := 12000;

      g_template_obj(9).ae_setup(4).iv_setup(1).input_value_name := 'Excess Advance';
      g_template_obj(9).ae_setup(4).iv_setup(1).uom              := 'C';
      g_template_obj(9).ae_setup(4).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(4).iv_setup(1).lookup_type      := 'IN_ADVANCE_OPTIONS';
      g_template_obj(9).ae_setup(4).iv_setup(1).default_value    := 'PENDING';
      g_template_obj(9).ae_setup(4).iv_setup(1).def_value_column := null;
      g_template_obj(9).ae_setup(4).iv_setup(1).min_value        := null;
      g_template_obj(9).ae_setup(4).iv_setup(1).warn_or_error    := null;
      g_template_obj(9).ae_setup(4).iv_setup(1).balance_name     := null;
      g_template_obj(9).ae_setup(4).iv_setup(1).exclusion_tag    := null;

      g_template_obj(9).ae_setup(4).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(4).iv_setup(2).uom              := 'C';
      g_template_obj(9).ae_setup(4).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(9).ae_setup(4).iv_setup(2).lookup_type      := null;
      g_template_obj(9).ae_setup(4).iv_setup(2).default_value    := 'Leave Travel Concession';
      g_template_obj(9).ae_setup(4).iv_setup(2).def_value_column := null;
      g_template_obj(9).ae_setup(4).iv_setup(2).min_value        := null;
      g_template_obj(9).ae_setup(4).iv_setup(2).warn_or_error    := null;
      g_template_obj(9).ae_setup(4).iv_setup(2).balance_name     := null;
      g_template_obj(9).ae_setup(4).iv_setup(2).exclusion_tag    := null;

    g_template_obj(9).ae_setup(4).uf_setup.formula_name   := '_LTC_EXC_ADV';
    g_template_obj(9).ae_setup(4).uf_setup.status_rule_id := null;
    g_template_obj(9).ae_setup(4).uf_setup.description    := 'Excess Advance Calculations for Actual allowances';

      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(1).result_name      := 'ADJUSTMENT_AMT';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(1).result_rule_type := 'I';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(1).input_value_name := 'Adjustment Amount';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(1).element_name     := ' Recover';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(1).exclusion_tag    := null;


      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(2).result_name      := 'RECOVERED_ADVANCE';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(2).result_rule_type := 'I';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(2).input_value_name := 'Pay Value';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(2).element_name     := ' Recover';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(2).exclusion_tag    := null;

      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(3).result_name      := 'SALARY_SEC171';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(3).result_rule_type := 'I';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(3).input_value_name := 'Pay Value';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(3).element_name     := ' Adjust';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(4).result_name      := 'COMPONENT_NAME_PAY';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(4).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(4).element_name     := ' Adjust';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(5).result_name      := 'COMPONENT_NAME_REC';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(5).input_value_name := 'Component Name';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(5).element_name     := ' Recover';
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(9).ae_setup(4).uf_setup.frs_setup(5).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Add. Element Setup for Leave Travel Concession Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR LEAVE TRAVEL CONCESSION ENDS
  ----------------------------------------------------------------
  ----------------------------------------------------------------
  --  TEMPLATE FOR EARNINGS STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,120);
  g_template_obj(10).template_name  := 'Earnings';
  g_template_obj(10).category       := 'Earnings';
  g_template_obj(10).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for Earnings Template start
    ----------------------------------------------------------------
    g_template_obj(10).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION1';
    g_template_obj(10).er_setup(1).value     := 'N';
    g_template_obj(10).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(10).er_setup(1).tag       := 'PROJECT';
    g_template_obj(10).er_setup(1).rule_id   :=  null;

    g_template_obj(10).er_setup(2).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(10).er_setup(2).value     := 'N';
    g_template_obj(10).er_setup(2).descr     := 'Exclusion rule for ESI Eligibility.';
    g_template_obj(10).er_setup(2).tag       := 'ESIELIG';
    g_template_obj(10).er_setup(2).rule_id   :=  null;

    g_template_obj(10).er_setup(3).ff_column := 'CONFIGURATION_INFORMATION3';
    g_template_obj(10).er_setup(3).value     := 'N';
    g_template_obj(10).er_setup(3).descr     := 'Exclusion rule for ESI Computation.';
    g_template_obj(10).er_setup(3).tag       := 'ESICOMP';
    g_template_obj(10).er_setup(3).rule_id   :=  null;

    g_template_obj(10).er_setup(4).ff_column := 'CONFIGURATION_INFORMATION4';
    g_template_obj(10).er_setup(4).value     := 'N';
    g_template_obj(10).er_setup(4).descr     := 'Exclusion rule for PF Computation.';
    g_template_obj(10).er_setup(4).tag       := 'SPFCOMP';
    g_template_obj(10).er_setup(4).rule_id   :=  null;

    g_template_obj(10).er_setup(5).ff_column := 'CONFIGURATION_INFORMATION5';
    g_template_obj(10).er_setup(5).value     := 'N';
    g_template_obj(10).er_setup(5).descr     := 'Exclusion rule for PT Computation.';
    g_template_obj(10).er_setup(5).tag       := 'SPTCOMP';
    g_template_obj(10).er_setup(5).rule_id   :=  null;

    g_template_obj(10).er_setup(6).ff_column := 'CONFIGURATION_INFORMATION6';
    g_template_obj(10).er_setup(6).value     := 'N';
    g_template_obj(10).er_setup(6).descr     := 'Exclusion rule for HRA and Related Exemptions.';
    g_template_obj(10).er_setup(6).tag       := 'HRACOMP';
    g_template_obj(10).er_setup(6).rule_id   :=  null;

    g_template_obj(10).er_setup(7).ff_column := 'CONFIGURATION_INFORMATION7';
    g_template_obj(10).er_setup(7).value     := 'N';
    g_template_obj(10).er_setup(7).descr     := 'Exclusion rule for Company Accommodation.';
    g_template_obj(10).er_setup(7).tag       := 'CMACOMP';
    g_template_obj(10).er_setup(7).rule_id   :=  null;

    g_template_obj(10).er_setup(8).ff_column := 'CONFIGURATION_INFORMATION8';
    g_template_obj(10).er_setup(8).value     := 'N';
    g_template_obj(10).er_setup(8).descr     := 'Exclusion rule for Notice Pay Base.';
    g_template_obj(10).er_setup(8).tag       := 'TNPCOMP';
    g_template_obj(10).er_setup(8).rule_id   :=  null;

    g_template_obj(10).er_setup(9).ff_column := 'CONFIGURATION_INFORMATION9';
    g_template_obj(10).er_setup(9).value     := 'N';
    g_template_obj(10).er_setup(9).descr     := 'Exclusion rule for Leave Encashment Base.';
    g_template_obj(10).er_setup(9).tag       := 'TLECOMP';
    g_template_obj(10).er_setup(9).rule_id   :=  null;

    g_template_obj(10).er_setup(10).ff_column := 'CONFIGURATION_INFORMATION10';
    g_template_obj(10).er_setup(10).value     := 'N';
    g_template_obj(10).er_setup(10).descr     := 'Exclusion rule for Gratuity Eligibility.';
    g_template_obj(10).er_setup(10).tag       := 'TGPCOMP';
    g_template_obj(10).er_setup(10).rule_id   :=  null;

    g_template_obj(10).er_setup(11).ff_column := 'CONFIGURATION_INFORMATION11';
    g_template_obj(10).er_setup(11).value     := 'N';
    g_template_obj(10).er_setup(11).descr     := 'Exclusion rule for Pension Computation Salary.';
    g_template_obj(10).er_setup(11).tag       := 'TPCSCOMP';
    g_template_obj(10).er_setup(11).rule_id   :=  null;

    g_template_obj(10).er_setup(12).ff_column := 'CONFIGURATION_INFORMATION12';
    g_template_obj(10).er_setup(12).value     := 'N';
    g_template_obj(10).er_setup(12).descr     := 'Exclusion rule for Pension Exemption Salary.';
    g_template_obj(10).er_setup(12).tag       := 'TPESCOMP';
    g_template_obj(10).er_setup(12).rule_id   :=  null;

    g_template_obj(10).er_setup(13).ff_column := 'CONFIGURATION_INFORMATION13';
    g_template_obj(10).er_setup(13).value     := 'N';
    g_template_obj(10).er_setup(13).descr     := 'Exclusion rule for PT Projection.';
    g_template_obj(10).er_setup(13).tag       := 'SPTPROJ';
    g_template_obj(10).er_setup(13).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for Earnings Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for Earnings Template start
    ----------------------------------------------------------------
    g_template_obj(10).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(10).iv_setup(1).uom              := 'M';
    g_template_obj(10).iv_setup(1).mandatory_flag   := 'N';
    g_template_obj(10).iv_setup(1).lookup_type      := null;
    g_template_obj(10).iv_setup(1).default_value    := null;
    g_template_obj(10).iv_setup(1).def_value_column := null;
    g_template_obj(10).iv_setup(1).min_value        := null;
    g_template_obj(10).iv_setup(1).warn_or_error    := null;
    g_template_obj(10).iv_setup(1).balance_name     := null;
    g_template_obj(10).iv_setup(1).exclusion_tag    := null;

    g_template_obj(10).iv_setup(2).input_value_name := 'Standard Value';
    g_template_obj(10).iv_setup(2).uom              := 'M';
    g_template_obj(10).iv_setup(2).mandatory_flag   := 'N';
    g_template_obj(10).iv_setup(2).lookup_type      := null;
    g_template_obj(10).iv_setup(2).default_value    := null;
    g_template_obj(10).iv_setup(2).def_value_column := null;
    g_template_obj(10).iv_setup(2).min_value        := null;
    g_template_obj(10).iv_setup(2).warn_or_error    := null;
    g_template_obj(10).iv_setup(2).balance_name     := null;
    g_template_obj(10).iv_setup(2).exclusion_tag    := 'PROJECT';

    ----------------------------------------------------------------
    --  Input Values for Earnings Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for Earnings Template start
    ----------------------------------------------------------------
    g_template_obj(10).bf_setup(1).balance_name     := 'ESI Eligible Salary';
    g_template_obj(10).bf_setup(1).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(1).scale            := 1;
    g_template_obj(10).bf_setup(1).exclusion_tag    := 'ESIELIG';

    g_template_obj(10).bf_setup(2).balance_name     := 'ESI Computation Salary';
    g_template_obj(10).bf_setup(2).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(2).scale            := 1;
    g_template_obj(10).bf_setup(2).exclusion_tag    := 'ESICOMP';

    g_template_obj(10).bf_setup(3).balance_name     := 'Earnings for Projection';
    g_template_obj(10).bf_setup(3).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(3).scale            := 1;
    g_template_obj(10).bf_setup(3).exclusion_tag    := 'PROJECT';

    g_template_obj(10).bf_setup(4).balance_name     := 'PF Computation Salary';
    g_template_obj(10).bf_setup(4).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(4).scale            := 1;
    g_template_obj(10).bf_setup(4).exclusion_tag    := 'SPFCOMP';

    g_template_obj(10).bf_setup(5).balance_name     := 'Professional Tax Salary';
    g_template_obj(10).bf_setup(5).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(5).scale            := 1;
    g_template_obj(10).bf_setup(5).exclusion_tag    := 'SPTCOMP';

    g_template_obj(10).bf_setup(6).balance_name     := 'Salary for HRA and Related Exemptions';
    g_template_obj(10).bf_setup(6).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(6).scale            := 1;
    g_template_obj(10).bf_setup(6).exclusion_tag    := 'HRACOMP';

    g_template_obj(10).bf_setup(7).balance_name     := 'Salary for Company Accommodation';
    g_template_obj(10).bf_setup(7).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(7).scale            := 1;
    g_template_obj(10).bf_setup(7).exclusion_tag    := 'CMACOMP';

    g_template_obj(10).bf_setup(8).balance_name     := 'Salary for Notice Period';
    g_template_obj(10).bf_setup(8).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(8).scale            := 1;
    g_template_obj(10).bf_setup(8).exclusion_tag    := 'TNPCOMP';

    g_template_obj(10).bf_setup(9).balance_name     := 'Salary for Leave Encashment';
    g_template_obj(10).bf_setup(9).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(9).scale            := 1;
    g_template_obj(10).bf_setup(9).exclusion_tag    := 'TLECOMP';

    g_template_obj(10).bf_setup(10).balance_name     := 'Gratuity Eligible Salary';
    g_template_obj(10).bf_setup(10).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(10).scale            := 1;
    g_template_obj(10).bf_setup(10).exclusion_tag    := 'TGPCOMP';

    g_template_obj(10).bf_setup(11).balance_name     := 'PF Computation Standard Salary';
    g_template_obj(10).bf_setup(11).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(11).scale            := 1;
    g_template_obj(10).bf_setup(11).exclusion_tag    := 'SPFCOMP';

    g_template_obj(10).bf_setup(12).balance_name     := 'Standard Salary for HRA and Related Exemptions';
    g_template_obj(10).bf_setup(12).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(12).scale            := 1;
    g_template_obj(10).bf_setup(12).exclusion_tag    := 'HRACOMP';

    g_template_obj(10).bf_setup(13).balance_name     := 'Standard Salary for Company Accommodation';
    g_template_obj(10).bf_setup(13).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(13).scale            := 1;
    g_template_obj(10).bf_setup(13).exclusion_tag    := 'CMACOMP';

    g_template_obj(10).bf_setup(14).balance_name     := 'Pension Computation Salary';
    g_template_obj(10).bf_setup(14).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(14).scale            := 1;
    g_template_obj(10).bf_setup(14).exclusion_tag    := 'TPCSCOMP';

    g_template_obj(10).bf_setup(15).balance_name     := 'Pension Computation Standard Salary';
    g_template_obj(10).bf_setup(15).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(15).scale            := 1;
    g_template_obj(10).bf_setup(15).exclusion_tag    := 'TPCSCOMP';

    g_template_obj(10).bf_setup(16).balance_name     := 'Pension Exemption Salary';
    g_template_obj(10).bf_setup(16).iv_name          := 'Pay Value';
    g_template_obj(10).bf_setup(16).scale            := 1;
    g_template_obj(10).bf_setup(16).exclusion_tag    := 'TPESCOMP';

    g_template_obj(10).bf_setup(17).balance_name     := 'Pension Exemption Standard Salary';
    g_template_obj(10).bf_setup(17).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(17).scale            := 1;
    g_template_obj(10).bf_setup(17).exclusion_tag    := 'TPESCOMP';

    g_template_obj(10).bf_setup(18).balance_name     := 'Professional Tax Salary for Projection';
    g_template_obj(10).bf_setup(18).iv_name          := 'Standard Value';
    g_template_obj(10).bf_setup(18).scale            := 1;
    g_template_obj(10).bf_setup(18).exclusion_tag    := 'SPTPROJ';


    ----------------------------------------------------------------
    --  Balance Feeds for Earnings Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for Earnings Template starts
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Formula Setup for Earnings Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for Earnings Template starts
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Add. Element Setup for Earnings Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR EARNINGS ENDS
  ----------------------------------------------------------------

-------------------------------------------------------------
---- TEMPLATE FOR TRANSFER OF COMPANY ASSETS STARTS
-------------------------------------------------------------

pay_in_utils.set_location(g_debug, l_procedure, 130 );
g_template_obj(11).template_name  := 'Transfer of Company Assets';
g_template_obj(11).category := 'Perquisites';
g_template_obj(11).priority :=  17000;


--------------------------------------------------------------
---  INPUT VALUES FOR TRANSFER OF COMPANY ASSETS STARTS
--------------------------------------------------------------

         g_template_obj(11).iv_setup(1).input_value_name := 'Pay Value';
         g_template_obj(11).iv_setup(1).uom              := 'M';
         g_template_obj(11).iv_setup(1).mandatory_flag   := 'X';
         g_template_obj(11).iv_setup(1).lookup_type      := null;
         g_template_obj(11).iv_setup(1).default_value    := null;
	 g_template_obj(11).iv_setup(1).def_value_column := null;
         g_template_obj(11).iv_setup(1).min_value        := null;
         g_template_obj(11).iv_setup(1).warn_or_error    := null;
         g_template_obj(11).iv_setup(1).balance_name     := null;
	 g_template_obj(11).iv_setup(1).exclusion_tag    := null;

         g_template_obj(11).iv_setup(2).input_value_name := 'Asset Category';
         g_template_obj(11).iv_setup(2).uom              := 'C';
         g_template_obj(11).iv_setup(2).mandatory_flag   := 'Y';
         g_template_obj(11).iv_setup(2).lookup_type      := 'IN_ASSET_TYPE_TRANSFER';
         g_template_obj(11).iv_setup(2).default_value    := null;
	 g_template_obj(11).iv_setup(2).def_value_column := null;
         g_template_obj(11).iv_setup(2).min_value        := null;
         g_template_obj(11).iv_setup(2).warn_or_error    := null;
         g_template_obj(11).iv_setup(2).balance_name     := null;
	 g_template_obj(11).iv_setup(2).exclusion_tag    := null;

         g_template_obj(11).iv_setup(3).input_value_name := 'Asset Description';
         g_template_obj(11).iv_setup(3).uom              := 'C';
         g_template_obj(11).iv_setup(3).mandatory_flag   := 'N';
         g_template_obj(11).iv_setup(3).lookup_type      := null;
         g_template_obj(11).iv_setup(3).default_value    := null;
	 g_template_obj(11).iv_setup(3).def_value_column := null;
         g_template_obj(11).iv_setup(3).min_value        := null;
         g_template_obj(11).iv_setup(3).warn_or_error    := null;
         g_template_obj(11).iv_setup(3).balance_name     := null;
	 g_template_obj(11).iv_setup(3).exclusion_tag    := null;

         g_template_obj(11).iv_setup(4).input_value_name := 'Original Cost';
         g_template_obj(11).iv_setup(4).uom              := 'M';
         g_template_obj(11).iv_setup(4).mandatory_flag   := 'Y';
         g_template_obj(11).iv_setup(4).lookup_type      := null;
         g_template_obj(11).iv_setup(4).default_value    := null;
	 g_template_obj(11).iv_setup(4).def_value_column := null;
         g_template_obj(11).iv_setup(4).min_value        := 0;
         g_template_obj(11).iv_setup(4).warn_or_error    := 'E';
         g_template_obj(11).iv_setup(4).balance_name     := null;
	 g_template_obj(11).iv_setup(4).exclusion_tag    := null;

         g_template_obj(11).iv_setup(5).input_value_name := 'Date of Purchase';
         g_template_obj(11).iv_setup(5).uom              := 'D';
         g_template_obj(11).iv_setup(5).mandatory_flag   := 'Y';
         g_template_obj(11).iv_setup(5).lookup_type      := null;
         g_template_obj(11).iv_setup(5).default_value    := null;
	 g_template_obj(11).iv_setup(5).def_value_column := null;
         g_template_obj(11).iv_setup(5).min_value        := null;
         g_template_obj(11).iv_setup(5).warn_or_error    := null;
         g_template_obj(11).iv_setup(5).balance_name     := null;
	 g_template_obj(11).iv_setup(5).exclusion_tag    := null;

         g_template_obj(11).iv_setup(6).input_value_name := 'Employee Contribution';
         g_template_obj(11).iv_setup(6).uom              := 'M';
         g_template_obj(11).iv_setup(6).mandatory_flag   := 'N';
         g_template_obj(11).iv_setup(6).lookup_type      := null;
         g_template_obj(11).iv_setup(6).default_value    := null;
	 g_template_obj(11).iv_setup(6).def_value_column := null;
         g_template_obj(11).iv_setup(6).min_value        := 0;
         g_template_obj(11).iv_setup(6).warn_or_error    := 'E';
         g_template_obj(11).iv_setup(6).balance_name     :='Perquisite Employee Contribution';
	 g_template_obj(11).iv_setup(6).exclusion_tag    := null;

         g_template_obj(11).iv_setup(7).input_value_name := 'Component Name';
         g_template_obj(11).iv_setup(7).uom              := 'C';
         g_template_obj(11).iv_setup(7).mandatory_flag   := 'X';
         g_template_obj(11).iv_setup(7).lookup_type      := null;
         g_template_obj(11).iv_setup(7).default_value    := 'Transfer of Company Assets';
	 g_template_obj(11).iv_setup(7).def_value_column := null;
         g_template_obj(11).iv_setup(7).min_value        := null;
         g_template_obj(11).iv_setup(7).warn_or_error    := null;
         g_template_obj(11).iv_setup(7).balance_name     := null;
	 g_template_obj(11).iv_setup(7).exclusion_tag    := null;

         g_template_obj(11).iv_setup(8).input_value_name := 'Employer Paid Tax';
         g_template_obj(11).iv_setup(8).uom              := 'C';
         g_template_obj(11).iv_setup(8).mandatory_flag   := 'Y';
         g_template_obj(11).iv_setup(8).lookup_type      := 'YES_NO';
         g_template_obj(11).iv_setup(8).default_value    := 'N';
	 g_template_obj(11).iv_setup(8).def_value_column := null;
         g_template_obj(11).iv_setup(8).min_value        := null;
         g_template_obj(11).iv_setup(8).warn_or_error    := null;
         g_template_obj(11).iv_setup(8).balance_name     := null;
	 g_template_obj(11).iv_setup(8).exclusion_tag    := null;

         g_template_obj(11).iv_setup(9).input_value_name := 'Employer Taxable Amount';
         g_template_obj(11).iv_setup(9).uom              := 'M';
         g_template_obj(11).iv_setup(9).mandatory_flag   := 'X';
         g_template_obj(11).iv_setup(9).lookup_type      := null;
         g_template_obj(11).iv_setup(9).default_value    := null;
	 g_template_obj(11).iv_setup(9).def_value_column := null;
         g_template_obj(11).iv_setup(9).min_value        := 0;
         g_template_obj(11).iv_setup(9).warn_or_error    := 'E';
         g_template_obj(11).iv_setup(9).balance_name     := null;
	 g_template_obj(11).iv_setup(9).exclusion_tag    := null;

--------------------------------------------------------------
---  INPUT VALUES FOR TRANSFER OF COMPANY ASSETS ENDS
--------------------------------------------------------------


--------------------------------------------------------------
---  FORMULAE SET UP FOR TRANSFER OF COMPANY ASSETS STARTS
--------------------------------------------------------------
  g_template_obj(11).sf_setup.formula_name   := 'IN_TRANSFER_OF_ASSETS';
  g_template_obj(11).sf_setup.status_rule_id := null;
  g_template_obj(11).sf_setup.description    := null;

  g_template_obj(11).sf_setup.frs_setup(1).result_name      := 'PERQUISITE_VALUE';
  g_template_obj(11).sf_setup.frs_setup(1).result_rule_type := 'D';
  g_template_obj(11).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
  g_template_obj(11).sf_setup.frs_setup(1).element_name     := null;
  g_template_obj(11).sf_setup.frs_setup(1).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(1).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(2).result_name      := 'EMPR_TAX';
  g_template_obj(11).sf_setup.frs_setup(2).result_rule_type := 'D';
  g_template_obj(11).sf_setup.frs_setup(2).input_value_name := 'Employer Taxable Amount';
  g_template_obj(11).sf_setup.frs_setup(2).element_name     := null;
  g_template_obj(11).sf_setup.frs_setup(2).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(2).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(3).result_name      := 'ER_MP_TAXABLE_AMOUNT';
  g_template_obj(11).sf_setup.frs_setup(3).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(3).input_value_name := 'ER MP Taxable Amount';
  g_template_obj(11).sf_setup.frs_setup(3).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(3).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(3).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(4).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
  g_template_obj(11).sf_setup.frs_setup(4).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(4).input_value_name := 'Projected ER MP Taxable Amt';
  g_template_obj(11).sf_setup.frs_setup(4).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(4).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(4).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(5).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
  g_template_obj(11).sf_setup.frs_setup(5).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(5).input_value_name := 'ER MP Salary to be Excluded';
  g_template_obj(11).sf_setup.frs_setup(5).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(5).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(5).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(6).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
  g_template_obj(11).sf_setup.frs_setup(6).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(6).input_value_name := 'ER NMP Taxable Amount';
  g_template_obj(11).sf_setup.frs_setup(6).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(6).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(6).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(7).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
  g_template_obj(11).sf_setup.frs_setup(7).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(7).input_value_name := 'Projected ER NMP Taxable Amt';
  g_template_obj(11).sf_setup.frs_setup(7).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(7).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(7).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(8).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
  g_template_obj(11).sf_setup.frs_setup(8).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(8).input_value_name := 'ER NMP Salary to be Excluded';
  g_template_obj(11).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(8).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(8).exclusion_tag    := null;


  g_template_obj(11).sf_setup.frs_setup(9).result_name      := 'COMPONENT_NAME';
  g_template_obj(11).sf_setup.frs_setup(9).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(9).input_value_name := 'Component Name';
  g_template_obj(11).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(9).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(9).exclusion_tag    := null;

  g_template_obj(11).sf_setup.frs_setup(10).result_name      := 'NON_REC_VALUE';
  g_template_obj(11).sf_setup.frs_setup(10).result_rule_type := 'I';
  g_template_obj(11).sf_setup.frs_setup(10).input_value_name := 'Non Rec Perquisite';
  g_template_obj(11).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
  g_template_obj(11).sf_setup.frs_setup(10).severity_level   := null;
  g_template_obj(11).sf_setup.frs_setup(10).exclusion_tag    := null;
--------------------------------------------------------------
---  FORMULAE SET UP FOR TRANSFER OF COMPANY ASSETS ENDS
--------------------------------------------------------------


-------------------------------------------------------------
---- TEMPLATE FOR TRANSFER OF COMPANY ASSETS ENDS
-------------------------------------------------------------

----------------------------------------------------------------
  --  TEMPLATE FOR Employer Charges STARTS
  ----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,110);
  g_template_obj(12).template_name  := 'Pension Fund 80CCD';
  g_template_obj(12).category       := 'Employer Charges';
  g_template_obj(12).priority       := 21000;

  ----------------------------------------------------------------
  --  Exclusion Rules for Employer Charges Template start
  ----------------------------------------------------------------
  g_template_obj(12).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION1';
  g_template_obj(12).er_setup(1).value     := 'N';
  g_template_obj(12).er_setup(1).descr     := 'Exclusion rule for Projections.';
  g_template_obj(12).er_setup(1).tag       := 'PROJECT';
  g_template_obj(12).er_setup(1).rule_id   :=  null;

  ----------------------------------------------------------------
  --  Exclusion Rules for Employer Charges Template end
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  Input Values for Employer Charges Template start
  ----------------------------------------------------------------
  g_template_obj(12).iv_setup(1).input_value_name := 'Pay Value';
  g_template_obj(12).iv_setup(1).uom              := 'M';
  g_template_obj(12).iv_setup(1).mandatory_flag   := 'N';
  g_template_obj(12).iv_setup(1).lookup_type      := null;
  g_template_obj(12).iv_setup(1).default_value    := null;
  g_template_obj(12).iv_setup(1).def_value_column := null;
  g_template_obj(12).iv_setup(1).min_value        := null;
  g_template_obj(12).iv_setup(1).warn_or_error    := null;
  g_template_obj(12).iv_setup(1).balance_name     := null;
  g_template_obj(12).iv_setup(1).exclusion_tag    := null;

  g_template_obj(12).iv_setup(2).input_value_name := 'Standard Value';
  g_template_obj(12).iv_setup(2).uom              := 'M';
  g_template_obj(12).iv_setup(2).mandatory_flag   := 'N';
  g_template_obj(12).iv_setup(2).lookup_type      := null;
  g_template_obj(12).iv_setup(2).default_value    := null;
  g_template_obj(12).iv_setup(2).def_value_column := null;
  g_template_obj(12).iv_setup(2).min_value        := null;
  g_template_obj(12).iv_setup(2).warn_or_error    := null;
  g_template_obj(12).iv_setup(2).balance_name     := null;
  g_template_obj(12).iv_setup(2).exclusion_tag    := 'PROJECT';

  g_template_obj(12).iv_setup(3).input_value_name := 'Contribution Percentage';
  g_template_obj(12).iv_setup(3).uom              := 'N';
  g_template_obj(12).iv_setup(3).mandatory_flag   := 'N';
  g_template_obj(12).iv_setup(3).lookup_type      := null;
  g_template_obj(12).iv_setup(3).default_value    := null;
  g_template_obj(12).iv_setup(3).def_value_column := null;
  g_template_obj(12).iv_setup(3).min_value        := null;
  g_template_obj(12).iv_setup(3).warn_or_error    := null;
  g_template_obj(12).iv_setup(3).balance_name     := null;
  g_template_obj(12).iv_setup(3).exclusion_tag    := null;

  ----------------------------------------------------------------
  --  Input Values for Employer Charges Template end
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  Balance Feeds for Employer Charges Template start
  ----------------------------------------------------------------
  g_template_obj(12).bf_setup(1).balance_name     := 'Employer Pension Contribution';
  g_template_obj(12).bf_setup(1).iv_name          := 'Pay Value';
  g_template_obj(12).bf_setup(1).scale            := 1;
  g_template_obj(12).bf_setup(1).exclusion_tag    := null;

  g_template_obj(12).bf_setup(2).balance_name     := 'Employer Standard Pension Contribution';
  g_template_obj(12).bf_setup(2).iv_name          := 'Standard Value';
  g_template_obj(12).bf_setup(2).scale            := 1;
  g_template_obj(12).bf_setup(2).exclusion_tag    := 'PROJECT';
  ----------------------------------------------------------------
  --  Balance Feeds for Employer Charges Template end
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  Formula Setup for Employer Charges Template starts
  ----------------------------------------------------------------
    g_template_obj(12).uf_setup.formula_name   := '_EC_CALC';
    g_template_obj(12).uf_setup.status_rule_id := null;
    g_template_obj(12).uf_setup.description    := 'Formula for Employer Charges';

      g_template_obj(12).uf_setup.frs_setup(1).result_name      := 'EC_PAY_VALUE';
      g_template_obj(12).uf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(12).uf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(12).uf_setup.frs_setup(1).element_name     := null;
      g_template_obj(12).uf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(12).uf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(12).uf_setup.frs_setup(2).result_name      := 'EC_STANDARD_VALUE';
      g_template_obj(12).uf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(12).uf_setup.frs_setup(2).input_value_name := 'Standard Value';
      g_template_obj(12).uf_setup.frs_setup(2).element_name     := null;
      g_template_obj(12).uf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(12).uf_setup.frs_setup(2).exclusion_tag    := 'PROJECT';
  ----------------------------------------------------------------
  --  Formula Setup for Employer Charges Template ends
  ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  Add. Element Setup for Employer Charges Template starts
  ----------------------------------------------------------------
  ----------------------------------------------------------------
  --  Add. Element Setup for Employer Charges Template ends
  ----------------------------------------------------------------

----------------------------------------------------------------
--  TEMPLATE FOR Employer Charges ENDS
----------------------------------------------------------------


  ----------------------------------------------------------------
  --  TEMPLATE FOR LUNCH  PERQUISITE STARTS
  ----------------------------------------------------------------
    pay_in_utils.set_location(g_debug, l_procedure,50);
    g_template_obj(13).template_name  := 'Lunch Perquisite';
    g_template_obj(13).category       := 'Perquisites';
    g_template_obj(13).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for LUNCH  PERQUISITE Template start
    ----------------------------------------------------------------
    g_template_obj(13).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(13).er_setup(1).value     := 'N';
    g_template_obj(13).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(13).er_setup(1).tag       := 'PROJECT';
    g_template_obj(13).er_setup(1).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for LUNCH  PERQUISITE Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for LUNCH  PERQUISITE Template start
    ----------------------------------------------------------------
    g_template_obj(13).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(13).iv_setup(1).uom              := 'M';
    g_template_obj(13).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(13).iv_setup(1).lookup_type      := null;
    g_template_obj(13).iv_setup(1).default_value    := null;
    g_template_obj(13).iv_setup(1).def_value_column := null;
    g_template_obj(13).iv_setup(1).min_value        := null;
    g_template_obj(13).iv_setup(1).warn_or_error    := null;
    g_template_obj(13).iv_setup(1).balance_name     := null;
    g_template_obj(13).iv_setup(1).exclusion_tag    := null;

    g_template_obj(13).iv_setup(2).input_value_name := 'Component Name';
    g_template_obj(13).iv_setup(2).uom              := 'C';
    g_template_obj(13).iv_setup(2).mandatory_flag   := 'X';
    g_template_obj(13).iv_setup(2).lookup_type      := null;
    g_template_obj(13).iv_setup(2).default_value    := 'Lunch Perquisite';
    g_template_obj(13).iv_setup(2).def_value_column := null;
    g_template_obj(13).iv_setup(2).min_value        := null;
    g_template_obj(13).iv_setup(2).warn_or_error    := null;
    g_template_obj(13).iv_setup(2).balance_name     := null;
    g_template_obj(13).iv_setup(2).exclusion_tag    := null;

    g_template_obj(13).iv_setup(3).input_value_name := 'Cost to Employer';
    g_template_obj(13).iv_setup(3).uom              := 'M';
    g_template_obj(13).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(13).iv_setup(3).lookup_type      := null;
    g_template_obj(13).iv_setup(3).default_value    := null;
    g_template_obj(13).iv_setup(3).def_value_column := null;
    g_template_obj(13).iv_setup(3).min_value        := 0;
    g_template_obj(13).iv_setup(3).warn_or_error    := 'E';
    g_template_obj(13).iv_setup(3).balance_name     := 'Perquisite Employer Contribution';
    g_template_obj(13).iv_setup(3).exclusion_tag    := null;


    g_template_obj(13).iv_setup(4).input_value_name := 'Employee Contribution';
    g_template_obj(13).iv_setup(4).uom              := 'M';
    g_template_obj(13).iv_setup(4).mandatory_flag   := 'N';
    g_template_obj(13).iv_setup(4).lookup_type      := null;
    g_template_obj(13).iv_setup(4).default_value    := null;
    g_template_obj(13).iv_setup(4).def_value_column := null;
    g_template_obj(13).iv_setup(4).min_value        := 0;
    g_template_obj(13).iv_setup(4).warn_or_error    := 'E';
    g_template_obj(13).iv_setup(4).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(13).iv_setup(4).exclusion_tag    := null;

    g_template_obj(13).iv_setup(5).input_value_name := 'Number of Days';
    g_template_obj(13).iv_setup(5).uom              := 'N';
    g_template_obj(13).iv_setup(5).mandatory_flag   := 'N';
    g_template_obj(13).iv_setup(5).lookup_type      := null;
    g_template_obj(13).iv_setup(5).default_value    := null;
    g_template_obj(13).iv_setup(5).def_value_column := null;
    g_template_obj(13).iv_setup(5).min_value        := null;
    g_template_obj(13).iv_setup(5).warn_or_error    := null;
    g_template_obj(13).iv_setup(5).balance_name     := null;
    g_template_obj(13).iv_setup(5).exclusion_tag    := null;

    g_template_obj(13).iv_setup(6).input_value_name := 'Projected Taxable Value';
    g_template_obj(13).iv_setup(6).uom              := 'M';
    g_template_obj(13).iv_setup(6).mandatory_flag   := 'X';
    g_template_obj(13).iv_setup(6).lookup_type      := null;
    g_template_obj(13).iv_setup(6).default_value    := null;
    g_template_obj(13).iv_setup(6).def_value_column := null;
    g_template_obj(13).iv_setup(6).min_value        := null;
    g_template_obj(13).iv_setup(6).warn_or_error    := null;
    g_template_obj(13).iv_setup(6).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(13).iv_setup(6).exclusion_tag    := 'PROJECT';

    g_template_obj(13).iv_setup(7).input_value_name := 'Employer Paid Tax';
    g_template_obj(13).iv_setup(7).uom              := 'C';
    g_template_obj(13).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(13).iv_setup(7).lookup_type      := 'YES_NO';
    g_template_obj(13).iv_setup(7).default_value    := 'N';
    g_template_obj(13).iv_setup(7).def_value_column := null;
    g_template_obj(13).iv_setup(7).min_value        := null;
    g_template_obj(13).iv_setup(7).warn_or_error    := null;
    g_template_obj(13).iv_setup(7).balance_name     := null;
    g_template_obj(13).iv_setup(7).exclusion_tag    := null;

    g_template_obj(13).iv_setup(8).input_value_name := 'Employer Taxable Amount';
    g_template_obj(13).iv_setup(8).uom              := 'M';
    g_template_obj(13).iv_setup(8).mandatory_flag   := 'X';
    g_template_obj(13).iv_setup(8).lookup_type      := null;
    g_template_obj(13).iv_setup(8).default_value    := null;
    g_template_obj(13).iv_setup(8).def_value_column := null;
    g_template_obj(13).iv_setup(8).min_value        := 0;
    g_template_obj(13).iv_setup(8).warn_or_error    := 'E';
    g_template_obj(13).iv_setup(8).balance_name     := null;
    g_template_obj(13).iv_setup(8).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for LUNCH  PERQUISITE Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for LUNCH  PERQUISITE Template start
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Balance Feeds for LUNCH  PERQUISITE Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for LUNCH  PERQUISITE Template starts
    ----------------------------------------------------------------
      g_template_obj(13).sf_setup.formula_name   := 'IN_LUNCH_PERQUISITE';
      g_template_obj(13).sf_setup.status_rule_id := null;
      g_template_obj(13).sf_setup.description    := null;

      g_template_obj(13).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(13).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(13).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(13).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(13).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(2).result_name      := 'PROJECTED_VALUE';
      g_template_obj(13).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(13).sf_setup.frs_setup(2).input_value_name := 'Projected Taxable Value';
      g_template_obj(13).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(13).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(2).exclusion_tag    := 'PROJECT';

      g_template_obj(13).sf_setup.frs_setup(3).result_name      := 'EMPR_TAX';
      g_template_obj(13).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(13).sf_setup.frs_setup(3).input_value_name := 'Employer Taxable Amount';
      g_template_obj(13).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(13).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(4).result_name      := 'FED_TO_NET_PAY';
      g_template_obj(13).sf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(4).input_value_name := 'Pay Value';
      g_template_obj(13).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(13).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(5).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(13).sf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(5).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(13).sf_setup.frs_setup(5).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(6).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(13).sf_setup.frs_setup(6).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(6).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(13).sf_setup.frs_setup(6).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(7).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(13).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(7).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(13).sf_setup.frs_setup(7).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(8).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(13).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(8).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(13).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(9).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(13).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(9).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(13).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(9).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(10).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(13).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(10).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(13).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(10).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(11).result_name      := 'COMPONENT_NAME';
      g_template_obj(13).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(11).input_value_name := 'Component Name';
      g_template_obj(13).sf_setup.frs_setup(11).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(11).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(12).result_name      := 'NON_REC_VALUE';
      g_template_obj(13).sf_setup.frs_setup(12).result_rule_type := 'I';
      g_template_obj(13).sf_setup.frs_setup(12).input_value_name := 'Non Rec Perquisite';
      g_template_obj(13).sf_setup.frs_setup(12).element_name     := 'Employer Tax Projection Element';
      g_template_obj(13).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(12).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(13).result_name      := 'Cost_to_Employer';
      g_template_obj(13).sf_setup.frs_setup(13).result_rule_type := 'D';
      g_template_obj(13).sf_setup.frs_setup(13).input_value_name := 'Cost to Employer';
      g_template_obj(13).sf_setup.frs_setup(13).element_name     := null;
      g_template_obj(13).sf_setup.frs_setup(13).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(13).exclusion_tag    := null;

      g_template_obj(13).sf_setup.frs_setup(14).result_name      := 'Employee_Contribution';
      g_template_obj(13).sf_setup.frs_setup(14).result_rule_type := 'D';
      g_template_obj(13).sf_setup.frs_setup(14).input_value_name := 'Employee Contribution';
      g_template_obj(13).sf_setup.frs_setup(14).element_name     := null;
      g_template_obj(13).sf_setup.frs_setup(14).severity_level   := null;
      g_template_obj(13).sf_setup.frs_setup(14).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for LUNCH  PERQUISITE Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for LUNCH  PERQUISITE Template starts
    ----------------------------------------------------------------

      g_template_obj(13).ae_setup(1).element_name     := ' Paid MP';
      g_template_obj(13).ae_setup(1).classification   := 'Paid Monetary Perquisite';
      g_template_obj(13).ae_setup(1).exclusion_tag    := 'Perquisite';
      g_template_obj(13).ae_setup(1).priority         := 2000;

      g_template_obj(13).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(13).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(13).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(13).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(13).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(13).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(13).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(13).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(13).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(13).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(13).ae_setup(1).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(13).ae_setup(1).iv_setup(2).uom              := 'C';
      g_template_obj(13).ae_setup(1).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(13).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(13).ae_setup(1).iv_setup(2).default_value    := 'Lunch Perquisite';
      g_template_obj(13).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(13).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(13).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(13).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(13).ae_setup(1).iv_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Add. Element Setup for LUNCH  PERQUISITE Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR LUNCH  PERQUISITE ENDS
  ----------------------------------------------------------------
  ----------------------------------------------------------------
  --  TEMPLATE FOR CAR  PERQUISITE STARTS
  ----------------------------------------------------------------
    pay_in_utils.set_location(g_debug, l_procedure,50);
    g_template_obj(14).template_name  := 'Motor Car Perquisite';
    g_template_obj(14).category       := 'Perquisites';
    g_template_obj(14).priority       := 9000;

    ----------------------------------------------------------------
    --  Exclusion Rules for CAR  PERQUISITE Template start
    ----------------------------------------------------------------
    g_template_obj(14).er_setup(1).ff_column := 'CONFIGURATION_INFORMATION2';
    g_template_obj(14).er_setup(1).value     := 'N';
    g_template_obj(14).er_setup(1).descr     := 'Exclusion rule for Projections.';
    g_template_obj(14).er_setup(1).tag       := 'PROJECT';
    g_template_obj(14).er_setup(1).rule_id   :=  null;

    ----------------------------------------------------------------
    --  Exclusion Rules for CAR  PERQUISITE Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Input Values for CAR  PERQUISITE Template start
    ----------------------------------------------------------------
    g_template_obj(14).iv_setup(1).input_value_name := 'Pay Value';
    g_template_obj(14).iv_setup(1).uom              := 'M';
    g_template_obj(14).iv_setup(1).mandatory_flag   := 'X';
    g_template_obj(14).iv_setup(1).lookup_type      := null;
    g_template_obj(14).iv_setup(1).default_value    := null;
    g_template_obj(14).iv_setup(1).def_value_column := null;
    g_template_obj(14).iv_setup(1).min_value        := null;
    g_template_obj(14).iv_setup(1).warn_or_error    := null;
    g_template_obj(14).iv_setup(1).balance_name     := null;
    g_template_obj(14).iv_setup(1).exclusion_tag    := null;

    g_template_obj(14).iv_setup(2).input_value_name := 'Component Name';
    g_template_obj(14).iv_setup(2).uom              := 'C';
    g_template_obj(14).iv_setup(2).mandatory_flag   := 'X';
    g_template_obj(14).iv_setup(2).lookup_type      := null;
    g_template_obj(14).iv_setup(2).default_value    := 'Motor Car Perquisite';
    g_template_obj(14).iv_setup(2).def_value_column := null;
    g_template_obj(14).iv_setup(2).min_value        := null;
    g_template_obj(14).iv_setup(2).warn_or_error    := null;
    g_template_obj(14).iv_setup(2).balance_name     := null;
    g_template_obj(14).iv_setup(2).exclusion_tag    := null;

    g_template_obj(14).iv_setup(3).input_value_name := 'Benefit Start Date';
    g_template_obj(14).iv_setup(3).uom              := 'D';
    g_template_obj(14).iv_setup(3).mandatory_flag   := 'N';
    g_template_obj(14).iv_setup(3).lookup_type      := null;
    g_template_obj(14).iv_setup(3).default_value    := null;
    g_template_obj(14).iv_setup(3).def_value_column := null;
    g_template_obj(14).iv_setup(3).min_value        := null;
    g_template_obj(14).iv_setup(3).warn_or_error    := null;
    g_template_obj(14).iv_setup(3).balance_name     := null;
    g_template_obj(14).iv_setup(3).exclusion_tag    := null;

    g_template_obj(14).iv_setup(4).input_value_name := 'Benefit End Date';
    g_template_obj(14).iv_setup(4).uom              := 'D';
    g_template_obj(14).iv_setup(4).mandatory_flag   := 'N';
    g_template_obj(14).iv_setup(4).lookup_type      := null;
    g_template_obj(14).iv_setup(4).default_value    := null;
    g_template_obj(14).iv_setup(4).def_value_column := null;
    g_template_obj(14).iv_setup(4).min_value        := null;
    g_template_obj(14).iv_setup(4).warn_or_error    := null;
    g_template_obj(14).iv_setup(4).balance_name     := null;
    g_template_obj(14).iv_setup(4).exclusion_tag    := null;

    g_template_obj(14).iv_setup(5).input_value_name := 'Type of Automotive';
    g_template_obj(14).iv_setup(5).uom              := 'C';
    g_template_obj(14).iv_setup(5).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(5).lookup_type      := 'IN_CAR_TYPE';
    g_template_obj(14).iv_setup(5).default_value    := null;
    g_template_obj(14).iv_setup(5).def_value_column := null;
    g_template_obj(14).iv_setup(5).min_value        := null;
    g_template_obj(14).iv_setup(5).warn_or_error    := null;
    g_template_obj(14).iv_setup(5).balance_name     := null;
    g_template_obj(14).iv_setup(5).exclusion_tag    := null;

    g_template_obj(14).iv_setup(6).input_value_name := 'Category of Car';
    g_template_obj(14).iv_setup(6).uom              := 'C';
    g_template_obj(14).iv_setup(6).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(6).lookup_type      := 'IN_CAR_CATEGORY';
    g_template_obj(14).iv_setup(6).default_value    := null;
    g_template_obj(14).iv_setup(6).def_value_column := null;
    g_template_obj(14).iv_setup(6).min_value        := null;
    g_template_obj(14).iv_setup(6).warn_or_error    := null;
    g_template_obj(14).iv_setup(6).balance_name     := null;
    g_template_obj(14).iv_setup(6).exclusion_tag    := null;

    g_template_obj(14).iv_setup(7).input_value_name := 'Usage of Car';
    g_template_obj(14).iv_setup(7).uom              := 'C';
    g_template_obj(14).iv_setup(7).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(7).lookup_type      := 'IN_CAR_USAGE';
    g_template_obj(14).iv_setup(7).default_value    := null;
    g_template_obj(14).iv_setup(7).def_value_column := null;
    g_template_obj(14).iv_setup(7).min_value        := null;
    g_template_obj(14).iv_setup(7).warn_or_error    := null;
    g_template_obj(14).iv_setup(7).balance_name     := null;
    g_template_obj(14).iv_setup(7).exclusion_tag    := null;

    g_template_obj(14).iv_setup(8).input_value_name := 'Actual Expenditure';
    g_template_obj(14).iv_setup(8).uom              := 'M';
    g_template_obj(14).iv_setup(8).mandatory_flag   := 'N';
    g_template_obj(14).iv_setup(8).lookup_type      := null;
    g_template_obj(14).iv_setup(8).default_value    := null;
    g_template_obj(14).iv_setup(8).def_value_column := null;
    g_template_obj(14).iv_setup(8).min_value        := null;
    g_template_obj(14).iv_setup(8).warn_or_error    := null;
    g_template_obj(14).iv_setup(8).balance_name     := null;
    g_template_obj(14).iv_setup(8).exclusion_tag    := null;

    g_template_obj(14).iv_setup(9).input_value_name := 'Chauffeur by Employer';
    g_template_obj(14).iv_setup(9).uom              := 'C';
    g_template_obj(14).iv_setup(9).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(9).lookup_type      := 'YES_NO';
    g_template_obj(14).iv_setup(9).default_value    := null;
    g_template_obj(14).iv_setup(9).def_value_column := null;
    g_template_obj(14).iv_setup(9).min_value        := null;
    g_template_obj(14).iv_setup(9).warn_or_error    := null;
    g_template_obj(14).iv_setup(9).balance_name     := null;
    g_template_obj(14).iv_setup(9).exclusion_tag    := null;

    g_template_obj(14).iv_setup(10).input_value_name := 'Engine Capacity';
    g_template_obj(14).iv_setup(10).uom              := 'C';
    g_template_obj(14).iv_setup(10).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(10).lookup_type      := 'IN_CAR_CAPACITY';
    g_template_obj(14).iv_setup(10).default_value    := null;
    g_template_obj(14).iv_setup(10).def_value_column := null;
    g_template_obj(14).iv_setup(10).min_value        := null;
    g_template_obj(14).iv_setup(10).warn_or_error    := null;
    g_template_obj(14).iv_setup(10).balance_name     := null;
    g_template_obj(14).iv_setup(10).exclusion_tag    := null;

    g_template_obj(14).iv_setup(11).input_value_name := 'Operational Expenses by';
    g_template_obj(14).iv_setup(11).uom              := 'C';
    g_template_obj(14).iv_setup(11).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(11).lookup_type      := 'IN_CAR_MAINT_EXPENSES';
    g_template_obj(14).iv_setup(11).default_value    := null;
    g_template_obj(14).iv_setup(11).def_value_column := null;
    g_template_obj(14).iv_setup(11).min_value        := null;
    g_template_obj(14).iv_setup(11).warn_or_error    := null;
    g_template_obj(14).iv_setup(11).balance_name     := null;
    g_template_obj(14).iv_setup(11).exclusion_tag    := null;


    g_template_obj(14).iv_setup(12).input_value_name := 'Employee Contribution';
    g_template_obj(14).iv_setup(12).uom              := 'M';
    g_template_obj(14).iv_setup(12).mandatory_flag   := 'N';
    g_template_obj(14).iv_setup(12).lookup_type      := null;
    g_template_obj(14).iv_setup(12).default_value    := null;
    g_template_obj(14).iv_setup(12).def_value_column := null;
    g_template_obj(14).iv_setup(12).min_value        := null;
    g_template_obj(14).iv_setup(12).warn_or_error    := null;
    g_template_obj(14).iv_setup(12).balance_name     := 'Perquisite Employee Contribution';
    g_template_obj(14).iv_setup(12).exclusion_tag    := null;


    g_template_obj(14).iv_setup(13).input_value_name := 'Projected Taxable Value';
    g_template_obj(14).iv_setup(13).uom              := 'M';
    g_template_obj(14).iv_setup(13).mandatory_flag   := 'X';
    g_template_obj(14).iv_setup(13).lookup_type      := null;
    g_template_obj(14).iv_setup(13).default_value    := null;
    g_template_obj(14).iv_setup(13).def_value_column := null;
    g_template_obj(14).iv_setup(13).min_value        := null;
    g_template_obj(14).iv_setup(13).warn_or_error    := null;
    g_template_obj(14).iv_setup(13).balance_name     := 'Taxable Perquisites for Projection';
    g_template_obj(14).iv_setup(13).exclusion_tag    := 'PROJECT';

    g_template_obj(14).iv_setup(14).input_value_name := 'Employer Paid Tax';
    g_template_obj(14).iv_setup(14).uom              := 'C';
    g_template_obj(14).iv_setup(14).mandatory_flag   := 'Y';
    g_template_obj(14).iv_setup(14).lookup_type      := 'YES_NO';
    g_template_obj(14).iv_setup(14).default_value    := 'N';
    g_template_obj(14).iv_setup(14).def_value_column := null;
    g_template_obj(14).iv_setup(14).min_value        := null;
    g_template_obj(14).iv_setup(14).warn_or_error    := null;
    g_template_obj(14).iv_setup(14).balance_name     := null;
    g_template_obj(14).iv_setup(14).exclusion_tag    := null;

    g_template_obj(14).iv_setup(15).input_value_name := 'Employer Taxable Amount';
    g_template_obj(14).iv_setup(15).uom              := 'M';
    g_template_obj(14).iv_setup(15).mandatory_flag   := 'X';
    g_template_obj(14).iv_setup(15).lookup_type      := null;
    g_template_obj(14).iv_setup(15).default_value    := null;
    g_template_obj(14).iv_setup(15).def_value_column := null;
    g_template_obj(14).iv_setup(15).min_value        := 0;
    g_template_obj(14).iv_setup(15).warn_or_error    := 'E';
    g_template_obj(14).iv_setup(15).balance_name     := null;
    g_template_obj(14).iv_setup(15).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Input Values for CAR  PERQUISITE Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Balance Feeds for CAR  PERQUISITE Template start
    ----------------------------------------------------------------
    ----------------------------------------------------------------
    --  Balance Feeds for CAR  PERQUISITE Template end
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Formula Setup for CAR  PERQUISITE Template starts
    ----------------------------------------------------------------
      g_template_obj(14).sf_setup.formula_name   := 'IN_MOTOR_CAR';
      g_template_obj(14).sf_setup.status_rule_id := null;
      g_template_obj(14).sf_setup.description    := null;

      g_template_obj(14).sf_setup.frs_setup(1).result_name      := 'ACTUAL_PERQUISITE_VALUE';
      g_template_obj(14).sf_setup.frs_setup(1).result_rule_type := 'D';
      g_template_obj(14).sf_setup.frs_setup(1).input_value_name := 'Pay Value';
      g_template_obj(14).sf_setup.frs_setup(1).element_name     := null;
      g_template_obj(14).sf_setup.frs_setup(1).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(1).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(2).result_name      := 'PROJECTED_VALUE';
      g_template_obj(14).sf_setup.frs_setup(2).result_rule_type := 'D';
      g_template_obj(14).sf_setup.frs_setup(2).input_value_name := 'Projected Taxable Value';
      g_template_obj(14).sf_setup.frs_setup(2).element_name     := null;
      g_template_obj(14).sf_setup.frs_setup(2).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(2).exclusion_tag    := 'PROJECT';

      g_template_obj(14).sf_setup.frs_setup(3).result_name      := 'EMPR_TAX';
      g_template_obj(14).sf_setup.frs_setup(3).result_rule_type := 'D';
      g_template_obj(14).sf_setup.frs_setup(3).input_value_name := 'Employer Taxable Amount';
      g_template_obj(14).sf_setup.frs_setup(3).element_name     := null;
      g_template_obj(14).sf_setup.frs_setup(3).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(3).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(4).result_name      := 'FED_TO_NET_PAY';
      g_template_obj(14).sf_setup.frs_setup(4).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(4).input_value_name := 'Pay Value';
      g_template_obj(14).sf_setup.frs_setup(4).element_name     := null;
      g_template_obj(14).sf_setup.frs_setup(4).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(4).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(5).result_name      := 'ER_MP_TAXABLE_AMOUNT';
      g_template_obj(14).sf_setup.frs_setup(5).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(5).input_value_name := 'ER MP Taxable Amount';
      g_template_obj(14).sf_setup.frs_setup(5).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(5).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(5).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(6).result_name      := 'PROJECTED_ER_MP_TAXABLE_AMT';
      g_template_obj(14).sf_setup.frs_setup(6).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(6).input_value_name := 'Projected ER MP Taxable Amt';
      g_template_obj(14).sf_setup.frs_setup(6).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(6).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(6).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(7).result_name      := 'ER_MP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(14).sf_setup.frs_setup(7).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(7).input_value_name := 'ER MP Salary to be Excluded';
      g_template_obj(14).sf_setup.frs_setup(7).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(7).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(7).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(8).result_name      := 'ER_NMP_TAXABLE_AMOUNT';
      g_template_obj(14).sf_setup.frs_setup(8).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(8).input_value_name := 'ER NMP Taxable Amount';
      g_template_obj(14).sf_setup.frs_setup(8).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(8).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(8).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(9).result_name      := 'PROJECTED_ER_NMP_TAXABLE_AMT';
      g_template_obj(14).sf_setup.frs_setup(9).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(9).input_value_name := 'Projected ER NMP Taxable Amt';
      g_template_obj(14).sf_setup.frs_setup(9).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(9).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(9).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(10).result_name      := 'ER_NMP_SALARY_TO_BE_EXCLUDED';
      g_template_obj(14).sf_setup.frs_setup(10).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(10).input_value_name := 'ER NMP Salary to be Excluded';
      g_template_obj(14).sf_setup.frs_setup(10).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(10).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(10).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(11).result_name      := 'COMPONENT_NAME';
      g_template_obj(14).sf_setup.frs_setup(11).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(11).input_value_name := 'Component Name';
      g_template_obj(14).sf_setup.frs_setup(11).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(11).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(11).exclusion_tag    := null;

      g_template_obj(14).sf_setup.frs_setup(12).result_name      := 'NON_REC_VALUE';
      g_template_obj(14).sf_setup.frs_setup(12).result_rule_type := 'I';
      g_template_obj(14).sf_setup.frs_setup(12).input_value_name := 'Non Rec Perquisite';
      g_template_obj(14).sf_setup.frs_setup(12).element_name     := 'Employer Tax Projection Element';
      g_template_obj(14).sf_setup.frs_setup(12).severity_level   := null;
      g_template_obj(14).sf_setup.frs_setup(12).exclusion_tag    := null;
    ----------------------------------------------------------------
    --  Formula Setup for CAR  PERQUISITE Template ends
    ----------------------------------------------------------------

    ----------------------------------------------------------------
    --  Add. Element Setup for CAR  PERQUISITE Template starts
    ----------------------------------------------------------------

      g_template_obj(14).ae_setup(1).element_name     := ' Paid MP';
      g_template_obj(14).ae_setup(1).classification   := 'Paid Monetary Perquisite';
      g_template_obj(14).ae_setup(1).exclusion_tag    := 'Perquisite';
      g_template_obj(14).ae_setup(1).priority         := 2000;

      g_template_obj(14).ae_setup(1).iv_setup(1).input_value_name := 'Pay Value';
      g_template_obj(14).ae_setup(1).iv_setup(1).uom              := 'M';
      g_template_obj(14).ae_setup(1).iv_setup(1).mandatory_flag   := 'X';
      g_template_obj(14).ae_setup(1).iv_setup(1).lookup_type      := null;
      g_template_obj(14).ae_setup(1).iv_setup(1).default_value    := null;
      g_template_obj(14).ae_setup(1).iv_setup(1).def_value_column := null;
      g_template_obj(14).ae_setup(1).iv_setup(1).min_value        := null;
      g_template_obj(14).ae_setup(1).iv_setup(1).warn_or_error    := null;
      g_template_obj(14).ae_setup(1).iv_setup(1).balance_name     := null;
      g_template_obj(14).ae_setup(1).iv_setup(1).exclusion_tag    := null;

      g_template_obj(14).ae_setup(1).iv_setup(2).input_value_name := 'Component Name';
      g_template_obj(14).ae_setup(1).iv_setup(2).uom              := 'C';
      g_template_obj(14).ae_setup(1).iv_setup(2).mandatory_flag   := 'X';
      g_template_obj(14).ae_setup(1).iv_setup(2).lookup_type      := null;
      g_template_obj(14).ae_setup(1).iv_setup(2).default_value    := 'Motor Car Perquisite';
      g_template_obj(14).ae_setup(1).iv_setup(2).def_value_column := null;
      g_template_obj(14).ae_setup(1).iv_setup(2).min_value        := null;
      g_template_obj(14).ae_setup(1).iv_setup(2).warn_or_error    := null;
      g_template_obj(14).ae_setup(1).iv_setup(2).balance_name     := null;
      g_template_obj(14).ae_setup(1).iv_setup(2).exclusion_tag    := null;

    ----------------------------------------------------------------
    --  Add. Element Setup for CAR  PERQUISITE Template ends
    ----------------------------------------------------------------

  ----------------------------------------------------------------
  --  TEMPLATE FOR CAR  PERQUISITE ENDS
  ----------------------------------------------------------------

  pay_in_utils.set_location(g_debug,'Leaving:'|| l_procedure,150);
EXCEPTION
    WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug, 'Leaving: '||l_procedure,160);
      l_message := pay_in_utils.get_pay_message
                      ('PER_IN_ORACLE_GENERIC_ERROR',
		       'FUNCTION:'||l_procedure,
		       'SQLERRMC:'||SQLERRM);
      pay_in_utils.trace('SQLERRM',l_message);
      RAISE ;

END init_code;

--------------------------------------------------------------------------
-- Name           : INIT_FORMULA                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to initialize the formulas for ETW        --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : N/A                                                 --
--         RETURN : N/A                                                 --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Bug#    Date      Userid   Description                               --
--------------------------------------------------------------------------
-- 5332442 26-JUL-06 statkar  Created                                   --
--------------------------------------------------------------------------
PROCEDURE init_formula
IS
   l_procedure    CONSTANT VARCHAR2(100):= g_package||'init_formula';

BEGIN
  g_debug := hr_utility.debug_enabled;
  pay_in_utils.set_location(g_debug, 'Entering: '||l_procedure,10);

----------------------------------------------------------------
--  FORMULA FOR FIXED ALLOWANCES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,20);
  g_formula_obj(1).name := '_FIXED_CALC';
  g_formula_obj(1).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
  /* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */

   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_FIXED_CALC
     FORMULA TYPE : Oracle Payroll
   -----------------------------------------------------------------------*/
   /* DEFAULT SECTION */
    /* Default for Database Items */
    DEFAULT FOR EXEMPTION_AMOUNT IS ''-1''
    DEFAULT FOR IN_HOSTEL_CHILDREN_ENTRY_COUNT is 0
    DEFAULT FOR ALLOWANCE_NAME IS ''XXXX''

    /* Default for Input Values */
    DEFAULT FOR Allowance_amount  is 0
    DEFAULT FOR Standard_Value is 0
    DEFAULT FOR Claim_Exemption_Sec10 is ''N''
    DEFAULT FOR Component_name is ''Null''

   /* Default for defined balances */
    DEFAULT FOR Outstanding_Advance_for_Allowances_ASG_COMP_LTD IS 0


   /* INPUT SECTION */
    INPUTS ARE Allowance_amount,
               Standard_Value,
               Claim_Exemption_Sec10(text),
               Component_name(text)

   /* INITIALIZATION SECTION   */
   /* Initialization of local variables */
    l_max_exem_amt    = TO_NUMBER(EXEMPTION_AMOUNT)
    l_exp_nature      = ''X''
    l_disable_catg    = ''X''
    l_disable_percent = 0
    l_disable_proof   = ''N''

    l_lt_outstanding_adv =Outstanding_Advance_for_Allowances_ASG_COMP_LTD

   /* Initialization of out variables */
    Taxable_Value          = 0
    Standard_Taxable_Value = 0
    Benefit_Amount = Allowance_amount


   /* CODE SECTION */
   IF ALLOWANCE_NAME = ''Children Education Allowance''
   OR ALLOWANCE_NAME = ''Hostel Expenditure Allowance'' THEN
   (
     IF IN_HOSTEL_CHILDREN_ENTRY_COUNT > 2 THEN
     (
       l_error_mesg = IN_GET_PAY_MESSAGE(''PAY_IN_MAX_CHILD_EXCEEDED'')
       RETURN l_error_mesg
     )

     IF Claim_Exemption_Sec10 <> ''Y'' THEN
        l_max_exem_amt = 0
    )

    IF ALLOWANCE_NAME = ''Transport Allowance'' Then
    (
        l_disable_details = IN_DISABILITY_DETAILS
                              (l_disable_catg,
                               l_disable_percent,
                               l_disable_proof)

        IF ((l_disable_catg = ''BLIND'' OR l_disable_catg = ''OH'')
         AND l_disable_proof= ''Y'') THEN
             l_max_exem_amt = 1600

     )

     IF ALLOWANCE_NAME = ''Entertainment Allowance'' THEN
          l_max_exem_amt = 0

     /* Common Code for all Fixed Allowances */
      Taxable_Value = Allowance_Amount
                    - LEAST(Allowance_Amount, l_max_exem_amt)

      Standard_Taxable_Value = Standard_Value
                             - LEAST(Standard_Value, l_max_exem_amt)

    /* Advance functionality*/
    Actual_allowance_amount = Allowance_amount
    Pending_Advance  = Outstanding_Advance_for_Allowances_ASG_COMP_LTD
    Allowance_amount = GREATEST((Actual_allowance_amount - Pending_Advance),0)
    Adjusted_advance = GREATEST((Actual_allowance_amount - Allowance_amount),0)



    /* RETURN SECTION */

          Return Taxable_Value,
                 Standard_Taxable_Value,
                 Allowance_amount,
                 Adjusted_advance


   /* End of Formula */ ';

----------------------------------------------------------------
--  FORMULA FOR ACTUAL EXPENSE ALLOWANCE
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,40);
  g_formula_obj(2).name := '_ACTEXP_CALC';
  g_formula_obj(2).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_ACTEXP_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Allowances in India Localization
   -----------------------------------------------------------------------*/
   /* DEFAULT SECTION */
   /* Default for Database Items */
    DEFAULT FOR ALLOWANCE_NAME IS ''XXXX''
    DEFAULT FOR EXEMPTION_AMOUNT IS ''0''
    DEFAULT FOR NATURE_OF_EXPENSE IS ''R''

   /* Default for Input Values */
    DEFAULT FOR Allowance_amount  is 0
    DEFAULT FOR Standard_Value is 0
    DEFAULT FOR Actual_Expenditure is 0
    DEFAULT FOR Component_Name IS ''No Component''

   /* Default for Defined Balances */
    DEFAULT FOR Allowance_Amount_ASG_COMP_PTD IS 0
    DEFAULT FOR Taxable_Allowances_ASG_COMP_PTD IS 0
    DEFAULT FOR Taxable_Allowances_For_Projection_ASG_COMP_PTD IS 0
    DEFAULT FOR Allowance_Expense_Amount_ASG_COMP_PTD IS 0
    DEFAULT FOR Allowances_Standard_Value_ASG_COMP_PTD IS 0

    DEFAULT FOR Allowance_Amount_ASG_LE_COMP_YTD IS 0
    DEFAULT FOR Taxable_Allowances_ASG_LE_COMP_YTD IS 0
    DEFAULT FOR Taxable_Allowances_For_Projection_ASG_COMP_YTD IS 0
    DEFAULT FOR Allowance_Expense_Amount_ASG_LE_COMP_YTD IS 0
    DEFAULT FOR Allowances_Standard_Value_ASG_COMP_YTD IS 0
    DEFAULT FOR Adjusted_Advance_for_Allowances_ASG_LE_COMP_YTD IS 0

  /* INPUT SECTION */
    INPUTS ARE Allowance_amount,
               Standard_Value,
               Actual_Expenditure,
               Component_Name (text)


  /* INITIALIZATION SECTION   */
   /* Initialization of local variables */
    l_Allowance_Amount   = 0
    l_Actual_Expenditure = 0
    l_max_exem_amt       = TO_NUMBER(EXEMPTION_AMOUNT)
    Projected_Expense    = 0
   /* Initialization of out variables */
    Taxable_Value          = 0
    Standard_Taxable_Value = 0
    l_success              =''X''

   /* Initialization for latest balances */
    l_lt_alw_amt          = Allowance_Amount_ASG_COMP_PTD
    l_lt_tax_alw_amt      = Taxable_Allowances_ASG_COMP_PTD
    l_lt_tax_alw_proj_amt = Taxable_Allowances_For_Projection_ASG_COMP_PTD
    l_lt_alw_exp_amt      = Allowance_Expense_Amount_ASG_COMP_PTD
    l_lt_alw_std_amt      = Allowances_Standard_Value_ASG_COMP_PTD
    l_lty_alw_amt          = Allowance_Amount_ASG_LE_COMP_YTD
    l_lty_tax_alw_amt      = Taxable_Allowances_ASG_LE_COMP_YTD
    l_lty_tax_alw_proj_amt = Taxable_Allowances_For_Projection_ASG_COMP_YTD
    l_lty_alw_exp_amt      = Allowance_Expense_Amount_ASG_LE_COMP_YTD
    l_lty_alw_std_amt      = Allowances_Standard_Value_ASG_COMP_YTD
    l_lty_adj_alw_amt      = Adjusted_Advance_for_Allowances_ASG_LE_COMP_YTD


   /* CODE SECTION */

    l_allowance_le_start   = IN_VALUE_ON_LE_START(''Allowance Amount'',
                          ''_ASG_LE_COMP_YTD'',''SOURCE_TEXT2'',Component_Name,l_success)
                           + IN_VALUE_ON_LE_START(''Adjusted Advance for Allowances'',
                          ''_ASG_LE_COMP_YTD'',''SOURCE_TEXT2'',Component_Name,l_success)

    l_expenditure_le_start = IN_VALUE_ON_LE_START(''Allowance Expense Amount'',
                          ''_ASG_LE_COMP_YTD'',''SOURCE_TEXT2'',Component_Name,l_success)
    l_taxable_le_start     = IN_VALUE_ON_LE_START(''Taxable Allowances'',
                          ''_ASG_LE_COMP_YTD'',''SOURCE_TEXT2'',Component_Name,l_success)

    l_Allowance_Amount = Allowance_Amount_ASG_LE_COMP_YTD
                       - l_allowance_le_start
                       + Adjusted_Advance_for_Allowances_ASG_LE_COMP_YTD
                       + Allowance_Amount

    IF NATURE_OF_EXPENSE = ''R'' THEN
       Projected_Expense = Actual_Expenditure

    l_Actual_Expenditure = Allowance_Expense_Amount_ASG_LE_COMP_YTD
                         - l_expenditure_le_start
                         + Actual_Expenditure

    Taxable_Value = l_Allowance_Amount
                   - LEAST(l_Allowance_Amount, l_Actual_Expenditure, l_max_exem_amt)
                   - (Taxable_Allowances_ASG_LE_COMP_YTD - l_taxable_le_start)

    Standard_Taxable_Value  = Standard_Value -
                     LEAST(Standard_Value,Projected_Expense, l_max_exem_amt)

    /* Advance functionality*/
    Actual_allowance_amount = Allowance_amount
    Pending_Advance  = Outstanding_Advance_for_Allowances_ASG_COMP_LTD
    Allowance_amount = GREATEST((Actual_allowance_amount - Pending_Advance),0)
    Adjusted_advance = GREATEST((Actual_allowance_amount - Allowance_amount),0)



   /* RETURN SECTION */

     RETURN  Taxable_Value,
             Standard_Taxable_Value,
             Allowance_amount,
             Adjusted_advance

   /* End of Formula */   ';

----------------------------------------------------------------
--  FORMULA FOR LTC EARNINGS
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,50);
  g_formula_obj(3).name := '_LTC_CALC';
  g_formula_obj(3).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_LTC_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for LTC Earnings in India Localization
   -----------------------------------------------------------------------*/
  /* DEFAULT SECTION */
   /* Input Value Defaults */
   DEFAULT FOR Carryover_from_Prev_Block IS ''N''
   DEFAULT FOR Exempted IS ''N''
   DEFAULT FOR Component_Name IS ''Leave Travel Concession''

   /* Defined Balance Defaults */
   DEFAULT FOR Outstanding_Advance_for_Earnings_ASG_COMP_LTD IS 0

   DEFAULT FOR Employer_Contribution_for_LTC_ASG_COMP_RUN IS 0

   /* INPUT SECTION */
   INPUTS ARE Employer_Contribution
             ,Ticket_Fare
             ,Exempted(text)
             ,Carryover_from_Prev_Block(text)
             ,Component_Name(text)

   /* Following is intended to initialize latest balances */
   l_lt_advance  = Outstanding_Advance_for_Earnings_ASG_COMP_LTD

   /* INITIALIZATION SECTION */
   /* Initialization of Out Variables */
   Carry_Over_Flag         = Carryover_from_Prev_Block
   Exempted_Flag           = Exempted
   Payable_Value           = 0
   adjusted_advance        = 0
   Exempted_Amt            = 0

   /* CODE SECTION */
   l_count = IN_LTC_DETAILS(Carry_Over_Flag,Exempted_Flag)

   IF (Exempted_Flag = ''Y'') THEN
     Taxable_value = GREATEST((Employer_Contribution - Ticket_Fare),0)
   ELSE
     Taxable_value = GREATEST(Employer_Contribution ,0)
   Approved_benefit_Value = Employer_Contribution

   /* Adjust with any outstanding advance */

       Pending_Advance = Outstanding_Advance_for_Earnings_ASG_COMP_LTD
       Payable_Value = GREATEST((Approved_benefit_Value - Pending_Advance ),0)
       Adjusted_advance = GREATEST((Approved_benefit_Value  - Payable_Value),0)


   Exempted_Amt = Payable_Value - Taxable_value

   IF Ticket_Fare = 0 THEN
      Exempted_Flag = ''N''

    /* RETURN SECTION */
   RETURN Payable_Value,
          adjusted_advance,
          Exempted_Amt,
          Exempted_Flag,
          Carry_Over_Flag

   /* End of Formula */   ';

----------------------------------------------------------------
--  FORMULA FOR ADVANCES ON EARNINGS
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,60);
  g_formula_obj(4).name := '_LTC_ADV_CALC';
  g_formula_obj(4).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_LTC_ADV_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Advances on Earnings in India Localization
   -----------------------------------------------------------------------*/
  /* DEFAULT SECTION */
   DEFAULT FOR Excess_Advance IS ''PENDING''
   DEFAULT FOR Advance_Amount IS 0
   DEFAULT FOR Add_to_Net_Pay IS ''Y''

   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Earnings_ASG_COMP_LTD IS 0



  /* INPUT SECTION */
    INPUTS ARE Advance_Amount,
               Excess_Advance(text),
               Add_to_Net_Pay (text),
               Component_Name (text)

    /* Initialisation of latest balances */
    l_lt_outstanding_adv = Outstanding_Advance_for_Earnings_ASG_COMP_LTD

    IF (Add_to_Net_Pay =''Y'') THEN
      Payable_Value = Advance_Amount
    ELSE
      Payable_Value = 0

    IF(Excess_Advance = ''PENDING'') THEN
      RETURN Payable_Value
    ELSE
      RETURN Payable_Value,
             Excess_Advance,
             Component_Name

   /* End of Formula */   ';

----------------------------------------------------------------
--  FORMULA FOR FRINGE BENEFIT CALCULATIONS
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,70);
  g_formula_obj(5).name := '_FB_CALC';
  g_formula_obj(5).text :=
'/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */

   /*----------------------------------------------------------------------
     FORMULA NAME : MED_BEN_FB_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Fringe Benefits in India Localization
   -----------------------------------------------------------------------*/
   /* DEFAULT SECTION */
   DEFAULT FOR EMP_TERM_DATE IS ''4712/12/31 00:00:00'' (date)
   DEFAULT FOR EMP_HIRE_DATE IS ''1900/01/01 00:00:00'' (date)
   DEFAULT FOR PAY_PROC_PERIOD_END_DATE IS ''4712/12/31 00:00:00'' (date)
   DEFAULT FOR PAY_PROC_PERIOD_START_DATE IS ''2004/01/01 00:00:00'' (date)
   DEFAULT FOR IN_PAY_PROC_PERIOD_NUM is -99
   /* Input Value Defaults */

   DEFAULT FOR Benefit_Amount is 0
   DEFAULT FOR Salary_under_Sec_17 IS 0
   DEFAULT FOR Maximum_Annual_Limit IS 0
   DEFAULT FOR Add_to_Net_Pay IS ''N''
   DEFAULT FOR Medical_Benefit IS ''N''

   /* Defined Balance Defaults */
   DEFAULT FOR Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD IS 0
   DEFAULT FOR Reimbursement_Amount_ASG_COMP_YTD IS 0
   DEFAULT FOR Reimbursement_Amount_ASG_COMP_PTD IS 0
   DEFAULT FOR Medical_Reimbursement_Amount_ASG_YTD IS 0
   DEFAULT FOR Medical_Reimbursement_Amount_ASG_PTD IS 0
   DEFAULT FOR Bills_Submitted_ASG_COMP_RUN IS 0
   DEFAULT FOR Salary_under_Section_17_ASG_COMP_YTD IS 0
   DEFAULT FOR Medical_Bills_ASG_YTD IS 0
   DEFAULT FOR Annual_Projection_for_Reimbursement_ASG_COMP_PTD IS 0

   /* INPUT SECTION */
   INPUTS ARE Benefit_Amount,
              Salary_under_Sec_17,
              Maximum_Annual_Limit,
              Add_to_Net_Pay(text),
              Component_Name(text),
              Medical_Benefit(text)


   /* INITIALIZATION SECTION */
   /* Initialization of Out Variables */
     Payable_value        = 0
     Fringe_Benefit_Value = 0
     adjusted_advance     = 0
     Salary_under_Sec171 = Salary_under_Sec_17
     l_annual_projected_value = 0
     l_ann_ben_amt         = 0
     Projected_salary_under_sec171 = 0
     taxable_fringe_benefit = 0

   /* Initialization of Local Variables */
     l_med_benefit = 0

     LRPP = IN_GET_PAY_PERIODS(PAY_PROC_PERIOD_END_DATE,
                               EMP_TERM_DATE,
                               IN_PAY_PROC_PERIOD_NUM,
                               ''X'')
    RECURRING = IN_GET_PROCESSING_TYPE()

   /* Code Section */
 /*  IF Benefit_Amount WAS DEFAULTED THEN
   Benefit_Amount = Bills_Submitted_ASG_COMP_RUN*/



  /*   Reimbursement_Amount_ASG_COMP_YTD - Holds the fringe benefit amount under each component.
    Do not use this for Superannuation .  For each component, tax varies . It could be 10% or 20% depending on component */

  /* For Superannuation use the Taxable_Fringe_Benefit_ASG_COMP_YTD and apply FBT on top of it */

  /* Salary_under_Section_17_ASG_COMP_YTD - Taxable to employee for Medical benefit */


/* Ensure total money paid out to employee does not exceed Maximum_Annual_Limit
   Adjust against outstanding advance
   Determine payable in current period
*/

   IF Maximum_Annual_Limit WAS NOT DEFAULTED THEN
   (
     Annual_Approved_value =
     LEAST(Maximum_Annual_Limit,
           (Reimbursement_Amount_ASG_COMP_YTD + Taxable_Fringe_Benefit_ASG_COMP_YTD + Benefit_Amount + Salary_under_Section_17_ASG_COMP_YTD)
          )

     Approved_Benefit_in_Current_Period = GREATEST((Annual_Approved_value - Reimbursement_Amount_ASG_COMP_YTD - Taxable_Fringe_Benefit_ASG_COMP_YTD - Salary_under_Section_17_ASG_COMP_YTD),0)

     payable_value = GREATEST((Approved_Benefit_in_Current_Period - Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD ),0)
   )
   ELSE
   (
     Approved_Benefit_in_Current_Period = Benefit_Amount
     payable_value = GREATEST((Approved_Benefit_in_Current_Period - Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD ),0)
   )

    adjusted_advance = Approved_Benefit_in_Current_Period - payable_value
    Fringe_Benefit_Value =  Approved_Benefit_in_Current_Period

    l_fbt_value_till_date = Reimbursement_Amount_ASG_COMP_YTD + Taxable_Fringe_Benefit_ASG_COMP_YTD + Fringe_Benefit_Value
    l_projection_for_rpp = (Fringe_Benefit_Value + Reimbursement_Amount_ASG_COMP_PTD + Taxable_Fringe_Benefit_ASG_COMP_PTD)*LRPP

   /* Medical Benefit - Special Handling */
   IF (Component_Name =''Employees Welfare Expense'' AND Medical_Benefit = ''Y'') THEN
   (
     prev_med_reimburse_amt = IN_PREV_MEDICAL_REIMBURSEMENT()
     l_max_exempted_amt = GREATEST((IN_EXEMPT_MEDICAL_PERQUISITE - prev_med_reimburse_amt),0)

      l_med_benefit  = Medical_Reimbursement_Amount_ASG_YTD
                     + Approved_Benefit_in_Current_Period
                     + Salary_under_Section_17_ASG_COMP_YTD



   IF(Medical_Bills_ASG_YTD < l_max_exempted_amt)   THEN
    (
        Salary_under_Sec171 = l_med_benefit - Medical_Bills_ASG_YTD
    )
   ELSE
     (
     l_tax_exempt  = LEAST(Medical_Bills_ASG_YTD,l_max_exempted_amt)
     Salary_under_Sec171 = l_med_benefit - l_tax_exempt
     )

     /* Reimbursement projection Start*/
     IF RECURRING = ''R'' THEN
     (
        IF Maximum_Annual_Limit WAS NOT DEFAULTED THEN
        (
         Projected_salary_under_sec171 = LEAST((l_med_benefit + Benefit_Amount*LRPP),Maximum_Annual_Limit) - l_med_benefit
        )
        ELSE
        (
         Projected_salary_under_sec171 = Benefit_Amount*LRPP
         )
        IF Salary_under_Sec171 < 0 THEN
        (
         Projected_salary_under_sec171 = Projected_salary_under_sec171 + Salary_under_Sec171
         )
         Projected_salary_under_sec171 = GREATEST(Projected_salary_under_sec171,0)
      )
     Salary_under_Sec171 = GREATEST(Salary_under_Sec171,0)
     Salary_under_Sec171 = Salary_under_Sec171 - Salary_under_Section_17_ASG_COMP_YTD
     Fringe_Benefit_Value = Fringe_Benefit_Value - Salary_under_Sec171
     l_fbt_value_till_date = Medical_Reimbursement_Amount_ASG_YTD + Fringe_Benefit_Value
     l_tot_fringe_benefit = LEAST( Medical_Bills_ASG_YTD,l_max_exempted_amt)
     l_projection_for_rpp = l_tot_fringe_benefit - l_fbt_value_till_date
    )
   IF RECURRING = ''R'' THEN
    (
       IF Maximum_Annual_Limit WAS NOT DEFAULTED THEN
         (
	             l_annual_projected_value = LEAST(l_fbt_value_till_date + l_projection_for_rpp,
		                                         Maximum_Annual_Limit)

         )
       ELSE
         (
	             l_annual_projected_value = l_fbt_value_till_date + l_projection_for_rpp
         )
        IF (Component_Name =''Employees Welfare Expense'' AND Medical_Benefit = ''Y'') THEN
         (
          l_ann_ben_amt = Salary_under_Section_17_ASG_COMP_YTD + Salary_under_Sec171
                          + Medical_Reimbursement_Amount_ASG_YTD + Fringe_Benefit_Value
                          + (Benefit_Amount * LRPP)
          l_annual_projected_value = LEAST(l_annual_projected_value,l_ann_ben_amt)
         )
    )
    Annual_projected_value = l_annual_projected_value - Annual_Projection_for_Reimbursement_ASG_COMP_PTD
     /* Reimbursement projection End */

    IF (Add_to_Net_Pay =''N'') THEN
     Payable_Value = 0

   /* Superannuation - Special handling */
    IF  Component_Name = ''Superannuation Fund''  THEN
    (
       IF Reimbursement_Amount_ASG_COMP_YTD + Fringe_Benefit_Value > IN_SUPERANNUATION_FBT THEN
        (
          taxable_fringe_benefit = Fringe_Benefit_Value
			      + Reimbursement_Amount_ASG_COMP_YTD

          Fringe_Benefit_Value = 0 - Reimbursement_Amount_ASG_COMP_YTD
        )
       ELSE IF Taxable_Fringe_Benefit_ASG_COMP_YTD + Fringe_Benefit_Value  > IN_SUPERANNUATION_FBT THEN
       (
          taxable_fringe_benefit = Fringe_Benefit_Value
	  Fringe_Benefit_Value = 0
       )
     )


   /* RETURN SECTION */
   RETURN Payable_value,
          Fringe_Benefit_Value,
          adjusted_advance,
          Salary_under_Sec171,
          Annual_projected_value,
          Projected_salary_under_sec171,
	  taxable_fringe_benefit,
          Component_Name
   /* End of Formula */
   ';

----------------------------------------------------------------
--  FORMULA FOR ADVANCES ON FRINGE BENEFITS
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_formula_obj(6).name := '_FB_ADV_CALC';
  g_formula_obj(6).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */

   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_FB_ADV_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Advance Calculation for Fringe Benefits in India Localization
   -----------------------------------------------------------------------*/
   /* DEFAULT SECTION */
   DEFAULT FOR Excess_Advance IS ''PENDING''
   DEFAULT FOR Advance_Amount IS 0
   DEFAULT FOR Add_to_Net_Pay IS ''Y''

   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD IS 0




  /* INPUT SECTION */
    INPUTS ARE Advance_Amount,
               Excess_Advance(text),
               Add_to_Net_Pay (text),
               Component_Name (text)

    /* Initialisation of latest balances */
    l_lt_outstanding_adv = Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD

    IF (Add_to_Net_Pay =''Y'') THEN
      Payable_Value = Advance_Amount
    ELSE
      Payable_Value = 0

    IF(Excess_Advance = ''PENDING'') THEN
      RETURN Payable_Value
    ELSE
      RETURN Payable_Value,
             Excess_Advance,
             Component_Name

   /* End of Formula */
  ';

  pay_in_utils.set_location(g_debug,'Leaving: '|| l_procedure,100);

----------------------------------------------------------------
--  FORMULA FOR ADVANCES ON FIXED ALLOWANCES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_formula_obj(7).name := '_FX_ADV_CALC';
  g_formula_obj(7).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_FX_ADV_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Advances on Fix Allowances in India Localization
   -----------------------------------------------------------------------*/
   /* DEFAULT SECTION */
   DEFAULT FOR Excess_Advance IS ''PENDING''
   DEFAULT FOR Advance_Amount IS 0
   DEFAULT FOR Add_to_Net_Pay IS ''Y''

   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Allowances_ASG_COMP_LTD IS 0




  /* INPUT SECTION */
    INPUTS ARE Advance_Amount,
               Excess_Advance(text),
               Add_to_Net_Pay (text),
               Component_Name (text)

    /* Initialisation of latest balances */
    l_lt_outstanding_adv =Outstanding_Advance_for_Allowances_ASG_COMP_LTD

    IF (Add_to_Net_Pay =''Y'') THEN
      Payable_Value = Advance_Amount
    ELSE
      Payable_Value = 0

    IF(Excess_Advance = ''PENDING'') THEN
      RETURN Payable_Value
    ELSE
      RETURN Payable_Value,
             Excess_Advance,
             Component_Name

   /* End of Formula */
  ';

----------------------------------------------------------------
--  FORMULA FOR ADVANCES ON ACTUAL EXPENSE ALLOWANCES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_formula_obj(8).name := '_AE_ADV_CALC';
  g_formula_obj(8).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_AE_ADV_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Advances on Actual allowances in India Localization
   -----------------------------------------------------------------------*/
    /* DEFAULT SECTION */
   DEFAULT FOR Excess_Advance IS ''PENDING''
   DEFAULT FOR Advance_Amount IS 0
   DEFAULT FOR Add_to_Net_Pay IS ''Y''

   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Allowances_ASG_COMP_LTD IS 0

  /* INPUT SECTION */
    INPUTS ARE Advance_Amount,
               Excess_Advance(text),
               Add_to_Net_Pay (text),
               Component_Name (text)

    /* Initialisation of latest balances */
    l_lt_outstanding_adv =Outstanding_Advance_for_Allowances_ASG_COMP_LTD

    IF (Add_to_Net_Pay =''Y'') THEN
      Payable_Value = Advance_Amount
    ELSE
      Payable_Value = 0

    IF(Excess_Advance = ''PENDING'') THEN
      RETURN Payable_Value
    ELSE
      RETURN Payable_Value,
             Excess_Advance,
             Component_Name

   /* End of Formula */
  ';

----------------------------------------------------------------
--  FORMULA FOR EXCESS ADVANCES ON FRINGE BENEFITS
----------------------------------------------------------------
  g_formula_obj(9).name := '_FB_EXC_ADV';
  g_formula_obj(9).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */

   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_FB_EXC_ADV
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Excess Advance Calculation for Fringe Benefits in India Localization
   -----------------------------------------------------------------------*/


   /* DEFAULT SECTION */
   /* Input Value Defaults */
   DEFAULT FOR Excess_Advance IS ''PENDING''
   DEFAULT FOR Advance_Amount IS 0


   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD IS 0




  /* INPUT SECTION */
    INPUTS ARE Excess_Advance(text),
               Component_Name (text)



  /* INITIALIZATION SECTION   */
   /* Initialization of out variables */

    Recovered_Advance   = 0
    Salary_Sec171      = 0
    Adjustment_Amt      = 0
    Component_Name_Pay  = Component_Name
    Component_Name_Rec  = Component_Name


    IF (Excess_Advance =''PAY''  ) THEN
    (

     Salary_Sec171 = Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD
     Recovered_Advance = Salary_Sec171
     Adjustment_Amt = Recovered_Advance


     IF(Recovered_Advance <> 0) THEN
      (

       RETURN Salary_Sec171,
              Recovered_Advance,
              Adjustment_Amt,
              Component_Name_Pay,
              Component_Name_Rec
      )

    )
    ELSE IF (Excess_Advance =''RECOVER''  ) THEN
    (
     Recovered_Advance = Outstanding_Advance_for_Fringe_Benefits_ASG_COMP_LTD

     IF Recovered_Advance <> 0 THEN
       RETURN Recovered_Advance,
            Component_Name_Rec
    )

    RETURN

   /* End of Formula */
  ';

  pay_in_utils.set_location(g_debug,'Leaving: '|| l_procedure,100);

----------------------------------------------------------------
--  FORMULA FOR EXCESS ADVANCES ON FIXED ALLOWANCES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_formula_obj(10).name := '_FX_EXC_ADV';
  g_formula_obj(10).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_FX_EXC_ADV
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Excess Advances on Fix Allowances in India Localization
   -----------------------------------------------------------------------*/

   /* DEFAULT SECTION */
   DEFAULT FOR Excess_Advance IS ''PENDING''

   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Allowances_ASG_COMP_LTD IS 0




  /* INPUT SECTION */
    INPUTS ARE Excess_Advance(text),
               Component_Name (text)

  /* INITIALIZATION SECTION   */
   /* Initialization of local variables */

    Recovered_Advance   = 0
    Salary_Sec171      = 0
    Adjustment_Amt      = 0
    Component_Name_Pay  = Component_Name
    Component_Name_Rec  = Component_Name



    IF (Excess_Advance = ''PAY''  ) THEN
    (

      Salary_Sec171 = Outstanding_Advance_for_Allowances_ASG_COMP_LTD
      Recovered_Advance = Salary_Sec171
      Adjustment_Amt = Recovered_Advance


      IF(Recovered_Advance <> 0) THEN
      (
        RETURN Salary_Sec171,
               Recovered_Advance,
               Adjustment_Amt,
               Component_Name_Pay,
               Component_Name_Rec
      )
    )
    ELSE IF (Excess_Advance = ''RECOVER''  ) THEN
    (

      Recovered_Advance = Outstanding_Advance_for_Allowances_ASG_COMP_LTD


      IF Recovered_Advance <> 0 THEN
        RETURN Recovered_Advance,
               Component_Name_Rec
    )

  RETURN

   /* End of Formula */
  ';

----------------------------------------------------------------
--  FORMULA FOR excess ADVANCES ON ACTUAL EXPENSE ALLOWANCES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_formula_obj(11).name := '_AE_EXC_ADV';
  g_formula_obj(11).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_AE_EXC_ADV
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Advances on Actual allowances in India Localization
   -----------------------------------------------------------------------*/

   /* DEFAULT SECTION */
   DEFAULT FOR Excess_Advance IS ''PENDING''

   /* Default for Database Items */
   DEFAULT FOR Outstanding_Advance_for_Allowances_ASG_COMP_LTD IS 0




  /* INPUT SECTION */
    INPUTS ARE Excess_Advance(text),
               Component_Name (text)

  /* INITIALIZATION SECTION   */
   /* Initialization of local variables */

    Recovered_Advance   = 0
    Salary_Sec171      = 0
    Adjustment_Amt      = 0
    Component_Name_Pay  = Component_Name
    Component_Name_Rec  = Component_Name



    IF (Excess_Advance =''PAY''  ) THEN
    (

      Salary_Sec171 = Outstanding_Advance_for_Allowances_ASG_COMP_LTD
      Recovered_Advance = Salary_Sec171
      Adjustment_Amt = Recovered_Advance


      IF(Recovered_Advance <> 0) THEN
      (
        RETURN Salary_Sec171,
               Recovered_Advance,
               Adjustment_Amt,
               Component_Name_Pay,
               Component_Name_Rec
      )
    )
    ELSE IF (Excess_Advance =''RECOVER''  ) THEN
    (

      Recovered_Advance = Outstanding_Advance_for_Allowances_ASG_COMP_LTD


      IF Recovered_Advance <> 0 THEN
        RETURN Recovered_Advance,
               Component_Name_Rec
    )

  RETURN

   /* End of Formula */

  ';
  ----------------------------------------------------------------
--  FORMULA FOR excess ADVANCES ON ACTUAL EXPENSE ALLOWANCES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,80);
  g_formula_obj(12).name := '_LTC_EXC_ADV';
  g_formula_obj(12).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_LTC_EXC_ADV
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Excess Advances on LTC in India Localization
   -----------------------------------------------------------------------*/
   /* DEFAULT SECTION */
   /* Input Value Defaults */
   DEFAULT FOR Excess_Advance IS ''PENDING''

   /* Defined Balance Defaults */
   DEFAULT FOR Outstanding_Advance_for_Earnings_ASG_COMP_LTD IS 0
   DEFAULT FOR Excess_Advance_for_Earnings_ASG_COMP_RUN IS 0



  /* INPUT SECTION */
    INPUTS ARE Excess_Advance(text),
               Component_Name (text)

   /* Following is intended to initialize latest balances */
   l_lt_advance = Outstanding_Advance_for_Earnings_ASG_COMP_LTD

  /* INITIALIZATION SECTION   */
   /* Initialization of out variables */
    Recovered_Advance   = 0
    Salary_Sec171      = 0
    Adjustment_Amt      = 0
    Component_Name_Pay  = Component_Name
    Component_Name_Rec  = Component_Name


    IF (Excess_Advance =''PAY''  ) THEN
    (

      Salary_Sec171 = Outstanding_Advance_for_Earnings_ASG_COMP_LTD
      Recovered_Advance = Salary_Sec171
      Adjustment_Amt = Recovered_Advance


      IF(Recovered_Advance <> 0) THEN
      (

        RETURN Salary_Sec171,
               Recovered_Advance,
               Adjustment_Amt,
               Component_Name_Pay,
               Component_Name_Rec
      )
    )
    ELSE IF (Excess_Advance =''RECOVER''  ) THEN
    (
      Recovered_Advance = Outstanding_Advance_for_Earnings_ASG_COMP_LTD

      IF Recovered_Advance <> 0 THEN
      (
        RETURN Recovered_Advance,
               Component_Name_Rec
      )
    )

    RETURN

   /* End of Formula */';

 ----------------------------------------------------------------
--  FORMULA FOR EMPLOYER CHARGES
----------------------------------------------------------------
  pay_in_utils.set_location(g_debug, l_procedure,60);
  g_formula_obj(13).name := '_EC_CALC';
  g_formula_obj(13).text :=
  '/* $Header: pyinetst.pkb 120.12.12010000.4 2008/09/17 10:50:33 lnagaraj ship $ */
   /*----------------------------------------------------------------------
     FORMULA NAME : <BASE NAME>_EC_CALC
     FORMULA TYPE : Oracle Payroll
     DESCRIPTION  : Formula for Employer Charges in India Localization
   -----------------------------------------------------------------------*/
  /* DEFAULT SECTION */

  /* Default for Database Items */
  DEFAULT FOR PENSION_COMPUTATION_SALARY_ASG_PTD IS  0
  DEFAULT FOR PENSION_COMPUTATION_STANDARD_SALARY_ASG_PTD IS  0
  DEFAULT FOR EMPLOYER_PENSION_CONTRIBUTION_ASG_PTD IS 0
  DEFAULT FOR EMPLOYER_STANDARD_PENSION_CONTRIBUTION_ASG_PTD IS 0

  /* INPUT SECTION */
    INPUTS ARE Contribution_Percentage



    EC_PAY_VALUE=(PENSION_COMPUTATION_SALARY_ASG_PTD*Contribution_Percentage)/100-
                                EMPLOYER_PENSION_CONTRIBUTION_ASG_PTD
    EC_STANDARD_VALUE=(PENSION_COMPUTATION_STANDARD_SALARY_ASG_PTD*Contribution_Percentage)/100 -
                                     EMPLOYER_STANDARD_PENSION_CONTRIBUTION_ASG_PTD


      RETURN EC_PAY_VALUE,
             EC_STANDARD_VALUE

   /* End of Formula */   ';


  pay_in_utils.set_location(g_debug,'Leaving: '|| l_procedure,100);
END init_formula;

END pay_in_etw_struct;

/
