--------------------------------------------------------
--  DDL for Package IBE_CCTBOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CCTBOM_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVCBMS.pls 115.4 2002/12/16 21:36:00 gzhang ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'IBE_CCTBOM_PVT';


TYPE IBE_BOM_EXPLOSION_REC IS RECORD
(
	component_item_id	NUMBER,
	plan_level		NUMBER,
	optional		NUMBER,
	parent_bom_item_type	NUMBER,
	bom_item_type		NUMBER,
        primary_uom_code        VARCHAR2(3),
        COMPONENT_QUANTITY	NUMBER,
        COMPONENT_CODE		VARCHAR2(1000)
);

type IBE_CCTBOM_REF_CSR_TYPE is REF CURSOR;

--FUNCTION Validate_Model_Bundle(p_model_id IN NUMBER, p_org_id IN NUMBER) RETURN VARCHAR2;

-- Start of comments

--    API name   : Is_Model_Bundle
--    Type       : Private.
--    Function   : Given a model item id, returns true if this is a model bundle--                 ,otherwise returns false
--
--    Pre-reqs   : None.
 --    Parameters :
 --    IN         : p_api_version             IN  NUMBER   Required
 --                 p_init_msg_list           IN  VARCHAR2 Optional
 --                     Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--
--           p_model_id            IN NUMBER Required
--           p_orgnization_id      IN  NUMBER, Required
--
--
--
--
--
--    Version    : Current version 1.0
--
--                 previous version     None
--
--                 Initial version      1.0
--                 Initial version      1.0

--

--    Notes      : Note text

--

-- End of comments

  Function Is_Model_Bundle
	  (p_api_version              IN  NUMBER,
	   p_init_msg_list            IN  VARCHAR2 := FND_API.G_FALSE,
	   p_validation_level         IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	   p_model_id                 IN  NUMBER,
	   p_organization_id           IN  NUMBER
		) RETURN VARCHAR2;



-- Start of comments
--    API name   : Load_Components
--    Type       : Private.
--    Function   : Given a model item id, retrieve all the component item ids of this model item
--
--    Pre-reqs   : None.
--    Parameters :
--    IN         : p_api_version        	IN  NUMBER   Required
--                 p_init_msg_list      	IN  VARCHAR2 Optional
--                     Default = FND_API.G_FALSE
--                 p_validation_level   	IN  NUMBER   Optional
--                     Default = FND_API.G_VALID_LEVEL_FULL
--
--		   p_model_id			IN NUMBER Required
--
--    OUT        : x_return_status      	OUT VARCHAR2(1)
--                 x_msg_count          	OUT NUMBER
--                 x_msg_data           	OUT VARCHAR2(2000)
--		   x_model_bundle		OUT VARCHAR2(1)
--		   x_item_csr			OUT IBE_CCTBOM_REF_CSR_TYPE
--			Record type = IBE_BOM_EXPLOSION_REC
--
--
--
--
--    Version    : Current version	1.0
--
--                 previous version	None
--
--                 Initial version 	1.0
--
--    Notes      : Note text
--
-- End of comments
  procedure Load_Components

		(p_api_version        		IN  NUMBER,
                 p_init_msg_list      		IN  VARCHAR2 := FND_API.G_FALSE,
                 p_validation_level   		IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
     		 x_return_status      		OUT NOCOPY VARCHAR2,
                 x_msg_count          		OUT NOCOPY NUMBER,
                 x_msg_data           		OUT NOCOPY VARCHAR2,

		 p_model_id			IN  NUMBER,
		 p_organization_id		IN  NUMBER,
		 x_item_csr			OUT NOCOPY IBE_CCTBOM_REF_CSR_TYPE
		);

/*----------------------------------------------------------------------
Procedure Name : Explode
Description    :
-----------------------------------------------------------------------*/
		Procedure Explode
		( p_validation_org IN  NUMBER
		, p_group_id       IN  NUMBER := NULL
		, p_session_id     IN  NUMBER := NULL
		, p_levels         IN  NUMBER := 60
		, p_stdcompflag    IN  VARCHAR2 := 'ALL'
		, p_exp_quantity   IN  NUMBER := NULL
		, p_top_item_id    IN  NUMBER
		, p_revdate        IN  DATE
		, p_component_code IN  VARCHAR2 := NULL
		, x_msg_data       OUT NOCOPY VARCHAR2
		, x_error_code     OUT NOCOPY NUMBER
		, x_return_status  OUT NOCOPY VARCHAR2);



end IBE_CCTBOM_PVT;

 

/
