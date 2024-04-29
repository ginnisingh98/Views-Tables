--------------------------------------------------------
--  DDL for Package BIM_I_SRC_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_I_SRC_CODE_PKG" AUTHID CURRENT_USER AS
/*$Header: bimiscds.pls 120.1 2005/10/11 05:38:38 sbassi noship $*/


PROCEDURE POPULATE
   (p_api_version_number     IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_commit                IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_para_num              IN  NUMBER
    ,p_truncate_flg	     IN  VARCHAR2
    );

PROCEDURE FIRST_LOAD
    (p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    );

PROCEDURE INCREMENTAL_LOAD
    (p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    );

END BIM_I_SRC_CODE_PKG;

 

/
