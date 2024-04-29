--------------------------------------------------------
--  DDL for Package CSE_CLIENT_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_CLIENT_EXT_PUB" AUTHID CURRENT_USER AS
-- $Header: CSECLEXS.pls 115.4 2003/01/17 00:17:33 jpwilson noship $

-- Procedure for customization
-- This Procedure is called from the Post Transaction Exit of
-- for NL tracked items. This is intended to publish the events
-- for the transaction types which are NOT supported by NL

PROCEDURE rcv_post_transaction(p_transaction_id  IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_error_message   OUT NOCOPY VARCHAR2);
end CSE_CLIENT_EXT_PUB;

 

/
