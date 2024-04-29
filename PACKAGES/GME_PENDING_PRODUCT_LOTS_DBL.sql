--------------------------------------------------------
--  DDL for Package GME_PENDING_PRODUCT_LOTS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_PENDING_PRODUCT_LOTS_DBL" AUTHID CURRENT_USER AS
/*  $Header: GMEVGPLS.pls 120.0 2005/06/17 14:31:25 snene noship $    */
 /* ========================================================================
 |                Copyright (c) 2001 Oracle Corporation                    |
 |                        TVP, Reading, England                            |
 |                         All rights reserved                             |
 ===========================================================================
 |  FILENAME                                                               |
 |      GMEVGPLB.pls                                                       |
 |                                                                         |
 |  DESCRIPTION                                                            |
 |                                                                         |
 |      Spec of package gme_pending_product_lots_dbl                       |
 |                                                                         |
 |  NOTES                                                                  |
 |                                                                         |
 |  HISTORY                                                                |
 |                                                                         |
 |             - insert_row                                                |
 |             - fetch_row                                                 |
 |             - delete_row                                                |
 |             - update_row                                                |
 |             - lock_row                                                  |
 |                                                                         |
 |                                                                         |
 =========================================================================*/

  FUNCTION insert_row
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   IN OUT NOCOPY  gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN;

  FUNCTION fetch_row
    (p_pending_product_lots_rec   IN  gme_pending_product_lots%ROWTYPE
    ,x_pending_product_lots_rec   IN OUT NOCOPY  gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN;

  FUNCTION delete_row (p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN;

  FUNCTION update_row (p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN;

  FUNCTION lock_row (p_pending_product_lots_rec IN gme_pending_product_lots%ROWTYPE) RETURN BOOLEAN;

END gme_pending_product_lots_dbl;

 

/
