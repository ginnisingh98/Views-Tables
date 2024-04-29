--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_HDR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_HDR_PKG" as
--/* $Header: PARFFIHB.pls 120.2 2005/08/19 16:51:21 mwasowic noship $ */
   l_empty_tab_record  EXCEPTION;  --  Variable to raise the exception if  the passing table of records is empty


-- This procedure will insert the record in pa_forecast_items  table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Forecast_Hdr_Tab           FIHDRTABTYP      YES       It contains the forecast items record for header
--

PROCEDURE insert_rows ( p_forecast_hdr_tab             IN  PA_FORECAST_GLOB.FIHdrTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
 l_forecast_item_id                 PA_PLSQL_DATATYPES.IdTabTyp;
 l_forecast_item_type               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_project_org_id                   PA_PLSQL_DATATYPES.IdTabTyp;
 l_expenditure_org_id               PA_PLSQL_DATATYPES.IdTabTyp;
 l_expenditure_organization_id      PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_organization_id          PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_id                       PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_type_class               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_person_id                        PA_PLSQL_DATATYPES.IdTabTyp;
 l_resource_id                      PA_PLSQL_DATATYPES.IdTabTyp;
 l_borrowed_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_assignment_id                    PA_PLSQL_DATATYPES.IdTabTyp;
 l_item_date                        PA_PLSQL_DATATYPES.DateTabTyp;
 l_item_uom                         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_item_quantity                    PA_PLSQL_DATATYPES.NumTabTyp;
 l_pvdr_period_set_name             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pvdr_pa_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pvdr_gl_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_period_set_name             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_pa_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_gl_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_global_exp_period_end_date       PA_PLSQL_DATATYPES.DateTabTyp;
 l_expenditure_type                 PA_PLSQL_DATATYPES.Char30TabTyp;
 l_expenditure_type_class           PA_PLSQL_DATATYPES.Char30TabTyp;
 l_cost_rejection_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rev_rejection_code               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_tp_rejection_code                PA_PLSQL_DATATYPES.Char30TabTyp;
 l_burden_rejection_code            PA_PLSQL_DATATYPES.Char30TabTyp;
 l_other_rejection_code             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_delete_flag                      PA_PLSQL_DATATYPES.Char1TabTyp;
 l_provisional_flag                 PA_PLSQL_DATATYPES.Char1TabTyp;
 l_error_flag                       PA_PLSQL_DATATYPES.Char1TabTyp;
 l_JOB_ID            PA_PLSQL_DATATYPES.NumTabTyp;
 l_TP_AMOUNT_TYPE            PA_PLSQL_DATATYPES.Char30TabTyp;
 l_OVERPROVISIONAL_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVER_PROV_CONF_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_CONFIRMED_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROVISIONAL_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_asgmt_sys_status_code            PA_PLSQL_DATATYPES.Char30TabTyp;
 l_capacity_quantity                PA_PLSQL_DATATYPES.NumTabTyp;
 l_overcommitment_quantity          PA_PLSQL_DATATYPES.NumTabTyp;
 l_availability_quantity            PA_PLSQL_DATATYPES.NumTabTyp;
 l_overcommitment_flag              PA_PLSQL_DATATYPES.Char1TabTyp;
 l_availability_flag                PA_PLSQL_DATATYPES.Char1TabTyp;

 l_fi_rejected     EXCEPTION;
 lv_rejection_code VARCHAR2(30);
 l_msg_index_out  NUMBER;
 -- added for Bug Fix 4537865
 l_new_msg_data    VARCHAR2(2000);
 -- added for Bug Fix 4537865
 /* Bug 2390990 Begin */
 l_tmp_forecast_item_type pa_forecast_items.forecast_item_type%TYPE;
 l_start_date_found BOOLEAN;
 l_end_date_found BOOLEAN;
 l_start_date  pa_forecast_items.item_date%TYPE;
 l_end_date    pa_forecast_items.item_date%TYPE;
 l_token   VARCHAR2(1000);
 l_fi_rejected_prd_missing    EXCEPTION;
 /*  Bug 2390990 End */

BEGIN

PA_DEBUG.Init_err_stack( 'PA_FORECAST_HDR_PKG.Insert_Rows');

x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Checking for the empty table of record */
   IF (nvl(p_forecast_hdr_tab.count,0) = 0 ) THEN
     PA_FORECASTITEM_PVT.print_message('count 0 ... before return ... ');
     RAISE l_empty_tab_record;
   END IF;

  PA_FORECASTITEM_PVT.print_message('start of the forecast inser row .... ');

FOR l_j IN p_forecast_hdr_tab.FIRST .. p_forecast_hdr_tab.LAST LOOP
 if (p_forecast_hdr_tab(l_j).error_flag = 'Y') then
    PA_FORECASTITEM_PVT.print_message('Errors');
    if (p_forecast_hdr_tab(l_j).cost_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).cost_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).rev_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).rev_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).tp_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).tp_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).burden_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).burden_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).other_rejection_code is not null) then
      lv_rejection_code := p_forecast_hdr_tab(l_j).other_rejection_code;

       /* Bug239090 Begin */
      l_tmp_forecast_item_type := p_forecast_hdr_tab(l_j).forecast_item_type;
      l_start_date_found := FALSE;
      IF (lv_rejection_code = 'PVDR_GL_PRD_NAME_NOT_FOUND' OR lv_rejection_code='PVDR_PA_PRD_NAME_NOT_FOUND'
         OR lv_rejection_code='RCVR_GL_PRD_NAME_NOT_FOUND' OR lv_rejection_code='RCVR_PA_PRD_NAME_NOT_FOUND') THEN

	   FOR l_k IN l_j .. p_forecast_hdr_tab.LAST LOOP

		IF (p_forecast_hdr_tab(l_k).other_rejection_code = lv_rejection_code ) THEN
		    IF (l_start_date_found =FALSE) THEN
 		        l_start_date_found := TRUE;
		        l_start_date := p_forecast_hdr_tab(l_k).item_date;
			l_end_date_found := FALSE;
                    END IF;
 	            IF l_k=p_forecast_hdr_tab.LAST THEN
	    	        l_end_date := p_forecast_hdr_tab(l_k).item_date;
			    IF l_end_date <> l_start_date THEN
			        IF l_token is null THEN
				   l_token := l_start_date||' - '||l_end_date;
		                ELSE
   				   l_token := l_token||', '||l_start_date||' - '||l_end_date;
				END IF;
		             ELSE
			        IF l_token is null THEN
				   l_token := l_start_date;
				ELSE
	   			   l_token := l_token||', '||l_start_date;
		                END IF;
			     END IF;
		    END IF;
	        ELSE
		    IF (l_end_date_found = FALSE) THEN
			    l_start_date_found:=FALSE;
			    l_end_date_found := TRUE;
 			    l_end_date := p_forecast_hdr_tab(l_k-1).item_date;
			    IF l_end_date <> l_start_date THEN
			        IF l_token is null THEN
				   l_token := l_start_date||' - '||l_end_date;
		                ELSE
   				   l_token := l_token||', '||l_start_date||' - '||l_end_date;
				END IF;
		             ELSE
			        IF l_token is null THEN
				   l_token := l_start_date;
				ELSE
	   			   l_token := l_token||', '||l_start_date;
		                END IF;
			     END IF;
                      END IF;
		   END IF;
		 END LOOP;

	     IF lv_rejection_code = 'PVDR_PA_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'PVDR_PA_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'PVDR_PA_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'PVDR_PA_PRD_U_NOT_FOUND_DTS';
                END IF;
	     ELSIF lv_rejection_code = 'PVDR_GL_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'PVDR_GL_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'PVDR_GL_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'PVDR_GL_PRD_U_NOT_FOUND_DTS';
                END IF;
	     ELSIF lv_rejection_code = 'RCVR_PA_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'RCVR_PA_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'RCVR_PA_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'RCVR_PA_PRD_U_NOT_FOUND_DTS';
                END IF;
	     ELSIF lv_rejection_code = 'RCVR_GL_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'RCVR_GL_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'RCVR_GL_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'RCVR_GL_PRD_U_NOT_FOUND_DTS';
                END IF;
	     END IF;

	     raise l_fi_rejected_prd_missing;
	END IF;
	/* Bug2390990 End */
      raise l_fi_rejected;
    end if;
 end if;

 l_forecast_item_id(l_J)                 := p_forecast_hdr_tab(l_j).forecast_item_id;
 l_forecast_item_type(l_j)               := p_forecast_hdr_tab(l_j).forecast_item_type;
 l_project_org_id(l_j)                   := p_forecast_hdr_tab(l_j).project_org_id;
 l_expenditure_org_id(l_j)               := p_forecast_hdr_tab(l_j).expenditure_org_id;
 l_expenditure_organization_id(l_j)      := p_forecast_hdr_tab(l_j).expenditure_organization_id;
 l_project_organization_id(l_j)          := p_forecast_hdr_tab(l_j).project_organization_id;
 l_project_id(l_j)                       := p_forecast_hdr_tab(l_j).project_id;
 l_project_type_class(l_j)               := p_forecast_hdr_tab(l_j).project_type_class;
 l_person_id(l_j)                        := p_forecast_hdr_tab(l_j).person_id;
 l_resource_id(l_j)                      := p_forecast_hdr_tab(l_j).resource_id;
 l_borrowed_flag(l_j)                    := p_forecast_hdr_tab(l_j).borrowed_flag;
 l_assignment_id(l_j)                    := p_forecast_hdr_tab(l_j).assignment_id;
 l_item_date(l_j)                        := trunc(p_forecast_hdr_tab(l_j).item_date);
 l_item_uom(l_j)                         := p_forecast_hdr_tab(l_j).item_uom;
 l_item_quantity(l_j)                    := p_forecast_hdr_tab(l_j).item_quantity;
 l_pvdr_period_set_name(l_j)             := p_forecast_hdr_tab(l_j).pvdr_period_set_name;
 l_pvdr_pa_period_name(l_j)              := p_forecast_hdr_tab(l_j).pvdr_pa_period_name;
 l_pvdr_gl_period_name(l_j)              := p_forecast_hdr_tab(l_j).pvdr_gl_period_name;
 l_rcvr_period_set_name(l_j)             := p_forecast_hdr_tab(l_j).rcvr_period_set_name;
 l_rcvr_pa_period_name(l_j)              := p_forecast_hdr_tab(l_j).rcvr_pa_period_name;
 l_rcvr_gl_period_name(l_j)              := p_forecast_hdr_tab(l_j).rcvr_gl_period_name;
 l_global_exp_period_end_date(l_j)       := trunc(p_forecast_hdr_tab(l_j).global_exp_period_end_date);
 l_expenditure_type(l_j)                 := p_forecast_hdr_tab(l_j).expenditure_type;
 l_expenditure_type_class(l_j)           := p_forecast_hdr_tab(l_j).expenditure_type_class;
 l_cost_rejection_code(l_j)              := p_forecast_hdr_tab(l_j).cost_rejection_code;
 l_rev_rejection_code(l_j)               := p_forecast_hdr_tab(l_j).rev_rejection_code;
 l_tp_rejection_code(l_j)                := p_forecast_hdr_tab(l_j).tp_rejection_code;
 l_burden_rejection_code(l_j)            := p_forecast_hdr_tab(l_j).burden_rejection_code;
 l_other_rejection_code(l_j)             := p_forecast_hdr_tab(l_j).other_rejection_code;
 l_delete_flag(l_j)                      := p_forecast_hdr_tab(l_j).delete_flag;
 l_provisional_flag(l_j)                 := p_forecast_hdr_tab(l_j).provisional_flag;
 l_error_flag(l_j)                       := p_forecast_hdr_tab(l_j).error_flag;
 l_JOB_ID(l_j)            := p_forecast_hdr_tab(l_j).JOB_ID;
 l_TP_AMOUNT_TYPE(l_j)            := p_forecast_hdr_tab(l_j).TP_AMOUNT_TYPE;
 l_OVERPROVISIONAL_QTY(l_j)            := p_forecast_hdr_tab(l_j).OVERPROVISIONAL_QTY;
 l_OVER_PROV_CONF_QTY(l_j)            := p_forecast_hdr_tab(l_j).OVER_PROV_CONF_QTY;
 l_CONFIRMED_QTY(l_j)            := p_forecast_hdr_tab(l_j).CONFIRMED_QTY;
 l_PROVISIONAL_QTY(l_j)            := p_forecast_hdr_tab(l_j).PROVISIONAL_QTY;
 l_asgmt_sys_status_code(l_j)            := p_forecast_hdr_tab(l_j).asgmt_sys_status_code;
 l_capacity_quantity(l_j)                := p_forecast_hdr_tab(l_j).capacity_quantity;
 l_overcommitment_quantity(l_j)          := p_forecast_hdr_tab(l_j).overcommitment_quantity;
 l_availability_quantity(l_j)            := p_forecast_hdr_tab(l_j).availability_quantity;
 l_overcommitment_flag(l_j)              := p_forecast_hdr_tab(l_j).overcommitment_flag;
 l_availability_flag(l_j)                := p_forecast_hdr_tab(l_j).availability_flag;
END LOOP;


 PA_FORECASTITEM_PVT.print_message('act ins ');
FORALL l_j IN p_forecast_hdr_tab.FIRST..p_forecast_hdr_tab.LAST
 INSERT INTO PA_FORECAST_ITEMS
      (
	 forecast_item_id                 ,
   	 forecast_item_type               ,
 	 project_org_id                   ,
 	 expenditure_org_id               ,
 	 expenditure_organization_id      ,
 	 project_organization_id          ,
 	 project_id                       ,
 	 project_type_class               ,
 	 person_id                        ,
 	 resource_id                      ,
 	 borrowed_flag                    ,
 	 assignment_id                    ,
 	 item_date                        ,
 	 item_uom                         ,
 	 item_quantity                    ,
 	 pvdr_period_set_name             ,
 	 pvdr_pa_period_name              ,
 	 pvdr_gl_period_name              ,
 	 rcvr_period_set_name             ,
 	 rcvr_pa_period_name              ,
 	 rcvr_gl_period_name              ,
 	 global_exp_period_end_date       ,
 	 expenditure_type                 ,
 	 expenditure_type_class           ,
 	 cost_rejection_code              ,
 	 rev_rejection_code               ,
 	 tp_rejection_code                ,
 	 burden_rejection_code            ,
 	 other_rejection_code             ,
 	 delete_flag                      ,
 	 provisional_flag                 ,
 	 error_flag                       ,
   JOB_ID            ,
   TP_AMOUNT_TYPE            ,
   OVERPROVISIONAL_QTY            ,
   OVER_PROV_CONF_QTY            ,
   CONFIRMED_QTY            ,
   PROVISIONAL_QTY            ,
   asgmt_sys_status_code            ,
   capacity_quantity                ,
   overcommitment_quantity          ,
   availability_quantity            ,
   overcommitment_flag              ,
   availability_flag                ,
         creation_date              ,
         created_by                       ,
         last_update_date                 ,
         last_updated_by                  ,
         last_update_login                ,
         request_id                       ,
         program_application_id           ,
         program_id                       ,
         program_update_date,
         FORECAST_AMT_CALC_FLAG)
 VALUES (
        l_forecast_item_id(l_J)                                ,
        l_forecast_item_type(l_j)                              ,
        l_project_org_id(l_j)                                  ,
        l_expenditure_org_id(l_j)                              ,
        l_expenditure_organization_id(l_j)                     ,
        l_project_organization_id(l_j)                         ,
        l_project_id(l_j)                                      ,
        l_project_type_class(l_j)                              ,
        l_person_id(l_j)                                       ,
        l_resource_id(l_j)                                     ,
        l_borrowed_flag(l_j)                                   ,
        l_assignment_id(l_j)                                   ,
        l_item_date(l_j)                                       ,
        l_item_uom(l_j)                                        ,
        l_item_quantity(l_j)                                   ,
        l_pvdr_period_set_name(l_j)                            ,
        l_pvdr_pa_period_name(l_j)                             ,
        l_pvdr_gl_period_name(l_j)                             ,
        l_rcvr_period_set_name(l_j)                            ,
        l_rcvr_pa_period_name(l_j)                             ,
        l_rcvr_gl_period_name(l_j)                             ,
        l_global_exp_period_end_date(l_j)                      ,
        l_expenditure_type(l_j)                                ,
        l_expenditure_type_class(l_j)                          ,
        l_cost_rejection_code(l_j)                             ,
        l_rev_rejection_code(l_j)                              ,
        l_tp_rejection_code(l_j)                               ,
        l_burden_rejection_code(l_j)                           ,
        l_other_rejection_code(l_j)                            ,
        l_delete_flag(l_j)                                     ,
        l_provisional_flag(l_j)                                ,
        l_error_flag(l_j)                                      ,
        l_JOB_ID(l_j)                           ,
        l_TP_AMOUNT_TYPE(l_j)                           ,
        l_OVERPROVISIONAL_QTY(l_j)                           ,
        l_OVER_PROV_CONF_QTY(l_j)                           ,
        l_CONFIRMED_QTY(l_j)                           ,
        l_PROVISIONAL_QTY(l_j)                           ,
        l_asgmt_sys_status_code(l_j)                           ,
        nvl(l_capacity_quantity(l_j),0)                               ,
        l_overcommitment_quantity(l_j)                         ,
        l_availability_quantity(l_j)                           ,
        l_overcommitment_flag(l_j)                             ,
        l_availability_flag(l_j)                               ,
        sysdate                                              ,
        fnd_global.user_id                                   ,
        sysdate                                              ,
        fnd_global.user_id                                   ,
        fnd_global.login_id                                  ,
        fnd_global.conc_request_id()                         ,
        fnd_global.prog_appl_id   ()                         ,
        fnd_global.conc_program_id()                         ,
        trunc(sysdate)                                       ,
         'N');

 --    PA_FORECAST_ITEMS_UTLS.log_message('end   of the forecast inser row .... ');
             PA_DEBUG.Reset_Err_Stack;
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
/* Bug 2390990 Begin */
   WHEN l_fi_rejected_prd_missing THEN
	 PA_UTILS.add_message(p_app_short_name => 'PA',
	                      p_msg_name       => lv_rejection_code,
			      p_token1         => 'DATE_LIST',
			      p_value1         => l_token);
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 x_msg_data      := lv_rejection_code;
	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
		pa_interface_utils_pub.get_messages
		       (p_encoded        => FND_API.G_TRUE,
			p_msg_index      => 1,
			p_msg_count      => x_msg_count,
			p_msg_data       => x_msg_data,
		      --p_data           => x_msg_data,	* commenetd for Bug: 4537865
			p_data		 => l_new_msg_data, --added for Bug 4537865
			p_msg_index_out  => l_msg_index_out );
		-- added for Bug Fix: 4537865
			x_msg_data := l_new_msg_data;
		 -- added for Bug Fix: 4537865
	 End If;
/* Bug 2390990 End */
 WHEN l_fi_rejected then
		 PA_UTILS.add_message('PA',lv_rejection_code);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := lv_rejection_code;
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				--      p_data           => x_msg_data,		* added for Bug 4537865
					p_data	         => l_new_msg_data,	-- added for bug 4537865
						p_msg_index_out  => l_msg_index_out );
		 -- added for bug 4537865
		 x_msg_data := l_new_msg_data;
		 -- added for bug 4537865
		 End If;
 WHEN OTHERS THEN
  x_msg_count := 1;
  x_msg_data  := SQLERRM;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg
       (p_pkg_name   => 'PA_FORECAST_HDR_PKG.Insert_Rows',
        p_procedure_name => PA_DEBUG.G_Err_Stack);

  RAISE;

--  PA_FORECAST_ITEMS_UTLS.log_message('ERROR ....'||sqlerrm);
END insert_rows;

-- This procedure will update  the record in pa_forecast_items table
-- Input parameters
-- Parameters                Type                Required  Description
-- P_Forecast_Hdr_Tab        FIHDRTABTYP         YES       It contains the forecast items record for header
--
PROCEDURE update_rows ( p_forecast_hdr_tab             IN  PA_FORECAST_GLOB.FIHdrTabTyp,
                        x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                            OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
 l_forecast_item_id                 PA_PLSQL_DATATYPES.IdTabTyp;
 l_forecast_item_type               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_project_org_id                   PA_PLSQL_DATATYPES.IdTabTyp;
 l_expenditure_org_id               PA_PLSQL_DATATYPES.IdTabTyp;
 l_expenditure_organization_id      PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_organization_id          PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_id                       PA_PLSQL_DATATYPES.IdTabTyp;
 l_project_type_class               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_person_id                        PA_PLSQL_DATATYPES.IdTabTyp;
 l_resource_id                      PA_PLSQL_DATATYPES.IdTabTyp;
 l_borrowed_flag                    PA_PLSQL_DATATYPES.Char1TabTyp;
 l_assignment_id                    PA_PLSQL_DATATYPES.IdTabTyp;
 l_item_date                        PA_PLSQL_DATATYPES.DateTabTyp;
 l_item_uom                         PA_PLSQL_DATATYPES.Char30TabTyp;
 l_item_quantity                    PA_PLSQL_DATATYPES.NumTabTyp;
 l_pvdr_period_set_name             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pvdr_pa_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_pvdr_gl_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_period_set_name             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_pa_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rcvr_gl_period_name              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_global_exp_period_end_date       PA_PLSQL_DATATYPES.DateTabTyp;
 l_expenditure_type                 PA_PLSQL_DATATYPES.Char30TabTyp;
 l_expenditure_type_class           PA_PLSQL_DATATYPES.Char30TabTyp;
 l_cost_rejection_code              PA_PLSQL_DATATYPES.Char30TabTyp;
 l_rev_rejection_code               PA_PLSQL_DATATYPES.Char30TabTyp;
 l_tp_rejection_code                PA_PLSQL_DATATYPES.Char30TabTyp;
 l_burden_rejection_code            PA_PLSQL_DATATYPES.Char30TabTyp;
 l_other_rejection_code             PA_PLSQL_DATATYPES.Char30TabTyp;
 l_delete_flag                      PA_PLSQL_DATATYPES.Char1TabTyp;
 l_provisional_flag                 PA_PLSQL_DATATYPES.Char1TabTyp;
 l_error_flag                       PA_PLSQL_DATATYPES.Char1TabTyp;
 l_JOB_ID            PA_PLSQL_DATATYPES.NumTabTyp;
 l_TP_AMOUNT_TYPE            PA_PLSQL_DATATYPES.Char30TabTyp;
 l_OVERPROVISIONAL_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_OVER_PROV_CONF_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_CONFIRMED_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_PROVISIONAL_QTY            PA_PLSQL_DATATYPES.NumTabTyp;
 l_asgmt_sys_status_code            PA_PLSQL_DATATYPES.Char30TabTyp;
 l_capacity_quantity                PA_PLSQL_DATATYPES.NumTabTyp;
 l_overcommitment_quantity          PA_PLSQL_DATATYPES.NumTabTyp;
 l_availability_quantity            PA_PLSQL_DATATYPES.NumTabTyp;
 l_overcommitment_flag              PA_PLSQL_DATATYPES.Char1TabTyp;
 l_availability_flag                PA_PLSQL_DATATYPES.Char1TabTyp;

 l_fi_rejected     EXCEPTION;
 lv_rejection_code VARCHAR2(30);
 l_msg_index_out  NUMBER;
  -- added for bug 4537865
 l_new_msg_data		VARCHAR2(2000);
   -- added for bug 4537865
 /* Bug 2390990 Begin */
 l_tmp_forecast_item_type pa_forecast_items.forecast_item_type%TYPE;
 l_start_date_found BOOLEAN;
 l_end_date_found BOOLEAN;
 l_start_date  pa_forecast_items.item_date%TYPE;
 l_end_date    pa_forecast_items.item_date%TYPE;
 l_token   VARCHAR2(1000);
 l_fi_rejected_prd_missing    EXCEPTION;
 /*  Bug 2390990 End */


BEGIN
  PA_DEBUG.Init_err_stack( 'PA_FORECAST_HDR_PKG.Update_Rows');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Checking for the empty table of record */
  IF (nvl(p_forecast_hdr_tab.count,0) = 0 ) THEN
    PA_FORECASTITEM_PVT.print_message('count 0 ... before return ... ');
    RAISE l_empty_tab_record;
  END IF;

  PA_FORECASTITEM_PVT.print_message('start of the forecast update row .... ');

FOR l_J IN p_forecast_hdr_tab.FIRST..p_forecast_hdr_tab.LAST LOOP
 if (p_forecast_hdr_tab(l_j).error_flag = 'Y' and nvl(p_forecast_hdr_tab(l_j).delete_flag,'N') <> 'Y') then -- added second condition for bug 4254376
    PA_FORECASTITEM_PVT.print_message('Errors');
    if (p_forecast_hdr_tab(l_j).cost_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).cost_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).rev_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).rev_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).tp_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).tp_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).burden_rejection_code is not null) then
       lv_rejection_code := p_forecast_hdr_tab(l_j).burden_rejection_code;
       raise l_fi_rejected;
    end if;
    if (p_forecast_hdr_tab(l_j).other_rejection_code is not null) then
      lv_rejection_code := p_forecast_hdr_tab(l_j).other_rejection_code;
       /* Bug239090 Begin */
      l_tmp_forecast_item_type := p_forecast_hdr_tab(l_j).forecast_item_type;
      l_start_date_found := FALSE;
      IF (lv_rejection_code = 'PVDR_GL_PRD_NAME_NOT_FOUND' OR lv_rejection_code='PVDR_PA_PRD_NAME_NOT_FOUND'
         OR lv_rejection_code='RCVR_GL_PRD_NAME_NOT_FOUND' OR lv_rejection_code='RCVR_PA_PRD_NAME_NOT_FOUND') THEN

	   FOR l_k IN l_j .. p_forecast_hdr_tab.LAST LOOP

		IF (p_forecast_hdr_tab(l_k).other_rejection_code = lv_rejection_code ) THEN
		    IF (l_start_date_found =FALSE) THEN
 		        l_start_date_found := TRUE;
		        l_start_date := p_forecast_hdr_tab(l_k).item_date;
			l_end_date_found := FALSE;
                    END IF;
 	            IF l_k=p_forecast_hdr_tab.LAST THEN
	    	        l_end_date := p_forecast_hdr_tab(l_k).item_date;
			    IF l_end_date <> l_start_date THEN
			        IF l_token is null THEN
				   l_token := l_start_date||' - '||l_end_date;
		                ELSE
   				   l_token := l_token||', '||l_start_date||' - '||l_end_date;
				END IF;
		             ELSE
			        IF l_token is null THEN
				   l_token := l_start_date;
				ELSE
	   			   l_token := l_token||', '||l_start_date;
		                END IF;
			     END IF;
		    END IF;
	        ELSE
		    IF (l_end_date_found = FALSE) THEN
			    l_start_date_found:=FALSE;
			    l_end_date_found := TRUE;
 			    l_end_date := p_forecast_hdr_tab(l_k-1).item_date;
			    IF l_end_date <> l_start_date THEN
			        IF l_token is null THEN
				   l_token := l_start_date||' - '||l_end_date;
		                ELSE
   				   l_token := l_token||', '||l_start_date||' - '||l_end_date;
				END IF;
		             ELSE
			        IF l_token is null THEN
				   l_token := l_start_date;
				ELSE
	   			   l_token := l_token||', '||l_start_date;
		                END IF;
			     END IF;
                      END IF;
		   END IF;
		 END LOOP;

	     IF lv_rejection_code = 'PVDR_PA_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'PVDR_PA_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'PVDR_PA_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'PVDR_PA_PRD_U_NOT_FOUND_DTS';
                END IF;
	     ELSIF lv_rejection_code = 'PVDR_GL_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'PVDR_GL_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'PVDR_GL_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'PVDR_GL_PRD_U_NOT_FOUND_DTS';
                END IF;
	     ELSIF lv_rejection_code = 'RCVR_PA_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'RCVR_PA_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'RCVR_PA_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'RCVR_PA_PRD_U_NOT_FOUND_DTS';
                END IF;
	     ELSIF lv_rejection_code = 'RCVR_GL_PRD_NAME_NOT_FOUND' THEN
	        IF l_tmp_forecast_item_type = 'A' THEN
			lv_rejection_code := 'RCVR_GL_PRD_A_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'R' THEN
			lv_rejection_code := 'RCVR_GL_PRD_R_NOT_FOUND_DTS';
                ELSIF l_tmp_forecast_item_type = 'U' THEN
		        lv_rejection_code := 'RCVR_GL_PRD_U_NOT_FOUND_DTS';
                END IF;
	     END IF;

	     raise l_fi_rejected_prd_missing;
	END IF;
	/* Bug2390990 End */

      raise l_fi_rejected;
    end if;
 end if;

 l_forecast_item_id(l_J)                 := p_forecast_hdr_tab(l_j).forecast_item_id;
 l_forecast_item_type(l_j)               := p_forecast_hdr_tab(l_j).forecast_item_type;
 l_project_org_id(l_j)                   := p_forecast_hdr_tab(l_j).project_org_id;
 l_expenditure_org_id(l_j)               := p_forecast_hdr_tab(l_j).expenditure_org_id;
 l_expenditure_organization_id(l_j)      := p_forecast_hdr_tab(l_j).expenditure_organization_id;
 l_project_organization_id(l_j)          := p_forecast_hdr_tab(l_j).project_organization_id;
 l_project_id(l_j)                       := p_forecast_hdr_tab(l_j).project_id;
 l_project_type_class(l_j)               := p_forecast_hdr_tab(l_j).project_type_class;
 l_person_id(l_j)                        := p_forecast_hdr_tab(l_j).person_id;
 l_resource_id(l_j)                      := p_forecast_hdr_tab(l_j).resource_id;
 l_borrowed_flag(l_j)                    := p_forecast_hdr_tab(l_j).borrowed_flag;
 l_assignment_id(l_j)                    := p_forecast_hdr_tab(l_j).assignment_id;
 l_item_date(l_j)                        := trunc(p_forecast_hdr_tab(l_j).item_date);
 l_item_uom(l_j)                         := p_forecast_hdr_tab(l_j).item_uom;
 l_item_quantity(l_j)                    := p_forecast_hdr_tab(l_j).item_quantity;
 l_pvdr_period_set_name(l_j)             := p_forecast_hdr_tab(l_j).pvdr_period_set_name;
 l_pvdr_pa_period_name(l_j)              := p_forecast_hdr_tab(l_j).pvdr_pa_period_name;
 l_pvdr_gl_period_name(l_j)              := p_forecast_hdr_tab(l_j).pvdr_gl_period_name;
 l_rcvr_period_set_name(l_j)             := p_forecast_hdr_tab(l_j).rcvr_period_set_name;
 l_rcvr_pa_period_name(l_j)              := p_forecast_hdr_tab(l_j).rcvr_pa_period_name;
 l_rcvr_gl_period_name(l_j)              := p_forecast_hdr_tab(l_j).rcvr_gl_period_name;
 l_global_exp_period_end_date(l_j)       := trunc(p_forecast_hdr_tab(l_j).global_exp_period_end_date);
 l_expenditure_type(l_j)                 := p_forecast_hdr_tab(l_j).expenditure_type;
 l_expenditure_type_class(l_j)           := p_forecast_hdr_tab(l_j).expenditure_type_class;
 l_cost_rejection_code(l_j)              := p_forecast_hdr_tab(l_j).cost_rejection_code;
 l_rev_rejection_code(l_j)               := p_forecast_hdr_tab(l_j).rev_rejection_code;
 l_tp_rejection_code(l_j)                := p_forecast_hdr_tab(l_j).tp_rejection_code;
 l_burden_rejection_code(l_j)            := p_forecast_hdr_tab(l_j).burden_rejection_code;
 l_other_rejection_code(l_j)             := p_forecast_hdr_tab(l_j).other_rejection_code;
 l_delete_flag(l_j)                      := p_forecast_hdr_tab(l_j).delete_flag;
 l_provisional_flag(l_j)                 := p_forecast_hdr_tab(l_j).provisional_flag;
 l_error_flag(l_j)                       := p_forecast_hdr_tab(l_j).error_flag;
 l_JOB_ID(l_j)            := p_forecast_hdr_tab(l_j).JOB_ID;
 l_TP_AMOUNT_TYPE(l_j)            := p_forecast_hdr_tab(l_j).TP_AMOUNT_TYPE;
 l_OVERPROVISIONAL_QTY(l_j)            := p_forecast_hdr_tab(l_j).OVERPROVISIONAL_QTY;
 l_OVER_PROV_CONF_QTY(l_j)            := p_forecast_hdr_tab(l_j).OVER_PROV_CONF_QTY;
 l_CONFIRMED_QTY(l_j)            := p_forecast_hdr_tab(l_j).CONFIRMED_QTY;
 l_PROVISIONAL_QTY(l_j)            := p_forecast_hdr_tab(l_j).PROVISIONAL_QTY;
 l_asgmt_sys_status_code(l_j)            := p_forecast_hdr_tab(l_j).asgmt_sys_status_code;
 l_capacity_quantity(l_j)                := p_forecast_hdr_tab(l_j).capacity_quantity;
 l_overcommitment_quantity(l_j)          := p_forecast_hdr_tab(l_j).overcommitment_quantity;
 l_availability_quantity(l_j)            := p_forecast_hdr_tab(l_j).availability_quantity;
 l_overcommitment_flag(l_j)              := p_forecast_hdr_tab(l_j).overcommitment_flag;
 l_availability_flag(l_j)                := p_forecast_hdr_tab(l_j).availability_flag;

END LOOP;

FORALL l_J IN p_forecast_hdr_tab.FIRST..p_forecast_hdr_tab.LAST
 UPDATE PA_FORECAST_ITEMS
 SET
 	forecast_item_type               = l_forecast_item_type(l_j)		,
 	project_org_id                   = l_project_org_id(l_j)		,
 	expenditure_org_id               = l_expenditure_org_id(l_j)		,
 	expenditure_organization_id      = l_expenditure_organization_id(l_j)	,
 	project_organization_id          = l_project_organization_id(l_j)	,
 	project_id                       = l_project_id(l_j)			,
 	project_type_class               = l_project_type_class(l_j)		,
 	person_id                        = l_person_id(l_j)			,
 	resource_id                      = l_resource_id(l_j)			,
 	borrowed_flag                    = l_borrowed_flag(l_j)			,
 	assignment_id                    = l_assignment_id(l_j)			,
 	item_date                        = l_item_date(l_j)			,
 	item_uom                         = l_item_uom(l_j)			,
 	item_quantity                    = l_item_quantity(l_j)			,
 	pvdr_period_set_name             = l_pvdr_period_set_name(l_j)		,
 	pvdr_pa_period_name              = l_pvdr_pa_period_name(l_j)		,
 	pvdr_gl_period_name              = l_pvdr_gl_period_name(l_j)		,
 	rcvr_period_set_name             = l_rcvr_period_set_name(l_j)		,
 	rcvr_pa_period_name              = l_rcvr_pa_period_name(l_j)		,
 	rcvr_gl_period_name              = l_rcvr_gl_period_name(l_j)		,
 	global_exp_period_end_date       = l_global_exp_period_end_date(l_j)	,
 	expenditure_type                 = l_expenditure_type(l_j)		,
 	expenditure_type_class           = l_expenditure_type_class(l_j)	,
 	cost_rejection_code              = l_cost_rejection_code(l_j)		,
 	rev_rejection_code               = l_rev_rejection_code(l_j)		,
 	tp_rejection_code                = l_tp_rejection_code(l_j)		,
 	burden_rejection_code            = l_burden_rejection_code(l_j)		,
 	other_rejection_code             = l_other_rejection_code(l_j)		,
 	delete_flag                      = l_delete_flag(l_j)			,
 	provisional_flag                 = l_provisional_flag(l_j)		,
 	error_flag                       = l_error_flag(l_j)			,
   JOB_ID           = l_JOB_ID(l_j)      ,
   TP_AMOUNT_TYPE           = l_TP_AMOUNT_TYPE(l_j)      ,
   OVERPROVISIONAL_QTY           = l_OVERPROVISIONAL_QTY(l_j)      ,
   OVER_PROV_CONF_QTY           = l_OVER_PROV_CONF_QTY(l_j)      ,
   CONFIRMED_QTY           = l_CONFIRMED_QTY(l_j)      ,
   PROVISIONAL_QTY           = l_PROVISIONAL_QTY(l_j)      ,
   asgmt_sys_status_code           = l_asgmt_sys_status_code(l_j)      ,
   capacity_quantity               = nvl(l_capacity_quantity(l_j),0),
   overcommitment_quantity         = l_overcommitment_quantity(l_j),
   availability_quantity           = l_availability_quantity(l_j),
   overcommitment_flag             = l_overcommitment_flag(l_j),
   availability_flag               = l_availability_flag(l_j),
        last_update_date        	 = sysdate 				,
        last_updated_by          	 = fnd_global.user_id			,
        last_update_login       	 = fnd_global.login_id ,
         FORECAST_AMT_CALC_FLAG = 'N',
	       COST_TXN_CURRENCY_CODE = null,
	       REVENUE_TXN_CURRENCY_CODE = null,
	       TXN_RAW_COST = null,
	       TXN_BURDENED_COST = null,
	       TXN_REVENUE = null,
	       TP_TXN_CURRENCY_CODE = null,
	       TXN_TRANSFER_PRICE = null,
	       PROJECT_CURRENCY_CODE = null,
	       PROJECT_RAW_COST = null,
	       PROJECT_BURDENED_COST = null,
	       PROJECT_REVENUE = null	,
	       PROJECT_TRANSFER_PRICE = null	,
	       PROJFUNC_CURRENCY_CODE = null,
	       PROJFUNC_RAW_COST = null,
	       PROJFUNC_BURDENED_COST = null,
	       PROJFUNC_REVENUE = null,
	       PROJFUNC_TRANSFER_PRICE = null,
	       EXPFUNC_CURRENCY_CODE = null,
	       EXPFUNC_RAW_COST = null,
	       EXPFUNC_BURDENED_COST = null,
	       EXPFUNC_TRANSFER_PRICE = null
         WHERE  forecast_item_id                 = l_forecast_item_id(l_j);

 PA_FORECASTITEM_PVT.print_message('end of update row .... ');
 PA_DEBUG.Reset_Err_Stack;
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
/* Bug 2390990 Begin */
   WHEN l_fi_rejected_prd_missing THEN
	 PA_UTILS.add_message(p_app_short_name => 'PA',
	                      p_msg_name       => lv_rejection_code,
			      p_token1         => 'DATE_LIST',
			      p_value1         => l_token);
	 x_return_status := FND_API.G_RET_STS_ERROR;
	 x_msg_data      := lv_rejection_code;
	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
		pa_interface_utils_pub.get_messages
		       (p_encoded        => FND_API.G_TRUE,
			p_msg_index      => 1,
			p_msg_count      => x_msg_count,
			p_msg_data       => x_msg_data,
		      --p_data           => x_msg_data,		* added for bug 4537865
			p_data		 => l_new_msg_data,	-- added for bug 4537865
			p_msg_index_out  => l_msg_index_out );
		-- added for bug 4537865
		x_msg_data := l_new_msg_data;
		-- added for bug 4537865
	 End If;
/* Bug 2390990 End */

 WHEN l_fi_rejected then
		 PA_UTILS.add_message('PA',lv_rejection_code);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := lv_rejection_code;
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* commented for Bug 4537865
					p_data		 => l_new_msg_data,	-- added for bug 4537865
						p_msg_index_out  => l_msg_index_out );
				 -- added for bug 4537865
				 x_msg_data := l_new_msg_data;
				 -- added for bug 4537865
		 End If;
 WHEN OTHERS THEN
  x_msg_count := 1;
  x_msg_data  := SQLERRM;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg
       (p_pkg_name   => 'PA_FORECAST_HDR_PKG.Update_Rows',
        p_procedure_name => PA_DEBUG.G_Err_Stack);
  RAISE;


 PA_FORECASTITEM_PVT.print_message('ERROR in update row '||sqlerrm);
END update_rows;

-- This procedure will update  the record in pa_schedules table
-- Input parameters
-- Parameters                Type                Required  Description
-- P_Sch_Record_Tab          ScheduleTabTyp      YES       It contains the schedule record
--
PROCEDURE update_schedule_rows ( p_schedule_tab                        IN  PA_FORECAST_GLOB.ScheduleTabTyp,
                                 x_return_status                       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count                           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data                            OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
 l_schedule_id                      PA_PLSQL_DATATYPES.IdTabTyp;
 l_forecast_txn_version_number      PA_PLSQL_DATATYPES.NumTabTyp;


BEGIN
  PA_DEBUG.Init_err_stack( 'PA_FORECAST_HDR_PKG.Update_Schedule_Rows');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /* Checking for the empty table of record */
  IF (nvl(p_schedule_tab.count,0) = 0 ) THEN
    PA_FORECASTITEM_PVT.print_message('count 0 ... before return ... ');
    RAISE l_empty_tab_record;
  END IF;

  PA_FORECASTITEM_PVT.print_message('start of the schedule inser row .... ');

 FOR l_j IN p_schedule_tab.FIRST .. p_schedule_tab.LAST LOOP
   PA_FORECASTITEM_PVT.print_message('inside loop');
   l_schedule_id(l_j)                 := p_schedule_tab(l_j).schedule_id;
   l_forecast_txn_version_number(l_j) := p_schedule_tab(l_j).forecast_txn_version_number ;

 END LOOP;

PA_FORECASTITEM_PVT.print_message('after loop');
FORALL l_j IN p_schedule_tab.FIRST..p_schedule_tab.LAST
 UPDATE PA_SCHEDULES
 SET
 	forecast_txn_version_number            = NVL(l_forecast_txn_version_number(l_j),0) + 1           ,
 	forecast_txn_generated_flag            = 'Y'                                        ,
        last_update_date                 = sysdate 			              ,
        last_update_by                   = fnd_global.user_id                         ,
        last_update_login                = fnd_global.login_id
 WHERE  schedule_id                      = l_schedule_id(l_j)
  AND   forecast_txn_version_number      = l_forecast_txn_version_number(l_j);

PA_FORECASTITEM_PVT.print_message('after update');
 PA_DEBUG.Reset_Err_Stack;
-- PA_FORECASTITEM_PVT.print_message('end of update schedule row .... ');
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_msg_count := 1;
  x_msg_data  := SQLERRM;
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.add_exc_msg
       (p_pkg_name   => 'PA_FORECAST_HDR_PKG.Update_Schedule_Rows',
        p_procedure_name => PA_DEBUG.G_Err_Stack);
  RAISE;

 PA_FORECASTITEM_PVT.print_message('ERROR in update row '||sqlerrm);
END update_schedule_rows;

PROCEDURE update_rows(p_assignment_id IN NUMBER,
                 p_forecast_amt_calc_flag IN VARCHAR2,
                 x_return_status    OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                 x_msg_count        OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                 x_msg_data         OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

 l_msg_index_out  NUMBER;
 l_new_msg_data	  VARCHAR2(2000);

BEGIN
   update pa_forecast_items
   set
     forecast_amt_calc_flag = 'N'
   where assignment_id = p_assignment_id;

EXCEPTION

              WHEN OTHERS THEN
                  PA_FORECASTITEM_PVT.print_message('Failed in update_rows api');
                  PA_FORECASTITEM_PVT.print_message('SQLCODE'||sqlcode||sqlerrm);

                   x_msg_count     := 1;
                   x_msg_data      := sqlerrm;
                   FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                              'PA_FORECAST_HDR_PKG.update_rows',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
                   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

		               If x_msg_count = 1 THEN
				              pa_interface_utils_pub.get_messages
				                (p_encoded        => FND_API.G_TRUE,
					               p_msg_index      => 1,
					               p_msg_count      => x_msg_count,
					               p_msg_data       => x_msg_data,
					               -- p_data           => x_msg_data, * commented for Bug: 4537865
						       p_data		=> l_new_msg_data, -- added for bug 4537865
					               p_msg_index_out  => l_msg_index_out );
				-- added for bug 4537865
				x_msg_data := l_new_msg_data;
				-- added for bug 4537865
		               End If;

                   PA_FORECASTITEM_PVT.Print_message(x_msg_data);

                   RAISE;

END update_rows;

END PA_FORECAST_HDR_PKG;

/
