--------------------------------------------------------
--  DDL for Package JTF_TASK_CONFIRMATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TASK_CONFIRMATION_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfptcfs.pls 120.1 2005/07/02 00:58:17 appldev noship $ */
 /*#
  * This is the public interface to set task confirmation counter
  * and status
  *
  * @rep:scope internal
  * @rep:product CAC
  * @rep:lifecycle active
  * @rep:displayname Task Confirmation
  * @rep:compatibility S
  * @rep:category BUSINESS_ENTITY CAC_CAL_TASK
  */


  /*#
   * sets the customer confirmation status and counter.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @param p_task_confirmation_status is the task confirmation status of the
   * task to be updated in jtf_tasks_b table.
   * @param p_task_confirmation_counter is the task confirmation counter of the
   * task to be updated in jtf_tasks_b table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */

   PROCEDURE SET_COUNTER_STATUS  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY   NUMBER,
    p_task_id	      IN       NUMBER,
    p_task_confirmation_status	      IN       VARCHAR2,
    p_task_confirmation_counter	      IN       NUMBER
   );



  /*#
   * Resets the customer confirmation counter to zero.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */

   PROCEDURE RESET_COUNTER  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY   NUMBER,
    p_task_id	      IN       NUMBER
   );

  /*#
   * Increases the customer confirmation counter by 1.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */

   PROCEDURE INCREASE_COUNTER  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
   );

  /*#
   * Decreases the customer confirmation counter by 1.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */

   PROCEDURE DECREASE_COUNTER  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY   NUMBER,
    p_task_id	      IN       NUMBER
   );

  /*#
   * Changes the sign of the customer confirmation.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */
   PROCEDURE CHANGE_COUNTER_SIGN  (
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
   );

  /*#
   * Resets the customer confirmation status to "N" and Counter to 0.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */
   PROCEDURE RESET_CONFIRMATION_STATUS(
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
   );

  /*#
   * Resets the customer confirmation status to "R", Required.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */
   PROCEDURE SET_CONFIRMATION_REQUIRED(
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
   );

  /*#
   * Resets the customer confirmation status to "C", Confirmed.
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
   *
   * @param p_object_version_number is the object version number of the
   * task that is to be updated.
   * @param p_task_id is the task id of the task to be updated in jtf_tasks_b
   * table.
   * @paraminfo {@rep:precision 6000}
   *
   * @rep:scope internal
   * @rep:lifecycle active
   * @rep:displayname Reset Customer Confirmation Counter
   * @rep:compatibility S
   */
   PROCEDURE SET_CONFIRMATION_CONFIRMED(
    p_api_version	  IN	   NUMBER,
    p_init_msg_list	  IN	   VARCHAR2 DEFAULT fnd_api.g_false,
    p_commit	      IN       VARCHAR2 DEFAULT fnd_api.g_false,
    x_return_status	  OUT NOCOPY	   VARCHAR2,
    x_msg_count       OUT NOCOPY       NUMBER,
    x_msg_data	      OUT NOCOPY       VARCHAR2,
    p_object_version_number   IN OUT NOCOPY  NUMBER,
    p_task_id	      IN       NUMBER
   );

END;

 

/
