--------------------------------------------------------
--  DDL for Package XDP_INSTALL_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_INSTALL_BASE" AUTHID CURRENT_USER AS
/* $Header: XDPIBINS.pls 120.1 2005/06/08 23:52:56 appldev  $ */


-- Start of comments
--      API name        : XDP_INSTALL_BASE
--      Type            : Private
--      Function        : An API to integrate SFM with Install Base
--      Pre-reqs        : None.
--      Parameters      :
--
--      IN              :
--                              p_order_id:               NUMBER        Required
--                                      The Order Id for the Order to be processed
--                              p_line_id:                NUMBER        Required
--                                      The Line Id for the line in the Order to be processed
--      OUT             :
--                              p_error_code:             NUMBER
--                                      The code of the error encountered
--
--      OUT             :
--                              p_error_description:             VARCHAR2
--                                      The description of the error encountered
--
--      Version : Current version       11.5
--      Notes   :
--              This API is used for the Integration between Service Fulfillment Manager
--              and Installed Base
--
-- End of comments

PROCEDURE UPDATE_IB(p_order_id IN NUMBER,
		    p_line_id  IN NUMBER,
                    p_error_code IN OUT NOCOPY NUMBER,
                    p_error_description OUT NOCOPY VARCHAR2);

END XDP_INSTALL_BASE;

 

/
