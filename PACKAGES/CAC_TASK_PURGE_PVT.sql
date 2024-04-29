--------------------------------------------------------
--  DDL for Package CAC_TASK_PURGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_TASK_PURGE_PVT" AUTHID CURRENT_USER AS
/* $Header: cactkpvs.pls 120.4 2005/10/18 08:57:33 sbarat noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cactkpvs.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for the commonly used procedure or    |
 |     function.                                                         |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer             Change                            |
 | ------        ---------------       ----------------------------------|
 | 10-Aug-2005   Swapan Barat          Created                           |
 +======================================================================*/


 G_PKG_NAME      CONSTANT        VARCHAR2(30):='CAC_TASK_PURGE_PUB';


/**
   * Purge Standalone Tasks for a given set of input parameters.
   *
   *@ param errbuf the standard CP variable for error message
   *@ param retcode the standard CP variable for return status
   *@ param p_creation_date_from Creation Date from.
   *@ param p_creation_date_to Creation Date to.
   *@ param p_updation_date_from Updation Date from.
   *@ param p_updation_date_to Updation Date to.
   *@ param p_planned_end_date_from Planned end Date from.
   *@ param p_planned_end_date_to Planned end Date to.
   *@ param p_scheduled_end_date_from Scheduled End Date from.
   *@ param p_scheduled_end_date _to  Scheduled End Date to.
   *@ param p_actual_end_date_from Actual End Date from.
   *@ param p_actual_end_date_to  Actual End Date to.
   *@ param p_task_type_id  Id for a task type
   *@ param p_task_status_Id Id for a given task status.
   *@ param p_delete_closed_task_only   Flag to check if close task has to be deleted.
   *@ param p_delete_deleted_task_only Flag to check if soft deleted task has to be purge from the table.
   *@ param p_no_of_worker To set how many workers to be invoked.
   *@ rep:scope Private
   *@ rep:product CAC
   *@ rep:displayname Purge Task
**/

 Procedure PURGE_STANDALONE_TASKS (
      errbuf				OUT  NOCOPY  VARCHAR2,
      retcode				OUT  NOCOPY  VARCHAR2,
      p_creation_date_from          IN   VARCHAR2 ,
      p_creation_date_to            IN   VARCHAR2 ,
      p_last_updation_date_from     IN   VARCHAR2 ,
      p_last_updation_date_to       IN   VARCHAR2 ,
      p_planned_end_date_from       IN   VARCHAR2 ,
      p_planned_end_date_to         IN   VARCHAR2 ,
      p_scheduled_end_date_from     IN   VARCHAR2 ,
      p_scheduled_end_date_to       IN   VARCHAR2 ,
      p_actual_end_date_from        IN   VARCHAR2 ,
      p_actual_end_date_to          IN   VARCHAR2 ,
      p_task_type_id                IN   NUMBER   DEFAULT  NULL ,
      p_task_status_id              IN   NUMBER   DEFAULT  NULL ,
      p_delete_closed_task_only     IN   VARCHAR2 DEFAULT  fnd_api.g_false ,
      p_delete_deleted_task_only    IN   VARCHAR2 DEFAULT  fnd_api.g_false ,
      p_no_of_worker                IN   NUMBER   DEFAULT  4 );


/**
   * Populate Purge Temp table for a given processing set id and worker id.
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_commit the standard API flag is used by API callers to ask
   * the API to commit on their behalf after performing its function
   * By default, the commit will not be performed.
   * @param p_worker_id   ID for identifying child concurre programme.
   * @param p_concurrent_request_id   ID for identifying TASKs belong to the concurrent program.
   * @rep:scope Private
   * @rep:product CAC
   * @rep:displayname Purge Task Entities
**/

 Procedure POPULATE_PURGE_TMP (
      errbuf		          OUT  NOCOPY  VARCHAR2,
      retcode			    OUT  NOCOPY  VARCHAR2,
      p_api_version               IN           NUMBER ,
      p_init_msg_list             IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_commit                    IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_worker_id                 IN           NUMBER ,
      p_concurrent_request_id     IN           NUMBER );


/**
   * Purge Tasks entities for a given processing set id.
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_commit the standard API flag is used by API callers to ask
   * the API to commit on their behalf after performing its function
   * By default, the commit will not be performed.
   * @param p_processing_set_id   ID for identifying parent of the TASK.
   * @param x_return_status returns the result of all the operations performed
   * by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
   * @param x_msg_count returns the number of messages in the API message list
   * @param x_msg_data returns the message in an encoded format if
   * <code>x_msg_count</code> returns number one.
   * @rep:scope Private
   * @rep:product CAC
   * @rep:displayname Purge Task Entities
**/

 Procedure PURGE_TASK_ENTITIES (
      p_api_version           IN           NUMBER ,
      p_init_msg_list         IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_commit                IN           VARCHAR2 DEFAULT fnd_api.g_false ,
      p_processing_set_id     IN           NUMBER ,
      x_return_status         OUT  NOCOPY  VARCHAR2 ,
      x_msg_data              OUT  NOCOPY  VARCHAR2 ,
      x_msg_count             OUT  NOCOPY  NUMBER ,
      p_object_type           IN           VARCHAR2 );

END CAC_TASK_PURGE_PVT;

 

/
