--------------------------------------------------------
--  DDL for Package BOM_BOM_ISETUP_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_BOM_ISETUP_IMP" AUTHID CURRENT_USER AS
/* $Header: BOMBMSTS.pls 115.1 2004/02/12 09:08:40 aujain ship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMBMSTS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_BOM_ISETUP_IMP
--
--  NOTES
--
--  HISTORY
--
--  18-NOV-02  M V M P Tilak	Initial Creation
--  10-FEB-04   Anupam Jain      Bug# 3349138, avoid redundant migration of
--                               Item Revisions data.
***************************************************************************/
PROCEDURE Import_Bom (P_debug             IN VARCHAR2 := 'N',
                      P_output_dir        IN VARCHAR2 := NULL,
                      P_debug_filename    IN VARCHAR2 := 'BOM_BO_debug.log',
                      P_bom_header_XML    IN CLOB,
--Bug# 3349138        P_bom_revisions_XML IN CLOB,
                      P_bom_inv_comps_XML IN CLOB,
                      P_bom_sub_comps_XML IN CLOB,
                      P_bom_ref_desgs_XML IN CLOB,
                      P_bom_comp_oper_XML IN CLOB,
                      X_return_status     OUT NOCOPY VARCHAR2,
                      X_msg_count         OUT NOCOPY NUMBER,
                      X_G_msg_data        OUT NOCOPY LONG);

END BOM_BOM_ISETUP_IMP;

 

/
