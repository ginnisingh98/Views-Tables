--------------------------------------------------------
--  DDL for Package CN_ADD_TBH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ADD_TBH_PVT" AUTHID CURRENT_USER AS
  /*$Header: cnvatbhs.pls 115.5 2002/11/25 19:07:59 nkodkani ship $*/

-- Start of comments
--    API name        : Create_TBH - Private.
--    Pre-reqs        : None.
--    IN              : standard params
--                      mgr_srp_id, emp_num, name, comp_group, job_title_id
--                      start+end date for srp, mgr assignment, job assignment
--    OUT             : standard params
--                      x_srp_id
--    Version         : 1.0
--
-- End of comments

PROCEDURE Create_TBH
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mgr_srp_id                 IN      NUMBER,
   p_name                       IN      VARCHAR2,
   p_emp_num                    IN      VARCHAR2,
   p_comp_group_id              IN      NUMBER,
   p_start_date_active          IN      DATE,
   p_end_date_active            IN      DATE,
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_srp_id                     OUT NOCOPY     NUMBER);

-- Given a manager's employee number, create the next sequence number
-- for a TBH under that manager
FUNCTION Get_TBH_Emp_Num
  (p_mgr_emp_num                IN      VARCHAR2) RETURN NUMBER;

END CN_ADD_TBH_PVT;

 

/
