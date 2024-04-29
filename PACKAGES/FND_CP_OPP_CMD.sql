--------------------------------------------------------
--  DDL for Package FND_CP_OPP_CMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CP_OPP_CMD" AUTHID CURRENT_USER AS
/* $Header: AFCPOPCS.pls 120.1.12010000.2 2009/10/30 19:26:17 smadhapp ship $ */

--
-- Send an immediate shutdown request to a specific OPP process
--
procedure send_opp_shutdown_request(cpid in number);


--
-- Requests termination of postprocessing for a specific request
--
procedure terminate_opp_request(reqid in number, senderid in number);

--
-- Requests termination of postprocessing for a specific request without autonomous_transaction
--
procedure terminate_opp_request_this_txn(reqid in number, senderid in number);

--
-- Ping a specific OPP service process
-- Returns TRUE if process replies.
--
function ping_opp_service(cpid in number, senderid in number, timeout in number) return boolean;


END fnd_cp_opp_cmd;

/
