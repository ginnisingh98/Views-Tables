--------------------------------------------------------
--  DDL for Package Body EGO_ICC_BULKLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_ICC_BULKLOAD_PVT" AS
/* $Header: EGOVICCB.pls 120.0.12010000.16 2010/06/22 15:02:56 vijoshi noship $ */


     g_icc_rec_count      NUMBER := 0;
     g_ag_assoc_rec_count NUMBER := 0;
     g_fn_param_map_count NUMBER := 0;
     g_icc_vers_rec_count NUMBER := 0;
     g_item_obj_id        NUMBER := NULL;
     g_old_icc_rec       mtl_item_catalog_groups_b%rowtype;


    CURSOR cur_get_obj_id
    IS
    SELECT object_id
    FROM   fnd_objects
    WHERE obj_name = G_ITEM_OBJ_NAME;

    TYPE number_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;  --- added bug 9701271

    -----------------------------------------------
    ---   This procedure prints the debugging information to a file or
    ---   to the concurrent program output
    ---
    -----------------------------------------------
    PROCEDURE write_debug( p_proc_name in VARCHAR2, p_message in VARCHAR2)
    IS
     -- PRAGMA AUTONOMOUS_TRANSACTION;
    BEGIN


     --- logging logic here  using G_PKG_NAME and p_PROC_NAME ---
     --dbms_output.put_line(' start insert=>'||p_proc_name||'**'||P_MESSAGE);
     --INSERT INTO TEMP_VJ VALUES (  xx_temp_vj.nextval||'-'||p_proc_name , p_message);
     --COMMIT;

      EGO_METADATA_BULKLOAD_PVT.write_debug(G_PKG_NAME||'.'||p_proc_name||'->'||p_message);


    EXCEPTION
    WHEN OTHERS THEN
      --dbms_output.put_line(SQLERRM);
      null;
    END write_debug;

   -----------------------------------------------
   --- Log the message in the interface errors table
   ---
   -----------------------------------------------

   PROCEDURE log_error ( p_transaction_id IN NUMBER
                        ,p_entity         IN VARCHAR2
                        ,p_message        IN VARCHAR2
                        ,p_proc_name      IN VARCHAR2
                       )
    IS

    BEGIN

      null;

    EXCEPTION
    WHEN OTHERS THEN
      null;
    END log_error;



    -----------------------------------------------
    ---  This procedure is used to validate the transaction type in the
    ---   interface tables
    ---
    -----------------------------------------------
    PROCEDURE Validate_Trans_Type ( p_entity         IN VARCHAR2
                                   ,x_return_status   OUT NOCOPY VARCHAR2
                                   ,x_return_msg  OUT NOCOPY VARCHAR2
                                  )

    IS
      L_proc_name VARCHAR2(30) :=  'Validate_Trans_Type';
      l_msg_name   fnd_new_messages.message_name%type;
      l_msg_text   fnd_new_messages.message_text%type;
      l_sysdate     DATE       := SYSDATE;

    BEGIN
          write_debug (l_proc_name, 'Start of  '||l_proc_name);
          x_return_status := G_RET_STS_SUCCESS;
          ---
          --- Validating if the transaction type is being passed
          ---

          IF p_entity = G_ENTITY_ICC_HEADER THEN

                l_msg_name := 'EGO_TRANS_TYPE_INVALID';
                FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
                l_msg_text := FND_MESSAGE.GET;

                INSERT INTO MTL_INTERFACE_ERRORS
                 (
                    TRANSACTION_ID
                    ,UNIQUE_ID
                    ,ORGANIZATION_ID
                    ,COLUMN_NAME
                    ,TABLE_NAME
                    ,MESSAGE_NAME
                    ,ERROR_MESSAGE
                    ,bo_identifier
                    ,ENTITY_IDENTIFIER
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,REQUEST_ID
                    ,PROGRAM_APPLICATION_ID
                    ,PROGRAM_ID
                    ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_ICC_HEADER_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_HEADER
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                FROM   MTL_ITEM_CAT_GRPS_INTERFACE MICGI
                WHERE  ( (MICGI.transaction_type IS NULL )
                             OR
                         (MICGI.transaction_type NOT IN ( G_TTYPE_CREATE , G_TTYPE_UPDATE
                                                       ,G_TTYPE_SYNC)
                         )
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( MICGI.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND process_status = G_PROCESS_STATUS_INITIAL
                ;

                --write_debug ( l_proc_name, 'rows inserted=>'||SQL%ROWCOUNT);

                ---
                --- mark the respective records as errors
                ---
                UPDATE MTL_ITEM_CAT_GRPS_INTERFACE MICGI
                SET micgi.process_status = G_PROCESS_STATUS_ERROR
                WHERE  ( micgi.transaction_type IS NULL OR
                         micgi.transaction_type NOT IN ( G_TTYPE_CREATE , G_TTYPE_UPDATE
                                                       ,G_TTYPE_SYNC)
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( MICGI.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND MICGI.process_status = G_PROCESS_STATUS_INITIAL
                ;


          END IF; -- entity  Header


          IF p_entity = G_ENTITY_ICC_AG_ASSOC THEN

                l_msg_name := 'EGO_TRANS_TYPE_INVALID';
                FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
                l_msg_text := FND_MESSAGE.GET;


                INSERT INTO MTL_INTERFACE_ERRORS
                 (
                    TRANSACTION_ID
                    ,UNIQUE_ID
                    ,ORGANIZATION_ID
                    ,COLUMN_NAME
                    ,TABLE_NAME
                    ,MESSAGE_NAME
                    ,ERROR_MESSAGE
                    ,bo_identifier
                    ,ENTITY_IDENTIFIER
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,REQUEST_ID
                    ,PROGRAM_APPLICATION_ID
                    ,PROGRAM_ID
                    ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_ICC_HEADER_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_AG_ASSOC
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                FROM   EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
                WHERE  ( eagai.transaction_type IS NULL OR
                         eagai.transaction_type NOT IN ( G_TTYPE_CREATE
                                                        ,G_TTYPE_DELETE)
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( EAGAI.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND process_status = G_PROCESS_STATUS_INITIAL
                ;


                UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
                SET eagai.process_status = G_PROCESS_STATUS_ERROR
                WHERE  ( eagai.transaction_type IS NULL OR
                         eagai.transaction_type NOT IN ( G_TTYPE_CREATE
                                                       , G_TTYPE_DELETE)
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( eagai.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND eagai.process_status = G_PROCESS_STATUS_INITIAL
                ;

          end if;

          IF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN

                l_msg_name := 'EGO_TRANS_TYPE_INVALID';
                FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
                l_msg_text := FND_MESSAGE.GET;


                INSERT INTO MTL_INTERFACE_ERRORS
                 (
                    TRANSACTION_ID
                    ,UNIQUE_ID
                    ,ORGANIZATION_ID
                    ,COLUMN_NAME
                    ,TABLE_NAME
                    ,MESSAGE_NAME
                    ,ERROR_MESSAGE
                    ,bo_identifier
                    ,ENTITY_IDENTIFIER
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,REQUEST_ID
                    ,PROGRAM_APPLICATION_ID
                    ,PROGRAM_ID
                    ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_FUNC_PARAM_MAP_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_FN_PARAM_MAP
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
               FROM   EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
               WHERE  ( efpmi.transaction_type IS NULL OR
                 efpmi.transaction_type NOT IN ( G_TTYPE_CREATE , G_TTYPE_UPDATE ,
                                              G_TTYPE_SYNC , G_TTYPE_DELETE)
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( EFPMI.set_process_id =  G_SET_PROCESS_ID)
                     )
               AND process_status = G_PROCESS_STATUS_INITIAL
               ;



                UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
                SET efpmi.process_status = G_PROCESS_STATUS_ERROR
                WHERE  ( efpmi.transaction_type IS NULL OR
                         efpmi.transaction_type NOT IN ( G_TTYPE_CREATE , G_TTYPE_UPDATE
                                                       ,G_TTYPE_SYNC, G_TTYPE_DELETE)
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND efpmi.process_status = G_PROCESS_STATUS_INITIAL
                ;


          END IF;


          if p_entity = G_ENTITY_ICC_VERSION THEN

                l_msg_name := 'EGO_TRANS_TYPE_ICC_VER_INVALID';
                FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
                l_msg_text := FND_MESSAGE.GET;

               ---
               --- Insert for versioning interface table
               ---

                INSERT INTO MTL_INTERFACE_ERRORS
                 (
                    TRANSACTION_ID
                    ,UNIQUE_ID
                    ,ORGANIZATION_ID
                    ,COLUMN_NAME
                    ,TABLE_NAME
                    ,MESSAGE_NAME
                    ,ERROR_MESSAGE
                    ,bo_identifier
                    ,ENTITY_IDENTIFIER
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,REQUEST_ID
                    ,PROGRAM_APPLICATION_ID
                    ,PROGRAM_ID
                    ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_ICC_VERS_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_VERSION
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                FROM   EGO_ICC_VERS_INTERFACE EIVI
                WHERE  ( EIVI.transaction_type IS NULL OR
                         EIVI.transaction_type NOT IN ( G_TTYPE_CREATE )
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( EIVI.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND EIVI.process_status = G_PROCESS_STATUS_INITIAL
                ;

                UPDATE EGO_ICC_VERS_INTERFACE EIVI
                SET EIVI.process_status = G_PROCESS_STATUS_ERROR
                WHERE  ( EIVI.transaction_type IS NULL OR
                         EIVI.transaction_type  <> G_TTYPE_CREATE
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( EIVI.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND EIVI.process_status = G_PROCESS_STATUS_INITIAL
                ;

        END IF;


      write_debug (l_proc_name, 'End of  '||l_proc_name);
    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
      return;
    END Validate_Trans_Type;


    -----------------------------------------------
    ---  This procedure is used to validate the Entity cols in the
    ---   interface tables eg. ag_name and ag_id in attr assoc interface table
    ---
    -----------------------------------------------
    PROCEDURE Validate_Entity_Cols (  p_entity         IN VARCHAR2
                                     ,x_return_status  OUT NOCOPY VARCHAR2
                                     ,x_return_msg  OUT NOCOPY VARCHAR2
                                             )

    IS
      L_proc_name VARCHAR2(30) :=  'Validate_Entity_Cols';
      l_msg_name   fnd_new_messages.message_name%type;
      l_msg_text   fnd_new_messages.message_text%type;
      l_sysdate     DATE       := SYSDATE;

    BEGIN
          write_debug (l_proc_name, 'Start of  '||l_proc_name);
          x_return_status := G_RET_STS_SUCCESS;

          l_msg_name := 'EGO_REQ_COLNS_MISSING';
          FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
          l_msg_text := FND_MESSAGE.GET;


          IF p_entity = G_ENTITY_ICC_HEADER THEN
                ---- Validate some of the bare essential columns for
                ---- every interface table


                INSERT INTO MTL_INTERFACE_ERRORS
                 (
                    TRANSACTION_ID
                    ,UNIQUE_ID
                    ,ORGANIZATION_ID
                    ,COLUMN_NAME
                    ,TABLE_NAME
                    ,MESSAGE_NAME
                    ,ERROR_MESSAGE
                    ,bo_identifier
                    ,ENTITY_IDENTIFIER
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,REQUEST_ID
                    ,PROGRAM_APPLICATION_ID
                    ,PROGRAM_ID
                    ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_ICC_HEADER_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_HEADER
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                FROM MTL_ITEM_CAT_GRPS_INTERFACE MICGI
                WHERE
                      (   micgi.item_catalog_name is NULL  AND
                          micgi.item_catalog_group_id   is NULL  AND
                          micgi.segment1 is NULL  AND micgi.segment14 is NULL AND
                          micgi.segment2 is NULL  AND micgi.segment15 is NULL AND
                          micgi.segment3 is NULL  AND micgi.segment16 is NULL AND
                          micgi.segment4 is NULL  AND micgi.segment17 is NULL AND
                          micgi.segment5 is NULL  AND micgi.segment18 is NULL AND
                          micgi.segment6 is NULL  AND micgi.segment19 is NULL AND
                          micgi.segment7 is NULL  AND micgi.segment20 is NULL AND
                          micgi.segment8 is NULL  AND
                          micgi.segment9 is NULL  AND
                          micgi.segment10 is NULL AND
                          micgi.segment11 is NULL AND
                          micgi.segment12 is NULL AND
                          micgi.segment13 is NULL
                      )
                AND  micgi.process_status = G_PROCESS_STATUS_INITIAL
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( MICGI.set_process_id =  G_SET_PROCESS_ID)
                     )
                ;
                write_debug ( l_proc_name, 'rows inserted=>'||SQL%ROWCOUNT);

                ---
                --- mark the respective records as errors
                ---
                UPDATE MTL_ITEM_CAT_GRPS_INTERFACE micgi
                SET micgi.process_status = G_PROCESS_STATUS_ERROR
                WHERE  (   micgi.item_catalog_name is NULL  AND
                          micgi.item_catalog_group_id   is NULL  AND
                          micgi.segment1 is NULL  AND micgi.segment14 is NULL AND
                          micgi.segment2 is NULL  AND micgi.segment15 is NULL AND
                          micgi.segment3 is NULL  AND micgi.segment16 is NULL AND
                          micgi.segment4 is NULL  AND micgi.segment17 is NULL AND
                          micgi.segment5 is NULL  AND micgi.segment18 is NULL AND
                          micgi.segment6 is NULL  AND micgi.segment19 is NULL AND
                          micgi.segment7 is NULL  AND micgi.segment20 is NULL AND
                          micgi.segment8 is NULL  AND
                          micgi.segment9 is NULL  AND
                          micgi.segment10 is NULL AND
                          micgi.segment11 is NULL AND
                          micgi.segment12 is NULL AND
                          micgi.segment13 is NULL
                      )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( MICGI.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND  micgi.process_status = G_PROCESS_STATUS_INITIAL
                ;

       END IF; --- header


       IF p_entity = G_ENTITY_ICC_AG_ASSOC THEN

                    INSERT INTO MTL_INTERFACE_ERRORS
                     (
                        TRANSACTION_ID
                        ,UNIQUE_ID
                        ,ORGANIZATION_ID
                        ,COLUMN_NAME
                        ,TABLE_NAME
                        ,MESSAGE_NAME
                        ,ERROR_MESSAGE
                        ,bo_identifier
                        ,ENTITY_IDENTIFIER
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,REQUEST_ID
                        ,PROGRAM_APPLICATION_ID
                        ,PROGRAM_ID
                        ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_ICC_HEADER_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_AG_ASSOC
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                 FROM   EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
                 WHERE  ( (eagai.item_catalog_group_id IS NULL AND
                          eagai.item_catalog_name IS NULL )
                           OR
                          ( eagai.attr_group_name IS NULL AND
                            eagai.attr_group_id IS NULL )
                        )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( eagai.set_process_id =  G_SET_PROCESS_ID)
                     )
                 AND  eagai.process_status = G_PROCESS_STATUS_INITIAL
                ;

                UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
                SET eagai.process_status = G_PROCESS_STATUS_ERROR
                WHERE  ( (eagai.item_catalog_group_id IS NULL AND
                         eagai.item_catalog_name IS NULL )
                          OR
                         ( eagai.attr_group_name IS NULL AND
                           eagai.attr_group_id IS NULL )
                       )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( eagai.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND  eagai.process_status = G_PROCESS_STATUS_INITIAL
                ;


       END IF ; -- ag assoc

       IF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN

                  INSERT INTO MTL_INTERFACE_ERRORS
                                 (
                                    TRANSACTION_ID
                                    ,UNIQUE_ID
                                    ,ORGANIZATION_ID
                                    ,COLUMN_NAME
                                    ,TABLE_NAME
                                    ,MESSAGE_NAME
                                    ,ERROR_MESSAGE
                                    ,bo_identifier
                                    ,ENTITY_IDENTIFIER
                                    ,LAST_UPDATE_DATE
                                    ,LAST_UPDATED_BY
                                    ,CREATION_DATE
                                    ,CREATED_BY
                                    ,LAST_UPDATE_LOGIN
                                    ,REQUEST_ID
                                    ,PROGRAM_APPLICATION_ID
                                    ,PROGRAM_ID
                                    ,PROGRAM_UPDATE_DATE
                                  )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_FUNC_PARAM_MAP_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_FN_PARAM_MAP
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                 FROM   EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
                 WHERE  ( (efpmi.item_catalog_group_id IS NULL AND
                           efpmi.item_catalog_name IS NULL)
                           OR
                           (
                            efpmi.function_name IS NULL AND
                            efpmi.function_id   IS NULL )
                            OR
                           (
                            efpmi.parameter_name IS NULL AND
                            efpmi.parameter_id IS NULL )
                         )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                     )
                 AND  efpmi.process_status = G_PROCESS_STATUS_INITIAL
                 ;

                UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
                SET efpmi.process_status = G_PROCESS_STATUS_ERROR
                WHERE  ( (efpmi.item_catalog_group_id IS NULL AND
                          efpmi.item_catalog_name IS NULL)
                          OR
                          (
                           efpmi.function_name IS NULL AND
                           efpmi.function_id   IS NULL )
                           OR
                          (
                           efpmi.parameter_name IS NULL AND
                           efpmi.parameter_id IS NULL )
                        )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                     )
                AND  efpmi.process_status = G_PROCESS_STATUS_INITIAL
                ;

       END IF;

       IF p_entity = G_ENTITY_ICC_VERSION THEN

                ---
                --- Added if condition bug 9791391
                ---  if the P4T profile is not enabled , error out the version records
                ---

                IF NOT G_P4TP_PROFILE_ENABLED THEN

                    l_msg_name := 'EGO_P4T_PROFILE_DISABLED_ERROR';
                    FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
                    fnd_message.set_token('ENTITY_NAME' , G_ENTITY_ICC_VERSION);
                    l_msg_text := FND_MESSAGE.GET;


                    --- Versioning interface columns
                    ---
                    INSERT INTO MTL_INTERFACE_ERRORS
                     (
                        TRANSACTION_ID
                        ,UNIQUE_ID
                        ,ORGANIZATION_ID
                        ,COLUMN_NAME
                        ,TABLE_NAME
                        ,MESSAGE_NAME
                        ,ERROR_MESSAGE
                        ,bo_identifier
                        ,ENTITY_IDENTIFIER
                        ,LAST_UPDATE_DATE
                        ,LAST_UPDATED_BY
                        ,CREATION_DATE
                        ,CREATED_BY
                        ,LAST_UPDATE_LOGIN
                        ,REQUEST_ID
                        ,PROGRAM_APPLICATION_ID
                        ,PROGRAM_ID
                        ,PROGRAM_UPDATE_DATE
                     )
                     SELECT transaction_id
                           ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                           ,null
                           ,null
                           ,G_ENTITY_ICC_VERS_TAB
                           ,l_msg_name
                           ,l_msg_text
                           ,G_BO_IDENTIFIER_ICC
                           ,G_ENTITY_ICC_VERSION
                           ,l_sysdate
                           ,G_USER_ID
                           ,l_sysdate
                           ,G_USER_ID
                           ,G_LOGIN_ID
                           ,G_CONC_REQUEST_ID
                           ,G_PROG_APPL_ID
                           ,G_PROGRAM_ID
                           ,l_sysdate
                    FROM EGO_ICC_VERS_INTERFACE eivi
                    where (
                             ( G_SET_PROCESS_ID IS NULL )
                              OR
                             ( eivi.set_process_id =  G_SET_PROCESS_ID)
                         )
                     AND  eivi.process_status = G_PROCESS_STATUS_INITIAL
                     ;

                    UPDATE EGO_ICC_VERS_INTERFACE eivi
                    SET eivi.process_status = G_PROCESS_STATUS_ERROR
                    where (
                             ( G_SET_PROCESS_ID IS NULL )
                              OR
                             ( eivi.set_process_id =  G_SET_PROCESS_ID)
                         )
                     AND  eivi.process_status = G_PROCESS_STATUS_INITIAL
                     ;
                END IF;
                --- end bug 9791391





                l_msg_name := 'EGO_REQ_COLNS_MISSING';
                FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
                l_msg_text := FND_MESSAGE.GET;


                --- Versioning interface columns
                ---
                INSERT INTO MTL_INTERFACE_ERRORS
                 (
                    TRANSACTION_ID
                    ,UNIQUE_ID
                    ,ORGANIZATION_ID
                    ,COLUMN_NAME
                    ,TABLE_NAME
                    ,MESSAGE_NAME
                    ,ERROR_MESSAGE
                    ,bo_identifier
                    ,ENTITY_IDENTIFIER
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,REQUEST_ID
                    ,PROGRAM_APPLICATION_ID
                    ,PROGRAM_ID
                    ,PROGRAM_UPDATE_DATE
                 )
                 SELECT transaction_id
                       ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                       ,null
                       ,null
                       ,G_ENTITY_ICC_VERS_TAB
                       ,l_msg_name
                       ,l_msg_text
                       ,G_BO_IDENTIFIER_ICC
                       ,G_ENTITY_ICC_VERSION
                       ,l_sysdate
                       ,G_USER_ID
                       ,l_sysdate
                       ,G_USER_ID
                       ,G_LOGIN_ID
                       ,G_CONC_REQUEST_ID
                       ,G_PROG_APPL_ID
                       ,G_PROGRAM_ID
                       ,l_sysdate
                FROM EGO_ICC_VERS_INTERFACE eivi
                where (
                          ( eivi.item_catalog_name IS NULL AND
                            eivi.item_catalog_group_id  IS NULL
                          )
                      )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( eivi.set_process_id =  G_SET_PROCESS_ID)
                     )
                 AND  eivi.process_status = G_PROCESS_STATUS_INITIAL
                 ;

                UPDATE EGO_ICC_VERS_INTERFACE eivi
                SET eivi.process_status = G_PROCESS_STATUS_ERROR
                where (
                          ( eivi.item_catalog_name IS NULL AND
                            eivi.item_catalog_group_id  IS NULL
                          )
                      )
                AND  (
                         ( G_SET_PROCESS_ID IS NULL )
                          OR
                         ( eivi.set_process_id =  G_SET_PROCESS_ID)
                     )
                 AND  eivi.process_status = G_PROCESS_STATUS_INITIAL
                 ;


          l_msg_name := 'EGO_ICC_VER_SEQ_NO_INVALID';
          FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
          l_msg_text := FND_MESSAGE.GET;


          --- Insert errors for ICC Name
          ---
          INSERT INTO MTL_INTERFACE_ERRORS
           (
              TRANSACTION_ID
              ,UNIQUE_ID
              ,ORGANIZATION_ID
              ,COLUMN_NAME
              ,TABLE_NAME
              ,MESSAGE_NAME
              ,ERROR_MESSAGE
              ,BO_IDENTIFIER
              ,ENTITY_IDENTIFIER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
           )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_ICC_VERS_TAB
                  ,l_msg_name
                  ,l_msg_text
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_VERSION
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
             FROM  ego_icc_vers_interface eivi
             WHERE 1=1
             AND   ---( eivi.ver_seq_no <= 0      ---- commented bug 9752139, moved to row by row
                   ---   OR
                     eivi.ver_seq_no IS NULL
                   ---)
             AND   eivi.transaction_id IS NOT NULL
             AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
             AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( eivi.set_process_id =  G_SET_PROCESS_ID)
                  );


            UPDATE EGO_ICC_VERS_INTERFACE eivi
            SET eivi.process_status = G_PROCESS_STATUS_ERROR
           WHERE 1=1
             AND   ---( eivi.ver_seq_no <= 0      ---- commented bug 9752139, moved to row by row
                   ---   OR
                     eivi.ver_seq_no IS NULL
                   ---)
             AND   eivi.transaction_id IS NOT NULL
             AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
             AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( eivi.set_process_id =  G_SET_PROCESS_ID)
              );


       END IF; --- versioning interface

      write_debug (l_proc_name, 'End of  '||l_proc_name);
    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
    END Validate_Entity_Cols;


    -----------------------------------------------
    --- This procedure is used to validate the required columns
    --- or bare essential meta data informaiton in the
    --- interface tables
    -----------------------------------------------




    PROCEDURE Validate_Name_ID_Cols ( p_entity         IN VARCHAR2
                                     ,x_return_status  OUT NOCOPY VARCHAR2
                                     ,x_return_msg     OUT NOCOPY VARCHAR2
                                     )

    IS
      l_proc_name   varchar2(30) :=  'Validate_Name_ID_Cols';
      l_msg_name    fnd_new_messages.message_name%type;
      l_msg_text    fnd_new_messages.message_text%type;
      l_msg_name2   fnd_new_messages.message_name%type;
      l_msg_text2   fnd_new_messages.message_text%type;
      l_msg_name3   fnd_new_messages.message_name%type;
      l_msg_text3   fnd_new_messages.message_text%type;
      l_msg_name4   fnd_new_messages.message_name%type;
      l_msg_text4   fnd_new_messages.message_text%type;
      l_msg_name5   fnd_new_messages.message_name%type;
      l_msg_text5   fnd_new_messages.message_text%type;


      l_sysdate     DATE       := SYSDATE;
      l_item_data_level VARCHAR2(50) := 'ITEM_LEVEL';


    BEGIN
      write_debug (l_proc_name, 'Start of  '||l_proc_name);

      x_return_status := G_RET_STS_SUCCESS;

       IF p_entity = G_ENTITY_ICC_HEADER THEN
           --- ICC table , ICC Name

           UPDATE mtl_item_cat_grps_interface micgi
           SET    item_catalog_name = ( select icc_kfv.concatenated_segments
                                        from   mtl_item_catalog_groups_kfv icc_kfv
                                        where icc_kfv.item_catalog_group_id = micgi.item_catalog_group_id
                                      )
           WHERE micgi.item_catalog_group_id IS NOT NULL
           AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( MICGI.set_process_id =  G_SET_PROCESS_ID)
               )
           ;



           UPDATE mtl_item_cat_grps_interface micgi
           SET    micgi.item_catalog_group_id = ( select icc_kfv.item_catalog_group_id
                                                  from   mtl_item_catalog_groups_kfv icc_kfv
                                                  where icc_kfv.concatenated_segments = micgi.item_catalog_name
                                                )
           WHERE micgi.item_catalog_name IS NOT NULL
           AND   micgi.item_catalog_group_id IS NULL
           AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( MICGI.set_process_id =  G_SET_PROCESS_ID)
               )
           ;

          --- insert into mtl_interface_errors
          ---

          l_msg_name := 'EGO_ITEMCATALOG_INVALID';
          FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
          l_msg_text := FND_MESSAGE.GET;


          --- Insert errors for ICC Name
          ---
          INSERT INTO MTL_INTERFACE_ERRORS
           (
              TRANSACTION_ID
              ,UNIQUE_ID
              ,ORGANIZATION_ID
              ,COLUMN_NAME
              ,TABLE_NAME
              ,MESSAGE_NAME
              ,ERROR_MESSAGE
              ,BO_IDENTIFIER
              ,ENTITY_IDENTIFIER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
           )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_ICC_HEADER_TAB
                  ,l_msg_name
                  ,l_msg_text
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_HEADER
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
             FROM  mtl_item_cat_grps_interface micgi
             WHERE micgi.item_catalog_name IS NULL
             AND   micgi.item_catalog_group_id IS NOT NULL
             AND   micgi.transaction_id IS NOT NULL
             AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
             AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( micgi.set_process_id =  G_SET_PROCESS_ID)
                  ) ;

           --- update status flag in ICC interface table

           UPDATE MTL_ITEM_CAT_GRPS_INTERFACE micgi
            set process_status = G_PROCESS_STATUS_ERROR
           WHERE micgi.item_catalog_group_id is NOT NULL
           AND   micgi.item_catalog_name IS NULL
           and   micgi.transaction_id IS NOT NULL
           AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( MICGI.set_process_id =  G_SET_PROCESS_ID)
                )
              ;


           /*****************************************
           --- ICC Parent id , ICC Parent Name
           ---
           /*****************************************/

           UPDATE mtl_item_cat_grps_interface micgi
           SET    parent_catalog_group_name = ( select icc_kfv.concatenated_segments
                                                from   mtl_item_catalog_groups_kfv icc_kfv
                                                where icc_kfv.item_catalog_group_id = micgi.parent_catalog_group_id
                                               )
           WHERE micgi.parent_catalog_group_id IS NOT NULL
           AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( MICGI.set_process_id =  G_SET_PROCESS_ID)
               )
           ;



           UPDATE mtl_item_cat_grps_interface micgi
           SET    micgi.parent_catalog_group_id = ( select icc_kfv.item_catalog_group_id
                                                  from   mtl_item_catalog_groups_kfv icc_kfv
                                                  where icc_kfv.concatenated_segments = micgi.parent_catalog_group_name
                                                )
           WHERE micgi.parent_catalog_group_name IS NOT NULL
           AND   micgi.parent_catalog_group_id IS NULL
           AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( MICGI.set_process_id =  G_SET_PROCESS_ID)
               )
           ;

          --- insert into mtl_interface_errors
          ---

          l_msg_name := 'EGO_ICC_PARENT_INVALID';
          FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
          l_msg_text := FND_MESSAGE.GET;


          --- Insert errors for ICC Name
          ---
          INSERT INTO MTL_INTERFACE_ERRORS
           (
              TRANSACTION_ID
              ,UNIQUE_ID
              ,ORGANIZATION_ID
              ,COLUMN_NAME
              ,TABLE_NAME
              ,MESSAGE_NAME
              ,ERROR_MESSAGE
              ,BO_IDENTIFIER
              ,ENTITY_IDENTIFIER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
           )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_ICC_HEADER_TAB
                  ,l_msg_name
                  ,l_msg_text
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_HEADER
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
             FROM  mtl_item_cat_grps_interface micgi
             WHERE micgi.parent_catalog_group_name IS NULL
             AND   micgi.parent_catalog_group_id IS NOT NULL
             AND   micgi.transaction_id IS NOT NULL
             AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
             AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( micgi.set_process_id =  G_SET_PROCESS_ID)
                  ) ;

           --- update status flag in ICC interface table for invalid parent ICC  names

           UPDATE MTL_ITEM_CAT_GRPS_INTERFACE micgi
            set process_status = G_PROCESS_STATUS_ERROR
           WHERE micgi.parent_catalog_group_name IS NULL
           AND   micgi.parent_catalog_group_id is NOT NULL
           and   micgi.transaction_id IS NOT NULL
           AND   micgi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( MICGI.set_process_id =  G_SET_PROCESS_ID)
                )
              ;



       END IF;     -- entity = header



       IF p_entity = G_ENTITY_ICC_AG_ASSOC THEN
           --- Update the AG Table, attr_group_name
           ---

           UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE EAGAI
           SET attr_group_name = ( select eagv.attr_group_name
                                 from ego_attr_groups_v EAGv
                                 where EAGv.attr_group_id = EAGAI.attr_group_id
                               )
           WHERE eagai.attr_group_id IS NOT NULL
           AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               )
           ;


           --- Update the AG Table , attr_group_id
           ---

           UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE EAGAI
           SET attr_group_id = ( select eagv.attr_group_id
                                 from ego_attr_groups_v EAGv
                                 where EAGv.attr_group_name = EAGAI.attr_group_name
                               )
           WHERE eagai.attr_group_id IS NULL
           AND   eagai.attr_group_name IS NOT NULL
           AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               )
           ;


           --- Update AG table, ICC Name
           ---
           UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE EAGAI
           SET  eagai.item_catalog_name = ( select icc_kfv.concatenated_segments
                                                  from   mtl_item_catalog_groups_kfv icc_kfv
                                                  where icc_kfv.item_catalog_group_id = eagai.item_catalog_group_id
                                                )
           WHERE eagai.item_catalog_group_id IS NOT NULL
           AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               )
           ;



           ---Update AG table, ICC id
           UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE EAGAI
           SET  eagai.item_catalog_group_id = ( select icc_kfv.item_catalog_group_id
                                                  from   mtl_item_catalog_groups_kfv icc_kfv
                                                  where icc_kfv.concatenated_segments = eagai.item_catalog_name
                                                )
           WHERE eagai.item_catalog_name IS NOT NULL
           AND   eagai.item_catalog_group_id IS NULL
           AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               )
           ;

          --- insert into mtl_interface_errors
          ---

          l_msg_name := 'EGO_ITEMCATALOG_INVALID';
          FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
          l_msg_text := FND_MESSAGE.GET;

          INSERT INTO MTL_INTERFACE_ERRORS
           (
              TRANSACTION_ID
              ,UNIQUE_ID
              ,ORGANIZATION_ID
              ,COLUMN_NAME
              ,TABLE_NAME
              ,MESSAGE_NAME
              ,ERROR_MESSAGE
              ,BO_IDENTIFIER
              ,ENTITY_IDENTIFIER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
           )
           SELECT transaction_id
                 ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                 ,null
                 ,null
                 ,G_ENTITY_ICC_AG_ASSOC_TAB
                 ,l_msg_name
                 ,l_msg_text
                 ,G_BO_IDENTIFIER_ICC
                 ,G_ENTITY_ICC_AG_ASSOC
                 ,l_sysdate
                 ,G_USER_ID
                 ,l_sysdate
                 ,G_USER_ID
                 ,G_LOGIN_ID
                 ,G_CONC_REQUEST_ID
                 ,G_PROG_APPL_ID
                 ,G_PROGRAM_ID
                 ,l_sysdate
          FROM  EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
          WHERE eagai.item_catalog_name IS NULL
          OR    eagai.item_catalog_group_id IS NULL
          AND   eagai.transaction_id IS NOT NULL
          AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
          AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                  OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               );

           l_msg_name2 := 'EGO_AG_NAME_MISSING';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name2 );
           l_msg_text2 := FND_MESSAGE.GET;

          INSERT INTO MTL_INTERFACE_ERRORS
           (
              TRANSACTION_ID
              ,UNIQUE_ID
              ,ORGANIZATION_ID
              ,COLUMN_NAME
              ,TABLE_NAME
              ,MESSAGE_NAME
              ,ERROR_MESSAGE
              ,bo_identifier
              ,ENTITY_IDENTIFIER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
           )
           SELECT transaction_id
                 ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                 ,null
                 ,null
                 ,G_ENTITY_ICC_AG_ASSOC_TAB
                 ,l_msg_name2
                 ,l_msg_text2
                 ,G_BO_IDENTIFIER_ICC
                 ,G_ENTITY_ICC_AG_ASSOC
                 ,l_sysdate
                 ,G_USER_ID
                 ,l_sysdate
                 ,G_USER_ID
                 ,G_LOGIN_ID
                 ,G_CONC_REQUEST_ID
                 ,G_PROG_APPL_ID
                 ,G_PROGRAM_ID
                 ,l_sysdate
          FROM  EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
          WHERE ( eagai.attr_group_name IS NULL
                    OR
                  eagai.attr_group_id IS NULL
                )
          AND   eagai.transaction_id IS NOT NULL
          AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
          AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                  OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               )
              ;

          --- update status flag in interface table
          ---
          UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE eagai
          set process_status = G_PROCESS_STATUS_ERROR
          WHERE eagai.item_catalog_name IS NULL
          OR    eagai.item_catalog_group_id IS NULL
          OR    eagai.attr_group_name IS NULL
          OR    eagai.attr_group_id IS NULL
          AND   eagai.transaction_id IS NOT NULL
          AND   eagai.process_status = G_PROCESS_STATUS_INITIAL
          AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                  OR
                  ( eagai.set_process_id =  G_SET_PROCESS_ID)
               )
               ;

       END IF; --- entity = AG Association


       IF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN
           ---- Validation for the func_param_interface
           ----


           --- ICC Name
           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           SET  efpmi.item_catalog_name = ( select icc_kfv.concatenated_segments
                                            from   mtl_item_catalog_groups_kfv icc_kfv
                                             where icc_kfv.item_catalog_group_id = efpmi.item_catalog_group_id
                                          )
           WHERE efpmi.item_catalog_group_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           -- ICC id

           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           SET  efpmi.item_catalog_group_id = ( select icc_kfv.item_catalog_group_id
                                               from   mtl_item_catalog_groups_kfv icc_kfv
                                               where icc_kfv.concatenated_segments = efpmi.item_catalog_name
                                             )
           WHERE efpmi.item_catalog_name IS NOT NULL
           AND   efpmi.item_catalog_group_id IS NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;




           --- Get the Attr group name
           ---
           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.attr_group_name =(  SELECT agv.attr_group_id
                                           FROM ego_attr_groups_v agv,
                                                   ego_obj_attr_grp_assocs_v oagv,
                                                   ego_catalog_groups_v cg
                                             WHERE oagv.attr_group_id = agv.attr_group_id
                                               AND agv.attr_group_id = EFPMI.ATTR_GROUP_ID
                                               AND cg.catalog_group_id = oagv.classification_code
                                               AND oagv.object_id = g_item_obj_id
                                               and oagv.data_level_int_name = l_item_data_level
                                               AND oagv.classification_code
                                               IN (
                                                   SELECT TO_CHAR (item_catalog_group_id)
                                                   FROM mtl_item_catalog_groups_b
                                                   CONNECT BY PRIOR parent_catalog_group_id =
                                                                       item_catalog_group_id
                                                   START WITH item_catalog_group_id = EFPMI.ITEM_CATALOG_GROUP_ID
                                                  )
                                          )
           WHERE efpmi.attr_group_id IS NOT NULL
           AND   efpmi.item_catalog_group_id is not null
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           -- Attr Group id

           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.attr_group_id = (  SELECT agv.attr_group_id
                                           FROM ego_attr_groups_v agv,
                                                   ego_obj_attr_grp_assocs_v oagv,
                                                   ego_catalog_groups_v cg
                                             WHERE oagv.attr_group_id = agv.attr_group_id
                                               AND agv.attr_group_name = EFPMI.ATTR_GROUP_NAME
                                               AND cg.catalog_group_id = oagv.classification_code
                                               AND oagv.object_id = g_item_obj_id
                                               and oagv.data_level_int_name = l_item_data_level
                                               AND oagv.classification_code
                                               IN (
                                                   SELECT TO_CHAR (item_catalog_group_id)
                                                   FROM mtl_item_catalog_groups_b
                                                   CONNECT BY PRIOR parent_catalog_group_id =
                                                                       item_catalog_group_id
                                                   START WITH item_catalog_group_id = EFPMI.ITEM_CATALOG_GROUP_ID
                                                  )
                                          )
           WHERE efpmi.attr_group_name IS NOT NULL
           AND   efpmi.attr_group_id IS NULL
           AND   efpmi.item_catalog_group_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           -- Attribute  name

           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.attr_name = (  SELECT eav.attr_name
                                       FROM ego_attrs_v eav
                                       WHERE eav.attr_id = efpmi.attr_id
                                       AND   eav.attr_group_name = efpmi.attr_group_name
                                    )
           WHERE efpmi.attr_name IS NULL
           AND   efpmi.attr_id IS NOT NULL
           AND   efpmi.attr_group_name IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           --- Attr ID
           ---
           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.attr_id = ( select eav.attr_id
                                    from ego_attrs_v eav
                                    where eav.attr_name = efpmi.attr_name
                                    and   eav.attr_group_name = efpmi.attr_group_name
                                  )
           WHERE efpmi.attr_id is null
           AND   efpmi.attr_name IS NOT NULL
           AND   efpmi.attr_group_name IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           --- Function name
           ---
           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.function_name = (  select efv.internal_name
                                       from ego_functions_v efv
                                       where efv.function_id = efv.function_id
                                    )
           WHERE efpmi.function_name IS NULL
           AND   efpmi.function_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           --- Function id
           ---
           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.function_id = ( select efv.function_id
                                        from ego_functions_v efv
                                        where efv.internal_name = efpmi.function_name
                                       )
           WHERE efpmi.function_id IS NULL
           AND   efpmi.function_name IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;



           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.parameter_id = ( select efpb.func_param_id
                                        from ego_func_params_b efpb
                                        where efpb.internal_name = efpmi.parameter_name
                                        and   efpb.function_id = efpmi.function_id
                                       )
           WHERE efpmi.parameter_id IS NULL
           AND   efpmi.parameter_name IS NOT NULL
           AND   efpmi.function_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;



           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           set    efpmi.parameter_name = ( select efpb.internal_name
                                        from ego_func_params_b efpb
                                        where efpb.func_param_id = efpmi.parameter_id
                                        and   efpb.function_id = efpmi.function_id
                                       )
           WHERE efpmi.parameter_name IS NULL
           AND   efpmi.parameter_id IS NOT NULL
           AND   efpmi.function_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;



           --- insert into mtl_interface_errors
           ---

           l_msg_name := 'EGO_ITEMCATALOG_INVALID';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
           l_msg_text := FND_MESSAGE.GET;

           l_msg_name2 := 'EGO_AG_NAME_MISSING';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name2 );
           l_msg_text2 := FND_MESSAGE.GET;

           l_msg_name3 := 'EGO_ATTR_NAME_MISSING';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name3 );
           l_msg_text3 := FND_MESSAGE.GET;


           l_msg_name4 := 'EGO_ICC_FUNCTION_INVALID';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name4 );
           l_msg_text4 := FND_MESSAGE.GET;


           l_msg_name5 := 'EGO_ICC_FUNC_PARAM_INVALID';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name5 );
           l_msg_text5 := FND_MESSAGE.GET;


           --- Insert errors for ICC Name
           ---
           INSERT INTO MTL_INTERFACE_ERRORS
            (
               TRANSACTION_ID
               ,UNIQUE_ID
               ,ORGANIZATION_ID
               ,COLUMN_NAME
               ,TABLE_NAME
               ,MESSAGE_NAME
               ,ERROR_MESSAGE
               ,bo_identifier
               ,ENTITY_IDENTIFIER
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,REQUEST_ID
               ,PROGRAM_APPLICATION_ID
               ,PROGRAM_ID
               ,PROGRAM_UPDATE_DATE
            )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_FUNC_PARAM_MAP_TAB
                  ,l_msg_name
                  ,l_msg_text
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_FN_PARAM_MAP
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
           FROM  EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           WHERE efpmi.item_catalog_name IS NULL
           OR    efpmi.item_catalog_group_id IS NULL
           AND   efpmi.transaction_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                );

           INSERT INTO MTL_INTERFACE_ERRORS
            (
               TRANSACTION_ID
               ,UNIQUE_ID
               ,ORGANIZATION_ID
               ,COLUMN_NAME
               ,TABLE_NAME
               ,MESSAGE_NAME
               ,ERROR_MESSAGE
               ,bo_identifier
               ,ENTITY_IDENTIFIER
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,REQUEST_ID
               ,PROGRAM_APPLICATION_ID
               ,PROGRAM_ID
               ,PROGRAM_UPDATE_DATE
            )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_FUNC_PARAM_MAP_TAB
                  ,l_msg_name2
                  ,l_msg_text2
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_FN_PARAM_MAP
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
           FROM  EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           WHERE efpmi.attr_group_name IS NULL
           OR    efpmi.attr_group_id IS NULL
           AND   efpmi.transaction_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                );

           INSERT INTO MTL_INTERFACE_ERRORS
            (
               TRANSACTION_ID
               ,UNIQUE_ID
               ,ORGANIZATION_ID
               ,COLUMN_NAME
               ,TABLE_NAME
               ,MESSAGE_NAME
               ,ERROR_MESSAGE
               ,bo_identifier
               ,ENTITY_IDENTIFIER
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,REQUEST_ID
               ,PROGRAM_APPLICATION_ID
               ,PROGRAM_ID
               ,PROGRAM_UPDATE_DATE
            )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_FUNC_PARAM_MAP_TAB
                  ,l_msg_name3
                  ,l_msg_text3
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_FN_PARAM_MAP
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
           FROM  EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           WHERE efpmi.attr_name IS NULL
           OR    efpmi.attr_id IS NULL
           AND   efpmi.transaction_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;


           ---
           --- Function name errors
           ---
           INSERT INTO MTL_INTERFACE_ERRORS
            (
               TRANSACTION_ID
               ,UNIQUE_ID
               ,ORGANIZATION_ID
               ,COLUMN_NAME
               ,TABLE_NAME
               ,MESSAGE_NAME
               ,ERROR_MESSAGE
               ,bo_identifier
               ,ENTITY_IDENTIFIER
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,REQUEST_ID
               ,PROGRAM_APPLICATION_ID
               ,PROGRAM_ID
               ,PROGRAM_UPDATE_DATE
            )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_FUNC_PARAM_MAP_TAB
                  ,l_msg_name3
                  ,l_msg_text3
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_FN_PARAM_MAP
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
           FROM  EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           WHERE efpmi.function_name IS NULL
           OR    efpmi.function_id IS NULL
           AND   efpmi.transaction_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
                ;

           INSERT INTO MTL_INTERFACE_ERRORS
            (
               TRANSACTION_ID
               ,UNIQUE_ID
               ,ORGANIZATION_ID
               ,COLUMN_NAME
               ,TABLE_NAME
               ,MESSAGE_NAME
               ,ERROR_MESSAGE
               ,bo_identifier
               ,ENTITY_IDENTIFIER
               ,LAST_UPDATE_DATE
               ,LAST_UPDATED_BY
               ,CREATION_DATE
               ,CREATED_BY
               ,LAST_UPDATE_LOGIN
               ,REQUEST_ID
               ,PROGRAM_APPLICATION_ID
               ,PROGRAM_ID
               ,PROGRAM_UPDATE_DATE
            )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_FUNC_PARAM_MAP_TAB
                  ,l_msg_name5
                  ,l_msg_text5
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_FN_PARAM_MAP
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
           FROM  EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           WHERE efpmi.parameter_name IS NULL
           OR    efpmi.parameter_id IS NULL
           AND   efpmi.transaction_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                );



           --- update the interface table records to Error
           ---
           UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE efpmi
           SET efpmi.process_status = G_PROCESS_STATUS_ERROR
           WHERE  efpmi.attr_name IS NULL
           OR     efpmi.attr_group_name IS NULL
           OR     efpmi.item_catalog_name IS NULL
           OR     efpmi.attr_id IS NULL
           OR     efpmi.attr_group_id IS NULL
           OR     efpmi.item_catalog_group_ID IS NULL
           OR     efpmi.function_id IS NULL
           OR     efpmi.function_name IS NULL
           OR     efpmi.parameter_id IS NULL
           OR     efpmi.parameter_name IS NULL
           AND   efpmi.transaction_id IS NOT NULL
           AND   efpmi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( efpmi.set_process_id =  G_SET_PROCESS_ID)
                )
              ;

       end if ; -- entity = func params

       /*
          --- Moved to rwo by row processing
          ---
       If p_entity = G_ENTITY_ICC_VERSION THEN
           --- ICC versions table , ICC Name

           UPDATE EGO_ICC_VERS_INTERFACE  eivi
           SET    eivi.item_catalog_name = ( select icc_kfv.concatenated_segments
                                        from   mtl_item_catalog_groups_kfv icc_kfv
                                        where icc_kfv.item_catalog_group_id = eivi.item_catalog_group_id
                                      )
           WHERE eivi.item_catalog_group_id IS NOT NULL
           AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( eivi.set_process_id =  G_SET_PROCESS_ID)
               )
           ;

           write_debug(l_proc_name, 'updated name');

           UPDATE ego_icc_vers_interface eivi
           SET    eivi.item_catalog_group_id = ( select icc_kfv.item_catalog_group_id
                                                  from   mtl_item_catalog_groups_kfv icc_kfv
                                                  where icc_kfv.concatenated_segments = eivi.item_catalog_name
                                                )
           WHERE eivi.item_catalog_name IS NOT NULL
           AND   eivi.item_catalog_group_id IS NULL
           AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                  ( G_SET_PROCESS_ID IS NULL )
                    OR
                  ( eivi.set_process_id =  G_SET_PROCESS_ID)
               )
           ;

           write_debug(l_proc_name, 'updated id');
            --commit;
          --- insert into mtl_interface_errors
          ---

          l_msg_name := 'EGO_ICC_ID_INVALID';
          FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
          l_msg_text := FND_MESSAGE.GET;


          --- Insert errors for ICC Name
          ---
          INSERT INTO MTL_INTERFACE_ERRORS
           (
              TRANSACTION_ID
              ,UNIQUE_ID
              ,ORGANIZATION_ID
              ,COLUMN_NAME
              ,TABLE_NAME
              ,MESSAGE_NAME
              ,ERROR_MESSAGE
              ,BO_IDENTIFIER
              ,ENTITY_IDENTIFIER
              ,LAST_UPDATE_DATE
              ,LAST_UPDATED_BY
              ,CREATION_DATE
              ,CREATED_BY
              ,LAST_UPDATE_LOGIN
              ,REQUEST_ID
              ,PROGRAM_APPLICATION_ID
              ,PROGRAM_ID
              ,PROGRAM_UPDATE_DATE
           )
            SELECT transaction_id
                  ,MTL_SYSTEM_ITEMS_INTERFACE_S.nextval
                  ,null
                  ,null
                  ,G_ENTITY_ICC_VERS_TAB
                  ,l_msg_name
                  ,l_msg_text
                  ,G_BO_IDENTIFIER_ICC
                  ,G_ENTITY_ICC_VERSION
                  ,l_sysdate
                  ,G_USER_ID
                  ,l_sysdate
                  ,G_USER_ID
                  ,G_LOGIN_ID
                  ,G_CONC_REQUEST_ID
                  ,G_PROG_APPL_ID
                  ,G_PROGRAM_ID
                  ,l_sysdate
             FROM  ego_icc_vers_interface eivi
             WHERE ( eivi.item_catalog_group_id IS NULL
                     OR
                     eivi.item_catalog_name IS NULL
                   )
             AND   eivi.transaction_id IS NOT NULL
             AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
             AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( eivi.set_process_id =  G_SET_PROCESS_ID)
                  ) ;

           write_debug(l_proc_name, 'inserted into errors=>'||SQL%ROWCOUNT);

           --- update status flag in ICC interface table

           UPDATE ego_icc_vers_interface eivi
            set process_status = G_PROCESS_STATUS_ERROR
           WHERE ( eivi.item_catalog_group_id IS NULL
                     OR
                     eivi.item_catalog_name IS NULL
                   )
           AND   eivi.transaction_id IS NOT NULL
           AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
           AND  (
                   ( G_SET_PROCESS_ID IS NULL )
                   OR
                   ( eivi.set_process_id =  G_SET_PROCESS_ID)
                )
              ;
           write_debug(l_proc_name, 'updated error to intf rows affected=>'||SQL%ROWCOUNT);


       END IF;  --- versions

       */

    write_debug (l_proc_name, 'End of  '||l_proc_name);

    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
    END Validate_Name_ID_Cols;


    -----------------------------------------------
    --- This procedure , marks the records for processing based on set_process_id passed
    ---   , sets the request_id column
    ---   , also does other bulk validations
    ---
    -----------------------------------------------

    PROCEDURE Bulk_Validate ( p_entity         IN VARCHAR2
                             ,x_return_status  OUT NOCOPY VARCHAR2
                             ,x_return_msg  OUT NOCOPY VARCHAR2
                            )
    IS

      L_proc_name VARCHAR2(30) :=  'Bulk_Validate';
      e_stop_process     EXCEPTION;
      l_sysdate    DATE := SYSDATE;


    BEGIN
      write_debug(l_proc_name,'Start of '||l_proc_name);

      x_return_status := G_RET_STS_SUCCESS;

      ---- update the transction_id in the interace table
      ---- update the transaction_type to UPPER
      ----
      IF p_entity = G_ENTITY_ICC_HEADER THEN


          Validate_Trans_Type (  G_ENTITY_ICC_HEADER, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

          Validate_Entity_Cols ( G_ENTITY_ICC_HEADER, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

          Validate_Name_ID_Cols ( G_ENTITY_ICC_HEADER, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

      END IF;  --- END ICC


      --- AG Assoc
      ----
      IF p_entity = G_ENTITY_ICC_AG_ASSOC THEN

          Validate_Trans_Type (  G_ENTITY_ICC_AG_ASSOC, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

          Validate_Entity_Cols ( G_ENTITY_ICC_AG_ASSOC, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

          Validate_Name_ID_Cols ( G_ENTITY_ICC_AG_ASSOC, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;


      END IF;  -- END  AG Assoc


      --- Func Params
      ----
      IF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN

           Validate_Trans_Type (  G_ENTITY_ICC_FN_PARAM_MAP, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

           Validate_Entity_Cols ( G_ENTITY_ICC_FN_PARAM_MAP, x_return_status ,x_return_msg);
              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

           Validate_Name_ID_Cols ( G_ENTITY_ICC_FN_PARAM_MAP, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;
      END IF;  -- END  Func Params



         --- corresponding TA records have to marked as Error
         ---
      IF p_entity = G_ENTITY_ICC_VERSION THEN


           --- moved to row by row bug 9752139
           ---
           /*
           Validate_Trans_Type (  G_ENTITY_ICC_VERSION, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;
           */

           Validate_Entity_Cols ( G_ENTITY_ICC_VERSION, x_return_status ,x_return_msg);

              IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
                 RETURN;
              END IF;

           --- Moved to row by row , since ICC may not be
           --- processed at the point this is called
           ---
           ---
           ---Validate_Name_ID_Cols ( G_ENTITY_ICC_VERSION, x_return_status ,x_return_msg);
           ---
           ---   IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
           ---      RETURN;
           ---   END IF;
           ---


      END IF;


    write_debug(l_proc_name,'End');
    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
      write_debug( l_proc_name ,x_return_msg);
      RETURN;
    END Bulk_Validate;


/********************************************************************
--- This procedure does thebulk validations as present in Bulk_Validate
--- when the public API for ICC processing is invoked
---
********************************************************************/


    PROCEDURE   Bulk_Validate_For_API (    p_entity         IN varchar2
                                         , p_icc_rec        IN OUT NOCOPY ego_icc_rec_type
                                         , p_ag_assoc_rec   IN OUT NOCOPY ego_ag_assoc_rec_type
                                         , p_func_param_assoc_rec IN OUT NOCOPY ego_func_param_map_rec_type
                                         , x_return_status    OUT NOCOPY VARCHAR2
                                         , x_return_msg  OUT NOCOPY VARCHAR2
                                     )
    IS
      l_proc_name  CONSTANT VARCHAR2(30) := 'Bulk_Validate_For_API';
    BEGIN

      write_debug(l_proc_name,'Start');

      NULL;
      write_debug(l_proc_name,'End');

    EXCEPTION
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
      RETURN;
    END Bulk_Validate_For_API;


   /********************************************************************
    ** Procedure: Check_Catalog_CCID (Unexposed)
    ** Purpose  : Checks the existence of catalog group id
    ** Returns  : TRUE if CCID exists and FALSE if not
    **********************************************************************/


    FUNCTION Check_Catalog_CCID ( p_catalog_grp_id IN NUMBER)
    RETURN BOOLEAN
    IS
      l_ccid NUMBER;
    BEGIN

      SELECT item_catalog_group_id
        INTO l_ccid
      FROM mtl_Item_Catalog_Groups_b
      WHERE  item_catalog_group_id = p_catalog_grp_id;

    Return TRUE;

    EXCEPTION WHEN OTHERS
    THEN
      Return FALSE;
    END Check_Catalog_CCID;


/********************************************************************
---   Function to check if the code passed exists in lookups
---   for given lookup type
---
********************************************************************/


FUNCTION Check_Lookup_value  ( p_code  IN VARCHAR2
                              ,p_lookup IN VARCHAR2
                              )
RETURN boolean
IS

  l_return boolean := false;

  CURSOR cur_lkup
  IS
  SELECT 1
  FROM FND_LOOKUP_VALUES
  WHERE LOOKUP_CODE = p_code
  AND   LOOKUP_TYPE = p_lookup
  AND   LANGUAGE = USERENV('LANG');


  l_proc_name    VARCHAR2(30) := 'Check_Lookup_value';
BEGIN
  write_debug(l_proc_name,'Start');

  FOR rec_lkup IN cur_lkup
  LOOP
    l_return := TRUE;
    write_debug(l_proc_name,' Code =>'||p_code||' exists in lookup=>'||p_lookup);
    EXIT;
  END LOOP;

write_debug(l_proc_name,'End ');
RETURN l_return;

END Check_Lookup_value;


/********************************************************************
--  API Name:       Generate_Seq_For_Item_Catalog
--
--  Description:
--  Generates the Item Sequence For Number Generation
********************************************************************/
PROCEDURE Generate_Seq_For_Item_Catalog (
        p_icc_id                        IN  NUMBER
       ,p_seq_start_num                 IN  NUMBER
       ,p_seq_increment_by              IN  NUMBER
       ,x_seq_name                      OUT nocopy VARCHAR2
       ,x_return_status                 OUT nocopy VARCHAR2
       ,x_return_msg                    OUT NOCOPY VARCHAR2
)IS
    l_proc_name              CONSTANT VARCHAR2(50) := 'Generate_Sequence_For_Item_Catalog';
    l_seq_name               VARCHAR2(100);
    l_ret_seq_name           VARCHAR2(100);
    l_syn_name               VARCHAR2(100);
    l_seq_name_prefix        VARCHAR2(70) ;
    l_syn_name_prefix        CONSTANT VARCHAR2(70) := 'ITEM_NUM_SEQ_';
    l_seq_name_suffix        CONSTANT VARCHAR2(10) := '_S' ;
    l_dyn_sql                VARCHAR2(100);

    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);

BEGIN
    x_return_status := G_RET_STS_SUCCESS;

    IF FND_INSTALLATION.GET_APP_INFO(G_INV_SCHEMA, l_status, l_industry, l_schema) THEN
       IF l_schema IS NULL    THEN
          x_return_msg := 'INV Schema could not be located.';
          write_debug (l_proc_name,x_return_msg );
          x_return_status  :=  G_RET_STS_ERROR;
       END IF;
    ELSE
          x_return_msg := 'INV Schema could not be located.';
          write_debug (l_proc_name,x_return_msg );
          x_return_status  :=  G_RET_STS_ERROR;
    END IF;

    l_seq_name_prefix := l_schema ||'.'||'ITEM_NUM_SEQ_';
    l_ret_seq_name := 'ITEM_NUM_SEQ_'|| p_icc_id || l_seq_name_suffix;
    l_seq_name  := l_seq_name_prefix || p_icc_id || l_seq_name_suffix;
    l_dyn_sql   := 'CREATE SEQUENCE '||l_seq_name||' INCREMENT BY '||p_seq_increment_by||' START WITH '||p_seq_start_num || ' NOCACHE';
    EXECUTE IMMEDIATE l_dyn_sql;
    l_syn_name  := l_syn_name_prefix || p_icc_id || l_seq_name_suffix;
    l_dyn_sql   := 'CREATE SYNONYM '||l_syn_name||' FOR '||l_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;

    x_seq_name := l_ret_seq_name;
EXCEPTION
   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      x_return_msg := G_PKG_NAME||'.'||l_proc_name||' '||SQLERRM;
END Generate_Seq_For_Item_Catalog;

/********************************************************************

--  API Name:       Drop_Sequence_For_Item_Catalog
--
--  Description:
--  Drops the Item Sequence For Number Generation
********************************************************************/

PROCEDURE Drop_Sequence_For_Item_Catalog (
       p_item_catalog_seq_name         IN  VARCHAR2
       ,x_return_status                 OUT NOCOPY VARCHAR2
       ,x_return_msg                    OUT NOCOPY VARCHAR2
       )
IS
    l_proc_name              CONSTANT VARCHAR2(50) := 'Drop_Sequence_For_Item_Catalog';
    l_dyn_sql                VARCHAR2(100);
    l_status                 VARCHAR2(1);
    l_industry               VARCHAR2(1);
    l_schema                 VARCHAR2(30);
BEGIN
    x_return_status := G_RET_STS_SUCCESS;

    IF FND_INSTALLATION.GET_APP_INFO('INV', l_status, l_industry, l_schema) THEN
       IF l_schema IS NULL    THEN
          x_return_msg := 'INV Schema could not be located.';
          write_debug (l_proc_name,x_return_msg );
          x_return_status  :=  G_RET_STS_ERROR;
       END IF;
    ELSE
          x_return_msg := 'INV Schema could not be located.';
          write_debug (l_proc_name,x_return_msg );
          x_return_status  :=  G_RET_STS_ERROR;
    END IF;

    l_dyn_sql   := 'DROP SYNONYM '||p_item_catalog_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
    l_dyn_sql   := 'DROP SEQUENCE '||l_schema||'.'||p_item_catalog_seq_name;
    EXECUTE IMMEDIATE l_dyn_sql;
EXCEPTION
   WHEN others THEN
      x_return_status  :=  G_RET_STS_UNEXP_ERROR;
      x_return_msg := G_PKG_NAME||'.'||l_proc_name||' '||SQLERRM;
END Drop_Sequence_For_Item_Catalog;



/********************************************************************
---
--- This procedure validates the paramter mappings associatiation
--- between function and ICC
---
/********************************************************************/
 PROCEDURE Validate_Func_Param_Mappings    ( p_func_param_assoc_rec IN OUT NOCOPY ego_func_param_map_rec_type
                                            ,x_return_status      OUT NOCOPY VARCHAR2
                                            ,x_return_msg  OUT NOCOPY VARCHAR2
                                           )
IS

  l_proc_name  CONSTANT VARCHAR2(30) := 'Validate_Func_Param_Mappings';
  -- for error logging
  --
  l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_FN_PARAM_MAP;
  l_token_table     ERROR_HANDLER.Token_Tbl_Type;

  l_function_id     ego_func_params_b.function_id%TYPE;
  l_func_param_id   ego_func_params_b.func_param_id%TYPE;
  l_func_params_tbl ego_func_param_map_tbl_type;
  l_object_id       fnd_objects.object_id%TYPE := null;
  l_action_id       ego_actions_b.action_id%TYPE := null;
  l_mapping_found  BOOLEAN := FALSE;


  cursor cur_func_param (  p_param_name  VARCHAR2 default null
                          ,p_param_id    NUMBER default null
                          ,p_function_id NUMBER
                        )
  IS
  select FUNC_PARAM_ID, internal_name
  from   ego_func_params_b efpb
  where  efpb.function_id = p_function_id
  and    efpb.internal_name = nvl(p_param_name, efpb.internal_name)
  and    efpb.func_param_id = nvl(p_param_id ,efpb.func_param_id)
  ;

  CURSOR cur_action_id ( p_function_id number
                        ,p_icc_id      number
                        ,p_object_id   number
                      )
  IS
  SELECT action_id
  FROM   ego_actions_b
  where  function_id = p_function_id
  and    classification_code = to_char(p_icc_id)
  and    object_id     = p_object_id
  ;

  CURSOR cur_chk_mapping ( p_function_id number
                        ,p_icc_id      number
                        ,p_func_param_id   number
                      )
  IS
  SELECT 1
  FROM   ego_mappings_b b
  WHERE  b.function_id = p_function_id
  AND    b.mapped_obj_pk1_val = to_char(p_icc_id)
  AND    b.func_param_id = p_func_param_id
  ;

BEGIN
  write_debug(l_proc_name,'Start');
  x_return_status := G_RET_STS_SUCCESS;


      --- Check if the function is associated to the ICC
      ---
  FOR rec_obj_id IN cur_get_obj_id loop
    l_object_id := rec_obj_id.object_id;
  end loop;

  for rec_action_id_chk IN cur_action_id ( p_function_id => p_func_param_assoc_rec.function_id
                                          ,p_icc_id      => p_func_param_assoc_rec.item_catalog_group_id
                                          ,p_object_id   => l_object_id
                                        )  loop

    l_action_id := rec_action_id_chk.action_id;

  end loop;

  --- If function is not associated to ICC , log error and return
  ---
  IF l_action_id IS NULL THEN

     x_return_status := G_RET_STS_ERROR;
     l_token_table(1).token_name := 'FUNC_NAME';
     l_token_table(1).token_value :=  p_func_param_assoc_rec.function_name;

     l_token_table(2).token_name := 'ICC_NAME';
     l_token_table(2).token_value :=  p_func_param_assoc_rec.item_catalog_name;

     ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_FUNC_NOT_ASSOC_ICC'
       ,p_application_id                => G_APPL_NAME
       ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
       ,p_token_tbl                     => l_token_table
       ,p_entity_code                   => l_entity_code
       ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
     );
     l_token_table.delete;
     p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;
     RETURN;

  END IF;


      /*
      ---
      --- Check if the parameter name or id provided is valid for the function
      ---

      IF p_func_param_assoc_rec.parameter_id IS NOT NULL THEN

        for  rec_param_chk in cur_func_param ( p_param_id =>  p_func_param_assoc_rec.parameter_id
                                              ,p_function_id => p_func_param_assoc_rec.function_id
                                             ) loop
          p_func_param_assoc_rec.parameter_name := rec_param_chk.internal_name;
        end loop;

        IF p_func_param_assoc_rec.parameter_name IS NULL THEN

             x_return_status := G_RET_STS_ERROR;
             l_token_table(1).token_name := 'FUNC_NAME';
             l_token_table(1).token_value :=  p_func_param_assoc_rec.function_name;
             ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ICC_FUNC_PARAM_INVALID'
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
               ,p_token_tbl                     => l_token_table
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
             );
             l_token_table.delete;
             p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;


        END IF;
      ELSIF   p_func_param_assoc_rec.parameter_name IS NOT NULL THEN
        for  rec_param_chk in cur_func_param ( p_param_name =>  p_func_param_assoc_rec.parameter_name
                                              ,p_function_id => p_func_param_assoc_rec.function_id
                                             ) loop
          p_func_param_assoc_rec.parameter_id := rec_param_chk.func_param_id;
        end loop;

        IF p_func_param_assoc_rec.parameter_id IS NULL THEN

             x_return_status := G_RET_STS_ERROR;
             l_token_table(1).token_name := 'FUNC_NAME';
             l_token_table(1).token_value :=  p_func_param_assoc_rec.function_name;
             ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ICC_FUNC_PARAM_INVALID'
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
               ,p_token_tbl                     => l_token_table
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
             );
             l_token_table.delete;
             p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;

        END IF;
      END IF;

      */

       l_mapping_found := FALSE;
       IF  p_func_param_assoc_rec.transaction_type <> G_TTYPE_CREATE THEN
           ---
           --- Check the mapping
           ---
           FOR rec_chk_mapping IN cur_chk_mapping ( p_function_id => p_func_param_assoc_rec.function_id
                                                   ,p_icc_id       => p_func_param_assoc_rec.item_catalog_group_id
                                                   ,p_func_param_id => p_func_param_assoc_rec.parameter_id
                                                  ) LOOP

             l_mapping_found := TRUE;
           END LOOP;
       END IF;

       IF p_func_param_assoc_rec.transaction_type = G_TTYPE_UPDATE AND (NOT l_mapping_found) THEN

           x_return_status := G_RET_STS_ERROR;
           l_token_table(1).token_name := 'PARAM_NAME';
           l_token_table(1).token_value := p_func_param_assoc_rec.parameter_name;
         ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_MAPPING_DOES_NOT_EXIST'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
         );
         l_token_table.DELETE;
         p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;
         RETURN;

       END IF;

      ---- Resolve the SYNC transaction type
      ---- if the paramter being mapped is already associated for the same function , against the ICC
      ---- then it is UPDATE
      ----
      IF p_func_param_assoc_rec.transaction_type = G_TTYPE_SYNC THEN

        IF l_mapping_found THEN
            p_func_param_assoc_rec.transaction_type := G_TTYPE_UPDATE;
        ELSE
            p_func_param_assoc_rec.transaction_type := G_TTYPE_CREATE;
        END IF;

      END IF;



      ---
      --- Checking the UOM Parameter name against the FUNCTION
      ---
      IF p_func_param_assoc_rec.mapped_uom_parameter IS NOT NULL AND p_func_param_assoc_rec.mapped_uom_parameter <> G_MISS_NUM THEN

        for  rec_param_chk in cur_func_param ( p_param_id =>  p_func_param_assoc_rec.mapped_uom_parameter
                                              ,p_function_id => p_func_param_assoc_rec.function_id
                                             )
        loop

          l_func_param_id := rec_param_chk.func_param_id;
          p_func_param_assoc_rec.uom_parameter := rec_param_chk.internal_name;
        end loop;

        IF l_func_param_id IS NULL THEN

             x_return_status := G_RET_STS_ERROR;
             ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ICC_FUNC_UOM_PARAM_INVALID'
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
             );
             p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;

        END IF;

      ELSIF p_func_param_assoc_rec.uom_parameter IS NOT NULL AND p_func_param_assoc_rec.uom_parameter <> G_MISS_CHAR THEN
        for  rec_param_chk in cur_func_param ( p_param_name =>  p_func_param_assoc_rec.uom_parameter
                                              ,p_function_id => p_func_param_assoc_rec.function_id
                                             )
        loop
          l_func_param_id := rec_param_chk.func_param_id;
          p_func_param_assoc_rec.mapped_uom_parameter := l_func_param_id;
        end loop;

        IF l_func_param_id IS NULL THEN

               x_return_status := G_RET_STS_ERROR;
               l_token_table(1).token_name := 'UOM_PARAM';
               l_token_table(1).token_value := p_func_param_assoc_rec.uom_parameter;
             ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ICC_FUNC_UOM_PARAM_INVALID'
               ,p_application_id                => G_APPL_NAME
               ,p_token_tbl                     => l_token_table
               ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
             );
             l_token_table.DELETE;
             p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;

        END IF;
      END IF;

       IF p_func_param_assoc_rec.UOM_PARAM_VALUE_TYPE IS NOT NULL AND p_func_param_assoc_rec.UOM_PARAM_VALUE_TYPE <> G_MISS_CHAR THEN

         IF NOT Check_Lookup_value ( p_code => p_func_param_assoc_rec.UOM_PARAM_VALUE_TYPE
                               ,p_lookup => 'EGO_PARAM_MAP_UOM_SOURCE'
                              ) THEN

               x_return_status := G_RET_STS_ERROR;
               l_token_table(1).token_name := 'COL_NAME';
               l_token_table(1).token_value := 'UOM_PARAM_VALUE_TYPE';

               ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_INVALID_VALUE_FOR_COL'
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
               );
             l_token_table.DELETE;
             p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;

         ELSIF p_func_param_assoc_rec.UOM_PARAM_VALUE_TYPE = 'F' -- fixed
                AND ( p_func_param_assoc_rec.FIXED_UOM_VALUE IS NULL OR p_func_param_assoc_rec.FIXED_UOM_VALUE = G_MISS_CHAR)
                THEN

                 x_return_status := G_RET_STS_ERROR;
                 l_token_table(1).token_name := 'MAPPED_ATTR';
                 l_token_table(1).token_value := p_func_param_assoc_rec.uom_parameter;

                  ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_FIXED_UOM_REQUIRED'
                  ,p_application_id                => G_APPL_NAME

                  ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_FUNC_PARAM_MAP_TAB
                  );
                 p_func_param_assoc_rec.process_status := G_PROCESS_STATUS_ERROR;
         END IF;
       END IF;
  write_debug(l_proc_name,'End ');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Validate_Func_Param_Mappings;


/******************************************
---- Function to check the function name
---- or ID provided against EGO_FUNCTIONS_V
*****************************************/

FUNCTION Check_Function ( p_func_id  IN NUMBER DEFAULT NULL
                         ,p_func_name IN VARCHAR2 DEFAULT NULL
                        )
RETURN NUMBER
IS
  l_temp_id    NUMBER := NULL;
  l_func_id    NUMBER := NULL;
  l_proc_name  VARCHAR2(30) := 'Check_Function';

  CURSOR cur_func
  IS
  SELECT function_id
  FROM ego_functions_v
  where  ( function_id = nvl(p_func_id, function_id)
           AND
           internal_name = nvl(p_func_name, internal_name)
        ) ;

  CURSOR cur_func_check ( p_cur_func_id  NUMBER)
  IS
  SELECT 1
  FROM EGO_FUNC_PARAMS_B
  WHERE function_id = p_cur_func_id
  AND   param_type = 'R'
  AND data_type IN ('O', 'N', 'V', 'I', 'L', 'S')
  ;


BEGIN

  for rec_func IN cur_func
  loop
      l_temp_id := rec_func.function_id;
  end loop;

  write_debug(l_proc_name, 'l_temp_id =>'||l_temp_id);

  ---
  --- Function should have a return value for it to be associated to the ICC
  --- number generation and desc generation
  for rec_func_check_func IN cur_func_check ( l_temp_id)
  LOOP
    l_func_id := l_temp_id;
  END LOOP;
 write_debug(l_proc_name, 'l_func_id =>'||l_func_id);

  return l_func_id;
EXCEPTION
WHEN OTHERS THEN
  return null;
END ;


/********************************************************************
---   This procedure accepts a icc intf. record type , does value to id
---   conversion and other validations for function related columns
---   bug 9737833
********************************************************************/
PROCEDURE Validate_YesNo_Cols ( p_icc_rec       IN OUT NOCOPY ego_icc_rec_type
                               ,x_return_status OUT NOCOPY VARCHAR2
                               ,x_return_msg    OUT NOCOPY VARCHAR2
                              )
IS
  l_proc_name  CONSTANT VARCHAR2(30) := 'Validate_YesNo_Cols';
  -- for error logging
  --
  l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_HEADER;
  l_token_table     ERROR_HANDLER.Token_Tbl_Type;

  l_return_msg      VARCHAR2(4000);
  l_return_status   VARCHAR2(1);



BEGIN
  write_debug(l_proc_name,'Start');
  X_return_status := G_RET_STS_SUCCESS;


  IF p_icc_rec.enabled_flag IS NOT NULL
        AND p_icc_rec.enabled_flag <> G_MISS_CHAR THEN

    IF p_icc_rec.enabled_flag NOT IN ( 'Y', 'N') THEN

           x_return_status := G_RET_STS_ERROR;
           l_token_table(1).token_name := 'COL_NAME';
           l_token_table(1).token_value := 'ENABLED_FLAG';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_INVALID_VALUE_FOR_COL'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
         );
         l_token_table.DELETE;
           write_debug(l_proc_name, 'Err_Msg-TID='
                   ||p_icc_rec.transaction_id||'-(ICC)=('
                   ||p_icc_rec.item_catalog_name
                   ||') invalid value for col ENABLED_FLAG'
                 );


    END IF;
  END IF;

  IF p_icc_rec.ITEM_CREATION_ALLOWED_FLAG IS NOT NULL
        AND p_icc_rec.ITEM_CREATION_ALLOWED_FLAG <> G_MISS_CHAR THEN

    IF p_icc_rec.ITEM_CREATION_ALLOWED_FLAG NOT IN ( 'Y', 'N') THEN

           x_return_status := G_RET_STS_ERROR;
           l_token_table(1).token_name := 'COL_NAME';
           l_token_table(1).token_value := 'ITEM_CREATION_ALLOWED_FLAG';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_INVALID_VALUE_FOR_COL'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
         );
         l_token_table.DELETE;
           write_debug(l_proc_name, 'Err_Msg-TID='
                   ||p_icc_rec.transaction_id||'-(ICC)=('
                   ||p_icc_rec.item_catalog_name
                   ||') invalid value for col ITEM_CREATION_ALLOWED_FLAG'
                 );


    END IF;
  END IF;


  IF p_icc_rec.ENABLE_KEY_ATTRS_DESC IS NOT NULL
        AND p_icc_rec.ENABLE_KEY_ATTRS_DESC <> G_MISS_CHAR THEN

    IF p_icc_rec.ENABLE_KEY_ATTRS_DESC NOT IN ( 'Y', 'N') THEN

           x_return_status := G_RET_STS_ERROR;
           l_token_table(1).token_name := 'COL_NAME';
           l_token_table(1).token_value := 'ENABLE_KEY_ATTRS_DESC';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_INVALID_VALUE_FOR_COL'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
         );
         l_token_table.DELETE;
         write_debug(l_proc_name, 'Err_Msg-TID='
               ||p_icc_rec.transaction_id||'-(ICC)=('
               ||p_icc_rec.item_catalog_name
               ||') invalid value for col ENABLE_KEY_ATTRS_DESC'
             );

    END IF;
  END IF;

  IF p_icc_rec.ENABLE_KEY_ATTRS_NUM IS NOT NULL
        AND p_icc_rec.ENABLE_KEY_ATTRS_NUM <> G_MISS_CHAR THEN

    IF p_icc_rec.ENABLE_KEY_ATTRS_NUM NOT IN ( 'Y', 'N') THEN

           x_return_status := G_RET_STS_ERROR;
           l_token_table(1).token_name := 'COL_NAME';
           l_token_table(1).token_value := 'ENABLE_KEY_ATTRS_NUM';

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_INVALID_VALUE_FOR_COL'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
         );
         l_token_table.DELETE;
         write_debug(l_proc_name, 'Err_Msg-TID='
               ||p_icc_rec.transaction_id||'-(ICC)=('
               ||p_icc_rec.item_catalog_name
               ||') invalid value for col ENABLE_KEY_ATTRS_NUM'
             );

    END IF;
  END IF;

  write_debug(l_proc_name,'End');

EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Validate_YesNo_Cols;




/********************************************************************
---   This procedure accepts a icc intf. record type , does value to id
---   conversion and other validations for function related columns
---
********************************************************************/

PROCEDURE Validate_Func_Related_Cols ( p_icc_rec       IN OUT NOCOPY ego_icc_rec_type
                                      ,x_return_status OUT NOCOPY VARCHAR2
                                      ,x_return_msg    OUT NOCOPY VARCHAR2
                                     )
IS
  l_proc_name  CONSTANT VARCHAR2(30) := 'Validate_Func_Related_Cols';
  -- for error logging
  --
  l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_HEADER;
  l_token_table     ERROR_HANDLER.Token_Tbl_Type;

  l_function_id     NUMBER := NULL;
  l_func_params_tbl ego_func_param_map_tbl_type;

  l_return_msg      VARCHAR2(4000);
  l_return_status   VARCHAR2(1);
  l_seq_name        VARCHAR2(30);


BEGIN
  write_debug(l_proc_name,'Start');
  X_return_status := G_RET_STS_SUCCESS;

  --- number generation method type
  ---
 IF p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE IS NOT NULL
             AND p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE <> G_MISS_CHAR THEN

    IF NOT Check_Lookup_value ( p_code => p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE , p_lookup => 'EGO_ITEM_NUM_GEN_METHOD') THEN

           x_return_status := G_RET_STS_ERROR;   -- added bug 9737833
           l_token_table(1).token_name := 'ITEM_NUM_GEN_METHOD_TYPE';
           l_token_table(1).token_value := p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_FUNC_TYPECODE_INVALID'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
         );
         l_token_table.DELETE;

    END IF;


    if p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE = 'U' THEN
           --- null out the other columns
           ---
           p_icc_rec.prefix := G_MISS_CHAR;
           p_icc_rec.starting_number := G_MISS_NUM;
           p_icc_rec.suffix := G_MISS_CHAR;
           p_icc_rec.increment_by :=   G_MISS_NUM;
           p_icc_rec.item_num_action_id := G_MISS_NUM;

    ELSIF  p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE = 'S' THEN
          --- starting number and increment should be provided
          ---
          p_icc_rec.item_num_action_id := g_miss_num;

          IF (p_icc_rec.starting_number IS NULL OR p_icc_rec.starting_number = G_MISS_NUM )
              OR
             (p_icc_rec.increment_by IS NULL OR p_icc_rec.increment_by = G_MISS_NUM) THEN
              x_return_status := G_RET_STS_ERROR;

             ERROR_HANDLER.Add_Error_Message(
               p_message_name                  => 'EGO_ITEM_NUM_FN_COLS_INVALID'
              ,p_application_id                => G_APPL_NAME

              ,p_row_identifier                => p_icc_rec.transaction_id
              ,p_entity_code                   => l_entity_code
              ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
            );
          ELSE /* addd below condition bug 9737368 */

            IF  p_icc_rec.starting_number <=0 OR
                p_icc_rec.increment_by <= 0 THEN

                  x_return_status := G_RET_STS_ERROR;

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_ITEM_NUM_FN_COLS_INVALID'
                  ,p_application_id                => G_APPL_NAME
                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_INPUT_NUMBERS_ONLY'
                  ,p_application_id                => G_APPL_NAME
                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );

           END IF;

          END if;





    ELSIF  p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE = 'F' THEN

           --- null out the other columns
           ---
           p_icc_rec.prefix := G_MISS_CHAR;
           p_icc_rec.starting_number := g_miss_num;
           p_icc_rec.suffix := g_miss_char;
           p_icc_rec.increment_by :=   g_miss_num;
           p_icc_rec.item_num_action_id := g_miss_num;
           p_icc_rec.item_num_seq_name := g_miss_char;

           l_function_id := null;
           -- validate function id

           --- if none of function_id or name provided then Error
           ---
           if p_icc_rec.ITEM_NUM_FUNCTION_ID IS  NULL AND p_icc_rec.ITEM_NUM_GENERATION_FUNCTION IS  NULL then
                 x_return_status := G_RET_STS_ERROR;

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_ITEM_NUM_FUNC_INVALID'
                  ,p_application_id                => G_APPL_NAME

                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );

           --- Validate the id
           ---
           ELSIF p_icc_rec.ITEM_NUM_FUNCTION_ID IS NOT NULL AND p_icc_rec.ITEM_NUM_FUNCTION_ID <> G_MISS_NUM THEN

              l_function_id :=  Check_Function ( p_func_id => p_icc_rec.ITEM_NUM_FUNCTION_ID );
              write_debug ( l_proc_name, ' function id =>'||l_function_id);

              IF l_function_id IS NULL THEN

                 x_return_status := G_RET_STS_ERROR;

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_ITEM_NUM_FUNC_INVALID'
                  ,p_application_id                => G_APPL_NAME

                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );

              end if;

           --- validate the name
           ---
           ELSIF p_icc_rec.ITEM_NUM_GENERATION_FUNCTION IS NOT NULL AND p_icc_rec.ITEM_NUM_GENERATION_FUNCTION <> G_MISS_CHAR
              AND p_icc_rec.ITEM_NUM_FUNCTION_ID IS NULL THEN

                write_debug ( l_proc_name, ' func name =>'||p_icc_rec.ITEM_NUM_GENERATION_FUNCTION);
                l_function_id := Check_Function ( p_func_name => p_icc_rec.ITEM_NUM_GENERATION_FUNCTION );
                write_debug ( l_proc_name, ' function id from func name =>'||NVL(l_function_id, -999));
                IF l_function_id IS NULL THEN

                   x_return_status := G_RET_STS_ERROR;

                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_ITEM_NUM_FUNC_INVALID'
                    ,p_application_id                => G_APPL_NAME
                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                 else
                   p_icc_rec.ITEM_NUM_FUNCTION_ID := l_function_id;
                end if;
           ELSE
             NULL;
           end if;

    ---
    --- Added below condition bug 9737144
    ---
    ELSIF p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE = 'I' THEN

          IF p_icc_rec.transaction_type = G_TTYPE_CREATE
              AND p_icc_rec.parent_catalog_group_id IS NULL
              OR p_icc_rec.parent_catalog_group_id = G_MISS_NUM THEN

                  x_return_status := G_RET_STS_ERROR;

                  l_token_table(1).token_name := 'ICC_NAME';
                  l_token_table(1).token_value := p_icc_rec.item_catalog_name;

                  l_token_table(2).token_name := 'COL_NAME';
                  l_token_table(2).token_value := 'ITEM_NUM_GEN_METHOD_TYPE';


                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_INVALID_VAL_PARENT_MISSING'
                    ,p_application_id                => G_APPL_NAME
                    ,p_token_tbl                     => l_token_table
                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                  l_token_table.delete;


           ELSIF p_icc_rec.transaction_type = G_TTYPE_UPDATE
                AND ( p_icc_rec.parent_catalog_group_id = G_MISS_NUM         --- trying to NULL out the parent
                      OR
                      ( p_icc_rec.parent_catalog_group_id IS NULL            --- parent ICC already exists check
                        AND
                        g_old_icc_rec.parent_catalog_group_id IS NULL
                      )
                    )  THEN

                    x_return_status := G_RET_STS_ERROR;

                  l_token_table(1).token_name := 'ICC_NAME';
                  l_token_table(1).token_value := p_icc_rec.item_catalog_name;

                  l_token_table(2).token_name := 'COL_NAME';
                  l_token_table(2).token_value := 'ITEM_NUM_GEN_METHOD_TYPE';


                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_INVALID_VAL_PARENT_MISSING'
                    ,p_application_id                => G_APPL_NAME
                    ,p_token_tbl                     => l_token_table
                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                  l_token_table.delete;
             END IF;

    END IF;  --- method Type
  END IF;   --- ITEM_NUM_GEN_METHOD_TYPE

  write_debug(l_proc_name,'Start Descriptin function validation');

  --- Description Generation method validation
  ---
  IF p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE IS NOT NULL AND p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE <> G_MISS_CHAR THEN

    IF NOT Check_Lookup_Value ( p_code => p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE , p_lookup => 'EGO_ITEM_DESC_GEN_METHOD' )    THEN

             x_return_status := G_RET_STS_ERROR;

             l_token_table(1).token_name := 'ITEM_DESC_GEN_METHOD_TYPE';
             l_token_table(1).token_value := p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE;

            ERROR_HANDLER.Add_Error_Message(
              p_message_name                  => 'EGO_FUNC_TYPECODE_INVALID'
             ,p_application_id                => G_APPL_NAME
             ,p_token_tbl                     => l_token_table

             ,p_row_identifier                => p_icc_rec.transaction_id
             ,p_entity_code                   => l_entity_code
             ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
           );
           l_token_table.DELETE;
    END IF;

    IF p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE = 'U' THEN

      p_icc_rec.ITEM_DESC_ACTION_ID := G_MISS_NUM;

    ELSIF p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE = 'F' THEN

           --- if none of function_id or name provided then Error
           ---
           l_function_id := NULL;
           IF p_icc_rec.ITEM_DESC_FUNCTION_ID IS  NULL AND p_icc_rec.ITEM_desc_GENERATION_FUNCTION IS  NULL then
                 x_return_status := G_RET_STS_ERROR;

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_ITEM_DESC_FUNC_INVALID'
                  ,p_application_id                => G_APPL_NAME

                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );


           --- Validate the id
           ---
           ELSIF p_icc_rec.ITEM_DESC_FUNCTION_ID IS NOT NULL AND p_icc_rec.ITEM_DESC_FUNCTION_ID <> G_MISS_NUM THEN

              l_function_id :=  Check_Function ( p_func_id => p_icc_rec.ITEM_DESC_FUNCTION_ID );
              IF l_function_id IS NULL THEN

                 x_return_status := G_RET_STS_ERROR;

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_ITEM_DESC_FUNC_INVALID'
                  ,p_application_id                => G_APPL_NAME

                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );

                p_icc_rec.ITEM_DESC_FUNCTION_ID := G_MISS_NUM;
              end if;

           --- validate the name
           ---
           ELSIF p_icc_rec.ITEM_DESC_GENERATION_FUNCTION IS NOT NULL AND p_icc_rec.ITEM_desc_GENERATION_FUNCTION <> G_MISS_CHAR
              AND p_icc_rec.ITEM_DESC_FUNCTION_ID IS NULL THEN

                l_function_id := Check_Function ( p_func_name => p_icc_rec.ITEM_desc_GENERATION_FUNCTION );
                IF l_function_id IS NULL THEN

                   x_return_status := G_RET_STS_ERROR;

                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_ITEM_NUM_FUNC_INVALID'
                    ,p_application_id                => G_APPL_NAME

                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                 else
                   p_icc_rec.ITEM_DESC_FUNCTION_ID := l_function_id;
                end if;
           else
             null;
           end if;

    ---
    --- Added below condition bug 9737144
    ---
    ELSIF p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE = 'I' THEN

          IF p_icc_rec.transaction_type = G_TTYPE_CREATE
              AND p_icc_rec.parent_catalog_group_id IS NULL
              OR p_icc_rec.parent_catalog_group_id = G_MISS_NUM THEN

                  x_return_status := G_RET_STS_ERROR;

                  l_token_table(1).token_name := 'ICC_NAME';
                  l_token_table(1).token_value := p_icc_rec.item_catalog_name;

                  l_token_table(2).token_name := 'COL_NAME';
                  l_token_table(2).token_value := 'ITEM_DESC_GEN_METHOD_TYPE';


                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_INVALID_VAL_PARENT_MISSING'
                    ,p_application_id                => G_APPL_NAME
                    ,p_token_tbl                     => l_token_table
                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                  l_token_table.delete;


           ELSIF p_icc_rec.transaction_type = G_TTYPE_UPDATE
                AND ( p_icc_rec.parent_catalog_group_id = G_MISS_NUM         --- trying to NULL out the parent
                      OR
                      ( p_icc_rec.parent_catalog_group_id IS NULL            --- parent ICC already exists check
                        AND
                        g_old_icc_rec.parent_catalog_group_id IS NULL
                      )
                    )  THEN

                    x_return_status := G_RET_STS_ERROR;

                  l_token_table(1).token_name := 'ICC_NAME';
                  l_token_table(1).token_value := p_icc_rec.item_catalog_name;

                  l_token_table(2).token_name := 'COL_NAME';
                  l_token_table(2).token_value := 'ITEM_DESC_GEN_METHOD_TYPE';


                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_INVALID_VAL_PARENT_MISSING'
                    ,p_application_id                => G_APPL_NAME
                    ,p_token_tbl                     => l_token_table
                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                  l_token_table.delete;
             END IF;

    END IF; --- method type

  END IF;   --- p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE IS NOT NULL

  write_debug(l_proc_name,'End');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Validate_Func_Related_Cols;


/********************************************************************
---   This procedure accepts a record type , validates the NIR related
---   columns of the ICC
---
********************************************************************/

PROCEDURE validate_NIR_Columns   ( p_icc_rec        IN OUT NOCOPY ego_icc_rec_type
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                 )
IS
  l_proc_name  CONSTANT VARCHAR2(30) := 'validate_NIR_Columns';
  -- for error logging
  --
  l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_HEADER;
  l_token_table     ERROR_HANDLER.Token_Tbl_Type;

  l_change_order_type ENG_CHANGE_ORDER_TYPES.change_order_type%TYPE := null;
  l_change_type_id   NUMBER := NULL;

   FUNCTION Check_Change_OrderType ( p_change_order_type_id  IN NUMBER DEFAULT NULL
                                   ,p_change_order_type_name IN VARCHAR2 DEFAULT NULL
                                  )
   RETURN NUMBER
   IS
     l_cotype_id    NUMBER := NULL;

     CURSOR cur_cotype
     IS
     SELECT change_order_type_id
     FROM eng_change_order_types_vl
     where (  change_order_type_id = nvl(p_change_order_type_id, change_order_type_id)
              AND
              change_order_type = nvl(p_change_order_type_name, change_order_type)
           )
     ;
   BEGIN

     for rec_cotype IN cur_cotype
     loop
         l_cotype_id := rec_cotype.change_order_type_id;

     end loop;

     RETURN l_cotype_id;

  END Check_Change_OrderType;

BEGIN
    write_debug(l_proc_name,'Start');
    x_return_status := G_RET_STS_SUCCESS;

    IF p_icc_rec.NEW_ITEM_REQUEST_TYPE is not null and p_icc_rec.NEW_ITEM_REQUEST_TYPE <> G_MISS_CHAR THEN

        IF NOT Check_Lookup_value ( p_code => p_icc_rec.NEW_ITEM_REQUEST_TYPE , p_lookup => 'EGO_NIR_SETUP_CHOICE_LIST') THEN

               x_return_status := G_RET_STS_ERROR;
               l_token_table(1).token_name := 'NIR_TYPE';
               l_token_table(1).token_value := p_icc_rec.NEW_ITEM_REQUEST_TYPE;

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ICC_NIR_TYPE_INVALID'
               ,p_application_id                => G_APPL_NAME
               ,p_token_tbl                     => l_token_table
               ,p_row_identifier                => p_icc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
             );
             l_token_table.DELETE;

        END IF;

    END IF;

    IF p_icc_rec.NEW_ITEM_REQUEST_TYPE = 'Y' THEN -- specify for category

      l_change_type_id := NULL;
      IF p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID IS NOT NULL
               AND p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID  <> G_MISS_NUM THEN

          l_change_type_id :=  Check_Change_OrderType ( p_change_order_type_id => p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID );

          IF l_change_type_id IS NULL THEN
                  x_return_status := G_RET_STS_ERROR;
                  l_token_table(1).token_name := 'VALUE';
                  l_token_table(1).token_value := p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID;

                 ERROR_HANDLER.Add_Error_Message(
                   p_message_name                  => 'EGO_CHGTYPE_DOESNOT_EXIST'
                  ,p_application_id                => G_APPL_NAME
                  ,p_token_tbl                     => l_token_table
                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );
                l_token_table.delete;
                p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID := NULL;
          END IF;

      ELSIF p_icc_rec.NEW_ITEM_REQUEST_NAME IS NOT NULL
             AND p_icc_rec.NEW_ITEM_REQUEST_NAME <> G_MISS_CHAR THEN

            l_change_type_id := Check_Change_OrderType ( p_change_order_type_name => p_icc_rec.NEW_ITEM_REQUEST_NAME);

            IF l_change_type_id IS NULL THEN
                    x_return_status := G_RET_STS_ERROR;
                    l_token_table(1).token_name := 'VALUE';
                    l_token_table(1).token_value := p_icc_rec.NEW_ITEM_REQUEST_NAME;

                   ERROR_HANDLER.Add_Error_Message(
                     p_message_name                  => 'EGO_CHGTYPE_DOESNOT_EXIST'
                    ,p_application_id                => G_APPL_NAME
                    ,p_token_tbl                     => l_token_table
                    ,p_row_identifier                => p_icc_rec.transaction_id
                    ,p_entity_code                   => l_entity_code
                    ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                  );
                  l_token_table.delete;
                  p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID := NULL;
             ELSE
               p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID := l_change_type_id;
            end IF;
      ELSIF p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID  <> G_MISS_NUM OR p_icc_rec.NEW_ITEM_REQUEST_NAME <> G_MISS_CHAR THEN

                x_return_status := G_RET_STS_ERROR;
                l_token_table(1).token_name := 'VALUE';
                l_token_table(1).token_value := p_icc_rec.NEW_ITEM_REQUEST_NAME;

               ERROR_HANDLER.Add_Error_Message(
                 p_message_name                  => 'EGO_CHGTYPE_DOESNOT_EXIST'
                ,p_application_id                => G_APPL_NAME
                ,p_token_tbl                     => l_token_table
                ,p_row_identifier                => p_icc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
              );
              l_token_table.delete;
      END IF;

    ---
    --- Added below condition bug 9737144
    ---
    ELSIF p_icc_rec.NEW_ITEM_REQUEST_TYPE = 'I' THEN

      IF p_icc_rec.transaction_type = G_TTYPE_CREATE
          AND p_icc_rec.parent_catalog_group_id IS NULL
          OR p_icc_rec.parent_catalog_group_id = G_MISS_NUM THEN

              x_return_status := G_RET_STS_ERROR;

              l_token_table(1).token_name := 'ICC_NAME';
              l_token_table(1).token_value := p_icc_rec.item_catalog_name;

              l_token_table(2).token_name := 'COL_NAME';
              l_token_table(2).token_value := 'NEW_ITEM_REQUEST_TYPE';


               ERROR_HANDLER.Add_Error_Message(
                 p_message_name                  => 'EGO_INVALID_VAL_PARENT_MISSING'
                ,p_application_id                => G_APPL_NAME
                ,p_token_tbl                     => l_token_table
                ,p_row_identifier                => p_icc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
              );
              l_token_table.delete;


      ELSIF p_icc_rec.transaction_type = G_TTYPE_UPDATE
            AND ( p_icc_rec.parent_catalog_group_id = G_MISS_NUM         --- trying to NULL out the parent
                  OR
                  ( p_icc_rec.parent_catalog_group_id IS NULL            --- parent ICC already exists check
                    AND
                    g_old_icc_rec.parent_catalog_group_id IS NULL
                  )
                )  THEN

                x_return_status := G_RET_STS_ERROR;

              l_token_table(1).token_name := 'ICC_NAME';
              l_token_table(1).token_value := p_icc_rec.item_catalog_name;

              l_token_table(2).token_name := 'COL_NAME';
              l_token_table(2).token_value := 'NEW_ITEM_REQUEST_TYPE';


               ERROR_HANDLER.Add_Error_Message(
                 p_message_name                  => 'EGO_INVALID_VAL_PARENT_MISSING'
                ,p_application_id                => G_APPL_NAME
                ,p_token_tbl                     => l_token_table
                ,p_row_identifier                => p_icc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
              );
              l_token_table.delete;

      END IF;


    ELSIF p_icc_rec.NEW_ITEM_REQUEST_TYPE = 'N' OR p_icc_rec.NEW_ITEM_REQUEST_TYPE = G_MISS_CHAR THEN
      p_icc_rec.NEW_ITEM_REQ_CHANGE_TYPE_ID := NULL;
    END IF;

  write_debug(l_proc_name,'End');
EXCEPTION
WHEN OTHERS THEN
    x_return_status := G_RET_STS_UNEXP_ERROR;
END validate_NIR_Columns;


 /********************************************************************
 --- gets the details for the earlier ICC
 --- for UPDATE transaction
 ********************************************************************/

 PROCEDURE Fetch_Old_ICC_Dtls  ( p_old_icc_rec   IN OUT NOCOPY mtl_item_catalog_groups_b%ROWTYPE
                                ,p_icc_id        IN NUMBER
                               )
 IS

   l_proc_name   VARCHAR2(30) := 'Fetch_Old_ICC_Dtls';
 BEGIN
   write_debug(l_proc_name,'Start');

   SELECT *
   INTO p_old_icc_rec
   FROM mtl_item_catalog_groups_b
   WHERE item_catalog_group_id = p_icc_id;

   write_debug(l_proc_name,'End');
 END Fetch_Old_ICC_Dtls;

/********************************************************************
---   This procedure accepts a record type , defaults values for CREATE
---   transaction
********************************************************************/
    PROCEDURE Attribute_Defaulting  (    p_entity         IN varchar2
                                        , p_icc_rec        IN OUT NOCOPY ego_icc_rec_type
                                        , p_ag_assoc_rec   IN OUT NOCOPY ego_ag_assoc_rec_type
                                        , p_func_param_assoc_rec IN OUT NOCOPY ego_func_param_map_rec_type
                                        , p_icc_ver_rec    IN OUT NOCOPY ego_icc_vers_rec_type
                                        , x_return_status    OUT NOCOPY VARCHAR2
                                        , x_return_msg  OUT NOCOPY VARCHAR2
                                     )
    IS
     l_proc_name  CONSTANT VARCHAR2(30) := 'Attribute_Defaulting';
     l_null_icc_rec_type EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type := null ;
     l_Mesg_Token_tbl  Error_Handler.Mesg_Token_Tbl_Type;


     -- for error logging
     --
     l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_HEADER;
     l_token_table     ERROR_HANDLER.Token_Tbl_Type;



     BEGIN
       write_debug(l_proc_name,'Start');
       x_return_status := G_RET_STS_SUCCESS;

        IF p_entity = G_ENTITY_ICC_HEADER then

            --- defaulting of other columns takes place in the EGO_ITEM_CATALOG_PUB API
            ---
            IF (p_icc_rec.Item_Creation_Allowed_Flag = G_MISS_CHAR  OR p_icc_rec.Item_Creation_Allowed_Flag IS NULL ) then
                p_icc_rec.Item_Creation_Allowed_Flag := 'N';
            END IF;


             IF fnd_flex_keyval.summary_flag THEN
               p_icc_rec.summary_flag := 'Y';
             ELSE
               p_icc_rec.summary_flag := 'N';
             END IF;


            IF (p_icc_rec.enabled_flag = G_MISS_CHAR  OR p_icc_rec.enabled_flag IS NULL ) then
                p_icc_rec.enabled_flag := 'Y';
            END IF;


            IF p_icc_rec.item_num_action_id = G_MISS_NUM THEN
              p_icc_rec.item_num_action_id := null;
            END IF;

            IF p_icc_rec.item_desc_action_id = G_MISS_NUM THEN
              p_icc_rec.item_desc_action_id := null;
            END IF;

            IF p_icc_rec.item_num_seq_name = G_MISS_CHAR THEN
              p_icc_rec.item_num_seq_name :=  null;
            END IF;

            --- Bug 9737204
            IF p_icc_rec.prefix = G_MISS_CHAR THEN
                p_icc_rec.prefix := NULL;
            END IF;

            IF p_icc_rec.starting_number = G_MISS_NUM  THEN
              p_icc_rec.starting_number := NULL;
            END IF;

            IF p_icc_rec.suffix = G_MISS_CHAR then
              p_icc_rec.suffix := NULL;
            END IF;

            IF p_icc_rec.increment_by = G_MISS_NUM THEN
              p_icc_rec.increment_by := NULL;
            END IF;

            -- bug 9737204  end


            IF p_icc_rec.parent_catalog_group_id IS NULL THEN

                IF (p_icc_rec.item_desc_gen_method_type = G_MISS_CHAR  OR p_icc_rec.item_desc_gen_method_type IS NULL ) then
                    p_icc_rec.item_desc_gen_method_type := 'U';  -- User defined
                END IF;

                IF (p_icc_rec.item_num_gen_method_type = G_MISS_CHAR  OR p_icc_rec.item_num_gen_method_type IS NULL ) then
                    p_icc_rec.item_num_gen_method_type := 'U';  -- User defined
                END IF;

                IF (p_icc_rec.new_item_request_type = G_MISS_CHAR  OR p_icc_rec.new_item_request_type IS NULL ) then
                    p_icc_rec.new_item_request_type := 'N';
                END IF;

            ELSE
                IF (p_icc_rec.item_desc_gen_method_type = G_MISS_CHAR  OR p_icc_rec.item_desc_gen_method_type IS NULL ) then
                     p_icc_rec.item_desc_gen_method_type := 'I';  -- Inherit from Parent
                END IF;

                IF (p_icc_rec.item_num_gen_method_type = G_MISS_CHAR  OR p_icc_rec.item_num_gen_method_type IS NULL ) then
                     p_icc_rec.item_num_gen_method_type := 'I';   -- Inherit from Parent
                END IF;

                IF (p_icc_rec.new_item_request_type = G_MISS_CHAR  OR p_icc_rec.new_item_request_type IS NULL ) then
                    p_icc_rec.new_item_request_type := 'I';  --- Inherit from parent
                END IF;

            END IF;

        IF p_icc_rec.enable_key_attrs_num is null or p_icc_rec.enable_key_attrs_num = G_MISS_CHAR  THEN
          p_icc_rec.enable_key_attrs_num := 'N';
        END IF;


        IF p_icc_rec.enable_key_attrs_desc is null or p_icc_rec.enable_key_attrs_desc = G_MISS_CHAR  THEN
          p_icc_rec.enable_key_attrs_desc := 'N';
        END IF;

        IF p_icc_rec.new_item_request_type = G_MISS_CHAR THEN
          p_icc_rec.new_item_request_type := 'N';
        END IF;

        IF p_icc_rec.new_item_req_change_type_id = G_MISS_NUM THEN
          p_icc_rec.new_item_request_type := NULL;
        END IF;


        ELSIF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN

            --- Default Func param columns
            --- no columns as of now
            NULL;

        ELSIF p_entity = G_ENTITY_ICC_AG_ASSOC THEN

            --- Default AG association cols
            --- no columns as of now
            NULL;

        ELSIF p_entity = G_ENTITY_ICC_VERSION THEN

            --- Default Version specific information
            ---no columns as of now
            null;

        END IF; --- ICC Header


       write_debug(l_proc_name,'End');
     EXCEPTION
     WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
     end   Attribute_Defaulting;




/********************************************************************
--- This procedure will look at the columns that the user
--- has not filled in and will assign those columns a
--- value from the database record.
--- This procedure is not called for CREATE
********************************************************************/
    PROCEDURE Populate_Null_Cols   (   p_entity         IN varchar2
                                     , p_icc_rec        IN OUT NOCOPY ego_icc_rec_type
                                     , p_ag_assoc_rec   IN OUT NOCOPY ego_ag_assoc_rec_type
                                     , p_func_param_assoc_rec IN OUT NOCOPY ego_func_param_map_rec_type
                                     , x_return_status    OUT NOCOPY VARCHAR2
                                     , x_return_msg  OUT NOCOPY VARCHAR2
                                    )
    IS
     l_proc_name  CONSTANT VARCHAR2(30) := 'Populate_Null_Cols';

     l_null_icc_rec_type EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type := null ;
     l_Mesg_Token_tbl  Error_Handler.Mesg_Token_Tbl_Type;


     -- for error logging
     --
     l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_HEADER;
     l_token_table     ERROR_HANDLER.Token_Tbl_Type;


     BEGIN
       write_debug(l_proc_name,'Start');
       x_return_status := G_RET_STS_SUCCESS;

        IF p_entity = G_ENTITY_ICC_HEADER THEN

            --- ************************
            --- Populate the old values
            --- ************************

            IF p_icc_rec.prefix IS NULL THEN
                    p_icc_rec.prefix :=  g_old_icc_rec.prefix;
            END IF;

            IF  p_icc_rec.starting_number IS NULL THEN
                    p_icc_rec.starting_number :=  g_old_icc_rec.starting_number;
            END IF;


            IF  p_icc_rec.increment_by IS NULL THEN
                    p_icc_rec.increment_by :=  g_old_icc_rec.increment_by;
            END IF;

            IF p_icc_rec.suffix IS NULL THEN
                    p_icc_rec.suffix :=  g_old_icc_rec.suffix;
            END IF;

            IF p_icc_rec.item_num_seq_name IS NULL THEN
                    p_icc_rec.item_num_seq_name :=  g_old_icc_rec.item_num_seq_name;
            END IF;

            IF p_icc_rec.item_num_action_id IS NULL THEN
                    p_icc_rec.item_num_action_id :=  g_old_icc_rec.item_num_action_id;
            END IF;


            IF p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE IS NULL THEN
                    p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE :=  g_old_icc_rec.ITEM_NUM_GEN_METHOD;
            END IF;


            IF p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE IS NULL THEN
                    p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE :=  g_old_icc_rec.ITEM_DESC_GEN_METHOD;
            END IF;

            IF  p_icc_rec.item_desc_action_id IS NULL THEN
                    p_icc_rec.item_desc_action_id :=  g_old_icc_rec.item_desc_action_id;
            END IF;


            IF p_icc_rec.new_item_req_change_type_id IS NULL THEN
                    p_icc_rec.new_item_req_change_type_id :=  g_old_icc_rec.new_item_req_change_type_id;
            END IF;

            IF  p_icc_rec.new_item_request_type IS NULL THEN
                    p_icc_rec.new_item_request_type :=  g_old_icc_rec.NEW_ITEM_REQUEST_REQD;
            END IF;

            IF p_icc_rec.enable_key_attrs_num IS NULL  THEN
              p_icc_rec.enable_key_attrs_num := 'N';
            END IF;

            IF p_icc_rec.enable_key_attrs_desc IS NULL  THEN
              p_icc_rec.enable_key_attrs_desc := 'N';
            END IF;

            IF p_icc_rec.ITEM_CREATION_ALLOWED_FLAG IS NULL THEN
                    p_icc_rec.ITEM_CREATION_ALLOWED_FLAG :=  g_old_icc_rec.ITEM_CREATION_ALLOWED_FLAG;
            END IF;


            -- Start DFF attributes
            -- Populating NULL is taken care by EGO_ITEM_CATALOG_PUB API ,
            --  adding only the additional columns not accepted by the API
            --

            IF p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE = G_MISS_CHAR THEN
              p_icc_rec.ITEM_NUM_GEN_METHOD_TYPE := 'U';   -- if it is NULL, in UI there is error while rendering ICC
            END IF;

            IF p_icc_rec.prefix = G_MISS_CHAR THEN
                    p_icc_rec.prefix :=  null;
            END IF;


            IF p_icc_rec.starting_number = G_MISS_NUM THEN
                    p_icc_rec.starting_number :=  null;
            END IF;


            IF p_icc_rec.increment_by = G_MISS_NUM  THEN
                    p_icc_rec.increment_by := null;
            END IF;

            IF p_icc_rec.suffix = G_MISS_CHAR THEN
                    p_icc_rec.suffix :=  null;
            END IF;

            IF p_icc_rec.item_num_action_id = G_MISS_NUM  THEN
                    p_icc_rec.item_num_action_id :=  null;
            END IF;

            IF p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE = G_MISS_CHAR THEN
                    p_icc_rec.ITEM_DESC_GEN_METHOD_TYPE :=  'U';  -- if it is NULL then in UI there is error while rendering ICC
            END IF;

            IF p_icc_rec.item_desc_action_id = G_MISS_NUM THEN
                    p_icc_rec.item_desc_action_id :=  null;
            END IF;


            IF p_icc_rec.new_item_req_change_type_id = G_MISS_NUM THEN
                    p_icc_rec.new_item_req_change_type_id :=  null;
            END IF;

            IF p_icc_rec.new_item_request_type = G_MISS_CHAR  THEN
                    p_icc_rec.new_item_request_type :=  null;
            END IF;

            IF p_icc_rec.enable_key_attrs_num = G_MISS_CHAR  THEN
              p_icc_rec.enable_key_attrs_num := 'N';
            END IF;

            IF p_icc_rec.enable_key_attrs_desc = G_MISS_CHAR  THEN
              p_icc_rec.enable_key_attrs_desc := 'N';
            END IF;

            IF p_icc_rec.ITEM_CREATION_ALLOWED_FLAG = G_MISS_CHAR THEN
                    p_icc_rec.ITEM_CREATION_ALLOWED_FLAG := 'N';
            END IF;



        ELSIF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN

            --- Nullify Func param columns
            --- no columns as of now
            NULL;
        ELSIF p_entity = G_ENTITY_ICC_AG_ASSOC THEN

            --- Nullify AG association cols
            --- no columns as of now
            NULL;

        ELSIF p_entity = G_ENTITY_ICC_VERSION THEN

            --- Nullify Version specific information
            --- no columns as of now
            null;

        END IF; --- ICC Header


     write_debug (l_proc_name, 'End');

     EXCEPTION
     WHEN OTHERS THEN
        x_return_status := G_RET_STS_UNEXP_ERROR;
        x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
        write_debug(l_proc_name, x_return_msg);
     end   Populate_Null_Cols;



  /********************************************
  ---- Function to check if the data level exists
  ----
  *******************************************/

  FUNCTION Get_Data_Level_for_AG (  p_data_level_name    IN VARCHAR2 DEFAULT NULL
                                   ,p_data_level_id      IN VARCHAR2 DEFAULT NULL
                                 )
  RETURN NUMBER
  IS

    l_data_level_id   ego_data_level_b.data_level_id%TYPE := NULL;
    l_proc_name       varchar2(40) := 'Get_Data_Level_for_AG';

    cursor cur_get_data_lvl
    IS
    SELECT data_level_id
    FROM ego_data_level_b
    WHERE data_level_id = NVL(p_data_level_id, data_level_id)
    AND   data_level_name = NVL (p_data_level_name , data_level_name)
    ;


  BEGIN
    write_debug (l_proc_name, 'Start');

    FOR rec_data_lvl IN cur_get_data_lvl
    LOOP
      l_data_level_id := rec_data_lvl.data_level_id;
      EXIT;
    END LOOP;

    RETURN l_data_level_id;

    write_debug (l_proc_name, 'End');
  exception
  WHEN OTHERS THEN
    RETURN NULL;
  End;


/********************************************************************
---   This procedure accepts the oncatenated segments
---   and returns the ccid for FINC_COMBINATION and 1 ( segment combination  exists)
---   or 0  ( combinaiton does not exist ) for CHECK_COMBINATION
********************************************************************/


    FUNCTION Get_Catalog_Group_Id (  p_catalog_group_name    IN VARCHAR2
                                   , p_operation         IN VARCHAR2
                                  )
    RETURN NUMBER
    IS
        l_proc_name    VARCHAR2(30) := 'Get_Catalog_Group_Id';

        is_valid  boolean;

    BEGIN

        -- write_debug(l_proc_name, 'validating segments . . .operation -  ' || p_operation );
        -- write_debug((l_proc_name,' concat. value ' || p_catalog_group_name);

        is_valid := FND_FLEX_KEYVAL.Validate_Segs
            (  operation         => p_operation
            ,  appl_short_name   => G_ITEM_CAT_KFF_APPL
            ,  key_flex_code     => G_ICC_KFF_NAME
            ,  structure_number  => G_STRUCTURE_NUMBER
            ,  concat_segments   => p_catalog_group_name
            );
        -- write_debug(l_proc_name, 'validate segments finished');

        IF (is_valid AND p_operation = 'FIND_COMBINATION') THEN

                return FND_FLEX_KEYVAL.Combination_ID;

        ELSIF (is_valid AND p_operation = 'CHECK_SEGMENTS')
        THEN

            return 1;
        ELSIF ( NOT is_valid AND p_operation = 'CHECK_SEGMENTS')
        THEN
            return 0;

        ELSE
            -- write_debug(l_proc_name, 'operation: ' || p_operation || ' returning NULL ' );
            return NULL;

        END IF;

    END Get_Catalog_Group_Id;



--***********************************************
--- Get the concatenated value from the segments
---**********************************************

    FUNCTION concatenate_segments( p_appl_short_name  IN VARCHAR2
                                  ,p_key_flex_code    IN VARCHAR2
                                  ,p_structure_number IN NUMBER
                                  ,p_icc_rec          IN ego_icc_rec_type
                                  )
    RETURN VARCHAR2
    IS

        l_proc_name               VARCHAR2(30) := 'concatenate_segments';
        l_key_flex_field          fnd_flex_key_api.flexfield_type;
        l_structure_type          fnd_flex_key_api.structure_type;
        l_segment_type            fnd_flex_key_api.segment_type;
        l_segment_list            fnd_flex_key_api.segment_list;
        l_segment_array           fnd_flex_ext.SegmentArray;
        l_cur_icc_segment_array   fnd_flex_ext.SegmentArray;
        l_num_segments            NUMBER;
        l_flag                    BOOLEAN;
        l_concat                  VARCHAR2(2000) := NULL;
        j                         NUMBER;
        i                         NUMBER;
    BEGIN

        write_debug(l_proc_name, 'Start');

        fnd_flex_key_api.set_session_mode('seed_data');

        l_key_flex_field :=
            fnd_flex_key_api.find_flexfield(p_appl_short_name,
                                     p_key_flex_code);

        l_structure_type :=
            fnd_flex_key_api.find_structure(l_key_flex_field,
                                     p_structure_number);

        fnd_flex_key_api.get_segments(l_key_flex_field, l_structure_type,
                                 TRUE, l_num_segments, l_segment_list);


        l_cur_icc_segment_array(1) := p_icc_rec.segment1;
        l_cur_icc_segment_array(2) := p_icc_rec.segment2;
        l_cur_icc_segment_array(3) := p_icc_rec.segment3;
        l_cur_icc_segment_array(4) := p_icc_rec.segment4;
        l_cur_icc_segment_array(5) := p_icc_rec.segment5;
        l_cur_icc_segment_array(6) := p_icc_rec.segment6;
        l_cur_icc_segment_array(7) := p_icc_rec.segment7;
        l_cur_icc_segment_array(8) := p_icc_rec.segment8;
        l_cur_icc_segment_array(9) := p_icc_rec.segment9;
        l_cur_icc_segment_array(10) := p_icc_rec.segment10;
        l_cur_icc_segment_array(11) := p_icc_rec.segment11;
        l_cur_icc_segment_array(12) := p_icc_rec.segment12;
        l_cur_icc_segment_array(13) := p_icc_rec.segment13;
        l_cur_icc_segment_array(14) := p_icc_rec.segment14;
        l_cur_icc_segment_array(15) := p_icc_rec.segment15;
        l_cur_icc_segment_array(16) := p_icc_rec.segment16;
        l_cur_icc_segment_array(17) := p_icc_rec.segment17;
        l_cur_icc_segment_array(18) := p_icc_rec.segment18;
        l_cur_icc_segment_array(19) := p_icc_rec.segment19;
        l_cur_icc_segment_array(20) := p_icc_rec.segment20;

        FOR i in 1..20 LOOP
          IF l_cur_icc_segment_array(i) =  G_MISS_CHAR THEN
            l_cur_icc_segment_array(i) := NULL;
          END IF;
        END LOOP;


        --
        -- The segments in the seg_list array are sorted in display order.
        -- i.e. sorted by segment number.
        --
        for i in 1..l_num_segments
        loop
                l_segment_type :=
                fnd_flex_key_api.find_segment(l_key_flex_field,
                                      l_structure_type,
                                      l_segment_list(i));
                j := to_number(substr(l_segment_type.column_name,8));
                l_segment_array(i) := l_cur_icc_segment_array(j);
        end loop;

        --
        -- Now we have the all segment values in correct order in segarray.
        --
        l_concat := fnd_flex_ext.concatenate_segments(l_num_segments,
                                      l_segment_array,
                                      l_structure_type.segment_separator);

        -- dbms_output.put_line('Return from concatenate_segments ' || l_concat);

        RETURN l_concat;
     write_debug(l_proc_name, 'End');
    END concatenate_segments;

---*******************************************
--- This functin returns true if one of the segment is populated for
--- ICC name

---*******************************************
FUNCTION Segments_Populated  ( p_icc_rec IN ego_icc_rec_type)
RETURN BOOLEAN
IS
BEGIN
  IF (   (p_icc_rec.Segment1 IS NOT NULL AND
          p_icc_rec.Segment1 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment2 IS NOT NULL AND
          p_icc_rec.Segment2 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment3 IS NOT NULL AND
          p_icc_rec.Segment3 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment4 IS NOT NULL AND
          p_icc_rec.Segment4 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment5 IS NOT NULL AND
          p_icc_rec.Segment5 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment6 IS NOT NULL AND
          p_icc_rec.Segment6 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment7 IS NOT NULL AND
          p_icc_rec.Segment7 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment8 IS NOT NULL AND
          p_icc_rec.Segment8 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment9 IS NOT NULL AND
          p_icc_rec.Segment9 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment10 IS NOT NULL AND
          p_icc_rec.Segment10 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment11 IS NOT NULL AND
          p_icc_rec.Segment12 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment13 IS NOT NULL AND
          p_icc_rec.Segment13 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment14 IS NOT NULL AND
          p_icc_rec.Segment14 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment15 IS NOT NULL AND
          p_icc_rec.Segment15 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment16 IS NOT NULL AND
          p_icc_rec.Segment16 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment17 IS NOT NULL AND
          p_icc_rec.Segment17 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment18 IS NOT NULL AND
          p_icc_rec.Segment18 <> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment19 IS NOT NULL AND
          p_icc_rec.Segment19<> FND_API.G_MISS_CHAR
          ) OR
         (p_icc_rec.Segment20 IS NOT NULL AND
          p_icc_rec.Segment20 <> FND_API.G_MISS_CHAR
          )
        )
     THEN
        return true;
     ELSE
        return false;
     END IF;
END Segments_Populated;


/********************************************************************
--- This function checks if the AG is already associated
---
********************************************************************/

function Get_AG_Association ( p_attr_group_id  IN NUMBER
                               ,p_icc_id       IN NUMBER
                              )
return number

IS
 l_proc_name   VARCHAR2(30) := 'Get_AG_Association';

 l_association_id  ego_obj_ag_assocs_b.association_id%TYPE := null;

 /*
 cursor cur_ag_assoc
 is
 select association_id
 from   ego_obj_ag_assocs_b
 where attr_group_id = p_attr_group_id
 and   classification_code = to_char(p_icc_id)
 and   object_id = ( select object_id from fnd_objects where obj_name = G_ITEM_OBJ_NAME)
 and rownum = 1
 ;
 */

 cursor cur_ag_assoc
 is
    SELECT oagv.association_id
      FROM ego_attr_groups_v agv,
           ego_obj_attr_grp_assocs_v oagv,
           ego_catalog_groups_v cg
     WHERE oagv.attr_group_id = agv.attr_group_id
       AND agv.attr_group_id =  p_attr_group_id
       AND cg.catalog_group_id = oagv.classification_code
       AND oagv.object_id = g_item_obj_id
       AND oagv.classification_code IN (
                                       SELECT TO_CHAR (item_catalog_group_id)
                                       FROM mtl_item_catalog_groups_b
                                       CONNECT BY PRIOR parent_catalog_group_id = item_catalog_group_id
                                       START WITH item_catalog_group_id = p_icc_id
                                       )
 ;


BEGIN
  write_debug(l_proc_name, 'start');

  FOR rec_ag_assoc IN cur_ag_assoc  loop
    l_association_id := rec_ag_assoc.association_id;
  end loop;

  write_debug(l_proc_name, 'End');
  return l_association_id;

END Get_AG_Association;

/**************************
--- Set EGO application id
***************************/
procedure set_application_id
is

  l_proc_name   varchar2(30) := 'set_application_id';
begin

  select application_id
  into   G_EGO_APPL_ID
  from   fnd_application
  where application_short_name = G_APPL_NAME;

exception
when others then
  write_debug( l_proc_name , 'Applcation id not found for ego '||SQLERRM);
  raise;
end;



/**********************************************************************
--- Check is AG being passed is not one of the base AGs associated to the ICC
---
***********************************************************************/
function Check_Seeded_AG_Assoc ( p_attr_grp_id  IN NUMBER
                                ,p_icc_id       IN NUMBER
                               )
return boolean
IS

 l_exists  BOOLEAN := false;
 l_proc_name  varchar2(30) := 'Check_Seeded_AG_Assoc';

 cursor cur_ag_CHK
 is
  SELECT 1
  from ego_fnd_dsc_flx_ctx_ext
  WHERE descriptive_flexfield_name = G_SEEDED_AG_Type
   AND  application_id = g_ego_appl_id
   and  attr_group_id = p_attr_grp_id
 ;



BEGIN
  write_debug ( l_proc_name, 'start');
  FOR rec_ag_chk IN cur_ag_chk  loop
    l_exists := TRUE;
    exit;
  end loop;

  write_debug ( l_proc_name, 'end');
  return l_exists;

exception
when others then
  write_debug( l_proc_name , 'Error which checking attr grp id '||SQLERRM);
  raise;
END Check_Seeded_AG_Assoc;

/***************************************************************
--- Function to check if an ICC has a released version
---
****************************************************************/
FUNCTION Has_Released_Version ( p_icc_id   IN NUMBER
                             )
RETURN boolean
IS

  CURSOR cur_icc_ver
  IS
  SELECT 1
  FROM   EGO_MTL_CATALOG_GRP_VERS_B b
  WHERE  b.item_catalog_group_id = p_icc_id
  AND    version_seq_id <> 0;

  l_exists   BOOLEAN := FALSE;
  L_PROC_NAME VARCHAR2(30) := 'Has_Released_Version';

BEGIN

  WRITE_DEBUG(L_PROC_NAME, 'p_icc_id, =>'||p_icc_id);

  FOR cur_chk_ver in cur_icc_ver LOOP
    l_exists := TRUE;
    exit;
  END LOOP;

  RETURN l_exists;

END Has_Released_Version;


/***************************************************************
--- Function to check if an ICC has a released version for a
--- particular date
----
****************************************************************/
FUNCTION Has_Released_Version ( p_icc_id   IN NUMBER
                             ,p_date     IN DATE
                             )
RETURN boolean
IS

  CURSOR cur_icc_ver
  IS
  SELECT 1
  FROM   EGO_MTL_CATALOG_GRP_VERS_B b
  WHERE  b.item_catalog_group_id = p_icc_id
  AND    p_date  BETWEEN start_active_date
                   AND NVL(end_active_date, p_date+1)
  AND    version_seq_id <> 0;

  l_exists   BOOLEAN := FALSE;
  L_PROC_NAME VARCHAR2(30) := 'Has_Released_Version';

BEGIN

  WRITE_DEBUG(L_PROC_NAME, 'p_icc_id, p_date=>'||p_icc_id||','||TO_CHAR(p_date, 'dd-mon-yyyy hh24:mi:ss'));

  FOR cur_chk_ver in cur_icc_ver LOOP
    l_exists := TRUE;
    exit;
  END LOOP;

  RETURN l_exists;

END Has_Released_Version;


/***************************************************************
--- Function to check if an ICC has only draft version
---
****************************************************************/
FUNCTION Has_OnlyDraft_Version ( p_icc_id   IN NUMBER
                             )
RETURN boolean
IS

  CURSOR cur_icc_ver
  IS
  SELECT 1
  FROM   EGO_MTL_CATALOG_GRP_VERS_B b
  WHERE  b.item_catalog_group_id = p_icc_id
  AND    version_seq_id <> 0;

  l_exists   BOOLEAN := FALSE;

BEGIN

  FOR cur_chk_ver in cur_icc_ver LOOP
    l_exists := TRUE;
  END LOOP;

  RETURN (NOT l_exists);

END Has_OnlyDraft_Version;



/********************************************************************
---   This procedure accepts a record type , does value to id
---   conversion and other validations
---
********************************************************************/
    PROCEDURE Value_To_ID_Conversion(    p_entity         IN varchar2
                                       , p_icc_rec        IN OUT NOCOPY ego_icc_rec_type
                                       , p_ag_assoc_rec   IN OUT NOCOPY ego_ag_assoc_rec_type
                                       , p_func_param_assoc_rec IN OUT NOCOPY ego_func_param_map_rec_type
                                       , p_icc_ver_rec    IN OUT NOCOPY ego_icc_vers_rec_type
                                       , p_call_from_icc_process IN VARCHAR2 := 'F'    --- Added param bug 9791391
                                       , x_return_status    OUT NOCOPY VARCHAR2
                                       , x_return_msg  OUT NOCOPY VARCHAR2
                                     )
    IS
     l_proc_name  CONSTANT  VARCHAR2(30) := 'Value_To_ID_COnversion';
     e_stop_processing      EXCEPTION;
     l_null_icc_rec_type    EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type := null ;
     l_Mesg_Token_tbl       Error_Handler.Mesg_Token_Tbl_Type;
     l_dummy                boolean;
     l_data_level_id        ego_data_level_b.data_level_id%TYPE := NULL;
     l_icc_name             mtl_item_catalog_groups_b_kfv.padded_concatenated_segments%TYPE := null;
     l_association_id       ego_obj_ag_assocs_b.association_id%TYPE := null;
     l_return_status        VARCHAR2(1);
     l_return_status2       VARCHAR2(1);
     l_locking_party_id     NUMBER;
     l_lock_flag            ego_object_lock.lock_flag%TYPE;
     l_user_name            ego_user_v.party_name%TYPE;


     -- for error logging
     --
     l_entity_code     VARCHAR2(30) := null;
     l_token_table     ERROR_HANDLER.Token_Tbl_Type;


   BEGIN
     write_debug (l_proc_name, 'Start of  '||l_proc_name);

     x_return_status := G_RET_STS_SUCCESS;
     l_return_status := G_RET_STS_SUCCESS;

     ---
     --- Validations which are done as part of BULK_Validate during concurrent processing should
     --- be done if the calling process is an API
     IF G_Flow_Type = G_EGO_MD_API THEN -- pl/sql processing

         write_debug (l_proc_name, 'API Bulk Validation');
         Bulk_Validate_For_API (    p_entity         => p_entity
                                  , p_icc_rec        => p_icc_rec
                                  , p_ag_assoc_rec   => p_ag_assoc_rec
                                  , p_func_param_assoc_rec => p_func_param_assoc_rec
                                  , x_return_status  => x_return_status
                                  , x_return_msg     => x_return_msg
                               );
         IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
           RAISE e_stop_processing;

         END IF;

     END IF;

     ---
     --- ICC HEADER
     ---
     IF p_ENTITY = G_ENTITY_ICC_HEADER THEN

           write_debug (l_proc_name, 'Start Header VALUE_TO_ID');
           l_entity_code := G_ENTITY_ICC_HEADER;
           ---
           --- Derive ICC id from segments , resolve the SYNC transaction based on that
           ---
           write_debug (l_proc_name, 'icc segs validation');
           IF p_icc_rec.item_catalog_group_id IS NULL and p_icc_rec.item_catalog_name IS NULL
             AND Segments_Populated ( p_icc_rec )
           THEN
             l_icc_name := concatenate_segments( p_appl_short_name  => G_ITEM_CAT_KFF_APPL
                                                ,p_key_flex_code    => G_ICC_KFF_NAME
                                                ,p_structure_number => G_STRUCTURE_NUMBER
                                                ,p_icc_rec          => p_icc_rec
                                               );

             p_icc_rec.item_catalog_group_id  --- NULL assigned indicated CCID was not found
                        :=  Get_Catalog_Group_Id (  p_catalog_group_name => l_icc_name
                                                  , p_operation     => 'FIND_COMBINATION'
                                                );


           END IF;

           ---
           --- Resolve the SYNC transaction type
           ---
           write_debug (l_proc_name, 'Resolve sync');
           IF p_icc_rec.transaction_type = G_TTYPE_SYNC THEN
               IF Check_Catalog_CCID (p_icc_rec.item_catalog_group_id) THEN
                 ---- ICC already exists
                 ----
                  p_icc_rec.transaction_type := G_TTYPE_UPDATE;
               ELSE
                  p_icc_rec.transaction_type := G_TTYPE_CREATE;
               END IF;
           END IF;

           IF p_icc_rec.transaction_type = G_TTYPE_UPDATE AND NOT Check_Catalog_CCID (p_icc_rec.item_catalog_group_id) THEN

                  l_return_status := G_RET_STS_ERROR;

                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                  => 'EGO_ICC_ID_INVALID'
                   ,p_application_id                => G_APPL_NAME
                   ,p_token_tbl                     => l_token_table

                   ,p_row_identifier                => p_icc_rec.transaction_id
                   ,p_entity_code                   => l_entity_code
                   ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                   );
           ELSIF p_icc_rec.transaction_type = G_TTYPE_UPDATE AND Check_Catalog_CCID (p_icc_rec.item_catalog_group_id) THEN
               --- Get the details for existing ICC , required for validations
               ---
              Fetch_Old_ICC_Dtls (g_old_icc_rec, p_icc_rec.item_catalog_group_id);
           end if;


           IF p_icc_rec.transaction_type = G_TTYPE_CREATE THEN

             IF p_icc_rec.item_catalog_group_id IS NOT NULL THEN

                  l_return_status := G_RET_STS_ERROR;

                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                  => 'EGO_CATALOG_GROUP_EXISTS'
                   ,p_application_id                => G_APPL_NAME
                   ,p_token_tbl                     => l_token_table
                   ,p_row_identifier                => p_icc_rec.transaction_id
                   ,p_entity_code                   => l_entity_code
                   ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                   );

             END IF;
           END IF;

           --- Bulk Validate takes care of below validation

           --- validate the parent catalog group, parent catalog group id is validated in Bulk validations
           ---
          write_debug (l_proc_name, 'Parent validation');
          IF p_icc_rec.parent_catalog_group_name IS NOT NULL THEN
                --- By this time if the parent catalog group if in the
                --- same interface table , it would have already been created
                ---
                  write_debug (l_proc_name, 'Validate parent catalog name');
                  p_icc_rec.parent_catalog_group_id := Get_Catalog_Group_Id ( p_icc_rec.parent_catalog_group_name , 'FIND_COMBINATION');
                  write_debug (l_proc_name, 'parent catalog GROUP ID =>'||NVL(p_icc_rec.parent_catalog_group_id, -999999));

                IF p_icc_rec.parent_catalog_group_id IS NULL THEN

                  l_return_status := G_RET_STS_ERROR;
                  write_debug (l_proc_name, 'inserting error for parent');

                  l_token_table(1).TOKEN_NAME := 'ICC_NAME';
                  l_token_table(1).TOKEN_VALUE := p_icc_rec.parent_catalog_group_name;

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                  => 'EGO_ICC_PARENT_INVALID'
                       ,p_application_id                => G_APPL_NAME
                       ,p_token_tbl                     => l_token_table
                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );
                       l_token_table.delete();
                --- Parent should have atleast one released at the time of creation of this child ICC
                ---
                ELSIF  p_icc_rec.parent_catalog_group_id IS NOT NULL THEN


                  IF (NOT Has_Released_Version ( p_icc_rec.parent_catalog_group_id, SYSDATE)) AND G_P4TP_PROFILE_ENABLED THEN


                    l_return_status := G_RET_STS_ERROR;
                    write_debug (l_proc_name, 'inserting error for parent, parent no released version');

                    l_token_table(1).TOKEN_NAME := 'ICC_NAME';
                    l_token_table(1).TOKEN_VALUE := p_icc_rec.parent_catalog_group_name;

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_name                  => 'ICC_PARENT_NO_RELEASE_VER'
                       ,p_application_id                => G_APPL_NAME
                       ,p_token_tbl                     => l_token_table
                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );
                       l_token_table.delete();
                       write_debug(l_proc_name, 'Err_Msg-TID='
                             ||p_icc_rec.transaction_id||'-(ICC, PARENT ICC)=('
                             ||p_icc_rec.item_catalog_name||','||p_icc_rec.parent_catalog_group_name||')'
                             ||' parent does not have a released version'
                             );


                  END IF;

                  --- parent icc has a released version effective sysdate
                  --- current icc being updated should not have a released version
                  --- if it has a released version, old and new parent icc should be same
                  ---
                  write_debug ( l_proc_name , ' old parent id=>'||g_old_icc_rec.PARENT_CATALOG_GROUP_ID||'*'
                                           || ' curr parent id=>'||p_icc_rec.parent_catalog_group_id);

                  IF p_icc_rec.transaction_type = G_TTYPE_UPDATE
                     AND Has_Released_Version(p_icc_rec.item_catalog_group_id)
                     AND G_P4TP_PROFILE_ENABLED
                     AND NVL(g_old_icc_rec.PARENT_CATALOG_GROUP_ID, -99999) <> p_icc_rec.parent_catalog_group_id THEN

                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => 'EGO_ICC_DIS_UPD'
                     ,p_application_id                => G_APPL_NAME
                     ,p_token_tbl                     => l_token_table
                     ,p_row_identifier                => p_icc_rec.transaction_id
                     ,p_entity_code                   => l_entity_code
                     ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                     );

                     l_return_status := G_RET_STS_ERROR;
                     write_debug(l_proc_name, 'Err_Msg-TID='
                             ||p_icc_rec.transaction_id||'-(ICC, PARENT ICC)=('
                             ||p_icc_rec.item_catalog_name||','||p_icc_rec.parent_catalog_group_name||')'
                             ||' change of parent item catalog is not allowed for versioned iccs'
                           );
                  END IF;

                  --- parent icc has a released version effective sysdate
                  --- current icc being updated if it has only draft
                  --- then allow the parent icc update only once if parent is null
                  ---
                  IF p_icc_rec.transaction_type = G_TTYPE_UPDATE
                     AND Has_OnlyDraft_Version(p_icc_rec.item_catalog_group_id)
                     AND G_P4TP_PROFILE_ENABLED
                     AND g_old_icc_rec.PARENT_CATALOG_GROUP_ID <> p_icc_rec.parent_catalog_group_id THEN

                    ERROR_HANDLER.Add_Error_Message(
                      p_message_name                  => 'EGO_ICC_DIS_UPD'
                     ,p_application_id                => G_APPL_NAME
                     ,p_token_tbl                     => l_token_table
                     ,p_row_identifier                => p_icc_rec.transaction_id
                     ,p_entity_code                   => l_entity_code
                     ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                     );

                     l_return_status := G_RET_STS_ERROR;
                     write_debug(l_proc_name, 'Err_Msg-TID='
                             ||p_icc_rec.transaction_id||'-(ICC, PARENT ICC)=('
                             ||p_icc_rec.item_catalog_name||','||p_icc_rec.parent_catalog_group_name||')'
                             ||' change of parent item catalog is not allowed for draft(parent asso before) iccs'
                           );
                  END IF;



                END IF;
          END IF;
           --- end parent checking
           ---

           --- added bug 9737402
           ---
           write_debug (l_proc_name, 'inactive date validation');
           IF p_icc_rec.inactive_date IS NOT NULL
              AND p_icc_rec.inactive_date <> G_MISS_DATE
              AND TRUNC(p_icc_rec.inactive_date) < TRUNC(SYSDATE) THEN

              ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ENDDATE_EXCEEDS_SYSDATE'
               ,p_application_id                => G_APPL_NAME
               ,p_token_tbl                     => l_token_table
               ,p_row_identifier                => p_icc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );

               l_return_status := G_RET_STS_ERROR;
               write_debug(l_proc_name, 'Err_Msg-TID='
                       ||p_icc_rec.transaction_id||'-(ICC)=('
                       ||p_icc_rec.item_catalog_name
                       ||') inactive date is in past'
                     );


           END IF;

           --- added bug 9737833
           ---
           Validate_YesNo_Cols ( p_icc_rec => p_icc_rec
                                ,x_return_status    => x_return_status
                               , x_return_msg      => x_return_msg
                               );

               if x_return_status = G_RET_STS_ERROR THEN
                 --- mark the current record as error
                 ---
                 l_return_status := G_RET_STS_ERROR;

               elsIF x_return_status = G_RET_STS_UNEXP_ERROR then
                   raise e_stop_processing;
               end if;


           Validate_Func_Related_Cols ( p_icc_rec => p_icc_rec
                                       ,x_return_status    => x_return_status
                                       , x_return_msg      => x_return_msg
                                      );

               if x_return_status = G_RET_STS_ERROR THEN
                 --- mark the current record as error
                 ---
                 l_return_status := G_RET_STS_ERROR;

               elsIF x_return_status = G_RET_STS_UNEXP_ERROR then
                   raise e_stop_processing;
               end if;



           Validate_NIR_Columns     ( p_icc_rec => p_icc_rec
                                       ,x_return_status    => x_return_status
                                      );

               IF x_return_status = G_RET_STS_ERROR THEN
                 --- mark the current record as error
                 ---
                 l_return_status := G_RET_STS_ERROR;

               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR then
                   raise e_stop_processing; -- skip to next record?
               END IF;

           ---- End ICC
           ----
           x_return_status := l_return_status;
           write_debug (l_proc_name, 'End Header');
     END IF;
     ---------------------------------------------------
     -------   AG Association
     ---------------------------------------------------


     IF p_ENTITY = G_ENTITY_ICC_AG_ASSOC THEN

        l_entity_code := G_ENTITY_ICC_AG_ASSOC;
         --- Validate if the AG being passed is base/default AG assocatiated to the item
         ---

       IF Check_Seeded_AG_Assoc ( p_icc_id => p_ag_assoc_rec.item_catalog_group_id
                                 ,p_attr_grp_id =>   p_ag_assoc_rec.attr_group_id
                                ) THEN

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_CANNOT_UPDATE_SEEDED_AG'
           ,p_application_id                => G_APPL_NAME
           ,p_row_identifier                => p_ag_assoc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_AG_ASSOC_TAB
           );

           l_return_status := G_RET_STS_ERROR;

       END IF;

       write_debug(l_proc_name, 'getting association id');
       l_association_id := Get_AG_Association ( p_icc_id => p_ag_assoc_rec.item_catalog_group_id
                                              ,p_attr_group_id  => p_ag_assoc_rec.attr_group_id
                                              );
       write_debug(l_proc_name, 'getting association id=>'||l_association_id);
       p_ag_assoc_rec.association_id :=  l_association_id;

       IF l_association_id is not null then

         IF p_ag_assoc_rec.transaction_type = G_TTYPE_CREATE then
           l_token_table(1).TOKEN_NAME := 'AG_NAME';
           l_token_table(1).TOKEN_VALUE := p_ag_assoc_rec.attr_group_name;

           l_token_table(2).TOKEN_NAME := 'ICC_NAME';
           l_token_table(2).TOKEN_VALUE := p_ag_assoc_rec.item_catalog_name;


           ERROR_HANDLER.Add_Error_Message(
             p_message_name                  => 'EGO_AG_ALREADY_ASSOCIATED_ICC'
            ,p_application_id                => G_APPL_NAME
            ,p_token_tbl                     => l_token_table
            ,p_row_identifier                => p_ag_assoc_rec.transaction_id
            ,p_entity_code                   => l_entity_code
            ,p_table_name                    => G_ENTITY_ICC_AG_ASSOC_TAB
            );
            l_token_table.DELETE;

            l_return_status := G_RET_STS_ERROR;
         end if;

       ELSIF (l_association_id IS NULL and p_ag_assoc_rec.transaction_type IN ( G_TTYPE_DELETE ) ) THEN

          l_token_table(1).TOKEN_NAME := 'AG_NAME';
          l_token_table(1).TOKEN_VALUE := p_ag_assoc_rec.attr_group_name;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_AG_NOT_ASSOCIATED_ICC'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table

           ,p_row_identifier                => p_ag_assoc_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_AG_ASSOC
           );
           l_token_table.DELETE;


           l_return_status := G_RET_STS_ERROR;
       ELSE
          null;
       END IF;

       x_return_status := l_return_status;
   END IF; --- AG assoc rec
   --- End AG Associations
   ---


  ---------------------------------------------------
  -------   ICC Versions
  ---------------------------------------------------


  IF p_ENTITY = G_ENTITY_ICC_VERSION  THEN
  --- Start ICC Versions
  ---
    l_entity_code := G_ENTITY_ICC_VERSION;

    --- uncommented bug 9752139
    --- Validate the transaction type, taken care of in bUlk validate , Validate_trans_Type
    ---
    IF p_icc_ver_rec.transaction_type IS NULL OR p_icc_ver_rec.transaction_type NOT IN ( G_TTYPE_CREATE) THEN


      l_token_table(1).TOKEN_NAME := 'entity';
      l_token_table(1).TOKEN_VALUE := G_ENTITY_ICC_VERSION;

      ERROR_HANDLER.Add_Error_Message(
        p_message_name                  => 'EGO_TRANS_TYPE_INVALID'
       ,p_application_id                => G_APPL_NAME
       ,p_token_tbl                     => l_token_table
       ,p_row_identifier                => p_icc_ver_rec.transaction_id
       ,p_entity_code                   => l_entity_code
       ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
       );
       l_token_table.DELETE;

       l_return_status := G_RET_STS_ERROR;

       write_debug(l_proc_name, 'Err_Msg-TID='
                    ||p_icc_ver_rec.transaction_id||'-(ICC, STA_DT)=('
                    ||p_icc_ver_rec.item_catalog_name||','||to_char(p_icc_ver_rec.start_date, 'DD-MON-YYYY HH24:MI:SS')||')'
                    ||' Versions only support CREATE'
                  );
    END IF;


    --- Validate the ICC ID
    ---
    IF p_icc_ver_rec.item_catalog_group_id IS NOT NULL
        AND NOT Check_Catalog_CCID (p_icc_ver_rec.item_catalog_group_id) THEN

          l_return_status := G_RET_STS_ERROR;
          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_ICC_ID_INVALID'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_ver_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
           );
       write_debug(l_proc_name, 'Err_Msg-TID='
                    ||p_icc_ver_rec.transaction_id||'-(ICC, STA_DT)=('
                    ||p_icc_ver_rec.item_catalog_name||','||to_char(p_icc_ver_rec.start_date, 'DD-MON-YYYY HH24:MI:SS')||')'
                    ||'EGO_ICC_ID_INVALID'
                  );


    ELSIF p_icc_ver_rec.item_catalog_name IS NOT NULL THEN

        p_icc_ver_rec.item_catalog_group_id := Get_Catalog_Group_Id ( p_icc_ver_rec.item_catalog_name , 'FIND_COMBINATION');
        write_debug (l_proc_name, 'catalog GROUP ID =>'||NVL(p_icc_ver_rec.item_catalog_group_id, -999999));

        IF p_icc_ver_rec.item_catalog_group_id IS NULL THEN
          l_return_status := G_RET_STS_ERROR;
          ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_ICC_ID_INVALID'
               ,p_application_id                => G_APPL_NAME
               ,p_token_tbl                     => l_token_table
               ,p_row_identifier                => p_icc_ver_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
               );
          write_debug(l_proc_name, 'Err_Msg-TID='
                    ||p_icc_ver_rec.transaction_id||'-(ICC, STA_DT)=('
                    ||p_icc_ver_rec.item_catalog_name||','||to_char(p_icc_ver_rec.start_date, 'DD-MON-YYYY HH24:MI:SS')||')'
                    ||'EGO_ICC_ID_INVALID'
                  );
        ELSE

           --- Since ICC is created now, update the icc id in the TA interface table
           ---
           --- Update the ICC id in the TA interface table
           ---
           EGO_TA_BULKLOAD_PVT.Bulk_Validate_Trans_Attrs_ICC (
                                                  p_set_process_id           => G_SET_PROCESS_ID
                                                ,p_item_catalog_group_id    => p_icc_ver_rec.item_catalog_group_id
                                                ,p_item_catalog_group_name  => p_icc_ver_rec.item_catalog_name
                                                );

        END IF;


    END IF;

    --- uncommented bug 9752139 , made condition <=
    ---
    --- Version  seq 0 or draft version are not supported
    ---
    IF p_icc_ver_rec.ver_seq_no <= 0 THEN

          ---
          --- Version seq 0 is not supported for create/update
          ---
          l_token_table(1).TOKEN_NAME := 'ICC_NAME';
          l_token_table(1).TOKEN_VALUE := p_icc_ver_rec.item_catalog_name;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_VER_SEQ_ZERO_ERROR'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_ver_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
           );
           l_token_table.DELETE;

           l_return_status := G_RET_STS_ERROR;

    END IF;


    ---
    --- Check for start date in the past
    ---
    IF NVL(p_icc_ver_rec.start_date, SYSDATE+1) < SYSDATE THEN

          ---
          --- Version seq already exists in the system
          ---
          l_token_table(1).TOKEN_NAME := 'START_DATE';
          l_token_table(1).TOKEN_VALUE := p_icc_ver_rec.start_date;

          l_token_table(2).TOKEN_NAME := 'VER_SEQ_NO';
          l_token_table(2).TOKEN_VALUE := p_icc_ver_rec.ver_seq_no;

          l_token_table(3).TOKEN_NAME := 'ICC_NAME';
          l_token_table(3).TOKEN_VALUE := p_icc_ver_rec.item_catalog_name;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_VER_START_DATE_PAST'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table

           ,p_row_identifier                => p_icc_ver_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
           );
           l_token_table.DELETE;

           l_return_status := G_RET_STS_ERROR;

    END IF;


    ---
    --- Default the start date with SYSDATE if NULL
    ---
    IF p_icc_ver_rec.start_date IS NULL THEN
      p_icc_ver_rec.start_date := SYSDATE;
    END IF;

    ---
    --- Added for bug 9791391, honour locks
    ---
    write_debug(l_proc_name, 'p_call_from_icc_process=>'||p_call_from_icc_process);

    IF p_call_from_icc_process = 'F' THEN
        --- first get the lock info as to who has locked the draft
        ---
        EGO_METADATA_BULKLOAD_PVT.Get_Lock_Info (   p_object_name  => G_ENTITY_ICC_LOCK
                                                   ,p_pk1_value    => p_icc_ver_rec.item_catalog_group_id
                                                   ,x_locking_party_id  => l_locking_party_id
                                                   ,x_lock_flag         => l_lock_flag
                                                   ,x_return_msg        => x_return_msg
                                                   ,x_return_status     => x_return_status
                                               );
         write_debug(l_proc_name, 'Locking flag , party id , g_party_id=>'||l_lock_flag||','|| l_locking_party_id||','||g_party_id);

        IF x_return_status  = G_RET_STS_ERROR THEN
          l_return_status := G_RET_STS_ERROR;

          ERROR_HANDLER.Add_Error_Message(
                p_message_text                  => x_return_msg
               ,p_application_id                => G_APPL_NAME
               ,p_token_tbl                     => l_token_table
               ,p_row_identifier                => p_icc_ver_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
               );
        ELSIF  x_return_status  = G_RET_STS_UNEXP_ERROR THEN
          RAISE e_stop_processing;
        END IF;

        ---
        --- Draft locked by a different user , error out the verison record
        ---
        IF l_lock_flag = 'L'  AND l_locking_party_id <> g_party_id THEN

          l_return_status := G_RET_STS_ERROR;   --- added bug 9840409
          ego_metadata_bulkload_pvt.Get_Party_Name( l_locking_party_id, l_user_name);

          l_token_table(1).TOKEN_NAME := 'ENTITY_NAME';
          l_token_table(1).TOKEN_VALUE := G_ENTITY_ICC_LOCK;

          l_token_table(2).TOKEN_NAME := 'PARTY_NAME';
          l_token_table(2).TOKEN_VALUE := l_user_name;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_ENTITY_LOCKED'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_ver_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
           );
           l_token_table.DELETE;

        END IF;
    END IF;    --- not from ICC process


    ---
    --- Check if version with the curr. start date already exists in
    --- the system
    ---
    FOR rec_dt_chk in  ( SELECT 1
                         FROM   ego_mtl_catalog_grp_vers_b
                         WHERE  version_seq_id <> 0
                         AND    start_active_date = p_icc_ver_rec.start_date
                         AND    item_catalog_group_id =   p_icc_ver_rec.item_catalog_group_id
                       ) LOOP

          ---
          --- Version seq already exists in the system
          ---
          l_token_table(1).TOKEN_NAME := 'START_DATE';
          l_token_table(1).TOKEN_VALUE := to_char(p_icc_ver_rec.start_date, 'DD-MON-YYYY HH24:MI:SS');

          l_token_table(2).TOKEN_NAME := 'ICC_NAME';
          l_token_table(2).TOKEN_VALUE := p_icc_ver_rec.item_catalog_name;

          ERROR_HANDLER.Add_Error_Message(
            p_message_name                  => 'EGO_VER_ALREADY_EXISTS_DT'
           ,p_application_id                => G_APPL_NAME
           ,p_token_tbl                     => l_token_table
           ,p_row_identifier                => p_icc_ver_rec.transaction_id
           ,p_entity_code                   => l_entity_code
           ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
           );
           l_token_table.DELETE;

           l_return_status := G_RET_STS_ERROR;

    END LOOP;

    --- added bug 9752139
    IF l_return_status = G_RET_STS_ERROR THEN

      --- fail the associated TA records
      ---
      EGO_TA_BULKLOAD_PVT.Update_Intf_Err_Trans_Attrs(
                 p_set_process_id          => G_SET_PROCESS_ID,
                 p_item_catalog_group_id   => p_icc_ver_rec.item_catalog_group_id,
                 p_icc_version_number_intf => p_icc_ver_rec.ver_seq_no,
                 x_return_status           => l_return_status2,
                 x_return_msg              => x_return_msg);

      IF l_return_status2 = G_RET_STS_UNEXP_ERROR THEN
        RAISE e_stop_processing;
      END IF;


       l_token_table(1).TOKEN_NAME := 'ICC_NAME';
       l_token_table(1).TOKEN_VALUE := p_icc_ver_rec.item_catalog_name;

       l_token_table(2).TOKEN_NAME := 'VER_SEQ';
       l_token_table(2).TOKEN_VALUE := p_icc_ver_rec.ver_seq_no;


       ERROR_HANDLER.Add_Error_Message(
         p_message_name                  => 'EGO_RELATED_TA_FAIL'
        ,p_application_id                => G_APPL_NAME
        ,p_token_tbl                     => l_token_table
        ,p_row_identifier                => p_icc_ver_rec.transaction_id
        ,p_entity_code                   => l_entity_code
        ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
        );
        l_token_table.DELETE;


    END IF;


    x_return_status := l_return_status;

  --- End ICC Versions
  ---
  END IF;


  ---------------------------------------------------
  -------   Function Parameter
  ---------------------------------------------------


  IF p_ENTITY = G_ENTITY_ICC_FN_PARAM_MAP  THEN
    --- Start Func Parameters
    ---

      Validate_Func_Param_Mappings    ( p_func_param_assoc_rec =>  p_func_param_assoc_rec
                                       ,x_return_status      => x_return_status
                                       ,x_return_msg         => x_return_msg
                                        );

      IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
        RAISE  e_stop_processing;
      END IF;

    --- End Func parameters
    ---
  END IF;

  write_debug (l_proc_name, 'End of  '||l_proc_name);
EXCEPTION
WHEN e_stop_processing THEN
   x_return_status := G_RET_STS_UNEXP_ERROR;
WHEN OTHERS THEN
   x_return_status := G_RET_STS_UNEXP_ERROR;
   x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
end   Value_To_ID_Conversion;


---******************************************
--- Function to get the party id for a user
--- ID
--*******************************************

FUNCTION Get_party_id ( p_user_id IN NUMBER)
RETURN NUMBER
IS

  l_party_id ego_user_v.party_id%TYPE := null;

BEGIN

    SELECT party_id
    INTO l_party_id
    from ego_user_v
    where user_id = p_user_id;

    return l_party_id;

  EXCEPTION
    WHEN OTHERS THEN
      -- defaulting to MFG
      SELECT party_id
      INTO  l_party_id
      from ego_user_v
      where user_name = G_DEFAULT_USER_NAME;
      return l_party_id;
END Get_party_id;



 ---******************************************
 --- Create draft version of the ICC
 ---******************************************

 PROCEDURE Create_Draft_Version ( p_item_catalog_id IN NUMBER
                                 ,x_return_status   OUT NOCOPY VARCHAR2
                                 ,x_return_msg  OUT NOCOPY VARCHAR2
                                )
IS

  l_proc_name       VARCHAR2(30) := 'Create_Draft_Version';
  l_msg_name        fnd_new_messages.message_name%TYPE := null;
  l_msg_text        fnd_new_messages.message_text%TYPE := null;
  l_obj_name        VARCHAR2(30)  := 'EGO_ITEM_CATALOG_CATEGORY';
  l_sysdate         DATE;
  l_party_id        ego_user_v.party_id%type;

BEGIN
  write_debug(l_proc_name, 'Start ');
  x_return_status := G_RET_STS_SUCCESS;


           l_msg_name := 'EGO_ICC_DRAFT_VERSION';
           FND_MESSAGE.SET_NAME(G_APPL_NAME,l_msg_name );
           l_msg_text := FND_MESSAGE.GET;
           l_sysdate := SYSDATE;

           INSERT INTO EGO_MTL_CATALOG_GRP_VERS_B
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
           VALUES
             ( p_item_catalog_id,
             0,
             l_msg_text,
             null,
             null,
             G_USER_ID,
             l_sysdate,
             G_USER_ID,
             l_sysdate,
             G_LOGIN_ID);

            ---- Lock the draft version
            ----
           l_party_id := Get_party_id ( p_user_id => G_USER_ID);
           INSERT INTO  EGO_OBJECT_LOCK
                ( lock_id,
                  object_name,
                  pk1_value,
                  locking_party_id,
                  lock_flag,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login)
          VALUES   ( EGO_OBJECT_LOCK_S.NEXTVAL,
                     l_obj_name,
                     p_item_catalog_id,
                     l_party_id,
                     'L',
                     G_USER_ID,
                     l_sysdate,
                     G_USER_ID,
                     l_sysdate,
                     G_LOGIN_ID);

write_debug(l_proc_name, 'End ');
EXCEPTION
WHEN OTHERS THEN
   x_return_status := G_RET_STS_UNEXP_ERROR;
   x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Create_Draft_Version;

/********************************************************************
---   This procedure accepts the interface table record type , converts
---   it to the record type required by the ego_item_catalog_pub API
---
********************************************************************/


PROCEDURE    Convert_intf_rec_to_API_type (  p_entity       IN VARCHAR2
                                      , p_icc_rec      IN ego_icc_rec_type
                                      , x_api_icc_rec  OUT NOCOPY EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type
                                     )
IS
  l_proc_name    VARCHAR2(30) := 'Convert_to_API_tbl_type';
BEGIN

  write_debug(l_proc_name, 'Start');

  IF p_entity = G_ENTITY_ICC_HEADER THEN

      x_api_icc_rec.Catalog_Group_Name         := p_icc_rec.item_catalog_name;
      x_api_icc_rec.Parent_Catalog_Group_Name  := p_icc_rec.parent_catalog_group_name;
      x_api_icc_rec.Catalog_Group_Id           := p_icc_rec.item_catalog_group_id;
      x_api_icc_rec.Parent_Catalog_Group_Id    := p_icc_rec.parent_catalog_group_id;
      x_api_icc_rec.Description                := p_icc_rec.Description;
      x_api_icc_rec.Item_Creation_Allowed_Flag := p_icc_rec.Item_Creation_Allowed_Flag;
      x_api_icc_rec.Start_Effective_Date       := p_icc_rec.start_date_active;
      x_api_icc_rec.Inactive_Date              := trunc(p_icc_rec.Inactive_Date);
      x_api_icc_rec.Enabled_Flag               := p_icc_rec.Enabled_Flag;
      x_api_icc_rec.Summary_Flag               := p_icc_rec.Summary_Flag;
      x_api_icc_rec.segment1                   := p_icc_rec.segment1;
      x_api_icc_rec.segment2                   := p_icc_rec.segment2;
      x_api_icc_rec.segment3                   := p_icc_rec.segment3;
      x_api_icc_rec.segment4                   := p_icc_rec.segment4;
      x_api_icc_rec.segment5                   := p_icc_rec.segment5;
      x_api_icc_rec.segment6                   := p_icc_rec.segment6;
      x_api_icc_rec.segment7                   := p_icc_rec.segment7;
      x_api_icc_rec.segment8                   := p_icc_rec.segment8;
      x_api_icc_rec.segment9                   := p_icc_rec.segment9;
      x_api_icc_rec.segment10                  := p_icc_rec.segment10;
      x_api_icc_rec.segment11                  := p_icc_rec.segment11;
      x_api_icc_rec.segment12                  := p_icc_rec.segment12;
      x_api_icc_rec.segment13                  := p_icc_rec.segment13;
      x_api_icc_rec.segment14                  := p_icc_rec.segment14;
      x_api_icc_rec.segment15                  := p_icc_rec.segment15;
      x_api_icc_rec.segment16                  := p_icc_rec.segment16;
      x_api_icc_rec.segment17                  := p_icc_rec.segment17;
      x_api_icc_rec.segment18                  := p_icc_rec.segment18;
      x_api_icc_rec. segment19                 := p_icc_rec.segment19;
      x_api_icc_rec.segment20                  := p_icc_rec.segment20;
      x_api_icc_rec.Attribute_category         := p_icc_rec.Attribute_category;
      x_api_icc_rec.Attribute1                 := p_icc_rec.Attribute1;
      x_api_icc_rec.Attribute2                 := p_icc_rec.Attribute2;
      x_api_icc_rec.Attribute3                 := p_icc_rec.Attribute3;
      x_api_icc_rec.Attribute4                 := p_icc_rec.Attribute4;
      x_api_icc_rec.Attribute5                 := p_icc_rec.Attribute5;
      x_api_icc_rec.Attribute6                 := p_icc_rec.Attribute6;
      x_api_icc_rec.Attribute7                 := p_icc_rec.Attribute7;
      x_api_icc_rec.Attribute8                 := p_icc_rec.Attribute8;
      x_api_icc_rec.Attribute9                 := p_icc_rec.Attribute9;
      x_api_icc_rec.Attribute10                := p_icc_rec.Attribute10;
      x_api_icc_rec.Attribute11                := p_icc_rec.Attribute11;
      x_api_icc_rec.Attribute12                := p_icc_rec.Attribute12;
      x_api_icc_rec.Attribute13                := p_icc_rec.Attribute13;
      x_api_icc_rec.Attribute14                := p_icc_rec.Attribute14;
      x_api_icc_rec.Attribute15                := p_icc_rec.Attribute15;
      x_api_icc_rec.Transaction_Type           := p_icc_rec.Transaction_Type;
         --x_api_icc_rec.Return_Status

  END IF;

  write_debug(l_proc_name, 'End');
END Convert_intf_rec_to_API_type;


/********************************************************************
---   This procedure accepts the ego_item_catalog_pub API record type , converts
---   it to the interface table record type
---
********************************************************************/

PROCEDURE Convert_API_type_to_intf_rec  (  p_entity       IN VARCHAR2
                                         , x_icc_rec      IN OUT NOCOPY ego_icc_rec_type
                                         , p_api_icc_rec  IN EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type
                                         )
IS
  l_proc_name    VARCHAR2(30) := 'Convert_API_type_to_intf_rec';
BEGIN

  write_debug(l_proc_name, 'Start');

  IF p_entity = G_ENTITY_ICC_HEADER THEN

      x_icc_rec.item_catalog_name          := NVL(x_icc_rec.item_catalog_name  ,  p_api_icc_rec.Catalog_Group_Name );
      x_icc_rec.parent_catalog_group_name  := NVL(x_icc_rec.parent_catalog_group_name,  p_api_icc_rec.Parent_Catalog_Group_Name );
      x_icc_rec.item_catalog_group_id      := NVL(x_icc_rec.item_catalog_group_id  ,  p_api_icc_rec.Catalog_Group_Id );
      x_icc_rec.parent_catalog_group_id    := NVL(x_icc_rec.parent_catalog_group_id  ,  p_api_icc_rec.Parent_Catalog_Group_Id );
      x_icc_rec.Description                := NVL(x_icc_rec.Description  ,  p_api_icc_rec.Description );
      x_icc_rec.Item_Creation_Allowed_Flag := NVL(x_icc_rec.Item_Creation_Allowed_Flag  ,  p_api_icc_rec.Item_Creation_Allowed_Flag );
      x_icc_rec.start_date_active          := NVL(x_icc_rec.start_date_active  ,  p_api_icc_rec.Start_Effective_Date );
      x_icc_rec.Inactive_Date              := NVL(x_icc_rec.Inactive_Date  ,  p_api_icc_rec.Inactive_Date );
      x_icc_rec.Enabled_Flag               := NVL(x_icc_rec.Enabled_Flag  ,  p_api_icc_rec.Enabled_Flag );
      x_icc_rec.Summary_Flag               := NVL(x_icc_rec.Summary_Flag  ,  p_api_icc_rec.Summary_Flag );
      x_icc_rec.segment1                   := NVL(x_icc_rec.segment1  ,  p_api_icc_rec.segment1 );
      x_icc_rec.segment2                   := NVL(x_icc_rec.segment2  ,  p_api_icc_rec.segment2 );
      x_icc_rec.segment3                   := NVL(x_icc_rec.segment3  ,  p_api_icc_rec.segment3 );
      x_icc_rec.segment4                   := NVL(x_icc_rec.segment4  ,  p_api_icc_rec.segment4 );
      x_icc_rec.segment5                   := NVL(x_icc_rec.segment5  ,  p_api_icc_rec.segment5 );
      x_icc_rec.segment6                   := NVL(x_icc_rec.segment6  ,  p_api_icc_rec.segment6 );
      x_icc_rec.segment7                   := NVL(x_icc_rec.segment7  ,  p_api_icc_rec.segment7 );
      x_icc_rec.segment8                   := NVL(x_icc_rec.segment8  ,  p_api_icc_rec.segment8 );
      x_icc_rec.segment9                   := NVL(x_icc_rec.segment9  ,  p_api_icc_rec.segment9 );
      x_icc_rec.segment10                  := NVL(x_icc_rec.segment10  ,  p_api_icc_rec.segment10 );
      x_icc_rec.segment11                  := NVL(x_icc_rec.segment11  ,  p_api_icc_rec.segment11 );
      x_icc_rec.segment12                  := NVL(x_icc_rec.segment12  ,  p_api_icc_rec.segment12 );
      x_icc_rec.segment13                  := NVL(x_icc_rec.segment13  ,  p_api_icc_rec.segment13 );
      x_icc_rec.segment14                  := NVL(x_icc_rec.segment14  ,  p_api_icc_rec.segment14 );
      x_icc_rec.segment15                  := NVL(x_icc_rec.segment15  ,  p_api_icc_rec.segment15 );
      x_icc_rec.segment16                  := NVL(x_icc_rec.segment16  ,  p_api_icc_rec.segment16 );
      x_icc_rec.segment17                  := NVL(x_icc_rec.segment17  ,  p_api_icc_rec.segment17 );
      x_icc_rec.segment18                  := NVL(x_icc_rec.segment18  ,  p_api_icc_rec.segment18 );
      x_icc_rec.segment19                  := NVL(x_icc_rec.segment19  ,  p_api_icc_rec. segment19 );
      x_icc_rec.segment20                  := NVL(x_icc_rec.segment20  ,  p_api_icc_rec.segment20 );
      x_icc_rec.Attribute_category         := NVL(x_icc_rec.Attribute_category  ,  p_api_icc_rec.Attribute_category );
      x_icc_rec.Attribute1                 := NVL(x_icc_rec.Attribute1  ,  p_api_icc_rec.Attribute1 );
      x_icc_rec.Attribute2                 := NVL(x_icc_rec.Attribute2  ,  p_api_icc_rec.Attribute2 );
      x_icc_rec.Attribute3                 := NVL(x_icc_rec.Attribute3  ,  p_api_icc_rec.Attribute3 );
      x_icc_rec.Attribute4                 := NVL(x_icc_rec.Attribute4  ,  p_api_icc_rec.Attribute4 );
      x_icc_rec.Attribute5                 := NVL(x_icc_rec.Attribute5  ,  p_api_icc_rec.Attribute5 );
      x_icc_rec.Attribute6                 := NVL(x_icc_rec.Attribute6  ,  p_api_icc_rec.Attribute6 );
      x_icc_rec.Attribute7                 := NVL(x_icc_rec.Attribute7  ,  p_api_icc_rec.Attribute7 );
      x_icc_rec.Attribute8                 := NVL(x_icc_rec.Attribute8  ,  p_api_icc_rec.Attribute8 );
      x_icc_rec.Attribute9                 := NVL(x_icc_rec.Attribute9  ,  p_api_icc_rec.Attribute9 );
      x_icc_rec.Attribute10                := NVL(x_icc_rec.Attribute10  ,  p_api_icc_rec.Attribute10 );
      x_icc_rec.Attribute11                := NVL(x_icc_rec.Attribute11  ,  p_api_icc_rec.Attribute11 );
      x_icc_rec.Attribute12                := NVL(x_icc_rec.Attribute12  ,  p_api_icc_rec.Attribute12 );
      x_icc_rec.Attribute13                := NVL(x_icc_rec.Attribute13  ,  p_api_icc_rec.Attribute13 );
      x_icc_rec.Attribute14                := NVL(x_icc_rec.Attribute14  ,  p_api_icc_rec.Attribute14 );
      x_icc_rec.Attribute15                := NVL(x_icc_rec.Attribute15  ,  p_api_icc_rec.Attribute15 );

                                        --p_api_icc_rec.Return_Status

  END IF;

  write_debug(l_proc_name, 'End');
END Convert_API_type_to_intf_rec;



/******************************************************************

--- Procedure to log an error message for an entity as a whole
--- when the entity fails because of error in existing APIs being
--- re-used
---

*******************************************************************/

PROCEDURE Log_Error_For_Entity_Rec  ( p_entity_name   IN VARCHAR2
                                     ,p_trans_type    IN NUMBER
                                     ,p_pkg_name      IN VARCHAR2
                                     ,p_proc_name     IN VARCHAR2
                                     ,p_entity_code   IN VARCHAR2
                                     ,p_table_name    IN VARCHAR2
                                     ,p_transaction_id IN VARCHAR2
                                     ,p_message_name   IN VARCHAR2 DEFAULT 'EGO_ENTITY_API_FAILED'
                                    )
IS
  l_proc_name  VARCHAR2(40) := 'Log_Error_For_Entity_Rec';

BEGIN



  NULL;

 /*

G_TOKEN_TBL(1).Token_Name   :=  'Entity_Name';
                G_TOKEN_TBL(1).Token_Value  :=  G_ENTITY_ICC_HEADER;
                G_TOKEN_TBL(2).Token_Name   :=  'Transaction_Type';
                G_TOKEN_TBL(2).Token_Value  :=  P_pg_tbl(i).transaction_type;
                G_TOKEN_TBL(3).Token_Name   :=  'Package_Name';
                G_TOKEN_TBL(3).Token_Value  :=  'ego_ext_fwk_pub';
                G_TOKEN_TBL(4).Token_Name   :=  'Proc_Name';
                G_TOKEN_TBL(4).Token_Value  :=  'Create_page';

                error_handler.Add_error_message(p_message_name => 'EGO_ENTITY_API_FAILED',p_application_id => G_EGO_APPLICATION_ID,
                                                p_token_tbl => g_token_table,p_message_type => G_RET_STS_ERROR,
                                                p_row_identifier => p_icc_rec.transaction_id,
                                                p_entity_code => G_ENTITY_ICC_HEADER,p_table_name => G_ENTITY_ICC_HEADER_TAB);

                G_TOKEN_TBL.DELETE;

*/

END Log_Error_For_Entity_Rec;



/********************************************************************
---
---   This procedure creates/updates/deletes the action id associated with
---   number generation and desc generation columns in the ICC header record
---
********************************************************************/

Procedure Process_Function_Actions (  p_operation       IN VARCHAR2
                                     ,p_function_id      IN NUMBER DEFAULT NULL
                                     ,p_icc_id           IN NUMBER DEFAULT NULL
                                     ,p_transaction_id   IN NUMBER  DEFAULT NULL
                                     ,p_enable_key_attrs IN VARCHAR2 DEFAULT NULL
                                     ,p_action_id        IN NUMBER DEFAULT NULL
                                     ,x_action_id     OUT NOCOPY NUMBER
                                     ,x_return_status OUT NOCOPY VARCHAR2
                                     ,x_return_msg    OUT NOCOPY VARCHAR2
                                    )
IS
  l_proc_name    VARCHAR2(30) := 'Process_Function_Actions';
  l_sequence     NUMBER := 100;
  l_action_name  EGO_ACTIONS_B.action_name%TYPE := 'ItemRequestProcessAction';
  l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_AG_ASSOC;
  l_object_id   fnd_objects.object_id%TYPE;
  l_association_id  ego_obj_ag_assocs_b.association_id%TYPE;

  l_msg_count           NUMBER := 0;
  l_error_code          NUMBER := 0;

  e_skip_record         EXCEPTION;
  e_unexpected_error    EXCEPTION;

  l_token_table     ERROR_HANDLER.Token_Tbl_Type;
  l_msg_data        VARCHAR2(4000);

BEGIN
  x_return_status := G_RET_STS_SUCCESS;
  write_debug (l_proc_name, 'Start');



    FOR rec_obj_id IN cur_get_obj_id loop
      l_object_id := rec_obj_id.object_id;
    end loop;

  IF p_operation = G_TTYPE_CREATE THEN

          EGO_EXT_FWK_PUB.Create_Action (
           p_api_version           => 1.0
          ,p_object_id             => l_object_id
          ,p_classification_code   => to_char( p_icc_id)
          ,p_attr_group_id         => NULL
          ,p_sequence              => l_sequence
          ,p_action_name           => l_action_name
          ,p_description           => null
          ,p_function_id           => p_function_id
          ,p_enable_key_attrs      => p_enable_key_attrs
          ,p_security_privilege_id => NULL
          ,p_init_msg_list         => FND_API.G_false
          ,p_commit                => FND_API.G_FALSE
          ,x_action_id             => x_action_id
          ,x_return_status         => x_return_status
          ,x_errorcode             => l_error_code
          ,x_msg_count             => l_msg_count
          ,x_msg_data              => x_return_msg
                                  );
       write_debug(l_proc_name, 'action id =>'||x_action_id);
       IF x_return_status = G_RET_STS_SUCCESS THEN

        EGO_EXT_FWK_PUB.Create_Action_Display (
                p_api_version     => 1.0
               ,p_action_id       => x_action_id
               ,p_trigger_code    => NULL
               ,p_init_msg_list   => fnd_api.g_FALSE
               ,p_commit          => fnd_api.g_FALSE
               ,x_return_status   => x_return_status
               ,x_errorcode       => l_error_code
               ,x_msg_count       => l_msg_count
               ,x_msg_data        => x_return_msg
                       );
            write_debug(l_proc_name, 'action display ret status =>'||x_action_id);
            IF x_return_status = G_RET_STS_ERROR THEN
                  ERROR_HANDLER.Add_Error_Message(
                    p_message_text                  => x_return_msg
                   ,p_application_id                => G_APPL_NAME
                   ,p_row_identifier                => p_transaction_id
                   ,p_entity_code                   => l_entity_code
                   ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                   );

            ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
               write_debug(l_proc_name, 'CREATE action=>'||x_return_msg);
               RAISE e_unexpected_error;
            END IF;


       ELSIF x_return_status = G_RET_STS_ERROR THEN

              ERROR_HANDLER.Add_Error_Message(
                p_message_text                  => x_return_msg
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );

       ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
         write_debug(l_proc_name, 'CREATE action=>'||x_return_msg);
         RAISE e_unexpected_error;
       END IF;

  ELSIF p_operation = G_TTYPE_UPDATE THEN

            EGO_EXT_FWK_PUB.Update_Action (
             p_api_version           => 1.0
            ,p_action_id             => p_action_id
            ,p_sequence              => l_sequence
            ,p_action_name           => l_action_name
            ,p_description           => null
            ,p_function_id           => p_function_id
            ,p_enable_key_attrs      => p_enable_key_attrs
            ,p_security_privilege_id => null
            ,p_init_msg_list         => FND_API.G_false
            ,p_commit                => FND_API.G_FALSE
            ,x_return_status         => x_return_status
            ,x_errorcode             => l_error_code
            ,x_msg_count             => l_msg_count
            ,x_msg_data              => x_return_msg
                                    );
                 write_debug(l_proc_name, 'action update func id=>'||p_function_id);
                 IF x_return_status = G_RET_STS_ERROR THEN

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => x_return_msg
                       ,p_application_id                => G_APPL_NAME
                       ,p_row_identifier                => p_transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );

               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 write_debug(l_proc_name, 'UPDATE action=>'||x_return_msg);
                 RAISE e_unexpected_error;
               END IF;


  ELSIF p_operation = G_TTYPE_DELETE THEN

        EGO_EXT_FWK_PUB.Delete_Action (
          p_api_version   => 1.0
         ,p_action_id     => p_action_id
         ,p_init_msg_list => FND_API.g_false
         ,p_commit        => FND_API.g_false
         ,x_return_status => x_return_status
         ,x_errorcode     => l_error_code
         ,x_msg_count     => l_msg_count
         ,x_msg_data      =>  x_return_msg
          );

        IF x_return_status  = G_RET_STS_SUCCESS THEN

               EGO_EXT_FWK_PUB.Delete_Action_Display (
                p_api_version        => 1.0
               ,p_action_id          => p_action_id
               ,p_init_msg_list      => FND_API.g_false
               ,p_commit             => FND_API.g_false
               ,x_return_status      => x_return_status
               ,x_errorcode          => l_error_code
               ,x_msg_count          => l_msg_count
               ,x_msg_data           =>  x_return_msg
                                    );
                 write_debug(l_proc_name, 'action DELETE STS=>'||x_return_status);
                 IF x_return_status = G_RET_STS_ERROR THEN

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => x_return_msg
                       ,p_application_id                => G_APPL_NAME
                       ,p_row_identifier                => p_transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );
                 ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                   write_debug(l_proc_name, 'delete action=>'||x_return_msg);
                   RAISE e_unexpected_error;
                 END IF;

        ELSIF x_return_status = G_RET_STS_ERROR THEN

                  ERROR_HANDLER.Add_Error_Message(
                    p_message_text                  => x_return_msg
                   ,p_application_id                => G_APPL_NAME
                   ,p_row_identifier                => p_transaction_id
                   ,p_entity_code                   => l_entity_code
                   ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                   );

        ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
             write_debug(l_proc_name, 'DELETE action=>'||x_return_msg);
             RAISE e_unexpected_error;
        END IF;

  END IF;  --for operation type

  write_debug(l_proc_name, 'End');
EXCEPTION
   WHEN e_unexpected_error THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := x_return_msg||'Stop process error occured in '||G_PKG_NAME||'.'||l_proc_name;
      write_debug(l_proc_name, x_return_msg);
   WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Process_Function_Actions;



/********************************************************************
---
---   This procedure calls the relevant procedures for function related
---   information update to the ICC
---
********************************************************************/

PROCEDURE Create_Action_for_Func   ( p_icc_rec IN OUT NOCOPY ego_icc_rec_type
                                    ,x_return_status OUT NOCOPY VARCHAR2
                                    ,x_return_msg    OUT NOCOPY VARCHAR2
                                    )

IS

  l_proc_name        VARCHAR2(30) := 'Create_Action_for_Func';
  l_entity_code      VARCHAR2(50) := G_ENTITY_ICC_HEADER;
  l_object_id        FND_OBJECTS.object_id%TYPE := null;
  l_action_id        ego_actions_b.action_id%TYPE := null;
  l_old_num_func_id  ego_actions_b.function_id%TYPE := NULL;
  l_old_desc_func_id ego_actions_b.function_id%TYPE := NULL;
  e_unexpected_error EXCEPTION;
  l_seq_name         VARCHAR2(30) := NULL;

  CURSOR cur_get_action ( p_function_id number
                         ,p_icc_id      number
                         ,p_object_id   number
                        )
  IS
  SELECT action_id
  FROM   ego_actions_b
  WHERE function_id = p_function_id
  and   classification_code = to_char(p_icc_id)
  and   object_id = p_object_id
  ;

  CURSOR cur_get_function ( p_action_id number
                         ,p_icc_id      number
                         ,p_object_id   number
                        )
  IS
  SELECT function_id, enable_key_attributes
  FROM   ego_actions_b
  WHERE action_id = p_action_id
  and   classification_code = to_char(p_icc_id)
  and   object_id = p_object_id
  ;

      ---
      --- Inline Procedure to create number generation method
      ---
      PROCEDURE Create_Num_Gen_Method
      IS
      BEGIN
            Process_Function_Actions (  p_operation        => G_TTYPE_CREATE
                                       ,p_function_id      => p_icc_rec.item_num_function_id
                                       ,p_icc_id           => p_icc_rec.item_catalog_group_id
                                       ,p_transaction_id   => p_icc_rec.transaction_id
                                       ,p_enable_key_attrs => p_icc_rec.enable_key_attrs_num
                                       ,p_action_id        => null
                                       ,x_action_id        => p_icc_rec.item_num_action_id
                                       ,x_return_status    => x_return_status
                                       ,x_return_msg       => x_return_msg
                                   );
            IF x_return_status = G_RET_STS_ERROR THEN

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => x_return_msg
                       ,p_application_id                => G_APPL_NAME

                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );

            ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
            END IF;
      END Create_Num_Gen_Method;


      ---
      --- Inline Procedure to create description generation method
      ---
      PROCEDURE Create_Desc_Gen_Method
      IS
      BEGIN
            Process_Function_Actions (  p_operation        => G_TTYPE_CREATE
                                       ,p_function_id      => p_icc_rec.item_desc_function_id
                                       ,p_icc_id           => p_icc_rec.item_catalog_group_id
                                       ,p_transaction_id   => p_icc_rec.transaction_id
                                       ,p_enable_key_attrs => p_icc_rec.enable_key_attrs_desc
                                       ,p_action_id        => null
                                       ,x_action_id        => p_icc_rec.item_desc_action_id
                                       ,x_return_status    => x_return_status
                                       ,x_return_msg       => x_return_msg
                                   );
            IF x_return_status = G_RET_STS_ERROR THEN

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => x_return_msg
                       ,p_application_id                => G_APPL_NAME

                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );

            ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
            END IF;
      END Create_Desc_Gen_Method;




      ---
      --- Inline Procedure to delete old number generation method
      ---
      PROCEDURE Delete_Old_Num_Gen_Method
      IS
      BEGIN
                      Process_Function_Actions (  p_operation        => G_TTYPE_DELETE    --- delete the earlier action associated
                                                 ,p_function_id      => l_old_num_func_id
                                                 ,p_icc_id           => g_old_icc_rec.item_catalog_group_id
                                                 ,p_transaction_id   => p_icc_rec.transaction_id
                                                 ,p_enable_key_attrs => NULL
                                                 ,p_action_id        => g_old_icc_rec.ITEM_NUM_ACTION_ID
                                                 ,x_action_id        => l_action_id   --- dummy
                                                 ,x_return_status    => x_return_status
                                                 ,x_return_msg       => x_return_msg
                                             );
                          IF x_return_status = G_RET_STS_ERROR THEN
                                    ERROR_HANDLER.Add_Error_Message(
                                      p_message_text                  => x_return_msg
                                     ,p_application_id                => G_APPL_NAME
                                     ,p_row_identifier                => p_icc_rec.transaction_id
                                     ,p_entity_code                   => l_entity_code
                                     ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                                     );
                          ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                               RAISE e_unexpected_error;
                          END IF;  ---error handling


      END Delete_Old_Num_Gen_Method;


      ---
      --- Inline Procedure to delete old description generation method
      ---
      PROCEDURE Delete_Old_Desc_Gen_Method
      IS
      BEGIN
                      Process_Function_Actions (  p_operation        => G_TTYPE_DELETE    --- delete the earlier action associated
                                                 ,p_function_id      => l_old_desc_func_id
                                                 ,p_icc_id           => g_old_icc_rec.item_catalog_group_id
                                                 ,p_transaction_id   => p_icc_rec.transaction_id
                                                 ,p_enable_key_attrs => p_icc_rec.enable_key_attrs_num
                                                 ,p_action_id        => g_old_icc_rec.ITEM_DESC_ACTION_ID
                                                 ,x_action_id        => l_action_id   --- dummy
                                                 ,x_return_status    => x_return_status
                                                 ,x_return_msg       => x_return_msg
                                             );
                          IF x_return_status = G_RET_STS_ERROR THEN
                                    ERROR_HANDLER.Add_Error_Message(
                                      p_message_text                  => x_return_msg
                                     ,p_application_id                => G_APPL_NAME
                                     ,p_row_identifier                => p_icc_rec.transaction_id
                                     ,p_entity_code                   => l_entity_code
                                     ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                                     );
                          ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                               RAISE e_unexpected_error;
                          END IF;  ---error handling


      END Delete_Old_Desc_Gen_Method;



BEGIN
  write_debug (l_proc_name, 'Start');
  x_return_status := G_RET_STS_SUCCESS;


  FOR rec_obj_id IN cur_get_obj_id
  loop
    l_object_id := rec_obj_id.object_id;
  end loop;


  --- Get the details of the existing ICC for
  --- UPDATE transaction
  ---
  IF p_icc_rec.transaction_type = G_TTYPE_UPDATE THEN

    --- Get the existing number generation function id
    ---

    FOR rec_get_function IN  cur_get_function (   g_old_icc_rec.item_num_action_id
                                                , g_old_icc_rec.item_catalog_group_id
                                                , l_object_id
                                              ) LOOP
      l_old_num_func_id := rec_get_function.function_id;
      p_icc_rec.enable_key_attrs_num  := rec_get_function.enable_key_attributes;
      write_debug(l_proc_name, 'old num gen func id=>'||l_old_num_func_id);

    END LOOP;

    --- Get the existing description generation function id
    ---

    FOR rec_get_function IN  cur_get_function (   g_old_icc_rec.item_desc_action_id
                                                , g_old_icc_rec.item_catalog_group_id
                                                , l_object_id
                                              ) LOOP
      l_old_desc_func_id := rec_get_function.function_id;
      p_icc_rec.enable_key_attrs_desc  := rec_get_function.enable_key_attributes;
      write_debug(l_proc_name, 'old desc gen func id=>'||l_old_desc_func_id);
    END LOOP;


  END IF;

  --- *******************
  --- CREATE transaction
  --- *******************
  IF p_icc_rec.transaction_type = G_TTYPE_CREATE THEN
          ---- CREATE for Number generation
          ----
          IF p_icc_rec.item_num_gen_method_type = 'F' THEN
             write_debug(l_proc_name, ' creating number generation action ');
             Create_Num_Gen_Method;
          END IF;

          ---- CREATE for description
          ----
          IF p_icc_rec.item_desc_gen_method_type = 'F'  THEN
             write_debug(l_proc_name, ' creating description generation action ');
             Create_Desc_Gen_Method;
          END IF;

          IF p_icc_rec.item_num_gen_method_type = 'S'  THEN
             write_debug(l_proc_name, ' creating sequence ');
             Generate_Seq_For_Item_Catalog (
                   p_icc_id                  => p_icc_rec.item_catalog_group_id
                  ,p_seq_start_num           => p_icc_rec.starting_number
                  ,p_seq_increment_by        => p_icc_rec.increment_by
                  ,x_seq_name                => l_seq_name
                  ,x_return_status           => x_return_status
                  ,x_return_msg              => x_return_msg
                    );
              write_debug(l_proc_name, ' creating sequence status =>'||x_return_status);
              IF x_return_status = G_RET_STS_SUCCESS THEN
                p_icc_rec.item_num_seq_name := l_seq_name;
              END IF;
          END IF;

 END IF;


 -----******************
 --- UPDATE transaction
 ----*******************

 IF p_icc_rec.transaction_type = G_TTYPE_UPDATE THEN
      write_debug(l_proc_name, 'UPDATE transaction');

      ---*******************
      ---- Number generation
      ---- when new method is FUNCTION generated

      IF p_icc_rec.item_num_gen_method_type = 'F' THEN
            write_debug(l_proc_name, 'UPDATE transaction 1');
            ---
            --- User attempting to add a number generation function
            ---
            IF g_old_icc_rec.item_num_gen_method IN ('U', 'I') THEN

                write_debug(l_proc_name, 'create of action func id=>'||p_icc_rec.item_num_function_id);
                Create_Num_Gen_Method;

            ---
            --- Old is function generated and user is trying to update it
            ---
            ELSIF g_old_icc_rec.item_num_gen_method = 'F' AND (l_old_num_func_id <> p_icc_rec.item_num_function_id ) THEN
                --- user attempting to change the function associated
                ---
                write_debug(l_proc_name, 'update of action NUM func id=>'||p_icc_rec.item_num_function_id);

                Process_Function_Actions (  p_operation        => G_TTYPE_UPDATE
                                           ,p_function_id      => p_icc_rec.item_num_function_id
                                           ,p_icc_id           => p_icc_rec.item_catalog_group_id
                                           ,p_transaction_id   => p_icc_rec.transaction_id
                                           ,p_enable_key_attrs => p_icc_rec.enable_key_attrs_num
                                           ,p_action_id        => g_old_icc_rec.item_num_action_id
                                           ,x_action_id        => p_icc_rec.item_num_action_id
                                           ,x_return_status    => x_return_status
                                           ,x_return_msg       => x_return_msg
                                       );
                IF x_return_status = G_RET_STS_ERROR THEN

                          ERROR_HANDLER.Add_Error_Message(
                            p_message_text                  => x_return_msg
                           ,p_application_id                => G_APPL_NAME
                           ,p_row_identifier                => p_icc_rec.transaction_id
                           ,p_entity_code                   => l_entity_code
                           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                           );

                ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE e_unexpected_error;
                END IF;

            ---
            --- if old method was sequence generated then
            ---
            ELSIF g_old_icc_rec.item_num_gen_method = 'S' THEN

                      write_debug ( l_proc_name, 'dropping sequence =>'||g_old_icc_rec.item_num_seq_name);
                      Drop_Sequence_For_Item_Catalog (
                                p_item_catalog_seq_name => g_old_icc_rec.item_num_seq_name
                               ,x_return_status         => x_return_status
                               ,x_return_msg            => x_return_msg
                                );
                      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                        RAISE e_unexpected_error;
                      END IF;  ---error handling

                      write_debug(l_proc_name, 'create of action func id=>'||p_icc_rec.item_num_function_id);
                      Create_Num_Gen_Method;
            END IF;

      ---
      --- If new method is S' U OR I
      ELSIF p_icc_rec.item_num_gen_method_type IN ( 'U', 'S' , 'I' ) THEN

             write_debug(l_proc_name, 'UPDATE transaction 2');
             --- delete if it was function earlier
             ---
             IF g_old_icc_rec.item_num_gen_method = 'F' THEN
               Delete_Old_Num_Gen_Method;
             END IF;

             IF  g_old_icc_rec.item_num_gen_method = 'S'
                  AND
                  (  g_old_icc_rec.prefix          <> p_icc_rec.prefix
                  OR g_old_icc_rec.starting_number <> p_icc_rec.starting_number
                  OR g_old_icc_rec.increment_by    <> p_icc_rec.increment_by
                  OR g_old_icc_rec.suffix          <> p_icc_rec.suffix
                  ) THEN

                  write_debug ( l_proc_name, 'dropping old sequence =>'||g_old_icc_rec.item_num_seq_name);
                  Drop_Sequence_For_Item_Catalog (
                            p_item_catalog_seq_name => g_old_icc_rec.item_num_seq_name
                           ,x_return_status         => x_return_status
                           ,x_return_msg            => x_return_msg
                            );
                  IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                    RAISE e_unexpected_error;
                  END IF;
                  --- new sequence will be created below
              END IF;


             IF p_icc_rec.item_num_gen_method_type = 'S' THEN
                 write_debug(l_proc_name, 'creating sequence ');
                 Generate_Seq_For_Item_Catalog (
                       p_icc_id                  => p_icc_rec.item_catalog_group_id
                      ,p_seq_start_num           => p_icc_rec.starting_number
                      ,p_seq_increment_by        => p_icc_rec.increment_by
                      ,x_seq_name                => l_seq_name
                      ,x_return_status           => x_return_status
                      ,x_return_msg              => x_return_msg
                        );
                  write_debug(l_proc_name, ' creating sequence status =>'||x_return_status);
                  IF x_return_status = G_RET_STS_SUCCESS THEN
                    p_icc_rec.item_num_seq_name := l_seq_name;
                  END IF;
             END IF;
      END IF;   --- New Method Type for number generation
      ---- Number generation End
      ---*******************


      ---*******************
      ---- Description  generation Start

      IF p_icc_rec.item_desc_gen_method_type = 'F' THEN

          write_debug(l_proc_name, 'transaction 2');
          IF g_old_icc_rec.item_desc_gen_method IN ('U','I') THEN
            write_debug(l_proc_name, 'transaction 3');
            Create_Desc_Gen_Method;

          ELSIF g_old_icc_rec.item_desc_gen_method = 'F' AND (l_old_desc_func_id <> p_icc_rec.item_desc_function_id) THEN
                write_debug(l_proc_name, 'Old desc function id  present , updating action');
                Process_Function_Actions (  p_operation        => G_TTYPE_UPDATE
                                           ,p_function_id      => p_icc_rec.item_desc_function_id
                                           ,p_icc_id           => p_icc_rec.item_catalog_group_id
                                           ,p_transaction_id   => p_icc_rec.transaction_id
                                           ,p_enable_key_attrs => p_icc_rec.enable_key_attrs_num
                                           ,p_action_id        => g_old_icc_rec.item_desc_action_id
                                           ,x_action_id        => p_icc_rec.item_desc_action_id
                                           ,x_return_status    => x_return_status
                                           ,x_return_msg       => x_return_msg
                                       );
                IF x_return_status = G_RET_STS_ERROR THEN
                          ERROR_HANDLER.Add_Error_Message(
                            p_message_text                  => x_return_msg
                           ,p_application_id                => G_APPL_NAME
                           ,p_row_identifier                => p_icc_rec.transaction_id
                           ,p_entity_code                   => l_entity_code
                           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                           );

                ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE e_unexpected_error;
                END IF;


          END IF;

      ELSIF p_icc_rec.item_desc_gen_method_type IN  ('U', 'I') THEN

          IF p_icc_rec.item_desc_gen_method_type = 'F' THEN
            Delete_Old_Desc_Gen_Method;
          END IF;

      END IF;
      ---
      ---- Description  generation End
      ---*******************
  END IF;
  ---
  --- UPDATE transaction End if
  ----*******************

  write_debug (l_proc_name, 'End');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Create_Action_for_Func;


/********************************************************************
---
---   This procedure updates the Item number Generation and
---   desc generation columns in the ICC header table
---   this procedure is called when all the paameters are not mapped
---   and the function needs to be removed from the ICC header
---
********************************************************************/

PROCEDURE  Update_Func_ICC_Hdr_Cols  (  p_col_name    IN VARCHAR2
                                       ,p_icc_id      IN NUMBER
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_return_msg  OUT NOCOPY VARCHAR2
                                      )
is
  l_proc_name    VARCHAR2(30) := 'Update_Func_ICC_Hdr_Cols';
begin
  x_return_status := G_RET_STS_SUCCESS;
  write_debug (l_proc_name, 'Start');


  UPDATE MTL_ITEM_CATALOG_GROUPS_B
  SET
      ITEM_NUM_ACTION_ID          = decode ( p_col_name, G_NUM_GEN_FUNCTION , null, ITEM_NUM_ACTION_ID)
    , ITEM_DESC_ACTION_ID         = decode ( p_col_name, G_DESC_GEN_FUNCTION , null, ITEM_DESC_ACTION_ID)
    ,last_updated_by        =   G_USER_ID
    ,last_update_date       =   SYSDATE
    ,last_update_login      =   G_LOGIN_ID
  WHERE   item_catalog_group_id = p_icc_id
  ;


  write_debug (l_proc_name, 'End');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Update_Func_ICC_Hdr_Cols;




/********************************************************************
---
---   This procedure updates the NIR related columns , Item number Generation and
---   desc generation columns in the ICC header table
---
********************************************************************/

 PROCEDURE Update_Other_ICC_Hdr_Cols  ( p_icc_rec IN ego_icc_rec_type
                                       ,x_return_status OUT NOCOPY VARCHAR2
                                       ,x_return_msg  OUT NOCOPY VARCHAR2
                                      )
is
  l_proc_name    VARCHAR2(30) := 'Update_Other_ICC_Hdr_Cols';
begin
  x_return_status := G_RET_STS_SUCCESS;
  write_debug (l_proc_name, 'Start');


  UPDATE MTL_ITEM_CATALOG_GROUPS_B
  SET
      ITEM_NUM_GEN_METHOD         = p_icc_rec.item_num_gen_method_type
     ,PREFIX                      = p_icc_rec.prefix
     ,STARTING_NUMBER             = p_icc_rec.starting_number
    , INCREMENT_BY                = p_icc_rec.increment_by
    , SUFFIX                      = p_icc_rec.suffix
    , ITEM_NUM_SEQ_NAME           = p_icc_rec.item_num_seq_name
    , ITEM_NUM_ACTION_ID          = p_icc_rec.item_num_action_id
    , ITEM_DESC_GEN_METHOD        = p_icc_rec.item_desc_gen_method_type
    , ITEM_DESC_ACTION_ID         = p_icc_rec.item_desc_action_id
    , NEW_ITEM_REQUEST_REQD       = p_icc_rec.new_item_request_type
    , NEW_ITEM_REQ_CHANGE_TYPE_ID = p_icc_rec.new_item_req_change_type_id
    --, ITEM_NUM_SEQ_NAME
    ,last_updated_by        =   G_USER_ID
    ,last_update_date       =   SYSDATE
    ,last_update_login      =   G_LOGIN_ID
  WHERE   item_catalog_group_id = p_icc_rec.item_catalog_group_id
  ;


  write_debug (l_proc_name, 'End');
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Update_Other_ICC_Hdr_Cols;



     --- required, when processing per ICC
     ---
  PROCEDURE update_icc_id_name ( p_icc_name   IN VARCHAR2, p_icc_id IN NUMBER)
  IS

     l_proc_name   VARCHAR2(50) :=  'update_icc_id_name';
   BEGIN

   write_debug(l_proc_name, 'updating  name');
   UPDATE EGO_ICC_VERS_INTERFACE  eivi
        SET    eivi.item_catalog_name = ( select icc_kfv.concatenated_segments
                                     from   mtl_item_catalog_groups_kfv icc_kfv
                                     where icc_kfv.item_catalog_group_id = eivi.item_catalog_group_id
                                   )
        WHERE  eivi.item_catalog_group_id = p_icc_id
        AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
        AND  (
               ( G_SET_PROCESS_ID IS NULL )
                 OR
               ( eivi.set_process_id =  G_SET_PROCESS_ID)
            )           ;

   write_debug(l_proc_name, 'updating  NAME=>'||SQL%ROWCOUNT);


   write_debug(l_proc_name, 'updating  id');

        UPDATE ego_icc_vers_interface eivi
        SET    eivi.item_catalog_group_id = ( select icc_kfv.item_catalog_group_id
                                               from   mtl_item_catalog_groups_kfv icc_kfv
                                               where icc_kfv.concatenated_segments = eivi.item_catalog_name
                                             )
        WHERE eivi.item_catalog_name = P_ICC_NAME
        AND   eivi.item_catalog_group_id IS NULL
        AND   eivi.process_status = G_PROCESS_STATUS_INITIAL
        AND  (
               ( G_SET_PROCESS_ID IS NULL )
                 OR
               ( eivi.set_process_id =  G_SET_PROCESS_ID)
            )
        ;
        write_debug(l_proc_name, 'updating  id=>'||SQL%ROWCOUNT);

     END update_icc_id_name;



/********************************************************************
---
---   This procedure calls the relevant procedures for actual ICC create/update
---   if creation is successful,
---
********************************************************************/


   PROCEDURE Create_ICC (   p_icc_rec       IN OUT NOCOPY ego_icc_rec_type
                              ,x_return_status OUT NOCOPY VARCHAR2
                              ,x_return_msg  OUT NOCOPY VARCHAR2
                            )
   is

     l_proc_name   VARCHAR2(30) := 'Create_ICC';

     l_api_icc_rec   EGO_ITEM_CATALOG_PUB.Catalog_Group_Rec_Type := null;
     l_api_icc_tbl   EGO_ITEM_CATALOG_PUB.Catalog_Group_Tbl_Type;
     x_api_icc_tbl   EGO_ITEM_CATALOG_PUB.Catalog_Group_Tbl_Type;

     l_grant_guid    fnd_grants.grant_guid%TYPE;

     x_message_list        Error_Handler.Error_Tbl_Type;
     l_message_count       NUMBER := 0;
     l_error_code          NUMBER := 0;

     e_skip_record         EXCEPTION;
     e_stop_processing     EXCEPTION;

     l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_HEADER;
     l_token_table     ERROR_HANDLER.Token_Tbl_Type;
     l_count           NUMBER;
     e_unexpected_error EXCEPTION;



   BEGIN
     ---
     --- Start the savepoint
     ---
     SAVEPOINT ICC_CREATE_START;

     write_debug(l_proc_name, 'Start ');
     x_return_status := G_RET_STS_SUCCESS;


     IF p_icc_rec.transaction_type = G_TTYPE_CREATE THEN

         Attribute_Defaulting (  p_entity         => G_ENTITY_ICC_HEADER
                               , p_icc_rec        => p_icc_rec
                               , p_ag_assoc_rec   => g_null_ag_assoc_rec
                               , p_func_param_assoc_rec => g_null_func_params_rec
                               , p_icc_ver_rec    => g_null_icc_vers_rec
                               , x_return_status  => x_return_status
                               , x_return_msg     => x_return_msg
                              );
         IF x_return_status = G_RET_STS_ERROR THEN

            write_debug('Attribute_Defaulting', 'Error Messages :');
              ERROR_HANDLER.Add_Error_Message(
                   p_message_text                  => x_return_msg
                  ,p_application_id                => G_APPL_NAME

                  ,p_row_identifier                => p_icc_rec.transaction_id
                  ,p_entity_code                   => l_entity_code
                  ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                 );
             RAISE e_skip_record;
         ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE e_skip_record;    --- G_RET_STS_UNEXP_ERROR Handled in caller
         END IF;
     END IF;


     IF p_icc_rec.transaction_type = G_TTYPE_UPDATE THEN

         Populate_Null_Cols   (  p_entity         => G_ENTITY_ICC_HEADER
                               , p_icc_rec        => p_icc_rec
                               , p_ag_assoc_rec   => g_null_ag_assoc_rec
                               , p_func_param_assoc_rec => g_null_func_params_rec
                               , x_return_status  => x_return_status
                               , x_return_msg     => x_return_msg
                              );
              IF x_return_status = G_RET_STS_ERROR  THEN

                 write_debug('Populate_Null_Cols', 'Error Messages :');
                   ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => x_return_msg
                       ,p_application_id                => G_APPL_NAME

                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                      );
                  RAISE e_skip_record;
             ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                  RAISE e_skip_record;    --- G_RET_STS_UNEXP_ERROR Handled in caller
              END IF;
     END IF;


     write_debug(l_proc_name, 'Convert Intf rec to API type ');

     Convert_intf_rec_to_API_type (  p_entity   => G_ENTITY_ICC_HEADER
                                   , p_icc_rec  => p_icc_rec
                                   , x_api_icc_rec => l_api_icc_rec
                                  );

     l_api_icc_tbl(1) := l_api_icc_rec;
     write_debug(l_proc_name, 'Convert Intf rec to API type end');

     write_debug(l_proc_name, 'Call EGO_ITEM_CATALOG_PUB.Calling Process_Catalog_Groups ');

       --*****************************************************
       -- CREATE/UPDATE Base ICC
       --*****************************************************
       l_entity_code    := G_ENTITY_ICC_HEADER;  -- for error handler

       EGO_ITEM_CATALOG_PUB.Process_Catalog_Groups
       (
          p_api_version_number      => 1.0
        , p_init_msg_list           => FALSE   --- need to be FALSE since this API uses the same error_handler pkg  bug 9767869
        , p_catalog_group_tbl       => l_api_icc_tbl
        , p_user_id                 => G_USER_ID
        , x_catalog_group_tbl       => x_api_icc_tbl
        , x_return_status           => x_return_status
        , x_msg_count               => l_message_count
        , p_debug                   => 'N'
        --, p_output_dir              IN  VARCHAR2 := NULL
        --, p_debug_filename          IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
        , p_bo_identifier           =>'ICC'
        --, p_language_code       IN  VARCHAR2 := 'US'
      );

      write_debug(l_proc_name, 'End EGO_ITEM_CATALOG_PUB.Calling Process_Catalog_Groups msg count=>'||l_message_count);

      IF x_return_status = G_RET_STS_ERROR THEN

         Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
         write_debug('EGO_ITEM_CATALOG_PUB.Process_Catalog_Groups', 'Error Messages :');

         FOR i IN 1..l_message_count LOOP
           write_debug('EGO_ITEM_CATALOG_PUB.Process_Catalog_Groups', x_message_list(i).message_text);

              ERROR_HANDLER.Add_Error_Message(
                p_message_text                  => x_message_list(i).message_text
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_icc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );

         END LOOP;

         RAISE e_skip_record;
      ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN

         Error_Handler.GET_MESSAGE_LIST(x_message_list=>x_message_list);
         write_debug('EGO_ITEM_CATALOG_PUB.Process_Catalog_Groups',  'Unexpected error');
         FOR i IN 1..l_message_count LOOP
           write_debug('EGO_ITEM_CATALOG_PUB.Process_Catalog_Groups', x_message_list(i).message_text);

              ERROR_HANDLER.Add_Error_Message(
                p_message_text                  => x_message_list(i).message_text
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_icc_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );

         END LOOP;
        RAISE e_stop_processing;
      END IF;

      Convert_API_type_to_intf_rec (  p_entity   => G_ENTITY_ICC_HEADER
                                   , x_icc_rec  => p_icc_rec
                                   , p_api_icc_rec => x_api_icc_tbl(1)
                                  );


      ----**************************************************
      --- API for creation of the actions for the funciton
      --- associations
      ----**************************************************
      Create_Action_for_Func   ( p_icc_rec => p_icc_rec
                                ,x_return_status => x_return_status
                                ,x_return_msg   => x_return_msg
                                 );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE e_skip_record;    --- G_RET_STS_UNEXP_ERROR Handled in caller
      END IF;

       ---**************************************************
       --- Update other columns for the ICC header
       ---**************************************************
       Update_Other_ICC_Hdr_Cols  ( p_icc_rec => p_icc_rec
                                  ,x_return_status => x_return_status
                                  ,x_return_msg   => x_return_msg
                                 );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE e_skip_record;    --- G_RET_STS_UNEXP_ERROR Handled in caller
      END IF;


       ---
       --- Following methods will be called only for CREATE after creation of BASE ICC
       ---
       IF (p_icc_rec.transaction_type = G_TTYPE_CREATE AND p_icc_rec.item_catalog_group_id IS NOT NULL )
        THEN

           IF G_P4TP_PROFILE_ENABLED THEN    --- added if 9791391
               ---**************************************************
               --- Create draft version for the ICC
               ---**************************************************
               l_entity_code := G_ENTITY_ICC_VERSION;

               Create_Draft_Version ( p_item_catalog_id => p_icc_rec.item_catalog_group_id
                                     ,x_return_status   =>  x_return_status
                                     ,x_return_msg      =>  x_return_msg
                                    );

               IF x_return_status = G_RET_STS_ERROR THEN
                 write_debug('Create_Draft_Version', x_return_msg);

                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => x_return_msg
                       ,p_application_id                => G_APPL_NAME

                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );

                 RAISE e_skip_record;
               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_skip_record;    --- G_RET_STS_UNEXP_ERROR Handled in caller
               END IF;
           END IF;


           ---***************************************************
           --- Grant the item catalog user role to the creater
           ---***************************************************


           l_entity_code := G_ENTITY_ICC_HEADER;
           EGO_SECURITY_PUB.grant_role_guid(
                  p_api_version        => 1.0
                , p_role_name          => 'EGO_CATALOG_GROUP_USER'
                , p_object_name        => 'EGO_CATALOG_GROUP'
                , p_instance_type      => EGO_ITEM_PUB.G_INSTANCE_TYPE_INSTANCE
                , p_instance_set_id    => NULL
                , p_instance_pk1_value => p_icc_rec.item_catalog_group_id
                , p_instance_pk2_value => NULL
                , p_instance_pk3_value => NULL
                , p_instance_pk4_value => NULL
                , p_instance_pk5_value => NULL
                , p_party_id           => G_party_id
                , p_start_date         => NULL
                , p_end_date           => NULL
                , x_return_status      => x_return_status
                , x_errorcode          => l_error_code
                , x_grant_guid         => l_grant_guid
                     );
                IF FND_API.TO_BOOLEAN(x_return_status) THEN
                  x_return_status := EGO_ITEM_PUB.G_RET_STS_SUCCESS;

                ELSE

                  x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
                  write_debug('EGO_SECURITY_PUB.grant_role_guid', 'Error Messages :');

                  FND_MSG_PUB.count_and_get ( p_count  => l_count
                                             ,p_data   => x_return_msg
                                           );

                  IF l_count = 1 THEN
                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => 'EGO_SECURITY_PUB.grant_role_guid'||x_return_msg
                       ,p_application_id                => G_APPL_NAME

                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                       );
                  ELSE
                    FOR i in 1..l_count LOOP
                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => 'EGO_SECURITY_PUB.grant_role_guid'||FND_MSG_PUB.get
                       ,p_application_id                => G_APPL_NAME

                       ,p_row_identifier                => p_icc_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                      );
                    END LOOP;
                  END IF;
                  RAISE e_skip_record;
              END IF;



           --*****************************************************
           -- Associate Base Pages
           --*****************************************************
           IF p_icc_rec.parent_catalog_group_id IS NULL THEN
               EGO_UPLOAD_PUB.createBaseAttributePages (p_catalog_group_id => p_icc_rec.item_catalog_group_id
                                                           ,x_return_status    => x_return_status
                                                           );
                  IF x_return_status = G_RET_STS_ERROR THEN

                     write_debug('EGO_UPLOAD_PUB.createBaseAttributePages', 'Error Messages :');
                      FND_MSG_PUB.count_and_get ( p_count  => l_count
                                                 ,p_data   => x_return_msg
                                               );
                     IF l_count = 1 THEN
                          ERROR_HANDLER.Add_Error_Message(
                            p_message_text                  => 'EGO_SECURITY_PUB.grant_role_guid'||x_return_msg
                           ,p_application_id                => G_APPL_NAME

                           ,p_row_identifier                => p_icc_rec.transaction_id
                           ,p_entity_code                   => l_entity_code
                           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                           );
                     ELSE
                        FOR i in 1..l_count LOOP
                          ERROR_HANDLER.Add_Error_Message(
                            p_message_text                  => 'EGO_SECURITY_PUB.grant_role_guid'||FND_MSG_PUB.get
                           ,p_application_id                => G_APPL_NAME

                           ,p_row_identifier                => p_icc_rec.transaction_id
                           ,p_entity_code                   => l_entity_code
                           ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                          );
                        END LOOP;
                      END IF;

                      RAISE e_skip_record;
                 ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                   RAISE e_stop_processing;
                 END IF;
           END IF;

       ELSIF p_icc_rec.transaction_type = G_TTYPE_UPDATE THEN
         NULL;
       END IF;

       --- For both CREATE as well as UPDATE transaction
       --- call the versions API to process the respective ICC versions
       ---
       ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);

       WRITE_DEBUG(l_proc_name, 'calling versions in create icc, id , name=>'||p_icc_rec.item_catalog_group_id||','||p_icc_rec.item_catalog_name);

       --- required by versions, when versions are processed per ICC
       UPDATE_ICC_ID_NAME ( p_icc_id => p_icc_rec.item_catalog_group_id, p_icc_name => p_icc_rec.item_catalog_name);

       Construct_Colltn_And_Validate ( p_entity        => G_ENTITY_ICC_VERSION
                                   ,   p_icc_name      => p_icc_rec.item_catalog_name
                                   ,   p_icc_id        => p_icc_rec.item_catalog_group_id
                                   ,   x_return_status  => x_return_status
                                   ,   x_return_msg     => x_return_msg
                                   );
       IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE e_unexpected_error;
       END IF;

     write_debug(l_proc_name, 'End');

   EXCEPTION
   WHEN e_skip_record THEN
      ---
      --- Proceed with the next record
      ---
      ROLLBACK TO ICC_CREATE_START;
      RETURN;
   WHEN e_unexpected_error THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := x_return_msg||'->Unexpected error in '||G_PKG_NAME||'.'||l_proc_name;
   WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
   END   Create_ICC;


--********************************************************************
----
---- This procedure resolves the transaction type and calls the relevant
---- CREATE/UPDATE APIs
--********************************************************************


PROCEDURE Call_ICC_APIS (   p_icc_rec       IN OUT NOCOPY ego_icc_rec_type
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_return_msg  OUT NOCOPY VARCHAR2
                       )
IS
     l_proc_name   VARCHAR2(30) := 'Call_ICC_APIS';

     e_skip_record      EXCEPTION;
     e_unexpected_error EXCEPTION;


BEGIN
  write_debug(l_proc_name, 'Start ');
  x_return_status := G_RET_STS_SUCCESS;

    Create_ICC (   p_icc_rec => p_icc_rec
                  ,x_return_status => x_return_status
                  ,x_return_msg    => x_return_msg
               );
    IF  x_return_status = G_RET_STS_ERROR THEN
      RAISE e_skip_record;
    ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE e_unexpected_error;  --- G_RET_STS_UNEXP_ERROR Handled in caller
    END IF;




  write_debug(l_proc_name, 'End ');
EXCEPTION
WHEN e_skip_record THEN
  RETURN;
WHEN e_unexpected_error THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := x_return_msg||'->'||'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
  RETURN;
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Call_ICC_APIS;


/********************************************************************
---
--- APIs for create/update/delete of AG ASSOCIATIONS
---
********************************************************************/

PROCEDURE CALL_AG_ASSOC_API  ( p_ag_assoc_rec  IN OUT nocopy ego_ag_assoc_rec_type
                                ,x_return_status OUT NOCOPY VARCHAR2
                                ,x_return_msg  OUT NOCOPY VARCHAR2
                               )
IS
  l_proc_name   VARCHAR2(30) :=  'CALL_AG_ASSOC_API';
  l_entity_code     VARCHAR2(30) := G_ENTITY_ICC_AG_ASSOC;
  l_object_id   fnd_objects.object_id%TYPE;
  l_association_id  ego_obj_ag_assocs_b.association_id%TYPE;

  l_msg_count           NUMBER := 0;
  l_error_code          NUMBER := 0;

  e_skip_record         EXCEPTION;
  e_unexpected_error    EXCEPTION;

  l_token_table     ERROR_HANDLER.Token_Tbl_Type;
  l_msg_data        VARCHAR2(4000);


BEGIN
   write_debug(l_proc_name, 'Start');
  x_return_status := G_RET_STS_SUCCESS;

  IF p_ag_assoc_rec.transaction_type = G_TTYPE_CREATE THEN

    FOR rec_obj_id IN cur_get_obj_id loop
      l_object_id := rec_obj_id.object_id;
    end loop;


    EGO_EXT_FWK_PUB.Create_Association (
        p_api_version             => 1.0
       ,p_association_id          => NULL
       ,p_object_id               => l_object_id
       ,p_classification_code     => TO_CHAR(p_ag_assoc_rec.item_catalog_group_id)
       ,p_data_level              => NULL
       ,p_attr_group_id           => p_ag_assoc_rec.attr_group_id
       ,p_enabled_flag            => 'Y'
       ,p_view_privilege_id       => NULL    --ignored for now
       ,p_edit_privilege_id       => NULL    --ignored for now
       ,p_init_msg_list           => fnd_api.g_FALSE
       ,p_commit                  => fnd_api.g_FALSE
       ,x_association_id          => l_association_id
       ,x_return_status           => x_return_status
       ,x_errorcode               => l_error_code
       ,x_msg_count               => l_msg_count
       ,x_msg_data                => l_msg_data
    );
        IF x_return_status = G_RET_STS_ERROR THEN

           write_debug('EGO_EXT_FWK_PUB.Create_Association', l_msg_data);

           FND_MSG_PUB.count_and_get ( p_count  => l_msg_count
                                      ,p_data   => l_msg_data
                                    );

           IF l_msg_count = 1 THEN
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Association'||x_return_msg
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_ag_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );
           ELSE
             FOR i in 1..l_msg_count LOOP
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Association'||FND_MSG_PUB.get
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_ag_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );
             END LOOP;

           END IF;
        ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          RAISE e_unexpected_error;
        END IF;
    END IF;


  IF p_ag_assoc_rec.transaction_type = G_TTYPE_DELETE THEN

    EGO_EXT_FWK_PUB.Delete_Association (
                          p_api_version     => 1.0
                         ,p_association_id  => p_ag_assoc_rec.association_id
                         ,p_init_msg_list   => fnd_api.g_FALSE
                         ,p_commit          => fnd_api.g_FALSE
                         ,p_force           => fnd_api.g_FALSE
                         ,x_return_status   => x_return_status
                         ,x_errorcode       => l_error_code
                         ,x_msg_count       => l_msg_count
                         ,x_msg_data        => l_msg_data
                                       );

    IF x_return_status = G_RET_STS_ERROR THEN

       x_return_status := EGO_ITEM_PUB.G_RET_STS_ERROR;
       write_debug('EGO_EXT_FWK_PUB.Delete_Association', l_msg_data);

       FND_MSG_PUB.count_and_get ( p_count  => l_msg_count
                                  ,p_data   => l_msg_data
                                );

       IF l_msg_count = 1 THEN
           ERROR_HANDLER.Add_Error_Message(
             p_message_text                  => 'EGO_EXT_FWK_PUB.Delete_Association'||x_return_msg
            ,p_application_id                => G_APPL_NAME

            ,p_row_identifier                => p_ag_assoc_rec.transaction_id
            ,p_entity_code                   => l_entity_code
            ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
            );
       ELSE
         FOR i in 1..l_msg_count LOOP
           ERROR_HANDLER.Add_Error_Message(
             p_message_text                  => 'EGO_EXT_FWK_PUB.Delete_Association'||FND_MSG_PUB.get
            ,p_application_id                => G_APPL_NAME

            ,p_row_identifier                => p_ag_assoc_rec.transaction_id
            ,p_entity_code                   => l_entity_code
            ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
           );
         END LOOP;
       END IF;
    ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE e_unexpected_error;
    END IF;
  END IF;

  IF p_ag_assoc_rec.transaction_type = G_TTYPE_UPDATE THEN
    --- nothing to update as only enabled flag, view privilege id , edit privilege id can be updated
    --- enabled flag is not available through UI, privilege ids are not used as of now
    null;

  END IF;


 write_debug(l_proc_name, 'End');
EXCEPTION
WHEN e_unexpected_error THEN
  write_debug(l_proc_name, x_return_msg);
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := x_return_msg||'Stop process error occured in '||G_PKG_NAME||'.'||l_proc_name;
  write_debug(l_proc_name, x_return_msg);
WHEN OTHERS THEN
   x_return_status := G_RET_STS_UNEXP_ERROR;
   x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END CALL_AG_ASSOC_API;



PROCEDURE Call_func_param_assoc_api(  p_func_param_assoc_rec  IN ego_func_param_map_rec_type
                                      ,x_return_status   OUT NOCOPY VARCHAR2
                                      ,x_return_msg  OUT NOCOPY VARCHAR2
                                      )
IS
  l_proc_name   VARCHAR2(30) := 'Call_func_param_assoc_api';
  l_application_id NUMBER    := NULL;
  l_entity_code    VARCHAR2(30) := G_ENTITY_ICC_FN_PARAM_MAP;
  l_action_id      ego_actions_b.action_id%TYPE := null;
  l_object_id      fnd_objects.object_id%TYPE := null;


  l_msg_count           NUMBER := 0;
  l_error_code          NUMBER := 0;
  l_msg_data            VARCHAR2(4000);
  l_mapped_obj_type     EGO_MAPPINGS_B.MAPPED_OBJ_TYPE%TYPE := 'A';

  e_skip_record         EXCEPTION;
  e_unexpected_error    EXCEPTION;

  l_token_table     ERROR_HANDLER.Token_Tbl_Type;

  CURSOR cur_action_id ( p_function_id number
                        ,p_icc_id      number
                        ,p_object_id   number
                      )
  IS
  SELECT action_id
  FROM   ego_actions_b
  where  function_id = p_function_id
  and    classification_code = to_char(p_icc_id)
  and    object_id     = p_object_id
  ;

  CURSOR cur_func_param_count ( p_function_id number)
  IS
  SELECT COUNT(1) count
  from   ego_func_params_b
  where function_id = p_function_id;



BEGIN
  write_debug(l_proc_name, 'Start');

  --- Get the object id
  ---
  FOR rec_obj_id IN cur_get_obj_id loop
    l_object_id := rec_obj_id.object_id;
  END LOOP;

  --- Get the function association action id
  ---
  FOR rec_action_id IN cur_action_id ( p_function_id => p_func_param_assoc_rec.function_id
                                      ,p_icc_id      => p_func_param_assoc_rec.item_catalog_group_id
                                      ,p_object_id   => l_object_id
                                     )
  LOOP
    l_action_id := rec_action_id.action_id;

  END LOOP;


  IF p_func_param_assoc_rec.transaction_type = G_TTYPE_CREATE THEN

      EGO_EXT_FWK_PUB.Create_Mapping (
          p_api_version            => 1.0
         ,p_function_id            => p_func_param_assoc_rec.function_id
         ,p_mapped_obj_type        => l_mapped_obj_type
         ,p_mapped_obj_pk1_value   => l_action_id
         ,p_func_param_id          => p_func_param_assoc_rec.parameter_id
         ,p_attr_group_id          => p_func_param_assoc_rec.attr_group_id
         ,p_mapping_value          => p_func_param_assoc_rec.ATTr_name
         ,p_mapped_uom_parameter   => p_func_param_assoc_rec.mapped_uom_parameter
         ,p_value_uom_source       => p_func_param_assoc_rec.uom_param_value_type
         ,p_fixed_uom              => p_func_param_assoc_rec.fixed_uom_value
         ,p_init_msg_list          => fnd_api.g_FALSE
         ,p_commit                 => fnd_api.g_FALSE
         ,x_return_status          => X_RETURN_STATUS
         ,x_errorcode              => l_error_code
         ,x_msg_count              => l_msg_count
         ,x_msg_data               => l_msg_data
                      );
        IF x_return_status = G_RET_STS_ERROR THEN

           write_debug('EGO_EXT_FWK_PUB.Create_Mapping', l_msg_data);

           FND_MSG_PUB.count_and_get ( p_count  => l_msg_count
                                      ,p_data   => l_msg_data
                                    );

           IF l_msg_count = 1 THEN
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Mapping'||x_return_msg
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );
           ELSE
             FOR i in 1..l_msg_count LOOP
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Mapping'||FND_MSG_PUB.get
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );
             END LOOP;
           END IF;
        ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          x_return_msg := l_msg_data;
          RAISE e_unexpected_error;
        END IF;

  ELSIF p_func_param_assoc_rec.transaction_type = G_TTYPE_UPDATE THEN

        EGO_EXT_FWK_PUB.Update_Mapping (
        p_api_version              => 1.0
       ,p_function_id              => p_func_param_assoc_rec.function_id
       ,p_mapped_obj_type          => l_mapped_obj_type
       ,p_mapped_obj_pk1_value     => l_action_id
       ,p_func_param_id            => p_func_param_assoc_rec.parameter_id
       ,p_attr_group_id            => p_func_param_assoc_rec.attr_group_id
       ,p_mapping_value            => p_func_param_assoc_rec.attr_name
       ,p_new_func_param_id        => p_func_param_assoc_rec.parameter_id
       ,p_new_mapping_value        => p_func_param_assoc_rec.attr_name
       ,p_mapped_uom_parameter     => p_func_param_assoc_rec.mapped_uom_parameter
       ,p_value_uom_source         => p_func_param_assoc_rec.uom_param_value_type
       ,p_fixed_uom                => p_func_param_assoc_rec.fixed_uom_value
       ,p_init_msg_list            => fnd_api.g_false
       ,p_commit                   => fnd_api.g_FALSE
       ,x_return_status            => X_RETURN_STATUS
       ,x_errorcode                => l_error_code
       ,x_msg_count                => l_msg_count
       ,x_msg_data                 => l_msg_data
                          );

        IF x_return_status = G_RET_STS_ERROR THEN
           write_debug('EGO_EXT_FWK_PUB.Create_Mapping', l_msg_data);

           FND_MSG_PUB.count_and_get ( p_count  => l_msg_count
                                      ,p_data   => l_msg_data
                                    );

           IF l_msg_count = 1 THEN
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Mapping'||x_return_msg
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );
           ELSE
             FOR i in 1..l_msg_count LOOP
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Mapping'||FND_MSG_PUB.get
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );
             END LOOP;
           END IF;
        ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          x_return_msg := l_msg_data;
          RAISE e_unexpected_error;
        END IF;



  ELSIF p_func_param_assoc_rec.transaction_type = G_TTYPE_DELETE THEN
       EGO_EXT_FWK_PUB.Delete_Func_Param_Mapping (
        p_api_version              => 1.0
       ,p_function_id              => p_func_param_assoc_rec.function_id
       ,p_mapped_obj_type          => l_mapped_obj_type
       ,p_mapped_obj_pk1_value     => l_action_id
       ,p_func_param_id            => p_func_param_assoc_rec.parameter_id
       ,p_init_msg_list            => fnd_api.g_false
       ,p_commit                   => fnd_api.g_FALSE
       ,x_return_status            => X_RETURN_STATUS
       ,x_errorcode                => l_error_code
       ,x_msg_count                => l_msg_count
       ,x_msg_data                 => l_msg_data
        );

        IF x_return_status = G_RET_STS_ERROR THEN

           write_debug('EGO_EXT_FWK_PUB.Create_Mapping', l_msg_data);

           FND_MSG_PUB.count_and_get ( p_count  => l_msg_count
                                      ,p_data   => l_msg_data
                                    );

           IF l_msg_count = 1 THEN
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Mapping'||x_return_msg
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
                );
           ELSE
             FOR i in 1..l_msg_count LOOP
               ERROR_HANDLER.Add_Error_Message(
                 p_message_text                  => 'EGO_EXT_FWK_PUB.Create_Mapping'||FND_MSG_PUB.get
                ,p_application_id                => G_APPL_NAME

                ,p_row_identifier                => p_func_param_assoc_rec.transaction_id
                ,p_entity_code                   => l_entity_code
                ,p_table_name                    => G_ENTITY_ICC_HEADER_TAB
               );
             END LOOP;
           END IF;
        ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
          x_return_msg := l_msg_data;
          RAISE e_unexpected_error;
        END IF;

  END IF;

  write_debug(l_proc_name, 'End');
EXCEPTION
WHEN e_unexpected_error THEN
  write_debug(l_proc_name, x_return_msg);
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := x_return_msg||'Stop process error occured in '||G_PKG_NAME||'.'||l_proc_name;
  write_debug(l_proc_name, x_return_msg);
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Call_func_param_assoc_api;


/********************************************************************
---
---   This procedure syncs the draft version with the latest released
---   version of the ICC, added method bug 9791391
---
********************************************************************/
PROCEDURE Sync_Draft_Version (
           p_icc_vers_rec     IN OUT NOCOPY ego_icc_vers_rec_type,
           x_return_status    OUT NOCOPY VARCHAR2,
           x_return_msg       OUT NOCOPY VARCHAR2)
IS

  l_proc_name        CONSTANT VARCHAR2(30) := 'Sync_Draft_Version';
  l_msg_count        NUMBER := 0;
  l_msg_data         VARCHAR2(4000);
  l_entity_code      VARCHAR2(30) := G_ENTITY_ICC_VERSION;
  l_locking_party_id ego_object_lock.locking_party_id%TYPE;
  l_lock_flag        ego_object_lock.lock_flag%TYPE;
  e_stop_processing  EXCEPTION;
  l_return_status    VARCHAR2(1);
  l_return_msg       VARCHAR2(2000);

BEGIN
  x_return_status := G_RET_STS_SUCCESS;
  write_debug(l_proc_name, 'Start');

  IF p_icc_vers_rec.process_status = G_PROCESS_STATUS_INITIAL THEN   -- only if the version record does not have an error
      ---
      --- This method will sync the draft with the released version ver_seq_id
      ---
      EGO_TRANSACTION_ATTRS_PVT.Revert_Transaction_Attribute (
                               p_source_icc_id   => p_icc_vers_rec.item_catalog_group_id
                               ,p_source_ver_no   => p_icc_vers_rec.ver_seq_id
                               ,p_init_msg_list   => FALSE
                               ,x_return_status   => x_return_status
                               ,x_msg_count       => l_msg_count
                               ,x_msg_data        => l_msg_data
                               );

        IF x_return_status <> G_RET_STS_SUCCESS THEN
            FND_MSG_PUB.RESET;  --- resets the message index pointer to top of table, since count_and_get is called in above api

            FOR i in 1..l_msg_count LOOP
              ERROR_HANDLER.Add_Error_Message(
                p_message_text                  => FND_MSG_PUB.GET ( p_encoded => FND_API.G_FALSE)
               ,p_application_id                => G_APPL_NAME
               ,p_message_type                  => G_TYPE_ERROR
               ,p_row_identifier                => p_icc_vers_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
              );
            END LOOP;
        END IF;


        --- once the draft is synced , update the lock flag, this call is repeated during validatio
        --- need to redesign

        --- first get the lock info
        ---
        EGO_METADATA_BULKLOAD_PVT.Get_Lock_Info (   p_object_name  => G_ENTITY_ICC_LOCK
                                                   ,p_pk1_value    => p_icc_vers_rec.item_catalog_group_id
                                                   ,x_locking_party_id  => l_locking_party_id
                                                   ,x_lock_flag         => l_lock_flag
                                                   ,x_return_msg        => x_return_msg
                                                   ,x_return_status     => x_return_status
                                               );
        IF  x_return_status  = G_RET_STS_SUCCESS THEN
          --- update the lock record
          ---
          IF l_lock_flag = 'L' THEN

                --- Unlock the record
                ---
                EGO_METADATA_BULKLOAD_PVT.Lock_Unlock_Object  ( p_object_name => G_ENTITY_ICC_LOCK
                                   ,p_pk1_value     => p_icc_vers_rec.item_catalog_group_id
                                   ,p_lock_flag     => FALSE
                                   ,x_return_msg    => l_return_msg
                                   ,x_return_status => l_return_status
                              );
                IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                    x_return_msg := l_return_msg;
                    RAISE e_stop_processing;
                END IF;


          ELSIF l_lock_flag = 'U' THEN
                --- IF Unlocked, then insert a new unlocked record ( simulating lock and unlock behaviour)
                ---
                EGO_METADATA_BULKLOAD_PVT.Lock_Unlock_Object  ( p_object_name      => G_ENTITY_ICC_LOCK
                                                               ,p_pk1_value        => p_icc_vers_rec.item_catalog_group_id
                                                               ,p_lock_flag        => TRUE
                                                               ,p_Party_id          => G_PARTY_ID
                                                               ,x_return_msg       => l_return_msg
                                                               ,x_return_status    => l_return_status
                                                             );
                IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                    x_return_msg := l_return_msg;
                    RAISE e_stop_processing;
                END IF;

          END IF;


        ELSIF x_return_status  = G_RET_STS_ERROR THEN
          ERROR_HANDLER.Add_Error_Message(
                p_message_text                  => x_return_msg
               ,p_application_id                => G_APPL_NAME
               ,p_row_identifier                => p_icc_vers_rec.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
               );

        ELSIF  x_return_status  = G_RET_STS_UNEXP_ERROR THEN
          RAISE e_stop_processing;

        END IF;





  END IF;

  write_debug(l_proc_name, 'End');
EXCEPTION
WHEN e_stop_processing THEN
  x_return_status  := G_RET_STS_UNEXP_ERROR ;
  x_return_msg := 'Stop processing error in '||G_PKG_NAME||'.'||l_proc_name||'->'||x_return_msg;
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END;



/********************************************************************
---
---   This procedure takes in the icc versions record type and creates
---   the icc revisions accordingly
---
********************************************************************/

PROCEDURE Call_ICC_Vers_API (  p_icc_vers_rec  IN OUT NOCOPY ego_icc_vers_rec_type
                               ,x_return_status   OUT NOCOPY VARCHAR2
                               ,x_return_msg  OUT NOCOPY VARCHAR2
                             )
IS
  l_proc_name   VARCHAR2(30) := 'Call_ICC_Vers_API';
  l_application_id NUMBER    := NULL;
  l_entity_code    VARCHAR2(30) := G_ENTITY_ICC_VERSION;

  e_skip_record         EXCEPTION;

  l_token_table     ERROR_HANDLER.Token_Tbl_Type;
  l_max_seq_id      NUMBER := 0;
  l_max_start_date  DATE := null;
  l_higher_date       DATE := null;
  l_lower_date        DATE := null;
  l_version_created   BOOLEAN := FALSE;


  FUNCTION Get_Max_Sequence
  RETURN NUMBER
  IS
    l_ver_id  number := 0;
  BEGIN

    select max(version_seq_id)
      into l_ver_id
    from   EGO_MTL_CATALOG_GRP_VERS_B
    where item_catalog_group_id = p_icc_vers_rec.item_catalog_group_id
    ;

    return l_ver_id;

  END Get_Max_Sequence;


  FUNCTION Check_ICC_Versioned
  RETURN BOOLEAN
  IS
    l_COUNT  number := 0;
  BEGIN

    select COUNT(1)
    into   l_count
    from   EGO_MTL_CATALOG_GRP_VERS_B
    where item_catalog_group_id = p_icc_vers_rec.item_catalog_group_id
    ;

    IF l_count > 0 THEN
      RETURN TRUE;
    ELSE
      RETURN FALSE;
    END IF;

  END Check_ICC_Versioned;


  FUNCTION Get_Max_St_Date
  RETURN DATE
  IS
    l_date   DATE := null;
  BEGIN

    SELECT max(start_active_date)
    INTO   l_date
    FROM   EGO_MTL_CATALOG_GRP_VERS_B
    WHERE item_catalog_group_id = p_icc_vers_rec.item_catalog_group_id
    AND   version_seq_id <> 0
    ;
    RETURN l_date;

  END Get_Max_St_Date;

  /****************************************
  ---
  --- INLINE Procedure to create a new version
  ---
  ****************************************/
  PROCEDURE Create_Version  ( p_start_date  IN DATE ,
                              p_end_date    IN DATE
                            )
  IS

    l_return_status   VARCHAR2(1) := G_RET_STS_SUCCESS;
    l_count           NUMBER := 0;
    l_msg_data        VARCHAR2(4000) := NULL;
  BEGIN
    write_debug(l_proc_name, 'Start insert');

    --- Update the ICC id in the TA interface table
    ---
    EGO_TA_BULKLOAD_PVT.Bulk_Validate_Trans_Attrs_ICC (
                                                      p_set_process_id           => G_SET_PROCESS_ID
                                                    ,p_item_catalog_group_id    => p_icc_vers_rec.item_catalog_group_id
                                                    ,p_item_catalog_group_name  => p_icc_vers_rec.item_catalog_name
                                                    );


    SAVEPOINT icc_version_create_start;
    l_version_created := FALSE;
    --- create the new version
    ---
         l_max_seq_id := Get_Max_Sequence;
         --- max seq id is incremented during insert below.

        INSERT into EGO_MTL_CATALOG_GRP_VERS_B
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
        VALUES
          (p_icc_vers_rec.item_catalog_group_id,
          l_max_seq_id + 1,
          p_icc_vers_rec.description,
          p_start_date,
          p_end_date,
          G_USER_ID,
          SYSDATE,
          G_USER_ID,
          SYSDATE,
          G_LOGIN_ID);

          p_icc_vers_rec.ver_seq_id := l_max_seq_id + 1;
          p_icc_vers_rec.end_date := p_end_date;

          write_debug(l_proc_name, 'inserted rows ver max seq seq=>'||l_max_seq_id||'  dt'||p_icc_vers_rec.start_date
           ||'*'||p_icc_vers_rec.end_date);

            --- Call the TA API
            ---
            EGO_TA_BULKLOAD_PVT.Import_TA_Intf
                               ( p_api_version             => 1.0,
                                 p_set_process_id          => G_SET_PROCESS_ID,
                                 p_item_catalog_group_id   => p_icc_vers_rec.item_catalog_group_id,
                                 p_icc_version_number_intf => p_icc_vers_rec.ver_seq_no,
                                 p_icc_version_number_act  => l_max_seq_id + 1,
                                 x_return_status           => l_return_status,
                                 x_return_msg              => x_return_msg
                               );

            write_debug(l_proc_name, 'TA api x_return_status =>'||l_return_status);

            IF l_return_status = G_RET_STS_SUCCESS THEN
              l_version_created := TRUE;
            ELSIF l_return_status = G_RET_STS_ERROR THEN

                  x_return_status := G_RET_STS_ERROR;

                  ROLLBACK TO icc_version_create_start;
                  l_version_created := FALSE;

                  write_debug ( l_proc_name , 'Unable to create TA for (icc id, seq no) => '
                             ||p_icc_vers_rec.item_catalog_group_id||','||p_icc_vers_rec.ver_seq_no);

                  l_token_table(1).TOKEN_NAME := 'VER_SEQ';
                  l_token_table(1).TOKEN_VALUE := p_icc_vers_rec.ver_seq_no;

                  l_token_table(2).TOKEN_NAME := 'ICC_NAME';
                  l_token_table(2).TOKEN_VALUE := p_icc_vers_rec.item_catalog_name;

                  ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);

                  --- Log a generic error for the version not being created
                  ---
                  ERROR_HANDLER.Add_Error_Message(
                    p_message_name                  => 'EGO_ICC_VERSION_NOT_CREATED'
                   ,p_application_id                => G_APPL_NAME
                   ,p_token_tbl                     => l_token_table
                   ,p_message_type                  => G_TYPE_ERROR
                   ,p_row_identifier                => p_icc_vers_rec.transaction_id
                   ,p_entity_code                   => l_entity_code
                   ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
                  );
                  l_token_table.DELETE;


                  -- Log the messages from the TA creation API
                  l_count := fnd_msg_pub.count_msg;
                  FND_MSG_PUB.RESET;  --- resets the message index pointer to top of table

                  FOR i in 1..l_count LOOP
                      ERROR_HANDLER.Add_Error_Message(
                        p_message_text                  => FND_MSG_PUB.GET ( p_encoded => FND_API.G_FALSE)  --- bug 9750497, 9756337
                       ,p_application_id                => G_APPL_NAME
                       ,p_token_tbl                     => l_token_table
                       ,p_message_type                  => G_TYPE_WARNING
                       ,p_row_identifier                => p_icc_vers_rec.transaction_id
                       ,p_entity_code                   => l_entity_code
                       ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
                      );
                  END LOOP;


                  --- we do not create the version if the TA fails
                  ---
                  --- Update all the TAs for the ver. seq to error
                  --- since we will not be processing any of those TAs
                  ---
                  EGO_TA_BULKLOAD_PVT.Update_Intf_Err_Trans_Attrs(
                             p_set_process_id          => G_SET_PROCESS_ID,
                             p_item_catalog_group_id   => p_icc_vers_rec.item_catalog_group_id,
                             p_icc_version_number_intf => p_icc_vers_rec.ver_seq_no,
                             x_return_status           => l_return_status,
                             x_return_msg              => x_return_msg);

                 ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);
                 IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                   l_version_created := FALSE;
                   RETURN;        --- Error message is logged in calling procedure
                 END IF;
            ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
              x_return_status := G_RET_STS_UNEXP_ERROR;
              l_version_created := FALSE;
              ROLLBACK TO icc_version_create_start;
              RETURN;
            END IF;

    write_debug(l_proc_name, 'create ver ret sts x_return_status=>'||x_return_status);
  END Create_Version;

      /****************************************
      --- INLINE Procedure which updates the END DATE
      --- on an existing version
      ---
      ****************************************/
  PROCEDURE Update_existing_Version ( p_ver_start_date  IN DATE
                                     ,p_new_end_date    IN DATE
                                    )
  IS

  BEGIN

    UPDATE EGO_MTL_CATALOG_GRP_VERS_B
    set end_active_date     = p_new_end_date
       , last_updated_by    = G_USER_ID
       , last_update_date   = SYSDATE
       , last_update_login  = G_LOGIN_ID
    WHERE start_active_date = p_ver_start_date
    and   item_catalog_group_id = p_icc_vers_rec.item_catalog_group_id
    and   version_seq_id <> 0;

  END Update_existing_Version;


      --- function to get the minimum higher date among
      --- existing version when compared with the current date
      ---
  FUNCTION get_high_date ( p_date  IN DATE)
  RETURN DATE
  IS

    l_date   DATE;

    CURSOR cur_fetch_date
    IS
    SELECT min(start_active_date)  min_higher_date
    FROM   EGO_MTL_CATALOG_GRP_VERS_B
    WHERE  item_catalog_group_id = p_icc_vers_rec.item_catalog_group_id
    AND    start_active_date > p_date
    --AND    p_date < nvl(end_active_date, p_date - 1)
    AND    version_seq_id <> 0
    ;

  BEGIN

    FOR rec_date in cur_fetch_date loop
      l_date :=  rec_date.min_higher_date;
    end loop;
    RETURN l_date;

  END get_high_date;

  --- function to get the minimum lower date among
  --- existing version when compared with the current date
  ---
  FUNCTION get_low_date ( p_date  IN DATE)
  RETURN DATE
  IS

    l_date   DATE;

    CURSOR cur_fetch_date
    IS
    SELECT max(start_active_date)  max_lower_date
    FROM   EGO_MTL_CATALOG_GRP_VERS_B
    WHERE  item_catalog_group_id = p_icc_vers_rec.item_catalog_group_id
    AND    start_active_date < p_date
    AND    version_seq_id <> 0
    ;

  BEGIN

    FOR rec_date in cur_fetch_date loop
      l_date :=  rec_date.max_lower_date;
    end loop;
    RETURN l_date;

  END get_low_date;



BEGIN
  write_debug(l_proc_name, 'Start');
  x_return_status := G_RET_STS_SUCCESS;

  --- Check if ICC is versioned
  ---
  IF NOT Check_ICC_Versioned THEN

    l_token_table(1).TOKEN_NAME := 'ICC_NAME';
    l_token_table(1).TOKEN_VALUE := p_icc_vers_rec.item_catalog_name;

    ERROR_HANDLER.Add_Error_Message(
      p_message_name                  => 'EGO_ICC_NOT_VERSIONED'
      ,p_application_id                => G_APPL_NAME
      ,p_token_tbl                     => l_token_table
      ,p_message_type                  => G_PROCESS_STATUS_WARNING
      ,p_row_identifier                => p_icc_vers_rec.transaction_id
      ,p_entity_code                   => l_entity_code
      ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
      );
      l_token_table.DELETE;

      x_return_status := G_RET_STS_ERROR;

      write_debug(l_proc_name, 'Err_Msg-TID='
                    ||p_icc_vers_rec.transaction_id||'-(ICC, STA_DT)=('
                    ||p_icc_vers_rec.item_catalog_name||','||to_char(p_icc_vers_rec.start_date, 'DD-MON-YYYY HH24:MI:SS')||')'
                    ||' EGO_ICC_NOT_VERSIONED'
                  );

      RETURN;

  END IF;

  --- CASE 1
  --- NEW version being inserted as the topmost version
  ---
  l_max_start_date := Get_Max_St_Date;
  IF p_icc_vers_rec.start_date > NVL(l_max_start_date, p_icc_vers_rec.start_date - 1) THEN

    --- create a new version
    ---
    l_version_created := FALSE;
    Create_Version ( p_start_date => p_icc_vers_rec.start_date
                    ,p_end_date   => NULL  -- since it is topmost
                   );

    --- end date the version which was earlier on top
    ---

    IF l_version_created THEN
        Update_existing_Version ( p_ver_start_date => l_max_start_date
                                 ,p_new_end_date   => p_icc_vers_rec.start_date - 1/(24*60*60)
                                );
    END IF;
  ELSE
      --- CASE 2
      --- Version has to be inserted between two versions
      ---
      --- get the dates between which this version should lie

      l_higher_date := Get_high_date ( p_date => p_icc_vers_rec.start_date);
      l_lower_date  := Get_low_date ( p_date => p_icc_vers_rec.start_date);

      --- Version has to be created between the above dates
      ---
      l_version_created := FALSE;
      Create_Version ( p_start_date => p_icc_vers_rec.start_date
                      ,p_end_date   => l_higher_date - 1/(24*60*60)
                      );

      --- if lower end date is NULL it means above version inserted is lowest date released version being inserted
      --- hence there is no need to update any existing version
      ---
      IF l_lower_date IS NOT NULL AND l_version_created THEN
          --- change the end date on the version below the current (new)version being inserted
          ---
          Update_existing_Version ( p_ver_start_date => l_lower_date
                                   ,p_new_end_date   => p_icc_vers_rec.start_date - 1/(24*60*60)
                                  );
      END IF;
  END IF;

  write_debug(l_proc_name, 'End x_return_status =>'||x_return_status);
EXCEPTION
WHEN OTHERS THEN
  x_return_status := G_RET_STS_UNEXP_ERROR;
  x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
END Call_ICC_Vers_API;


/********************************************************************
---
---   This procedure updates the interface table with the pl/sql table
---   with process_status and other id value conversions which are done
---
---
********************************************************************/

PROCEDURE Update_Interface_Table ( p_entity IN VARCHAR2
                                 , p_icc_tbl        IN ego_icc_tbl_type DEFAULT g_null_icc_tbl
                                 , p_ag_assoc_tbl   IN ego_ag_assoc_tbl_type DEFAULT g_null_ag_assoc_tbl
                                 , p_func_assoc_tbl IN ego_func_param_map_tbl_type DEFAULT g_null_func_param_map_tbl
                                 , p_icc_vers_tbl   IN ego_icc_vers_tbl_type DEFAULT g_null_icc_vers_tbl
                                 )
IS

  l_proc_name  VARCHAR2(30) :=  'Update_Interface_Table';

  l_transaction_id_tbl number_tbl_type; -- bug 9701271
  l_blank_tbl number_tbl_type; -- bug 9701271
BEGIN
  write_debug (l_proc_name, 'Start of  '||l_proc_name);

  IF p_entity = G_ENTITY_ICC_HEADER THEN

      write_debug(l_proc_name, 'Updating interface table for '|| G_ENTITY_ICC_HEADER);
      -- bug 9701271
      l_transaction_id_tbl := l_blank_tbl;
      FOR i IN 1..p_icc_tbl.count LOOP
       l_transaction_id_tbl(i) :=  p_icc_tbl(i).transaction_id;
      END LOOP;

      FORALL i IN 1..p_icc_tbl.count
        UPDATE MTL_ITEM_CAT_GRPS_INTERFACE
        SET
           ROW = p_icc_tbl(i)   -- bug 9701271
        WHERE transaction_id = l_transaction_id_tbl(i)   -- bug 9701271
        AND   process_status = G_PROCESS_STATUS_INITIAL
        ;

  ELSIF p_entity = G_ENTITY_ICC_AG_ASSOC THEN

        write_debug(l_proc_name, 'Updating interface table for '|| G_ENTITY_ICC_AG_ASSOC);
        -- bug 9701271
        l_transaction_id_tbl := l_blank_tbl;
        FOR i IN 1..p_ag_assoc_tbl.count LOOP
         l_transaction_id_tbl(i) :=  p_ag_assoc_tbl(i).transaction_id;
        END LOOP;

        FORALL i in 1..p_ag_assoc_tbl.COUNT
            UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE
            SET ROW = p_ag_assoc_tbl(i)   -- bug 9701271
            WHERE transaction_id = l_transaction_id_tbl(i)
            AND   process_status = G_PROCESS_STATUS_INITIAL
            ;

  ELSIF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN

        write_debug(l_proc_name, 'Updating interface table for '|| G_ENTITY_ICC_FN_PARAM_MAP);
        -- bug 9701271
        l_transaction_id_tbl := l_blank_tbl;
        FOR i IN 1..p_func_assoc_tbl.count LOOP
          l_transaction_id_tbl(i) :=  p_func_assoc_tbl(i).transaction_id;
        END LOOP;

        FORALL i in  1..p_func_assoc_tbl.COUNT
            UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE
            SET   ROW = p_func_assoc_tbl(i)      -- bug 9701271
            WHERE transaction_id = l_transaction_id_tbl(i)
            AND   process_status = G_PROCESS_STATUS_INITIAL
            ;

  ELSIF p_entity = G_ENTITY_ICC_VERSION THEN

        write_debug(l_proc_name, 'Updating interface table for '|| G_ENTITY_ICC_VERSION);
        -- bug 9701271
        l_transaction_id_tbl := l_blank_tbl;
        FOR i IN 1..p_icc_vers_tbl.count LOOP
          l_transaction_id_tbl(i) :=  p_icc_vers_tbl(i).transaction_id;
        END LOOP;

        FORALL i in  1..p_icc_vers_tbl.COUNT
            UPDATE EGO_ICC_VERS_INTERFACE
            set ROW = p_icc_vers_tbl(i)
            WHERE transaction_id = l_transaction_id_tbl(i)
            AND   process_status = G_PROCESS_STATUS_INITIAL
            ;
            write_debug( l_proc_name, 'rows update =>'||SQL%ROWCOUNT);

  END IF;


write_debug (l_proc_name, 'End of  '||l_proc_name);

END Update_Interface_Table;





/********************************************************************
---   This procedure accepts a pl/sql table of records
---   validates, converts necessary ids, finally processes them
---
********************************************************************/

   PROCEDURE Process_Entity ( p_entity         IN varchar2
                         , p_icc_tbl        IN OUT NOCOPY ego_icc_tbl_type
                         , p_ag_assoc_tbl   IN OUT NOCOPY ego_ag_assoc_tbl_type
                         , p_func_assoc_tbl IN OUT NOCOPY ego_func_param_map_tbl_type
                         , p_icc_vers_tbl   IN OUT NOCOPY ego_icc_vers_tbl_type
                         , p_call_from_icc_process IN varchar2 DEFAULT NULL   --- bug 9791391, added parameter
                         , x_return_status    OUT NOCOPY VARCHAR2
                         , x_return_msg  OUT NOCOPY VARCHAR2
                         )
   IS
     l_proc_name  CONSTANT VARCHAR2(30) := 'Process_Entity';
     e_skip_record EXCEPTION;
     e_unexpected_error EXCEPTION;

     l_null_icc_rec          ego_icc_rec_type := null;
     l_null_ag_assoc_rec     ego_ag_assoc_rec_type:= null;
     l_null_icc_vers_rec     ego_icc_vers_rec_type := null;
     l_null_func_params_rec  ego_func_param_map_rec_type := null;
     l_count_prod            number := 0;
     l_count_current         number := 0;
     l_action_id             number := 0;
     l_dummy                 number := 0;

     l_func_params_tbl       ego_FN_Param_Obj_Tbl_Type := ego_FN_Param_Obj_Tbl_Type();
     l_count_frm_ego_maps    NUMBER := 0;
     l_count_frm_func_params NUMBER := 0;
     l_token_table           ERROR_HANDLER.Token_Tbl_Type;
     l_entity_code           VARCHAR2(30);
     l_return_status         VARCHAR2(1) := NULL;

     ---
     --- dummy call to get the SUMMARY_FLAG for ICC , KFF in attribute_defaulting
     l_delimiter varchar2(1) := FND_Flex_Ext.Get_Delimiter
                (  application_short_name   => G_ITEM_CAT_KFF_APPL
                 , key_flex_code            => G_ICC_KFF_NAME
                 , structure_number         => G_STRUCTURE_NUMBER
                 );



     CURSOR cur_prod_param_count  ( p_function_id number)
     IS
     SELECT COUNT(1) AS count_prod
     FROM EGO_FUNC_PARAMS_B
     where function_id = p_function_id
     ;

     CURSOR cur_curr_param_count  ( p_function_id number, p_icc_id number)
     IS
     SELECT COUNT(1) AS count_map
     FROM EGO_MAPPINGS_B
     where function_id = p_function_id
     and mapped_obj_type = 'A'
     and mapped_obj_pk1_val = ( select action_id
                                   from ego_actions_b
                                   where function_id = p_function_id
                                   and   classification_code = to_char(p_icc_id)
                                 )
    ;


     CURSOR cur_icc_column_chk ( p_action_id NUMBER, p_icc_id NUMBER)
     IS
        SELECT G_NUM_GEN_FUNCTION  column_name
        FROM   mtl_item_catalog_groups_b
        WHERE item_catalog_group_id =  p_icc_id
        AND   item_num_action_id =  p_action_id
        UNION ALL
        SELECT G_DESC_GEN_FUNCTION column_name
        FROM   mtl_item_catalog_groups_b
        WHERE item_catalog_group_id =  p_icc_id
        AND   item_desc_action_id =  p_action_id
        ;



   BEGIN
     write_debug (l_proc_name, 'Start of  '||l_proc_name);
     write_debug (l_proc_name, 'Entity =>'||p_entity);

     x_return_status := G_RET_STS_SUCCESS;

     --- pl/sql validations for ICC header
     ---
     IF p_entity = G_ENTITY_ICC_HEADER THEN

         IF p_icc_tbl.count = 0 THEN
           --- nothing to process
           ---
           RETURN;
         END IF;

         FOR i in 1..p_icc_tbl.count
         LOOP
           BEGIN

               write_debug (l_proc_name, 'Calling value_to_id');
               Value_To_ID_Conversion  ( p_entity        =>  p_entity
                                        ,p_icc_rec       =>  p_icc_tbl(i)       --- only header record processed rest are ignored
                                        ,p_ag_assoc_rec  =>  g_null_ag_assoc_rec
                                        ,p_func_PARAM_assoc_rec => g_null_func_params_rec
                                        ,p_icc_ver_rec    => g_null_icc_vers_rec
                                        ,x_return_status => l_return_status
                                        ,x_return_msg    => x_return_msg
                                       );

               IF l_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;

                write_debug (l_proc_name, 'Calling icc API ICC NAME=>'||p_icc_tbl(i).item_catalog_name);
                Call_ICC_APIS (   p_icc_rec       => p_icc_tbl(i)
                                 ,x_return_status => x_return_status
                                 ,x_return_msg    => x_return_msg
                               );

               IF x_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;

               --- Successfully processed , mark the record
               ---
               p_icc_tbl(i).process_status := G_PROCESS_STATUS_SUCCESS;




           EXCEPTION
           WHEN e_skip_record THEN
             --- Skip the current record and continue processing for next record
             --- Mark the current record in p_icc_tbl as Error
             --- Message would have been logged by the individual APIs doing the validation
             ---
             p_icc_tbl(i).process_status := G_PROCESS_STATUS_ERROR;

             NULL;
           END;
         END LOOP;

         IF G_Flow_Type = G_EGO_MD_INTF THEN --- if called by API then update the interface table with the process status
           Update_Interface_Table (p_entity => p_entity, p_icc_tbl  => p_icc_tbl);
         END IF;

     END IF;

     --- pl/sql validations for ICC AG associations
     ---
     IF p_entity =  G_ENTITY_ICC_AG_ASSOC THEN

         IF p_ag_assoc_tbl.count = 0 THEN
           --- nothing to process
           ---
           RETURN;
         END IF;

         FOR i in 1..p_ag_assoc_tbl.COUNT
         LOOP
           BEGIN

               Value_To_ID_Conversion  ( p_entity         => p_entity
                                        ,p_icc_rec        => g_null_icc_rec
                                        ,p_ag_assoc_rec   => p_ag_assoc_tbl(i)
                                        ,p_func_PARAM_assoc_rec => g_null_func_params_rec
                                        ,p_icc_ver_rec    => g_null_icc_vers_rec
                                        ,x_return_status  => l_return_status
                                        ,x_return_msg     => x_return_msg
                                       );

               IF l_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;

               /*
               --- not being used currently
               ---
               Attribute_Defaulting ( p_entity         => p_entity
                                     ,p_icc_rec        => p_icc_tbl(i)
                                     ,p_ag_assoc_rec   => p_ag_assoc_tbl(i)
                                     ,p_func_param_assoc_rec => g_null_func_params_rec
                                     ,p_icc_ver_rec    => l_null_icc_vers_rec
                                     ,x_return_status  => x_return_status
                                     ,x_return_msg     => x_return_msg
                                    );

               IF x_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;
               */
                Call_ag_assoc_api  (   p_ag_assoc_rec       => p_ag_assoc_tbl(i)
                                      ,x_return_status => l_return_status
                                      ,x_return_msg    => x_return_msg
                                   );

               IF l_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;

               --- Successfully processed , mark the record
               ---
               p_ag_assoc_tbl(i).process_status := G_PROCESS_STATUS_SUCCESS;



           EXCEPTION
           WHEN e_skip_record THEN
             --- Skip the current record and continue processing for next record
             p_ag_assoc_tbl(i).process_status := G_PROCESS_STATUS_ERROR;
           END;
         END LOOP;
         IF G_Flow_Type = G_EGO_MD_INTF THEN --- if called by API then update the interface table with the process status
           Update_Interface_Table (p_entity => p_entity, p_ag_assoc_tbl  => p_ag_assoc_tbl);
         END IF;


     END IF;


     --- pl/sql validations for ICC Function  associations
     ---
     IF p_entity =  G_ENTITY_ICC_FN_PARAM_MAP THEN

         IF p_func_assoc_tbl.count = 0 THEN
           --- nothing to process
           ---
           RETURN;
         END IF;

         l_entity_code := G_ENTITY_ICC_FN_PARAM_MAP;

         FOR i in 1..p_func_assoc_tbl.COUNT
         LOOP
           BEGIN

               Value_To_ID_Conversion  ( p_entity         => p_entity
                                        ,p_icc_rec        => g_null_icc_rec
                                        ,p_ag_assoc_rec   => g_null_ag_assoc_rec
                                        ,p_func_param_assoc_rec => p_func_assoc_tbl(i)
                                        ,p_icc_ver_rec    => g_null_icc_vers_rec
                                        ,x_return_status  => l_return_status
                                        ,x_return_msg     => x_return_msg
                                       );

               IF l_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;

                 --- not being used currently
                 ---
               /*
               Attribute_Defaulting ( p_entity        => p_entity
                                     ,p_icc_rec       => g_null_icc_rec       --- ignored
                                     ,p_ag_assoc_rec  =>  g_null_ag_assoc_rec  --- only ag assoc record processed rest are ignored
                                     ,p_func_param_assoc_rec => p_func_assoc_tbl(i) --- ignored
                                     ,p_icc_ver_rec    => g_null_icc_vers_rec   --- ignored
                                     ,x_return_status => x_return_status
                                     ,x_return_msg    => x_return_msg
                                    );

               IF x_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF x_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;
               */

                Call_func_param_assoc_api( p_func_param_assoc_rec  => p_func_assoc_tbl(i)
                                          ,x_return_status   => l_return_status
                                          ,x_return_msg      => x_return_msg
                                         );

               IF l_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;

               --- Successfully processed , mark the record
               ---
               p_func_assoc_tbl(i).process_status := G_PROCESS_STATUS_SUCCESS;

           EXCEPTION
           WHEN e_skip_record THEN
             --- Skip the current record and continue processing for next record
             p_func_assoc_tbl(i).process_status := G_PROCESS_STATUS_ERROR;
           END;
         END LOOP;

         /*
         ---
         --- If some of the parameters are not mapped then we have to remove the association
         --- of the function and remove the mapping
         ---
         write_debug(l_proc_name, 'start of param check loop');
         FOR i in 1..p_func_assoc_tbl.COUNT LOOP
           l_func_params_tbl.extend;
           l_func_params_tbl(i) := ego_Func_Param_map_Obj_Type (
                                        p_func_assoc_tbl(i).item_catalog_group_id
                                       ,p_func_assoc_tbl(i).function_id
                                       ,p_func_assoc_tbl(i).parameter_id
                                       ,p_func_assoc_tbl(i).process_status
                                       ,p_func_assoc_tbl(i).item_catalog_name
                                       ,p_func_assoc_tbl(i).function_name
                                       ,p_func_assoc_tbl(i).transaction_id
                                         );
         END LOOP;

         write_debug(l_proc_name, 'start of function verification');
         <<Function_Verification>>
         FOR rec_icc_func  IN ( select item_catalog_group_id
                                     , function_id
                                     , item_catalog_name
                                     , function_name
                                     , min(transaction_id) transaction_id
                                     , count(1) as count
                                from    table ( cast (l_func_params_tbl as ego_FN_Param_Obj_Tbl_Type))
                                where  process_status = G_RET_STS_SUCCESS
                                group by item_catalog_group_id , function_id , item_catalog_name, function_name
                              ) LOOP
             --- For every icc and function_id in params table
             --- get counts from interface table, get total parameters for the function from production
             ---
            FOR rec_prod IN cur_prod_param_count ( rec_icc_func.FUNCTION_ID)
            LOOP
              l_count_frm_func_params := rec_prod.count_prod;
            END LOOP;

            FOR rec_curr IN cur_curr_param_count ( p_function_id => rec_icc_func.FUNCTION_ID, p_icc_id => rec_icc_func.item_catalog_group_id) LOOP
              l_count_frm_ego_maps := rec_curr.count_map;
            END LOOP;

            IF l_count_frm_ego_maps < l_count_frm_func_params THEN
               --- All the function parameters are not mapped
               --- issue a warning to the user
               ---
               l_token_table(1).TOKEN_NAME := 'FUNC_NAME';
               l_token_table(1).TOKEN_VALUE := rec_icc_func.function_name;

               l_token_table(2).TOKEN_NAME := 'ICC_NAME';
               l_token_table(2).TOKEN_VALUE := rec_icc_func.item_catalog_name;


               ERROR_HANDLER.Add_Error_Message(
                p_message_name                  => 'EGO_FUNC_NOT_ASSOC_ICC_PARAM'
               ,p_application_id                => G_APPL_NAME
               ,p_token_tbl                     => l_token_table
               ,p_message_type                  => G_PROCESS_STATUS_WARNING
               ,p_row_identifier                => rec_icc_func.transaction_id
               ,p_entity_code                   => l_entity_code
               ,p_table_name                    => G_ENTITY_ICC_AG_ASSOC
               );
               l_token_table.DELETE;


               --- Check if the function is associated to number generation or desc generation
               ---

               SELECT action_id
               into   l_action_id
               FROM  ego_actions_b
               WHERE function_id = rec_icc_func.function_id
               AND classification_code = to_char(rec_icc_func.item_catalog_group_id)
               ;


               FOR rec_icc_chk   IN cur_icc_column_chk ( L_action_id , rec_icc_func.item_catalog_group_id)
               LOOP

                 Update_Func_ICC_Hdr_Cols  (  p_col_name      => rec_icc_chk.column_name
                                             ,p_icc_id        => rec_icc_func.item_catalog_group_id
                                             ,x_return_status => l_return_status
                                             ,x_return_msg    => x_return_msg
                                           );

                   IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE e_unexpected_error;
                   END IF;

                 EXIT;

               END LOOP;

           --- Delete the function association and mappings
           ---
                Process_Function_Actions (  p_operation => G_TTYPE_DELETE
                                           ,p_action_id        => l_action_id
                                           ,x_action_id        => l_dummy
                                           ,x_return_status    => l_return_status
                                           ,x_return_msg       => x_return_msg
                                         );
                   IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE e_unexpected_error;
                   END IF;


                --- mark the interface table records as Error for that function_id and icc_id
                FOR i in 1..p_func_assoc_tbl.COUNT LOOP

                  IF p_func_assoc_tbl(i).function_id = rec_icc_func.function_id
                      AND p_func_assoc_tbl(i).item_catalog_group_id = rec_icc_func.item_catalog_group_id
                    THEN
                    p_func_assoc_tbl(i).process_status := G_PROCESS_STATUS_ERROR;
                  END IF;

                END LOOP;

            END IF;  ----- l_count_frm_ego_maps < l_count_frm_func_params
         END LOOP Function_Verification;
         **/


         IF G_Flow_Type = G_EGO_MD_INTF THEN --- if called by API then update the interface table with the process status
           Update_Interface_Table (p_entity => p_entity, p_func_assoc_tbl  => p_func_assoc_tbl);
         END IF;

     END IF;  --- pl/sql validations for ICC AF associations


     IF p_entity = G_ENTITY_ICC_VERSION THEN

          write_debug ( l_proc_name, 'No of records=>'||p_icc_vers_tbl.COUNT);
          IF p_icc_vers_tbl.count = 0 THEN
            --- nothing to process
            ---
            RETURN;
          END IF;

          FOR i in 1..p_icc_vers_tbl.COUNT LOOP
             BEGIN

               Value_To_ID_Conversion  ( p_entity         => p_entity
                                        ,p_icc_rec        => g_null_icc_rec
                                        ,p_ag_assoc_rec   => g_null_ag_assoc_rec
                                        ,p_func_param_assoc_rec => g_null_func_params_rec
                                        ,p_icc_ver_rec    => p_icc_vers_tbl(i)
                                        ,p_call_from_icc_process => p_call_from_icc_process
                                        ,x_return_status  => l_return_status
                                        ,x_return_msg     => x_return_msg
                                       );

               IF l_return_status = G_RET_STS_ERROR THEN
                 RAISE e_skip_record;
               ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                 RAISE e_unexpected_error;
               END IF;


               write_debug ( l_proc_name, 'calling vers record=>'||i);
               Call_ICC_Vers_API (  p_icc_vers_rec  => p_icc_vers_tbl(i)
                                   ,x_return_status => l_return_status
                                   ,x_return_msg    => x_return_msg
                                 );
               write_debug ( l_proc_name, 'calling vers status=>'||l_return_status);
                   IF  l_return_status = G_RET_STS_ERROR THEN
                      RAISE e_skip_record;
                   ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE e_unexpected_error;
                   END IF;

               --- Added this call Bug 9791391
               ---
               write_debug ( l_proc_name, 'calling vers record=>'||i);
               Sync_Draft_Version (  p_icc_vers_rec  => p_icc_vers_tbl(i)
                                    ,x_return_status => l_return_status
                                    ,x_return_msg    => x_return_msg
                                  );
               write_debug ( l_proc_name, 'calling sync draft version =>'||l_return_status);
                   IF  l_return_status = G_RET_STS_ERROR THEN
                      RAISE e_skip_record;
                   ELSIF l_return_status = G_RET_STS_UNEXP_ERROR THEN
                     RAISE e_unexpected_error;
                   END IF;



                   --- Successfully processed , mark the record
                   ---
                   p_icc_vers_tbl(i).process_status := G_PROCESS_STATUS_SUCCESS;

             EXCEPTION
             WHEN e_skip_record THEN
               --- Skip the current record and continue processing for next record
               p_icc_vers_tbl(i).process_status := G_PROCESS_STATUS_ERROR;
             END;
           END LOOP;

             IF G_Flow_Type = G_EGO_MD_INTF THEN --- if called by API then update the interface table with the process status
               Update_Interface_Table (p_entity => p_entity, p_icc_vers_tbl => p_icc_vers_tbl);
             END IF;

     END IF;  ---ICC Versions entity

   write_debug (l_proc_name, 'End of  '||l_proc_name);

   EXCEPTION
   WHEN e_unexpected_error THEN
      write_debug(l_proc_name, x_return_msg);
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := x_return_msg||'Stop process error occured in '||G_PKG_NAME||'.'||l_proc_name;
      write_debug(l_proc_name, x_return_msg);
   WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
      write_debug(l_proc_name, x_return_msg);
   end   Process_Entity;


/*************************************************************************************************
---
--- This procedure is used to build the hierarchy for the ICCs
--- in the interface table.
---
--- Techical Design:
---  First get the interface records which are top-most parents ( parent_id is null),
---  mark them as level 0 , then get the immediate children of these parents ( level 1)
--- then get the immediate children of the level 1 records and so on until no records are found
---  process/import the ICC records starting from level 0
**************************************************************************************************/
PROCEDURE Build_ICC_Hierarcy_From_Intf  ( x_icc_hier_tbl   IN OUT NOCOPY ego_ICC_Hier_Tbl_Type
                                         ,x_no_levels         OUT NOCOPY NUMBER
                                       )
IS
  l_proc_name    VARCHAR2(30) := 'Build_ICC_Hierarcy_From_Intf';

  l_icc_hier_rec ego_ICC_Obj_Type;
  l_icc_hier_tbl ego_ICC_Hier_Tbl_Type := ego_ICC_Hier_Tbl_Type();
  i number := 0;
  l_count number := 0;
  l_records_found boolean;
  l_level   number := 0;


  CURSOR cur_select_recs
  is
    select micgi.* ,  0 icc_level
    from MTL_ITEM_CAT_GRPS_INTERFACE micgi
    where (PARENT_CATALOG_GROUP_NAME IS NULL
           OR PARENT_CATALOG_GROUP_ID  IS NOT NULL
          )
     AND  ( ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
     AND process_status = G_PROCESS_STATUS_INITIAL
    ;

  CURSOR cur_select_orph_recs
  is
    select micgi.*
    from MTL_ITEM_CAT_GRPS_INTERFACE micgi
    where (PARENT_CATALOG_GROUP_NAME IS NOT NULL
           AND PARENT_CATALOG_GROUP_ID  IS NULL
          )
     AND  ( ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
     AND process_status = G_PROCESS_STATUS_INITIAL
    ;



  CURSOR cur_select_child_recs ( p_level number)
  is
    select MICGI.* ,  p_level+1 icc_level
    from MTL_ITEM_CAT_GRPS_INTERFACE MICGI
    where parent_catalog_group_name
    in (
        select item_catalog_name
        from table ( cast (l_icc_hier_tbl as ego_ICC_Hier_Tbl_Type) ) a
        where a.icc_level = p_level
       )
     AND  ( ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )

    ;

  l_cur_child_recs   cur_select_child_recs%rowtype;


  cursor cur_fetch_recs
  is
    select item_catalog_name , icc_level
    from table ( cast (l_icc_hier_tbl as ego_ICC_Hier_Tbl_Type ))
    ;


BEGIN

   ---
   --- Built level 0 , top most parents

  for rec_records in cur_select_recs loop

    i:= i+1;
    l_icc_hier_tbl.extend;
    l_icc_hier_tbl(i)   := ego_ICC_Obj_Type(rec_records.ITEM_CATALOG_NAME
                                  , rec_records.ITEM_CATALOG_GROUP_ID
                                  , rec_records.pARENT_CATALOG_GROUP_NAME, rec_records.PARENT_CATALOG_GROUP_ID
                                  , rec_records.TRANSACTION_TYPE
                                  , rec_records.TRANSACTION_ID
                                  , rec_records.icc_level
                                  ) ;

  end loop;

    l_level := 0;

  LOOP
      l_records_found := FALSE;

      FOR rec_child_rec  in cur_select_child_recs ( l_level) loop
          l_icc_hier_tbl.extend;
          l_icc_hier_tbl(l_icc_hier_tbl.LAST)  := ego_ICC_Obj_Type (rec_child_rec.ITEM_CATALOG_NAME
                                                          , rec_child_rec.ITEM_CATALOG_GROUP_ID
                                                          , rec_child_rec.pARENT_CATALOG_GROUP_NAME
                                                          , rec_child_rec.PARENT_CATALOG_GROUP_ID
                                                          , rec_child_rec.TRANSACTION_TYPE
                                                          , rec_child_rec.TRANSACTION_ID
                                                          , rec_child_rec.ICC_LEVEL
                                                          );
          l_records_found := TRUE;
      END LOOP;

    IF NOT l_records_found then
      exit;
    else
      l_level := l_level + 1;
    END IF;

  END LOOP;



  FOR rec_cur_fetch_recs in cur_fetch_recs LOOP
    write_debug(l_proc_name, rec_cur_fetch_recs.ITEM_CATALOG_NAME||'**'||rec_cur_fetch_recs.icc_level);
  END LOOP;


  --- Append the Orphan records as the last level
  ---
   l_level := l_level + 1;
  FOR rec_orphan_icc IN cur_select_orph_recs
  LOOP

    l_icc_hier_tbl.extend;
    l_icc_hier_tbl(l_icc_hier_tbl.LAST)  := ego_ICC_Obj_Type (rec_orphan_icc.ITEM_CATALOG_NAME
                                                      , rec_orphan_icc.ITEM_CATALOG_GROUP_ID
                                                      , rec_orphan_icc.pARENT_CATALOG_GROUP_NAME
                                                      , rec_orphan_icc.PARENT_CATALOG_GROUP_ID
                                                      , rec_orphan_icc.TRANSACTION_TYPE
                                                      , rec_orphan_icc.TRANSACTION_ID
                                                      , l_level
                                                      );

  END LOOP;


  x_icc_hier_tbl := l_icc_hier_tbl;

  write_debug(l_proc_name, ' sql count =>'||l_count);
  write_debug(l_proc_name,' l_icc_hier_tbl.count =>'||l_icc_hier_tbl.count);

  x_no_levels := l_level;

END Build_ICC_Hierarcy_From_Intf;


/********************************************************************
 ---  This procedure concatenated the segment values based
 ---   on the KFF setup and updates the concatenated ICC name
 ---   to the interface table
 ---
********************************************************************/

PROCEDURE Update_ICC_Name_Frm_Segs
IS

  --- these records have passed the bulk validate phase
  ---
  CURSOR cur_update_name_frm_segs
  IS
    select micgi.*
    from MTL_ITEM_CAT_GRPS_INTERFACE micgi
    where item_catalog_name IS NULL
    AND   item_catalog_group_id  IS NULL
    AND  ( ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
     AND process_status = G_PROCESS_STATUS_INITIAL
     FOR UPDATE OF ITEM_CATALOG_NAME;


  l_proc_name        VARCHAR2(40) :=  'Update_ICC_Name_Frm_Segs';
  l_key_flex_field   fnd_flex_key_api.flexfield_type;
  l_structure_type   fnd_flex_key_api.structure_type;
  l_segment_type     fnd_flex_key_api.segment_type;
  l_segment_list     fnd_flex_key_api.segment_list;
  l_segment_array    fnd_flex_ext.SegmentArray;
  l_num_segments     NUMBER;
  l_flag             BOOLEAN;
  l_concat           VARCHAR2(2000);

BEGIN
    write_debug(l_proc_name, 'Start ');

    fnd_flex_key_api.set_session_mode('seed_data');

    l_key_flex_field :=
        fnd_flex_key_api.find_flexfield( G_ITEM_CAT_KFF_APPL,
                                         G_ICC_KFF_NAME
                                       );

    l_structure_type :=
        fnd_flex_key_api.find_structure( l_key_flex_field,
                                         G_STRUCTURE_NUMBER
                                        );

    fnd_flex_key_api.get_segments(l_key_flex_field
                                , l_structure_type
                                , TRUE             -- GET enabled_segments only
                                , l_num_segments
                                , l_segment_list
                                  );
    write_debug(l_proc_name, 'KFF num of segments =>'||l_num_segments);

    FOR rec_icc_name_update in cur_update_name_frm_segs
    LOOP
        --
        -- The segments in the seg_list array are sorted in display order.
        -- i.e. sorted by segment number.
        --
        l_segment_array(1)  := CASE rec_icc_name_update.SEGMENT1 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT1 END;
        l_segment_array(2)  := CASE rec_icc_name_update.SEGMENT2 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT2 END;
        l_segment_array(3)  := CASE rec_icc_name_update.SEGMENT3 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT3 END;
        l_segment_array(4)  := CASE rec_icc_name_update.SEGMENT4 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT4 END;
        l_segment_array(5)  := CASE rec_icc_name_update.SEGMENT5 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT5 END;
        l_segment_array(6)  := CASE rec_icc_name_update.SEGMENT6 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT6 END;
        l_segment_array(7)  := CASE rec_icc_name_update.SEGMENT7 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT7 END;
        l_segment_array(8)  := CASE rec_icc_name_update.SEGMENT8 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT8 END;
        l_segment_array(9)  := CASE rec_icc_name_update.SEGMENT9 WHEN G_MISS_CHAR THEN NULL ELSE  rec_icc_name_update.SEGMENT9 END;
        l_segment_array(10) := CASE rec_icc_name_update.SEGMENT10 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT10 END;
        l_segment_array(11) := CASE rec_icc_name_update.SEGMENT11 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT11 END;
        l_segment_array(12) := CASE rec_icc_name_update.SEGMENT12 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT12 END;
        l_segment_array(13) := CASE rec_icc_name_update.SEGMENT13 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT13 END;
        l_segment_array(14) := CASE rec_icc_name_update.SEGMENT14 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT14 END;
        l_segment_array(15) := CASE rec_icc_name_update.SEGMENT15 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT15 END;
        l_segment_array(16) := CASE rec_icc_name_update.SEGMENT16 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT16 END;
        l_segment_array(17) := CASE rec_icc_name_update.SEGMENT17 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT17 END;
        l_segment_array(18) := CASE rec_icc_name_update.SEGMENT18 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT18 END;
        l_segment_array(19) := CASE rec_icc_name_update.SEGMENT19 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT19 END;
        l_segment_array(20) := CASE rec_icc_name_update.SEGMENT20 WHEN G_MISS_CHAR THEN NULL ELSE rec_icc_name_update.SEGMENT20 END;

        --
        -- Now we have the all segment values in correct order in segarray.
        --
        l_concat := fnd_flex_ext.concatenate_segments(l_num_segments,
                                      l_segment_array,
                                      l_structure_type.segment_separator);


          update MTL_ITEM_CAT_GRPS_INTERFACE
          set item_catalog_name = l_concat
          WHERE CURRENT OF cur_update_name_frm_segs
          ;

    END LOOP;

 write_debug(l_proc_name, 'End... ');
EXCEPTION
WHEN OTHERS THEN
  RAISE;
END  Update_ICC_Name_Frm_Segs;




/********************************************************************
 ---  This procedure constructs the PL/SQL collection for the records
 ---    which have passed the initial bulk validation phase
 ---    , error records will be in status 3, 'valid' records will be in status 1
 ---
********************************************************************/

 PROCEDURE Construct_Colltn_And_Validate (  p_entity IN VARCHAR2
                                           ,p_icc_name IN VARCHAR2 DEFAULT NULL    --- Used by version processing
                                           ,p_icc_id   IN NUMBER DEFAULT NULL    --- Used by version processing
                                           ,x_return_status OUT NOCOPY VARCHAR2
                                           ,x_return_msg  OUT NOCOPY VARCHAR2
                                         )
 IS

     l_ego_icc_tbl      ego_icc_tbl_type;
     l_ego_icc_hier_tbl ego_ICC_Hier_Tbl_Type := ego_ICC_Hier_Tbl_Type();
     l_counter          NUMBER := 0;
     l_level            NUMBER := 0;
     l_ag_assoc_tbl     ego_ag_assoc_tbl_type;
     l_func_params_tbl  ego_func_param_map_tbl_type;
     l_icc_vers_tbl     ego_icc_vers_tbl_type;
     l_proc_name      VARCHAR2(40) :=  'Construct_Colltn_And_Validate';
     e_stop_processing EXCEPTION;
     l_no_levels       NUMBER;
     l_call_from_icc_process VARCHAR2(1) := 'F';
     l_max_seq_id      NUMBER;
     l_max_ver_seq_id  NUMBER;
     l_msg_count       NUMBER;
     l_msg_data        VARCHAR2(2000);
     l_version_processed BOOLEAN := FALSE;


     ---
     --- Pick up the records with process_status = 1
     ---
     CURSOR cur_icc ( p_level NUMBER)
     is
     SELECT *
     FROM MTL_ITEM_CAT_GRPS_INTERFACE
     WHERE  (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            )
     AND process_status = G_PROCESS_STATUS_INITIAL
     AND item_catalog_name IN (
                                        SELECT item_catalog_name
                                        FROM table ( cast (l_ego_icc_hier_tbl as ego_ICC_Hier_Tbl_Type) ) a
                                        WHERE a.icc_level = p_level
                                       )
      ;

     CURSOR cur_icc_no_hier
     is
     SELECT *
     FROM MTL_ITEM_CAT_GRPS_INTERFACE
     WHERE  (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            )
     AND process_status = G_PROCESS_STATUS_INITIAL
     ;



     CURSOR cur_ag_assoc
     is
     SELECT *
     FROM EGO_ATTR_GRPS_ASSOC_INTERFACE
     WHERE  (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            )
     AND process_status = G_PROCESS_STATUS_INITIAL ;


     --- Either process all the eligible version records
     --- or process them by passed ICC Name or ID
     ---
     CURSOR cur_icc_versions
     is
     SELECT *
     FROM EGO_ICC_VERS_INTERFACE
     WHERE process_status = G_PROCESS_STATUS_INITIAL
     AND (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
         )
     AND (
              ( p_icc_id IS NULL )
                OR
              ( item_catalog_group_id =  p_icc_id)
         )
     AND (
              ( p_icc_name IS NULL )
                OR
              ( item_catalog_name = p_icc_name)
         )

     ;



     CURSOR cur_icc_func_params
     is
     SELECT *
     FROM ego_func_params_map_interface
     WHERE  (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            )
     AND process_status = G_PROCESS_STATUS_INITIAL;


     FUNCTION get_max_seq_id ( p_icc_id  NUMBER)
     RETURN NUMBER

     IS
       CURSOR cur_seq_id
       IS
       SELECT MAX(l.lock_id) lock_id
       FROM  EGO_OBJECT_LOCK l
       WHERE l.pk1_value = p_icc_id
       AND   l.object_name = G_ENTITY_ICC_LOCK
       ;
     BEGIN
       l_max_seq_id := 0;
       FOR rec_cur_seq_id in cur_seq_id loop
         l_max_seq_id := rec_cur_seq_id.lock_id;
       end loop;

       return l_max_seq_id;

     END;


 BEGIN
    write_debug (l_proc_name, 'Start of  '||l_proc_name);
    x_return_status    := G_RET_STS_SUCCESS;

   ---*************************
   --- ICC header
   ---
   IF p_entity = G_ENTITY_ICC_HEADER THEN

         --- get the concatenated segs for the ICC name from segment combination
         --- for those records where only segments are populated
         ---
         Update_ICC_Name_Frm_Segs;

         Build_ICC_Hierarcy_From_Intf  ( x_icc_hier_tbl => l_ego_icc_hier_tbl , x_no_levels => l_no_levels);

         IF l_ego_icc_hier_tbl.Count = 0 THEN
           write_debug (l_proc_name, 'No ICC Hierarchy to process');
         END IF;

     <<Level_Loop>>
     LOOP
         IF l_no_levels > 0 THEN
             EXIT WHEN  l_level > l_no_levels;
             OPEN cur_icc ( p_level => l_level);
         ELSE
             OPEN cur_icc_no_hier;
         END IF;

       <<Bulk_Limit_Loop>>
       LOOP

         IF l_no_levels > 0 THEN
            FETCH cur_icc BULK COLLECT INTO l_ego_icc_tbl LIMIT G_MAX_FETCH_SIZE;
         ELSE
            FETCH cur_icc_no_hier BULK COLLECT INTO l_ego_icc_tbl LIMIT G_MAX_FETCH_SIZE;
         END IF;


         write_debug(l_proc_name, 'icc tbl count=>'||l_ego_icc_tbl.count);
         Process_Entity (  p_entity         => G_ENTITY_ICC_HEADER
                      , p_icc_tbl        => l_ego_icc_tbl
                      , p_ag_assoc_tbl   => l_ag_assoc_tbl
                      , p_func_assoc_tbl => l_func_params_tbl
                      , p_icc_vers_tbl   => l_icc_vers_tbl
                      , x_return_status => x_return_status
                      , x_return_msg    => x_return_msg
                     ) ;

         IF x_return_status <> G_RET_STS_SUCCESS THEN
           RAISE e_stop_processing;
         END IF;

         l_counter := l_counter + l_ego_icc_tbl.count;

         IF l_counter >= G_MAX_FETCH_SIZE THEN
           COMMIT WORK;
           l_counter := 0;
         END IF;

         EXIT WHEN l_ego_icc_tbl.count < G_MAX_FETCH_SIZE;
       END LOOP Bulk_Limit_Loop;

       IF l_no_levels > 0 THEN
           CLOSE cur_icc;
           l_level := l_level + 1;
       ELSE
           CLOSE cur_icc_no_hier;
           EXIT;
       END IF;

     END LOOP Level_Loop;



     COMMIT WORK;  --- commit any remaining ICCs



   END IF;    --- End ICC

   ---*************************
   --- AG association
   ---
   IF p_entity = G_ENTITY_ICC_AG_ASSOC THEN
       OPEN cur_ag_assoc;
       LOOP

         FETCH cur_ag_assoc BULK COLLECT INTO l_ag_assoc_tbl LIMIT G_MAX_FETCH_SIZE;

         Process_Entity (  p_entity         => G_ENTITY_ICC_AG_ASSOC
                      , p_icc_tbl        => l_ego_icc_tbl
                      , p_ag_assoc_tbl   => l_ag_assoc_tbl
                      , p_func_assoc_tbl => l_func_params_tbl
                      , p_icc_vers_tbl   => l_icc_vers_tbl
                      , x_return_status => x_return_status
                      , x_return_msg    => x_return_msg
                     ) ;


         IF x_return_status <> G_RET_STS_SUCCESS THEN
           RAISE e_stop_processing;
         END IF;

         ---
         --- commit after every G_MAX_FETCH_SIZE records are processed
         ---
         COMMIT WORK;

         EXIT WHEN l_ag_assoc_tbl.count < G_MAX_FETCH_SIZE;

       END LOOP;
       CLOSE cur_ag_assoc;
   END IF;      --- AG association

   ---*************************
   --- Function params
   ---
   IF p_entity = G_ENTITY_ICC_FN_PARAM_MAP THEN
       OPEN cur_icc_func_params;
       LOOP

         FETCH cur_icc_func_params BULK COLLECT INTO l_func_params_tbl LIMIT G_MAX_FETCH_SIZE;

         Process_Entity (  p_entity         => G_ENTITY_ICC_FN_PARAM_MAP
                      , p_icc_tbl        => l_ego_icc_tbl
                      , p_ag_assoc_tbl   => l_ag_assoc_tbl
                      , p_func_assoc_tbl => l_func_params_tbl
                      , p_icc_vers_tbl   => l_icc_vers_tbl
                      , x_return_status => x_return_status
                      , x_return_msg    => x_return_msg
                     ) ;


         IF x_return_status <> G_RET_STS_SUCCESS THEN
           RAISE e_stop_processing;
         END IF;

         ---
         --- commit after every G_MAX_FETCH_SIZE records are processed
         ---
         COMMIT WORK;

         EXIT WHEN l_func_params_tbl.count < G_MAX_FETCH_SIZE;
       END LOOP;
       CLOSE cur_icc_func_params;
   END IF;      --- End funcion parameters

   ---*************************
   --- ICC Versions
   ---
   IF p_entity = G_ENTITY_ICC_VERSION THEN

       write_debug( l_proc_name, 'start of version processing');



       IF p_icc_name IS NULL THEN
        l_call_from_icc_process := 'F';
       ELSE
        l_call_from_icc_process := 'T';
       END IF;

       WRITE_DEBUG(l_proc_name, 'G_ENTITY_ICC_VERSION ICC, ID=>'||p_icc_name||'*'||p_icc_id);


       OPEN cur_icc_versions;
       LOOP

         FETCH cur_icc_versions BULK COLLECT INTO l_icc_vers_tbl LIMIT G_MAX_FETCH_SIZE;

         Process_Entity (  p_entity         => G_ENTITY_ICC_VERSION
                      , p_icc_tbl        => l_ego_icc_tbl
                      , p_ag_assoc_tbl   => l_ag_assoc_tbl
                      , p_func_assoc_tbl => l_func_params_tbl
                      , p_icc_vers_tbl   => l_icc_vers_tbl
                      , p_call_from_icc_process => l_call_from_icc_process
                      , x_return_status => x_return_status
                      , x_return_msg    => x_return_msg
                     ) ;


         IF x_return_status <> G_RET_STS_SUCCESS THEN
           RAISE e_stop_processing;
         END IF;
         ---
         --- commit after every G_MAX_FETCH_SIZE records are processed
         ---
         COMMIT WORK;

         EXIT WHEN l_icc_vers_tbl.count < G_MAX_FETCH_SIZE;
       END LOOP;
       CLOSE cur_icc_versions;

       ---
       --- Sync the draft to the latest released version
       ---
       IF l_call_from_icc_process = 'T' AND l_icc_vers_tbl.count > 0 THEN

         --- loop to check if any of the version is processed successfully
         ---
         l_version_processed := FALSE;
         for i in 1..l_icc_vers_tbl.count loop
           if l_icc_vers_tbl(i).process_status = G_PROCESS_STATUS_INITIAL then
             l_version_processed := true;
             exit;
           end if;
         end loop;

         --- Get the max version id
         ---
         l_max_ver_seq_id := get_max_seq_id ( p_icc_id => p_icc_id);
         if l_max_ver_seq_id > 0 AND l_version_processed then --- only if it is non draft then sync

                  EGO_TRANSACTION_ATTRS_PVT.Revert_Transaction_Attribute (
                                            p_source_icc_id   => p_icc_id
                                           ,p_source_ver_no  => l_max_ver_seq_id
                                           ,p_init_msg_list  => FALSE
                                           ,x_return_status  => x_return_status
                                           ,x_msg_count      => l_msg_count
                                           ,x_msg_data       => l_msg_data
                                           );

                    IF x_return_status <> G_RET_STS_SUCCESS THEN
                        FND_MSG_PUB.RESET;  --- resets the message index pointer to top of table, since count_and_get is called in above api

                        FOR i in 1..l_msg_count LOOP
                          ERROR_HANDLER.Add_Error_Message(
                            p_message_text                  => FND_MSG_PUB.GET ( p_encoded => FND_API.G_FALSE)
                           ,p_application_id                => G_APPL_NAME
                           ,p_message_type                  => G_TYPE_ERROR
                           --,p_row_identifier
                           ,p_entity_code                   => G_ENTITY_ICC_VERSION
                           ,p_table_name                    => G_ENTITY_ICC_VERS_TAB
                          );
                        END LOOP;
                    END IF;

         end if; ---- l_max_ver_seq_id <> 0


       END IF;


   END IF;      --- End ICC Versions




   write_debug (l_proc_name, 'End of  '||l_proc_name);
 EXCEPTION
 WHEN e_stop_processing THEN
   IF cur_icc%ISOPEN THEN
     CLOSE cur_icc;
   END IF;

   IF cur_icc_no_hier%ISOPEN THEN
     CLOSE cur_icc_no_hier;
   END IF;

   IF cur_ag_assoc%ISOPEN THEN
     CLOSE cur_ag_assoc;
   END IF;

   IF cur_icc_func_params%ISOPEN THEN
     CLOSE cur_icc_func_params;
   END IF;

   IF cur_icc_versions%ISOPEN THEN
     CLOSE cur_icc_versions;
   END IF;


   write_debug(l_proc_name, ' Error while processing n '||G_PKG_NAME||'.'||l_proc_name||'->'||x_return_msg);
   RETURN;
 WHEN OTHERS THEN
   IF cur_icc%ISOPEN THEN
     CLOSE cur_icc;
   END IF;

   IF cur_icc_no_hier%ISOPEN THEN
     CLOSE cur_icc_no_hier;
   END IF;

   IF cur_ag_assoc%ISOPEN THEN
     CLOSE cur_ag_assoc;
   END IF;

   IF cur_icc_func_params%ISOPEN THEN
     CLOSE cur_icc_func_params;
   END IF;
   IF cur_icc_versions%ISOPEN THEN
     CLOSE cur_icc_versions;
   END IF;

   x_return_status := G_RET_STS_UNEXP_ERROR;
   x_return_msg := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
   write_debug(l_proc_name, x_return_msg);
   RETURN;
 END Construct_Colltn_And_Validate;


/********************************************************************
   --- This procedure initializes the global variables
   --- used for processing across all procedures
   ---
********************************************************************/



  PROCEDURE Initialize (p_set_process_id IN  NUMBER
                        ,p_entity         IN VARCHAR2

                       )
  IS
    l_proc_name    VARCHAR2(30) := 'Initialize';
    l_sysdate      DATE := SYSDATE;

  BEGIN

     set_application_id; -- sets the EGO application id

      ---
      --- Set the g_set_process_id AND G_Flow_Type which will be used
      --- for selection of records everywhere
      ---

      G_SET_PROCESS_ID := p_set_process_id;
      G_Flow_Type      := G_EGO_MD_INTF;
      G_PARTY_ID       := GET_PARTY_ID ( G_USER_ID);

      G_P4TP_PROFILE_ENABLED := CASE FND_PROFILE.VALUE('EGO_ENABLE_P4T') WHEN 'Y' THEN TRUE
                                               ELSE FALSE END;



      IF p_entity = G_ENTITY_ICC_HEADER THEN
            write_debug(l_proc_name,'Inside header update ');

            UPDATE MTL_ITEM_CAT_GRPS_INTERFACE
            SET transaction_id = mtl_system_items_interface_s.nextval
               ,transaction_type = upper(transaction_type)
               ,creation_date = nvl(creation_date, l_sysdate)
               ,created_by    = NVL(created_by , G_USER_ID)
               ,last_updated_by = G_USER_ID
               ,last_update_login      = G_LOGIN_ID
               ,last_update_date       = l_sysdate
               ,request_id             = G_CONC_REQUEST_ID
               ,program_application_id = G_PROG_APPL_ID
               ,program_id             = G_PROGRAM_ID
               ,program_update_date    = l_sysdate
            WHERE (
                      ( G_SET_PROCESS_ID IS NULL )
                      OR
                      ( set_process_id =  G_SET_PROCESS_ID)
                  )
            AND transaction_id IS NULL
            AND process_status = G_PROCESS_STATUS_INITIAL
             ;


      ELSIF p_entity =  G_ENTITY_ICC_AG_ASSOC   THEN

             write_debug(l_proc_name,'start ag assoc update ');

            UPDATE EGO_ATTR_GRPS_ASSOC_INTERFACE
            SET transaction_id = mtl_system_items_interface_s.nextval
               ,transaction_type = upper(transaction_type)
               ,creation_date = nvl(creation_date, l_sysdate)
               ,created_by    = NVL(created_by , G_USER_ID)
               ,last_updated_by = G_USER_ID
               ,last_update_login      = G_LOGIN_ID
               ,LAST_UPDATE_DATE       = l_sysdate
               ,request_id             = G_CONC_REQUEST_ID
               ,program_application_id = G_PROG_APPL_ID
               ,program_id             = G_PROGRAM_ID
               ,program_update_date    = l_sysdate
            WHERE (
                      ( G_SET_PROCESS_ID IS NULL )
                      OR
                      ( set_process_id =  G_SET_PROCESS_ID)
                  )
            AND transaction_id IS NULL
            AND process_status = G_PROCESS_STATUS_INITIAL
            ;


      ELSIF p_entity =  G_ENTITY_ICC_FN_PARAM_MAP   THEN

            write_debug(l_proc_name,'start func param update ');

            UPDATE EGO_FUNC_PARAMS_MAP_INTERFACE
            SET transaction_id = mtl_system_items_interface_s.nextval
               ,transaction_type = upper(transaction_type)
               ,creation_date = nvl(creation_date, l_sysdate)
               ,created_by    = NVL(created_by , G_USER_ID)
               ,last_updated_by = G_USER_ID
               ,last_update_login      = G_LOGIN_ID
               ,LAST_UPDATE_DATE       = l_sysdate
               ,request_id             = G_CONC_REQUEST_ID
               ,program_application_id = G_PROG_APPL_ID
               ,program_id             = G_PROGRAM_ID
               ,program_update_date    = l_sysdate
            WHERE (
                      ( G_SET_PROCESS_ID IS NULL )
                      OR
                      ( set_process_id =  G_SET_PROCESS_ID)
                  )
            AND transaction_id IS NULL
            AND process_status = G_PROCESS_STATUS_INITIAL
            ;

      ELSIF p_entity =  G_ENTITY_ICC_VERSION   THEN


            write_debug(l_proc_name,'start icc vers update ');

            UPDATE EGO_ICC_VERS_INTERFACE
            SET transaction_id = mtl_system_items_interface_s.nextval
               ,transaction_type = upper(transaction_type)
               ,creation_date = nvl(creation_date, l_sysdate)
               ,created_by    = NVL(created_by , G_USER_ID)
               ,last_updated_by = G_USER_ID
               ,last_update_login      = G_LOGIN_ID
               ,LAST_UPDATE_DATE       = l_sysdate
               ,request_id             = G_CONC_REQUEST_ID
               ,program_application_id = G_PROG_APPL_ID
               ,program_id             = G_PROGRAM_ID
               ,program_update_date    = l_sysdate
            WHERE (
                      ( G_SET_PROCESS_ID IS NULL )
                      OR
                      ( set_process_id =  G_SET_PROCESS_ID)
                  )
            AND transaction_id IS NULL
            AND process_status = G_PROCESS_STATUS_INITIAL
            ;

      END IF;

  END Initialize;



/********************************************************************
   --- Starting point of call for this package
   ---
********************************************************************/

   PROCEDURE Import_ICC_Intf
    (
       p_set_process_id            IN  NUMBER
    ,  x_return_status             OUT NOCOPY VARCHAR2
    ,  x_return_msg                OUT NOCOPY VARCHAR2

    )
    IS

      l_proc_name VARCHAR2(30) :=  'Import_ICC_Intf';
      e_unexpected_error    EXCEPTION;

    CURSOR cur_icc_count
    IS
    SELECT count(1) count
    FROM   MTL_ITEM_CAT_GRPS_INTERFACE
    WHERE (
              ( G_SET_PROCESS_ID IS NULL )
              OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
    AND transaction_id IS NOT NULL
    AND process_status = G_PROCESS_STATUS_INITIAL
     ;


    CURSOR cur_ag_assoc_count
    IS
    SELECT count(1) count
    FROM   EGO_ATTR_GRPS_ASSOC_INTERFACE
    WHERE (
              ( G_SET_PROCESS_ID IS NULL )
              OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
    AND transaction_id IS NOT NULL
    AND process_status = G_PROCESS_STATUS_INITIAL
     ;


    CURSOR cur_fn_map_count
    IS
    SELECT count(1) count
    FROM   EGO_FUNC_PARAMS_MAP_INTERFACE
    WHERE (
              ( G_SET_PROCESS_ID IS NULL )
              OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
    AND transaction_id IS NOT NULL
    AND process_status = G_PROCESS_STATUS_INITIAL
     ;


    CURSOR cur_icc_ver_count
    IS
    SELECT count(1) count
    FROM   EGO_ICC_VERS_INTERFACE
    WHERE (
              ( G_SET_PROCESS_ID IS NULL )
              OR
              ( set_process_id =  G_SET_PROCESS_ID)
          )
    AND transaction_id IS NOT NULL
    AND process_status = G_PROCESS_STATUS_INITIAL
     ;


    BEGIN
      x_return_status := G_RET_STS_SUCCESS;


      write_debug (l_proc_name, 'Start of  '||l_proc_name);

      --- GET THE item obj id
      ---
      FOR rec_item_obj_id IN cur_get_obj_id loop
        g_item_obj_id := rec_item_obj_id.object_id;
      end loop;

      ---
      --- initializing once since while calling ego_ext_fwk_pub APIS we need not initialize explicitly --
      --- changed during bug 9767869
      ---
      FND_MSG_PUB.initialize;


      write_debug (l_proc_name, 'Calling function metadata load');
      ----*************************
      ---- Functions metadata load
      ----*************************

      EGO_FUNCTIONS_BULKLOAD_PVT.import_functions_intf
                  (p_set_process_id => p_set_process_id
                  ,x_return_status  => x_return_status
                  ,x_return_msg     => x_return_msg
                  );

          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN    --- we expect this API to return only S or U.
            RAISE e_unexpected_error;
          END IF;

      ----*************************
      --- ICC header
      ----*************************
      write_debug (l_proc_name, G_ENTITY_ICC_HEADER);
      ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);

      --- Initialize ICC Header and versions and TAs
      ---
      Initialize (p_set_process_id, G_ENTITY_ICC_HEADER) ;
      Initialize (p_set_process_id, G_ENTITY_ICC_VERSION);
      write_debug (l_proc_name, 'Calling TA Initialize');
      EGO_TA_BULKLOAD_PVT.Initialize  ( p_set_process_id => G_SET_PROCESS_ID
                                       ,x_return_status  => x_return_status
                                      );

      IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
        write_debug (l_proc_name, 'Unexpected error in EGO_TA_BULKLOAD_PVT.Initialize');
        RAISE e_unexpected_error;
      END IF;

      ----************************
      ---- ICC Versions
      ----************************
      --- bulk validation required columns and ver_seq_no
      ---

      Bulk_Validate ( p_entity         => G_ENTITY_ICC_VERSION
                   ,  x_return_status  => x_return_status
                   ,  x_return_msg     => x_return_msg
                    );
      IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
         RAISE e_unexpected_error;
      END IF;


      ----**************************************
      --- Bulk validate TAs
      ----**************************************
      write_debug (l_proc_name, 'Calling TA Bulk_Validate_Trans_Attrs');
      EGO_TA_BULKLOAD_PVT.Bulk_Validate_Trans_Attrs ( p_set_process_id => G_SET_PROCESS_ID);

      --- store the number of records to process for each entity
      ---
      FOR rec_count IN cur_icc_count loop
        g_icc_rec_count := rec_count.COUNT;
      END LOOP;

      write_debug(l_proc_name, 'ICC HEADER count =>'||g_icc_rec_count);

      --- Call validation and import only if there are records to process
      ---
      IF g_icc_rec_count > 0 THEN
          Bulk_Validate ( p_entity         => G_ENTITY_ICC_HEADER
                       ,  x_return_status  => x_return_status
                       ,  x_return_msg     => x_return_msg
                        );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;


          Construct_Colltn_And_Validate ( p_entity        => G_ENTITY_ICC_HEADER
                                      ,  x_return_status  => x_return_status
                                      ,  x_return_msg     => x_return_msg
                                      );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;
      END IF;


      ----*************************
      --- AG assocs
      ----*************************
      write_debug (l_proc_name, G_ENTITY_ICC_AG_ASSOC);

      Initialize (p_set_process_id, G_ENTITY_ICC_AG_ASSOC) ;

      FOR rec_count IN cur_ag_assoc_count loop
        g_ag_assoc_rec_count := rec_count.COUNT;
      END LOOP;

      write_debug(l_proc_name, 'AG Assoc count =>'||g_ag_assoc_rec_count);

      --- Call validation and import only if there are records to process
      ---
      IF g_ag_assoc_rec_count > 0 THEN
          Bulk_Validate ( p_entity         => G_ENTITY_ICC_AG_ASSOC
                       ,  x_return_status  => x_return_status
                       ,  x_return_msg     => x_return_msg
                        );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;


          Construct_Colltn_And_Validate ( p_entity        => G_ENTITY_ICC_AG_ASSOC
                                      ,  x_return_status  => x_return_status
                                      ,  x_return_msg     => x_return_msg
                                      );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;
      END IF;


      ----*************************
      --- Function params
      ----*************************

      write_debug (l_proc_name, G_ENTITY_ICC_FN_PARAM_MAP);

      Initialize (p_set_process_id, G_ENTITY_ICC_FN_PARAM_MAP) ;

      FOR rec_count IN cur_fn_map_count loop
        g_fn_param_map_count := rec_count.COUNT;
      END LOOP;

      write_debug(l_proc_name, 'FN PARAM count =>'||g_fn_param_map_count);

      --- Call validation and import only if there are records to process
      ---
      IF g_fn_param_map_count > 0 THEN

          Bulk_Validate ( p_entity         => G_ENTITY_ICC_FN_PARAM_MAP
                       ,  x_return_status  => x_return_status
                       ,  x_return_msg     => x_return_msg
                        );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;


          Construct_Colltn_And_Validate ( p_entity        => G_ENTITY_ICC_FN_PARAM_MAP
                                      ,  x_return_status  => x_return_status
                                      ,  x_return_msg     => x_return_msg
                                      );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;

      END IF;

      ----*************************
      --- ICC Versions
      ----*************************

      write_debug (l_proc_name, G_ENTITY_ICC_VERSION);

      --- Call validation and import only if there are records to process
      ---
      FOR rec_count IN cur_icc_ver_count loop
        g_icc_vers_rec_count := rec_count.COUNT;
      END LOOP;

      write_debug(l_proc_name, 'ICC vers count =>'||g_icc_vers_rec_count);


      IF g_icc_vers_rec_count > 0 THEN
          --- Initialize the TA table
          ---
          /*
          --- Validations moved to row by row processing
          ---
          Bulk_Validate ( p_entity         => G_ENTITY_ICC_VERSION
                       ,  x_return_status  => x_return_status
                       ,  x_return_msg     => x_return_msg
                        );
          IF x_return_status =   G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;
          */

          ERROR_HANDLER.Set_Bo_Identifier(G_BO_IDENTIFIER_ICC);
          Construct_Colltn_And_Validate ( p_entity        => G_ENTITY_ICC_VERSION
                                      ,  x_return_status  => x_return_status
                                      ,  x_return_msg     => x_return_msg
                                      );
          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN
             RAISE e_unexpected_error;
          END IF;

       END IF;



      ----*************************
      ---- ICC Pages
      ----*************************

      write_debug (l_proc_name, 'Calling Pages metadata load');
      ego_pages_bulkload_pvt.import_pg_intf
                  ( p_set_process_id => p_set_process_id
                   ,x_return_status  => x_return_status
                   ,x_return_msg     => x_return_msg
                  );

          IF x_return_status = G_RET_STS_UNEXP_ERROR THEN    --- we expect this API to return only S or U.
            RAISE e_unexpected_error;
          END IF;


      write_debug (l_proc_name, 'End of  '||l_proc_name);
    EXCEPTION
    WHEN e_unexpected_error THEN
      write_debug(l_proc_name, x_return_msg);
      write_debug(l_proc_name, 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM);
      x_return_msg := x_return_msg||'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name;
      RETURN;
    WHEN OTHERS THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;
      write_debug(l_proc_name, 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM);
      x_return_msg := NVL(x_return_msg,'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM);
      ROLLBACK;
      RETURN;
    END Import_ICC_Intf;

    ---
    --- Procedure to delete the processed records
    --- from the various interface tables
    ---

    PROCEDURE Delete_Processed_ICC  ( p_set_process_id  IN NUMBER
                                   ,  x_return_status    OUT NOCOPY VARCHAR2
                                   ,  x_return_msg       OUT NOCOPY VARCHAR2
    )
    IS


      l_proc_name     VARCHAR2(30) := 'Delete_Processed_ICC';
   BEGIN
     x_return_status := G_RET_STS_SUCCESS;

     DELETE FROM MTL_ITEM_CAT_GRPS_INTERFACE
       WHERE transaction_id IS NOT NULL
       AND process_status = G_PROCESS_STATUS_SUCCESS
       AND (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            );


     DELETE FROM EGO_ATTR_GRPS_ASSOC_INTERFACE
       WHERE transaction_id IS NOT NULL
       AND process_status = G_PROCESS_STATUS_SUCCESS
       AND (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            );



     DELETE FROM EGO_ICC_VERS_INTERFACE
       WHERE transaction_id IS NOT NULL
       AND process_status = G_PROCESS_STATUS_SUCCESS
       AND (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            );



     DELETE FROM ego_func_params_map_interface
       WHERE transaction_id IS NOT NULL
       AND process_status = G_PROCESS_STATUS_SUCCESS
       AND (
              ( G_SET_PROCESS_ID IS NULL )
                OR
              ( set_process_id =  G_SET_PROCESS_ID)
            );


   EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
     x_return_status := G_RET_STS_UNEXP_ERROR;
     x_return_msg  := 'Unexpected error in '||G_PKG_NAME||'.'||l_proc_name||'->'||SQLERRM;
     write_debug(l_proc_name ,x_return_msg);
     RETURN;
   END Delete_Processed_Icc;


 END EGO_ICC_BULKLOAD_PVT;

/
