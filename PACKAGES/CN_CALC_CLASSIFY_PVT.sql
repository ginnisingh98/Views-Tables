--------------------------------------------------------
--  DDL for Package CN_CALC_CLASSIFY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_CLASSIFY_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvcclss.pls 120.3.12010000.1 2008/07/24 11:04:21 appldev ship $

  -- API name 	: classify_batch
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:  p_physical_batch_id NUMBER(15) Require
  --
  --
  --  +
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE classify_batch
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_physical_batch_id     IN  NUMBER,
      p_mode                  IN  VARCHAR2 := 'NORMAL'

      );


   -- API name 	: classify
  -- Type	: Private.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --		   p_transaction_rec   cn_commission_headers%rowtype
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --               x_revenue_class_id   NUMBER
  --
  --
  --  +
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE classify
 (  p_api_version                IN      NUMBER,
    p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_transaction_rec            IN      cn_commission_headers%rowtype,
    x_revenue_class_id           OUT NOCOPY NUMBER,
    x_return_status              OUT NOCOPY     VARCHAR2,
    x_msg_count                  OUT NOCOPY     NUMBER,
    x_msg_data                   OUT NOCOPY     VARCHAR2
    );


END cn_calc_classify_pvt;

/
