--------------------------------------------------------
--  DDL for Package Body EAM_SYNC_WO_TEXT_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_SYNC_WO_TEXT_INDEX_PVT" AS
/* $Header: EAMVWTSB.pls 120.0 2006/09/20 15:10:36 cboppana noship $ */


-- -----------------------------------------------------------------------------
--                              Private Globals
-- -----------------------------------------------------------------------------

 g_installed           BOOLEAN;
  g_inst_status         VARCHAR2(1);
  g_industry            VARCHAR2(1);
  g_Prod_Schema         VARCHAR2(30);

/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMVWTSB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_SYNC_WO_TEXT_INDEX_PVT

***************************************************************************/

  l_retcode_success   CONSTANT VARCHAR2(1) := '0';
  l_retcode_warning   CONSTANT VARCHAR2(1) := '1';
  l_retcode_error     CONSTANT VARCHAR2(1) := '2';

  PROCEDURE sync IS
	l_count number;
	l_ctx_schema varchar2(20);
  BEGIN

     l_ctx_schema := 'CTXSYS';

     SELECT count(*) into l_count
     FROM all_indexes
     WHERE (owner = g_prod_schema OR owner = USER OR owner = l_ctx_schema)
		AND table_name = 'EAM_WORK_ORDER_TEXT' AND index_name = 'EAM_WORK_ORDER_TEXT_CTX1'
		AND status = 'VALID' AND domidx_status = 'VALID' AND domidx_opstatus = 'VALID';

	 IF (l_count > 0) THEN
		ad_ctx_ddl.sync_index(g_Prod_Schema || '.' || 'EAM_WORK_ORDER_TEXT_CTX1');
	 END IF;

  EXCEPTION
    WHEN OTHERS THEN
      RAISE;
  END;

  PROCEDURE sync_ctx(errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'EAM_SYNC_WO_TEXT_INDEX_PVT';
    l_api_version     CONSTANT VARCHAR2(30) := 1.0;
  BEGIN
    sync;
    retcode := l_retcode_success;
  EXCEPTION
    WHEN OTHERS THEN
      retcode := l_retcode_error;
      errbuf := SUBSTR(sqlerrm,1,200);
  END;

-- *****************************************************************************
-- **                      Package initialization block                       **
-- *****************************************************************************

BEGIN
    -----------------------------------------------------------------
   -- Determine index schema and store in a private global variable
   ------------------------------------------------------------------

   g_installed := FND_INSTALLATION.Get_App_Info ('EAM', g_inst_status, g_industry, g_Prod_Schema);


END;

/
