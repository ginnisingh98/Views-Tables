--------------------------------------------------------
--  DDL for Package Body PA_PURGE_CAPITAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_CAPITAL" AS
/* $Header: PAXGCPPB.pls 120.3.12010000.2 2009/06/05 14:48:55 kmaddi ship $ */

    l_commit_size     NUMBER ;
    l_err_stage       VARCHAR2(500);

    -- This procedure is called from the main purge program. The
    -- parameters passed to this procedure are as follows

/*  * p_purge_batch_id		-> Purge batch Id
    * p_project_id		-> Project Id
    * p_purge_release		-> The release during which it is purged
    * p_archive_flag		-> This flag will indicate if the  records need to be archived
				   before they are purged.
    * p_txn_to_date		-> Date through which the transactions need to be purged. This
                                   value will be NULL if the purge batch is for closed projects.
    * p_commit_size		-> The maximum number of records that can be allowed to remain
				   uncommited. If the number of records processed goes beyond
                                   this number then the process is commited.
*/



PROCEDURE PA_Capital_Main_Purge (p_purge_batch_id	in NUMBER,
				 p_project_id		in NUMBER,
				 p_purge_release	in VARCHAR2,
				 p_txn_to_date		in DATE,
				 p_archive_flag		in VARCHAR2,
				 p_commit_size		in NUMBER,
				 p_err_stack		in OUT NOCOPY VARCHAR2,
				 p_err_stage		in OUT NOCOPY VARCHAR2,
				 p_err_code		in OUT NOCOPY VARCHAR2) IS

  l_old_err_stack      VARCHAR2(2000);

  BEGIN

    p_err_code := 0;

    l_old_err_stack := p_err_stack;

    p_err_stack := p_err_stack || ' ->Before call to purge the data ';

    -- Call the procedure to delete Project Asset Line Details

    pa_debug.debug('*-> About to purge Asset Line Details ') ;

    l_err_stage := 'Before calling PA_Purge_Capital.PA_MC_AsstLinDtls';

    PA_Purge_Capital.PA_MC_AsstLinDtls(p_purge_batch_id    => p_purge_batch_id,
                                       p_project_id        => p_project_id,
                                       p_txn_to_date       => p_txn_to_date,
                                       p_purge_release     => p_purge_release,
                                       p_archive_flag      => p_archive_flag,
                                       p_commit_size       => p_commit_size,
                                       p_err_code          => p_err_code,
                                       p_err_stack         => p_err_stack,
                                       p_err_stage         => p_err_stage) ;

    l_err_stage := 'Before calling PA_Purge_Capital.PA_AsstLineDtls';

    IF p_err_code = 0 then
      PA_Purge_Capital.PA_AsstLineDtls(p_purge_batch_id  => p_purge_batch_id,
                                       p_project_id      => p_project_id,
                                       p_txn_to_date     => p_txn_to_date,
                                       p_purge_release   => p_purge_release,
                                       p_archive_flag    => p_archive_flag,
                                       p_commit_size     => p_commit_size,
                                       p_err_code        => p_err_code,
                                       p_err_stack       => p_err_stack,
                                       p_err_stage       => p_err_stage) ;
    End IF;

    IF p_err_code = 0 THEN
       p_err_stack := l_old_err_stack;
    End IF;

EXCEPTION
  WHEN OTHERS THEN
    p_err_code := -1;
    p_err_stage := to_char(SQLCODE);
    FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name        => 'PA_PURGE_CAPITAL',
            p_procedure_name  => 'PA_CAPITAL_MAIN_PURGE'||'-'||l_err_stage,
            p_error_text      => 'ORA-'||LPAD(substr(p_err_stage,2),5,'0'));

    RAISE ;

END PA_Capital_Main_Purge ;



/********** Procedure Rearchitured bug 36137398 ***********/

PROCEDURE PA_MC_AsstLinDtls (p_purge_batch_id	IN NUMBER,
	                     p_project_id       IN NUMBER,
			     p_txn_to_date	IN DATE,
			     p_purge_release	IN VARCHAR2,
			     p_archive_flag	IN VARCHAR2,
			     p_commit_size	IN NUMBER,
			     p_err_code		IN OUT NOCOPY NUMBER,
			     p_err_stack        IN OUT NOCOPY VARCHAR2,
			     p_err_stage	IN OUT NOCOPY VARCHAR2)    IS

  l_old_err_stack       VARCHAR2(2000);
  NoOfRecordsIns        NUMBER;
  NoOfRecordsDel        NUMBER;

  l_sob            		   PA_PLSQL_DATATYPES.Num15TabTyp;
  l_asset_line_uniq_id 	   PA_PLSQL_DATATYPES.Num15TabTyp;
  l_asset_line_id		   PA_PLSQL_DATATYPES.Num15TabTyp;
  l_cip_cost			   PA_PLSQL_DATATYPES.Num15TabTyp;
  l_cur_code		       PA_PLSQL_DATATYPES.Char30TabTyp;
  l_exc_rate			   PA_PLSQL_DATATYPES.Num15TabTyp;
  l_conv_date			   PA_PLSQL_DATATYPES.DateTabTyp;

CURSOR c_ast_ln_det_ar Is
SELECT   pmald.Set_Of_Books_Id,
              pmald.Proj_Asset_Line_Dtl_Uniq_Id,
              pmald.Project_Asset_Line_Detail_Id,
              pmald.Cip_Cost,
              pmald.Currency_Code,
              pmald.Exchange_Rate,
              pmald.Conversion_Date
        FROM
              PA_Expenditure_Items_All pei ,
              PA_Project_Asset_Line_Details pald,
              pa_implementations_all pia ,
              -- gl_mc_reporting_options gmc ,
              GL_ALC_LEDGER_RSHIPS_V gmc, -- R12 Ledger changes
              PA_MC_Prj_Ast_Line_Dtls pmald
      WHERE
             pald.proj_asset_line_dtl_uniq_id = pmald.proj_asset_line_dtl_uniq_id
        AND  pald.Expenditure_Item_id = pei.Expenditure_Item_id
        AND  pei.project_id = p_project_id
        AND  NVL(pia.ORG_ID,-99) = NVL(pei.ORG_ID,-99)
        AND  gmc.SOURCE_LEDGER_ID = pia.SET_OF_BOOKS_ID
        AND  gmc.APPLICATION_ID  = 275
        AND  gmc.Org_Id  = pia.ORG_ID
        AND  pmald.SET_OF_BOOKS_ID = gmc.LEDGER_ID;

  BEGIN

    p_err_code := 0;

    l_old_err_stack := p_err_stack;

    p_err_stack := p_err_stack || ' ->Before insert into PA_MC_PRJ_AST_LINE_DETS_AR' ;

    Open c_ast_ln_det_ar;

	LOOP

        l_commit_size := p_commit_size;  /* -- Bug#6609009 -- */

	  IF p_archive_flag = 'Y' THEN
        -- If archive option is selected then the records are inserted into the archive tables
        -- before being purged. The where condition is such that only the it inserts half the
        -- no. of records specified in the commit size.
        l_commit_size := p_commit_size / 2 ;
	  End If;

	l_commit_size := NVL(l_commit_size,1000); /* -- Bug#6609009 -- */

	  FETCH c_ast_ln_det_ar bulk collect into
			  l_sob            		   ,
			  l_asset_line_uniq_id 	   ,
			  l_asset_line_id		   ,
			  l_cip_cost			   ,
			  l_cur_code		       ,
			  l_exc_rate			   ,
			  l_conv_date
	  LIMIT NVL(l_commit_size,p_commit_size); -- added the NVL for bug 6494397

	  If l_sob.count <> 0 Then

			  l_err_stage := 'Before Inserting into PA_MC_PRJ_AST_LN_DET_AR table';

			  IF p_archive_flag = 'Y'  THEN

				FORALL i in 1..l_sob.count
					INSERT INTO PA_MC_PRJ_AST_LN_DET_AR
					( Set_Of_Books_Id,
					  Proj_Asset_Line_Dtl_Uniq_Id,
					  Project_Asset_Line_Detail_Id,
					  Cip_Cost,
					  Currency_Code,
					  Exchange_Rate,
					  Conversion_Date,
					  Purge_Release,
					  Purge_Batch_Id ,
					  Purge_Project_Id)
					  VALUES(
					  l_sob(i)            		   ,
					  l_asset_line_uniq_id(i) 	   ,
					  l_asset_line_id(i)		   ,
					  l_cip_cost(i)			   ,
					  l_cur_code(i)		       ,
					  l_exc_rate(i)			   ,
					  l_conv_date(i)			   ,
					  P_Purge_Release,
					  P_Purge_Batch_Id,
					  p_project_id
					  );

				NoOfRecordsIns := l_sob.count ;

			  End If;

			  FORALL i in 1..l_sob.count
					Delete From PA_MC_Prj_Ast_line_Dtls
					 Where SET_OF_BOOKS_ID = l_sob(i)
					   And PROJ_ASSET_LINE_DTL_UNIQ_ID = l_asset_line_uniq_id(i);

			  NoOfRecordsDel := l_sob.count ;



			  -- After "deleting" or "deleting and inserting" a set of records
			  -- the transaction is commited. This also creates a record in the
			  -- Pa_Purge_Project_details which will show the no. of records
			  -- that are purged from each table.

			  l_err_stage := 'Before Calling PA_Purge.CommitProcess';

			  PA_Purge.CommitProcess(p_purge_batch_id,
									 p_project_id,
									 'PA_MC_Prj_Ast_line_Dtls',
									 NoOfRecordsIns,
									 NoOfRecordsDel,
									 p_err_code,
									 p_err_stack,
									 p_err_stage);


	   End If;

	   IF c_ast_ln_det_ar%NOTFOUND and l_sob.count = 0 THEN
		  EXIT;
	   END IF;

	   l_sob.delete;
	   l_asset_line_uniq_id.delete;
	   l_asset_line_id.delete;
	   l_cip_cost.delete;
	   l_cur_code.delete;
	   l_exc_rate.delete;
	   l_conv_date.delete;



    END LOOP ;

	Close c_ast_ln_det_ar;

    p_err_stack    := l_old_err_stack ;

EXCEPTION
  WHEN OTHERS THEN
    p_err_code := -1;
    p_err_stage := to_char(SQLCODE);
    FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name        => 'PA_PURGE_CAPITAL',
            p_procedure_name  => 'PA_MC_AsstLinDtls'||'-'||l_err_stage,
            p_error_text      => 'ORA-'||LPAD(substr(p_err_stage,2),5,'0'));

    RAISE ;

END PA_MC_AsstLinDtls;



/************************************/

/* Commenting Out below Procedure By Re-Architecturing as above
Bug 3613739

PROCEDURE PA_MC_AsstLinDtls (p_purge_batch_id	IN NUMBER,
	                     p_project_id       IN NUMBER,
			     p_txn_to_date	IN DATE,
			     p_purge_release	IN VARCHAR2,
			     p_archive_flag	IN VARCHAR2,
			     p_commit_size	IN NUMBER,
			     p_err_code		IN OUT NUMBER,
			     p_err_stack        IN OUT VARCHAR2,
			     p_err_stage	IN OUT VARCHAR2)    IS

  l_old_err_stack       VARCHAR2(2000);
  NoOfRecordsIns        NUMBER;
  NoOfRecordsDel        NUMBER;

  BEGIN

    p_err_code := 0;

    l_old_err_stack := p_err_stack;

    p_err_stack := p_err_stack || ' ->Before insert into PA_MC_PRJ_AST_LINE_DETS_AR' ;

    LOOP

      IF p_archive_flag = 'Y' THEN
        -- If archive option is selected then the records are inserted into the archive tables
        -- before being purged. The where condition is such that only the it inserts half the
        -- no. of records specified in the commit size.

        l_commit_size := p_commit_size / 2 ;

        l_err_stage := 'Before Inserting into PA_MC_PRJ_AST_LN_DET_AR table';

        INSERT INTO PA_MC_PRJ_AST_LN_DET_AR
        ( Set_Of_Books_Id,
          Proj_Asset_Line_Dtl_Uniq_Id,
          Project_Asset_Line_Detail_Id,
          Cip_Cost,
          Currency_Code,
          Exchange_Rate,
          Conversion_Date,
          Purge_Release,
          Purge_Batch_Id ,
          Purge_Project_Id)
        SELECT
              pmald.Set_Of_Books_Id,
              pmald.Proj_Asset_Line_Dtl_Uniq_Id,
              pmald.Project_Asset_Line_Detail_Id,
              pmald.Cip_Cost,
              pmald.Currency_Code,
              pmald.Exchange_Rate,
              pmald.Conversion_Date,
              p_purge_release,
              p_purge_batch_id,
              p_project_id
        FROM
              PA_MC_Prj_Ast_Line_Dtls pmald,
              PA_Project_Asset_Line_Details pald,
              PA_Expenditure_Items_All pei
        WHERE
             pald.proj_asset_line_dtl_uniq_id = pmald.proj_asset_line_dtl_uniq_id
        AND  pald.Expenditure_Item_id = pei.Expenditure_Item_id
        AND  pei.project_id = p_project_id
        AND  rownum < l_commit_size ;
        ---- Commented for the bug#2385541
        ---- NoOfRecordsIns := nvl(NoOfRecordsIns, 0) + SQL%ROWCOUNT ;
        NoOfRecordsIns := SQL%ROWCOUNT ; --- Added for the bug#2385541

        IF SQL%ROWCOUNT > 0 THEN
          -- We have a seperate delete statement if the archive option is
          -- selected because if archive option is selected the the records
          -- being purged will be those records which are already archived.

          l_err_stage := 'Before Deleting from PA_MC_Prj_Ast_line_Dtls table after Archive';

          DELETE FROM PA_MC_Prj_Ast_line_Dtls pmald
          WHERE (pmald.Proj_Asset_Line_Dtl_Uniq_Id) in
                                          ( SELECT pmaldar.Proj_Asset_Line_Dtl_Uniq_Id
                                            FROM   PA_MC_PRJ_AST_LN_DET_AR pmaldar,
                                                   PA_Project_Asset_Line_Details pald,
                                                   PA_Expenditure_Items_All pei
                                            WHERE
                                                   pald.Proj_Asset_Line_Dtl_Uniq_Id =
                                                   pmaldar.Proj_Asset_Line_Dtl_Uniq_Id
                                            AND    pald.Expenditure_Item_id = pei.Expenditure_Item_id
                                            AND    pei.project_id = p_project_id);

          NoOfRecordsDel := SQL%ROWCOUNT ;  ----- Added for the bug#2385541

        End IF ;

      ELSE

        l_commit_size := p_commit_size ;

        -- If the archive option is not selected then the delete will
        -- be based on the commit size.

        l_err_stage := 'Before Deleting from PA_MC_Prj_Ast_line_Dtls table ';

        DELETE FROM PA_MC_Prj_Ast_line_Dtls pmald
        WHERE Exists  ---- Bug 3613739 proj_asset_line_dtl_uniq_id IN
              (SELECT proj_asset_line_dtl_uniq_id
               FROM   PA_Project_Asset_Line_Details pald,
                      PA_Expenditure_Items_All pei
               WHERE  pald.Expenditure_Item_id = pei.Expenditure_Item_id
			   AND pmald.proj_asset_line_dtl_uniq_id =  pald.proj_asset_line_dtl_uniq_id -- Bug 3613739
               AND    pei.project_id = p_project_id)
        AND  rownum < l_commit_size ;
        --- Commented for the bug#2385541
        --- NoOfRecordsDel := nvl(NoOfRecordsDel, 0) + SQL%ROWCOUNT ;
        NoOfRecordsDel := SQL%ROWCOUNT ;   --- Added for the bug#2385541

      End IF ;

      IF SQL%ROWCOUNT = 0 then
        -- Once the SqlCount becomes 0, which means that there are
        -- no more records to be purged then we exit the loop.

        EXIT ;

      ELSE
        -- After "deleting" or "deleting and inserting" a set of records
        -- the transaction is commited. This also creates a record in the
        -- Pa_Purge_Project_details which will show the no. of records
        -- that are purged from each table.

        l_err_stage := 'Before Calling PA_Purge.CommitProcess';

        PA_Purge.CommitProcess(	p_purge_batch_id,
                                p_project_id,
                                'PA_MC_Prj_Ast_line_Dtls',
                                NoOfRecordsIns,
                                NoOfRecordsDel,
                                p_err_code,
                                p_err_stack,
                                p_err_stage) ;

      End IF ;

    END LOOP ;

    p_err_stack    := l_old_err_stack ;

EXCEPTION
  WHEN OTHERS THEN
    p_err_code := -1;
    p_err_stage := to_char(SQLCODE);
    FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name        => 'PA_PURGE_CAPITAL',
            p_procedure_name  => 'PA_MC_AsstLinDtls'||'-'||l_err_stage,
            p_error_text      => 'ORA-'||LPAD(substr(p_err_stage,2),5,'0'));

    RAISE ;

END PA_MC_AsstLinDtls ;

Bug 3613739
*/



PROCEDURE PA_AsstLineDtls (p_purge_batch_id	IN NUMBER,
	                   p_project_id		IN NUMBER,
			   p_txn_to_date	IN DATE,
			   p_purge_release	IN VARCHAR2,
			   p_archive_flag	IN VARCHAR2,
			   p_commit_size	IN NUMBER,
			   p_err_code		IN OUT NOCOPY NUMBER,
			   p_err_stack		IN OUT NOCOPY VARCHAR2,
			   p_err_stage		IN OUT NOCOPY VARCHAR2)    IS

  l_old_err_stack       VARCHAR2(2000);
  NoOfRecordsIns        NUMBER;
  NoOfRecordsDel        NUMBER;

  BEGIN

    p_err_code := 0;

    l_old_err_stack := p_err_stack;

    p_err_stack := p_err_stack || ' ->Before insert into PA_PRJ_ASSET_LN_DETS_AR' ;

    LOOP

      IF p_archive_flag = 'Y' THEN
        -- If archive option is selected then the records are inserted into the archive tables
        -- before being purged. The where condition is such that only the it inserts half the
        -- no. of records specified in the commit size.

        l_commit_size := p_commit_size / 2 ;

        l_err_stage := 'Before Inserting into PA_PRJ_ASSET_LN_DETS_AR table';

        INSERT INTO PA_PRJ_ASSET_LN_DETS_AR
        ( Expenditure_Item_Id,
          Line_Num,
          Project_Asset_Line_Detail_Id,
          Cip_Cost,
          Reversed_Flag,
          Last_Update_Date,
          Last_Updated_By,
          Created_By,
          Creation_Date,
          Last_Update_Login,
          Request_Id,
          Program_Application_Id,
          Program_Id,
          Program_Update_Date,
          Purge_Release,
          Purge_Batch_Id,
          Purge_Project_id,
	  PROJ_ASSET_LINE_DTL_UNIQ_ID) /* Bug#2385541  */
        SELECT
              pald.Expenditure_Item_Id,
              pald.Line_Num,
              pald.Project_Asset_Line_Detail_Id,
              pald.Cip_Cost,
              pald.Reversed_Flag,
              pald.Last_Update_Date,
              pald.Last_Updated_By,
              pald.Created_By,
              pald.Creation_Date,
              pald.Last_Update_Login,
              pald.Request_Id,
              pald.Program_Application_Id,
              pald.Program_Id,
              pald.Program_Update_Date,
              p_purge_release,
              p_purge_batch_id,
              p_project_id,
	      pald.PROJ_ASSET_LINE_DTL_UNIQ_ID  /* Bug#2385541 */
        FROM
              PA_Project_Asset_Line_Details pald,
              PA_Expenditure_Items_All pei
        WHERE
             pald.Expenditure_Item_id = pei.Expenditure_Item_id
        AND  pei.project_id = p_project_id
        AND  rownum < l_commit_size ;
    /* Commented for the bug#2385541
        NoOfRecordsIns := nvl(NoOfRecordsIns, 0) + SQL%ROWCOUNT ;   */
        NoOfRecordsIns := SQL%ROWCOUNT ;  /* Added for the bug#2385541 */

        IF SQL%ROWCOUNT > 0 THEN
          -- We have a seperate delete statement if the archive option is
          -- selected because if archive option is selected the the records
          -- being purged will be those records which are already archived.

          l_err_stage := 'Before Deleting from PA_Project_Asset_line_Details table after Archive';
/* Bug#2405839: Purge process is not deleting the asset line details since, checking for
   pald.Project_Asset_Line_Detail_Id in pald1.Proj_Asset_Line_Dtl_Uniq_Id.
   Commented the delete statement and added the modified delete statement below.

          DELETE FROM PA_Project_Asset_line_Details pald
          WHERE (pald.Project_Asset_Line_Detail_Id) IN
                  ( SELECT pald1.Proj_Asset_Line_Dtl_Uniq_Id
                    FROM PA_Project_Asset_line_Details pald1,
                         PA_PRJ_ASSET_LN_DETS_AR paldar,
                         PA_Expenditure_Items_All pei
                    WHERE
                         pald1.Project_Asset_Line_Detail_Id = paldar.Project_Asset_Line_Detail_Id
                    AND  paldar.Expenditure_Item_Id = pei.Expenditure_Item_Id
                    and  pei.project_id = p_project_id ) ;
*/
        DELETE FROM PA_Project_Asset_line_Details pald
        WHERE (pald.PROJ_ASSET_LINE_DTL_UNIQ_ID) IN
                ( SELECT paldar.PROJ_ASSET_LINE_DTL_UNIQ_ID
                  FROM PA_Project_Asset_line_Details pald1,
                       PA_PRJ_ASSET_LN_DETS_AR paldar
                 WHERE
                       pald1.PROJ_ASSET_LINE_DTL_UNIQ_ID = paldar.PROJ_ASSET_LINE_DTL_UNIQ_ID
                  AND  paldar.Purge_project_id = p_project_id
                  AND  pald1.Project_Asset_Line_Detail_Id = paldar.Project_Asset_Line_Detail_Id) ;


           NoOfRecordsDel := SQL%ROWCOUNT ;  /* Added for the bug#2385541 */

        End IF ;

      ELSE

        l_commit_size := p_commit_size ;

        -- If the archive option is not selected then the delete will
        -- be based on the commit size.

        l_err_stage := 'Before Deleting from PA_Project_Asset_line_Details table ';

        DELETE FROM PA_Project_Asset_line_Details pald
        WHERE Expenditure_Item_Id in (SELECT pei.Expenditure_Item_Id
                                      FROM   PA_Expenditure_Items_All pei
                                      WHERE  pei.project_id = p_project_id)
        AND  rownum < l_commit_size ;
        /* Commented for the Bug#2385541
        NoOfRecordsDel := nvl(NoOfRecordsDel, 0) + SQL%ROWCOUNT ;   */
        NoOfRecordsDel := SQL%ROWCOUNT ;  /* Added for the bug#2385541 */

      End IF ;

      IF SQL%ROWCOUNT = 0 then
        -- Once the SqlCount becomes 0, which means that there are
        -- no more records to be purged then we exit the loop.

        EXIT ;

      ELSE
        -- After "deleting" or "deleting and inserting" a set of records
        -- the transaction is commited. This also creates a record in the
        -- Pa_Purge_Project_details which will show the no. of records
        -- that are purged from each table.

        l_err_stage := 'Before Calling PA_Purge.CommitProcess';

        PA_Purge.CommitProcess(	p_purge_batch_id,
                                p_project_id,
                                'PA_Project_Asset_line_Details',
                                NoOfRecordsIns,
                                NoOfRecordsDel,
                                p_err_code,
                                p_err_stack,
                                p_err_stage) ;

      End IF ;

    END LOOP ;

    p_err_stack    := l_old_err_stack ;

EXCEPTION
  WHEN OTHERS THEN
    p_err_code := -1;
    p_err_stage := to_char(SQLCODE);
    FND_MSG_PUB.Add_Exc_Msg(
            p_pkg_name        => 'PA_PURGE_CAPITAL',
            p_procedure_name  => 'PA_AsstLineDtls'||'-'||l_err_stage,
            p_error_text      => 'ORA-'||LPAD(substr(p_err_stage,2),5,'0'));

    RAISE ;

END PA_AsstLineDtls ;

END PA_Purge_Capital;

/
