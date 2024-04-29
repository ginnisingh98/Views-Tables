--------------------------------------------------------
--  DDL for Package Body MSD_AW_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_AW_LOADER_PVT" as
/* $Header: msdawloaderb.pls 120.0 2005/05/25 20:00:46 appldev noship $ */

m_ascii_nl number := 10;
m_curr_obj varchar2(32);

-------------------------------------------------------------------------------
-- CALL_AW - Calls an AW command and returns the result
--
-- IN:  p_cmd (varchar2) - The command to execute
-- OUT: The result of the command
-------------------------------------------------------------------------------
function CALL_AW(p_cmd in varchar2) return varchar2
   is
      l_return varchar2(4000);
      l_pos    number          := 1;
begin
   l_return := dbms_aw.interp (p_cmd);

   if (l_return is null or length (l_return) = 0) then
      return l_return;
   end if;
   loop
      if (ascii (substr (l_return, l_pos)) = 10) then
         l_pos := l_pos + 1;
       else
         exit;
      end if;
   end loop;
   return substr (l_return, l_pos);
end CALL_AW;

-------------------------------------------------------------------------------
-- ATTACH_AW: Attaches the AW rw
--
-- IN: p_schema (varchar2) - Schema of the AW to attach
--     p_aw     (varchar2) - Name of the AW
-------------------------------------------------------------------------------
procedure ATTACH_AW(p_schema in varchar2,
                    p_aw     in varchar2)
   is
      l_ret  varchar2(16);
      l_aw   varchar2(32) := p_schema||'.'||p_aw;
begin
   --
   -- If this function is called from development, then the AW is attached
   -- under ALIAS of p_aw.  If from ADPATCH, then this AW is not attached.
   -- Note that, in development, we are in as msd, whereas in ADPATCH, we
   -- enter as APPS.
   --
   if (upper (CALL_AW('shw aw (attached '''||p_aw||''')')) = 'YES' and
       upper(CALL_AW('shw aw (rw '''||p_aw||''')')) = 'NO') then
      dbms_aw.execute ('aw detach '||p_aw);
   end if;
   if (upper (CALL_AW('shw aw (attached '''||p_aw||''')')) <> 'YES') then
      dbms_aw.execute ('aw attach '||l_aw||' rw wait');
   end if;
end ATTACH_AW;

-------------------------------------------------------------------------------
-- CREATE_OBJECT - Creates the object of specified name, type and attribute
--
-- IN: p_object_name       (varchar2) - Name of the object to create
--     p_object_type       (varchar2) - Type of the object (ie. VARIABLE)
--     p_object_attributes (varchar2) - Attributes of object (ie. <DIM1, DIM2>)
--     p_object_ld         (varchar2) - The LD (description) of the object
--
-------------------------------------------------------------------------------
procedure CREATE_OBJECT(p_object_name       in varchar2,
                        p_object_type       in varchar2,
                        p_object_attributes in varchar2,
                        p_object_ld         in varchar2)
   is
      l_ret   varchar2(16);
begin
   if (upper (CALL_AW('shw exists ('''||p_object_name||''')')) = 'YES') then
      if (p_object_type = 'DIMENSION') then
         dbms_aw.execute ('cns '||p_object_name);
         dbms_aw.execute ('property delete all');
       else
         dbms_aw.execute ('dlt '||p_object_name);
         dbms_aw.execute ('dfn '||p_object_name||' '||p_object_type||' '||
                          p_object_attributes);
      end if;
    else
      dbms_aw.execute ('dfn '||p_object_name||' '||p_object_type||' '||
                       p_object_attributes);
   end if;
   dbms_aw.execute ('ld '||p_object_ld);
   m_curr_obj := p_object_name;
end CREATE_OBJECT;

-------------------------------------------------------------------------------
-- LOAD_DIMENSION_INT
--
-- IN: p_dimension_size (number) - The size of the integer dimension
-------------------------------------------------------------------------------
procedure LOAD_DIMENSION_INT(p_dimension_size in number)
   is
      l_size  number;
      l_diff  number;
begin
   l_size := to_number(CALL_AW('shw obj(dimmax '''||m_curr_obj||''')'));
   if (l_size < p_dimension_size) then
      dbms_aw.execute('mnt '||m_curr_obj||' add '||
                      (p_dimension_size - l_size));
    elsif (l_size > p_dimension_size) then
      dbms_aw.execute('mnt '||m_curr_obj||' delete last '||
                      (l_size - p_dimension_size));
   end if;
end LOAD_DIMENSION_INT;

-------------------------------------------------------------------------------
-- LOAD_DIMENSION_VALUES - Loads values of a text dimension
--
-- IN: p_dimension_values - Hash of index/value pairs
--
-------------------------------------------------------------------------------
procedure LOAD_DIMENSION_VALUES(p_dimension_values in DIM_VALUES)
   is
      i       number := 0;
      l_value varchar2(32);
      l_size  number;
begin
   loop
      if not p_dimension_values.exists(i) then
         exit;
      end if;
      l_value := p_dimension_values(i);

      --
      -- If not a conjoint, add sorrounding parenthesis:
      --
      if (instr (l_value, '<') <> 1) then
         l_value := ''''||l_value||'''';
      end if;

      if (upper (CALL_AW ('shw isvalue ('||m_curr_obj||' '||l_value||')'))
          = 'NO') then
         dbms_aw.execute ('mnt '||m_curr_obj||' add '||l_value||'');
      end if;
      dbms_aw.execute('mnt '||m_curr_obj||' move '||l_value||' after '||i);
      i := i + 1;
   end loop;

   --
   -- Remove extra entries:
   --
   l_size := to_number(CALL_AW ('shw obj(dimmax '''||m_curr_obj||''')'));
   if (l_size > i) then
      dbms_aw.execute ('lmt '||m_curr_obj||' to last '||(l_size - i));
      dbms_aw.execute ('mnt '||m_curr_obj||' delete values('||m_curr_obj||')');
   end if;

end LOAD_DIMENSION_VALUES;

-------------------------------------------------------------------------------
-- LOAD_FORMULA - Builds a formula
--
-- IN: p_formula - The formula body
--
-------------------------------------------------------------------------------
procedure LOAD_FORMULA(p_formula in varchar2)
   is
begin
   dbms_aw.execute ('cns '||m_curr_obj);
   dbms_aw.execute('eq '||p_formula);
end LOAD_FORMULA;

-------------------------------------------------------------------------------
-- LOAD_MODEL - Builds a model
--
-- IN: p_model - The model body
--
-------------------------------------------------------------------------------
procedure LOAD_MODEL(p_model in varchar2)
   is
begin
   dbms_aw.execute ('cns '||m_curr_obj);
   dbms_aw.execute('model;'||p_model||';end');
end LOAD_MODEL;

-------------------------------------------------------------------------------
-- LOAD_PROGRAM - Builds a program
--
-- IN: p_program - The program body
--
-------------------------------------------------------------------------------
procedure LOAD_PROGRAM(p_program in CLOB)
   is
      templob CLOB := 'program;';
begin
   dbms_aw.execute ('cns '||m_curr_obj);
   dbms_lob.append(templob, p_program);
   dbms_lob.append(templob, ';end');
   templob := dbms_aw.interpclob(templob);
end LOAD_PROGRAM;

-------------------------------------------------------------------------------
-- LOAD_PROPERTIES - Loads the properties of an object
--
-- IN: p_properties - Hash of property index/value pairs
--
-------------------------------------------------------------------------------
procedure LOAD_PROPERTIES(p_properties in PROP_VALUES)
   is
      l_key varchar2(32);
begin
   dbms_aw.execute ('cns '||m_curr_obj);
   l_key := p_properties.FIRST;
   while (l_key is not null)
   loop
      dbms_aw.execute('prp '''||l_key||''' '||p_properties(l_key));
      l_key := p_properties.NEXT(l_key);
   end loop;
end LOAD_PROPERTIES;

-------------------------------------------------------------------------------
-- LOAD_VALUESET - Loads the values of a valueset object
--
-- IN: p_dim_values - Hash of dimension values
--
-------------------------------------------------------------------------------
procedure LOAD_VALUESET(p_dimension_values in DIM_VALUES)
   is
      i       number := 0;
      l_value varchar2(32);
      l_size  number;
begin
   dbms_aw.execute('lmt '||m_curr_obj||' to null');
   loop
      if not p_dimension_values.exists(i) then
         exit;
      end if;
      l_value := p_dimension_values(i);
      dbms_aw.execute('lmt '||m_curr_obj||' add '||l_value);
      i := i + 1;
   end loop;

end LOAD_VALUESET;

-------------------------------------------------------------------------------
-- UPDATE_AW - Updates the AW
--
-------------------------------------------------------------------------------
procedure UPDATE_AW
   is
begin
   dbms_aw.execute ('upd');
end UPDATE_AW;

end msd_AW_LOADER_PVT;

/
