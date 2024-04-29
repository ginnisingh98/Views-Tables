--------------------------------------------------------
--  DDL for Package HR_SUMMARY_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_SUMMARY_API2" AUTHID CURRENT_USER as
/* $Header: hrsumapi.pkh 115.4 2002/11/26 10:37:14 sfmorris noship $ */
--
procedure update_item_type (p_item_type_id           in number
                           ,p_business_group_id      in number
                           ,p_object_version_number  in out nocopy number
                           ,p_name                   in varchar2
                           ,p_units                  in varchar2
                           ,p_datatype               in varchar2
                           ,p_count_clause1          in varchar2
                           ,p_count_clause2          in varchar2
                           ,p_where_clause           in varchar2
                           ,p_seeded_data            in varchar2
                           ,p_allowed                in varchar2 default 'N');

procedure update_key_type  (p_key_type_id           in number
                           ,p_business_group_id     in number
                           ,p_object_version_number in out nocopy number
                           ,p_name                  in varchar2
                           ,p_key_function          in varchar2
                           ,p_seeded_data           in varchar2
                           ,p_allowed               in varchar2 default 'N');

procedure update_key_value (p_key_value_id          in number
                           ,p_business_group_id     in number
                           ,p_object_version_number in  out nocopy number
                           ,p_key_type_id           in number
                           ,p_item_value_id         in number
                           ,p_name                  in varchar2 );

procedure update_item_value (p_item_value_id          in number
                            ,p_business_group_id      in number
                            ,p_object_version_number  in out nocopy number
                            ,p_process_run_id         in number
                            ,p_item_type_usage_id     in number
                            ,p_textvalue              in varchar2
                            ,p_numvalue1              in number
                            ,p_numvalue2              in number
                            ,p_datevalue              in date );

procedure update_valid_restriction (p_valid_restriction_id  in number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number in out nocopy number
                                   ,p_item_type_id          in number
                                   ,p_restriction_type_id   in number
                                   ,p_seeded_data           in varchar2
                                   ,p_allowed               in varchar2 default 'N');

procedure update_restriction_type  (p_restriction_type_id   in number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number in out nocopy number
                                   ,p_name                  in varchar2
                                   ,p_data_type             in varchar2
                                   ,p_restriction_clause    in varchar2
                                   ,p_restriction_sql       in varchar2
                                   ,p_seeded_data           in varchar2
                                   ,p_allowed               in varchar2 default 'N');

procedure update_restriction_usage (p_restriction_usage_id    in number
                                   ,p_business_group_id       in number
                                   ,p_object_version_number   in out nocopy number
                                   ,p_item_type_usage_id      in number
                                   ,p_valid_restriction_id    in number
                                   ,p_restriction_type        in varchar2
                                   ,p_seeded_data             in varchar2
                                   ,p_allowed                 in varchar2 default 'N');

procedure update_restriction_value ( p_restriction_value_id  in number
                                    ,p_business_group_id     in number
                                    ,p_object_version_number in out nocopy number
                                    ,p_restriction_usage_id  in number
                                    ,p_value                 in varchar2
                                    ,p_seeded_data           in varchar2
                                    ,p_allowed               in varchar2 default 'N');

procedure update_item_type_usage ( p_item_type_usage_id     in number
                                  ,p_business_group_id      in number
                                  ,p_object_version_number  in out nocopy number
                                  ,p_sequence_number        in number
                                  ,p_name                   in varchar2
                                  ,p_template_id            in number
                                  ,p_item_type_id           in number
                                  ,p_seeded_data            in varchar2
                                  ,p_allowed                in varchar2 default 'N');

procedure update_valid_key_type (p_valid_key_type_id      in number
                                ,p_business_group_id      in number
                                ,p_object_version_number  in out nocopy number
                                ,p_item_type_id           in number
                                ,p_key_type_id            in number
                                ,p_seeded_data            in varchar2
                                ,p_allowed                in varchar2 default 'N');

procedure update_key_type_usage (p_key_type_usage_id      in number
                                ,p_business_group_id      in number
                                ,p_object_version_number  in out nocopy number
                                ,p_item_type_usage_id     in number
                                ,p_valid_key_type_id      in number
                                ,p_seeded_data            in varchar2
                                ,p_allowed                in varchar2 default 'N');

procedure update_template (p_template_id            in number
                          ,p_business_group_id      in number
                          ,p_object_version_number  in out nocopy number
                          ,p_name                   in varchar2
                          ,p_seeded_data            in varchar2
                          ,p_allowed                in varchar2 default 'N');

procedure update_process_run (p_process_run_id         in  number
                             ,p_business_group_id      in  number
                             ,p_object_version_number  in  out nocopy number
                             ,p_name                   in  varchar2
                             ,p_template_id            in  varchar2
                             ,p_process_type           in  varchar2);

procedure update_parameter (p_parameter_id           in  number
                           ,p_business_group_id      in  number
                           ,p_object_version_number  in  out nocopy number
                           ,p_process_run_id         in  number
                           ,p_name                   in  varchar2
                           ,p_value                  in  varchar2);
--
end hr_summary_api2;

 

/
