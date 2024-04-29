--------------------------------------------------------
--  DDL for Package IBU_MULTIPARTY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_MULTIPARTY_PUB" AUTHID CURRENT_USER as
/* $Header: ibuspubs.pls 120.2 2008/04/23 10:01:13 majha noship $ */
--
-- To modify this template, edit file PKGSPEC.TXT in TEMPLATE
-- directory of SQL Navigator
--
/* Purpose:Craeted the public API to be used by the customers to send emil notification
to persons in case of addition or removal  of parties */
-- Enter package declarations as shown below

  g_file_name VARCHAR2(32) := 'ibuspubs.pls';

 /* Use the procedure to send the email notification to the persons when thers is a addition or removal of
  parties. */

 /* p_operation_type will consist two values
   1. A - In case of addition
   2. R - In case of removal*/

 /*p_user_id is the id of the user for which association or removal is performed */

 /* p_party_id is the id the organisation being associated or removed from a user*/

   PROCEDURE send_email_notification( p_user_id IN SYSTEM.IBU_NUM_TBL_TYPE,
                                      p_party_id IN SYSTEM.IBU_NUM_TBL_TYPE,
                                      p_operation_type IN system.IBU_VAR_3_TBL_TYPE
                                      );

END IBU_MULTIPARTY_PUB;

/
