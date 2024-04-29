--------------------------------------------------------
--  DDL for Package Body PA_GL_TIEBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_GL_TIEBACK_PKG" As
/* $Header: PAGLTIEB.pls 115.3 2002/04/15 21:12:10 pkm ship        $*/

Procedure PA_GL_TIEBACK  (
                         P_Module     In      Varchar2,
                         X_COUNT      Out     Number ,
                         X_ERROR      Out     VARCHAR2
                         )

Is
L_Interface_Process Varchar2(30) := Null;
L_Count Number := 0;
L_Interface_Is_Running varchar2(1):= 'N';

        CURSOR interface IS
        SELECT 'Y'
        FROM    fnd_concurrent_requests req,
                fnd_concurrent_programs prog,
                fnd_executables exe
        WHERE   req.program_application_id = prog.application_id
          AND   req.concurrent_program_id = prog.concurrent_program_id
          AND   req.phase_code = 'R'
          AND   prog.executable_application_id = exe.application_id
          AND   prog.executable_id = exe.executable_id
          AND   exe.executable_name = L_Interface_Process;


        Cursor Corruption_Labor is
        SELECT gi.RowId Row_Id from Pa_Gl_Interface gi
        WHERE  Status = 'NEW'
        AND    not exists (Select 0 from gl_Interface_control gc where gc.group_id = gi.group_id)
        AND    user_je_category_name in ( select user_je_category_name
                                          from   gl_je_Categories where je_category_name='Labor Cost');

        Cursor Corruption_Usage is
        SELECT gi.RowId Row_Id from Pa_Gl_Interface gi
        WHERE  Status = 'NEW'
        AND    not exists (Select 0 from gl_Interface_control gc where gc.group_id = gi.group_id)
        AND    user_je_category_name in ( select user_je_category_name
                                          from   gl_je_Categories where je_category_name
						 in ('Budget','Usage Cost'));


        Cursor Corruption_Burden is
        SELECT gi.RowId Row_Id from Pa_Gl_Interface gi
        WHERE  Status = 'NEW'
        AND    not exists (Select 0 from gl_Interface_control gc where gc.group_id = gi.group_id)
        AND    user_je_category_name in ( select user_je_category_name
                                          from   gl_je_Categories where je_category_name='Total Burdened Cost');


        Cursor Corruption_Revenue is
        SELECT gi.RowId Row_Id from Pa_Gl_Interface gi
        WHERE  Status = 'NEW'
        AND    not exists (Select 0 from gl_Interface_control gc where gc.group_id = gi.group_id)
        AND    user_je_category_name in ( select user_je_category_name
                                          from   gl_je_Categories where je_category_name='Revenue');



        Cursor Corruption_CrossCharge is
        SELECT gi.RowId Row_Id from Pa_Gl_Interface gi
        WHERE  Status = 'NEW'
        AND    not exists (Select 0 from gl_Interface_control gc where gc.group_id = gi.group_id)
        AND    user_je_category_name in ( select user_je_category_name
                                          from   gl_je_Categories where je_category_name
					  in (Select    gjc.je_category_name
    						FROM    gl_je_categories gjc,
            						pa_lookups pl
      					       WHERE 	pl.meaning = gjc.JE_CATEGORY_NAME
      						 and 	pl.lookup_type = 'CC_CCD_LINE_TYPE_JE_CATEGORY'));



Begin

/* Identifying whether any relevant Interface process is running If not the corrupted records
   will be marked as rejected. The cprrupted records means where Status is NEW and No record
   exists in gl_interface control table for relevant group id */

	If 	P_Module =  'LABOR' Then
		L_Interface_Process := 'PAGGLT';
	Elsif	P_Module = 'USAGE' Then
		L_Interface_Process := 'PASGLT';
	Elsif	P_Module = 'REVENUE' Then
		L_Interface_Process := 'PATTGL';
	Elsif	P_Module = 'BURDEN' Then
		L_Interface_Process := 'PACTFTBC';
	Elsif	P_Module = 'BORRLENT' Then
		L_Interface_Process := 'PACCGLTR';
        End If;

       OPEN interface; /* Check if Interface is running */
                FETCH Interface INTO L_Interface_Is_Running;
                CLOSE Interface;

            IF ( nvl(L_Interface_Is_Running,'N') = 'N' ) THEN /* If No Process is running update
								corrupted data as rejected */

		IF P_Module = 'LABOR' Then
		For Rec In Corruption_labor Loop

		Update PA_GL_Interface
		Set    Status = 'PREV_GL_INTERFACE_UNSUCCESSFUL'
		Where  RowId = Rec.Row_Id;

		L_Count := L_Count + Sql%rowcount;

		End Loop;
		END IF; /* Calling Modulr LABOR */

                IF P_Module = 'USAGE' Then
                For Rec In Corruption_usage Loop

                Update PA_GL_Interface
                Set    Status = 'PREV_GL_INTERFACE_UNSUCCESSFUL'
                Where  RowId = Rec.Row_Id;

                L_Count := L_Count + Sql%rowcount;

                End Loop;
                END IF; /* Calling Module USAGE */

                IF P_Module = 'BURDEN' Then
                For Rec In Corruption_burden Loop

                Update PA_GL_Interface
                Set    Status = 'PREV_GL_INTERFACE_UNSUCCESSFUL'
                Where  RowId = Rec.Row_Id;

                L_Count := L_Count + Sql%rowcount;

                End Loop;
                END IF; /* Calling Modulr BURDEN */

                IF P_Module = 'REVENUE' Then
                For Rec In Corruption_revenue Loop

                Update PA_GL_Interface
                Set    Status = 'PREV_GL_INTERFACE_UNSUCCESSFUL'
                Where  RowId = Rec.Row_Id;

                L_Count := L_Count + Sql%rowcount;

                End Loop;
                END IF; /* Calling Modulr REVENUE */

                IF P_Module = 'BORRLENT' Then
                For Rec In Corruption_CrossCharge Loop

                Update PA_GL_Interface
                Set    Status = 'PREV_GL_INTERFACE_UNSUCCESSFUL'
                Where  RowId = Rec.Row_Id;

                L_Count := L_Count + Sql%rowcount;

                End Loop;
                END IF; /* Calling Modulr BORRLENT */

             END IF;  /* End Process is not running */

X_COUNT := L_Count;

Exception
 When Others Then
	X_COUNT := L_Count;
	X_ERROR := SQLCODE;
End PA_GL_TIEBACK;
End PA_GL_TIEBACK_PKG;

/
