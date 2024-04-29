--------------------------------------------------------
--  DDL for Package WSH_OTM_HTTP_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_OTM_HTTP_UTL" AUTHID CURRENT_USER AS
/* $Header: WSHGLHUS.pls 120.0.12000000.1 2007/01/25 16:15:06 amohamme noship $ */

-- ----------------------------------------------------------------------------------------- --


-- Get the Request and return the Response.
-- Make call to Rating servlet and fulfill the RIQ request.
PROCEDURE post_request_to_otm(  p_request       IN XMLType,
                                x_response      OUT NOCOPY CLOB,
                                x_return_status OUT NOCOPY VARCHAR2
                              );

-- Get the security token from FND Http packages.
-- Takes in opcode, argument and timespan for new ticket.
-- returns fnd ticket.
PROCEDURE get_secure_ticket_details( p_op_code       IN VARCHAR2,
                                     p_argument      IN VARCHAR2,
                                     x_ticket        OUT NOCOPY RAW,
                                     x_server_time_zone OUT NOCOPY VARCHAR2,
                                     x_return_status OUT NOCOPY VARCHAR2
                                   );


END WSH_OTM_HTTP_UTL;


 

/
