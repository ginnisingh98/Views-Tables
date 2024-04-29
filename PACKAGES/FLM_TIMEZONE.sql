--------------------------------------------------------
--  DDL for Package FLM_TIMEZONE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_TIMEZONE" AUTHID CURRENT_USER AS
/* $Header: FLMTMZOS.pls 115.3 2004/08/18 23:17:21 hwenas noship $*/
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| FILE NAME    : FLMTMZOS.pls                                               |
| DESCRIPTION  : This package contains functions used to provide timezone   |
|                support                                                    |
| MODIFICATION HISTORY:                                                     |
|   Hadi Wenas         10/14/03          Created                            |
+===========================================================================*/

g_enabled   BOOLEAN := (fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' AND
												fnd_profile.value('CLIENT_TIMEZONE_ID') IS NOT NULL AND
												fnd_profile.value('SERVER_TIMEZONE_ID') IS NOT NULL AND
                        fnd_profile.value('CLIENT_TIMEZONE_ID') <>
                        fnd_profile.value('SERVER_TIMEZONE_ID'));

g_client_id NUMBER  := fnd_profile.value('CLIENT_TIMEZONE_ID');
g_server_id NUMBER  := fnd_profile.value('SERVER_TIMEZONE_ID');
g_init BOOLEAN := FALSE;

--fix bug#3827600: new global variables
g_client_start_time NUMBER	:= 0;
g_server_start_time NUMBER	:= 0;
g_org_id NUMBER 		:= 0;

PROCEDURE init_timezone(p_org_id NUMBER);
FUNCTION is_init RETURN BOOLEAN;

FUNCTION server_to_calendar(p_server_date IN DATE) RETURN DATE;
FUNCTION client_to_calendar(p_client_date IN DATE) RETURN DATE; --fix bug#3840945

--fix bug#3827600
--Modified signature
FUNCTION calendar_to_server(p_calendar_date IN DATE,
                            p_server_time IN NUMBER DEFAULT NULL) RETURN DATE;
--end of fix bug#3827600

FUNCTION server_to_client(p_server_date IN DATE) RETURN DATE;
FUNCTION client_to_server(p_client_date IN DATE) RETURN DATE;
FUNCTION client00_in_server(p_server_date IN DATE) RETURN DATE;
FUNCTION sysdate00_in_server RETURN DATE;

/*fix bug#3827600
  Removed the following procedures:
  - get_offset()
  - calendar_to_client()
  - client_to_calendar()

  end of fix bug#3827600
*/

END flm_timezone;

 

/
