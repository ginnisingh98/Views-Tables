--------------------------------------------------------
--  DDL for Package Body PER_TIME_PERIOD_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_TIME_PERIOD_TYPES_PKG" as
/* $Header: pydpt01t.pkb 120.0.12010000.1 2008/07/27 22:27:58 appldev ship $ */

g_debug boolean := hr_utility.debug_enabled;

procedure PERIOD_TYPE_NOT_UNIQUE (
--
-- Returns TRUE if the period type name is not unique, then the check is for a
-- new record within generic data
-- Parameters are:
--
p_period_type  in      varchar2 ,
p_row_id in varchar2 ) is
--
v_not_unique    boolean := FALSE;
g_dummy_number  number;
l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.period_type_not_unique';

--
cursor csr_duplicate is
		select  null
                from per_time_period_types ptpt
		where upper(p_period_type) = upper(ptpt.period_type)
		and    (p_row_id is null
			      or     (p_row_id is not null
					      and    chartorowid(p_row_id) <> ptpt.rowid));
begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

--
  open csr_duplicate;
  fetch csr_duplicate into g_dummy_number;
  v_not_unique := csr_duplicate%found;
  close csr_duplicate;
--
if v_not_unique then
    hr_utility.set_message (801,'HR_7663_DEF_TIME_PERIOD_EXISTS');
    hr_utility.raise_error;
end if;
--

if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
end if;

end period_type_not_unique;

--

procedure check_delete_period_type (
p_period_type in varchar2,
p_number_per_fiscal_year in number) is
--
g_dummy_number    number;
v_no_delete       boolean := FALSE;
l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.delete_period_type';

--
cursor csr_calendar is
	   select null
	   from pay_calendars
	   where upper(p_period_type) = upper(actual_period_type);
cursor csr_periods is
	   select null
	   from per_time_periods
	   where upper(p_period_type) = upper(period_type);
cursor csr_cobra is
	   select null
	   from per_cobra_cov_enrollments
	   where upper(p_period_type) = upper(period_type);
cursor csr_year is
	   select null
	   from per_time_period_types
	   where number_per_fiscal_year = p_number_per_fiscal_year
	   and exists
	      (select null
	       from per_time_period_types
	       where number_per_fiscal_year = p_number_per_fiscal_year
	       and number_per_fiscal_year = 1
	       having count(*) = 1);
cursor csr_quarter is
	   select null
	   from per_time_period_types
	   where number_per_fiscal_year = p_number_per_fiscal_year
	   and exists
	      (select null
	       from per_time_period_types
	       where number_per_fiscal_year = p_number_per_fiscal_year
	       and number_per_fiscal_year = 4
	       having count(*) = 1);
--
--
-- Check there are no dependencies of the period type record
-- in the PAY_CALENDARS, PER_TIME_PERIOD_SETS, PER_COBRA_COV_ENROLLMENTS tables
-- and there is at least one record with fiscal year of 1 and 4
--
begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

  open csr_calendar;
  fetch csr_calendar into g_dummy_number;
  v_no_delete := csr_calendar%found;
  close csr_calendar;
--
if  v_no_delete then
    hr_utility.set_message (801,'HR_7660_DEF_DELETE_PERIODS');
    hr_utility.raise_error;
end if;
--
  open csr_periods;
  fetch csr_periods into g_dummy_number;
  v_no_delete := csr_periods%found;
  close csr_periods;
--
if  v_no_delete then
    hr_utility.set_message (801,'HR_6058_TIME_DELETE_PERIOD');
    hr_utility.raise_error;
end if;
--
  open csr_cobra;
  fetch csr_cobra into g_dummy_number;
  v_no_delete := csr_cobra%found;
  close csr_cobra;
--
if  v_no_delete then
    hr_utility.set_message (801,'HR_6974_TIME_DELETE_COBRA');
    hr_utility.raise_error;
end if;
--
  open csr_year;
  fetch csr_year into g_dummy_number;
  v_no_delete := csr_year%found;
  close csr_year;
--
if  v_no_delete then
    hr_utility.set_message (801,'HR_7662_DEF_DELETE_YEAR_OR_QTR');
    fnd_message.set_token('PERIOD_TYPE','Year');
    hr_utility.raise_error;
end if;
--
  open csr_quarter;
  fetch csr_quarter into g_dummy_number;
  v_no_delete := csr_quarter%found;
  close csr_quarter;
--
if  v_no_delete then
    hr_utility.set_message (801,'HR_7662_DEF_DELETE_YEAR_OR_QTR');
    fnd_message.set_token('PERIOD_TYPE','Quarter');
    hr_utility.raise_error;
end if;
--

if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
end if;

end check_delete_period_type;
--

-- Returns TRUE if the display period type is not unique for a particular language.

procedure DISPLAY_PERIOD_TYPE_NOT_UNIQUE (
		x_period_type in varchar2,
		x_display_period_type  in varchar2,
		x_language in varchar2 ) is
--
v_not_unique    boolean := FALSE;
g_dummy_number  number;
l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.display_period_type_not_unique';

--
cursor csr_duplicate is
      SELECT  1
	 FROM  per_time_period_types_tl ptptl
	 WHERE upper(ptptl.display_period_type) = upper(x_display_period_type)
	 AND   ptptl.language = x_language
	 AND   ( x_period_type is null or ( x_period_type is not null
						and ptptl.period_type <> x_period_type ) );
begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

--
  open csr_duplicate;
  fetch csr_duplicate into g_dummy_number;
  v_not_unique := csr_duplicate%found;
  close csr_duplicate;
--
if v_not_unique then
    hr_utility.set_message (801,'HR_7663_DEF_TIME_PERIOD_EXISTS');
    hr_utility.raise_error;
end if;
--

  if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;

end display_period_type_not_unique;

procedure INSERT_ROW (
  X_ROWID in out nocopy VARCHAR2,
  X_PERIOD_TYPE in VARCHAR2,
  X_NUMBER_PER_FISCAL_YEAR in NUMBER,
  X_YEAR_TYPE_IN_NAME in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAY_PERIOD_TYPE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_CREATION_DATE in DATE,
  X_CREATED_BY in NUMBER,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is
  cursor C is select ROWID from PER_TIME_PERIOD_TYPES
    where PERIOD_TYPE = X_PERIOD_TYPE;

  l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.insert_row';

begin

  if g_debug then
     hr_utility.set_location( 'Entering : ' || l_proc , 1);
  end if;


  display_period_type_not_unique( X_PERIOD_TYPE,
				  X_DISPLAY_PERIOD_TYPE,
   			          userenv('LANG') );

  insert into PER_TIME_PERIOD_TYPES (
    PERIOD_TYPE,
    NUMBER_PER_FISCAL_YEAR,
    YEAR_TYPE_IN_NAME,
    SYSTEM_FLAG,
    DESCRIPTION,
    DISPLAY_PERIOD_TYPE,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1,
    ATTRIBUTE2,
    ATTRIBUTE3,
    ATTRIBUTE4,
    ATTRIBUTE5,
    ATTRIBUTE6,
    ATTRIBUTE7,
    ATTRIBUTE8,
    ATTRIBUTE9,
    ATTRIBUTE10,
    ATTRIBUTE11,
    ATTRIBUTE12,
    ATTRIBUTE13,
    ATTRIBUTE14,
    ATTRIBUTE15,
    ATTRIBUTE16,
    ATTRIBUTE17,
    ATTRIBUTE18,
    ATTRIBUTE19,
    ATTRIBUTE20,
    REQUEST_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_ID,
    PROGRAM_UPDATE_DATE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    X_PERIOD_TYPE,
    X_NUMBER_PER_FISCAL_YEAR,
    X_YEAR_TYPE_IN_NAME,
    X_SYSTEM_FLAG,
    X_DESCRIPTION,
    X_DISPLAY_PERIOD_TYPE,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
    X_REQUEST_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_ID,
    X_PROGRAM_UPDATE_DATE,
    X_CREATION_DATE,
    X_CREATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  insert into PER_TIME_PERIOD_TYPES_TL (
    PERIOD_TYPE,
    DISPLAY_PERIOD_TYPE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    X_PERIOD_TYPE,
    X_DISPLAY_PERIOD_TYPE,
    X_DESCRIPTION,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_CREATED_BY,
    X_CREATION_DATE,
    L.LANGUAGE_CODE,
    userenv('LANG')
  from FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and not exists
    (select NULL
    from PER_TIME_PERIOD_TYPES_TL T
    where T.PERIOD_TYPE = X_PERIOD_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;

End INSERT_ROW;

procedure LOCK_ROW (
  X_PERIOD_TYPE in VARCHAR2,
  X_NUMBER_PER_FISCAL_YEAR in NUMBER,
  X_YEAR_TYPE_IN_NAME in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DISPLAY_PERIOD_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER
) is
  cursor c is select
      ATTRIBUTE20,
      NUMBER_PER_FISCAL_YEAR,
      YEAR_TYPE_IN_NAME,
      SYSTEM_FLAG,
      REQUEST_ID,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19
    from PER_TIME_PERIOD_TYPES
    where PERIOD_TYPE = X_PERIOD_TYPE
    for update of PERIOD_TYPE nowait;
  recinfo c%rowtype;

  cursor c1 is select
      DISPLAY_PERIOD_TYPE,
      DESCRIPTION,
      decode(LANGUAGE, userenv('LANG'), 'Y', 'N') BASELANG
    from PER_TIME_PERIOD_TYPES_TL
    where PERIOD_TYPE = X_PERIOD_TYPE
    and userenv('LANG') in (LANGUAGE, SOURCE_LANG)
    for update of PERIOD_TYPE nowait;

    l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.lock_row';

begin

 if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
 end if;

  open c;
  fetch c into recinfo;
  if (c%notfound) then
    close c;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
  end if;
  close c;
  if (    ((recinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
           OR ((recinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))
      AND (recinfo.NUMBER_PER_FISCAL_YEAR = X_NUMBER_PER_FISCAL_YEAR)
      AND (recinfo.YEAR_TYPE_IN_NAME = X_YEAR_TYPE_IN_NAME)
      AND ((recinfo.SYSTEM_FLAG = X_SYSTEM_FLAG)
           OR ((recinfo.SYSTEM_FLAG is null) AND (X_SYSTEM_FLAG is null)))
      AND ((recinfo.REQUEST_ID = X_REQUEST_ID)
           OR ((recinfo.REQUEST_ID is null) AND (X_REQUEST_ID is null)))
      AND ((recinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
           OR ((recinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
      AND ((recinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
           OR ((recinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
      AND ((recinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
           OR ((recinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
      AND ((recinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
           OR ((recinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
      AND ((recinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
           OR ((recinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
      AND ((recinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
           OR ((recinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
      AND ((recinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
           OR ((recinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
      AND ((recinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
           OR ((recinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
      AND ((recinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
           OR ((recinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
      AND ((recinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
           OR ((recinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
      AND ((recinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
           OR ((recinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
      AND ((recinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
           OR ((recinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
      AND ((recinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
           OR ((recinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
      AND ((recinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
           OR ((recinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
      AND ((recinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
           OR ((recinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
      AND ((recinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
           OR ((recinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
      AND ((recinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
           OR ((recinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
      AND ((recinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
           OR ((recinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
      AND ((recinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
           OR ((recinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
      AND ((recinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
           OR ((recinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;

  for tlinfo in c1 loop
    if (tlinfo.BASELANG = 'Y') then
      if (    (tlinfo.DISPLAY_PERIOD_TYPE = X_DISPLAY_PERIOD_TYPE)
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  return;

if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
end if;

end LOCK_ROW;

procedure UPDATE_ROW (
  X_PERIOD_TYPE in VARCHAR2,
  X_NUMBER_PER_FISCAL_YEAR in NUMBER,
  X_YEAR_TYPE_IN_NAME in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAY_PERIOD_TYPE in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_REQUEST_ID in NUMBER,
  X_PROGRAM_APPLICATION_ID in NUMBER,
  X_PROGRAM_ID in NUMBER,
  X_PROGRAM_UPDATE_DATE in DATE,
  X_LAST_UPDATE_DATE in DATE,
  X_LAST_UPDATED_BY in NUMBER,
  X_LAST_UPDATE_LOGIN in NUMBER
) is

cursor chk_source_lang is
  select 1
    from per_time_period_types_tl
    where period_type = x_period_type
    and source_lang <> userenv('LANG');

l_exists number;

l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.update_row';

begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;


  display_period_type_not_unique( X_PERIOD_TYPE,
				  X_DISPLAY_PERIOD_TYPE,
				  userenv('LANG') );

  update PER_TIME_PERIOD_TYPES set
    NUMBER_PER_FISCAL_YEAR = X_NUMBER_PER_FISCAL_YEAR,
    YEAR_TYPE_IN_NAME = X_YEAR_TYPE_IN_NAME,
    SYSTEM_FLAG = X_SYSTEM_FLAG,
    ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = X_ATTRIBUTE1,
    ATTRIBUTE2 = X_ATTRIBUTE2,
    ATTRIBUTE3 = X_ATTRIBUTE3,
    ATTRIBUTE4 = X_ATTRIBUTE4,
    ATTRIBUTE5 = X_ATTRIBUTE5,
    ATTRIBUTE6 = X_ATTRIBUTE6,
    ATTRIBUTE7 = X_ATTRIBUTE7,
    ATTRIBUTE8 = X_ATTRIBUTE8,
    ATTRIBUTE9 = X_ATTRIBUTE9,
    ATTRIBUTE10 = X_ATTRIBUTE10,
    ATTRIBUTE11 = X_ATTRIBUTE11,
    ATTRIBUTE12 = X_ATTRIBUTE12,
    ATTRIBUTE13 = X_ATTRIBUTE13,
    ATTRIBUTE14 = X_ATTRIBUTE14,
    ATTRIBUTE15 = X_ATTRIBUTE15,
    ATTRIBUTE16 = X_ATTRIBUTE16,
    ATTRIBUTE17 = X_ATTRIBUTE17,
    ATTRIBUTE18 = X_ATTRIBUTE18,
    ATTRIBUTE19 = X_ATTRIBUTE19,
    ATTRIBUTE20 = X_ATTRIBUTE20,
    REQUEST_ID  = X_REQUEST_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where PERIOD_TYPE = X_PERIOD_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  open chk_source_lang;
	  fetch chk_source_lang into l_exists;
  close chk_source_lang;
  --
  if l_exists is null then
	update PER_TIME_PERIOD_TYPES set
	    DISPLAY_PERIOD_TYPE = X_DISPLAY_PERIOD_TYPE,
	    DESCRIPTION = X_DESCRIPTION
	where  PERIOD_TYPE = X_PERIOD_TYPE;
  end if;

  update PER_TIME_PERIOD_TYPES_TL set
    DISPLAY_PERIOD_TYPE = X_DISPLAY_PERIOD_TYPE,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where PERIOD_TYPE = X_PERIOD_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  if (sql%notfound) then
	insert into PER_TIME_PERIOD_TYPES_TL (
	    PERIOD_TYPE,
	    DISPLAY_PERIOD_TYPE,
	    DESCRIPTION,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    CREATED_BY,
	    CREATION_DATE,
	    LANGUAGE,
	    SOURCE_LANG
	  ) select
	    X_PERIOD_TYPE,
	    X_DISPLAY_PERIOD_TYPE,
	    X_DESCRIPTION,
	    X_LAST_UPDATE_DATE,
	    X_LAST_UPDATED_BY,
	    X_LAST_UPDATE_LOGIN,
	    X_LAST_UPDATED_BY,
	    X_LAST_UPDATE_DATE,
	    L.LANGUAGE_CODE,
	    userenv('LANG')
	  from FND_LANGUAGES L
	  where L.INSTALLED_FLAG in ('I', 'B')
	  and not exists
	    (select NULL
	    from PER_TIME_PERIOD_TYPES_TL T
	    where T.PERIOD_TYPE = X_PERIOD_TYPE
	    and T.LANGUAGE = L.LANGUAGE_CODE);
  end if;

  if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;


end UPDATE_ROW;

procedure DELETE_ROW (
  X_PERIOD_TYPE in VARCHAR2
) is

l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.delete_row';

begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

  delete from PER_TIME_PERIOD_TYPES_TL
  where PERIOD_TYPE = X_PERIOD_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  delete from PER_TIME_PERIOD_TYPES
  where PERIOD_TYPE = X_PERIOD_TYPE;

  if (sql%notfound) then
    raise no_data_found;
  end if;

if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
end if;

end DELETE_ROW;

procedure ADD_LANGUAGE
is
l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.add_language';
begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

  delete from PER_TIME_PERIOD_TYPES_TL T
  where not exists
    (select NULL
    from PER_TIME_PERIOD_TYPES B
    where B.PERIOD_TYPE = T.PERIOD_TYPE
    );

  update PER_TIME_PERIOD_TYPES_TL T set (
      DISPLAY_PERIOD_TYPE,
      DESCRIPTION
    ) = (select
      B.DISPLAY_PERIOD_TYPE,
      B.DESCRIPTION
    from PER_TIME_PERIOD_TYPES_TL B
    where B.PERIOD_TYPE = T.PERIOD_TYPE
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.PERIOD_TYPE,
      T.LANGUAGE
  ) in (select
      SUBT.PERIOD_TYPE,
      SUBT.LANGUAGE
    from PER_TIME_PERIOD_TYPES_TL SUBB, PER_TIME_PERIOD_TYPES_TL SUBT
    where SUBB.PERIOD_TYPE = SUBT.PERIOD_TYPE
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.DISPLAY_PERIOD_TYPE <> SUBT.DISPLAY_PERIOD_TYPE
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));

  insert into PER_TIME_PERIOD_TYPES_TL (
    PERIOD_TYPE,
    DISPLAY_PERIOD_TYPE,
    DESCRIPTION,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    CREATED_BY,
    CREATION_DATE,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.PERIOD_TYPE,
    B.DISPLAY_PERIOD_TYPE,
    B.DESCRIPTION,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.CREATED_BY,
    B.CREATION_DATE,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from PER_TIME_PERIOD_TYPES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from PER_TIME_PERIOD_TYPES_TL T
    where T.PERIOD_TYPE = B.PERIOD_TYPE
    and T.LANGUAGE = L.LANGUAGE_CODE);

  if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;

end ADD_LANGUAGE;

procedure OWNER_TO_WHO (
  X_OWNER in VARCHAR2,
  X_CREATION_DATE out nocopy DATE,
  X_CREATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_DATE out nocopy DATE,
  X_LAST_UPDATED_BY out nocopy NUMBER,
  X_LAST_UPDATE_LOGIN out nocopy NUMBER
) is

l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.owner_to_who';

begin

  if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
  end if;

  if X_OWNER = 'SEED' then
    hr_general2.init_fndload
       (p_resp_appl_id => 801
	,p_user_id      => 1);
  else
    hr_general2.init_fndload
       (p_resp_appl_id => 801
        ,p_user_id     => 0 );
  end if;

  X_CREATED_BY := fnd_global.user_id;
  X_CREATION_DATE := sysdate;
  X_LAST_UPDATE_DATE := sysdate;
  X_LAST_UPDATED_BY   := fnd_global.user_id;
  X_LAST_UPDATE_LOGIN := fnd_global.login_id;

  if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;

end OWNER_TO_WHO;


procedure LOAD_ROW (
  X_PERIOD_TYPE in VARCHAR2,
  X_NUMBER_PER_FISCAL_YEAR in NUMBER,
  X_YEAR_TYPE_IN_NAME in VARCHAR2,
  X_SYSTEM_FLAG in VARCHAR2,
  X_ATTRIBUTE_CATEGORY in VARCHAR2,
  X_ATTRIBUTE1 in VARCHAR2,
  X_ATTRIBUTE2 in VARCHAR2,
  X_ATTRIBUTE3 in VARCHAR2,
  X_ATTRIBUTE4 in VARCHAR2,
  X_ATTRIBUTE5 in VARCHAR2,
  X_ATTRIBUTE6 in VARCHAR2,
  X_ATTRIBUTE7 in VARCHAR2,
  X_ATTRIBUTE8 in VARCHAR2,
  X_ATTRIBUTE9 in VARCHAR2,
  X_ATTRIBUTE10 in VARCHAR2,
  X_ATTRIBUTE11 in VARCHAR2,
  X_ATTRIBUTE12 in VARCHAR2,
  X_ATTRIBUTE13 in VARCHAR2,
  X_ATTRIBUTE14 in VARCHAR2,
  X_ATTRIBUTE15 in VARCHAR2,
  X_ATTRIBUTE16 in VARCHAR2,
  X_ATTRIBUTE17 in VARCHAR2,
  X_ATTRIBUTE18 in VARCHAR2,
  X_ATTRIBUTE19 in VARCHAR2,
  X_ATTRIBUTE20 in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAY_PERIOD_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  l_ROWID  varchar2(30);
  l_CREATION_DATE DATE;
  l_CREATED_BY NUMBER;
  l_LAST_UPDATE_DATE DATE;
  l_LAST_UPDATED_BY NUMBER;
  l_LAST_UPDATE_LOGIN NUMBER;

  l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.load_row';


begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

  OWNER_TO_WHO ( X_OWNER => X_OWNER,
		 X_CREATION_DATE => l_CREATION_DATE,
		 X_CREATED_BY => l_CREATED_BY,
		 X_LAST_UPDATE_DATE => l_LAST_UPDATE_DATE,
		 X_LAST_UPDATED_BY => l_LAST_UPDATED_BY,
		 X_LAST_UPDATE_LOGIN => l_LAST_UPDATE_LOGIN );

  begin
    UPDATE_ROW (
      X_PERIOD_TYPE,
      X_NUMBER_PER_FISCAL_YEAR,
      X_YEAR_TYPE_IN_NAME,
      X_SYSTEM_FLAG,
      X_DESCRIPTION,
      X_DISPLAY_PERIOD_TYPE,
      X_ATTRIBUTE_CATEGORY,
      X_ATTRIBUTE1,
      X_ATTRIBUTE2,
      X_ATTRIBUTE3,
      X_ATTRIBUTE4,
      X_ATTRIBUTE5,
      X_ATTRIBUTE6,
      X_ATTRIBUTE7,
      X_ATTRIBUTE8,
      X_ATTRIBUTE9,
      X_ATTRIBUTE10,
      X_ATTRIBUTE11,
      X_ATTRIBUTE12,
      X_ATTRIBUTE13,
      X_ATTRIBUTE14,
      X_ATTRIBUTE15,
      X_ATTRIBUTE16,
      X_ATTRIBUTE17,
      X_ATTRIBUTE18,
      X_ATTRIBUTE19,
      X_ATTRIBUTE20,
      NULL,
      NULL,
      NULL,
      NULL,
      l_LAST_UPDATE_DATE,
      l_LAST_UPDATED_BY,
      l_LAST_UPDATE_LOGIN
    );
  exception
    when no_data_found then
      INSERT_ROW (
        l_ROWID,
        X_PERIOD_TYPE,
        X_NUMBER_PER_FISCAL_YEAR,
        X_YEAR_TYPE_IN_NAME,
        X_SYSTEM_FLAG,
        X_DESCRIPTION,
        X_DISPLAY_PERIOD_TYPE,
        X_ATTRIBUTE_CATEGORY,
        X_ATTRIBUTE1,
        X_ATTRIBUTE2,
        X_ATTRIBUTE3,
        X_ATTRIBUTE4,
        X_ATTRIBUTE5,
        X_ATTRIBUTE6,
        X_ATTRIBUTE7,
        X_ATTRIBUTE8,
        X_ATTRIBUTE9,
        X_ATTRIBUTE10,
        X_ATTRIBUTE11,
        X_ATTRIBUTE12,
        X_ATTRIBUTE13,
        X_ATTRIBUTE14,
        X_ATTRIBUTE15,
        X_ATTRIBUTE16,
        X_ATTRIBUTE17,
        X_ATTRIBUTE18,
        X_ATTRIBUTE19,
        X_ATTRIBUTE20,
        NULL,
        NULL,
        NULL,
        NULL,
        l_CREATION_DATE,
        l_CREATED_BY,
        l_LAST_UPDATE_DATE,
        l_LAST_UPDATED_BY,
        l_LAST_UPDATE_LOGIN
      );
  end;

if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
end if;

end LOAD_ROW;

procedure TRANSLATE_ROW (
  X_PERIOD_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_DISPLAY_PERIOD_TYPE in VARCHAR2,
  X_OWNER in VARCHAR2
) is

  l_CREATION_DATE DATE;
  l_CREATED_BY NUMBER;
  l_LAST_UPDATE_DATE DATE;
  l_LAST_UPDATED_BY NUMBER;
  l_LAST_UPDATE_LOGIN NUMBER;

  l_exists number;

  l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.translate_row';

  cursor chk_source_lang is
  select 1
    from per_time_period_types_tl
    where period_type = x_period_type
    and source_lang <> userenv('LANG');
begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;

  display_period_type_not_unique( X_PERIOD_TYPE,
				  X_DISPLAY_PERIOD_TYPE,
   			          userenv('LANG') );

  OWNER_TO_WHO ( X_OWNER => X_OWNER,
		 X_CREATION_DATE => l_CREATION_DATE,
		 X_CREATED_BY => l_CREATED_BY,
		 X_LAST_UPDATE_DATE => l_LAST_UPDATE_DATE,
		 X_LAST_UPDATED_BY => l_LAST_UPDATED_BY,
		 X_LAST_UPDATE_LOGIN => l_LAST_UPDATE_LOGIN );

  update PER_TIME_PERIOD_TYPES_TL
  set DESCRIPTION = X_DESCRIPTION,
      DISPLAY_PERIOD_TYPE = X_DISPLAY_PERIOD_TYPE,
      LAST_UPDATE_DATE = l_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = l_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = l_LAST_UPDATE_LOGIN,
      SOURCE_LANG = userenv('LANG')
  where PERIOD_TYPE = X_PERIOD_TYPE
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

  open chk_source_lang;
	  fetch chk_source_lang into l_exists;
  close chk_source_lang;
  --

  if l_exists is null then
	update PER_TIME_PERIOD_TYPES set
	    DISPLAY_PERIOD_TYPE = X_DISPLAY_PERIOD_TYPE,
	    DESCRIPTION = X_DESCRIPTION,
            LAST_UPDATE_DATE = l_LAST_UPDATE_DATE,
            LAST_UPDATED_BY = l_LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN = l_LAST_UPDATE_LOGIN
	where  PERIOD_TYPE = X_PERIOD_TYPE;
  end if;
  if g_debug then
     hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;

end TRANSLATE_ROW;

procedure validate_translation (
	  X_PERIOD_TYPE in VARCHAR2,
	  X_LANGUAGE in VARCHAR2,
	  X_DISPLAY_PERIOD_TYPE in VARCHAR2,
	  X_DESCRIPTION in VARCHAR2 ) is

l_exists number;

cursor chk_source_lang is
  select 1
     from per_time_period_types_tl
     where period_type = x_period_type
     and source_lang <> userenv('LANG');

  l_LAST_UPDATE_DATE DATE;
  l_LAST_UPDATED_BY NUMBER;
  l_LAST_UPDATE_LOGIN NUMBER;

  l_proc CONSTANT varchar2(100) := 'per_time_period_types_pkg.validate_translation';

begin

if g_debug then
    hr_utility.set_location( 'Entering : ' || l_proc , 1);
end if;


display_period_type_not_unique(   X_PERIOD_TYPE,
		                  X_DISPLAY_PERIOD_TYPE,
   			          X_LANGUAGE );
  open chk_source_lang;
	  fetch chk_source_lang into l_exists;
  close chk_source_lang;
  --
  l_LAST_UPDATE_DATE  := sysdate;
  l_LAST_UPDATED_BY   := fnd_global.user_id;
  l_LAST_UPDATE_LOGIN := fnd_global.login_id;

  if l_exists is null and userenv('LANG') = X_LANGUAGE  then
	update PER_TIME_PERIOD_TYPES set
	    DISPLAY_PERIOD_TYPE = X_DISPLAY_PERIOD_TYPE,
	    DESCRIPTION = X_DESCRIPTION,
            LAST_UPDATE_DATE = l_LAST_UPDATE_DATE,
            LAST_UPDATED_BY = l_LAST_UPDATED_BY
	where  PERIOD_TYPE = X_PERIOD_TYPE;
  end if;

  if g_debug then
    hr_utility.set_location( 'Leaving : ' || l_proc , 2);
  end if;

end validate_translation;

END PER_TIME_PERIOD_TYPES_PKG;

/
