--------------------------------------------------------
--  DDL for Package GMD_COMMON_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_COMMON_GRP" AUTHID CURRENT_USER AS
--$Header: GMDGCOMS.pls 120.0 2005/06/17 08:15:00 sxfeinst noship $ */

--+=======================================================================================================+
--|                   Copyright (c) 1998 Oracle Corporation
--|                          Redwood Shores, CA, USA
--|                            All rights reserved.
--+========================================================================================================+
--| File Name          : GMDGCOMS.pls
--| Package Name       : GMD_COMMON_GRP
--| Type               : Group
--|
--| Notes
--|    This package contains common group layer APIs for Quality
--|
--| HISTORY
--|    S. Feinstein     05-Jan-2004 Created.
--|
--+========================================================================================================+

PROCEDURE item_is_locator_controlled (
                      p_organization_id   IN    NUMBER
                     ,p_subinventory      IN    VARCHAR2
                     ,p_inventory_item_id IN    NUMBER
                     ,x_locator_type      OUT NOCOPY   NUMBER
                     ,x_return_status     OUT NOCOPY VARCHAR2
                                   ) ;

PROCEDURE Get_organization_type (
                         p_organization_id IN  Number
                        ,x_plant           OUT NOCOPY NUMBER
                        ,x_lab             OUT NOCOPY NUMBER
                        ,x_return_status   OUT NOCOPY VARCHAR2);

PROCEDURE Get_lot_attributes ( p_organization_id    IN  NUMBER
                              ,p_inventory_item_id  IN  NUMBER
                              ,p_lot_number         IN  VARCHAR2
                              ,p_parent_lot_number  IN  VARCHAR2
                              ,x_lot_status_code    OUT NOCOPY VARCHAR2
                              ,x_grade_code         OUT NOCOPY VARCHAR2
                              ,x_return_status      OUT NOCOPY VARCHAR2);
END GMD_COMMON_GRP;

 

/
