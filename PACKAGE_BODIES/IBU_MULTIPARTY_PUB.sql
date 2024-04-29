--------------------------------------------------------
--  DDL for Package Body IBU_MULTIPARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_MULTIPARTY_PUB" AS
/* $Header: ibuspubb.pls 120.3 2008/05/13 04:53:30 majha noship $ */

  g_file_name VARCHAR2(32) := 'ibuspubb.pls';

  /*
    * Procedure: send_email_notification
    *
   */
 PROCEDURE send_email_notification( p_user_id IN SYSTEM.IBU_NUM_TBL_TYPE,
                                    p_party_id IN SYSTEM.IBU_NUM_TBL_TYPE,
                                    p_operation_type IN SYSTEM.IBU_VAR_3_TBL_TYPE
                                    )
 IS
 i NUMBER ;
 BEGIN
 BEGIN
-- Code to be written by the customer.
 NULL;
 END;
 --x_status := 'S';
 EXCEPTION
 WHEN OTHERS THEN
 NULL;
 --x_status := 'S';
 --Please dont raise exception from this procedure.
 END send_email_notification;
 END IBU_MULTIPARTY_PUB;

/
