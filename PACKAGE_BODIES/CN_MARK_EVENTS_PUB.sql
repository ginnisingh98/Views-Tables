--------------------------------------------------------
--  DDL for Package Body CN_MARK_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MARK_EVENTS_PUB" AS
/* $Header: cnpmkevb.pls 120.0 2006/08/25 00:19:15 ymao noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_MARK_EVENTS_PUB';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpmkevb.pls';

cursor check_period_id(p_period_id number, p_org_id number) is
  select 1 from cn_period_statuses_all
   where org_id = p_org_id
     and period_id = p_period_id;

cursor check_salesrep_id(p_salesrep_id number, p_period_id number, p_org_id number) is
  select 1 from cn_srp_intel_periods_all
   where salesrep_id = p_salesrep_id
     and period_id = p_period_id
	 and org_id = p_org_id;

cursor check_quota_id(p_quota_id number, p_org_id number) is
  select 1 from cn_quotas_all
   where org_id = p_org_id
     and quota_id = p_quota_id;

cursor check_date_in_period(p_period_id number, p_date date, p_org_id number) is
  select 1 from cn_period_statuses_all
   where period_id = p_period_id
     and org_id = p_org_id
	 and p_date between start_date and end_date;

-- Start of Comments
-- API name : Mark_Event_Calc
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create notification log records to re-compute commissions incrementally for the specified
--            salesrep within the given parameters
-- Desc 	: Procedure to create notification log records for the specified salesrep in the given time period
--            and optionally for the given plan element
-- Parameters	:
-- IN	   p_api_version       IN  NUMBER      Required
-- 		   p_init_msg_list     IN  VARCHAR2    Optional 	Default = FND_API.G_FALSE
-- 		   p_commit	           IN  VARCHAR2    Optional 	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN  NUMBER      Optional 	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT	   x_return_status     OUT VARCHAR2(1)
-- 		   x_msg_count	       OUT NUMBER
-- 		   x_msg_data	       OUT VARCHAR2(2000)
-- IN	   p_salesrep_id       IN  NUMBER
--         p_period_id         IN  NUMBER
--         p_start_date        IN  DATE        Optional     Default = NULL
--         p_end_date          IN  DATE        Optional     Default = NULL
--         p_quota_id          IN  NUMBER      Optional     Default = NULL
--         p_org_id            IN  NUMBER
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--   p_salesrep_id should be a valid salesrep identified in the operating unit specified by p_org_id.
--   p_period_id should specify the period for which calculation needs to be rerun
--   p_start_date should be within the period specified by p_period_id. It has a default value of null,
--     which is treated as the beginning of the specified period
--   p_end_date should be within the period specified by p_period_id. It has a default value of null,
--     which is treated as the end of the specified period
--   p_quota_id is the identifier of the plan element that needs to be recalculated. If it is null, all
--     plan elements of the specified salesrep will be calculated
--   p_org_id is the identifier of the operating unit
-- End of comments

PROCEDURE Mark_Event_Calc
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	            IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count	        OUT   NOCOPY NUMBER,
   x_msg_data	        OUT   NOCOPY VARCHAR2,
   p_salesrep_id 	    IN    NUMBER,
   p_period_id	        IN    NUMBER,
   p_start_date	        IN    DATE     := NULL,
   p_end_date	        IN    DATE     := NULL,
   p_quota_id	        IN    NUMBER   := NULL,
   p_org_id             IN    NUMBER)
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'Mark_Event_Calc';
   l_api_version  CONSTANT NUMBER  := 1.0;
   l_status       VARCHAR2(30);
   l_org_id       NUMBER;
   l_dummy        NUMBER := 0;
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_mark_events_pub.mark_event_calc.begin',
	      		    'Beginning of mark_event_calc for resource ('||p_salesrep_id||') ...');
   end if;

   -- Standard Start of API savepoint
   SAVEPOINT	mark_event_calc;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.compatible_api_call
     ( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;

   -- API body starts here
   l_org_id := p_org_id;
   mo_global.validate_orgid_pub_api(org_id => l_org_id,
                                    status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_mark_events_pub.mark_event_calc.org_validate',
	      		    'Validated org_id = ' || l_org_id || ' status = '||l_status);
   end if;

   IF (p_period_id IS NULL) THEN
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                      'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		      'p_period_id is null');
     end if;
     x_return_status := fnd_api.g_ret_sts_error;
   ELSE
     open check_period_id(p_period_id, l_org_id);
     fetch check_period_id into l_dummy;
     close check_period_id;

     if (l_dummy <> 1) then
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                        'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		        'p_period_id is not valid');
       end if;
       x_return_status := fnd_api.g_ret_sts_error;
     end if;
   END IF;

   IF (p_salesrep_id IS NULL) THEN
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                      'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		      'p_salesrep_id is null');
     end if;
	 x_return_status := fnd_api.g_ret_sts_error;
   ELSIF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
     l_dummy := 0;
     open check_salesrep_id(p_salesrep_id, p_period_id, l_org_id);
     fetch check_salesrep_id into l_dummy;
     close check_salesrep_id;

     if (l_dummy <> 1) then
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                        'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		        'p_salesrep_id does not have valid setup in the given operating unit');
       end if;
       x_return_status := fnd_api.g_ret_sts_error;
     end if;
   END IF;

   IF (p_quota_id IS NOT NULL) THEN
     l_dummy := 0;
     open check_quota_id(p_quota_id, p_org_id);
     fetch check_quota_id into l_dummy;
     close check_quota_id;

     if (l_dummy <> 1) then
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                        'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		        'p_quota_id is not valid in the given operating unit');
       end if;
       x_return_status := fnd_api.g_ret_sts_error;
     end if;
   END IF;

   if (p_start_date is not null) then
     l_dummy := 0;
     open check_date_in_period(p_period_id, p_start_date, p_org_id);
     fetch check_date_in_period into l_dummy;
     close check_date_in_period;

     if (l_dummy <> 1) then
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                        'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		        'p_start_date is not within the given period');
       end if;
       x_return_status := fnd_api.g_ret_sts_error;
     end if;
   end if;

   if (p_end_date is not null) then
     l_dummy := 0;
     open check_date_in_period(p_period_id, p_end_date, p_org_id);
     fetch check_date_in_period into l_dummy;
     close check_date_in_period;

     if (l_dummy <> 1) then
	   if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
         FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                        'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	       		        'p_end_date is not within the given period');
       end if;
       x_return_status := fnd_api.g_ret_sts_error;
     end if;
   end if;

   if (p_start_date is not null and p_end_date is not null and p_start_date > p_end_date) then
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.STRING(FND_LOG.LEVEL_ERROR,
                      'cn.plsql.cn_mark_events_pub.mark_event_calc.error',
	                  'p_start_date is greater than p_end_date');
     end if;
     x_return_status := fnd_api.g_ret_sts_error;
   end if;

   if (x_return_status <> FND_API.g_ret_sts_success) then
     raise FND_API.G_EXC_ERROR;
   end if;

   -- if passing all validations, call mark_notify
   cn_mark_events_pkg.mark_notify
	      (p_salesrep_id     => p_salesrep_id,
	       p_period_id       => p_period_id,
	       p_start_date      => p_start_date,
	       p_end_date        => p_end_date,
	       p_quota_id        => p_quota_id,
	       p_revert_to_state => 'CALC',
	       p_event_log_id    => null,
           p_org_id          => p_org_id);

   -- End of API body.

   -- Standard check of p_commit.
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;
   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_mark_events_pub.mark_event_calc.end',
	      		    'End of mark_event_calc.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO 	mark_event_calc;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO 	mark_event_calc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO 	mark_event_calc;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	THEN
	 FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

     if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_mark_events_pub.mark_event_calc.exception',
		       		     sqlerrm);
     end if;

END Mark_Event_Calc;


END cn_mark_events_pub ;

/
