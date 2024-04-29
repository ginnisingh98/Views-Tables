--------------------------------------------------------
--  DDL for Package Body FA_DET_ADD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DET_ADD_PKG" as
/* $Header: faxdadb.pls 120.5.12010000.2 2009/07/19 10:46:15 glchen ship $ */

  PROCEDURE Initialize(X_Asset_Id		NUMBER,
			X_PC_Fully_Ret		IN OUT NOCOPY NUMBER,
			X_Current_PC		IN OUT NOCOPY NUMBER,
			X_Transfer_In_PC	IN OUT NOCOPY NUMBER,
			X_Books_Cost		IN OUT NOCOPY NUMBER,
			X_Inv_Cost		IN OUT NOCOPY NUMBER,
			X_Deprn_Reserve		IN OUT NOCOPY NUMBER,
			X_Calling_Fn		VARCHAR2,
          p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  lv_corp_book	varchar2(30);
  BEGIN
 	SELECT BK.Period_Counter_Fully_Retired,BC.Book_Type_Code
	INTO X_PC_Fully_Ret, lv_corp_book
	FROM FA_BOOKS BK, FA_BOOK_CONTROLS BC
	WHERE BK.Asset_Id = X_Asset_Id
	AND BK.Date_Ineffective IS NULL
	AND BK.Book_Type_Code = BC.Book_Type_Code
	AND BC.Book_Class = 'CORPORATE';
	--
	SELECT DP.Period_Counter
	into X_Current_PC
	FROM FA_DEPRN_PERIODS DP
	WHERE DP.Book_Type_Code = lv_corp_book
	AND DP.Period_Close_Date IS NULL;
	--
	SELECT DP.Period_Counter
	INTO X_Transfer_In_PC
	FROM FA_DEPRN_PERIODS DP, FA_TRANSACTION_HEADERS TH
	WHERE DP.Book_Type_Code = lv_corp_book
	AND TH.Book_Type_Code = lv_corp_book
	AND TH.Asset_Id = X_Asset_Id
	AND TH.Transaction_Type_Code = 'TRANSFER IN'
	AND TH.Date_Effective between
		DP.Period_Open_Date and nvl(DP.Period_Close_Date,sysdate);
	--
	if X_Transfer_In_PC < X_Current_PC then
	   -- can't update asset type, so don't bother getting
	   -- costs for further validation
	   X_Books_Cost := 0;
	   X_Inv_Cost := 0;
	else
           select deprn_reserve into X_deprn_reserve
           from fa_deprn_summary
           where asset_id = X_Asset_id
           and book_type_code = lv_corp_book
           and deprn_source_code = 'BOOKS';

	   select cost into X_Books_Cost
	   from fa_books
	   where asset_id = X_Asset_Id
	   and book_type_code = lv_corp_book
	   and date_ineffective is null;
	   --
	   begin
	      select nvl(sum(fixed_assets_cost),0)
	      into X_Inv_Cost
	      from fa_asset_invoices ai
	      where asset_id = X_Asset_Id;
	   exception
	      when no_data_found then X_Inv_Cost := 0;
	   end;
	end if;
  EXCEPTION
	WHEN Others THEN
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_DET_ADD_PKG.INITIALIZE',
			Calling_Fn => X_Calling_Fn
	,	p_log_level_rec => p_log_level_rec);
  END Initialize;
  --
  FUNCTION  Val_Reclass(X_Old_Cat_Id		NUMBER,
			X_New_Cat_Id		NUMBER,
			X_Asset_Id		NUMBER,
			X_Asset_Type		VARCHAR2,
			X_Old_Cap_Flag		VARCHAR2,
			X_Old_Cat_Type		VARCHAR2,
			X_New_Cat_Type		IN OUT NOCOPY VARCHAR2,
			X_Lease_Id		NUMBER,
			X_Calling_Fn		VARCHAR2,
              p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS
  lv_corp_book		varchar2(30);
  lv_new_cap_flag	varchar2(3);
  lv_count		number := 0;
  lv_mesg		varchar2(50);
  h_status		boolean := false;
  validation_error	exception;
  BEGIN
  -- find corporate book
  select bc.book_type_code into lv_corp_book
  from fa_books bk, fa_book_controls bc
  where bc.book_class = 'CORPORATE'
  and bk.asset_id = X_Asset_Id
  and bk.book_type_code = bc.book_type_code
  and bk.date_ineffective is null;

  -- validate new category
  if (X_Calling_Fn = 'FA_ASSET_VAL.Validate_Reclass') then
  -- called from form.  don't use stacked mesg.
      h_status := FA_FIN_ADD_PKG.CAT_VAL
			(X_Book_Type_Code => lv_corp_book,
			X_Asset_Type => X_Asset_Type,
			X_Category_Id => X_New_Cat_Id,
			X_Stack_Mesg => 'NO',
			X_Calling_Fn => 'FA_DET_ADD_PKG.Val_Reclass'
			, p_log_level_rec => p_log_level_rec);
  else
      h_status := FA_FIN_ADD_PKG.CAT_VAL
                        (X_Book_Type_Code => lv_corp_book,
                        X_Asset_Type => X_Asset_Type,
                        X_Category_Id => X_New_Cat_Id,
                        X_Stack_Mesg => 'YES',
                        X_Calling_Fn => 'FA_DET_ADD_PKG.Val_Reclass'
                        , p_log_level_rec => p_log_level_rec);
  end if;

  if (not h_status and x_calling_fn <> 'FA_ASSET_VAL.Validate_Reclass') then
  -- if not invoked from form, then add error message to stack.
      raise validation_error;
  end if;

  -- both categories must be capitalized or expensed types
  --
  select capitalize_flag, category_type
  into lv_new_cap_flag, X_New_Cat_Type
  from fa_categories
  where category_id = X_New_Cat_Id;
  --
  if X_Old_Cap_Flag = 'YES' then
     if lv_new_cap_flag = 'NO' then
	lv_mesg := 'FA_ADD_RECLS_TO_EXPENSE';
 	raise validation_error;
     end if;
  elsif X_Old_Cap_Flag = 'NO' then
     if lv_new_cap_flag = 'YES' then
	lv_mesg := 'FA_ADD_RECLS_TO_CAP_ASSET';
 	raise validation_error;
     end if;
  end if;
  -- also check lease stuff
  -- for bug 3057767, added X_Asset_Id to join since it seems that you
  -- ony need to remove the lease for this asset and not all assets that
  -- have this lease when the asset is being reclassed.
  if X_Old_Cat_Type = 'LEASE' and X_New_Cat_Type <> 'LEASE' then
     select count(*) into lv_count
     from   fa_additions_b ad
     where  ad.asset_id = X_Asset_Id
     and    ad.lease_id = X_Lease_Id
     and exists
     ( select 'X'
       from fa_categories_b cat
       where  cat.category_id = ad.asset_category_id
       and    cat.category_type = 'LEASEHOLD IMPROVEMENT');
     --
     if lv_count > 0 then
	lv_mesg := 'FA_ADD_DELETE_LHOLD_BEFORE_RCL';
	raise validation_error;
     end if;
     --
     -- syoung: performance tuning: count(*) to count(1).
     -- and inserted rownum condition.
     select count(1) into lv_count
     from fa_leases
     where lease_id = X_Lease_Id
     and rownum < 2;
     --
     if lv_count > 0 then
	lv_mesg := 'FA_ADD_DELETE_LEASE_BEFORE_RCL';
	raise validation_error;
     end if;
  end if;
  --
  --  no pending retirements
  -- syoung: performance tuning: count(*) to count(1).
  -- and inserted rownum condition.
  -- syoung: do the following check if called from single reclass only.

  /*******************************************************+
   | Bug 1544755.					  |
   | Added a join to fa_book_controls to insure that we   |
   | don't include disabled books.			  |
   +*******************************************************/

  if (X_Calling_Fn = 'FA_ASSET_VAL.Validate_Reclass') then
  	select count(1)
  	into lv_count
  	from fa_retirements fr,
	fa_book_controls fbc
  	where fr.book_type_code = fbc.book_type_code
	and fbc.date_ineffective is null
	and fr.asset_id = X_Asset_Id
  	and fr.status in ('PENDING', 'REINSTATE', 'PARTIAL')
	and rownum < 2;
  	--
  	if lv_count > 0 then
     	    lv_mesg := 'FA_RET_PENDING_RETIREMENTS';
     	    raise validation_error;
  	end if;
  end if;

  return (true);
  --
  EXCEPTION
	WHEN Validation_Error THEN
	    if (X_calling_fn = 'FA_ASSET_VAL.Validate_Reclass') then
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_DET_ADD_PKG.VAL_RECLASS',
			Calling_Fn => X_Calling_Fn,
			Name => LV_Mesg
			, p_log_level_rec => p_log_level_rec);
	    else
		FA_SRVR_MSG.Add_Message
			(Calling_Fn => 'FA_DET_ADD_PKG.VAL_RECLASS',
			 Name => lv_mesg
			 , p_log_level_rec => p_log_level_rec);
	    end if;
	    return (false);
	WHEN Others THEN
	    if (X_calling_fn = 'FA_ASSET_VAL.Validate_Reclass') then
		FA_STANDARD_PKG.RAISE_ERROR
			(Called_Fn => 'FA_DET_ADD_PKG.VAL_RECLASS',
			Calling_Fn => X_Calling_Fn
			, p_log_level_rec => p_log_level_rec);
	    else
		FA_SRVR_MSG.Add_SQL_Error
			(Calling_Fn => 'FA_DET_ADD_PKG.VAL_RECLASS'
						, p_log_level_rec => p_log_level_rec);
	    end if;
            return (false);
  END Val_Reclass;

PROCEDURE UPDATE_LEASE_DF(X_Lease_Id                       NUMBER,
                       X_Last_Update_Date               DATE,
                       X_Last_Updated_By                NUMBER,
                       X_Last_Update_Login              NUMBER,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2,
                       X_Attribute_Category_Code        VARCHAR2,
                       X_Return_Status                  OUT NOCOPY BOOLEAN,
                       X_Calling_Fn                     VARCHAR2,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type)
IS

  cursor LS_CUR is
        select ls.rowid row_id,
                lease_id,
                lease_number,
                lessor_id,
                description,
                last_update_date,
                last_updated_by,
                created_by,
                creation_date,
                last_update_login,
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
                attribute15,
                attribute_category_code,
                fasb_lease_type,
                cost_capitalized,
                transfer_ownership,
                bargain_purchase_option,
                payment_schedule_id,
                fair_value,
                present_value,
                lease_type,
                asset_life,
                lease_term,
                currency_code
        from fa_leases ls
        where ls.lease_id = X_Lease_Id;
  LS_ROW        LS_CUR%ROWTYPE;
  h_status      boolean := false;
  update_error  exception;
BEGIN

  if X_Lease_Id is not null then
        OPEN LS_CUR;
        FETCH LS_CUR INTO LS_ROW;

                FA_LEASES_PKG.UPDATE_ROW(
                   X_Rowid            => LS_ROW.Row_id,
                   X_Lease_Id         => LS_ROW.Lease_Id,
                   X_Lease_Number     => LS_ROW.Lease_Number,
                   X_Lessor_Id        => LS_ROW.Lessor_Id,
                   X_Description      => LS_ROW.Description,
                   X_Last_Update_Date => X_Last_Update_Date,
                   X_Last_Updated_By  => X_Last_Updated_By,
                   X_Last_Update_Login=> X_Last_Update_Login,
                   X_Attribute1       => X_Attribute1,
                   X_Attribute2       => X_Attribute2,
                   X_Attribute3       => X_Attribute3,
                   X_Attribute4       => X_Attribute4,
                   X_Attribute5       => X_Attribute5,
                   X_Attribute6       => X_Attribute6,
                   X_Attribute7       => X_Attribute7,
                   X_Attribute8       => X_Attribute8,
                   X_Attribute9       => X_Attribute9,
                   X_Attribute10      => X_Attribute10,
                   X_Attribute11      => X_Attribute11,
                   X_Attribute12      => X_Attribute12,
                   X_Attribute13      => X_Attribute13,
                   X_Attribute14      => X_Attribute14,
                   X_Attribute15      => X_Attribute15,
                   X_Attribute_Category_Code =>
                        X_Attribute_Category_Code,
                   X_Return_Status => h_status,
                   X_Calling_Fn       => 'FA_DET_ADD2_PKG.UPDATE_LEASE_DF'
                   , p_log_level_rec => p_log_level_rec);

        if not h_status then
            raise update_error;
        end if;

  end if;
  X_Return_Status := true;
exception
    when update_error then
      FA_SRVR_MSG.Add_Message(
                CALLING_FN => 'FA_DET_ADD2_PKG.Update_Lease_DF'
                , p_log_level_rec => p_log_level_rec);
      X_Return_Status := false;
    when others then
      FA_SRVR_MSG.Add_SQL_Error(
                CALLING_FN => 'FA_DET_ADD2_PKG.Update_Lease_DF'
                ,p_log_level_rec => p_log_level_rec);
      X_Return_Status := false;
END Update_Lease_DF;

END FA_DET_ADD_PKG;

/
