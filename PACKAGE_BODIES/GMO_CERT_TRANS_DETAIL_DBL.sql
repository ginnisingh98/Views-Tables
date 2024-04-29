--------------------------------------------------------
--  DDL for Package Body GMO_CERT_TRANS_DETAIL_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_CERT_TRANS_DETAIL_DBL" AS
/* $Header: GMOVGCDB.pls 120.1 2007/06/21 06:13:46 rvsingh noship $ */

   /* Global Variables */
   g_table_name   VARCHAR2 (80) DEFAULT 'gmo_cert_trans_detail_dbl';

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMOVGCDB.pls
 |
 |   DESCRIPTION

 |   NOTES
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |      - insert_row
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
 |      Insert_Row will insert a row in gmo_cert_trans_detail
 |
 |
 |   DESCRIPTION
 |      Insert_Row will insert a row in gmo_cert_trans_detail
 |
 |   PARAMETERS
 |
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar   Created
 |
 |
 |
 +=============================================================================
 Api end of comments
*/

   PROCEDURE INSERT_ROW (
   p_trans_detail_id          IN OUT NOCOPY    NUMBER
  ,p_operator_certificate_id  IN               NUMBER
  ,p_header_id                IN               NUMBER
  ,p_Qualification_id         IN               NUMBER
  ,p_Qualification_type       IN               NUMBER
  ,p_PROFICIENCY_LEVEL_ID     IN               NUMBER
  ,x_return_Status          OUT   NOCOPY     VARCHAR2 ) IS


BEGIN
   -- Initially let us assign the return status to success
      x_return_status := fnd_api.g_ret_sts_success;




     INSERT INTO gmo_operator_trans_detail
                        (trans_detail_id
                         ,operator_certificate_id
                         ,header_id
                         ,Qualification_id
                         ,Qualification_type
                         ,PROFICIENCY_LEVEL_ID
                         )
                 VALUES ( gmo_oc_object_trans_s.nextval
                         ,p_operator_certificate_id
                         ,p_header_id
                         ,p_Qualification_id
                         ,p_Qualification_type
                         ,p_PROFICIENCY_LEVEL_ID

                         )
        RETURNING trans_detail_id
             INTO p_trans_detail_id ;

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



END gmo_cert_trans_detail_dbl;

/
