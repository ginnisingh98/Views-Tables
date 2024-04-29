--------------------------------------------------------
--  DDL for Package WMS_SHIPPING_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SHIPPING_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSSHPPS.pls 120.1 2005/06/21 10:42:31 appldev ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'WMS_SHIPPING_PUB';

-- TYPE shipping_msg_tab_type IS TABLE OF VARCHAR2(1024) INDEX BY BINARY_INTEGER;
-- TYPE shipping_error_tab_type IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;

PROCEDURE DEL_WSTT_RECS_BY_DELIVERY_ID (x_return_status  OUT NOCOPY VARCHAR2,
					x_msg_count      OUT NOCOPY NUMBER,
					x_msg_data       OUT NOCOPY VARCHAR2,
					p_commit         IN  VARCHAR2 := FND_API.g_false,
					p_init_msg_list  IN  VARCHAR2 := FND_API.g_false,
					p_api_version    IN  NUMBER := 1.0, --3555636 changed from varchar2 to number
					p_delivery_ids   IN  wsh_util_core.id_tab_type
					);
END WMS_SHIPPING_PUB;

 

/
