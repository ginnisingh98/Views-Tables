--------------------------------------------------------
--  DDL for Package Body JTM_CON_QUERY_REQUEST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTM_CON_QUERY_REQUEST_PKG" AS
/* $Header: jtmconqb.pls 120.3 2006/01/13 03:20:18 trajasek noship $ */

/*** Globals ***/
G_PACKAGE_NAME  constant   VARCHAR2(30) := 'JTM_CON_QUERY_REQUEST_PKG';
g_debug_level      NUMBER; -- debug level
g_category         varchar2(30);

/*** cursor retrieving query request properties ***/
CURSOR c_query_requests IS
  SELECT con_query_id
  ,      acc_table_name
  ,      con_query
  ,      last_run_date
 FROM   jtm_con_query_request_data
 WHERE EXECUTE_FLAG='Y'
 ORDER BY execution_order;


 /*** cursor retriving the primary key of pub_item associated with this query ***/
 CURSOR c_primary_key(b_con_query_id NUMBER) IS
 SELECT distinct pubitm.primary_key_column
  FROM   asg_pub_item               pubitm
  , 	 jtm_pub_acc		pubacc
  WHERE  pubacc.publication_item_name = pubitm.name
  AND    pubacc.con_query_id = b_con_query_id
  AND    pubacc.execute_flag = 'Y'
  AND    pubitm.status = 'Y'
  AND    pubitm.enabled = 'Y';

/*** cursor retrieving list of resources subscribed to publication item ***/
  --Bug 4924543
  CURSOR c_item_resources( b_pub_item_name VARCHAR2 )
   IS
	SELECT au.resource_id
    FROM   asg_user           au
    ,      asg_user_pub_resps aupr
    ,      asg_pub_item       api
    WHERE  au.user_name  = aupr.user_name
    AND    aupr.pub_name = api.pub_name
    AND    api.name 	 = b_pub_item_name
    AND    au.enabled  	 = 'Y'
	AND    api.ENABLED 	 = 'Y';



PROCEDURE WorkAround is
l_status varchar2(80);
l_message varchar2(2000);
BEGIN
    FIX_DFF_ACC(l_status, l_message);
END WorkAround;

PROCEDURE FIX_DFF_ACC(
    P_Status       OUT NOCOPY  VARCHAR2,
    P_Message      OUT NOCOPY  VARCHAR2) IS

    Cursor get_dff_seed_date is
    select creation_date, application_id,
           base_application_id, descriptive_flexfield_name
    from JTM_FND_DESCR_FLEXS_ACC;

   Cursor get_old_context_acc (
       p_creation_date date, p_appl_id number, p_dff_name in varchar2) is
   select access_id
   from   JTM_FND_DESC_FLEX_CONTEXT_ACC
   where  creation_date < p_creation_date
   and    APPLICATION_ID = p_appl_id
   and    DESCRIPTIVE_FLEXFIELD_NAME = p_dff_name;

   Cursor get_old_col_usg_acc (
       p_creation_date date, p_appl_id number, p_dff_name in varchar2) is
   select access_id
   from   JTM_FND_DESC_FLEX_COL_USG_ACC
   where  creation_date < p_creation_date
   and    APPLICATION_ID = p_appl_id
   and    DESCRIPTIVE_FLEXFIELD_NAME = p_dff_name;

   Cursor get_old_value_acc (
       p_creation_date date, p_appl_id number, p_dff_name in varchar2) is
   select access_id
   from   JTM_FND_FLEX_VALUES_ACC
   where  creation_date < p_creation_date
   AND flex_value_id IN
  (SELECT V.flex_value_id
  FROM fnd_descr_flex_column_usages bas, FND_FLEX_VALUES V
  WHERE bas.application_id = p_appl_id
  AND bas.descriptive_flexfield_name = p_dff_name
  AND bas.FLEX_VALUE_SET_ID = V.FLEX_VALUE_SET_ID
  );

   Cursor get_old_value_set_acc (
       p_creation_date date, p_appl_id number, p_dff_name in varchar2) is
   select access_id
   from jtm_fnd_flex_value_sets_acc
   where  creation_date < p_creation_date
   and flex_value_set_id IN
  (SELECT FLEX_VALUE_SET_ID
  FROM fnd_descr_flex_column_usages bas
  WHERE bas.application_id = p_appl_id
  AND bas.descriptive_flexfield_name = p_dff_name
  );
  L_API_NAME constant varchar2(30) := 'FIX_DFF_ACC';

  l_csl_tab_user     ASG_DOWNLOAD.USER_LIST;
  l_csm_tab_user     ASG_DOWNLOAD.USER_LIST;
  l_tab_user        ASG_DOWNLOAD.USER_LIST;
  l_pub_item   varchar2(30);
  l_dummy      BOOLEAN;
BEGIN

   P_Status := G_FINE;
   P_Message := 'All are working.';

   /*** get debug level ***/
   g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     JTM_message_log_pkg.Log_Msg
     ( v_object_id   => L_API_NAME
     , v_object_name => G_PACKAGE_NAME
     , v_message     => 'The procedure begins execution.'
     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     , v_module      => 'jtm_message_log_pkg');
   END IF;

   select  u.user_id BULK COLLECT INTO l_csl_tab_user
   from    asg_user u, asg_user_Pub_resps r
   where   u.user_name = r.user_name
   and     r.pub_name = 'JTM';

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     JTM_message_log_pkg.Log_Msg
     ( v_object_id   => L_API_NAME
     , v_object_name => G_PACKAGE_NAME
     , v_message     => 'There are ' || l_csl_tab_user.count || ' mobile laptop users.'
     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     , v_module      => 'jtm_message_log_pkg');
   END IF;

   select  u.user_id BULK COLLECT INTO l_csm_tab_user
   from    asg_user u, asg_user_Pub_resps r
   where   u.user_name = r.user_name
   and     r.pub_name = 'JTM_HANDHELD';

   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     JTM_message_log_pkg.Log_Msg
     ( v_object_id   => L_API_NAME
     , v_object_name => G_PACKAGE_NAME
     , v_message     => 'There are ' || l_csm_tab_user.count || ' mobile pocket pc users.'
     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     , v_module      => 'jtm_message_log_pkg');
   END IF;

   FOR c_seed_date in get_dff_seed_date  LOOP
       /* Handle the DFF context */
       BEGIN
           FOR c_old_context_acc in get_old_context_acc(
              c_seed_date.creation_date,
              c_seed_date.base_application_id,
              c_seed_date.descriptive_flexfield_name) LOOP
               BEGIN
                  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
                     JTM_message_log_pkg.Log_Msg
                     ( v_object_id   => L_API_NAME
                     , v_object_name => G_PACKAGE_NAME
                     , v_message     => 'Handling DFF '||
                      c_seed_date.descriptive_flexfield_name || ' context (acc id ='
                      || c_old_context_acc.access_id || ')'
                     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
                     , v_module      => 'jtm_message_log_pkg');
                  END IF;
                  IF (c_seed_date.application_id = 883)  THEN
                    l_tab_user := l_csm_tab_user;
                    l_pub_item := 'JTM_H_DESC_FLEX_CONTEXTS';
                  ELSIF (c_seed_date.application_id = 868) THEN
                    l_tab_user := l_csl_tab_user;
                    l_pub_item := 'FND_DESC_FLEX_CONTEXTS';
                  END IF;

                  FOR i IN l_tab_user.FIRST..l_tab_user.LAST LOOP
                     l_dummy := asg_download.mark_dirty (
                            p_pub_item         => l_pub_item,
                            p_accessid         => c_old_context_acc.access_id,
                            p_userid           => l_tab_user(i),
                            p_dml              => 'I',
                            p_timestamp        => sysdate );
                  END LOOP;

                  Update JTM_FND_DESC_FLEX_CONTEXT_ACC
                  set creation_date = c_seed_date.creation_date
                  where access_id = c_old_context_acc.access_id;

                  commit;
               EXCEPTION
                  WHEN OTHERS THEN
                      P_Status := G_ERROR;
                      P_Message := 'Exception ocurrs with DFF ' ||
                      c_seed_date.descriptive_flexfield_name || ' context (acc id ='
                      || c_old_context_acc.access_id || '): ' || sqlerrm;
                      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                        JTM_message_log_pkg.Log_Msg
                          ( v_object_id   => L_API_NAME
                          , v_object_name => G_PACKAGE_NAME
                          , v_message     => P_Message
                          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                          , v_module      => 'jtm_message_log_pkg');
                      END IF;
               END;
           END LOOP;
       EXCEPTION
          WHEN OTHERS THEN
              P_Status := G_ERROR;
              P_Message := 'Exception ocurrs with DFF ' ||
                   c_seed_date.descriptive_flexfield_name || ' context ' || sqlerrm;
              IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                JTM_message_log_pkg.Log_Msg
                  ( v_object_id   => L_API_NAME
                  , v_object_name => G_PACKAGE_NAME
                  , v_message     => P_Message
                  , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                  , v_module      => 'jtm_message_log_pkg');
              END IF;
       END; /* Handle the DFF context */

       BEGIN  /* Handle the DFF column usage */
           FOR c_old_col_usg_acc in get_old_col_usg_acc(
               c_seed_date.creation_date,
               c_seed_date.base_application_id,
               c_seed_date.descriptive_flexfield_name) LOOP
               BEGIN
                   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
                     JTM_message_log_pkg.Log_Msg
                     ( v_object_id   => L_API_NAME
                     , v_object_name => G_PACKAGE_NAME
                     , v_message     => 'Handling DFF '||
                      c_seed_date.descriptive_flexfield_name || ' segment (acc id ='
                      || c_old_col_usg_acc.access_id || ')'
                     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
                     , v_module      => 'jtm_message_log_pkg');
                   END IF;
                   IF (c_seed_date.application_id = 883)  THEN
                        l_tab_user := l_csm_tab_user;
                        l_pub_item := 'JTM_H_DESC_FLEX_COL_USGS';
                   ELSIF (c_seed_date.application_id = 868) THEN
                        l_tab_user := l_csl_tab_user;
                        l_pub_item := 'FND_DESC_FLEX_COL_USGS';
                   END IF;

                   FOR i IN l_tab_user.FIRST..l_tab_user.LAST LOOP
                         l_dummy := asg_download.mark_dirty (
                                p_pub_item         => l_pub_item,
                                p_accessid         => c_old_col_usg_acc.access_id,
                                p_userid           => l_tab_user(i),
                                p_dml              => 'I',
                                p_timestamp        => sysdate );
                   END LOOP;

                   Update JTM_FND_DESC_FLEX_COL_USG_ACC
                   set creation_date = c_seed_date.creation_date
                   where access_id = c_old_col_usg_acc.access_id;

                   commit;
               EXCEPTION
                  WHEN OTHERS THEN
                      P_Status := G_ERROR;
                      P_Message := 'Exception ocurrs with DFF ' ||
                      c_seed_date.descriptive_flexfield_name || ' segment (acc id ='
                      || c_old_col_usg_acc.access_id || '): ' || sqlerrm;
                      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                        JTM_message_log_pkg.Log_Msg
                          ( v_object_id   => L_API_NAME
                          , v_object_name => G_PACKAGE_NAME
                          , v_message     => P_Message
                          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                          , v_module      => 'jtm_message_log_pkg');
                      END IF;
               END;
           END LOOP;
       EXCEPTION
          WHEN OTHERS THEN
              P_Status := G_ERROR;
              P_Message := 'Exception ocurrs with DFF ' ||
                      c_seed_date.descriptive_flexfield_name || ' segments: ' || sqlerrm;
              IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                JTM_message_log_pkg.Log_Msg
                  ( v_object_id   => L_API_NAME
                  , v_object_name => G_PACKAGE_NAME
                  , v_message     => P_Message
                  , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                  , v_module      => 'jtm_message_log_pkg');
              END IF;
       END; /* Handle the DFF column usage */

       BEGIN /* Handle the DFF value */
           FOR c_old_value_acc in get_old_value_acc(
               c_seed_date.creation_date,
               c_seed_date.base_application_id,
               c_seed_date.descriptive_flexfield_name) LOOP
               BEGIN
                   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
                     JTM_message_log_pkg.Log_Msg
                     ( v_object_id   => L_API_NAME
                     , v_object_name => G_PACKAGE_NAME
                     , v_message     => 'Handling DFF '||
                      c_seed_date.descriptive_flexfield_name || ' value (acc id ='
                      || c_old_value_acc.access_id || ')'
                     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
                     , v_module      => 'jtm_message_log_pkg');
                   END IF;
                   IF (c_seed_date.application_id = 883)  THEN
                        l_tab_user := l_csm_tab_user;
                        l_pub_item := 'JTM_H_FLEX_VALUES';
                   ELSIF (c_seed_date.application_id = 868) THEN
                        l_tab_user := l_csl_tab_user;
                        l_pub_item := 'FND_FLEX_VALUES';
                   END IF;

                   FOR i IN l_tab_user.FIRST..l_tab_user.LAST LOOP
                         l_dummy := asg_download.mark_dirty (
                                p_pub_item         => l_pub_item,
                                p_accessid         => c_old_value_acc.access_id,
                                p_userid           => l_tab_user(i),
                                p_dml              => 'I',
                                p_timestamp        => sysdate );
                   END LOOP;

                   Update JTM_FND_FLEX_VALUES_ACC
                   set creation_date = c_seed_date.creation_date
                   where access_id = c_old_value_acc.access_id;

                   commit;
              EXCEPTION
                  WHEN OTHERS THEN
                      P_Status := G_ERROR;
                      P_Message := 'Exception ocurrs with DFF ' ||
                       c_seed_date.descriptive_flexfield_name || ' values (acc id ='
                      || c_old_value_acc.access_id || '): ' || sqlerrm;
                      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                        JTM_message_log_pkg.Log_Msg
                          ( v_object_id   => L_API_NAME
                          , v_object_name => G_PACKAGE_NAME
                          , v_message     => P_Message
                          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                          , v_module      => 'jtm_message_log_pkg');
                      END IF;
              END;
          END LOOP;
       EXCEPTION
          WHEN OTHERS THEN
              P_Status := G_ERROR;
              P_Message := 'Exception ocurrs with DFF value: ' ||
                       c_seed_date.descriptive_flexfield_name || ' values: '  || sqlerrm;
              IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                JTM_message_log_pkg.Log_Msg
                  ( v_object_id   => L_API_NAME
                  , v_object_name => G_PACKAGE_NAME
                  , v_message     => P_Message
                  , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                  , v_module      => 'jtm_message_log_pkg');
              END IF;
       END;  /* Handle the DFF value */

       BEGIN  /* Handle the DFF value set */
            FOR c_old_value_set_acc in get_old_value_set_acc(
               c_seed_date.creation_date,
               c_seed_date.base_application_id,
               c_seed_date.descriptive_flexfield_name) LOOP
               BEGIN
                   IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
                     JTM_message_log_pkg.Log_Msg
                     ( v_object_id   => L_API_NAME
                     , v_object_name => G_PACKAGE_NAME
                     , v_message     => 'Handling DFF '||
                      c_seed_date.descriptive_flexfield_name || ' value set (acc id ='
                      || c_old_value_set_acc.access_id || ')'
                     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
                     , v_module      => 'jtm_message_log_pkg');
                   END IF;
                   IF (c_seed_date.application_id = 883)  THEN
                        l_tab_user := l_csm_tab_user;
                        l_pub_item := 'JTM_H_FLEX_VALUE_SETS';
                   ELSIF (c_seed_date.application_id = 868) THEN
                        l_tab_user := l_csl_tab_user;
                        l_pub_item := 'FND_FLEX_VALUE_SETS';
                   END IF;

                   FOR i IN l_tab_user.FIRST..l_tab_user.LAST LOOP
                         l_dummy := asg_download.mark_dirty (
                                p_pub_item         => l_pub_item,
                                p_accessid         => c_old_value_set_acc.access_id,
                                p_userid           => l_tab_user(i),
                                p_dml              => 'I',
                                p_timestamp        => sysdate );
                   END LOOP;

                   Update JTM_FND_FLEX_VALUE_SETS_ACC
                   set creation_date = c_seed_date.creation_date
                   where access_id = c_old_value_set_acc.access_id;

                   commit;
               EXCEPTION
                  WHEN OTHERS THEN
                      P_Status := G_ERROR;
                      P_Message := 'Exception ocurrs with DFF ' ||
                       c_seed_date.descriptive_flexfield_name || ' value set(acc id ='
                      || c_old_value_set_acc.access_id || '): ' || sqlerrm;
                      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                        JTM_message_log_pkg.Log_Msg
                          ( v_object_id   => L_API_NAME
                          , v_object_name => G_PACKAGE_NAME
                          , v_message     => P_Message
                          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                          , v_module      => 'jtm_message_log_pkg');
                      END IF;
               END;
           END LOOP;
       EXCEPTION
           WHEN OTHERS THEN
              P_Status := G_ERROR;
              P_Message := 'Exception ocurrs with DFF ' ||
                       c_seed_date.descriptive_flexfield_name || ' values: '  || sqlerrm;
              IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
                JTM_message_log_pkg.Log_Msg
                  ( v_object_id   => L_API_NAME
                  , v_object_name => G_PACKAGE_NAME
                  , v_message     => P_Message
                  , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
                  , v_module      => 'jtm_message_log_pkg');
              END IF;
       END;   /* Handle the DFF value set */

   END LOOP;
EXCEPTION
   WHEN OTHERS THEN
      P_Status := G_ERROR;
      P_Message := 'Exception ocurrs: ' || sqlerrm;
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
        JTM_message_log_pkg.Log_Msg
          ( v_object_id   => L_API_NAME
          , v_object_name => G_PACKAGE_NAME
          , v_message     => P_Message
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
          , v_module      => 'jtm_message_log_pkg');
      END IF;

END FIX_DFF_ACC;

FUNCTION GET_CATEGORY RETURN VARCHAR2 IS
l_category varchar2(80);
BEGIN
   SELECT category
   INTO l_category
   FROM   jtm_con_request_data
   WHERE upper(package_name) = 'JTM_CON_QUERY_REQUEST_PKG'
   AND upper(procedure_name) = 'RUN_QUERY_REQUESTS';

   return l_category;
EXCEPTION
   WHEN others then
   return null;
END GET_CATEGORY;

FUNCTION GET_CONDITION(p_primary_key IN VARCHAR2,
                       P_ALIAS1 IN VARCHAR2,
                       P_ALIAS2 IN VARCHAR2) RETURN VARCHAR2 IS
L_CONDITION VARCHAR2(4000);
l_column_name VARCHAR2(200);
l_alias1 VARCHAR2(200);
l_alias2 VARCHAR2(200);

l_index1 number;
l_index2 number;

BEGIN
     L_CONDITION := NULL;
     l_index1 := 1;
     l_alias1 := LTRIM(RTRIM(P_ALIAS1));
     l_alias2 := LTRIM(RTRIM(P_ALIAS2));
     LOOP
        l_index2 := INSTR(p_primary_key, ',', l_index1, 1);
        IF (l_index2 > 0) THEN
            l_column_name := LTRIM(RTRIM(SUBSTR(p_primary_key,l_index1,l_index2-l_index1)));
        ELSE
            l_column_name := LTRIM(RTRIM(SUBSTR(p_primary_key,l_index1,LENGTH(p_primary_key)+1-l_index1)));
        END IF;

        IF (l_index1 = 1) then
           L_CONDITION := ' ' || l_alias1 || '.' || l_column_name || ' = ' ||
                          l_alias2 || '.' || l_column_name || ' ';
        ELSE
           L_CONDITION := L_CONDITION || 'AND ' || l_alias1 || '.' || l_column_name || ' = ' ||
                          l_alias2 || '.' || l_column_name || ' ' ;
        END IF;

        IF (l_index2 <= 0) THEN
            EXIT;
        END IF;
        l_index1 := l_index2 +1;
     END LOOP;
     RETURN L_CONDITION;
END;

FUNCTION markdirty_helper(
        		p_con_query_id IN NUMBER
        		,p_accessList  IN ASG_DOWNLOAD.ACCESS_LIST
        		,p_dml_type IN CHAR
        		) RETURN BOOLEAN IS

  TYPE pitnameTab IS TABLE OF JTM_PUB_ACC.PUBLICATION_ITEM_NAME%TYPE INDEX BY BINARY_INTEGER;
  l_publication_item_name pitnameTab;

  local_item_resources   c_item_resources%ROWTYPE;
  local_tab_resource     ASG_DOWNLOAD.USER_LIST;
  l_dummy                BOOLEAN;
  j                      BINARY_INTEGER;

BEGIN
	SELECT publication_item_name BULK COLLECT INTO l_publication_item_name
	FROM JTM_PUB_ACC WHERE CON_QUERY_ID = p_con_query_id;

	IF(l_publication_item_name.COUNT >0) THEN
       FOR j IN l_publication_item_name.FIRST..l_publication_item_name.LAST LOOP

          OPEN c_item_resources(l_publication_item_name(j));
  	      FETCH c_item_resources BULK COLLECT INTO local_tab_resource;

          IF c_item_resources%ROWCOUNT >  0 THEN
             l_dummy := asg_download.markDirty (
            	       p_pub_item       => l_publication_item_name(j)
                       ,p_accessList    => p_accessList
                       ,p_resourceList  => local_tab_resource
                       ,p_dml_type      => p_dml_type
                       ,p_timestamp     => SYSDATE
                       ,p_bulk_flag  => TRUE
                       );
          END IF;
  	      CLOSE c_item_resources;
       END LOOP;
   END IF;

   RETURN TRUE;

EXCEPTION
  WHEN OTHERS THEN
  CLOSE c_item_resources;
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => l_publication_item_name(j)
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'exception thrown in '||G_PACKAGE_NAME||'.markdirty_helper.'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , v_module      => 'jtm_message_log_pkg');
    END IF;
    RAISE;
    RETURN FALSE;

END markdirty_helper;

PROCEDURE Process_Request
  (r_query_request c_query_requests%ROWTYPE
  ,p_status  out nocopy varchar2
  ,p_message out nocopy varchar2) IS

  l_query_start  DATE;
  l_dynamic_stmt VARCHAR2(4000);

  l_primary_key VARCHAR2(4000);
  l_original_primary_key VARCHAR2(4000);
  l_tab_access_id dbms_sql.Number_Table;
  m_tab_access_id ASG_DOWNLOAD.ACCESS_LIST;

  l_cursor             INTEGER;
  l_count              INTEGER;
  l_index              NUMBER;

  l_dummy              BOOLEAN;
  l_start_log_id       NUMBER;
  l_status             varchar2(1);
  l_message            varchar2(2000);
  l_tmp_stmt		   varchar2(2000);

BEGIN
  p_status := G_FINE;
  p_message := 'OK';
  l_query_start := sysdate;


  JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => r_query_request.con_query_id
    ,v_query_stmt => G_CATEGORY
    ,v_start_time => l_query_start
    ,v_end_time => NULL
    ,v_status => 'Running'
    ,v_message => 'Processing for table ' ||r_query_request.acc_table_name
    ,x_log_id => l_start_log_id
    ,x_status => l_status
    ,x_msg_data => l_message);

  IF (l_status = 'E') THEN
      RAISE JTM_MESSAGE_LOG_PKG.G_EXC_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
     JTM_message_log_pkg.Log_Msg
     ( v_object_id   => null
     , v_object_name => G_PACKAGE_NAME
     , v_message     => 'Entering '||G_PACKAGE_NAME||'.PROCESS_REQUEST'
     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
     , v_module      => 'jtm_message_log_pkg');
  END IF;

  /** get primary_key of corresponding publication item  **/
  OPEN c_primary_key(r_query_request.con_query_id);
  FETCH c_primary_key into l_primary_key;
    l_original_primary_key := l_primary_key;
  IF (r_query_request.acc_table_name = 'JTM_FND_PROF_OPTIONS_VAL_ACC') THEN
     begin
        l_primary_key := replace (l_primary_key, 'LEVEL_VALUE_APPLICATION_ID',
                                  'NVL(LEVEL_VALUE_APPLICATION_ID, -1)');
     exception
         WHEN OTHERS THEN
            null;
     end;
  END IF;

  IF c_primary_key%ROWCOUNT = 0 THEN
  /*** no application subscribed -> ignore this query ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'No application subscribed to query ' ||
         r_query_request.con_query_id || '.' ||
         fnd_global.local_chr(10) || 'Ignoring this query.'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , v_module      => 'jtm_message_log_pkg');
    END IF;

   p_status  := G_ERROR;
   p_message := 'No primary key found for pub item related to query id ' ||
                r_query_request.con_query_id;
  ELSE

    /*** one or more resources subscribed -> process publication item ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'There is at lesst one application regiesterd to this query'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    /***  PROCESS UPDATES  ***/

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Processing UPDATES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    /*** Check if query ran before ***/
    IF r_query_request.last_run_date IS NOT NULL THEN
        /*** Yes -> Get access_id of records that were updated since last_run_date  ***/
        l_dynamic_stmt := 'SELECT ACCESS_ID FROM ' || r_query_request.acc_table_name ||
          ' ACC WHERE (' || l_primary_key || ') IN (SELECT ' ||
          l_primary_key || ' FROM (' || r_query_request.con_query || ') B ' ||
          'WHERE B.LAST_UPDATE_DATE >= :last_run_date)';
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
          JTM_message_log_pkg.Log_Msg
          ( v_object_id   => r_query_request.acc_table_name
          , v_object_name => G_PACKAGE_NAME
          , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt || fnd_global.local_chr(10) ||
            'LAST_RUN_DATE = ' || to_char(r_query_request.last_run_date)
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
          , v_module      => 'jtm_message_log_pkg');
        END IF;
        l_cursor := dbms_sql.open_cursor;
        dbms_sql.parse( l_cursor, l_dynamic_stmt, dbms_sql.v7);
        dbms_sql.bind_variable( l_cursor, 'last_run_date', r_query_request.last_run_date);
        l_index := 1;
        l_tab_access_id.DELETE;
        dbms_sql.define_array( l_cursor, 1, l_tab_access_id, 100, l_index);
        l_count := dbms_sql.execute( l_cursor );
        LOOP
          l_count := dbms_sql.fetch_rows(l_cursor);
          dbms_sql.column_value( l_cursor, '1', l_tab_access_id);
          EXIT WHEN l_count <> 100;
        END LOOP;
        dbms_sql.close_cursor( l_cursor );

      IF l_tab_access_id.COUNT > 0 THEN
        /*** 1 or more acc rows retrieved -> push to resources ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          JTM_message_log_pkg.Log_Msg
          ( v_object_id   => r_query_request.acc_table_name
          , v_object_name => G_PACKAGE_NAME
          , v_message     => 'Pushing ' || l_tab_access_id.COUNT || ' updated record(s) to subscribed resources.'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
          , v_module      => 'jtm_message_log_pkg');
        END IF;

         FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
       		m_tab_access_id(i) := l_tab_access_id(i);
         END LOOP;

         l_dummy := markdirty_helper(
      		p_con_query_id => r_query_request.con_query_id
       		,p_accessList  => m_tab_access_id
       		,p_dml_type => 'U');
      END IF;

    END IF; -- process UPDATES

    /***  PROCESS INSERTS ***/
    /***
      Insert new records to in ACC with COUNTER = 0.
      Then select all ACCESS_IDs from ACC where COUNTER = 0.
      Then update COUNTER to 1.
      This is a workaround for the fact that INSERT INTO with subquery cannot be used
      in combination with RETURNING and we need the ACCESS_IDs to push the records to the
      mobile users.
    ***/

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Processing INSERTS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    IF (r_query_request.acc_table_name = 'JTM_FND_PROF_OPTIONS_VAL_ACC') THEN
        l_dynamic_stmt :=
           'INSERT INTO JTM_FND_PROF_OPTIONS_VAL_ACC ' ||
           '(APPLICATION_ID,LEVEL_ID,LEVEL_VALUE, ' ||
           'LEVEL_VALUE_APPLICATION_ID,PROFILE_OPTION_ID, ' ||
           'ACCESS_ID, COUNTER, LAST_UPDATE_DATE, LAST_UPDATED_BY, ' ||
           'CREATION_DATE, CREATED_BY) ' ||
           'SELECT V.APPLICATION_ID,V.LEVEL_ID,V.LEVEL_VALUE, ' ||
           'NVL(V.LEVEL_VALUE_APPLICATION_ID, -1), ' ||
           'V.PROFILE_OPTION_ID, ' ||
           'JTM_ACC_TABLE_S.NEXTVAL, 0, SYSDATE, 1, SYSDATE, 1 ' ||
           'FROM FND_PROFILE_OPTION_VALUES V, ' ||
           '     JTM_FND_PROF_OPTIONS_VAL_ACC ACC ' ||
           'WHERE V.APPLICATION_ID IN ' ||
           ' (0,170,178,222,401,513,523,544,690,697,868,874,689,883) ' ||
           'AND V.APPLICATION_ID = ACC.APPLICATION_ID(+) ' ||
           'AND V.LEVEL_ID = ACC.LEVEL_ID(+) ' ||
           'AND V.LEVEL_VALUE = ACC.LEVEL_VALUE(+) ' ||
           'AND NVL(V.LEVEL_VALUE_APPLICATION_ID, -1) = ' ||
           '    ACC.LEVEL_VALUE_APPLICATION_ID(+) ' ||
           'AND V.PROFILE_OPTION_ID = ACC.PROFILE_OPTION_ID(+) ' ||
           'AND ACC.APPLICATION_ID IS NULL';
    ELSE
        l_dynamic_stmt := 'INSERT INTO ' || r_query_request.acc_table_name ||
          '(' || l_original_primary_key  || ', ACCESS_ID, COUNTER,' ||
          ' LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY) ' ||
          'SELECT ' || l_primary_key || ', JTM_ACC_TABLE_S.NEXTVAL, 0, SYSDATE, 1, SYSDATE, 1' ||
          ' FROM (' || r_query_request.con_query || ') WHERE' ||
          ' (' || l_primary_key || ') NOT IN ' ||
          '(SELECT ' || l_primary_key || ' FROM ' || r_query_request.acc_table_name || ')';
    END IF;
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
      , v_module      => 'jtm_message_log_pkg');

    END IF;
    EXECUTE IMMEDIATE l_dynamic_stmt;

    /*** Retrieve ACCESS_IDs for any inserted records ***/
    l_dynamic_stmt := 'SELECT ACCESS_ID FROM ' || r_query_request.acc_table_name ||
          ' WHERE COUNTER = 0';
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
      , v_module      => 'jtm_message_log_pkg');
    END IF;
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( l_cursor, l_dynamic_stmt, dbms_sql.v7);
    l_index := 1;
    l_tab_access_id.DELETE;
    dbms_sql.define_array( l_cursor, 1, l_tab_access_id, 100, l_index);
    l_count := dbms_sql.execute( l_cursor );
    LOOP
      l_count := dbms_sql.fetch_rows(l_cursor);
      dbms_sql.column_value( l_cursor, '1', l_tab_access_id);
       EXIT WHEN l_count <> 100;
    END LOOP;
    dbms_sql.close_cursor( l_cursor );

    IF l_tab_access_id.COUNT > 0 THEN
      /*** 1 or more acc rows retrieved -> push to resources ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Pushing ' || l_tab_access_id.COUNT || ' inserted record(s) to subscribed resources.'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , v_module      => 'jtm_message_log_pkg');
      END IF;

      /*** push to oLite using asg_download ***/

      FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
          m_tab_access_id(i) := l_tab_access_id(i);
      END LOOP;

      l_dummy := markdirty_helper(
     		p_con_query_id => r_query_request.con_query_id
       		,p_accessList  => m_tab_access_id
       		,p_dml_type => 'I');

      /*** set COUNTER to 1 in ACC table ***/
      l_dynamic_stmt := 'UPDATE ' || r_query_request.acc_table_name || ' SET COUNTER=1 WHERE COUNTER=0';
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
        , v_module      => 'jtm_message_log_pkg');
      END IF;
      EXECUTE IMMEDIATE l_dynamic_stmt;
    END IF; -- process INSERTS


    /*** PROCESS DELETES ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Processing DELETES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    IF (r_query_request.acc_table_name = 'JTM_FND_PROF_OPTIONS_VAL_ACC') THEN
       l_dynamic_stmt :=
           'SELECT acc.access_id ' ||
           'FROM jtm_fnd_prof_options_val_acc acc, ' ||
           '(SELECT application_id, level_id, level_value, ' ||
           'nvl(level_value_application_id, -1) ' ||
           'as level_value_application_id, profile_option_id ' ||
           'FROM fnd_profile_option_values ' ||
           'WHERE application_id IN ' ||
           '(0,170,178,222,401,513,523,544,690,697,868,874,689,883) ) B ' ||
           'WHERE acc.application_id = b.application_id(+) ' ||
           'and  acc.level_id = b.level_id(+) ' ||
           'and  acc.level_value = b.level_value(+) ' ||
           'and  acc.level_value_application_id =  ' ||
              ' b.level_value_application_id(+) ' ||
           'and  acc.profile_option_id = b.profile_option_id(+) ' ||
           'and  b.application_id is null ';
    ELSE
       l_dynamic_stmt := 'SELECT ACCESS_ID FROM ' || r_query_request.acc_table_name ||
           ' WHERE (' || l_primary_key || ') NOT IN (SELECT ' ||
           l_primary_key || ' FROM (' || r_query_request.con_query || '))';
    END IF;

    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( l_cursor, l_dynamic_stmt, dbms_sql.v7);
    l_index := 1;
    l_tab_access_id.DELETE;
    dbms_sql.define_array( l_cursor, 1, l_tab_access_id, 100, l_index);
    l_count := dbms_sql.execute( l_cursor );
    LOOP
        l_count := dbms_sql.fetch_rows(l_cursor);
        dbms_sql.column_value( l_cursor, '1', l_tab_access_id);
        EXIT WHEN l_count <> 100;
    END LOOP;
    dbms_sql.close_cursor( l_cursor );

    IF l_tab_access_id.COUNT > 0 THEN
        /*** 1 or more acc rows retrieved -> push to resources ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          JTM_message_log_pkg.Log_Msg
          ( v_object_id   => r_query_request.acc_table_name
          , v_object_name => G_PACKAGE_NAME
          , v_message     => 'Pushing ' || l_tab_access_id.COUNT || ' deleted record(s) to subscribed resources.'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
          , v_module      => 'jtm_message_log_pkg');
        END IF;
        /*** push to oLite using asg_download ***/

        FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
       		m_tab_access_id(i) := l_tab_access_id(i);
        END LOOP;

        l_dummy := markdirty_helper(
        		p_con_query_id => r_query_request.con_query_id
        		,p_accessList  => m_tab_access_id
        		,p_dml_type => 'D'
        		);

        /* Delete record from acc table. */
        l_dynamic_stmt := 'DELETE ' || r_query_request.acc_table_name ||
             ' WHERE access_id= :1';
        FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
           EXECUTE IMMEDIATE l_dynamic_stmt USING m_tab_access_id(i);
        END LOOP;

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
        , v_module      => 'jtm_message_log_pkg');
      END IF;


    END IF; -- process DELETES

   p_message := 'Successfully processing with query id  ' ||
                r_query_request.con_query_id;
  END IF;
  CLOSE c_primary_key;

  JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
      (v_log_id =>l_start_log_id
      ,v_query_stmt => G_Category
      ,v_start_time => l_query_start
      ,v_end_time   => sysdate
      ,v_status     => p_status
      ,v_message    => p_message
      ,x_status     => l_status
      ,x_msg_data   => l_message);

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    JTM_message_log_pkg.Log_Msg
    ( v_object_id   => r_query_request.acc_table_name
    , v_object_name => G_PACKAGE_NAME
    , v_message     => 'Leaving '||G_PACKAGE_NAME||'.Process_Request'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'jtm_message_log_pkg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE c_primary_key;
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Leaving '||G_PACKAGE_NAME||'.Process_Request after exception.'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    p_status  := G_ERROR;
    p_message := 'Exception ocurrs while processing query with id ' ||
                  r_query_request.con_query_id || ': ' || sqlerrm;
    JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
      (v_log_id =>l_start_log_id
      ,v_query_stmt => G_Category
      ,v_start_time => l_query_start
      ,v_end_time   => sysdate
      ,v_status     => p_status
      ,v_message    => p_message
      ,x_status     => l_status
      ,x_msg_data   => l_message);
END Process_Request;

/* PWU: The version 2 of the process request. It handle the last_update_date
   gracely, even the base table last update date is wrong.
   New requirement: All the query statement should include the last_update_date
   in the select clause */
PROCEDURE Process_Request_v2
   (r_query_request c_query_requests%ROWTYPE
   ,p_status out nocopy varchar2
   ,p_message out nocopy varchar2) IS

  l_query_start  date;
  l_dynamic_stmt VARCHAR2(4000);

  l_primary_key VARCHAR2(2000);
  l_tab_access_id dbms_sql.Number_Table;
  m_tab_access_id ASG_DOWNLOAD.ACCESS_LIST;

  l_cursor             INTEGER;
  l_count              INTEGER;
  l_index              NUMBER;

  l_dummy              BOOLEAN;
  l_start_log_id       NUMBER;
  l_status             varchar2(1);
  l_message            varchar2(2000);
  l_tmp_stmt		   varchar2(2000);
  l_update_count       NUMBER;

  TYPE RefCurType is REF CURSOR;
  update_cursor      RefCurType;
  l_lud              date;
BEGIN
  p_status := G_FINE;
  p_message := 'OK';
  l_query_start := sysdate;

  JTM_MESSAGE_LOG_PKG.INSERT_CONC_STATUS_LOG
  	(v_package_name => NULL
	,v_procedure_name => NULL
	,v_con_query_id => r_query_request.con_query_id
    ,v_query_stmt => G_CATEGORY
    ,v_start_time => l_query_start
    ,v_end_time => NULL
    ,v_status => 'Running'
    ,v_message => 'Processing for table ' ||r_query_request.acc_table_name
    ,x_log_id => l_start_log_id
    ,x_status => l_status
    ,x_msg_data => l_message);

  IF (l_status = 'E') THEN
        RAISE JTM_MESSAGE_LOG_PKG.G_EXC_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    JTM_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => G_PACKAGE_NAME
    , v_message     => 'Entering ' || G_PACKAGE_NAME ||'.Process_Request_v2'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'jtm_message_log_pkg');
  END IF;

  /** get primary_key of corresponding publication item  **/
  OPEN c_primary_key(r_query_request.con_query_id);
  FETCH c_primary_key into l_primary_key;

  IF c_primary_key%ROWCOUNT = 0 THEN
  /*** no application subscribed -> ignore this query ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'No application subscribed to query ' || r_query_request.con_query_id || '.' ||
         fnd_global.local_chr(10) || 'Ignoring this query.'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , v_module      => 'jtm_message_log_pkg');
    END IF;

   p_status  := G_ERROR;
   p_message := 'No primary key found for pub item related to query id ' ||
                r_query_request.con_query_id;
  ELSE

    /*** one or more resources subscribed -> process publication item ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'There is at lesst one application regiesterd to this query'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
      , v_module      => 'jtm_message_log_pkg');
    END IF;

/*************************** PROCESS UPDATES ***************************/

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Processing UPDATES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    -- Check if query ran before
    IF r_query_request.last_run_date IS NOT NULL THEN
      -- Yes -> Get access_id of records that were updated since last_run_date
      l_dynamic_stmt := 'SELECT ACC.ACCESS_ID, B.LAST_UPDATE_DATE FROM ' ||
           r_query_request.acc_table_name||' ACC, ('|| r_query_request.con_query||') B ' ||
           'WHERE B.LAST_UPDATE_DATE <> ACC.LAST_UPDATE_DATE ' ||
           'AND ' || GET_CONDITION(l_primary_key,'ACC','B');

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt || fnd_global.local_chr(10) ||
          'LAST_RUN_DATE = ' || to_char(r_query_request.last_run_date)
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
        , v_module      => 'jtm_message_log_pkg');
      END IF;

      l_update_count  := 0;
      OPEN update_cursor for l_dynamic_stmt;
      LOOP
          FETCH  update_cursor INTO	m_tab_access_id(l_update_count+1), l_lud;
          EXIT WHEN update_cursor%NOTFOUND;
          EXECUTE IMMEDIATE 'Update ' || r_query_request.acc_table_name ||
                            ' set last_update_date = :d where access_id = :a'
                            using l_lud, m_tab_access_id(l_update_count+1);
          l_update_count := l_update_count + 1;
      END LOOP;
      CLOSE update_cursor;

      IF l_update_count > 0 THEN
        -- 1 or more acc rows retrieved -> push to resources
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          JTM_message_log_pkg.Log_Msg
          ( v_object_id   => r_query_request.acc_table_name
          , v_object_name => G_PACKAGE_NAME
          , v_message     => 'Pushing ' || l_update_count || ' updated record(s) to subscribed resources.'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
          , v_module      => 'jtm_message_log_pkg');
        END IF;

           l_dummy := markdirty_helper(
        		p_con_query_id => r_query_request.con_query_id
        		,p_accessList  => m_tab_access_id
        		,p_dml_type => 'U'
        		);
      END IF;

    END IF; -- process UPDATES

/*************************** 2. PROCESS INSERTS ***************************/
    /***
      Insert new records to in ACC with COUNTER = 0.
      Then select all ACCESS_IDs from ACC where COUNTER = 0.
      Then update COUNTER to 1.
      This is a workaround for the fact that INSERT INTO with subquery cannot be used
      in combination with RETURNING and we need the ACCESS_IDs to push the records to the
      mobile users.
    ***/

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Processing INSERTS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    l_dynamic_stmt := 'INSERT INTO ' || r_query_request.acc_table_name ||
      '(' || l_primary_key  || ', ACCESS_ID, COUNTER,' ||
      ' LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY) ' ||
      'SELECT ' || l_primary_key || ', JTM_ACC_TABLE_S.NEXTVAL, 0, LAST_UPDATE_DATE, 1, sysdate, 1' ||
      ' FROM (' || r_query_request.con_query || ') WHERE' ||
      ' (' || l_primary_key || ') NOT IN ' ||
      '(SELECT ' || l_primary_key || ' FROM ' || r_query_request.acc_table_name || ')';

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
      , v_module      => 'jtm_message_log_pkg');

    END IF;
    EXECUTE IMMEDIATE l_dynamic_stmt;

    /*** Retrieve ACCESS_IDs for any inserted records ***/
    l_dynamic_stmt := 'SELECT ACCESS_ID FROM ' || r_query_request.acc_table_name ||
          ' WHERE COUNTER = 0';
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
      , v_module      => 'jtm_message_log_pkg');
    END IF;
    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse( l_cursor, l_dynamic_stmt, dbms_sql.v7);
    l_index := 1;
    l_tab_access_id.DELETE;
    dbms_sql.define_array( l_cursor, 1, l_tab_access_id, 100, l_index);
    l_count := dbms_sql.execute( l_cursor );
    LOOP
      l_count := dbms_sql.fetch_rows(l_cursor);
      dbms_sql.column_value( l_cursor, '1', l_tab_access_id);
      EXIT WHEN l_count <> 100;
    END LOOP;
    dbms_sql.close_cursor( l_cursor );

    IF l_tab_access_id.COUNT > 0 THEN
      /*** 1 or more acc rows retrieved -> push to resources ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Pushing ' || l_tab_access_id.COUNT || ' inserted record(s) to subscribed resources.'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
        , v_module      => 'jtm_message_log_pkg');
      END IF;

      /*** push to oLite using asg_download ***/

      FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
       		m_tab_access_id(i) := l_tab_access_id(i);
      END LOOP;

      l_dummy := markdirty_helper(
   		p_con_query_id => r_query_request.con_query_id
   		,p_accessList  => m_tab_access_id
   		,p_dml_type => 'I'
   		);


      /*** set COUNTER to 1 in ACC table ***/
      l_dynamic_stmt := 'UPDATE ' || r_query_request.acc_table_name || ' SET COUNTER=1 WHERE COUNTER=0';
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
        , v_module      => 'jtm_message_log_pkg');
      END IF;
      EXECUTE IMMEDIATE l_dynamic_stmt;
    END IF; -- process INSERTS

/*************************** 3. PROCESS DELETES ***************************/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Processing DELETES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    /*** Check if query ran before ***/
    IF r_query_request.last_run_date IS NOT NULL THEN

      l_dynamic_stmt := 'SELECT ACCESS_ID FROM ' || r_query_request.acc_table_name ||
        ' WHERE (' || l_primary_key || ') NOT IN (SELECT ' ||
        l_primary_key || ' FROM (' || r_query_request.con_query || '))';

      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse( l_cursor, l_dynamic_stmt, dbms_sql.v7);
      l_index := 1;
      l_tab_access_id.DELETE;
      dbms_sql.define_array( l_cursor, 1, l_tab_access_id, 100, l_index);
      l_count := dbms_sql.execute( l_cursor );
      LOOP
        l_count := dbms_sql.fetch_rows(l_cursor);
        dbms_sql.column_value( l_cursor, '1', l_tab_access_id);
        EXIT WHEN l_count <> 100;
      END LOOP;
      dbms_sql.close_cursor( l_cursor );

      IF l_tab_access_id.COUNT > 0 THEN
        /*** 1 or more acc rows retrieved -> push to resources ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          JTM_message_log_pkg.Log_Msg
          ( v_object_id   => r_query_request.acc_table_name
          , v_object_name => G_PACKAGE_NAME
          , v_message     => 'Pushing ' || l_tab_access_id.COUNT || ' deleted record(s) to subscribed resources.'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM
          , v_module      => 'jtm_message_log_pkg');
        END IF;
        /*** push to oLite using asg_download ***/

        FOR i IN l_tab_access_id.FIRST..l_tab_access_id.LAST LOOP
       		m_tab_access_id(i) := l_tab_access_id(i);
         END LOOP;


       l_dummy := markdirty_helper(
        		p_con_query_id => r_query_request.con_query_id
        		,p_accessList  => m_tab_access_id
        		,p_dml_type => 'D'
        		);

      END IF;

      /* Delete record from acc table. */
      l_dynamic_stmt := 'DELETE ' || r_query_request.acc_table_name ||
        ' WHERE (' || l_primary_key || ') NOT IN (SELECT ' ||
        l_primary_key || ' FROM (' || r_query_request.con_query || '))';

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL THEN
        JTM_message_log_pkg.Log_Msg
        ( v_object_id   => r_query_request.acc_table_name
        , v_object_name => G_PACKAGE_NAME
        , v_message     => 'Executing:' || fnd_global.local_chr(10) || l_dynamic_stmt
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_SQL
        , v_module      => 'jtm_message_log_pkg');
      END IF;

      l_cursor := dbms_sql.open_cursor;
      dbms_sql.parse( l_cursor, l_dynamic_stmt, dbms_sql.v7);
      l_count := dbms_sql.execute( l_cursor );
      dbms_sql.close_cursor( l_cursor );
    END IF;
/*************************** 3. PROCESS DELETES DONE***************************/

  p_message := 'Successfully processing with query id  ' ||
                r_query_request.con_query_id;
  END IF;
  CLOSE c_primary_key;

  JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
      (v_log_id =>l_start_log_id
      ,v_query_stmt => G_Category
      ,v_start_time => l_query_start
      ,v_end_time   => sysdate
      ,v_status     => p_status
      ,v_message    => p_message
      ,x_status     => l_status
      ,x_msg_data   => l_message);

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    JTM_message_log_pkg.Log_Msg
    ( v_object_id   => r_query_request.acc_table_name
    , v_object_name => G_PACKAGE_NAME
    , v_message     => 'Leaving ' || G_PACKAGE_NAME ||'.Process_Request_v2'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'jtm_message_log_pkg');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    CLOSE c_primary_key;

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      JTM_message_log_pkg.Log_Msg
      ( v_object_id   => r_query_request.acc_table_name
      , v_object_name => G_PACKAGE_NAME
      , v_message     => 'Leaving ' || G_PACKAGE_NAME ||'.Process_Request_v2 after exception.'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
      , v_module      => 'jtm_message_log_pkg');
    END IF;

    p_status  := G_ERROR;
    p_message := 'Exception ocurrs while processing query with id ' ||
                  r_query_request.con_query_id || ': ' || sqlerrm;

    JTM_MESSAGE_LOG_PKG.UPDATE_CONC_STATUS_LOG
      (v_log_id =>l_start_log_id
      ,v_query_stmt => G_Category
      ,v_start_time => l_query_start
      ,v_end_time   => sysdate
      ,v_status     => p_status
      ,v_message    => p_message
      ,x_status     => l_status
      ,x_msg_data   => l_message);

END Process_Request_v2;

PROCEDURE RUN_QUERY_REQUESTS IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_Status     VARCHAR2(80);
l_Message    VARCHAR2(2000);
BEGIN
   RUN_QUERY_REQUESTS(l_status, l_message);
END;


PROCEDURE RUN_QUERY_REQUESTS(
    P_Status    OUT NOCOPY  VARCHAR2,
    P_Message   OUT NOCOPY  VARCHAR2) IS
PRAGMA AUTONOMOUS_TRANSACTION;
  L_API_NAME CONSTANT VARCHAR2(30) := 'RUN_QUERY_REQUESTS';
  r_query_request c_query_requests%ROWTYPE;
  l_retcode number;
  run_query_error exception;
  l_status varchar2(30);
  l_message varchar2(2000);

BEGIN
  l_retcode := 0;
   g_category := GET_CATEGORY;

   P_Status := G_FINE;
   P_Message:= 'OK';

  /*** get debug level ***/
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    JTM_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => G_PACKAGE_NAME
    , v_message     => 'Entering '||G_PACKAGE_NAME||'.' || L_API_NAME
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'jtm_message_log_pkg');
  END IF;

  -- loop over query requests
  FOR r_query_request IN c_query_requests LOOP
     UPDATE jtm_con_query_request_data
     SET    LAST_TXC_START =  sysdate,
            LAST_TXC_END = null,
            STATUS = 'Running',
            COMPLETION_TEXT = 'Processing the query with id '
                    || r_query_request.con_query_id
     WHERE  con_query_id = r_query_request.con_query_id;
     commit;

     BEGIN
         /* PWU: Temporily solution. Eventually we will use only the v2 procedure
           and absolete the original one */
         if (r_query_request.con_query_id >= 53 AND
             r_query_request.con_query_id <= 67  ) then
             Process_Request_v2( r_query_request,l_status,l_message );
         else
            Process_Request( r_query_request,l_status,l_message );
         end if;
         IF (l_status = G_ERROR) then
           P_Status := G_ERROR;
           IF (P_Message = 'OK' ) THEN
               P_Message := l_message;
         ELSE
             P_Message := P_Message || '; ' || l_message;
         END IF;
      END IF;
      COMMIT;

    EXCEPTION
      WHEN OTHERS THEN
        l_status  := G_ERROR;
        l_message := 'Exception ocurrs while processing query with id ' ||
                     r_query_request.con_query_id;
        P_Status  := G_ERROR;
        IF (P_Message = 'OK' ) THEN
           P_Message:= l_message;
        ELSE
           P_Message:= P_Message || '. ' || l_message;
        END IF;
        ROLLBACK;
        --**** todo: return FND_NEW_MESSAGE error
        l_retcode := -1;
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
          JTM_message_log_pkg.Log_Msg
          ( v_object_id   => r_query_request.acc_table_name
          , v_object_name => G_PACKAGE_NAME
          , v_message     => 'Unexpected error encountered in Process_Request: ' || fnd_global.local_chr(10) || sqlerrm
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
          , v_module      => 'jtm_message_log_pkg');
        END IF;
     END;

     IF (l_status = G_ERROR) THEN
         UPDATE jtm_con_query_request_data
         SET    LAST_TXC_END = sysdate,
                STATUS = l_status,
                COMPLETION_TEXT = l_message
         WHERE  con_query_id = r_query_request.con_query_id;
     ELSE
         UPDATE jtm_con_query_request_data
         SET    LAST_TXC_END = sysdate,
                last_run_date = last_txc_start,
                STATUS = l_status,
                COMPLETION_TEXT = l_message
         WHERE  con_query_id = r_query_request.con_query_id;
	 END IF;
     COMMIT;

  END LOOP;

  IF (P_Message = 'OK') then
     P_Message:= 'The concurrent query program is working fine';
  END IF;
  UPDATE JTM_CON_REQUEST_DATA SET LAST_RUN_DATE = SYSDATE
  WHERE PRODUCT_CODE = 'JTM'
  AND   PACKAGE_NAME = G_PACKAGE_NAME
  AND   UPPER(PROCEDURE_NAME) = L_API_NAME;
  COMMIT;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    JTM_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => G_PACKAGE_NAME
    , v_message     => 'Leaving '||G_PACKAGE_NAME||'.RUN_QUERY_REQUESTS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
    , v_module      => 'jtm_message_log_pkg');
  END IF;

  if l_retcode = -1 then
     RAISE run_query_error;
  END IF;

EXCEPTION
   WHEN run_query_error THEN
      ROLLBACK;
      RAISE;
   WHEN OTHERS THEN
     ROLLBACK;

     IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       JTM_message_log_pkg.Log_Msg
       (v_object_id   => null
       ,v_object_name => G_PACKAGE_NAME
       ,v_message     => 'Unexpected error encountered in RUN_QUERY_REQUESTS:'
                          || fnd_global.local_chr(10) || sqlerrm
       ,v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
       ,v_module      => 'jtm_message_log_pkg');
     END IF;

END RUN_QUERY_REQUESTS;

END JTM_CON_QUERY_REQUEST_PKG;

/
