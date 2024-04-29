--------------------------------------------------------
--  DDL for Package Body CN_CALC_SUBMISSION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CALC_SUBMISSION_PUB" AS
/* $Header: cnpcsbb.pls 120.4 2005/10/27 14:09:06 ymao noship $ */

G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_CALC_SUBMISSION_PUB';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnpcsbb.pls';

G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := FND_GLOBAL.USER_ID;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := FND_GLOBAL.USER_ID;
G_LAST_UPDATE_LOGIN         NUMBER  := FND_GLOBAL.LOGIN_ID;

g_org_id NUMBER;

g_calc_sub_name CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('NAME', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_start_date CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('START_DATE', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_end_date CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('END_DATE', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_calc_type CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('CALC_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_salesrep_option CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('SALESREP_OPTION', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_hierarchy_flag CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('HIERARCHY_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_concurrent_flag CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('CONCURRENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_intelligent_flag CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('INTELLIGENT_FLAG', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_interval_type CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('INTERVAL_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_emp_num CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('EMPLOYEE_NUMBER', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_emp_type CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('EMPLOYEE_TYPE', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_user_name CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('USER_NAME', 'CALC_SUBMISSION_OBJECT_TYPE');
g_calc_sub_resp_name CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('RESPONSIBILITY_NAME', 'CALC_SUBMISSION_OBJECT_TYPE');

TYPE salesrep_id_tbl_type IS TABLE OF cn_salesreps.salesrep_id%TYPE
  INDEX BY BINARY_INTEGER;

TYPE plan_element_id_tbl_type IS TABLE OF cn_quotas.quota_id%TYPE
  INDEX BY BINARY_INTEGER;

-- ----------------------------------------------------------------------------+
-- Procedure: validate_calc_sub_batch
-- Desc     : check if the record is valid to insert into cn_calc_submission_batches
-- ----------------------------------------------------------------------------+
PROCEDURE validate_calc_sub_batch
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_calc_submission_rec    IN  calc_submission_rec_type,
   p_loading_status         IN  VARCHAR2,
   p_name_validate_flag     IN  VARCHAR2 := 'Y',
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'validate_calc_sub_batch';
      l_loading_status  VARCHAR2(100);

      cursor  l_ctr_csr (l_start_date date) is
	 select 1
	     from cn_period_statuses_all
	     where period_status = 'O'
	     and org_id = g_org_id
	     and (period_set_id, period_type_id) = (select period_set_id, period_type_id
	                                              from cn_repositories_all
	                                             where org_id = g_org_id)
	     and l_start_date between start_date and end_date;

      l_counter number := 0;

      CURSOR l_batch_name_csr IS
	 SELECT COUNT(*)
	   FROM cn_calc_submission_batches_all
	   WHERE name = p_calc_submission_rec.batch_name
	     AND org_id = g_org_id;
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.begin',
	      		    'Beginning of validate_calc_sub_batch ...');
   end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body

   -- batch_name can not be missing or null
   --  and should uniquely identify the batch
   IF p_name_validate_flag = 'Y' THEN
      IF (cn_api.chk_miss_null_char_para
	  (p_char_para => p_calc_submission_rec.batch_name,
	   p_obj_name => g_calc_sub_name,
	   p_loading_status => x_loading_status,
	   x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;

      OPEN l_batch_name_csr;
      FETCH l_batch_name_csr INTO l_counter;
      CLOSE l_batch_name_csr;

      IF l_counter <> 0 THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_EXISTS');
	    fnd_message.set_token('BATCH_NAME', p_calc_submission_rec.batch_name);
	    if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
        end if;

	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_EXISTS');
	      fnd_message.set_token('BATCH_NAME', p_calc_submission_rec.batch_name);
	      FND_MSG_PUB.Add;
	    END IF;

	    x_loading_status := 'CN_CALC_SUB_EXISTS';
	    RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF; -- end of p_name_validate_flag

   -- start_date can not be null/missing
   -- end_date can not be null/missing
   -- start_date < end_date
   IF ( (cn_api.invalid_date_range
	 (p_start_date => p_calc_submission_rec.start_date,
	  p_end_date => p_calc_submission_rec.end_date,
	  p_end_date_nullable => FND_API.G_TRUE,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- start_date / end_date must be within open period
   open l_ctr_csr( p_calc_submission_rec.start_date);
   fetch l_ctr_csr into l_counter;
   close l_ctr_csr;

   IF l_counter <> 1 then
   	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_OPEN_DATE');
	 FND_MESSAGE.SET_TOKEN('DATE', p_calc_submission_rec.start_date);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_OPEN_DATE');
	   FND_MESSAGE.SET_TOKEN('DATE', p_calc_submission_rec.start_date);
	   FND_MSG_PUB.Add;
     END IF;

     x_loading_status := 'CN_CALC_SUB_OPEN_DATE';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   open l_ctr_csr( p_calc_submission_rec.end_date);
   fetch l_ctr_csr into l_counter;
   close l_ctr_csr;

   IF l_counter <> 1 then
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_OPEN_DATE');
	 FND_MESSAGE.SET_TOKEN('DATE', p_calc_submission_rec.end_date );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_OPEN_DATE');
	   FND_MESSAGE.SET_TOKEN('DATE', p_calc_submission_rec.end_date );
	   FND_MSG_PUB.Add;
     END IF;

     x_loading_status := 'CN_CALC_SUB_OPEN_DATE';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- calculation_type can not be null/missing, must be valid value
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_calc_submission_rec.calculation_type,
	  p_obj_name  => g_calc_sub_calc_type,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF ( p_calc_submission_rec.calculation_type NOT IN ('COMMISSION', 'BONUS')) THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	 FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_calc_type);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	   FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_calc_type);
	   FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_INVALID_DATA';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- salesrep_option can not be null/missing, must be valid value
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_calc_submission_rec.salesrep_option,
	  p_obj_name  => g_calc_sub_salesrep_option,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_calc_submission_rec.salesrep_option NOT IN ('ALL_REPS', 'USER_SPECIFY', 'REPS_IN_NOTIFY_LOG')
      OR ( p_calc_submission_rec.calculation_type = 'BONUS'
	  AND p_calc_submission_rec.salesrep_option = 'REPS_IN_NOTIFY_LOG' )
   THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	 FND_MESSAGE.SET_TOKEN('OBJ_NAME',g_calc_sub_salesrep_option );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	   FND_MESSAGE.SET_TOKEN('OBJ_NAME',g_calc_sub_salesrep_option );
	   FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_INVALID_DATA';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- entire_hierarchy can not be null/missing, must be valid value
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_calc_submission_rec.entire_hierarchy,
	  p_obj_name  => g_calc_sub_hierarchy_flag,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_calc_submission_rec.entire_hierarchy NOT IN ('Y', 'N')
     OR ( p_calc_submission_rec.salesrep_option IN ('ALL_REPS', 'REPS_IN_NOTIFY_LOG')
	  AND p_calc_submission_rec.entire_hierarchy = 'Y'  )
   THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	 FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_hierarchy_flag );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	   FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_hierarchy_flag );
	   FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_INVALID_DATA';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

    -- concurrent_calculation can not be null/missing, must be valid value
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_calc_submission_rec.concurrent_calculation,
	  p_obj_name  => g_calc_sub_concurrent_flag,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_calc_submission_rec.concurrent_calculation NOT IN ('Y', 'N') THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	 FND_MESSAGE.SET_TOKEN('OBJ_NAME',g_calc_sub_concurrent_flag );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	   FND_MESSAGE.SET_TOKEN('OBJ_NAME',g_calc_sub_concurrent_flag );
	   FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_INVALID_DATA';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- incremental_calculation can not be null/missing , must be valid value
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_calc_submission_rec.incremental_calculation,
	  p_obj_name  => g_calc_sub_intelligent_flag,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   IF p_calc_submission_rec.incremental_calculation NOT IN ('Y', 'N')
     OR ( p_calc_submission_rec.calculation_type = 'BONUS'
	  AND p_calc_submission_rec.incremental_calculation = 'Y' )
     OR ( p_calc_submission_rec.salesrep_option = 'REPS_IN_NOTIFY_LOG'
	  AND p_calc_submission_rec.incremental_calculation = 'N' )
   THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	 FND_MESSAGE.SET_TOKEN('OBJ_NAME',g_calc_sub_intelligent_flag );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	   FND_MESSAGE.SET_TOKEN('OBJ_NAME',g_calc_sub_intelligent_flag );
	   FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_INVALID_DATA';
     RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- interval_type can not be null/missing, must be valid value if calc_type = 'BONUS'
   IF p_calc_submission_rec.calculation_type = 'BONUS' THEN
      IF ( (cn_api.chk_miss_null_char_para
	    (p_char_para => p_calc_submission_rec.interval_type,
	     p_obj_name  => g_calc_sub_interval_type,
	     p_loading_status => x_loading_status,
	     x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
	    RAISE FND_API.G_EXC_ERROR ;
      END IF;

      IF p_calc_submission_rec.interval_type NOT IN ('ALL', 'PERIOD', 'QUARTER', 'YEAR' ) THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	    FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_interval_type );
        if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.error',
	       		       TRUE);
        end if;

	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	      FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_interval_type );
	      FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_INVALID_DATA';
	    RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;

   -- End of API body.

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
       p_encoded => FND_API.G_FALSE
       );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.end',
	      		    'End of validate_calc_sub_batch.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
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
                         'cn.plsql.cn_calc_submission_pub.validate_calc_sub_batch.exception',
		       		     sqlerrm);
      end if;

END validate_calc_sub_batch;

FUNCTION  validate_salesrep ( p_salesrep_rec   salesrep_rec_type,
			      x_salesrep_id    OUT NOCOPY cn_salesreps.salesrep_id%TYPE,
			      x_loading_status OUT NOCOPY VARCHAR2 ) RETURN BOOLEAN IS

     CURSOR l_has_had_comp_plan_csr ( l_salesrep_id cn_salesreps.salesrep_id%TYPE) IS
	SELECT 1
	    FROM cn_srp_intel_periods_all
	    WHERE salesrep_id = l_salesrep_id
		AND org_id = g_org_id;

     l_salesrep_id  NUMBER;
     l_counter      NUMBER;
     l_return_status  VARCHAR2(30);

BEGIN

   -- emp_num can not be missing
   IF (cn_api.chk_miss_char_para
       (p_char_para => p_salesrep_rec.employee_number,
	p_para_name => g_calc_sub_emp_num,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RETURN FALSE;
   END IF;

   -- type can not be missing
   IF (cn_api.chk_miss_char_para
       (p_char_para => p_salesrep_rec.TYPE,
	p_para_name => g_calc_sub_emp_type,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RETURN FALSE;
   END IF;

   if (nvl(p_salesrep_rec.hierarchy_flag, 'N') not in ('N', 'Y')) then
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	 FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_hierarchy_flag );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_salesrep.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_INVALID_DATA');
	   FND_MESSAGE.SET_TOKEN('OBJ_NAME', g_calc_sub_hierarchy_flag );
	   FND_MSG_PUB.Add;
     END IF;
     return false;
   end if;

   -- (employee_number + type) must uniquely identify one salesrep
   -- in cn_salesreps
   cn_api.chk_and_get_salesrep_id( p_emp_num        => p_salesrep_rec.employee_number,
				   p_type           => p_salesrep_rec.TYPE,
				   p_org_id         => g_org_id,
				   x_salesrep_id    => l_salesrep_id,
				   x_return_status  => l_return_status,
				   x_loading_status => x_loading_status,
				   p_show_message   => FND_API.G_TRUE);
   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
      RETURN FALSE;
   END IF;

   OPEN l_has_had_comp_plan_csr( l_salesrep_id );
   FETCH l_has_had_comp_plan_csr INTO l_counter;

   IF l_has_had_comp_plan_csr%notfound THEN
     CLOSE l_has_had_comp_plan_csr;

	 FND_MESSAGE.SET_NAME ('CN', 'CN_CALC_PLAN_NOT_ASSIGNED');
	 FND_MESSAGE.SET_TOKEN('EMPLOYEE_NUMBER', p_salesrep_rec.employee_number );
	 FND_MESSAGE.SET_TOKEN('EMPLOYEE_TYPE', p_salesrep_rec.TYPE );
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_salesrep.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.SET_NAME ('CN', 'CN_CALC_PLAN_NOT_ASSIGNED');
	   FND_MESSAGE.SET_TOKEN('EMPLOYEE_NUMBER', p_salesrep_rec.employee_number );
	   FND_MESSAGE.SET_TOKEN('EMPLOYEE_TYPE', p_salesrep_rec.TYPE );
	   FND_MSG_PUB.Add;
     END IF;

     x_loading_status := 'CN_CALC_PLAN_NOT_ASSIGNED';
     RETURN FALSE;
   END IF;
   CLOSE l_has_had_comp_plan_csr;

   x_salesrep_id := l_salesrep_id;
   RETURN TRUE;
END validate_salesrep;

FUNCTION  validate_bonus_pe ( p_quota_name     IN   cn_quotas.name%TYPE ,
			      p_interval_type  IN   VARCHAR2,
			      x_quota_id       OUT NOCOPY  cn_quotas.quota_id%TYPE,
			      x_loading_status OUT NOCOPY  VARCHAR2 )  RETURN BOOLEAN IS

     CURSOR l_bonus_pe_csr IS
	SELECT quota_id
	  FROM cn_quotas_all
	  WHERE name = p_quota_name
	  AND org_id = g_org_id
	  AND incentive_type_code = 'BONUS'
	  AND ( (interval_type_id = -1000 AND p_interval_type = 'PERIOD')
		OR (interval_type_id = -1001 AND p_interval_type = 'QUARTER')
		OR (interval_type_id = -1002 AND p_interval_type = 'YEAR')
		OR (interval_type_id IN (-1000, -1001, -1002) AND p_interval_type = 'ALL')
		);
BEGIN
   OPEN l_bonus_pe_csr;
   FETCH l_bonus_pe_csr INTO x_quota_id;

   IF l_bonus_pe_csr%notfound THEN
      CLOSE l_bonus_pe_csr;

	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_PE_NO_MATCH');
	 FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_quota_name);
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_bonus_pe.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_PE_NO_MATCH');
	   FND_MESSAGE.SET_TOKEN('QUOTA_NAME',p_quota_name);
	   FND_MSG_PUB.Add;
     END IF;

     x_loading_status := 'CN_CALC_PE_NO_MATCH';
     RETURN FALSE;
   ELSE
      CLOSE l_bonus_pe_csr;
      RETURN TRUE;
   END IF;

END validate_bonus_pe;


-- ----------------------------------------------------------------------------+
-- Procedure: validate_salesrep_entries
-- Desc     : check if the record is valid to insert into cn_calc_submission_entries
-- ----------------------------------------------------------------------------+
PROCEDURE validate_salesrep_entries
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_salesrep_tbl           IN  salesrep_tbl_type,
   p_loading_status         IN  VARCHAR2,
   x_salesreps_id_tbl       OUT NOCOPY salesrep_id_tbl_type,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'validate_salesrep_entries';
      l_loading_status  VARCHAR2(100);

      l_salesrep_id     NUMBER;
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_salesrep_entries.begin',
	      		    'Beginning of validate_salesrep_entries ...');
   end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body

   IF p_salesrep_tbl.COUNT = 0 THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_NO_SALESREP');
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
       FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.validate_salesrep_entries.error',
	       		       TRUE);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_NO_SALESREP');
	   FND_MSG_PUB.Add;
     END IF;
     x_loading_status := 'CN_CALC_NO_SALESREP';
     RAISE FND_API.g_exc_error;
   ELSE
     FOR ctr IN 1 .. p_salesrep_tbl.COUNT LOOP
	 IF validate_salesrep(  p_salesrep_rec   =>  p_salesrep_tbl(ctr),
			     x_salesrep_id    =>  l_salesrep_id,
			     x_loading_status =>  x_loading_status  )  THEN
	    x_salesreps_id_tbl(ctr) := l_salesrep_id;
	  ELSE
	    RAISE FND_API.g_exc_error;
	 END IF;
      END LOOP;
   END IF;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_salesrep_entries.end',
	      		    'End of validate_salesrep_entries.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
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
                         'cn.plsql.cn_calc_submission_pub.validate_salesrep_entries.exception',
		       		     sqlerrm);
      end if;

END validate_salesrep_entries;


-- ----------------------------------------------------------------------------+
-- Procedure: validate_bonus_pe_entries
-- Desc     : check if the record is valid to insert into cn_calc_submission_batches
-- ----------------------------------------------------------------------------+
PROCEDURE validate_bonus_pe_entries
  (
   x_return_status          OUT NOCOPY VARCHAR2,
   x_msg_count              OUT NOCOPY NUMBER,
   x_msg_data               OUT NOCOPY VARCHAR2,
   p_bonus_pe_tbl           IN  plan_element_tbl_type,
   p_interval_type          IN  VARCHAR2,
   p_loading_status         IN  VARCHAR2,
   x_bonus_pe_id_tbl        OUT NOCOPY plan_element_id_tbl_type,
   x_loading_status         OUT NOCOPY VARCHAR2
   ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'validate_bonus_pe_entries';
      l_loading_status  VARCHAR2(100);

      l_quota_id        NUMBER;
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_bonus_pe_entries.begin',
	      		    'Beginning of validate_bonus_pe_entries ...');
   end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body
   FOR ctr IN 1 .. p_bonus_pe_tbl.COUNT LOOP
      IF validate_bonus_pe ( p_quota_name  => p_bonus_pe_tbl(ctr),
			  p_interval_type => p_interval_type,
			  x_quota_id      => l_quota_id,
			  x_loading_status => x_loading_status ) THEN
	 x_bonus_pe_id_tbl(ctr) := l_quota_id;
       ELSE
	 RAISE FND_API.g_exc_error;
      END IF;
   END LOOP;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
       p_encoded => FND_API.G_FALSE
       );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_bonus_pe_entries.end',
	      		    'End of validate_bonus_pe_entries.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
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
                         'cn.plsql.cn_calc_submission_pub.validate_bonus_pe_entries.exception',
		       		     sqlerrm);
      end if;

END validate_bonus_pe_entries;

-- ----------------------------------------------------------------------------+
-- Procedure: validate_app_user_resp
-- Desc     : check if the record is valid to insert into cn_calc_submission_batches
-- ----------------------------------------------------------------------------+
PROCEDURE validate_app_user_resp
  ( x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_app_user_resp_rec      IN  app_user_resp_rec_type,
    p_loading_status         IN  VARCHAR2,
    x_user_id                OUT NOCOPY NUMBER,
    x_responsibility_id      OUT NOCOPY NUMBER,
    x_loading_status         OUT NOCOPY VARCHAR2
    ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'validate_app_user_resp';
      l_loading_status  VARCHAR2(100);

BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.begin',
	      		    'Beginning of validate_app_user_resp ...');
   end if;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := p_loading_status;

   -- Start of API body

   -- user_name cannot be missing/null
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_app_user_resp_rec.user_name,
	  p_obj_name  => g_calc_sub_user_name,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   BEGIN
      SELECT user_id INTO x_user_id
	FROM fnd_user
	WHERE user_name = p_app_user_resp_rec.user_name;

   EXCEPTION
      WHEN no_data_found THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_USER_NOT_EXIST');
	    fnd_message.set_token('USER_NAME', p_app_user_resp_rec.user_name );
        if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.validation',
		       		     TRUE);
        end if;

	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	      FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_USER_NOT_EXIST');
	      fnd_message.set_token('USER_NAME', p_app_user_resp_rec.user_name );
	      FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_CALC_USER_NOT_EXIST';
	    RAISE FND_API.G_EXC_ERROR ;
      WHEN OTHERS THEN
        if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.exception',
		       		     sqlerrm);
        end if;

	    RAISE FND_API.G_EXC_ERROR ;
   END;

   --  responsibility_name can not be missing/null
   IF ( (cn_api.chk_miss_null_char_para
	 (p_char_para => p_app_user_resp_rec.responsibility_name,
	  p_obj_name  => g_calc_sub_resp_name,
	  p_loading_status => x_loading_status,
	  x_loading_status => x_loading_status)) = FND_API.G_TRUE ) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   BEGIN
      -- clku, bug 3683443, added hints to do index skip scan
      SELECT /*+ index_ss(V.T) */ responsibility_id
	  INTO x_responsibility_id
	FROM fnd_responsibility_vl
	WHERE responsibility_name = p_app_user_resp_rec.responsibility_name;

   EXCEPTION
	 WHEN no_data_found THEN
       FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_RESP_NOT_EXIST');
       fnd_message.set_token('RESP_NAME', p_app_user_resp_rec.responsibility_name );
       if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                         'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.validation',
		       		     TRUE);
       end if;

	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	       FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_RESP_NOT_EXIST');
	       fnd_message.set_token('RESP_NAME', p_app_user_resp_rec.responsibility_name );
	       FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_CALC_RESP_NOT_EXIST';
	    RAISE FND_API.G_EXC_ERROR ;

	 WHEN OTHERS THEN
        if (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED,
                         'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.exception',
		       		     sqlerrm);
        end if;

	    RAISE FND_API.G_EXC_ERROR ;
   END;

   -- End of API body.

   -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
      (p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
       p_encoded => FND_API.G_FALSE
       );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.end',
	      		    'End of validate_app_user_resp.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
         );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
      FND_MSG_PUB.Count_And_Get
        (
         p_count   =>  x_msg_count ,
         p_data    =>  x_msg_data  ,
         p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      x_loading_status := 'UNEXPECTED_ERR';
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
                         'cn.plsql.cn_calc_submission_pub.validate_app_user_resp.exception',
		       		     sqlerrm);
      end if;

END validate_app_user_resp;

FUNCTION get_calc_sub_batch_status ( p_calc_sub_batch_id NUMBER) RETURN VARCHAR2 IS
   CURSOR l_status_csr IS
      SELECT status
	FROM cn_calc_submission_batches_all
	WHERE calc_sub_batch_id = p_calc_sub_batch_id;

   x_status VARCHAR2(30);

BEGIN
   OPEN l_status_csr;
   FETCH l_status_csr INTO x_status;
   CLOSE l_status_csr;

   RETURN x_status;
END get_calc_sub_batch_status;


-- Start of Comments
-- API name 	: Create_Calc_Submission
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
-- Desc 	: Procedure to create a new calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_calc_submission_rec     IN       calc_submission_rec_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
--
--
-- Description :
--               Create Calc Submission is a Public Package which allows us to create
-- the calculation submission batch.
------------------+
-- p_calc_submission_rec Input parameter
--   name             calculation submission batch name,                            Mandatory
--                    Should uniquely identify the batch
--   start_date       start date                                                    Mandatory
--                    Must be within opened period
--   end_date         end date    must be within opened period                      Mandatory
--                    Must be within opened period
--   calc_type        type of calculation                                           Mandatory
--                    Valid values: COMMISSION/BONUS
--   salesrep_option  salesrep option                                               Mandatory
--                    Valid values: ALL_REPS/USER_SPECIFY/REPS_IN_NOTIFY_LOG
--                    IF calc_type = BONUS , REPS_IN_NOTIFY_LOG is not valid.
--   hierarchy_flag   entire hierarchy or not                                       Mandatory
--                    Valid values: Y/N
--                    IF salesrep_option = ALL_REPS or REPS_IN_NOTIFY_LOG,
--                       hierarchy_flag should be 'N'.
--   concurrent_flag  concurrent calculation or not ( Y/N )                         Mandatory
--                    Valid values: Y/N
--   intelligent_flag incremental calculation or not ( Y/N)                         Mandatory
--                    Valid values: Y/N
--                    IF salesrep_option = REPS_IN_NOTIFY_LOG,
--                       intelligent_flag should be 'Y'.
--   interval_type    interval type for bonus plan elements                         Optional
--                    Valid values:  PERIOD/QUARTER/YEAR/ALL
--                    Mandatory when calc_type = 'COMMISSION'
--
--   salesrep_tbl list of salesreps' name                                           Optional
--                    Valid when salesrep_option = 'USER_SPECIFY'
--                    Sales persons listed currently have or previously had
--                          compensation plan assigned.
--   bonus_pe_tbl list of bonus plan elements' name                                 Optional
--                    Valid when calc_type = BONUS
--                    Plan elements listed should be 'BONUS' type and their interval type should
--                         match the value of interval_type.
--
------------------------+
-- End of comments
PROCEDURE Create_Calc_Submission
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_calc_submission_rec  IN  calc_submission_rec_type := g_miss_calc_submission_rec,
   p_app_user_resp_rec    IN  app_user_resp_rec_type                := g_miss_app_user_resp_rec,
   p_salesrep_tbl         IN  salesrep_tbl_type                     := g_miss_salesrep_tbl,
   p_bonus_pe_tbl         IN  plan_element_tbl_type                 := g_miss_pe_tbl,
   x_loading_status     OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name     CONSTANT VARCHAR2(30) := 'Create_Calc_Submission';
      l_api_version  CONSTANT NUMBER  := 1.0;

      l_calc_sub_batch_id     NUMBER;
      l_interval_type_id      NUMBER;
      l_hierarchy_flag        VARCHAR2(1);

      l_p_calc_submission_rec calc_submission_rec_type;
      l_OAI_array             JTF_USR_HKS.OAI_data_array_type;

      l_salesreps_id_tbl      salesrep_id_tbl_type;
      l_bonus_pe_id_tbl       plan_element_id_tbl_type;
      l_user_id               NUMBER;
      l_responsibility_id     NUMBER;
      l_unfinished            BOOLEAN := TRUE;

      l_calc_sub_status       cn_calc_submission_batches.status%TYPE;
      l_process_audit_id      NUMBER;
      l_process_audit_status  VARCHAR2(30);

      l_bind_data_id          NUMBER;

      l_status                VARCHAR2(30);
BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.create_calc_submission.begin',
	      		    'Beginning of create_calc_submission ...');
   end if;

   -- Standard Start of API savepoint
   SAVEPOINT	create_calc_submission;
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
   x_loading_status := 'CN_INSERTED';

   -- API body starts here
   l_p_calc_submission_rec := p_calc_submission_rec;

   -- Due to the change of moving this flag to the rep level, the caller can choose not to
   -- pass a value for entire_hierarchy when running calculation. However, for backward
   -- compatibility, we still recognize entire_hierarchy if it is specified as 'Y'
   if (p_calc_submission_rec.entire_hierarchy = fnd_api.g_miss_char) then
     l_p_calc_submission_rec.entire_hierarchy := 'N';
   end if;

   -- validate user_name/responsibility name
   IF l_p_calc_submission_rec.concurrent_calculation = 'Y' THEN
      validate_app_user_resp( x_return_status  => x_return_status,
			      x_msg_count      => x_msg_count,
			      x_msg_data       => x_msg_data,
			      p_app_user_resp_rec => p_app_user_resp_rec,
			      p_loading_status => x_loading_status,
			      x_user_id        => l_user_id,
			      x_responsibility_id => l_responsibility_id,
			      x_loading_status => x_loading_status
			      );

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;

   fnd_global.apps_initialize (user_id => l_user_id,
				               resp_id => l_responsibility_id,
				               resp_appl_id => 283
				              );

   g_org_id := p_calc_submission_rec.org_id;
   mo_global.validate_orgid_pub_api(org_id => g_org_id,
                                    status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_calc_submission_pub.create_calc_submission.org_validate',
	      		    'Validated org_id = ' || g_org_id || ' status = '||l_status);
   end if;

   l_p_calc_submission_rec.org_id := g_org_id;


   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'B', 'C' ) then

      CN_CALC_SUBMISSION_CUHK.create_calc_submission_pre
	(   	p_api_version              => p_api_version,
   		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
		p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
       );
     if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
				RAISE FND_API.G_EXC_ERROR;
     elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   end if;

   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'B', 'V' ) then
      cn_calc_submission_VUHK.create_calc_submission_pre
	(       p_api_version              => p_api_version,
   		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
		p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
       );
     if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
				RAISE FND_API.G_EXC_ERROR;
     elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   END IF;

   --+
   -- Validate calculation submission batch level
   --+
   validate_calc_sub_batch( x_return_status  => x_return_status,
			    x_msg_count      => x_msg_count,
			    x_msg_data       => x_msg_data,
			    p_calc_submission_rec => l_p_calc_submission_rec,
			    p_loading_status => x_loading_status,
			    x_loading_status => x_loading_status
			    );

   IF (x_return_status <> FND_API.g_ret_sts_success) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- continue to validate salesrep_entries
   IF l_p_calc_submission_rec.salesrep_option = 'USER_SPECIFY' THEN
      validate_salesrep_entries( x_return_status  => x_return_status,
				 x_msg_count      => x_msg_count,
				 x_msg_data       => x_msg_data,
				 p_salesrep_tbl   => p_salesrep_tbl,
				 p_loading_status => x_loading_status,
				 x_salesreps_id_tbl => l_salesreps_id_tbl,
				 x_loading_status => x_loading_status
				 );

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;

   -- continue to validate bonus plan elements
   IF l_p_calc_submission_rec.calculation_type = 'BONUS' THEN
      validate_bonus_pe_entries ( x_return_status  => x_return_status,
				  x_msg_count      => x_msg_count,
				  x_msg_data       => x_msg_data,
				  p_bonus_pe_tbl   => p_bonus_pe_tbl,
				  p_interval_type  => l_p_calc_submission_rec.interval_type,
				  p_loading_status => x_loading_status,
				  x_bonus_pe_id_tbl => l_bonus_pe_id_tbl,
				  x_loading_status => x_loading_status
				  );

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;


   -- IF program reaches here, all validations are successful.
   -- start to create calc_submission_batch
   l_calc_sub_batch_id := cn_calc_sub_batches_pkg.get_calc_sub_batch_id;

   IF l_p_calc_submission_rec.calculation_type = 'BONUS' THEN
      --clku, bug 3428365
      /*SELECT interval_type_id INTO l_interval_type_id
	FROM cn_interval_types
	WHERE name = l_p_calc_submission_rec.interval_type;*/

       IF  l_p_calc_submission_rec.interval_type = 'PERIOD' THEN
           l_interval_type_id := -1000;
       END IF;

       IF  l_p_calc_submission_rec.interval_type = 'QUARTER' THEN
           l_interval_type_id := -1001;
       END IF;

       IF  l_p_calc_submission_rec.interval_type = 'YEAR' THEN
           l_interval_type_id := -1002;
       END IF;

       IF  l_p_calc_submission_rec.interval_type = 'ALL' THEN
           l_interval_type_id := -1003;
       END IF;

   END IF;

   -- insert into cn_calc_submission_batches
   cn_calc_sub_batches_pkg.begin_record
     ( p_operation           => 'INSERT',
       p_calc_sub_batch_id   => l_calc_sub_batch_id,
       p_name                => l_p_calc_submission_rec.batch_name,
       p_start_date          => l_p_calc_submission_rec.start_date,
       p_end_date            => l_p_calc_submission_rec.end_date,
       p_intelligent_flag    => l_p_calc_submission_rec.incremental_calculation,
       p_hierarchy_flag      => l_p_calc_submission_rec.entire_hierarchy,
       p_salesrep_option     => l_p_calc_submission_rec.salesrep_option,
       p_concurrent_flag     => l_p_calc_submission_rec.concurrent_calculation,
       p_status              => 'INCOMPLETE',
       p_interval_type_id    => l_interval_type_id,
       p_org_id              => g_org_id,
       p_calc_type           => l_p_calc_submission_rec.calculation_type,
       p_attribute_category  => l_p_calc_submission_rec.attribute_category,
       p_attribute1            => l_p_calc_submission_rec.attribute1,
       p_attribute2            => l_p_calc_submission_rec.attribute2,
       p_attribute3            => l_p_calc_submission_rec.attribute3,
       p_attribute4            => l_p_calc_submission_rec.attribute4,
       p_attribute5            => l_p_calc_submission_rec.attribute5,
       p_attribute6            => l_p_calc_submission_rec.attribute6,
       p_attribute7            => l_p_calc_submission_rec.attribute7,
       p_attribute8            => l_p_calc_submission_rec.attribute8,
       p_attribute9            => l_p_calc_submission_rec.attribute9,
       p_attribute10           => l_p_calc_submission_rec.attribute10,
       p_attribute11           => l_p_calc_submission_rec.attribute11,
       p_attribute12           => l_p_calc_submission_rec.attribute12,
       p_attribute13           => l_p_calc_submission_rec.attribute13,
       p_attribute14           => l_p_calc_submission_rec.attribute14,
       p_attribute15           => l_p_calc_submission_rec.attribute15,
       p_last_update_date     => g_last_update_date,
       p_last_updated_by      => g_last_updated_by,
       p_creation_date        => g_creation_date,
       p_created_by           => g_created_by,
       p_last_update_login    => g_last_update_login
     );

   -- insert into cn_calc_submission_entries
   IF l_p_calc_submission_rec.salesrep_option = 'USER_SPECIFY' THEN
      FOR ctr IN 1 .. l_salesreps_id_tbl.COUNT LOOP

      -- for backward compatibility
      if (l_p_calc_submission_rec.entire_hierarchy = 'Y') then
        l_hierarchy_flag := 'Y';
      else
        l_hierarchy_flag := p_salesrep_tbl(ctr).hierarchy_flag;
      end if;

	  cn_calc_sub_entries_pkg.begin_record
	    ( p_operation         => 'INSERT',
	      p_calc_sub_batch_id => l_calc_sub_batch_id,
	      p_salesrep_id       => l_salesreps_id_tbl(ctr),
	      p_hierarchy_flag    => l_hierarchy_flag,
	      p_org_id            => g_org_id,
	      p_last_update_date     => g_last_update_date,
	      p_last_updated_by      => g_last_updated_by,
	      p_creation_date        => g_creation_date,
	      p_created_by           => g_created_by,
	      p_last_update_login    => g_last_update_login
	      );
      END LOOP;
   END IF;

   -- insert into cn_calc_sub_quotas
   IF l_p_calc_submission_rec.calculation_type = 'BONUS' THEN
      FOR ctr IN 1 .. l_bonus_pe_id_tbl.COUNT LOOP
	 cn_calc_sub_quotas_pkg.begin_record
	   ( p_operation         => 'INSERT',
	     p_calc_sub_batch_id => l_calc_sub_batch_id,
	     p_quota_id          => l_bonus_pe_id_tbl(ctr),
	     p_org_id            => g_org_id,
	     p_last_update_date     => g_last_update_date,
	     p_last_updated_by      => g_last_updated_by,
	     p_creation_date        => g_creation_date,
	     p_created_by           => g_created_by,
	     p_last_update_login    => g_last_update_login
	     );
      END LOOP;
   END IF;

   -- only if p_commit is true then submit the calculation
   IF FND_API.To_Boolean( p_commit ) THEN
      -- initialize apps enviroment for concurrent submission
      IF l_p_calc_submission_rec.concurrent_calculation = 'Y' THEN

	 -- we have to do commit first
	 COMMIT WORK;

      END IF;

      cn_proc_batches_pkg.calculation_submission
	(  p_calc_sub_batch_id   => l_calc_sub_batch_id,
	   x_process_audit_id    => l_process_audit_id,
	   x_process_status_code => l_process_audit_status
	   );

      l_calc_sub_status := get_calc_sub_batch_status( l_calc_sub_batch_id);

      IF l_p_calc_submission_rec.concurrent_calculation = 'Y' THEN
	 l_unfinished := TRUE;

	 WHILE l_unfinished LOOP
	    l_calc_sub_status := get_calc_sub_batch_status( l_calc_sub_batch_id);

	    IF l_calc_sub_status = 'PROCESSING' THEN
	       dbms_lock.sleep(180);
	     ELSE
	       l_unfinished := FALSE;
	    END IF;
	 END LOOP;
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 IF l_calc_sub_status = 'FAILED' THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_FAIL_LOG');
	    fnd_message.set_token( 'AUDIT_ID', To_char(l_process_audit_id) );
		if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.create_calc_submission.error',
	       		       false);
        end if;

	    x_loading_status := 'ALL_PROCESS_DONE_FAIL_LOG';
	  ELSIF l_calc_sub_status = 'COMPLETE' THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_OK_LOG');
        fnd_message.set_token( 'AUDIT_ID', To_char(l_process_audit_id) );
	    x_loading_status := 'ALL_PROCESS_DONE_OK_LOG';
	 END IF;

	 FND_MSG_PUB.Add;
      END IF;
   END IF;  -- p_commit;

   --   API return status to success
   x_return_status  := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';


   -- End of API body.

   /*  Post processing     */
   -- dbms_output.put_line('calling post processing API');
   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'A', 'V' ) then
      cn_calc_submission_VUHK.create_calc_submission_post
	(   	p_api_version              => p_api_version,
		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
                p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
		);
      if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
	 RAISE FND_API.G_EXC_ERROR;
       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
   end if;

   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'A', 'C' ) then

      CN_CALC_SUBMISSION_CUHK.create_calc_submission_post
	( 	p_api_version              => p_api_version,
		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
		p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
       );
      if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
	 RAISE FND_API.G_EXC_ERROR;
       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
   end if;

   --  Following code is for message generation
   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'M', 'M' ) then

      IF ( CN_CALC_SUBMISSION_CUHK.ok_to_generate_msg
	   ( p_calc_submission_rec    => l_p_calc_submission_rec )
	   ) THEN

	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;
	 JTF_USR_HKS.Load_Bind_Data(  l_bind_data_id, 'CALC_SUB_BATCH_ID',
				      l_calc_sub_batch_id, 'S', 'N'       );

	JTF_USR_HKS.generate_message( p_prod_code    => 'CN',
				      p_bus_obj_code => 'CALC_SUB',
				      p_bus_obj_name => 'CALC_SUBMISSION',
				      p_action_code  => 'I',     -- Insert
				      p_bind_data_id => l_bind_data_id,
				      x_return_code  => x_return_status
				      );
	 if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
	    RAISE FND_API.G_EXC_ERROR;
	  elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 end if;
      END IF;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

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
                    'cn.plsql.cn_calc_submission_pub.create_calc_submission.end',
	      		    'End of create_calc_submission.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO 	create_calc_submission;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO 	create_calc_submission;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO 	create_calc_submission;
      x_loading_status := 'UNEXPECTED_ERR';
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
                         'cn.plsql.cn_calc_submission_pub.create_calc_submission.exception',
		       		     sqlerrm);
     end if;

END Create_Calc_Submission;

-- Start of Comments
-- API name 	: Update_Calc_Submission
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to update a calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
--                And submit the calculation after all validations are successful
-- Desc 	: Procedure to update calculation submission batch with passed_in
--                salesreps/ passed_in bonus plan elements
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_calc_submission_rec     IN       calc_submission_rec_type
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
--
-- Description	: This procedure is used to update a calculation submission
-- Notes	:
--
--   p_calc_submission_rec_old                           Mandatory
--                old calculation submission batch must be found based
--                    on p_calc_submission_rec_old.name
--   p_calc_submission_rec_new                           Mandatory
--                all the validation rules in create_calc_submission holds here
--
--  p_app_user_resp_rec IN parameter                     Optional
--                    Information required to submit concurrent calculation
--                    Valid when concurrent_calculation = 'Y'
--                      user_name should be a valid application user name.
--                      responsibility_name should be a valid responsibility name
--
--   p_salesrep_tbl IN parameter                         Optional
--                   list of salesreps' employee number /employee type
--                   Valid when salesrep_option = 'USER_SPECIFY'
--                      salesrep_rec_type.employee number    can not be missing or null
--                      salesrep_rec_type.type               can not be missing or null
--                      Sales persons listed currently have or previously had
--                          compensation plan assigned.
--   p_salesrep_tbl_action                               Mandatory
--                Valid Values: ADD/DELETE
--                either add the listed sales persons to table or delete the listed
--                       sales persons from the table.
--
--   p_bonus_pe_tbl IN parameter                         Optional
--                   list of bonus plan elements' name
--                   Valid when calc_type = BONUS
--                     Plan elements listed should be 'BONUS' type and their interval type should
--                         match the value of p_calc_submission_rec.interval_type
--                         or if p_calc_submission_rec.interval_type = 'ALL', then their interval
--                         type can be any of 'PERIOD'/'QUARTER'/'YEAR'
--   p_bonus_pe_tbl_action                               Mandatory
--                Valid Values: ADD/DELETE
--                either add the listed bonus plan elements to table or delete the listed
--                       bonus plan elements from the table.
--                if the plan element already exists or there are duplicates in p_bonus_pe_tbl,
--                  give out a message without failing the call
--
-- Special Notes:
--     IF p_commit is not fnd_api.g_true, then the calculation will not be submitted even if all
--     the validations are successful.
--
--
-- End of comments
------------------------+
-- End of comments

PROCEDURE Update_Calc_Submission
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	            IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_calc_submission_rec_old      IN    calc_submission_rec_type := g_miss_calc_submission_rec,
   p_calc_submission_rec_new      IN    calc_submission_rec_type := g_miss_calc_submission_rec,
   p_app_user_resp_rec    IN  app_user_resp_rec_type                := g_miss_app_user_resp_rec,
   p_salesrep_tbl         IN  salesrep_tbl_type                     := g_miss_salesrep_tbl,
   p_salesrep_tbl_action  IN    VARCHAR2,
   p_bonus_pe_tbl         IN  plan_element_tbl_type                 := g_miss_pe_tbl,
   p_bonus_pe_tbl_action  IN    VARCHAR2,
   x_loading_status       OUT NOCOPY   VARCHAR2
   ) IS

      l_api_name		   CONSTANT VARCHAR2(30) := 'Update_Calc_Submission';
      l_api_version           	   CONSTANT NUMBER  := 1.0;

      l_calc_sub_batch_id   NUMBER;
      l_interval_type_id    NUMBER;
      l_hierarchy_flag      VARCHAR2(1);

      l_p_calc_submission_rec calc_submission_rec_type;
      l_OAI_array        JTF_USR_HKS.OAI_data_array_type;

      l_salesreps_id_tbl salesrep_id_tbl_type;
      l_bonus_pe_id_tbl  plan_element_id_tbl_type;
      l_user_id               NUMBER;
      l_responsibility_id     NUMBER;
      l_unfinished            BOOLEAN := TRUE;

      l_calc_sub_status       cn_calc_submission_batches.status%TYPE;
      l_process_audit_id      NUMBER;
      l_process_audit_status  VARCHAR2(30);
      l_status                VARCHAR2(30);

      CURSOR l_calc_sub_batch_csr( l_name cn_calc_submission_batches.name%TYPE)
	IS
	 SELECT *
	   FROM cn_calc_submission_batches_all
	   WHERE name = l_name
	   AND org_id = g_org_id;

      l_calc_sub_batch_rec   l_calc_sub_batch_csr%ROWTYPE;

      CURSOR l_bonus_pe_exists_csr ( l_calc_sub_batch_id NUMBER,
				     l_quota_id          NUMBER )
	IS
	   SELECT COUNT(*)
	     FROM cn_calc_sub_quotas_all
	     WHERE calc_sub_batch_id = l_calc_sub_batch_id
	     AND quota_id = l_quota_id;

      CURSOR l_salesrep_exists_csr ( l_calc_sub_batch_id NUMBER,
				     l_salesrep_id       NUMBER  )
	IS
	   SELECT COUNT(*)
	     FROM cn_calc_submission_entries_all
	     WHERE calc_sub_batch_id = l_calc_sub_batch_id
	     AND salesrep_id = l_salesrep_id;

      l_counter    NUMBER;
      l_name_validate_flag VARCHAR2(1);

      l_bind_data_id  NUMBER;

BEGIN
   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.update_calc_submission.begin',
	      		    'Beginning of update_calc_submission ...');
   end if;

   -- Standard Start of API savepoint

   SAVEPOINT	update_calc_submission;

   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
					p_api_version ,
					l_api_name    ,
					G_PKG_NAME )
     THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   -- continue to validate user_name/responsibility name
   IF l_p_calc_submission_rec.concurrent_calculation = 'Y' THEN
      validate_app_user_resp( x_return_status  => x_return_status,
			      x_msg_count      => x_msg_count,
			      x_msg_data       => x_msg_data,
			      p_app_user_resp_rec => p_app_user_resp_rec,
			      p_loading_status => x_loading_status,
			      x_user_id        => l_user_id,
			      x_responsibility_id => l_responsibility_id,
			      x_loading_status => x_loading_status
			      );

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;

	 fnd_global.apps_initialize ( user_id => l_user_id,
				      resp_id => l_responsibility_id,
				      resp_appl_id => 283
				      );

   g_org_id := p_calc_submission_rec_old.org_id;
   mo_global.validate_orgid_pub_api(org_id => g_org_id,
                                    status => l_status);

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT,
                    'cn.plsql.cn_calc_submission_pub.update_calc_submission.org_validate',
	      		    'Validated org_id = ' || g_org_id || ' status = '||l_status);
   end if;

   if (nvl(p_calc_submission_rec_new.org_id, g_org_id) <> nvl(p_calc_submission_rec_old.org_id, g_org_id)) then
     FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
     if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       true);
     end if;

     IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.SET_NAME ('FND' , 'FND_MO_OU_CANNOT_UPDATE');
	   FND_MSG_PUB.Add;
     END IF;

     RAISE FND_API.G_EXC_ERROR ;
   end if;

   --+
   -- Start of API body
   --+
   l_p_calc_submission_rec := p_calc_submission_rec_new;
   l_p_calc_submission_rec.org_id := g_org_id;

   --dbms_output.put_line('Going into pre processing ');
   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'B', 'C' ) then

      CN_CALC_SUBMISSION_CUHK.create_calc_submission_pre
	(   	p_api_version              => p_api_version,
   		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
		p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
       );
     if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
				RAISE FND_API.G_EXC_ERROR;
     elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   end if;

   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'B', 'V' ) then
      cn_calc_submission_VUHK.create_calc_submission_pre
	(       p_api_version              => p_api_version,
   		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
		p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
       );
     if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
				RAISE FND_API.G_EXC_ERROR;
     elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     end if;
   END IF;


   -- validate the p_calc_submission_rec_old exists
   --  old batch_name can not be missing or null
   --  and should uniquely identify the batch
   IF (cn_api.chk_miss_null_char_para
       (p_char_para => p_calc_submission_rec_old.batch_name,
	p_obj_name => g_calc_sub_name,
	p_loading_status => x_loading_status,
	x_loading_status => x_loading_status) = FND_API.G_TRUE) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   OPEN l_calc_sub_batch_csr( p_calc_submission_rec_old.batch_name);
   FETCH l_calc_sub_batch_csr INTO l_calc_sub_batch_rec;

   IF l_calc_sub_batch_csr%notfound THEN
     CLOSE l_calc_sub_batch_csr;
     FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_NOT_EXIST');
	 fnd_message.set_token ('BATCH_NAME', p_calc_submission_rec_old.batch_name );
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       true);
      end if;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_NOT_EXIST');
	 fnd_message.set_token ('BATCH_NAME', p_calc_submission_rec_old.batch_name );
	 FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_CALC_SUB_NOT_EXIST';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   CLOSE l_calc_sub_batch_csr;

   IF l_calc_sub_batch_rec.status = 'COMPLETE' OR l_calc_sub_batch_rec.status = 'PROCESSING' THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_NOT_UPDATEABLE');
	 fnd_message.set_token ('BATCH_NAME', p_calc_submission_rec_old.batch_name );
	 if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       true);
      end if;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_NOT_UPDATEABLE');
	 fnd_message.set_token ('BATCH_NAME', p_calc_submission_rec_old.batch_name );
	 FND_MSG_PUB.Add;
      END IF;

      x_loading_status := 'CN_CALC_SUB_NOT_UPDATEABLE';
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- handling g_miss_* in l_p_calc_submission_rec_new
   SELECT Decode( l_p_calc_submission_rec.batch_name, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.name, l_p_calc_submission_rec.batch_name )
     INTO l_p_calc_submission_rec.batch_name
     FROM dual;

   IF l_p_calc_submission_rec.batch_name = p_calc_submission_rec_old.batch_name THEN
      l_name_validate_flag := 'N';
    ELSE
      l_name_validate_flag := 'Y';
   END IF;

   SELECT Decode( l_p_calc_submission_rec.start_date, fnd_api.g_miss_date,
		  l_calc_sub_batch_rec.start_date, l_p_calc_submission_rec.start_date )
     INTO l_p_calc_submission_rec.start_date
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.end_date, fnd_api.g_miss_date,
		  l_calc_sub_batch_rec.end_date, l_p_calc_submission_rec.end_date )
     INTO l_p_calc_submission_rec.end_date
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.calculation_type, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.calc_type, l_p_calc_submission_rec.calculation_type )
     INTO l_p_calc_submission_rec.calculation_type
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.salesrep_option, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.salesrep_option, l_p_calc_submission_rec.salesrep_option )
     INTO l_p_calc_submission_rec.salesrep_option
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.entire_hierarchy, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.hierarchy_flag, l_p_calc_submission_rec.entire_hierarchy )
     INTO l_p_calc_submission_rec.entire_hierarchy
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.concurrent_calculation, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.concurrent_flag, l_p_calc_submission_rec.concurrent_calculation )
     INTO l_p_calc_submission_rec.concurrent_calculation
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.incremental_calculation, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.intelligent_flag, l_p_calc_submission_rec.incremental_calculation )
     INTO l_p_calc_submission_rec.incremental_calculation
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.interval_type, fnd_api.g_miss_char,
		  Decode( l_calc_sub_batch_rec.interval_type_id, NULL, NULL, -1000, 'PERIOD',
			  -1001, 'QUARTER', -1002, 'YEAR', -1003 , 'ALL' ),
		  l_p_calc_submission_rec.interval_type )
     INTO l_p_calc_submission_rec.interval_type
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute_category, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute_category, l_p_calc_submission_rec.attribute_category )
     INTO l_p_calc_submission_rec.attribute_category
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute1, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute1, l_p_calc_submission_rec.attribute1 )
     INTO l_p_calc_submission_rec.attribute1
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute2, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute2, l_p_calc_submission_rec.attribute2 )
     INTO l_p_calc_submission_rec.attribute2
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute3, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute3, l_p_calc_submission_rec.attribute3 )
     INTO l_p_calc_submission_rec.attribute3
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute4, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute4, l_p_calc_submission_rec.attribute4 )
     INTO l_p_calc_submission_rec.attribute4
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute5, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute5, l_p_calc_submission_rec.attribute5 )
     INTO l_p_calc_submission_rec.attribute5
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute6, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute6, l_p_calc_submission_rec.attribute6 )
     INTO l_p_calc_submission_rec.attribute6
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute7, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute7, l_p_calc_submission_rec.attribute7 )
     INTO l_p_calc_submission_rec.attribute7
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute8, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute8, l_p_calc_submission_rec.attribute8 )
     INTO l_p_calc_submission_rec.attribute8
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute9, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute9, l_p_calc_submission_rec.attribute9 )
     INTO l_p_calc_submission_rec.attribute9
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute10, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute10, l_p_calc_submission_rec.attribute10 )
     INTO l_p_calc_submission_rec.attribute10
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute11, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute11, l_p_calc_submission_rec.attribute11 )
     INTO l_p_calc_submission_rec.attribute11
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute12, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute12, l_p_calc_submission_rec.attribute12 )
     INTO l_p_calc_submission_rec.attribute12
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute13, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute13, l_p_calc_submission_rec.attribute13 )
     INTO l_p_calc_submission_rec.attribute13
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute14, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute14, l_p_calc_submission_rec.attribute14 )
     INTO l_p_calc_submission_rec.attribute14
     FROM dual;

   SELECT Decode( l_p_calc_submission_rec.attribute15, fnd_api.g_miss_char,
		  l_calc_sub_batch_rec.attribute15, l_p_calc_submission_rec.attribute1 )
     INTO l_p_calc_submission_rec.attribute15
     FROM dual;

   --+
   -- Validate calculation submission batch level
   --+
   validate_calc_sub_batch( x_return_status       => x_return_status,
			    x_msg_count           => x_msg_count,
			    x_msg_data            => x_msg_data,
			    p_calc_submission_rec => l_p_calc_submission_rec,
			    p_loading_status      => x_loading_status,
			    p_name_validate_flag  => l_name_validate_flag,
			    x_loading_status      => x_loading_status
			    );

   IF (x_return_status <> FND_API.g_ret_sts_success) THEN
      RAISE FND_API.G_EXC_ERROR ;
   END IF;

   -- continue to validate salesrep_entries
   IF l_p_calc_submission_rec.salesrep_option = 'USER_SPECIFY' THEN
      IF p_salesrep_tbl.COUNT > 0 THEN
	 validate_salesrep_entries( x_return_status  => x_return_status,
				    x_msg_count      => x_msg_count,
				    x_msg_data       => x_msg_data,
				    p_salesrep_tbl   => p_salesrep_tbl,
				    p_loading_status   => x_loading_status,
				    x_salesreps_id_tbl => l_salesreps_id_tbl,
				    x_loading_status   => x_loading_status
				    );
      END IF;

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;

   -- continue to validate bonus plan elements
   IF l_p_calc_submission_rec.calculation_type = 'BONUS' THEN
      validate_bonus_pe_entries ( x_return_status  => x_return_status,
				  x_msg_count      => x_msg_count,
				  x_msg_data       => x_msg_data,
				  p_bonus_pe_tbl   => p_bonus_pe_tbl,
				  p_interval_type  => l_p_calc_submission_rec.interval_type,
				  p_loading_status => x_loading_status,
				  x_bonus_pe_id_tbl => l_bonus_pe_id_tbl,
				  x_loading_status => x_loading_status
				  );

      IF  x_return_status <> FND_API.g_ret_sts_success THEN
	 RAISE FND_API.G_EXC_ERROR ;
      END IF;
   END IF;


   -- IF program reaches here, all validations are successful.
   -- start to create calc_submission_batch
   l_calc_sub_batch_id := l_calc_sub_batch_rec.calc_sub_batch_id;

   IF l_p_calc_submission_rec.calculation_type = 'BONUS' THEN
      --clku, bug 3428365
      /*SELECT interval_type_id INTO l_interval_type_id
	FROM cn_interval_types
	WHERE name = l_p_calc_submission_rec.interval_type;*/

      IF  l_p_calc_submission_rec.interval_type = 'PERIOD' THEN
           l_interval_type_id := -1000;
       END IF;

       IF  l_p_calc_submission_rec.interval_type = 'QUARTER' THEN
           l_interval_type_id := -1001;
       END IF;

       IF  l_p_calc_submission_rec.interval_type = 'YEAR' THEN
           l_interval_type_id := -1002;
       END IF;

       IF  l_p_calc_submission_rec.interval_type = 'ALL' THEN
           l_interval_type_id := -1003;
       END IF;
   END IF;

   -- update cn_calc_submission_batches
   cn_calc_sub_batches_pkg.begin_record
     ( p_operation           => 'UPDATE',
       p_calc_sub_batch_id   => l_calc_sub_batch_id,
       p_name                => l_p_calc_submission_rec.batch_name,
       p_start_date          => l_p_calc_submission_rec.start_date,
       p_end_date            => l_p_calc_submission_rec.end_date,
       p_intelligent_flag    => l_p_calc_submission_rec.incremental_calculation,
       p_hierarchy_flag      => l_p_calc_submission_rec.entire_hierarchy,
       p_salesrep_option     => l_p_calc_submission_rec.salesrep_option,
       p_concurrent_flag     => l_p_calc_submission_rec.concurrent_calculation,
       p_status              => l_calc_sub_batch_rec.status,
       p_interval_type_id    => l_interval_type_id,
       p_org_id              => g_org_id,
       p_calc_type           => l_p_calc_submission_rec.calculation_type,
       p_attribute_category  => l_p_calc_submission_rec.attribute_category,
       p_attribute1            => l_p_calc_submission_rec.attribute1,
       p_attribute2            => l_p_calc_submission_rec.attribute2,
       p_attribute3            => l_p_calc_submission_rec.attribute3,
       p_attribute4            => l_p_calc_submission_rec.attribute4,
       p_attribute5            => l_p_calc_submission_rec.attribute5,
       p_attribute6            => l_p_calc_submission_rec.attribute6,
       p_attribute7            => l_p_calc_submission_rec.attribute7,
       p_attribute8            => l_p_calc_submission_rec.attribute8,
       p_attribute9            => l_p_calc_submission_rec.attribute9,
       p_attribute10           => l_p_calc_submission_rec.attribute10,
       p_attribute11           => l_p_calc_submission_rec.attribute11,
       p_attribute12           => l_p_calc_submission_rec.attribute12,
       p_attribute13           => l_p_calc_submission_rec.attribute13,
       p_attribute14           => l_p_calc_submission_rec.attribute14,
       p_attribute15           => l_p_calc_submission_rec.attribute15,
       p_last_update_date     => g_last_update_date,
       p_last_updated_by      => g_last_updated_by,
       p_creation_date        => g_creation_date,
       p_created_by           => g_created_by,
       p_last_update_login    => g_last_update_login
     );

   -- ADD/DELETE cn_calc_submission_entries
   IF l_p_calc_submission_rec.salesrep_option = 'USER_SPECIFY' THEN
      IF p_salesrep_tbl_action = 'ADD' THEN
	 FOR ctr IN 1 .. l_salesreps_id_tbl.COUNT LOOP
	    OPEN l_salesrep_exists_csr( l_calc_sub_batch_id,
					l_salesreps_id_tbl(ctr) );
	    FETCH l_salesrep_exists_csr INTO l_counter;
	    CLOSE l_salesrep_exists_csr;

	    IF l_counter = 0 THEN
	      -- for backward compatibility
          if (l_p_calc_submission_rec.entire_hierarchy = 'Y') then
            l_hierarchy_flag := 'Y';
          else
            l_hierarchy_flag := p_salesrep_tbl(ctr).hierarchy_flag;
          end if;

	       cn_calc_sub_entries_pkg.begin_record
		 (  p_operation         => 'INSERT',
		    p_calc_sub_batch_id => l_calc_sub_batch_id,
		    p_salesrep_id       => l_salesreps_id_tbl(ctr),
		    p_hierarchy_flag    => l_hierarchy_flag,
		    p_org_id            => g_org_id,
		    p_last_update_date     => g_last_update_date,
		    p_last_updated_by      => g_last_updated_by,
		    p_creation_date        => g_creation_date,
		    p_created_by           => g_created_by,
		    p_last_update_login    => g_last_update_login
		    );
	     ELSE
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SALESREP_EXISTS');
		  FND_MESSAGE.SET_TOKEN('EMPLOYEE_NUMBER', p_salesrep_tbl(ctr).employee_number );
		  FND_MESSAGE.SET_TOKEN('EMPLOYEE_TYPE', p_salesrep_tbl(ctr).TYPE );
	      if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       true);
          end if;

	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SALESREP_EXISTS');
		  FND_MESSAGE.SET_TOKEN('EMPLOYEE_NUMBER', p_salesrep_tbl(ctr).employee_number );
		  FND_MESSAGE.SET_TOKEN('EMPLOYEE_TYPE', p_salesrep_tbl(ctr).TYPE );
		  FND_MSG_PUB.Add;
	       END IF;
	    END IF;
	 END LOOP;
       ELSIF p_salesrep_tbl_action = 'DELETE' THEN
	 forall j IN 1 .. l_salesreps_id_tbl.COUNT
	   DELETE cn_calc_submission_entries_all
	   WHERE calc_sub_batch_id = l_calc_sub_batch_id
	   AND salesrep_id = l_salesreps_id_tbl(j);

	 DECLARE
	    CURSOR l_salesrep_count_csr IS
	       SELECT 1
		   FROM cn_calc_submission_entries_all
		   WHERE calc_sub_batch_id = l_calc_sub_batch_id;
	    dummy NUMBER;
	 BEGIN
	    OPEN l_salesrep_count_csr;
	    FETCH l_salesrep_count_csr INTO dummy;

	    IF l_salesrep_count_csr%notfound THEN
          CLOSE l_salesrep_count_csr;

		  FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_NO_SALESREP');
	      if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       true);
          end if;

	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_NO_SALESREP');
		  FND_MSG_PUB.Add;
	       END IF;
	       x_loading_status := 'CN_CALC_NO_SALESREP';
	       RAISE FND_API.g_exc_error;
	     ELSE
	       CLOSE l_salesrep_count_csr;
	    END IF;
	 END ;
      END IF;
   END IF;

   -- ADD/DELETE into cn_calc_sub_quotas
   IF l_p_calc_submission_rec.calculation_type = 'BONUS' THEN
      IF p_bonus_pe_tbl_action = 'ADD' THEN
	 FOR ctr IN 1 .. l_bonus_pe_id_tbl.COUNT LOOP
	    OPEN l_bonus_pe_exists_csr( l_calc_sub_batch_id,
					l_bonus_pe_id_tbl(ctr)  );
	    FETCH l_bonus_pe_exists_csr INTO l_counter;
	    CLOSE l_bonus_pe_exists_csr;

	    IF l_counter = 0 THEN
	       cn_calc_sub_quotas_pkg.begin_record
		 ( p_operation         => 'INSERT',
		   p_calc_sub_batch_id => l_calc_sub_batch_id,
		   p_quota_id          => l_bonus_pe_id_tbl(ctr),
		   p_org_id            => g_org_id,
		   p_last_update_date     => g_last_update_date,
		   p_last_updated_by      => g_last_updated_by,
		   p_creation_date        => g_creation_date,
		   p_created_by           => g_created_by,
		   p_last_update_login    => g_last_update_login
		   );
	     ELSE
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_QUOTA_EXISTS');
		  fnd_message.set_token( 'QUOTA_NAME', p_bonus_pe_tbl(ctr) );
	      if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       true);
          end if;

	       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
		 THEN
		  FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_QUOTA_EXISTS');
		  fnd_message.set_token( 'QUOTA_NAME', p_bonus_pe_tbl(ctr) );
		  FND_MSG_PUB.Add;
	       END IF;
	    END IF;
	 END LOOP;
       ELSIF p_bonus_pe_tbl_action = 'DELETE' THEN
	 forall j IN 1 .. l_bonus_pe_id_tbl.COUNT
	    DELETE cn_calc_sub_quotas
	      WHERE calc_sub_batch_id = l_calc_sub_batch_id
	      AND quota_id = l_bonus_pe_id_tbl(j);
      END IF;
   END IF;

   -- only if p_commit is true then submit the calculation
   IF FND_API.To_Boolean( p_commit ) THEN
      -- initialize apps enviroment for concurrent submission
      IF l_p_calc_submission_rec.concurrent_calculation = 'Y' THEN

	 -- we have to do commit first
	 COMMIT WORK;

      END IF;

      cn_proc_batches_pkg.calculation_submission
	(  p_calc_sub_batch_id   => l_calc_sub_batch_id,
	   x_process_audit_id    => l_process_audit_id,
	   x_process_status_code => l_process_audit_status
	   );

      l_calc_sub_status := get_calc_sub_batch_status( l_calc_sub_batch_id);

      IF l_p_calc_submission_rec.concurrent_calculation = 'Y' THEN
	 l_unfinished := TRUE;

	 WHILE l_unfinished LOOP
	    l_calc_sub_status := get_calc_sub_batch_status( l_calc_sub_batch_id);

	    IF l_calc_sub_status = 'PROCESSING' THEN
	       dbms_lock.sleep(180);
	     ELSE
	       l_unfinished := FALSE;
	    END IF;
	 END LOOP;
      END IF;

      IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	THEN
	 IF l_calc_sub_status = 'FAILED' THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_FAIL_LOG');
	    fnd_message.set_token( 'AUDIT_ID', To_char(l_process_audit_id) );
        if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
            FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       false);
        end if;

	    x_loading_status := 'ALL_PROCESS_DONE_FAIL_LOG';
	  ELSIF l_calc_sub_status = 'COMPLETE' THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'ALL_PROCESS_DONE_OK_LOG');
        fnd_message.set_token( 'AUDIT_ID', To_char(l_process_audit_id) );
        if (FND_LOG.LEVEL_ERROR >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
          FND_LOG.MESSAGE(FND_LOG.LEVEL_ERROR,
                       'cn.plsql.cn_calc_submission_pub.update_calc_submission.error',
	       		       false);
        end if;

	    x_loading_status := 'ALL_PROCESS_DONE_OK_LOG';
	 END IF;

	 FND_MSG_PUB.Add;
      END IF;
   END IF;  -- p_commit;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_UPDATED';

   --+
   -- End of API body.

   /*  Post processing     */
   --dbms_output.put_line('calling post processing API x_loading_status is ' || x_loading_status);
   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'A', 'V' ) then
      cn_calc_submission_VUHK.create_calc_submission_post
	(   	p_api_version              => p_api_version,
		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
                p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
		);
      if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
	 RAISE FND_API.G_EXC_ERROR;
       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
				RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
   end if;

   --dbms_output.put_line('vertical post processing API x_loading_status is ' || x_loading_status);

   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'A', 'C' ) then

      CN_CALC_SUBMISSION_CUHK.create_calc_submission_post
	( 	p_api_version              => p_api_version,
		p_init_msg_list		   => p_init_msg_list,
		p_commit	    	   => FND_API.G_FALSE,
		p_validation_level	   => p_validation_level,
		x_return_status		   => x_return_status,
		x_msg_count		   => x_msg_count,
		x_msg_data		   => x_msg_data,
		p_calc_submission_rec      => l_p_calc_submission_rec,
        	x_loading_status           => x_loading_status
       );
      if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
	 RAISE FND_API.G_EXC_ERROR;
       elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;
   end if;

   --  Following code is for message generation
   if JTF_USR_HKS.Ok_to_Execute( 'CN_CALC_SUBMISSION_PUB',
                                 'CREATE_CALC_SUBMISSION', 'M', 'M' ) then

      IF ( CN_CALC_SUBMISSION_CUHK.ok_to_generate_msg
	   ( p_calc_submission_rec    => l_p_calc_submission_rec )
	   ) THEN

	 l_bind_data_id := JTF_USR_HKS.get_bind_data_id;
	 JTF_USR_HKS.Load_Bind_Data(  l_bind_data_id, 'CALC_SUB_BATCH_ID',
				      l_calc_sub_batch_id, 'S', 'N'       );

	JTF_USR_HKS.generate_message( p_prod_code    => 'CN',
				      p_bus_obj_code => 'CALC_SUB',
				      p_bus_obj_name => 'CALC_SUBMISSION',
				      p_action_code  => 'U',     -- update
				      p_bind_data_id => l_bind_data_id,
				      x_return_code  => x_return_status
				      );

	 if ( x_return_status = FND_API.G_RET_STS_ERROR )  then
	    RAISE FND_API.G_EXC_ERROR;
	  elsif (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 end if;
      END IF;
   end if;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard check of p_commit.
   --   +
   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   --+
   -- Standard call to get message count and if count is 1, get message info.
   --+
   FND_MSG_PUB.Count_And_Get
     (
      p_count   =>  x_msg_count ,
      p_data    =>  x_msg_data  ,
      p_encoded => FND_API.G_FALSE
      );

   if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) then
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,
                    'cn.plsql.cn_calc_submission_pub.update_calc_submission.end',
	      		    'End of update_calc_submission.');
   end if;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_calc_submission;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_calc_submission;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get
	(
	 p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data   ,
	 p_encoded => FND_API.G_FALSE
	 );
   WHEN OTHERS THEN
      ROLLBACK TO update_calc_submission;
      x_loading_status := 'UNEXPECTED_ERR';
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
                         'cn.plsql.cn_calc_submission_pub.update_calc_submission.exception',
		       		     sqlerrm);
     end if;

END update_calc_submission;

END cn_calc_submission_pub ;

/
