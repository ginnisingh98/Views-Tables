--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_API_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_API_PUB" as
/*$Header: PACIAMPB.pls 120.1 2006/11/24 09:05:31 vgottimu noship $*/


g_module_name     VARCHAR2(100) := 'pa.plsql.PA_CONTROL_API_PUB';


l_debug_mode                 VARCHAR2(1);
l_debug_level3               CONSTANT NUMBER := 3;




CURSOR Check_Valid_CI (c_Ci_Id NUMBER) IS
        SELECT ci_id
        FROM pa_control_items
        WHERE ci_id = c_Ci_Id;

/*
        Cursor Get_CI_Data.
        To get the PROJECT_ID, STATUS_CODE, CI_TYPE_CLASS_CODE
        and RECORD_VERSION_NUMBER for the given Ci_Id.
*/
CURSOR Get_CI_Data (c_Ci_Id NUMBER) IS
        SELECT ci.project_id,
        s.project_system_status_code,
        cib.ci_type_class_code,
        ci.record_version_number
        FROM pa_control_items ci,
        pa_ci_types_b cib,
        (select
        project_status_code,
        project_system_status_code
        from pa_project_statuses
        where status_type = 'CONTROL_ITEM') s
        WHERE ci.ci_id = c_Ci_Id
        AND ci.ci_type_id = cib.ci_type_id
        AND ci.status_code = s.project_status_code;

/*
        Cursor Check_Workflow_On_CI.
        To check whether Workflow is running on the Ci_Id that
        is passed in.
*/
CURSOR Check_Workflow_On_CI (c_Ci_Id NUMBER) IS
        SELECT ci.ci_id
        FROM pa_project_statuses pps, pa_control_items ci
        WHERE pps.status_type = 'CONTROL_ITEM'
        AND pps.project_status_code = ci.status_code
        AND pps.enable_wf_flag = 'Y'
        AND pps.wf_success_status_code is not null
        AND pps.wf_failure_status_code is not null
        AND ci.ci_id = c_Ci_Id;

/*
	Cursor Get_CI_Type_Class_Code
	To get the CI_Type_Class_Code of the Control Item (ISSUE, CHANGE_REQUEST
	or CHANGE_ORDER) for a particular Control Item.
*/
CURSOR Get_CI_Type_Class_Code (c_Ci_Id NUMBER) IS
	SELECT pcit.ci_type_class_code
	FROM pa_control_items pci, pa_ci_types_b pcit
	WHERE pci.ci_id = c_Ci_Id
	AND pcit.ci_type_id = pci.ci_type_id;

/*Procedure to add workplan impact*/
Procedure Add_Workplan_Impact (
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        )
IS
       --Declaring local Variables
        l_impact_type_code        pa_ci_impacts.impact_type_code%TYPE:='WORKPLAN';
        l_msg_count               NUMBER := 0;
        l_data                    VARCHAR2(2000);
        l_msg_data                VARCHAR2(2000);
        l_msg_index_out           NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Add_Workplan_Impact';
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Workplan_Impact', p_debug_mode => l_debug_mode);
        END IF;

        --initializing the message stack.
        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint ADD_WORKPLAN_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add Workplan Impact', l_debug_level3);
        END IF;

        /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;

        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;


        PA_CONTROL_API_PVT.update_impacts(
                  p_ci_id               =>  p_ci_id,
                  x_ci_impact_id        =>  x_impact_id,
                  p_impact_type_code    =>  l_impact_type_code,
                  p_impact_description  =>  p_impact_description,
                  p_api_version_number  =>  p_api_version_number ,
                  p_commit              =>  p_commit,
                  p_init_msg_list       =>  p_init_msg_list,
                  p_mode                =>  'INSERT',
                  x_return_status       =>  x_return_status,
                  x_msg_count           =>  x_msg_count,
                  x_msg_data            =>  x_msg_data
                  );

        IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
        END IF;
         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_WORKPLAN_IMPACT_SVPT;
        END IF;
        if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);

         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_WORKPLAN_IMPACT_SVPT;
         END IF;
         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Add_Workplan_Impact',
                                   p_error_text      => x_msg_data);
         x_msg_count     := FND_MSG_PUB.count_msg;
         if l_debug_mode = 'Y' then
                 pa_debug.reset_err_stack;
         end if;

End Add_Workplan_Impact;


/*Procedure to add Staffing impact*/
Procedure Add_Staffing_Impact(
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        )
IS
       --Declaring local Variables
  l_impact_type_code          pa_ci_impacts.impact_type_code%TYPE:='STAFFING';
  l_msg_count                 NUMBER := 0;
  l_data                      VARCHAR2(2000);
  l_msg_data                  VARCHAR2(2000);
  l_msg_index_out             NUMBER;
  l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Add_Staffing_Impact';
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Staffing_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint ADD_STAFFING_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add Staffing Impact', l_debug_level3);
        END IF;

        /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;

        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        PA_CONTROL_API_PVT.update_impacts(
                  p_ci_id               =>  p_ci_id,
                  x_ci_impact_id        =>  x_impact_id,
                  p_impact_type_code    =>  l_impact_type_code,
                  p_impact_description  =>  p_impact_description,
                  p_api_version_number  =>  p_api_version_number ,
                  p_commit              =>  p_commit,
                  p_init_msg_list       =>  p_init_msg_list,
                  p_mode                =>  'INSERT',
                  x_return_status       =>  x_return_status,
                  x_msg_count           =>  x_msg_count,
                  x_msg_data            =>  x_msg_data
                  );

        IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
        END IF;
         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_STAFFING_IMPACT_SVPT;
        END IF;

       if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
      else
              x_msg_count := l_msg_count;
      end if;
      --Reset the stack
      if l_debug_mode = 'Y' then
              Pa_Debug.reset_curr_function;
      end if;

when others then
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      x_msg_data      := substr(SQLERRM,1,240);
      IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO ADD_STAFFING_IMPACT_SVPT;
      END IF;
      fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                p_procedure_name  => 'Add_Staffing_Impact',
                                p_error_text      => x_msg_data);
      x_msg_count     := FND_MSG_PUB.count_msg;
      if l_debug_mode = 'Y' then
              pa_debug.reset_err_stack;
      end if;

 End Add_Staffing_Impact;



/*Procedure to add Contract impact*/
Procedure Add_Contract_Impact(
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        )
IS
       --Declaring local Variables
    l_impact_type_code      pa_ci_impacts.impact_type_code%TYPE:='CONTRACT';
    l_msg_count            NUMBER := 0;
    l_data                 VARCHAR2(2000);
    l_msg_data             VARCHAR2(2000);
    l_msg_index_out        NUMBER;
    l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Add_Contract_Impact';
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Contract_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint ADD_CONTRACT_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add Contract Impact', l_debug_level3);
        END IF;

        /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;

        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        PA_CONTROL_API_PVT.update_impacts(
                  p_ci_id               =>  p_ci_id,
                  x_ci_impact_id        =>  x_impact_id,
                  p_impact_type_code    =>  l_impact_type_code,
                  p_impact_description  =>  p_impact_description,
                  p_api_version_number  =>  p_api_version_number ,
                  p_commit              =>  p_commit,
                  p_init_msg_list       =>  p_init_msg_list,
                  p_mode                =>  'INSERT',
                  x_return_status       =>  x_return_status,
                  x_msg_count           =>  x_msg_count,
                  x_msg_data            =>  x_msg_data
                  );

        IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
        END IF;
         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;
Exception
when FND_API.G_EXC_ERROR then

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_CONTRACT_IMPACT_SVPT;
        END IF;
        if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
        else
              x_msg_count := l_msg_count;
        end if;
        --Reset the stack
        if l_debug_mode = 'Y' then
                 Pa_Debug.reset_curr_function;
        end if;

when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        x_msg_data      := substr(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
               ROLLBACK TO ADD_CONTRACT_IMPACT_SVPT;
        END IF;
        fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Add_Contract_Impact',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        if l_debug_mode = 'Y' then
                 pa_debug.reset_err_stack;
         end if;
End Add_Contract_Impact;

/*Procedure to add Other impact*/
Procedure Add_Other_Impact(
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        x_impact_id            OUT NOCOPY  NUMBER
        )
IS
       --Declaring local Variables
        l_impact_type_code       pa_ci_impacts.impact_type_code%TYPE:='OTHER';
        l_msg_count              NUMBER := 0;
        l_data                   VARCHAR2(2000);
        l_msg_data               VARCHAR2(2000);
        l_msg_index_out          NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Add_Other_Impact';
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Other_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint ADD_OTHER_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add Other Impact', l_debug_level3);
        END IF;

        /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;

        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        PA_CONTROL_API_PVT.update_impacts(
                  p_ci_id               =>  p_ci_id,
                  x_ci_impact_id        =>  x_impact_id,
                  p_impact_type_code    =>  l_impact_type_code,
                  p_impact_description  =>  p_impact_description,
                  p_api_version_number  =>  p_api_version_number ,
                  p_commit              =>  p_commit,
                  p_init_msg_list       =>  p_init_msg_list,
                  p_mode                =>  'INSERT',
                  x_return_status       =>  x_return_status,
                  x_msg_count           =>  x_msg_count,
                  x_msg_data            =>  x_msg_data
                  );

       IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
        END IF;
         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;
Exception
when FND_API.G_EXC_ERROR then

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_OTHER_IMPACT_SVPT;
        END IF;
        if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
        else
              x_msg_count := l_msg_count;
        end if;
        --Reset the stack
        if l_debug_mode = 'Y' then
                 Pa_Debug.reset_curr_function;
        end if;

when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);

         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_OTHER_IMPACT_SVPT;
         END IF;
         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Add_Other_Impact',
                                   p_error_text      => x_msg_data);
         x_msg_count     := FND_MSG_PUB.count_msg;

        if l_debug_mode = 'Y' then
                 pa_debug.reset_err_stack;
        end if;
End Add_Other_Impact;

/*Procedure to add Supplier impact ,
including the supplier details passed as a table type parameter*/
Procedure Add_Supplier_Impact (
        p_commit               IN          VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN          VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN          NUMBER,
        x_return_status        OUT NOCOPY  VARCHAR2,
        x_msg_count            OUT NOCOPY  NUMBER,
        x_msg_data             OUT NOCOPY  VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR,
        p_supplier_det_tbl     IN          SUPP_DET_TBL_TYPE,    --Table with supplier details
        x_impact_id            OUT NOCOPY  NUMBER
        )
IS
  --Declaring local Variables
  l_impact_type_code       pa_ci_impacts.impact_type_code%TYPE:='SUPPLIER';
  l_msg_count              NUMBER := 0;
  l_data                   VARCHAR2(2000);
  l_msg_data               VARCHAR2(2000);
  l_msg_index_out          NUMBER;
  l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Add_Supplier_Impact';
  l_any_error_flag         VARCHAR2(1):= null;

--Supplier Details
  l_change_type            VARCHAR2(100);
  l_change_description     VARCHAR2(2000);
  l_vendor_id              VARCHAR2(240);
  l_po_header_id           NUMBER;
  l_po_number              VARCHAR2(40);
  l_po_line_id             NUMBER;
  l_po_line_num            NUMBER;
  l_currency               VARCHAR2(15);
  l_change_amount          NUMBER;


BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Supplier_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint ADD_SUPPLIER_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add_Supplier_Impact', l_debug_level3);
        END IF;

         /*validating the CI_ID for null value*/
         if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
        PA_CONTROL_API_PVT.update_impacts(
                  p_ci_id               =>  p_ci_id,
                  x_ci_impact_id        =>  x_impact_id,
                  p_impact_type_code    =>  l_impact_type_code,
                  p_impact_description  =>  p_impact_description,
                  p_api_version_number  =>  p_api_version_number ,
                  p_mode                => 'INSERT',
                  x_return_status       =>  x_return_status,
                  x_msg_count           =>  x_msg_count,
                  x_msg_data            =>  x_msg_data
                  );

        /* Adding the details of suppliers.*/
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Created the supplier impact and calling the supplier details API.';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        /*Calling the supplier details API  add Supplier details procedure.
        If any of the details did not get inserted successfully then roll back
          them including the  impact.*/
        if  x_return_status = FND_API.G_RET_STS_SUCCESS and x_impact_id is not null and p_supplier_det_tbl is not null then

            PA_CONTROL_API_PVT.Add_supplier_details(
                        p_ci_id                =>    p_ci_id,
                        p_ci_impact_id         =>    x_impact_id,
                        p_supplier_det_tbl     =>    p_supplier_det_tbl,
                        x_return_status        =>    x_return_status,
                        x_msg_count            =>    x_msg_count,
                        x_msg_data             =>    x_msg_data
                        );

        end if;


        IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
        END IF;
         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;

          IF p_commit = 'T' THEN
            ROLLBACK to ADD_SUPPLIER_IMPACT_SVPT;
          END IF;


         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  := x_msg_data || l_data;
              x_msg_count := l_msg_count;

         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO ADD_SUPPLIER_IMPACT_SVPT;
         END IF;
         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Add_Supplier_Impact',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;
End Add_Supplier_Impact;



/*Procedure to update or implement the Workplan impact*/
Procedure  Update_Workplan_Impact (
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        )
IS
        --Declaring local Variables
        l_impact_type_code        pa_ci_impacts.impact_type_code%TYPE:='WORKPLAN';
        l_ci_impact_id            pa_ci_impacts.ci_impact_id%Type;
        l_msg_count               NUMBER := 0;
        l_data                    VARCHAR2(2000);
        l_msg_data                VARCHAR2(2000);
        l_msg_index_out           NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Update_Workplan_Impact';
BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Update_Workplan_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_WORKPLAN_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Update_Workplan_Impact', l_debug_level3);
        END IF;

         /*validating the CI_ID for null value*/
         if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;


        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

         PA_CONTROL_API_PVT.update_impacts(
                p_ci_id                   => p_ci_id       ,
                p_impact_type_code        => l_impact_type_code,
                p_impact_description      => p_impact_description,
                p_api_version_number      => p_api_version_number ,
                p_mode                    => 'UPDATE',
                x_ci_impact_id            => l_ci_impact_id,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
                );

           IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
           END IF;
            --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;

          IF p_commit = 'T' THEN
            ROLLBACK to UPDATE_WORKPLAN_IMPACT_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_WORKPLAN_IMPACT_SVPT;
         END IF;


         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'UPDATE_WORKPLAN_IMPACT',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

End Update_Workplan_Impact;

/*Procedure to update or implement the Staffing impact*/
Procedure   Update_Staffing_Impact(
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        )
IS
  --Declaring local Variables
        l_impact_type_code        pa_ci_impacts.impact_type_code%TYPE:='STAFFING';
        l_ci_impact_id            pa_ci_impacts.ci_impact_id%Type;
        l_msg_count               NUMBER := 0;
        l_data                    VARCHAR2(2000);
        l_msg_data                VARCHAR2(2000);
        l_msg_index_out           NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Update_Staffing_Impact';

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Update_Staffing_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_STAFFING_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Update_Staffing_Impact', l_debug_level3);
        END IF;

          /*validating the CI_ID for null value*/
         if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;



        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

         PA_CONTROL_API_PVT.update_impacts(
                p_ci_id                   => p_ci_id       ,
                p_impact_type_code        => l_impact_type_code,
                p_impact_description      => p_impact_description,
                p_api_version_number      => p_api_version_number ,
                p_mode                    => 'UPDATE',
                x_ci_impact_id            => l_ci_impact_id,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
                );

           IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
           END IF;
            --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;

          IF p_commit = 'T' THEN
            ROLLBACK to UPDATE_STAFFING_IMPACT_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_STAFFING_IMPACT_SVPT;
         END IF;


         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'UPDATE_STAFFING_IMPACT',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

End Update_Staffing_Impact;


/*Procedure to update or implement the Contract impact*/
Procedure Update_Contract_Impact(
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        )
IS
 --Declaring local Variables
        l_impact_type_code              pa_ci_impacts.impact_type_code%TYPE:='CONTRACT';
        l_ci_impact_id pa_ci_impacts.ci_impact_id%Type;
        l_msg_count                              NUMBER := 0;
        l_data                                   VARCHAR2(2000);
        l_msg_data                               VARCHAR2(2000);
        l_msg_index_out                          NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Update_Contract_Impact';

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Update_Contract_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_CONTRACT_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Update_Contract_Impact', l_debug_level3);
        END IF;

          /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;


        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

         PA_CONTROL_API_PVT.update_impacts(
                p_ci_id                   => p_ci_id       ,
                p_impact_type_code        => l_impact_type_code,
                p_impact_description      => p_impact_description,
                p_api_version_number      => p_api_version_number ,
                p_mode                    => 'UPDATE',
                x_ci_impact_id            => l_ci_impact_id,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
                );

         IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                COMMIT;
         END IF;
            --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;

          IF p_commit = 'T' THEN
            ROLLBACK to UPDATE_CONTRACT_IMPACT_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CONTRACT_IMPACT_SVPT;
         END IF;

         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'UPDATE_CONTRACT_IMPACT',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

End Update_Contract_Impact;


/*Procedure to update or implement the Other impact*/
Procedure   Update_Other_Impact(
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        )
IS
 --Declaring local Variables
        l_impact_type_code       pa_ci_impacts.impact_type_code%TYPE:='OTHER';
        l_ci_impact_id           pa_ci_impacts.ci_impact_id%Type;
        l_msg_count                              NUMBER := 0;
        l_data                                   VARCHAR2(2000);
        l_msg_data                               VARCHAR2(2000);
        l_msg_index_out                          NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Update_Other_Impact';

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Update_Other_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_OTHER_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Update_Other_Impact', l_debug_level3);
        END IF;

          /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;



        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

         PA_CONTROL_API_PVT.update_impacts(
                p_ci_id                   => p_ci_id       ,
                p_impact_type_code        => l_impact_type_code,
                p_impact_description      => p_impact_description,
                p_api_version_number      => p_api_version_number ,
                p_mode                    => 'UPDATE',
                x_ci_impact_id            => l_ci_impact_id,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
                );

           IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
           END IF;
            --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;

          IF p_commit = 'T' THEN
            ROLLBACK to UPDATE_OTHER_IMPACT_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_OTHER_IMPACT_SVPT;
         END IF;


         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Update_Other_Impact',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;
End Update_Other_Impact;

Procedure  Update_Supplier_Impact (
        p_commit               IN         VARCHAR2 := FND_API.G_FALSE,
        p_init_msg_list        IN         VARCHAR2 := FND_API.G_FALSE,
        p_api_version_number   IN         NUMBER,
        x_return_status        OUT NOCOPY VARCHAR2,
        x_msg_count            OUT NOCOPY NUMBER,
        x_msg_data             OUT NOCOPY VARCHAR2,
        p_ci_id                IN          NUMBER   := G_PA_MISS_NUM,
        p_impact_description   IN          VARCHAR2 := G_PA_MISS_CHAR
        )
IS
        --Declaring local Variables
        l_impact_type_code        pa_ci_impacts.impact_type_code%TYPE:='SUPPLIER';
        l_ci_impact_id            pa_ci_impacts.ci_impact_id%Type;
        l_msg_count                              NUMBER := 0;
        l_data                                   VARCHAR2(2000);
        l_msg_data                               VARCHAR2(2000);
        l_msg_index_out                          NUMBER;
        l_module_name             VARCHAR2(200):='PA_CONTROL_API_PUB.Update_Supplier_Impact';

BEGIN

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Update_Supplier_Impact', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint UPDATE_SUPPLIER_IMPACT_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Update_Supplier_Impact', l_debug_level3);
        END IF;

          /*validating the CI_ID for null value*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_CI_ID');
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 raise FND_API.G_EXC_ERROR;
        end if;


        /*Calling the private API
        This update_impacts will do all the necessary validations and call
        other procedure to insert the details*/
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before Calling the Private API PA_CONTROL_API_PVT.update_impacts';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
         PA_CONTROL_API_PVT.update_impacts(
                p_ci_id                   => p_ci_id       ,
                p_impact_type_code        => l_impact_type_code,
                p_impact_description      => p_impact_description,
                p_api_version_number      => p_api_version_number ,
                p_mode                    => 'UPDATE',
                x_ci_impact_id            => l_ci_impact_id,
                x_return_status           => x_return_status,
                x_msg_count               => x_msg_count,
                x_msg_data                => x_msg_data
                );

           IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
           END IF;
            --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;

          IF p_commit = 'T' THEN
            ROLLBACK to UPDATE_SUPPLIER_IMPACT_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_SUPPLIER_IMPACT_SVPT;
         END IF;

         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Update_Supplier_Impact',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

END Update_Supplier_Impact;




Procedure Delete_Supplier_Impact_Details
		(
		P_COMMIT              IN      VARCHAR2  := FND_API.G_FALSE,
		P_INIT_MSG_LIST       IN      VARCHAR2  := FND_API.G_FALSE,
		P_API_VERSION_NUMBER  IN      NUMBER,
		X_RETURN_STATUS	      OUT  NOCOPY  VARCHAR2,
		X_MSG_COUNT	      OUT  NOCOPY  NUMBER,
		X_MSG_DATA 	      OUT  NOCOPY  VARCHAR2,
		P_CI_TRANSACTION_ID   IN      NUMBER)

IS
    -- Local Variables.
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
	l_module_name           VARCHAR2(200):='PA_CONTROL_API_PUB.Delete_Supplier_Impact_Details';
        -- End: Local Variables.

        l_chk_status_ctrl       VARCHAR2(1);
	l_ci_id                 pa_control_items.ci_id%type;
	l_transaction_id        pa_ci_supplier_details.ci_transaction_id%type;
        l_status_code           pa_control_items.status_code%type;

	CURSOR Check_Valid_CI_TRANS_ID  IS
        SELECT ci_transaction_id ,ci_id
        FROM pa_ci_supplier_details
        WHERE ci_transaction_id = P_CI_TRANSACTION_ID;

        CURSOR c_get_status(c_ci_id NUMBER)  IS
	SELECT status_code
	FROM pa_control_items
	WHERE ci_id = c_ci_id;

BEGIN
        -- Initialize the Error Stack.
        PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PUB.Delete_Supplier_Impact_Details');

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.G_RET_STS_SUCCESS;
        x_Msg_Count := 0;

        -- Clear the Global PL/SQL Message table.
        IF (FND_API.To_Boolean (p_Init_Msg_List)) THEN
                FND_MSG_PUB.Initialize;
        END IF;

	 IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_SUPP_DETAIL_SVPT;
        END IF;

        -- Check for the null p_ci_transaction_id value.
        -- report Error.
        IF P_CI_TRANSACTION_ID IS NULL  THEN
                -- Add message to the Error Stack that Ci_Id is NULL.
                PA_UTILS.Add_Message (p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_MISS_TRANS_ID'
                        );
		X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        else
		open Check_Valid_CI_TRANS_ID;
		fetch Check_Valid_CI_TRANS_ID into l_transaction_id,l_ci_id;
		if Check_Valid_CI_TRANS_ID%notfound then
			 -- Add message to the Error Stack that Ci_Id is NULL.
			PA_UTILS.Add_Message (p_App_Short_Name => 'PA'
					    , p_Msg_Name => 'PA_CI_INV_TRANS_ID'
					      );
			close Check_Valid_CI_TRANS_ID;
			X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
		        -- Raise the Invalid Argument exception.
	                RAISE FND_API.G_EXC_ERROR;
		end if;
		close Check_Valid_CI_TRANS_ID;
	END IF;

	    /*Security check for the CI_ID UpdateAccess*/
       if 'T' <> Pa_ci_security_pkg.check_update_access (l_ci_id) then
             PA_UTILS.add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_CI_NO_UPDATE_ACCESS');
             x_return_status := FND_API.G_RET_STS_ERROR;
             if l_debug_mode = 'Y' then
                    pa_debug.g_err_stage:= 'the CI_ID does not have the update access';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
              raise FND_API.G_EXC_ERROR ;
       end if;

 /* Check for the status control: check whether the action  CONTROL_ITEM_ALLOW_UPDATE is allowed on the current status of the issue. */
        open c_get_status(l_ci_id);
	fetch c_get_status into l_status_code;
	if c_get_status%notfound then
		 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       =>'PA_CI_INV_CI_ID');
                 if l_debug_mode = 'Y' then
                          pa_debug.g_err_stage:= 'the ci_id is invalid';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 x_return_status := FND_API.G_RET_STS_ERROR;
		 close c_get_status;
		 raise  FND_API.G_EXC_ERROR ;
	end if;
	close c_get_status;

	  l_chk_status_ctrl :=  pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM', l_status_code, 'CONTROL_ITEM_ALLOW_UPDATE');
	  IF (l_chk_status_ctrl = 'N') THEN
		       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_ALLOW_UPDATE');
	              RAISE FND_API.G_EXC_ERROR;
	  END IF;


  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module_name, 'After call to pa_control_items_utils.CheckCIActionAllowed', l_debug_level3);
  END IF;


	if X_RETURN_STATUS = FND_API.g_Ret_Sts_Success then
		--Calling the api to delete the supplier details
		PA_CI_SUPPLIER_PKG.delete_row (p_ci_transaction_id => P_CI_TRANSACTION_ID);
	end if;

	 IF p_commit = FND_API.G_TRUE and  x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
        END IF;
         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;
Exception
when FND_API.G_EXC_ERROR then

        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO DELETE_SUPP_DETAIL_SVPT;
        END IF;
        if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
        else
              x_msg_count := l_msg_count;
        end if;
        --Reset the stack
        if l_debug_mode = 'Y' then
                 Pa_Debug.reset_curr_function;
        end if;

when others then
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        x_msg_data      := substr(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
               ROLLBACK TO ADD_CONTRACT_IMPACT_SVPT;
        END IF;
        fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Delete_Supplier_Impact_Details',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        if l_debug_mode = 'Y' then
                 pa_debug.reset_err_stack;
         end if;
End Delete_Supplier_Impact_Details;



/* Update Progress API to update the progress and resolution details are also included
   to add the resolution*/
Procedure Update_Progress(
                        p_commit                IN    VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN    VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN    NUMBER,
                        x_return_status         OUT NOCOPY  VARCHAR2,
                        x_msg_count             OUT NOCOPY  NUMBER,
                        x_msg_data              OUT NOCOPY  VARCHAR2,
                        p_ci_id                 IN    NUMBER   := G_PA_MISS_NUM,
                        p_ci_status_code        IN    VARCHAR2 := G_PA_MISS_CHAR,
  		        p_status_comment        IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_as_of_date            IN    DATE     := G_PA_MISS_DATE,
                        p_progress_status_code  IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_progress_overview     IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_resolution_code       IN    VARCHAR2 := G_PA_MISS_CHAR,
                        p_resolution_comment    IN    VARCHAR2 := G_PA_MISS_CHAR
                        )
IS

/* Cursor to get the control item data*/
cursor c_get_control_item_data
is
    select *
    from pa_control_items
    where ci_id = p_ci_id;

/*cursor to check the progress code is valid or not*/
cursor c_check_Progress_code
is
    Select project_status_code,
    project_status_name
    From   pa_project_statuses
    where (trunc(sysdate) between nvl(start_date_active, trunc(sysdate))
    and nvl(end_date_active, trunc(sysdate))
    and status_type = 'PROGRESS')
    and project_status_code = p_progress_status_code;  --need to clarify whether this is a name or code

/*cursor to check the resolution code is valid or not*/
cursor c_get_resolution_codes(c_ci_type_id pa_control_items.ci_type_id%type)
is
   select
   cat.class_category class_category,
   cat.class_code description,
   cat.class_code_id code
   from pa_class_codes cat,
   pa_ci_types_b typ
   where trunc(sysdate) between cat.start_date_active and
   nvl(cat.end_date_active,trunc(sysdate))
   and typ.ci_type_id=c_ci_type_id
   and cat.class_category=typ.resolution_category
   and cat.class_code_id = p_resolution_code;


CURSOR c_info IS
    SELECT cit.ci_type_class_code,
           cit.approval_required_flag,
             s.next_allowable_status_flag
      FROM pa_control_items c,
           pa_ci_types_b cit,
           pa_project_statuses s
     WHERE c.ci_id = p_ci_id
       AND c.status_code = s.project_status_code
       AND c.ci_type_id =cit.ci_type_id
       AND s.status_type = 'CONTROL_ITEM';



 l_data              VARCHAR2(2000);
 l_msg_data          VARCHAR2(2000);
 l_msg_index_out     NUMBER;
 l_module_name       VARCHAR2(200):='PA_CONTROL_API_PUB.Update_Progress';
 l_msg_count         NUMBER := 0;

 l_stmnt             VARCHAR2(5000);
 l_sel_clause        VARCHAR2(300);
 l_from_clause       VARCHAR2(300);
 l_where             VARCHAR2(4000);
 l_where1            VARCHAR2(2000);
 l_cursor            NUMBER;
 l_rows              NUMBER;
 l_rows1             NUMBER;
 l_ci_status_code_1                  pa_project_statuses.project_status_code%TYPE;

 cp    c_get_control_item_data%ROWTYPE;
 c_get_resolution_codes_rec   c_get_resolution_codes%ROWTYPE;
 c_check_Progress_code_rec    c_check_Progress_code%ROWTYPE;

 check_s   VARCHAR2(1);  --For security checks.

--declaring pa_control_item local variables
 l_last_modified_by_id          pa_control_items.last_modified_by_id%TYPE;
 l_curr_status_code             pa_control_items.status_code%TYPE;
 l_ci_status_code               pa_control_items.status_code%TYPE;
 l_record_version_number        pa_control_items.record_version_number%TYPE;
 l_summary                      pa_control_items.summary%TYPE;
 l_description                  pa_control_items.description%TYPE;
 l_owner_id                     pa_control_items.owner_id%TYPE;
 l_classification_code_id       pa_control_items.classification_code_id%TYPE;
 l_reason_code_id               pa_control_items.reason_code_id%TYPE;
 l_object_id                    pa_control_items.object_id%TYPE;
 l_object_type                  pa_control_items.object_type%TYPE;
 l_date_required                pa_control_items.date_required%TYPE;
 l_priority_code                pa_control_items.priority_code%TYPE;
 l_effort_level_code            pa_control_items.effort_level_code%TYPE;
 l_price                        pa_control_items.price%TYPE;
 l_price_currency_code          pa_control_items.price_currency_code%TYPE;
 l_source_type_code             pa_control_items.source_type_code%TYPE;
 l_source_comment               pa_control_items.source_comment%TYPE;
 l_source_number                pa_control_items.source_number%TYPE;
 l_source_date_received         pa_control_items.source_date_received%TYPE;
 l_source_organization          pa_control_items.source_organization%TYPE;
 l_source_person                pa_control_items.source_person%TYPE;
 l_as_of_date                   pa_control_items.progress_as_of_date%TYPE;
 l_ci_number                    pa_control_items.ci_number%TYPE;
 l_progress_status_code         pa_control_items.progress_status_code%TYPE;
 l_progress_overview            pa_control_items.status_overview%TYPE;
 l_resolution_code_id           pa_control_items.resolution_code_id%TYPE;
 l_resolution_comment           pa_control_items.resolution%TYPE;
 l_date_closed                  pa_control_items.date_closed%TYPE;
 l_closed_by_id                 pa_control_items.closed_by_id%TYPE;
 l_project_id                   pa_control_items.project_id%TYPE;
 l_ci_type_id                   pa_control_items.ci_type_id%TYPE;
 l_attribute_category           pa_control_items.attribute_category%TYPE;
 l_attribute1                   pa_control_items.attribute1%TYPE;
 l_attribute2                   pa_control_items.attribute2%TYPE;
 l_attribute3                   pa_control_items.attribute3%TYPE;
 l_attribute4                   pa_control_items.attribute4%TYPE;
 l_attribute5                   pa_control_items.attribute5%TYPE;
 l_attribute6                   pa_control_items.attribute6%TYPE;
 l_attribute7                   pa_control_items.attribute7%TYPE;
 l_attribute8                   pa_control_items.attribute8%TYPE;
 l_attribute9                   pa_control_items.attribute9%TYPE;
 l_attribute10                  pa_control_items.attribute10%TYPE;
 l_attribute11                  pa_control_items.attribute11%TYPE;
 l_attribute12                  pa_control_items.attribute12%TYPE;
 l_attribute13                  pa_control_items.attribute13%TYPE;
 l_attribute14                  pa_control_items.attribute14%TYPE;
 l_attribute15                  pa_control_items.attribute15%TYPE;

 l_projectid                 pa_control_items.project_id%TYPE;
 l_proj_status_code          pa_project_statuses.project_system_status_code%TYPE;
 l_citypeclasscode           pa_ci_types_b.ci_type_class_Code%TYPE;

 l_curr_system_status        pa_project_statuses.project_system_status_code%TYPE;
 l_next_allow_status_flag    pa_project_statuses.next_allowable_status_flag%TYPE;
 l_ci_type_class_code        pa_ci_types_b.ci_type_class_code%TYPE;
 l_approval_required_flag    pa_ci_types_b.approval_required_flag%TYPE;

 l_enforce_security          VARCHAR2(1) := 'Y';
 l_start_wf                  VARCHAR2(1) := 'Y';
 l_num_of_actions            NUMBER;
 l_max_msg_count             NUMBER := FND_API.G_MISS_NUM;
 l_status_change_flag        VARCHAR2(1) := 'N';
 l_validate_only             VARCHAR2(1) := FND_API.g_false;
 l_recordversionnumber       NUMBER(15);
 l_ci_id_error_flag          VARCHAR2(1) := null;
 l_resolution_check          VARCHAR2(10) := 'AMG';
 l_resolution_req            VARCHAR2(10) := 'N';
 l_resolution_req_cls        VARCHAR2(10) := 'N';
 l_to_status_flag            VARCHAR2(10) := 'Y';


Begin
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
        IF l_debug_mode = 'Y' THEN
              PA_DEBUG.set_curr_function(p_function => 'UPDATE_PROGRESS', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                 savepoint UPDATE_PROGRESS_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Update Progress ', l_debug_level3);
        END IF;

        x_msg_count := 0;

        if p_ci_id is null or p_ci_id = G_PA_MISS_NUM then
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CI_MISS_CI_ID');
                if l_debug_mode = 'Y' then
                       pa_debug.g_err_stage:= 'the ci_id is null';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                x_return_status := FND_API.G_RET_STS_ERROR;
                --raise FND_API.G_EXC_ERROR;
                l_ci_id_error_flag := 'Y';
        else
                open c_get_control_item_data;
                fetch c_get_control_item_data into cp;
                if c_get_control_item_data%NOTFOUND then

                        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                             ,p_msg_name       => 'PA_CI_INV_CI_ID');
                        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= 'the ci_id is invalid';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_get_control_item_data;
                        --raise FND_API.G_EXC_ERROR;
                        l_ci_id_error_flag := 'Y';
                else

                      l_curr_status_code        := cp.status_code;
                      l_record_version_number   := cp.record_version_number;
                      l_summary                 := cp.summary;
                      l_description             := cp.description;
                      l_owner_id                := cp.owner_id;
                      l_classification_code_id  := cp.classification_code_id;
                      l_reason_code_id          := cp.reason_code_id;
                      l_object_id               := cp.object_id;
                      l_object_type             := cp.object_type;
                      l_date_required           := cp.date_required;
                      l_priority_code           := cp.priority_code;
                      l_effort_level_code       := cp.effort_level_code;
                      l_price                   := cp.price;
                      l_price_currency_code     := cp.price_currency_code;
                      l_source_type_code        := cp.source_type_code;
                      l_source_comment          := cp.source_comment;
                      l_source_number           := cp.source_number;
                      l_source_date_received    := cp.source_date_received;
                      l_source_organization     := cp.source_organization;
                      l_source_person           := cp.source_person;
                      l_as_of_date              := cp.progress_as_of_date;
                      l_ci_number               := cp.ci_number;
                      l_progress_status_code    := cp.progress_status_code;
                      l_progress_overview       := cp.status_overview;
                      l_resolution_code_id      := cp.resolution_code_id;
                      l_resolution_comment      := cp.resolution;
                      l_date_closed             := cp.date_closed;
                      l_closed_by_id            := cp.closed_by_id;
                      l_project_id              := cp.project_id;
                      l_ci_type_id              := cp.ci_type_id;
                      l_attribute_category      := cp.attribute_category;
                      l_attribute1              := cp.attribute1;
                      l_attribute2              := cp.attribute2;
                      l_attribute3              := cp.attribute3;
                      l_attribute4              := cp.attribute4;
                      l_attribute5              := cp.attribute5;
                      l_attribute6              := cp.attribute6;
                      l_attribute7              := cp.attribute7;
                      l_attribute8              := cp.attribute8;
                      l_attribute9              := cp.attribute9;
                      l_attribute10             := cp.attribute10;
                      l_attribute11             := cp.attribute11;
                      l_attribute12             := cp.attribute12;
                      l_attribute13             := cp.attribute13;
                      l_attribute14             := cp.attribute14;
                      l_attribute15             := cp.attribute15;
                        close c_get_control_item_data;
                end if;
        end if;



        /*check the security access only when ci_id is not invalid bcoz we need to
        validate other parameters as we are not raising any exceptions (All the
        conditions depending on the ci_id will be checked only when ci_id is valid.)*/

      if l_ci_id_error_flag is null then

        /*Check if the user can update the item. This requires the user to be owner or
        to have project authority or to have open actions and status controls are satisfied.
        The page will not be updateable when the current status has approval workflow attached*/

         /*Security check for the CI_ID UpdateAccess*/
          check_s  := pa_ci_security_pkg.check_update_access(p_ci_id);

        if 'T' <> check_s then
               PA_UTILS.add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_NO_UPDATE_ACCESS');
               x_return_status := FND_API.G_RET_STS_ERROR;
               if l_debug_mode = 'Y' then
                      pa_debug.g_err_stage:= 'the CI_ID does not have the update access';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               end if;
               --raise FND_API.G_EXC_ERROR ;

        end if;



        /* cursor to get the project system status code to pass the value in checkciActionallowed as
        user statuses are not considered in pa_control_items status code*/
          -- Open Cursor Get_CI_Data and fetch the data into out local variables.
        OPEN get_ci_data (p_ci_id);
        FETCH Get_CI_Data INTO l_projectid, l_proj_status_code, l_citypeclasscode, l_recordversionnumber;
        -- If NO_DATA_FOUND then report Error.
        IF (Get_CI_Data%NOTFOUND) THEN
                -- Code to Report Error and Return.
                x_return_status := FND_API.G_RET_STS_ERROR;
--                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Get_CI_Data;



         /* Check for the status control: check whether the action CONTROL_ITEM_ALLOW_UPDST is allowed on the current status of the issue. */

       check_s   :=  PA_CONTROL_ITEMS_UTILS.CheckCIActionAllowed ('CONTROL_ITEM', l_curr_status_code , 'CONTROL_ITEM_ALLOW_UPDATE');

       if check_s <> 'Y' then
                PA_UTILS.add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CI_NO_ALLOW_UPDATE');
                x_return_status := FND_API.G_RET_STS_ERROR;
                if l_debug_mode = 'Y' then
                       pa_debug.g_err_stage:= 'the CI_ID does not have the update access for the current status';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
               -- raise FND_API.G_EXC_ERROR ;
       end if;


  end if; -- end for if l_ci_id_error_flag is null then



/*Validating the p_ci_status_code -
  This is taken from Update_issue procedure. So If any changes happen in update_issue then this code needs to
  be looked in to*/

 l_curr_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_curr_status_code);

 IF p_ci_status_code = G_PA_MISS_CHAR THEN
       l_ci_status_code := l_curr_status_code;
  ELSIF p_ci_status_code IS NOT NULL THEN
          l_ci_status_code := p_ci_status_code;

          OPEN c_info;
          FETCH c_info INTO l_ci_type_class_code, l_approval_required_flag, l_next_allow_status_flag;
          CLOSE c_info;

          l_sel_clause  := ' SELECT ps.project_status_code ';
          l_from_clause := ' FROM pa_obj_status_lists osl, pa_status_list_items sli, pa_project_statuses ps ';
          l_where       := ' WHERE osl.status_type = '||'''CONTROL_ITEM'''||
                             ' AND osl.object_type = '||'''PA_CI_TYPES'''||
                             ' AND osl.object_id = '||l_ci_type_id||
                             ' AND osl.status_list_id = sli.status_list_id'||
                             ' AND sli.project_status_code = ps.project_status_code'||
                             ' AND ps.project_status_code <> '||''''||l_curr_status_code||''''||
                             ' AND ps.status_type = osl.status_type'||
                             ' AND trunc(sysdate) between nvl(ps.start_date_active, trunc(sysdate)) and nvl(ps.end_date_active, trunc(sysdate))'||
                             ' AND (('||''''||l_next_allow_status_flag||''''||' = '||'''N'''||' and 1=2)'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''S'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in ( select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
                                  ''''||l_curr_status_code||''''||')))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''U'''||
                                  ' and ps.project_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||''''||
                                  l_curr_status_code||''''||'))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''A'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
                                  ''''||l_curr_system_status||''''||'))))'||
                              ' AND ps.project_status_code not in (select wf_success_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND ps.project_status_code not in (select wf_failure_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND decode(ps.project_system_status_code, '||'''CI_CANCELED'''||
                              ', nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_CANCEL'''||', null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_WORKING'''||
                              ' ,nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_REWORK'''||' ,null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_UPDST'''||' ,null),'||'''N'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_DRAFT'''||
                              ' ,decode('||''''||l_curr_system_status||''''||', '||'''CI_DRAFT'''||', '||
                              '''Y'''||' ,'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND ps.project_status_code = '||''''||p_ci_status_code||'''';

          IF (l_ci_type_class_code = 'ISSUE' AND l_approval_required_flag = 'N') THEN
                l_where1 := ' AND  ps.project_status_code not in (select project_status_code from pa_project_statuses where status_type = '||
                           '''CONTROL_ITEM'''||' and enable_wf_flag = '||'''Y'''||
                           ' and wf_success_status_code is not null and wf_failure_status_code is not null) ';
          END IF;

          IF (l_ci_type_class_code = 'ISSUE' AND l_approval_required_flag = 'Y' AND l_curr_system_status = 'CI_WORKING') THEN
                l_where1 := ' AND  ps.project_system_status_code <> '||'''CI_CLOSED''';
          END IF;

          IF (l_ci_type_class_code = 'CHANGE_REQUEST') THEN
                l_where1 := ' AND  ps.project_system_status_code <> '||'''CI_CLOSED''';
          END IF;

          IF (l_ci_type_class_code = 'CHANGE_ORDER' AND l_curr_system_status = 'CI_WORKING') THEN
                l_where1 := ' AND ps.project_system_status_code <> '||'''CI_CLOSED''';
          END IF;

          l_stmnt := l_sel_clause || l_from_clause || l_where || l_where1;

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module_name, l_stmnt, l_debug_level3);
          END IF;

    l_cursor := dbms_sql.open_cursor;

    DBMS_SQL.PARSE(l_cursor, l_stmnt, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_ci_status_code_1, 30);

    l_rows := DBMS_SQL.EXECUTE(l_cursor);

    IF (l_rows < 0) THEN
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_TO_STATUS_INVALID');
               x_return_status := FND_API.G_RET_STS_ERROR;
               l_to_status_flag := 'N';
    ELSE
       l_rows1 := DBMS_SQL.FETCH_ROWS(l_cursor);

       if l_rows1 > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_ci_status_code_1);
            l_ci_status_code := l_ci_status_code_1;
       else
	     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TO_STATUS_INVALID');
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_to_status_flag := 'N';
       end if;

    END IF;
    IF dbms_sql.is_open(l_cursor) THEN
         dbms_sql.close_cursor(l_cursor);
    END IF;
  ELSIF p_ci_status_code IS NULL THEN
          l_ci_status_code := p_ci_status_code;
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NULL_STATUS');
          x_return_status := FND_API.G_RET_STS_ERROR;
	  l_to_status_flag := 'N';
  END IF;

/*end of status_code validation*/


        --get hz_parties.party_id of the logged in user
        l_last_modified_by_id := PA_CONTROL_ITEMS_UTILS.GetPartyId(fnd_global.user_id );

         if p_as_of_date <> G_PA_MISS_DATE and p_as_of_date is not null then
                l_as_of_date := p_as_of_date;
         else
                l_as_of_date := SYSDATE;
         end if;

        if  p_progress_status_code <> G_PA_MISS_CHAR and p_progress_status_code is not null then
                open c_check_Progress_code;
                fetch c_check_Progress_code into c_check_Progress_code_rec;
                if c_check_Progress_code%notfound then
                        PA_UTILS.add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_INV_PRG_CODE');
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        if l_debug_mode = 'Y' then
                              pa_debug.g_err_stage:= 'Invalid progress Code is passed';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        close c_check_Progress_code;
                else
                        l_progress_status_code := p_progress_status_code;
                        close c_check_Progress_code;
                end if;
        elsif p_progress_status_code is null then
                 PA_UTILS.add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_PROGRESS_STATUS_NULL');
                 if l_debug_mode = 'Y' then
                         pa_debug.g_err_stage:= 'Progress Code is null';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        if p_resolution_code <> G_PA_MISS_CHAR and p_resolution_code is not null then
                open c_get_resolution_codes(l_ci_type_id);
                fetch c_get_resolution_codes into c_get_resolution_codes_rec;
                        if c_get_resolution_codes%notfound then
                                PA_UTILS.add_Message( p_app_short_name => 'PA'
                                                     ,p_msg_name       => 'PA_CI_RESOLUTION_INV');
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                if l_debug_mode = 'Y' then
                                      pa_debug.g_err_stage:= 'the Resolution Code is invalid';
                                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                end if;
                                close c_get_resolution_codes;
                                --raise FND_API.G_EXC_ERROR ;
                        else
                                l_resolution_code_id := p_resolution_code;
                                close c_get_resolution_codes;
                        end if;
        elsif p_resolution_code is null then
                l_resolution_code_id := null;
        end if;

        if p_progress_overview <> G_PA_MISS_CHAR and p_progress_overview is not null then
                l_progress_overview := p_progress_overview;
        elsif p_progress_overview is null then
                l_progress_overview := null;
        end if;


        if p_resolution_comment <> G_PA_MISS_CHAR and p_resolution_comment is not null then
                l_resolution_comment:=p_resolution_comment;
        elsif p_resolution_comment is null then
                l_resolution_comment := null;
        end if;

IF (l_curr_status_code is NOT NULL AND
      l_ci_status_code   is NOT NULL AND
      l_curr_status_code <> l_ci_status_code AND
      l_to_status_flag = 'Y' and x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN

	 IF l_debug_mode = 'Y' THEN
   	      pa_debug.write(l_module_name, 'Before call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate', l_debug_level3);
         END IF;

         PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate (
                                  p_init_msg_list      => p_init_msg_list
                                 ,p_commit             => p_commit
                                 ,p_validate_only      => l_validate_only
                                 ,p_max_msg_count      => l_max_msg_count
                                 ,p_ci_id              => p_ci_id
                                 ,p_status             => p_ci_status_code
                                 ,p_enforce_security   => l_enforce_security
                                 ,p_resolution_check   => l_resolution_check
                                 ,x_resolution_req     => l_resolution_req
                                 ,x_resolution_req_cls => l_resolution_req_cls
                                 ,x_start_wf           => l_start_wf
                                 ,x_new_status         => l_ci_status_code
                                 ,x_num_of_actions     => l_num_of_actions
                                 ,x_return_status      => x_return_status
                                 ,x_msg_count          => x_msg_count
                                 ,x_msg_data           => x_msg_data);

       /* l_ci_status_code gets the new status from ChangeCIStatusValidate.
          In case of CR/CO, if Auto Approve on Submission is enabled and while changing the status to submitted,
          then the new status would be the success status code defined for the workflow */

	IF l_debug_mode = 'Y' THEN
   	     pa_debug.write(l_module_name, 'after call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate: x_return_status = '||x_return_status, l_debug_level3);
   	     pa_debug.write(l_module_name, 'after call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate: l_ci_status_code = '||l_ci_status_code, l_debug_level3);
        END IF;

        IF x_return_status = 'S' THEN
             l_status_change_flag := 'Y';
        END IF;

	IF l_debug_mode = 'Y' THEN
   	     pa_debug.write(l_module_name, 'after call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate: l_status_change_flag = '||l_status_change_flag, l_debug_level3);
        END IF;



        IF (l_resolution_req IS NOT NULL AND  l_resolution_req = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

        IF (l_resolution_req_cls IS NOT NULL AND  l_resolution_req_cls = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

   END IF;

        if l_debug_mode = 'Y' then
                pa_debug.g_err_stage:= 'Before caliing the PA_CONTROL_ITEMS_PKG.UPDATE_ROW procedure';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;


         if x_return_status = FND_API.G_RET_STS_SUCCESS then
          PA_CONTROL_ITEMS_PKG.UPDATE_ROW(
                         p_ci_id                 => p_ci_id
                        ,p_ci_type_id            => l_ci_type_id
                        ,p_summary               => l_summary
                        ,p_status_code           => l_ci_status_code
                        ,p_owner_id              => l_owner_id
                        ,p_highlighted_flag      => null
                        ,p_progress_status_code  => l_progress_status_code
                        ,p_progress_as_of_date   => l_as_of_date
                        ,p_classification_code   => l_classification_code_id
                        ,p_reason_code           => l_reason_code_id
                        ,p_record_version_number => l_record_version_number

                        ,p_project_id            => l_project_id
                        ,p_last_modified_by_id   => l_last_modified_by_id
                        ,p_object_type           => l_object_type
                        ,p_object_id             => l_object_id
                        ,p_ci_number             => l_ci_number
                        ,p_date_required         => l_date_required
                        ,p_date_closed           => l_date_closed
                        ,p_closed_by_id          => l_closed_by_id
                        ,p_description           => l_description
                        ,p_status_overview       => l_progress_overview
                        ,p_resolution            => l_resolution_comment
                        ,p_resolution_code       => l_resolution_code_id
                        ,p_priority_code         => l_priority_code
                        ,p_effort_level_code     => l_effort_level_code
                        ,p_open_action_num       => null
                        ,p_price                 => l_price
                        ,p_price_currency_code   => l_price_currency_code
                        ,p_source_type_code      => l_source_type_code
                        ,p_source_comment        => l_source_comment
                        ,p_source_number         => l_source_number
                        ,p_source_date_received  => l_source_date_received
                        ,p_source_organization   => l_source_organization
                        ,p_source_person         => l_source_person
                        ,p_attribute_category    => l_attribute_category
                        ,p_attribute1            => l_attribute1
                        ,p_attribute2            => l_attribute2
                        ,p_attribute3            => l_attribute3
                        ,p_attribute4            => l_attribute4
                        ,p_attribute5            => l_attribute5
                        ,p_attribute6            => l_attribute6
                        ,p_attribute7            => l_attribute7
                        ,p_attribute8            => l_attribute8
                        ,p_attribute9            => l_attribute9
                        ,p_attribute10           => l_attribute10
                        ,p_attribute11           => l_attribute11
                        ,p_attribute12           => l_attribute12
                        ,p_attribute13           => l_attribute13
                        ,p_attribute14           => l_attribute14
                        ,p_attribute15           => l_attribute15
                        ,x_return_status         => x_return_status
                        ,x_msg_count             => x_msg_count
                        ,x_msg_data              => x_msg_data
                         );
        else
                raise FND_API.G_EXC_ERROR;
        end if;

 IF (l_status_change_flag = 'Y' AND l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

	   IF l_debug_mode = 'Y' THEN
   	        pa_debug.write(l_module_name, 'before call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           /* call the insert table handlers of pa_obj_status_changes and pa_ci_comments here */

           PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT( p_object_type        => 'PA_CI_TYPES'
                                                            ,p_object_id          => p_ci_id
                                                            ,p_type_code          => 'CHANGE_STATUS'
                                                            ,p_status_type        => 'CONTROL_ITEM'
                                                            ,p_new_project_status => l_ci_status_code
                                                            ,p_old_project_status => l_curr_status_code
                                                            ,p_comment            => p_status_comment
                                                            ,x_return_status      => x_return_status
                                                            ,x_msg_count          => x_msg_count
                                                            ,x_msg_data           => x_msg_data );

	   IF l_debug_mode = 'Y' THEN
   	        pa_debug.write(l_module_name, 'after call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus (
                                                          p_init_msg_list
                                                         ,p_commit
                                                         ,l_validate_only
                                                         ,l_max_msg_count
                                                         ,p_ci_id
                                                         ,l_curr_status_code
                                                         ,l_ci_status_code
                                                         ,l_start_wf
                                                         ,l_enforce_security
                                                         ,l_num_of_actions
                                                         ,x_return_status
                                                         ,x_msg_count
                                                         ,x_msg_data    );


           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'after call to PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus', l_debug_level3);
           END IF;

  END IF;




         IF p_commit = FND_API.G_TRUE and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                 COMMIT;
         elsif x_return_status <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_ERROR;
         END IF;
            --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

Exception
when FND_API.G_EXC_ERROR then

         x_return_status := FND_API.G_RET_STS_ERROR;
         l_msg_count := fnd_msg_pub.count_msg;
          IF p_commit = 'T' THEN
            ROLLBACK to UPDATE_PROGRESS_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_msg_data      := substr(SQLERRM,1,240);
         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_PROGRESS_SVPT;
         END IF;
         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'Update_Progress',
                                   p_error_text      => x_msg_data);
         x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

end Update_Progress;




PROCEDURE CREATE_ISSUE
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
x_ci_id                                         OUT NOCOPY NUMBER,
x_ci_number                                     OUT NOCOPY NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute_category                            IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   IN VARCHAR2 := G_PA_MISS_CHAR
)
IS

  l_module_name                            VARCHAR2(200);


  l_ci_type_class_code                     pa_ci_types_b.ci_type_class_code%type;
  l_auto_number_flag                       pa_ci_types_b.auto_number_flag%type;
  l_source_attrs_enabled_flag              pa_ci_types_b.source_attrs_enabled_flag%type;

  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;

  l_project_id                             pa_projects_all.project_id%type;
  l_project_name                           pa_projects_all.name%type;
  l_project_number                         pa_projects_all.segment1%type;
  l_ci_type_id                             pa_ci_types_b.ci_type_id%type;
  l_summary                                pa_control_items.summary%type;
  l_ci_number                              pa_control_items.ci_number%type;
  l_description                            pa_control_items.description%type;
  l_status_code                            pa_project_statuses.project_status_code%type;
  l_status                                 pa_project_statuses.project_status_name%type;
  l_owner_id                               pa_control_items.owner_id%type;
  l_progress_status_code                   pa_control_items.progress_status_code%type;
  l_progress_as_of_date                    pa_control_items.progress_as_of_date%type;
  l_status_overview                        pa_control_items.status_overview%type;
  l_classification_code                    pa_control_items.classification_code_id%type;
  l_reason_code                            pa_control_items.reason_code_id%type;
  l_object_id                              pa_control_items.object_id%type;
  l_object_type                            pa_control_items.object_type%type;
  l_date_required                          pa_control_items.date_required%type;
  l_date_closed                            pa_control_items.date_closed%type;
  l_closed_by_id                           pa_control_items.closed_by_id%type;
  l_resolution                             pa_control_items.resolution%type;
  l_resolution_code                        pa_control_items.resolution_code_id%type;
  l_priority_code                          pa_control_items.priority_code%type;
  l_effort_level_code                      pa_control_items.effort_level_code%type;
  l_price                                  pa_control_items.price%type;
  l_price_currency_code                    pa_control_items.price_currency_code%type;
  l_source_type_name                       pa_lookups.meaning%type;
  l_source_type_code                       pa_control_items.source_type_code%type;
  l_source_number                          pa_control_items.source_number%type;
  l_source_comment                         pa_control_items.source_comment%type;
  l_source_date_received                   pa_control_items.source_date_received%type;
  l_source_organization                    pa_control_items.source_organization%type;
  l_source_person                          pa_control_items.source_person%type;
  l_attribute_category                     pa_control_items.attribute_category%type;
  l_attribute1                             pa_control_items.attribute1%type;
  l_attribute2                             pa_control_items.attribute1%type;
  l_attribute3                             pa_control_items.attribute1%type;
  l_attribute4                             pa_control_items.attribute1%type;
  l_attribute5                             pa_control_items.attribute1%type;
  l_attribute6                             pa_control_items.attribute1%type;
  l_attribute7                             pa_control_items.attribute1%type;
  l_attribute8                             pa_control_items.attribute1%type;
  l_attribute9                             pa_control_items.attribute1%type;
  l_attribute10                            pa_control_items.attribute1%type;
  l_attribute11                            pa_control_items.attribute1%type;
  l_attribute12                            pa_control_items.attribute1%type;
  l_attribute13                            pa_control_items.attribute1%type;
  l_attribute14                            pa_control_items.attribute1%type;
  l_attribute15                            pa_control_items.attribute1%type;
  l_class_code                             constant varchar2(20) := 'ISSUE';

BEGIN

  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'create_issue' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pub.create_issue', p_debug_mode => l_debug_mode);
  end if;

  if fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) then
          fnd_msg_pub.initialize;
  end if;

  if p_commit = fnd_api.g_true then
          savepoint create_issue;
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of create_issue', l_debug_level3);
  end if;

  --handle the miss_char and null values
  if(p_project_id is null or p_project_id = G_PA_MISS_NUM) then
     l_project_id := null;
  else
     l_project_id := p_project_id;
  end if;

    if(p_project_name is null or p_project_name = G_PA_MISS_CHAR) then
     l_project_name := null;
  else
     l_project_name := p_project_name;
  end if;

  if(p_project_number is null or p_project_number = G_PA_MISS_CHAR) then
     l_project_number := null;
  else
     l_project_number := p_project_number;
  end if;

  if(p_ci_type_id is null or p_ci_type_id = G_PA_MISS_NUM) then
     l_ci_type_id := null;
  else
     l_ci_type_id := p_ci_type_id;
  end if;

  if(p_summary is null) then
     l_summary := null;
  else
     l_summary := p_summary;
  end if;

  if(p_ci_number is null or p_ci_number = G_PA_MISS_CHAR) then
     l_ci_number := null;
  else
     l_ci_number := p_ci_number;
  end if;

  if(p_description is null or p_description = G_PA_MISS_CHAR) then
     l_description := null;
  else
     l_description := p_description;
  end if;

  if(p_status_code is null or p_status_code = G_PA_MISS_CHAR) then
     l_status_code := null;
  else
     l_status_code := p_status_code;
  end if;

  if(p_status is null or p_status = G_PA_MISS_CHAR) then
     l_status := null;
  else
     l_status := p_status;
  end if;

  if(p_owner_id is null or p_owner_id = G_PA_MISS_NUM) then
     l_owner_id := null;
  else
     l_owner_id := p_owner_id;
  end if;

  if(p_progress_status_code is null or p_progress_status_code = G_PA_MISS_CHAR) then
     l_progress_status_code := null;
  else
     l_progress_status_code := p_progress_status_code;
  end if;

  if(p_progress_as_of_date is null or p_progress_as_of_date = G_PA_MISS_DATE) then
     l_progress_as_of_date := null;
  else
     l_progress_as_of_date := p_progress_as_of_date;
  end if;

  if(p_status_overview is null or p_status_overview = G_PA_MISS_CHAR) then
     l_status_overview := null;
  else
     l_status_overview := p_status_overview;
  end if;

  if(p_classification_code is null) then
     l_classification_code := null;
  else
     l_classification_code := p_classification_code;
  end if;

  if(p_reason_code is null) then
     l_reason_code := null;
  else
     l_reason_code := p_reason_code;
  end if;

  if(p_object_id is null or p_object_id = G_PA_MISS_NUM) then
     l_object_id := null;
  else
     l_object_id := p_object_id;
  end if;

  if(p_object_type is null or p_object_type = G_PA_MISS_CHAR) then
     l_object_type := null;
  else
     l_object_type := p_object_type;
  end if;

  if(p_date_required is null or p_date_required = G_PA_MISS_DATE) then
     l_date_required := null;
  else
     l_date_required := p_date_required;
  end if;

  if(p_date_closed is null or p_date_closed = G_PA_MISS_DATE) then
     l_date_closed := null;
  else
     l_date_closed := p_date_closed;
  end if;

  if(p_closed_by_id is null or p_closed_by_id = G_PA_MISS_NUM) then
     l_closed_by_id := null;
  else
     l_closed_by_id := p_closed_by_id;
  end if;

  if(p_resolution is null or p_resolution = G_PA_MISS_CHAR) then
     l_resolution := null;
  else
     l_resolution := p_resolution;
  end if;

  if(p_resolution_code is null or p_resolution_code = G_PA_MISS_NUM) then
     l_resolution_code := null;
  else
     l_resolution_code := p_resolution_code;
  end if;

  if(p_priority_code is null or p_priority_code = G_PA_MISS_CHAR) then
     l_priority_code := null;
  else
     l_priority_code := p_priority_code;
  end if;

  if(p_effort_level_code is null or p_effort_level_code = G_PA_MISS_CHAR) then
     l_effort_level_code := null;
  else
     l_effort_level_code := p_effort_level_code;
  end if;

  if(p_price is null or p_price = G_PA_MISS_NUM) then
     l_price := null;
  else
     l_price := p_price;
  end if;

  if(p_price_currency_code is null or p_price_currency_code = G_PA_MISS_CHAR) then
     l_price_currency_code := null;
  else
     l_price_currency_code := p_price_currency_code;
  end if;

  if(p_source_type_name is null or p_source_type_name = G_PA_MISS_CHAR) then
     l_source_type_name := null;
  else
     l_source_type_name := p_source_type_name;
  end if;

  if(p_source_type_code is null or p_source_type_code = G_PA_MISS_CHAR) then
     l_source_type_code := null;
  else
     l_source_type_code := p_source_type_code;
  end if;

  if(p_source_number is null or p_source_number = G_PA_MISS_CHAR) then
     l_source_number := null;
  else
     l_source_number := p_source_number;
  end if;

  if(p_source_comment is null or p_source_comment = G_PA_MISS_CHAR) then
     l_source_comment := null;
  else
     l_source_comment := p_source_comment;
  end if;

  if(p_source_date_received is null or p_source_date_received = G_PA_MISS_DATE) then
     l_source_date_received := null;
  else
     l_source_date_received := p_source_date_received;
  end if;

  if(p_source_organization is null or p_source_organization = G_PA_MISS_CHAR) then
     l_source_organization := null;
  else
     l_source_organization := p_source_organization;
  end if;

  if(p_source_person is null or p_source_person = G_PA_MISS_CHAR) then
     l_source_person := null;
  else
     l_source_person := p_source_person;
  end if;

  if(p_attribute_category is null or p_attribute_category = G_PA_MISS_CHAR) then
     l_attribute_category := null;
  else
     l_attribute_category := p_attribute_category;
  end if;

  if(p_attribute1 is null or p_attribute1 = G_PA_MISS_CHAR) then
     l_attribute1 := null;
  else
     l_attribute1 := p_attribute1;
  end if;

  if(p_attribute2 is null or p_attribute2 = G_PA_MISS_CHAR) then
     l_attribute2 := null;
  else
     l_attribute2 := p_attribute2;
  end if;

  if(p_attribute3 is null or p_attribute3 = G_PA_MISS_CHAR) then
     l_attribute3 := null;
  else
     l_attribute3 := p_attribute3;
  end if;

  if(p_attribute4 is null or p_attribute4 = G_PA_MISS_CHAR) then
     l_attribute4 := null;
  else
     l_attribute4 := p_attribute4;
  end if;

  if(p_attribute5 is null or p_attribute5 = G_PA_MISS_CHAR) then
     l_attribute5 := null;
  else
     l_attribute5 := p_attribute5;
  end if;

  if(p_attribute6 is null or p_attribute6 = G_PA_MISS_CHAR) then
     l_attribute6 := null;
  else
     l_attribute6 := p_attribute6;
  end if;

  if(p_attribute7 is null or p_attribute7 = G_PA_MISS_CHAR) then
     l_attribute7 := null;
  else
     l_attribute7 := p_attribute7;
  end if;

  if(p_attribute8 is null or p_attribute8 = G_PA_MISS_CHAR) then
     l_attribute8 := null;
  else
     l_attribute8 := p_attribute8;
  end if;

  if(p_attribute9 is null or p_attribute9 = G_PA_MISS_CHAR) then
     l_attribute9 := null;
  else
     l_attribute9 := p_attribute9;
  end if;

  if(p_attribute10 is null or p_attribute10 = G_PA_MISS_CHAR) then
     l_attribute10 := null;
  else
     l_attribute10 := p_attribute10;
  end if;

  if(p_attribute11 is null or p_attribute11 = G_PA_MISS_CHAR) then
     l_attribute11 := null;
  else
     l_attribute11 := p_attribute11;
  end if;

  if(p_attribute12 is null or p_attribute12 = G_PA_MISS_CHAR) then
     l_attribute12 := null;
  else
     l_attribute12 := p_attribute12;
  end if;

  if(p_attribute13 is null or p_attribute13 = G_PA_MISS_CHAR) then
     l_attribute13 := null;
  else
     l_attribute13 := p_attribute13;
  end if;

  if(p_attribute14 is null or p_attribute14 = G_PA_MISS_CHAR) then
     l_attribute14 := null;
  else
     l_attribute14 := p_attribute14;
  end if;

  if(p_attribute15 is null or p_attribute15 = G_PA_MISS_CHAR) then
     l_attribute15 := null;
  else
     l_attribute15 := p_attribute15;
  end if;


  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'calling check_create_ci_allowed';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.check_create_ci_allowed(
                                              p_project_id                      =>  l_project_id
                                             ,p_project_name                    =>  l_project_name
                                             ,p_project_number                  =>  l_project_number
                                             ,p_ci_type_class_code              =>  l_class_code
                                             ,p_ci_type_id                      =>  l_ci_type_id
                                             ,x_ci_type_class_code              =>  l_ci_type_class_code
                                             ,x_auto_number_flag                =>  l_auto_number_flag
                                             ,x_source_attrs_enabled_flag       =>  l_source_attrs_enabled_flag
                                             ,x_return_status                   =>  x_return_status
                                             ,x_msg_count                       =>  x_msg_count
                                             ,x_msg_data                        =>  x_msg_data
                                             );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'After calling check_create_ciallowed';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;
/*Need to get the details on p_api_version_number, p_orig_system_code and p_orig_system_code and write the code which uses these */
/*p_orig_system_code and p_orig_system_reference will be passsed by users
 and What ever user gives those will get inserted in the table as it is. */
  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'about to call validate_param_and_create';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.validate_param_and_create(
                                                p_orig_system_code              =>    p_orig_system_code
                                               ,p_orig_system_reference         =>    p_orig_system_reference
                                               ,p_project_id                    =>    l_project_id
                                               ,p_ci_type_id                    =>    l_ci_type_id
                                               ,p_auto_number_flag              =>    l_auto_number_flag
                                               ,p_source_attrs_enabled_flag     =>    l_source_attrs_enabled_flag
                                               ,p_ci_type_class_code            =>    l_ci_type_class_code
                                               ,p_summary                       =>    l_summary
                                               ,p_ci_number                     =>    l_ci_number
                                               ,p_description                   =>    l_description
                                               ,p_status_code                   =>    l_status_code
                                               ,p_status                        =>    l_status
                                               ,p_owner_id                      =>    l_owner_id
                                               ,p_progress_status_code          =>    l_progress_status_code
                                               ,p_progress_as_of_date           =>    l_progress_as_of_date
                                               ,p_status_overview               =>    l_status_overview
                                               ,p_classification_code           =>    l_classification_code
                                               ,p_reason_code                   =>    l_reason_code
                                               ,p_object_id                     =>    l_object_id
                                               ,p_object_type                   =>    l_object_type
                                               ,p_date_required                 =>    l_date_required
                                               ,p_date_closed                   =>    l_date_closed
                                               ,p_closed_by_id                  =>    l_closed_by_id
                                               ,p_resolution                    =>    l_resolution
                                               ,p_resolution_code               =>    l_resolution_code
                                               ,p_priority_code                 =>    l_priority_code
                                               ,p_effort_level_code             =>    l_effort_level_code
                                               ,p_price                         =>    l_price
                                               ,p_price_currency_code           =>    l_price_currency_code
                                               ,p_source_type_name              =>    l_source_type_name
                                               ,p_source_type_code              =>    l_source_type_code
                                               ,p_source_number                 =>    l_source_number
                                               ,p_source_comment                =>    l_source_comment
                                               ,p_source_date_received          =>    l_source_date_received
                                               ,p_source_organization           =>    l_source_organization
                                               ,p_source_person                 =>    l_source_person
                                               ,p_attribute_category            =>    l_attribute_category
                                               ,p_attribute1                    =>    l_attribute1
                                               ,p_attribute2                    =>    l_attribute2
                                               ,p_attribute3                    =>    l_attribute3
                                               ,p_attribute4                    =>    l_attribute4
                                               ,p_attribute5                    =>    l_attribute5
                                               ,p_attribute6                    =>    l_attribute6
                                               ,p_attribute7                    =>    l_attribute7
                                               ,p_attribute8                    =>    l_attribute8
                                               ,p_attribute9                    =>    l_attribute9
                                               ,p_attribute10                   =>    l_attribute10
                                               ,p_attribute11                   =>    l_attribute11
                                               ,p_attribute12                   =>    l_attribute12
                                               ,p_attribute13                   =>    l_attribute13
                                               ,p_attribute14                   =>    l_attribute14
                                               ,p_attribute15                   =>    l_attribute15
                                               ,x_ci_id                         =>    x_ci_id
                                               ,x_ci_number                     =>    x_ci_number
                                               ,x_return_status                 =>    x_return_status
                                               ,x_msg_count                     =>    x_msg_count
                                               ,x_msg_data                      =>    x_msg_data
                                               );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'after calling validate_param_and_create';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  if (p_commit = fnd_api.g_true and x_return_status = fnd_api.g_ret_sts_success)
  then
        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'about to do a commit';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        commit;
  end if;

  --rest the stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;

EXCEPTION
  when fnd_api.g_exc_unexpected_error then

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_issue;
            end if;
            FND_MSG_PUB.Count_And_Get(
                                      p_count     =>  x_msg_count ,
                                      p_data      =>  x_msg_data  );

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --rest the stack;
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;


  when fnd_api.g_exc_error then

         x_return_status := fnd_api.g_ret_sts_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_issue;
            end if;
         l_msg_count := fnd_msg_pub.count_msg;
         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                                   (p_encoded        => fnd_api.g_false,
                                    p_msg_index      => 1,
                                    p_msg_count      => l_msg_count ,
                                    p_msg_data       => l_msg_data ,
                                    p_data           => l_data,
                                    p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

  when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_issue;
            end if;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_API_PUB',
                                 p_procedure_name => 'create_issue',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

END CREATE_ISSUE;

PROCEDURE CREATE_CHANGE_REQUEST
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
x_ci_id                                         OUT NOCOPY NUMBER,
x_ci_number                                     OUT NOCOPY NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute_category                            IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   IN VARCHAR2 := G_PA_MISS_CHAR
)
IS

  l_module_name                            VARCHAR2(200);


  l_ci_type_class_code                     pa_ci_types_b.ci_type_class_code%type;
  l_auto_number_flag                       pa_ci_types_b.auto_number_flag%type;
  l_source_attrs_enabled_flag              pa_ci_types_b.source_attrs_enabled_flag%type;

  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;

  l_project_id                             pa_projects_all.project_id%type;
  l_project_name                           pa_projects_all.name%type;
  l_project_number                         pa_projects_all.segment1%type;
  l_ci_type_id                             pa_ci_types_b.ci_type_id%type;
  l_summary                                pa_control_items.summary%type;
  l_ci_number                              pa_control_items.ci_number%type;
  l_description                            pa_control_items.description%type;
  l_status_code                            pa_project_statuses.project_status_code%type;
  l_status                                 pa_project_statuses.project_status_name%type;
  l_owner_id                               pa_control_items.owner_id%type;
  l_progress_status_code                   pa_control_items.progress_status_code%type;
  l_progress_as_of_date                    pa_control_items.progress_as_of_date%type;
  l_status_overview                        pa_control_items.status_overview%type;
  l_classification_code                    pa_control_items.classification_code_id%type;
  l_reason_code                            pa_control_items.reason_code_id%type;
  l_object_id                              pa_control_items.object_id%type;
  l_object_type                            pa_control_items.object_type%type;
  l_date_required                          pa_control_items.date_required%type;
  l_date_closed                            pa_control_items.date_closed%type;
  l_closed_by_id                           pa_control_items.closed_by_id%type;
  l_resolution                             pa_control_items.resolution%type;
  l_resolution_code                        pa_control_items.resolution_code_id%type;
  l_priority_code                          pa_control_items.priority_code%type;
  l_effort_level_code                      pa_control_items.effort_level_code%type;
  l_price                                  pa_control_items.price%type;
  l_price_currency_code                    pa_control_items.price_currency_code%type;
  l_source_type_name                       pa_lookups.meaning%type;
  l_source_type_code                       pa_control_items.source_type_code%type;
  l_source_number                          pa_control_items.source_number%type;
  l_source_comment                         pa_control_items.source_comment%type;
  l_source_date_received                   pa_control_items.source_date_received%type;
  l_source_organization                    pa_control_items.source_organization%type;
  l_source_person                          pa_control_items.source_person%type;
  l_attribute_category                     pa_control_items.attribute_category%type;
  l_attribute1                             pa_control_items.attribute1%type;
  l_attribute2                             pa_control_items.attribute1%type;
  l_attribute3                             pa_control_items.attribute1%type;
  l_attribute4                             pa_control_items.attribute1%type;
  l_attribute5                             pa_control_items.attribute1%type;
  l_attribute6                             pa_control_items.attribute1%type;
  l_attribute7                             pa_control_items.attribute1%type;
  l_attribute8                             pa_control_items.attribute1%type;
  l_attribute9                             pa_control_items.attribute1%type;
  l_attribute10                            pa_control_items.attribute1%type;
  l_attribute11                            pa_control_items.attribute1%type;
  l_attribute12                            pa_control_items.attribute1%type;
  l_attribute13                            pa_control_items.attribute1%type;
  l_attribute14                            pa_control_items.attribute1%type;
  l_attribute15                            pa_control_items.attribute1%type;
  l_class_code                             constant varchar2(20) := 'CHANGE_REQUEST';

BEGIN

  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'create_change_request' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pub.create_change_request', p_debug_mode => l_debug_mode);
  end if;

  if fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) then
          fnd_msg_pub.initialize;
  end if;

  if p_commit = fnd_api.g_true then
          savepoint create_change_request;
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of create_change_request', l_debug_level3);
  end if;

  --handle the miss_char and null values
  if(p_project_id is null or p_project_id = G_PA_MISS_NUM) then
     l_project_id := null;
  else
     l_project_id := p_project_id;
  end if;

    if(p_project_name is null or p_project_name = G_PA_MISS_CHAR) then
     l_project_name := null;
  else
     l_project_name := p_project_name;
  end if;

  if(p_project_number is null or p_project_number = G_PA_MISS_CHAR) then
     l_project_number := null;
  else
     l_project_number := p_project_number;
  end if;

  if(p_ci_type_id is null or p_ci_type_id = G_PA_MISS_NUM) then
     l_ci_type_id := null;
  else
     l_ci_type_id := p_ci_type_id;
  end if;

  if(p_summary is null) then
     l_summary := null;
  else
     l_summary := p_summary;
  end if;

  if(p_ci_number is null or p_ci_number = G_PA_MISS_CHAR) then
     l_ci_number := null;
  else
     l_ci_number := p_ci_number;
  end if;

  if(p_description is null or p_description = G_PA_MISS_CHAR) then
     l_description := null;
  else
     l_description := p_description;
  end if;

  if(p_status_code is null or p_status_code = G_PA_MISS_CHAR) then
     l_status_code := null;
  else
     l_status_code := p_status_code;
  end if;

  if(p_status is null or p_status = G_PA_MISS_CHAR) then
     l_status := null;
  else
     l_status := p_status;
  end if;

  if(p_owner_id is null or p_owner_id = G_PA_MISS_NUM) then
     l_owner_id := null;
  else
     l_owner_id := p_owner_id;
  end if;

  if(p_progress_status_code is null or p_progress_status_code = G_PA_MISS_CHAR) then
     l_progress_status_code := null;
  else
     l_progress_status_code := p_progress_status_code;
  end if;

  if(p_progress_as_of_date is null or p_progress_as_of_date = G_PA_MISS_DATE) then
     l_progress_as_of_date := null;
  else
     l_progress_as_of_date := p_progress_as_of_date;
  end if;

  if(p_status_overview is null or p_status_overview = G_PA_MISS_CHAR) then
     l_status_overview := null;
  else
     l_status_overview := p_status_overview;
  end if;

  if(p_classification_code is null) then
     l_classification_code := null;
  else
     l_classification_code := p_classification_code;
  end if;

  if(p_reason_code is null) then
     l_reason_code := null;
  else
     l_reason_code := p_reason_code;
  end if;

  if(p_object_id is null or p_object_id = G_PA_MISS_NUM) then
     l_object_id := null;
  else
     l_object_id := p_object_id;
  end if;

  if(p_object_type is null or p_object_type = G_PA_MISS_CHAR) then
     l_object_type := null;
  else
     l_object_type := p_object_type;
  end if;

  if(p_date_required is null or p_date_required = G_PA_MISS_DATE) then
     l_date_required := null;
  else
     l_date_required := p_date_required;
  end if;

  if(p_date_closed is null or p_date_closed = G_PA_MISS_DATE) then
     l_date_closed := null;
  else
     l_date_closed := p_date_closed;
  end if;

  if(p_closed_by_id is null or p_closed_by_id = G_PA_MISS_NUM) then
     l_closed_by_id := null;
  else
     l_closed_by_id := p_closed_by_id;
  end if;

  if(p_resolution is null or p_resolution = G_PA_MISS_CHAR) then
     l_resolution := null;
  else
     l_resolution := p_resolution;
  end if;

  if(p_resolution_code is null or p_resolution_code = G_PA_MISS_NUM) then
     l_resolution_code := null;
  else
     l_resolution_code := p_resolution_code;
  end if;

  if(p_priority_code is null or p_priority_code = G_PA_MISS_CHAR) then
     l_priority_code := null;
  else
     l_priority_code := p_priority_code;
  end if;

  if(p_effort_level_code is null or p_effort_level_code = G_PA_MISS_CHAR) then
     l_effort_level_code := null;
  else
     l_effort_level_code := p_effort_level_code;
  end if;

  if(p_price is null or p_price = G_PA_MISS_NUM) then
     l_price := null;
  else
     l_price := p_price;
  end if;

  if(p_price_currency_code is null or p_price_currency_code = G_PA_MISS_CHAR) then
     l_price_currency_code := null;
  else
     l_price_currency_code := p_price_currency_code;
  end if;

  if(p_source_type_name is null or p_source_type_name = G_PA_MISS_CHAR) then
     l_source_type_name := null;
  else
     l_source_type_name := p_source_type_name;
  end if;

  if(p_source_type_code is null or p_source_type_code = G_PA_MISS_CHAR) then
     l_source_type_code := null;
  else
     l_source_type_code := p_source_type_code;
  end if;

  if(p_source_number is null or p_source_number = G_PA_MISS_CHAR) then
     l_source_number := null;
  else
     l_source_number := p_source_number;
  end if;

  if(p_source_comment is null or p_source_comment = G_PA_MISS_CHAR) then
     l_source_comment := null;
  else
     l_source_comment := p_source_comment;
  end if;

  if(p_source_date_received is null or p_source_date_received = G_PA_MISS_DATE) then
     l_source_date_received := null;
  else
     l_source_date_received := p_source_date_received;
  end if;

  if(p_source_organization is null or p_source_organization = G_PA_MISS_CHAR) then
     l_source_organization := null;
  else
     l_source_organization := p_source_organization;
  end if;

  if(p_source_person is null or p_source_person = G_PA_MISS_CHAR) then
     l_source_person := null;
  else
     l_source_person := p_source_person;
  end if;

  if(p_attribute_category is null or p_attribute_category = G_PA_MISS_CHAR) then
     l_attribute_category := null;
  else
     l_attribute_category := p_attribute_category;
  end if;

  if(p_attribute1 is null or p_attribute1 = G_PA_MISS_CHAR) then
     l_attribute1 := null;
  else
     l_attribute1 := p_attribute1;
  end if;

  if(p_attribute2 is null or p_attribute2 = G_PA_MISS_CHAR) then
     l_attribute2 := null;
  else
     l_attribute2 := p_attribute2;
  end if;

  if(p_attribute3 is null or p_attribute3 = G_PA_MISS_CHAR) then
     l_attribute3 := null;
  else
     l_attribute3 := p_attribute3;
  end if;

  if(p_attribute4 is null or p_attribute4 = G_PA_MISS_CHAR) then
     l_attribute4 := null;
  else
     l_attribute4 := p_attribute4;
  end if;

  if(p_attribute5 is null or p_attribute5 = G_PA_MISS_CHAR) then
     l_attribute5 := null;
  else
     l_attribute5 := p_attribute5;
  end if;

  if(p_attribute6 is null or p_attribute6 = G_PA_MISS_CHAR) then
     l_attribute6 := null;
  else
     l_attribute6 := p_attribute6;
  end if;

  if(p_attribute7 is null or p_attribute7 = G_PA_MISS_CHAR) then
     l_attribute7 := null;
  else
     l_attribute7 := p_attribute7;
  end if;

  if(p_attribute8 is null or p_attribute8 = G_PA_MISS_CHAR) then
     l_attribute8 := null;
  else
     l_attribute8 := p_attribute8;
  end if;

  if(p_attribute9 is null or p_attribute9 = G_PA_MISS_CHAR) then
     l_attribute9 := null;
  else
     l_attribute9 := p_attribute9;
  end if;

  if(p_attribute10 is null or p_attribute10 = G_PA_MISS_CHAR) then
     l_attribute10 := null;
  else
     l_attribute10 := p_attribute10;
  end if;

  if(p_attribute11 is null or p_attribute11 = G_PA_MISS_CHAR) then
     l_attribute11 := null;
  else
     l_attribute11 := p_attribute11;
  end if;

  if(p_attribute12 is null or p_attribute12 = G_PA_MISS_CHAR) then
     l_attribute12 := null;
  else
     l_attribute12 := p_attribute12;
  end if;

  if(p_attribute13 is null or p_attribute13 = G_PA_MISS_CHAR) then
     l_attribute13 := null;
  else
     l_attribute13 := p_attribute13;
  end if;

  if(p_attribute14 is null or p_attribute14 = G_PA_MISS_CHAR) then
     l_attribute14 := null;
  else
     l_attribute14 := p_attribute14;
  end if;

  if(p_attribute15 is null or p_attribute15 = G_PA_MISS_CHAR) then
     l_attribute15 := null;
  else
     l_attribute15 := p_attribute15;
  end if;


  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'calling check_create_ci_allowed';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.check_create_ci_allowed(
                                              p_project_id                      =>  l_project_id
                                             ,p_project_name                    =>  l_project_name
                                             ,p_project_number                  =>  l_project_number
                                             ,p_ci_type_class_code              =>  l_class_code
                                             ,p_ci_type_id                      =>  l_ci_type_id
                                             ,x_ci_type_class_code              =>  l_ci_type_class_code
                                             ,x_auto_number_flag                =>  l_auto_number_flag
                                             ,x_source_attrs_enabled_flag       =>  l_source_attrs_enabled_flag
                                             ,x_return_status                   =>  x_return_status
                                             ,x_msg_count                       =>  x_msg_count
                                             ,x_msg_data                        =>  x_msg_data
                                             );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'After calling check_create_ci_allowed';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;
/*Need to get the details on p_api_version_number, p_orig_system_code and p_orig_system_code and write the code which uses these */
/*p_orig_system_code and p_orig_system_reference will be passsed by users
 and What ever user gives those will get inserted in the table as it is. */
  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'about to call validate_param_and_create';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.validate_param_and_create(
                                                p_orig_system_code              =>    p_orig_system_code
                                               ,p_orig_system_reference         =>    p_orig_system_reference
                                               ,p_project_id                    =>    l_project_id
                                               ,p_ci_type_id                    =>    l_ci_type_id
                                               ,p_auto_number_flag              =>    l_auto_number_flag
                                               ,p_source_attrs_enabled_flag     =>    l_source_attrs_enabled_flag
                                               ,p_ci_type_class_code            =>    l_ci_type_class_code
                                               ,p_summary                       =>    l_summary
                                               ,p_ci_number                     =>    l_ci_number
                                               ,p_description                   =>    l_description
                                               ,p_status_code                   =>    l_status_code
                                               ,p_status                        =>    l_status
                                               ,p_owner_id                      =>    l_owner_id
                                               ,p_progress_status_code          =>    l_progress_status_code
                                               ,p_progress_as_of_date           =>    l_progress_as_of_date
                                               ,p_status_overview               =>    l_status_overview
                                               ,p_classification_code           =>    l_classification_code
                                               ,p_reason_code                   =>    l_reason_code
                                               ,p_object_id                     =>    l_object_id
                                               ,p_object_type                   =>    l_object_type
                                               ,p_date_required                 =>    l_date_required
                                               ,p_date_closed                   =>    l_date_closed
                                               ,p_closed_by_id                  =>    l_closed_by_id
                                               ,p_resolution                    =>    l_resolution
                                               ,p_resolution_code               =>    l_resolution_code
                                               ,p_priority_code                 =>    l_priority_code
                                               ,p_effort_level_code             =>    l_effort_level_code
                                               ,p_price                         =>    l_price
                                               ,p_price_currency_code           =>    l_price_currency_code
                                               ,p_source_type_name              =>    l_source_type_name
                                               ,p_source_type_code              =>    l_source_type_code
                                               ,p_source_number                 =>    l_source_number
                                               ,p_source_comment                =>    l_source_comment
                                               ,p_source_date_received          =>    l_source_date_received
                                               ,p_source_organization           =>    l_source_organization
                                               ,p_source_person                 =>    l_source_person
                                               ,p_attribute_category            =>    l_attribute_category
                                               ,p_attribute1                    =>    l_attribute1
                                               ,p_attribute2                    =>    l_attribute2
                                               ,p_attribute3                    =>    l_attribute3
                                               ,p_attribute4                    =>    l_attribute4
                                               ,p_attribute5                    =>    l_attribute5
                                               ,p_attribute6                    =>    l_attribute6
                                               ,p_attribute7                    =>    l_attribute7
                                               ,p_attribute8                    =>    l_attribute8
                                               ,p_attribute9                    =>    l_attribute9
                                               ,p_attribute10                   =>    l_attribute10
                                               ,p_attribute11                   =>    l_attribute11
                                               ,p_attribute12                   =>    l_attribute12
                                               ,p_attribute13                   =>    l_attribute13
                                               ,p_attribute14                   =>    l_attribute14
                                               ,p_attribute15                   =>    l_attribute15
                                               ,x_ci_id                         =>    x_ci_id
                                               ,x_ci_number                     =>    x_ci_number
                                               ,x_return_status                 =>    x_return_status
                                               ,x_msg_count                     =>    x_msg_count
                                               ,x_msg_data                      =>    x_msg_data
                                               );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'after calling validate_param_and_create';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  if (p_commit = fnd_api.g_true and x_return_status = fnd_api.g_ret_sts_success)
  then
        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'about to do a commit';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        commit;
  end if;

  --rest the stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;

EXCEPTION
  when fnd_api.g_exc_unexpected_error then

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_change_request;
            end if;
            FND_MSG_PUB.Count_And_Get(
                                      p_count     =>  x_msg_count ,
                                      p_data      =>  x_msg_data  );

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --rest the stack;
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;


  when fnd_api.g_exc_error then

         x_return_status := fnd_api.g_ret_sts_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_change_request;
            end if;
         l_msg_count := fnd_msg_pub.count_msg;
         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                                   (p_encoded        => fnd_api.g_false,
                                    p_msg_index      => 1,
                                    p_msg_count      => l_msg_count ,
                                    p_msg_data       => l_msg_data ,
                                    p_data           => l_data,
                                    p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

  when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_change_request;
            end if;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_API_PUB',
                                 p_procedure_name => 'create_change_request',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

END CREATE_CHANGE_REQUEST;

PROCEDURE CREATE_CHANGE_ORDER
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
p_orig_system_code                              IN VARCHAR2 := null,
p_orig_system_reference                         IN VARCHAR2 := null,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
x_ci_id                                         OUT NOCOPY NUMBER,
x_ci_number                                     OUT NOCOPY NUMBER,
p_project_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_project_name                                  IN VARCHAR2 := G_PA_MISS_CHAR,
p_project_number                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_ci_type_id                                    IN NUMBER   := G_PA_MISS_NUM,
p_summary                                       IN VARCHAR2,
p_ci_number                                     IN VARCHAR2 := G_PA_MISS_CHAR,
p_description                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status_code                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_status                                        IN VARCHAR2 := G_PA_MISS_CHAR,
p_owner_id                                      IN NUMBER   := G_PA_MISS_NUM,
p_progress_status_code                          IN VARCHAR2 := G_PA_MISS_CHAR,
p_progress_as_of_date                           IN DATE     := G_PA_MISS_DATE,
p_status_overview                               IN VARCHAR2 := G_PA_MISS_CHAR,
p_classification_code                           IN NUMBER,
p_reason_code                                   IN NUMBER,
p_object_id                                     IN NUMBER   := G_PA_MISS_NUM,
p_object_type                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_date_required                                 IN DATE     := G_PA_MISS_DATE,
p_date_closed                                   IN DATE     := G_PA_MISS_DATE,
p_closed_by_id                                  IN NUMBER   := G_PA_MISS_NUM,
p_resolution                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_resolution_code                               IN NUMBER   := G_PA_MISS_NUM,
p_priority_code                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_effort_level_code                             IN VARCHAR2 := G_PA_MISS_CHAR,
p_price                                         IN NUMBER   := G_PA_MISS_NUM,
p_price_currency_code                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_name                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_type_code                              IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_number                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_comment                                IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_date_received                          IN DATE     := G_PA_MISS_DATE,
p_source_organization                           IN VARCHAR2 := G_PA_MISS_CHAR,
p_source_person                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute_category                            IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute1                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute2                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute3                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute4                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute5                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute6                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute7                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute8                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute9                                    IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute10                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute11                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute12                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute13                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute14                                   IN VARCHAR2 := G_PA_MISS_CHAR,
p_attribute15                                   IN VARCHAR2 := G_PA_MISS_CHAR
)
IS

  l_module_name                            VARCHAR2(200);


  l_ci_type_class_code                     pa_ci_types_b.ci_type_class_code%type;
  l_auto_number_flag                       pa_ci_types_b.auto_number_flag%type;
  l_source_attrs_enabled_flag              pa_ci_types_b.source_attrs_enabled_flag%type;

  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;

  l_project_id                             pa_projects_all.project_id%type;
  l_project_name                           pa_projects_all.name%type;
  l_project_number                         pa_projects_all.segment1%type;
  l_ci_type_id                             pa_ci_types_b.ci_type_id%type;
  l_summary                                pa_control_items.summary%type;
  l_ci_number                              pa_control_items.ci_number%type;
  l_description                            pa_control_items.description%type;
  l_status_code                            pa_project_statuses.project_status_code%type;
  l_status                                 pa_project_statuses.project_status_name%type;
  l_owner_id                               pa_control_items.owner_id%type;
  l_progress_status_code                   pa_control_items.progress_status_code%type;
  l_progress_as_of_date                    pa_control_items.progress_as_of_date%type;
  l_status_overview                        pa_control_items.status_overview%type;
  l_classification_code                    pa_control_items.classification_code_id%type;
  l_reason_code                            pa_control_items.reason_code_id%type;
  l_object_id                              pa_control_items.object_id%type;
  l_object_type                            pa_control_items.object_type%type;
  l_date_required                          pa_control_items.date_required%type;
  l_date_closed                            pa_control_items.date_closed%type;
  l_closed_by_id                           pa_control_items.closed_by_id%type;
  l_resolution                             pa_control_items.resolution%type;
  l_resolution_code                        pa_control_items.resolution_code_id%type;
  l_priority_code                          pa_control_items.priority_code%type;
  l_effort_level_code                      pa_control_items.effort_level_code%type;
  l_price                                  pa_control_items.price%type;
  l_price_currency_code                    pa_control_items.price_currency_code%type;
  l_source_type_name                       pa_lookups.meaning%type;
  l_source_type_code                       pa_control_items.source_type_code%type;
  l_source_number                          pa_control_items.source_number%type;
  l_source_comment                         pa_control_items.source_comment%type;
  l_source_date_received                   pa_control_items.source_date_received%type;
  l_source_organization                    pa_control_items.source_organization%type;
  l_source_person                          pa_control_items.source_person%type;
  l_attribute_category                     pa_control_items.attribute_category%type;
  l_attribute1                             pa_control_items.attribute1%type;
  l_attribute2                             pa_control_items.attribute1%type;
  l_attribute3                             pa_control_items.attribute1%type;
  l_attribute4                             pa_control_items.attribute1%type;
  l_attribute5                             pa_control_items.attribute1%type;
  l_attribute6                             pa_control_items.attribute1%type;
  l_attribute7                             pa_control_items.attribute1%type;
  l_attribute8                             pa_control_items.attribute1%type;
  l_attribute9                             pa_control_items.attribute1%type;
  l_attribute10                            pa_control_items.attribute1%type;
  l_attribute11                            pa_control_items.attribute1%type;
  l_attribute12                            pa_control_items.attribute1%type;
  l_attribute13                            pa_control_items.attribute1%type;
  l_attribute14                            pa_control_items.attribute1%type;
  l_attribute15                            pa_control_items.attribute1%type;
  l_class_code                             constant varchar2(20) := 'CHANGE_ORDER';

BEGIN

  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'create_change_order' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pub.create_change_order', p_debug_mode => l_debug_mode);
  end if;

  if fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) then
          fnd_msg_pub.initialize;
  end if;

  if p_commit = fnd_api.g_true then
          savepoint create_change_order;
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of create_change_order', l_debug_level3);
  end if;

  --handle the miss_char and null values
  if(p_project_id is null or p_project_id = G_PA_MISS_NUM) then
     l_project_id := null;
  else
     l_project_id := p_project_id;
  end if;

    if(p_project_name is null or p_project_name = G_PA_MISS_CHAR) then
     l_project_name := null;
  else
     l_project_name := p_project_name;
  end if;

  if(p_project_number is null or p_project_number = G_PA_MISS_CHAR) then
     l_project_number := null;
  else
     l_project_number := p_project_number;
  end if;

  if(p_ci_type_id is null or p_ci_type_id = G_PA_MISS_NUM) then
     l_ci_type_id := null;
  else
     l_ci_type_id := p_ci_type_id;
  end if;

  if(p_summary is null) then
     l_summary := null;
  else
     l_summary := p_summary;
  end if;

  if(p_ci_number is null or p_ci_number = G_PA_MISS_CHAR) then
     l_ci_number := null;
  else
     l_ci_number := p_ci_number;
  end if;

  if(p_description is null or p_description = G_PA_MISS_CHAR) then
     l_description := null;
  else
     l_description := p_description;
  end if;

  if(p_status_code is null or p_status_code = G_PA_MISS_CHAR) then
     l_status_code := null;
  else
     l_status_code := p_status_code;
  end if;

  if(p_status is null or p_status = G_PA_MISS_CHAR) then
     l_status := null;
  else
     l_status := p_status;
  end if;

  if(p_owner_id is null or p_owner_id = G_PA_MISS_NUM) then
     l_owner_id := null;
  else
     l_owner_id := p_owner_id;
  end if;

  if(p_progress_status_code is null or p_progress_status_code = G_PA_MISS_CHAR) then
     l_progress_status_code := null;
  else
     l_progress_status_code := p_progress_status_code;
  end if;

  if(p_progress_as_of_date is null or p_progress_as_of_date = G_PA_MISS_DATE) then
     l_progress_as_of_date := null;
  else
     l_progress_as_of_date := p_progress_as_of_date;
  end if;

  if(p_status_overview is null or p_status_overview = G_PA_MISS_CHAR) then
     l_status_overview := null;
  else
     l_status_overview := p_status_overview;
  end if;

  if(p_classification_code is null) then
     l_classification_code := null;
  else
     l_classification_code := p_classification_code;
  end if;

  if(p_reason_code is null) then
     l_reason_code := null;
  else
     l_reason_code := p_reason_code;
  end if;

  if(p_object_id is null or p_object_id = G_PA_MISS_NUM) then
     l_object_id := null;
  else
     l_object_id := p_object_id;
  end if;

  if(p_object_type is null or p_object_type = G_PA_MISS_CHAR) then
     l_object_type := null;
  else
     l_object_type := p_object_type;
  end if;

  if(p_date_required is null or p_date_required = G_PA_MISS_DATE) then
     l_date_required := null;
  else
     l_date_required := p_date_required;
  end if;

  if(p_date_closed is null or p_date_closed = G_PA_MISS_DATE) then
     l_date_closed := null;
  else
     l_date_closed := p_date_closed;
  end if;

  if(p_closed_by_id is null or p_closed_by_id = G_PA_MISS_NUM) then
     l_closed_by_id := null;
  else
     l_closed_by_id := p_closed_by_id;
  end if;

  if(p_resolution is null or p_resolution = G_PA_MISS_CHAR) then
     l_resolution := null;
  else
     l_resolution := p_resolution;
  end if;

  if(p_resolution_code is null or p_resolution_code = G_PA_MISS_NUM) then
     l_resolution_code := null;
  else
     l_resolution_code := p_resolution_code;
  end if;

  if(p_priority_code is null or p_priority_code = G_PA_MISS_CHAR) then
     l_priority_code := null;
  else
     l_priority_code := p_priority_code;
  end if;

  if(p_effort_level_code is null or p_effort_level_code = G_PA_MISS_CHAR) then
     l_effort_level_code := null;
  else
     l_effort_level_code := p_effort_level_code;
  end if;

  if(p_price is null or p_price = G_PA_MISS_NUM) then
     l_price := null;
  else
     l_price := p_price;
  end if;

  if(p_price_currency_code is null or p_price_currency_code = G_PA_MISS_CHAR) then
     l_price_currency_code := null;
  else
     l_price_currency_code := p_price_currency_code;
  end if;

  if(p_source_type_name is null or p_source_type_name = G_PA_MISS_CHAR) then
     l_source_type_name := null;
  else
     l_source_type_name := p_source_type_name;
  end if;

  if(p_source_type_code is null or p_source_type_code = G_PA_MISS_CHAR) then
     l_source_type_code := null;
  else
     l_source_type_code := p_source_type_code;
  end if;

  if(p_source_number is null or p_source_number = G_PA_MISS_CHAR) then
     l_source_number := null;
  else
     l_source_number := p_source_number;
  end if;

  if(p_source_comment is null or p_source_comment = G_PA_MISS_CHAR) then
     l_source_comment := null;
  else
     l_source_comment := p_source_comment;
  end if;

  if(p_source_date_received is null or p_source_date_received = G_PA_MISS_DATE) then
     l_source_date_received := null;
  else
     l_source_date_received := p_source_date_received;
  end if;

  if(p_source_organization is null or p_source_organization = G_PA_MISS_CHAR) then
     l_source_organization := null;
  else
     l_source_organization := p_source_organization;
  end if;

  if(p_source_person is null or p_source_person = G_PA_MISS_CHAR) then
     l_source_person := null;
  else
     l_source_person := p_source_person;
  end if;

  if(p_attribute_category is null or p_attribute_category = G_PA_MISS_CHAR) then
     l_attribute_category := null;
  else
     l_attribute_category := p_attribute_category;
  end if;

  if(p_attribute1 is null or p_attribute1 = G_PA_MISS_CHAR) then
     l_attribute1 := null;
  else
     l_attribute1 := p_attribute1;
  end if;

  if(p_attribute2 is null or p_attribute2 = G_PA_MISS_CHAR) then
     l_attribute2 := null;
  else
     l_attribute2 := p_attribute2;
  end if;

  if(p_attribute3 is null or p_attribute3 = G_PA_MISS_CHAR) then
     l_attribute3 := null;
  else
     l_attribute3 := p_attribute3;
  end if;

  if(p_attribute4 is null or p_attribute4 = G_PA_MISS_CHAR) then
     l_attribute4 := null;
  else
     l_attribute4 := p_attribute4;
  end if;

  if(p_attribute5 is null or p_attribute5 = G_PA_MISS_CHAR) then
     l_attribute5 := null;
  else
     l_attribute5 := p_attribute5;
  end if;

  if(p_attribute6 is null or p_attribute6 = G_PA_MISS_CHAR) then
     l_attribute6 := null;
  else
     l_attribute6 := p_attribute6;
  end if;

  if(p_attribute7 is null or p_attribute7 = G_PA_MISS_CHAR) then
     l_attribute7 := null;
  else
     l_attribute7 := p_attribute7;
  end if;

  if(p_attribute8 is null or p_attribute8 = G_PA_MISS_CHAR) then
     l_attribute8 := null;
  else
     l_attribute8 := p_attribute8;
  end if;

  if(p_attribute9 is null or p_attribute9 = G_PA_MISS_CHAR) then
     l_attribute9 := null;
  else
     l_attribute9 := p_attribute9;
  end if;

  if(p_attribute10 is null or p_attribute10 = G_PA_MISS_CHAR) then
     l_attribute10 := null;
  else
     l_attribute10 := p_attribute10;
  end if;

  if(p_attribute11 is null or p_attribute11 = G_PA_MISS_CHAR) then
     l_attribute11 := null;
  else
     l_attribute11 := p_attribute11;
  end if;

  if(p_attribute12 is null or p_attribute12 = G_PA_MISS_CHAR) then
     l_attribute12 := null;
  else
     l_attribute12 := p_attribute12;
  end if;

  if(p_attribute13 is null or p_attribute13 = G_PA_MISS_CHAR) then
     l_attribute13 := null;
  else
     l_attribute13 := p_attribute13;
  end if;

  if(p_attribute14 is null or p_attribute14 = G_PA_MISS_CHAR) then
     l_attribute14 := null;
  else
     l_attribute14 := p_attribute14;
  end if;

  if(p_attribute15 is null or p_attribute15 = G_PA_MISS_CHAR) then
     l_attribute15 := null;
  else
     l_attribute15 := p_attribute15;
  end if;


  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'calling check_create_ci_allowed';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.check_create_ci_allowed(
                                              p_project_id                      =>  l_project_id
                                             ,p_project_name                    =>  l_project_name
                                             ,p_project_number                  =>  l_project_number
                                             ,p_ci_type_class_code              =>  l_class_code
                                             ,p_ci_type_id                      =>  l_ci_type_id
                                             ,x_ci_type_class_code              =>  l_ci_type_class_code
                                             ,x_auto_number_flag                =>  l_auto_number_flag
                                             ,x_source_attrs_enabled_flag       =>  l_source_attrs_enabled_flag
                                             ,x_return_status                   =>  x_return_status
                                             ,x_msg_count                       =>  x_msg_count
                                             ,x_msg_data                        =>  x_msg_data
                                             );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'After calling check_create_ci_allowed';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;
/*p_orig_system_code and p_orig_system_reference will be passsed by users
 and What ever user gives those will get inserted in the table as it is. */

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'about to call validate_param_and_create';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.validate_param_and_create(
                                                p_orig_system_code              =>    p_orig_system_code
                                               ,p_orig_system_reference         =>    p_orig_system_reference
                                               ,p_project_id                    =>    l_project_id
                                               ,p_ci_type_id                    =>    l_ci_type_id
                                               ,p_auto_number_flag              =>    l_auto_number_flag
                                               ,p_source_attrs_enabled_flag     =>    l_source_attrs_enabled_flag
                                               ,p_ci_type_class_code            =>    l_ci_type_class_code
                                               ,p_summary                       =>    l_summary
                                               ,p_ci_number                     =>    l_ci_number
                                               ,p_description                   =>    l_description
                                               ,p_status_code                   =>    l_status_code
                                               ,p_status                        =>    l_status
                                               ,p_owner_id                      =>    l_owner_id
                                               ,p_progress_status_code          =>    l_progress_status_code
                                               ,p_progress_as_of_date           =>    l_progress_as_of_date
                                               ,p_status_overview               =>    l_status_overview
                                               ,p_classification_code           =>    l_classification_code
                                               ,p_reason_code                   =>    l_reason_code
                                               ,p_object_id                     =>    l_object_id
                                               ,p_object_type                   =>    l_object_type
                                               ,p_date_required                 =>    l_date_required
                                               ,p_date_closed                   =>    l_date_closed
                                               ,p_closed_by_id                  =>    l_closed_by_id
                                               ,p_resolution                    =>    l_resolution
                                               ,p_resolution_code               =>    l_resolution_code
                                               ,p_priority_code                 =>    l_priority_code
                                               ,p_effort_level_code             =>    l_effort_level_code
                                               ,p_price                         =>    l_price
                                               ,p_price_currency_code           =>    l_price_currency_code
                                               ,p_source_type_name              =>    l_source_type_name
                                               ,p_source_type_code              =>    l_source_type_code
                                               ,p_source_number                 =>    l_source_number
                                               ,p_source_comment                =>    l_source_comment
                                               ,p_source_date_received          =>    l_source_date_received
                                               ,p_source_organization           =>    l_source_organization
                                               ,p_source_person                 =>    l_source_person
                                               ,p_attribute_category            =>    l_attribute_category
                                               ,p_attribute1                    =>    l_attribute1
                                               ,p_attribute2                    =>    l_attribute2
                                               ,p_attribute3                    =>    l_attribute3
                                               ,p_attribute4                    =>    l_attribute4
                                               ,p_attribute5                    =>    l_attribute5
                                               ,p_attribute6                    =>    l_attribute6
                                               ,p_attribute7                    =>    l_attribute7
                                               ,p_attribute8                    =>    l_attribute8
                                               ,p_attribute9                    =>    l_attribute9
                                               ,p_attribute10                   =>    l_attribute10
                                               ,p_attribute11                   =>    l_attribute11
                                               ,p_attribute12                   =>    l_attribute12
                                               ,p_attribute13                   =>    l_attribute13
                                               ,p_attribute14                   =>    l_attribute14
                                               ,p_attribute15                   =>    l_attribute15
                                               ,x_ci_id                         =>    x_ci_id
                                               ,x_ci_number                     =>    x_ci_number
                                               ,x_return_status                 =>    x_return_status
                                               ,x_msg_count                     =>    x_msg_count
                                               ,x_msg_data                      =>    x_msg_data
                                               );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'after calling validate_param_and_create';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  if (p_commit = fnd_api.g_true and x_return_status = fnd_api.g_ret_sts_success)
  then
        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'about to do a commit';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        commit;
  end if;

  --rest the stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;

EXCEPTION
  when fnd_api.g_exc_unexpected_error then

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_change_order;
            end if;
            FND_MSG_PUB.Count_And_Get(
                                      p_count     =>  x_msg_count ,
                                      p_data      =>  x_msg_data  );

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --rest the stack;
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;


  when fnd_api.g_exc_error then

         x_return_status := fnd_api.g_ret_sts_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_change_order;
            end if;
         l_msg_count := fnd_msg_pub.count_msg;
         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                                   (p_encoded        => fnd_api.g_false,
                                    p_msg_index      => 1,
                                    p_msg_count      => l_msg_count ,
                                    p_msg_data       => l_msg_data ,
                                    p_data           => l_data,
                                    p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

  when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --do a rollback;
            if p_commit = fnd_api.g_true then
                 rollback to  create_change_order;
            end if;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_API_PUB',
                                 p_procedure_name => 'create_change_order',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

         /*Initialize the out variables back to null*/
         x_ci_id         := null;
         x_ci_number     := null;

         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

END CREATE_CHANGE_ORDER;

PROCEDURE CREATE_ACTION
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
p_ci_id                                         IN NUMBER := G_PA_MISS_NUM,
p_action_tbl                                    IN ci_actions_in_tbl_type,
x_action_tbl                                    OUT NOCOPY ci_actions_out_tbl_type
)
IS



  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_action_tbl                             ci_actions_in_tbl_type;
  l_ci_id                                  pa_control_items.ci_id%type;
  l_project_id                             pa_control_items.project_id%type;
BEGIN

  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'create_action' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pub.create_action', p_debug_mode => l_debug_mode);
  end if;

  if fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) then
          fnd_msg_pub.initialize;
  end if;

  if p_commit = fnd_api.g_true then
          savepoint create_action;
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of create_action', l_debug_level3);
  end if;

 --handling the g_pa_miss_xxx for p_ci_id
  if(p_ci_id is null or p_ci_id = G_PA_MISS_NUM) then
     l_ci_id := null;
  else
     l_ci_id := p_ci_id;
  end if;

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'Calling check_create_action_allow';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  PA_CONTROL_API_PVT.check_create_action_allow(
                                                p_ci_id                   =>  l_ci_id
                                               ,x_project_id              =>  l_project_id
                                               ,x_return_status           =>  x_return_status
                                               ,x_msg_count               =>  x_msg_count
                                               ,x_msg_data                =>  x_msg_data
                                               );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'Calling validate_action_attributes';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  /*Passing the l_ci_id here which was validated in check_create_action_allow*/
  PA_CONTROL_API_PVT.validate_action_attributes(
                                                p_ci_id                   =>  l_ci_id
                                               ,p_project_id              =>  l_project_id
                                               ,p_action_tbl              =>  p_action_tbl
                                               ,x_action_tbl              =>  l_action_tbl
                                               ,x_return_status           =>  x_return_status
                                               ,x_msg_count               =>  x_msg_count
                                               ,x_msg_data                =>  x_msg_data
                                                );

  if l_debug_mode = 'Y' then
      pa_debug.g_err_stage:= 'Calling PA_CONTROL_API_PVT.create_action';
      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  /*Passing the l_ci_id here which was validated in check_create_action_allow*/
  PA_CONTROL_API_PVT.create_action(
                                    p_action_tbl              =>  l_action_tbl
                                   ,p_ci_id                   =>  l_ci_id
                                   ,x_action_tbl              =>  x_action_tbl
                                   ,x_return_status           =>  x_return_status
                                   ,x_msg_count               =>  x_msg_count
                                   ,x_msg_data                =>  x_msg_data
                                   );

  if (p_commit = fnd_api.g_true and x_return_status = fnd_api.g_ret_sts_success)
  then
        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'about to do a commit';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        commit;
  end if;

  --rest the stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;

Exception
  when fnd_api.g_exc_error then

         x_return_status := fnd_api.g_ret_sts_error;

         --do a rollback;
         if p_commit = fnd_api.g_true then
              rollback to  create_action;
         end if;

         l_msg_count := fnd_msg_pub.count_msg;
         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                                   (p_encoded        => fnd_api.g_false,
                                    p_msg_index      => 1,
                                    p_msg_count      => l_msg_count ,
                                    p_msg_data       => l_msg_data ,
                                    p_data           => l_data,
                                    p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         /*Initialize the out variables back to null*/
         /*set the elements in the out table to null here*/
         for i in 1..x_action_tbl.count
         loop
         x_action_tbl(i).action_id     := null;
         x_action_tbl(i).action_number := null;
         end loop;


         --rest the stack;
         if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
         end if;
  when others then

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         --do a rollback;
         if p_commit = fnd_api.g_true then
              rollback to  create_action;

         end if;

         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pub',
                                 p_procedure_name => 'create_action',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

         /*Initialize the out variables back to null*/
         /*set the elements in the out table to null here*/
         for i in 1..x_action_tbl.count
         loop
         x_action_tbl(i).action_id     := null;
         x_action_tbl(i).action_number := null;
         end loop;
         --rest the stack;
         if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
         end if;
END CREATE_ACTION;


PROCEDURE TAKE_ACTION
(
p_commit                                        IN VARCHAR2 := FND_API.G_FALSE,
p_init_msg_list                                 IN VARCHAR2 := FND_API.G_FALSE,
p_api_version_number                            IN NUMBER   := G_PA_MISS_NUM,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2,
p_ci_id                                         IN NUMBER := G_PA_MISS_NUM,
p_action_id                                     IN NUMBER := G_PA_MISS_NUM,
p_action_number                                 IN NUMBER := G_PA_MISS_NUM,
p_close_action_flag                             IN VARCHAR2 := 'N',
p_response_text                                 IN VARCHAR2 := G_PA_MISS_CHAR,
p_sign_off_flag                                 IN VARCHAR2 := 'N',
p_reassign_action_flag                          IN VARCHAR2 := 'N',
p_reassign_to_id                                IN NUMBER := G_PA_MISS_NUM,
p_reassign_request_text                         IN VARCHAR2 := G_PA_MISS_CHAR,
p_required_by_date                              IN DATE := G_PA_MISS_DATE
)
is


cursor get_action_attrs(p_action_id number)
is
select sign_off_required_flag, record_version_number, date_required, ci_id, status_code
from pa_ci_actions
where ci_action_id = p_action_id;

cursor close_notification(p_action_id number)
is
select wfi.notification_id,
wfi.item_type,
wfi.item_key
from pa_wf_processes pwp,
wf_item_activity_statuses_v wfi
where pwp.entity_key2 = p_action_id
and pwp.item_type ='PAWFCIAC'
and wfi.item_type = pwp.item_type
and wfi.item_key = pwp.item_key
and wfi.activity_type_code ='NOTICE'
and wfi.activity_status_code ='NOTIFIED';

  close_notification_rec                  close_notification%rowtype;
  get_action_attrs_rec                    get_action_attrs%rowtype;



  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_action_id                              pa_ci_actions.ci_action_id%type;
  l_party_id                               NUMBER := 0;
  l_user_id                                NUMBER := 0;
  l_assignee_id                            NUMBER := null;
  l_perform_action                         VARCHAR2(1) := null;
  l_ci_comment_id                          pa_ci_comments.ci_comment_id%type;
  l_sign_off_flag                          VARCHAR2(1);
  l_response_text                          pa_ci_comments.comment_text%type;
  l_reassign_request_text                  pa_ci_comments.comment_text%type;
  l_required_by_date                       pa_ci_actions.date_required%type;
  l_reassign_to_id                         pa_ci_actions.assigned_to%type;
  l_project_id                             pa_control_items.project_id%TYPE;

begin

  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'take_action' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pub.take_action', p_debug_mode => l_debug_mode);
  end if;

  if fnd_api.to_boolean(nvl(p_init_msg_list, fnd_api.g_true)) then
          fnd_msg_pub.initialize;
  end if;

  if p_commit = fnd_api.g_true then
          savepoint take_action;
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of take_action', l_debug_level3);
  end if;

  --Get the party_id for the logged in user
  l_user_id  := fnd_global.user_id;
  l_party_id := pa_control_items_utils.getpartyid(l_user_id);

  /*Check whether the user has privilige to update this action or not and whether the passed action is valid or not*/
  /*for checking the privilege check the party id of the logged in user with party id of person to whom the action is assigned*/
  PA_CONTROL_API_PVT.validate_priv_and_action(
                                                p_ci_id                   =>  p_ci_id
                                               ,p_action_id               =>  p_action_id
                                               ,p_action_number           =>  p_action_number
                                               ,x_action_id               =>  l_action_id
                                               ,x_assignee_id             =>  l_assignee_id
                                               ,x_project_id              =>  l_project_id
                                               ,x_return_status           =>  x_return_status
                                               ,x_msg_count               =>  x_msg_count
                                               ,x_msg_data                =>  x_msg_data
                                              );
  /* at this point in code action_id and assignee id would have been dervied if code reaches here*/
  /* compare the assignee_id for this action with the party id of the logged inuser to determine the priv
     to take action*/
  if l_party_id is null then
        pa_utils.add_message(p_app_short_name    => 'PA',
                             p_msg_name          => 'PA_CI_ACTION_NO_ACCESS');
        if (l_debug_mode = 'Y') then
             pa_debug.g_err_stage := 'Apps Initialization is not been done';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        raise fnd_api.g_exc_error;
  elsif( l_assignee_id is not null and (l_assignee_id <> l_party_id) ) then
    /*user doesnt have privilige to update the action*/
        pa_utils.add_message(p_app_short_name    => 'PA',
                             p_msg_name          => 'PA_CI_ACTION_NO_ACCESS');
        if (l_debug_mode = 'Y') then
             pa_debug.g_err_stage := 'user doesnt have access to update the action';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        raise fnd_api.g_exc_error;
  end if;

  if( p_close_action_flag = 'Y' and p_reassign_action_flag = 'Y') then
        pa_utils.add_message(p_app_short_name    => 'PA',
                             p_msg_name          => 'PA_CI_BOTH_REASSGN_CLSE');
        if (l_debug_mode = 'Y') then
             pa_debug.g_err_stage := 'you cannot both close and reassign the action.';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        raise fnd_api.g_exc_error;
  end if;--  if( p_close_action_flag := 'Y' and p_reassign_action_flag := 'Y') then

  /*validathe value for the close action flg. It can be either Y, N or G_PA_MISS_CHAR*/
  if (p_close_action_flag <> 'N' and p_close_action_flag <> 'Y' and p_close_action_flag <> G_PA_MISS_CHAR) then
        pa_utils.add_message(p_app_short_name    => 'PA',
                             p_msg_name          => 'PA_CI_INV_CLS_ACT_FLG');
        if (l_debug_mode = 'Y') then
             pa_debug.g_err_stage := 'Invalid value for close action flag';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        raise fnd_api.g_exc_error;
  end if;

  /*validathe value for the reassign action flg. It can be either Y, N or G_PA_MISS_CHAR*/
  if (p_reassign_action_flag <> 'N' and p_reassign_action_flag <> 'Y' and
      p_reassign_action_flag <> G_PA_MISS_CHAR ) then
        pa_utils.add_message(p_app_short_name    => 'PA',
                             p_msg_name          => 'PA_CI_INV_REASSGN_ACT_FLG');
        if (l_debug_mode = 'Y') then
             pa_debug.g_err_stage := 'Invalid value for reassign action flag';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        raise fnd_api.g_exc_error;
  end if;

  /*now check which action of three close/reassign or keep open has to be performed*/
  if( p_close_action_flag = 'Y' and
      (p_reassign_action_flag = 'N' or p_reassign_action_flag = G_PA_MISS_CHAR) ) then
      l_perform_action := 'C';
  elsif(p_reassign_action_flag = 'Y' and
      (p_close_action_flag = 'N' or p_close_action_flag = G_PA_MISS_CHAR) )  then
      l_perform_action := 'R';
  else
      l_perform_action := 'O';
  end if;

  if(l_perform_action is not null and l_perform_action = 'C') then

       open get_action_attrs(l_action_id);
       fetch get_action_attrs into get_action_attrs_rec;
       close get_action_attrs;

       /*Only open actions can be closed*/
       if get_action_attrs_rec.status_code <> 'CI_ACTION_OPEN' then
              pa_utils.add_message(p_app_short_name    => 'PA',
                                   p_msg_name          => 'PA_CI_CLS_OPEN_ACT');
              if (l_debug_mode = 'Y') then
		    pa_debug.g_err_stage := 'only open actions can be closed';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              end if;
              x_return_status := FND_API.G_RET_STS_ERROR;
              raise FND_API.G_EXC_ERROR;
       end if;

       if(get_action_attrs_rec.sign_off_required_flag = 'Y') then
           /*sign off flag is acknowledged only when sign_off_required_flag is Y*/
           /*although sign off is optional but if a value is supplied then it should be either Y or N*/
           if(p_sign_off_flag <> 'N' and p_sign_off_flag <> 'Y') then
                pa_utils.add_message(p_app_short_name    => 'PA',
                                     p_msg_name          => 'PA_CI_INV_SIGN_OFF_FLAG');
                if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'sign off flag can either be Y or N';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
           else
               l_sign_off_flag := p_sign_off_flag;
           end if;
       else--       if(get_action_attrs_rec.sign_off_required_flag = 'Y') then
           /*if sign_off_required_flag is not Y then sign_off flag would be N*/
           l_sign_off_flag := 'N';
       end if;  --     if(get_action_attrs_rec.sign_off_required_flag = 'Y') then

       --a new record gets created in pa_ci_comments with response text if response text is passed.
       if (p_response_text = G_PA_MISS_CHAR or p_response_text is null ) then
            l_response_text := null;
       else
            l_response_text := p_response_text;
       end if;--if (p_response_text = G_PA_MISS_CHAR) then

            pa_ci_actions_pvt.close_ci_action(
                                              p_validate_only          => fnd_api.g_false,
                                              p_ci_action_id           => l_action_id,
                                              p_sign_off_flag          => l_sign_off_flag,
                                              p_record_version_number  => get_action_attrs_rec.record_version_number,
                                              p_comment_text           => l_response_text,
                                              p_last_updated_by        => fnd_global.user_id,
                                              p_last_update_date       => sysdate,
                                              p_last_update_login      => fnd_global.login_id,
                                              x_return_status          => x_return_status,
                                              x_msg_count              => x_msg_count,
                                              x_msg_data               => x_msg_data
                                             );

       if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           if (l_debug_mode = 'Y') then
                pa_debug.g_err_stage := 'error occured while closing the action';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           raise fnd_api.g_exc_unexpected_error;
       end if;

      /*check for open notifications for this action which is being closed. Close the open notification for this action*/
      open close_notification(l_action_id);
      fetch close_notification into close_notification_rec;
      if(close_notification%notfound) then
             null;
      else
             pa_control_items_workflow.close_notification(
                                                              p_item_type       =>  close_notification_rec.item_type,
                                                              p_item_key        =>  close_notification_rec.item_key,
                                                              p_nid             =>  close_notification_rec.notification_id,
                                                              p_action          =>  l_perform_action,
                                                              p_sign_off_flag   =>  l_sign_off_flag,
                                                              p_response        =>  l_response_text,
                                                              x_msg_count       =>  x_msg_count,
                                                              x_msg_data        =>  x_msg_data,
                                                              x_return_status   =>  x_return_status
                                                         );
      end if;

      if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
          if (l_debug_mode = 'Y') then
               pa_debug.g_err_stage := 'error occurred while closing the notification';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          end if;
          raise fnd_api.g_exc_unexpected_error;
     end if;

  end if;--  if(l_perform_action is not null and l_perform_action = 'C') then

  if(l_perform_action is not null and l_perform_action = 'R') then

       open get_action_attrs(l_action_id);
       fetch get_action_attrs into get_action_attrs_rec;
       close get_action_attrs;

        /*only open actions can be reassigned.*/
        if get_action_attrs_rec.status_code <> 'CI_ACTION_OPEN' then
              pa_utils.add_message(p_app_short_name    => 'PA',
                                   p_msg_name          => 'PA_CI_REASSGN_OPEN_ACT');
              if (l_debug_mode = 'Y') then
		    pa_debug.g_err_stage := 'only open actions can be reassigned';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              end if;
              x_return_status := FND_API.G_RET_STS_ERROR;
              raise FND_API.G_EXC_ERROR;
       end if;


       if(get_action_attrs_rec.sign_off_required_flag = 'Y') then
           /*sign off flag is acknowledged only when sign_off_required_flag is Y*/
           /*although sign off is optional but if a value is supplied then it should be either Y or N*/
           if(p_sign_off_flag <> 'N' and p_sign_off_flag <> 'Y') then
                pa_utils.add_message(p_app_short_name    => 'PA',
                                     p_msg_name          => 'PA_CI_INV_SIGN_OFF_FLAG');
                if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'sign off flag can either be Y or N';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
           else
               l_sign_off_flag := p_sign_off_flag;
           end if;
       else--       if(get_action_attrs_rec.sign_off_required_flag = 'Y') then
           /*if sign_off_required_flag is not Y then sign_off flag would be N*/
           l_sign_off_flag := 'N';
       end if;  --     if(get_action_attrs_rec.sign_off_required_flag = 'Y') then

       if (p_response_text = G_PA_MISS_CHAR or p_response_text is null) then
            l_response_text := null;
       else
            l_response_text := p_response_text;
       end if;--if (p_response_text = G_PA_MISS_CHAR) then

       if (p_reassign_request_text = G_PA_MISS_CHAR or p_reassign_request_text is null) then
            l_reassign_request_text := null;
       else
            l_reassign_request_text := p_reassign_request_text;
       end if;--if (p_reassign_request_text = G_PA_MISS_CHAR) then

      if(p_required_by_date = G_PA_MISS_DATE or p_required_by_date is null) then
            l_required_by_date := null;
       else
            l_required_by_date := p_required_by_date;
      end if;

       if(get_action_attrs_rec.date_required <> null) then
          /*defaulting the required by date while reassigning with the action required by date if this was given while
            creating the action*/
          if( l_required_by_date is null) then
              l_required_by_date := get_action_attrs_rec.date_required;
          else
              l_required_by_date := l_required_by_date;
          end if;
       else
          l_required_by_date := l_required_by_date;
       end if;

       /*Validate the reassignee for the action*/
       pa_control_api_pvt.validate_assignee_id(
                                                 p_assignee_id           => p_reassign_to_id
                                                ,p_project_id            => l_project_id
                                                ,p_msg_token_num         => null  --Need to pass this parameter null here for non tokenized messages.
                                                ,x_assignee_id           => l_reassign_to_id
                                                ,x_return_status         => x_return_status
                                                ,x_msg_count             => x_msg_count
                                                ,x_msg_data              => x_msg_data
                                             );

      if(x_return_status <> fnd_api.g_ret_sts_success) then
          if (l_debug_mode = 'Y') then
              pa_debug.g_err_stage := 'error occured while validating the assignee id';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          end if;
          raise fnd_api.g_exc_error;
       end if;

          /*need to add a context in the pa_ci_actions_pvt.reassign_ci_action so tht we dont perform the check that
            required by date cannot be before the system date*/
                    pa_ci_actions_pvt.reassign_ci_action(
                                                        p_validate_only          =>  fnd_api.g_false,
                                                        p_ci_action_id           =>  l_action_id,
                                                        p_sign_off_flag          =>  l_sign_off_flag,
                                                        p_record_version_number  =>  get_action_attrs_rec.record_version_number,
                                                        p_assigned_to            =>  l_reassign_to_id,
                                                        p_date_required          =>  l_required_by_date,
                                                        p_comment_text           =>  l_reassign_request_text,
                                                        p_closure_comment        =>  l_response_text,
                                                        p_created_by             =>  fnd_global.user_id,
                                                        p_creation_date          =>  sysdate,
                                                        p_last_updated_by        =>  fnd_global.user_id,
                                                        p_last_update_date       =>  sysdate,
                                                        p_last_update_login      =>  fnd_global.login_id,
                                                        x_return_status          =>  x_return_status,
                                                        x_msg_count              =>  x_msg_count,
                                                        x_msg_data               =>  x_msg_data
                                                        );

       if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           if (l_debug_mode = 'Y') then
                pa_debug.g_err_stage := 'error occured while reassigning the action';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           raise fnd_api.g_exc_unexpected_error;
       end if;

      /*check for open notifications for this action which is being closed. Close the open notification for this action*/
      open close_notification(l_action_id);
      fetch close_notification into close_notification_rec;
      if(close_notification%notfound) then
             null;
      else
             pa_control_items_workflow.close_notification(
                                                              p_item_type       =>  close_notification_rec.item_type,
                                                              p_item_key        =>  close_notification_rec.item_key,
                                                              p_nid             =>  close_notification_rec.notification_id,
                                                              p_action          =>  l_perform_action,
                                                              p_sign_off_flag   =>  l_sign_off_flag,
                                                              p_response        =>  l_response_text,
                                                              x_msg_count       =>  x_msg_count,
                                                              x_msg_data        =>  x_msg_data,
                                                              x_return_status   =>  x_return_status
                                                         );
      end if;

      if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
          if (l_debug_mode = 'Y') then
               pa_debug.g_err_stage := 'error occurred while closing the notification';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          end if;
          raise fnd_api.g_exc_unexpected_error;
     end if;

  end if;--    if(l_perform_action is not null and l_perform_action = 'R') then

  if(l_perform_action is not null and l_perform_action = 'O') then

       open get_action_attrs(l_action_id);
       fetch get_action_attrs into get_action_attrs_rec;
       close get_action_attrs;

       if (p_response_text = G_PA_MISS_CHAR or p_response_text is null ) then
            l_response_text := null;
       else
            l_response_text := p_response_text;
       end if;--if (p_response_text = G_PA_MISS_CHAR) then

                pa_ci_actions_pvt.add_ci_comment(
                                                  p_validate_only         => fnd_api.g_false,
                                                  p_ci_comment_id         => l_ci_comment_id,
                                                  p_ci_id                 => get_action_attrs_rec.ci_id,
                                                  p_type_code             => 'UNSOLICITED',
                                                  p_comment_text          => l_response_text,
                                                  p_ci_action_id          => l_action_id,
                                                  p_created_by            => fnd_global.user_id,
                                                  p_creation_date         => sysdate,
                                                  p_last_updated_by       => fnd_global.user_id,
                                                  p_last_update_date      => sysdate,
                                                  p_last_update_login     => fnd_global.login_id,
                                                  x_return_status         => x_return_status,
                                                  x_msg_count             => x_msg_count,
                                                  x_msg_data              => x_msg_data
                                                );

       if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
           if (l_debug_mode = 'Y') then
                pa_debug.g_err_stage := 'error occured while adding the response';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           raise fnd_api.g_exc_unexpected_error;
       end if;

      /*check for open notifications for this action which is being closed. Close the open notification for this action*/
      open close_notification(l_action_id);
      fetch close_notification into close_notification_rec;
      if(close_notification%notfound) then
             null;
      else
             pa_control_items_workflow.close_notification(
                                                              p_item_type       =>  close_notification_rec.item_type,
                                                              p_item_key        =>  close_notification_rec.item_key,
                                                              p_nid             =>  close_notification_rec.notification_id,
                                                              p_action          =>  l_perform_action,
                                                              p_sign_off_flag   =>  l_sign_off_flag,
                                                              p_response        =>  l_response_text,
                                                              x_msg_count       =>  x_msg_count,
                                                              x_msg_data        =>  x_msg_data,
                                                              x_return_status   =>  x_return_status
                                                         );
      end if;

      if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
          if (l_debug_mode = 'Y') then
               pa_debug.g_err_stage := 'error occurred while closing the notification';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          end if;
          raise fnd_api.g_exc_unexpected_error;
     end if;
  end if;--  if(l_perform_action is not null and l_perform_action = 'O') then

--handle this exception here
--  raise fnd_api.g_exc_error;
--raise fnd_api.g_exc_unexpected_error;

  if (p_commit = fnd_api.g_true and x_return_status = fnd_api.g_ret_sts_success)
  then
        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'about to do a commit';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        commit;
  end if;

  --rest the stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;


Exception
  when fnd_api.g_exc_error then

         --do a rollback;
         if p_commit = fnd_api.g_true then
              rollback to  take_action;
         end if;

         x_return_status := fnd_api.g_ret_sts_error;
         l_msg_count := fnd_msg_pub.count_msg;
         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                                   (p_encoded        => fnd_api.g_false,
                                    p_msg_index      => 1,
                                    p_msg_count      => l_msg_count ,
                                    p_msg_data       => l_msg_data ,
                                    p_data           => l_data,
                                    p_msg_index_out  => l_msg_index_out );
              x_msg_data  := l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

           /*no out variables to intialise back to null*/
           /*no inout variables to initialize to their initial values*/

         --reset the error stack;
         if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
         end if;

  when fnd_api.g_exc_unexpected_error then
         --do a rollback;
         if p_commit = fnd_api.g_true then
              rollback to  take_action;
         end if;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_API_PUB',
                                 p_procedure_name => 'take_action',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

           /*no out variables to intialise back to null*/
           /*no inout variables to initialize to their initial values*/

         --reset the error stack;
         if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
         end if;

  when others then
         --do a rollback;
         if p_commit = fnd_api.g_true then
              rollback to  take_action;
         end if;

         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_CONTROL_API_PUB',
                                 p_procedure_name => 'take_action',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

           /*no out variables to intialise back to null*/
           /*no inout variables to initialize to their initial values*/

         --reset the error stack;
         if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
         end if;

end TAKE_ACTION;


Procedure Cancel_Action(
                        p_commit              IN    VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list       IN    VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number  IN    NUMBER,
                        x_return_status       OUT NOCOPY  VARCHAR2,
                        x_msg_count           OUT NOCOPY  NUMBER,
                        x_msg_data            OUT NOCOPY  VARCHAR2,
                        p_ci_id               IN    NUMBER := G_PA_MISS_NUM,
                        p_action_id           IN    NUMBER := G_PA_MISS_NUM,
                        p_action_number       IN    NUMBER := G_PA_MISS_NUM,
                        p_cancel_comment      IN    VARCHAR2 := G_PA_MISS_CHAR
                        )
IS

cursor c_get_ci_id (c_action_id number)
is                    --status_code is added to check only open action can be closed
   select ci_id , record_version_number, created_by , status_code
   from pa_ci_actions
   where ci_action_id = c_action_id;



  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200):= 'PA_CONTROL_API_PUB.Cancel_Action';
  l_assignee_id                            NUMBER := null;
  l_user_id                                NUMBER := 0;
  l_action_id                             pa_ci_actions.ci_action_id%type;
  l_ci_id                                 pa_control_items.ci_id%type;
  l_record_version_number                 pa_ci_actions.record_version_number%type;
  l_status_code                           pa_ci_actions.status_code%type;
  check_s                                  VARCHAR2(1);
  l_created_by                             NUMBER;
  l_project_id                             pa_control_items.project_id%TYPE;

begin

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        x_msg_count := 0;

        l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Cancel_Action', p_debug_mode => l_debug_mode);
        END IF;

        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint CANCEL_ACTION_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Cancel_Action', l_debug_level3);
        END IF;

  --Get the user_id for the logged in user
  l_user_id  := fnd_global.user_id;


   /*Calling the procedure in PA_CONTROL_API_PVT.validate_priv_and_action to validate the
    P_ci_id and action_id and action number. and it returns the action_id*/
     if (l_debug_mode = 'Y') then
             pa_debug.g_err_stage := 'Before calling the PA_CONTROL_API_PVT.validate_priv_and_action';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     end if;
     PA_CONTROL_API_PVT.validate_priv_and_action(
                                                p_ci_id                   =>  p_ci_id
                                               ,p_action_id               =>  p_action_id
                                               ,p_action_number           =>  p_action_number
                                               ,x_action_id               =>  l_action_id
                                               ,x_assignee_id             =>  l_assignee_id
                                               ,x_project_id              =>  l_project_id
                                               ,x_return_status           =>  x_return_status
                                               ,x_msg_count               =>  x_msg_count
                                               ,x_msg_data                =>  x_msg_data
                                              );

   /* Get the control item id(if it is passed also with action_id) to check the security */
   if x_return_status = FND_API.G_RET_STS_SUCCESS then
                open c_get_ci_id(l_action_id);
                fetch c_get_ci_id into l_ci_id,l_record_version_number,l_created_by, l_status_code;
                if c_get_ci_id%notfound then
                        pa_utils.add_message(p_app_short_name    => 'PA',
                                              p_msg_name          => 'PA_CI_INV_ACT_ID');
                        if (l_debug_mode = 'Y') then
                                pa_debug.g_err_stage := 'invalid action_id passed';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
			x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_get_ci_id;
                        raise FND_API.G_EXC_ERROR;
                else
		/*User can only delete the actions, which are created by him*/
		close c_get_ci_id;
			if l_created_by <> l_user_id then
				pa_utils.add_message(p_app_short_name    => 'PA',
					             p_msg_name          => 'PA_CI_ACTION_NO_ACCESS');
				if (l_debug_mode = 'Y') then
					pa_debug.g_err_stage := 'invalid action_id passed';
					pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
				x_return_status := FND_API.G_RET_STS_ERROR;

				raise FND_API.G_EXC_ERROR;
			end if;
			if l_status_code <> 'CI_ACTION_OPEN' then
				pa_utils.add_message(p_app_short_name    => 'PA',
					             p_msg_name          => 'PA_CI_CANCEL_OPEN_ACTION');
				if (l_debug_mode = 'Y') then
					pa_debug.g_err_stage := 'Only open actions can be cancelled';
					pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
				x_return_status := FND_API.G_RET_STS_ERROR;
				raise FND_API.G_EXC_ERROR;
			end if;

               end if;
   end if;


   /*Security check  - whether the cancel button is existing in the UI*/
   check_s := pa_ci_security_pkg.check_item_owner_project_auth(l_ci_id);

   if check_s <> 'T' then
         PA_UTILS.add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_NO_UPDATE_ACCESS');
         x_return_status := FND_API.G_RET_STS_ERROR;
         if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Does not have the update access';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         raise FND_API.G_EXC_ERROR;
   end if;

  --------------------------------------------------------------
   /*Need to chck for the open notification details cancelling*/
   -------------------------------------------------------------
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Before calling the pa_ci_actions_pvt.cancel_ci_action';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

	if x_return_status = FND_API.G_RET_STS_SUCCESS THEN

	    pa_ci_actions_pvt.cancel_ci_action(
                               p_api_version           => 1.0,
                               p_init_msg_list         => FND_API.G_FALSE,
                               p_commit                => p_commit,
                               p_validate_only         => 'F',
                               p_ci_action_id          => l_action_id,
                               p_record_version_number => l_record_version_number,
                               p_cancel_comment        => p_cancel_comment,
                               x_return_status         => x_return_status,
                               x_msg_count             => x_msg_count,
                               x_msg_data              => x_msg_data
                              );
          end if;

          IF p_commit = FND_API.G_TRUE and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                COMMIT;
          elsif  x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
          END IF;
           --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_msg_count := FND_MSG_PUB.COUNT_MSG;

          IF p_commit = 'T' THEN
            ROLLBACK to CANCEL_ACTION_SVPT;
          END IF;

         if l_msg_count = 1 then
              pa_interface_utils_pub.get_messages
                            (p_encoded        => fnd_api.g_false,
                             p_msg_index      => 1,
                             p_msg_count      => l_msg_count ,
                             p_msg_data       => l_msg_data ,
                             p_data           => l_data,
                             p_msg_index_out  => l_msg_index_out );
              x_msg_data  :=  l_data;
              x_msg_count := l_msg_count;
         else
              x_msg_count := l_msg_count;
         end if;

         --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

when others then

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         x_msg_data      := substr(SQLERRM,1,240);

         IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO CANCEL_ACTION_SVPT;
         END IF;


         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PUB',
                                   p_procedure_name  => 'CANCEL_ACTION',
                                   p_error_text      => x_msg_data);
        x_msg_count     := FND_MSG_PUB.count_msg;
        --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

end Cancel_Action;



/*
        Procedure Delete_Issue.
        Internally calls the procedure PA_CONTROL_API_PVT.Delete_CI
        to delete the Issue. The internal procedure is responsible
        for all validations.
*/
Procedure Delete_Issue (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        )
IS
        -- Local Variables.
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
        l_module_name           VARCHAR2(200):= 'PA_CONTROL_API_PUB.Delete_Issue';
	l_CiTypeClassCode	VARCHAR2(30);
	l_Issue			VARCHAR2(30) := 'ISSUE';
        -- End: Local Variables.
BEGIN

	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Delete_Issue', p_debug_mode => l_debug_mode);
        END IF;

	-- Clear the Global PL/SQL Message table.
        IF FND_API.TO_BOOLEAN(nvl(p_Init_Msg_List, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_ISSUE_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Delete_Issue', l_debug_level3);
        END IF;
        -- Initialize the Error Stack.
      --  PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PUB.Delete_Issue');

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;



	-- Check whether the Ci_Id that is passed in is for an Issue or not.
	OPEN Get_CI_Type_Class_Code (p_Ci_Id);
	FETCH Get_CI_Type_Class_Code INTO l_CiTypeClassCode;
	IF (Get_CI_Type_Class_Code%FOUND AND l_CiTypeClassCode <> l_Issue) THEN
		-- Close the Cursor.
		CLOSE Get_CI_Type_Class_Code;

		-- Add the Error Message to the Stack.
		PA_UTILS.Add_Message (
			p_App_Short_Name	=> 'PA'
			, p_Msg_Name		=> 'PA_CI_INV_CI_ID');
		-- Raise the Error.
	       if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'Invalid API Use';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	       end if;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE Get_CI_Type_Class_Code;

        -- Call the procedure Delete_CI to delete the Control Item.
        PA_CONTROL_API_PVT.Delete_CI (
                        p_Commit                => p_Commit
                        , p_Init_Msg_List       => 'F'
                        , p_Api_Version_Number  => p_Api_Version_Number
                        , p_Ci_Id               => p_Ci_Id
                        , x_Return_Status       => x_Return_Status
                        , x_Msg_Count           => x_Msg_Count
                        , x_Msg_Data            => x_Msg_Data
                  );

	 IF p_commit = FND_API.G_TRUE and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                COMMIT;
         elsif  x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
         END IF;

        -- Reset the Error Stack.
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

        -- If any Exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Error;
                -- Get the Message Count.
                l_Msg_Count := FND_MSG_PUB.Count_Msg;
		--Roll back
		IF p_commit = FND_API.G_TRUE THEN
		        ROLLBACK TO DELETE_ISSUE_SVPT;
	        END IF;
                IF (l_Msg_Count = 1) THEN
                        PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_Encoded               => FND_API.g_False
                                , p_Msg_Index           => 1
                                , p_Msg_Count           => l_Msg_Count
                                , p_Msg_Data            => l_Msg_Data
                                , p_Data                => l_Data
                                , p_Msg_Index_Out       => l_Msg_Index_Out
                                );
                        x_Msg_Data := l_Data;
                        x_Msg_Count := l_Msg_Count;
                ELSE
                        x_Msg_Count := l_Msg_Count;
                END IF;

               --Reset the stack
		 if l_debug_mode = 'Y' then
			  Pa_Debug.reset_curr_function;
		 end if;

        WHEN OTHERS THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;
		--Roll back the changes.
		IF p_commit = FND_API.G_TRUE THEN
		        ROLLBACK TO DELETE_ISSUE_SVPT;
	        END IF;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PUB',
                        p_Procedure_Name => 'Delete_Issue',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

               --Reset the stack
		  if l_debug_mode = 'Y' then
			 Pa_Debug.reset_curr_function;
		  end if;
END Delete_Issue;

/*
        Procedure Delete_Change_Request.
        Internally calls the procedure PA_CONTROL_API_PVT.Delete_CI
        to delete the Issue. The internal procedure is responsible
        for all validations.
*/
Procedure Delete_Change_Request (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        )
IS
        -- Local Variables.
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
        l_module_name           VARCHAR2(200):= 'PA_CONTROL_API_PUB.Delete_Change_Request';
	l_CiTypeClassCode	VARCHAR2(30);
	l_ChangeRequest		VARCHAR2(30) := 'CHANGE_REQUEST';
        -- End: Local Variables.
BEGIN
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Delete_Change_Request', p_debug_mode => l_debug_mode);
        END IF;

	-- Clear the Global PL/SQL Message table.
        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_CR_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Delete_Change_Request', l_debug_level3);
        END IF;

        -- Initialize the Error Stack.
        --PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PUB.Delete_Change_Request');

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;



	-- Check whether the Ci_Id that is passed in is for a CR or not.
	OPEN Get_CI_Type_Class_Code (p_Ci_Id);
	FETCH Get_CI_Type_Class_Code INTO l_CiTypeClassCode;
	IF (Get_CI_Type_Class_Code%FOUND AND l_CiTypeClassCode <> l_ChangeRequest) THEN
		-- Close the Cursor.
		CLOSE Get_CI_Type_Class_Code;

		-- Add the Error Message to the Stack.
		PA_UTILS.Add_Message (
			p_App_Short_Name	=> 'PA'
			, p_Msg_Name		=> 'PA_CI_INV_CI_ID');
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'Invalid API Use';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
		-- Raise the Error.
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE Get_CI_Type_Class_Code;

        -- Call the procedure Delete_CI to delete the Control Item.
        PA_CONTROL_API_PVT.Delete_CI (
                        p_Commit                => p_Commit
                        , p_Init_Msg_List       => 'F'
                        , p_Api_Version_Number  => p_Api_Version_Number
                        , p_Ci_Id               => p_Ci_Id
                        , x_Return_Status       => x_Return_Status
                        , x_Msg_Count           => x_Msg_Count
                        , x_Msg_Data            => x_Msg_Data
                  );


	 IF p_commit = FND_API.G_TRUE and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                COMMIT;
         elsif  x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
         END IF;


        --Reset the stack
	 if l_debug_mode = 'Y' then
		 Pa_Debug.reset_curr_function;
	  end if;

        -- If any Exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Error;
                -- Get the Message Count.
                l_Msg_Count := FND_MSG_PUB.Count_Msg;

		IF p_commit = FND_API.G_TRUE THEN
		        ROLLBACK TO DELETE_CR_SVPT;
	        END IF;

                IF (l_Msg_Count = 1) THEN
                        PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_Encoded               => FND_API.g_False
                                , p_Msg_Index           => 1
                                , p_Msg_Count           => l_Msg_Count
                                , p_Msg_Data            => l_Msg_Data
                                , p_Data                => l_Data
                                , p_Msg_Index_Out       => l_Msg_Index_Out
                                );
                        x_Msg_Data := l_Data;
                        x_Msg_Count := l_Msg_Count;
                ELSE
                        x_Msg_Count := l_Msg_Count;
                END IF;


                --Reset the stack
		  if l_debug_mode = 'Y' then
			 Pa_Debug.reset_curr_function;
		  end if;

        WHEN OTHERS THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;

		IF p_commit = FND_API.G_TRUE THEN
		        ROLLBACK TO DELETE_CR_SVPT;
	        END IF;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PUB',
                        p_Procedure_Name => 'Delete_Change_Request',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

                -- Reset the Error Stack.
                  if l_debug_mode = 'Y' then
			 Pa_Debug.reset_curr_function;
		  end if;
END Delete_Change_Request;

/*
        Procedure Delete_Change_Order.
        Internally calls the procedure PA_CONTROL_API_PVT.Delete_CI
        to delete the Issue. The internal procedure is responsible
        for all validations.
*/
Procedure Delete_Change_Order (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        )
IS
        -- Local Variables.
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
        l_module_name           VARCHAR2(200):= 'PA_CONTROL_API_PUB.Delete_Change_Order';
	l_CiTypeClassCode	VARCHAR2(30);
	l_ChangeOrder		VARCHAR2(30) := 'CHANGE_ORDER';
        -- End: Local Variables.
BEGIN
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Delete_Change_Order', p_debug_mode => l_debug_mode);
        END IF;

	-- Clear the Global PL/SQL Message table.
        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF p_commit = FND_API.G_TRUE THEN
                savepoint DELETE_CO_SVPT;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Delete_Change_Order', l_debug_level3);
        END IF;
        -- Initialize the Error Stack.
        --PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PUB.Delete_Change_Order');

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;


	-- Check whether the Ci_Id that is passed in is for a CO or not.
	OPEN Get_CI_Type_Class_Code (p_Ci_Id);
	FETCH Get_CI_Type_Class_Code INTO l_CiTypeClassCode;
	IF (Get_CI_Type_Class_Code%FOUND AND l_CiTypeClassCode <> l_ChangeOrder) THEN
		-- Close the Cursor.
		CLOSE Get_CI_Type_Class_Code;

		-- Add the Error Message to the Stack.
		PA_UTILS.Add_Message (
			p_App_Short_Name	=> 'PA'
			, p_Msg_Name		=> 'PA_CI_INV_CI_ID');
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'Invalid API Use';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
		-- Raise an Error.
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	CLOSE Get_CI_Type_Class_Code;

        -- Call the procedure Delete_CI to delete the Control Item.
        PA_CONTROL_API_PVT.Delete_CI (
                        p_Commit                => p_Commit
                        , p_Init_Msg_List       => 'F'
                        , p_Api_Version_Number  => p_Api_Version_Number
                        , p_Ci_Id               => p_Ci_Id
                        , x_Return_Status       => x_Return_Status
                        , x_Msg_Count           => x_Msg_Count
                        , x_Msg_Data            => x_Msg_Data
                  );

	 IF p_commit = FND_API.G_TRUE and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                COMMIT;
         elsif  x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
         END IF;

        -- Reset the Error Stack.
        if l_debug_mode = 'Y' then
		 Pa_Debug.reset_curr_function;
	end if;

        -- If any Exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Error;
                -- Get the Message Count.
                l_Msg_Count := FND_MSG_PUB.Count_Msg;

		IF p_commit = FND_API.G_TRUE THEN
		        ROLLBACK TO DELETE_CO_SVPT;
	        END IF;

                IF (l_Msg_Count = 1) THEN
                        PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_Encoded               => FND_API.g_False
                                , p_Msg_Index           => 1
                                , p_Msg_Count           => l_Msg_Count
                                , p_Msg_Data            => l_Msg_Data
                                , p_Data                => l_Data
                                , p_Msg_Index_Out       => l_Msg_Index_Out
                                );
                        x_Msg_Data := l_Data;
                        x_Msg_Count := l_Msg_Count;
                ELSE
                        x_Msg_Count := l_Msg_Count;
                END IF;

		 -- Reset the Error Stack.
	        if l_debug_mode = 'Y' then
			 Pa_Debug.reset_curr_function;
		end if;

        WHEN OTHERS THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;

		IF p_commit = FND_API.G_TRUE THEN
		        ROLLBACK TO DELETE_CO_SVPT;
	        END IF;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PUB',
                        p_Procedure_Name => 'Delete_Change_Order',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

                -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;
END Delete_Change_Order;



/*
        Procedure Add_Comments.
        Procedure for adding Comments to a particular Control Item.
        Validations done before initiating Add:
        1. Check whether the Control Item is valid or not.
        2. Check whether the logged in user has View acceess on
           the Control Item or not.
*/
Procedure Add_Comments (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , p_Comments_Tbl        IN CI_COMMENTS_TBL_TYPE
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        )
IS
        -- Local Variables.
        l_CiId                  NUMBER(15);
        l_CiCommentId           NUMBER(15);
        l_StatusCode            VARCHAR2(30);
        l_ProjectId             NUMBER(15);
        l_CiTypeClassCode       VARCHAR2(30);
        l_RecordVersionNumber   NUMBER(15);

	l_module_name           VARCHAR2(200):= 'PA_CONTROL_API_PUB.Add_Comments';
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
        -- End: Local Variables.
BEGIN
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Comments', p_debug_mode => l_debug_mode);
        END IF;

	-- Clear the Global PL/SQL Message table.
        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add_Comments', l_debug_level3);
        END IF;

        -- Set the SavePoint if we have been requested to Commit the Data.
        IF (p_Commit = FND_API.G_TRUE) THEN
            SAVEPOINT ADD_COMMENTS_SVPT;
        END IF;

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;


        -- If the Ci_Id that is passed in is NULL then report
        -- Error.
        IF (p_Ci_Id IS NULL) THEN
                -- Add message to the Error Stack that Ci_Id is NULL.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_MISS_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID is not passed';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- If the Ci_Id that is passed in does not exist then
        -- report Error.
        OPEN Check_Valid_CI (p_Ci_Id);
        FETCH Check_Valid_CI INTO l_CiId;
        IF (Check_Valid_CI%NOTFOUND) THEN
                -- Close the Cursor.
                CLOSE Check_Valid_CI;

                -- Add message to the Error Stack that this Ci_Id is Invalid.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_INV_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID is invalid';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Check_Valid_CI;

        -- Open Cursor Get_CI_Data and fetch the data into out local variables.
        OPEN Get_CI_Data (p_Ci_Id);
        FETCH Get_CI_Data INTO l_ProjectId, l_StatusCode, l_CiTypeClassCode, l_RecordVersionNumber;
        -- If NO_DATA_FOUND then report Error.
        IF (Get_CI_Data%NOTFOUND) THEN
                -- Code to Report Error and Return.
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID is invalid, No data founc in Get_CI_Data Cursor';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                CLOSE Get_CI_Data;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Get_CI_Data;



        -- Adding of Comments is only allowed on a Control Item if
        --      1. The User has View access on the Control Item, ie
        --         he would be able to see the Control Item on the UI.
        IF (PA_CI_SECURITY_PKG.Check_View_Access (p_Ci_Id, l_ProjectId, l_StatusCode, l_CiTypeClassCode) = 'T') THEN
                -- For each Comment in the passed in array, insert it.
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'Before Calling PA_CI_ACTIONS_PUB.Add_CI_Comment in a for loop';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                FOR i IN 1..p_Comments_Tbl.COUNT LOOP
                        PA_CI_ACTIONS_PUB.Add_CI_Comment (
                                p_Api_Version           => p_Api_Version_Number
                                , p_Init_Msg_List       => 'F'
                                , p_Commit              => 'F'
                                , p_Validate_Only       => 'F'
                                , x_Ci_Comment_Id       => l_CiCommentId
                                , p_Ci_Id               => p_Ci_Id
                                , p_Type_Code           => 'UNSOLICITED'
                                , p_Comment_Text        => p_Comments_Tbl(i)
                                , p_Ci_Action_Id        => NULL
                                , x_Return_Status       => x_Return_Status
                                , x_Msg_Count           => x_Msg_Count
                                , x_Msg_Data            => x_Msg_Data
                                );

                        -- If at any time, the Return Status is not success
                        -- then raise exception to rollbakc all changes.
                        IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
                END LOOP;
        ELSE -- If View access is denied to the User for this Control Item.
                -- Add message to the Error Stack that the user does not
                -- have the privilege to update this Control Item.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_NO_ALLOW_UPDATE'
                        );

                -- Raise exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Commit the data to the Database if p_Commit is True
        -- and there are no Errors.
        IF (p_Commit = FND_API.G_TRUE AND x_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
                COMMIT;
        END IF;

        -- Reset the Error Stack.
	if l_debug_mode = 'Y' then
		Pa_Debug.reset_curr_function;
	end if;

	-- If any Exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- Rollback.
                IF (p_Commit = FND_API.G_TRUE) THEN
                        ROLLBACK TO ADD_COMMENTS_SVPT;
                END IF;

                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Error;
                -- Get the Message Count.
                l_Msg_Count := FND_MSG_PUB.Count_Msg;

                IF (l_Msg_Count = 1) THEN
                        PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_Encoded               => FND_API.g_False
                                , p_Msg_Index           => 1
                                , p_Msg_Count           => l_Msg_Count
                                , p_Msg_Data            => l_Msg_Data
                                , p_Data                => l_Data
                                , p_Msg_Index_Out       => l_Msg_Index_Out
                                );
                        x_Msg_Data := l_Data;
                        x_Msg_Count := l_Msg_Count;
                ELSE
                        x_Msg_Count := l_Msg_Count;
                END IF;

                -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;

        WHEN OTHERS THEN
                -- Rollback.
                IF (p_Commit = FND_API.G_TRUE) THEN
                        ROLLBACK TO ADD_COMMENTS_SVPT;
                END IF;

                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PUB',
                        p_Procedure_Name => 'Add_Comments',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

                -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;
END Add_Comments;



/*
        Procedure Add_Related_Items.
        Procedure for adding Related Items to a particular Control Item.
        Validations done before initiating Add:
        1. Check whether the Control Item is valid or not.
        2. Check whether the logged in user has update access on the
           Control Item and whether the Control Item in question can
           be updated or not based on its current status.
*/
Procedure Add_Related_Items (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , p_Related_Items_Tbl   IN REL_ITEM_IN_TABLE_TYPE
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        )
IS
        -- Local Variables.
        l_CiId                  NUMBER(15);
        l_StatusCode            VARCHAR2(30);
        l_ProjectId             NUMBER(15);
        l_CiTypeClassCode       VARCHAR2(30);
        l_RecordVersionNumber   NUMBER(15);

	l_module_name           VARCHAR2(200):= 'PA_CONTROL_API_PUB.Add_Related_Items';
        l_AnyError              VARCHAR2(1) := 'N';
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;

	l_UpdateAccess          VARCHAR2(1);
        l_UpdateAllowed         VARCHAR2(1);
        -- End: Local Variables.
BEGIN
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Add_Related_Items', p_debug_mode => l_debug_mode);
        END IF;

	-- Clear the Global PL/SQL Message table.
        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Add_Related_Items', l_debug_level3);
        END IF;
        -- Initialize the Error Stack.
        --PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PUB.Add_Related_Items');

        -- Set the SavePoint if we have been requested to Commit the Data.
        IF (p_Commit = FND_API.G_TRUE) THEN
            SAVEPOINT ADD_RELATED_ITEMS_SVPT;
        END IF;

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;



        -- If the Ci_Id that is passed in is NULL then report
        -- Error.
        IF (p_Ci_Id IS NULL) THEN
                -- Add message to the Error Stack that Ci_Id is NULL.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_MISS_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID is not passed';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- If the Ci_Id that is passed in does not exist then
        -- report Error.
        OPEN Check_Valid_CI (p_Ci_Id);
        FETCH Check_Valid_CI INTO l_CiId;
        IF (Check_Valid_CI%NOTFOUND) THEN
                -- Close the Cursor.
                CLOSE Check_Valid_CI;

                -- Add message to the Error Stack that this Ci_Id is Invalid.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_INV_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID is Invalid';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Check_Valid_CI;

        -- Open Cursor Get_CI_Data and fetch the data into our local variables.
        OPEN Get_CI_Data (p_Ci_Id);
        FETCH Get_CI_Data INTO l_ProjectId, l_StatusCode, l_CiTypeClassCode, l_RecordVersionNumber;
        -- If NO_DATA_FOUND then report Error.
        IF (Get_CI_Data%NOTFOUND) THEN
                -- Code to Report Error and Return.
                CLOSE Get_CI_Data;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Get_CI_Data;

        -- Check whether Workflow is running on this Control Item or not.
        OPEN Check_Workflow_On_CI (p_Ci_Id);
        FETCH Check_Workflow_On_CI INTO l_CiId;

        -- If Workflow is not running on this Control Item then proceed,
        -- else report Error.
        IF (Check_Workflow_On_CI%NOTFOUND) THEN
                CLOSE Check_Workflow_On_CI;
                -- Adding of Related Items is only allowed on a Control Item if
                --      1. The User has Update access on the Control Item.
                --      2. Update is allowed on the Control Item in this particular
                --         status.
		l_UpdateAccess := PA_CI_SECURITY_PKG.Check_Update_Access (p_Ci_Id);
		l_UpdateAllowed := PA_CONTROL_ITEMS_UTILS.CheckCIActionAllowed ('CONTROL_ITEM', l_StatusCode, 'CONTROL_ITEM_ALLOW_UPDATE', p_Ci_Id);
                IF (l_UpdateAllowed = 'Y' AND l_UpdateAccess = 'T') THEN
                        -- For each Related Item in the passed in array, insert it.
                        FOR i IN 1..p_Related_Items_Tbl.COUNT LOOP
                                -- If the Related Ci_Id that is passed in does not
                                -- exist then report Error to rollback changes made
                                -- till now.
                                OPEN Check_Valid_CI (p_Related_Items_Tbl(i));
                                FETCH Check_Valid_CI INTO l_CiId;
                                IF (Check_Valid_CI%NOTFOUND OR p_Related_Items_Tbl(i) = p_Ci_Id) THEN
                                        -- Close the Cursor.
                                        CLOSE Check_Valid_CI;

                                        -- Add message to the Error Stack that this Ci_Id is Invalid.
                                        PA_UTILS.Add_Message (
                                                p_App_Short_Name => 'PA'
                                                , p_Msg_Name => 'PA_CI_RELATED_ITEM_INVALID'
                                                , p_Token1 => 'NUMBER'
                                                , p_Value1 => i
                                                );
					if l_debug_mode = 'Y' then
						pa_debug.g_err_stage:= 'Invalid Related_Item ['||i||']';
					        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				        end if;
                                        -- Set the Error Occured flag.
                                        l_AnyError := 'Y';
                                ELSE
                                        -- Close the Cursor.
                                        CLOSE Check_Valid_CI;
					if l_debug_mode = 'Y' then
						pa_debug.g_err_stage:= 'Before Calling PA_CONTROL_ITEMS_PVT.Add_Related_Item for the related item ['||i||']';
					        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				        end if;
                                        -- Call our API for insertion.
                                        PA_CONTROL_ITEMS_PVT.Add_Related_Item (
                                                p_Api_Version           => p_Api_Version_Number
                                                , p_Init_Msg_List       => 'F'
                                                , p_Commit              => 'F'
                                                , p_Validate_Only       => 'F'
                                                , p_Ci_Id               => p_Ci_Id
                                                , p_Related_Ci_Id       => p_Related_Items_Tbl(i)
                                                , x_Return_Status       => x_Return_Status
                                                , x_Msg_Count           => x_Msg_Count
                                                , x_Msg_Data            => x_Msg_Data
                                                );

                                        -- If at any time, the Return Status is not success
                                        -- then Raise Exception to Rollback all changes.
                                        IF (x_Return_Status <> FND_API.G_RET_STS_SUCCESS) THEN
                                                RAISE FND_API.G_EXC_ERROR;
                                        END IF;
                                END IF;
                        END LOOP;

                        -- Check for errors. If any related item was invalid,
                        -- then report Error and rollback all changes.
                        IF (l_AnyError = 'Y') THEN
                                RAISE FND_API.G_EXC_ERROR;
                        END IF;
		ELSE
			-- Check if Update Access was denied or not.
                        IF (l_UpdateAccess <> 'T') THEN
                                -- Add message to the Error Stack that the user does not
                                -- have the privilege to update this Control Item.
                                PA_UTILS.Add_Message (
                                        p_App_Short_Name => 'PA'
                                        , p_Msg_Name => 'PA_CI_UPDATE_NOT_ALLOWED'
                                        );
				if l_debug_mode = 'Y' then
					pa_debug.g_err_stage:= 'User does not have the privilege to update this Control Item.';
				        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
                        END IF;

                        -- Check if update was denied by Status Control or not.
                        IF (l_UpdateAllowed <> 'Y') THEN
                                -- Add message to the Error Stack that this Control Item
                                -- cannot be updated in its present status.
                                PA_UTILS.Add_Message (
                                        p_App_Short_Name => 'PA'
                                        , p_Msg_Name => 'PA_CI_NO_ALLOW_UPDATE'
                                        );
				if l_debug_mode = 'Y' then
					pa_debug.g_err_stage:= 'This Control Item cannot be updated in its present status.';
				        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
                        END IF;

                        -- Raise the Invalid Argument exception.
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        ELSE
                -- Close the Cursor.
                CLOSE Check_Workflow_On_CI;

                -- Add message to the Error Stack that this Ci_Id has Workflow
                -- attached.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_APPROVAL_WORKFLOW'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'Ci_Id has Workflow attached.';
			pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
		end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Commit the data to the Database if p_Commit is True
        -- and there are no Errors.
        IF (p_Commit = FND_API.G_TRUE AND x_Return_Status = FND_API.G_RET_STS_SUCCESS) THEN
                COMMIT;
        END IF;

           -- Reset the Error Stack.
	if l_debug_mode = 'Y' then
		Pa_Debug.reset_curr_function;
	end if;

        -- If any Exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- Rollback.
                IF (p_Commit = FND_API.G_TRUE) THEN
                        ROLLBACK TO ADD_RELATED_ITEMS_SVPT;
                END IF;

                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Error;
                -- Get the Message Count.
                l_Msg_Count := FND_MSG_PUB.Count_Msg;

                IF (l_Msg_Count = 1) THEN
                        PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_Encoded               => FND_API.g_False
                                , p_Msg_Index           => 1
                                , p_Msg_Count           => l_Msg_Count
                                , p_Msg_Data            => l_Msg_Data
                                , p_Data                => l_Data
                                , p_Msg_Index_Out       => l_Msg_Index_Out
                                );
                        x_Msg_Data := l_Data;
                        x_Msg_Count := l_Msg_Count;
                ELSE
                        x_Msg_Count := l_Msg_Count;
                END IF;

                   -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;

        WHEN OTHERS THEN
                -- Rollback.
                IF (p_Commit = FND_API.G_TRUE) THEN
                        ROLLBACK TO ADD_RELATED_ITEMS_SVPT;
                END IF;

                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PUB',
                        p_Procedure_Name => 'Add_Related_Items',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

                   -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;
END Add_Related_Items;

/*
        Procedure Delete_Related_Item.
        Procedure for deleting Related Items to a particular Control Item.
        Validations done before initiating Delete:
        1. Check whether the Control Item is valid or not.
        2. Check whether the logged in user has update access on the
           Control Item and whether the Control Item in question can
           be updated or not based on its current status.
*/
Procedure Delete_Related_Item (
                        p_Commit                IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Init_Msg_List       IN VARCHAR2 DEFAULT FND_API.G_FALSE
                        , p_Api_Version_Number  IN NUMBER
                        , p_Ci_Id               IN NUMBER
                        , p_To_Ci_Id            IN NUMBER
                        , x_Return_Status       OUT NOCOPY VARCHAR2
                        , x_Msg_Count           OUT NOCOPY NUMBER
                        , x_Msg_Data            OUT NOCOPY VARCHAR2
                        )
IS
        -- Local Variables.
        l_CiId                  NUMBER(15);
        l_StatusCode            VARCHAR2(30);
        l_ProjectId             NUMBER(15);
        l_CiTypeClassCode       VARCHAR2(30);
        l_RecordVersionNumber   NUMBER(15);

        l_UpdateAccess          VARCHAR2(1);
        l_UpdateAllowed         VARCHAR2(1);
	l_module_name           VARCHAR2(200):= 'PA_CONTROL_API_PUB.Delete_Related_Item';
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
        -- End: Local Variables.
BEGIN
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.set_curr_function(p_function => 'Delete_Related_Item', p_debug_mode => l_debug_mode);
        END IF;

	-- Clear the Global PL/SQL Message table.
        IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
                FND_MSG_PUB.initialize;
        END IF;

	-- Set the SavePoint if we have been requested to Commit the Data.
        IF (p_Commit = FND_API.G_TRUE) THEN
            SAVEPOINT DELETE_RELATED_ITEMS_SVPT;
        END IF;


        IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module_name, 'Start of Delete_Related_Item', l_debug_level3);
        END IF;
        -- Initialize the Error Stack.
        --PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PUB.Delete_Related_Item');

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;


        -- If any of the Ci_Ids that are passed in is NULL then
        -- report Error.
        IF (p_Ci_Id IS NULL OR p_To_Ci_Id IS NULL) THEN
                -- Add message to the Error Stack that Ci_Id is NULL.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_MISS_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID or TO_CI_ID is not passed';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- If the Ci_Id that is passed in does not exist then
        -- report Error.
        OPEN Check_Valid_CI (p_Ci_Id);
        FETCH Check_Valid_CI INTO l_CiId;
        IF (Check_Valid_CI%NOTFOUND) THEN
                -- Close the Cursor.
                CLOSE Check_Valid_CI;

                -- Add message to the Error Stack that this Ci_Id is Invalid.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_INV_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID is Invalid';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Check_Valid_CI;

	-- If the To_Ci_Id that is passed in does not exist then
        -- report Error.
        OPEN Check_Valid_CI (p_To_Ci_Id);
        FETCH Check_Valid_CI INTO l_CiId;
        IF (Check_Valid_CI%NOTFOUND) THEN
                -- Close the Cursor.
                CLOSE Check_Valid_CI;

                -- Add message to the Error Stack that this Ci_Id is Invalid.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_INV_CI_ID'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'TO_CI_ID is Invalid';
		        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
	        end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Check_Valid_CI;

        -- Open Cursor Get_CI_Data and fetch the data into our local variables.
        OPEN Get_CI_Data (p_Ci_Id);
        FETCH Get_CI_Data INTO l_ProjectId, l_StatusCode, l_CiTypeClassCode, l_RecordVersionNumber;
        -- If NO_DATA_FOUND then report Error.
        IF (Get_CI_Data%NOTFOUND) THEN
                -- Code to Report Error and Return.
                CLOSE Get_CI_Data;
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Get_CI_Data;

        -- Check whether Workflow is running on this Control Item or not.
        OPEN Check_Workflow_On_CI (p_Ci_Id);
        FETCH Check_Workflow_On_CI INTO l_CiId;

        -- If Workflow is not running on this Control Item then proceed,
        -- else report Error.
        IF (Check_Workflow_On_CI%NOTFOUND) THEN
                CLOSE Check_Workflow_On_CI;
                -- Deleting of Related Items is only allowed on a Control Item if
                --      1. The User has Update access on the Control Item.
                --      2. Update is allowed on the Control Item in this particular
                --         status.
                l_UpdateAllowed := PA_CONTROL_ITEMS_UTILS.CheckCIActionAllowed ('CONTROL_ITEM', l_StatusCode, 'CONTROL_ITEM_ALLOW_UPDATE', p_Ci_Id);
                l_UpdateAccess := PA_CI_SECURITY_PKG.Check_Update_Access (p_Ci_Id);
                IF (l_UpdateAllowed = 'Y' AND l_UpdateAccess = 'T') THEN
			if l_debug_mode = 'Y' then
				pa_debug.g_err_stage:= 'Before Calling PA_CONTROL_ITEMS_PVT.Delete_Related_Item';
			        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
		        end if;
                        -- Call our procedure to Delete the Item.
                        PA_CONTROL_ITEMS_PVT.Delete_Related_Item (
                                p_Api_Version           => p_Api_Version_Number
                                , p_Init_Msg_List       => 'F'
                                , p_Commit              => p_Commit
                                , p_Validate_Only       => 'F'
                                , p_Ci_Id               => p_Ci_Id
                                , p_Related_Ci_Id       => p_To_Ci_Id
                                , x_Return_Status       => x_Return_Status
                                , x_Msg_Count           => x_Msg_Count
                                , x_Msg_Data            => x_Msg_Data
                                );
                ELSE
                        -- Check if Update Access was denied or not.
                        IF (l_UpdateAccess <> 'T') THEN
                                -- Add message to the Error Stack that the user does not
                                -- have the privilege to update this Control Item.
                                PA_UTILS.Add_Message (
                                        p_App_Short_Name => 'PA'
                                        , p_Msg_Name => 'PA_CI_UPDATE_NOT_ALLOWED'
                                        );
				if l_debug_mode = 'Y' then
					pa_debug.g_err_stage:= 'User does not have the privilege to update this Control Item.';
				        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
                        END IF;

                        -- Check if update was denied by Status Control or not.
                        IF (l_UpdateAllowed <> 'Y') THEN
                                -- Add message to the Error Stack that this Control Item
                                -- cannot be updated in its present status.
                                PA_UTILS.Add_Message (
                                        p_App_Short_Name => 'PA'
                                        , p_Msg_Name => 'PA_CI_NO_ALLOW_UPDATE'
                                        );
				if l_debug_mode = 'Y' then
					pa_debug.g_err_stage:= 'This Control Item cannot be updated in its present status.';
				        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
                        END IF;

                        -- Raise the Invalid Argument exception.
                        RAISE FND_API.G_EXC_ERROR;
                END IF;
        ELSE
                -- Close the Cursor.
                CLOSE Check_Workflow_On_CI;

                -- Add message to the Error Stack that this Ci_Id has Workflow
                -- attached.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_APPROVAL_WORKFLOW'
                        );
		if l_debug_mode = 'Y' then
			pa_debug.g_err_stage:= 'CI_ID has WorkFlow Attached';
			pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
		end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

	 IF p_commit = FND_API.G_TRUE and x_return_status = FND_API.G_RET_STS_SUCCESS THEN
                COMMIT;
         elsif  x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                raise FND_API.G_EXC_ERROR;
         END IF;

           -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;

        -- If any Exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Error;
                -- Get the Message Count.
                l_Msg_Count := FND_MSG_PUB.Count_Msg;

		-- Rollback.
                IF (p_Commit = FND_API.G_TRUE) THEN
                        ROLLBACK TO DELETE_RELATED_ITEMS_SVPT;
                END IF;

                IF (l_Msg_Count = 1) THEN
                        PA_INTERFACE_UTILS_PUB.Get_Messages (
                                p_Encoded               => FND_API.g_False
                                , p_Msg_Index           => 1
                                , p_Msg_Count           => l_Msg_Count
                                , p_Msg_Data            => l_Msg_Data
                                , p_Data                => l_Data
                                , p_Msg_Index_Out       => l_Msg_Index_Out
                                );
                        x_Msg_Data := l_Data;
                        x_Msg_Count := l_Msg_Count;
                ELSE
                        x_Msg_Count := l_Msg_Count;
                END IF;

                   -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;

        WHEN OTHERS THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;

		-- Rollback.
                IF (p_Commit = FND_API.G_TRUE) THEN
                        ROLLBACK TO DELETE_RELATED_ITEMS_SVPT;
                END IF;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PUB',
                        p_Procedure_Name => 'Delete_Related_Item',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

                   -- Reset the Error Stack.
		if l_debug_mode = 'Y' then
			Pa_Debug.reset_curr_function;
		end if;
END Delete_Related_Item;


PROCEDURE UPDATE_ISSUE (
                        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN      NUMBER,
                        x_return_status         OUT  NOCOPY   VARCHAR2,
                        x_msg_count             OUT  NOCOPY   NUMBER,
                        x_msg_data              OUT  NOCOPY   VARCHAR2,
                        p_ci_id                 IN      NUMBER,
                        P_RECORD_VERSION_NUMBER IN      NUMBER   := G_PA_MISS_NUM,
                        P_SUMMARY               IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DESCRIPTION           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_OWNER_ID              IN      NUMBER   := G_PA_MISS_NUM,
                        P_OWNER_COMMENT         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CLASSIFICATION_CODE   IN      NUMBER   := G_PA_MISS_NUM,
                        P_REASON_CODE           IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_ID             IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_TYPE           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_NUMBER             IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DATE_REQUIRED         IN      DATE     := G_PA_MISS_DATE,
                        P_PRIORITY_CODE         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_EFFORT_LEVEL_CODE     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PRICE                 IN      NUMBER   := G_PA_MISS_NUM,
                        P_PRICE_CURRENCY_CODE   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_TYPE_CODE      IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_NUMBER         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_DATE_RECEIVED  IN      DATE     := G_PA_MISS_DATE,
                        P_SOURCE_ORGANIZATION   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_PERSON         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_STATUS_CODE        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_STATUS_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_AS_OF_DATE   IN      DATE     := G_PA_MISS_DATE,
                        P_PROGRESS_STATUS_CODE  IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_OVERVIEW     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_CODE       IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_COMMENT    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE_CATEGORY    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE1            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE2            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE3            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE4            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE5            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE6            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE7            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE8            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE9            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE10           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE11           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE12           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE13           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE14           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE15           IN      VARCHAR2 := G_PA_MISS_CHAR
                        )
IS






 l_data                       VARCHAR2(2000);
 l_msg_data                   VARCHAR2(2000);
 l_msg_index_out              NUMBER;
 l_msg_count                  NUMBER := 0;

 l_check_update_access        VARCHAR2(1) := 'F';
 l_chk_status_ctrl            VARCHAR2(1) := 'N';
 l_module                     VARCHAR2(100) := 'PA_CONTROL_API_PUB.UPDATE_ISSUE';


 l_curr_status_code                   pa_control_items.status_code%TYPE;
 l_ci_status_code                     pa_control_items.status_code%TYPE;
 l_record_version_number              pa_control_items.record_version_number%TYPE;
 l_summary                            pa_control_items.summary%TYPE;
 l_description                        pa_control_items.description%TYPE;
 l_curr_owner_id                      pa_control_items.owner_id%TYPE;
 l_owner_id                           pa_control_items.owner_id%TYPE;
 l_classification_code_id             pa_control_items.classification_code_id%TYPE;
 l_reason_code_id                     pa_control_items.reason_code_id%TYPE;
 l_object_id                          pa_control_items.object_id%TYPE;
 l_object_type                        pa_control_items.object_type%TYPE;
 l_ci_number                          pa_control_items.ci_number%TYPE;
 l_date_required                      pa_control_items.date_required%TYPE;
 l_priority_code                      pa_control_items.priority_code%TYPE;
 l_effort_level_code                  pa_control_items.effort_level_code%TYPE;
 l_price                              pa_control_items.price%TYPE;
 l_price_currency_code                pa_control_items.price_currency_code%TYPE;
 l_source_type_code                   pa_control_items.source_type_code%TYPE;
 l_source_comment                     pa_control_items.source_comment%TYPE;
 l_source_number                      pa_control_items.source_number%TYPE;
 l_source_date_received               pa_control_items.source_date_received%TYPE;
 l_source_organization                pa_control_items.source_organization%TYPE;
 l_source_person                      pa_control_items.source_person%TYPE;
 l_progress_as_of_date                pa_control_items.progress_as_of_date%TYPE;
 l_progress_status_code               pa_control_items.progress_status_code%TYPE;
 l_progress_overview                  pa_control_items.status_overview%TYPE;
 l_resolution_code_id                 pa_control_items.resolution_code_id%TYPE;
 l_resolution_comment                 pa_control_items.resolution%TYPE;
 l_date_closed                        pa_control_items.date_closed%TYPE;
 l_closed_by_id                       pa_control_items.closed_by_id%TYPE;
 l_project_id                         pa_control_items.project_id%TYPE;
 l_ci_type_id                         pa_control_items.ci_type_id%TYPE;
 l_attribute_category                 pa_control_items.attribute_category%TYPE;
 l_attribute1                         pa_control_items.attribute1%TYPE;
 l_attribute2                         pa_control_items.attribute2%TYPE;
 l_attribute3                         pa_control_items.attribute3%TYPE;
 l_attribute4                         pa_control_items.attribute4%TYPE;
 l_attribute5                         pa_control_items.attribute5%TYPE;
 l_attribute6                         pa_control_items.attribute6%TYPE;
 l_attribute7                         pa_control_items.attribute7%TYPE;
 l_attribute8                         pa_control_items.attribute8%TYPE;
 l_attribute9                         pa_control_items.attribute9%TYPE;
 l_attribute10                        pa_control_items.attribute10%TYPE;
 l_attribute11                        pa_control_items.attribute11%TYPE;
 l_attribute12                        pa_control_items.attribute12%TYPE;
 l_attribute13                        pa_control_items.attribute13%TYPE;
 l_attribute14                        pa_control_items.attribute14%TYPE;
 l_attribute15                        pa_control_items.attribute15%TYPE;
 l_class_code                         constant varchar2(20) := 'ISSUE';

 CURSOR curr_row is
    SELECT *
      FROM pa_control_items
     WHERE ci_id = p_ci_id;

 cp    curr_row%rowtype;

 CURSOR c_submit_status (p_curr_status_code VARCHAR2) IS
    SELECT enable_wf_flag, wf_success_status_code, wf_failure_status_code
      FROM pa_project_statuses
     WHERE project_status_code = p_curr_status_code;

 CURSOR c_lkup (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
    SELECT lookup_code
      FROM pa_lookups
     WHERE lookup_type = p_lookup_type
       AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, trunc(sysdate))
       AND enabled_flag = 'Y'
       AND lookup_code = p_lookup_code;

 CURSOR c_statuses (p_status_type VARCHAR2, p_project_status_code VARCHAR2) IS
    SELECT project_status_code
      FROM pa_project_statuses
     WHERE status_type = p_status_type
       AND project_status_code = p_project_status_code
       AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, trunc(sysdate));

 CURSOR c_classification (p_ci_type_id NUMBER, p_class_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.classification_category
       AND cat.class_code_id = p_class_code_id;

 CURSOR c_reason (p_ci_type_id NUMBER, p_reason_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.reason_category
       AND cat.class_code_id = p_reason_code_id;

 CURSOR c_resolution (p_ci_type_id NUMBER, p_resolution_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.resolution_category
       AND cat.class_code_id = p_resolution_code_id;

 CURSOR c_auto_num IS
    SELECT type.auto_number_flag
      FROM pa_ci_types_b type,
           pa_control_items ci
     WHERE ci.ci_id = p_ci_id
       AND ci.ci_type_id = type.ci_type_id;

 CURSOR c_ci_number (p_project_id NUMBER, p_ci_type_id NUMBER) IS
    SELECT ROWID
      FROM pa_control_items
     WHERE project_id = p_project_id
       AND ci_number = p_ci_number
       AND ci_id <> p_ci_id
       AND ci_type_id = p_ci_type_id;

 CURSOR c_info IS
    SELECT cit.ci_type_class_code,
           cit.approval_required_flag,
             s.next_allowable_status_flag
      FROM pa_control_items c,
           pa_ci_types_b cit,
           pa_project_statuses s
     WHERE c.ci_id = p_ci_id
       AND c.status_code = s.project_status_code
       AND c.ci_type_id =cit.ci_type_id
       AND s.status_type = 'CONTROL_ITEM';

--added to get the owner name to include in the log message
 CURSOR c_get_owner(c_owner_id NUMBER,c_project_id NUMBER)  IS
     select distinct resource_source_name party_name
	 from PA_PROJECT_PARTIES_V
	 where party_type <> 'ORGANIZATION'
	 and resource_party_id = c_owner_id
         and project_id = c_project_id;

 l_stmnt                             VARCHAR2(5000);
 l_sel_clause                        VARCHAR2(300);
 l_from_clause                       VARCHAR2(300);
 l_where                             VARCHAR2(4000);
 l_where1                            VARCHAR2(2000);
 l_cursor                            NUMBER;
 l_rows                              NUMBER;
 l_rows1                             NUMBER;
 l_ci_status_code_1                  pa_project_statuses.project_status_code%TYPE;

 l_ROWID                             ROWID;

 l_enable_wf_flag                     pa_project_statuses.enable_wf_flag%TYPE;
 l_wf_success_status_code             pa_project_statuses.wf_success_status_code%TYPE;
 l_wf_failure_status_code             pa_project_statuses.wf_failure_status_code%TYPE;
 l_status_change_flag                 VARCHAR2(1) := 'N';
 l_start_wf                           VARCHAR2(1) := 'Y';
 l_validate_only                      VARCHAR2(1) := FND_API.g_false;
 l_max_msg_count                      NUMBER := FND_API.G_MISS_NUM;
 l_enforce_security                   VARCHAR2(1) := 'Y';
 l_num_of_actions                     NUMBER;
 l_priority_type                      VARCHAR2(30) := 'PA_TASK_PRIORITY_CODE';
 l_effort_type                        VARCHAR2(30) := 'PA_CI_EFFORT_LEVELS';
 l_source_type                        VARCHAR2(30) := 'PA_CI_SOURCE_TYPES';
 l_progress_type                      VARCHAR2(30) := 'PROGRESS';
 l_auto_numbers                       VARCHAR2(1);
 l_curr_system_status                 pa_project_statuses.project_system_status_code%TYPE;
 l_new_system_status                  pa_project_statuses.project_system_status_code%TYPE;
 l_next_allow_status_flag             pa_project_statuses.next_allowable_status_flag%TYPE;
 l_ci_type_class_code                 pa_ci_types_b.ci_type_class_code%TYPE;
 l_approval_required_flag             pa_ci_types_b.approval_required_flag%TYPE;
 l_resolution_check                   VARCHAR2(10) := 'AMG';
 l_resolution_req                     VARCHAR2(10) := 'N';
 l_resolution_req_cls                 VARCHAR2(10) := 'N';
 l_to_status_flag                     VARCHAR2(10) := 'Y';

 l_ci_comment_id                      pa_ci_comments.ci_comment_id%TYPE;
 l_comment_text                       pa_ci_comments.comment_text%TYPE;
 l_owner_name                         per_all_people_f.full_name%TYPE;
 l_curr_owner_name                    per_all_people_f.full_name%TYPE;
 l_chgowner_allowed                   VARCHAR2(1);
 l_to_owner_allowed                   VARCHAR2(1);


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

  IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function(p_function => 'UPDATE_ISSUE', p_debug_mode => l_debug_mode);
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
        savepoint UPDATE_ISSUE_SVPT;
  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'Start of Update Issue', l_debug_level3);
  END IF;

  OPEN curr_row;
  FETCH curr_row INTO cp;
  IF curr_row%NOTFOUND then
      close curr_row;
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CI_INVALID_ITEM');   /* Change this message */
      RAISE  FND_API.G_EXC_ERROR;
  ELSE

      l_curr_status_code        := cp.status_code;
      l_record_version_number   := cp.record_version_number;
      l_summary                 := cp.summary;
      l_description             := cp.description;
      l_curr_owner_id           := cp.owner_id;
      l_classification_code_id  := cp.classification_code_id;
      l_reason_code_id          := cp.reason_code_id;
      l_object_id               := cp.object_id;
      l_object_type             := cp.object_type;
      l_ci_number               := cp.ci_number;
      l_date_required           := cp.date_required;
      l_priority_code           := cp.priority_code;
      l_effort_level_code       := cp.effort_level_code;
      l_price                   := cp.price;
      l_price_currency_code     := cp.price_currency_code;
      l_source_type_code        := cp.source_type_code;
      l_source_comment          := cp.source_comment;
      l_source_number           := cp.source_number;
      l_source_date_received    := cp.source_date_received;
      l_source_organization     := cp.source_organization;
      l_source_person           := cp.source_person;
      l_progress_as_of_date     := cp.progress_as_of_date;
      l_progress_status_code    := cp.progress_status_code;
      l_progress_overview       := cp.status_overview;
      l_resolution_code_id      := cp.resolution_code_id;
      l_resolution_comment      := cp.resolution;
      l_date_closed             := cp.date_closed;
      l_closed_by_id            := cp.closed_by_id;
      l_project_id              := cp.project_id;
      l_ci_type_id              := cp.ci_type_id;
      l_attribute_category      := cp.attribute_category;
      l_attribute1              := cp.attribute1;
      l_attribute2              := cp.attribute2;
      l_attribute3              := cp.attribute3;
      l_attribute4              := cp.attribute4;
      l_attribute5              := cp.attribute5;
      l_attribute6              := cp.attribute6;
      l_attribute7              := cp.attribute7;
      l_attribute8              := cp.attribute8;
      l_attribute9              := cp.attribute9;
      l_attribute10             := cp.attribute10;
      l_attribute11             := cp.attribute11;
      l_attribute12             := cp.attribute12;
      l_attribute13             := cp.attribute13;
      l_attribute14             := cp.attribute14;
      l_attribute15             := cp.attribute15;

      close curr_row;

  END IF;

     OPEN c_info;
     FETCH c_info INTO l_ci_type_class_code, l_approval_required_flag, l_next_allow_status_flag;
     CLOSE c_info;

    /* Added to check invalid API usage*/
    if l_ci_type_class_code <> l_class_code then
 	  PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                               p_msg_name        => 'PA_CI_INV_API_USE');
           if l_debug_mode = 'Y' then
                pa_debug.g_err_stage:= 'wrong usage of the api for the control item type';
                pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
           end if;
	   RAISE FND_API.G_EXC_ERROR;
     end if;



  l_curr_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_curr_status_code);

  /*  Check if the user can update the item. This requires the user to be owner or to have project authority or
      to have open UPDATE actions and status controls are satisfied.  */

  l_check_update_access := pa_ci_security_pkg.check_update_access(p_ci_id);

  IF (l_check_update_access = 'F') THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_UPDATE_ACCESS');
       RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After call to pa_ci_security_pkg.check_update_access', l_debug_level3);
  END IF;

  /* Check for the status control: check whether the action CONTROL_ITEM_ALLOW_UPDATE is allowed on the current status of the issue. */

  l_chk_status_ctrl := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM', l_curr_status_code, 'CONTROL_ITEM_ALLOW_UPDATE');

  IF (l_chk_status_ctrl = 'N') THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_ALLOW_UPDATE');
       RAISE FND_API.G_EXC_ERROR;

  END IF;


  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After call to pa_control_items_utils.CheckCIActionAllowed', l_debug_level3);
  END IF;

  /*  The control item will not be updateable if the current status has approval workflow attached. */

  OPEN c_submit_status(l_curr_status_code);
  FETCH c_submit_status INTO l_enable_wf_flag, l_wf_success_status_code, l_wf_failure_status_code;
  CLOSE c_submit_status;
  IF (l_enable_wf_flag = 'Y' AND l_wf_success_status_code IS NOT NULL AND l_wf_failure_status_code IS NOT NULL) THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_APPROVAL_WORKFLOW');
       RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After checking for submitted status', l_debug_level3);
  END IF;


  IF p_ci_status_code = G_PA_MISS_CHAR THEN
       l_ci_status_code := l_curr_status_code;
  ELSIF p_ci_status_code IS NOT NULL THEN
          l_ci_status_code := p_ci_status_code;

          l_sel_clause  := ' SELECT ps.project_status_code ';
          l_from_clause := ' FROM pa_obj_status_lists osl, pa_status_list_items sli, pa_project_statuses ps ';
          l_where       := ' WHERE osl.status_type = '||'''CONTROL_ITEM'''||
                             ' AND osl.object_type = '||'''PA_CI_TYPES'''||
                             ' AND osl.object_id = '||l_ci_type_id||
                             ' AND osl.status_list_id = sli.status_list_id'||
                             ' AND sli.project_status_code = ps.project_status_code'||
                             ' AND ps.project_status_code <> '||''''||l_curr_status_code||''''||
                             ' AND ps.status_type = osl.status_type'||
                             ' AND trunc(sysdate) between nvl(ps.start_date_active, trunc(sysdate)) and nvl(ps.end_date_active, trunc(sysdate))'||
                             ' AND (('||''''||l_next_allow_status_flag||''''||' = '||'''N'''||' and 1=2)'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''S'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in ( select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
				  ''''||l_curr_status_code||''''||')))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''U'''||
                                  ' and ps.project_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||''''||
				  l_curr_status_code||''''||'))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''A'''||
				  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
				  ' and project_system_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
				  ''''||l_curr_system_status||''''||'))))'||
                              ' AND ps.project_status_code not in (select wf_success_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND ps.project_status_code not in (select wf_failure_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND decode(ps.project_system_status_code, '||'''CI_CANCELED'''||
                              ', nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
			      '''CONTROL_ITEM_ALLOW_CANCEL'''||', null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_WORKING'''||
                              ' ,nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
			      '''CONTROL_ITEM_ALLOW_REWORK'''||' ,null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
			      '''CONTROL_ITEM_ALLOW_UPDST'''||' ,null),'||'''N'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_DRAFT'''||
		   	      ' ,decode('||''''||l_curr_system_status||''''||', '||'''CI_DRAFT'''||', '||
			      '''Y'''||' ,'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND ps.project_status_code = '||''''||p_ci_status_code||'''';


          IF (l_ci_type_class_code = 'ISSUE' AND l_approval_required_flag = 'N') THEN
                l_where1 := ' AND  ps.project_status_code not in (select project_status_code from pa_project_statuses where status_type = '||
                           '''CONTROL_ITEM'''||' and enable_wf_flag = '||'''Y'''||
                           ' and wf_success_status_code is not null and wf_failure_status_code is not null) ';
          END IF;

          IF (l_ci_type_class_code = 'ISSUE' AND l_approval_required_flag = 'Y' AND l_curr_system_status = 'CI_WORKING') THEN
                l_where1 := ' AND  ps.project_system_status_code <> '||'''CI_CLOSED''';
          END IF;

          l_stmnt := l_sel_clause || l_from_clause || l_where || l_where1;

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, l_stmnt , l_debug_level3);
          END IF;

    l_cursor := dbms_sql.open_cursor;

    DBMS_SQL.PARSE(l_cursor, l_stmnt, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_ci_status_code_1, 30);

    l_rows := DBMS_SQL.EXECUTE(l_cursor);

    IF (l_rows < 0) THEN
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_TO_STATUS_INVALID');
               x_return_status := FND_API.G_RET_STS_ERROR;
	       l_to_status_flag := 'N';
    ELSE
       l_rows1 := DBMS_SQL.FETCH_ROWS(l_cursor);

       if l_rows1 > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_ci_status_code_1);
            l_ci_status_code := l_ci_status_code_1;
       else
	     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TO_STATUS_INVALID');
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_to_status_flag := 'N';
       end if;
    END IF;

    IF l_debug_mode = 'Y' THEN
         pa_debug.write(l_module, 'After validating p_ci_status_code', l_debug_level3);
    END IF;

    IF dbms_sql.is_open(l_cursor)   THEN
         dbms_sql.close_cursor(l_cursor);
    END IF;
  ELSIF p_ci_status_code IS NULL THEN
          l_ci_status_code := p_ci_status_code;
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_NULL_STATUS');
          x_return_status := FND_API.G_RET_STS_ERROR;
	  l_to_status_flag := 'N';
  END IF;

  IF p_record_version_number = G_PA_MISS_NUM THEN
       NULL;
  ELSE
       l_record_version_number := p_record_version_number;
  END IF;

  IF p_summary = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_summary IS NOT NULL THEN
          l_summary := p_summary;
  ELSIF p_summary IS NULL THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NULL_SUMMARY');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_description = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_description IS NOT NULL THEN
          l_description := p_description;
  ELSIF p_description IS NULL THEN
          l_description := p_description;
  END IF;


/*Adding the comment after validating the Owner id*/
  IF p_owner_id = G_PA_MISS_NUM THEN
       l_owner_id := l_curr_owner_id;
  ELSIF p_owner_id IS NOT NULL THEN
          l_owner_id := p_owner_id;
          IF (l_owner_id = l_curr_owner_id) then
                 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
                 x_return_status := 'E';

	  ELSIF (l_owner_id <> l_curr_owner_id) then
		l_chgowner_allowed := pa_ci_security_pkg.check_change_owner_access(p_ci_id);
		IF (l_chgowner_allowed <> 'T') then
		         PA_UTILS.Add_Message( p_app_short_name => 'PA'
				              ,p_msg_name       => 'PA_CI_OWNER_CHG_NOT_ALLOWED');
			 x_return_status := 'E';
	        else
		         l_to_owner_allowed := pa_ci_security_pkg.is_to_owner_allowed(p_ci_id, l_owner_id);
		         if (l_to_owner_allowed <> 'T') then
				 PA_UTILS.Add_Message( p_app_short_name => 'PA'
					              ,p_msg_name       => 'PA_CI_TO_OWNER_NOT_ALLOWED');
		         x_return_status := 'E';
		         else

				/*get the Passed owner name*/
				OPEN c_get_owner(l_owner_id,l_project_id);
				FETCH c_get_owner into l_owner_name;
				if (c_get_owner%notfound) then
					PA_UTILS.Add_Message( p_app_short_name => 'PA'
					      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
					x_return_status := 'E';
				end if;
				close 	c_get_owner;

				/*Get the Current Owner name*/
				OPEN c_get_owner(l_curr_owner_id,l_project_id);
				FETCH c_get_owner into l_curr_owner_name;
				if (c_get_owner%notfound) then
					PA_UTILS.Add_Message( p_app_short_name => 'PA'
					      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
					x_return_status := 'E';
				end if;
				close 	c_get_owner;

					fnd_message.set_name('PA', 'PA_CI_LOG_OWNER_CHANGE');
					fnd_message.set_token('PREV_OWNER', l_curr_owner_name);
					fnd_message.set_token('NEXT_OWNER', l_owner_name);
					fnd_message.set_token('COMMENT', p_owner_comment);
					l_comment_text := fnd_message.get;

					 pa_ci_comments_pkg.insert_row(
						p_ci_comment_id             => l_ci_comment_id,
						p_ci_id                     => p_ci_id,
						p_type_code                 => 'CHANGE_OWNER',
						p_comment_text              => l_comment_text,
						p_last_updated_by           => fnd_global.user_id,
						p_created_by                => fnd_global.user_id,
						p_creation_date             => sysdate,
						p_last_update_date          => sysdate,
						p_last_update_login         => fnd_global.login_id,
						p_ci_action_id              => null);
			end if;
	        end if;
	end if;
  ELSIF p_owner_id IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_OWNER_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_classification_code = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_classification_code IS NOT NULL THEN
          OPEN c_classification (l_ci_type_id, p_classification_code);
          FETCH c_classification INTO l_classification_code_id;
          IF c_classification%NOTFOUND then
              -- close c_classification;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_CLASSIFICATION_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_classification;
  ELSIF p_classification_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_CLASSIFICATION_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_reason_code = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_reason_code IS NOT NULL THEN
          OPEN c_reason (l_ci_type_id, p_reason_code);
          FETCH c_reason INTO l_reason_code_id;
          IF c_reason%NOTFOUND then
              -- close c_reason;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_REASON_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_reason;
  ELSIF p_reason_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_REASON_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_object_id = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_object_id IS NOT NULL THEN
       /* As of now we're only handling PA_TASKS objects */
       BEGIN
               SELECT proj_element_id
                 INTO l_object_id
                 FROM PA_FIN_LATEST_PUB_TASKS_V
                WHERE project_id     = l_project_id
                  AND proj_element_id = p_object_id;

        EXCEPTION WHEN TOO_MANY_ROWS THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_MULTIPLE');
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_INV');
           x_return_status := FND_API.G_RET_STS_ERROR;
        END;
  ELSIF p_object_id IS NULL THEN
          l_object_id := p_object_id;
  END IF;

  IF p_object_type = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_object_type IS NOT NULL THEN
         IF p_object_type = 'PA_TASKS' THEN
              l_object_type := p_object_type;
         ELSE
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_TYPE_INV');
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
  ELSIF p_object_type IS NULL THEN
       l_object_type := p_object_type;
  END IF;

  IF p_date_required = G_PA_MISS_DATE THEN
       NULL;
  ELSIF p_date_required IS NOT NULL THEN
          l_date_required := p_date_required;
  ELSIF p_date_required IS NULL THEN
          l_date_required := p_date_required;
  END IF;

  IF p_priority_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_priority_code IS NOT NULL THEN
          OPEN c_lkup(l_priority_type, p_priority_code);
          FETCH c_lkup INTO l_priority_code;
          IF c_lkup%NOTFOUND then
          -- close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_PRIORITY_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_priority_code IS NULL THEN
          l_priority_code := p_priority_code;
  END IF;

  IF p_effort_level_code = G_PA_MISS_CHAR THEN
       l_effort_level_code := null;
  ELSIF p_effort_level_code IS NOT NULL THEN
          OPEN c_lkup(l_effort_type, p_effort_level_code);
          FETCH c_lkup INTO l_effort_level_code;
          IF c_lkup%NOTFOUND then
          --  close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_EFFORT_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_effort_level_code IS NULL THEN
          l_effort_level_code := p_effort_level_code;
  END IF;

  IF p_price = G_PA_MISS_NUM THEN
       l_price := null;
  ELSIF p_price IS NOT NULL THEN
          l_price := p_price;
  ELSIF p_price IS NULL THEN
          l_price := p_price;
  END IF;

  IF p_price_currency_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_price_currency_code IS NOT NULL THEN
          l_price_currency_code := p_price_currency_code;
          /* Getting validated in pa_control_items_pvt.update_control_item API. */
  ELSIF p_price_currency_code IS NULL THEN
          l_price_currency_code := p_price_currency_code;
  END IF;

  IF p_source_type_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_source_type_code IS NOT NULL THEN
          OPEN c_lkup(l_source_type, p_source_type_code);
          FETCH c_lkup INTO l_source_type_code;
          IF c_lkup%NOTFOUND then
            -- close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_SOURCE_TYPE_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_source_type_code IS NULL THEN
          l_source_type_code := p_source_type_code;
  END IF;

  IF p_source_comment = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_comment := p_source_comment;
  END IF;

  IF p_source_number = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_number := p_source_number;
  END IF;

  IF p_source_date_received = G_PA_MISS_DATE THEN
       NULL;
  ELSE
          l_source_date_received := p_source_date_received;
  END IF;

  IF p_source_organization = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_organization := p_source_organization;
  END IF;

  IF p_source_person = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_person := p_source_person;
  END IF;

  IF p_progress_as_of_date = G_PA_MISS_DATE THEN
       NULL;
  ELSIF p_progress_as_of_date IS NOT NULL THEN
          l_progress_as_of_date := p_progress_as_of_date;
  ELSIF p_progress_as_of_date IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_AS_OF_DATE_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  OPEN c_auto_num;
  FETCH c_auto_num INTO l_auto_numbers;
  close c_auto_num;

  IF l_auto_numbers is NOT NULL and l_auto_numbers <> 'Y' then

       IF (p_ci_number = G_PA_MISS_CHAR OR p_ci_number IS NULL) THEN

              IF l_ci_status_code IS NOT NULL THEN
                    l_new_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_ci_status_code);
              END IF;

              IF p_ci_number = G_PA_MISS_CHAR THEN
                   IF l_ci_number IS NULL THEN
                        IF (l_curr_system_status = 'CI_DRAFT' AND (l_new_system_status IS NOT NULL AND l_new_system_status <> 'CI_DRAFT')) THEN
                              PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                   ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                              x_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_curr_system_status <> 'CI_DRAFT' THEN
                                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                     ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                   END IF;
              ELSIF p_ci_number IS NULL THEN
                 IF (l_curr_system_status = 'CI_DRAFT' AND (l_new_system_status IS NOT NULL AND l_new_system_status <> 'CI_DRAFT')) THEN
                       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                 ELSIF l_curr_system_status <> 'CI_DRAFT' THEN
                       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
              END IF;

       ELSIF p_ci_number IS NOT NULL THEN
               l_ci_number := p_ci_number;

               OPEN c_ci_number(l_project_id, l_ci_type_id);
               FETCH c_ci_number into l_ROWID;
               IF (c_ci_number%NOTFOUND) then
                    CLOSE c_ci_number;
               ELSE
                    CLOSE c_ci_number;
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_CI_DUPLICATE_CI_NUMBER');
                    x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
       END IF;

  END IF;


  IF p_progress_status_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_progress_status_code IS NOT NULL THEN
          OPEN c_statuses(l_progress_type, p_progress_status_code);
          FETCH c_statuses INTO l_progress_status_code;
          IF c_statuses%NOTFOUND then
               close c_statuses;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_PROGRESS_STATUS_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_statuses;
  ELSIF p_progress_status_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_PROGRESS_STATUS_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_progress_overview = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_progress_overview := p_progress_overview;
  END IF;

  IF p_resolution_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_resolution_code IS NOT NULL THEN
          OPEN c_resolution (l_ci_type_id, p_resolution_code);
          FETCH c_resolution INTO l_resolution_code_id;
          IF c_resolution%NOTFOUND then
               close c_resolution;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_RESOLUTION_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_resolution;
  ELSIF p_resolution_code IS NULL THEN
          l_resolution_code_id := p_resolution_code;
  END IF;

  IF p_resolution_comment = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_resolution_comment := p_resolution_comment;
  END IF;

  IF p_attribute_category = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute_category := p_attribute_category;
  END IF;

  IF p_attribute1 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute1 := p_attribute1;
  END IF;

  IF p_attribute2 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute2 := p_attribute2;
  END IF;

  IF p_attribute3 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute3 := p_attribute3;
  END IF;

  IF p_attribute4 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute4 := p_attribute4;
  END IF;

  IF p_attribute5 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute5 := p_attribute5;
  END IF;

  IF p_attribute6 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute6 := p_attribute6;
  END IF;

  IF p_attribute7 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute7 := p_attribute7;
  END IF;

  IF p_attribute8 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute8 := p_attribute8;
  END IF;

  IF p_attribute9 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute9 := p_attribute9;
  END IF;

  IF p_attribute10 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute10 := p_attribute10;
  END IF;

  IF p_attribute11 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute11 := p_attribute11;
  END IF;

  IF p_attribute12 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute12 := p_attribute12;
  END IF;

  IF p_attribute13 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute13 := p_attribute13;
  END IF;

  IF p_attribute14 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute14 := p_attribute14;
  END IF;

  IF p_attribute15 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute15 := p_attribute15;
  END IF;


  IF (l_curr_status_code is NOT NULL AND
      l_ci_status_code   is NOT NULL AND
      l_curr_status_code <> l_ci_status_code AND
      l_to_status_flag = 'Y') THEN

	 IF l_debug_mode = 'Y' THEN
   	      pa_debug.write(l_module, 'Before call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate', l_debug_level3);
         END IF;

         PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate (
                                  p_init_msg_list      => p_init_msg_list
                                 ,p_commit             => p_commit
                                 ,p_validate_only      => l_validate_only
                                 ,p_max_msg_count      => l_max_msg_count
                                 ,p_ci_id              => p_ci_id
                                 ,p_status             => p_ci_status_code
                                 ,p_enforce_security   => l_enforce_security
                                 ,p_resolution_check   => l_resolution_check
                                 ,x_resolution_req     => l_resolution_req
                                 ,x_resolution_req_cls => l_resolution_req_cls
                                 ,x_start_wf           => l_start_wf
                                 ,x_new_status         => l_ci_status_code
                                 ,x_num_of_actions     => l_num_of_actions
                                 ,x_return_status      => x_return_status
                                 ,x_msg_count          => x_msg_count
                                 ,x_msg_data           => x_msg_data);

       /* l_ci_status_code gets the new status from ChangeCIStatusValidate.
          In case of CR/CO, if Auto Approve on Submission is enabled and while changing the status to submitted,
          then the new status would be the success status code defined for the workflow */

	IF l_debug_mode = 'Y' THEN
   	     pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate: x_return_status = '||x_return_status, l_debug_level3);
   	     pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate: l_ci_status_code = '||l_ci_status_code, l_debug_level3);
        END IF;

        IF x_return_status = 'S' THEN
             l_status_change_flag := 'Y';
        END IF;

	IF l_debug_mode = 'Y' THEN
   	     pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate: l_status_change_flag = '||l_status_change_flag, l_debug_level3);
        END IF;

        IF (l_resolution_req IS NOT NULL AND  l_resolution_req = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

        IF (l_resolution_req_cls IS NOT NULL AND  l_resolution_req_cls = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

  END IF;


  IF (l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

	  IF l_debug_mode = 'Y' THEN
   	       pa_debug.write(l_module, 'before call to PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM', l_debug_level3);
          END IF;

          PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM (
                                 p_api_version           =>  1.0
                                ,p_init_msg_list         => fnd_api.g_false
                                ,p_commit                => FND_API.g_false
                                ,p_validate_only         => FND_API.g_false
                                ,p_max_msg_count         => FND_API.g_miss_num
                                ,p_ci_id                 => p_ci_id
                                ,p_ci_type_id            => l_ci_type_id
                                ,p_summary               => l_summary
                                ,p_status_code           => l_ci_status_code
                                ,p_owner_id              => l_owner_id
                                ,p_owner_name            => null
                                ,p_highlighted_flag      => null
                                ,p_progress_status_code  => l_progress_status_code
                                ,p_progress_as_of_date   => l_progress_as_of_date
                                ,p_classification_code   => l_classification_code_id
                                ,p_reason_code           => l_reason_code_id
                                ,p_record_version_number => l_record_version_number
                                ,p_project_id            => l_project_id
                                ,p_object_type           => l_object_type
                                ,p_object_id             => l_object_id
                                ,p_object_name           => null
                                ,p_ci_number             => l_ci_number
                                ,p_date_required         => l_date_required
                                ,p_date_closed           => l_date_closed
                                ,p_closed_by_id          => l_closed_by_id
                                ,p_description           => l_description
                                ,p_status_overview       => l_progress_overview
                                ,p_resolution            => l_resolution_comment
                                ,p_resolution_code       => l_resolution_code_id
                                ,p_priority_code         => l_priority_code
                                ,p_effort_level_code     => l_effort_level_code
                                ,p_open_action_num       => null
                                ,p_price                 => l_price
                                ,p_price_currency_code   => l_price_currency_code
                                ,p_source_type_code      => l_source_type_code
                                ,p_source_comment        => l_source_comment
                                ,p_source_number         => l_source_number
                                ,p_source_date_received  => l_source_date_received
                                ,p_source_organization   => l_source_organization
                                ,p_source_person         => l_source_person
                                ,p_attribute_category    => l_attribute_category
                                ,p_attribute1            => l_attribute1
                                ,p_attribute2            => l_attribute2
                                ,p_attribute3            => l_attribute3
                                ,p_attribute4            => l_attribute4
                                ,p_attribute5            => l_attribute5
                                ,p_attribute6            => l_attribute6
                                ,p_attribute7            => l_attribute7
                                ,p_attribute8            => l_attribute8
                                ,p_attribute9            => l_attribute9
                                ,p_attribute10           => l_attribute10
                                ,p_attribute11           => l_attribute11
                                ,p_attribute12           => l_attribute12
                                ,p_attribute13           => l_attribute13
                                ,p_attribute14           => l_attribute14
                                ,p_attribute15           => l_attribute15
                                ,x_return_status         => x_return_status
                                ,x_msg_count             => x_msg_count
                                ,x_msg_data              => x_msg_data
                        );

	  IF l_debug_mode = 'Y' THEN
   	       pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM : x_return_status = '||x_return_status, l_debug_level3);
          END IF;

  END IF;

  IF (l_status_change_flag = 'Y' AND l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

	   IF l_debug_mode = 'Y' THEN
   	        pa_debug.write(l_module, 'before call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           /* call the insert table handlers of pa_obj_status_changes and pa_ci_comments here */

           PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT( p_object_type        => 'PA_CI_TYPES'
                                                            ,p_object_id          => p_ci_id
                                                            ,p_type_code          => 'CHANGE_STATUS'
                                                            ,p_status_type        => 'CONTROL_ITEM'
                                                            ,p_new_project_status => l_ci_status_code
                                                            ,p_old_project_status => l_curr_status_code
                                                            ,p_comment            => p_status_comment
                                                            ,x_return_status      => x_return_status
                                                            ,x_msg_count          => x_msg_count
                                                            ,x_msg_data           => x_msg_data );

	   IF l_debug_mode = 'Y' THEN
   	        pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus (
                                                          p_init_msg_list
                                                         ,p_commit
                                                         ,l_validate_only
                                                         ,l_max_msg_count
                                                         ,p_ci_id
                                                         ,l_curr_status_code
                                                         ,l_ci_status_code
                                                         ,l_start_wf
                                                         ,l_enforce_security
                                                         ,l_num_of_actions
                                                         ,x_return_status
                                                         ,x_msg_count
                                                         ,x_msg_data    );


           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus', l_debug_level3);
           END IF;

  END IF;


  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'Before Commit', l_debug_level3);
        END IF;

        COMMIT;

  END IF;

   --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'in FND_API.G_EXC_ERROR exception', l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_ISSUE_SVPT;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
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


   WHEN OTHERS THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'in OTHERS exception', l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := substr(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_ISSUE_SVPT;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_CONTROL_API_PUB'
        , p_procedure_name      => 'UPDATE_ISSUE'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

--        RAISE;

END UPDATE_ISSUE;


PROCEDURE UPDATE_CHANGE_REQUEST (
                        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN      NUMBER,
                        x_return_status         OUT NOCOPY    VARCHAR2,
                        x_msg_count             OUT NOCOPY    NUMBER,
                        x_msg_data              OUT NOCOPY    VARCHAR2,
                        p_ci_id                 IN      NUMBER,
                        P_RECORD_VERSION_NUMBER IN      NUMBER   := G_PA_MISS_NUM,
                        P_SUMMARY               IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DESCRIPTION           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_OWNER_ID              IN      NUMBER   := G_PA_MISS_NUM,
                        P_OWNER_COMMENT         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CLASSIFICATION_CODE   IN      NUMBER   := G_PA_MISS_NUM,
                        P_REASON_CODE           IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_ID             IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_TYPE           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_NUMBER             IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DATE_REQUIRED         IN      DATE     := G_PA_MISS_DATE,
                        P_PRIORITY_CODE         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_EFFORT_LEVEL_CODE     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PRICE                 IN      NUMBER   := G_PA_MISS_NUM,
                        P_PRICE_CURRENCY_CODE   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_TYPE_CODE      IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_NUMBER         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_DATE_RECEIVED  IN      DATE     := G_PA_MISS_DATE,
                        P_SOURCE_ORGANIZATION   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_PERSON         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_STATUS_CODE        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_STATUS_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_AS_OF_DATE   IN      DATE     := G_PA_MISS_DATE,
                        P_PROGRESS_STATUS_CODE  IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_OVERVIEW     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_CODE       IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_COMMENT    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE_CATEGORY    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE1            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE2            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE3            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE4            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE5            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE6            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE7            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE8            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE9            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE10           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE11           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE12           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE13           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE14           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE15           IN      VARCHAR2 := G_PA_MISS_CHAR
                        )
IS




 l_data                       VARCHAR2(2000);
 l_msg_data                   VARCHAR2(2000);
 l_msg_index_out              NUMBER;
 l_msg_count                  NUMBER := 0;

 l_check_update_access        VARCHAR2(1) := 'F';
 l_chk_status_ctrl            VARCHAR2(1) := 'N';
 l_module                     VARCHAR2(100) := 'PA_CONTROL_API_PUB.UPDATE_CHANGE_REQUEST';


 l_curr_status_code                   pa_control_items.status_code%TYPE;
 l_ci_status_code                     pa_control_items.status_code%TYPE;
 l_record_version_number              pa_control_items.record_version_number%TYPE;
 l_summary                            pa_control_items.summary%TYPE;
 l_description                        pa_control_items.description%TYPE;
 l_curr_owner_id                      pa_control_items.owner_id%TYPE;
 l_owner_id                           pa_control_items.owner_id%TYPE;
 l_classification_code_id             pa_control_items.classification_code_id%TYPE;
 l_reason_code_id                     pa_control_items.reason_code_id%TYPE;
 l_object_id                          pa_control_items.object_id%TYPE;
 l_object_type                        pa_control_items.object_type%TYPE;
 l_ci_number                          pa_control_items.ci_number%TYPE;
 l_date_required                      pa_control_items.date_required%TYPE;
 l_priority_code                      pa_control_items.priority_code%TYPE;
 l_effort_level_code                  pa_control_items.effort_level_code%TYPE;
 l_price                              pa_control_items.price%TYPE;
 l_price_currency_code                pa_control_items.price_currency_code%TYPE;
 l_source_type_code                   pa_control_items.source_type_code%TYPE;
 l_source_comment                     pa_control_items.source_comment%TYPE;
 l_source_number                      pa_control_items.source_number%TYPE;
 l_source_date_received               pa_control_items.source_date_received%TYPE;
 l_source_organization                pa_control_items.source_organization%TYPE;
 l_source_person                      pa_control_items.source_person%TYPE;
 l_progress_as_of_date                pa_control_items.progress_as_of_date%TYPE;
 l_progress_status_code               pa_control_items.progress_status_code%TYPE;
 l_progress_overview                  pa_control_items.status_overview%TYPE;
 l_resolution_code_id                 pa_control_items.resolution_code_id%TYPE;
 l_resolution_comment                 pa_control_items.resolution%TYPE;
 l_date_closed                        pa_control_items.date_closed%TYPE;
 l_closed_by_id                       pa_control_items.closed_by_id%TYPE;
 l_project_id                         pa_control_items.project_id%TYPE;
 l_ci_type_id                         pa_control_items.ci_type_id%TYPE;
 l_attribute_category                 pa_control_items.attribute_category%TYPE;
 l_attribute1                         pa_control_items.attribute1%TYPE;
 l_attribute2                         pa_control_items.attribute2%TYPE;
 l_attribute3                         pa_control_items.attribute3%TYPE;
 l_attribute4                         pa_control_items.attribute4%TYPE;
 l_attribute5                         pa_control_items.attribute5%TYPE;
 l_attribute6                         pa_control_items.attribute6%TYPE;
 l_attribute7                         pa_control_items.attribute7%TYPE;
 l_attribute8                         pa_control_items.attribute8%TYPE;
 l_attribute9                         pa_control_items.attribute9%TYPE;
 l_attribute10                        pa_control_items.attribute10%TYPE;
 l_attribute11                        pa_control_items.attribute11%TYPE;
 l_attribute12                        pa_control_items.attribute12%TYPE;
 l_attribute13                        pa_control_items.attribute13%TYPE;
 l_attribute14                        pa_control_items.attribute14%TYPE;
 l_attribute15                        pa_control_items.attribute15%TYPE;
  l_class_code                         constant varchar2(20) := 'CHANGE_REQUEST';

 CURSOR curr_row is
    SELECT *
      FROM pa_control_items
     WHERE ci_id = p_ci_id;

 cp    curr_row%rowtype;

 CURSOR c_submit_status (p_curr_status_code VARCHAR2) IS
    SELECT enable_wf_flag, wf_success_status_code, wf_failure_status_code
      FROM pa_project_statuses
     WHERE project_status_code = p_curr_status_code;

 CURSOR c_lkup (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
    SELECT lookup_code
      FROM pa_lookups
     WHERE lookup_type = p_lookup_type
       AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, trunc(sysdate))
       AND enabled_flag = 'Y'
       AND lookup_code = p_lookup_code;

 CURSOR c_statuses (p_status_type VARCHAR2, p_project_status_code VARCHAR2) IS
    SELECT project_status_code
      FROM pa_project_statuses
     WHERE status_type = p_status_type
       AND project_status_code = p_project_status_code
       AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, trunc(sysdate));

 CURSOR c_classification (p_ci_type_id NUMBER, p_class_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.classification_category
       AND cat.class_code_id = p_class_code_id;

 CURSOR c_reason (p_ci_type_id NUMBER, p_reason_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.reason_category
       AND cat.class_code_id = p_reason_code_id;

 CURSOR c_resolution (p_ci_type_id NUMBER, p_resolution_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.resolution_category
       AND cat.class_code_id = p_resolution_code_id;

 CURSOR c_auto_num IS
    SELECT type.auto_number_flag
      FROM pa_ci_types_b type,
           pa_control_items ci
     WHERE ci.ci_id = p_ci_id
       AND ci.ci_type_id = type.ci_type_id;

 CURSOR c_ci_number (p_project_id NUMBER, p_ci_type_id NUMBER) IS
    SELECT ROWID
      FROM pa_control_items
     WHERE project_id = p_project_id
       AND ci_number = p_ci_number
       AND ci_id <> p_ci_id
       AND ci_type_id = p_ci_type_id;

 CURSOR c_info IS
    SELECT cit.ci_type_class_code,
           cit.approval_required_flag,
             s.next_allowable_status_flag
      FROM pa_control_items c,
           pa_ci_types_b cit,
           pa_project_statuses s
     WHERE c.ci_id = p_ci_id
       AND c.status_code = s.project_status_code
       AND c.ci_type_id =cit.ci_type_id
       AND s.status_type = 'CONTROL_ITEM';

--added to get the owner name to include in the log message
 CURSOR c_get_owner(c_owner_id NUMBER,c_project_id NUMBER)  IS
     select distinct resource_source_name party_name
	 from PA_PROJECT_PARTIES_V
	 where party_type <> 'ORGANIZATION'
	 and resource_party_id = c_owner_id
         and project_id = c_project_id;

 l_stmnt                             VARCHAR2(5000);
 l_sel_clause                        VARCHAR2(300);
 l_from_clause                       VARCHAR2(300);
 l_where                             VARCHAR2(4000);
 l_where1                            VARCHAR2(2000);
 l_cursor                            NUMBER;
 l_rows                              NUMBER;
 l_rows1                             NUMBER;
 l_ci_status_code_1                  pa_project_statuses.project_status_code%TYPE;

 l_ROWID                             ROWID;

 l_enable_wf_flag                     pa_project_statuses.enable_wf_flag%TYPE;
 l_wf_success_status_code             pa_project_statuses.wf_success_status_code%TYPE;
 l_wf_failure_status_code             pa_project_statuses.wf_failure_status_code%TYPE;
 l_status_change_flag                 VARCHAR2(1) := 'N';
 l_start_wf                           VARCHAR2(1) := 'Y';
 l_validate_only                      VARCHAR2(1) := FND_API.g_false;
 l_max_msg_count                      NUMBER := FND_API.G_MISS_NUM;
 l_enforce_security                   VARCHAR2(1) := 'Y';
 l_num_of_actions                     NUMBER;
 l_priority_type                      VARCHAR2(30) := 'PA_TASK_PRIORITY_CODE';
 l_effort_type                        VARCHAR2(30) := 'PA_CI_EFFORT_LEVELS';
 l_source_type                        VARCHAR2(30) := 'PA_CI_SOURCE_TYPES';
 l_progress_type                      VARCHAR2(30) := 'PROGRESS';
 l_auto_numbers                       VARCHAR2(1);
 l_curr_system_status                 pa_project_statuses.project_system_status_code%TYPE;
 l_new_system_status                  pa_project_statuses.project_system_status_code%TYPE;
 l_next_allow_status_flag             pa_project_statuses.next_allowable_status_flag%TYPE;
 l_ci_type_class_code                 pa_ci_types_b.ci_type_class_code%TYPE;
 l_approval_required_flag             pa_ci_types_b.approval_required_flag%TYPE;
 l_resolution_check                   VARCHAR2(10) := 'AMG';
 l_resolution_req                     VARCHAR2(10) := 'N';
 l_resolution_req_cls                 VARCHAR2(10) := 'N';
 l_to_status_flag                     VARCHAR2(10) := 'Y';

 l_ci_comment_id                      pa_ci_comments.ci_comment_id%TYPE;
 l_comment_text                       pa_ci_comments.comment_text%TYPE;
 l_owner_name                         per_all_people_f.full_name%TYPE;
 l_curr_owner_name                    per_all_people_f.full_name%TYPE;
 l_chgowner_allowed                   VARCHAR2(1);
 l_to_owner_allowed                   VARCHAR2(1);


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

  IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function(p_function => 'UPDATE_CHANGE_REQUEST', p_debug_mode => l_debug_mode);
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
        savepoint UPDATE_CR_SVPT;
  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'Start of Update Change Request', l_debug_level3);
  END IF;

  OPEN curr_row;
  FETCH curr_row INTO cp;
  IF curr_row%NOTFOUND then
      close curr_row;
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CI_INVALID_ITEM');   /* Change this message */
      RAISE  FND_API.G_EXC_ERROR;
  ELSE

      l_curr_status_code        := cp.status_code;
      l_record_version_number   := cp.record_version_number;
      l_summary                 := cp.summary;
      l_description             := cp.description;
      l_curr_owner_id           := cp.owner_id;
      l_classification_code_id  := cp.classification_code_id;
      l_reason_code_id          := cp.reason_code_id;
      l_object_id               := cp.object_id;
      l_object_type             := cp.object_type;
      l_ci_number               := cp.ci_number;
      l_date_required           := cp.date_required;
      l_priority_code           := cp.priority_code;
      l_effort_level_code       := cp.effort_level_code;
      l_price                   := cp.price;
      l_price_currency_code     := cp.price_currency_code;
      l_source_type_code        := cp.source_type_code;
      l_source_comment          := cp.source_comment;
      l_source_number           := cp.source_number;
      l_source_date_received    := cp.source_date_received;
      l_source_organization     := cp.source_organization;
      l_source_person           := cp.source_person;
      l_progress_as_of_date     := cp.progress_as_of_date;
      l_progress_status_code    := cp.progress_status_code;
      l_progress_overview       := cp.status_overview;
      l_resolution_code_id      := cp.resolution_code_id;
      l_resolution_comment      := cp.resolution;
      l_date_closed             := cp.date_closed;
      l_closed_by_id            := cp.closed_by_id;
      l_project_id              := cp.project_id;
      l_ci_type_id              := cp.ci_type_id;
      l_attribute_category      := cp.attribute_category;
      l_attribute1              := cp.attribute1;
      l_attribute2              := cp.attribute2;
      l_attribute3              := cp.attribute3;
      l_attribute4              := cp.attribute4;
      l_attribute5              := cp.attribute5;
      l_attribute6              := cp.attribute6;
      l_attribute7              := cp.attribute7;
      l_attribute8              := cp.attribute8;
      l_attribute9              := cp.attribute9;
      l_attribute10             := cp.attribute10;
      l_attribute11             := cp.attribute11;
      l_attribute12             := cp.attribute12;
      l_attribute13             := cp.attribute13;
      l_attribute14             := cp.attribute14;
      l_attribute15             := cp.attribute15;

      close curr_row;

  END IF;


  OPEN c_info;
  FETCH c_info INTO l_ci_type_class_code, l_approval_required_flag, l_next_allow_status_flag;
  CLOSE c_info;

  /* Added to check invalid API usage*/
   if l_ci_type_class_code <> l_class_code then
	PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                             p_msg_name        => 'PA_CI_INV_API_USE');
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'wrong usage of the api for the control item type';
               pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
        end if;
	RAISE FND_API.G_EXC_ERROR;
   end if;



  l_curr_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_curr_status_code);

  /*  Check if the user can update the item. This requires the user to be owner or to have project authority or
      to have open UPDATE actions and status controls are satisfied.  */

  l_check_update_access := pa_ci_security_pkg.check_update_access(p_ci_id);

  IF (l_check_update_access = 'F') THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_UPDATE_ACCESS');
       RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After call to pa_ci_security_pkg.check_update_access', l_debug_level3);
  END IF;

  /* Check for the status control: check whether the action CONTROL_ITEM_ALLOW_UPDATE is allowed on the current status of the issue. */

  l_chk_status_ctrl := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM', l_curr_status_code, 'CONTROL_ITEM_ALLOW_UPDATE');

  IF (l_chk_status_ctrl = 'N') THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_ALLOW_UPDATE');
       RAISE FND_API.G_EXC_ERROR;

  END IF;


  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After call to pa_control_items_utils.CheckCIActionAllowed', l_debug_level3);
  END IF;

  /*  The control item will not be updateable if the current status has approval workflow attached. */

  OPEN c_submit_status(l_curr_status_code);
  FETCH c_submit_status INTO l_enable_wf_flag, l_wf_success_status_code, l_wf_failure_status_code;
  CLOSE c_submit_status;

  IF (l_enable_wf_flag = 'Y' AND l_wf_success_status_code IS NOT NULL AND l_wf_failure_status_code IS NOT NULL) THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_APPROVAL_WORKFLOW');
       RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After checking for submitted status', l_debug_level3);
  END IF;


  IF p_ci_status_code = G_PA_MISS_CHAR THEN
       l_ci_status_code := l_curr_status_code;
  ELSIF p_ci_status_code IS NOT NULL THEN
          l_ci_status_code := p_ci_status_code;

          l_sel_clause  := ' SELECT ps.project_status_code ';
          l_from_clause := ' FROM pa_obj_status_lists osl, pa_status_list_items sli, pa_project_statuses ps ';
          l_where       := ' WHERE osl.status_type = '||'''CONTROL_ITEM'''||
                             ' AND osl.object_type = '||'''PA_CI_TYPES'''||
                             ' AND osl.object_id = '||l_ci_type_id||
                             ' AND osl.status_list_id = sli.status_list_id'||
                             ' AND sli.project_status_code = ps.project_status_code'||
                             ' AND ps.project_status_code <> '||''''||l_curr_status_code||''''||
                             ' AND ps.status_type = osl.status_type'||
                             ' AND trunc(sysdate) between nvl(ps.start_date_active, trunc(sysdate)) and nvl(ps.end_date_active, trunc(sysdate))'||
                             ' AND (('||''''||l_next_allow_status_flag||''''||' = '||'''N'''||' and 1=2)'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''S'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in ( select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
                                  ''''||l_curr_status_code||''''||')))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''U'''||
                                  ' and ps.project_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||''''||
                                  l_curr_status_code||''''||'))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''A'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
                                  ''''||l_curr_system_status||''''||'))))'||
                              ' AND ps.project_status_code not in (select wf_success_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND ps.project_status_code not in (select wf_failure_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND decode(ps.project_system_status_code, '||'''CI_CANCELED'''||
                              ', nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_CANCEL'''||', null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_WORKING'''||
                              ' ,nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_REWORK'''||' ,null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_UPDST'''||' ,null),'||'''N'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_DRAFT'''||
                              ' ,decode('||''''||l_curr_system_status||''''||', '||'''CI_DRAFT'''||', '||
                              '''Y'''||' ,'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND ps.project_status_code = '||''''||p_ci_status_code||'''';

          IF (l_ci_type_class_code = 'CHANGE_REQUEST') THEN
                l_where1 := ' AND  ps.project_system_status_code <> '||'''CI_CLOSED''';
          END IF;

          l_stmnt := l_sel_clause || l_from_clause || l_where || l_where1;

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, l_stmnt, l_debug_level3);
          END IF;

    l_cursor := dbms_sql.open_cursor;

    DBMS_SQL.PARSE(l_cursor, l_stmnt, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_ci_status_code_1, 30);

    l_rows := DBMS_SQL.EXECUTE(l_cursor);

    IF (l_rows < 0) THEN
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_TO_STATUS_INVALID');
               x_return_status := FND_API.G_RET_STS_ERROR;
               l_to_status_flag := 'N';
    ELSE
       l_rows1 := DBMS_SQL.FETCH_ROWS(l_cursor);

       if l_rows1 > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_ci_status_code_1);
            l_ci_status_code := l_ci_status_code_1;
       else
	     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TO_STATUS_INVALID');
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_to_status_flag := 'N';
       end if;

    END IF;
    IF dbms_sql.is_open(l_cursor) THEN
         dbms_sql.close_cursor(l_cursor);
    END IF;
  ELSIF p_ci_status_code IS NULL THEN
          l_ci_status_code := p_ci_status_code;
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NULL_STATUS');
          x_return_status := FND_API.G_RET_STS_ERROR;
	  l_to_status_flag := 'N';
  END IF;

  IF p_record_version_number = G_PA_MISS_NUM THEN
       NULL;
  ELSE
       l_record_version_number := p_record_version_number;
  END IF;

  IF p_summary = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_summary IS NOT NULL THEN
          l_summary := p_summary;
  ELSIF p_summary IS NULL THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NULL_SUMMARY');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_description = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_description IS NOT NULL THEN
          l_description := p_description;
  ELSIF p_description IS NULL THEN
          l_description := p_description;
  END IF;

  /*Adding the comment after validating the Owner id*/
  IF p_owner_id = G_PA_MISS_NUM THEN
       l_owner_id := l_curr_owner_id;
  ELSIF p_owner_id IS NOT NULL THEN
          l_owner_id := p_owner_id;
          IF (l_owner_id = l_curr_owner_id) then
                 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
                 x_return_status := 'E';

	  ELSIF (l_owner_id <> l_curr_owner_id) then
		l_chgowner_allowed := pa_ci_security_pkg.check_change_owner_access(p_ci_id);
		IF (l_chgowner_allowed <> 'T') then
		         PA_UTILS.Add_Message( p_app_short_name => 'PA'
				              ,p_msg_name       => 'PA_CI_OWNER_CHG_NOT_ALLOWED');
			 x_return_status := 'E';
	        else
		         l_to_owner_allowed := pa_ci_security_pkg.is_to_owner_allowed(p_ci_id, l_owner_id);
		         if (l_to_owner_allowed <> 'T') then
				 PA_UTILS.Add_Message( p_app_short_name => 'PA'
					              ,p_msg_name       => 'PA_CI_TO_OWNER_NOT_ALLOWED');
		         x_return_status := 'E';
		         else

				/*get the Passed owner names*/
				OPEN c_get_owner(l_owner_id,l_project_id);
				FETCH c_get_owner into l_owner_name;
				if (c_get_owner%notfound) then
					PA_UTILS.Add_Message( p_app_short_name => 'PA'
					      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
					x_return_status := 'E';
				end if;
				close 	c_get_owner;

				/*Get the Current Owner name*/
				OPEN c_get_owner(l_curr_owner_id,l_project_id);
				FETCH c_get_owner into l_curr_owner_name;
				if (c_get_owner%notfound) then
					PA_UTILS.Add_Message( p_app_short_name => 'PA'
					      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
					x_return_status := 'E';
				end if;
				close 	c_get_owner;

					fnd_message.set_name('PA', 'PA_CI_LOG_OWNER_CHANGE');
					fnd_message.set_token('PREV_OWNER', l_curr_owner_name);
					fnd_message.set_token('NEXT_OWNER', l_owner_name);
					fnd_message.set_token('COMMENT', p_owner_comment);
					l_comment_text := fnd_message.get;

					 pa_ci_comments_pkg.insert_row(
						p_ci_comment_id             => l_ci_comment_id,
						p_ci_id                     => p_ci_id,
						p_type_code                 => 'CHANGE_OWNER',
						p_comment_text              => l_comment_text,
						p_last_updated_by           => fnd_global.user_id,
						p_created_by                => fnd_global.user_id,
						p_creation_date             => sysdate,
						p_last_update_date          => sysdate,
						p_last_update_login         => fnd_global.login_id,
						p_ci_action_id              => null);
			end if;
	        end if;
	end if;
  ELSIF p_owner_id IS NOT NULL THEN
          l_owner_id := p_owner_id;
          IF (l_owner_id = l_curr_owner_id) then
                 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
                 x_return_status := 'E';
          END IF;
          /* Getting validated in pa_control_items_pub.update_control_item API. */
  ELSIF p_owner_id IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_OWNER_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_classification_code = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_classification_code IS NOT NULL THEN
          OPEN c_classification (l_ci_type_id, p_classification_code);
          FETCH c_classification INTO l_classification_code_id;
          IF c_classification%NOTFOUND then
              -- close c_classification;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_CLASSIFICATION_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_classification;
  ELSIF p_classification_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_CLASSIFICATION_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_reason_code = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_reason_code IS NOT NULL THEN
          OPEN c_reason (l_ci_type_id, p_reason_code);
          FETCH c_reason INTO l_reason_code_id;
          IF c_reason%NOTFOUND then
             --  close c_reason;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_REASON_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_reason;
  ELSIF p_reason_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_REASON_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_object_id = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_object_id IS NOT NULL THEN
       /* As of now we're only handling PA_TASKS objects */
       BEGIN
               SELECT proj_element_id
                 INTO l_object_id
                 FROM PA_FIN_LATEST_PUB_TASKS_V
                WHERE project_id     = l_project_id
                  AND proj_element_id = p_object_id;

        EXCEPTION WHEN TOO_MANY_ROWS THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_MULTIPLE');
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_INV');
           x_return_status := FND_API.G_RET_STS_ERROR;
        END;
  ELSIF p_object_id IS NULL THEN
          l_object_id := p_object_id;
  END IF;

  IF p_object_type = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_object_type IS NOT NULL THEN
         IF p_object_type = 'PA_TASKS' THEN
              l_object_type := p_object_type;
         ELSE
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_TYPE_INV');
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
  ELSIF p_object_type IS NULL THEN
       l_object_type := p_object_type;
  END IF;

  IF p_date_required = G_PA_MISS_DATE THEN
       NULL;
  ELSIF p_date_required IS NOT NULL THEN
          l_date_required := p_date_required;
  ELSIF p_date_required IS NULL THEN
          l_date_required := p_date_required;
  END IF;

  IF p_priority_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_priority_code IS NOT NULL THEN
          OPEN c_lkup(l_priority_type, p_priority_code);
          FETCH c_lkup INTO l_priority_code;
          IF c_lkup%NOTFOUND then
            --  close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_PRIORITY_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_priority_code IS NULL THEN
          l_priority_code := p_priority_code;
  END IF;

  IF p_effort_level_code = G_PA_MISS_CHAR THEN
       l_effort_level_code := null;
  ELSIF p_effort_level_code IS NOT NULL THEN
          OPEN c_lkup(l_effort_type, p_effort_level_code);
          FETCH c_lkup INTO l_effort_level_code;
          IF c_lkup%NOTFOUND then
           --    close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_EFFORT_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_effort_level_code IS NULL THEN
          l_effort_level_code := p_effort_level_code;
  END IF;

  IF p_price = G_PA_MISS_NUM THEN
       l_price := null;
  ELSIF p_price IS NOT NULL THEN
          l_price := p_price;
  ELSIF p_price IS NULL THEN
          l_price := p_price;
  END IF;

  IF p_price_currency_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_price_currency_code IS NOT NULL THEN
          l_price_currency_code := p_price_currency_code;
          /* Getting validated in pa_control_items_pvt.update_control_item API. */
  ELSIF p_price_currency_code IS NULL THEN
          l_price_currency_code := p_price_currency_code;
  END IF;

  IF p_source_type_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_source_type_code IS NOT NULL THEN
          OPEN c_lkup(l_source_type, p_source_type_code);
          FETCH c_lkup INTO l_source_type_code;
          IF c_lkup%NOTFOUND then
              -- close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_SOURCE_TYPE_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_source_type_code IS NULL THEN
          l_source_type_code := p_source_type_code;
  END IF;

  IF p_source_comment = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_comment := p_source_comment;
  END IF;

  IF p_source_number = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_number := p_source_number;
  END IF;

  IF p_source_date_received = G_PA_MISS_DATE THEN
       NULL;
  ELSE
          l_source_date_received := p_source_date_received;
  END IF;

  IF p_source_organization = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_organization := p_source_organization;
  END IF;

  IF p_source_person = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_person := p_source_person;
  END IF;

  IF p_progress_as_of_date = G_PA_MISS_DATE THEN
       NULL;
  ELSIF p_progress_as_of_date IS NOT NULL THEN
          l_progress_as_of_date := p_progress_as_of_date;
  ELSIF p_progress_as_of_date IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_AS_OF_DATE_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  OPEN c_auto_num;
  FETCH c_auto_num INTO l_auto_numbers;
  close c_auto_num;

  IF l_auto_numbers is NOT NULL and l_auto_numbers <> 'Y' then

       IF (p_ci_number = G_PA_MISS_CHAR OR p_ci_number IS NULL) THEN

              IF l_ci_status_code IS NOT NULL THEN
                    l_new_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_ci_status_code);
              END IF;

              IF p_ci_number = G_PA_MISS_CHAR THEN
                   IF l_ci_number IS NULL THEN
                        IF (l_curr_system_status = 'CI_DRAFT' AND (l_new_system_status IS NOT NULL AND l_new_system_status <> 'CI_DRAFT')) THEN
                              PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                   ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                              x_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_curr_system_status <> 'CI_DRAFT' THEN
                                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                     ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                   END IF;
              ELSIF p_ci_number IS NULL THEN
                 IF (l_curr_system_status = 'CI_DRAFT' AND (l_new_system_status IS NOT NULL AND l_new_system_status <> 'CI_DRAFT')) THEN
                       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                 ELSIF l_curr_system_status <> 'CI_DRAFT' THEN
                       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
              END IF;

       ELSIF p_ci_number IS NOT NULL THEN
               l_ci_number := p_ci_number;

               OPEN c_ci_number(l_project_id, l_ci_type_id);
               FETCH c_ci_number into l_ROWID;
               IF (c_ci_number%NOTFOUND) then
                    CLOSE c_ci_number;
               ELSE
                    CLOSE c_ci_number;
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_CI_DUPLICATE_CI_NUMBER');
                    x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
       END IF;

  END IF;


  IF p_progress_status_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_progress_status_code IS NOT NULL THEN
          OPEN c_statuses(l_progress_type, p_progress_status_code);
          FETCH c_statuses INTO l_progress_status_code;
          IF c_statuses%NOTFOUND then
               close c_statuses;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_PROGRESS_STATUS_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_statuses;
  ELSIF p_progress_status_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_PROGRESS_STATUS_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_progress_overview = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_progress_overview := p_progress_overview;
  END IF;

  IF p_resolution_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_resolution_code IS NOT NULL THEN
          OPEN c_resolution (l_ci_type_id, p_resolution_code);
          FETCH c_resolution INTO l_resolution_code_id;
          IF c_resolution%NOTFOUND then
               close c_resolution;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_RESOLUTION_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_resolution;
  ELSIF p_resolution_code IS NULL THEN
          l_resolution_code_id := p_resolution_code;
  END IF;

  IF p_resolution_comment = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_resolution_comment := p_resolution_comment;
  END IF;

  IF p_attribute_category = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute_category := p_attribute_category;
  END IF;

  IF p_attribute1 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute1 := p_attribute1;
  END IF;

  IF p_attribute2 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute2 := p_attribute2;
  END IF;

  IF p_attribute3 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute3 := p_attribute3;
  END IF;

  IF p_attribute4 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute4 := p_attribute4;
  END IF;

  IF p_attribute5 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute5 := p_attribute5;
  END IF;

  IF p_attribute6 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute6 := p_attribute6;
  END IF;

  IF p_attribute7 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute7 := p_attribute7;
  END IF;

  IF p_attribute8 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute8 := p_attribute8;
  END IF;

  IF p_attribute9 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute9 := p_attribute9;
  END IF;

  IF p_attribute10 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute10 := p_attribute10;
  END IF;

  IF p_attribute11 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute11 := p_attribute11;
  END IF;

  IF p_attribute12 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute12 := p_attribute12;
  END IF;

  IF p_attribute13 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute13 := p_attribute13;
  END IF;

  IF p_attribute14 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute14 := p_attribute14;
  END IF;

  IF p_attribute15 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute15 := p_attribute15;
  END IF;


  IF (l_curr_status_code is NOT NULL AND
      l_ci_status_code   is NOT NULL AND
      l_curr_status_code <> l_ci_status_code AND
      l_to_status_flag = 'Y') THEN

         IF l_debug_mode = 'Y' THEN
              pa_debug.write(l_module, 'before call to ChangeCIStatusValidate', l_debug_level3);
         END IF;

         PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate (
                                  p_init_msg_list      => p_init_msg_list
                                 ,p_commit             => p_commit
                                 ,p_validate_only      => l_validate_only
                                 ,p_max_msg_count      => l_max_msg_count
                                 ,p_ci_id              => p_ci_id
                                 ,p_status             => p_ci_status_code
                                 ,p_enforce_security   => l_enforce_security
                                 ,p_resolution_check   => l_resolution_check
                                 ,x_resolution_req     => l_resolution_req
                                 ,x_resolution_req_cls => l_resolution_req_cls
                                 ,x_start_wf           => l_start_wf
                                 ,x_new_status         => l_ci_status_code
                                 ,x_num_of_actions     => l_num_of_actions
                                 ,x_return_status      => x_return_status
                                 ,x_msg_count          => x_msg_count
                                 ,x_msg_data           => x_msg_data);

       /* l_ci_status_code gets the new status from ChangeCIStatusValidate.
          In case of CR/CO, if Auto Approve on Submission is enabled and while changing the status to submitted,
          then the new status would be the success status code defined for the workflow */

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'After call to ChangeCIStatusValidate : x_return_status = '||x_return_status, l_debug_level3);
             pa_debug.write(l_module, 'After call to ChangeCIStatusValidate : l_ci_status_code = '||l_ci_status_code, l_debug_level3);
        END IF;

        IF x_return_status = 'S' THEN
             l_status_change_flag := 'Y';
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'After call to ChangeCIStatusValidate :l_status_change_flag = '||l_status_change_flag, l_debug_level3);
        END IF;

        IF (l_resolution_req IS NOT NULL AND  l_resolution_req = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

        IF (l_resolution_req_cls IS NOT NULL AND  l_resolution_req_cls = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

  END IF;


  IF (l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, 'before call to PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM', l_debug_level3);
          END IF;

          PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM (
                                 p_api_version           =>  1.0
                                ,p_init_msg_list         => fnd_api.g_false
                                ,p_commit                => FND_API.g_false
                                ,p_validate_only         => FND_API.g_false
                                ,p_max_msg_count         => FND_API.g_miss_num
                                ,p_ci_id                 => p_ci_id
                                ,p_ci_type_id            => l_ci_type_id
                                ,p_summary               => l_summary
                                ,p_status_code           => l_ci_status_code
                                ,p_owner_id              => l_owner_id
                                ,p_owner_name            => null
                                ,p_highlighted_flag      => null
                                ,p_progress_status_code  => l_progress_status_code
                                ,p_progress_as_of_date   => l_progress_as_of_date
                                ,p_classification_code   => l_classification_code_id
                                ,p_reason_code           => l_reason_code_id
                                ,p_record_version_number => l_record_version_number
                                ,p_project_id            => l_project_id
                                ,p_object_type           => l_object_type
                                ,p_object_id             => l_object_id
                                ,p_object_name           => null
                                ,p_ci_number             => l_ci_number
                                ,p_date_required         => l_date_required
                                ,p_date_closed           => l_date_closed
                                ,p_closed_by_id          => l_closed_by_id
                                ,p_description           => l_description
                                ,p_status_overview       => l_progress_overview
                                ,p_resolution            => l_resolution_comment
                                ,p_resolution_code       => l_resolution_code_id
                                ,p_priority_code         => l_priority_code
                                ,p_effort_level_code     => l_effort_level_code
                                ,p_open_action_num       => null
                                ,p_price                 => l_price
                                ,p_price_currency_code   => l_price_currency_code
                                ,p_source_type_code      => l_source_type_code
                                ,p_source_comment        => l_source_comment
                                ,p_source_number         => l_source_number
                                ,p_source_date_received  => l_source_date_received
                                ,p_source_organization   => l_source_organization
                                ,p_source_person         => l_source_person
                                ,p_attribute_category    => l_attribute_category
                                ,p_attribute1            => l_attribute1
                                ,p_attribute2            => l_attribute2
                                ,p_attribute3            => l_attribute3
                                ,p_attribute4            => l_attribute4
                                ,p_attribute5            => l_attribute5
                                ,p_attribute6            => l_attribute6
                                ,p_attribute7            => l_attribute7
                                ,p_attribute8            => l_attribute8
                                ,p_attribute9            => l_attribute9
                                ,p_attribute10           => l_attribute10
                                ,p_attribute11           => l_attribute11
                                ,p_attribute12           => l_attribute12
                                ,p_attribute13           => l_attribute13
                                ,p_attribute14           => l_attribute14
                                ,p_attribute15           => l_attribute15
                                ,x_return_status         => x_return_status
                                ,x_msg_count             => x_msg_count
                                ,x_msg_data              => x_msg_data
                        );

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM : x_return_status = '||x_return_status, l_debug_level3);
          END IF;

  END IF;

  IF (l_status_change_flag = 'Y' AND l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

           /* call the insert table handlers of pa_obj_status_changes and pa_ci_comments here */

           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'before call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT( p_object_type        => 'PA_CI_TYPES'
                                                            ,p_object_id          => p_ci_id
                                                            ,p_type_code          => 'CHANGE_STATUS'
                                                            ,p_status_type        => 'CONTROL_ITEM'
                                                            ,p_new_project_status => l_ci_status_code
                                                            ,p_old_project_status => l_curr_status_code
                                                            ,p_comment            => p_status_comment
                                                            ,x_return_status      => x_return_status
                                                            ,x_msg_count          => x_msg_count
                                                            ,x_msg_data           => x_msg_data );


           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus (
                                                          p_init_msg_list
                                                         ,p_commit
                                                         ,l_validate_only
                                                         ,l_max_msg_count
                                                         ,p_ci_id
                                                         ,l_curr_status_code
                                                         ,l_ci_status_code
                                                         ,l_start_wf
                                                         ,l_enforce_security
                                                         ,l_num_of_actions
                                                         ,x_return_status
                                                         ,x_msg_count
                                                         ,x_msg_data    );


           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call to PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus', l_debug_level3);
           END IF;

  END IF;


  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'Before Commit', l_debug_level3);
        END IF;

        COMMIT;

  END IF;

   --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'in FND_API.G_EXC_ERROR exception', l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CR_SVPT;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
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


   WHEN OTHERS THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'in OTHERS exception', l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := substr(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CR_SVPT;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_CONTROL_API_PUB'
        , p_procedure_name      => 'UPDATE_CHANGE_REQUEST'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

--        RAISE;

END UPDATE_CHANGE_REQUEST;


PROCEDURE UPDATE_CHANGE_ORDER (
                        p_commit                IN      VARCHAR2 := FND_API.G_FALSE,
                        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE,
                        p_api_version_number    IN      NUMBER,
                        x_return_status         OUT NOCOPY    VARCHAR2,
                        x_msg_count             OUT NOCOPY    NUMBER,
                        x_msg_data              OUT NOCOPY    VARCHAR2,
                        p_ci_id                 IN      NUMBER,
                        P_RECORD_VERSION_NUMBER IN      NUMBER   := G_PA_MISS_NUM,
                        P_SUMMARY               IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DESCRIPTION           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_OWNER_ID              IN      NUMBER   := G_PA_MISS_NUM,
                        P_OWNER_COMMENT         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CLASSIFICATION_CODE   IN      NUMBER   := G_PA_MISS_NUM,
                        P_REASON_CODE           IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_ID             IN      NUMBER   := G_PA_MISS_NUM,
                        P_OBJECT_TYPE           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_NUMBER             IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_DATE_REQUIRED         IN      DATE     := G_PA_MISS_DATE,
                        P_PRIORITY_CODE         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_EFFORT_LEVEL_CODE     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PRICE                 IN      NUMBER   := G_PA_MISS_NUM,
                        P_PRICE_CURRENCY_CODE   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_TYPE_CODE      IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_NUMBER         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_DATE_RECEIVED  IN      DATE     := G_PA_MISS_DATE,
                        P_SOURCE_ORGANIZATION   IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_SOURCE_PERSON         IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_CI_STATUS_CODE        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_STATUS_COMMENT        IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_AS_OF_DATE   IN      DATE     := G_PA_MISS_DATE,
                        P_PROGRESS_STATUS_CODE  IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_PROGRESS_OVERVIEW     IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_CODE       IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_RESOLUTION_COMMENT    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE_CATEGORY    IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE1            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE2            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE3            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE4            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE5            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE6            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE7            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE8            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE9            IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE10           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE11           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE12           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE13           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE14           IN      VARCHAR2 := G_PA_MISS_CHAR,
                        P_ATTRIBUTE15           IN      VARCHAR2 := G_PA_MISS_CHAR
                        )
IS





 l_data                       VARCHAR2(2000);
 l_msg_data                   VARCHAR2(2000);
 l_msg_index_out              NUMBER;
 l_msg_count                  NUMBER := 0;

 l_check_update_access        VARCHAR2(1) := 'F';
 l_chk_status_ctrl            VARCHAR2(1) := 'N';
 l_module                     VARCHAR2(100) := 'PA_CONTROL_API_PUB.UPDATE_CHANGE_ORDER';


 l_curr_status_code                   pa_control_items.status_code%TYPE;
 l_ci_status_code                     pa_control_items.status_code%TYPE;
 l_record_version_number              pa_control_items.record_version_number%TYPE;
 l_summary                            pa_control_items.summary%TYPE;
 l_description                        pa_control_items.description%TYPE;
 l_curr_owner_id                      pa_control_items.owner_id%TYPE;
 l_owner_id                           pa_control_items.owner_id%TYPE;
 l_classification_code_id             pa_control_items.classification_code_id%TYPE;
 l_reason_code_id                     pa_control_items.reason_code_id%TYPE;
 l_object_id                          pa_control_items.object_id%TYPE;
 l_object_type                        pa_control_items.object_type%TYPE;
 l_ci_number                          pa_control_items.ci_number%TYPE;
 l_date_required                      pa_control_items.date_required%TYPE;
 l_priority_code                      pa_control_items.priority_code%TYPE;
 l_effort_level_code                  pa_control_items.effort_level_code%TYPE;
 l_price                              pa_control_items.price%TYPE;
 l_price_currency_code                pa_control_items.price_currency_code%TYPE;
 l_source_type_code                   pa_control_items.source_type_code%TYPE;
 l_source_comment                     pa_control_items.source_comment%TYPE;
 l_source_number                      pa_control_items.source_number%TYPE;
 l_source_date_received               pa_control_items.source_date_received%TYPE;
 l_source_organization                pa_control_items.source_organization%TYPE;
 l_source_person                      pa_control_items.source_person%TYPE;
 l_progress_as_of_date                pa_control_items.progress_as_of_date%TYPE;
 l_progress_status_code               pa_control_items.progress_status_code%TYPE;
 l_progress_overview                  pa_control_items.status_overview%TYPE;
 l_resolution_code_id                 pa_control_items.resolution_code_id%TYPE;
 l_resolution_comment                 pa_control_items.resolution%TYPE;
 l_date_closed                        pa_control_items.date_closed%TYPE;
 l_closed_by_id                       pa_control_items.closed_by_id%TYPE;
 l_project_id                         pa_control_items.project_id%TYPE;
 l_ci_type_id                         pa_control_items.ci_type_id%TYPE;
 l_attribute_category                 pa_control_items.attribute_category%TYPE;
 l_attribute1                         pa_control_items.attribute1%TYPE;
 l_attribute2                         pa_control_items.attribute2%TYPE;
 l_attribute3                         pa_control_items.attribute3%TYPE;
 l_attribute4                         pa_control_items.attribute4%TYPE;
 l_attribute5                         pa_control_items.attribute5%TYPE;
 l_attribute6                         pa_control_items.attribute6%TYPE;
 l_attribute7                         pa_control_items.attribute7%TYPE;
 l_attribute8                         pa_control_items.attribute8%TYPE;
 l_attribute9                         pa_control_items.attribute9%TYPE;
 l_attribute10                        pa_control_items.attribute10%TYPE;
 l_attribute11                        pa_control_items.attribute11%TYPE;
 l_attribute12                        pa_control_items.attribute12%TYPE;
 l_attribute13                        pa_control_items.attribute13%TYPE;
 l_attribute14                        pa_control_items.attribute14%TYPE;
 l_attribute15                        pa_control_items.attribute15%TYPE;
 l_class_code                         constant varchar2(20) := 'CHANGE_ORDER';
 CURSOR curr_row is
    SELECT *
      FROM pa_control_items
     WHERE ci_id = p_ci_id;

 cp    curr_row%rowtype;

 CURSOR c_submit_status (p_curr_status_code VARCHAR2) IS
    SELECT enable_wf_flag, wf_success_status_code, wf_failure_status_code
      FROM pa_project_statuses
     WHERE project_status_code = p_curr_status_code;

 CURSOR c_lkup (p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
    SELECT lookup_code
      FROM pa_lookups
     WHERE lookup_type = p_lookup_type
       AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, trunc(sysdate))
       AND enabled_flag = 'Y'
       AND lookup_code = p_lookup_code;

 CURSOR c_statuses (p_status_type VARCHAR2, p_project_status_code VARCHAR2) IS
    SELECT project_status_code
      FROM pa_project_statuses
     WHERE status_type = p_status_type
       AND project_status_code = p_project_status_code
       AND trunc(sysdate) BETWEEN start_date_active AND nvl(end_date_active, trunc(sysdate));

 CURSOR c_classification (p_ci_type_id NUMBER, p_class_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.classification_category
       AND cat.class_code_id = p_class_code_id;

 CURSOR c_reason (p_ci_type_id NUMBER, p_reason_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.reason_category
       AND cat.class_code_id = p_reason_code_id;

 CURSOR c_resolution (p_ci_type_id NUMBER, p_resolution_code_id NUMBER) IS
    SELECT cat.class_code_id
      FROM pa_class_codes cat,
           pa_ci_types_b typ
     WHERE trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate))
       AND typ.ci_type_id = p_ci_type_id
       AND cat.class_category = typ.resolution_category
       AND cat.class_code_id = p_resolution_code_id;

 CURSOR c_auto_num IS
    SELECT type.auto_number_flag
      FROM pa_ci_types_b type,
           pa_control_items ci
     WHERE ci.ci_id = p_ci_id
       AND ci.ci_type_id = type.ci_type_id;

 CURSOR c_ci_number (p_project_id NUMBER, p_ci_type_id NUMBER) IS
    SELECT ROWID
      FROM pa_control_items
     WHERE project_id = p_project_id
       AND ci_number = p_ci_number
       AND ci_id <> p_ci_id
       AND ci_type_id = p_ci_type_id;

 CURSOR c_info IS
    SELECT cit.ci_type_class_code,
           cit.approval_required_flag,
             s.next_allowable_status_flag
      FROM pa_control_items c,
           pa_ci_types_b cit,
           pa_project_statuses s
     WHERE c.ci_id = p_ci_id
       AND c.status_code = s.project_status_code
       AND c.ci_type_id =cit.ci_type_id
       AND s.status_type = 'CONTROL_ITEM';

--added to get the owner name to include in the log message
 CURSOR c_get_owner(c_owner_id NUMBER,c_project_id NUMBER)  IS
     select distinct resource_source_name party_name
	 from PA_PROJECT_PARTIES_V
	 where party_type <> 'ORGANIZATION'
	 and resource_party_id = c_owner_id
         and project_id = c_project_id;

 l_stmnt                             VARCHAR2(5000);
 l_sel_clause                        VARCHAR2(300);
 l_from_clause                       VARCHAR2(300);
 l_where                             VARCHAR2(4000);
 l_where1                            VARCHAR2(2000);
 l_cursor                            NUMBER;
 l_rows                              NUMBER;
 l_rows1                             NUMBER;
 l_ci_status_code_1                  pa_project_statuses.project_status_code%TYPE;

 l_ROWID                             ROWID;

 l_enable_wf_flag                     pa_project_statuses.enable_wf_flag%TYPE;
 l_wf_success_status_code             pa_project_statuses.wf_success_status_code%TYPE;
 l_wf_failure_status_code             pa_project_statuses.wf_failure_status_code%TYPE;
 l_status_change_flag                 VARCHAR2(1) := 'N';
 l_start_wf                           VARCHAR2(1) := 'Y';
 l_validate_only                      VARCHAR2(1) := FND_API.g_false;
 l_max_msg_count                      NUMBER := FND_API.G_MISS_NUM;
 l_enforce_security                   VARCHAR2(1) := 'Y';
 l_num_of_actions                     NUMBER;
 l_priority_type                      VARCHAR2(30) := 'PA_TASK_PRIORITY_CODE';
 l_effort_type                        VARCHAR2(30) := 'PA_CI_EFFORT_LEVELS';
 l_source_type                        VARCHAR2(30) := 'PA_CI_SOURCE_TYPES';
 l_progress_type                      VARCHAR2(30) := 'PROGRESS';
 l_auto_numbers                       VARCHAR2(1);
 l_curr_system_status                 pa_project_statuses.project_system_status_code%TYPE;
 l_new_system_status                  pa_project_statuses.project_system_status_code%TYPE;
 l_next_allow_status_flag             pa_project_statuses.next_allowable_status_flag%TYPE;
 l_ci_type_class_code                 pa_ci_types_b.ci_type_class_code%TYPE;
 l_approval_required_flag             pa_ci_types_b.approval_required_flag%TYPE;
 l_resolution_check                   VARCHAR2(10) := 'AMG';
 l_resolution_req                     VARCHAR2(10) := 'N';
 l_resolution_req_cls                 VARCHAR2(10) := 'N';
 l_to_status_flag                     VARCHAR2(10) := 'Y';

 l_ci_comment_id                      pa_ci_comments.ci_comment_id%TYPE;
 l_comment_text                       pa_ci_comments.comment_text%TYPE;
 l_owner_name                         per_all_people_f.full_name%TYPE;
 l_curr_owner_name                    per_all_people_f.full_name%TYPE;
 l_chgowner_allowed                   VARCHAR2(1);
 l_to_owner_allowed                   VARCHAR2(1);


BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.login_id, 275, null, null), 'N');

  IF l_debug_mode = 'Y' THEN
        PA_DEBUG.set_curr_function(p_function => 'UPDATE_CHANGE_ORDER', p_debug_mode => l_debug_mode);
  END IF;

  IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_TRUE)) THEN
        FND_MSG_PUB.initialize;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
        savepoint UPDATE_CO_SVPT;
  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'Start of Update Chaneg Order', l_debug_level3);
  END IF;

  OPEN curr_row;
  FETCH curr_row INTO cp;
  IF curr_row%NOTFOUND then
      close curr_row;
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_CI_INVALID_ITEM');   /* Change this message */
      RAISE  FND_API.G_EXC_ERROR;
  ELSE

      l_curr_status_code        := cp.status_code;
      l_record_version_number   := cp.record_version_number;
      l_summary                 := cp.summary;
      l_description             := cp.description;
      l_curr_owner_id           := cp.owner_id;
      l_classification_code_id  := cp.classification_code_id;
      l_reason_code_id          := cp.reason_code_id;
      l_object_id               := cp.object_id;
      l_object_type             := cp.object_type;
      l_ci_number               := cp.ci_number;
      l_date_required           := cp.date_required;
      l_priority_code           := cp.priority_code;
      l_effort_level_code       := cp.effort_level_code;
      l_price                   := cp.price;
      l_price_currency_code     := cp.price_currency_code;
      l_source_type_code        := cp.source_type_code;
      l_source_comment          := cp.source_comment;
      l_source_number           := cp.source_number;
      l_source_date_received    := cp.source_date_received;
      l_source_organization     := cp.source_organization;
      l_source_person           := cp.source_person;
      l_progress_as_of_date     := cp.progress_as_of_date;
      l_progress_status_code    := cp.progress_status_code;
      l_progress_overview       := cp.status_overview;
      l_resolution_code_id      := cp.resolution_code_id;
      l_resolution_comment      := cp.resolution;
      l_date_closed             := cp.date_closed;
      l_closed_by_id            := cp.closed_by_id;
      l_project_id              := cp.project_id;
      l_ci_type_id              := cp.ci_type_id;
      l_attribute_category      := cp.attribute_category;
      l_attribute1              := cp.attribute1;
      l_attribute2              := cp.attribute2;
      l_attribute3              := cp.attribute3;
      l_attribute4              := cp.attribute4;
      l_attribute5              := cp.attribute5;
      l_attribute6              := cp.attribute6;
      l_attribute7              := cp.attribute7;
      l_attribute8              := cp.attribute8;
      l_attribute9              := cp.attribute9;
      l_attribute10             := cp.attribute10;
      l_attribute11             := cp.attribute11;
      l_attribute12             := cp.attribute12;
      l_attribute13             := cp.attribute13;
      l_attribute14             := cp.attribute14;
      l_attribute15             := cp.attribute15;

      close curr_row;

  END IF;

  OPEN c_info;
  FETCH c_info INTO l_ci_type_class_code, l_approval_required_flag, l_next_allow_status_flag;
  CLOSE c_info;


   /* Added to check invalid API usage*/
   if l_ci_type_class_code <> l_class_code then
	PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                             p_msg_name        => 'PA_CI_INV_API_USE');
        if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'wrong usage of the api for the control item type';
               pa_debug.write(l_module,pa_debug.g_err_stage,l_debug_level3);
        end if;
	RAISE FND_API.G_EXC_ERROR;
   end if;


  l_curr_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_curr_status_code);

  /*  Check if the user can update the item. This requires the user to be owner or to have project authority or
      to have open UPDATE actions and status controls are satisfied.  */

  l_check_update_access := pa_ci_security_pkg.check_update_access(p_ci_id);

  IF (l_check_update_access = 'F') THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_UPDATE_ACCESS');
       RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After call to pa_ci_security_pkg.check_update_access', l_debug_level3);
  END IF;

  /* Check for the status control: check whether the action CONTROL_ITEM_ALLOW_UPDATE is allowed on the current status of the issue. */

  l_chk_status_ctrl := pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM', l_curr_status_code, 'CONTROL_ITEM_ALLOW_UPDATE');

  IF (l_chk_status_ctrl = 'N') THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NO_ALLOW_UPDATE');
       RAISE FND_API.G_EXC_ERROR;

  END IF;


  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After call to pa_control_items_utils.CheckCIActionAllowed', l_debug_level3);
  END IF;

  /*  The control item will not be updateable if the current status has approval workflow attached. */

  OPEN c_submit_status(l_curr_status_code);
  FETCH c_submit_status INTO l_enable_wf_flag, l_wf_success_status_code, l_wf_failure_status_code;
  CLOSE c_submit_status;

  IF (l_enable_wf_flag = 'Y' AND l_wf_success_status_code IS NOT NULL AND l_wf_failure_status_code IS NOT NULL) THEN

       PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_APPROVAL_WORKFLOW');
       RAISE FND_API.G_EXC_ERROR;

  END IF;

  IF l_debug_mode = 'Y' THEN
        pa_debug.write(l_module, 'After checking for submitted status', l_debug_level3);
  END IF;


  IF p_ci_status_code = G_PA_MISS_CHAR THEN
       l_ci_status_code := l_curr_status_code;
  ELSIF p_ci_status_code IS NOT NULL THEN
          l_ci_status_code := p_ci_status_code;


          l_sel_clause  := ' SELECT ps.project_status_code ';
          l_from_clause := ' FROM pa_obj_status_lists osl, pa_status_list_items sli, pa_project_statuses ps ';
          l_where       := ' WHERE osl.status_type = '||'''CONTROL_ITEM'''||
                             ' AND osl.object_type = '||'''PA_CI_TYPES'''||
                             ' AND osl.object_id = '||l_ci_type_id||
                             ' AND osl.status_list_id = sli.status_list_id'||
                             ' AND sli.project_status_code = ps.project_status_code'||
                             ' AND ps.project_status_code <> '||''''||l_curr_status_code||''''||
                             ' AND ps.status_type = osl.status_type'||
                             ' AND trunc(sysdate) between nvl(ps.start_date_active, trunc(sysdate)) and nvl(ps.end_date_active, trunc(sysdate))'||
                             ' AND (('||''''||l_next_allow_status_flag||''''||' = '||'''N'''||' and 1=2)'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''S'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in ( select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
                                  ''''||l_curr_status_code||''''||')))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''U'''||
                                  ' and ps.project_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||''''||
                                  l_curr_status_code||''''||'))'||
                                  ' OR '||
                                  ' ('||''''||l_next_allow_status_flag||''''||' = '||'''A'''||
                                  ' and ps.project_status_code in (select project_status_code from pa_project_statuses where status_type = '||'''CONTROL_ITEM'''||
                                  ' and project_system_status_code in (select next_allowable_status_code from pa_next_allow_statuses where status_code = '||
                                  ''''||l_curr_system_status||''''||'))))'||
                              ' AND ps.project_status_code not in (select wf_success_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND ps.project_status_code not in (select wf_failure_status_code from pa_project_statuses where status_type = '||
                              '''CONTROL_ITEM'''||' and wf_success_status_code is not null and wf_failure_status_code is not null)'||
                              ' AND decode(ps.project_system_status_code, '||'''CI_CANCELED'''||
                              ', nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_CANCEL'''||', null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_WORKING'''||
                              ' ,nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_REWORK'''||' ,null),'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND nvl(pa_control_items_utils.CheckCIActionAllowed('||'''CONTROL_ITEM'''||', '||''''||l_curr_status_code||''''||', '||
                              '''CONTROL_ITEM_ALLOW_UPDST'''||' ,null),'||'''N'''||' ) = '||'''Y'''||
                              ' AND decode(ps.project_system_status_code,'||'''CI_DRAFT'''||
                              ' ,decode('||''''||l_curr_system_status||''''||', '||'''CI_DRAFT'''||', '||
                              '''Y'''||' ,'||'''N'''||' ),'||'''Y'''||' ) = '||'''Y'''||
                              ' AND ps.project_status_code = '||''''||p_ci_status_code||'''';

          IF (l_ci_type_class_code = 'CHANGE_ORDER' AND l_curr_system_status = 'CI_WORKING') THEN
                l_where1 := ' AND ps.project_system_status_code <> '||'''CI_CLOSED''';
          END IF;

          l_stmnt := l_sel_clause || l_from_clause || l_where || l_where1;

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, l_stmnt, l_debug_level3);
          END IF;

    l_cursor := dbms_sql.open_cursor;

    DBMS_SQL.PARSE(l_cursor, l_stmnt, DBMS_SQL.v7);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_ci_status_code_1, 30);

    l_rows := DBMS_SQL.EXECUTE(l_cursor);

    IF (l_rows < 0) THEN
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_TO_STATUS_INVALID');
               x_return_status := FND_API.G_RET_STS_ERROR;
               l_to_status_flag := 'N';
    ELSE
       l_rows1 := DBMS_SQL.FETCH_ROWS(l_cursor);

       if l_rows1 > 0 THEN
            DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_ci_status_code_1);
            l_ci_status_code := l_ci_status_code_1;
       else
	     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_TO_STATUS_INVALID');
             x_return_status := FND_API.G_RET_STS_ERROR;
             l_to_status_flag := 'N';
       end if;

    END IF;
    IF dbms_sql.is_open(l_cursor) THEN
         dbms_sql.close_cursor(l_cursor);
    END IF;
  ELSIF p_ci_status_code IS NULL THEN
          l_ci_status_code := p_ci_status_code;
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NULL_STATUS');
          x_return_status := FND_API.G_RET_STS_ERROR;
	  l_to_status_flag := 'N';
  END IF;

  IF p_record_version_number = G_PA_MISS_NUM THEN
       NULL;
  ELSE
       l_record_version_number := p_record_version_number;
  END IF;

  IF p_summary = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_summary IS NOT NULL THEN
          l_summary := p_summary;
  ELSIF p_summary IS NULL THEN
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CI_NULL_SUMMARY');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_description = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_description IS NOT NULL THEN
          l_description := p_description;
  ELSIF p_description IS NULL THEN
          l_description := p_description;
  END IF;

 /*Adding the comment after validating the Owner id*/
  IF p_owner_id = G_PA_MISS_NUM THEN
       l_owner_id := l_curr_owner_id;
  ELSIF p_owner_id IS NOT NULL THEN
          l_owner_id := p_owner_id;
          IF (l_owner_id = l_curr_owner_id) then
                 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
                 x_return_status := 'E';

	  ELSIF (l_owner_id <> l_curr_owner_id) then
		l_chgowner_allowed := pa_ci_security_pkg.check_change_owner_access(p_ci_id);
		IF (l_chgowner_allowed <> 'T') then
		         PA_UTILS.Add_Message( p_app_short_name => 'PA'
				              ,p_msg_name       => 'PA_CI_OWNER_CHG_NOT_ALLOWED');
			 x_return_status := 'E';
	        else
		         l_to_owner_allowed := pa_ci_security_pkg.is_to_owner_allowed(p_ci_id, l_owner_id);
		         if (l_to_owner_allowed <> 'T') then
				 PA_UTILS.Add_Message( p_app_short_name => 'PA'
					              ,p_msg_name       => 'PA_CI_TO_OWNER_NOT_ALLOWED');
		         x_return_status := 'E';
		         else

				/*get the Passed owner names*/
				OPEN c_get_owner(l_owner_id,l_project_id);
				FETCH c_get_owner into l_owner_name;
				if (c_get_owner%notfound) then
					PA_UTILS.Add_Message( p_app_short_name => 'PA'
					      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
					x_return_status := 'E';
				end if;
				close 	c_get_owner;

				/*Get the Current Owner name*/
				OPEN c_get_owner(l_curr_owner_id,l_project_id);
				FETCH c_get_owner into l_curr_owner_name;
				if (c_get_owner%notfound) then
					PA_UTILS.Add_Message( p_app_short_name => 'PA'
					      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
					x_return_status := 'E';
				end if;
				close 	c_get_owner;

					fnd_message.set_name('PA', 'PA_CI_LOG_OWNER_CHANGE');
					fnd_message.set_token('PREV_OWNER', l_curr_owner_name);
					fnd_message.set_token('NEXT_OWNER', l_owner_name);
					fnd_message.set_token('COMMENT', p_owner_comment);
					l_comment_text := fnd_message.get;

					 pa_ci_comments_pkg.insert_row(
						p_ci_comment_id             => l_ci_comment_id,
						p_ci_id                     => p_ci_id,
						p_type_code                 => 'CHANGE_OWNER',
						p_comment_text              => l_comment_text,
						p_last_updated_by           => fnd_global.user_id,
						p_created_by                => fnd_global.user_id,
						p_creation_date             => sysdate,
						p_last_update_date          => sysdate,
						p_last_update_login         => fnd_global.login_id,
						p_ci_action_id              => null);

			end if;
	        end if;
	end if;
  ELSIF p_owner_id IS NOT NULL THEN
          l_owner_id := p_owner_id;
          IF (l_owner_id = l_curr_owner_id) then
                 PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       => 'PA_CI_CHANGE_OWNER_INVALID');
                 x_return_status := 'E';
          END IF;
          /* Getting validated in pa_control_items_pub.update_control_item API. */
  ELSIF p_owner_id IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_OWNER_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_classification_code = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_classification_code IS NOT NULL THEN
          OPEN c_classification (l_ci_type_id, p_classification_code);
          FETCH c_classification INTO l_classification_code_id;
          IF c_classification%NOTFOUND then
              -- close c_classification;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_CLASSIFICATION_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_classification;
  ELSIF p_classification_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_CLASSIFICATION_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_reason_code = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_reason_code IS NOT NULL THEN
          OPEN c_reason (l_ci_type_id, p_reason_code);
          FETCH c_reason INTO l_reason_code_id;
          IF c_reason%NOTFOUND then
              -- close c_reason;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_REASON_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_reason;
  ELSIF p_reason_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_REASON_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_object_id = G_PA_MISS_NUM THEN
       NULL;
  ELSIF p_object_id IS NOT NULL THEN
       /* As of now we're only handling PA_TASKS objects */
       BEGIN
               SELECT proj_element_id
                 INTO l_object_id
                 FROM PA_FIN_LATEST_PUB_TASKS_V
                WHERE project_id     = l_project_id
                  AND proj_element_id = p_object_id;

        EXCEPTION WHEN TOO_MANY_ROWS THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_MULTIPLE');
           x_return_status := FND_API.G_RET_STS_ERROR;

        WHEN OTHERS THEN
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_NAME_INV');
           x_return_status := FND_API.G_RET_STS_ERROR;
        END;
  ELSIF p_object_id IS NULL THEN
          l_object_id := p_object_id;
  END IF;

  IF p_object_type = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_object_type IS NOT NULL THEN
         IF p_object_type = 'PA_TASKS' THEN
              l_object_type := p_object_type;
         ELSE
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_OBJECT_TYPE_INV');
           x_return_status := FND_API.G_RET_STS_ERROR;
         END IF;
  ELSIF p_object_type IS NULL THEN
       l_object_type := p_object_type;
  END IF;

  IF p_date_required = G_PA_MISS_DATE THEN
       NULL;
  ELSIF p_date_required IS NOT NULL THEN
          l_date_required := p_date_required;
  ELSIF p_date_required IS NULL THEN
          l_date_required := p_date_required;
  END IF;

  IF p_priority_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_priority_code IS NOT NULL THEN
          OPEN c_lkup(l_priority_type, p_priority_code);
          FETCH c_lkup INTO l_priority_code;
          IF c_lkup%NOTFOUND then
             --  close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_PRIORITY_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_priority_code IS NULL THEN
          l_priority_code := p_priority_code;
  END IF;

  IF p_effort_level_code = G_PA_MISS_CHAR THEN
       l_effort_level_code := null;
  ELSIF p_effort_level_code IS NOT NULL THEN
          OPEN c_lkup(l_effort_type, p_effort_level_code);
          FETCH c_lkup INTO l_effort_level_code;
          IF c_lkup%NOTFOUND then
             --  close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_EFFORT_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_effort_level_code IS NULL THEN
          l_effort_level_code := p_effort_level_code;
  END IF;

  IF p_price = G_PA_MISS_NUM THEN
       l_price := null;
  ELSIF p_price IS NOT NULL THEN
          l_price := p_price;
  ELSIF p_price IS NULL THEN
          l_price := p_price;
  END IF;

  IF p_price_currency_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_price_currency_code IS NOT NULL THEN
          l_price_currency_code := p_price_currency_code;
          /* Getting validated in pa_control_items_pvt.update_control_item API. */
  ELSIF p_price_currency_code IS NULL THEN
          l_price_currency_code := p_price_currency_code;
  END IF;

  IF p_source_type_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_source_type_code IS NOT NULL THEN
          OPEN c_lkup(l_source_type, p_source_type_code);
          FETCH c_lkup INTO l_source_type_code;
          IF c_lkup%NOTFOUND then
             --  close c_lkup;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_SOURCE_TYPE_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_lkup;
  ELSIF p_source_type_code IS NULL THEN
          l_source_type_code := p_source_type_code;
  END IF;

  IF p_source_comment = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_comment := p_source_comment;
  END IF;

  IF p_source_number = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_number := p_source_number;
  END IF;

  IF p_source_date_received = G_PA_MISS_DATE THEN
       NULL;
  ELSE
          l_source_date_received := p_source_date_received;
  END IF;

  IF p_source_organization = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_organization := p_source_organization;
  END IF;

  IF p_source_person = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_source_person := p_source_person;
  END IF;

  IF p_progress_as_of_date = G_PA_MISS_DATE THEN
       NULL;
  ELSIF p_progress_as_of_date IS NOT NULL THEN
          l_progress_as_of_date := p_progress_as_of_date;
  ELSIF p_progress_as_of_date IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_AS_OF_DATE_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  OPEN c_auto_num;
  FETCH c_auto_num INTO l_auto_numbers;
  close c_auto_num;

  IF l_auto_numbers is NOT NULL and l_auto_numbers <> 'Y' then

       IF (p_ci_number = G_PA_MISS_CHAR OR p_ci_number IS NULL) THEN

              IF l_ci_status_code IS NOT NULL THEN
                    l_new_system_status :=  PA_CONTROL_ITEMS_UTILS.getSystemStatus(l_ci_status_code);
              END IF;

              IF p_ci_number = G_PA_MISS_CHAR THEN
                   IF l_ci_number IS NULL THEN
                        IF (l_curr_system_status = 'CI_DRAFT' AND (l_new_system_status IS NOT NULL AND l_new_system_status <> 'CI_DRAFT')) THEN
                              PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                   ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                              x_return_status := FND_API.G_RET_STS_ERROR;
                        ELSIF l_curr_system_status <> 'CI_DRAFT' THEN
                                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                                     ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                                x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                   END IF;
              ELSIF p_ci_number IS NULL THEN
                 IF (l_curr_system_status = 'CI_DRAFT' AND (l_new_system_status IS NOT NULL AND l_new_system_status <> 'CI_DRAFT')) THEN
                       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                 ELSIF l_curr_system_status <> 'CI_DRAFT' THEN
                       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_CI_NO_CI_NUMBER');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                 END IF;
              END IF;

       ELSIF p_ci_number IS NOT NULL THEN
               l_ci_number := p_ci_number;

               OPEN c_ci_number(l_project_id, l_ci_type_id);
               FETCH c_ci_number into l_ROWID;
               IF (c_ci_number%NOTFOUND) then
                    CLOSE c_ci_number;
               ELSE
                    CLOSE c_ci_number;
                    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_CI_DUPLICATE_CI_NUMBER');
                    x_return_status := FND_API.G_RET_STS_ERROR;
               END IF;
       END IF;

  END IF;


  IF p_progress_status_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_progress_status_code IS NOT NULL THEN
          OPEN c_statuses(l_progress_type, p_progress_status_code);
          FETCH c_statuses INTO l_progress_status_code;
          IF c_statuses%NOTFOUND then
               close c_statuses;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_PROGRESS_STATUS_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_statuses;
  ELSIF p_progress_status_code IS NULL THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_PROGRESS_STATUS_NULL');
          x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_progress_overview = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
          l_progress_overview := p_progress_overview;
  END IF;

  IF p_resolution_code = G_PA_MISS_CHAR THEN
       NULL;
  ELSIF p_resolution_code IS NOT NULL THEN
          OPEN c_resolution (l_ci_type_id, p_resolution_code);
          FETCH c_resolution INTO l_resolution_code_id;
          IF c_resolution%NOTFOUND then
               close c_resolution;
               PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_CI_RESOLUTION_INV');
               x_return_status := FND_API.G_RET_STS_ERROR;
          END IF;
          close c_resolution;
  ELSIF p_resolution_code IS NULL THEN
          l_resolution_code_id := p_resolution_code;
  END IF;

  IF p_resolution_comment = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_resolution_comment := p_resolution_comment;
  END IF;

  IF p_attribute_category = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute_category := p_attribute_category;
  END IF;

  IF p_attribute1 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute1 := p_attribute1;
  END IF;

  IF p_attribute2 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute2 := p_attribute2;
  END IF;

  IF p_attribute3 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute3 := p_attribute3;
  END IF;

  IF p_attribute4 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute4 := p_attribute4;
  END IF;

  IF p_attribute5 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute5 := p_attribute5;
  END IF;

  IF p_attribute6 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute6 := p_attribute6;
  END IF;

  IF p_attribute7 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute7 := p_attribute7;
  END IF;

  IF p_attribute8 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute8 := p_attribute8;
  END IF;

  IF p_attribute9 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute9 := p_attribute9;
  END IF;

  IF p_attribute10 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute10 := p_attribute10;
  END IF;

  IF p_attribute11 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute11 := p_attribute11;
  END IF;

  IF p_attribute12 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute12 := p_attribute12;
  END IF;

  IF p_attribute13 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute13 := p_attribute13;
  END IF;

  IF p_attribute14 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute14 := p_attribute14;
  END IF;

  IF p_attribute15 = G_PA_MISS_CHAR THEN
       NULL;
  ELSE
       l_attribute15 := p_attribute15;
  END IF;


  IF (l_curr_status_code is NOT NULL AND
      l_ci_status_code   is NOT NULL AND
      l_curr_status_code <> l_ci_status_code AND
      l_to_status_flag = 'Y') THEN

         IF l_debug_mode = 'Y' THEN
              pa_debug.write(l_module, 'before call to ChangeCIStatusValidate', l_debug_level3);
         END IF;

         PA_CONTROL_ITEMS_UTILS.ChangeCIStatusValidate (
                                  p_init_msg_list      => p_init_msg_list
                                 ,p_commit             => p_commit
                                 ,p_validate_only      => l_validate_only
                                 ,p_max_msg_count      => l_max_msg_count
                                 ,p_ci_id              => p_ci_id
                                 ,p_status             => p_ci_status_code
                                 ,p_enforce_security   => l_enforce_security
                                 ,p_resolution_check   => l_resolution_check
                                 ,x_resolution_req     => l_resolution_req
                                 ,x_resolution_req_cls => l_resolution_req_cls
                                 ,x_start_wf           => l_start_wf
                                 ,x_new_status         => l_ci_status_code
                                 ,x_num_of_actions     => l_num_of_actions
                                 ,x_return_status      => x_return_status
                                 ,x_msg_count          => x_msg_count
                                 ,x_msg_data           => x_msg_data);

       /* l_ci_status_code gets the new status from ChangeCIStatusValidate.
          In case of CR/CO, if Auto Approve on Submission is enabled and while changing the status to submitted,
          then the new status would be the success status code defined for the workflow */

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'After call to ChangeCIStatusValidate : x_return_status = '||x_return_status, l_debug_level3);
             pa_debug.write(l_module, 'After call to ChangeCIStatusValidate : l_ci_status_code = '||l_ci_status_code, l_debug_level3);
        END IF;

        IF x_return_status = 'S' THEN
             l_status_change_flag := 'Y';
        END IF;

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'After call to ChangeCIStatusValidate : l_status_change_flag = '||l_status_change_flag, l_debug_level3);
        END IF;

        IF (l_resolution_req IS NOT NULL AND  l_resolution_req = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_RESOLUTION_OPEN');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

        IF (l_resolution_req_cls IS NOT NULL AND  l_resolution_req_cls = 'Y') THEN
              IF (PA_CONTROL_ITEMS_UTILS.checkhasresolution(p_ci_id) <> 'Y'  ) THEN
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              ELSE
                  IF (l_resolution_code_id IS NULL) THEN
                      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_CI_CLOSE_INV_RES');
                      x_return_status := FND_API.G_RET_STS_ERROR;
                  END IF;
              END IF;
        END IF;

  END IF;


  IF (l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, 'before call to PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM', l_debug_level3);
          END IF;

          PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM (
                                 p_api_version           =>  1.0
                                ,p_init_msg_list         => fnd_api.g_false
                                ,p_commit                => FND_API.g_false
                                ,p_validate_only         => FND_API.g_false
                                ,p_max_msg_count         => FND_API.g_miss_num
                                ,p_ci_id                 => p_ci_id
                                ,p_ci_type_id            => l_ci_type_id
                                ,p_summary               => l_summary
                                ,p_status_code           => l_ci_status_code
                                ,p_owner_id              => l_owner_id
                                ,p_owner_name            => null
                                ,p_highlighted_flag      => null
                                ,p_progress_status_code  => l_progress_status_code
                                ,p_progress_as_of_date   => l_progress_as_of_date
                                ,p_classification_code   => l_classification_code_id
                                ,p_reason_code           => l_reason_code_id
                                ,p_record_version_number => l_record_version_number
                                ,p_project_id            => l_project_id
                                ,p_object_type           => l_object_type
                                ,p_object_id             => l_object_id
                                ,p_object_name           => null
                                ,p_ci_number             => l_ci_number
                                ,p_date_required         => l_date_required
                                ,p_date_closed           => l_date_closed
                                ,p_closed_by_id          => l_closed_by_id
                                ,p_description           => l_description
                                ,p_status_overview       => l_progress_overview
                                ,p_resolution            => l_resolution_comment
                                ,p_resolution_code       => l_resolution_code_id
                                ,p_priority_code         => l_priority_code
                                ,p_effort_level_code     => l_effort_level_code
                                ,p_open_action_num       => null
                                ,p_price                 => l_price
                                ,p_price_currency_code   => l_price_currency_code
                                ,p_source_type_code      => l_source_type_code
                                ,p_source_comment        => l_source_comment
                                ,p_source_number         => l_source_number
                                ,p_source_date_received  => l_source_date_received
                                ,p_source_organization   => l_source_organization
                                ,p_source_person         => l_source_person
                                ,p_attribute_category    => l_attribute_category
                                ,p_attribute1            => l_attribute1
                                ,p_attribute2            => l_attribute2
                                ,p_attribute3            => l_attribute3
                                ,p_attribute4            => l_attribute4
                                ,p_attribute5            => l_attribute5
                                ,p_attribute6            => l_attribute6
                                ,p_attribute7            => l_attribute7
                                ,p_attribute8            => l_attribute8
                                ,p_attribute9            => l_attribute9
                                ,p_attribute10           => l_attribute10
                                ,p_attribute11           => l_attribute11
                                ,p_attribute12           => l_attribute12
                                ,p_attribute13           => l_attribute13
                                ,p_attribute14           => l_attribute14
                                ,p_attribute15           => l_attribute15
                                ,x_return_status         => x_return_status
                                ,x_msg_count             => x_msg_count
                                ,x_msg_data              => x_msg_data
                        );

          IF l_debug_mode = 'Y' THEN
               pa_debug.write(l_module, 'after call to PA_CONTROL_ITEMS_PUB.UPDATE_CONTROL_ITEM : x_return_status = '||x_return_status, l_debug_level3);
          END IF;

  END IF;

  IF (l_status_change_flag = 'Y' AND l_validate_only <> fnd_api.g_true AND x_return_status = 'S') THEN

           /* call the insert table handlers of pa_obj_status_changes and pa_ci_comments here */

           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'before call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT( p_object_type        => 'PA_CI_TYPES'
                                                            ,p_object_id          => p_ci_id
                                                            ,p_type_code          => 'CHANGE_STATUS'
                                                            ,p_status_type        => 'CONTROL_ITEM'
                                                            ,p_new_project_status => l_ci_status_code
                                                            ,p_old_project_status => l_curr_status_code
                                                            ,p_comment            => p_status_comment
                                                            ,x_return_status      => x_return_status
                                                            ,x_msg_count          => x_msg_count
                                                            ,x_msg_data           => x_msg_data );


           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call to PA_CONTROL_ITEMS_UTILS.ADD_STATUS_CHANGE_COMMENT', l_debug_level3);
           END IF;

           PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus (
                                                          p_init_msg_list
                                                         ,p_commit
                                                         ,l_validate_only
                                                         ,l_max_msg_count
                                                         ,p_ci_id
                                                         ,l_curr_status_code
                                                         ,l_ci_status_code
                                                         ,l_start_wf
                                                         ,l_enforce_security
                                                         ,l_num_of_actions
                                                         ,x_return_status
                                                         ,x_msg_count
                                                         ,x_msg_data    );


           IF l_debug_mode = 'Y' THEN
                pa_debug.write(l_module, 'After call to PA_CONTROL_ITEMS_UTILS.PostChangeCIStatus', l_debug_level3);
           END IF;

  END IF;


  IF (p_commit = FND_API.G_TRUE AND x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'Before Commit', l_debug_level3);
        END IF;

        COMMIT;

  END IF;

   --Reset the stack
         if l_debug_mode = 'Y' then
                  Pa_Debug.reset_curr_function;
         end if;


EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'in FND_API.G_EXC_ERROR exception', l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_ERROR;
        l_msg_count := FND_MSG_PUB.count_msg;

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CO_SVPT;
        END IF;

        IF l_msg_count = 1 AND x_msg_data IS NULL THEN
                PA_INTERFACE_UTILS_PUB.get_messages
                ( p_encoded        => FND_API.G_FALSE
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


   WHEN OTHERS THEN
        IF l_debug_mode = 'Y' THEN
             pa_debug.write(l_module, 'in OTHERS exception', l_debug_level3);
        END IF;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_data      := substr(SQLERRM,1,240);

        IF p_commit = FND_API.G_TRUE THEN
                ROLLBACK TO UPDATE_CO_SVPT;
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name            => 'PA_CONTROL_API_PUB'
        , p_procedure_name      => 'UPDATE_CHANGE_ORDER'
        , p_error_text          => x_msg_data);

        x_msg_count     := FND_MSG_PUB.count_msg;

        IF l_debug_mode = 'Y' THEN
                PA_DEBUG.reset_curr_function;
        END IF;

--        RAISE;

END UPDATE_CHANGE_ORDER;


END PA_CONTROL_API_PUB;

/
