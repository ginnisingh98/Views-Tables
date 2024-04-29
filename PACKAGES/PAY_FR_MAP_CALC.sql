--------------------------------------------------------
--  DDL for Package PAY_FR_MAP_CALC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_FR_MAP_CALC" AUTHID CURRENT_USER AS
/* $Header: pyfrmapp.pkh 115.15 2003/02/10 12:08:57 vsjain noship $ */
-----------------------------------------------------------------------
-- Date     Ver       	Author          Comments
-- 16-12-02 115.0      	asnell          Initial version of package
-- 10-01-03 115.1       vjain           Added Architectural procedures
-- 13-01-03 115.2       vjain           Modified procedures following
--                                      comments from formal review
-- 13-01-03 115.3       vjain           Changes in PLSQL str for IJSS_NET
-- 17-01-03 115.4       asnell          added t_map_calc columns
-- 20-01-03 115.5       vjain           added maternity deduction procedure
-- 21-01-03 115.6       vjain           Changes for init_cpam_absence
-- 22-01-03 115.7       asnell          added tmap_calc columns
-- 03-02-03 115.11      vjain           initial changes after map calc review
-- ---------------------------------------------------------------------
--
--

-- GLOBAL DATA STRUCTURES
TYPE T_MAP_ARCH IS RECORD
(ASSIGNMENT_ID		NUMBER
, ELEMENT_ENTRY_ID	NUMBER
, DATE_EARNED		DATE
, ASSIGNMENT_ACTION_ID  NUMBER
, ACTION_START_DATE     DATE
, ACTION_END_DATE       DATE
, BUSINESS_GROUP_ID     NUMBER
, PAYROLL_ACTION_ID     NUMBER
, PAYROLL_ID            NUMBER
, ELEMENT_TYPE_ID       NUMBER
, DEDUCT_FORMULA        NUMBER
, DED_REF_SALARY        NUMBER
, NOTIONAL_SS_RATE      NUMBER
, NET                   NUMBER
);
g_map_arch t_map_arch;

TYPE T_MAP_CALC IS RECORD
(ABSENCE_ID                NUMBER
, PARENT_ABSENCE_ID        NUMBER
, PERSON_ID                NUMBER
, ABSENCE_CATEGORY         VARCHAR2(30)
, PARENT_ABSENCE_START_DATE DATE
, PARENT_ABSENCE_END_DATE   DATE
, DEDUCTION                NUMBER
, DEDUCTION_RATE           NUMBER
, DEDUCTION_BASE           NUMBER
, DEDUCTION_START_DATE     DATE
, DEDUCTION_END_DATE       DATE
, START_DATE               DATE
, END_DATE                 DATE
, ABSENCE_START_DATE       DATE
, ESTIMATED_IJSS           VARCHAR2(1)
, GI_ELIGIBLE              VARCHAR2(4)
, BIRTHS                   NUMBER
, BIRTH_DATE               DATE
, ELIG_IJSS_HOURS          VARCHAR2(1)
, ELIG_IJSS_CONTRIB        NUMBER
, ELIG_IJSS                VARCHAR2(1)
, SPOUSES_LEAVE            NUMBER
, IJSS_NET_PAYMENT         NUMBER
, IJSS_ADJUSTMENT          VARCHAR2(1)
, GI_PAYMENT               NUMBER
, GI_IJSS_ADJ              NUMBER
, IJSS_GROSS               NUMBER
, IJSS_GROSS_RATE          NUMBER
, IJSS_GROSS_DAYS          NUMBER
, IJSS_GROSS_START_DATE    DATE
, IJSS_GROSS_END_DATE      DATE
, INITIATOR                VARCHAR2(30)
);

g_map_calc t_map_calc;

 TYPE t_ctl IS RECORD
  (iter        NUMBER
  ,p_mode      NUMBER);


-- CALC_SICKNESS_DEDUCTION
-- fires legislative or user formula as indicated on the establishment
-- to calculate the deduction for sickness absence

Procedure Calculate_Maternity_Deduction;

-- calculates maternity IJSS
PROCEDURE CALC_MAP_IJSS(
p_assignment_id         IN  Number,
p_start_date            IN  Date,
p_end_date              IN  Date
);

-----------------------------------------------------------------------
-- use the PQH shared type mapping to identify how many dependent
-- children the emloyee has as of the reference date
FUNCTION COUNT_CHILDREN(
p_person_id IN Number,
p_effective_date IN Date) return NUMBER;

-----------------------------------------------------------------------
-- CALC_MAP
-- initiates all sickness calculations and performs comparison of
-- most beneficial guarantee over the whole absence period.
--
PROCEDURE calc_map;
--
-- init_absence
-- populates internal PL/SQL structure with passed parameter values
-- Decides skipping based on ijss estimate information.
--

FUNCTION init_map_absence(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
p_business_group_id     IN      Number,
p_payroll_id            IN      Number,
p_assignment_action_id  IN      Number,
p_element_type_id       IN      Number,
p_deduction_formula     IN      Number,
p_deduction_ref_salary  IN      Number,
P_action_start_date     IN      Date,
P_action_end_date       IN      Date,
p_notional_ss_rate      IN      Number)
RETURN Varchar2 ;
--
FUNCTION init_cpam_absence(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
p_business_group_id     IN      Number,
p_payroll_id            IN      Number,
p_assignment_action_id  IN      Number,
p_element_type_id       IN      Number,
p_payment_from_date     IN      Date,
p_payment_to_date       IN      Date,
p_days                  IN      Number,
p_gross_amount          IN      Number,
p_net_amount            IN      Number,
p_gross_daily_rate      IN      Number)
RETURN Varchar2 ;

-- get_map_skip
-- Gets skip information from internal PL/SQL structure
-- Decides skipping or processing of element.
--

FUNCTION get_map_skip
RETURN Varchar2 ;
--

-- iterate
-- controls iteration logic for process
-- Decides number of iteration, finds adjustment and stop processing.
--

FUNCTION iterate(
P_Assignment_id         IN      Number,
P_element_entry_id      IN      Number,
P_date_earned           IN      Date,
p_net_pay               IN      Number,
p_stop_processing       OUT NOCOPY Varchar2)

RETURN Number ;
--

-- indirects
-- Create indirects for maternity process and populates input values
-- Decides which element should be created
--

FUNCTION indirects
 ( p_absence_id            out nocopy number,
   p_ijss_gross            out nocopy number,
   p_ijss_gross_rate       out nocopy number,
   p_ijss_gross_base       out nocopy number,
   p_ijss_gross_start_date out nocopy date,
   p_ijss_gross_end_date   out nocopy date,
   p_ijss_estmtd           out nocopy varchar2,
   p_ijss_net_payment      out nocopy number,
   p_map_deduction         out nocopy number,
   p_map_deduction_rate    out nocopy number,
   p_map_deduction_base    out nocopy number,
   p_map_deduct_start_date out nocopy date,
   p_map_deduct_end_date   out nocopy date,
   p_map_gi_payment        out nocopy number,
   p_map_ijss_adjustment   out nocopy number)

RETURN Number ;
--

PROCEDURE reset_data_structures;
--

PROCEDURE increment_iteration;
--

PROCEDURE set_adjustment
    (p_net_pay NUMBER);
--

END PAY_FR_MAP_CALC;

 

/
