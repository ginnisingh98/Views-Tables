--------------------------------------------------------
--  DDL for Package CN_ACC_PERIODS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ACC_PERIODS_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvsyprs.pls 120.2 2005/08/02 10:33:40 mblum noship $*/

TYPE acc_period_rec_type IS RECORD
  (period_name            gl_period_statuses.period_name%TYPE,
   period_year            gl_period_statuses.period_year%TYPE,
   start_date             gl_period_statuses.start_date%TYPE,
   end_date               gl_period_statuses.end_date%TYPE,
   closing_status_meaning gl_lookups.meaning%TYPE,
   prosessing_status      cn_lookups.meaning%TYPE,
   freeze_flag            cn_period_statuses.freeze_flag%TYPE,
   object_version_number  cn_period_statuses.object_version_number%TYPE);

TYPE acc_period_tbl_type IS TABLE OF acc_period_rec_type INDEX BY BINARY_INTEGER;

-- Procedure to start OPEN_PERIODS concurrent request
PROCEDURE open_period
   (errbuf        OUT NOCOPY VARCHAR2,
    retcode       OUT NOCOPY NUMBER,
    p_period_name IN VARCHAR2,
    p_freeze_flag IN VARCHAR2);

-- Procedure to start concurrent request for opening a period
PROCEDURE start_request(p_org_id IN NUMBER, x_request_id OUT NOCOPY NUMBER);


-- Start of comments
--    API name        : Update_Acc_Periods
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
--                      p_acc_period_tbl      IN      acc_period_tbl_type Required
--                        Default = null
--    IN                p_org_id              IN      NUMBER              Required
--    OUT             : x_return_status       OUT     VARCHAR2(1)
--                      x_msg_count           OUT     NUMBER
--                      x_msg_data            OUT     VARCHAR2(2000)
--    Version :         Current version       1.0
--                      Initial version       1.0
--
--    Notes           : 1) update period_status, insert period record into cn_period_statuses if the
--                         the corresponding record does not exist in cn_period_statuses
--
-- End of comments

PROCEDURE Update_Acc_Periods
  (p_api_version                IN      NUMBER                          ,
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_acc_period_tbl             IN      acc_period_tbl_type             ,
   p_org_id                     IN      NUMBER,
   x_return_status              OUT NOCOPY     VARCHAR2                        ,
   x_msg_count                  OUT NOCOPY     NUMBER                          ,
   x_msg_data                   OUT NOCOPY     VARCHAR2                        );

-- populate the accumulation periods screen
PROCEDURE get_acc_periods
  (p_year                         IN      NUMBER,
   x_system_status                OUT NOCOPY     cn_lookups.meaning%TYPE,
   x_calendar                     OUT NOCOPY     cn_period_sets.period_set_name%TYPE,
   x_period_type                  OUT NOCOPY     cn_period_types.period_type%TYPE,
   x_acc_period_tbl               OUT NOCOPY     acc_period_tbl_type);

END CN_ACC_PERIODS_PVT;

 

/
