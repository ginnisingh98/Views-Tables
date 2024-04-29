--------------------------------------------------------
--  DDL for Package Body IEU_CTRL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEU_CTRL_PVT" AS
/* $Header: IEUVCTLB.pls 120.1 2005/07/14 15:20:05 appldev ship $ */
---------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for retrieving a IEU_CTRL_MESSAGE_OBJ table based on
--some criterion
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE GET_CTRL_MESSAGES
 (
   P_RESOURCE_ID   IN NUMBER
  ,P_STATUS_ID     IN NUMBER
  ,P_AGE_FILTER    IN NUMBER
  ,X_CTRL_MESSAGES_NST OUT NOCOPY SYSTEM.IEU_CTRL_MESSAGES_NST
 )
 AS
 BEGIN
    GET_CTRL_MESSAGES_T( P_RESOURCE_ID, P_STATUS_ID,
                         0, P_AGE_FILTER,
                         X_CTRL_MESSAGES_NST );
 END GET_CTRL_MESSAGES;


PROCEDURE GET_CTRL_MESSAGES_T
 (
   P_RESOURCE_ID IN NUMBER,
   P_STATUS_ID   IN NUMBER,
   P_START_FILTER  IN NUMBER,
   P_END_FILTER  IN NUMBER,
   X_CTRL_MESSAGES_NST OUT NOCOPY SYSTEM.IEU_CTRL_MESSAGES_NST
 )
 AS
   l_timediff NUMBER;

   CURSOR msg_cursor is
     SELECT *
     FROM
       IEU_MSG_MESSAGES message_table
     WHERE
       message_table.RESOURCE_TYPE = 'RS_INDIVIDUAL' AND
       message_table.RESOURCE_ID   =  P_RESOURCE_ID AND
       message_table.STATUS_ID     <= P_STATUS_ID;
 BEGIN

   --parameter check
   IF ( ( P_RESOURCE_ID IS NULL ) OR
        ( P_STATUS_ID   IS NULL ) OR
        ( P_END_FILTER  IS NULL ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_RESOURCE_ID, P_STATUS_ID OR P_START_FILTER invalid values' ||
            '(P_RESOURCE_ID = '    || P_RESOURCE_ID ||
          ') (P_STATUS_ID = '  || P_STATUS_ID ||
          ') (P_END_FILTER = ' || P_END_FILTER ||')'
         ,TRUE
        );
   END IF;

   IF ( ( P_END_FILTER < 0 ) OR
        ( P_START_FILTER  < 0 ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_START_FILTER OR P_END_FILTER invalid values' ||
            '(P_START_FILTER = '    || P_START_FILTER ||
          ') (P_END_FILTER = ' || P_END_FILTER ||')'
         ,TRUE
        );
   END IF;

   X_CTRL_MESSAGES_NST := SYSTEM.IEU_CTRL_MESSAGES_NST();

   FOR msg_val IN msg_cursor
   LOOP
     --get the difference in the current time and the message create
     --time and convert to minutes because the parameters are in minutes
     l_timediff := 60*24*( SYSDATE - MSG_VAL.CREATION_DATE );

     IF ( ( l_timediff >= P_START_FILTER AND
            l_timediff <= P_END_FILTER )
          OR
          ( P_START_FILTER = 0 AND
            P_END_FILTER = 0 ) )
     THEN
       X_CTRL_MESSAGES_NST.extend( 1 );
       X_CTRL_MESSAGES_NST( X_CTRL_MESSAGES_NST.LAST ) :=
         SYSTEM.IEU_CTRL_MESSAGE_OBJ( msg_val.MESSAGE_ID,  msg_val.CREATION_DATE,
                               msg_val.LAST_UPDATE_DATE, msg_val.APPLICATION_ID,                               msg_val.RESOURCE_TYPE, msg_val.RESOURCE_ID,
                               msg_val.STATUS_ID, msg_val.TITLE,
                               msg_val.BODY, msg_val.WORKITEM_OBJ_CODE,
                               msg_val.WORKITEM_PK_ID );
     END IF;

   END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

 END GET_CTRL_MESSAGES_T;
------------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for saving a IEU_CTRL_MESSAGE_OBJ table based on
--some the message id and the new status
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE SAVE_CTRL_MESSAGES
 (
   P_CTRL_MESSAGES_NST IN SYSTEM.IEU_CTRL_MESSAGES_NST
 )
 AS
 BEGIN

   --parameter check
   IF ( P_CTRL_MESSAGES_NST IS NULL )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_CTRL_MESSAGES_NST cannot be NULL'
         ,TRUE
        );
   END IF;

   --save the updated message
   FOR i IN P_CTRL_MESSAGES_NST.FIRST..P_CTRL_MESSAGES_NST.LAST
   LOOP
    UPDATE IEU_MSG_MESSAGES SET
        IEU_MSG_MESSAGES.STATUS_ID = P_CTRL_MESSAGES_NST(i).STATUS_ID,
        IEU_MSG_MESSAGES.LAST_UPDATE_DATE = SYSDATE
      WHERE P_CTRL_MESSAGES_NST(i).MESSAGE_ID =
        IEU_MSG_MESSAGES.MESSAGE_ID;
   END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

 END SAVE_CTRL_MESSAGES;



------------------------------------------------------------------------
------------------------------------------------------------------------
--utility procedure for setting the lang info whereever required
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE SET_LANG_INFO
 (
   P_USER_LANG     IN  VARCHAR2
 )
 AS
   l_lang     VARCHAR2(100);
 BEGIN
   l_lang := 'ALTER SESSION SET NLS_LANGUAGE = '|| ''''||
              SUBSTR ( P_USER_LANG,
                       1,
                       ( INSTR ( P_USER_LANG,'_',1,1 ) - 1 ) ) ||'''';
   --insert into plsqldbug values( sysdate, l_lang );
   --commit;

   EXECUTE IMMEDIATE l_lang;


   l_lang := 'ALTER SESSION SET NLS_TERRITORY = '|| ''''||
              SUBSTR( P_USER_LANG,
                     ( INSTR ( P_USER_LANG,'_',1,1 ) + 1 ),
                     ( INSTR ( P_USER_LANG,'.',1,1 ) -
                              INSTR ( P_USER_LANG,'_',1,1) - 1 ) ) || '''';
   --insert into plsqldbug values( sysdate, l_lang );
   --commit;

   EXECUTE IMMEDIATE l_lang;

 END SET_LANG_INFO;

------------------------------------------------------------------------
------------------------------------------------------------------------
--utility procedure for setting the lang info whereever required
--also returns the previous language setting which can be used to reset
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE SET_LANG_INFO_X
 (
   P_USER_LANG IN VARCHAR2,
   X_EXISTING_LANG OUT NOCOPY VARCHAR2
 )
AS
BEGIN
  SELECT userenv('LANGUAGE') INTO X_EXISTING_LANG FROM DUAL;

  SET_LANG_INFO( P_USER_LANG );

END SET_LANG_INFO_X;

------------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for getting the plugin information for a particular resource
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE GET_CTRL_PLUGINS
 (
   P_RESOURCE_ID IN NUMBER
  ,P_AGENT_EXTN   IN NUMBER
  ,P_USER_ID      IN NUMBER
  ,P_RESP_ID      IN NUMBER
  ,P_RESP_APPL_ID IN NUMBER
  ,P_USER_LANG IN VARCHAR2
  ,X_CTRL_PLUGINS_NST OUT NOCOPY SYSTEM.IEU_CTRL_PLUGINS_NST
 )
 AS
   l_sql_clause  VARCHAR2(1000);
   l_label_name  VARCHAR2(1990);
   l_desc        VARCHAR2(1990);
   l_load_plugin BOOLEAN;
   l_func_return VARCHAR2(1);
   l_error_text  VARCHAR(2000);
   l_cur_lang    VARCHAR(100);
   l_temp        VARCHAR(100);
   l_app_name     VARCHAR2(32);

   CURSOR msg_cursor is
     SELECT * FROM
       IEU_CTL_PLUGINS_B;
 BEGIN

   l_app_name := 'IEU';
   --parameter check
   IF ( ( P_RESOURCE_ID IS NULL ) OR
        ( P_AGENT_EXTN IS NULL ) OR
        ( P_USER_LANG IS NULL ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_USER_LANG OR P_RESOURCE_ID cannot be NULL' ||
            '(P_USER_LANG = '    || P_USER_LANG ||
          ') (P_AGENT_EXTN = '  || P_AGENT_EXTN ||
          ') (P_RESOURCE_ID = '  || P_RESOURCE_ID || ')'
         ,TRUE
        );
   END IF;

   --set the language stuff
   SET_LANG_INFO_X( P_USER_LANG, l_cur_lang );

   --initialize fnd env variables
   FND_GLOBAL.APPS_INITIALIZE( P_USER_ID, P_RESP_ID, P_RESP_APPL_ID );

   X_CTRL_PLUGINS_NST := SYSTEM.IEU_CTRL_PLUGINS_NST();
   FOR msg_val IN msg_cursor
   LOOP

     --initialize the load plugin flag to false
     l_load_plugin := FALSE;

     --select the translated stuff
     SELECT tl.NAME, tl.DESCRIPTION INTO l_label_name, l_desc
           FROM IEU_CTL_PLUGINS_TL tl
           WHERE tl.PLUGIN_ID = msg_val.PLUGIN_ID AND
                 tl.LANGUAGE = userenv( 'LANG' );


     --select the error message txt
     l_error_text :=
         FND_MESSAGE.GET_STRING( l_app_name, msg_val.INIT_ERROR_MSG_NAME );

     --if the required flag for the plugin is set to T ot t
     --the plugin is mandatory. else call the DO_LAUNCH function
     --of the plugin and check if it has to be loaded

     IF( ( msg_val.IS_REQUIRED_FLAG = 'T' ) OR
         ( msg_val.IS_REQUIRED_FLAG = 't' ) )
     THEN
       l_load_plugin := TRUE;
     ELSE
       IF (msg_val.DO_LAUNCH_FUNC = 'CCT_PLGN_FUNC_PVT.DO_LAUNCH_CLIENT_SDK')
       THEN
          l_sql_clause := 'BEGIN :l_func_return := ' ||
             msg_val.DO_LAUNCH_FUNC || '( :1, :2, :3, :4, :5); END; ';

          EXECUTE IMMEDIATE l_sql_clause USING OUT l_func_return,
          IN P_RESOURCE_ID, IN P_USER_ID, IN P_RESP_ID, IN P_RESP_APPL_ID,
          IN P_USER_LANG ;

       ELSE

         l_sql_clause := 'BEGIN :l_func_return := ' ||
             msg_val.DO_LAUNCH_FUNC || '( :1, :2, :3, :4, :5, :6); END; ';

         --insert into plsqldbug values( sysdate, l_sql_clause );
         --commit;

         --tried to make the return BOOLEAN but PL/SQL complained
         --at this statement.. !! DARN so I am leaving it
         --VARCHAR2 - ssk
         EXECUTE IMMEDIATE l_sql_clause USING OUT l_func_return,
         IN P_RESOURCE_ID, IN P_AGENT_EXTN, IN P_USER_ID, IN P_RESP_ID, IN P_RESP_APPL_ID,
         IN P_USER_LANG ;
       END IF;

       --if the function returns T or t the plugin has to be loaded
       --insert into plsqldbug values( sysdate, '##' || l_func_return || '##' );
       --commit;

       IF ( l_func_return = 'Y' )
       THEN
         l_load_plugin := TRUE;
       END IF;

     END IF;


     IF ( l_load_plugin )
     THEN
       X_CTRL_PLUGINS_NST.extend( 1 );
       X_CTRL_PLUGINS_NST( X_CTRL_PLUGINS_NST.LAST ) :=
         SYSTEM.IEU_CTRL_PLUGIN_OBJ( msg_val.PLUGIN_ID, msg_val.CLASS_NAME,
                              l_label_name, l_desc,
                              msg_val.IMAGE_FILE_NAME, msg_val.AUDIO_FILE_NAME,
                              l_error_text,
                              msg_val.IS_REQUIRED_FLAG, msg_val.DO_LAUNCH_FUNC);
     END IF;

   END LOOP;

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

   --reset the language stuff
   SET_LANG_INFO_X( l_cur_lang, l_temp );

 END GET_CTRL_PLUGINS;


------------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for getting all the error messages at startup
--this prevents multiple database roundtrips
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE GET_FND_ERROR_MESSAGES
 (
   P_RESOURCE_ID   IN  NUMBER
  ,P_FND_MESSAGES_NST   IN  SYSTEM.IEU_FND_MESSAGES_NST
  ,P_USER_LANG     IN  VARCHAR2
  ,X_FND_MESSAGES_NST  OUT NOCOPY SYSTEM.IEU_FND_MESSAGES_NST
 )
 AS
   l_message_text VARCHAR2(4000);
   l_cur_lang     VARCHAR2(100);
   l_temp         VARCHAR2(100);
   l_app_name     VARCHAR2(100);
   l_number       NUMBER(9);
 BEGIN

   --parameter check
   IF ( ( P_USER_LANG IS NULL ) OR
        ( P_RESOURCE_ID IS NULL ) OR
        ( P_FND_MESSAGES_NST IS NULL ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_USER_LANG, P_RESOURCE_ID OR P_FND_MESSAGES_NST cannot be NULL' ||
            '(P_USER_LANG = '    || P_USER_LANG ||
          ') (P_RESOURCE_ID = '  || P_RESOURCE_ID || ')'
         ,TRUE
        );
   END IF;

   --set the language stuff
   SET_LANG_INFO_X( P_USER_LANG, l_cur_lang );

   --initialize the nested table
   X_FND_MESSAGES_NST := SYSTEM.IEU_FND_MESSAGES_NST();

   FOR i IN P_FND_MESSAGES_NST.FIRST..P_FND_MESSAGES_NST.LAST
   LOOP

     IF ( P_FND_MESSAGES_NST( i ).NAME IS NOT NULL )
     THEN

       l_app_name := P_FND_MESSAGES_NST( i ).APP_NAME;
       if ( l_app_name IS NULL )
       THEN
         l_app_name := 'IEU';
       END IF;

       --get the message text from the fnd function
       l_message_text :=
         FND_MESSAGE.GET_STRING( l_app_name, P_FND_MESSAGES_NST( i ).NAME );

       l_number :=
         FND_MESSAGE.GET_NUMBER( l_app_name, P_FND_MESSAGES_NST( i ).NAME );

       --initialize the nested table and add the message object to it
       X_FND_MESSAGES_NST.EXTEND( 1 );
       X_FND_MESSAGES_NST( X_FND_MESSAGES_NST.LAST )
             :=  SYSTEM.IEU_FND_MESSAGE_OBJ( P_FND_MESSAGES_NST( i ).NAME ,
                                             l_message_text,
                                             l_number,
                                             l_app_name );
     ELSE
       NULL;
     END IF;

   END LOOP;

   --reset the language stuff
   SET_LANG_INFO_X( l_cur_lang, l_temp );

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

 END GET_FND_ERROR_MESSAGES;


------------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for getting the  FND Lookup Codes and values based on
--lookup type and application id.
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE GET_FND_LOOKUP_VALUES
 (
   P_RESOURCE_ID   IN  NUMBER
  ,P_APP_ID        IN  NUMBER
  ,P_LOOKUP_TYPE   IN  VARCHAR2
  ,P_USER_LANG     IN  VARCHAR2
  ,X_FND_MESSAGES_NST  OUT NOCOPY SYSTEM.IEU_FND_MESSAGES_NST
 )
 AS
   l_cur_lang VARCHAR2(100);
   l_temp     VARCHAR2(100);

   CURSOR msg_cursor is
     SELECT
       lookup_table.LOOKUP_CODE,
       lookup_table.MEANING
     FROM
       FND_LOOKUP_VALUES_VL lookup_table
     WHERE
       lookup_table.LOOKUP_TYPE = P_LOOKUP_TYPE AND
       lookup_table.VIEW_APPLICATION_ID = P_APP_ID AND
       lookup_table.ENABLED_FLAG = 'Y';
 BEGIN

   --parameter check
   IF ( ( P_LOOKUP_TYPE IS NULL ) OR
        ( P_USER_LANG   IS NULL ) OR
        ( P_RESOURCE_ID IS NULL ) OR
        ( P_APP_ID      IS NULL ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_LOOKUP_TYPE, P_USER_LANG, P_RESOURCE_ID OR P_APP_ID ' ||
                                                  'cannot be NULL' ||
            '(P_LOOKUP_TYPE = '  || P_LOOKUP_TYPE ||
            '(P_USER_LANG = '    || P_USER_LANG ||
          ') (P_RESOURCE_ID = '  || P_RESOURCE_ID ||
          ') (P_APP_ID = '  || P_APP_ID || ')'
         ,TRUE
        );
   END IF;

   --set the language stuff
   SET_LANG_INFO_X( P_USER_LANG, l_cur_lang );

   --initialize the nested table
   X_FND_MESSAGES_NST := SYSTEM.IEU_FND_MESSAGES_NST();

   FOR msg_val IN msg_cursor
      LOOP
        X_FND_MESSAGES_NST.extend(1);
        X_FND_MESSAGES_NST( X_FND_MESSAGES_NST.LAST )
           := SYSTEM.IEU_FND_MESSAGE_OBJ( msg_val.LOOKUP_CODE ,
                                          msg_val.MEANING,
                                          null, null );
   END LOOP;

   --set the language stuff
   SET_LANG_INFO_X( l_cur_lang, l_temp );

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

 END GET_FND_LOOKUP_VALUES;


------------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for getting the  FND Lookup Codes and values based on
--lookup type and application id and sort them based on meaning
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE GET_FND_LOOKUP_VALUES_SRT
 (
   P_RESOURCE_ID   IN  NUMBER
  ,P_APP_ID        IN  NUMBER
  ,P_LOOKUP_TYPE   IN  VARCHAR2
  ,P_USER_LANG     IN  VARCHAR2
  ,X_FND_MESSAGES_NST  OUT NOCOPY SYSTEM.IEU_FND_MESSAGES_NST
 )
 AS
   l_cur_lang VARCHAR2(100);
   l_temp     VARCHAR2(100);

   CURSOR msg_cursor is
     SELECT
       lookup_table.LOOKUP_CODE,
       lookup_table.MEANING
     FROM
       FND_LOOKUP_VALUES_VL lookup_table
     WHERE
       lookup_table.LOOKUP_TYPE = P_LOOKUP_TYPE AND
       lookup_table.VIEW_APPLICATION_ID = P_APP_ID AND
       lookup_table.ENABLED_FLAG = 'Y'
     ORDER BY lookup_table.MEANING;
 BEGIN
   --parameter check
   IF ( ( P_LOOKUP_TYPE IS NULL ) OR
        ( P_USER_LANG   IS NULL ) OR
        ( P_RESOURCE_ID IS NULL ) OR
        ( P_APP_ID      IS NULL ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'P_LOOKUP_TYPE, P_USER_LANG, P_RESOURCE_ID OR P_APP_ID ' ||
                                                  'cannot be NULL' ||
            '(P_LOOKUP_TYPE = '  || P_LOOKUP_TYPE ||
            '(P_USER_LANG = '    || P_USER_LANG ||
          ') (P_RESOURCE_ID = '  || P_RESOURCE_ID ||
          ') (P_APP_ID = '  || P_APP_ID || ')'
         ,TRUE
        );
   END IF;

   --set the language stuff
   SET_LANG_INFO_X( P_USER_LANG, l_cur_lang );

   --initialize the nested table
   X_FND_MESSAGES_NST := SYSTEM.IEU_FND_MESSAGES_NST();

   FOR msg_val IN msg_cursor
      LOOP
        X_FND_MESSAGES_NST.extend(1);
        X_FND_MESSAGES_NST( X_FND_MESSAGES_NST.LAST )
           := SYSTEM.IEU_FND_MESSAGE_OBJ( msg_val.LOOKUP_CODE ,
                                          msg_val.MEANING,
                                          null, null );
   END LOOP;

   --set the language stuff
   SET_LANG_INFO_X( l_cur_lang, l_temp );

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

 END GET_FND_LOOKUP_VALUES_SRT;

------------------------------------------------------------------------
------------------------------------------------------------------------
--procedure for getting the  FND Lookup Codes and values based on
--lookup type and application id.
------------------------------------------------------------------------
------------------------------------------------------------------------
PROCEDURE GET_FND_LOOKUP_CODES
 (
   P_RESOURCE_ID   IN  NUMBER
  ,P_APP_ID        IN  NUMBER
  ,P_CTRL_STRING_NST IN  SYSTEM.IEU_CTRL_STRING_NST
  ,P_USER_LANG     IN  VARCHAR2
  ,X_FND_CODES_NST OUT NOCOPY SYSTEM.IEU_FND_CODES_NST
 )
 AS
   l_cur_lang VARCHAR2(100);
   l_temp VARCHAR2(100);

   CURSOR msg_cursor( p_lookup_type VARCHAR2 ) is
     SELECT
       lookup_table.LOOKUP_CODE,
       lookup_table.MEANING
     FROM
       FND_LOOKUP_VALUES_VL lookup_table
     WHERE
       lookup_table.LOOKUP_TYPE = p_lookup_type AND
       lookup_table.VIEW_APPLICATION_ID = P_APP_ID AND
       lookup_table.ENABLED_FLAG = 'Y';

 BEGIN

   --parameter check
   IF ( ( P_CTRL_STRING_NST IS NULL ) OR
        ( P_USER_LANG   IS NULL ) OR
        ( P_RESOURCE_ID IS NULL ) OR
        ( P_APP_ID      IS NULL ) )
   THEN
     RAISE_APPLICATION_ERROR
        (
          -20000
         ,'LOOKUP_TYPES, P_USER_LANG, P_RESOURCE_ID OR P_APP_ID ' ||
                                                  'cannot be NULL' ||
            '(P_USER_LANG = '    || P_USER_LANG ||
          ') (P_RESOURCE_ID = '  || P_RESOURCE_ID ||
          ') (P_APP_ID = '  || P_APP_ID || ')'
         ,TRUE
        );
   END IF;

   --set the language stuff
   SET_LANG_INFO_X( P_USER_LANG, l_cur_lang );

   --initialize the nested table
   X_FND_CODES_NST := SYSTEM.IEU_FND_CODES_NST();

   FOR i IN P_CTRL_STRING_NST.FIRST..P_CTRL_STRING_NST.LAST
   LOOP

     IF ( P_CTRL_STRING_NST( i ).NAME IS NOT NULL )
     THEN

       FOR msg_val IN msg_cursor( P_CTRL_STRING_NST( i ).NAME )
       LOOP
         X_FND_CODES_NST.extend(1);
         X_FND_CODES_NST( X_FND_CODES_NST.LAST )
           := SYSTEM.IEU_FND_CODE_OBJ( P_CTRL_STRING_NST( i ).NAME,
                                       msg_val.LOOKUP_CODE ,
                                       msg_val.MEANING );
       END LOOP;/*end of for loop*/

     ELSE
       NULL;
     END IF;

   END LOOP; /*end of for loop*/

   --reset the language stuff
   SET_LANG_INFO_X( l_cur_lang, l_temp );

   EXCEPTION
     WHEN OTHERS THEN
       RAISE;

 END GET_FND_LOOKUP_CODES;



END IEU_CTRL_PVT;

------------------------------------------------------------------------
------------------------------------------------------------------------
--end of package
------------------------------------------------------------------------
------------------------------------------------------------------------


/
