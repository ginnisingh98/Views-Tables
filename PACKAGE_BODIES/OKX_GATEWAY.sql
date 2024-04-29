--------------------------------------------------------
--  DDL for Package Body OKX_GATEWAY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKX_GATEWAY" AS
/* $Header: OKXSWRPB.pls 120.1 2005/10/03 15:06:43 jvarghes noship $ */

  PROCEDURE OKX_TIMEZONE_GETTIME (
    p_api_version          IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2 DEFAULT OKC_API.G_FALSE,
    p_source_tz_id         IN   NUMBER,
    p_dest_ts_id           IN   NUMBER,
    p_source_day_time      IN   DATE,
    x_dest_day_time        OUT  NOCOPY DATE,
    x_return_status        OUT  NOCOPY VARCHAR2,
    x_msg_count            OUT  NOCOPY NUMBER,
    x_msg_data             OUT  NOCOPY VARCHAR2) is
/*
REM Get destination day time, given the source day time,
REM source timezone_id and destination timezone_id

  l_api_name               CONSTANT VARCHAR2(30):= 'OKX_TIMEZONE_GETTIME';
  l_api_version            CONSTANT NUMBER      := 1.0;
  l_row_count              NUMBER;
  l_return_status          VARCHAR2(1)          := OKC_API.G_RET_STS_SUCCESS;
*/
  BEGIN

  HZ_TIMEZONE_PUB.GET_TIME (
   p_api_version,
   p_init_msg_list,
   p_source_tz_id,
   p_dest_ts_id,
   p_source_day_time,
   x_dest_day_time,
   x_return_status,
   x_msg_count,
   x_msg_data );

  /* EXCEPTION
     when others then
         x_return_status := OKC_API.HANDLE_EXCEPTIONS(
                              l_api_name
                             ,G_PKG_NAME
                             ,'OTHERS'
                             ,x_msg_count
                             ,x_msg_data
                             ,'_PVT'
         );
*/
  END OKX_TIMEZONE_GETTIME;

END okx_gateway;

/
