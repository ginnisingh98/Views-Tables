--------------------------------------------------------
--  DDL for Package Body OZF_REFRESH_VIEW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_REFRESH_VIEW_PVT" AS
/*$Header: ozfvrfeb.pls 120.1 2005/07/08 03:37:56 appldev ship $*/

PROCEDURE load (ERRBUF                  OUT NOCOPY VARCHAR2,
                RETCODE                 OUT NOCOPY NUMBER,
		p_view_name             IN VARCHAR2)
IS
l_api_name       CONSTANT VARCHAR2(30) := 'load';
l_full_name      CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_api_version    CONSTANT NUMBER := 1.0;
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    x_msg_count               NUMBER;
    x_msg_data                VARCHAR2(240);
    x_return_status           VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;

l_view_name varchar2(30);
BEGIN
   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ': Start');

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_view_name = 'EARNING' THEN
      l_view_name := 'OZF_EARNING_SUMMARY_MV';
   ELSIF p_view_name = 'INVENTORY' THEN
      l_view_name := 'OZF_INVENTORY_SUMMARY_MV';
   ELSIF p_view_name = 'ORDER' THEN
      l_view_name := 'OZF_ORDER_SALES_SUMRY_MV';
    ELSIF p_view_name = 'CUSTFUND' THEN
      l_view_name := 'OZF_CUST_FUND_SUMMARY_MV';
   END IF;

   ozf_utility_pvt.write_conc_log(' -- Begin Materialized view refresh -- ');

   DBMS_MVIEW.REFRESH(
                list => l_view_name ,
                method => '?'
      );

   ozf_utility_pvt.write_conc_log(' -- End Mataerialized view refresh -- ');

   --------------------------------------------------------
   -- Gather statistics for the use of cost-based optimizer
   --------------------------------------------------------
   ozf_utility_pvt.write_conc_log(' -- Begin FND_STATS API to gather table statstics -- ');
   fnd_stats.gather_table_stats (ownname=>'APPS', tabname=>l_view_name);
   ozf_utility_pvt.write_conc_log(' -- End FND_STATS API to gather table statstics -- ');

   ozf_utility_pvt.write_conc_log('Private API: ' || l_full_name || ': End');
EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error ;
          FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                     p_count   => x_msg_count,
                                     p_data    => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Expected Error');

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);
          ERRBUF := x_msg_data;
          RETCODE := 2;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Error');

     WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error ;
          FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
                                     p_count => x_msg_count,
                                     p_data  => x_msg_data);

          ERRBUF  := sqlerrm(sqlcode);
          RETCODE := sqlcode;
          ozf_utility_pvt.write_conc_log('Private API: ' || l_api_name || ' Others');

END load;


END ozf_refresh_view_pvt;

/
