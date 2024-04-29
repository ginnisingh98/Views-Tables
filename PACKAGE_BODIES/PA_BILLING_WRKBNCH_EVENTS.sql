--------------------------------------------------------
--  DDL for Package Body PA_BILLING_WRKBNCH_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_BILLING_WRKBNCH_EVENTS" as
/* $Header: PABWBCHB.pls 120.2.12010000.2 2010/02/24 05:35:24 dbudhwar ship $ */

/*----------------- Private Procedure/Function Declarations -----------------*/

/*----------------------------------------------------------------------------+
 | This Private Procedure Get_Next_Event_Num gets the maximum event num + 1   |
 | for the project and task.                                                  |
 +----------------------------------------------------------------------------*/
  Procedure Get_Next_Event_Num ( P_Project_ID         IN  NUMBER,
                                 P_Task_ID            IN  NUMBER,
                                 X_Event_Num          OUT NOCOPY NUMBER ) AS --File.Sql.39 bug 4440895

	Cursor c_Event_Num_Project Is
	select nvl(max(event_num), 0) + 1 from pa_events
	where project_id = P_Project_ID
	  and task_id is null;

	Cursor c_Event_Num_Task  Is
	select nvl(max(event_num), 0) + 1 from pa_events
	where project_id = P_Project_ID
	  and task_id = P_Task_ID;
  BEGIN

       If nvl(P_Task_Id, 0) <= 0 Then
          Open c_Event_Num_Project;
          Fetch c_Event_Num_Project Into X_Event_Num;
          Close c_Event_Num_Project;
       Else
          Open c_Event_Num_Task;
          Fetch c_Event_Num_Task Into X_Event_Num;
          Close c_Event_Num_Task;
       End If;


  EXCEPTION
    WHEN OTHERS THEN
      /* ATG NOCOPY */
      X_Event_Num := null;
      RAISE;
  END Get_Next_Event_Num;


/*----------------------------------------------------------------------------+
 | This Private Procedure Check_Create_Update_Event validates the funding lvl |
 | and also if the event number is unique or not.                             |
 +----------------------------------------------------------------------------*/

  Procedure       Check_Event_Action  ( P_Project_Id     IN  NUMBER,
                                        P_Task_ID        IN  NUMBER,
                                        P_Event_Num      IN  NUMBER,
                                        P_Event_Id       IN  NUMBER,
                                        P_Event_Action   IN  VARCHAR2,
                                        P_Action_Name    IN  VARCHAR2,
                                        P_Init_Msg_List  IN  VARCHAR2,
                                        P_Event_Num_Chg  IN  VARCHAR2,
                                        P_Rec_Ver_Num    IN  NUMBER,
                                        P_Mcb_Enabled_Flag    IN  VARCHAR2,
                                        P_Pfc_Rate_Date_Code    IN  VARCHAR2,
                                        P_Pc_Rate_Date_Code    IN  VARCHAR2,
                                        P_Fc_Rate_Date_Code    IN  VARCHAR2,
                                        P_Projfunc_Curr_Code    IN  VARCHAR2,
                                        P_Project_Curr_Code    IN  VARCHAR2,
                                        P_Bill_Trans_Curr_Code    IN  VARCHAR2,
                                        P_Pfc_Rate_Type    IN  VARCHAR2,
                                        P_Pc_Rate_Type    IN  VARCHAR2,
                                        P_Fc_Rate_Type    IN  VARCHAR2,
                                        P_Pfc_Rate_Date    IN  DATE,
                                        P_Pc_Rate_Date    IN  DATE,
                                        P_Fc_Rate_Date    IN  DATE,
                                        P_Pfc_Excg_Rate    IN  NUMBER,
                                        P_Pc_Excg_Rate    IN  NUMBER,
                                        P_Fc_Excg_Rate    IN  NUMBER,
                                        P_Event_Type      IN  VARCHAR2,
                                        P_Bill_Txn_Cur    IN  VARCHAR2,
                                        P_Invoice_Amt     IN  NUMBER,
                                        P_Revenue_Amt     IN  NUMBER,
                                        P_Event_Org       IN  NUMBER,
                                        X_Msg_Data        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        X_Msg_Count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        X_Return_Status   OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

  Invalid_event_action exception; /* Added for bug 3850381 */
  l_return_status varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_err_message varchar2(240) := null;
  l_event_processed varchar2(1) := 'Y';
  l_rec_ver_num pa_events.record_version_number%type;
  /* Added for bug 3850381 */
  l_msg_count                  NUMBER := 0;
  l_data                       VARCHAR2(2000) := null;
  l_msg_data                   VARCHAR2(2000) := null;
  l_msg_index_out              NUMBER := 0;

  BEGIN

       X_Return_Status := FND_API.G_RET_STS_SUCCESS;

       IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
            FND_MSG_PUB.initialize;
       END IF;

       If P_Event_Action = 'Delete'
       Then
               l_event_processed :=PA_EVENT_UTILS.CHECK_EVENT_PROCESSED
                                 (P_event_id             => P_Event_Id );

               If l_event_processed <> 'Y'
               Then
		   x_return_status := FND_API.G_RET_STS_ERROR;
                   l_err_message :=  FND_MESSAGE.GET_STRING('PA', 'PA_TK_EVENT_IN_USE');
		   PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
               End If;

       Else

               /* Added for bug 3935772 */
	       If P_Event_Type is null
	       Then
		  x_return_status := FND_API.G_RET_STS_ERROR;
		    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_NO_EVENT_TYPE');
		    PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
	       End If;

	       If P_Bill_Txn_Cur is null
	       Then
		  x_return_status := FND_API.G_RET_STS_ERROR;
		    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_BIL_TRX_CUR_AMG');
		    PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
	       End If;

	       If P_Invoice_Amt is null
	       Then
		  x_return_status := FND_API.G_RET_STS_ERROR;
		    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_INV_AMT');
		    PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
	       End If;

	       If P_Revenue_Amt is null
	       Then
		  x_return_status := FND_API.G_RET_STS_ERROR;
		    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_REV_AMT');
		    PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
	       End If;

	       If P_Event_Org is null
	       Then
		  x_return_status := FND_API.G_RET_STS_ERROR;
		    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_EVNT_ORG_AMG');
		    PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
	       End If;

	       IF X_Return_Status <> FND_API.G_RET_STS_SUCCESS
	       THEN
		    raise Invalid_event_action;
	       END IF;

               /* End of changes for bug 3935772 */

	       If PA_EVENT_CORE.CHECK_FUNDING ( P_Project_Id,
						P_Task_Id ) = 'N'
	       Then
		  x_return_status := FND_API.G_RET_STS_ERROR;
		    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_TASK_FUND_NO_PROJ_EVENT_AMG');
		    PA_UTILS.ADD_MESSAGE
			     ( p_app_short_name => 'PA',
			       p_msg_name       => 'PA_ACTION_NAME_ERR',
			       p_token1         => 'ACTION_NAME',
			       p_value1         =>  P_Action_Name,
			       p_token2         => 'MESSAGE',
			       p_value2         =>  l_Err_Message);
	       End If;


		If P_Event_Num_Chg = 'Y'
		Then
		       If PA_EVENT_CORE.CHECK_VALID_EVENT_NUM( P_Project_Id,
							       P_Task_Id,
							       P_Event_Num) = 'N'
		       Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INV_EVNT_NUM_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
		       End If;
		End If;

                IF (P_Mcb_Enabled_Flag = 'Y' )
                Then
                    If  p_Bill_Trans_Curr_Code <> p_Projfunc_Curr_Code
                    Then

                        If (p_Pfc_Rate_Date_Code = 'FIXED_DATE' and p_Pfc_Rate_Type <> 'User' and p_Pfc_Rate_Date is null)
                        Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_PROJFUNC_DATE_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
                        End If;

                        If (p_Pfc_Rate_Type = 'User' and nvl(p_Pfc_Excg_Rate, 0) <= 0)
                        Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_EXCH_RATE_NULL_PF_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
                        End If;

                    End If;

                    If  (p_Bill_Trans_Curr_Code <> p_Project_Curr_Code and p_Project_Curr_Code <> p_Projfunc_Curr_Code)
                    Then

                        If (p_Pc_Rate_Date_Code = 'FIXED_DATE' and p_Pc_Rate_Type <> 'User' and p_Pc_Rate_Date is null)
                        Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_PROJ_DATE_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
                        End If;

                        If (p_Pc_Rate_Type = 'User' and nvl(p_Pc_Excg_Rate, 0) <= 0 )
                        Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_EXCH_RATE_NULL_PC_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
                        End If;

                    End If;

                    If (p_Fc_Rate_Date_Code = 'FIXED_DATE' and p_Fc_Rate_Type <> 'User' and p_Fc_Rate_Date is null)
                    Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_INVALID_FUND_DATE_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
                    End If;

                    If ( p_Fc_Rate_Type = 'User' and nvl(p_Fc_Excg_Rate, 0) <= 0 )
                    Then
			  x_return_status := FND_API.G_RET_STS_ERROR;
			    l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_FUND_EXCG_RATE_INV_AMG');
			    PA_UTILS.ADD_MESSAGE
				     ( p_app_short_name => 'PA',
				       p_msg_name       => 'PA_ACTION_NAME_ERR',
				       p_token1         => 'ACTION_NAME',
				       p_value1         =>  P_Action_Name,
				       p_token2         => 'MESSAGE',
				       p_value2         =>  l_Err_Message);
                    End If;

                End If;


                If P_Event_Action = 'Update'
                Then
                    Begin
                          select record_version_number
                            into l_rec_ver_num
                            from pa_events
                           where event_id = p_event_id;

                           If l_rec_ver_num <> p_rec_ver_num
                            Then
				  x_return_status := FND_API.G_RET_STS_ERROR;
                                l_err_message :=  FND_MESSAGE.GET_STRING('PA','PA_XC_RECORD_CHANGED');
                                PA_UTILS.ADD_MESSAGE
                                     ( p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_ACTION_NAME_ERR',
                                       p_token1         => 'ACTION_NAME',
                                       p_value1         =>  P_Action_Name,
                                       p_token2         => 'MESSAGE',
                                       p_value2         =>  l_Err_Message);
                          End If;
                    Exception When others then
                         l_return_status := FND_API.G_RET_STS_ERROR;
                         /*  raise;  */
                    End;
                End If;

       End If;

       IF X_Return_Status <> FND_API.G_RET_STS_SUCCESS
       THEN
            raise Invalid_event_action;
       END IF;

  EXCEPTION
    WHEN Invalid_event_action THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     l_msg_count := FND_MSG_PUB.count_msg;

     IF l_msg_count = 1 THEN
           PA_INTERFACE_UTILS_PUB.get_messages
               (p_encoded        => FND_API.G_TRUE,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out);
           x_msg_data  := l_data;
           x_msg_count := l_msg_count;
     ELSE
            x_msg_count := l_msg_count;
     END IF;
     RETURN;

    WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     FND_MSG_PUB.add_exc_msg( p_pkg_name=> 'PA_BILLING_WRKBNCH_EVENTS'
                     ,p_procedure_name  => 'CHECK_EVENT_ACTION');

      RETURN;
      /*  RAISE;  */
  END Check_Event_Action;

/*----------------------------------------------------------------------------+
 | This Private Function Check_Delv_Event_Processed returns 'Y' if an event   |
 | associated with an action processed else returns 'N'.
 +----------------------------------------------------------------------------*/
  Function  Check_Delv_Event_Processed  ( P_Project_Id     IN  NUMBER,
                                          P_Deliverable_Id IN  NUMBER,
                                          P_Action_Id      IN  NUMBER)
  RETURN VARCHAR2
  IS

  l_return_status varchar2(1) := 'Y';
  l_event_Id  pa_events.event_id%type;

  BEGIN

	SELECT event_id
	  INTO l_event_id
	  FROM pa_events
	 WHERE project_id = P_Project_Id
           AND deliverable_id = P_Deliverable_Id
           AND action_id = P_Action_Id;

	l_return_status :=PA_EVENT_UTILS.CHECK_EVENT_PROCESSED
                            (P_event_id             => l_event_Id );

	IF l_return_status in ('N', 'P', 'C','I','R') /* for bug 9278197 */
	Then
		return 'Y';
	else
		return 'N';
	End If;

  EXCEPTION WHEN OTHERS
  THEN
        return 'N';
  END Check_Delv_Event_Processed;

/*----------------------------------------------------------------------------+
 | This Private Function Check_Delv_Event_Processed returns 'Y' if an event   |
 | associated with an action processed else returns 'N'.
 +----------------------------------------------------------------------------*/
 Procedure Delete_Delv_Event ( P_Project_Id     IN  NUMBER,
                               P_Deliverable_Id IN  NUMBER,
                               P_Action_Id      IN  NUMBER,
                               P_Action_Name    IN  VARCHAR2,
                               X_Return_Status  OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 AS

  l_tmp_return_status varchar2(1) := null;
  l_return_status varchar2(1) := FND_API.G_RET_STS_SUCCESS;
  l_err_message varchar2(240) := null;
  l_tmp_rowid rowid;
  cursor c_rowid is
         select rowid from pa_events
                      where project_id = P_Project_Id
                        and deliverable_id = P_Deliverable_Id
                        and action_id = P_Action_Id;

 BEGIN
        l_tmp_return_status := Check_Delv_Event_Processed ( P_Project_Id
                                                           ,P_Deliverable_Id
                                                           ,P_Action_Id);

        IF l_tmp_return_status = 'Y'
        Then
             l_err_message :=  FND_MESSAGE.GET_STRING('PA', 'PA_TK_EVENT_IN_USE');
                   PA_UTILS.ADD_MESSAGE
                             ( p_app_short_name => 'PA',
                               p_msg_name       => 'PA_TK_EVENT_IN_USE',
                               p_token1         => 'ACTION_NAME',
                               p_value1         =>  P_Action_Name,
                               p_token2         => 'MESSAGE',
                               p_value2         =>  l_Err_Message);
                   l_return_status := FND_API.G_RET_STS_ERROR;
        Else
              open c_rowid;
              fetch c_rowid into l_tmp_rowid;

              if c_rowid%rowcount = 1
              then
                  PA_EVENTS_PKG.Delete_Row (X_RowId => l_tmp_rowid);
              end if;

              close c_rowid;

        End If;
        X_Return_Status := l_return_status;
 EXCEPTION WHEN OTHERS
 THEN
      raise;
 END Delete_Delv_Event;


  Procedure Get_Proj_Carry_Out_Org ( P_Project_ID         IN  NUMBER,
                                     X_Org_ID             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     X_Org_Name           OUT NOCOPY VARCHAR2 ) AS --File.Sql.39 bug 4440895
  Begin

	SELECT to_char(o.organization_id),
               o.name
          INTO X_Org_ID,
               X_Org_Name
          FROM pa_projects p, hr_organization_units o
         WHERE p.carrying_out_organization_id = o.organization_id
           AND p.project_id = P_Project_ID;

  Exception WHEN OTHERS
  THEN
      NULL;
  End Get_Proj_Carry_Out_Org;


Function CHECK_BILLING_EVENT_EXISTS
(
  p_project_id       IN  pa_projects_all.project_id%TYPE,
  p_dlv_element_id   IN  pa_proj_elements.proj_element_id%TYPE
) RETURN VARCHAR2
IS

l_Deliverable_Id pa_events.deliverable_id%TYPE;
l_Dlv_Count  Number := 0;

Begin

	select element_version_id
          into l_Deliverable_Id
	  from pa_proj_element_versions
	 where proj_element_id = p_dlv_element_id
	   and object_type = 'PA_DELIVERABLES'
	   and project_id = p_project_id;

        If nvl(l_Deliverable_Id, 0) > 0 Then

		Select count(*)
		  into l_Dlv_Count
		  from pa_events e
		 where e.project_id = p_project_id
		   and e.deliverable_id = l_deliverable_id;
        End If;

	If nvl(l_Dlv_Count, 0) > 0 Then
	 return('Y');
	Else
	 return('N');
	End If;

Exception when others Then
   return('N');

End CHECK_BILLING_EVENT_EXISTS;


/* Added for bug 3941159 */
Procedure Upd_Event_Comp_Date
(
  P_Deliverable_Id  IN     NUMBER,
  P_Action_Id       IN     NUMBER,
  P_Event_Date      IN     DATE
)
IS
BEGIN
      IF  nvl(P_Deliverable_Id, 0) > 0 AND  nvl(P_Action_Id, 0) > 0
      Then
           Update PA_EVENTS
              set Completion_Date = trunc(P_Event_Date)
            Where deliverable_id = P_Deliverable_Id
              and action_id  = P_Action_Id;
      End If;
EXCEPTION WHEN OTHERS THEN
  null;
END Upd_Event_Comp_Date;

/*------------- End of Public Procedure/Function Declarations ----------------*/

end PA_Billing_Wrkbnch_Events;

/
