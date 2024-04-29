--------------------------------------------------------
--  DDL for Package CN_PAY_APPROVAL_FLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PAY_APPROVAL_FLOW_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvpflws.pls 115.1 2002/11/21 21:14:57 hlchen ship $

-- Start of comments
--    API name        : Submit_Worksheet
--    Type            : Private.
--    Function        : submit worksheet for approval.
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_worksheet_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Submit_Worksheet
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_worksheet_id            IN     NUMBER
   );

-- Start of comments
--    API name        : Approve_Worksheet
--    Type            : Private.
--    Function        : approve worksheet
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_worksheet_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Approve_Worksheet
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_worksheet_id            IN     NUMBER
   );

-- Start of comments
--    API name        : Reject_Worksheet
--    Type            : Private.
--    Function        : reject worksheet
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_worksheet_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Reject_Worksheet
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_worksheet_id            IN     NUMBER
   );

-- Start of comments
--    API name        : Pay_Payrun
--    Type            : Private.
--    Function        : pay payrun
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_payrun_id  IN   NUMBER
--    OUT             :
--    Version :         Current version       1.0
--
-- End of comments


PROCEDURE Pay_Payrun
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_payrun_id               IN     NUMBER
   );

END CN_PAY_APPROVAL_FLOW_PVT ;

 

/
