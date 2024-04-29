--------------------------------------------------------
--  DDL for Package Body GL_PERIOD_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_PERIOD_TYPES_PKG" AS
/* $Header: gliprptb.pls 120.9 2005/05/05 01:18:12 kvora ship $ */

--
-- PRIVATE FUNCTIONS
--

  --
  -- Procedure
  --   select_row
  -- Purpose
  --   Used to select a particular period type row
  -- History
  --   11-02-93  D. J. Ogg    Created
  -- Arguments
  --   recinfo			Various information about the row
  -- Example
  --   gl_period_types_pkg.select_row(recinfo)
  -- Notes
  --
  PROCEDURE select_row( recinfo		IN OUT NOCOPY gl_period_types%ROWTYPE) IS
  BEGIN
    SELECT *
    INTO recinfo
    FROM gl_period_types
    WHERE period_type = recinfo.period_type;
  END SELECT_ROW;


--
-- PUBLIC FUNCTIONS
--

  PROCEDURE select_columns(
			x_period_type			IN OUT NOCOPY VARCHAR2,
  			x_user_period_type		IN OUT NOCOPY VARCHAR2,
			x_year_type_in_name	 	IN OUT NOCOPY VARCHAR2,
			x_number_per_fiscal_year	IN OUT NOCOPY NUMBER) IS

    recinfo gl_period_types%ROWTYPE;

  BEGIN
    recinfo.period_type := x_period_type;

    select_row(recinfo);

    x_user_period_type := recinfo.user_period_type;
    x_year_type_in_name := recinfo.year_type_in_name;
    x_number_per_fiscal_year := recinfo.number_per_fiscal_year;
  END select_columns;

  PROCEDURE Check_Unique_User_Type(x_user_period_type VARCHAR2,
                                              x_rowid VARCHAR2) IS
  CURSOR check_dups is
    SELECT  1
      FROM  GL_PERIOD_TYPES pt
     WHERE  pt.user_period_type =
                check_unique_user_type.x_user_period_type
       AND  ( x_rowid is NULL
             OR pt.rowid <> x_rowid );

  dummy  NUMBER;

  BEGIN
    OPEN check_dups;
    FETCH check_dups INTO dummy;

    IF check_dups%FOUND THEN
       CLOSE  check_dups;
       fnd_message.set_name('SQLGL', 'GL_DUP_USER_PERIOD_TYPE');
       app_exception.raise_exception;
    END IF;

    CLOSE check_dups;
  EXCEPTION
    WHEN app_exception.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Check_Unique_User_Type');
      RAISE;
  END Check_Unique_User_Type;

  PROCEDURE Check_Unique_Type(x_period_type VARCHAR2,
                                    x_rowid VARCHAR2) IS
  CURSOR chk_dups is
    SELECT  1
      FROM  GL_PERIOD_TYPES pt
     WHERE  pt.period_type =
                check_unique_type.x_period_type
       AND  ( x_rowid is NULL
             OR pt.rowid <> x_rowid );

  t_var  NUMBER;

  BEGIN
    OPEN chk_dups;
    FETCH chk_dups INTO t_var;

    IF chk_dups%FOUND THEN
       CLOSE  chk_dups;
       fnd_message.set_name('SQLGL', 'GL_DUP_UNIQUE_ID');
       fnd_message.set_token('TAB_S', 'GL_PERIOD_TYPES_S');
       app_exception.raise_exception;
    END IF;

    CLOSE chk_dups;
  EXCEPTION
    WHEN app_exception.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Check_Unique_Type');
      RAISE;
  END Check_Unique_Type;

  PROCEDURE Get_New_Id(x_period_type IN OUT NOCOPY VARCHAR2) IS

  BEGIN
    select GL_PERIOD_TYPES_S.NEXTVAL
    into   x_period_type
    from   dual;

    IF (x_period_type is NULL) THEN
      fnd_message.set_name('SQLGL', 'GL_SEQUENCE_NOT_FOUND');
      fnd_message.set_token('TAB_S', 'GL_PERIOD_TYPES_S');
      app_exception.raise_exception;
    END IF;
  EXCEPTION
    WHEN app_exception.application_exception THEN RAISE;
    WHEN OTHERS THEN
      fnd_message.set_name('SQLGL','Unhandled Exception');
      fnd_message.set_token('PROCEDURE', 'Get_New_Id');
      RAISE;
  END Get_New_Id;


  PROCEDURE TRANSLATE_ROW(
                 x_period_type          in varchar2,
                 x_user_period_type     in varchar2,
                 x_description          in varchar2,
                 x_owner                in varchar2,
                 x_force_edits          in varchar2 ) as

  user_id number := 0;

Begin

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

     /* Update only if force_edits is 'Y' or it is seed data */
     if ((x_force_edits = 'Y') OR (x_owner = 'SEED')) then
       update gl_period_types
          set
          user_period_type                = x_user_period_type,
          description                     = x_description,
          last_update_date                = sysdate,
          last_updated_by                 = user_id,
          last_update_login               = 0
       where period_type 		  = x_period_type
       AND    userenv('LANG') =
             ( SELECT language_code
                FROM  FND_LANGUAGES
               WHERE  installed_flag = 'B' );
    end if;

   if (sql%notfound) then
        null;
    end if;

END TRANSLATE_ROW ;



 PROCEDURE LOAD_ROW(
                x_period_type                   in varchar2,
                x_number_per_fiscal_year        in number,
                x_year_type_in_name             in varchar2,
                x_user_period_type              in varchar2,
                x_description                   in varchar2,
                x_attribute1                    in varchar2,
                x_attribute2                    in varchar2,
                x_attribute3                    in varchar2,
                x_attribute4                    in varchar2,
                x_attribute5                    in varchar2,
                x_context                       in varchar2,
                x_owner                         in varchar2,
                x_force_edits                   in varchar2  default 'N'
               ) AS
    user_id             number := 0;
    v_creation_date     date;
    v_rowid             rowid := null;
    v_num_per_fiscal_yr number;
BEGIN
    -- validate input parameters
    if ( x_period_type is null) then

      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    end if;

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;
   begin

       /*Check if the row exists in the database. If it does, retrieves
         the creation date for update_row. */
       /* bug 2407006: if it is an existing row, use the original
          number_per_fiscal_year to update. */

       select creation_date,rowid,number_per_fiscal_year
       into   v_creation_date, v_rowid, v_num_per_fiscal_yr
       from   gl_period_types
       where  period_type = x_period_type;

    if ((x_force_edits = 'Y') OR (x_owner = 'SEED')) THEN
          -- update row if present
        gl_period_types_pkg.UPDATE_ROW(
    		x_row_id  		 => v_rowid,
                x_period_type		 => x_period_type,
                x_number_per_fiscal_year => v_num_per_fiscal_yr,
    		x_year_type_in_name      => x_year_type_in_name,
    		x_user_period_type       => x_user_period_type,
    		x_description            => x_description,
    		x_attribute1		 => x_attribute1,
    		x_attribute2		 => x_attribute2,
    		x_attribute3		 => x_attribute3,
    		x_attribute4		 => x_attribute4,
    		x_attribute5		 => x_attribute5,
    		x_context                => x_context,
                x_last_update_date       => sysdate,
    		x_last_updated_by        => user_id,
    		x_last_update_login      => 0,
    		x_creation_date          => v_creation_date
             );
   end if;

    exception
        when NO_DATA_FOUND then
     	   gl_period_types_pkg.INSERT_ROW(
    		x_row_id	 	 => v_rowid,
    		x_period_type  		 => x_period_type,
    		x_number_per_fiscal_year => x_number_per_fiscal_year,
    		x_year_type_in_name      => x_year_type_in_name,
    		x_user_period_type       => x_user_period_type,
    		x_description            => x_description,
    		x_attribute1       	 => x_attribute1,
    		x_attribute2       	 => x_attribute2,
    		x_attribute3       	 => x_attribute3,
    		x_attribute4       	 => x_attribute4,
    		x_attribute5       	 => x_attribute5,
    		x_context      		 => x_context,
    		x_last_update_date	 =>  sysdate,
    		x_last_updated_by	 =>  user_id,
    		x_last_update_login	 =>  0,
    		x_creation_date   	 =>  sysdate,
    		x_created_by      	 =>  user_id
            );

   end ;


END LOAD_ROW;

PROCEDURE UPDATE_ROW(
    x_row_id                        in varchar2,
    x_period_type                   in varchar2,
    x_number_per_fiscal_year        in number,
    x_year_type_in_name             in varchar2,
    x_user_period_type              in varchar2,
    x_description                   in varchar2,
    x_attribute1                    in varchar2,
    x_attribute2                    in varchar2,
    x_attribute3                    in varchar2,
    x_attribute4                    in varchar2,
    x_attribute5                    in varchar2,
    x_context                       in varchar2,
    x_last_update_date              in date,
    x_last_updated_by               in number,
    x_last_update_login             in number ,
    x_creation_date                 in date
  ) AS
BEGIN
     Update gl_period_types
     set        period_type            = x_period_type,
                number_per_fiscal_year = x_number_per_fiscal_year,
                year_type_in_name      = x_year_type_in_name,
                user_period_type       = x_user_period_type,
                description            = x_description,
                attribute1             = x_attribute1,
                attribute2             = x_attribute2,
                attribute3             = x_attribute3,
                attribute4             = x_attribute4,
                attribute5             = x_attribute5,
                context                = x_context,
                last_update_date       = x_last_update_date,
                last_updated_by        = x_last_updated_by,
                last_update_login      = x_last_update_login,
                creation_date          = x_creation_date
      where   period_type  = x_period_type;

   if (sql%notfound) then
      raise no_data_found;
   end if;

END UPDATE_ROW;

PROCEDURE INSERT_ROW(
    x_row_id                     in out NOCOPY varchar2,
    x_period_type                   in varchar2,
    x_number_per_fiscal_year        in number,
    x_year_type_in_name             in varchar2,
    x_user_period_type              in varchar2,
    x_description                   in varchar2,
    x_attribute1                    in varchar2,
    x_attribute2                    in varchar2,
    x_attribute3                    in varchar2,
    x_attribute4                    in varchar2,
    x_attribute5                    in varchar2,
    x_context                       in varchar2,
    x_last_update_date              in date,
    x_last_updated_by               in number,
    x_last_update_login             in number ,
    x_creation_date                 in date,
    x_created_by                    in number
  )AS

    cursor period_type_row is
    select rowid
    from gl_period_types
    where period_type = x_period_type;
BEGIN
    if (x_period_type is NULL) then
      raise no_data_found;
    end if;

  INSERT INTO GL_PERIOD_TYPES(
    		period_type,
    		number_per_fiscal_year ,
    		year_type_in_name ,
    		user_period_type,
                period_type_id,
    		description,
    		attribute1,
    		attribute2,
    		attribute3,
    		attribute4,
    		attribute5,
    		context,
    		last_update_date,
    		last_updated_by,
    		last_update_login ,
    		creation_date,
    		created_by )
 	select
                x_period_type,
                x_number_per_fiscal_year ,
                x_year_type_in_name ,
                x_user_period_type ,
                gl_period_types_s.nextval,
                x_description ,
                x_attribute1,
                x_attribute2,
                x_attribute3,
                x_attribute4,
                x_attribute5,
                x_context,
                x_last_update_date  ,
                x_last_updated_by ,
                x_last_update_login,
                x_creation_date,
                x_created_by
     from dual
       where  not exists
           ( 	select null
          	from   gl_period_types B
          	where  B.period_type = x_period_type );


   open period_type_row;
   fetch period_type_row into x_row_id;
    if (period_type_row%notfound) then
      close period_type_row;
      raise no_data_found;
    end if;
    close period_type_row;

END INSERT_ROW;

/* Called from iSpeed calendar api */

procedure checkUpdate(
             mReturnValue          OUT NOCOPY VARCHAR2
            ,mPeriodType           IN VARCHAR2
            ,mNumberPerFiscalYear  IN VARCHAR2
            ,mYearTypeInName       IN VARCHAR2
          )
AS

l_number_per_fiscal_year Number(15) ;
l_year_type_in_name      Varchar2(1);

Cursor c1 is select number_per_fiscal_year,
             year_type_in_name
             from gl_period_types
             where period_type = mPeriodType;
Begin
    mReturnValue := 0;
    open c1;
    fetch c1 into l_number_per_fiscal_year,l_year_type_in_name;
    close c1;
    if ( ( l_number_per_fiscal_year = mNumberPerFiscalYear) AND
        ( mYearTypeInName = l_year_type_in_name )) Then
     mReturnValue := 1;
    else
     mReturnValue := 0;
   end if;

End  checkUpdate;

END gl_period_types_pkg;

/
