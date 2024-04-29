--------------------------------------------------------
--  DDL for Package BEN_ASG_BUDGET_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_ASG_BUDGET_VALUES" AUTHID CURRENT_USER as
/* $Header: bebudapi.pkh 120.0 2005/05/28 00:53:30 appldev noship $ */
--
--
--

Procedure create_budget_values
(p_assignment_id in number,
p_effective_date in date,
p_unit in varchar2,
p_business_group_id in number,
p_value in number,
p_datetrack_mode in varchar2
);

---

procedure update_dml
(P_ASSIGNMENT_BUDGET_VALUE_ID IN NUMBER,
P_EFFECTIVE_END_DATE IN DATE,
P_BUSINESS_GROUP_ID IN NUMBER,
P_ASSIGNMENT_ID  IN NUMBER,
P_VALUE IN NUMBER
);

--
PROCEDURE insert_budget_values
(p_assignment_id in number,
p_effective_date in date,
p_unit in varchar2,
p_business_group_id in number,
p_value in number,
p_rowid in varchar2,
p_assignment_budget_value_id in number);

---
procedure insert_dml
(P_ASSIGNMENT_BUDGET_VALUE_ID IN NUMBER,
p_EFFECTIVE_START_DATE IN DATE,
P_EFFECTIVE_END_DATE IN DATE,
P_BUSINESS_GROUP_ID IN NUMBER,
P_ASSIGNMENT_ID  IN NUMBER,
P_UNIT IN VARCHAR2,
P_VALUE IN NUMBER
);
---
end ben_asg_budget_values;

 

/
