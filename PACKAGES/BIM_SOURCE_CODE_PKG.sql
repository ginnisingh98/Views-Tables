--------------------------------------------------------
--  DDL for Package BIM_SOURCE_CODE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_SOURCE_CODE_PKG" AUTHID CURRENT_USER AS
/* $Header: bimsrcds.pls 120.0 2005/06/01 12:51:00 appldev noship $*/

 PROCEDURE LOAD_DATA
    (p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    );
END BIM_SOURCE_CODE_PKG;

 

/
