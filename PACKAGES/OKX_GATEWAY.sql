--------------------------------------------------------
--  DDL for Package OKX_GATEWAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKX_GATEWAY" AUTHID CURRENT_USER as
/* $Header: OKXSWRPS.pls 120.1 2005/10/03 15:06:01 jvarghes noship $ */

  PROCEDURE OKX_TIMEZONE_GETTIME (
    p_api_version                  	IN 	NUMBER,
    p_init_msg_list                	IN 	VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_source_tz_id			IN 	NUMBER,
    p_dest_ts_id				IN	NUMBER,
    p_source_day_time			IN	DATE,
    x_dest_day_time			OUT	NOCOPY DATE,
    x_return_status                	OUT 	NOCOPY VARCHAR2,
    x_msg_count                    	OUT 	NOCOPY NUMBER,
    x_msg_data                     	OUT 	NOCOPY VARCHAR2);


END okx_gateway;

 

/
