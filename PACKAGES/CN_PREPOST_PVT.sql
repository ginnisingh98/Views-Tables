--------------------------------------------------------
--  DDL for Package CN_PREPOST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PREPOST_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvposts.pls 120.0 2005/06/06 17:43:30 appldev noship $ --+
-- ---------------------------------------------------------------------------------+
--
--   Procedure    : Initialize_Batch
--   Description  : This procedure is used to initialize a pre posting batch and
--                  set a global variable CN_PREPOST_PVT.G_BATCH_ID for the session.
--                  The batch can be entirely system generated or have user defined
--                  parameters.  If a batch has already been initialized then it
--                  does nothing.
--   Calls        :
--
-- ---------------------------------------------------------------------------------+
PROCEDURE Initialize_Batch
(     p_api_version               IN      NUMBER                           ,
      p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE      ,
      p_commit                    IN      VARCHAR2 := FND_API.G_FALSE      ,
      p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
      x_return_status             OUT NOCOPY     VARCHAR2                  ,
      x_msg_count                 OUT NOCOPY     NUMBER                    ,
      x_msg_data                  OUT NOCOPY     VARCHAR2                  ,
      x_loading_status            OUT NOCOPY     VARCHAR2                  ,
      p_loading_status            IN      VARCHAR2                  ,
      p_posting_batch_rec         IN OUT NOCOPY  CN_PREPOSTBATCHES.posting_batch_rec_type    ,
      x_status                    OUT NOCOPY     VARCHAR2
);
-- ---------------------------------------------------------------------------------+
--
--   Procedure    : Terminate_Batch
--   Description  : This PUBLIC procedure is used to terminate the current pre
--                  posting batch for a session.  The global variable
--                  CN_PREPOSTBATCHES.G_BATCH_ID is nullified.
--   Calls        :
--
-- ---------------------------------------------------------------------------------+
PROCEDURE Terminate_Batch;
-- ---------------------------------------------------------------------------------+
--
--   Procedure    : Create_From_CommLine
--   Description  : This procedure is used to create a pre posting detail for a
--                  commission line.  A commission line can be created as a NEW
--                  or a REVERTed (e.g., the commission line has previously been
--                  posted and is reversed out) posting detail.
--   Calls        : Initialize_Batch() is called from within.  If a batch already
--                  exists then OK, else it will create an system generated batch.
--
-- ---------------------------------------------------------------------------------+
PROCEDURE Create_From_CommLine
(     p_api_version            IN      NUMBER                           ,
      p_init_msg_list          IN      VARCHAR2 := FND_API.G_FALSE      ,
      p_commit                 IN      VARCHAR2 := FND_API.G_FALSE      ,
      p_validation_level       IN      NUMBER   :=
                                         FND_API.G_VALID_LEVEL_FULL     ,
      x_return_status          OUT NOCOPY     VARCHAR2                         ,
      x_msg_count              OUT NOCOPY     NUMBER                           ,
      x_msg_data               OUT NOCOPY     VARCHAR2                         ,
      p_create_mode            IN      VARCHAR2 := 'NEW'                ,
      p_commission_line_id     IN      NUMBER
);
-- ---------------------------------------------------------------------------------+
--
--   Procedure    : Create_PrePostDetails
--   Description  : This procedure is used to create pre posting details from a
--                  PL/SQL table of transactions, committing once per table (e.g.,
--                  each time the procedure is called).  This procedure therefore
--                  defines a unit of work.  Used to create posting details for
--                  non commission line related transactions (e.g., payment plan
--                  transactions).
--   Calls        :
--
-- ---------------------------------------------------------------------------------+
PROCEDURE Create_PrePostDetails
(     p_api_version             IN       NUMBER                        ,
      p_init_msg_list           IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_commit                  IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_validation_level        IN       NUMBER      :=
                                    FND_API.G_VALID_LEVEL_FULL      ,
      x_return_status           OUT NOCOPY      VARCHAR2                    ,
      x_msg_count               OUT NOCOPY      NUMBER                        ,
      x_msg_data                OUT NOCOPY      VARCHAR2                  ,
      p_posting_detail_rec_tbl  IN OUT NOCOPY   CN_PREPOSTDETAILS.posting_detail_rec_tbl_type
);
-- ---------------------------------------------------------------------------------+
--
--   Procedure    : PrePost_PayWorksheets
--   Description  : This procedure is used to create pre posting details for any
--                  paid but not posted payment worksheets.  Assumes a batch has
--                  been initialized and uses the batch parameters to drive the
--                  selection of pay worksheets.
--                  Populates PL/SQL table and calls Create_PrePostDetails.
--   Calls        : Create_PrePostDetails()
--
-- ---------------------------------------------------------------------------------+
PROCEDURE PrePost_PayWorksheets
(     p_api_version             IN       NUMBER                        ,
      p_init_msg_list           IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_commit                  IN       VARCHAR2 := FND_API.G_FALSE      ,
      p_validation_level        IN       NUMBER      :=
                                    FND_API.G_VALID_LEVEL_FULL      ,
      x_return_status           OUT NOCOPY      VARCHAR2                    ,
      x_msg_count               OUT NOCOPY      NUMBER                      ,
      x_msg_data                OUT NOCOPY      VARCHAR2
);
END CN_PREPOST_PVT;
 

/
