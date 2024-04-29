--------------------------------------------------------
--  DDL for Package GME_INIT_RSRC_TXNS_SUMMARY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_INIT_RSRC_TXNS_SUMMARY" AUTHID CURRENT_USER AS
/* $Header: GMEMIRSS.pls 120.0 2005/05/26 14:29:26 appldev noship $ */
/*============================================================================
 |                         Copyright (c) 2002 Oracle Corporation
 |                             Redwood Shores, California, USA
 |                                  All rights reserved
 =============================================================================
 |   FILENAME
 |      GMEMIRSB.pls
 |
 |   DESCRIPTION
 |      Package specification containing the procedures used to populate
 |      the new resource transaction summary table.
 |
 |   NOTES
 |
 |   HISTORY
 |     03-OCT-2002 Eddie Oumerretane   Created.
 =============================================================================
*/

  PROCEDURE Initialize_Rsrc_Txns_Summary;

END GME_INIT_RSRC_TXNS_SUMMARY;

 

/
