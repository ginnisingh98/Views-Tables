--------------------------------------------------------
--  DDL for Package EAM_ISUP_CHECK_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ISUP_CHECK_WO_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMISWPS.pls 120.1 2005/11/08 23:18:05 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMISWPS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_ISUP_CHECK_WO_PUB
--
--  NOTES
--
--  HISTORY
--
--  02-NOV-2005    Basanth Roy     Initial Creation
***************************************************************************/

        g_debug_flag            VARCHAR2(1) := 'N';


        PROCEDURE CHECK_WO_EXISTS
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_header_id               IN  NUMBER
         , p_release_id              IN  NUMBER
         , x_wo_exists               OUT NOCOPY VARCHAR2
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         );


END EAM_ISUP_CHECK_WO_PUB;

 

/
