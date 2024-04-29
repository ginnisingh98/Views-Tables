--------------------------------------------------------
--  DDL for Package CAC_TASK_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_TASK_PURGE_PUB" AUTHID CURRENT_USER AS
/* $Header: cactkprs.pls 120.4 2005/09/19 09:46:32 rhshriva noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cactkprs.pls                                                         |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for the commonly used procedure or    |
 |        function.                                                      |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date         Developer             Change                             |
 | ------       ---------------       -----------------------------------|
 | 03--2004  Rahul Shrivastava     Created                            |
 +======================================================================*/
   G_PKG_NAME      CONSTANT        VARCHAR2(30):='CAC_TASK_PURGE_PUB';

  /**
     * Purge Tasks for a given set of input parameters.
     *
     * @param p_api_version the standard API version number
     * @param p_init_msg_list the standard API flag allows API callers to request
     * that the API does the initialization of the message list on their behalf.
     * By default, the message list will not be initialized.
     * @param p_commit the standard API flag is used by API callers to ask
     * the API to commit on their behalf after performing its function
     * By default, the commit will not be performed.
     * @param x_return_status returns the result of all the operations performed
     * by the API and must have one of the following values:
     *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
     *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
     *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
     * @param x_msg_count returns the number of messages in the API message list
     * @param x_msg_data returns the message in an encoded format if
     * <code>x_msg_count</code> returns number one.
     *@param p_processing_set_id   ID for identifying parent of the TASK.
     *@param p_object_type   Type of object for which this procedure is being called.
    * @rep:scope INTERNAL
     * @rep:product CAC
     * @rep:displayname Purge Task
*/

  Procedure purge_tasks(
      p_api_version           IN          NUMBER,
      p_init_msg_list         IN          VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                IN          VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status         OUT  NOCOPY VARCHAR2,
      x_msg_data              OUT  NOCOPY VARCHAR2,
      x_msg_count             OUT  NOCOPY NUMBER,
      p_object_type           IN          VARCHAR2,
      p_processing_set_id     IN          NUMBER);



/**
   * Validate Tasks for a given set of input parameters.
   *
   * @param p_api_version the standard API version number
   * @param p_init_msg_list the standard API flag allows API callers to request
   * that the API does the initialization of the message list on their behalf.
   * By default, the message list will not be initialized.
   * @param p_commit the standard API flag is used by API callers to ask
   * the API to commit on their behalf after performing its function
   * By default, the commit will not be performed.
   * @param x_return_status returns the result of all the operations performed
   * by the API and must have one of the following values:
   *   <LI><Code>FND_API.G_RET_STS_SUCCESS</Code>
   *   <LI><Code>FND_API.G_RET_STS_ERROR</Code>
   *   <LI><Code>FND_API.G_RET_STS_UNEXP_ERROR</Code>
   * @param x_msg_count returns the number of messages in the API message list
   * @param x_msg_data returns the message in an encoded format if
   * <code>x_msg_count</code> returns number one.
   *@param p_processing_set_id   ID for identifying parent of the TASK.
   *@param p_object_type   Type of object for which this procedure is being called.
   *@param p_purge_source_with_open_task: default is false. If value is passed as false, code will set the status of SR as 'E' in the global temp table which has open tasks associated to it.
   * @rep:scope INTERNAL
   * @rep:product CAC
   * @rep:displayname Validate Task
*/

   Procedure validate_tasks(
      p_api_version             IN          NUMBER,
      p_init_msg_list           IN          VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                  IN          VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status           OUT  NOCOPY VARCHAR2,
      x_msg_data                OUT  NOCOPY VARCHAR2,
      x_msg_count               OUT  NOCOPY NUMBER,
      p_object_type             IN          VARCHAR2,
      p_processing_set_id       IN          NUMBER,
      p_purge_source_with_open_task IN          VARCHAR2  DEFAULT 'N');



END;

 

/
