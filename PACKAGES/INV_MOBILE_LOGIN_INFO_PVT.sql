--------------------------------------------------------
--  DDL for Package INV_MOBILE_LOGIN_INFO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_MOBILE_LOGIN_INFO_PVT" AUTHID CURRENT_USER AS
/* $Header: INVMULHS.pls 115.0 2003/03/01 03:10:29 satkumar noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'INV_MOBILE_LOGIN_INFO_PVT';

  PROCEDURE LOG_USER_INFO
  (
  p_event_type            IN  number,
  p_user_id               IN  number,
  p_server_machine_name   IN  varchar2,
  p_server_port_number    IN  number,
  p_client_machine_name   IN  varchar2,
  p_client_port_number    IN  number,
  p_event_message         IN  varchar2,
  X_RETURN_STATUS         OUT    NOCOPY NUMBER
  );


  END INV_MOBILE_LOGIN_INFO_PVT;

 

/
