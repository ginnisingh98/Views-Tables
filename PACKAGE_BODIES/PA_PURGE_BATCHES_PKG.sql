--------------------------------------------------------
--  DDL for Package Body PA_PURGE_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PURGE_BATCHES_PKG" as
/* $Header: PAXARPBB.pls 120.2 2005/08/05 00:42:45 rgandhi noship $ */
 procedure insert_row(x_rowid				in out NOCOPY VARCHAR2,/*File.sql.39*/
                      x_purge_batch_id                  in out NOCOPY NUMBER, /*File.sql.39*/
                      x_batch_name       		in VARCHAR2,
                      x_description			in VARCHAR2,
                      x_batch_status_code       	in VARCHAR2,
                      x_active_closed_flag              in VARCHAR2,
                      x_purge_summary_flag              in VARCHAR2,
                      x_archive_summary_flag            in VARCHAR2,
                      x_purge_budgets_flag              in VARCHAR2,
                      x_archive_budgets_flag            in VARCHAR2,
                      x_purge_capital_flag              in VARCHAR2,
                      x_archive_capital_flag            in VARCHAR2,
                      x_purge_actuals_flag              in VARCHAR2,
                      x_archive_actuals_flag            in VARCHAR2,
		      x_admin_proj_flag                 in VARCHAR2,
                      x_txn_to_date                     in DATE,
                      x_next_pp_project_status_code     in VARCHAR2,
                      x_next_p_project_status_code      in VARCHAR2,
                      x_purged_date              	in DATE,
                      x_purge_release                   in VARCHAR2,
                      x_user_id                         in NUMBER,
		      x_org_id                          in NUMBER) is

  cursor c is select rowid from pa_purge_batches
              where purge_batch_id = x_purge_batch_id;
  cursor get_id is select pa_purge_batches_s.nextval from dual ;
  x_err_code		NUMBER;
  x_return_status	VARCHAR2(630);
  l_purge_batch_id      NUMBER := x_purge_batch_id;

 BEGIN

  if x_purge_batch_id is null then
     open get_id;
     fetch get_id into x_purge_batch_id ;
     close get_id ;
  end if;

  insert into pa_purge_batches(purge_batch_id,
                               batch_name,
                               description,
                               batch_status_code,
                               active_closed_flag,
                               archive_summary_flag,
                               purge_summary_flag,
                               archive_budgets_flag,
                               purge_budgets_flag,
                               archive_capital_flag,
                               purge_capital_flag,
                               archive_actuals_flag,
                               purge_actuals_flag,
			       admin_proj_flag,
                               txn_to_date ,
                               next_pp_project_status_code,
                               next_p_project_status_code,
                               purged_date,
                               purge_release,
                               last_update_date,
                               last_updated_by ,
                               last_update_login,
                               creation_date,
                               created_by,
			       org_id)
                      values ( x_purge_batch_id,
                               x_batch_name,
                               x_description,
                               x_batch_status_code,
                               x_active_closed_flag,
                               x_archive_summary_flag,
                               x_purge_summary_flag,
                               x_archive_budgets_flag,
                               x_purge_budgets_flag,
                               x_archive_capital_flag,
                               x_purge_capital_flag,
                               x_archive_actuals_flag,
                               x_purge_actuals_flag,
			       x_admin_proj_flag,
                               x_txn_to_date ,
                               x_next_pp_project_status_code,
                               x_next_p_project_status_code,
                               x_purged_date,
                               x_purge_release,
                               sysdate,
                               x_user_id,
                               x_user_id,
                               sysdate,
                               x_user_id,
			       x_org_id);

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
    raise NO_DATA_FOUND;
  end if;
  close c;

 exception
   when others then
   x_purge_batch_id := l_purge_batch_id;
     raise ;
 END insert_row;

 procedure update_row  (x_rowid				  in VARCHAR2,
                        x_purge_batch_id                  in out NOCOPY NUMBER,/*File.sql.39*/
                        x_batch_name       		  in VARCHAR2,
                        x_description			  in VARCHAR2,
                        x_batch_status_code       	  in VARCHAR2,
                        x_active_closed_flag              in VARCHAR2,
                        x_purge_summary_flag              in VARCHAR2,
                        x_archive_summary_flag            in VARCHAR2,
                        x_purge_budgets_flag              in VARCHAR2,
                        x_archive_budgets_flag            in VARCHAR2,
                        x_purge_capital_flag              in VARCHAR2,
                        x_archive_capital_flag            in VARCHAR2,
                        x_purge_actuals_flag              in VARCHAR2,
                        x_archive_actuals_flag            in VARCHAR2,
		        x_admin_proj_flag                 in VARCHAR2,
                        x_txn_to_date                     in DATE,
                        x_next_pp_project_status_code     in VARCHAR2,
                        x_next_p_project_status_code      in VARCHAR2,
                        x_purged_date              	  in DATE,
                        x_purge_release              	  in VARCHAR2,
                        x_user_id                         in NUMBER) is

 BEGIN

  update pa_purge_batches
  set purge_batch_id                    = x_purge_batch_id,
      batch_name                        = x_batch_name,
      description                       = x_description,
      batch_status_code                 = x_batch_status_code,
      active_closed_flag                = x_active_closed_flag,
      purge_summary_flag                = x_purge_summary_flag,
      archive_summary_flag              = x_archive_summary_flag,
      purge_budgets_flag                = x_purge_budgets_flag,
      archive_budgets_flag              = x_archive_budgets_flag,
      purge_capital_flag                = x_purge_capital_flag,
      archive_capital_flag              = x_archive_capital_flag,
      purge_actuals_flag                = x_purge_actuals_flag,
      archive_actuals_flag              = x_archive_actuals_flag,
      admin_proj_flag                   = x_admin_proj_flag,
      txn_to_date                       = x_txn_to_date  ,
      next_pp_project_status_code       = x_next_pp_project_status_code,
      next_p_project_status_code        = x_next_p_project_status_code,
      purged_date                       = x_purged_date,
      purge_release                     = x_purge_release,
      last_update_date			= sysdate,
      last_updated_by			= x_user_id,
      last_update_login			= x_user_id
  where rowid = x_rowid;

 exception
    when others then
      raise ;
 END update_row;

 -- The delete_row table handler cascades the delete to the
 -- pa_purge_projects table by calling the pa_purge_projects delete_row
 -- table handler.

 procedure delete_row (x_rowid	in  VARCHAR2) is
  cursor get_batch is select batch_status_code,
                             purge_batch_id
                      from pa_purge_batches
                      where rowid = x_rowid;
  batches_rec	get_batch%rowtype;

 BEGIN
  open get_batch;
  fetch get_batch into batches_rec;
  -- check notfound?

  if (batches_rec.batch_status_code <> 'W') then
    fnd_message.set_name ('PA', 'PA_ARPUR_ONLY_DEL_WORK');
    app_exception.raise_exception;
  end if;

  -- cascade delete to purge projects in the batch.
  DECLARE
   cursor purge_projects is
                     select rowid, project_id, last_project_status_code
                       from pa_purge_projects
                      where purge_batch_id = batches_rec.purge_batch_id
                      for update of project_id, purge_batch_id nowait;

   projects_rec  purge_projects%rowtype;

   cursor project is
               select project_id
                 from pa_projects
                where project_id = projects_rec.project_id
                  for update of project_status_code nowait ;

  BEGIN
   open purge_projects;
   LOOP
     fetch purge_projects into projects_rec;
      open project ;
     if (purge_projects%notfound) then
       exit;
     else
       pa_purge_projects_pkg.delete_row ( projects_rec.rowid);
     end if;
     close project ;
   END LOOP;

   close purge_projects ;
  EXCEPTION
   when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
     fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
     app_exception.raise_exception;
  END;

  delete from pa_purge_batches
  where rowid = x_rowid;


 END delete_row;


 -- Locks the given row in the database.  Does not check if
 -- values have changed (currently not in use).

 procedure lock_row    (x_rowid				  in VARCHAR2,
                        x_purge_batch_id                  in out NOCOPY NUMBER,/*file.sql.39*/
                        x_batch_name       		  in VARCHAR2,
                        x_description			  in VARCHAR2,
                        x_batch_status_code       	  in VARCHAR2,
                        x_active_closed_flag              in VARCHAR2,
                        x_purge_summary_flag              in VARCHAR2,
                        x_archive_summary_flag            in VARCHAR2,
                        x_purge_budgets_flag              in VARCHAR2,
                        x_archive_budgets_flag            in VARCHAR2,
                        x_purge_capital_flag              in VARCHAR2,
                        x_archive_capital_flag            in VARCHAR2,
                        x_purge_actuals_flag              in VARCHAR2,
                        x_archive_actuals_flag            in VARCHAR2,
		        x_admin_proj_flag                 in VARCHAR2,
                        x_txn_to_date                     in DATE,
                        x_next_pp_project_status_code     in VARCHAR2,
                        x_next_p_project_status_code      in VARCHAR2,
                        x_purge_release                   in VARCHAR2,
                        x_purged_date              	  in DATE) is

  dummy		NUMBER;

  CURSOR C is
     select * from pa_purge_batches
      where rowid = x_rowid
      for update of purge_batch_id ;

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
         recinfo.batch_name                  = x_batch_name                    and
         recinfo.description                 = x_description                   and
         recinfo.batch_status_code           = x_batch_status_code             and
         recinfo.active_closed_flag          = x_active_closed_flag            and
         recinfo.purge_summary_flag          = x_purge_summary_flag            and
         recinfo.archive_summary_flag        = x_archive_summary_flag          and
         recinfo.purge_budgets_flag          = x_purge_budgets_flag            and
         recinfo.archive_budgets_flag        = x_archive_budgets_flag          and
         recinfo.purge_capital_flag          = x_purge_capital_flag            and
         recinfo.archive_capital_flag        = x_archive_capital_flag          and
         recinfo.purge_actuals_flag          = x_purge_actuals_flag            and
         recinfo.archive_actuals_flag        = x_archive_actuals_flag          and
	 recinfo.admin_proj_flag             = x_admin_proj_flag               and
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
         x_purged_date is null) )                                              and
      ( (recinfo.purge_release = x_purge_release )                            or
        (recinfo.purge_release is null                                        and
         x_purge_release is null) )

    )   then
       return ;

  else

     fnd_message.set_name('FND','FORM_RECORD_CHANGED');
     app_exception.raise_exception ;


  end if ;

 END lock_row;

---------------------------------------------------------------------------


END pa_purge_batches_pkg;

/
