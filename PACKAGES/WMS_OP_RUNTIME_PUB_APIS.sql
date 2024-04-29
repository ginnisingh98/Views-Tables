--------------------------------------------------------
--  DDL for Package WMS_OP_RUNTIME_PUB_APIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_OP_RUNTIME_PUB_APIS" AUTHID CURRENT_USER AS
/* $Header: WMSOPPBS.pls 120.0.12000000.1 2007/01/16 06:54:56 appldev ship $*/

--
-- File        : WMSOPPBS.pls
-- Content     : WMS_OP_RUNTIME_PUB_APIS package specification
-- Description : WMS Operation Plan Run-time APIs
-- Notes       :
-- Modified    : 10/21/2002 lezhang created



-- API name    :
-- Type        : Public
-- Function    :
-- Pre-reqs    :
--
--
-- Parameters  :
--   Output:
--
--   Input:
--
--
-- Version
--   Currently version is 1.0
--


PROCEDURE update_drop_locator_for_task
  (x_return_status          OUT nocopy VARCHAR2,
   x_message                OUT nocopy VARCHAR2,
   x_drop_lpn_option        OUT nocopy NUMBER,
   p_transfer_lpn_id    IN NUMBER
   );


PROCEDURE validate_pick_drop_Locator
  (
   X_Return_status          OUT nocopy VARCHAR2,
   X_Message                OUT nocopy VARCHAR2,
   P_Task_Type              IN  NUMBER,
   P_Task_ID                IN  NUMBER,
   P_Locator_Id             IN  NUMBER
   );

END WMS_OP_RUNTIME_PUB_APIS;


 

/
