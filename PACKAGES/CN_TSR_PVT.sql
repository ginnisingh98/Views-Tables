--------------------------------------------------------
--  DDL for Package CN_TSR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TSR_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvtsrs.pls 115.5 2002/11/21 21:19:59 hlchen ship $ */

TYPE tsr_rec_type IS RECORD
  (
   tsr_emp_no            VARCHAR2(30)           := NULL,
   tsr_name              VARCHAR2(80)           := NULL,
   mgr_emp_no            VARCHAR2(30)           := NULL,
   mgr_name              VARCHAR2(80)           := NULL,
   tsr_srp_id            NUMBER := NULL,
   tsr_mgr_id            NUMBER := NULL
   );

TYPE tsr_tbl_type IS
   TABLE OF tsr_rec_type INDEX BY BINARY_INTEGER ;

-- Global variable that represent missing values.

   G_MISS_TSR_REC   tsr_rec_type;
   G_MISS_TSR_TBL   tsr_tbl_type;


-- Start of comments
-- API name    : Get_Tsr_Data
-- Type        : Private.
-- Pre-reqs    : None.
-- Usage       :
--
-- Desc        :
--
--
--
-- Parameters  :
-- IN          :  p_api_version       NUMBER      Require
--                p_init_msg_list     VARCHAR2    Optional
--                    Default = FND_API.G_FALSE
--                p_commit            VARCHAR2    Optional
--                    Default = FND_API.G_FALSE
--                p_validation_level  NUMBER      Optional
--                    Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     VARCHAR2(1)
--                x_msg_count         NUMBER
--                x_msg_data          VARCHAR2(2000)
-- IN          :  p_mgr_id            NUMBER
--                p_comp_group_id     NUMBER
--                p_org_code          VARCHAR2
--                p_period_id         NUMBER
--                p_start_row         NUMBER
--                p_rows              NUMBER
-- OUT         :  x_tsr_data          tsr_tbl_type
--                x_total_rows        NUMBER
-- Version     :  Current version     1.0
--                Initial version     1.0
--
-- Notes       :  Note text
--
-- End of comments


PROCEDURE Get_Tsr_Data
  (
   p_api_version               IN    NUMBER,
   p_init_msg_list             IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit                    IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level          IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status             OUT NOCOPY   VARCHAR2,
   x_msg_count                 OUT NOCOPY   NUMBER,
   x_msg_data                  OUT NOCOPY   VARCHAR2,
   p_mgr_id                    IN    NUMBER,
   p_comp_group_id             IN    NUMBER,
   p_org_code                  IN    VARCHAR2,
   p_period_id                 IN    DATE,
   p_start_row                 IN    NUMBER,
   p_rows                      IN    NUMBER,
   x_tsr_data                  OUT NOCOPY   tsr_tbl_type,
   x_total_rows                OUT NOCOPY   NUMBER,
   download                     IN      VARCHAR2 := 'N'
   );

END CN_TSR_PVT;


 

/
