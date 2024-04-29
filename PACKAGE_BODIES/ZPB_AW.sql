--------------------------------------------------------
--  DDL for Package Body ZPB_AW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_AW" AS
/* $Header: zpbaw.plb 120.14 2007/12/04 14:43:17 mbhat ship $ */

m_ascii_nl constant number := ascii(fnd_global.local_chr(10));

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ZPB_AW';
G_SCHEMA VARCHAR2(16);

-------------------------------------------------------------------------------
-- EXECUTE
--
-- Function to call dbms_aw.execute
--
-- IN:  p_cmd (varchar2) - The AW command to execute
--
-------------------------------------------------------------------------------
procedure EXECUTE (p_cmd in varchar2)
   is
begin
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      zpb_log.write_statement ('zpb_aw.execute',
                               'Executing AW Statement: '||p_cmd);
   end if;
   dbms_aw.execute(p_cmd);
end execute;

-------------------------------------------------------------------------------
-- INTERP <-- DEPRECATED - Use EVAL_TEXT or EVAL_NUMBER instead -->
--
-- Wrapper around the call to the AW, which will parse the output.  If no
-- output is expected, you may just run zpb_aw.execute() instead.
--
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function INTERP (p_cmd in varchar2)
   return varchar2
   is
      l_return varchar2(4000);
begin
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      zpb_log.write_statement ('zpb_aw.interp',
                               'Interpreting AW Statement: '||p_cmd);

      l_return := dbms_lob.substr(dbms_aw.interp (p_cmd), 4000);

      zpb_log.write_statement ('zpb_aw.interp',
                               'AW Statement returned: '||l_return);
      return l_return;
    else
      return dbms_lob.substr(dbms_aw.interp (p_cmd), 4000);
   end if;
end INTERP;

-------------------------------------------------------------------------------
-- INTERPBOOL
--
-- Wrapper around the call the AW with boolean (yes/no) output expected.
-- Will handle conversion within the NLS_LANGUAGE setting (Bug 4058390).
--
-- IN:  p_cmd (varchar2) - The AW boolean command to execute
-- OUT:        boolean   - The output of the the AW command
--
-------------------------------------------------------------------------------
function INTERPBOOL (p_cmd in varchar2)
   return boolean is
      l_return   boolean;
begin
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      zpb_log.write_statement ('zpb_aw.interpbool',
                               'Interpreting AW Statement: '||p_cmd);
   end if;

   if (dbms_aw.eval_number('if nafill('||substr(p_cmd, 5)||
                           ', no) then 1 else 0') = 1) then
      l_return := true;
    else
      l_return := false;
   end if;

   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      if (l_return) then
         zpb_log.write_statement ('zpb_aw.interpbool',
                                  'AW Statement returned true');
       else
         zpb_log.write_statement ('zpb_aw.interpbool',
                                  'AW Statement returned false');
      end if;
   end if;
   return l_return;
end INTERPBOOL;

-------------------------------------------------------------------------------
-- EVAL_TEXT
--
-- Improved version of INTERP, which avoids many OLAP bugs.  No need to
-- use "show" in front of command.  Returns text-based queries, null if NA.
-- -
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function EVAL_TEXT (p_cmd in VARCHAR2)
   return VARCHAR2 is
      l_return varchar2(4000);
begin
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      zpb_log.write_statement ('zpb_aw.eval_text',
                               'Interpreting AW Statement: '||p_cmd);

      l_return := dbms_lob.substr(dbms_aw.eval_text(p_cmd), 4000);

      zpb_log.write_statement ('zpb_aw.eval_text',
                               'AW Statement returned: '||l_return);
      return l_return;
    else
      return dbms_lob.substr(dbms_aw.eval_text(p_cmd), 4000);
   end if;
end EVAL_TEXT;

-------------------------------------------------------------------------------
-- EVAL_NUMBER
--
-- Improved version of INTERP, which avoids many OLAP bugs.  No need to
-- use "show" in front of command.  Returns numeric queries, null if NA.
-- -
-- IN:  p_cmd (varchar2) - The AW command to execute
-- OUT:        varchar2  - The output of the the AW command
--
-------------------------------------------------------------------------------
function EVAL_NUMBER (p_cmd in VARCHAR2)
   return NUMBER is
      l_return NUMBER;
begin
   if (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      zpb_log.write_statement ('zpb_aw.eval_text',
                               'Interpreting AW Statement: '||p_cmd);

      l_return := dbms_aw.eval_number(p_cmd);

      zpb_log.write_statement ('zpb_aw.eval_text',
                               'AW Statement returned: '||l_return);
      return l_return;
    else
      return dbms_aw.eval_number(p_cmd);
   end if;
end EVAL_NUMBER;
------------------------------------------------------------------------------
-- DETACH_ALL
--
-- Detaches all AW's on the session
------------------------------------------------------------------------------
procedure DETACH_ALL is
   l_aws           VARCHAR2(4000);
   l_aw            VARCHAR2(30);
   i               NUMBER;
   j               NUMBER;
begin
   l_aws := INTERP
      ('shw blankstrip(joinchars(joincols (aw (list) '' '')) BOTH)');
   i := 1;
   loop
      j := instr (l_aws, ' ', i);
      if (j = 0) then
         l_aw := substr (l_aws, i);
       else
         l_aw := substr (l_aws, i, j-i);
         i    := j+1;
      end if;

      if (l_aw <> 'EXPRESS') then
         EXECUTE ('aw detach '||l_aw);
      end if;

      exit when j=0;
   end loop;
end DETACH_ALL;

-------------------------------------------------------------------------------
-- GET_ANNOTATION_AW
--
-- Returns the un-qualified (schema not prepended) annotation aw name for
-- the business area.
--
-- IN: p_business_area_id (number) - The Business Area ID.  If null, then
--                                   uses the Business Area in context, or
--                                   the business area currently logged in as
-------------------------------------------------------------------------------
function GET_ANNOTATION_AW
     (p_business_area_id IN ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type)
   return ZPB_BUSINESS_AREAS.ANNOTATION_AW%type is
      l_business_area_id   ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
      l_annotation_aw      ZPB_BUSINESS_AREAS.ANNOTATION_AW%type;
begin
   l_business_area_id := nvl(p_business_area_id,
                             sys_context('ZPB_CONTEXT', 'business_area_id'));
   if (l_business_area_id is null) then
      select BUSINESS_AREA_ID
         into l_business_area_id
         from ZPB_CURRENT_USER_V;
   end if;

   select ANNOTATION_AW
      into l_annotation_aw
      from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = l_business_area_id;

   return l_annotation_aw;
end GET_ANNOTATION_AW;

-------------------------------------------------------------------------------
-- GET_CODE_AW
--
-- Returns the un-qualified (schema not prepended) code aw name for
-- this user.
--
-- IN: p_user (varchar2) - The FND_USER USER_ID
-------------------------------------------------------------------------------
function GET_CODE_AW (p_user in varchar2)
   return varchar2 is
begin
   return FND_PROFILE.VALUE_SPECIFIC('ZPB_CODE_AW_NAME',
                                     to_number(p_user));
end GET_CODE_AW;

-------------------------------------------------------------------------------
-- GET_PERSONAL_AW
--
-- Returns the un-qualified (schema not prepended) personal aw name for
-- this user.
--
-- IN: p_user (varchar2) - The FND_USER USER_ID
-------------------------------------------------------------------------------
function GET_PERSONAL_AW (p_user in varchar2,
                p_business_area_id in ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type)
   return ZPB_USERS.PERSONAL_AW%type is
      l_user               FND_USER.USER_ID%type;
      l_business_area_id   ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
      l_personal_aw        ZPB_USERS.PERSONAL_AW%type;
begin
   l_business_area_id := nvl(p_business_area_id,
                             sys_context('ZPB_CONTEXT', 'business_area_id'));
   if (l_business_area_id is null) then
      select BUSINESS_AREA_ID
         into l_business_area_id
         from ZPB_CURRENT_USER_V;
   end if;

   l_user := to_number(nvl(p_user, sys_context('ZPB_CONTEXT', 'shadow_id')));
   if (l_user is null) then
      select SHADOW_ID
         into l_user
         from ZPB_CURRENT_USER_V;
   end if;

   begin
      select PERSONAL_AW
         into l_personal_aw
         from ZPB_USERS
         where BUSINESS_AREA_ID = l_business_area_id
         and USER_ID = l_user;
   exception
      when no_data_found then
         null;
   end;
   return l_personal_aw;
end GET_PERSONAL_AW;

-------------------------------------------------------------------------------
-- GET_SHARED_AW
--
-- Returns the un-qualified (schema not prepended) shared aw name for
-- the business area.
--
-- IN: p_business_area_id (number) - The Business Area ID.  If null, then
--                                   uses the Business Area in context, or
--                                   the business area currently logged in as
-------------------------------------------------------------------------------
function GET_SHARED_AW
     (p_business_area_id IN ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type)
   return ZPB_BUSINESS_AREAS.DATA_AW%type is
      l_business_area_id   ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
      l_shared_aw          ZPB_BUSINESS_AREAS.DATA_AW%type;
begin
   l_business_area_id := nvl(p_business_area_id,
                             sys_context('ZPB_CONTEXT', 'business_area_id'));
   if (l_business_area_id is null) then
      select BUSINESS_AREA_ID
         into l_business_area_id
         from ZPB_CURRENT_USER_V;
   end if;

   select DATA_AW
      into l_shared_aw
      from ZPB_BUSINESS_AREAS
      where BUSINESS_AREA_ID = l_business_area_id;

   return l_shared_aw;
end GET_SHARED_AW;

-------------------------------------------------------------------------------
-- GET_SCHEMA
--
-- Returns the schema where the aw's reside
-------------------------------------------------------------------------------
function GET_SCHEMA
   return varchar2 is
begin
   if (G_SCHEMA is not null) then
      return G_SCHEMA;
   end if;

   select ORACLE_USERNAME
    into G_SCHEMA
    from FND_ORACLE_USERID a,
      FND_APPLICATION b,
      FND_PRODUCT_INSTALLATIONS c
    where a.ORACLE_ID = c.ORACLE_ID
      and c.APPLICATION_ID = b.APPLICATION_ID
      and b.APPLICATION_SHORT_NAME = 'ZPB';

   return G_SCHEMA;
end GET_SCHEMA;

-------------------------------------------------------------------------------
-- GET_AW_SHORT_NAME
--
-- Procedure to get the AW short name, used in CWM and view names.  If a
-- personal AW is passed in, will use the username.  Otherwise, is the same as
-- the AW actual name
--
-- IN:  p_aw (varchar2) - The actual name of the AW
-- OUT:       varchar2  - The short name of the AW
--
-------------------------------------------------------------------------------
function GET_AW_SHORT_NAME (p_aw in varchar2) return varchar2 is
   l_return varchar2 (16);
   l_aw     varchar2 (64);
begin
   l_aw := p_aw;
   if (instr (l_aw, '.') > 0) then
      l_aw := substr (l_aw, instr (l_aw, '.')+1);
   end if;
   if (instr (l_aw, '_') > 0) then
      l_return := upper (substr (l_aw, 1, instr (l_aw, '_') - 1));
    else
      l_return := upper (l_aw);
   end if;
   return l_return;
end GET_AW_SHORT_NAME;

-------------------------------------------------------------------------------
-- GET_AW_TINY_NAME
--
-- Procedure to get ZPB followed by business area id from ZPB.ZPBDATAXXX
-- Used in CWM and view names.  If a personal AW is passed in,
-- its name will not be changed other than the stripping of schema prefix.
--
-- IN:  p_aw (varchar2) - The actual name of the AW
-- OUT:       varchar2  - ZPB + BA_ID
--
-------------------------------------------------------------------------------
function GET_AW_TINY_NAME (p_aw in varchar2) return varchar2 is
   l_return varchar2 (16);
   j number;
begin

        l_return := get_aw_short_name(p_aw);
        j :=instr(l_return, 'DATA');

        if j> 0 then
                l_return := substr(l_return, 0, j-1) || substr(l_return, j+4, length(l_return) - j - 3);
        end if;

        return l_return;

end GET_AW_TINY_NAME;

-------------------------------------------------------------------------------
-- INITIALIZE
--
-- Initializes the AW session by attaching code, annotation and shared AW for
-- the Business Area specified, and setting context and session-wide
-- parameters
--
-- No commit is done by this procedure
--
-- IN: p_business_area_id NUMBER - The Business Area ID to work under
-------------------------------------------------------------------------------
PROCEDURE INITIALIZE(p_api_version       IN  NUMBER,
                     p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                     p_validation_level  IN  NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                     x_return_status     OUT NOCOPY varchar2,
                     x_msg_count         OUT NOCOPY number,
                     x_msg_data          OUT NOCOPY varchar2,
                     p_business_area_id  IN  NUMBER,
                     p_shadow_id         IN  NUMBER,
                     p_shared_rw         IN  VARCHAR2 := FND_API.G_FALSE,
                     p_annot_rw          IN  VARCHAR2 := FND_API.G_FALSE,
                                         p_detach_all        IN  VARCHAR2 := FND_API.G_TRUE)
   is
    l_api_name      CONSTANT VARCHAR2(20) := G_PKG_NAME||'.initialize';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_code_AW       VARCHAR2(30);
    l_annot_AW      VARCHAR2(30);
    l_schema        VARCHAR2(10);
    l_trace         VARCHAR2(200);
    l_comm          VARCHAR2(200);
    l_user_id       NUMBER;
begin
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version, l_api_name, G_PKG_NAME)
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ZPB_LOG.WRITE (l_api_name||'.begin',
                  'Initializing Bus Area '||p_business_area_id);

   if p_detach_all = FND_API.G_TRUE then
     DETACH_ALL;
   end if;

   if (FND_GLOBAL.USER_ID = -1) then
      l_user_id := p_shadow_id;
    else
      l_user_id := FND_GLOBAL.USER_ID;
   end if;

   ZPB_SECURITY_CONTEXT.INITCONTEXT(to_char(l_user_id),
                                    to_char(p_shadow_id),
                                    to_char(FND_GLOBAL.RESP_ID),
                                    to_char(FND_GLOBAL.SESSION_ID),
                                    p_business_area_id);

   l_schema     := GET_SCHEMA||'.';
   l_code_AW    := l_schema||GET_CODE_AW(p_shadow_id);
   l_annot_AW   := l_schema||GET_ANNOTATION_AW;

   EXECUTE('badline=yes');
   EXECUTE('recursive=yes');
   EXECUTE('oknullstatus=yes');
   EXECUTE('set naskip2 yes');
   EXECUTE('set dividebyzero yes');

   EXECUTE('aw attach '||l_code_AW||' ro last');

   l_trace := FND_PROFILE.VALUE_SPECIFIC('ZPB_SQL_TRACE', l_user_id);
   if (l_trace is not null and instr(l_trace, 'AWLOG:') > 0) then
      l_comm := substr(l_trace, instr(l_trace, 'AWLOG:')+6);
      ZPB_AW.EXECUTE ('CM.LOGFILE = '''||l_comm||'''');
   end if;

   if (p_annot_rw = FND_API.G_TRUE) then
      EXECUTE('aw attach '||l_annot_AW||' rw');
    else
      EXECUTE('aw attach '||l_annot_AW||' ro');
   end if;
   if (p_shared_rw = FND_API.G_TRUE) then
      EXECUTE('aw attach '||l_schema||GET_SHARED_AW||' rw');
      EXECUTE('aw aliaslist '||l_schema||GET_SHARED_AW||' alias shared');
      EXECUTE('aw aliaslist '||l_schema||GET_SHARED_AW||' alias s');
      EXECUTE('aw aliaslist '||l_schema||GET_SHARED_AW||' alias aggaw');
          if (zpb_aw.interpbool('show exists(''LANG'')')) then
                EXECUTE('lmt LANG to '''||FND_GLOBAL.CURRENT_LANGUAGE||'''');
          end if;
    else
      EXECUTE('call pa.attach.shared('''||FND_GLOBAL.USER_ID||''' no)');
   end if;

end INITIALIZE;

-------------------------------------------------------------------------------
-- INITIALIZE_FOR_AC
--
-- Initializes the AW session by attaching code, annotation and shared AW for
-- the business process specified, and setting context and session-wide
-- parameters
--
-- No commit is done by this procedure
--
-- IN: p_analysis_cycle_id NUMBER - The Analysis Cycle to initialize against
-------------------------------------------------------------------------------
PROCEDURE INITIALIZE_FOR_AC(p_api_version       IN  NUMBER,
                            p_init_msg_list     IN  VARCHAR2:= FND_API.G_FALSE,
                            p_validation_level  IN  NUMBER
                                                 := FND_API.G_VALID_LEVEL_FULL,
                            x_return_status     OUT NOCOPY varchar2,
                            x_msg_count         OUT NOCOPY number,
                            x_msg_data          OUT NOCOPY varchar2,
                            p_analysis_cycle_id IN  NUMBER,
                            p_shared_rw         IN  VARCHAR2:=FND_API.G_FALSE,
                            p_annot_rw          IN  VARCHAR2:=FND_API.G_FALSE)
   is
      l_business_area_id ZPB_BUSINESS_AREAS.BUSINESS_AREA_ID%type;
begin

   -- support both analysis cycle ids and current instance ids
   begin
   select BUSINESS_AREA_ID
      into l_business_area_id
      from ZPB_ANALYSIS_CYCLES
      where ANALYSIS_CYCLE_ID = p_analysis_cycle_id;
   exception
      when no_data_found then
                 -- most likely there will be more than row for the same current instance id
         select max(BUSINESS_AREA_ID)
                 into l_business_area_id
                 from ZPB_ANALYSIS_CYCLES
                 where CURRENT_INSTANCE_ID = p_analysis_cycle_id;
   end;

   INITIALIZE (p_api_version       => p_api_version,
               p_init_msg_list     => p_init_msg_list,
               p_validation_level  => p_validation_level,
               x_return_status     => x_return_status,
               x_msg_count         => x_msg_count,
               x_msg_data          => x_msg_data,
               p_business_area_id  => l_business_area_id,
               p_shared_rw         => p_shared_rw,
               p_annot_rw          => p_annot_rw);
end INITIALIZE_FOR_AC;

-------------------------------------------------------------------------------
-- INITIALIZE_USER
--
-- Initializes the AW session by attaching the personal AW for
-- the user specified.  Will initialize the shared AW's
--
-- No commit is done by this procedure
--
-- IN: p_business_area_id NUMBER - The Business Area ID to work under
-------------------------------------------------------------------------------
PROCEDURE INITIALIZE_USER(p_api_version       IN  NUMBER,
                          p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                          p_validation_level  IN  NUMBER
                                                := FND_API.G_VALID_LEVEL_FULL,
                          x_return_status     OUT NOCOPY varchar2,
                          x_msg_count         OUT NOCOPY number,
                          x_msg_data          OUT NOCOPY varchar2,
                          p_user              IN  FND_USER.USER_ID%type,
                          p_business_area_id  IN  NUMBER,
                          p_attach_readwrite  IN  VARCHAR2,
                          p_sync_shared       IN  VARCHAR2,
                                                  p_detach_all            IN  VARCHAR2 :=FND_API.G_FALSE)
   is
    l_api_name      CONSTANT VARCHAR2(30) := G_PKG_NAME||'.initialize_user';
    l_api_version   CONSTANT NUMBER       := 1.0;
    l_code_AW       VARCHAR2(30);
    l_annot_AW      VARCHAR2(30);
    l_pers_AW       VARCHAR2(30);
    l_schema        VARCHAR2(10);
    l_onattach      BOOLEAN;
begin
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version, l_api_name, G_PKG_NAME)
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ZPB_LOG.WRITE (l_api_name||'.begin', 'Initializing User '||p_user);

   if (p_business_area_id is null) then
      null;
   end if;

   if p_detach_all = FND_API.G_TRUE then
           DETACH_ALL;
   end if;

   l_schema     := GET_SCHEMA||'.';
   l_code_AW    := l_schema||GET_CODE_AW(p_user);

   EXECUTE('badline=yes');
   EXECUTE('recursive=yes');
   EXECUTE('oknullstatus=yes');
   EXECUTE('set naskip2 yes');
   EXECUTE('set dividebyzero yes');

   EXECUTE('aw attach '||l_code_AW||' ro last');

   l_onattach := false;

   if not ((sys_context('ZPB_CONTEXT', 'business_area_id') is null or
       sys_context('ZPB_CONTEXT', 'business_area_id') <> p_business_area_id or
       not INTERPBOOL('shw aw(attached ''SHARED'')'))) then

    ZPB_SECURITY_CONTEXT.INITCONTEXT(sys_context('ZPB_CONTEXT','user_id'),
                                       p_user,
                                       sys_context('ZPB_CONTEXT','resp_id'),
                                       sys_context('ZPB_CONTEXT','session_id'),
                                       sys_context('ZPB_CONTEXT',
                                                   'business_area_id'));
      EXECUTE ('DM.PRS.DATAAW = NA');
      if (INTERPBOOL('shw aw(attached ''PERSONAL'')')) then
         select PERSONAL_AW
            into l_pers_AW
            from ZPB_USERS
            where BUSINESS_AREA_ID =
              sys_context('ZPB_CONTEXT', 'business_area_id')
            and USER_ID = p_user;
         if (not INTERPBOOL('shw aw(attached '''||l_pers_aw||''')') or
             INTERPBOOL('shw aw(name ''PERSONAL'') ne aw(name '''||
                        l_pers_aw||''')')) then
            EXECUTE ('aw detach ''PERSONAL''');
            l_onattach := true;
         end if;
      end if;
   end if;

   if (p_attach_readwrite = FND_API.G_TRUE) then
      EXECUTE('call PA.ATTACH.PERSONAL('''||p_user||''' ''rw'')');
    else
      EXECUTE('call PA.ATTACH.PERSONAL('''||p_user||''' ''ro'')');
   end if;

   if (l_onattach) then
      --
      -- ONATTACH needs to be called in the case where the user's personal is
      -- already attached for whatever reason: the DM.PRS structures will
      -- point to the wrong AW in this
      --
      EXECUTE('call PERSONAL!ONATTACH');
   end if;

   if (sys_context('ZPB_CONTEXT', 'business_area_id') is null or
       sys_context('ZPB_CONTEXT', 'business_area_id') <> p_business_area_id or
       not INTERPBOOL('shw aw(attached ''SHARED'')')) then
      INITIALIZE(1.0,
                 p_init_msg_list,
                 p_validation_level,
                 x_return_status,
                 x_msg_count,
                 x_msg_data,
                 p_business_area_id,
                 p_user,
                                 FND_API.G_FALSE,
                                 FND_API.G_FALSE,
                                 FND_API.G_FALSE);
   end if;

   if (p_sync_shared = FND_API.G_TRUE) then
      EXECUTE('call PA.ATTACH.SHARED('''||p_user||''' yes)');
   end if;

end INITIALIZE_USER;

-------------------------------------------------------------------------------
-- clean_workspace
--
-- Procedure detaches the code and shared AWs and resets the ZPB context.
-- Designed to be called by backend programs that initiate an
-- OLAP workspace with full data access.
--
-- No commit is done by this procedure
--
-------------------------------------------------------------------------------
PROCEDURE clean_workspace ( p_api_version       IN NUMBER,
                            p_init_msg_list     IN VARCHAR2,
                            p_validation_level  IN  NUMBER,
                            x_return_status     OUT NOCOPY varchar2,
                            x_msg_count         OUT NOCOPY number,
                            x_msg_data          OUT NOCOPY varchar2)
  IS

     l_api_name      CONSTANT VARCHAR2(15) := 'clean_workspace';
     l_api_version   CONSTANT NUMBER       := 1.0;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT zpb_aw_clean_workspace;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call( l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME)
      THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME||'.'||l_api_name||'.begin',
                           'Begin OLAP workspace cleaning');

   --
   -- Detach all AW's that are attached, except for EXPRESS
   --
   DETACH_ALL;

   ZPB_SECURITY_CONTEXT.INITCONTEXT(null, null, null, null, null);

   DBMS_AW.SHUTDOWN;

   ZPB_LOG.WRITE_STATEMENT(G_PKG_NAME||'.'||l_api_name||'.end',
                           'OLAP workspace has been cleaned');

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get(p_count =>  x_msg_count, p_data  =>  x_msg_data );

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO zpb_aw_clean_workspace;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get(
                                p_count =>  x_msg_count,
                                p_data  =>  x_msg_data
                                );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO zpb_aw_clean_workspace;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get(
                                p_count =>  x_msg_count,
                                p_data  =>  x_msg_data
                                );
   WHEN OTHERS THEN
      ROLLBACK TO zpb_aw_clean_workspace;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
                                p_count =>  x_msg_count,
                                p_data  =>  x_msg_data
                                );

      ZPB_ERROR_HANDLER.HANDLE_EXCEPTION (G_PKG_NAME, l_api_name);
   END clean_workspace;

end ZPB_AW;

/
