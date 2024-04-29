--------------------------------------------------------
--  DDL for Package GMO_OPER_CERT_TRANS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMO_OPER_CERT_TRANS_DBL" AUTHID CURRENT_USER AS
/* $Header: GMOVGOCS.pls 120.1 2007/06/21 06:15:16 rvsingh noship $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |       GMOVGOCS.pls
 |
 |   DESCRIPTION
 |      Spec of package gmo_oper_cert_trans_dbl
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-07 Pawan Kumar  Created
 |    bug number- 4440475
 |      - insert_row
 |      - update_row
 |      - lock_row
 |
 |
 =============================================================================
*/
   PROCEDURE INSERT_ROW (
   p_operator_CERTIFICATE_ID    IN OUT NOCOPY NUMBER
  ,p_HEADER_ID                 IN            NUMBER
  ,p_TRANSACTION_ID            IN            VARCHAR2
  ,p_USER_ID                   IN            NUMBER
  ,p_comments                   IN            VARCHAR2
  ,p_OVERRIDER_ID               IN            NUMBER
  ,p_User_key_label_product    IN            VARCHAR2
  ,p_User_key_label_token      IN            VARCHAR2
  ,p_User_key_value            IN            VARCHAR2
  ,p_Erecord_id                IN            NUMBER
  ,p_Trans_object_id           IN            NUMBER
  ,p_STATUS                    IN            VARCHAR2
  ,p_event_name                IN            VARCHAR2
  ,p_event_key                 IN            VARCHAR2
  ,p_CREATION_DATE             IN            DATE
  ,p_CREATED_BY                IN            NUMBER
  ,p_LAST_UPDATE_DATE          IN            DATE
  ,p_LAST_UPDATED_BY           IN            NUMBER
  ,p_LAST_UPDATE_LOGIN         IN            NUMBER
  ,x_return_Status            OUT   NOCOPY     VARCHAR2 );

    PROCEDURE delete_row (p_oper_cert_id   IN 	NUMBER
                        ,x_return_Status  OUT NOCOPY   VARCHAR2 );


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
  ,x_return_Status            OUT   NOCOPY   VARCHAR2  );



   PROCEDURE lock_row (p_oper_cert_id     IN            NUMBER
                      ,x_return_Status   OUT   NOCOPY  VARCHAR2 )  ;

END gmo_oper_cert_trans_dbl;

/
