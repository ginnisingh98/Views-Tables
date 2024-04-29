--------------------------------------------------------
--  DDL for Package Body HZ_EXTENSIBILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_EXTENSIBILITY_PUB" AS
/* $Header: ARHEXTSB.pls 120.1 2005/08/30 19:06:50 geliu noship $ */

   G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'ARHEXTSB.pls';
   G_PKG_NAME        CONSTANT  VARCHAR2(30)  :=  'HZ_EXTENSIBILITY_PUB';

   G_USER_ID       NUMBER  :=  FND_GLOBAL.User_Id;
   G_LOGIN_ID      NUMBER  :=  FND_GLOBAL.Conc_Login_Id;


   G_FILE_NAME       CONSTANT  VARCHAR2(12)  :=  'ARHEXTSB.pls';
   G_PKG_NAME        CONSTANT  VARCHAR2(30)  :=  'HZ_EXTENSIBILITY_PUB';

   G_USER_ID       NUMBER  :=  FND_GLOBAL.User_Id;
   G_LOGIN_ID      NUMBER  :=  FND_GLOBAL.Conc_Login_Id;


   PROCEDURE Process_Organization_Record (
        p_api_version                   IN   NUMBER
       ,p_org_profile_id                IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
     -- Add the code here to validate the ID's passed
     -- Before caalling the PVT API.
     --
     -- Need to be filled in.
     --

     HZ_EXTENSIBILITY_PVT.Process_User_Attrs_For_Item(
          p_api_version                   => p_api_version
         ,p_owner_table_id                => p_org_profile_id
         ,p_owner_table_name              => 'HZ_ORGANIZATION_PROFILES'
         ,p_attributes_row_table          => p_attributes_row_table
         ,p_attributes_data_table         => p_attributes_data_table
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

   END Process_Organization_Record;

   PROCEDURE Process_Person_Record (
        p_api_version                   IN   NUMBER
       ,p_person_profile_id             IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
     -- Add the code here to validate the ID's passed
     -- Before caalling the PVT API.
     --
     -- Need to be filled in.
     --

     HZ_EXTENSIBILITY_PVT.Process_User_Attrs_For_Item(
          p_api_version                   => p_api_version
         ,p_owner_table_id                => p_person_profile_id
         ,p_owner_table_name              => 'HZ_PERSON_PROFILES'
         ,p_attributes_row_table          => p_attributes_row_table
         ,p_attributes_data_table         => p_attributes_data_table
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

   END Process_Person_Record;

   PROCEDURE Process_Location_Record (
        p_api_version                   IN   NUMBER
       ,p_location_id                   IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
     -- Add the code here to validate the ID's passed
     -- Before caalling the PVT API.
     --
     -- Need to be filled in.
     --
     HZ_EXTENSIBILITY_PVT.Process_User_Attrs_For_Item(
          p_api_version                   => p_api_version
         ,p_owner_table_id                => p_location_id
         ,p_owner_table_name              => 'HZ_LOCATIONS'
         ,p_attributes_row_table          => p_attributes_row_table
         ,p_attributes_data_table         => p_attributes_data_table
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

   END Process_Location_Record;

   PROCEDURE Process_PartySite_Record (
        p_api_version                   IN   NUMBER
       ,p_party_site_id                 IN   NUMBER
       ,p_attributes_row_table          IN   EGO_USER_ATTR_ROW_TABLE
       ,p_attributes_data_table         IN   EGO_USER_ATTR_DATA_TABLE
       ,p_change_info_table             IN   EGO_USER_ATTR_CHANGE_TABLE DEFAULT NULL
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_write_to_concurrent_log       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_init_fnd_msg_list             IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_log_errors                    IN   VARCHAR2   DEFAULT FND_API.G_TRUE
       ,p_add_errors_to_fnd_stack       IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,p_commit                        IN   VARCHAR2   DEFAULT FND_API.G_FALSE
       ,x_failed_row_id_list            OUT NOCOPY VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_errorcode                     OUT NOCOPY NUMBER
       ,x_msg_count                     OUT NOCOPY NUMBER
       ,x_msg_data                      OUT NOCOPY VARCHAR2
   ) IS

   BEGIN
     -- Add the code here to validate the ID's passed
     -- Before caalling the PVT API.
     --
     -- Need to be filled in.
     --

     HZ_EXTENSIBILITY_PVT.Process_User_Attrs_For_Item(
          p_api_version                   => p_api_version
         ,p_owner_table_id                => p_party_site_id
         ,p_owner_table_name              => 'HZ_PARTY_SITES'
         ,p_attributes_row_table          => p_attributes_row_table
         ,p_attributes_data_table         => p_attributes_data_table
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

   END Process_PartySite_Record;

   PROCEDURE Get_User_Attrs_For_Item (
        p_api_version                   IN   NUMBER
       ,p_org_profile_id                IN   NUMBER
       ,p_attr_group_request_table      IN   EGO_ATTR_GROUP_REQUEST_TABLE
       ,p_entity_id                     IN   NUMBER     DEFAULT NULL
       ,p_entity_index                  IN   NUMBER     DEFAULT NULL
       ,p_entity_code                   IN   VARCHAR2   DEFAULT NULL
       ,p_debug_level                   IN   NUMBER     DEFAULT 0
       ,p_init_error_handler            IN   VARCHAR2   DEFAULT FND_API.G_TRUE
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

     HZ_EXTENSIBILITY_PVT.Get_User_Attrs_For_Item(
        p_api_version                   => p_api_version
       ,p_org_profile_id                => p_org_profile_id
       ,p_attr_group_request_table      => p_attr_group_request_table
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

   END Get_User_Attrs_For_Item;

END HZ_EXTENSIBILITY_PUB;

/
