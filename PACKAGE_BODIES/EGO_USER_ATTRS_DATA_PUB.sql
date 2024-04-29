--------------------------------------------------------
--  DDL for Package Body EGO_USER_ATTRS_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_USER_ATTRS_DATA_PUB" AS
/* $Header: EGOPEFBB.pls 120.4.12010000.6 2009/12/07 08:43:30 iyin ship $ */


G_ADD_ERRORS_TO_FND_STACK       VARCHAR2(1) := 'Y';

                          ----------------
                          -- Procedures --
                          ----------------

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

  BEGIN

    EGO_USER_ATTRS_DATA_PVT.Process_User_Attrs_Data
    (
        p_api_version                   => p_api_version
       ,p_object_name                   => p_object_name
       ,p_attributes_row_table          => p_attributes_row_table
       ,p_attributes_data_table         => p_attributes_data_table
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_user_privileges_on_object     => p_user_privileges_on_object
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler            => p_init_error_handler
       ,p_write_to_concurrent_log       => p_write_to_concurrent_log
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_log_errors                    => p_log_errors
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,x_failed_row_id_list            => x_failed_row_id_list
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END Process_User_Attrs_Data;

/* Overload method with additional parameters x_extension_id, x_mode */

PROCEDURE Process_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_extension_id                  OUT NOCOPY NUMBER
       ,x_mode                          OUT NOCOPY VARCHAR2
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

    -------------------------------------------------------------------------
    -- COM item uda validations
    -- trudave
    -------------------------------------------------------------------------
    -- Telco profile value
    /*profile_value varchar2(1) := fnd_profile.value('EGO_ENABLE_P4T');

    -- attribute group
    l_com_attr_group_type VARCHAR2(40);
    l_com_attr_group_name VARCHAR2(30) := NULL;
    l_com_attr_group_id NUMBER;
    l_attributes_row_table EGO_USER_ATTR_ROW_TABLE;

    -- attribute
    l_com_attr_int_name VARCHAR2(30);
    l_attributes_data_table  EGO_USER_ATTR_DATA_TABLE;
    l_curr_data_element      EGO_USER_ATTR_DATA_OBJ;

    -- pk
    l_pk_column_name_value_pairs       EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_curr_pk_col_name_val_element      EGO_COL_NAME_VALUE_PAIR_OBJ;
    l_revision_id NUMBER;

    -- catalog category
    l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
    l_curr_class_cd_val_element         EGO_COL_NAME_VALUE_PAIR_OBJ;

    -- declarations
    l_row_identifier NUMBER;
    l_data_row_identifier NUMBER;

    -- output
    l_telco_return_status VARCHAR2(1);
    l_error_messages EGO_COL_NAME_VALUE_PAIR_ARRAY := EGO_COL_NAME_VALUE_PAIR_ARRAY();
    l_error_col_name_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY :=EGO_COL_NAME_VALUE_PAIR_ARRAY();
    l_error_element EGO_COL_NAME_VALUE_PAIR_OBJ;


    l_next_attr_group BOOLEAN := FALSE;
    l_validate_data BOOLEAN := FALSE;
    l_mark_error_record BOOLEAN := FALSE;


    l_error_attr_name  VARCHAR2(1000);
    l_error_attr_group_name VARCHAR2(30);
    l_name VARCHAR2(30);
    l_err_value VARCHAR2(150);
    l_error_message VARCHAR2(30);
    l_error_row_identifier NUMBER;
    l_error_message_name     VARCHAR2(30);
    l_token_table            ERROR_HANDLER.Token_Tbl_Type;
    l_error_occured 	     EXCEPTION;

    message_list  ERROR_HANDLER.Error_Tbl_Type; */

  BEGIN

    --------------------------------------------------------------------------
    -- Processing PIM Telco Item Attribute Groups - Attributes starts
    -- trudave
    --------------------------------------------------------------------------
    /*l_telco_return_status := 'S';

    IF (profile_value = 'Y') THEN
      IF (p_object_name = 'EGO_ITEM') THEN
        l_attributes_row_table := p_attributes_row_table;
	l_pk_column_name_value_pairs := p_pk_column_name_value_pairs;
       	ERROR_HANDLER.Initialize;
        FOR i IN p_attributes_row_table.FIRST .. p_attributes_row_table.LAST
        LOOP
          l_row_identifier := p_attributes_row_table(i).ROW_IDENTIFIER;
          l_com_attr_group_type := p_attributes_row_table(i).ATTR_GROUP_TYPE;
          l_com_attr_group_name := p_attributes_row_table(i).ATTR_GROUP_NAME;
          l_com_attr_group_id := p_attributes_row_table(i).ATTR_GROUP_ID;
	  l_revision_id := p_attributes_row_table(i).DATA_LEVEL_1;
          l_pk_column_name_value_pairs.EXTEND();
          l_pk_column_name_value_pairs(l_pk_column_name_value_pairs.LAST) := EGO_COL_NAME_VALUE_PAIR_OBJ( 'REVISION_ID', l_revision_id);

          FOR j IN p_attributes_data_table.FIRST .. p_attributes_data_table.LAST
          LOOP
	    l_data_row_identifier := p_attributes_data_table(j).ROW_IDENTIFIER;
	    IF (l_row_identifier = l_data_row_identifier) THEN
              l_curr_data_element := p_attributes_data_table(j);
              IF ( l_attributes_data_table IS NULL) THEN
	        l_attributes_data_table := EGO_USER_ATTR_DATA_TABLE();
              END IF;
              l_attributes_data_table.EXTEND();
              l_attributes_data_table(l_attributes_data_table.LAST) := l_curr_data_element;
            END IF;
          END LOOP;
          IF (EGO_COM_ATTR_VALIDATION.Is_Attribute_Group_Telco(l_com_attr_group_name,l_com_attr_group_type)) THEN
            EGO_COM_ATTR_VALIDATION.Validate_Attributes (
                        p_attr_group_type                  => l_com_attr_group_type
                       ,p_attr_group_name                  => l_com_attr_group_name
                       ,p_attr_group_id                    => l_com_attr_group_id
                       ,p_attr_name_value_pairs            => l_attributes_data_table
                       ,p_pk_column_name_value_pairs       => l_pk_column_name_value_pairs
                       ,x_return_status                    => l_telco_return_status
                       ,x_error_messages                   => l_error_messages
	               );
          END IF;

	  IF (l_telco_return_status = 'E') THEN

            l_error_attr_name := NULL;
            l_error_attr_group_name := NULL;

            FOR i IN l_error_messages.FIRST .. l_error_messages.LAST
	    LOOP
              l_name := l_error_messages(i).NAME;
	      l_err_value := l_error_messages(i).VALUE;
	      l_error_row_identifier := l_row_identifier;
	      IF (l_name = 'ATTR_GROUP_NAME') THEN
	        l_error_attr_group_name := l_err_value;
              END IF;
	      IF (l_name = 'ERROR_MESSAGE_NAME') THEN
	        l_error_message := l_err_value;
              END IF;
	      IF (l_name = 'ATTR_INT_NAME') THEN
	        l_error_attr_name := l_err_value;
	        l_mark_error_record := TRUE;
              END IF;

              IF (l_mark_error_record) THEN

	        l_token_table(1).TOKEN_NAME := 'ATTR_GROUP_NAME';
                l_token_table(1).TOKEN_VALUE := l_error_attr_group_name;
                l_error_message_name := l_error_message;

                ERROR_HANDLER.Add_Error_Message(
                   p_message_name      => l_error_message_name
                  ,p_application_id    => 'EGO'
                  ,p_token_tbl         => l_token_table
                  ,p_message_type      => FND_API.G_RET_STS_ERROR
                  ,p_row_identifier    => l_error_row_identifier
                  ,p_entity_id         => p_entity_id -- G_ENTITY_ID
                  ,p_entity_index      => p_entity_index
                  ,p_entity_code       => p_entity_code -- G_ENTITY_CODE
                  ,p_addto_fnd_stack   => G_ADD_ERRORS_TO_FND_STACK
                  );
                l_token_table.DELETE();
              END IF; -- if error record marked
            END LOOP; -- loop l_error_messages
          END IF; -- if l_telco_return_status
        END LOOP; -- loop for attribute groups objects for COM item uda ends

        x_msg_count := ERROR_HANDLER.Get_Message_Count();

      END IF; -- if object_name - EGO_ITEM -ends

    END IF; -- if P4T profile option ends

    -- Processing PIM Telco Item Attribute Groups - Attributes ends
    IF l_telco_return_status = 'S' THEN */

      EGO_USER_ATTRS_DATA_PVT.Process_User_Attrs_Data
      (
        p_api_version                   => p_api_version
       ,p_object_name                   => p_object_name
       ,p_attributes_row_table          => p_attributes_row_table
       ,p_attributes_data_table         => p_attributes_data_table
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_user_privileges_on_object     => p_user_privileges_on_object
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler            => p_init_error_handler
       ,p_write_to_concurrent_log       => p_write_to_concurrent_log
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_log_errors                    => p_log_errors
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,x_extension_id                  => x_extension_id
       ,x_mode                          => x_mode
       ,x_failed_row_id_list            => x_failed_row_id_list
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
      );
    /*ELSE
      x_return_status := 'E';
    END IF; */

END Process_User_Attrs_Data;

----------------------------------------------------------------------


PROCEDURE Get_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_user_privileges_on_object     IN   EGO_VARCHAR_TBL_TYPE DEFAULT NULL
       ,p_entity_id                     IN   VARCHAR2   DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_attributes_row_table          OUT NOCOPY EGO_USER_ATTR_ROW_TABLE
       ,x_attributes_data_table         OUT NOCOPY EGO_USER_ATTR_DATA_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

  BEGIN

    EGO_USER_ATTRS_DATA_PVT.Get_User_Attrs_Data
    (
        p_api_version                   => p_api_version
       ,p_object_name                   => p_object_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_attr_group_request_table      => p_attr_group_request_table
       ,p_user_privileges_on_object     => p_user_privileges_on_object
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler            => p_init_error_handler
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,x_attributes_row_table          => x_attributes_row_table
       ,x_attributes_data_table         => x_attributes_data_table
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END Get_User_Attrs_Data;

----------------------------------------------------------------------

PROCEDURE Copy_User_Attrs_Data (
        p_api_version                   IN   NUMBER
       ,p_application_id                IN   NUMBER
       ,p_object_id                     IN   NUMBER     DEFAULT NULL
       ,p_object_name                   IN   VARCHAR2   DEFAULT NULL
       ,p_old_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_old_data_level_id             IN   NUMBER     DEFAULT NULL --bug 8941665
       ,p_old_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_pk_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_new_data_level_id             IN   NUMBER     DEFAULT NULL --bug 8941665
       ,p_new_dtlevel_col_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_new_cc_col_value_pairs        IN   EGO_COL_NAME_VALUE_PAIR_ARRAY DEFAULT NULL
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS

  BEGIN

    EGO_USER_ATTRS_DATA_PVT.Copy_User_Attrs_Data
    (
        p_api_version                   => p_api_version
       ,p_application_id                => p_application_id
       ,p_object_id                     => p_object_id
       ,p_object_name                   => p_object_name
       ,p_old_pk_col_value_pairs        => p_old_pk_col_value_pairs
       ,p_old_data_level_id             => p_old_data_level_id  --bug 8941665
       ,p_old_dtlevel_col_value_pairs   => p_old_dtlevel_col_value_pairs
       ,p_new_pk_col_value_pairs        => p_new_pk_col_value_pairs
       ,p_new_data_level_id             => p_new_data_level_id  --bug 8941665
       ,p_new_dtlevel_col_value_pairs   => p_new_dtlevel_col_value_pairs
       ,p_init_error_handler            => p_init_error_handler
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,p_commit                        => p_commit
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END Copy_User_Attrs_Data;

PROCEDURE Validate_Required_Attrs (
        p_api_version                   IN   NUMBER
       ,p_object_name                   IN   VARCHAR2
                                                     -- FND_OBJECTS.OBJECT_NAME
       ,p_pk_column_name_value_pairs    IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
                                                 -- Attr values to be validated
       ,p_class_code_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_data_level_name               IN   EGO_DATA_LEVEL_B.DATA_LEVEL_NAME%TYPE := NULL
       ,p_data_level_name_value_pairs   IN   EGO_COL_NAME_VALUE_PAIR_ARRAY
       ,p_attr_group_type_table         IN   EGO_VARCHAR_TBL_TYPE
                                -- FND_DESCRIPTIVE_FLEXS.APPLICATION_TABLE_NAME
       ,p_entity_id                     IN   NUMBER
       ,p_entity_index                  IN   NUMBER
       ,p_entity_code                   IN   VARCHAR2
       ,p_debug_level                   IN   NUMBER
       ,p_init_error_handler            IN   VARCHAR2
       ,p_write_to_concurrent_log       IN   VARCHAR2
       ,p_init_fnd_msg_list             IN   VARCHAR2
       ,p_log_errors                    IN   VARCHAR2
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2
       ,x_attributes_req_table          OUT NOCOPY EGO_USER_ATTR_TABLE
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
) IS
  BEGIN

    EGO_USER_ATTRS_DATA_PVT.Validate_Required_Attrs
    (
        p_api_version                   => p_api_version
       ,p_object_name                   => p_object_name
       ,p_pk_column_name_value_pairs    => p_pk_column_name_value_pairs
       ,p_class_code_name_value_pairs   => p_class_code_name_value_pairs
       ,p_data_level_name               => p_data_level_name
       ,p_data_level_name_value_pairs   => p_data_level_name_value_pairs
       ,p_attr_group_type_table         => p_attr_group_type_table
       ,p_entity_id                     => p_entity_id
       ,p_entity_index                  => p_entity_index
       ,p_entity_code                   => p_entity_code
       ,p_debug_level                   => p_debug_level
       ,p_init_error_handler            => p_init_error_handler
       ,p_write_to_concurrent_log       => p_write_to_concurrent_log
       ,p_init_fnd_msg_list             => p_init_fnd_msg_list
       ,p_log_errors                    => p_log_errors
       ,p_add_errors_to_fnd_stack       => p_add_errors_to_fnd_stack
       ,x_attributes_req_table          => x_attributes_req_table
       ,x_return_status                 => x_return_status
       ,x_errorcode                     => x_errorcode
       ,x_msg_count                     => x_msg_count
       ,x_msg_data                      => x_msg_data
    );

END Validate_Required_Attrs;
----------------------------------------------------------------------


/*
 * Build_Attr_Group_Row_Object builds and trturns an instance of
 * EGO_USER_ATTR_ROW_OBJ using the passed in infomation.
*/

FUNCTION Build_Attr_Group_Row_Object( p_row_identifier       IN    NUMBER
                                     ,p_attr_group_id        IN    NUMBER   DEFAULT NULL
                                     ,p_attr_group_app_id    IN    NUMBER
                                     ,p_attr_group_type      IN    VARCHAR2
                                     ,p_attr_group_name      IN    VARCHAR2
                                     ,p_data_level           IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_1         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_2         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_3         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_4         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_5         IN    VARCHAR2 DEFAULT NULL
                                     ,p_transaction_type     IN    VARCHAR2
                                     )
RETURN EGO_USER_ATTR_ROW_OBJ
IS
BEGIN
RETURN EGO_USER_ATTR_ROW_OBJ ( p_row_identifier
                              ,p_attr_group_id
                              ,p_attr_group_app_id
                              ,p_attr_group_type
                              ,p_attr_group_name
                              ,p_data_level
                              ,p_data_level_1
                              ,p_data_level_2
                              ,p_data_level_3
                              ,p_data_level_4
                              ,p_data_level_5
                              ,p_transaction_type
                             );

END Build_Attr_Group_Row_Object;

/*
 * Build_Attr_Group_Row_Table builds up the EGO_USER_ATTR_ROW_TABLE.
 * an instance of EGO_USER_ATTR_ROW_OBJ is built using the passed in
 * infomation and appended to the table here.
*/

FUNCTION Build_Attr_Group_Row_Table(  p_attr_group_row_table IN    EGO_USER_ATTR_ROW_TABLE
                                     ,p_row_identifier       IN    NUMBER
                                     ,p_attr_group_id        IN    NUMBER   DEFAULT NULL
                                     ,p_attr_group_app_id    IN    NUMBER
                                     ,p_attr_group_type      IN    VARCHAR2
                                     ,p_attr_group_name      IN    VARCHAR2
                                     ,p_data_level           IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_1         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_2         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_3         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_4         IN    VARCHAR2 DEFAULT NULL
                                     ,p_data_level_5         IN    VARCHAR2 DEFAULT NULL
                                     ,p_transaction_type     IN    VARCHAR2
                                     )
RETURN EGO_USER_ATTR_ROW_TABLE
IS
 l_user_Attr_row_tab       EGO_USER_ATTR_ROW_TABLE;
BEGIN
 IF (p_attr_group_row_table IS NULL) THEN
   l_user_Attr_row_tab := EGO_USER_ATTR_ROW_TABLE();
   l_user_Attr_row_tab.EXTEND();
 ELSE
   l_user_Attr_row_tab := p_attr_group_row_table;
   l_user_Attr_row_tab.EXTEND();
 END IF;

 l_user_Attr_row_tab(l_user_Attr_row_tab.LAST) := Build_Attr_Group_Row_Object( p_row_identifier    => p_row_identifier
                                                                              ,p_attr_group_id     => p_attr_group_id
                                                                              ,p_attr_group_app_id => p_attr_group_app_id
                                                                              ,p_attr_group_type   => p_attr_group_type
                                                                              ,p_attr_group_name   => p_attr_group_name
                                                                              ,p_data_level        => p_data_level
                                                                              ,p_data_level_1      => p_data_level_1
                                                                              ,p_data_level_2      => p_data_level_2
                                                                              ,p_data_level_3      => p_data_level_3
                                                                              ,p_data_level_4      => p_data_level_4
                                                                              ,p_data_level_5      => p_data_level_5
                                                                              ,p_transaction_type  => p_transaction_type
                                                                             );
 RETURN l_user_Attr_row_tab;

END Build_Attr_Group_Row_Table;

/*
 * Build_Attr_Group_Request_Obj creates and returns an instance of
 * EGO_ATTR_GROUP_REQUEST_OBJ using the passed in infomation.
 */

FUNCTION Build_Attr_Group_Request_Obj(p_attr_group_id      IN   NUMBER   DEFAULT NULL
                                        ,p_application_id     IN   NUMBER
                                        ,p_attr_group_type    IN   VARCHAR2
                                        ,p_attr_group_name    IN   VARCHAR2
                                        ,p_data_level         IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_1       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_2       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_3       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_4       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_5       IN   VARCHAR2 DEFAULT NULL
                                        ,p_attr_name_list     IN   VARCHAR2 DEFAULT NULL
                                       )
RETURN EGO_ATTR_GROUP_REQUEST_OBJ
IS
BEGIN

RETURN EGO_ATTR_GROUP_REQUEST_OBJ (p_attr_group_id
                                  ,p_application_id
                                  ,p_attr_group_type
                                  ,p_attr_group_name
                                  ,p_data_level
                                  ,p_data_level_1
                                  ,p_data_level_2
                                  ,p_data_level_3
                                  ,p_data_level_4
                                  ,p_data_level_5
                                  ,p_attr_name_list
                                  );

END Build_Attr_Group_Request_Obj;

/*
 * Build_Attr_Group_Request_Table builds up the EGO_ATTR_GROUP_REQUEST_TABLE.
 * An instance of EGO_ATTR_GROUP_REQUEST_OBJ is built using the passed in
 * infomation and appended to the table here.
 */

FUNCTION Build_Attr_Group_Request_Table( p_ag_req_table       IN   EGO_ATTR_GROUP_REQUEST_TABLE
                                        ,p_attr_group_id      IN   NUMBER   DEFAULT NULL
                                        ,p_application_id     IN   NUMBER
                                        ,p_attr_group_type    IN   VARCHAR2
                                        ,p_attr_group_name    IN   VARCHAR2
                                        ,p_data_level         IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_1       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_2       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_3       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_4       IN   VARCHAR2 DEFAULT NULL
                                        ,p_data_level_5       IN   VARCHAR2 DEFAULT NULL
                                        ,p_attr_name_list     IN   VARCHAR2 DEFAULT NULL
                                       )
RETURN EGO_ATTR_GROUP_REQUEST_TABLE
IS
l_req_table EGO_ATTR_GROUP_REQUEST_TABLE;
BEGIN

 IF (l_req_table IS NULL) THEN
   l_req_table := EGO_ATTR_GROUP_REQUEST_TABLE();
   l_req_table.EXTEND();
 ELSE
   l_req_table := p_ag_req_table;
   l_req_table.EXTEND();
 END IF;

 l_req_table(l_req_table.LAST) := Build_Attr_Group_Request_Obj(p_attr_group_id   => p_attr_group_id
                                                                 ,p_application_id  => p_application_id
                                                                 ,p_attr_group_type => p_attr_group_type
                                                                 ,p_attr_group_name => p_attr_group_name
                                                                 ,p_data_level      => p_data_level
                                                                 ,p_data_level_1    => p_data_level_1
                                                                 ,p_data_level_2    => p_data_level_2
                                                                 ,p_data_level_3    => p_data_level_3
                                                                 ,p_data_level_4    => p_data_level_4
                                                                 ,p_data_level_5    => p_data_level_5
                                                                 ,p_attr_name_list  => p_attr_name_list
                                                                 );

 RETURN l_req_table;


END Build_Attr_Group_Request_Table;









END EGO_USER_ATTRS_DATA_PUB;


/
