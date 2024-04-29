--------------------------------------------------------
--  DDL for Package PAY_FR_SICK_PAY_PROCESSING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_SICK_PAY_PROCESSING" AUTHID CURRENT_USER AS
  /* $Header: pyfrsppr.pkh 120.1 2005/08/29 07:37:49 ayegappa noship $ */
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Constants for the types of guarantee (numeric).
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --
  cs_GN         CONSTANT NUMBER := 10;    -- Garantie au Net
  cs_LE         CONSTANT NUMBER := 20;    -- Legal
  cs_CA_G_ADJ   CONSTANT NUMBER := 30;    -- Collectively agreed gross with adjustment
  cs_CA_G_NOADJ CONSTANT NUMBER := 40;    -- Collectively agreed gross without adjustment
  cs_CA_N       CONSTANT NUMBER := 50;    -- Collectively agreed net
  cs_NO_G       CONSTANT NUMBER := 60;    -- No guarantee
  cs_FINAL      CONSTANT NUMBER := 100;   -- Final Run
  --
  --
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  -- Custom data types
  -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  --

 TYPE t_asg IS RECORD
  (assignment_id 		NUMBER
  ,sick_net                     NUMBER
  ,base_net      		NUMBER
  ,assignment_action_id 	NUMBER
  ,action_start_date    	DATE
  ,action_end_date      	DATE
  ,business_group_id    	NUMBER
  ,payroll_action_id    	NUMBER
  ,payroll_id           	NUMBER
  ,element_type_id      	NUMBER
  ,deduct_formula               NUMBER
  ,ded_ref_salary               NUMBER
  ,lg_ref_salary		NUMBER);

  --

  TYPE t_absence_arch IS RECORD
  (element_entry_id 		NUMBER
  ,date_earned      		DATE
  ,ID               		NUMBER
  ,sick_deduction   		NUMBER
  ,sick_deduction_rate    	NUMBER
  ,sick_deduction_base		NUMBER
  ,sick_deduct_start_date       DATE
  ,sick_deduct_end_date         DATE
  ,ijss_net			NUMBER
  ,ijss_estimated   		VARCHAR2(1)
  ,ijss_payment           	NUMBER
  ,parent_absence_id		NUMBER
  ,gi_adjustment                NUMBER
  ,gross_ijss_adjustment        NUMBER
  -- added for days paid balances
  ,partial_paid_days            NUMBER
  ,unpaid_days                  NUMBER
  );

  --
  TYPE t_coverage IS RECORD
  (g_type          		NUMBER
  ,cagr_id         		NUMBER
  ,gi_payment1      		NUMBER
  ,gi_rate1         		NUMBER
  ,gi_days1         		NUMBER
  ,gi_from_date1    		DATE
  ,gi_to_date1      		DATE
  ,gi_payment2      		NUMBER
  ,gi_rate2         		NUMBER
  ,gi_days2         		NUMBER
  ,gi_from_date2    		DATE
  ,gi_to_date2      		DATE
  ,sick_adj        		NUMBER
  ,net           		NUMBER
  ,ijss_gross1      		NUMBER
  ,ijss_gross_rate1 		NUMBER
  ,ijss_gross_days1 		NUMBER
  ,ijss_from_date1  		DATE
  ,ijss_to_date1    		DATE
  ,ijss_gross2      		NUMBER
  ,ijss_gross_rate2 		NUMBER
  ,ijss_gross_days2 		NUMBER
  ,ijss_from_date2  		DATE
  ,ijss_to_date2    		DATE
  ,band1         		NUMBER
  ,band2         		NUMBER
  ,band3         		NUMBER
  ,band4         		NUMBER
  ,best_method   		VARCHAR2(1)
  ,processed_flag   		VARCHAR2(1)
  ,previous_net    		NUMBER
  ,previous_gi_payment  	NUMBER
  ,previous_sick_adj            NUMBER
  ,previous_ijss_gross	        NUMBER
  ,ijss_net_adjustment          NUMBER);

  --
  TYPE t_coverages IS TABLE OF t_coverage INDEX BY BINARY_INTEGER;
  --
  TYPE t_rule IS RECORD
  (net    NUMBER
  ,repeat NUMBER
  ,stop   NUMBER);
  --
  TYPE t_rules IS TABLE OF t_rule INDEX BY BINARY_INTEGER;
  --
  TYPE t_iter_rule IS RECORD
  (ijss_payment    VARCHAR2(1)
  ,deduct_for_sick VARCHAR2(1)
  ,gi_payment      VARCHAR2(1)
  ,sick_adj        VARCHAR2(1)
  ,gi_adj          VARCHAR2(1)
  ,gross_ijss_adj     VARCHAR2(1));

  --
  TYPE t_iter_rules IS TABLE OF t_iter_rule INDEX BY BINARY_INTEGER;
  --
  TYPE t_ctl IS RECORD
  (g_idx       NUMBER
  ,iter        NUMBER
  ,p_mode      NUMBER
  ,audit_g_idx NUMBER);
  --
  TYPE t_guarantee_type_lookups IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
  --
 FUNCTION iterate
  (p_assignment_id       	NUMBER
  ,p_element_entry_id    	NUMBER
  ,p_date_earned         	DATE
  ,p_assignment_action_id  	NUMBER
  ,p_business_group_id     	NUMBER
  ,p_payroll_action_id     	NUMBER
  ,p_payroll_id            	NUMBER
  ,p_element_type_id       	NUMBER
  ,p_net_pay             	NUMBER
  ,p_deduct_formula             NUMBER
  ,p_action_start_date          DATE
  ,p_action_end_date            DATE
  ,p_ded_ref_salary             NUMBER
  ,p_lg_ref_salary		NUMBER
  ,p_stop_processing 	 OUT NOCOPY VARCHAR2) RETURN NUMBER;


FUNCTION indirects
(
P_ABSENCE_ID			 OUT NOCOPY NUMBER,
P_ijss_net 			 OUT NOCOPY NUMBER,
P_ijss_payment 			 OUT NOCOPY NUMBER,
P_ijss_gross1 			 OUT NOCOPY NUMBER,
P_ijss_gross2 			 OUT NOCOPY NUMBER,
p_ijss_estmtd                    OUT NOCOPY VARCHAR2,
P_ijss_gross1_rate		 OUT NOCOPY NUMBER,
P_ijss_gross2_rate		 OUT NOCOPY NUMBER,
P_ijss_gross1_base		 OUT NOCOPY NUMBER,
P_ijss_gross2_base		 OUT NOCOPY NUMBER,
P_ijss_gross1_fromdate		 OUT NOCOPY DATE,
P_ijss_gross2_fromdate		 OUT NOCOPY DATE,
P_ijss_gross1_todate		 OUT NOCOPY DATE,
P_ijss_gross2_todate		 OUT NOCOPY DATE,
P_gi_payment1 			 OUT NOCOPY NUMBER,
P_gi_payment2 			 OUT NOCOPY NUMBER,
P_gi_payment1_rate		 OUT NOCOPY NUMBER,
P_gi_payment2_rate		 OUT NOCOPY NUMBER,
P_gi_payment1_base		 OUT NOCOPY NUMBER,
P_gi_payment2_base		 OUT NOCOPY NUMBER,
P_gi_payment1_fromdate		 OUT NOCOPY DATE,
P_gi_payment2_fromdate		 OUT NOCOPY DATE,
P_gi_payment1_todate		 OUT NOCOPY DATE,
P_gi_payment2_todate		 OUT NOCOPY DATE,
P_sick_adj			 OUT NOCOPY NUMBER,
P_sick_deduct   		 OUT NOCOPY NUMBER,
P_sick_deduct_rate		 OUT NOCOPY NUMBER,
P_sick_deduct_base		 OUT NOCOPY NUMBER,
P_gi_adjustment 		 OUT NOCOPY NUMBER,
P_gross_ijss_adj 		 OUT NOCOPY NUMBER,
P_audit			         OUT NOCOPY VARCHAR2,
P_deduct_start_date              OUT NOCOPY DATE,
P_deduct_end_date                OUT NOCOPY DATE,
-- added for paid days balances
p_red_partial_days                     OUT NOCOPY NUMBER,
p_red_unpaid_days                      OUT NOCOPY NUMBER,
-- Obtains the current Rate Input value 4504304
p_net                                  OUT NOCOPY NUMBER
--
)	    RETURN NUMBER ;


 FUNCTION audit
  (p_parent_abs_id           OUT NOCOPY NUMBER
  ,p_guarantee_type          OUT NOCOPY VARCHAR2
  ,p_cagr_id                 OUT NOCOPY NUMBER
  ,p_net                     OUT NOCOPY NUMBER
  ,p_gi_payment              OUT NOCOPY NUMBER
  ,p_band1                   OUT NOCOPY NUMBER
  ,p_band2                   OUT NOCOPY NUMBER
  ,p_band3                   OUT NOCOPY NUMBER
  ,p_band4                   OUT NOCOPY NUMBER
  ,p_best_method             OUT NOCOPY VARCHAR2
  ,p_sick_adjustment         OUT NOCOPY NUMBER
  ,p_gi_adjustment           OUT NOCOPY NUMBER
  ,p_gross_ijss_adj          OUT NOCOPY NUMBER
  ,p_ijss_gross              OUT NOCOPY NUMBER
  ,p_audit                   OUT NOCOPY VARCHAR2
  ,p_payment_start_date      OUT NOCOPY DATE
  ,p_payment_end_date        OUT NOCOPY DATE
 ) RETURN NUMBER ;

FUNCTION get_guarantee_id(
P_type     IN  VARCHAR2 )  RETURN NUMBER ;

END pay_fr_sick_pay_processing;

 

/
