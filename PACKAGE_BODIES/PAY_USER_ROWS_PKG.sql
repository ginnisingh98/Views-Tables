--------------------------------------------------------
--  DDL for Package Body PAY_USER_ROWS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_USER_ROWS_PKG" AS
/* $Header: pyusr01t.pkb 120.1 2005/07/29 05:09:07 shisriva noship $ */

--
g_dummy	number(1);	-- Dummy for cursor returns which are not needed
g_user_table_id number(9); -- For validating translation;
g_business_group_id number(15); -- For validating translation;
g_legislation_code varchar2(150); -- For validating translation;
--
--
-- Overloaded check_unique procedure to accept p_validation_start_date and
-- p_validation_end_date to check the uniquness of row_low_range_or_name
-- only in validation range.Bug No 3734910.
--
procedure check_unique ( p_rowid                 in varchar2,
                         p_user_table_id         in number,
                         p_user_row_id           in number,
                         p_row_low_range_or_name in varchar2,
                         p_business_group_id     in number ,
			 p_validation_start_date in date ,
			 p_validation_end_date   in date) is

cursor c1 is
  select '1'
  from   pay_user_rows_f  usr
  where  usr.user_table_id                = p_user_table_id
  and    upper(usr.row_low_range_or_name) = upper(p_row_low_range_or_name)
  and    ( p_rowid is null
	  or ( p_rowid is not null and usr.user_row_id <> p_user_row_id ) )
  and    ((usr.effective_start_date between p_validation_start_date and p_validation_end_date)
           or (usr.effective_end_date between p_validation_start_date and p_validation_end_date)
	   or (usr.effective_start_date < p_validation_start_date and usr.effective_end_date > p_validation_end_date))
  and    ( usr.business_group_id is null
          or ( usr.business_group_id = p_business_group_id ) );
 l_dummy varchar2(255) ;
begin
--

     open c1 ;
     fetch c1 into l_dummy ;
     if  c1%found
     then close c1 ;
          fnd_message.set_name( 'PAY' , 'PAY_7884_USER_TABLE_UNIQUE' ) ;
          fnd_message.raise_error ;
     end if ;
     close c1 ;
end  check_unique;



procedure check_unique ( p_rowid                 in varchar2,
                         p_user_table_id         in number,
                         p_user_row_id           in number,
                         p_row_low_range_or_name in varchar2,
                         p_business_group_id     in number ) is
--
--  JBARKER, bug #2608226
--  changed following cursor to reference table instead of view pay_user_rows
--  to remove date comparison
--
cursor c1 is
  select '1'
  from   pay_user_rows_f  usr
  where  usr.user_table_id                = p_user_table_id
  and    upper(usr.row_low_range_or_name) = upper(p_row_low_range_or_name)
  and    ( p_rowid is null
	  or ( p_rowid is not null and usr.user_row_id <> p_user_row_id ) )
  and    ( usr.business_group_id is null
          or ( usr.business_group_id = p_business_group_id ) );
 l_dummy varchar2(255) ;
begin
--

     open c1 ;
     fetch c1 into l_dummy ;
     if  c1%found
     then close c1 ;
          fnd_message.set_name( 'PAY' , 'PAY_7884_USER_TABLE_UNIQUE' ) ;
          fnd_message.raise_error ;
     end if ;
     close c1 ;
end  check_unique;
--

--
-- Overloaded check_overlap procedure to accept p_validation_start_date and
-- p_validation_end_date to check for overlapping ranges which lie in the
-- validation range.Bug No 3734910.
--

procedure check_overlap (p_rowid                 in varchar2,
                         p_user_table_id         in number,
                         p_user_row_id           in number,
                         p_row_low_range_or_name in varchar2,
                         p_row_high_range        in varchar2,
                         p_business_group_id     in number,
			 p_validation_start_date in date,
			 p_validation_end_date   in date) is
--
cursor csr_row_overlap is
  select '1'
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))
  and    ((usr.effective_start_date between p_validation_start_date and p_validation_end_date)
           or (usr.effective_end_date between p_validation_start_date and p_validation_end_date)
	   or (usr.effective_start_date < p_validation_start_date and usr.effective_end_date > p_validation_end_date))
  and    (p_rowid is null
  or     (p_rowid is not null
  and    usr.user_row_id <> p_user_row_id))
  and    (fnd_number.canonical_to_number(p_row_low_range_or_name) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range)
  or     (fnd_number.canonical_to_number(p_row_high_range) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range))
  or     (fnd_number.canonical_to_number(usr.row_low_range_or_name) > fnd_number.canonical_to_number(p_row_low_range_or_name)
     and fnd_number.canonical_to_number(usr.row_high_range) < fnd_number.canonical_to_number(p_row_high_range))
  );
--
l_dummy varchar2(1);
--
begin
--
/*  Procedure is only called for Range comparisons which must be Numbers */
  open  csr_row_overlap;
  fetch csr_row_overlap into l_dummy;
  if csr_row_overlap%found then
    close csr_row_overlap;
    fnd_message.set_name('PER','PER_34003_USER_ROW_OVERLAP');
    fnd_message.raise_error;
  end if;
  close csr_row_overlap;

end check_overlap;
--



procedure check_overlap (p_rowid                 in varchar2,
                         p_user_table_id         in number,
                         p_user_row_id           in number,
                         p_row_low_range_or_name in varchar2,
                         p_row_high_range        in varchar2,
                         p_business_group_id     in number) is
--
cursor csr_row_overlap is
  select '1'
  from   pay_user_rows usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))
  and    (p_rowid is null
  or     (p_rowid is not null
  and    usr.user_row_id <> p_user_row_id))
  and    (fnd_number.canonical_to_number(p_row_low_range_or_name) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range)
  or     (fnd_number.canonical_to_number(p_row_high_range) between
          fnd_number.canonical_to_number(usr.row_low_range_or_name) and fnd_number.canonical_to_number(usr.row_high_range)));
--
l_dummy varchar2(1);
--
begin
--
/*  Procedure is only called for Range comparisons which must be Numbers */
  open  csr_row_overlap;
  fetch csr_row_overlap into l_dummy;
  if csr_row_overlap%found then
    close csr_row_overlap;
    fnd_message.set_name('PER','PER_34003_USER_ROW_OVERLAP');
    fnd_message.raise_error;
  end if;
  close csr_row_overlap;

end check_overlap;
--
function range_end_date (p_user_table_id         in number,
                         p_effective_start_date  in date,
                         p_row_low_range_or_name in varchar2,
                         p_row_high_range        in varchar2,
                         p_business_group_id     in number)return date is
--
cursor csr_new_end_date is
  select (min(usr.effective_start_date)-1)
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))
  and    usr.effective_start_date > p_effective_start_date
  and    ((upper(lpad(p_row_low_range_or_name,80,'0')) between
         upper(lpad(usr.row_low_range_or_name,80,'0')) and upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')))
  or     (upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0')) between
         upper(lpad(usr.row_low_range_or_name,80,'0')) and upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')))
  or     (upper(lpad(usr.row_low_range_or_name,80,'0')) between
         upper(lpad(p_row_low_range_or_name,80,'0')) and upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0')))
  or     (upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')) between
         upper(lpad(p_row_low_range_or_name,80,'0')) and upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0'))));
--
l_eed date;
--
begin
--
  open  csr_new_end_date;
  fetch csr_new_end_date into l_eed;
  if l_eed is null then
    l_eed := hr_api.g_eot;
  end if;
  close csr_new_end_date;
--
return(l_eed);
--
end range_end_date;
--
function match_end_date(p_user_table_id         in number,
                        p_effective_start_date  in date,
                        p_row_low_range_or_name in varchar2,
                        p_business_group_id     in number) return date is
--
cursor csr_new_match_end is
  select (min(usr.effective_start_date)-1)
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))
  and    usr.effective_start_date > p_effective_start_date
  and    upper(usr.row_low_range_or_name) = upper(p_row_low_range_or_name);
--
l_eed date;
--
begin
--
  open  csr_new_match_end;
  fetch csr_new_match_end into l_eed;
  if l_eed is null then
    l_eed := hr_api.g_eot;
  end if;
  close csr_new_match_end;
--
return(l_eed);
--
end match_end_date;



--
-- Overloaded future_ranges_exist procedure to accept p_validation_start_date and
-- p_validation_end_date to check for future ranges only in validation range.
-- Also accepted user_row_id parameter to distinguish other records from future
-- updates of the row for which this function is called.
-- Bug No 3734910.
--

function future_ranges_exist (p_user_table_id         in number,
                              p_effective_start_date  in date,
                              p_row_low_range_or_name in varchar2,
                              p_row_high_range        in varchar2,
                              p_business_group_id     in number,
			      p_user_row_id           in number,
			      p_validation_start_date in date,
			      p_validation_end_date   in date)return boolean is
--
cursor csr_rows_exist is
  select '1'
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))

  and    (usr.effective_start_date between p_validation_start_date and p_validation_end_date)
  and    usr.user_row_id <> p_user_row_id
  and    ((upper(lpad(p_row_low_range_or_name,80,'0')) between
         upper(lpad(usr.row_low_range_or_name,80,'0')) and upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')))
  or     (upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0')) between
         upper(lpad(usr.row_low_range_or_name,80,'0')) and upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')))
  or     (upper(lpad(usr.row_low_range_or_name,80,'0')) between
         upper(lpad(p_row_low_range_or_name,80,'0')) and upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0')))
  or     (upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')) between
         upper(lpad(p_row_low_range_or_name,80,'0')) and upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0'))));
--
l_dummy  varchar2(1);
l_exists boolean;
--
begin
--
  open  csr_rows_exist;
  fetch csr_rows_exist into l_dummy;
  l_exists := csr_rows_exist%found;
  close csr_rows_exist;
--
return(l_exists);
--
end future_ranges_exist;






--
function future_ranges_exist (p_user_table_id         in number,
                              p_effective_start_date  in date,
                              p_row_low_range_or_name in varchar2,
                              p_row_high_range        in varchar2,
                              p_business_group_id     in number)return boolean is
--
cursor csr_rows_exist is
  select '1'
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))
  and    usr.effective_start_date > p_effective_start_date
  and    ((upper(lpad(p_row_low_range_or_name,80,'0')) between
         upper(lpad(usr.row_low_range_or_name,80,'0')) and upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')))
  or     (upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0')) between
         upper(lpad(usr.row_low_range_or_name,80,'0')) and upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')))
  or     (upper(lpad(usr.row_low_range_or_name,80,'0')) between
         upper(lpad(p_row_low_range_or_name,80,'0')) and upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0')))
  or     (upper(lpad(nvl(usr.row_high_range,usr.row_low_range_or_name),80,'0')) between
         upper(lpad(p_row_low_range_or_name,80,'0')) and upper(lpad(nvl(p_row_high_range,p_row_low_range_or_name),80,'0'))));
--
l_dummy  varchar2(1);
l_exists boolean;
--
begin
--
  open  csr_rows_exist;
  fetch csr_rows_exist into l_dummy;
  l_exists := csr_rows_exist%found;
  close csr_rows_exist;
--
return(l_exists);
--
end future_ranges_exist;


--
function future_matches_exist(p_user_table_id         in number,
                              p_effective_start_date  in date,
                              p_row_low_range_or_name in varchar2,
			      p_business_group_id     in number) return boolean is
--
cursor csr_matches_exist is
  select '1'
  from   pay_user_rows_f usr
  where  usr.user_table_id = p_user_table_id
  and    (usr.business_group_id is null
  or     (usr.business_group_id = p_business_group_id))
  and    usr.effective_start_date > p_effective_start_date
  and    upper(usr.row_low_range_or_name) = upper(p_row_low_range_or_name);
--
l_dummy  varchar2(1);
l_exists boolean;
--
begin
--
  open  csr_matches_exist;
  fetch csr_matches_exist into l_dummy;
  l_exists := csr_matches_exist%found;
  close csr_matches_exist;
--
return(l_exists);
--
end future_matches_exist;




--
procedure get_seq ( p_user_row_id in out NOCOPY number ) is
  cursor c1 is
      select pay_user_rows_s.nextval
      from   dual  ;
begin
--
   open c1 ;
   fetch c1 into p_user_row_id ;
   close c1 ;
--
end get_seq ;
--
procedure pre_insert ( p_rowid                 in 		varchar2,
                       p_user_table_id         in 		number,
                       p_row_low_range_or_name in 		varchar2,
		       p_user_row_id           in out 	NOCOPY 	number,
                       p_business_group_id     in 		number,
		       p_ghr_installed	       in 		varchar2 default 'N') is
begin
--
  if ( p_ghr_installed = 'N' ) then
  --
  --  if GHR product component not installed then
  --  check value is unique
  --
    check_unique( p_rowid                 => p_rowid,
		  p_user_table_id         => p_user_table_id,
		  p_user_row_id           => p_user_row_id,
		  p_row_low_range_or_name => p_row_low_range_or_name,
                  p_business_group_id     => p_business_group_id ) ;
  end if;
--
   get_seq( p_user_row_id => p_user_row_id ) ;
--
end pre_insert ;
--
--  Checks whether the given delete is allowed.
procedure check_delete_row ( p_user_row_id           in number,
			     p_validation_start_date in date,
			     p_dt_delete_mode        in varchar2 ) is
--
--  Check for DATE EFFECTIVE DELETE
--  Check there are no column instances which end
--  after the validation start date
--
procedure check_dt_delete_row ( p_user_row_id           in number ,
	                        p_validation_start_date in date ) is
cursor c1 is
   select null
   from   pay_user_column_instances_f
   where  user_row_id         = p_user_row_id
   and    effective_end_date >= p_validation_start_date  ;
l_dummy varchar2(1) ;
begin
   open c1 ;
   fetch c1 into l_dummy ;
   if c1%found then
       close c1 ;
       fnd_message.set_name( 'PAY', 'PAY_6982_USERTAB_END_VALUES' ) ;
       fnd_message.raise_error ;
   end if ;
   close c1 ;
end check_dt_delete_row ;
--
--  Check for ZAP DELETE.
--  Check there are no column instances
--
procedure check_dt_zap_row ( p_user_row_id in number )  is
cursor c1 is
   select null
   from   pay_user_column_instances_f
   where  user_row_id = p_user_row_id ;
l_dummy varchar2(1) ;
begin
   open c1 ;
   fetch c1 into l_dummy ;
   if c1%found then
       close c1 ;
       fnd_message.set_name( 'PAY', 'HR_6980_USERTAB_VALUES_FIRST' ) ;
       fnd_message.set_token( 'ROWCOL' , 'row' ) ;
       fnd_message.raise_error ;
   end if ;
   close c1 ;
end check_dt_zap_row ;
--
-- MAIN PROCEDURE
--
begin
--
  if p_dt_delete_mode = 'ZAP' then
       check_dt_zap_row ( p_user_row_id ) ;
  elsif p_dt_delete_mode = 'DELETE' then
       check_dt_delete_row( p_user_row_id , p_validation_start_date ) ;
  else
       app_exception.invalid_argument('pay_user_rows_pkg.check_delete_row',
				      'p_dt_delete_mode',
				       p_dt_delete_mode ) ;
  end if ;
--
end check_delete_row ;
--
--For MLS-----------------------------------------------------------------------
procedure ADD_LANGUAGE
is
begin
  delete from PAY_USER_ROWS_F_TL T
  where not exists
    (select NULL
     from PAY_USER_ROWS_F B
     where B.USER_ROW_ID = T.USER_ROW_ID
    );
  update PAY_USER_ROWS_F_TL T
  set (ROW_LOW_RANGE_OR_NAME) =
  (select B.ROW_LOW_RANGE_OR_NAME
   from PAY_USER_ROWS_F_TL B
   where B.USER_ROW_ID = T.USER_ROW_ID
   and B.LANGUAGE = T.SOURCE_LANG)
  where (T.USER_ROW_ID,T.LANGUAGE) in
  (select SUBT.USER_ROW_ID,SUBT.LANGUAGE
    from PAY_USER_ROWS_F_TL SUBB, PAY_USER_ROWS_F_TL SUBT
    where SUBB.USER_ROW_ID = SUBT.USER_ROW_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.ROW_LOW_RANGE_OR_NAME <> SUBT.ROW_LOW_RANGE_OR_NAME
  ));
 insert into PAY_USER_ROWS_F_TL (
    USER_ROW_ID,
    ROW_LOW_RANGE_OR_NAME,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.USER_ROW_ID,
    B.ROW_LOW_RANGE_OR_NAME,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PAY_USER_ROWS_F_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PAY_USER_ROWS_F_TL T
    where T.USER_ROW_ID = B.USER_ROW_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;
--
procedure TRANSLATE_ROW (
   X_B_ROW_LOW_RANGE_OR_NAME in VARCHAR2,
   X_B_LEGISLATION_CODE in VARCHAR2,
   X_ROW_LOW_RANGE_OR_NAME in VARCHAR2,
   X_OWNER in VARCHAR2
) is
begin
  UPDATE PAY_USER_ROWS_F_TL
    SET ROW_LOW_RANGE_OR_NAME = nvl(X_ROW_LOW_RANGE_OR_NAME,ROW_LOW_RANGE_OR_NAME),
        last_update_date = SYSDATE,
        last_updated_by = decode(x_owner,'SEED',1,0),
        last_update_login = 0,
        source_lang = userenv('LANG')
  WHERE userenv('LANG') IN (language,source_lang)
    AND USER_ROW_ID in
        (select USER_ROW_ID
           from PAY_USER_ROWS_F
          where nvl(ROW_LOW_RANGE_OR_NAME,'~null~')=nvl(X_B_ROW_LOW_RANGE_OR_NAME,'~null~')
            and nvl(LEGISLATION_CODE,'~null~') = nvl(X_B_LEGISLATION_CODE,'~null~')
            and BUSINESS_GROUP_ID is NULL);
  if (sql%notfound) then
  null;
  end if;
end TRANSLATE_ROW;
--
--
PROCEDURE set_translation_globals(p_business_group_id IN NUMBER,
                		  p_legislation_code IN VARCHAR2,
                                  p_user_table_id IN NUMBER) IS
BEGIN
   g_business_group_id := p_business_group_id;
   g_legislation_code := p_legislation_code;
   g_user_table_id := p_user_table_id;
END;
--
procedure validate_translation(user_row_id	NUMBER,
			       language		VARCHAR2,
			       row_low_range_or_name	VARCHAR2,
			       p_business_group_id IN NUMBER DEFAULT NULL,
			       p_legislation_code IN VARCHAR2 DEFAULT NULL) IS
/*

This procedure fails if a user_row translation is already present in
the table for a given language.  Otherwise, no action is performed.  It is
used to ensure uniqueness of translated user_row names.

*/

--
-- This cursor implements the validation we require,
-- and expects that the various package globals are set before
-- the call to this procedure is made.  This is done from the
-- user-named trigger 'TRANSLATIONS' in the form
--
cursor c_translation(p_language IN VARCHAR2,
                     p_row_low_range_or_name IN VARCHAR2,
                     p_user_row_id IN NUMBER,
                     p_user_table_id IN NUMBER,
                     p_bus_grp_id IN NUMBER,
		     p_leg_code IN varchar2)  IS
       select '1'
	from   pay_user_rows_f pur,
	       pay_user_rows_f_tl urt
	where  upper(urt.row_low_range_or_name) = upper(p_row_low_range_or_name)
	AND   pur.user_row_id = urt.user_row_id
	AND   (urt.user_row_id <> p_user_row_id OR p_user_row_id IS NULL)
	AND   pur.user_table_id   = p_user_table_id
        AND   urt.language = p_language
	AND   (nvl(pur.business_group_id,-1) = nvl(p_bus_grp_id,-1) OR p_bus_grp_id IS NULL)
	AND   (nvl(pur.LEGISLATION_CODE,'~null~') = nvl(p_leg_code,'~null~') OR p_leg_code IS NULL);

       l_package_name VARCHAR2(80);
       l_business_group_id NUMBER;
       l_legislation_code VARCHAR2(150);


BEGIN
   l_package_name  := 'PAY_user_rowS_PKG.VALIDATE_TRANSLATION';
   l_business_group_id := p_business_group_id;
   l_legislation_code  := p_legislation_code;
   hr_utility.set_location (l_package_name,10);
   OPEN c_translation(language, row_low_range_or_name,user_row_id,g_user_table_id,
		     l_business_group_id,l_legislation_code);
      	hr_utility.set_location (l_package_name,50);
       FETCH c_translation INTO g_dummy;

       IF c_translation%NOTFOUND THEN
      	hr_utility.set_location (l_package_name,60);
	  CLOSE c_translation;
       ELSE
      	hr_utility.set_location (l_package_name,70);
	  CLOSE c_translation;
	  fnd_message.set_name('PAY','HR_TRANSLATION_EXISTS');
	  fnd_message.raise_error;
       END IF;
      	hr_utility.set_location ('Leaving:'||l_package_name,80);
END validate_translation;
--
--

--------------------------------------------------------------------------
--
END PAY_USER_ROWS_PKG;

/
