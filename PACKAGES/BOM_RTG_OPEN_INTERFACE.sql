--------------------------------------------------------
--  DDL for Package BOM_RTG_OPEN_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_OPEN_INTERFACE" AUTHID CURRENT_USER AS
/* $Header: BOMPROIS.pls 120.1 2005/06/20 06:17:30 appldev ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMPROIS.pls
--
--  DESCRIPTION
--
--      Specification of package BOM_RTG_OPEN_INTERFACE
--
--  NOTES
--
--  HISTORY
--
--  12-DEC-02   Deepak Jebar    Initial Creation
--  15-JUN-05   Abhishek Bhardwaj Added Batch Id
--
***************************************************************************/


FUNCTION IMPORT_RTG
(  p_organization_id    IN  NUMBER
   , p_all_org   	IN  NUMBER
   , p_delete_rows 	IN  NUMBER
   , x_err_text		IN OUT NOCOPY VARCHAR2
) RETURN INTEGER;

-- Overloaded IMPORT_RTG for Batch Import
FUNCTION IMPORT_RTG
(  p_organization_id    IN  NUMBER
   , p_all_org   	IN  NUMBER
   , p_delete_rows 	IN  NUMBER
   , x_err_text		IN OUT NOCOPY VARCHAR2
   , p_batch_id         IN  NUMBER
) RETURN INTEGER;

END BOM_RTG_OPEN_INTERFACE;

 

/
