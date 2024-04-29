--------------------------------------------------------
--  DDL for Package EAM_TEXT_INDEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_TEXT_INDEX_PVT" AUTHID DEFINER AS
/* $Header: EAMVTICS.pls 120.1 2005/06/12 21:49:41 appldev  $*/
   -- Start of comments
   -- API name    : EAM_TEXT_INDEX_PVT
   -- Type        : Public or Group or Private.
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2 Optional
   --                                         Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Optional
   --                                         Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER   Optional
   --                                         Default = FND_API.G_VALID_LEVEL_FULL
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- OUT      x_return_status      OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --          parameter1
   --          parameter2
   --          .
   --          .
   -- Version  Current version x.x
   --          Changed....
   --          previous version   y.y
   --          Changed....
   --         .
   --         .
   --          previous version   2.0
   --          Changed....
   --          Initial version    1.0
   --
   -- Notes    : Note text
   --
   -- End of comments


-- -----------------------------------------------------------------------------
--  				Public Globals
-- -----------------------------------------------------------------------------

G_FILE_NAME		CONSTANT  VARCHAR2(12)  :=  'EAMVTICS.pls';
G_RETCODE_SUCCESS	CONSTANT  NUMBER  :=  0;
G_RETCODE_WARNING	CONSTANT  NUMBER  :=  1;
G_RETCODE_ERROR		CONSTANT  NUMBER  :=  2;

G_MISS_NUM		CONSTANT  NUMBER       :=  9.99E125;
G_MISS_CHAR		CONSTANT  VARCHAR2(1)  :=  CHR(0);
G_MISS_DATE		CONSTANT  DATE         :=  TO_DATE('1','J');

G_STATUS_SUCCESS	CONSTANT  VARCHAR2(1)  :=  'S';
G_STATUS_WARNING	CONSTANT  VARCHAR2(1)  :=  'W';
G_STATUS_ERROR		CONSTANT  VARCHAR2(1)  :=  'E';
G_STATUS_UNEXP_ERROR	CONSTANT  VARCHAR2(1)  :=  'U';

G_EXC_ERROR		EXCEPTION;
G_EXC_UNEXPECTED_ERROR	EXCEPTION;


-- -----------------------------------------------------------------------------
--  				Procedures
-- -----------------------------------------------------------------------------
/*
   p_text_context :
                    1 - Asset
		    2 - Work Order

   p_action :
                    1 - Create
		    2 - Update / Rebuild
		    3 - Optimize
                    4 - Drop
*/

PROCEDURE Build_Text_Index
(
    ERRBUF		OUT  NOCOPY  VARCHAR2
 ,  RETCODE		OUT  NOCOPY  NUMBER
 ,  p_text_context      IN           NUMBER
 ,  p_Action		IN           NUMBER
 ,  p_dummy1            IN           NUMBER   DEFAULT NULL
 ,  p_optlevel		IN	     NUMBER   DEFAULT NULL
 ,  p_dummy2            IN           NUMBER   DEFAULT NULL
 ,  p_maxtime		IN           NUMBER   DEFAULT AD_CTX_DDL.Maxtime_Unlimited
);


PROCEDURE Optimize_Index
(
   x_return_status OUT NOCOPY VARCHAR2
 , p_optlevel      IN         VARCHAR2 DEFAULT  AD_CTX_DDL.Optlevel_Full
 , p_maxtime       IN         NUMBER   DEFAULT  AD_CTX_DDL.Maxtime_Unlimited
 , p_index_name	   IN         VARCHAR2
);


PROCEDURE set_Log_Mode ( p_Mode  IN  VARCHAR2 );

PROCEDURE Log_Line ( p_Buffer  IN  VARCHAR2
                   , p_Log_Type IN NUMBER
		   , p_Module IN VARCHAR2 );

-- -----------------------------------------------------------------------------
--				  Functions
-- -----------------------------------------------------------------------------

FUNCTION set_Log_Mode ( p_Mode  IN  VARCHAR2 )
RETURN VARCHAR2;


-- -----------------------------------------------------------------------------
--			         End of Package Spec
-- -----------------------------------------------------------------------------

END EAM_TEXT_INDEX_PVT;

 

/
