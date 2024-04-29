--------------------------------------------------------
--  DDL for Package BIM_SEGMENT_DENORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_SEGMENT_DENORM_PKG" AUTHID CURRENT_USER AS
/* $Header: bimisgds.pls 120.2 2005/09/27 07:19:05 sbassi noship $ */

PROCEDURE POPULATE
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER,
    p_api_version_number    IN  NUMBER
    ,p_proc_num             IN  NUMBER
	,p_load_type			IN	VARCHAR2
    );

PROCEDURE POPULATE_SEGMENT_DENORM
   (p_api_version_number     IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2
    ,p_validation_level      IN  NUMBER
    ,p_commit                IN  VARCHAR2
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_proc_num              IN  NUMBER
	,p_load_type			IN	VARCHAR2
    );

END bim_segment_denorm_pkg;

 

/
