--------------------------------------------------------
--  DDL for Package Body FND_FILE_MIME_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_FILE_MIME_TYPES_PKG" as
/* $Header: AFATFMTB.pls 120.0.12010000.6 2013/09/25 21:12:27 ctilley noship $ */
 G_MODULE_SOURCE constant varchar2(80) := 'fnd.plsql.fnd_file_mime_types_pkg.';

-------------------------------------------------------------------------------------
--
-- INSERT_ROW (PUBLIC)
--   Insert new user MIME_TYPE into FND_MIME_TYPES table only.
--   If the mime_type and file_ext already exists, an exception with the error message
--   Already exists will be returned.
--   There are two input arguments that must be provided. All the other columns
--   in FND_MIME_TYPE table can take the default value.
--
--   *** NOTE: This version accepts the last_update columns but these are overridden
--   with the same values as the creation_date and created_by columns.  This exists for
--   backward compatibility.
--
--   If FILE_EXT is null then the ALLOW_FILE_UPLOAD will be set to null regardless of
--   what is passed.
--
-- Input (Mandatory)
--  x_rowid:            Variable to return newly created rowid
--  x_mime_type:        New mime_type to create
--
-- Returns
--   row_id of created mime_type
--

PROCEDURE INSERT_ROW (X_ROWID in out nocopy VARCHAR2,
                      X_MIME_TYPE in VARCHAR2,
                      X_CP_FORMAT_CODE in VARCHAR2,
                      X_CTX_FORMAT_CODE in VARCHAR2,
                      X_CREATION_DATE in DATE,
                      X_CREATED_BY in NUMBER,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_LAST_UPDATE_LOGIN in NUMBER,
                      X_FILE_EXT in VARCHAR2,
                      X_ALLOW_FILE_UPLOAD in VARCHAR2)  IS

BEGIN

     fnd_file_mime_types_pkg.insert_row(X_ROWID,
                                        X_MIME_TYPE,
                                        X_CP_FORMAT_CODE,
                                        X_CTX_FORMAT_CODE,
                      									X_CREATION_DATE,
                      									X_CREATED_BY,
                      									X_FILE_EXT,
                     									  X_ALLOW_FILE_UPLOAD);


END;



-------------------------------------------------------------------------------------
--
-- INSERT_ROW (PUBLIC)
--   Insert new user MIME_TYPE into FND_MIME_TYPES table only.
--   If the mime_type and file_ext already exists, an exception with the error message
--   Already exists will be returned.
--   There are two input arguments that must be provided. All the other columns
--   in FND_MIME_TYPE table can take the default value.
--
--   *** NOTE: This version accepts the last_update columns but these are overridden
--   with the same values as the creation_date and created_by columns
--
--   If FILE_EXT is null then the ALLOW_FILE_UPLOAD will be set to null regardless of
--   what is passed.
--
-- Input (Mandatory)
--  x_rowid:            Variable to return newly created rowid
--  x_mime_type:        New mime_type to create
--
-- Returns
--   row_id of created mime_type
--
PROCEDURE INSERT_ROW (X_ROWID in out nocopy VARCHAR2,
                      X_MIME_TYPE in VARCHAR2,
                      X_CP_FORMAT_CODE in VARCHAR2,
                      X_CTX_FORMAT_CODE in VARCHAR2,
                      X_CREATION_DATE in DATE,
                      X_CREATED_BY in NUMBER,
                      X_FILE_EXT in VARCHAR2,
                      X_ALLOW_FILE_UPLOAD in VARCHAR2)  IS

 cursor C is select rowid from fnd_mime_types
  where lower(mime_type) = lower(x_mime_type)
  and nvl(lower(file_ext),'NULL') = nvl(lower(x_file_ext),'NULL');


 l_owner number;
 l_module_source varchar2(256);

 chk_exists number;
 x_mime_type_id number;
 l_allow_file_upload varchar2(1);
 l_creation_date date;
BEGIN
  l_module_source := G_MODULE_SOURCE||'insert_row';


  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;


   if (x_created_by is null) then
      l_owner := fnd_global.user_id;
  else
     l_owner := x_created_by;
  end if;

   if (x_creation_date = fnd_file_mime_types_pkg.null_date) then
     l_creation_date  := sysdate;
  else
     l_creation_date := x_creation_date;
  end if;


  if (x_file_ext is null) then
     -- ALLOW_FILE_UPLOAD should be null if file_ext is null.
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'For null file_ext the allow_file_upload flag should be null');
     end if;
     l_allow_file_upload := '';
  else
     l_allow_file_upload := x_allow_file_upload;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Attempt to insert for mime_type='||x_mime_type||' and file_ext='||x_file_ext);
  end if;

   select count(*) into chk_exists from fnd_mime_types
    where lower(mime_type) = lower(x_mime_type)
    and nvl(lower(file_ext),'NULL') = nvl(lower(x_file_ext),'NULL');

/*  Checking if a record exists before attempting to insert a record.
 *  Using 2 cursors so that whether a record exists or not the rowid
 *  can be retrieved and returned to the caller
 */

  if (chk_exists = 0) then
     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Record does not exist - insert new record');
     end if;

     select fnd_mime_types_s.NEXTVAL into x_mime_type_id from dual;

     INSERT INTO fnd_mime_types (mime_type_id,
                                 mime_type,
                                 cp_format_code,
                                 ctx_format_code,
                                 creation_date,
                                 created_by,
                                 last_update_date,
                                 last_updated_by,
                                 last_update_login,
                                 file_ext,
                                 allow_file_upload)
                        VALUES
                                (x_mime_type_id,
                                 x_mime_type,
                                 x_cp_format_code,
                                 x_ctx_format_code,
                                 l_creation_date,
                                 l_owner,
                                 l_creation_date,
                                 l_owner,
                                 l_owner,
                                 x_file_ext,
                                 l_allow_file_upload);
  else
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Already exists');
      end if;

      fnd_message.set_name('FND','FND_FILE_MIME_TYPE_EXISTS');
      app_exception.raise_exception;
  end if;

/* Now get the rowid for the mime_type and file_ext specified.
 * This could be for the newly created record or the previous existing record
 */
       open C;
       fetch C into x_rowid;
       if (C%NOTFOUND) then
           close C;
           raise no_data_found;
       end if;

       close C;

   if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
   end if;
 END INSERT_ROW;



-------------------------------------------------------------------------------------
--
-- UPDATE_ROW (PUBLIC)
--   update the data for the MIME_TYPE_ID provided in FND_MIME_TYPES table only.
--   If the mime_type and file_ext already exists, an exception with the error message
--   Already exists will be returned.
--   There is one input argument that must be provided. All the other columns
--   in FND_MIME_TYPE table can take the default value.
--
--   ** NOTE **
--   If FILE_EXT is null then the ALLOW_FILE_UPLOAD will be set to null regardless of
--   what is passed.
--
-- Input (Mandatory)
--  x_mime_type_id:     Mime_type_id of the record to be updated
--
--
PROCEDURE UPDATE_ROW (X_MIME_TYPE_ID in NUMBER,
                      X_MIME_TYPE in VARCHAR2,
                      X_CP_FORMAT_CODE in VARCHAR2,
                      X_CTX_FORMAT_CODE in VARCHAR2,
                      X_LAST_UPDATE_DATE in DATE,
                      X_LAST_UPDATED_BY in NUMBER,
                      X_FILE_EXT in VARCHAR2,
                      X_ALLOW_FILE_UPLOAD in VARCHAR2) IS


l_mime_type varchar2(80);
l_cp_format_code varchar2(10);
l_ctx_format_code varchar2(40);
l_allow_file_upload varchar2(10);
l_file_ext varchar2(20);
l_last_update_login number;
l_last_updated_by number;
l_owner number;
l_last_update_date date;


l_module_source varchar2(256);

BEGIN
      l_module_source := G_MODULE_SOURCE||'update_row';

      if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
      end if;

   if (x_last_updated_by is null) then
       l_owner := fnd_global.user_id;
   else
       l_owner := x_last_updated_by;
   end if;

         if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
             fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Passed mime_type and file_ext: '||x_mime_type||' and file_ext: '||x_file_ext);
         end if;

          select decode(x_mime_type,null,m.mime_type, x_mime_type),
                 decode(x_cp_format_code,fnd_file_mime_types_pkg.null_char,null,null,m.cp_format_code,x_cp_format_code),
                 decode(x_ctx_format_code,fnd_file_mime_types_pkg.null_char,null,null,m.ctx_format_code,x_ctx_format_code),
                 decode(x_file_ext,fnd_file_mime_types_pkg.null_char,null,null,m.file_ext,x_file_ext),
                 decode(x_allow_file_upload,fnd_file_mime_types_pkg.null_char,null,null,m.allow_file_upload,x_allow_file_upload),
                 decode(x_last_update_date,fnd_file_mime_types_pkg.null_date,m.last_update_date,to_date(null),sysdate,x_last_update_date)
          into l_mime_type, l_cp_format_code, l_ctx_format_code, l_file_ext, l_allow_file_upload, l_last_update_date
          from fnd_mime_types m
          where mime_type_id = x_mime_type_id;

           if (SQL%NOTFOUND) then
             if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                 fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'No record exists - call insert_row instead');
             end if;
             raise NO_DATA_FOUND;
          end if;


        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'file_ext is not null update mime_type '||x_mime_type||' and file_ext: '||x_file_ext);
        end if;
      begin
        if (x_file_ext = fnd_file_mime_types_pkg.null_char and l_file_ext is null) then

          -- When nulling out the file_ext the allow_file_upload flag should also  be null

          update fnd_mime_types
          set    mime_type = l_mime_type,
                 cp_format_code = l_cp_format_code,
                 ctx_format_code = l_ctx_format_code,
                 file_ext = null,
                 allow_file_upload = null,
                 last_update_date = l_last_update_date,
                 last_updated_by = l_owner,
                 last_update_login = l_owner
          where mime_type_id = x_mime_type_id;

         else
             update fnd_mime_types
             set    mime_type = l_mime_type,
                    cp_format_code = l_cp_format_code,
                    ctx_format_code = l_ctx_format_code,
                    file_ext = l_file_ext,
                    allow_file_upload = l_allow_file_upload,
                    last_update_date = x_last_update_date,
                    last_updated_by = l_owner,
                    last_update_login = l_owner
             where mime_type_id = x_mime_type_id;

          end if;

        exception when DUP_VAL_ON_INDEX then
          fnd_message.set_name('FND','FND_FILE_MIME_TYPE_EXISTS');
          app_exception.raise_exception;
       end;


    if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
        fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
    end if;

END UPDATE_ROW;

-------------------------------------------------------------------------------------
--
-- DELETE_ROW (PUBLIC)
--   Deletes an existing MIME_TYPE/FILE_EXT combination.
--   If the mime_type and file_ext does not exist, an exception with the error message
--   No data found be returned.
--
--   There are two  input arguments must be provided.
--
-- Input (Mandatory)
--  x_mime_type:     Mime_type of the record to be deleted
--  x_file_ext:      File_ext of the record to be deleted
--

PROCEDURE DELETE_ROW (X_MIME_TYPE in VARCHAR2,
                      X_FILE_EXT in VARCHAR2) IS
l_module_source varchar2(256);
BEGIN
  l_module_source := G_MODULE_SOURCE||'delete_row';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Deleting row for mime_type: '||x_mime_type||' and file_ext: '||x_file_ext);
  end if;

  if (x_file_ext = fnd_file_mime_types_pkg.null_char) then
      delete from fnd_mime_types
      where lower(mime_type) like lower(x_mime_type)
      and file_ext is null;
  else
      delete from fnd_mime_types
      where lower(mime_type) like lower(x_mime_type)
      and lower(file_ext) like lower(x_file_ext);
  end if;

  if (sql%notfound) then
     raise no_data_found;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;
END DELETE_ROW;

-------------------------------------------------------------------------------------
--
--  SET_FILE_EXT (PUBLIC)
--   Sets the file_ext for an existing mime_type that currently has a null file extension.
--   The mime_type must exist without a current file_ext else an exception with the error message
--   No data found is returned.
--
--   If the mime_type exists with a current file_ext then either insert a new record or
--   use update_row to change the current file_ext to the new file_ext.
--
--   There are two  input arguments must be provided.
--
-- Input (Mandatory)
--  x_mime_type:     Mime_type of the record to be updated
--  x_file_ext:      File_ext to set for this mime_type
--
PROCEDURE SET_FILE_EXT (X_MIME_TYPE IN VARCHAR2,
                        X_FILE_EXT IN VARCHAR2,
                        X_LAST_UPDATE_DATE in DATE,
                        X_LAST_UPDATED_BY in NUMBER) IS

cnt_exists number;
l_owner number;
l_last_update_date date;
l_module_source varchar2(256);


BEGIN
  l_module_source := G_MODULE_SOURCE||'set_file_ext';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

  if (x_last_updated_by is null) then
      l_owner := fnd_global.user_id;
  else
     l_owner := x_last_updated_by;
  end if;

  if (x_last_update_date = fnd_file_mime_types_pkg.null_date) then
     l_last_update_date  := sysdate;
  else
     l_last_update_date := x_last_update_date;
  end if;

  if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'set_file_ext for mime_type: '||x_mime_type||' and file_ext: '||x_file_ext);
  end if;

   select count(1) into cnt_exists
   from fnd_mime_types
   where lower(mime_type) = lower(x_mime_type)
   and lower(file_ext) = lower(file_ext);

   if (cnt_exists > 0) then
      if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
          fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Already exists - update existing record');
      end if;

       fnd_message.set_name('FND', 'FND_FILE_MIME_TYPE_EXISTS');
       app_exception.raise_exception;

   elsif (cnt_exists = 0) then

     if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
         fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Does not exist - check for null file_ext: '||x_mime_type||' and file_ext: '||x_file_ext);
     end if;

     -- Check if a mime type exists without file_ext
      select count(1) into cnt_exists from fnd_mime_types
      where lower(mime_type) = lower(x_mime_type)
      and file_ext is null;

      if (cnt_exists <> 0) then

        if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
            fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'Update mime_type: '||x_mime_type||' set file_ext= '||x_file_ext);
        end if;

        UPDATE FND_MIME_TYPES
        SET file_ext = x_file_ext,
            last_update_date = l_last_update_date,
            last_updated_by = l_owner,
            last_update_login = l_owner
        WHERE lower(MIME_TYPE) like lower(X_MIME_TYPE)
        AND FILE_EXT IS NULL
        AND ROWNUM = 1;

         if (SQL%NOTFOUND) then
            if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
                fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'No record exists - call insert_row instead');
            end if;

            raise NO_DATA_FOUND;
         end if;
       end if;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

END;

-------------------------------------------------------------------------------------
--
--  SET_ALLOW_UPLOAD (PUBLIC)
--   Sets the allow_file_upload for an existing mime_type and file_ext combination that
--   currently has a null file extension.
--   The mime_type and file_ext must exist, else an exception with the error message
--   No data found is returned.
--
--   There are three input arguments must be provided.
--
-- Input (Mandatory)
--  x_mime_type:     			Mime_type of the record to be updated
--  x_file_ext:      			File_ext for this mime_type
--  x_allow_file_upload		'Y' or 'N'
--
PROCEDURE SET_ALLOW_UPLOAD (X_FILE_EXT IN VARCHAR2,
                            X_MIME_TYPE IN VARCHAR2,
                            X_ALLOW_FILE_UPLOAD IN VARCHAR2,
                            X_LAST_UPDATE_DATE in DATE,
                            X_LAST_UPDATED_BY in NUMBER) IS
l_owner number;
l_last_update_date date;
l_module_source varchar2(256);
BEGIN
  l_module_source := G_MODULE_SOURCE||'set_allow_upload';

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'Begin');
  end if;

   if (x_last_updated_by is null) then
      l_owner := fnd_global.user_id;
  else
     l_owner := x_last_updated_by;
  end if;

  if (x_last_update_date = fnd_file_mime_types_pkg.null_date) then
     l_last_update_date  := sysdate;
  else
     l_last_update_date := x_last_update_date;
  end if;

   if (fnd_log.LEVEL_STATEMENT >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_STATEMENT, l_module_source, 'set_allow_upload: '||x_allow_file_upload||' for mime_type: '||x_mime_type||' and file_ext: '||x_file_ext);
  end if;

    UPDATE FND_MIME_TYPES
    SET allow_file_upload = x_allow_file_upload,
        last_update_date = l_last_update_date,
        last_updated_by = l_owner,
        last_update_login = l_owner
    WHERE lower(FILE_EXT) = lower(X_FILE_EXT)
    AND lower(mime_type) = lower(mime_type);

  if (SQL%NOTFOUND) then
     RAISE NO_DATA_FOUND;
  end if;

  if (fnd_log.LEVEL_PROCEDURE >= fnd_log.G_CURRENT_RUNTIME_LEVEL) then
      fnd_log.string(fnd_log.LEVEL_PROCEDURE, l_module_source, 'End');
  end if;

END;


END FND_FILE_MIME_TYPES_PKG;

/
