--------------------------------------------------------
--  DDL for Package EAM_TEXT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_TEXT_UTIL" AUTHID DEFINER AS
/* $Header: EAMVTIUS.pls 120.2 2006/01/12 04:22:08 cboppana noship $*/


-- -----------------------------------------------------------------------------
--  				Public Globals
-- -----------------------------------------------------------------------------

G_FILE_NAME		CONSTANT  VARCHAR2(12)  :=  'EAMVTIUS.pls';


-- -----------------------------------------------------------------------------
--  				Procedures
-- -----------------------------------------------------------------------------

PROCEDURE Set_Context ( p_context  IN  VARCHAR2 );

/***
***   Procedure called when an asset is create/updated
**/
PROCEDURE Process_Asset_Update_Event
(
   p_event                IN  VARCHAR2    DEFAULT  NULL
,  p_instance_id          IN  NUMBER
,  p_commit               IN  VARCHAR2    DEFAULT  FND_API.G_FALSE
,  p_last_update_date     IN  VARCHAR2    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  VARCHAR2    DEFAULT  FND_API.G_MISS_NUM
);


/***
*****   Proedure called when a workorder  is created/updated
***/
PROCEDURE Process_Wo_Event
(
   p_event                IN        VARCHAR2  DEFAULT  NULL,
   p_wip_entity_id        IN        NUMBER,
   p_organization_id      IN        NUMBER   DEFAULT  NULL
,  p_commit               IN  VARCHAR2    DEFAULT  FND_API.G_FALSE
,  p_last_update_date     IN  DATE    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  NUMBER    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  NUMBER   DEFAULT  FND_API.G_MISS_NUM
);

/***
*****   Proedure called when a status code is updated from User Defined Statuses form
***/
PROCEDURE Process_Status_Update_Event
(
   p_event                IN        VARCHAR2  DEFAULT  NULL,
   p_status_id        IN        NUMBER
,  p_commit               IN  VARCHAR2    DEFAULT  FND_API.G_FALSE
,  p_last_update_date     IN  DATE    DEFAULT  FND_API.G_MISS_DATE
,  p_last_updated_by      IN  NUMBER    DEFAULT  FND_API.G_MISS_NUM
,  p_last_update_login    IN  NUMBER   DEFAULT  FND_API.G_MISS_NUM
 ,  x_return_status     IN OUT NOCOPY VARCHAR2
);

/*****
*****   Procedure called from the Intermedia index for asset to find the text on which index has to be created
*****/
PROCEDURE Get_Asset_Text
(
   p_rowid          IN             ROWID
 , p_output_type    IN             VARCHAR2
 , x_tlob           IN OUT NOCOPY  CLOB
 , x_tchar          IN OUT NOCOPY  VARCHAR2
);

/*****
*****   Procedure called from the Intermedia index for work ordersto find the text on which index has to be created
*****/
PROCEDURE Get_Wo_Text
(
   p_rowid          IN             ROWID
 , p_output_type    IN             VARCHAR2
 , x_tlob           IN OUT NOCOPY  CLOB
 , x_tchar          IN OUT NOCOPY  VARCHAR2
);

/****
****   Procedure called when the intermedia  index has to be updated
****/
PROCEDURE Sync_Index ( p_idx_name  IN  VARCHAR2);


-- -----------------------------------------------------------------------------
--				  Functions
-- -----------------------------------------------------------------------------

FUNCTION get_Prod_Schema
  RETURN VARCHAR2;

FUNCTION get_DB_Version_Num
RETURN NUMBER;

FUNCTION get_DB_Version_Str
RETURN VARCHAR2;

-- -----------------------------------------------------------------------------
--			         End of Package Spec
-- -----------------------------------------------------------------------------

END eam_text_util;

 

/

  GRANT EXECUTE ON "APPS"."EAM_TEXT_UTIL" TO "CTXSYS";
