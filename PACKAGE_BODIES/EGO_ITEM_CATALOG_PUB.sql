--------------------------------------------------------
--  DDL for Package Body EGO_ITEM_CATALOG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ITEM_CATALOG_PUB" AS
/* $Header: EGOBCAGB.pls 120.7.12010000.3 2009/05/04 07:16:58 chechand ship $ */

  g_pkg_name                VARCHAR2(30) := 'EGO_ITEM_CATALOG_PUB';
  g_app_name                VARCHAR2(3)  := 'EGO';
  g_current_user_id         NUMBER       := EGO_SCTX.Get_User_Id();
  g_current_login_id        NUMBER       := FND_GLOBAL.Login_Id;
  g_plsql_err               VARCHAR2(17) := 'EGO_PLSQL_ERR';
  g_pkg_name_token          VARCHAR2(8)  := 'PKG_NAME';
  g_api_name_token          VARCHAR2(8)  := 'API_NAME';
  g_sql_err_msg_token       VARCHAR2(11) := 'SQL_ERR_MSG';



  /******************************************************************
  ** Procedure: Set_Debug_Parameters (unexposed)
  ** Purpose: Will take input as the debug parameters and check if
  ** a debug session needs to be eastablished. If yes, the it will
  ** open a debug session file and all developer messages will be
  ** logged into a debug error file. File name will be the parameter
  ** debug_file_name_<session_id>
  ********************************************************************/
  Procedure Set_Debug_Parameters(  p_debug_flag      IN VARCHAR2
               , p_output_dir      IN VARCHAR2
               , p_debug_filename    IN VARCHAR2
               )
  IS
    l_Mesg_Token_tbl  Error_Handler.Mesg_Token_Tbl_Type;
    l_token_Tbl   Error_Handler.Token_Tbl_Type;
    l_return_status   VARCHAR2(1);
    l_Debug_Flag    VARCHAR2(1) := p_debug_flag;
  BEGIN

                    IF p_debug_flag = 'Y'
                    THEN

          -- dbms_output.put_line('Debug is Yes ' );

                            IF trim(p_output_dir) IS NULL OR
                               trim(p_output_dir) = ''
                            THEN
                                -- If debug is Y then out dir must be
                                -- specified

                                Error_Handler.Add_Error_Token
                                (  p_Message_text       =>
                                   'Debug is set to Y so an output directory' ||
                                   ' must be specified. Debug will be turned' ||
                                   ' off since no directory is specified'
                                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                                , p_Token_Tbl          => l_token_tbl
                                );

                               Ego_Catalog_Group_Err_Handler.Log_Error
                               (  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_error_status => 'W'
                                , p_error_level => Error_Handler.G_BO_LEVEL
                               );
                              l_debug_flag := 'N';

        -- dbms_output.put_line('Reverting debug to N ' );

                            END IF;

                            IF trim(p_debug_filename) IS NULL OR
                               trim(p_debug_filename) = ''
                            THEN

                                Error_Handler.Add_Error_Token
                                (  p_Message_text       =>
                                   'Debug is set to Y so an output filename' ||
                                   ' must be specified. Debug will be turned' ||
                                   ' off since no filename is specified'
                                , p_Mesg_Token_Tbl     => l_mesg_token_tbl
                                , x_Mesg_Token_Tbl     => l_mesg_token_tbl
                                , p_Token_Tbl          => l_token_tbl
                                );

                               Ego_Catalog_Group_Err_Handler.Log_Error
                               (  p_Mesg_Token_Tbl => l_Mesg_Token_Tbl
                                , p_error_status => 'W'
                                , p_error_level => Error_Handler.G_BO_LEVEL
                               );
                              l_debug_flag := 'N';


        -- dbms_output.put_line('Reverting debug to N ' );

                            END IF;

                            Error_Handler.Set_Debug(l_debug_flag);

                            IF p_debug_flag = 'Y'
                            THEN
                                Error_Handler.Open_Debug_Session
                                (  p_debug_filename     => p_debug_filename
                                 , p_output_dir         => p_output_dir
                                 , x_return_status      => l_return_status
                                 , p_mesg_token_tbl     => l_mesg_token_tbl
                                 , x_mesg_token_tbl     => l_mesg_token_tbl
                                 );

                                IF l_return_status <> FND_API.G_RET_STS_SUCCESS
                                THEN
                                    Error_Handler.Set_Debug('N');
                                END IF;
                            END IF;
                    END IF;

  END Set_Debug_Parameters;


  /***************************************************************************
  ** Procedure  : Process_Catalog_Groups
  ** Purpose  : This is the exposed procedure which most applications will
  **      call to create the catalog group hierarchy.
  **
  ** Return : error status
  **      error message count
  ****************************************************************************/
  Procedure Process_Catalog_Groups
  (  p_bo_identifier           IN  VARCHAR2 := 'ICG'
   , p_api_version_number      IN  NUMBER := 1.0
   , p_init_msg_list           IN  BOOLEAN := FALSE
   , p_catalog_group_tbl       IN  Ego_Item_Catalog_Pub.Catalog_Group_Tbl_Type
   , p_user_id         IN  NUMBER
   , p_language_code       IN  VARCHAR2 := 'US'
   , x_catalog_group_tbl       OUT NOCOPY Ego_Item_Catalog_Pub.Catalog_Group_Tbl_Type
   , x_return_status           OUT NOCOPY VARCHAR2
   , x_msg_count               OUT NOCOPY NUMBER
   , p_debug                   IN  VARCHAR2 := 'N'
   , p_output_dir              IN  VARCHAR2 := NULL
   , p_debug_filename          IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
   ) IS
    l_return_status   VARCHAR2(1);
    l_other_message   VARCHAR2(30);
    l_other_token_tbl Error_Handler.Token_Tbl_Type;
    l_token_tbl   Error_Handler.Token_Tbl_Type;
  BEGIN
    --
    -- store a global reference to the table so that other processes do not need to be
    -- passed the whole table.
    --
    -- dbms_output.put_line('In record count: ' || p_catalog_group_tbl.COUNT);

    EGO_Globals.G_Catalog_Group_Tbl := p_catalog_group_tbl;
    EGO_Globals.Set_User_Id(p_user_id);
    EGO_Globals.Set_Language_Code(p_language_code);

    -- Initialize the Flex column holder
    --
                -- Update the flex field global reference
                --

                FOR i in 1..20
                LOOP
                    EGO_Item_Catalog_Pub.G_KF_Segment_Values(i) := null;
                END LOOP;

    EGO_Globals.G_Catalog_Group_Rec := null;

                --
                -- Set Business Object Idenfier in the System Information
                -- record.
                --
                Error_Handler.Set_Bo_Identifier
                            (p_bo_identifier    =>  p_bo_identifier);

                --
                -- Initialize the message list if the user has set the
                -- Init Message List parameter
                --
                IF p_init_msg_list
                THEN
                        Error_Handler.Initialize;
                END IF;

    Set_Debug_Parameters(  p_debug_flag => p_debug
                   , p_output_dir => p_output_dir
                   , p_debug_filename => p_debug_filename
             );

    if(Error_Handler.Get_Debug = 'Y')
    then
    Error_Handler.write_debug('Within business object public api ...');
    -- dbms_output.put_line('Within business object public api ...');
    end if;

    --
    -- Call the Private API for performing further business
    -- rules validation
    --
    EGO_Item_Catalog_Pvt.Process_Catalog_Groups
    (   x_return_status          => l_return_status
    ,   x_msg_count              => x_msg_count
    );

    -- dbms_output.put_line('Returned from private API ...');

          IF l_return_status <> 'S'
    THEN
    -- Call Error Handler
      -- dbms_output.put_line('Calling log error ...');
            Ego_Catalog_Group_Err_Handler.Log_Error
                (  p_error_status   => l_return_status
                 , p_error_scope  => Error_Handler.G_SCOPE_ALL
                 , p_error_level  => Error_Handler.G_BO_LEVEL
                 --, p_other_message  => 'EGO_ERROR_BUSINESS_OBJECT'
                 --, p_other_status   => l_return_status
                );
      -- dbms_output.put_line('Called log error ...');
    END IF;

    x_return_status := l_return_status;
          x_msg_count := Error_Handler.Get_Message_Count;

    Error_Handler.write_debug('Return status is ...'||x_return_status);

    IF Error_Handler.Get_Debug = 'Y'
          THEN
                  Error_Handler.Close_Debug_Session;
          END IF;

    -- return back the table from the global reference.

    x_catalog_group_tbl := EGO_Globals.G_Catalog_Group_Tbl;

      EXCEPTION
        WHEN EGO_Globals.G_EXC_SEV_QUIT_OBJECT THEN

        -- Call Error Handler

          Ego_Catalog_Group_Err_Handler.Log_Error
    ( p_error_status  => Error_Handler.G_STATUS_ERROR
    , p_error_scope   => Error_Handler.G_SCOPE_ALL
    , p_error_level   => Error_Handler.G_BO_LEVEL
                , p_other_message => l_other_message
                , p_other_status  => Error_Handler.G_STATUS_ERROR
    );

          x_return_status := Error_Handler.G_STATUS_ERROR;
          x_msg_count := Error_Handler.Get_Message_Count;
                IF Error_Handler.Get_Debug = 'Y'
                THEN
                        Error_Handler.Close_Debug_Session;
                END IF;

        WHEN EGO_Globals.G_EXC_UNEXP_SKIP_OBJECT THEN

        -- Call Error Handler

          Ego_Catalog_Group_Err_Handler.Log_Error
                ( p_error_status => Error_Handler.G_STATUS_UNEXPECTED
                , p_error_level => Error_Handler.G_BO_LEVEL
                , p_other_status => Error_Handler.G_STATUS_NOT_PICKED
                , p_other_message => l_other_message
                , p_other_token_tbl => l_token_tbl
                );

          x_return_status := Error_Handler.G_STATUS_UNEXPECTED;
          x_msg_count := Error_Handler.Get_Message_Count;
                IF Error_Handler.Get_Debug = 'Y'
                THEN
                        Error_Handler.Close_Debug_Session;
                END IF;


END Process_Catalog_Groups;


/* Process_Catalog_Group
** Convenience method that can be called once for every catalog group in the catalog group
** hierarchy
*/
Procedure Process_Catalog_Group
(  p_Catalog_Group_Name            IN  VARCHAR2         := NULL
 , p_Parent_Catalog_Group_Name     IN  VARCHAR2         := NULL
 , p_Catalog_Group_Id              IN  NUMBER           := NULL
 , p_Parent_Catalog_Group_Id       IN  NUMBER           := NULL
 , p_Description                   IN  VARCHAR2         := NULL
 , p_Item_Creation_Allowed_Flag    IN  VARCHAR2         := NULL
 , p_Start_Effective_Date          IN  DATE             := NULL
 , p_Inactive_date                 IN  DATE             := NULL
 , p_Enabled_Flag                  IN  VARCHAR2         := NULL
 , p_Summary_Flag                  IN  VARCHAR2         := NULL
 , p_segment1                      IN  VARCHAR2         := NULL
 , p_segment2                      IN  VARCHAR2         := NULL
 , p_segment3                      IN  VARCHAR2         := NULL
 , p_segment4                      IN  VARCHAR2         := NULL
 , p_segment5                      IN  VARCHAR2         := NULL
 , p_segment6                      IN  VARCHAR2         := NULL
 , p_segment7                      IN  VARCHAR2         := NULL
 , p_segment8                      IN  VARCHAR2         := NULL
 , p_segment9                      IN  VARCHAR2         := NULL
 , p_segment10                     IN  VARCHAR2         := NULL
 , p_segment11                     IN  VARCHAR2         := NULL
 , p_segment12                     IN  VARCHAR2         := NULL
 , p_segment13                     IN  VARCHAR2         := NULL
 , p_segment14                     IN  VARCHAR2         := NULL
 , p_segment15                     IN  VARCHAR2         := NULL
 , p_segment16                     IN  VARCHAR2         := NULL
 , p_segment17                     IN  VARCHAR2         := NULL
 , p_segment18                     IN  VARCHAR2         := NULL
 , p_segment19                     IN  VARCHAR2         := NULL
 , p_segment20                     IN  VARCHAR2         := NULL
 , Attribute_category              IN  VARCHAR2         := NULL
 , Attribute1                      IN  VARCHAR2         := NULL
 , Attribute2                      IN  VARCHAR2         := NULL
 , Attribute3                      IN  VARCHAR2         := NULL
 , Attribute4                      IN  VARCHAR2         := NULL
 , Attribute5                      IN  VARCHAR2         := NULL
 , Attribute6                      IN  VARCHAR2         := NULL
 , Attribute7                      IN  VARCHAR2         := NULL
 , Attribute8                      IN  VARCHAR2         := NULL
 , Attribute9                      IN  VARCHAR2         := NULL
 , Attribute10                     IN  VARCHAR2         := NULL
 , Attribute11                     IN  VARCHAR2         := NULL
 , Attribute12                     IN  VARCHAR2         := NULL
 , Attribute13                     IN  VARCHAR2         := NULL
 , Attribute14                     IN  VARCHAR2         := NULL
 , Attribute15                     IN  VARCHAR2         := NULL
 , p_User_id                       IN  NUMBER
 , p_Language_Code                 IN  VARCHAR2         := 'US'
 , p_Transaction_Type              IN  VARCHAR2
 , x_Return_Status                 OUT NOCOPY VARCHAR2
 , x_msg_count                     OUT NOCOPY NUMBER
 , p_debug                         IN  VARCHAR2 := 'N'
 , p_output_dir                    IN  VARCHAR2 := NULL
 , p_debug_filename                IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 , x_catalog_group_id              OUT NOCOPY NUMBER
 , x_catalog_group_name            OUT NOCOPY VARCHAR2
) IS
  l_catalog_group_tbl EGO_Item_Catalog_Pub.Catalog_Group_Tbl_Type;
  x_catalog_group_tbl EGO_Item_Catalog_Pub.Catalog_Group_Tbl_Type;
BEGIN
  EGO_Globals.G_Catalog_Group_Rec.catalog_group_name := p_catalog_group_name;
  EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_name := p_parent_catalog_group_name;
  EGO_Globals.G_Catalog_Group_Rec.catalog_group_id := p_catalog_group_id;
  EGO_Globals.G_Catalog_Group_Rec.parent_catalog_group_id := p_parent_catalog_group_id;
  EGO_Globals.G_Catalog_Group_Rec.segment1 := p_segment1;
  EGO_Globals.G_Catalog_Group_Rec.segment2 := p_segment2;
  EGO_Globals.G_Catalog_Group_Rec.segment3 := p_segment3;
  EGO_Globals.G_Catalog_Group_Rec.segment4 := p_segment4;
  EGO_Globals.G_Catalog_Group_Rec.segment5 := p_segment5;
  EGO_Globals.G_Catalog_Group_Rec.segment6 := p_segment6;
  EGO_Globals.G_Catalog_Group_Rec.segment7 := p_segment7;
  EGO_Globals.G_Catalog_Group_Rec.segment8 := p_segment8;
  EGO_Globals.G_Catalog_Group_Rec.segment9 := p_segment9;
  EGO_Globals.G_Catalog_Group_Rec.segment10 := p_segment10;
  EGO_Globals.G_Catalog_Group_Rec.segment11 := p_segment11;
  EGO_Globals.G_Catalog_Group_Rec.segment12 := p_segment12;
  EGO_Globals.G_Catalog_Group_Rec.segment13 := p_segment13;
  EGO_Globals.G_Catalog_Group_Rec.segment14 := p_segment14;
  EGO_Globals.G_Catalog_Group_Rec.segment15 := p_segment15;
  EGO_Globals.G_Catalog_Group_Rec.segment16 := p_segment16;
  EGO_Globals.G_Catalog_Group_Rec.segment17 := p_segment17;
  EGO_Globals.G_Catalog_Group_Rec.segment18 := p_segment18;
  EGO_Globals.G_Catalog_Group_Rec.segment19 := p_segment19;
  EGO_Globals.G_Catalog_Group_Rec.segment20 := p_segment20;
  EGO_Globals.G_Catalog_Group_Rec.summary_flag  := p_summary_flag;
  EGO_Globals.G_Catalog_Group_Rec.enabled_flag  := p_enabled_flag;
  EGO_Globals.G_Catalog_Group_Rec.inactive_date := p_inactive_date;
  EGO_Globals.G_Catalog_Group_Rec.item_creation_allowed_flag := p_item_creation_Allowed_flag;
  EGO_Globals.G_Catalog_Group_Rec.description := p_description;
  EGO_Globals.G_Catalog_Group_Rec.Transaction_Type := p_transaction_type;

  l_catalog_group_tbl(1) := EGO_Globals.G_Catalog_Group_Rec;

  -- -- dbms_output.put_line('local table count of records before start : ' || l_catalog_group_tbl.count);

  EGO_Item_Catalog_Pub.Process_Catalog_Groups
            ( p_catalog_group_tbl => l_catalog_group_tbl
            , p_user_id   => p_user_id
            , p_Language_Code   => p_Language_Code
            , x_catalog_group_tbl => x_catalog_group_tbl
            , x_return_status   => x_return_status
            , x_msg_count   => x_msg_count
            , p_debug     => p_debug
            , p_debug_filename  => p_debug_filename
            , p_output_dir    => p_output_dir
             );

  x_catalog_group_id   := x_catalog_group_tbl(1).catalog_group_id;
  x_catalog_group_name := x_catalog_group_tbl(1).catalog_group_name;

END Process_Catalog_Group;


PROCEDURE Create_Catalog_Group
(  p_Catalog_Group_Id              IN  NUMBER     := NULL
 , p_Parent_Catalog_Group_Id       IN  NUMBER         := NULL
 , p_Description                   IN  VARCHAR2   := NULL
 , p_Item_Creation_Allowed_Flag    IN  VARCHAR2   := NULL
 , p_Start_Effective_Date      IN  DATE   := NULL
 , p_Inactive_date       IN  DATE   := NULL
 , p_Enabled_Flag                  IN  VARCHAR2   := NULL
 , p_Summary_Flag                  IN  VARCHAR2   := NULL
 , p_segment1        IN  VARCHAR2   := NULL
 , p_segment2        IN  VARCHAR2   := NULL
 , p_segment3        IN  VARCHAR2   := NULL
 , p_segment4        IN  VARCHAR2   := NULL
 , p_segment5        IN  VARCHAR2   := NULL
 , p_segment6        IN  VARCHAR2   := NULL
 , p_segment7        IN  VARCHAR2   := NULL
 , p_segment8        IN  VARCHAR2   := NULL
 , p_segment9        IN  VARCHAR2   := NULL
 , p_segment10         IN  VARCHAR2   := NULL
 , p_segment11         IN  VARCHAR2   := NULL
 , p_segment12         IN  VARCHAR2   := NULL
 , p_segment13         IN  VARCHAR2   := NULL
 , p_segment14         IN  VARCHAR2   := NULL
 , p_segment15         IN  VARCHAR2   := NULL
 , p_segment16         IN  VARCHAR2   := NULL
 , p_segment17         IN  VARCHAR2   := NULL
 , p_segment18         IN  VARCHAR2   := NULL
 , p_segment19         IN  VARCHAR2   := NULL
 , p_segment20           IN  VARCHAR2   := NULL
 , Attribute_category            IN  VARCHAR2   := NULL
 , Attribute1                    IN  VARCHAR2   := NULL
 , Attribute2                    IN  VARCHAR2   := NULL
 , Attribute3                    IN  VARCHAR2   := NULL
 , Attribute4                    IN  VARCHAR2   := NULL
 , Attribute5                    IN  VARCHAR2   := NULL
 , Attribute6                    IN  VARCHAR2   := NULL
 , Attribute7                    IN  VARCHAR2   := NULL
 , Attribute8                    IN  VARCHAR2   := NULL
 , Attribute9                    IN  VARCHAR2   := NULL
 , Attribute10                   IN  VARCHAR2   := NULL
 , Attribute11                   IN  VARCHAR2   := NULL
 , Attribute12                   IN  VARCHAR2   := NULL
 , Attribute13                   IN  VARCHAR2   := NULL
 , Attribute14                   IN  VARCHAR2   := NULL
 , Attribute15                   IN  VARCHAR2   := NULL
 , p_Template_Id                   IN  NUMBER
 , p_User_id               IN  NUMBER
 , x_return_status                 OUT NOCOPY VARCHAR2
 , x_msg_count         OUT NOCOPY NUMBER
 , x_msg_data                      OUT NOCOPY VARCHAR2
 , p_debug                       IN  VARCHAR2 := 'N'
 , p_output_dir                  IN  VARCHAR2 := NULL
 , p_debug_filename              IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 , x_catalog_group_id              OUT NOCOPY NUMBER
 , x_catalog_group_name            OUT NOCOPY VARCHAR2
)

IS
  l_entity_index             number;
  l_entity_id                varchar2(2000);
  l_message_type             varchar2(2000);
  l_message_list             varchar2(2000);

  --GET PROFILE OPTION VALUE FOR PIM FOR TELCO
  profile_value varchar2(1) := fnd_profile.value('EGO_ENABLE_P4T');
  draft_str VARCHAR2(2000);

   -- Checks for any active version of PARENT ICC passed as parameter.
  cursor icc_with_active_ver (parent_icc_id VARCHAR2)
    IS
    SELECT version_seq_id
    FROM ego_mtl_catalog_grp_vers_b
    WHERE item_catalog_group_id = parent_icc_id
    AND version_seq_id > 0
    AND start_active_date <= SYSDATE;

BEGIN

  IF  profile_value = 'Y' AND p_Parent_Catalog_Group_Id <> null THEN
       OPEN icc_with_active_ver (p_Parent_Catalog_Group_Id);
       IF icc_with_active_ver%NOTFOUND THEN
          CLOSE icc_with_active_ver;
          -- Returning false since an icc without any active version at the time of release cannot be chosen as a parent.
          x_return_status := 'F';
          RETURN;
       END IF;
  END IF;

---------------------------------------------------
  -- Insert catalog group
  EGO_Item_Catalog_Pub.Process_Catalog_Group
        ( p_Catalog_Group_Id           => p_Catalog_Group_Id
        , p_Parent_Catalog_Group_Id    => p_Parent_Catalog_Group_Id
        , p_Description                => p_Description
        , p_Item_Creation_Allowed_Flag => p_Item_Creation_Allowed_Flag
        , p_Inactive_Date              => p_Inactive_Date
        , p_segment1                   => p_segment1
        , p_segment2                   => p_segment2
        , p_segment3                   => p_segment3
        , p_segment4                   => p_segment4
        , p_segment5                   => p_segment5
        , p_segment6                   => p_segment6
        , p_segment7                   => p_segment7
        , p_segment8                   => p_segment8
        , p_segment9                   => p_segment9
        , p_segment10                  => p_segment10
        , p_segment11                  => p_segment11
        , p_segment12                  => p_segment12
        , p_segment13                  => p_segment13
        , p_segment14                  => p_segment14
        , p_segment15                  => p_segment15
        , p_segment16                  => p_segment16
        , p_segment17                  => p_segment17
        , p_segment18                  => p_segment18
        , p_segment19                  => p_segment19
        , p_segment20                  => p_segment20
        , p_user_id                    => p_user_id
        , p_Language_Code              => userenv('LANG')
        , p_Transaction_Type           => 'CREATE'
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
  , p_debug                      => p_debug
        , p_output_dir                 => p_output_dir
        , p_debug_filename             => p_debug_filename
        , x_catalog_group_id           => x_catalog_group_id
        , x_catalog_group_name         => x_catalog_group_name
       );

  -- PIM4TELCO: CHECHAND: INSERT A ROW IN VERSIONS TABLE FOR DEFAULT DRAFT VERSION.   - START
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    -- dbms_output.put_line ('PIM Telco Profile Value: '||profile_value);
    if profile_value = 'Y' then
        SELECT message_text into draft_str
        FROM fnd_new_messages
        WHERE
        application_id = (SELECT application_id
                        FROM fnd_application
                        WHERE application_short_name = 'EGO') AND
        message_name = 'EGO_ICC_DRAFT_VERSION' AND
        language_code = USERENV('LANG') ;

        -- dbms_output.put_line ('draft text: '||draft_str);

        insert into EGO_MTL_CATALOG_GRP_VERS_B
          (item_catalog_group_id,
          version_seq_id,
          version_description,
          start_active_date,
          end_active_date,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        values
          ( x_catalog_group_id,
          0,
          draft_str,
          null,
          null,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.USER_ID,
          sysdate,
          FND_GLOBAL.LOGIN_ID);
    end if;
  END IF;
  -- PIM4TELCO: CHECHAND: - END


  -- Create an association between Default Template and Catalog Group
  IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
     p_Template_Id is not null THEN

    INSERT INTO ego_cat_grp_templates
    (   template_id
      , catalog_group_id
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
    )
    VALUES
    (   p_Template_Id
      , x_catalog_group_id
      , p_user_id
      , sysdate
      , p_user_id
      , sysdate
    );

  ELSIF x_return_status <> 'S' THEN
    Error_Handler.Get_Message
    (  x_message_text    => l_message_list
     , x_entity_index   => l_entity_index
     , x_entity_id      => l_entity_id
     , x_message_type   => l_message_type
     );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      x_msg_data := 'Executing - EGO_ITEM_CATALOG_PUB.CREATE_CATALOG_GROUP '||l_message_list;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      Ego_Catalog_Group_Err_Handler.Log_Error
      (  p_error_status => x_return_status
       , p_error_scope  => Error_Handler.G_SCOPE_ALL
       , p_error_level  => Error_Handler.G_BO_LEVEL
      );

      Error_Handler.Get_Message
      (  x_message_text    => l_message_list
       , x_entity_index   => l_entity_index
       , x_entity_id      => l_entity_id
       , x_message_type   => l_message_type
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      x_msg_data := 'Executing - EGO_ITEM_CATALOG_PUB.CREATE_CATALOG_GROUP '||l_message_list;

END CREATE_CATALOG_GROUP;

---------------------------------------------------------

PROCEDURE Update_Catalog_Group
(  p_Catalog_Group_Id              IN  NUMBER     := NULL
 , p_Parent_Catalog_Group_Id       IN  NUMBER         := NULL
 , p_Description                   IN  VARCHAR2   := NULL
 , p_Item_Creation_Allowed_Flag    IN  VARCHAR2   := NULL
 , p_Start_Effective_Date      IN  DATE   := NULL
 , p_Inactive_date       IN  DATE   := NULL
 , p_Enabled_Flag                  IN  VARCHAR2   := NULL
 , p_Summary_Flag                  IN  VARCHAR2   := NULL
 , p_segment1        IN  VARCHAR2   := NULL
 , p_segment2        IN  VARCHAR2   := NULL
 , p_segment3        IN  VARCHAR2   := NULL
 , p_segment4        IN  VARCHAR2   := NULL
 , p_segment5        IN  VARCHAR2   := NULL
 , p_segment6        IN  VARCHAR2   := NULL
 , p_segment7        IN  VARCHAR2   := NULL
 , p_segment8        IN  VARCHAR2   := NULL
 , p_segment9        IN  VARCHAR2   := NULL
 , p_segment10         IN  VARCHAR2   := NULL
 , p_segment11         IN  VARCHAR2   := NULL
 , p_segment12         IN  VARCHAR2   := NULL
 , p_segment13         IN  VARCHAR2   := NULL
 , p_segment14         IN  VARCHAR2   := NULL
 , p_segment15         IN  VARCHAR2   := NULL
 , p_segment16         IN  VARCHAR2   := NULL
 , p_segment17         IN  VARCHAR2   := NULL
 , p_segment18         IN  VARCHAR2   := NULL
 , p_segment19         IN  VARCHAR2   := NULL
 , p_segment20           IN  VARCHAR2   := NULL
 , Attribute_category            IN  VARCHAR2   := NULL
 , Attribute1                    IN  VARCHAR2   := NULL
 , Attribute2                    IN  VARCHAR2   := NULL
 , Attribute3                    IN  VARCHAR2   := NULL
 , Attribute4                    IN  VARCHAR2   := NULL
 , Attribute5                    IN  VARCHAR2   := NULL
 , Attribute6                    IN  VARCHAR2   := NULL
 , Attribute7                    IN  VARCHAR2   := NULL
 , Attribute8                    IN  VARCHAR2   := NULL
 , Attribute9                    IN  VARCHAR2   := NULL
 , Attribute10                   IN  VARCHAR2   := NULL
 , Attribute11                   IN  VARCHAR2   := NULL
 , Attribute12                   IN  VARCHAR2   := NULL
 , Attribute13                   IN  VARCHAR2   := NULL
 , Attribute14                   IN  VARCHAR2   := NULL
 , Attribute15                   IN  VARCHAR2   := NULL
 , p_Template_Id                   IN  NUMBER
 , p_User_id               IN  NUMBER
 , x_Return_Status                 OUT NOCOPY VARCHAR2
 , x_msg_count         OUT NOCOPY NUMBER
 , x_msg_data                      OUT NOCOPY VARCHAR2
 , p_debug                       IN  VARCHAR2 := 'N'
 , p_output_dir                  IN  VARCHAR2 := NULL
 , p_debug_filename              IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 , x_catalog_group_id              OUT NOCOPY NUMBER
 , x_catalog_group_name            OUT NOCOPY VARCHAR2
)

IS
  l_entity_index             number;
  l_entity_id                varchar2(2000);
  l_message_type             varchar2(2000);
  l_message_list             varchar2(2000);
  v_dummy                    varchar2(1);

BEGIN

---------------------------------------------------
  -- Update catalog group
  EGO_Item_Catalog_Pub.Process_Catalog_Group
        ( p_Catalog_Group_Id           => p_Catalog_Group_Id
        , p_Parent_Catalog_Group_Id    => p_Parent_Catalog_Group_Id
        , p_Description                => p_Description
        , p_Item_Creation_Allowed_Flag => p_Item_Creation_Allowed_Flag
        , p_Inactive_Date              => p_Inactive_Date
        , p_segment1                   => p_segment1
        , p_segment2                   => p_segment2
        , p_segment3                   => p_segment3
        , p_segment4                   => p_segment4
        , p_segment5                   => p_segment5
        , p_segment6                   => p_segment6
        , p_segment7                   => p_segment7
        , p_segment8                   => p_segment8
        , p_segment9                   => p_segment9
        , p_segment10                  => p_segment10
        , p_segment11                  => p_segment11
        , p_segment12                  => p_segment12
        , p_segment13                  => p_segment13
        , p_segment14                  => p_segment14
        , p_segment15                  => p_segment15
        , p_segment16                  => p_segment16
        , p_segment17                  => p_segment17
        , p_segment18                  => p_segment18
        , p_segment19                  => p_segment19
        , p_segment20                  => p_segment20
        , p_user_id                    => p_user_id
        , p_Language_Code              => userenv('LANG')
        , p_Transaction_Type           => 'UPDATE'
        , x_return_status              => x_return_status
        , x_msg_count                  => x_msg_count
  , p_debug                      => p_debug
        , p_output_dir                 => p_output_dir
        , p_debug_filename             => p_debug_filename
        , x_catalog_group_id           => x_catalog_group_id
        , x_catalog_group_name         => x_catalog_group_name
       );

  -- Create an association between Default Template and Catalog Group
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

    -- check if catalog group is already associated with a default template
    SELECT 'x' INTO v_dummy
    FROM ego_cat_grp_templates
    WHERE catalog_group_id = x_catalog_group_id;

    IF p_Template_Id is not null THEN

      -- update current association of catalog group with default template
      UPDATE ego_cat_grp_templates
      SET template_id = p_Template_Id
      WHERE catalog_group_id = x_catalog_group_id;

    ELSE

      -- delete current association of catalog group with default template
      DELETE FROM ego_cat_grp_templates
      WHERE catalog_group_id = x_catalog_group_id;

    END IF;

  ELSIF x_return_status <> 'S' THEN
    x_msg_count := Error_Handler.Get_Message_Count();

    Error_Handler.Get_Message
    (  x_message_text   => l_message_list
     , x_entity_index   => l_entity_index
     , x_entity_id      => l_entity_id
     , x_message_type   => l_message_type
     );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      x_msg_data := 'Executing - EGO_ITEM_CATALOG_PUB.UPDATE_CATALOG_GROUP '||l_message_list;
  END IF;



  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- There is no current association of default template to catalog group
      IF p_Template_Id is not null THEN

        INSERT INTO ego_cat_grp_templates
        (   template_id
          , catalog_group_id
          , created_by
          , creation_date
          , last_updated_by
          , last_update_date
        )
        VALUES
        (   p_Template_Id
          , x_catalog_group_id
          , p_user_id
          , sysdate
          , p_user_id
          , sysdate
        );


      END IF;

    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      Ego_Catalog_Group_Err_Handler.Log_Error
      (  p_error_status   => x_return_status
       , p_error_scope  => Error_Handler.G_SCOPE_ALL
       , p_error_level  => Error_Handler.G_BO_LEVEL
      );

      Error_Handler.Get_Message
      (  x_message_text    => l_message_list
       , x_entity_index   => l_entity_index
       , x_entity_id      => l_entity_id
       , x_message_type   => l_message_type
      );

      x_msg_count := ERROR_HANDLER.Get_Message_Count();
      x_msg_data := 'Executing - EGO_ITEM_CATALOG_PUB.UPDATE_CATALOG_GROUP '||l_message_list;

END UPDATE_CATALOG_GROUP;

---------------------------------------------------------------
-- Check before deleting an attribute group assoc ----
---------------------------------------------------------------

PROCEDURE Check_Delete_AttrGroup_Assoc
(
    p_api_version                   IN      NUMBER
   ,p_association_id                IN      NUMBER
   ,p_classification_code           IN      VARCHAR2
   ,p_data_level                    IN      VARCHAR2
   ,p_attr_group_id                 IN      NUMBER
   ,p_application_id                IN      NUMBER
   ,p_attr_group_type               IN      VARCHAR2
   ,p_attr_group_name               IN      VARCHAR2
   ,p_enabled_code                  IN      VARCHAR2
   ,p_init_msg_list                 IN      VARCHAR2   := fnd_api.g_FALSE
   ,x_ok_to_delete                  OUT     NOCOPY VARCHAR2
   ,x_return_status                 OUT     NOCOPY VARCHAR2
   ,x_errorcode                     OUT     NOCOPY NUMBER
   ,x_msg_count                     OUT     NOCOPY NUMBER
   ,x_msg_data                      OUT     NOCOPY VARCHAR2
)
IS

    l_api_version           CONSTANT NUMBER           := 1.0;
    l_count                 VARCHAR2(3);
    l_api_name              CONSTANT VARCHAR2(30)     := 'Check_Delete_AttrGroup_Assoc';
    l_message               VARCHAR2(4000);
    l_classification_codes  VARCHAR2(32767);
    l_attr_group_id         VARCHAR2(40);
    l_dynamic_sql           VARCHAR2(32767);
    l_attr_display_name     VARCHAR2(250);
    l_variant_Behaviour     VARCHAR2(10);
    l_style_exists          VARCHAR2(1);

  BEGIN

    --Standard checks
    IF NOT FND_API.Compatible_API_Call (l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,g_pkg_name)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.Initialize;
    END IF;

    SELECT
      attr_group_disp_name INTO l_attr_display_name
    FROM
      ego_obj_attr_grp_assocs_v
    WHERE association_id =  p_association_id;

    --Check if there are any entries for in EGO_PAGE_ENTRIES_V

    -- Bug - 5068278 , avoided Full Table Scans
    SELECT COUNT(*) INTO l_count
      FROM EGO_PAGE_ENTRIES_B A,
                  FND_OBJECTS B ,
                  EGO_OBJ_ATTR_GRP_ASSOCS_V C
    WHERE C.ASSOCIATION_ID =  A.ASSOCIATION_ID
         AND A.ASSOCIATION_ID = p_association_id
         AND C.OBJECT_ID =  B.OBJECT_ID
         AND B.OBJ_NAME = 'EGO_ITEM' ;

    IF (l_count > 0)
    THEN
      x_ok_to_delete := FND_API.G_FALSE;
      l_message := 'EGO_ASSOCIATED_AG_IN_USE';
      FND_MESSAGE.Set_Name(g_app_name, l_message);
      FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
      FND_MSG_PUB.Add;
      x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

    -- now need to get all the classification code that has p_classification_code as its parent
    IF (l_count = 0) THEN

     l_attr_group_id := p_attr_group_id || '%';

     -- check if this ag is used to create any search criterias

      l_dynamic_sql :=  'SELECT COUNT (*) '||
                        'FROM AK_CRITERIA cols , '||
                        '     EGO_CRITERIA_TEMPLATES_V criterions '||
                        'WHERE cols.customization_code = criterions.customization_code '||
                        ' AND ( criterions.classification1 IN ( SELECT item_catalog_group_id '||
                        '              FROM mtl_item_catalog_groups_b CONNECT BY PRIOR item_catalog_group_id = '||
                        '              parent_catalog_group_id START WITH parent_catalog_group_id = :1 ) '||
                        '     OR criterions.classification1 = :2 ) '||
                        '  AND cols.attribute_code LIKE :3 '||
                        '  AND criterions.REGION_CODE LIKE ''EGO%'' '||
                        '  AND COLS.REGION_CODE = CRITERIONS.REGION_CODE ';

     EXECUTE IMMEDIATE l_dynamic_sql INTO l_count USING p_classification_code, p_classification_code, l_attr_group_id;
     IF (l_count > 0)
     THEN
       x_ok_to_delete := FND_API.G_FALSE;
       l_message := 'EGO_ASSOCIATED_AG_IN_USE';
       FND_MESSAGE.Set_Name(g_app_name, l_message);
       FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

     IF (l_count = 0) THEN
       -- check if this ag is used to create any result formats
       l_dynamic_sql := 'SELECT COUNT(*) ' ||
                        'FROM AK_CUSTOM_REGION_ITEMS COLS, ' ||
                        '     EGO_RESULTS_FORMAT_V RF ' ||
                        'WHERE cols.customization_code = RF.customization_code ' ||
                        ' AND ( RF.classification1 IN ( SELECT item_catalog_group_id '||
                        '              FROM mtl_item_catalog_groups_b CONNECT BY PRIOR item_catalog_group_id = '||
                        '              parent_catalog_group_id START WITH parent_catalog_group_id = :1 ) '||
                        '     OR RF.classification1 = :2 ) '||
                        '  AND cols.attribute_code LIKE :3 '||
                        '  AND RF.REGION_CODE LIKE ''EGO%'' ' ||
                        '  AND COLS.REGION_CODE = RF.REGION_CODE ';

       EXECUTE IMMEDIATE l_dynamic_sql INTO l_count USING p_classification_code, p_classification_code, l_attr_group_id;
       IF (l_count > 0)
       THEN
         x_ok_to_delete := FND_API.G_FALSE;
         l_message := 'EGO_ASSOCIATED_AG_IN_USE';
         FND_MESSAGE.Set_Name(g_app_name, l_message);
         FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
         FND_MSG_PUB.Add;
         x_return_status := FND_API.G_RET_STS_ERROR;
       END IF;
     END IF; --if no search criteria exist
   END IF; -- no page entry exist

   -- In Case the Attribute Group is Variant in Behavior it can not be deleted if
   -- there exists any style or SKU item for this ICC
   BEGIN
     SELECT VARIANT INTO l_variant_Behaviour
     FROM EGO_FND_DSC_FLX_CTX_EXT
     WHERE ATTR_GROUP_ID = p_attr_group_id;
   EXCEPTION
     WHEN OTHERS THEN
       l_variant_Behaviour := 'N';
   END;

   IF l_variant_Behaviour = 'Y' THEN
     -- Style Exists check is enough for SKU Exists check,
     -- Since SKU cannot exists with out a Style
     l_style_exists := EGO_STYLE_SKU_ITEM_PVT.IsStyle_Item_Exist_For_ICC( p_classification_code );
     IF l_style_exists = FND_API.G_TRUE THEN
       x_ok_to_delete := FND_API.G_FALSE;
       l_message := 'EGO_ASSOCIATED_AG_IN_USE';
       FND_MESSAGE.Set_Name(g_app_name, l_message);
       FND_MESSAGE.Set_Token('ATTR_GROUP_NAME', l_attr_display_name);
       FND_MSG_PUB.Add;
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;


    FND_MSG_PUB.Count_And_Get(
        p_encoded        => FND_API.G_FALSE,
        p_count          => x_msg_count,
        p_data           => x_msg_data
    );

    IF (l_message IS NULL) THEN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_ok_to_delete := FND_API.G_TRUE;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_ok_to_delete := FND_API.G_FALSE;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MESSAGE.Set_Name(g_app_name, g_plsql_err);
      FND_MESSAGE.Set_Token(g_pkg_name_token, g_pkg_name);
      FND_MESSAGE.Set_Token(g_api_name_token, l_api_name);
      FND_MESSAGE.Set_Token(g_sql_err_msg_token, SQLERRM);
      FND_MSG_PUB.Add;

END Check_Delete_AttrGroup_Assoc;
---------------------------------------------------------------
-- Check before deleting an attribute group assoc ----
---------------------------------------------------------------

PROCEDURE LOCK_ROW (
  p_item_catalog_group_id          IN       NUMBER,
  p_parent_catalog_group_id        IN       NUMBER,
  p_item_creation_allowed_flag     IN       VARCHAR2,
  p_inactive_date                  IN       DATE,
  p_segment1                       IN       VARCHAR2,
  p_segment2                       IN       VARCHAR2,
  p_segment3                       IN       VARCHAR2,
  p_segment4                       IN       VARCHAR2,
  p_segment5                       IN       VARCHAR2,
  p_segment6                       IN       VARCHAR2,
  p_segment7                       IN       VARCHAR2,
  p_segment8                       IN       VARCHAR2,
  p_segment9                       IN       VARCHAR2,
  p_segment10                      IN       VARCHAR2,
  p_segment11                      IN       VARCHAR2,
  p_segment12                      IN       VARCHAR2,
  p_segment13                      IN       VARCHAR2,
  p_segment14                      IN       VARCHAR2,
  p_segment15                      IN       VARCHAR2,
  p_segment16                      IN       VARCHAR2,
  p_segment17                      IN       VARCHAR2,
  p_segment18                      IN       VARCHAR2,
  p_segment19                      IN       VARCHAR2,
  p_segment20                      IN       VARCHAR2,
  p_description                    IN       VARCHAR2
) is
  cursor c is select
      PARENT_CATALOG_GROUP_ID,
      ITEM_CREATION_ALLOWED_FLAG,
      INACTIVE_DATE,
      SUMMARY_FLAG,
      ENABLED_FLAG,
      START_DATE_ACTIVE,
      END_DATE_ACTIVE,
      SEGMENT1,
      SEGMENT2,
      SEGMENT3,
      SEGMENT4,
      SEGMENT5,
      SEGMENT6,
      SEGMENT7,
      SEGMENT8,
      SEGMENT9,
      SEGMENT10,
      SEGMENT11,
      SEGMENT12,
      SEGMENT13,
      SEGMENT14,
      SEGMENT15,
      SEGMENT16,
      SEGMENT17,
      SEGMENT18,
      SEGMENT19,
      SEGMENT20,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      REQUEST_ID
    from MTL_ITEM_CATALOG_GROUPS_B
    where ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id
    for update of ITEM_CATALOG_GROUP_ID nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from MTL_ITEM_CATALOG_GROUPS_TL
    where ITEM_CATALOG_GROUP_ID = p_item_catalog_group_id
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of ITEM_CATALOG_GROUP_ID nowait;


BEGIN


  OPEN c;
  FETCH c into recinfo;
  IF (c%notfound) THEN
    CLOSE c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  END IF;
  CLOSE c;

  IF (    ((recinfo.PARENT_CATALOG_GROUP_ID = p_parent_catalog_group_id)
           OR ((recinfo.PARENT_CATALOG_GROUP_ID is null) AND (p_parent_catalog_group_id is null)))
      AND (recinfo.ITEM_CREATION_ALLOWED_FLAG = p_item_creation_allowed_flag)
      AND ((recinfo.INACTIVE_DATE = p_inactive_date)
           OR ((recinfo.INACTIVE_DATE is null) AND (p_inactive_date is null)))
      AND ((recinfo.SEGMENT1 = p_segment1)
           or ((recinfo.SEGMENT1 is null) AND (p_segment1 is null)))
      AND ((recinfo.SEGMENT2 = p_segment2)
           or ((recinfo.SEGMENT2 is null) AND (p_segment2 is null)))
      AND ((recinfo.SEGMENT3 = p_segment3)
           or ((recinfo.SEGMENT3 is null) AND (p_segment3 is null)))
      AND ((recinfo.SEGMENT4 = p_segment4)
           or ((recinfo.SEGMENT4 is null) AND (p_segment4 is null)))
      AND ((recinfo.SEGMENT5 = p_segment5)
           or ((recinfo.SEGMENT5 is null) AND (p_segment5 is null)))
      AND ((recinfo.SEGMENT6 = p_segment6)
           or ((recinfo.SEGMENT6 is null) AND (p_segment6 is null)))
      AND ((recinfo.SEGMENT7 = p_segment7)
           or ((recinfo.SEGMENT7 is null) AND (p_segment7 is null)))
      AND ((recinfo.SEGMENT8 = p_segment8)
           or ((recinfo.SEGMENT8 is null) AND (p_segment8 is null)))
      AND ((recinfo.SEGMENT9 = p_segment9)
           or ((recinfo.SEGMENT9 is null) AND (p_segment9 is null)))
      AND ((recinfo.SEGMENT10 = p_segment10)
           or ((recinfo.SEGMENT10 is null) AND (p_segment10 is null)))
      AND ((recinfo.SEGMENT11 = p_segment11)
           or ((recinfo.SEGMENT11 is null) AND (p_segment11 is null)))
      AND ((recinfo.SEGMENT12 = p_segment12)
           or ((recinfo.SEGMENT12 is null) AND (p_segment12 is null)))
      AND ((recinfo.SEGMENT13 = p_segment13)
           or ((recinfo.SEGMENT13 is null) AND (p_segment13 is null)))
      AND ((recinfo.SEGMENT14 = p_segment14)
           or ((recinfo.SEGMENT14 is null) AND (p_segment14 is null)))
      AND ((recinfo.SEGMENT15 = p_segment15)
           or ((recinfo.SEGMENT15 is null) AND (p_segment15 is null)))
      AND ((recinfo.SEGMENT16 = p_segment16)
           or ((recinfo.SEGMENT16 is null) AND (p_segment16 is null)))
      AND ((recinfo.SEGMENT17 = p_segment17)
           or ((recinfo.SEGMENT17 is null) AND (p_segment17 is null)))
      AND ((recinfo.SEGMENT18 = p_segment18)
           or ((recinfo.SEGMENT18 is null) AND (p_segment18 is null)))
      AND ((recinfo.SEGMENT19 = p_segment19)
           or ((recinfo.SEGMENT19 is null) AND (p_segment19 is null)))
      AND ((recinfo.SEGMENT20 = p_segment20)
           or ((recinfo.SEGMENT20 is null) AND (p_segment20 is null)))
  ) THEN
    null;
  ELSE
    --failed to lock row b/c data has changed since last fetch
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;


  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.DESCRIPTION = p_description)
               or ((tlinfo.DESCRIPTION is null) AND (p_description is null)))
      ) then
        null;
      else
        --failed to lock row b/c data has changed since last fetch
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;

  return;
end LOCK_ROW;






END EGO_ITEM_CATALOG_PUB;

/
