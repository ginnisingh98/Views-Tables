--------------------------------------------------------
--  DDL for Package Body PA_FP_FCST_GEN_CLIENT_EXT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_FCST_GEN_CLIENT_EXT" as
/* $Header: PAFPFGCB.pls 120.2 2007/02/06 09:52:44 dthakker ship $ */
P_PA_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');

PROCEDURE FCST_GEN_CLIENT_EXTN
  (P_PROJECT_ID    		IN NUMBER
   ,P_BUDGET_VERSION_ID 		IN NUMBER
   ,P_RESOURCE_ASSIGNMENT_ID	IN NUMBER
   ,P_TASK_ID			IN NUMBER
   ,P_TASK_PERCENT_COMPLETE      IN NUMBER
   ,P_PROJECT_PERCENT_COMPLETE	IN NUMBER
   ,P_RESOURCE_LIST_MEMBER_ID	IN NUMBER
   ,P_UNIT_OF_MEASURE           IN PA_RESOURCE_ASSIGNMENTS.UNIT_OF_MEASURE%TYPE
   ,P_TXN_CURRENCY_CODE		IN VARCHAR2
   ,P_ETC_QTY			IN NUMBER
   ,P_ETC_RAW_COST		IN NUMBER
   ,P_ETC_BURDENED_COST	        IN NUMBER
   ,P_ETC_REVENUE		IN NUMBER
   ,P_ETC_SOURCE		        IN VARCHAR2
   ,P_ETC_GEN_METHOD  		IN VARCHAR2
   ,P_ACTUAL_THRU_DATE		IN DATE
   ,P_ETC_START_DATE		IN DATE
   ,P_ETC_END_DATE		IN DATE
   ,P_PLANNED_WORK_QTY		IN  NUMBER
   ,P_ACTUAL_WORK_QTY		IN NUMBER
   ,P_ACTUAL_QTY			IN NUMBER
   ,P_ACTUAL_RAW_COST		IN NUMBER
   ,P_ACTUAL_BURDENED_COST	IN NUMBER
   ,P_ACTUAL_REVENUE		IN NUMBER
   ,P_PERIOD_RATES_TBL		IN l_pds_rate_dtls_tab
   -- Start Bug 5726785
   ,p_override_raw_cost_rate   IN  pa_resource_asgn_curr.txn_raw_cost_rate_override%TYPE
   ,p_override_burd_cost_rate  IN  pa_resource_asgn_curr.txn_burden_cost_rate_override%TYPE
   ,p_override_bill_rate       IN  pa_resource_asgn_curr.txn_bill_rate_override%TYPE
   ,p_avg_raw_cost_rate        IN  pa_resource_asgn_curr.txn_average_raw_cost_rate%TYPE
   ,p_avg_burd_cost_rate       IN  pa_resource_asgn_curr.txn_average_burden_cost_rate%TYPE
   ,p_avg_bill_rate            IN  pa_resource_asgn_curr.txn_average_bill_rate%TYPE
   ,px_period_amts_tbl         IN  OUT NOCOPY l_plan_txn_prd_amt_tbl
   ,px_period_data_modified    IN  OUT NOCOPY VARCHAR2
  -- End Bug 5726785
   ,X_ETC_QTY			OUT NOCOPY NUMBER
   ,X_ETC_RAW_COST		OUT NOCOPY NUMBER
   ,X_ETC_BURDENED_COST		OUT NOCOPY NUMBER
   ,X_ETC_REVENUE		OUT NOCOPY NUMBER
   ,X_PERIOD_RATES_TBL		OUT NOCOPY l_pds_rate_dtls_tab
   ,X_RETURN_STATUS		OUT NOCOPY VARCHAR2
   ,X_MSG_DATA			OUT NOCOPY VARCHAR2
   ,X_MSG_COUNT			OUT NOCOPY NUMBER) IS

l_module_name         VARCHAR2(200) := 'pa.plsql.pa_fp_fcst_gen_client_ext.fcst_gen_client_extn';

l_ret_status                VARCHAR2(100);
l_msg_count                 NUMBER;
l_msg_data                  VARCHAR2(2000);
l_data                      VARCHAR2(2000);
l_msg_index_out             NUMBER:=0;

BEGIN
   --Setting initial values
   X_MSG_COUNT := 0;
   X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

   IF p_pa_debug_mode = 'Y' THEN
            pa_debug.set_curr_function( p_function     => 'FCST_GEN_CLIENT_EXTN'
                                       ,p_debug_mode   =>  p_pa_debug_mode);
   END IF;

-- This would the default value for px_period_data modified.
 	     px_period_data_modified := 'N';

    X_ETC_QTY		:= P_ETC_QTY;
    X_ETC_RAW_COST	:= P_ETC_RAW_COST;
    X_ETC_BURDENED_COST	:= P_ETC_BURDENED_COST;
    X_ETC_REVENUE	:= P_ETC_REVENUE;

    IF p_period_rates_tbl.count > 0 and
       x_period_rates_tbl.count = 0 THEN
	FOR j IN 1..p_period_rates_tbl.count LOOP
	    x_period_rates_tbl(j).period_name := p_period_rates_tbl(j).period_name;
	    x_period_rates_tbl(j).raw_cost_rate := p_period_rates_tbl(j).raw_cost_rate;
	    x_period_rates_tbl(j).burdened_cost_rate := p_period_rates_tbl(j).burdened_cost_rate;
	    x_period_rates_tbl(j).revenue_bill_rate := p_period_rates_tbl(j).revenue_bill_rate;
	END LOOP;
    END IF;

--If the periodic data has to be modified px_period_data has to be set to 'Y'
 	 --and the value can be modified inside the loop

 	     FOR j IN 1..px_period_amts_tbl.count LOOP
 	         px_period_amts_tbl(j).period_name := px_period_amts_tbl(j).period_name;
 	         px_period_amts_tbl(j).etc_quantity := px_period_amts_tbl(j).etc_quantity ;
 	         px_period_amts_tbl(j).txn_raw_cost := px_period_amts_tbl(j).txn_raw_cost;
 	         px_period_amts_tbl(j).txn_burdened_cost := px_period_amts_tbl(j).txn_burdened_cost;
 	         px_period_amts_tbl(j).txn_revenue := px_period_amts_tbl(j).txn_revenue;
 	         px_period_amts_tbl(j).init_quantity := px_period_amts_tbl(j).init_quantity;
 	         px_period_amts_tbl(j).init_raw_cost := px_period_amts_tbl(j).init_raw_cost;
 	         px_period_amts_tbl(j).init_revenue := px_period_amts_tbl(j).init_revenue;
 	         px_period_amts_tbl(j).init_revenue := px_period_amts_tbl(j).init_revenue;
 	     END LOOP;

    IF p_pa_debug_mode = 'Y' THEN
         pa_debug.Reset_Curr_Function;
    END IF;

EXCEPTION
   WHEN PA_FP_CONSTANTS_PKG.Invalid_Arg_Exc THEN
   -- Bug Fix: 4569365. Removed MRC code.
     -- PA_MRC_FINPLAN.G_CALLING_MODULE := Null;
      l_msg_count := FND_MSG_PUB.count_msg;
      IF x_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
                 (p_encoded        => FND_API.G_TRUE
                  ,p_msg_index      => 1
                  ,p_msg_count      => l_msg_count
                  ,p_msg_data       => l_msg_data
                  ,p_data           => l_data
                  ,p_msg_index_out  => l_msg_index_out);
           x_msg_data := l_data;
           x_msg_count := l_msg_count;
      ELSE
          x_msg_count := l_msg_count;
      END IF;
      ROLLBACK;
      x_return_status := FND_API.G_RET_STS_ERROR;

     IF p_pa_debug_mode = 'Y' THEN
          pa_debug.Reset_Curr_Function;
     END IF;

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_data      := SUBSTR(SQLERRM,1,240);
      -- dbms_output.put_line('inside excep create res asg');
      -- dbms_output.put_line(SUBSTR(SQLERRM,1,240));
     FND_MSG_PUB.add_exc_msg
             ( p_pkg_name       => 'PA_FP_FCST_GEN_CLIENT_EXT'
              ,p_procedure_name => 'FCST_GEN_CLIENT_EXTN');
     IF p_pa_debug_mode = 'Y' THEN
         pa_debug.Reset_Curr_Function;
     END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END FCST_GEN_CLIENT_EXTN;

END PA_FP_FCST_GEN_CLIENT_EXT;

/
