--------------------------------------------------------
--  DDL for Package BIM_PROGRAMS_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_PROGRAMS_DENORM_PKG" AUTHID CURRENT_USER AS
/*$Header: bimprgds.pls 120.1 2005/10/11 05:38:14 sbassi noship $*/

PROCEDURE POPULATE
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER,
    p_api_version_number    IN  NUMBER,
    p_proc_num              IN  NUMBER,
    p_load_type		    IN  VARCHAR2
    );

PROCEDURE POPULATE_SOURCE_DENORM
   (p_api_version_number     IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,p_validation_level      IN  NUMBER
    ,p_commit                IN  VARCHAR2
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_proc_num              IN  NUMBER
    ,p_load_type	     IN  VARCHAR2
    );

PROCEDURE LOAD_ADMIN_RECORDS(
    p_api_version_number                 IN    NUMBER       := 1.0
    ,p_init_msg_list                      IN    VARCHAR2
    ,p_commit                             IN    VARCHAR2
    ,p_validation_level                   IN    NUMBER
    ,x_return_status                      OUT   NOCOPY VARCHAR2
    ,x_msg_count                          OUT   NOCOPY NUMBER
    ,x_msg_data                           OUT   NOCOPY VARCHAR2
    );

PROCEDURE LOAD_TOP_LEVEL_OBJECTS(
    p_api_version_number                 IN    NUMBER       := 1.0
    ,p_init_msg_list                      IN    VARCHAR2
    ,p_commit                             IN    VARCHAR2
    ,p_validation_level                   IN    NUMBER
    ,x_return_status                      OUT   NOCOPY VARCHAR2
    ,x_msg_count                          OUT   NOCOPY NUMBER
    ,x_msg_data                           OUT   NOCOPY VARCHAR2
    );

END bim_programs_denorm_pkg;

 

/
