--------------------------------------------------------
--  DDL for Package Body GL_GLCOAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_GLCOAM_PKG" as
/* $Header: glmrcoab.pls 120.6.12010000.2 2009/08/28 13:35:59 degoel ship $ */

  PROCEDURE run_prog(X_id_flex_num NUMBER,
                     X_mode VARCHAR2) IS
     x_userid               VARCHAR2(8);
     x_loginid              VARCHAR2(10);
     x_user_id              NUMBER; --Variable to hold the USER ID
     x_login_id             NUMBER; --Variable to hold hte LOGIN ID
     request_id             NUMBER; --Variable to get the REQUEST ID
     x_num                  NUMBER; --Dummy variable to decide whether there is
                                    --already an existing structure with the same
                                    --ID
     msg                    VARCHAR2(2000);--The variable to get the message
     failed_request         EXCEPTION;  --Exception to handle the request submission
                                        --failure.
     x_id_flex_strt_code    VARCHAR2(30);--Variable to get the structure code.

     CURSOR insert_update(flex_num NUMBER) IS
     SELECT id_flex_num
     FROM FND_ID_FLEX_STRUCTURES
     WHERE application_id = 101
     AND   id_flex_code = 'GLLE'
     AND   id_flex_num = flex_num;

     CURSOR segments_exist(flex_num NUMBER) IS
     SELECT id_flex_num
     FROM   FND_ID_FLEX_SEGMENTS
     WHERE  application_id = 101
     AND    id_flex_code = 'GL#'
     AND    id_flex_num = flex_num;


  BEGIN

     IF(X_mode = 'N') THEN
         -- Bug8459241 : changed FND_PROFILE to FND_GLOBAL
         -- FND_PROFILE.get('USER_ID',x_userid);
         -- FND_PROFILE.get('CONC_LOGIN_ID',x_loginid);
         x_user_id := FND_GLOBAL.user_id;
         x_login_id := FND_GLOBAL.conc_login_id;
     ELSE
         x_user_id := 1;
         x_login_id := 0;
     END IF;

     --If there is already an existing structure with the same ID, delete it.
     OPEN insert_update(X_id_flex_num);
     FETCH insert_update INTO x_num;
     IF(insert_update%FOUND)THEN
        DELETE FROM FND_ID_FLEX_STRUCTURES
        WHERE  application_id = 101
        AND    id_flex_code = 'GLLE'
        AND    id_flex_num = X_id_flex_num;

        DELETE FROM FND_ID_FLEX_STRUCTURES_TL
        WHERE  application_id = 101
        AND    id_flex_code = 'GLLE'
        AND    id_flex_num = X_id_flex_num;

        DELETE FROM FND_ID_FLEX_SEGMENTS
        WHERE  application_id = 101
        AND    id_flex_code  = 'GLLE'
        AND    id_flex_num = X_id_flex_num;

        DELETE FROM FND_ID_FLEX_SEGMENTS_TL
        WHERE  application_id = 101
        AND    id_flex_code = 'GLLE'
        AND    id_flex_num = X_id_flex_num;

        DELETE FROM FND_SEGMENT_ATTRIBUTE_VALUES
        WHERE  application_id = 101
        AND    id_flex_code = 'GLLE'
        AND    id_flex_num = X_id_flex_num;

        DELETE FROM FND_COMPILED_ID_FLEX_STRUCTS
        WHERE  application_id = 101
        AND    id_flex_code = 'GLLE'
        AND    id_flex_num = X_id_flex_num;

        IF(X_mode = 'N') THEN
           fnd_message.set_name('SQLGL','GL_COA_MIRROR_DELETE');
           msg := fnd_message.get;
           fnd_file.put_line(FND_FILE.LOG,msg);
        END IF;
     END IF;
     CLOSE insert_update;

     --Insert the new chart of accounts based on the Ledger Flexfield.
     INSERT INTO FND_ID_FLEX_STRUCTURES
     (application_id,
      id_flex_code,
      id_flex_num,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      concatenated_segment_delimiter,
      cross_segment_validation_flag,
      dynamic_inserts_allowed_flag,
      enabled_flag,
      freeze_flex_definition_flag,
      freeze_structured_hier_flag,
      shorthand_enabled_flag,
      shorthand_length,
      structure_view_name,
      id_flex_structure_code)
   --   security_group_id)
     SELECT
      101,
      'GLLE',
      X_id_flex_num,
      sysdate,
      x_user_id,
      sysdate,
      x_user_id,
      x_login_id,
      concatenated_segment_delimiter,
      cross_segment_validation_flag,
      'N',
      enabled_flag,
      'Y',
      freeze_structured_hier_flag,
      shorthand_enabled_flag,
      shorthand_length,
      structure_view_name,
      id_flex_structure_code--,
   --   security_group_id
     FROM   FND_ID_FLEX_STRUCTURES
     WHERE  application_id = 101
     AND    id_flex_code = 'GL#'
     AND    id_flex_num = X_id_flex_num;

     --Insert the chart of accounts in multiple languages supported by the
     --application.
     INSERT INTO FND_ID_FLEX_STRUCTURES_TL
     (application_id,
      id_flex_code,
      id_flex_num,
      language,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      id_flex_structure_name,
      description,
      shorthand_prompt,
      source_lang)
   --   security_group_id)
     SELECT
      101,
      'GLLE',
      X_id_flex_num,
      language,
      sysdate,
      x_user_id,
      sysdate,
      x_user_id,
      x_login_id,
      id_flex_structure_name,
      description,
      shorthand_prompt,
      source_lang
   --   security_group_id
     FROM   FND_ID_FLEX_STRUCTURES_TL
     WHERE  application_id = 101
     AND    id_flex_code = 'GL#'
     AND    id_flex_num = X_id_flex_num;

     -- Insert segments only if GL# segments exist
     OPEN segments_exist(X_id_flex_num);
     FETCH segments_exist INTO x_num;
     IF(segments_exist%FOUND)THEN

       --Insert the ledger segment as the first segment for the new structure.
       INSERT INTO FND_ID_FLEX_SEGMENTS
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        segment_name,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        segment_num,
       application_column_index_flag,
        enabled_flag,
        required_flag,
        display_flag,
        display_size,
        security_enabled_flag,
        maximum_description_len,
        concatenation_description_len,
        flex_value_set_id,
        range_code,
        default_type,
        default_value,
        runtime_property_function)
   --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        'LEDGER_SEGMENT',
        lv.meaning,
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        1,
        'Y',
        'Y',
        'Y',
        'Y',
        20,
        'N',
        50,
        25,
        fv.flex_value_set_id,
        null,
        'S',
        'SELECT short_name FROM gl_ledgers WHERE ledger_id = gl_formsinfo.get_default_ledger(:$PROFILES$.access_set_id,''R'',NULL)',
        null
   --   security_group_id
       FROM   FND_FLEX_VALUE_SETS fv,
                FND_LANGUAGES l,
              FND_LOOKUP_VALUES lv
       WHERE  fv.flex_value_set_name = 'GL_COA_MIRROR_LEDGER'
       AND    l.installed_flag = 'B'
       AND    lv.language = l.language_code
       AND    lv.lookup_type = 'LEDGERS'
       AND    lv.lookup_code = 'L'
       AND    lv.view_application_id = 101;

       --Copy the segments of the same structure based on the Accounting Flexfield.
       INSERT INTO FND_ID_FLEX_SEGMENTS
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        segment_name,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        segment_num,
        application_column_index_flag,
        enabled_flag,
        required_flag,
        display_flag,
        display_size,
        security_enabled_flag,
        maximum_description_len,
        concatenation_description_len,
        flex_value_set_id,
        range_code,
        default_type,
        default_value,
        runtime_property_function)
  --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        application_column_name,
        segment_name,
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        segment_num+1,
        application_column_index_flag,
        enabled_flag,
        required_flag,
        display_flag,
        display_size,
        security_enabled_flag,
        maximum_description_len,
        concatenation_description_len,
        flex_value_set_id,
        range_code,
        default_type,
        default_value,
        runtime_property_function
   --   security_group_id
       FROM   FND_ID_FLEX_SEGMENTS
       WHERE  application_id = 101
       AND    id_flex_code = 'GL#'
       AND    id_flex_num = X_id_flex_num;

       --Insert the ledger segment in multiple languages supported by the
       --application.
       INSERT INTO FND_ID_FLEX_SEGMENTS_TL
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        language,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        form_left_prompt,
        form_above_prompt,
        description,
        source_lang)
   --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        'LEDGER_SEGMENT',
        l.language_code,
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        lv.meaning,
        lv.meaning,
        lv.description,
        userenv('LANG')
   --   security_group_id
       FROM   FND_LOOKUP_VALUES lv,
                FND_LANGUAGES l
       WHERE  l.installed_flag in ('B','I')
       AND    NOT EXISTS
              (SELECT NULL
               FROM   FND_ID_FLEX_SEGMENTS_TL t
               WHERE  t.application_id = 101
               AND    t.id_flex_code = 'GLLE'
               AND    t.id_flex_num = X_id_flex_num
               AND    t.application_column_name = 'LEDGER_SEGMENT'
               AND    t.language = l.language_code)
       AND    lv.lookup_type = 'LEDGERS'
       AND    lv.lookup_code = 'L'
       AND    lv.language = l.language_code
       AND    lv.view_application_id = 101;

       --Insert the remaining segments in multiple languages supported by the
       --application.
       INSERT INTO FND_ID_FLEX_SEGMENTS_TL
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        language,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        form_left_prompt,
        form_above_prompt,
        description,
        source_lang)
   --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        application_column_name,
        language,
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        form_left_prompt,
        form_above_prompt,
        description,
        source_lang
   --   security_group_id
       FROM   FND_ID_FLEX_SEGMENTS_TL
       WHERE  application_id = 101
       AND    id_flex_code = 'GL#'
       AND    id_flex_num = X_id_flex_num;

       --Insert the GL_LEDGER qualifier for all of the segments.
       INSERT INTO FND_SEGMENT_ATTRIBUTE_VALUES
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        segment_attribute_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        attribute_value)
   --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        application_column_name,
        'GL_LEDGER',
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        decode(application_column_name,'LEDGER_SEGMENT','Y','N')
   --   security_group_id
       FROM   FND_ID_FLEX_SEGMENTS
       WHERE  application_id =101
       AND    id_flex_code = 'GLLE'
       AND    id_flex_num = X_id_flex_num;

       --Insert the qualifiers for the ledger segment.
       INSERT INTO FND_SEGMENT_ATTRIBUTE_VALUES
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        segment_attribute_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        attribute_value)
   --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        'LEDGER_SEGMENT',
        val.segment_attribute_type,
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        decode(val.segment_attribute_type,'GL_GLOBAL','Y','N')
   --   security_group_id
       FROM   FND_SEGMENT_ATTRIBUTE_VALUES val,
              FND_SEGMENT_ATTRIBUTE_TYPES typ
       WHERE  val.application_id=101
       AND    val.id_flex_code = 'GL#'
       AND    val.id_flex_num = X_id_flex_num
       AND    val.application_column_name =
              (SELECT application_column_name
               FROM   FND_ID_FLEX_SEGMENTS
               WHERE  application_id = 101
               AND    id_flex_code = 'GL#'
               AND    id_flex_num = X_id_flex_num
               AND    rownum=1)
       AND    typ.application_id = 101
       AND    typ.id_flex_code = 'GLLE'
       AND    typ.segment_attribute_type = val.segment_attribute_type;

       --Insert the qualifiers for the remaining segments.
       INSERT INTO FND_SEGMENT_ATTRIBUTE_VALUES
       (application_id,
        id_flex_code,
        id_flex_num,
        application_column_name,
        segment_attribute_type,
        last_update_date,
        last_updated_by,
        creation_date,
        created_by,
        last_update_login,
        attribute_value)
   --   security_group_id)
       SELECT
        101,
        'GLLE',
        X_id_flex_num,
        val.application_column_name,
        val.segment_attribute_type,
        sysdate,
        x_user_id,
        sysdate,
        x_user_id,
        x_login_id,
        val.attribute_value
   --   security_group_id
       FROM   FND_SEGMENT_ATTRIBUTE_VALUES val,
              FND_SEGMENT_ATTRIBUTE_TYPES typ
       WHERE  val.application_id = 101
       AND    val.id_flex_code = 'GL#'
       AND    val.id_flex_num = X_id_flex_num
       AND    typ.application_id = 101
       AND    typ.id_flex_code = 'GLLE'
       AND    typ.segment_attribute_type = val.segment_attribute_type;

     END IF;
     CLOSE segments_exist;

     SELECT id_flex_structure_code
     INTO   x_id_flex_strt_code
     FROM   FND_ID_FLEX_STRUCTURES
     WHERE  application_id = 101
     AND    id_flex_code = 'GLLE'
     AND    id_flex_num = X_id_flex_num;

     IF(X_mode = 'N') THEN
         request_id := fnd_request.submit_request(
                       'FND', 'FDFCMPK', '', '', FALSE,
                       'K', 'SQLGL',
                       'GLLE', X_id_flex_num);

         IF (request_id = 0) THEN
              raise failed_request;
         ELSE
              fnd_file.put_line(FND_FILE.LOG, 'Request ID is: '||request_id);
         END IF;
     END IF;

  EXCEPTION
     WHEN failed_request THEN
          rollback;
          fnd_message.set_name('SQLGL','GL_API_COA_FLEX_COMPILE_ERR');
          fnd_message.set_token('STRUCTURECODE',x_id_flex_strt_code);
          msg := fnd_message.get;
          fnd_file.put_line(FND_FILE.LOG,msg);
     WHEN OTHERS THEN
          rollback;
          IF(X_mode = 'N') THEN
              msg := SUBSTRB(SQLERRM,1,2000);
              fnd_file.put_line(FND_FILE.LOG,msg);
          END IF;

  END run_prog;


  FUNCTION gl_coam_rule(p_subscription_guid IN RAW,
                        p_event             IN OUT NOCOPY WF_EVENT_T)
    RETURN VARCHAR2 IS
    src_req_id         VARCHAR2(15);
    application_id     VARCHAR2(15);
    id_flex_code       VARCHAR2(10);
    id_flex_num        VARCHAR2(15);
    request_id         NUMBER;
  BEGIN
    FND_PROFILE.get('CONC_REQUEST_ID', src_req_id);

    -- only necessary when the event is raised directly from the form
    IF (to_number(src_req_id) <= 0) THEN

      application_id := p_event.GetValueForParameter('APPLICATION_ID');
      id_flex_code   := p_event.GetValueForParameter('ID_FLEX_CODE');
      id_flex_num    := p_event.GetValueForParameter('ID_FLEX_NUM');

      IF (application_id = '101' AND id_flex_code = 'GL#') THEN
        request_id := fnd_request.submit_request(
                        'SQLGL', 'GLCOAM', '', '', FALSE,
                        id_flex_num, chr(0), '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '',
                        '', '', '', '', '', '', '', '', '', '');
        IF (request_id = 0) THEN
          WF_CORE.CONTEXT('GL_GLCOAM_PKG', 'gl_coam_rule',
                          p_event.getEventName, p_subscription_guid);
          WF_EVENT.setErrorInfo(p_event, FND_MESSAGE.get);
          return 'WARNING';
        END IF;
      END IF;

    END IF;

    RETURN 'SUCCESS';

  EXCEPTION
    WHEN OTHERS THEN
      WF_CORE.CONTEXT('GL_GLCOAM_PKG', 'gl_coam_rule',
                      p_event.getEventName, p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      return 'ERROR';
  END gl_coam_rule;

END GL_GLCOAM_PKG;

/
