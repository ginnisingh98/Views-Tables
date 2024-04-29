--------------------------------------------------------
--  DDL for Package Body IBC_AUDIT_LOG_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBC_AUDIT_LOG_GRP" as
/* $Header: ibcalogb.pls 120.1 2005/05/31 23:18:35 appldev  $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBC_AUDIT_LOG_GRP';
  G_FILE_NAME     CONSTANT VARCHAR2(12) := 'ibcalogb.pls';

  -- Cursor to retrieve all information about a particular audit_log
  CURSOR c_audit_log(p_audit_log_id NUMBER) IS
    SELECT *
      FROM IBC_AUDIT_LOGS
     WHERE audit_log_id = p_audit_log_id;


  -- --------------------------------------------------------------------
  -- FUNCTION: Get_Lookup_Meaning
  -- DESCRIPTION: Given a Lookup Type, code and Language; returns the
  --              meaning in FND_LOOKUP_VALUES.
  -- PARAMETERS:
  --   p_lookup_type           => Lookup Type
  --   p_lookup_code           => Lookup Code
  --   p_language              => language
  -- --------------------------------------------------------------------
  FUNCTION Get_Lookup_Meaning(p_lookup_type IN VARCHAR2,
                              p_lookup_code IN VARCHAR2,
                              p_language    IN VARCHAR2 DEFAULT USERENV('LANG'))
  RETURN VARCHAR2
  IS
    l_result       VARCHAR2(80);
    CURSOR c_lookup_meaning(p_lookup_type IN VARCHAR2,
                            p_lookup_code IN VARCHAR2,
                            p_language    IN VARCHAR2) IS
      SELECT meaning
        FROM FND_LOOKUP_VALUES
       WHERE lookup_type = p_lookup_type
         AND lookup_code = p_lookup_code
         AND language = p_language;
  BEGIN
    l_result := NULL;
    OPEN c_lookup_meaning(p_lookup_type, p_lookup_code, p_language);
    FETCH c_lookup_meaning INTO l_Result;
    CLOSE c_lookup_meaning;
    RETURN l_result;
  END Get_Lookup_Meaning;


  FUNCTION Object_Lookup_Value(p_object_value    VARCHAR2)
  RETURN VARCHAR2
  IS
    l_result      VARCHAR2(4000);
    l_pos         NUMBER;
    l_lookup_type VARCHAR2(4000);
    l_lookup_code VARCHAR2(4000);
  BEGIN

    l_result := p_object_value;
    l_pos := INSTR(p_object_value, ':');

    IF l_pos > 0 THEN
      l_lookup_type := SUBSTR(l_result, 1, l_pos - 1);
      l_lookup_code := SUBSTR(l_result, l_pos + 1);

      IF l_lookup_type = 'USER' THEN
        SELECT user_name
          INTO l_result
          FROM fnd_user
         WHERE user_id = l_lookup_code;
      ELSIF l_lookup_type = 'GROUP' THEN
        SELECT group_name resource_name
          INTO l_result
          FROM jtf_rs_groups_vl
         WHERE group_id = TO_NUMBER(l_lookup_code);
      ELSIF l_lookup_type = 'RESPONSIBILITY' THEN
        SELECT responsibility_name
          INTO l_result
          FROM fnd_responsibility_vl
         WHERE sysdate BETWEEN start_date and NVL(end_date, sysdate)
           AND responsibility_id = l_lookup_code;
      ELSIF l_lookup_type = 'GRANT_LEVEL' THEN
        SELECT meaning
          INTO l_result
          FROM ibc_lookups
         WHERE lookup_type = 'IBC_GRANTEE_TYPES'
           AND lookup_code = l_lookup_code;
      ELSIF l_lookup_type = 'GRANT_ACTION' THEN
        SELECT meaning
          INTO l_result
          FROM ibc_lookups
         WHERE lookup_type = 'IBC_SECURITY_ACTIONS'
           AND lookup_code = l_lookup_code;
      END IF;

    END IF;

    RETURN l_result;

  EXCEPTION
    WHEN OTHERS THEN
      IF l_lookup_code IS NOT NULL AND
         l_lookup_type IN ('USER', 'GROUP', 'RESPONSIBIILTY',
                           'GRANT_LEVEL', 'GRANT_ACTION')
      THEN
        RETURN l_lookup_code;
      ELSE
        RETURN l_result;
      END IF;
  END Object_Lookup_Value;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Replace_Tokens
  -- DESCRIPTION: It sets tokens for a particular audit log message record
  -- PARAMETERS:
  --   p_audit_log             => Record holding the audit log row
  --   p_language              => language
  -- --------------------------------------------------------------------
  PROCEDURE Replace_Tokens(p_audit_log   c_audit_log%ROWTYPE,
                           p_language    VARCHAR2 DEFAULT USERENV('LANG'))
  IS
    l_orig_msg VARCHAR2(4000);
    CURSOR c_citem_ver (p_citem_Ver_id NUMBER)
    IS
      SELECT *
        FROM ibc_citems_v
       WHERE citem_Ver_id = p_citem_Ver_id
         AND language = p_language;
    CURSOR c_citem (p_citem_id NUMBER)
    IS
      SELECT *
        FROM ibc_content_items
       WHERE content_item_id = p_citem_id;
  BEGIN
    l_orig_msg := FND_MESSAGE.get_string(NVL(p_audit_log.MESSAGE_APPLICATION, 'IBC'),
                                         NVL(p_audit_log.MESSAGE_NAME, 'IBC_DFLT_AUDIT_MSG'));
    l_orig_msg := UPPER(l_orig_msg);

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_LOG_ID') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_LOG_ID', p_audit_log.audit_log_id);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'ACTIVITY ') > 0 THEN
      FND_MESSAGE.set_token('ACTIVITY', p_audit_log.activity);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'ACTIVITY_MEANING') > 0 THEN
      FND_MESSAGE.set_token('ACTIVITY_MEANING',
                             Get_Lookup_Meaning('IBC_AUDIT_ACTIVITIES',
                                                p_audit_log.ACTIVITY,
                                                p_language));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_USER_ID') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_USER_ID', p_audit_log.user_id);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_TIME_STAMP') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_TIME_STAMP', p_audit_log.time_stamp);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_TYPE') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_TYPE', p_audit_log.object_type);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_VALUE1') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_VALUE1', Object_Lookup_Value(p_audit_log.object_value1));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_VALUE2') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_VALUE2', Object_Lookup_Value(p_audit_log.object_value2));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_VALUE3') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_VALUE3', Object_Lookup_Value(p_audit_log.object_value3));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_VALUE4') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_VALUE4', Object_Lookup_Value(p_audit_log.object_value4));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_VALUE5') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_VALUE5', Object_Lookup_Value(p_audit_log.object_value5));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_PARENT_VALUE') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_PARENT_VALUE', p_audit_log.parent_value);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'AUDIT_OBJECT_STATUS') > 0 THEN
      FND_MESSAGE.set_token('AUDIT_OBJECT_STATUS', p_audit_log.object_status);
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'EXTRA_INFO1_VALUE') > 0 THEN
      FND_MESSAGE.set_token('EXTRA_INFO1_VALUE',
                            get_extra_info(p_audit_log_id => p_audit_log.audit_log_id,
                                           p_info_number  => 1));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'EXTRA_INFO2_VALUE') > 0 THEN
      FND_MESSAGE.set_token('EXTRA_INFO2_VALUE',
                            get_extra_info(p_audit_log_id => p_audit_log.audit_log_id,
                                           p_info_number  => 2));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'EXTRA_INFO3_VALUE') > 0 THEN
      FND_MESSAGE.set_token('EXTRA_INFO3_VALUE',
                            get_extra_info(p_audit_log_id => p_audit_log.audit_log_id,
                                           p_info_number  => 3));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'EXTRA_INFO4_VALUE') > 0 THEN
      FND_MESSAGE.set_token('EXTRA_INFO4_VALUE',
                            get_extra_info(p_audit_log_id => p_audit_log.audit_log_id,
                                           p_info_number  => 4));
    END IF;

    IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'EXTRA_INFO5_VALUE') > 0 THEN
      FND_MESSAGE.set_token('EXTRA_INFO5_VALUE',
                            get_extra_info(p_audit_log_id => p_audit_log.audit_log_id,
                                           p_info_number  => 5));
    END IF;

    IF p_audit_log.object_type = G_CONTENT_ITEM THEN
      FOR r_citem IN c_citem(p_audit_log.object_value1) LOOP

        IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'ITEM_REFERENCE_CODE') > 0 THEN
          FND_MESSAGE.set_token('ITEM_REFERENCE_CODE', r_citem.item_reference_code);
        END IF;

        IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'CONTENT_TYPE_CODE') > 0 THEN
          FND_MESSAGE.set_token('CONTENT_TYPE_CODE', r_citem.content_type_code);
        END IF;

      END LOOP;
    END IF;


    IF p_audit_log.object_type = G_CITEM_VERSION THEN
      FOR r_citem_ver IN c_citem_Ver(p_audit_log.object_value1) LOOP

        IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'CONTENT_ITEM_NAME') > 0 THEN
          FND_MESSAGE.set_token('CONTENT_ITEM_NAME', r_citem_Ver.name);
        END IF;

        IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'CONTENT_TYPE_CODE') > 0 THEN
          FND_MESSAGE.set_token('CONTENT_TYPE_CODE', r_citem_Ver.ctype_code);
        END IF;

        IF INSTR(l_orig_msg, FND_GLOBAL.local_chr(38) || 'CONTENT_TYPE_NAME') > 0 THEN
          FND_MESSAGE.set_token('CONTENT_TYPE_NAME', r_citem_Ver.ctype_name);
        END IF;

      END LOOP;
    END IF;

  END Replace_Tokens;

  -- --------------------------------------------------------------------
  -- PROCEDURE: Log_Action
  -- DESCRIPTION: It stores an audit log
  -- PARAMETERS:
  --   p_activity                  => Activity Code
  --   p_object_type               => Object Type
  --   p_object_value[1..5]        => Primary Key for object being audited
  --   p_parent_value              => Parent Value
  --   p_message_application       => Application owner of audit message
  --   p_message_name              => Message Name (FND_MESSAGES)
  --   p_extra_info[1..5]_type     => Extra Information segment type
  --                                  i.e. CONSTANT, LOOKUP or MESSAGE
  --   p_extra_info[1..5]_ref_type => Lookup Type (in case of LOOKUP)
  --   p_extra_info[1..5]_value    => Value (Constant, lookup code or
  --                                  message name).
  --   <STANDARD API Parms>
  -- --------------------------------------------------------------------
  PROCEDURE log_action(
    p_activity              IN VARCHAR2
    ,p_object_type          IN VARCHAR2
    ,p_object_value1        IN VARCHAR2
    ,p_object_value2        IN VARCHAR2
    ,p_object_value3        IN VARCHAR2
    ,p_object_value4        IN VARCHAR2
    ,p_object_value5        IN VARCHAR2
    ,p_parent_value         IN VARCHAR2
    ,p_message_application  IN VARCHAR2
    ,p_message_name         IN VARCHAR2
    ,p_extra_info1_type     IN VARCHAR2
    ,p_extra_info1_ref_type IN VARCHAR2
    ,p_extra_info1_value    IN VARCHAR2
    ,p_extra_info2_type     IN VARCHAR2
    ,p_extra_info2_ref_type IN VARCHAR2
    ,p_extra_info2_value    IN VARCHAR2
    ,p_extra_info3_type     IN VARCHAR2
    ,p_extra_info3_ref_type IN VARCHAR2
    ,p_extra_info3_value    IN VARCHAR2
    ,p_extra_info4_type     IN VARCHAR2
    ,p_extra_info4_ref_type IN VARCHAR2
    ,p_extra_info4_value    IN VARCHAR2
    ,p_extra_info5_type     IN VARCHAR2
    ,p_extra_info5_ref_type IN VARCHAR2
    ,p_extra_info5_value    IN VARCHAR2
  -- Standard API parms
    ,p_commit               IN  VARCHAR2
    ,p_api_version          IN  NUMBER
    ,p_init_msg_list        IN  VARCHAR2
    ,x_return_status	    OUT NOCOPY VARCHAR2
    ,x_msg_count	    OUT NOCOPY NUMBER
    ,x_msg_data	            OUT NOCOPY VARCHAR2
  ) IS
   --******************* BEGIN REQUIRED VARIABLES *************************
   l_api_name CONSTANT VARCHAR2(30) := 'log_action';               --|**|
   l_api_version_number CONSTANT NUMBER := G_API_VERSION_DEFAULT;  --|**|
   --******************* END REQUIRED VARIABLES ****************************
   temp_rowid  VARCHAR2(100);
   audit_log_id NUMBER;
   l_message_application   VARCHAR2(50);
   l_object_status  VARCHAR2(30);
BEGIN

   --DBMS_OUTPUT.put_line('----- ' || l_api_name || ' -----');
   --******************* BEGIN REQUIRED AREA ******************************
   SAVEPOINT svpt_log_action;                                 --|**|
   IF (p_init_msg_list = FND_API.g_true) THEN                  --|**|
     FND_MSG_PUB.initialize;                                   --|**|
   END IF;                                                     --|**|
                                                                  --|**|
      -- Standard call to check for call compatibility.           --|**|
   IF NOT FND_API.Compatible_API_Call (                        --|**|
             L_API_VERSION_NUMBER                                     --|**|
			          ,p_api_version                                    --|**|
			          ,L_API_NAME                                              --|**|
		           ,G_PKG_NAME)                                              --|**|
   THEN                                                       --|**|
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;                     --|**|
   END IF;                                                     --|**|
                                                                  --|**|
   -- Initialize API return status to SUCCESS                  --|**|
   x_return_status := FND_API.G_RET_STS_SUCCESS;               --|**|
   --******************* END REQUIRED AREA ********************************

   IF NVL(FND_PROFILE.value('IBC_ENABLE_AUDIT_LOG'), 'Y') = 'Y' THEN

     IF p_message_name IS NOT NULL THEN
       l_message_application := NVL(p_message_application, 'IBC');
     ELSE
       l_message_application := NULL;
     END IF;

     --- *** LOGIC for OBJECT_STATUS
    IF p_object_type = G_CONTENT_ITEM THEN
   	BEGIN
       	SELECT content_item_status
        INTO l_object_status
        FROM ibc_content_items
        WHERE content_item_id = p_object_value1;
		EXCEPTION WHEN OTHERS THEN
	  	NULL;
  	END;
     ELSIF p_object_type = G_CITEM_VERSION THEN
	-- Bug# 3731956
	-- When the version is hard-deleted then this SQL
	-- will not return any value
	--
  	BEGIN
       	SELECT citem_version_status
        INTO l_object_status
        FROM ibc_citem_versions_b
        WHERE citem_version_id = p_object_value1;
	EXCEPTION WHEN OTHERS THEN
	  	NULL;
 	END;

     END IF;

     Ibc_Audit_Logs_Pkg.insert_row(
        px_audit_log_id            => audit_log_id
        ,p_activity                => p_activity
        ,p_parent_value            => p_parent_value
        ,p_user_id                 => Fnd_Global.user_id
        ,p_time_stamp              => SYSDATE
        ,p_object_type             => p_object_type
        ,p_object_value1           => p_object_value1
        ,p_object_value2           => p_object_value2
        ,p_object_value3           => p_object_value3
        ,p_object_value4           => p_object_value4
        ,p_object_value5           => p_object_value5
        ,p_object_status           => l_object_status
        ,p_internal_flag           => FND_API.G_FALSE
        ,p_message_application     => l_message_application
        ,p_message_name            => p_message_name
        ,p_extra_info1_type        => p_extra_info1_type
        ,p_extra_info1_ref_type    => p_extra_info1_ref_type
        ,p_extra_info1_value       => p_extra_info1_value
        ,p_extra_info2_type        => p_extra_info2_type
        ,p_extra_info2_ref_type    => p_extra_info2_ref_type
        ,p_extra_info2_value       => p_extra_info2_value
        ,p_extra_info3_type        => p_extra_info3_type
        ,p_extra_info3_ref_type    => p_extra_info3_ref_type
        ,p_extra_info3_value       => p_extra_info3_value
        ,p_extra_info4_type        => p_extra_info4_type
        ,p_extra_info4_ref_type    => p_extra_info4_ref_type
        ,p_extra_info4_value       => p_extra_info4_value
        ,p_extra_info5_type        => p_extra_info5_type
        ,p_extra_info5_ref_type    => p_extra_info5_ref_type
        ,p_extra_info5_value       => p_extra_info5_value
        ,p_object_version_number   => 1
        ,x_rowid                   => temp_rowid
     );

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

   END IF; -- If enable audit log

   -- COMMIT?
   IF (p_commit = FND_API.g_true) THEN
     COMMIT;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(
       p_count           =>      x_msg_count,
       p_data            =>      x_msg_data
   );

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      --DBMS_OUTPUT.put_line('Expected Error');
      ROLLBACK TO svpt_log_action;
	     Ibc_Utilities_Pvt.handle_exceptions(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_ERROR
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
       );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      --DBMS_OUTPUT.put_line('Unexpected error');
      ROLLBACK TO svpt_log_action;
      Ibc_Utilities_Pvt.handle_exceptions(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
      );
  WHEN OTHERS THEN
      --DBMS_OUTPUT.put_line('Other error');
      ROLLBACK TO svpt_log_action;
      Ibc_Utilities_Pvt.HANDLE_EXCEPTIONS(
	       p_api_name           => L_API_NAME
	       ,p_pkg_name          => G_PKG_NAME
	       ,p_exception_level   => Ibc_Utilities_Pvt.G_EXC_OTHERS
	       ,p_package_type      => Ibc_Utilities_Pvt.G_PVT
	       ,p_sqlcode           => SQLCODE
	       ,p_sqlerrm           => SQLERRM
	       ,x_msg_count         => x_msg_count
	       ,x_msg_data          => x_msg_data
	       ,x_return_status     => x_return_status
      );
  END log_action;

  -- --------------------------------------------------------------------
  -- FUNCTION: Get_Audit_Message
  -- DESCRIPTION: Given an Audit Log Id it resolves the appropriate
  --              message (substituting tokens,etc.)
  -- PARAMETERS:
  --   p_audit_log_id              => Audit Log Id
  -- --------------------------------------------------------------------
  FUNCTION get_audit_message(
     p_audit_log_id IN NUMBER
  ) RETURN VARCHAR2 IS
    l_result      VARCHAR2(4000);
    r_audit_log  c_audit_log%ROWTYPE;
  BEGIN

    l_result := NULL;

    OPEN c_audit_log(p_audit_log_id);
    FETCH c_audit_log INTO r_audit_log;
    IF c_audit_log%FOUND THEN
      FND_MESSAGE.set_name(NVL(r_audit_log.MESSAGE_APPLICATION, 'IBC'),
                           NVL(r_audit_log.MESSAGE_NAME, 'IBC_DFLT_AUDIT_MSG'));
      Replace_Tokens(r_audit_log);
      l_result := FND_MESSAGE.get();
      FND_MESSAGE.clear;
    END IF;
    CLOSE c_audit_log;

    RETURN l_result;

  END get_audit_message;

  -- --------------------------------------------------------------------
  -- FUNCTION: Get_Extra_Info
  -- DESCRIPTION: Given an Audit Log Id it returns the extra information
  --              segment (based on p_info_number).
  -- PARAMETERS:
  --   p_audit_log_id              => Audit Log Id
  --   p_info_number               => Indicates which segment to return
  -- --------------------------------------------------------------------
  FUNCTION get_extra_info(
     p_audit_log_id IN NUMBER
     ,p_info_number IN NUMBER
  ) RETURN VARCHAR2 IS
    TYPE cursorType IS REF CURSOR;
    l_result      VARCHAR2(4000);
    l_extra_info_type     IBC_AUDIT_LOGS.extra_info1_type%TYPE;
    l_extra_info_ref_type IBC_AUDIT_LOGS.extra_info1_ref_type%TYPE;
    l_extra_info_value    IBC_AUDIT_LOGS.extra_info1_value%TYPE;
    l_colon_pos       NUMBER;
    l_comma_pos       NUMBER;
    l_curr_value_list VARCHAR2(4000);
    l_curr_value      VARCHAR2(80);
    l_msg_application VARCHAR2(50);
    l_msg_name        VARCHAR2(80);
    l_before_message  VARCHAR2(2000);
  BEGIN
    l_result := NULL;
    IF p_info_number BETWEEN 1 AND 5 THEN

      -- Getting rid of dynamic execution
      IF p_info_number = 1 THEN
        SELECT EXTRA_INFO1_TYPE,
               EXTRA_INFO1_REF_TYPE,
               EXTRA_INFO1_VALUE
          INTO l_extra_info_type, l_extra_info_ref_type, l_extra_info_value
          FROM IBC_AUDIT_LOGS
         WHERE audit_log_id = p_audit_log_id;
      ELSIF p_info_number = 2 THEN
        SELECT EXTRA_INFO2_TYPE,
               EXTRA_INFO2_REF_TYPE,
               EXTRA_INFO2_VALUE
          INTO l_extra_info_type, l_extra_info_ref_type, l_extra_info_value
          FROM IBC_AUDIT_LOGS
         WHERE audit_log_id = p_audit_log_id;
      ELSIF p_info_number = 3 THEN
        SELECT EXTRA_INFO3_TYPE,
               EXTRA_INFO3_REF_TYPE,
               EXTRA_INFO3_VALUE
          INTO l_extra_info_type, l_extra_info_ref_type, l_extra_info_value
          FROM IBC_AUDIT_LOGS
         WHERE audit_log_id = p_audit_log_id;
      ELSIF p_info_number = 4 THEN
        SELECT EXTRA_INFO4_TYPE,
               EXTRA_INFO4_REF_TYPE,
               EXTRA_INFO4_VALUE
          INTO l_extra_info_type, l_extra_info_ref_type, l_extra_info_value
          FROM IBC_AUDIT_LOGS
         WHERE audit_log_id = p_audit_log_id;
      ELSE
        SELECT EXTRA_INFO5_TYPE,
               EXTRA_INFO5_REF_TYPE,
               EXTRA_INFO5_VALUE
          INTO l_extra_info_type, l_extra_info_ref_type, l_extra_info_value
          FROM IBC_AUDIT_LOGS
         WHERE audit_log_id = p_audit_log_id;
      END IF;

      IF l_extra_info_type = G_EI_LOOKUP THEN
        l_result := Get_Lookup_Meaning(p_lookup_type => NVL(l_extra_info_ref_type,
                                                            'IBC_AUDIT_LOOKUPS'),
                                       p_lookup_code => l_extra_info_value);
      ELSIF l_extra_info_type = G_EI_MESSAGE THEN
        l_colon_pos := INSTR(l_extra_info_value, ':');
        IF l_colon_pos > 0 THEN
          l_msg_application := SUBSTR(l_extra_info_value, 1, l_colon_pos - 1);
          l_msg_name        := SUBSTR(l_extra_info_value, l_colon_pos + 1);
        ELSE
          l_msg_application := 'IBC';
          l_msg_name        := l_extra_info_value;
        END IF;
        l_before_message := FND_MESSAGE.get_encoded();
        FND_MESSAGE.clear;
        FND_MESSAGE.set_name(l_msg_application,l_msg_name);
        l_result := FND_MESSAGE.get();
        FND_MESSAGE.clear;
        FND_MESSAGE.set_encoded(l_before_message);
      ELSIF l_extra_info_type = G_EI_CS_LOOKUP THEN

        l_curr_value_list := l_extra_info_value;
        WHILE l_curr_value_list IS NOT NULL LOOP
          l_comma_pos := INSTR(l_curr_value_list, ',');
          IF l_comma_pos > 0 THEN
            l_curr_value := SUBSTR(l_curr_value_list, 1, l_comma_pos - 1);
            l_curr_value_list := SUBSTR(l_curr_value_list, l_comma_pos + 1);
          ELSE
            l_curr_value := l_curr_value_list;
            l_curr_value_list := NULL;
          END IF;
          IF l_curr_value IS NOT NULL THEN
            IF l_result IS NULL THEN
              l_result := Get_Lookup_Meaning(p_lookup_type => NVL(l_extra_info_ref_type,
                                                              'IBC_AUDIT_LOOKUPS'),
                                             p_lookup_code => l_curr_value);
            ELSE
              l_result := l_result || ',' || Get_Lookup_Meaning(p_lookup_type => NVL(l_extra_info_ref_type,
                                                                'IBC_AUDIT_LOOKUPS'),
                                                                p_lookup_code => l_curr_value);

            END IF;
          END IF;
        END LOOP;
      ELSE
        -- By default treated as CONSTANT
        l_result := l_extra_info_value;
      END IF;
    END IF;
    RETURN l_result;
  END get_extra_info;



END IBC_AUDIT_LOG_GRP;

/
