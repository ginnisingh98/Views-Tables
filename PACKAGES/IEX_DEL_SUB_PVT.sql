--------------------------------------------------------
--  DDL for Package IEX_DEL_SUB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_DEL_SUB_PVT" AUTHID CURRENT_USER AS
/* $Header: iexpdlss.pls 120.0 2004/01/24 03:19:29 appldev noship $ */

  G_PKG_NAME     CONSTANT VARCHAR2(30) := 'IEX_DEL_SUB_PVT';
  G_FILE_NAME    CONSTANT VARCHAR2(30) := 'iexpdlss.pls';


  PROCEDURE Add_rec   (p_api_version         IN  NUMBER	,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2	,
                       x_msg_count           OUT NOCOPY NUMBER	,
                       x_msg_data            OUT NOCOPY VARCHAR2	,
			     p_source_module	   IN	 VARCHAR2	,
			     p_id_tbl		   IN  IEX_UTILITIES.t_numbers,
                       p_del_id		   IN  Number	,
                       p_object_code	   IN  Varchar2	,
                       p_object_id	     	   IN  IEX_DEL_ASSETS.object_id%TYPE         	);

  PROCEDURE Add_All_rec(p_api_version        IN  NUMBER	,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2	,
                       x_msg_count           OUT NOCOPY NUMBER	,
                       x_msg_data            OUT NOCOPY VARCHAR2	,
			     p_source_module	   IN	 VARCHAR2	,
                       p_del_id		   IN  Number	,
                       p_object_code	   IN  Varchar2	,
                       p_object_id	     	   IN  Number	);

  PROCEDURE Remove_rec(p_api_version         IN  NUMBER,
                       p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		   IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status       OUT NOCOPY VARCHAR2,
                       x_msg_count           OUT NOCOPY NUMBER,
                       x_msg_data            OUT NOCOPY VARCHAR2,
			           p_source_module	   IN	 VARCHAR2,
                       p_id_tbl	   	   IN  IEX_UTILITIES.t_numbers) ;


   PROCEDURE Remove_All_rec(
			     p_api_version        IN  NUMBER	,
                       p_init_msg_list      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_commit		  IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
                       p_validation_level   IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
                       x_return_status      OUT NOCOPY VARCHAR2	,
                       x_msg_count          OUT NOCOPY NUMBER	,
                       x_msg_data           OUT NOCOPY VARCHAR2	,
			     p_source_module	  IN	VARCHAR2	,
                       p_del_id	   	  IN  Number 	) ;

   PROCEDURE Start_Workflow(
	  p_api_version         IN  NUMBER := 1.0,
        p_init_msg_list       IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_commit		      IN  VARCHAR2 DEFAULT FND_API.G_FALSE,
        p_validation_level    IN  NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL,
        x_return_status       OUT NOCOPY VARCHAR2	,
        x_msg_count           OUT NOCOPY NUMBER	,
        x_msg_data            OUT NOCOPY VARCHAR2	,
	  p_user_id			IN  NUMBER		,
	  p_asset_info	      IN  VARCHAR2	,
        p_asset_addl_info	IN  Varchar2 	,
        p_delinquency_id      IN  Number    ) ;

  End IEX_DEL_SUB_PVT ;

 

/
