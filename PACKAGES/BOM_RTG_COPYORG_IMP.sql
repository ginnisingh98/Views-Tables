--------------------------------------------------------
--  DDL for Package BOM_RTG_COPYORG_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_COPYORG_IMP" AUTHID CURRENT_USER AS
/* $Header: BOMRTCPS.pls 120.0.12000000.1 2007/02/26 12:18:46 appldev noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRTCPS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_RTG_COPYORG_IMP
--
--  NOTES
--
--  HISTORY
--
--  06-OCT-06  Mohan Yerramsetty  Bug# 5493353, Initial Creation.
--                                This package has PL/SQL logic of Copying
--				  Routings. It doesn't use Exporting to XML,
--				  Importing from XML Logic. This will fetch
--				  all Routings from source organization and
--				  pass all the records to Routing Interface API.
--				  Routing Interface API will do the copying.
--
***************************************************************************/
PROCEDURE Import_Routing(P_debug              IN  VARCHAR2 := 'N',
                         P_output_dir         IN  VARCHAR2 := NULL,
                         P_debug_filename     IN  VARCHAR2 := 'BOM_BO_debug.log',
  			 p_model_org_id	      IN  NUMBER,
			 p_target_orgcode     IN  VARCHAR2,
                         X_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         X_G_msg_data         OUT NOCOPY LONG);

END BOM_RTG_COPYORG_IMP;

 

/
