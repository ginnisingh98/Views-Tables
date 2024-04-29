--------------------------------------------------------
--  DDL for Package CAC_SYNC_COMMON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_SYNC_COMMON" AUTHID CURRENT_USER AS
/* $Header: cacstcos.pls 120.4 2005/09/27 09:24:14 rhshriva noship $ */
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
 | Date         Developer             Change                             |
 | ------       ---------------       -----------------------------------|
 | 01-Feb-2004  Sanjeev K. Choudhary  Created                            |
 +======================================================================*/
   invalid_num_of_records EXCEPTION;
   sync_success CONSTANT VARCHAR2(7) := 'Success';
   sync_failure CONSTANT VARCHAR2(7) := 'Failure';

   FUNCTION get_seqid
      RETURN NUMBER;

   FUNCTION is_success (
      p_return_status IN VARCHAR2
      )
      RETURN BOOLEAN;

  PROCEDURE put_messages_to_result (
      p_task_rec     IN OUT NOCOPY cac_sync_task.task_rec,
      p_status       IN     NUMBER,
      p_user_message IN     VARCHAR2,
      p_token_name   IN     VARCHAR2  default null,
      p_token_value  IN     VARCHAR2  default null
   );

  /* PROCEDURE put_messages_to_result (
      p_contact_rec  IN OUT NOCOPY cac_sync_contact.contact_rec,
      p_status       IN     NUMBER
   );  */

   PROCEDURE apps_login (
      p_user_id IN NUMBER
   );

   PROCEDURE get_userid (p_user_name  IN VARCHAR2
                        ,x_user_id   OUT NOCOPY NUMBER);

   PROCEDURE get_resourceid (p_user_id      IN NUMBER
                            ,x_resource_id OUT NOCOPY NUMBER);

   PROCEDURE get_timezoneid (p_timezone_name  IN VARCHAR2
                            ,x_timezone_id   OUT NOCOPY NUMBER);
   FUNCTION get_messages
   RETURN VARCHAR2;

   --------------------------------------------------------------------------
   --  API name    : get_territory_code
   --  Type        : Private
   --  Function    : Tries to convert a country into a CRM territory_code
   --  Notes:
   --------------------------------------------------------------------------
   FUNCTION get_territory_code
   ( p_country IN     VARCHAR2
   ) RETURN VARCHAR2;




     PROCEDURE put_message_to_excl_record (
      p_exclusion_rec     IN OUT NOCOPY  cac_sync_task.exclusion_rec,
      p_status       IN     NUMBER,
      p_user_message IN     VARCHAR2,
      p_token_name   IN     VARCHAR2 default null,
      p_token_value  IN     VARCHAR2 default null
   );


END;




 

/
