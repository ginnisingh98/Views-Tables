--------------------------------------------------------
--  DDL for Package WMS_CROSS_DOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CROSS_DOCK_PVT" AUTHID CURRENT_USER AS
/* $Header: WMSCRDKS.pls 120.2 2005/09/15 15:35:16 mankuma ship $ */


PROCEDURE mydebug(msg in varchar2) ;


-- This API will be to determine whether cross docking opportunities
-- exist. If so, it will call pick release for the order(s) in question and
-- direct the User to the staging location(s)


PROCEDURE crossdock
  (    p_org_id                       IN   NUMBER
       ,  p_lpn IN NUMBER:=NULL
       ,  x_ret OUT NOCOPY NUMBER
       ,  x_return_status     OUT   NOCOPY VARCHAR2
       ,  x_msg_count         OUT   NOCOPY NUMBER
       ,  x_msg_data          OUT   NOCOPY VARCHAR2
       ,  p_move_order_line_id IN NUMBER DEFAULT NULL   -- added for ATF_J
       );

PROCEDURE complete_crossdock
  (    p_org_id               IN    NUMBER
       ,  p_temp_id             IN    NUMBER
       ,  x_return_status     OUT   NOCOPY VARCHAR2
       ,  x_msg_count         OUT   NOCOPY NUMBER
       ,  x_msg_data          OUT   NOCOPY VARCHAR2
       );



PROCEDURE mark_delivery
  (p_del_id IN NUMBER
   ,  x_ret OUT NOCOPY VARCHAR2
   ,  x_return_status     OUT   NOCOPY VARCHAR2
   ,  x_msg_count         OUT   NOCOPY NUMBER
   ,  x_msg_data          OUT   NOCOPY VARCHAR2);

--New api to be called from WMS Control Board.
PROCEDURE cancel_crossdock_task(p_transaction_temp_id IN NUMBER
				, x_return_status     OUT nocopy VARCHAR2
				, x_msg_data          OUT nocopy VARCHAR2
				, x_msg_count         OUT nocopy NUMBER
				);


END WMS_Cross_Dock_Pvt;





 

/
