--------------------------------------------------------
--  DDL for Package INV_GRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_GRADE_PKG" AUTHID CURRENT_USER AS
  /* $Header: INVUPLGS.pls 120.0 2005/05/25 04:54:55 appldev noship $ */

PROCEDURE UPDATE_GRADE
    (   p_organization_id        IN  NUMBER   DEFAULT NULL
      , p_update_method          IN  NUMBER
      , p_inventory_item_id      IN  NUMBER
      , p_from_grade_code        IN  VARCHAR2
      , p_to_grade_code          IN  VARCHAR2
      , p_reason_id              IN  NUMBER
      , p_lot_number             IN  VARCHAR2
      , x_Status                 OUT NOCOPY VARCHAR2
      , x_Message                OUT NOCOPY VARCHAR2
      , p_update_from_mobile     IN  VARCHAR2  DEFAULT 'N'
      , p_primary_quantity       IN  NUMBER
      , p_secondary_quantity     IN  NUMBER
   );

END  INV_GRADE_PKG ;

 

/
