--------------------------------------------------------
--  DDL for Package EAM_MATERIAL_VALIDATE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_MATERIAL_VALIDATE_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPMTSS.pls 120.1 2005/12/15 06:20:30 grajan noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMPMTSS.pls
--
--  DESCRIPTION
--
--      Spec of package EAM_WO_VALIDATE_PUB
--
--  NOTES
--
--  HISTORY
--
--  02-FEB-2005    Girish Rajan     Initial Creation
***************************************************************************/
FUNCTION Get_Open_Qty(p_required_quantity NUMBER, p_allocated_quantity NUMBER, p_issued_quantity NUMBER)
RETURN NUMBER ;

PROCEDURE Check_Shortage
         (p_api_version                 IN  NUMBER
        , p_init_msg_lst                IN  VARCHAR2 := FND_API.G_FALSE
        , p_commit	                IN  VARCHAR2 := FND_API.G_FALSE
        , x_return_status               OUT NOCOPY VARCHAR2
        , x_msg_count                   OUT NOCOPY NUMBER
        , x_msg_data                    OUT NOCOPY VARCHAR2
        , p_wip_entity_id		IN  NUMBER
	, p_source_api			IN VARCHAR2 DEFAULT null
        , x_shortage_exists		OUT NOCOPY VARCHAR2
        );

G_PKG_NAME CONSTANT VARCHAR2(30):='EAM_MATERIAL_VALIDATE_PUB';

END EAM_MATERIAL_VALIDATE_PUB;

 

/
