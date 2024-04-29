--------------------------------------------------------
--  DDL for Package Body FA_CUA_MASS_UPDATE1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_CUA_MASS_UPDATE1_PKG" as
/* $Header: FACMUP1MB.pls 120.3.12010000.3 2009/08/20 14:18:09 bridgway ship $*/

g_log_level_rec fa_api_types.log_level_rec_type;

----------------------------------------------------------------
PROCEDURE CALC_LIFE_ENDDATE( x_prorate_date                   DATE,
                             x_end_date                IN OUT NOCOPY DATE,
                             x_prorate_convention_code IN     VARCHAR2,
                             x_life                    IN     NUMBER,
                             x_err_code                IN OUT NOCOPY VARCHAR2,
                             x_err_stage               IN OUT NOCOPY VARCHAR2,
                             x_err_stack               IN OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS
/*
CURSOR C IS
  select  conv.prorate_date
  from    fa_conventions conv
  where   conv.prorate_convention_code = x_prorate_convention_code
  and     add_months(x_prorate_date,x_life)
        between conv.start_date and conv.end_date;
*/
CURSOR C IS
  select add_months(x_prorate_date,x_life)
  from dual;

BEGIN
   open c;
   fetch c into x_end_date;
   close c;
END;


----------------------------------------------------------------
FUNCTION GET_END_DATE(x_book_type_code	         VARCHAR2,
		                x_prorate_date            DATE,
                      x_life                    NUMBER, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) return date is
/** commneted for bugfix 1055453 */
/* this cursor displays life_end_date incorrectly ( to the last period_date defined )
   if the life fell beyond existing calendar periods
CURSOR C IS
select max(cp.end_date)
from fa_calendar_periods cp,
    fa_calendar_types ct,
    fa_book_controls bc
where bc.book_type_code = X_book_type_code and
     bc.date_ineffective is null and
     ct.calendar_type = bc.prorate_calendar  and
     cp.calendar_type = ct.calendar_type and
     cp.end_date <= add_months(x_prorate_date,x_life);

*/

-- added the following cursor for bugfix 1055453
CURSOR C IS
  select add_months(x_prorate_date,x_life)
  from dual;

l_end_date date;
Begin
  open c;
  fetch c into l_end_date;
  close c;

  return l_end_date;
End;

----------------------------------------------------------------
PROCEDURE CALC_LIFE(X_book_type_code	         VARCHAR2,
		      x_prorate_date     DATE,
		      x_end_date         DATE,
              x_deprn_method     IN VARCHAR2,
		      x_life             IN OUT NOCOPY number,
		      x_err_code in out nocopy varchar2 ,
		      x_err_stage in out nocopy varchar2 ,
		      x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS
  -- bugfix 1210531
  -- to improve peroformance do not use this cursor

    CURSOR GET_LIFE IS
       select /*+ ordered */ round
              (nvl(sum
               (decode (bc.deprn_allocation_code,'E',
                1/ct.number_per_fiscal_year,
                (cp.end_date + 1 - cp.start_date) /
                (fy.end_date + 1 - fy.start_date))),0) * 12, 0)
       from fa_calendar_periods cp,
            fa_calendar_types ct,
            fa_book_controls bc,
            fa_fiscal_year fy
       where bc.book_type_code = X_book_type_code and
             bc.date_ineffective is null and
             ct.calendar_type = bc.prorate_calendar and
             ct.fiscal_year_name = bc.fiscal_year_name
         and cp.calendar_type = ct.calendar_type and
             ( (cp.start_date >= x_prorate_date and
                cp.end_date <= x_end_date)
              or
               (cp.start_date <= x_prorate_date
                and cp.end_date >= x_prorate_date
                and cp.start_date <= x_end_date
                and cp.end_date <= x_end_date))
         and fy.fiscal_year_name = bc.fiscal_year_name
         and fy.start_date <= cp.start_date
         and fy.end_date >= cp.end_date;

    CURSOR GET_RSR IS
    select rate_source_rule
    from  fa_methods
    where method_code = x_deprn_method;

    l_rsr               varchar2(20);

    CURSOR CHECK_METHOD_EXISTS IS
    select 'X'
    from fa_methods
    where method_code = x_deprn_method
    and nvl(life_in_months,0) = x_life;

    l_dummy             varchar2(1);
    l_old_stack         varchar2(600);
    l_rowid             rowid;
    l_method_id         number;

  BEGIN


    x_err_code :='0';
    l_old_stack := x_err_stack ;
    x_err_stack := x_err_stack||'CALC_LIFE';

-- Return Life as Zero  if either of the dates is null. Therefore not possible to do calcs
    if (x_prorate_date is null) or (x_end_date is null) then
       x_life :=0;
       return;
    end if;

   -- bugfix 1210531
   -- instead of the cursor use months_between logic
   /*
    OPEN GET_LIFE;

    FETCH GET_LIFE INTO x_life;
    if GET_LIFE%NOTFOUND THEN
      x_life :=1;
    end if;
    CLOSE GET_LIFE;
    */

    x_life := ceil(months_between(x_end_date, x_prorate_date));
    if nvl(x_life, 0) < 0 then
      x_life:= 1;
    end if;


-- If Calendars are not setup OR some other problem then return life = 1 month
    select decode(x_life,null,1,0,1,x_life)
    into x_life
    from dual;

    OPEN GET_RSR;
    FETCH GET_RSR INTO l_rsr;
    CLOSE GET_RSR;

    OPEN CHECK_METHOD_EXISTS;
    FETCH CHECK_METHOD_EXISTS into l_dummy;
    IF CHECK_METHOD_EXISTS%NOTFOUND THEN
      if l_rsr = 'TABLE' then
          x_err_code := 'FA_REVAL_NO_METH_LIFE';
          return;
      else
           FA_METHODS_PKG.Insert_Row(
            X_Rowid	                   => l_rowid,
	    X_Method_Id	                   => l_method_id,
            X_Method_Code                  => x_deprn_method,
            X_Life_In_Months               => x_life,
            X_Depreciate_Lastyear_Flag     => 'YES',
  	    X_STL_Method_Flag 	           => 'YES',
  	    X_Rate_Source_Rule	           => 'CALCULATED',
	    X_Deprn_Basis_Rule	           => 'COST',
	    X_Prorate_Periods_Per_Year     => NULL,
 	    X_Name			   => 'Straight-Line',
	    X_Last_Update_Date   	   => sysdate,
	    X_Last_Updated_By	           => FND_GLOBAL.LOGIN_ID,
	    X_Created_By		   => FND_GLOBAL.LOGIN_ID,
	    X_Creation_Date		   => sysdate,
	    X_Last_Update_Login	           => FND_GLOBAL.LOGIN_ID,
	    X_Attribute1		   => null,
    	    X_Attribute2		   => null,
	    X_Attribute3		   => null,
	    X_Attribute4		   => null,
	    X_Attribute5		   => null,
	    X_Attribute6		   => null,
	    X_Attribute7		   => null,
	    X_Attribute8		   => null,
	    X_Attribute9		   => null,
	    X_Attribute10		   => null,
	    X_Attribute11		   => null,
	    X_Attribute12		   => null,
	    X_Attribute13		   => null,
	    X_Attribute14		   => null,
	    X_Attribute15		   => null,
	    X_Attribute_Category_Code      => null,
	    X_Calling_Fn		   => 'CALC_LIFE', p_log_level_rec => p_log_level_rec);

    end if;

    CLOSE CHECK_METHOD_EXISTS;

  end if;

        x_err_stack := l_old_stack ;

  END ;


----------------------------------------------------------------
PROCEDURE Val_Reclass(X_Old_Cat_Id		NUMBER,
			X_New_Cat_Id		NUMBER,
			X_Asset_Id		    NUMBER,
			X_Asset_Type		VARCHAR2,
			X_Old_Cap_Flag		VARCHAR2,
			X_Old_Cat_Type		VARCHAR2,
            x_new_cap_flag      VARCHAR2,
			X_New_Cat_Type		IN OUT NOCOPY VARCHAR2,
			X_Lease_Id		     NUMBER,
            x_err_code in out nocopy varchar2 ,
            x_err_stage in out nocopy varchar2 ,
            x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

  ll_corp_book		varchar2(30);
  ll_count		number;
  ll_mesg		varchar2(50);
  l_old_stack   varchar2(600);

  BEGIN
    x_err_code := '0';
    l_old_stack := x_err_stack ;
    x_err_stack := x_err_stack||'->Updating Asset Catgeory';

   -- find corporate book
  x_err_stage := 'find corporate book';

  select bc.book_type_code into ll_corp_book
  from fa_books bk, fa_book_controls bc
  where bc.book_class = 'CORPORATE'
  and bk.asset_id = X_Asset_Id
  and bk.book_type_code = bc.book_type_code
  and bk.date_ineffective is null;

  -- validate new category
  x_err_stage := 'validate new category';

 if X_ASSET_TYPE = 'CIP' then
      -- check that CIP accounts are set up
      select count(*)
      into ll_count
      from fa_category_books
      where category_id = X_new_cat_ID
      and book_type_code = ll_corp_book
      and cip_cost_acct is not null
      and cip_clearing_acct is not null;
      --
      if ll_count = 0 then
	   x_err_code := 'FA_SHARED_NO_CIP_ACCOUNTS';
	   return;
      end if;
 end if;

   -- check if cat is set up in this book
   select count(*)
   into ll_count
   from fa_category_books
   where book_type_code = ll_corp_book and
   category_id = X_new_cat_ID;
   --
   if ll_count = 0 then
      x_err_code := 'FA_BOOK_CAT_NOT_SET_UP';
      return;
   end if;

  -- both categories must be capitalized or expensed types
  --
  if X_Old_Cap_Flag = 'YES' then
     if x_new_cap_flag = 'NO' then
	   x_err_code := 'FA_ADD_RECLS_TO_CAP_ASSET';
       return;
     end if;
  elsif X_Old_Cap_Flag = 'NO' then
     if x_new_cap_flag = 'YES' then
	   x_err_code := 'FA_ADD_RECLS_TO_EXPENSE';
 	   return;
     end if;
  end if;
  -- also check lease stuff
  if X_Old_Cat_Type = 'LEASE' and X_New_Cat_Type <> 'LEASE' then
     select count(*) into ll_count
     from fa_additions
     where lease_id = X_Lease_Id
     and asset_category_id in
	(select category_id from fa_categories
     	where category_type = 'LEASEHOLD IMPROVEMENT');
     --
     if ll_count > 0 then
	   x_err_code := 'FA_ADD_DELETE_LHOLD_BEFORE_RCL';
	   return;
     end if;
     --
     select count(*) into ll_count
     from fa_leases
     where lease_id = X_Lease_Id;
     --
     if ll_count > 0 then
	   x_err_code := 'FA_ADD_DELETE_LEASE_BEFORE_RCL';
	   return;
     end if;
  end if;
  --
  --  no pending retirements

  x_err_stage := 'no pending retirements';

   select count(*)
  into ll_count
  from fa_retirements
  where asset_id = X_Asset_Id
  and status in ('PENDING', 'REINSTATE', 'PARTIAL');
  --
  if ll_count > 0 then
     x_err_code := 'FA_RET_PENDING_RETIREMENTS';
     return;
  end if;
  --

  x_err_stack := l_old_stack;

  EXCEPTION
	WHEN others THEN
		x_err_code := substr(sqlcode, 1, 240);
        return;

  END Val_Reclass;

----------------------------------------------------------------
 Procedure update_category
(x_asset_id in number,
x_old_cat_id in number,
x_new_cat_id in number,
x_err_code in out nocopy varchar2 ,
x_err_stage in out nocopy varchar2 ,
x_err_stack in out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

--l_status Boolean := TRUE;
l_old_stack  varchar2(600);
--l_thid   number;
--l_new_capitalize_flag varchar2(10);
--l_new_Category_Type varchar2(30);
--l_cat_flex_struct   NUMBER;
--l_cat_segs          FA_RX_SHARED_PKG.Seg_Array;
--l_asset_rec         fa_additions_v%rowtype;

--l_return_status BOOLEAN;
--l_return_status2 BOOLEAN;
--l_return_status3 BOOLEAN;

l_api_version        CONSTANT number := 1.0;
l_msg_list           VARCHAR2(5) := FND_API.G_FALSE;
l_commit_flag        VARCHAR2(5) := FND_API.G_FALSE;
l_validation_level   VARCHAR2(5) := FND_API.G_VALID_LEVEL_FULL;
l_debug_flag         VARCHAR2(5) := FND_API.G_FALSE;
l_calling_fn         VARCHAR2(20) := 'update_category';

l_trans_rec          FA_API_TYPES.trans_rec_type;
l_asset_hdr_rec      FA_API_TYPES.asset_hdr_rec_type;
l_asset_cat_rec_new  FA_API_TYPES.asset_cat_rec_type;
l_recl_opt_rec       FA_API_TYPES.reclass_options_rec_type;
l_count              NUMBER;
l_return_status      VARCHAR2(100);
l_msg_count		      NUMBER := 0;
l_msg_data		      VARCHAR2(4000);

Begin

  x_err_code := '0';
  l_old_stack := x_err_stack ;
  x_err_stack := x_err_stack||'->Updating Asset Catgeory';

  select bc.book_type_code
    into l_asset_hdr_rec.book_type_code
    from fa_books  bk,
         fa_book_controls bc
   where bk.asset_id = x_asset_id
     and bk.book_type_code = bc.book_type_code
     and bk.transaction_header_id_out is null
     and bc.book_class = 'CORPORATE';

  l_asset_hdr_rec.asset_id := x_asset_id;
  l_asset_cat_rec_new.category_id := x_new_cat_id;
  x_err_stage := 'Performing the Recalssification';

  -- BMR: validation is removed because most of the variables wer based
  -- on selects not need for api call

  FA_RECLASS_PUB.do_reclass (
           p_api_version  => l_api_version,
           p_init_msg_list => l_msg_list,
           p_commit        => l_commit_flag,
           p_validation_level  => l_validation_level,
           p_calling_fn        => l_calling_fn,
           x_return_status     => l_return_status,
           x_msg_count         => l_msg_count,
           x_msg_data          => l_msg_data,
           -- api parameters
           px_trans_rec          => l_trans_rec,
           px_asset_hdr_rec      => l_asset_hdr_rec,
           px_asset_cat_rec_new  => l_asset_cat_rec_new,
           p_recl_opt_rec        => l_recl_opt_rec );

 if not(l_return_status <> 'S') then
   x_err_code := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_TRUE), 1, 512);
 end if;

 x_err_stack := l_old_stack;

Exception
  When others then
    x_err_code := substr(sqlcode,1, 240);
    rollback;
   return;

End;


---------------------------------------------------------------
PROCEDURE do_transfer(
         p_asset_id                 in number,
         p_book_type_code           in varchar2,
         p_new_hr_dist_set_id       in number,
         p_transaction_date         in date,
         x_err_code                 out nocopy varchar2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) IS

CURSOR GET_DIST_HIST IS
        SELECT
            DH.ROWID,
            DH.DISTRIBUTION_ID,
            DH.CODE_COMBINATION_ID,
            DH.UNITS_ASSIGNED,
            DH.LOCATION_ID,
            DH.DATE_EFFECTIVE,
            DH.ASSIGNED_TO,
            DH.TRANSACTION_HEADER_ID_IN
        FROM
            FA_DISTRIBUTION_HISTORY DH,
            FA_BOOK_CONTROLS BC
        WHERE
            DH.ASSET_ID = p_asset_id AND
            DH.BOOK_TYPE_CODE = BC.DISTRIBUTION_SOURCE_BOOK AND
            BC.BOOK_TYPE_CODE = p_book_type_code AND
            DH.DATE_INEFFECTIVE IS NULL AND
            DH.RETIREMENT_ID IS NULL;

CURSOR get_hr_dist( p_txn_units in number ) is
    SELECT
      (DH.DISTRIBUTION_LINE_PERCENTAGE/100)* p_txn_units new_units,
      DH.CODE_COMBINATION_ID expense_ccid,
      DH.LOCATION_ID,
      DH.ASSIGNED_TO
    FROM
      FA_HIERARCHY_DISTRIBUTIONS DH,
      FA_ADDITIONS A
    WHERE
      A.ASSET_ID = p_asset_id AND
      DH.DIST_SET_ID = p_new_hr_dist_set_id;


  l_return_status         varchar2(1);
  l_msg_count       number:= 0;
  l_msg_data        varchar2(4000);

  l_trans_rec             fa_api_types.trans_rec_type;
  l_asset_hdr_rec         fa_api_types.asset_hdr_rec_type;

  l_asset_dist_tbl        fa_api_types.asset_dist_tbl_type;
  i binary_integer;
  tfr_error EXCEPTION;
Begin

     l_asset_hdr_rec.asset_id := p_asset_id;
     l_asset_hdr_rec.book_type_code := p_book_type_code;

     l_trans_rec.transaction_date_entered := p_transaction_date;

     -- source distribution
     for dist_hist_rec in get_dist_hist loop
        l_asset_dist_tbl.delete;
        i := 0;
        i := i+1;
        l_asset_dist_tbl(i).distribution_id := dist_hist_rec.distribution_id;
        l_asset_dist_tbl(i).transaction_units := dist_hist_rec.units_assigned * -1;


        --  destination distribution
        for dist_set_rec in get_hr_dist(dist_hist_rec.units_assigned) loop
           i := i+1;
           l_asset_dist_tbl(i).distribution_id := NULL;
           l_asset_dist_tbl(i).transaction_units := dist_set_rec.new_units;
           l_asset_dist_tbl(i).assigned_to := dist_set_rec.assigned_to;
           l_asset_dist_tbl(i).expense_ccid := dist_set_rec.expense_ccid;
           l_asset_dist_tbl(i).location_ccid := dist_set_rec.location_id;
        end loop;

        l_msg_count := null;
        l_msg_data := null;
        l_return_status := null;
        FA_TRANSFER_PUB.do_transfer(
              p_api_version       => 1.0,
              p_init_msg_list     => FND_API.G_FALSE,
              p_commit            => FND_API.G_FALSE,
              p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
              p_calling_fn        => NULL,
              x_return_status     => l_return_status,
              x_msg_count         => l_msg_count,
              x_msg_data          => l_msg_data,
              px_trans_rec        => l_trans_rec,
              px_asset_hdr_rec    => l_asset_hdr_rec,
              px_asset_dist_tbl    => l_asset_dist_tbl);

              if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  x_err_code := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_TRUE), 1, 512);
                  return;
              end if;
     end loop;

End;


-- ------------------------------------------
PROCEDURE do_adjustment( px_trans_rec        IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                         px_asset_hdr_rec    IN OUT NOCOPY FA_API_TYPES.asset_hdr_rec_type,
                         x_new_life          IN     NUMBER,
                         p_amortize_flag     IN     VARCHAR2,
                         x_err_code             OUT NOCOPY VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

    l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_rec_new        FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_mrc_tbl_new    FA_API_TYPES.asset_fin_tbl_type;
    l_inv_trans_rec            FA_API_TYPES.inv_trans_rec_type;
    l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
    l_asset_deprn_rec_adj      FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_rec_new      FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_mrc_tbl_new  FA_API_TYPES.asset_deprn_tbl_type;
    l_inv_rec                  FA_API_TYPES.inv_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;
    l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

    l_return_status            VARCHAR2(1);
    l_mesg_count               number := 0;
    l_mesg_len                 number;
    l_mesg                     varchar2(4000);

    Cursor C_books is
    select basic_rate,
           adjusted_rate,
           production_capacity,
           deprn_method_code
    from fa_books
    where asset_id = px_asset_hdr_rec.asset_id
    and book_type_code = px_asset_hdr_rec.book_type_code
    and date_ineffective is null;

BEGIN


         if p_amortize_flag = 'NO' then
              px_trans_rec.amortization_start_date := null;
              px_trans_rec.transaction_subtype  := 'EXPENSED';
         else
              px_trans_rec.transaction_subtype  := 'AMORTIZED';
         end if;

         l_asset_fin_rec_adj.life_in_months := x_new_life;

         FA_ADJUSTMENT_PUB.do_adjustment
                           (p_api_version             => 1.0,
                            p_init_msg_list           => FND_API.G_FALSE,
                            p_commit                  => FND_API.G_FALSE,
                            p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
                            x_return_status           => l_return_status,
                            x_msg_count               => l_mesg_count,
                            x_msg_data                => l_mesg,
                            p_calling_fn              => 'fa_cua_mass_update1_pkg.do_adjustment',
                            px_trans_rec              => px_trans_rec,
                            px_asset_hdr_rec          => px_asset_hdr_rec,
                            p_asset_fin_rec_adj       => l_asset_fin_rec_adj,
                            x_asset_fin_rec_new       => l_asset_fin_rec_new,
                            x_asset_fin_mrc_tbl_new   => l_asset_fin_mrc_tbl_new,
                            px_inv_trans_rec          => l_inv_trans_rec,
                            px_inv_tbl                => l_inv_tbl,
                            p_asset_deprn_rec_adj     => l_asset_deprn_rec_adj,
                            x_asset_deprn_rec_new     => l_asset_deprn_rec_new,
                            x_asset_deprn_mrc_tbl_new => l_asset_deprn_mrc_tbl_new,
                            p_group_reclass_options_rec => l_group_reclass_options_rec);



    if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
       x_err_code := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_TRUE), 1, 512);
       return;
    end if;

EXCEPTION
when others then
     x_err_code := substr(sqlerrm, 1, 200);
     return;

END do_adjustment;

-- -------------------------------------------------------------
-- Process_Conc
--    Called by the concurrent program to process batches.  This
--    procedure serves as a wrapper to the Process procedure.
-- -------------------------------------------------------------

PROCEDURE Proc_Conc( ERRBUF                  OUT NOCOPY  VARCHAR2,
                     RETCODE                 OUT NOCOPY  VARCHAR2,
                     x_from_batch_number  IN      NUMBER,
                     x_to_batch_number    IN      NUMBER) IS

    l_dummy   varchar2(1);
    l_request_id number;
    l_ret_value  number;

    CURSOR l_batch_csr IS
    SELECT batch_id,
           decode(amortize_flag,'Y','YES','NO') amortize_flag,
           amortization_date,
           transaction_name,
           attribute_category,
           attribute1,
           attribute2,
           attribute3,
           attribute4,
           attribute5,
           attribute6,
           attribute7,
           attribute8,
           attribute9,
           attribute10,
           attribute11,
           attribute12,
           attribute13,
           attribute14,
           attribute15
    FROM fa_mass_update_batch_headers
    WHERE status_code in ('IP','P','PP','R')
    AND  batch_number >= nvl(X_from_Batch_number,batch_number)
    AND   batch_number <= nvl(X_to_batch_number,batch_number)
    order by creation_date;
    --FOR UPDATE NOWAIT;

    l_trans_rec  FA_API_TYPES.trans_rec_type;

BEGIN

    retcode := '0';
    BEGIN

      l_trans_rec.mass_reference_id          := fnd_global.conc_request_id;
      l_trans_rec.who_info.last_update_date  := sysdate;
      l_trans_rec.who_info.last_updated_by   := fnd_global.user_id;
      l_trans_rec.who_info.created_by        := l_trans_rec.who_info.last_updated_by;
      l_trans_rec.who_info.creation_date     := sysdate;
      l_trans_rec.who_info.last_update_login := fnd_global.login_id;


      FOR l_batch_rec IN l_batch_csr LOOP

        update fa_mass_update_batch_headers
        set status_code = 'IP'
        where batch_id = l_batch_rec.batch_id;

        -- assign attribute values to global_variables
        fa_cua_asset_apis.g_process_batch := 'Y';
        fa_cua_asset_apis.g_transaction_name := l_batch_rec.transaction_name;
        fa_cua_asset_apis.g_attribute_category := l_batch_rec.attribute_category;
        fa_cua_asset_apis.g_attribute1 := l_batch_rec.attribute1;
        fa_cua_asset_apis.g_attribute2 := l_batch_rec.attribute2;
        fa_cua_asset_apis.g_attribute3 := l_batch_rec.attribute3;
        fa_cua_asset_apis.g_attribute4 := l_batch_rec.attribute4;
        fa_cua_asset_apis.g_attribute5 := l_batch_rec.attribute5;
        fa_cua_asset_apis.g_attribute6 := l_batch_rec.attribute6;
        fa_cua_asset_apis.g_attribute7 := l_batch_rec.attribute7;
        fa_cua_asset_apis.g_attribute8 := l_batch_rec.attribute8;
        fa_cua_asset_apis.g_attribute9 := l_batch_rec.attribute9;
        fa_cua_asset_apis.g_attribute10 := l_batch_rec.attribute10;
        fa_cua_asset_apis.g_attribute11 := l_batch_rec.attribute11;
        fa_cua_asset_apis.g_attribute12 := l_batch_rec.attribute12;
        fa_cua_asset_apis.g_attribute13 := l_batch_rec.attribute13;
        fa_cua_asset_apis.g_attribute14 := l_batch_rec.attribute14;
        fa_cua_asset_apis.g_attribute15 := l_batch_rec.attribute15;

        l_trans_rec.transaction_name := l_batch_rec.transaction_name;
        l_trans_rec.desc_flex.attribute_category_code := l_batch_rec.attribute_category;
        l_trans_rec.desc_flex.attribute1 := l_batch_rec.attribute1;
        l_trans_rec.desc_flex.attribute2 := l_batch_rec.attribute2;
        l_trans_rec.desc_flex.attribute3 := l_batch_rec.attribute3;
        l_trans_rec.desc_flex.attribute4 := l_batch_rec.attribute4;
        l_trans_rec.desc_flex.attribute5 := l_batch_rec.attribute5;
        l_trans_rec.desc_flex.attribute6 := l_batch_rec.attribute6;
        l_trans_rec.desc_flex.attribute7 := l_batch_rec.attribute7;
        l_trans_rec.desc_flex.attribute8 := l_batch_rec.attribute8;
        l_trans_rec.desc_flex.attribute9 := l_batch_rec.attribute9;
        l_trans_rec.desc_flex.attribute10 := l_batch_rec.attribute10;
        l_trans_rec.desc_flex.attribute11 := l_batch_rec.attribute11;
        l_trans_rec.desc_flex.attribute12 := l_batch_rec.attribute12;
        l_trans_rec.desc_flex.attribute13 := l_batch_rec.attribute13;
        l_trans_rec.desc_flex.attribute14 := l_batch_rec.attribute14;
        l_trans_rec.desc_flex.attribute15 := l_batch_rec.attribute15;
        l_trans_rec.amortization_start_date := l_batch_rec.amortization_date;

        process_batch( px_trans_rec     => l_trans_rec,
                       p_batch_id       => l_batch_rec.batch_id,
                       p_amortize_flag  => l_batch_rec.amortize_flag,
                       p_log_level_rec  => g_log_level_rec);


       -- check if there are any line unprocessed or Rejected
        l_dummy := 'N';

      Begin
        select 'Y'
        into l_dummy
        from fa_mass_update_batch_details
        where batch_id = l_batch_rec.batch_id
        and status_code in ('P','R')
        and rownum = 1;
      Exception
        When others then
           null;
       End ;

   if l_dummy = 'Y' then

    	  update fa_mass_update_batch_headers
    	  set status_code = 'R' -- Rejected Processed
                  , concurrent_request_id = l_Request_ID
                  , last_updated_by = fnd_global.login_id
                  , last_update_date = sysdate
                  , last_update_login = fnd_global.login_id
    	  where batch_id = l_batch_rec.batch_id;
   else
          update fa_mass_update_batch_headers
          set status_code = 'CP' -- Completetly Processed
              , concurrent_request_id = l_Request_ID
              , last_updated_by = fnd_global.login_id
              , last_update_date = sysdate
              , last_update_login = fnd_global.login_id
          where batch_id = l_batch_rec.batch_id;
    end if;
    END LOOP;
    commit;

  EXCEPTION
    WHEN OTHERS THEN
      RETCODE := '2';
      ERRBUF := SQLERRM;
  END;



  if RETCODE = '0' then
    l_ret_value := fnd_request.submit_request('CUA','CUAMUPR',null,null,FALSE, l_request_id);
    if (l_ret_value  = 0) then
       ERRBUF  := 'Failed to Submit Mass Update report';
    else
       commit;
    end if;
   end if;


END Proc_Conc;


-- -------------------------------------------------------------
-- Process
--   This procedure can be called online using the Mass Update
--   Batches form or as a concurrent program.
--
--  Commit is performed once  all the Asset records are processed
--  in a batch.
--  If even one asset record is rejected then the Batch Status is
--  Set to Rejected and changes for accepted assets is rolled back
-- as if they had not been processed at all
-- -------------------------------------------------------------

PROCEDURE process_batch( px_trans_rec        IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                        p_batch_id          IN     NUMBER ,
                        p_amortize_flag     IN     VARCHAR2 , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type  default null) IS
    l_asset_id number;
    l_book     varchar2(30);
    l_dummy    varchar2(1);
    l_status   boolean;

    l_transaction_date  		date;

    l_err_code  varchar2(600);
    l_err_stage varchar2(600);
    l_err_stack varchar2(600);
    l_error_flag varchar2(1) := 'N'; -- Flag to indicate if any asset record has errored.
    h_mesg_str varchar2(2000);

    -- -----------------------
    -- Cursor declarations
    -- -----------------------

    CURSOR l_get_books is
      SELECT distinct book_type_code
      from fa_mass_update_batch_details
      WHERE batch_id = p_Batch_ID
      and   status_code in ('P','R')
      and   apply_flag = 'Y';

    CURSOR l_get_assets_csr is
    SELECT distinct asset_id
    from fa_mass_update_batch_details
    WHERE batch_id = p_Batch_ID
    and   book_type_code = l_book
    and   status_code in ('P','R')
    and   apply_flag = 'Y';


    l_message_name varchar2(240);


    -- We create a new record type to store the error information
    -- for each batch line that fails to validate.  A PL/SQL table
    -- will be used to store all the failed lines.  We need to do
    -- this because we want to process all the lines even if an
    -- error has occured in one of the lines
    --
    TYPE ErrorRecTyp IS RECORD(
   attribute_name    VARCHAR2(30),
	rejection_reason	VARCHAR2(250) );

    TYPE ErrorTabTyp IS TABLE OF ErrorRecTyp
	INDEX BY BINARY_INTEGER;

    l_Error_Tab		ErrorTabTyp;  -- error table
    l_return_status     BOOLEAN;

    error_exp exception;
    l_attribute_name varchar2(30);
BEGIN

   fnd_message.set_name('OFA','FA_LIFE_CHANGE_EXCEPTION');
   fnd_message.set_token('AMORT_DATE',to_char(px_trans_rec.amortization_start_date,'DD/MM/YYYY'));
   h_mesg_str := fnd_message.get;
   fa_rx_conc_mesg_pkg.out(h_mesg_str);

   FOR l_get_book_rec IN l_get_books LOOP

      l_book := l_get_book_rec.book_type_code;

      select  greatest(calendar_period_open_date,
                       least(sysdate, calendar_period_close_date))
      into    l_transaction_date
      from    fa_deprn_periods
      where   book_type_code = l_book
      and     period_close_date is null;

      FOR l_asset_rec IN l_get_assets_csr LOOP
         l_asset_id := l_asset_rec.asset_id;

         l_err_code := '0';

         /* moved this update here for bugfix 1389275 */
         -- Changes the status of the Asset detail records to In Process
         update  fa_mass_update_batch_details
         set   status_code = 'IP'
         where  batch_id = p_batch_id
         and asset_id = l_asset_id
         and book_type_code = l_book;

        if not FA_TRX_APPROVAL_PKG.faxcat(
                        X_book          => l_book,
                        X_asset_id      => l_asset_id,
                        X_trx_type      => 'RECLASS',
                        X_trx_date      => l_transaction_date,
                        X_init_message_flag=> 'YES', p_log_level_rec => p_log_level_rec) then

              l_err_code := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_TRUE), 1, 512);

              if nvl(l_err_code, '0') = '0' then
                 -- check_pending_batches procedure returned false;
                 l_err_code := 'CUA_PENDING_BOOK';
              end if;

         else
           px_trans_rec.transaction_date_entered:= l_transaction_date;
           process_asset( px_trans_rec    => px_trans_rec,
                          p_batch_id      => p_batch_id,
                          p_asset_id      => l_asset_id,
                          p_book          => l_book,
                          p_amortize_flag => p_amortize_flag,
                          x_err_code      => l_err_code,
                          x_err_attr_name => l_attribute_name ,
                          p_log_level_rec => p_log_level_rec);

           if l_err_code <> '0' then
               l_error_flag := 'Y';

             if ( (substrb(l_err_code, 1,3) = 'FA_') OR
                  (substrb(l_err_code, 1,3) = 'CUA')) then

                 if (substrb(l_err_code, 1,3) = 'FA_') then
                     fnd_message.set_name ('OFA',l_err_code);
                     l_message_name := substrb(fnd_message.get,1,240);
                 end if;

                 if (substrb(l_err_code, 1,3) = 'CUA') then
                    fnd_message.set_name ('CUA',l_err_code);
                    l_message_name := substrb(fnd_message.get,1,240);
                 end if;
             else
                 if substr(l_err_code,1,1) = '-' then
                    l_message_name := substrb(sqlerrm(l_err_code),1,240);
                 else
                     l_message_name := l_err_code;
                 end if;
             end if;

            -- Populate Table with rejection reasons
            l_error_tab(l_asset_id).attribute_name:= l_attribute_name;
            l_error_tab(l_asset_id).rejection_reason := l_message_name;
          end if;
       end if;

    END LOOP;
  END LOOP;

  if l_error_flag = 'Y' then
    rollback;

    FOR l_get_book_rec IN l_get_books LOOP
      l_book := l_get_book_rec.book_type_code;

      FOR l_asset_rec IN l_get_assets_csr LOOP
	     l_asset_id := l_asset_rec.asset_id;

        if l_error_tab.exists(l_asset_id) then
	        update  fa_mass_update_batch_details
	        set  rejection_reason = l_error_tab(l_asset_id).rejection_reason,
		          concurrent_request_id = px_trans_rec.mass_reference_id,
		          status_code = 'R',
                last_updated_by = px_trans_rec.who_info.last_updated_by,
                last_update_date = px_trans_rec.who_info.last_update_date,
                last_update_login = px_trans_rec.who_info.last_update_login
	        where asset_id = l_asset_id
	        and   book_type_code = l_book
	        and   batch_id = p_batch_id
           and   attribute_name = nvl(l_attribute_name, attribute_name)
	        and   status_code in ('P','R')  -- since rollback will revert the update to 'IP'
	        and   nvl(apply_flag,'N') = 'Y';
        end if;

	   END LOOP;
    END LOOP;

  else -- No Asset record failed. Therefore update the status to Accepted for all records
    update  fa_mass_update_batch_details
    set   rejection_reason = null,
          concurrent_request_id = px_trans_rec.mass_reference_id,
          status_code = 'A',
          last_updated_by = px_trans_rec.who_info.last_updated_by,
          last_update_date = px_trans_rec.who_info.last_update_date,
          last_update_login = px_trans_rec.who_info.last_update_login
    where batch_id = p_batch_id
    and   status_code = 'IP' -- changed to 'IP'from ( 'P', 'R')- bugfix 1389275
    and nvl(apply_flag,'N') = 'Y';
  end if;

End;


PROCEDURE process_asset( px_trans_rec    IN OUT NOCOPY FA_API_TYPES.trans_rec_type,
                        p_batch_id       IN     NUMBER,
                        p_asset_id       IN     NUMBER,
                        p_book           IN     VARCHAR2,
                        p_amortize_flag  IN     VARCHAR2,
                        x_err_code          OUT NOCOPY VARCHAR2,
                        x_err_attr_name     OUT NOCOPY VARCHAR2  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type   default null) IS

    l_asset_id number;
    l_new_life number;
    l_old_life number;
    l_amortization_date date;
    prior_date_effective        DATE;
    check_prior_addition    number;
    check_flag              varchar2(2);
    l_dummy    varchar2(1);
    l_amortize_flag         varchar2(3) ;

    CURSOR l_get_Lines_csr IS
    SELECT attribute_name,
           attribute_old_id,
           attribute_new_id,
           derived_from_entity_id,
           derived_from_entity,
           status_code
    FROM fa_mass_update_batch_details
    WHERE batch_id = p_batch_id
    and   asset_id = p_asset_id
    and   book_type_code = p_book
    AND   apply_flag = 'Y'
    AND   STATUS_CODE in ('IP', 'P', 'R') -- added 'IP' as part of 138927
    order by decode(attribute_name,
                   'LIFE_END_DATE',1,
                   'SERIAL_NUMBER',2,
                   'ASSET_KEY',3,
                   'LEASE_NUMBER',4,
                   'DISTRIBUTION',5,
                   'CATEGORY',6)
    FOR UPDATE NOWAIT;

     h_status  boolean;

   -- api variables
   l_return_status      VARCHAR2(100);
   l_msg_count          NUMBER:= 0;
   l_msg_data           VARCHAR2(4000);
   l_api_version        CONSTANT number := 1.0;
   l_msg_list           VARCHAR2(5) := FND_API.G_FALSE;
   l_commit_flag        VARCHAR2(5) := FND_API.G_FALSE;
   l_validation_level   NUMBER := FND_API.G_VALID_LEVEL_FULL;
   l_calling_fn         VARCHAR2(20) := 'ASSET HIERARACHY';

   l_asset_hdr_rec      FA_API_TYPES.asset_hdr_rec_type;
   l_asset_cat_rec_new  FA_API_TYPES.asset_cat_rec_type;
   l_recl_opt_rec       FA_API_TYPES.reclass_options_rec_type;

   l_asset_desc_rec      FA_API_TYPES.asset_desc_rec_type;
   l_asset_type_rec      FA_API_TYPES.asset_type_rec_type;
   l_asset_cat_rec       FA_API_TYPES.asset_cat_rec_type;
   l_asset_dist_tbl      FA_API_TYPES.asset_dist_tbl_type;

   -- Adjustment parameters
    l_asset_fin_rec_adj        FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_rec_new        FA_API_TYPES.asset_fin_rec_type;
    l_asset_fin_mrc_tbl_new    FA_API_TYPES.asset_fin_tbl_type;
    l_inv_trans_rec            FA_API_TYPES.inv_trans_rec_type;
    l_inv_tbl                  FA_API_TYPES.inv_tbl_type;
    l_asset_deprn_rec_adj      FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_rec_new      FA_API_TYPES.asset_deprn_rec_type;
    l_asset_deprn_mrc_tbl_new  FA_API_TYPES.asset_deprn_tbl_type;
    l_inv_rec                  FA_API_TYPES.inv_rec_type;
    l_group_reclass_options_rec FA_API_TYPES.group_reclass_options_rec_type;

   l_request_id          number(15);

   l_update_attribute  varchar2(1):= 'N';

    l_err_stage varchar2(600);
    l_err_stack varchar2(600);
  Begin


    x_err_code := '0';
    -- Intialize Header variables
    l_asset_desc_rec := null;
    l_asset_hdr_rec  := null;
    l_asset_hdr_rec.asset_id        := p_asset_id;
    l_asset_hdr_rec.book_type_code  := p_book;
    px_trans_rec.calling_interface  := 'ASSET_HIERARCHY';

    FOR l_get_lines_rec in l_get_lines_csr LOOP

       -- cleanup for each loop
       fa_cua_asset_apis.g_derive_from_entity       := null;
       fa_cua_asset_apis.g_derive_from_entity_value := null;
       l_update_attribute := 'N';

       if l_get_lines_rec.attribute_name = 'CATEGORY' then
           if (l_get_lines_rec.attribute_old_id <> l_get_lines_rec.attribute_new_id)
              and (l_get_lines_rec.attribute_new_id is not null) then

           update_category( p_asset_id,
                            to_number(l_get_lines_rec.attribute_old_id) ,
                            to_number(l_get_lines_rec.attribute_new_id),
                            x_err_code,l_err_stage,l_err_stack, p_log_level_rec);
           if x_err_code <> '0' then
             x_err_attr_name := l_get_lines_rec.attribute_name;
             return;
           end if;

         end if;
       end if;

       if l_get_lines_rec.attribute_name = 'LEASE_NUMBER' then
         if (l_get_lines_rec.attribute_old_id <> l_get_lines_rec.attribute_new_id) or
             (l_get_lines_rec.attribute_old_id is null) then

           l_asset_desc_rec.lease_id := to_number(l_get_lines_rec.attribute_new_id);
           l_update_attribute := 'Y';

         end if;
       end if;

       if l_get_lines_rec.attribute_name = 'SERIAL_NUMBER' then
         if (l_get_lines_rec.attribute_old_id <> l_get_lines_rec.attribute_new_id) or
             (l_get_lines_rec.attribute_old_id is null) then

          l_asset_desc_rec.serial_number := l_get_lines_rec.attribute_new_id;
          l_update_attribute := 'Y';

         end if;
       end if;

       if l_get_lines_rec.attribute_name = 'ASSET_KEY' then
         if (l_get_lines_rec.attribute_old_id <> l_get_lines_rec.attribute_new_id) or
             (l_get_lines_rec.attribute_old_id is null) then

           l_asset_desc_rec.asset_key_ccid := to_number(l_get_lines_rec.attribute_new_id);
           l_update_attribute := 'Y';

         end if;
       end if;


       if l_update_attribute = 'Y' then
            FA_ASSET_DESC_PUB.update_desc(
            p_api_version       => l_api_version,
            p_init_msg_list     => l_msg_list,
            p_commit            => l_commit_flag,
            p_validation_level  => l_validation_level,
            x_return_status     => l_return_status,
            x_msg_count         => l_msg_count,
            x_msg_data          => l_msg_data,
            p_calling_fn        => 'fa_cua_mass_update1_pkg.process_asset_batch',
            px_trans_rec          => px_trans_rec,
            px_asset_hdr_rec      => l_asset_hdr_rec,
            px_asset_desc_rec_new => l_asset_desc_rec,
            px_asset_cat_rec_new  => l_asset_cat_rec);

            if ( l_return_status <> FND_API.G_RET_STS_SUCCESS) then
               x_err_code := substr(fnd_msg_pub.get(fnd_msg_pub.G_FIRST, fnd_api.G_TRUE), 1, 512);
               x_err_attr_name := l_get_lines_rec.attribute_name;
               return;
            end if;
       end if;

       if l_get_lines_rec.attribute_name = 'DISTRIBUTION' then
          if (  l_get_lines_rec.attribute_old_id <> l_get_lines_rec.attribute_new_id) or
             ( (l_get_lines_rec.attribute_old_id is null)
               and (l_get_lines_rec.attribute_new_id is not null) )  then

               do_transfer(
                         p_asset_id           => p_asset_id,
                         p_book_type_code     => p_book,
                         p_new_hr_dist_set_id => to_number(l_get_lines_rec.attribute_new_id),
                         p_transaction_date   => nvl(px_trans_rec.amortization_start_date,
                                                     px_trans_rec.transaction_date_entered ),
                         x_err_code           => x_err_code ,
                         p_log_level_rec      => p_log_level_rec);
              if x_err_code <> '0' then
                   x_err_attr_name := l_get_lines_rec.attribute_name;
                   return;
               end if;
          end if;
        end if;

--
     if l_get_lines_rec.attribute_name = 'LIFE_END_DATE' then
       if (l_get_lines_rec.attribute_old_id <> l_get_lines_rec.attribute_new_id) or
             (l_get_lines_rec.attribute_old_id is null) then
            l_new_life := to_number(l_get_lines_rec.attribute_new_id);
            l_old_life := to_number(l_get_lines_rec.attribute_old_id);

            l_amortization_date := px_trans_rec.amortization_start_date;

           -- If Asset has not started depreciating and user is trying to make an Amortized
           -- Adjustment, it would fail. Also check if there are no Amortized Changes.
           -- Therefore proactively set the Adjustment to Expensed
           -- so that the Life Change can go through.

           -- assign Life Derivation info to global variables. The global variables
           -- are refernced from DB trigger on FA_TRANSACTION_HEADERS to populate
           -- FA_LIFE_DERIVATION_INFO;

           fa_cua_asset_apis.g_derive_from_entity := l_get_lines_rec.derived_from_entity;
           fa_cua_asset_apis.g_derive_from_entity_value := l_get_lines_rec.derived_from_entity_id;

           do_adjustment ( px_trans_rec  => px_trans_rec,
                           px_asset_hdr_rec => l_asset_hdr_rec,
                           x_new_life       => l_new_life,
                           p_amortize_flag  => p_amortize_flag,
                           x_err_code       => x_err_code ,
                           p_log_level_rec  => p_log_level_rec);
               if x_err_code <> '0' then
                  x_err_attr_name := l_get_lines_rec.attribute_name;
                  return ;
               end if;
        end if;
    end if;

    -- Now restore to Pending/Rejected
       update fa_mass_update_batch_details
       set    status_code = l_get_lines_rec.status_code
       where  batch_id = p_batch_id
       and    asset_id = p_asset_id
       and    book_type_code = p_book;

    END LOOP;

Exception
    when OTHERS then
      x_err_code := substr(sqlerrm, 1, 240);
End process_asset;



END FA_CUA_MASS_UPDATE1_PKG;

/
