--------------------------------------------------------
--  DDL for Package BIM_FUND_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_FUND_FACTS" AUTHID CURRENT_USER AS
/* $Header: bimbgtfs.pls 120.1 2005/06/14 15:13:40 appldev  $*/
PROCEDURE POPULATE
   (
    p_api_version_number      IN   NUMBER        ,
    p_init_msg_list           IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level        IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    p_commit                  IN   VARCHAR2     := FND_API.G_FALSE,
    x_msg_count               OUT  NOCOPY NUMBER       ,
    x_msg_data                OUT  NOCOPY VARCHAR2     ,
    x_return_status           OUT  NOCOPY VARCHAR2     ,
    p_object                  IN   VARCHAR2     ,
    p_start_date              IN   DATE         ,
    p_end_date                IN   DATE         ,
    p_para_num                IN   NUMBER
    );

--PROCEDURE update_balance(p_start_date DATE, p_end_date DATE);
PROCEDURE update_balance;

FUNCTION  convert_currency(
   p_from_currency          VARCHAR2 ,
   p_from_amount            NUMBER) return NUMBER;

/*
PROCEDURE LOG_HISTORY
   (p_object                VARCHAR2,
    p_start_date            DATE,
    p_end_date              DATE,
    x_msg_count             OUT  NOCOPY NUMBER       ,
    x_msg_data              OUT  NOCOPY VARCHAR2     ,
    x_return_status         OUT NOCOPY VARCHAR2
) ;
*/

PROCEDURE FUND_SUB_LOAD
(p_start_datel	   DATE,
 p_end_datel	   DATE,
 p_para_num                IN   NUMBER       ,
 x_msg_count		 OUT  NOCOPY NUMBER	   ,
 x_msg_data		 OUT  NOCOPY VARCHAR2	   ,
 x_return_status	 OUT NOCOPY VARCHAR2
);
PROCEDURE FUND_FIRST_LOAD
(p_start_datel	   DATE,
 p_end_datel	   DATE,
 p_para_num                IN   NUMBER       ,
 x_msg_count		 OUT  NOCOPY NUMBER	   ,
 x_msg_data		 OUT  NOCOPY VARCHAR2	   ,
 x_return_status	 OUT NOCOPY VARCHAR2
);

END BIM_FUND_FACTS;

 

/
