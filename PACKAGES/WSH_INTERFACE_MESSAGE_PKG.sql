--------------------------------------------------------
--  DDL for Package WSH_INTERFACE_MESSAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_INTERFACE_MESSAGE_PKG" AUTHID CURRENT_USER AS
/* $Header: WSHINMSS.pls 120.0.12010000.3 2009/03/30 08:16:49 brana noship $ */

/*==============================================================================
-- PROCEDURE:         lock_record
-- Purpose:           Submit From Interface Message Correction Form
-- Description:       This procedure  is called from Interface Message Correction Form
--                    for locking the record in table wsh_del_details_interface
--                    and wsh_new_del_interface
==============================================================================*/
Procedure lock_record (
                       p_delivery_interface_id        IN NUMBER DEFAULT NULL,
                       p_delivery_detail_interface_id IN NUMBER DEFAULT NULL,
                       x_return_status                OUT NOCOPY VARCHAR2
                      );

END wsh_interface_message_pkg;

/
