--------------------------------------------------------
--  DDL for Package OKL_CPY_PDT_RULS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_CPY_PDT_RULS_PUB" AUTHID CURRENT_USER AS
/* $Header: OKLPPCOS.pls 115.0 2002/04/10 07:39:31 pkm ship       $ */
--------------------------------------------------------------------------------
--Global Variables
--------------------------------------------------------------------------------
G_PKG_NAME     CONSTANT Varchar2(50) := 'OKL_CPY_PRD_RULS_PUB';
G_APP_NAME     CONSTANT Varchar2(3) :=   OKL_API.G_APP_NAME;
Procedure Copy_Product_Rules(p_api_version     IN  NUMBER,
	                         p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
	                         x_return_status   OUT NOCOPY VARCHAR2,
	                         x_msg_count       OUT NOCOPY NUMBER,
                             x_msg_data        OUT NOCOPY VARCHAR2,
                             p_khr_id          IN  NUMBER,
                             p_pov_id          IN  NUMBER);
End OKL_CPY_PDT_RULS_PUB;

 

/
