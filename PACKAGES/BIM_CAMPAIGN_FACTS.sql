--------------------------------------------------------
--  DDL for Package BIM_CAMPAIGN_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_CAMPAIGN_FACTS" AUTHID CURRENT_USER AS
/*$Header: bimcmpfs.pls 120.0 2005/05/31 13:15:48 appldev noship $*/

FUNCTION  convert_currency(
   p_from_currency          VARCHAR2
  ,p_from_amount            NUMBER) return NUMBER;

FUNCTION ret_max_date(
    p_sales_lead_id in number) return date ;

PROCEDURE POPULATE
   (p_api_version_number     IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level      IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL
    ,p_commit                IN  VARCHAR2     := FND_API.G_FALSE
    ,x_msg_Count             OUT NOCOPY NUMBER
    ,x_msg_Data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
    ,p_object                IN  VARCHAR2
    ,p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_para_num              IN   NUMBER
    );

PROCEDURE CAMPAIGN_DAILY_LOAD
    ( p_api_version_number    IN   NUMBER
     ,p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE
     ,x_msg_count             OUT  NOCOPY NUMBER
     ,x_msg_data              OUT  NOCOPY VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2
     ,p_date		      DATE          := SYSDATE
    );

procedure CAMPAIGN_FIRST_LOAD
    (p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_load_type             IN  VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
);

procedure CAMPAIGN_SUBSEQUENT_LOAD
    (p_start_date            IN  DATE
    ,p_end_date              IN  DATE
    ,p_api_version_number    IN  NUMBER
    ,p_init_msg_list         IN  VARCHAR2     := FND_API.G_FALSE
    ,p_load_type             IN  VARCHAR2
    ,x_msg_count             OUT NOCOPY NUMBER
    ,x_msg_data              OUT NOCOPY VARCHAR2
    ,x_return_status         OUT NOCOPY VARCHAR2
);


END BIM_CAMPAIGN_FACTS;

 

/
