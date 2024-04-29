--------------------------------------------------------
--  DDL for Package Body ZPB_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_UTIL_PVT" AS
/* $Header: ZPBUTILB.pls 120.6 2007/12/04 14:36:01 mbhat noship $ */

G_PKG_NAME CONSTANT VARCHAR2(15) := 'zpb_util_pvt';

function compare_queries(p_dataAw IN varchar2,
                          p_first_query IN varchar2,
                          p_second_query IN varchar2,
                          p_line_dim IN varchar2) return integer
AS
  l_api_name         CONSTANT VARCHAR2(30) := 'compare_queries';
  l_vs               varchar2(100);
  l_dataAwQual       varchar2(70);
  l_first_superset   boolean;
  l_second_superset  boolean;
  l_equal            integer;
begin
  l_dataAwQual := p_dataAw ||'!';
  -- call the first query
  zpb_aw_status.get_status(p_dataAw,p_first_query);
  -- get the valuseset name
  l_vs := '&' || 'obj(prp ''LASTQUERYVS'' '||''''||l_dataAwQual||p_line_dim ||''')';
  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'valueset name:' ||l_vs);
  -- initialize
  zpb_aw.execute('push oknullstatus '||l_dataAwQual ||p_line_dim);
  zpb_aw.execute('oknullstatus=y');
  if (not zpb_aw.interpbool('shw exists(''l_temp_vs'')')) then
    zpb_aw.execute(' dfn  l_temp_vs  valueset '||l_dataAwQual ||p_line_dim|| ' aw ' ||p_dataAw);
  end if;

  -- lmt the first valueset to the first query
  zpb_aw.execute('lmt '|| l_dataAwQual ||'l_temp_vs  to '|| l_vs );

  -- generate the valuseset for the second query
  zpb_aw_status.get_status(p_dataAw,p_second_query);
  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr w 40 values('||l_dataAwQual ||'l_temp_vs)'),1,254));
  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,substr(zpb_aw.interp('rpr w 40  values('||l_vs||')'),1,254));

  -- check if the two valusesets are identical
  l_first_superset := zpb_aw.interpbool('shw inlist(values('||l_dataAwQual||'l_temp_vs)'|| ' values('||l_vs||'))');
  l_second_superset := zpb_aw.interpbool('shw inlist(values('||l_dataAwQual||l_vs||')'|| ' values(l_temp_vs))');

  if l_first_superset then
    if l_second_superset then
       l_equal := 0;
    else
       l_equal := 1;
    end if;
  else
    if  l_second_superset then
       l_equal := 2;
    else
       l_equal := 3;
    end if;
  end if;

  return l_equal;
exception
  when others then
    l_equal := 0;
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90)
);
    return l_equal;
end;

PROCEDURE compare_dim_members(p_dim_name IN varchar2,
                              p_first_query IN varchar2,
                              p_second_query IN varchar2,
                              x_equal OUT NOCOPY integer) IS
  l_api_name         CONSTANT VARCHAR2(30) := 'compare_line_members';
  l_dataAw           varchar2(30);
  l_dataAwQual       varchar2(70);
  l_temp_vs                  varchar2(100);
  l_line_dim         zpb_cycle_model_dimensions.dimension_name%type;

begin
  l_dataAw := zpb_aw.get_schema||'.'||zpb_aw.get_shared_aw;
  l_dataAwQual := l_dataAw ||'!';
  zpb_aw.execute('aw attach '|| l_dataAw || '  first  ');
  zpb_aw.execute('aw attach '|| zpb_aw.get_schema||'.'||zpb_aw.get_code_aw(fnd_global.user_id) || '  ro');

  zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'Dimension:' ||l_dataAwQual|| p_dim_name);

  x_equal := compare_queries(l_dataAw,p_first_query,p_second_query,p_dim_name);
  -- cleanup and return
  zpb_aw.execute('delete  l_temp_vs  aw ' ||l_dataAw);
  zpb_aw.execute('pop oknullstatus '||l_dataAwQual ||p_dim_name);
  zpb_aw.execute('aw detach '|| l_dataAw );
  zpb_aw.execute('aw detach '|| zpb_aw.get_schema||'.'||zpb_aw.get_code_aw(fnd_global.user_id) );

exception
  when others then
    x_equal := 0;
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));

end compare_dim_members;


-- b 4948928
-- Set_Expired_Users
--   sets expired user to temporary table to be used as list for notification
-- IN
--   p_session_id Number
--   P_User_Name  VARCHAR2
-- OUT

procedure set_expired_users(p_session_id in number, p_user_name in VARCHAR2)

is

begin

  INSERT INTO ZPB_WF_INACTIVE_USERS_GT(
            SESSION_ID,
            USER_NAME

  )
  VALUES(
            p_session_id,
            p_user_name
  );

return;

exception
  when others then
    raise;

end Set_Expired_Users;



--
-- String_To_UserTable
--   Converts a comma/space delimited string of users into a UserTable
-- IN
--   P_UserList  VARCHAR2
-- OUT
-- RETURN
--   P_UserTable WF_DIRECTORY.UserTable
--

procedure String_To_UserTable (p_UserList  in VARCHAR2,
                               p_UserTable out NOCOPY WF_DIRECTORY.UserTable)
is

  c1          integer;
  u1          integer := 0;
  l_userList  varchar2(32000);
  l_users     WF_DIRECTORY.UserTable;
  l_sessionID number;



begin


  if (p_UserList is not NULL) then

    -- Set sessionID for expired users;
   select SYS_CONTEXT('USERENV','SESSIONID')  into l_sessionID From dual;
    --
    -- Substring and insert users into UserTable
    --
    l_userList := ltrim(p_UserList);
    <<UserLoop>>
    loop
      c1 := instr(l_userList, ',');
        if (c1 = 0) then

          -- b4948928 check if valid user. if  not do not add it to table.
          -- add it to expired list
          if wf_directory.useractive(l_userList) = TRUE then
             p_UserTable(u1) := l_userList;
             u1 := u1 + 1;
          else
             set_expired_users(l_sessionID, l_userList);
          end if;

          exit;

        else
          -- b4948928 check if valid user. if  not do not add it to table.
          -- add it to expired list
          if wf_directory.useractive(substr(l_userList, 1, c1-1)) = TRUE then
              p_UserTable(u1) := substr(l_userList, 1, c1-1);
              u1 := u1 + 1;
          else
              set_expired_users(l_sessionID, substr(l_userList, 1, c1-1));
          end if;

        end if;

      --u1 := u1 + 1;
      l_userList := ltrim(substr(l_userList, c1+1));
    end loop UserLoop;
  end if;

end String_To_UserTable;

--
-- This procedure is written mainly to handle user names which include
-- 'Space' in them viz 'GOPI NATH'
--  Here, for converting role_users String to Table we call our private procedure
--  instead of WF_DIRECTORY.String_To_UserTable
-- IN
--   role_name     - AdHoc role name
--   role_users    - Space or comma delimited list of apps-based users
--                      or adhoc users
-- OUT
--
procedure AddUsersToAdHocRole(role_name         in varchar2,
                              role_users        in  varchar2)
is
  l_users WF_DIRECTORY.UserTable;

begin

  if (role_users is NOT NULL) then
    ZPB_UTIL_PVT.String_To_UserTable (p_UserList=>AddUsersToAdHocRole.role_users,
                         p_UserTable=>l_users);

    WF_DIRECTORY.AddUsersToAdHocRole2(role_name=>AddUsersToAdHocRole.role_name,
                         role_users=>l_users);
  end if;

exception
  when others then
    wf_core.context('ZPB_UTIL_PVT', 'AddUsersToAdHocRole',
        role_name, '"'||role_users||'"');
    raise;
end AddUsersToAdHocRole;

----------------------------------------------------------------------------
-- CLOBToChar - Function that converts a CLOB to a VARCHAR2, unless the
--              CLOB is greater than 3900 characters, in which case it
--              returns null.  Used for optimization in SV.GET.SOLVEDEF
----------------------------------------------------------------------------
function CLOBToChar(p_clob     in CLOB) return VARCHAR2
   is
begin
   if (length(p_clob) < 3900) then
      return to_char(p_clob);
    else
      return null;
   end if;
end CLOBToChar;

--
-- This procedure is to populate model_equation and calc_parameters columns
-- into SV.DEF.VAR variable .The same cant be done in olap program like other
-- columns as these two columns are are of CLOB data type and hence OLAP cant
-- recognize them. DBMS_AW.INTERPCLOB( ) procedure takes the clob parameter and
-- executes it as a olap command. This procedure is been called from
-- SV.GET.SOLVEDEF program on make effective
-- Bug 4036563 .
--

PROCEDURE populate_SVDEFVAR
   (p_ac_id IN ZPB_SOLVE_MEMBER_DEFS.ANALYSIS_CYCLE_ID%TYPE)
   is
      CURSOR records_cur IS
         SELECT model_equation,calc_parameters,member
            FROM zpb_solve_member_defs
            WHERE analysis_cycle_id = p_ac_id
              and source_type = 1200;

      l_modelEquation    ZPB_SOLVE_MEMBER_DEFS.MODEL_EQUATION%TYPE;
      l_calcParam        ZPB_SOLVE_MEMBER_DEFS.CALC_PARAMETERS%TYPE;
      l_modelEquationres ZPB_SOLVE_MEMBER_DEFS.MODEL_EQUATION%TYPE;
      l_calcParamres     ZPB_SOLVE_MEMBER_DEFS.CALC_PARAMETERS%TYPE;
      offset             number := 1;
      opRec              zpb_solve_member_defs%ROWTYPE;
      i                  number;
      indx               number;
begin
   ZPB_AW.execute('push SV.LN.DIM');

   for opRec in records_cur loop
      ZPB_AW.EXECUTE('lmt SV.LN.DIM to '''||opRec.Member||'''');
      l_modelEquationRes := opRec.model_equation ;
      l_calcParamRes     := opRec.CALC_PARAMETERS;

      if (ZPB_AW.INTERPBOOL('shw SV.DEF.VAR(SV.DEF.PROP.DIM ''EQUATION'') eq NA')) then
       dbms_lob.CREATETEMPORARY(l_modelEquation, true);
       --iterating through each clob to replace ' with \'

       offset := dbms_lob.instr(l_modelEquationres, '\');
       while (offset <> 0)
       loop
         l_modelEquationres := dbms_lob.substr(l_modelEquationres,offset-1,1)||
            '\'||dbms_lob.substr(lob_loc => l_modelEquationres,
                                 offset => offset);
         offset := dbms_lob.instr(l_modelEquationres, '\', offset+2);
       end loop;
       offset := dbms_lob.instr(l_modelEquationres, '''');

       while (offset <> 0)
       loop
         l_modelEquationres := dbms_lob.substr(l_modelEquationres,offset-1,1)||
            '\'||dbms_lob.substr(lob_loc => l_modelEquationres,
                                 offset => offset);
         offset := dbms_lob.instr(l_modelEquationres, '''', offset+2);
       end loop;

       l_modelEquation :=
          'SV.DEF.VAR(SV.DEF.PROP.DIM ''EQUATION'') = joinlines( ';
       indx := 1;
       loop
         i := dbms_lob.instr(l_modelEquationres, ')', indx+3800);
         if (i > 0) then
            l_modelEquation := l_modelEquation || ' - '||fnd_global.newline()||
               ''''||dbms_lob.substr(l_modelEquationres,i-indx+1,indx)||'''';
            indx := i+1;
          else
            l_modelEquation := l_modelEquation || ' - '||fnd_global.newline()||
               ''''||dbms_lob.substr(l_modelEquationres,4000,indx)||'''';
            exit;
         end if;
       end loop;
       l_modelEquation := l_modelEquation || ')';
       l_modelEquationres := DBMS_AW.INTERPCLOB(l_modelEquation);
      end if;
      if (ZPB_AW.INTERPBOOL('shw SV.DEF.VAR(SV.DEF.PROP.DIM ''CALC_PARAMS'') eq NA')) then
       -- for calc_parameters column
       dbms_lob.CREATETEMPORARY(l_calcParam, true);

       offset := dbms_lob.instr(l_calcParamRes, '\');
       while (offset <> 0)
        loop
         l_calcParamres := dbms_lob.substr(l_calcParamres, offset-1, 1)||
            '\'||dbms_lob.substr(lob_loc => l_calcParamres, offset => offset);
         offset := dbms_lob.instr(l_calcParamres, '\', offset+2);
        end loop;
       offset := dbms_lob.instr(l_calcParamres, '''');

       while (offset <> 0)
       loop
          l_calcParamres := dbms_lob.substr(l_calcParamres, offset-1, 1)||
             '\'||dbms_lob.substr(lob_loc => l_calcParamres, offset => offset);
          offset := dbms_lob.instr(l_calcParamres, '''', offset+2);
       end loop;

       offset := dbms_lob.instr(l_calcParamres, fnd_global.newline());
       while (offset <> 0)
       loop
          if (dbms_lob.substr(l_calcParamres, offset-1, 1) <> '-')
             then
             l_calcParamres := dbms_lob.substr(l_calcParamres, offset-1, 1)||
                '-'||dbms_lob.substr(lob_loc => l_calcParamres, offset => offset);
          end if;
          offset := dbms_lob.instr(l_calcParamres, fnd_global.newline(), offset+2);
       end loop;


       l_calcParam :=
          'SV.DEF.VAR(SV.DEF.PROP.DIM ''CALC_PARAMS'') = joinlines( ';
       indx := 1;
       loop
          i := dbms_lob.instr(l_calcParamres, ')', indx+3800);
          if (i > 0) then
             l_calcParam := l_calcParam || ' - '||fnd_global.newline()||
                ''''||dbms_lob.substr(l_calcParamres,i-indx+1,indx)||'''';
             indx := i+1;
           else
             l_calcParam := l_calcParam || ' - '||fnd_global.newline()||
                ''''||dbms_lob.substr(l_calcParamres,4000,indx)||'''';
             exit;
          end if;
       end loop;
       l_calcParam := l_calcParam || ')';
       l_calcParamres :=  DBMS_AW.INTERPCLOB(l_calcParam);
      end if;
   end loop;
   zpb_aw.execute('pop SV.LN.DIM ');
end populate_SVDEFVAR ;

-- This procedure modified the olap page pool size session parameter
-- setting_id corresponds to ZPB profile parameters.  If the corresponding profile
-- is not set, the page pool size is unchanged
-- 1 = ZPB_OPPS_DATA_MOVE
-- 2 = ZPB_OPPS_DATA_SOLVE
-- 3 = ZPB_OPPS_AW_BUILD
procedure set_opps(setting_id in number, user_id in number) is

        l_api_name      CONSTANT VARCHAR2(30) := 'set_opps';
        l_callbase              varchar2(64);
        l_callnumber    varchar2(64);
        l_call                  varchar2(64);

begin
        l_callbase := 'alter session set olap_page_pool_size=';

        if setting_id = ZPB_UTIL_PVT.ZPB_OPPS_DATA_MOVE then
                l_callnumber:=FND_PROFILE.VALUE_SPECIFIC('ZPB_OPPS_DATA_MOVE', user_id);
        end if;

        if setting_id = ZPB_UTIL_PVT.ZPB_OPPS_DATA_SOLVE then
                l_callnumber:=FND_PROFILE.VALUE_SPECIFIC('ZPB_OPPS_DATA_SOLVE', user_id);
        end if;

        if setting_id = ZPB_UTIL_PVT.ZPB_OPPS_AW_BUILD then
                l_callnumber:=FND_PROFILE.VALUE_SPECIFIC('ZPB_OPPS_AW_BUILD', user_id);
        end if;

        l_call := l_callbase || l_callnumber;

        if l_callnumber is not null then
                execute immediate l_call;
                zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'executed ' ||l_call);
        end if;

exception
  when others then
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
end set_opps;

-- This function returns the current olap page pool size
function get_opps return number is
        l_api_name      CONSTANT VARCHAR2(30) := 'get_opps';
        return_val varchar2(32);
begin
        select value into return_val
        from v$parameter
        where name='olap_page_pool_size';

        return to_number(return_val);

exception
  when others then
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
        return to_number(return_val);
end get_opps;

procedure set_opps_spec(setting in number) is
        l_api_name      CONSTANT VARCHAR2(30) := 'set_opps_spec';
        l_callbase              varchar2(64);
        l_call                  varchar2(64);
begin
        if setting is not null then
                l_callbase := 'alter session set olap_page_pool_size=';
                l_call := l_callbase || to_char(setting);
                execute immediate l_call;
                zpb_log.write_statement(G_PKG_NAME||'.'||l_api_name,'executed ' ||l_call);
        end if;
exception
  when others then
    zpb_log.write_event(G_PKG_NAME,to_char(sqlcode) ||':'|| substr(sqlerrm,1,90));
end set_opps_spec;

procedure exec_ddl(p_cmd varchar2) is

begin
   execute immediate p_cmd;
end exec_ddl;

end ZPB_UTIL_PVT;

/
