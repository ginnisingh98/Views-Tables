--------------------------------------------------------
--  DDL for Package BEN_EVALUATE_RATE_MATRIX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_EVALUATE_RATE_MATRIX" AUTHID CURRENT_USER as
/* $Header: benrtmtx.pkh 120.0 2005/05/28 09:28:43 appldev noship $ */

type rate_rec is record
(pl_id                  number,
 rate_matrix_rate_id    number,
 rate_matrix_node_id    number,
 criteria_rate_defn_id  number,
 min_rate_value         number,
 max_rate_value         number,
 mid_rate_value         number,
 rate_value             number,
 level_number           number);

type rate_tab is table of rate_rec
index by binary_integer;

--
-- Public procedure to determine rate given a person and rate type
--
procedure determine_rate
(p_person_id                number default null,
 p_assignment_id            number default null,
 p_criteria_rate_defn_id    number,
 p_effective_date           date,
 p_business_group_id        number,
 p_rate_tab                 out nocopy rate_tab);

end ben_evaluate_rate_matrix;

 

/
