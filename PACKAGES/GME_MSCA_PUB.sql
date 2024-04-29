--------------------------------------------------------
--  DDL for Package GME_MSCA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GME_MSCA_PUB" AUTHID CURRENT_USER AS
/*  $Header: GMEPMSCS.pls 120.0.12010000.2 2009/08/19 15:41:36 gmurator ship $   */



/*===========================================================================+
 |      Copyright (c) 2004 Oracle Corporation, Redwood Shores, CA, USA       |
 |                         All rights reserved.                              |
 |===========================================================================|
 |                                                                           |
 | PL/SQL Package to support the (Java) GME Mobile Application. Various      |
 | procedures perform lookups. Others perform updates by calling the GME     |
 | public APIs to commit the changes made on the mobile screen.              |
 |                                                                           |
 | Author: Paul Schofield, OPM Development UK, August 2004                   |
 |                                                                           |
 +===========================================================================+
 |  HISTORY                                                                  |
 |                                                                           |
 | Date          Who               What                                      |
 | ====          ===               ====                                      |
 | 03Sep04       PJS               First version following TDD Review        |
 | 11Oct04       PJS               Corrected phase to pls from plb in dbdrv  |
 | 23Nov04       Eddie Oumerretane Added procedure Create_Lot                |
 |                                                                           |
 | 19Aug09       G. Muratore       Stub out obsolete file.                   |
 +===========================================================================*/


END gme_msca_pub;

/
