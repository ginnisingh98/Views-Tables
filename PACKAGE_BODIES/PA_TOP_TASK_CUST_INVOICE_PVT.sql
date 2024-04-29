--------------------------------------------------------
--  DDL for Package Body PA_TOP_TASK_CUST_INVOICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TOP_TASK_CUST_INVOICE_PVT" AS
/* $Header: PATOPCIB.pls 120.3 2007/02/06 10:05:38 dthakker ship $ */

g_module_name   VARCHAR2(100) := 'PA_TOP_TASK_CUST_INVOICE_PVT';
Invalid_Arg_Exc EXCEPTION;

-- Procedure            : enbl_disbl_cust_at_top_task
-- Type                 : PRIVATE
-- Purpose              : Includes logic for updating various tables depending on whether the
--                        'Customer at Top Task' flag is disabled or enabled
-- Note                 :
-- Assumptions          :
-- Parameters                    Type      Required  Description and Purpose
-- ---------------------------  ------     --------  --------------------------------------------------------
-- p_mode                       VARCHAR2      Y      Describes whether flag is being disabled or enabled
-- p_project_id                 NUMBER        Y      Gives the Project id
-- p_def_top_task_cust          NUMBER        N      The customer to be set as default top task customer
-- p_contr_update_cust          NUMBER        N      The customer to be updated with 100% contribution
PROCEDURE enbl_disbl_cust_at_top_task(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
    	   , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_mode		          IN   VARCHAR2
        , p_project_id            IN   NUMBER
        , p_def_top_task_cust     IN   NUMBER
        , p_contr_update_cust     IN   NUMBER
        , x_return_status         OUT NOCOPY  VARCHAR2 -- 4537865 Added the nocopy hint
        , x_msg_count             OUT NOCOPY  NUMBER -- 4537865 Added the nocopy hint
        , x_msg_data              OUT NOCOPY VARCHAR2 -- 4537865 Added the nocopy hint
        ) IS

l_msg_count                     NUMBER := 0;
l_debug_mode                    VARCHAR2(1);
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;


--sunkalya:federal Bug#5511353

     l_orig_date_eff_funds_flag VARCHAR2(1);

     CURSOR get_date_eff_funds_flag( c_project_id IN NUMBER )
     IS
     SELECT
     nvl(DATE_EFF_FUNDS_CONSUMPTION,'N')
     FROM
     pa_projects_all
     WHERE project_id = c_project_id ;

--sunkalya:federal Bug#5511353

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        savepoint en_db_cust_at_top_task_pub;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'enbl_disbl_cust_at_top_task',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_mode'||':'||p_mode,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_def_top_task_cust'||':'||p_def_top_task_cust,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_contr_update_cust'||':'||p_contr_update_cust,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( ( p_mode		IS NULL OR p_mode              = FND_API.G_MISS_CHAR ) AND
          ( p_project_id	IS NULL OR p_project_id	       = FND_API.G_MISS_NUM  ) AND
          ( p_def_top_task_cust IS NULL OR p_def_top_task_cust = FND_API.G_MISS_NUM  ) AND
          ( p_contr_update_cust IS NULL OR p_contr_update_cust = FND_API.G_MISS_NUM  )
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : enbl_disbl_cust_at_top_task :
	                   p_mode, p_project_id, p_def_top_task_cust, p_contr_update_cust are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

  IF ( (p_mode       IS NOT NULL AND p_mode       <> FND_API.G_MISS_CHAR) AND
       (p_project_id IS NOT NULL AND p_project_id <> FND_API.G_MISS_NUM )
     ) THEN
	  IF p_mode = 'DISABLE' THEN


		  UPDATE pa_tasks SET customer_id = null
		  WHERE project_id = p_project_id;

		  UPDATE pa_project_customers SET default_top_task_cust_flag = 'N'
		  WHERE customer_id = p_def_top_task_cust AND project_id = p_project_id;

		 --sunkalya:federal Bug#5511353
		 --added the below logic as changing customer bill split
		 --depends now on date_eff_fields_consumption flag also. Sunkalya federal Bug#5511353

		  OPEN  get_date_eff_funds_flag(p_project_id);
		  FETCH get_date_eff_funds_flag INTO l_orig_date_eff_funds_flag;
		  CLOSE get_date_eff_funds_flag;

		  --sunkalya:federal Bug#5511353

		  IF l_orig_date_eff_funds_flag = 'N' THEN	--sunkalya:federal Bug#5511353

			UPDATE pa_project_customers SET customer_bill_split = 100
			WHERE customer_id = p_contr_update_cust AND project_id = p_project_id;

			UPDATE pa_project_customers SET customer_bill_split = 0
			WHERE customer_id <> p_contr_update_cust AND project_id = p_project_id;

		  END IF;

	  ELSIF p_mode = 'ENABLE' THEN
		  UPDATE pa_tasks SET customer_id = p_def_top_task_cust
		  WHERE project_id = p_project_id;

		  UPDATE pa_project_customers SET default_top_task_cust_flag = 'Y'
		  WHERE customer_id = p_def_top_task_cust AND project_id = p_project_id;

		  UPDATE pa_project_customers SET customer_bill_split = null
		  WHERE project_id = p_project_id;

            --Commented out call below for bug 3882790
            --Project_funding_level_flag is now set in project form itself
            /*IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Going to set project funding flag';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                               l_debug_level3);
            END IF;

            PA_TOP_TASK_CUST_INVOICE_PVT.set_top_task_funding_level(
                 p_api_version           => p_api_version
               , p_init_msg_list         => FND_API.G_FALSE
               , p_commit                => p_commit
               , p_validate_only         => p_validate_only
               , p_validation_level      => p_validation_level
               , p_calling_module        => p_calling_module
               , p_project_id            => p_project_id
               , x_return_status         => x_return_status
               , x_msg_count             => x_msg_count
               , x_msg_data              => x_msg_data
                                     );

		  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                    RAISE FND_API.G_EXC_ERROR;
            END IF;*/

       END IF;
  ELSE
       IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : enbl_disbl_cust_at_top_task :
                   Mandatory parameters p_mode or p_project_id are NULL';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                l_debug_level3);
       END IF;
       RAISE Invalid_Arg_Exc;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO en_db_cust_at_top_task_pub;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_TOP_TASK_CUST_INVOICE_PVT : enbl_disbl_cust_at_top_task : NULL parameters passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO en_db_cust_at_top_task_pub;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
                    , p_procedure_name  => 'enbl_disbl_cust_at_top_task'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO en_db_cust_at_top_task_pub;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
	    , p_procedure_name  => 'enbl_disbl_cust_at_top_task'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END enbl_disbl_cust_at_top_task;



-- Procedure            : Get_Highest_Contr_Cust
-- Type                 : PRIVATE
-- Purpose              : Gets the highest contribution customer. If contribution is same,
--                        then sorts on name and if names are also same, then sorts on
--                        customer id. It will not return the customers that are included in the
--                        p_exclude_cust_id_tbl PL/SQL table.
-- Note                 :
-- Assumptions          :
-- Parameters                   Type          Required    Description and Purpose
-- ---------------------------  ------        --------    --------------------------------------------------------
-- p_project_id                 NUMBER           Y        Project ID for which highest contribution customer is
--                                                        to be returned
-- p_exclude_cust_id_tbl SYSTEM.PA_NUM_TBL_TYPE  N        Customer IDs to be excluded while fetching highest contrib
--                                                        customer (Required during customer deletion)
-- x_highst_contr_cust_id       NUMBER           N        Customer ID of the highest contribution customer
-- x_highst_contr_cust_name     VARCHAR2         N        Customer Name of the highest contribution customer
-- x_highst_contr_cust_num      VARCHAR2         N        Customer Number of the highest contribution customer
PROCEDURE Get_Highest_Contr_Cust(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , p_exclude_cust_id_tbl   IN   PA_PLSQL_DATATYPES.NumTabTyp
        , x_highst_contr_cust_id   OUT NOCOPY NUMBER -- 4537865 Added the nocopy hint
        , x_highst_contr_cust_name OUT NOCOPY VARCHAR2 -- 4537865 Added the nocopy hint
        , x_highst_contr_cust_num  OUT NOCOPY VARCHAR2 -- 4537865 Added the nocopy hint
        , x_return_status         OUT  NOCOPY VARCHAR2 -- 4537865 Added the nocopy hint
        , x_msg_count             OUT  NOCOPY NUMBER -- 4537865 Added the nocopy hint
        , x_msg_data              OUT  NOCOPY VARCHAR2	 -- 4537865 Added the nocopy hint
        ) IS

l_msg_count             NUMBER := 0;
l_debug_mode            VARCHAR2(1);
l_data                  VARCHAR2(2000);
l_msg_data              VARCHAR2(2000);
l_msg_index_out         NUMBER;

l_debug_level2          CONSTANT NUMBER := 2;
l_debug_level3          CONSTANT NUMBER := 3;
l_debug_level4          CONSTANT NUMBER := 4;
l_debug_level5          CONSTANT NUMBER := 5;

l_return_cust_id_tbl    SYSTEM.PA_NUM_TBL_TYPE;
l_return_cust_name_tbl  SYSTEM.PA_VARCHAR2_80_TBL_TYPE;
l_return_cust_num_tbl   SYSTEM.PA_VARCHAR2_30_TBL_TYPE;
l_return_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE;

/* Changes for TCA
CURSOR cur_get_ordered_customers IS
SELECT ra_cust.customer_id , ra_cust.customer_name , ra_cust.customer_number, 'Y'
FROM  pa_project_customers proj_cust, ra_customers ra_cust
WHERE proj_cust.project_id = p_project_id
AND   proj_cust.customer_id = ra_cust.customer_id
ORDER BY proj_cust.customer_bill_split desc, ra_cust.customer_name, ra_cust.customer_number ;
*/

CURSOR cur_get_ordered_customers IS
SELECT HZ_C.cust_account_id , HZ_P.party_name , HZ_P.party_number, 'Y'
FROM  pa_project_customers proj_cust, hz_cust_accounts HZ_C, HZ_PARTIES HZ_P
WHERE proj_cust.project_id = p_project_id
AND   proj_cust.customer_id = hz_c.cust_account_id
AND   hz_c.party_id = hz_p.party_id
ORDER BY proj_cust.customer_bill_split desc, hz_p.party_name, HZ_P.party_number ;

BEGIN

  x_highst_contr_cust_id := null;
  x_highst_contr_cust_name := null;
  x_highst_contr_cust_num  := null;

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        savepoint get_highest_cont_cust_svpt;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'Get_Highest_Contr_Cust',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);

     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( p_project_id IS NULL    OR    p_project_id	= FND_API.G_MISS_NUM
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : Get_Highest_Contr_Cust :
	                    p_project_id is NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

    OPEN  cur_get_ordered_customers;
    FETCH cur_get_ordered_customers BULK COLLECT INTO l_return_cust_id_tbl, l_return_cust_name_tbl, l_return_cust_num_tbl, l_return_flag_tbl;
    CLOSE cur_get_ordered_customers;

    --If the return table is not NULL
    IF nvl(l_return_flag_tbl.LAST,0) > 0 THEN
        --If the exclude customer ids table passed is not NULL
        IF nvl(p_exclude_cust_id_tbl.LAST,0) > 0 THEN
            --Mark return flag as 'N' for all 'exclude customer ids' found in the return result set
             FOR i IN p_exclude_cust_id_tbl.FIRST..p_exclude_cust_id_tbl.LAST LOOP
                FOR j IN l_return_cust_id_tbl.FIRST..l_return_cust_id_tbl.LAST LOOP
                    IF p_exclude_cust_id_tbl(i) = l_return_cust_id_tbl(j) THEN
                        l_return_flag_tbl(j) := 'N';
                    END IF;
                END LOOP;
             END LOOP;
        END IF;

        --Return the first record that has return flag as 'Y'
        FOR i IN l_return_flag_tbl.FIRST..l_return_flag_tbl.LAST LOOP
            IF l_return_flag_tbl(i) = 'Y' THEN
                x_highst_contr_cust_id   := l_return_cust_id_tbl(i);
                x_highst_contr_cust_name := l_return_cust_name_tbl(i);
                x_highst_contr_cust_num  := l_return_cust_num_tbl(i);
                EXIT;
            END IF;
        END LOOP;
    END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     -- 4537865 RESET OUT PARAMS
     x_highst_contr_cust_id := null;
     x_highst_contr_cust_name := null;
     x_highst_contr_cust_num  := null;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO get_highest_cont_cust_svpt;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_TOP_TASK_CUST_INVOICE_PVT : Get_Highest_Contr_Cust : NULL parameters passed';

     -- 4537865 RESET OUT PARAMS
     x_highst_contr_cust_id := null;
     x_highst_contr_cust_name := null;
     x_highst_contr_cust_num  := null;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO get_highest_cont_cust_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
                    , p_procedure_name  => 'Get_Highest_Contr_Cust'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     -- 4537865 RESET OUT PARAMS
     x_highst_contr_cust_id := null;
     x_highst_contr_cust_name := null;
     x_highst_contr_cust_num  := null;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO get_highest_cont_cust_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
	    , p_procedure_name  => 'Get_Highest_Contr_Cust'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Get_Highest_Contr_Cust;



-- Procedure            : Set_Rev_Acc_At_Top_Task
-- Type                 : PRIVATE
-- Purpose              : To set the revenue accrual method in PA_TASKS table
-- Note                 :
-- Assumptions          :
-- Parameters                   Type     Required    Description and Purpose
-- ---------------------------  ------   --------    --------------------------------------------------------
-- p_project_id                 NUMBER      Y        Project ID for which revenue accrual method is to be set
-- p_rev_acc                    VARCHAR2    Y        The revenue accrual method that is to be set
PROCEDURE Set_Rev_Acc_At_Top_Task(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , p_rev_acc               IN   VARCHAR2
        , x_return_status         OUT  NOCOPY VARCHAR2 -- 4537865
        , x_msg_count             OUT  NOCOPY NUMBER -- 4537865
        , x_msg_data              OUT  NOCOPY VARCHAR2	 -- 4537865
	  ) IS

l_msg_count                     NUMBER := 0;
l_debug_mode                    VARCHAR2(1);
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        savepoint Set_Rev_Acc_At_Top_Task_svpt;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'Set_Rev_Acc_At_Top_Task',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_rev_acc'||':'||p_rev_acc,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( (p_project_id IS NULL    OR    p_project_id	= FND_API.G_MISS_NUM) AND
          (p_rev_acc    IS NULL    OR    p_rev_acc 	= FND_API.G_MISS_CHAR)
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : Set_Rev_Acc_At_Top_Task :
	                    p_project_id and p_rev_acc are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

  IF ( (p_project_id IS NOT NULL    AND    p_project_id	<> FND_API.G_MISS_NUM) AND
       (p_rev_acc    IS NOT NULL    AND    p_rev_acc	<> FND_API.G_MISS_CHAR)
     ) THEN

	  UPDATE pa_tasks SET revenue_accrual_method = p_rev_acc
	  WHERE project_id = p_project_id;

  ELSE
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : Set_Rev_Acc_At_Top_Task :
	                   Mandatory parameters p_project_id or p_rev_acc are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          END IF;
          RAISE Invalid_Arg_Exc;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO Set_Rev_Acc_At_Top_Task_svpt;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_TOP_TASK_CUST_INVOICE_PVT : Set_Rev_Acc_At_Top_Task : NULL parameters passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO Set_Rev_Acc_At_Top_Task_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
                    , p_procedure_name  => 'Set_Rev_Acc_At_Top_Task'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO Set_Rev_Acc_At_Top_Task_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
	    , p_procedure_name  => 'Set_Rev_Acc_At_Top_Task'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Set_Rev_Acc_At_Top_Task;



-- Procedure            : Set_Inv_Mth_At_Top_Task
-- Type                 : PRIVATE
-- Purpose              : To set the invoice method in PA_TASKS table
-- Note                 :
-- Assumptions          :
-- Parameters                   Type     Required    Description and Purpose
-- ---------------------------  ------   --------    --------------------------------------------------------
-- p_project_id                 NUMBER      Y        Project ID for which invoice method is to be set
-- p_inv_mth                    VARCHAR2    Y        The invoice method that is to be set
PROCEDURE Set_Inv_Mth_At_Top_Task(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
        , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , p_inv_mth               IN   VARCHAR2
        , x_return_status         OUT  NOCOPY VARCHAR2 -- 4537865
        , x_msg_count             OUT  NOCOPY NUMBER -- 4537865
        , x_msg_data              OUT  NOCOPY VARCHAR2	 -- 4537865
	) IS

l_msg_count                     NUMBER := 0;
l_debug_mode                    VARCHAR2(1);
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        savepoint Set_Inv_Mth_At_Top_Task_svpt;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'Set_Inv_Mth_At_Top_Task',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_inv_mth'||':'||p_inv_mth,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( (p_project_id IS NULL    OR    p_project_id	= FND_API.G_MISS_NUM) AND
          (p_inv_mth    IS NULL    OR    p_inv_mth 	= FND_API.G_MISS_CHAR)
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : Set_Inv_Mth_At_Top_Task :
	                    p_project_id and p_inv_mth are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

  IF ( (p_project_id IS NOT NULL    AND    p_project_id	<> FND_API.G_MISS_NUM) AND
       (p_inv_mth    IS NOT NULL    AND    p_inv_mth	<> FND_API.G_MISS_CHAR)
     ) THEN

	  UPDATE pa_tasks SET invoice_method = p_inv_mth
	  WHERE project_id = p_project_id;
  ELSE
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : Set_Inv_Mth_At_Top_Task :
	                   Mandatory parameters p_project_id or p_inv_mth are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          END IF;
          RAISE Invalid_Arg_Exc;
  END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
      COMMIT;
  END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO Set_Inv_Mth_At_Top_Task_svpt;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_TOP_TASK_CUST_INVOICE_PVT : Set_Inv_Mth_At_Top_Task : NULL parameters passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO Set_Inv_Mth_At_Top_Task_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
                    , p_procedure_name  => 'Set_Inv_Mth_At_Top_Task'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO Set_Inv_Mth_At_Top_Task_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
	    , p_procedure_name  => 'Set_Inv_Mth_At_Top_Task'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END Set_Inv_Mth_At_Top_Task;



-- Procedure            : set_top_task_funding_level
-- Type                 : PRIVATE
-- Purpose              :
-- Note                 :
-- Assumptions          :
-- Parameters                   Type     Required    Description and Purpose
-- ---------------------------  ------   --------    --------------------------------------------------------
-- p_project_id                 NUMBER      Y        Project ID for which funding flag is to be set
PROCEDURE set_top_task_funding_level(
          p_api_version           IN   NUMBER   := 1.0
        , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only         IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
    	   , p_debug_mode            IN   VARCHAR2 := 'N'
        , p_project_id            IN   NUMBER
        , x_return_status         OUT  NOCOPY VARCHAR2 -- 4537865
        , x_msg_count             OUT  NOCOPY NUMBER -- 4537865
        , x_msg_data              OUT  NOCOPY VARCHAR2	 -- 4537865
	) IS

l_msg_count                     NUMBER := 0;
l_debug_mode                    VARCHAR2(1);
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

l_funding_level varchar2(1);
l_err_code      number;
l_err_stage     varchar2(100);
l_err_stack     varchar2(700);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        savepoint set_top_tsk_funding_lvl_svpt;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'set_top_task_funding_level',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( (p_project_id IS NULL    OR    p_project_id	= FND_API.G_MISS_NUM)
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : set_top_task_funding_level :
	                    p_project_id is NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Going to set project funding flag to N';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
	     	       l_debug_level3);
     END IF;

     --Commented out code below for bug 3882790
     /*pa_billing_core.check_funding_level(p_project_id,
   				         l_funding_level,
   				         l_err_code,
				         l_err_stage,
				         l_err_stack);
     IF l_funding_level = 'P' AND l_err_code = 0 THEN*/
     UPDATE pa_projects_all SET project_level_funding_flag = 'N'
     WHERE project_id = p_project_id;
     --END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
         COMMIT;
     END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO set_top_tsk_funding_lvl_svpt;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_TOP_TASK_CUST_INVOICE_PVT : set_top_task_funding_level : NULL parameters passed';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO set_top_tsk_funding_lvl_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
                    , p_procedure_name  => 'set_top_task_funding_level'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO set_top_tsk_funding_lvl_svpt;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   ( p_pkg_name         => 'PA_TOP_TASK_CUST_INVOICE_PVT'
	    , p_procedure_name  => 'set_top_task_funding_level'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END set_top_task_funding_level;




-- Procedure            : check_customer_assoc
-- Type                 : PRIVATE
-- Purpose              : Check for customer associations with tasks or whether the customer is default
--                        top task customer and update tables accordingly
-- Note                 : This API should be called only if Customer_At_Top_Task is enabled for the project
-- Assumptions          : This API is called from self-service during customer deletion only when
--                        customer_at_top_task is enabled for the project
-- Parameters                   Type     Required    Description and Purpose
-- ---------------------------  ------   --------    --------------------------------------------------------
-- p_project_id                 NUMBER      Y        Project ID for which customer is being deleted
-- p_customer_id                NUMBER      Y        Customer ID which is being deleted
-- x_cust_assoc                 VARCHAR2             "T" if customer is associated with tasks
--                                                   "D" if customer is default top task customer
-- x_cust_id                    NUMBER               Customer ID of (new) default top task customer
-- x_cust_name                  VARCHAR2             Customer Name of (new) default top task customer
-- x_cust_num                   VARCHAR2             Customer Number of the (new) default top task customer
PROCEDURE check_delete_customer(
          p_api_version      IN   NUMBER   := 1.0
        , p_init_msg_list    IN   VARCHAR2 := FND_API.G_TRUE
        , p_commit           IN   VARCHAR2 := FND_API.G_FALSE
        , p_validate_only    IN   VARCHAR2 := FND_API.G_TRUE
        , p_validation_level IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
        , p_calling_module   IN   VARCHAR2 := 'SELF_SERVICE'
    	   , p_debug_mode       IN   VARCHAR2 := 'N'
        , p_project_id       IN   NUMBER
        , p_customer_id      IN   NUMBER
        , x_cust_assoc       OUT  NOCOPY VARCHAR2 -- 4537865
        , x_cust_id          OUT  NOCOPY NUMBER -- 4537865
        , x_cust_name        OUT  NOCOPY VARCHAR2 -- 4537865
        , x_cust_num         OUT  NOCOPY VARCHAR2 -- 4537865
        , x_return_status    OUT NOCOPY VARCHAR2 -- 4537865
        , x_msg_count        OUT NOCOPY NUMBER -- 4537865
        , x_msg_data         OUT NOCOPY VARCHAR2 -- 4537865
                                ) IS
  CURSOR task_assoc_exists IS
  SELECT 'Y'
  FROM  PA_TASKS
  WHERE project_id  = p_project_id
  AND   customer_id = p_customer_id;

/* Changes for TCA
  CURSOR cur_get_top_task_customer IS
  SELECT ppc.customer_id, rc.customer_name, rc.customer_number
  FROM   pa_project_customers ppc, ra_customers rc
  WHERE  ppc.project_id = p_project_id
  AND    ppc.default_top_task_cust_flag = 'Y'
  AND    ppc.customer_id = rc.customer_id ;
*/

  CURSOR cur_get_top_task_customer IS
  SELECT ppc.customer_id, hz_p.party_name, hz_p.party_number
  FROM   pa_project_customers ppc, hz_cust_accounts HZ_C, hz_parties HZ_P
  WHERE  ppc.project_id = p_project_id
  AND    ppc.default_top_task_cust_flag = 'Y'
  AND    ppc.customer_id = hz_c.cust_account_id
  AND    hz_c.party_id = hz_p.party_id;

  l_msg_count                     NUMBER := 0;
  l_debug_mode                    VARCHAR2(1);
  l_data                          VARCHAR2(2000);
  l_msg_data                      VARCHAR2(2000);
  l_msg_index_out                 NUMBER;

  l_debug_level2                   CONSTANT NUMBER := 2;
  l_debug_level3                   CONSTANT NUMBER := 3;
  l_debug_level4                   CONSTANT NUMBER := 4;
  l_debug_level5                   CONSTANT NUMBER := 5;

  l_task_assoc_exists      VARCHAR2(1)  := 'N' ;
  l_def_top_task_cust_id   NUMBER;
  l_def_top_task_cust_name VARCHAR2(50);
  l_def_top_task_cust_num  VARCHAR2(30);

  l_exclude_cust_id_tbl   PA_PLSQL_DATATYPES.NumTabTyp;

BEGIN

     x_msg_count     := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode    := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
        savepoint check_delete_customer;
     END IF;

     IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function( p_function   => 'check_delete_customer',
                                    p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Printing Input parameters';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                   l_debug_level3);

        Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                   l_debug_level3);
        Pa_Debug.WRITE(g_module_name,'p_customer_id'||':'||p_customer_id,
                                   l_debug_level3);
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Validating Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( (p_project_id  IS NULL    OR    p_project_id	 = FND_API.G_MISS_NUM) AND
          (p_customer_id IS NULL    OR    p_customer_id = FND_API.G_MISS_NUM)
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TOP_TASK_CUST_INVOICE_PVT : check_delete_customer :
	                    p_project_id AND p_customer_id are NULL';
               Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc;
     END IF;

    OPEN  task_assoc_exists;
    FETCH task_assoc_exists INTO l_task_assoc_exists;
    CLOSE task_assoc_exists;

    OPEN  cur_get_top_task_customer;
    FETCH cur_get_top_task_customer INTO l_def_top_task_cust_id, l_def_top_task_cust_name, l_def_top_task_cust_num;
    CLOSE cur_get_top_task_customer;

    l_exclude_cust_id_tbl(1) := p_customer_id;

    IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'Checking for associations';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
	     	       l_debug_level3);
    END IF;

    IF 'Y' = l_task_assoc_exists AND l_def_top_task_cust_id <> p_customer_id THEN
          x_cust_assoc  := 'T';
          x_cust_id     := l_def_top_task_cust_id;
          x_cust_name   := l_def_top_task_cust_name;
          x_cust_num    := l_def_top_task_cust_num;

          UPDATE pa_tasks SET customer_id = l_def_top_task_cust_id
          WHERE project_id  = p_project_id
          AND   customer_id = p_customer_id ;
    ELSIF 'Y' = l_task_assoc_exists AND l_def_top_task_cust_id = p_customer_id THEN
          pa_top_task_cust_invoice_pvt.Get_Highest_Contr_Cust( P_API_VERSION            => 1.0
                                                             , P_INIT_MSG_LIST          => 'T'
                                                             , P_COMMIT                 => 'F'
                                                             , P_VALIDATE_ONLY          => 'F'
                                                             , P_VALIDATION_LEVEL       => 100
                                                             , P_DEBUG_MODE             => 'N'
                                                             , p_project_id             => p_project_id
                         							 , p_exclude_cust_id_tbl    => l_exclude_cust_id_tbl
                                                             , x_highst_contr_cust_id   => x_cust_id
                                                             , x_highst_contr_cust_name => x_cust_name
                                                             , x_highst_contr_cust_num  => x_cust_num
                                                             , x_return_status  => x_return_status
                                                             , x_msg_count      => x_msg_count
                                                             , x_msg_data       => x_msg_data );
          IF 'S' = x_return_status THEN

               UPDATE pa_tasks SET customer_id = x_cust_id
               WHERE project_id  = p_project_id
               AND   customer_id = p_customer_id ;

               IF x_cust_id IS NOT NULL THEN
                    x_cust_assoc  := 'T';
                    UPDATE pa_project_customers SET default_top_task_cust_flag = 'Y'
                    WHERE  project_id = p_project_id
                    AND    customer_id = x_cust_id;
               END IF;

          END IF;
    ELSIF 'Y' <> l_task_assoc_exists AND l_def_top_task_cust_id = p_customer_id THEN
          pa_top_task_cust_invoice_pvt.Get_Highest_Contr_Cust( P_API_VERSION            => 1.0
                                                             , P_INIT_MSG_LIST          => 'T'
                                                             , P_COMMIT                 => 'F'
                                                             , P_VALIDATE_ONLY          => 'F'
                                                             , P_VALIDATION_LEVEL       => 100
                                                             , P_DEBUG_MODE             => 'N'
                                                             , p_project_id             => p_project_id
                         							 , p_exclude_cust_id_tbl    => l_exclude_cust_id_tbl
                                                             , x_highst_contr_cust_id   => x_cust_id
                                                             , x_highst_contr_cust_name => x_cust_name
                                                             , x_highst_contr_cust_num  => x_cust_num
                                                             , x_return_status  => x_return_status
                                                             , x_msg_count      => x_msg_count
                                                             , x_msg_data       => x_msg_data );
          IF 'S' = x_return_status AND x_cust_id IS NOT NULL THEN
               x_cust_assoc  := 'D';
               UPDATE pa_project_customers SET default_top_task_cust_flag = 'Y'
               WHERE  project_id = p_project_id
               AND    customer_id = x_cust_id;
          END IF;
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
        COMMIT;
    END IF;
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;

     -- 4537865 : RESET OUT PARAMS
     x_cust_assoc       := NULL ;
     x_cust_id          := NULL ;
     x_cust_name        := NULL ;
     x_cust_num         := NULL ;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO check_customer_delete;
     END IF;

     l_msg_count := Fnd_Msg_Pub.count_msg;
     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_FALSE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := ' PA_TOP_TASK_CUST_INVOICE_PVT : check_delete_customer : NULL parameters passed';

     -- 4537865 : RESET OUT PARAMS
     x_cust_assoc       := NULL ;
     x_cust_id          := NULL ;
     x_cust_name        := NULL ;
     x_cust_num         := NULL ;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO check_delete_customer;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   (  p_pkg_name        => 'PA_TOP_TASK_CUST_INVOICE_PVT'
                    , p_procedure_name  => 'check_delete_customer'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                       l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     -- 4537865 : RESET OUT PARAMS
     x_cust_assoc       := NULL ;
     x_cust_id          := NULL ;
     x_cust_name        := NULL ;
     x_cust_num         := NULL ;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO check_delete_customer;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
	   (  p_pkg_name        => 'PA_TOP_TASK_CUST_INVOICE_PVT'
	    , p_procedure_name  => 'check_delete_customer'
	    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE( g_module_name,Pa_Debug.g_err_stage,
                          l_debug_level5 );
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END check_delete_customer;

END PA_TOP_TASK_CUST_INVOICE_PVT;

/
