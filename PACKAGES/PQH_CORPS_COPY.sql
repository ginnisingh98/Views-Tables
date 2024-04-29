--------------------------------------------------------
--  DDL for Package PQH_CORPS_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PQH_CORPS_COPY" AUTHID CURRENT_USER as
/* $Header: pqcpdcpy.pkh 115.3 2003/11/26 02:33:33 kgowripe noship $ */
procedure copy_corps(p_corps_definition_id     in number,
                     p_effective_date          in date,
                     p_name                    in varchar2,
                     p_nature_cd               in varchar2,
                     p_business_group_id       in number default null,
                     p_copy_grades             in varchar2 default 'Y',
                     p_copy_docs               in varchar2 default 'Y',
                     p_copy_exams              in varchar2 default 'Y',
                     p_copy_training           in varchar2 default 'Y',
                     p_copy_organizations      in varchar2 default 'Y',
                     p_copy_others             in varchar2 default 'Y',
                     p_copy_career             in varchar2 default 'Y',
                     p_filere1_cd              in varchar2 default 'NO',
                     p_filere2_cd              in varchar2 default null,
                     p_filere3_cd              in varchar2 default null,
                     p_filere4_cd              in varchar2 default null,
                     p_filere5_cd              in varchar2 default null,
                     p_filere6_cd              in varchar2 default null,
                     p_filere7_cd              in varchar2 default null,
                     p_filere8_cd              in varchar2 default null,
                     p_filere9_cd              in varchar2 default null,
                     p_filere10_cd             in varchar2 default null);

function get_step_name(p_grade_step_id in number) return varchar2 ;

function get_grade_name(p_grade_step_id in number) return varchar2 ;

function get_grade_id(p_grade_step_id in number) return number ;

function get_hier_ver return number ;

procedure insert_career_path(p_effective_date           in date,
                             p_hierarchy_version_id     in number,
                             p_business_group_id        in number,
                             p_from_corps_definition_id in number,
                             p_starting_grade_step_id   in number,
                             p_ending_grade_step_id     in number,
                             p_to_corps_definition_id   in number,
                             p_from_seniority           in number default null,
                             p_from_seniority_uom       in varchar2 default null,
                             p_to_seniority             in number default null,
                             p_to_seniority_uom         in varchar2 default null,
                             p_node_id                  out nocopy number,
                             p_object_version_number    out nocopy number) ;

procedure update_career_path(p_effective_date           in date,
                             p_node_id                  in number,
                             p_from_corps_definition_id in number   default null,
                             p_starting_grade_step_id   in number   default null,
                             p_ending_grade_step_id     in number   default null,
                             p_to_corps_definition_id   in number   default null,
                             p_from_seniority           in number   default null,
                             p_from_seniority_uom       in varchar2 default null,
                             p_to_seniority             in number   default null,
                             p_to_seniority_uom         in varchar2 default null,
                             p_object_version_number    in out nocopy number) ;

procedure delete_career_path(p_node_id               in number,
                             p_object_version_number in number) ;

--
procedure add_corps_fileres(p_corps_definition_id     in number,
                            p_effective_date          in date,
                            p_filere1_cd              in varchar2 ,
                            p_filere2_cd              in varchar2 default null,
                            p_filere3_cd              in varchar2 default null);
--
procedure delete_corps_fileres(p_corps_definition_id     in number,
                               p_filere_cd              in varchar2 default null);
--
procedure delete_corps(p_corps_definition_id     in number);
--
procedure delete_corps_grade(p_corps_definition_id     in number,
                             p_grade_id                in number);
--
end pqh_corps_copy;

 

/
