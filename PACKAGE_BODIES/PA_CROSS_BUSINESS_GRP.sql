--------------------------------------------------------
--  DDL for Package Body PA_CROSS_BUSINESS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CROSS_BUSINESS_GRP" 
--  $Header: PAXCBGAB.pls 120.2 2005/08/19 17:11:01 mwasowic noship $
AS

G_package_name 	VARCHAR2(30)   := 'Pa_Cross_Business_Grp';

/* The following global variables are used to track the size of the
 * plsql table and the name and type of plsql tables being used.
 */
TABLE_SIZE      BINARY_INTEGER := 0;
type VAL_TAB_TYPE  is table of NUMBER index by binary_integer;
type NAME_TAB_TYPE is table of varchar2(80) index by binary_integer;

G_FromJobToGrp	NAME_TAB_TYPE;
G_ToJob		VAL_TAB_TYPE;



FUNCTION IsMappedToJob	(P_From_Job_Id IN NUMBER, P_To_Job_Group_Id IN NUMBER ) RETURN NUMBER

IS

	/* This function should be used by views and conditional type of needs to return the
         * ToJobId based on the FromJobId and ToJobGroupId passed in.  Note that we use view
         * pa_job_relationships_view to accomplish this if the FromJobId ToJobGroupId has not
         * been stored in the plsql table already.  If view has to be checked to get the
         * ToJobId then the value retrieved will be placed in the plsql table for performance
         * improvements.
	 */

	l_To_Job_Id 	  NUMBER ;
	l_From_Job_Grp_Id NUMBER;
	l_Status_Code 	  VARCHAR2(30) ;
	l_Error_Stage	  VARCHAR2(250) ;
	l_Error_Code	  NUMBER ;
	l_FromJobToGrp	  VARCHAR2(30);

	TABLE_INDEX	binary_integer;

BEGIN

	l_FromJobToGrp := to_char(P_From_Job_Id) || '-' || to_char(P_To_Job_Group_Id);

	/* Try are retrieve from the plsql table the index that corrolates to the
         * concatenated combination of FromJobId ToJobGroupId.
	 */
	TABLE_INDEX := FindJobIndex(l_FromJobToGrp);

	If TABLE_INDEX < TABLE_SIZE Then
        	/* If an index is returned that is less than the table size then we how found a
                 * match and can return the value from the other plsql table that stores the
                 * ToJobId.  Note that the first time thru table_index and table_size are the
                 * same value 0.  So it knows to do the else the first time thru.
                 */
            	RETURN( G_ToJob(TABLE_INDEX) ) ;
        Else
		/* If the table_index value is not less than table_size then no match was
                 * found so get the value from the view and store it in plsql table using the
                 * current table size as the next available index to use.  Then increment
                 * table_size by one so that it has a count of 1 more that the size
                 * of the plsql table.
		 */

        	SELECT job_group_id
        	INTO l_From_Job_Grp_Id
        	FROM per_jobs
        	WHERE job_id = P_From_Job_Id ;

        	If l_From_Job_Grp_Id IS NULL Then
               		/* Job Group Id is not a NOT NULL column so must check for it being null */
                	RETURN ( NULL ) ;

        	ElsIf l_From_Job_Grp_Id = P_To_Job_Group_Id Then
                	/* If the From/To Job Groups are same then return the From Job Id
			 * This can be the case if the customer chooses not the define relationships
                         * at all or chooses the HR job group for either cost job group or bill job group.
                         */
                        G_FromJobToGrp(TABLE_SIZE) := l_FromJobToGrp;
                        G_ToJob(TABLE_SIZE) := P_From_Job_Id ;

                        TABLE_SIZE := TABLE_SIZE + 1;
                	RETURN ( P_From_Job_Id ) ;

       		Else
			/* If the From/To Job Groups are different then get the To Job Id from the
			 * job relationships view.
			 */
        		select to_job_id
			into l_To_Job_Id
        		from pa_job_relationships_view
        		where from_job_id = P_From_Job_Id
        		and   to_job_group_id = P_To_Job_Group_Id ;

			G_FromJobToGrp(TABLE_SIZE) := l_FromJobToGrp;
			G_ToJob(TABLE_SIZE) := l_To_Job_Id;

			TABLE_SIZE := TABLE_SIZE + 1;

			RETURN ( l_To_Job_Id ) ;
		End If;
	End If;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN ( NULL );
	WHEN OTHERS THEN
		RAISE ;

END IsMappedToJob;

PROCEDURE GetMappedToJob (
			P_From_Job_Id IN NUMBER,
			P_To_Job_Group_Id IN NUMBER,
			X_To_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER )  --File.Sql.39 bug 4440895

IS
	/* This procedure is used when you only looking for a single
         * value being returned.  It populates locally defined plsql tables
         * and then passes the values to the the GetMappedToJobs which handles
         * arrays of data for process and requires that arrays of data be passed
         * to it. Once returning from GetMappedToJobs the single value is extracted
         * and returned in the OUT variable.
         */
	l_From_Job_Id_Tab	PA_PLSQL_DATATYPES.IdTabTyp;
	l_To_Job_Group_Id_Tab	PA_PLSQL_DATATYPES.IdTabTyp;
	l_To_Job_Id_Tab		PA_PLSQL_DATATYPES.IdTabTyp;
	l_Status_Code_Tab	PA_PLSQL_DATATYPES.Char30TabTyp;
	l_Error_Stage		VARCHAR2(150) := NULL ;
	l_Error_Code		NUMBER := NULL ;

BEGIN

	pa_cc_utils.set_curr_function(G_package_name || '.GetMappedToJob().');
	pa_cross_business_grp.ErrorStage(
			P_Message => '20.10: Assign input variables to local table variables.',
			X_Stage => X_Error_Stage);

	l_From_Job_Id_Tab(1) := P_From_Job_Id ;
	l_To_Job_Group_Id_Tab(1) := P_To_Job_Group_Id ;

	/* The following two variables are set to NULL intentionally. */
	l_To_Job_Id_Tab(1) := NULL ;
	l_Status_Code_Tab(1) := NULL ;

        pa_cross_business_grp.ErrorStage(
		P_Message => '20.20: Calling procedure ' || G_package_name || '.GetMappedToJobs().',
		X_Stage => X_Error_Stage );

	pa_cross_business_grp.GetMappedToJobs (
			P_From_Job_Id_Tab => l_From_Job_Id_Tab ,
			P_To_Job_Group_Id_Tab => l_To_Job_Group_Id_Tab ,
			X_To_Job_Id_Tab => l_To_Job_Id_Tab ,
			X_StatusTab => l_Status_Code_Tab ,
			X_Error_Stage => l_Error_Stage ,
			X_Error_Code => l_Error_Code ) ;

        pa_cross_business_grp.ErrorStage(
		P_Message => '20.30: Assigning returned value of To_Job_id.',
		X_Stage => X_Error_Stage );

	X_To_Job_Id := l_To_Job_Id_Tab(1) ;

        pa_cross_business_grp.ErrorStage(
		P_Message => '20.40: Exiting the procedure ' || G_package_name || '.GetMappedToJob().',
                X_Stage => X_Error_Stage );

	pa_cc_utils.reset_curr_function;

EXCEPTION
	WHEN OTHERS THEN
		RAISE ;

END GetMappedToJob;

PROCEDURE GetMappedToJobs (
			P_From_Job_Id_Tab IN PA_PLSQL_DATATYPES.IdTabTyp,
			P_To_Job_Group_Id_Tab IN PA_PLSQL_DATATYPES.IdTabTyp,
			X_To_Job_Id_Tab OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
			X_StatusTab OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER ) --File.Sql.39 bug 4440895

IS
	/* This procedure is designed to process table arrays so that a single
         * run will process 1 or more rows of data before returning the calling
         * procedure/pro*c program.

	/* This cursor is used to retrieve the to_job_id based on the FromJobId and
         * ToGrpId passed in if the combination was not already found and stored in
         * plsql table array within this current sql session.
	 */
	cursor getJob(	from_job_id IN NUMBER,
      			to_grp_id     IN NUMBER)  IS
	select to_job_id
	from pa_job_relationships_view
	where from_job_id = from_job_id
	and   to_job_group_id = to_grp_id ;

	l_MinRecs		NUMBER ;
	l_MaxRecs		NUMBER ;
	l_From_Job_Grp_Id	NUMBER ;

        l_FromJobToGrp  VARCHAR2(30);

        TABLE_INDEX     binary_integer;

BEGIN

	pa_cc_utils.set_curr_function(G_package_name || '.GetMappedToJobs().');

        pa_cross_business_grp.ErrorStage(
		P_Message => '30.10: Assign Min and Max recs based on number of records in table.',
                X_Stage => X_Error_Stage );

 	l_MinRecs  := P_From_Job_Id_Tab.FIRST ;
    	l_MaxRecs := P_From_Job_Id_Tab.LAST ;

        pa_cross_business_grp.ErrorStage(
                P_Message => '30.15: Begin looping thru all the records in the table and process the data.',
                X_Stage => X_Error_Stage );

	/* From the passed in arrays a determination is made on the number of records that
         * have been passed in and need to be processed in the LOOP.
	 */
	FOR j IN l_MinRecs..l_MaxRecs
    	LOOP

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '30.20: Concatenate the From_Job_Id with To_Job_Group_Id.',
                	X_Stage => X_Error_Stage );

		l_FromJobToGrp := to_char(P_From_Job_Id_Tab(j)) || '-' ||
				  to_char(P_To_Job_Group_Id_Tab(j));

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '30.25: Check if the job is already stored in the array table.',
                	X_Stage => X_Error_Stage );

                /* Try are retrieve from the plsqsql table the index that corrolates to the
                 * concatenated combination of FromJobId ToJobGroupId.
                 */
        	TABLE_INDEX := FindJobIndex(l_FromJobToGrp);

        	IF TABLE_INDEX < TABLE_SIZE THEN
                        /* If table_index is that is less than the table size then we how found a
                         * match and can return the value from the other plsql table that stores
                         * the ToJobId.  Note that the first time thru table_index and table_size
                         * are the same value 0.  So it knows to do the else the first time thru.
                         */
                	X_To_Job_Id_Tab(j) := G_ToJob(TABLE_INDEX);

        	ELSE
	                /* If the table_index value is not less than table_size then no match was
       	          	 * found, get the value from the cursor and store in plsql table using the
       	          	 * current table size as the next available index to use.  Then increment
       	          	 * table_size by one so that it has a count of 1 more that the size
       	          	 * of the plsql table.
       	          	 */

                        pa_cross_business_grp.ErrorStage(
                                P_Message => '30.26: Get GroupId for From Job Id.',
                                X_Stage => X_Error_Stage );

                        SELECT job_group_id
                        INTO l_From_Job_Grp_Id
                        FROM per_jobs
                        WHERE job_id = P_From_Job_Id_Tab(j) ;

                        If l_From_Job_Grp_Id = P_To_Job_Group_Id_Tab(j) Then

                               pa_cross_business_grp.ErrorStage(
                                        P_Message => '30.28: If From/To Job Groups are same then return From Job Id.',
                                        X_Stage => X_Error_Stage );

                                G_FromJobToGrp(TABLE_SIZE) := l_FromJobToGrp;
                                G_ToJob(TABLE_SIZE) := P_From_Job_Id_Tab(j);

				TABLE_SIZE := TABLE_SIZE + 1;

			Else
                		pa_cross_business_grp.ErrorStage(
                        		P_Message => '30.30: Open the cursor getJob.',
                        		X_Stage => X_Error_Stage );

				OPEN getJob(P_From_Job_Id_Tab(j), P_To_Job_Group_Id_Tab(j));

                		pa_cross_business_grp.ErrorStage(
                        		P_Message => '30.40: Fetch record from cursor getJob.',
                        		X_Stage => X_Error_Stage );

                		FETCH getJob
                		INTO X_To_Job_Id_Tab(j);

 				If getJob%NOTFOUND Then

                        		pa_cross_business_grp.ErrorStage(
                                		P_Message => '30.50: If NO_DATA_FOUND then set variables appropriately.',
                                		X_Stage => X_Error_Stage );

					X_To_Job_Id_Tab(j) := NULL;
					X_StatusTab(j) := 'PA_CBGA_NO_MAPPING_EXISTS' ;

				Else

                                	pa_cross_business_grp.ErrorStage(
                                        	P_Message => '30.55: If FOUND then store in table arrays.',
                                        	X_Stage => X_Error_Stage );

			        	G_FromJobToGrp(TABLE_SIZE) := l_FromJobToGrp;
                			G_ToJob(TABLE_SIZE) := X_To_Job_Id_Tab(j);

                			TABLE_SIZE := TABLE_SIZE + 1;
				End If;

                        	pa_cross_business_grp.ErrorStage(
                                	P_Message => '30.60: Close cursor getJob.',
                                	X_Stage => X_Error_Stage );

				Close getJob;

			End If;
		End If;

                pa_cross_business_grp.ErrorStage(
                        P_Message => '30.70: End Loop.',
                        X_Stage => X_Error_Stage );

	END LOOP ;

        pa_cross_business_grp.ErrorStage(
                P_Message => '30.80: Exiting procedure ' || G_package_name || '.GetMappedToJobs().',
                X_Stage => X_Error_Stage );

	pa_cc_utils.reset_curr_function;

EXCEPTION
	WHEN OTHERS THEN
		RAISE ;

END GetMappedToJobs ;

FUNCTION IsCrossBGProfile RETURN VARCHAR2

IS

	l_Status_Code VARCHAR2(30) ;
	l_Error_Stage VARCHAR2(150) ;
	l_Error_Code NUMBER;

BEGIN
	IF pa_cross_business_grp.G_CrossBGProfile IS NULL THEN
		pa_cross_business_grp.G_CrossBGProfile := FND_PROFILE.VALUE('HR_CROSS_BUSINESS_GROUP');
	END IF;


	RETURN (pa_cross_business_grp.G_CrossBGProfile ) ;

EXCEPTION
	WHEN OTHERS THEN
		RAISE ;

END IsCrossBGProfile ;


PROCEDURE GetMasterGrpId  (
			P_Business_Group_Id IN NUMBER DEFAULT NULL,
			X_Master_Grp_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER )  --File.Sql.39 bug 4440895

IS
	BUSINESS_GROUP_NEEDED EXCEPTION;

BEGIN
	pa_cc_utils.set_curr_function(G_package_name || '.GetMasterGrpId().');

        pa_cross_business_grp.ErrorStage(
                P_Message => '40.10: Check if the Global Master Group Id is already populated.',
                X_Stage => X_Error_Stage );

        /* If the Global variable G_MasterGroupId is null then we need to get it
         * and store in the the global variable otherwise we will return the value from the
         * global variable and return it the the calling procedure.  At any given point there
         * should be only 1 master group id for a given business group/enterprise so a global
         * variable can be used.
         */
	If pa_cross_business_grp.G_MasterGroupId IS NULL Then

		pa_cross_business_grp.ErrorStage(
			P_Message => '40.20: Check if the Business Group is NULL.',
			X_Stage => X_Error_Stage );

		/* IF the profile HR_CROSS_BUSINESS_GROUP is 'N' Then it is expected that the
                 * calling procedure will pass in the business group since it is then required.
                 */
		If pa_cross_business_grp.IsCrossBGProfile = 'N' AND P_Business_Group_Id IS NULL Then
			RAISE BUSINESS_GROUP_NEEDED;
		End If;

                pa_cross_business_grp.ErrorStage(
                        P_Message => '40.30: Get the Master Group Id.',
                        X_Stage => X_Error_Stage );

		/* Based on the profile HR_CROSS_BUSINESS_GROUP this select statement will
                 * return the master group id.  Note that the way it is written if the customer
                 * has more than a single master group  or no master group for either the
                 * enterprise or the business group defined then either TOO MANY ROWS or
                 * NO DATA FOUND will occur and will be handled appropriately in the
                 * exception handler.  This can occur since HR is not restricting the form
                 * they are creating in this way, so we have to check and handle this in PA.
		 */
		select job_group_id
		into x_master_grp_id
		from per_job_groups
		where pa_cross_business_grp.IsCrossBGProfile = 'N'
		and business_group_id = P_Business_group_Id
		and master_flag = 'Y'
		 UNION ALL
		select job_group_id
		from per_job_groups
		where pa_cross_business_grp.IsCrossBGProfile = 'Y'
		and master_flag = 'Y' ;

		pa_cross_business_grp.ErrorStage(
                        P_Message => '40.40: Assign master group id to Global variable.',
                        X_Stage => X_Error_Stage );

		pa_cross_business_grp.G_MasterGroupId := x_master_grp_id;

 	Else

                pa_cross_business_grp.ErrorStage(
                        P_Message => '40.50: Get master group id from Global variable.',
                        X_Stage => X_Error_Stage );

		x_master_grp_id := pa_cross_business_grp.G_MasterGroupId;

  	End If;

        pa_cross_business_grp.ErrorStage(
                P_Message => '40.60:Exiting procedure ' || G_package_name || '.GetMasterGrpId().',
                X_Stage => X_Error_Stage );

	pa_cc_utils.reset_curr_function;


EXCEPTION
	WHEN BUSINESS_GROUP_NEEDED THEN
		X_Status_Code := 'PA_CBGA_BG_NEEDED' ;

	WHEN TOO_MANY_ROWS THEN
		/* This can occur if the customer defines more than 1 master group for the
                 * enterprise or business group which is being used.
                 */
		If pa_cross_business_grp.IsCrossBGProfile = 'Y' Then
			X_Status_Code := 'PA_CBGA_MULTI_GRP_G' ;
		Else
			X_Status_Code := 'PA_CBGA_MULTI_GRP_S' ;
		End If;

	WHEN NO_DATA_FOUND THEN
		/* This can occur if the customer has not flagged any of the job group for either
                 * the enterprise or business group, as appropriate.
                 */
		If pa_cross_business_grp.IsCrossBGProfile = 'Y' Then
			X_Status_Code := 'PA_CBGA_NO_MASTER_G' ;
		Else
			X_Status_Code := 'PA_CBGA_NO_MASTER_S' ;
		End If;

	WHEN OTHERS THEN
		x_error_code := SQLCODE;
		RAISE;


END GetMasterGrpId ;

PROCEDURE GetGlobalHierarchy (
			P_Org_Structure_Id IN NUMBER,
			X_Global_Hierarchy OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER )  --File.Sql.39 bug 4440895

IS

BEGIN

	pa_cc_utils.set_curr_function(G_package_name || '.GetGlobalHierarchy().');

        pa_cross_business_grp.ErrorStage(
                P_Message => '50.10: Get the Global Hierarchy Flag using the Org Structure Id.',
                X_Stage => X_Error_Stage );

	Select decode(business_group_id,NULL,'Y','N')
	into X_Global_Hierarchy
	from per_organization_structures
	where  organization_structure_id = P_Org_Structure_id ;


        pa_cross_business_grp.ErrorStage(
                P_Message => '50.20:Exiting procedure ' || G_package_name || '.GetGlobalHierarchy().',
                X_Stage => X_Error_Stage );

	pa_cc_utils.reset_curr_function;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		X_Status_Code := 'PA_CBGA_BAD_ORG_STRC';
	WHEN OTHERS THEN
		RAISE ;

END GetGlobalHierarchy ;


PROCEDURE GetJobIds (	P_HR_Job_Id IN NUMBER,
			P_Project_Id IN NUMBER,
			X_Bill_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Bill_Job_Grp_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Cost_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Cost_Job_Grp_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_PP_Bill_Job_Id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
			X_Status_Code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Stage OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			X_Error_Code OUT NOCOPY NUMBER )  --File.Sql.39 bug 4440895

IS

	/* This procedure is assumed to be called from TRX IMPORT.
         * TRX Import has to derive the Job since it is not provide in table
         * pa_transaction_interface so it passed in the HR Job Id. Since TRX
         * IMPORT has to validate the Project that is in each record in the
         * pa_transaction_interface table TRX IMPORT passes in the project Id
         * as well.
         * The default Bill Job Group Id and Cost Job Group Id are retrieved and
         * then the cost job id and the bill job id all based on the HR Job Id
         * that is defined in HR for the employee.
         */
	MISSING_DATA	EXCEPTION;
	l_cost_job_group_id	NUMBER ;
	l_bill_job_group_id	NUMBER ;
	l_group_type		VARCHAR2(1);
	l_HR_Job_Group_Id       NUMBER ;

BEGIN

	pa_cc_utils.set_curr_function(G_package_name || '.GetJobIds().');

        pa_cross_business_grp.ErrorStage(
                P_Message => '60.05: Get the default cost job group for the project.',
                X_Stage => X_Error_Stage );

	l_group_type := 'C';

	l_cost_job_group_id :=
		pa_cross_business_grp.GetDefProjJobGrpId( P_Project_Id => P_Project_id,
						          P_Group_Type => l_group_type);

	pa_cross_business_grp.ErrorStage(
                P_Message => '60.10: Check if the default cost job group is populated.',
                X_Stage => X_Error_Stage );

	If l_cost_job_group_id IS NULL Then
                /* There does not have to be a default cost job group defined for
                 * a project.  This is optional.  In the case that it is not
                 * defined then return the cost_job_id, cost_grp_id as NULL.
                 */
		X_Cost_Job_Grp_Id := NULL;
		X_Cost_Job_Id := NULL;
	Else

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '60.20: Assign the cost job group id to the out variable.',
                	X_Stage => X_Error_Stage );

		X_Cost_Job_Grp_Id := l_cost_job_group_id;

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '60.80: Get the cost job id.',
                	X_Stage => X_Error_Stage );

        	X_Cost_Job_Id := IsMappedToJob( P_From_Job_id => P_HR_Job_Id,
                                        	P_To_Job_Group_id => l_cost_job_group_id ) ;

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '60.90: Check if the cost job id is NULL.',
                	X_Stage => X_Error_Stage );

        	If X_Cost_Job_Id IS NULL Then
                	X_Status_Code := 'PA_CBGA_NO_COST_JOB';
                	RAISE MISSING_DATA;
        	End If;
	End If;

        pa_cross_business_grp.ErrorStage(
                P_Message => '60.25: Get the default bill job group for the project.',
                X_Stage => X_Error_Stage );

	l_group_type := 'B';

	l_bill_job_group_id :=
		pa_cross_business_grp.GetDefProjJobGrpId( P_Project_Id => P_Project_id,
							  P_Group_Type => l_group_type) ;

        pa_cross_business_grp.ErrorStage(
                P_Message => '60.30: Check if the default bill job group is populated.',
                X_Stage => X_Error_Stage );

	If l_bill_job_group_id IS NOT NULL Then

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '60.40: Assign bill job group to the out variable.',
                	X_Stage => X_Error_Stage );

		X_Bill_Job_Grp_Id := l_bill_job_group_id;

		pa_cross_business_grp.ErrorStage(
                	P_Message => '60.50: Get the bill job id.',
                	X_Stage => X_Error_Stage );

		X_Bill_Job_Id := IsMappedToJob( P_From_Job_id => P_HR_Job_Id,
				       		P_To_Job_Group_id => l_bill_job_group_id) ;

		pa_cross_business_grp.ErrorStage(
                	P_Message => '60.60: Check if the bill job id is NULL.',
                	X_Stage => X_Error_Stage );

		If X_Bill_Job_Id IS NULL Then
			X_Status_Code := 'PA_CBGA_NO_BILL_JOB';
			RAISE MISSING_DATA;
		End If;

        	pa_cross_business_grp.ErrorStage(
                	P_Message => '60.70: Assign bill job id to PP bill job id.',
                	X_Stage => X_Error_Stage );

		X_PP_Bill_Job_Id := X_Bill_Job_Id;

	Else
		/* There does not have to be a default bill job group defined for
                 * a project.  This is optional.  In the case that it is not
                 * defined then return the bill_job_id, pp_bill_job_id, bill_grp_id
                 * as NULL.
		 */
		X_Bill_Job_Grp_Id := NULL;
		X_Bill_Job_Id := NULL;
		X_PP_Bill_Job_Id := NULL;
	End If;

	pa_cc_utils.reset_curr_function;

EXCEPTION
	WHEN MISSING_DATA THEN
		If pa_cross_business_grp.G_CrossBGProfile = 'Y' THEN
			X_Status_Code := X_Status_Code || 'G' ;
		Else
			X_Status_Code := X_Status_Code || 'S' ;

		End If;
	WHEN OTHERS THEN
		RAISE ;
END GetJobIds ;

FUNCTION GetDefProjJobGrpId (P_Project_Id IN NUMBER,
			     P_Group_Type IN VARCHAR2 ) RETURN NUMBER

IS
	l_JobGroupId NUMBER := NULL ;
BEGIN

	/* If P_Group_Type := 'C' then the cost job group id needs to be returned
         * If P_Group_Type := 'B' then the bill job group id needs to be returned
	 * If the project for some reason does not exist then NULL is returned.
	 */

	select decode(P_Group_Type,'C',cost_job_group_id,'B',bill_job_group_id)
	into l_JobGroupId
	from pa_projects_all
	where project_id = P_Project_Id ;

	RETURN ( l_JobGroupId ) ;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN ( to_number( NULL ) ) ;
	WHEN OTHERS THEN
		RAISE ;

END GetDefProjJobGrpId ;

FUNCTION FindJobIndex ( P_From_Job_To_Grp IN VARCHAR2 ) RETURN BINARY_INTEGER

IS

	/* TABLE_SIZE is always one larger that the number of records stored in
         * the plsql table except the first time that this function is called at
         * which time both the tab_index and table_size will be 0 and the function
         * immediately returns 0 to the calling procedure which is fine.
         */

	TAB_INDEX	binary_integer;
	FOUND    	boolean;

BEGIN
	TAB_INDEX  := 0;
        FOUND      := false;

	/* Passing in the concatenated value the check for in the plsql table
         * G_FromJobToGrp we are looking for match so that we can return the index
         * back to the calling procedure/function. If not FOUND is to break out the
         * the loop if a match is found before getting to the end of the plsql table.
         * Once a match is found the FOUND := TRUE and the the loop is stopped.
         * Until a match is found or reaching the end of the plsqpl table keep
         * on incrementing tab_index by 1.  If the index is found the return it to the
         * calling procedure it will be the same number as the table_size which is what
         * we want.
         */
        while (TAB_INDEX < TABLE_SIZE) and (not FOUND) loop
            if G_FromJobToGrp(TAB_INDEX) = P_From_Job_To_Grp then
                FOUND := true;
            else
                TAB_INDEX := TAB_INDEX + 1;
            end if;
        end loop;

       	return TAB_INDEX;

END FindJobIndex;

FUNCTION HRJobGroupIs ( P_Business_Group_Id IN NUMBER ) RETURN NUMBER

IS

        JobGroup        NUMBER;

BEGIN

	SELECT JOB_GROUP_ID
	INTO JobGroup
	FROM PER_JOB_GROUPS
	WHERE BUSINESS_GROUP_ID = P_Business_Group_Id
	AND   INTERNAL_NAME LIKE 'HR_%';

	RETURN ( JobGroup );

EXCEPTION
	WHEN OTHERS THEN
		RETURN ( NULL );

END HRJobGroupIs;

PROCEDURE ErrorStage( P_Message IN VARCHAR2,
		      X_Stage OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
	/* This is a centralized location to indicate the location in the package is in
         * at each step of the way so as to be able to pinpoint if an error occurs where
         * it happened.
	 */

BEGIN

       	X_Stage := P_Message;
       	pa_cc_utils.log_message(P_Message);

END ErrorStage;

/* End of API */
END ;

/
