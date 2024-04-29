--------------------------------------------------------
--  DDL for Package WMS_SHIPPING_MESSAGES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SHIPPING_MESSAGES" AUTHID CURRENT_USER AS
/* $Header: WMSSHPMS.pls 120.0.12010000.1 2008/07/28 18:36:47 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'WMS_SHIPPING_MESSAGES';

PROCEDURE PROCESS_SHIPPING_WARNING_MSGS(x_return_status  OUT  NOCOPY VARCHAR2,
                                        x_msg_count      OUT  NOCOPY NUMBER,
                 			x_msg_data       OUT  NOCOPY VARCHAR2,
                                        p_commit         IN  VARCHAR2 := FND_API.g_false,
                                        p_api_version    IN  VARCHAR2 := 1.0,
                                        x_shipping_msg_tab  IN OUT  NOCOPY wsh_integration.msg_table) ;

END WMS_SHIPPING_MESSAGES;

/
