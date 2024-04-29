--------------------------------------------------------
--  DDL for Package BOM_RTG_ISETUP_IMP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BOM_RTG_ISETUP_IMP" AUTHID CURRENT_USER AS
/* $Header: BOMRTSTS.pls 115.0 2003/01/16 09:34:13 tmanda noship $ */
/***************************************************************************
--
--  Copyright (c) 1996 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      BOMRTSTS.pls
--
--  DESCRIPTION
--
--      Spec of package BOM_RTG_ISETUP_IMP
--
--  NOTES
--
--  HISTORY
--
--  18-NOV-02  M V M P Tilak	Initial Creation
--
***************************************************************************/
PROCEDURE Import_Routing(P_debug              IN  VARCHAR2 := 'N',
                         P_output_dir         IN  VARCHAR2 := NULL,
                         P_debug_filename     IN  VARCHAR2 := 'BOM_BO_debug.log',
                         P_rtg_hdr_XML        IN  CLOB,
                         P_rtg_rev_XML        IN  CLOB,
                         P_rtg_op_XML         IN  CLOB,
                         P_rtg_op_res_XML     IN  CLOB,
                         P_rtg_sub_op_res_XML IN  CLOB,
                         P_rtg_op_network_XML IN  CLOB,
                         X_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         X_G_msg_data         OUT NOCOPY LONG);

END BOM_RTG_ISETUP_IMP;

 

/
