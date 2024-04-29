--------------------------------------------------------
--  DDL for Package CSI_CLIENT_EXT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSI_CLIENT_EXT_PUB" AUTHID CURRENT_USER AS
-- $Header: csiclexs.pls 120.0 2005/05/24 19:02:17 appldev noship $

PROCEDURE mtl_post_transaction(p_transaction_id  IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_error_message   OUT NOCOPY VARCHAR2);




-- Procedure for customization
-- This Procedure is called from the Post Transaction Exit of
-- for NL tracked items. This is intended to publish the events
-- for the transaction types which are NOT supported by NL

PROCEDURE rcv_post_transaction(p_transaction_id  IN NUMBER,
                               x_return_status   OUT NOCOPY VARCHAR2,
                               x_error_message   OUT NOCOPY VARCHAR2);

PROCEDURE csi_error_resubmit(p_transaction_id  IN NUMBER,
                             x_return_status   OUT NOCOPY VARCHAR2,
                             x_error_message   OUT NOCOPY VARCHAR2);

end CSI_CLIENT_EXT_PUB;

 

/
