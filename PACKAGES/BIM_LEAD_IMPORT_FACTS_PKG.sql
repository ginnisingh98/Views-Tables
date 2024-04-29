--------------------------------------------------------
--  DDL for Package BIM_LEAD_IMPORT_FACTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_LEAD_IMPORT_FACTS_PKG" AUTHID CURRENT_USER AS
/* $Header: bimlisfs.pls 120.1 2005/06/14 15:25:02 appldev  $ */

PROCEDURE POPULATE
   (p_api_version_number  IN   NUMBER	 ,
    p_init_msg_list	      IN   VARCHAR2	:= FND_API.G_FALSE,
    p_validation_level    IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit              IN  VARCHAR2     := FND_API.G_FALSE,
    x_msg_count		      OUT  NOCOPY NUMBER	,
    x_msg_data		      OUT  NOCOPY VARCHAR2	,
    x_return_status	      OUT  NOCOPY VARCHAR2	,
    p_object		      IN   VARCHAR2	,
    p_start_date	      IN   DATE		,
    p_end_date		      IN   DATE,
    p_para_num            IN   number
    );

PROCEDURE LOG_HISTORY
   (p_object		      VARCHAR2,
	p_start_date        DATE,
	p_end_date          DATE
) ;

PROCEDURE LOAD_DATA
(p_start_datel          DATE,
p_end_datel             DATE,
p_api_version_number    IN   NUMBER,
x_msg_count             OUT  NOCOPY NUMBER       ,
x_msg_data              OUT  NOCOPY VARCHAR2     ,
x_return_status         OUT  NOCOPY VARCHAR2
);
END BIM_LEAD_IMPORT_FACTS_PKG;

 

/
