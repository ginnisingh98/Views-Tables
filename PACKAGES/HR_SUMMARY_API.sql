--------------------------------------------------------
--  DDL for Package HR_SUMMARY_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUMMARY_API" AUTHID CURRENT_USER as
/* $Header: hrsumapi.pkh 115.4 2002/11/26 10:37:14 sfmorris noship $ */
procedure lck (p_id_value                  in     number
              ,p_object_version_number     in     number );

procedure row_data (p_business_group_id in number,
                    p_type              in varchar2,
                    p_text_value1       in varchar2 default null,
                    p_text_value2       in varchar2 default null,
                    p_fk_value1         in number   default null,
                    p_fk_value2         in number   default null,
                    l_id_value          out nocopy number,
                    l_ovn               out nocopy number);

function get_id (p_name in varchar2
                ,p_type in varchar2
                ,p_business_group_id in number) return number;
pragma restrict_references (get_id, WNPS, WNDS);

function get_itu_id (p_template_name     in varchar2
                    ,p_item_type_name    in varchar2
                    ,p_itu_name          in varchar2
                    ,p_business_group_id in number) return number;
pragma restrict_references (get_itu_id, WNPS, WNDS);

function get_itu_id (p_template_name     in varchar2
                    ,p_sequence_number   in number
                    ,p_business_group_id in number) return number;
pragma restrict_references (get_itu_id, WNPS, WNDS);

function get_vkt_id (p_key_type_name     in varchar2
                    ,p_item_type_name    in varchar2
                    ,p_business_group_id in number) return number;
pragma restrict_references (get_vkt_id, WNPS, WNDS);

function get_ru_id (p_restriction_name  in varchar2
                   ,p_item_type_name    in varchar2
                   ,p_business_group_id in number) return number;
pragma restrict_references (get_ru_id, WNPS, WNDS);

function get_rv_id (p_template          in varchar2
                   ,p_item              in varchar2
                   ,p_restriction       in varchar2
                   ,p_itu_name          in varchar2
                   ,p_business_group_id in number) return number;
pragma restrict_references (get_rv_id, WNPS, WNDS);

function get_rv_id (p_template          in varchar2
                   ,p_item              in varchar2
                   ,p_restriction       in varchar2
                   ,p_itu_seq_num       in number
                   ,p_business_group_id in number) return number;
pragma restrict_references (get_rv_id, WNPS, WNDS);

procedure create_item_type (p_item_type_id           out nocopy number
                           ,p_business_group_id      in number
                           ,p_object_version_number  out nocopy number
                           ,p_name                   in varchar2
                           ,p_units                  in varchar2
                           ,p_datatype               in varchar2
                           ,p_count_clause1          in varchar2
                           ,p_count_clause2          in varchar2
                           ,p_where_clause           in varchar2
                           ,p_seeded_data            in varchar2);

procedure create_key_type  (p_key_type_id           out nocopy number
                           ,p_business_group_id     in number
                           ,p_object_version_number out nocopy number
                           ,p_name                  in varchar2
                           ,p_key_function          in varchar2
                           ,p_seeded_data           in varchar2);

procedure create_key_value (p_key_value_id          out nocopy number
                           ,p_business_group_id     in number
                           ,p_object_version_number out nocopy number
                           ,p_key_type_id           in number
                           ,p_item_value_id         in number
                           ,p_name                  in varchar2 );

procedure create_item_value (p_item_value_id          out nocopy number
                            ,p_business_group_id      in number
                            ,p_object_version_number  out nocopy number
                            ,p_process_run_id         in number
                            ,p_item_type_usage_id     in number
                            ,p_textvalue              in varchar2
                            ,p_numvalue1              in number
                            ,p_numvalue2              in number
                            ,p_datevalue              in date );

procedure create_valid_restriction (p_valid_restriction_id  out nocopy number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number out nocopy number
                                   ,p_item_type_id          in number
                                   ,p_restriction_type_id   in number
                                   ,p_seeded_data           in varchar2);

procedure create_restriction_type  (p_restriction_type_id  out nocopy number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number out nocopy number
                                   ,p_name                  in varchar2
                                   ,p_data_type             in varchar2
                                   ,p_restriction_clause    in varchar2
                                   ,p_restriction_sql       in varchar2
                                   ,p_seeded_data           in varchar2);

procedure create_restriction_usage (p_restriction_usage_id    out nocopy number
                                   ,p_business_group_id       in number
                                   ,p_object_version_number   out nocopy number
                                   ,p_item_type_usage_id      in number
                                   ,p_valid_restriction_id    in number
                                   ,p_restriction_type        in varchar2
                                   ,p_seeded_data             in varchar2);

procedure create_restriction_value ( p_restriction_value_id  out nocopy number
                                    ,p_business_group_id     in number
                                    ,p_object_version_number out nocopy number
                                    ,p_restriction_usage_id  in number
                                    ,p_value                 in varchar2
                                    ,p_seeded_data           in varchar2);

procedure create_item_type_usage ( p_item_type_usage_id     out nocopy number
                                  ,p_business_group_id      in number
                                  ,p_object_version_number  out nocopy number
                                  ,p_sequence_number        in number
                                  ,p_name                   in varchar2
                                  ,p_template_id            in number
                                  ,p_item_type_id           in number
                                  ,p_seeded_data            in varchar2);

procedure create_valid_key_type (p_valid_key_type_id      out nocopy number
                                ,p_business_group_id      in number
                                ,p_object_version_number  out nocopy number
                                ,p_item_type_id           in number
                                ,p_key_type_id            in number
                                ,p_seeded_data            in varchar2);

procedure create_key_type_usage (p_key_type_usage_id      out nocopy number
                                ,p_business_group_id      in number
                                ,p_object_version_number  out nocopy number
                                ,p_item_type_usage_id     in number
                                ,p_valid_key_type_id      in number
                                ,p_seeded_data            in varchar2);

procedure create_template (p_template_id            out nocopy number
                          ,p_business_group_id      in number
                          ,p_object_version_number  out nocopy number
                          ,p_name                   in varchar2
                          ,p_seeded_data            in varchar2);

procedure create_process_run (p_process_run_id         out nocopy number
                             ,p_business_group_id      in  number
                             ,p_object_version_number  out nocopy number
                             ,p_name                   in  varchar2
                             ,p_template_id            in  varchar2
                             ,p_process_type           in  varchar2);

procedure create_parameter (p_parameter_id           out nocopy number
                           ,p_business_group_id      in  number
                           ,p_object_version_number  out nocopy number
                           ,p_process_run_id         in  number
                           ,p_name                   in  varchar2
                           ,p_value                  in  varchar2);

/*@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*/

procedure delete_hr_summary (p_validate              in boolean  default false
                            ,p_id_value              in number
                            ,p_object_version_number in number);


end hr_summary_api;

 

/
