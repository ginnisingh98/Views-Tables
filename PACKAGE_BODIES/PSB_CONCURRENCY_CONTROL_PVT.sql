--------------------------------------------------------
--  DDL for Package Body PSB_CONCURRENCY_CONTROL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PSB_CONCURRENCY_CONTROL_PVT" AS
/* $Header: PSBVCCLB.pls 120.3 2005/08/01 09:48:04 sudagarw ship $ */

  G_PKG_NAME CONSTANT   VARCHAR2(30):= 'PSB_CONCURRENCY_CONTROL_PVT';

  TYPE TokNameArray IS TABLE OF VARCHAR2(100)
    INDEX BY BINARY_INTEGER;

  TYPE TokValArray IS TABLE OF VARCHAR2(1000)
    INDEX BY BINARY_INTEGER;

  -- Number of Message Tokens

  no_msg_tokens         NUMBER := 0;

  -- Message Token Name

  msg_tok_names         TokNameArray;

  -- Message Token Value

  msg_tok_val           TokValArray;

  g_dbug                VARCHAR2(1000);



/* ----------------------------------------------------------------------- */
/*                                                                         */
/*                      Private Function Definition                        */
/*                                                                         */
/* ----------------------------------------------------------------------- */

PROCEDURE message_token
( tokname IN  VARCHAR2,
  tokval  IN  VARCHAR2
);

PROCEDURE add_message
( appname  IN  VARCHAR2,
  msgname  IN  VARCHAR2
);

/* ----------------------------------------------------------------------- */

PROCEDURE Enforce_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2,
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
) IS

  l_ws_lock                  VARCHAR2(128);
  l_ws_handle                VARCHAR2(128);
  l_ws_status                INTEGER;

  l_bg_lock                  VARCHAR2(128);
  l_bg_handle                VARCHAR2(128);
  l_bg_status                INTEGER;

  l_bc_lock                  VARCHAR2(128);
  l_bc_handle                VARCHAR2(128);
  l_bc_status                INTEGER;

  l_ps_lock                  VARCHAR2(128);
  l_ps_handle                VARCHAR2(128);
  l_ps_status                INTEGER;

  l_cs_lock                  VARCHAR2(128);
  l_cs_handle                VARCHAR2(128);
  l_cs_status                INTEGER;

  l_ar_lock                  VARCHAR2(128);
  l_ar_handle                VARCHAR2(128);
  l_ar_status                INTEGER;

  l_de_lock                  VARCHAR2(128);
  l_de_handle                VARCHAR2(128);
  l_de_status                INTEGER;

  l_br_lock                  VARCHAR2(128);
  l_br_handle                VARCHAR2(128);
  l_br_status                INTEGER;

  l_pa_lock                  VARCHAR2(128);
  l_pa_handle                VARCHAR2(128);
  l_pa_status                INTEGER;

  l_api_name                 CONSTANT VARCHAR2(30) := 'Enforce_Concurrency_Control';
  l_api_version              CONSTANT NUMBER       := 1.0;

  cursor c_Worksheet is
    select worksheet_id,
	   budget_group_id,
	   budget_calendar_id,
	   nvl(parameter_set_id, global_parameter_set_id) parameter_set_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   nvl(allocrule_set_id, global_allocrule_set_id) allocrule_set_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id
      from PSB_WORKSHEETS_V
     where worksheet_id = p_concurrency_entity_id;

  cursor c_Budget_Revision is
    select budget_revision_id,
	   budget_group_id,
	   parameter_set_id,
	   constraint_set_id
      from psb_budget_revisions_v
     where budget_revision_id = p_concurrency_entity_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if p_concurrency_class = 'WORKSHEET_CREATION' then
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      for c_Worksheet_Rec in c_Worksheet loop

	l_ws_lock := 'PSB%WS' || c_Worksheet_Rec.worksheet_id;
	l_bg_lock := 'PSB%BG' || c_Worksheet_Rec.budget_group_id;
	l_bc_lock := 'PSB%BC' || c_Worksheet_Rec.budget_calendar_id;
	l_ps_lock := 'PSB%PS' || c_Worksheet_Rec.parameter_set_id;

	if c_Worksheet_Rec.constraint_set_id is not null then
	  l_cs_lock := 'PSB%CS' || c_Worksheet_Rec.constraint_set_id;
	end if;

	if c_Worksheet_Rec.allocrule_set_id is not null then
	  l_ar_lock := 'PSB%AR' || c_Worksheet_Rec.allocrule_set_id;
	end if;

	if c_Worksheet_Rec.data_extract_id is not null then
	  l_de_lock := 'PSB%DE' || c_Worksheet_Rec.data_extract_id;
	end if;

      end loop;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := dbms_lock.request (lockhandle => l_ws_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_ws_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_bg_lock,
				 lockhandle => l_bg_handle,
				 expiration_secs => 86400);

      l_bg_status := dbms_lock.request (lockhandle => l_bg_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_bg_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_bc_lock,
				 lockhandle => l_bc_handle,
				 expiration_secs => 86400);

      l_bc_status := dbms_lock.request (lockhandle => l_bc_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_bc_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_ps_lock,
				 lockhandle => l_ps_handle,
				 expiration_secs => 86400);

      l_ps_status := dbms_lock.request (lockhandle => l_ps_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_ps_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      if l_cs_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_cs_lock,
				   lockhandle => l_cs_handle,
				   expiration_secs => 86400);

	l_cs_status := dbms_lock.request (lockhandle => l_cs_handle,
					  lockmode => dbms_lock.s_mode,
					  timeout => 300);

	if l_cs_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

      if l_ar_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_ar_lock,
				   lockhandle => l_ar_handle,
				   expiration_secs => 86400);

	l_ar_status := dbms_lock.request (lockhandle => l_ar_handle,
					  lockmode => dbms_lock.s_mode,
					  timeout => 300);

	if l_ar_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

      if l_de_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_de_lock,
				   lockhandle => l_de_handle,
				   expiration_secs => 86400);

	l_de_status := dbms_lock.request (lockhandle => l_de_handle,
					  lockmode => dbms_lock.s_mode,
					  timeout => 300);

	if l_de_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end;
    end if;

  end;
  elsif p_concurrency_class = 'BUDGET_REVISION_CREATION' then
  begin

    if p_concurrency_entity_name = 'BUDGET_REVISION' then
    begin

      for c_Revision_Rec in c_Budget_Revision loop

	l_br_lock := 'PSB%BR' || c_Revision_Rec.budget_revision_id;
	l_bg_lock := 'PSB%BG' || c_Revision_Rec.budget_group_id;

	if c_Revision_Rec.parameter_set_id is not null then
	   l_ps_lock := 'PSB%PS' || c_Revision_Rec.parameter_set_id;
	end if;

	if c_Revision_Rec.constraint_set_id is not null then
	   l_cs_lock := 'PSB%CS' || c_Revision_Rec.constraint_set_id;
	end if;

      end loop;

      dbms_lock.allocate_unique (lockname => l_br_lock,
				 lockhandle => l_br_handle,
				 expiration_secs => 86400);

      l_br_status := dbms_lock.request (lockhandle => l_br_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_br_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_bg_lock,
				 lockhandle => l_bg_handle,
				 expiration_secs => 86400);

      l_bg_status := dbms_lock.request (lockhandle => l_bg_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_bg_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      if l_ps_lock is not null then
      begin
	dbms_lock.allocate_unique (lockname => l_ps_lock,
				   lockhandle => l_ps_handle,
				   expiration_secs => 86400);

	l_ps_status := dbms_lock.request (lockhandle => l_ps_handle,
					  lockmode => dbms_lock.s_mode,
					  timeout => 300);

	 if l_ps_status <> 0 then
	    raise FND_API.G_EXC_ERROR;
	 end if;
      end;
      end if;

      if l_cs_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_cs_lock,
				   lockhandle => l_cs_handle,
				   expiration_secs => 86400);

	l_cs_status := dbms_lock.request (lockhandle => l_cs_handle,
					  lockmode => dbms_lock.s_mode,
					  timeout => 300);

	if l_cs_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end;
    end if;

  end;
  elsif p_concurrency_class = 'DATAEXTRACT_CREATION' then
  begin

    if p_concurrency_entity_name = 'DATA_EXTRACT' then
    begin

      l_de_lock := 'PSB%DE' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_de_lock,
				 lockhandle => l_de_handle,
				 expiration_secs => 86400);

      l_de_status := dbms_lock.request (lockhandle => l_de_handle,
					lockmode => dbms_lock.s_mode,
					timeout => 300);

      if l_de_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  elsif p_concurrency_class = 'WORKSHEET_CONSOLIDATION' then
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      l_ws_lock := 'PSB%WS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := dbms_lock.request (lockhandle => l_ws_handle,
					timeout => 300,
					release_on_commit => TRUE);

      if l_ws_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'DATA_EXTRACT' then
    begin

      l_de_lock := 'PSB%DE' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_de_lock,
				 lockhandle => l_de_handle,
				 expiration_secs => 86400);

      l_de_status := dbms_lock.request (lockhandle => l_de_handle,
					timeout => 300,
					release_on_commit => TRUE);

      if l_de_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  elsif p_concurrency_class = 'PROJECTIONS' then
  begin

    if p_concurrency_entity_name = 'PARAMETER' then
    begin

      l_pa_lock := 'PSB%PA' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_pa_lock,
				 lockhandle => l_pa_handle,
				 expiration_secs => 86400);

      l_pa_status := dbms_lock.request (lockhandle => l_pa_handle,
					timeout => 300,
					release_on_commit => TRUE);

      if l_pa_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;
  end;

  /* For Bug 4337768 Start */

  elsif p_concurrency_class = 'MODIFY_WORKSHEET' then
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      l_ws_lock := 'PSB%WS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := dbms_lock.request (lockhandle => l_ws_handle,
                            lockmode => dbms_lock.s_mode,
					timeout => 1,
					release_on_commit => TRUE);

      if l_ws_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;
  end;

  /* For Bug 4337768 End */

  else
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      l_ws_lock := 'PSB%WS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := dbms_lock.request (lockhandle => l_ws_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_ws_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'BUDGET_REVISION' then
    begin
      l_br_lock := 'PSB%BR' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_br_lock,
				 lockhandle => l_br_handle,
				 expiration_secs => 86400);

      l_br_status := dbms_lock.request (lockhandle => l_br_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_br_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'BUDGET_GROUP' then
    begin

      l_bg_lock := 'PSB%BG' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_bg_lock,
				 lockhandle => l_bg_handle,
				 expiration_secs => 86400);

      l_bg_status := dbms_lock.request (lockhandle => l_bg_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_bg_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'BUDGET_CALENDAR' then
    begin

      l_bc_lock := 'PSB%BC' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_bc_lock,
				 lockhandle => l_bc_handle,
				 expiration_secs => 86400);

      l_bc_status := dbms_lock.request (lockhandle => l_bc_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_bc_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'PARAMETER_SET' then
    begin

      l_ps_lock := 'PSB%PS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ps_lock,
				 lockhandle => l_ps_handle,
				 expiration_secs => 86400);

      l_ps_status := dbms_lock.request (lockhandle => l_ps_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_ps_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'CONSTRAINT_SET' then
    begin

      l_cs_lock := 'PSB%CS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_cs_lock,
				 lockhandle => l_cs_handle,
				 expiration_secs => 86400);

      l_cs_status := dbms_lock.request (lockhandle => l_cs_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_cs_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'ALLOCRULE_SET' then
    begin

      l_ar_lock := 'PSB%AR' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ar_lock,
				 lockhandle => l_ar_handle,
				 expiration_secs => 86400);

      l_ar_status := dbms_lock.request (lockhandle => l_ar_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_ar_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    elsif p_concurrency_entity_name = 'DATA_EXTRACT' then
    begin

      l_de_lock := 'PSB%DE' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_de_lock,
				 lockhandle => l_de_handle,
				 expiration_secs => 86400);

      l_de_status := dbms_lock.request (lockhandle => l_de_handle,
					timeout => 1,
					release_on_commit => TRUE);

      if l_de_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  end if;

  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     add_message('PSB', 'PSB_CONC_LOCK');
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Enforce_Concurrency_Control;

/* ----------------------------------------------------------------------- */

PROCEDURE Release_Concurrency_Control
( p_api_version              IN   NUMBER,
  p_validation_level         IN   NUMBER := FND_API.G_VALID_LEVEL_NONE,
  p_return_status            OUT  NOCOPY  VARCHAR2,
  p_concurrency_class        IN   VARCHAR2,
  p_concurrency_entity_name  IN   VARCHAR2,
  p_concurrency_entity_id    IN   NUMBER
) IS

  l_ws_lock                  VARCHAR2(128);
  l_ws_handle                VARCHAR2(128);
  l_ws_status                INTEGER;

  l_bg_lock                  VARCHAR2(128);
  l_bg_handle                VARCHAR2(128);
  l_bg_status                INTEGER;

  l_bc_lock                  VARCHAR2(128);
  l_bc_handle                VARCHAR2(128);
  l_bc_status                INTEGER;

  l_ps_lock                  VARCHAR2(128);
  l_ps_handle                VARCHAR2(128);
  l_ps_status                INTEGER;

  l_cs_lock                  VARCHAR2(128);
  l_cs_handle                VARCHAR2(128);
  l_cs_status                INTEGER;

  l_ar_lock                  VARCHAR2(128);
  l_ar_handle                VARCHAR2(128);
  l_ar_status                INTEGER;

  l_de_lock                  VARCHAR2(128);
  l_de_handle                VARCHAR2(128);
  l_de_status                INTEGER;

  l_api_name                 CONSTANT VARCHAR2(30) := 'Release_Concurrency_Control';
  l_api_version              CONSTANT NUMBER       := 1.0;

  cursor c_Worksheet is
    select worksheet_id,
	   budget_group_id,
	   budget_calendar_id,
	   nvl(parameter_set_id, global_parameter_set_id) parameter_set_id,
	   nvl(constraint_set_id, global_constraint_set_id) constraint_set_id,
	   nvl(allocrule_set_id, global_allocrule_set_id) allocrule_set_id,
	   nvl(data_extract_id, global_data_extract_id) data_extract_id
      from PSB_WORKSHEETS_V
     where worksheet_id = p_concurrency_entity_id;

BEGIN

  -- Standard call to check for call compatibility

  if not FND_API.Compatible_API_Call (l_api_version,
				      p_api_version,
				      l_api_name,
				      G_PKG_NAME)
  then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if p_concurrency_class = 'WORKSHEET_CREATION' then
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      for c_Worksheet_Rec in c_Worksheet loop

	l_ws_lock := 'PSB%WS' || c_Worksheet_Rec.worksheet_id;
	l_bg_lock := 'PSB%BG' || c_Worksheet_Rec.budget_group_id;
	l_bc_lock := 'PSB%BC' || c_Worksheet_Rec.budget_calendar_id;
	l_ps_lock := 'PSB%PS' || c_Worksheet_Rec.parameter_set_id;

	if c_Worksheet_Rec.constraint_set_id is not null then
	  l_cs_lock := 'PSB%CS' || c_Worksheet_Rec.constraint_set_id;
	end if;

	if c_Worksheet_Rec.allocrule_set_id is not null then
	  l_ar_lock := 'PSB%AR' || c_Worksheet_Rec.allocrule_set_id;
	end if;

	if c_Worksheet_Rec.data_extract_id is not null then
	  l_de_lock := 'PSB%DE' || c_Worksheet_Rec.data_extract_id;
	end if;

      end loop;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := DBMS_LOCK.RELEASE(lockhandle => l_ws_handle);

      if l_ws_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_bg_lock,
				 lockhandle => l_bg_handle,
				 expiration_secs => 86400);

      l_bg_status := DBMS_LOCK.RELEASE(lockhandle => l_bg_handle);

      if l_bg_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_bc_lock,
				 lockhandle => l_bc_handle,
				 expiration_secs => 86400);

      l_bc_status := DBMS_LOCK.RELEASE(lockhandle => l_bc_handle);

      if l_bc_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      dbms_lock.allocate_unique (lockname => l_ps_lock,
				 lockhandle => l_ps_handle,
				 expiration_secs => 86400);

      l_ps_status := DBMS_LOCK.RELEASE(lockhandle => l_ps_handle);

      if l_ps_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

      if l_cs_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_cs_lock,
				   lockhandle => l_cs_handle,
				   expiration_secs => 86400);

	l_cs_status := DBMS_LOCK.RELEASE(lockhandle => l_cs_handle);

	if l_cs_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

      if l_ar_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_ar_lock,
				   lockhandle => l_ar_handle,
				   expiration_secs => 86400);

	l_ar_status := DBMS_LOCK.RELEASE(lockhandle => l_ar_handle);

	if l_ar_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

      if l_de_lock is not null then
      begin

	dbms_lock.allocate_unique (lockname => l_de_lock,
				   lockhandle => l_de_handle,
				   expiration_secs => 86400);

	l_de_status := DBMS_LOCK.RELEASE(lockhandle => l_de_handle);

	if l_de_status <> 0 then
	  raise FND_API.G_EXC_ERROR;
	end if;

      end;
      end if;

    end;
    end if;

  end;
  elsif p_concurrency_class = 'DATAEXTRACT_CREATION' then
  begin

    if p_concurrency_entity_name = 'DATA_EXTRACT' then
    begin

      l_de_lock := 'PSB%DE' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_de_lock,
				 lockhandle => l_de_handle,
				 expiration_secs => 86400);

      l_de_status := DBMS_LOCK.RELEASE(lockhandle => l_de_handle);

      if l_de_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;

  end;
  elsif p_concurrency_class = 'WORKSHEET_CONSOLIDATION' then
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      l_ws_lock := 'PSB%WS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := DBMS_LOCK.RELEASE(lockhandle => l_ws_handle);

      if l_ws_status <> 0 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;
  end;

  /* For Bug 4337768 Start*/

  elsif p_concurrency_class = 'MAINTENANCE' then
  begin

    if p_concurrency_entity_name = 'WORKSHEET' then
    begin

      l_ws_lock := 'PSB%WS' || p_concurrency_entity_id;

      dbms_lock.allocate_unique (lockname => l_ws_lock,
				 lockhandle => l_ws_handle,
				 expiration_secs => 86400);

      l_ws_status := DBMS_LOCK.RELEASE(lockhandle => l_ws_handle);

      -- For locks requested with release_on_commit = true
      -- l_ws_status will be 4 since allocate_unique will
      -- commit and release the lock. 4 is for 'do not own
      -- a lock specified by id or lockhandle'.

      if l_ws_status <> 0 and l_ws_status <> 4 then
	raise FND_API.G_EXC_ERROR;
      end if;

    end;
    end if;
  end;

  /* For Bug 4337768 End */

  end if;
  p_return_status := FND_API.G_RET_STS_SUCCESS;


EXCEPTION

   when FND_API.G_EXC_ERROR then
     p_return_status := FND_API.G_RET_STS_ERROR;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

   when OTHERS then

     if FND_MSG_PUB.Check_Msg_Level
       (p_message_level => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) then

       FND_MSG_PUB.Add_Exc_Msg
	  (p_pkg_name => G_PKG_NAME,
	   p_procedure_name => l_api_name);

     end if;

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Release_Concurrency_Control;

/* ----------------------------------------------------------------------- */

-- Add Token and Value to the Message Token array

PROCEDURE message_token(tokname IN VARCHAR2,
			tokval  IN VARCHAR2) IS

BEGIN

  if no_msg_tokens is null then
    no_msg_tokens := 1;
  else
    no_msg_tokens := no_msg_tokens + 1;
  end if;

  msg_tok_names(no_msg_tokens) := tokname;
  msg_tok_val(no_msg_tokens) := tokval;

END message_token;

/* ----------------------------------------------------------------------- */

-- Define a Message Token with a Value and set the Message Name

-- Calls FND_MESSAGE server package to set the Message Stack. This message is
-- retrieved by the calling program.

PROCEDURE add_message(appname IN VARCHAR2,
		      msgname IN VARCHAR2) IS

  i  BINARY_INTEGER;

BEGIN

  if ((appname is not null) and
      (msgname is not null)) then

    FND_MESSAGE.SET_NAME(appname, msgname);

    if no_msg_tokens is not null then
      for i in 1..no_msg_tokens loop
	FND_MESSAGE.SET_TOKEN(msg_tok_names(i), msg_tok_val(i));
      end loop;
    end if;

    FND_MSG_PUB.Add;

  end if;

  -- Clear Message Token stack

  no_msg_tokens := 0;

END add_message;

/* ----------------------------------------------------------------------- */

  -- Get Debug Information

  -- This Module is used to retrieve Debug Information for this Package. It
  -- prints Debug Information when run as a Batch Process from SQL*Plus. For
  -- the Debug Information to be printed on the Screen, the SQL*Plus parameter
  -- 'Serveroutput' should be set to 'ON'

FUNCTION Get_Debug RETURN VARCHAR2 IS

BEGIN

  return(g_dbug);

END Get_Debug;

/* ----------------------------------------------------------------------- */

END PSB_CONCURRENCY_CONTROL_PVT;

/
