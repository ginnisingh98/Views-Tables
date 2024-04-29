--------------------------------------------------------
--  DDL for Package WIP_TRANSACTION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_TRANSACTION_PVT" AUTHID CURRENT_USER AS
/* $Header: WIPVTXNS.pls 120.0.12010000.1 2008/07/24 05:20:43 appldev ship $ */

--  Start of Comments
--  API name    Process_Transaction
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments


-- Validation levels
NONE                          CONSTANT NUMBER := 0;
REQUIRED		      CONSTANT NUMBER := 5;
COMPLETE                      CONSTANT NUMBER := 10;

PROCEDURE Process_OSP_Transaction
(   p_OSP_rec                       IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_validation_level		    IN  NUMBER DEFAULT COMPLETE
,   p_return_status                 OUT NOCOPY VARCHAR2
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   p_msg_count                     OUT NOCOPY NUMBER
,   p_msg_data                      OUT NOCOPY VARCHAR2
);

--  Start of Comments
--  API name    Get_Transaction
--  Type        Private
--  Function
--
--  Pre-reqs
--
--  Parameters
--
--  Version     Current version = 1.0
--              Initial version = 1.0
--
--  Notes
--
--  End of Comments

PROCEDURE Get_Transaction
(   p_api_version_number            IN  NUMBER
,   p_init_msg_list                 IN  VARCHAR2 := FND_API.G_FALSE
,   x_return_status                 OUT NOCOPY VARCHAR2
,   x_msg_count                     OUT NOCOPY NUMBER
,   x_msg_data                      OUT NOCOPY VARCHAR2
,   p_dummy                         IN  VARCHAR2
,   x_WIPTransaction_tbl            OUT NOCOPY WIP_Transaction_PUB.Wiptransaction_Tbl_Type
,   x_Res_tbl                       OUT NOCOPY WIP_Transaction_PUB.Res_Tbl_Type
,   x_ShopFloorMove_tbl             OUT NOCOPY WIP_Transaction_PUB.Shopfloormove_Tbl_Type
);


PROCEDURE Process_Resource_Transaction
(   p_res_txn_rec                   IN  WIP_Transaction_PUB.Res_Rec_Type
,   p_validation_level		    IN  NUMBER DEFAULT COMPLETE
,   p_return_status                 OUT NOCOPY VARCHAR2
,   p_init_msg_list		    IN  VARCHAR2 := FND_API.G_FALSE
,   p_msg_count			    OUT NOCOPY NUMBER
,   p_msg_data			    OUT NOCOPY VARCHAR2
);


END WIP_Transaction_PVT;

/
