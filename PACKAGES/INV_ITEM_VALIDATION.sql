--------------------------------------------------------
--  DDL for Package INV_ITEM_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_VALIDATION" AUTHID CURRENT_USER AS
/* $Header: INVVIVAS.pls 120.1 2005/06/21 05:50:33 appldev ship $ */

-- --------------------------------------------------------
-- ------------------- Procedure specs --------------------
-- --------------------------------------------------------

PROCEDURE Attribute_Dependency
(
    p_Item_rec          IN   INV_Item_API.Item_rec_type
,   x_return_status     OUT  NOCOPY VARCHAR2
);


PROCEDURE Effectivity_Control
(
    p_Item_rec          IN   INV_Item_API.Item_rec_type
,   x_return_status     OUT  NOCOPY VARCHAR2
);


END INV_Item_Validation;

 

/
