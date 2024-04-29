--------------------------------------------------------
--  DDL for Package Body AK_UPLOAD_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AK_UPLOAD_GRP" as
/* $Header: akgulodb.pls 120.2 2005/09/15 22:27:08 tshort ship $ */

procedure UPLOAD (
  p_update_mode       IN   varchar2,
  p_return_status     OUT NOCOPY varchar2
  ) is

  l_api_name          VARCHAR2(30) := 'Upload';
  l_buffer_tbl        AK_ON_OBJECTS_PUB.Buffer_Tbl_Type;
  l_filename          varchar2(128);
  l_index             number := 0;
  l_log_directory     varchar2(128);
  l_log_filename      varchar2(128);
  l_msg_count         number;
  l_msg_data          varchar2(2000);
  l_return_status     VARCHAR2(1);
  l_string_pos        number;
  l_table_index       number;
  l_session_id        number := -1;
begin

  --FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_SUCCESS;
  FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_ERROR;

  FND_PROGRAM.set_session_mode('seed_data');

  -- set current process mode to UPLOAD
  AK_ON_OBJECTS_PUB.G_LOAD_MODE := 'UPLOAD';

  -- Check Update mode
  if (p_update_mode = 'UPDATE') then
    G_UPDATE_MODE := TRUE;
	-- update everything
	G_NO_CUSTOM_UPDATE := FALSE;
	G_COMPARE_UPDATE := FALSE;
  elsif (p_update_mode = 'NCUPDATE') then
	-- update non-customized data only
    G_NO_CUSTOM_UPDATE := TRUE;
	G_UPDATE_MODE := FALSE;
	G_COMPARE_UPDATE := TRUE;
  elsif (p_update_mode = 'NON_SEED_DATA') then
        -- update non-customized data only
    G_NO_CUSTOM_UPDATE := TRUE;
        G_UPDATE_MODE := FALSE;
        G_COMPARE_UPDATE := TRUE;
  elsif (p_update_mode = 'COMPAREUPDATE') then
	-- update everything, but compare date
	G_UPDATE_MODE := TRUE;
	G_NO_CUSTOM_UPDATE := FALSE;
	G_COMPARE_UPDATE := TRUE;
  else
    G_UPDATE_MODE := FALSE;
	G_NO_CUSTOM_UPDATE := FALSE;
	G_COMPARE_UPDATE := FALSE;
  end if;
  --
  -- Load buffer table with log file heading info to be written
  -- to the log file
  --
  l_index := 1;
  l_buffer_tbl(l_index) := '**********';

  l_index := l_index + 1;
  FND_MESSAGE.SET_NAME('AK','AK_START_UPLOAD_SESSION');
  l_buffer_tbl(l_index) := FND_MESSAGE.GET;

  l_index := l_index + 1;
  l_buffer_tbl(l_index) := to_char(sysdate, 'DY MM DD YYYY HH24:MI:SS');
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := '**********';
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := ' ';
  if (G_NON_SEED_DATA) then
	l_index := l_index + 1;
  	l_buffer_tbl(l_index) := 'Uploading in Non Seed Data mode.';
        l_index := l_index + 1;
        l_buffer_tbl(l_index) := 'All WHO columns, in records normally updated depending on update mode, will be updated with the information from the jlt file.';
  	l_index := l_index + 1;
  	l_buffer_tbl(l_index) := ' ';
  end if;

  --dbms_output.put_line('Begin upload at:' ||
  --                     to_char(sysdate, 'MM-DD HH24:MI:SS'));
  --
  -- Write heading info to a log file
  --
  AK_ON_OBJECTS_PVT.WRITE_LOG_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_buffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_OVERWRITE
  );

  /** commit the inserts in ak_loader_temp that's done by akload **/
  commit;

  /** retreive the sessio id **/
  select sid into l_session_id
  from v$session
  where AUDSID = userenv('SESSIONID');

  AK_ON_OBJECTS_PVT.G_SESSION_ID := l_session_id;

  --
  -- Clean up buffer table for use by other messages later
  --
  -- l_buffer_tbl.delete;

  --
  -- Upload data from data file to the database
  --
  AK_ON_OBJECTS_GRP.UPLOAD (
--    p_validation_level => FND_API.G_VALID_LEVEL_NONE,
    p_api_version_number => 1.0,
    p_init_msg_tbl => TRUE,
    p_msg_count => l_msg_count,
    p_msg_data => l_msg_data,
    p_return_status => l_return_status
  );

  p_return_status := l_return_status;

  --dbms_output.put_line('Finish uploading at:' ||
  --                     to_char(sysdate, 'MM-DD HH24:MI:SS'));

  --dbms_output.put_line('Return status is: ' || l_return_status);
  --dbms_output.put_line('Return message: ' || l_msg_data);

  if FND_MSG_PUB.Count_Msg > 0 then
    FND_MSG_PUB.Reset;
    --dbms_output.put_line('Messages: ');
    for i in 1 .. FND_MSG_PUB.Count_Msg loop
      l_buffer_tbl(i + l_index) := FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
      --dbms_output.put_line(to_char(i) || substr(l_buffer_tbl(i),1,256) );
    end loop;
    FND_MSG_PUB.Initialize;
  end if;
  --
  -- Add ending to log file
  --
  l_index := nvl(l_buffer_tbl.last,0) + 1;
  l_buffer_tbl(l_index) := '**********';
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := to_char(sysdate, 'DY MM DD YYYY HH24:MI:SS');
  l_index := l_index + 1;
  FND_MESSAGE.SET_NAME('AK','AK_END_UPLOAD_SESSION');
  l_buffer_tbl(l_index) := FND_MESSAGE.GET;
  --
  -- Write all messages to a log file
  --
  AK_ON_OBJECTS_PVT.WRITE_LOG_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_buffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );
  if (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) or
     (l_return_status = FND_API.G_RET_STS_ERROR) then
    RAISE FND_API.G_EXC_ERROR;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    p_return_status := FND_API.G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Build_Exc_Msg( G_PKG_NAME, l_api_name,
                           SUBSTR (SQLERRM, 1, 240) );
    FND_MSG_PUB.Add;
  if FND_MSG_PUB.Count_Msg > 0 then
    FND_MSG_PUB.Reset;
    if ( l_index is null ) then l_index := 0; end if;
    for i in 1 .. FND_MSG_PUB.Count_Msg loop
      l_buffer_tbl(i + l_index) := FND_MSG_PUB.GET(p_encoded=>FND_API.G_FALSE);
      --dbms_output.put_line(to_char(i) || substr(l_buffer_tbl(i),1,256) );
    end loop;
    FND_MSG_PUB.Initialize;
  end if;
  --
  -- Add ending to log file
  --
  l_index := nvl(l_buffer_tbl.last,0) + 1;
  l_buffer_tbl(l_index) := '**********';
  l_index := l_index + 1;
  l_buffer_tbl(l_index) := to_char(sysdate, 'DY MM DD YYYY HH24:MI:SS');
  l_index := l_index + 1;
  FND_MESSAGE.SET_NAME('AK','AK_END_UPLOAD_SESSION');
  l_buffer_tbl(l_index) := FND_MESSAGE.GET;
  --
  -- Write all messages to a log file
  --
  AK_ON_OBJECTS_PVT.WRITE_LOG_FILE (
    p_return_status => l_return_status,
    p_buffer_tbl => l_buffer_tbl,
    p_write_mode => AK_ON_OBJECTS_PUB.G_APPEND
  );

end UPLOAD;
end AK_UPLOAD_GRP;

/
