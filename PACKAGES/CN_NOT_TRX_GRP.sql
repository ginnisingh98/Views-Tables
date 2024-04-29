--------------------------------------------------------
--  DDL for Package CN_NOT_TRX_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_NOT_TRX_GRP" AUTHID CURRENT_USER as
/* $Header: cngntxs.pls 120.1 2005/09/05 05:36:56 apink noship $ */

-- Start of comments
-- API name    : Col_Adjustments
-- Type        : Group
-- Pre-reqs    : None
-- Function    : Procedure to collect line adjustments from CN_NOT_TRX and
--               and create Reversal records in CN_COMM_LINES_API
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Required
--                p_init_msg_list     IN VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_commit            IN VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT          : x_return_status     OUT VARCHAR2(1)
--                x_msg_count         OUT NUMBER
--                x_msg_data          OUT VARCHAR2(2000)
--
-- Version :  Current version   1.0
--            Previous version  1.0
--            Initial version   1.0
--
-- Notes : Internal OSC procedure
--
-- End of comments
PROCEDURE Col_Adjustments
(  p_api_version      IN NUMBER,
   p_init_msg_list    IN VARCHAR2 := FND_API.G_FALSE,
   p_commit           IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_org_id IN NUMBER);



END CN_NOT_TRX_GRP;
 

/
