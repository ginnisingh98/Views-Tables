--------------------------------------------------------
--  DDL for Package WMS_SHIPPING_LPN_UTILS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_SHIPPING_LPN_UTILS_PUB" AUTHID CURRENT_USER AS
/* $Header: WMSSHUTS.pls 120.1 2005/06/20 07:04:29 appldev ship $ */

PROCEDURE mydebug(msg in varchar2) ;

PROCEDURE update_lpn_context
  (  p_delivery_id            IN    NUMBER,
     x_return_status          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
     x_msg_count              OUT NOCOPY /* file.sql.39 change */   NUMBER,
     x_msg_data               OUT NOCOPY /* file.sql.39 change */   VARCHAR2);



END WMS_Shipping_LPN_Utils_PUB;

 

/
