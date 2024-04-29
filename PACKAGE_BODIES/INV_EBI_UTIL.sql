--------------------------------------------------------
--  DDL for Package Body INV_EBI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EBI_UTIL" AS
/* $Header: INVEIUTLB.pls 120.13.12010000.5 2009/04/06 11:50:41 prepatel ship $ */

/************************************************************************************
--      API name        : is_pim_installed
--      Type            : Public
--      Function        :
************************************************************************************/
FUNCTION is_pim_installed RETURN BOOLEAN IS
  l_pimdl_profile_value FND_PROFILE_OPTION_VALUES.profile_option_value%TYPE;
BEGIN
l_pimdl_profile_value := FND_PROFILE.value('EGO_ENABLE_PIMDL');
IF (l_pimdl_profile_value = 1) THEN
  RETURN TRUE;
ELSE
  RETURN FALSE;
END IF;
EXCEPTION
  WHEN OTHERS THEN
  RETURN FALSE;
END is_pim_installed;

/************************************************************************************
--      API name        : get_config_param_value
--      Type            : Public
--      Function        :
************************************************************************************/
FUNCTION get_config_param_value(
  p_config_tbl        IN inv_ebi_name_value_tbl
 ,p_config_param_name IN VARCHAR2
) RETURN VARCHAR IS
  l_config_param_value  VARCHAR2(2000);
BEGIN
  IF(p_config_tbl IS NOT NULL AND p_config_tbl.COUNT > 0) THEN
    FOR i IN 1..p_config_tbl.COUNT LOOP
      IF (UPPER(p_config_tbl(i).param_name) = UPPER(p_config_param_name))THEN
        l_config_param_value  := p_config_tbl(i).param_value;
        RETURN l_config_param_value;
      END IF;
    END LOOP;
  END IF;
  RETURN NULL;
EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
END get_config_param_value;

/************************************************************************************
 --      API name        : is_master_org
 --      Type            : Public
 --      Function        : FOR ORG ID
 ************************************************************************************/
 FUNCTION is_master_org(
   p_organization_id IN   NUMBER
 ) RETURN VARCHAR IS
   l_master_org NUMBER;
  BEGIN

    SELECT master_organization_id INTO l_master_org
    FROM mtl_parameters
    WHERE organization_id = p_organization_id;

    IF(l_master_org = p_organization_id) THEN
      RETURN FND_API.g_true;
    ELSE
      RETURN FND_API.g_false;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.g_false;
 END is_master_org;

/************************************************************************************
 --      API name        : is_master_org
 --      Type            : Public
 --      Function        : FOR ORG CODE.
 ************************************************************************************/
FUNCTION is_master_org(
   p_organization_code IN   VARCHAR2
 ) RETURN VARCHAR IS
   l_master_org NUMBER;
  BEGIN
        SELECT COUNT(1) INTO l_master_org
        FROM mtl_parameters
        WHERE organization_id = master_organization_id
        AND organization_code = p_organization_code;

    IF(l_master_org > 0) THEN
      RETURN FND_API.g_true;
    ELSE
      RETURN FND_API.g_false;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.g_false;
 END is_master_org;

 /************************************************************************************
 --      API name        : get_master_organization
 --      Type            : Public
 --      Function        :
 ************************************************************************************/
 FUNCTION get_master_organization(
   p_organization_id IN NUMBER
 ) RETURN NUMBER IS
   l_master_org  NUMBER;
 BEGIN

   SELECT master_organization_id INTO l_master_org
   FROM mtl_parameters
   WHERE organization_id = p_organization_id;

   RETURN l_master_org;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
 END get_master_organization;

 /************************************************************************************
  --      API name        : get_error_table
  --      Type            : Public
  --      Function        :
 ************************************************************************************/
 FUNCTION get_error_table RETURN inv_ebi_error_tbl_type IS
   l_error_table              ERROR_HANDLER.error_tbl_type;
   l_inv_ebi_err_tbl          inv_ebi_error_tbl_type;
 BEGIN
   l_inv_ebi_err_tbl := inv_ebi_error_tbl_type();
   ERROR_HANDLER.get_message_list( x_message_list  =>  l_error_table );
     FOR i IN 1..l_error_table.COUNT
     LOOP
       l_inv_ebi_err_tbl.EXTEND(1);
       l_inv_ebi_err_tbl(i)  := inv_ebi_error_rec_type(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
       l_inv_ebi_err_tbl(i).organization_id :=  l_error_table(i).organization_id;
       l_inv_ebi_err_tbl(i).entity_id       :=  l_error_table(i).entity_id;
       l_inv_ebi_err_tbl(i).table_name      :=  l_error_table(i).table_name ;
       l_inv_ebi_err_tbl(i).message_name    :=  l_error_table(i).message_name;
       l_inv_ebi_err_tbl(i).message_text    :=  l_error_table(i).message_text;
       l_inv_ebi_err_tbl(i).entity_index    :=  l_error_table(i).entity_index;
       l_inv_ebi_err_tbl(i).message_type    :=  l_error_table(i).message_type ;
       l_inv_ebi_err_tbl(i).row_identifier  :=  l_error_table(i).row_identifier;
       l_inv_ebi_err_tbl(i).bo_identifier   :=  l_error_table(i).bo_identifier;
     END LOOP;
   RETURN l_inv_ebi_err_tbl;
 EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;
 END get_error_table;


 /************************************************************************************
  --      API name        : get_error_table_msgtxt
  --      Type            : Public
  --      Function        :
 ************************************************************************************/
 FUNCTION get_error_table_msgtxt (
   p_error_table      IN        inv_ebi_error_tbl_type
   )
 RETURN VARCHAR2 IS
   l_msg_text                 VARCHAR2(32000);
   l_part_msg_txt             VARCHAR2(32000);
   l_overflw_msg              VARCHAR2(1) := 'N';
 BEGIN
   IF (p_error_table IS NOT NULL AND p_error_table.COUNT > 0) THEN
     FOR i IN 1..p_error_table.COUNT
     LOOP
       IF (p_error_table(i).message_type IS NULL OR p_error_table(i).message_type <> ERROR_HANDLER.G_STATUS_WARNING) THEN
         l_part_msg_txt := 'Entity Id: '|| p_error_table(i).entity_id ||' Message Text: '||p_error_table(i).message_text;
         IF l_msg_text IS NULL THEN
           l_msg_text := l_part_msg_txt;
         ELSE
           IF LENGTH(l_msg_text || ' , ' ||l_part_msg_txt) <31000 THEN
             l_msg_text := l_msg_text || ' , ' ||l_part_msg_txt;
           ELSE
             l_overflw_msg := 'Y';
             EXIT;
           END IF;
         END IF;
       END IF;
     END LOOP;
   END IF;

   IF (l_overflw_msg = 'Y' AND SUBSTR(l_msg_text,length(l_msg_text)-2) <> '...') THEN
     l_msg_text := l_msg_text ||'...';
   END IF;

   RETURN l_msg_text;

 EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;

 END get_error_table_msgtxt;

/************************************************************************************
  --      API name        : get_attr_group_id
  --      Type            : Private
  --      Function        :
  --      Bug 7240247
 ************************************************************************************/
 FUNCTION  get_attr_group_id(
              p_attr_group_short_name  IN VARCHAR2,
              p_attr_group_app_id      IN NUMBER,
              p_attr_group_type        IN VARCHAR2
 ) RETURN NUMBER IS

 l_attr_group_id NUMBER;

 BEGIN
    SELECT attr_group_id INTO l_attr_group_id
    FROM ego_fnd_dsc_flx_ctx_ext
    WHERE
      descriptive_flex_context_code = p_attr_group_short_name AND
      application_id = p_attr_group_app_id AND
      descriptive_flexfield_name = p_attr_group_type;

    RETURN l_attr_group_id;
 EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;

 END get_attr_group_id;

/************************************************************************************
   --      API name        : get_application_id
   --      Type            : Public
   --      Function        :
   --      Bug 7240247
  ************************************************************************************/
 FUNCTION
 get_application_id(
      p_application_short_name IN VARCHAR2
 ) RETURN NUMBER IS
  l_app_id NUMBER;
 BEGIN

   SELECT application_id INTO l_app_id
   FROM fnd_application
   WHERE
   application_short_name = p_application_short_name;

   RETURN l_app_id;

 EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
 END get_application_id;

/************************************************************************************
 --      API name        : transform_uda
 --      Type            : Public
 --      Function        :
 --
 ************************************************************************************/
  PROCEDURE transform_uda (
    p_uda_input_obj          IN  inv_ebi_uda_input_obj
   ,x_attributes_row_table   OUT NOCOPY ego_user_attr_row_table
   ,x_attributes_data_table  OUT NOCOPY ego_user_attr_data_table
   ,x_return_status          OUT NOCOPY VARCHAR2 --Bug 7240247
   ,x_msg_count              OUT NOCOPY NUMBER
   ,x_msg_data               OUT NOCOPY VARCHAR2
 )
 IS
   l_attributes_row_table   ego_user_attr_row_table;
   l_attributes_data_table  ego_user_attr_data_table;
   l_attribute_group_obj    inv_ebi_uda_attr_grp_obj;
   l_attribute_obj          inv_ebi_uda_attr_obj;
   l_attr_count             NUMBER := 0;
 BEGIN
   x_return_status         := FND_API.G_RET_STS_SUCCESS;
   IF (p_uda_input_obj IS NOT NULL AND p_uda_input_obj.attribute_group_tbl IS NOT NULL AND
     p_uda_input_obj.attribute_group_tbl.COUNT > 0 ) THEN
     l_attributes_row_table  :=  ego_user_attr_row_table();
     l_attributes_data_table  := ego_user_attr_data_table();
     l_attributes_row_table.extend(p_uda_input_obj.attribute_group_tbl.COUNT);
     FOR i IN 1..p_uda_input_obj.attribute_group_tbl.COUNT LOOP
       l_attribute_group_obj  := p_uda_input_obj.attribute_group_tbl(i);

       IF(l_attribute_group_obj.attr_group_app_id IS NULL AND l_attribute_group_obj.application_short_name IS NOT NULL ) THEN

          --Start Bug 7240247
          l_attribute_group_obj.attr_group_app_id := get_application_id(
                                                       p_application_short_name => l_attribute_group_obj.application_short_name
                                                     );
          IF(l_attribute_group_obj.attr_group_app_id IS NULL ) THEN
            FND_MESSAGE.set_name('INV','INV_EBI_APP_INVALID');
            FND_MESSAGE.set_token('COL_VALUE', l_attribute_group_obj.application_short_name);
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
          END IF;
          --End Bug 7240247

       END IF;
       IF(l_attribute_group_obj.attr_group_id IS NULL AND l_attribute_group_obj.attr_group_short_name IS NOT NULL ) THEN

         --Start Bug 7240247
         l_attribute_group_obj.attr_group_id := get_attr_group_id(
                                                   p_attr_group_short_name  => l_attribute_group_obj.attr_group_short_name,
                                                   p_attr_group_app_id      => l_attribute_group_obj.attr_group_app_id,
                                                   p_attr_group_type        => l_attribute_group_obj.attr_group_type
                                                );

         IF(l_attribute_group_obj.attr_group_id IS NULL ) THEN
           FND_MESSAGE.set_name('INV','INV_EBI_ATTR_GROUP_INVALID');
           FND_MESSAGE.set_token('COL_VALUE', l_attribute_group_obj.attr_group_short_name);
           FND_MSG_PUB.add;
           RAISE FND_API.g_exc_error;
         END IF;
         --End Bug 7240247

       END IF;
       l_attributes_row_table(i) := EGO_USER_ATTRS_DATA_PUB.build_attr_group_row_object(
                                   p_row_identifier      => i
                                  ,p_attr_group_id       => l_attribute_group_obj.attr_group_id
                                  ,p_attr_group_app_id   => l_attribute_group_obj.attr_group_app_id
                                  ,p_attr_group_type     => l_attribute_group_obj.attr_group_type
                                  ,p_attr_group_name     => l_attribute_group_obj.attr_group_short_name
                                  ,p_data_level          => l_attribute_group_obj.data_level
                                  ,p_data_level_1        => l_attribute_group_obj.data_level_1
                                  ,p_data_level_2        => l_attribute_group_obj.data_level_2
                                  ,p_data_level_3        => l_attribute_group_obj.data_level_3
                                  ,p_data_level_4        => l_attribute_group_obj.data_level_4
                                  ,p_data_level_5        => l_attribute_group_obj.data_level_5
                                  ,p_transaction_type    => l_attribute_group_obj.transaction_type
                                );
      IF (l_attribute_group_obj.attributes_tbl IS NOT NULL  AND l_attribute_group_obj.attributes_tbl.COUNT > 0 ) THEN

       l_attributes_data_table.EXTEND(l_attribute_group_obj.attributes_tbl.COUNT);

        FOR j IN 1..l_attribute_group_obj.attributes_tbl.COUNT LOOP

          l_attribute_obj := l_attribute_group_obj.attributes_tbl(j);
          l_attributes_data_table(l_attr_count + j) := ego_user_attr_data_obj ( i
                                                         ,l_attribute_obj.attr_short_name
                                                         ,l_attribute_obj.attr_value_str
                                                         ,l_attribute_obj.attr_value_num
                                                         ,l_attribute_obj.attr_value_date
                                                         ,l_attribute_obj.attr_disp_value
                                                         ,l_attribute_obj.attr_unit_of_measure
                                                         ,l_attribute_obj.user_row_identifier
                                                        );
        END LOOP;

        l_attr_count := l_attr_count + l_attribute_group_obj.attributes_tbl.COUNT;

      END IF;

     END LOOP;

   END IF;

   x_attributes_row_table  := l_attributes_row_table;
   x_attributes_data_table := l_attributes_data_table;

 EXCEPTION
   WHEN FND_API.g_exc_error THEN

     x_return_status :=  FND_API.g_ret_sts_error;
     IF(x_msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_msg_count
        ,p_data    => x_msg_data
      );
     END IF;
   WHEN OTHERS THEN

     x_return_status :=  FND_API.g_ret_sts_unexp_error;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' ->INV_EBI_UTIL.transform_uda ';
     ELSE
       x_msg_data      :=  SQLERRM||'INV_EBI_UTIL.transform_uda ';
     END IF;
 END transform_uda;

 /************************************************************************************
  --      API name        : transform_attr_rowdata_uda
  --      Type            : Public
  --      Function        :
  --
 ************************************************************************************/
 PROCEDURE transform_attr_rowdata_uda(
    p_attributes_row_table    IN          ego_user_attr_row_table
    ,p_attributes_data_table  IN          ego_user_attr_data_table
    ,x_uda_input_obj          OUT NOCOPY  inv_ebi_uda_input_obj
    ,x_return_status          OUT NOCOPY VARCHAR2 --Bug 7240247
    ,x_msg_count              OUT NOCOPY NUMBER
    ,x_msg_data               OUT NOCOPY VARCHAR2
 )
 IS
 l_attr_obj inv_ebi_uda_attr_obj;
 l_attr_tbl inv_ebi_uda_attr_tbl;
 l_attr_grp_obj inv_ebi_uda_attr_grp_obj;
 l_attr_grp_tbl inv_ebi_uda_attr_grp_tbl;
 l_count               NUMBER := 0;
 BEGIN
   x_return_status         := FND_API.G_RET_STS_SUCCESS;
   IF ( p_attributes_row_table IS NOT NULL AND p_attributes_row_table.COUNT > 0
     AND p_attributes_data_table IS NOT NULL AND p_attributes_data_table.COUNT >0 ) THEN

     l_attr_grp_tbl := inv_ebi_uda_attr_grp_tbl();

     FOR i IN p_attributes_row_table.FIRST .. p_attributes_row_table.LAST
     LOOP
       l_attr_grp_tbl.extend();
       l_count := 1;
       l_attr_tbl := inv_ebi_uda_attr_tbl();
       FOR j IN p_attributes_data_table.FIRST .. p_attributes_data_table.LAST
       LOOP
         IF( p_attributes_data_table(j).ROW_IDENTIFIER = p_attributes_row_table(i).ROW_IDENTIFIER) THEN

           l_attr_tbl.extend();
           l_attr_obj := inv_ebi_uda_attr_obj( p_attributes_data_table(j).ATTR_NAME
                            ,p_attributes_data_table(j).ATTR_VALUE_STR
                            ,p_attributes_data_table(j).ATTR_VALUE_NUM
                            ,p_attributes_data_table(j).ATTR_VALUE_DATE
                            ,p_attributes_data_table(j).ATTR_DISP_VALUE
                            ,p_attributes_data_table(j).ATTR_UNIT_OF_MEASURE
                            ,p_attributes_data_table(j).USER_ROW_IDENTIFIER
                            ,NULL);

           l_attr_tbl(l_count) := l_attr_obj;
           l_count  := l_count +1;

         END IF;
       END LOOP;
       l_attr_grp_obj := inv_ebi_uda_attr_grp_obj( p_attributes_row_table(i).ATTR_GROUP_ID
                           ,p_attributes_row_table(i).ATTR_GROUP_APP_ID
                           ,NULL
                           ,p_attributes_row_table(i).ATTR_GROUP_TYPE
                           ,p_attributes_row_table(i).ATTR_GROUP_NAME
                           ,p_attributes_row_table(i).DATA_LEVEL
                           ,p_attributes_row_table(i).DATA_LEVEL_1
                           ,p_attributes_row_table(i).DATA_LEVEL_2
                           ,p_attributes_row_table(i).DATA_LEVEL_3
                           ,p_attributes_row_table(i).DATA_LEVEL_4
                           ,p_attributes_row_table(i).DATA_LEVEL_5
                           ,p_attributes_row_table(i).TRANSACTION_TYPE
                           ,l_attr_tbl
                         );
        l_attr_grp_tbl(i) := l_attr_grp_obj;

     END LOOP;
     x_uda_input_obj := inv_ebi_uda_input_obj(
                          l_attr_grp_tbl
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                          ,NULL
                        );

   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     x_return_status :=  FND_API.g_ret_sts_unexp_error;
     IF (x_msg_data IS NOT NULL) THEN
       x_msg_data      :=  x_msg_data||' ->INV_EBI_UTIL.transform_attr_rowdata_uda ';
     ELSE
       x_msg_data      :=  SQLERRM||'INV_EBI_UTIL.transform_attr_rowdata_uda ';
     END IF;
 END transform_attr_rowdata_uda;


/************************************************************************************
 --      API name        : set_apps_context
 --      Type            : Public
 --      Procedure       : p_name_value_list contaning user id and responsibility id
 --      Desc            : This API to initialize the apps context for forward and
 --                        reverse flow API's.
************************************************************************************/

PROCEDURE set_apps_context( p_name_value_tbl IN inv_ebi_name_value_tbl)
IS
  l_user               VARCHAR2(100);
  l_resp               VARCHAR2(100);
  l_user_id            NUMBER(15);
  l_resp_id            NUMBER(15);
  l_resp_appl_id       NUMBER(15);
  l_sec_grp_id         NUMBER(15);
  l_language           FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_language_code      FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_date_format        FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_date_language      FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_numeric_characters FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_nls_sort           FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_nls_territory      FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_limit_time         NUMBER;
  l_limit_connects     NUMBER;
  l_org_id             FND_PROFILE_OPTION_VALUES.PROFILE_OPTION_VALUE%TYPE;
  l_timeout            NUMBER;
BEGIN
  IF p_name_value_tbl IS NOT NULL AND p_name_value_tbl.COUNT>0
  THEN
    l_user  := INV_EBI_UTIL.get_config_param_value(p_name_value_tbl,'USER');
    l_resp  := INV_EBI_UTIL.get_config_param_value(p_name_value_tbl,'RESPONSIBILITY');
  END IF;

  BEGIN
    SELECT usr.user_id,
           furg.responsibility_id,
           furg.responsibility_application_id,
           furg.security_group_id
      INTO l_user_id,
           l_resp_id,
           l_resp_appl_id,
           l_sec_grp_id
      FROM FND_USER_RESP_GROUPS FURG, FND_RESPONSIBILITY_TL FR , FND_USER USR
     WHERE furg.user_id = usr.user_id
       AND furg.responsibility_id = fr.responsibility_id
       AND furg.responsibility_application_id = fr.application_id
       AND UPPER(usr.user_name) = UPPER(l_user)
       AND UPPER(fr.responsibility_name) = UPPER(l_resp);
  EXCEPTION
    WHEN OTHERS THEN
      NULL;
  END;

  IF l_user_id IS NOT NULL AND l_resp_id IS NOT NULL AND l_resp_appl_id IS NOT NULL
  THEN
    FND_GLOBAL.apps_initialize(l_user_id, l_resp_id, l_resp_appl_id,l_sec_grp_id);
  END IF;

  FND_SESSION_MANAGEMENT.SETUSERNLS(l_user_id
                                   ,NULL
                                   ,l_language
                                   ,l_language_code
                                   ,l_date_format
                                   ,l_date_language
                                   ,l_numeric_characters
                                   ,l_nls_sort
                                   ,l_nls_territory
                                   ,l_limit_time
                                   ,l_limit_connects
                                   ,l_org_id
                                   ,l_timeout  );

  FND_GLOBAL.SET_NLS_CONTEXT(l_language,
                             l_date_format,
                             l_date_language,
                             l_numeric_characters,
                             l_nls_sort,
                             l_nls_territory);

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END set_apps_context;

-- ------------------------------------------------------------------
-- Name: put_names
-- Desc: Setup which directory to put the log and what the log file
--       name is.  The directory setup is used only if the program
--       is not run thru concurrent manager
-- -----------------------------------------------------------------
PROCEDURE put_names(
        p_log_file              VARCHAR2,
        p_out_file              VARCHAR2,
        p_directory             VARCHAR2) IS
BEGIN
     FND_FILE.PUT_NAMES(p_log_file,p_out_file,p_directory);
END put_names;
-- ------------------------------------------------------------------
-- Name: debug_line
-- Desc: If debug flag is turned on, the log will be printed
-- -----------------------------------------------------------------
PROCEDURE debug_line(
                p_text                  VARCHAR2) IS
BEGIN
  IF (INV_EBI_UTIL.g_debug) THEN
   FND_FILE.PUT_LINE(FND_FILE.LOG,to_char(sysdate,'DD/MON/YYYY HH24:MI:SS')||': '||p_text);
  END IF;
END debug_line;
-- ------------------------------------------------------------------
-- Name: debug_status
-- Desc:
-- -----------------------------------------------------------------
FUNCTION debug_status
RETURN boolean
IS
BEGIN
  IF (fnd_profile.value('INV_EBI_DEBUG') = 'Y') THEN
    RETURN true;
  ELSE
    RETURN false;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
   RETURN false;
END debug_status;

-- ------------------------------------------------------------------
-- Name: setup
-- Desc:
-- -----------------------------------------------------------------
PROCEDURE setup(
                p_filename         VARCHAR2  Default NULL) IS
l_path varchar2(200) := FND_PROFILE.value('INV_EBI_DEBUG_DIRECTORY');
BEGIN
  INV_EBI_UTIL.g_debug := debug_status;

  IF (INV_EBI_UTIL.g_debug) THEN

    INV_EBI_UTIL.put_names(nvl(p_filename,'EBS'||to_char(sysdate,'DDMMYYYYHH24MISS'))||'.log',nvl(p_filename,'EBS'||to_char(sysdate,'DDMMYYYYHH24MISS'))||'.out',l_path);
    INV_EBI_UTIL.debug_line('At the start of the Debug process is ');
  END IF;
END setup;
-- ------------------------------------------------------------------
-- Name: wrapup
-- Desc:
-- -----------------------------------------------------------------

PROCEDURE wrapup IS
BEGIN
 IF (INV_EBI_UTIL.g_debug) THEN
     INV_EBI_UTIL.debug_line('At the end of Debug Process');
   FND_FILE.close;
 END IF;
END wrapup;
END INV_EBI_UTIL;

/
