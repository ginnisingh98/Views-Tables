--------------------------------------------------------
--  DDL for Package Body GMO_OPERT_CERT_GTMP_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_OPERT_CERT_GTMP_DBL" AS
/* $Header: GMOVGCTB.pls 120.1 2007/06/21 06:14:28 rvsingh noship $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'gmo_opert_cert_gtmp_dbl';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMOVGCTB.pls
 |
 |   DESCRIPTION
 |
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |      - insert_row
 |
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
 |      Insert_Row will insert a row in gmo_opert_cert_gtmp
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gmo_opert_cert_gtmp

 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

   PROCEDURE INSERT_ROW (
    p_ERECORD_ID               IN NUMBER
   ,p_Operator_certificate_id  IN NUMBER
   ,p_EVENT_KEY                IN VARCHAR2
   ,p_EVENT_NAME               IN VARCHAR2
   ,x_return_status            OUT NOCOPY VARCHAR2) IS


BEGIN
   -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;




     INSERT INTO gmo_opert_cert_gtmp
                         (ERECORD_ID
                         ,Operator_certificate_id
                         ,EVENT_KEY
                         ,EVENT_NAME
                         )
                 VALUES ( p_ERECORD_ID
                         ,p_Operator_certificate_id
                         ,p_EVENT_KEY
                         ,p_EVENT_NAME

                         ) ;

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



END gmo_opert_cert_gtmp_dbl;

/
