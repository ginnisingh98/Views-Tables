--------------------------------------------------------
--  DDL for Package Body PA_UTILS4
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_UTILS4" AS
/* $Header: PAXGUT4B.pls 120.10.12010000.3 2010/03/17 11:38:12 abjacob ship $ */

PROCEDURE print_msg(p_msg  varchar2) IS
BEGIN
	--dbms_output.put_line('Log:PA_UTILS4:'||p_msg);
	--r_debug.r_msg('Log:PA_UTILS4:'||p_msg);
	null;
END print_msg;

/* This API returns true if thera are any transactions exists in contract commitment
 * module for the given project and Task
 */
FUNCTION CheckCCTxnsExists
			(p_project_id  NUmber
                     	,p_task_id    Number )
		RETURN VARCHAR2 IS

	l_CC_txn_Exists  Varchar2(1) := 'N';

BEGIN

    IF p_project_id is NOT NULL AND p_task_id is NOT NULL Then
	SELECT 'Y'
	INTO l_CC_txn_Exists
	FROM dual
	WHERE EXISTS (
			SELECT 'CC TXNS'
			FROM igc_cc_acct_lines igc
			     ,pa_projects_all pp
			WHERE igc.project_id IS NOT NULL
                        AND igc.project_id = pp.project_id
			AND pp.project_id = p_project_id
			AND igc.task_id IN  ( SELECT task.task_id
                                     FROM pa_tasks task
				     WHERE task.project_id = pp.project_id
				     CONNECT BY PRIOR task.TASK_ID = task.PARENT_TASK_ID
				     START WITH task.TASK_ID = p_task_id
                                   )
		     );
    ElsIF p_project_id is NOT NULL AND p_task_id is NULL Then

        SELECT 'Y'
        INTO l_CC_txn_Exists
        FROM dual
        WHERE EXISTS (
                        SELECT 'CC TXNS'
                        FROM igc_cc_acct_lines igc
                             ,pa_projects_all pp
                        WHERE igc.project_id IS NOT NULL
                        AND igc.project_id = pp.project_id
                        AND pp.project_id = p_project_id
                     );
    END IF;
    Return l_CC_txn_Exists;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	l_CC_txn_Exists := 'N';
	Return l_CC_txn_Exists;

    WHEN OTHERS THEN
	RAISE;
END CheckCCTxnsExists;

/** This API derives the assignment_id and work_type for the given
 *  person,project,task and transaction date
 *  If the person is having more than one assignment or No assignment then
 *  api returns Assignment_id will be ZERO and name will be null
 *  work type is derivation logic as follows
 *  If The defaulting work_type is set as project assignment
 *    If work_type derived based on assignment is not null then
 *           return project assignment work type
 *    Else if work_type derived based on Task level is not null then
 *           return Task level work type
 *    Else if work_type derived based on project level is not null then
 *            return  project level work type
 *    End if;
 *  If The defaulting work_type is set as Task then
 *    If work_type derived based on Task level is not null then
 *          return Task level work type
 *    If work_type derived based on assignment is not null then
 *           return project assignment work type
 *    Else if work_type derived based on project level is not null then
 *            return  project level work type
 *    End if;
 **/
PROCEDURE get_work_assignment(p_person_id     		IN  NUMBER
                             ,p_project_id    		IN  NUMBER
    			     ,p_task_id       		IN  NUMBER
			     ,p_ei_date       		IN  DATE
			     ,p_system_linkage          IN  VARCHAR2
			     ,x_tp_amt_type_code        OUT NOCOPY VARCHAR2
 			     ,x_assignment_id 		OUT NOCOPY NUMBER
			     ,x_assignment_name         IN OUT NOCOPY VARCHAR2
			     ,x_work_type_id            OUT NOCOPY NUMBER
			     ,x_work_type_name          IN  VARCHAR2
			     ,x_return_status           OUT NOCOPY VARCHAR2
			     ,x_error_message_code      OUT NOCOPY VARCHAR2 ) IS

	cursor cur_work is
	SELECT work_type_id
	FROM  pa_work_types_v w
        WHERE   w.name = x_work_type_name ;


BEGIN

	x_return_status := 'S';
	x_error_message_code := null;

	If p_system_linkage in ('ST','OT','ER') Then -- Bug 4092732 and nvl(PA_INSTALL.is_prm_licensed,'N') = 'Y'  then

	/** call the api which derives assignment_id and assignment_name **/

	   BEGIN

		PA_ASSIGNMENT_UTILS.Get_Person_Asgmt
            	( p_person_id           => p_person_id
             	  ,p_project_id         => p_project_id
             	  ,p_ei_date            => p_ei_date
             	  ,x_assignment_name    => x_assignment_name
             	  ,x_assignment_id      => x_assignment_id
             	  ,x_return_status      => x_return_status
             	  ,x_error_message_code => x_error_message_code );

		--if the assignment name is passed validate the assignment and if any error
                -- in validation just return no further processing is required
		 IF x_return_status <> 'S' and x_assignment_name is not null and
		    x_error_message_code = 'PA_NO_ASSIGNMENT' then
			Return;

                 ElsIf x_return_status <> 'S' or x_assignment_id is NULL then
			x_assignment_id  :=  0;
			--x_assignment_name := null;
			x_return_status := 'S';
			x_error_message_code := null;
		 End If;

	   EXCEPTION
                 WHEN no_data_found then
	        	x_assignment_id  :=  0;
			--x_assignment_name := null;
			x_return_status := 'S';
			x_error_message_code := null;
	         WHEN too_many_rows then
			--x_assignment_id  :=  0;
                        --x_assignment_name := null;
                        x_return_status := 'S';
			x_error_message_code := null;
		WHEN others then
			Raise;
           END;

	Else -- other than system linkage ST,ER and OT set the assignment id to zero
		--x_assignment_id  :=  0;
		NULL;

	End if;

		If x_work_type_name is not null then
			-- validate the work type
			OPEN cur_work;
			FETCH cur_work INTO x_work_type_id;
			IF cur_work%NOTFOUND then
				x_return_status := 'E';
				x_error_message_code := 'INVALID_WORK_TYPE';
			End If;
			CLOSE cur_work;

			IF x_return_status <> 'S' and x_error_message_code = 'INVALID_WORK_TYPE' then
				Return;

			Elsif x_work_type_id is Not null then
                        	x_tp_amt_type_code := get_tp_amt_type_code
                                            (p_work_type_id => x_work_type_id);

			END IF;
		End if;

		/** call the api which derives work type id **/
		If x_work_type_id is null and nvl(pa_utils4.is_exp_work_type_enabled,'N') = 'Y' Then

		     x_work_type_id := Get_work_type_id
			    ( p_project_id   =>p_project_id
                             ,p_task_id           =>p_task_id
                             ,p_assignment_id     =>nvl(x_assignment_id ,0)
                             );

		     /** added this code to raise error if the work type id not set while
                      *  defining the project, task or setting the profile after defining the
		      *  project , task in both cases the transaction import program should
                      *  reject the transaction
                      **/

		     If x_work_type_id is Null and pa_utils4.is_exp_work_type_enabled = 'Y' then
			x_error_message_code := 'INVALID_WORK_TYPE';
			x_return_status := 'E';
			Return;
		     End if;

		     If x_work_type_id is NOT NULL and x_work_type_name is NULL then
			x_tp_amt_type_code := get_tp_amt_type_code
                                            (p_work_type_id => x_work_type_id);
		     End if;
		End if;

		Return;


EXCEPTION
        WHEN OTHERS THEN
                x_return_status  := 'U';
                x_error_message_code := sqlcode||sqlerrm;
                RAISE;


END get_work_assignment;

FUNCTION get_work_type_id ( p_project_id               IN  NUMBER
                             ,p_task_id                 IN  NUMBER
                             ,p_assignment_id           IN  NUMBER
			   ) RETURN NUMBER is

	l_work_type_id   number := NULL;

	/* Bug fix: 2667770 removed the old cursor for performance issues
         * Please refer the previous version of this File for old cursor
         * New Logic : Based on p_assignment_id open the different cursor
         */

	CURSOR  cur_Assn_worktype  IS
	    select DECODE(nvl(pp.assign_precedes_task,'N')
                          ,'Y',decode(ppasgn.work_type_id, NULL,
                                  decode(t.work_type_id,NULL,pp.work_type_id,t.work_type_id),ppasgn.work_type_id),
                           'N', decode(t.work_type_id,NULL,
                                  decode(ppasgn.work_type_id,NULL,pp.work_type_id,ppasgn.work_type_id)
					,t.work_type_id)
			 ) work_type_id
                FROM  pa_projects_all pp
                      ,pa_project_assignments  ppasgn
                      ,pa_tasks t
                WHERE pp.project_id = p_project_id
                AND   t.task_id  = p_task_id
                AND   t.project_id  = pp.project_id
                AND   ppasgn.assignment_id = p_assignment_id
                AND   ( pp.project_id  = ppasgn.project_id
                       OR ( ppasgn.project_id is null
                            and rownum = 1
                          )
                      );

	CURSOR  cur_Task_worktype  IS
	   select Decode(t.work_type_id,NULL,pp.work_type_id,t.work_type_id) work_type_id
	   FROM  pa_projects_all pp
     		,pa_tasks t
	   WHERE pp.project_id = p_project_id
	   AND   t.task_id  = p_task_id
	   AND   t.project_id  = pp.project_id ;

	--l_Found  Boolean := FALSE;
	--l_plsql_index    Number;

BEGIN

       /*  If nvl(pa_utils4.is_exp_work_type_enabled,'N') = 'Y' Then commented for bug 3661894*/

           If (G_PrevWkPrjId = p_project_id and
               G_PrevWkTskId = p_task_id and
               Nvl(G_PrevWkAsgnId,0) = Nvl(p_assignment_id,0)) Then

               print_msg('Parameter same as previous, G_PrevWkTypeId = '|| G_PrevWkTypeId);
               l_work_type_id := G_PrevWkTypeId;

           Else

              print_msg('Parameter not same as previous');
	      IF Nvl(p_assignment_id,0) <> 0 Then

                OPEN cur_Assn_worktype;
                FETCH cur_Assn_worktype INTO l_work_type_id;
                CLOSE cur_Assn_worktype;

	      Else
		OPEN cur_Task_worktype;
                FETCH cur_Task_worktype INTO l_work_type_id;
                CLOSE cur_Task_worktype;
	      End If;

              G_PrevWkPrjId := p_project_id;
              G_PrevWkTskId := p_task_id;
              G_PrevWkAsgnId := p_assignment_id;
              G_PrevWkTypeId := l_work_type_id;

              print_msg('G_PrevWkTypeId = ' || G_PrevWkTypeId);

           End If;

     /*   End If; commented for bug 3661894 end of is_exp_work_type_enabled */


	Return l_work_type_id;

EXCEPTION

	WHEN OTHERS THEN
		RAISE;

END get_work_type_id;

FUNCTION get_work_type_name(p_work_type_id  IN NUMBER)
         RETURN varchar2 IS

	l_work_type_name   VARCHAR2(80) := Null;
	l_worktypeid       NUMBER;
	l_found            boolean := FALSE;

BEGIN
	l_workTypeId := nvl(p_work_type_id,99999999);

        -- Check if there are any records in the pl/sql table
        If pa_utils4.G_WorkTypeNameRecTab.count > 0 then
            Begin

                -- Get the Project Number from the pl/sql table.
                -- If there is no index with the value of the project_id passed
                -- in then an ora-1403: no_data_found is generated.
                l_work_type_name := pa_utils4.G_WorkTypeNameRecTab(l_workTypeId).work_type_name;
                l_Found := TRUE;
                print_msg('Retreiving workTypeName from cache['||l_work_type_name||']' );

            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;

            End;

        End If;

        -- Since the project has not been cached yet, will need to add it.
        -- So check to see if there are already 200 records in the pl/sql table.
        If pa_utils4.G_WorkTypeNameRecTab.COUNT > 199 Then

                pa_utils4.G_WorkTypeNameRecTab.Delete;
                l_Found := FALSE;

        End If;

        If Not l_Found then
          If p_work_type_id is NOT NULL then
             	SELECT name
           	INTO  l_work_type_name
           	FROM  pa_work_types_tl
           	WHERE work_type_id  = p_work_type_id
           	and   language = userenv('LANG');
          End if;
		pa_utils4.G_WorkTypeNameRecTab(l_workTypeId).work_type_name := l_work_type_name;
        End If;

      	Return l_work_type_name;

EXCEPTION
	when no_data_found then
		return null;

	when others then
		Raise;

END get_work_type_name;

FUNCTION get_assignment_name(p_assignment_id  IN NUMBER) RETURN varchar2 IS

	l_assignment_name   VARCHAR2(80);
	l_found   boolean := FALSE;
	l_assignmentId    number;

BEGIN

	l_assignmentId := nvl(p_assignment_id,0);

	If pa_utils4.G_AssignNameRecTab.COUNT > 0 then
	   Begin

		l_assignment_name := pa_utils4.G_AssignNameRecTab(l_assignmentId).assignment_name;
		l_found := TRUE;
	   Exception
		when no_data_found then
			l_found :=  FALSE;

		when others then
			raise;
	    End;

	End If;

	If pa_utils4.G_AssignNameRecTab.COUNT > 199 then

		pa_utils4.G_AssignNameRecTab.delete;
		l_found :=  FALSE;

	End If;

	If Not l_found Then
         If p_assignment_id is NOT NULL then
	   If p_assignment_id = 0 then

		select meaning
		into l_assignment_name
		from pa_lookups
		where lookup_type = 'PA_EXP_ASSGN_ENTRY'
		and   lookup_code = 'UNSCHEDULED';

	   Else

          	SELECT assignment_name
           	INTO  l_assignment_name
           	FROM  pa_project_assignments
           	WHERE assignment_id = p_assignment_id;

	   End If;
	   pa_utils4.G_AssignNameRecTab(l_assignmentId).assignment_name := l_assignment_name;

          End if;
	End If;
      	Return l_assignment_name;

EXCEPTION
        when no_data_found then
                return null;

        when others then
                Raise;

END get_assignment_name;

/** This is an wrapper api which in turn calls procedure
 *  which derives assignment_id and assignment_name
 */
FUNCTION get_assignment_id(p_person_id               IN  NUMBER
                           ,p_project_id              IN  NUMBER
                           ,p_task_id                 IN  NUMBER
                           ,p_ei_date                 IN  DATE
                         ) RETURN NUMBER IS

	x_assignment_id  number := NULL;
	x_assignment_name varchar2(80);
	x_return_status   varchar2(80);
	x_error_message_code varchar2(1000);
--	l_plsql_index   number;
--	l_found  Boolean := FALSE;

BEGIN
/*	l_plsql_index := nvl(p_project_id,0)||nvl(p_task_id,0)||nvl(p_person_id,0)||
			 nvl(to_char(trunc(p_ei_date),'DDMMYYYY'),99999999);

	print_msg('l_plsql_index in get_assignment_id api['||l_plsql_index||']' );

	If pa_utils4.G_AssignIdRecTab.COUNT > 0 then
		Begin
			x_assignment_id := pa_utils4.G_AssignIdRecTab(l_plsql_index).assignment_id;
			print_msg('Retreiving assignment_id from Cache['||x_assignment_id||']' );
			l_found := true;

		Exception
			when no_data_found then
				l_found := FALSE;
			when others then
				raise;
		End;

	End If;

	If pa_utils4.G_AssignIdRecTab.COUNT > 199 then
		pa_utils4.G_AssignIdRecTab.delete;
		l_found := FALSE;
	End if;

	If Not l_found Then

	     print_msg('global profile G_PRM_INSTALLED_FLAG:['||PA_UTILS4.G_PRM_INSTALLED_FLAG||']' );

	     If PA_UTILS4.G_PRM_INSTALLED_FLAG is NULL then
		PA_UTILS4.G_PRM_INSTALLED_FLAG := nvl(PA_INSTALL.is_prm_licensed,'N');
		print_msg('Executing query to get profile value G_PRM_INSTALLED_FLAG:['
                          ||PA_UTILS4.G_PRM_INSTALLED_FLAG||']' );
             End If;

	     --If nvl(PA_INSTALL.is_prm_licensed,'N') = 'Y' Then commented out for performance

             IF PA_UTILS4.G_PRM_INSTALLED_FLAG = 'Y' then
             -- call the api which derives assignment_id and assignment_name
                PA_ASSIGNMENT_UTILS.Get_Person_Asgmt
                ( p_person_id           => p_person_id
                  ,p_project_id         => p_project_id
                  ,p_ei_date            => p_ei_date
                  ,x_assignment_name    => x_assignment_name
                  ,x_assignment_id      => x_assignment_id
                  ,x_return_status      => x_return_status
                  ,x_error_message_code => x_error_message_code );

                 If x_return_status <> 'S' or x_assignment_id is NULL then
                        x_assignment_id  :=  0;
                 End If;
	    End if;
	    print_msg('Retreiving assignment_id from query['||x_assignment_id||']' );
	    pa_utils4.G_AssignIdRecTab(l_plsql_index).assignment_id := x_assignment_id ;

	End If;

*/

	/* Bug 4092732 : Regardless of PJR license, matching assignment should be stamped against
					 an expenditure item. (assignment_id should be populated on
					 pa_expenditure_items_all based on project assignment)
	   If PA_UTILS4.G_PRM_INSTALLED_FLAG is NULL then

          PA_UTILS4.G_PRM_INSTALLED_FLAG := nvl(PA_INSTALL.is_prm_licensed,'N');

          print_msg('Executing query to get profile value G_PRM_INSTALLED_FLAG:['
                    ||PA_UTILS4.G_PRM_INSTALLED_FLAG||']' );
       End If;

	*/

    ---- Bug 4092732 IF PA_UTILS4.G_PRM_INSTALLED_FLAG = 'Y' then


          If (G_PrevAsgPerId = p_person_id and
              G_PrevAsgPrjId = p_project_id and
              trunc(G_PrevAsgEIDate) = trunc(p_ei_date)) Then

              print_msg('Parameters same as previous, G_PrevAsgAsgnId = '|| G_PrevAsgAsgnId);
              x_assignment_id := G_PrevAsgAsgnId;

          Else

              print_msg('Parameters not same as previous, call API');
             /** call the api which derives assignment_id and assignment_name **/
                PA_ASSIGNMENT_UTILS.Get_Person_Asgmt
                ( p_person_id           => p_person_id
                  ,p_project_id         => p_project_id
                  ,p_ei_date            => p_ei_date
                  ,x_assignment_name    => x_assignment_name
                  ,x_assignment_id      => x_assignment_id
                  ,x_return_status      => x_return_status
                  ,x_error_message_code => x_error_message_code );

                 If x_return_status <> 'S' or x_assignment_id is NULL then
                        x_assignment_id  :=  0;
                 End If;

                 G_PrevAsgPerId := p_person_id;
                 G_PrevAsgPrjId := p_project_id;
                 G_PrevAsgEIDate := p_ei_date;
                 G_PrevAsgAsgnId := x_assignment_id;

                 print_msg('G_PrevAsgAsgnId = ' || G_PrevAsgAsgnId);

           End If;

        --- Bug 4092732 End if;

	RETURN x_assignment_id;


EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 0;

	WHEN OTHERS THEN
		RAISE;
END get_assignment_id;

FUNCTION get_tp_amt_type_code(p_work_type_id   IN  Number)
         RETURN varchar2 IS

        l_tp_amt_code  VARCHAR2(80);
        l_found            boolean := FALSE;
	l_workTypeId   NUMBER;

BEGIN
        l_workTypeId := nvl(p_work_type_id,99999999);

        -- Check if there are any records in the pl/sql table
        If pa_utils4.G_TpAmtTypeRecTab.count > 0 then
            Begin

                -- Get the Project Number from the pl/sql table.
                -- If there is no index with the value of the project_id passed
                -- in then an ora-1403: no_data_found is generated.
                l_tp_amt_code := pa_utils4.G_TpAmtTypeRecTab(l_workTypeId).tp_amt_type_code;
                l_Found := TRUE;
                print_msg('Retreiving l_tp_amt_code  from cache['||l_tp_amt_code||']' );

            Exception
                When No_Data_Found Then
                        l_Found := FALSE;
                When Others Then
                        Raise;

            End;

        End If;

        -- Since the project has not been cached yet, will need to add it.
        -- So check to see if there are already 200 records in the pl/sql table.
        If pa_utils4.G_TpAmtTypeRecTab.COUNT > 199 Then

                pa_utils4.G_TpAmtTypeRecTab.Delete;
                l_Found := FALSE;

        End If;

	If Not l_Found Then


         If p_work_type_id is NOT NULL then
           SELECT tp_amt_type_code
           INTO  l_tp_amt_code
           FROM  pa_work_types_b
           WHERE work_type_id = p_work_type_id
	   AND   trunc(sysdate) between start_date_active
                 and nvl(end_date_active,sysdate);
         End if;
	   pa_utils4.G_TpAmtTypeRecTab(l_workTypeId).tp_amt_type_code := l_tp_amt_code;
	End If;

      	Return l_tp_amt_code;

EXCEPTION
        when no_data_found then
                return null;

        when others then
                Raise;

END get_tp_amt_type_code;

/** This api derives the site level profile value of
 *  Transaction work type enabled
 **/
FUNCTION is_exp_work_type_enabled RETURN VARCHAR2  IS

	l_enabled_flag   varchar2(1);
BEGIN
	print_msg('global value G_WORKTYPE_ENABLED['||PA_UTILS4.G_WORKTYPE_ENABLED||']' );
	/* cache the profile value in global variable and return it */

	IF PA_UTILS4.G_WORKTYPE_ENABLED is NULL then

		SELECT nvl(fnd_profile.value_specific('PA_EN_NEW_WORK_TYPE_PROCESS'),'N')
        	INTO l_enabled_flag
        	FROM  dual;
		PA_UTILS4.G_WORKTYPE_ENABLED := l_enabled_flag;
		print_msg('Executing query to get profile  G_WORKTYPE_ENABLED['||PA_UTILS4.G_WORKTYPE_ENABLED||']' );

	End If;

        /* In Grants Implemented in OU ,  work type is not supported */
	IF PA_UTILS4.G_WORKTYPE_ENABLED = 'Y' then
             IF (GMS_INSTALL.enabled) THEN
		PA_UTILS4.G_WORKTYPE_ENABLED := 'N';
             END IF;
        END IF;

	return PA_UTILS4.G_WORKTYPE_ENABLED;
EXCEPTION
	WHEN NO_DATA_FOUND then
	    PA_UTILS4.G_WORKTYPE_ENABLED := 'N';
	    return PA_UTILS4.G_WORKTYPE_ENABLED;

        WHEN OTHERS THEN
                RAISE;

END is_exp_work_type_enabled;
/** This api derives the site level profile value of
 *  Transaction Billablity derived from work type
 **/
FUNCTION is_worktype_billable_enabled RETURN VARCHAR2  IS

	l_enabled_flag   varchar2(1);
BEGIN
	print_msg('global profile G_WORKTYPE_BILLABILITY value: ['||PA_UTILS4.G_WORKTYPE_BILLABILITY||']' );
	--Added this check as if the work type profile is not enabled then
        --work type billablity cannot be enabled
	IF is_exp_work_type_enabled  = 'Y' then

		IF PA_UTILS4.G_WORKTYPE_BILLABILITY is NULL then

			SELECT nvl(fnd_profile.value_specific('PA_TRXN_BILLABLE_WORK_TYPE'),'N')
        		INTO l_enabled_flag
        		FROM  dual;
			PA_UTILS4.G_WORKTYPE_BILLABILITY := l_enabled_flag;
			print_msg('Executing query to get  profile G_WORKTYPE_BILLABILITY: ['
				 ||PA_UTILS4.G_WORKTYPE_BILLABILITY||']' );
	        End If;


	ELse
		/* l_enabled_flag := 'N'; commented out for performance issue */
		PA_UTILS4.G_WORKTYPE_BILLABILITY := 'N';
	End if;

	/* return l_enabled_flag; */
	return PA_UTILS4.G_WORKTYPE_BILLABILITY;
EXCEPTION

        WHEN OTHERS THEN
                RAISE;

END is_worktype_billable_enabled;
/** This api derives the billability of the
 *    transaction based on the work type and profile option
 *    if  p_tc_extn_bill_flag is  billable flag derived from client extension  is null then
 *    and profile option = Y  then  api returns billable flag  derived from work type
 *    if  p_tc_extn_bill_flag is not null and profile option = N then api returns client extension
 *    if  p_tc_extn_bill_flag is not null and profile option = N then api returns  N
 *    NOTE : This API is called from PATC,PA_ADJUSTMENTS,TRXN_IMPORTS API please before modifying
 *           this api do impact analysis
 **/
FUNCTION get_trxn_work_billabilty(p_work_type_id  IN  NUMBER
                            ,p_tc_extn_bill_flag  IN  VARCHAR2  )
      RETURN varchar2  IS

	CURSOR cur_billwork IS
	SELECT BILLABLE_CAPITALIZABLE_FLAG
        FROM  pa_work_types_b -- bug 4668816 changed from pa_work_types_v to pa_work_types_b
	WHERE work_type_id = p_work_type_id
	AND   trunc(sysdate) between start_date_active  and
		nvl(end_date_active,sysdate);

	l_billable_flag    varchar2(10);
	l_temp_flag        varchar2(10);

BEGIN

	l_temp_flag :=  null;

	-- if the profile option PA: Require Work Type Entry for Expenditures set to NO
        -- then profile PA: Transaction Billablity derived from work type cannot be set to YES
        -- based on the above profile option return the billable flag

	IF is_exp_work_type_enabled  = 'Y' and  is_worktype_billable_enabled = 'Y' then
        	OPEN cur_billwork;
        	FETCH cur_billwork INTO l_billable_flag;
        	CLOSE cur_billwork;

		If l_billable_flag is NOT NULL then
		     l_temp_flag := l_billable_flag;
		Else
		     l_temp_flag := p_tc_extn_bill_flag;
		End if;
	Else
		l_temp_flag := p_tc_extn_bill_flag;
	End if;

	Return l_temp_flag;

EXCEPTION

	WHEN OTHERS THEN
		RAISE;

END get_trxn_work_billabilty;

/* added the function below for BUG 3220230 */
--------------------------------------------------------------------------------------------------
-- FUNCTION GetOrig_EiBillability_SST() derives the billability of the reversed EIs based on their
-- parent EI in the ei table.The argument to this function is the EID of the parent.
-- This function only takes care of reversed EI's of ORACLE SELF SERVICE TIME.
---------------------------------------------------------------------------------------------------
FUNCTION GetOrig_EiBillability_SST(orig_eid IN NUMBER,billable_flag IN VARCHAR2,trans_source IN VARCHAR2) RETURN VARCHAR2 IS
l_billable_flag       varchar2(10);
l_param_billable_flag varchar2(1) ;
BEGIN
        -- BUG: 4590927
	-- PJ.R12:DI1:APLINES: ADJUSTING EXPENDITURE ITEM CREATED HAS INCORRECT FLAGS
	/*l_param_billable_flag := 'N' ;
	IF trans_source not in ( 'Oracle Self Service Time',
                             'ORACLE TIME AND LABOR',  bug 5297060
	                         'AP EXPENSE',
				             'AP INVOICE',
				             'AP NRTAX' ,
	                         'INTERCOMPANY_AP_INVOICES',
				             'INTERPROJECT_AP_INVOICES',
				             'AP VARIANCE',
				             'AP DISCOUNTS',
                             'AP ERV',  Bug 5284323
				             'PO RECEIPT',
				             'PO RECEIPT NRTAX',
				             'PO RECEIPT PRICE ADJ',
				             'PO RECEIPT NRTAX PRICE ADJ' ) THEN

	    l_param_billable_flag := 'Y' ;

	END IF ; */ -- Commented for 9461465

	IF /*l_param_billable_flag = 'Y' OR*/ orig_eid is NULL  THEN -- Commented for 9461465

		l_billable_flag := billable_flag;

    ELSE

	    SELECT billable_flag
		INTO l_billable_flag
		FROM  pa_expenditure_items_all ei
		WHERE ei.expenditure_item_id=orig_eid;

	END IF ;

	RETURN l_billable_flag;

EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END;


/* Added the function below for Bug# 4057474 */
------------------------------------------------------------------------------------------------------
-- FUNCTION GetOrig_EiBill_hold() derives the value of bill_hold_flag of the reversed EIs based on
-- their parent EI in the ei table. The argument to this function is the EID of the parent.
-- This function takes care of reversed EI's of external transaction sources like ORACLE TIME AND LABOR.
-------------------------------------------------------------------------------------------------------
FUNCTION GetOrig_EiBill_hold(orig_eid IN NUMBER,bill_hold_flag IN VARCHAR2) RETURN VARCHAR2 IS
l_bill_hold_flag    varchar2(10);
BEGIN
        IF orig_eid is NULL  THEN
                l_bill_hold_flag := bill_hold_flag;
        ELSE
                SELECT bill_hold_flag
                INTO l_bill_hold_flag
                FROM  pa_expenditure_items_all ei
                WHERE ei.expenditure_item_id=orig_eid;
        END IF ;
        RETURN l_bill_hold_flag;

EXCEPTION
        WHEN OTHERS THEN
                RAISE;

END;



PROCEDURE check_txn_exists (p_project_id   IN NUMBER,
                            p_task_id      IN NUMBER ,
                            x_status_code  OUT NOCOPY NUMBER,
                            x_err_code     OUT NOCOPY VARCHAR2,
                            x_err_stage    OUT NOCOPY VARCHAR2) IS

   x_used_in_OTL   BOOLEAN;   --To pass to OTL API.
   l_CCTrxexists Varchar2(100) := 'N';

BEGIN

   -- Check if task has expenditure item
   x_err_stage := 'check expenditure item for project:'|| p_project_id;

   x_status_code:=PA_PROJ_TSK_UTILS.check_exp_item_exists(p_project_id,p_task_id);
   IF ( x_status_code = 1) THEN
        x_err_code   :=50;
        x_err_stage  := 'PA_TSK_EXP_ITEM_EXIST';
        return;
   ELSIF ( x_status_code< 0 ) THEN
        x_err_code   :=x_status_code;
        return;
   END IF;

   -- Check if task has purchase order distribution
   x_err_stage := 'check purchase order for project:'|| p_project_id;

   x_status_code :=pa_proj_tsk_utils.check_po_dist_exists(p_project_id, p_task_id);

   IF ( x_status_code = 1 ) then
        x_err_code := 60;
        x_err_stage := 'PA_TSK_PO_DIST_EXIST';
        return;
   ELSIF ( x_status_code < 0 ) then
           x_err_code := x_status_code;
           return;
   END IF;

   -- Check if task has purchase order requisition
   x_err_stage := 'check purchase order requisition for project: '|| p_project_id;
   x_status_code := pa_proj_tsk_utils.check_po_req_dist_exists(p_project_id, p_task_id);

   IF ( x_status_code = 1 ) then
        x_err_code := 70;
        x_err_stage := 'PA_TSK_PO_REQ_DIST_EXIST';
        return;
   ELSIF ( x_status_code < 0 ) then
           x_err_code := x_status_code;
           return;
   END IF;

   -- Check if task has supplier invoices
   x_err_stage := 'check supplier invoice for project:'|| p_project_id;
   x_status_code := pa_proj_tsk_utils.check_ap_invoice_exists(p_project_id, p_task_id);
   IF ( x_status_code = 1 ) then
        x_err_code := 80;
        x_err_stage := 'PA_TSK_AP_INV_EXIST';
        return;
   ELSIF ( x_status_code < 0 ) then
           x_err_code := x_status_code;
           return;
   END IF;

   -- Check if task has supplier invoice distribution
   x_err_stage   := 'check supplier inv distribution for project: '|| p_project_id;
   x_status_code := pa_proj_tsk_utils.check_ap_inv_dist_exists(p_project_id, p_task_id);
   IF ( x_status_code = 1 ) then
        x_err_code := 90;
        x_err_stage := 'PA_TSK_AP_INV_DIST_EXIST';
        return;
   ELSIF ( x_status_code < 0 ) then
           x_err_code := x_status_code;
           return;
   END IF;

   -- Check to see if the project has any Contract Commitment Trxns exists
   x_err_stage   := 'check if project used in ContractCommitments for project: '|| p_project_id;
   l_CCTrxexists := CheckCCTxnsExists(p_project_id=> p_project_id,p_task_id =>p_task_id);

   IF l_CCTrxexists = 'Y' Then
	x_status_code := 1;
        x_err_code := 100;
        x_err_stage := 'PA_TASK_CC_TXN_EXIST';
        return;
   End If;

   --Check to see if the project has been used in OTL--Added by Ansari
   x_err_stage   := 'check if project used in OTL for project: '|| p_project_id;
   PA_OTC_API.ProjectTaskUsed( p_search_attribute => 'PROJECT_ID',
                               p_search_value     => p_project_id,
                               x_used             => x_used_in_OTL );
   --If exists in OTL
    IF x_used_in_OTL THEN
       x_err_code := 200;
       x_err_stage := 'PA_TSK_EXP_ITEM_EXIST';
       return;
    END IF;


   IF x_status_code IS NULL THEN
      x_status_code:=0;
   END IF;

   IF x_err_code IS NULL THEN
      x_err_code:=0;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
       x_err_code := SQLCODE;
       rollback;
       return;
END check_txn_exists;

  /** This api checks if a bill rate schedule is used
   *  in any organization assignment.
   */
  FUNCTION IsUsedInCosting(p_bill_rate_sch_id  IN  NUMBER )
      RETURN BOOLEAN IS

    CURSOR c1 IS
      SELECT 'X'
        FROM sys.dual
       WHERE EXISTS ( SELECT 'x'
                        FROM pa_org_labor_sch_rule a
                       WHERE (a.cost_rate_sch_id = p_bill_rate_sch_id
                              OR
                              a.FORECAST_COST_RATE_SCH_ID = p_bill_rate_sch_id
							 )
                    ) ;
	/* Bug # 3613754 In ISUSEDINCOSTING Function, splitted the cursor in two cursor */

	Cursor C2 Is
	  SELECT 'X'
        FROM sys.dual
       WHERE EXISTS ( SELECT 'y'
                        FROM pa_compensation_details_all b
                       WHERE b.rate_schedule_id = p_bill_rate_sch_id
                    ) ;



   l_check_if_exists   varchar2(1);

BEGIN

    OPEN  C1 ;
    FETCH c1 INTO l_check_if_exists;
    CLOSE c1 ;
    IF l_check_if_exists = 'X' THEN
       RETURN (TRUE);
    ELSE
	   Open C2 ;
	   FETCH C2 INTO l_check_if_exists;
	   CLOSE C2 ;
	   If  l_check_if_exists = 'X' Then
			RETURN (TRUE);
	   Else
	        RETURN (FALSE);
	   End If;
    END IF ;

EXCEPTION

	WHEN OTHERS THEN

		RAISE;

END IsUsedInCosting;

  /** This API validates the given IN param is Number or Not
   *  If not Number return -9999
   */

FUNCTION getNumericString(p_reference1  IN varchar2) RETURN NUMBER IS

	l_return_number  Number := -9999;

BEGIN
	If p_reference1 IS Not Null Then

		SELECT TO_NUMBER(p_reference1)
		INTO l_return_number
		FROM dual;

	End If;

	Return l_return_number;

EXCEPTION

	WHEN OTHERS THEN
		l_return_number := -9999;
		RETURN l_return_number;

END getNumericString;

 /** This API will return Implementaion OrgId and uses cacheing logic
  */
  FUNCTION get_org_id RETURN NUMBER IS

  BEGIN

	IF PA_UTILS4.G_imp_org_id IS NOT NULL Then
		Return G_imp_org_id;
	End IF;

  	get_imp_values(x_prim_sob  =>PA_UTILS4.G_imp_sob_id
                      ,x_org_id    =>PA_UTILS4.G_imp_org_id
                      ,x_book_type_code =>PA_UTILS4.G_imp_book_type_code
                      ,x_business_group =>PA_UTILS4.G_imp_bus_group
                       );

	Return PA_UTILS4.G_imp_org_id;

  EXCEPTION
	WHEN OTHERS THEN
		Return PA_UTILS4.G_imp_org_id;

  END get_org_id;

 /** This API returns set_of_books_id from the implementations
  **/
  FUNCTION get_primary_sob RETURN NUMBER IS

  BEGIN
        IF PA_UTILS4.G_imp_sob_id IS NOT NULL Then
                Return PA_UTILS4.G_imp_sob_id;
        End IF;

        get_imp_values(x_prim_sob  =>PA_UTILS4.G_imp_sob_id
                      ,x_org_id    =>PA_UTILS4.G_imp_org_id
                      ,x_book_type_code =>PA_UTILS4.G_imp_book_type_code
                      ,x_business_group =>PA_UTILS4.G_imp_bus_group
                       );

        Return PA_UTILS4.G_imp_sob_id;

  EXCEPTION
        WHEN OTHERS THEN
                Return PA_UTILS4.G_imp_sob_id;
  END get_primary_sob;

 /** This API returns the Implementation values **/
  PROCEDURE get_imp_values(x_prim_sob  OUT NOCOPY Number
                          ,x_org_id    OUT NOCOPY NUmber
                          ,x_book_type_code OUT NOCOPY varchar2
                          ,x_business_group OUT NOCOPY number
                          ) IS

  BEGIN

    IF (PA_UTILS4.G_imp_sob_id is NULL OR PA_UTILS4.G_imp_org_id IS NULL or
	PA_UTILS4.G_imp_book_type_code <> 'X' or PA_UTILS4.G_imp_bus_group is NULL) Then

	SELECT SET_OF_BOOKS_ID
	      ,ORG_ID
	      ,nvl(BOOK_TYPE_CODE,'X')
	      ,BUSINESS_GROUP_ID
	INTO PA_UTILS4.G_imp_sob_id
	     ,PA_UTILS4.G_imp_org_id
             ,PA_UTILS4.G_imp_book_type_code
             ,PA_UTILS4.G_imp_bus_group
	FROM pa_implementations;

    End IF;

	x_prim_sob := PA_UTILS4.G_imp_sob_id;
	x_org_id   := PA_UTILS4.G_imp_org_id;
	x_book_type_code := PA_UTILS4.G_imp_book_type_code;
	x_business_group := PA_UTILS4.G_imp_bus_group;

  EXCEPTION
	when no_data_found then
	     PA_UTILS4.G_imp_sob_id := Null;
             PA_UTILS4.G_imp_org_id := Null;
             PA_UTILS4.G_imp_book_type_code := Null;
             PA_UTILS4.G_imp_bus_group := Null;
             x_prim_sob := PA_UTILS4.G_imp_sob_id;
             x_org_id   := PA_UTILS4.G_imp_org_id;
             x_book_type_code := PA_UTILS4.G_imp_book_type_code;
             x_business_group := PA_UTILS4.G_imp_bus_group;
	     RETURN;
	when others then
		Raise;

  END get_imp_values;

 /** This API returns the Business group Id for the given Organization Id **/
  FUNCTION GetOrgBusinessGrpId(p_organization_id IN Number)

	RETURN NUMBER IS
	l_business_grp_id Number := Null;

  BEGIN
      IF p_organization_id IS NOT NULL THEN

	SELECT BUSINESS_GROUP_ID
	INTO   l_business_grp_id
	FROM   HR_ALL_ORGANIZATION_UNITS
	WHERE  ORGANIZATION_ID = p_organization_id;

      END IF;

      RETURN l_business_grp_id;

  EXCEPTION
      WHEN NO_DATA_FOUND THEN
	RETURN NULL;

      WHEN OTHERS THEN
	RAISE;

  END GetOrgBusinessGrpId;

/* This is an public API, which in turn calls a private function CheckCCTxnsExists
 * This api will be called from project and task Form before deleting
 * any of the task or project
 */
PROCEDURE Check_CC_TxnExists(p_project_id       Number
                            ,p_task_id          Number
                            ,x_return_status OUT NOCOPY varchar2
                            ,x_msg_data      OUT NOCOPY varchar2
                            ,x_msg_count     OUT NOCOPY Number ) IS

	l_error_msg_code  varchar2(100);
        l_msg_count  Number;
	l_msg_data   Varchar2(1000);
	l_trx_exists     varchar2(1);

BEGIN
	x_return_status := 'S';
	x_msg_data := Null;
	x_msg_count := 0;

        /** clear the message stack **/
        fnd_msg_pub.INITIALIZE;

	l_trx_exists := CheckCCTxnsExists(p_project_id=> p_project_id,p_task_id =>p_task_id);
        If l_trx_exists <> 'N' Then
               x_msg_data      := 'PA_TASK_CC_TXN_EXIST';
	       x_return_status := 'E';
	       x_msg_count := 1;

               PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                                    ,p_msg_name  =>x_msg_data
                                   );

        End if;
EXCEPTION
	WHEN OTHERS THEN
		RAISE;

END Check_CC_TxnExists;

/* This is an public API, which in turn calls a private functions
 * This api will be called from budgetary controls form to check any
 * transactions exists for project or task. If so the budgetary control form
 * will be modified to read only mode
 */
PROCEDURE CheckToEnableBdgtCtrl(p_project_id       Number
                                ,p_task_id          Number
				,p_mode             Varchar2  Default 'BDGTCTRL'
                                ,x_return_status    OUT NOCOPY varchar2
                                ,x_error_msg_code   OUT NOCOPY varchar2
				,x_error_stage      OUT NOCOPY varchar2
                                 ) IS

	l_stage   Varchar2(1000);
	l_status_code Number := 0;
	l_param  varchar2(100);
	l_project_id Number;
	l_task_id    Number;
	l_CCTrxexists  varchar2(1);
BEGIN

	-- Initialize the Out variables
	x_return_status  := 'S';
	x_error_msg_code := NULL;
	x_error_stage    := NULL;
	l_status_code    := 0;

	l_stage := 'Validating IN params';
	IF p_project_id is NULL and p_task_id is NULL Then
		Return;
	ElsIf p_mode = 'BDGTCTRL' Then
		l_project_id := p_project_id;
		l_task_id    := NULL;
	Else
		l_project_id := p_project_id;
		l_task_id    := p_task_id;
	End If;

	l_param := ':P_mode['||p_mode||']ProjectId['||l_project_id||']TasId['||l_task_id||']';

	-- Check for Requisitions
        l_stage       := 'Check for Requisitions';
	IF x_return_status = 'S' Then
        	l_status_code := pa_proj_tsk_utils.check_po_req_dist_exists(l_project_id, l_task_id);
        	IF ( l_status_code = 1 ) then
                	x_error_msg_code := 'PA_PRJ_PO_REQ_DIST_EXIST';
			x_error_stage    := l_stage||l_param;
			x_return_status  := 'E';
        	END IF;
	End If;

   	-- Check for Purchase order
	IF x_return_status = 'S' Then
   		l_stage       := 'Check purchase order';
   		l_status_code := pa_proj_tsk_utils.check_po_dist_exists(l_project_id, l_task_id);
   		IF ( l_status_code = 1 ) then
        		x_error_msg_code := 'PA_PRJ_PO_DIST_EXIST';
			x_error_stage    := l_stage||l_param;
			x_return_status  := 'E';
   		END IF;
	End If;


        /* Bug 6153950: start
        Bug 6153950: It is sufficient to query AP Invoice Distributions to check for AP Txns
                     Hence call to pa_proj_tsk_utils.check_ap_invoice_existsis is commented here

   	-- Check for Supplier Invoices
	IF x_return_status = 'S' Then
   		l_stage       := 'Check for Supplier Invoices';
   		l_status_code := pa_proj_tsk_utils.check_ap_invoice_exists(l_project_id, l_task_id);
   		IF ( l_status_code = 1 ) then
        		x_error_msg_code := 'PA_PRJ_AP_INV_EXIST';
			x_error_stage    := l_stage||l_param;
			x_return_status  := 'E';
   		END IF;
	End If;
	Bug 6153950: end */


   	-- Check if task has supplier invoice distribution
	IF x_return_status = 'S' Then
   		l_stage       := 'Check for Supplier Invoice Distributions';
   		l_status_code := pa_proj_tsk_utils.check_ap_inv_dist_exists(l_project_id, l_task_id);
   		IF ( l_status_code = 1 ) then
        		x_error_msg_code := 'PA_PRJ_AP_INV_DIST_EXIST';
			x_error_stage    := l_stage||l_param;
			x_return_status  := 'E';
   		END IF;
	End If;

   	-- Check for Contract Commitments
	IF x_return_status = 'S' Then
   		l_stage       := 'Check for Contract Commitments';
   		l_CCTrxexists := CheckCCTxnsExists(p_project_id=> l_project_id,p_task_id =>l_task_id);
   		IF l_CCTrxexists = 'Y' Then
        		x_error_msg_code:= 'PA_PRJ_CC_TXN_EXIST';
			x_error_stage   := l_stage||l_param;
			x_return_status := 'E';
   		End If;
	End if;

	RETURN;

EXCEPTION
	WHEN OTHERS THEN
		x_error_msg_code := SQLCODE||SQLERRM;
		x_error_stage    := l_stage||l_param;
		x_return_status  := 'U';
		Raise;


END CheckToEnableBdgtCtrl;


 -- New functions added for PJM changes.
Function get_unit_of_measure ( p_expenditure_type IN VARCHAR2 ) return VARCHAR2  IS

l_uom VARCHAR2(30) := NULL ;
begin
     select unit_of_measure
       into  l_uom
       from pa_expenditure_types
      where expenditure_type = p_expenditure_type ;
     return l_uom ;
 Exception
  when NO_DATA_FOUND THEN
     return l_uom ;
end  ;

Function get_unit_of_measure_m ( p_unit_of_measure IN VARCHAR2 ,
                                 p_expenditure_type IN VARCHAR2) return VARCHAR2  IS

l_uom_m VARCHAR2(80) := NULL ;
begin
  -- If unit_of_measure in pa_expenditure_items_all is populated
  If p_unit_of_measure IS NOT NULL THEN
    select l.meaning
      into l_uom_m
     from pa_lookups l
     where lookup_type = 'UNIT'
     and   lookup_code = p_unit_of_measure ;
  -- If unit_of_measure in pa_expenditure_items_all is NOT populated
  else
      select l.meaning
        into l_uom_m
        from pa_lookups l,
             pa_expenditure_types et
       where lookup_type = 'UNIT'
         and lookup_code = et.unit_of_measure
         and et.expenditure_type = p_expenditure_type ;
   End if ;

    return l_uom_m ;
  Exception
  when NO_DATA_FOUND THEN
    return l_uom_m ;
end  get_unit_of_measure_m;

Function GET_EMP_NAME_NUMBER( p_incurred_by_person_id IN NUMBER,
                              p_expenditure_ending_date IN DATE,
                              p_mode IN VARCHAR2 ) Return VARCHAR2 IS
 begin
  if NVL (G_INCURRED_BY_PERSON_ID,0) <>  p_incurred_by_person_id   THEN
      select P.FULL_NAME,NVL(P.EMPLOYEE_NUMBER,P.NPW_NUMBER)
        into G_full_name, G_employee_number
        from PER_PEOPLE_F P
       WHERE P.PERSON_ID =  p_incurred_by_person_id
         AND TRUNC(p_EXPENDITURE_ENDING_DATE) BETWEEN P.EFFECTIVE_START_DATE AND P.EFFECTIVE_END_DATE ;
   end if ;

   if p_mode = 'EMP_NAME' then
      Return G_full_name;
   else
      Return G_employee_number ;
   end if ;
   EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return NULL ;
end ;

  Function get_wip_resource_code(p_wip_resource_id IN NUMBER ) Return VARCHAR2 IS
    l_resource_code VARCHAR2(30) := null;
    begin
      select resource_code
        into l_resource_code
       from  bom_resources
        where resource_id = p_wip_resource_id ;
      return l_resource_code;

    Exception
     WHEN NO_DATA_FOUND then
       return l_resource_code ;
    end ;

 FUNCTION get_inventory_item(p_inventory_item_id  IN NUMBER) Return VARCHAR2 IS
 l_inventory_item VARCHAR2(4000):= NULL  ; /* Modified the size for the bug 6652655 */
  begin
   Select Concatenated_Segments
     into l_inventory_item
     from Mtl_System_Items_Kfv
    where Inventory_Item_Id = p_inventory_item_id
      and rownum = 1 ;
      --and  Organization_Id = p_Incurred_By_Organization_Id ; -- fix for bug : 3181386
      return l_inventory_item ;
  Exception
   when NO_DATA_FOUND then
    return l_inventory_item ;
  end ;

-- New function, created for AP Invoice Lines Uptake for R12, to get the check number for passed invoice payment id.

FUNCTION get_invoice_payment_num(p_transaction_source IN VARCHAR2,p_inv_payment_id  IN VARCHAR2) Return NUMBER IS
  l_inv_payment_id  NUMBER:= NULL  ;
  Begin

If (PA_UTILS4.get_ledger_cash_basis_flag = 'Y' or p_transaction_source = 'AP DISCOUNTS')  Then -- Accounting Method is Cash.

     select chk.check_number
     into   l_inv_payment_id
     from   ap_checks chk,
            ap_invoice_payments pay
    where   pay.check_id = chk.check_id
    and     pay.invoice_payment_id = to_number(NVL2(LTRIM(p_inv_payment_id,'0123456789'), NULL, p_inv_payment_id));

End If;

    return l_inv_payment_id;

  Exception
   when NO_DATA_FOUND then
    return l_inv_payment_id;
  End ;

-- New function, created for AP Invoice Lines Uptake for R12, to get sla cash basis flag.

FUNCTION get_ledger_cash_basis_flag Return VARCHAR2 IS
  l_ledger_cash_basis_flag  VARCHAR2(1) := 'N';
  Begin

      select nvl(glsla.sla_ledger_cash_basis_flag,'N')
      into   l_ledger_cash_basis_flag
      from   gl_ledgers glsla,
             pa_implementations imp
      where  glsla.ledger_id = imp.set_of_books_id;

      return l_ledger_cash_basis_flag;

  Exception
   when NO_DATA_FOUND then
    return l_ledger_cash_basis_flag;
  End ;

/*----------------------------------------------------------------------------*/
-- Start of Comments
-- API name                      : IsProjectsImplemented
-- Type                          : Public Function
-- Pre-reqs                      : None
-- Function                      : To check if Projects is implemented for a given OU
-- Return Value                  : VARCHAR2
-- Prameters
-- p_org_id               IN    NUMBER  REQUIRED
--  History
--  05-MAY-05   Vgade                    -Created
--
/*----------------------------------------------------------------------------*/
FUNCTION IsProjectsImplemented(p_org_id IN Number) RETURN VARCHAR2 IS

	l_pa_implemented  varchar2(1) := 'N';

BEGIN
		SELECT 'Y'
		INTO   l_pa_implemented
		FROM   pa_implementations_all
                WHERE  org_id = p_org_id;

	Return l_pa_implemented;

EXCEPTION

	WHEN OTHERS THEN
            l_pa_implemented := 'N';
            RETURN l_pa_implemented;

END IsProjectsImplemented;

END pa_utils4;

/
