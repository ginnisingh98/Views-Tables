--------------------------------------------------------
--  DDL for Package Body GL_BC_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GL_BC_OPTIONS_PKG" AS
/*  $Header: glnlsbcb.pls 120.5 2005/05/05 02:06:55 kvora ship $ */

 Procedure load_row(
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_context           in varchar2,
    x_attribute1        in varchar2,
    x_attribute2        in varchar2,
    x_attribute3        in varchar2,
    x_attribute4        in varchar2,
    x_attribute5        in varchar2,
    x_attribute6        in varchar2,
    x_attribute7        in varchar2,
    x_attribute8        in varchar2,
    x_attribute9        in varchar2,
    x_attribute10       in varchar2,
    x_attribute11       in varchar2,
    x_attribute12       in varchar2,
    x_attribute13       in varchar2,
    x_attribute14       in varchar2,
    x_attribute15       in varchar2,
    x_owner             in varchar2,
    x_force_edits       in varchar2 default 'N'
   )as

    user_id            number := 0;
    v_creation_date    date;
    v_rowid            rowid := null;

  BEGIN

    -- validate input parameters
    if ( x_bc_option_id      is null) then

      fnd_message.set_name('SQLGL', 'GL_LOAD_ROW_NO_DATA');
      app_exception.raise_exception;
    end if;

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

    begin

      /* Check if the row exists in the database. If it does, retrieves
         the creation date for update_row. */

       select creation_date,rowid
       into   v_creation_date, v_rowid
       from   gl_bc_options
       where  bc_option_id = x_bc_option_id;

        /* Update only if force_edits is 'Y' or it is seed data */
       if ((x_force_edits = 'Y') OR (x_owner = 'SEED')) THEN
          -- update row if present
           gl_bc_options_pkg.update_row(
                      x_row_id          => v_rowid ,
                      x_bc_option_id    => x_bc_option_id,
                      x_bc_option_name  => x_bc_option_name,
                      x_description     => x_description,
                      x_context         => x_Context,
                      x_attribute1      => x_attribute1,
                      x_attribute2      => x_attribute2,
                      x_attribute3      => x_attribute3,
                      x_attribute4      => x_attribute4,
                      x_attribute5      => x_attribute5,
                      x_attribute6      => x_attribute6,
                      x_attribute7      => x_attribute7,
                      x_attribute8      => x_attribute8,
                      x_attribute9      => x_attribute9,
                      x_attribute10     => x_attribute10,
                      x_attribute11     => x_attribute11,
                      x_attribute12     => x_attribute12,
                      x_attribute13     => x_attribute13,
                      x_attribute14     => x_attribute14,
                      x_attribute15     => x_attribute15,
                      x_last_update_date => sysdate,
                      x_last_updated_by  => user_id,
                      x_last_update_login => 0,
                      x_creation_date     => v_creation_date
                 );
     end if;

    exception
        when NO_DATA_FOUND then
            gl_bc_options_pkg.insert_row(
                      x_row_id          => v_rowid ,
                      x_bc_option_id    => x_bc_option_id,
                      x_bc_option_name  => x_bc_option_name,
                      x_description     => x_description,
                      x_context         => x_Context,
                      x_attribute1      => x_attribute1,
                      x_attribute2      => x_attribute2,
                      x_attribute3      => x_attribute3,
                      x_attribute4      => x_attribute4,
                      x_attribute5      => x_attribute5,
                      x_attribute6      => x_attribute6,
                      x_attribute7      => x_attribute7,
                      x_attribute8      => x_attribute8,
                      x_attribute9      => x_attribute9,
                      x_attribute10      => x_attribute10,
                      x_attribute11      => x_attribute11,
                      x_attribute12      => x_attribute12,
                      x_attribute13      => x_attribute13,
                      x_attribute14      => x_attribute14,
                      x_attribute15      => x_attribute15,
                      x_last_update_date => sysdate,
                      x_last_updated_by  => user_id,
                      x_last_update_login => 0,
                      x_creation_date     => sysdate,
                      x_created_by       => user_id
                 );
   end ;
End load_row;

Procedure translate_row (
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_owner             in varchar2,
    x_force_edits       in varchar2
   ) as

  user_id number := 0;

Begin

    if (X_OWNER = 'SEED') then
      user_id := 1;
    end if;

     /* Update only if force_edits is 'Y' or it is seed data */
     if ((x_force_edits = 'Y') OR (x_owner = 'SEED')) then
       update gl_bc_options
          set
          bc_option_name 		  = x_bc_option_name,
          description 			  = x_description,
          last_update_date                = sysdate,
          last_updated_by                 = user_id,
          last_update_login               = 0
       where bc_option_id = x_bc_option_id
       and   userenv('LANG') =
              ( select language_code
                from   fnd_languages
                where  installed_flag = 'B' );
    end if;

   /*If base language is not set to the language being uploaded, then do nothing.*/
   if (sql%notfound) then
        null;
    end if;

End Translate_Row;




procedure update_row(
    x_row_id            in varchar2,
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_context           in varchar2,
    x_attribute1        in varchar2,
    x_attribute2        in varchar2,
    x_attribute3        in varchar2,
    x_attribute4        in varchar2,
    x_attribute5        in varchar2,
    x_attribute6        in varchar2,
    x_attribute7        in varchar2,
    x_attribute8        in varchar2,
    x_attribute9        in varchar2,
    x_attribute10       in varchar2,
    x_attribute11       in varchar2,
    x_attribute12       in varchar2,
    x_attribute13       in varchar2,
    x_attribute14       in varchar2,
    x_attribute15       in varchar2,
    x_last_update_date  in date,
    x_last_updated_by   in number,
    x_last_update_login in number ,
    x_creation_date     in date
  ) as
begin

 --update non translatable column
 Update gl_bc_options
 set	bc_option_id 		= x_bc_option_id,
	bc_option_name	 	= x_bc_option_name,
	context 		= x_context,
	attribute1		= x_attribute1,
	attribute2		= x_attribute2,
	attribute3		= x_attribute3,
	attribute4		= x_attribute4,
	attribute5		= x_attribute5,
	attribute6		= x_attribute6,
	attribute7		= x_attribute7,
	attribute8		= x_attribute8,
	attribute9		= x_attribute9,
	attribute10		= x_attribute10,
	attribute11		= x_attribute11,
	attribute12		= x_attribute12,
	attribute13		= x_attribute13,
	attribute14		= x_attribute14,
	attribute15		= x_attribute15,
        last_update_date	= x_last_update_date,
	last_updated_by		= x_last_update_login,
	creation_date		= x_creation_date,
        description             = x_description
 where  bc_option_id = x_bc_option_id;


  if (sql%notfound) then
      raise no_data_found;
   end if;

end ;

procedure insert_row (
    x_row_id       in out NOCOPY  varchar2,
    x_bc_option_id      in number,
    x_bc_option_name    in varchar2,
    x_description       in varchar2,
    x_context           in varchar2,
    x_attribute1        in varchar2,
    x_attribute2        in varchar2,
    x_attribute3        in varchar2,
    x_attribute4        in varchar2,
    x_attribute5        in varchar2,
    x_attribute6        in varchar2,
    x_attribute7        in varchar2,
    x_attribute8        in varchar2,
    x_attribute9        in varchar2,
    x_attribute10       in varchar2,
    x_attribute11       in varchar2,
    x_attribute12       in varchar2,
    x_attribute13       in varchar2,
    x_attribute14       in varchar2,
    x_attribute15       in varchar2,
    x_last_update_date  in date,
    x_last_updated_by   in number,
    x_last_update_login in number,
    x_creation_date     in date,
    x_created_by        in number
  ) as

  cursor bc_option_row is
    select rowid
    from gl_bc_options
    where bc_option_id = x_bc_option_id;

begin

    if (x_bc_option_id is NULL) then
      raise no_data_found;
    end if;

    INSERT INTO GL_BC_OPTIONS(
                bc_option_id,
   		bc_option_name,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                description,
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
                context)
    SELECT
                     x_bc_option_id,
		     x_bc_option_name,
                     x_Last_Update_Date,
                     x_Last_Updated_By,
                     x_Creation_Date,
                     x_Created_By,
                     x_Last_Update_Login,
                     x_Description,
                     x_Attribute1,
                     x_Attribute2,
                     x_Attribute3,
                     x_Attribute4,
                     x_Attribute5,
                     x_Attribute6,
                     x_Attribute7,
                     x_Attribute8,
                     x_Attribute9,
                     x_Attribute10,
                     x_Attribute11,
                     x_Attribute12,
                     x_Attribute13,
                     x_Attribute14,
                     x_Attribute15,
                     x_context
    from dual
    where  not exists
        ( select null
          from   gl_bc_options B
          where  B.bc_option_id = x_bc_option_id );


   open bc_option_row;
   fetch bc_option_row into x_row_id;
    if (bc_option_row%notfound) then
      close bc_option_row;
      raise no_data_found;
    end if;
    close bc_option_row;

 end insert_row;

end gl_bc_options_pkg;

/
