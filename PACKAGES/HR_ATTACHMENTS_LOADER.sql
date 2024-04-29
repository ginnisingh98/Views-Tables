--------------------------------------------------------
--  DDL for Package HR_ATTACHMENTS_LOADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_ATTACHMENTS_LOADER" AUTHID CURRENT_USER as
/* $Header: hratload.pkh 115.1 99/10/12 07:04:55 porting ship $ */
--
procedure cre_or_sel_att_form_function(p_function_name   IN     VARCHAR2
                                      ,p_function_type       IN     VARCHAR2
                                      ,p_attachment_function_id OUT NUMBER
                                      ,p_application_id         OUT NUMBER);
--
procedure associate_category(p_attachment_function_id IN NUMBER
                            ,p_category_name          IN VARCHAR2);
--
procedure create_or_update_block
          (p_attachment_function_id  IN     NUMBER
          ,p_block_name              IN     VARCHAR2
          ,p_query_flag              IN     VARCHAR2 default 'N'
          ,p_security_type           IN     NUMBER   default 4
          ,p_org_context_field       IN     VARCHAR2 default null
          ,p_set_of_books_context_field  IN VARCHAR2 default null
          ,p_business_unit_context_field IN VARCHAR2 default null
          ,p_context1_field          IN     VARCHAR2 default null
          ,p_context2_field          IN     VARCHAR2 default null
          ,p_context3_field          IN     VARCHAR2 default null
          ,p_attachment_blk_id          OUT NUMBER);
--
procedure create_or_select_entity
          (p_data_object_code IN     VARCHAR2
          ,p_entity_user_name IN     VARCHAR2 default null
          ,p_language_code    IN     VARCHAR2 default null
          ,p_application_id   IN     NUMBER   default null
          ,p_table_name       IN     VARCHAR2 default null
          ,p_entity_name      IN     VARCHAR2 default null
          ,p_pk1_column       IN     VARCHAR2 default null
          ,p_pk2_column       IN     VARCHAR2 default null
          ,p_pk3_column       IN     VARCHAR2 default null
          ,p_pk4_column       IN     VARCHAR2 default null
          ,p_pk5_column       IN     VARCHAR2 default null
          ,p_document_entity_id  OUT NUMBER);
--
procedure attach_entity
          (p_attachment_blk_id      IN     NUMBER
          ,p_data_object_code       IN     VARCHAR2
          ,p_display_method         IN     VARCHAR2 default 'M'
          ,p_include_in_indicator_flag IN  VARCHAR2 default 'Y'
          ,p_indicator_in_view_flag IN     VARCHAR2 default 'N'
          ,p_pk1_field              IN     VARCHAR2 default null
          ,p_pk2_field              IN     VARCHAR2 default null
          ,p_pk3_field              IN     VARCHAR2 default null
          ,p_pk4_field              IN     VARCHAR2 default null
          ,p_pk5_field              IN     VARCHAR2 default null
          ,p_sql_statement          IN     VARCHAR2 default null
          ,p_query_permission_type  IN     VARCHAR2 default 'Y'
          ,p_insert_permission_type IN     VARCHAR2 default 'Y'
          ,p_update_permission_type IN     VARCHAR2 default 'Y'
          ,p_delete_permission_type IN     VARCHAR2 default 'Y'
          ,p_condition_field        IN     VARCHAR2 default null
          ,p_condition_operator     IN     VARCHAR2 default null
          ,p_condition_value1       IN     VARCHAR2 default null
          ,p_condition_value2       IN     VARCHAR2 default null
          ,p_attachment_blk_entity_id  OUT NUMBER);
--
end HR_ATTACHMENTS_LOADER;

 

/
