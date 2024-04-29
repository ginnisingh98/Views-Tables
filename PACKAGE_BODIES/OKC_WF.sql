--------------------------------------------------------
--  DDL for Package Body OKC_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_WF" as
/*$Header: OKCRWFSB.pls 120.0.12010000.2 2008/10/24 08:02:40 ssreekum ship $*/

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

--
-- Package Variables
--
-- the string to be sent to wf
-- the string should be built in format readable for the package
wf_string varchar2(4000):='';

-- public proc - see in spec
procedure init_wf_string
is
begin
    wf_string:='';
end;

-- public proc - see in spec
procedure init_wf_string(p_wf in varchar2)
is
begin
    wf_string:=p_wf;
end;

-- public proc - see in spec
function get_wf_string return varchar2
is
begin
    return wf_string;
end;

-- public proc - see in spec
procedure init_wf_header(p_head in varchar2)
is
begin
    wf_string:='\h='||p_head;
end;

-- public proc - see in spec
procedure append_wf_string( p_dnum in number,
                            p_dname in varchar2,
                            p_dtype in varchar2,
                            p_dvalue in varchar2
                            )
is
begin
    if upper(p_dtype) not in ('CHAR','NUMBER','DATE') then return; end if;
    wf_string:=wf_string||  '\#='||p_dnum||
                            '\t='||upper(substr(p_dtype,1,1))||
                            '\n='||upper(p_dname)||
                            '\l='||length(p_dvalue)||
                            '\v='||p_dvalue;
end; -- returns parameter name if the parameter has wrong type

-- private func
function get_start_pos( p_num in number,
                        p_wf in varchar2
                        ) return number
is
i number:=1;
l_pos1 number:=1;
l_pos2 number:=1;
len number:=0;
begin
    for i in 2..p_num
    loop
      l_pos1:=instr(p_wf,'\#='||(i-1)||'\t',l_pos1,1);   -- next start point
      l_pos1:=instr(p_wf,'\l=',l_pos1,1)+3;              -- next line position
      l_pos2:=instr(p_wf,'\v=',l_pos1,1);                -- next value position -3
      len:=to_number(substr(p_wf,l_pos1,l_pos2-l_pos1)); -- length of value string
      l_pos1:=l_pos2+len+3;                              -- after value position
    end loop;
    l_pos1:=instr(p_wf,'\#='||p_num||'\t',l_pos1,1);     -- next start point
    return l_pos1;
end;   -- returns 0 if cannot find

-- private func
function get_start_pos( p_num in number
                        ) return number
is
begin
    return get_start_pos(p_num,wf_string);
end;   -- returns 0 if cannot find

-- private func
function get_type_pos(  p_num in number,
                        p_wf in varchar2
                        ) return number
is
l_pos number;
begin
    l_pos:=get_start_pos(p_num,p_wf);
    l_pos:=instr(p_wf,'\#='||to_char(p_num)||'\t',l_pos,1);
    if l_pos = 0 then return 0; -- not found - go out
    end if;
    return (instr(p_wf,'\t=',l_pos,1)+3);
end;   -- returns 0 if cannot find

-- private func
function get_type_pos(  p_num in number
                        ) return number
is
begin
    return get_type_pos(p_num,wf_string);
end;   -- returns 0 if cannot find

-- private func
function get_name_pos(  p_num in number,
                        p_wf in varchar2
                        ) return number
is
l_pos number;
begin
    l_pos:=get_type_pos(p_num,p_wf);
    if l_pos = 0 then return 0; -- not found - go out
    end if;
    return (instr(p_wf,'\n=',l_pos,1)+3);
end;   -- returns 0 if cannot find

-- private func
function get_name_pos(  p_num in number
                        ) return number
is
begin
    return get_name_pos(p_num,wf_string);
end;   -- returns 0 if cannot find

-- private func
function get_length_pos(    p_num in number,
                            p_wf in varchar2
                            ) return number
is
l_pos number;
begin
    l_pos:=get_name_pos(p_num,p_wf);
    if l_pos = 0 then return 0; -- not found - go out
    end if;
    return (instr(p_wf,'\l=',l_pos,1)+3);
end;   -- returns 0 if cannot find

-- private func
function get_length_pos(    p_num in number
                            ) return number
is
begin
    return get_length_pos(p_num,wf_string);
end;   -- returns 0 if cannot find

-- private func
function get_value_pos( p_num in number,
                        p_wf in varchar2
                        ) return number
is
l_pos number;
begin
    l_pos:=get_type_pos(p_num,p_wf);
    if l_pos = 0 then return 0; -- not found - go out
    end if;
    return (instr(p_wf,'\v=',l_pos,1)+3);
end;   -- returns 0 if cannot find

-- private func
function get_value_pos( p_num in number
                        ) return number
is
begin
    return get_value_pos(p_num,wf_string);
end;   -- returns 0 if cannot find

-- private func
function get_header(    p_wf in varchar2
                        ) return varchar2
is
l_num number;
begin
    if instr(p_wf,'\h=') = 0 then return null;
    end if;
    l_num:=instr(p_wf,'\#=1\t',1,1)-4;
    return (substr(p_wf,4,l_num));
end;   -- returns null if cannot find

-- private func
function get_header return varchar2
is
begin
    return get_header(wf_string);
end;   -- returns null if cannot find

-- private func
function get_type(  p_num in number,
                    p_wf in varchar2
                    ) return varchar2
is
l_pos number;
begin
    l_pos:=get_type_pos(p_num, p_wf);
    if l_pos = 0 then return null;
    end if;
    return (substr(p_wf,l_pos,1));
end;   -- returns null if cannot find

-- private func
function get_type(  p_num in number
                    ) return varchar2
is
begin
    return get_type(p_num,wf_string);
end;   -- returns null if cannot find

-- private func
function get_name(  p_num in number,
                    p_wf in varchar2
                    ) return varchar2
is
l_pos1 number;
l_pos2 number;
begin
    l_pos1:=get_name_pos(p_num, p_wf);
    l_pos2:=get_length_pos(p_num, p_wf)-3;
    if l_pos1 = 0 or l_pos2 = 0 then    return  null;
    end if;
    return (substr(p_wf,l_pos1,l_pos2-l_pos1));
end;   -- returns null if cannot find

-- private func
function get_name(  p_num in number
                    ) return varchar2
is
begin
    return get_name(p_num,wf_string);
end;   -- returns null if cannot find
-- private func
function get_length(    p_num in number,
                        p_wf in varchar2
                        ) return number
is
l_pos1 number;
l_pos2 number;
begin
    l_pos1:=get_length_pos(p_num, p_wf);
    l_pos2:=get_value_pos(p_num, p_wf)-3;
    if l_pos1 = 0 or l_pos2 = 0 then    return  0;
    end if;
    return (to_number(substr(p_wf,l_pos1,l_pos2-l_pos1)));
end;   -- returns 0 if cannot find

-- private func
function get_length(    p_num in number
                        ) return number
is
begin
    return get_length(p_num,wf_string);
end;   -- returns 0 if cannot find

-- private func
function get_value( p_num in number,
                    p_wf in varchar2
                    ) return varchar2
is
l_pos number;
l_length number;
begin
    l_pos:=get_value_pos(p_num, p_wf);
    l_length:=get_length(p_num, p_wf);
    if l_pos = 0 or l_length = 0 then    return  null;
    end if;
    return substr(p_wf,l_pos,l_length);
end;   -- returns null if cannot find

-- private func
function get_value( p_num in number
                    ) return varchar2
is
begin
    return get_value(p_num,wf_string);
end;   -- returns null if cannot find

-- public func - see in spec
function Nvalue(p_num in number) return number
is
l_value varchar2(255);
begin
    l_value:=get_value(p_num,wf_string);
    if l_value is not null  then
        if l_value   =  'OKC_API.G_MISS_NUM' then
         return   OKC_API.G_MISS_NUM;
        end if;
        if l_value   =  'NULL'   then
         return   null;
        end if;
    end if;
    return  to_number(l_value);
end; -- returns null if no value

-- public func - see in spec
function Dvalue(p_num in number) return date
is
l_value varchar2(255);
begin
    l_value:=get_value(p_num,wf_string);
    if l_value is not null  then
        if l_value   =  'OKC_API.G_MISS_DATE'   then
         return   OKC_API.G_MISS_DATE;
        end if;
        if l_value   =  'NULL'   then
         return   null;
        end if;
    end if;
    return  to_date(l_value,'YYYY/MM/DD');
end; -- returns null if no value

-- public func - see in spec
function Cvalue(p_num in number) return varchar2
is
l_value varchar2(255);
begin
    l_value:=get_value(p_num,wf_string);
    if l_value is not null  then
        if l_value   =  'OKC_API.G_MISS_CHAR'   then
         return   OKC_API.G_MISS_CHAR;
        end if;
        if l_value   =  'NULL'   then
         return   null;
        end if;
    end if;
    return  l_value;
end; -- returns null if no value

-- public func - see in spec
function build_wf_string(   p_outcome_name in varchar2,
                            p_outcome_tbl in p_outcometbl_type
                            )   return varchar2
is
i number:=0;
begin
    init_wf_string;
    init_wf_header(p_outcome_name);
    for i in 1..p_outcome_tbl.COUNT
    loop
        append_wf_string(   i,
                            p_outcome_tbl(i).name,
                            p_outcome_tbl(i).data_type,
                            p_outcome_tbl(i).value);
    end loop;
    return wf_string;
end;

-- private func
function prebuild_wf_plsql(   p_wf in varchar2
                            )   return varchar2
is
i number:=1;    -- start point
l_plsql varchar2(4000);
l_name varchar2(255);
begin
    l_plsql := get_header(p_wf);
    if l_plsql is null then return null;    -- no header go out
    end if;
    l_plsql := l_plsql || '(';
    while get_type_pos(i,p_wf) <> 0
    loop
        l_name := get_name(i,p_wf);
        if l_name is null then
         l_plsql :=
            l_plsql||'okc_wf.'||get_type(i,p_wf)||'value('||i||'), ';
        else
         l_plsql :=
            l_plsql||l_name||' => okc_wf.'||get_type(i,p_wf)||'value('||i||'), ';
        end if;
        i:=i+1;
    end loop;
    return l_plsql;
end;

-- public func - see in spec
function prebuild_wf_plsql return varchar2
is
begin
    return prebuild_wf_plsql(wf_string);
end;

-- public func - see in spec
function build_wf_plsql(p_prebuilt_wf_plsql in varchar2)   return varchar2
is
l_plsql varchar2(4000);
begin
    if p_prebuilt_wf_plsql is null then return null;  -- no prebuilt - go out
    end if;
    l_plsql := p_prebuilt_wf_plsql;
-- add standard trail
    l_plsql := l_plsql|| 'P_INIT_MSG_LIST => OKC_API.G_FALSE, '||
                         'X_RETURN_STATUS => :V_RETURN_STATUS, '||
                         'X_MSG_COUNT => V_MSG_COUNT, '||
                         'X_MSG_DATA => V_MSG_DATA);';
    l_plsql := 'Begin ' ||l_plsql||' End;';    -- add block frame
    return  l_plsql;
end; -- returns null if wrong

-- public proc
function exec_wf_plsql(p_proc in varchar2) return varchar2
is
x_return_status varchar2(1);
begin
   savepoint exec_plsql_call;
      begin EXECUTE IMMEDIATE P_PROC USING IN OUT x_return_status;
      if (x_return_status in ('E','U')) then
            rollback to exec_plsql_call;
 	   end if;
 	   return x_return_status;
	   exception   when others then
      rollback to exec_plsql_call;
 	   return x_return_status;
	   end;
end;

end okc_wf;

/
