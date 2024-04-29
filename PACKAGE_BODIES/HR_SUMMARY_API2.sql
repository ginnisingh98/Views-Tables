--------------------------------------------------------
--  DDL for Package Body HR_SUMMARY_API2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_SUMMARY_API2" as
/* $Header: hrsumapi.pkb 115.5 2002/11/26 10:30:14 sfmorris noship $ */
--
procedure update_item_type (p_item_type_id           in number
                           ,p_business_group_id      in number
                           ,p_object_version_number  in out  nocopy number
                           ,p_name                   in varchar2
                           ,p_units                  in varchar2
                           ,p_datatype               in varchar2
                           ,p_count_clause1          in varchar2
                           ,p_count_clause2          in varchar2
                           ,p_where_clause           in varchar2
                           ,p_seeded_data            in varchar2
                           ,p_allowed                in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_item_type', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'ITEM_TYPE'
               ,p_id_value              => p_item_type_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_text_value1           => p_name
               ,p_text_value2           => p_units
               ,p_text_value3           => p_datatype
               ,p_text_value4           => p_count_clause1
               ,p_text_value5           => p_count_clause2
               ,p_text_value6           => p_where_clause
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_item_type', 20);
--
end update_item_type;
-----------------
procedure update_key_type  (p_key_type_id           in number
                           ,p_business_group_id     in number
                           ,p_object_version_number in out  nocopy number
                           ,p_name                  in varchar2
                           ,p_key_function          in varchar2
                           ,p_seeded_data           in varchar2
                           ,p_allowed               in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_key_type', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'KEY_TYPE'
               ,p_id_value              => p_key_type_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_text_value1           => p_name
               ,p_text_value6           => p_key_function
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_key_type', 20);
--
end update_key_type;
-----------------
procedure update_key_value (p_key_value_id          in number
                           ,p_business_group_id     in number
                           ,p_object_version_number in out  nocopy number
                           ,p_key_type_id           in number
                           ,p_item_value_id         in number
                           ,p_name                  in varchar2 ) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_key_value', 10);
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'KEY_VALUE'
               ,p_id_value              => p_key_value_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_key_type_id
               ,p_fk_value2             => p_item_value_id
               ,p_text_value1           => p_name);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_key_value', 20);
--
end update_key_value;
-----------------
procedure update_item_value (p_item_value_id          in number
                            ,p_business_group_id      in number
                            ,p_object_version_number  in out  nocopy number
                            ,p_process_run_id         in number
                            ,p_item_type_usage_id     in number
                            ,p_textvalue              in varchar2
                            ,p_numvalue1              in number
                            ,p_numvalue2              in number
                            ,p_datevalue              in date ) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_item_value', 10);
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'ITEM_VALUE'
               ,p_id_value              => p_item_value_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_process_run_id
               ,p_fk_value2             => p_item_type_usage_id
               ,p_text_value1           => p_textvalue
               ,p_num_value1            => p_numvalue1
               ,p_num_value2            => p_numvalue2
               ,p_date_value1           => p_datevalue);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_item_value', 20);
--
end update_item_value;
-----------------
procedure update_valid_restriction (p_valid_restriction_id  in number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number in out  nocopy number
                                   ,p_item_type_id          in number
                                   ,p_restriction_type_id   in number
                                   ,p_seeded_data           in varchar2
                                   ,p_allowed               in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_valid_restriction', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'VALID_RESTRICTION'
               ,p_id_value              => p_valid_restriction_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_item_type_id
               ,p_fk_value2             => p_restriction_type_id
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_valid_restriction', 20);
--
end update_valid_restriction;
-----------------
procedure update_restriction_type  (p_restriction_type_id   in number
                                   ,p_business_group_id     in number
                                   ,p_object_version_number in out  nocopy number
                                   ,p_name                  in varchar2
                                   ,p_data_type             in varchar2
                                   ,p_restriction_clause    in varchar2
                                   ,p_restriction_sql       in varchar2
                                   ,p_seeded_data           in varchar2
                                   ,p_allowed               in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_restriction_type', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'RESTRICTION_TYPE'
               ,p_id_value              => p_restriction_type_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_text_value1           => p_name
               ,p_text_value2           => p_data_type
               ,p_text_value3           => p_restriction_clause
               ,p_text_value4           => p_restriction_sql
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_restriction_type', 20);
--
end update_restriction_type;
-----------------
procedure update_restriction_usage (p_restriction_usage_id    in number
                                   ,p_business_group_id       in number
                                   ,p_object_version_number   in out  nocopy number
                                   ,p_item_type_usage_id      in number
                                   ,p_valid_restriction_id    in number
                                   ,p_restriction_type        in varchar2
                                   ,p_seeded_data             in varchar2
                                   ,p_allowed                 in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_restriction_usage', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'RESTRICTION_USAGE'
               ,p_id_value              => p_restriction_usage_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_item_type_usage_id
               ,p_fk_value2             => p_valid_restriction_id
               ,p_text_value1           => p_restriction_type
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_restriction_usage', 20);
--
end update_restriction_usage;
-----------------
procedure update_restriction_value ( p_restriction_value_id  in number
                                    ,p_business_group_id     in number
                                    ,p_object_version_number in out  nocopy number
                                    ,p_restriction_usage_id  in number
                                    ,p_value                 in varchar2
                                    ,p_seeded_data           in varchar2
                                    ,p_allowed               in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_restriction_value', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'RESTRICTION_VALUE'
               ,p_id_value              => p_restriction_value_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_restriction_usage_id
               ,p_text_value1           => p_value);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_restriction_value', 20);
--
end update_restriction_value;
-----------------
procedure update_item_type_usage ( p_item_type_usage_id     in number
                                  ,p_business_group_id      in number
                                  ,p_object_version_number  in out  nocopy number
                                  ,p_sequence_number        in number
                                  ,p_name                   in varchar2
                                  ,p_template_id            in number
                                  ,p_item_type_id           in number
                                  ,p_seeded_data            in varchar2
                                  ,p_allowed                in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_item_type_usage', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'ITEM_TYPE_USAGE'
               ,p_id_value              => p_item_type_usage_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_num_value1            => p_sequence_number
               ,p_text_value1           => p_name
               ,p_fk_value1             => p_template_id
               ,p_fk_value2             => p_item_type_id
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_item_type_usage', 20);
--
end update_item_type_usage;
-----------------
procedure update_valid_key_type (p_valid_key_type_id      in number
                                ,p_business_group_id      in number
                                ,p_object_version_number  in out  nocopy number
                                ,p_item_type_id           in number
                                ,p_key_type_id            in number
                                ,p_seeded_data            in varchar2
                                ,p_allowed                in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_valid_key_type', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'VALID_KEY_TYPE'
               ,p_id_value              => p_valid_key_type_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_item_type_id
               ,p_fk_value2             => p_key_type_id
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Entering: hr_summary_api2.update_valid_key_type', 20);
--
end update_valid_key_type;
-----------------
procedure update_key_type_usage (p_key_type_usage_id      in number
                                ,p_business_group_id      in number
                                ,p_object_version_number  in out  nocopy number
                                ,p_item_type_usage_id     in number
                                ,p_valid_key_type_id      in number
                                ,p_seeded_data            in varchar2
                                ,p_allowed                in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_key_type_usage', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'KEY_TYPE_USAGE'
               ,p_id_value              => p_key_type_usage_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_item_type_usage_id
               ,p_fk_value2             => p_valid_key_type_id
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Entering: hr_summary_api2.update_key_type_usage', 20);
--
end update_key_type_usage;
-----------------
procedure update_template (p_template_id            in number
                          ,p_business_group_id      in number
                          ,p_object_version_number  in out  nocopy number
                          ,p_name                   in varchar2
                          ,p_seeded_data            in varchar2
                          ,p_allowed                in varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_template', 10);
--
if p_seeded_data = 'Y' then
   if p_allowed = 'Y' then
      null;
   else
      fnd_message.set_name('PER','PER_74882_RECORD_PROTECT');
      fnd_message.raise_error;
   end if;
end if;
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'TEMPLATE'
               ,p_id_value              => p_template_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_text_value1           => p_name
               ,p_text_value7           => p_seeded_data);
--
hr_utility.set_location('Entering: hr_summary_api2.update_template', 20);
--
end update_template;
-----------------
procedure update_process_run (p_process_run_id         in  number
                             ,p_business_group_id      in  number
                             ,p_object_version_number  in  out  nocopy number
                             ,p_name                   in  varchar2
                             ,p_template_id            in  varchar2
                             ,p_process_type           in  varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_process_run', 10);
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'PROCESS_RUN'
               ,p_id_value              => p_process_run_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_text_value2           => p_name
               ,p_fk_value1             => p_template_id
               ,p_text_value1           => p_process_type);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_process_run', 20);
--
end update_process_run;
-----------------
procedure update_parameter (p_parameter_id           in  number
                           ,p_business_group_id      in  number
                           ,p_object_version_number  in  out  nocopy number
                           ,p_process_run_id         in  number
                           ,p_name                   in  varchar2
                           ,p_value                  in  varchar2) is
begin
--
hr_utility.set_location('Entering: hr_summary_api2.update_parameter', 10);
--
/* call row handler package with correct parameters */
per_bil_upd.upd(p_type                  => 'PARAMETER'
               ,p_id_value              => p_parameter_id
               ,p_business_group_id     => p_business_group_id
               ,p_object_version_number => p_object_version_number
               ,p_fk_value1             => p_process_run_id
               ,p_text_value1           => p_name
               ,p_text_value6           => p_value);
--
hr_utility.set_location('Leaving: hr_summary_api2.update_parameter', 20);
--
end update_parameter;
--
end hr_summary_api2;

/
