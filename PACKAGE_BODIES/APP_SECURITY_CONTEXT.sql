--------------------------------------------------------
--  DDL for Package Body APP_SECURITY_CONTEXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."APP_SECURITY_CONTEXT" AS
/* $Header: ahmpascb.pls 115.1 2001/09/18 13:08:28 pkm ship      $ */
-- DESCRIPTION: Creates the app_security_context package body

   PROCEDURE Set_empno(sec_group_id NUMBER) IS
   BEGIN
    DBMS_SESSION.SET_CONTEXT('app_context', 'sec_id', TO_CHAR(sec_group_id));
   END;
   END app_security_context;

/
