--------------------------------------------------------
--  DDL for Package PER_IT_QH_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IT_QH_TAX" AUTHID CURRENT_USER as
/* $Header: peitqhtx.pkh 115.3 2002/11/26 16:34:17 jahobbs noship $ */

procedure update_it_tax_data
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

procedure it_tax_query
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

end per_it_qh_tax;

 

/
