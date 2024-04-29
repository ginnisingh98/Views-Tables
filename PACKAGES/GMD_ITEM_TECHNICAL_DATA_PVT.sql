--------------------------------------------------------
--  DDL for Package GMD_ITEM_TECHNICAL_DATA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_ITEM_TECHNICAL_DATA_PVT" AUTHID CURRENT_USER AS
/* $Header: GMDVITDS.pls 120.3 2005/08/24 08:18:09 srsriran noship $ */


--Start of comments
--+========================================================================+
--| API Name    : INSERT_ITEM_TECHNICAL_DATA_HDR                           |
--| TYPE        : Private                                                  |
--| Function    : Inserts the Item technical data header record            |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE INSERT_ITEM_TECHNICAL_DATA_HDR
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, x_tech_data_id        IN OUT  NOCOPY  NUMBER
, p_organization_id     IN              NUMBER
, p_inventory_item_id   IN              NUMBER
, p_lot_no		IN		VARCHAR2
, p_lot_organization_id IN              NUMBER
, p_formula_id          IN              NUMBER
, p_batch_id            IN              NUMBER
, p_delete_mark         IN              NUMBER
, p_text_code           IN              NUMBER
, p_creation_date       IN              DATE
, p_created_by          IN              NUMBER
, p_last_update_date    IN              DATE
, p_last_updated_by     IN              NUMBER
, p_last_update_login   IN              NUMBER
);

--Start of comments
--+========================================================================+
--| API Name    : INSERT_ITEM_TECHNICAL_DATA_DTL                           |
--| TYPE        : Private                                                  |
--| Function    : Inserts the Item technical data detail records           |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE INSERT_ITEM_TECHNICAL_DATA_DTL
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, x_tech_data_id        IN OUT  NOCOPY  NUMBER
, x_tech_parm_id        IN OUT  NOCOPY  NUMBER
, p_sort_seq            IN              NUMBER
, p_text_data           IN              VARCHAR2
, p_num_data            IN              NUMBER
, p_boolean_data        IN              NUMBER
, p_text_code           IN              NUMBER
, p_creation_date       IN              DATE
, p_created_by          IN              NUMBER
, p_last_update_date    IN              DATE
, p_last_updated_by     IN              NUMBER
, p_last_update_login   IN              NUMBER
);

--Start of comments
--+========================================================================+
--| API Name    : UPDATE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Private                                                  |
--| Function    : Updates the Item technical data detail records           |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE UPDATE_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_tech_data_id	IN              NUMBER
, x_tech_parm_id        IN OUT  NOCOPY  NUMBER
, p_sort_seq            IN              NUMBER
, p_text_data           IN              VARCHAR2
, p_num_data            IN              NUMBER
, p_boolean_data        IN              NUMBER
, p_text_code           IN              NUMBER
, p_last_update_date    IN              DATE
, p_last_updated_by     IN              NUMBER
, p_last_update_login   IN              NUMBER
);

--Start of comments
--+========================================================================+
--| API Name    : DELETE_ITEM_TECHNICAL_DATA                               |
--| TYPE        : Private                                                  |
--| Function    : Deletes the Item technical data                          |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE DELETE_ITEM_TECHNICAL_DATA
(
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, p_commit		IN  		VARCHAR2 := FND_API.G_FALSE
, x_return_status	OUT 	NOCOPY 	VARCHAR2
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_tech_data_id	IN              NUMBER
);

--Start of comments
--+========================================================================+
--| API Name    : FETCH_ITEM_TECHNICAL_DATA                                |
--| TYPE        : Private                                                  |
--| Function    : Fetches the Item technical data based on the input parm's|
--|               passed.                                                  |
--| Notes       :                                                          |
--|                                                                        |
--| HISTORY                                                                |
--|     S.Sriram        21-Feb-2005     Created                            |
--+========================================================================+
-- End of comments

PROCEDURE FETCH_ITEM_TECHNICAL_DATA (
  p_api_version		IN  		NUMBER
, p_init_msg_list	IN  		VARCHAR2 := FND_API.G_FALSE
, x_msg_count		OUT 	NOCOPY 	NUMBER
, x_msg_data		OUT 	NOCOPY 	VARCHAR2
, p_header_rec		IN              GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_hdr_rec
, x_dtl_tbl		OUT 	NOCOPY 	GMD_ITEM_TECHNICAL_DATA_PUB.technical_data_dtl_tab
, x_return_status	OUT 	NOCOPY 	VARCHAR2
);

END GMD_ITEM_TECHNICAL_DATA_PVT ;


 

/
