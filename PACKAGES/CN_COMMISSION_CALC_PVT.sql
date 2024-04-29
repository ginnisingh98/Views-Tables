--------------------------------------------------------
--  DDL for Package CN_COMMISSION_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMMISSION_CALC_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvprcms.pls 120.0 2005/09/08 00:28:30 rarajara noship $

Procedure calculate_Commission
(
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_inc_plnr_disclaimer   OUT NOCOPY  cn_repositories.income_planner_disclaimer%TYPE,	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2
);

Procedure calculate_Commission
(
  p_api_version         IN NUMBER,
  p_init_msg_list       IN VARCHAR2 := FND_API.G_FALSE,
  p_org_id            IN NUMBER,
  x_inc_plnr_disclaimer OUT NOCOPY cn_repositories.income_planner_disclaimer%TYPE,
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2
);

END CN_COMMISSION_CALC_PVT;

 

/
