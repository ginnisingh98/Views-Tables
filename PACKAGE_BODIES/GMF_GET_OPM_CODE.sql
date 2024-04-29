--------------------------------------------------------
--  DDL for Package Body GMF_GET_OPM_CODE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GET_OPM_CODE" as
/*       $Header: gmfopmcb.pls 115.3 2004/09/10 06:37:55 anthiyag ship $ */

-----------------------------------------------------------------
-- The pl/sql table to contain all the session generated codes
-----------------------------------------------------------------
type session_code_tab_type is table of op_ship_mst.shipper_code%TYPE
index by binary_integer;

g_session_code_tab     session_code_tab_type;

-------------------------------------------
-- Declare all the cursors here
-------------------------------------------
cursor c_fobc(p_original_code varchar2) is
       select count(*)
       from op_fobc_mst
       where fob_code = p_original_code;

cursor c_term(p_original_code varchar2) is
       select count(*)
       from op_term_mst
       where terms_code = p_original_code;

cursor c_frgt(p_original_code varchar2) is
       select count(*)
       from op_frgt_mth
       where frtbill_mthd = p_original_code;

cursor c_ship(p_original_code varchar2) is
       select count(*)
       from op_ship_mst
       where shipper_code = p_original_code;

--Bug # 3464154 ANTHIYAG Anand Thiyagarajan 05-05-2004	GL Exchange Rate Type Enhancement Start

Cursor c_xrtc (p_original_code varchar2) is
       select count (*)
       from gl_rate_typ
       where rate_type_code = p_original_code;

--Bug # 3464154 ANTHIYAG Anand Thiyagarajan 05-05-2004	GL Exchange Rate Type Enhancement End

----------------------------------------------
-- Declare all the variables here
----------------------------------------------
l_counter               NUMBER:=0;

--------------------------------------------
-- Forward declaration of functions
--------------------------------------------
function code_exists (p_original_code varchar2,
		      p_table_code varchar2) return boolean;
procedure insert_code (p_original_code varchar2);


function generate_code (p_original_code varchar2,
			p_table_code    varchar2)
			return varchar2 is
  l_count_code 	          number;
  l_length                number;
  l_original_code         varchar2(4);
begin
  if    (p_table_code='FOBC') then
     open c_fobc(p_original_code);
     fetch c_fobc into l_count_code;
     close c_fobc;
  elsif (p_table_code='TERM') then
     open c_term(p_original_code);
     fetch c_term into l_count_code;
     close c_term;
  elsif (p_table_code='FRGT') then
     open c_frgt(p_original_code);
     fetch c_frgt into l_count_code;
     close c_frgt;
  elsif (p_table_code='SHIP') then
     open c_ship(p_original_code);
     fetch c_ship into l_count_code;
     close c_ship;

--Bug # 3464154 ANTHIYAG Anand Thiyagarajan 05-05-2004	GL Exchange Rate Type Enhancement Start

  elsif (p_table_code='XRTC') then
     open c_xrtc (p_original_code);
     fetch c_xrtc into l_count_code;
     close c_xrtc;

--Bug # 3464154 ANTHIYAG Anand Thiyagarajan 05-05-2004	GL Exchange Rate Type Enhancement End

  else
     -- Raise an invalid table type passed
     -- Return error
     return('-1');
  end if;

  if ((l_count_code = 0) and (code_exists(p_original_code,p_table_code))) then
    l_counter:=0;
    return (p_original_code);
  end if;

  l_counter:=l_counter+1;

  if (l_counter > 999) then
    -- Raise an error, no unique code generated
    --return;
    return('-2');
  end if;
  --------------------------
  -- Length of counter
  --------------------------
  l_length:=length(l_counter);

  -------------------------
  -- Make a new code, rtrim is used so that the string does not go beyond 4 byetes
  --------------------------
  l_original_code:=rtrim(substrb(p_original_code,1,4-l_length))||to_char(l_counter);
  ------------------------------------
  -- Give a recursive call to function
  ------------------------------------
  return generate_code(l_original_code,p_table_code);
end generate_code;


--------------------------------------------------------------------
-- Function to find if the code exists in pl/sql table
--------------------------------------------------------------------
function code_exists (p_original_code varchar2,
	              p_table_code   varchar2)
		      return boolean is
l_table_index   number;
begin
  if ( p_table_code in ('FOBC','TERMS', 'XRTC'))  then
    return true;
  else
    if g_session_code_tab.last is not null then
      l_table_index:=g_session_code_tab.first;
      while l_table_index is not null
        loop
	  if (g_session_code_tab(l_table_index)=p_original_code) then
            return false;
          end if;
	  l_table_index:=g_session_code_tab.next(l_table_index);
        end loop;
      insert_code(p_original_code);
      return true;
    else
      insert_code(p_original_code);
      return true;
    end if;
  end if;
end code_exists;

----------------------------------------------------------
-- Procedure to store generated code in the same session
----------------------------------------------------------
procedure insert_code(p_original_code varchar2)  is
l_table_index	binary_integer;
  begin
    if g_session_code_tab.last is null then
      l_table_index:=1;
    else
      l_table_index:=g_session_code_tab.last+1;
   end if;
   g_session_code_tab(l_table_index) :=p_original_code;
  end insert_code;


----------------------------------------------------------
-- delete  plsql table, called from the form at the time
-- of commit or exit form
----------------------------------------------------------
function delete_session_codes_tab
         return number is
begin
  g_session_code_tab.delete;
  return  1;
exception
  when no_data_found then
   return  1;
  when others then
   return -1;
end delete_session_codes_tab;


----------------------------------------------------------
-- delete   a row in plsql table, called from the form at
-- clear_record
----------------------------------------------------------
function delrow_session_tab(p_original_code varchar2)
                            return number is
l_table_index         binary_integer;
begin
l_table_index:=g_session_code_tab.first;
  while l_table_index <= g_session_code_tab.LAST
    loop
      if (g_session_code_tab(l_table_index)=p_original_code) then
        g_session_code_tab.delete(l_table_index);
	return 1;
      end if;
      l_table_index:=g_session_code_tab.next(l_table_index);
    end loop;
return -1;
end delrow_session_tab;
end gmf_get_opm_code;

/
