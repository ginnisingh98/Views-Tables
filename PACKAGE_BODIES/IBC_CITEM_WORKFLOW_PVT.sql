--------------------------------------------------------
--  DDL for Package Body IBC_CITEM_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_CITEM_WORKFLOW_PVT" as
/* $Header: ibcciwfb.pls 120.10.12010000.3 2008/09/25 05:43:26 rsatyava ship $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_CITEM_WORKFLOW_PVT';
  G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcciwfb.pls';


  -- --------------------------------------------------------------
  -- GET CONTENT TYPE
  --
  -- Used to check if the content item exists and to get the content
  -- -- type code
  --
  -- --------------------------------------------------------------
  FUNCTION getContentType(
      f_content_item_id  IN  NUMBER
  )
  RETURN VARCHAR2
  IS
    CURSOR c_ctype IS
        SELECT
           content_type_code
        FROM
               ibc_content_items
        WHERE
            content_item_id = f_content_item_id;

    temp IBC_CONTENT_TYPES_B.content_type_code%TYPE;
  BEGIN

    OPEN c_ctype;
    FETCH c_ctype INTO temp;

    IF(c_ctype%NOTFOUND) THEN
        -- not found!
        CLOSE c_ctype;
        RETURN NULL;
    ELSE
        -- found!
        CLOSE c_ctype;
        RETURN temp;
    END IF;
  END;

  FUNCTION get_user_description(p_user_id IN NUMBER) RETURN VARCHAR2
  IS
    l_result      VARCHAR2(80);
    CURSOR c_user_description(p_user_id NUMBER) IS
      SELECT description
        FROM fnd_user
       WHERE user_id = p_user_id;
  BEGIN
    OPEN c_user_description(p_user_id);
    FETCH c_user_description INTO l_result;
    CLOSE c_user_description;
    RETURN l_result;
  END get_user_description;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Create_User_List
  -- DESCRIPTION: Given p_resource_id and p_resource_type, it returns
  --              a comma separated list of usernames(p_user_list).
  -- --------------------------------------------------------------------
  PROCEDURE Create_User_List(
    p_resource_id    IN NUMBER
    ,p_resource_type IN VARCHAR2
    ,p_user_list     IN OUT NOCOPY VARCHAR2
  ) IS

    l_resource_type    VARCHAR2(30);
    l_resource_number  VARCHAR2(30);
    l_user_name        VARCHAR2(30);

    CURSOR c_grp_members(p_resource_id NUMBER) IS
      SELECT  group_id  group_id,  resource_id  group_resource_id,  'INDIVIDUAL'  resource_type
        FROM jtf_rs_group_members
       WHERE group_id = p_resource_id
         AND delete_flag = 'N'
       UNION
      SELECT rgm.group_id  group_id,  rgr.group_id  group_resource_id,  'GROUP'   resource_type
        FROM jtf_rs_group_members rgm, jtf_rs_grp_relations rgr
       WHERE rgm.group_id = rgr.related_group_id
         AND rgm.group_id = p_resource_id
         AND rgm.delete_flag = 'N'
         AND rgr.delete_flag = 'N';

    CURSOR c_user_name(p_resource_id IN NUMBER) IS
      SELECT resource_number, user_name
        FROM jtf_rs_resource_extns
       WHERE resource_id = p_resource_id;

  BEGIN

    l_resource_type := RTRIM(p_resource_type);

    IF l_resource_type IN ('GROUP', 'RS_GROUP') THEN
      FOR rec_member IN c_grp_members(p_resource_id) LOOP
        Create_User_List(p_resource_id   => rec_member.group_resource_id,
                         p_resource_type => rec_member.resource_type,
                         p_user_list     => p_user_list);
      END LOOP;
    ELSE
      OPEN c_user_name(p_resource_id);
      FETCH c_user_name INTO l_resource_number, l_user_name;
      IF c_user_name%FOUND AND l_user_name IS NOT NULL THEN
        IF p_user_list IS NOT NULL THEN
          p_user_list := p_user_list || ', ' || l_user_name;
        ELSE
          p_user_list := l_user_name;
        END IF;
      END IF;
      CLOSE c_user_name;
    END IF;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Create_User_List;

  FUNCTION Remove_Duplicates(p_list IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_list    VARCHAR2(5000);
    l_result  VARCHAR2(5000);
    l_sep_pos NUMBER;
    l_value   VARCHAR2(80);
  BEGIN

    l_list := p_list;

    LOOP
      l_sep_pos := INSTR(l_list, ',');
      IF l_sep_pos > 0 THEN
        l_value := SUBSTR(l_list, 1, l_sep_pos - 1);
      ELSE
        l_value := l_list;
      END IF;
      l_value := RTRIM(LTRIM(l_value));
      IF l_value IS NOT NULL THEN
        IF NVL(INSTR(l_result, '[' || l_value || ']'), 0) = 0 THEN
          IF l_result IS NULL THEN
            l_result := '[' || l_value || ']';
          ELSE
            l_result := l_result || ',[' || l_value || ']';
          END IF;
        END IF;
        l_list := SUBSTR(l_list, l_sep_pos + 1);
      END IF;
      EXIT WHEN l_value IS NULL or l_sep_pos = 0;
    END LOOP;

    l_result := REPLACE(REPLACE(l_result, '[',''), ']', '');

    RETURN l_result;

  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Remove_Duplicates;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Create_Workflow_Role
  -- DESCRIPTION: It creates an Adhoc workflow role based on the user
  --              list resulting from p_resource_id and p_resource_type.
  --              The role name (p_wf_role_name) and display name
  --              (p_wf_role_display_name) could be passed, otherwise
  --              it will be defaulted thru WF Api.
  -- --------------------------------------------------------------------
  PROCEDURE Create_Workflow_Role(
    p_resource_id               IN NUMBER DEFAULT NULL
    ,p_resource_type            IN VARCHAR2 DEFAULT NULL
    ,p_user_list                IN VARCHAR2 DEFAULT NULL
    ,px_wf_role_name            IN OUT NOCOPY VARCHAR2
    ,px_wf_role_display_name    IN OUT NOCOPY VARCHAR2
    ,p_add_to_list              IN VARCHAR2 DEFAULT NULL
  ) IS
    l_user_list       VARCHAR2(5000);
  BEGIN
    IF p_user_list IS NULL THEN
      Create_User_List(p_resource_id   => p_resource_id,
                       p_resource_type => p_resource_type,
                       p_user_list     => l_user_list);
    ELSE
      l_user_list := p_user_list;
    END IF;
    IF l_user_list IS NOT NULL THEN
      IF p_add_to_list IS NOT NULL THEN
        l_user_list := l_user_list || ', ' || p_add_to_list;
      END IF;
      WF_DIRECTORY.CreateAdHocRole(
        role_name          => px_wf_role_name
        ,role_display_name => px_wf_role_display_name
        ,role_users        => Remove_Duplicates(l_user_list)
	,notification_preference => 'MAILHTML'
      );
    ELSIF p_add_to_list IS NOT NULL THEN
      l_user_list := p_add_to_list;
      WF_DIRECTORY.CreateAdHocRole(
        role_name          => px_wf_role_name
        ,role_display_name => px_wf_role_display_name
        ,role_users        => Remove_Duplicates(l_user_list)
	,notification_preference => 'MAILHTML'
      );
    ELSE
      -- Nullifies output variables
      px_wf_role_name := NULL;
      px_wf_role_display_name := NULL;
    END IF;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Create_Workflow_Role;

  -- --------------------------------------------------------------
  -- GET CONTENT ITEM ID
  --
  -- Used to get content item id from version id
  --
  -- --------------------------------------------------------------
  FUNCTION getCitemId(
      f_citem_version_id   IN  NUMBER
  ) RETURN NUMBER IS
    CURSOR c_item IS
      SELECT content_item_id
        FROM ibc_citem_versions_b
       WHERE citem_version_id = f_citem_version_id;
      temp NUMBER;
  BEGIN
    open c_item;
    fetch c_item into temp;
    if (c_item%NOTFOUND) then
        close c_item;
        RETURN null;
    else
        close c_item;
        RETURN temp;
    end if;
  END getCitemId;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Submit_For_Approval
  -- DESCRIPTION: It launches Content Item Approval Workflow process
  -- PARAMETERS:
  --   p_citem_ver_id          => Content Item Version ID
  --   p_object_version_number => Content Item Object Version Number
  --   p_notes_to_approver     => Comments/Notes send to approver(s)
  --   p_priority              => WF Notification priority
  --   p_callback_URL          => URL Link to be shown in the notification
  --                              in order to access the content item
  --                              Some parameters will be replaced in the
  --                              content (parameters are prefixed with an
  --                              Ampersand and all uppercase):
  --                              CITEM_VERSION_ID => Content Item version ID
  --                              ITEM_TYPE        => WF Item Type
  --                              ITEM_KEY         => WF Item Key
  --                              ACTION_MODE      => Action Mode (SUBMITTED,
  --                                                  APPROVED or REJECTED)
  --   p_callback_url_description => Description to appear in notification
  --   p_language              => Content Item's Language
  --   x_wf_item_key           => WF item key
  --   <Default standard API parms>
  -- --------------------------------------------------------------------
  PROCEDURE Submit_For_Approval(
    p_citem_ver_id              IN  NUMBER
    ,p_notes_to_approver        IN  VARCHAR2
    ,p_priority                 IN  NUMBER
    ,p_callback_url             IN  VARCHAR2
    ,p_callback_url_description IN  VARCHAR2
    ,p_language                 IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,px_object_version_number   IN OUT NOCOPY NUMBER
    ,x_wf_item_key              OUT NOCOPY VARCHAR2
    ,x_return_status            OUT NOCOPY VARCHAR2
    ,x_msg_count                    OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  ) IS

    --******** local variable for standards **********
    l_api_name                     CONSTANT VARCHAR2(30)   := 'Submit_For_Approval';
    l_api_version                  CONSTANT NUMBER := 1.0;
    l_dummy                        VARCHAR2(2);

    l_owner_resource_id            NUMBER;
    l_owner_resource_type          VARCHAR2(30);
    l_owner_name                   VARCHAR2(30);
    l_version_number               NUMBER;

    l_user_list                    VARCHAR2(4096);
    l_reply_to                     VARCHAR2(4096);

    l_creator_id                   NUMBER;
    l_wf_role_name                 VARCHAR2(240);
    l_wf_role_display_name         VARCHAR2(80);
    l_wf_no_approver_defined       VARCHAR2(1);
    l_already_approved             VARCHAR2(1);

    l_content_item_id              NUMBER;
    l_citem_name                   VARCHAR2(240);
    l_submitter_name               VARCHAR2(240);

    l_format_callback_url          VARCHAR2(2000);
    l_callback_url_description     VARCHAR2(2000);

    l_ItemType                     VARCHAR2(30) := 'IBC_WF';
    l_ItemKey                      VARCHAR2(80) := p_citem_ver_id || '@/' || p_language || '/' || TO_CHAR(SYSDATE, 'YYYYMMDD-HH24:MI:SS');

    l_directory_node_id            NUMBER;
    l_directory_path               VARCHAR2(4000);

    l_citem_object_type            NUMBER := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM');
    l_directory_object_type        NUMBER := IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE');

    CURSOR c_directory(p_content_item_id NUMBER) IS
      SELECT citem.directory_node_id, dirnode.directory_path
        FROM ibc_content_items citem,
             ibc_directory_nodes_b dirnode
       WHERE citem.content_item_id = p_content_item_id
         AND citem.directory_node_id = dirnode.directory_node_id;

    -- Cursor to get resource_id and type from current logged-on user.
    CURSOR c_resource IS
      SELECT resource_id,
             DECODE(category ,'EMPLOYEE', 'RS_EMPLOYEE',
                                     'PARTNER','RS_PARTNER',
                                            'SUPPLIER_CONTACT', 'RS_SUPPLIER' ,
                                            'PARTY', 'RS_PARTY' ,
                                                   'OTHER','RS_OTHER',
                                            'TBH', 'RS_TBH')  resource_type
        FROM jtf_rs_resource_extns
       WHERE user_id = FND_GLOBAL.USER_ID;

    CURSOR c_owner(p_citem_ver_id NUMBER) IS
      SELECT owner_resource_id,
             owner_resource_type,
             civer.version_number,
             citem.created_by
        FROM ibc_citem_versions_b civer,
             ibc_content_items citem
       WHERE civer.citem_version_id = p_citem_ver_id
         AND civer.content_item_id = citem.content_item_id;

    CURSOR c_citem_name(p_citem_ver_id NUMBER) IS
      SELECT content_item_name
        FROM ibc_citem_versions_tl
       WHERE citem_version_id = p_citem_ver_id
         AND language = p_language;

    CURSOR c_user_name(p_user_id IN NUMBER) IS
      SELECT user_name
        FROM FND_USER
       WHERE USER_ID = p_user_id;

    CURSOR c_submitter_name IS
      SELECT INITCAP(user_name)
        FROM fnd_user
       WHERE USER_ID = FND_GLOBAL.USER_ID;

    CURSOR c_component_not_status (p_citem_ver_id IN NUMBER,
                                   p_status IN VARCHAR2)
    IS
      SELECT 'X'
       FROM ibc_citem_versions_b a,
            ibc_compound_relations b,
            ibc_content_items c
      WHERE a.citem_version_id = b.citem_version_id
        AND b.content_item_id = c.content_item_id
        AND a.citem_version_id = p_citem_ver_id
        AND c.content_item_status <> p_status;

  BEGIN

    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    -- Validation of Content Item before submitting it for approval
    IBC_CITEM_ADMIN_GRP.pre_validate_item(
      p_citem_ver_id        => p_citem_ver_id
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Validation of Components (they need to be approved already)
    OPEN c_component_not_status(p_citem_ver_id, IBC_UTILITIES_PUB.G_STV_APPROVED);
    FETCH c_component_not_status INTO l_dummy;
    IF (c_component_not_status%FOUND) THEN
      CLOSE c_component_not_status;
      x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'COMPONENT_APPROVAL_REQUIRED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_component_not_status;

    l_content_item_id := getCitemId(p_citem_ver_id);
    OPEN c_directory(l_content_item_id);
    FETCH c_directory INTO l_directory_node_id, l_directory_path;
    CLOSE c_directory;

    IF IBC_DATA_SECURITY_PVT.has_permission(
         p_instance_object_id    => l_citem_object_type
         ,p_instance_pk1_value   => l_content_item_id
         ,p_permission_code      => 'CITEM_APPROVE'
         ,p_container_object_id  => l_directory_object_type
         ,p_container_pk1_value  => l_directory_node_id) = FND_API.g_false
       AND
       NVL(Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999), 'N') = 'Y'
    THEN
      IBC_DATA_SECURITY_PVT.get_grantee_usernames(
        p_instance_object_id   => l_citem_object_type
        ,p_instance_pk1_value  => l_content_item_id
        ,p_permission_code     => 'CITEM_APPROVE'
        ,p_container_object_id => l_directory_object_type
        ,p_container_pk1_value => l_directory_node_id
        ,x_usernames           => l_user_list
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
       );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_user_list IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'IBC_NOT_APPROVER_DEFINED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        Create_Workflow_Role(
          p_user_list              => l_user_list
                ,px_wf_role_name         => l_wf_role_name
                ,px_wf_role_display_name => l_wf_role_display_name
        );
      END IF;
    ELSE
      -- Submitter is Approver or No security Enabled.
      l_wf_no_approver_defined := 'Y';
    END IF;

    -- Unlock Content Id
    IBC_CITEM_ADMIN_GRP.unlock_item(
      p_content_item_id           => l_content_item_id
     ,p_commit                    => FND_API.g_false
     ,p_init_msg_list             => FND_API.g_false
     ,x_return_status             => x_return_status
     ,x_msg_count                 => x_msg_count
     ,x_msg_data                  => x_msg_data
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Approval Will go through Workflow
    -- Creation of workflow process
    WF_ENGINE.createProcess( ItemType => l_ItemType,
                             ItemKey  => l_ItemKey,
                             process  => 'IBC_CITEM_APPROVAL');

    -- Set WF attribute values

    WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               aname    => 'DIRECTORY_PATH',
                               avalue   => l_directory_path);

    WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               aname    => 'SUBMITTED_BY',
                               avalue   => FND_GLOBAL.USER_NAME);

    OPEN c_submitter_name;
    FETCH c_submitter_name INTO l_submitter_name;
    IF c_submitter_name%FOUND AND l_submitter_name IS NOT NULL THEN
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'SUBMITTER_NAME',
                                 avalue   => l_submitter_name);
    END IF;
    CLOSE c_submitter_name;

    l_already_approved := 'N';
    IF l_wf_no_approver_defined = 'Y' AND
       NVL(Fnd_Profile.Value_specific('IBC_CUSTOMIZED_APPROVAL_WF',-999,-999,-999), 'N') = 'N'
    THEN
      -- If no approver or submitter is approver
      -- and approval workflow has not been customized
      -- then change status directly.
      -- Requiremente driven by PRP, but generalized.
      IBC_CITEM_ADMIN_GRP.change_status(
         p_citem_ver_id           => p_citem_ver_id
        ,p_new_status             => IBC_UTILITIES_PUB.G_STV_APPROVED
        ,p_language               => p_language
        ,p_commit                 => FND_API.g_false
        ,p_init_msg_list          => FND_API.g_false
        ,px_object_version_number => px_object_version_number
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
      );
      -- Set ALREADY_APPROVED to Y
      l_already_approved := 'Y'; -- Fix for bug# 3410110
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'ALREADY_APPROVED',
                                 avalue   => 'Y');

    ELSE
      -- Set Status of Content Item to SUBMITTED
      px_object_version_number := NVL(px_object_version_number,
                                        IBC_CITEM_ADMIN_GRP.getObjVerNum(l_content_item_id));
      IBC_CITEM_ADMIN_GRP.change_status(
        p_citem_ver_id           => p_citem_ver_id
        ,p_new_status             => IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL
        ,p_language               => p_language
        ,p_commit                 => FND_API.g_false
        ,p_init_msg_list          => FND_API.g_true
        ,px_object_version_number => px_object_version_number
        ,x_return_status          => x_return_status
        ,x_msg_count              => x_msg_count
        ,x_msg_data               => x_msg_data
      );
      -- Set ALREADY_APPROVED to N
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'ALREADY_APPROVED',
                                 avalue   => 'N');
    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    OPEN c_owner(p_citem_ver_id);
    FETCH c_owner INTO l_owner_resource_id, l_owner_resource_type, l_version_number, l_creator_id;

    -- Functionality for Approval in case IBC_USE_ACCESS_CONTROL is set to 'N'
    IF l_wf_no_approver_defined = 'Y' AND
       NVL(Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999), 'N') = 'N' AND
       l_owner_resource_id IS NOT NULL AND
       ((l_owner_resource_type IS NULL AND l_owner_resource_id <> l_creator_id) OR
        (l_owner_resource_type IS NOT NULL AND
         IBC_UTILITIES_PVT.check_current_user(NULL,l_owner_resource_id,l_owner_resource_type, l_creator_id) = 'FALSE'))
    THEN
      l_wf_no_approver_defined := 'N';
      IF l_owner_resource_type IS NOT NULL THEN  -- Owner is a resource
        Create_Workflow_Role(
          p_resource_id            => l_owner_resource_id
          ,p_resource_type         => l_owner_resource_type
          ,px_wf_role_name         => l_wf_role_name
          ,px_wf_role_display_name => l_wf_role_display_name
        );
      ELSE -- Owner is a user FND_USER
        OPEN c_user_name(l_owner_resource_id);
        FETCH c_user_name INTO l_owner_name;
        CLOSE c_user_name;
        Create_Workflow_Role(
          p_user_list              => l_owner_name
          ,px_wf_role_name         => l_wf_role_name
          ,px_wf_role_display_name => l_wf_role_display_name
        );
      END IF;
    END IF;

    WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               aname    => 'NO_APPROVER_DEFINED',
                               avalue   => l_wf_no_approver_defined);

    WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               aname    => 'CITEM_APPROVER_ROLE',
                               avalue   => l_wf_role_name);

    -- Set REPLY_TO Role Attribute, and CITEM Version Number
    IF l_already_approved <> 'Y' THEN   -- Fix for bug# 3410110
      l_wf_role_name := NULL;
      l_wf_role_display_name := NULL;
      Create_Workflow_Role(
        p_resource_id            => l_owner_resource_id
        ,p_resource_type         => l_owner_resource_type
        ,px_wf_role_name         => l_wf_role_name
        ,px_wf_role_display_name => l_wf_role_display_name
        ,p_add_to_list           => FND_GLOBAL.USER_NAME
      );
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'REPLY_TO',
                                 avalue   => l_wf_role_name);
    END IF;

    CLOSE c_owner;

    WF_ENGINE.SetItemAttrNumber( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'CITEM_VER_ID',
                                 avalue   => p_citem_ver_id);

    WF_ENGINE.SetItemAttrNumber( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'CITEM_VERSION_NBR',
                                 avalue   => l_version_number);

    WF_ENGINE.SetItemAttrNumber( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'CITEM_OBJECT_VERSION_NUMBER',
                                 avalue   => px_object_version_number);

    OPEN c_citem_name(p_citem_ver_id);
    FETCH c_citem_name INTO l_citem_name;
    IF c_citem_name%FOUND AND l_citem_name IS NOT NULL THEN
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'CONTENT_ITEM_NAME',
                                 avalue   => l_citem_name);
    END IF;
    CLOSE c_citem_name;

    IF p_notes_to_approver IS NOT NULL THEN
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'NOTES_TO_APPROVER',
                                 avalue   => p_notes_to_approver);
    END IF;

    IF p_priority IS NOT NULL THEN
      WF_ENGINE.SetItemAttrNumber( itemtype => l_ItemType,
                                   itemkey  => l_Itemkey,
                                   aname    => 'PRIORITY',
                                   avalue   => p_priority);
    END IF;

    IF p_callback_url IS NOT NULL THEN
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'UNTOUCHED_CALLBACK_URL',
                                 avalue   => p_callback_url);
      -- Replace Info on Callback URL
      l_format_callback_url := p_callback_url;
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'CONTENT_ITEM_ID',
                                           l_content_item_id);
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'CITEM_VERSION_NBR',
                                           l_version_number);
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'CITEM_VERSION_ID',
                                           p_citem_ver_id);
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'CONTENT_TYPE_CODE',
                                           getContentType(l_content_item_id));
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'OBJECT_VERSION_NUMBER',
                                                   px_object_version_number);
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'CONTENT_ITEM_LANGUAGE',
                                                   p_language);
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'ITEM_TYPE',
                                           l_ItemType);
      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'ITEM_KEY',
                                           l_ItemKey);
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'ORIGINAL_CALLBACK_URL',
                                 avalue   => l_format_callback_url);

      l_format_callback_url := REPLACE(l_format_callback_url,
                                       FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE',
                                                   IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL);

      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'CALLBACK_URL',
                                 avalue   => l_format_callback_url);
      l_callback_url_description := NVL(p_callback_url_description, l_format_callback_url);
      WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                 itemkey  => l_Itemkey,
                                 aname    => 'CALLBACK_URL_DESCRIPTION',
                                 avalue   => l_callback_url_description);
    END IF;

    WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                               itemkey  => l_Itemkey,
                               aname    => 'CITEM_LANGUAGE',
                               avalue   => p_language);

    -- Start WF Process
    WF_ENGINE.StartProcess ( ItemType => l_ItemType,
                             ItemKey  => l_ItemKey);

    -- If everything is okay so far then set x_wf_item_key
    x_wf_item_key := l_ItemKey;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END Submit_For_Approval;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Approve_Citem_Version
  -- DESCRIPTION: Procedure to be called from WF to actually perform the
  --              approval process thru status change API.
  --              If it's approved succesfully then 'COMPLETE:Y' will be
  --              returned and callback URL updated, otherwise
  --              'COMPLETE:N' will be returned along with error
  --              stack assigned to 'ERROR_MESSAGE_STACK' WF Attribute.
  --              (Standard WF API)
  -- --------------------------------------------------------------------
  PROCEDURE Approve_Citem_Version(itemtype IN VARCHAR2,
                                  itemkey  IN VARCHAR2,
                                  actid    IN NUMBER,
                                  funcmode IN VARCHAR2,
                                  result   IN OUT NOCOPY VARCHAR2) IS
    l_callback_url           VARCHAR2(2000);
    l_citem_ver_id           NUMBER;
    l_object_version_number  NUMBER;
    l_language               VARCHAR2(4);
    l_return_status          VARCHAR2(30);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_error_msg_stack        VARCHAR2(10000);
  BEGIN
    result := '';
    IF funcmode = 'RUN' THEN
      result := 'COMPLETE:Y';
      l_citem_ver_id := WF_ENGINE.GetItemAttrNumber(
                                                  itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'CITEM_VER_ID'
                        );
      l_object_version_number := IBC_CITEM_ADMIN_GRP.getObjVerNum(getCitemId(l_citem_ver_id));
      l_language := WF_ENGINE.GetItemAttrText(
                                              itemtype => itemtype,
                                              itemkey  => itemkey,
                                              aname    => 'CITEM_LANGUAGE'
                    );

      IF l_citem_ver_id IS NOT NULL THEN

        IBC_CITEM_ADMIN_GRP.change_status(
          p_citem_ver_id           => l_citem_ver_id
         ,p_new_status             => IBC_UTILITIES_PUB.G_STV_APPROVED
         ,p_language               => l_language
         ,p_commit                 => FND_API.g_true
         ,p_init_msg_list          => FND_API.g_true
         ,px_object_version_number => l_object_version_number
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
        );

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          WF_ENGINE.SetItemAttrText( itemtype => itemtype,
                                     itemkey  => itemkey,
                                     aname    => 'APPROVER_NAME',
                                     avalue   => get_user_description(FND_GLOBAL.user_id));
          l_callback_url          := WF_ENGINE.GetItemAttrText(
                                                               itemtype => itemtype,
                                                               itemkey  => itemkey,
                                                               aname    => 'ORIGINAL_CALLBACK_URL'
                                     );
          IF l_callback_url IS NOT NULL THEN
            l_callback_url := REPLACE(l_callback_url,
                                      FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE',
                                      IBC_UTILITIES_PUB.G_STV_APPROVED);
              WF_ENGINE.SetItemAttrText(
              itemtype => itemtype,
              itemkey  => itemkey,
              aname    => 'CALLBACK_URL',
              avalue   => l_callback_url
            );
          END IF;

          -- Audit Log Action
          IBC_AUDIT_LOG_GRP.log_action(
            p_activity       => 'APPROVE'
            ,p_object_type   => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
            ,p_object_value1 => l_citem_ver_id
            ,p_parent_value  => getCitemId(l_citem_ver_id)
                 ,p_commit                 => FND_API.g_true
            ,p_init_msg_list          => FND_API.g_true
            ,x_return_status          => l_return_status
            ,x_msg_count              => l_msg_count
            ,x_msg_data               => l_msg_data
          );
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                -- IF l_return_status not successful then return 'N'
          result := 'COMPLETE:N';
          IBC_UTILITIES_PVT.Get_Messages (
            p_message_count => l_msg_count,
            x_msgs          => l_error_msg_stack
          );
          l_error_msg_stack := FND_GLOBAL.Newline() || 'CITEM_VER_ID:' || l_citem_ver_id ||
                               '     -  Object Version Number:' || l_object_version_number ||
                               FND_GLOBAL.NewLine() || l_error_msg_stack;
          WF_ENGINE.SetItemAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'ERROR_MESSAGE_STACK',
            avalue   => l_error_msg_stack
          );
        END IF;
      END IF;
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
    RAISE;
  END Approve_Citem_Version;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Process_Approval_Response
  -- DESCRIPTION: Procedure to be called from WF to process the response
  --              for approval notification request.
  --              It focuses more on REJECTED response to set callback
  --              URL
  --              (Standard WF API)
  -- --------------------------------------------------------------------
  PROCEDURE Process_Approval_Response(itemtype IN VARCHAR2,
                                      itemkey  IN VARCHAR2,
                                      actid    IN NUMBER,
                                      funcmode IN VARCHAR2,
                                      result   IN OUT NOCOPY VARCHAR2) IS
    l_callback_url           VARCHAR2(2000);
    l_citem_ver_id           NUMBER;
    l_language               VARCHAR2(4);
    l_return_status          VARCHAR2(30);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_object_version_number  NUMBER;
    l_response_code          VARCHAR2(30);
    l_error_msg_stack        VARCHAR2(10000);
    l_comments               VARCHAR2(10000);
  BEGIN
    result := '';
    IF funcmode IN ('RUN') THEN
      l_callback_url          := WF_ENGINE.GetItemAttrText(
                                             itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'ORIGINAL_CALLBACK_URL'
                                 );
      l_response_code := WF_ENGINE.GetItemAttrText(
                    itemtype => itemtype,
                    itemkey  => itemkey,
                    aname    => 'RESULT'
                  );
      IF l_response_code = 'N'
      THEN
        l_citem_ver_id := WF_ENGINE.GetItemAttrNumber(
                                                  itemtype => itemtype,
                                                  itemkey  => itemkey,
                                                  aname    => 'CITEM_VER_ID'
                            );
        l_object_version_number := IBC_CITEM_ADMIN_GRP.getObjVerNum(getCitemId(l_citem_ver_id));
        l_language := WF_ENGINE.GetItemAttrText(
                                          itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'CITEM_LANGUAGE'
                      );
        IBC_CITEM_ADMIN_GRP.change_status(
          p_citem_ver_id           => l_citem_ver_id
         ,p_new_status             => IBC_UTILITIES_PUB.G_STV_REJECTED
         ,p_language               => l_language
         ,p_commit                 => FND_API.g_true
         ,p_init_msg_list          => FND_API.g_true
         ,px_object_version_number => l_object_version_number
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
        );

        IF l_callback_url IS NOT NULL THEN
          l_callback_url := REPLACE(l_callback_url,
                                         FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE',
                                                            IBC_UTILITIES_PUB.G_STV_REJECTED);
          WF_ENGINE.SetItemAttrText(
                            itemtype => itemtype,
                            itemkey  => itemkey,
                            aname    => 'CALLBACK_URL',
                            avalue   => l_callback_url
          );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- Audit Log Action
          l_comments          := WF_ENGINE.GetItemAttrText(
                                             itemtype => itemtype,
                                                           itemkey  => itemkey,
                                                           aname    => 'NOTES_TO_SUBMITTER'
                                           );
          IBC_AUDIT_LOG_GRP.log_action(
            p_activity           => 'REJECT'
            ,p_object_type       => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
            ,p_object_value1     => l_citem_ver_id
            ,p_parent_value      => getCitemId(l_citem_ver_id)
            ,p_extra_info1_type  => IBC_AUDIT_LOG_GRP.G_EI_CONSTANT
            ,p_extra_info1_value => l_comments
                 ,p_commit            => FND_API.g_true
            ,p_init_msg_list     => FND_API.g_true
            ,x_return_status     => l_return_status
            ,x_msg_count         => l_msg_count
            ,x_msg_data          => l_msg_data
          );
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IBC_UTILITIES_PVT.Get_Messages (
            p_message_count => l_msg_count,
            x_msgs          => l_error_msg_stack
          );
          l_error_msg_stack := FND_GLOBAL.Newline() || 'CITEM_VER_ID:' || l_citem_ver_id ||
                               '     -  Object Version Number:' || l_object_version_number ||
                               FND_GLOBAL.NewLine() || l_error_msg_stack;
          WF_ENGINE.SetItemAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'ERROR_MESSAGE_STACK',
            avalue   => l_error_msg_stack
          );
        END IF;

      END IF;
    END IF;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Process_Approval_Response;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Process_Translations
  -- DESCRIPTION:
  -- --------------------------------------------------------------------
  PROCEDURE Process_Translations(itemtype IN VARCHAR2,
                                 itemkey  IN VARCHAR2,
                                 actid    IN NUMBER,
                                 funcmode IN VARCHAR2,
                                 result   IN OUT NOCOPY VARCHAR2) IS
    l_citem_ver_id           NUMBER;
    l_language               VARCHAR2(4);
    l_content_item_id        NUMBER;
    l_directory_node_id      NUMBER;
    l_version_number         NUMBER;
    l_user_list              VARCHAR2(4096);
    l_base_language          VARCHAR2(4);
    l_translation_required   VARCHAR2(1);
    l_ItemType               VARCHAR2(30) := 'IBC_WF';
    l_ItemKey                VARCHAR2(30);
    l_return_status          VARCHAR2(30);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_error_msg_stack        VARCHAR2(10000);
    l_wf_role_name           VARCHAR2(240);
    l_wf_role_display_name   VARCHAR2(80);
    l_citem_name             VARCHAR2(240);
    l_format_callback_url    VARCHAR2(2000);
    CURSOR c_citem_info(p_citem_version_id NUMBER) IS
      SELECT ci.content_item_id,
             ci.base_language,
             ci.translation_required_flag,
             ci.directory_node_id,
             civ.version_number
        FROM ibc_citem_versions_b civ,
             ibc_content_items ci
       WHERE ci.content_item_id = civ.content_item_id
         AND civ.citem_version_id = p_citem_version_id;
    CURSOR c_citem_name(p_citem_ver_id NUMBER, p_language VARCHAR2) IS
      SELECT content_item_name
        FROM ibc_citem_versions_tl
       WHERE citem_version_id = p_citem_ver_id
         AND language = p_language;

    CURSOR c_directory(p_content_item_id NUMBER) IS
      SELECT citem.directory_node_id, dirnode.directory_path
        FROM ibc_content_items citem,
             ibc_directory_nodes_b dirnode
       WHERE citem.content_item_id = p_content_item_id
         AND citem.directory_node_id = dirnode.directory_node_id;
    --l_directory_node_id            NUMBER;
    l_directory_path               VARCHAR2(4000);

  BEGIN
    result := '';
    IF funcmode IN ('RUN') THEN
      l_citem_ver_id := WF_ENGINE.GetItemAttrNumber(
                                                           itemtype => itemtype,
                                                      itemkey  => itemkey,
                                                      aname    => 'CITEM_VER_ID'
                        );
      l_language := WF_ENGINE.GetItemAttrText(
                                          itemtype => itemtype,
                                          itemkey  => itemkey,
                                          aname    => 'CITEM_LANGUAGE'
                    );
      OPEN c_citem_info(l_citem_ver_id);
      FETCH c_citem_info INTO l_content_item_id, l_base_language,
                              l_translation_required, l_directory_node_id,
                              l_version_number;
      IF l_translation_required = FND_API.g_true
      THEN

        OPEN c_directory(l_content_item_id);
        FETCH c_directory INTO l_directory_node_id, l_directory_path;
        CLOSE c_directory;

        IBC_DATA_SECURITY_PVT.get_grantee_usernames(
          p_instance_object_id   => IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM')
          ,p_instance_pk1_value  => l_content_item_id
          ,p_permission_code     => 'CITEM_TRANSLATE'
          ,p_container_object_id => IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE')
          ,p_container_pk1_value => l_directory_node_id
          ,x_usernames           => l_user_list
          ,x_return_status       => l_return_status
          ,x_msg_count           => l_msg_count
          ,x_msg_data            => l_msg_data
         );

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          result := 'COMPLETE:Y';
          IF l_user_list IS NOT NULL THEN
            l_ItemKey :=  l_citem_ver_id || '@T' || TO_CHAR(SYSDATE, 'YYYYMMDD-HH24:MI:SS');

            Create_Workflow_Role(
              p_user_list              => l_user_list
                ,px_wf_role_name         => l_wf_role_name
                ,px_wf_role_display_name => l_wf_role_display_name
            );

            -- Creation of Translations workflow process
            WF_ENGINE.createProcess( ItemType => l_ItemType,
                                     ItemKey  => l_ItemKey,
                                     process  => 'IBC_CITEM_TRANSLATE');

            -- Set Parent Process
            WF_ENGINE.set_item_parent(itemtype        => l_ItemType,
                                      itemkey         => l_ItemKey,
                                      parent_itemtype => itemtype,
                                      parent_itemkey  => itemkey,
                                      parent_context  => 'Parent Process');

            -- Set parameter CITEM_VER_ID
            WF_ENGINE.SetItemAttrNumber( itemtype => l_ItemType,
                                         itemkey  => l_Itemkey,
                                         aname    => 'CITEM_VER_ID',
                                         avalue   => l_citem_ver_id);

            -- Set parameter CITEM_VERSION_NBR
            WF_ENGINE.SetItemAttrNumber( itemtype => l_ItemType,
                                         itemkey  => l_Itemkey,
                                         aname    => 'CITEM_VERSION_NBR',
                                         avalue   => l_version_number);

            -- Set parameter CITEM_TRANSLATORS_ROLE
            WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                       itemkey  => l_Itemkey,
                                       aname    => 'CITEM_TRANSLATORS_ROLE',
                                       avalue   => l_wf_role_name);

            -- Set parameter CONTENT_ITEM_NAME
            OPEN c_citem_name(l_citem_ver_id, l_language);
            FETCH c_citem_name INTO l_citem_name;
            IF c_citem_name%FOUND AND l_citem_name IS NOT NULL THEN
              WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                         itemkey  => l_Itemkey,
                                         aname    => 'CONTENT_ITEM_NAME',
                                         avalue   => l_citem_name);
            END IF;
            CLOSE c_citem_name;

            -- Set parameter CALLBACK_URL_DESCRIPTION
            WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                       itemkey  => l_Itemkey,
                                       aname    => 'CALLBACK_URL_DESCRIPTION',
                                       avalue   => WF_ENGINE.GetItemAttrText(
                                                          itemtype => itemtype,
                                                               itemkey  => itemkey,
                                                                aname    => 'CALLBACK_URL_DESCRIPTION'));


            -- Replace Info on Callback URL
            l_format_callback_url := WF_ENGINE.GetItemAttrText(
                                                 itemtype => itemtype,
                                                 itemkey  => itemkey,
                                                 aname    => 'UNTOUCHED_CALLBACK_URL'
                                     );
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'CONTENT_ITEM_ID',
                                                 l_content_item_id);
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'CITEM_VERSION_NBR',
                                                     l_version_number);
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'CONTENT_TYPE_CODE',
                                                 getContentType(l_content_item_id));
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'CITEM_VERSION_ID',
                                                                       l_citem_ver_id);
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'OBJECT_VERSION_NUMBER',
                                                                       IBC_CITEM_ADMIN_GRP.getobjvernum(l_content_item_id));
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'CONTENT_ITEM_LANGUAGE',
                                                                       l_language);
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'ITEM_TYPE',
                                                                       l_ItemType);
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'ITEM_KEY',
                                                                       l_ItemKey);
            l_format_callback_url := REPLACE(l_format_callback_url,
                                             FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE',
                                                                       'TRANSLATE');
            WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                       itemkey  => l_Itemkey,
                                       aname    => 'CALLBACK_URL',
                                       avalue   => l_format_callback_url);

            -- Set directory Path
            WF_ENGINE.SetItemAttrText( itemtype => l_ItemType,
                                       itemkey  => l_Itemkey,
                                       aname    => 'DIRECTORY_PATH',
                                       avalue   => l_directory_path);

            -- Start WF Process
            WF_ENGINE.StartProcess ( ItemType => l_ItemType,
                                     ItemKey  => l_ItemKey);

            NULL;
          END IF;
        ELSE
                -- IF l_return_status not successful then return 'N'
          result := 'COMPLETE:N';
          l_error_msg_stack := 'Error During IBC_CITEM_WORKFLOW_PVT.Process_Translations  -- ' ||
                               FND_GLOBAL.Newline() || 'CITEM_VER_ID:' || l_citem_ver_id;
          l_error_msg_stack := l_error_msg_stack || FND_GLOBAL.Newline() || 'Return Status: ' ||
                               l_return_status || FND_GLOBAL.Newline() || FND_GLOBAL.Newline() ;
          FOR I IN 1..l_msg_count LOOP
            l_error_msg_stack := l_error_msg_stack || '  ...  ' ||
                                 FND_MSG_PUB.get(p_encoded => FND_API.g_false) ||
                                 FND_GLOBAL.Newline();
          END LOOP;
          WF_ENGINE.SetItemAttrText(
            itemtype => itemtype,
            itemkey  => itemkey,
            aname    => 'ERROR_MESSAGE_STACK',
            avalue   => l_error_msg_stack
          );
        END IF;
	  ELSE
	     -- IF Translation is not required
	   result:='COMPLETE:Y';
      END IF;
      CLOSE c_citem_info;
    END IF;
  -- Exception Handler Added for NOCOPY Change (11/08/2002) By ENUNEZ
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Process_Translations;


  -- --------------------------------------------------------------------
  -- PROCEDURE: Respond_Approval_Notification
  -- DESCRIPTION: Responds approval notification request, and optionally
  --              pass notes/comments to submitter.
  -- PARAMETERS:
  --   p_item_type             => WF item type
  --   p_item_key              => WF item key
  --   p_activity              => WF Activity
  --   p_response              => Response to Notification (either Y or N)
  --   p_notes_to_submitter    => Notes/Comments to Submitter.
  --   <Default standard API parms>
  -- --------------------------------------------------------------------
  PROCEDURE Respond_Approval_Notification(
    p_item_type                 IN  VARCHAR2
    ,p_item_key                 IN  VARCHAR2
    ,p_activity                 IN  VARCHAR2
    ,p_response                 IN  VARCHAR2
    ,p_notes_to_submitter       IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                       OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  ) IS
      --******** local variable for standards **********
    l_api_name                     CONSTANT VARCHAR2(30)   := 'Respond_Approval_Notification';
    l_api_version                  CONSTANT NUMBER := 1.0;
    l_dummy                        VARCHAR2(2);
    CURSOR c_chk_notification IS
      SELECT 'X'
        FROM ibc_pending_approvals_v
       WHERE item_key = p_item_key;
  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    OPEN c_chk_notification;
    FETCH c_chk_notification INTO l_dummy;
    IF c_chk_notification%NOTFOUND THEN
      CLOSE c_chk_notification;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'IBC_NOTIF_ALREADY_RESPONDED');
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c_chk_notification;

    IF p_response IN ('Y', 'N') THEN
      WF_ENGINE.SetItemAttrText( itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'APPROVER_NAME',
                                 avalue   => get_user_description(FND_GLOBAL.user_id));
      IF p_notes_to_submitter IS NOT NULL THEN
        WF_ENGINE.SetItemAttrText( itemtype => p_item_type,
                                   itemkey  => p_item_key,
                                   aname    => 'NOTES_TO_SUBMITTER',
                                   avalue   => p_notes_to_submitter);
      END IF;
      WF_ENGINE.SetItemAttrText( itemtype => p_item_type,
                                 itemkey  => p_item_key,
                                 aname    => 'RESULT',
                                 avalue   => p_response);
      WF_ENGINE.CompleteActivity(p_item_type,
                                 p_item_key,
                                                 p_activity,
                                                 p_response);
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MESSAGE.Set_Name('IBC', 'BAD_INPUT_VALUE');
      FND_MESSAGE.Set_Token('INPUT', 'p_response', FALSE);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END Respond_Approval_Notification;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Close_Translation_Request
  -- DESCRIPTION: Closes Translation Request from inbox
  -- PARAMETERS:
  --   p_item_type             => WF item type
  --   p_item_key              => WF item key
  --   <Default standard API parms>
  -- --------------------------------------------------------------------
  PROCEDURE Close_Translation_Request(
    p_item_type                 IN  VARCHAR2
    ,p_item_key                 IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                       OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  ) IS
      --******** local variable for standards **********
    l_api_name                     CONSTANT VARCHAR2(30)   := 'Close_Translation_Request';
    l_api_version                  CONSTANT NUMBER := 1.0;
  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin

    WF_ENGINE.CompleteActivity(p_item_type,
                               p_item_key,
                                                 'IBC_CITEM_TRANSLATE_REQ',
                                                 NULL);

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END Close_Translation_Request;


  -- --------------------------------------------------------------------
  -- PROCEDURE: Get_Pending_Approvals
  -- DESCRIPTION: Fetch all notifications (for current user) associated
  -- to Content Manager and with the format set by Submit_for_Approval
  -- PARAMETERS:
  --  - x_citem_version_ids     Table of content item version ids
  --  - x_wf_item_keys          Table of Workflow Item Keys, these
  --                            values can be used to respond (Approve
  --                            or Reject) notifications calling
  --                            Respond_Approval_Notification
  --   <Default standard API parms>
  -- --------------------------------------------------------------------
  PROCEDURE Get_Pending_Approvals(
    x_citem_version_ids         OUT NOCOPY jtf_number_table
    ,x_wf_item_keys             OUT NOCOPY jtf_varchar2_table_100
    ,p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                       OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  ) IS

    l_index                        NUMBER;

    -- Cursor to obtain notifications associated to Content Manager
    -- for current user and which item key has the format followed by
    -- Submit_For_Approval proc.
    CURSOR c_notifications IS
      SELECT *
        FROM IBC_PENDING_APPROVALS_V
       WHERE USER_NAME = FND_GLOBAL.USER_NAME;

      --******** local variable for standards **********
    l_api_name                     CONSTANT VARCHAR2(30)   := 'Get_Pending_Approvals';
    l_api_version                  CONSTANT NUMBER := 1.0;

    TYPE t_citem_version_id_tbl IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
    TYPE t_wf_item_key_tbl IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;
    l_citem_version_id_tbl         t_citem_version_id_tbl;
    l_wf_item_key_tbl              t_wf_item_key_tbl;

  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin
    l_index := 0;
    FOR r_notification IN c_notifications LOOP
      l_index := l_index + 1;
      l_citem_version_id_tbl(l_index) := r_notification.citem_version_id;
      l_wf_item_key_tbl(l_index)      := r_notification.item_key;
    END LOOP;

    IF l_index > 0 THEN
      x_citem_version_ids := JTF_NUMBER_TABLE();
      x_citem_version_ids.EXTEND(l_index);
      x_wf_item_keys      := JTF_VARCHAR2_TABLE_100();
      x_wf_item_keys.EXTEND(l_index);
      FOR I IN 1..l_index LOOP
        x_citem_version_ids(I) := l_citem_version_id_tbl(I);
        x_wf_item_keys(I)   := l_wf_item_key_tbl(I);
      END LOOP;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END Get_Pending_Approvals;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Get_Pending_Translations
  -- DESCRIPTION: Fetch all notifications (for current user) associated
  -- to Content Manager and for translation requests
  -- PARAMETERS:
  --  - x_citem_version_ids     Table of content item version ids
  --  - x_wf_item_keys          Table of Workflow Item Keys, these
  --                            values can be used to close notifications
  --                            calling close_fyi_notification
  --   <Default standard API parms>
  -- --------------------------------------------------------------------
  PROCEDURE Get_Pending_Translations(
    x_citem_version_ids         OUT NOCOPY jtf_number_table
    ,x_wf_item_keys             OUT NOCOPY jtf_varchar2_table_100
    ,p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,x_return_status               OUT NOCOPY VARCHAR2
    ,x_msg_count                       OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  ) IS

    l_index                        NUMBER;

    -- Cursor to obtain notifications associated to Content Manager
    -- for current user and which item key has the format followed by
    -- Submit_For_Approval proc.
    CURSOR c_notifications IS
      SELECT *
        FROM IBC_PENDING_TRANSLATIONS_V
       WHERE USER_NAME = FND_GLOBAL.USER_NAME;

      --******** local variable for standards **********
    l_api_name                     CONSTANT VARCHAR2(30)   := 'Get_Pending_Translations';
    l_api_version                  CONSTANT NUMBER := 1.0;

    TYPE t_citem_version_id_tbl IS TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
    TYPE t_wf_item_key_tbl IS TABLE OF VARCHAR2(100)
      INDEX BY BINARY_INTEGER;
    l_citem_version_id_tbl         t_citem_version_id_tbl;
    l_wf_item_key_tbl              t_wf_item_key_tbl;

  BEGIN
    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin
    l_index := 0;
    FOR r_notification IN c_notifications LOOP
      l_index := l_index + 1;
      l_citem_version_id_tbl(l_index) := r_notification.citem_version_id;
      l_wf_item_key_tbl(l_index)      := r_notification.item_key;
    END LOOP;

    IF l_index > 0 THEN
      x_citem_version_ids := JTF_NUMBER_TABLE();
      x_citem_version_ids.EXTEND(l_index);
      x_wf_item_keys      := JTF_VARCHAR2_TABLE_100();
      x_wf_item_keys.EXTEND(l_index);
      FOR I IN 1..l_index LOOP
        x_citem_version_ids(I) := l_citem_version_id_tbl(I);
        x_wf_item_keys(I)   := l_wf_item_key_tbl(I);
      END LOOP;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
          P_API_NAME => L_API_NAME
          ,P_PKG_NAME => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE => SQLCODE
          ,P_SQLERRM => SQLERRM
          ,X_MSG_COUNT => X_MSG_COUNT
          ,X_MSG_DATA => X_MSG_DATA
          ,X_RETURN_STATUS => X_RETURN_STATUS
      );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
           );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
               P_API_NAME => L_API_NAME
               ,P_PKG_NAME => G_PKG_NAME
               ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
               ,P_PACKAGE_TYPE => IBC_UTILITIES_PVT.G_PVT
               ,P_SQLCODE => SQLCODE
               ,P_SQLERRM => SQLERRM
               ,X_MSG_COUNT => X_MSG_COUNT
               ,X_MSG_DATA => X_MSG_DATA
               ,X_RETURN_STATUS => X_RETURN_STATUS
          );
  END Get_Pending_Translations;

  -- --------------------------------------------------------------------
  -- PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Submit_For_Trans_Approval
  -- DESCRIPTION: It launches Content Item Translation Approval Workflow process
  -- PARAMETERS:
  --   p_citem_ver_id          => Content Item Version ID
  --   p_object_version_number => Content Item Object Version Number
  --   p_notes_to_approver     => Comments/Notes send to approver(s)
  --   p_priority              => WF Notification priority
  --   p_callback_URL          => URL Link to be shown in the notification
  --                              in order to access the content item
  --                              Some parameters will be replaced in the
  --                              content (parameters are prefixed with an
  --                              Ampersand and all uppercase):
  --                              CITEM_VERSION_ID => Content Item version ID
  --                              ITEM_TYPE        => WF Item Type
  --                              ITEM_KEY         => WF Item Key
  --                              ACTION_MODE      => Action Mode (SUBMITTED,
  --                                                  APPROVED or REJECTED)
  --   p_callback_url_description => Description to appear in notification
  --   p_language                 => Content Item's Language
  --   x_wf_item_key              => WF item key
  --   <Default standard API parms>
  -- --------------------------------------------------------------------
  PROCEDURE Submit_For_Trans_Approval(
     p_citem_ver_id             IN  NUMBER
    ,p_notes_to_approver        IN  VARCHAR2
    ,p_priority                 IN  NUMBER
    ,p_callback_url             IN  VARCHAR2
    ,p_callback_url_description IN  VARCHAR2
    ,p_language                 IN  VARCHAR2
    ,p_commit                   IN  VARCHAR2
    ,p_api_version              IN  NUMBER
    ,p_init_msg_list            IN  VARCHAR2
    ,px_object_version_number   IN  OUT NOCOPY NUMBER
    ,x_wf_item_key              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data                 OUT NOCOPY VARCHAR2
  ) IS

    --******** local variable for standards **********
    l_api_name                     CONSTANT VARCHAR2(30)   := 'Submit_For_Trans_Approval';
    l_api_version                  CONSTANT NUMBER := 1.0;
    l_dummy                        VARCHAR2(2);

    l_owner_resource_id            NUMBER;
    l_owner_resource_type          VARCHAR2(30);
    l_owner_name                   VARCHAR2(30);
    l_version_number               NUMBER;

    l_user_list                    VARCHAR2(4096);
    l_reply_to                     VARCHAR2(4096);

    l_creator_id                   NUMBER;
    l_wf_role_name                 VARCHAR2(240);
    l_wf_role_display_name         VARCHAR2(80);
    l_wf_no_approver_defined       VARCHAR2(1);

    l_content_item_id              NUMBER;
    l_citem_name                   VARCHAR2(240);
    l_submitter_name               VARCHAR2(240);

    l_format_callback_url          VARCHAR2(2000);
    l_callback_url_description     VARCHAR2(2000);

    -- Initialize the Workflow Item Type and Key
    l_ItemType                     VARCHAR2(30) := 'IBC_WF';
    --l_ItemKey                      VARCHAR2(30) := p_citem_ver_id || '@TA' || TO_CHAR(SYSDATE, 'YYYYMMDD-HH24:MI:SS');
    l_ItemKey                      VARCHAR2(30) := p_citem_ver_id||'@TA/'||p_language||TO_CHAR(SYSDATE, '/YYYYMMDD-HH24:MI:SS');

    l_directory_node_id            NUMBER;
    l_directory_path               VARCHAR2(4000);

    l_citem_object_type            NUMBER := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM');
    l_directory_object_type        NUMBER := IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE');

    CURSOR c_directory(p_content_item_id NUMBER) IS
      SELECT citem.directory_node_id, dirnode.directory_path
        FROM ibc_content_items citem,
             ibc_directory_nodes_b dirnode
       WHERE citem.content_item_id = p_content_item_id
         AND citem.directory_node_id = dirnode.directory_node_id;


    -- Cursor to get resource_id and type from current logged-on user.
    CURSOR c_resource IS
      SELECT  resource_id
             ,DECODE(category ,'EMPLOYEE', 'RS_EMPLOYEE'
                              ,'PARTNER','RS_PARTNER'
                              ,'SUPPLIER_CONTACT', 'RS_SUPPLIER'
                              ,'PARTY', 'RS_PARTY'
                              ,'OTHER','RS_OTHER'
                              ,'TBH', 'RS_TBH')  resource_type
        FROM jtf_rs_resource_extns
       WHERE user_id = FND_GLOBAL.USER_ID;

    CURSOR c_owner(p_citem_ver_id NUMBER) IS
      SELECT  CITEM.owner_resource_id
             ,CITEM.owner_resource_type
             ,CIVER.version_number
             ,CITEM.created_by
        FROM  ibc_citem_versions_b CIVER
             ,ibc_content_items CITEM
       WHERE CIVER.citem_version_id = p_citem_ver_id
         AND CIVER.content_item_id = CITEM.content_item_id;

    CURSOR c_citem_name(p_citem_ver_id NUMBER) IS
      SELECT content_item_name
        FROM ibc_citem_versions_tl
       WHERE citem_version_id = p_citem_ver_id
         AND language = p_language;

    CURSOR c_user_name(p_user_id IN NUMBER) IS
      SELECT user_name
        FROM FND_USER
       WHERE USER_ID = p_user_id;

    CURSOR c_submitter_name IS
      SELECT INITCAP(user_name)
        FROM fnd_user
       WHERE USER_ID = FND_GLOBAL.USER_ID;

    CURSOR c_component_not_status (p_citem_ver_id IN NUMBER,
                                   p_status IN VARCHAR2)
    IS
      SELECT 'X'
       FROM  ibc_citem_versions_b a
            ,ibc_compound_relations b
            ,ibc_content_items c
      WHERE a.citem_version_id = b.citem_version_id
        AND b.content_item_id = c.content_item_id
        AND a.citem_version_id = p_citem_ver_id
        AND c.content_item_status <> p_status;

    l_language_description           VARCHAR2(255);

  BEGIN

    -- ******* Standard Begins ********

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
              l_api_version,
              p_api_version,
              l_api_name,
              G_PKG_NAME)
    THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Begin


    l_content_item_id := getCitemId(p_citem_ver_id);

    OPEN c_directory(l_content_item_id);
    FETCH c_directory INTO l_directory_node_id, l_directory_path;
    CLOSE c_directory;


    IF IBC_DATA_SECURITY_PVT.has_permission(
          p_instance_object_id  => l_citem_object_type
         ,p_instance_pk1_value  => l_content_item_id
         ,p_permission_code     => 'CITEM_APPROVE_TRANSLATE'
         ,p_container_object_id => l_directory_object_type
         ,p_container_pk1_value => l_directory_node_id) = FND_API.g_false
       AND
       NVL(Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999), 'N') = 'Y'
    THEN
      IBC_DATA_SECURITY_PVT.get_grantee_usernames(
         p_instance_object_id   => l_citem_object_type
        ,p_instance_pk1_value  => l_content_item_id
        ,p_permission_code     => 'CITEM_APPROVE_TRANSLATE'
        ,p_container_object_id => l_directory_object_type
        ,p_container_pk1_value => l_directory_node_id
        ,x_usernames           => l_user_list
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
       );
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_user_list IS NULL THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
            FND_MESSAGE.Set_Name('IBC', 'IBC_NOT_APPROVER_DEFINED');
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      ELSE
        Create_Workflow_Role(p_user_list             => l_user_list
                            ,px_wf_role_name         => l_wf_role_name
                            ,px_wf_role_display_name => l_wf_role_display_name
                            );
      END IF;
    ELSE
      -- Current user/Submitter is approver or if security is disabled
      l_wf_no_approver_defined := 'Y';
    END IF;

    px_object_version_number := NVL(px_object_version_number
                                   ,IBC_CITEM_ADMIN_GRP.getObjVerNum(l_content_item_id)
                                   );


    --======================================================================
    --======================================================================
    -- If no approver defined and the the WF profile is disabled then
    -- directly approve the version without invoking the WF.
    --======================================================================
    --======================================================================

    IF l_wf_no_approver_defined = 'Y' AND
       NVL(Fnd_Profile.Value_specific('IBC_CUSTOMIZED_APPROVAL_WF',-999,-999,-999), 'N') = 'N'
    THEN
      -- Set Status of Content Item Version
      IBC_CITEM_ADMIN_GRP.Change_Translation_Status(
        p_citem_ver_id           => p_citem_ver_id
       ,p_new_status             => IBC_UTILITIES_PUB.G_STV_APPROVED -- Change the status to approve
       ,p_language               => p_language
       ,p_commit                 => FND_API.g_false
       ,p_init_msg_list          => FND_API.g_true
       ,px_object_version_number => px_object_version_number
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      x_wf_item_key := -1;

      --UI Logging
      IBC_AUDIT_LOG_GRP.log_action(
         p_activity             => Ibc_Utilities_Pvt.G_ALA_APPROVE
        ,p_object_type          => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
        ,p_object_value1        => p_citem_ver_id
        ,p_object_value2        => p_language
        ,p_parent_value         => getCitemId(p_citem_ver_id)
        ,p_message_application  => 'IBC'
        ,p_message_name         => 'IBC_TRANS_LOG_MSG'
        ,p_extra_info2_type     => IBC_AUDIT_LOG_GRP.G_EI_LOOKUP
        ,p_extra_info2_ref_type => 'IBC_CITEM_VERSION_STATUS'
        ,p_extra_info2_value    => IBC_UTILITIES_PUB.G_STV_APPROVED
        --,p_commit               => FND_API.g_true
        ,p_init_msg_list        => FND_API.g_true
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
      );


    ELSE
    --======================================================================
    --======================================================================
    -- Else invoke the WF.
    --======================================================================
    --======================================================================

      -- Set Status of Content Item Version
      IBC_CITEM_ADMIN_GRP.Change_Translation_Status(
        p_citem_ver_id           => p_citem_ver_id
       ,p_new_status             => IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL -- Change the status to submitted
       ,p_language               => p_language
       ,p_commit                 => FND_API.g_false
       ,p_init_msg_list          => FND_API.g_true
       ,px_object_version_number => px_object_version_number
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
       );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --UI Logging
      IBC_AUDIT_LOG_GRP.log_action(
         p_activity             => Ibc_Utilities_Pvt.G_ALA_SUBMIT
        ,p_object_type          => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
        ,p_object_value1        => p_citem_ver_id
        ,p_object_value2        => p_language
        ,p_parent_value         => getCitemId(p_citem_ver_id)
        ,p_message_application  => 'IBC'
        ,p_message_name         => 'IBC_TRANS_LOG_MSG'
        ,p_extra_info2_type     => IBC_AUDIT_LOG_GRP.G_EI_LOOKUP
        ,p_extra_info2_ref_type => 'IBC_CITEM_VERSION_STATUS'
        ,p_extra_info2_value    => IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL
        --,p_commit               => FND_API.g_true
        ,p_init_msg_list        => FND_API.g_true
        ,x_return_status        => x_return_status
        ,x_msg_count            => x_msg_count
        ,x_msg_data             => x_msg_data
      );

      -- Workflow related Code
      -- Creation of workflow process for Content Item Translation Approval
      WF_ENGINE.createProcess(itemType => l_ItemType
                             ,itemKey  => l_ItemKey
                             ,process  => 'IBC_CITEM_TRANSLATE_APPROVAL'
                             );

      -- Set WF attribute values
      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'DIRECTORY_PATH'
                               ,avalue   => l_directory_path
                               );

      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'SUBMITTED_BY'
                               ,avalue   => FND_GLOBAL.USER_NAME
                               );

      OPEN c_submitter_name;
      FETCH c_submitter_name INTO l_submitter_name;
      IF c_submitter_name%FOUND AND l_submitter_name IS NOT NULL THEN
        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'SUBMITTER_NAME'
                                 ,avalue   => l_submitter_name
                                 );
      END IF;
      CLOSE c_submitter_name;




      OPEN c_owner(p_citem_ver_id);
      FETCH c_owner INTO l_owner_resource_id, l_owner_resource_type, l_version_number, l_creator_id;

      -- Functionality for Approval in case IBC_USE_ACCESS_CONTROL is set to 'N'
      -- If the submitter is not the owner then send a notification to him by a
      -- creating an appripriate role.

      IF     l_wf_no_approver_defined = 'Y'
         AND NVL(Fnd_Profile.Value_specific('IBC_USE_ACCESS_CONTROL',-999,-999,-999), 'N') = 'N'
         AND l_owner_resource_id IS NOT NULL
         AND ((    l_owner_resource_type IS NULL
               AND l_owner_resource_id <> l_creator_id)
              OR
              (l_owner_resource_type IS NOT NULL
               AND IBC_UTILITIES_PVT.check_current_user(NULL
                                                       ,l_owner_resource_id
                                                       ,l_owner_resource_type
                                                       ,l_creator_id) = 'FALSE'))
      THEN
        l_wf_no_approver_defined := 'N';
        IF l_owner_resource_type IS NOT NULL THEN  -- Owner is a resource
          Create_Workflow_Role(
               p_resource_id           => l_owner_resource_id
            ,p_resource_type         => l_owner_resource_type
            ,px_wf_role_name         => l_wf_role_name
            ,px_wf_role_display_name => l_wf_role_display_name
          );
        ELSE -- Owner is a user FND_USER
          OPEN c_user_name(l_owner_resource_id);
          FETCH c_user_name INTO l_owner_name;
          CLOSE c_user_name;
          Create_Workflow_Role(
               p_user_list             => l_owner_name
            ,px_wf_role_name         => l_wf_role_name
            ,px_wf_role_display_name => l_wf_role_display_name
          );
        END IF;
      END IF;


      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'NO_APPROVER_DEFINED'
                               ,avalue   => l_wf_no_approver_defined
                               );

      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'CITEM_TRANS_APPROVER_ROLE'--'CITEM_APPROVER_ROLE'
                               ,avalue   => l_wf_role_name);

      -- Set REPLY_TO Role Attribute, and CITEM Version Number
      l_wf_role_name := NULL;
      l_wf_role_display_name := NULL;
      Create_Workflow_Role(
         p_resource_id           => l_owner_resource_id
        ,p_resource_type         => l_owner_resource_type
        ,px_wf_role_name         => l_wf_role_name
        ,px_wf_role_display_name => l_wf_role_display_name
        ,p_add_to_list           => FND_GLOBAL.USER_NAME
      );
      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'REPLY_TO'
                               ,avalue   => l_wf_role_name);
      CLOSE c_owner;

      WF_ENGINE.SetItemAttrNumber(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'CITEM_VER_ID'
                                 ,avalue   => p_citem_ver_id);

      WF_ENGINE.SetItemAttrNumber(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'CITEM_VERSION_NBR'
                                 ,avalue   => l_version_number);

      WF_ENGINE.SetItemAttrNumber(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'CITEM_OBJECT_VERSION_NUMBER'
                                 ,avalue   => px_object_version_number);

      OPEN c_citem_name(p_citem_ver_id);
      FETCH c_citem_name INTO l_citem_name;
      IF c_citem_name%FOUND AND l_citem_name IS NOT NULL THEN
        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'CONTENT_ITEM_NAME'
                                 ,avalue   => l_citem_name);
      END IF;
      CLOSE c_citem_name;

      IF p_notes_to_approver IS NOT NULL THEN
        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'NOTES_TO_APPROVER'
                                 ,avalue   => p_notes_to_approver);
      END IF;

      IF p_priority IS NOT NULL THEN
        WF_ENGINE.SetItemAttrNumber(itemtype => l_ItemType
                                   ,itemkey  => l_Itemkey
                                   ,aname    => 'PRIORITY'
                                   ,avalue   => p_priority);
      END IF;

      IF p_callback_url IS NOT NULL THEN
        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'UNTOUCHED_CALLBACK_URL'
                                 ,avalue   => p_callback_url);

        -- Replace Info on Callback URL
        l_format_callback_url := p_callback_url;
        l_format_callback_url := REPLACE(l_format_callback_url
                                        ,FND_GLOBAL.Local_Chr(38) || 'CITEM_VERSION_ID'
                                        ,p_citem_ver_id);
        l_format_callback_url := REPLACE(l_format_callback_url
                                        ,FND_GLOBAL.Local_Chr(38) || 'OBJECT_VERSION_NUMBER'
                                        ,px_object_version_number);
        l_format_callback_url := REPLACE(l_format_callback_url
                                        ,FND_GLOBAL.Local_Chr(38) || 'CONTENT_ITEM_LANGUAGE'
                                        ,p_language);
        l_format_callback_url := REPLACE(l_format_callback_url
                                        ,FND_GLOBAL.Local_Chr(38) || 'ITEM_TYPE'
                                        ,l_ItemType);
        l_format_callback_url := REPLACE(l_format_callback_url
                                        ,FND_GLOBAL.Local_Chr(38) || 'ITEM_KEY'
                                        ,l_ItemKey);

        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'ORIGINAL_CALLBACK_URL'
                                 ,avalue   => l_format_callback_url);

        l_format_callback_url := REPLACE(l_format_callback_url
                                        ,FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE'
                                        ,IBC_UTILITIES_PUB.G_STV_SUBMIT_FOR_APPROVAL);

        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'CALLBACK_URL'
                                 ,avalue   => l_format_callback_url);

        l_callback_url_description := NVL(p_callback_url_description, l_format_callback_url);
        WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                                 ,itemkey  => l_Itemkey
                                 ,aname    => 'CALLBACK_URL_DESCRIPTION'
                                 ,avalue   => l_callback_url_description);
      END IF;

      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'CITEM_LANGUAGE'
                               ,avalue   => p_language);

      -- Set the language description
      IBC_UTILITIES_PVT.Get_Language_Description(p_language_code        => p_language
                                                ,p_language_description => l_language_description
                                                );
  --DBMS_OUTPUT.put_line('l_language_description =' || l_language_description);
      WF_ENGINE.SetItemAttrText(itemtype => l_ItemType
                               ,itemkey  => l_Itemkey
                               ,aname    => 'CITEM_LANGUAGE_DESCRIPTION'
                               ,avalue   => l_language_description);


      -- Start WF Process
      WF_ENGINE.StartProcess (ItemType => l_ItemType
                             ,ItemKey  => l_ItemKey);

      -- If everything is okay so far then set x_wf_item_key
      x_wf_item_key := l_ItemKey;

    END IF; -- End If of Conditionally invoking the WF

    -- COMMIT?
    IF (p_commit = FND_API.g_true) THEN
        COMMIT;
    END IF;

    -- Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME        => L_API_NAME
          ,P_PKG_NAME        => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE    => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE         => SQLCODE
          ,P_SQLERRM         => SQLERRM
          ,X_MSG_COUNT       => X_MSG_COUNT
          ,X_MSG_DATA        => X_MSG_DATA
          ,X_RETURN_STATUS   => X_RETURN_STATUS
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                               ,p_data  => x_msg_data
                               );
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME
        ,P_PKG_NAME        => G_PKG_NAME
        ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
        ,P_PACKAGE_TYPE    => IBC_UTILITIES_PVT.G_PVT
        ,P_SQLCODE         => SQLCODE
        ,P_SQLERRM         => SQLERRM
        ,X_MSG_COUNT       => X_MSG_COUNT
        ,X_MSG_DATA        => X_MSG_DATA
        ,X_RETURN_STATUS   => X_RETURN_STATUS
        );
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count
                               ,p_data  => x_msg_data
                               );
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
         P_API_NAME        => L_API_NAME
        ,P_PKG_NAME        => G_PKG_NAME
        ,P_EXCEPTION_LEVEL => IBC_UTILITIES_PVT.G_EXC_OTHERS
        ,P_PACKAGE_TYPE    => IBC_UTILITIES_PVT.G_PVT
        ,P_SQLCODE         => SQLCODE
        ,P_SQLERRM         => SQLERRM
        ,X_MSG_COUNT       => X_MSG_COUNT
        ,X_MSG_DATA        => X_MSG_DATA
        ,X_RETURN_STATUS   => X_RETURN_STATUS
   );
  END Submit_For_Trans_Approval;



  -- --------------------------------------------------------------------
  -- PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Process_TA_Response
  -- DESCRIPTION: Procedure to be called from WF to process the response
  --              for translation approval(TA) notification request.
  --              It focuses more on REJECTED response to set callback
  --              URL
  --              (Standard WF API)
  -- --------------------------------------------------------------------
  PROCEDURE Process_TA_Response(itemtype IN VARCHAR2
                               ,itemkey  IN VARCHAR2
                               ,actid    IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,result   IN OUT NOCOPY VARCHAR2
                               ) IS
    l_callback_url           VARCHAR2(240);
    l_citem_ver_id           NUMBER;
    l_language               VARCHAR2(4);
    l_return_status          VARCHAR2(30);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_object_version_number  NUMBER;
    l_response_code          VARCHAR2(30);
    l_error_msg_stack        VARCHAR2(10000);
    l_comments               VARCHAR2(10000);
  BEGIN
    result := '';
    IF funcmode IN ('RUN') THEN
      -- commented to fix 5255155
      /*
      l_callback_url  := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'ORIGINAL_CALLBACK_URL'
                                                  );
      */

      l_response_code := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                  ,itemkey  => itemkey
                                                  ,aname    => 'RESULT'
                                                  );
      IF l_response_code = 'N'
      THEN
        l_citem_ver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                     ,itemkey  => itemkey
                                                     ,aname    => 'CITEM_VER_ID'
                                                     );

        l_object_version_number := IBC_CITEM_ADMIN_GRP.getObjVerNum(getCitemId(l_citem_ver_id));

        l_language := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                               ,itemkey  => itemkey
                                               ,aname    => 'CITEM_LANGUAGE'
                                               );

        -- Update the Translation Approval Status
        IBC_CITEM_ADMIN_GRP.Change_Translation_Status(
          p_citem_ver_id           => l_citem_ver_id
         ,p_new_status             => IBC_UTILITIES_PUB.G_STV_REJECTED
         ,p_language               => l_language
         ,p_commit                 => FND_API.g_true
         ,p_init_msg_list          => FND_API.g_true
         ,px_object_version_number => l_object_version_number
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
         );


        IF l_callback_url IS NOT NULL THEN
          l_callback_url := REPLACE(l_callback_url
                                   ,FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE'
                                   ,IBC_UTILITIES_PUB.G_STV_REJECTED
                                   );

          WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                   ,itemkey  => itemkey
                                   ,aname    => 'CALLBACK_URL'
                                   ,avalue   => l_callback_url
                                   );

        END IF;

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          -- Audit Log Action
          l_comments := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                 ,itemkey  => itemkey
                                                 ,aname    => 'NOTES_TO_SUBMITTER'
                                                 );
          -- Logging
          IBC_AUDIT_LOG_GRP.log_action(
             p_activity             => Ibc_Utilities_Pvt.G_ALA_REJECT
            ,p_object_type          => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
            ,p_object_value1        => l_citem_ver_id
            ,p_object_value2        => l_language
            ,p_parent_value         => getCitemId(l_citem_ver_id)
            ,p_message_application  => 'IBC'
            ,p_message_name         => 'IBC_TRANS_LOG_MSG'
            ,p_extra_info1_type     => IBC_AUDIT_LOG_GRP.G_EI_CONSTANT
            ,p_extra_info1_value    => l_comments
            ,p_extra_info2_type     => IBC_AUDIT_LOG_GRP.G_EI_LOOKUP
            ,p_extra_info2_ref_type => 'IBC_CITEM_VERSION_STATUS'
            ,p_extra_info2_value    => IBC_UTILITIES_PUB.G_STV_REJECTED
            --,p_commit            => FND_API.g_true
            ,p_init_msg_list        => FND_API.g_true
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data
          );


        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IBC_UTILITIES_PVT.Get_Messages(p_message_count => l_msg_count
                                        ,x_msgs          => l_error_msg_stack
                                        );

          l_error_msg_stack := FND_GLOBAL.Newline()||'CITEM_VER_ID:'
                                                   ||l_citem_ver_id
                                                   ||'     -  Object Version Number:'
                                                   ||l_object_version_number
                                                   ||FND_GLOBAL.NewLine()
                                                   ||l_error_msg_stack;

         WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                   ,itemkey  => itemkey
                                   ,aname    => 'ERROR_MESSAGE_STACK'
                                   ,avalue   => l_error_msg_stack
                                   );

        END IF;

      END IF;
    END IF;
  -- Exception Handler Added for NOCOPY
  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END Process_TA_Response;


  -- --------------------------------------------------------------------
  -- PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Approve_Translation
  -- DESCRIPTION: Procedure to be called from WF to actually perform the
  --              translation approval process thru status change API.
  --              If it's approved succesfully then 'COMPLETE:Y' will be
  --              returned and callback URL updated, otherwise
  --              'COMPLETE:N' will be returned along with error
  --              stack assigned to 'ERROR_MESSAGE_STACK' WF Attribute.
  --              (Standard WF API)
  -- --------------------------------------------------------------------
  PROCEDURE Approve_Translation(itemtype IN VARCHAR2
                               ,itemkey  IN VARCHAR2
                               ,actid    IN NUMBER
                               ,funcmode IN VARCHAR2
                               ,result   IN OUT NOCOPY VARCHAR2
                               ) IS

    l_callback_url           VARCHAR2(240);
    l_citem_ver_id           NUMBER;
    l_object_version_number  NUMBER;
    l_language               VARCHAR2(4);
    l_return_status          VARCHAR2(30);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);
    l_error_msg_stack        VARCHAR2(10000);

  BEGIN
    result := '';
    IF funcmode = 'RUN' THEN
      result := 'COMPLETE:Y';
      l_citem_ver_id := WF_ENGINE.GetItemAttrNumber(itemtype => itemtype
                                                   ,itemkey  => itemkey
                                                   ,aname    => 'CITEM_VER_ID'
                                                   );

      l_object_version_number := IBC_CITEM_ADMIN_GRP.getObjVerNum(getCitemId(l_citem_ver_id));

      l_language := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                             ,itemkey  => itemkey
                                             ,aname    => 'CITEM_LANGUAGE'
                                             );

      IF l_citem_ver_id IS NOT NULL THEN
        -- Update the Translation Approval Status
        IBC_CITEM_ADMIN_GRP.Change_Translation_Status(
          p_citem_ver_id           => l_citem_ver_id
         ,p_new_status             => IBC_UTILITIES_PUB.G_STV_APPROVED
         ,p_language               => l_language
         ,p_commit                 => FND_API.g_true
         ,p_init_msg_list          => FND_API.g_true
         ,px_object_version_number => l_object_version_number
         ,x_return_status          => l_return_status
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
        );


        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
          WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                   ,itemkey  => itemkey
                                   ,aname    => 'APPROVER_NAME'
                                   ,avalue   => get_user_description(FND_GLOBAL.user_id)
                                   );

          l_callback_url := WF_ENGINE.GetItemAttrText(itemtype => itemtype
                                                     ,itemkey  => itemkey
                                                     ,aname    => 'ORIGINAL_CALLBACK_URL'
                                                     );

          IF l_callback_url IS NOT NULL THEN
            l_callback_url := REPLACE(l_callback_url
                                     ,FND_GLOBAL.Local_Chr(38) || 'ACTION_MODE'
                                     ,IBC_UTILITIES_PUB.G_STV_APPROVED
                                     );

            WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                       ,itemkey  => itemkey
                                       ,aname    => 'CALLBACK_URL'
                                       ,avalue   => l_callback_url
                                       );

          END IF;

          -- Audit Log Action
          IBC_AUDIT_LOG_GRP.log_action(
             p_activity             => Ibc_Utilities_Pvt.G_ALA_APPROVE
            ,p_object_type          => IBC_AUDIT_LOG_GRP.G_CITEM_VERSION
            ,p_object_value1        => l_citem_ver_id
            ,p_object_value2        => l_language
            ,p_parent_value         => getCitemId(l_citem_ver_id)
            ,p_message_application  => 'IBC'
            ,p_message_name         => 'IBC_TRANS_LOG_MSG'
            ,p_extra_info2_type     => IBC_AUDIT_LOG_GRP.G_EI_LOOKUP
            ,p_extra_info2_ref_type => 'IBC_CITEM_VERSION_STATUS'
            ,p_extra_info2_value    => IBC_UTILITIES_PUB.G_STV_APPROVED
            --,p_commit        => FND_API.g_true
            ,p_init_msg_list        => FND_API.g_true
            ,x_return_status        => l_return_status
            ,x_msg_count            => l_msg_count
            ,x_msg_data             => l_msg_data
            );

        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          -- IF l_return_status not successful then return 'N'
          result := 'COMPLETE:N';
          IBC_UTILITIES_PVT.Get_Messages(p_message_count => l_msg_count
                                        ,x_msgs          => l_error_msg_stack
                                        );

          l_error_msg_stack := FND_GLOBAL.Newline()||'CITEM_VER_ID:'
                                                   ||l_citem_ver_id
                                                   ||'     -  Object Version Number:'
                                                   ||l_object_version_number
                                                   ||FND_GLOBAL.NewLine()
                                                   || l_error_msg_stack;

          WF_ENGINE.SetItemAttrText(itemtype => itemtype
                                   ,itemkey  => itemkey
                                   ,aname    => 'ERROR_MESSAGE_STACK'
                                   ,avalue   => l_error_msg_stack
                                   );

        END IF;
      END IF;
    END IF;
    RETURN;
  EXCEPTION
    WHEN OTHERS THEN
    RAISE;
  END Approve_Translation;

  FUNCTION Is_Security_OK_For_Dir(p_directory_node_id IN NUMBER)
  RETURN BOOLEAN
  IS
    l_result BOOLEAN;
    CURSOR c_item_approvals_nonotif(p_directory_node_id NUMBER,
                                    p_user_pattern      VARCHAR2)
    IS
        select IAS.ITEM_KEY
        from WF_LOOKUPS L_AT, WF_LOOKUPS L_AS, WF_ACTIVITIES_VL A, WF_PROCESS_ACTIVITIES PA,
        WF_ITEM_TYPES_VL IT, WF_ITEMS I, WF_ITEM_ACTIVITY_STATUSES IAS,
        ibc_citem_versions_b civb,
        ibc_content_items citem
        WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
          and IAS.ITEM_KEY = I.ITEM_KEY
          and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
          and I.ITEM_TYPE = IT.NAME
          and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
          and PA.ACTIVITY_NAME = A.NAME
          and PA.ACTIVITY_ITEM_TYPE = A.ITEM_TYPE
          and L_AT.LOOKUP_TYPE = 'WFENG_ACTIVITY_TYPE'
          and L_AT.LOOKUP_CODE = A.TYPE
          and L_AS.LOOKUP_TYPE = 'WFENG_STATUS'
          and L_AS.LOOKUP_CODE = IAS.ACTIVITY_STATUS
        AND A.NAME = 'IBC_CITEM_APPROVE_NOTIFICATION'
        AND SUBSTR(IAS.ITEM_KEY ,1 ,INSTR(IAS.ITEM_KEY,'@') - 1) = civb.citem_version_id
        AND civb.content_item_id = citem.content_item_id
        AND directory_node_id = p_directory_node_id AND
        IAS.ITEM_TYPE = 'IBC_WF'
        AND IAS.ACTIVITY_STATUS = 'NOTIFIED'
        GROUP BY IAS.ITEM_KEY
        MINUS
        select IAS.ITEM_KEY
        from WF_LOOKUPS L_AT, WF_LOOKUPS L_AS, WF_ACTIVITIES_VL A, WF_PROCESS_ACTIVITIES PA,
        WF_ITEM_TYPES_VL IT, WF_ITEMS I, WF_ITEM_ACTIVITY_STATUSES IAS, WF_USER_ROLES U,
        ibc_citem_versions_b civb,
        ibc_content_items citem
        WHERE IAS.ITEM_TYPE = I.ITEM_TYPE
          and IAS.ITEM_KEY = I.ITEM_KEY
          and I.BEGIN_DATE between A.BEGIN_DATE and nvl(A.END_DATE, I.BEGIN_DATE)
          and I.ITEM_TYPE = IT.NAME
          and IAS.PROCESS_ACTIVITY = PA.INSTANCE_ID
          and PA.ACTIVITY_NAME = A.NAME
          and PA.ACTIVITY_ITEM_TYPE = A.ITEM_TYPE
          and L_AT.LOOKUP_TYPE = 'WFENG_ACTIVITY_TYPE'
          and L_AT.LOOKUP_CODE = A.TYPE
          and L_AS.LOOKUP_TYPE = 'WFENG_STATUS'
          and L_AS.LOOKUP_CODE = IAS.ACTIVITY_STATUS
        AND A.NAME = 'IBC_CITEM_APPROVE_NOTIFICATION'
        AND SUBSTR(IAS.ITEM_KEY ,1 ,INSTR(IAS.ITEM_KEY,'@') - 1) = civb.citem_version_id
        AND civb.content_item_id = citem.content_item_id
        AND directory_node_id = p_directory_node_id AND
        IAS.ITEM_TYPE = 'IBC_WF'
        AND IAS.ACTIVITY_STATUS = 'NOTIFIED'
        AND IAS.ASSIGNED_USER = U.ROLE_NAME
        AND NOT EXISTS(SELECT 'X'
                       FROM ibc_pending_approvals_v pav2
                       WHERE pav2.item_key = IAS.item_key
                       AND p_user_pattern NOT LIKE '%[' || U.user_name || ']%'
        )
        GROUP BY IAS.ITEM_KEY;

    l_item_key               VARCHAR2(80);
    l_item_approve_users     VARCHAR2(32767);
    l_citem_object_type      NUMBER := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM');
    l_directory_object_type  NUMBER := IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE');
    l_return_status          VARCHAR2(30);
    l_msg_count              NUMBER;
    l_msg_data               VARCHAR2(2000);

  BEGIN
    l_result := TRUE;

    IBC_DATA_SECURITY_PVT.get_grantee_usernames(
      p_instance_object_id   => l_citem_object_type
      ,p_instance_pk1_value  => NULL
      ,p_permission_code     => 'CITEM_APPROVE'
      ,p_container_object_id => l_directory_object_type
      ,p_container_pk1_value => p_directory_node_id
      ,x_usernames           => l_item_approve_users
      ,x_return_status       => l_return_status
      ,x_msg_count           => l_msg_count
      ,x_msg_data            => l_msg_data
     );

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

      IF l_item_approve_users IS NOT NULL THEN
        -- Preparing list of users so it can be used in Query as a pattern
        l_item_approve_users := '[' || REPLACE(l_item_approve_users, ',', '][') || ']';
      END IF;

      OPEN c_item_approvals_nonotif(p_directory_node_id,
                                    NVL(l_item_approve_users, '[]'));
      FETCH c_item_approvals_nonotif INTO l_item_key;
      IF c_item_approvals_nonotif%FOUND THEN
        l_result := FALSE;
      END IF;
    ELSE
      -- Error from get_grantee_usernames
      l_result := FALSE;
    END IF;

    RETURN l_result;
  EXCEPTION
    WHEN OTHERS THEN
      l_result := FALSE;
      RETURN l_result;
  END Is_Security_OK_For_Dir;

 -- --------------------------------------------------------------------------------
  -- PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Notify_Move
  -- DESCRIPTION: Procedure to be called from WF and a notification has to be
  --              sent to all users with the Read Item permission that the category
  --              or folder has moved to a new location.
  -- -------------------------------------------------------------------------------

 PROCEDURE Notify_Move(p_object_name IN VARCHAR2
                       ,p_content_item_id IN NUMBER
                       ,p_source_dir_node_id  IN NUMBER
                       ,p_destination_dir_node_id IN NUMBER

 )  IS
    l_return_status                VARCHAR2(30);
    l_msg_count                    NUMBER;
    l_msg_data                     VARCHAR2(2000);
    l_error_msg_stack              VARCHAR2(10000);
    l_directory_node_id            NUMBER;
    l_directory_path               VARCHAR2(4000);
    l_citem_object_type            NUMBER;
    l_directory_object_type        NUMBER;
    l_object                       VARCHAR2(30);
    l_name                         VARCHAR2(240);

    CURSOR c_citem_info(p_content_item_id NUMBER) IS
      SELECT content_item_name
        FROM ibc_citem_versions_vl civ
       WHERE civ.content_item_id = p_content_item_id;

    CURSOR c_citem_location(p_content_item_id NUMBER) IS
      SELECT dirnode.directory_path
        FROM ibc_content_items citem,
             ibc_directory_nodes_b dirnode
       WHERE citem.content_item_id = p_content_item_id
         AND citem.directory_node_id = dirnode.directory_node_id;

    CURSOR c_directory(p_directory_node_id NUMBER) IS
      SELECT dirnode.directory_path
        FROM ibc_directory_nodes_b dirnode
       WHERE directory_node_id = p_directory_node_id;

    ls_directory_path        VARCHAR2(4000);
    ld_dirctory_path         VARCHAR2(4000);
    l_subject                VARCHAR2(4000);
    l_body                   VARCHAR2(4000);
    l_citem_name             VARCHAR2(240);

    l_ItemType               VARCHAR2(30);
    l_ItemKey                VARCHAR2(80);
    l_message_name           VARCHAR2(30);
    l_notif_id               NUMBER;
    l_user_list              VARCHAR2(32000);
    l_wf_role_name           VARCHAR2(240);
    l_wf_role_display_name   VARCHAR2(80);
    l_permission_code        VARCHAR2(30);
    x_return_status          VARCHAR2(30);
    x_msg_count              VARCHAR2(30);
    x_msg_data               VARCHAR2(4096);

   l_api_name                CONSTANT VARCHAR2(30)   := 'Notify_Move';
   g_pkg_name                CONSTANT VARCHAR2(240)  := 'IBC_CITEM_WORKFLOW_PVT';

  BEGIN

    l_ItemType              := 'IBC_WF';
    l_ItemKey               := TO_CHAR(SYSDATE,'YYYYMMDD-HH24:MI:SS');
    l_message_name          := 'GEN_STDLN_MESG';

 -- A notification will be sent to all users with the Read Item permission that the content
 -- folder or category has been moved to a new location. Such a notification will not be sent
 -- if the permissions is set to the Public Level.


  IF p_content_item_id IS NOT NULL THEN
         OPEN c_citem_info(p_content_item_id);
         FETCH c_citem_info INTO l_citem_name;
         CLOSE c_citem_info;
  END IF;

  IF l_citem_name IS NULL THEN
        null;
  END IF;

  IF p_source_dir_node_id IS NOT NULL THEN
        OPEN c_directory(p_source_dir_node_id);
        FETCH  c_directory INTO   ls_directory_path;
        CLOSE c_directory;
  END IF;

  IF p_destination_dir_node_id IS NOT NULL THEN
        OPEN c_directory(p_destination_dir_node_id);
        FETCH  c_directory INTO   ld_dirctory_path;
        CLOSE c_directory;
  END IF;

 -- Get the users list
 IF p_object_name = 'IBC_CATEGORY_NODE' THEN
    l_permission_code := 'PD_VIEW';
    l_citem_object_type := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CATEGORY_NODE');
    l_directory_object_type := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CATEGORY_NODE');

 ELSE
    l_permission_code := 'CITEM_READ';
    l_citem_object_type := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM');
    l_directory_object_type := IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE');
 END IF;

      IBC_DATA_SECURITY_PVT.get_grantee_usernames(
         p_instance_object_id   => l_citem_object_type
        ,p_instance_pk1_value  => p_content_item_id
        ,p_permission_code     => l_permission_code
        ,p_container_object_id => l_directory_object_type
        ,p_container_pk1_value => p_source_dir_node_id
        ,x_usernames           => l_user_list
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
       );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_user_list IS NULL THEN
        --x_return_status := FND_API.G_RET_STS_ERROR;
        --FND_MESSAGE.Set_Name('IBC', 'IBC_NOT_APPROVER_DEFINED');
        --FND_MSG_PUB.ADD;
        --RAISE FND_API.G_EXC_ERROR;
        return;
      ELSE
        Create_Workflow_Role(p_user_list             => l_user_list
                            ,px_wf_role_name         => l_wf_role_name
                            ,px_wf_role_display_name => l_wf_role_display_name
                            );
      END IF;


 -- set the message

  IF p_object_name='IBC_CONTENT_ITEM' THEN
     l_object := 'Content Item';
     FND_MESSAGE.SET_NAME('IBC','IBC_MOVE_ITEM_BODY_MESSAGE');
     FND_MESSAGE.set_token('CITEM_NAME',l_citem_name,false);
     FND_MESSAGE.set_token('FROM_LOCATION',ls_directory_path,false);
     FND_MESSAGE.set_token('TO_LOCATION',ld_dirctory_path,false);
     l_name:=l_citem_name;
     l_body:=fnd_message.get;
  ELSIF p_object_name = 'IBC_DIRECTORY_NODE' THEN
     l_object := 'Folder';
     FND_MESSAGE.SET_NAME('IBC','IBC_MOVE_FOLDER_BODY_MESSAGE');
     FND_MESSAGE.set_token('OBJECT_NAME',l_object,false);
     FND_MESSAGE.set_token('FROM_LOCATION',ls_directory_path,false);
     FND_MESSAGE.set_token('TO_LOCATION',ld_dirctory_path,false);
     l_name:=ls_directory_path;
     l_body:=fnd_message.get;
  ELSE
     l_object := 'Category';
     FND_MESSAGE.SET_NAME('IBC','IBC_MOVE_FOLDER_BODY_MESSAGE');
     FND_MESSAGE.set_token('OBJECT_NAME',l_object,false);
     FND_MESSAGE.set_token('FROM_LOCATION',ls_directory_path,false);
     FND_MESSAGE.set_token('TO_LOCATION',ld_dirctory_path,false);
     l_name:=ls_directory_path;
     l_body:=fnd_message.get;

  END IF;

  FND_MESSAGE.SET_NAME('IBC','IBC_MOVE_SUBJECT_MESSAGE');
  FND_MESSAGE.set_token('OBJECT_TYPE',l_object,false);
  FND_MESSAGE.set_token('OBJECT_NAME',l_name,false);
  l_subject:=fnd_message.get;

        l_notif_id := Wf_Notification.Send
           (  ROLE     => l_wf_role_name
            , msg_type => l_ItemType
            , msg_name => l_message_name
           );

          Wf_Notification.SetAttrText(l_notif_id,
                       'GEN_MSG_SUBJECT',
                       l_subject);

           Wf_Notification.SetAttrText(l_notif_id,
                       'GEN_MSG_BODY',
                       l_body);

           Wf_Notification.SetAttrText(l_notif_id,
                       'GEN_MSG_SEND_TO',
                       l_wf_role_name);

           Wf_Notification.Denormalize_Notification(l_notif_id);

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME        => L_API_NAME
          ,P_PKG_NAME        => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE    => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE         => SQLCODE
          ,P_SQLERRM         => SQLERRM
          ,X_MSG_COUNT       => X_MSG_COUNT
          ,X_MSG_DATA        => X_MSG_DATA
          ,X_RETURN_STATUS   => X_RETURN_STATUS
          );
    WHEN OTHERS THEN
      RAISE;
  END Notify_Move;

  -- --------------------------------------------------------------------------------
  -- PROCEDURE: IBC_CITEM_WORKFLOW_PVT.Notify_Translator
  -- DESCRIPTION: Procedure to be called from WF and a notification has to be
  --              sent to all users with Translate permission when a change is
  --              made to the content item that has translation enabled.
  -- -------------------------------------------------------------------------------

 PROCEDURE Notify_Translator(p_content_item_id IN NUMBER)
 IS

    l_citem_object_type            NUMBER;
    l_directory_object_type        NUMBER;
    l_object                       VARCHAR2(30);
    ls_directory_path              VARCHAR2(4000);
    l_subject                      VARCHAR2(4000);
    l_body                         VARCHAR2(4000);
    l_citem_name                   VARCHAR2(240);
    l_source_dir_node_id           NUMBER;

    l_ItemType                     VARCHAR2(30);
    l_ItemKey                      VARCHAR2(80);
    l_message_name                 VARCHAR2(30);
    l_notif_id                     NUMBER;
    l_user_list                    VARCHAR2(32000);
    l_wf_role_name                 VARCHAR2(240);
    l_wf_role_display_name         VARCHAR2(80);
    l_permission_code              VARCHAR2(30);
    x_return_status                VARCHAR2(30);
    x_msg_count                    VARCHAR2(30);
    x_msg_data                     VARCHAR2(4096);
    l_appr_user_list               VARCHAR2(32000);


   l_api_name                CONSTANT VARCHAR2(30)   := 'Notify_Translator';
   g_pkg_name                CONSTANT VARCHAR2(240)  := 'IBC_CITEM_WORKFLOW_PVT';

    CURSOR c_citem_info(p_content_item_id NUMBER) IS
      SELECT content_item_name
        FROM ibc_citem_versions_vl civ
       WHERE civ.content_item_id = p_content_item_id;

    CURSOR c_citem_location(p_content_item_id NUMBER) IS
      SELECT dirnode.directory_path, dirnode.directory_node_id
        FROM ibc_content_items citem,
             ibc_directory_nodes_b dirnode
       WHERE citem.content_item_id = p_content_item_id
         AND citem.directory_node_id = dirnode.directory_node_id;


  BEGIN

    l_ItemType              := 'IBC_WF';
    l_ItemKey               := TO_CHAR(SYSDATE,'YYYYMMDD-HH24:MI:SS');
    l_message_name          := 'GEN_STDLN_MESG';

 -- A notification will be sent to all users with the Read Item permission that the content
 -- folder or category has been moved to a new location. Such a notification will not be sent
 -- if the permissions is set to the Public Level.


  IF p_content_item_id IS NOT NULL THEN
         OPEN c_citem_info(p_content_item_id);
         FETCH c_citem_info INTO l_citem_name;
         CLOSE c_citem_info;

         OPEN c_citem_location(p_content_item_id);
         FETCH  c_citem_location INTO   ls_directory_path, l_source_dir_node_id ;
         CLOSE c_citem_location;

  END IF;

  IF l_citem_name IS NULL THEN
        NULL;
  END IF;

l_permission_code := 'CITEM_TRANSLATE';
l_citem_object_type := IBC_DATA_SECURITY_PVT.get_object_id('IBC_CONTENT_ITEM');
l_directory_object_type := IBC_DATA_SECURITY_PVT.get_object_id('IBC_DIRECTORY_NODE');
l_object := 'Content Item';

 -- Get the users list with CITEM_TRANSLATE permission

      IBC_DATA_SECURITY_PVT.get_grantee_usernames(
         p_instance_object_id   => l_citem_object_type
        ,p_instance_pk1_value  => p_content_item_id
        ,p_permission_code     => l_permission_code
        ,p_container_object_id => l_directory_object_type
        ,p_container_pk1_value => l_source_dir_node_id
        ,x_usernames           => l_user_list
        ,x_return_status       => x_return_status
        ,x_msg_count           => x_msg_count
        ,x_msg_data            => x_msg_data
       );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_user_list IS NULL THEN
        RETURN;
      ELSE
        Create_Workflow_Role(p_user_list             => l_user_list
                            ,px_wf_role_name         => l_wf_role_name
                            ,px_wf_role_display_name => l_wf_role_display_name
                            );
      END IF;


 -- set the message

     FND_MESSAGE.SET_NAME('IBC','IBC_TRANSLATE_BODY_MESSAGE');
     FND_MESSAGE.set_token('CITEM_NAME',l_citem_name,FALSE);
     FND_MESSAGE.set_token('FROM_LOCATION',ls_directory_path,FALSE);

     l_body:=fnd_message.get;


     FND_MESSAGE.SET_NAME('IBC','IBC_TRANSLATE_SUBJECT_MESSAGE');
     FND_MESSAGE.set_token('OBJECT_TYPE',l_object,FALSE);
     FND_MESSAGE.set_token('OBJECT_NAME',l_citem_name,FALSE);
     l_subject:=fnd_message.get;

        l_notif_id := Wf_Notification.Send
           (  ROLE     => l_wf_role_name
            , msg_type => l_ItemType
            , msg_name => l_message_name
           );

          Wf_Notification.SetAttrText(l_notif_id,
                       'GEN_MSG_SUBJECT',
                       l_subject);

           Wf_Notification.SetAttrText(l_notif_id,
                       'GEN_MSG_BODY',
                       l_body);

           Wf_Notification.SetAttrText(l_notif_id,
                       'GEN_MSG_SEND_TO',
                       l_wf_role_name);

           Wf_Notification.Denormalize_Notification(l_notif_id);

  EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                p_data  => x_msg_data);
      IBC_UTILITIES_PVT.HANDLE_EXCEPTIONS(
           P_API_NAME        => L_API_NAME
          ,P_PKG_NAME        => G_PKG_NAME
          ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
          ,P_PACKAGE_TYPE    => IBC_UTILITIES_PVT.G_PVT
          ,P_SQLCODE         => SQLCODE
          ,P_SQLERRM         => SQLERRM
          ,X_MSG_COUNT       => X_MSG_COUNT
          ,X_MSG_DATA        => X_MSG_DATA
          ,X_RETURN_STATUS   => X_RETURN_STATUS
          );
    WHEN OTHERS THEN
      RAISE;
  END Notify_Translator;

END IBC_CITEM_WORKFLOW_PVT;

/
