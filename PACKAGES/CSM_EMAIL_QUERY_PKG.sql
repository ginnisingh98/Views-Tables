--------------------------------------------------------
--  DDL for Package CSM_EMAIL_QUERY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSM_EMAIL_QUERY_PKG" AUTHID CURRENT_USER AS
/* $Header: csmeqps.pls 120.0.12010000.13 2010/06/23 11:53:20 ravir noship $ */


  /*
   * The function to be called by Process Email Mobile Queries concurrent program
   */

-- Purpose: Per-seeded queries and to execute them
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- RAVIR    22 April 2010         Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below
  /*Function to get email preference of an user*/
  FUNCTION GET_EMAIL_PREF
  (p_email_id VARCHAR2)
  RETURN VARCHAR2;

  /*Function to check email id belongs to a single FND_USER*/
  FUNCTION IS_FND_USER
  ( p_email_id VARCHAR2)
  RETURN NUMBER;

  /*Function to check user's access to a mobile query*/
  FUNCTION CHECK_USER_ACCESS
  ( p_user_id     NUMBER,
    p_level_id    NUMBER,
    p_level_value NUMBER)
  RETURN VARCHAR2;

  /*Function to check if user has a vlid assignment for task number*/
  FUNCTION CHECK_TASK_ACCESS
  ( p_user_id       NUMBER,
    p_task_number   NUMBER)
  RETURN VARCHAR2;

  /*Procedure to execute a Mobile Query command from a email_id and return the query results */
  PROCEDURE EXECUTE_COMMAND
  ( p_email_id            IN VARCHAR2,
    p_command_name        IN VARCHAR2,
    p_var_value_lst       IN CSM_VARCHAR_LIST,
    p_instance_id         OUT nocopy NUMBER,
    x_return_status       OUT nocopy VARCHAR2,
    x_error_message       OUT nocopy VARCHAR2
  );

  /*Procedure for Mytasks Mobile Query*/
  PROCEDURE GET_TASKS
  ( p_email_id      IN VARCHAR2,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to update the task status*/
  PROCEDURE UPDATE_TASK
  ( p_task_number     IN NUMBER,
    p_task_status_id  IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

  /*Procedure to update task statu to Accepted*/
  PROCEDURE ACCEPT_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to update task statu to Cancel*/
  PROCEDURE CANCEL_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to update task statu to Closed*/
  PROCEDURE CLOSE_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to update task statu to Traveling*/
  PROCEDURE TRAVELING_TASK
  ( p_task_number     IN NUMBER,
    p_default_status  IN VARCHAR2,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to update task statu to Working*/
  PROCEDURE WORKING_TASK
  ( p_task_number   IN NUMBER,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to update task statu to Completed*/
  PROCEDURE COMPLETED_TASK
  ( p_task_number     IN NUMBER,
    p_default_status  IN VARCHAR2,
    p_result        OUT nocopy  CLOB,
    x_return_status OUT nocopy VARCHAR2,
    x_error_message OUT nocopy VARCHAR2
  );

  /*Procedure to add a task note*/
  PROCEDURE ADD_TASK_NOTE
  ( p_task_number     IN NUMBER,
    p_note_text1      IN VARCHAR2,
    p_note_text2      IN VARCHAR2,
    p_note_visibility IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

  /*Procedure to get the all details of a service request number*/
  PROCEDURE GET_SR_DETAILS
  ( p_sr_number       IN NUMBER,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

  /*Procedure to get the all details of a task number number*/
  PROCEDURE GET_TASK_DETAILS
  ( p_task_number     IN NUMBER,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

  /*Procedure to get the all details entitlements for a serial number*/
  PROCEDURE GET_ENTITLEMENTS
  ( p_serial_number   IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

  /*Procedure to get the information of mobile query command*/
  PROCEDURE HELP_QUERY
  ( p_query_name      IN VARCHAR2,
    p_result          OUT nocopy  CLOB,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

  /*Procedure to set profile to a value */
  FUNCTION SET_PROFILE
  ( p_profile_name  VARCHAR2,
    p_profile_value VARCHAR2
  ) RETURN VARCHAR2;

  /*Procedure to send notification on email exception */
  PROCEDURE NOTIFY_EMAIL_EXCEPTION
  ( p_email_id        IN   VARCHAR2,
    p_subject         IN   VARCHAR2,
    p_message         IN   VARCHAR2,
    x_return_status   OUT nocopy VARCHAR2,
    x_error_message   OUT nocopy VARCHAR2
  );

END CSM_EMAIL_QUERY_PKG;
-- Package spec

/
