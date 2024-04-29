--------------------------------------------------------
--  DDL for Package ZPB_USER_UPDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_USER_UPDATE" AUTHID CURRENT_USER AS
/* $Header: zpbusersynch.pls 120.0.12010.2 2005/12/23 10:28:50 appldev noship $ */

  MODULE_NAME      CONSTANT VARCHAR2 (17):= 'ZPB_USER_UPDATE';
  ANALYST          CONSTANT VARCHAR2(16):= 'ZPB_ANALYST_RESP';
  MANAGER          CONSTANT VARCHAR2(16):= 'ZPB_MANAGER_RESP';
  CONTROLLER       CONSTANT VARCHAR2(19):= 'ZPB_CONTROLLER_RESP';
  SCHEMA_ADMIN     CONSTANT VARCHAR2(21):= 'ZPB_SCHEMA_ADMIN_RESP';
  BIBEANS          CONSTANT VARCHAR2(7):= 'BIBEANS';
  ZPBUSER          CONSTANT VARCHAR2(4):= 'APPS';
  CURRENT_USER     CONSTANT number := 0;
  NEW_USER         CONSTANT number := 1;
  EXP_USER         CONSTANT number := -1;
  ADD_ROLE         CONSTANT NUMBER:= 10;
  RMV_ROLE         CONSTANT NUMBER:= -10;
  HIDE_ACCOUNT     CONSTANT NUMBER:= -100;

  PROCEDURE synch_users(p_business_area_id NUMBER);

  procedure init_user_session (p_user_id in number,
                               p_resp_id in number,
                               p_business_area_id in number);

  --
  -- Procedure that will insert rows into ZPB_USERS for any security
  -- administrators who have access to a business area.  Called from
  -- the business area user's screen
  --
  procedure synch_security_users (p_business_area_id in number);

  procedure update_admin_entries (p_business_area_id in number);

END ZPB_USER_UPDATE;

 

/
