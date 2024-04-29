--------------------------------------------------------
--  DDL for Package INV_CONSIGN_NOTIF_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CONSIGN_NOTIF_UTL" AUTHID CURRENT_USER AS
-- $Header: INVCNTFS.pls 115.0 2003/10/15 00:25:48 vma noship $ --
--+=======================================================================+
--|               Copyright (c) 2002 Oracle Corporation                   |
--|                       Redwood Shores, CA, USA                         |
--|                         All rights reserved.                          |
--+=======================================================================+
--| FILENAME                                                              |
--|     INVCNTFS.pls                                                      |
--|                                                                       |
--| DESCRIPTION                                                           |
--|     Send Consigned Inventory Diagnostics Notification to buyers       |
--|                                                                       |
--| HISTORY                                                               |
--|     10/06/03 vma      Created.                                        |
--+========================================================================

--===================
-- CONSTANTS
--===================
G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_CONSIGN_NOTIF_UTL';

--===================
-- PROCEDURES AND FUNCTIONS
--===================
--==========================================================================
--  PROCEDURE NAME:  Send_Notification
--
--  DESCRIPTION:     Send Workflow Notification to buyers that have Consigned
--                   Inventory Diagnostics errors to resolve.
--
--  PARAMETERS:
--     p_api_version    REQUIRED  API version
--     p_init_msg_list  REQUIRED  FND_API.G_TRUE to reset the message list
--                                FND_API.G_FALSE to not reset it.
--                                If pass NULL, it means FND_API.G_FALSE.
--     p_commit         REQUIRED  FND_API.G_TRUE to have API commit the change
--                                FND_API.G_FALSE to not commit the change.
--                                If pass NULL, it means FND_API.G_FALSE.
--     x_return_status  REQUIRED  Value can be
--                                  FND_API.G_RET_STS_SUCCESS
--                                  FND_API.G_RET_STS_ERROR
--                                  FND_API.G_RET_STS_UNEXP_ERROR
--     x_msg_count      REQUIRED  Number of messages on the message list
--     x_msg_data       REQUIRED  Return message data if message count is 1
--     p_notification_resend_days
--                      REQUIRED  Number of days elapsed before resending
--                                notification to a buyer
--
-- COMMENT    : Call Workflow to send Consigned Diagnostics notification
--              to buyers.
--
-- CHANGE HISTORY :
--   10/06/03 vma      Created.
--=========================================================================
PROCEDURE Send_Notification
( p_api_version              IN  NUMBER
, p_init_msg_list            IN  VARCHAR2
, p_commit                   IN  VARCHAR2
, x_return_status            OUT NOCOPY VARCHAR2
, x_msg_count                OUT NOCOPY NUMBER
, x_msg_data                 OUT NOCOPY VARCHAR2
, p_notification_resend_days IN  NUMBER
);

END INV_CONSIGN_NOTIF_UTL;

 

/
