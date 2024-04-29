--------------------------------------------------------
--  DDL for Package Body AK_QUERYOBJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_QUERYOBJ_PVT" as
/* $Header: akdvqryb.pls 120.4 2005/09/15 22:46:14 tshort ship $ */

--=======================================================
--  Procedure   WRITE_LINES_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given qurey object
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retrieves and writes the given
--              object to the loader file. Then it calls other local
--              procedures to write all its object attributes and
--              foriegn and unique key definitions to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_query_code : IN required
--                  Key value of the Object to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_LINES_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_query_code				 IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_lines_csr (param_query_code in varchar2) is
    select *
    from AK_QUERY_OBJECT_LINES
    where query_code = param_query_code
    order by seq_num;

  l_api_name           CONSTANT varchar2(30) := 'Write_lines_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_queryobj_lines_rec  AK_QUERY_OBJECT_LINES%ROWTYPE;
  l_return_status      varchar2(1);
  l_line_count			NUMBER := 0;

begin
  -- Retrieve object information from the database

  open l_get_lines_csr(p_query_code);
  loop
  	fetch l_get_lines_csr into l_queryobj_lines_rec;
	exit when l_get_lines_csr%notfound;
	l_line_count := l_line_count + 1;

	  -- query Object line must be validated before it is written to the file
	/* nothing to validate yet
	  if p_validation_level <> FND_API.G_VALID_LEVEL_NONE then
	    if not AK_QUERY_OBJECT_PVT.VALIDATE_LINE (
			p_validation_level => p_validation_level,
			p_api_version_number => 1.0,
			p_return_status => l_return_status,
			p_query_code => l_queryobj_lines_rec.seq_num,
		)
	    then
	      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
	        FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DOWNLOADED');
	        FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
	        FND_MSG_PUB.Add;
		  end if;
	      close l_get_lines_csr;
	      raise FND_API.G_EXC_ERROR;
	    end if;
	  end if;
	*/
	  -- Write object into buffer
	  l_index := 1;

	  l_databuffer_tbl(l_index) := '  BEGIN QUERY_OBJECT_LINE '||nvl(to_char(l_queryobj_lines_rec.seq_num),'""');
	  l_index := l_index + 1;
	  l_databuffer_tbl(l_index) := '    QUERY_LINE_TYPE = "' ||
	    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_queryobj_lines_rec.query_line_type)||'"';
	  l_index := l_index + 1;
	  l_databuffer_tbl(l_index) := '    QUERY_LINE = "' ||
	    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_queryobj_lines_rec.query_line)||'"';
	  l_index := l_index + 1;
	  l_databuffer_tbl(l_index) := '    LINKED_PARAMETER = "' ||
	    AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_queryobj_lines_rec.linked_parameter)||'"';
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = ' ||
                nvl(to_char(l_queryobj_lines_rec.created_by),'""');
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_queryobj_lines_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = ' ||
--                nvl(to_char(l_queryobj_lines_rec.last_updated_by),'""');
    l_databuffer_tbl(l_index) := '  OWNER = ' ||
                FND_LOAD_UTIL.OWNER_NAME(l_queryobj_lines_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_queryobj_lines_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = ' ||
                nvl(to_char(l_queryobj_lines_rec.last_update_login),'""');

	  l_index := l_index + 1;
	  l_databuffer_tbl(l_index) := '  END QUERY_OBJECT_LINE ';
	  l_index := l_index + 1;
	  l_databuffer_tbl(l_index) := ' ';

	  -- - Write object data out to the specified file
	  AK_ON_OBJECTS_PVT.WRITE_FILE (
	    p_return_status => l_return_status,
	    p_buffer_tbl => l_databuffer_tbl,
	    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
	  );
	  -- If API call returns with an error status...
	  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
	     (l_return_status = FND_API.G_RET_STS_ERROR) then
	    close l_get_lines_csr;
	    RAISE FND_API.G_EXC_ERROR;
	  end if;

	  l_databuffer_tbl.delete;

	  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
	     (l_return_status = FND_API.G_RET_STS_ERROR) then
	    close l_get_lines_csr;
	    RAISE FND_API.G_EXC_ERROR;
	  end if;

	  -- - Finish up writing object data out to the specified file
	  AK_ON_OBJECTS_PVT.WRITE_FILE (
	    p_return_status => l_return_status,
	    p_buffer_tbl => l_databuffer_tbl,
	    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
	  );

	  -- If API call returns with an error status...
	  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
	     (l_return_status = FND_API.G_RET_STS_ERROR) then
	    close l_get_lines_csr;
	    RAISE FND_API.G_EXC_ERROR;
	  end if;
  end loop;
  close l_get_lines_csr;

  if (l_line_count = 0) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
--	  dbms_output.put_line('cannot find query '||p_query_code);
      FND_MESSAGE.SET_NAME('AK','AK_QUERY_OBJ_DOES_NOT_EXIST');
  	  FND_MSG_PUB.Add;
    end if;
--  	dbms_output.put_line('Cannot find query object '||p_query_code);
    RAISE FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DOWNLOADED');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_LINES_TO_BUFFER;

--=======================================================
--  Procedure   WRITE_TO_BUFFER (local procedure)
--
--  Usage       Local procedure for writing the given qurey object
--              and all its children records to the output file.
--              Not designed to be called from outside this package.
--
--  Desc        This procedure first retrieves and writes the given
--              object to the loader file. Then it calls other local
--              procedures to write all its object attributes and
--              foriegn and unique key definitions to the same output
--              file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_database_object_name : IN required
--                  Key value of the Object to be extracted to the loader
--                  file.
--              p_nls_language : IN required
--                  The NLS langauge that should be used when
--                  extracting data from the TL table
--=======================================================
procedure WRITE_TO_BUFFER (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_query_code				 IN      VARCHAR2,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_queryobj_csr is
    select *
    from AK_QUERY_OBJECTS
    where query_code = p_query_code;

  l_api_name           CONSTANT varchar2(30) := 'Write_to_buffer';
  l_databuffer_tbl     AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_index              NUMBER;
  l_queryobj_rec        AK_QUERY_OBJECTS%ROWTYPE;
  l_return_status      varchar2(1);

begin

  -- Retrieve query object information from the database

  open l_get_queryobj_csr;
  fetch l_get_queryobj_csr into l_queryobj_rec;
  if (l_get_queryobj_csr%notfound) then
    close l_get_queryobj_csr;
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_QUERY_OBJ_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line('Cannot find query object '||p_query_code);
    RAISE FND_API.G_EXC_ERROR;
  end if;
  close l_get_queryobj_csr;

  -- Write object into buffer
  l_index := 1;

  l_databuffer_tbl(l_index) := 'BEGIN QUERY_OBJECT "' ||
	AK_ON_OBJECTS_PVT.REPLACE_SPECIAL_CHAR(l_queryobj_rec.query_code) || '"';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := '  APPLICATION_ID = ' ||
    nvl(to_char(l_queryobj_rec.application_id),'""');
  -- - Write out who columns
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATED_BY = ' ||
                nvl(to_char(l_queryobj_rec.created_by),'""');
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  CREATION_DATE = "' ||
                to_char(l_queryobj_rec.creation_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
-- CHANGED TO OWNER FOR R12
--    l_databuffer_tbl(l_index) := '  LAST_UPDATED_BY = ' ||
--                nvl(to_char(l_queryobj_rec.last_updated_by),'""');
    l_databuffer_tbl(l_index) := '  OWNER = ' ||
                FND_LOAD_UTIL.OWNER_NAME(l_queryobj_rec.last_updated_by) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_DATE = "' ||
                to_char(l_queryobj_rec.last_update_date,
                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT) || '"';
    l_index := l_index + 1;
    l_databuffer_tbl(l_index) := '  LAST_UPDATE_LOGIN = ' ||
                nvl(to_char(l_queryobj_rec.last_update_login),'""');

  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := ' ';

  -- - Write object data out to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_databuffer_tbl.delete;

  WRITE_LINES_TO_BUFFER (
    p_validation_level => p_validation_level,
    p_return_status => l_return_status,
    p_query_code => p_query_code,
    p_nls_language => p_nls_language
  );
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  l_index := 1;
  l_databuffer_tbl(l_index) := 'END QUERY_OBJECT';
  l_index := l_index + 1;
  l_databuffer_tbl(l_index) := ' ';

  -- - Finish up writing object data out to the specified file
  AK_ON_OBJECTS_PVT.WRITE_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_databuffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );

  -- If API call returns with an error status...
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_OBJECT_NOT_DOWNLOADED');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end WRITE_TO_BUFFER;

--=======================================================
--  Procedure   DOWNLOAD_QUERY_OBJECT
--
--  Usage       Private API for downloading query objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        This API will extract the query objects selected
--              by application ID or by key values from the
--              database to the output file.
--              If a query object is selected for writing to the loader
--              file, all its children records query_object_lines
--              that references this object will also be written.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters
--              p_nls_language : IN optional
--                  NLS language for database. If none if given,
--                  the current NLS language will be used.
--
--              One of the following parameters must be provided:
--
--              p_application_id : IN optional
--                  If given, all attributes for this application ID
--                  will be written to the output file.
--                  p_application_id will be ignored if a table is
--                  given in p_object_pk_tbl.
--              p_queryobj_pk_tbl : IN optional
--                  If given, only queyr objects whose key values are
--                  included in this table will be written to the
--                  output file.
--
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure DOWNLOAD_QUERY_OBJECT (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_application_id           IN      NUMBER := FND_API.G_MISS_NUM,
  p_queryobj_pk_tbl          IN      AK_QUERYOBJ_PUB.queryObj_PK_Tbl_Type
                                    := AK_QUERYOBJ_PUB.G_MISS_QUERYOBJ_PK_TBL,
  p_nls_language             IN      VARCHAR2
) is
  cursor l_get_queryobj_list_csr (appl_id_parm in number) is
    select query_code
    from AK_QUERY_OBJECTS
    where APPLICATION_ID = appl_id_parm;
  l_api_version_number CONSTANT number := 1.0;
  l_api_name           CONSTANT varchar2(30) := 'Download_Query_Object';
  l_application_id     NUMBER;
  l_query_code         VARCHAR2(30);
  l_index              NUMBER;
  l_last_orig_index    NUMBER;
  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(2000);
  l_queryobj_pk_tbl    AK_QUERYOBJ_PUB.Queryobj_PK_Tbl_Type;
  l_return_status      varchar2(1);
begin
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
	  -- dbms_output.put_line('API error in AK_OBJECTS2_PVT');
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Check that one of the following selection criteria is given:
  -- - p_application_id alone, or
  -- - query codes in p_queryobj_PK_tbl

  if (p_application_id = FND_API.G_MISS_NUM) or (p_application_id is null) then
    if (p_queryobj_pk_tbl.count = 0) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_NO_SELECTION');
        FND_MSG_PUB.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;
  else
    if (p_queryobj_PK_tbl.count > 0) then
      -- both application ID and a list of objects to be extracted are
      -- given, issue a warning that we will ignore the application ID
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_APPL_ID_IGNORED');
        FND_MSG_PUB.Add;
      end if;
    end if;
  end if;

  -- If selecting by application ID, first load a query object primary key table
  -- with the query codes of all query objects for the given application ID.
  -- If selecting by a list of query objects, simply copy the query object unique key
  -- table with the parameter
  if (p_queryobj_PK_tbl.count > 0) then
    l_queryobj_pk_tbl := p_queryobj_pk_tbl;
  else
    l_index := 1;
    open l_get_queryobj_list_csr(p_application_id);
    loop
      fetch l_get_queryobj_list_csr into l_queryobj_pk_tbl(l_index);
      exit when l_get_queryobj_list_csr%notfound;
      l_index := l_index + 1;
    end loop;
    close l_get_queryobj_list_csr;
  end if;

  -- Put index pointing to the first record of the query objects primary key table
  l_index := l_queryobj_pk_tbl.FIRST;

  -- Write details for each selected query object, including its query
  -- object lines to a buffer to be passed back to the calling procedure.
  --

  while (l_index is not null) loop
    -- Write object information from the database

--dbms_output.put_line('writing object #'||to_char(l_index) || ':' ||
--                      l_queryobj_pk_tbl(l_index).query_code);

    WRITE_TO_BUFFER(
        p_validation_level => p_validation_level,
        p_return_status => l_return_status,
        p_query_code => l_queryobj_pk_tbl(l_index).query_code,
        p_nls_language => p_nls_language
    );
	-- Download aborts if any of the validation fails
	--
    if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
       (l_return_status = FND_API.G_RET_STS_ERROR) then
--	  dbms_output.put_line('error throwing from WRITE_TO_BUFFER');
      RAISE FND_API.G_EXC_ERROR;
    end if;

    -- Ready to download the next object in the list
    l_index := l_queryobj_pk_tbl.NEXT(l_index);

  end loop;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

-- dbms_output.put_line('returning from ak_object_pvt.download_query_object: ' ||
--                        to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_PK_VALUE_ERROR');
      FND_MSG_PUB.Add;
    end if;
-- dbms_output.put_line('Value error occurred in download- check your object list.');
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
end DOWNLOAD_QUERY_OBJECT;


--=======================================================
--  Procedure   VALIDATE_LINE (local procedure)
--  not being used yet
--=======================================================

FUNCTION VALIDATE_LINE (
		p_validation_level			IN	NUMBER := FND_API.G_VALID_LEVEL_FULL,
		p_api_version_number		IN	NUMBER,
		p_return_status				OUT NOCOPY	VARCHAR2,
		p_query_code				IN	VARCHAR2,
		p_seq_num					IN	NUMBER,
		p_query_line_type			IN	VARCHAR2,
		p_query_line				IN	VARCHAR2,
		p_linked_parameter			IN	VARCHAR2,
		p_pass						IN	NUMBER := 2
	) RETURN BOOLEAN IS
cursor l_chk_seq_num_csr (param_query_code in varchar2,
							param_seq_num in number) is
	select *
	from ak_query_object_lines
	where query_code = param_query_code
	and seq_num = param_seq_num;

l_line_rec		ak_query_object_lines%ROWTYPE;
l_error			boolean;
l_api_name		CONSTANT	varchar2(30) := 'validate_line';

BEGIN
	open l_chk_seq_num_csr (p_query_code, p_seq_num);
	fetch l_chk_seq_num_csr into l_line_rec;
	if (l_chk_seq_num_csr%notfound) then
	  l_error := TRUE;
	  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) and (p_pass = 2) then
	    FND_MESSAGE.SET_NAME('AK','AK_INVALID_REFERENCE');
	    FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
	    FND_MSG_PUB.Add;
	  end if;
	end if;
	close l_chk_seq_num_csr;
	return true;

EXCEPTION
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;

END VALIDATE_LINE;

--=======================================================
--  Function   QUERY_OBJECT_EXISTS
--
--  Usage       Private API for creating query objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--=======================================================

FUNCTION QUERY_OBJECT_EXISTS (
		p_api_version_number	in	number,
		p_return_status			out NOCOPY	varchar2,
		p_query_code			in	varchar2,
		p_application_id		in	number
) RETURN BOOLEAN IS
	CURSOR l_chk_qobj_exists_csr (param_query_code in varchar2,
								param_application_id in number) is
	select 1
	from ak_query_objects
	where query_code = param_query_code
	and application_id = param_application_id;
	l_dummy			number;
	l_api_name		constant	varchar2(30) := 'QUERY_OBJECT_EXISTS';
	l_api_version_number      CONSTANT number := 1.0;
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_chk_qobj_exists_csr(p_query_code, p_application_id);
  fetch l_chk_qobj_exists_csr into l_dummy;
  if (l_chk_qobj_exists_csr%notfound) then
    close l_chk_qobj_exists_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
     return FALSE;
  else
    close l_chk_qobj_exists_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;
END QUERY_OBJECT_EXISTS;


--=======================================================
--  Function   LINE_EXISTS
--
--  Usage       Private API for creating query objects line. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--=======================================================

FUNCTION LINE_EXISTS (
		p_api_version_number	IN	NUMBER,
		p_return_status			OUT NOCOPY	VARCHAR2,
		p_query_code			IN	VARCHAR2,
		p_seq_num				IN	NUMBER
) RETURN BOOLEAN IS
	CURSOR l_chk_line_exists_csr (param_query_code in varchar2,
								param_seq_num in number) is
	select 1
	from ak_query_object_lines
	where query_code = param_query_code
	and seq_num = param_seq_num;
	l_dummy			number;
	l_api_name		constant	varchar2(30) := 'LINE_EXISTS';
	l_api_version_number      CONSTANT number := 1.0;
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return FALSE;
  END IF;

  open l_chk_line_exists_csr(p_query_code, p_seq_num);
  fetch l_chk_line_exists_csr into l_dummy;
  if (l_chk_line_exists_csr%notfound) then
    close l_chk_line_exists_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
     return FALSE;
  else
    close l_chk_line_exists_csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
    return TRUE;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    return FALSE;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    return FALSE;
END LINE_EXISTS;

--=======================================================
--  Procedure   CREATE_QUERY_OBJECT
--
--  Usage       Private API for creating query objects. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a region using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query Object columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--=======================================================

PROCEDURE CREATE_QUERY_OBJECT(
    p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_api_version_number	IN		NUMBER,
	p_init_msg_tbl			IN      BOOLEAN := FALSE,
    p_msg_count				OUT NOCOPY		NUMBER,
    p_msg_data				OUT NOCOPY		VARCHAR2,
    p_return_status			OUT NOCOPY		VARCHAR2,
    p_query_code			IN		VARCHAR2,
    p_application_id		IN		NUMBER,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
	p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
	p_pass					IN		NUMBER := 2
) IS
	l_api_version_number	CONSTANT number := 1.0;
	l_api_name				constant	varchar2(30) := 'CREATE_QUERY_OBJECT';
	l_return_status			varchar2(1);
	l_created_by              number;
	l_creation_date           date;
	l_last_update_date        date;
	l_last_update_login       number;
	l_last_updated_by         number;
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_create_queryobj;

  --** check to see if row already exists **
  if AK_QUERYOBJ_PVT.QUERY_OBJECT_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_query_code => p_query_code,
            p_application_id => p_application_id) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_EXISTS');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(G_PKG_NAME || 'Error - Row already exists');
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  -- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

  insert into AK_QUERY_OBJECTS (
	QUERY_CODE,
	APPLICATION_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
	p_query_code,
	p_application_id,
	l_creation_date,
	l_created_by,
	l_last_update_date,
	l_last_updated_by,
	l_last_update_login);

--  /** commit the insert **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_CREATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_queryobj;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_queryobj;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_queryobj;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

END CREATE_QUERY_OBJECT;

--=======================================================
--  Procedure   CREATE_QUERY_OBJECT_LINE
--
--  Usage       Private API for creating query object lines. This
--              API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Desc        Creates a query object line using the given info.
--              This API should only be called by other APIs that are
--              owned by the Core Modules Team (AK).
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query Object Line columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will create the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--=======================================================

PROCEDURE CREATE_QUERY_OBJECT_LINE(
    p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_api_version_number	IN		NUMBER,
	p_init_msg_tbl			IN      BOOLEAN := FALSE,
    p_msg_count				OUT NOCOPY		NUMBER,
    p_msg_data				OUT NOCOPY		VARCHAR2,
    p_return_status			OUT NOCOPY		VARCHAR2,
    p_query_code			IN		VARCHAR2,
    p_seq_num				IN		NUMBER,
	p_query_line_type 		IN		VARCHAR2,
	p_query_line			IN		VARCHAR2 := FND_API.G_MISS_CHAR,
	p_linked_parameter		IN		VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
	p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
	p_pass					IN		NUMBER := 2
) IS
	l_api_name	constant	varchar2(30) := 'CREATE_QUERY_OBJECT_LINE';
	l_api_version_number	CONSTANT number := 1.0;
	l_return_status			varchar2(1);
	l_created_by              number;
	l_creation_date           date;
	l_last_update_date        date;
	l_last_update_login       number;
	l_last_updated_by         number;
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_create_line;

  --** check to see if row already exists **
  if AK_QUERYOBJ_PVT.LINE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_query_code => p_query_code,
            p_seq_num => p_seq_num) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_LINE_EXISTS');
      FND_MSG_PUB.Add;
    end if;
    -- dbms_output.put_line(G_PKG_NAME || 'Error - Row already exists');
    raise FND_API.G_EXC_ERROR;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

  -- Create record if no validation error was found
  --  NOTE - Calling IS_UPDATEABLE for backward compatibility
  --  old jlt files didn't have who columns and IS_UPDATEABLE
  --  calls SET_WHO which populates those columns, for later
  --  jlt files IS_UPDATEABLE will always return TRUE for CREATE

  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => null,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => null,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'CREATE') then
     null;
  end if;

  insert into AK_QUERY_OBJECT_LINES (
	QUERY_CODE,
	SEQ_NUM,
	QUERY_LINE_TYPE,
	QUERY_LINE,
	LINKED_PARAMETER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
	p_query_code,
	p_seq_num,
	p_query_line_type,
	p_query_line,
	p_linked_parameter,
	l_creation_date,
	l_created_by,
	l_last_update_date,
	l_last_updated_by,
	l_last_update_login);

--  /** commit the insert **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_LINE_CREATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_query_code||' '||to_char(p_seq_num));
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LINE_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code||' '||to_char(p_seq_num));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_line;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LINE_NOT_CREATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code||' '||to_char(p_seq_num));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_create_line;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_create_line;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

END CREATE_QUERY_OBJECT_LINE;

--=======================================================
--  Procedure   UPDATE_QUERY_OBJECT
--
--  Usage       Private API for updating a query object.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API updates a query object using the given info
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  Query Object columns
--              p_loader_timestamp : IN optional
--                  If a timestamp is passed, the API will update the
--                  record using this timestamp. Only the upload API
--                  should call with this parameter loaded.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
PROCEDURE UPDATE_QUERY_OBJECT(
    p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_api_version_number	IN		NUMBER,
	p_init_msg_tbl			IN      BOOLEAN := FALSE,
    p_msg_count				OUT NOCOPY		NUMBER,
    p_msg_data				OUT NOCOPY		VARCHAR2,
    p_return_status			OUT NOCOPY		VARCHAR2,
    p_query_code			IN		VARCHAR2,
    p_application_id		IN		NUMBER,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
	p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
	p_pass					IN		NUMBER := 2
) IS
  cursor l_get_query_csr is
    select *
    from  AK_QUERY_OBJECTS
    where QUERY_CODE = p_query_code
    for update of APPLICATION_ID;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Update_Query_Object';
  l_queryobj_rec            AK_QUERY_OBJECTS%ROWTYPE;
  l_created_by              number;
  l_creation_date           date;
  l_last_update_date        date;
  l_last_update_login       number;
  l_last_updated_by         number;
  l_return_status           varchar2(1);
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_update_queryobj;

  --** retrieve ak_regions row if it exists **
  open l_get_query_csr;
  fetch l_get_query_csr into l_queryobj_rec;
  if (l_get_query_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_query_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_query_csr;

  if ( NOT AK_ON_OBJECTS_PVT.VALID_APPLICATION_ID (
	p_api_version_number => 1.0,
	p_return_status => l_return_status,
	p_application_id => p_application_id) ) then
		FND_MESSAGE.SET_NAME('AK','AK_INVALID_COLUMN_VALUE');
		FND_MESSAGE.SET_TOKEN('COLUMN','APPLICATION_ID');
		FND_MSG_PUB.Add;
		raise FND_API.G_EXC_ERROR;
  end if;

  l_queryobj_rec.application_id := p_application_id;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

-- THIS UPDATES NO MATTER WHAT - CALLING IS_UPDATEABLE BECAUSE STILL
-- NECESSARY FOR PRE-12 CODE
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_queryobj_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_queryobj_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then
     null;
  end if;

  update AK_QUERY_OBJECTS set
	application_id = l_queryobj_rec.application_id,
	LAST_UPDATE_DATE = l_last_update_date,
	LAST_UPDATED_BY = l_last_updated_by,
	LAST_UPDATE_LOGIN = l_last_update_login
  where query_code = p_query_code;

  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_VALUE_ERROR');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    rollback to start_update_queryobj;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_QUERYOBJ_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code);
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_queryobj;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_queryobj;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
     FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

END UPDATE_QUERY_OBJECT;

PROCEDURE UPDATE_QUERY_OBJECT_LINE(
    p_validation_level		IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_api_version_number	IN		NUMBER,
	p_init_msg_tbl			IN      BOOLEAN := FALSE,
    p_msg_count				OUT NOCOPY		NUMBER,
    p_msg_data				OUT NOCOPY		VARCHAR2,
    p_return_status			OUT NOCOPY		VARCHAR2,
    p_query_code			IN		VARCHAR2,
    p_seq_num				IN		NUMBER,
	p_query_line_type 		IN		VARCHAR2 := FND_API.G_MISS_CHAR,
	p_query_line			IN		VARCHAR2 := FND_API.G_MISS_CHAR,
	p_linked_parameter		IN		VARCHAR2 := FND_API.G_MISS_CHAR,
  p_created_by               IN     NUMBER := FND_API.G_MISS_NUM,
  p_creation_date            IN      DATE := FND_API.G_MISS_DATE,
  p_last_updated_by          IN     NUMBER := FND_API.G_MISS_NUM,
  p_last_update_date         IN      DATE := FND_API.G_MISS_DATE,
  p_last_update_login        IN     NUMBER := FND_API.G_MISS_NUM,
	p_loader_timestamp      IN      DATE := FND_API.G_MISS_DATE,
	p_pass					IN		NUMBER := 2
) IS

  cursor l_get_query_line_csr is
    select *
    from  AK_QUERY_OBJECT_LINES
    where QUERY_CODE = p_query_code
	and	  seq_num = p_seq_num
    for update of QUERY_LINE;
  l_api_version_number      CONSTANT number := 1.0;
  l_api_name                CONSTANT varchar2(30) := 'Update_Query_Object_Line';
  l_created_by              number;
  l_creation_date           date;
  l_line_rec				AK_QUERY_OBJECT_LINES%ROWTYPE;
  l_last_update_date        date;
  l_last_update_login       number;
  l_last_updated_by         number;
  l_return_status           varchar2(1);
BEGIN
  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  -- Initialize the message table if requested.

  if p_init_msg_tbl then
    FND_MSG_PUB.initialize;
  end if;

  savepoint start_update_query_line;

  --** retrieve ak_query_object_lines row if it exists **
  open l_get_query_line_csr;
  fetch l_get_query_line_csr into l_line_rec;
  if (l_get_query_line_csr%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) then
      FND_MESSAGE.SET_NAME('AK','AK_LINE_DOES_NOT_EXIST');
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line(l_api_name || 'Error - Row does not exist');
    close l_get_query_line_csr;
    raise FND_API.G_EXC_ERROR;
  end if;
  close l_get_query_line_csr;

  --** Load record to be updated to the database **

  if (p_query_line_type  <> FND_API.G_MISS_CHAR) or
     (p_query_line_type is null) then
    l_line_rec.query_line_type := p_query_line_type;
  end if;
  if (p_query_line  <> FND_API.G_MISS_CHAR) or
     (p_query_line is null) then
    l_line_rec.query_line := p_query_line;
  end if;
  if (p_linked_parameter  <> FND_API.G_MISS_CHAR) or
     (p_linked_parameter is null) then
    l_line_rec.linked_parameter := p_linked_parameter;
  end if;

  if (p_created_by <> FND_API.G_MISS_NUM) then
    l_created_by := p_created_by;
  end if;

  if (p_creation_date <> FND_API.G_MISS_DATE) then
    l_creation_date := p_creation_date;
  end if;

  if (p_last_updated_by <> FND_API.G_MISS_NUM) then
    l_last_updated_by := p_last_updated_by;
  end if;

  if (p_last_update_date <> FND_API.G_MISS_DATE) then
    l_last_update_date := p_last_update_date;
  end if;

  if (p_last_update_login <> FND_API.G_MISS_NUM) then
    l_last_update_login := p_last_update_login;
  end if;

-- THIS UPDATES NO MATTER WHAT - CALLING IS_UPDATEABLE BECAUSE STILL
-- NECESSARY FOR PRE-12 CODE
  if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
       p_loader_timestamp => p_loader_timestamp,
       p_created_by => l_created_by,
       p_creation_date => l_creation_date,
       p_last_updated_by => l_last_updated_by,
       p_db_last_updated_by => l_line_rec.last_updated_by,
       p_last_update_date => l_last_update_date,
       p_db_last_update_date => l_line_rec.last_update_date,
       p_last_update_login => l_last_update_login,
       p_create_or_update => 'UPDATE') then
     null;
  end if;

  update AK_QUERY_OBJECT_LINES set
	query_line_type = l_line_rec.query_line_type,
	query_line = l_line_rec.query_line,
	linked_parameter = l_line_rec.linked_parameter,
	LAST_UPDATE_DATE = l_last_update_date,
	LAST_UPDATED_BY = l_last_updated_by,
	LAST_UPDATE_LOGIN = l_last_update_login
  where query_code = p_query_code
  and seq_num = p_seq_num;

  if (sql%notfound) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LINE_UPDATE_FAILED');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

--  /** commit the update **/
--  commit;

  if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS) THEN
    FND_MESSAGE.SET_NAME('AK','AK_LINE_UPDATED');
    FND_MESSAGE.SET_TOKEN('KEY', p_query_code || to_char(p_seq_num) );
    FND_MSG_PUB.Add;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

EXCEPTION
  WHEN VALUE_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LINE_VALUE_ERROR');
	  FND_MESSAGE.SET_TOKEN('KEY', p_query_code || to_char(p_seq_num) );
      FND_MSG_PUB.Add;
    end if;
    rollback to start_update_query_line;
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN FND_API.G_EXC_ERROR THEN
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_LINE_NOT_UPDATED');
      FND_MESSAGE.SET_TOKEN('KEY', p_query_code || to_char(p_seq_num));
      FND_MSG_PUB.Add;
    end if;
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to start_update_query_line;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to start_update_query_line;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
    FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);
     FND_MSG_PUB.Count_And_Get (
        p_count => p_msg_count,
        p_data => p_msg_data);

END UPDATE_QUERY_OBJECT_LINE;


--=======================================================
--  Procedure   UPLOAD_QUERY_OBJECT
--
--  Usage       Private API for loading query objects from a
--              loader file to the database.
--              This API should only be called by other APIs
--              that are owned by the Core Modules Team (AK).
--
--  Desc        This API reads the query object data (including query
--              object lines) stored in the loader file currently being
--              processed, parses the data, and loads them to the
--              database. The tables are updated with the timestamp
--              passed. This API will process the file until the
--              EOF is reached, a parse error is encountered, or when
--              data for a different business object is read from the file.
--
--  Results     The API returns the standard p_return_status parameter
--              indicating one of the standard return statuses :
--                  * Unexpected error
--                  * Error
--                  * Success
--  Parameters  p_index : IN OUT required
--                  Index of PL/SQL file to be processed.
--              p_loader_timestamp : IN required
--                  The timestamp to be used when creating or updating
--                  records
--              p_line_num : IN optional
--                  The first line number in the file to be processed.
--                  It is used for keeping track of the line number
--                  read so that this info can be included in the
--                  error message when a parse error occurred.
--              p_buffer : IN required
--                  The content of the first line to be processed.
--                  The calling API has already read the first line
--                  that needs to be parsed by this API, so this
--                  line won't be read from the file again.
--              p_line_num_out : OUT
--                  The number of the last line in the loader file
--                  that is read by this API.
--              p_buffer_out : OUT
--                  The content of the last line read by this API.
--                  If an EOF has not reached, this line would
--                  contain the beginning of another business object
--                  that will need to be processed by another API.
--
--  Version     Initial version number  =   1.0
--  History     Current version number  =   1.0
--=======================================================
procedure UPLOAD_QUERY_OBJECT (
  p_validation_level         IN      NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_api_version_number       IN      NUMBER,
  p_return_status            OUT NOCOPY     VARCHAR2,
  p_index                    IN OUT NOCOPY  NUMBER,
  p_loader_timestamp         IN      DATE,
  p_line_num                 IN NUMBER := FND_API.G_MISS_NUM,
  p_buffer                   IN AK_ON_OBJECTS_PUB.Buffer_Type,
  p_line_num_out             OUT NOCOPY    NUMBER,
  p_buffer_out               OUT NOCOPY    AK_ON_OBJECTS_PUB.Buffer_Type,
  p_upl_loader_cur           IN OUT NOCOPY  AK_ON_OBJECTS_PUB.LoaderCurTyp,
  p_pass                     IN      NUMBER := 1 -- we don't need 2 passes for query objects, changed from 2 to 1 to match spec for 9i
) is
  l_api_version_number       CONSTANT number := 1.0;
  l_api_name                 CONSTANT varchar2(30) := 'Upload_queryobj';
  l_line_index               NUMBER := 0;
  l_line_rec                 ak_query_object_lines%ROWTYPE;
  l_line_tbl                 AK_queryobj_PUB.queryobj_lines_Tbl_Type;
  l_buffer                   AK_ON_OBJECTS_PUB.Buffer_Type;
  l_column                   varchar2(30);
  l_dummy                    NUMBER;
  l_eof_flag                 VARCHAR2(1);
  l_index                    NUMBER;
  l_line_num                 NUMBER;
  l_lines_read               NUMBER;
  l_more_queryobj			 BOOLEAN := TRUE;
  l_msg_count                NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_query_index             NUMBER := 0;
  l_query_rec               ak_query_objects%ROWTYPE;
  l_query_tbl               AK_QUERYOBJ_PUB.queryobj_Tbl_Type;
  l_return_status            varchar2(1);
  l_saved_token              AK_ON_OBJECTS_PUB.Buffer_Type;
  l_state                    NUMBER;
  l_token                    AK_ON_OBJECTS_PUB.Buffer_Type;
  l_value_count              NUMBER;
  l_copy_redo_flag           BOOLEAN := FALSE;
  l_user_id1				 NUMBER;
  l_user_id2				 NUMBER;
  l_update1				 DATE;
  l_update2				 DATE;
begin
  --dbms_output.put_line('Started query upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

  IF NOT FND_API.Compatible_API_Call (
    l_api_version_number, p_api_version_number, l_api_name,
    G_PKG_NAME) then
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      return;
  END IF;

  SAVEPOINT Start_Upload;

  -- Retrieve the first non-blank, non-comment line
  l_state := 0;
  l_eof_flag := 'N';
  --
  -- if calling from ak_on_objects.upload (ie, loader timestamp is given),
  -- the tokens 'BEGIN QUERY_OBJECT' has already been parsed. Set initial
  -- buffer to 'BEGIN QUERY_OBJECT' before reading the next line from the
  -- file. Otherwise, set initial buffer to null.
  --
  if (p_loader_timestamp <> FND_API.G_MISS_DATE) then
    l_buffer := 'BEGIN QUERY_OBJECT ' || p_buffer;
  else
    l_buffer := null;
  end if;

  if (p_line_num = FND_API.G_MISS_NUM) then
    l_line_num := 0;
  else
    l_line_num := p_line_num;
  end if;

  while (l_buffer is null and l_eof_flag = 'N' and p_index <=  AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => p_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
        p_upl_loader_cur => p_upl_loader_cur
      );
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
      end if;
      l_line_num := l_line_num + l_lines_read;
      --
      -- trim leading spaces and discard comment lines
      --
      l_buffer := LTRIM(l_buffer);
      if (SUBSTR(l_buffer, 1, 1) = '#') then
        l_buffer := null;
      end if;
  end loop;

  --
  -- Error if there is nothing to be read from the file
  --
  if (l_buffer is null and l_eof_flag = 'Y') then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_EMPTY_BUFFER');
      FND_MSG_PUB.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Read tokens from file, one at a time

  while (l_eof_flag = 'N') and (l_buffer is not null)
        and (l_more_queryobj) loop

    AK_ON_OBJECTS_PVT.GET_TOKEN(
      p_return_status => l_return_status,
      p_in_buf => l_buffer,
      p_token => l_token
    );

--dbms_output.put_line(' State:' || l_state || 'Token:' || l_token);

    if (l_return_status = FND_API.G_RET_STS_ERROR) or
       (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
      if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
        FND_MESSAGE.SET_NAME('AK','AK_GET_TOKEN_ERROR');
        FND_MSG_PUB.Add;
      end if;
      --dbms_output.put_line(l_api_name || ' Error parsing buffer');
      raise FND_API.G_EXC_ERROR;
    end if;


    --
    -- QUERY OBJECT (states 0 - 19)
    --
    if (l_state = 0) then
      if (l_token = 'BEGIN') then
        l_state := 1;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','BEGIN');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 1) then
      if (l_token = 'QUERY_OBJECT') then
        --== Clear out previous column data  ==--
		l_query_rec := AK_QUERYOBJ_PUB.G_MISS_QUERYOBJ_REC;
		l_state := 2;
      else
        -- Found the beginning of a non-region object,
        -- rebuild last line and pass it back to the caller
        -- (ak_on_objects_pvt.upload).
        p_buffer_out := 'BEGIN ' || l_token || ' ' || l_buffer;
        l_more_queryobj := FALSE;
      end if;
    elsif (l_state = 2) then
      if (l_token is not null) then
        l_query_rec.query_code := l_token;
        l_value_count := null;
        l_state := 10;
      else
        --dbms_output.put_line('Expecting region application ID');
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','QUERY_CODE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 10) then
      if (l_token = 'BEGIN') then
        l_state := 13;
      elsif (l_token = 'END') then
        l_state := 19;
      elsif (l_token = 'APPLICATION_ID') or
                       (l_token = 'CREATED_BY') or
                        (l_token = 'CREATION_DATE') or
                        (l_token = 'LAST_UPDATED_BY') or
                        (l_token = 'OWNER') or
                        (l_token = 'LAST_UPDATE_DATE') or
                        (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 11;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','QUERY_OBJECT');
            FND_MSG_PUB.Add;
          end if;
--        dbms_output.put_line('Expecting region field, BEGIN, or END');
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 11) then
      if (l_token = '=') then
        l_state := 12;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED','=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 12) then
      l_value_count := 1;
      if (l_column = 'APPLICATION_ID') then
         l_query_rec.application_id := to_number(l_token);
	 l_state := 10;
      elsif (l_column = 'CREATED_BY') then
         l_query_rec.created_by := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'CREATION_DATE') then
         l_query_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_query_rec.last_updated_by := to_number(l_token);
         l_state := 10;
      elsif (l_column = 'OWNER') then
         l_query_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_query_rec.last_update_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 10;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_query_rec.last_update_login := to_number(l_token);
         l_state := 10;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column);
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
      l_state := 10;
    elsif (l_state = 13) then
      if (l_token = 'QUERY_OBJECT_LINE') then
        --== Clear out previous query object line column data  ==--
        --   and load query object key values into record        --
    l_line_rec := AK_QUERYOBJ_PUB.G_MISS_QUERYOBJ_LINE_REC;
        l_line_rec.query_code := l_query_rec.query_code;
        l_state := 20;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'QUERY_OBJECT_LINE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 19) then
      if (l_token = 'QUERY_OBJECT') then
        l_state := 0;
        l_query_index := l_query_index + 1;
        l_query_tbl(l_query_index) := l_query_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'REGION');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    --
    -- QUERY_OBJECT_LINE (states 20 - 39)
    --
    elsif (l_state = 20) then
      if (l_token is not null) then
        l_line_rec.seq_num := to_number(l_token);
        l_state := 30;
		l_value_count := null;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_VALUE');
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'SEQ_NUM');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 30) then
      if (l_token = 'END') then
        l_state := 39;
      elsif (l_token = 'QUERY_LINE_TYPE') or
        (l_token = 'QUERY_LINE') or
        (l_token = 'LINKED_PARAMETER') or
            (l_token = 'CREATED_BY') or
            (l_token = 'CREATION_DATE') or
            (l_token = 'LAST_UPDATED_BY') or
            (l_token = 'OWNER') or
            (l_token = 'LAST_UPDATE_DATE') or
            (l_token = 'LAST_UPDATE_LOGIN') then
        l_column := l_token;
        l_state := 31;
      else
      --
      -- error if not expecting attribute values added by the translation team
      -- or if we have read in more than a certain number of values
      -- for the same DB column
      --
        l_value_count := l_value_count + 1;
        --
        -- save second value. It will be the token with error if
        -- it turns out that there is a parse error on this line.
        --
        if (l_value_count = 2) then
          l_saved_token := l_token;
        end if;
        if (l_value_count > AK_ON_OBJECTS_PUB.G_MAX_NUM_LOADER_VALUES) or
           (l_value_count is null) then
          if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
            FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR_EFIELD');
            FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
            if (l_value_count is null) then
              FND_MESSAGE.SET_TOKEN('TOKEN', l_token);
            else
              FND_MESSAGE.SET_TOKEN('TOKEN',l_saved_token);
            end if;
            FND_MESSAGE.SET_TOKEN('EXPECTED','QUERY_OBJECT_LINE');
            FND_MSG_PUB.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;
      end if;
    elsif (l_state = 31) then
      if (l_token = '=') then
        l_state := 32;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', '=');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 32) then
      l_value_count := 1;
      if (l_column = 'QUERY_LINE_TYPE') then
         l_line_rec.QUERY_LINE_TYPE := l_token;
         l_state := 30;
      elsif (l_column = 'QUERY_LINE') then
         l_line_rec.QUERY_LINE := l_token;
         l_state := 30;
      elsif (l_column = 'LINKED_PARAMETER') then
         l_line_rec.LINKED_PARAMETER := l_token;
         l_state := 30;
      elsif (l_column = 'CREATED_BY') then
         l_line_rec.created_by := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'CREATION_DATE') then
         l_line_rec.creation_date := to_date(l_token,
                                        AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATED_BY') then
         l_line_rec.last_updated_by := to_number(l_token);
         l_state := 30;
      elsif (l_column = 'OWNER') then
         l_line_rec.last_updated_by := FND_LOAD_UTIL.OWNER_ID(l_token);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_DATE') then
         l_line_rec.last_update_date := to_date(l_token,
                                       AK_ON_OBJECTS_PUB.G_DATE_FORMAT);
         l_state := 30;
      elsif (l_column = 'LAST_UPDATE_LOGIN') then
         l_line_rec.last_update_login := to_number(l_token);
         l_state := 30;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', l_column || ' value');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;
    elsif (l_state = 39) then
	  -- end of query_object_line
      if (l_token = 'QUERY_OBJECT_LINE') then
        l_value_count := null;
        l_state := 10;
        l_line_index := l_line_index + 1;
        l_line_tbl(l_line_index) := l_line_rec;
      else
        if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
          FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
          FND_MESSAGE.SET_TOKEN('TOKEN',l_token);
          FND_MESSAGE.SET_TOKEN('EXPECTED', 'QUERY_OBJECT_LINE');
          FND_MSG_PUB.Add;
        end if;
        raise FND_API.G_EXC_ERROR;
      end if;

    end if; -- if l_state = ...

    -- Get rid of leading white spaces, so that buffer would become
    -- null if the only thing in it are white spaces
    l_buffer := LTRIM(l_buffer);

    -- Get the next non-blank, non-comment line if current line is
    -- fully parsed
    while (l_buffer is null and l_eof_flag = 'N' and p_index <=  AK_ON_OBJECTS_PVT.G_UPL_TABLE_NUM) loop
      AK_ON_OBJECTS_PVT.READ_LINE (
        p_return_status => l_return_status,
        p_index => p_index,
        p_buffer => l_buffer,
        p_lines_read => l_lines_read,
        p_eof_flag => l_eof_flag,
        p_upl_loader_cur => p_upl_loader_cur
      );
      if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
         (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
      end if;
      l_line_num := l_line_num + l_lines_read;
      --
      -- trim leading spaces and discard comment lines
      --
      l_buffer := LTRIM(l_buffer);
      if (SUBSTR(l_buffer, 1, 1) = '#') then
        l_buffer := null;
      end if;
    end loop;

  end LOOP;

  -- If the loops end in a state other then at the end of a region
  -- (state 0) or when the beginning of another business object was
  -- detected, then the file must have ended prematurely, which is an error
  if (l_state <> 0) and (l_more_queryobj) then
    if FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
      FND_MESSAGE.SET_NAME('AK','AK_PARSE_ERROR');
      FND_MESSAGE.SET_TOKEN('LINENUM', to_char(l_line_num));
      FND_MESSAGE.SET_TOKEN('TOKEN', 'END OF FILE');
      FND_MESSAGE.SET_TOKEN('EXPECTED', null);
      FND_MSG_PUB.Add;
    end if;
    --dbms_output.put_line('Unexpected END OF FILE: state is ' ||
    --            to_char(l_state));
    raise FND_API.G_EXC_ERROR;
  end if;

  --
  -- create or update all regions to the database
  --
  if (l_query_tbl.count > 0) then
    for l_index in l_query_tbl.FIRST .. l_query_tbl.LAST loop
      if (l_query_tbl.exists(l_index)) then
        if AK_QUERYOBJ_PVT.QUERY_OBJECT_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
			p_query_code => l_query_tbl(l_index).query_code,
            p_application_id => l_query_tbl(l_index).application_id
            ) then
          --
          -- Update Query Objects only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_QUERYOBJ_PVT.UPDATE_QUERY_OBJECT (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_query_code => l_query_tbl(l_index).query_code,
              p_application_id => l_query_tbl(l_index).application_id,
	p_created_by => l_query_tbl(l_index).created_by,
	p_creation_date => l_query_tbl(l_index).creation_date,
	p_last_updated_by => l_query_tbl(l_index).last_updated_by,
	p_last_update_date => l_query_tbl(l_index).last_update_date,
	p_last_update_login => l_query_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
		      p_pass => p_pass
            );

		  elsif (AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE) then
			-- do not update customized data
			select aqo.last_updated_by, aqo.last_update_date
			into l_user_id1, l_update1
			from ak_query_objects aqo
			where aqo.query_code = l_query_tbl(l_index).query_code
			and aqo.application_id = l_query_tbl(l_index).application_id;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2 ) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_query_tbl(l_index).created_by,
                      p_creation_date => l_query_tbl(l_index).creation_date,
                      p_last_updated_by => l_query_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_query_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_query_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_QUERYOBJ_PVT.UPDATE_QUERY_OBJECT (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_query_code => l_query_tbl(l_index).query_code,
              p_application_id => l_query_tbl(l_index).application_id,
        p_created_by => l_query_tbl(l_index).created_by,
        p_creation_date => l_query_tbl(l_index).creation_date,
        p_last_updated_by => l_query_tbl(l_index).last_updated_by,
        p_last_update_date => l_query_tbl(l_index).last_update_date,
        p_last_update_login => l_query_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
		      p_pass => p_pass
	            );
			end if; -- /* if ( l_user_id1 = 1 ) */
          end if; -- /* if G_UPDATE_MODE G_NC_UPDATE_MODE*/
        else
          AK_QUERYOBJ_PVT.CREATE_QUERY_OBJECT (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
            p_query_code => l_query_tbl(l_index).query_code,
            p_application_id => l_query_tbl(l_index).application_id,
	p_created_by => l_query_tbl(l_index).created_by,
        p_creation_date => l_query_tbl(l_index).creation_date,
        p_last_updated_by => l_query_tbl(l_index).last_updated_by,
        p_last_update_date => l_query_tbl(l_index).last_update_date,
        p_last_update_login => l_query_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass
          );
        end if; -- /* if QUERY_OBJECT_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */
		/******* below piece of code is not actually being used because
		 ******* query objects do not need 2 passes, but I am saving
		 ******* the code here for future use
		 *******/
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  G_QUERY_OBJECT_REDO_INDEX := G_QUERY_OBJECT_REDO_INDEX + 1;
		  G_QUERY_OBJECT_REDO_TBL(G_QUERY_OBJECT_REDO_INDEX) := l_query_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
		/*****************************************************************/
      end if;
    end loop;
  end if;

  --
  -- create or update all query object lines to the database
  --
  if (l_line_tbl.count > 0) then
    for l_index in l_line_tbl.FIRST .. l_line_tbl.LAST loop
      if (l_line_tbl.exists(l_index)) then
        if AK_QUERYOBJ_PVT.LINE_EXISTS (
            p_api_version_number => 1.0,
            p_return_status => l_return_status,
            p_query_code => l_line_tbl(l_index).query_code,
            p_seq_num =>l_line_tbl(l_index).seq_num ) then
          --
          -- Update Query object lines only if G_UPDATE_MODE is TRUE
          --
          if (AK_UPLOAD_GRP.G_UPDATE_MODE) then
            AK_QUERYOBJ_PVT.UPDATE_QUERY_OBJECT_LINE (
              p_validation_level => p_validation_level,
              p_api_version_number => 1.0,
              p_msg_count => l_msg_count,
              p_msg_data => l_msg_data,
              p_return_status => l_return_status,
              p_query_code => l_line_tbl(l_index).query_code,
              p_seq_num =>l_line_tbl(l_index).seq_num,
              p_query_line_type => l_line_tbl(l_index).query_line_type,
              p_query_line => l_line_tbl(l_index).query_line,
              p_linked_parameter => l_line_tbl(l_index).linked_parameter,
	p_created_by => l_line_tbl(l_index).created_by,
	p_creation_date => l_line_tbl(l_index).creation_date,
	p_last_updated_by => l_line_tbl(l_index).last_updated_by,
	p_last_update_date => l_line_tbl(l_index).last_update_date,
	p_last_update_login => l_line_tbl(l_index).last_update_login,
              p_loader_timestamp => p_loader_timestamp,
  		      p_pass => p_pass
            );
		  -- update non-customized data only
		  elsif ( AK_UPLOAD_GRP.G_NO_CUSTOM_UPDATE ) then
			select aqol.last_updated_by, aqol.last_update_date
			into l_user_id1, l_update1
			from ak_query_object_lines aqol
			where aqol.query_code = l_line_tbl(l_index).query_code
			and aqol.seq_num = l_line_tbl(l_index).seq_num;
			/*if ( l_user_id1 = 1 or l_user_id1 = 2 ) then*/
                if AK_ON_OBJECTS_PVT.IS_UPDATEABLE(
                      p_loader_timestamp => p_loader_timestamp,
                      p_created_by => l_line_tbl(l_index).created_by,
                      p_creation_date => l_line_tbl(l_index).creation_date,
                      p_last_updated_by => l_line_tbl(l_index).last_updated_by,
                      p_db_last_updated_by => l_user_id1,
                      p_last_update_date => l_line_tbl(l_index).last_update_date,
                      p_db_last_update_date => l_update1,
                      p_last_update_login => l_line_tbl(l_index).last_update_login,
                      p_create_or_update => 'UPDATE') then

	            AK_QUERYOBJ_PVT.UPDATE_QUERY_OBJECT_LINE (
	              p_validation_level => p_validation_level,
	              p_api_version_number => 1.0,
	              p_msg_count => l_msg_count,
	              p_msg_data => l_msg_data,
	              p_return_status => l_return_status,
	              p_query_code => l_line_tbl(l_index).query_code,
	              p_seq_num =>l_line_tbl(l_index).seq_num,
	              p_query_line_type => l_line_tbl(l_index).query_line_type,
	              p_query_line => l_line_tbl(l_index).query_line,
	              p_linked_parameter => l_line_tbl(l_index).linked_parameter,
        p_created_by => l_line_tbl(l_index).created_by,
        p_creation_date => l_line_tbl(l_index).creation_date,
        p_last_updated_by => l_line_tbl(l_index).last_updated_by,
        p_last_update_date => l_line_tbl(l_index).last_update_date,
        p_last_update_login => l_line_tbl(l_index).last_update_login,
	              p_loader_timestamp => p_loader_timestamp,
	  		      p_pass => p_pass
	            );
			end if; /* if l_user_id1 = 1 and l_user_id2 = 1 */
          end if; -- /* if G_UPDATE_MODE G_NO_CUSTOM_UPDATE */
        else
          AK_QUERYOBJ_PVT.CREATE_QUERY_OBJECT_LINE (
            p_validation_level => p_validation_level,
            p_api_version_number => 1.0,
            p_msg_count => l_msg_count,
            p_msg_data => l_msg_data,
            p_return_status => l_return_status,
	        p_query_code => l_line_tbl(l_index).query_code,
	        p_seq_num =>l_line_tbl(l_index).seq_num,
	        p_query_line_type => l_line_tbl(l_index).query_line_type,
	        p_query_line => l_line_tbl(l_index).query_line,
	        p_linked_parameter => l_line_tbl(l_index).linked_parameter,
        p_created_by => l_line_tbl(l_index).created_by,
        p_creation_date => l_line_tbl(l_index).creation_date,
        p_last_updated_by => l_line_tbl(l_index).last_updated_by,
        p_last_update_date => l_line_tbl(l_index).last_update_date,
        p_last_update_login => l_line_tbl(l_index).last_update_login,
            p_loader_timestamp => p_loader_timestamp,
		    p_pass => p_pass
          );
        end if; -- /* if LINE_EXISTS */
        --
        -- If API call returns with an error status, upload aborts
        if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
        (l_return_status = FND_API.G_RET_STS_ERROR) then
          RAISE FND_API.G_EXC_ERROR;
        end if; -- /* if l_return_status */

		/*** below code is not being used right now ******/
		--
		-- if validation fails, then this record should go to second pass
		if (l_copy_redo_flag) then
		  G_LINE_REDO_INDEX := G_LINE_REDO_INDEX + 1;
		  G_LINE_REDO_TBL(G_LINE_REDO_INDEX) := l_line_tbl(l_index);
		  l_copy_redo_flag := FALSE;
		end if; --/* if l_copy_redo_flag */
		/*************************************************/
      end if; -- /* if l_line_tbl.exists */
    end loop;
  end if; -- /* if l_line_tbl.count > 0 */
  --
  -- Load line number of the last file line processed
  --
  p_line_num_out := l_line_num;

  p_return_status := FND_API.G_RET_STS_SUCCESS;

  --dbms_output.put_line('Leaving query object upload: ' ||
  --                            to_char(sysdate, 'MON-DD HH24:MI:SS'));

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    rollback to Start_Upload;
  WHEN VALUE_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.SET_NAME('AK','AK_REGION_VALUE_ERROR');
    FND_MESSAGE.SET_TOKEN('KEY',l_query_rec.query_code||' '||
    						to_char(l_query_rec.application_id));
    FND_MSG_PUB.Add;
	FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240)||': '||l_column||'='||l_token );
	FND_MSG_PUB.Add;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    rollback to Start_Upload;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
end UPLOAD_QUERY_OBJECT;

end AK_QUERYOBJ_PVT;

/
