--------------------------------------------------------
--  DDL for Package Body ZPB_AW_LOADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZPB_AW_LOADER_PVT" as
/* $Header: zpbawloader.plb 120.0.12010.2 2005/12/23 06:15:55 appldev noship $ */

m_ascii_nl constant number := ascii(fnd_global.local_chr(10));
m_curr_obj varchar2(32);

-------------------------------------------------------------------------------
-- CALL_AW - Calls an AW command and returns the result
--
-- IN:  p_cmd (varchar2) - The command to execute
-- OUT: The result of the command
-------------------------------------------------------------------------------
function CALL_AW(p_cmd in varchar2) return varchar2
   is
begin
   return dbms_lob.substr(dbms_aw.interp (p_cmd));
end CALL_AW;

-------------------------------------------------------------------------------
-- CALL_BOOL
--
-- Wrapper around the call the AW with boolean (yes/no) output expected.
-- Will handle conversion within the NLS_LANGUAGE setting (Bug 4058390).
--
-- IN:  p_cmd (varchar2) - The AW boolean command to execute
-- OUT:        boolean   - The output of the the AW command
--
-------------------------------------------------------------------------------
function CALL_BOOL (p_cmd in varchar2)
   return boolean is
begin
   return (dbms_aw.interp (p_cmd) = dbms_aw.interp ('shw yes'));
end CALL_BOOL;

-------------------------------------------------------------------------------
-- ATTACH_AW: Attaches the AW rw
--
-- IN: p_app_name (varchar2) - The application short name
--     p_aw       (varchar2) - Name of the AW
-------------------------------------------------------------------------------
procedure ATTACH_AW(p_app_name in varchar2,
                    p_aw       in varchar2)
   is
      l_ret    varchar2(16);
      l_schema varchar2(16);
      l_aw     varchar2(32);
begin

   select ORACLE_USERNAME
    into l_schema
    from FND_ORACLE_USERID a,
      FND_APPLICATION b,
      FND_PRODUCT_INSTALLATIONS c
    where a.ORACLE_ID = c.ORACLE_ID
      and c.APPLICATION_ID = b.APPLICATION_ID
      and b.APPLICATION_SHORT_NAME = upper(p_app_name);

l_aw := l_schema||'.'||p_aw;

   --
   -- If this function is called from development, then the AW is attached
   -- under ALIAS of p_aw.  If from ADPATCH, then this AW is not attached.
   -- Note that, in development, we are in as ZPB, whereas in ADPATCH, we
   -- enter as APPS.
   --
   dbms_aw.execute ('awwaittime = 200');
   if (CALL_BOOL('shw aw (attached '''||p_aw||''')') and
       (not CALL_BOOL('shw aw (rw '''||p_aw||''')'))) then
      dbms_aw.execute ('aw detach '||p_aw);
   end if;
   if (not CALL_BOOL('shw aw (attached '''||p_aw||''')')) then
      dbms_aw.execute ('aw attach '||l_aw||' rw wait');
   end if;
   dbms_aw.execute ('commas = no');
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
   if (CALL_BOOL('shw exists ('''||p_object_name||''')')) then
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
-- DELETE_OBJECT - Deletes the specified object from the current AW

-- IN: p_object_name           (varchar2) - Name of object to delete
--
-------------------------------------------------------------------------------
procedure DELETE_OBJECT(p_object_name   in varchar2)
        is
begin
   if (CALL_BOOL('shw exists ('''||p_object_name||''')')) then
      dbms_aw.execute('delete ' || p_object_name);
   end if;
end DELETE_OBJECT;

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
      i       number;
      l_value varchar2(32);
      l_size  number;
begin
   i := 0;
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

      if (not CALL_BOOL ('shw isvalue ('||m_curr_obj||' '||l_value||')')) then
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
      templob CLOB;
begin
   templob := 'program;';
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
      i       number;
      l_value varchar2(32);
      l_size  number;
begin
   dbms_aw.execute('lmt '||m_curr_obj||' to null');
   i := 0;
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

end ZPB_AW_LOADER_PVT;

/
