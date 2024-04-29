--------------------------------------------------------
--  DDL for Package BIM_I_SGMT_ACT_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_I_SGMT_ACT_FACTS_PKG" AUTHID CURRENT_USER AS
/*$Header: bimisafs.pls 120.1 2005/09/27 07:18:59 sbassi noship $*/


PROCEDURE POPULATE
   (p_api_version_number     IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,p_validation_level      IN  NUMBER
    ,p_commit                IN  VARCHAR2
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_para_num              IN  NUMBER
	,p_truncate_flg			 IN  VARCHAR2
    );

PROCEDURE FIRST_LOAD
    (p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    );

PROCEDURE INCREMENTAL_LOAD
    (p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    );

END BIM_I_SGMT_ACT_FACTS_PKG;

 

/
