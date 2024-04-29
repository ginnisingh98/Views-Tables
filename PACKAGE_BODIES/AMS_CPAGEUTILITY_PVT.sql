--------------------------------------------------------
--  DDL for Package Body AMS_CPAGEUTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CPAGEUTILITY_PVT" AS
/* $Header: amsvcpgb.pls 115.28 2002/06/09 17:55:22 pkm ship        $ */
--
--
g_pkg_name                    CONSTANT VARCHAR2(30)   :=    'AMS_CPageUtility_PVT';

-- Added the flag below as a workaround for IBC Code to work.
-- Currently creating the content items for each section as reusable items.
-- Mar 26,2002 : IBC has shifted away from reusable_flag and now we are
-- using parent_item_id
g_reusable_flag               CONSTANT VARCHAR2(1)    :=    FND_API.g_true;

--

g_commit_on_lock_unlock       CONSTANT VARCHAR2(1)    :=    FND_API.g_false;

-- Currently we do not send commit as TRUE to lock and unlock calls.
--

g_lock_flag_value             CONSTANT VARCHAR2(1)    :=    FND_API.g_false;
g_using_locking               CONSTANT VARCHAR2(1)    :=    FND_API.g_false;

-- Currently we are not using the locking mechanism from IBC as the LOCK and UNLOCK
-- takes effect only if we commit the transaction, which is not what we want.

g_wd_restricted_flag_value    CONSTANT VARCHAR2(1)    :=    FND_API.g_false;

-- The wd_restricted_flag='T' means the items is not for runtime,
-- only administrators who have access to the directory can manipulate them.
-- All items for public view (runtime read) shld set this flag to 'F'.

--
-- Declare private procedure signatures here.
--
--
--------------------------------------------------------------------
-- PROCEDURE
--    create_citem_for_delv
--
-- PURPOSE
--    Create a Content Item for Deliverable of type Content Page.
--
-- NOTES
--    1. The required input is as follows:
--         content_type_code
--         default_display_template_id
--         deliverable_id
--         association_type_code (to be recorded in ibc_associations table)
--    2. This procedure returns the Content Item ID of the newly created
--       Content Item associated with the given deliverable.
--
-- HISTORY
--    29-JAN-2002   gdeodhar     Created.
-----------------------------------------------------------------------
PROCEDURE create_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_def_disp_template_id  IN  NUMBER,
   p_delv_id               IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_citem_id              OUT NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
-- Cursor to select the Deliverable Details to record in the Content Item Data.
--
   CURSOR c_delv_details IS
     SELECT owner_user_id
            ,actual_avail_from_date
            ,actual_avail_to_date
            ,deliverable_name
            ,description
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
   l_owner_res_id                NUMBER ;
   l_start_date                  DATE ;
   l_end_date                    DATE ;
   l_delv_name                   VARCHAR2(240) ;
   l_delv_desc                   VARCHAR2(4000) ;
--
   l_citem_ver_id                NUMBER ;
   l_citem_id                    NUMBER ;
   l_return_status               VARCHAR2(1) ;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000) ;
--
   l_obj_ver_num                 NUMBER ;
   l_assoc_id                    NUMBER ;
--
   l_attribute_type_codes        JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_attributes                  JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
--
   l_assoc_type_codes            JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_assoc_objects1              JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300() ;
   l_assoc_objects2              JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300() ;
   l_assoc_objects3              JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300() ;
   l_assoc_objects4              JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300() ;
   l_assoc_objects5              JTF_VARCHAR2_TABLE_300 := JTF_VARCHAR2_TABLE_300() ;
--
   l_init_msg_list               VARCHAR2(1)           := FND_API.g_true;
--
   l_api_version_number          CONSTANT NUMBER       := 1.0;
   l_api_name                    CONSTANT VARCHAR2(30) := 'create_citem_for_delv';
   l_full_name                   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT create_citem_for_delv_PVT;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

--
-- This procedure will create a new Content Item in IBC Schema.
-- It will record the Default Display Template ID as the value of one special Attribute
-- of the same Content Item.
-- It will also create a record in IBC_ASSOCIATIONS table to associate the Deliverable
-- and the newly created Content Item.
--
-- Fetch the Deliverable Details.

   OPEN c_delv_details;
   FETCH c_delv_details INTO l_owner_res_id, l_start_date, l_end_date, l_delv_name, l_delv_desc;
   CLOSE c_delv_details;
--
   -- Prepare the Attribute Bundle if necessary.
   IF p_def_disp_template_id IS NOT NULL
   THEN
--    Call the procedure IBC_CITEM_ADMIN_GRP.set_citem_att_bundle.
--    prepare the data for insert.
--
      l_attribute_type_codes.extend();
      l_attribute_type_codes(1) := G_DEFAULT_DISPLAY_TEMPLATE; -- Should be a CONSTANT in package.
--
      l_attributes.extend();
      l_attributes(1) := p_def_disp_template_id;
--
   ELSE
      l_attribute_type_codes := NULL;
      l_attributes := NULL;
   END IF;


-- Create a new Content Item in IBC Schema for incoming Content Type.

-- Call the procedure upsert_item. This method allows creation of Content Item from one
-- single API.

   IBC_CITEM_ADMIN_GRP.upsert_item(
       p_ctype_code              =>     p_content_type_code
       ,p_citem_name             =>     l_delv_name
       ,p_citem_description      =>     substr(l_delv_desc,1,2000)
       ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
       ,p_owner_resource_id      =>     l_owner_res_id
       ,p_owner_resource_type    =>     G_OWNER_RESOURCE_TYPE
       ,p_reference_code         =>     NULL                      -- Why is this needed?
       ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
       ,p_parent_item_id         =>     NULL                      -- There is no parent for the content item that is associated with the Deliverable.
       ,p_lock_flag              =>     g_lock_flag_value
       ,p_wd_restricted          =>     g_wd_restricted_flag_value
       ,p_start_date             =>     l_start_date
       ,p_end_date               =>     l_end_date
       ,p_attach_file_id         =>     NULL
       ,p_attribute_type_codes   =>     l_attribute_type_codes
       ,p_attributes             =>     l_attributes
       ,p_component_citems       =>     NULL
       ,p_component_atypes       =>     NULL
       ,p_sort_order             =>     NULL
       ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- When the Deliverable becomes active, we will go in and approve all the underlying content items.
       ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
       ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
       ,p_api_version_number     =>     p_api_version
       ,p_init_msg_list          =>     l_init_msg_list
       ,px_content_item_id       =>     l_citem_id
       ,px_citem_ver_id          =>     l_citem_ver_id
       ,px_object_version_number =>     l_obj_ver_num
       ,x_return_status          =>     l_return_status
       ,x_msg_count              =>     l_msg_count
       ,x_msg_data               =>     l_msg_data
   );

   AMS_UTILITY_PVT.debug_message('After upsert_item.');
   AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id);
   AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
   AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   l_init_msg_list := FND_API.g_false ; -- This point onwards, we should not initialize the message list.

-- If the above statement is successful, add the association record in IBC_ASSOCIATIONS.
--
-- Prepare the data for insert.

   l_assoc_type_codes.extend();
   l_assoc_type_codes(1) := p_assoc_type_code ;

   l_assoc_objects1.extend();
   l_assoc_objects1(1) := p_delv_id ;

   l_assoc_objects2.extend();
   l_assoc_objects2(1) := p_content_type_code ;

   l_assoc_objects3.extend();
   l_assoc_objects3(1) := p_def_disp_template_id ;

   l_assoc_objects4.extend();
   l_assoc_objects4(1) := NULL ;

   l_assoc_objects5.extend();
   l_assoc_objects5(1) := NULL ;

-- Call the procedure IBC_CITEM_ADMIN_GRP.insert_associations.

   IBC_CITEM_ADMIN_GRP.insert_associations(
      p_content_item_id       =>    l_citem_id
      ,p_assoc_type_codes     =>    l_assoc_type_codes
      ,p_assoc_objects1       =>    l_assoc_objects1
      ,p_assoc_objects2       =>    l_assoc_objects2        -- Denormalized Value stored here. This can be debated. Remove if decided against storing it here.
      ,p_assoc_objects3       =>    l_assoc_objects3        -- Denormalized Value stored here. This can be debated. Remove if decided against storing it here.
      ,p_assoc_objects4       =>    l_assoc_objects4        -- Null values.
      ,p_assoc_objects5       =>    l_assoc_objects5        -- Null values.
      ,p_commit               =>    FND_API.g_false         -- This is the Default.
      ,p_api_version_number   =>    p_api_version
      ,p_init_msg_list        =>    l_init_msg_list
      -- The following are OUT parameters in this procedure.
      --,x_assoc_id             =>    l_assoc_id
      -- Jamie applied his package on mapdev01.
      -- He has changed signature of this method.
      -- as a result commenting the above line.
      ,x_return_status        =>    l_return_status
      ,x_msg_count            =>    l_msg_count
      ,x_msg_data             =>    l_msg_data
   );
--
--
   AMS_UTILITY_PVT.debug_message('Insert Assoc.');
   AMS_UTILITY_PVT.debug_message('l_assoc_id = ' || l_assoc_id);
   AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
   AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_CITEM_ASSOC');
      RAISE FND_API.g_exc_error;
   END IF;
--

-- We should not approve this item at this time.
-- When the associated Deliverable gets the approval and becomes actives, we should
-- approve the main content item associated with the deliverable and we should also
-- approve the components of that main content item.

   IF g_using_locking = FND_API.g_true
   THEN
   --
   -- At this stage we must UNLOCK this content item as we will soon commit this transaction.
   -- Call the procedure IBC_CITEM_ADMIN_GRP.unlock_item
   --
      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    l_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );
   --
      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);
   --
   --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;
--
-- If we come till here, everything has been done successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
--
   x_citem_id := l_citem_id;
   x_citem_ver_id := l_citem_ver_id;
   x_return_status := l_return_status;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_citem_for_delv_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_citem_for_delv_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO create_citem_for_delv_PVT;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
--
END create_citem_for_delv;
--


-----------------------------------------------------------------------
-- PROCEDURE
--    approve_citem_for_delv
--
-- PURPOSE
--    Approve the Content Item associated with the Deliverable of type Content Page.
--
-- NOTES
--    1. The required input is as follows:
--         content_type_code
--         deliverable_id
--         content_item_id
--         association_type_code (this is recorded in ibc_associations table)
--    2. This procedure returns the success or failure status
--
-- COMMENTS added on May 06, 2002.
/*
Notes for changes in Approve CItem for Delv procedure :

1. There has to be a validate_citem_for_delv procedure that does the following :

   Goes through all the sections and checks that all the data is OK.

   Rich Content Section :

      1. It checks that there is an attachment created.

   Questions Section :

      1. Dropdown/checkbox/RadioButton/List question :
         Check that there are some answers.

   Submit Section :

      1. Must be defined if there are questions.

   CP Image Section :

      1. Nothing to check.

2. If all the validations are done proceed with incomplete definition check.

3. Incomplete definition must check if there are some sections undefined.
   If so, this is not really an error, but we must make sure that the mandatory sections are defined.
   The IBC API approve_item checks this, but it will be good if we check it before hand.

______

Provide a report to the user.

When user clicks proceed, we must then call :

1. Complete definition process.

   This will generate the XML for Questions Section if necessary by calling update_questions_section.

   Other completion tasks as identified.

2. Approve Item call.
*/
-----------------------------------------------------------------------
PROCEDURE approve_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_citem_id              IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
-- Declare the local variables and cursors here.
--
   CURSOR c_delv_details IS
     SELECT status_code
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
--
   l_delv_status_code      VARCHAR2(30) ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
   l_citem_id              NUMBER ;
   l_citem_ver_id          NUMBER ;
   l_cpnt_citem_ver_id     NUMBER ;
   l_cpnt_obj_ver_num      NUMBER ;
--
   l_content_item_id       NUMBER ;
--
-- Cursor to select the latest citem version for a content item.
--
   CURSOR c_max_version IS
     SELECT MAX(citem_version_id)
     FROM   ibc_citem_versions_b
     WHERE  content_item_id = l_content_item_id ;
--
   l_status                VARCHAR2(30) ;
   l_attach_file_id        NUMBER ;
   l_attach_file_name      VARCHAR2(240) ;
   l_citem_name            VARCHAR2(240) ;
   l_description           VARCHAR2(2000) ;
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 ;
   l_attribute_type_names  JTF_VARCHAR2_TABLE_300 ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 ;
   l_cpnt_citems           JTF_NUMBER_TABLE ;
   l_cpnt_ctypes           JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_attrib_types     JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_citem_names      JTF_VARCHAR2_TABLE_300 ;
   l_cpnt_owner_ids        JTF_NUMBER_TABLE ;
   l_cpnt_owner_types      JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_owner_names      JTF_VARCHAR2_TABLE_400 ;
   l_cpnt_sort_orders      JTF_NUMBER_TABLE ;
   l_object_version_number NUMBER ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Approve_Citem_For_Delv';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Check if the deliverable is in ACTIVE status first.
   -- Fetch the Deliverable Details.
   OPEN c_delv_details ;
   FETCH c_delv_details INTO l_delv_status_code ;
   CLOSE c_delv_details ;

   /*
   IF l_delv_status_code NOT IN ('ACTIVE','AVAILABLE')
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_DELV_NOT_ACTIVE');
      RAISE FND_API.g_exc_error;
   END IF;
   */
   -- Removing the above check for now. Will revist.

   IF g_using_locking = FND_API.g_true
   THEN

      -- We have to lock the item first.
      IBC_CITEM_ADMIN_GRP.lock_item(
         p_content_item_id          =>    p_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_citem_version_id        =>    l_citem_ver_id
         ,x_object_version_number   =>    l_obj_ver_num
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_LOCKING_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;
   ELSE

      -- If we do not use locking mechanism, we will have to get the latest citem version
      -- for this deliverable at this stage.
      -- Fetch the latest citem version id.

      l_content_item_id := p_citem_id;

      OPEN c_max_version ;
      FETCH c_max_version INTO l_citem_ver_id ;
      CLOSE c_max_version ;

      -- We must also fetch the object version number.
      l_obj_ver_num := IBC_CITEM_ADMIN_GRP.getObjVerNum( p_citem_id );

   END IF;

   AMS_Utility_PVT.Debug_Message(' l_content_item_id = ' || l_content_item_id ) ;
   AMS_Utility_PVT.Debug_Message(' l_citem_ver_id = ' || l_citem_ver_id ) ;
   AMS_Utility_PVT.Debug_Message(' obj ver num = ' || l_obj_ver_num ) ;

   -- Get the components of this content item.
   -- We must approve the components first.

   -- Call get_content_item_data.
   get_content_item_data(
      p_citem_id                  =>    p_citem_id
      ,p_citem_ver_id             =>    l_citem_ver_id
      ,p_api_version              =>    p_api_version
      ,x_status                   =>    l_status
      ,x_attach_file_id           =>    l_attach_file_id
      ,x_attach_file_name         =>    l_attach_file_name
      ,x_citem_name               =>    l_citem_name
      ,x_description              =>    l_description
      ,x_attribute_type_codes     =>    l_attribute_type_codes
      ,x_attribute_type_names     =>    l_attribute_type_names
      ,x_attributes               =>    l_attributes
      ,x_cpnt_citem_ids           =>    l_cpnt_citems
      ,x_cpnt_ctype_codes         =>    l_cpnt_ctypes
      ,x_cpnt_attrib_types        =>    l_cpnt_attrib_types
      ,x_cpnt_citem_names         =>    l_cpnt_citem_names
      ,x_cpnt_sort_orders         =>    l_cpnt_sort_orders
      ,x_object_version_number    =>    l_object_version_number
      ,x_return_status            =>    l_return_status
      ,x_msg_count                =>    l_msg_count
      ,x_msg_data                 =>    l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_GET_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   -- First approve each of the components.
   IF l_cpnt_citems IS NOT NULL
   THEN
      FOR i IN l_cpnt_citems.first .. l_cpnt_citems.last
      LOOP
         -- Note that when locking is enabled, we still need not lock the components
         -- as we have locked the parent content item.
         -- So obtain the citem version id and object version number for the
         -- component the usual way.

         l_content_item_id := l_cpnt_citems(i);

         OPEN c_max_version ;
         FETCH c_max_version INTO l_cpnt_citem_ver_id ;
         CLOSE c_max_version ;

         -- We must also fetch the object version number.
         l_cpnt_obj_ver_num := IBC_CITEM_ADMIN_GRP.getObjVerNum( l_content_item_id );

         --The line below does not work.
         --The l_cpnt_attrib_types is un-initialized.
         --Must check the original get_item from IBC API to see if that is working.
         --AMS_Utility_PVT.Debug_Message(' For component ' || l_cpnt_attrib_types(i) );
         AMS_Utility_PVT.Debug_Message(' l_content_item_id = ' || l_content_item_id );
         AMS_Utility_PVT.Debug_Message(' l_cpnt_citem_ver_id = ' || l_cpnt_citem_ver_id );
         AMS_Utility_PVT.Debug_Message(' l_cpnt_obj_ver_num = ' || l_cpnt_obj_ver_num );

         IF l_cpnt_citem_ver_id IS NOT NULL
            AND
            l_cpnt_obj_ver_num IS NOT NULL
         THEN

            -- Approve this component.
            IBC_CITEM_ADMIN_GRP.approve_item(
               p_citem_ver_id                =>    l_cpnt_citem_ver_id
               ,p_commit                     =>    FND_API.g_false
               ,p_api_version_number         =>    p_api_version
               ,p_init_msg_list              =>    l_init_msg_list
               ,px_object_version_number     =>    l_cpnt_obj_ver_num
               ,x_return_status              =>    l_return_status
               ,x_msg_count                  =>    l_msg_count
               ,x_msg_data                   =>    l_msg_data
            );

            IF FND_API.g_ret_sts_success <> l_return_status
            THEN
               AMS_Utility_PVT.Error_Message('AMS_ERR_APPROVE_CITEM');
               RAISE FND_API.g_exc_error;
            END IF;

         END IF;

      END LOOP ;

   END IF ;

   -- Now approve the main parent component item.
   IBC_CITEM_ADMIN_GRP.approve_item(
      p_citem_ver_id                =>    l_citem_ver_id
      ,p_commit                     =>    FND_API.g_false
      ,p_api_version_number         =>    p_api_version
      ,p_init_msg_list              =>    l_init_msg_list
      ,px_object_version_number     =>    l_obj_ver_num
      ,x_return_status              =>    l_return_status
      ,x_msg_count                  =>    l_msg_count
      ,x_msg_data                   =>    l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_APPROVE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   IF g_using_locking = FND_API.g_true
   THEN

      -- unlock the content item.
      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    p_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;


   -- Commit the work and set the output values.

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   x_return_status := l_return_status;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );

END approve_citem_for_delv;


--
-----------------------------------------------------------------------
-- PROCEDURE
--    validate_citem_for_delv
--
-- PURPOSE
--    Validate Content Item created for a Deliverable before approval.
--
-- NOTES
--    1. This procedures validates the contents of a content item associated with
--       the given deliverable.
--    2. The procedure logs messages in activity log table.
--    3. procedure returns the fact that it is successful.
--
-- HISTORY
--    06-MAY-2002   gdeodhar     Created as a stub.
--
-----------------------------------------------------------------------
PROCEDURE validate_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_citem_id              IN  NUMBER,
   p_citem_version_id      IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
BEGIN
null;
END validate_citem_for_delv;



--
--
-----------------------------------------------------------------------
-- PROCEDURE
--    manage_rich_content
--
-- PURPOSE
--    Manage a Rich Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be RICH_CONTENT.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Attachment File ID that has the Rich Content Data.
--       Attachment File Name.
--       Start Date
--       End Date
--       Owner Resource ID
--       Owner Resource Type
--       Value for HAS_MERGE_FIELDS
--       Value for HAS_PAGE_MERGE_FIELDS
--    2. The optional input is as follows:
--       Content Item Id : If given Update is done.
--       Content Item Version Id : If given Update is done.
--       Description.
--       Attribute Type Code for the Section.
--       The Content Item Version ID of the Parent Content Item
--       The Content Type Code associated with the Parent Content Item.
--          If the above two are available, this procedure will create a
--          compound relation between the Parent Content Item Version ID and
--          the Content Item ID of the newly created Content Item.
--       VARCHAR2 Array of Data Source Programmatic Access Codes.
--       VARCHAR2 Array of Merge Field names.
--       Note that these names contain the Programmatic Access Code for the
--       Data Source as well as the Column Name, separated by a period.
--          If this Array has data, the SELECT_SQL_QUERY type of Content Items
--          will be created for each of Data Sources that appear in the list.
--          The MERGE_FIELD Content Items will be created for each of the item
--          in the Array.
--          Compound relations will be created between the MERGE_FIELD items and
--          SELECT_SQL_QUERY items and between SELECT_SQL_QUERY items and the
--          newly created RICH_CONTENT item.
--    3. This procedure performs the following steps:
--          1. Create a Basic Content Item for Rich Content with insert_basic_citem
--          2. Add the Meta Data with set_citem_meta.
--          3. Set the Attachment for this Content Item.
--          4. Set the Attribute Bundle for this Content Item.
--             Arrive at the value for FUNCTIONAL_TYPE.
--             This will consist of the following attributes:
--                HAS_MERGE_FIELDS
--                HAS_PAGE_MERGE_FIELDS
--                FUNCTIONAL_TYPE
--          5. If the details of Parent Content Item are available,
--             create the compound relation between the parent content item and the
--             newly created RICH_CONTENT item.
--          6. If the Merge Fields List is not empty, do the following:
--             Collect all the Merge Fields from one data source together.
--             For each such data source, do the following:
--                Create MERGE_FIELD Content Item for each Merge Field for this Data Source with an APPROVED status. Use BULK_INSERT.
--                   Pick up the Field Type from Data Source schema.
--                Generate SQL Query for the resolution of these Merge Fields in APPROVED status. Use BULK_INSERT.
--                Create the SELECT_SQL_QUERY content item.
--                Create Compound Relations between the SELECT_SQL_QUERY and the MERGE_FIELD content items.
--             Create Compound Relations between the SELECT_SQL_QUERY items and the RICH_CONTENT content item.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    14-FEB-2002   gdeodhar     Created.
--    11-MAR-2002   gdeodhar     Added Update to the same method.
--
-----------------------------------------------------------------------
PROCEDURE manage_rich_content(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_has_merge_fields      IN  VARCHAR2,
   p_has_page_merge_fields IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_data_source_list      IN  JTF_VARCHAR2_TABLE_300,
   p_merge_fields_list     IN  JTF_VARCHAR2_TABLE_300,
   p_attribute_type_code   IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   px_citem_id             IN OUT NUMBER,
   px_citem_ver_id         IN OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2,
   p_dml_flag              IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2                DEFAULT FND_API.g_true
)
IS
--
-- Declare the local variables and cursors here.
-- Cursor to select the Deliverable Details to record in the Content Item Data.
--
   CURSOR c_delv_details IS
     SELECT actual_avail_from_date
            ,actual_avail_to_date
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
   l_start_date                  DATE ;
   l_end_date                    DATE ;
--
   l_citem_ver_id                NUMBER ;
   l_citem_id                    NUMBER ;
   l_return_status               VARCHAR2(1) ;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000) ;
--
   l_obj_ver_num                 NUMBER ;
--
   l_attribute_type_codes        JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100() ;
   l_attributes                  JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
   l_citem_ids                   JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE() ;
   l_citem_attrs                 JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100() ;
   l_dummy_sort_order            JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE() ;
--
   l_init_msg_list               VARCHAR2(1)             := FND_API.g_true;
--
   l_api_version_number          CONSTANT NUMBER         := 1.0;
   l_api_name                    CONSTANT VARCHAR2(30)   := 'manage_rich_content';
   l_full_name                   CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
--
   l_attr_count                  NUMBER ;
   l_bind_vars_list              JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300() ;
   l_select_sql_statement        VARCHAR2(4000) ;
   l_data_src_type_code       VARCHAR2(300) ;
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT manage_rich_content_PVT ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
   IF p_content_type_code <> G_RICH_CONTENT -- Should be a CONSTANT in the package.
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_WRONG_CTYPE_CODE');
      RAISE FND_API.g_exc_error;
   END IF;
--
-- Check if the call is for Create or Update.

   l_citem_id := px_citem_id ;
   l_citem_ver_id := px_citem_ver_id ;

   AMS_UTILITY_PVT.debug_message( 'l_citem_id = ' || l_citem_id );
   AMS_UTILITY_PVT.debug_message( 'l_citem_ver_id = ' || l_citem_ver_id );
   AMS_UTILITY_PVT.debug_message( 'p_dml_flag = ' || p_dml_flag );

   IF p_dml_flag <> 'C'
   THEN
      -- check if content item id and content item version id is available.
      IF l_citem_id IS NULL
         OR
         l_citem_ver_id IS NULL
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_NO_CITEM_OR_VER_ID');
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- For update, ideally we must check if the dates for the parent deliverable
   -- have changed and update the dates as well.
   -- To be done later.

   --
   --
   -- prepare the data for insert / update

   l_attr_count := 0;

   IF p_dml_flag <> 'D'
   THEN

      l_attr_count := l_attr_count + 1;
      l_attribute_type_codes.extend();
      l_attribute_type_codes(l_attr_count) := G_HAS_MERGE_FIELDS;

      l_attributes.extend();
      l_attributes(l_attr_count) := p_has_merge_fields;
   --
      l_attr_count := l_attr_count + 1;
      l_attribute_type_codes.extend();
      l_attribute_type_codes(l_attr_count) := G_HAS_PAGE_MERGE_FIELDS;
   --
      l_attributes.extend();
      l_attributes(l_attr_count) := p_has_page_merge_fields;
   --
      -- Check if the Data Source is available.
      IF p_data_source_list IS NOT NULL
         AND
         p_data_source_list(1) IS NOT NULL
      THEN

         -- We also have to update the ams_list_src_type_usages table.
         -- For CREATE, we have to insert the record in the above table.
         -- For UPDATE, we have to update the record in the above table.
         -- To be coded when the APIs for ams_list_src_type_usages are available.

         -- The data source list is not null.
         -- Currently we support only one data source per rich content.
         l_attr_count := l_attr_count + 1;
         l_attribute_type_codes.extend();
         l_attribute_type_codes(l_attr_count) := G_DATA_SOURCE;

         l_attributes.extend();
         l_attributes(l_attr_count) := p_data_source_list(1);

         AMS_UTILITY_PVT.debug_message( ' p_data_source_list(1) = ' || p_data_source_list(1) );

         -- Check if the Merge Fields are available.
         -- populate the attributes for Merge Fields.
         IF p_merge_fields_list IS NOT NULL
         THEN

            FOR i IN p_merge_fields_list.first .. p_merge_fields_list.last
            LOOP
               l_attr_count := l_attr_count + 1;
               l_attribute_type_codes.extend();
               l_attribute_type_codes(l_attr_count) := G_MERGE_FIELD;

               l_attributes.extend();
               l_attributes(l_attr_count) := substr(p_merge_fields_list(i), 1, 30);

               -- GDEODHAR : May 06, 2002.
               -- Changed the above line to use substr.
               -- When the alias name exceeds 30 characters, it gives problem with the
               -- SQL statement execution at runtime.
               -- Now truncating the alias after 30th character while generating the
               -- select SQL statement in generate_select_sql method.
               -- Hence the change has to happen here as well.
               -- At runtime, there has to be one-to-one correspondance between the
               -- select column and the merge field name recorded here.

            END LOOP;

         END IF;

         l_data_src_type_code := p_data_source_list(1);

         -- Generate the SQL statement for the Merge Fields.
         generate_select_sql(
            p_data_source_code          =>    l_data_src_type_code
            ,p_data_source_fields_list  =>    p_merge_fields_list
            ,p_data_source_field_ids    =>    NULL
            ,x_select_sql_statement     =>    l_select_sql_statement
            ,x_bind_vars                =>    l_bind_vars_list
            ,x_return_status            =>    l_return_status
            ,x_msg_count                =>    l_msg_count
            ,x_msg_data                 =>    l_msg_data
         );

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_CPAGE_GEN_SQL');
            RAISE FND_API.g_exc_error;
         END IF;

         AMS_UTILITY_PVT.debug_message( ' l_select_sql_statement = ' || l_select_sql_statement );

         -- Set the attributes for Select SQL Statement and bind variables.
         IF l_select_sql_statement IS NOT NULL
         THEN
            l_attr_count := l_attr_count + 1;
            l_attribute_type_codes.extend();
            l_attribute_type_codes(l_attr_count) := G_SELECT_SQL_STATEMENT ;

            l_attributes.extend();
            l_attributes(l_attr_count) := l_select_sql_statement ;

            IF l_bind_vars_list IS NOT NULL
            THEN
               FOR i IN l_bind_vars_list.first .. l_bind_vars_list.last
               LOOP
                  l_attr_count := l_attr_count + 1;
                  l_attribute_type_codes.extend();
                  l_attribute_type_codes(l_attr_count) := G_BIND_VAR;

                  l_attributes.extend();
                  l_attributes(l_attr_count) := l_bind_vars_list(i);
               END LOOP;
            END IF;

         END IF;

      ELSE

         -- If this is an update call, check if there was a data source associated
         -- with this content item and delete that record from the ams_list_src_type_usages
         -- table.
         -- To be coded when the APIs for ams_list_src_type_usages are available.

         null;

      END IF;

   -- Arrive at the Functional Type.
   -- The Functional Type depends on what Data Source are associated with this content.
   -- We will add this functionality later, when we decide something concrete about the
   -- Data Sources.
      l_attr_count := l_attr_count + 1;
      l_attribute_type_codes.extend();
      l_attribute_type_codes(l_attr_count) := G_FUNCTIONAL_TYPE ;

      l_attributes.extend();
      l_attributes(l_attr_count) := G_DEFAULT_FUNCTIONAL_TYPE ;
   --

   END IF;

   IF p_dml_flag = 'C'
   THEN
   -- Create a new Content Item in IBC Schema for incoming Content Type.

      -- Fetch the Deliverable Details.
      OPEN c_delv_details;
      FETCH c_delv_details INTO l_start_date, l_end_date;
      CLOSE c_delv_details;

   -- Call IBC_CITEM_ADMIN_GRP.upsert_item procedure.

      IBC_CITEM_ADMIN_GRP.upsert_item(
          p_ctype_code              =>     p_content_type_code
          ,p_citem_name             =>     p_content_item_name
          ,p_citem_description      =>     substr(p_description,1,2000)
          ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
          ,p_owner_resource_id      =>     p_owner_resource_id
          ,p_owner_resource_type    =>     p_owner_resource_type
          ,p_reference_code         =>     NULL                      -- Why is this needed?
          ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
          ,p_parent_item_id         =>     p_parent_citem_id         -- Specify the parent content item id. This item is visible only in the context of this parent.
          ,p_lock_flag              =>     g_lock_flag_value
          ,p_wd_restricted          =>     g_wd_restricted_flag_value
          ,p_start_date             =>     l_start_date
          ,p_end_date               =>     l_end_date
          ,p_attach_file_id         =>     p_attach_file_id          -- This procedure picks up the file name from FND_LOBS.
          ,p_attribute_type_codes   =>     l_attribute_type_codes
          ,p_attributes             =>     l_attributes
          ,p_component_citems       =>     NULL
          ,p_component_atypes       =>     NULL
          ,p_sort_order             =>     NULL
          ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- When the Deliverable becomes active, we will go in and approve all the underlying content items.
          ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
          ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
          ,p_api_version_number     =>     p_api_version
          ,p_init_msg_list          =>     l_init_msg_list
          ,px_content_item_id       =>     l_citem_id
          ,px_citem_ver_id          =>     l_citem_ver_id
          ,px_object_version_number =>     l_obj_ver_num
          ,x_return_status          =>     l_return_status
          ,x_msg_count              =>     l_msg_count
          ,x_msg_data               =>     l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After upsert_item.');
      AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id);
      AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
      AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

      -- There is a bug in IBC Code. The field attachment_attribute_code in the
      -- table ibc_citem_versions_tl is getting updated some times. Filed a bug on IBC
      -- to track this issue.
      -- Bug # is : 2290924.

      UPDATE ibc_citem_versions_tl
         SET attachment_attribute_code = 'ATTACHMENT' -- hardcoding as ATTACHMENT for Rich Content.
       WHERE citem_version_id = l_citem_ver_id ;

      -- We do not approve this item at this point.
      -- When the Deliverable becomes active, we will approve all underlying content items.
      --

      -- If the information about the parent content item is available, create the
      -- compound relation between the parent content item and the newly created RICH_CONTENT
      -- item.
      --
      IF p_parent_citem_ver_id IS NOT NULL
         AND
         p_parent_ctype_code IS NOT NULL
         AND
         p_attribute_type_code IS NOT NULL
      THEN
         -- prepare the data for insert.
         l_citem_attrs.extend();
         l_citem_attrs(1) := p_attribute_type_code;
         --
         l_citem_ids.extend();
         l_citem_ids(1) := l_citem_id;
         --
         l_dummy_sort_order.extend();
         l_dummy_sort_order(1) := 1;
         --

         AMS_Utility_PVT.Debug_Message( ' p_parent_citem_ver_id = ' || p_parent_citem_ver_id );
         AMS_Utility_PVT.Debug_Message( ' l_citem_ids(1) = ' || l_citem_ids(1) );
         AMS_Utility_PVT.Debug_Message( ' l_citem_attrs(1) = ' || l_citem_attrs(1) );
         AMS_Utility_PVT.Debug_Message( ' p_api_version = ' || p_api_version );
         AMS_Utility_PVT.Debug_Message( ' l_init_msg_list = ' || l_init_msg_list );

         IBC_CITEM_ADMIN_GRP.insert_components(
            p_citem_ver_id             =>    p_parent_citem_ver_id
            ,p_content_item_ids        =>    l_citem_ids
            ,p_attribute_type_codes    =>    l_citem_attrs
            ,p_sort_order              =>    l_dummy_sort_order   -- The NULL does not work.  -- The new API is supposed to be able to take NULL for this parameter.
            ,p_commit                  =>    FND_API.g_false
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
        );
      END IF;
      --
      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_ADD_COMPOUND_REL');
         RAISE FND_API.g_exc_error;
      END IF;

      IF g_using_locking = FND_API.g_true
      THEN

         -- At this stage we must UNLOCK this content item as we will soon commit this transaction.
         -- Call the procedure IBC_CITEM_ADMIN_GRP.unlock_content_item
         --

         IBC_CITEM_ADMIN_GRP.unlock_item(
            p_content_item_id          =>    l_citem_id
            ,p_commit                  =>    g_commit_on_lock_unlock
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
         );

         AMS_UTILITY_PVT.debug_message('After Unlock.');
         AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
            RAISE FND_API.g_exc_error;
         END IF;

      END IF;

   ELSIF p_dml_flag = 'U'
   THEN
      -- Update mode.
      -- For update we do not allow update of name and description.
      -- Only change is to the attribute bundle, and the attachment file.

      -- call update_content_item.

      update_content_item(
         p_citem_id                  =>    l_citem_id
         ,p_citem_version_id         =>    l_citem_ver_id
         ,p_content_type_code        =>    p_content_type_code
         ,p_content_item_name        =>    NULL                -- We do not allow update on this one yet.
         ,p_description              =>    NULL                -- We do not allow update on this one yet.
         ,p_delv_id                  =>    p_delv_id
         ,p_attr_types_for_update    =>    l_attribute_type_codes
         ,p_attr_values_for_update   =>    l_attributes
         ,p_attach_file_id           =>    p_attach_file_id
         ,p_attach_file_name         =>    p_attach_file_name
         ,p_commit                   =>    FND_API.g_false
         ,p_api_version              =>    p_api_version
         ,p_api_validation_level     =>    p_api_validation_level
         ,x_return_status            =>    l_return_status
         ,x_msg_count                =>    l_msg_count
         ,x_msg_data                 =>    l_msg_data
         ,p_replace_attr_bundle      =>    FND_API.g_true
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;


-- If we come till here, everything has been created successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
   x_return_status := l_return_status;
   px_citem_id := l_citem_id;
   px_citem_ver_id := l_citem_ver_id;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO manage_rich_content_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO manage_rich_content_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO manage_rich_content_PVT ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
--
END manage_rich_content;
--


-----------------------------------------------------------------------
-- PROCEDURE
--    manage_toc_section
--
-- PURPOSE
--    Manage a TOC Section Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be AMS_TOC.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Start Date
--       End Date
--       Owner Resource ID
--       Owner Resource Type
--    2. The optional input is as follows:
--       Content Item Id : If given Update is done.
--       Content Item Version Id : If given Update is done.
--       Description.
--       The Content Item Version ID of the Parent Content Item
--       The Content Type Code associated with the Parent Content Item.
--          If the above two are available, this procedure will create a
--          compound relation between the Parent Content Item Version ID and
--          the Content Item ID of the newly created Content Item.
--       VARCHAR2 caption.
--       VARCHAR2 list style.
--       VARCHAR2 Array of Attribute Type Codes.
--       VARCHAR2 Array of Attribute Values.
--       VARCHAR2 functional type which must be 'NORMAL'
--    3. This procedure performs the following steps:
--          1. Create a Basic Content Item for Rich Content with insert_basic_citem
--          2. Add the Meta Data with set_citem_meta.
--          4. Set the Attribute Bundle for this Content Item.
--          5. If the details of Parent Content Item are available,
--             create the compound relation between the parent content item and the
--             newly created RICH_CONTENT item.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    10-APR-2002   asaha     Created.
--
-----------------------------------------------------------------------
PROCEDURE manage_toc_section(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attr_types            IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values           IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_attribute_type_code   IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   px_citem_id             IN OUT NUMBER,
   px_citem_ver_id         IN OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2,
   p_dml_flag              IN  VARCHAR2,
   p_init_msg_list         IN  VARCHAR2                DEFAULT FND_API.g_true
)
IS
--
-- Declare the local variables and cursors here.
-- Cursor to select the Deliverable Details to record in the Content Item Data.
--
   CURSOR c_delv_details IS
     SELECT actual_avail_from_date
            ,actual_avail_to_date
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
   l_start_date                  DATE ;
   l_end_date                    DATE ;
--
   l_citem_ver_id                NUMBER ;
   l_citem_id                    NUMBER ;
   l_return_status               VARCHAR2(1) ;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000) ;
--
   l_obj_ver_num                 NUMBER ;
--
   l_citem_ids                   JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE() ;
   l_citem_attrs                 JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100() ;
   l_dummy_sort_order            JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE() ;
--
   l_init_msg_list               VARCHAR2(1)             := FND_API.g_true;
--
   l_api_version_number          CONSTANT NUMBER         := 1.0;
   l_api_name                    CONSTANT VARCHAR2(30)   := 'manage_toc_section';
   l_full_name                   CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
--
   l_attr_count                  NUMBER ;
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT manage_toc_section_PVT ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
   IF p_content_type_code <> G_TOC -- Should be a CONSTANT in the package.
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_WRONG_CTYPE_CODE');
      RAISE FND_API.g_exc_error;
   END IF;
--
-- Check if the call is for Create or Update.

   l_citem_id := px_citem_id ;
   l_citem_ver_id := px_citem_ver_id ;

   AMS_UTILITY_PVT.debug_message( 'l_citem_id = ' || l_citem_id );
   AMS_UTILITY_PVT.debug_message( 'l_citem_ver_id = ' || l_citem_ver_id );
   AMS_UTILITY_PVT.debug_message( 'p_dml_flag = ' || p_dml_flag );

   IF p_dml_flag <> 'C'
   THEN
      -- check if content item id and content item version id is available.
      IF l_citem_id IS NULL
         OR
         l_citem_ver_id IS NULL
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_NO_CITEM_OR_VER_ID');
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   -- For update, ideally we must check if the dates for the parent deliverable
   -- have changed and update the dates as well.
   -- To be done later.

   --
   --
   -- prepare the data for insert / update


   IF p_dml_flag = 'C'
   THEN
   -- Create a new Content Item in IBC Schema for incoming Content Type.

      -- Fetch the Deliverable Details.
      OPEN c_delv_details;
      FETCH c_delv_details INTO l_start_date, l_end_date;
      CLOSE c_delv_details;

   -- Call IBC_CITEM_ADMIN_GRP.upsert_item procedure.

      IBC_CITEM_ADMIN_GRP.upsert_item(
          p_ctype_code              =>     p_content_type_code
          ,p_citem_name             =>     p_content_item_name
          ,p_citem_description      =>     substr(p_description,1,2000)
          ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
          ,p_owner_resource_id      =>     p_owner_resource_id
          ,p_owner_resource_type    =>     p_owner_resource_type
          ,p_reference_code         =>     NULL                      -- Why is this needed?
          ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
          ,p_parent_item_id         =>     p_parent_citem_id         -- Specify the parent content item id. This item is visible only in the context of this parent.
          ,p_lock_flag              =>     g_lock_flag_value
          ,p_wd_restricted          =>     g_wd_restricted_flag_value
          ,p_start_date             =>     l_start_date
          ,p_end_date               =>     l_end_date
          ,p_attach_file_id         =>   NULL          -- This procedure picks up the file name from FND_LOBS.
          ,p_attribute_type_codes   =>     p_attr_types
          ,p_attributes             =>     p_attr_values
          ,p_component_citems       =>     NULL
          ,p_component_atypes       =>     NULL
          ,p_sort_order             =>     NULL
          ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- When the Deliverable becomes active, we will go in and approve all the underlying content items.
          ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
          ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
          ,p_api_version_number     =>     p_api_version
          ,p_init_msg_list          =>     l_init_msg_list
          ,px_content_item_id       =>     l_citem_id
          ,px_citem_ver_id          =>     l_citem_ver_id
          ,px_object_version_number =>     l_obj_ver_num
          ,x_return_status          =>     l_return_status
          ,x_msg_count              =>     l_msg_count
          ,x_msg_data               =>     l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After upsert_item.');
      AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id);
      AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
      AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

      -- We do not approve this item at this point.
      -- When the Deliverable becomes active, we will approve all underlying content items.
      --

      -- If the information about the parent content item is available, create the
      -- compound relation between the parent content item and the newly created RICH_CONTENT
      -- item.
      --
      IF p_parent_citem_ver_id IS NOT NULL
         AND
         p_parent_ctype_code IS NOT NULL
         AND
         p_attribute_type_code IS NOT NULL
      THEN
         -- prepare the data for insert.
         l_citem_attrs.extend();
         l_citem_attrs(1) := p_attribute_type_code;
         --
         l_citem_ids.extend();
         l_citem_ids(1) := l_citem_id;
         --
         l_dummy_sort_order.extend();
         l_dummy_sort_order(1) := 1;
         --

         AMS_Utility_PVT.Debug_Message( ' p_parent_citem_ver_id = ' || p_parent_citem_ver_id );
         AMS_Utility_PVT.Debug_Message( ' l_citem_ids(1) = ' || l_citem_ids(1) );
         AMS_Utility_PVT.Debug_Message( ' l_citem_attrs(1) = ' || l_citem_attrs(1) );
         AMS_Utility_PVT.Debug_Message( ' p_api_version = ' || p_api_version );
         AMS_Utility_PVT.Debug_Message( ' l_init_msg_list = ' || l_init_msg_list );

         IBC_CITEM_ADMIN_GRP.insert_components(
            p_citem_ver_id             =>    p_parent_citem_ver_id
            ,p_content_item_ids        =>    l_citem_ids
            ,p_attribute_type_codes    =>    l_citem_attrs
            ,p_sort_order              =>    l_dummy_sort_order   -- The NULL does not work.  -- The new API is supposed to be able to take NULL for this parameter.
            ,p_commit                  =>    FND_API.g_false
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
        );
      END IF;
      --
      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_ADD_COMPOUND_REL');
         RAISE FND_API.g_exc_error;
      END IF;

      IF g_using_locking = FND_API.g_true
      THEN

         -- At this stage we must UNLOCK this content item as we will soon commit this transaction.
         -- Call the procedure IBC_CITEM_ADMIN_GRP.unlock_content_item
         --

         IBC_CITEM_ADMIN_GRP.unlock_item(
            p_content_item_id          =>    l_citem_id
            ,p_commit                  =>    g_commit_on_lock_unlock
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
         );

         AMS_UTILITY_PVT.debug_message('After Unlock.');
         AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
            RAISE FND_API.g_exc_error;
         END IF;

      END IF;

   ELSIF p_dml_flag = 'U'
   THEN
      -- Update mode.
      -- For update we do not allow update of name and description.
      -- Only change is to the attribute bundle.

      -- call update_content_item.

      update_content_item(
         p_citem_id                  =>    l_citem_id
         ,p_citem_version_id         =>    l_citem_ver_id
         ,p_content_type_code        =>    p_content_type_code
         ,p_content_item_name        =>    NULL                -- We do not allow update on this one yet.
         ,p_description              =>    NULL                -- We do not allow update on this one yet.
         ,p_delv_id                  =>    p_delv_id
         ,p_attr_types_for_update    =>    p_attr_types
         ,p_attr_values_for_update   =>    p_attr_values
         ,p_attach_file_id           =>    NULL
         ,p_attach_file_name         =>    NULL
         ,p_commit                   =>    FND_API.g_false
         ,p_api_version              =>    p_api_version
         ,p_api_validation_level     =>    p_api_validation_level
         ,x_return_status            =>    l_return_status
         ,x_msg_count                =>    l_msg_count
         ,x_msg_data                 =>    l_msg_data
         ,p_replace_attr_bundle      =>    FND_API.g_true
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;


-- If we come till here, everything has been created successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
   x_return_status := l_return_status;
   px_citem_id := l_citem_id;
   px_citem_ver_id := l_citem_ver_id;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO manage_toc_section_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO manage_toc_section_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO manage_toc_section_PVT ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
--
END manage_toc_section;




--
-----------------------------------------------------------------------
-- PROCEDURE
--    get_rich_content_data
--
-- PURPOSE
--    Get the data from Rich Content Item.
--
-- NOTES
--    1. The required input is as follows:
--         content_item_id
--    2. This procedure returns the following data back to the caller.
--         citem_version_id for the content item.
--         attachment_file_id
--         attachment_file_name
--         citem_name
--         attribute_types (array)
--         attribute_values (array)
--
-----------------------------------------------------------------------
PROCEDURE get_rich_content_data(
   p_citem_id              IN  NUMBER,
   p_api_version           IN  NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_attach_file_id        OUT NUMBER,
   x_attach_file_name      OUT VARCHAR2,
   x_citem_name            OUT VARCHAR2,
   x_attribute_types       OUT JTF_VARCHAR2_TABLE_100,
   x_attribute_values      OUT JTF_VARCHAR2_TABLE_4000,
   x_object_version_number OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
-- Declare the local variables and cursors here.
-- Cursor to select the latest citem version for a content item.
--
   CURSOR c_max_version IS
     SELECT MAX(citem_version_id)
     FROM   ibc_citem_versions_b
     WHERE  content_item_id = p_citem_id ;
--
   l_citem_ver_id      NUMBER ;
   l_status                VARCHAR2(30) ;
--
   l_attach_file_id        NUMBER ;
   l_attach_file_name      VARCHAR2(240) ;
   l_citem_name            VARCHAR2(240) ;
   l_description           VARCHAR2(2000) ;
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 ;
   l_attribute_type_names  JTF_VARCHAR2_TABLE_300 ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 ;
   l_cpnt_citems           JTF_NUMBER_TABLE ;
   l_cpnt_ctypes           JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_attrib_types     JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_citem_names      JTF_VARCHAR2_TABLE_300 ;
   l_cpnt_owner_ids        JTF_NUMBER_TABLE ;
   l_cpnt_owner_types      JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_owner_names      JTF_VARCHAR2_TABLE_400 ;
   l_cpnt_sort_orders      JTF_NUMBER_TABLE ;
   l_object_version_number NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Get_Rich_Content_Data';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
BEGIN
   --
   x_return_status := FND_API.g_ret_sts_success;
   --
   -- Fetch the latest citem version id.
   OPEN c_max_version;
   FETCH c_max_version INTO l_citem_ver_id;
   CLOSE c_max_version;

   -- Call get_content_item_data.
   get_content_item_data(
      p_citem_id                  =>    p_citem_id
      ,p_citem_ver_id             =>    l_citem_ver_id
      ,p_api_version              =>    p_api_version
      ,x_status                   =>    l_status
      ,x_attach_file_id           =>    l_attach_file_id
      ,x_attach_file_name         =>    l_attach_file_name
      ,x_citem_name               =>    l_citem_name
      ,x_description              =>    l_description
      ,x_attribute_type_codes     =>    l_attribute_type_codes
      ,x_attribute_type_names     =>    l_attribute_type_names
      ,x_attributes               =>    l_attributes
      ,x_cpnt_citem_ids           =>    l_cpnt_citems
      ,x_cpnt_ctype_codes         =>    l_cpnt_ctypes
      ,x_cpnt_attrib_types        =>    l_cpnt_attrib_types
      ,x_cpnt_citem_names         =>    l_cpnt_citem_names
      ,x_cpnt_sort_orders         =>    l_cpnt_sort_orders
      ,x_object_version_number    =>    l_object_version_number
      ,x_return_status            =>    l_return_status
      ,x_msg_count                =>    l_msg_count
      ,x_msg_data                 =>    l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_GET_RICH_CTNT');
      RAISE FND_API.g_exc_error;
   END IF;

   x_citem_ver_id := l_citem_ver_id;
   x_return_status := l_return_status;
   x_attach_file_id := l_attach_file_id;
   x_attach_file_name := l_attach_file_name;
   x_citem_name := l_citem_name;
   x_attribute_types := l_attribute_type_codes;
   x_attribute_values := l_attributes;
   x_object_version_number := l_object_version_number;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );


END get_rich_content_data;

-----------------------------------------------------------------------
-- PROCEDURE
--    get_content_item_data
--
-- PURPOSE
--    Get the Content Item Details.
--
-- NOTES
--    1. The required input is as follows:
--         content_item_id
--         content_item_version_id
--    2. This procedure calls the get_citem from IBC_CITEM_ADMIN_GRP package.
--       It only sends the useful data back to the caller.
--
-----------------------------------------------------------------------
PROCEDURE get_content_item_data(
   p_citem_id              IN  NUMBER,
   p_citem_ver_id          IN  NUMBER,
   p_api_version           IN  NUMBER,
   x_status                OUT VARCHAR2,
   x_attach_file_id        OUT NUMBER,
   x_attach_file_name      OUT VARCHAR2,
   x_citem_name            OUT VARCHAR2,
   x_description           OUT VARCHAR2,
   x_attribute_type_codes  OUT JTF_VARCHAR2_TABLE_100,
   x_attribute_type_names  OUT JTF_VARCHAR2_TABLE_300,
   x_attributes            OUT JTF_VARCHAR2_TABLE_4000,
   x_cpnt_citem_ids        OUT JTF_NUMBER_TABLE,
   x_cpnt_ctype_codes      OUT JTF_VARCHAR2_TABLE_100,
   x_cpnt_attrib_types     OUT JTF_VARCHAR2_TABLE_100,
   x_cpnt_citem_names      OUT JTF_VARCHAR2_TABLE_300,
   x_cpnt_sort_orders      OUT JTF_NUMBER_TABLE,
   x_object_version_number OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
   l_citem_name            VARCHAR2(240) ;
   l_citem_version         NUMBER ;
   l_citem_id              NUMBER ;
   l_dir_node_id           NUMBER ;
   l_dir_node_name         VARCHAR2(240) ;
   l_dir_node_code         VARCHAR2(240) ;
   l_status                VARCHAR2(30) ;
   l_version_status        VARCHAR2(30) ;
   l_version_number        NUMBER ;
   l_citem_description     VARCHAR2(2000) ;
   l_ctype_code            VARCHAR2(30) ;
   l_ctype_name            VARCHAR2(240) ;
   l_start_date            DATE ;
   l_end_date              DATE ;
   l_owner_resource_id     NUMBER ;
   l_owner_resource_type   VARCHAR2(30) ;
   l_owner_name            VARCHAR2(240) ;
   l_reference_code        VARCHAR2(30) ;
   l_trans_required        VARCHAR2(1) ;
   l_parent_item_id        VARCHAR2(240) ;
   l_locked_by             VARCHAR2(30) ; -- Actually LOCKED_BY in ibc_citems_v is a NUMBER(15) field.
   l_wd_restricted         VARCHAR2(1) ;
   l_attach_file_id        NUMBER ;
   l_attach_file_name      VARCHAR2(240) ;
   l_object_version_number NUMBER ;
   l_created_by            NUMBER ;
   l_creation_date         DATE ;
   l_last_updated_by       NUMBER ;
   l_last_update_date      DATE ;
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 ;
   l_attribute_type_names  JTF_VARCHAR2_TABLE_300 ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 ;
   l_cpnt_citems           JTF_NUMBER_TABLE ;
   l_cpnt_ctypes           JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_attrib_types     JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_citem_names      JTF_VARCHAR2_TABLE_300 ;
   l_cpnt_owner_ids        JTF_NUMBER_TABLE ;
   l_cpnt_owner_types      JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_owner_names      JTF_VARCHAR2_TABLE_400 ;
   l_cpnt_sort_orders      JTF_NUMBER_TABLE ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Get_Content_Item_Data';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
BEGIN
   --
   x_return_status := FND_API.g_ret_sts_success;
   AMS_UTILITY_PVT.debug_message(g_pkg_name || '.' || l_api_name || ' Entered the proc.');
   l_msg_data := 'Citem id = ' || p_citem_id;
   AMS_UTILITY_PVT.debug_message(g_pkg_name || '.' || l_api_name || ' ' || l_msg_data);
   l_msg_data := 'Citem Version id = ' || p_citem_ver_id;
   AMS_UTILITY_PVT.debug_message(g_pkg_name || '.' || l_api_name || ' ' || l_msg_data);
   l_msg_data := 'API Version = ' || p_api_version;
   AMS_UTILITY_PVT.debug_message(g_pkg_name || '.' || l_api_name || ' ' || l_msg_data);

   --
   -- Call Get_item procedure.

   IBC_CITEM_ADMIN_GRP.get_item(
      p_citem_ver_id             =>       p_citem_ver_id
      ,p_init_msg_list           =>       FND_API.g_true
      ,p_api_version_number      =>       p_api_version
      ,x_content_item_id         =>       l_citem_id
      ,x_citem_name              =>       l_citem_name
      ,x_citem_version           =>       l_citem_version
      ,x_dir_node_id             =>       l_dir_node_id
      ,x_dir_node_name           =>       l_dir_node_name
      ,x_dir_node_code           =>       l_dir_node_code
      ,x_item_status             =>       l_status
      ,x_version_status          =>       l_version_status
      --,x_version_number          =>       l_version_number
      ,x_citem_description       =>       l_citem_description
      ,x_ctype_code              =>       l_ctype_code
      ,x_ctype_name              =>       l_ctype_name
      ,x_start_date              =>       l_start_date
      ,x_end_date                =>       l_end_date
      ,x_owner_resource_id       =>       l_owner_resource_id
      ,x_owner_resource_type     =>       l_owner_resource_type
      ,x_reference_code          =>       l_reference_code
      ,x_trans_required          =>       l_trans_required
      ,x_parent_item_id          =>       l_parent_item_id
      ,x_locked_by               =>       l_locked_by
      ,x_wd_restricted           =>       l_wd_restricted
      ,x_attach_file_id          =>       l_attach_file_id
      ,x_attach_file_name        =>       l_attach_file_name
      ,x_object_version_number   =>       l_object_version_number
      ,x_created_by              =>       l_created_by
      ,x_creation_date           =>       l_creation_date
      ,x_last_updated_by         =>       l_last_updated_by
      ,x_last_update_date        =>       l_last_update_date
      ,x_attribute_type_codes    =>       l_attribute_type_codes
      ,x_attribute_type_names    =>       l_attribute_type_names
      ,x_attributes              =>       l_attributes
      ,x_component_citems        =>       l_cpnt_citems
      -- Not in the new API ,x_cpnt_ctypes           =>       l_cpnt_ctypes
      ,x_component_attrib_types  =>       l_cpnt_attrib_types
      ,x_component_citem_names   =>       l_cpnt_citem_names
      ,x_component_owner_ids     =>       l_cpnt_owner_ids
      ,x_component_owner_types   =>       l_cpnt_owner_types
      -- Not in the new API ,x_cpnt_owner_names        =>       l_cpnt_owner_names
      ,x_component_sort_orders   =>       l_cpnt_sort_orders
      ,x_return_status           =>       l_return_status
      ,x_msg_count               =>       l_msg_count
      ,x_msg_data                =>       l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_GET_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;


   -- Print the data for debug purposes.
/*
   AMS_UTILITY_PVT.debug_message(p_citem_ver_id);
   AMS_UTILITY_PVT.debug_message(p_api_version);
   AMS_UTILITY_PVT.debug_message(l_citem_id);
   AMS_UTILITY_PVT.debug_message(l_citem_name);
   AMS_UTILITY_PVT.debug_message(l_citem_version);
   AMS_UTILITY_PVT.debug_message(l_dir_node_id);
   AMS_UTILITY_PVT.debug_message(l_dir_node_name);
   AMS_UTILITY_PVT.debug_message(l_status);
   AMS_UTILITY_PVT.debug_message(l_citem_description);
   AMS_UTILITY_PVT.debug_message(l_ctype_code);
   AMS_UTILITY_PVT.debug_message(l_ctype_name);
   AMS_UTILITY_PVT.debug_message(l_start_date);
   AMS_UTILITY_PVT.debug_message(l_end_date);
   AMS_UTILITY_PVT.debug_message(l_owner_resource_id);
   AMS_UTILITY_PVT.debug_message(l_owner_resource_type);
   AMS_UTILITY_PVT.debug_message(l_owner_name);
   AMS_UTILITY_PVT.debug_message(l_reference_code);
   AMS_UTILITY_PVT.debug_message(l_trans_required);
   AMS_UTILITY_PVT.debug_message(l_reusable_flag);
   AMS_UTILITY_PVT.debug_message(l_locked_by);
   AMS_UTILITY_PVT.debug_message(l_wd_restricted);
   AMS_UTILITY_PVT.debug_message(l_attach_file_id);
   AMS_UTILITY_PVT.debug_message(l_attach_file_name);
   AMS_UTILITY_PVT.debug_message(l_object_version_number);
   AMS_UTILITY_PVT.debug_message(l_created_by);
   AMS_UTILITY_PVT.debug_message(l_creation_date);
   AMS_UTILITY_PVT.debug_message(l_last_updated_by);
   AMS_UTILITY_PVT.debug_message(l_last_update_date);
   if l_attribute_type_codes is null
   then
   AMS_UTILITY_PVT.debug_message('l_attribute_type_codes is null');
   else
   AMS_UTILITY_PVT.debug_message('l_attribute_type_codes is not null');
   end if;
   if l_attribute_type_names is null
   then
   AMS_UTILITY_PVT.debug_message('l_attribute_type_names is null');
   else
   AMS_UTILITY_PVT.debug_message('l_attribute_type_names is not null');
   end if;
   if l_attributes is null
   then
   AMS_UTILITY_PVT.debug_message('l_attributes is null');
   else
   AMS_UTILITY_PVT.debug_message('l_attributes is not null');
   end if;
   if l_cpnt_citems is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_citems is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_citems is not null');
   end if;
   if l_cpnt_ctypes is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_ctypes is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_ctypes is not null');
   end if;
   if l_cpnt_attrib_types is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_attrib_types is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_attrib_types is not null');
   end if;
   if l_cpnt_citem_names is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_citem_names is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_citem_names is not null');
   end if;
   if l_cpnt_owner_ids is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_owner_ids is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_owner_ids is not null');
   end if;
   if l_cpnt_owner_ids is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_owner_types is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_owner_types is not null');
   end if;
   if l_cpnt_owner_names is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_owner_names is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_owner_names is not null');
   end if;
   if l_cpnt_sort_orders is null
   then
   AMS_UTILITY_PVT.debug_message('l_cpnt_sort_orders is null');
   else
   AMS_UTILITY_PVT.debug_message('l_cpnt_sort_orders is not null');
   end if;
   AMS_UTILITY_PVT.debug_message(l_return_status);
   AMS_UTILITY_PVT.debug_message(l_msg_count);
   AMS_UTILITY_PVT.debug_message(l_msg_data);
*/


   x_return_status := l_return_status;
   x_status := l_status;
   x_attach_file_id := l_attach_file_id;
   x_attach_file_name := l_attach_file_name;
   x_citem_name := l_citem_name;
   x_description := l_citem_description;
   x_attribute_type_codes := l_attribute_type_codes;
   x_attribute_type_names := l_attribute_type_names;
   x_attributes := l_attributes;
   x_cpnt_citem_ids := l_cpnt_citems;
   x_cpnt_ctype_codes := l_cpnt_ctypes;
   x_cpnt_citem_names := l_cpnt_citem_names;
   x_cpnt_sort_orders := l_cpnt_sort_orders;
   x_object_version_number := l_object_version_number;

   -- Standard call to get message count and if count is 1, get message info.

   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );


END get_content_item_data;

-----------------------------------------------------------------------
-- PROCEDURE
--    create_cp_image
--
-- PURPOSE
--    Create the CP_IMAGE Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be CP_IMAGE.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Deliverable ID.
--       Two Arrays : one with all the attribute type codes for CP_IMAGE.
--                    second with the corresponding values for CP_IMAGE.
--    2. The optional input is as follows:
--       Description.
--       Attribute Type Code for the Parent's Section.
--       The Content Item Version ID of the Parent Content Item
--       The Content Type Code associated with the Parent Content Item.
--          If the above two are available, this procedure will create a
--          compound relation between the Parent Content Item Version ID and
--          the Content Item ID of the newly created Content Item.
--       Attachment File Id of the newly uploaded binary file.
--       Attachment File Name for the same.
--       Two Arrays : one with the attribute type codes for IMAGE.
--                    second with the corresponding values for IMAGE.
--          If the above four are available, this procedure will create a Content Item
--          of type IMAGE (the OCM's IMAGE) first and use the content_item_id of
--          this content item for CP_IMAGE.
--       If the above two are unavailable, the content_item_id of the IMAGE content item
--       referred to by this CP_IMAGE must be provided.
--    3. This procedure performs the following steps:
--          1. Create the IMAGE content item if necessary. It will call the bulk-insert
--             procedure for this task. The IMAGE content item is marked as APPROVED
--             upon creation.
--          2. Create the CP_IMAGE content item using the bulk-insert call. This item
--             however is not marked as APPROVED.
--          NOTE that the FUNCTIONAL_TYPE for CP_IMAGE items is NORMAL.
--          3. If the details of Parent Content Item are available,
--             create the compound relation between the parent content item and the
--             newly created CP_IMAGE item.
--    4. This procedure returns the fact that it is successful.
--       It also returns the citem_id and citem_ver_id for the newly created CP_IMAGE item.
--
-- HISTORY
--    17-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE create_cp_image(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_delv_id               IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_resource_type         IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2                  DEFAULT FND_API.g_true, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attr_types_cp_image   IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_cp_image  IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_attr_types_image      IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_image     IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_parent_attr_type_code IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_commit                IN  VARCHAR2                  DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                    DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                    DEFAULT FND_API.g_valid_level_full,
   x_cp_image_citem_id     OUT NUMBER,
   x_cp_image_citem_ver_id OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
-- Cursor to select the Deliverable Details to record in the Content Item Data.
--
   CURSOR c_delv_details IS
     SELECT actual_avail_from_date
            ,actual_avail_to_date
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
   l_start_date            DATE ;
   l_end_date              DATE ;
--
   l_citem_ver_id          NUMBER ;
   l_citem_id              NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_image_citem_id        NUMBER ;
   l_image_citem_ver_id    NUMBER ;
   l_image_obj_ver_num     NUMBER ;
   l_created_image         VARCHAR2(1) :=  FND_API.g_false;
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
   l_citem_ids             JTF_NUMBER_TABLE := JTF_NUMBER_TABLE() ;
   l_dummy_sort_order      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE() ;
   l_citem_attrs           JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Create_CP_Image';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
   l_err_msg               VARCHAR2(4000);
   l_init_msg_list         VARCHAR2(1)           := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER       := 1.0;
--
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT create_cp_image_PVT ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
-- This procedure will create a new Content Item in IBC Schema.


-- Fetch the Deliverable Details.
   OPEN c_delv_details;
   FETCH c_delv_details INTO l_start_date, l_end_date;
   CLOSE c_delv_details;
--
-- push this data to FND_Messages so that we see it in the JSPs as well.
   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name, 'Data for IMAGE');
   IF p_attr_types_image IS NOT NULL
      AND
      p_attr_values_image IS NOT NULL
   THEN
      FOR i IN p_attr_types_image.first .. p_attr_types_image.last
      LOOP
         l_err_msg := i || ' : >' || p_attr_types_image(i) || '< : >' || p_attr_values_image(i) || '<';
         AMS_UTILITY_PVT.debug_message(l_err_msg);
      END LOOP;
   END IF;
   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name, 'Data for CP_IMAGE');
   FOR i IN p_attr_types_cp_image.first .. p_attr_types_cp_image.last
   LOOP
      l_err_msg := i || ' : >' || p_attr_types_cp_image(i) || '< : >' || p_attr_values_cp_image(i) || '<';
      AMS_UTILITY_PVT.debug_message(l_err_msg);
   END LOOP;
   l_init_msg_list := FND_API.g_false;


-- Check if we need to create the IMAGE content type.
   IF p_attach_file_id IS NOT NULL
      AND
      p_attach_file_name IS NOT NULL
      AND
      p_attr_types_image IS NOT NULL
      AND
      p_attr_values_image IS NOT NULL
   THEN
      -- IMAGE content type has the following attributes:
      /*
         attr_type   data_type      min_inst      max_inst data_length
         ALT_TEXT    string         0             1
         ATTACHMENT  attachment     0             1
         DESCRIPTION string         1             1        2000
         HEIGHT      decimal        0             1
         IMAGE_TYPE  string         0             1
         LINK        url            0             1
         NAME        string         1             1         240
         WIDTH       decimal        0             1
      */
      -- Create the content item of type IMAGE.
      -- Call bulk_insert procedure.
      AMS_UTILITY_PVT.debug_message('file id = ' || p_attach_file_id);
      AMS_UTILITY_PVT.debug_message('file name = ' || p_attach_file_name);
      AMS_UTILITY_PVT.debug_message('start date = ' || l_start_date);

      -- Call the procedure upsert_item. This method allows creation of Content Item from one
      -- single API.

      -- The new IBC ARU added validations to check if the value of the incoming
      -- boolean attributes is T or F. It appears that it cannot be NULL.
      -- Added the following piece of code that makes the boolean values as 'F'
      -- if incoming values are null.
      /*
      FOR i IN p_attr_types_image.first .. p_attr_types_image.last
      LOOP
         -- If the associated value is NULL for the boolean type of attributes,
         -- make the value 'F'
         -- Currently hardcoding the attribute type codes as we know which attributes
         -- of IBC_IMAGE are of type boolean.
         IF p_attr_values_image(i) = 'F'
            ||
            p_attr_values_image(i) = 'T'
         THEN
            null;
            -- do not change the data.
         ELSE
            -- Check if the attribute is one of the boolean types for IBC_IMAGE and
            -- make the value 'F'.
            IF p_attr_types_image(i) = ''
         END IF;

      END LOOP;
      */

      IBC_CITEM_ADMIN_GRP.upsert_item(
          p_ctype_code              =>     G_IBC_IMAGE
          ,p_citem_name             =>     p_attach_file_name
          ,p_citem_description      =>     p_attach_file_name        -- Currently we do not expose the description on the UI, however the IBC_IMAGE type says that DESCRIPTION is a required field. So sending the file name as description.
          ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
          ,p_owner_resource_id      =>     p_resource_id
          ,p_owner_resource_type    =>     p_resource_type
          ,p_reference_code         =>     NULL                      -- Why is this needed?
          ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
          ,p_parent_item_id         =>     NULL                      -- There is no parent for the item of type IBC_IMAGE.
          ,p_lock_flag              =>     g_lock_flag_value
          ,p_wd_restricted          =>     g_wd_restricted_flag_value
          ,p_start_date             =>     sysdate                   -- use the sysdate as the start date for the IMAGE content item.
          ,p_end_date               =>     NULL                      -- Leave the end date as NULL. The idea is to allow the usage of this basic IBC_IMAGE item indefinitely.
          ,p_attach_file_id         =>     p_attach_file_id
          ,p_attribute_type_codes   =>     p_attr_types_image
          ,p_attributes             =>     p_attr_values_image
          ,p_component_citems       =>     NULL
          ,p_component_atypes       =>     NULL
          ,p_sort_order             =>     NULL
          ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- Soon after the content item of type IBC_IMAGE is created successfully, we will go ahead and approve this item.
          ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
          ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
          ,p_api_version_number     =>     p_api_version
          ,p_init_msg_list          =>     l_init_msg_list
          ,px_content_item_id       =>     l_image_citem_id
          ,px_citem_ver_id          =>     l_image_citem_ver_id
          ,px_object_version_number =>     l_image_obj_ver_num
          ,x_return_status          =>     l_return_status
          ,x_msg_count              =>     l_msg_count
          ,x_msg_data               =>     l_msg_data

      );


      AMS_UTILITY_PVT.debug_message('After upsert_item of type IBC_IMAGE');
      AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_image_citem_id );
      AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_image_citem_ver_id );
      AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_image_obj_ver_num );
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_IMAGE_ITEM');
         RAISE FND_API.g_exc_error;
      ELSE
         l_created_image := FND_API.g_true;
      END IF;

      l_init_msg_list := FND_API.g_false;

      -- Approve this content item of type IBC_IMAGE.

      IBC_CITEM_ADMIN_GRP.approve_item(
         p_citem_ver_id                =>    l_image_citem_ver_id
         ,p_commit                     =>    FND_API.g_false
         ,p_api_version_number         =>    p_api_version
         ,p_init_msg_list              =>    l_init_msg_list
         ,px_object_version_number     =>    l_image_obj_ver_num
         ,x_return_status              =>    l_return_status
         ,x_msg_count                  =>    l_msg_count
         ,x_msg_data                   =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_APPROVE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- If we reach till here we can proceed with creation of CP_IMAGE item.

   l_attribute_type_codes := p_attr_types_cp_image;
   l_attributes := p_attr_values_cp_image;

   -- Check if there was a newly created image.
   -- If so, we have to set the two attributes to the array of CP_IMAGE attributes.
   -- One for attachment_file_id and one for ocm_image_id.
   IF l_created_image = FND_API.g_true
   THEN
      -- Substitute the values for the above two attributes.
      FOR i IN l_attribute_type_codes.first .. l_attribute_type_codes.last
      LOOP
        IF l_attribute_type_codes(i) = 'ATTACHMENT_FILE_ID'
        THEN
            l_attributes(i) := NULL; -- set it to NULL. The Runtime code picks up the latest file id.
        END IF;
        IF l_attribute_type_codes(i) = 'OCM_IMAGE_ID'
        THEN
            l_attributes(i) := l_image_citem_id;
        END IF;
      END LOOP;
   END IF;

   -- Create the CP_IMAGE item.
   -- Call upsert_item.

   -- Call the procedure upsert_item. This method allows creation of Content Item from one
   -- single API.

   IBC_CITEM_ADMIN_GRP.upsert_item(
       p_ctype_code              =>     G_CP_IMAGE
       ,p_citem_name             =>     p_content_item_name
       ,p_citem_description      =>     NULL                      -- currently we do not expose the description on the UI.
       ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
       ,p_owner_resource_id      =>     p_resource_id
       ,p_owner_resource_type    =>     p_resource_type
       ,p_reference_code         =>     NULL                      -- Why is this needed?
       ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
       ,p_parent_item_id         =>     p_parent_citem_id         -- Specify the parent content item id. This item is visible only in the context of this parent.
       ,p_lock_flag              =>     g_lock_flag_value
       ,p_wd_restricted          =>     g_wd_restricted_flag_value
       ,p_start_date             =>     l_start_date
       ,p_end_date               =>     l_end_date
       ,p_attach_file_id         =>     NULL                      -- Note that CP_IMAGE item does not have any attachment.
       ,p_attribute_type_codes   =>     l_attribute_type_codes
       ,p_attributes             =>     l_attributes
       ,p_component_citems       =>     NULL
       ,p_component_atypes       =>     NULL
       ,p_sort_order             =>     NULL
       ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- We will approve the underlying content items when the deliverable gets approved.
       ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
       ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
       ,p_api_version_number     =>     p_api_version
       ,p_init_msg_list          =>     l_init_msg_list
       ,px_content_item_id       =>     l_citem_id
       ,px_citem_ver_id          =>     l_citem_ver_id
       ,px_object_version_number =>     l_obj_ver_num
       ,x_return_status          =>     l_return_status
       ,x_msg_count              =>     l_msg_count
       ,x_msg_data               =>     l_msg_data

   );

   AMS_UTILITY_PVT.debug_message('After upsert_item of type CP_IMAGE');
   AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id );
   AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id );
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num );
   AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_CP_IMAGE');
      RAISE FND_API.g_exc_error;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- We do not Approve the CP_IMAGE Item at this stage.
   -- When the deliverable gets approved and the status becomes active, we will approve all the underlying content items.
   --

   -- If we reach till here, we have created the CP_IMAGE correctly.
   -- Add the Compound Relation with it's parent if necessary.

   IF p_parent_citem_ver_id IS NOT NULL
      AND
      p_parent_ctype_code IS NOT NULL
      AND
      p_parent_attr_type_code IS NOT NULL
   THEN
      -- prepare the data for insert.
      l_citem_attrs.extend();
      l_citem_attrs(1) := p_parent_attr_type_code;
      --
      l_citem_ids.extend();
      l_citem_ids(1) := l_citem_id;
      --
      l_dummy_sort_order.extend();
      l_dummy_sort_order(1) := 1;
      --
      AMS_UTILITY_PVT.debug_message('parent_citem_ver_id = ' || p_parent_citem_ver_id);
      AMS_UTILITY_PVT.debug_message('parent_ctype_code = ' || p_parent_ctype_code);
      AMS_UTILITY_PVT.debug_message('citem_attr = ' || l_citem_attrs(1));
      AMS_UTILITY_PVT.debug_message('citem_id = ' || l_citem_ids(1));

      IBC_CITEM_ADMIN_GRP.insert_components(
         p_citem_ver_id             =>    p_parent_citem_ver_id
         ,p_content_item_ids        =>    l_citem_ids
         ,p_attribute_type_codes    =>    l_citem_attrs
         ,p_sort_order              =>    l_dummy_sort_order   -- The NULL does not work.  -- The new API is supposed to be able to take NULL for this parameter.
         ,p_commit                  =>    FND_API.g_false
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
     );

   END IF;

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_ADD_COMPOUND_REL');
      RAISE FND_API.g_exc_error;
   END IF;

   -- If we reach till here, we can unlock the IMAGE item and then
   -- unlock the CP_IMAGE item.

   IF l_created_image = FND_API.g_true
   THEN

      IF g_using_locking = FND_API.g_true
      THEN

         IBC_CITEM_ADMIN_GRP.unlock_item(
            p_content_item_id          =>    l_image_citem_id
            ,p_commit                  =>    g_commit_on_lock_unlock
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
         );

         AMS_UTILITY_PVT.debug_message('After Unlock.');
         AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

         --
         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_IMAGE');
            RAISE FND_API.g_exc_error;
         END IF;

      END IF;
      --
   END IF;

   IF g_using_locking = FND_API.g_true
   THEN

      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    l_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CP_IMAGE');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- If we come till here, everything has been created successfully.
   -- Commit the work and set the output values.

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   x_cp_image_citem_id := l_citem_id;
   x_cp_image_citem_ver_id := l_citem_ver_id;
   x_return_status := l_return_status;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_cp_image_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_cp_image_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO create_cp_image_PVT ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
END create_cp_image;
--


-----------------------------------------------------------------------
-- PROCEDURE
--    update_cp_image
--
-- PURPOSE
--    Update the CP_IMAGE Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Section. This must be CP_IMAGE.
--       Content Item Id for the CP_IMAGE item.
--       Content Item Name. This is same as the Section Name.
--       Content Item Version Id for the CP_IMAGE item.
--       Deliverable ID.
--       Two Arrays : one with all the attribute type codes for CP_IMAGE.
--                    second with the corresponding values for CP_IMAGE.
--    2. The optional input is as follows:
--       Description.
--       Attachment File Id of the newly uploaded binary file.
--       Attachment File Name for the same.
--       Two Arrays : one with the attribute type codes for IMAGE.
--                    second with the corresponding values for IMAGE.
--          If the above four are available, this procedure will create a Content Item
--          of type IMAGE (the OCM's IMAGE) first and use the content_item_id of
--          this content item for CP_IMAGE.
--       If the above two are unavailable, the content_item_id of the IMAGE content item
--       referred to by this CP_IMAGE must be provided.
--    3. This procedure performs the following steps:
--          1. Create the IMAGE content item if necessary. It will call the bulk-insert
--             procedure for this task. The IMAGE content item is marked as APPROVED
--             upon creation.
--          2. Update the CP_IMAGE content item using the following calls:
--             set_citem_att_bundle (with all the attributes with the changed values).
--          NOTE that the FUNCTIONAL_TYPE for CP_IMAGE items is NORMAL.
--          NOTE that we will not call the following for now:
--             set_citem_meta will not be called as none of the meta items are exposed
--             in the UI for CP_IMAGE.
--             update_citem_basic will not be called as we do not expose Description
--             in the UI and we do not allow the change of the Name.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    19-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE update_cp_image(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_cp_image_citem_id     IN  NUMBER,
   p_cp_image_citem_ver_id IN  NUMBER,
   p_delv_id               IN  NUMBER,
   p_resource_id           IN  NUMBER,
   p_resource_type         IN  VARCHAR2,
   p_attr_types_cp_image   IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_cp_image  IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_description           IN  VARCHAR2,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_attr_types_image      IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_image     IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_commit                IN  VARCHAR2                  DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                    DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                    DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_image_citem_id        NUMBER ;
   l_image_citem_ver_id    NUMBER ;
   l_cp_image_citem_ver_id NUMBER ;
   l_image_obj_ver_num     NUMBER ;
   l_created_image         VARCHAR2(1) :=  FND_API.g_false;
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100     := JTF_VARCHAR2_TABLE_100() ;
   l_attributes            JTF_VARCHAR2_TABLE_4000    := JTF_VARCHAR2_TABLE_4000() ;
   l_citem_ids             JTF_NUMBER_TABLE           := JTF_NUMBER_TABLE() ;
   l_dummy_sort_order      JTF_NUMBER_TABLE           := JTF_NUMBER_TABLE() ;
   l_citem_attrs           JTF_VARCHAR2_TABLE_100     := JTF_VARCHAR2_TABLE_100() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)   := 'Update_CP_Image';
   l_full_name             CONSTANT    VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT update_cp_image_PVT ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;


   l_init_msg_list := FND_API.g_false;


   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
--
-- print the contents of the two arrays for Debug.
   IF p_attr_types_image IS NOT NULL
      AND
      p_attr_values_image IS NOT NULL
   THEN
      FOR i IN p_attr_types_image.first .. p_attr_types_image.last
      LOOP
         AMS_UTILITY_PVT.debug_message(i || ' : ' || p_attr_types_image(i) || ' : ' || p_attr_values_image(i));
         null;
      END LOOP;
   END IF;
   IF p_attr_types_cp_image IS NOT NULL
      AND
      p_attr_values_cp_image IS NOT NULL
   THEN
      FOR i IN p_attr_types_cp_image.first .. p_attr_types_cp_image.last
      LOOP
         AMS_UTILITY_PVT.debug_message(i || ' : ' || p_attr_types_cp_image(i) || ' : ' || p_attr_values_cp_image(i));
         null;
      END LOOP;
   END IF;

-- Check if we need to create the IMAGE content type.
   IF p_attach_file_id IS NOT NULL
      AND
      p_attach_file_name IS NOT NULL
      AND
      p_attr_types_image IS NOT NULL
      AND
      p_attr_values_image IS NOT NULL
   THEN
      -- IMAGE content type has the following attributes:
      /*
         attr_type   data_type      min_inst      max_inst data_length
         ALT_TEXT    string         0             1
         ATTACHMENT  attachment     0             1
         DESCRIPTION string         1             1        2000
         HEIGHT      decimal        0             1
         IMAGE_TYPE  string         0             1
         LINK        url            0             1
         NAME        string         1             1         240
         WIDTH       decimal        0             1
      */
      -- Create the content item of type IMAGE.
      -- Call bulk_insert procedure.
      /*
      AMS_UTILITY_PVT.debug_message('file id = ' || p_attach_file_id);
      AMS_UTILITY_PVT.debug_message('file name = ' || p_attach_file_name);
      */

      -- Call the procedure upsert_item. This method allows creation of Content Item from one
      -- single API.

      IBC_CITEM_ADMIN_GRP.upsert_item(
          p_ctype_code              =>     G_IBC_IMAGE
          ,p_citem_name             =>     p_attach_file_name
          ,p_citem_description      =>     p_attach_file_name        -- Currently we do not expose the description on the UI, however the IBC_IMAGE type says that DESCRIPTION is a required field. So sending the file name as description.
          ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
          ,p_owner_resource_id      =>     p_resource_id
          ,p_owner_resource_type    =>     p_resource_type
          ,p_reference_code         =>     NULL                      -- Why is this needed?
          ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
          ,p_parent_item_id         =>     NULL                      -- There is no parent for the item of type IBC_IMAGE.
          ,p_lock_flag              =>     g_lock_flag_value
          ,p_wd_restricted          =>     g_wd_restricted_flag_value
          ,p_start_date             =>     sysdate                   -- use the sysdate as the start date for the IMAGE content item.
          ,p_end_date               =>     NULL                      -- Leave the end date as NULL. The idea is to allow the usage of this basic IBC_IMAGE item indefinitely.
          ,p_attach_file_id         =>     p_attach_file_id
          ,p_attribute_type_codes   =>     p_attr_types_image
          ,p_attributes             =>     p_attr_values_image
          ,p_component_citems       =>     NULL
          ,p_component_atypes       =>     NULL
          ,p_sort_order             =>     NULL
          ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- Soon after the content item of type IBC_IMAGE is created successfully, we will go ahead and approve this item.
          ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
          ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
          ,p_api_version_number     =>     p_api_version
          ,p_init_msg_list          =>     l_init_msg_list
          ,px_content_item_id       =>     l_image_citem_id
          ,px_citem_ver_id          =>     l_image_citem_ver_id
          ,px_object_version_number =>     l_image_obj_ver_num
          ,x_return_status          =>     l_return_status
          ,x_msg_count              =>     l_msg_count
          ,x_msg_data               =>     l_msg_data

      );

      AMS_UTILITY_PVT.debug_message('After upsert_item of type IBC_IMAGE');
      AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_image_citem_id );
      AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_image_citem_ver_id );
      AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_image_obj_ver_num );
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_IMAGE_ITEM');
         RAISE FND_API.g_exc_error;
      ELSE
         l_created_image := FND_API.g_true;
      END IF;

      l_init_msg_list := FND_API.g_false;

      -- Approve this content item of type IBC_IMAGE.

      IBC_CITEM_ADMIN_GRP.approve_item(
         p_citem_ver_id                =>    l_image_citem_ver_id
         ,p_commit                     =>    FND_API.g_false
         ,p_api_version_number         =>    p_api_version
         ,p_init_msg_list              =>    l_init_msg_list
         ,px_object_version_number     =>    l_image_obj_ver_num
         ,x_return_status              =>    l_return_status
         ,x_msg_count                  =>    l_msg_count
         ,x_msg_data                   =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_APPROVE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- If we reach till here we can proceed with update of CP_IMAGE item.

   l_attribute_type_codes := p_attr_types_cp_image;
   l_attributes := p_attr_values_cp_image;

   -- Check if there was a newly created image.
   -- If so, we have to set the two attributes to the array of CP_IMAGE attributes.
   -- One for attachment_file_id and one for ocm_image_id.
   IF l_created_image = FND_API.g_true
   THEN
      -- Substitute the values for the above two attributes.
      FOR i IN l_attribute_type_codes.first .. l_attribute_type_codes.last
      LOOP
        IF l_attribute_type_codes(i) = 'ATTACHMENT_FILE_ID'
        THEN
            l_attributes(i) := NULL; -- set it to NULL. The Runtime code picks up the latest file id.
        END IF;
        IF l_attribute_type_codes(i) = 'OCM_IMAGE_ID'
        THEN
            l_attributes(i) := l_image_citem_id;
        END IF;
      END LOOP;
   END IF;

   -- Update the CP_IMAGE item.

   -- Call the procedure IBC_CITEM_ADMIN_GRP.set_attribute_bundle.

   IF g_using_locking = FND_API.g_true
   THEN

      -- Note that we have to lock the item first.
      IBC_CITEM_ADMIN_GRP.lock_item(
         p_content_item_id          =>    p_cp_image_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_citem_version_id        =>    l_cp_image_citem_ver_id
         ,x_object_version_number   =>    l_obj_ver_num
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_LOCKING_CP_IMAGE');
         RAISE FND_API.g_exc_error;
      END IF;

      IF l_cp_image_citem_ver_id <> p_cp_image_citem_ver_id
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CITEM_VER_MISMATCH');
         RAISE FND_API.g_exc_error;
      END IF;

   ELSE

      -- We have to get the object version number separately as we are not using locking.
      l_obj_ver_num := IBC_CITEM_ADMIN_GRP.getObjVerNum( p_cp_image_citem_id );

   END IF;

   AMS_Utility_PVT.Debug_Message(' CP IMage citem version id = ' || p_cp_image_citem_ver_id );
   AMS_Utility_PVT.Debug_Message(' obj ver num = ' || l_obj_ver_num );

   IBC_CITEM_ADMIN_GRP.set_attribute_bundle(
      p_citem_ver_id             =>    p_cp_image_citem_ver_id
      ,p_attribute_type_codes    =>    l_attribute_type_codes
      ,p_attributes              =>    l_attributes            -- This has the changed data if IMAGE was created.
      ,p_remove_old              =>    FND_API.g_true          -- The procedure sets the p_remove_old value to FND_API.g_true by default as well. Sending it in anyway.
      ,p_commit                  =>    FND_API.g_false         -- This is the Default.
      ,p_api_version_number      =>    p_api_version
      ,p_init_msg_list           =>    l_init_msg_list
      ,px_object_version_number  =>    l_obj_ver_num           -- This is an IN/OUT parameter in this procedure.
      ,x_return_status           =>    l_return_status
      ,x_msg_count               =>    l_msg_count
      ,x_msg_data                =>    l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_SET_CITEM_ATTRIB');
      AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CP_IMAGE');
      RAISE FND_API.g_exc_error;
   END IF;

   -- If we reach till here, we can unlock the IMAGE item and then
   -- unlock the CP_IMAGE item.

   IF l_created_image = FND_API.g_true
   THEN

      IF g_using_locking = FND_API.g_true
      THEN

         IBC_CITEM_ADMIN_GRP.unlock_item(
            p_content_item_id          =>    l_image_citem_id
            ,p_commit                  =>    g_commit_on_lock_unlock
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
         );

         AMS_UTILITY_PVT.debug_message('After Unlock.');
         AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

         --
         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_IMAGE');
            RAISE FND_API.g_exc_error;
         END IF;

      END IF;
      --
   END IF;

   IF g_using_locking = FND_API.g_true
   THEN

      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    p_cp_image_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CP_IMAGE');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- Commit the work and set the output values.

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   x_return_status := l_return_status;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO update_cp_image_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO update_cp_image_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO update_cp_image_PVT ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );


END update_cp_image;

-----------------------------------------------------------------------
-- PROCEDURE
--    get_content_item_attrs
--
-- PURPOSE
--    Wrapper on IBC_CITEM_ADMIN_GRP.get_attribute_bundle
--
-- NOTES
--    1. The required input is as follows:
--         content_item_id
--         content_type_code
--         content_item_version_id
--    2. This procedure calls the get_attribute_bundle from IBC_CITEM_ADMIN_GRP package.
--       It only sends the useful data back to the caller.
--
-----------------------------------------------------------------------
PROCEDURE get_content_item_attrs(
   p_citem_id              IN  NUMBER,
   p_ctype_code            IN  VARCHAR2,
   p_citem_ver_id          IN  NUMBER,
   p_attrib_file_id        IN  NUMBER                    DEFAULT NULL,
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2,
   x_attribute_type_codes  OUT JTF_VARCHAR2_TABLE_100,
   x_attribute_type_names  OUT JTF_VARCHAR2_TABLE_300,
   x_attributes            OUT JTF_VARCHAR2_TABLE_4000,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 ;
   l_attribute_type_names  JTF_VARCHAR2_TABLE_300 ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 ;
   l_obj_ver_num           NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Get_Content_Item_Attrs';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
BEGIN
   --
   x_return_status := FND_API.g_ret_sts_success;
   --

   IBC_CITEM_ADMIN_GRP.get_attribute_bundle(
      p_citem_ver_id             =>       p_citem_ver_id
      ,p_init_msg_list           =>       p_init_msg_list
      ,p_api_version_number      =>       p_api_version
      ,x_attribute_type_codes    =>       l_attribute_type_codes
      ,x_attribute_type_names    =>       l_attribute_type_names
      ,x_attributes              =>       l_attributes
      ,x_object_version_number   =>       l_obj_ver_num
      ,x_return_status           =>       l_return_status
      ,x_msg_count               =>       l_msg_count
      ,x_msg_data                =>       l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_GET_CITEM_ATTRS');
      RAISE FND_API.g_exc_error;
   END IF;

   x_return_status := l_return_status;
   x_attribute_type_codes := l_attribute_type_codes;
   x_attribute_type_names := l_attribute_type_names;
   x_attributes := l_attributes;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );

END get_content_item_attrs;



-----------------------------------------------------------------------
-- PROCEDURE
--    update_content_item
--
-- PURPOSE
--    Update a Content Item with a generic content type.
--    The Content Type must be provided.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for the Item.
--       Content Item Id for Item.
--       Content Item Version Id for the Item.
--       Two Arrays : one with data for changed attribute codes.
--                    second with the corresponding values.
--    2. The optional input is as follows:
--       Content Item Name for the Item.
--       Description.
--       Attachment File Id for the attachment.
--       Attachment File Name for the same.
--    3. This procedure performs the following steps:
--          1. Lock the Content Item.
--          2. Get the existing Attribute data for the content item.
--          3. Set the values of the changed Attributes with the incoming data.
--          4. Set the Attachment File Id if it has been provided as input.
--          5. Unlock the Content Item.
--          NOTE that we will not call the following for now:
--             set_citem_meta will not be called as none of the meta items are exposed
--             in the UI for any of the content items.
--             update_citem_basic will not be called as we do not expose Description
--             in the UI and we do not allow the change of the Name.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    24-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE update_content_item(
   p_citem_id                 IN  NUMBER,
   p_citem_version_id         IN  NUMBER,
   p_content_type_code        IN  VARCHAR2,
   p_content_item_name        IN  VARCHAR2,
   p_description              IN  VARCHAR2,
   p_delv_id                  IN  NUMBER,
   p_attr_types_for_update    IN  JTF_VARCHAR2_TABLE_100    DEFAULT NULL,
   p_attr_values_for_update   IN  JTF_VARCHAR2_TABLE_4000   DEFAULT NULL,
   p_attach_file_id           IN  NUMBER                    DEFAULT NULL,
   p_attach_file_name         IN  VARCHAR2                  DEFAULT NULL,
   p_commit                   IN  VARCHAR2                  DEFAULT FND_API.g_false,
   p_api_version              IN  NUMBER                    DEFAULT 1.0,
   p_api_validation_level     IN  NUMBER                    DEFAULT FND_API.g_valid_level_full,
   x_return_status            OUT VARCHAR2,
   x_msg_count                OUT NUMBER,
   x_msg_data                 OUT VARCHAR2,
   p_replace_attr_bundle      IN  VARCHAR2                  DEFAULT FND_API.g_false
)
IS
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 ;
   l_attribute_type_names  JTF_VARCHAR2_TABLE_300 ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 ;
   l_citem_ver_id          NUMBER ;
   l_citem_id              NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Update_Content_Item';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
   l_status                VARCHAR2(30) ;
   l_attach_file_id        NUMBER ;
   l_attach_file_name      VARCHAR2(240) ;
   l_citem_name            VARCHAR2(240) ;
   l_description           VARCHAR2(2000) ;
   l_cpnt_citems           JTF_NUMBER_TABLE ;
   l_cpnt_ctypes           JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_attrib_types     JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_citem_names      JTF_VARCHAR2_TABLE_300 ;
   l_cpnt_owner_ids        JTF_NUMBER_TABLE ;
   l_cpnt_owner_types      JTF_VARCHAR2_TABLE_100 ;
   l_cpnt_owner_names      JTF_VARCHAR2_TABLE_400 ;
   l_cpnt_sort_orders      JTF_NUMBER_TABLE ;
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
   AMS_UTILITY_PVT.debug_message('content item id = ' || p_citem_id);

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   IF g_using_locking = FND_API.g_true
   THEN

      -- We have to lock the item first.
      IBC_CITEM_ADMIN_GRP.lock_item(
         p_content_item_id          =>    p_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_citem_version_id        =>    l_citem_ver_id
         ,x_object_version_number   =>    l_obj_ver_num
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_LOCKING_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

      IF l_citem_ver_id <> p_citem_version_id
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CITEM_VER_MISMATCH');
         RAISE FND_API.g_exc_error;
      END IF;

   ELSE

      -- We have to get the object version number separately as we are not using locking.
      l_obj_ver_num := IBC_CITEM_ADMIN_GRP.getObjVerNum( p_citem_id );

   END IF;

   AMS_Utility_PVT.Debug_Message(' p_citem_version_id = ' || p_citem_version_id );
   AMS_Utility_PVT.Debug_Message(' obj ver num = ' || l_obj_ver_num );

   -- Get all the existing basic attributes for the content item if necessary.

   -- Check if we just need to replace the attribute bundle.

   IF p_replace_attr_bundle = FND_API.g_true
   THEN

      -- If the attribute bundle has to be totally replaced with the one
      -- incoming, do so.
      l_attribute_type_codes := p_attr_types_for_update;
      l_attributes := p_attr_values_for_update;

   ELSE

      IF p_attr_types_for_update IS NOT NULL
         AND
         p_attr_values_for_update IS NOT NULL
      THEN

         /*
         -- This call was giving problems.
         -- Using get_content_item_data instead.

         -- Call get_content_item_attrs method.

         get_content_item_attrs(
            p_citem_id               =>    p_citem_id
            ,p_ctype_code            =>    p_content_type_code
            ,p_citem_ver_id          =>    p_citem_version_id
            ,p_attrib_file_id        =>    NULL
            ,p_api_version           =>    p_api_version
            ,p_init_msg_list         =>    l_init_msg_list
            ,x_attribute_type_codes  =>    l_attribute_type_codes
            ,x_attribute_type_names  =>    l_attribute_type_names
            ,x_attributes            =>    l_attributes
            ,x_return_status         =>    l_return_status
            ,x_msg_count             =>    l_msg_count
            ,x_msg_data              =>    l_msg_data
         );

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_GET_CITEM_ATTRS');
            RAISE FND_API.g_exc_error;
         END IF;

         */

         -- call get_content_item_data.
         get_content_item_data(
            p_citem_id                 =>     p_citem_id
            ,p_citem_ver_id             =>    p_citem_version_id
            ,p_api_version              =>    p_api_version
            ,x_status                   =>    l_status
            ,x_attach_file_id           =>    l_attach_file_id
            ,x_attach_file_name         =>    l_attach_file_name
            ,x_citem_name               =>    l_citem_name
            ,x_description              =>    l_description
            ,x_attribute_type_codes     =>    l_attribute_type_codes
            ,x_attribute_type_names     =>    l_attribute_type_names
            ,x_attributes               =>    l_attributes
            ,x_cpnt_citem_ids           =>    l_cpnt_citems
            ,x_cpnt_ctype_codes         =>    l_cpnt_ctypes
            ,x_cpnt_attrib_types        =>    l_cpnt_attrib_types
            ,x_cpnt_citem_names         =>    l_cpnt_citem_names
            ,x_cpnt_sort_orders         =>    l_cpnt_sort_orders
            ,x_object_version_number    =>    l_obj_ver_num
            ,x_return_status            =>    l_return_status
            ,x_msg_count                =>    l_msg_count
            ,x_msg_data                 =>    l_msg_data
         );

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_GET_CITEM');
            RAISE FND_API.g_exc_error;
         END IF;

         IF l_attribute_type_codes IS NOT NULL
            AND
            l_attributes IS NOT NULL
         THEN

            -- go through the incoming attributes and get the new values and set the
            -- new values in the existing attribute bundle.

            FOR i IN l_attribute_type_codes.first .. l_attribute_type_codes.last
            LOOP
               FOR j IN p_attr_types_for_update.first .. p_attr_types_for_update.last
               LOOP
                  IF l_attribute_type_codes(i) = p_attr_types_for_update(j)
                  THEN

                     -- The i-th attribute needs value change.
                     -- Set the new value.
                     l_attributes(i) := p_attr_values_for_update(j);

                  END IF;
               END LOOP;
            END LOOP;

         ELSE
            -- If the Content Item does not have any Attributes set so far,
            -- we will set the incoming Attribute Bundle as is.

            l_attribute_type_codes := p_attr_types_for_update;
            l_attributes := p_attr_values_for_update;

         END IF;

      END IF;

   END IF;

   IF l_attribute_type_codes IS NOT NULL
      AND
      l_attributes IS NOT NULL
   THEN

      -- Set the Attribute Bundle.
      IBC_CITEM_ADMIN_GRP.set_attribute_bundle(
         p_citem_ver_id             =>    p_citem_version_id
         ,p_attribute_type_codes    =>    l_attribute_type_codes
         ,p_attributes              =>    l_attributes            -- This has the changed data as needed.
         ,p_remove_old              =>    FND_API.g_true          -- The procedure sets the p_remove_old value to FND_API.g_true by default as well. Sending it in anyway.
         ,p_commit                  =>    FND_API.g_false         -- This is the Default.
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,px_object_version_number  =>    l_obj_ver_num           -- This is an IN/OUT parameter in this procedure.
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_SET_CITEM_ATTRIB');
         AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- Set the attachment is necessary.
   IF p_attach_file_id IS NOT NULL
      AND
      p_attach_file_name IS NOT NULL
   THEN
      -- Call the procedure IBC_CITEM_ADMIN_GRP.set_attachment.

      IBC_CITEM_ADMIN_GRP.set_attachment(
         p_citem_ver_id             =>    p_citem_version_id
         ,p_attach_file_id          =>    p_attach_file_id
         ,p_commit                  =>    FND_API.g_false         -- This is the Default.
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,px_object_version_number  =>    l_obj_ver_num           -- This is the IN OUT Parameter
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_SET_CITEM_ATTCH');
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   AMS_UTILITY_PVT.debug_message('Before Unlock.');
   AMS_UTILITY_PVT.debug_message('p_citem_version_id = ' || p_citem_version_id);
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);

   IF g_using_locking = FND_API.g_true
   THEN

      -- unlock the content item as the update was successful.
      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    p_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );
      --
      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);
      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- Commit the work and set the output values.

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   x_return_status := l_return_status;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );

END update_content_item;

-----------------------------------------------------------------------
-- PROCEDURE
--    update_citem_for_delv
--
-- PURPOSE
--    Update the Content Item associated with the Deliverable of type Content Page.
--
-- NOTES
--    1. The required input is as follows:
--         content_type_code
--         default_display_template_id
--         deliverable_id
--         content_item_id
--         association_type_code (this is recorded in ibc_associations table)
--    2. This procedure returns the success or failure status
--
-----------------------------------------------------------------------
PROCEDURE update_citem_for_delv(
   p_content_type_code     IN  VARCHAR2,
   p_def_disp_template_id  IN  NUMBER,
   p_delv_id               IN  NUMBER,
   p_citem_id              IN  NUMBER,
   p_assoc_type_code       IN  VARCHAR2,
   p_commit                IN  VARCHAR2     DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER       DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER       DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
-- Cursor to select the latest citem version for a content item.
--
   CURSOR c_max_version IS
     SELECT MAX(citem_version_id)
     FROM   ibc_citem_versions_b
     WHERE  content_item_id = p_citem_id ;
--
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
   l_citem_ver_id          NUMBER ;
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Update_Citem_For_Delv';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   IF g_using_locking = FND_API.g_true
   THEN

      -- We have to lock the item first.
      IBC_CITEM_ADMIN_GRP.lock_item(
         p_content_item_id          =>    p_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_citem_version_id        =>    l_citem_ver_id
         ,x_object_version_number   =>    l_obj_ver_num
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_LOCKING_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   ELSE

      -- If we do not use locking mechanism, we will have to get the latest citem version
      -- for this deliverable at this stage.
      -- Fetch the latest citem version id.
      OPEN c_max_version;
      FETCH c_max_version INTO l_citem_ver_id;
      CLOSE c_max_version;

      -- We must also fetch the object version number.
      l_obj_ver_num := IBC_CITEM_ADMIN_GRP.getObjVerNum( p_citem_id );

   END IF;

   AMS_Utility_PVT.Debug_Message(' l_citem_ver_id = ' || l_citem_ver_id );
   AMS_Utility_PVT.Debug_Message(' obj ver num = ' || l_obj_ver_num );

   -- update the data if needed.
   IF p_def_disp_template_id IS NOT NULL
   THEN
      l_attribute_type_codes.extend();
      l_attribute_type_codes(1) := G_DEFAULT_DISPLAY_TEMPLATE;

      l_attributes.extend();
      l_attributes(1) := p_def_disp_template_id;

      -- Call update_content_item method.
      update_content_item(
         p_citem_id                  =>    p_citem_id
         ,p_citem_version_id         =>    l_citem_ver_id
         ,p_content_type_code        =>    p_content_type_code
         ,p_content_item_name        =>    NULL
         ,p_description              =>    NULL
         ,p_delv_id                  =>    p_delv_id
         ,p_attr_types_for_update    =>    l_attribute_type_codes
         ,p_attr_values_for_update   =>    l_attributes
         ,p_attach_file_id           =>    NULL
         ,p_attach_file_name         =>    NULL
         ,p_commit                   =>    FND_API.g_false
         ,p_api_version              =>    p_api_version
         ,p_api_validation_level     =>    p_api_validation_level
         ,x_return_status            =>    l_return_status
         ,x_msg_count                =>    l_msg_count
         ,x_msg_data                 =>    l_msg_data
      );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

      --Change the value of default_display_template in IBC_ASSOCIATIONS table.

      UPDATE ibc_associations
      SET associated_object_val3 = p_def_disp_template_id
      WHERE content_item_id = p_citem_id
      AND associated_object_val1 = TO_CHAR(p_delv_id)
      AND association_type_code = G_CPAGE_ASSOC_TYPE_CODE;

      IF (SQL%NOTFOUND) THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error)
         THEN
            FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
            FND_MSG_PUB.add;
         END IF;
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   IF g_using_locking = FND_API.g_true
   THEN

      -- unlock the content item.
      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    p_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- Commit the work and set the output values.

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   x_return_status := l_return_status;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );

END update_citem_for_delv;

-----------------------------------------------------------------------
-- PROCEDURE
--    create_display_template
--
-- PURPOSE
--    Create a Content Item of type STYLESHEET.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type Code for which the Stylesheet or Display Template is for.
--       Display Template or Stylesheet Name.
--       Attachment File ID that has the actual Stylesheet or Display Template.
--       Attachment File Name. (This will the one of the uploaded file).
--       Value for DELIVERY_CHANNEL
--       Value for OUTPUT_TYPE
--    2. The optional input is as follows:
--       Stylesheet Description.
--    3. This procedure performs the following steps:
--          1. Create a Content Item of type STYLESHEET using Bulk Insert as an APPROVED item.
--             Set the attribute bundle for the item, with DELIVERY_OPTION and OUTPUT_TYPE.
--          2. Create an entry in IBC_STYLESHEETS table.
--    4. This procedure returns the fact that it is successful, it also returns the
--       newly created Display Template ID.
--
-- HISTORY
--    14-FEB-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE create_display_template(
   p_content_type_code        IN  VARCHAR2,
   p_stylesheet_name          IN  VARCHAR2,
   p_stylesheet_descr         IN  VARCHAR2      DEFAULT NULL,
   p_delivery_channel         IN  VARCHAR2,
   p_output_type              IN  VARCHAR2,
   p_attach_file_id           IN  NUMBER,
   p_attach_file_name         IN  VARCHAR2,
   p_resource_id              IN  NUMBER,
   p_resource_type            IN  VARCHAR2,
   p_commit                   IN  VARCHAR2      DEFAULT FND_API.g_false,
   p_api_version              IN  NUMBER        DEFAULT 1.0,
   p_api_validation_level     IN  NUMBER        DEFAULT FND_API.g_valid_level_full,
   x_citem_id                 OUT NUMBER,
   x_citem_ver_id             OUT NUMBER,
   x_return_status            OUT VARCHAR2,
   x_msg_count                OUT NUMBER,
   x_msg_data                 OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
   l_citem_ver_id          NUMBER ;
   l_citem_id              NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Create_Display_Template';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT create_display_template_PVT ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;

-- prepare the data for insert.
--
   l_attribute_type_codes.extend();
   l_attribute_type_codes(1) := G_DELIVERY_CHANNEL ;
--
   l_attributes.extend();
   l_attributes(1) := p_delivery_channel;
--
   l_attribute_type_codes.extend();
   l_attribute_type_codes(2) := G_OUTPUT_TYPE ;
--
   l_attributes.extend();
   l_attributes(2) := p_output_type;
--
-- Call upsert_item.

-- Call IBC_CITEM_ADMIN_GRP.upsert_item procedure.

   IBC_CITEM_ADMIN_GRP.upsert_item(
       p_ctype_code              =>     G_IBC_STYLESHEET
       ,p_citem_name             =>     p_stylesheet_name
       ,p_citem_description      =>     substr(p_stylesheet_descr,1,2000)
       ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
       ,p_owner_resource_id      =>     p_resource_id
       ,p_owner_resource_type    =>     p_resource_type
       ,p_reference_code         =>     NULL                      -- Why is this needed?
       ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
       ,p_parent_item_id         =>     NULL                      -- There is no parent for the item of type IBC_STYLESHEET.
       ,p_lock_flag              =>     g_lock_flag_value
       ,p_wd_restricted          =>     g_wd_restricted_flag_value
       ,p_start_date             =>     sysdate
       ,p_end_date               =>     null
       ,p_attach_file_id         =>     p_attach_file_id          -- This procedure picks up the file name from FND_LOBS.
       ,p_attribute_type_codes   =>     l_attribute_type_codes
       ,p_attributes             =>     l_attributes
       ,p_component_citems       =>     NULL
       ,p_component_atypes       =>     NULL
       ,p_sort_order             =>     NULL
       ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- We will approve this item as soon as we are done with the creation.
       ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
       ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
       ,p_api_version_number     =>     p_api_version
       ,p_init_msg_list          =>     l_init_msg_list
       ,px_content_item_id       =>     l_citem_id
       ,px_citem_ver_id          =>     l_citem_ver_id
       ,px_object_version_number =>     l_obj_ver_num
       ,x_return_status          =>     l_return_status
       ,x_msg_count              =>     l_msg_count
       ,x_msg_data               =>     l_msg_data
   );

   AMS_UTILITY_PVT.debug_message('After upsert_item.');
   AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id);
   AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
   AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CRE_STYLE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   -- Approve the above item.

   IBC_CITEM_ADMIN_GRP.approve_item(
      p_citem_ver_id                =>    l_citem_ver_id
      ,p_commit                     =>    FND_API.g_false
      ,p_api_version_number         =>    p_api_version
      ,p_init_msg_list              =>    l_init_msg_list
      ,px_object_version_number     =>    l_obj_ver_num
      ,x_return_status              =>    l_return_status
      ,x_msg_count                  =>    l_msg_count
      ,x_msg_data                   =>    l_msg_data
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_APPROVE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   IF g_using_locking = FND_API.g_true
   THEN

      -- Unlock the Item if success.
      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    l_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      --
      --
      --
      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   -- Create the association in IBC_STYLESHEETS, if success.
   insert into IBC_STYLESHEETS
   (
      CONTENT_TYPE_CODE
      ,CONTENT_ITEM_ID
      ,DEFAULT_STYLESHEET_FLAG
      ,CREATED_BY
      ,CREATION_DATE
      ,LAST_UPDATED_BY
      ,LAST_UPDATE_DATE
      ,LAST_UPDATE_LOGIN
      ,OBJECT_VERSION_NUMBER
      ,SECURITY_GROUP_ID
   )
   values
   (
      p_content_type_code
      ,l_citem_id
      ,'N'
      ,FND_GLOBAL.user_id
      ,SYSDATE
      ,FND_GLOBAL.user_id
      ,SYSDATE
      ,FND_GLOBAL.conc_login_id
      ,1
      ,NULL
   );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CREATE_DISP_TMPL');
      RAISE FND_API.g_exc_error;
   END IF;
--
-- If we come till here, everything has been created successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
   x_return_status := l_return_status;
   x_citem_id := l_citem_id;
   x_citem_ver_id := l_citem_ver_id;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_display_template_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_display_template_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO create_display_template_PVT ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
END create_display_template;







-----------------------------------------------------------------------
-- PROCEDURE
--    create_basic_questions_item.
--
-- PURPOSE
--    Create basic content item of type QUESTIONS.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type code. This must be QUESTIONS.
--       Name of the Questions Section.
--       Owner Resource Id.
--       Resource Type.
--       Content Item Id for the Parent Content Item associated with the parent deliverable.
--       Content Item Version Id for the Parent Content Item.
--       Content Type Code for the Parent Content Item.
--    2. The optional input is as follows:
--       Description.
--    3. This procedure performs the following steps:
--          1. Create a basic Content Item of type QUESTIONS using Bulk Insert.
--          2. Create compound relation with the parent.
--    4. This procedure returns the fact that it is successful, it also returns the
--       newly created Content Item Id.
--
-- HISTORY
--    09-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE create_basic_questions_item(
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_start_date            IN  DATE                    DEFAULT SYSDATE,
   p_end_date              IN  DATE                    DEFAULT NULL,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2                DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attribute_type_code   IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   x_citem_id              OUT NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
   l_citem_ver_id          NUMBER ;
   l_citem_id              NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_citem_ids             JTF_NUMBER_TABLE := JTF_NUMBER_TABLE() ;
   l_citem_attrs           JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_dummy_sort_order      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Create_Basic-Questions_Item';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT create_basic_ques_item_PVT ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
   IF p_content_type_code <> G_QUESTIONS -- Should be a CONSTANT in the package.
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_WRONG_CTYPE_CODE');
      RAISE FND_API.g_exc_error;
   END IF;
--
   x_return_status := FND_API.g_ret_sts_success;
--
-- Create a new Content Item in IBC Schema for incoming Content Type.
-- Call upsert_item.

   IBC_CITEM_ADMIN_GRP.upsert_item(
       p_ctype_code              =>     G_QUESTIONS
       ,p_citem_name             =>     p_content_item_name
       ,p_citem_description      =>     NULL                      -- We do not expose the description in the UI for now.
       ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
       ,p_owner_resource_id      =>     p_owner_resource_id
       ,p_owner_resource_type    =>     p_owner_resource_type
       ,p_reference_code         =>     NULL                      -- Why is this needed?
       ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
       ,p_parent_item_id         =>     p_parent_citem_id         -- Specify the parent content item id. This item is visible only in the context of this parent.
       ,p_lock_flag              =>     g_lock_flag_value
       ,p_wd_restricted          =>     g_wd_restricted_flag_value
       ,p_start_date             =>     p_start_date
       ,p_end_date               =>     p_end_date
       ,p_attach_file_id         =>     NULL                      -- We do not have any attachment while creating the basic Questions item.
       ,p_attribute_type_codes   =>     NULL                      -- We do not set the attribute bundle while creating the basic Questions item.
       ,p_attributes             =>     NULL
       ,p_component_citems       =>     NULL
       ,p_component_atypes       =>     NULL
       ,p_sort_order             =>     NULL
       ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- When the Deliverable becomes active, we will go in and approve all the underlying content items.
       ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
       ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
       ,p_api_version_number     =>     p_api_version
       ,p_init_msg_list          =>     l_init_msg_list
       ,px_content_item_id       =>     l_citem_id
       ,px_citem_ver_id          =>     l_citem_ver_id
       ,px_object_version_number =>     l_obj_ver_num
       ,x_return_status          =>     l_return_status
       ,x_msg_count              =>     l_msg_count
       ,x_msg_data               =>     l_msg_data
   );

   AMS_UTILITY_PVT.debug_message('After upsert_item.');
   AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id);
   AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
   AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CRE_QUES_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   -- Create the Compound Relation with the parent.
   IF p_parent_citem_ver_id IS NOT NULL
      AND
      p_parent_ctype_code IS NOT NULL
      AND
      p_attribute_type_code IS NOT NULL
   THEN
      -- prepare the data for insert.
      l_citem_attrs.extend();
      l_citem_attrs(1) := p_attribute_type_code;
      --
      l_citem_ids.extend();
      l_citem_ids(1) := l_citem_id;
      --
      l_dummy_sort_order.extend();
      l_dummy_sort_order(1) := 1;
      --

      IBC_CITEM_ADMIN_GRP.insert_components(
         p_citem_ver_id             =>    p_parent_citem_ver_id
         ,p_content_item_ids        =>    l_citem_ids
         ,p_attribute_type_codes    =>    l_citem_attrs
         ,p_sort_order              =>    l_dummy_sort_order   -- The NULL does not work.  -- The new API is supposed to be able to take NULL for this parameter.
         ,p_commit                  =>    FND_API.g_false
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
     );

   END IF;
--
--
   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_ADD_COMPOUND_REL');
      RAISE FND_API.g_exc_error;
   END IF;
--
   IF g_using_locking = FND_API.g_true
   THEN

      -- Unlock the content item.

      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    l_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );
      --
      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   END IF;
--
-- If we come till here, everything has been created successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
   x_return_status := l_return_status;
   x_citem_id := l_citem_id;
   x_citem_ver_id := l_citem_ver_id;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_basic_ques_item_PVT ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_basic_ques_item_PVT ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO create_basic_ques_item_PVT ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
END create_basic_questions_item;






-----------------------------------------------------------------------
-- PROCEDURE
--    generate_select_sql.
--
-- PURPOSE
--    Generate select SQL statement, given a data source and list of fields.
--
-- NOTES
--    1. The required input is as follows:
--       Data Source code.
--       VARCHAR2 Array with a list of Data Fields in the form of DATA_SRC_TYPE_CODE:FIELD_COLUMN_NAME.
--    2. The optional input is as follows:
--       NUMBER Array with a list of Data Source Field IDs.
--    3. This procedure performs the following steps:
--          1. Referes to the Data Sources schema to get the details of Data Source fields.
--          2. Generate a Select SQL Statement based on the Data Source and the fields.
--    4. This procedure returns the generated SQL statement and the list of bind variable names.
--
--    5. Change made on 20 APR 2002 is as follows:
--
--       Making changes in generate_sql_statement. April 30, 2002.
--       According to Avijit, for Runtime of Questions Section the bind variable name
--       has to be changed based on the Data Source column and field.
--       This change is fine, but it will not work for user defined data sources at all.
--       For address, amsp is good for address-es.
--       For email, fax, phone-s , please put amsctp
--       For company name, please put amsorgp - org party id,
--       For job title, amsrelp - relationshipparty id is good.
--
--       This is what the above translates to :
--       for PERSON_LIST as list_source_type, amsp should be used.
--       for PERSON_PHONE1 to PERSON_PHONE3 and EMAIL and FAX, amscpt (contant points) should be used.
--       When the same page is used in B2C Context, Avijit's runtime uses Person Party Id.
--       When the same page is used in B2B Context, Avijit's runtime uses Relationship Party Id.
--       We are not covering the Business Phones and other details as yet.
--       for ORGANIZATION_LIST as list_source_type, amsorgp should be used. This is Organization Party ID.
--       for ORGANIZATION_CONTACT_LIST as list_source_type, amsrelp should be used. This is Relationship Party ID.
--
-- HISTORY
--    09-MAR-2002   gdeodhar     Created.
--    30-APR-2002   gdeodhar     Modified to set the bind_var as per the List Source Type used.
--    06-MAY-2002   gdeodhar     Changed the convention about the aliases.
--                               Earlier it was Data_Source_Code_Name:Field_Column_Name.
--                               Truncated that after 30 characters.
--                               That does not look good.
--                               So changed it such that now it has the following format:
--                               Data_Source_Type_Id:Field_Column_Name truncated after 30th character.
--
-----------------------------------------------------------------------

PROCEDURE generate_select_sql(
   p_data_source_code         IN  VARCHAR2,
   p_data_source_fields_list  IN  JTF_VARCHAR2_TABLE_300       DEFAULT NULL,
   p_data_source_field_ids    IN  JTF_NUMBER_TABLE             DEFAULT NULL,
   x_select_sql_statement     OUT VARCHAR2,
   x_bind_vars                OUT JTF_VARCHAR2_TABLE_300,
   x_return_status            OUT VARCHAR2,
   x_msg_count                OUT NUMBER,
   x_msg_data                 OUT VARCHAR2
)
IS
   l_select_sql_statement     VARCHAR2(4000)          := '' ;
   l_select_clause            VARCHAR2(4000)          := '' ;
   l_from_clause              VARCHAR2(1000)          := '' ;
   l_where_clause             VARCHAR2(1000)          := '' ;
   l_return_status            VARCHAR2(1)             := FND_API.g_ret_sts_success ;
   l_msg_count                NUMBER ;
   l_msg_data                 VARCHAR2(2000) ;

   l_data_src_fld_ids         JTF_NUMBER_TABLE        := JTF_NUMBER_TABLE() ;
   l_data_src_fld_cols        JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300() ;
   l_bind_vars                JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300() ;

   l_source_object_name       VARCHAR2(240) ;
   l_source_object_pk_field   VARCHAR2(240) ;
   l_master_source_type_flag  VARCHAR2(1) ;
   l_view_application_id      NUMBER ;

   l_list_source_field_id     NUMBER ;
   l_list_source_field        VARCHAR2(240) ;
   l_source_column_name       VARCHAR2(240) ;

   l_alias                    VARCHAR2(240) ;

   l_fld_count                NUMBER ;

   l_data_src_type_id         NUMBER ;

   CURSOR c_get_list_src_id (p_data_source_code IN VARCHAR2) IS
   SELECT list_source_type_id
     FROM ams_list_src_types
    WHERE source_type_code = p_data_source_code
      AND enabled_flag = 'Y';

   CURSOR c_get_list_src_data (p_data_source_code IN VARCHAR2) IS
   SELECT source_object_name, source_object_pk_field, master_source_type_flag, view_application_id
     FROM ams_list_src_types
    WHERE source_type_code = p_data_source_code
      AND enabled_flag = 'Y';

   CURSOR c_get_list_src_fld_data (p_data_source_code IN VARCHAR2, l_list_source_field_id IN NUMBER) IS
   SELECT source_column_name
     FROM ams_list_src_fields
    WHERE de_list_source_type_code = p_data_source_code
      AND list_source_field_id = l_list_source_field_id
      AND enabled_flag = 'Y';

--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Generate_Select_Sql';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
BEGIN
--
   l_return_status := FND_API.g_ret_sts_success;
--
-- Get all the Data Source details.
   OPEN c_get_list_src_data (p_data_source_code);
   FETCH c_get_list_src_data
   INTO l_source_object_name, l_source_object_pk_field, l_master_source_type_flag, l_view_application_id;
   CLOSE c_get_list_src_data;

   IF l_source_object_name IS NULL
      AND
      l_source_object_pk_field IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_NO_DATA_SRC');
      RAISE FND_API.g_exc_error;
   END IF;

--
-- Form the FROM clause and WHERE clause.
--
   l_from_clause := 'FROM ' || l_source_object_name;
   l_where_clause := 'WHERE ' || l_source_object_pk_field || ' = ?';


   -- Check for the Data Source codes and add the bind variable names to the array.
   l_bind_vars.extend();
   l_bind_vars(1) := '';

   /*
   l_bind_vars(1) := G_BIND_VAR_AMSP;
   -- Hardcoding the bind var as amsp for now.
   -- Since we use only TCA based data sources for Merge Fields, it is fine to
   -- assume the bind variable as party id for Rich Content with Merge Fields.
   -- For the Questions section, we are hardcoding it as well, so the bind variables
   -- returned from this method will never be used for Questions section.
   -- Revisit this part when we allow User Defined data sources.
   */
   -- Commented the above piece, we not have the bind variable names based on the Data
   -- Source Type.

   -- The bind variables for both questions section and rich content section will now
   -- depend on the type of Data Source used (B2B or B2C or Contact Points).
   -- The party id will always be Person Party Id for B2C.
   -- However the party id could be either a Person Party Id or a Relationship Party Id
   -- for a B2B scenario.

   IF p_data_source_code = G_PEROSN_LIST_DATA_SRC
   THEN
      -- person party id
      l_bind_vars(1) := G_BIND_VAR_AMSP ;
   ELSIF p_data_source_code IN ( G_PERSON_PHONE1_DATA_SRC , G_PERSON_PHONE2_DATA_SRC , G_PERSON_PHONE3_DATA_SRC , G_EMAIL_DATA_SRC , G_FAX_DATA_SRC )
   THEN
      -- contact party id
      l_bind_vars(1) := G_BIND_VAR_AMSCTP ;
   ELSIF p_data_source_code IN ( G_ORG_LIST_DATA_SRC )
   THEN
      -- organization party id
      l_bind_vars(1) := G_BIND_VAR_AMSORGP ;
   ELSIF p_data_source_code IN ( G_ORG_CONTACT_LIST_DATA_SRC )
   THEN
      -- relationship party id
      l_bind_vars(1) := G_BIND_VAR_AMSRELP ;
   ELSE
      -- For all other, we note it as amsp (person party id).
      -- When we restrict the Rich Content as well as Questions setion to show only specific
      -- Data Sources for the marketer to choose from, we are fine.
      -- When we open it up to all data sources, we will have issues.
      l_bind_vars(1) := G_BIND_VAR_AMSP ;
   END IF;

   /*
   IF UPPER(l_source_object_pk_field) = 'PARTY_ID'
   THEN
      l_bind_vars(1) := G_BIND_VAR_AMSP;
   ELSE
      AMS_Utility_PVT.Error_Message('AMS_ERR_UNDEF_BIND_VAR');
      RAISE FND_API.g_exc_error;
      -- For user entered data sources, there has to be a way to define the bind variable
      -- name that we can use here.
   END IF;
   */

   -- get the id of the list source type
   OPEN c_get_list_src_id (p_data_source_code);
   FETCH c_get_list_src_id INTO l_data_src_type_id ;
   CLOSE c_get_list_src_id ;

   IF l_data_src_type_id IS NULL
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_NO_DATA_SRC_TYPE');
      RAISE FND_API.g_exc_error;
   END IF ;

   -- For each field id in the incoming array, get the source_column_name
   -- if needed and form the select list.

   l_fld_count := 0;
   l_select_clause := 'SELECT 1';

   IF p_data_source_field_ids IS NOT NULL
   THEN

      FOR i IN p_data_source_field_ids.first .. p_data_source_field_ids.last
      LOOP
         l_list_source_field_id := p_data_source_field_ids(i);

         OPEN c_get_list_src_fld_data (p_data_source_code, l_list_source_field_id) ;
         FETCH c_get_list_src_fld_data INTO l_source_column_name ;
         CLOSE c_get_list_src_fld_data;

         IF l_source_column_name IS NULL
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_NO_DATA_SRC_FLD');
            RAISE FND_API.g_exc_error;
         ELSE

            -- Form the alias for the Column Name in the select list.
            l_fld_count := l_fld_count + 1;

            --l_alias := substr((p_data_source_code || ':' || l_source_column_name), 1, 30);
            l_alias := substr((to_char(l_data_src_type_id) || ':' || l_source_column_name), 1, 30);

            -- Changed the above once again to use the id of the list source type.
            -- GDEODHAR : May 06, 2002.
            -- Changed the above line to use substr.
            -- When the alias name exceeds 30 characters, it gives problem with the
            -- SQL statement execution at runtime.
            -- Now truncating the alias after 30th character.

            l_data_src_fld_cols.extend();
            l_data_src_fld_cols(l_fld_count) := l_alias;

            l_select_clause := l_select_clause || ' ,' || l_source_column_name || ' "' || l_alias || '"';

         END IF;

      END LOOP;

   ELSE
      IF p_data_source_fields_list IS NOT NULL
      THEN
         FOR i IN p_data_source_fields_list.first .. p_data_source_fields_list.last
         LOOP
            l_list_source_field := p_data_source_fields_list(i);

            -- The format of l_list_source_field is :
            -- DATA_SOURCE_TYPE_CODE:SOURCE_COLUMN_NAME.
            -- Extract the column name.

            l_source_column_name := SUBSTR(l_list_source_field, INSTR(l_list_source_field,':') + 1) ;

            IF l_source_column_name = ''
            THEN
               AMS_Utility_PVT.Error_Message('AMS_ERR_MALFORMED_FLD_NAME');
               RAISE FND_API.g_exc_error;
            ELSE
               l_fld_count := l_fld_count + 1;

               l_alias := substr(l_list_source_field, 1, 30) ;

               -- Note that this is Rich Content section and the change for using
               -- list source type id instead of the name has already happened
               -- when this code is invoked. So no need to change anything here.

               -- GDEODHAR : May 06, 2002.
               -- Changed the above line to use substr.
               -- When the alias name exceeds 30 characters, it gives problem with the
               -- SQL statement execution at runtime.
               -- Now truncating the alias after 30th character.

               l_data_src_fld_cols.extend();
               l_data_src_fld_cols(l_fld_count) := l_alias;

               l_select_clause := l_select_clause || ' ,' || l_source_column_name || ' "' || l_alias || '"';
            END IF;

         END LOOP;
      ELSE
         -- Cannot form the select statement, as no fields list available.
         AMS_Utility_PVT.Error_Message('AMS_ERR_NO_FLDS_FOR_GEN_SQL');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

   l_select_sql_statement := l_select_clause || ' ' || l_from_clause || ' ' || l_where_clause;
--
-- There is nothing to commit, as we did not change any data.
--
   x_return_status := l_return_status ;
   x_select_sql_statement := l_select_sql_statement ;
   x_bind_vars := l_bind_vars ;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_encoded        =>   FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--
END generate_select_sql;





-----------------------------------------------------------------------
-- PROCEDURE
--    create_submit_section
--
-- PURPOSE
--    Create content item of type SUBMIT_SECTION.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type code. This must be SUBMIT_SECTION.
--       Name of the Submit Section.
--       Owner Resource Id.
--       Resource Type.
--       Content Item Id for the Parent Content Item associated with the parent deliverable.
--       Content Item Version Id for the Parent Content Item.
--       Content Type Code for the Parent Content Item.
--    2. The optional input is as follows:
--       Description.
--    3. This procedure performs the following steps:
--          1. Create a Content Item of type SUBMIT_SECTION using Bulk Insert.
--          2. Create compound relation with the parent.
--    4. This procedure returns the fact that it is successful, it also returns the
--       newly created Content Item Id.
--
-- HISTORY
--    10-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE create_submit_section(
   p_delv_id               IN  NUMBER,
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_owner_resource_id     IN  NUMBER,
   p_owner_resource_type   IN  VARCHAR2,
   p_reusable_flag         IN  VARCHAR2               DEFAULT FND_API.g_false, -- CHANGE to Y or N when IBC folks change the conventions for varchar2 fields.
   p_attribute_type_code   IN  VARCHAR2,
   p_parent_citem_id       IN  NUMBER,
   p_parent_citem_ver_id   IN  NUMBER,
   p_parent_ctype_code     IN  VARCHAR2,
   p_ui_control_type       IN  VARCHAR2               DEFAULT G_DEF_UI_FOR_SUBMIT,
   p_button_label          IN  VARCHAR2,
   p_ocm_image_id          IN  NUMBER                 DEFAULT NULL,
   p_alignment             IN  VARCHAR2               DEFAULT G_DEF_ALIGN_FOR_SUBMIT,
   p_commit                IN  VARCHAR2               DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                 DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                 DEFAULT FND_API.g_valid_level_full,
   x_citem_id              OUT NUMBER,
   x_citem_ver_id          OUT NUMBER,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
   CURSOR c_delv_details IS
     SELECT actual_avail_from_date
            ,actual_avail_to_date
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
   l_start_date            DATE ;
   l_end_date              DATE ;
--
   l_citem_ver_id          NUMBER ;
   l_citem_id              NUMBER ;
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_parent_obj_ver_num    NUMBER ;
   l_parent_citem_ver_id   NUMBER ;
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
--
   l_citem_ids             JTF_NUMBER_TABLE := JTF_NUMBER_TABLE() ;
   l_citem_attrs           JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_dummy_sort_order      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)  := 'Create_Submit_Section';
   l_full_name             CONSTANT    VARCHAR2(60)  := g_pkg_name ||'.'|| l_api_name;
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--
   -- Standard Start of API savepoint
   SAVEPOINT create_submit_section_PVT  ;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
--
   IF p_content_type_code <> G_SUBMIT_SECTION -- Should be a CONSTANT in the package.
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_WRONG_CTYPE_CODE');
      RAISE FND_API.g_exc_error;
   END IF;
--
   x_return_status := FND_API.g_ret_sts_success;

-- Fetch the Deliverable Details.
   OPEN c_delv_details;
   FETCH c_delv_details INTO l_start_date, l_end_date;
   CLOSE c_delv_details;

-- prepare the data for insert.
--
   l_attribute_type_codes.extend() ;
   l_attribute_type_codes(1) := G_UI_CONTROL_TYPE ; -- Should be a CONSTANT in package.
--
   l_attributes.extend() ;
   l_attributes(1) := p_ui_control_type ;
--
   l_attribute_type_codes.extend() ;
   l_attribute_type_codes(2) := G_BUTTON_LABEL; -- Should be a CONSTANT in package.
--
   l_attributes.extend() ;
   l_attributes(2) := p_button_label ;
--
   l_attribute_type_codes.extend() ;
   l_attribute_type_codes(3) := G_OCM_IMAGE_ID ; -- Should be a CONSTANT in package.
--
   l_attributes.extend();
   l_attributes(3) := p_ocm_image_id ;
--
   l_attribute_type_codes.extend() ;
   l_attribute_type_codes(4) := G_ALIGNMENT ; -- Should be a CONSTANT in package.
--
   l_attributes.extend();
   l_attributes(4) := p_alignment ;
--
-- Create a new Content Item in IBC Schema for incoming Content Type.
-- Call upsert_item.

   IBC_CITEM_ADMIN_GRP.upsert_item(
       p_ctype_code              =>     G_SUBMIT_SECTION
       ,p_citem_name             =>     p_content_item_name
       ,p_citem_description      =>     NULL                      -- We do not expose the description in the UI for now.
       ,p_dir_node_id            =>     G_AMS_DIR_NODE_ID
       ,p_owner_resource_id      =>     p_owner_resource_id
       ,p_owner_resource_type    =>     p_owner_resource_type
       ,p_reference_code         =>     NULL                      -- Why is this needed?
       ,p_trans_required         =>     FND_API.g_false           -- This is the default value. For now we do not expose this flag on the UI.
       ,p_parent_item_id         =>     p_parent_citem_id         -- Specify the parent content item id. This item is visible only in the context of this parent.
       ,p_lock_flag              =>     g_lock_flag_value
       ,p_wd_restricted          =>     g_wd_restricted_flag_value
       ,p_start_date             =>     l_start_date
       ,p_end_date               =>     l_end_date
       ,p_attach_file_id         =>     NULL                      -- We do not have any attachment while creating the basic Questions item.
       ,p_attribute_type_codes   =>     l_attribute_type_codes
       ,p_attributes             =>     l_attributes
       ,p_component_citems       =>     NULL
       ,p_component_atypes       =>     NULL
       ,p_sort_order             =>     NULL
       ,p_status                 =>     G_CITEM_WIP_STATUS_CODE   -- When the Deliverable becomes active, we will go in and approve all the underlying content items.
       ,p_log_action             =>     FND_API.g_true            -- This to be sent as TRUE. It updates the Audit Logs.
       ,p_commit                 =>     FND_API.g_false           -- We still have to do some more operations.
       ,p_api_version_number     =>     p_api_version
       ,p_init_msg_list          =>     l_init_msg_list
       ,px_content_item_id       =>     l_citem_id
       ,px_citem_ver_id          =>     l_citem_ver_id
       ,px_object_version_number =>     l_obj_ver_num
       ,x_return_status          =>     l_return_status
       ,x_msg_count              =>     l_msg_count
       ,x_msg_data               =>     l_msg_data
   );

   AMS_UTILITY_PVT.debug_message('After upsert_item.');
   AMS_UTILITY_PVT.debug_message('l_citem_id = ' || l_citem_id);
   AMS_UTILITY_PVT.debug_message('l_citem_ver_id = ' || l_citem_ver_id);
   AMS_UTILITY_PVT.debug_message('l_obj_ver_num = ' || l_obj_ver_num);
   AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_CRE_SUBMIT_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   -- Create the Compound Relation with the parent.
   IF p_parent_citem_ver_id IS NOT NULL
      AND
      p_parent_ctype_code IS NOT NULL
      AND
      p_attribute_type_code IS NOT NULL
   THEN
      -- prepare the data for insert.
      l_citem_attrs.extend();
      l_citem_attrs(1) := p_attribute_type_code;
      --
      l_citem_ids.extend();
      l_citem_ids(1) := l_citem_id;
      --
      l_dummy_sort_order.extend();
      l_dummy_sort_order(1) := 1;
      --

      IF g_using_locking = FND_API.g_true
      THEN

         -- We need to lock the content item before we can add components to it.

         IBC_CITEM_ADMIN_GRP.lock_item(
            p_content_item_id          =>    p_parent_citem_id
            ,p_commit                  =>    g_commit_on_lock_unlock
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_citem_version_id        =>    l_parent_citem_ver_id
            ,x_object_version_number   =>    l_parent_obj_ver_num
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
         );

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_LOCKING_CITEM');
            RAISE FND_API.g_exc_error;
         END IF;

         IF l_parent_citem_ver_id <> p_parent_citem_ver_id
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_CITEM_VER_MISMATCH');
            RAISE FND_API.g_exc_error;
         END IF;

      ELSE

         -- We have to get the object version number separately as we are not using locking.
         l_parent_obj_ver_num := IBC_CITEM_ADMIN_GRP.getObjVerNum( p_parent_citem_id );

      END IF;

      AMS_Utility_PVT.Debug_Message(' p_parent_citem_ver_id = ' || p_parent_citem_ver_id );
      AMS_Utility_PVT.Debug_Message(' obj ver num = ' || l_parent_obj_ver_num );


      -- insert compound relations.
      -- If we use locking, the parent content item and the children content items
      -- must all be locked by the same user in order to get the insert_components
      -- work correctly.

      IBC_CITEM_ADMIN_GRP.insert_components(
         p_citem_ver_id             =>    p_parent_citem_ver_id
         ,p_content_item_ids        =>    l_citem_ids
         ,p_attribute_type_codes    =>    l_citem_attrs
         ,p_sort_order              =>    l_dummy_sort_order   -- The NULL does not work.  -- The new API is supposed to be able to take NULL for this parameter.
         ,p_commit                  =>    FND_API.g_false
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
     );

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_ADD_COMPOUND_REL');
         RAISE FND_API.g_exc_error;
      END IF;

      IF g_using_locking = FND_API.g_true
      THEN

         -- Unlock the parent content item.

         IBC_CITEM_ADMIN_GRP.unlock_item(
            p_content_item_id          =>    p_parent_citem_id
            ,p_commit                  =>    g_commit_on_lock_unlock
            ,p_api_version_number      =>    p_api_version
            ,p_init_msg_list           =>    l_init_msg_list
            ,x_return_status           =>    l_return_status
            ,x_msg_count               =>    l_msg_count
            ,x_msg_data                =>    l_msg_data
         );

         AMS_UTILITY_PVT.debug_message('After Unlock.');
         AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

         IF FND_API.g_ret_sts_success <> l_return_status
         THEN
            AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
            RAISE FND_API.g_exc_error;
         END IF;

      END IF;

   END IF;
--
--
   IF g_using_locking = FND_API.g_true
   THEN

      -- Unlock the Submit Section content item.
      IBC_CITEM_ADMIN_GRP.unlock_item(
         p_content_item_id          =>    l_citem_id
         ,p_commit                  =>    g_commit_on_lock_unlock
         ,p_api_version_number      =>    p_api_version
         ,p_init_msg_list           =>    l_init_msg_list
         ,x_return_status           =>    l_return_status
         ,x_msg_count               =>    l_msg_count
         ,x_msg_data                =>    l_msg_data
      );

      AMS_UTILITY_PVT.debug_message('After Unlock.');
      AMS_UTILITY_PVT.debug_message('l_return_status = ' || l_return_status);

      IF FND_API.g_ret_sts_success <> l_return_status
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_UNLOCK_CITEM');
         RAISE FND_API.g_exc_error;
      END IF;

   END IF;

-- If we come till here, everything has been created successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
   x_return_status := l_return_status;
   x_citem_id := l_citem_id;
   x_citem_ver_id := l_citem_ver_id;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK TO create_submit_section_PVT  ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO create_submit_section_PVT  ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK TO create_submit_section_PVT  ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );

END create_submit_section;






-----------------------------------------------------------------------
-- PROCEDURE
--    update_submit_section
--
-- PURPOSE
--    Update content item of type SUBMIT_SECTION.
--
-- NOTES
--    1. The required input is as follows:
--       Content Type code. This must be SUBMIT_SECTION.
--       Name of the Submit Section.
--       Content Item Id for the section.
--       Content Item Version Id for the section.
--    2. The optional input is as follows:
--       Description.
--       Other data that needs changes.
--    3. This procedure performs the following steps:
--          1. Update a Content Item of type SUBMIT_SECTION.
--    4. This procedure returns the fact that it is successful
--
-- HISTORY
--    11-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------

PROCEDURE update_submit_section(
   p_delv_id               IN  NUMBER,
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_citem_id              IN  NUMBER,
   p_citem_ver_id          IN  NUMBER,
   p_ui_control_type       IN  VARCHAR2,
   p_button_label          IN  VARCHAR2,
   p_ocm_image_id          IN  NUMBER,
   p_alignment             IN  VARCHAR2,
   p_commit                IN  VARCHAR2               DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                 DEFAULT 1.0,
   p_api_validation_level  IN  NUMBER                 DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
--
   l_return_status         VARCHAR2(1) ;
   l_msg_count             NUMBER ;
   l_msg_data              VARCHAR2(2000) ;
--
   l_obj_ver_num           NUMBER ;
--
   l_citem_id              NUMBER ;
   l_citem_ver_id          NUMBER ;
   l_obj_ver_num           NUMBER ;
--
   l_attribute_type_codes  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100() ;
   l_attributes            JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;
--
   l_api_name              CONSTANT    VARCHAR2(30)   := 'Update_Submit_Section';
   l_full_name             CONSTANT    VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
--
   l_init_msg_list         VARCHAR2(1)                := FND_API.g_true;
--
   l_attrib_count          NUMBER                     := 0;
--
   l_api_version_number    CONSTANT NUMBER            := 1.0;
--
BEGIN
--

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   --l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
--
-- Form the arrays with incoming values.
-- Note that at the time of Update all the values are required.
-- So the Calling procedure must make sure that it sends the correct desired
-- values for all the attributes.
-- If incoming values are NULL, they will get updated as NULL.
--
   -- UI Control Type

   l_attrib_count := l_attrib_count + 1;
   l_attribute_type_codes.extend();
   l_attribute_type_codes(l_attrib_count) := G_UI_CONTROL_TYPE ;

   l_attributes.extend();
   l_attributes(l_attrib_count) := p_ui_control_type ;

   -- Button Label

   l_attrib_count := l_attrib_count + 1;
   l_attribute_type_codes.extend();
   l_attribute_type_codes(l_attrib_count) := G_BUTTON_LABEL ;

   l_attributes.extend();
   l_attributes(l_attrib_count) := p_button_label ;

   -- OCM Image Id

   l_attrib_count := l_attrib_count + 1;
   l_attribute_type_codes.extend();
   l_attribute_type_codes(l_attrib_count) := G_OCM_IMAGE_ID ;

   l_attributes.extend();
   l_attributes(l_attrib_count) := p_ocm_image_id ;

   -- Alignment

   l_attrib_count := l_attrib_count + 1;
   l_attribute_type_codes.extend();
   l_attribute_type_codes(l_attrib_count) := G_ALIGNMENT ;

   l_attributes.extend();
   l_attributes(l_attrib_count) := p_alignment ;

-- Call Update_content_item if needed.
--
   IF l_attrib_count > 0
   THEN

      update_content_item(
         p_citem_id                  =>    p_citem_id
         ,p_citem_version_id         =>    p_citem_ver_id
         ,p_content_type_code        =>    p_content_type_code
         ,p_content_item_name        =>    p_content_item_name
         ,p_description              =>    p_description
         ,p_delv_id                  =>    p_delv_id
         ,p_attr_types_for_update    =>    l_attribute_type_codes
         ,p_attr_values_for_update   =>    l_attributes
         ,p_attach_file_id           =>    NULL
         ,p_attach_file_name         =>    NULL
         ,p_commit                   =>    FND_API.g_false
         ,p_api_version              =>    p_api_version
         ,p_api_validation_level     =>    p_api_validation_level
         ,x_return_status            =>    l_return_status
         ,x_msg_count                =>    l_msg_count
         ,x_msg_data                 =>    l_msg_data
      );

   END IF;

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   -- Commit the work and set the output values.

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;

   x_return_status := l_return_status;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );

END update_submit_section;


-----------------------------------------------------------------------
-- PROCEDURE
--    update_questions_section
--
-- PURPOSE
--    Update Questions Section Content Item.
--
-- NOTES
--    1. The required input is as follows:
--       Deliverable ID.
--       Content Item ID for the section.
--       Content Item Version ID for the section.
--       Content Type Code for the Section. This must be QUESTIONS.
--       Content Type Name. (This is the same as Section Name when this item is created in the context of a parent content item).
--       Attachment File ID that has the XML Data.
--       Attachment File Name.
--    2. The optional input is as follows:
--       Description.
--    3. This procedure performs the following steps:
--          1. Arrive at SELECT SQL Statements for each Data Source used in the section.
--          2. Arrive at the FUNCTIONAL_TYPE value.
--          3. Set the Attachment for this Content Item.
--          4. Set the Attribute Bundle for this Content Item.
--             This will consist of the following attributes:
--                SELECT_SQL_STATEMENT (s) : These could be many.
--                FUNCTIONAL_TYPE
--          5. Delete the Data Source Usages records if already available.
--          6. Insert the Data Source Usages records for the Data Sources used.
--    4. This procedure returns the fact that it is successful.
--
-- HISTORY
--    24-MAR-2002   gdeodhar     Created.
--
-----------------------------------------------------------------------
PROCEDURE update_questions_section(
   p_delv_id               IN  NUMBER,
   p_section_citem_id      IN  NUMBER,
   p_section_citem_ver_id  IN  NUMBER,
   p_content_type_code     IN  VARCHAR2,
   p_content_item_name     IN  VARCHAR2,
   p_description           IN  VARCHAR2,
   p_attach_file_id        IN  NUMBER,
   p_attach_file_name      IN  VARCHAR2,
   p_commit                IN  VARCHAR2                DEFAULT FND_API.g_false,
   p_api_version           IN  NUMBER                  DEFAULT 1.0,
   p_init_msg_list         IN  VARCHAR2                DEFAULT FND_API.g_true,
   p_api_validation_level  IN  NUMBER                  DEFAULT FND_API.g_valid_level_full,
   x_return_status         OUT VARCHAR2,
   x_msg_count             OUT NUMBER,
   x_msg_data              OUT VARCHAR2
)
IS
--
-- Declare the local variables and cursors here.
-- test cursor for file id.

   CURSOR c_fild_id_check IS
     SELECT file_id, file_name
       FROM fnd_lobs
      WHERE file_id = p_attach_file_id ;

   l_test_file_id              NUMBER ;
   l_test_file_name            VARCHAR2(250) ;

-- Cursor to select the latest citem version for a content item.
--
   CURSOR c_max_version IS
     SELECT MAX(citem_version_id)
     FROM   ibc_citem_versions_b
     WHERE  content_item_id = p_section_citem_id ;

   l_section_citem_ver_id       NUMBER ;

-- Cursor to select the Deliverable Details to record in the Content Item Data.
--
   CURSOR c_delv_details IS
     SELECT actual_avail_from_date
            ,actual_avail_to_date
     FROM   ams_deliverables_vl
     WHERE  deliverable_id = p_delv_id ;
--
   CURSOR c_profile_ques_count IS
   SELECT count(1)
     FROM ams_cpag_questions_b
    WHERE content_item_id = p_section_citem_id
      AND profile_field_id IS NOT NULL
      AND question_type NOT IN (G_QUESTIONNAIRE, G_SEPARATOR) ;
--
   l_profile_ques_count          NUMBER ;
   l_data_src_type_code          VARCHAR2(240) ;
   l_data_src_fld_id             NUMBER ;
   l_fld_cnt                     NUMBER ;
   l_data_src_cnt                NUMBER ;
--
   CURSOR c_data_src_codes IS
   SELECT DISTINCT de_list_source_type_code
     FROM ams_list_src_fields
    WHERE list_source_field_id IN
          (SELECT profile_field_id
             FROM ams_cpag_questions_b
            WHERE content_item_id = p_section_citem_id
          ) ;
--
   CURSOR c_data_src_flds IS
   SELECT ques.profile_field_id
     FROM ams_cpag_questions_b ques, ams_list_src_fields flds
    WHERE ques.profile_field_id = flds.list_source_field_id
      AND flds.de_list_source_type_code = l_data_src_type_code
      AND ques.content_item_id = p_section_citem_id ;
--
   CURSOR c_data_src_usage_count IS
   SELECT count(1)
     FROM ams_list_src_type_usages
    WHERE list_src_used_by_type = 'CPAGE'
      AND list_src_used_by_id = p_section_citem_id ;

   l_data_src_usage_count        NUMBER ;

--
   l_start_date                  DATE ;
   l_end_date                    DATE ;
--
   l_return_status               VARCHAR2(1) ;
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000) ;
--
   l_err_msg                     VARCHAR2(4000);
--
   l_obj_ver_num                 NUMBER ;
--
   l_attribute_type_codes        JTF_VARCHAR2_TABLE_100  := JTF_VARCHAR2_TABLE_100() ;
   l_attributes                  JTF_VARCHAR2_TABLE_4000 := JTF_VARCHAR2_TABLE_4000() ;

   l_data_src_type_codes         JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300() ;
--
   l_data_src_fld_ids            JTF_NUMBER_TABLE ; -- This is initilized below.
--
   l_init_msg_list               VARCHAR2(1)             := FND_API.g_true;
--
   l_api_version_number          CONSTANT NUMBER         := 1.0;
   l_api_name                    CONSTANT VARCHAR2(30)   := 'update_questions_section';
   l_full_name                   CONSTANT VARCHAR2(60)   := g_pkg_name ||'.'|| l_api_name;
--
   l_attr_count                  NUMBER ;

   l_bind_vars_list              JTF_VARCHAR2_TABLE_300  := JTF_VARCHAR2_TABLE_300() ;
   l_select_sql_statement        VARCHAR2(4000) ;

BEGIN

   OPEN c_fild_id_check ;
   FETCH c_fild_id_check INTO l_test_file_id, l_test_file_name ;
   CLOSE c_fild_id_check ;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message(' l_test_file_id in update_questions_section = ' || l_test_file_id);
   AMS_UTILITY_PVT.debug_message(' l_test_file_name in update_questions_section = ' || l_test_file_name);

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                        p_api_version,
                                        l_api_name,
                                        G_PKG_NAME)
   THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.

   l_init_msg_list := p_init_msg_list;

   IF FND_API.to_Boolean( l_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   l_init_msg_list := FND_API.g_false;

   -- Debug Message
   AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   l_return_status := FND_API.G_RET_STS_SUCCESS;
--
   IF p_content_type_code <> G_QUESTIONS -- Should be a CONSTANT in the package.
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_WRONG_CTYPE_CODE');
      RAISE FND_API.g_exc_error;
   END IF;

-- check the version id.

   OPEN c_max_version ;
   FETCH c_max_version INTO l_section_citem_ver_id ;
   CLOSE c_max_version ;

   IF p_section_citem_ver_id IS NOT NULL
   THEN
      IF p_section_citem_ver_id <> l_section_citem_ver_id
      THEN
         AMS_Utility_PVT.Error_Message('AMS_ERR_CITEM_VER_MISMATCH');
         RAISE FND_API.g_exc_error;
      END IF;
   END IF;
--
-- This API performs the following tasks.
-- 1. Arrive at SELECT SQL Statements for each Data Source used in the section.
-- 2. Arrive at the FUNCTIONAL_TYPE value.
-- 3. Set the Attachment for this Content Item.
-- 4. Set the Attribute Bundle for this Content Item.
--    This will consist of the following attributes:
--       SELECT_SQL_QUERY (s) : These could be many.
--       BIND_VAR (s) : Starting APR 30, 2002. These could also be many. There has to be one for each select sql statement.
--       FUNCTIONAL_TYPE
-- 5. Delete the Data Source Usages records if already available.
-- 6. Insert the Data Source Usages records for the Data Sources used.

-- initialize attribute count.

   l_attr_count := 0;

-- initialize data source count.

   l_data_src_cnt := 0;

-- check if there are any questions based on data sources., if so, generate select
-- sql statement and set into attributes.

   OPEN c_profile_ques_count ;
   FETCH c_profile_ques_count INTO l_profile_ques_count ;
   CLOSE c_profile_ques_count ;

   IF l_profile_ques_count IS NOT NULL
      AND
      l_profile_ques_count > 0
   THEN

      -- Find out all the Data Sources that are used by the questions section.
      -- We have the profile_field_id fields in Questions table.
      -- select distinct de_list_source_type_code
      -- from ams_list_src_fields
      -- where list_source_field_id in
      -- (select profile_field_id
      --  from ams_cpag_questions_b
      --  where content_item_id = <incoming section citem id>
      -- )

      OPEN c_data_src_codes ;
      LOOP
         FETCH c_data_src_codes INTO l_data_src_type_code ;
         EXIT WHEN c_data_src_codes%NOTFOUND ;

         l_data_src_type_codes.extend() ;
         l_data_src_cnt := l_data_src_cnt + 1 ;
         l_data_src_type_codes(l_data_src_cnt) := l_data_src_type_code ;

         -- Note that for the new PIN_CODE based data source, we do not
         -- need to do select ever, as the user will enter the data.

         -- do not generate the select statement
         -- if the Data Source is not valid for generating
         -- select sql query.

         IF l_data_src_type_code NOT IN (G_PIN_CODE_DATA_SRC, G_LEAD_QUAL_DATA_SRC)
         THEN

            -- For this data source, pick all the questions that fall in this
            -- data source and make a list to send to generate_select_sql
            -- select ques.profile_field_id
            --   from ams_cpag_questions_b ques, ams_list_src_fields flds
            --  where ques.profile_field_id = flds.list_source_field_id
            --    and flds.de_list_source_type_code = <the data source type code>

            l_fld_cnt := 0;
            l_data_src_fld_ids := JTF_NUMBER_TABLE();

            OPEN c_data_src_flds ;
            LOOP
               FETCH c_data_src_flds INTO l_data_src_fld_id ;
               EXIT WHEN c_data_src_flds%NOTFOUND ;

               l_data_src_fld_ids.extend() ;
               l_fld_cnt := l_fld_cnt + 1 ;
               l_data_src_fld_ids(l_fld_cnt) := l_data_src_fld_id ;

            END LOOP ;
            CLOSE c_data_src_flds ;

            -- Debug Message
            AMS_UTILITY_PVT.debug_message('Data Src : ' || l_data_src_type_code || ': # of fields : ' || l_fld_cnt );

            IF l_fld_cnt > 0
            THEN
               -- This means that we have some field ids for this data source.
               -- call generate_select_sql.
               generate_select_sql(
                  p_data_source_code          =>    l_data_src_type_code
                  ,p_data_source_fields_list  =>    NULL
                  ,p_data_source_field_ids    =>    l_data_src_fld_ids
                  ,x_select_sql_statement     =>    l_select_sql_statement
                  ,x_bind_vars                =>    l_bind_vars_list
                  ,x_return_status            =>    l_return_status
                  ,x_msg_count                =>    l_msg_count
                  ,x_msg_data                 =>    l_msg_data
               );

               IF FND_API.g_ret_sts_success <> l_return_status
               THEN
                  AMS_Utility_PVT.Error_Message('AMS_ERR_CPAGE_GEN_SQL');
                  RAISE FND_API.g_exc_error;
               END IF;

               AMS_UTILITY_PVT.debug_message( ' l_select_sql_statement = ' || l_select_sql_statement );

               -- Set the attributes for Select SQL Statement and bind variables.
               IF l_select_sql_statement IS NOT NULL
               THEN
                  l_attr_count := l_attr_count + 1;
                  l_attribute_type_codes.extend();
                  l_attribute_type_codes(l_attr_count) := G_SELECT_SQL_QUERY ;

                  l_attributes.extend();
                  l_attributes(l_attr_count) := l_select_sql_statement ;

                  -- Note that for now, we only consider ONE bind variable per
                  -- select SQL statement.
                  -- More over, for Questions section, for now, we only have
                  -- Party ID as the bind variable for all the data sources that
                  -- can be used for questions section. So even if the Bind Var is
                  -- repeating here, the bind variable will be the exact same.
                  -- Check with Avijit and remove Bind Variables from QUESTIONS
                  -- content type, or just add one bind variable as a hardcoded one
                  -- for the entire QUESTIONS section.

                  -- Checked with Avijit and commented the following code on
                  -- March 27th 2002.
                  -- For now the Questions Section can have many Select SQL Queries,
                  -- but has only one bind variable as party id.

                  IF l_bind_vars_list IS NOT NULL
                  THEN
                     FOR i IN l_bind_vars_list.first .. l_bind_vars_list.last
                     LOOP
                        l_attr_count := l_attr_count + 1;
                        l_attribute_type_codes.extend();
                        l_attribute_type_codes(l_attr_count) := G_BIND_VAR;

                        l_attributes.extend();
                        l_attributes(l_attr_count) := l_bind_vars_list(i);
                     END LOOP;
                  END IF;

                  -- Uncommented the above code on April 30, 2002.
                  -- Since we have to support B2B, B2C etc., there will be
                  -- different bind variable names for each Select SQL
                  -- statement.
                  -- The Questions Content Type has been changed to accommodate
                  -- many bind variables.

                  -- Note the the SQL Statement will have the Bind Variable
                  -- followed by it. So the order will be maintained.

               END IF;

            END IF;

         END IF ;

      END LOOP ;
      CLOSE c_data_src_codes ;

   END IF;

   /*
   -- Hardcode one bind variable as amsp (Party Id)
   l_attr_count := l_attr_count + 1;
   l_attribute_type_codes.extend();
   l_attribute_type_codes(l_attr_count) := G_BIND_VAR ;

   l_attributes.extend();
   l_attributes(l_attr_count) := G_BIND_VAR_AMSP ;
   */
   -- Commented the above code on APRIL 30, 2002. We not have a different bind
   -- variable for each Select SQL Statement.

-- At this point, we have all the select sql statements and bind variables generated.

-- Look at the collected data sources and decide on the FUNCTIONAL_TYPE.
-- The possible values are :
-- B2B, B2C, B2B_B2C, QUESTIONNAIRE, NORMAL (This is the default)
-- If there are only B2B data sources associated with this questions section, then
-- the functional type is B2B....and so on.

-- We are not actually using the FUNCTIONAL_TYPE anywhere in the Dialogs and Content
-- Pages at this time.

-- So this part will be coded later. For now FUNCTIONAL_TYPE will be left as NORMAL.

   l_attr_count := l_attr_count + 1;
   l_attribute_type_codes.extend();
   l_attribute_type_codes(l_attr_count) := G_FUNCTIONAL_TYPE ;

   l_attributes.extend();
   l_attributes(l_attr_count) := G_DEFAULT_FUNCTIONAL_TYPE ;

-- At this point the attribute bundle is read for setting.
-- And the attachment has to be set as well.

   FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name, 'Data for update');
   IF l_attribute_type_codes IS NOT NULL
      AND
      l_attributes IS NOT NULL
   THEN
      FOR i IN l_attribute_type_codes.first .. l_attribute_type_codes.last
      LOOP
         l_err_msg := i || ' : >' || l_attribute_type_codes(i) || '< : >' || l_attributes(i) || '<';
         AMS_UTILITY_PVT.debug_message(l_err_msg);
      END LOOP;
   END IF;

   -- call update_content_item.

   update_content_item(
      p_citem_id                  =>    p_section_citem_id
      ,p_citem_version_id         =>    l_section_citem_ver_id
      ,p_content_type_code        =>    p_content_type_code
      ,p_content_item_name        =>    NULL                -- We do not allow update on this one yet.
      ,p_description              =>    NULL                -- We do not allow update on this one yet.
      ,p_delv_id                  =>    p_delv_id
      ,p_attr_types_for_update    =>    l_attribute_type_codes
      ,p_attr_values_for_update   =>    l_attributes
      ,p_attach_file_id           =>    p_attach_file_id
      ,p_attach_file_name         =>    p_attach_file_name
      ,p_commit                   =>    FND_API.g_false
      ,p_api_version              =>    p_api_version
      ,p_api_validation_level     =>    p_api_validation_level
      ,x_return_status            =>    l_return_status
      ,x_msg_count                =>    l_msg_count
      ,x_msg_data                 =>    l_msg_data
      ,p_replace_attr_bundle      =>    FND_API.g_true
   );

   AMS_UTILITY_PVT.debug_message( ' After update_content_item call. ' );

   IF FND_API.g_ret_sts_success <> l_return_status
   THEN
      AMS_Utility_PVT.Error_Message('AMS_ERR_UPDATE_CITEM');
      RAISE FND_API.g_exc_error;
   END IF;

   -- There is a bug in IBC Code. The field attachment_attribute_code in the
   -- table ibc_citem_versions_tl is getting updated some times. Filed a bug on IBC
   -- to track this issue.
   -- Bug # is : 2290924.

   UPDATE ibc_citem_versions_tl
      SET attachment_attribute_code = 'QUESTIONS_XML' -- hardcoding as QUESTIONS_XML for Questions Section.
    WHERE citem_version_id = l_section_citem_ver_id ;

-- Delete all the records from ams_list_src_type_usages for this content item

   OPEN c_data_src_usage_count ;
   FETCH c_data_src_usage_count INTO l_data_src_usage_count ;
   CLOSE c_data_src_usage_count ;

   AMS_UTILITY_PVT.debug_message( ' l_data_src_usage_count = ' || l_data_src_usage_count );

   IF l_data_src_usage_count > 0
   THEN
      DELETE FROM ams_list_src_type_usages
       WHERE list_src_used_by_type = 'CPAGE'
         AND list_src_used_by_id = p_section_citem_id;
   END IF;

   AMS_UTILITY_PVT.debug_message( ' l_data_src_usage_count = ' || l_data_src_usage_count );

-- Insert into ams_list_src_type_usages the usage record for all the Data Sources
-- being used by this content item.

   IF l_data_src_cnt > 0
   THEN

      FOR i IN l_data_src_type_codes.first .. l_data_src_type_codes.last
      LOOP
         AMS_UTILITY_PVT.debug_message( ' There are data sources. ' );

         l_data_src_type_code := l_data_src_type_codes(i);

         AMS_UTILITY_PVT.debug_message( ' Adding usage record for : l_data_src_type_code = ' || l_data_src_type_code );

         INSERT INTO ams_list_src_type_usages
         (
            list_source_type_usage_id
            ,last_update_date
            ,last_updated_by
            ,creation_date
            ,created_by
            ,last_update_login
            ,object_version_number
            ,source_type_code
            ,list_header_id
            ,list_src_used_by_type
            ,list_src_used_by_id
          )
          select
            ams_list_src_type_usages_s.NEXTVAL,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.CONC_LOGIN_ID,
            1,
            substr(l_data_src_type_code, 1, 30),
            0,                                  -- sending list_header_id as 0. -- The index AMS.AMS_LIST_SRC_TYPE_USAGES_U2 has to be dropped from the ODF for this to work correctly.
            'CPAGE',
            p_section_citem_id
         from dual
         where not exists
            ( select  'x'
                from  ams_list_src_type_usages
               where list_header_id = 0
                 and source_type_code = l_data_src_type_code
                 and list_src_used_by_type = 'CPAGE'
                 and list_src_used_by_id = p_section_citem_id
             ) ;

      END LOOP;
   END IF;

-- If we come till here, everything has been updated successfully.
-- Commit the work and set the output values.
--
-- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
      COMMIT WORK;
   END IF;
--
   x_return_status := l_return_status ;
--
-- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.count_and_get(
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );
--
   EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
--

END update_questions_section ;


PROCEDURE erase_blob(
   p_file_id     IN NUMBER,
   x_blob        OUT BLOB,
   p_init_msg_list IN  VARCHAR2 DEFAULT FND_API.g_true,
   x_return_status OUT VARCHAR2,
   x_msg_count     OUT NUMBER,
   x_msg_data      OUT VARCHAR2
)
IS
  l_blob BLOB;
  l_length NUMBER;
  l_api_name CONSTANT VARCHAR2(30) := 'erase_blob';
BEGIN
   AMS_UTILITY_PVT.debug_message('enter erase');

   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   select file_data into l_blob
   from fnd_lobs
   where file_id = p_file_id
   for update;

   l_length := dbms_lob.getlength(l_blob);
   AMS_UTILITY_PVT.debug_message('Length of lob erased : '||TO_CHAR(l_length));

   dbms_lob.erase(l_blob,l_length,1);
   dbms_lob.trim(l_blob,0);

   x_blob := l_blob;

  AMS_UTILITY_PVT.debug_message('erase successful');

EXCEPTION
   WHEN FND_API.g_exc_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
   WHEN OTHERS THEN
      ROLLBACK ;
      x_return_status := FND_API.g_ret_sts_unexp_error;
      IF FND_MSG_PUB.check_msg_level (FND_MSG_PUB.g_msg_lvl_unexp_error) THEN
         FND_MSG_PUB.add_exc_msg (g_pkg_name, l_api_name);
      END IF;
      FND_MSG_PUB.count_and_get (
         p_count         =>     x_msg_count,
         p_data          =>     x_msg_data,
         p_encoded       =>     FND_API.G_FALSE
      );
END erase_blob;



END AMS_CPageUtility_PVT;

/
