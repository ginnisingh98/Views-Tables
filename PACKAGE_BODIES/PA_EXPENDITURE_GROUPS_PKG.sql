--------------------------------------------------------
--  DDL for Package Body PA_EXPENDITURE_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EXPENDITURE_GROUPS_PKG" as
/* $Header: PAXTGRPB.pls 120.3 2005/08/16 02:57:34 vthakkar noship $ */

 -- forward declarations
 procedure check_submit_allowed (x_expenditure_group	in VARCHAR2,
                                 x_err_code		in out NOCOPY NUMBER,
                                 x_return_status	in out NOCOPY VARCHAR2);

 procedure execute_submit (x_expenditure_group	VARCHAR2,
                           x_err_code		in out NOCOPY NUMBER,
                           x_return_status	in out NOCOPY VARCHAR2);

 procedure update_exp (p_expenditure_group	in VARCHAR2 ,
                       p_exp_grp_status_code in Varchar2 ,
                       p_exp_status_code in Varchar2); /* Bug 3754869 and 3754875 */


 procedure insert_row (x_rowid				      in out NOCOPY VARCHAR2,
                       x_expenditure_group		  in VARCHAR2,
                       x_last_update_date		  in DATE,
                       x_last_updated_by		  in NUMBER,
                       x_creation_date			  in DATE,
                       x_created_by			      in NUMBER,
                       x_expenditure_group_status in VARCHAR2,
                       x_expenditure_ending_date  in DATE,
                       x_system_linkage_function  in VARCHAR2,
                       x_control_count			  in NUMBER,
                       x_control_total_amount	  in NUMBER,
                       x_description			  in VARCHAR2,
                       x_last_update_login		  in NUMBER,
                       x_transaction_source		  in VARCHAR2,
		               x_period_accrual_flag      in VARCHAR2,
                       P_Org_Id                   in NUMBER) -- 12i MOAC changes
 is

  cursor c is select rowid from pa_expenditure_groups
              where expenditure_group = x_expenditure_group;
  x_err_code		NUMBER;
  x_return_status	VARCHAR2(630);

 BEGIN

  insert into pa_expenditure_groups (
          expenditure_group,
          last_update_date,
          last_updated_by ,
          creation_date,
          created_by,
          expenditure_group_status_code,
          expenditure_ending_date,
          system_linkage_function,
          control_count,
          control_total_amount,
          description,
          last_update_login,
          transaction_source,
		  period_accrual_flag,
          org_id) -- 12i MOAC changes
  values (x_expenditure_group,
          x_last_update_date,
          x_last_updated_by,
          x_creation_date,
          x_created_by,
          'WORKING',
          x_expenditure_ending_date,
          x_system_linkage_function,
          x_control_count,
          x_control_total_amount,
          x_description,
          x_last_update_login,
          x_transaction_source,
          x_period_accrual_flag,
          P_Org_Id); -- 12i MOAC changes

  open c;
  fetch c into x_rowid;
  if (c%notfound) then
    raise NO_DATA_FOUND;
  end if;
  close c;

  -- We always initially insert the row with status 'WORKING' - if
  -- the row being inserted had status 'SUBMITTED', we then call
  -- the 'SUBMIT' function to set the status to 'SUBMITTED'.
  if (x_expenditure_group_status = 'SUBMITTED') then
    -- we bypass the error checking that submit does, since
    -- it should already have been done at the form level
    execute_submit (x_expenditure_group, x_err_code, x_return_status);
    if (x_err_code = 1) then
      app_exception.raise_exception;
    end if;
  end if;

 END insert_row;

 procedure update_row (x_rowid				      in VARCHAR2,
                       x_expenditure_group		  in VARCHAR2,
                       x_last_update_date		  in DATE,
                       x_last_updated_by		  in NUMBER,
                       x_expenditure_group_status in VARCHAR2,
                       x_expenditure_ending_date  in DATE,
                       x_system_linkage_function  in VARCHAR2,
                       x_control_count			  in NUMBER,
                       x_control_total_amount	  in NUMBER,
                       x_description			  in VARCHAR2,
                       x_last_update_login		  in NUMBER,
                       x_transaction_source		  in VARCHAR2,
		               x_period_accrual_flag      in VARCHAR2) is

  cursor c_orig_group is select * from pa_expenditure_groups
                         where rowid = x_rowid;

  x_orig_group  c_orig_group%rowtype;
  x_err_code		NUMBER;
  x_return_status	VARCHAR2(630);

 BEGIN

  open c_orig_group;
  fetch c_orig_group into x_orig_group;

  -- update all the columns to the new values, except for the
  -- expenditure_group_status_code column - we call on the appropriate
  -- submit/rework/release procedures to handle that.

  update pa_expenditure_groups
  set expenditure_group			= x_expenditure_group,
      last_update_date			= x_last_update_date,
      last_updated_by			= x_last_updated_by,
      expenditure_ending_date		= x_expenditure_ending_date,
      system_linkage_function		= x_system_linkage_function,
      control_count			= x_control_count,
      control_total_amount		= x_control_total_amount,
      description			= x_description,
      last_update_login			= x_last_update_login,
      transaction_source		= x_transaction_source,
      period_accrual_flag               = x_period_accrual_flag
  where rowid = x_rowid;


  if ((x_expenditure_group_status = 'SUBMITTED') and
      (x_orig_group.expenditure_group_status_code <> 'SUBMITTED')) then
--    submit (x_expenditure_group, x_err_code, x_return_status);
    -- we bypass the error checking that submit does, since
    -- it should already have been done at the form level
    execute_submit (x_expenditure_group, x_err_code, x_return_status);
    if (x_err_code = 1) then
      app_exception.raise_exception;
    end if;
  end if;

  if ((x_expenditure_group_status = 'RELEASED') and
      (x_orig_group.expenditure_group_status_code <> 'RELEASED')) then
    release (x_expenditure_group, x_err_code, x_return_status);
    if (x_err_code = 1) then
      app_exception.raise_exception;
    end if;
  end if;

  if ((x_expenditure_group_status = 'WORKING') and
      (x_orig_group.expenditure_group_status_code <> 'WORKING')) then
    rework (x_expenditure_group, x_err_code, x_return_status);
    if (x_err_code = 1) then
      app_exception.raise_exception;
    end if;
  end if;


 END update_row;

 -- The delete_row table handler cascades the delete to the
 -- expenditures table by calling the expenditures delete_row
 -- table handler.

 procedure delete_row (x_rowid	in  VARCHAR2) is
  cursor get_group is select expenditure_group,
                             expenditure_group_status_code
                      from pa_expenditure_groups
                      where rowid = x_rowid;
  groups_rec	get_group%rowtype;

 BEGIN
  open get_group;
  fetch get_group into groups_rec;
  -- check notfound?

  if (groups_rec.expenditure_group_status_code <> 'WORKING') then
    fnd_message.set_name ('PA', 'PA_TR_EPE_ONLY_DEL_WORK');
    app_exception.raise_exception;
  end if;

  -- cascade delete to expenditures.
  DECLARE
   cursor expnds is select expenditure_id from pa_expenditures
                     where expenditure_group = groups_rec.expenditure_group
                     for update of expenditure_id nowait;
   exp_rec  expnds%rowtype;
  BEGIN
   open expnds;
   LOOP
     fetch expnds into exp_rec;
     if (expnds%notfound) then
       exit;
     else
       --
       -- 3733123 - PJ.M:B5: QA:P11:OTH: MANUAL ENC/EXP  FORM CREATING ORPHAN ADLS
       -- delete award distribution lines..
       --
       gms_awards_dist_pkg.delete_adls(exp_rec.expenditure_id, NULL, 'EXP' ) ;

       pa_expenditures_pkg.delete_row (exp_rec.expenditure_id);
     end if;
   END LOOP;

  EXCEPTION
   when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
     fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
     app_exception.raise_exception;
  END;

  delete from pa_expenditure_groups
  where rowid = x_rowid;

 END delete_row;


 -- Locks the given row in the database.  Does not check if
 -- values have changed (currently not in use).

 procedure lock_row (x_rowid	in VARCHAR2) is
  dummy		NUMBER;
 BEGIN
  select 1 into dummy
  from pa_expenditure_groups
  where rowid = x_rowid
  for update of expenditure_group nowait;
 EXCEPTION

  when OTHERS then null;  -- pragma exception init ...

 END lock_row;


/*************************************************************************
 *  These are the procedure calls to submit, release, or rework an
 * existing expenditure group.  They are called by the update_row
 * table handler if the corresponding change to the status indicates
 * one of the actions has been performed, or can be called by a user
 * directly.
 *************************************************************************/

 --  Release an expenditure group.  Modifies all expenditures for that
 -- group to have status 'APPROVED'.

 procedure release (x_expenditure_group	in VARCHAR2,
                    x_err_code		in out NOCOPY NUMBER,
                    x_return_status	in out NOCOPY VARCHAR2) is

  cursor c_orig_group is select * from pa_expenditure_groups
                         where expenditure_group = x_expenditure_group;

  cursor lock_exps is select expenditure_id from pa_expenditures
                      where expenditure_group = x_expenditure_group
                      for update of expenditure_status_code nowait;

  x_orig_group  c_orig_group%rowtype;
  x_exps	lock_exps%rowtype;

 BEGIN

  open c_orig_group;
  fetch c_orig_group into x_orig_group;

  if (x_orig_group.expenditure_group_status_code <> 'SUBMITTED') then
    x_err_code := 1;
    x_return_status := 'Can only release Submitted group';
    fnd_message.set_name ('PA', 'PA_TR_EPE_REL_ONLY_SUBMIT');
  end if;

  -- make sure the expenditures are not locked before making the change
  open lock_exps;
  fetch lock_exps into x_exps;

  -- if it reaches here, the locks succeeded.

  /* Bug 3754875 : Removed the literals and added bind variables.
  update pa_expenditure_groups
  set expenditure_group_status_code = 'RELEASED'
  where expenditure_group = x_expenditure_group;
  */

  /* Bug 3754869 : Removed the literals and added bind variables.
  update pa_expenditures
  set expenditure_status_code = 'APPROVED'
  where expenditure_group = x_expenditure_group;
  */

  /* Bug 3754869 and 3754875 */
  update_exp ( p_expenditure_group => x_expenditure_group ,
               p_exp_grp_status_code => 'RELEASED' ,
               p_exp_status_code => 'APPROVED' );


 EXCEPTION
  when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
    x_err_code := 1;
    x_return_status := 'Could not lock expenditures';
    fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
 END release;


----------------------------------------------------------------------------

 --  Rework an expenditure group (set its status back to 'WORKING').
 -- Modifies all expenditures for that group to have status 'WORKING'.

 procedure rework (x_expenditure_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2) is

  cursor c_orig_group is select * from pa_expenditure_groups
                         where expenditure_group = x_expenditure_group
                         for update of expenditure_group_status_code nowait;

  cursor lock_exps is select expenditure_id from pa_expenditures
                      where expenditure_group = x_expenditure_group
                      for update of expenditure_status_code nowait;

  x_orig_group  c_orig_group%rowtype;
  x_exps	lock_exps%rowtype;




 BEGIN

  open c_orig_group;
  fetch c_orig_group into x_orig_group;

  if (x_orig_group.expenditure_group_status_code <> 'SUBMITTED') then
    x_err_code := 1;
    x_return_status := 'Can only rework Submitted group';
    fnd_message.set_name ('PA', 'PA_TR_EPE_REWORK_ONLY_SUBMIT');
  end if;

  -- make sure the expenditures are not locked before making the change
  open lock_exps;
  fetch lock_exps into x_exps;

  -- if it reaches here, the locks succeeded.
  /* Bug 3754875 : Removed the literals and added bind variables.
  update pa_expenditure_groups
  set expenditure_group_status_code = 'WORKING'
  where expenditure_group = x_expenditure_group;
  */

  /* Bug 3754869 : Removed the literals and added bind variables.
  update pa_expenditures
  set expenditure_status_code = 'WORKING'
  where expenditure_group = x_expenditure_group;
  */

  /* Bug 3754869 and 3754875 */
  update_exp ( p_expenditure_group => x_expenditure_group ,
               p_exp_grp_status_code => 'WORKING' ,
               p_exp_status_code => 'WORKING' );



 EXCEPTION
  when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
    x_err_code := 1;
    x_return_status := 'Could not lock expenditures';
    fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
 END rework;

----------------------------------------------------------------------------

--   Submitting an expenditure group is divided into two steps -
--  checking that the submit is allowed (there are quite a few checks
--  involved), and modifying all its expenditures to have status
--  'SUBMITTED'

 procedure submit (x_expenditure_group	in VARCHAR2,
                   x_err_code		in out NOCOPY NUMBER,
                   x_return_status	in out NOCOPY VARCHAR2) is

 BEGIN
  check_submit_allowed (x_expenditure_group, x_err_code, x_return_status);
  if (x_err_code = 0) then
    execute_submit (x_expenditure_group, x_err_code, x_return_status);
  end if;
 END submit;


----------------------------------------------------------------------------

 procedure check_submit_allowed (x_expenditure_group	in VARCHAR2,
                                 x_err_code		in out NOCOPY NUMBER,
                                 x_return_status	in out NOCOPY VARCHAR2) is

  cursor c_orig_group is select * from pa_expenditure_groups
                         where expenditure_group = x_expenditure_group;

  x_orig_group  c_orig_group%rowtype;
 BEGIN
  x_err_code := 0;

  open c_orig_group;
  fetch c_orig_group into x_orig_group;

  if (c_orig_group%notfound) then
    x_err_code := 1;
    x_return_status := 'group does not exist';
    return;
  end if;

  -- Check that the group being submitted was 'WORKING' to begin with.
  if (x_orig_group.expenditure_group_status_code <> 'WORKING') then
    x_err_code := 1;
    x_return_status := 'Can only submit working';
    fnd_message.set_name ('PA', 'PA_TR_EPE_SUBMIT_ONLY_WORK');
--    app_exception.raise_exception;
    return;
  end if;

  -- Check that expenditure items exist for the group
  DECLARE
   cursor count_ei is
      select count(*) from pa_expenditure_items
      where expenditure_id in
        (select expenditure_id from pa_expenditures
         where expenditure_group = x_expenditure_group);
   x_count	NUMBER;
  BEGIN
   open count_ei;
   fetch count_ei into x_count;
   if (x_count = 0) then
     x_err_code := 1;
     x_return_status := 'Exp items must exist';
     fnd_message.set_name ('PA', 'PA_TR_EPE_SUBMIT_NO_ITEMS');
--     app_exception.raise_exception;
     return;
   end if;
  END;

  -- If control amounts were entered, make sure they match
  -- the actual amounts.
  DECLARE
   cursor count_exp is
     select count(*) from pa_expenditures
     where expenditure_group = x_expenditure_group;

   cursor totals is
     select sum(quantity)
     from pa_expenditure_items
     where expenditure_id in
       (select expenditure_id from pa_expenditures
        where expenditure_group = x_expenditure_group);

   x_count	NUMBER;
   x_total	NUMBER;
  BEGIN
   if (x_orig_group.control_count is not null) then
     open count_exp;
     fetch count_exp into x_count;
     close count_exp;

     if (x_count <> x_orig_group.control_count) then
       x_err_code := 1;
       x_return_status := 'Control count does not match actual count';
       fnd_message.set_name ('PA', 'PA_TR_EPE_SUBMIT_CTRL_CNT');
       return;
     end if;
   end if;

   if (x_orig_group.control_total_amount is not null) then
     open totals;
     fetch totals into x_total;
     close totals;

     if (x_total <> x_orig_group.control_total_amount) then
       x_err_code := 1;
       x_return_status := 'Control total does not match actual total';
       fnd_message.set_name ('PA', 'PA_TR_EPE_SUBMIT_CTRL_AMTS');
       return;
     end if;
   end if;

  END;

  -- Make sure no quantities of null have been entered.
  DECLARE
     cursor null_qty is
       select count(*) from pa_expenditure_items
        where expenditure_id in (
          select expenditure_id from pa_expenditures
           where expenditure_group =  x_expenditure_group )
          and quantity is null ;
      number_of_nulls   NUMBER ;
  BEGIN
    open null_qty;
    fetch null_qty into number_of_nulls;
    if (number_of_nulls  > 0) then
        x_err_code := 1;
        x_return_status := 'Expenditure items have null quantities';
        fnd_message.set_name('PA', 'PA_TR_EPE_SUBMIT_NULL_QTY');
        return ;
    end if;
  END;

 END check_submit_allowed;


---------------------------------------------------------------------------

 procedure execute_submit (x_expenditure_group	VARCHAR2,
                           x_err_code		in out NOCOPY NUMBER,
                           x_return_status	in out NOCOPY VARCHAR2) is

  cursor lock_exps is select expenditure_id from pa_expenditures
                      where expenditure_group = x_expenditure_group
                      for update of expenditure_status_code nowait;

  x_exps	lock_exps%rowtype;


 BEGIN
  -- make sure the expenditures are not locked before making the change
  open lock_exps;
  fetch lock_exps into x_exps;

  /* Bug 3754875 : Removed the literals and added bind variables.
  update pa_expenditure_groups
  set expenditure_group_status_code = 'SUBMITTED'
  where expenditure_group = x_expenditure_group;
  */

  /* Bug 3754869 : Removed the literals and added bind variables.
  update pa_expenditures
  set expenditure_status_code = 'SUBMITTED'
  where expenditure_group = x_expenditure_group;
  */

  /* Bug 3754869 and 3754875 */
  update_exp ( p_expenditure_group => x_expenditure_group ,
               p_exp_grp_status_code => 'SUBMITTED' ,
               p_exp_status_code => 'SUBMITTED' );



 EXCEPTION
  when APP_EXCEPTION.RECORD_LOCK_EXCEPTION then
    x_err_code := 1;
    x_return_status := 'Could not lock expenditures';
    fnd_message.set_name ('FND', 'FORM_UNABLE_TO_RESERVE_RECORD');
 END execute_submit;

---------------------------------------------------------------------------
/* Bug 3754869 and 3754875 */
procedure update_exp (p_expenditure_group in varchar2 ,
                      p_exp_grp_status_code in Varchar2 ,
                      p_exp_status_code in Varchar2
					  )
Is

Begin

  update pa_expenditure_groups
  set expenditure_group_status_code = p_exp_grp_status_code
  where expenditure_group = p_expenditure_group ;

  update pa_expenditures
  set expenditure_status_code = p_exp_status_code
  where expenditure_group = p_expenditure_group ;

End;






END pa_expenditure_groups_pkg;

/
