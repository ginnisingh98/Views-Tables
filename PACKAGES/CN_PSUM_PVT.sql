--------------------------------------------------------
--  DDL for Package CN_PSUM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PSUM_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvpsums.pls 115.5 2002/11/21 21:15:55 hlchen ship $ */
-- Start of comments
-- API name    : Get_psum_Data
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
-- OUT         :  x_psum_data          psum_tbl_type
--                x_total_rows        NUMBER
-- Version     :  Current version     1.0
--                Initial version     1.0
--
-- Notes       :  Note text
--
-- End of comments

type psum_rec_type IS RECORD
  (
     mgr_id         NUMBER,
     mgr_name           VARCHAR2(360),
     srp_role_id        NUMBER,
     srp_id             number,
     overlay_flag       varchar2(1),
     non_std_flag       varchar2(1),
     role_id            NUMBER,
     role_name          VARCHAR2(60),
     job_title_id       NUMBER,
     job_discretion     VARCHAR2(80),
     status             VARCHAR2(30),
     plan_activate_status VARCHAR2(30),
     club_eligible_flag VARCHAR2(1),
     org_code           VARCHAR2(30),
     start_date         date,
     end_date           date,
     group_id           number
     );

type psum_tbl_type IS table OF psum_rec_type INDEX BY binary_integer;


PROCEDURE Get_Psum_Data
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
   p_mgr_dtl_flag              IN    VARCHAR2,
   p_effective_date            IN    DATE,
   x_psum_data                 OUT NOCOPY   psum_tbl_type,
   x_total_rows                OUT NOCOPY   NUMBER
   );

PROCEDURE Get_MO_Psum_Data
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
   p_mgr_dtl_flag              IN    VARCHAR2,
   p_effective_date            IN    DATE,
   p_is_multiorg               IN    VARCHAR2,
   x_psum_data                 OUT NOCOPY   psum_tbl_type,
   x_total_rows                OUT NOCOPY   NUMBER
   );
END CN_psum_PVT;


 

/
