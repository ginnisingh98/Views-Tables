--------------------------------------------------------
--  DDL for Package PQH_RBC_RATE_RETRIEVAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_RBC_RATE_RETRIEVAL" AUTHID CURRENT_USER as
/* $Header: pqrbcpkg.pkh 120.3.12010000.2 2009/10/28 06:07:10 vkodedal ship $ */
--
--
Type g_rbc_rate_val_rec is record(minimum_rate pqh_rate_matrix_rates_f.min_rate_value%type,
                                  maximum_rate pqh_rate_matrix_rates_f.min_rate_value%type,
                                  mid_rate     pqh_rate_matrix_rates_f.min_rate_value%type,
                                  default_rate pqh_rate_matrix_rates_f.min_rate_value%type);
--
Type g_rbc_rate_val_tbl is table of g_rbc_rate_val_rec index by binary_integer;
--
-- Start of Changes to support PAYROLL EVENTS
--
Type g_rbc_factor_rec is record(rate_matrix_rate_id pqh_rate_matrix_rates_f.min_rate_value%type,
                             default_rate pqh_rate_matrix_rates_f.min_rate_value%type);
--
Type g_rbc_factor_tbl is table of g_rbc_factor_rec index by binary_integer;
--
-- End of Changes to support PAYROLL EVENTS
--
-- Main Rate retrieval function.
--
Type tc_ovrd_val is record(
column_name           varchar2(30),
col_value             varchar2(60)); --bug#9054813
--
Type tc_ovrd_tbl is table of tc_ovrd_val index by binary_integer;
--
g_entry_rec  pay_element_entries_f%ROWTYPE;
--
g_ckf_rec    pay_cost_allocation_keyflex%ROWTYPE;
--
g_entry_val_tbl       tc_ovrd_tbl;
--
Procedure determine_rbc_rate
(p_element_entry_id       IN        number,
 p_element_type_id        IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number);
--
Procedure determine_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_person_id              IN        number default null,
 p_assignment_id          IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number);
--
Procedure determine_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_business_group_id      IN        number,
 p_criteria_list          IN        pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl,
 p_effective_date         IN        date,
 p_rate_factors          OUT nocopy g_rbc_factor_tbl,
 p_rate_factor_cnt       OUT nocopy number,
 p_min_rate              OUT nocopy number,
 p_mid_rate              OUT nocopy number,
 p_max_rate              OUT nocopy number,
 p_rate                  OUT nocopy number);
--
Function get_persons_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_person_id              IN        number default null,
 p_assignment_id          IN        number default null,
 p_business_group_id      IN        number,
 p_effective_date         IN        date)
return  number;
--
Function get_persons_rbc_rate
(p_element_type_id        IN        number default null,
 p_crit_rt_defn_id        IN        number default null,
 p_business_group_id      IN        number,
 p_criteria_list          IN        pqh_popl_criteria_ovrrd.g_crit_ovrrd_val_tbl,
 p_effective_date         IN        date)
return  number ;
--
Function get_ele_entry_rbc_rate
(p_element_entry_id       IN        number,
 p_business_group_id      IN        number,
 p_effective_date         IN        date)
return  number;
--
Function get_ele_entry_rbc_rate
(p_element_entry_id       IN        number,
 p_business_group_id      IN        number,
 p_effective_date         IN        date,
 p_element_type_id        IN        number)
return  number;
--
End pqh_rbc_rate_retrieval;
--

/
