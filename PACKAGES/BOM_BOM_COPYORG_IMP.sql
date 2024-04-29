--------------------------------------------------------
--  DDL for Package BOM_BOM_COPYORG_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOM_COPYORG_IMP" AUTHID CURRENT_USER AS
/* $Header: BOMBOCPS.pls 120.0 2006/07/04 09:31:08 myerrams noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBOCPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_BOM_COPYORG_IMP
--
--  NOTES
--
--  HISTORY
--
--  05-JUN-06  Mohan Yerramsetty  Bug# 5142847, Initial Creation.
--                                This package has PL/SQL logic of Copying
--				  BOMs. It doesn't use Exporting to XML,
--				  Importing from XML Logic. This will fetch
--				  all Boms from source organization and
--				  pass all the records to Bom Interface.
--				  Bom Interface will do the copying.
***************************************************************************/
PROCEDURE Import_Bom (P_debug             IN VARCHAR2 := 'N',
                      P_output_dir        IN VARCHAR2 := NULL,
                      P_debug_filename    IN VARCHAR2 := 'BOM_BO_debug.log',
  		      p_model_org_id	  IN NUMBER,
		      p_target_orgcode	  IN VARCHAR2,
                      X_return_status     OUT NOCOPY VARCHAR2,
                      X_msg_count         OUT NOCOPY NUMBER,
                      X_G_msg_data        OUT NOCOPY LONG,
		      p_bomthreshold	  IN VARCHAR2 );

END BOM_BOM_COPYORG_IMP;

 

/
