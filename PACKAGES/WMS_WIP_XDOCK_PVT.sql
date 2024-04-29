--------------------------------------------------------
--  DDL for Package WMS_WIP_XDOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_WIP_XDOCK_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSWIPCS.pls 120.0.12010000.1 2008/07/28 18:38:25 appldev ship $ */


PROCEDURE mydebug(msg in varchar2) ;


-- This API will be to determine whether cross docking opportunities
-- exist. If so, it will call pick release for the order(s) in question and
-- direct the User to the staging location(s)


PROCEDURE wip_chk_crossdock
  (    p_org_id                       IN   NUMBER
       ,  p_lpn IN NUMBER:=NULL
       ,  x_ret OUT NOCOPY NUMBER
       ,  x_return_status     OUT   NOCOPY VARCHAR2
       ,  x_msg_count         OUT   NOCOPY NUMBER
       ,  x_msg_data          OUT   NOCOPY VARCHAR2
       ,  p_move_order_line_id IN NUMBER DEFAULT NULL  -- added for ATF_J
);

PROCEDURE wip_complete_crossdock
  (    p_org_id               IN    NUMBER
       ,  p_temp_id             IN    NUMBER
       , p_wip_id IN NUMBER
       , p_inventory_item_id IN NUMBER
       ,  x_return_status     OUT   NOCOPY VARCHAR2
       ,  x_msg_count         OUT   NOCOPY NUMBER
       ,  x_msg_data          OUT   NOCOPY VARCHAR2
       );



PROCEDURE mark_wip(
		   p_line_id          IN            NUMBER ,
		   P_WIP_ENTITY_ID    IN            NUMBER ,
		   P_OPERATION_SEQ_NUM   IN         NUMBER ,
		   P_INVENTORY_ITEM_ID  IN          NUMBER ,
		   P_REPETITIVE_SCHEDULE_ID   IN    NUMBER,
		   P_PRIMARY_QUANTITY   IN          NUMBER,
		   x_quantity_allocated OUT         NOCOPY NUMBER,
		   X_RETURN_STATUS      OUT          NOCOPY VARCHAR2,
		   X_MSG_DATA           OUT          NOCOPY VARCHAR2,
		   p_primary_uom IN VARCHAR2,
		   p_uom VARCHAR2);

 PROCEDURE insert_new_mmtt_row_like
	(
	   p_txn_temp_id      IN    number,
	   x_new_temp_id     OUT   NOCOPY number,
	   x_new_hdr_id      OUT   NOCOPY number
	 );


END wms_wip_xdock_pvt;





/
