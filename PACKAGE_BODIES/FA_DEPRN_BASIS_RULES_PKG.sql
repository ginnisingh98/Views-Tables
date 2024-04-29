--------------------------------------------------------
--  DDL for Package Body FA_DEPRN_BASIS_RULES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_DEPRN_BASIS_RULES_PKG" as
/* $Header: faxtdbrb.pls 120.10.12010000.2 2009/07/19 13:06:41 glchen ship $ */

  PROCEDURE Insert_Row(	X_deprn_basis_rule_id		IN OUT NOCOPY NUMBER,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2,
			X_last_update_date		DATE,
			X_last_updated_by		NUMBER,
			X_created_by			NUMBER,
			X_creation_date			DATE,
			X_last_update_login		NUMBER,
			X_rate_source			VARCHAR2,
			X_calculation_basis		VARCHAR2,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
   CURSOR C is SELECT FA_DEPRN_BASIS_RULES_S.nextval from sys.dual;

   CURSOR C_MAX_SEQ
   is
     select nvl(max(deprn_basis_rule_id),0)+1
     from   FA_DEPRN_BASIS_RULES;

  Begin

    if (X_deprn_basis_rule_id is null) then
      if X_created_by=1 then
        OPEN C_MAX_SEQ;
        FETCH C_MAX_SEQ INTO X_deprn_basis_rule_id;
	CLOSE C_MAX_SEQ;
      else
	OPEN C;
	FETCH C INTO X_deprn_basis_rule_id;
	CLOSE C;
      end if;
    end if;


    Insert into fa_deprn_basis_rules (
	deprn_basis_rule_id,
	rule_name,
	user_rule_name,
	last_update_date,
	last_updated_by,
	created_by,
	creation_date,
	last_update_login,
	rate_source,
	deprn_basis,
	enabled_flag,
	program_name,
        description
	)
   values (
	X_deprn_basis_rule_id,
	X_rule_name,
	X_user_rule_name,
	X_last_update_date,
	X_last_updated_by,
	X_created_by,
	X_creation_date,
	X_last_update_login,
	X_rate_source,
	X_calculation_basis,
	X_enabled_flag,
	X_program_name,
        X_description
	);

  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.insert_row',  p_log_level_rec => p_log_level_rec);

  END Insert_Row;

  PROCEDURE Lock_Row (	X_deprn_basis_rule_id	NUMBER,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2,
			X_last_update_date		DATE,
			X_last_updated_by		NUMBER,
			X_last_update_login		NUMBER,
			X_rate_source			VARCHAR2,
			X_calculation_basis		VARCHAR2,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS
   CURSOR C IS
	Select	deprn_basis_rule_id,
		rule_name,
		user_rule_name,
		last_update_date,
		last_updated_by,
		last_update_login,
		rate_source,
		deprn_basis,
		enabled_flag,
		program_name,
                description
	from 	FA_DEPRN_BASIS_RULES
	Where 	DEPRN_BASIS_RULE_ID = x_deprn_basis_rule_id
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
		(Recinfo.deprn_basis_rule_id = X_deprn_basis_rule_id)
	AND	(Recinfo.rule_name = X_rule_name)
--	AND	(Recinfo.user_rule_name = X_user_rule_name)
--	AND	(Recinfo.rate_source = X_rate_source)
--	AND	(Recinfo.deprn_basis = X_calculation_basis)
	AND	(Recinfo.enabled_flag = X_enabled_flag)
	AND	(Nvl(Recinfo.program_name,'NULL')
	                    = Nvl(X_program_name,'NULL'))
        AND     (Recinfo.description
                            = X_description)
	) then
	return;
    else
        FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
        APP_EXCEPTION.Raise_Exception;
    end if;
  END Lock_Row;

  PROCEDURE Update_Row( X_deprn_basis_rule_id		NUMBER,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2,
			X_last_update_date		DATE,
			X_last_updated_by		NUMBER,
			X_last_update_login		NUMBER,
			X_rate_source			VARCHAR2,
			X_calculation_basis		VARCHAR2,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  BEGIN

    UPDATE FA_DEPRN_BASIS_RULES
    SET
	rule_name		=	X_rule_name,
	user_rule_name		=	X_user_rule_name,
	last_update_date	=	X_last_update_date,
	last_updated_by		=	X_last_updated_by,
	last_update_login	=	X_last_update_login,
	rate_source		=	X_rate_source,
	deprn_basis		=	X_calculation_basis,
	enabled_flag		=	X_enabled_flag,
	program_name		=	X_program_name,
        description             =       X_description
    WHERE deprn_basis_rule_id = X_deprn_basis_rule_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;
  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.update_row',  p_log_level_rec => p_log_level_rec);

  END Update_Row;

  PROCEDURE Delete_Row(X_deprn_basis_rule_id 	NUMBER
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

    h_count number;

  BEGIN
    DELETE FROM fa_deprn_basis_rules
    WHERE deprn_basis_rule_id = x_deprn_basis_rule_id;

    if (SQL%NOTFOUND) then
      Raise NO_DATA_FOUND;
    end if;

    select count(*)
    into   h_count
    from   FA_DEPRN_RULE_DETAILS
    where  deprn_basis_rule_id = x_deprn_basis_rule_id;

    if h_count >0 then
      DELETE from fa_deprn_rule_details
      WHERE deprn_basis_rule_id = x_deprn_basis_rule_id;
    end if;

  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.delete_row',  p_log_level_rec => p_log_level_rec);

  END DELETE_ROW;

  PROCEDURE LOAD_ROW (  X_deprn_basis_rule_id		NUMBER,
			X_owner				VARCHAR2,
			X_rule_name			VARCHAR2,
			X_user_rule_name		VARCHAR2,
			X_rate_source		        VARCHAR2,
			X_calculation_basis	        VARCHAR2,
			X_enabled_flag			VARCHAR2,
			X_program_name			VARCHAR2,
                        X_description                   VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) IS

  h_record_exists		number(15);
  h_deprn_basis_rule_id		number(15);
  user_id			number(15);

  begin

    h_deprn_basis_rule_id := x_deprn_basis_rule_id;

    if (x_owner = 'SEED') then
	user_id :=1;
    else
	user_id := 0;
    end if;

    select count(*)
    into   h_record_exists
    from   fa_deprn_basis_rules
    where  deprn_basis_rule_id = x_deprn_basis_rule_id;

    if (h_record_exists >0) then
     fa_deprn_basis_rules_pkg.update_row (
	X_deprn_basis_rule_id		=> h_deprn_basis_rule_id,
	X_rule_name			=> X_rule_name,
	X_user_rule_name		=> X_user_rule_name,
	X_last_update_date		=> sysdate,
	X_last_updated_by		=> user_id,
	X_last_update_login		=> 0,
	X_rate_source			=> X_rate_source,
	X_calculation_basis		=> X_calculation_basis,
	X_enabled_flag			=> X_enabled_flag,
	X_program_name			=> X_program_name,
        X_description                   => X_description
     , p_log_level_rec => p_log_level_rec);

   else

       -- Bug#2234906
       -- When Seed data is insereted, deprn_basis_rule_id on FA_DEPRN_BASIS_RULES
       -- doesn't match to deprn_basis_rule_id on FA_METHODS.

--    h_deprn_basis_rule_id := null;

     fa_deprn_basis_rules_pkg.insert_row (
	X_deprn_basis_rule_id		=> h_deprn_basis_rule_id,
	X_rule_name			=> X_rule_name,
	X_user_rule_name		=> X_user_rule_name,
	X_last_update_date		=> sysdate,
	X_last_updated_by		=> user_id,
	X_created_by			=> user_id,
	X_creation_date			=> sysdate,
	X_last_update_login             => 0,
	X_rate_source			=> X_rate_source,
	X_calculation_basis		=> X_calculation_basis,
	X_enabled_flag			=> X_enabled_flag,
	X_program_name			=> X_program_name,
        X_description                   => X_description
     , p_log_level_rec => p_log_level_rec);
   end if;

  exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.load_row',  p_log_level_rec => p_log_level_rec);

  end LOAD_ROW;
  /*Bug 8355119 overloading function for release specific signatures*/
  PROCEDURE LOAD_ROW (X_custom_mode         IN VARCHAR2,
                      X_deprn_basis_rule_id IN NUMBER,
                      X_owner               IN VARCHAR2,
                      X_last_update_date    IN DATE,
                      X_rule_name           IN VARCHAR2,
                      X_user_rule_name      IN VARCHAR2 DEFAULT NULL,
                      X_rate_source         IN VARCHAR2 DEFAULT NULL,
                      X_calculation_basis   IN VARCHAR2 DEFAULT NULL,
                      X_enabled_flag        IN VARCHAR2,
                      X_program_name        IN VARCHAR2,
                      X_description         IN VARCHAR2 DEFAULT NULL,
                      p_log_level_rec       IN FA_API_TYPES.log_level_rec_type
                                                        DEFAULT NULL) IS


  h_record_exists		number(15);
  h_deprn_basis_rule_id		number(15);
  user_id			number(15);

  db_last_updated_by   number;
  db_last_update_date  date;

  begin

    h_deprn_basis_rule_id := x_deprn_basis_rule_id;

    user_id := fnd_load_util.owner_id (X_Owner);

    select count(*)
    into   h_record_exists
    from   fa_deprn_basis_rules
    where  deprn_basis_rule_id = x_deprn_basis_rule_id;

    if (h_record_exists > 0) then

       select last_updated_by, last_update_date
       into   db_last_updated_by, db_last_update_date
       from   fa_deprn_basis_rules
       where  deprn_basis_rule_id = x_deprn_basis_rule_id;

       if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                     db_last_updated_by, db_last_update_date,
                                     X_CUSTOM_MODE)) then

          fa_deprn_basis_rules_pkg.update_row (
	             X_deprn_basis_rule_id => h_deprn_basis_rule_id,
	             X_rule_name           => X_rule_name,
	             X_user_rule_name      => X_user_rule_name,
	             X_last_update_date    => sysdate,
	             X_last_updated_by     => user_id,
	             X_last_update_login   => 0,
	             X_rate_source         => X_rate_source,
	             X_calculation_basis   => X_calculation_basis,
                     X_enabled_flag        => X_enabled_flag,
	             X_program_name        => X_program_name,
                     X_description         => X_description,
                     p_log_level_rec => p_log_level_rec);

       end if;
    else

       -- Bug#2234906
       -- When Seed data is insereted, deprn_basis_rule_id on
       -- FA_DEPRN_BASIS_RULES doesn't match to deprn_basis_rule_id on
       -- FA_METHODS.
--    h_deprn_basis_rule_id := null;

     fa_deprn_basis_rules_pkg.insert_row (
	                X_deprn_basis_rule_id  => h_deprn_basis_rule_id,
	                X_rule_name            => X_rule_name,
	                X_user_rule_name       => X_user_rule_name,
	                X_last_update_date     => sysdate,
	                X_last_updated_by      => user_id,
	                X_created_by           => user_id,
	                X_creation_date        => sysdate,
	                X_last_update_login    => 0,
	                X_rate_source          => X_rate_source,
	                X_calculation_basis    => X_calculation_basis,
	                X_enabled_flag         => X_enabled_flag,
                        X_program_name         => X_program_name,
                        X_description          => X_description,
                        p_log_level_rec => p_log_level_rec);
   end if;

  exception
   when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.load_row'
                ,p_log_level_rec => p_log_level_rec);

  end LOAD_ROW;

  procedure TRANSLATE_ROW (
		X_DEPRN_BASIS_RULE_ID in NUMBER,
		X_OWNER	in VARCHAR2,
		X_USER_RULE_NAME in VARCHAR2,
		X_RULE_NAME      in VARCHAR2,
                X_DESCRIPTION    in VARCHAR2
  , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) is

    user_id	number;

  begin

    if (X_OWner ='SEED') then
	user_id :=1;
    else
	user_id :=0;
    end if;

  update FA_DEPRN_BASIS_RULES set
	USER_RULE_NAME=nvl(X_USER_RULE_NAME, USER_RULE_NAME),
	LAST_UPDATED_BY = user_id,
	LAST_UPDATE_LOGIN =0,
        DESCRIPTION = X_DESCRIPTION
  where DEPRN_BASIS_RULE_ID = nvl(X_DEPRN_BASIS_RULE_ID,DEPRN_BASIS_RULE_ID)
  and   RULE_NAME = nvl(X_RULE_NAME,RULE_NAME)
  and 	userenv('LANG') =
	(select language_code
	 from FND_LANGUAGES
	 where installed_flag='B');

  exception
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.translate_row',  p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_deprn_basis_rules_pkg.translate_row',
                        CALLING_FN => 'upload fa_deprn_basis_rules', p_log_level_rec => p_log_level_rec);

  end TRANSLATE_ROW;
/*Bug 8355119 overloading function for release specific signatures*/
procedure TRANSLATE_ROW (
      X_CUSTOM_MODE         in VARCHAR2,
      X_DEPRN_BASIS_RULE_ID in NUMBER,
      X_OWNER               in VARCHAR2,
      X_LAST_UPDATE_DATE    in DATE,
      X_USER_RULE_NAME      in VARCHAR2 DEFAULT NULL,
      X_RULE_NAME           in VARCHAR2 DEFAULT NULL,
      X_DESCRIPTION         in VARCHAR2 DEFAULT NULL,
      p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null) IS

  user_id              number;

  db_last_updated_by   number;
  db_last_update_date  date;

BEGIN

  user_id := fnd_load_util.owner_id (X_Owner);

  select last_updated_by, last_update_date
  into   db_last_updated_by, db_last_update_date
  from   fa_deprn_basis_rules
  where  deprn_basis_rule_id = x_deprn_basis_rule_id;

  if (fnd_load_util.upload_test(user_id, x_last_update_date,
                                db_last_updated_by, db_last_update_date,
                                X_CUSTOM_MODE)) then

     update FA_DEPRN_BASIS_RULES set
            USER_RULE_NAME  =nvl(X_USER_RULE_NAME, USER_RULE_NAME),
            LAST_UPDATED_BY = user_id,
            LAST_UPDATE_LOGIN = 0,
            DESCRIPTION = X_DESCRIPTION
     where  DEPRN_BASIS_RULE_ID = nvl(X_DEPRN_BASIS_RULE_ID,DEPRN_BASIS_RULE_ID)
     and    RULE_NAME = nvl(X_RULE_NAME,RULE_NAME)
     and    userenv('LANG') =
            (select language_code
             from   FND_LANGUAGES
             where  installed_flag = 'B');

  end if;

EXCEPTION
    when others then

      fa_srvr_msg.add_sql_error(
                calling_fn => 'fa_deprn_basis_rules_pkg.translate_row'
                ,p_log_level_rec => p_log_level_rec);

       FA_STANDARD_PKG.RAISE_ERROR(
                        CALLED_FN => 'fa_deprn_basis_rules_pkg.translate_row',
                        CALLING_FN => 'upload fa_deprn_basis_rules'
                        ,p_log_level_rec => p_log_level_rec);

END TRANSLATE_ROW;
/*bug 8355119 adding R12 specific funtion LOAD_SEED_ROW*/
procedure LOAD_SEED_ROW (
                X_upload_mode                   IN VARCHAR2,
                X_custom_mode                   IN VARCHAR2,
                X_deprn_basis_rule_id           IN NUMBER,
                X_owner                         IN VARCHAR2,
                X_last_update_date              IN DATE,
                X_rule_name                     IN VARCHAR2,
                X_user_rule_name                IN VARCHAR2,
                X_description                   IN VARCHAR2,
                X_enabled_flag                  IN VARCHAR2,
                X_program_name                  IN VARCHAR2) IS


BEGIN

        if (X_upload_mode = 'NLS') then
           fa_deprn_basis_rules_pkg.TRANSLATE_ROW (
                X_custom_mode           => X_custom_mode,
                X_deprn_basis_rule_id   => X_deprn_basis_rule_id,
                X_owner                 => X_owner,
                X_last_update_date      => X_last_update_date,
                X_user_rule_name        => X_user_rule_name,
                X_description           => X_description);
        else
           fa_deprn_basis_rules_pkg.LOAD_ROW (
                X_custom_mode                   => X_custom_mode,
                X_deprn_basis_rule_id           => X_deprn_basis_rule_id,
                X_owner                         => X_owner,
                X_last_update_date              => X_last_update_date,
                X_rule_name                     => X_rule_name,
                X_user_rule_name                => X_user_rule_name,
                X_description                   => X_description,
                X_enabled_flag                  => X_enabled_flag,
                X_program_name                  => X_program_name);
        end if;

END LOAD_SEED_ROW;

END FA_DEPRN_BASIS_RULES_PKG;

/
