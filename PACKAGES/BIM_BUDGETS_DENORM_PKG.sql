--------------------------------------------------------
--  DDL for Package BIM_BUDGETS_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_BUDGETS_DENORM_PKG" AUTHID CURRENT_USER AS
/*$Header: bimbgtds.pls 120.2 2005/10/17 01:48:04 arvikuma noship $*/

PROCEDURE POPULATE
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER,
    p_api_version_number    IN  NUMBER
    ,p_proc_num             IN  NUMBER
    ,p_load_type	    IN  VARCHAR2
    );

PROCEDURE POPULATE_DENORM
   (p_api_version_number     IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_commit                IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_proc_num              IN  NUMBER
    ,p_load_type	    IN  VARCHAR2
    );

END BIM_BUDGETS_DENORM_PKG;

 

/
