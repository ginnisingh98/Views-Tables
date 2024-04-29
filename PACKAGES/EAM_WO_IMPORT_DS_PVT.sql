--------------------------------------------------------
--  DDL for Package EAM_WO_IMPORT_DS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_WO_IMPORT_DS_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVDSIS.pls 120.0 2005/06/08 02:44:57 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVDSIS.pls
--
--  DESCRIPTION
--
--  Package Interface for importing Work Order from Interface Tables for
--  Detailed Scheduling Project
--
--  NOTES
--
--  HISTORY
--
-- 23-SEP-2004    Milind Maduskar     Initial Creation
***************************************************************************/

PROCEDURE IMPORT_WORKORDER (
  errbuf                      OUT NOCOPY     VARCHAR2,
  retcode                     OUT NOCOPY     NUMBER,
  P_GROUP_ID		      IN NUMBER);


END EAM_WO_IMPORT_DS_PVT;

 

/
