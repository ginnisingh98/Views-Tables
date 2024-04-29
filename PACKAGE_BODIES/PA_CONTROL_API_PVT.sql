--------------------------------------------------------
--  DDL for Package Body PA_CONTROL_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CONTROL_API_PVT" as
/*$Header: PACIAMVB.pls 120.0.12010000.2 2009/08/17 07:05:45 kkorada ship $*/

g_module_name     VARCHAR2(100) := 'pa.plsql.PA_CONTROL_API_PVT';



api_error         Exception;

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
        (select project_status_code,
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


/*The update_impacts procedure will be called from Add_<impact_type>_impact and
update_<impact_type>_impact to create the impact, to update the details of impact and also
to implement the impact.*/
Procedure update_impacts (
        p_ci_id                        IN NUMBER    := G_PA_MISS_NUM,
        x_ci_impact_id                 OUT NOCOPY NUMBER,
        p_impact_type_code             IN VARCHAR2  := G_PA_MISS_CHAR,
        p_impact_description           IN VARCHAR2  := G_PA_MISS_CHAR,
        p_mode                         IN VARCHAR2,
        p_commit                       IN VARCHAR2  := FND_API.G_FALSE,
        p_init_msg_list                IN VARCHAR2  := FND_API.G_FALSE,
        p_api_version_number           IN NUMBER ,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2
        )
IS

/*Cursor for possible ci_impacts. */
cursor c_impact_types
        is
        select distinct
        pci.ci_id
        --pci.ci_type_id,
        --pl.lookup_code impact_type_code,
        --pl.predefined_flag,
        --pl.meaning impact_name,
        --pci.project_id project_id
        from
        pa_control_items pci,
        pa_ci_impact_type_usage pcit,
        pa_lookups pl
        where pci.ci_type_id = pcit.ci_type_id
        and pl.lookup_type = 'PA_CI_IMPACT_TYPES'
        and decode(pcit.impact_type_code, 'FINPLAN_COST', 'FINPLAN', 'FINPLAN_REVENUE', 'FINPLAN', pcit.impact_type_code) = pl.lookup_code
        and pl.enabled_flag = 'Y'
        and Pa_ci_impacts_util.is_render_true(pl.lookup_code, pci.project_id) = 'Y'
        and ci_id = p_ci_id
        and impact_type_code = p_impact_type_code;


/*Cursor to check whether the ci_impact_id exits or not.*/
 cursor c_check_impact_exists
        is
        select ci_impact_id ,status_code,description
        from
        pa_ci_impacts
        where ci_id = p_ci_id
        and impact_type_code = p_impact_type_code;


 --Declaring local Variables

 l_status_code              pa_ci_impacts.status_code%TYPE := null;
 l_ci_id                    pa_control_items.ci_id%TYPE := null;
 l_impact_type_code         pa_ci_impacts.impact_type_code%TYPE;
 l_project_id               pa_control_items.project_id%TYPE;
 l_ci_type_id               pa_ci_types_b.ci_type_id%TYPE;
 l_cr_status_code           pa_control_items.status_code%type;
 l_ci_type_class_code       pa_ci_types_b.ci_type_class_Code%TYPE;
 l_ci_impact_id             pa_ci_impacts.ci_impact_id%TYPE;
 l_impact_description       pa_ci_impacts.description%type;
 l_impact_description1      pa_ci_impacts.description%type;



 has_access               VARCHAR2(1); --for security check
 l_mode                   VARCHAR2(20)  := 'INSERT'; --used to call the insert or update method.
 l_context                VARCHAR2(40)  := null;
 l_error_msg              VARCHAR2(200);
 temp                     VARCHAR2(1);
 l_version_number         NUMBER(15);
 l_data                   VARCHAR2(2000);
 l_msg_data               VARCHAR2(2000);
 l_msg_index_out          NUMBER;
 l_module_name            VARCHAR2(200):='PA_CONTROL_API_PVT.UPDATE_IMPACTS';
 l_msg_count              NUMBER := 0;


 c_check_impact_exists_rec   c_check_impact_exists %rowtype;

BEGIN


       -- initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  	if l_debug_mode = 'Y' then
        	  pa_debug.set_curr_function(p_function =>l_module_name,p_debug_mode => l_debug_mode);
  	end if;


        if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'Start of Update Impacts  PVT method.';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        l_ci_id := p_ci_id;
        /*Get the control item details- this also checks for Ci_id is Valid or not*/
        open Get_CI_Data(p_ci_id);
        fetch Get_CI_Data into l_project_id,l_cr_status_code,l_ci_type_class_code,l_version_number;
        if Get_CI_Data%notfound then
                PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CI_INV_CI_ID');
                if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The ci_id is invalid';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                x_return_status := FND_API.G_RET_STS_ERROR;
                close Get_CI_Data;
                raise FND_API.G_EXC_ERROR;
        else
                close Get_CI_Data;
        end if;

        if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'After checking whether the CI_ID is valid or not.';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        /* If the control items is ISSUE, then it doesnot have the impact*/
        if l_ci_type_class_code = 'ISSUE' then
              PA_UTILS.add_Message( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_CI_INV_CI_ID');
              if l_debug_mode = 'Y' then
                     pa_debug.g_err_stage:= 'The given CI_ID is an ISSUE, does not contain any impact';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              end if;
              x_return_status := FND_API.G_RET_STS_ERROR;
               raise FND_API.G_EXC_ERROR ;
         end if;

      /*Checking whether given impact_type_code exists in the possible impacts types
       These possible impacts types are enabled during the creation of control type.*/
        open c_impact_types;
        fetch c_impact_types into l_ci_id;
        if c_impact_types%notfound then
                PA_UTILS.add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CI_IMPACT_CODE_INVALID');
                if l_debug_mode = 'Y' then
                       pa_debug.g_err_stage:= 'the ci_imapct_type_code is invalid, This is impact is not enabled for the control item type.';
                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                x_return_status := FND_API.G_RET_STS_ERROR;
                close c_impact_types;
                raise FND_API.G_EXC_ERROR ;
        else
                close c_impact_types;
        end if;

        if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'After checking the possible impact type codes for the given ci_id.';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        /*Check whether the impact exists are or not,if it already exists and the mode is 'INSERT'
         then it is an error and do the same for update for does not exist case*/
        open c_check_impact_exists;
        fetch c_check_impact_exists into c_check_impact_exists_rec ;
        if c_check_impact_exists%found then
               l_ci_impact_id            := c_check_impact_exists_rec.ci_impact_id;
               l_impact_description1     := c_check_impact_exists_rec.description;
               if p_mode = 'INSERT' then
                       PA_UTILS.add_Message( p_app_short_name => 'PA'
                                             ,p_msg_name       => 'PA_CI_IMPACT_EXIST');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       if l_debug_mode = 'Y' then
                              pa_debug.g_err_stage:= 'Cannot be inserted as the record already exists for the given impact type code';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       end if;
                       close c_check_impact_exists;
                       raise FND_API.G_EXC_ERROR;
               else
                       close c_check_impact_exists;
               end if;
        else
               if p_mode = 'UPDATE' then
                       PA_UTILS.add_Message( p_app_short_name => 'PA'
                                            ,p_msg_name       => 'PA_NO_CI_IMPACT');
                       x_return_status := FND_API.G_RET_STS_ERROR;
                       if l_debug_mode = 'Y' then
                              pa_debug.g_err_stage:= 'Cannot update the impact, as there is no record exists';
                              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                       end if;
                       close c_check_impact_exists;
                       raise FND_API.G_EXC_ERROR;
               else
                       close c_check_impact_exists;
               end if;
        end if; --end for if c_check_impact_exists


       if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'Security Checking starts.....';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       end if;

         /*Security check for the CI_ID UpdateAccess*/
       if 'T' <> Pa_ci_security_pkg.check_update_access (p_ci_id) then
             PA_UTILS.add_Message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_CI_NO_UPDATE_ACCESS');
             x_return_status := FND_API.G_RET_STS_ERROR;
             if l_debug_mode = 'Y' then
                    pa_debug.g_err_stage:= 'the CI_ID does not have the update access';
                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
              raise FND_API.G_EXC_ERROR ;
       end if;
       if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'After call to pa_ci_security_pkg.check_update_acces';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       end if;


        /*Check for the impact security -- coded as in the UI  impact_icon is enabled and disabled based on ControlitemListVO query */
        if ('EDIT'<> pa_ci_impacts_util.get_update_impact_mode(l_ci_id, l_cr_status_code)) then
                PA_UTILS.add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CI_NO_IMPACT_UPDATE_ACCESS');
               x_return_status := FND_API.G_RET_STS_ERROR;
               if l_debug_mode = 'Y' then
                      pa_debug.g_err_stage:= 'the CI_ID does not have the update Impact access';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
               end if;
                raise FND_API.G_EXC_ERROR ;
        end if;

        if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'After call to pa_ci_impacts_util.get_update_impact_mode, to check for the update access';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;


     /*The control item will not be updatable if the current status has approval workflow attached. */
        OPEN Check_Workflow_On_CI(p_ci_id);
        FETCH Check_Workflow_On_CI INTO l_ci_id;
        if Check_Workflow_On_CI%found then
        --IF (l_enable_wf_flag = 'Y' AND l_wf_success_status_code IS NOT NULL AND l_wf_failure_status_code IS NOT NULL) THEN
                PA_UTILS.ADD_MESSAGE(p_app_short_name =>'PA'
                                    ,p_msg_name       =>'PA_CI_APPROVAL_WORKFLOW');
                if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'Approval workflow is attached';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                close Check_Workflow_On_CI;
                raise FND_API.G_EXC_ERROR ;
        else
                 close Check_Workflow_On_CI;
        end if;

        if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'After checking for Approval Workflow security check';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        /* Check for the status control: check whether the action CONTROL_ITEM_ALLOW_UPDATE
        is allowed on the current status of the issue. */
       has_access   :=  pa_control_items_utils.CheckCIActionAllowed('CONTROL_ITEM', l_cr_status_code, 'CONTROL_ITEM_ALLOW_UPDATE',p_ci_id);
       if has_access <> 'Y' then
              PA_UTILS.add_Message( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_CI_NO_ALLOW_UPDATE');
              x_return_status := FND_API.G_RET_STS_ERROR;
              if l_debug_mode = 'Y' then
                     pa_debug.g_err_stage:= 'the CI_ID does not have the update access for the current status';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
              end if;
               raise FND_API.G_EXC_ERROR ;
       end if;
       if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'After checking for CONTROL_ITEM_ALLOW_UPDATE for the current status';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
       end if;


        l_status_code := 'CI_IMPACT_PENDING'; --always be pending as we are not implementing the impact.

        if l_debug_mode = 'Y' then
             pa_debug.g_err_stage:= 'Calling the '||p_mode||' API for impacts';
             pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        if p_mode = 'INSERT' and x_return_status = FND_API.G_RET_STS_SUCCESS then

                /*Validating the p_impact_description with the PA_INTERFACE_UTILS_PUB.G_PA_MISS_XXX */
                if p_impact_description = G_PA_MISS_CHAR or p_impact_description is null then
                        l_impact_description := null;
                elsif p_impact_description <> G_PA_MISS_CHAR and p_impact_description is not null then
                        l_impact_description := p_impact_description;
                end if;

                 /*Directly calling the private method in PA_CI_IMPACTS_PVT*/
                PA_CI_IMPACTS_pvt.create_ci_impact(
                     p_api_version             => p_api_version_number,
                     p_init_msg_list           => FND_API.G_FALSE,
                     p_commit                  => p_commit,
                     p_validate_only           => 'F',
                     p_max_msg_count           => NULL,
                     p_ci_id                   => p_ci_id,
                     p_impact_type_code        => p_impact_type_code,
                     p_status_code             => l_status_code,
                     p_description             => l_impact_description,
                     p_implementation_date     => NULL,
                     p_implemented_by          => NULL,
                     p_implementation_comment  => NULL,
                     p_impacted_task_id        => NULL,
                     x_ci_impact_id            => x_ci_impact_id,
                     x_return_status           => x_return_status,
                     x_msg_count               => x_msg_count,
                     x_msg_data                => x_msg_data
                      );

        elsif p_mode = 'UPDATE' and x_return_status = FND_API.G_RET_STS_SUCCESS then

                /*Validating the imapct description*/
                if p_impact_description = G_PA_MISS_CHAR then
                        l_impact_description := l_impact_description1;
                else
                        l_impact_description := p_impact_description;
                end if;


                /*calling directly the PVT method in PA_CI_IMPACTS_pvt*/
                        PA_CI_IMPACTS_pvt.update_ci_impact(
                                p_api_version             => p_api_version_number,
                                p_init_msg_list           => FND_API.G_FALSE,
                                p_commit                  => p_commit,
                                p_validate_only           => 'F',
                                p_max_msg_count           => null,
                                p_ci_impact_id            => l_ci_impact_id,
                                p_ci_id                   => p_ci_id,
                                p_impact_type_code        => p_impact_type_code,
                                p_status_code             => l_status_code,
                                p_description             => l_impact_description,
                                p_implementation_date     => null,
                                p_implemented_by          => null,
                                p_impby_name              => null,
                                p_impby_type_id           => null,
                                p_implementation_comment  => null,
                                p_record_version_number   => null,
                                p_impacted_task_id        => null,
                                x_return_status           => x_return_status,
                                x_msg_count               => x_msg_count,
                                x_msg_data                => x_msg_data
                              );
                        x_ci_impact_id := 0;  --setting the ci_impact_id = 0 in update impact.
        end if; /*enf for if l_mode*/

        if x_return_status <> FND_API.G_RET_STS_SUCCESS then
                raise FND_API.G_EXC_ERROR;
        end if;

 --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

exception

when FND_API.G_EXC_ERROR then
         x_ci_impact_id := null;
         x_return_status := FND_API.G_RET_STS_ERROR;
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
 --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;


         --raise the exception
         raise;

when others then
         x_ci_impact_id := null;
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PVT',
                                   p_procedure_name  => 'update_impacts',
                                   p_error_text      => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
	 --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

         --raise the exception
         raise;

END update_impacts;




/*This Procedure will be called from PA_CONTROL_API_PUB.add_supplier_impact procedure
to insert the details of the supplier
You can also call this procedure independently by passing necessary info.
*/

Procedure add_supplier_details (
         p_ci_id                IN         NUMBER   := G_PA_MISS_NUM,
         p_ci_impact_id         IN         NUMBER ,
         p_supplier_det_tbl     IN         PA_CONTROL_API_PUB.SUPP_DET_TBL_TYPE,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        )

IS

-- declaring local variables
 l_vendor_id             po_vendors.vendor_id%TYPE;
 l_supplier_name         po_vendors.vendor_name%TYPE;
 l_po_number             po_headers_all.segment1%TYPE;
 l_header_id             po_headers_all.po_header_id%TYPE;
 l_line_id               po_lines_all.po_line_id%TYPE;
 l_line_num              po_lines_all.line_num%TYPE;
 l_currency_code         fnd_currencies_vl.currency_code%type;
 l_currency_code1        fnd_currencies_vl.currency_code%type;
 l_currency_name         fnd_currencies_vl.Name%TYPE;
 l_project_id            pa_control_items.project_id%TYPE;
 l_ci_type_id            pa_control_items.ci_type_id%type;
 l_change_description    pa_ci_supplier_details.change_description%type;
 l_ci_impact_id          pa_ci_impacts.ci_impact_id%type := NULL;
 l_calling_mode          VARCHAR2(30);
 l_po_line_Amount        NUMBER ;
 l_ou_name               VARCHAR2(30);
 x_rowid                 ROWID;
 x_ci_transaction_id     NUMBER(15);
 l_error_msg_code        varchar2(100);
  l_org_id                po_headers_all.org_id%TYPE       := null;
 l_data                    VARCHAR2(2000);
 l_msg_data                VARCHAR2(2000);
 l_msg_index_out           NUMBER;
 l_module_name             VARCHAR2(200) := 'PA_CONTROL_API_PVT.add_supplier_details';
 l_msg_count               NUMBER := 0;
 l_record_status           VARCHAR2(20) := 'NEW';



--query for ref cursor. The where clause will be added depending upon the change_type.
l_check_vendor_query VARCHAR2(2000);

Type cur_vendor_id   IS REF CURSOR;
c_cur_vendor_id    cur_vendor_id;


/*Cursor to check the po_number is valid or not*/
cursor c_check_po_number(c_po_number VARCHAR2, c_project_id NUMBER, c_org_id number) is
       select distinct po.segment1 PoNumber
       ,po.po_header_id PoHeaderId
       ,po.vendor_id    PoVendorId
       ,v.vendor_name   PoSupplierName
       ,po.currency_code PoCurrency
       ,po.org_id       Poorgid
       ,substr(pa_expenditures_utils.getorgtlname(po.org_id),1,30) PoOuname
       ,pod.project_id  PoProjectId
        From po_headers_all  po
       ,po_vendors v
       ,po_distributions_all pod
        Where po.vendor_id = v.vendor_id
        and NVL(po.closed_code,'XX') NOT IN ('FINALLY CLOSED','CLOSED')
        and pod.po_header_id = po.po_header_id
        and   (( po.org_id = c_org_id and c_org_id is NOT NULL ) or c_org_id is NULL )
        and pod.project_id = c_project_id
        and po.segment1 = c_po_number;


/*Cursor to check the po_header_id is valid or not*/
cursor c_check_po_header_id(c_po_header_id VARCHAR2, c_project_id NUMBER,c_org_id number) is
       select distinct po.segment1 PoNumber
       ,po.po_header_id PoHeaderId
       ,po.vendor_id    PoVendorId
       ,v.vendor_name   PoSupplierName
       ,po.currency_code PoCurrency
       ,po.org_id       Poorgid
       ,substr(pa_expenditures_utils.getorgtlname(po.org_id),1,30) PoOuname
       ,pod.project_id  PoProjectId
        From po_headers_all  po
       ,po_vendors v
       ,po_distributions_all pod
        Where po.vendor_id = v.vendor_id
        and NVL(po.closed_code,'XX') NOT IN ('FINALLY CLOSED','CLOSED')
        and pod.po_header_id = po.po_header_id
        and   (( po.org_id = c_org_id and c_org_id is NOT NULL ) or c_org_id is NULL )
        and pod.project_id = c_project_id
        and po.po_header_id = c_po_header_id;


/*cursor to check the po_line_number is valid or not*/
cursor c_check_Doc_number(c_po_number VARCHAR2,c_po_line_num NUMBER, c_project_id NUMBER)
is
       select pol.po_line_id PoLineId
      ,pol.line_num PoLineNum
      ,(pol.quantity * pol.unit_price) PolineAmount
      ,poh.po_header_id  Poheaderid
      ,poh.segment1   Ponumber
      ,pod.project_id  Projectid
      ,substr(pa_expenditures_utils.getorgtlname(pod.org_id),1,30) Ouname
      ,pod.po_distribution_id Podistid
      From  po_lines_all pol
     ,po_headers_all poh
     ,po_distributions_all pod
      Where poh.po_header_id = pol.po_header_id
      and pod.po_header_id = pol.po_header_id
      and pod.po_line_id = pol.po_line_id
      and NVL(poh.closed_code,'XX') NOT IN ('FINALLY CLOSED','CLOSED')
      and pod.project_id = c_project_id
      and poh.segment1 = c_po_number    --ponumber is passed
      and pol.line_num = c_po_line_num;

/*cursor to check the po_line_id  is valid or not*/
cursor c_check_po_line_id(c_po_number VARCHAR2,c_po_line_id NUMBER, c_project_id NUMBER)
is
       select pol.po_line_id PoLineId
      ,pol.line_num PoLineNum
      ,(pol.quantity * pol.unit_price) PolineAmount
      ,poh.po_header_id  Poheaderid
      ,poh.segment1   Ponumber
      ,pod.project_id  Projectid
      ,substr(pa_expenditures_utils.getorgtlname(pod.org_id),1,30) Ouname
      ,pod.po_distribution_id Podistid
      From  po_lines_all pol
     ,po_headers_all poh
     ,po_distributions_all pod
      Where poh.po_header_id = pol.po_header_id
      and pod.po_header_id = pol.po_header_id
      and pod.po_line_id = pol.po_line_id
      and NVL(poh.closed_code,'XX') NOT IN ('FINALLY CLOSED','CLOSED')
      and pod.project_id = c_project_id
      and poh.segment1 = c_po_number    --ponumber is passed
      and pol.po_line_id = c_po_line_id;



/*cursor to check the validity of currency_code*/
cursor c_check_currency_code(c_currency varchar2) is
     select currency_code CurrencyCode
    ,Name  CurrencyName
     from fnd_currencies_vl
     where enabled_flag = 'Y'
     and trunc(sysdate) between nvl(start_date_active,trunc(sysdate))
     and nvl(end_date_active,trunc(sysdate))
     and currency_code = c_currency;

/*cursor to fetch the ci_type_id and project_id data*/
 cursor c_get_project_id(c_ci_id number)
        is
        select  pci.project_id
        from
        pa_control_items pci
        where pci.ci_id = c_ci_id;


/*Cursor to check ci_id validity*/
/*cursor c_get_ci_type_id is
     select ci_type_id from pa_control_items a , pa_ci_impacts b
     where a.ci_id = b.ci_id
     and a.ci_id = p_ci_id
     and b.IMPACT_TYPE_CODE = 'SUPPLIER';*/

--Declaring record types for both cursors c_check_po_number and c_check_Doc_number.
c_check_po_number_rec     c_check_po_number%ROWTYPE;
c_check_Doc_number_rec    c_check_Doc_number%ROWTYPE;
c_check_po_line_id_rec    c_check_po_line_id%ROWTYPE;
c_check_po_header_id_rec  c_check_po_header_id%ROWTYPE;

/*parameter variable declaraion */

p_change_type        pa_ci_supplier_details.change_type%type;
p_change_description pa_ci_supplier_details.change_description%type ;
p_vendor_id          NUMBER;
p_po_header_id       NUMBER;
p_po_number          varchar2(40);
p_po_line_id         number;
p_po_line_num        number;
p_currency           pa_ci_supplier_details.CURRENCY_CODE%type;
p_change_amount      number;



BEGIN

           -- initialize the return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

	l_debug_mode  :=NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE',fnd_global.user_id,fnd_global.resp_id, 275, null, null), 'N');
        if l_debug_mode = 'Y' then
                  pa_debug.set_curr_function(p_function=>l_module_name,p_debug_mode => l_debug_mode);
        end if;


        if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= ' Starting the PA_CONTROL_API_PVT.add_supplier_details ';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        l_org_id := FND_GLOBAL.org_id;

for i in p_supplier_det_tbl.FIRST .. p_supplier_det_tbl.LAST loop

                /*get the details of supplier from table type p_supplier_det_tbl*/
                p_change_type        :=  p_supplier_det_tbl(i).change_type;
                p_change_description :=  p_supplier_det_tbl(i).change_description;
                p_vendor_id          :=  p_supplier_det_tbl(i).vendor_id;
                p_po_header_id       :=  p_supplier_det_tbl(i).po_header_id;
                p_po_number          :=  p_supplier_det_tbl(i).po_number;
                p_po_line_id         :=  p_supplier_det_tbl(i).po_line_id;
                p_po_line_num        :=  p_supplier_det_tbl(i).po_line_num;
                p_currency           :=  p_supplier_det_tbl(i).currency;
                p_change_amount      :=  p_supplier_det_tbl(i).change_amount;

                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'In Loop Record number '|| i ||' Values are :';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        pa_debug.g_err_stage:= 'p_change_type['||i||']='||p_change_type||
                                               'p_change_description['||i||']='||p_change_description||
                                               'p_vendor_id['||i||']='||p_vendor_id||
                                               'p_po_header_id['||i||']='||p_po_header_id||
                                               'p_po_number['||i||']='||p_po_number||
                                               'p_po_line_id['||i||']='||p_po_line_id||
                                               'p_po_line_num['||i||']='||p_po_line_num||
                                               'p_currency['||i||']='||p_currency||
                                               'p_change_amount['||i||']='||p_change_amount;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;

                /*assigning local variables to default value null*/
                l_vendor_id         :=null;
                l_supplier_name     :=null;
                l_po_number         :=null;
                l_header_id         :=null;
                l_line_id           :=null;
                l_line_num          :=null;
                l_currency_code     :=null;
                l_currency_code1    :=null;
                l_currency_name     :=null;
                l_project_id        :=null;
                l_ci_type_id        :=null;
                l_change_description :=null;
                l_calling_mode       := 'VALIDATEANDINSERT';
                l_po_line_Amount      :=null;
                l_ou_name            :=null;
                x_rowid              :=null;
                x_ci_transaction_id  :=null;
                l_error_msg_code     := null;
                l_check_vendor_query := 'select v.vendor_id SupplierId ,v.vendor_name  SupplierName From po_vendors v ';

        /*Check the ci_id and P_CHANGE_TYPE (should be either CREATE or UPDATE) are valid or not*/
        if  p_ci_id is null or p_ci_id = G_PA_MISS_NUM
            or p_change_type is null or p_change_type = G_PA_MISS_CHAR  then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_ID_CHANGE_TYPE_NULL',
                                      p_token1          => 'NUMBER',
                                      p_value1          =>  i);
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= ' The ci_id is null or Change Type is null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 x_return_status := FND_API.G_RET_STS_ERROR;
        elsif p_change_type is not null and (p_change_type <> 'CREATE' and p_change_type <> 'UPDATE') then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CHANGE_TYPE_INVALID',
                                      p_token1          => 'NUMBER',
                                      p_value1          =>  i);
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= ':The  Change Type is invalid';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 x_return_status := FND_API.G_RET_STS_ERROR;
        end if; --end for if  p_ci_id is null or p_change_type is null

        /*Checking if the change type is CREATE then po details should be null */
        If p_change_type is NOT NULL and p_change_type = 'CREATE'
          and (  (p_po_number is NOT NULL and p_po_number <>G_PA_MISS_CHAR)
                 or (p_po_header_id is NOT NULL and p_po_header_id <>G_PA_MISS_NUM)
                 or (p_po_line_num is not null and p_po_line_num <> G_PA_MISS_NUM)
                 or (p_po_line_id  is not null and p_po_line_id <> G_PA_MISS_NUM) )
        then
                   PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CHANGE_TYPE_INVALID',
                                      p_token1          => 'NUMBER',
                                      p_value1          =>  i);
                    if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'Invalid Change Type (CREATE)- po number should be null';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    end if;
                    x_return_status := FND_API.G_RET_STS_ERROR;
        /*if change_type is UPDATE then user must pass PO details*/
        elsif   p_change_type is NOT NULL and p_change_type = 'UPDATE'
        and (  (p_po_number is  NULL or p_po_number = G_PA_MISS_CHAR)
                 and (p_po_header_id is  NULL or p_po_header_id = G_PA_MISS_NUM)
                 and (p_po_line_num is  null or p_po_line_num = G_PA_MISS_NUM)
                 and (p_po_line_id  is  null or p_po_line_id = G_PA_MISS_NUM) )
        then
                   PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CHANGE_TYPE_INVALID',
                                      p_token1          => 'NUMBER',
                                      p_value1          =>  i);
                    if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'Invalid Change Type (CREATE)- po number should be null';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                    end if;
                    x_return_status := FND_API.G_RET_STS_ERROR;
        end if;

        if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'After validating the Change Type and ci_id.'||
                                                'Change Type is :'||p_change_type|| ' ; Ci_id is :'||p_ci_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        /*get the ci_type_id and project_id, this should not raise an exception becoz ci_id is already validated in public method.*/
        if p_ci_id is not null and p_ci_id <> G_PA_MISS_NUM then
                open c_get_project_id(p_ci_id);
                fetch c_get_project_id into l_project_id;
                if c_get_project_id%notfound then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_INVALID_CI_ID',
                                      p_token1          => 'NUMBER',
                                      p_value1          =>  i);
                         if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'Invalid Control Item id.' ;
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                         end if;
                            x_return_status := FND_API.G_RET_STS_ERROR;
                end if;
                close c_get_project_id;
        end if;

         if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'The project id is :'||l_project_id;
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;



        /*if vendor id is not null then check whether it is  valid or not,
        depending  on the change_type, execute the cursor query*/
        if  p_vendor_id is not null and p_vendor_id <> G_PA_MISS_NUM then
                if p_change_type = 'UPDATE' then
                        l_check_vendor_query := l_check_vendor_query || ' where EXISTS (select * from po_distributions_all pod ,po_headers_all poh where pod.po_header_id = poh.po_header_id and  pod.project_id = '||
                                                  l_project_id ||' and poh.vendor_id = v.vendor_id and  v.vendor_id = '''||p_vendor_id ||''') ';
                else
                        l_check_vendor_query := l_check_vendor_query ||
                                                  ' where v.vendor_id = '''||p_vendor_id ||'''';
                end if;

                if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= 'The l_check_vendor_query is ['||p_change_type||'] : '||l_check_vendor_query;
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;

                open c_cur_vendor_id for l_check_vendor_query;
                fetch c_cur_vendor_id into l_vendor_id , l_supplier_name;
                if c_cur_vendor_id%notfound then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_VENDOR_ID_INVALID',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'Invalid Vedor ID';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_cur_vendor_id;

                else
                        close c_cur_vendor_id;
                end if;
        elsif  (p_vendor_id is null or p_vendor_id = G_PA_MISS_NUM )-- end for  if  p_vendor_id
                and p_change_type = 'CREATE' then
                /*for create change type vendor id should not be null
                But where as in UPDATE we can derive the vendor id from the given header id or po_line id details */
                PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_VENDOR_ID_NULL',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'Vedor ID is null';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;


        /* check for the po_number valid or not
           if po_number is null and po_line_number is not null then raise exception
           bcoz po_line_num is dependent on po_number*/
        if p_po_header_id is not null and  p_po_header_id <> G_PA_MISS_NUM then
                open c_check_po_header_id(p_po_header_id,l_project_id,l_org_id);
                fetch c_check_po_header_id into c_check_po_header_id_rec;
                if c_check_po_header_id%notfound then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_PO_HEADER_ID_INVALID',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'The header id is not valid';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_check_po_header_id;

                else
                        l_po_number     := c_check_po_header_id_rec.PoNumber;
                        l_supplier_name := c_check_po_header_id_rec.PoSupplierName;
                        l_vendor_id     := c_check_po_header_id_rec.PoVendorId;
                        l_currency_code := c_check_po_header_id_rec.PoCurrency;
                        l_header_id     := p_po_header_id;
                        if l_debug_mode = 'Y' then
                                pa_debug.g_err_stage:= 'The values after validating p_po_header_id are'||
                                                        'l_po_number['||l_po_number||'],l_supplier_name['||l_supplier_name||'],l_vendor_id['||
                                                        l_vendor_id||'],l_currency_code['||l_currency_code||']';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        close c_check_po_header_id;
                        if p_vendor_id is not null and p_vendor_id <> G_PA_MISS_NUM then
                                if l_vendor_id <> p_vendor_id then
                                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                             p_msg_name        => 'PA_VENDOR_ID_INVALID',
                                                             p_token1          => 'NUMBER',
                                                             p_value1          =>  i);
                                        if l_debug_mode = 'Y' then
                                                pa_debug.g_err_stage:= 'The Vendor id is not valid';
                                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                        end if;
                                        x_return_status := FND_API.G_RET_STS_ERROR;
                                end if;
                        end if;
                end if;

        elsif p_po_number is not null and p_po_number <> G_PA_MISS_CHAR then
                        open c_check_po_number(p_po_number,l_project_id,l_org_id);
                        fetch c_check_po_number into c_check_po_number_rec;
                        if c_check_po_number%notfound then
                                PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                     p_msg_name        => 'PA_PO_NUMBER_INVALID',
                                                     p_token1          => 'NUMBER',
                                                     p_value1          =>  i);
                                if l_debug_mode = 'Y' then
                                        pa_debug.g_err_stage:= 'The po_number is not valid';
                                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                end if;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                close c_check_po_number;

                        else
                                l_po_number     := c_check_po_number_rec.PoNumber;
                                l_supplier_name := c_check_po_number_rec.PoSupplierName;
                                l_vendor_id     := c_check_po_number_rec.PoVendorId;
                                l_currency_code := c_check_po_number_rec.PoCurrency;
                                l_header_id     := c_check_po_number_rec.PoHeaderId;
                                if l_debug_mode = 'Y' then
                                        pa_debug.g_err_stage:= 'The values after validating p_po_number are'||
                                                        'l_po_number['||l_po_number||'],l_supplier_name['||l_supplier_name||'],l_vendor_id['||
                                                        l_vendor_id||'],l_currency_code['||l_currency_code||']';
                                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                end if;
                                close c_check_po_number;
                                if p_vendor_id is not null then
                                        if l_vendor_id <> p_vendor_id then
                                                PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                                     p_msg_name        => 'PA_VENDOR_ID_INVALID',
                                                                     p_token1          => 'NUMBER',
                                                                     p_value1          =>  i);
                                                if l_debug_mode = 'Y' then
                                                        pa_debug.g_err_stage:= 'The Vendor ID is not valid';
                                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                               end if;
                                                x_return_status := FND_API.G_RET_STS_ERROR;

                                        end if;
                                end if;
                        end if;
        else
                if (p_po_line_num is not null and p_po_line_num <> G_PA_MISS_NUM)
                    or (p_po_line_id is not null  and p_po_line_id <> G_PA_MISS_NUM) then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_HEAD_ID_PO_NUM_IS_NULL',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= 'The PO header id or Po Number is null';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;

                end if;

        end if;

        /* check for po_line_id validity execute the cursor only if the l_po_number is not null
           this value is been assigned from the cursors c_check_po_number or c_check_po_header_id.
           Becuase this cursor takes l_po_number as parameter.if Both parameters line id
           and line number then set the error flag*/
        if l_po_number is not null  and p_po_line_id is not null
            and  p_po_line_id <> G_PA_MISS_NUM then
                open c_check_po_line_id(l_po_number,p_po_line_id,l_project_id);
                fetch c_check_po_line_id into c_check_po_line_id_rec;
                if c_check_po_line_id%notfound then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_PO_LINE_ID_INVALID',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= 'Po Line id is invalid';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_check_po_line_id;

                else
                        l_line_num       := c_check_po_line_id_rec.PoLineNum;
                        l_po_number      := c_check_po_line_id_rec.Ponumber;
                        l_po_line_Amount := c_check_po_line_id_rec.PolineAmount;
                        l_line_id        := p_po_line_id;
                        close c_check_po_line_id;
                end if;
      elsif l_po_number is not null and p_po_line_num is not null and p_po_line_num<>G_PA_MISS_NUM then
                open c_check_Doc_number(l_po_number,p_po_line_num,l_project_id);
                fetch c_check_Doc_number into c_check_Doc_number_rec;
                if c_check_Doc_number%notfound then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_PO_LINE_NUMBER_INVALID',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= 'Po Line number is invalid';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_check_Doc_number;

                else
                        l_line_num       := c_check_Doc_number_rec.PoLineNum;
                        l_po_number      := c_check_Doc_number_rec.Ponumber;
                        l_po_line_Amount := c_check_Doc_number_rec.PolineAmount;
                        l_line_id        := c_check_Doc_number_rec.PoLineID;
                        close c_check_Doc_number;
                end if;
        elsif l_po_number is not null and
        ((p_po_line_num is  null or p_po_line_num = G_PA_MISS_NUM)
        or (p_po_line_id is  null  or  p_po_line_id = G_PA_MISS_NUM)) then
                 PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_PO_LINE_ID_LINE_NUM_NULL',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                 if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'Po Line number is invalid';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 x_return_status := FND_API.G_RET_STS_ERROR;
        end if;


        if l_debug_mode = 'Y' then
                pa_debug.g_err_stage:= 'Validated the po_line_id or doc number and the values are :'||
                                        'l_line_num['||l_line_num||'],l_po_number['||l_po_number||'],l_po_line_Amount['||
                                        l_po_line_Amount||']';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;



/* if the l_currency_code  already exists  then store it in other local variable*/
        if l_currency_code is not null then    --got it from c_check_po_number cursor.
               l_currency_code1 :=  l_currency_code;
        end if;

/* Check the currency code is valid or not*/
        if p_currency is not null and p_currency <> G_PA_MISS_CHAR then
                open c_check_currency_code(p_currency);
                fetch c_check_currency_code into l_currency_code, l_currency_name;
                if c_check_currency_code%found then
                        if l_currency_code1 is not null  and l_currency_code1 <> l_currency_code then
                                PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                     p_msg_name        => 'PA_CURRENCY_CODE_INVALID',
                                                     p_token1          => 'NUMBER',
                                                     p_value1          =>  i);
                                if l_debug_mode = 'Y' then
                                       pa_debug.g_err_stage:= 'Currency Code is invalid';
                                       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                                end if;
                                x_return_status := FND_API.G_RET_STS_ERROR;
                                close c_check_currency_code;

                        else
                                close c_check_currency_code;
                        end if;
                else
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                                     p_msg_name        => 'PA_CURRENCY_CODE_INVALID',
                                                     p_token1          => 'NUMBER',
                                                     p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                                    pa_debug.g_err_stage:= 'Currency Code is invalid';
                                    pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
                        close c_check_currency_code;
                end if;
        elsif (p_currency is null or p_currency = G_PA_MISS_CHAR)
                    and l_currency_code1 is null
                    and l_currency_code is null then
                        PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_CURRENCY_CODE_NULL',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= ' Currency Code is invalid';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        x_return_status := FND_API.G_RET_STS_ERROR;
        end if;


        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= ' Currency Code is Validated';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

        if (p_change_amount is null or p_change_amount = G_PA_MISS_NUM ) and l_po_line_Amount is null then
                PA_UTILS.ADD_MESSAGE(p_app_short_name  => 'PA',
                                     p_msg_name        => 'PA_SUPP_AMOUNT_NULL',
                                     p_token1          => 'NUMBER',
                                     p_value1          =>  i);
                if l_debug_mode = 'Y' then
                        pa_debug.g_err_stage:= 'Change amount cannot be null';
                        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                x_return_status := FND_API.G_RET_STS_ERROR;

        elsif p_change_amount is not null and p_change_amount <>  G_PA_MISS_NUM then
                l_po_line_Amount := p_change_amount;
        end if;

        /*setting the descrition value*/
        if p_change_description is null or p_change_description = G_PA_MISS_CHAR then
                l_change_description := null;
        else
                l_change_description := p_change_description;
        end if;


        if l_debug_mode = 'Y' then
                               pa_debug.g_err_stage:= 'Before calling the PA_CI_SUPPLIER_UTILS.validateSI to validate and insert';
                               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
      /*Call the procedure to  insert the details*/
      if x_return_status = FND_API.G_RET_STS_SUCCESS then
/*              PA_CI_SUPPLIER_UTILS.validateSI(
                        p_ROWID                     =>  x_rowid
                       ,p_RECORD_STATUS             =>  l_record_status
                       ,p_CI_ID                     =>  p_ci_id
                       ,p_CI_TYPE_ID                =>  l_ci_type_id
                       ,p_CI_IMPACT_ID              =>  p_ci_impact_id
                       ,P_CALLING_MODE              =>  l_calling_mode
                       ,P_ORG_ID                    =>  l_org_id
                       ,p_VENDOR_NAME               =>  l_supplier_name
                       ,p_PO_NUMBER                 =>  l_po_number
                       ,p_PO_LINE_NUM               =>  l_line_num
                       ,p_ADJUSTED_TRANSACTION_ID   =>  null
                       ,p_CURRENCY_CODE             =>  l_currency_code
                       ,p_CHANGE_AMOUNT             =>  l_po_line_Amount
                       ,p_CHANGE_TYPE               =>  p_change_type
                       ,p_CHANGE_DESCRIPTION        =>  l_change_description
                       ,p_CI_TRANSACTION_ID         =>  x_ci_transaction_id
                       ,x_return_status             =>  x_return_status
                       ,x_msg_data                  =>  x_msg_data
                       ,x_msg_count                 =>  x_msg_count
                       );*/
                       PA_CI_SUPPLIER_PKG.insert_row (
                                        x_rowid                   => x_rowid
                                        ,x_ci_transaction_id      => x_ci_transaction_id
                                        ,p_CI_TYPE_ID             => l_ci_type_id   --passed as null as from UI also this is getting stamped as null
                                        ,p_CI_ID                  => p_ci_id
                                        ,p_CI_IMPACT_ID           => l_ci_impact_id --p_ci_impact_id Passing null value as from UI also this is getting stamped as null
                                        ,p_VENDOR_ID              => l_vendor_id
                                        ,p_PO_HEADER_ID           => l_header_id
                                        ,p_PO_LINE_ID             => l_line_id
                                        ,p_ADJUSTED_TRANSACTION_ID => null        --passed as null as from UI
                                        ,p_CURRENCY_CODE           => l_currency_code
                                        ,p_CHANGE_AMOUNT           => l_po_line_Amount
                                        ,p_CHANGE_TYPE             => p_CHANGE_TYPE
                                        ,p_CHANGE_DESCRIPTION      => l_change_description
                                        ,p_CREATED_BY              => FND_GLOBAL.user_id
                                        ,p_CREATION_DATE           => trunc(sysdate)
                                        ,p_LAST_UPDATED_BY         => FND_GLOBAL.user_id
                                        ,p_LAST_UPDATE_DATE        => trunc(sysdate)
                                        ,p_LAST_UPDATE_LOGIN       => FND_GLOBAL.login_id
										,p_Task_Id                 => NULL
		                                ,p_Resource_List_Mem_Id    => NULL
		                                ,p_From_Date               => NULL
		                                ,p_To_Date                 => NULL
		                                ,p_Estimated_Cost          => NULL
		                                ,p_Quoted_Cost             => NULL
		                                ,p_Negotiated_Cost         => NULL
						                ,p_Burdened_cost           => NULL
						                ,p_revenue_override_rate   => NULL
                                        ,p_audit_history_number    => NULL
                                        ,p_current_audit_flag      => 'Y'
                                        ,p_Original_supp_trans_id  => NULL
                                        ,p_Source_supp_trans_id    => NULL
                                        ,p_ci_status               => null
                                        ,x_return_status           => x_return_status
                                        ,x_error_msg_code          => l_error_msg_code  );

        ELSIF l_error_msg_code is not null then
                raise FND_API.G_EXC_ERROR;   --error while inserting the records raise
        end if;
 END LOOP;
            if x_return_status <> FND_API.G_RET_STS_SUCCESS or l_error_msg_code is not null then
                raise FND_API.G_EXC_ERROR;
            end if;
         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

Exception

when FND_API.G_EXC_ERROR then
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_msg_count := fnd_msg_pub.count_msg;
         x_rowid := null;                   --assign to the initial value
         x_ci_transaction_id := null;       --assign to the initial value
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
               pa_debug.reset_curr_function;
         end if;

        raise;

when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         x_rowid := null;                   --assign to the initial value
         x_ci_transaction_id := null;       --assign to the initial value
         fnd_msg_pub.add_exc_msg ( p_pkg_name        => 'PA_CONTROL_API_PVT',
                                   p_procedure_name  => 'update_impacts',
                                   p_error_text      => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
	 --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;

        raise;

End add_supplier_details;




PROCEDURE check_create_ci_allowed
(
p_project_id                                    IN OUT NOCOPY NUMBER,
p_project_name                                  IN VARCHAR2 := null,
p_project_number                                IN VARCHAR2 := null,
p_ci_type_class_code                            IN VARCHAR2 := null,
p_ci_type_id                                    IN OUT NOCOPY NUMBER,
x_ci_type_class_code                            OUT NOCOPY VARCHAR2,
x_auto_number_flag                              OUT NOCOPY VARCHAR2,
x_source_attrs_enabled_flag                     OUT NOCOPY VARCHAR2,
x_return_status                                 OUT NOCOPY VARCHAR2,
x_msg_count                                     OUT NOCOPY NUMBER,
x_msg_data                                      OUT NOCOPY VARCHAR2
)
is

  cursor get_project_id_frm_num(p_project_number VARCHAR2) is
  select project_id
  from pa_projects_all
  where segment1 = p_project_number;

  cursor get_project_id_frm_name(p_project_name VARCHAR2) is
  select project_id
  from pa_projects_all
  where name = p_project_name;

  cursor validate_prj_id(p_project_id NUMBER) is
  select project_id
  from pa_projects_all
  where project_id = p_project_id;

  cursor get_ci_type_attrs(p_ci_type_id NUMBER) is
  select ci_type_class_code,
         auto_number_flag,
         source_attrs_enabled_flag
  from pa_ci_types_b
  where ci_type_id = p_ci_type_id;

  /*pa_ci_security_pkg.check_create_ci will check if the current project type and role played by user are allowed
    to create the control item of this type. Also it will check for project authority.*/
  cursor check_create_ci_priv(p_ci_type_id NUMBER, p_project_id NUMBER) is
  select 'Y'
  from pa_ci_types_vl
  where ci_type_id = p_ci_type_id
  and pa_ci_security_pkg.check_create_ci(p_ci_type_id, p_project_id)='T'
  and trunc(sysdate) between start_date_active and nvl(end_date_active, sysdate);


  l_ci_type_attrs_rec                      get_ci_type_attrs%rowtype;
  l_ci_type_class_code                     pa_ci_types_b.ci_type_class_code%type;
  l_auto_number_flag                       pa_ci_types_b.auto_number_flag%type;
  l_source_attrs_enabled_flag              pa_ci_types_b.source_attrs_enabled_flag%type;


  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_check_create_ci                        VARCHAR2(1);
  l_project_id                             pa_projects_all.project_id%type;
  l_ini_proj_id                            pa_projects_all.project_id%type;
  l_ini_ci_type_id                         pa_ci_types_b.ci_type_id%type;
  l_any_err_occured_flg                    VARCHAR2(1);

begin
  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'check_create_ci_allowed' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pvt.check_create_ci_allowed', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of check_create_ci_allowed', l_debug_level3);
  end if;

--Store the initial values of the in out parameteres so that these can be restored back if some exception occurs.
  l_ini_proj_id := p_project_id;
  l_ini_ci_type_id := p_ci_type_id;

  --setting the err occured flag to N initially.
  l_any_err_occured_flg := 'N';

  if (p_ci_type_id is null) then
      PA_UTILS.ADD_MESSAGE
                        (p_app_short_name  => 'PA',
                         p_msg_name        => 'PA_CI_TYPE_ID_MISSING');
      if l_debug_mode = 'Y' then
         pa_debug.g_err_stage:= 'ci_type_id is null';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      end if;
      l_any_err_occured_flg := 'Y';
  end if;

  if(p_project_id is null and p_project_number is null and p_project_name is null) then
      PA_UTILS.ADD_MESSAGE
                        (p_app_short_name  => 'PA',
                         p_msg_name        => 'PA_CI_PROJECT_MISSING');
      if l_debug_mode = 'Y' then
         pa_debug.g_err_stage:= 'project id, project number, project name, all three cannot be null';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      end if;
      l_any_err_occured_flg := 'Y';
  end if;

  if(p_ci_type_id is not null) then
     /* the passed p_ci_type_id gets validated and we derive the ci_type_attributes for the ci_type_id passed*/
     open get_ci_type_attrs(p_ci_type_id);
     fetch get_ci_type_attrs into l_ci_type_attrs_rec;
     if get_ci_type_attrs%NOTFOUND then
         PA_UTILS.ADD_MESSAGE
                           (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_CI_INVALID_TYPE_ID');  --existing msg.
         if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'Invalid ci_type_id passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         close get_ci_type_attrs;
         l_any_err_occured_flg := 'Y';
     else
         x_ci_type_class_code         := l_ci_type_attrs_rec.ci_type_class_code;
         x_auto_number_flag           := l_ci_type_attrs_rec.auto_number_flag;
         x_source_attrs_enabled_flag  := l_ci_type_attrs_rec.source_attrs_enabled_flag;
         close get_ci_type_attrs;
         /*now validate the class type code. validate that create_issue api can be used to create issues only and not
           change request or change order. And similarly create_change_request, create_change_order are used for their
           respective types*/
          if(p_ci_type_class_code <> l_ci_type_attrs_rec.ci_type_class_code) then
                  PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name  => 'PA',
                                    p_msg_name        => 'PA_CI_INV_API_USE');  --existing msg.
                  if l_debug_mode = 'Y' then
                     pa_debug.g_err_stage:= 'wrong usage of the api for the control item type';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                  end if;
                  l_any_err_occured_flg := 'Y';
          end if;--if(p_ci_type_class_code <> l_ci_type_attrs_rec.ci_type_class_code) then
     end if;
  end if;

  /* Need to write the code to get the ci_type_id from the ci_type and pass back this ci_type_id*/
  /*Need to check a test case in the UI also*/
  if(p_project_id is not null) then
     /*a value has been passed for project id, we will validate this value*/
     open validate_prj_id(p_project_id);
     fetch validate_prj_id into l_project_id;
     if validate_prj_id%NOTFOUND then
         PA_UTILS.ADD_MESSAGE
                           (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_CI_NO_PROJECT_ID');  --exisitng message
         if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'Invalid project id passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         close validate_prj_id;
         l_any_err_occured_flg := 'Y';
     else
         p_project_id := l_project_id;
         close validate_prj_id;
     end if;
  elsif(p_project_id is null and p_project_number is not null) then
     /*Derive the project id from project number*/
     open get_project_id_frm_num(p_project_number);
     fetch get_project_id_frm_num into l_project_id;
     if get_project_id_frm_num%NOTFOUND then
         PA_UTILS.ADD_MESSAGE
                           (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_CI_INV_PROJ_NUM');
         if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'Invalid project number passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         close get_project_id_frm_num;
         l_any_err_occured_flg := 'Y';
     else
         p_project_id := l_project_id;
         close get_project_id_frm_num;
     end if;
  elsif(p_project_id is null and p_project_number is null and p_project_name is not null) then
    /*Derive the project id from project name*/
     open get_project_id_frm_name(p_project_name);
     fetch get_project_id_frm_name into l_project_id;
     if get_project_id_frm_name%NOTFOUND then
         PA_UTILS.ADD_MESSAGE
                           (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_CI_INV_PROJ_NAME');
         if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'Invalid project name passed';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         close get_project_id_frm_name;
         l_any_err_occured_flg := 'Y';
     else
         p_project_id := l_project_id;
         close get_project_id_frm_name;
     end if;
  end if;--(p_project_id is not null) then

  /*at this place in code both project id and ci type id would be valid*/
  /* check if the project type ,role for the current logged in user, project authority can create the
     control item for this control item type*/
  /* Added "and l_any_err_occured_flg <> 'Y'" in the if condition, so tht security check is only enforced if there were no errors
     before this point. Without this check Even if invalid project id or invalid ci type id would have been passed, then  security check
     would have got applied for invalid project/citype id
  */
  if(p_project_id is not null and p_ci_type_id is not null and l_any_err_occured_flg <> 'Y') then
     open check_create_ci_priv(p_ci_type_id, p_project_id);
     fetch check_create_ci_priv into l_check_create_ci;
     if check_create_ci_priv%NOTFOUND then
         PA_UTILS.ADD_MESSAGE
                           (p_app_short_name  => 'PA',
                            p_msg_name        => 'PA_CI_NO_SECURITY');
         if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'Either the project type or role selected by you doesnt have privilge to create the control item';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         close check_create_ci_priv;
         l_any_err_occured_flg := 'Y';
     else
         close check_create_ci_priv;
     end if;
  end if;

  if( l_any_err_occured_flg = 'Y' ) then
     raise fnd_api.g_exc_error;
  end if;

  if l_debug_mode = 'Y' then
        pa_debug.reset_curr_function;
  end if;

exception
  when fnd_api.g_exc_error then
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

         /*Initialize the out variables back to null*/
         x_ci_type_class_code         := null;
         x_auto_number_flag           := null;
         x_source_attrs_enabled_flag  := null;
         --in out parameters are set to their initial values.
         p_project_id := l_ini_proj_id;
         p_ci_type_id := l_ini_ci_type_id;
         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;
         --raise the exception
         raise;
  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'check_create_ci_allowed',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
         /*Initialize the out variables back to null*/
         x_ci_type_class_code         := null;
         x_auto_number_flag           := null;
         x_source_attrs_enabled_flag  := null;
         --in out parameters are set to their initial values.
         p_project_id := l_ini_proj_id;
         p_ci_type_id := l_ini_ci_type_id;
         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;
         --raise the exception
         raise;
end check_create_ci_allowed;


/*this procedure will validate the parameters and if all the paramters are valid will call the api's to
  create the control item*/
PROCEDURE validate_param_and_create(
                                    p_orig_system_code              IN VARCHAR2
                                   ,p_orig_system_reference         IN VARCHAR2
                                   ,p_project_id                    IN NUMBER := null
                                   ,p_ci_type_id                    IN NUMBER := null
                                   ,p_auto_number_flag              IN VARCHAR2 := null
                                   ,p_source_attrs_enabled_flag     IN VARCHAR2 := null
                                   ,p_ci_type_class_code            IN VARCHAR2 := null
                                   ,p_summary                       IN VARCHAR2
                                   ,p_ci_number                     IN VARCHAR2 := null
                                   ,p_description                   IN VARCHAR2 := null
                                   ,p_status_code                   IN VARCHAR2 := null
                                   ,p_status                        IN VARCHAR2 := null
                                   ,p_owner_id                      IN NUMBER := null
                                   ,p_highlighted_flag              IN  VARCHAR2 := 'N'
                                   ,p_progress_status_code          IN VARCHAR2 := null
                                   ,p_progress_as_of_date           IN DATE := null
                                   ,p_status_overview               IN VARCHAR2 := null
                                   ,p_classification_code           IN NUMBER
                                   ,p_reason_code                   IN NUMBER
                                   ,p_object_id                     IN NUMBER := null
                                   ,p_object_type                   IN VARCHAR2 := null
                                   ,p_date_required                 IN DATE := null
                                   ,p_date_closed                   IN DATE := null
                                   ,p_closed_by_id                  IN NUMBER := null
                                   ,p_resolution                    IN VARCHAR2 := null
                                   ,p_resolution_code               IN NUMBER := null
                                   ,p_priority_code                 IN VARCHAR2 := null
                                   ,p_effort_level_code             IN VARCHAR2 := null
                                   ,p_price                         IN NUMBER := null
                                   ,p_price_currency_code           IN VARCHAR2 := null
                                   ,p_source_type_name              IN VARCHAR2 := null
                                   ,p_source_type_code              IN VARCHAR2 := null
                                   ,p_source_number                 IN VARCHAR2 := null
                                   ,p_source_comment                IN VARCHAR2 := null
                                   ,p_source_date_received          IN DATE := null
                                   ,p_source_organization           IN VARCHAR2 := null
                                   ,p_source_person                 IN VARCHAR2 := null
                                   ,p_attribute_category            IN VARCHAR2 := null
                                   ,p_attribute1                    IN VARCHAR2 := null
                                   ,p_attribute2                    IN VARCHAR2 := null
                                   ,p_attribute3                    IN VARCHAR2 := null
                                   ,p_attribute4                    IN VARCHAR2 := null
                                   ,p_attribute5                    IN VARCHAR2 := null
                                   ,p_attribute6                    IN VARCHAR2 := null
                                   ,p_attribute7                    IN VARCHAR2 := null
                                   ,p_attribute8                    IN VARCHAR2 := null
                                   ,p_attribute9                    IN VARCHAR2 := null
                                   ,p_attribute10                   IN VARCHAR2 := null
                                   ,p_attribute11                   IN VARCHAR2 := null
                                   ,p_attribute12                   IN VARCHAR2 := null
                                   ,p_attribute13                   IN VARCHAR2 := null
                                   ,p_attribute14                   IN VARCHAR2 := null
                                   ,p_attribute15                   IN VARCHAR2 := null
                                   ,x_ci_id                         OUT NOCOPY NUMBER
                                   ,x_ci_number                     OUT NOCOPY NUMBER
                                   ,x_return_status                 OUT NOCOPY VARCHAR2
                                   ,x_msg_count                     OUT NOCOPY NUMBER
                                   ,x_msg_data                      OUT NOCOPY VARCHAR2
                                   )
is

  cursor get_prj_mgr_id(p_project_id NUMBER) is
  select hp.party_id ,ppf.full_name
  from pa_project_parties party,
       pa_project_role_types rtype,
       hz_parties hp,
       per_all_people_f ppf
  where party.project_id = p_project_id
  and   party.project_role_id = rtype.project_role_id
  and   rtype.project_role_type = 'PROJECT MANAGER'
  and   party.resource_source_id = pa_project_parties_utils.get_project_manager(p_project_id)
  and   hp.orig_system_reference = 'PER:'||party.resource_source_id
  and   ppf.person_id = party.resource_source_id;

  cursor get_strtng_sts_frm_sts_nme(p_ci_type_id number, p_status varchar2)
  is
  select  pstat.project_status_code, pstat.project_status_name, pstat.project_system_status_code
  from
  pa_obj_status_lists obj,
  pa_status_lists list,
  pa_status_list_items item,
  pa_project_statuses pstat
  where obj.object_id = p_ci_type_id
  and   obj.status_list_id = list.status_list_id
  and   list.status_type = 'CONTROL_ITEM'
  and   sysdate between list.start_date_active and nvl(list.end_date_active,sysdate)
  and   list.status_list_id = item.status_list_id
  and   pstat.project_status_code = item.project_status_code
  and   pstat.project_system_status_code in ('CI_DRAFT','CI_WORKING')
  and   pstat.project_status_name = p_status; /*where clause on status name*/

  cursor get_strtng_sts_frm_sts_cde(p_ci_type_id number, p_status_code varchar2)
  is
  select  pstat.project_status_code, pstat.project_status_name, pstat.project_system_status_code
  from
  pa_obj_status_lists obj,
  pa_status_lists list,
  pa_status_list_items item,
  pa_project_statuses pstat
  where obj.object_id = p_ci_type_id
  and   obj.status_list_id = list.status_list_id
  and   list.status_type = 'CONTROL_ITEM'
  and   sysdate between list.start_date_active and nvl(list.end_date_active,sysdate)
  and   list.status_list_id = item.status_list_id
  and   pstat.project_status_code = item.project_status_code
  and   pstat.project_system_status_code in ('CI_DRAFT','CI_WORKING')
  and   pstat.project_status_code  = p_status_code; /*where clause on status code*/

  cursor validate_owner_id(p_project_id number, p_owner_id number)
  is
  select distinct resource_party_id,
                  resource_source_name
  from PA_PROJECT_PARTIES_V
  where party_type <> 'ORGANIZATION'
  and project_id = p_project_id
  and resource_party_id = p_owner_id;

  cursor validate_progress_sts_code(p_progress_status_code varchar2)
  is
  select project_status_code
  from   pa_project_statuses
  where
  (trunc(sysdate) between nvl(start_date_active, trunc(sysdate)) and nvl(end_date_active, trunc(sysdate)))
  and status_type = 'PROGRESS'
  and project_status_code = p_progress_status_code;

  cursor validate_clsfcation_code(p_classification_code number)
  is
  select cat.class_code_id code
  from   pa_class_codes cat
        ,pa_ci_types_b typ
  where (trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate)))
  and typ.ci_type_id = p_ci_type_id
  and cat.class_category = typ.classification_category
  and cat.class_code_id = p_classification_code;

  cursor validate_reason_code(p_reason_code number)
  is
  select cat.class_code_id code
     from   pa_class_codes cat
           ,pa_ci_types_b typ
     where (trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate)))
     and typ.ci_type_id = p_ci_type_id
     and cat.class_category = typ.reason_category
     and cat.class_code_id = p_reason_code;

  cursor validate_obj_id(p_project_id number, p_object_id number)
  is
  select proj_element_id
  from PA_FIN_LATEST_PUB_TASKS_V
  where project_id = p_project_id
  and proj_element_id = p_object_id;

  l_user_id                                NUMBER := 0;
  l_party_id                               NUMBER := 0;
  l_resp_id                                NUMBER:= 0;

  cursor validate_cls_by_id(p_project_id number, p_closed_by_id number)
  is
  select 'Y'
  from PA_PROJECT_PARTIES_V
  where party_type <> 'ORGANIZATION'
  and project_id = p_project_id
  and resource_party_id = p_closed_by_id  --validating the p_closed_by_id
  and pa_ci_security_pkg.check_proj_auth_ci(p_project_id, l_user_id, l_resp_id) = 'T'; --validating the project authority here.

  cursor validate_resolution_code(p_resolution_code number)
  is
  select cat.class_code_id code
  from pa_class_codes cat
      ,pa_ci_types_b typ
  where (trunc(sysdate) between cat.start_date_active and nvl(cat.end_date_active,trunc(sysdate)))
  and typ.ci_type_id= p_ci_type_id
  and cat.class_category=typ.resolution_category
  and cat.class_code_id = p_resolution_code;

  cursor validate_priority_code(p_priority_code varchar2)
  is
  select lookup_code
  FROM   pa_lookups
  WHERE lookup_type='PA_TASK_PRIORITY_CODE'
        and  trunc(sysdate) < nvl(trunc(end_date_active), trunc(sysdate+1))
        and  enabled_flag = 'Y'
        and (trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate)))
        and lookup_code = p_priority_code;

  cursor validate_eff_lvl_code(p_effort_level_code varchar2)
  is
  select lookup_code
  FROM   pa_lookups
  WHERE lookup_type='PA_CI_EFFORT_LEVELS'
        and  trunc(sysdate) < nvl(trunc(end_date_active), trunc(sysdate+1))
        and  enabled_flag = 'Y'
        and (trunc(sysdate) between start_date_active and nvl(end_date_active, trunc(sysdate)))
        and lookup_code = p_effort_level_code;

  cursor validate_prj_currency(p_price_currency_code varchar2)
  is
  select currency_code
  from fnd_currencies_vl
  where enabled_flag = 'Y'
  and trunc(sysdate) between nvl(start_date_active,trunc(sysdate)) and nvl(end_date_active,trunc(sysdate))
  and currency_code = p_price_currency_code;

  validate_owner_id_rec                    validate_owner_id%rowtype;
  get_strtng_sts_frm_sts_nme_rec           get_strtng_sts_frm_sts_nme%rowtype;
  get_strtng_sts_frm_sts_cde_rec           get_strtng_sts_frm_sts_cde%rowtype;
  get_prj_mgr_id_rec                       get_prj_mgr_id%rowtype;

  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);


  l_any_err_occured_flg                    VARCHAR2(1);

  l_summary                                pa_control_items.summary%type;
  l_description                            pa_control_items.description%type;
  l_status_code                            pa_project_statuses.project_status_code%type;
  l_status_name                            pa_project_statuses.project_status_name%type;
  l_system_status_code                     pa_project_statuses.project_system_status_code%type;

  l_ci_number_char                         PA_CONTROL_ITEMS.ci_number%type  := NULL;
  l_ci_number_num                          NUMBER(15)    := NULL;
  l_system_number_id                       NUMBER(15) := NULL;

  l_owner_id                              per_all_people_f.party_id%type;
  l_owner_name                            per_all_people_f.full_name%type;
  l_progress_status_code                  pa_project_statuses.project_status_code%type;
  l_classification_code                   pa_control_items.classification_code_id%type;
  l_reason_code                           pa_control_items.reason_code_id%type;
  l_object_id                             pa_proj_elements.proj_element_id%type;
  l_date_closed                           pa_control_items.date_closed%type;
  l_closed_by_id                          pa_control_items.closed_by_id%type;
  l_valid_clsby_id                        VARCHAR2(1);
  l_resolution_code                       pa_control_items.resolution_code_id%type;
  l_resolution                            pa_control_items.resolution%type;
  l_effort_level_code                     pa_control_items.effort_level_code%type;
  l_priority_code                         pa_control_items.priority_code%type;
  l_price_currency_code                   pa_control_items.price_currency_code%type;
  l_price                                 pa_control_items.price%type;

  l_attribute_category                    pa_control_items.attribute_category%type;
  l_attribute1                            pa_control_items.attribute1%type;
  l_attribute2                            pa_control_items.attribute1%type;
  l_attribute3                            pa_control_items.attribute1%type;
  l_attribute4                            pa_control_items.attribute1%type;
  l_attribute5                            pa_control_items.attribute1%type;
  l_attribute6                            pa_control_items.attribute1%type;
  l_attribute7                            pa_control_items.attribute1%type;
  l_attribute8                            pa_control_items.attribute1%type;
  l_attribute9                            pa_control_items.attribute1%type;
  l_attribute10                           pa_control_items.attribute1%type;
  l_attribute11                           pa_control_items.attribute1%type;
  l_attribute12                           pa_control_items.attribute1%type;
  l_attribute13                           pa_control_items.attribute1%type;
  l_attribute14                           pa_control_items.attribute1%type;
  l_attribute15                           pa_control_items.attribute1%type;


  l_source_type_name                      pa_lookups.meaning%type;
  l_source_type_code                      pa_control_items.source_type_code%type;
  l_source_number                         pa_control_items.source_number%type;
  l_source_comment                        pa_control_items.source_comment%type;
  l_source_date_received                  pa_control_items.source_date_received%type;
  l_source_organization                   pa_control_items.source_organization%type;
  l_source_person                         pa_control_items.source_person%type;
  l_ci_id                                 pa_control_items.ci_id%type;
begin
  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'validate_param_and_create' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pvt.validate_param_and_create', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of validate_param_and_create', l_debug_level3);
  end if;

  --setting the err occured flag to N initially.
  l_any_err_occured_flg := 'N';

--get the user id and the party id for the current logged in user.
  l_user_id  := fnd_global.user_id;
  l_party_id := pa_control_items_utils.getpartyid(l_user_id);
  l_resp_id  := fnd_global.resp_id;

  if(p_summary is null) then
     PA_UTILS.ADD_MESSAGE
                       (p_app_short_name  => 'PA',
                        p_msg_name        => 'PA_CI_NO_SUMMARY');  --existing msg
     if l_debug_mode = 'Y' then
        pa_debug.g_err_stage:= 'Summary passed is null';
        pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
     end if;
     l_any_err_occured_flg := 'Y';
  end if;

  l_summary := p_summary;
  l_description := p_description;

  if (p_status_code is null and p_status is null) then
      /*get the default starting status*/
      l_status_code := PA_CONTROL_ITEMS_UTILS.Get_Initial_Ci_Status(p_ci_type_id);
      /*l_status_code would always be CI_WORKING here and below select would always give CI_WORKING
      for project_system_status_code. So */
      select project_system_status_code
      into l_system_status_code
      from pa_project_statuses
      where project_status_code = l_status_code
      and status_type = 'CONTROL_ITEM';

  elsif(p_status_code is null and p_status is not null) then

     /* the below cursor query will give only one record as status_type and project_status_name forms a
         unique index on pa_project_statuses table We derive p_status_code from */
      open get_strtng_sts_frm_sts_nme(p_ci_type_id , p_status);
      fetch get_strtng_sts_frm_sts_nme into get_strtng_sts_frm_sts_nme_rec;
      if (get_strtng_sts_frm_sts_nme%notfound) then
           PA_UTILS.Add_message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_CI_INV_STATUS');
           if l_debug_mode = 'Y' then
                pa_debug.g_err_stage:= 'Invalid status passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           l_any_err_occured_flg := 'Y';
           close get_strtng_sts_frm_sts_nme;
      else
          l_status_code         :=     get_strtng_sts_frm_sts_nme_rec.project_status_code;
          l_status_name         :=     get_strtng_sts_frm_sts_nme_rec.project_status_name;
          l_system_status_code  :=     get_strtng_sts_frm_sts_nme_rec.project_system_status_code;
          close get_strtng_sts_frm_sts_nme;
      end if;

  elsif(p_status_code is not null) then
     /*Validate the p_status_code*/

      open get_strtng_sts_frm_sts_cde(p_ci_type_id, p_status_code);
      fetch get_strtng_sts_frm_sts_cde into get_strtng_sts_frm_sts_cde_rec;
      if (get_strtng_sts_frm_sts_cde%notfound) then
           PA_UTILS.Add_message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_CI_INVALID_STATUS_CODE'); --this msg is already there
           if l_debug_mode = 'Y' then
                pa_debug.g_err_stage:= 'Invalid status code passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           l_any_err_occured_flg := 'Y';
           close get_strtng_sts_frm_sts_cde;
      else
          l_status_code         :=     get_strtng_sts_frm_sts_cde_rec.project_status_code;
          l_status_name         :=     get_strtng_sts_frm_sts_cde_rec.project_status_name;
          l_system_status_code  :=     get_strtng_sts_frm_sts_cde_rec.project_system_status_code;
           close get_strtng_sts_frm_sts_cde;
      end if;
  end if;

  if(p_owner_id is null) then
  /*if owner id is not passed default it with the project manager id*/
       open get_prj_mgr_id(p_project_id);
       fetch get_prj_mgr_id into get_prj_mgr_id_rec;
       if (get_prj_mgr_id%notfound) then
               pa_utils.add_message( p_app_short_name => 'PA'
                                     ,p_msg_name      => 'PA_CI_NO_MGR_ID'); --Need to check what this msg context shd be.
             if l_debug_mode = 'Y' then
                   pa_debug.g_err_stage:= 'Could not find project manager';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
             close get_prj_mgr_id;
             l_any_err_occured_flg := 'Y';
       else
           l_owner_id := get_prj_mgr_id_rec.party_id;
           l_owner_name := get_prj_mgr_id_rec.full_name;
           close get_prj_mgr_id;
       end if;
  elsif(p_owner_id is not null) then  --p_owner_id is null
  /* validate the passed owner id*/

      open validate_owner_id(p_project_id, p_owner_id);
      fetch validate_owner_id into validate_owner_id_rec;
      if(validate_owner_id%notfound) then
          pa_utils.add_message( p_app_short_name => 'PA'
                               ,p_msg_name      => 'PA_CI_NO_OWNER'); --existing msg
          if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Invalid owner id passed';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          end if;
          l_any_err_occured_flg := 'Y';
          close validate_owner_id;
      else
         l_owner_id    := validate_owner_id_rec.resource_party_id;
         l_owner_name  := validate_owner_id_rec.resource_source_name;
         close validate_owner_id;
      end if;
  end if; --p_owner_id is null

  /* Validate the p_progress_status_code if it is not null else default the progress with the on_track*/
  if(p_progress_status_code is not null) then
      open validate_progress_sts_code(p_progress_status_code);
      fetch validate_progress_sts_code into l_progress_status_code;
      if (validate_progress_sts_code%notfound) then
          pa_utils.add_message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CI_INV_PRG_CODE');
          if l_debug_mode = 'Y' then
               pa_debug.g_err_stage:= 'Invalid progress status code passed';
               pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
          end if;
          l_any_err_occured_flg := 'Y';
          close validate_progress_sts_code;
      else --if (validate_progress_sts_code%notfound) then
          close validate_progress_sts_code;
      end if;
  else
     /*else default the progress with the on_track*/
     l_progress_status_code := 'PROGRESS_STAT_ON_TRACK';
  end if;

    /*Check for mandatory classification code and reason code*/
    l_reason_code         := p_reason_code;
    if (p_classification_code is null or p_reason_code is null )
       then
         if (p_classification_code is null) then
              pa_utils.add_message( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_CI_MIS_CLASSIFICATION_COD'); --msg is already there
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'classification_code is null';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
              l_any_err_occured_flg := 'Y';
          end if;
         if (p_reason_code is null) then
              pa_utils.add_message( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_CI_MISS_REASON_CODE');    --msg is already there
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'reason_code is null';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
              l_any_err_occured_flg := 'Y';
         end if;
    end if;

  /* validate the passed classification_code*/
  if(p_classification_code is not null) then
     open validate_clsfcation_code(p_classification_code);
     fetch validate_clsfcation_code into l_classification_code;
     if (validate_clsfcation_code%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_CLASSIFICATION_INV');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid classification code passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_clsfcation_code;
     else
         close validate_clsfcation_code;
     end if;
  end if;

  /* validate the passed reason_code*/
  if(p_reason_code is not null) then
     open validate_reason_code(p_reason_code);
     fetch validate_reason_code into l_reason_code;
     if (validate_reason_code%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_REA_CODE');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid reason code passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_reason_code;
      else
         close validate_reason_code;
      end if;
  end if;

  /*Currently only PA_TASKS type of objects are supported*/
  if(p_object_type is not null and p_object_type <> 'PA_TASKS') then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_OBJ_TYPE');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid object type passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
  end if;

 /* Validate the object id passed*/
  if (p_object_id is not null) then
     open validate_obj_id(p_project_id, p_object_id);
     fetch validate_obj_id into l_object_id;
     if (validate_obj_id%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_OBJ_ID');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid Object Id passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_obj_id;
     end if;
     close validate_obj_id;
  end if;


  /*validations for p_closed_date parameter. The date must be supplied for a item in closed status, for statuses other than closed
  we should ignore this value*/
  if( l_system_status_code = 'CI_CLOSED') then
     if(p_date_closed is null) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_CLS_DATE_MISS');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'For a control item in closed status, closed_date is missing';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
     else
          l_date_closed := p_date_closed;
     end if;
  else
    /* for status other than closed ignore the closed date*/
     l_date_closed := null;
  end if;

  /*validations for p_closed_by_id parameter. The p_closed_by_id must be supplied for a item in closed status
    and it must be a valid id(validte the closed_by_id passed). for statuses other than closed, ignore the p_closed_by_id.*/

  if( l_system_status_code = 'CI_CLOSED') then

     if(p_closed_by_id is null) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_CLS_BYID_MISS');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'For a control item in closed status, closed_by_id is missing';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
     else--if(p_closed_by_id is null) then
      /*validate the p_closed_by_id. Also the persons with the project authority can close the item*/
         open validate_cls_by_id(p_project_id , p_closed_by_id);
         fetch validate_cls_by_id into l_valid_clsby_id;
         if(validate_cls_by_id%notfound) then
             pa_utils.add_message( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_CI_INV_CLS_BYID');
             if l_debug_mode = 'Y' then
                  pa_debug.g_err_stage:= 'inavlid closed_by_id is passed or user doesnt have project authority';
                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
             l_any_err_occured_flg := 'Y';
             close validate_cls_by_id;
         else
             l_closed_by_id := p_closed_by_id;
             close validate_cls_by_id;
         end if;--if(sql%notfound) then
     end if;--if(p_closed_by_id is null) then

  else--( l_system_status_code = 'CI_CLOSED') then
    /* for status other than closed ignore the closed by id*/
     l_closed_by_id := null;
  end if;

  /*
  Validate the resolution attribute.
  1)if resoltuion id passed then validate the id.
  2)check status. if status is sbumitted then resolution id and resoltuion both must be passed. hold it.
  3)also resolution can be enetered for any status .simply stamp the value in db for resoltuion irrespective of staus after validating
    it
  4) Also in UI we can have resolution with missing resoltuion category. Is it ok to have this.- Hold this.
  */
  if(p_resolution_code is not null) then
  open validate_resolution_code(p_resolution_code);
  fetch validate_resolution_code into l_resolution_code;
     if (validate_resolution_code%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_RES_CODE');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid resolution code passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_resolution_code;
     end if;
     close validate_resolution_code;
  end if;

  l_resolution := p_resolution;

 /*Validate the priority level code*/
  if(p_priority_code is not null) then
    open validate_priority_code(p_priority_code);
    fetch validate_priority_code into l_priority_code;
     if (validate_priority_code%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_PRIO_CODE');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid priority code passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_priority_code;
     end if;
     close validate_priority_code;
  end if;

 /*Validate the effort level code*/
  if(p_effort_level_code is not null) then
  open validate_eff_lvl_code(p_effort_level_code);
  fetch validate_eff_lvl_code into l_effort_level_code;
     if (validate_eff_lvl_code%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_EFFR_CODE');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid effort code passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_eff_lvl_code;
     end if;
     close validate_eff_lvl_code;
  end if;

  /* if currency_code is null then default it with project currency else validate the passed value*/
  if (p_price_currency_code is null) then
    select projfunc_currency_code
    into l_price_currency_code
    from pa_projects_all
    where project_id = p_project_id;
  else
     open validate_prj_currency(p_price_currency_code);
     fetch validate_prj_currency into l_price_currency_code;
     if (validate_prj_currency%notfound) then
         pa_utils.add_message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_CI_INV_CURR_CODE');
         if l_debug_mode = 'Y' then
              pa_debug.g_err_stage:= 'Invalid currency code passed';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
         end if;
         l_any_err_occured_flg := 'Y';
         close validate_prj_currency;
     end if;
     close validate_prj_currency;
  end if;

  /*Needto check if we should have the validation that whenever price is passed a valid currency must be there for the control item*/
  l_price := p_price;

  /* source attributes would only be acknowledged only if the enable source attributes flag was set at the control item type level*/
  /*need to write the code to validate the source type/dervive source type code from surce type name*/
  if(p_source_attrs_enabled_flag = 'Y') then
        l_source_type_name      :=  p_source_type_name;
        l_source_type_code      :=  p_source_type_code;
        l_source_number         :=  p_source_number;
        l_source_comment        :=  p_source_comment;
        l_source_date_received  :=  p_source_date_received;
        l_source_organization   :=  p_source_organization;
        l_source_person         :=  p_source_person;
  end if;

  l_attribute_category       :=          p_attribute_category;
  l_attribute1               :=          p_attribute1;
  l_attribute2               :=          p_attribute2;
  l_attribute3               :=          p_attribute3;
  l_attribute4               :=          p_attribute4;
  l_attribute5               :=          p_attribute5;
  l_attribute6               :=          p_attribute6;
  l_attribute7               :=          p_attribute7;
  l_attribute8               :=          p_attribute8;
  l_attribute9               :=          p_attribute9;
  l_attribute10              :=          p_attribute10;
  l_attribute11              :=          p_attribute11;
  l_attribute12              :=          p_attribute12;
  l_attribute13              :=          p_attribute13;
  l_attribute14              :=          p_attribute14;
  l_attribute15              :=          p_attribute15;

   /* if we reach here in code then all the attributes have been validated.
   So get the next value from the sequence which will be used as the ci_id*/
   select pa_control_items_s.nextval
   into l_ci_id
   from dual;

  /* now generate the ci_number;*/
  if(l_status_code is not null) then
      begin
          /*ci_number would be generated only for the items with auto numbering and which are not in draft status*/
          if p_auto_number_flag = 'Y' and l_system_status_code <> 'CI_DRAFT' then
            loop
                pa_system_numbers_pkg.get_next_number (
                        p_object1_pk1_value     => p_project_id
                        ,p_object1_type         => 'PA_PROJECTS'
                        ,p_object2_pk1_value    => p_ci_type_id
                        ,p_object2_type         => p_ci_type_class_code
                        ,x_system_number_id     => l_system_number_id
                        ,x_next_number          => l_ci_number_num
                        ,x_return_status        => x_return_status
                        ,x_msg_count            => x_msg_count
                        ,x_msg_data             => x_msg_data);

                if  x_return_status <> FND_API.g_ret_sts_success then
                      if l_debug_mode = 'Y' then
                         pa_debug.g_err_stage:= 'Failed in pa_system_numbers_pkg.get_next_number';
                         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                      end if;
                      raise api_error;
                end if;
                l_ci_number_char := TO_CHAR(l_ci_number_num);

                -- call Client Extension here
                pa_ci_number_client_extn.get_next_number (
                     p_object1_pk1_value    => p_project_id
                    ,p_object1_type         => 'PA_PROJECTS'
                    ,p_object2_pk1_value    => p_ci_type_id
                    ,p_object2_type         => p_ci_type_class_code
                    ,p_next_number          => l_ci_number_char
                    ,x_return_status        => x_return_status
                    ,x_msg_count            => x_msg_count
                    ,x_msg_data             => x_msg_data);

                exit when pa_control_items_pvt.ci_number_exists(p_project_id, l_ci_number_char
                                          ,p_ci_type_id) = FALSE;
            end loop;
          else --p_auto_number_flag = 'Y' and l_system_status_code <> 'CI_DRAFT'
          /*For manual numbering check if passed ci_number already exist.*/
                l_ci_number_char := p_ci_number;
                if pa_control_items_pvt.ci_number_exists(p_project_id, l_ci_number_char  ,p_ci_type_id) = TRUE then
                        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                             ,p_msg_name       => 'PA_CI_DUPLICATE_CI_NUMBER');--msg already there
                        if l_debug_mode = 'Y' then
                            pa_debug.g_err_stage:= 'Duplicate ci_number passed.';
                            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        l_any_err_occured_flg := 'Y';
                end if;
          end if;--p_auto_number_flag = 'Y' and l_system_status_code <> 'CI_DRAFT'

         /* if auto numbering is enabled then l_ci_number_char wont be null here. For manual numbering checking if
            passed ci_number was null.*/
         if l_ci_number_char is null and l_system_status_code <> 'CI_DRAFT' then
               pa_utils.add_message( p_app_short_name => 'PA'
                                     ,p_msg_name      => 'PA_CI_NO_CI_NUMBER'); --msg already there
             if l_debug_mode = 'Y' then
                   pa_debug.g_err_stage:= 'Missing ci_number';
                   pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
             l_any_err_occured_flg := 'Y';
         end if;
      exception
      when api_error then
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           /*need to get input here as to how to handle the exception and populate the stack with appropriate messages.
           Set some other flag l_other_excp here and use tht flag to handle the unexpected case of exception handling*/
           l_any_err_occured_flg := 'Y';
      end; --for begin
  end if;--l_status_code is not null

  if l_debug_mode = 'Y' then
       pa_debug.g_err_stage:= 'about to call the table handler';
       pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
  end if;

  if (l_any_err_occured_flg is not null and l_any_err_occured_flg <> 'Y') then
      pa_control_items_pkg.insert_row (
                                            p_ci_type_id           =>  p_ci_type_id,
                                            p_summary              =>  l_summary,
                                            p_status_code          =>  l_status_code,
                                            p_owner_id             =>  l_owner_id,
                                            p_highlighted_flag     =>  p_highlighted_flag,
                                            p_progress_status_code =>  l_progress_status_code,
                                            p_progress_as_of_date  =>  nvl(p_progress_as_of_date,sysdate),
                                            p_classification_code  =>  l_classification_code,
                                            p_reason_code          =>  l_reason_code,
                                            p_project_id           =>  p_project_id,
                                            p_last_modified_by_id  =>  l_party_id,
                                            p_object_type          =>  p_object_type,
                                            p_object_id            =>  l_object_id,
                                            p_ci_number            =>  l_ci_number_char,
                                            p_date_required        =>  p_date_required,
                                            p_date_closed          =>  l_date_closed,
                                            p_closed_by_id         =>  l_closed_by_id,
                                            p_description          =>  l_description,
                                            p_status_overview      =>  p_status_overview,
                                            p_resolution           =>  l_resolution,
                                            p_resolution_code      =>  l_resolution_code,
                                            p_priority_code        =>  l_priority_code,
                                            p_effort_level_code    =>  l_effort_level_code,
                                            p_price                =>  l_price,
                                            p_price_currency_code  =>  l_price_currency_code,
                                            p_source_type_code     =>  l_source_type_code,
                                            p_source_comment       =>  l_source_comment,
                                            p_source_number        =>  l_source_number,
                                            p_source_date_received =>  l_source_date_received,
                                            p_source_organization  =>  l_source_organization,
                                            p_source_person        =>  l_source_person,
                                            p_attribute_category   =>  l_attribute_category,
                                            p_attribute1           =>  l_attribute1,
                                            p_attribute2           =>  l_attribute2,
                                            p_attribute3           =>  l_attribute3,
                                            p_attribute4           =>  l_attribute4,
                                            p_attribute5           =>  l_attribute5,
                                            p_attribute6           =>  l_attribute6,
                                            p_attribute7           =>  l_attribute7,
                                            p_attribute8           =>  l_attribute8,
                                            p_attribute9           =>  l_attribute9,
                                            p_attribute10          =>  l_attribute10,
                                            p_attribute11          =>  l_attribute11,
                                            p_attribute12          =>  l_attribute12,
                                            p_attribute13          =>  l_attribute13,
                                            p_attribute14          =>  l_attribute14,
                                            p_attribute15          =>  l_attribute15,
                                            px_ci_id               =>  l_ci_id,
                                            x_return_status        =>  x_return_status,
                                            x_msg_count            =>  x_msg_count,
                                            x_msg_data             =>  x_msg_data,
                                            p_orig_system_code     =>  p_orig_system_code,
                                            p_orig_system_reference=>  p_orig_system_reference
                                      );
  end if;

  if (x_return_status <> fnd_api.g_ret_sts_success) then
      if l_debug_mode = 'Y' then
            pa_debug.g_err_stage:= 'Missing ci_number';
            pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      end if;
      raise fnd_api.g_exc_unexpected_error;
  end if;

  x_ci_id := l_ci_id;
  x_ci_number := l_ci_number_char;

  if( l_any_err_occured_flg = 'Y' ) then
     raise fnd_api.g_exc_error;
  end if;
  /* set the out variables ci_id and ci_number if there were no exceptions for any of the attributes*/
  x_ci_id := l_ci_id;
  x_ci_number := l_ci_number_char;

  --rest the stack;
  if l_debug_mode = 'Y' then
        pa_debug.reset_curr_function;
  end if;

exception
  when fnd_api.g_exc_unexpected_error then
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            FND_MSG_PUB.Count_And_Get(
                                      p_count     =>  x_msg_count ,
                                      p_data      =>  x_msg_data  );
          /*Initialize the out variables back to null*/
          x_ci_id         := null;
          x_ci_number           := null;
         --rest the stack;
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;
        --raise the exception
        raise;
  when fnd_api.g_exc_error then
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

         /*Initialize the out variables back to null*/
         x_ci_id               := null;
         x_ci_number           := null;

         --rest the stack;
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;
         --raise the exception
         raise;
  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'validate_param_and_create',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

         /*Initialize the out variables back to null*/
         x_ci_id               := null;
         x_ci_number           := null;


         --Reset the stack
         if l_debug_mode = 'Y' then
               pa_debug.reset_curr_function;
         end if;
         --raise the exception
         raise;
end validate_param_and_create;

procedure check_create_action_allow(
                                    p_ci_id                  IN NUMBER := null,
                                    x_project_id             OUT NOCOPY NUMBER,
                                    x_return_status          OUT NOCOPY VARCHAR2,
                                    x_msg_count              OUT NOCOPY NUMBER,
                                    x_msg_data               OUT NOCOPY VARCHAR2)
IS

cursor check_valid_ci_id(p_ci_id number) is
select ci_id, project_id
from pa_control_items
where ci_id = p_ci_id;


  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_any_err_occured_flg                    VARCHAR2(1);
  l_create_action_flg                      VARCHAR2(1) := null;
  l_ci_id                                  pa_control_items.ci_id%type;
  l_check_valid_ci_id_rec                  check_valid_ci_id%rowtype;
BEGIN

  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'check_create_action_allow' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pvt.check_create_action_allow', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of check_create_action_allow', l_debug_level3);
  end if;

--Setting this flag to N initially.
  l_any_err_occured_flg := 'N';

  /* check if p_ci_id is not passed/null*/
  if(p_ci_id is null) then
      pa_utils.add_message
                        (p_app_short_name  => 'PA',
                         p_msg_name        => 'PA_CI_MISS_CI_ID');
      if l_debug_mode = 'Y' then
         pa_debug.g_err_stage:= 'ci_id is missing';
         pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
      end if;
      l_any_err_occured_flg := 'Y';
  end if;--  if(p_ci_id is null) then

  /*check if p_ci_id is a valid control item id*/
  if(p_ci_id is not null)then
     open check_valid_ci_id(p_ci_id);
     fetch check_valid_ci_id into l_check_valid_ci_id_rec; --l_ci_id;
     if(check_valid_ci_id%notfound) then
        /*invalid ci_id*/
        pa_utils.add_message
                          (p_app_short_name  => 'PA',
                           p_msg_name        => 'PA_CI_INV_CI_ID');
        if l_debug_mode = 'Y' then
           pa_debug.g_err_stage:= 'ci_id is invalid';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        close check_valid_ci_id;
        l_any_err_occured_flg := 'Y';
     else
        l_ci_id      := l_check_valid_ci_id_rec.ci_id;
        x_project_id := l_check_valid_ci_id_rec.project_id;
        close check_valid_ci_id;
     end if;--if(check_valid_ci_id%notfound) then
  end if;--  if(p_ci_id is not null)then

  /*check whether the logged in user has privilge to create the action or not*/
  /*Need to revisit function used below. It cannot be used here. We dont want to use the status controls check
    from here*/
  if(l_ci_id is not null)--checking only if ci_id was valid and not null
  then
     l_create_action_flg := pa_ci_security_pkg.check_create_action(p_ci_id => l_ci_id, p_calling_context => 'AMG');
  end if;

  if(l_create_action_flg is not null and l_create_action_flg = 'F') then
  /*user doesnt have privilige to create the action*/
        pa_utils.add_message
                          (p_app_short_name  => 'PA',
                           p_msg_name        => 'PA_CI_ACT_FLS_SEC');
        if l_debug_mode = 'Y' then
           pa_debug.g_err_stage:= 'user doesnt have security to create the action';
           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
        l_any_err_occured_flg := 'Y';
  end if;

  if( l_any_err_occured_flg is not null and l_any_err_occured_flg = 'Y' ) then
     raise fnd_api.g_exc_error;
  end if;

  --rest the stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;

Exception
  when fnd_api.g_exc_error then
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
         /*initializing the out variables to null*/
         x_project_id := null;
         /* no in/out paramters to be set to their initial values here*/
         --rest the stack;
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;
       --raise the exception
       raise;
  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'check_create_action_allow',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
         /*initializing the out variables to null*/
          x_project_id := null;
         /* no in/out paramters to be set to their initial values here*/
         --rest the stack;
         if l_debug_mode = 'Y' then
          pa_debug.reset_curr_function;
         end if;
         --raise the exception
         raise;
END check_create_action_allow;

procedure validate_assignee_id(
                                p_assignee_id           IN NUMBER
                               ,p_project_id            IN NUMBER
                               ,p_msg_token_num         IN NUMBER DEFAULT NULL
                               ,x_assignee_id           OUT NOCOPY NUMBER
                               ,x_return_status         OUT NOCOPY VARCHAR2
                               ,x_msg_count             OUT NOCOPY NUMBER
                               ,x_msg_data              OUT NOCOPY VARCHAR2
                              )
is
/*cursor to validate the action assignee id*/
cursor chk_act_assgn_id(p_project_id number, p_assignee_id number) is
SELECT p.resource_type_id,
       p.resource_source_id,
       p.name,
       p.organization_id,
       p.organization_name,
       p.object_id,
       p.object_type,
       l.meaning internal,
       pl.meaning person_type,
       p.employee_number,
       p.party_id
FROM pa_people_lov_v p,
     fnd_lookups l,
     pa_lookups pl
WHERE l.lookup_type='YES_NO'
  AND l.lookup_code=DECODE(p.resource_type_id, 101, 'Y', 'N')
  AND pl.lookup_type(+) = 'PA_PERSON_TYPE'
  AND pl.lookup_code(+) = p.person_type
  and ( p.object_type IS NULL OR (p.object_type='PA_PROJECTS' AND p.object_id = p_project_id))
  and p.party_id = p_assignee_id;

  chk_act_assgn_id_rec  chk_act_assgn_id%rowtype;
  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);

BEGIN
  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'validate_assignee_id' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pvt.validate_assignee_id', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of validate_assignee_id', l_debug_level3);
  end if;

  if(p_assignee_id is not null) then
      /*Validate the passed action assinee id exists in the system*/
      open chk_act_assgn_id(p_project_id, p_assignee_id);
      fetch chk_act_assgn_id into chk_act_assgn_id_rec;
      if(chk_act_assgn_id%notfound) then
             x_return_status := fnd_api.g_ret_sts_error;

             if(p_msg_token_num is not null) then
             /*if p_msg_token_num is passed then we are raising the parameterized msg which we need in create_action flow frm amg*/
                     pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_INV_ACT_ASSGN_CODE', -- We have this similar msg
                                          p_token1          => 'NUMBER',                   --PA_CI_ACTION_INVALID_ASSIGNEE
                                          p_value1          =>  p_msg_token_num);          --but it doesnt have tokens
             else
             /*if p_msg_token_num is not passed then we are raising the msg without any tokens
               which we need in take action flow in amg. Note the two msg names are different.*/
                     pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_INV_ACT_ASSGN_CODE_NT');
             end if;--if(p_msg_token_num is not null) then

             if (l_debug_mode = 'Y') then
                pa_debug.g_err_stage:= 'Invalid action assingee code passed';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
             close chk_act_assgn_id;
             raise fnd_api.g_exc_error;
      else--(chk_act_assgn_id%notfound) then
            x_assignee_id := chk_act_assgn_id_rec.party_id;
            close chk_act_assgn_id;
      end if;--if(chk_act_assgn_id%notfound) then
  else--if(p_assignee_id is not null) then
      /*Action Assignee is Missing for this action record.*/
             x_return_status := fnd_api.g_ret_sts_error;

             if(p_msg_token_num is not null) then
                     pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_MISS_ASSGN_ID',
                                          p_token1          => 'NUMBER',
                                          p_value1          =>  p_msg_token_num);
             else--if(p_msg_token_num is not null)
                     pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_MISS_ASSGN_ID_NT');
             end if;--if(p_msg_token_num is not null)

             if l_debug_mode = 'Y' then
                pa_debug.g_err_stage:= 'Action Assignee Id is missing';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
             end if;
             raise fnd_api.g_exc_error;
  end if;--if(p_assignee_id is not null) then
  --rest the stack;
         if l_debug_mode = 'Y' then
          pa_debug.reset_curr_function;
         end if;

Exception
  when fnd_api.g_exc_error then
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
         /*inititalise the out variables to null here*/
         x_assignee_id := null;
         /* no in/out paramters to be set to their initial values here*/
        --reset the err stack
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;

  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'validate_assignee_id',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
         /*inititalise the out variables to null here*/
         x_assignee_id := null;
         /* no in/out paramters to be set to their initial values here*/
        --reset the err stack
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;
        /*dont raise this exception*/
END validate_assignee_id;

procedure validate_action_attributes(
                                     p_ci_id                 IN NUMBER
                                    ,p_project_id            IN NUMBER
                                    ,p_action_tbl            IN pa_control_api_pub.ci_actions_in_tbl_type
                                    ,x_action_tbl            OUT NOCOPY pa_control_api_pub.ci_actions_in_tbl_type
                                    ,x_return_status         OUT NOCOPY VARCHAR2
                                    ,x_msg_count             OUT NOCOPY NUMBER
                                    ,x_msg_data              OUT NOCOPY VARCHAR2
                                    )
IS

cursor chk_act_typ_code(p_action_type_code varchar2)
is select lookup_code, meaning
   from pa_lookups
where lookup_type ='PA_CI_ACTION_TYPES'
and meaning = p_action_type_code;

cursor check_valid_src_ci_action_id(p_action_id number) is
select ci_action_id, status_code
from pa_ci_actions
where source_ci_action_id = p_action_id;


cursor chk_action_status_code(p_action_status VARCHAR2)
is
select project_status_code
      from pa_project_statuses
      where status_type = 'CI_ACTION'
      and project_status_name = p_action_status;

cursor act_sts_allw_for_ci_sts(p_ci_id NUMBER)
is
select pps.project_system_status_code
from pa_project_statuses pps,
     pa_control_items pci
where pps.status_type = 'CONTROL_ITEM'
and pps.project_status_code = pci.status_code
and pci.ci_id = p_ci_id;


  chk_act_typ_code_rec                   chk_act_typ_code%rowtype;
--  chk_act_assgn_id_rec                   chk_act_assgn_id%rowtype;


  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_any_err_occured_flg                    VARCHAR2(1);
  l_return_status                          VARCHAR2(1);

  l_action_status_code                     pa_project_statuses.project_status_code%type;
  l_ci_status_code                         pa_control_items.status_code%type;
  --l_src_ci_action_id                       pa_ci_actions.ci_action_id%type;
  l_action_tbl                             pa_control_api_pub.ci_actions_in_tbl_type;
  chk_valid_src_ci_action_id_rec           check_valid_src_ci_action_id%rowtype;

BEGIN
  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'validate_action_attributes' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pvt.validate_action_attributes', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of validate_action_attributes', l_debug_level3);
  end if;

  --Setting this flag to N initially outside the loop.
  l_any_err_occured_flg := 'N';

  if(p_action_tbl.count > 0) then

      For i in 1..p_action_tbl.count
      loop

          l_action_tbl(i).action_type_code          := p_action_tbl(i).action_type_code;
          l_action_tbl(i).assignee_id               := p_action_tbl(i).assignee_id;
          l_action_tbl(i).date_required             := p_action_tbl(i).date_required;
          l_action_tbl(i).request_text              := p_action_tbl(i).request_text;
          l_action_tbl(i).action_status             := p_action_tbl(i).action_status;
          l_action_tbl(i).source_ci_action_id       := p_action_tbl(i).source_ci_action_id;
          l_action_tbl(i).closed_date               := p_action_tbl(i).closed_date;
          l_action_tbl(i).sign_off_requested_flag   := p_action_tbl(i).sign_off_requested_flag;
          l_action_tbl(i).signed_off                := p_action_tbl(i).signed_off;
          l_action_tbl(i).start_wf                  := p_action_tbl(i).start_wf;

             /*Validate the action_type_code. It can be one of update or review*/
             if(l_action_tbl(i).action_type_code is not null) then
                 open chk_act_typ_code(l_action_tbl(i).action_type_code);
                 fetch chk_act_typ_code into chk_act_typ_code_rec;
                 if(chk_act_typ_code%notfound) then
                        pa_utils.add_message(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_CI_INV_ACT_CODE',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if l_debug_mode = 'Y' then
                           pa_debug.g_err_stage:= 'Invalid action code';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        close chk_act_typ_code;
                        l_any_err_occured_flg := 'Y';
                 else--(chk_act_typ_code%notfound) then
                       x_action_tbl(i).action_type_code := chk_act_typ_code_rec.lookup_code;
                       close chk_act_typ_code;
                 end if;--if(chk_act_typ_code%notfound) then
             else--(l_action_tbl(i).action_type_code is not null) then
                 /*if action_type_code is not passed then we default the action type as review action*/
                 x_action_tbl(i).action_type_code := 'REVIEW';
             end if;--(l_action_tbl(i).action_type_code is not null) then

           /*validate the action_assignee id*/
           validate_assignee_id(
                                p_assignee_id           => l_action_tbl(i).assignee_id
                               ,p_project_id            => p_project_id
                               ,p_msg_token_num         => i  --passing this value to show tokenized messages.
                               ,x_assignee_id           => x_action_tbl(i).assignee_id
                               ,x_return_status         => l_return_status
                               ,x_msg_count             => l_msg_count
                               ,x_msg_data              => l_msg_data
                              );

           if(l_return_status <> fnd_api.g_ret_sts_success) then
                /* we are not raising the exception here*/
                l_any_err_occured_flg := 'Y';
           end if;



             /*Copy the other two attributes date and request to out table*/
             x_action_tbl(i).date_required            := l_action_tbl(i).date_required;
             x_action_tbl(i).request_text             := l_action_tbl(i).request_text;

             /* sign off requested flag can only be Y or N. so when it is passed Y setting it to Y else
               setting it to N explicitly.although the varibale has been set to default value of N.
               Explicit initialization is must because we are not validating this flag for a value other than Y or N*/
             if(l_action_tbl(i).sign_off_requested_flag is not null and l_action_tbl(i).sign_off_requested_flag = 'Y') then
                  x_action_tbl(i).sign_off_requested_flag  := l_action_tbl(i).sign_off_requested_flag;
             else
                  x_action_tbl(i).sign_off_requested_flag  := 'N';
             end if;

             /* Validate the status code for the action. It can be either of Closed/Canceled/Open*/
             if(l_action_tbl(i).action_status is not null) then
                open chk_action_status_code(l_action_tbl(i).action_status);
                fetch chk_action_status_code into l_action_status_code;
                if(chk_action_status_code%notfound) then
                        pa_utils.add_message(p_app_short_name  => 'PA',
                                             p_msg_name        => 'PA_CI_INV_ACT_STS_CODE',
                                             p_token1          => 'NUMBER',
                                             p_value1          =>  i);
                        if (l_debug_mode = 'Y') then
                           pa_debug.g_err_stage:= 'Status code for the action is invalid';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        close chk_action_status_code;
                        l_any_err_occured_flg := 'Y';
                else--if(chk_action_status_code%notfound) then

                  /* Validate that this action status code is allowed for the control item status*/
                  /* only control items in open/ draft status can have the open actions. A control item in any other status cannot
                     have open actions*/
                   /*get the control item status code*/
                   open  act_sts_allw_for_ci_sts(p_ci_id);
                   fetch act_sts_allw_for_ci_sts into l_ci_status_code;
                   /* the cursor shd always return a record here as ci_id is valid at this place in code unless the status types
                      heve not been set up in the system for control items*/
                   if(act_sts_allw_for_ci_sts%notfound) then
                        if (l_debug_mode = 'Y') then
                           pa_debug.g_err_stage:= 'Either the ci_id is invalid or statuses for control item  have not been set up';
                           pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                        end if;
                        close act_sts_allw_for_ci_sts;
                   else
                       if( (l_ci_status_code = 'CI_APPROVED' or l_ci_status_code = 'CI_CANCELED' or l_ci_status_code = 'CI_CLOSED'
                            or l_ci_status_code = 'CI_REJECTED' or l_ci_status_code = 'CI_SUBMITTED')
                           and
                           (l_action_status_code = 'CI_ACTION_OPEN') ) then
                             /*raise the msg action status not valid for the control item status*/
                             pa_utils.add_message(p_app_short_name  => 'PA',
                                                  p_msg_name        => 'PA_CI_MISMATCH_ACT_CI_STS',
                                                  p_token1          => 'NUMBER',
                                                  p_value1          =>  i);
                             if (l_debug_mode = 'Y') then
                                  pa_debug.g_err_stage := 'Action status is not valid for the control item status.';
                                  pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                             end if;
                             l_any_err_occured_flg := 'Y';
                       else
                             x_action_tbl(i).action_status := l_action_status_code;
                       end if;--if( (l_ci_status_code = 'CI_APPROVED' or l_ci_status_code = 'CI_CANCELED' or l_ci_status_code
                       close act_sts_allw_for_ci_sts;
                   end if;--if(act_sts_allw_for_ci_sts%notfound) then

                   close chk_action_status_code;
                end if;--if(chk_action_status_code%notfound) then
             else --if(l_action_tbl(i).action_status is not null) then
             /*action status is not passed. Raise the error msg.*/
             /* we can also default the action status to open if no status is passed. need to crosscheck this*/
                 pa_utils.add_message(p_app_short_name  => 'PA',
                                      p_msg_name        => 'PA_CI_MISS_ACT_CI_STS',
                                      p_token1          => 'NUMBER',
                                      p_value1          =>  i);
                 if (l_debug_mode = 'Y') then
                      pa_debug.g_err_stage := 'Action status code is missing.';
                      pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                 end if;
                 l_any_err_occured_flg := 'Y';
             end if;--if(l_action_tbl(i).action_status is not null) then

             /* signed_off  flag can only be Y or N. so when it is passed Y setting it to Y else
               setting it to N explicitly.although the varibale has been set to default value of N.
               Explicit initialization is must because we are not validating this flag for a value other than Y or N*/
             if(l_action_tbl(i).signed_off is not null and l_action_tbl(i).signed_off = 'Y') then
                  x_action_tbl(i).signed_off  := l_action_tbl(i).signed_off;
             else
                  x_action_tbl(i).signed_off  := 'N';
             end if;

             /* start_wf  flag can only be Y or N. so when it is passed Y setting it to Y else
               setting it to N explicitly.although the varibale has been set to default value of N.
               Explicit initialization is must because we are not validating this flag for a value other than Y or N*/
             if(l_action_tbl(i).start_wf is not null and l_action_tbl(i).start_wf = 'Y') then
                  x_action_tbl(i).start_wf  := l_action_tbl(i).start_wf;
             else
                  x_action_tbl(i).start_wf  := 'N';
             end if;

              /*Validate the source_ci_action_id*/
             if(l_action_tbl(i).source_ci_action_id is not null) then
                  open check_valid_src_ci_action_id(l_action_tbl(i).source_ci_action_id);
                  fetch check_valid_src_ci_action_id into chk_valid_src_ci_action_id_rec;
                  if(check_valid_src_ci_action_id%notfound) then
                     pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_INV_SRC_CI_ID',
                                          p_token1          => 'NUMBER',
                                          p_value1          =>  i);
                     if (l_debug_mode = 'Y') then
                          pa_debug.g_err_stage := 'source_ci_action_id is invalid';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     end if;
                     l_any_err_occured_flg := 'Y';
                     close check_valid_src_ci_action_id;
                  else
                      /*here the source_ci_action_id ia valid id*/
                      /*we need to validate that the source_ci_action_id shd be closed action always. source action cannot be open/canceled*/
                      if (chk_valid_src_ci_action_id_rec.status_code = 'CI_ACTION_CLOSED') then
                          x_action_tbl(i).source_ci_action_id := chk_valid_src_ci_action_id_rec.ci_action_id; --l_src_ci_action_id;
                          close check_valid_src_ci_action_id;
                      else
                          /*source_ci_action is not closed. Raise error msg that the source action shd always be closed*/
                          pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_INV_SRC_CI_ID_STS',
                                          p_token1          => 'NUMBER',
                                          p_value1          =>  i);
                          if (l_debug_mode = 'Y') then
                                pa_debug.g_err_stage := 'source_ci_action_id can only be a closed action';
                                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                          end if;
                          l_any_err_occured_flg := 'Y';
                          close check_valid_src_ci_action_id;
                      end if;
                  end if;
             else --if(l_action_tbl(i).source_ci_action_id is not null) then
                 /*if source_ci_action_id is passed*/
                 x_action_tbl(i).source_ci_action_id := null;
             end if;--if(l_action_tbl(i).source_ci_action_id is not null) then

             /*Validate the date_closed. This is a must for closed/canceled actions*/
            if( (l_action_status_code = 'CI_ACTION_CLOSED'or l_action_status_code = 'CI_ACTION_CANCELED') ) then
                 if (l_action_tbl(i).closed_date is null)  then
                     pa_utils.add_message(p_app_short_name  => 'PA',
                                          p_msg_name        => 'PA_CI_MISS_DATE_FOR_ACT_CODE',
                                          p_token1          => 'NUMBER',
                                          p_value1          =>  i);
                     if (l_debug_mode = 'Y') then
                          pa_debug.g_err_stage := 'closed_date is missing for a closed/canceled action';
                          pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                     end if;
                     l_any_err_occured_flg := 'Y';
                 else --(l_action_tbl(i).closed_date is null)  then
                      x_action_tbl(i).closed_date := l_action_tbl(i).closed_date;
                 end if;
             else --if( (l_action_status_code = 'CI_ACTION_CLOSED'or l_action_status_code = 'CI_ACTION_CANCELED') ) then
             /*for open actions ignore this date*/
                 x_action_tbl(i).closed_date := null;
             end if;

      end loop;--For i in 1..p_action_tbl.count

  end if;--  if(p_action_tbl.count > 0) then

  if( l_any_err_occured_flg is not null and l_any_err_occured_flg = 'Y' ) then
     raise fnd_api.g_exc_error;
  end if;
--reset the err stack
  if l_debug_mode = 'Y' then
     pa_debug.reset_curr_function;
  end if;

Exception
  when fnd_api.g_exc_error then
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
         /*Not initializing the out table of records to null as it wont be used in the calling API if exception occurs*/
         /* no in/out paramters to be set to their initial values here*/
        --reset the err stack
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;
       --raise the exception
       raise;
  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'validate_action_attributes',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
         /*Not initializing the out table of records to null as it wont be used in the calling API if exception occurs*/
         /* no in/out paramters to be set to their initial values here*/
        --reset the err stack
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;
         --raise the exception
         raise;
END validate_action_attributes;

procedure create_action(
                        p_action_tbl              IN  pa_control_api_pub.ci_actions_in_tbl_type
                       ,p_ci_id                   IN NUMBER := null
                       ,x_action_tbl              OUT NOCOPY pa_control_api_pub.ci_actions_out_tbl_type
                       ,x_return_status           OUT NOCOPY VARCHAR2
                       ,x_msg_count               OUT NOCOPY NUMBER
                       ,x_msg_data                OUT NOCOPY VARCHAR2
                       )
IS

  Cursor getRecordVersionNumber(p_ci_id number)
  is
  select record_version_number
  from pa_control_items
  where ci_id = p_ci_id;


  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_any_err_occured_flg                    VARCHAR2(1);
  l_action_number                          pa_ci_actions.ci_action_number%type;
  l_ci_comment_id                          pa_ci_comments.ci_comment_id%type;
  l_type_code                              pa_ci_comments.type_code%type;
  l_ci_action_id                           pa_ci_actions.ci_action_id%type;
  l_ci_record_version_number               pa_control_items.record_version_number%type;
  l_process_name                           varchar(100);
  l_item_key                               pa_wf_processes.item_key%TYPE;
  l_num_of_actions                         number;
  l_num_open_action                        pa_control_items.open_action_num%type;
BEGIN
  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'create_action' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pvt.create_action', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of create_action', l_debug_level3);
  end if;


--Setting this flag to N initially.
  l_any_err_occured_flg := 'N';

  /*get the record version number for the control item*/
  OPEN getRecordVersionNumber(p_ci_id);
  FETCH getRecordVersionNumber into l_ci_record_version_number;
  CLOSE getRecordVersionNumber;

  /* initalizing the number of open action to zero outside the loop here
     this number would be incremented by one each time for every open action inside the loop*/
  l_num_open_action := 0;

  For i in 1..p_action_tbl.count
  loop
        /*get the action number*/
        if (p_ci_id IS NOT NULL) then
             l_action_number := PA_CI_ACTIONS_UTIL.get_next_ci_action_number(p_ci_id);
        end if;

        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'calling insert row to create the action';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

         /*insert row in pa_ci_actions*/
        pa_ci_actions_pkg.insert_row(
                        p_ci_action_id             => l_ci_action_id,  -- this is out paramter
                        p_ci_id                    => p_ci_id,
                        p_ci_action_number         => l_action_number,
                        p_status_code              => p_action_tbl(i).action_status,
                        p_type_code                => p_action_tbl(i).action_type_code,
                        p_assigned_to              => p_action_tbl(i).assignee_id,
                        p_date_required            => p_action_tbl(i).date_required,
                        p_sign_off_required_flag   => p_action_tbl(i).sign_off_requested_flag,
                        p_date_closed              => p_action_tbl(i).closed_date,
                        p_sign_off_flag            => p_action_tbl(i).signed_off,
                        p_source_ci_action_id      => p_action_tbl(i).source_ci_action_id,
                        p_last_updated_by          => fnd_global.user_id,
                        p_created_by               => fnd_global.user_id,
                        p_creation_date            => sysdate,
                        p_last_update_date         => sysdate,
                        p_last_update_login        => fnd_global.login_id, --this shd not be user_id.
                        p_record_version_number    => 1);

         /* now prepare the output table to store the output values*/
        x_action_tbl(i).action_id         := l_ci_action_id;
        x_action_tbl(i).action_number     := l_action_number;

       /*set the type_code for the pa_ci_comments table before inserting comment in it*/
       if(p_action_tbl(i).action_status = 'CI_ACTION_CLOSED' or p_action_tbl(i).action_status = 'CI_ACTION_CANCELED') then
          l_type_code := 'CLOSURE';
       elsif(p_action_tbl(i).action_status = 'CI_ACTION_OPEN') then
          l_type_code := 'REQUESTOR';
       end if;

        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'Inserting the comment for the action.';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;

         /*now call the add comment api*/
       pa_ci_comments_pkg.insert_row(
                p_ci_comment_id             => l_ci_comment_id,
                p_ci_id                     => p_ci_id,
                p_type_code                 => l_type_code,
                p_comment_text              => p_action_tbl(i).request_text,
                p_last_updated_by           => fnd_global.user_id,
                p_created_by                => fnd_global.user_id,
                p_creation_date             => sysdate,
                p_last_update_date          => sysdate,
                p_last_update_login         => fnd_global.login_id, --this shd not be user_id
                p_ci_action_id              => l_ci_action_id);


        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'Updating number of actions for a control item';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
         /*now update the number of actions in pa_control_items_table   */
         if(p_action_tbl(i).action_status = 'CI_ACTION_OPEN') then
            l_num_open_action := l_num_open_action + 1;
         end if;

/*         pa_control_items_pvt.update_number_of_actions (
                            p_ci_id                     => p_ci_id,
                            p_num_of_actions            => 1,
                            p_record_version_number     => l_ci_record_version_number,
                            x_num_of_actions            => l_num_of_actions,
                            x_return_status             => x_return_status,
                            x_msg_count                 => x_msg_count,
                            x_msg_data                  => x_msg_data);*/

         if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
             l_any_err_occured_flg := 'Y';
         end if;

        if l_debug_mode = 'Y' then
              pa_debug.g_err_stage := 'calling insert row to create the action';
              pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
        end if;
                 /*start the workflow notification only if start_wf flag is Y*/
       if(p_action_tbl(i).start_wf = 'Y') then
            if(p_action_tbl(i).action_status = 'CI_ACTION_OPEN') then
              -- Depending upon Sign-off required different processes have been created in the PA Issue and Change Action Workflow
                    if (p_action_tbl(i).sign_off_requested_flag = 'Y' )then
                        l_process_name := 'PA_CI_ACTION_ASMT_SIGN_OFF';
                    else
                        l_process_name := 'PA_CI_ACTION_ASMT_NO_SIGN_OFF';
                    end if;

                    pa_control_items_workflow.start_notification_wf
                          (  p_item_type        => 'PAWFCIAC'
                            ,p_process_name     => l_process_name
                            ,p_ci_id            => p_ci_id
                            ,p_action_id        => l_ci_action_id
                            ,x_item_key         => l_item_key
                            ,x_return_status    => x_return_status
                            ,x_msg_count        => x_msg_count
                            ,x_msg_data         => x_msg_data );

                         if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                             l_any_err_occured_flg := 'Y';
                         end if;

            elsif( p_action_tbl(i).action_status = 'CI_ACTION_CLOSED') then
            /*need to check if we should send the notification while creating closed actions*/
            /*Most likely we shd not be sending this. Can be commented later*/
                  pa_control_items_workflow.start_notification_wf
                          (  p_item_type                => 'PAWFCIAC'
                            ,p_process_name             => 'PA_CI_ACTION_CLOSE_FYI'
                            ,p_ci_id                    => p_ci_id
                            ,p_action_id                => l_ci_action_id
                            ,x_item_key                 => l_item_key
                            ,x_return_status            => x_return_status
                            ,x_msg_count                => x_msg_count
                            ,x_msg_data                 => x_msg_data );
                         if(x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                             l_any_err_occured_flg := 'Y';
                         end if;
            end if;--            if(p_action_tbl(i).action_status = 'CI_ACTION_OPEN') then
       end if;--(p_action_tbl(i).start_wf = 'Y')

  end loop;--  For i in 1..p_action_tbl.count

  --if there were any open actions update the no of open action in pa_control_items
  --this has to be done outside the loop only once for all the open actions in table.
  if(l_num_open_action is not null and l_num_open_action > 0 ) then
         pa_control_items_pvt.update_number_of_actions (
                            p_ci_id                     => p_ci_id,
                            p_num_of_actions            => l_num_open_action,
                            p_record_version_number     => l_ci_record_version_number,
                            x_num_of_actions            => l_num_of_actions,
                            x_return_status             => x_return_status,
                            x_msg_count                 => x_msg_count,
                            x_msg_data                  => x_msg_data);
  end if;

  if( l_any_err_occured_flg is not null and l_any_err_occured_flg = 'Y' ) then
     raise fnd_api.g_exc_unexpected_error;
  end if;

  --reset the err stack
  if l_debug_mode = 'Y' then
     pa_debug.reset_curr_function;
  end if;

Exception
  When fnd_api.g_exc_unexpected_error then

            x_return_status := fnd_api.g_ret_sts_unexp_error;
            --do a rollback;
            FND_MSG_PUB.Count_And_Get(
                                      p_count     =>  x_msg_count ,
                                      p_data      =>  x_msg_data  );

         /*Not initializing the out table of records to null as it wont be used in the calling API if exception occurs*/
         /* no in/out paramters to be set to their initial values here*/
        --reset the err stack
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;
         --raise the exception;
         raise;
  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'create_action',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);
         /*Not initializing the out table of records to null as it wont be used in the calling API if exception occurs*/
         /* no in/out paramters to be set to their initial values here*/
        --reset the err stack
        if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
        end if;
         --raise the exception
         raise;

END create_action;

procedure validate_priv_and_action(
                                    p_ci_id                   IN NUMBER
                                   ,p_action_id               IN NUMBER
                                   ,p_action_number           IN NUMBER
                                   ,x_action_id               OUT NOCOPY NUMBER
                                   ,x_assignee_id             OUT NOCOPY NUMBER
                                   ,x_project_id              OUT NOCOPY NUMBER
                                   ,x_return_status           OUT NOCOPY VARCHAR2
                                   ,x_msg_count               OUT NOCOPY NUMBER
                                   ,x_msg_data                OUT NOCOPY VARCHAR2
                                   )
is

cursor get_ci_action_id(p_ci_id number, p_action_number number)
is
select pca.ci_action_id, pca.assigned_to, pci.project_id
from pa_ci_actions pca,
     pa_control_items pci
where pca.ci_id = p_ci_id
and   pca.ci_action_number = p_action_number
and   pci.ci_id = p_ci_id;

cursor validate_ci_action_id(p_action_id number)
is
select pca.ci_action_id, pca.assigned_to, pci.project_id
from pa_ci_actions pca,
     pa_control_items pci
where pca.ci_action_id = p_action_id
and   pci.ci_id = pca.ci_id;

  l_validate_ci_action_id_rec              validate_ci_action_id%rowtype;
  l_get_ci_action_id_rec                   get_ci_action_id%rowtype;

  l_msg_count                              NUMBER := 0;
  l_data                                   VARCHAR2(2000);
  l_msg_data                               VARCHAR2(2000);
  l_msg_index_out                          NUMBER;
  l_module_name                            VARCHAR2(200);
  l_any_err_occured_flg                    VARCHAR2(1);


begin
  -- initialize the return status to success
  x_return_status := fnd_api.g_ret_sts_success;
  x_msg_count := 0;

  l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
  l_module_name :=  'validate_priv_and_action' || g_module_name;

  if l_debug_mode = 'Y' then
          pa_debug.set_curr_function(p_function => 'pa_control_api_pub.validate_priv_and_action', p_debug_mode => l_debug_mode);
  end if;

  if l_debug_mode = 'Y' then
          pa_debug.write(l_module_name, 'start of validate_priv_and_action', l_debug_level3);
  end if;

--Setting this flag to N initially.
  l_any_err_occured_flg := 'N';

  /*check if the action_id, action_number, ci_id all three are missing*/
  if( (p_ci_id is null or p_ci_id  = G_PA_MISS_NUM) AND
      (p_action_id is null or p_action_id = G_PA_MISS_NUM) AND
      (p_action_number is null or p_action_number = G_PA_MISS_NUM)
    ) then
         pa_utils.add_message(p_app_short_name    => 'PA',
                              p_msg_name          => 'PA_CI_MISS_CIID_ACTID_ACTNUM');
           if (l_debug_mode = 'Y') then
                pa_debug.g_err_stage := 'all three action_id, ci_id, action_number cannot be missing';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           /*raise the exception*/
           raise fnd_api.g_exc_error;
  end if;--  if( (p_ci_id is null or p_ci_id is = G_PA_MISS_NUM) AND

  if (p_action_id is null or p_action_id = G_PA_MISS_NUM) then

    /*here action_id is missing. So check if we can derive action_id from ci_id and action_number.*/
      if( (p_ci_id is not null and p_ci_id <> G_PA_MISS_NUM) AND
          (p_action_number is not null and p_action_number <> G_PA_MISS_NUM)
        ) then
           /*derive the ci_action_id*/
           open  get_ci_action_id(p_ci_id, p_action_number);
           fetch get_ci_action_id into l_get_ci_action_id_rec;
           if(get_ci_action_id%notfound) then
           /*ci_id and action_number combination is invalid.raise the error message.*/
                pa_utils.add_message(p_app_short_name    => 'PA',
                                     p_msg_name          => 'PA_CI_INV_CIID_ACTNUM');
                if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'there is no action for passed action_number and ci_id';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                close get_ci_action_id;
                raise fnd_api.g_exc_error;
           else--if(get_ci_action_id%notfound) then
                x_assignee_id := l_get_ci_action_id_rec.assigned_to;
                x_action_id   := l_get_ci_action_id_rec.ci_action_id;
                x_project_id  := l_get_ci_action_id_rec.project_id;
                close get_ci_action_id;
           end if; --if(get_ci_action_id%notfound) then
      else--if( (p_ci_id is not null and p_ci_id <> G_PA_MISS_NUM) AND
      /*one or both   p_ci_id, p_action_number is missing here.*/
           pa_utils.add_message(p_app_short_name    => 'PA',
                                p_msg_name          => 'PA_CI_INV_CIID_ACTNUM');
           if (l_debug_mode = 'Y') then
                pa_debug.g_err_stage := 'one or both ci_id or action_number is missing';
                pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
           end if;
           raise fnd_api.g_exc_error;
      end if;--if( (p_ci_id is not null and p_ci_id <> G_PA_MISS_NUM) AND

  else --if (p_action_id is null or p_action_id is G_PA_MISS_NUM) then
  /*user has passed a value for action_id. Validate this value here.*/
      open validate_ci_action_id(p_action_id);
      fetch validate_ci_action_id into l_validate_ci_action_id_rec;
           if(validate_ci_action_id%notfound) then
               /*incorrect p_action_id is passed. there is no record for this action id*/
                pa_utils.add_message(p_app_short_name    => 'PA',
                                     p_msg_name          => 'PA_CI_INV_ACT_ID');
                if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'invalid action_id passed';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                close validate_ci_action_id;
                raise fnd_api.g_exc_error;
           else--if(validate_ci_action_id%notfound) then
               x_assignee_id := l_validate_ci_action_id_rec.assigned_to;
               x_action_id   := l_validate_ci_action_id_rec.ci_action_id;
               x_project_id  := l_validate_ci_action_id_rec.project_id;
               close validate_ci_action_id;
           end if; --if(validate_ci_action_id%notfound) then

  end if; -- if (p_action_id is null or p_action_id is G_PA_MISS_NUM)

 --reset the error stack;
  if l_debug_mode = 'Y' then
           pa_debug.reset_curr_function;
  end if;

  --do the exception handling;
exception
  when fnd_api.g_exc_error then
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

         /*Initialize the out variables back to null*/
          x_action_id := null;
          x_assignee_id :=  null;
          x_project_id :=  null;
         --no in out parameters to set to their initial values.

          --reset the error stack;
          if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
          end if;
         --raise the exception
         raise;
  when others then
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'pa_control_api_pvt',
                                 p_procedure_name => 'validate_priv_and_action',
                                 p_error_text     => substrb(sqlerrm,1,240));
         fnd_msg_pub.count_and_get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

         /*Initialize the out variables back to null*/
          x_action_id := null;
          x_assignee_id :=  null;
          x_project_id :=  null;
         --no inout parameters to set to their initial values.

          --reset the error stack;
          if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
          end if;
         --raise the exception
         raise;

end validate_priv_and_action;



Procedure Delete_CI (
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
        l_StatusCode            VARCHAR2(30);
        l_ProjectId             NUMBER(15);
        l_CiTypeClassCode       VARCHAR2(30);
        l_RecordVersionNumber   NUMBER(15);

        l_ViewAccess            VARCHAR2(1);
        l_DeleteAllowed         VARCHAR2(1);

	l_module_name           VARCHAR2(200);
        l_Msg_Count             NUMBER := 0;
        l_Data                  VARCHAR2(2000);
        l_Msg_Data              VARCHAR2(2000);
        l_Msg_Index_Out         NUMBER;
        l_CiId                  PA_CONTROL_ITEMS.Ci_Id%TYPE;
        -- End: Local Variables.
BEGIN
	l_debug_mode  := NVL(FND_PROFILE.VALUE_SPECIFIC('PA_DEBUG_MODE', fnd_global.user_id, fnd_global.resp_id, 275, null, null), 'N');
	l_module_name :=  'Delete_CI' || g_module_name;

	 if l_debug_mode = 'Y' then
		  pa_debug.set_curr_function(p_function => 'pa_control_api_pub.Delete_CI', p_debug_mode => l_debug_mode);
	  end if;

	  if l_debug_mode = 'Y' then
		  pa_debug.write(l_module_name, 'start of Delete_CI', l_debug_level3);
	  end if;
        -- Initialize the Error Stack.
        --PA_DEBUG.Init_Err_Stack ('PA_CONTROL_API_PVT.Delete_CI');

        -- Initialize the Return Status to Success.
        x_Return_Status := FND_API.g_Ret_Sts_Success;
        x_Msg_Count := 0;

        -- Clear the Global PL/SQL Message table.
        IF (FND_API.To_Boolean (p_Init_Msg_List)) THEN
                FND_MSG_PUB.Initialize;
        END IF;

        -- If the Ci_Id that is passed in is NULL then report
        -- Error.
        IF (p_Ci_Id IS NULL) THEN
                -- Add message to the Error Stack that Ci_Id is NULL.
                PA_UTILS.Add_Message (
                        p_App_Short_Name => 'PA'
                        , p_Msg_Name => 'PA_CI_MISS_CI_ID'
                        );
		if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'CI_ID is not passed';
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
		if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'invalid ci_id passed';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;
        CLOSE Check_Valid_CI;

        -- Open Cursor Get_CI_Data and Fetch the data into our local variables.
        OPEN Get_CI_Data (p_Ci_Id);
        FETCH Get_CI_Data INTO l_ProjectId, l_StatusCode, l_CiTypeClassCode, l_RecordVersionNumber;

        -- If NO_DATA_FOUND then report Error.
        IF (Get_CI_Data%NOTFOUND) THEN
                -- Code to Report Error.
                CLOSE Get_CI_Data;
		if (l_debug_mode = 'Y') then
                     pa_debug.g_err_stage := 'No data found in Get_CI_Data';
                     pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
                end if;
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
                -- If the User has View Access to this Control Item and
                -- delete is allowed on this Control Item then call the
                -- API to delete it.
                l_ViewAccess := PA_CI_SECURITY_PKG.Check_View_Access (p_Ci_Id, l_ProjectId, l_StatusCode, l_CiTypeClassCode);
                l_DeleteAllowed := PA_CONTROL_ITEMS_UTILS.CheckCIActionAllowed ('CONTROL_ITEM', l_StatusCode, 'CONTROL_ITEM_ALLOW_DELETE', p_Ci_Id);
                IF (l_ViewAccess = 'T' AND l_DeleteAllowed = 'Y') THEN
			if (l_debug_mode = 'Y') then
				pa_debug.g_err_stage := 'Before Calling PA_CONTROL_ITEMS_PUB.Delete_Control_Item';
				pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
			end if;
                        PA_CONTROL_ITEMS_PUB.Delete_Control_Item (
                                                p_Api_Version                   => p_Api_Version_Number
                                                , p_Init_Msg_List               => 'F'
                                                , p_Commit                      => p_Commit
                                                , p_Validate_Only               => 'F'
                                                , p_Ci_Id                       => p_Ci_Id
                                                , p_Record_Version_Number       => l_RecordVersionNumber
                                                , x_Return_Status               => x_Return_Status
                                                , x_Msg_Count                   => x_Msg_Count
                                                , x_Msg_Data                    => x_Msg_Data
                                                );
                ELSE
                        -- Check if View Access was denied or not.
                        IF (l_ViewAccess <> 'T') THEN
                                -- Add message to the Error Stack that the user does not
                                -- have the privilege to delete this Control Item.
                                PA_UTILS.Add_Message (
                                        p_App_Short_Name => 'PA'
                                        , p_Msg_Name => 'PA_CI_NO_ALLOW_DELETE'
                                        );
				if (l_debug_mode = 'Y') then
					pa_debug.g_err_stage := 'User does  not have the privilege to delete this Control Item';
					pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
				end if;
                        END IF;

                        -- Check if delete was denied by Status Control or not.
                        IF (l_DeleteAllowed <> 'Y') THEN
                                -- Add message to the Error Stack that this Control Item
                                -- cannot be deleted in its present status.
                                PA_UTILS.Add_Message (
                                        p_App_Short_Name => 'PA'
                                        , p_Msg_Name => 'PA_CI_DELETE_NOT_ALLOWED'
                                        );
				if (l_debug_mode = 'Y') then
					pa_debug.g_err_stage := 'This control item cannot be deleted in its present status';
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
		if (l_debug_mode = 'Y') then
			pa_debug.g_err_stage := 'CI_ID has workflow Attached';
			pa_debug.write(l_module_name,pa_debug.g_err_stage,l_debug_level3);
		end if;
                -- Raise the Invalid Argument exception.
                RAISE FND_API.G_EXC_ERROR;
        END IF;

         --reset the error stack;
          if l_debug_mode = 'Y' then
              pa_debug.reset_curr_function;
          end if;
        -- If any exception then catch it.
        EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
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

                 --reset the error stack;
		 if l_debug_mode = 'Y' then
			 pa_debug.reset_curr_function;
		end if;

                -- Raise the Exception.
                RAISE;

        WHEN OTHERS THEN
                -- Set the Return Status as Error.
                x_Return_Status := FND_API.g_Ret_Sts_Unexp_Error;

                -- Add the message that is reported in SQL Error.
                FND_MSG_PUB.Add_Exc_Msg (
                        p_Pkg_Name       => 'PA_CONTROL_API_PVT',
                        p_Procedure_Name => 'Delete_CI',
                        p_Error_Text     => SUBSTRB (sqlerrm, 1, 240)
                        );

                FND_MSG_PUB.Count_And_Get (
                        p_Count => x_Msg_Count,
                        p_Data  => x_Msg_Data
                        );

                 --reset the error stack;
		if l_debug_mode = 'Y' then
			 pa_debug.reset_curr_function;
		end if;

                -- Raise the Exception.
                RAISE;
END Delete_CI;


END PA_CONTROL_API_PVT;

/
