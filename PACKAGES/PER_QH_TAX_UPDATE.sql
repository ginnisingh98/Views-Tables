--------------------------------------------------------
--  DDL for Package PER_QH_TAX_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_QH_TAX_UPDATE" AUTHID CURRENT_USER as
/* $Header: peqhtaxi.pkh 115.3 2004/02/10 00:38:57 jpthomas noship $ */

procedure insert_tax_data
(tax_effective_start_date in out nocopy date
,tax_effective_end_date   in out nocopy date
,tax_field1         in out nocopy VARCHAR2
,tax_field2         in out nocopy VARCHAR2
,tax_field3         in out nocopy VARCHAR2
,tax_field4         in out nocopy VARCHAR2
,tax_field5         in out nocopy VARCHAR2
,tax_field6         in out nocopy VARCHAR2
,tax_field7         in out nocopy VARCHAR2
,tax_field8         in out nocopy VARCHAR2
,tax_field9         in out nocopy VARCHAR2
,tax_field10        in out nocopy VARCHAR2
,tax_field11        in out nocopy VARCHAR2
,tax_field12        in out nocopy VARCHAR2
,tax_field13        in out nocopy VARCHAR2
,tax_field14        in out nocopy VARCHAR2
,tax_field15        in out nocopy VARCHAR2
,tax_field16        in out nocopy VARCHAR2
,tax_field17        in out nocopy VARCHAR2
,tax_field18        in out nocopy VARCHAR2
,tax_field19        in out nocopy VARCHAR2
,tax_field20        in out nocopy VARCHAR2
,tax_field21        in out nocopy VARCHAR2
,tax_field22        in out nocopy VARCHAR2
,tax_field23        in out nocopy VARCHAR2
,tax_field24        in out nocopy VARCHAR2
,tax_field25        in out nocopy VARCHAR2
,tax_field26        in out nocopy VARCHAR2
,tax_field27        in out nocopy VARCHAR2
,tax_field28        in out nocopy VARCHAR2
,tax_field29        in out nocopy VARCHAR2
,tax_field30        in out nocopy VARCHAR2
,tax_field31        in out nocopy VARCHAR2
,tax_field32        in out nocopy VARCHAR2
,tax_field33        in out nocopy VARCHAR2
,tax_field34        in out nocopy VARCHAR2
,tax_field35        in out nocopy VARCHAR2
,tax_field36        in out nocopy VARCHAR2
,tax_field37        in out nocopy VARCHAR2
,tax_field38        in out nocopy VARCHAR2
,tax_field39        in out nocopy VARCHAR2
,tax_field40        in out nocopy VARCHAR2
,tax_field41        in out nocopy VARCHAR2
,tax_field42        in out nocopy VARCHAR2
,tax_field43        in out nocopy VARCHAR2
,tax_field44        in out nocopy VARCHAR2
,tax_field45        in out nocopy VARCHAR2
,tax_field46        in out nocopy VARCHAR2
,tax_field47        in out nocopy VARCHAR2
,tax_field48        in out nocopy VARCHAR2
,tax_field49        in out nocopy VARCHAR2
,tax_field50        in out nocopy VARCHAR2
,tax_field51        in out nocopy VARCHAR2
,tax_field52        in out nocopy VARCHAR2
,tax_field53        in out nocopy VARCHAR2
,tax_field54        in out nocopy VARCHAR2
,tax_field55        in out nocopy VARCHAR2
,tax_field56        in out nocopy VARCHAR2
,tax_field57        in out nocopy VARCHAR2
,tax_field58        in out nocopy VARCHAR2
,tax_field59        in out nocopy VARCHAR2
,tax_field60        in out nocopy VARCHAR2
,tax_field61        in out nocopy VARCHAR2
,tax_field62        in out nocopy VARCHAR2
,tax_field63        in out nocopy VARCHAR2
,tax_field64        in out nocopy VARCHAR2
,tax_field65        in out nocopy VARCHAR2
,tax_field66        in out nocopy VARCHAR2
,tax_field67        in out nocopy VARCHAR2
,tax_field68        in out nocopy VARCHAR2
,tax_field69        in out nocopy VARCHAR2
,tax_field70        in out nocopy VARCHAR2
,tax_field71        in out nocopy VARCHAR2
,tax_field72        in out nocopy VARCHAR2
,tax_field73        in out nocopy VARCHAR2
,tax_field74        in out nocopy VARCHAR2
,tax_field75        in out nocopy VARCHAR2
,tax_field76        in out nocopy VARCHAR2
,tax_field77        in out nocopy VARCHAR2
,tax_field78        in out nocopy VARCHAR2
,tax_field79        in out nocopy VARCHAR2
,tax_field80        in out nocopy VARCHAR2
,tax_field81        in out nocopy VARCHAR2
,tax_field82        in out nocopy VARCHAR2
,tax_field83        in out nocopy VARCHAR2
,tax_field84        in out nocopy VARCHAR2
,tax_field85        in out nocopy VARCHAR2
,tax_field86        in out nocopy VARCHAR2
,tax_field87        in out nocopy VARCHAR2
,tax_field88        in out nocopy VARCHAR2
,tax_field89        in out nocopy VARCHAR2
,tax_field90        in out nocopy VARCHAR2
,tax_field91        in out nocopy VARCHAR2
,tax_field92        in out nocopy VARCHAR2
,tax_field93        in out nocopy VARCHAR2
,tax_field94        in out nocopy VARCHAR2
,tax_field95        in out nocopy VARCHAR2
,tax_field96        in out nocopy VARCHAR2
,tax_field97        in out nocopy VARCHAR2
,tax_field98        in out nocopy VARCHAR2
,tax_field99        in out nocopy VARCHAR2
,tax_field100       in out nocopy VARCHAR2
,tax_field101       in out nocopy VARCHAR2
,tax_field102       in out nocopy VARCHAR2
,tax_field103       in out nocopy VARCHAR2
,tax_field104       in out nocopy VARCHAR2
,tax_field105       in out nocopy VARCHAR2
,tax_field106       in out nocopy VARCHAR2
,tax_field107       in out nocopy VARCHAR2
,tax_field108       in out nocopy VARCHAR2
,tax_field109       in out nocopy VARCHAR2
,tax_field110       in out nocopy VARCHAR2
,tax_field111       in out nocopy VARCHAR2
,tax_field112       in out nocopy VARCHAR2
,tax_field113       in out nocopy VARCHAR2
,tax_field114       in out nocopy VARCHAR2
,tax_field115       in out nocopy VARCHAR2
,tax_field116       in out nocopy VARCHAR2
,tax_field117       in out nocopy VARCHAR2
,tax_field118       in out nocopy VARCHAR2
,tax_field119       in out nocopy VARCHAR2
,tax_field120       in out nocopy VARCHAR2
,tax_field121       in out nocopy VARCHAR2
,tax_field122       in out nocopy VARCHAR2
,tax_field123       in out nocopy VARCHAR2
,tax_field124       in out nocopy VARCHAR2
,tax_field125       in out nocopy VARCHAR2
,tax_field126       in out nocopy VARCHAR2
,tax_field127       in out nocopy VARCHAR2
,tax_field128       in out nocopy VARCHAR2
,tax_field129       in out nocopy VARCHAR2
,tax_field130       in out nocopy VARCHAR2
,tax_field131       in out nocopy VARCHAR2
,tax_field132       in out nocopy VARCHAR2
,tax_field133       in out nocopy VARCHAR2
,tax_field134       in out nocopy VARCHAR2
,tax_field135       in out nocopy VARCHAR2
,tax_field136       in out nocopy VARCHAR2
,tax_field137       in out nocopy VARCHAR2
,tax_field138       in out nocopy VARCHAR2
,tax_field139       in out nocopy VARCHAR2
,tax_field140       in out nocopy VARCHAR2
-- Bug 3357807 Start Here
,tax_field141                 IN OUT NOCOPY DATE
,tax_field142                 IN OUT NOCOPY DATE
,tax_field143                 IN OUT NOCOPY DATE
,tax_field144                 IN OUT NOCOPY DATE
,tax_field145                 IN OUT NOCOPY DATE
,tax_field146                 IN OUT NOCOPY DATE
,tax_field147                 IN OUT NOCOPY DATE
,tax_field148                 IN OUT NOCOPY DATE
,tax_field149                 IN OUT NOCOPY DATE
,tax_field150                 IN OUT NOCOPY DATE
-- Bug 3357807 End Here
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

procedure insert_tax_data
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

procedure update_tax_data
(tax_effective_start_date in out nocopy date
,tax_effective_end_date   in out nocopy date
,tax_field1         in out nocopy VARCHAR2
,tax_field2         in out nocopy VARCHAR2
,tax_field3         in out nocopy VARCHAR2
,tax_field4         in out nocopy VARCHAR2
,tax_field5         in out nocopy VARCHAR2
,tax_field6         in out nocopy VARCHAR2
,tax_field7         in out nocopy VARCHAR2
,tax_field8         in out nocopy VARCHAR2
,tax_field9         in out nocopy VARCHAR2
,tax_field10        in out nocopy VARCHAR2
,tax_field11        in out nocopy VARCHAR2
,tax_field12        in out nocopy VARCHAR2
,tax_field13        in out nocopy VARCHAR2
,tax_field14        in out nocopy VARCHAR2
,tax_field15        in out nocopy VARCHAR2
,tax_field16        in out nocopy VARCHAR2
,tax_field17        in out nocopy VARCHAR2
,tax_field18        in out nocopy VARCHAR2
,tax_field19        in out nocopy VARCHAR2
,tax_field20        in out nocopy VARCHAR2
,tax_field21        in out nocopy VARCHAR2
,tax_field22        in out nocopy VARCHAR2
,tax_field23        in out nocopy VARCHAR2
,tax_field24        in out nocopy VARCHAR2
,tax_field25        in out nocopy VARCHAR2
,tax_field26        in out nocopy VARCHAR2
,tax_field27        in out nocopy VARCHAR2
,tax_field28        in out nocopy VARCHAR2
,tax_field29        in out nocopy VARCHAR2
,tax_field30        in out nocopy VARCHAR2
,tax_field31        in out nocopy VARCHAR2
,tax_field32        in out nocopy VARCHAR2
,tax_field33        in out nocopy VARCHAR2
,tax_field34        in out nocopy VARCHAR2
,tax_field35        in out nocopy VARCHAR2
,tax_field36        in out nocopy VARCHAR2
,tax_field37        in out nocopy VARCHAR2
,tax_field38        in out nocopy VARCHAR2
,tax_field39        in out nocopy VARCHAR2
,tax_field40        in out nocopy VARCHAR2
,tax_field41        in out nocopy VARCHAR2
,tax_field42        in out nocopy VARCHAR2
,tax_field43        in out nocopy VARCHAR2
,tax_field44        in out nocopy VARCHAR2
,tax_field45        in out nocopy VARCHAR2
,tax_field46        in out nocopy VARCHAR2
,tax_field47        in out nocopy VARCHAR2
,tax_field48        in out nocopy VARCHAR2
,tax_field49        in out nocopy VARCHAR2
,tax_field50        in out nocopy VARCHAR2
,tax_field51        in out nocopy VARCHAR2
,tax_field52        in out nocopy VARCHAR2
,tax_field53        in out nocopy VARCHAR2
,tax_field54        in out nocopy VARCHAR2
,tax_field55        in out nocopy VARCHAR2
,tax_field56        in out nocopy VARCHAR2
,tax_field57        in out nocopy VARCHAR2
,tax_field58        in out nocopy VARCHAR2
,tax_field59        in out nocopy VARCHAR2
,tax_field60        in out nocopy VARCHAR2
,tax_field61        in out nocopy VARCHAR2
,tax_field62        in out nocopy VARCHAR2
,tax_field63        in out nocopy VARCHAR2
,tax_field64        in out nocopy VARCHAR2
,tax_field65        in out nocopy VARCHAR2
,tax_field66        in out nocopy VARCHAR2
,tax_field67        in out nocopy VARCHAR2
,tax_field68        in out nocopy VARCHAR2
,tax_field69        in out nocopy VARCHAR2
,tax_field70        in out nocopy VARCHAR2
,tax_field71        in out nocopy VARCHAR2
,tax_field72        in out nocopy VARCHAR2
,tax_field73        in out nocopy VARCHAR2
,tax_field74        in out nocopy VARCHAR2
,tax_field75        in out nocopy VARCHAR2
,tax_field76        in out nocopy VARCHAR2
,tax_field77        in out nocopy VARCHAR2
,tax_field78        in out nocopy VARCHAR2
,tax_field79        in out nocopy VARCHAR2
,tax_field80        in out nocopy VARCHAR2
,tax_field81        in out nocopy VARCHAR2
,tax_field82        in out nocopy VARCHAR2
,tax_field83        in out nocopy VARCHAR2
,tax_field84        in out nocopy VARCHAR2
,tax_field85        in out nocopy VARCHAR2
,tax_field86        in out nocopy VARCHAR2
,tax_field87        in out nocopy VARCHAR2
,tax_field88        in out nocopy VARCHAR2
,tax_field89        in out nocopy VARCHAR2
,tax_field90        in out nocopy VARCHAR2
,tax_field91        in out nocopy VARCHAR2
,tax_field92        in out nocopy VARCHAR2
,tax_field93        in out nocopy VARCHAR2
,tax_field94        in out nocopy VARCHAR2
,tax_field95        in out nocopy VARCHAR2
,tax_field96        in out nocopy VARCHAR2
,tax_field97        in out nocopy VARCHAR2
,tax_field98        in out nocopy VARCHAR2
,tax_field99        in out nocopy VARCHAR2
,tax_field100       in out nocopy VARCHAR2
,tax_field101       in out nocopy VARCHAR2
,tax_field102       in out nocopy VARCHAR2
,tax_field103       in out nocopy VARCHAR2
,tax_field104       in out nocopy VARCHAR2
,tax_field105       in out nocopy VARCHAR2
,tax_field106       in out nocopy VARCHAR2
,tax_field107       in out nocopy VARCHAR2
,tax_field108       in out nocopy VARCHAR2
,tax_field109       in out nocopy VARCHAR2
,tax_field110       in out nocopy VARCHAR2
,tax_field111       in out nocopy VARCHAR2
,tax_field112       in out nocopy VARCHAR2
,tax_field113       in out nocopy VARCHAR2
,tax_field114       in out nocopy VARCHAR2
,tax_field115       in out nocopy VARCHAR2
,tax_field116       in out nocopy VARCHAR2
,tax_field117       in out nocopy VARCHAR2
,tax_field118       in out nocopy VARCHAR2
,tax_field119       in out nocopy VARCHAR2
,tax_field120       in out nocopy VARCHAR2
,tax_field121       in out nocopy VARCHAR2
,tax_field122       in out nocopy VARCHAR2
,tax_field123       in out nocopy VARCHAR2
,tax_field124       in out nocopy VARCHAR2
,tax_field125       in out nocopy VARCHAR2
,tax_field126       in out nocopy VARCHAR2
,tax_field127       in out nocopy VARCHAR2
,tax_field128       in out nocopy VARCHAR2
,tax_field129       in out nocopy VARCHAR2
,tax_field130       in out nocopy VARCHAR2
,tax_field131       in out nocopy VARCHAR2
,tax_field132       in out nocopy VARCHAR2
,tax_field133       in out nocopy VARCHAR2
,tax_field134       in out nocopy VARCHAR2
,tax_field135       in out nocopy VARCHAR2
,tax_field136       in out nocopy VARCHAR2
,tax_field137       in out nocopy VARCHAR2
,tax_field138       in out nocopy VARCHAR2
,tax_field139       in out nocopy VARCHAR2
,tax_field140       in out nocopy VARCHAR2
-- Bug 3357807 Start Here
,tax_field141                 IN OUT NOCOPY DATE
,tax_field142                 IN OUT NOCOPY DATE
,tax_field143                 IN OUT NOCOPY DATE
,tax_field144                 IN OUT NOCOPY DATE
,tax_field145                 IN OUT NOCOPY DATE
,tax_field146                 IN OUT NOCOPY DATE
,tax_field147                 IN OUT NOCOPY DATE
,tax_field148                 IN OUT NOCOPY DATE
,tax_field149                 IN OUT NOCOPY DATE
,tax_field150                 IN OUT NOCOPY DATE
-- Bug 3357807 End Here
,tax_update_allowed in out nocopy varchar2
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

procedure update_tax_data
(p_rec              in out nocopy per_qh_tax_query.taxrec
,p_person_id        in     per_all_people_f.person_id%type
,p_assignment_id    in     per_all_assignments_f.assignment_id%type
,p_legislation_code in     varchar2
,p_effective_date   in     date
);

end per_qh_tax_update;

 

/
