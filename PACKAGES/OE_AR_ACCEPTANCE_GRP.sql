--------------------------------------------------------
--  DDL for Package OE_AR_ACCEPTANCE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_AR_ACCEPTANCE_GRP" AUTHID CURRENT_USER AS
-- $Header: OEXGAARS.pls 120.1.12000000.1 2007/01/16 21:51:30 appldev ship $
--+=======================================================================+
--|               Copyright (c) 2000 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|    OEXGAARS.pls                                                       |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Package Spec of OE_AR_Acceptance_GRP                              |
--|                                                                       |
--| PROCEDURE LIST                                                        |
--|     Process_Acceptance_in_OM                                          |
--|                                                                       |
--| HISTORY                                                               |
--|    MAY-20-2005 Initial Creation                                       |
--|                                                                       |
--|=======================================================================+

PROCEDURE Process_Acceptance_in_OM
(   p_action_request_tbl            IN OUT NOCOPY OE_Order_PUB.Request_Tbl_Type
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
);

PROCEDURE Get_interface_attributes
(     P_LINE_ID                    IN  NUMBER
,    x_line_flex_rec        OUT NOCOPY ar_deferral_reasons_grp.line_flex_rec
,    x_return_status        OUT NOCOPY VARCHAR2
,    x_msg_count            OUT NOCOPY NUMBER
,    x_msg_data             OUT NOCOPY VARCHAR2
);


END OE_AR_Acceptance_GRP;

-- SHOW ERRORS PACKAGE OE_AR_Acceptance_GRP;


 

/
