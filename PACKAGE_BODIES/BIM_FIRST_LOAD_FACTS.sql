--------------------------------------------------------
--  DDL for Package Body BIM_FIRST_LOAD_FACTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_FIRST_LOAD_FACTS" AS
/* $Header: bimfdfab.pls 115.19 2003/10/22 08:32:25 kpadiyar ship $*/

--g_pkg_name  CONSTANT  VARCHAR2(20) :='BIM_LOAD_FACTS';
--G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimldfab.pls';

PROCEDURE invoke_object
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE		    OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
   --  p_mode                  IN   VARCHAR2  DEFAULT NULL,
    p_start_dt              IN   VARCHAR2  DEFAULT NULL,
    p_end_dt                IN   VARCHAR2  DEFAULT NULL,
    p_proc_num              IN   NUMBER    DEFAULT 8
    ) IS
cursor max_log_date IS
select TRUNC(max(object_last_updated_date))
from bim_rep_history
where object='DATES';
    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'invoke_object';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(1) ;
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;
    l_max_date                DATE;
    p_start_date              DATE := FND_DATE.CANONICAL_TO_DATE(p_start_dt);
    p_end_date                DATE := FND_DATE.CANONICAL_TO_DATE(p_end_dt);

BEGIN


     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      OPEN max_log_date;
      FETCH max_log_date into l_max_date;
      CLOSE max_log_date;
      IF (l_max_date is null) or (l_max_date < TRUNC(sysdate)) THEN
      BIM_POPDATES_PKG.pop_intl_dates(p_start_date);
      END IF;

 		BIM_SOURCE_CODE_PKG.LOAD_DATA(p_api_version_number=>1
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status);


	 IF p_object = 'CAMPAIGN' THEN

		  bim_campaign_facts.populate
                                     (p_api_version_number => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
                                     ,p_object        => p_object
                                     ,p_start_date    => p_start_date
                                     ,p_end_date      => p_end_date
                                     ,p_para_num      => p_proc_num
                                     );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;


	   ELSIF
 	   	   p_object = 'EVENT' THEN


		   bim_event_facts.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => p_object,
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
				                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

           ELSIF
                   p_object = 'RESPONSE' THEN


                   bim_response_facts_pkg.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

           ELSIF
                   p_object = 'LEADS' THEN


                   bim_lead_facts_pkg.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => p_object,
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

         ELSIF
           p_object = 'LEAD_IMPORT' THEN

		   bim_lead_import_facts_pkg.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'LEAD_IMPORT',
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
				                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

         ELSIF
   		 p_object = 'BUDGET'THEN

	         bim_fund_facts.populate (
                          	      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count      ,
                                      x_msg_data           => x_msg_data    ,
                                      x_return_status      => x_return_status    ,
                                      P_OBJECT             => 'FUND',
                                      P_START_DATE         => p_start_date,
                                      P_END_DATE           => p_end_date,
				                      p_para_num           => p_proc_num
			              );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;


	   ELSIF
		  p_object = 'ALL' THEN

		  bim_campaign_facts.populate
                                     (p_api_version_number => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
                                     ,p_object        => 'CAMPAIGN'
                                     ,p_start_date    => p_start_date
                                     ,p_end_date      => p_end_date
                                     ,p_para_num      => p_proc_num
                                     );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

  		  bim_event_facts.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'EVENT',
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
			                          p_para_num           => p_proc_num
				      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                 bim_lead_import_facts_pkg.POPULATE (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => 'LEAD_IMPORT',
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
				                      p_para_num           => p_proc_num
                                      );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
                   bim_response_facts_pkg.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

                   bim_lead_facts_pkg.populate (
                                      p_api_version_number => 1.0,
                                      p_init_msg_list      => FND_API.G_FALSE,
                                      x_msg_count          => x_msg_count         ,
                                      x_msg_data           => x_msg_data        ,
                                      x_return_status      => x_return_status   ,
                                      p_object             => p_object,
                                      p_start_date         => p_start_date,
                                      p_end_date           => p_end_date,
                                      p_para_num           => p_proc_num
                                      );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;


	          bim_fund_facts.populate (
                          	          p_api_version_number  => 1.0,
                                      p_init_msg_list       => FND_API.G_FALSE,
                                      x_msg_count           => x_msg_count      ,
                                      x_msg_data            => x_msg_data    ,
                                      x_return_status       => x_return_status    ,
                                      p_object              => 'FUND',
                                      p_start_date          => p_start_date,
                                      p_end_date            => p_end_date,
				      p_para_num            => p_proc_num
                                     -- p_smode              => p_mode
				      );

                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

	      END IF;

	  	  AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'End');

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status := FND_API.g_ret_sts_error ;
	 FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
            				   p_count => x_msg_count,
                               p_data  => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;

   WHEN OTHERS THEN
        	x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
             				    p_count => x_msg_count,
                                p_data  => x_msg_data);
     ERRBUF  := sqlerrm(sqlcode);
     RETCODE := sqlcode;

END invoke_object;


PROCEDURE recover_object
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE		    OUT  NOCOPY NUMBER,
    p_api_version_number    IN   NUMBER	,
    p_object                IN   VARCHAR2  DEFAULT NULL,
    p_date                  IN   DATE    DEFAULT SYSDATE
    ) IS

    v_error_code              NUMBER;
    v_error_text              VARCHAR2(1500);
    l_start_date              DATE;
    l_end_date                DATE;
    l_user_id                 NUMBER := FND_GLOBAL.USER_ID();
    l_api_version_number      CONSTANT NUMBER       := 1.0;
    l_api_name                CONSTANT VARCHAR2(30) := 'invoke_object';
    x_msg_count	              NUMBER;
    x_msg_data		      VARCHAR2(240);
    x_return_status	      VARCHAR2(10);
    l_init_msg_list           VARCHAR2(10)  := FND_API.G_FALSE;

BEGIN

     -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           g_pkg_name)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

	 IF p_object = 'CAMPAIGN' THEN
		       	bim_campaign_facts.campaign_daily_load
                                     (p_api_version_number => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
				     ,p_date => p_date
				     );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

	ELSIF
   	   p_object = 'EVENT' 	THEN
		  	 bim_event_facts.event_subsequent_load
				                     (p_start_datel    => null
                                     ,p_end_datel     => p_date
                                     ,p_api_version_number => 1.0
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
				    );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

	/*ELSIF
	   p_object = 'BUDGET'	THEN
		        bim_fund_facts.fund_daily_load
				                     (p_date      => p_date
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
			             );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF; */

	ELSIF
	   p_object = 'ALL'	THEN

		       	bim_campaign_facts.campaign_daily_load
                                     (p_api_version_number => 1.0
                                     ,p_init_msg_list => FND_API.G_FALSE
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
				     ,p_date	=> p_date
				     );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

		  	bim_event_facts.event_subsequent_load
				                    (p_start_datel     => null
                                     ,p_end_datel     => p_date
                                     ,p_api_version_number => 1.0
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
				    );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;

/*		        bim_fund_facts.fund_daily_load
				                     (p_date      => p_date
                                     ,x_msg_count     => x_msg_count
                                     ,x_msg_data      => x_msg_data
                                     ,x_return_status => x_return_status
			             );
                  IF    x_return_status = FND_API.g_ret_sts_error
                  THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF; */

         END IF;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status := FND_API.g_ret_sts_error ;
	 FND_MSG_PUB.count_and_get (p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    	x_return_status := FND_API.g_ret_sts_unexp_error ;
    FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
            				   p_count => x_msg_count,
                               p_data  => x_msg_data);
     ERRBUF := x_msg_data;
     RETCODE := 2;

   WHEN OTHERS THEN
        	x_return_status := FND_API.g_ret_sts_unexp_error ;
     FND_MSG_PUB.Count_And_Get (p_encoded => FND_API.G_FALSE,
             				    p_count => x_msg_count,
                                p_data  => x_msg_data);

     ERRBUF  := sqlerrm(sqlcode);
     RETCODE := sqlcode;

END recover_object;


END bim_first_load_facts;

/
