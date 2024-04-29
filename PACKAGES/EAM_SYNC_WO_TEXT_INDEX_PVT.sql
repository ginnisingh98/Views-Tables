--------------------------------------------------------
--  DDL for Package EAM_SYNC_WO_TEXT_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_SYNC_WO_TEXT_INDEX_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVWTSS.pls 120.0 2006/09/20 13:45:53 cboppana noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWTSS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_SYNC_WO_TEXT_INDEX_PVT

***************************************************************************/

  PROCEDURE sync;

  PROCEDURE sync_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

END;

 

/
