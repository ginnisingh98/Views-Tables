--------------------------------------------------------
--  DDL for Package PER_NL_QH_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NL_QH_TAX" AUTHID CURRENT_USER as
/* $Header: penlqhtx.pkh 115.2 2002/11/28 10:03:21 pgdavies noship $ */

procedure update_nl_tax_data
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

procedure nl_tax_query
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

end per_nl_qh_tax;

 

/
