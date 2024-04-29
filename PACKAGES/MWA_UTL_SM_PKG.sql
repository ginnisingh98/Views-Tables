--------------------------------------------------------
--  DDL for Package MWA_UTL_SM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MWA_UTL_SM_PKG" AUTHID CURRENT_USER as
/*$Header: MWASMGRS.pls 120.1.12010000.2 2008/12/04 06:41:08 pbonthu ship $ */

TYPE t_user_table IS TABLE OF VARCHAR2(32)
	INDEX BY BINARY_INTEGER;

Procedure Get_Users
(num_of_users		OUT nocopy INTEGER,
 user_table		OUT nocopy t_user_table,
 status			OUT nocopy VARCHAR2,
 status_msg             OUT nocopy VARCHAR2,
 server_host		IN  VARCHAR2,
 server_port		IN  VARCHAR2,
 proxy_host		IN  VARCHAR2,
 user_name		IN  VARCHAR2,
 password		IN  VARCHAR2
);

Procedure Send_Message
(status		OUT nocopy VARCHAR2,
 status_msg     OUT nocopy VARCHAR2,
 server_host	IN  VARCHAR2,
 server_port	IN  VARCHAR2,
 proxy_host	IN  VARCHAR2,
 user_name	IN  VARCHAR2,
 password	IN  VARCHAR2,
 recipient	IN  VARCHAR2,
 message	IN  VARCHAR2
);

--Added for bug 7584728 start

function test(function_name in varchar2,
              test_maint_avilability in varchar2 default NULL)
    return NUMBER;
--Added for bug 7584728 end


END MWA_UTL_SM_PKG;

/
