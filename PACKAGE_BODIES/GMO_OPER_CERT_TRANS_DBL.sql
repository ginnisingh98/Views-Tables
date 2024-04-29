--------------------------------------------------------
--  DDL for Package Body GMO_OPER_CERT_TRANS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_OPER_CERT_TRANS_DBL" AS
/* $Header: GMOVGOCB.pls 120.1 2007/06/21 06:14:59 rvsingh noship $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'gmo_operator_cert_trans';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMOVGOCB.pls
 |
 |   DESCRIPTION
 | |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |      - Delete_row
 |
 |
 =============================================================================
*/

   /* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      insert_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Insert_Row will insert a row in gmo_operator_cert_trans
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gmo_operator_cert_trans
 |
 |
 |
 |   PARAMETERS
 |     p_oper_cert_trans IN  gmo_operator_cert_trans%ROWTYPE
 |     x_oper_cert_trans IN OUT NOCOPY gmo_operator_cert_trans%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

   PROCEDURE INSERT_ROW (
   p_operator_CERTIFICATE_ID   IN OUT NOCOPY NUMBER
  ,P_HEADER_ID                 IN            NUMBER
  ,P_TRANSACTION_ID            IN            VARCHAR2
  ,P_USER_ID                   IN            NUMBER
  ,P_comments                  IN            VARCHAR2
  ,P_OVERRIDER_ID              IN            NUMBER
  ,P_User_key_label_product    IN            VARCHAR2
  ,P_User_key_label_token      IN            VARCHAR2
  ,P_User_key_value            IN            VARCHAR2
  ,P_Erecord_id                IN            NUMBER
  ,P_Trans_object_id           IN            NUMBER
  ,P_STATUS                    IN            VARCHAR2
  ,P_event_name                IN            VARCHAR2
  ,P_event_key                 IN            VARCHAR2
  ,P_CREATION_DATE             IN            DATE
  ,P_CREATED_BY                IN            NUMBER
  ,P_LAST_UPDATE_DATE          IN            DATE
  ,P_LAST_UPDATED_BY           IN            NUMBER
  ,P_LAST_UPDATE_LOGIN         IN            NUMBER
  ,x_return_Status            OUT   NOCOPY     VARCHAR2 )  IS


BEGIN
   -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;




     INSERT INTO gmo_operator_cert_trans
                        (operator_CERTIFICATE_ID
                         ,HEADER_ID
                         ,TRANSACTION_ID
                         ,USER_ID
                         ,comments
                         ,OVERRIDER_ID
                         ,User_key_label_product
                         ,User_key_label_token
                         ,User_key_value
                         ,Erecord_id
                         ,Trans_object_id
                         ,STATUS
                         ,EVENT_NAME
                         ,EVENT_KEY
                         ,CREATION_DATE
                         ,CREATED_BY
                         ,LAST_UPDATE_DATE
                         ,LAST_UPDATED_BY
                         ,LAST_UPDATE_LOGIN )
                 VALUES ( gmo_oc_object_trans_s.nextval
                         ,p_HEADER_ID
                         ,p_TRANSACTION_ID
                         ,p_USER_ID
                         ,p_comments
                         ,p_OVERRIDER_ID
                         ,p_User_key_label_product
                         ,p_User_key_label_token
                         ,p_User_key_value
                         ,p_Erecord_id
                         ,p_Trans_object_id
                         ,p_STATUS
                         ,p_EVENT_NAME
                         ,p_event_KEY
                         ,p_CREATION_DATE
                         ,p_CREATED_BY
                         ,p_LAST_UPDATE_DATE
                         ,p_LAST_UPDATED_BY
                         ,p_LAST_UPDATE_LOGIN

                         )
        RETURNING operator_CERTIFICATE_ID
             INTO p_operator_CERTIFICATE_ID ;

      IF SQL%NOTFOUND THEN
             x_return_status := fnd_api.g_ret_sts_error;
      END IF;

   EXCEPTION
     WHEN FND_API.g_exc_error  THEN
        --dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
    x_return_status := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
      	x_return_status := fnd_api.g_ret_sts_unexp_error;
         --dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));

   END insert_row;


/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      delete_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Delete_Row will delete a row in gmo_operator_cert_trans
 |
 |
 |   DESCRIPTION
 |      Delete_Row will delete a row in gmo_operator_cert_trans
 |
 |
 |
 |   PARAMETERS
 |     p_oper_cert_trans IN  gmo_operator_cert_trans%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

   PROCEDURE delete_row (p_oper_cert_id IN NUMBER
   ,x_return_Status            OUT   NOCOPY   VARCHAR2)

   IS
      l_dummy                NUMBER    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);

   BEGIN
   -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;
      IF p_oper_cert_ID  IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gmo_operator_cert_trans
              WHERE operator_CERTIFICATE_ID  = p_oper_cert_ID
         FOR UPDATE NOWAIT;

         DELETE FROM gmo_operator_cert_trans
               WHERE operator_CERTIFICATE_ID  = p_oper_cert_ID ;


        IF (SQL%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
        END IF;
      END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN

         x_return_status := fnd_api.g_ret_sts_error;

      WHEN OTHERS THEN
      	--dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
        	x_return_status := fnd_api.g_ret_sts_unexp_error;
   END delete_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      update_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Update_Row will update a row in gmo_operator_cert_trans
 |
 |
 |   DESCRIPTION
 |      Update_Row will update a row in gmo_operator_cert_trans
 |
 |
 |
 |   PARAMETERS
 |     p_oper_cert_trans IN  gmo_operator_cert_trans%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   PROCEDURE UPDATE_ROW (
   P_operator_CERTIFICATE_ID    IN            NUMBER
  ,P_HEADER_ID                 IN            NUMBER
  ,P_TRANSACTION_ID            IN            VARCHAR2
  ,P_USER_ID                   IN            NUMBER
  ,P_comments                   IN            VARCHAR2
  ,P_OVERRIDER_ID               IN            NUMBER
  ,P_User_key_label_product    IN            VARCHAR2
  ,P_User_key_label_token      IN            VARCHAR2
  ,P_User_key_value            IN            VARCHAR2
  ,P_Erecord_id                IN            NUMBER
  ,P_Trans_object_id           IN            NUMBER
  ,P_STATUS                    IN            VARCHAR2
  ,P_event_name                IN            VARCHAR2
  ,p_event_key                 IN            VARCHAR2
  ,P_CREATION_DATE             IN            DATE
  ,P_CREATED_BY                IN            NUMBER
  ,P_LAST_UPDATE_DATE          IN            DATE
  ,P_LAST_UPDATED_BY           IN            NUMBER
  ,P_LAST_UPDATE_LOGIN         IN            NUMBER
  ,x_return_Status            OUT   NOCOPY   VARCHAR2  )

   IS
      l_dummy                NUMBER    := 0;
      locked_by_other_user   EXCEPTION;
      PRAGMA EXCEPTION_INIT (locked_by_other_user, -54);

   BEGIN
   	  x_return_status := fnd_api.g_ret_sts_success;

      IF p_operator_CERTIFICATE_ID  IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gmo_operator_cert_trans
              WHERE operator_CERTIFICATE_ID  = p_operator_CERTIFICATE_ID
         FOR UPDATE NOWAIT;

         UPDATE gmo_operator_cert_trans
            SET
                 TRANSACTION_ID          = P_TRANSACTION_ID
                 ,comments               = P_comments
                 ,OVERRIDER_ID           = P_OVERRIDER_ID
                 ,User_key_label_product = P_User_key_label_product
                 ,User_key_label_token   = P_User_key_label_token
                 ,User_key_value         = P_User_key_value
                 ,Erecord_id             = P_Erecord_id
                 ,Trans_object_id        = P_Trans_object_id
                 ,STATUS                 = P_STATUS
                 ,event_name           = P_event_name
                 ,event_key            = P_event_key

                 ,LAST_UPDATE_DATE       = P_LAST_UPDATE_DATE
                 ,LAST_UPDATED_BY        = P_LAST_UPDATED_BY
                 ,LAST_UPDATE_LOGIN      = P_LAST_UPDATE_LOGIN
                 WHERE operator_CERTIFICATE_ID  = p_operator_CERTIFICATE_ID;
      END IF;
      IF (SQL%NOTFOUND) THEN
          RAISE NO_DATA_FOUND;
        END IF;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_return_status := fnd_api.g_ret_sts_error;

       WHEN OTHERS THEN
       	--dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
         	x_return_status := fnd_api.g_ret_sts_unexp_error;

   END update_row;

/* Api start of comments
 +============================================================================
 |   FUNCTION NAME
 |      lock_row
 |
 |   TYPE
 |      Private
 |   USAGE
 |      Lock_Row will lock a row in gmo_operator_cert_trans
 |
 |
 |   DESCRIPTION
 |      Lock_Row will lock a row in gmo_operator_cert_trans
 |
 |
 |
 |   PARAMETERS
 |     p_oper_cert_trans IN  gmo_operator_cert_trans%ROWTYPE
 |
 |   RETURNS
 |      BOOLEAN
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/
   PROCEDURE lock_row (p_oper_cert_id IN NUMBER
   ,x_return_Status            OUT   NOCOPY   VARCHAR2)

   IS
      l_dummy   NUMBER;
   BEGIN
      IF p_oper_cert_ID  IS NOT NULL THEN
         SELECT     1
               INTO l_dummy
               FROM gmo_operator_cert_trans
              WHERE operator_CERTIFICATE_ID  = p_oper_cert_ID
         FOR UPDATE NOWAIT;
      END IF;


   EXCEPTION
   	WHEN NO_DATA_FOUND THEN
         x_return_status := fnd_api.g_ret_sts_error;
      WHEN app_exception.record_lock_exception THEN
       x_return_status := fnd_api.g_ret_sts_error;

      WHEN OTHERS THEN
      	--dbms_output.put_line(SubStr('Error '||TO_CHAR(SQLCODE)||': '||SQLERRM, 1, 255));
     x_return_status := fnd_api.g_ret_sts_unexp_error;
   END lock_row;
END gmo_oper_cert_trans_dbl;

/
