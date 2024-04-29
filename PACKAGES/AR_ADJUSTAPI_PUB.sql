--------------------------------------------------------
--  DDL for Package AR_ADJUSTAPI_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AR_ADJUSTAPI_PUB" AUTHID CURRENT_USER AS
/* $Header: ARTAADJS.pls 115.1 2003/10/13 16:13:52 mraymond noship $ */
G_START_TIME	number;


PROCEDURE Create_Adjustment (
     p_api_name			IN	varchar2,
     p_api_version		IN	number,
     p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
     p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
     p_validation_level     	IN	number   := FND_API.G_VALID_LEVEL_FULL,
     p_msg_count		OUT NOCOPY 	number,
     p_msg_data			OUT NOCOPY varchar2,
     p_return_status		OUT NOCOPY varchar2,
     p_adj_rec			IN 	ar_adjustments%rowtype,
     p_new_adjust_number	OUT NOCOPY ar_adjustments.adjustment_number%type,
     p_new_adjust_id		OUT NOCOPY ar_adjustments.adjustment_id%type
           );

PROCEDURE Modify_Adjustment(
          p_api_name		IN	varchar2,
	  p_api_version		IN	number,
	  p_init_msg_list	IN	varchar2 := FND_API.G_FALSE,
	  p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
	  p_validation_level    IN	number   := FND_API.G_VALID_LEVEL_FULL,
          p_msg_count		OUT NOCOPY number,
	  p_msg_data		OUT NOCOPY varchar2,
	  p_return_status	OUT NOCOPY varchar2 ,
	  p_adj_rec		IN 	ar_adjustments%rowtype,
	  p_old_adjust_id	IN	ar_adjustments.adjustment_id%type
	   );

PROCEDURE Reverse_Adjustment(
        p_api_name		IN	varchar2,
        p_api_version		IN	number,
        p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
	p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
	p_validation_level     	IN	number   := FND_API.G_VALID_LEVEL_FULL,
	p_msg_count		OUT NOCOPY number,
	p_msg_data		OUT NOCOPY varchar2,
	p_return_status		OUT NOCOPY varchar2,
	p_old_adjust_id		IN	ar_adjustments.adjustment_id%type,
        p_reversal_gl_date	IN	date,
        p_reversal_date		IN	date
	   );

PROCEDURE Approve_Adjustment (
p_api_name		IN	varchar2,
p_api_version		IN	number,
p_init_msg_list		IN	varchar2 := FND_API.G_FALSE,
p_commit_flag		IN	varchar2 := FND_API.G_FALSE,
p_validation_level     	IN	number   := FND_API.G_VALID_LEVEL_FULL,
p_msg_count		OUT NOCOPY number,
p_msg_data		OUT NOCOPY varchar2,
p_return_status		OUT NOCOPY varchar2,
p_adj_rec		IN 	ar_adjustments%rowtype,
p_old_adjust_id		IN	ar_adjustments.adjustment_id%type
     	  );


END ar_adjustapi_pub;

 

/
