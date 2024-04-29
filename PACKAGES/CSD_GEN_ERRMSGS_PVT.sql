--------------------------------------------------------
--  DDL for Package CSD_GEN_ERRMSGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_GEN_ERRMSGS_PVT" AUTHID CURRENT_USER AS
/* $Header: csdvgems.pls 115.4 2004/01/11 05:43:15 vparvath noship $ */

   TYPE csd_errmsgs_rec_type IS RECORD (
      generic_errmsgs_id   NUMBER,
      repair_number        VARCHAR2 (30),
      source_entity_type   VARCHAR2 (80),
      source_entity        VARCHAR2 (80),
      msg_type             VARCHAR2 (80),
      msg                  VARCHAR2 (2000)
   );

   TYPE csd_errmsgs_tbl IS TABLE OF csd_errmsgs_rec_type
      INDEX BY BINARY_INTEGER;


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
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: Purge_Msg                                                                                 */
/* description   : Deletes a single generic message record                                                   */
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
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
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: PURGE_ENTITY_MSGS                                                                         */
/* description   : This API will delete the messages for the given module,entity codes                       */
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
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
   );

/*-----------------------------------------------------------------------------------------------------------*/
/* procedure name: GET_ERRMSGS                                                                               */
/* description   : This API will retrieve the messages from the table, populates the message data structure */
/*                 and returns the messages data structures.
/* Called from   : */
/* Input Parm    : p_api_version         NUMBER      Required Api Version number                             */
/*                 p_init_msg_list       VARCHAR2    Optional Initializes message stack if fnd_api.g_true,   */
/*                                                            default value is fnd_api.g_false               */
/*                 p_commit              VARCHAR2    Optional Commits in API if fnd_api.g_true, default      */
/*                                                            fnd_api.g_false                                */
/*                 p_validation_level    NUMBER      Optional API uses this parameter to determine which     */
/*                                                            validation steps must be done and which steps  */
/*                                                            should be skipped.                             */
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
   );

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
   );


---------------------Temporary
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
   );


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
   );


END csd_gen_errmsgs_pvt;

 

/
