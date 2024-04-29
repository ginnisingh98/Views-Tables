--------------------------------------------------------
--  DDL for Package Body HR_ADE_ADI_DATA_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_ADE_ADI_DATA_SETUP" AS
/* $Header: peadeset.pkb 120.3 2008/04/29 13:04:18 dbansal ship $ */
-------------------------------------------------------------------------------
-------------------------< Procedures private to package  >--------------------
-------------------------------------------------------------------------------
--
--  ---------------------------------------------------------------------------
--  --                          set_new_session_flag                         --
--  ---------------------------------------------------------------------------
--
 PROCEDURE set_new_session_flag
   (p_application_id       IN    number
   ,p_integrator_code      IN    varchar2) IS
--
--  Find if NEW SESSION functionality installed on environment and,
--  if it is, update the integrator to initiate cloning
--
  l_cloning           VARCHAR2(1);
  l_out_industry      VARCHAR2(30);
  l_out_oracle_schema VARCHAR2(30);
  l_out_status        VARCHAR2(30);
  l_plsql             varchar2(2000);
  l_value             BOOLEAN;
 --
 --
  CURSOR csr_test_for_flag (l_oracle_schema IN varchar) IS
    SELECT 'Y'
    FROM   all_tab_columns tc
    WHERE  tc.table_name = 'BNE_INTEGRATORS_B'
    AND    tc.column_name = 'NEW_SESSION_FLAG'
    AND    tc.owner = l_oracle_schema;
  --
--
BEGIN
--
  l_value := FND_INSTALLATION.GET_APP_INFO ('BNE', l_out_status,
                                          l_out_industry, l_out_oracle_schema);
--
  l_cloning := 'N';
--
  OPEN csr_test_for_flag(l_out_oracle_schema);
  FETCH csr_test_for_flag INTO l_cloning;
  IF csr_test_for_flag%NOTFOUND THEN
  --
    l_cloning := 'N';
  --
  END IF;
  CLOSE csr_test_for_flag;
--
  IF l_cloning = 'Y' THEN
  --
    l_plsql :=
     'BEGIN ' ||
     ' UPDATE bne_integrators_b ' ||
     ' SET    new_session_flag = ''Y'' ' ||
     ' WHERE  application_id = :1 ' ||
     ' AND    integrator_code = :2; ' ||
     'END;';
  --
    EXECUTE IMMEDIATE l_plsql
      USING IN p_application_id,
               p_integrator_code;
  --
  END IF;
--
END set_new_session_flag;
--
-------------------------------------------------------------------
--                      create_download_data                     --
-------------------------------------------------------------------
--
PROCEDURE create_download_data
  (p_application_id       IN    number
  ,p_integrator_user_name IN    varchar2
  ,p_view_name            IN    varchar2
  ,p_form_name            IN    varchar2 default null
  ,p_language             IN    varchar2
  ,p_user_id              IN    number ) IS
  --
  TYPE CSR_TYP IS REF CURSOR;
  csr_int CSR_TYP;
  -- constants
  c_hr_content      CONSTANT    VARCHAR2(50) :=
    'oracle.apps.per.webui.control.BneHrSQLControl';
  -- local variables
  l_content_code      varchar2(30);
  l_interface_code    varchar2(30);
  l_mapping_code      varchar2(30);
  --
  l_integrator_code   varchar2(60);
  l_igr_csr_id        varchar2(60);
  l_num_columns       NUMBER;
  l_num_content       NUMBER;
  l_param_list_code   varchar2(30) DEFAULT NULL;
  --
  l_user_integrator_name varchar2(240);
  l_object_code          varchar2(20) ;
  l_object_num           number;
  --
  l_bne_value         VARCHAR2(2000);
  l_sql_statement     VARCHAR2(2000);
  --
  BEGIN
   --
   ------< Validate parameters >------
   --
   IF p_view_name IS NULL THEN
      fnd_message.set_name('PER','PER_289873_INVALID_VIEW_NAME');
      fnd_message.raise_error;
   END IF;
   --
  IF p_form_name <> 'LETTER' AND p_form_name <> 'GENERAL' THEN
     --Check Form Name exists
     l_bne_value := 'FND_FORM_VL';
     OPEN csr_int FOR
       ' select FORM_NAME' ||
       ' from '||l_bne_value ||
       ' where FORM_NAME = '''||
        p_form_name || '''';
     FETCH csr_int INTO l_igr_csr_id;
     IF csr_int%NOTFOUND THEN
        --invalid form name supplied
        fnd_message.set_name('PER','PER_289922_INVAL_FM_NAME');
        fnd_message.raise_error;
     END IF;
   END IF;
   --
   --Check Application ID
   l_bne_value := 'FND_APPLICATION';
   OPEN csr_int FOR
      ' select APPLICATION_SHORT_NAME' ||
      ' from '||l_bne_value ||
      ' where APPLICATION_ID ='||
       p_application_id;
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      --invalid form name supplied
      fnd_message.set_name('PER','PER_289921_INVAL_APP_ID');
      fnd_message.raise_error;
   END IF;
   --
   --Check integrator_user_name
   l_bne_value := 'bne_integrators_tl';
   OPEN csr_int FOR
      ' select USER_NAME' ||
      ' from '||l_bne_value ||
      ' where USER_NAME ='''||
       p_integrator_user_name ||'''';
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%FOUND THEN
      --invalid form name supplied
      fnd_message.set_name('PER','PER_289923_USER_NAME_EXISTS');
      fnd_message.raise_error;
   END IF;
   --
   ---------< Create MetaData >-------
   --
   --create object code
   SELECT hr_adi_object_code_s.NEXTVAL
   INTO l_object_num
   FROM dual;
    -- If Style is "GENERAL", prepend object code with "GENERAL_"
    IF p_form_name = 'GENERAL' THEN
       l_object_code := 'GENERAL_'||to_char(l_object_num);
    ELSE
       l_object_code := 'HR_'||to_char(l_object_num);
    END IF;
    l_user_integrator_name := p_integrator_user_name;
    --
    -- STEP 1.  Create Integrator
    --
    -- check to see if integrator name already exists
        l_bne_value := 'bne_integrators_b';
        OPEN csr_int FOR
          'SELECT integrator_code' ||
          '   FROM ' || l_bne_value ||
          '   WHERE integrator_code =  ''' ||
                    l_object_code ||'_INTG'||
          ''' AND application_id = '
                    || p_application_id;
        --
        FETCH csr_int INTO l_igr_csr_id;
        IF csr_int%FOUND THEN
           CLOSE csr_int;
           fnd_message.set_name('PER','PER_289872_ADI_INTGR_EXISTS');
           fnd_message.raise_error;
        END IF;
        CLOSE csr_int;
    --
    l_bne_value := 'bne_integrator_utils.create_integrator_no_content';
    l_sql_statement :=
      'BEGIN '||
      l_bne_value||
      ' (:1,:2,:3,:4,:5,:6,:7);' ||
      'END;';
    --
    EXECUTE IMMEDIATE l_sql_statement
           USING IN     p_application_id
               , IN     l_object_code
               , IN     l_user_integrator_name
               , IN     p_user_id
               , IN     p_language
               , IN     p_language
               ,    OUT l_integrator_code;
    --
    l_bne_value := 'bne_integrators_b';
    OPEN csr_int FOR
      'SELECT integrator_code' ||
      '   FROM ' || l_bne_value ||
      '   WHERE integrator_code =  ''' ||
                l_integrator_code ||
      ''' AND application_id = '
                || p_application_id;
    --
    FETCH csr_int INTO l_igr_csr_id;
    IF csr_int%NOTFOUND THEN
       CLOSE csr_int;
       fnd_message.set_name('PER','PER_289864_ADI_INTGR_INVAL');
       fnd_message.raise_error;
    /*ELSE
       set_new_session_flag
          (p_application_id  => p_application_id
          ,p_integrator_code => l_integrator_code);*/
    END IF;
    CLOSE csr_int;
    -- ??? maybe also check for null???
    --
    -- STEP 2.  Create Content
    --
    l_bne_value := 'bne_content_utils.create_content';
    l_sql_statement :=
      'BEGIN '||
      l_bne_value||
      ' (:1,:2,:3,:4,:5,:6,:7,:8,:9);' ||
      'END;';
    EXECUTE IMMEDIATE     l_sql_statement
             USING IN     p_application_id
                  ,IN     l_object_code
                  ,IN     l_integrator_code
                  ,IN     upper(p_view_name)
                  ,IN     p_language
                  ,IN     p_language
                  ,IN     c_hr_content
                  ,IN     p_user_id
                  ,   OUT l_content_code;
    --
    l_bne_value := 'bne_contents_b';
    OPEN csr_int FOR
      'SELECT content_code ' ||
      ' FROM ' || l_bne_value ||
      ' WHERE integrator_code =''' ||
         l_integrator_code ||
      ''' AND application_id = '|| p_application_id;

    FETCH csr_int INTO l_igr_csr_id;
    IF csr_int%NOTFOUND THEN
       CLOSE csr_int;
       fnd_message.set_name('PER','PER_289865_ADI_CONTENT_FAIL');
       fnd_message.raise_error;
    END IF;
    CLOSE csr_int;
    --
    -- STEP 3.  Create Content Columns
    --
    l_bne_value := 'bne_content_utils.create_content_cols_from_view';
    l_sql_statement :=
      'BEGIN ' ||
      l_bne_value ||
      ' (:1,:2,:3,:4,:5,:6);' ||
      'END;';
    EXECUTE IMMEDIATE     l_sql_statement
             USING IN     p_application_id
                  ,IN     l_content_code
                  ,IN     upper(p_view_name)
                  ,IN     p_language
                  ,IN     p_language
                  ,IN     p_user_id;
    --
    l_bne_value := 'bne_content_cols_b';
    OPEN csr_int FOR
      'SELECT count(*) ' ||
      ' FROM '|| l_bne_value ||
      ' WHERE content_code =''' ||
      l_content_code ||''' AND ' ||
      '          application_id = '|| p_application_id;
    FETCH csr_int INTO l_num_columns;
    IF l_num_columns <1 THEN
       CLOSE csr_int;
       fnd_message.set_name('PER','PER_289866_ADI_CONT_COL_FAIL');
       fnd_message.raise_error;
    END IF;
    CLOSE csr_int;
    --
    -- Step 4.  Enable content for reporting
    --
    l_bne_value := 'bne_content_utils.enable_content_for_reporting';
    l_sql_statement :=
      'BEGIN ' ||
      l_bne_value ||
      ' (:1,:2,:3,:4,:5,:6,:7,:8,:9);' ||
      'END;';
    EXECUTE IMMEDIATE     l_sql_statement
             USING IN     p_application_id
                  ,IN     l_object_code
                  ,IN     l_integrator_code
                  ,IN     l_content_code
                  ,IN     p_language
                  ,IN     p_language
                  ,IN     p_user_id
                  ,   OUT l_interface_code
                  ,   OUT l_mapping_code;
    --
    l_bne_value := 'bne_interface_cols_b';
    --check interface code
    OPEN csr_int FOR
      'SELECT count(*) ' ||
      ' FROM ' || l_bne_value ||
      ' WHERE interface_code = ' ||
      '  (SELECT interface_code' ||
      '   FROM bne_interfaces_b' ||
      '   WHERE integrator_code = ''' ||
           l_integrator_code ||
      ''' AND application_id = '||
           p_application_id || ')';
    FETCH csr_int INTO l_num_content;
    IF l_num_content <> l_num_columns THEN
       CLOSE csr_int;
       fnd_message.set_name('PER','PER_289867_ADI_CONT_ENABL_FAIL');
       fnd_message.raise_error;
    END IF;
    CLOSE csr_int;
    --check mapping code
    l_bne_value := 'bne_mappings_b';
    OPEN csr_int FOR
      '   SELECT mapping_code'||
      '   FROM ' || l_bne_value ||
      '   WHERE mapping_code = ''' ||
          l_mapping_code ||
      ''' AND application_id ='||
          p_application_id;
    FETCH csr_int INTO l_igr_csr_id;
    IF csr_int%NOTFOUND THEN
       CLOSE csr_int;
       fnd_message.set_name('PER','PER_289868_ADI_CONT_MAP_FAIL');
       fnd_message.raise_error;
    END IF;
    CLOSE csr_int;
    --
    -- Step 5. Add HR Param list to content
    --
    --if not general
    l_bne_value := 'hr_integration_utils.add_hr_param_list_to_content';
    l_sql_statement :=
      'BEGIN ' ||
      l_bne_value ||
      ' (:1,:2);' ||
      'END;';
    EXECUTE IMMEDIATE l_sql_statement
             USING IN   p_application_id
                  ,IN   l_content_code;
    --
    l_bne_value := 'bne_contents_b';
    OPEN csr_int FOR
      'SELECT param_list_code ' ||
      ' FROM ' || l_bne_value ||
      ' WHERE content_code = ''' ||
          l_content_code ||
      ''' AND  application_id = '||
      p_application_id;

    FETCH csr_int INTO l_param_list_code;
    IF l_param_list_code IS NULL THEN
       CLOSE csr_int;
       fnd_message.set_name('PER','PER_289869_ADI_ADD_PARAM_FAIL');
       fnd_message.raise_error;
    END IF;
    CLOSE csr_int;
    --
    -- Step 6. Add Integrator to LETTER group
    --
    IF p_form_name IS NOT NULL  and
       p_form_name <> 'GENERAL' THEN
       l_user_integrator_name := to_char(p_application_id) || ':' || l_integrator_code;
       l_bne_value := 'hr_integration_utils.register_integrator_to_form';
       l_sql_statement :=
         'BEGIN ' ||
         l_bne_value ||
         ' (:1,:2); ' ||
         'END;';
       EXECUTE IMMEDIATE l_sql_statement
                   USING IN     l_user_integrator_name
                        ,IN     p_form_name;
    END IF;
    --
  END create_download_data;
 --
 -----------------------------------------------------------------------------
 --                             create_upload_data                          --
 -----------------------------------------------------------------------------
 --
 PROCEDURE create_upload_data
   (p_application_id       IN    number
   ,p_integrator_user_name IN    varchar2
   ,p_api_package_name     IN    varchar2
   ,p_api_procedure_name   IN    varchar2
   ,p_interface_user_name  IN    varchar2
   ,p_interface_param_name IN    varchar2
   ,p_api_type             IN    varchar2
   ,p_api_return_type      IN    varchar2
   ,p_language             IN    varchar2
   ,p_user_id              IN    number ) IS
 --
 --
 -- Upload api, with "none" and "text file" content
 --
 -- Required actions by user:
 --    - Create Layout
 --    - create mapping for text file mapping
 --
 TYPE CSR_TYP IS REF CURSOR;
 csr_int CSR_TYP;
 -- local variables
 l_integrator_code   varchar2(60);
 l_param_list_code   varchar2(60) DEFAULT NULL;
 l_interface_code    varchar2(60);
 l_content_code      varchar2(60);
 l_igr_csr_id        varchar2(60);
 --
 l_object_code       varchar2(30);
 l_object_num        number;
 --
 l_bne_value         VARCHAR2(2000);
 l_sql_statement     VARCHAR2(2000);
 --
 BEGIN
   --
   --------< validate parameters >---------------
   IF p_api_package_name IS NULL THEN
      fnd_message.set_name('PER','PER_289874_INVAL_PGK_NAME');
      fnd_message.raise_error;
   ELSIF p_api_procedure_name IS NULL THEN
      fnd_message.set_name('PER','PER_289875_INVAL_PROC_NAME');
      fnd_message.raise_error;
   ELSIF p_interface_user_name IS NULL THEN
      fnd_message.set_name('PER','PER_289876_INVAL_IFACE_NAME');
      fnd_message.raise_error;
   ELSIF p_interface_param_name IS NULL THEN
      fnd_message.set_name('PER','PER_289877_INVAL_PARAM_LIST');
      fnd_message.raise_error;
   ELSIF p_api_type IS NULL THEN
      fnd_message.set_name('PER','PER_289878_INVAL_API_TYPE');
      fnd_message.raise_error;
   END IF;
   --Check Application ID
   l_bne_value := 'FND_APPLICATION';
   OPEN csr_int FOR
      ' select APPLICATION_SHORT_NAME' ||
      ' from '||l_bne_value ||
      ' where APPLICATION_ID ='||
       p_application_id;
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      --invalid form name supplied
      fnd_message.set_name('PER','PER_289921_INVAL_APP_ID');
      fnd_message.raise_error;
   END IF;
   --Check integrator_user_name
   l_bne_value := 'bne_integrators_tl';
   OPEN csr_int FOR
      ' select USER_NAME' ||
      ' from '||l_bne_value ||
      ' where USER_NAME ='''||
       p_integrator_user_name ||'''';
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%FOUND THEN
      --invalid form name supplied
      fnd_message.set_name('PER','PER_289923_USER_NAME_EXISTS');
      fnd_message.raise_error;
   END IF;
   --
   --Check package and procedure name
   l_bne_value := 'SYS.ARGUMENT$ A, DBA_OBJECTS B';
      OPEN csr_int FOR
         ' select 1' ||
         ' from '||l_bne_value ||
         ' where A.OBJ# = B.OBJECT_ID' ||
         ' AND   B.OBJECT_NAME = '''||P_API_PACKAGE_NAME ||
         ''' AND   A.PROCEDURE$ = ''' ||P_API_PROCEDURE_NAME || '''';
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      --invalid package/procedure name supplied
      fnd_message.set_name('PER','PER_289931_API_NOT_EXIST');
      fnd_message.raise_error;
   END IF;
   --
   -------< Create MetaData >---------
   --
   --create object code
   SELECT hr_adi_object_code_s.NEXTVAL
   INTO l_object_num
   FROM dual;
   l_object_code := 'GENERAL_'||to_char(l_object_num);
   --
   -- STEP 1.  Create Integrator
   --
   -- check to see if integrator name already exists
   l_bne_value := 'bne_integrators_b';
   OPEN csr_int FOR
     'SELECT integrator_code' ||
     '   FROM ' || l_bne_value ||
     '   WHERE integrator_code =  ''' ||
               l_object_code ||'_INTG'||
     ''' AND application_id = '
               || p_application_id;
   --
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%FOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289872_ADI_INTGR_EXISTS');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   l_bne_value := 'bne_integrator_utils.create_integrator';
   l_sql_statement :=
     'BEGIN '||
     l_bne_value||
     ' (:1,:2,:3,:4,:5,:6,:7); ' ||
     'END;';

   EXECUTE IMMEDIATE l_sql_statement
          USING IN     p_application_id
               ,IN     l_object_code
               ,IN     p_integrator_user_name
               ,IN     p_language
               ,IN     p_language
               ,IN     p_user_id
               ,   OUT l_integrator_code;
   --
   l_bne_value := 'bne_contents_b';
   OPEN csr_int FOR
   --check integrator created and has content
     'SELECT integrator_code' ||
     '   FROM ' || l_bne_value ||
     '   WHERE integrator_code = '||
          '(SELECT integrator_code '||
             'FROM bne_integrators_b '||
             'WHERE integrator_code =''' ||
               l_integrator_code ||
             ''' AND application_id = ' ||
                  p_application_id||
     ')  AND application_id ='||
           p_application_id;

   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289864_ADI_INTGR_INVAL');
      fnd_message.raise_error;
   /*ELSE
      set_new_session_flag
         (p_application_id  => p_application_id
         ,p_integrator_code => l_integrator_code);*/
   END IF;
   CLOSE csr_int;
   --
   -- STEP 2.  Create Interface for API
   --
   l_bne_value := 'bne_integrator_utils.create_interface_for_api';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     '  (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15); ' ||
     'END;';
   --
   EXECUTE IMMEDIATE l_sql_statement
     USING IN     p_application_id
          ,IN     l_object_code
          ,IN     l_integrator_code
          ,IN     upper(p_api_package_name)
          ,IN     upper(p_api_procedure_name)
          ,IN     p_interface_user_name
          ,IN     p_interface_param_name
          ,IN     p_api_type
          ,IN     p_api_return_type
          ,IN     5
          ,IN     p_language
          ,IN     p_language
          ,IN     p_user_id
          ,   OUT l_param_list_code
          ,   OUT l_interface_code;
   --
   l_bne_value := 'bne_interface_cols_b';
   OPEN csr_int FOR
   --check interface created and has columns
   ' SELECT interface_code '||
   ' FROM '|| l_bne_value ||
   ' WHERE interface_code = (' ||
        ' SELECT interface_code'||
        ' FROM bne_interfaces_b' ||
        ' WHERE interface_code = ''' ||
           l_interface_code ||
        ''' AND application_id ='||
            p_application_id ||
   ') AND application_id = '||
     p_application_id;
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289870_ADI_IFACE_FAIL');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   -- Step 3. Set upload param list for integrator
   --
   l_bne_value := 'hr_integration_utils.add_hr_upload_list_to_integ';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     '  (:1,:2); ' ||
     'END;';
   --
   EXECUTE IMMEDIATE l_sql_statement
     USING IN    p_application_id
          ,In    l_integrator_code;
   --
   -- Step 4: Create content for text file input
   --
   l_bne_value := 'bne_content_utils.create_content_text';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     '  (:1,:2,:3,:4,:5,null,:6,:7,:8,:9); ' ||
     'END;';
   --
   --create content_code object code
   l_object_code := l_object_code ||'A';
   --
   EXECUTE IMMEDIATE l_sql_statement
     USING IN     p_application_id
          ,IN     l_object_code
          ,IN     l_integrator_code
          ,IN     'Text File'
          ,IN     128
                  -- col prefix is null
          ,IN     p_language
          ,IN     p_language
          ,IN     p_user_id
          ,   OUT l_content_code;
   --
   l_bne_value := 'bne_contents_b';
       OPEN csr_int FOR
         '   SELECT content_code'||
         '   FROM ' || l_bne_value ||
         '   WHERE content_code = ''' ||
             l_content_code ||
         ''' AND application_id ='||
             p_application_id;
       FETCH csr_int INTO l_igr_csr_id;
       IF csr_int%NOTFOUND THEN
          CLOSE csr_int;
          fnd_message.set_name('PER','PER_289871_CREATE_TEXT_FAIL');
          fnd_message.raise_error;
       END IF;
   CLOSE csr_int;
   --
 --
 END create_upload_data;
 --
 -----------------------------------------------------------------------------
 --                     create_update_data                                  --
 -----------------------------------------------------------------------------
 --
 PROCEDURE create_update_data
   (p_application_id         IN    number
   ,p_integrator_user_name   IN    varchar2
   ,p_api_package_name       IN    varchar2
   ,p_api_procedure_name     IN    varchar2
   ,p_interface_user_name    IN    varchar2
   ,p_interface_param_name   IN    varchar2
   ,p_api_type               IN    varchar2
   ,p_api_return_type        IN    varchar2
   ,p_view_name              IN    varchar2
   ,p_form_name              IN    varchar2
   ,p_language               IN    varchar2
   ,p_user_id                IN    number) IS
 --
 -- Upload api (update-style api's)
 --
 TYPE CSR_TYP IS REF CURSOR;
 csr_int CSR_TYP;
 -- constants
 c_hr_content      CONSTANT    VARCHAR2(50) :=
   'oracle.apps.per.webui.control.BneHrSQLControl';
 -- local variables
 l_integrator_code   varchar2(60);
 l_param_list_code   varchar2(60) DEFAULT NULL;
 l_interface_code    varchar2(60);
 l_content_code      varchar2(60);
 l_igr_csr_id        varchar2(60);
 l_mapping_code      varchar2(60);
 --
 l_user_integrator_name varchar2(100);
 l_num_columns          number;
 l_object_code          varchar2(30) ;
 l_object_num           number;
 --
 l_bne_value         VARCHAR2(2000);
 l_sql_statement     VARCHAR2(2000);
 --
 BEGIN
   --
   --------< Validate Parameters >--------------
   IF p_view_name IS NULL THEN
      fnd_message.set_name('PER','PER_289873_INVALID_VIEW_NAME');
      fnd_message.raise_error;
   ELSIF p_api_package_name IS NULL THEN
      fnd_message.set_name('PER','PER_289874_INVAL_PGK_NAME');
      fnd_message.raise_error;
   ELSIF p_api_procedure_name IS NULL THEN
      fnd_message.set_name('PER','PER_289875_INVAL_PROC_NAME');
      fnd_message.raise_error;
   ELSIF p_interface_user_name IS NULL THEN
      fnd_message.set_name('PER','PER_289876_INVAL_IFACE_NAME');
      fnd_message.raise_error;
   ELSIF p_interface_param_name IS NULL THEN
      fnd_message.set_name('PER','PER_289877_INVAL_PARAM_LIST');
      fnd_message.raise_error;
   ELSIF p_api_type IS NULL THEN
      fnd_message.set_name('PER','PER_289878_INVAL_API_TYPE');
      fnd_message.raise_error;
   END IF;
   --Check Application ID
   l_bne_value := 'FND_APPLICATION';
   OPEN csr_int FOR
      ' select APPLICATION_SHORT_NAME' ||
      ' from '||l_bne_value ||
      ' where APPLICATION_ID ='||
       p_application_id;
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      --invalid form name supplied
      fnd_message.set_name('PER','PER_289921_INVAL_APP_ID');
      fnd_message.raise_error;
   END IF;
   IF p_form_name <> 'LETTER' AND p_form_name <> 'GENERAL' THEN
   --Check Form Name exists
     l_bne_value := 'FND_FORM_VL';
     OPEN csr_int FOR
        ' select FORM_NAME' ||
        ' from '||l_bne_value ||
        ' where FORM_NAME = '''||
         p_form_name || '''';
     FETCH csr_int INTO l_igr_csr_id;
     IF csr_int%NOTFOUND THEN
        --invalid form name supplied
        fnd_message.set_name('PER','PER_289922_INVAL_FM_NAME');
        fnd_message.raise_error;
     END IF;
   END IF;
   --
   --Check integrator_user_name
   l_bne_value := 'bne_integrators_tl';
   OPEN csr_int FOR
      ' select USER_NAME' ||
      ' from '||l_bne_value ||
      ' where USER_NAME ='''||
       p_integrator_user_name ||'''';
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%FOUND THEN
      --invalid form name supplied
      fnd_message.set_name('PER','PER_289923_USER_NAME_EXISTS');
      fnd_message.raise_error;
   END IF;
   --
   --Check package and procedure name
   l_bne_value := 'SYS.ARGUMENT$ A, DBA_OBJECTS B';
      OPEN csr_int FOR
         ' select 1' ||
         ' from '||l_bne_value ||
         ' where A.OBJ# = B.OBJECT_ID' ||
         ' AND   B.OBJECT_NAME = '''||P_API_PACKAGE_NAME ||
         ''' AND   A.PROCEDURE$ = ''' ||P_API_PROCEDURE_NAME ||'''';
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      --invalid package/procedure name supplied
      fnd_message.set_name('PER','PER_289931_API_NOT_EXIST');
      fnd_message.raise_error;
   END IF;
   --
   ---------< Create MetaData >----------
   --
   --create object code
   SELECT hr_adi_object_code_s.NEXTVAL
   INTO l_object_num
   FROM dual;
   -- If Style is "GENERAL", prepend object code with "GENERAL_"
   IF p_form_name = 'GENERAL' THEN
      l_object_code := 'GENERAL_'||to_char(l_object_num);
   ELSE
      l_object_code := 'HR_'||to_char(l_object_num);
   END IF;
   --
   -- STEP 1.  Create Integrator
   --
   l_user_integrator_name := p_integrator_user_name;
   -- check to see if integrator name already exists
   l_bne_value := 'bne_integrators_b';
   OPEN csr_int FOR
     'SELECT integrator_code' ||
     '   FROM ' || l_bne_value ||
     '   WHERE integrator_code =  ''' ||
               l_object_code ||'_INTG'||
     ''' AND application_id = '
               || p_application_id;
   --
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%FOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289872_ADI_INTGR_EXISTS');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   l_bne_value := 'bne_integrator_utils.create_integrator_no_content';
   l_sql_statement :=
     'BEGIN '||
     l_bne_value||
     ' (:1,:2,:3,:4,:5,:6,:7);' ||
     'END;';
   --
   EXECUTE IMMEDIATE l_sql_statement
          USING IN     p_application_id
              , IN     l_object_code
              , IN     l_user_integrator_name --use created integrator name
              , IN     p_user_id
              , IN     p_language
              , IN     p_language
              ,    OUT l_integrator_code;
   --
   l_bne_value := 'bne_integrators_b';
   OPEN csr_int FOR
     'SELECT integrator_code' ||
     '   FROM ' || l_bne_value ||
     '   WHERE integrator_code =  ''' ||
               l_integrator_code ||
     ''' AND application_id = '
               || p_application_id;
   --
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289864_ADI_INTGR_INVAL');
      fnd_message.raise_error;
   /*ELSE
      set_new_session_flag
         (p_application_id  => p_application_id
         ,p_integrator_code => l_integrator_code);*/
   END IF;
   CLOSE csr_int;
   -- ??? maybe also check for null???
   --
   -- Step 2: Create Content for view
   --
   l_bne_value := 'bne_content_utils.create_content';
   l_sql_statement :=
     'BEGIN '||
     l_bne_value||
     ' (:1,:2,:3,:4,:5,:6,:7,:8,:9);' ||
     'END;';
   EXECUTE IMMEDIATE     l_sql_statement
            USING IN     p_application_id
                 ,IN     l_object_code
                 ,IN     l_integrator_code
                 ,IN     upper(p_view_name)
                 ,IN     p_language
                 ,IN     p_language
                 ,IN     c_hr_content
                 ,IN     p_user_id
                 ,   OUT l_content_code;
   --
   l_bne_value := 'bne_contents_b';
   OPEN csr_int FOR
     'SELECT content_code ' ||
     ' FROM ' || l_bne_value ||
     ' WHERE integrator_code =''' ||
        l_integrator_code ||
     ''' AND application_id = '|| p_application_id;

   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289865_ADI_CONTENT_FAIL');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   -- STEP 3.  Create Content Columns
   --
   l_bne_value := 'bne_content_utils.create_content_cols_from_view';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     ' (:1,:2,:3,:4,:5,:6);' ||
     'END;';
   EXECUTE IMMEDIATE     l_sql_statement
            USING IN     p_application_id
                 ,IN     l_content_code
                 ,IN     upper(p_view_name)
                 ,IN     p_language
                 ,IN     p_language
                 ,IN     p_user_id;
   --
   l_bne_value := 'bne_content_cols_b';
   OPEN csr_int FOR
     'SELECT count(*) ' ||
     ' FROM '|| l_bne_value ||
     ' WHERE content_code =''' ||
     l_content_code ||''' AND ' ||
     '          application_id = '|| p_application_id;
   FETCH csr_int INTO l_num_columns;
   IF l_num_columns <1 THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289866_ADI_CONT_COL_FAIL');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   -- Step 4.  Add HR Param List to content
   --
   l_bne_value := 'hr_integration_utils.add_hr_param_list_to_content';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     ' (:1,:2);' ||
     'END;';
   EXECUTE IMMEDIATE l_sql_statement
            USING IN   p_application_id
                 ,IN   l_content_code;
   --
   l_bne_value := 'bne_contents_b';
   OPEN csr_int FOR
     'SELECT param_list_code ' ||
     ' FROM ' || l_bne_value ||
     ' WHERE content_code = ''' ||
         l_content_code ||
     ''' AND  application_id = '||
     p_application_id;
   --
   FETCH csr_int INTO l_param_list_code;
   IF l_param_list_code IS NULL THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289869_ADI_ADD_PARAM_FAIL');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   -- STEP 5.  Create Interface for API
   --
   l_bne_value := 'bne_integrator_utils.create_api_interface_and_map';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     '  (:1,:2,:3,:4,:5,:6,:7,:8,:9,:10,:11,:12,:13,:14,:15,:16,:17,:18); ' ||
     'END;';
   --
   EXECUTE IMMEDIATE l_sql_statement
     USING IN     p_application_id
          ,IN     l_object_code
          ,IN     l_integrator_code
          ,IN     upper(p_api_package_name)
          ,IN     upper(p_api_procedure_name)
          ,IN     p_interface_user_name
          ,IN     l_content_code
          ,IN     upper(p_view_name)
          ,IN     p_interface_param_name
          ,IN     p_api_type
          ,IN     p_api_return_type
          ,IN     5
          ,IN     p_language
          ,IN     p_language
          ,IN     p_user_id
          ,   OUT l_param_list_code
          ,   OUT l_interface_code
          ,   OUT l_mapping_code;
   --
   l_bne_value := 'bne_interface_cols_b';
   OPEN csr_int FOR
   --check interface created and has columns
   ' SELECT interface_code '||
   ' FROM '|| l_bne_value ||
   ' WHERE interface_code = (' ||
        ' SELECT interface_code'||
        ' FROM bne_interfaces_b' ||
        ' WHERE interface_code = ''' ||
           l_interface_code ||
        ''' AND application_id ='||
            p_application_id ||
   ') AND application_id = '||
     p_application_id;
   FETCH csr_int INTO l_igr_csr_id;
   IF csr_int%NOTFOUND THEN
      CLOSE csr_int;
      fnd_message.set_name('PER','PER_289870_ADI_IFACE_FAIL');
      fnd_message.raise_error;
   END IF;
   CLOSE csr_int;
   --
   -- Step 6. Set upload param list for integrator
   --
   l_bne_value := 'hr_integration_utils.add_hr_upload_list_to_integ';
   l_sql_statement :=
     'BEGIN ' ||
     l_bne_value ||
     '  (:1,:2); ' ||
     'END;';
   --
   EXECUTE IMMEDIATE l_sql_statement
     USING IN    p_application_id
          ,In    l_integrator_code;
   --
   -- STEP 7.  Associate integrator with a particular form.
   --
   IF p_form_name IS NOT NULL  and
      p_form_name <> 'GENERAL' THEN
      l_user_integrator_name := to_char(p_application_id) || ':' || l_integrator_code;
      l_bne_value := 'hr_integration_utils.register_integrator_to_form';
      l_sql_statement :=
        'BEGIN ' ||
        l_bne_value ||
        ' (:1,:2); ' ||
        'END;';
      EXECUTE IMMEDIATE l_sql_statement
                  USING IN     l_user_integrator_name
                       ,IN     p_form_name;
   END IF;
   --
 END create_update_data;
--
-------------------------------------------------------------------------------
-------------------------<Public procedure visible in header>------------------
-------------------------------------------------------------------------------
PROCEDURE  create_metadata(
    p_metadata_type        IN    varchar2
   ,p_application_id       IN    number
   ,p_integrator_user_name IN    varchar2
   ,p_view_name            IN    varchar2 default null
   ,p_form_name            IN    varchar2 default null
   ,p_api_package_name     IN    varchar2 default null
   ,p_api_procedure_name   IN    varchar2 default null
   ,p_interface_user_name  IN    varchar2 default null
   ,p_interface_param_name IN    varchar2 default null
   ,p_api_type             IN    varchar2 default null
   ,p_api_return_type      IN    varchar2 default null
   ) IS
--vars
   l_language        varchar2(100);
   l_user_id         number;
   l_package_name    varchar2(240) default null;
   l_procedure_name  varchar2(240) default null;
   l_form_name       varchar2(240) default null;
   l_api_type        varchar2(240) default null;
   l_api_return_type varchar2(240) default null;
--
BEGIN
   --get language and user_id
   SELECT
      fnd_global.user_id,
      userenv('LANG')
   INTO
      l_user_id,
      l_language
   FROM
      dual;
   -- UPPER parameters
   IF p_api_package_name IS NOT NULL THEN
      l_package_name := UPPER(p_api_package_name);
   END IF;
   IF p_api_procedure_name IS NOT NULL THEN
      l_procedure_name := UPPER(p_api_procedure_name);
   END IF;
   IF p_form_name IS NOT NULL THEN
      l_form_name := UPPER(p_form_name);
   END IF;
   IF p_api_type IS NOT NULL THEN
      l_api_type := UPPER(p_api_type);
   END IF;
   IF p_api_return_type IS NOT NULL THEN
      l_api_return_type := UPPER(p_api_return_type);
   END IF;
   --Validate return type if api type is function
   IF l_api_type ='FUNCTION' THEN
     IF p_api_return_type IS NULL THEN
      fnd_message.set_name('PER','PER_289928_INVAL_RET_TYPE');
      fnd_message.raise_error;
     END IF;
   END IF;
   --
   IF (UPPER(p_metadata_type) = 'DOWNLOAD')
   THEN
      create_download_data
        (p_application_id       =>  p_application_id
        ,p_integrator_user_name =>  p_integrator_user_name
        ,p_view_name            =>  p_view_name
        ,p_form_name            =>  l_form_name
        ,p_language             =>  l_language
        ,p_user_id              =>  l_user_id );
   --
   ELSIF (UPPER(p_metadata_type) = 'CREATE')
   THEN
      create_upload_data
        (p_application_id       => p_application_id
        ,p_integrator_user_name => p_integrator_user_name
        ,p_api_package_name     => l_package_name
        ,p_api_procedure_name   => l_procedure_name
        ,p_interface_user_name  => p_interface_user_name
        ,p_interface_param_name => p_interface_param_name
        ,p_api_type             => l_api_type
        ,p_api_return_type      => l_api_return_type
        ,p_language             => l_language
        ,p_user_id              => l_user_id);
   --
   ELSIF (UPPER(p_metadata_type) = 'UPDATE')
   THEN NULL;
     create_update_data
        (p_application_id       => p_application_id
        ,p_integrator_user_name => p_integrator_user_name
        ,p_api_package_name     => l_package_name
        ,p_api_procedure_name   => l_procedure_name
        ,p_interface_user_name  => p_interface_user_name
        ,p_interface_param_name => p_interface_param_name
        ,p_api_type             => l_api_type
        ,p_api_return_type      => l_api_return_type
        ,p_view_name            => p_view_name
        ,p_form_name            => l_form_name
        ,p_language             => l_language
        ,p_user_id              => l_user_id);
   ELSE
      fnd_message.set_name('PER','PER_289879_INVAL_META_TYPE');
      fnd_message.raise_error;
   END IF;
END create_metadata;
--
--
-- ---------------------------------------------------------------------------
-- |------------------------< create_standalone_query >----------------------|
-- ---------------------------------------------------------------------------
PROCEDURE create_standalone_query
  (p_application_id    in number
  ,p_intg_user_name    in varchar2
  ,p_sql               in varchar2
  ,p_param1_name       in varchar2 default NULL
  ,p_param1_type       in varchar2 default NULL
  ,p_param1_prompt     in varchar2 default NULL
  ,p_param2_name       in varchar2 default NULL
  ,p_param2_type       in varchar2 default NULL
  ,p_param2_prompt     in varchar2 default NULL
  ,p_param3_name       in varchar2 default NULL
  ,p_param3_type       in varchar2 default NULL
  ,p_param3_prompt     in varchar2 default NULL
  ,p_param4_name       in varchar2 default NULL
  ,p_param4_type       in varchar2 default NULL
  ,p_param4_prompt     in varchar2 default NULL
  ,p_param5_name       in varchar2 default NULL
  ,p_param5_type       in varchar2 default NULL
  ,p_param5_prompt     in varchar2 default NULL
  ) IS
  --
  -- Local variables
  l_param_identifier  varchar2(20) := '$PARAM$.';
  --
BEGIN
  --
  -- Check that params appear in the query.
  --
  IF ((p_param1_name IS NOT NULL) and
      (instr(p_sql,l_param_identifier||p_param1_name) = 0)) THEN
     --
     -- Param 1 does not appear in WHERE clause
     fnd_message.set_name('PER','PER_289713_ADI_INVALID_PARAM');
     fnd_message.raise_error;
     --
  ELSIF ((p_param2_name IS NOT NULL) and
      (instr(p_sql,l_param_identifier||p_param2_name) = 0)) THEN
     --
     -- Param 2 does not appear in WHERE clause
     fnd_message.set_name('PER','PER_289713_ADI_INVALID_PARAM');
     fnd_message.raise_error;
     --
  ELSIF ((p_param3_name IS NOT NULL) and
      (instr(p_sql,l_param_identifier||p_param3_name) = 0)) THEN
     --
     -- Param 3 does not appear in WHERE clause
     fnd_message.set_name('PER','PER_289713_ADI_INVALID_PARAM');
     fnd_message.raise_error;
     --
  ELSIF ((p_param4_name IS NOT NULL) and
      (instr(p_sql,l_param_identifier||p_param4_name) = 0)) THEN
     --
     -- Param 4 does not appear in WHERE clause
     fnd_message.set_name('PER','PER_289713_ADI_INVALID_PARAM');
     fnd_message.raise_error;
     --
  ELSIF ((p_param5_name IS NOT NULL) and
      (instr(p_sql,l_param_identifier||p_param5_name) = 0)) THEN
     --
     -- Param 5 does not appear in WHERE clause
     fnd_message.set_name('PER','PER_289713_ADI_INVALID_PARAM');
     fnd_message.raise_error;
     --
  ELSE
    hr_integration_utils.add_sql_to_content
      (p_application_id    => p_application_id
      ,p_intg_user_name    => p_intg_user_name
      ,p_sql               => p_sql
      ,p_param1_name       => p_param1_name
      ,p_param1_type       => p_param1_type
      ,p_param1_prompt     => p_param1_prompt
      ,p_param2_name       => p_param2_name
      ,p_param2_type       => p_param2_type
      ,p_param2_prompt     => p_param2_prompt
      ,p_param3_name       => p_param3_name
      ,p_param3_type       => p_param3_type
      ,p_param3_prompt     => p_param3_prompt
      ,p_param4_name       => p_param4_name
      ,p_param4_type       => p_param4_type
      ,p_param4_prompt     => p_param4_prompt
      ,p_param5_name       => p_param5_name
      ,p_param5_type       => p_param5_type
      ,p_param5_prompt     => p_param5_prompt
      );
    --
  END IF;
END create_standalone_query;
--
-- ---------------------------------------------------------------------------
-- |----------------------< maintain_standalone_query >----------------------|
-- ---------------------------------------------------------------------------
PROCEDURE maintain_standalone_query
  (p_application_id    in number
  ,p_intg_user_name    in varchar2
  ,p_sql               in varchar2 default null
  ,p_param1_name       in varchar2 default null
  ,p_param1_type       in varchar2 default null
  ,p_param1_prompt     in varchar2 default null
  ,p_param2_name       in varchar2 default null
  ,p_param2_type       in varchar2 default null
  ,p_param2_prompt     in varchar2 default null
  ,p_param3_name       in varchar2 default null
  ,p_param3_type       in varchar2 default null
  ,p_param3_prompt     in varchar2 default null
  ,p_param4_name       in varchar2 default null
  ,p_param4_type       in varchar2 default null
  ,p_param4_prompt     in varchar2 default null
  ,p_param5_name       in varchar2 default null
  ,p_param5_type       in varchar2 default null
  ,p_param5_prompt     in varchar2 default null
  ) IS
  --
  --
  TYPE CSR_TYP IS REF CURSOR;
  csr_int CSR_TYP;
  --
  -- Local variables
  --
  l_integrator_code    varchar2(30);
  l_content_code       varchar2(30);
  l_sql                varchar2(2000);
  l_param_list_code    varchar2(30);
  l_param_list_app_id  number;
  --
BEGIN
  --
  -- Have integrator user name - determine integrator code
  --
  OPEN csr_int FOR
    'SELECT b.integrator_code ' ||
    '  FROM bne_integrators_tl t ' ||
    '     , bne_integrators_b b ' ||
    ' WHERE t.application_id = ' || p_application_id ||
    '   AND t.user_name = ''' || p_intg_user_name  || '''' ||
    '   AND t.integrator_code = b.integrator_code ' ||
    '   AND t.application_id = b.application_id ' ||
    '   AND t.integrator_code like ''GENERAL%'' ' ||
    '   AND b.enabled_flag = ''Y'' ';
  FETCH csr_int INTO l_integrator_code;
  --
  IF csr_int%NOTFOUND THEN
    --
    CLOSE csr_int;
    fnd_message.set_name('PER','PER_289428_ADI_INTG_NOT_EXIST');
    fnd_message.raise_error;
    --
  END IF;
  CLOSE csr_int;
  --
  -- Have integrator code, and integrator exists.  Now we
  -- want to determine the parameter list for the content
  -- for the integrator, and remove it completely.
  -- This will be rebuilt when we create the query again.
  --
  OPEN csr_int FOR
    'SELECT param_list_app_id, ' ||
    '       param_list_code, ' ||
    '       content_code ' ||
    '  FROM bne_contents_b ' ||
    ' WHERE integrator_app_id = '||p_application_id ||
    '   AND integrator_code = ''' ||l_integrator_code || ''' ';
  --
  FETCH csr_int INTO l_param_list_app_id, l_param_list_code, l_content_code;
  --
  IF csr_int%FOUND THEN
    IF l_param_list_code <> 'HR_STANDARD' Then
     --
     -- Parameter list exists for this content, so delete it.
     --
     l_sql := 'BEGIN ' ||
              '  DELETE FROM bne_param_list_items ' ||
              '  WHERE application_id = :1 ' ||
              '    AND param_list_code = :2 ;' ||
              'END; ';
     EXECUTE IMMEDIATE l_sql
       USING IN l_param_list_app_id,
             IN l_param_list_code;
     --
     l_sql := 'BEGIN ' ||
              '  DELETE from bne_param_lists_tl ' ||
              '  WHERE application_id = :1 ' ||
              '    AND param_list_code = :2 ;' ||
              'END; ';
     EXECUTE IMMEDIATE l_sql
       USING IN l_param_list_app_id,
             IN l_param_list_code;
     --
     l_sql := 'BEGIN ' ||
              '  DELETE from bne_param_lists_b ' ||
              '  WHERE application_id = :1 ' ||
              '    AND param_list_code = :2 ;' ||
              'END; ';
     EXECUTE IMMEDIATE l_sql
       USING IN l_param_list_app_id,
             IN l_param_list_code;
     --
     -- Update content to reflect deleted param list
     l_sql := 'BEGIN ' ||
              '  UPDATE bne_contents_b ' ||
              '     SET param_list_app_id = 800 ' ||
              '       , param_list_code = ''HR_STANDARD'' ' ||
              '       , object_version_number = object_version_number + 1 ' ||
              '   WHERE integrator_app_id = :1 ' ||
              '     AND integrator_code = :2; ' ||
              'END; ';
     EXECUTE IMMEDIATE l_sql
        USING IN p_application_id,
              IN l_integrator_code;
    END IF;
     --
     --
     -- Update SQL and re-create param list if necessary
     --
     IF p_sql IS NOT NULL THEN
        --
        -- Can call the create one, as it will update the
        -- stored SQL
        create_standalone_query
          (p_application_id => p_application_id,
           p_intg_user_name => p_intg_user_name,
           p_sql            => p_sql,
           p_param1_name    => p_param1_name,
           p_param1_type    => p_param1_type,
           p_param1_prompt  => p_param1_prompt,
           p_param2_name    => p_param2_name,
           p_param2_type    => p_param2_type,
           p_param2_prompt  => p_param2_prompt,
           p_param3_name    => p_param3_name,
           p_param3_type    => p_param3_type,
           p_param3_prompt  => p_param3_prompt,
           p_param4_name    => p_param4_name,
           p_param4_type    => p_param4_type,
           p_param4_prompt  => p_param4_prompt,
           p_param5_name    => p_param5_name,
           p_param5_type    => p_param5_type,
           p_param5_prompt  => p_param5_prompt);
     ELSE
        -- update to null
        l_sql := 'BEGIN ' ||
                 ' DELETE FROM bne_stored_sql ' ||
                 '  WHERE content_code = :1 ' ||
                 '    AND application_id = :2; ' ||
                 'END; ';
        EXECUTE IMMEDIATE l_sql
          USING IN l_content_code,
                IN p_application_id;
        --
     END IF;
  ELSE
     -- Could not find a query, etc for given integrator.
     -- Therefore create one, if query is not null
     --
     IF p_sql IS NOT NULL THEN
        --
        -- Call to create
        --
        create_standalone_query
          (p_application_id => p_application_id,
           p_intg_user_name => p_intg_user_name,
           p_sql            => p_sql,
           p_param1_name    => p_param1_name,
           p_param1_type    => p_param1_type,
           p_param1_prompt  => p_param1_prompt,
           p_param2_name    => p_param2_name,
           p_param2_type    => p_param2_type,
           p_param2_prompt  => p_param2_prompt,
           p_param3_name    => p_param3_name,
           p_param3_type    => p_param3_type,
           p_param3_prompt  => p_param3_prompt,
           p_param4_name    => p_param4_name,
           p_param4_type    => p_param4_type,
           p_param4_prompt  => p_param4_prompt,
           p_param5_name    => p_param5_name,
           p_param5_type    => p_param5_type,
           p_param5_prompt  => p_param5_prompt);
        --
     END IF;
     --
  END IF;
  CLOSE csr_int;
  --
END maintain_standalone_query;
--
END hr_ade_adi_data_setup;

/
