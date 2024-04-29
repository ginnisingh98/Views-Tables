--------------------------------------------------------
--  DDL for Package AHL_OSP_COST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_OSP_COST_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVOSCS.pls 115.1 2003/09/18 20:56:00 cxcheng noship $ */

-- Start of Comments --
--  Procedure name    : Get_OSP_Cost
--  Type              : Private
--  Function          : Private API to calculate the Outside Proessing cost of
--                      a CMRO Work order.
--  Pre-reqs    :
--  Parameters  :
--      p_workorder_id                  IN      NUMBER       Required
--      x_osp_cost                      OUT     NUMBER       Required
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_OSP_Cost
(
    x_return_status       OUT  NOCOPY    VARCHAR2,
    p_workorder_id          IN   NUMBER,
    x_osp_cost              OUT  NOCOPY   NUMBER);

----------------------------------------

End AHL_OSP_COST_PVT;

 

/
