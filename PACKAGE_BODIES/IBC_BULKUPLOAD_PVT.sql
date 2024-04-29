--------------------------------------------------------
--  DDL for Package Body IBC_BULKUPLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_BULKUPLOAD_PVT" AS
/* $Header: ibcblkub.pls 120.1 2005/12/16 17:43 srrangar noship $ */
PROCEDURE write_log(p_statement IN VARCHAR2)
IS
BEGIN

   Fnd_Message.SET_ENCODED(p_statement);
   Fnd_Msg_Pub.ADD;
END;
-- --------------------------------------------------------------
-- UPSERT ITEM FULL
--
--
-- --------------------------------------------------------------
PROCEDURE upsert_item_full(
        p_ctype_code                IN VARCHAR2
       ,p_citem_name                IN VARCHAR2
       ,p_dir_node_id               IN NUMBER
       ,p_owner_resource_id         IN NUMBER
       ,p_owner_resource_type       IN VARCHAR2
       ,p_trans_required            IN VARCHAR2
       ,p_start_date                IN DATE
       ,p_end_date                  IN DATE
       ,p_attach_file_id            IN NUMBER
       ,p_item_renditions           IN NUMBER
       ,p_status                    IN VARCHAR2
       ,p_language                  IN VARCHAR2
       ,px_content_item_id          IN OUT NOCOPY NUMBER
       ,px_citem_ver_id             IN OUT NOCOPY NUMBER
       ,x_return_status             OUT NOCOPY VARCHAR2
       ,x_msg_count                 OUT NOCOPY NUMBER
       ,x_msg_data                  OUT NOCOPY VARCHAR2
)IS

l_attribute_type_codes		JTF_VARCHAR2_TABLE_100   := NULL;
l_attributes				JTF_VARCHAR2_TABLE_32767 := NULL;
l_item_renditions			JTF_NUMBER_TABLE := NULL;
l_object_version_number		NUMBER := NULL;

BEGIN

IF p_item_renditions IS NOT NULL THEN
   	 l_item_renditions := JTF_NUMBER_TABLE();
   	 l_item_renditions.EXTEND();
	 l_item_renditions(1) := p_item_renditions;
END IF;

   Ibc_Citem_Admin_Grp.upsert_item_full(
          p_ctype_code                 => p_ctype_code
          ,p_citem_name                => p_citem_name
          ,p_citem_description         => 'Description of ' || p_citem_name
          ,p_dir_node_id               => p_dir_node_id
          ,p_owner_resource_id         => p_owner_resource_id
          ,p_owner_resource_type       => p_owner_resource_type
          ,p_reference_code            => NULL
          ,p_trans_required            => p_trans_required
          ,p_parent_item_id            => NULL
          ,p_lock_flag                 => Fnd_Api.G_FALSE
          ,p_wd_restricted             => Fnd_Api.G_FALSE
          ,p_start_date                => p_start_date
          ,p_end_date                  => p_end_date
          ,p_attribute_type_codes      => l_attribute_type_codes
          ,p_attributes                => l_attributes
          ,p_attach_file_id            => p_attach_file_id
          ,p_item_renditions           => l_item_renditions -- if the user chooses to upload as rendition l_cl_item_renditions
          ,p_default_rendition         => NULL
          ,p_component_citems          => NULL
          ,p_component_citem_ver_ids   => NULL
          ,p_component_atypes          => NULL
          ,p_sort_order                => NULL
          ,p_keywords                  => NULL
          ,p_status                    => p_status
          ,p_log_action                => Fnd_Api.G_TRUE
          ,p_language                  => p_language
          ,p_update                    => Fnd_Api.g_true
          ,p_commit                    => Fnd_Api.G_FALSE
          ,p_api_version_number        => 1.0
          ,p_init_msg_list             => Fnd_Api.G_FALSE
          ,px_content_item_id          => px_content_item_id
          ,px_citem_ver_id             => px_citem_ver_id
          ,px_object_version_number    => l_object_version_number
          ,x_return_status             => x_return_status
          ,x_msg_count                 => x_msg_count
          ,x_msg_data                  => x_msg_data);

END upsert_item_full;

PROCEDURE detect_item_conflict(l_content_item_id IN OUT NOCOPY NUMBER
					,l_citem_version_id IN OUT NOCOPY NUMBER
					,l_content_item_name IN OUT NOCOPY VARCHAR2
					,l_dir_node_id IN NUMBER
					,l_user_option IN VARCHAR2)
IS

CURSOR cur_item_info IS
--query if the content item exists
SELECT a.content_item_id
	   ,a.CITEM_VERSION_ID
	   ,a.CITEM_VERSION_STATUS
	   ,a.version_number
FROM
  ibc_citem_versions_vl a,
  ibc_content_items b
WHERE
  a.content_item_id=b.content_item_id  AND
  b.directory_node_id = l_dir_node_id AND
  a.content_item_name = l_content_item_name AND
  a.version_number = (SELECT MAX(version_number) FROM ibc_citem_versions_b c
  				   	  WHERE c.content_item_id = a.content_item_id);

l_citem_version_status 		VARCHAR2(30);
l_citem_version_number 		NUMBER;

BEGIN

  OPEN cur_item_info;
  FETCH cur_item_info INTO l_content_item_id,l_citem_version_id,l_citem_version_status,l_citem_version_number;
  CLOSE cur_item_info;

  IF l_citem_version_id IS NOT NULL THEN

       IF l_user_option='IBC_UPLOAD_ITEMEXIST_OVERWRITE' THEN
       	 IF l_citem_version_status IN ('SUBMITTED','APPROVED') THEN
     	 	l_citem_version_id := NULL;
     	 END IF;
       ELSIF l_user_option='IBC_UPLOAD_ITEMEXIST_VERSION' THEN
       	  	l_citem_version_id := NULL;
       ELSIF l_user_option='IBC_UPLOAD_ITEMEXIST_SKIP' THEN
       	  --
     	  -- skip creating content item Don't do anything
     	  --
     	  	 NULL;
       ELSIF l_user_option='IBC_UPLOAD_ITEMEXIST_NEW' THEN
     	 	l_citem_version_id 		:= NULL;
			l_content_item_id  		:= NULL;
			l_content_item_name		:= l_content_item_name||TO_CHAR(SYSDATE,'jHHmiSSSSS');
	   END IF;

  END IF;


END;



PROCEDURE BULKUPLOAD_PROCESS(p_bulkupload_id 	 		IN NUMBER
                            ,x_return_status            OUT NOCOPY VARCHAR2
                            ,x_msg_count                OUT NOCOPY NUMBER
                            ,x_msg_data                 OUT NOCOPY VARCHAR2)
IS

l_content_type_code			VARCHAR2(240);
l_content_item_name    		VARCHAR2(240);
l_dir_node_id          		NUMBER;
l_owner_resource_id    		NUMBER;
l_owner_resource_type  		VARCHAR2(240);
l_trans_required       		CHAR(1);
l_start_date           		DATE;
l_end_date             		DATE;
l_attach_file_id       		NUMBER;
l_citem_version_status      VARCHAR2(30);
l_language_code        		CHAR(2);
l_content_item_id           NUMBER;
l_citem_version_id     		NUMBER;

x_wf_item_key				VARCHAR2(240);

l_count						NUMBER;
l_msg						VARCHAR2(4000);
l_access_control			CHAR(1);
l_user_option				VARCHAR2(100);
l_item_renditions			NUMBER;
l_temp						NUMBER;


CURSOR cur_bulk_item_process IS
SELECT	--a.ROWID
	a.content_item_id
	,citem_version_id
	,content_type_code
	,content_item_name
	,directory_node_id
	,owner_resource_id
	,owner_resource_type
	,translation_required_flag
	,start_date
	,end_date
	,attachment_file_id
	,'IBC_UPLOAD_ITEM_STATUS_SUBMIT' citem_version_status
	,'US' language_code
	,NULL content_creation_status
	,'IBC_UPLOAD_ITEMEXIST_NEW' user_option_for_item
	,'IBC_UPLOAD_FILEAS_RENDITION' citem_upload_as
FROM ibc_content_items a, ibc_citem_versions_vl b
WHERE content_type_code='IBC_FILE'
AND a.content_item_id=b.content_item_id
AND citem_version_id=16799;

BEGIN

l_access_control := NVL(Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999), 'N');

  --   ---------------------------------
  --   I N I T I A L I Z E
  --   ---------------------------------
  --
  --
  --
  --
  --

  FOR i_rec IN  cur_bulk_item_process
  LOOP
  --   -----------------------------------------
  --   C R E A T E     C O N T E N T   I T E M
  --   -----------------------------------------

   write_log('Creating Content Item content item .. ');

	l_content_type_code     :=   i_rec.content_type_code;
	l_content_item_name   	:=   i_rec.content_item_name;
	l_dir_node_id         	:=   i_rec.directory_node_id;
	l_owner_resource_id   	:=   i_rec.owner_resource_id;
	l_owner_resource_type 	:=   i_rec.owner_resource_type;
	l_trans_required      	:=   i_rec.translation_required_flag;
	l_start_date          	:=   i_rec.start_date;
	l_end_date            	:=   i_rec.end_date;
	l_citem_version_status 	:=   i_rec.citem_version_status;
	l_language_code			:=   i_rec.language_code;
	l_content_item_id      	:=   i_rec.content_item_id;
	l_citem_version_id    	:=   i_rec.citem_version_id;
	l_user_option			:= 	 i_rec.user_option_for_item;
	l_item_renditions		:= 	 NULL;
	l_attach_file_id		:=	 NULL;

	IF (i_rec.citem_upload_as = 'IBC_UPLOAD_FILEAS_RENDITION') THEN
	   l_item_renditions		:= 	 i_rec.attachment_file_id;
	ELSE
	   l_attach_file_id      	:=   i_rec.attachment_file_id;
	END IF;

   Fnd_Global.apps_initialize(l_owner_resource_id, 23812, 549);

  --   ---------------------------------
  --   I N I T I A L I Z E
  --   ---------------------------------
  --   Detect conflict
  --
  --
  --
  --

  	detect_item_conflict(l_content_item_id
     					,l_citem_version_id
     					,l_content_item_name
     					,l_dir_node_id
     					,l_user_option);


	IF ((l_access_control = 'N') AND (i_rec.citem_version_status IN ('IBC_UPLOAD_ITEM_STATUS_SUBMIT'))) THEN
	   -- access control is off and user submits the item for approval
	   -- it should be auto approved
	   l_citem_version_status 		:= 'APPROVED';
	ELSE
	   l_citem_version_status 		:= 'INPROGRESS';
	END IF;

   write_log('.. Item id to upsert' || l_content_item_id || ' ; Version id = '||l_citem_version_id ||';'|| l_user_option);


   upsert_item_full(
          p_ctype_code                 => l_content_type_code
          ,p_citem_name                => l_content_item_name
          ,p_dir_node_id               => l_dir_node_id
          ,p_owner_resource_id         => l_owner_resource_id
          ,p_owner_resource_type       => l_owner_resource_type
          ,p_trans_required            => l_trans_required
          ,p_start_date                => l_start_date
          ,p_end_date                  => l_end_date
          ,p_attach_file_id            => l_attach_file_id
          ,p_item_renditions           => l_item_renditions
          ,p_status                    => l_citem_version_status
          ,p_language                  => l_language_code
          ,px_content_item_id          => l_content_item_id
          ,px_citem_ver_id             => l_citem_version_id
          ,x_return_status             => x_return_status
          ,x_msg_count                 => x_msg_count
          ,x_msg_data                  => x_msg_data);

   write_log('Content Item created .. return status = '|| x_return_status );
   write_log('Content Item created .. Item id = ' || l_content_item_id || ' ; Version id = '||l_citem_version_id);




   write_log('Trying to approve the item created');
   write_log('i_rec.citem_version_status ' || i_rec.citem_version_status);

	IF ((l_access_control = 'Y') AND (i_rec.citem_version_status IN ('IBC_UPLOAD_ITEM_STATUS_SUBMIT'))) THEN
	     Ibc_Citem_Workflow_Pvt.Submit_For_Approval(
		 p_citem_ver_id              => l_citem_version_id
		 ,px_object_version_number   => l_temp
		 ,x_wf_item_key              => x_wf_item_key
		 ,x_return_status            => x_return_status
		 ,x_msg_count         	     => x_msg_count
		 ,x_msg_data                 => x_msg_data
	       );

		write_log('Approve Item .. return status = '|| x_return_status );
		write_log(' Version id = '||l_citem_version_id);

	END IF;


-- 	    FOR i IN 1 .. l_count LOOP
--           l_msg := Fnd_Msg_Pub.get(i,Fnd_Api.G_FALSE);
--           write_log('(' || i || ') ' || l_msg);
--         END LOOP;
--
-- 		--Fnd_Msg_Pub.Delete_Msg;

	-- UPDATE IBC_BULK_UPLOAD SET content_item_id=l_content_item_id
	-- WHERE ROWID=i_rec.ROWID;

  END LOOP;



END BULKUPLOAD_PROCESS;

END Ibc_Bulkupload_Pvt;

/
