--------------------------------------------------------
--  DDL for Package FPA_INVESTMENT_CRITERIA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_INVESTMENT_CRITERIA_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVINVS.pls 120.6 2008/01/30 13:24:06 rthumma ship $ */

TYPE Investment_rec_type is RECORD
(
 	project_shortname		varchar2(30) -- Project shortname
	,project_type_shortname		varchar2(30) -- Project Type shortname
	,scenario_shortname		varchar2(30) -- Project shortname
	,strategic_obj_shortname	number(15,0) -- strategic objective shortname
	,strategic_obj_name		varchar2(105) -- strategic objective name
	,strategic_obj_desc		varchar2(240) -- strategic objective description
	,strategic_obj_parent		varchar2(30) -- shortname for the strategic objective parent.
	,strategic_obj_status		varchar2(30) -- shortname for the strategic objective parent.
	,strategic_obj_level		varchar2(30) -- level for the strategic objective.
	,strategic_obj_id		number	    -- ID for strategic Objective, used for BSC.
	,strategic_obj_weight		varchar2(10) -- Value for Strategic Weight
	,strategic_obj_score		varchar2(10) -- Value for Strategic Score
	,strategic_obj_wscore		varchar2(10) -- Value for Strategic Weighted Score
	,strategic_scores_string	varchar2(5000) -- String containing objectives and their scores.
);

TYPE Investment_tbl_type IS TABLE OF Investment_rec_type
  INDEX BY BINARY_INTEGER;

  /*
procedure Create_StrategicObj_Objects_AW(
  p_commit             		IN      	varchar2 := FND_API.G_FALSE
 ,p_Investment_rec_type		IN              FPA_Investment_Criteria_PVT.Investment_rec_type
 ,x_return_status       	OUT NOCOPY	varchar2
 ,x_msg_count           	OUT NOCOPY	number
 ,x_msg_data            	OUT NOCOPY	varchar2
);
*/

PROCEDURE create_strategicobj_aw
(
  	p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
        p_seeding                     IN              VARCHAR2,
        x_strategic_obj_id	      OUT NOCOPY      VARCHAR2,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE delete_strategicobj_aw
(
  	p_api_version                 IN              NUMBER,
	p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE update_strategicobj
(
  	p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE update_strategicobj_status_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE update_strategicobj_level_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
);

PROCEDURE update_strategicobj_weight_aw
(
	p_Investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               OUT NOCOPY      VARCHAR2,
	x_msg_count                   OUT NOCOPY      NUMBER,
	x_msg_data                    OUT NOCOPY      VARCHAR2
);
/*
PROCEDURE update_strategicobj_score_aw
(
  	p_api_version			IN		NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_Investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);
*/

PROCEDURE update_projecttypeobjscore_aw
(
  	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);
/*
PROCEDURE update_strategicobj_wscore_aw
(
  	p_api_version			IN		NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);
*/
/*
PROCEDURE update_projecttypeobjwscore_aw
(
  	p_api_version                 	IN              NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);
*/
/*
PROCEDURE update_strategicobj_ascore_aw
(
  	p_api_version			IN		NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);
*/
/*
procedure Update_ProjectTypeObjAScore_AW(
  p_commit                      IN              varchar2 := FND_API.G_FALSE
 ,p_Investment_rec_type         IN              FPA_Investment_Criteria_PVT.Investment_rec_type
 ,x_return_status               OUT NOCOPY      varchar2
 ,x_msg_count                   OUT NOCOPY      number
 ,x_msg_data                    OUT NOCOPY      varchar2
);
*/
/*
PROCEDURE rollup_strategicobj_wscore_aw
(
  	p_api_version                 	IN              NUMBER,
	p_commit                      	IN              VARCHAR2 := FND_API.G_FALSE,
	p_investment_rec_type         	IN              FPA_Investment_Criteria_PVT.Investment_rec_type,
	x_return_status               	OUT NOCOPY      VARCHAR2,
	x_msg_count                   	OUT NOCOPY      NUMBER,
	x_msg_data                    	OUT NOCOPY      VARCHAR2
);
*/

-------------------------------------------------------------------------------
-- API create_strategicobj_aw , Overloaded API which does not take
-- FPA_Investment_Criteria_PVT.Investment_rec_type as a parameter
--
-- Params
--              p_commit                      IN              VARCHAR2
--              p_seeding                     IN              VARCHAR2
--              x_strategic_obj_id	      OUT NOCOPY      VARCHAR2
--              x_return_status               OUT NOCOPY      VARCHAR2
--              x_msg_count                   OUT NOCOPY      NUMBER
--              x_msg_data                    OUT NOCOPY      VARCHAR2
--              p_strategic_obj_shortname     IN              NUMBER
-- 		p_strategic_obj_desc          IN              VARCHAR2
-- 		p_strategic_obj_name          IN              VARCHAR2
-- 		p_strategic_obj_level         IN              VARCHAR2
--              p_strategic_obj_parent        IN              VARCHAR2
-------------------------------------------------------------------------------
PROCEDURE create_strategicobj_aw
(
  	    p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
            p_seeding                     IN              VARCHAR2,
            p_strategic_obj_shortname     IN              NUMBER,
            p_strategic_obj_desc          IN              VARCHAR2,
            p_strategic_obj_name          IN              VARCHAR2,
            p_strategic_obj_level         IN              VARCHAR2,
            p_strategic_obj_parent        IN              VARCHAR2,
            x_strategic_obj_id	          OUT NOCOPY      VARCHAR2,
	    x_return_status               OUT NOCOPY      VARCHAR2,
	    x_msg_count                   OUT NOCOPY      NUMBER,
	    x_msg_data                    OUT NOCOPY      VARCHAR2
);

-------------------------------------------------------------------------------
-- API update_strategicobj_status_aw , Overloaded API which does not take
-- FPA_Investment_Criteria_PVT.Investment_rec_type as a parameter
--
-- Params
--              p_commit                      IN              VARCHAR2
--              x_return_status               OUT NOCOPY      VARCHAR2
--              x_msg_count                   OUT NOCOPY      NUMBER
--              x_msg_data                    OUT NOCOPY      VARCHAR2
--              p_strategic_obj_shortname     IN              NUMBER
-- 	        p_strategic_obj_desc          IN              VARCHAR2
-- 		p_strategic_obj_name          IN              VARCHAR2
-- 		p_strategic_obj_level         IN              VARCHAR2
--              p_strategic_obj_parent        IN              VARCAHR2
--              p_strategic_obj_status        IN              VARCHAR2
-------------------------------------------------------------------------------
PROCEDURE update_strategicobj_status_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_strategic_obj_shortname     IN              NUMBER,
        p_strategic_obj_desc          IN              VARCHAR2,
        p_strategic_obj_name          IN              VARCHAR2,
        p_strategic_obj_level         IN              VARCHAR2,
        p_strategic_obj_parent        IN              VARCHAR2,
        p_strategic_obj_status        IN              VARCHAR2,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
);

-------------------------------------------------------------------------------
-- API update_strategicobj_level_aw , Overloaded API which does not take
-- FPA_Investment_Criteria_PVT.Investment_rec_type as a parameter
--
-- Params
--              p_commit                      IN              VARCHAR2
--              x_return_status               OUT NOCOPY      VARCHAR2
--              x_msg_count                   OUT NOCOPY      NUMBER
--              x_msg_data                    OUT NOCOPY      VARCHAR2
--              p_strategic_obj_shortname     IN              NUMBER
-- 		p_strategic_obj_desc          IN              VARCHAR2
-- 		p_strategic_obj_name          IN              VARCHAR2
-- 		p_strategic_obj_level         IN              VARCHAR2
--              p_strategic_obj_parent        IN              VARCHAR2
-------------------------------------------------------------------------------

PROCEDURE update_strategicobj_level_aw
(
        p_commit                      IN              VARCHAR2 := FND_API.G_FALSE,
        p_strategic_obj_shortname     IN              NUMBER,
        p_strategic_obj_desc          IN              VARCHAR2,
        p_strategic_obj_name          IN              VARCHAR2,
        p_strategic_obj_level         IN              VARCHAR2,
        p_strategic_obj_parent        IN              VARCHAR2,
        x_return_status               OUT NOCOPY      VARCHAR2,
        x_msg_count                   OUT NOCOPY      NUMBER,
        x_msg_data                    OUT NOCOPY      VARCHAR2
);

END fpa_investment_criteria_pvt;

/
