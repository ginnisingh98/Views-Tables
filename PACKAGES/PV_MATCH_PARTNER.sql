--------------------------------------------------------
--  DDL for Package PV_MATCH_PARTNER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_MATCH_PARTNER" AUTHID CURRENT_USER as
/* $Header: pvxpmats.pls 115.19 2002/01/27 21:04:19 pkm ship    $*/

	G_PKG_NAME      CONSTANT VARCHAR2(30):='PV_MATCH_PARTNER';

	procedure Form_Where_Clause(
			p_api_version_number   IN      NUMBER,
			p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
			p_commit               IN      VARCHAR2 := FND_API.G_FALSE,
			p_validation_level     IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
			p_attr_tbl             IN OUT  JTF_VARCHAR2_TABLE_100,
			p_attr_val_count       IN      JTF_VARCHAR2_TABLE_100,
			p_val_attr_tbl         IN OUT  JTF_VARCHAR2_TABLE_100,
			p_cm_id                IN      number,
			p_lead_id              IN      number,
			p_auto_match_flag      IN      varchar2,
			x_iterations           OUT     varchar2,
			x_matched_id_tbl       OUT     JTF_VARCHAR2_TABLE_100,
			x_return_status        OUT     VARCHAR2,
			x_msg_count            OUT     NUMBER,
			x_msg_data             OUT     VARCHAR2);

 Procedure Auto_Match_Criteria (
			p_api_version_number   IN NUMBER,
			p_init_msg_list        IN VARCHAR2 := FND_API.G_FALSE,
			p_commit               IN VARCHAR2 := FND_API.G_FALSE,
			p_validation_level     IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
			p_lead_id              IN  Number,
			x_matched_attr         OUT JTF_VARCHAR2_TABLE_100,
			x_matched_attr_val     OUT JTF_VARCHAR2_TABLE_100,
			x_original_attr        OUT  JTF_VARCHAR2_TABLE_100,
			x_original_attr_val    OUT  JTF_VARCHAR2_TABLE_100,
			x_iterations           OUT varchar2,
			x_matched_id           OUT JTF_VARCHAR2_TABLE_100,
			x_return_status        OUT VARCHAR2,
			x_msg_count            OUT NUMBER,
			x_msg_data             OUT VARCHAR2);

end PV_MATCH_PARTNER;

 

/
