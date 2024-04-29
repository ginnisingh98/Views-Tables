--------------------------------------------------------
--  DDL for Package CN_SRP_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_VALIDATION_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpsrpvs.pls 120.1 2005/06/10 13:59:55 appldev  $


TYPE srp_trx_rec_type IS RECORD
    ( salesrep_id                 NUMBER(15),
      commission_header_id        NUMBER(15));

  -- API name 	: Validate_trx
  -- Type		: Public.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  IN		:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT		:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN		:  p_srp_trx           srp_trx_rec_type Require
  --
  --
  --  OUT		:  x_validation_status VARCHAR2(1)
  --
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE validate_trx
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_srp_trx            IN  srp_trx_rec_type,

      x_validation_status     OUT NOCOPY VARCHAR2

    );

TYPE srp_pe_rec_type IS RECORD
    ( salesrep_id                 NUMBER(15),
      quota_id        	      NUMBER(15));

  -- API name 	: Validate_pe
  -- Type		: Public.
  -- Pre-reqs	:
  -- Usage	:
  --+
  -- Desc 	:
  --
  --
  --+
  -- Parameters	:
  --  IN		:  p_api_version       NUMBER      Require
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT		:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN		:  p_srp_pe            srp_pe_rec_type Require
  --
  --
  --  OUT		:  x_validation_status VARCHAR2(1)
  --
  --+
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --+
  -- Notes	:
  --+
  -- End of comments

  PROCEDURE validate_pe
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,

      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,

      p_srp_pe                IN  srp_pe_rec_type,

      x_validation_status     OUT NOCOPY VARCHAR2

    );

END cn_srp_validation_pub;

 

/
