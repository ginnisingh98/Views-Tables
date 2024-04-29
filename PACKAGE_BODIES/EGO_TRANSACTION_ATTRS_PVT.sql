--------------------------------------------------------
--  DDL for Package Body EGO_TRANSACTION_ATTRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_TRANSACTION_ATTRS_PVT" AS
/* $Header: EGOVITAB.pls 120.0.12010000.15 2010/06/15 11:59:53 kjonnala ship $ */
   ---------------------------------------------------------------
   -- Global Variables and Constants --
   ---------------------------------------------------------------
   G_PKG_NAME           CONSTANT VARCHAR2(30)   := 'EGO_TRANSACTION_ATTRS_PVT';
   G_APP_NAME           CONSTANT  VARCHAR2(3)   := 'EGO';

   G_CHAR_DATA_TYPE           CONSTANT VARCHAR2(1) := 'C';
   G_TL_DATA_TYPE             CONSTANT VARCHAR2(1) := 'A';
   G_NUMBER_DATA_TYPE         CONSTANT VARCHAR2(1) := 'N';
   G_DATE_DATA_TYPE           CONSTANT VARCHAR2(1) := 'X';
   G_DATE_TIME_DATA_TYPE      CONSTANT VARCHAR2(1) := 'Y';

   G_CURRENT_USER_ID          NUMBER := FND_GLOBAL.User_Id;
   G_CURRENT_LOGIN_ID         NUMBER := FND_GLOBAL.Login_Id;
   G_APPLICATION_ID           NUMBER := 431;

   G_MISS_CHAR                CONSTANT VARCHAR2(1) := FND_API.G_MISS_CHAR;
   G_MISS_NUM                 CONSTANT NUMBER      := FND_API.G_MISS_NUM;

   ---------------------------------------------------------------
   -- API Return statuses.                                      --
   ---------------------------------------------------------------
   G_STATUS_SUCCESS    CONSTANT VARCHAR2(1)    := 'S';
   G_STATUS_ERROR      CONSTANT VARCHAR2(1)    := 'E';

/* Create transaction attribute API*/
PROCEDURE Create_Transaction_Attribute (
           p_api_version      IN         NUMBER,
           p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2)
IS
  /* User Defined Exception object*/
   e_ta_int_name_exist     EXCEPTION;
   e_ta_disp_name_exist    EXCEPTION;
   e_ta_sequence_exist     EXCEPTION;
   e_ta_default_value_null EXCEPTION;
   e_ag_create             EXCEPTION;
   e_ta_create             EXCEPTION;
   e_ta_association        EXCEPTION;
   e_vs_data_type          EXCEPTION;
   e_vs_not_versioned      EXCEPTION;
   e_ta_int_name_invalidchars  EXCEPTION;

  /* Declaring local parameters*/

   l_attr_desc           VARCHAR2(100);  --confirm about size
   l_count               NUMBER:=0;
   l_ag_seq_value        NUMBER;
   l_ag_int_name         VARCHAR2(100);   --confirm about size
   l_ag_disp_name        VARCHAR2(100);   --confirm about size
   l_ag_desc             VARCHAR2(100);    --confirm about size
   l_ag_type             VARCHAR2(30) := 'EGO_ITEM_TRANS_ATTR_GROUP';
   l_attr_group_id       NUMBER;
   l_column              VARCHAR2(30):=NULL;

   l_return_status       VARCHAR2(1);
   l_errorcode           NUMBER;
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);


   l_association_id      NUMBER;
   l_attr_id             NUMBER:=0;
   l_attr_sequence       EGO_ATTRS_V.SEQUENCE%TYPE;
   l_value_set_id        NUMBER;
   l_uom_class           VARCHAR2(10);
   l_default_value       VARCHAR2(2000);
   l_rejectedvalue           VARCHAR2(2000);
   l_required            VARCHAR2(1);
   l_readonlyflag            VARCHAR2(1);
   l_hiddenflag                VARCHAR2(1);
   l_searchable          VARCHAR2(1);
   l_checkeligibility    VARCHAR2(1);
   l_inventoryitemid       NUMBER;
   l_organizationid          NUMBER;
   l_metadatalevel         VARCHAR2(10);
   l_programapplicationid NUMBER;
   l_programid           NUMBER;
   l_programupdatedate   DATE;
   l_requestid           NUMBER;
   l_item_cat_group_id   EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE;
   l_attr_name           EGO_ATTRS_V.ATTR_NAME%TYPE:=NULL;
   l_attr_disp_name      EGO_ATTRS_V.ATTR_DISPLAY_NAME%TYPE:=NULL;
   l_data_type           VARCHAR2(1);
   l_display             VARCHAR2(1);

   l_api_name            CONSTANT VARCHAR2(30) := 'Create_Transaction_Attribute';
   l_data_level_id       NUMBER;
   l_icc_version_number  NUMBER;
   l_revision_id         NUMBER;
   l_item_obj_id         NUMBER;
   l_versioned_value_set NUMBER:=0;
   l_has_invalid_chars  VARCHAR2(1);
    l_is_column_indexed  VARCHAR2(80);

BEGIN
    --Reset all global variables
    FND_MSG_PUB.Initialize;
    FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last
    LOOP

      l_item_cat_group_id := p_tran_attrs_tbl(i).ItemCatalogGroupId;
      l_attr_name         := p_tran_attrs_tbl(i).AttrName;
      l_attr_disp_name    := p_tran_attrs_tbl(i).AttrDisplayName;
      l_attr_sequence     := p_tran_attrs_tbl(i).SEQUENCE;

      --l_association_id    := p_tran_attrs_tbl(i).associationid;
      --l_attr_id           := p_tran_attrs_tbl(i).attrid;
      l_value_set_id      := p_tran_attrs_tbl(i).valuesetid;
      l_uom_class         := p_tran_attrs_tbl(i).uomclass;
      l_default_value     := p_tran_attrs_tbl(i).defaultvalue;
      l_rejectedvalue     := p_tran_attrs_tbl(i).rejectedvalue;
      l_required          := p_tran_attrs_tbl(i).requiredflag;
      l_readonlyflag      := p_tran_attrs_tbl(i).readonlyflag;
      l_hiddenflag        := p_tran_attrs_tbl(i).hiddenflag;
      l_searchable        := p_tran_attrs_tbl(i).searchableflag;
      l_checkeligibility  := p_tran_attrs_tbl(i).checkeligibility;
      l_inventoryitemid   := p_tran_attrs_tbl(i).inventoryitemid;
      l_organizationid    := p_tran_attrs_tbl(i).organizationid;
      l_metadatalevel     := p_tran_attrs_tbl(i).metadatalevel;
      l_programapplicationid := p_tran_attrs_tbl(i).programapplicationid;
      l_programid         := p_tran_attrs_tbl(i).programid;
      l_programupdatedate := p_tran_attrs_tbl(i).programupdatedate;
      l_requestid         := p_tran_attrs_tbl(i).requestid;

      l_icc_version_number:= p_tran_attrs_tbl(i).icc_version_number;
      l_revision_id       := p_tran_attrs_tbl(i).revision_id;

      l_data_type         := p_tran_attrs_tbl(i).datatype;
      l_display           := p_tran_attrs_tbl(i).displayas;


      /* Check  if att_int_name already exist*/
      IF (    Check_TA_IS_INVALID (p_item_cat_group_id  => l_item_cat_group_id,
                                 p_attr_id            => l_attr_id,
                                 p_attr_name          => l_attr_name) ) THEN
          RAISE  e_ta_int_name_exist;
      END IF;
    /*check whether the internal has some specail characters*/
    has_invalid_char(p_internal_name   => l_attr_name,
                        x_has_invalid_chars => l_has_invalid_chars);
      IF(  l_has_invalid_chars ='Y') THEN
          RAISE e_ta_int_name_invalidchars;
      END IF ;

      /* Check  if att_disp_name already exist*/
      IF (    Check_TA_IS_INVALID (p_item_cat_group_id  => l_item_cat_group_id,
                                 p_attr_id            => l_attr_id,
                                 p_attr_disp_name     => l_attr_disp_name) ) THEN

          RAISE  e_ta_disp_name_exist;
      END IF;

      /*
      IF (Check_Ta_Disp_Name_Exist(l_item_cat_group_id,l_attr_id,l_attr_disp_name)) THEN
          RAISE  e_ta_disp_name_exist;
      END IF;*/

      /* Check  if sequence already exist*/

      IF (    Check_TA_IS_INVALID (p_item_cat_group_id  => l_item_cat_group_id,
                                 p_attr_id            => l_attr_id,
                                 p_attr_sequence      => l_attr_sequence) ) THEN
          RAISE  e_ta_sequence_exist;
      END IF;
      /*
      IF (Check_Ta_Sequence_Exist(l_item_cat_group_id,l_attr_id,l_attr_sequence)) THEN
          RAISE  e_ta_sequence_exist;
      END IF;*/

      /* Check  for default value of a TA */
      IF ( l_readonlyflag='Y'  AND l_required ='Y' AND l_default_value IS NULL) THEN
          RAISE  e_ta_default_value_null;
      END IF;

      -------------------------------------------------------------------------------------
      -- Make sure that if a Value Set was passed in, is a versioned value set --
      -------------------------------------------------------------------------------------
      IF (l_value_set_id IS NOT NULL) THEN

        SELECT Count(*) CNT
          INTO l_versioned_value_set
          FROM EGO_FLEX_VALUESET_VERSION_B
         WHERE FLEX_VALUE_SET_ID = l_value_set_id
           AND VERSION_SEQ_ID>0;

        IF (l_versioned_value_set=0)  THEN
          RAISE e_vs_not_versioned;
        END IF;
        --------------------------------------------------------------------------

        IF (NOT Check_VS_Data_Type(l_value_set_id,l_data_type) ) THEN
          RAISE e_vs_data_type;
        END IF;

      END IF;

      BEGIN
          SELECT EGO_TRANS_AG_S.NEXTVAL INTO l_ag_seq_value FROM dual;
      EXCEPTION
          WHEN OTHERS THEN
             x_return_status   :=  G_STATUS_ERROR;
             x_msg_data       :=  'TA_SEQUENCE_NOT_EXIST';
             FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
             FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
             FND_MESSAGE.Set_Token('API_NAME', l_api_name);
             FND_MESSAGE.Set_Token('SQL_ERR_MSG',x_msg_data );
             FND_MSG_PUB.Add;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                      ,p_count   => x_msg_count
                                      ,p_data    => x_msg_data);
      END;

      l_ag_int_name       := 'EGO_TRANS_AG_'||l_ag_seq_value;
      l_ag_disp_name      := l_ag_int_name;
      l_ag_desc           := l_ag_int_name;


      /* Create a attribute group to keep sync with existing framework*/
      EGO_EXT_FWK_PUB.Create_Attribute_Group
               ( p_api_version             => 1.0,
                 p_application_id          => G_APPLICATION_ID ,
                 p_attr_group_type         => l_ag_type,
                 p_internal_name           => l_ag_int_name,
                 p_display_name            => l_ag_disp_name ,
                 p_attr_group_desc         => l_ag_desc ,
                 p_security_type           => NULL ,
                 p_multi_row_attrib_group  => 'N' ,
                 p_variant_attrib_group    => 'N' ,
                 p_num_of_cols             => NULL,
                 p_num_of_rows             => NULL,
                 p_owning_company_id       => NULL,
                 p_view_privilege_id       => NULL,
                 p_edit_privilege_id       => NULL,
                 p_business_event_flag     => 'N',
                 p_pre_business_event_flag => 'N',
                 p_init_msg_list           => NULL,
                 p_commit                  => NULL,
                 x_attr_group_id           => l_attr_group_id,
                 x_return_status           => l_return_status,
                 x_errorcode               => l_errorcode,
                 x_msg_count               => l_msg_count,
                 x_msg_data                => x_msg_data);

      IF (l_return_status<> G_STATUS_SUCCESS) THEN
          RAISE e_ag_create;
      END IF;

      /* Get data level id */
      BEGIN
        SELECT max(data_level_id)  INTO l_data_level_id
        FROM ego_data_level_b
        WHERE application_id = G_APPLICATION_ID;
      EXCEPTION
        WHEN No_Data_Found THEN
            x_return_status   :=  G_STATUS_ERROR;
            x_msg_data       :=  'TA_NO_DATA_LEVEL_FOUND';
            FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
            FND_MESSAGE.Set_Token('SQL_ERR_MSG',x_msg_data );
            FND_MSG_PUB.Add;
            FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                     ,p_count   => x_msg_count
                                     ,p_data    => x_msg_data);
      END ;

      /* INSERT record into ego_attr_group_dl*/
      INSERT INTO ego_attr_group_dl
          (attr_group_id
          ,data_level_id
          ,defaulting
          ,view_privilege_id
          ,edit_privilege_id
          ,raise_pre_event
          ,raise_post_event
          ,created_by
          ,creation_date
          ,last_updated_by
          ,last_update_date
          ,last_update_login)
      VALUES(l_attr_group_id,l_data_level_id,
                                null,null,null,'N','N',G_CURRENT_USER_ID,SYSDATE,G_CURRENT_USER_ID,SYSDATE,G_CURRENT_LOGIN_ID);

      /* Find out column name based on data type */
      IF ( l_data_type = G_NUMBER_DATA_TYPE )
      THEN
          l_column      := 'N_EXT_ATTR';
      ELSIF (l_data_type = G_DATE_DATA_TYPE OR l_data_type = G_DATE_TIME_DATA_TYPE )
      THEN
          l_column      := 'D_EXT_ATTR';
      ELSIF (l_data_type = G_TL_DATA_TYPE )
      THEN
          l_column      := 'TL_EXT_ATTR';
      ELSE
          l_column      := 'C_EXT_ATTR' ;
      END IF;
     SELECT MEANING
          INTO l_is_column_indexed
          FROM FND_LOOKUP_VALUES
         WHERE LOOKUP_TYPE = 'YES_NO'
           AND LANGUAGE = USERENV('LANG')
           AND VIEW_APPLICATION_ID = 0
           AND LOOKUP_CODE = 'Y';

      /* Call below API to create transaction atribute*/
      EGO_EXT_FWK_PUB.Create_Attribute
                (  p_api_version       => 1.0
                  ,p_application_id    => G_APPLICATION_ID
                  ,p_attr_group_type   => l_ag_type
                  ,p_attr_group_name   => l_ag_int_name
                  ,p_internal_name     => l_attr_name
                  ,p_display_name      => l_attr_disp_name
                  ,p_description       => l_attr_desc
                  ,p_sequence          => l_attr_sequence
                  ,p_data_type         => l_data_type
                  ,p_required          => l_required
                  ,p_searchable        => l_searchable
                  ,p_column            => l_column
                  ,p_is_column_indexed => l_is_column_indexed --'No'   --- ToDo
                  ,p_value_set_id      => l_value_set_id
                  ,p_info_1            => null
                  ,p_default_value     => l_default_value
                  ,p_unique_key_flag   => null
                  ,p_enabled           => 'Y'
                  ,p_display           => l_display
                  ,p_uom_class         => l_uom_class
                  ,p_init_msg_list     => null
                  ,p_commit            => null
                  ,x_return_status     => l_return_status
                  ,x_errorcode         => l_errorcode
                  ,x_msg_count         => l_msg_count
                  ,x_msg_data          => x_msg_data
        );

       IF (l_return_status<>G_STATUS_SUCCESS) THEN
          RAISE e_ta_create;
       END IF;
       BEGIN
          SELECT object_id INTO l_item_obj_id FROM fnd_objects WHERE obj_name = 'EGO_ITEM';
       EXCEPTION
          WHEN No_Data_Found THEN
             x_return_status   :=  G_STATUS_ERROR;
             x_msg_data       :=  'TA_NO_OBJECT_ID';
             FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
             FND_MESSAGE.Set_Token('SQL_ERR_MSG',x_msg_data );
             FND_MSG_PUB.Add;
             FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                      ,p_count   => x_msg_count
                                      ,p_data    => x_msg_data);
       END;
       EGO_EXT_FWK_PUB.Create_Association(
                p_api_version         =>     1.0 ,
                p_object_id           =>     l_item_obj_id,
                p_classification_code =>     l_item_cat_group_id ,
                p_data_level          =>     'ITEM_REVISION_LEVEL',
                p_application_id      =>     G_APPLICATION_ID ,
                p_attr_group_type     =>     l_ag_type ,
                p_attr_group_name     =>     l_ag_int_name ,
                p_enabled_flag        =>     'Y' ,
                p_view_privilege_id   =>     0 ,
                p_edit_privilege_id   =>     0 ,
                x_association_id      =>     l_association_id ,
                x_return_status       =>     l_return_status,
                x_errorcode           =>     l_errorcode,
                x_msg_count           =>     l_msg_count,
                x_msg_data            =>     x_msg_data);



          SELECT ASSOCIATION_ID INTO l_association_id
            FROM EGO_OBJ_AG_ASSOCS_B
              WHERE CLASSIFICATION_CODE= l_item_cat_group_id
                AND ATTR_GROUP_ID=  l_attr_group_id
                AND OBJECT_ID= l_item_obj_id;

       IF (l_return_status<>G_STATUS_SUCCESS) THEN
          RAISE e_ta_association;
       END IF;

        SELECT attr_id INTO l_attr_id
        FROM EGO_FND_DF_COL_USGS_EXT
        WHERE APPLICATION_ID = G_APPLICATION_ID
       AND DESCRIPTIVE_FLEXFIELD_NAME = l_ag_type
       AND DESCRIPTIVE_FLEX_CONTEXT_CODE = l_ag_int_name
       AND APPLICATION_COLUMN_NAME = l_column;


       /* INSERTING values in tables*/
       BEGIN

       INSERT INTO EGO_TRANS_ATTR_VERS_B
             (association_id,attr_id,icc_version_number,attr_display_name,"SEQUENCE",value_set_id,uom_class,
              default_value,rejected_value,required_flag,readonly_flag,hidden_flag, searchable_flag,
              check_eligibility,inventory_item_id,organization_id, revision_id,metadata_level,created_by,
              creation_date,last_updated_by,last_update_date,last_update_login,program_application_id,
              program_id,program_update_date,request_id,item_catalog_group_id)
       VALUES(l_association_id,l_attr_id,l_icc_version_number,l_attr_disp_name,
              l_attr_sequence,l_value_set_id,l_uom_class,l_default_value,l_rejectedvalue,l_required,l_readonlyflag,
              l_hiddenflag,l_searchable,l_checkeligibility,l_inventoryitemid,l_organizationid,l_revision_id,
              l_metadatalevel,G_CURRENT_USER_ID,SYSDATE,G_CURRENT_USER_ID,SYSDATE,G_CURRENT_LOGIN_ID,
              l_programapplicationid,l_programid,l_programupdatedate,l_requestid,l_item_cat_group_id);
       EXCEPTION
          WHEN OTHERS  THEN
              x_return_status   :=  G_STATUS_ERROR;
              x_msg_data       :=  'TA_INSERT_FAILED';
              FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
              FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
              FND_MESSAGE.Set_Token('API_NAME', l_api_name);
              FND_MESSAGE.Set_Token('SQL_ERR_MSG',SQLERRM);
              FND_MSG_PUB.Add;
              FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                       ,p_count   => x_msg_count
                                       ,p_data    => x_msg_data);
       END ;
    END LOOP; /* FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last  */
    IF (Nvl(x_return_status,G_STATUS_SUCCESS) <>G_STATUS_ERROR )
    THEN
        x_return_status := G_STATUS_SUCCESS;
    END IF;
EXCEPTION
    WHEN e_ta_int_name_exist THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_INTERNAL_NAME_UNIQUE');
      /*SELECT * FROM fnd_new_messages WHERE message_name LIKE 'EGO_PLSQL_ERR%'*/
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_ta_disp_name_exist THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_TA_DISPLAY_NAME_UNIQUE');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_ta_sequence_exist THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_DUP_SEQ_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_ta_default_value_null
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_TA_DEFAULT_VALUE_NULL');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_vs_not_versioned
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_VALUE_SET_NOT_VERSIONED');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_vs_data_type
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_VS_DT_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN e_ag_create
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_TA_AG_CREATE');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_ta_create
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_TA_CREATE_FAILED');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_ta_association
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_TA_ASSOC_FAILED');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
     WHEN e_ta_int_name_invalidchars
     THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_INTERNAL_NAME_TIP');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

    WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END Create_Transaction_Attribute;






--=================Check_TA_IS_INVALID===============--------
FUNCTION Check_TA_IS_INVALID (
        p_item_cat_group_id  IN NUMBER,
        p_attr_id            IN NUMBER,
        p_attr_name          IN VARCHAR2,
        p_attr_disp_name     IN VARCHAR2,
        p_attr_sequence      IN NUMBER
)
RETURN BOOLEAN
  IS

  l_attr_id NUMBER;
  l_attr_name VARCHAR2(80);
  l_attr_disp_name VARCHAR2(80);
  l_attr_sequence NUMBER;
  l_ta_is_invalid BOOLEAN := FALSE;
  --p_attr_id NUMBER :=2972 ; --parameter to test API
  --p_item_cat_group_id NUMBER:=609 ; --parameter to test API

/**------Query to fetch all associated attribute with passed in ICC--------**/
CURSOR cur_list
IS
        SELECT item_catalog_group_id,
               icc_version_NUMBER   ,
               SEQUENCE             ,
               attr_display_name    ,
               attr_name            ,
               attr_id              ,
               lev
        FROM
               (SELECT versions.item_catalog_group_id,
                      versions.icc_version_NUMBER    ,
                      versions.SEQUENCE              ,
                      attrs.attr_display_name        ,
                      attrs.attr_name                ,
                      attrs.attr_id                  ,
                      hier.lev
               FROM   ego_obj_AG_assocs_b assocs      ,
                      ego_attrs_v attrs               ,
                      ego_attr_groups_v ag            ,
                      EGO_TRANS_ATTR_VERS_B versions  ,
                      mtl_item_catalog_groups_kfv icv ,
                      (SELECT item_catalog_group_id   ,
                             LEVEL lev
                      FROM   mtl_item_catalog_groups_b START
                      WITH item_catalog_group_id = p_item_cat_group_id CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                      ) hier
        WHERE  ag.attr_group_type                      = 'EGO_ITEM_TRANS_ATTR_GROUP'
           AND assocs.attr_group_id                    = ag.attr_group_id
           AND assocs.classification_code              = TO_CHAR(hier.item_catalog_group_id)
           AND attrs.attr_group_name                   = ag.attr_group_name
           AND TO_CHAR(icv.item_catalog_group_id)      = assocs.classification_code
           AND TO_CHAR(versions.association_id)        = assocs.association_id
           AND TO_CHAR(versions.item_catalog_group_id) = assocs.classification_code
           AND attrs.attr_id                           = versions.attr_id
               )
        WHERE
               (
                      (
                             LEV                = 1
                         AND ICC_VERSION_NUMBER = 0
                      )
                   OR
                      (
                             LEV <> 1
                         AND
                             (
                                    item_catalog_group_id, ICC_VERSION_NUMBER
                             )
                             IN
                             (SELECT item_catalog_group_id,
                                    VERSION_SEQ_ID
                             FROM   EGO_MTL_CATALOG_GRP_VERS_B
                             WHERE  start_active_date <=
                                    (SELECT NVL(start_active_date,SYSDATE)
                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                       AND VERSION_SEQ_ID        = 0
                                    )
                                AND NVL(end_active_date, sysdate) >=
                                    (SELECT NVL(start_active_date,SYSDATE)
                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                       AND VERSION_SEQ_ID        = 0
                                    )
                                AND version_seq_id > 0
                             )
                      )
               ); --end CURSOR cur_list


/**------Query to fetch overridden values for a transaction attribute------**/
CURSOR cur_metadata
IS
        SELECT *
        FROM
               (SELECT *
               FROM
                      (SELECT versions.item_catalog_group_id,
                             versions.ICC_VERSION_NUMBER    ,
                             versions.ATTR_ID               ,
                             versions.SEQUENCE              ,
                             versions.attr_display_name     ,
                             versions.metadata_level        ,
                             attrs.attr_name                ,
                             Hier.lev
                      FROM   EGO_TRANS_ATTR_VERS_B VERSIONS,
                             EGO_ATTRS_V ATTRS             ,
                             (SELECT ITEM_CATALOG_GROUP_ID ,
                                    LEVEL LEV
                             FROM   MTL_ITEM_CATALOG_GROUPS_B START
                             WITH ITEM_CATALOG_GROUP_ID = p_item_cat_group_id CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
                             ) HIER
               WHERE  HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id
                  AND attrs.attr_id              = versions.attr_id
                  AND attrs.attr_group_type      ='EGO_ITEM_TRANS_ATTR_GROUP'
                  AND versions.metadata_level    ='ICC'
                      )
               WHERE
                      (
                             (
                                    LEV                = 1
                                AND ICC_VERSION_number = 0
                             )
                          OR
                             (
                                    LEV <> 1
                                AND
                                    (
                                           item_catalog_group_id, ICC_VERSION_NUMBER
                                    )
                                    IN
                                    (SELECT item_catalog_group_id,
                                           VERSION_SEQ_ID
                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                    WHERE
                                           (
                                                  item_catalog_group_id,start_active_date
                                           )
                                           IN
                                           (SELECT  item_catalog_group_id,
                                                    MAX(start_active_date) start_active_date
                                           FROM     EGO_MTL_CATALOG_GRP_VERS_B
                                           WHERE    NVL(end_active_date, sysdate) >=
                                                    (SELECT NVL(start_active_date,SYSDATE)
                                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                       AND VERSION_SEQ_ID        = 0
                                                    )
                                                AND version_seq_id > 0

                                                AND  start_active_date <=
                                                    (SELECT NVL(start_active_date,SYSDATE)
                                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                       AND VERSION_SEQ_ID        = 0
                                                    )



                                           GROUP BY item_catalog_group_id
                                           HAVING   MAX(start_active_date)<=
                                                    (SELECT NVL(start_active_date,SYSDATE)
                                                    FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                    WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                       AND VERSION_SEQ_ID        = 0
                                                    )
                                           )
                                    )
                             )
                      )
               )
        WHERE
               (
                      lev,attr_id
               )
               IN
               (SELECT  MIN(lev),
                        attr_id
               FROM
                        (SELECT versions.item_catalog_group_id,
                               versions.ICC_VERSION_NUMBER    ,
                               versions.ATTR_ID               ,
                               versions.SEQUENCE              ,
                               versions.attr_display_name     ,
                               versions.metadata_level        ,
                               Hier.lev
                        FROM   EGO_TRANS_ATTR_VERS_B VERSIONS,
                               (SELECT ITEM_CATALOG_GROUP_ID ,
                                      LEVEL LEV
                               FROM   MTL_ITEM_CATALOG_GROUPS_B
                                START  WITH ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
                               ) HIER
                        WHERE  HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id
                           AND versions.metadata_level    ='ICC'
                           AND versions.attr_display_name IS NOT NULL
                        )
               WHERE
                        (
                                 (
                                          LEV                =1
                                      AND ICC_VERSION_number = 0
                                 )
                              OR
                                 (
                                          LEV <> 1
                                      AND
                                          (
                                                   item_catalog_group_id, ICC_VERSION_NUMBER
                                          )
                                          IN
                                          (SELECT item_catalog_group_id,
                                                 VERSION_SEQ_ID
                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                          WHERE
                                                 (
                                                        item_catalog_group_id,start_active_date
                                                 )
                                                 IN
                                                 (SELECT  item_catalog_group_id,
                                                          MAX(start_active_date) start_active_date
                                                 FROM     EGO_MTL_CATALOG_GRP_VERS_B
                                                 WHERE    NVL(end_active_date, sysdate) >=
                                                          (SELECT NVL(start_active_date,SYSDATE)
                                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                          WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                             AND VERSION_SEQ_ID        = 0
                                                          )
                                                      AND version_seq_id > 0


                                                      AND  start_active_date <=
                                                      (SELECT NVL(start_active_date,SYSDATE)
                                                      FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                      WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                        AND VERSION_SEQ_ID        = 0
                                                      )




                                                 GROUP BY item_catalog_group_id
                                                 HAVING   MAX(start_active_date)<=
                                                          (SELECT NVL(start_active_date,SYSDATE)
                                                          FROM   EGO_MTL_CATALOG_GRP_VERS_B
                                                          WHERE  ITEM_CATALOG_GROUP_ID = p_item_cat_group_id
                                                             AND VERSION_SEQ_ID        = 0
                                                          )
                                                 )
                                          )
                                 )
                             --AND metadata_level ='ICC'
                        )
               GROUP BY attr_id
               )
           AND attr_id=l_attr_id
           AND attr_id<>p_attr_id; --end cur_metadata
BEGIN

        FOR i IN cur_list
        LOOP
                l_attr_id := i.attr_id;
                FOR j IN cur_metadata
                LOOP
                        l_attr_name      := j.attr_name;
                        l_attr_disp_name := j.attr_display_name;
                        l_attr_sequence       := j.SEQUENCE;

                       /** Validate if any transaction atrribute exist with same
                       internal name while creating/ updating a transaction attribute**/
                       IF (p_attr_name IS NOT NULL ) THEN
                          IF (p_attr_name= l_attr_name) THEN
                            l_ta_is_invalid := TRUE;
                          END IF; --IF (p_attr_name= l_attr_name) THEN
                       END IF ; --IF (p_attr_name IS NOT NULL ) THEN

                       /** Validate if any transaction atrribute exist with same
                       display name while creating/ updating a transaction attribute**/
                       IF (p_attr_disp_name IS NOT NULL ) THEN
                          IF (p_attr_disp_name= l_attr_disp_name) THEN
                            l_ta_is_invalid := TRUE;
                          END IF; --IF (p_attr_disp_name= l_attr_disp_name) THEN
                       END IF; --IF (p_attr_disp_name IS NOT NULL ) THEN

                        /** Validate if any transaction atrribute exist with same
                       sequence while creating/ updating a transaction attribute**/
                       IF (p_attr_sequence IS NOT NULL ) THEN
                          IF (p_attr_sequence = l_attr_sequence) THEN
                            l_ta_is_invalid := TRUE;
                          END IF; --IF (p_attr_sequence= l_attr_sequence) THEN
                       END IF ; --IF (p_attr_sequence IS NOT NULL )

                END LOOP;--FOR j IN cur_metadata

        END LOOP; --FOR i IN cur_list
       RETURN l_ta_is_invalid;
END;



PROCEDURE IS_METADATA_CHANGE (p_tran_attrs_tbl  IN          EGO_TRAN_ATTR_TBL,
                              p_ta_metadata_tbl OUT NOCOPY  EGO_TRAN_ATTR_TBL,
                              x_return_status   OUT NOCOPY  VARCHAR2,
                              x_msg_count       OUT NOCOPY  NUMBER,
                              x_msg_data        OUT NOCOPY  VARCHAR2)
IS

  l_api_name     CONSTANT VARCHAR2(30) := 'IS_METADATA_CHANGE';

  l_uom_change            BOOLEAN:= FALSE;
  l_default_change        BOOLEAN:= FALSE;
  l_rejected_change       BOOLEAN:= FALSE;
  l_require_change        BOOLEAN:= FALSE;
  l_readonly_change       BOOLEAN:= FALSE;
  l_hidden_change         BOOLEAN:= FALSE;
  l_searchable_change     BOOLEAN:= FALSE;
  l_eligible_change       BOOLEAN:= FALSE;
  l_attr_disp_change      BOOLEAN:= FALSE;
  l_inherited_attr        BOOLEAN:= FALSE;



  l_out_uom               VARCHAR2(10);
  l_out_default           VARCHAR2(2000);
  l_out_rejected          VARCHAR2(2000);
  l_out_required          VARCHAR2(1);
  l_out_readonly          VARCHAR2(1);
  l_out_hidden            VARCHAR2(1);
  l_out_searchable        VARCHAR2(1);
  l_out_eligibile         VARCHAR2(1);
  l_out_attr_disp_name    VARCHAR2(80);


  l_attr_id               NUMBER:=0;
  l_value_set_id          NUMBER;
  l_uom_class             VARCHAR2(10);
  l_default_value         VARCHAR2(2000);
  l_rejectedvalue         VARCHAR2(2000);
  l_required              VARCHAR2(1);
  l_readonlyflag          VARCHAR2(1);
  l_hiddenflag            VARCHAR2(1);
  l_searchable            VARCHAR2(1);
  l_checkeligibility      VARCHAR2(1);
  l_item_cat_group_id     EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE;
  l_metadatalevel         VARCHAR2(10);
  l_attr_disp_name        VARCHAR2(80);

  indexcount              NUMBER:=1;

  CURSOR CUR_METADATA(CP_ITEM_CAT_GROUP_ID IN NUMBER,
                      CP_ATTR_ID           IN NUMBER)
  IS
    SELECT * FROM
       (SELECT versions.item_catalog_group_id,
              versions.ICC_VERSION_NUMBER    ,
              versions.ATTR_ID               ,
              versions.attr_display_name     ,
              versions.metadata_level        ,
              versions.association_id        ,
              VERSIONS.VALUE_SET_ID          ,
              VERSIONS.UOM_CLASS             ,
              VERSIONS.DEFAULT_VALUE         ,
              versions.revision_id           ,
              versions.organization_id       ,
              versions.inventory_item_id     ,
              VERSIONS.REJECTED_VALUE        ,
              VERSIONS.REQUIRED_FLAG         ,
              VERSIONS.READONLY_FLAG         ,
              VERSIONS.HIDDEN_FLAG           ,
              VERSIONS.SEARCHABLE_FLAG       ,
              VERSIONS.CHECK_ELIGIBILITY     ,
              Hier.lev
       FROM   EGO_TRANS_ATTR_VERS_B VERSIONS,
              (SELECT ITEM_CATALOG_GROUP_ID ,
                     LEVEL LEV
              FROM   MTL_ITEM_CATALOG_GROUPS_B
                START WITH ITEM_CATALOG_GROUP_ID = CP_ITEM_CAT_GROUP_ID
                CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
              ) HIER
       WHERE  HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id
          AND versions.attr_id           = CP_ATTR_ID
       )
    WHERE
       (
              /*(
                     LEV                =1
                 AND ICC_VERSION_number = 0
                 AND metadata_level     ='ICC'
              )
           OR  */
              (
                     LEV           > 1
                 AND metadata_level='ICC'
                 AND
                     (
                            item_catalog_group_id, ICC_VERSION_NUMBER
                     )
                     IN
                     (SELECT item_catalog_group_id,
                            VERSION_SEQ_ID
                     FROM   EGO_MTL_CATALOG_GRP_VERS_B
                     WHERE  start_active_date <=
                            (SELECT NVL(start_active_date,SYSDATE)
                            FROM   EGO_MTl_CATALOG_GRP_VERS_B
                            WHERE  ITEM_CATALOG_GROUP_ID = CP_ITEM_CAT_GROUP_ID
                               AND VERSION_SEQ_ID        = 0
                            )
                        AND NVL(end_active_date, sysdate) >=
                            (SELECT NVL(start_active_date,SYSDATE)
                            FROM   EGO_MTl_CATALOG_GRP_VERS_B
                            WHERE  ITEM_CATALOG_GROUP_ID = CP_ITEM_CAT_GROUP_ID
                               AND VERSION_SEQ_ID        = 0
                            )
                        AND version_seq_id > 0
                     )
              )
       )
    ORDER BY  Lev ASC ;

BEGIN
    --Reset all global variables
    FND_MSG_PUB.Initialize;
    p_ta_metadata_tbl  := EGO_TRAN_ATTR_TBL(NULL);
    FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last
    LOOP
                l_item_cat_group_id    := p_tran_attrs_tbl(i).ItemCatalogGroupId;
                l_attr_id              := p_tran_attrs_tbl(i).attrid;
                l_value_set_id         := p_tran_attrs_tbl(i).valuesetid;
                l_uom_class            := p_tran_attrs_tbl(i).uomclass;
                l_default_value        := p_tran_attrs_tbl(i).defaultvalue;
                l_rejectedvalue        := p_tran_attrs_tbl(i).rejectedvalue;
                l_required             := p_tran_attrs_tbl(i).requiredflag;
                l_readonlyflag         := p_tran_attrs_tbl(i).readonlyflag;
                l_hiddenflag           := p_tran_attrs_tbl(i).hiddenflag;
                l_searchable           := p_tran_attrs_tbl(i).searchableflag;
                l_checkeligibility     := p_tran_attrs_tbl(i).checkeligibility;
                l_metadatalevel        := p_tran_attrs_tbl(i).metadatalevel;
                l_attr_disp_name       := p_tran_attrs_tbl(i).AttrDisplayName;


                FOR J IN CUR_METADATA(CP_ITEM_CAT_GROUP_ID =>l_item_cat_group_id , CP_ATTR_ID=>l_attr_id)
                LOOP

                  IF (CUR_METADATA%ROWCOUNT>0 ) THEN
                    l_inherited_attr :=TRUE;
                  END IF;



                  IF(l_attr_disp_name IS NULL) THEN
                     l_attr_disp_change:= TRUE;
                  ELSIF (l_attr_disp_change = FALSE) THEN
                    IF (j.attr_display_name IS NULL) THEN
                      l_attr_disp_change:= TRUE;
                    ELSIF (l_attr_disp_name <> j.attr_display_name) THEN
                      l_attr_disp_change:= TRUE;
                    ELSE
                      l_attr_disp_change:= FALSE;
                    END IF;
                  END IF;





                  IF(l_uom_class IS NULL) THEN
                     l_uom_change:= TRUE;
                  ELSIF (l_uom_change = FALSE) THEN

                    IF (j.uom_class IS NULL) THEN
                      l_uom_change:= TRUE;
                    ELSIF (l_uom_class <> j.uom_class) THEN
                      l_uom_change:= TRUE;
                    ELSE
                      l_uom_change:= FALSE;
                    END IF;
                  END IF;

                  IF(l_default_value IS NULL) THEN
                     l_default_change:= TRUE;
                  ELSIF (l_default_change = FALSE) THEN
                    IF (j.default_value IS NULL) THEN
                      l_default_change:= TRUE;
                    ELSIF (l_default_value <> j.default_value) THEN
                      l_default_change:= TRUE ;
                    ELSE
                      l_default_change:= FALSE ;
                    END IF;
                  END IF;


                  IF(l_rejectedvalue IS NULL) THEN
                     l_rejected_change:= TRUE;
                  ELSIF (l_rejected_change = FALSE) THEN
                    IF (j.REJECTED_VALUE IS NULL) THEN
                      l_rejected_change:= TRUE;
                    ELSIF (l_rejectedvalue <> j.REJECTED_VALUE) THEN
                      l_rejected_change:= TRUE;
                    ELSE
                      l_rejected_change:= FALSE;
                    END IF;
                  END IF;

                  IF(l_required IS NULL) THEN
                     l_require_change:= TRUE;
                  ELSIF (l_require_change = FALSE) THEN
                    IF (j.REQUIRED_FLAG IS NULL) THEN
                      l_require_change:= TRUE;
                    ELSIF (l_required <> j.REQUIRED_FLAG) THEN
                      l_require_change:= TRUE;
                    ELSE
                      l_require_change:= FALSE;
                    END IF;
                  END IF;


                  IF(l_readonlyflag IS NULL) THEN
                     l_readonly_change:= TRUE;
                  ELSIF (l_readonly_change = FALSE) THEN
                    IF (j.READONLY_FLAG IS NULL) THEN
                      l_readonly_change:= TRUE;
                    ELSIF (l_readonlyflag <> j.READONLY_FLAG) THEN
                      l_readonly_change:= TRUE;
                    ELSE
                      l_readonly_change:= FALSE;
                    END IF;
                  END IF;

                  IF(l_hiddenflag IS NULL) THEN
                     l_hidden_change:= TRUE;
                  ELSIF (l_hidden_change = FALSE) THEN
                    IF (j.HIDDEN_FLAG IS NULL) THEN
                      l_hidden_change:= TRUE;
                    ELSIF (l_hiddenflag <> j.HIDDEN_FLAG) THEN
                      l_hidden_change:= TRUE;
                    ELSE
                      l_hidden_change:= FALSE;
                    END IF;
                  END IF;

                  IF(l_searchable IS NULL) THEN
                     l_searchable_change:= TRUE;
                  ELSIF (l_searchable_change = FALSE) THEN
                    IF (j.SEARCHABLE_FLAG IS NULL) THEN
                      l_searchable_change:= TRUE;
                    ELSIF (l_searchable <> j.SEARCHABLE_FLAG) THEN
                      l_searchable_change:= TRUE;
                    ELSE
                      l_searchable_change:= FALSE;
                    END IF;
                  END IF;

                  IF(l_checkeligibility IS NULL) THEN
                     l_eligible_change:= TRUE;
                  ELSIF (l_eligible_change = FALSE) THEN
                    IF (j.CHECK_ELIGIBILITY IS NULL) THEN
                      l_eligible_change:= TRUE;
                    ELSIF (l_checkeligibility <> j.CHECK_ELIGIBILITY) THEN
                      l_eligible_change:= TRUE;
                    ELSE
                      l_eligible_change:= FALSE;
                    END IF;
                  END IF;



                END LOOP; -- Loop   FOR J IN CUR_METADATA(CP_ITEM_CAT_GROUP_ID =>l_item_cat_group_id , CP_ATTR_ID=>l_attr_id)


                IF (l_inherited_attr) THEN
                    IF (l_attr_disp_change = TRUE) THEN
                      l_out_attr_disp_name:=l_attr_disp_name;
                    ELSE
                      l_out_attr_disp_name:=NULL;
                    END IF;

                    IF (l_uom_change = TRUE) THEN
                      l_out_uom:=l_uom_class;
                    ELSE
                      l_out_uom:=NULL;
                    END IF;

                    IF (l_default_change = TRUE) THEN
                      l_out_default:=l_default_value;
                    ELSE
                      l_out_default:=NULL;
                    END IF;

                    IF (l_rejected_change = TRUE) THEN
                      l_out_rejected:=l_rejectedvalue;
                    ELSE
                      l_out_rejected:=NULL;
                    END IF;

                    IF (l_require_change = TRUE) THEN
                      l_out_required:=l_required;
                    ELSE
                      l_out_required:=NULL;
                    END IF;

                    IF (l_readonly_change = TRUE) THEN
                      l_out_readonly:=l_readonlyflag;
                    ELSE
                      l_out_readonly:=NULL;
                    END IF;

                    IF (l_hidden_change = TRUE) THEN
                      l_out_hidden:=l_hiddenflag;
                    ELSE
                      l_out_hidden:=NULL;
                    END IF;

                    IF (l_searchable_change = TRUE) THEN
                      l_out_searchable:=l_searchable;
                    ELSE
                      l_out_searchable:=NULL;
                    END IF;

                    IF (l_eligible_change = TRUE) THEN
                      l_out_eligibile:=l_checkeligibility;
                    ELSE
                      l_out_eligibile:=NULL;
                    END IF;
                    --p_ta_metadata_tbl.extend;
                    p_ta_metadata_tbl(indexcount)  := EGO_TRAN_ATTR_REC(
                                         --EGO_TA_METADATA_REC(
                                         p_tran_attrs_tbl(i).AssociationId,
                                         p_tran_attrs_tbl(i).AttrId,
                                         p_tran_attrs_tbl(i).icc_version_number,
                                         p_tran_attrs_tbl(i).revision_id,
                                         p_tran_attrs_tbl(i).Sequence,
                                         p_tran_attrs_tbl(i).ValueSetId,
                                         l_out_uom,
                                         l_out_default,
                                         l_out_rejected,
                                         l_out_required,
                                         l_out_readonly,
                                         l_out_hidden,
                                         l_out_searchable,
                                         l_out_eligibile,
                                         p_tran_attrs_tbl(i).InventoryItemId,
                                         p_tran_attrs_tbl(i).OrganizationId,
                                         p_tran_attrs_tbl(i).MetadataLevel,
                                         p_tran_attrs_tbl(i).CreatedBy,
                                         p_tran_attrs_tbl(i).CreationDate,
                                         p_tran_attrs_tbl(i).LastUpdatedBy,
                                         p_tran_attrs_tbl(i).LastUpdateDate,
                                         p_tran_attrs_tbl(i).LastUpdateLogin,
                                         p_tran_attrs_tbl(i).ProgramApplicationId,
                                         p_tran_attrs_tbl(i).ProgramId,
                                         p_tran_attrs_tbl(i).ProgramUpdateDate,
                                         p_tran_attrs_tbl(i).RequestId,
                                         p_tran_attrs_tbl(i).ItemCatalogGroupId,
                                         p_tran_attrs_tbl(i).AttrName,
                                         --p_tran_attrs_tbl(i).AttrDisplayName,
                                         l_out_attr_disp_name,
                                         p_tran_attrs_tbl(i).DataType,
                                         p_tran_attrs_tbl(i).DisplayAs  ,
                                         p_tran_attrs_tbl(i).ValueSetName
                                         --)
                                         );

                    indexcount:=indexcount+1;

                ELSE
                    p_ta_metadata_tbl(indexcount)  := EGO_TRAN_ATTR_REC(
                                         --EGO_TA_METADATA_REC(
                                         p_tran_attrs_tbl(i).AssociationId,
                                         p_tran_attrs_tbl(i).AttrId,
                                         p_tran_attrs_tbl(i).icc_version_number,
                                         p_tran_attrs_tbl(i).revision_id,
                                         p_tran_attrs_tbl(i).Sequence,
                                         p_tran_attrs_tbl(i).ValueSetId,
                                         p_tran_attrs_tbl(i).UomClass,
                                         p_tran_attrs_tbl(i).DefaultValue,
                                         p_tran_attrs_tbl(i).RejectedValue,
                                         p_tran_attrs_tbl(i).RequiredFlag,
                                         p_tran_attrs_tbl(i).ReadonlyFlag,
                                         p_tran_attrs_tbl(i).HiddenFlag,
                                         p_tran_attrs_tbl(i).SearchableFlag,
                                         p_tran_attrs_tbl(i).CheckEligibility,
                                         p_tran_attrs_tbl(i).InventoryItemId,
                                         p_tran_attrs_tbl(i).OrganizationId,
                                         p_tran_attrs_tbl(i).MetadataLevel,
                                         p_tran_attrs_tbl(i).CreatedBy,
                                         p_tran_attrs_tbl(i).CreationDate,
                                         p_tran_attrs_tbl(i).LastUpdatedBy,
                                         p_tran_attrs_tbl(i).LastUpdateDate,
                                         p_tran_attrs_tbl(i).LastUpdateLogin,
                                         p_tran_attrs_tbl(i).ProgramApplicationId,
                                         p_tran_attrs_tbl(i).ProgramId,
                                         p_tran_attrs_tbl(i).ProgramUpdateDate,
                                         p_tran_attrs_tbl(i).RequestId,
                                         p_tran_attrs_tbl(i).ItemCatalogGroupId,
                                         p_tran_attrs_tbl(i).AttrName,
                                         p_tran_attrs_tbl(i).AttrDisplayName,
                                         p_tran_attrs_tbl(i).DataType,
                                         p_tran_attrs_tbl(i).DisplayAs  ,
                                         p_tran_attrs_tbl(i).ValueSetName
                                         --)
                                         );

                END IF ; -- end IF (l_inherited_attr) THEN

                l_attr_disp_change     :=  FALSE;
                l_uom_change           :=  FALSE;
                l_default_change       :=  FALSE;
                l_rejected_change      :=  FALSE;
                l_require_change       :=  FALSE;
                l_readonly_change      :=  FALSE;
                l_hidden_change        :=  FALSE;
                l_searchable_change    :=  FALSE;
                l_eligible_change      :=  FALSE;
                l_inherited_attr       :=  FALSE;



    END LOOP;
    /* FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last  */
    x_return_status := G_STATUS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,p_count => x_msg_count ,p_data => x_msg_data);
END;








/* Create inherited transaction attribute API*/
PROCEDURE Create_Inherited_Trans_Attr
        (
                p_api_version     IN NUMBER,
                p_tran_attrs_tbl  IN EGO_TRAN_ATTR_TBL,
                x_return_status   OUT NOCOPY VARCHAR2,
                x_msg_count       OUT NOCOPY     NUMBER,
                x_msg_data        OUT NOCOPY      VARCHAR2)
IS
        /* User Defined Exception object*/
        e_ta_disp_name_exist    EXCEPTION;
        e_ta_default_value_null EXCEPTION;
        e_vs_data_type          EXCEPTION;
        e_vs_not_versioned      EXCEPTION;

        /* Declaring local parameters*/
        l_attr_desc             VARCHAR2(100); --confirm about size
        l_count                 NUMBER:=0;
        l_ag_seq_value          NUMBER;
        l_ag_int_name           VARCHAR2(100); --confirm about size
        l_ag_disp_name          VARCHAR2(100); --confirm about size
        l_ag_desc               VARCHAR2(100); --confirm about size
        l_ag_type               VARCHAR2(30) := 'EGO_ITEM_TRANS_ATTR_GROUP';
        l_attr_group_id         NUMBER;
        l_column                VARCHAR2(30):=NULL;
        l_return_status         VARCHAR2(1);
        l_errorcode             NUMBER;
        l_msg_count             NUMBER;
        l_msg_data              VARCHAR2(2000);
        l_association_id        NUMBER;
        l_attr_id               NUMBER:=0;
        l_attr_sequence         EGO_ATTRS_V.SEQUENCE%TYPE;
        l_value_set_id          NUMBER;
        l_uom_class             VARCHAR2(10);
        l_default_value         VARCHAR2(2000);
        l_rejectedvalue         VARCHAR2(2000);
        l_required              VARCHAR2(1);
        l_readonlyflag          VARCHAR2(1);
        l_hiddenflag            VARCHAR2(1);
        l_searchable            VARCHAR2(1);
        l_checkeligibility      VARCHAR2(1);
        l_inventoryitemid       NUMBER;
        l_organizationid        NUMBER;
        l_metadatalevel         VARCHAR2(10);
        l_programapplicationid  NUMBER;
        l_programid             NUMBER;
        l_programupdatedate     DATE;
        l_requestid             NUMBER;
        l_item_cat_group_id     EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE;
        l_attr_name             EGO_ATTRS_V.ATTR_NAME%TYPE             :=NULL;
        l_attr_disp_name        EGO_ATTRS_V.ATTR_DISPLAY_NAME%TYPE:=NULL;
        l_data_type             VARCHAR2(1);
        l_display               VARCHAR2(1);
        l_api_name     CONSTANT VARCHAR2(30) := 'Create_Inherited_Trans_Attr';
        l_data_level_id         NUMBER;
        l_icc_version_number    NUMBER;
        l_revision_id           NUMBER;
        l_item_obj_id           NUMBER;
        l_versioned_value_set   NUMBER:=0;

        l_ta_metadata_tbl       EGO_TRAN_ATTR_TBL;

BEGIN
        --Reset all global variables
        FND_MSG_PUB.Initialize;
        l_ta_metadata_tbl   :=    EGO_TRAN_ATTR_TBL(NULL);

        IS_METADATA_CHANGE(p_tran_attrs_tbl,l_ta_metadata_tbl,l_return_status,l_msg_count,l_msg_data );
        FOR i IN l_ta_metadata_tbl.first..l_ta_metadata_tbl.last
        LOOP

                l_item_cat_group_id    := l_ta_metadata_tbl(i).ItemCatalogGroupId;
                --l_attr_name            := p_tran_attrs_tbl(i).AttrName;
                l_attr_disp_name       := l_ta_metadata_tbl(i).AttrDisplayName;
                l_attr_sequence        := l_ta_metadata_tbl(i).SEQUENCE;
                l_association_id       := l_ta_metadata_tbl(i).associationid;
                l_attr_id              := l_ta_metadata_tbl(i).attrid;
                l_value_set_id         := l_ta_metadata_tbl(i).valuesetid;
                l_uom_class            := l_ta_metadata_tbl(i).uomclass;
                l_default_value        := l_ta_metadata_tbl(i).defaultvalue;
                l_rejectedvalue        := l_ta_metadata_tbl(i).rejectedvalue;
                l_required             := l_ta_metadata_tbl(i).requiredflag;
                l_readonlyflag         := l_ta_metadata_tbl(i).readonlyflag;
                l_hiddenflag           := l_ta_metadata_tbl(i).hiddenflag;
                l_searchable           := l_ta_metadata_tbl(i).searchableflag;
                l_checkeligibility     := l_ta_metadata_tbl(i).checkeligibility;
                l_inventoryitemid      := l_ta_metadata_tbl(i).inventoryitemid;
                l_organizationid       := l_ta_metadata_tbl(i).organizationid;
                l_metadatalevel        := l_ta_metadata_tbl(i).metadatalevel;
                l_programapplicationid := l_ta_metadata_tbl(i).programapplicationid;
                l_programid            := l_ta_metadata_tbl(i).programid;
                l_programupdatedate    := l_ta_metadata_tbl(i).programupdatedate;
                l_requestid            := l_ta_metadata_tbl(i).requestid;
                l_icc_version_number   := l_ta_metadata_tbl(i).icc_version_number;
                l_revision_id          := p_tran_attrs_tbl(i).revision_id;
                l_data_type            := l_ta_metadata_tbl(i).datatype;
                --l_display              := p_tran_attrs_tbl(i).displayas;

                /* Check  if att_disp_name already exist*/
                IF ( Check_TA_IS_INVALID (p_item_cat_group_id => l_item_cat_group_id, p_attr_id => l_attr_id, p_attr_disp_name => l_attr_disp_name) ) THEN
                        RAISE e_ta_disp_name_exist;
                END IF;

                IF ( l_readonlyflag='Y' AND l_required ='Y' AND l_default_value IS NULL) THEN
                        RAISE e_ta_default_value_null;
                END IF;
            -------------------------------------------------------------------------------------
                -- Make sure that if a Value Set was passed in, is a versioned value set --
                -------------------------------------------------------------------------------------
                IF (l_value_set_id IS NOT NULL) THEN
                        SELECT COUNT(*) CNT
                        INTO   l_versioned_value_set
                        FROM   EGO_FLEX_VALUESET_VERSION_B
                        WHERE  FLEX_VALUE_SET_ID = l_value_set_id
                           AND VERSION_SEQ_ID    >0;

                        IF (l_versioned_value_set=0) THEN
                                RAISE e_vs_not_versioned;
                        END IF;
                        --------------------------------------------------------------------------
                        IF (NOT Check_VS_Data_Type(l_value_set_id,l_data_type) ) THEN
                                RAISE e_vs_data_type;
                        END IF;
                END IF;
                /* checking whether any of the columns are updated before inserting
                bug 8356736 */
                IF(l_attr_disp_name IS NOT  NULL OR  l_default_value IS NOT  NULL OR  l_rejectedvalue IS NOT NULL OR  l_required IS NOT NULL  OR
                   l_readonlyflag IS NOT NULL OR   l_hiddenflag IS NOT  NULL OR   l_searchable IS NOT NULL OR    l_checkeligibility IS NOT  NULL ) THEN
                /* INSERTING values in tables*/
                BEGIN
                        INSERT INTO EGO_TRANS_ATTR_VERS_B
                                     (association_id,
                                      attr_id,
                                      icc_version_number,
                                      attr_display_name,
                                      sequence,
                                      value_set_id,
                                      uom_class,
                                      default_value,
                                      rejected_value,
                                      required_flag,
                                      readonly_flag,
                                      hidden_flag,
                                      searchable_flag,
                                      check_eligibility,
                                      inventory_item_id,
                                      organization_id,
                                      revision_id,
                                      metadata_level,
                                      created_by,
                                      creation_date,
                                      last_updated_by,
                                      last_update_date,
                                      last_update_login,
                                      program_application_id,
                                      program_id,
                                      program_update_date,
                                      request_id,
                                      item_catalog_group_id)
                              VALUES (l_association_id      ,
                                      l_attr_id             ,
                                      l_icc_version_number  ,
                                      l_attr_disp_name      ,
                                      l_attr_sequence       ,
                                      l_value_set_id        ,
                                      l_uom_class           ,
                                      l_default_value       ,
                                      l_rejectedvalue       ,
                                      l_required            ,
                                      l_readonlyflag        ,
                                      l_hiddenflag          ,
                                      l_searchable          ,
                                      l_checkeligibility    ,
                                      l_inventoryitemid     ,
                                      l_organizationid      ,
                                      l_revision_id         ,
                                      l_metadatalevel       ,
                                      G_CURRENT_USER_ID     ,
                                      SYSDATE               ,
                                      G_CURRENT_USER_ID     ,
                                      SYSDATE               ,
                                      G_CURRENT_LOGIN_ID    ,
                                      l_programapplicationid,
                                      l_programid           ,
                                      l_programupdatedate   ,
                                      l_requestid           ,
                                      l_item_cat_group_id
                               );

                EXCEPTION
                WHEN OTHERS
                THEN
                  x_return_status   :=  G_STATUS_ERROR;
                  x_msg_data       :=  'TA_REC_INSERT_FAILED';
                  FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
                  FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
                  FND_MESSAGE.Set_Token('API_NAME', l_api_name);
                  FND_MESSAGE.Set_Token('SQL_ERR_MSG',x_msg_data );
                  FND_MSG_PUB.Add;
                  FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                           ,p_count   => x_msg_count
                                           ,p_data    => x_msg_data);
                END ;
                END IF; --BUG 8356736
        END LOOP;
        /* FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last  */
        IF (Nvl(x_return_status,G_STATUS_SUCCESS) <>G_STATUS_ERROR )
        THEN
           x_return_status := G_STATUS_SUCCESS;
        END IF;
EXCEPTION
  WHEN e_ta_disp_name_exist THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_TA_DISPLAY_NAME_UNIQUE');
        --FND_MESSAGE.Set_Token('SQL_ERR_MSG',x_msg_data );
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
  WHEN e_ta_default_value_null THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_TA_DEFAULT_VALUE_NULL');
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count => x_msg_count
                                 ,p_data => x_msg_data);
    WHEN e_vs_not_versioned
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_VALUE_SET_NOT_VERSIONED');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN e_vs_data_type
    THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_EF_CR_ATTR_VS_DT_ERR');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);

  WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count => x_msg_count
                                 ,p_data => x_msg_data);
END Create_Inherited_Trans_Attr;









--============ Update_Transaction_Attribute API===============

PROCEDURE Update_Transaction_Attribute (
           p_api_version      IN         NUMBER,
           p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2)
IS
    /* Declaring local parameters*/
   l_attr_desc           VARCHAR2(100);  --confirm about size
   l_ag_int_name         VARCHAR2(100);   --confirm about size
   l_ag_type             VARCHAR2(30) := 'EGO_ITEM_TRANS_ATTR_GROUP';
   l_icc_version_number  NUMBER;
   --l_attr_group_id       NUMBER;
   l_column              VARCHAR2(30):=NULL;

   l_return_status       VARCHAR2(1);
   l_errorcode           NUMBER;
   l_msg_count           NUMBER;
   l_msg_data            VARCHAR2(2000);

   l_association_id      NUMBER;
   l_attr_id             NUMBER;
   l_attr_sequence       EGO_ATTRS_V.SEQUENCE%TYPE;
   l_value_set_id        NUMBER;
   l_uom_class           VARCHAR2(10);
   l_default_value       VARCHAR2(2000);
   l_rejectedvalue           VARCHAR2(2000);
   l_required            VARCHAR2(1);
   l_readonlyflag            VARCHAR2(1);
   l_hiddenflag                VARCHAR2(1);
   l_searchable          VARCHAR2(1);
   l_checkeligibility    VARCHAR2(1);
   l_item_cat_group_id   EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE;
   l_attr_name           EGO_ATTRS_V.ATTR_NAME%TYPE:=NULL;
   l_attr_disp_name      EGO_ATTRS_V.ATTR_DISPLAY_NAME%TYPE:=NULL;
   l_data_type           VARCHAR2(1);
   l_display             VARCHAR2(1);
   l_inventoryitemid     NUMBER;
   l_revisionid          NUMBER;
   l_organizationid      NUMBER;


   l_api_name            CONSTANT VARCHAR2(30) := 'Update_Transaction_Attribute';

   /* User Defined Exception object*/
   e_ta_int_name_exist     EXCEPTION;
   e_ta_disp_name_exist    EXCEPTION;
   e_ta_sequence_exist     EXCEPTION;
   e_ta_default_value_null EXCEPTION;
   l_ta_metadata_tbl       EGO_TRAN_ATTR_TBL;

BEGIN
    --Reset all global variables
    FND_MSG_PUB.Initialize;
    IS_METADATA_CHANGE(p_tran_attrs_tbl,l_ta_metadata_tbl,l_return_status,l_msg_count,l_msg_data );
    FOR i IN l_ta_metadata_tbl.first..l_ta_metadata_tbl.last
    LOOP
      l_association_id    := l_ta_metadata_tbl(i).associationid;
      l_attr_id           := l_ta_metadata_tbl(i).attrid;
      l_item_cat_group_id := l_ta_metadata_tbl(i).ItemCatalogGroupId;
      l_attr_sequence     := l_ta_metadata_tbl(i).SEQUENCE;
      l_icc_version_number:= l_ta_metadata_tbl(i).icc_version_number;

      l_attr_name         := l_ta_metadata_tbl(i).AttrName;
      l_attr_disp_name    := l_ta_metadata_tbl(i).AttrDisplayName;
      l_attr_sequence     := l_ta_metadata_tbl(i).SEQUENCE;


      l_value_set_id      := l_ta_metadata_tbl(i).valuesetid;
      l_uom_class         := l_ta_metadata_tbl(i).uomclass;
      l_default_value     := l_ta_metadata_tbl(i).defaultvalue;
      l_rejectedvalue     := l_ta_metadata_tbl(i).rejectedvalue;
      l_required          := l_ta_metadata_tbl(i).requiredflag;
      l_readonlyflag      := l_ta_metadata_tbl(i).readonlyflag;
      l_hiddenflag        := l_ta_metadata_tbl(i).hiddenflag;
      l_searchable        := l_ta_metadata_tbl(i).searchableflag;
      l_checkeligibility  := l_ta_metadata_tbl(i).checkeligibility;
      l_inventoryitemid   := l_ta_metadata_tbl(i).InventoryItemId;
      l_revisionid        := l_ta_metadata_tbl(i).revision_id;
      l_organizationid    := l_ta_metadata_tbl(i).OrganizationId;
      --l_data_type         := p_tran_attrs_tbl(i).datatype;
            l_display           := l_ta_metadata_tbl(i).displayas;


      /* Check  if att_disp_name already exist*/
      /*IF (Check_Ta_Disp_Name_Exist(l_item_cat_group_id,l_attr_id,l_attr_disp_name)) THEN
          RAISE  e_ta_disp_name_exist;
      END IF; */

      /* Check  if att_disp_name already exist*/
      IF (    Check_TA_IS_INVALID (p_item_cat_group_id  => l_item_cat_group_id,
                                 p_attr_id            => l_attr_id,
                                 p_attr_disp_name     => l_attr_disp_name) ) THEN
          RAISE  e_ta_disp_name_exist;
      END IF;

      IF(l_inventoryitemid IS NOT NULL AND l_revisionid IS NOT NULL AND l_organizationid IS NOT NULL ) THEN
            UPDATE EGO_TRANS_ATTR_VERS_B
              SET "SEQUENCE"  =l_attr_sequence,
                  ATTR_DISPLAY_NAME = l_attr_disp_name,
                  value_set_id      = l_value_set_id,
                  uom_class         = l_uom_class,
                  default_value     = l_default_value,
                  rejected_value    = l_rejectedvalue,
                  required_flag     = l_required,
                  readonly_flag     = l_readonlyflag,
                  hidden_flag       = l_hiddenflag,
                  searchable_flag   = l_searchable,
                  check_eligibility = l_checkeligibility,
                  last_updated_by   = G_CURRENT_USER_ID,
                  last_update_date  = SYSDATE,
                  last_update_login = G_CURRENT_LOGIN_ID
              WHERE  ASSOCIATION_ID= l_association_id
                  AND ATTR_ID  =l_attr_id
                  AND INVENTORY_ITEM_ID = l_inventoryitemid
                  AND ORGANIZATION_ID = l_organizationid
                  AND REVISION_ID = l_revisionid
                  AND metadata_level  = 'ITM';
      ELSE
            UPDATE EGO_TRANS_ATTR_VERS_B
              SET "SEQUENCE"  =l_attr_sequence,
                  ATTR_DISPLAY_NAME = l_attr_disp_name,
                  value_set_id      = l_value_set_id,
                  uom_class         = l_uom_class,
                  default_value     = l_default_value,
                  rejected_value    = l_rejectedvalue,
                  required_flag     = l_required,
                  readonly_flag     = l_readonlyflag,
                  hidden_flag       = l_hiddenflag,
                  searchable_flag   = l_searchable,
                  check_eligibility = l_checkeligibility,
                  last_updated_by   = G_CURRENT_USER_ID,
                  last_update_date  = SYSDATE,
                  last_update_login = G_CURRENT_LOGIN_ID
              WHERE  ASSOCIATION_ID= l_association_id
                  AND ATTR_ID  =l_attr_id
                  AND ITEM_CATALOG_GROUP_ID = l_item_cat_group_id
                  AND ICC_VERSION_NUMBER =0
                  AND metadata_level  = 'ICC';

      END IF;

      SELECT attr_group_name INTO l_ag_int_name
        FROM EGO_OBJ_ATTR_GRP_ASSOCS_V
       WHERE (object_id, classification_code, attr_group_id) IN
               (SELECT object_id, classification_code, attr_group_id
                FROM ego_obj_ag_assocs_b
                where association_id = l_association_id);


      /*EGO_EXT_FWK_PUB.Update_Attribute (
             p_api_version       => 1.0
                  ,p_application_id    => G_APPLICATION_ID
                  ,p_attr_group_type   => l_ag_type
                  ,p_attr_group_name   => l_ag_int_name
                  ,p_internal_name     => l_attr_name
                  ,p_display_name      => l_attr_disp_name
                  ,p_description       => l_attr_desc
                  ,p_sequence          => l_attr_sequence
            ,p_required          => l_required
                  ,p_searchable        => l_searchable
                  ,p_column            => l_column
            ,p_value_set_id      => l_value_set_id
                  ,p_info_1            => null
                  ,p_default_value     => l_default_value
                  ,p_unique_key_flag   => null
                  ,p_enabled           => 'Y'
                  ,p_display           => l_display
            ,p_control_level     => -1
            ,p_attribute_code    => G_MISS_CHAR
            ,p_view_in_hierarchy_code => G_MISS_CHAR
            ,p_edit_in_hierarchy_code => G_MISS_CHAR
            ,p_customization_level    => G_MISS_CHAR
            ,p_owner             => NULL
            ,p_lud               => SYSDATE
            ,p_init_msg_list     => null
                  ,p_commit            => null
            ,p_is_nls_mode       => FND_API.G_FALSE
            ,p_uom_class         => l_uom_class
            ,x_return_status     => l_return_status
                  ,x_errorcode         => l_errorcode
                  ,x_msg_count         => l_msg_count
                  ,x_msg_data          => l_msg_data);*/
    END LOOP; /* FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last  */
      x_return_status:=G_STATUS_SUCCESS;

EXCEPTION
    WHEN e_ta_disp_name_exist THEN
      x_return_status   :=  G_STATUS_ERROR;
      FND_MESSAGE.Set_Name('EGO', 'EGO_TA_DISPLAY_NAME_UNIQUE');
      FND_MSG_PUB.Add;
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
    WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END Update_Transaction_Attribute;



--============ Delete_Transaction_Attribute API===============
PROCEDURE Delete_Transaction_Attribute (
           p_api_version      IN         NUMBER,
           p_association_id   IN         NUMBER,
           p_attr_id          IN         NUMBER,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2)
  IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Transaction_Attribute';

BEGIN
     --Reset all global variables
     FND_MSG_PUB.Initialize;
     DELETE FROM EGO_TRANS_ATTR_VERS_B
      WHERE  ASSOCIATION_ID= p_association_id
              AND ATTR_ID  =p_attr_id
              AND ICC_VERSION_NUMBER=0;
    x_return_status := G_STATUS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG',SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
END Delete_Transaction_Attribute;


--========Override method=======
PROCEDURE Delete_Transaction_Attribute (
           p_api_version      IN         NUMBER,
           p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_msg_count        OUT NOCOPY NUMBER,
           x_msg_data         OUT NOCOPY VARCHAR2) IS

  /* Declaring local parameters*/
  l_association_id      EGO_TRANS_ATTR_VERS_B.ASSOCIATION_ID%TYPE;
  l_attr_id             EGO_TRANS_ATTR_VERS_B.ATTR_ID%TYPE;
  l_icc_version_number  NUMBER;

  l_item_cat_group_id   EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE;
  l_api_name            CONSTANT VARCHAR2(30) := 'Delete_Transaction_Attribute';

BEGIN
    --Reset all global variables
    FND_MSG_PUB.Initialize;
    FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last
    LOOP
      l_association_id    := p_tran_attrs_tbl(i).associationid;
      l_attr_id           := p_tran_attrs_tbl(i).attrid;

     DELETE FROM EGO_TRANS_ATTR_VERS_B
      WHERE  ASSOCIATION_ID= l_association_id
              AND ATTR_ID  =l_attr_id
              AND ICC_VERSION_NUMBER=0;
    END LOOP; /* FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last  */

    x_return_status := G_STATUS_SUCCESS;

EXCEPTION
  WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
END Delete_Transaction_Attribute;




--============ Release_Transaction_Attribute API===============

/* Releasing a version of a ICC*/
PROCEDURE Release_Transaction_Attribute (
           p_api_version      IN         NUMBER,
           p_icc_id           IN         NUMBER,
           p_version_number   IN         NUMBER,
           --p_tran_attrs_tbl   IN         EGO_TRAN_ATTR_TBL,
           x_return_status    OUT NOCOPY VARCHAR2
          ,x_msg_count        OUT NOCOPY NUMBER
          ,x_msg_data         OUT NOCOPY VARCHAR2)
IS

  /* Declaring local parameters*/
  --l_association_id      EGO_TRANS_ATTR_VERS_B.ASSOCIATION_ID%TYPE;
  --l_attr_id             EGO_TRANS_ATTR_VERS_B.ATTR_ID%TYPE;
  l_icc_version_number  NUMBER:=p_version_number;
  l_max_ver_number      NUMBER:=0;
  l_item_cat_group_id   EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE:=p_icc_id;
  l_api_name            CONSTANT VARCHAR2(30) := 'Release_Transaction_Attribute';

  l_return_status       VARCHAR2(1);
  l_errorcode           NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(2000);

  e_version_error   EXCEPTION ;


  CURSOR cur_tran_attr_vers_exist
    IS
    SELECT Max(icc_version_number) maxver
                   FROM EGO_TRANS_ATTR_VERS_B
                      WHERE ITEM_CATALOG_GROUP_ID=l_item_cat_group_id;

BEGIN
  --Reset all global variables
  FND_MSG_PUB.Initialize;
  FOR i IN cur_tran_attr_vers_exist
  LOOP
    l_max_ver_number:=i.maxver;
  END LOOP;

  IF (l_max_ver_number>= p_version_number ) THEN
      RAISE  e_version_error;
  END IF;
  /*FOR i IN p_tran_attrs_tbl.first..p_tran_attrs_tbl.last
  LOOP */
      /*l_association_id    := p_tran_attrs_tbl(i).associationid;
      l_attr_id           := p_tran_attrs_tbl(i).attrid;*/
      --l_item_cat_group_id := p_tran_attrs_tbl(i).ItemCatalogGroupId;

  Copy_Transaction_Attribute(l_item_cat_group_id,l_icc_version_number,l_return_status,l_msg_count,l_msg_data);
  x_return_status := G_STATUS_SUCCESS;
  --END LOOP;

EXCEPTION
  WHEN e_version_error
  THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_ICC_VER_ERROR');
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
  WHEN OTHERS
  THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END;

PROCEDURE Copy_Transaction_Attribute (
           p_item_cat_group_id   IN         NUMBER,
           p_version_number      IN         NUMBER,
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2)
IS
  /* Declaring local parameters*/
  l_association_id      EGO_TRANS_ATTR_VERS_B.ASSOCIATION_ID%TYPE;
  l_attr_id             EGO_TRANS_ATTR_VERS_B.ATTR_ID%TYPE;
  l_item_cat_group_id   EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE:=p_item_cat_group_id;
  l_icc_version_number  NUMBER:=p_version_number;
  l_api_name            CONSTANT VARCHAR2(30) := 'Copy_Transaction_Attribute';

  CURSOR cur_tran_attr_vers
    IS
    SELECT *
                   FROM EGO_TRANS_ATTR_VERS_B
                      WHERE ITEM_CATALOG_GROUP_ID=l_item_cat_group_id
            AND ICC_VERSION_NUMBER =0;
BEGIN
    --Reset all global variables
    FND_MSG_PUB.Initialize;
    FOR i IN cur_tran_attr_vers
    LOOP
      INSERT INTO  EGO_TRANS_ATTR_VERS_B
             (association_id,attr_id,icc_version_number,attr_display_name,"SEQUENCE",value_set_id,uom_class,
              default_value,rejected_value,required_flag,readonly_flag,hidden_flag, searchable_flag,
              check_eligibility,inventory_item_id,organization_id, revision_id,metadata_level,created_by,
              creation_date,last_updated_by,last_update_date,last_update_login,program_application_id,
              program_id,program_update_date,request_id,item_catalog_group_id)
      VALUES (i.association_id,i.attr_id,l_icc_version_number,i.attr_display_name,i.SEQUENCE,i.value_set_id,i.uom_class,
              i.default_value,i.rejected_value,i.required_flag,i.readonly_flag,i.hidden_flag,i.searchable_flag,
              i.check_eligibility,i.inventory_item_id,i.organization_id,i.revision_id,i.metadata_level,G_CURRENT_USER_ID,
              sysdate,G_CURRENT_USER_ID,SYSDATE,G_CURRENT_LOGIN_ID,i.program_application_id,
              i.program_id,i.program_update_date,i.request_id,i.item_catalog_group_id);
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);
END;


/* procedure to copy data from source Id's to destination Id's*/

PROCEDURE Copy_Transaction_Attribute (
           p_source_icc_id       IN         NUMBER,
           p_source_ver_no       IN         NUMBER,
           p_sorce_item_id       IN         NUMBER,
           p_source_rev_id       IN         NUMBER,
           p_source_org_id       IN         NUMBER,
           p_dest_icc_id         IN         NUMBER,
           p_dest_ver_no         IN         NUMBER,
           p_dest_item_id        IN         NUMBER,
           p_dest_rev_id         IN         NUMBER,
           p_dest_org_id         IN         NUMBER,
           p_init_msg_list       IN         BOOLEAN,  --- Bug 9791391, made default true in spec to maintain existing TA code
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2)
IS
  l_api_name            CONSTANT VARCHAR2(30) := 'Copy_Transaction_Attribute';
  /* Declaring local parameters*/
 /* l_association_id      EGO_TRANS_ATTR_VERS_B.ASSOCIATION_ID%TYPE;
  l_attr_id             EGO_TRANS_ATTR_VERS_B.ATTR_ID%TYPE;
  l_item_cat_group_id   EGO_TRANS_ATTR_VERS_B.ITEM_CATALOG_GROUP_ID%TYPE:=p_item_cat_group_id;
  l_icc_version_number  NUMBER:=p_version_number;

  CURSOR cur_tran_attr_vers
    IS
    SELECT *
                   FROM EGO_TRANS_ATTR_VERS_B
                      WHERE ITEM_CATALOG_GROUP_ID=l_item_cat_group_id
            AND ICC_VERSION_NUMBER =0;*/
BEGIN
  --Reset all global variables
  IF p_init_msg_list THEN     --- BUG 9791391 added if condition
    FND_MSG_PUB.Initialize;
  END IF;


  IF (p_sorce_item_id IS NOT NULL AND p_source_rev_id IS NOT NULL AND p_source_org_id IS NOT NULL ) THEN
    INSERT INTO EGO_TRANS_ATTR_VERS_B
        (SELECT  association_id,attr_id,icc_version_number,attr_display_name,SEQUENCE,value_set_id,uom_class,
                default_value,rejected_value,required_flag,readonly_flag,hidden_flag,searchable_flag,
                check_eligibility,p_dest_item_id,p_dest_org_id,p_dest_rev_id,'ITM',G_CURRENT_USER_ID,
                sysdate,G_CURRENT_USER_ID,SYSDATE,G_CURRENT_LOGIN_ID,program_application_id,
                program_id,program_update_date,request_id,item_catalog_group_id
        FROM EGO_TRANS_ATTR_VERS_B
        WHERE inventory_item_id =p_sorce_item_id
            AND organization_id =p_source_org_id
            AND revision_id=  p_source_rev_id);
  /*When icc_id and ver_id is passed*/
  ELSIF (p_source_icc_id IS NOT NULL AND p_source_ver_no IS NOT NULL) THEN
    INSERT INTO EGO_TRANS_ATTR_VERS_B
        (SELECT association_id,attr_id,p_dest_ver_no,attr_display_name,SEQUENCE,value_set_id,uom_class,
                default_value,rejected_value,required_flag,readonly_flag,hidden_flag,searchable_flag,
                check_eligibility,inventory_item_id,organization_id,revision_id,'ICC',G_CURRENT_USER_ID,
                sysdate,G_CURRENT_USER_ID,SYSDATE,G_CURRENT_LOGIN_ID,program_application_id,
                program_id,program_update_date,request_id,p_dest_icc_id
        FROM EGO_TRANS_ATTR_VERS_B
        WHERE ITEM_CATALOG_GROUP_ID =p_source_icc_id
            AND ICC_VERSION_NUMBER = p_source_ver_no);

  END IF;

EXCEPTION
WHEN OTHERS THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                                 ,p_count   => x_msg_count
                                 ,p_data    => x_msg_data);

END;


/* procedure to copy data from source Id's to destination Id's*/
PROCEDURE Revert_Transaction_Attribute (
           p_source_icc_id       IN         NUMBER,
           p_source_ver_no       IN         NUMBER,
           p_init_msg_list       IN         BOOLEAN,  --- Bug 9791391, made default true in spec to maintain existing TA code
           x_return_status       OUT NOCOPY VARCHAR2,
           x_msg_count           OUT NOCOPY NUMBER,
           x_msg_data            OUT NOCOPY VARCHAR2)
IS

  l_api_name            CONSTANT VARCHAR2(30) := 'Revert_Transaction_Attribute';

BEGIN
  --Reset all global variables
  IF p_init_msg_list THEN       --- Bug 9791391 , added IF condition
      FND_MSG_PUB.Initialize;
  END IF;


  DELETE FROM EGO_TRANS_ATTR_VERS_B
  WHERE ITEM_CATALOG_GROUP_ID = p_source_icc_id
    AND ICC_VERSION_NUMBER    = 0;

   Copy_Transaction_Attribute (
            p_source_icc_id   => p_source_icc_id
           ,p_source_ver_no   => p_source_ver_no
           ,p_sorce_item_id   => NULL
           ,p_source_rev_id   => NULL
           ,p_source_org_id   => NULL
           ,p_dest_icc_id     => p_source_icc_id
           ,p_dest_ver_no     => 0
           ,p_dest_item_id    => NULL
           ,p_dest_rev_id     => NULL
           ,p_dest_org_id     => NULL
           ,x_return_status   => x_return_status
           ,x_msg_count       => x_msg_count
           ,x_msg_data        => x_msg_data
           );


EXCEPTION
   WHEN OTHERS
   THEN
        x_return_status := G_STATUS_ERROR;
        FND_MESSAGE.Set_Name('EGO', 'EGO_PLSQL_ERR');
        FND_MESSAGE.Set_Token('PKG_NAME', G_PKG_NAME);
        FND_MESSAGE.Set_Token('API_NAME', l_api_name);
        FND_MESSAGE.Set_Token('SQL_ERR_MSG', SQLERRM);
        FND_MSG_PUB.Add;
        FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE
                               ,p_count   => x_msg_count
                               ,p_data    => x_msg_data);
END;


/* Function will return true if a Value Set was passed in is not compatible with
 the data type  */
FUNCTION Check_VS_Data_Type (
        p_value_set_id  IN NUMBER,
        p_data_type     IN VARCHAR2
)
RETURN BOOLEAN
  IS
    l_value_set_id               NUMBER:=p_value_set_id;
    l_ta_invalid_vs_data_type    BOOLEAN := FALSE;
    l_value_set_format_code      VARCHAR2(1);
    l_vs_valid_data_type         NUMBER:=0;

BEGIN

    SELECT Count(*) cnt
        INTO l_vs_valid_data_type
          FROM EGO_VS_FORMAT_CODES_V
            WHERE lookup_code IN (p_data_type);

    IF (l_vs_valid_data_type=0) THEN
       l_ta_invalid_vs_data_type:=FALSE;
    ELSE
       l_ta_invalid_vs_data_type:=TRUE ;
    END IF ;


   -------------------------------------------------------------------------------------
    -- Make sure that if a Value Set was passed in, it's compatible with the data type --
    -------------------------------------------------------------------------------------
    SELECT FORMAT_TYPE
          INTO l_value_set_format_code
          FROM FND_FLEX_VALUE_SETS
            WHERE FLEX_VALUE_SET_ID = l_value_set_id;

    IF (l_value_set_format_code IS NULL OR  (l_value_set_format_code <> p_data_type))
    THEN
        l_ta_invalid_vs_data_type:=FALSE;
    ELSE
        l_ta_invalid_vs_data_type:= TRUE;
    END IF;

    RETURN l_ta_invalid_vs_data_type;

END Check_VS_Data_Type;

/* Function to get attribute display name for passed in parameter. */

FUNCTION GET_ATTR_DISP_NAME (
                            P_ITEM_CAT_GROUP_ID  IN          NUMBER,
                            P_ICC_VERSION_NUMBER IN          NUMBER,
                            P_INVENTORY_ITEM_ID  IN          NUMBER DEFAULT NULL,
                            P_ORGANIZATION_ID    IN          NUMBER DEFAULT NULL,
                            P_REVISION_ID        IN          NUMBER DEFAULT NULL,
                            P_CREATION_DATE      IN          DATE   DEFAULT NULL,
                            P_START_DATE         IN          DATE   DEFAULT NULL,
                            P_ATTR_ID            IN          NUMBER
                            )
RETURN VARCHAR2
IS
    l_dynamic_sql        VARCHAR2(4000):=NULL;
    l_attr_disp_name_sql VARCHAR2(4000):=NULL;
    l_attr_disp_name     VARCHAR2(80)  :=NULL;
BEGIN
  l_attr_disp_name_sql := ' SELECT ATTR_DISPLAY_NAME FROM (';
  l_dynamic_sql :=
                ' SELECT * '||
                ' FROM  '||
                ' ( SELECT  *   '||
                '   FROM '||
                '   ( SELECT TA_VERS.item_catalog_group_id,  '||
                '            TA_VERS.ICC_VERSION_NUMBER   ,  '||
                '            TA_VERS.ATTR_ID              ,  '||
                '            TA_VERS.attr_display_name    ,  '||
                '            TA_VERS.metadata_level       ,  '||
                '            TA_VERS.INVENTORY_ITEM_ID    , '||
                '            TA_VERS.ORGANIZATION_ID      ,   '||
                '            TA_VERS.REVISION_ID          , '||
                '            TA_VERS.VALUE_SET_ID         , '||
                '            HIERLEVEL.lev                   '||
                '     FROM   EGO_TRANS_ATTR_VERS_B TA_VERS  ,   '||
                '     ( SELECT ITEM_CATALOG_GROUP_ID ,    '||
                '              LEVEL LEV                 '||
                '       FROM    MTL_ITEM_CATALOG_GROUPS_B  '||
                '        START WITH ITEM_CATALOG_GROUP_ID =:1    '||
                '        CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID    '||
                '     ) HIERLEVEL                        '||
                '     WHERE   HIERLEVEL.ITEM_CATALOG_GROUP_ID = TA_VERS.item_catalog_group_id    '||
                '   )          '||
                '   WHERE      '||
                '   (         '||
                '         (   '||
                '            LEV                = 1 '||
                '            AND ICC_VERSION_NUMBER = :2            '||
                '         )                   '||
                '         OR       '||
                '         (          '||
                '            METADATA_LEVEL    = ''ITM'''||
                '            AND INVENTORY_ITEM_ID = :3         '||
                '            AND ORGANIZATION_ID   = :4            '||
                '            AND REVISION_ID       = :5                 '||
                '         )                                                         '||
                '         OR                                  '||
                '         (                                   '||
                '            LEV           > 1            '||
                '            AND metadata_level=''ICC'''||
                '            AND                               '||
                '            (                  '||
                '               item_catalog_group_id, ICC_VERSION_NUMBER      '||
                '            )                   '||
                '            IN            '||
                '            ( SELECT item_catalog_group_id,VERSION_SEQ_ID     '||
                '              FROM    EGO_MTL_CATALOG_GRP_VERS_B                ';

  IF (P_ICC_VERSION_NUMBER =0 ) THEN
     l_dynamic_sql := l_dynamic_sql ||
                '              WHERE start_active_date <= :6       '||
                '               AND                      '||
                '               (                  '||
                '                  end_active_date IS NULL               '||
                '                  OR end_active_date>=:7                    '||
                '               )                 ';
  ELSE
    l_dynamic_sql := l_dynamic_sql ||
                '              WHERE                  '||
                '              (                      '||
                '                item_catalog_group_id,start_active_date          '||
                '              )                      '||
                '              IN       '||
                '              ( SELECT  item_catalog_group_id, MAX(start_active_date) start_active_date       '||
                '                FROM   EGO_MTL_CATALOG_GRP_VERS_B                     '||
                '                WHERE  creation_date     <= :6   '||
                '                  AND version_seq_id     > 0                     '||
                '                  AND start_active_date <= :7  '||
                '                GROUP BY item_catalog_group_id                     '||
                '                HAVING   MAX(start_active_date)<=:8 '||
                '              )              ';
  END IF;
/*  l_value_set_sql:= l_dynamic_sql ||
                '              AND version_seq_id > 0               '||
                '            )    '||
                '         )         '||
                '   )         '||
                '   ORDER BY METADATA_LEVEL DESC ,LEV ASC    '||
                ' )         '||
                ' WHERE   attr_id = :9 --ATTRS.attr_id   '||
                ' AND ROWNUM<2    '  ;  */
  l_dynamic_sql := l_dynamic_sql ||
                '              AND version_seq_id > 0               '||
                '            )    '||
                '         )         '||
                '   )         '||
                '   ORDER BY METADATA_LEVEL DESC ,LEV ASC    '||
                ' )         ';

  IF (P_ICC_VERSION_NUMBER =0 ) THEN
     l_dynamic_sql := l_dynamic_sql ||
                ' WHERE   attr_id  =:8';
  ELSE
     l_dynamic_sql := l_dynamic_sql ||
                ' WHERE   attr_id  =:9';
  END IF;
  l_dynamic_sql := l_dynamic_sql ||
                '             ORDER BY METADATA_LEVEL DESC ,LEV ASC    )  ';


  l_attr_disp_name_sql:= l_attr_disp_name_sql||l_dynamic_sql ||
                ' WHERE ATTR_DISPLAY_NAME IS NOT NULL       '||
                ' AND ROWNUM<2    '  ;

  IF (P_ICC_VERSION_NUMBER =0 ) THEN
      EXECUTE IMMEDIATE l_attr_disp_name_sql INTO  l_attr_disp_name
                                             USING P_ITEM_CAT_GROUP_ID,
                                                   P_ICC_VERSION_NUMBER,
                                                   P_INVENTORY_ITEM_ID,
                                                   P_ORGANIZATION_ID,
                                                   P_REVISION_ID,
                                                   P_START_DATE,
                                                   P_START_DATE,
                                                   P_ATTR_ID;
  ELSE
      EXECUTE IMMEDIATE l_attr_disp_name_sql INTO  l_attr_disp_name
                                             USING P_ITEM_CAT_GROUP_ID,
                                                   P_ICC_VERSION_NUMBER,
                                                   P_INVENTORY_ITEM_ID,
                                                   P_ORGANIZATION_ID,
                                                   P_REVISION_ID,
                                                   P_CREATION_DATE,
                                                   P_START_DATE,
                                                   P_START_DATE,
                                                   P_ATTR_ID;
  END IF;
  RETURN L_ATTR_DISP_NAME;
END;



/* Function to get value set id associated to a transaction attribute for passed in parameter. */
FUNCTION GET_VS_ID (
                            P_ITEM_CAT_GROUP_ID  IN          NUMBER,
                            P_ICC_VERSION_NUMBER IN          NUMBER,
                            P_INVENTORY_ITEM_ID  IN          NUMBER DEFAULT NULL,
                            P_ORGANIZATION_ID    IN          NUMBER DEFAULT NULL,
                            P_REVISION_ID        IN          NUMBER DEFAULT NULL,
                            P_CREATION_DATE      IN          DATE   DEFAULT NULL,
                            P_START_DATE         IN          DATE   DEFAULT NULL,
                            P_ATTR_ID            IN          NUMBER
                            )
RETURN NUMBER
IS
    l_dynamic_sql        VARCHAR2(4000):=NULL;
    l_value_set_sql      VARCHAR2(4000):=NULL;
    l_value_set_id       NUMBER        :=NULL;
BEGIN
  l_value_set_sql := ' SELECT VALUE_SET_ID FROM (';
  l_dynamic_sql :=
                ' SELECT * '||
                ' FROM  '||
                ' ( SELECT  *   '||
                '   FROM '||
                '   ( SELECT TA_VERS.item_catalog_group_id,  '||
                '            TA_VERS.ICC_VERSION_NUMBER   ,  '||
                '            TA_VERS.ATTR_ID              ,  '||
                '            TA_VERS.attr_display_name    ,  '||
                '            TA_VERS.metadata_level       ,  '||
                '            TA_VERS.INVENTORY_ITEM_ID    , '||
                '            TA_VERS.ORGANIZATION_ID      ,   '||
                '            TA_VERS.REVISION_ID          , '||
                '            TA_VERS.VALUE_SET_ID         , '||
                '            HIERLEVEL.lev                   '||
                '     FROM   EGO_TRANS_ATTR_VERS_B TA_VERS  ,   '||
                '     ( SELECT ITEM_CATALOG_GROUP_ID ,    '||
                '              LEVEL LEV                 '||
                '       FROM    MTL_ITEM_CATALOG_GROUPS_B  '||
                '        START WITH ITEM_CATALOG_GROUP_ID =:1    '||
                '        CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID    '||
                '     ) HIERLEVEL                        '||
                '     WHERE   HIERLEVEL.ITEM_CATALOG_GROUP_ID = TA_VERS.item_catalog_group_id    '||
                '   )          '||
                '   WHERE      '||
                '   (         '||
                '         (   '||
                '            LEV                = 1 '||
                '            AND ICC_VERSION_NUMBER = :2            '||
                '         )                   '||
                '         OR       '||
                '         (          '||
                '            METADATA_LEVEL    = ''ITM'''||
                '            AND INVENTORY_ITEM_ID = :3         '||
                '            AND ORGANIZATION_ID   = :4            '||
                '            AND REVISION_ID       = :5                 '||
                '         )                                                         '||
                '         OR                                  '||
                '         (                                   '||
                '            LEV           > 1            '||
                '            AND metadata_level=''ICC'''||
                '            AND                               '||
                '            (                  '||
                '               item_catalog_group_id, ICC_VERSION_NUMBER      '||
                '            )                   '||
                '            IN            '||
                '            ( SELECT item_catalog_group_id,VERSION_SEQ_ID     '||
                '              FROM    EGO_MTL_CATALOG_GRP_VERS_B                ';

  IF (P_ICC_VERSION_NUMBER =0 ) THEN
     l_dynamic_sql := l_dynamic_sql ||
                '              WHERE start_active_date <= :6       '||
                '               AND                      '||
                '               (                  '||
                '                  end_active_date IS NULL               '||
                '                  OR end_active_date>=:7                    '||
                '               )                 ';
  ELSE
    l_dynamic_sql := l_dynamic_sql ||
                '              WHERE                  '||
                '              (                      '||
                '                item_catalog_group_id,start_active_date          '||
                '              )                      '||
                '              IN       '||
                '              ( SELECT  item_catalog_group_id, MAX(start_active_date) start_active_date       '||
                '                FROM   EGO_MTL_CATALOG_GRP_VERS_B                     '||
                '                WHERE  creation_date     <= :6   '||
                '                  AND version_seq_id     > 0                     '||
                '                  AND start_active_date <= :7  '||
                '                GROUP BY item_catalog_group_id                     '||
                '                HAVING   MAX(start_active_date)<=:8 '||
                '              )              ';
  END IF;
/*  l_value_set_sql:= l_dynamic_sql ||
                '              AND version_seq_id > 0               '||
                '            )    '||
                '         )         '||
                '   )         '||
                '   ORDER BY METADATA_LEVEL DESC ,LEV ASC    '||
                ' )         '||
                ' WHERE   attr_id = :9 --ATTRS.attr_id   '||
                ' AND ROWNUM<2    '  ;  */
  l_dynamic_sql := l_dynamic_sql ||
                '              AND version_seq_id > 0               '||
                '            )    '||
                '         )         '||
                '   )         '||
                '   ORDER BY METADATA_LEVEL DESC ,LEV ASC    '||
                ' )         ';


  IF (P_ICC_VERSION_NUMBER =0 ) THEN
     l_dynamic_sql := l_dynamic_sql ||
                ' WHERE   attr_id  =:8';
  ELSE
     l_dynamic_sql := l_dynamic_sql ||
                ' WHERE   attr_id  =:9';
  END IF;
  l_dynamic_sql := l_dynamic_sql ||
                '             ORDER BY METADATA_LEVEL DESC ,LEV ASC    )  ';

  l_value_set_sql:= l_value_set_sql||l_dynamic_sql ||
                ' WHERE ROWNUM<2    '  ;

  IF (P_ICC_VERSION_NUMBER =0 ) THEN
      EXECUTE IMMEDIATE l_value_set_sql INTO  l_value_set_id
                                             USING P_ITEM_CAT_GROUP_ID,
                                                   P_ICC_VERSION_NUMBER,
                                                   P_INVENTORY_ITEM_ID,
                                                   P_ORGANIZATION_ID,
                                                   P_REVISION_ID,
                                                   P_START_DATE,
                                                   P_START_DATE,
                                                   P_ATTR_ID;
  ELSE
      EXECUTE IMMEDIATE l_value_set_sql INTO  l_value_set_id
                                             USING P_ITEM_CAT_GROUP_ID,
                                                   P_ICC_VERSION_NUMBER,
                                                   P_INVENTORY_ITEM_ID,
                                                   P_ORGANIZATION_ID,
                                                   P_REVISION_ID,
                                                   P_CREATION_DATE,
                                                   P_START_DATE,
                                                   P_START_DATE,
                                                   P_ATTR_ID;

  END IF;
  RETURN L_VALUE_SET_ID;
END;

PROCEDURE has_invalid_char (
                              p_internal_name  IN VARCHAR2,
                              x_has_invalid_chars OUT  NOCOPY VARCHAR2
)IS
   l_internal_name varchar2(1000);
   l_counter number :=0;
   l_curr_char varchar2(1);
BEGIN
    l_internal_name:=p_internal_name;
    IF (l_internal_name IS null) THEN
       x_has_invalid_chars :='N';
    END IF;
    l_internal_name:=trim(l_internal_name);
    WHILE(l_counter <=length(l_internal_name)) loop
      l_curr_char:=SubStr(l_internal_name, l_counter,1);
      IF  (regexp_like(l_curr_char, '[0-9a-zA-Z_]')) THEN
         l_counter:=l_counter+1;
         x_has_invalid_chars := 'N';
      ELSE
          x_has_invalid_chars :='Y';
          exit;
      END IF;
    END LOOP;
EXCEPTION
    WHEN OTHERS THEN
          x_has_invalid_chars:='N';
          NULL;
END has_invalid_char;


/*API will return the record of transaction attribute metadata based on given input.It will return null
if given input is invalid */
PROCEDURE GET_TRANS_ATTR_METADATA(             x_ta_metadata_tbl OUT NOCOPY  EGO_TRAN_ATTR_TBL,
                                               p_item_catalog_category_id IN number,
                                               p_icc_version IN number,
                                               p_attribute_id IN NUMBER,
                                               p_inventory_item_id IN NUMBER ,
                                               p_organization_id   IN NUMBER,
                                               p_revision_id     IN NUMBER  ,
                                               x_return_status  OUT NOCOPY VARCHAR2 ,
                                               x_is_inherited   OUT  NOCOPY VARCHAR2  ,
                                               x_is_modified   OUT  NOCOPY varchar2
                                            )

                                            IS

         l_item_catalog_group_id       VARCHAR2(10);
         l_efectivity_date             DATE ; /*Item revision effective date.*/
         l_creation_date               DATE;-- MTL_ITEM_REVISIONS_VL.CREATION_DATE
         l_icc_start_date              DATE ;/*ICC start effective date*/
         l_start_active_date           DATE ;/*ICC start effective date*/
         l_icc_create_date             DATE ;/*ICC create  date*/
         l_version_seq_id              VARCHAR2(5);
         l_max_start_date              DATE;
         l_exception                   EXCEPTION;
         l_associationid               VARCHAR2(5);
         l_ATTRID                      NUMBER:=0;
         l_icc_version_number          VARCHAR2(15);
         l_Value_Set_Id                VARCHAR2(15);
         l_uom_class                   VARCHAR2(10);
         l_ta_metadata_tbl             EGO_TRAN_ATTR_TBL;
         l_default_value               VARCHAR2(2000);
         l_rejectedvalue               VARCHAR2(2000);
         l_required                    VARCHAR2(1);
         l_readonlyflag                VARCHAR2(1);
         l_hiddenflag                 VARCHAR2(1);
         l_searchable                 VARCHAR2(1);
         l_checkeligibility           VARCHAR2(1);
         l_organization_id            VARCHAR2(10);
         l_metadatalevel              VARCHAR2(10);
         l_attr_disp_name             VARCHAR2(80);
         l_no_of_rows                 NUMBER;
         l_level                      VARCHAR2(50);
   l_value_set_name             VARCHAR2(60); -- Bug 8643860
         l_attr_seq                   NUMBER;   -- Bug 8643860


  CURSOR get_Item_TA_metadata(
                                v_ITEM_CATALOG_GROUP_ID in NUMBER,
                                v_attr_id   in number,
                                v_INVENTORY_ITEM_ID in number,
                                v_ORGANIZATION_ID in number,
                                v_REVISION_ID in number,
                                v_creation_date in date,
                                v_start_active_date in date,
                                v_max_start_active_date in date
   ) IS

      SELECT * FROM
         ( SELECT versions.item_catalog_group_id,
           versions.ICC_VERSION_NUMBER    ,
           versions.ATTR_ID               ,
           versions.attr_display_name     ,
           versions.SEQUENCE              , -- Bug 8643860
           versions.metadata_level        ,
           versions.association_id        ,
           VERSIONS.VALUE_SET_ID          ,
           VERSIONS.UOM_CLASS             ,
           VERSIONS.DEFAULT_VALUE         ,
           versions.revision_id           ,
           versions.organization_id       ,
           versions.inventory_item_id     ,
           VERSIONS.REJECTED_VALUE        ,
           VERSIONS.REQUIRED_FLAG         ,
           VERSIONS.READONLY_FLAG         ,
           VERSIONS.HIDDEN_FLAG           ,
           VERSIONS.SEARCHABLE_FLAG       ,
           VERSIONS.CHECK_ELIGIBILITY     ,
           Hier.lev
         FROM    EGO_TRANS_ATTR_VERS_B VERSIONS,
           (SELECT ITEM_CATALOG_GROUP_ID , LEVEL LEV
                   FROM  MTL_ITEM_CATALOG_GROUPS_B START WITH ITEM_CATALOG_GROUP_ID = v_ITEM_CATALOG_GROUP_ID CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
           ) HIER
                 WHERE   HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id  AND versions.attr_id  = v_attr_id )
    WHERE
         ( (LEV =1   AND ICC_VERSION_NUMBER  = l_version_seq_id AND METADATA_LEVEL  = 'ICC' )
        OR
           (
            METADATA_LEVEL    = 'ITM'   AND
            INVENTORY_ITEM_ID = v_INVENTORY_ITEM_ID AND
            ORGANIZATION_ID   = v_ORGANIZATION_ID AND
            REVISION_ID       = v_REVISION_ID
           )
        OR
           (
            LEV  > 1  AND
           metadata_level='ICC'
        AND
            (
             item_catalog_group_id, ICC_VERSION_NUMBER
            )
            IN
            ( SELECT item_catalog_group_id,VERSION_SEQ_ID
              FROM    EGO_MTL_CATALOG_GRP_VERS_B
              WHERE
                  (
                    item_catalog_group_id,start_active_date
                  )
              IN
                 (SELECT  item_catalog_group_id,MAX(start_active_date) start_active_date
                  FROM     EGO_MTL_CATALOG_GRP_VERS_B
                  WHERE    creation_date     <= v_creation_date
                  AND version_seq_id     > 0
                  AND start_active_date <= v_start_active_date
                  GROUP BY item_catalog_group_id
                  HAVING   MAX(start_active_date)<= v_max_start_active_date
                )
          AND version_seq_id > 0
            )
           )   );

   get_Item_TA_metadata_rec      get_Item_TA_metadata%ROWTYPE;

    CURSOR get_ICC_TA_metadata(
                                  v_ITEM_CATALOG_GROUP_ID in NUMBER,
                                  v_attr_id   in number,
                      v_creation_date in date,
                      v_start_active_date in date,
                      v_max_start_active_date in date
   ) IS

      SELECT * FROM
         ( SELECT versions.item_catalog_group_id,
           versions.ICC_VERSION_NUMBER    ,
           versions.ATTR_ID               ,
           versions.attr_display_name     ,
           versions.SEQUENCE              , -- Bug 8643860
           versions.metadata_level        ,
           versions.association_id        ,
           VERSIONS.VALUE_SET_ID          ,
           VERSIONS.UOM_CLASS             ,
           VERSIONS.DEFAULT_VALUE         ,
           versions.revision_id           ,
           versions.organization_id       ,
           versions.inventory_item_id     ,
           VERSIONS.REJECTED_VALUE        ,
           VERSIONS.REQUIRED_FLAG         ,
           VERSIONS.READONLY_FLAG         ,
           VERSIONS.HIDDEN_FLAG           ,
           VERSIONS.SEARCHABLE_FLAG       ,
           VERSIONS.CHECK_ELIGIBILITY     ,
           Hier.lev
         FROM    EGO_TRANS_ATTR_VERS_B VERSIONS,
           (SELECT ITEM_CATALOG_GROUP_ID , LEVEL LEV
                   FROM  MTL_ITEM_CATALOG_GROUPS_B START WITH ITEM_CATALOG_GROUP_ID = v_ITEM_CATALOG_GROUP_ID CONNECT BY PRIOR PARENT_CATALOG_GROUP_ID =ITEM_CATALOG_GROUP_ID
           ) HIER
                 WHERE   HIER.ITEM_CATALOG_GROUP_ID = versions.item_catalog_group_id  AND versions.attr_id  = v_attr_id )
    WHERE
         ( (LEV =1   AND ICC_VERSION_NUMBER  = p_icc_version AND METADATA_LEVEL  = 'ICC' )

        OR
           (
            LEV           > 1
        AND metadata_level='ICC'
        AND
            (
             item_catalog_group_id, ICC_VERSION_NUMBER
            )
            IN
            ( SELECT item_catalog_group_id,
              VERSION_SEQ_ID
            FROM    EGO_MTL_CATALOG_GRP_VERS_B
            WHERE
              (
                item_catalog_group_id,start_active_date
              )
              IN
              (SELECT  item_catalog_group_id,
                 MAX(start_active_date) start_active_date
              FROM     EGO_MTL_CATALOG_GRP_VERS_B
              WHERE    creation_date     <= v_creation_date
             AND version_seq_id     > 0
             AND start_active_date <= v_start_active_date
              GROUP BY item_catalog_group_id
              HAVING   MAX(start_active_date)<= v_max_start_active_date
              )
          AND version_seq_id > 0
            )
           )
           );
   get_ICC_TA_metadata_rec      get_ICC_TA_metadata%ROWTYPE;

BEGIN
        x_ta_metadata_tbl := EGO_TRAN_ATTR_TBL(NULL);
        x_is_inherited := 'N';
        x_is_modified := 'N';
         IF(p_attribute_id IS null) THEN
                 RAISE l_exception  ;
         END IF ;

  IF(p_inventory_item_id IS NOT NULL AND p_organization_id IS NOT NULL AND p_revision_id IS NOT null)
       THEN
          x_is_inherited := 'Y';
          --Finding which ICC is associated ot the item.
          SELECT ITEM_CATALOG_GROUP_ID INTO  l_item_catalog_group_id FROM MTL_SYSTEM_ITEMS_VL
                    WHERE INVENTORY_ITEM_ID = p_inventory_item_id AND ORGANIZATION_ID = p_organization_id ;

         IF(l_ITEM_CATALOG_GROUP_ID IS NULL ) THEN
                     RAISE l_exception  ;
          ELSE
                  SELECT  EFFECTIVITY_DATE  ,CREATION_DATE INTO l_efectivity_date,l_creation_date
                       FROM  MTL_ITEM_REVISIONS_VL WHERE   INVENTORY_ITEM_ID = p_inventory_item_id
                       AND   ORGANIZATION_ID = p_organization_id    AND  REVISION_ID =  p_revision_id;

                --Finding out which ICC version is effective at a time of item creation.

             SELECT  VERSION_SEQ_ID INTO l_version_seq_id FROM EGO_MTL_CATALOG_GRP_VERS_B
             WHERE   (ITEM_CATALOG_GROUP_ID, start_active_date) IN
                     (

                    SELECT  ITEM_CATALOG_GROUP_ID,Max(START_ACTIVE_DATe) START_ACTIVE_DATe
                    FROM    EGO_MTL_CATALOG_GRP_VERS_B
                    WHERE   CREATION_DATE <= l_creation_date AND
                            ITEM_CATALOG_GROUP_ID = l_item_catalog_group_id AND
                            START_ACTIVE_DATE <= l_efectivity_date AND VERSION_SEQ_ID >0
                    GROUP BY ITEM_CATALOG_GROUP_ID
                    HAVING MAX(START_ACTIVE_DATE) <= l_efectivity_date
      )    ;
              /*bug 8767080
              --Finding out start effcetive date and creation date of ICC Version
                SELECT  START_ACTIVE_DATE,CREATION_DATE INTO l_icc_start_date, l_icc_create_date
                       FROM  EGO_MTL_CATALOG_GRP_VERS_B
                       WHERE ITEM_CATALOG_GROUP_ID = l_item_catalog_group_id  AND   VERSION_SEQ_ID =  l_version_seq_id;
              */
          END IF;

    OPEN get_Item_TA_metadata(
                                v_ITEM_CATALOG_GROUP_ID => l_item_catalog_group_id,
                                v_attr_id  =>p_attribute_id,
                                v_INVENTORY_ITEM_ID =>p_inventory_item_id,
                                v_ORGANIZATION_ID => p_organization_id,
                                v_REVISION_ID => p_revision_id,
                                v_creation_date =>l_creation_date,      --bug 8767080
                                v_start_active_date => l_efectivity_date,       --bug 8767080
                                v_max_start_active_date =>  l_efectivity_date       --bug 8767080
        )     ;

      LOOP
            FETCH get_Item_TA_metadata INTO get_Item_TA_metadata_rec;
               EXIT WHEN get_Item_TA_metadata%NOTFOUND;

            IF(get_Item_TA_metadata_rec.association_id is not null  )      THEN
                  l_associationid :=   get_Item_TA_metadata_rec.association_id;
            END IF;


          IF(get_Item_TA_metadata_rec.ATTR_ID is not null  )    THEN
                  l_ATTRID := get_Item_TA_metadata_rec.ATTR_ID  ;
              END IF;

          IF(get_Item_TA_metadata_rec.ICC_VERSION_NUMBER is not null AND l_icc_version_number IS null )    THEN
                  l_icc_version_number := get_Item_TA_metadata_rec.ICC_VERSION_NUMBER  ;
            END IF;
          if(get_Item_TA_metadata_rec.VALUE_SET_ID is not null AND l_Value_Set_Id IS null )       THEN
                  l_Value_Set_Id := get_Item_TA_metadata_rec.VALUE_SET_ID  ;

                  -- Bug 8643860
                  SELECT FLEX_VALUE_SET_NAME INTO l_value_set_name
                  FROM FND_FLEX_VALUE_SETS
                  WHERE FLEX_VALUE_SET_ID = l_Value_Set_Id;
            END IF;

            IF(get_Item_TA_metadata_rec.UOM_CLASS is not NULL AND l_uom_class IS null  )       THEN
                  l_uom_class := get_Item_TA_metadata_rec.UOM_CLASS  ;
            END IF;

            IF(get_Item_TA_metadata_rec.DEFAULT_VALUE is not NULL AND l_default_value IS null   )  THEN
                l_default_value := get_Item_TA_metadata_rec.DEFAULT_VALUE  ;
            END IF;

             if(get_Item_TA_metadata_rec.REJECTED_VALUE is not null AND l_rejectedvalue IS null )     THEN
              l_rejectedvalue   := get_Item_TA_metadata_rec.REJECTED_VALUE  ;
            END IF;

            IF(get_Item_TA_metadata_rec.REQUIRED_FLAG is not null AND l_required IS null)     THEN
                l_required := get_Item_TA_metadata_rec.REQUIRED_FLAG  ;
            END IF;


            IF(get_Item_TA_metadata_rec.READONLY_FLAG is not null AND l_readonlyflag IS null)    THEN
              l_readonlyflag     := get_Item_TA_metadata_rec.READONLY_FLAG  ;
            END IF;

            IF(get_Item_TA_metadata_rec.HIDDEN_FLAG is not null AND l_hiddenflag IS null )     THEN
                l_hiddenflag := get_Item_TA_metadata_rec.HIDDEN_FLAG  ;
           END IF;

          IF(get_Item_TA_metadata_rec.SEARCHABLE_FLAG is not null  AND l_searchable IS null)     THEN
              l_searchable  := get_Item_TA_metadata_rec.SEARCHABLE_FLAG  ;
            END IF;

          IF(get_Item_TA_metadata_rec.CHECK_ELIGIBILITY is not NULL AND l_checkeligibility IS null )       THEN
              l_checkeligibility   := get_Item_TA_metadata_rec.CHECK_ELIGIBILITY  ;
          END IF;
          if(get_Item_TA_metadata_rec.organization_id is not NULL AND l_organization_id IS null  )     THEN
            l_organization_id   := get_Item_TA_metadata_rec.organization_id  ;
          END IF;

          IF(get_Item_TA_metadata_rec.metadata_level is not null AND l_metadatalevel IS null)   THEN
                l_metadatalevel := get_Item_TA_metadata_rec.metadata_level  ;

                -- Bug 8643860
                IF (l_metadatalevel = 'ITM') THEN
                  x_is_modified :='Y';
                END IF;

            END IF;

         IF(get_Item_TA_metadata_rec.attr_display_name is not null  AND l_attr_disp_name IS null )  THEN
                l_attr_disp_name  := get_Item_TA_metadata_rec.attr_display_name  ;
            END IF;

          -- Bug 8643860
          IF (get_Item_TA_metadata_rec.SEQUENCE IS NOT NULL AND l_attr_seq is NULL) THEN
            l_attr_seq := get_Item_TA_metadata_rec.SEQUENCE;
          END IF;

         END LOOP;
      CLOSE get_Item_TA_metadata;
   ELSE IF (p_item_catalog_category_id IS NOT NULL AND p_icc_version IS NOT NULL)  THEN
                /*Finding out start effcetive date and creation date of ICC Version */
              SELECT  START_ACTIVE_DATE,CREATION_DATE INTO l_icc_start_date, l_icc_create_date
                     FROM  EGO_MTL_CATALOG_GRP_VERS_B
                     WHERE ITEM_CATALOG_GROUP_ID = p_item_catalog_category_id  AND   VERSION_SEQ_ID =  p_icc_version;

             OPEN GET_ICC_TA_METADATA(
                v_ITEM_CATALOG_GROUP_ID => p_item_catalog_category_id,
                            v_attr_id  =>p_attribute_id,
                v_creation_date =>l_icc_create_date,
                v_start_active_date => l_icc_start_date,
                v_max_start_active_date =>  l_icc_start_date
              )     ;


        LOOP
             FETCH get_ICC_TA_metadata INTO get_ICC_TA_metadata_rec;
             EXIT WHEN get_ICC_TA_metadata%NOTFOUND;

                IF(get_ICC_TA_metadata_rec.association_id is not null  )      THEN
                      l_associationid :=   get_ICC_TA_metadata_rec.association_id;
                END IF;

              IF(get_ICC_TA_metadata_rec.ATTR_ID is not null  )    THEN
                      l_ATTRID := get_ICC_TA_metadata_rec.ATTR_ID  ;
                  END IF;

              IF(get_ICC_TA_metadata_rec.ICC_VERSION_NUMBER is not null AND l_icc_version_number IS null )    THEN
                      l_icc_version_number := get_ICC_TA_metadata_rec.ICC_VERSION_NUMBER  ;
              END IF;
              IF(get_ICC_TA_metadata_rec.VALUE_SET_ID is not null AND l_Value_Set_Id IS null )       THEN
                      l_Value_Set_Id := get_ICC_TA_metadata_rec.VALUE_SET_ID  ;

                      -- Bug 8643860
                      SELECT FLEX_VALUE_SET_NAME INTO l_value_set_name
                      FROM FND_FLEX_VALUE_SETS
                      WHERE FLEX_VALUE_SET_ID = l_Value_Set_Id;
                END IF;


                IF(get_ICC_TA_metadata_rec.UOM_CLASS is not NULL AND l_uom_class IS null  )       THEN
                      l_uom_class := get_ICC_TA_metadata_rec.UOM_CLASS  ;
                END IF;


                IF(get_ICC_TA_metadata_rec.DEFAULT_VALUE is not NULL AND l_default_value IS null   )  THEN
                    l_default_value := get_ICC_TA_metadata_rec.DEFAULT_VALUE  ;
                END IF;

                  IF(get_ICC_TA_metadata_rec.REJECTED_VALUE is not null AND l_rejectedvalue IS null )     THEN
                  l_rejectedvalue   := get_ICC_TA_metadata_rec.REJECTED_VALUE  ;
                END IF;

                IF(get_ICC_TA_metadata_rec.REQUIRED_FLAG is not null AND l_required IS null)     THEN
                    l_required := get_ICC_TA_metadata_rec.REQUIRED_FLAG  ;
                END IF;

                IF(get_ICC_TA_metadata_rec.READONLY_FLAG is not null AND l_readonlyflag IS null)    THEN
                  l_readonlyflag     := get_ICC_TA_metadata_rec.READONLY_FLAG  ;
                END IF;

                IF(get_ICC_TA_metadata_rec.HIDDEN_FLAG is not null AND l_hiddenflag IS null )     THEN
                    l_hiddenflag := get_ICC_TA_metadata_rec.HIDDEN_FLAG  ;
              END IF;

              IF(get_ICC_TA_metadata_rec.SEARCHABLE_FLAG is not null  AND l_searchable IS null)     THEN
                  l_searchable  := get_ICC_TA_metadata_rec.SEARCHABLE_FLAG  ;
                END IF;

                IF(get_ICC_TA_metadata_rec.CHECK_ELIGIBILITY is not NULL AND l_checkeligibility IS null )       THEN
                  l_checkeligibility   := get_ICC_TA_metadata_rec.CHECK_ELIGIBILITY  ;
                END IF;
                IF(get_ICC_TA_metadata_rec.organization_id is not NULL AND l_organization_id IS null  )     THEN
                l_organization_id   := get_ICC_TA_metadata_rec.organization_id  ;
                END IF;

               IF(get_ICC_TA_metadata_rec.lev is not null AND l_level IS null)   THEN
                    l_level := get_ICC_TA_metadata_rec.lev  ;
                      IF(l_level =1 ) THEN
                        x_is_modified :='Y';
                  END IF ;
              END IF;
                IF(get_ICC_TA_metadata_rec.metadata_level is not null AND l_metadatalevel IS null)   THEN
                    l_metadatalevel := get_ICC_TA_metadata_rec.metadata_level  ;
                END IF;

               IF(get_ICC_TA_metadata_rec.attr_display_name is not null  AND l_attr_disp_name IS null )  THEN
                    l_attr_disp_name  := get_ICC_TA_metadata_rec.attr_display_name  ;
               END IF;

               -- Bug 8643860
           -- Bug 9744800 change the get_Item_TA_metadata_rec to get_ICC_TA_metadata_rec
              IF (get_ICC_TA_metadata_rec.SEQUENCE IS NOT NULL AND l_attr_seq is NULL) THEN
                l_attr_seq := get_ICC_TA_metadata_rec.SEQUENCE;
              END IF;

      END LOOP;
      l_no_of_rows := get_ICC_TA_metadata%ROWCOUNT;
        IF(l_no_of_rows >1) THEN
              x_is_inherited := 'y';
          ELSIF (x_is_modified = 'N')  THEN
           x_is_inherited := 'Y';
       END IF      ;
    CLOSE GET_ICC_TA_METADATA;


   ELSE
       RAISE l_exception  ;

    END  if;
  END IF ;
    x_ta_metadata_tbl(1)  := EGO_TRAN_ATTR_REC(
                                        l_associationid,
                                        l_ATTRID,
                                        l_icc_version_number,
                                        p_revision_id,
                                        l_attr_seq,   -- Bug 8643860
                                        l_Value_Set_Id,
                                         l_uom_class,
                                         l_default_value,
                                         l_rejectedvalue,
                                         l_required,
                                         l_readonlyflag,
                                         l_hiddenflag,
                                         l_searchable,
                                         l_checkeligibility,
                                        p_inventory_item_id,
                                        l_organization_id,
                                        l_metadatalevel,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         null,
                                         l_item_catalog_group_id,
                                         null,
                                         l_attr_disp_name,
                                         null,
                                        null ,
                                        l_value_set_name  -- Bug 8643860
                                         );
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'F' ;
END GET_TRANS_ATTR_METADATA;



END EGO_TRANSACTION_ATTRS_PVT;

/
