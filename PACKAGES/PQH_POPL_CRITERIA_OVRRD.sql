--------------------------------------------------------
--  DDL for Package PQH_POPL_CRITERIA_OVRRD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_POPL_CRITERIA_OVRRD" AUTHID CURRENT_USER as
/* $Header: pqrbcovd.pkh 120.0 2005/05/29 02:24 appldev noship $ */
--
-- Record structure for passing criteria list, for which rate has to be evaluated.
-- May need to change the structure based on BEN changes.
--
Type g_crit_ovrrd_val_rec is record(criteria_short_code varchar2(30),
                                    number_value1       number(15),
                                    number_value2       number(15),
                                    char_value1         varchar2(240),
                                    char_value2         varchar2(240),
                                    date_value1         date,
                                    date_value2         date);
--
Type g_crit_ovrrd_val_tbl is table of g_crit_ovrrd_val_rec index by binary_integer;
--
g_criteria_override_val   g_crit_ovrrd_val_tbl; /** Table with override data, accessed by BEN **/
g_criteria_count          number(15) := 0; /** If count > 0, then there is override data in above table **/
--
Procedure init_criteria_override_tbl;
--
Procedure insert_criteria_override(p_crit_ovrrd_val_rec IN g_crit_ovrrd_val_rec);
--
Procedure get_criteria_override(p_crit_ovrrd_val_rec OUT nocopy g_crit_ovrrd_val_rec);
--
--
End pqh_popl_criteria_ovrrd;

 

/
