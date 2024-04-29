--------------------------------------------------------
--  DDL for Package GME_RESOURCE_TXNS_GTMP_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_RESOURCE_TXNS_GTMP_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVGRGS.pls 120.1 2005/06/03 13:46:10 appldev  $ */
/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGRGS.pls
 |
 |   DESCRIPTION
 |      Spec of package gme_resource_txns_gtmp_dbl
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-01 Thomas Daniel  Created
 |
 |      - insert_row
 |      - fetch_row
 |      - update_row
 |
 |
 =============================================================================
*/
   FUNCTION insert_row (
      p_resource_txns   IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_resource_txns   IN OUT NOCOPY   gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION fetch_row (
      p_resource_txns   IN              gme_resource_txns_gtmp%ROWTYPE
     ,x_resource_txns   IN OUT NOCOPY   gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION delete_row (p_resource_txns IN gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN;

   FUNCTION update_row (p_resource_txns IN gme_resource_txns_gtmp%ROWTYPE)
      RETURN BOOLEAN;
END gme_resource_txns_gtmp_dbl;

 

/
