--------------------------------------------------------
--  DDL for Package PER_ZA_PTO_ACCRUAL_PERIOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ZA_PTO_ACCRUAL_PERIOD" AUTHID CURRENT_USER as
/* $Header: perzaapl.pkh 120.1.12000000.1 2007/01/22 04:14:16 appldev noship $ */
/*==========================================================================
  This package contains accrual plan functions. Each Accrual Plan set up
  under HRMS has a main accrual formula which calls one of these functions
  to calculate the accrued PTO for each period. The original PTO design
  had the main accrual formula calling a looping sub-accrual formula but the
  performance was a problem.

  MODIFICATION HISTORY
  Person         Date              Version   Comments
  -------        ------            --------  -----------------------
  R.Kingham      15-MAR-2000       110.0     Initial Version
  J.N. Louw      24-Aug-2000       115.0     Updated for ZAPatch11i.01
  L.Kloppers     21-Dec-2000       115.1     Put 'create...' on one line
  P.Vaish        07-JUL-02         115.2     Added calculation date as an
                                             input parameter.
  R.Pahune       14-Aug-2003       115.3     Added Procedure
					     ZA_PTO_CARRYOVER_RESI_VALUE
					     for the bug no 2932073
					     if the carry over is -ve made it 0
					     along with earlier ZA specific
					     requirements.
 =========================================================================*/

function ZA_PTO_ANNLEAVE_PERIOD_LOOP       (p_Assignment_ID IN  Number
                                           ,p_Plan_ID       IN  Number
                                           ,p_Payroll_ID    IN  Number
                                           ,p_calculation_date    IN  Date)
return number;
--
function ZA_PTO_SICKLEAVE_PERIOD_LOOP      (p_Assignment_ID IN  Number
                                           ,p_Plan_ID       IN  Number
                                           ,p_Payroll_ID    IN  Number)
return number;
--

/* Start Bug 2932073 And 2878657 */
procedure ZA_PTO_CARRYOVER_RESI_VALUE (
				   p_assignment_id			IN Number
				  ,p_plan_id				IN Number
				  ,l_payroll_id				IN Number
				  ,p_business_group_id                  IN Number
				  ,l_effective_date			IN Date
				  ,l_total_accrual			IN Number
				  ,l_net_entitlement			IN number
				  ,l_max_carryover			IN Number
				  ,l_residual				OUT NOCOPY Number
				  ,l_carryover				OUT NOCOPY Number);



--
/* End Bug 2932073 And 2878657 */

end PER_ZA_PTO_ACCRUAL_PERIOD;

 

/
