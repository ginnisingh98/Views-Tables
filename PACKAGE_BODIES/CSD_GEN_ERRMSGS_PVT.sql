--------------------------------------------------------
--  DDL for Package Body CSD_GEN_ERRMSGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_GEN_ERRMSGS_PVT" AS
/* $Header: csdvgemb.pls 120.1 2008/05/28 21:40:51 swai ship $ */

   -- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------
   g_pkg_name    CONSTANT VARCHAR2 (30) := 'CSD_GEN_ERRMSGS_PVT';
   g_file_name   CONSTANT VARCHAR2 (12) := 'csdvgemb.pls';
   g_debug_level          NUMBER        := csd_gen_utility_pvt.g_debug_level;
   g_MSG_STATUS_OPEN  VARCHAR2(1)   := 'O';

   FUNCTION validate_module_code (p_module VARCHAR2)
      RETURN BOOLEAN;


/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name:    Save_Fnd_Msgs                                                                          */
/* description   : This api will take the messages on the stack and save them in the generic messages table  */
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_module_code         VARCHAR2    Required module which is saving the message.            */
/*                 p_source_entity_id_1  NUMBER      Required source entity_id 1.                            */
/*                                                            This is usually the repair line id.            */
/*                 p_source_entity_type_code VARCHAR2 Required Seeded entity type code.                      */
/*                                                             Valid values are 'SERIAL_NUMBER',             */
/*                                                             'SERVICE_CODE',                               */
/*                                                             'SOLUTION',                                   */
/*                                                             'ESTIMATE',                                   */
/*                                                             'TASK',                                       */
/*                                                             'WIP',                                        */
/*                 p_source_entity_id_2  NUMBER      Required source entity_id 2.                            */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE save_fnd_msgs (
      p_api_version               IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      p_module_code               IN              VARCHAR2,
      p_source_entity_id1         IN              NUMBER,
      p_source_entity_type_code   IN              VARCHAR2,
      p_source_entity_id2         IN              NUMBER
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_api_version_number   CONSTANT NUMBER          := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30)   := 'Save_Fnd_Msgs';
      l_tmp_char                      VARCHAR2 (1);
      l_msg                           VARCHAR2 (2000) ;
      l_msg_type                      VARCHAR2 (30);
      l_msg_status                    VARCHAR2 (30);
      l_msg_index                     NUMBER;
      l_count                         NUMBER;
      l_generic_errmsgs_id            NUMBER;
      l_msg_dummy                     VARCHAR2(2000);
      -- swai: bug 7122368 and 7119695
      -- add variables to identify and supress cost message from service
      l_app_short_name                VARCHAR2(30);
      l_message_name                  VARCHAR2(30);
   BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS.BEGIN',
                         'Entered SAVE_FND_MSGS'
                        );
      END IF;


      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'Checking required params'
                        );
      END IF;

      -- Check for required parameters
      csd_process_util.check_reqd_param (p_param_value      => p_module_code,
                                         p_param_name       => 'p_module_code',
                                         p_api_name         => l_api_name
                                        );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'module code is ok'
                        );
      END IF;

      csd_process_util.check_reqd_param
                                       (p_param_value      => p_source_entity_id1,
                                        p_param_name       => 'p_source_entity_id1',
                                        p_api_name         => l_api_name
                                       );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'p_source_entity_id1 is ok'
                        );
      END IF;

      csd_process_util.check_reqd_param
                                 (p_param_value      => p_source_entity_type_code,
                                  p_param_name       => 'p_source_entity_type_code',
                                  p_api_name         => l_api_name
                                 );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'p_source_entity_type_code is ok'
                        );
      END IF;

      csd_process_util.check_reqd_param
                                       (p_param_value      => p_source_entity_id2,
                                        p_param_name       => 'p_source_entity_id2',
                                        p_api_name         => l_api_name
                                       );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'p_source_entity_id2 is ok'
                        );
      END IF;

      IF (NOT validate_module_code (p_module => p_module_code))
      THEN
         fnd_message.set_name ('CSD', 'CSD_INVALID_MSG_MODULE');
         fnd_msg_pub.ADD;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'p_msg_module validation passed'
                        );
      END IF;

      fnd_msg_pub.RESET (p_mode => fnd_msg_pub.g_first);
      l_count := fnd_msg_pub.count_msg;

      --Loop thru the message stack and insert into the generic error messages table.
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                         'Count of messages in the stack[' || l_count || ']'
                        );
      END IF;

      FOR l_index IN 1 .. l_count
      LOOP

      -- To get the message type from the message in the stack we need
      -- to use the get_detail api. The message type should have been
      -- added by the add_detail API.
         l_msg := fnd_msg_pub.get_detail (p_encoded => fnd_api.g_true);

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                            'Encoded message[' || l_msg || ']'
                           );
         END IF;

         fnd_message.set_encoded (l_msg);
-- Get the fnd token for associated cols and ignore.
         l_msg_type :=
            fnd_message.get_token
                              (token                    => fnd_msg_pub.G_associated_cols_token_name,
                               remove_from_message      => 'Y'
                              );
--Get the message type from the message type token
         l_msg_type :=
            fnd_message.get_token
                              (token                    => fnd_msg_pub.g_message_type_token_name,
                               remove_from_message      => 'Y'
                              );

         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_statement,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                            'Message type[' || l_msg_type || ']'
                           );
         END IF;

         IF (l_msg_type IS NULL)  --AAA verify
         THEN
            l_msg_type := fnd_msg_pub.g_error_msg;
         END IF;


         -- Message status is hard coded to OPEN.
         l_msg_status := G_MSG_STATUS_OPEN;

         l_msg := fnd_message.get_encoded;
        -- Call this to get the index of current message.
         --FND_MSG_PUB.GET(p_data   => l_msg_dummy,
                        --p_msg_index_out => l_msg_index);

         -- swai: bug 7122368 and 7119695
         -- get the app short name and message name to identify and supress
         -- cost message from service
         fnd_message.PARSE_ENCODED(ENCODED_MESSAGE =>l_msg,
                                   APP_SHORT_NAME=>l_app_short_name,
                                   MESSAGE_NAME=>l_message_name);

         -- Delete the message from the stack.
         --fnd_msg_pub.delete_msg (l_msg_index);


         -- swai: bug 7122368 and 7119695
         -- suppress the CS_COST_NO_CHARGE_EXIST message from charges
         IF (l_msg IS NOT NULL)
            AND NOT (l_app_short_name = 'CS' AND l_message_name = 'CS_COST_NO_CHARGE_EXIST')
         THEN
            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                               'Adding record into generic error messages'
                              );
            END IF;

            l_generic_errmsgs_id := NULL;
            csd_generic_errmsgs_pkg.insert_row
                      (px_generic_errmsgs_id          => l_generic_errmsgs_id,
                       p_module_code                  => p_module_code,
                       p_source_entity_id1            => p_source_entity_id1,
                       p_source_entity_id2            => p_source_entity_id2,
                       p_source_entity_type_code      => p_source_entity_type_code,
                       p_msg_type_code                => l_msg_type,
                       p_msg                          => l_msg,
                       p_msg_status                   => l_msg_status,
                       p_created_by                   => fnd_global.user_id,
                       p_creation_date                => SYSDATE,
                       p_last_updated_by              => fnd_global.user_id,
                       p_last_update_date             => SYSDATE,
                       p_last_update_login            => fnd_global.login_id,
                       p_object_version_number        => 1 -- not needed
                      );

            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
            THEN
               fnd_log.STRING (fnd_log.level_statement,
                               'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                                  'Insert into generic error successful,id['
                               || l_generic_errmsgs_id
                               || ']'
                              );
            END IF;
         END IF;
      END LOOP;

     -- Delete all the messages from the stack.
     fnd_msg_pub.initialize;


-- The commit happens everytime
-- in a separate transaction.
      COMMIT;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS.END',
                         'Leaving SAVE_FND_MSGS'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK;                                     --TO SP_Save_Fnd_Msgs;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK;                                     --TO SP_Save_Fnd_Msgs;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                            'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK;                                     --TO SP_Save_Fnd_Msgs;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.SAVE_FND_MSGS',
                            'SQL Message[' || SQLERRM || ']'
                           );
         END IF;
   END save_fnd_msgs;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: Purge_Msg                                                                                 */
/* description   : Deletes a singel generic message record                                                   */
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_generic_errmsgs_id   NUMBER      Required  KEy field for the messages table             */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE purge_msg (
      p_api_version          IN              NUMBER,
      x_return_status        OUT NOCOPY      VARCHAR2,
      x_msg_count            OUT NOCOPY      NUMBER,
      x_msg_data             OUT NOCOPY      VARCHAR2,
      p_generic_errmsgs_id   IN              NUMBER
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'Purge_Msg';
   BEGIN


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_MSG.BEGIN',
                         'Entered Purge_Msg'
                        );
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      BEGIN
         DELETE FROM csd_generic_errmsgs
               WHERE generic_errmsgs_id = p_generic_errmsgs_id;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            fnd_message.set_name ('CSD', 'CSD_INVALID_ERRMSGS_ID');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         WHEN OTHERS
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      COMMIT;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_MSG.END',
                         'Leaving Purge_Msg'
                        );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK TO sp_purge_msg;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_MSG',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_purge_msg;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_MSG',
                            'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK TO sp_purge_msg;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_MSG',
                            'SQL Message[' || SQLERRM || ']'
                           );
         END IF;
   END purge_msg;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: PURGE_ENTITY_MSGS                                                                         */
/* description   : This API will delete the messages for the given module,entity codes                       */
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_module_code         VARCHAR2    Required module which is saving the message.            */
/*                 p_source_entity_id_1  NUMBER      optional source entity_id 1.                            */
/*                                                            This is usually the repair line id.            */
/*                 p_source_entity_type_code VARCHAR2 Optional Seeded entity type code.                      */
/*                                                             Valid values are 'SERIAL_NUMBER',             */
/*                                                             'SERVICE_CODE',                               */
/*                                                             'SOLUTION',                                   */
/*                                                             'ESTIMATE',                                   */
/*                                                             'TASK',                                       */
/*                                                             'WIP',                                        */
/*                 p_source_entity_id_2  NUMBER      Optional source entity_id 2.                            */
/* Output Parm   : x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE purge_entity_msgs (
      p_api_version               IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      p_module_code               IN              VARCHAR2,
      p_source_entity_id1         IN              NUMBER,
      p_source_entity_type_code   IN              VARCHAR2,
      p_source_entity_id2         IN              NUMBER
   )
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'PURGE_ENTITY_MSGS';
   BEGIN

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                    (fnd_log.level_procedure,
                     'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS.BEGIN',
                     'Entered PURGE_ENTITY_MSGS'
                    );
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;
      -- Check for required parameters
      csd_process_util.check_reqd_param (p_param_value      => p_module_code,
                                         p_param_name       => 'p_module_code',
                                         p_api_name         => l_api_name
                                        );

      BEGIN
         DELETE FROM csd_generic_errmsgs
               WHERE module_code = p_module_code
                 AND (   source_entity_id1 = p_source_entity_id1
                      OR p_source_entity_id1 IS NULL
                     )
                 AND (   source_entity_type_code = p_source_entity_type_code
                      OR p_source_entity_type_code IS NULL
                     )
                 AND (   source_entity_id2 = p_source_entity_id2
                      OR p_source_entity_id2 IS NULL
                     );
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            NULL;
         WHEN OTHERS
         THEN
            RAISE fnd_api.g_exc_unexpected_error;
      END;

      COMMIT;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                      (fnd_log.level_procedure,
                       'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS.END',
                       'Leaving PURGE_ENTITY_MSGS'
                      );
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         ROLLBACK;                                 --TO SP_PURGE_ENTITY_MSGS;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_error,
                           'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS',
                           'EXC_ERROR[' || x_msg_data || ']'
                          );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK;                                 --TO SP_PURGE_ENTITY_MSGS;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_exception,
                           'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS',
                           'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']'
                          );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         ROLLBACK;                                 --TO SP_PURGE_ENTITY_MSGS;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                          (fnd_log.level_exception,
                           'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS',
                           'SQL Message[' || SQLERRM || ']'
                          );
         END IF;
   END purge_entity_msgs;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: GET_ERRMSGS                                                                               */
/* description   : This API will retrieve the messages from the table, populates the message data structure */
/*                 and returns the messages data structures.
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_module_code         VARCHAR2    Required module which is saving the message.            */
/*                 p_source_entity_id_1  NUMBER      optional source entity_id 1.                            */
/*                                                            This is usually the repair line id.            */
/*                 p_source_entity_type_code VARCHAR2 Optional Seeded entity type code.                      */
/*                                                             Valid values are 'SERIAL_NUMBER',             */
/*                                                             'SERVICE_CODE',                               */
/*                                                             'SOLUTION',                                   */
/*                                                             'ESTIMATE',                                   */
/*                                                             'TASK',                                       */
/*                                                             'WIP',                                        */
/*                 p_source_entity_id_2  NUMBER      Optional source entity_id 2.                            */
/* Output Parm   : x_errmsgs_tbl         CSD_ERRMSGS_TBL       table of message records                      */
/*                 x_return_status       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 x_msg_count           NUMBER               Number of messages in the message stack        */
/*                 x_msg_data            VARCHAR2             Message text if x_msg_count >= 1               */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE get_errmsgs (
      p_api_version               IN              NUMBER,
      p_init_msg_list             IN              VARCHAR2,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      p_module_code               IN              VARCHAR2,
      p_source_entity_id_1        IN              NUMBER,
      p_source_entity_type_code   IN              VARCHAR2,
      p_source_entity_id_2        IN              NUMBER,
      x_errmsgs_tbl               OUT NOCOPY      csd_errmsgs_tbl
   )
   IS
      l_api_version_number   CONSTANT NUMBER        := 1.0;
      l_api_name             CONSTANT VARCHAR2 (30) := 'GET_ERRMSGS';
      l_index                         NUMBER;
      l_msg_index                     NUMBER;

      -- Fix for Bug 3824988, sragunat, 11/16/04, Bind Variable fix,
	 -- Introduced the following constants to use in Cursor cur_generic_errmsgs
	 -- query
      lc_msg_entity_lkp_typ  CONSTANT VARCHAR2(24) := 'CSD_MSG_ENTITY_TYPE_CODE' ;
	 lc_msg_typ_lkp_typ     CONSTANT VARCHAR2(17)  := 'CSD_MSG_TYPE_CODE' ;


      CURSOR cur_generic_errmsgs (
         p_module        VARCHAR2,
         p_entity_type   VARCHAR2,
         p_entity_id1    NUMBER,
         p_entity_id2    NUMBER
      )
      IS
         SELECT b.repair_number, c.meaning source_entity_type,
                a.source_entity_type_code source_entity_type_code,
                d.meaning msg_type, a.msg, a.generic_errmsgs_id,
                a.source_entity_id2
           FROM csd_generic_errmsgs a,
                csd_repairs_v b,
                fnd_lookups c,
                fnd_lookups d
          WHERE b.repair_line_id = a.source_entity_id1
            AND c.lookup_code = a.source_entity_type_code
            AND c.lookup_type = lc_msg_entity_lkp_typ
            AND d.lookup_code = a.msg_type_code
            AND d.lookup_type = lc_msg_typ_lkp_typ
            AND a.module_code = p_module
            AND a.source_entity_id1 = p_entity_id1
            AND (   a.source_entity_type_code = p_entity_type
                 OR p_entity_type IS NULL
                )
            AND (a.source_entity_id2 = p_entity_id2 OR p_entity_id2 IS NULL);

      CURSOR cur_serial_num (p_entity_id NUMBER)
      IS
         SELECT serial_number
           FROM csd_mass_ro_sn
          WHERE mass_ro_sn_id = p_entity_id;

      CURSOR cur_service_code (p_entity_id NUMBER)
      IS
         SELECT service_code
           FROM csd_service_codes_vl
          WHERE service_code_id = p_entity_id;

      CURSOR cur_solution_code (p_entity_id NUMBER)
      IS
         SELECT NVL (set_name, set_id)
           FROM cs_kb_sets_vl
          WHERE set_id = p_entity_id;

      CURSOR cur_estimate_desc (p_entity_id NUMBER)
      IS
         SELECT NVL (work_summary, repair_estimate_id)
           FROM csd_repair_estimate
          WHERE repair_estimate_id = p_entity_id;

      CURSOR cur_wip_name (p_entity_id NUMBER)
      IS
         SELECT NVL (wip_entity_name, wip_entity_id) --- AAA not required
           FROM wip_entities
          WHERE wip_entity_id = p_entity_id;

      CURSOR cur_task_name (p_entity_id NUMBER)
      IS
         SELECT NVL (task_name, task_number) ---AAA nvl not required
           FROM csf_debrief_headers_v
          WHERE task_id = p_entity_id;
   BEGIN


      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS.BEGIN',
                         'Entered GET_ERRMSGS'
                        );
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list)
      THEN
         -- initialize message list
         fnd_msg_pub.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version_number,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- initialize return status
      x_return_status := fnd_api.g_ret_sts_success;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'Checking for required parameters'
                        );
      END IF;

      -- Check for required parameters
      csd_process_util.check_reqd_param (p_param_value      => p_module_code,
                                         p_param_name       => 'p_module_code',
                                         p_api_name         => l_api_name
                                        );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'module code is ok'
                        );
      END IF;

      -- Check for required parameters
      csd_process_util.check_reqd_param
                                      (p_param_value      => p_source_entity_id_1,
                                       p_param_name       => 'p_source_entity_id_1',
                                       p_api_name         => l_api_name
                                      );

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'p_source_entity_id_1 is ok'
                        );
      END IF;

      l_index := 1;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'p_module_code=[' || p_module_code || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                            'p_source_entity_type_code=['
                         || p_source_entity_type_code
                         || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'p_source_entity_id_1=[' || p_source_entity_id_1
                         || ']'
                        );
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'p_source_entity_id_2=[' || p_source_entity_id_2
                         || ']'
                        );
      END IF;

      FOR msg_rec IN cur_generic_errmsgs (p_module_code,
                                          p_source_entity_type_code,
                                          p_source_entity_id_1,
                                          p_source_entity_id_2
                                         )
      LOOP
         x_errmsgs_tbl (l_index).generic_errmsgs_id :=
                                                   msg_rec.generic_errmsgs_id;
         x_errmsgs_tbl (l_index).repair_number := msg_rec.repair_number;
         x_errmsgs_tbl (l_index).source_entity_type :=
                                                   msg_rec.source_entity_type;
         x_errmsgs_tbl (l_index).msg_type := msg_rec.msg_type;

         --Case stmt to get the correct entity id
         IF (msg_rec.source_entity_type_code = 'SERIAL_NUMBER')
         THEN
            OPEN cur_serial_num (msg_rec.source_entity_id2);

            FETCH cur_serial_num
             INTO x_errmsgs_tbl (l_index).source_entity;

            IF (cur_serial_num%NOTFOUND)
            THEN
               x_errmsgs_tbl (l_index).source_entity := '';
            END IF;

            CLOSE cur_serial_num;
         ELSIF (msg_rec.source_entity_type_code = 'SERVICE_CODE')
         THEN
            OPEN cur_service_code (msg_rec.source_entity_id2);

            FETCH cur_service_code
             INTO x_errmsgs_tbl (l_index).source_entity;

            IF (cur_service_code%NOTFOUND)
            THEN
               x_errmsgs_tbl (l_index).source_entity := '';
            END IF;

            CLOSE cur_service_code;
         ELSIF (msg_rec.source_entity_type_code = 'SOLUTION')
         THEN
            OPEN cur_solution_code (msg_rec.source_entity_id2);

            FETCH cur_solution_code
             INTO x_errmsgs_tbl (l_index).source_entity;

            IF (cur_solution_code%NOTFOUND)
            THEN
               x_errmsgs_tbl (l_index).source_entity := '';
            END IF;

            CLOSE cur_solution_code;
         ELSIF (msg_rec.source_entity_type_code = 'ESTIMATE')
         THEN
            OPEN cur_estimate_desc (msg_rec.source_entity_id2);

            FETCH cur_estimate_desc
             INTO x_errmsgs_tbl (l_index).source_entity;

            IF (cur_estimate_desc%NOTFOUND)
            THEN
               x_errmsgs_tbl (l_index).source_entity := '';
            END IF;

            CLOSE cur_estimate_desc;
         ELSIF (msg_rec.source_entity_type_code = 'TASK')
         THEN
            OPEN cur_task_name (msg_rec.source_entity_id2);

            FETCH cur_task_name
             INTO x_errmsgs_tbl (l_index).source_entity;

            IF (cur_task_name%NOTFOUND)
            THEN
               x_errmsgs_tbl (l_index).source_entity := '';
            END IF;

            CLOSE cur_task_name;
         ELSIF (msg_rec.source_entity_type_code = 'WIP')
         THEN
            OPEN cur_wip_name (msg_rec.source_entity_id2);

            FETCH cur_wip_name
             INTO x_errmsgs_tbl (l_index).source_entity;

            IF (cur_wip_name%NOTFOUND)
            THEN
               x_errmsgs_tbl (l_index).source_entity := '';
            END IF;

            CLOSE cur_wip_name;
         END IF;

         fnd_message.set_encoded (msg_rec.msg);
         x_errmsgs_tbl (l_index).msg := fnd_message.get;
         l_index := l_index + 1;
      END LOOP;

      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_statement,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                         'Populated errmsgs table'
                        );
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING (fnd_log.level_procedure,
                         'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS.END',
                         'Leaving GET_ERRMSGS'
                        );
      END IF;

      -- Standard call to get message count and IF count is  get message info.
      fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                 p_data       => x_msg_data);
   EXCEPTION
      WHEN fnd_api.g_exc_error
      THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_error >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_error,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                            'EXC_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN fnd_api.g_exc_unexpected_error
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_exception,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                            'EXC_UNEXPECTED_ERROR[' || x_msg_data || ']'
                           );
         END IF;
      WHEN OTHERS
      THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error)
         THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (p_count      => x_msg_count,
                                    p_data       => x_msg_data
                                   );

         IF (fnd_log.level_unexpected >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING (fnd_log.level_unexpected,
                            'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.GET_ERRMSGS',
                            'SQL Message[' || SQLERRM || ']'
                           );
         END IF;
   END get_errmsgs;

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: PURGE_ENTITY_MSGS_CP                                                                        */
/* description   : This API will delete the messages for the given module,entity codes                       */
/* Called from   : */
/* Input Parm    : p_module_code         VARCHAR2    Required module which is saving the message.            */
/*                 p_source_entity_id_1  NUMBER      optional source entity_id 1.                            */
/*                                                            This is usually the repair line id.            */
/*                 p_source_entity_type_code VARCHAR2 Optional Seeded entity type code.                      */
/*                                                             Valid values are 'SERIAL_NUMBER',             */
/*                                                             'SERVICE_CODE',                               */
/*                                                             'SOLUTION',                                   */
/*                                                             'ESTIMATE',                                   */
/*                                                             'TASK',                                       */
/*                                                             'WIP',                                        */
/*                 p_source_entity_id_2  NUMBER      Optional source entity_id 2.                            */
/* Output Parm   : errbuf       VARCHAR2             Return status after the call. The status can be*/
/*                                                            fnd_api.g_ret_sts_success (success)            */
/*                                                            fnd_api.g_ret_sts_error (error)                */
/*                                                            fnd_api.g_ret_sts_unexp_error (unexpected)     */
/*                 retcode      NUMBER               Number of messages in the message stack        */
/*-----------------------------------------------------------------------------------------------------------*/
   PROCEDURE purge_entity_msgs_cp (
      errbuf          OUT NOCOPY      VARCHAR2,
      retcode         OUT NOCOPY      NUMBER,
      p_module_code   IN              VARCHAR2
   )
   IS
      l_return_status   VARCHAR2 (30);
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2 (2000);
      l_msg_index_out   NUMBER;
      l_index           NUMBER;
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                 (fnd_log.level_procedure,
                  'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS_CP.BEGIN',
                  'Entered PURGE_ENTITY_MSGS_CP'
                 );
      END IF;

      errbuf := NULL;
      retcode := 0;
      -- Call the procedure to purge the messages.
      purge_entity_msgs (p_api_version                  => 1.0,
                         p_module_code                  => p_module_code,
                         p_source_entity_id1            => NULL,
                         p_source_entity_type_code      => NULL,
                         p_source_entity_id2            => NULL,
                         x_return_status                => l_return_status,
                         x_msg_count                    => l_msg_count,
                         x_msg_data                     => l_msg_data
                        );

      IF (l_return_status <> fnd_api.g_ret_sts_success)
      THEN
         FOR l_index IN 1 .. l_msg_count
         LOOP
             fnd_msg_pub.get (p_msg_index          => l_index,
                              p_encoded            => fnd_api.g_false,
                              p_data               => l_msg_data,
                              p_msg_index_out      => l_msg_index_out
                             );
             IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
             THEN
                 fnd_log.STRING
                          (fnd_log.level_exception,
                           'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS_CP',
                           'Error message [' || l_msg_data || ']'
                          );
             END IF;
             fnd_file.put_line (fnd_file.LOG, l_msg_data);
             fnd_file.put_line (fnd_file.output, l_msg_data);
         END LOOP;
         errbuf := l_msg_data;
         retcode := 1;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                   (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS_CP.END',
                    'Leaving PURGE_ENTITY_MSGS_CP'
                   );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                       (fnd_log.level_exception,
                        'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.PURGE_ENTITY_MSGS_CP',
                        'SQL Message[' || SQLERRM || ']'
                       );
         END IF;
   END purge_entity_msgs_cp;

/******************************************************
Funciton to validate module code
*****************************************************/
   FUNCTION validate_module_code (p_module VARCHAR2)
      RETURN BOOLEAN
   IS
      -- Fix for Bug 3824988, sragunat, 11/16/04, Bind Variable fix,
	 -- Introduced the following constants to use in Cursor cur_module_lookup
	 -- query
      lc_module_code_lkp_typ CONSTANT VARCHAR2(19) := 'CSD_MSG_MODULE_CODE' ;
	 lc_enabled             CONSTANT VARCHAR2(1)  := 'Y';

      CURSOR cur_module_lookup (p_module_code VARCHAR2)
      IS
         SELECT 'x'
           FROM fnd_lookups
          WHERE lookup_type = lc_module_code_lkp_typ
            AND lookup_code = p_module_code
            AND enabled_flag = lc_enabled
            AND (   TRUNC (SYSDATE) >= TRUNC (start_date_active)
                 OR start_date_active IS NULL
                )
            AND (   TRUNC (SYSDATE) < TRUNC (end_date_active)
                 OR end_date_active IS NULL
                );

      l_tmp_char   VARCHAR2 (1);
   BEGIN
      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                 (fnd_log.level_procedure,
                  'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.VALIDATE_MODULE_CODE.BEGIN',
                  'Entered VALIDATE_MODULE_CODE'
                 );
      END IF;

      OPEN cur_module_lookup (p_module);

      FETCH cur_module_lookup
       INTO l_tmp_char;

      IF (cur_module_lookup%FOUND)
      THEN
         RETURN TRUE;
      ELSE
         RETURN FALSE;
      END IF;

      IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level)
      THEN
         fnd_log.STRING
                   (fnd_log.level_procedure,
                    'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.VALIDATE_MODULE_CODE.END',
                    'Leaving VALIDATE_MODULE_CODE'
                   );
      END IF;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF (fnd_log.level_exception >= fnd_log.g_current_runtime_level)
         THEN
            fnd_log.STRING
                       (fnd_log.level_exception,
                        'CSD.PLSQL.CSD_GEN_ERRMSGS_PVT.VALIDATE_MODULE_CODE',
                        'SQL Error[' || SQLERRM || ']'
                       );
         END IF;

         RETURN FALSE;
   END validate_module_code;

-------------------------- Tremporary
   PROCEDURE save_fnd_msgs (
      p_api_version               IN              NUMBER,
      p_commit                 IN              VARCHAR2,
      p_init_msg_list          IN              VARCHAR2,
      p_validation_level       IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      p_module_code               IN              VARCHAR2,
      p_source_entity_id1         IN              NUMBER,
      p_source_entity_type_code   IN              VARCHAR2,
      p_source_entity_id2         IN              NUMBER
   ) IS
  BEGIN

       save_fnd_msgs( p_api_version => p_api_version,
                      x_return_status => x_return_Status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_Data,
                      p_module_code   => p_module_code,
                      p_source_entity_id1 => p_source_entity_id1,
                      p_source_entity_type_code => p_source_entity_type_code,
                      p_source_entity_id2 => p_source_entity_id2);

  END save_fnd_msgs;


  PROCEDURE purge_entity_msgs (
      p_api_version               IN              NUMBER,
      p_commit                 IN              VARCHAR2,
      p_init_msg_list          IN              VARCHAR2,
      p_validation_level       IN              NUMBER,
      x_return_status             OUT NOCOPY      VARCHAR2,
      x_msg_count                 OUT NOCOPY      NUMBER,
      x_msg_data                  OUT NOCOPY      VARCHAR2,
      p_module_code               IN              VARCHAR2,
      p_source_entity_id1         IN              NUMBER,
      p_source_entity_type_code   IN              VARCHAR2,
      p_source_entity_id2         IN              NUMBER
   ) IS
   BEGIN
      purge_entity_msgs (p_api_version                  => p_api_version,
                         p_module_code                  => p_module_code,
                         p_source_entity_id1            => p_source_entity_id1,
                         p_source_entity_type_code      => p_source_entity_type_code,
                         p_source_entity_id2            => p_source_entity_id2,
                         x_return_status                => x_return_status,
                         x_msg_count                    => x_msg_count,
                         x_msg_data                     => x_msg_data
                        );
   END purge_entity_msgs;


END csd_gen_errmsgs_pvt;

/
