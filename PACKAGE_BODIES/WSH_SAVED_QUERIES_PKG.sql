--------------------------------------------------------
--  DDL for Package Body WSH_SAVED_QUERIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_SAVED_QUERIES_PKG" as
/* $Header: WSHQACTB.pls 115.7 2004/04/06 00:53:42 anxsharm ship $ */


-- ===========================================================================
--
-- Name:
--
--   insert_row
--
-- Description:
--
--   Called by the client to insert a row into the
--   WSH_SAVED_QUERIES table.
--
-- ===========================================================================

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_SAVED_QUERIES_PKG';
--
procedure insert_row(
  X_rowid				  out NOCOPY  varchar2,
  X_query_id			          out NOCOPY  number,
  X_name				  varchar2,
  X_description				  varchar2,
  X_entity_type			          varchar2,
  X_shared_flag			          varchar2,
  X_pseudo_query			  long,
  X_attribute_category			  varchar2,
  X_attribute1				  varchar2,
  X_attribute2				  varchar2,
  X_attribute3				  varchar2,
  X_attribute4				  varchar2,
  X_attribute5				  varchar2,
  X_attribute6				  varchar2,
  X_attribute7				  varchar2,
  X_attribute8				  varchar2,
  X_attribute9				  varchar2,
  X_attribute10				  varchar2,
  X_attribute11				  varchar2,
  X_attribute12				  varchar2,
  X_attribute13				  varchar2,
  X_attribute14				  varchar2,
  X_attribute15				  varchar2,
  X_creation_date			  date,
  X_created_by			          number,
  X_last_update_date		          date,
  X_last_updated_by		          number,
  X_last_update_login			  number,
  X_program_application_id 		  number,
  X_program_id				  number,
  X_program_update_date			  date,
  X_request_id				  number
)
is

  X_dummy     varchar2(18);

  cursor id_sequence is
    select wsh_saved_queries_s.nextval
    from sys.dual;

  cursor row_id is
    select rowid
    from wsh_saved_queries_b
    where query_id = X_query_id;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'INSERT_ROW';
--
begin

  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'X_NAME',X_NAME);
      WSH_DEBUG_SV.log(l_module_name,'X_DESCRIPTION',X_DESCRIPTION);
      WSH_DEBUG_SV.log(l_module_name,'X_ENTITY_TYPE',X_ENTITY_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'X_SHARED_FLAG',X_SHARED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_REQUEST_ID',X_REQUEST_ID);
  END IF;
  --
  open id_sequence;
  fetch id_sequence into X_query_id;
  close id_sequence;

  insert into wsh_saved_queries_b(

    query_id,
    entity_type,
    shared_flag,
    pseudo_query,
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
    attribute15,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    program_application_id,
    program_id,
    program_update_date,
    request_id

  ) values(

    X_query_id,
    X_entity_type,
    X_shared_flag,
    X_pseudo_query,
    X_attribute_category,
    X_attribute1,
    X_attribute2,
    X_attribute3,
    X_attribute4,
    X_attribute5,
    X_attribute6,
    X_attribute7,
    X_attribute8,
    X_attribute9,
    X_attribute10,
    X_attribute11,
    X_attribute12,
    X_attribute13,
    X_attribute14,
    X_attribute15,
    X_creation_date,
    X_created_by,
    X_last_update_date,
    X_last_updated_by,
    X_last_update_login,
    X_program_application_id,
    X_program_id,
    X_program_update_date,
    X_request_id
  );

  insert into wsh_saved_queries_tl (

    query_id,
    name,
    description,
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    language,
    source_lang

  ) select

    x_query_id,
    x_name,
    x_description,
    x_creation_date,
    x_created_by,
    x_last_update_date,
    x_last_updated_by,
    x_last_update_login,
    l.language_code,
    userenv('LANG')

  from
    fnd_languages l
  where
    l.installed_flag in ('I', 'B')
    and not exists
      (select null
      from wsh_saved_queries_tl t
      where t.query_id = x_query_id
      and t.language = l.language_code);

  open row_id;

  fetch row_id into X_rowid;

  if (row_id%NOTFOUND) then
    close row_id;
    IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'no_data_found');
    END IF;
    raise NO_DATA_FOUND;
  end if;

  close row_id;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
exception
  when DUP_VAL_ON_INDEX then
    fnd_message.set_name('WSH', 'WSH_DUPLICATE_RECORD');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DUP_VAL_ON_INDEX exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DUP_VAL_ON_INDEX');
    END IF;
    --
    app_exception.raise_exception;
  when app_exception.record_lock_exception then
    fnd_message.set_name('OE', 'WSH_NO_LOCK');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.RECORD_LOCK_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.RECORD_LOCK_EXCEPTION');
    END IF;
    --
    app_exception.raise_exception;
end insert_row;


-- ===========================================================================
--
-- Name:
--
--   lock_row
--
-- Description:
--
--   Called by the client to lock a row into the
--   WSH_SAVED_QUERIES table.
--
-- ===========================================================================

procedure lock_row(
  X_query_id			          number,
  X_name				  varchar2,
  X_description				  varchar2,
  X_entity_type			          varchar2,
  X_shared_flag			          varchar2,
  X_pseudo_query			  long,
  X_attribute_category			  varchar2,
  X_attribute1				  varchar2,
  X_attribute2				  varchar2,
  X_attribute3				  varchar2,
  X_attribute4				  varchar2,
  X_attribute5				  varchar2,
  X_attribute6				  varchar2,
  X_attribute7				  varchar2,
  X_attribute8				  varchar2,
  X_attribute9				  varchar2,
  X_attribute10				  varchar2,
  X_attribute11				  varchar2,
  X_attribute12				  varchar2,
  X_attribute13				  varchar2,
  X_attribute14				  varchar2,
  X_attribute15				  varchar2,
  X_creation_date			  date,
  X_created_by			          number,
  X_last_update_date		          date,
  X_last_updated_by		          number,
  X_last_update_login			  number,
  X_program_application_id 		  number,
  X_program_id				  number,
  X_program_update_date			  date,
  X_request_id				  number
)
is

  cursor lock_record is
    select *
    from   wsh_saved_queries_b
    where  query_id = X_query_id
    for update nowait;

  rec_info lock_record%ROWTYPE;

  cursor c1 is
    select
      name,
      description,
      decode(language, userenv('LANG'), 'Y', 'N') baselang
    from wsh_saved_queries_tl
    where query_id = x_query_id
    and userenv('LANG') in (language, source_lang)
    for update of query_id nowait;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'LOCK_ROW';
--
begin

  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'X_QUERY_ID',X_QUERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_NAME',X_NAME);
      WSH_DEBUG_SV.log(l_module_name,'X_DESCRIPTION',X_DESCRIPTION);
      WSH_DEBUG_SV.log(l_module_name,'X_ENTITY_TYPE',X_ENTITY_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'X_REQUEST_ID',X_REQUEST_ID);
  END IF;
  --
  open lock_record;

  fetch lock_record into rec_info;

  if (lock_record%NOTFOUND) then
    close lock_record;

    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_DELETED');
    END IF;
    app_exception.raise_exception;

  end if;

  close lock_record;

  if (
	  (rec_info.query_id = X_query_id)
    and
	  (rec_info.entity_type = X_entity_type)
    and
	  (rec_info.shared_flag = X_shared_flag)
    and
	  ((rec_info.pseudo_query = X_pseudo_query)
	or
	  ((rec_info.pseudo_query is null)
	    and (X_pseudo_query is null)))
    and
	  ((rec_info.attribute_category = X_attribute_category)
	or
	  ((rec_info.attribute_category is null)
	    and (X_attribute_category is null)))
    and
	  ((rec_info.attribute1 = X_attribute1)
	or
	  ((rec_info.attribute1 is null)
	    and (X_attribute1 is null)))
    and
	  ((rec_info.attribute2 = X_attribute2)
	or
	  ((rec_info.attribute2 is null)
	    and (X_attribute2 is null)))
    and
	  ((rec_info.attribute3 = X_attribute3)
	or
	  ((rec_info.attribute3 is null)
	    and (X_attribute3 is null)))
    and
	  ((rec_info.attribute4 = X_attribute4)
	or
	  ((rec_info.attribute4 is null)
	    and (X_attribute4 is null)))
    and
	  ((rec_info.attribute5 = X_attribute5)
	or
	  ((rec_info.attribute5 is null)
	    and (X_attribute5 is null)))
    and
	  ((rec_info.attribute6 = X_attribute6)
	or
	  ((rec_info.attribute6 is null)
	    and (X_attribute6 is null)))
    and
	  ((rec_info.attribute7 = X_attribute7)
	or
	  ((rec_info.attribute7 is null)
	    and (X_attribute7 is null)))
    and
	  ((rec_info.attribute8 = X_attribute8)
	or
	  ((rec_info.attribute8 is null)
	    and (X_attribute8 is null)))
    and
	  ((rec_info.attribute9 = X_attribute9)
	or
	  ((rec_info.attribute9 is null)
	    and (X_attribute9 is null)))
    and
	  ((rec_info.attribute10 = X_attribute10)
	or
	  ((rec_info.attribute10 is null)
	    and (X_attribute10 is null)))
    and
	  ((rec_info.attribute11 = X_attribute11)
	or
	  ((rec_info.attribute11 is null)
	    and (X_attribute11 is null)))
    and
	  ((rec_info.attribute12 = X_attribute12)
	or
	  ((rec_info.attribute12 is null)
	    and (X_attribute12 is null)))
    and
	  ((rec_info.attribute13 = X_attribute13)
	or
	  ((rec_info.attribute13 is null)
	    and (X_attribute13 is null)))
    and
	  ((rec_info.attribute14 = X_attribute14)
	or
	  ((rec_info.attribute14 is null)
	    and (X_attribute14 is null)))
    and
	  ((rec_info.attribute15 = X_attribute15)
	or
	  ((rec_info.attribute15 is null)
	    and (X_attribute15 is null)))
    and
	  (rec_info.creation_date = X_creation_date)
    and
	  (rec_info.created_by = X_created_by)
    and
	  (rec_info.last_update_date = X_last_update_date)
    and
	  (rec_info.last_updated_by = X_last_updated_by)
    and
	  ((rec_info.last_update_login = X_last_update_login)
	or
	  ((rec_info.last_update_login is null)
	    and (X_last_update_login is null)))
    and
	  ((rec_info.program_application_id = X_program_application_id)
	or
	  ((rec_info.program_application_id is null)
	    and (X_program_application_id is null)))
    and
	  ((rec_info.program_id = X_program_id)
	or
	  ((rec_info.program_id is null)
	    and (X_program_id is null)))
    and
	  ((rec_info.program_update_date = X_program_update_date)
	or
	  ((rec_info.program_update_date is null)
	    and (X_program_update_date is null)))
    and
	  ((rec_info.request_id = X_request_id)
	or
	  ((rec_info.request_id is null)
	    and (X_request_id is null)))
  ) then

    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'Nothing changed');
    END IF;
    --
    return;

  else

    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_CHANGED');
    END IF;
    app_exception.raise_exception;

  end if;

  for tlinfo in c1 loop
    IF l_debug_on THEN
       WSH_DEBUG_SV.log(l_module_name,'tlinfo.BASELANG',tlinfo.BASELANG);
    END IF;
    if (tlinfo.BASELANG = 'Y') then
      if (    ((tlinfo.NAME = X_NAME)
               OR ((tlinfo.NAME is null) AND (X_NAME is null)))
          AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
               OR ((tlinfo.DESCRIPTION is null) AND (X_DESCRIPTION is null)))
      ) then
        null;
      else
        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name,'FORM_RECORD_CHANGED');
        END IF;
        app_exception.raise_exception;
      end if;
    end if;
  end loop;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
end lock_row;


-- ===========================================================================
--
-- Name:
--
--   update_row
--
-- Description:
--
--   Called by the client to update a row into the
--   WSH_SAVED_QUERIES table.
--
-- ===========================================================================

procedure update_row(
  X_query_id			          number,
  X_name				  varchar2,
  X_description				  varchar2,
  X_entity_type			          varchar2,
  X_shared_flag			          varchar2,
  X_pseudo_query			  long,
  X_attribute_category			  varchar2,
  X_attribute1				  varchar2,
  X_attribute2				  varchar2,
  X_attribute3				  varchar2,
  X_attribute4				  varchar2,
  X_attribute5				  varchar2,
  X_attribute6				  varchar2,
  X_attribute7				  varchar2,
  X_attribute8				  varchar2,
  X_attribute9				  varchar2,
  X_attribute10				  varchar2,
  X_attribute11				  varchar2,
  X_attribute12				  varchar2,
  X_attribute13				  varchar2,
  X_attribute14				  varchar2,
  X_attribute15				  varchar2,
  X_last_update_date		          date,
  X_last_updated_by		          number,
  X_last_update_login			  number,
  X_program_application_id 		  number,
  X_program_id				  number,
  X_program_update_date			  date,
  X_request_id				  number
)
is
  X_dummy		  varchar2(18);
  --
l_debug_on BOOLEAN;
  --
  l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'UPDATE_ROW';
  --
begin
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
      --
      WSH_DEBUG_SV.log(l_module_name,'X_QUERY_ID',X_QUERY_ID);
      WSH_DEBUG_SV.log(l_module_name,'X_NAME',X_NAME);
      WSH_DEBUG_SV.log(l_module_name,'X_DESCRIPTION',X_DESCRIPTION);
      WSH_DEBUG_SV.log(l_module_name,'X_ENTITY_TYPE',X_ENTITY_TYPE);
      WSH_DEBUG_SV.log(l_module_name,'X_SHARED_FLAG',X_SHARED_FLAG);
      WSH_DEBUG_SV.log(l_module_name,'X_REQUEST_ID',X_REQUEST_ID);
  END IF;
  --
  update wsh_saved_queries_b set

    entity_type				= X_entity_type,
    shared_flag				= X_shared_flag,
    pseudo_query			= X_pseudo_query,
    attribute_category			= X_attribute_category,
    attribute1				= X_attribute1,
    attribute2				= X_attribute2,
    attribute3				= X_attribute3,
    attribute4				= X_attribute4,
    attribute5				= X_attribute5,
    attribute6				= X_attribute6,
    attribute7				= X_attribute7,
    attribute8				= X_attribute8,
    attribute9				= X_attribute9,
    attribute10				= X_attribute10,
    attribute11				= X_attribute11,
    attribute12				= X_attribute12,
    attribute13				= X_attribute13,
    attribute14				= X_attribute14,
    attribute15				= X_attribute15,
    last_update_date			= X_last_update_date,
    last_updated_by			= X_last_updated_by,
    last_update_login			= X_last_update_login,
    program_application_id		= X_program_application_id,
    program_id				= X_program_id,
    program_update_date			= X_program_update_date,
    request_id				= X_request_id

  where query_id = X_query_id;

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
   END IF;
  if (SQL%NOTFOUND) then
    IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'no_data_found');
    END IF;
    raise NO_DATA_FOUND;
  end if;

  update WSH_SAVED_QUERIES_TL set
    NAME = X_NAME,
    DESCRIPTION = X_DESCRIPTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SOURCE_LANG = userenv('LANG')
  where QUERY_ID = X_QUERY_ID
  and userenv('LANG') in (LANGUAGE, SOURCE_LANG);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
   END IF;
  if (sql%notfound) then
    IF l_debug_on THEN
          WSH_DEBUG_SV.pop(l_module_name,'no_data_found');
    END IF;
    raise no_data_found;
  end if;
  --
  IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
exception
  when DUP_VAL_ON_INDEX then
    fnd_message.set_name('WSH', 'WSH_DUPLICATE_RECORD');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'DUP_VAL_ON_INDEX exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:DUP_VAL_ON_INDEX');
    END IF;
    --
    app_exception.raise_exception;
  when app_exception.record_lock_exception then
    fnd_message.set_name('OE', 'WSH_NO_LOCK');
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.logmsg(l_module_name,'APP_EXCEPTION.RECORD_LOCK_EXCEPTION exception has occured.',WSH_DEBUG_SV.C_EXCEP_LEVEL);
        WSH_DEBUG_SV.pop(l_module_name,'EXCEPTION:APP_EXCEPTION.RECORD_LOCK_EXCEPTION');
    END IF;
    --
    app_exception.raise_exception;
end update_row;


-- ===========================================================================
--
-- Name:
--
--   delete_row
--
-- Description:
--
--   Called by the client to delete a row into the
--   WSH_SAVED_QUERIES table.
--
-- ===========================================================================

procedure delete_row(X_query_id wsh_saved_queries_b.query_id%type)
is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'DELETE_ROW';
--
begin
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  delete from WSH_SAVED_QUERIES_TL
  where QUERY_ID = X_QUERY_ID;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Rows Deleted',SQL%ROWCOUNT);
  END IF;
  if (sql%notfound) then
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
    END IF;
    raise no_data_found;
  end if;

  delete from wsh_saved_queries_b
  where query_id = X_query_id;

  IF l_debug_on THEN
     WSH_DEBUG_SV.log(l_module_name,'Rows Deleted',SQL%ROWCOUNT);
  END IF;
  if (SQL%NOTFOUND) then
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name,'NO_DATA_FOUND');
    END IF;
    raise NO_DATA_FOUND;
  end if;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.pop(l_module_name);
  END IF;
  --
end delete_row;


procedure ADD_LANGUAGE
is
--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'ADD_LANGUAGE';
--
begin
  --
  --
  l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
  --
  IF l_debug_on IS NULL
  THEN
      l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
  END IF;
  --
  IF l_debug_on THEN
      WSH_DEBUG_SV.push(l_module_name);
  END IF;
  --
  delete from WSH_SAVED_QUERIES_TL T
  where not exists
    (select NULL
    from WSH_SAVED_QUERIES_B B
    where B.QUERY_ID = T.QUERY_ID
    );
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows deleted',SQL%ROWCOUNT);
   END IF;

  update WSH_SAVED_QUERIES_TL T set (
      NAME,
      DESCRIPTION
    ) = (select
      B.NAME,
      B.DESCRIPTION
    from WSH_SAVED_QUERIES_TL B
    where B.QUERY_ID = T.QUERY_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.QUERY_ID,
      T.LANGUAGE
  ) in (select
      SUBT.QUERY_ID,
      SUBT.LANGUAGE
    from WSH_SAVED_QUERIES_TL SUBB, WSH_SAVED_QUERIES_TL SUBT
    where SUBB.QUERY_ID = SUBT.QUERY_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
  ));
   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows updated',SQL%ROWCOUNT);
   END IF;
  insert into WSH_SAVED_QUERIES_TL (
    QUERY_ID,
    NAME,
    DESCRIPTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.QUERY_ID,
    B.NAME,
    B.DESCRIPTION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from WSH_SAVED_QUERIES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from WSH_SAVED_QUERIES_TL T
    where T.QUERY_ID = B.QUERY_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

   IF l_debug_on THEN
      WSH_DEBUG_SV.log(l_module_name,'Rows inserted',SQL%ROWCOUNT);
   END IF;
    --
    IF l_debug_on THEN
        WSH_DEBUG_SV.pop(l_module_name);
    END IF;
    --
end ADD_LANGUAGE;


end wsh_saved_queries_pkg;

/
