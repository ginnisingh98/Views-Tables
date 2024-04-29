--------------------------------------------------------
--  DDL for Package Body PER_ZA_WSP_ARCHIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_ZA_WSP_ARCHIVE_PKG" as
/* $Header: perzawspa.pkb 120.1.12010000.2 2009/08/12 11:24:41 rbabla ship $ */
 /*
 +======================================================================+
 | Copyright (c) 2001 Oracle Corporation Redwood Shores, California, USA|
 |                       All rights reserved.                           |
 +======================================================================+
 Package Name         : PER_ZA_WSP_ARCHIVE_PKG
 Package File Name    : perzawspa.pkb
 Description          : This sql script seeds the Package Body that
                        creates the WSP Archive code.

 Change List          : pyzawspa.pkb
 ------------
 Name          Date          Version  Bug     Text
 ------------- ------------- ------- ------- ------------------------------
 A. Mahanty     11-DEC-2006   115.0           First created
 A. Mahanty     19-Feb-2007   115.2           All valid learning interventions
 		    																			for a person are archived as
 																						  completed.
 A. Mahanty     23-Feb-2007   115.3           Modified set_wsp_atr_tables
 A. Mahanty 		06-Jun-2007		115.5	6116743   Moved the setup for the pl/sql
 																							tables and archiving of data for
 																							A2 and B2 to range_cursor
 A. Mahanty     11-Jun-2007   115.6 6121907		range_code modified and
 																		6121877		globals are set in action_creation
 A. Mahanty			12-Jun-2007		115.7           global flag added. Pl/sql table are
 																							reset and populated if not already done.
 R Babla        10-Aug-2009   115.10  8468137 Modified the range_cursor to archive SDL Number
 ========================================================================*/
--
-- Global Variables
--

g_package                constant varchar2(31) := 'per_za_wsp_archive_pkg.';
g_debug                  boolean;

g_sql_range              varchar2(4000);

g_bg_id                  number(30);
g_legal_entity_id        number(30);
g_archive_effective_date date;
g_pactid                 number;

g_cat_flex           pay_user_column_instances_f.value%type := null;
g_cat_segment        pay_user_column_instances_f.value%type := null;

g_plan_year              number(10);

g_wsp_start_date         date;
g_wsp_end_date           date;

g_atr_start_date         date;
g_atr_end_date           date;

g_attribute_category     constant varchar2(100) := 'ZA_WSP_SKILLS_PRIORITIES';
g_wsp_comp_lookup        constant varchar2(40)  := 'ZA_WSP_COMPETENCIES';  -- Not seeded. Only used in this package
g_wsp_lpath_lookup       constant varchar2(40)  := 'ZA_WSP_LEARNING_PATHS';
g_wsp_courses_lookup     constant varchar2(40)  := 'ZA_WSP_COURSES';
g_wsp_cert_lookup        constant varchar2(40)  := 'ZA_WSP_CERTIFICATIONS';
g_atr_lpath_lookup       constant varchar2(40)  := 'ZA_ATR_LEARNING_PATHS';
g_atr_courses_lookup     constant varchar2(40)  := 'ZA_ATR_COURSES';
g_atr_cert_lookup        constant varchar2(40)  := 'ZA_ATR_CERTIFICATIONS';
g_atr_comp_lookup        constant varchar2(40)  := 'ZA_ATR_COMPETENCIES';
g_atr_qual_lookup        constant varchar2(40)  := 'ZA_ATR_QUALIFICATIONS';
g_priority_udt_name      constant varchar2(40)  := 'ZA_WSP_SKILLS_PRIORITIES';

--flags
g_pl_tab_start          varchar2(10) := 'N';
g_pl_tab_end						varchar2(10) := 'N';

type wsp_map_tab is record
   ( id   number
   , Attribute1   number
   , Attribute2   number
   , Attribute3   number
   , Attribute4   number
   , Attribute5   number
   , Attribute6   number
   , Attribute7   number
   , Attribute8   number
   , Attribute9   number
   , Attribute10  number
   , Attribute11  number
   , Attribute12  number
   , Attribute13  number
   , Attribute14  number
   , Attribute15  number
   );
--
type wsp_priority_map_rec is record
  ( skills_priority_id    number --user_row_id
  , skills_priority_name  varchar2(80)
  , trng_event_id         number
  , legal_entity_id       number(15)
  , level_number          number(10)
  , saqa_id               varchar2(150)
  , year                  varchar2(20)
  );
--

type wsp_pri_final_tab_rec is record
  ( skills_priority_id    number --
  , skills_priority_num   number
  , skills_priority_name  varchar2(80)
  , legal_entity_id       number
  , year                  varchar2(20)
  , Level_1               number
  , Level_2               number
  , Level_3               number
  , Level_4               number
  , Level_5               number
  , Level_6               number
  , Level_7               number
  , Level_8               number
  , Unknown               number
  , SAQA_Registered       number
  , Not_Registered        number
  , SAQA_Ids              varchar2(1000)
  );

--
type priority_le_rec  is record
  ( skills_priority_id number
  , legal_entity_id    number
  );
--
type trng_event_priority_rec is record
  (trng_event_id   number
  ,priority_id     number
  ,legal_entity_id number
  );
--
type t_wsp_priority_map_tab is table of wsp_priority_map_rec
          index by binary_integer;
--
type t_wsp_map_tab is table of wsp_map_tab index by varchar2(100);
--
type t_wsp_pri_final_tab is table of wsp_pri_final_tab_rec index by varchar2(30);
--
type t_trng_priority_tab is table of trng_event_priority_rec index by varchar2(100);
--
type skills_priority_num_rec is record
	(skills_priority_num number);

type t_skills_priority_num is table of 	skills_priority_num_rec index by varchar2(50);

--global pl/sql tables for trng events. index by trng event id
g_wsp_courses_tab          t_wsp_map_tab;
g_wsp_l_paths_tab          t_wsp_map_tab;
g_wsp_certifications_tab   t_wsp_map_tab;
g_atr_courses_tab          t_wsp_map_tab;
g_atr_l_paths_tab          t_wsp_map_tab;
g_atr_certifications_tab   t_wsp_map_tab;
g_atr_competences_tab      t_wsp_map_tab;
g_atr_qualifications_tab   t_wsp_map_tab;
--
g_wsp_priority_tab         t_wsp_priority_map_tab;
g_atr_priority_tab         t_wsp_priority_map_tab;
-- for A2 and B2 . index by legal_entity + skills priority id
g_wsp_pri_final_tab        t_wsp_pri_final_tab;
g_atr_pri_final_tab        t_wsp_pri_final_tab;
-- index by Skills priority id + Competence/Course Id
g_wsp_compt_pri_tab        t_trng_priority_tab;
g_wsp_course_pri_tab       t_trng_priority_tab;

g_atr_compt_pri_tab        t_trng_priority_tab;
g_atr_course_pri_tab       t_trng_priority_tab;

g_wsp_index                binary_integer ;
g_atr_index                binary_integer ;
g_wsp_skills_pri_num       number;
g_atr_skills_pri_num       number;
--
g_wsp_skills_priority_num t_skills_priority_num;
g_atr_skills_priority_num t_skills_priority_num;
--
cursor g_csr_le is
select distinct to_number(substr(puc1.user_column_name,1, instr(puc1.user_column_name,'_')-1)) organization_id
  from pay_user_tables  put
     , pay_user_columns puc
     , pay_user_columns puc1
     , pay_user_rows_f  pur
     , pay_user_column_instances_f puci
  where put.user_table_name = g_priority_udt_name
  and   puc.user_table_id = put.user_table_id
  and   pur.user_table_id = put.user_table_id
  and   pur.business_group_id = g_bg_id
  and   puci.user_row_id = pur.user_row_id
  and   puci.user_column_id = puc1.user_column_id;
---

/*--------------------------------------------------------------------------
  Name      : reset_tables
  Purpose   : Reset global tables.
  Arguments : None
--------------------------------------------------------------------------*/
procedure reset_tables is

l_proc constant varchar2(60) := g_package || 'reset_tables';

begin
    hr_utility.set_location('Entering ' || l_proc, 10);
		g_pl_tab_start := 'Y';

    g_wsp_courses_tab.delete;
    g_wsp_l_paths_tab.delete;
    g_wsp_certifications_tab.delete;
    g_atr_courses_tab.delete;
    g_atr_l_paths_tab.delete;
    g_atr_certifications_tab.delete;

    g_atr_competences_tab.delete;
    g_atr_qualifications_tab.delete;

    g_wsp_priority_tab.delete;
    g_atr_priority_tab.delete;

    g_wsp_pri_final_tab.delete;
    g_atr_pri_final_tab.delete;

    g_wsp_index := 0;
    g_atr_index := 0;
    g_wsp_skills_pri_num := 0;
    g_atr_skills_pri_num := 0;

   hr_utility.set_location('Leaving  ' || l_proc, 30);
end reset_tables;
--
/* Procedure to set global tables
   with p_id
   where p_id are course_id, Learning_path_id etc
*/

  Procedure set_wsp_atr_tables
                  ( p_id             varchar2
                  , lookup_type      varchar2
                  , p_effective_date date
                  ) is

  cursor csr_get_priority ( p_lookup_type varchar2
                          , p_year        varchar2) is
    select Attribute1,Attribute2,Attribute3,Attribute4,Attribute5,Attribute6,
           Attribute7,Attribute8,Attribute9,Attribute10, Attribute11,
           Attribute12, Attribute13, Attribute14, Attribute15,
           substr(lookup_code,5) lookup_code
      from  fnd_lookup_values
      where lookup_type = p_lookup_type
      and   lookup_code like p_year || '%'
      and   security_group_id = fnd_global.lookup_security_group(p_lookup_type,3)
      and   attribute_category = G_ATTRIBUTE_CATEGORY
      and (
           Attribute1 || Attribute2 || Attribute3 || Attribute4  || Attribute5  ||
           Attribute6 || Attribute7 || Attribute8 || Attribute9  || Attribute10 ||
           Attribute11|| Attribute12|| Attribute13|| Attribute14 || Attribute15
          ) is not null;

        l_index          varchar2(30);
        l_proc  constant varchar2(60) := g_package || 'set_wsp_atr_tables';
   begin
          hr_utility.trace('Entering ' || l_proc);
          l_index := p_id;
          if lookup_type = g_wsp_courses_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_wsp_courses_tab(l_index).id          := p_id;
              g_wsp_courses_tab(l_index).Attribute1  := rec_get_priority.Attribute1   ;
              g_wsp_courses_tab(l_index).Attribute2  := rec_get_priority.Attribute2   ;
              g_wsp_courses_tab(l_index).Attribute3  := rec_get_priority.Attribute3   ;
              g_wsp_courses_tab(l_index).Attribute4  := rec_get_priority.Attribute4   ;
              g_wsp_courses_tab(l_index).Attribute5  := rec_get_priority.Attribute5   ;
              g_wsp_courses_tab(l_index).Attribute6  := rec_get_priority.Attribute6   ;
              g_wsp_courses_tab(l_index).Attribute7  := rec_get_priority.Attribute7   ;
              g_wsp_courses_tab(l_index).Attribute8  := rec_get_priority.Attribute8   ;
              g_wsp_courses_tab(l_index).Attribute9  := rec_get_priority.Attribute9   ;
              g_wsp_courses_tab(l_index).Attribute10 := rec_get_priority.Attribute10  ;
              g_wsp_courses_tab(l_index).Attribute11 := rec_get_priority.Attribute11  ;
              g_wsp_courses_tab(l_index).Attribute12 := rec_get_priority.Attribute12  ;
              g_wsp_courses_tab(l_index).Attribute13 := rec_get_priority.Attribute13  ;
              g_wsp_courses_tab(l_index).Attribute14 := rec_get_priority.Attribute14  ;
              g_wsp_courses_tab(l_index).Attribute15 := rec_get_priority.Attribute15  ;
            end loop;
            hr_utility.set_location('g_wsp_courses_tab.count : '||g_wsp_courses_tab.count,10);
          elsif lookup_type = g_wsp_lpath_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_wsp_l_paths_tab(l_index).id          := p_id;
              g_wsp_l_paths_tab(l_index).Attribute1  := rec_get_priority.Attribute1   ;
              g_wsp_l_paths_tab(l_index).Attribute2  := rec_get_priority.Attribute2   ;
              g_wsp_l_paths_tab(l_index).Attribute3  := rec_get_priority.Attribute3   ;
              g_wsp_l_paths_tab(l_index).Attribute4  := rec_get_priority.Attribute4   ;
              g_wsp_l_paths_tab(l_index).Attribute5  := rec_get_priority.Attribute5   ;
              g_wsp_l_paths_tab(l_index).Attribute6  := rec_get_priority.Attribute6   ;
              g_wsp_l_paths_tab(l_index).Attribute7  := rec_get_priority.Attribute7   ;
              g_wsp_l_paths_tab(l_index).Attribute8  := rec_get_priority.Attribute8   ;
              g_wsp_l_paths_tab(l_index).Attribute9  := rec_get_priority.Attribute9   ;
              g_wsp_l_paths_tab(l_index).Attribute10 := rec_get_priority.Attribute10  ;
              g_wsp_l_paths_tab(l_index).Attribute11 := rec_get_priority.Attribute11  ;
              g_wsp_l_paths_tab(l_index).Attribute12 := rec_get_priority.Attribute12  ;
              g_wsp_l_paths_tab(l_index).Attribute13 := rec_get_priority.Attribute13  ;
              g_wsp_l_paths_tab(l_index).Attribute14 := rec_get_priority.Attribute14  ;
              g_wsp_l_paths_tab(l_index).Attribute15 := rec_get_priority.Attribute15  ;
            end loop;
            hr_utility.set_location('g_wsp_l_paths_tab.count : '||g_wsp_l_paths_tab.count,10);
          elsif lookup_type = g_wsp_cert_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_wsp_certifications_tab(l_index).id          := p_id;
              g_wsp_certifications_tab(l_index).Attribute1  := rec_get_priority.Attribute1  ;
              g_wsp_certifications_tab(l_index).Attribute2  := rec_get_priority.Attribute2   ;
              g_wsp_certifications_tab(l_index).Attribute3  := rec_get_priority.Attribute3   ;
              g_wsp_certifications_tab(l_index).Attribute4  := rec_get_priority.Attribute4   ;
              g_wsp_certifications_tab(l_index).Attribute5  := rec_get_priority.Attribute5   ;
              g_wsp_certifications_tab(l_index).Attribute6  := rec_get_priority.Attribute6   ;
              g_wsp_certifications_tab(l_index).Attribute7  := rec_get_priority.Attribute7   ;
              g_wsp_certifications_tab(l_index).Attribute8  := rec_get_priority.Attribute8   ;
              g_wsp_certifications_tab(l_index).Attribute9  := rec_get_priority.Attribute9   ;
              g_wsp_certifications_tab(l_index).Attribute10 := rec_get_priority.Attribute10  ;
              g_wsp_certifications_tab(l_index).Attribute11 := rec_get_priority.Attribute11  ;
              g_wsp_certifications_tab(l_index).Attribute12 := rec_get_priority.Attribute12  ;
              g_wsp_certifications_tab(l_index).Attribute13 := rec_get_priority.Attribute13  ;
              g_wsp_certifications_tab(l_index).Attribute14 := rec_get_priority.Attribute14  ;
              g_wsp_certifications_tab(l_index).Attribute15 := rec_get_priority.Attribute15  ;
            end loop;
            hr_utility.set_location('g_wsp_certifications_tab.count : '||g_wsp_certifications_tab.count,10);
          /*  -- Not being used anymore
          elsif lookup_type = g_atr_courses_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_atr_courses_tab(l_index).id := p_id;
              g_atr_courses_tab(l_index).Attribute1  := rec_get_priority.Attribute1   ;
              g_atr_courses_tab(l_index).Attribute2  := rec_get_priority.Attribute2   ;
              g_atr_courses_tab(l_index).Attribute3  := rec_get_priority.Attribute3   ;
              g_atr_courses_tab(l_index).Attribute4  := rec_get_priority.Attribute4   ;
              g_atr_courses_tab(l_index).Attribute5  := rec_get_priority.Attribute5   ;
              g_atr_courses_tab(l_index).Attribute6  := rec_get_priority.Attribute6   ;
              g_atr_courses_tab(l_index).Attribute7  := rec_get_priority.Attribute7   ;
              g_atr_courses_tab(l_index).Attribute8  := rec_get_priority.Attribute8   ;
              g_atr_courses_tab(l_index).Attribute9  := rec_get_priority.Attribute9   ;
              g_atr_courses_tab(l_index).Attribute10 := rec_get_priority.Attribute10  ;
              g_atr_courses_tab(l_index).Attribute11 := rec_get_priority.Attribute11  ;
              g_atr_courses_tab(l_index).Attribute12 := rec_get_priority.Attribute12  ;
              g_atr_courses_tab(l_index).Attribute13 := rec_get_priority.Attribute13  ;
              g_atr_courses_tab(l_index).Attribute14 := rec_get_priority.Attribute14  ;
              g_atr_courses_tab(l_index).Attribute15 := rec_get_priority.Attribute15  ;
            end loop;
          */
          elsif lookup_type = g_atr_lpath_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_atr_l_paths_tab(l_index).id          := p_id;
              g_atr_l_paths_tab(l_index).Attribute1  := rec_get_priority.Attribute1 ;
              g_atr_l_paths_tab(l_index).Attribute2  := rec_get_priority.Attribute2 ;
              g_atr_l_paths_tab(l_index).Attribute3  := rec_get_priority.Attribute3 ;
              g_atr_l_paths_tab(l_index).Attribute4  := rec_get_priority.Attribute4 ;
              g_atr_l_paths_tab(l_index).Attribute5  := rec_get_priority.Attribute5 ;
              g_atr_l_paths_tab(l_index).Attribute6  := rec_get_priority.Attribute6 ;
              g_atr_l_paths_tab(l_index).Attribute7  := rec_get_priority.Attribute7 ;
              g_atr_l_paths_tab(l_index).Attribute8  := rec_get_priority.Attribute8 ;
              g_atr_l_paths_tab(l_index).Attribute9  := rec_get_priority.Attribute9 ;
              g_atr_l_paths_tab(l_index).Attribute10 := rec_get_priority.Attribute10;
              g_atr_l_paths_tab(l_index).Attribute11 := rec_get_priority.Attribute11;
              g_atr_l_paths_tab(l_index).Attribute12 := rec_get_priority.Attribute12;
              g_atr_l_paths_tab(l_index).Attribute13 := rec_get_priority.Attribute13;
              g_atr_l_paths_tab(l_index).Attribute14 := rec_get_priority.Attribute14;
              g_atr_l_paths_tab(l_index).Attribute15 := rec_get_priority.Attribute15;
            end loop;
            hr_utility.set_location('g_atr_l_paths_tab.count : '||g_atr_l_paths_tab.count,10);
          elsif lookup_type = g_atr_cert_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_atr_certifications_tab(l_index).id          := p_id;
              g_atr_certifications_tab(l_index).Attribute1  := rec_get_priority.Attribute1 ;
              g_atr_certifications_tab(l_index).Attribute2  := rec_get_priority.Attribute2 ;
              g_atr_certifications_tab(l_index).Attribute3  := rec_get_priority.Attribute3 ;
              g_atr_certifications_tab(l_index).Attribute4  := rec_get_priority.Attribute4 ;
              g_atr_certifications_tab(l_index).Attribute5  := rec_get_priority.Attribute5 ;
              g_atr_certifications_tab(l_index).Attribute6  := rec_get_priority.Attribute6 ;
              g_atr_certifications_tab(l_index).Attribute7  := rec_get_priority.Attribute7 ;
              g_atr_certifications_tab(l_index).Attribute8  := rec_get_priority.Attribute8 ;
              g_atr_certifications_tab(l_index).Attribute9  := rec_get_priority.Attribute9 ;
              g_atr_certifications_tab(l_index).Attribute10 := rec_get_priority.Attribute10;
              g_atr_certifications_tab(l_index).Attribute11 := rec_get_priority.Attribute11;
              g_atr_certifications_tab(l_index).Attribute12 := rec_get_priority.Attribute12;
              g_atr_certifications_tab(l_index).Attribute13 := rec_get_priority.Attribute13;
              g_atr_certifications_tab(l_index).Attribute14 := rec_get_priority.Attribute14;
              g_atr_certifications_tab(l_index).Attribute15 := rec_get_priority.Attribute15;
            end loop;
            hr_utility.set_location('g_atr_certifications_tab.count : '||g_atr_certifications_tab.count,10);
          /* --Not being used anymore
          elsif lookup_type = g_atr_comp_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_atr_competences_tab(l_index).id          := p_id;
              g_atr_competences_tab(l_index).Attribute1  := rec_get_priority.Attribute1   ;
              g_atr_competences_tab(l_index).Attribute2  := rec_get_priority.Attribute2   ;
              g_atr_competences_tab(l_index).Attribute3  := rec_get_priority.Attribute3   ;
              g_atr_competences_tab(l_index).Attribute4  := rec_get_priority.Attribute4   ;
              g_atr_competences_tab(l_index).Attribute5  := rec_get_priority.Attribute5   ;
              g_atr_competences_tab(l_index).Attribute6  := rec_get_priority.Attribute6   ;
              g_atr_competences_tab(l_index).Attribute7  := rec_get_priority.Attribute7   ;
              g_atr_competences_tab(l_index).Attribute8  := rec_get_priority.Attribute8   ;
              g_atr_competences_tab(l_index).Attribute9  := rec_get_priority.Attribute9   ;
              g_atr_competences_tab(l_index).Attribute10 := rec_get_priority.Attribute10  ;
              g_atr_competences_tab(l_index).Attribute11 := rec_get_priority.Attribute11  ;
              g_atr_competences_tab(l_index).Attribute12 := rec_get_priority.Attribute12  ;
              g_atr_competences_tab(l_index).Attribute13 := rec_get_priority.Attribute13  ;
              g_atr_competences_tab(l_index).Attribute14 := rec_get_priority.Attribute14  ;
              g_atr_competences_tab(l_index).Attribute15 := rec_get_priority.Attribute15  ;
            end loop;
          */
          elsif lookup_type = g_atr_qual_lookup then
            for rec_get_priority in csr_get_priority(lookup_type, to_char(p_effective_date,'YYYY')) -- chk again
              loop
              g_atr_qualifications_tab(l_index).id          := p_id;
              g_atr_qualifications_tab(l_index).Attribute1  := rec_get_priority.Attribute1  ;
              g_atr_qualifications_tab(l_index).Attribute2  := rec_get_priority.Attribute2   ;
              g_atr_qualifications_tab(l_index).Attribute3  := rec_get_priority.Attribute3   ;
              g_atr_qualifications_tab(l_index).Attribute4  := rec_get_priority.Attribute4   ;
              g_atr_qualifications_tab(l_index).Attribute5  := rec_get_priority.Attribute5   ;
              g_atr_qualifications_tab(l_index).Attribute6  := rec_get_priority.Attribute6   ;
              g_atr_qualifications_tab(l_index).Attribute7  := rec_get_priority.Attribute7   ;
              g_atr_qualifications_tab(l_index).Attribute8  := rec_get_priority.Attribute8   ;
              g_atr_qualifications_tab(l_index).Attribute9  := rec_get_priority.Attribute9   ;
              g_atr_qualifications_tab(l_index).Attribute10 := rec_get_priority.Attribute10  ;
              g_atr_qualifications_tab(l_index).Attribute11 := rec_get_priority.Attribute11  ;
              g_atr_qualifications_tab(l_index).Attribute12 := rec_get_priority.Attribute12  ;
              g_atr_qualifications_tab(l_index).Attribute13 := rec_get_priority.Attribute13  ;
              g_atr_qualifications_tab(l_index).Attribute14 := rec_get_priority.Attribute14  ;
              g_atr_qualifications_tab(l_index).Attribute15 := rec_get_priority.Attribute15  ;
            end loop;
            hr_utility.set_location('g_atr_qualifications_tab.count : '||g_atr_qualifications_tab.count,10);
          end if;
          hr_utility.trace('Leaving  ' || l_proc);
end set_wsp_atr_tables;
--
/*--------------------------------------------------------------------------
  Name      : set_wsp_atr_pri_tabs
  Purpose   : Procedure to set global tables for the skills priorities and
              training events, their level and SAQA ID.
--------------------------------------------------------------------------*/

Procedure set_wsp_atr_pri_tabs
                  ( p_user_row_id        number
                  , p_trng_event_id      varchar2
                  , p_lookup_type        varchar2
                  , p_effective_date     date
                  ) is

  cursor csr_get_pri_name(p_csr_user_row_id number) is
  select  row_low_range_or_name   --, effective_start_date, effective_end_date
    from  pay_user_rows_f
    where user_row_id = p_csr_user_row_id
    and   p_effective_date between effective_start_date and effective_end_date;

  cursor csr_get_legal_entity (p_csr_user_row_id number) is
  select distinct substr(puc.user_column_name,1, instr(puc.user_column_name,'_')-1) organization_id
    from pay_user_column_instances_f puci
       , pay_user_columns_tl puc
    where puci.user_row_id = p_csr_user_row_id
    and   puc.user_column_id = puci.user_column_id
    and   p_effective_date between puci.effective_start_date and puci.effective_end_date;

  cursor csr_get_comp_info(p_csr_trng_event_id  number) is
    select level_number, unit_standard_id  --saqa_id
    from   per_competences
    where  competence_id = p_csr_trng_event_id;

  cursor csr_get_qual_info(p_csr_trng_event_id  number) is
    select level_number, qual_framework_id  --saqa_id
    from   per_qualification_types
    where  qualification_type_id   = p_csr_trng_event_id;
--variables
l_skills_priority_id   number;
l_skills_priority_name varchar2(80);
l_level_num            number;
l_saqa_id              varchar2(150);
l_year                 varchar2(20);
l_index                varchar2(30);
l_proc      constant   varchar2(60) := g_package || 'set_wsp_atr_pri_tabs';
l_pri_index            varchar2(60);
--
l_count              number;
--
begin
  hr_utility.trace('Entering ' || l_proc);

  if p_user_row_id is not null then
     open csr_get_pri_name(p_user_row_id);
     fetch csr_get_pri_name into l_skills_priority_name;
     close csr_get_pri_name;

     if (p_lookup_type = g_atr_comp_lookup OR p_lookup_type = g_wsp_comp_lookup) then
        open csr_get_comp_info(p_trng_event_id);
        fetch csr_get_comp_info into l_level_num, l_saqa_id;
        close csr_get_comp_info;
     elsif p_lookup_type  = g_atr_qual_lookup then
        open csr_get_qual_info(p_trng_event_id);
        fetch csr_get_qual_info into l_level_num, l_saqa_id;
        close csr_get_qual_info;
     end if;
  end if;
  hr_utility.set_location('p_user_row_id   '||p_user_row_id   ,10);
  hr_utility.set_location('p_trng_event_id '||p_trng_event_id ,10);
  hr_utility.set_location('p_lookup_type   '||p_lookup_type   ,10);
  hr_utility.set_location('p_effective_date'||to_char(p_effective_date,'DD-MM-YYYY') ,10);
  hr_utility.set_location('l_skills_priority_name'||l_skills_priority_name,10);


  if (p_user_row_id is not null AND instr(p_lookup_type,'WSP') > 0) then
    -- For the Planned Training Event and Priority Map . To stop duplication
    if p_lookup_type = g_wsp_comp_lookup then
      l_pri_index := p_user_row_id ||'_' || p_trng_event_id;
      if NOT g_wsp_compt_pri_tab.exists(l_pri_index) then
      g_wsp_compt_pri_tab(l_pri_index).trng_event_id := p_trng_event_id;
      g_wsp_compt_pri_tab(l_pri_index).priority_id := p_user_row_id;
      end if;
    elsif p_lookup_type = g_wsp_courses_lookup then
      l_pri_index := p_user_row_id ||'_' || p_trng_event_id;
      if NOT g_wsp_compt_pri_tab.exists(l_pri_index) then
      g_wsp_course_pri_tab(l_pri_index).trng_event_id := p_trng_event_id;
      g_wsp_course_pri_tab(l_pri_index).priority_id := p_user_row_id;
      end if;
    end if;
    hr_utility.set_location('g_wsp_compt_pri_tab.count:  '||g_wsp_compt_pri_tab.count,10);
    hr_utility.set_location('g_wsp_course_pri_tab.count: '||g_wsp_course_pri_tab.count,10);
    --
    for rec_legal_entity in csr_get_legal_entity(p_user_row_id)
      loop
          hr_utility.set_location('Entering rec_legal_entity',20);
          g_wsp_index := g_wsp_index + 1;
          g_wsp_priority_tab(g_wsp_index).skills_priority_id   := p_user_row_id;
          g_wsp_priority_tab(g_wsp_index).skills_priority_name := l_skills_priority_name;
          g_wsp_priority_tab(g_wsp_index).trng_event_id        := p_trng_event_id;
          g_wsp_priority_tab(g_wsp_index).legal_entity_id      := fnd_number.canonical_to_number(rec_legal_entity.organization_id);
          g_wsp_priority_tab(g_wsp_index).level_number         := l_level_num;
          g_wsp_priority_tab(g_wsp_index).saqa_id              := l_saqa_id;
          g_wsp_priority_tab(g_wsp_index).year                 := to_char(p_effective_date,'YYYY');

          --
          hr_utility.set_location(' level_number:           '||l_level_num,20);
          hr_utility.set_location(' l_saqa_id:              '||l_saqa_id,20);
          hr_utility.set_location(' year     :              '||to_char(p_effective_date,'YYYY'),20);
      end loop;
    for rec_legal_entity2 in csr_get_legal_entity(p_user_row_id)
      loop
          hr_utility.set_location('Entering rec_legal_entity2',20);
          l_index := rpad(rec_legal_entity2.organization_id,15,0) || p_user_row_id;
          hr_utility.set_location('l_index '||l_index,20);
          if g_wsp_pri_final_tab.exists(l_index) then
            hr_utility.set_location('Record exists',20);
          else
            hr_utility.set_location('New Record in g_wsp_pri_final_tab',20);
            --g_wsp_skills_pri_num := g_wsp_skills_pri_num + 1;
            if g_wsp_skills_priority_num.exists(fnd_number.canonical_to_number(rec_legal_entity2.organization_id)) then
            g_wsp_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity2.organization_id)).skills_priority_num := g_wsp_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity2.organization_id)).skills_priority_num + 1;
          	else
          	g_wsp_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity2.organization_id)).skills_priority_num := 1;
          	end if;

            g_wsp_pri_final_tab(l_index).legal_entity_id      := fnd_number.canonical_to_number(rec_legal_entity2.organization_id);
            g_wsp_pri_final_tab(l_index).skills_priority_id   := p_user_row_id;
            g_wsp_pri_final_tab(l_index).skills_priority_num  := g_wsp_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity2.organization_id)).skills_priority_num;
            g_wsp_pri_final_tab(l_index).skills_priority_name := l_skills_priority_name;
            g_wsp_pri_final_tab(l_index).year                 := to_char(p_effective_date,'YYYY');
            g_wsp_pri_final_tab(l_index).Level_1              := 0;
            g_wsp_pri_final_tab(l_index).Level_2              := 0;
            g_wsp_pri_final_tab(l_index).Level_3              := 0;
            g_wsp_pri_final_tab(l_index).Level_4              := 0;
            g_wsp_pri_final_tab(l_index).Level_5              := 0;
            g_wsp_pri_final_tab(l_index).Level_6              := 0;
            g_wsp_pri_final_tab(l_index).Level_7              := 0;
            g_wsp_pri_final_tab(l_index).Level_8              := 0;
            g_wsp_pri_final_tab(l_index).Unknown              := 0;
            g_wsp_pri_final_tab(l_index).SAQA_Registered      := 0;
            g_wsp_pri_final_tab(l_index).Not_Registered       := 0;
          --
          hr_utility.set_location(' skills_priority_num : '||g_wsp_skills_pri_num,20) ;
          hr_utility.set_location(' skills_priority_name: '||l_skills_priority_name,20);
          hr_utility.set_location(' l_index                : '||l_index,20);
          hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id : '||g_wsp_pri_final_tab(l_index).legal_entity_id,20);
          hr_utility.set_location('rec_legal_entity2.organization_id: '||fnd_number.canonical_to_number(rec_legal_entity2.organization_id),20);
          --
          end if;
      end loop;
   elsif (p_user_row_id is not null AND instr(p_lookup_type,'ATR') > 0) then

    -- For the Completed Training Event and Priority Map . To stop duplication
    if p_lookup_type = g_atr_comp_lookup then
      l_pri_index := p_user_row_id ||'_' || p_trng_event_id;
      if NOT g_atr_compt_pri_tab.exists(l_pri_index) then
      g_atr_compt_pri_tab(l_pri_index).trng_event_id := p_trng_event_id;
      g_atr_compt_pri_tab(l_pri_index).priority_id := p_user_row_id;
      end if;
    elsif p_lookup_type = g_atr_courses_lookup then
      l_pri_index := p_user_row_id ||'_' || p_trng_event_id;
      if NOT g_atr_course_pri_tab.exists(l_pri_index) then
      g_atr_course_pri_tab(l_pri_index).trng_event_id := p_trng_event_id;
      g_atr_course_pri_tab(l_pri_index).priority_id := p_user_row_id;
      end if;
    end if;
    hr_utility.set_location('g_atr_compt_pri_tab.count : '||g_atr_compt_pri_tab.count,30);
    hr_utility.set_location('g_atr_course_pri_tab.count : '||g_atr_course_pri_tab.count,30);
    --
    for rec_legal_entity in csr_get_legal_entity(p_user_row_id)
      loop
          hr_utility.set_location('Entering rec_legal_entity',30);
          g_atr_index := g_atr_index + 1;
          g_atr_priority_tab(g_atr_index).skills_priority_id    := p_user_row_id;
          g_atr_priority_tab(g_atr_index).skills_priority_name  := l_skills_priority_name;
          g_atr_priority_tab(g_atr_index).trng_event_id         := p_trng_event_id;
          g_atr_priority_tab(g_atr_index).legal_entity_id       := rec_legal_entity.organization_id;
          g_atr_priority_tab(g_atr_index).level_number          := l_level_num;
          g_atr_priority_tab(g_atr_index).saqa_id               := l_saqa_id;
          g_atr_priority_tab(g_atr_index).year                  := to_char(p_effective_date,'YYYY');
          hr_utility.set_location('Checking',30);
          hr_utility.set_location('skills_priority_id: '||p_user_row_id,30);
          hr_utility.set_location('trng_event_id: '||p_trng_event_id,30);
          hr_utility.set_location('legal_entity_id: '||rec_legal_entity.organization_id,30);
      end loop;
    for rec_legal_entity3 in csr_get_legal_entity(p_user_row_id)
      loop
          l_index := rpad(rec_legal_entity3.organization_id,15,0) || p_user_row_id;
          hr_utility.set_location('Entering rec_legal_entity3-l_index: '||l_index,30);
          if g_atr_pri_final_tab.exists(l_index) then
            hr_utility.set_location('record exists',30);
          else
            hr_utility.set_location('New Record in g_atr_pri_final_tab',30);
            --g_atr_skills_pri_num := g_atr_skills_pri_num + 1;
            if g_atr_skills_priority_num.exists(fnd_number.canonical_to_number(rec_legal_entity3.organization_id)) then
            g_atr_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity3.organization_id)).skills_priority_num := g_atr_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity3.organization_id)).skills_priority_num + 1;
          	else
          	g_atr_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity3.organization_id)).skills_priority_num := 1;
          	end if;
            g_atr_pri_final_tab(l_index).legal_entity_id      := fnd_number.canonical_to_number(rec_legal_entity3.organization_id);
            g_atr_pri_final_tab(l_index).skills_priority_id   := p_user_row_id;
            g_atr_pri_final_tab(l_index).skills_priority_num  := g_atr_skills_priority_num(fnd_number.canonical_to_number(rec_legal_entity3.organization_id)).skills_priority_num;
            g_atr_pri_final_tab(l_index).skills_priority_name := l_skills_priority_name;
            g_atr_pri_final_tab(l_index).year                 := to_char(p_effective_date,'YYYY');
            g_atr_pri_final_tab(l_index).Level_1              := 0;
            g_atr_pri_final_tab(l_index).Level_2              := 0;
            g_atr_pri_final_tab(l_index).Level_3              := 0;
            g_atr_pri_final_tab(l_index).Level_4              := 0;
            g_atr_pri_final_tab(l_index).Level_5              := 0;
            g_atr_pri_final_tab(l_index).Level_6              := 0;
            g_atr_pri_final_tab(l_index).Level_7              := 0;
            g_atr_pri_final_tab(l_index).Level_8              := 0;
            g_atr_pri_final_tab(l_index).Unknown              := 0;
            g_atr_pri_final_tab(l_index).SAQA_Registered      := 0;
            g_atr_pri_final_tab(l_index).Not_Registered       := 0;
          --
          hr_utility.set_location(' skills_priority_num :  '||g_atr_skills_pri_num ,30) ;
          hr_utility.set_location(' skills_priority_name:  '||l_skills_priority_name,30);
          hr_utility.set_location(' year                :  '||to_char(p_effective_date,'YYYY'),30);

          end if;
      end loop;
   end if;


hr_utility.set_location('Leaving  ' || l_proc, 30);
end set_wsp_atr_pri_tabs;

/*--------------------------------------------------------------------------
  Name      : set_wsp_atr_final_tabs
  Purpose   : Procedure to set global tables for the A2 and B2 Sections
--------------------------------------------------------------------------*/
Procedure set_wsp_atr_final_tabs  is
--variables
l_skills_pri_id varchar2(30);
l_proc constant varchar2(60) := g_package || 'set_wsp_atr_final_tabs';
l_count         number;
l_index         varchar2(100);
begin

hr_utility.trace('Entering  ' || l_proc);
hr_utility.set_location('g_wsp_pri_final_tab.COUNT : '||g_wsp_pri_final_tab.COUNT,10);
hr_utility.set_location('g_wsp_pri_final_tab.FIRST : '||g_wsp_pri_final_tab.FIRST,10);
-- WSP tables
l_count := g_wsp_pri_final_tab.COUNT;

--AM
l_count := g_wsp_pri_final_tab.COUNT;
if l_count > 0 then
l_index := g_wsp_pri_final_tab.FIRST;
WHILE l_index IS NOT NULL
	LOOP
   	hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id			'||g_wsp_pri_final_tab(l_index).legal_entity_id,40);
  	hr_utility.set_location('skills_priority_name'||g_wsp_pri_final_tab(l_index).skills_priority_name,40);
  	hr_utility.set_location('year								'||g_wsp_pri_final_tab(l_index).year,40);
  	hr_utility.set_location('set_wsp_atr_final_tabs: l_index:' ||l_index,40);
  	l_index := g_wsp_pri_final_tab.NEXT(l_index);  -- get subscript of next element
	END LOOP;
end if;
--AM

if l_count > 0 then
  l_index := g_wsp_pri_final_tab.FIRST;
for i in 1..l_count
  loop
    select substr(l_index,16,15) into l_skills_pri_id from dual;

    hr_utility.set_location('l_skills_pri_id  ' || l_skills_pri_id, 10);
    --
    for j in g_wsp_priority_tab.FIRST..g_wsp_priority_tab.LAST
      loop
        hr_utility.set_location('Step 1', 10);
        if (l_skills_pri_id = g_wsp_priority_tab(j).skills_priority_id
            and g_wsp_pri_final_tab(l_index).legal_entity_id = g_wsp_priority_tab(j).legal_entity_id) then
          hr_utility.set_location('Inside Loop :'||j,10);
          if g_wsp_priority_tab(j).level_number is null then
            g_wsp_pri_final_tab(l_index).Unknown := g_wsp_pri_final_tab(l_index).Unknown + 1;
          else
          CASE g_wsp_priority_tab(j).level_number
          WHEN '1' THEN g_wsp_pri_final_tab(l_index).Level_1 := g_wsp_pri_final_tab(l_index).Level_1 + 1;
          WHEN '2' THEN g_wsp_pri_final_tab(l_index).Level_2 := g_wsp_pri_final_tab(l_index).Level_2 + 1;
          WHEN '3' THEN g_wsp_pri_final_tab(l_index).Level_3 := g_wsp_pri_final_tab(l_index).Level_3 + 1;
          WHEN '4' THEN g_wsp_pri_final_tab(l_index).Level_4 := g_wsp_pri_final_tab(l_index).Level_4 + 1;
          WHEN '5' THEN g_wsp_pri_final_tab(l_index).Level_5 := g_wsp_pri_final_tab(l_index).Level_5 + 1;
          WHEN '6' THEN g_wsp_pri_final_tab(l_index).Level_6 := g_wsp_pri_final_tab(l_index).Level_6 + 1;
          WHEN '7' THEN g_wsp_pri_final_tab(l_index).Level_7 := g_wsp_pri_final_tab(l_index).Level_7 + 1;
          WHEN '8' THEN g_wsp_pri_final_tab(l_index).Level_8 := g_wsp_pri_final_tab(l_index).Level_8 + 1;
          END CASE;
          end if;
          hr_utility.set_location('g_wsp_pri_final_tab(l_index).Unknown: '||g_wsp_pri_final_tab(l_index).Unknown,20);
          if g_wsp_priority_tab(j).saqa_id is not null then
            g_wsp_pri_final_tab(l_index).SAQA_Registered := g_wsp_pri_final_tab(l_index).SAQA_Registered + 1;
            if g_wsp_pri_final_tab(l_index).SAQA_Ids is not null then
            g_wsp_pri_final_tab(l_index).SAQA_Ids := g_wsp_pri_final_tab(l_index).SAQA_Ids || ','
                                        || g_wsp_priority_tab(j).saqa_id;
            else -- for first saqa id
            g_wsp_pri_final_tab(l_index).SAQA_Ids := g_wsp_priority_tab(j).saqa_id;
            end if;
          else
            g_wsp_pri_final_tab(l_index).Not_Registered := g_wsp_pri_final_tab(l_index).Not_Registered + 1;
          end if;
        end if;
      end loop;
        if i < l_count then
        l_index := g_wsp_pri_final_tab.NEXT(l_index);
        end if;
  end loop;
end if;
--ATR tables
hr_utility.set_location('g_atr_pri_final_tab.COUNT : '||g_atr_pri_final_tab.COUNT,20);
hr_utility.set_location('g_atr_pri_final_tab.FIRST : '||g_atr_pri_final_tab.FIRST,20);
hr_utility.set_location('g_atr_pri_final_tab.LAST  : '||g_atr_pri_final_tab.LAST,20);
l_count := g_atr_pri_final_tab.COUNT;
if l_count > 0 then
  l_index := g_atr_pri_final_tab.FIRST;
for i in 1..l_count
  loop
    hr_utility.set_location('Step 0', 20);
    select substr(l_index,16,15) into l_skills_pri_id from dual;
    hr_utility.set_location('l_skills_pri_id  ' || l_skills_pri_id, 20);
    for j in g_atr_priority_tab.FIRST..g_atr_priority_tab.LAST
      loop
        hr_utility.set_location('Step 1: g_atr_priority_tab : '||j, 20);
        if (l_skills_pri_id = g_atr_priority_tab(j).skills_priority_id
            and g_atr_pri_final_tab(l_index).legal_entity_id = g_atr_priority_tab(j).legal_entity_id) then
          if g_atr_priority_tab(j).level_number is null then
            g_atr_pri_final_tab(l_index).Unknown := g_atr_pri_final_tab(l_index).Unknown + 1;
          else
            CASE g_atr_priority_tab(j).level_number
            WHEN '1' THEN g_atr_pri_final_tab(l_index).Level_1 := g_atr_pri_final_tab(l_index).Level_1 + 1;
            WHEN '2' THEN g_atr_pri_final_tab(l_index).Level_2 := g_atr_pri_final_tab(l_index).Level_2 + 1;
            WHEN '3' THEN g_atr_pri_final_tab(l_index).Level_3 := g_atr_pri_final_tab(l_index).Level_3 + 1;
            WHEN '4' THEN g_atr_pri_final_tab(l_index).Level_4 := g_atr_pri_final_tab(l_index).Level_4 + 1;
            WHEN '5' THEN g_atr_pri_final_tab(l_index).Level_5 := g_atr_pri_final_tab(l_index).Level_5 + 1;
            WHEN '6' THEN g_atr_pri_final_tab(l_index).Level_6 := g_atr_pri_final_tab(l_index).Level_6 + 1;
            WHEN '7' THEN g_atr_pri_final_tab(l_index).Level_7 := g_atr_pri_final_tab(l_index).Level_7 + 1;
            WHEN '8' THEN g_atr_pri_final_tab(l_index).Level_8 := g_atr_pri_final_tab(l_index).Level_8 + 1;
            END CASE;
          end if;
          if g_atr_priority_tab(j).saqa_id is not null then
            g_atr_pri_final_tab(l_index).SAQA_Registered := g_atr_pri_final_tab(l_index).SAQA_Registered + 1;
            if g_atr_pri_final_tab(l_index).SAQA_Ids is not null then
            g_atr_pri_final_tab(l_index).SAQA_Ids := g_atr_pri_final_tab(l_index).SAQA_Ids || ','
                                        || g_atr_priority_tab(j).saqa_id;
            else
            g_atr_pri_final_tab(l_index).SAQA_Ids := g_atr_priority_tab(j).saqa_id; -- for first saqa id
            end if;
          else
            hr_utility.set_location('Not Registered '||g_atr_pri_final_tab(l_index).Not_Registered,20);
            g_atr_pri_final_tab(l_index).Not_Registered := g_atr_pri_final_tab(l_index).Not_Registered + 1;
            hr_utility.set_location('Not Registered '||g_atr_pri_final_tab(l_index).Not_Registered,20);
          end if;
        end if;
        hr_utility.set_location('g_atr_pri_final_tab(l_index).Unknown: '||g_atr_pri_final_tab(l_index).Unknown,20);
      end loop;
        if i < l_count then
        l_index := g_atr_pri_final_tab.NEXT(l_index);
        end if;
  end loop;
end if;
-- start For debug only
hr_utility.trace('Print all WSP Competences and Priority Combinations');
l_index := g_wsp_compt_pri_tab.first;
WHILE l_index IS NOT NULL LOOP
   hr_utility.set_location(l_index,30);
   l_index := g_wsp_compt_pri_tab.NEXT(l_index);
END LOOP;
--
hr_utility.trace('Print all ATR Competences and Priority Combinations');
l_index := g_atr_compt_pri_tab.first;
WHILE l_index IS NOT NULL LOOP
   hr_utility.set_location(l_index,30);
   l_index := g_atr_compt_pri_tab.NEXT(l_index);
END LOOP;
--
hr_utility.trace('Print all WSP Courses and Priority Combinations');
l_index := g_wsp_course_pri_tab.first;
WHILE l_index IS NOT NULL LOOP
   hr_utility.set_location(l_index,30);
   l_index := g_wsp_course_pri_tab.NEXT(l_index);
END LOOP;
--
hr_utility.trace('Print all ATR Courses and Priority Combinations');
l_index := g_atr_course_pri_tab.first;
WHILE l_index IS NOT NULL LOOP
   hr_utility.set_location(l_index,30);
   l_index := g_atr_course_pri_tab.NEXT(l_index);
END LOOP;

-- end For debug only
hr_utility.trace('Leaving  ' || l_proc);

end set_wsp_atr_final_tabs;

/*--------------------------------------------------------------------------
  Procedure to set global_table
      is it called from init
--------------------------------------------------------------------------*/

procedure set_global_tables is

cursor csr_get_priority(p_lookup_type varchar2
                       , p_year       varchar2) is
select Attribute1,Attribute2,Attribute3,Attribute4,Attribute5,Attribute6,
       Attribute7,Attribute8,Attribute9,Attribute10, Attribute11,
       Attribute12, Attribute13, Attribute14, Attribute15,
       substr(lookup_code,5) lookup_code -- trng event id
from  fnd_lookup_values
where lookup_type = p_lookup_type
and   lookup_code like p_year || '%'
and   security_group_id = fnd_global.lookup_security_group(p_lookup_type,3)
and   attribute_category = G_ATTRIBUTE_CATEGORY
and (
      Attribute1 || Attribute2 || Attribute3 || Attribute4  || Attribute5  ||
      Attribute6 || Attribute7 || Attribute8 || Attribute9  || Attribute10 ||
      Attribute11|| Attribute12|| Attribute13|| Attribute14 || Attribute15
     ) is not null;

-- Get the Competences Linked to a Course
cursor csr_get_course_compts(p_course_id number) is
select pce.competence_id
from per_competence_elements pce
where pce.type = 'DELIVERY'
and pce.activity_version_id = p_course_id
and pce.business_group_id = g_bg_id;

-- Get the Competences Linked to a Learning Path
cursor csr_get_lp_compts(p_lp_id number) is
select pce.competence_id
from per_competence_elements pce
where pce.type = 'OTA_LEARNING_PATH'
and pce.object_id = p_lp_id
and pce.business_group_id = g_bg_id;

-- Get the Competences Linked to a Certification
cursor csr_get_cert_compts(p_cert_id number) is
select pce.competence_id
from per_competence_elements pce
where pce.type = 'OTA_CERTIFICATION'
and pce.object_id = p_cert_id
and pce.business_group_id = g_bg_id;

-- Get the Courses Linked to a Learning Path
cursor csr_get_lp_courses(p_learning_path_id number) is
select olpm.activity_version_id
from   ota_learning_paths olp
     , ota_lp_sections    olps
     , ota_learning_path_members olpm
where olp.learning_path_id = p_learning_path_id
and   olp.learning_path_id = olps.learning_path_id
and   olps.learning_path_section_id = olpm.learning_path_section_id;

-- Get the Courses Linked to a Certification
cursor csr_get_cert_courses(p_cert_id number) is
select ocm.object_id
from OTA_CERTIFICATION_MEMBERS ocm
    , OTA_CERTIFICATIONS_B oc
where oc.certification_id = p_cert_id
and ocm.certification_id = oc.certification_id
and ocm.object_type = 'H';
--
-- Exists cursors
--
cursor csr_exists_course_compts(p_course_id number) is
select count(pce.competence_id)
from per_competence_elements pce
where pce.type = 'DELIVERY'
and pce.activity_version_id = p_course_id
and pce.business_group_id = g_bg_id;
--
--
type lookup_table is table of varchar2(80) index by BINARY_INTEGER ;

lookup_list      lookup_table;
--
i                     number;
l_index               varchar2(40);
l_year                number;
l_effective_date      date;
l_proc constant       varchar2(60) := g_package || 'set_global_tables';
l_trng_event_id       number;
l_trng_event_cat      varchar2(80);
l_trng_links_flag     boolean;
l_exists_course_compt number;
--AM
l_count     number;
--AM
begin
hr_utility.trace('Entering '||l_proc );
-- Reset all the pl/sql tables
reset_tables;
--
lookup_list(1):= g_wsp_courses_lookup;
lookup_list(2):= g_wsp_lpath_lookup;
lookup_list(3):= g_wsp_cert_lookup;
lookup_list(4):= g_atr_comp_lookup;
lookup_list(5):= g_atr_qual_lookup;
lookup_list(6):= g_atr_courses_lookup;
lookup_list(7):= g_atr_lpath_lookup;
lookup_list(8):= g_atr_cert_lookup;

for i in 1.. 8
loop
  hr_utility.set_location('Entering loop 1' ,10);
  /* Condition to assign plan year/ trained year */
  if instr(lookup_list(i),'WSP') > 0 then
    l_year := to_char(g_wsp_end_date,'YYYY');
    l_effective_date := g_wsp_end_date;
  elsif instr(lookup_list(i),'ATR') > 0 then
    l_year := to_char(g_atr_end_date,'YYYY');
    l_effective_date := g_atr_end_date;
  else
    l_year := null;
  end if;
  for rec_priority in csr_get_priority
                       (  lookup_list(i)
                       ,  l_year
                       )
  loop
    hr_utility.set_location('Entering rec_priority - lookup_code : '|| rec_priority.lookup_code,10);
    hr_utility.set_location('lookup_list(i) = '|| lookup_list(i),10);
    hr_utility.set_location('l_effective_date = '|| to_char(l_effective_date,'DD-MON-YYYY'),10);
    --
    set_wsp_atr_tables(rec_priority.lookup_code,lookup_list(i),l_effective_date);
  end loop;
  hr_utility.set_location('Exiting loop 1' ,10);
end loop;
--
-- For priorities and trng event mapping ( A2 and B2)
i := 0;
for i in 1.. 8
  loop
    hr_utility.set_location('Entering loop 2' ,20);
    /* Condition to assign plan year/ trained year */
    if instr(lookup_list(i),'WSP') > 0 then
      l_year := to_char(g_wsp_end_date,'YYYY');
      l_effective_date := g_wsp_end_date;
    elsif instr(lookup_list(i),'ATR') > 0 then
      l_year := to_char(g_atr_end_date,'YYYY');
      l_effective_date := g_atr_end_date;
    else
      l_year := null;
    end if;
    for rec_priority in csr_get_priority
                         (  lookup_list(i)
                         ,  l_year
                         )
    loop
    hr_utility.set_location('Entering rec_priority',20);
    l_trng_links_flag := FALSE;
    l_trng_event_id  := rec_priority.lookup_code;
    l_trng_event_cat := lookup_list(i);
    -- can remove these trace statements later
    hr_utility.set_location('Initial l_trng_event_id :  '||l_trng_event_id,20);
    hr_utility.set_location('Initial l_trng_event_cat :  '||l_trng_event_cat,20);
    hr_utility.set_location('Initial rec_priority.Attribute2 :  '||rec_priority.Attribute2,20);

    -- Start: ATR and WSP Courses which have competencies linked to them
    if lookup_list(i) = g_wsp_courses_lookup then
        for rec_get_course_compt in csr_get_course_compts(rec_priority.lookup_code)
          loop
            --set the flag to true
            l_trng_links_flag := TRUE;
            l_trng_event_id  := rec_get_course_compt.competence_id;
            l_trng_event_cat := g_wsp_comp_lookup;
            --
            hr_utility.set_location('Entering WSP rec_get_course_compt :',30);
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
          end loop;
    elsif lookup_list(i) = g_atr_courses_lookup then
        for rec_get_course_compt in csr_get_course_compts(rec_priority.lookup_code)
          loop
            --set the flag to true
            hr_utility.set_location('Entering ATR rec_get_course_compt :',40);
            l_trng_links_flag := TRUE;
            l_trng_event_id  := rec_get_course_compt.competence_id;
            l_trng_event_cat := g_atr_comp_lookup;
            hr_utility.set_location('l_trng_event_id :'||l_trng_event_id,40);
            hr_utility.set_location('rec_priority.Attribute1 :'||rec_priority.Attribute1,40);
            hr_utility.set_location('rec_priority.Attribute2 :'||rec_priority.Attribute2,40);
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                hr_utility.set_location('g_atr_compt_pri_tab.count : '||g_atr_compt_pri_tab.count,401);
                set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                hr_utility.set_location('g_atr_compt_pri_tab.count : '||g_atr_compt_pri_tab.count,402);
                set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
          end loop;
    end if;
    -- End: WSP and ATR Courses which have competencies linked to them
    --
    -- Start: WSP and ATR Learning Paths which have Courses/Competences linked to them
    if lookup_list(i) = g_wsp_lpath_lookup then
        for rec_get_lp_compt in csr_get_lp_compts(rec_priority.lookup_code)
          loop
          hr_utility.set_location('Entering WSP rec_get_lp_compt :',50);
          --set the flag to true
          l_trng_links_flag := TRUE;
          l_trng_event_id  := rec_get_lp_compt.competence_id;
          l_trng_event_cat := g_wsp_comp_lookup;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
          end loop;
      --
      -- loop through each course that is attached to the LP
        for rec_get_lp_courses in csr_get_lp_courses(rec_priority.lookup_code)
          loop
            hr_utility.set_location('Entering WSP rec_get_lp_courses :',50);
            --set the flag to true
            l_trng_links_flag := TRUE;
            --check if the course has any competences linked to it
            l_exists_course_compt := 0;
            open csr_exists_course_compts(rec_get_lp_courses.activity_version_id);
            fetch csr_exists_course_compts into l_exists_course_compt;
            close csr_exists_course_compts;
            --
            if l_exists_course_compt > 0 then
             for rec_get_course_compt in csr_get_course_compts(rec_get_lp_courses.activity_version_id)
              loop
                l_trng_event_id  := rec_get_course_compt.competence_id;
                l_trng_event_cat := g_wsp_comp_lookup;
                --
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
             end loop;
            else
              --Cater for the non-NQF aligned courses which are attached to the LP
             hr_utility.set_location('Entering WSP non-NQF aligned linked to LP :',50);
             l_trng_event_id  := rec_get_lp_courses.activity_version_id;
             l_trng_event_cat := g_wsp_courses_lookup;
             --
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
            end if;
          end loop;
    end if;
    -- WSP part ends : LP
    -- ATR part Starts :LP
    if lookup_list(i) = g_atr_lpath_lookup then
      -- delete the record from lp pl/sql table
      --
        for rec_get_lp_compt in csr_get_lp_compts(rec_priority.lookup_code)
          loop
          hr_utility.set_location('Entering ATR rec_get_lp_compt :',60);
          --set the flag to true
          l_trng_links_flag := TRUE;
          l_trng_event_id  := rec_get_lp_compt.competence_id;
          l_trng_event_cat := g_atr_comp_lookup;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
          end loop;
      --
      -- loop through each course that is attached to the LP
        for rec_get_lp_courses in csr_get_lp_courses(rec_priority.lookup_code)
          loop
            hr_utility.set_location('Entering ATR rec_get_lp_courses :',60);
            --set the flag to true
            l_trng_links_flag := TRUE;
            --check if the course has any competences linked to it
            l_exists_course_compt := 0;
            open csr_exists_course_compts(rec_get_lp_courses.activity_version_id);
            fetch csr_exists_course_compts into l_exists_course_compt;
            close csr_exists_course_compts;
            --
            if l_exists_course_compt > 0 then
             for rec_get_course_compt in csr_get_course_compts(rec_get_lp_courses.activity_version_id)
              loop
                l_trng_event_id  := rec_get_course_compt.competence_id;
                l_trng_event_cat := g_atr_comp_lookup;
                --
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
             end loop;
            else
             --Cater for the non-NQF aligned courses which are attached to the LP
             hr_utility.set_location('Entering ATR non-NQF aligned courses linked to LP :',60);
             l_trng_event_id  := rec_get_lp_courses.activity_version_id;
             l_trng_event_cat := g_atr_courses_lookup;
             --
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
            end if;
          end loop;
      -- remove the lp from the LP pl/sql table
      if l_trng_links_flag = TRUE and g_atr_l_paths_tab.exists(rec_priority.lookup_code) then
        g_atr_l_paths_tab.delete(rec_priority.lookup_code);
      end if;
    end if;
    -- ATR Part ends : LP
    -- End : WSP and ATR Learning Paths which have Courses/Competences linked to them
    --
    -- Start: WSP and ATR Certifications which have Courses/Competences linked to them
    if lookup_list(i) = g_wsp_cert_lookup then
    -- delete the record from lp pl/sql table
    --
        for rec_get_cert_compt in csr_get_cert_compts(rec_priority.lookup_code)
          loop
            hr_utility.set_location('Entering WSP rec_get_cert_compt :',70);
            -- set the flag to true
            l_trng_links_flag := TRUE;
            l_trng_event_id  := rec_get_cert_compt.competence_id;
            l_trng_event_cat := g_wsp_comp_lookup;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
          end loop;  -- end loop for csr_get_cert_compts()
        --
        -- loop through each course that is attached to the Certification
        for rec_get_cert_courses in csr_get_cert_courses(rec_priority.lookup_code)
          loop
            hr_utility.set_location('Entering WSP rec_get_cert_courses :',70);
            -- set the flag to true
            l_trng_links_flag := TRUE;
            --check if the course has any competences linked to it
            l_exists_course_compt := 0;
            open csr_exists_course_compts(rec_get_cert_courses.object_id);
            fetch csr_exists_course_compts into l_exists_course_compt;
            close csr_exists_course_compts;
            --
            if l_exists_course_compt > 0 then
             for rec_get_course_compt in csr_get_course_compts(rec_get_cert_courses.object_id)
              loop
                l_trng_event_id  := rec_get_course_compt.competence_id;
                l_trng_event_cat := g_wsp_comp_lookup;
                --
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
             end loop; -- end loop for csr_get_course_compts()
            else
             --Cater for the non-NQF aligned courses which are attached to the Certification
             hr_utility.set_location('Entering WSP non-NQF aligned courses linked to Cert :',70);
             l_trng_event_id  := rec_get_cert_courses.object_id;
             l_trng_event_cat := g_wsp_courses_lookup;
             --
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_wsp_course_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
            end if;
          end loop; -- end loop for csr_get_cert_courses()
    end if;
    -- WSP part ends : Cert
    -- ATR part Starts : Cert
    if lookup_list(i) = g_atr_cert_lookup then
    -- delete the record from lp pl/sql table
    --
        for rec_get_cert_compt in csr_get_cert_compts(rec_priority.lookup_code)
          loop
            hr_utility.set_location('Entering ATR rec_get_cert_compt :',80);
            -- set the flag to true
            l_trng_links_flag := TRUE;
            l_trng_event_id  := rec_get_cert_compt.competence_id;
            l_trng_event_cat := g_atr_comp_lookup;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
            if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
            end if;
          end loop;  -- end loop for csr_get_cert_compts()
        --
        -- loop through each course that is attached to the Certification
        for rec_get_cert_courses in csr_get_cert_courses(rec_priority.lookup_code)
          loop
            hr_utility.set_location('Entering ATR rec_get_cert_courses :',80);
            -- set the flag to true
            l_trng_links_flag := TRUE;
            --check if the course has any competences linked to it
            l_exists_course_compt := 0;
            open csr_exists_course_compts(rec_get_cert_courses.object_id);
            fetch csr_exists_course_compts into l_exists_course_compt;
            close csr_exists_course_compts;
            --
            if l_exists_course_compt > 0 then
             for rec_get_course_compt in csr_get_course_compts(rec_get_cert_courses.object_id)
              loop
                l_trng_event_id  := rec_get_course_compt.competence_id;
                l_trng_event_cat := g_atr_comp_lookup;
                --
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_compt_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
             end loop; -- end loop for csr_get_course_compts()
            else
             --Cater for the non-NQF aligned courses which are attached to the Certification
             hr_utility.set_location('Entering ATR non-NQF aligned courses linked to Cert :',80);
             l_trng_event_id  := rec_get_cert_courses.object_id;
             l_trng_event_cat := g_atr_courses_lookup;
             --
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute1||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute2||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute3||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute4||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute5||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute6||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute7||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute8||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute9||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute10||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute10 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute11||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute11 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute12||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute12 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute13||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute13 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute14||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute14 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
                if NOT(g_atr_course_pri_tab.exists(rec_priority.Attribute15||'_'||l_trng_event_id)) then
                    set_wsp_atr_pri_tabs(rec_priority.Attribute15 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
                end if;
            end if;
          end loop; -- end loop for csr_get_cert_courses()
        if l_trng_links_flag = TRUE and g_atr_certifications_tab.exists(rec_priority.lookup_code) then
             g_atr_certifications_tab.delete(rec_priority.lookup_code);
        end if;
    end if;
    -- ATR part ends : Cert
    -- End: WSP and ATR Certifications which have Courses/Competences linked to them
    --
    -- caters for all the cases not already covered above
    	 hr_utility.set_location('Before Entering Others ',85);
    	 hr_utility.set_location('lookup_list(i) : '||lookup_list(i) ,85);
       if ( lookup_list(i) = g_atr_comp_lookup OR lookup_list(i) = g_atr_qual_lookup OR l_trng_links_flag = FALSE) then
        --
        hr_utility.set_location('Entering Others ',90);
        hr_utility.set_location('lookup_list(i) : '||lookup_list(i),90);
        --
        set_wsp_atr_pri_tabs(rec_priority.Attribute1 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute2 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute3 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute4 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute5 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute6 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute7 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute8 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute9 ,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute10,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute11,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute12,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute13,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute14,l_trng_event_id,l_trng_event_cat,l_effective_date);
        set_wsp_atr_pri_tabs(rec_priority.Attribute15,l_trng_event_id,l_trng_event_cat,l_effective_date);
       end if;
  end loop;
  hr_utility.set_location('Exiting loop 2' ,20);
end loop;
-- Setup the tables for A2 and B2
set_wsp_atr_final_tabs;
--
g_wsp_courses_tab.delete;
--g_wsp_l_paths_tab.delete;
--g_wsp_certifications_tab.delete;
g_atr_courses_tab.delete;
--g_atr_l_paths_tab.delete;
--g_atr_certifications_tab.delete;
g_atr_competences_tab.delete;
--g_atr_qualifications_tab.delete;
--
g_wsp_priority_tab.delete;
g_atr_priority_tab.delete;

g_pl_tab_end := 'Y';
--
/*
-- debug
l_count := g_wsp_pri_final_tab.COUNT;
if l_count > 0 then
for i in 1..l_count
  loop
  	l_index := g_wsp_pri_final_tab.FIRST;
  	hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id			'||g_wsp_pri_final_tab(l_index).legal_entity_id,40);
  	hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_name'||g_wsp_pri_final_tab(l_index).skills_priority_name,40);
  	hr_utility.set_location('g_wsp_pri_final_tab(l_index).year								'||g_wsp_pri_final_tab(l_index).year,40);
  	if i < l_count then
    	l_index := g_wsp_pri_final_tab.NEXT(l_index);
    end if;
  end loop;
end if;
-- debug
*/
hr_utility.trace('Leaving '||l_proc);
/*exception
  when no_data_found then
      hr_utility.trace('No Data Found: Please Run the Workplace Skills Plan Set Up and Maintenance and do the necessary setup' ||
        to_char(sqlcode));
      hr_utility.raise_error;*/
end set_global_tables;

--
--
/*--------------------------------------------------------------------------
  Name      : get_parameter
  Purpose   : Returns a legislative parameter
  Arguments :
  Notes     : The legislative parameter field must be of the form:
              PARAMETER_NAME=PARAMETER_VALUE. No spaces is allowed in either
              the PARAMETER_NAME or the PARAMETER_VALUE.
--------------------------------------------------------------------------*/
function get_parameter
(
   name        in varchar2,
   parameter_list in varchar2
)  return varchar2 is

start_ptr       number;
end_ptr         number;
token_val       pay_payroll_actions.legislative_parameters%type;
par_value       pay_payroll_actions.legislative_parameters%type;
l_proc constant varchar2(60) := g_package || 'get_parameter';

begin
hr_utility.trace('Entering    '|| l_proc);

token_val := name || '=';

start_ptr := instr(parameter_list, token_val) + length(token_val);
end_ptr   := instr(parameter_list, ' ', start_ptr);

/* if there is no spaces, then use the length of the string */
if end_ptr = 0 then
  end_ptr := length(parameter_list) + 1;
end if;

/* Did we find the token */
if instr(parameter_list, token_val) = 0 then
  par_value := NULL;
else
  par_value := substr(parameter_list, start_ptr, end_ptr - start_ptr);
end if;

return par_value;
hr_utility.trace('Leaving  ' || l_proc);
end get_parameter;

--
/*--------------------------------------------------------------------------
  Name      : range_cursor
  Purpose   : This returns the select statement that is used to created the
              range rows.
  Arguments :
  Notes     : The range cursor determines which people should be processed.
              The normal practice is to include everyone, and then limit
              the list during the assignment action creation.
--------------------------------------------------------------------------*/
procedure range_cursor
(
    pactid in number,
    sqlstr out nocopy varchar2
) is

l_proc             varchar2(100);
l_legal_entity_id  varchar2(60);
l_leg_param        varchar2(1000);
l_tmp_char         varchar2(30);


l_ovn                   number;
l_action_info_id        number;
l_tmp_flag              boolean;
l_seta_name             varchar2(150);
l_sic_code              varchar2(150);


l_index                 varchar(60);
l_count                 number;
l_count_temp number;

--
-- To fetch employer contact details
cursor csr_le_contact_info(p_legal_entity_id in number) is
Select hoi1.org_information1    org_name                  -- A(1).1 Organization Name
     , hoi.org_information4     post_add_line_1           -- A(1).2 Postal Address
     , hoi.org_information5     post_add_line_2
     , hoi.org_information6     post_add_line_3
     , hoi.org_information8     post_town_or_city
     , hoi.org_information7     post_postal_code
     , hoi.org_information9     post_province
     , hoi.org_information10    phy_add_line_1            -- A(1).3 Physical Address
     , hoi.org_information11    phy_add_line_2
     , hoi.org_information12    phy_add_line_3
     , hoi.org_information14    phy_town_or_city
     , hoi.org_information13    phy_postal_code
     , hoi.org_information15    phy_province
     , hoi.org_information1     tel_no                    -- A(1).5 Telephone number
     , hoi.org_information2     fax_no                    -- A(1).6 Fax number
     , hoi.org_information3     email_add                 -- A(1).7 E-mail Address
     , hoi1.org_information12   sdl_no
  From hr_all_organization_units   haou
     , hr_organization_information hoi
     , hr_organization_information hoi1
 Where haou.business_group_id         = g_bg_id
   and haou.organization_id           = p_legal_entity_id
   and haou.organization_id           = hoi1.organization_id
   and hoi.org_information_context(+) = 'ZA_LEGAL_ENTITY_CONTACT_INFO'
   and hoi.organization_id(+)         = haou.organization_id
   and hoi1.org_information_context   = 'ZA_LEGAL_ENTITY';

cursor csr_seta_info(p_legal_entity_id in number) is
select hoi.org_information1     SETA_Name
     , hoi.org_information3     activity_name
from  hr_all_organization_units   haou
    , hr_organization_information hoi
where haou.business_group_id         = g_bg_id
and   haou.organization_id           = p_legal_entity_id
and   haou.organization_id           = hoi.organization_id
and   hoi.org_information_context = 'ZA_NQF_SETA_INFO';
/*
-- To fetch employer banking and other details
cursor csr_le_bank_info is
    Select 'sdl_number'         sdl_num                 -- A(1).4  Skills Development Levy Number
         , 'bank_name'          bank_name               -- A(1).8  Banking details
         , 'bank_add_line_1'    bank_add_line_1
         , 'bank_add_line_2'    bank_add_line_2
         , 'bank_add_line_3'    bank_add_line_3
         , 'bank_town_or_city'  bank_town_or_city
         , 'bank_postal_code'   bank_postal_code
         , 'bank_province'      bank_province
         , 'sic_code'           sic_code                -- A(1).9  Main business activity
         , 'total_employement'  tot_emp                 -- A(1).10 Total Employment
         , 'Tot Ann Payroll'    tot_prev_ann_pay        -- A(1).11 Total prev fin-year annual payroll
      From dual;
*/
-- To fetch SDF details
cursor csr_sdf_info(p_legal_entity_id in number) is
select hoi.org_information1     sdf_name
     , hoi.org_information2     sdf_add_line_1
     , hoi.org_information3     sdf_add_line_2
     , hoi.org_information4     sdf_add_line_3
     , hoi.org_information5     sdf_add_line_4
     , hoi.org_information6     sdf_town_or_city
     , hoi.org_information7     sdf_province
     , hoi.org_information8     sdf_postal_code
     , hoi.org_information9     sdf_telephone_no
     , hoi.org_information10    sdf_fax_no
     , hoi.org_information11    sdf_email_id
     , hoi.org_information12    sdf_mobile_no
from   hr_all_organization_units   haou
     , hr_organization_information hoi
where haou.business_group_id          = g_bg_id
and   haou.organization_id            = p_legal_entity_id
and   haou.organization_id            = hoi.organization_id
and   hoi.org_information_context     = 'ZA_SDF_INFO';
--
begin
--hr_utility.trace_on(null,'ZAWSP');
l_proc := g_package || 'range_cursor';
hr_utility.trace ('Entering '||l_proc);
--
hr_utility.set_location('payroll_action_id = '||pactid,10);
--
-- set the global legislative parameters
Select business_group_id
Into g_bg_id  -- Business Group Id
From pay_payroll_actions
Where payroll_action_id = pactid ;

select ppa.legislative_parameters
into l_leg_param
from pay_payroll_actions ppa
where payroll_action_id = pactid;

l_tmp_char :=  get_parameter('PLAN_YEAR', l_leg_param);
l_legal_entity_id :=  get_parameter('LEGAL_ENTITY_ID', l_leg_param);

-- Get the effective date of the payroll action
Select effective_date
Into   g_archive_effective_date
From   pay_payroll_actions
Where  payroll_action_id = pactid;

 -- get_parameters(pactid, 'LEGAL_ENTITY_ID', l_tmp_char);
if (l_legal_entity_id is null) then
  g_legal_entity_id := null;
 else
  g_legal_entity_id := to_number(l_legal_entity_id); -- Type cast to number
 end if;


 -- set the plan and training year start and end dates
g_plan_year := fnd_number.canonical_to_number(l_tmp_char);

g_wsp_start_date := to_date('01-04-'||(g_plan_year-1) , 'DD-MM-YYYY');
g_wsp_end_date   := to_date('31-03-'||g_plan_year     , 'DD-MM-YYYY');

g_atr_start_date := to_date('01-04-'||(g_plan_year-2) , 'DD-MM-YYYY');
g_atr_end_date   := to_date('31-03-'||(g_plan_year-1) , 'DD-MM-YYYY');

hr_utility.set_location('g_legal_entity_id = '||g_legal_entity_id,10);
hr_utility.set_location('g_archive_effective_date = '||g_archive_effective_date,10);
hr_utility.set_location('g_wsp_start_date = '||g_wsp_start_date,10);
hr_utility.set_location('g_wsp_end_date   = '||g_wsp_end_date,10);
hr_utility.set_location('g_atr_start_date = '||g_atr_start_date,10);
hr_utility.set_location('g_atr_end_date   = '||g_atr_end_date,10);

-- set the payroll_action_id
g_pactid := pactid;
-----------------
-- calling to set the global tables
   set_global_tables;
--

-- debug
l_count := g_wsp_pri_final_tab.COUNT;
if l_count > 0 then
l_index := g_wsp_pri_final_tab.FIRST;
WHILE l_index IS NOT NULL
	LOOP
   	hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id			'||g_wsp_pri_final_tab(l_index).legal_entity_id,40);
  	hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_name'||g_wsp_pri_final_tab(l_index).skills_priority_name,40);
  	hr_utility.set_location('g_wsp_pri_final_tab(l_index).year								'||g_wsp_pri_final_tab(l_index).year,40);
  	hr_utility.set_location('range_cursor: l_index:' ||l_index,40);
  	l_index := g_wsp_pri_final_tab.NEXT(l_index);  -- get subscript of next element
	END LOOP;
end if;
-- debug

--Archive the Legal Entity Contact Details
   l_tmp_flag := true;
   if g_legal_entity_id is not null then
    hr_utility.set_location('g_legal_entity_id  = '||g_legal_entity_id,10);
   for le_info_rec1 in csr_le_contact_info(g_legal_entity_id)
     loop
         hr_utility.set_location('Archiving ZA WSP Employer Contact Details', 10);
         l_tmp_flag := false;
         open csr_seta_info(g_legal_entity_id);
         fetch csr_seta_info into l_seta_name,l_sic_code;
         close csr_seta_info;
         hr_utility.set_location('g_archive_effective_date       = '||to_char(g_archive_effective_date,'DD-MON-YYYY'),10);
         hr_utility.set_location('le_info_rec1.org_name          = '|| le_info_rec1.org_name,10);
         hr_utility.set_location('le_info_rec1.post_add_line_1   = '||le_info_rec1.post_add_line_1   ,10);
         hr_utility.set_location('le_info_rec1.post_add_line_2   = '||le_info_rec1.post_add_line_2   ,10);
         hr_utility.set_location('le_info_rec1.post_add_line_3   = '||le_info_rec1.post_add_line_3   ,10);
        -- hr_utility.set_location('le_info_rec1.post_add_line_4   = '||le_info_rec1.post_add_line_4   ,10);
         hr_utility.set_location('le_info_rec1.post_town_or_city = '||le_info_rec1.post_town_or_city ,10);
         hr_utility.set_location('le_info_rec1.post_postal_code  = '||le_info_rec1.post_postal_code  ,10);
         hr_utility.set_location('le_info_rec1.post_province     = '||le_info_rec1.post_province     ,10);
         hr_utility.set_location('le_info_rec1.phy_add_line_1    = '||le_info_rec1.phy_add_line_1    ,10);
         hr_utility.set_location('le_info_rec1.phy_add_line_2    = '||le_info_rec1.phy_add_line_2    ,10);
         hr_utility.set_location('le_info_rec1.phy_add_line_3    = '||le_info_rec1.phy_add_line_3    ,10);
    --     hr_utility.set_location('le_info_rec1.phy_add_line_4    = '||le_info_rec1.phy_add_line_4    ,10);
         hr_utility.set_location('le_info_rec1.phy_town_or_city  = '||le_info_rec1.phy_town_or_city  ,10);
         hr_utility.set_location('le_info_rec1.phy_postal_code   = '||le_info_rec1.phy_postal_code   ,10);
         hr_utility.set_location('le_info_rec1.phy_province      = '||le_info_rec1.phy_province      ,10);
         hr_utility.set_location('le_info_rec1.tel_no            = '||le_info_rec1.tel_no            ,10);
         hr_utility.set_location('le_info_rec1.fax_no            = '||le_info_rec1.fax_no            ,10);
         hr_utility.set_location('le_info_rec1.email_add         = '||le_info_rec1.email_add         ,10);
         hr_utility.set_location('l_seta_name                    = '||l_seta_name                    ,10);
         hr_utility.set_location('l_sic_code                     = '||l_sic_code                     ,10);
         hr_utility.set_location('l_sdl_no                       = '||le_info_rec1.sdl_no            ,10);



         -- Archive 'ZA WSP EMPLOYER DETAILS'
         pay_action_information_api.create_action_information
         (
            p_action_information_id       => l_action_info_id
          , p_action_context_id           => pactid
          , p_action_context_type         => 'PA'
          , p_object_version_number       => l_ovn
          , p_effective_date              => g_archive_effective_date
          , p_action_information_category => 'ZA WSP EMPLOYER DETAILS'
          , p_action_information1         => g_bg_id                          -- Business GROUP Id
          , p_action_information2         => g_legal_entity_id                -- Legal Entity Id
          , p_action_information3         => le_info_rec1.org_name            -- A(1).1 Organization Name
          , p_action_information4         => le_info_rec1.post_add_line_1     -- A(1).2 Postal Address
          , p_action_information5         => le_info_rec1.post_add_line_2
          , p_action_information6         => le_info_rec1.post_add_line_3
--          , p_action_information7       => le_info_rec1.post_add_line_4     -- Reserved for Address line 4
          , p_action_information8         => le_info_rec1.post_town_or_city
          , p_action_information9         => le_info_rec1.post_postal_code
          , p_action_information10        => le_info_rec1.post_province
          , p_action_information11        => le_info_rec1.phy_add_line_1      -- A(1).3 Physical Address
          , p_action_information12        => le_info_rec1.phy_add_line_2
          , p_action_information13        => le_info_rec1.phy_add_line_3
--          , p_action_information14      => le_info_rec1.phy_add_line_4      -- Reserved for Address line 4
          , p_action_information15        => le_info_rec1.phy_town_or_city
          , p_action_information16        => le_info_rec1.phy_postal_code
          , p_action_information17        => le_info_rec1.phy_province
          , p_action_information18        => le_info_rec1.tel_no              -- A(1).5 Telephone number
          , p_action_information19        => le_info_rec1.fax_no              -- A(1).6 Fax number
          , p_action_information20        => le_info_rec1.email_add           -- A(1).7 E-mail Address
          , p_action_information21        => l_seta_name                       -- Seta Name
          , p_action_information22        => l_sic_code
	  , p_action_information23        => le_info_rec1.sdl_no
          );
     end loop;
   else
     for rec_le_id in g_csr_le
     loop
        for le_info_rec1 in csr_le_contact_info(rec_le_id.organization_id)
        loop
          hr_utility.set_location('Archiving ZA WSP Employer Contact Details', 20);
          l_tmp_flag := false;
          open csr_seta_info(rec_le_id.organization_id);
          fetch csr_seta_info into l_seta_name,l_sic_code;
          close csr_seta_info;

          -- Archive 'ZA WSP EMPLOYER DETAILS'
          pay_action_information_api.create_action_information
          (
             p_action_information_id       => l_action_info_id
           , p_action_context_id           => pactid
           , p_action_context_type         => 'PA'
           , p_object_version_number       => l_ovn
           , p_effective_date              => g_archive_effective_date
           , p_action_information_category => 'ZA WSP EMPLOYER DETAILS'
           , p_action_information1         => g_bg_id                          -- Business GROUP Id
           , p_action_information2         => rec_le_id.organization_id        -- Legal Entity Id
           , p_action_information3         => le_info_rec1.org_name            -- A(1).1 Organization Name
           , p_action_information4         => le_info_rec1.post_add_line_1     -- A(1).2 Postal Address
           , p_action_information5         => le_info_rec1.post_add_line_2
           , p_action_information6         => le_info_rec1.post_add_line_3
 --        , p_action_information7       => le_info_rec1.post_add_line_4     -- Reserved for Address line 4
           , p_action_information8         => le_info_rec1.post_town_or_city
           , p_action_information9         => le_info_rec1.post_postal_code
           , p_action_information10        => le_info_rec1.post_province
           , p_action_information11        => le_info_rec1.phy_add_line_1      -- A(1).3 Physical Address
           , p_action_information12        => le_info_rec1.phy_add_line_2
           , p_action_information13        => le_info_rec1.phy_add_line_3
 --        , p_action_information14      => le_info_rec1.phy_add_line_4      -- Reserved for Address line 4
           , p_action_information15        => le_info_rec1.phy_town_or_city
           , p_action_information16        => le_info_rec1.phy_postal_code
           , p_action_information17        => le_info_rec1.phy_province
           , p_action_information18        => le_info_rec1.tel_no              -- A(1).5 Telephone number
           , p_action_information19        => le_info_rec1.fax_no              -- A(1).6 Fax number
           , p_action_information20        => le_info_rec1.email_add           -- A(1).7 E-mail Address
           , p_action_information21        => l_seta_name                      -- Seta Name
           , p_action_information22        => l_sic_code
           , p_action_information23        => le_info_rec1.sdl_no
           );
        end loop;
     end loop;
   end if;
--
    if l_tmp_flag = true
     then
        hr_utility.set_location('ZA WSP EMPLOYER CONTACT DETAILS does not exist', 20);
     end if;
--
-- BANK DETAILS WILL NOT BE REPORTED .... CUSTOMERS NEED TO FILL IT MANUALLY
-- Archive Skills Development Facilitator(SDF) details
   l_tmp_flag := true;
   if g_legal_entity_id is not null then
     for le_sdf_rec3 in csr_sdf_info(g_legal_entity_id)
     loop
         hr_utility.set_location('Archiving ZA WSP SDF Details', 20);
         l_tmp_flag := false;
         hr_utility.set_location('g_archive_effective_date      = '||to_char(g_archive_effective_date,'DD-MON-YYYY'),20);
         hr_utility.set_location('le_sdf_rec3.sdf_name          = '||le_sdf_rec3.sdf_name          ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_add_line_1    = '||le_sdf_rec3.sdf_add_line_1    ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_add_line_2    = '||le_sdf_rec3.sdf_add_line_2    ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_add_line_3    = '||le_sdf_rec3.sdf_add_line_3    ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_add_line_4    = '||le_sdf_rec3.sdf_add_line_4    ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_town_or_city  = '||le_sdf_rec3.sdf_town_or_city  ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_province      = '||le_sdf_rec3.sdf_province      ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_postal_code   = '||le_sdf_rec3.sdf_postal_code   ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_telephone_no  = '||le_sdf_rec3.sdf_telephone_no  ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_fax_no        = '||le_sdf_rec3.sdf_fax_no        ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_email_id      = '||le_sdf_rec3.sdf_email_id      ,20);
         hr_utility.set_location('le_sdf_rec3.sdf_mobile_no     = '||le_sdf_rec3.sdf_mobile_no     ,20);


         -- Archive 'ZA WSP SDF DETAILS'
         pay_action_information_api.create_action_information
         (
            p_action_information_id       => l_action_info_id
          , p_action_context_id           => pactid
          , p_action_context_type         => 'PA'
          , p_object_version_number       => l_ovn
          , p_effective_date              => g_archive_effective_date
          , p_action_information_category => 'ZA WSP SDF DETAILS'
          , p_action_information1         => g_bg_id                         -- Business GROUP Id
          , p_action_information2         => g_legal_entity_id               -- Legal Entity Id
          , p_action_information3         => le_sdf_rec3.sdf_name            -- A(1).12 SDF Name
          , p_action_information4         => le_sdf_rec3.sdf_add_line_1      -- A(1).13 SDF Address
          , p_action_information5         => le_sdf_rec3.sdf_add_line_2
          , p_action_information6         => le_sdf_rec3.sdf_add_line_3
          , p_action_information7         => le_sdf_rec3.sdf_add_line_4
          , p_action_information8         => le_sdf_rec3.sdf_town_or_city
          , p_action_information9         => le_sdf_rec3.sdf_province
          , p_action_information10        => le_sdf_rec3.sdf_postal_code
          , p_action_information11        => le_sdf_rec3.sdf_telephone_no     -- A(1).14 SDF contact details
          , p_action_information12        => le_sdf_rec3.sdf_fax_no
          , p_action_information13        => le_sdf_rec3.sdf_email_id
          , p_action_information14        => le_sdf_rec3.sdf_mobile_no
          );
     end loop;
   else
     for rec_le_id in g_csr_le
     loop
      for le_sdf_rec3 in csr_sdf_info(rec_le_id.organization_id)
      loop
         hr_utility.set_location('Archiving ZA WSP SDF Details', 30);
         l_tmp_flag := false;
         -- Archive 'ZA WSP SDF DETAILS'
         pay_action_information_api.create_action_information
         (
            p_action_information_id       => l_action_info_id
          , p_action_context_id           => pactid
          , p_action_context_type         => 'PA'
          , p_object_version_number       => l_ovn
          , p_effective_date              => g_archive_effective_date
          , p_action_information_category => 'ZA WSP SDF DETAILS'
          , p_action_information1         => g_bg_id                         -- Business GROUP Id
          , p_action_information2         => rec_le_id.organization_id       -- Legal Entity Id
          , p_action_information3         => le_sdf_rec3.sdf_name            -- A(1).12 SDF Name
          , p_action_information4         => le_sdf_rec3.sdf_add_line_1      -- A(1).13 SDF Address
          , p_action_information5         => le_sdf_rec3.sdf_add_line_2
          , p_action_information6         => le_sdf_rec3.sdf_add_line_3
          , p_action_information7         => le_sdf_rec3.sdf_add_line_4
          , p_action_information8         => le_sdf_rec3.sdf_town_or_city
          , p_action_information9         => le_sdf_rec3.sdf_province
          , p_action_information10        => le_sdf_rec3.sdf_postal_code
          , p_action_information11        => le_sdf_rec3.sdf_telephone_no     -- A(1).14 SDF contact details
          , p_action_information12        => le_sdf_rec3.sdf_fax_no
          , p_action_information13        => le_sdf_rec3.sdf_email_id
          , p_action_information14        => le_sdf_rec3.sdf_mobile_no
          );
      end loop;
     end loop;
   end if;

   if l_tmp_flag = true
     then
        hr_utility.set_location('ZA WSP SDF DETAILS does not exist', 30);
   end if;
--
-- Archive Annual Education and Training Programs Provided
--WSP
hr_utility.set_location('Archive WSP Training Programs Provided',40);
l_count := g_wsp_pri_final_tab.COUNT;
hr_utility.set_location('l_count: '||l_count,40);
if l_count > 0 then
l_index := g_wsp_pri_final_tab.FIRST;
WHILE l_index IS NOT NULL
	LOOP
  if g_legal_entity_id is not null then
  	hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id: '||g_wsp_pri_final_tab(l_index).legal_entity_id,40);
    if g_wsp_pri_final_tab(l_index).legal_entity_id = g_legal_entity_id then
    hr_utility.set_location('g_bg_id                                            = '||g_bg_id                                          ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id       = '||g_wsp_pri_final_tab(l_index).legal_entity_id     ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_num   = '||g_wsp_pri_final_tab(l_index).skills_priority_num ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_name  = '||g_wsp_pri_final_tab(l_index).skills_priority_name,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_1               = '||g_wsp_pri_final_tab(l_index).Level_1             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_2               = '||g_wsp_pri_final_tab(l_index).Level_2             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_3               = '||g_wsp_pri_final_tab(l_index).Level_3             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_4               = '||g_wsp_pri_final_tab(l_index).Level_4             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_5               = '||g_wsp_pri_final_tab(l_index).Level_5             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_6               = '||g_wsp_pri_final_tab(l_index).Level_6             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_7               = '||g_wsp_pri_final_tab(l_index).Level_7             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_8               = '||g_wsp_pri_final_tab(l_index).Level_8             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Unknown               = '||g_wsp_pri_final_tab(l_index).Unknown             ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).SAQA_Registered       = '||g_wsp_pri_final_tab(l_index).SAQA_Registered     ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Not_Registered        = '||g_wsp_pri_final_tab(l_index).Not_Registered      ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).SAQA_Ids              = '||g_wsp_pri_final_tab(l_index).SAQA_Ids            ,40);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).year                  = '||g_wsp_pri_final_tab(l_index).year                ,40);

    pay_action_information_api.create_action_information
    (
       p_action_information_id       => l_action_info_id
     , p_action_context_id           => pactid
     , p_action_context_type         => 'PA'
     , p_object_version_number       => l_ovn
     , p_effective_date              => g_archive_effective_date
     , p_action_information_category => 'ZA WSP TRAINING PROGRAMS'
     , p_action_information1         => g_bg_id
     , p_action_information2         => g_wsp_pri_final_tab(l_index).legal_entity_id
     , p_action_information3         => g_wsp_pri_final_tab(l_index).skills_priority_num      --Skills Priority Number
     , p_action_information4         => g_wsp_pri_final_tab(l_index).skills_priority_name     --Skills Priority Name
     , p_action_information5         => g_wsp_pri_final_tab(l_index).Level_1                 --Level 1
     , p_action_information6         => g_wsp_pri_final_tab(l_index).Level_2                 --Level 2
     , p_action_information7         => g_wsp_pri_final_tab(l_index).Level_3                 --Level 3
     , p_action_information8         => g_wsp_pri_final_tab(l_index).Level_4                 --Level 4
     , p_action_information9         => g_wsp_pri_final_tab(l_index).Level_5                 --Level 5
     , p_action_information10        => g_wsp_pri_final_tab(l_index).Level_6                 --Level 6
     , p_action_information11        => g_wsp_pri_final_tab(l_index).Level_7                 --Level 7
     , p_action_information12        => g_wsp_pri_final_tab(l_index).Level_8                 --Level 8
     , p_action_information13        => g_wsp_pri_final_tab(l_index).Unknown                 --Unknown
     , p_action_information14        => g_wsp_pri_final_tab(l_index).SAQA_Registered         --SAQA_Registered
     , p_action_information15        => g_wsp_pri_final_tab(l_index).Not_Registered          --Not Registered
     , p_action_information16        => g_wsp_pri_final_tab(l_index).SAQA_Ids                --SAQA Ids
     , p_action_information17        => g_wsp_pri_final_tab(l_index).year
     );
     end if;
     l_index := g_wsp_pri_final_tab.NEXT(l_index);  -- get subscript of next element
   else
    hr_utility.set_location('g_bg_id                                            = '||g_bg_id                                          ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).legal_entity_id       = '||g_wsp_pri_final_tab(l_index).legal_entity_id     ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_num   = '||g_wsp_pri_final_tab(l_index).skills_priority_num ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_name  = '||g_wsp_pri_final_tab(l_index).skills_priority_name,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_1               = '||g_wsp_pri_final_tab(l_index).Level_1             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_2               = '||g_wsp_pri_final_tab(l_index).Level_2             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_3               = '||g_wsp_pri_final_tab(l_index).Level_3             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_4               = '||g_wsp_pri_final_tab(l_index).Level_4             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_5               = '||g_wsp_pri_final_tab(l_index).Level_5             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_6               = '||g_wsp_pri_final_tab(l_index).Level_6             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_7               = '||g_wsp_pri_final_tab(l_index).Level_7             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Level_8               = '||g_wsp_pri_final_tab(l_index).Level_8             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Unknown               = '||g_wsp_pri_final_tab(l_index).Unknown             ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).SAQA_Registered       = '||g_wsp_pri_final_tab(l_index).SAQA_Registered     ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).Not_Registered        = '||g_wsp_pri_final_tab(l_index).Not_Registered      ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).SAQA_Ids              = '||g_wsp_pri_final_tab(l_index).SAQA_Ids            ,45);
    hr_utility.set_location('g_wsp_pri_final_tab(l_index).year                  = '||g_wsp_pri_final_tab(l_index).year                ,45);

    pay_action_information_api.create_action_information
    (
       p_action_information_id       => l_action_info_id
     , p_action_context_id           => pactid
     , p_action_context_type         => 'PA'
     , p_object_version_number       => l_ovn
     , p_effective_date              => g_archive_effective_date
     , p_action_information_category => 'ZA WSP TRAINING PROGRAMS'
     , p_action_information1         => g_bg_id
     , p_action_information2         => g_wsp_pri_final_tab(l_index).legal_entity_id
     , p_action_information3         => g_wsp_pri_final_tab(l_index).skills_priority_num      --Skills Priority Number
     , p_action_information4         => g_wsp_pri_final_tab(l_index).skills_priority_name     --Skills Priority Name
     , p_action_information5         => g_wsp_pri_final_tab(l_index).Level_1                 --Level 1
     , p_action_information6         => g_wsp_pri_final_tab(l_index).Level_2                 --Level 2
     , p_action_information7         => g_wsp_pri_final_tab(l_index).Level_3                 --Level 3
     , p_action_information8         => g_wsp_pri_final_tab(l_index).Level_4                 --Level 4
     , p_action_information9         => g_wsp_pri_final_tab(l_index).Level_5                 --Level 5
     , p_action_information10        => g_wsp_pri_final_tab(l_index).Level_6                 --Level 6
     , p_action_information11        => g_wsp_pri_final_tab(l_index).Level_7                 --Level 7
     , p_action_information12        => g_wsp_pri_final_tab(l_index).Level_8                 --Level 8
     , p_action_information13        => g_wsp_pri_final_tab(l_index).Unknown                 --Unknown
     , p_action_information14        => g_wsp_pri_final_tab(l_index).SAQA_Registered         --SAQA_Registered
     , p_action_information15        => g_wsp_pri_final_tab(l_index).Not_Registered          --Not Registered
     , p_action_information16        => g_wsp_pri_final_tab(l_index).SAQA_Ids                --SAQA Ids
     , p_action_information17        => g_wsp_pri_final_tab(l_index).year
     );

     l_index := g_wsp_pri_final_tab.NEXT(l_index);  -- get subscript of next element
   end if;
  end loop;
end if;
--ATR
hr_utility.set_location('Archive ATR Training Programs Provided',50);
l_count := g_atr_pri_final_tab.COUNT;
if  l_count > 0 then
  l_index := g_atr_pri_final_tab.FIRST;
  hr_utility.set_location('l_index: '||l_index,50);
WHILE l_index IS NOT NULL
	LOOP
  if g_legal_entity_id is not null then
    if g_atr_pri_final_tab(l_index).legal_entity_id = g_legal_entity_id then
    hr_utility.set_location('g_bg_id                                            = '||g_bg_id                                          ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).legal_entity_id       = '||g_atr_pri_final_tab(l_index).legal_entity_id     ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_num   = '||g_atr_pri_final_tab(l_index).skills_priority_num ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_name  = '||g_atr_pri_final_tab(l_index).skills_priority_name,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_1               = '||g_atr_pri_final_tab(l_index).Level_1             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_2               = '||g_atr_pri_final_tab(l_index).Level_2             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_3               = '||g_atr_pri_final_tab(l_index).Level_3             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_4               = '||g_atr_pri_final_tab(l_index).Level_4             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_5               = '||g_atr_pri_final_tab(l_index).Level_5             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_6               = '||g_atr_pri_final_tab(l_index).Level_6             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_7               = '||g_atr_pri_final_tab(l_index).Level_7             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_8               = '||g_atr_pri_final_tab(l_index).Level_8             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Unknown               = '||g_atr_pri_final_tab(l_index).Unknown             ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).SAQA_Registered       = '||g_atr_pri_final_tab(l_index).SAQA_Registered     ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Not_Registered        = '||g_atr_pri_final_tab(l_index).Not_Registered      ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).SAQA_Ids              = '||g_atr_pri_final_tab(l_index).SAQA_Ids            ,50);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).year                  = '||g_atr_pri_final_tab(l_index).year                ,50);


    pay_action_information_api.create_action_information
    (
       p_action_information_id       => l_action_info_id
     , p_action_context_id           => pactid
     , p_action_context_type         => 'PA'
     , p_object_version_number       => l_ovn
     , p_effective_date              => g_archive_effective_date
     , p_action_information_category => 'ZA ATR TRAINING PROGRAMS'
     , p_action_information1         => g_bg_id
     , p_action_information2         => g_atr_pri_final_tab(l_index).legal_entity_id
     , p_action_information3         => g_atr_pri_final_tab(l_index).skills_priority_num      --Skills Priority Number
     , p_action_information4         => g_atr_pri_final_tab(l_index).skills_priority_name     --Skills Priority Name
     , p_action_information5         => g_atr_pri_final_tab(l_index).Level_1                 --Level 1
     , p_action_information6         => g_atr_pri_final_tab(l_index).Level_2                 --Level 2
     , p_action_information7         => g_atr_pri_final_tab(l_index).Level_3                 --Level 3
     , p_action_information8         => g_atr_pri_final_tab(l_index).Level_4                 --Level 4
     , p_action_information9         => g_atr_pri_final_tab(l_index).Level_5                 --Level 5
     , p_action_information10        => g_atr_pri_final_tab(l_index).Level_6                 --Level 6
     , p_action_information11        => g_atr_pri_final_tab(l_index).Level_7                 --Level 7
     , p_action_information12        => g_atr_pri_final_tab(l_index).Level_8                 --Level 8
     , p_action_information13        => g_atr_pri_final_tab(l_index).Unknown                 --Unknown
     , p_action_information14        => g_atr_pri_final_tab(l_index).SAQA_Registered         --SAQA_Registered
     , p_action_information15        => g_atr_pri_final_tab(l_index).Not_Registered          --Not Registered
     , p_action_information16        => g_atr_pri_final_tab(l_index).SAQA_Ids                --SAQA Ids
     , p_action_information17        => g_atr_pri_final_tab(l_index).year
     );

    end if;
    l_index := g_atr_pri_final_tab.NEXT(l_index);  -- get subscript of next element
   else
    hr_utility.set_location('g_bg_id                                            = '||g_bg_id                                          ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).legal_entity_id       = '||g_atr_pri_final_tab(l_index).legal_entity_id     ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_num   = '||g_atr_pri_final_tab(l_index).skills_priority_num ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_name  = '||g_atr_pri_final_tab(l_index).skills_priority_name,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_1               = '||g_atr_pri_final_tab(l_index).Level_1             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_2               = '||g_atr_pri_final_tab(l_index).Level_2             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_3               = '||g_atr_pri_final_tab(l_index).Level_3             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_4               = '||g_atr_pri_final_tab(l_index).Level_4             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_5               = '||g_atr_pri_final_tab(l_index).Level_5             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_6               = '||g_atr_pri_final_tab(l_index).Level_6             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_7               = '||g_atr_pri_final_tab(l_index).Level_7             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Level_8               = '||g_atr_pri_final_tab(l_index).Level_8             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Unknown               = '||g_atr_pri_final_tab(l_index).Unknown             ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).SAQA_Registered       = '||g_atr_pri_final_tab(l_index).SAQA_Registered     ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).Not_Registered        = '||g_atr_pri_final_tab(l_index).Not_Registered      ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).SAQA_Ids              = '||g_atr_pri_final_tab(l_index).SAQA_Ids            ,60);
    hr_utility.set_location('g_atr_pri_final_tab(l_index).year                  = '||g_atr_pri_final_tab(l_index).year                ,60);


    pay_action_information_api.create_action_information
    (
       p_action_information_id       => l_action_info_id
     , p_action_context_id           => pactid
     , p_action_context_type         => 'PA'
     , p_object_version_number       => l_ovn
     , p_effective_date              => g_archive_effective_date
     , p_action_information_category => 'ZA ATR TRAINING PROGRAMS'
     , p_action_information1         => g_bg_id
     , p_action_information2         => g_atr_pri_final_tab(l_index).legal_entity_id
     , p_action_information3         => g_atr_pri_final_tab(l_index).skills_priority_num      --Skills Priority Number
     , p_action_information4         => g_atr_pri_final_tab(l_index).skills_priority_name     --Skills Priority Name
     , p_action_information5         => g_atr_pri_final_tab(l_index).Level_1                 --Level 1
     , p_action_information6         => g_atr_pri_final_tab(l_index).Level_2                 --Level 2
     , p_action_information7         => g_atr_pri_final_tab(l_index).Level_3                 --Level 3
     , p_action_information8         => g_atr_pri_final_tab(l_index).Level_4                 --Level 4
     , p_action_information9         => g_atr_pri_final_tab(l_index).Level_5                 --Level 5
     , p_action_information10        => g_atr_pri_final_tab(l_index).Level_6                 --Level 6
     , p_action_information11        => g_atr_pri_final_tab(l_index).Level_7                 --Level 7
     , p_action_information12        => g_atr_pri_final_tab(l_index).Level_8                 --Level 8
     , p_action_information13        => g_atr_pri_final_tab(l_index).Unknown                 --Unknown
     , p_action_information14        => g_atr_pri_final_tab(l_index).SAQA_Registered         --SAQA_Registered
     , p_action_information15        => g_atr_pri_final_tab(l_index).Not_Registered          --Not Registered
     , p_action_information16        => g_atr_pri_final_tab(l_index).SAQA_Ids                --SAQA Ids
     , p_action_information17        => g_atr_pri_final_tab(l_index).year
     );

     l_index := g_atr_pri_final_tab.NEXT(l_index);  -- get subscript of next element
   end if;
  end loop;
end if;
    --
--delete all pl/sql tables
reset_tables;
-----------------
g_sql_range :=
   'select distinct asg.person_id
      from per_assignments_f   asg,
           pay_payroll_actions ppa
     where ppa.payroll_action_id = :payroll_action_id
       and asg.business_group_id = ppa.business_group_id
       and asg.assignment_type   = ''E''
     order by asg.person_id';

sqlstr := g_sql_range;

hr_utility.trace('Leaving ' || l_proc);

--hr_utility.trace_off;
end range_cursor;
--

/****************************************************************************
   Name        : action_creation
   Arguments   : p_payroll_action_id
                 p_start_person_id
                 p_end_person_id
                 p_chunk_number
   Description : This procedure creates assignment actions for the
                 payroll_action_id passed as parameter for a specific chunk.
*****************************************************************************/
procedure action_creation
(
    pactid      number,
    stperson    number,
    endperson   number,
    chunk       number
) as

-- cursor to get all the valid assignments
-- pick up only the primary assignment for a person
--
cursor csr_get_pri_asg (p_pactid number
                , p_stperson number
                , p_endperson number
                , p_plan_year_end_date date
                , p_legal_entity_id number) is
    select ppf.person_id
         , paa.assignment_id
      from per_all_people_f             ppf
         , per_all_assignments_f        paa
         , per_assignment_extra_info    paei
         , pay_payroll_actions          ppa_arch
         , per_periods_of_service       pps
     where paa.business_group_id = g_bg_id
       and paa.person_id = ppf.person_id
       and ppf.person_id between p_stperson and p_endperson
       and paa.period_of_service_id = pps.period_of_service_id
       and paei.assignment_id = paa.assignment_id
       and paa.assignment_type = 'E'
       and paa.primary_flag = 'Y'
--       and ppa_arch.payroll_id = paa.payroll_id          -- payroll id isnt populated in R12
       and ppa_arch.payroll_action_id = p_pactid
       and paei.aei_information_category = 'ZA_SPECIFIC_INFO'
       and paei.aei_information7 = p_legal_entity_id -- support archive for one or all legal entities in that bg
       -- check if the person is active within the training and plan year
       and ppf.effective_start_date = ( select max(effective_start_date)
                        from   per_all_people_f ppf1
                        where  ppf1.person_id             = ppf.person_id
                        and    ppf1.effective_start_date <= g_wsp_end_date
                        and    ppf1.effective_end_date   >= g_atr_start_date
                        )
               -- check if the asg is active within the training and plan year
       and paa.effective_start_date = ( select max(paa1.effective_start_date)
                        from   per_all_assignments_f paa1
                        where paa1.assignment_id = paa.assignment_id
                        and    paa1.effective_start_date <= g_wsp_end_date
                        and    paa1.effective_end_date   >= g_atr_start_date
                        );

--
l_proc         varchar2(60);
l_person_id    number;
lockingactid   number;
--
--
l_legal_entity_id  varchar2(60);
l_leg_param        varchar2(1000);
l_tmp_char         varchar2(30);
--
begin
--
--
 --hr_utility.trace_on(null,'ZAWSP');

    l_proc := g_package || 'action_creation';
    hr_utility.trace('Entering '||l_proc);
    ---
    -- set the global legislative parameters
Select business_group_id
Into g_bg_id  -- Business Group Id
From pay_payroll_actions
Where payroll_action_id = pactid ;

select ppa.legislative_parameters
into l_leg_param
from pay_payroll_actions ppa
where payroll_action_id = pactid;

l_tmp_char :=  get_parameter('PLAN_YEAR', l_leg_param);
l_legal_entity_id :=  get_parameter('LEGAL_ENTITY_ID', l_leg_param);

-- Get the effective date of the payroll action
Select effective_date
Into   g_archive_effective_date
From   pay_payroll_actions
Where  payroll_action_id = pactid;

 -- get_parameters(pactid, 'LEGAL_ENTITY_ID', l_tmp_char);
if (l_legal_entity_id is null) then
  g_legal_entity_id := null;
 else
  g_legal_entity_id := to_number(l_legal_entity_id); -- Type cast to number
 end if;


 -- set the plan and training year start and end dates
g_plan_year := fnd_number.canonical_to_number(l_tmp_char);

g_wsp_start_date := to_date('01-04-'||(g_plan_year-1) , 'DD-MM-YYYY');
g_wsp_end_date   := to_date('31-03-'||g_plan_year     , 'DD-MM-YYYY');

g_atr_start_date := to_date('01-04-'||(g_plan_year-2) , 'DD-MM-YYYY');
g_atr_end_date   := to_date('31-03-'||(g_plan_year-1) , 'DD-MM-YYYY');

hr_utility.set_location('g_legal_entity_id = '||g_legal_entity_id,10);
hr_utility.set_location('g_archive_effective_date = '||g_archive_effective_date,10);
hr_utility.set_location('g_wsp_start_date = '||g_wsp_start_date,10);
hr_utility.set_location('g_wsp_end_date   = '||g_wsp_end_date,10);
hr_utility.set_location('g_atr_start_date = '||g_atr_start_date,10);
hr_utility.set_location('g_atr_end_date   = '||g_atr_end_date,10);

    ---
    hr_utility.set_location('pactid    = '|| pactid,10);
    hr_utility.set_location('stperson  = '|| stperson,10);
    hr_utility.set_location('endperson = '|| endperson,10);
    hr_utility.set_location('chunk     = '||chunk,10);
    hr_utility.set_location('g_wsp_end_date   :'||to_char(g_wsp_end_date,'DD-MM-YYYY'),10);
    hr_utility.set_location('g_atr_start_date :'||to_char(g_atr_start_date,'DD-MM-YYYY'),10);
--
--
    if g_legal_entity_id is not null then
    for asgrec in csr_get_pri_asg (pactid, stperson, endperson, g_wsp_end_date, g_legal_entity_id )
     loop
          hr_utility.set_location('Entering asgrec',10);
          -- create an assignment action for the primary assignment
             select pay_assignment_actions_s.nextval
              into lockingactid
              from dual;

           -- Insert assignment into pay_assignment_actions
            hr_nonrun_asact.insact
            (
               lockingactid,
               asgrec.assignment_id,
               pactid,
               chunk,
               null
            );
     end loop;
   else
   for rec_le_id in g_csr_le
    loop
      for asgrec in csr_get_pri_asg (pactid, stperson, endperson, g_wsp_end_date, rec_le_id.organization_id )
        loop
          hr_utility.set_location('Entering asgrec ',20);
            -- create an assignment action for the primary assignment
             select pay_assignment_actions_s.nextval
              into lockingactid
              from dual;

             -- Insert assignment into pay_assignment_actions
            hr_nonrun_asact.insact
            (
               lockingactid,
               asgrec.assignment_id,
               pactid,
               chunk,
               null
            );
        end loop;
    end loop;
   end if;
--
   hr_utility.trace('Leaving ' || l_proc);
--   hr_utility.trace_off;
--
end action_creation;


/****************************************************************************
    Name        :  archive_init
    Description : * Initialize global variables
                  * Populate the eight global pl/sql tables for each
                    category of prioritised training events.
                  * Archive Company and SDF details
                   Bank Details will NOT be archived and reported
                  * Populate pl/sql for training event priorites
                  * Archive A2 and B2.
*****************************************************************************/
procedure archive_init (pactid  in number)
  is

l_proc             varchar2(100);
l_legal_entity_id  varchar2(60);
l_leg_param        varchar2(1000);
l_tmp_char         varchar2(30);


l_ovn                   number;
l_action_info_id        number;
l_tmp_flag              boolean;
l_seta_name             varchar2(150);
l_sic_code              varchar2(150);


l_index                 varchar(60);
l_count                 number;
l_count_temp number;


--
begin
 --  hr_utility.trace_on(null,'ZAWSP');
    l_proc := g_package || 'archive_init';
    hr_utility.trace ('Entering '||l_proc);
    hr_utility.trace ('pactid '||pactid);


-- set the global legislative parameters
Select business_group_id
Into g_bg_id  -- Business Group Id
From pay_payroll_actions
Where payroll_action_id = pactid ;

select ppa.legislative_parameters
into l_leg_param
from pay_payroll_actions ppa
where payroll_action_id = pactid;

l_tmp_char :=  get_parameter('PLAN_YEAR', l_leg_param);
l_legal_entity_id :=  get_parameter('LEGAL_ENTITY_ID', l_leg_param);

-- Get the effective date of the payroll action
Select effective_date
Into   g_archive_effective_date
From   pay_payroll_actions
Where  payroll_action_id = pactid;

 -- get_parameters(pactid, 'LEGAL_ENTITY_ID', l_tmp_char);
if (l_legal_entity_id is null) then
  g_legal_entity_id := null;
 else
  g_legal_entity_id := to_number(l_legal_entity_id); -- Type cast to number
 end if;

 -- set the plan and training year start and end dates
g_plan_year := fnd_number.canonical_to_number(l_tmp_char);

g_wsp_start_date := to_date('01-04-'||(g_plan_year-1) , 'DD-MM-YYYY');
g_wsp_end_date   := to_date('31-03-'||g_plan_year     , 'DD-MM-YYYY');

g_atr_start_date := to_date('01-04-'||(g_plan_year-2) , 'DD-MM-YYYY');
g_atr_end_date   := to_date('31-03-'||(g_plan_year-1) , 'DD-MM-YYYY');

--set pl/sql table
hr_utility.set_location('g_pl_tab_start : '||g_pl_tab_start,10);
hr_utility.set_location('g_pl_tab_end : '||g_pl_tab_end,10);
hr_utility.set_location('fnd_global.conc_request_id : '||fnd_global.conc_request_id,10);

if g_pl_tab_start <> 'Y' and g_pl_tab_end <> 'Y' then
set_global_tables;
end if;
hr_utility.set_location('g_pl_tab_start : '||g_pl_tab_start,10);
hr_utility.set_location('g_pl_tab_end : '||g_pl_tab_end,10);


hr_utility.set_location('g_legal_entity_id = '||g_legal_entity_id,10);
hr_utility.set_location('g_archive_effective_date = '||g_archive_effective_date,10);
hr_utility.set_location('g_wsp_start_date = '||g_wsp_start_date,10);
hr_utility.set_location('g_wsp_end_date   = '||g_wsp_end_date,10);
hr_utility.set_location('g_atr_start_date = '||g_atr_start_date,10);
hr_utility.set_location('g_atr_end_date   = '||g_atr_end_date,10);

hr_utility.set_location('g_wsp_pri_final_tab.count   = '||g_wsp_pri_final_tab.count,10);
hr_utility.set_location('g_atr_pri_final_tab.count   = '||g_atr_pri_final_tab.count,10);
hr_utility.set_location('g_wsp_compt_pri_tab.count   = '||g_wsp_compt_pri_tab.count,10);
hr_utility.set_location('g_wsp_certifications_tab.count   = '||g_wsp_certifications_tab.count,10);

    hr_utility.trace('Leaving '||l_proc);
--   hr_utility.trace_off;
end archive_init;
--
--
/****************************************************************************
    Name        : archive_wsp_data2
    Description : Archive person level WSP related data.
*****************************************************************************/
procedure archive_wsp_data2( assactid            in number
                          , p_person_id        in per_all_assignments_f.person_id%type
                          , p_assignment_id    in per_all_assignments_f.assignment_id%type
                          , p_race             in per_all_people_f.per_information4%type
                          , p_sex              in per_all_people_f.sex%type
                          , p_ass_cat_name     in hr_lookups.meaning%type
                          , p_skills_pri_id    in number
                          , p_trng_event_id    in number
                          , p_trng_event_name  in varchar2
                          , p_trng_event_lookup  in varchar2
                          , p_legal_entity_id  in number
                          , p_disability       in varchar2
                          ) is
--variables
l_index             varchar2(40);
l_action_info_id    number;
l_ovn               number;
l_proc              varchar2(50);
l_legal_entity_id   varchar2(30);
begin
  l_proc := g_package ||'archive_wsp_data2';
  hr_utility.set_location('Entering '||l_proc,10);
  select rpad(p_legal_entity_id,15,0) into l_legal_entity_id from dual;
  l_index := l_legal_entity_id ||p_skills_pri_id;

if g_wsp_pri_final_tab.exists(l_index) then
 hr_utility.set_location('skills_priority_name '||g_wsp_pri_final_tab(l_index).skills_priority_name,20);
 hr_utility.set_location('archive for person_id '||p_person_id,20);
   hr_utility.set_location('assactid                                         : '||assactid,10);
  hr_utility.set_location('p_legal_entity_id                                : '||p_legal_entity_id,10);
  hr_utility.set_location('p_person_id                                      : '||p_person_id,10);
  hr_utility.set_location('p_race                                           : '||p_race,10);
  hr_utility.set_location('p_sex                                            : '||p_sex,10);
  hr_utility.set_location('p_ass_cat_name                                   : '||p_ass_cat_name,10);
  hr_utility.set_location('p_disability                                     : '||p_disability,10);
  hr_utility.set_location('p_trng_event_id                                  : '||p_trng_event_id,10);
  hr_utility.set_location('p_trng_event_name                                : '||p_trng_event_name,10);
  hr_utility.set_location('p_trng_event_lookup                              : '||p_trng_event_lookup,10);
  hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_num : '||g_wsp_pri_final_tab(l_index).skills_priority_num,10);
  hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_id  : '||g_wsp_pri_final_tab(l_index).skills_priority_id,10);
  hr_utility.set_location('g_wsp_pri_final_tab(l_index).skills_priority_name: '||g_wsp_pri_final_tab(l_index).skills_priority_name,10);
  --hr_utility.set_location('p_status                                         : '||p_status,10);


 pay_action_information_api.create_action_information
    (
      p_action_information_id       => l_action_info_id
    , p_assignment_id               => p_assignment_id
    , p_action_context_id           => assactid
    , p_action_context_type         => 'AAP'
    , p_object_version_number       => l_ovn
    , p_effective_date              => g_archive_effective_date
    , p_action_information_category => 'ZA WSP PERSON DETAILS'
    , p_action_information1         => g_bg_id                               -- Business GROUP Id
    , p_action_information2         => p_legal_entity_id
    , p_action_information3         => p_person_id
    , p_action_information4         => p_race
    , p_action_information5         => p_sex
    , p_action_information6         => p_ass_cat_name                         -- Occupation category
    , p_action_information7         => p_disability
    , p_action_information8         => p_trng_event_id                        -- trng event id course/competence/qualification/learningpath/certification
    , p_action_information9         => p_trng_event_name                      -- trng event Name
    , p_action_information10        => p_trng_event_lookup                                    -- trng event category
    , p_action_information11        => g_wsp_pri_final_tab(l_index).skills_priority_num
    , p_action_information12        => g_wsp_pri_final_tab(l_index).skills_priority_id
    , p_action_information13        => g_wsp_pri_final_tab(l_index).skills_priority_name
 --   , p_action_information14        => null --Attended/Completed
    );
end if;
  hr_utility.set_location('Leaving '||l_proc,10);

end archive_wsp_data2;
--
--
/****************************************************************************
    Name        : archive_wsp_data
    Description : Archive person level WSP related data.
*****************************************************************************/
procedure archive_wsp_data( assactid             in number
                          , p_person_id        in per_all_assignments_f.person_id%type
                          , p_assignment_id    in per_all_assignments_f.assignment_id%type
                          , p_race             in per_all_people_f.per_information4%type
                          , p_sex              in per_all_people_f.sex%type
                          , p_ass_cat_name     in hr_lookups.meaning%type
                          , p_legal_entity_id  in number
                          , p_disability       in varchar2
                          ) is
--
l_proc                  varchar2(50);
l_ovn                   number;
l_action_info_id        number;
l_index                 varchar2(30);
l_legal_entity_id       varchar2(15);
l_exists_compts           number;
l_exists_courses        number;
-- index by Skills priority id + Competence/Course Id
l_per_compt_pri_tab     t_trng_priority_tab;
l_per_courses_pri_tab   t_trng_priority_tab;
--
-- Learning Paths
cursor csr_wsp_lp(p_person_id number) is
select olp.learning_path_id, olp_tl.name
from   ota_learning_paths       olp
      ,ota_learning_paths_tl    olp_tl
      ,ota_lp_enrollments       ole
where ole.person_id = p_person_id
and ole.learning_path_id = olp.learning_path_id
and ole.path_status_code  <> 'CANCELLED'
--and ole.completion_target_date between g_wsp_start_date and  g_wsp_end_date --changed
and ole.creation_date between g_wsp_start_date and  g_wsp_end_date
and olp.learning_path_id = olp_tl.learning_path_id
and olp_tl.language = userenv('LANG');
--
-- Certifications
cursor csr_wsp_cert(p_person_id number) is
select oc.certification_id, oc_tl.name
from ota_certifications_b  oc
    ,ota_certifications_tl oc_tl
    ,ota_cert_enrollments  oce
where oce.person_id = p_person_id
and oce.certification_id = oc.certification_id
and oc.certification_id = oc_tl.certification_id
and oc_tl.language = userenv('LANG')
and oc.start_date_active <= g_wsp_end_date
and (oc.end_date_active >= g_wsp_start_date or oc.end_date_active is null)
and oce.certification_status_code not in ('CANCELLED','EXPIRED'); --AWAITING_APPROVAL,CANCELLED,CERTIFIED,ENROLLED,EXPIRED,REJECTED
--
-- Courses
cursor csr_wsp_courses(p_person_id number) is
select oav.activity_version_id, oav.version_name
from ota_events oe
    ,ota_activity_versions oav
    ,ota_delegate_bookings odb
    ,ota_booking_status_types obst
where odb.delegate_person_id = p_person_id
and   odb.event_id = oe.event_id
and   oe.event_type in ( 'SCHEDULED', 'SELFPACED')
and   oe.activity_version_id = oav.activity_version_id
and   oe.course_start_date <= g_wsp_end_date
and   nvl(oe.course_end_date, g_wsp_start_date) >= g_wsp_start_date
and   obst.booking_status_type_id = odb.booking_status_type_id
and   obst.type <> 'C'; -- include all status except the cancelled
--
-- Get the Competences Linked to a Course
cursor csr_get_course_compts(p_course_id number) is
select pce.competence_id ,pc.name
from per_competence_elements pce
   , per_competences pc
where pce.type = 'DELIVERY'
and pce.activity_version_id = p_course_id
and pce.business_group_id = g_bg_id
and pce.competence_id = pc.competence_id;
--
-- Get the Competences Linked to a Learning Path
cursor csr_get_lp_compts(p_lp_id number) is
select pce.competence_id,pc.name
from per_competence_elements pce
   , per_competences pc
where pce.type = 'OTA_LEARNING_PATH'
and pce.object_id = p_lp_id
and pce.business_group_id = g_bg_id
and pce.competence_id = pc.competence_id;
--
-- Get the Competences Linked to a Certification
cursor csr_get_cert_compts(p_cert_id number) is
select pce.competence_id,pc.name
from per_competence_elements pce
   , per_competences pc
where pce.type = 'OTA_CERTIFICATION'
and pce.object_id = p_cert_id
and pce.business_group_id = g_bg_id
and pce.competence_id = pc.competence_id;
--
-- Get the Courses Linked to a Learning Path
cursor csr_get_lp_courses(p_learning_path_id number) is
select olpm.activity_version_id
from   ota_learning_paths olp
     , ota_lp_sections    olps
     , ota_learning_path_members olpm
where olp.learning_path_id = p_learning_path_id
and   olp.learning_path_id = olps.learning_path_id
and   olps.learning_path_section_id = olpm.learning_path_section_id;
--
-- Get the Courses Linked to a Certification
cursor csr_get_cert_courses(p_cert_id number) is
select ocm.object_id
from OTA_CERTIFICATION_MEMBERS ocm
    , OTA_CERTIFICATIONS_B oc
where oc.certification_id = p_cert_id
and ocm.certification_id = oc.certification_id
and ocm.object_type = 'H';
--
-- Exists cursors
--
cursor csr_exists_course_compts(p_course_id number) is
select count(pce.competence_id)
from per_competence_elements pce
where pce.type = 'DELIVERY'
and pce.activity_version_id = p_course_id
and pce.business_group_id = g_bg_id;
--
cursor csr_exists_lp_compts(p_lp_id number) is
select count(pce.competence_id)
from per_competence_elements pce
where pce.type = 'OTA_LEARNING_PATH'
and pce.object_id = p_lp_id
and pce.business_group_id = g_bg_id;
--
cursor csr_exists_lp_courses(p_learning_path_id number) is
select count(olpm.activity_version_id)
from   ota_learning_paths olp
     , ota_lp_sections    olps
     , ota_learning_path_members olpm
where olp.learning_path_id = p_learning_path_id
and   olp.learning_path_id = olps.learning_path_id
and   olps.learning_path_section_id = olpm.learning_path_section_id;
--
cursor csr_exists_cert_compts(p_cert_id number) is
select count(pce.competence_id)
from per_competence_elements pce
where pce.type = 'OTA_CERTIFICATION'
and pce.object_id = p_cert_id
and pce.business_group_id = g_bg_id;
--
cursor csr_exists_cert_courses(p_cert_id number) is
select count(ocm.object_id)
from OTA_CERTIFICATION_MEMBERS ocm
    , OTA_CERTIFICATIONS_B oc
where oc.certification_id = p_cert_id
and ocm.certification_id = oc.certification_id
and ocm.object_type = 'H';
--
--
-- Get the Valid Priorities defined for a specific Legal Entity
cursor csr_get_all_pri_le is
select puci.user_row_id
from   pay_user_tables put
     , pay_user_rows_f pur
     , pay_user_column_instances_f puci
     , pay_user_columns puc
where put.user_table_name = 'ZA_WSP_SKILLS_PRIORITIES'
and   put.user_table_id = puc.user_table_id
and   puc.user_column_name like p_legal_entity_id || '%'
and   put.user_table_id = pur.user_table_id
and   puci.user_row_id = pur.user_row_id
and   puci.effective_start_date <= g_wsp_end_date
and   nvl(puci.effective_end_date,g_wsp_start_date) >= g_wsp_start_date
and   puci.user_column_id = puc.user_column_id;
--
begin
l_proc := g_package || 'archive_wsp_data';
hr_utility.trace ('Entering '||l_proc);
hr_utility.set_location('l_legal_entity_id:  '||l_legal_entity_id,10);
hr_utility.set_location('assactid         :  '||assactid,10);
hr_utility.set_location('p_person_id      :  '||p_person_id,10);
hr_utility.set_location('p_assignment_id  :  '||p_assignment_id,10);
-- initialize the pl/sql table
l_per_compt_pri_tab.delete;
l_per_courses_pri_tab.delete;
--
select rpad(p_legal_entity_id,15,0) into l_legal_entity_id from dual;
--
hr_utility.set_location('l_legal_entity_id:  '||l_legal_entity_id,10);
hr_utility.set_location('assactid         :  '||assactid,10);
hr_utility.set_location('p_person_id      :  '||p_person_id,10);
hr_utility.set_location('p_assignment_id  :  '||p_assignment_id,10);
--
-- Courses : start
  for rec_courses in csr_wsp_courses(p_person_id)
  loop
  hr_utility.set_location('Entering rec_courses : '||rec_courses.activity_version_id,20);
  hr_utility.set_location('g_wsp_course_pri_tab.COUNT : '||g_wsp_course_pri_tab.COUNT,20);
  hr_utility.set_location('g_wsp_compt_pri_tab.COUNT : '||g_wsp_compt_pri_tab.COUNT,20);
    -- Check if the Course has competences linked to it
  open csr_exists_course_compts(rec_courses.activity_version_id);
  fetch csr_exists_course_compts into l_exists_compts;
  close csr_exists_course_compts;
  --
  hr_utility.set_location('l_exists_compts : '||l_exists_compts,20);
  --
  if l_exists_compts > 0 then
    for rec_get_course_compts in csr_get_course_compts(rec_courses.activity_version_id)
      loop
      hr_utility.set_location('Entering rec_get_course_compts : '||rec_get_course_compts.competence_id,20);
      for rec_get_all_pri_le in csr_get_all_pri_le
        loop
          l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_course_compts.competence_id;
          hr_utility.set_location('Entering rec_get_all_pri_le l_index : '||l_index,20);
          if NOT l_per_compt_pri_tab.exists(l_index) then -- check if this  priority+competence is archived
            hr_utility.set_location('Not archived yet : l_per_compt_pri_tab.COUNT : '||l_per_compt_pri_tab.COUNT,20);
            if g_wsp_compt_pri_tab.exists(l_index) then
              hr_utility.set_location('l_index Exists',20);
              archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id, rec_get_course_compts.competence_id, rec_get_course_compts.name, g_wsp_comp_lookup, p_legal_entity_id, p_disability);
              -- populate the pl/sql table for the person
              l_per_compt_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
              l_per_compt_pri_tab(l_index).trng_event_id := rec_get_course_compts.competence_id;
            end if;
          end if;
        end loop;
      end loop;
  else
    for rec_get_all_pri_le in csr_get_all_pri_le
      loop
       l_index := rec_get_all_pri_le.user_row_id||'_'||rec_courses.activity_version_id;
       hr_utility.set_location('ELSE Entering rec_get_all_pri_le l_index : '||l_index,20);
       if NOT l_per_courses_pri_tab.exists(l_index) then -- check if this  priority+course is archived
         hr_utility.set_location('ELSE Not archived yet : l_per_courses_pri_tab.COUNT : '||l_per_courses_pri_tab.COUNT,20);
         if g_wsp_course_pri_tab.exists(l_index) then
            hr_utility.set_location('ELSE l_index Exists',20);
            archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id, rec_courses.activity_version_id, rec_courses.version_name, g_wsp_courses_lookup, p_legal_entity_id, p_disability);
            -- populate the pl/sql table for the person
            l_per_courses_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
            l_per_courses_pri_tab(l_index).trng_event_id := rec_courses.activity_version_id;
         end if;
       end if;
    end loop;
  end if;
  end loop;
-- Courses : end
--
-- Learning Paths : start
  for rec_learning_paths in csr_wsp_lp(p_person_id)
  loop
  hr_utility.set_location('Entering rec_learning_paths : '||rec_learning_paths.learning_path_id,30);
  hr_utility.set_location('g_wsp_l_paths_tab.COUNT : '||g_wsp_l_paths_tab.COUNT,30);
  if g_wsp_l_paths_tab.exists(rec_learning_paths.learning_path_id) then
    --
    open csr_exists_lp_compts(rec_learning_paths.learning_path_id);
    fetch csr_exists_lp_compts into l_exists_compts;
    close csr_exists_lp_compts;
    --
    open csr_exists_lp_courses(rec_learning_paths.learning_path_id);
    fetch csr_exists_lp_courses into l_exists_courses;
    close csr_exists_lp_courses;
    hr_utility.set_location('LP Exists : '||'Compt:'||l_exists_compts||' Course:'||l_exists_courses,30);

    if (l_exists_compts > 0 OR l_exists_courses > 0) then
      if l_exists_compts > 0 then
        for rec_get_lp_compts in csr_get_lp_compts(rec_learning_paths.learning_path_id)
          loop
          hr_utility.set_location('Entering rec_get_lp_compts: ',30);
          for rec_get_all_pri_le in csr_get_all_pri_le
            loop
              l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_lp_compts.competence_id;
              hr_utility.set_location('Entering rec_get_all_pri_le - l_index: '||l_index, 30);
              if NOT l_per_compt_pri_tab.exists(l_index) then -- check if this  priority+competence is archived
                hr_utility.set_location('Not archived yet : l_per_compt_pri_tab.COUNT : '||l_per_compt_pri_tab.COUNT,30);
                if g_wsp_compt_pri_tab.exists(l_index) then
                  hr_utility.set_location('l_index Exists',30);
                  archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id, rec_get_lp_compts.competence_id, rec_get_lp_compts.name, g_wsp_comp_lookup, p_legal_entity_id, p_disability);
                  -- populate the pl/sql table for the person
                  l_per_compt_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
                  l_per_compt_pri_tab(l_index).trng_event_id := rec_get_lp_compts.competence_id;
                end if;
              end if;
            end loop;
          end loop;
      end if;
      if l_exists_courses > 0 then
        for rec_get_lp_courses in csr_get_lp_courses(rec_learning_paths.learning_path_id)
          loop
          hr_utility.set_location('Entering rec_get_lp_courses: ',30);
          -- Check if the Course has competences linked to it
          open csr_exists_course_compts(rec_get_lp_courses.activity_version_id);
          fetch csr_exists_course_compts into l_exists_compts;
          close csr_exists_course_compts;

          if l_exists_compts > 0 then
            for rec_get_course_compts in csr_get_course_compts(rec_get_lp_courses.activity_version_id)
            loop
            hr_utility.set_location('Entering rec_get_course_compts : '||rec_get_course_compts.competence_id,20);
            for rec_get_all_pri_le in csr_get_all_pri_le
              loop
                l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_course_compts.competence_id;
                hr_utility.set_location('Entering rec_get_all_pri_le l_index : '||l_index,30);
                if NOT l_per_compt_pri_tab.exists(l_index) then -- check if this  priority+competence is archived
                  hr_utility.set_location('Not archived yet : l_per_compt_pri_tab.COUNT : '||l_per_compt_pri_tab.COUNT,30);
                  if g_wsp_compt_pri_tab.exists(l_index) then
                    hr_utility.set_location('l_index Exists',30);
                    archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
                                      rec_get_all_pri_le.user_row_id, rec_get_course_compts.competence_id,
                                      rec_get_course_compts.name, g_wsp_comp_lookup, p_legal_entity_id,
                                      p_disability);
                    -- populate the pl/sql table for the person
                    l_per_compt_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
                    l_per_compt_pri_tab(l_index).trng_event_id := rec_get_course_compts.competence_id;
                  end if;
                end if;
              end loop;
            end loop;
          else
            for rec_get_all_pri_le in csr_get_all_pri_le
              loop
                l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_lp_courses.activity_version_id;
                hr_utility.set_location('Entering rec_get_all_pri_le - l_index: '||l_index, 30);
                if NOT l_per_courses_pri_tab.exists(l_index) then -- check if this  priority+course is archived
                  hr_utility.set_location('Not archived yet : l_per_courses_pri_tab.COUNT : '||l_per_courses_pri_tab.COUNT,30);
                  if g_wsp_course_pri_tab.exists(l_index) then
                    hr_utility.set_location('l_index Exists',30);
                    archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id,
                                      rec_get_lp_courses.activity_version_id, rec_get_lp_courses.activity_version_id, g_wsp_courses_lookup,
                                       p_legal_entity_id, p_disability);
                    -- populate the pl/sql table for the person
                    l_per_courses_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
                    l_per_courses_pri_tab(l_index).trng_event_id := rec_get_lp_courses.activity_version_id;
                  end if;
                end if;
              end loop;
          end if;
          end loop;
      end if;
    else
      l_index := rec_learning_paths.learning_path_id;
      hr_utility.set_location('No Linked Course or Compt - l_index'||l_index,30);
      if (g_wsp_l_paths_tab(l_index).Attribute1 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute1)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute1, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute2 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute2))  then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute2, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute3 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute3)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute3, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute4 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute4)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute4, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute5 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute5)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute5, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute6 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute6)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute6, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute7 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute7)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute7, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute8 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute8)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute8, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute9 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute9)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute9, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute10 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute10)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute10, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute11 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute11)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute11, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute12 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute12)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute12, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute13 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute13)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute13, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute14 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute14)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute14, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
      if (g_wsp_l_paths_tab(l_index).Attribute15 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_l_paths_tab(l_index).Attribute15)) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_l_paths_tab(l_index).Attribute15, rec_learning_paths.learning_path_id, rec_learning_paths.name, g_wsp_lpath_lookup, p_legal_entity_id, p_disability);
      end if;
    end if;
  end if ;
  end loop;
-- Learning Path : end
--
-- Certifications : start
  for rec_certifications in csr_wsp_cert(p_person_id)
  loop
  hr_utility.set_location('Entering rec_certifications : '||rec_certifications.certification_id,40);
  hr_utility.set_location('g_wsp_certifications_tab.COUNT : '||g_wsp_certifications_tab.COUNT,40);
  hr_utility.set_location('g_wsp_certifications_tab.first : '||g_wsp_certifications_tab.first,40);
  if g_wsp_certifications_tab.exists(rec_certifications.certification_id) then
    --
    open csr_exists_cert_compts(rec_certifications.certification_id);
    fetch csr_exists_cert_compts into l_exists_compts;
    close csr_exists_cert_compts;
    --
    open csr_exists_cert_courses(rec_certifications.certification_id);
    fetch csr_exists_cert_courses into l_exists_courses;
    close csr_exists_cert_courses;
--
    hr_utility.set_location('Cert Exists : '||'Compt:'||l_exists_compts||' Course:'||l_exists_courses,40);

    if ( l_exists_compts > 0 OR l_exists_courses > 0 ) then
      if l_exists_compts > 0 then
        for rec_get_cert_compts in csr_get_cert_compts(rec_certifications.certification_id)
          loop
          hr_utility.set_location('Entering rec_get_cert_compts: ',40);
          for rec_get_all_pri_le in csr_get_all_pri_le
            loop
              l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_cert_compts.competence_id;
              hr_utility.set_location('Entering rec_get_all_pri_le - l_index : '||l_index,40);
              if NOT l_per_compt_pri_tab.exists(l_index) then -- check if this  priority + competence is archived
                hr_utility.set_location('Not archived yet : l_per_compt_pri_tab.COUNT : '||l_per_compt_pri_tab.COUNT,40);
                if g_wsp_compt_pri_tab.exists(l_index) then
                  hr_utility.set_location('l_index Exists',40);
                  archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id, rec_get_cert_compts.competence_id, rec_get_cert_compts.name, g_wsp_comp_lookup, p_legal_entity_id, p_disability);
                  -- populate the pl/sql table for the person
                  l_per_compt_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
                  l_per_compt_pri_tab(l_index).trng_event_id := rec_get_cert_compts.competence_id;
                end if;
              end if;
            end loop;
          end loop;
      end if;
      if l_exists_courses > 0 then
        for rec_get_cert_courses in csr_get_cert_courses(rec_certifications.certification_id)
          loop
          hr_utility.set_location('Entering rec_get_cert_courses: ',40);
          -- Check if the Course has competences linked to it
          open csr_exists_course_compts(rec_get_cert_courses.object_id);
          fetch csr_exists_course_compts into l_exists_compts;
          close csr_exists_course_compts;

          if l_exists_compts > 0 then
            for rec_get_course_compts in csr_get_course_compts(rec_get_cert_courses.object_id)
            loop
            hr_utility.set_location('Entering rec_get_course_compts : '||rec_get_course_compts.competence_id,20);
            for rec_get_all_pri_le in csr_get_all_pri_le
              loop
                l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_course_compts.competence_id;
                hr_utility.set_location('Entering rec_get_all_pri_le l_index : '||l_index,40);
                if NOT l_per_compt_pri_tab.exists(l_index) then -- check if this  priority+competence is archived
                  hr_utility.set_location('Not archived yet : l_per_compt_pri_tab.COUNT : '||l_per_compt_pri_tab.COUNT,20);
                  if g_wsp_compt_pri_tab.exists(l_index) then
                    hr_utility.set_location('l_index Exists',40);
                    archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id, rec_get_course_compts.competence_id, rec_get_course_compts.name, g_wsp_comp_lookup, p_legal_entity_id, p_disability);
                    -- populate the pl/sql table for the person
                    l_per_compt_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
                    l_per_compt_pri_tab(l_index).trng_event_id := rec_get_course_compts.competence_id;
                  end if;
                end if;
              end loop;
            end loop;
          else
           for rec_get_all_pri_le in csr_get_all_pri_le
            loop
              l_index := rec_get_all_pri_le.user_row_id||'_'||rec_get_cert_courses.object_id;
              hr_utility.set_location('Entering rec_get_all_pri_le - l_index: '||l_index, 40);
              if NOT l_per_courses_pri_tab.exists(l_index) then -- check if this  priority+course is archived
                hr_utility.set_location('Not archived yet : l_per_courses_pri_tab.COUNT : '||l_per_courses_pri_tab.COUNT,40);
                if g_wsp_course_pri_tab.exists(l_index) then
                  hr_utility.set_location('l_index Exists',40);
                  archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,rec_get_all_pri_le.user_row_id, rec_get_cert_courses.object_id, rec_get_cert_courses.object_id, g_wsp_courses_lookup, p_legal_entity_id, p_disability);
                  -- populate the pl/sql table for the person
                  l_per_courses_pri_tab(l_index).priority_id := rec_get_all_pri_le.user_row_id;
                  l_per_courses_pri_tab(l_index).trng_event_id := rec_get_cert_courses.object_id;
                end if;
              end if;
            end loop;
          end if;
          end loop;
      end if; -- l_exists_courses > 0
    else
      l_index := rec_certifications.certification_id;
      hr_utility.set_location('No Linked Course or Compt - l_index'||l_index,40);
      if g_wsp_certifications_tab(l_index).Attribute1 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute1) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute1, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute2 is not null  and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute2) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute2, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute3 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute3) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute3, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute4 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute4) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute4, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute5 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute5) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute5, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute6 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute6) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute6, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute7 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute7) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute7, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute8 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute8) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute8, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute9 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute9) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute9, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute10 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute10) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute10, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute11 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute11) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute11, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute12 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute12) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute12, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute13 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute13) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute13, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute14 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute14) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute14, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
      if g_wsp_certifications_tab(l_index).Attribute15 is not null and g_wsp_pri_final_tab.exists(l_legal_entity_id||g_wsp_certifications_tab(l_index).Attribute15) then
      archive_wsp_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_wsp_certifications_tab(l_index).Attribute15, rec_certifications.certification_id, rec_certifications.name, g_wsp_cert_lookup, p_legal_entity_id, p_disability);
      end if;
    end if;
  end if;
  end loop;
-- Certification : end
--
    l_per_compt_pri_tab.delete;
    l_per_courses_pri_tab.delete;
    hr_utility.trace('Leaving '||l_proc);
end archive_wsp_data;
--
--
/****************************************************************************
    Name        : archive_atr_data2
    Description : Archive person level ATR related data.
*****************************************************************************/
procedure archive_atr_data2( assactid            in number
                          , p_person_id          in per_all_assignments_f.person_id%type
                          , p_assignment_id      in per_all_assignments_f.assignment_id%type
                          , p_race               in per_all_people_f.per_information4%type
                          , p_sex                in per_all_people_f.sex%type
                          , p_ass_cat_name       in hr_lookups.meaning%type
                          , p_skills_pri_id      in number
                          , p_trng_event_id      in number
                          , p_trng_event_name    in varchar2
                          , p_trng_event_lookup  in varchar2
                          , p_status             in varchar2
                          , p_legal_entity_id    in number
                          , p_disability         in varchar2
                          ) is
--variables
l_index             varchar2(40);
l_action_info_id    number;
l_ovn               number;
l_legal_entity_id   varchar2(30);
l_proc              varchar2(100);
begin
--
l_proc := g_package || 'archive_atr_data2';
hr_utility.trace('Entering '||l_proc);
--
select rpad(p_legal_entity_id,15,0) into l_legal_entity_id from dual;
l_index := l_legal_entity_id ||p_skills_pri_id;
--
hr_utility.set_location('g_atr_pri_final_tab.COUNT: '||g_atr_pri_final_tab.COUNT,10);
hr_utility.set_location('l_index :'   ||l_index,10);
--
if g_atr_pri_final_tab.exists(l_index) then
  hr_utility.set_location('assactid                                         : '||assactid,10);
  hr_utility.set_location('p_legal_entity_id                                : '||p_legal_entity_id,10);
  hr_utility.set_location('p_person_id                                      : '||p_person_id,10);
  hr_utility.set_location('p_race                                           : '||p_race,10);
  hr_utility.set_location('p_sex                                            : '||p_sex,10);
  hr_utility.set_location('p_ass_cat_name                                   : '||p_ass_cat_name,10);
  hr_utility.set_location('p_disability                                     : '||p_disability,10);
  hr_utility.set_location('p_trng_event_id                                  : '||p_trng_event_id,10);
  hr_utility.set_location('p_trng_event_name                                : '||p_trng_event_name,10);
  hr_utility.set_location('p_trng_event_lookup                              : '||p_trng_event_lookup,10);
  hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_num : '||g_atr_pri_final_tab(l_index).skills_priority_num,10);
  hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_id  : '||g_atr_pri_final_tab(l_index).skills_priority_id,10);
  hr_utility.set_location('g_atr_pri_final_tab(l_index).skills_priority_name: '||g_atr_pri_final_tab(l_index).skills_priority_name,10);
  hr_utility.set_location('p_status                                         : '||p_status,10);


  pay_action_information_api.create_action_information
    (
      p_action_information_id       => l_action_info_id
    , p_assignment_id               => p_assignment_id
    , p_action_context_id           => assactid
    , p_action_context_type         => 'AAP'
    , p_object_version_number       => l_ovn
    , p_effective_date              => g_archive_effective_date
    , p_action_information_category => 'ZA ATR PERSON DETAILS'
    , p_action_information1         => g_bg_id                                           -- Business GROUP Id
    , p_action_information2         => p_legal_entity_id
    , p_action_information3         => p_person_id
    , p_action_information4         => p_race
    , p_action_information5         => p_sex
    , p_action_information6         => p_ass_cat_name                                     -- Occupation category
    , p_action_information7         => p_disability
    , p_action_information8         => p_trng_event_id                                    -- trng event id course/competence/qualification/learningpath/certification
    , p_action_information9         => p_trng_event_name                                  -- trng event Name
    , p_action_information10        => p_trng_event_lookup                                  -- trng event category
    , p_action_information11        => g_atr_pri_final_tab(l_index).skills_priority_num
    , p_action_information12        => g_atr_pri_final_tab(l_index).skills_priority_id
    , p_action_information13        => g_atr_pri_final_tab(l_index).skills_priority_name
    , p_action_information14        => p_status                                            --Attended/Completed
    );
 end if;
--
hr_utility.trace('Leaving '||l_proc);
--
end archive_atr_data2;
--
--
/****************************************************************************
    Name        : archive_atr_data
    Description : Archive person level ATR related data. All learning intervention
    							are archived with the status of completed
*****************************************************************************/
procedure archive_atr_data( assactid             in number
                          , p_person_id        in per_all_assignments_f.person_id%type
                          , p_assignment_id    in per_all_assignments_f.assignment_id%type
                          , p_race             in per_all_people_f.per_information4%type
                          , p_sex              in per_all_people_f.sex%type
                          , p_ass_cat_name     in hr_lookups.meaning%type
                          , p_legal_entity_id  in number
                          , p_disability       in varchar2
                          ) is
 l_proc varchar2(50);
 l_status varchar2(50);
 l_index varchar2(60);
 l_legal_entity_id varchar2(15);

-- Qualifications
cursor csr_atr_qual(p_person_id number) is -- Caters for both the two types of Qualifications(Award/Class)
select pqt.qualification_type_id, pqt.name, pqa.awarded_date, pqa.status--event id event name
from   per_qualifications pqa
      ,per_qualification_types pqt
      ,per_establishment_attendances pea
where (pqa.person_id = p_person_id or pea.person_id = p_person_id)
and   pqa.start_date <= g_atr_end_date
and   nvl(pqa.end_date,g_atr_start_date) >= g_atr_start_date
and   pqa.awarded_date between g_atr_start_date and g_atr_end_date
and   pqa.qualification_type_id = pqt.qualification_type_id
and   pqa.attendance_id = pea.attendance_id(+);

-- Competencies
cursor csr_atr_competency(p_person_id number) is
select pc.competence_id, pc.name , pce.achieved_date , pce.status
from  per_competences pc
    , per_competence_elements pce
where pce.person_id = p_person_id
and   pce.competence_id = pc.competence_id
and   pce.effective_date_from between g_atr_start_date and g_atr_end_date
and   pce.type = 'PERSONAL';

--
-- Learning Paths
cursor csr_atr_lp(p_person_id number) is
select olp.learning_path_id, olp_tl.name, ole.completion_date, ole.path_status_code
from   ota_learning_paths       olp
      ,ota_learning_paths_tl    olp_tl
      ,ota_lp_enrollments       ole
where ole.person_id = p_person_id
and ole.learning_path_id = olp.learning_path_id
and ole.path_status_code  = 'COMPLETED'
and ole.completion_date between g_atr_start_date and  g_atr_end_date
and olp.learning_path_id = olp_tl.learning_path_id
and olp_tl.language = userenv('LANG');

--
-- Certifications
cursor csr_atr_cert(p_person_id number) is
select oc.certification_id, oc_tl.name,oce.completion_date, oce.certification_status_code
from ota_certifications_b  oc
    ,ota_certifications_tl oc_tl
    ,ota_cert_enrollments  oce
where oce.person_id = p_person_id
and oce.certification_id = oc.certification_id
and oc.certification_id = oc_tl.certification_id
and oc_tl.language = userenv('LANG')
and oce.completion_date between g_atr_start_date and g_atr_end_date
and oce.certification_status_code in ('CERTIFIED'); --AWAITING_APPROVAL,CANCELLED,CERTIFIED,ENROLLED,EXPIRED,REJECTED

-- Courses
cursor csr_atr_courses(p_person_id number) is
select oav.activity_version_id, oav.version_name, odb.date_status_changed ,obst.name "status"
from ota_events oe
    ,ota_activity_versions oav
    ,ota_delegate_bookings odb
    ,ota_booking_status_types obst
where odb.delegate_person_id = p_person_id
and   odb.event_id = oe.event_id
and   oe.event_type in ( 'SCHEDULED', 'SELFPACED')
and   oe.activity_version_id = oav.activity_version_id
and   oe.course_start_date <= g_atr_end_date
and   nvl(oe.course_end_date, g_atr_start_date) >= g_atr_start_date
and   obst.booking_status_type_id = odb.booking_status_type_id
and   obst.type = 'A' -- Attended
and   odb.date_status_changed between g_atr_start_date and g_atr_end_date;
--
-- Get the Valid Priorities defined for a specific Legal Entity
cursor csr_get_all_pri_le is
select puci.user_row_id
from   pay_user_tables put
     , pay_user_rows_f pur
     , pay_user_column_instances_f puci
     , pay_user_columns puc
where put.user_table_name = 'ZA_WSP_SKILLS_PRIORITIES'
and   put.user_table_id = puc.user_table_id
and   puc.user_column_name like to_char(p_legal_entity_id) || '%'
and   put.user_table_id = pur.user_table_id
and   puci.user_row_id = pur.user_row_id
and   puci.effective_start_date <= g_atr_end_date
and   nvl(puci.effective_end_date,g_atr_start_date) >= g_atr_start_date
and   puci.user_column_id = puc.user_column_id;

--
begin
   select rpad(p_legal_entity_id,15,0) into l_legal_entity_id from dual;
    l_proc := g_package || 'archive_atr_data';
    hr_utility.trace('Entering '||l_proc);
    hr_utility.set_location('l_legal_entity_id:  '||l_legal_entity_id,10);
    hr_utility.set_location('assactid         :  '||assactid,10);
    hr_utility.set_location('p_person_id      :  '||p_person_id,10);
    hr_utility.set_location('p_assignment_id  :  '||p_assignment_id,10);
    hr_utility.set_location('p_race           :  '||p_race,10);
    hr_utility.set_location('p_sex            :  '||p_sex,10);
    hr_utility.set_location('p_ass_cat_name   :  '||p_ass_cat_name,10);
    hr_utility.set_location('p_legal_entity_id:  '||p_legal_entity_id,10);
    hr_utility.set_location('p_disability     :  '||p_disability,10);

--Identify attended/completed trng events
--
-- for Qualifications
for rec_qualifications in csr_atr_qual(p_person_id)
 loop
 hr_utility.set_location('Entering rec_qualifications : '||rec_qualifications.qualification_type_id,10);
 hr_utility.set_location('g_atr_qualifications_tab.COUNT'||g_atr_qualifications_tab.COUNT,10);
 if g_atr_qualifications_tab.exists(rec_qualifications.qualification_type_id) then
    hr_utility.set_location('Qual Exists : '||rec_qualifications.qualification_type_id,10);
    --
    l_status := 'COMPLETED'; --
    l_index := rec_qualifications.qualification_type_id;
    if g_atr_qualifications_tab(l_index).Attribute1 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute1) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute1, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                                g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute2 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute2)  then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute2, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                                g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute3 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute3) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute3, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                                g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute4 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute4) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute4, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                                g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute5 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute5) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute5, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                               g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute6 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute6) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute6, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                               g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute7 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute7)  then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute7, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                               g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute8 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute8)   then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute8, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                               g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute9 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute9) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute9, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                               g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute10 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute10) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute10, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                               g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute11 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute11)  then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute11, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                              g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute12 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute12)  then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute12, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                             g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute13 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute13) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute13, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                             g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute14 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute14) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute14, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                            g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_qualifications_tab(l_index).Attribute15 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_qualifications_tab(l_index).Attribute15) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_qualifications_tab(l_index).Attribute15, rec_qualifications.qualification_type_id, rec_qualifications.name,
                                            g_atr_qual_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
  end if;
  end loop;
--
-- Competencies
  for rec_competencies in csr_atr_competency(p_person_id)
  loop
    hr_utility.set_location('Entering rec_competencies : '||rec_competencies.competence_id,20);
    hr_utility.set_location('g_atr_compt_pri_tab.COUNT : '||g_atr_compt_pri_tab.COUNT,20);
  for rec_get_all_pri_le in csr_get_all_pri_le
    loop
      hr_utility.set_location('Entering rec_get_all_pri_le ',20);
      l_index := rec_get_all_pri_le.user_row_id||'_'||rec_competencies.competence_id;
      if g_atr_compt_pri_tab.exists(l_index) then
        hr_utility.set_location('l_index Exists: '||l_index,20);
        l_status := 'COMPLETED';
        archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
                          g_atr_compt_pri_tab(l_index).priority_id, rec_competencies.competence_id,
                          rec_competencies.name, g_atr_comp_lookup, l_status, p_legal_entity_id,
                          p_disability);
      end if;
    end loop;
  end loop;
--
-- Courses
  for rec_courses in csr_atr_courses(p_person_id)
  loop
    hr_utility.set_location('Entering rec_courses : '||rec_courses.activity_version_id,30);
    hr_utility.set_location('g_atr_course_pri_tab.COUNT : '||g_atr_course_pri_tab.COUNT,30);
  for rec_get_all_pri_le in csr_get_all_pri_le
    loop
      hr_utility.set_location('Entering rec_get_all_pri_le ',30);
      l_index := rec_get_all_pri_le.user_row_id||'_'||rec_courses.activity_version_id;
      if g_atr_course_pri_tab.exists(l_index) then
        hr_utility.set_location('l_index Exists: '||l_index,30);
        l_status := 'COMPLETED';
        archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
                          g_atr_course_pri_tab(l_index).priority_id, rec_courses.activity_version_id,
                          rec_courses.version_name, g_atr_courses_lookup, l_status, p_legal_entity_id,
                           p_disability);
      end if;
    end loop;
  end loop;
--
-- Learning Paths
  for rec_learning_paths in csr_atr_lp(p_person_id)
  loop
  hr_utility.set_location('Entering rec_learning_paths : '||rec_learning_paths.learning_path_id,40);
  hr_utility.set_location('g_atr_l_paths_tab.COUNT'||g_atr_l_paths_tab.COUNT,40);
  if g_atr_l_paths_tab.exists(rec_learning_paths.learning_path_id) then
    hr_utility.set_location('LP Exists : '||rec_learning_paths.learning_path_id,40);
    l_status := 'COMPLETED';
    l_index := rec_learning_paths.learning_path_id;
    if g_atr_l_paths_tab(l_index).Attribute1 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute1) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute1,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute2 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute2) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute2,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute3 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute3) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute3,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute4 is not null  and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute4) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute4,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute5 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute5) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute5,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute6 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute6) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute6,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute7 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute7) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute7,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute8 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute8) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute8,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute9 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute9) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute9,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute10 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute10) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute10,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute11 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute11) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute11,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute12 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute12) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute12,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute13 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute13) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute13,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute14 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute14) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute14,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_l_paths_tab(l_index).Attribute15 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_l_paths_tab(l_index).Attribute15) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_l_paths_tab(l_index).Attribute15,
                      rec_learning_paths.learning_path_id, rec_learning_paths.name, g_atr_lpath_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
  end if;
  end loop;
--
-- Certifications
  for rec_certifications in csr_atr_cert(p_person_id)
  loop
  hr_utility.set_location('Entering rec_certifications : '||rec_certifications.certification_id,50);
  hr_utility.set_location('g_atr_certifications_tab.COUNT'||g_atr_certifications_tab.COUNT,50);
  if g_atr_certifications_tab.exists(rec_certifications.certification_id) then
    hr_utility.set_location('Certification Exists : '||rec_certifications.certification_id,50);
    l_status := 'COMPLETED';
    l_index := rec_certifications.certification_id;
    if g_atr_certifications_tab(l_index).Attribute1 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute1) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,g_atr_certifications_tab(l_index).Attribute1,
    rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute2 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute2) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute2, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute3 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute3) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute3, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute4 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute4) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute4, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute5 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute5) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute5, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute6 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute6) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute6, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute7 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute7) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute7, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute8 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute8) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute8, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute9 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute9) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute9, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute10 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute10) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute10, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute11 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute11) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute11, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute12 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute12) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute12, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute13 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute13) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute13, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute14 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute14) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute14, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
    if g_atr_certifications_tab(l_index).Attribute15 is not null and g_atr_pri_final_tab.exists(l_legal_entity_id||g_atr_certifications_tab(l_index).Attribute15) then
    archive_atr_data2(assactid,p_person_id,p_assignment_id,p_race,p_sex,p_ass_cat_name,
    g_atr_certifications_tab(l_index).Attribute15, rec_certifications.certification_id, rec_certifications.name, g_atr_cert_lookup, l_status, p_legal_entity_id, p_disability);
    end if;
  end if;
  end loop;
--
    hr_utility.trace('Leaving '||l_proc);
--
end archive_atr_data;
--
--
-- This procedure caches the location of the occupational category and level data.
procedure cache_occupational_location
(
   p_report_date       in date,
   p_business_group_id in per_all_assignments_f.business_group_id%type
)  is

l_user_table_id       pay_user_tables.user_table_id%type;
l_user_column_id_flex pay_user_columns.user_column_id%type;
l_user_column_id_seg  pay_user_columns.user_column_id%type;
l_user_row_id_cat     pay_user_rows_f.user_row_id%type;
l_user_row_id_lev     pay_user_rows_f.user_row_id%type;
l_user_row_id_func    pay_user_rows_f.user_row_id%type;
l_temp                varchar2(9);

begin

   select user_table_id
   into   l_user_table_id
   from   pay_user_tables
   where  user_table_name = 'ZA_OCCUPATIONAL_TYPES'
   and    business_group_id is null
   and    legislation_code = 'ZA';

   select user_column_id
   into   l_user_column_id_flex
   from   pay_user_columns
   where  user_table_id = l_user_table_id
   and    business_group_id is null
   and    legislation_code = 'ZA'
   and    user_column_name = 'Flexfield';

   select user_column_id
   into   l_user_column_id_seg
   from   pay_user_columns
   where  user_table_id = l_user_table_id
   and    business_group_id is null
   and    legislation_code = 'ZA'
   and    user_column_name = 'Segment';

   select user_row_id
   into   l_user_row_id_cat
   from   pay_user_rows_f
   where  user_table_id = l_user_table_id
   and    row_low_range_or_name = 'Occupational Categories'
   and    p_report_date between effective_start_date and effective_end_date;

   select user_row_id
   into   l_user_row_id_lev
   from   pay_user_rows_f
   where  user_table_id = l_user_table_id
   and    row_low_range_or_name = 'Occupational Levels'
   and    p_report_date between effective_start_date and effective_end_date;

   select user_row_id
   into   l_user_row_id_func
   from   pay_user_rows_f
   where  user_table_id = l_user_table_id
   and    row_low_range_or_name = 'Function Type'
   and    p_report_date between effective_start_date and effective_end_date;


   select value
   into   g_cat_flex
   from   pay_user_column_instances_f
   where  user_row_id    = l_user_row_id_cat
   and    user_column_id = l_user_column_id_flex
   and    business_group_id = p_business_group_id
   and    p_report_date between effective_start_date and effective_end_date;

   select value
   into   g_cat_segment
   from   pay_user_column_instances_f
   where  user_row_id    = l_user_row_id_cat
   and    user_column_id = l_user_column_id_seg
   and    business_group_id = p_business_group_id
   and    p_report_date between effective_start_date and effective_end_date;

   -- Verify the validity of the segments
   begin
      l_temp := substr(g_cat_segment, 8);
      if substr(g_cat_segment, 1, 7) <> 'SEGMENT' or to_number(l_temp) < 1 or to_number(l_temp) > 30 then
         raise_application_error(-20003, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Segment.');
      end if;
   exception
      when invalid_number then
         raise_application_error(-20003, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Segment.');
   end;

exception
   when no_data_found then
      raise_application_error(-20001, 'The Occupational data does not exist in the User Table ZA_OCCUPATIONAL_TYPES.');

end cache_occupational_location;
--
-- This function retrieves the occupational data via dynamic sql from the appropriate flexfield segment
function get_occupational_data
(
   p_type        in varchar2,
   p_flex        in varchar2,
   p_segment     in varchar2,
   p_job_id      in per_all_assignments_f.job_id%type,
   p_grade_id    in per_all_assignments_f.grade_id%type,
   p_position_id in per_all_assignments_f.position_id%type
)  return varchar2 is

l_sql  varchar2(32767);
l_name hr_lookups.meaning%type;


begin
hr_utility.set_location('In side get_occupational_data',1);
hr_utility.set_location('p_flex : ' || p_flex,2);
   if p_flex = upper('Job') then
      begin
         if p_job_id is not null then
            l_sql := 'select hl.meaning from hr_lookups hl, per_job_definitions pjd, per_jobs pj where pj.job_id = '
                     || to_char(p_job_id)
                     || '  and pjd.job_definition_id = pj.job_definition_id and hl.application_id = 800 and hl.lookup_type = '''
                     || p_type || ''' and hl.lookup_code = pjd.' || p_segment;
            execute immediate l_sql into l_name;
         else
            l_name := null;
         end if;
      exception
         when no_data_found then
            l_name := null;
      end;
   elsif p_flex = upper('Grade') then
      begin
         if p_grade_id is not null then
           l_sql := 'select hl.meaning from hr_lookups hl, per_grade_definitions pgd, per_grades pg where pg.grade_id = '
                     || to_char(p_grade_id)
                     || '  and pgd.grade_definition_id = pg.grade_definition_id and hl.application_id = 800 and hl.lookup_type = '''
                     || p_type ||''' and hl.lookup_code = pgd.' || p_segment;
            execute immediate l_sql into l_name;
         else
            l_name := null;
         end if;
      exception
         when no_data_found then
            l_name := null;
      end;
   elsif p_flex = upper('Position') then
      begin
         if p_position_id is not null then
            l_sql := 'select hl.meaning from hr_lookups hl, per_position_definitions ppd, per_all_positions pap where pap.position_id = '
                     || to_char(p_position_id)
                     || '  and ppd.position_definition_id = pap.position_definition_id and hl.application_id = 800 and hl.lookup_type = '''
                     || p_type || ''' and hl.lookup_code = ppd.' || p_segment;
            execute immediate l_sql into l_name;
         else
            l_name := null;
         end if;
      exception
         when no_data_found then
            l_name := null;
      end;
   else
      raise_application_error(-20002, 'The Occupational data in the User Table ZA_OCCUPATIONAL_TYPES refers to an invalid Flexfield.');
   end if;
   hr_utility.set_location('l_name : ' ||l_name,10);
   return l_name;

end get_occupational_data;
--
-- This function returns the occupational category from the common lookups table.
function get_occupational_category
(
   p_report_date       in per_all_assignments_f.effective_end_date%type,
   p_assignment_id     in per_all_assignments_f.assignment_id%type,
   p_job_id            in per_all_assignments_f.job_id%type,
   p_grade_id          in per_all_assignments_f.grade_id%type,
   p_position_id       in per_all_assignments_f.position_id%type,
   p_business_group_id in per_all_assignments_f.business_group_id%type
)  return varchar2 is
l_cat_name hr_lookups.meaning%type;
begin
-- Check whether we have cached the location of Occupational data
hr_utility.set_location('Entering get_occupational_category', 10);
hr_utility.set_location('p_assignment_id : '||p_assignment_id, 10);
hr_utility.set_location('p_job_id: '||p_job_id, 10);
hr_utility.set_location('p_grade_id: '||p_grade_id, 10);
hr_utility.set_location('p_position_id: '||p_position_id, 10);

   if g_cat_flex is null then
      cache_occupational_location(p_report_date, p_business_group_id);
   end if;
--
      l_cat_name := get_occupational_data
                    (
                       p_type        => 'ZA_WSP_OCCUPATIONAL_CATEGORIES',
                       p_flex        => upper(g_cat_flex),
                       p_segment     => g_cat_segment,
                       p_job_id      => p_job_id,
                       p_grade_id    => p_grade_id,
                       p_position_id => p_position_id
                    );
      return l_cat_name;
--
end get_occupational_category;
--
--
/****************************************************************************
    Name        : archive_code
    Description : Archive person level WSP and ATR related data.
*****************************************************************************/
procedure archive_data ( p_assactid         in  number
                       , p_effective_date   in  date
                       ) is

l_proc              varchar2(50);
l_assignment_id     per_all_assignments_f.assignment_id%type;
l_person_id         per_all_assignments_f.person_id%type;
l_ass_cat_name      hr_lookups.meaning%type;
l_race              per_all_people_f.per_information4%type;
l_sex               per_all_people_f.sex%type;
l_legal_entity_id   number(30);
l_disability        varchar2(30);

begin
--    hr_utility.trace_on(null,'ZAWSP');
    l_proc := g_package || 'archive_code';
    hr_utility.trace ('Entering '||l_proc);
    hr_utility.trace('p_assactid = '|| p_assactid);
    hr_utility.trace('p_effective_date = '|| to_char(p_effective_date, 'DD-MON-YYYY'));

-- Occupation category for current person : Emp Equity report setup
-- pick all persons for whom assgn actn id is created : AM
    Select paaf.person_id
         , paaf.assignment_id
         , perf.per_information4  -- Race
         , perf.sex
         , perf.registered_disabled_flag
         , paei.aei_information7 --legal_entity_id
         , per_za_wsp_archive_pkg.get_occupational_category( p_effective_date
                                    , paaf.assignment_id
                                    , paaf.job_id
                                    , paaf.grade_id
                                    , paaf.position_id
                                    , paaf.business_group_id)
       Into l_person_id
          , l_assignment_id
          , l_race
          , l_sex
          , l_disability
          , l_legal_entity_id
          , l_ass_cat_name
       From per_all_assignments_f  paaf
          , pay_assignment_actions paa
          , per_all_people_f       perf
          , per_assignment_extra_info paei
      Where paa.assignment_action_id = p_assactid
        and paa.assignment_id        = paaf.assignment_id
        and paaf.person_id           = perf.person_id
        and p_effective_date   between perf.effective_start_date
                                   and perf.effective_end_date
        and p_effective_date   between paaf.effective_start_date
                                   and paaf.effective_end_date
        and paaf.assignment_id = paei.assignment_id
        and paei.aei_information_category = 'ZA_SPECIFIC_INFO';

		hr_utility.set_location('g_wsp_certifications_tab.COUNT 	: '||g_wsp_certifications_tab.COUNT ,10);
    if l_ass_cat_name is not null then
    -- Archive WSP data
    archive_wsp_data(p_assactid, l_person_id, l_assignment_id, l_race, l_sex, l_ass_cat_name, l_legal_entity_id, l_disability);

    -- Archive ATR data
    archive_atr_data(p_assactid, l_person_id, l_assignment_id, l_race, l_sex, l_ass_cat_name, l_legal_entity_id, l_disability);
    end if;

    --Reset the pl/sql tables
    --hr_utility.trace ('Flush data from all the pl/sql tables ');
    --reset_tables;
    --
    hr_utility.trace('Leaving '||l_proc);
 --  hr_utility.trace_off;
end archive_data;
--

end per_za_wsp_archive_pkg;
--


/
