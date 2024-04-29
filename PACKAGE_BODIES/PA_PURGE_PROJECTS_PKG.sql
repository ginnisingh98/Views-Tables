--------------------------------------------------------
--  DDL for Package Body PA_PURGE_PROJECTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_PROJECTS_PKG" as
/* $Header: PAXARPPB.pls 120.1 2005/08/05 00:47:38 rgandhi noship $ */
 procedure insert_row (x_rowid				 in out NOCOPY VARCHAR2,/*File.sql.39*/
                       x_purge_batch_id                  in out NOCOPY NUMBER,/*File.sql.39*/
                       x_project_id       		 in NUMBER,
                       x_last_project_status_code        in VARCHAR2,
                       x_purge_summary_flag              in VARCHAR2,
                       x_archive_summary_flag            in VARCHAR2,
                       x_purge_budgets_flag              in VARCHAR2,
                       x_archive_budgets_flag            in VARCHAR2,
                       x_purge_capital_flag              in VARCHAR2,
                       x_archive_capital_flag            in VARCHAR2,
                       x_purge_actuals_flag              in VARCHAR2,
                       x_archive_actuals_flag            in VARCHAR2,
                       x_txn_to_date                     in DATE,
                       x_purge_project_status_code       in VARCHAR2,
                       x_next_pp_project_status_code     in VARCHAR2,
                       x_next_p_project_status_code      in VARCHAR2,
                       x_purged_date              	 in DATE,
                       x_user_id                         in NUMBER ) is

  cursor c is select rowid from pa_purge_projects
              where purge_batch_id = x_purge_batch_id
                and project_id     = x_project_id;

  x_err_code		NUMBER;
  x_return_status	VARCHAR2(630);

 BEGIN

  insert into pa_purge_projects(purge_batch_id,
                                project_id,
                                last_project_status_code,
                                purge_summary_flag,
                                archive_summary_flag,
                                purge_budgets_flag,
                                archive_budgets_flag,
                                purge_capital_flag,
                                archive_capital_flag,
                                purge_actuals_flag,
                                archive_actuals_flag,
                                purge_project_status_code,
                                next_pp_project_status_code,
                                next_p_project_status_code,
                                txn_to_date ,
                                creation_date,
                                created_by,
                                last_update_date,
                                last_updated_by )
                        values (x_purge_batch_id,
                                x_project_id,
                                x_last_project_status_code,
                                x_purge_summary_flag,
                                x_archive_summary_flag,
                                x_purge_budgets_flag,
                                x_archive_budgets_flag,
                                x_purge_capital_flag,
                                x_archive_capital_flag,
                                x_purge_actuals_flag,
                                x_archive_actuals_flag,
                                x_purge_project_status_code,
                                x_next_pp_project_status_code,
                                x_next_p_project_status_code,
                                x_txn_to_date ,
                                sysdate,
                                x_user_id,
                                sysdate,
                                x_user_id) ;

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
    raise NO_DATA_FOUND;
  end if;
  close c;

 exception
   when others then
     raise ;
 END insert_row;

 procedure update_row (x_rowid				 in VARCHAR2,
                       x_purge_batch_id                  in NUMBER,
                       x_project_id       		 in NUMBER,
                       x_last_project_status_code        in VARCHAR2,
                       x_purge_summary_flag              in VARCHAR2,
                       x_archive_summary_flag            in VARCHAR2,
                       x_purge_budgets_flag              in VARCHAR2,
                       x_archive_budgets_flag            in VARCHAR2,
                       x_purge_capital_flag              in VARCHAR2,
                       x_archive_capital_flag            in VARCHAR2,
                       x_purge_actuals_flag              in VARCHAR2,
                       x_archive_actuals_flag            in VARCHAR2,
                       x_txn_to_date                     in DATE,
                       x_purge_project_status_code       in VARCHAR2,
                       x_next_pp_project_status_code     in VARCHAR2,
                       x_next_p_project_status_code      in VARCHAR2,
                       x_purged_date              	 in DATE,
                       x_user_id                         in NUMBER ) is


 BEGIN

  update pa_purge_projects
  set purge_batch_id                    = x_purge_batch_id,
      project_id                        = x_project_id,
      last_project_status_code          = x_last_project_status_code,
      purge_summary_flag                = x_purge_summary_flag       ,
      archive_summary_flag              = x_archive_summary_flag,
      purge_budgets_flag                = x_purge_budgets_flag       ,
      archive_budgets_flag              = x_archive_budgets_flag,
      purge_capital_flag                = x_purge_capital_flag       ,
      archive_capital_flag              = x_archive_capital_flag,
      purge_actuals_flag                = x_purge_actuals_flag       ,
      archive_actuals_flag              = x_archive_actuals_flag,
      purge_project_status_code         = x_purge_project_status_code,
      next_pp_project_status_code       = x_next_pp_project_status_code,
      next_p_project_status_code        = x_next_p_project_status_code,
      txn_to_date                       = x_txn_to_date ,
      last_update_date			= sysdate,
      last_updated_by			= x_user_id,
      last_update_login			= x_user_id
  where rowid = x_rowid;

 exception
    when others then
      raise ;
 END update_row;

 -- The delete_row table handler cascades the delete to the
 -- expenditures table by calling the expenditures delete_row
 -- table handler.

 procedure delete_row (x_rowid	in  VARCHAR2) is

   cursor purge_projects is
                     select purge_batch_id, project_id, last_project_status_code
                       from pa_purge_projects
                      where rowid = x_rowid
                      for update of project_id, purge_batch_id nowait;

   projects_rec  purge_projects%rowtype;
   cursor project is
               select project_id
                 from pa_projects
                where project_id = projects_rec.project_id
                  for update of project_status_code nowait ;

 BEGIN
   open purge_projects;
   fetch purge_projects into projects_rec;
   open project ;
   if (purge_projects%notfound) then
       null;
   else
       update pa_projects
          set project_status_code = projects_rec.last_project_status_code
        where project_id = projects_rec.project_id ;

       delete from pa_purge_project_errors
        where project_id = projects_rec.project_id
          and purge_batch_id = projects_rec.purge_batch_id ;

       delete from pa_purge_projects
       where rowid = x_rowid;
   end if;
   close project ;

   close purge_projects ;

 EXCEPTION
   when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
     fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
     app_exception.raise_exception;

 END delete_row;


 -- Locks the given row in the database.  Does not check if
 -- values have changed (currently not in use).

 procedure lock_row    (x_rowid				  in VARCHAR2,
                        x_purge_batch_id                  in NUMBER,
                        x_project_id       		  in NUMBER,
                        x_last_project_status_code        in VARCHAR2,
                        x_purge_summary_flag              in VARCHAR2,
                        x_archive_summary_flag            in VARCHAR2,
                        x_purge_budgets_flag              in VARCHAR2,
                        x_archive_budgets_flag            in VARCHAR2,
                        x_purge_capital_flag              in VARCHAR2,
                        x_archive_capital_flag            in VARCHAR2,
                        x_purge_actuals_flag              in VARCHAR2,
                        x_archive_actuals_flag            in VARCHAR2,
                        x_txn_to_date                     in DATE,
                        x_purge_project_status_code       in VARCHAR2,
                        x_next_pp_project_status_code     in VARCHAR2,
                        x_next_p_project_status_code      in VARCHAR2,
                        x_purged_date              	  in DATE) is

  dummy		NUMBER;

  CURSOR C is
     select * from pa_purge_projects
      where rowid = x_rowid
      for update of project_id ;

   recinfo    C%ROWTYPE ;

 BEGIN
  open C;
  fetch C into recinfo ;

  if C%NOTFOUND then
     close C ;
     FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
     APP_EXCEPTION.RAISE_EXCEPTION ;
  end if ;
  close C ;

  if (   recinfo.purge_batch_id              = x_purge_batch_id                and
         recinfo.project_id                  = x_project_id                    and
         recinfo.last_project_status_code    = x_last_project_status_code      and
         recinfo.purge_summary_flag          = x_purge_summary_flag            and
         recinfo.archive_summary_flag        = x_archive_summary_flag          and
         recinfo.purge_budgets_flag          = x_purge_budgets_flag            and
         recinfo.archive_budgets_flag        = x_archive_budgets_flag          and
         recinfo.purge_capital_flag          = x_purge_capital_flag            and
         recinfo.archive_capital_flag        = x_archive_capital_flag          and
         recinfo.purge_actuals_flag          = x_purge_actuals_flag            and
         recinfo.archive_actuals_flag        = x_archive_actuals_flag          and
         recinfo.purge_project_status_code   = x_purge_project_status_code     and
      ( (recinfo.txn_to_date                 = x_txn_to_date  )                or
        (recinfo.txn_to_date  is null                                          and
         x_txn_to_date  is null) )                                             and
      ( (recinfo.next_pp_project_status_code = x_next_pp_project_status_code ) or
        (recinfo.next_pp_project_status_code is null                           and
         x_next_pp_project_status_code is null) )                              and
      ( (recinfo.next_p_project_status_code = x_next_p_project_status_code )   or
        (recinfo.next_p_project_status_code is null                            and
         x_next_pp_project_status_code is null) )                              and
      ( (recinfo.purged_date = x_purged_date )                                 or
        (recinfo.purged_date is null                                           and
         x_purged_date is null) )

    )   then
       return ;

  else

     fnd_message.set_name('FND','FORM_RECORD_CHANGED');
     app_exception.raise_exception ;


  end if ;

 END lock_row;

---------------------------------------------------------------------------


END pa_purge_projects_pkg;

/
