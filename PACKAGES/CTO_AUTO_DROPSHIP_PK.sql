--------------------------------------------------------
--  DDL for Package CTO_AUTO_DROPSHIP_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CTO_AUTO_DROPSHIP_PK" AUTHID CURRENT_USER AS
/*$Header: CTODROPS.pls 120.1 2005/06/06 09:45:16 appldev  $ */
/*============================================================================+
|  Copyright (c) 1999 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|                                                                             |
| FILE NAME   : CTODROPS.pls                                                  |
| DESCRIPTION:                                                                |
|               Contain all CTO and WF related APIs for AutoCreate Purchase   |
|               Requisitions. This Package creates the following              |
|               Procedures                                                    |
|               1. AUTO_CREATE_DROPSHIP                                       |
|               Functions                                                     |
| HISTORY     :                                                               |
| 20-FEB-2002 : Sushant Sawant Initial version                                |
| 01-Jun-2005 : Renga Kannan   Added NOCOPY HINT for all out parameters.
=============================================================================*/

-- CTO_AUTO_DROPSHIP_PK
-- following parameters are created for
   g_pkg_name     CONSTANT  VARCHAR2(30) := 'CTO_AUTO_DROPSHIP_PK';
   gMrpAssignmentSet        NUMBER ;


/**************************************************************************
   Procedure:   AUTO_CREATE_DROPSHIP
   Parameters:  p_sales_order             NUMBER    -- Sales Order number.
                p_dummy_field             VARCHAR2  -- Dummy field for the Concurrent Request.
                p_sales_order_line_id     NUMBER    -- Sales Order Line number.
                p_organization_id         VARCHAR2  -- Ship From Organization ID.
                current_organization_id   NUMBER    -- Current Org ID
                p_offset_days             NUMBER    -- Offset days.

   Description: This procedure is called from the concurrent progran to run the
                AutoCreate Purchase Requisitions.
*****************************************************************************/
PROCEDURE auto_create_dropship (
           errbuf              OUT   NOCOPY VARCHAR2,
           retcode             OUT   NOCOPY VARCHAR2,
           p_sales_order             NUMBER,
           p_dummy_field             VARCHAR2,
           p_sales_order_line_id     NUMBER,
           p_organization_id         VARCHAR2,
           current_organization_id   NUMBER, -- VARCHAR2,
           p_offset_days             NUMBER );


END cto_auto_dropship_pk;

 

/
