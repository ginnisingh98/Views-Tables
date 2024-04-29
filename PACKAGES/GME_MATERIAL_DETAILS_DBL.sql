--------------------------------------------------------
--  DDL for Package GME_MATERIAL_DETAILS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_MATERIAL_DETAILS_DBL" AUTHID CURRENT_USER AS
/*  $Header: GMEVGMDS.pls 120.1.12010000.2 2009/02/27 20:17:53 gmurator ship $    */
/* ===========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVBHMS.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package gme_material_details_dbl                           |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |  13-Feb-01 Created                                                      |
 |                                                                         |
 |             - create_row                                                |
 |             - fetch_row                                                 |
 |             - delete_row                                                |
 |             - update_row                                                |
 |             - fetch_tab                                                 |
 |                                                                         |
 |                                                                         |
 |                                                                         |
    G. Muratore   26-Feb-2009  Bug 7710435
       Added Called by parameter to avoid timestamp failures during
       batch creation. FUNCTION: update_row
 ===========================================================================
*/
   FUNCTION insert_row (
      p_material_detail   IN              gme_material_details%ROWTYPE
     ,x_material_detail   IN OUT NOCOPY   gme_material_details%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION fetch_row (
      p_material_detail   IN              gme_material_details%ROWTYPE
     ,x_material_detail   IN OUT NOCOPY   gme_material_details%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION delete_row (p_material_detail IN gme_material_details%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION update_row (p_material_detail IN gme_material_details%ROWTYPE
                       ,p_called_by IN VARCHAR2 DEFAULT 'U')
      RETURN BOOLEAN;

   FUNCTION fetch_tab (
      p_material_detail   IN              gme_material_details%ROWTYPE
     ,x_material_detail   IN OUT NOCOPY   gme_common_pvt.material_details_tab)
      RETURN BOOLEAN;
END;

/
