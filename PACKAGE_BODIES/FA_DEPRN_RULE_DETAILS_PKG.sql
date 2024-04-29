--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_RULE_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_RULE_DETAILS_PKG" as
/* $Header: faxtdrdb.pls 120.7.12010000.2 2009/07/19 13:07:39 glchen ship $ */

  PROCEDURE Insert_Row(
			p_deprn_rule_detail_id		IN OUT NOCOPY NUMBER,
			p_deprn_basis_rule_id		IN OUT NOCOPY NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL,
			p_last_update_date		DATE,
			p_last_updated_by		NUMBER,
			p_created_by			NUMBER,
			p_creation_date			DATE,
			p_last_update_login		NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
   CURSOR C is SELECT FA_DEPRN_RULE_DETAILS_S.nextval from sys.dual;

   CURSOR C_RULE is
    select deprn_basis_rule_id
    from   FA_DEPRN_BASIS_RULES
    where  rule_name = p_rule_name;

   CURSOR C_MAX_SEQ
   is
     select nvl(max(deprn_rule_detail_id),0)+1
     from   FA_DEPRN_RULE_DETAILS;

  Begin

    if (p_deprn_rule_detail_id is null) then
      if p_created_by=1 then
        OPEN C_MAX_SEQ;
        FETCH C_MAX_SEQ INTO p_deprn_rule_detail_id;
	CLOSE C_MAX_SEQ;
      else
        OPEN C;
        FETCH C INTO p_deprn_rule_detail_id;
        CLOSE C;
      end if;
    end if;

    if (p_deprn_basis_rule_id is null) then
      OPEN C_RULE;
      FETCH C_RULE INTO p_deprn_basis_rule_id;
      CLOSE C_RULE;
    end if;

    Insert into fa_deprn_rule_details (
        deprn_rule_detail_id,
	deprn_basis_rule_id,
	rule_name,
        rate_source_rule,
        deprn_basis_rule,
        asset_type,
        period_update_flag,
        subtract_ytd_flag,
        allow_reduction_rate_flag,
        use_eofy_reserve_flag,
        use_rsv_after_imp_flag,
	last_update_date,
	last_updated_by,
	created_by,
	creation_date,
	last_update_login
	)
    values (
        p_deprn_rule_detail_id,
	p_deprn_basis_rule_id,
	p_rule_name,
        p_rate_source_rule,
        p_deprn_basis_rule,
        p_asset_type,
        p_period_update_flag,
        p_subtract_ytd_flag,
        p_allow_reduction_rate_flag,
        p_use_eofy_reserve_flag,
        p_use_rsv_after_imp_flag,
	p_last_update_date,
	p_last_updated_by,
	p_created_by,
	p_creation_date,
	p_last_update_login
	);

  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_rule_details_pkg.insert_row',  p_log_level_rec => p_log_level_rec);

  END Insert_Row;

  PROCEDURE Lock_Row (
			p_deprn_rule_detail_id		NUMBER,
			p_deprn_basis_rule_id		NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL,
			p_last_update_date		DATE,
			p_last_updated_by		NUMBER,
			p_last_update_login		NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
   CURSOR C IS
	Select
                deprn_rule_detail_id,
        	deprn_basis_rule_id,
        	rule_name,
                rate_source_rule,
                deprn_basis_rule,
                asset_type,
                period_update_flag,
                subtract_ytd_flag,
                allow_reduction_rate_flag,
                use_eofy_reserve_flag,
                use_rsv_after_imp_flag,
        	last_update_date,
        	last_updated_by,
        	last_update_login
	from 	FA_DEPRN_RULE_DETAILS
	Where 	rule_name = p_rule_name
        and     rate_source_rule = p_rate_source_rule
        and     deprn_basis_rule = p_deprn_basis_rule
	for update of deprn_basis_rule_id nowait;

	Recinfo C%ROWTYPE;

  BEGIN

    OPEN C;
    FETCH C INTO Recinfo;

    if (C%NOTFOUND) then
	CLOSE C;
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
        APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;

    if (
		(Recinfo.deprn_rule_detail_id = p_deprn_rule_detail_id)
	AND	(Recinfo.deprn_basis_rule_id = p_deprn_basis_rule_id)
	AND	(Recinfo.rule_name = p_rule_name)
	AND	(Recinfo.rate_source_rule = p_rate_source_rule)
	AND	(Recinfo.deprn_basis_rule = p_deprn_basis_rule)
	AND	(Recinfo.asset_type = p_asset_type)
        AND     (Recinfo.period_update_flag = p_period_update_flag)
        AND     (Recinfo.subtract_ytd_flag = p_subtract_ytd_flag)
        AND     (Recinfo.allow_reduction_rate_flag
                                    = p_allow_reduction_rate_flag)
        AND     (Recinfo.use_eofy_reserve_flag = p_use_eofy_reserve_flag)
        AND     (Recinfo.use_rsv_after_imp_flag = p_use_rsv_after_imp_flag)
	) then
	return;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row(
			p_deprn_rule_detail_id		NUMBER,
			p_deprn_basis_rule_id		NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL,
			p_last_update_date		DATE,
			p_last_updated_by		NUMBER,
			p_last_update_login		NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    UPDATE FA_DEPRN_RULE_DETAILS
    SET
        asset_type                =       p_asset_type,
        period_update_flag        =       p_period_update_flag,
        subtract_ytd_flag         =       p_subtract_ytd_flag,
        allow_reduction_rate_flag =       p_allow_reduction_rate_flag,
        use_eofy_reserve_flag     =       p_use_eofy_reserve_flag,
        use_rsv_after_imp_flag    =       nvl(use_rsv_after_imp_flag, p_use_rsv_after_imp_flag),
	last_update_date	  =	  p_last_update_date,
	last_updated_by		  =	  p_last_updated_by,
	last_update_login	  =	  p_last_update_login
    WHERE deprn_rule_detail_id    =       p_deprn_rule_detail_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_rule_details_pkg.update_row',  p_log_level_rec => p_log_level_rec);

  END Update_Row;

  PROCEDURE Delete_Row(p_deprn_rule_detail_id 	NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
  BEGIN

    DELETE FROM fa_deprn_rule_details
    WHERE deprn_rule_detail_id = p_deprn_rule_detail_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_rule_details_pkg.delete_row',  p_log_level_rec => p_log_level_rec);

  END DELETE_ROW;

  PROCEDURE LOAD_ROW (
			p_deprn_rule_detail_id		NUMBER,
			p_owner				VARCHAR2,
			p_deprn_basis_rule_id		NUMBER,
			p_rule_name			VARCHAR2,
			p_rate_source_rule		VARCHAR2,
			p_deprn_basis_rule		VARCHAR2,
                        p_asset_type                    VARCHAR2,
                        p_period_update_flag            VARCHAR2,
                        p_subtract_ytd_flag             VARCHAR2,
                        p_allow_reduction_rate_flag     VARCHAR2,
                        p_use_eofy_reserve_flag         VARCHAR2,
                        p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  h_record_exists		number(15);
  h_deprn_basis_rule_id		number(15);
  h_deprn_rule_detail_id        number(15);
  user_id			number(15);

  begin

    if (p_owner = 'SEED') then
	user_id :=1;
    else
	user_id := 0;
    end if;

    select count(*)
    into   h_record_exists
    from   fa_deprn_rule_details
    where  rule_name = p_rule_name
    and    rate_source_rule = p_rate_source_rule
    and    deprn_basis_rule = p_deprn_basis_rule;


    if (h_record_exists >0) then
     fa_deprn_rule_details_pkg.update_row (
        p_deprn_rule_detail_id          => p_deprn_rule_detail_id,
        p_deprn_basis_rule_id           => p_deprn_basis_rule_id,
	p_rule_name			=> p_rule_name,
	p_rate_source_rule		=> p_rate_source_rule,
	p_deprn_basis_rule		=> p_deprn_basis_rule,
        p_asset_type                    => p_asset_type,
        p_period_update_flag            => p_period_update_flag,
        p_subtract_ytd_flag             => p_subtract_ytd_flag,
        p_allow_reduction_rate_flag     => p_allow_reduction_rate_flag,
        p_use_eofy_reserve_flag         => p_use_eofy_reserve_flag,
        p_use_rsv_after_imp_flag        => p_use_rsv_after_imp_flag,
        p_last_update_date		=> sysdate,
	p_last_updated_by		=> user_id,
	p_last_update_login		=> 0
     , p_log_level_rec => p_log_level_rec);

   else

     h_deprn_rule_detail_id := p_deprn_rule_detail_id;
     h_deprn_basis_rule_id  := p_deprn_basis_rule_id;

     fa_deprn_rule_details_pkg.insert_row (
	p_deprn_rule_detail_id		=> h_deprn_rule_detail_id,
	p_deprn_basis_rule_id		=> h_deprn_basis_rule_id,
	p_rule_name			=> p_rule_name,
	p_rate_source_rule		=> p_rate_source_rule,
	p_deprn_basis_rule		=> p_deprn_basis_rule,
        p_asset_type                    => p_asset_type,
        p_period_update_flag            => p_period_update_flag,
        p_subtract_ytd_flag             => p_subtract_ytd_flag,
        p_allow_reduction_rate_flag     => p_allow_reduction_rate_flag,
        p_use_eofy_reserve_flag         => p_use_eofy_reserve_flag,
        p_use_rsv_after_imp_flag        => p_use_rsv_after_imp_flag,
	p_last_update_date		=> sysdate,
	p_last_updated_by		=> user_id,
	p_created_by			=> user_id,
	p_creation_date			=> sysdate,
	p_last_update_login		=> 0
     , p_log_level_rec => p_log_level_rec);
   end if;

  exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_rule_details_pkg.load_row',  p_log_level_rec => p_log_level_rec);

  end LOAD_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
 PROCEDURE LOAD_ROW (
             p_custom_mode               IN VARCHAR2,
             p_deprn_rule_detail_id      IN NUMBER,
             p_owner                     IN VARCHAR2,
             p_last_update_date          IN DATE,
             p_deprn_basis_rule_id       IN NUMBER,
             p_rule_name                 IN VARCHAR2,
             p_rate_source_rule          IN VARCHAR2,
             p_deprn_basis_rule          IN VARCHAR2,
             p_asset_type                IN VARCHAR2,
             p_period_update_flag        IN VARCHAR2,
             p_subtract_ytd_flag         IN VARCHAR2,
             p_allow_reduction_rate_flag IN VARCHAR2,
             p_use_eofy_reserve_flag     IN VARCHAR2,
	     p_use_rsv_after_imp_flag    IN VARCHAR2 DEFAULT NULL,
             p_log_level_rec             IN FA_API_TYPES.log_level_rec_type
                                            default null ) IS



  h_record_exists		number(15);
  h_deprn_basis_rule_id		number(15);
  h_deprn_rule_detail_id        number(15);
  user_id			number(15);

  db_last_updated_by   number;
  db_last_update_date  date;

BEGIN

    user_id := fnd_load_util.owner_id (p_Owner);

    select count(*)
    into   h_record_exists
    from   fa_deprn_rule_details
    where  rule_name = p_rule_name
    and    rate_source_rule = p_rate_source_rule
    and    deprn_basis_rule = p_deprn_basis_rule;

    if (h_record_exists > 0) then

       select last_updated_by, last_update_date
       into   db_last_updated_by, db_last_update_date
       from   fa_deprn_rule_details
       where  rule_name = p_rule_name
       and    rate_source_rule = p_rate_source_rule
       and    deprn_basis_rule = p_deprn_basis_rule;

       if (fnd_load_util.upload_test(user_id, p_last_update_date,
                                     db_last_updated_by, db_last_update_date,
                                     P_CUSTOM_MODE)) then

          fa_deprn_rule_details_pkg.update_row (
             p_deprn_rule_detail_id          => p_deprn_rule_detail_id,
             p_deprn_basis_rule_id           => p_deprn_basis_rule_id,
	     p_rule_name		     => p_rule_name,
	     p_rate_source_rule		     => p_rate_source_rule,
	     p_deprn_basis_rule		     => p_deprn_basis_rule,
             p_asset_type                    => p_asset_type,
             p_period_update_flag            => p_period_update_flag,
             p_subtract_ytd_flag             => p_subtract_ytd_flag,
             p_allow_reduction_rate_flag     => p_allow_reduction_rate_flag,
             p_use_eofy_reserve_flag         => p_use_eofy_reserve_flag,
	     p_use_rsv_after_imp_flag        => p_use_rsv_after_imp_flag,
             p_last_update_date		     => sysdate,
	     p_last_updated_by               => user_id,
	     p_last_update_login             => 0,
             p_log_level_rec => p_log_level_rec);

       end if;
    else

       h_deprn_rule_detail_id := p_deprn_rule_detail_id;
       h_deprn_basis_rule_id  := p_deprn_basis_rule_id;

       fa_deprn_rule_details_pkg.insert_row (
	            p_deprn_rule_detail_id      => h_deprn_rule_detail_id,
	            p_deprn_basis_rule_id	=> h_deprn_basis_rule_id,
	            p_rule_name			=> p_rule_name,
	            p_rate_source_rule		=> p_rate_source_rule,
	            p_deprn_basis_rule		=> p_deprn_basis_rule,
                    p_asset_type                => p_asset_type,
                    p_period_update_flag        => p_period_update_flag,
                    p_subtract_ytd_flag         => p_subtract_ytd_flag,
                    p_allow_reduction_rate_flag => p_allow_reduction_rate_flag,
                    p_use_eofy_reserve_flag     => p_use_eofy_reserve_flag,
		    p_use_rsv_after_imp_flag    => p_use_rsv_after_imp_flag,
	            p_last_update_date		=> sysdate,
	            p_last_updated_by		=> user_id,
	            p_created_by		=> user_id,
	            p_creation_date		=> sysdate,
	            p_last_update_login		=> 0,
                    p_log_level_rec => p_log_level_rec);
    end if;

EXCEPTION
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_rule_details_pkg.load_row'
                ,p_log_level_rec => p_log_level_rec);

END LOAD_ROW;

/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/

PROCEDURE LOAD_SEED_ROW (
               p_upload_mode                IN VARCHAR2,
               p_custom_mode                IN VARCHAR2,
               p_deprn_rule_detail_id       IN NUMBER,
               p_owner                      IN VARCHAR2,
               p_last_update_date           IN DATE,
               p_deprn_basis_rule_id        IN NUMBER,
               p_rule_name                  IN VARCHAR2,
               p_rate_source_rule           IN VARCHAR2,
               p_deprn_basis_rule           IN VARCHAR2,
               p_asset_type                 IN VARCHAR2,
               p_period_update_flag         IN VARCHAR2,
               p_subtract_ytd_flag          IN VARCHAR2,
               p_allow_reduction_rate_flag  IN VARCHAR2,
               p_use_eofy_reserve_flag      IN VARCHAR2,
	       p_use_rsv_after_imp_flag        VARCHAR2 DEFAULT NULL) IS

  BEGIN

        if (p_upload_mode = 'NLS') then
           null;
        else
          FA_DEPRN_RULE_DETAILS_PKG.LOAD_ROW (
               p_custom_mode                => p_custom_mode,
               p_deprn_rule_detail_id       => p_deprn_rule_detail_id,
               p_owner                      => p_owner,
               p_last_update_date           => p_last_update_date,
               p_deprn_basis_rule_id        => p_deprn_basis_rule_id,
               p_rule_name                  => p_rule_name,
               p_rate_source_rule           => p_rate_source_rule,
               p_deprn_basis_rule           => p_deprn_basis_rule,
               p_asset_type                 => p_asset_type,
               p_period_update_flag         => p_period_update_flag,
               p_subtract_ytd_flag          => p_subtract_ytd_flag,
               p_allow_reduction_rate_flag  => p_allow_reduction_rate_flag,
               p_use_eofy_reserve_flag      => p_use_eofy_reserve_flag,
	       p_use_rsv_after_imp_flag     => p_use_rsv_after_imp_flag);

        end if;

END LOAD_SEED_ROW;

END FA_DEPRN_RULE_DETAILS_PKG;

/
