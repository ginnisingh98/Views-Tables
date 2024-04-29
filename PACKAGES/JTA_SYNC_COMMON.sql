--------------------------------------------------------
--  DDL for Package JTA_SYNC_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTA_SYNC_COMMON" AUTHID CURRENT_USER AS
/* $Header: jtavscs.pls 120.4 2006/04/12 03:27:18 deeprao ship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   jtavscs.pls                                                         |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for the commonly used procedure or    |
 |        function.                                                      |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date          Developer        Change                                 |
 | ------        ---------------  -------------------------------------- |
 | 01-Feb-2002   rdespoto         Modified                               |
 | 12-Feb-2002   cjang            Added get_userid,get_resourceid,       |
 |                                   get_timezoneid,get_messages         |
 | 27-Feb-2002   hbouten          Added get_territory_code               |
 +======================================================================*/

 /**
 * This package is implemented for the commonly used procedure or function in Contact Sync.
 * @rep:scope private
 * @rep:product CAC
 * @rep:lifecycle active
 * @rep:displayname Synchronization Common
 * @rep:compatibility N
 * @rep:category BUSINESS_ENTITY CAC_SYNC_SERVER
 */
   invalid_num_of_records EXCEPTION;
   sync_success CONSTANT VARCHAR2(7) := 'Success';
   sync_failure CONSTANT VARCHAR2(7) := 'Failure';

 /**
 * This function will return the sequence Id
 * @return The item type number
 * @rep:displayname Get Sequence Id
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   FUNCTION get_seqid
      RETURN NUMBER;

 /**
 * This function will return whether operation was successful
 * @return Is successful
 * @param p_return_status Return status
 * @rep:displayname Is Success
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   FUNCTION is_success (
      p_return_status IN VARCHAR2
      )
      RETURN BOOLEAN;


  /**
 * This procedure will put messages to Result
 * @param p_task_rec Task Record
 * @p_status Status
 * @p_user_message User Message
 * @rep:displayname Put messages to result
 * @rep:lifecycle active
 * @rep:compatibility N
 */
  PROCEDURE put_messages_to_result (
      p_task_rec     IN OUT NOCOPY jta_sync_task.task_rec,
      p_status       IN     NUMBER,
      p_user_message IN     VARCHAR2
   );

  /**
 * This procedure will put messages to Result
 * @param p_contact_rec Contact Record
 * @p_status Status
 * @rep:displayname Put messages to result
 * @rep:lifecycle active
 * @rep:compatibility N
 */
/* Commenting the method for bug # 5029377
  PROCEDURE put_messages_to_result (
      p_contact_rec  IN OUT NOCOPY jta_sync_contact.contact_rec,
      p_status       IN     NUMBER
   );*/



 /**
 * This procedure is for logging to Apps
 * @param p_user_id User Id
 * @rep:displayname Apps Login
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   PROCEDURE apps_login (
      p_user_id IN NUMBER
   );



 /**
 * This procedure is for getting the user Id
 * @param p_user_name User Name
 * @x_user_id User Id
 * @rep:displayname Get User Id
 * @rep:lifecycle active
 * @rep:compatibility N
 */
 PROCEDURE get_userid (p_user_name  IN VARCHAR2
                        ,x_user_id   OUT NOCOPY NUMBER);



 /**
 * This procedure is for getting the Resource Id
 * @param p_user_id User Id
 * @x_resource_id Resource Id
 * @rep:displayname Get Resource Id
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   PROCEDURE get_resourceid (p_user_id      IN NUMBER
                            ,x_resource_id OUT NOCOPY NUMBER);



 /**
 * This procedure is for getting the Timezone Id
 * @param p_timezone_name User Id
 * @x_timezone_id Timezone Id
 * @rep:displayname Get Timezone Id
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   PROCEDURE get_timezoneid (p_timezone_name  IN VARCHAR2
                            ,x_timezone_id   OUT NOCOPY NUMBER);

 /**
 * This function will retrieve the messages
 * @return Messages
 * @rep:displayname Get Messages
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   FUNCTION get_messages
   RETURN VARCHAR2;

   --------------------------------------------------------------------------
   --  API name    : get_territory_code
   --  Type        : Private
   --  Function    : Tries to convert a country into a CRM territory_code
   --  Notes:
   --------------------------------------------------------------------------

 /**
 * This function tries to convert a country into a CRM territory_code
 * @return Territory code
 * @param p_country Country
 * @rep:displayname Get Territory Code
 * @rep:lifecycle active
 * @rep:compatibility N
 */
   FUNCTION get_territory_code
   ( p_country IN     VARCHAR2
   ) RETURN VARCHAR2;

END;

 

/
