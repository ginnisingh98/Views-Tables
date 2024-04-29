--------------------------------------------------------
--  DDL for Package CN_CALC_SUBMISSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUBMISSION_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvsbcss.pls 120.2 2005/07/14 17:31:33 ymao ship $*/

-- Start of comments
--    API name        : Validate
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER              Required
--                      p_init_msg_list       IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER              Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_calc_sub_batch_id   IN      NUMBER              Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : 1) Validate a calculation submission batch
--
-- End of comments

PROCEDURE Validate
  (p_api_version                IN  NUMBER                          ,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN  VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   p_calc_sub_batch_id          IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE);

-- Start of comments
--    API name        : Calculate
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER              Required
--                      p_init_msg_list       IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER              Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_calc_sub_batch_id   IN      NUMBER              Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : 1) Process a calculation submission batch. This process commits automatically.
--
-- End of comments

-- Start of comments
--    API name        : CopyBatch
--    Type            : Private.
--    Function        :
--    Pre-reqs        : None.
--    Parameters      :
--    IN              : p_api_version         IN      NUMBER              Required
--                      p_init_msg_list       IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_commit              IN      VARCHAR2            Optional
--                        Default = FND_API.G_FALSE
--                      p_validation_level    IN      NUMBER              Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                      p_calc_sub_batch_id   IN      NUMBER              Required
--

--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--   	                p_out_calc_sub_batch_id      OUT NOCOPY  cn_calc_submission_batches.calc_sub_batch_id%TYPE);
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : 1) Validate a calculation submission batch
--
-- End of comments

PROCEDURE CopyBatch
  	(p_api_version               IN  NUMBER,
   	p_init_msg_list              IN  VARCHAR2,
   	p_commit                     IN  VARCHAR2,
   	p_validation_level           IN  NUMBER,
   	x_return_status              OUT NOCOPY VARCHAR2,
   	x_msg_count                  OUT NOCOPY NUMBER,
   	x_msg_data                   OUT NOCOPY VARCHAR2,
   	p_calc_sub_batch_id          IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE,
   	p_out_calc_sub_batch_id      OUT NOCOPY  cn_calc_submission_batches.calc_sub_batch_id%TYPE);


PROCEDURE Calculate
  (p_api_version                IN  NUMBER                          ,
   p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   p_calc_sub_batch_id          IN  cn_calc_submission_batches.calc_sub_batch_id%TYPE);

-- This procedure should be invoked only when retrieving calculation batch records in response to a search request
-- from the calculation batch search page.
PROCEDURE maintain_batch_status ;

END CN_CALC_SUBMISSION_PVT;

 

/
