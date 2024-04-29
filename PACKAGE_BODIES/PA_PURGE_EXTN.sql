--------------------------------------------------------
--  DDL for Package Body PA_PURGE_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_EXTN" as
/* $Header: PAXAPPXB.pls 120.1 2005/08/19 17:08:20 mwasowic noship $ */
-- forward declarations

    l_commit_size     NUMBER ;

-- Start of comments
-- API name         : pa_purge_client_extn
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure is the client extension that is called
--                    from the main purge procedure. Custom code can be added
--                    to this procedure to purge custom tables.
--
-- Parameters       : p_purge_batch_id			IN     NUMBER
--                              The purge batch id for which rows have
--                              to be purged/archived.
--		      p_project_Id			IN     NUMBER,
--                              The project id for which records have
--                              to be purged/archived.
--		      p_Purge_Release			IN OUT VARCHAR2,
--                              The version of the application on which the
--                              purge process is run.
--		      p_Txn_Through_Date		IN     DATE,
--                              If the purging is being done on projects
--                              that are active then this parameter
--                              determines the date through which the
--                              transactions need to be purged.
--		      p_Archive_Flag			IN OUT VARCHAR2,
--                              This flag determines if the records need to
--                              be archived before they are purged. When the
--                              main procedure calls the client extension,
--                              this flag is passed a value of 'Y' if actuals
--                              are being archived, 'N' if actuals are not
--                              being archived
--		      p_Calling_Place			IN OUT VARCHAR2,
--                              This parameter will have a value of BEFORE_PURGE
--                              when the client extension is called at the start
--                              of the purge process and AFTER_PURGE when the
--                              client extension is called at the end of the
--                              purge process
--		      p_Commit_Size			IN     NUMBER,
--                              The number of records that can be allowed to
--                              remain uncommitted. If the number of records
--                              goes beyond this number then the process is
--                              commited.
--		      X_Err_Stack			IN OUT VARCHAR2,
--                              Error stack
--		      X_Err_Stage		        IN OUT VARCHAR2,
--                              Stage in the procedure where error occurred
--		      X_Err_Code		        IN OUT NUMBER
--                              Error code returned from the procedure
--
-- Note : The parameter p_txn_through_date includes transactions through
--        a given date. However, the archive/purge code and tables refer
--        to this parameter as txn_to_date
--
--
-- End of comments

procedure pa_purge_client_extn  ( p_purge_batch_id                 in NUMBER,
                                   p_project_id                     in NUMBER,
                                   p_purge_release                  in VARCHAR2,
                                   p_txn_through_date               in DATE,
                                   p_archive_flag                   in VARCHAR2,
                                   p_calling_place                  in VARCHAR2,
                                   p_commit_size                    in NUMBER,
                                   x_err_stack                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_stage                      in OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_err_code                       in OUT NOCOPY NUMBER ) is --File.Sql.39 bug 4440895

      l_old_err_stack        VARCHAR2(2000);
      l_err_stage            VARCHAR2(500);
      l_err_stack            VARCHAR2(500);
      l_no_records_del       NUMBER ;
      l_no_records_ins       NUMBER ;

 BEGIN

 --        l_old_err_stack := x_err_stack;
 --
 --        x_err_stack := x_err_stack || ' ->Before call to purge the data ';
 --        -- Call the procedure to delete custom table data
 --
      if p_calling_place = 'BEFORE_PURGE' then

 --     Call the procedure to purge the respective tables one after the
 --     other. This section of the code is called before any of the main
 --     tables are purged in the current run.
 --
 --    Note : The p_archive_purge flag determines if the records need to
 --           be archived before they are purged. This flag is passed a default
 --           value of 'Y' by the calling procedure if actuals are being
 --           archived, 'N' if actuals are not being archived
 --           The value can be changed before calling the <CUST_PROCEDURE>
 --
 --
 --        pa_debug.debug('*-> About to purge Extn data ') ;
 --        pa_purge_extn.<CUST_PROCEDURE>(p_purge_batch_id   => p_purge_batch_id,
 --                                       p_project_id       => p_project_id,
 --                                       p_txn_through_date => p_txn_through_date,
 --                                       p_purge_release    => p_purge_release,
 --                                       p_archive_flag     => p_archive_flag,
 --                                       p_commit_size      => p_commit_size,
 --                                       x_err_code         => x_err_code,
 --                                       x_err_stack        => x_err_stack,
 --                                       x_err_stage        => x_err_stage
 --                                      ) ;
 --
           NULL ;
      else
 --     Call the procedure to purge the respective tables one after the
 --     other. This section of the code is called after all the main
 --     tables are purged in the current run.
 --
 --        pa_debug.debug('*-> About to purge extn data ') ;
 --        pa_purge_extn.<CUST_PROCEDURE>(p_purge_batch_id   => p_purge_batch_id,
 --                                       p_project_id       => p_project_id,
 --                                       p_txn_through_date => p_txn_through_date,
 --                                       p_purge_release    => p_purge_release,
 --                                       p_archive_flag     => p_archive_flag,
 --                                       p_commit_size      => p_commit_size,
 --                                       x_err_code         => x_err_code,
 --                                       x_err_stack        => x_err_stack,
 --                                       x_err_stage        => x_err_stage
 --                                      ) ;
 --
           NULL ;

      end if;

         NULL ;

 EXCEPTION
  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;

  WHEN OTHERS THEN
    x_err_stage := l_err_stage ;
    pa_debug.debug('Error Procedure Name  := PA_PURGE_EXTN.PA_PURGE_CLIENT_EXTN' );
    pa_debug.debug('Error stage is '||l_err_stage );
    pa_debug.debug('Error stack is '||l_err_stack );
    pa_debug.debug(SQLERRM);
    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;

    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;


 END pa_purge_client_extn ;

-- Start of comments
-- API name         : <CUST_PROCEDURE>
-- Type             : Public
-- Pre-reqs         : None
-- Function         : This procedure purges all the records from <CUST_TABLE>
--
-- Parameters       : Refer to the comments of the previous procedure
--
-- End of comments

-- procedure <CUST_PROCEDURE> ( p_purge_batch_id         IN NUMBER,
--                              p_project_id             IN NUMBER,
--                              p_txn_through_date       IN DATE,
--                              p_purge_release          IN VARCHAR2,
--                              p_archive_flag           IN VARCHAR2,
--                              p_commit_size            IN NUMBER,
--                              x_err_code           IN OUT NUMBER,
--                              x_err_stack          IN OUT VARCHAR2,
--                              x_err_stage          IN OUT VARCHAR2
--                            )    is
--
--     l_old_err_stage         VARCHAR2(2000);
--     l_old_err_stack         VARCHAR2(2000);
--     l_NoOfRecordsIns        NUMBER;
--     l_NoOfRecordsDel        NUMBER;
--     l_NoOfRecsPrced         NUMBER;
-- begin
--
--     l_old_err_stack := x_err_stack;
--
--     x_err_stack := x_err_stack || ' ->Before insert into <CUST_TABLE_AR>' ;
--     LOOP
--             if p_archive_flag = 'Y' then
--                     -- If archive option is selected then the records are
--                     -- inserted into the archived into the archive tables
--                     -- before being purged. The where condition is such that
--                     -- it inserts half the no. of records specified
--                     -- in the commit size.
--
--                     l_commit_size := p_commit_size / 2 ;
--                     insert into <CUSTOM_TABLE>_AR
--                        (
--                          expenditure_item_id,
--                          line_number,
--                          last_update_date,
--                          last_updated_by,
--                          creation_date,
--                          created_by,
--                          last_update_login,
--                          request_id,
--                          program_id,
--                          program_application_id,
--                          program_update_date ,
--                          purge_batch_id,
--                          purge_release,
--                          purge_project_id
--                        )
--                       select eX.expenditure_item_id,
--                              eX.line_number
--                              eX.last_update_date,
--                              eX.last_updated_by,
--                              eX.creation_date,
--                              eX.created_by,
--                              eX.last_update_login,
--                              eX.request_id,
--                              eX.program_id,
--                              eX.program_application_id,
--                              eX.program_update_date,
--                              p_purge_batch_id,
--                              p_purge_release,
--                              p_project_id
--                         from <CUSTOM_TABLE> eX
--                        where ( eX.rowid )
--                                  in ( select eX1.rowid
--                                         from pa_tasks t,
--                                              pa_expenditure_items_all ei,
--                                              <CUSTOM_TABLE> eX1
--                                        where ei.expenditure_item_id = eX1.expenditure_item_id
--                                        and (p_txn_through_date  is null
--                                        or  trunc(ei.expenditure_item_date) <= trunc(p_txn_through_date ))
 --                                       and ei.task_id = t.task_id
 --                                       and t.project_id = p_project_id
 --                                       and rownum <= p_commit_size
 --                                     ) ;
 --
 --                     -- Make sure that the custom tables are indexed on
 --                     -- expenditure_item_id
 --
 --                     l_NoOfRecordsIns :=  SQL%ROWCOUNT ;
 --                     l_NoOfRecsPrced  :=  SQL%ROWCOUNT ;
 --
 --
 --                     if l_NoOfRecsPrced  > 0 then
 --                          -- We have a separate delete statement if the archive option is
 --                          -- selected because if archive option is selected the the records
 --                          -- being purged will be those records which are already archived.
 --
 --
 --                          delete from <CUST_TABLE> eX
 --                           where ( eX.rowid )
 --                                       in ( select eX1.rowid
 --                                              from <CUST_TABLE> eX1,
 --                                                   <CUST_TABLE>_ar eX2
 --                                             where eX2.expenditure_item_id = eX1.expenditure_item_id
 --                                               and eX2.line_number = eX1.line_number
 --                                               and eX2.purge_project_id = p_project_id
 --                                          ) ;
 --                          -- The archive tables should be indexed on the combination
 --                          -- of the original primary key and purge_project_id. This
 --                          -- index will improve the performance while purging the
 --                          -- archived records.
 --
 --                          l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
 --                          l_NoOfRecsPrced  :=  SQL%ROWCOUNT ;
 --
 --                     end if;
 --             else
 --
 --                     l_commit_size := p_commit_size ;
 --
 --                     -- If the archive option is not selected then the delete will
 --                     -- be based on the commit size.
 --
 --                     delete from <CUST_TABLE> eX
 --                      where ( eX.rowid )
 --                                  in ( select eX1.rowid
 --                                         from pa_tasks t,
 --                                              pa_expenditure_items_all ei,
 --                                              <CUST_TABLE> eX1
 --                                        where ei.expenditure_item_id = eX1.expenditure_item_id
 --                                          and (p_txn_through_date  is null
 --                                          or  trunc(ei.expenditure_item_date) <= trunc(p_txn_through_date ))
 --                                          and ei.task_id = t.task_id
 --                                          and t.project_id = p_project_id
 --                                          and rownum <= p_commit_size
 --                                      ) ;
 --
 --                     l_NoOfRecordsDel :=  SQL%ROWCOUNT ;
 --                     l_NoOfRecsPrced  :=  SQL%ROWCOUNT ;
 --
 --             end if ;
 --
 --             if l_NoOfRecsPrced = 0 then
 --
 --                  -- Once the SqlCount becomes 0, which means that there are
 --                  -- no more records to be purged then we exit the loop.
 --
 --                  exit ;
 --
 --             else
 --                  -- After "deleting" or "deleting and inserting" a set of records
 --                  -- the transaction is commited. This also creates a record in the
 --                  -- Pa_Purge_Project_details which will show the number of records
 --                  -- that are purged from each table.
 --
 --                  pa_purge.CommitProcess(p_purge_batch_id,
 --                                         p_project_id,
 --                                         '<CUST_TABLE>',
 --                                         l_NoOfRecordsIns,
 --                                         l_NoOfRecordsDel,
 --                                         x_err_code,
 --                                         x_err_stack,
 --                                         x_err_stage
 --                                        ) ;
 --
 --             end if ;
 --     END LOOP ;
 --
 --     x_err_stack    := l_old_err_stack ;
 --
 -- EXCEPTION
 --  WHEN PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error then
 --       RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;
 --
 --  WHEN OTHERS THEN
 --    x_err_stage := l_err_stage ;
 --    pa_debug.debug('Error Procedure Name  := PA_PURGE_EXTN.<CUST_PROCEDURE>' );
 --    pa_debug.debug('Error stage is '||l_err_stage );
 --    pa_debug.debug('Error stack is '||l_err_stack );
 --    pa_debug.debug(SQLERRM);
 --    PA_PROJECT_UTILS2.g_sqlerrm := SQLERRM ;
 --
 --    RAISE PA_PROJECT_UTILS2.PA_Arch_Pur_Subroutine_Error ;
 --
 --
 -- end <CUST_PROCEDURE> ;

END pa_purge_extn;

/
