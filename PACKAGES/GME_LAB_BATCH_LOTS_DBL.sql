--------------------------------------------------------
--  DDL for Package GME_LAB_BATCH_LOTS_DBL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_LAB_BATCH_LOTS_DBL" AUTHID CURRENT_USER AS
/* $Header: GMEVGLBS.pls 120.0 2005/05/26 14:37:45 appldev noship $ */

/*============================================================================
 |                         Copyright (c) 2001 Oracle Corporation
 |                                 TVP, Reading
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEVGLBS.pls
 |
 |   DESCRIPTION
 |      This procedure is user to manipulate the GME_LAB_BATCH_LOTS table.
 |
 |
 |
 |   NOTES
 |
 |   HISTORY
 |   12-MAR-01	Thomas Daniel	 Created
 |
 |      - create_row
 |      - fetch_row
 |      - update_row
 |      - lock_row
 |
 |
 =============================================================================
*/


  FUNCTION insert_row (
    p_lab_batch_lots	IN GME_LAB_BATCH_LOTS%ROWTYPE
,   x_lab_batch_lots	IN OUT NOCOPY GME_LAB_BATCH_LOTS%ROWTYPE) RETURN BOOLEAN;


  FUNCTION fetch_row (
    p_lab_batch_lots	IN GME_LAB_BATCH_LOTS%ROWTYPE
,   x_lab_batch_lots	IN OUT NOCOPY GME_LAB_BATCH_LOTS%ROWTYPE) RETURN BOOLEAN;


  FUNCTION delete_row (
    p_lab_batch_lots	IN GME_LAB_BATCH_LOTS%ROWTYPE) RETURN BOOLEAN;

  FUNCTION update_row (
    p_lab_batch_lots	IN GME_LAB_BATCH_LOTS%ROWTYPE) RETURN BOOLEAN;

  FUNCTION lock_row (
    p_lab_batch_lots	IN GME_LAB_BATCH_LOTS%ROWTYPE) RETURN BOOLEAN;

  PROCEDURE delete_lab_lots (p_lab_batch_lots	IN GME_LAB_BATCH_LOTS%ROWTYPE
                            ,x_return_status	IN OUT NOCOPY VARCHAR2);

END GME_LAB_BATCH_LOTS_DBL;

 

/
