--------------------------------------------------------
--  DDL for Package Body INV_MOBILE_LOGIN_INFO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_MOBILE_LOGIN_INFO_PVT" AS
/* $Header: INVMULHB.pls 120.0 2005/05/25 05:42:43 appldev noship $ */

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
   ) IS
  BEGIN

     ROLLBACK;--Added bug4043847 since we must rollback all uncommited transactions before updating login history

     --p_event_type -> 0: log-in, 1: log-off
     IF (p_event_type  = 0 ) THEN

	--what about, if he is trying to log on with same user but on different
	--machine/port, In this case it should not delete previous login record
	UPDATE MTL_MOBILE_LOGIN_HIST
	  SET LOGOFF_DATE = logon_date,
	   event_message = 'MWA SERVER EXCEPTION'
	  WHERE
	  USER_ID = p_user_id
	  AND SERVER_MACHINE_NAME = p_server_machine_name
	  AND SERVER_PORT_NUMBER = p_server_port_number
	  AND LOGOFF_DATE IS NULL;

	INSERT INTO MTL_MOBILE_LOGIN_HIST (
					   USER_ID,
					   LOGON_DATE,
					   SERVER_MACHINE_NAME,
					   SERVER_PORT_NUMBER,
					   CLIENT_MACHINE_NAME,
					   CLIENT_PORT_NUMBER
					   ) VALUES(
						    p_user_id,
						    SYSDATE,
						    substr(p_server_machine_name,1,95),
						    p_server_port_number,
						    substr(p_client_machine_name,1,95),
						    p_client_port_number);
      ELSE

	UPDATE MTL_MOBILE_LOGIN_HIST SET
	  LOGOFF_DATE = SYSDATE,
	  EVENT_MESSAGE = p_event_message
	  WHERE USER_ID = p_user_id
	  AND SERVER_MACHINE_NAME = substr(p_server_machine_name,1,95)
	  AND SERVER_PORT_NUMBER = p_server_port_number
	  AND LOGOFF_DATE IS NULL;
     END IF;

     COMMIT;
     x_return_status:= 0;
  EXCEPTION
     WHEN OTHERS THEN
       X_RETURN_STATUS := -1;
  END log_user_info;


  END INV_MOBILE_LOGIN_INFO_PVT;

/
