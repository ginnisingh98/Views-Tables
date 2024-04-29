--------------------------------------------------------
--  DDL for Package BEN_PERSON_RECORD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BEN_PERSON_RECORD" AUTHID CURRENT_USER AS
/* $Header: benperrec.pkh 120.0.12010000.4 2009/04/10 12:56:22 pvelvano noship $ */

TYPE g_beneficiary_rec_type IS RECORD
(plan_type_name ben_pl_typ_f.name%type
,plan_name ben_pl_f.name%type
,option_name ben_opt_f.name%type
,beneficiary VARCHAR2(400)
,ben_ssn per_all_people_f.national_identifier%type
,ben_relation VARCHAR2(400)
,primary_bnf NUMBER
,contingent_bnf NUMBER
,le_name ben_ler_f.name%type
,ben_full_name per_all_people_f.full_name%type
);

TYPE g_dependent_rec_type IS RECORD
(
   name per_all_people_f.full_name%type,
   relationship VARCHAR2(400),
   type_of_benefit ben_pl_typ_f.name%type,
   coverage VARCHAR2(100)
);

TYPE g_benefits_rec_type IS RECORD
(
       type_of_benefit ben_pl_typ_f.name%type
       ,plan ben_pl_f.name%type
       ,coverage_or_participation ben_opt_f.name%type
);

TYPE g_beneficiary_tab_type IS TABLE OF g_beneficiary_rec_type INDEX BY BINARY_INTEGER;
TYPE g_benefits_tab_type IS TABLE OF g_benefits_rec_type INDEX BY BINARY_INTEGER;
TYPE g_dependent_tab_type IS TABLE OF g_dependent_rec_type INDEX BY BINARY_INTEGER;

/*Complete Ben record structure*/
TYPE ben_record_details  is record
  (
      benefit                    g_benefits_tab_type,
      dependent                  g_dependent_tab_type
  );

-- Procedure to populate the record structure with Person Benefits Data
procedure GET_BEN_DETAILS (p_ben_details in out NOCOPY ben_record_details,
                           p_person_id NUMBER,p_effective_date DATE,
			   p_business_group_id NUMBER);

END BEN_PERSON_RECORD;
--

/
