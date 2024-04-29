--------------------------------------------------------
--  DDL for Package Body CS_KNOWLEDGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KNOWLEDGE_PVT" AS
/* $Header: csvkbb.pls 120.4.12010000.2 2009/07/20 13:39:06 gasankar ship $ */

/*
 *
 * +======================================================================+
 * |                Copyright (c) 1999 Oracle Corporation                 |
 * |                   Redwood Shores, California, USA                    |
 * |                        All rights reserved.                          |
 * +======================================================================+
 *
 *   FILENAME
 *
 *   PURPOSE
 *     Creates the package body for CS_Knowledge_Pvt
 *   NOTES
 *     Usage: start
 *   HISTORY
 *   18-OCT-1999 A. WONG Created
 *   18-DEC-2001 hali    Modified
 *   26-FEB-2003 BAYU    Fix bug 2821275 KMR9INT : EXCEPTION ON SEARCH
 *                         WITH PARTICULAR KEYWORD STRING
 *   02-APR-2003 DTIAN   Fixed bug 2885439 EMAIL CENTER TO KM SEARCH
 *                         INTEGRATION RETURNS NO SEARCH RESULTS
 *   22-JUL-2003 SPENG   For 11.5.10 - Added handling for Exact Phrase
 *                         search method in Text query rewrite routines.
 *                         Also cleaned up formatting and implementation
 *                         of some query rewrite related routine
 *   08-AUG-2003 klou (LEAK)
 *               1. Fix security problem that the security check is only
 *                 in the text section. Secruity check should embrace the
 *                 entire query text.
 *               2. Fix malformat query text when search text is null.
 *   26-Aug-2003 MKETTLE Changed to use CS_KB_SOLUTION_PVT.Create_Solution
 *   26-Aug-2003 klou (TEXTNUM)
 *               1. Modify Build_Solution_Text_Query to merge the NUMBER
 *                  section in the text section.
 *   27-Aug-2003 klou (SRCHEFF)
 *               1. Add Process_Frequency_Keyword procedure.
 *               2. Modify Build_Intermedia_Query to incorporate the use of
 *                  keyword frequency profile.
 *   08-Sep-2003 klou (PRODFILTER)
 *               1. Filter generic solutions if products are used.
 *   20-Oct-2003 klou (SMARTSCORE)
 *               1. Add logic to include score from product/platfor/category filters.
 *   27-oct-2003 klou
 *               1. Fix bug 3217731.
 *   03-Nov-2003 klou
 *               1. Fix bug 3231550: solution search using statements returns
 *                  solutions outside of the security group.
 *   03-Dec-2003 klou
 *               1. Fix bug 3209009: handling special character %.
 *   10-Dec-2003 MKETTLE
 *               Added changes for Create_Set_And_Elements for Public Create api
 *               to make it compliant with security for 11.5.10
 *   12-Jan-2004 KLOU
 *               Increate varchar size in Remove_Braces, Remove_Parenthesis,
 *               to avoid the error of buffer string too small.
 *   23-Jan-2004 ALAWANG
 *               1> Fix bug 3328595
 *   02-Feb-2004 KLOU (3398078)
 *               1. Remove extra filtering condition in Find_Sets_Matching.
 *   18-Feb-2004 KLOU (3341248)
 *               1. Add implementation for Build_Related_Stmt_Text_Query.
 *   01-Mar-2004 KLOU (3468629)
 *               1. Modify Build_Statement_Text_Query such that it does not
 *                  call Build_Solution_Text_Query. Instead, it should have
 *                  its own implementation.
 *   06-Apr-2004 KLOU (3534598)
 *               1. Modify Process_Frequency_Keyword to handle
 *                  nls_numeric_characters format.
 *   05-24-2004 KLOU
 *               1. Add Build_SR_Text_Query.
 *   09-02-2004 KLOU
 *               1. Fix bug 3832320.
 *   09-04-2004 KLOU
 *               1. Add implementation for overloaded Build_SR_Text_Query.
 *   04-05-2005 HMEI
 *               1. Add exact phrase (" ") syntax processing:
 *                  Build_Keyword_Query, Parse_Keywords, Append_Query_Term
 *   04-05-2005 mkettle Added Find_Sets_Matching2 for bugfix 4304939
 *   17-May-2005 mkettle Reomved obs ele_eles code
 *   18-May-2005 MKETTLE Cleanup - removed unused apis and cursors
 *               Apis removed in 115.130:
 *               Move_Element_Order
 *               Change_Element_Assoc
 *               Change_Set_Type_Links
 *               Add_Element_To_Set_Ord
 *               Find_Eles_Matching
 *               Find_Eles_Related
 *               Find_Sets_Related
 *   29-Jul-2005 speng - R12. Modifed Find_Sets_Matching and
 *                        Find_Sets_Matching2 to add an additional set_number
 *                        column to the search query select list.
 *   25-Oct-2005 klou (3983696)
 *               - Fix bug 3983696.
 *   19-May-2006 klou (5217204)
 *               - Escape % that is prefixed or postfixed with by a symbol that
 *                 will be parsed as blank by the text parser. This fix only supports
 *                 the out-of-box symbols and has a drawback to ignore wildcard
 *                 expansion if customers define a symobol as printjoins character,
 *                 e.g. we will escape .% to .\% because the dot (.)
 *                 will be parsed as blank by the text parser.  But, if it is
 *                 printjoin character, the parser will consider it as alphanumeric;
 *                 thus, .% is actually meant for searching any word starting with
 *                 a dot. With this fix, this feature (non out-of-box) will be
 *                 ignored.
 *   26-JUL-2006 klou (5412688)
 *               - Fix bug 5412688 that was caused by bug fix for 5217204.
 *   06-MAY-2009 mmaiya 12.1.3 Project: Search within attachments
 */


Type WeakCurType IS REF CURSOR;

--
-- Check if required element type is missing for given set type
-- returns 'T' if error
--
FUNCTION Is_Required_Type_Missing(
  p_set_type_id   in  number,
  p_ele_def_tbl   in  cs_kb_ele_def_tbl_type
) return varchar2 is
  l_types_tbl cs_kb_number_tbl_type := cs_kb_number_tbl_type();
  i1 pls_integer;
  i2 pls_integer;
  l_count pls_integer;
  l_type_id number;
  cursor l_types_csr is
    select element_type_id
    from cs_kb_set_ele_types
    where set_type_id = p_set_type_id
    and optional_flag = 'N';
begin
  if(p_set_type_id is null or p_ele_def_tbl is null) then
    goto error_found;
  end if;

  -- get required types
  i1 := 1;
  for recType in l_types_csr loop
    l_types_tbl.EXTEND;
    l_types_tbl(i1) := recType.element_type_id;
    i1 := i1 + 1;
  end loop;

  -- for each required type
  i2 := l_types_tbl.FIRST;
  while i2 is not null loop
  --for i in l_types_tbl.FIRST..l_types_tbl.LAST loop

    -- if found, check it and continue
    -- if not found, set error and exit
    l_count := 0;
    i1 := p_ele_def_tbl.FIRST;
    while i1 is not null loop

      if(p_ele_def_tbl(i1).element_id is not null) then
        select element_type_id into l_type_id
          from cs_kb_elements_b
          where element_id = p_ele_def_tbl(i1).element_id;
        if(l_types_tbl(i2)=l_type_id) then
          l_count := 1;
        end if;

      elsif(p_ele_def_tbl(i1).element_type_id is not null) then
        if(p_ele_def_tbl(i1).element_type_id=l_types_tbl(i2)) then
          l_count := 1;
        end if;
      else
        fnd_message.set_name('CS','CS_KB_C_MISS_PARAM');
        return FND_API.G_TRUE;
      end if;
      i1 := p_ele_def_tbl.NEXT(i1);
    end loop;
    if(l_count = 0) then
      return FND_API.G_TRUE;
    end if;

    i2 := l_types_tbl.NEXT(i2);
  end loop;


  return FND_API.G_FALSE;

  <<error_found>>
  return FND_API.G_TRUE;

end Is_Required_Type_Missing;

/*
--
-- Set fnd.missing char to null
--
PROCEDURE Miss_Char_To_Null(
  p_char in varchar2,
  x_char OUT NOCOPY varchar2
) is
begin
  if(p_char =FND_API.G_MISS_CHAR) then
    x_char := null;
  else
    x_char := p_char;
  end if;
end Miss_Char_To_Null;
*/


--
-- Given a table of num 15,
-- return a string of the numbers separated by p_separator
--
FUNCTION Concat_Ids(
  p_id_tbl in cs_kb_number_tbl_type,
  p_separator in varchar2
) return varchar2 is
  l_str varchar2(1990) := null;
  i1 pls_integer;
begin

  if p_id_tbl is not null and p_id_tbl.COUNT > 0 then
    i1 := p_id_tbl.FIRST;
    while i1 is not null loop

      if i1= p_id_tbl.FIRST then
        l_str := to_char(p_id_tbl(i1));
      else
        l_str := l_str|| p_separator|| to_char(p_id_tbl(i1));
      end if;
      i1 := p_id_tbl.NEXT(i1);
    end loop;
  end if;
  return l_str;

end Concat_Ids;

FUNCTION Concat_Ids(
  p_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
  p_separator in varchar2
) return varchar2 is
  l_str varchar2(1990) := null;
  i1 pls_integer;
begin

  if p_id_tbl is not null and p_id_tbl.COUNT > 0 then
    i1 := p_id_tbl.FIRST;
    while i1 is not null loop

      if i1= p_id_tbl.FIRST then
        l_str := to_char(p_id_tbl(i1));
      else
        l_str := l_str|| p_separator|| to_char(p_id_tbl(i1));
      end if;
      i1 := p_id_tbl.NEXT(i1);
    end loop;
  end if;
  return l_str;

end Concat_Ids;
--
-- Check set_type - element_type is valid
-- Valid params:
--   (set id, null, ele id, null)
--   (set id, null, null, ele type)
--   (null, set type, ele id, null)
--   (null, set type, null, ele type)
--
FUNCTION Is_Set_Ele_Type_Valid(
  p_set_id in number := null,
  p_set_type_id in number :=null,
  p_ele_id in number :=null,
  p_ele_type_id in number :=null
) return varchar2 is
  l_count pls_integer;
begin

  if(p_set_id > 0) then
    if(p_ele_id > 0) then
      select count(*) into l_count
        from cs_kb_set_ele_types se,
             cs_kb_sets_b s,
             cs_kb_elements_b e
        where se.set_type_id = s.set_type_id
        and se.element_type_id = e.element_type_id
        and s.set_id = p_set_id
        and e.element_id = p_ele_id;

    elsif(p_ele_type_id > 0) then
      select count(*) into l_count
        from cs_kb_set_ele_types se,
             cs_kb_sets_b s
        where se.set_type_id = s.set_type_id
        and s.set_id = p_set_id
        and se.element_type_id = p_ele_type_id;
    end if;

  elsif(p_set_type_id >0) then
    if(p_ele_id >0) then
      select count(*) into l_count
        from cs_kb_set_ele_types se,
             cs_kb_elements_b e
        where se.set_type_id = p_set_type_id
        and e.element_id = p_ele_id
        and se.element_type_id = e.element_type_id;

    elsif(p_ele_type_id >0) then
      select count(*) into l_count
        from cs_kb_set_ele_types se
        where se.set_type_id = p_set_type_id
        and se.element_type_id = p_ele_type_id;
    end if;
  end if;

  if(l_count >0) then return G_TRUE;
  else                return G_FALSE;
  end if;
end Is_Set_Ele_Type_Valid;


--
-- Check if set type exist
--
FUNCTION Does_Set_Type_Exist(
  p_set_type_id in number
) return varchar2 is
  l_count pls_integer;
begin
 select count(*) into l_count
    from cs_kb_set_types_b
    where set_type_id = p_set_type_id;
  if(l_count <1) then return G_FALSE;
  else                return G_TRUE;
  end if;
end Does_Set_Type_Exist;

--
-- Does ele type exist
--
FUNCTION Does_Element_Type_Exist(
  p_ele_type_id in number
) return varchar2 is
  l_count pls_integer;
begin
  -- if type exists
  select count(*) into l_count
    from cs_kb_element_types_b
    where element_type_id = p_ele_type_id;
  if(l_count <1) then return G_FALSE;
  else                return G_TRUE;
  end if;
end Does_Element_Type_Exist;

--
-- Get sysdate, fnd user and login
--
PROCEDURE Get_Who(
  x_sysdate  OUT NOCOPY date,
  x_user_id  OUT NOCOPY number,
  x_login_id OUT NOCOPY number
) is
begin
  x_sysdate := sysdate;
  x_user_id := fnd_global.user_id;
  x_login_id := fnd_global.login_id;
end Get_Who;

--
-- return ":a1,:a2,:a3"
--
FUNCTION Bind_Var_String(
  p_start_num   in number,
  p_size        in number
) return varchar2 is
  i1 pls_integer;
  l_end_num pls_integer;
  l_string varchar2(1000):=null;
begin

  l_end_num := p_start_num + p_size -1;

  for i1 in p_start_num..l_end_num loop
    if(i1=p_start_num) then
      l_string := ':a'||to_char(i1);
    else
       l_string := l_string || ',:a'||to_char(i1);
    end if;
  end loop;
  return l_string;

exception
  when others then
    return null;
end Bind_Var_String;


--
-- Simply check if given elements
-- already exist in any larger set.
--

/* New - uses bind variables */
FUNCTION Do_Elements_Exist_In_Set (
  p_ele_id_tbl  in cs_kb_number_tbl_type)
return varchar2 is
  l_csr    CS_Knowledge_PUB.general_csr_type;
  l_sid    number(15);
  l_total pls_integer :=0;
  l_count  pls_integer := 0;
  l_sqlstr1 varchar2(100) :=
    ' select set_id, count(*) count from cs_kb_set_eles c '||
    ' where element_id in (';
  l_eids   varchar2(1000);
  l_sqlstr2 varchar2(100) := ') group by set_id ';
  l_bind_ids varchar2(1000) := null;
  l_csr_num integer;
  i1 pls_integer; -- temporary variable
BEGIN

--  l_eids := Concat_Ids(p_ele_id_tbl, ',');
--  if l_eids is null then
--    return G_TRUE; --i.e. should abort insert/create set.
--  end if;
  if ( p_ele_id_tbl is null OR p_ele_id_tbl.COUNT<=0 ) then
    return G_TRUE; --i.e. should abort insert/create set.
  end if;

  -- convert element_ids into bind vars
  l_bind_ids := Bind_Var_String(1, p_ele_id_tbl.COUNT);

  -- open cursor
  l_csr_num := dbms_sql.open_cursor;

  -- parse dynamic sql
  dbms_sql.parse(l_csr_num,
                 l_sqlstr1 || l_bind_ids || l_sqlstr2,
                 dbms_sql.NATIVE);

  -- define return columns from dynamic sql cursor select
  dbms_sql.define_column(l_csr_num, 1, l_sid);
  dbms_sql.define_column(l_csr_num, 2, l_count);

  -- Bind element_ids to bind variables in dynamic sql
  if(p_ele_id_tbl is not null and p_ele_id_tbl.COUNT>0) then
    for i in 1..p_ele_id_tbl.COUNT loop
      dbms_sql.bind_variable(l_csr_num, ':a'||to_char(i), p_ele_id_tbl(i));
    end loop;
  end if;

  -- Execute dynamic sql
  i1 := dbms_sql.execute(l_csr_num);

  l_total := 0;
  WHILE( dbms_sql.fetch_rows(l_csr_num)>0)
  LOOP
    dbms_sql.column_value(l_csr_num, 1, l_sid);
    dbms_sql.column_value(l_csr_num, 2, l_count);
    if(l_count >= p_ele_id_tbl.COUNT) then
      l_total := l_total + 1;
    end if;
  END LOOP;
  dbms_sql.close_cursor(l_csr_num);


--  OPEN l_csr FOR l_sqlstr1 || l_eids || l_sqlstr2;
--  LOOP
--    FETCH l_csr INTO l_sid, l_count;
--    EXIT when l_csr%NOTFOUND;
--    if(l_count >= p_ele_id_tbl.COUNT) then
--      l_total := l_total + 1;
--    end if;
--  END LOOP;

--  CLOSE l_csr;

  if(l_total<1) then --set not exist yet
    return G_FALSE;
  else
    return G_TRUE;
  end if;


END Do_Elements_Exist_In_Set;


--
-- Given table of object_code and select_ids
-- return table of select name in sel_name_tbl
-- return null in the entry if cannot find specified object
-- return OKAY_STATUS if okay, ERROR_STATUS if error
--
FUNCTION Get_External_Obj_Names(
  p_obj_code_tbl in jtf_varchar2_table_100,
  p_sel_id_tbl   in jtf_varchar2_table_100,
  p_sel_name_tbl OUT NOCOPY jtf_varchar2_table_1000
) return number is
  l_sel_name_tbl jtf_varchar2_table_1000
    := jtf_varchar2_table_1000();
  l_query varchar2(1000);
  l_csr   WeakCurType;
  l_id    varchar2(300);
  l_name  varchar2(1000);
  i1 pls_integer;
  cursor l_jtfobj_csr(c_objcode in varchar2) is
    select select_id, select_name, from_table, where_clause
    from jtf_objects_vl
    where object_code = c_objcode;
  l_jtfobj_rec l_jtfobj_csr%ROWTYPE;
begin
  -- Check params
  if(p_obj_code_tbl is null or p_sel_id_tbl is null or
     p_obj_code_tbl.COUNT<=0 or
     p_sel_id_tbl.COUNT < p_obj_code_tbl.COUNT) then
    return ERROR_STATUS;
  end if;

  l_sel_name_tbl.EXTEND(p_obj_code_tbl.COUNT);
  i1 := p_obj_code_tbl.FIRST;
  while i1 is not null loop
  --for i1 in p_obj_code_tbl.FIRST..p_obj_code_tbl.LAST loop

    --select jtf object definition
    open l_jtfobj_csr(p_obj_code_tbl(i1));
    fetch l_jtfobj_csr into l_jtfobj_rec;
    close l_jtfobj_csr;

    --construct query
    l_query := 'select distinct ' || l_jtfobj_rec.select_id || ', '||
        l_jtfobj_rec.select_name || ' from ' ||
        l_jtfobj_rec.from_table || ' where '||
        l_jtfobj_rec.select_id || '=:1';

   --||FND_GLOBAL.local_chr(39)||p_sel_id_tbl(i1) || FND_GLOBAL.local_chr(39);

    if(l_jtfobj_rec.where_clause is not null) then
      l_query := l_query || ' and '||l_jtfobj_rec.where_clause;
    end if;

    --query name where id = given id
    open l_csr for l_query using p_sel_id_tbl(i1);
    fetch l_csr into l_id, l_name;
    close l_csr;
/*
    execute immediate l_query
      into l_id, l_name
      using p_sel_id_tbl(i1);
*/
    --add name to table
    l_sel_name_tbl(i1) := l_name;

    i1 := p_obj_code_tbl.NEXT(i1);
  end loop;
  p_sel_name_tbl := l_sel_name_tbl;
--dbms_output.put_line(to_char(p_sel_name_tbl.COUNT));
  return OKAY_STATUS;

end Get_External_Obj_Names;

--
-- Add external link
--
PROCEDURE Add_External_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_usage_code          in  varchar2,
  p_id                  in  number,
  p_object_code         in  varchar2,
  p_other_id_tbl            in  cs_kb_number_tbl_type,
  p_other_code_tbl          in  cs_kb_varchar100_tbl_type
) is
  l_api_name    CONSTANT varchar2(30)   := 'Add_External_Links';
  l_api_version CONSTANT number         := 1.0;
  l_ele_type_id number;
  i1    pls_integer;
  l_count pls_integer;
  l_id number;
begin
  savepoint Add_External_Links_Pvt;

  if not FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --

  -- Check params
  if(p_usage_code is null or p_id is null or
     p_object_code is null or
     p_other_id_tbl is null or p_other_code_tbl is null or
     p_other_id_tbl.COUNT <> p_other_code_tbl.COUNT) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  i1 := p_other_id_tbl.FIRST;
  while i1 is not null loop

    if(p_other_id_tbl(i1) is not null or p_other_code_tbl(i1) is not null)
    then

      if( p_usage_code = 'CS_KB_SET' ) then
        l_id := CS_KB_SET_LINKS_PKG.Create_Set_Link(
          null, --link type
          p_object_code,
          p_id,
          p_other_id_tbl(i1));

--      elsif(p_usage_code = 'CS_KB_SET_TYPE' ) then
--        l_id := CS_KB_SET_TYPE_LINKS_PKG.Create_Set_Type_Link(
--          null, --link type
--          p_object_code,
--          p_id,
--          p_other_id_tbl(i1),
--          p_other_code_tbl(i1));
      elsif(p_usage_code = 'CS_KB_ELEMENT' ) then
        l_id := CS_KB_ELEMENT_LINKS_PKG.Create_Element_Link(
          null, --link type
          p_object_code,
          p_id,
          p_other_id_tbl(i1));

      elsif(p_usage_code = 'CS_KB_ELEMENT_TYPE' ) then
        l_id := CS_KB_ELE_TYPE_LINKS_PKG.Create_Element_Type_Link(
          null, --link type
          p_object_code,
          p_id,
          p_other_id_tbl(i1),
          p_other_code_tbl(i1));
      end if;
    end if;

    if(not l_id>0) then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    i1 := p_other_id_tbl.NEXT(i1);
  end loop;


-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Add_External_Links_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Add_External_Links_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Add_External_Links_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
          l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

end Add_External_Links;


--
-- Delete or update rows in Ele Type Links table
-- Given linkids, new ele type ids.
-- If new id <= 0, remove link
--
PROCEDURE Change_Ele_Type_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_link_id_tbl         in  cs_kb_number_tbl_type,
  p_ele_type_id_tbl      in  cs_kb_number_tbl_type
)is
  l_api_name    CONSTANT varchar2(30)   := 'Change_Ele_Type_Links';
  l_api_version CONSTANT number         := 1.0;
  l_ele_type_id number;
  i1    pls_integer;
  l_count pls_integer;
begin
  savepoint Change_Ele_Type_Links_PVT;

  if not FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --

  -- Check params
  if(p_link_id_tbl is null or p_ele_type_id_tbl is null or
     p_link_id_tbl.COUNT =0 or p_ele_type_id_tbl.COUNT =0 or
     p_ele_type_id_tbl.COUNT < p_link_id_tbl.COUNT) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;

  end if;

  i1 := p_link_id_tbl.FIRST;
  while i1 is not null loop
    l_ele_type_id := p_ele_type_id_tbl(i1);

    if(p_link_id_tbl(i1) is not null) then
      if(l_ele_type_id is not null and l_ele_type_id>0) then
        select count(*) into l_count
          from cs_kb_element_types_b
          where element_type_id = l_ele_type_id;
        if(l_count<1) then

          if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
           fnd_message.set_name('CS', 'CS_KB_C_INVALID_ELE_TYPE_ID');
           fnd_msg_pub.Add;
          end if;

          raise FND_API.G_EXC_ERROR;
        end if;

        update cs_kb_ele_type_links set
          element_type_id = l_ele_type_id
          where link_id = p_link_id_tbl(i1);
      else
        delete from cs_kb_ele_type_links
          where link_id = p_link_id_tbl(i1);
      end if;
    end if;
    i1 := p_link_id_tbl.NEXT(i1);
  end loop;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Change_Ele_Type_Links_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Change_Ele_Type_Links_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Change_Ele_Type_Links_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
          l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

end Change_Ele_Type_Links;

--
-- Delete or update rows in Set Links table
-- Given linkids, new setids.
-- If new set id <= 0, remove link
--
PROCEDURE Change_Set_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_link_id_tbl         in  cs_kb_number_tbl_type,
  p_set_id_tbl          in  cs_kb_number_tbl_type
)is
  l_api_name    CONSTANT varchar2(30)   := 'Change_Set_Links';
  l_api_version CONSTANT number         := 1.0;
  l_set_id number;
  i1    pls_integer;
  l_count pls_integer;
begin
  savepoint Change_Set_Links_PVT;

  if not FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --

  -- Check params
  if(p_link_id_tbl is null or p_set_id_tbl is null or
     p_link_id_tbl.COUNT =0 or p_set_id_tbl.COUNT =0 or
     p_set_id_tbl.COUNT < p_link_id_tbl.COUNT) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  i1 := p_link_id_tbl.FIRST;
  while i1 is not null loop
    l_set_id := p_set_id_tbl(i1);

    if(p_link_id_tbl(i1) is not null) then
      if(l_set_id is not null and l_set_id>0) then
        select count(*) into l_count
          from cs_kb_sets_b
          where set_id = l_set_id;
        if(l_count<1) then

          if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
           fnd_message.set_name('CS', 'CS_KB_C_INVALID_SET_ID');
           fnd_msg_pub.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

        update cs_kb_set_links set
          set_id = l_set_id
          where link_id = p_link_id_tbl(i1);
      else
        delete from cs_kb_set_links
          where link_id = p_link_id_tbl(i1);
      end if;
    end if;
    i1 := p_link_id_tbl.NEXT(i1);
  end loop;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Change_Set_Links_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Change_Set_Links_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Change_Set_Links_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
          l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

end Change_Set_Links;

--
-- Delete link to set or change link to new element id
--
PROCEDURE Change_Element_To_Sets(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_element_id          in  number,
  p_set_id_tbl          in  cs_kb_number_tbl_type,
  p_new_ele_id_tbl      in  cs_kb_number_tbl_type
)is
  l_api_name    CONSTANT varchar2(30)   := 'Change_Element_To_Sets';
  l_api_version CONSTANT number         := 1.0;
  l_element_id number;
  i1    pls_integer;
  l_count pls_integer;
  l_retnum number(5);

begin
  savepoint Change_Element_To_Sets_PVT;

  if not FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --

  -- Check params
  if(p_set_id_tbl is null or p_new_ele_id_tbl is null or
     p_set_id_tbl.COUNT =0 or p_new_ele_id_tbl.COUNT =0 or
     p_new_ele_id_tbl.COUNT < p_set_id_tbl.COUNT) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;

    raise FND_API.G_EXC_ERROR;
  end if;

  i1 := p_set_id_tbl.FIRST;
  while i1 is not null loop
    l_element_id := p_new_ele_id_tbl(i1);

    if(p_set_id_tbl(i1) is not null) then

      if(l_element_id is not null and l_element_id>0) then

        --valid new element id
        select count(*) into l_count
          from cs_kb_elements_b
          where element_id = l_element_id;
        if(l_count<1) then
          if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
           fnd_message.set_name('CS', 'CS_KB_C_INVALID_ELE_ID');
           fnd_msg_pub.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

        -- new ele and old ele cannot be in same set
        select count(*) into l_count
          from cs_kb_set_eles
          where set_id = p_set_id_tbl(i1)
          and element_id = l_element_id;
        if(l_count>0) then
          if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
           fnd_message.set_name('CS', 'CS_KB_C_INVALID_ELE_ID');
           fnd_msg_pub.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

        -- add new element, then delete old ele.
        -- checking of type compatibility and required types handled by apis

        l_retnum := Add_Element_To_Set(
          p_ele_id => l_element_id,
          p_set_id => p_set_id_tbl(i1));
        if(l_retnum <> OKAY_STATUS) then
          fnd_msg_pub.Add;
          raise FND_API.G_EXC_ERROR;
        end if;

        l_retnum := Del_Element_From_Set(
          p_ele_id => p_element_id,
          p_set_id => p_set_id_tbl(i1));
        if(l_retnum <> OKAY_STATUS) then
          fnd_msg_pub.Add;
          raise FND_API.G_EXC_ERROR;
        end if;


        -- update
        --update cs_kb_set_eles set
        --  element_id = l_element_id
        --  where set_id = p_set_id_tbl(i1);
      else
        l_retnum := CS_Knowledge_Pvt.Del_Element_From_Set(
          p_ele_id => p_element_id,
          p_set_id => p_set_id_tbl(i1));
        if(l_retnum = ERROR_STATUS) then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
        end if;
      end if;

    end if;

    i1 := p_set_id_tbl.NEXT(i1);
  end loop;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Change_Element_To_Sets_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Change_Element_To_Sets_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Change_Element_To_Sets_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
          l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

end Change_Element_To_Sets;

--
-- Delete or update rows in Element Links table
-- Given linkids, new elementids.
-- If new element id <= 0, remove link
--
PROCEDURE Change_Element_Links(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit              in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_link_id_tbl         in  cs_kb_number_tbl_type,
  p_element_id_tbl          in  cs_kb_number_tbl_type
)is
  l_api_name    CONSTANT varchar2(30)   := 'Change_Element_Links';
  l_api_version CONSTANT number         := 1.0;
  l_element_id number;
  i1    pls_integer;
  l_count pls_integer;
begin
  savepoint Change_Element_Links_PVT;

  if not FND_API.Compatible_API_Call(
                l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --

  -- Check params
  if(p_link_id_tbl is null or p_element_id_tbl is null or
     p_link_id_tbl.COUNT =0 or p_element_id_tbl.COUNT =0 or
     p_element_id_tbl.COUNT < p_link_id_tbl.COUNT) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  i1 := p_link_id_tbl.FIRST;
  while i1 is not null loop
    l_element_id := p_element_id_tbl(i1);

    if( p_link_id_tbl(i1) is not null) then
      if(l_element_id is not null and l_element_id>0) then

        select count(*) into l_count
          from cs_kb_elements_b
          where element_id = l_element_id;
        if(l_count<1) then
          if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
           fnd_message.set_name('CS', 'CS_KB_C_INVALID_ELE_ID');
           fnd_msg_pub.Add;
          end if;
          raise FND_API.G_EXC_ERROR;
        end if;

        update cs_kb_element_links set
          element_id = l_element_id
          where link_id = p_link_id_tbl(i1);
      else
        delete from cs_kb_element_links
          where link_id = p_link_id_tbl(i1);
      end if;
    end if;
    i1 := p_link_id_tbl.NEXT(i1);
  end loop;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Change_Element_Links_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Change_Element_Links_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Change_Element_Links_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
          l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

end Change_Element_Links;

FUNCTION Del_Element_From_Set(
  p_ele_id in number,
  p_set_id in number,
  p_update_sets_b in varchar2
) return number is
  l_date date;
  l_user number;
  l_login number;


  l_retnum number;
  l_ele_type_id number;
  l_set_type_id number;
  l_optional_flag varchar2(1);
  l_count pls_integer;

  cursor cur_eles( c_sid in number) is
    select element_id
    from cs_kb_set_eles
    where set_id = c_sid;

  cursor cur_set is
    select s.set_type_id
    from cs_kb_sets_vl s
    where s.set_id = p_set_id;
  l_set_rec cur_set%ROWTYPE;

begin
  -- Check params
  if( not p_set_id > 0 ) or (not p_ele_id > 0) then
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    goto error_found;
  end if;


  --if ele is the only required type in set, cannot delete

  select element_type_id into l_ele_type_id
    from cs_kb_elements_b
    where element_id = p_ele_id;

  open cur_set;
  fetch cur_set into l_set_rec;
  close cur_set;

 begin

   select optional_flag into l_optional_flag
     from cs_kb_set_ele_types
     where set_type_id = l_set_rec.set_type_id
     and element_type_id = l_ele_type_id;

   exception
     when NO_DATA_FOUND THEN
        NULL;
 end;






  if(l_optional_flag = 'N') then
    select count(*) into l_count
      from cs_kb_set_eles se, cs_kb_elements_b e
      where se.set_id = p_set_id
      and se.element_id = e.element_id
      and e.element_type_id = l_ele_type_id;
    if(l_count <=1) then
      fnd_message.set_name('CS', 'CS_KB_C_REQ_TYPE_ERR');
      goto error_found;
    end if;
  end if;

  --delete a row in set_eles
  delete from cs_kb_set_eles
    where element_id = p_ele_id
    and set_id = p_set_id;

  -- change update date of set
  -- and update change_history of set


  Get_Who(l_date, l_user, l_login);

  if(p_update_sets_b = 'T') then

    update cs_kb_sets_b set
     last_update_date = l_date,
     last_updated_by = l_user,
     last_update_login = l_login
     where set_id = p_set_id;
  end if;

  -- touch related sets to update interMedia index
  update cs_kb_sets_tl set
    positive_assoc_index = 'c',
    negative_assoc_index = 'c',
    composite_assoc_index = 'c',
    composite_assoc_attach_index = 'c' --12.1.3
    where set_id = p_set_id;


  return OKAY_STATUS;
  <<error_found>>
  return ERROR_STATUS;

end Del_Element_From_Set;

-- Add element
FUNCTION Add_Element_To_Set(
  p_ele_id in number,
  p_set_id in number,
  p_assoc_degree in number := CS_Knowledge_PUB.G_POSITIVE_ASSOC,
  p_update_sets_b in varchar2
) return number is
  l_count  pls_integer;
  l_date  date;
  l_created_by number;
  l_login number;
  l_order number(15);
  cursor cur_eles( c_sid in number) is
    select element_id
    from cs_kb_set_eles
    where set_id = c_sid; /* can add: and element_id <> p_ele_id */
begin

  -- Check params
  if( not p_set_id > 0 ) or (not p_ele_id > 0) then
    fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
    goto error_found;
  end if;

  -- check if element exists
  select count(*) into l_count
      from cs_kb_elements_b
      where element_id = p_ele_id;
  if(l_count=0) then
    fnd_message.set_name('CS', 'CS_KB_C_INVALID_ELE_ID');
    goto error_found;
  end if;

  -- check if row already exists
  select count(*) into l_count
      from cs_kb_set_eles
      where set_id = p_set_id
      and element_id = p_ele_id;
  if(l_count>0) then
    fnd_message.set_name('CS', 'CS_KB_C_ELE_EXIST_ERR');
    goto error_found;
  end if;

  --check set ele type match
  if( Is_Set_Ele_Type_Valid(
        p_set_id => p_set_id,
        p_ele_id => p_ele_id)
        = G_FALSE) then
      fnd_message.set_name('CS', 'CS_KB_C_INCOMPATIBLE_TYPES');
      goto error_found;
   end if;

  -- prepare data to insert
  Get_Who(l_date, l_created_by, l_login);

  select max(element_order) into l_order
    from cs_kb_set_eles
    where set_id = p_set_id;
  if( not l_order > 0) then
    l_order :=1;
  else
    l_order := l_order + 1;
  end if;


  -- insert into set_ele
  insert into cs_kb_set_eles (
        set_id, element_id, element_order, assoc_degree,
        creation_date, created_by,
        last_update_date, last_updated_by, last_update_login)
        values(
        p_set_id, p_ele_id, l_order, p_assoc_degree,
        l_date, l_created_by, l_date, l_created_by, l_login);


  if(p_update_sets_b = 'T') then

    update cs_kb_sets_b set
      last_update_date = l_date,
      last_updated_by = l_created_by,
      last_update_login = l_login
      where set_id = p_set_id;
  end if;

  -- touch related sets to update interMedia index
  update cs_kb_sets_tl set
    positive_assoc_index = 'c',
    negative_assoc_index = 'c',
    composite_assoc_index = 'c',
    composite_assoc_attach_index = 'c' --12.1.3
    where set_id = p_set_id;

  return OKAY_STATUS;

  <<error_found>>
  return ERROR_STATUS;
end Add_Element_To_Set;


--
-- -- -- Copy from records to objects -- -- -- --
--

PROCEDURE Copy_Eledef_To_Obj(
  p_ele_def_rec in  CS_Knowledge_PUB.ele_def_rec_type,
  x_ele_def_obj OUT NOCOPY cs_kb_ele_def_obj_type
) is
begin

  if(p_ele_def_rec.element_id is null and
     p_ele_def_rec.element_type_id is null) then
    return;
  end if;

  x_ele_def_obj := cs_kb_ele_def_obj_type(
    p_ele_def_rec.element_id,
    p_ele_def_rec.element_type_id,
    p_ele_def_rec.name,
    p_ele_def_rec.description,
    null);

  if( p_ele_def_rec.attribute_category is not null) then
    x_ele_def_obj.dff_obj := cs_kb_dff_obj_type(
      p_ele_def_rec.attribute_category,
      p_ele_def_rec.attribute1,
      p_ele_def_rec.attribute2,
      p_ele_def_rec.attribute3,
      p_ele_def_rec.attribute4,
      p_ele_def_rec.attribute5,
      p_ele_def_rec.attribute6,
      p_ele_def_rec.attribute7,
      p_ele_def_rec.attribute8,
      p_ele_def_rec.attribute9,
      p_ele_def_rec.attribute10,
      p_ele_def_rec.attribute11,
      p_ele_def_rec.attribute12,
      p_ele_def_rec.attribute13,
      p_ele_def_rec.attribute14,
      p_ele_def_rec.attribute15);
  end if;
end Copy_Eledef_To_Obj;

--
-- Copy set def from record to object
--
PROCEDURE Copy_Setdef_To_Obj(
  p_set_def_rec in  CS_Knowledge_PUB.set_def_rec_type,
  x_set_def_obj OUT NOCOPY cs_kb_set_def_obj_type
) is
begin

  if(p_set_def_rec.set_id is null and
     p_set_def_rec.set_type_id is null) then  return; end if;

  x_set_def_obj := cs_kb_set_def_obj_type(
    p_set_def_rec.set_id,
    p_set_def_rec.set_type_id,
    p_set_def_rec.name,
    p_set_def_rec.description,
    p_set_def_rec.status,
    null);

  if( p_set_def_rec.attribute_category is not null) then
    x_set_def_obj.dff_obj := cs_kb_dff_obj_type(
      p_set_def_rec.attribute_category,
      p_set_def_rec.attribute1,
      p_set_def_rec.attribute2,
      p_set_def_rec.attribute3,
      p_set_def_rec.attribute4,
      p_set_def_rec.attribute5,
      p_set_def_rec.attribute6,
      p_set_def_rec.attribute7,
      p_set_def_rec.attribute8,
      p_set_def_rec.attribute9,
      p_set_def_rec.attribute10,
      p_set_def_rec.attribute11,
      p_set_def_rec.attribute12,
      p_set_def_rec.attribute13,
      p_set_def_rec.attribute14,
      p_set_def_rec.attribute15);
  end if;
end Copy_Setdef_To_Obj;

--
-- -- -- --  Provided in PUB package -- -- -- -- --
--

--
--  Create_Set_And_Elements (1)- Using RECORDs
--    Wrapper on top of (2)
--    Original (Pre 8/03/00) Contributed element ids not passed back
--
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type,
--  p_attrval_def_tbl     in  CS_Knowledge_PUB.attrval_def_tbl_type,
  x_set_id              OUT NOCOPY number
)is
  l_element_id_tbl CS_Knowledge_PUB.number15_tbl_type;
  i1 pls_integer;
begin

  Create_Set_And_Elements(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status   => x_return_status,
    x_msg_count       => x_msg_count,
    x_msg_data        => x_msg_data,
    p_set_def_rec     => p_set_def_rec,
    p_ele_def_tbl     => p_ele_def_tbl,
    x_set_id          => x_set_id,
    x_element_id_tbl  => l_element_id_tbl);

end Create_Set_And_Elements;

--  Create_Set_And_Elements (2) - Using RECORDs
--    Wrapper - calls (4)
--    New (Post 8/03/00) Contributed element ids passed back
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type,
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY CS_Knowledge_PUB.number15_tbl_type
)
is
  l_set_def_obj cs_kb_set_def_obj_type;
  l_ele_def_tbl cs_kb_ele_def_tbl_type;
  i1 pls_integer;
  i2 pls_integer;
  l_element_id_tbl cs_kb_number_tbl_type;
  l_ele_assoc_tbl cs_kb_number_tbl_type;
begin

  if(p_ele_def_tbl is not null) then
    l_ele_def_tbl := cs_kb_ele_def_tbl_type();
    l_ele_def_tbl.EXTEND(p_ele_def_tbl.COUNT);
    i1 := l_ele_def_tbl.FIRST;
    while i1 is not null loop
      Copy_EleDef_To_Obj(p_ele_def_tbl(i1),
	  		l_ele_def_tbl(i1));
      i1 := l_ele_def_tbl.NEXT(i1);
    end loop;
  end if;

  Copy_SetDef_To_Obj(p_set_def_rec, l_set_def_obj);

  Create_Set_And_Elements(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status   => x_return_status,
    x_msg_count	      => x_msg_count,
    x_msg_data	      => x_msg_data,
    p_set_def_obj     => l_set_def_obj,
    p_ele_def_tbl     => l_ele_def_tbl,
    x_set_id          => x_set_id,
    x_element_id_tbl  => l_element_id_tbl);


  if (x_return_status <> FND_API.G_RET_STS_SUCCESS)
  then
    raise FND_API.G_EXC_ERROR;
  end if;

  -- Create new element id table out param if it's not there
  if ( x_element_id_tbl is null) then
    x_element_id_tbl := cs_knowledge_pub.number15_tbl_type();
  end if;

  -- Copy the resulting element id's from obj to out record
  if ( l_element_id_tbl is not null ) then
    i2 := l_element_id_tbl.FIRST;
    while i2 is not null loop
      x_element_id_tbl.EXTEND(1);
      x_element_id_tbl(x_element_id_tbl.LAST) := l_element_id_tbl(i2);
      i2 := l_element_id_tbl.NEXT(i2);
    end loop;
  end if;

exception
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE ,
      p_count  => x_msg_count,
      p_data   => x_msg_data );
end Create_Set_And_Elements;


--
--  Create_Set_And_Elements (3) - Using OBJECTs
--    Wrapper on top of Create_Set_and_elements (4)
--    Original (Pre 8/03/00) Contributed element ids not passed back
--
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_obj         in  cs_kb_set_def_obj_type,
  p_ele_def_tbl         in  cs_kb_ele_def_tbl_type,
--  p_attrval_def_tbl     in  cs_kb_attrval_def_tbl_type :=null,
  p_ele_assoc_tbl       in  cs_kb_number_tbl_type :=null,
  x_set_id              OUT NOCOPY number
)is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set_And_Elements';
  l_api_version CONSTANT number 	:= 1.0;

  l_ele_id number(15);
  l_rowid varchar2(30);
  l_date  date;
  l_created_by number;
  l_login number;
  j pls_integer;
  i1 pls_integer;
  l_ele_id_tbl cs_kb_number_tbl_type := cs_kb_number_tbl_type();

begin
  --if ele tab valid
  --insert elements if any

  -- if set type exists
  -- if empty set or check_set_exists = N
  -- insert new set
  -- insert new set_ele 's
  -- insert new set_attrval 's
  -- insert new ele_ele for all eles in the set if not exists
  -- incr_ele_ele for all possible links

  savepoint Create_Set_And_Elements_PVT;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -- -- -- begin my code -- -- -- -- --

  Create_Set_And_Elements(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status   => x_return_status,
    x_msg_count       => x_msg_count,
    x_msg_data        => x_msg_data,
    p_set_def_obj     => p_set_def_obj,
    p_ele_def_tbl     => p_ele_def_tbl,
    p_ele_assoc_tbl   => p_ele_assoc_tbl,
    x_set_id          => x_set_id,
    x_element_id_tbl  => l_ele_id_tbl);


-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Set_And_Elements_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
   	  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
end Create_Set_And_Elements;

--
--  Create_Set_And_Elements (4) - Using OBJECTs
--
--    New (Post 8/03/00) Contributed element ids passed back
--
PROCEDURE Create_Set_And_Elements(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_obj         in  cs_kb_set_def_obj_type,
  p_ele_def_tbl         in  cs_kb_ele_def_tbl_type,
--  p_attrval_def_tbl     in  cs_kb_attrval_def_tbl_type :=null,
  p_ele_assoc_tbl       in  cs_kb_number_tbl_type :=null,
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY cs_kb_number_tbl_type
)
IS
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set_And_Elements';
  l_api_version CONSTANT number 	:= 1.0;

  l_ele_id number(15);
  l_rowid varchar2(30);
  l_date  date;
  l_created_by number;
  l_login number;
  j pls_integer;
  i1 pls_integer;
  l_user  NUMBER := FND_GLOBAL.user_id;
  l_user_login NUMBER := FND_GLOBAL.login_id;

  CURSOR Get_Defaulted_Category IS
   SELECT category_id
   FROM CS_KB_SOLN_CATEGORIES_B
   WHERE category_id = to_number(fnd_profile.value('CS_KB_CAT_FOR_INT_CREATE_API'));

  l_defaulted_category NUMBER;

  CURSOR Get_Profile_Name IS
   SELECT user_profile_option_name
   FROM FND_PROFILE_OPTIONS_VL
   WHERE profile_option_name = 'CS_KB_CAT_FOR_INT_CREATE_API';

  l_profile_name VARCHAR2(240);


  CURSOR Check_Element (v_ele_id NUMBER) IS
   SELECT count(*)
   FROM CS_KB_ELEMENTS_B
   WHERE Element_Id = v_ele_id
   AND status = 'PUBLISHED';

  l_ele_check NUMBER;

begin
  --if ele tab valid
  --insert elements if any

  -- if set type exists
  -- if empty set or check_set_exists = N
  -- insert new set
  -- insert new set_ele 's
  -- insert new set_attrval 's
  -- insert new ele_ele for all eles in the set if not exists
  -- incr_ele_ele for all possible links


  savepoint Create_Set_And_Elements_PVT;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -- -- -- begin my code -- -- -- -- --

  -- Create output element id list
  x_element_id_tbl := cs_kb_number_tbl_type();

  -- Check params
  if(p_set_def_obj.set_type_id is null or
     p_set_def_obj.set_type_id <=0 or
     p_set_def_obj.name is null) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;

  end if;

  IF(p_set_def_obj.status is not null AND
     p_set_def_obj.status <> 'SAV' )THEN

    -- This Create api only creates Draft Solutions
    IF fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then

      fnd_message.set_name('CS', 'CS_KB_INV_API_STATUS');
      fnd_msg_pub.Add;

    END IF;
    RAISE FND_API.G_EXC_ERROR;

  END IF;

  OPEN  Get_Defaulted_Category;
  FETCH Get_Defaulted_Category INTO l_defaulted_category;
  CLOSE Get_Defaulted_Category;

  IF l_defaulted_category IS NULL THEN
    IF fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then

      OPEN  Get_Profile_Name;
      FETCH Get_Profile_Name INTO l_profile_name;
      CLOSE Get_Profile_Name;

      fnd_message.set_name('CS', 'CS_KB_INV_CAT_PROFILE');
      FND_MESSAGE.SET_TOKEN(TOKEN => 'PROFILE',
                            VALUE => l_profile_name,
                            TRANSLATE => true);
      fnd_msg_pub.Add;

    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  if(p_ele_def_tbl is null or p_ele_def_tbl.COUNT <= 0) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;

  end if;

  CS_Knowledge_PVT.Get_Who(l_date, l_created_by, l_login);

  --Process ele_tab
  x_element_id_tbl.EXTEND(p_ele_def_tbl.COUNT);

  j:=1;
  i1 := p_ele_def_tbl.FIRST;
  while i1 is not null loop

    if p_ele_def_tbl(i1).element_id is null then
      --create element and store ele_id

      l_ele_id := CS_KB_ELEMENTS_AUDIT_PKG.Create_Element(
          p_element_type_id => p_ele_def_tbl(i1).element_type_id,
          p_desc => p_ele_def_tbl(i1).description,
          p_name => p_ele_def_tbl(i1).name,
          p_status => 'DRAFT',
          p_access_level => 1000,
          p_attribute_category => p_ele_def_tbl(i1).dff_obj.attribute_category,
          p_attribute1 => p_ele_def_tbl(i1).dff_obj.attribute1,
          p_attribute2 => p_ele_def_tbl(i1).dff_obj.attribute2,
          p_attribute3 => p_ele_def_tbl(i1).dff_obj.attribute3,
          p_attribute4 => p_ele_def_tbl(i1).dff_obj.attribute4,
          p_attribute5 => p_ele_def_tbl(i1).dff_obj.attribute5,
          p_attribute6 => p_ele_def_tbl(i1).dff_obj.attribute6,
          p_attribute7 => p_ele_def_tbl(i1).dff_obj.attribute7,
          p_attribute8 => p_ele_def_tbl(i1).dff_obj.attribute8,
          p_attribute9 => p_ele_def_tbl(i1).dff_obj.attribute9,
          p_attribute10 => p_ele_def_tbl(i1).dff_obj.attribute10,
          p_attribute11 => p_ele_def_tbl(i1).dff_obj.attribute11,
          p_attribute12 => p_ele_def_tbl(i1).dff_obj.attribute12,
          p_attribute13 => p_ele_def_tbl(i1).dff_obj.attribute13,
          p_attribute14 => p_ele_def_tbl(i1).dff_obj.attribute14,
          p_attribute15 => p_ele_def_tbl(i1).dff_obj.attribute15);

      if not (l_ele_id > 0)
      then
        raise FND_API.G_EXC_ERROR;
      else
          x_element_id_tbl(j) := l_ele_id;
      end if;

    else  --if ele id not null

      -- Validate the Element Id to ensure the value passed is a valid element
      OPEN  Check_Element( p_ele_def_tbl(i1).element_id );
      FETCH Check_Element INTO l_ele_check;
      CLOSE Check_Element;

      IF l_ele_check = 1 THEN
        x_element_id_tbl(j) := p_ele_def_tbl(i1).element_id;
      ELSE
        FND_MESSAGE.set_name('CS', 'CS_KB_INV_API_ELE_ID');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    end if;

    j := j+1;
    i1 := p_ele_def_tbl.NEXT(i1);
  end loop;

  Create_Set(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status   => x_return_status,
    x_msg_count	      => x_msg_count,
    x_msg_data	      => x_msg_data,
    p_set_def_obj     => p_set_def_obj,
      p_ele_id_tbl	=> x_element_id_tbl,
    p_ele_assoc_tbl   => p_ele_assoc_tbl,
    x_set_id          => x_set_id);

    if not (x_set_id > 0)
    then
      raise FND_API.G_EXC_ERROR;
    ELSE --Create_Set was successful

      INSERT INTO CS_KB_SET_CATEGORIES (
              SET_ID,
              CATEGORY_ID,
              CREATION_DATE,
              CREATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_LOGIN	)
      VALUES (x_set_id,
              l_defaulted_category,
              sysdate,
              l_user,
              sysdate,
              l_user,
              l_user_login);

    end if;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE ,
      p_count  => x_msg_count,
      p_data   => x_msg_data );


  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Set_And_Elements_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
   	  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
END Create_Set_And_Elements;

--
-- wrapper using records
-- done
--
PROCEDURE Create_Set(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_id_tbl          in  CS_Knowledge_PUB.number15_tbl_type,
  x_set_id              OUT NOCOPY number
) is
  l_set_def_obj cs_kb_set_def_obj_type;
  l_ele_id_tbl cs_kb_number_tbl_type
    := cs_kb_number_tbl_type();
  i1 pls_integer;
begin

  if(p_ele_id_tbl is null ) then

   if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  Copy_SetDef_To_Obj(p_set_def_rec, l_set_def_obj);

  l_ele_id_tbl.EXTEND(p_ele_id_tbl.COUNT);
  i1 := p_ele_id_tbl.FIRST;
  while i1 is not null loop
    l_ele_id_tbl(i1) := p_ele_id_tbl(i1);
    i1 := p_ele_id_tbl.NEXT(i1);
  end loop;


  Create_Set(
    p_api_version => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status   => x_return_status,
    x_msg_count	      => x_msg_count,
    x_msg_data	      => x_msg_data,
    p_set_def_obj     => l_set_def_obj,
    p_ele_id_tbl      => l_ele_id_tbl,
    x_set_id          => x_set_id);


end Create_Set;

--
-- Create a set for the given element_ids.
--
PROCEDURE Create_Set(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_def_obj         in  cs_kb_set_def_obj_type,
  p_ele_id_tbl          in  cs_kb_number_tbl_type,
  p_ele_assoc_tbl       in  cs_kb_number_tbl_type :=null,
  x_set_id              OUT NOCOPY number
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set';
  l_api_version CONSTANT number 	:= 1.0;

  l_set_id number(15);
  l_count  pls_integer;
  l_rowid  varchar2(30);
  l_date   date;
  l_created_by number;
  l_login  number;
  i1    pls_integer;
  i2    pls_integer;
  i3    pls_integer;
  l_ele_def_tbl cs_kb_ele_def_tbl_type;
  l_assoc number(15);
  l_set_number varchar2(30);

  CURSOR Get_Min_Visibility IS
   SELECT visibility_id
   FROM cs_kb_visibilities_b
   WHERE position = ( SELECT min(position)
                      FROM cs_kb_visibilities_b
                      WHERE sysdate BETWEEN nvl(start_date_active, sysdate-1)
                      AND  nvl(end_date_active, sysdate+1));
  l_visibility_id NUMBER;
  l_return_status VARCHAR2(1);
  l_msg_data      VARCHAR2(2000);
  l_msg_count     NUMBER;


  CURSOR Check_Dup_Ele_Insert (v_set_id NUMBER,
                               v_ele_id NUMBER ) IS
   SELECT count(*)
   FROM CS_KB_SET_ELES
   WHERE set_id = v_set_id
   AND   element_id = v_ele_id;

   l_set_ele_count NUMBER;

begin
  -- if type exists
  -- if empty set or check_set_exists = N
  -- N/A in this api-- insert new elements
  -- insert new set
  -- insert new set_ele 's
  -- insert new set_attr 's
  -- insert new ele_ele for all eles in the set if not exists
  -- incr_ele_ele for all possible links

  savepoint Create_Set_PVT;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --
  -- Check params
  if(p_set_def_obj.set_type_id is null or
     p_set_def_obj.set_type_id <= 0 or
     p_set_def_obj.name is null
     ) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    RAISE FND_API.G_EXC_ERROR;   -- goto error_found;
  end if;

  if(p_ele_id_tbl is null or p_ele_id_tbl.COUNT <= 0) then

    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  --check types compatible
  i3 := p_ele_id_tbl.FIRST;
  while i3 is not null loop

    if( Is_Set_Ele_Type_Valid(
        p_set_type_id => p_set_def_obj.set_type_id,
        p_ele_id => p_ele_id_tbl(i3))
        = G_FALSE) then
      if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
        fnd_message.set_name('CS', 'CS_KB_C_INCOMPATIBLE_TYPES');
        fnd_msg_pub.Add;

      end if;
      RAISE FND_API.G_EXC_ERROR;
    end if;
    i3 := p_ele_id_tbl.NEXT(i3);
  end loop;

  -- Check required types
  l_ele_def_tbl := cs_kb_ele_def_tbl_type();
  l_ele_def_tbl.EXTEND(p_ele_id_tbl.COUNT);
  i3 := p_ele_id_tbl.FIRST;
  while i3 is not null loop
    l_ele_def_tbl(i3) := cs_kb_ele_def_obj_type(
      p_ele_id_tbl(i3),
      null, null, null, null);
    i3 := p_ele_id_tbl.NEXT(i3);
  end loop;
  if(Is_Required_Type_Missing(
      p_set_def_obj.set_type_id,l_ele_def_tbl)=FND_API.G_TRUE) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_REQ_TYPE');
      fnd_msg_pub.Add;

    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  OPEN  Get_Min_Visibility;
  FETCH Get_Min_Visibility INTO l_visibility_id;
  CLOSE Get_Min_Visibility;

  CS_KB_SOLUTION_PVT.Create_Solution( x_set_id             => l_set_id,
                  p_set_type_id        => p_set_def_obj.set_type_id,
                  p_name               => p_set_def_obj.name,
                  p_status             => p_set_def_obj.status,
                  p_attribute_category => p_set_def_obj.dff_obj.ATTRIBUTE_CATEGORY,
                  p_attribute1         => p_set_def_obj.dff_obj.ATTRIBUTE1,
                  p_attribute2         => p_set_def_obj.dff_obj.ATTRIBUTE2,
                  p_attribute3         => p_set_def_obj.dff_obj.ATTRIBUTE3,
                  p_attribute4         => p_set_def_obj.dff_obj.ATTRIBUTE4,
                  p_attribute5         => p_set_def_obj.dff_obj.ATTRIBUTE5,
                  p_attribute6         => p_set_def_obj.dff_obj.ATTRIBUTE6,
                  p_attribute7         => p_set_def_obj.dff_obj.ATTRIBUTE7,
                  p_attribute8         => p_set_def_obj.dff_obj.ATTRIBUTE8,
                  p_attribute9         => p_set_def_obj.dff_obj.ATTRIBUTE9,
                  p_attribute10        => p_set_def_obj.dff_obj.ATTRIBUTE10,
                  p_attribute11        => p_set_def_obj.dff_obj.ATTRIBUTE11,
                  p_attribute12        => p_set_def_obj.dff_obj.ATTRIBUTE12,
                  p_attribute13        => p_set_def_obj.dff_obj.ATTRIBUTE13,
                  p_attribute14        => p_set_def_obj.dff_obj.ATTRIBUTE14,
                  p_attribute15        => p_set_def_obj.dff_obj.ATTRIBUTE15,
                  x_set_number         => l_set_number,
                  x_return_status      => l_return_status,
                  x_msg_data           => l_msg_data,
                  x_msg_count          => l_msg_count,
                  p_visibility_id      => l_visibility_id);


  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_set_id := l_set_id;

  CS_Knowledge_PVT.Get_Who(l_date, l_created_by, l_login);

  --insert set_ele
  -- schema changes: element order column
  if p_ele_id_tbl is not null and p_ele_id_tbl.COUNT > 0 then

    i1 := p_ele_id_tbl.FIRST;
    while i1 is not null loop
      --validate element
      if(p_ele_id_tbl(i1) is null or p_ele_id_tbl(i1) < 0) then
        if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
          fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
          fnd_msg_pub.Add;
        end if;
        RAISE FND_API.G_EXC_ERROR;
      end if;


      if(p_ele_assoc_tbl is null or p_ele_assoc_tbl.count<1 or
         p_ele_assoc_tbl(i1) is null or
        p_ele_assoc_tbl(i1)=CS_Knowledge_PUB.G_POSITIVE_ASSOC) then
        l_assoc := CS_Knowledge_PUB.G_POSITIVE_ASSOC;
      else
        l_assoc := CS_Knowledge_PUB.G_NEGATIVE_ASSOC;
      end if;

      OPEN  Check_Dup_Ele_Insert( l_set_id, p_ele_id_tbl(i1) );
      FETCH Check_Dup_Ele_Insert INTO l_set_ele_count;
      CLOSE Check_Dup_Ele_Insert;

      IF l_set_ele_count = 0 THEN

        insert into cs_kb_set_eles (
          set_id, element_id, element_order, assoc_degree,
          creation_date, created_by,
          last_update_date, last_updated_by, last_update_login)
        values(
        l_set_id, p_ele_id_tbl(i1), i1, l_assoc,
        l_date, l_created_by, l_date, l_created_by, l_login);

      END IF;

      i1 := p_ele_id_tbl.NEXT(i1);

    end loop;
  end if;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_PVT;
    x_set_id := -1;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set_PVT;
    x_set_id := -1;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Set_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
   	  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);

end Create_Set;


/*
  wrapper using records
*/
PROCEDURE Create_Element(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_ele_def_rec         in  CS_Knowledge_PUB.ele_def_rec_type,
  x_element_id          OUT NOCOPY number
) is
  l_ele_def_obj  cs_kb_ele_def_obj_type;

begin

  Copy_EleDef_To_Obj(p_ele_def_rec, l_ele_def_obj);

  Create_Element(
    p_api_version   => p_api_version,
    p_init_msg_list => p_init_msg_list,
    p_commit        => p_commit,
    p_validation_level => p_validation_level,
    x_return_status    => x_return_status,
    x_msg_count        => x_msg_count,
    x_msg_data         => x_msg_data,
    p_ele_def_obj      => l_ele_def_obj,
    x_element_id       => x_element_id
  );

end Create_Element;


--
-- Create ELement given ele_type_id and desc
-- Other params are not used for now.
--
PROCEDURE Create_Element(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_ele_def_obj         in  cs_kb_ele_def_obj_type,
  x_element_id          OUT NOCOPY number
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Element';
  l_api_version CONSTANT number 	:= 1.0;

  l_ele_id number;
  l_date  date;
  l_created_by number;
  l_login number;
  l_rowid varchar2(30);
  l_ele_def_obj  cs_kb_ele_def_obj_type;

begin

  savepoint Create_Element_PVT;

  if not FND_API.Compatible_API_Call(
           	l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;


-- -- -- -- begin my code -- -- -- -- --
  -- if type exists
  -- insert element


  -- Check params
  if(p_ele_def_obj.element_type_id is null
     ) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;

    raise FND_API.G_EXC_ERROR;   -- goto error_found;
  end if;

  l_ele_id := CS_KB_ELEMENTS_AUDIT_PKG.Create_Element(
      p_element_type_id => p_ele_def_obj.element_type_id,
      p_desc => p_ele_def_obj.description,
      p_name => p_ele_def_obj.name,
      p_attribute_category => p_ele_def_obj.dff_obj.attribute_category,
      p_attribute1 => p_ele_def_obj.dff_obj.attribute1,
      p_attribute2 => p_ele_def_obj.dff_obj.attribute2,
      p_attribute3 => p_ele_def_obj.dff_obj.attribute3,
      p_attribute4 => p_ele_def_obj.dff_obj.attribute4,
      p_attribute5 => p_ele_def_obj.dff_obj.attribute5,
      p_attribute6 => p_ele_def_obj.dff_obj.attribute6,
      p_attribute7 => p_ele_def_obj.dff_obj.attribute7,
      p_attribute8 => p_ele_def_obj.dff_obj.attribute8,
      p_attribute9 => p_ele_def_obj.dff_obj.attribute9,
      p_attribute10 => p_ele_def_obj.dff_obj.attribute10,
      p_attribute11 => p_ele_def_obj.dff_obj.attribute11,
      p_attribute12 => p_ele_def_obj.dff_obj.attribute12,
      p_attribute13 => p_ele_def_obj.dff_obj.attribute13,
      p_attribute14 => p_ele_def_obj.dff_obj.attribute14,
      p_attribute15 => p_ele_def_obj.dff_obj.attribute15);

  x_element_id := l_ele_id;

  if not (l_ele_id>0) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  <<end_proc>>
  null;
-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Element_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Element_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Element_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
   	  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
end Create_Element;

--
-- Incr_Set_Useful
-- When a set is found useful, update usefulness history table.
-- Should I incr (each) individual ele_ele's? No.
-- wt_code indicates which column in ele_ele to update. - just use set_count.
--
PROCEDURE Incr_Set_Useful(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_commit	        in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_id              in  number,
  p_user_id             in  number,
  p_used_type           in varchar2, -- := CS_KNOWLEDGE_PVT.G_PF,
  p_session_id          in number
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Incr_Set_Useful';
  l_api_version CONSTANT number 	:= 1.0;
  l_hist_id number(15);
  l_date date;
  l_created_by number;
  l_login number;
  l_rowid varchar2(30);
begin
  savepoint Incr_Set_Useful_PVT;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -- -- -- begin my code -- -- -- -- --
  -- Check params
  if(p_set_id is null) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;   --goto error_found;
  end if;

  -- incr history tables
  -- insert into histories table (who, when)
  -- insert or update cs_kb_set_used_hists(set, usedtype, histid)

  --prepare data, then insert new ele
  select cs_kb_histories_s.nextval into l_hist_id from dual;
  CS_Knowledge_PVT.Get_Who(l_date, l_created_by, l_login);

  CS_KB_HISTORIES_PKG.Insert_Row(
    X_Rowid => l_rowid,
    X_History_Id => l_hist_id,
    X_History_Name => null,
    X_User_Id => p_user_id,
    X_Entry_Date => l_date,
    X_Name => null,
    X_Description => null,
    X_Creation_Date => l_date,
    X_Created_By => l_created_by,
    X_Last_Update_Date => l_date,
    X_Last_Updated_By => l_created_by,
    X_Last_Update_Login => l_login);

  insert into cs_kb_set_used_hists(
        set_id, history_id,
        creation_date, created_by, last_update_date,
        last_updated_by, last_update_login,used_type, session_id)
        values(
        p_set_id, l_hist_id, l_date, l_created_by, l_date,
        l_created_by, l_login, p_used_type, p_session_id );

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Incr_Set_Useful_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Incr_Set_Useful_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Incr_Set_Useful_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
   	  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);
end Incr_Set_Useful;

-- ************************************************************
-- START: Oracle Text Query Rewrite Routines
-- ************************************************************

  --
  -- Private Utility function
  -- remove ( and ) from p_string by replacing them with space characters
  --
  FUNCTION Remove_Parenthesis
  ( p_string       in varchar2 )
  return varchar2
  is
    l_string varchar2(32000) := p_string;
  begin
    l_string := replace(l_string, '(', ' ');
    l_string := replace(l_string, ')', ' ');
    l_string := replace(l_string, '[', ' ');
    l_string := replace(l_string, ']', ' ');
    return l_string;
  end Remove_Parenthesis;

  --
  -- Private Utility function
  -- remove } and { from p_string by replacing them with space characters
  --
  FUNCTION Remove_Braces
  ( p_string	in varchar2 )
  return varchar2
  is
    l_string varchar2(32000) := p_string;
  begin
    l_string := replace(l_string, '}', ' ');
    l_string := replace(l_string, '{', ' ');
    return l_string;
  end Remove_Braces;

  --
  -- Private Utility function
  -- replace white-space characters
  --
  FUNCTION Replace_Whitespace
  ( p_string	in varchar2,
    p_search_option in number )
  return varchar2
  is
    lenb            INTEGER;
    len             INTEGER;
    l_criteria_word VARCHAR2(2000);
    q_word          VARCHAR2(32000);
    l_string        varchar2(32000) := p_string;
    first_word      boolean := TRUE;
    l_operator      varchar2(4);

  begin

    -- First convert multi-byte space character to single byte space
    -- so that later on, when we a parsing for the space character, it
    -- will be found
    lenb := lengthb(l_string);
    len := length(l_string);
    if(lenb<>len) then
      l_string := replace(l_string, to_multi_byte(' '), ' ');
    end if;
    lenb := lengthb(l_string);
    len := length(l_string);
    -- Pad the criteria string with blanks so that
    -- the parse algorithm will not miss the last word
    l_string := rpad(l_string, lenb+1);
    l_string := ltrim(l_string,' ');

    -- Initialize some variables
    first_word := TRUE;
    len := instr(l_string, ' ');  -- position of first space character

    -- Loop through the criteria string, parse to get a single criteria word
    -- token at a time. Between each word, insert the proper Oracle Text
    -- operator (e.g. AND, OR, ACCUM, etc.) depending on the search method
    -- chosen.
    while (len > 0) LOOP
      l_criteria_word :=
        substr(l_string, 1, len-1); --from beg till char before space

      if (first_word = TRUE)
      then
        if (p_search_option = CS_KNOWLEDGE_PUB.FUZZY) --FUZZY
        then
           q_word := '?'''||l_criteria_word||'''';
         else
           q_word := ''''||l_criteria_word||'''';
         end if;
      else
        if (p_search_option = CS_KNOWLEDGE_PUB.MATCH_ALL)
        then
          l_operator := ' & ';
        elsif (p_search_option = CS_KNOWLEDGE_PUB.MATCH_ANY)
        then
          l_operator := ' | ';
        elsif (p_search_option = CS_KNOWLEDGE_PUB.FUZZY)
        then
          l_operator := ' , ?';
        elsif (p_search_option = CS_KNOWLEDGE_PUB.MATCH_ACCUM)
        then
          l_operator := ' , ';
        elsif (p_search_option = CS_KNOWLEDGE_PUB.MATCH_PHRASE)
        then
          l_operator := ' ';
        else -- if other cases
          l_operator := ' , ';
        end if;
        q_word := q_word||l_operator||''''||l_criteria_word||'''';
      end if;

      first_word := FALSE;

      -- Get the rest of the criteria string and trim off beginning whitespace
      -- This will now be the beginning of the next criteria token
      l_string := substr(l_string,len);
      l_string := LTRIM(l_string, ' ');
      -- Find the position of the next space. This will now be the end of the
      -- next criteria token
      len:= instr(l_string, ' '); -- find the position of the next space
    end loop;
    return q_word;
  end Replace_Whitespace;


  --
  -- Private Utility function
  -- Handle special characters for Text query
  --
  FUNCTION Escape_Special_Char( p_string in varchar2 )
    return varchar2
  is
    l_string varchar2(32000) := p_string;

    --5217204
    l_symbol_regexp_pattern VARCHAR2(100);
    l_symbol_idx NUMBER;
    l_final_start NUMBER;
    l_final_str VARCHAR2(32000);
    l_symbol_str VARCHAR2(32000);

    --5217204_eof
  begin
    --5217204
    -- define regular expression pattern.
    -- We do not neex to include () and [] in the pattern because they should
    -- be removed before processing.
    -- This pattern should find the pattern in which a % sign is prefixed, postfixed,
    -- or in between a symbol or a space.
    -- e.g $%  $%$  %%%%^  %%%*
    l_symbol_regexp_pattern :=
       '([''<>\.!@#$^&*\(-\)+=_\?/ ])([%]+)([''<>\.!@#$^&*\(-\)+=_|\?/ ])';
    l_symbol_idx := 0;
    --5217204_eof

    -- Remove Grouping and Escaping characters
    l_string := Remove_Parenthesis(l_string);
    l_string := Remove_Braces(l_string);

    -- replace all the other special reserved characters
    l_string := replace(l_string, FND_GLOBAL.LOCAL_CHR(39),
      FND_GLOBAL.LOCAL_CHR(39)||FND_GLOBAL.LOCAL_CHR(39)); -- quote ' to ''
    l_string := replace(l_string, '\', '\\');  -- back slash (escape char)
    l_string := replace(l_string, ',', '\,');  -- accumulate
    l_string := replace(l_string, '&', '\&');  -- and
    l_string := replace(l_string, '=', '\=');  -- equivalance
    l_string := replace(l_string, '?', '\?');  -- fussy
    l_string := replace(l_string, '-', '\-');  -- minus
    l_string := replace(l_string, ';', '\;');  -- near
    l_string := replace(l_string, '~', '\~');  -- not
    l_string := replace(l_string, '|', '\|');  -- or
    l_string := replace(l_string, '$', '\$');  -- stem
    l_string := replace(l_string, '!', '\!');  -- soundex
    l_string := replace(l_string, '>', '\>');  -- threshold
    l_string := replace(l_string, '*', '\*');  -- weight
    l_string := replace(l_string, '_', '\_');  -- single char wildcard

    --bug 3209009
    -- to make sure we will not miss '% test and %%'
--    l_string := ' '||l_string||' ';
--    l_string := replace(l_string, ' % ', ' \% ');
--    l_string := replace(l_string, ' %% ', ' \%\% ');
--    l_string := trim(l_string);

   -- bug 5217204
   -- Make sure we will not miss '% test and %%
      l_final_str := l_string;
      l_string := ' ' || l_string || ' ';
      l_symbol_idx := regexp_instr(l_string, l_symbol_regexp_pattern);

      l_final_start := 1;

      if l_symbol_idx > 0 then
        l_final_str := '';
	 --5412688
	 else -- if nothing to process
	  return l_final_str;
      --5412688_eof
      end if;

      while l_symbol_idx > 0 loop
           -- l_symbol_idx is the position of the first character of the pattern
           -- in l_string.
           l_final_str := l_final_str || substrb(l_string,
                                                 l_final_start,
                                                 l_symbol_idx - l_final_start);

           l_symbol_str := regexp_substr(l_string,
                                         l_symbol_regexp_pattern,
                                         l_final_start);

           if l_symbol_str is not  null then
            -- Update l_final_start position. It must come before the replace
            -- command.
            -- If the last character of l_symbol_str is a space, then we need
            -- to move back the index by 1. This is to plug the problem like
            -- this phrase  .% %%% in this case both ".%" and "%%%" relies on
            -- the space between for the regular expression to successfully
            -- match the pattern.
            if regexp_instr(l_symbol_str, ' $') = 0 then
              l_final_start := l_symbol_idx + length(l_symbol_str);
            else
              l_final_start := l_symbol_idx + length(l_symbol_str) - 1;
            end if;
            l_final_str := l_final_str || replace(l_symbol_str, '%', '\%');
           end if;

         -- Starting from the l_final_start, look for next pattern
         l_symbol_idx := regexp_instr(l_string, l_symbol_regexp_pattern, l_final_start);

      end loop;

    -- get the rest of the string
    l_final_str :=  l_final_str || substrb(l_string, l_final_start);

   -- return l_string;
   return l_final_str;
   -- 5217204 -eof


  end Escape_Special_Char;

  --
  -- Private Utility function
  -- Add the next term to the query string according to search option
  -- Parameters:
  --  p_string VARCHAR2: the running keyword string
  --  p_term VARCHAR2: the term to append
  --  p_search_option NUMBER: search option, as defined in CS_KNOWLEDGE_PUB
  -- Returns:
  --  Query string with the term appended using the appropriate search operator
  -- Since 12.0
  --
  FUNCTION Append_Query_Term
  ( p_string 	IN VARCHAR2,
    p_term  	IN VARCHAR2,
    p_search_option IN NUMBER )
    return varchar2
  is
    l_string varchar2(32000) := p_string;
    l_operator      varchar2(4);
  begin
    if( trim(p_term) is null )
    then
        return p_string;
    end if;

    if( trim(l_string) is null ) -- first term
    then
      if (p_search_option = CS_KNOWLEDGE_PUB.FUZZY)
      then
        l_string := '?'''|| p_term ||'''';
      else
        l_string :=  p_term;
      end if;
    else -- subsequent terms
      if (p_search_option = CS_KNOWLEDGE_PUB.MATCH_ALL)
      then
        l_operator := ' & ';
      elsif (p_search_option = CS_KNOWLEDGE_PUB.MATCH_ANY)
      then
        l_operator := ' | ';
      elsif (p_search_option = CS_KNOWLEDGE_PUB.FUZZY)
      then
        l_operator := ' , ?';
      elsif (p_search_option = CS_KNOWLEDGE_PUB.MATCH_ACCUM)
      then
          l_operator := ' , ';
      elsif (p_search_option = CS_KNOWLEDGE_PUB.MATCH_PHRASE)
      then
        l_operator := ' ';
      else -- if other cases
        l_operator := ' , ';
      end if;

      l_string := l_string || l_operator|| p_term ;
    end if;

    return l_string;
  end Append_Query_Term;

  --
  -- Private Utility function
  -- This method parses the keywords based on the search syntax rule.
  -- We support the syntax of exact phrase in the keywords (" ").
  --
  -- Parameters:
  --  p_string VARCHAR2: keywords to be processed
  --  p_search_option NUMBER: Must be one of the search option
  --       defined in CS_K NOWLEDGE_PUB.
  -- Returns:
  --  The processed keyword query
  -- Since 12.0
  --
  FUNCTION Parse_Keywords
  ( p_string	IN VARCHAR2,
    p_search_option IN NUMBER )
  RETURN VARCHAR2
  is
    l_left_quote    INTEGER := 0; -- position of left quote
    l_right_quote   INTEGER := 0; -- position of right quote
    l_qnum          INTEGER := 0; -- number of double quotes found so far
    l_phrase        Varchar2(32000); -- extracted phrase
    l_unquoted      Varchar2(32000) := ''; -- all unquoted text
    l_len           integer;
    TYPE String_List IS TABLE OF VARCHAR2(32000) INDEX BY PLS_INTEGER;
    l_phrase_list  String_List;  -- list of extracted phrases
    l_counter       INTEGER;
    l_processed_keyword VARCHAR(32000) := ''; --final processed keyword string
  begin

    l_left_quote := instr(p_string, '"', 1, l_qnum + 1);

    if(l_left_quote = 0) -- no quotes
    then
      l_unquoted := p_string;
    end if;

    while (l_left_quote > 0) LOOP
      --add unquoted portion to the unquoted string (exclude ")
      --assert: left quote (current) > right quote (prev)
      l_len := l_left_quote - l_right_quote - 1;
      l_unquoted := l_unquoted || ' ' ||
        substr(p_string, l_right_quote + 1, l_len);

      --is there a close quote?
      l_right_quote := instr(p_string,'"', 1, l_qnum + 2);
      if(l_right_quote > 0) -- add the quote
      then
        l_len := l_right_quote - l_left_quote - 1;
        l_phrase := substr(p_string, l_left_quote + 1, l_len);
        if( trim (l_phrase) is not null)
        then
          --add the quote to the list
          l_phrase_list(l_left_quote) := l_phrase;
          --dbms_output.put_line('phrase:' || '[' || l_phrase || ']');
        end if;
      else -- add the remaining text (last quote was an open quote)
        l_unquoted := l_unquoted || ' ' || substr(p_string, l_left_quote + 1);
      end if;

      -- now process the next phrase, try to find the open quote
      l_qnum := l_qnum + 2;
      l_left_quote := instr(p_string, '"', 1, l_qnum + 1);
    end loop;

    -- add the remaining text (last quote was close quote)
    if(l_right_quote > 0)
    then
        l_unquoted := l_unquoted || ' ' || substr(p_string, l_right_quote + 1);
    end if;

   --add unquoted text first to final keyword string
   if(length( trim (l_unquoted) ) > 0)
   then
     l_processed_keyword := l_unquoted;
     l_processed_keyword := Escape_Special_Char(l_processed_keyword);
     l_processed_keyword :=
       Replace_Whitespace(l_processed_keyword, p_search_option);
   end if;

   -- loop and add all the phrases
   l_counter := l_phrase_list.FIRST;
   WHILE l_counter IS NOT NULL
   LOOP
      --dbms_output.put_line('Phrase[' || l_counter || '] = ' || l_phrase_list(l_counter));
      --process each phrase as an exact phrase
      l_phrase := Escape_Special_Char( l_phrase_list(l_counter) );
      l_phrase := Replace_Whitespace(l_phrase, CS_KNOWLEDGE_PUB.MATCH_PHRASE);
      l_phrase := '(' || l_phrase || ')';
      l_processed_keyword :=
        Append_Query_Term(l_processed_keyword, l_phrase, p_search_option);
      l_counter := l_phrase_list.NEXT(l_counter);
   END LOOP;

   -- Note some calling procedures do not properly handle an empty query
   -- For now, simply return ' ', which will match nothing
   if( trim (l_processed_keyword) is null)
   then
     l_processed_keyword := ' '' '' ';
   end if;

   return l_processed_keyword;
  end Parse_Keywords;

  --
  -- Private Utility function
  -- Convert Text query critiera string into keyword query
  -- with special characters handled
  -- Since 12.0, delegates to Parse_Keywords
  --
  FUNCTION Build_Keyword_Query(
    p_string        in varchar2,
    p_search_option in number
  ) return varchar2
  is
    --l_string varchar2(32000) := p_string;
  begin
    --l_string := Escape_Special_Char(l_string);
    --return Replace_Whitespace(l_string, p_search_option);
    return parse_keywords(p_string, p_search_option);
  end Build_Keyword_Query;

  --
  -- Private Utility function
  -- This function build the theme query component of a search
  -- This is essentially wrapping the keywords with a 'about()'
  -- intermedia function call.
  -- The string parameter passed into the intermedia 'about()'
  -- function has a limit of 255 characters. This function gets
  -- around that limit by breaking the query string up into < 255
  -- character chunks, wrapping each chunk with a separate 'about()'
  -- function and accumulating the theme search chunks together.
  function Build_Intermedia_Theme_Query( p_raw_query_keywords  in varchar2 )
    return varchar2
  is
    l_theme_querystring varchar2(30000);
    l_chunksize     integer := 245;
    l_pos_raw       integer;
    l_pos_endchunk  integer;
    l_len_raw       integer;
    l_chunk_count   integer := 0;
  begin
    l_len_raw := length(p_raw_query_keywords);
    l_pos_raw := 1;

    while( l_pos_raw < l_len_raw ) loop
      l_chunk_count := l_chunk_count + 1;

      -- Set end position of next chunck
      if( l_pos_raw + l_chunksize - 1  > l_len_raw ) then
        l_pos_endchunk := l_len_raw;
      else
        l_pos_endchunk := l_pos_raw + l_chunksize - 1;
        -- adjust the endchunk to the last word boundary
        l_pos_endchunk := instr( p_raw_query_keywords, ' ',
                                 -(l_len_raw-l_pos_endchunk+1) );
      end if;

      -- wrap next chunk with 'about()' and append to
      -- the theme query string buffer with accumulate.
      if( l_chunk_count > 1 ) then
        l_theme_querystring := l_theme_querystring || ',';
      end if;

      l_theme_querystring := l_theme_querystring || 'about(' ||
        substr(p_raw_query_keywords,
               l_pos_raw,
               l_pos_endchunk - l_pos_raw + 1)||')';

      l_pos_raw := l_pos_endchunk + 1;
    end loop;
    return l_theme_querystring;
  end Build_Intermedia_Theme_Query;

  --
  -- Private Utility function
  -- This is the main query-rewrite function. Given a raw
  -- user-entered keyword string and the search method chosen,
  -- this function will construct the appropriate Oracle Text
  -- query string. This is independent of whether the search
  -- is for solutions or statements or anything else.
  -- NOTE: This function does NOT incorporate product, platform,
  -- category, or other metadata information into the Text query.
  -- Those predicates are left to the caller to append.
  FUNCTION Build_Intermedia_Query
  ( p_string in varchar2,
    p_search_option in number )
  return varchar2
  is
    l_about_query varchar2(32000) := p_string;
    l_keyword_query varchar2(32000) := p_string;
    l_iQuery_str varchar2(32000); -- final intermedia query string
    lenb integer;
    len integer;
  begin

    -- If the Search option chosen is THEME Search or if there is
    -- no search option chosen, then rewrite the raw text query
    -- with the theme search query and concatenate it with a regular
    -- non-theme based rewritten query
    if (p_search_option = CS_KNOWLEDGE_PUB.THEME_BASED or
        p_search_option is null) --DEFAULT
    then
      l_keyword_query :=
        Build_Keyword_Query
         ( p_string => l_keyword_query,
           p_search_option=> null);
      l_about_query :=
        Build_Intermedia_Theme_Query( Escape_Special_Char(l_about_query) );
      l_iQuery_str := '('||l_about_query||' OR '||l_keyword_query||')';
    else
    -- Else just build the standard, non-theme based rewritten query
      l_keyword_query :=
        Build_Keyword_Query
        ( p_string => l_keyword_query,
          p_search_option => p_search_option );

      --(SRCHEFF)
      Process_Frequency_Keyword(l_keyword_query, p_search_option);

      l_iQuery_str := '( ' || l_keyword_query || ' )';
    end if;

    -- Return the rewritten text query criteria
    return l_iQuery_str;

  end Build_Intermedia_Query;


  -- WRAPPER
  -- Constructs the Text query that should be used in the
  -- CONTAINS predicate for a solution search
  -- (1) -calls (2)
  --
  FUNCTION Build_Solution_Text_Query
  ( p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type )
  return varchar2
  is
    l_number number;
  begin
    return Build_Solution_Text_Query(p_raw_text,
      p_solution_type_id_tbl, l_number);
  end Build_Solution_Text_Query;

  -- WRAPPER
  -- Constructs the Text query that should be used in the
  -- CONTAINS predicate for a solution search
  -- (2) calls (3)
  FUNCTION Build_Solution_Text_Query
  ( p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number )
  return varchar2
  is
    l_product_id_tbl CS_Knowledge_PUB.number15_tbl_type;
    l_platform_id_tbl CS_Knowledge_PUB.number15_tbl_type;
  begin
    return Build_Solution_Text_Query(
      p_raw_text, p_solution_type_id_tbl,
      l_product_id_tbl, l_platform_id_tbl, p_search_option);
  end Build_Solution_Text_Query;

  -- WRAPPER
  -- Constructs the Text query that should be used in the
  -- CONTAINS predicate for a solution search
  -- (3) calls (4)
  FUNCTION Build_Solution_Text_Query
  ( p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number )
  return varchar2
  is
    l_category_id_tbl CS_Knowledge_PUB.number15_tbl_type;
  begin
    return Build_Solution_Text_Query(
      p_raw_text, p_solution_type_id_tbl,
      p_product_id_tbl, p_platform_id_tbl, l_category_id_tbl, p_search_option);
  end Build_Solution_Text_Query;

  -- WRAPPER
  -- Constructs the Text query that should be used in the
  -- CONTAINS predicate for a solution search
  -- (4) calls (5)
  FUNCTION Build_Solution_Text_Query
  ( p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_category_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number )
  return varchar2
  is
    l_statement_id_tbl CS_Knowledge_PUB.number15_tbl_type;
  begin
    return Build_Solution_Text_Query(
      p_raw_text, p_solution_type_id_tbl,
      p_product_id_tbl, p_platform_id_tbl, p_category_id_tbl,
      l_statement_id_tbl, p_search_option);
  end Build_Solution_Text_Query;

  -- Constructs the Text query that should be used in the
  -- CONTAINS predicate for a solution search
  -- (5)
  -- Handles keywords, solution type, products, platforms, category,
  -- solution number and statement id
  FUNCTION Build_Solution_Text_Query
  ( p_raw_text in varchar2,
    p_solution_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_category_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_statement_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number )
  return varchar2
  is
    l_query_str varchar2(30000) := p_raw_text;
    l_raw_text varchar2(30000) := p_raw_text;
    l_custom_query_str varchar2(30000);
    l_lang varchar2(4);
    l_lang_cond varchar2(2000);
    l_types varchar2(2000);
    l_type_cond varchar2(2000);
    l_type_is_all varchar2(1);
    l_type_ids_index number;

    l_product_cond  varchar2(2000);
    l_products varchar2(2000);

    l_platform_cond varchar2(2000);
    l_platforms varchar2(2000);

    l_category_cond varchar2(2000);
    l_categories varchar2(2000);

    l_sol_number_cond varchar2(2000);
    l_statement_ids      varchar2(30000);
    l_statement_ids_cond varchar2(30000);

    l_return_status VARCHAR2(50);
    l_msg_count 	  NUMBER;
    l_msg_data      VARCHAR2(5000);

    l_weight1 NUMBER;
    l_weight2 NUMBER;
    MAX_SET_NUMBER_LENGTH NUMBER := 30;

    l_category_group_id NUMBER;
    l_soln_visibility_position NUMBER;
    l_catgrp_vis varchar2(2000);

    -- klou (LEAK)
    l_open_text   VARCHAR2(1) := '(';
    l_close_text  VARCHAR2(1) := ')';
    l_and_operator VARCHAR2(10) := ' ';
    -- klou (PRODFILTER)
    Cursor get_product_filter_csr Is
      Select nvl(fnd_profile.value('CS_KB_NO_GENERIC_SOLN_IN_PROD_SRCH'), 'N')
      From dual;
    l_exclude_generic_soln VARCHAR(1) := 'Y';
    -- klou (SMARTSCORE)
    l_query_filter VARCHAR2(30000) := '';
    l_query_keyword VARCHAR2(30000) := '';
    l_smart_score_flag VARCHAR2(1) := 'Y';
    l_statement_ids_keyword VARCHAR2(30000) ;

    Cursor visibility_csr Is
    SELECT VISIBILITY_ID
    FROM CS_KB_VISIBILITIES_B
    WHERE VISIBILITY_ID =
      fnd_profile.value('CS_KB_ASSIGNED_SOLUTION_VISIBILITY_LEVEL')
    AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

    l_soln_visibility_id NUMBER;

    -- 39836966_cursor
    CURSOR Get_Magic_Word_Csr IS
    SELECT fnd_profile.value('CS_KB_SEARCH_NONEXIST_KEYWORD') FROM dual;

    l_magic_word VARCHAR2(255);
    -- 39836966_cursor_eof
  begin
   -- Goal: make a query text that consists of score_section + filter_section.

    -- Get security.
    Open visibility_csr;
    Fetch visibility_csr Into l_soln_visibility_id;
    Close visibility_csr;
    If l_soln_visibility_id Is Null Then
      l_soln_visibility_id := 0;
    End If;

    l_category_group_id :=
                CS_KB_SECURITY_PVT.Get_Category_Group_Id();
    l_catgrp_vis := TO_CHAR(l_category_group_id) || 'a'
            ||to_char(l_soln_visibility_id);

     --1. Clean up the p_raw_text.
    l_raw_text := Remove_Braces(p_raw_text);
    l_raw_text := trim(l_raw_text);
    l_query_str := l_raw_text;
    If l_raw_text is null or l_raw_text = '' then
	 --(SMARTSCORE), remove all logic in this block.
	  null;
    Else  -- when p_raw_text is not null

    If (p_search_option <> CS_KNOWLEDGE_PUB.INTERMEDIA_SYNTAX)
    then
      l_query_str := Build_Intermedia_Query( l_query_str, p_search_option);
    end if;

    -- Call Customer User Hook to customize the Intermedia query string
    CS_KNOWLEDGE_CUHK.Text_Query_Rewrite_Post
    (
      p_api_version          => 1.0,
      p_init_msg_list        => FND_API.G_TRUE,
      p_commit               => FND_API.G_FALSE,
      p_validation_level     => FND_API.G_VALID_LEVEL_FULL,
      x_return_status        => l_return_status,
      x_msg_count            => l_msg_count,
      x_msg_data             => l_msg_data,
      p_raw_query_text       => p_raw_text,
      p_processed_text_query => l_query_str,
      p_search_option        => p_search_option,
      x_custom_text_query    => l_custom_query_str
    );
    if( l_return_status = FND_API.G_RET_STS_SUCCESS AND
        l_custom_query_str is not null )
    then
      l_query_str := l_custom_query_str;
    end if;

    -- (TEXTNUM)
    if (length(l_raw_text) > MAX_SET_NUMBER_LENGTH)
    then
      l_sol_number_cond := NULL;
    else
      l_sol_number_cond := ' or ({a' || l_raw_text || 'a} within NUMBER)*10*10 ';
    end if;

    if (l_sol_number_cond is not null)
    then
      l_query_str := '(' || l_query_str || l_sol_number_cond || ')';
    end if;
   End If; -- End  l_raw_text checkl
   -- (SMARTSCORE)

   l_query_keyword := l_query_str;

    -- 2. At this point the l_query_keyword contributes the score due to the raw text.
    --    Next, we will include the scores from the filter of product, platfom, category,
    --    or statement fitlers only if the smart score mode is ON.
    l_smart_score_flag := fnd_profile.value('CS_KB_SMART_SCORING');
    If l_smart_score_flag is null or  l_smart_score_flag = 'Y' Then
      l_query_keyword := Build_Smart_Score_Query(
                              l_query_keyword,
                              p_product_id_tbl,
                              p_platform_id_tbl,
                              p_category_id_tbl ,
		              p_statement_id_tbl);
    End If;

    -- 3. At this point, the format of the l_query_keyword should be correct even in the
    --     case that the p_raw_text is empty and the smart score mode is on. It is
    --     because the Build_Smart_Score_Query takes care of an empty p_raw_text.
    --    Next we will construct the filter section for the query text.
    -- (SMARTSCORE)

    --3832320
    l_lang := userenv('LANG');
    l_query_filter := '((a'||l_lang||'a) within LANG) ';


    -- 3.1 Generic filters.
    -- Bug 3328595 : If any solution type ID is -1, we should not use it a
    -- criteria at all
     If (p_solution_type_id_tbl is not null and p_solution_type_id_tbl.COUNT > 0) then
            -- Check if the ids contains -1, which means search all types.
            l_type_is_all := 'N';
            l_type_ids_index := p_solution_type_id_tbl.FIRST;
            while l_type_ids_index is not null loop
              if p_solution_type_id_tbl(l_type_ids_index) = -1 then
                l_type_is_all := 'Y';
                exit;
              end if;
              l_type_ids_index := p_solution_type_id_tbl.NEXT(l_type_ids_index);
            end loop;
            -- Only when we are not searching all, we will add this condition.
            if l_type_is_all = 'N' then
                l_types := Concat_Ids(p_solution_type_id_tbl, 'a|a');
                -- (SMARTSCORE)
                l_type_cond := ' AND ((a'|| l_types ||'a) within TYPE)';
            end if;
      End If;
     -- End Bug 3328595

      If (l_type_cond is not null)
        then
          l_query_filter := l_query_filter || l_type_cond;
      End if;

      If (p_statement_id_tbl is not null and   p_statement_id_tbl.COUNT > 0)
        then
          l_statement_ids := Concat_Ids(p_statement_id_tbl, 'a|a');
         --(SMARTSCORE)
            l_statement_ids_cond := '((a'|| l_statement_ids ||'a) within STATEMENTS)';
            l_statement_ids_keyword := '((a'||Concat_Ids(p_statement_id_tbl, 'a,a')
    	                        ||'a) within STATEMENTS)';
      End If;

      -- Bug 3328595 : The statements condition should have been connected to
      -- others by AND instead of OR
      If (l_statement_ids_cond is not null)
        then
            l_query_filter :=  l_query_filter||' AND '|| l_statement_ids_cond;
      End if;
      -- End Bug 3328595

   -- Bug 3217731, if l_smart_score_flag is on, ignore the rest filters because the only
   -- filter we need is (keyword And Lang And security)
   If l_smart_score_flag = 'N' Then

    If (p_product_id_tbl is not null and   p_product_id_tbl.COUNT > 0)
    then
        l_products := Concat_Ids(p_product_id_tbl, 'a|a');
        -- (PRODFILTER)
        Open get_product_filter_csr;
        Fetch get_product_filter_csr Into l_exclude_generic_soln;
        Close get_product_filter_csr;
        l_products := 'a' || l_products||'a';
        if l_exclude_generic_soln <> 'Y' then
         l_products := l_products || '|a000a';
        end if;
            -- (SMARTSCORE)
        l_product_cond := ' AND (('|| l_products ||') within PRODUCTS)';
    End If;

    If (p_platform_id_tbl is not null and   p_platform_id_tbl.COUNT > 0)
    then
      l_platforms := Concat_Ids(p_platform_id_tbl, 'a|a');
      l_platforms := 'a' || l_platforms || 'a|a000a';
      -- (SMARTSCORE)
      l_platform_cond := ' AND (('|| l_platforms ||') within PLATFORMS)';
    End if;

    If (p_category_id_tbl is not null and
        p_category_id_tbl.COUNT > 0)
    then
      l_categories := Concat_Ids(p_category_id_tbl, 'a|a');
      -- (SMARTSCORE)
      l_category_cond := ' AND ((a'|| l_categories ||'a) within CATEGORIES) ';
    End If;

    If (l_product_cond is not null)
    then
      l_query_filter := l_query_filter || l_product_cond;
    End If;

    If (l_platform_cond is not null)
    then
      l_query_filter := l_query_filter || l_platform_cond;
    End If;

    If (l_category_cond is not null)
    then
      l_query_filter := l_query_filter || l_category_cond;
    End If;
  End If; -- end Bug 3217731 fix

    l_query_filter := l_open_text||l_query_filter; -- first level bracket
    l_query_filter := l_open_text || l_query_filter||l_close_text ;
    l_query_filter := l_query_filter || ' & '|| l_open_text;  -- security bracket
     l_query_filter:= l_query_filter || '(( ' || l_catgrp_vis ;
     l_query_filter:= l_query_filter || ' ) within CATEGORYGROUPS)';
    l_query_filter := l_query_filter || l_close_text;  -- close security bracket
    l_query_filter := l_query_filter || l_close_text;  -- close first level bracket
   -- End bug 3231550

   -- 5. Combine the l_queryt_keyword and the l_query_filter.
   -- 5.1 If the l_query_keywrod part is null, we end up returning the l_query_filter. If
   --     this is the case, we don't use 100 as the term weight.
   --      Q: In what condition will this happen?
   --      A: when raw text is empty, product/plaform/category/statement filters are empty
   --          and the solution type filter is/is not present. In this case the queryt text must
   --          have the <LANG> and <CATEGORYGROUPS> sections, and/or the <TYPE>
   --         section.
   If l_query_keyword is  null OR  l_query_keyword  = '' Then
     l_query_str := l_query_filter||'*10*10';
   ELSE
    -- 39836966
    l_query_filter := l_query_filter||'*10*10';

    OPEN Get_Magic_Word_Csr;
    FETCH Get_Magic_Word_Csr INTO l_magic_word;
    CLOSE Get_Magic_Word_Csr;

    l_query_keyword := l_open_text||l_query_keyword||l_close_text||'|('''||l_magic_word||''')';

    -- 39836966_eof
    l_query_str := l_open_text||l_query_keyword||l_close_text||' & '||l_query_filter;
   End If;
   Return l_query_str;
  End Build_Solution_Text_Query;

-- Constructs the intermedia query that should be used in the
-- CONTAINS predicate for a solution search
--
-- Not includes products and platforms

FUNCTION Build_Simple_Text_Query
  (
    p_qry_string in varchar2,
    p_search_option in number
  )
  return varchar2
is
  l_query_str varchar2(30000) := p_qry_string;

begin

  if (p_search_option = CS_KNOWLEDGE_PUB.INTERMEDIA_SYNTAX) -- Intermedia Syntax
  then
       return l_query_str;
  end if;

  l_query_str := Build_Intermedia_Query( l_query_str, p_search_option);

  return l_query_str;
end Build_Simple_Text_Query;


-- (3468629)
  -- Make the old API backward compatible.
  FUNCTION Build_Statement_Text_Query
  ( p_raw_text in varchar2,
    p_statement_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type
  )
  return varchar2
  is
  begin
    Return Build_Statement_Text_Query (
               p_raw_text,
               p_statement_type_id_tbl,
               CS_KNOWLEDGE_PUB.MATCH_ACCUM -- default to Accumulate
              );
  end Build_Statement_Text_Query;


  FUNCTION Build_Statement_Text_Query
  ( p_raw_text in varchar2,
    p_statement_type_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_search_option in number
  )
  return varchar2
  is
    l_query_str varchar2(30000) := p_raw_text;
    l_raw_text varchar2(30000) := p_raw_text;
    l_lang varchar2(4);

    l_types varchar2(2000);
    l_type_cond varchar2(2000);
    l_type_is_all varchar2(1);
    l_type_ids_index number;

    l_number_cond varchar2(2000);

    l_return_status VARCHAR2(50);
    l_msg_count 	  NUMBER;
    l_msg_data      VARCHAR2(5000);

    MAX_SET_NUMBER_LENGTH NUMBER := 30;

    l_category_group_id NUMBER;
    l_soln_visibility_position NUMBER;
    l_catgrp_vis varchar2(2000);


    l_query_filter VARCHAR2(30000) := '';
    l_query_keyword VARCHAR2(30000) := '';

    l_statement_ids_keyword VARCHAR2(30000) ;

    Cursor visibility_csr Is
    SELECT VISIBILITY_ID
    FROM CS_KB_VISIBILITIES_B
    WHERE VISIBILITY_ID =
      fnd_profile.value('CS_KB_ASSIGNED_SOLUTION_VISIBILITY_LEVEL')
    AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

    l_soln_visibility_id NUMBER;

    l_stmt_visibility NUMBER;
    l_access_level_filter VARCHAR2(500);

    -- 39836966_cursor
    CURSOR Get_Magic_Word_Csr IS
    SELECT fnd_profile.value('CS_KB_SEARCH_NONEXIST_KEYWORD') FROM dual;

    l_magic_word VARCHAR2(255);
    -- 39836966_cursor_eof
  begin
 -- Goal: make a query text that consists of
 -- score_section + filter_section.

 -- 1. Get security.
    Open visibility_csr;
    Fetch visibility_csr Into l_soln_visibility_id;
    Close visibility_csr;
    If l_soln_visibility_id Is Null Then
      l_soln_visibility_id := 0;
    End If;

    l_category_group_id :=
                CS_KB_SECURITY_PVT.Get_Category_Group_Id();
    l_catgrp_vis := TO_CHAR(l_category_group_id) || 'a'
            ||to_char(l_soln_visibility_id)||
            ' within CATEGORYGROUPS ';

  --2. Clean up the p_raw_text.
    l_raw_text := Remove_Braces(p_raw_text);
    l_raw_text := trim(l_raw_text);
    l_query_str := l_raw_text;

  --3. Process l_raw_text
    If l_query_str is not null Then
      If (p_search_option <> CS_KNOWLEDGE_PUB.INTERMEDIA_SYNTAX)
      Then
        l_query_str := Build_Intermedia_Query(
                          l_query_str,
                          p_search_option);
        -- At this point, l_query_str should contain
        -- searching method operators.
      End If;

      -- 3.1 Check if we should use the search string
      --     add a number.
      if (length(l_raw_text) > MAX_SET_NUMBER_LENGTH)
      then
        l_number_cond := NULL;
      else
        l_number_cond := ' or ({a' || l_raw_text
                 || 'a} within NUMBER)*10*10 ';
      end if;

      if (l_number_cond is not null)
      then
        l_query_str := '(' || l_query_str || l_number_cond || ')';
      end if;
    End If; -- End  l_raw_text check

    l_query_keyword := l_query_str;

   -- 4. Add non-scoreable filters: filters should not contribute
   --    to the score.
    l_query_filter := '(a'||userenv('LANG')||'a within LANG)';

    If (p_statement_type_id_tbl is not null
         and p_statement_type_id_tbl.COUNT > 0) then
          -- Check if the ids contains -1,
          -- which means search for all types.
          l_type_is_all := 'N';
          l_type_ids_index := p_statement_type_id_tbl.FIRST;
          while l_type_ids_index is not null loop
            if p_statement_type_id_tbl(l_type_ids_index) = -1 then
              l_type_is_all := 'Y';
              exit;
            end if;
            l_type_ids_index := p_statement_type_id_tbl.NEXT(l_type_ids_index);
          end loop;
          if l_type_is_all = 'N' then
              l_types := Concat_Ids(p_statement_type_id_tbl, 'a|a');
              l_type_cond := ' & ((a'|| l_types ||'a) within TYPE)';
          end if;
    End If; -- end p_statement_type_id_tbl check

    If (l_type_cond is not null)
      then
        l_query_filter := l_query_filter || l_type_cond;
    End if;

    l_stmt_visibility :=
       CS_KB_SECURITY_PVT.Get_Stmt_Visibility_Position();
    l_access_level_filter := '(a'||to_char(l_stmt_visibility)
           ||'a within ACCESS)';
    l_query_filter := l_query_filter ||' & '||
           l_access_level_filter;

   -- 5. Add security filter
    l_query_filter :=l_query_filter || ' & ('||l_catgrp_vis||')';

   -- 6. Combine the l_query_keyword and the l_query_filter.
   -- 6.1 If the l_query_keyword is null, we end up returning
   ---   the l_query_filter. If this is the case, we use 100
   --    as the term weight.
   If l_query_keyword is  null OR  l_query_keyword  = '' Then
     l_query_str := '('||l_query_filter||')*10*10';
   ELSE

    -- 39836966
    OPEN Get_Magic_Word_Csr;
    FETCH Get_Magic_Word_Csr INTO l_magic_word;
    CLOSE Get_Magic_Word_Csr;

    l_query_keyword := '('||l_query_keyword||')'||'|('''||l_magic_word||''')';

    -- 39836966_eof
    l_query_str := '('||l_query_keyword||')'||' & '
             ||'('||l_query_filter||')*10*10';
   End If;

   Return l_query_str;
  End Build_Statement_Text_Query;
-- end 3468629

-- NOTE: This api code has been duplicated to Find_Sets_Matching2 for bug 4304939
-- Any changes made to this api should also be replicated to the new Find_Sets_Matching2
PROCEDURE Find_Sets_Matching (
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_pos_query_str       in  varchar2,
  p_neg_query_str       in  varchar2 := null,
  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
  p_other_criteria      in  varchar2 := NULL,
  p_rows                in  number,
  p_start_score         in  number := null,
  p_start_id            in  number := null,
  p_start_row           in  number, -- := 1,
  p_get_total_flag      in  varchar2, -- := FND_API.G_FALSE,
  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type,
  x_total_rows          OUT NOCOPY number,
  p_search_option       in number := null
)is
  l_api_name	CONSTANT varchar2(30)	:= 'Find_Sets_Matching';
  l_api_version CONSTANT number 	:= 1.0;
  l_type_cond varchar2(500) := null;
  l_types     varchar2(1000);
  l_qstr varchar2(1990);
  l_sets_csr  CS_Knowledge_PUB.general_csr_type;
  l_set_rec   CS_Knowledge_PUB.set_res_rec_type;
  l_score_cond varchar2(100) := null;
  l_id_cond varchar2(100) := null;
  l_end_row  number;
  --l_str_p varchar2(2000) := p_pos_query_str;
  --l_str_n varchar2(2000) := p_neg_query_str;

  l_sql_srows varchar2(30) :=
    ' select count(*) ';

  l_sql_s varchar2(500) :=
    ' select /*+ FIRST_ROWS */ cs_kb_sets_tl.set_id id, score(10) score, cs_kb_sets_b.set_type_id,'||
    ' cs_kb_sets_tl.name, cs_kb_sets_tl.description, '||
    ' cs_kb_sets_b.creation_date, cs_kb_sets_b.created_by,'||
    ' cs_kb_sets_b.last_update_date, cs_kb_sets_b.last_updated_by, '||
    ' cs_kb_sets_b.last_update_login, cs_kb_set_types_tl.name, '||
    ' cs_kb_sets_b.set_number ';
  l_sql_f1 varchar2(100) :=
    ' from cs_kb_sets_tl, cs_kb_sets_b, cs_kb_set_types_tl ';

  l_sql_w1 varchar2(200) :=
    ' where contains(cs_kb_sets_tl.composite_assoc_index, :a1, 10)>0 ';
  l_sql_wrows varchar2(200) :=
    ' where contains(cs_kb_sets_tl.composite_assoc_index, :a1)>0 ';
  l_sql_w varchar2(500) :=
   -- 3398078
    ' and cs_kb_sets_tl.set_id = cs_kb_sets_b.set_id '||
   -- ' and cs_kb_sets_tl.language=userenv(''LANG'') ' ||
    ' and cs_kb_set_types_tl.set_type_id = cs_kb_sets_b.set_type_id '||
    ' and cs_kb_set_types_tl.language=userenv(''LANG'') '; -- ||

  l_sql_o varchar2(100) := ' order by score desc ';

  l_sql_contains varchar2(2000);
  l_lang varchar2(4);
  l_escaped_query_str varchar2(2000);

  l_sqlerr_pos pls_integer;

begin
  savepoint Find_Sets_Matching_PVT;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -- -- -- begin my code -- -- -- -- --

  if(x_set_tbl is null) then
    x_set_tbl := cs_knowledge_pub.set_res_tbl_type();
  end if;

  --process strings
  if(p_pos_query_str is not null) then
    l_sql_contains := p_pos_query_str;
  end if;
  if(p_neg_query_str is not null) then
    l_sql_contains := l_sql_contains ||' '||p_neg_query_str;
  end if;


  if l_sql_contains is null then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;   --goto error_found;
  end if;

  l_sql_contains := Build_Solution_Text_Query
  ( p_raw_text => l_sql_contains,
    p_solution_type_id_tbl =>  p_type_id_tbl,
    p_search_option => p_search_option);

  -- (cancel) get score and id conditions

  OPEN l_sets_csr FOR
      l_sql_s || l_sql_f1 ||l_sql_w1 || l_sql_w ||
      p_other_criteria ||l_sql_o
      USING l_sql_contains;

  l_end_row := p_start_row + p_rows -1;
  for i in 1..l_end_row loop
    fetch l_sets_csr into l_set_rec;
    exit when l_sets_csr%NOTFOUND;
    if(i>=p_start_row) then
      x_set_tbl.EXTEND(1);
      x_set_tbl(x_set_tbl.LAST) := l_set_rec;
    end if;
  end loop;
  close l_sets_csr;

  -- if get total rowcount
  if(p_get_total_flag = FND_API.G_TRUE) then

    OPEN l_sets_csr FOR
      l_sql_srows || l_sql_f1 ||l_sql_w1  || l_sql_w ||
      p_other_criteria
      USING l_sql_contains;
    fetch l_sets_csr into x_total_rows;
    close l_sets_csr;

  end if;
-- -- -- -- end of code -- -- --

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Find_Sets_Matching_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Find_Sets_Matching_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN

    -- trap interMedia query exceptions and default to keyword searc
    l_sqlerr_pos := instr(SQLERRM, 'DRG-11440', 1);

    --dbms_output.put_line('_'||substr(SQLERRM, 1, 240));
    --dbms_output.put_line(substr(SQLERRM, 241, 240)||'-');
    --dbms_output.put_line('EXCEPTION: 123-'||to_char(l_sqlerr_pos)||'-');

    if(l_sqlerr_pos>0) then

        --dbms_output.put_line('can run alternative query here');
        Find_Sets_Matching(
          p_api_version  => p_api_version,
          p_init_msg_list => p_init_msg_list,
          p_validation_level => p_validation_level,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_pos_query_str  => p_pos_query_str,
          p_neg_query_str  => p_neg_query_str,
          p_type_id_tbl    => p_type_id_tbl,
          p_other_criteria  => p_other_criteria,
          p_rows            => p_rows,
          p_start_score     => p_start_score,
          p_start_id        => p_start_id,
          p_start_row       => p_start_row,
          p_get_total_flag  => p_get_total_flag,
          x_set_tbl         => x_set_tbl,
          x_total_rows      => x_total_rows,
          p_search_option   => CS_KNOWLEDGE_PUB.MATCH_ANY);
      else
        --no data to rollback in query api ROLLBACK TO Find_Sets_Matching_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
    	    l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count,
          p_data => x_msg_data);
      end if;

end Find_Sets_Matching;

-- NOTE: This api code has been duplicated from Find_Sets_Matching for bug 4304939
-- Any changes made to this api should also be replicated to the new Find_Sets_Matching
PROCEDURE Find_Sets_Matching2 (
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2, -- := FND_API.G_FALSE,
  p_validation_level    in  number, --   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_pos_query_str       in  varchar2,
  --p_neg_query_str       in  varchar2 := null,
  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
  p_other_criteria      in  varchar2,
  p_other_value         in number,
  p_rows                in  number,
  p_start_score         in  number := null,
  p_start_id            in  number := null,
  p_start_row           in  number, -- := 1,
  p_get_total_flag      in  varchar2, -- := FND_API.G_FALSE,
  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type,
  x_total_rows          OUT NOCOPY number,
  p_search_option       in number := null
)is
  l_api_name	CONSTANT varchar2(30)	:= 'Find_Sets_Matching';
  l_api_version CONSTANT number 	:= 1.0;
  l_type_cond varchar2(500) := null;
  l_types     varchar2(1000);
  l_qstr varchar2(1990);
  l_sets_csr  CS_Knowledge_PUB.general_csr_type;
  l_set_rec   CS_Knowledge_PUB.set_res_rec_type;
  l_score_cond varchar2(100) := null;
  l_id_cond varchar2(100) := null;
  l_end_row  number;
  --l_str_p varchar2(2000) := p_pos_query_str;
  --l_str_n varchar2(2000) := p_neg_query_str;

  l_sql_srows varchar2(30) :=
    ' select count(*) ';

  l_sql_s varchar2(500) :=
    ' select /*+ FIRST_ROWS */ cs_kb_sets_tl.set_id id, score(10) score, cs_kb_sets_b.set_type_id,'||
    ' cs_kb_sets_tl.name, cs_kb_sets_tl.description, '||
    ' cs_kb_sets_b.creation_date, cs_kb_sets_b.created_by,'||
    ' cs_kb_sets_b.last_update_date, cs_kb_sets_b.last_updated_by, '||
    ' cs_kb_sets_b.last_update_login, cs_kb_set_types_tl.name ' ||
    ' cs_kb_sets_b.set_number ';
  l_sql_f1 varchar2(100) :=
    ' from cs_kb_sets_tl, cs_kb_sets_b, cs_kb_set_types_tl ';

  l_sql_w1 varchar2(200) :=
    ' where contains(cs_kb_sets_tl.composite_assoc_index, :1, 10)>0 ';
  l_sql_w varchar2(500) :=
   -- 3398078
    ' and cs_kb_sets_tl.set_id = cs_kb_sets_b.set_id '||
    ' and cs_kb_set_types_tl.set_type_id = cs_kb_sets_b.set_type_id '||
    ' and cs_kb_set_types_tl.language=userenv(''LANG'') ';

  l_sql_o varchar2(100) := ' order by score desc ';

  l_sql_contains varchar2(2000);
  l_lang varchar2(4);
  l_escaped_query_str varchar2(2000);

  l_sqlerr_pos pls_integer;

begin
  savepoint Find_Sets_Matching_PVT;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -- -- -- begin my code -- -- -- -- --

  if(x_set_tbl is null) then
    x_set_tbl := cs_knowledge_pub.set_res_tbl_type();
  end if;

  --process strings
  if(p_pos_query_str is not null) then
    l_sql_contains := p_pos_query_str;
  end if;

  if l_sql_contains is null then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;   --goto error_found;
  end if;

  l_sql_contains := Build_Solution_Text_Query
  ( p_raw_text => l_sql_contains,
    p_solution_type_id_tbl =>  p_type_id_tbl,
    p_search_option => p_search_option);

  -- (cancel) get score and id conditions
  OPEN l_sets_csr FOR
      l_sql_s || l_sql_f1 ||l_sql_w1 || l_sql_w ||
      p_other_criteria ||l_sql_o
      USING l_sql_contains, p_other_value;

  l_end_row := p_start_row + p_rows -1;
  for i in 1..l_end_row loop
    fetch l_sets_csr into l_set_rec;
    exit when l_sets_csr%NOTFOUND;
    if(i>=p_start_row) then
      x_set_tbl.EXTEND(1);
      x_set_tbl(x_set_tbl.LAST) := l_set_rec;
    end if;
  end loop;
  close l_sets_csr;

  -- if get total rowcount
  if(p_get_total_flag = FND_API.G_TRUE) then

    OPEN l_sets_csr FOR
      l_sql_srows || l_sql_f1 ||l_sql_w1  || l_sql_w ||
      p_other_criteria
      USING l_sql_contains, p_other_value;
    fetch l_sets_csr into x_total_rows;
    close l_sets_csr;

  end if;
-- -- -- -- end of code -- -- --

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Find_Sets_Matching_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Find_Sets_Matching_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN

    -- trap interMedia query exceptions and default to keyword searc
    l_sqlerr_pos := instr(SQLERRM, 'DRG-11440', 1);

    --dbms_output.put_line('_'||substr(SQLERRM, 1, 240));
    --dbms_output.put_line(substr(SQLERRM, 241, 240)||'-');
    --dbms_output.put_line('EXCEPTION: 123-'||to_char(l_sqlerr_pos)||'-');

    if(l_sqlerr_pos>0) then

        --dbms_output.put_line('can run alternative query here');
        Find_Sets_Matching2(
          p_api_version  => p_api_version,
          p_init_msg_list => p_init_msg_list,
          p_validation_level => p_validation_level,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_pos_query_str  => p_pos_query_str,
          --p_neg_query_str  => p_neg_query_str,
          p_type_id_tbl    => p_type_id_tbl,
          p_other_criteria  => p_other_criteria,
          p_other_value     => p_other_value,
          p_rows            => p_rows,
          p_start_score     => p_start_score,
          p_start_id        => p_start_id,
          p_start_row       => p_start_row,
          p_get_total_flag  => p_get_total_flag,
          x_set_tbl         => x_set_tbl,
          x_total_rows      => x_total_rows,
          p_search_option   => CS_KNOWLEDGE_PUB.MATCH_ANY);
      else
        --no data to rollback in query api ROLLBACK TO Find_Sets_Matching_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF FND_MSG_PUB.Check_Msg_Level
             (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
          FND_MSG_PUB.Add_Exc_Msg(
            G_PKG_NAME,
    	    l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(
          p_count => x_msg_count,
          p_data => x_msg_data);
      end if;

end Find_Sets_Matching2;

--(SRCHEFF)
PROCEDURE Process_Frequency_Keyword (
     p_query_str    in  out nocopy varchar2,
     p_search_option   in Number) IS
    l_magic_word   VARCHAR2(240) := null;
    l_not_use_freq   VARCHAR2(1) := 'Y';
    Cursor Get_Frequency_Csr Is
    Select nvl(fnd_profile.value('CS_KB_SEARCH_FREQUENCY_MODE'), 'Y') from dual;

    Cursor Get_Magic_Word_Csr Is
    Select fnd_profile.value('CS_KB_SEARCH_NONEXIST_KEYWORD') from dual;

    l_query VARCHAR2(32000) := p_query_str;

    --3534598. We can use substr because value from
    --v$nl_parameters is always single-byte.
    Cursor get_numeric_decimal Is
    select substr(value, 1,1) from v$nls_parameters
    where parameter = 'NLS_NUMERIC_CHARACTERS';

    l_decimal VARCHAR2(1);
    l_freq_term_weight VARCHAR2(30);

BEGIN
      Open Get_Frequency_Csr;
      Fetch Get_Frequency_Csr Into l_not_use_freq;
      Close Get_Frequency_Csr;

      If l_not_use_freq = 'N' Then
        If p_search_option = CS_KNOWLEDGE_PUB.MATCH_ACCUM Then
        -- For Accum operator, add magicword as
        -- e.g. (A, B, C, magicword*0.1*0.1*0.1)
          Open Get_Magic_Word_Csr;
          Fetch Get_Magic_Word_Csr Into l_magic_word;
          Close Get_Magic_Word_Csr;

          If l_magic_word Is Not Null Then
            -- 3534598
            -- Process term weight.
            Open get_numeric_decimal;
            Fetch get_numeric_decimal Into l_decimal;
            Close get_numeric_decimal;

            If l_decimal is Null Then
              l_decimal := '.';
            End If;

            -- Since Escape_Special_Char does not take care
            -- of the space, we need to handle it separately.
            If l_decimal = ' ' Then
               l_freq_term_weight := '0\ 1';
            Else
               l_freq_term_weight := '0'||l_decimal||'1';
               l_freq_term_weight := Escape_Special_Char(l_freq_term_weight);
            End If;

            l_freq_term_weight:= l_freq_term_weight||'*'||l_freq_term_weight
                ||'*'||l_freq_term_weight;

            p_query_str := p_query_str||', '''||l_magic_word
             ||'''*'||l_freq_term_weight;
          End If;

        Elsif p_search_option = CS_KNOWLEDGE_PUB.MATCH_ALL
          OR p_search_option = CS_KNOWLEDGE_PUB.MATCH_PHRASE Then
        -- For ALL operator and Exact Phrase, amplify score by 100
           p_query_str := '('||p_query_str||')*10*10';
        Else
           null;

        End If;
      End If;
Exception
  WHEN OTHERS THEN
    p_query_str := l_query;
END;

-- (SMARTCODE)
-- Construct a text query that accumulates scores from each filter.
-- This function also takes care the empty p_current_query case.
FUNCTION Build_Smart_Score_Query
  (
    p_current_query  in varchar2,
    p_product_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_platform_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_category_id_tbl in CS_Knowledge_PUB.number15_tbl_type,
    p_statement_id_tbl in CS_Knowledge_PUB.number15_tbl_type
  )  return varchar2
  Is
    l_final_query VARCHAR2(4000) := '';
    l_temp_query VARCHAR2(2000) := '';
    l_first VARCHAR2(1) := 'Y';
    l_connector VARCHAR2(1) := ',';
  Begin

  If p_current_query is null Or p_current_query = '' Then
     l_connector := '';
  Else
     l_final_query := p_current_query;
  End If;

  If (p_product_id_tbl is not null and p_product_id_tbl.COUNT > 0)
   Then
      l_temp_query := Concat_Ids(p_product_id_tbl, 'a,a');
      l_final_query :=l_final_query|| l_connector||' ((a'|| l_temp_query ||'a) within PRODUCTS)';
      -- after use the l_connector, always set it to ','
      l_connector := ',';
  End If;

  If (p_platform_id_tbl is not null and   p_platform_id_tbl.COUNT > 0)
  then
     l_temp_query := Concat_Ids(p_platform_id_tbl, 'a,a');
     l_final_query := l_final_query||l_connector||' ((a'|| l_temp_query ||'a) within PLATFORMS)';
     -- after use the l_connector, always set it to ','
     l_connector := ',';
  End if;

   If (p_category_id_tbl is not null and  p_category_id_tbl.COUNT > 0)
   then
     l_temp_query := Concat_Ids(p_category_id_tbl, 'a,a');
     l_final_query :=l_final_query||l_connector
                || ' ((a'|| l_temp_query ||'a) within CATEGORIES) ';
      -- after use the l_connector, always set it to ','
      l_connector := ',';
   End If;

  If (p_statement_id_tbl is not null and  p_statement_id_tbl.COUNT > 0)
    then
      l_temp_query := Concat_Ids(p_statement_id_tbl, 'a,a');
      l_final_query :=l_final_query||l_connector
                || ' ((a'|| l_temp_query ||'a) within STATEMENTS) ';
       -- after use the l_connector, always set it to ','
      l_connector := ',';
  End If;

  Return l_final_query;
  Exception
     WHEN OTHERS THEN
	return p_current_query;
 End;

  -- 3341248
  -- Constructs the Text query that should be used in the
  -- CONTAINS predicate for a related statement search
  -- Handles statement id.
  -- By default, it generates an Accumulate string if more
  -- than one statement ids are given.
  FUNCTION Build_Related_Stmt_Text_Query
  (  p_statement_id_tbl in CS_Knowledge_PUB.number15_tbl_type )
  return varchar2
  is
    l_lang_str varchar2(200);

    l_statement_ids      varchar2(30000);
    l_statement_ids_cond varchar2(30000);

    l_category_group_id NUMBER;
    l_soln_visibility_id NUMBER;
   -- l_soln_visibility VARCHAR2(30);
    l_stmt_visibility NUMBER;
    l_catgrp_vis varchar2(2000);
    l_query_str VARCHAR2(30000) := '';


    l_stmt_ids_exclude VARCHAR2(30000) ;
    l_stmt_ids_exclude_cond VARCHAR2(30000);
    l_access_level_filter VARCHAR2(500);

    Cursor visibility_csr Is
    SELECT VISIBILITY_ID
    FROM CS_KB_VISIBILITIES_B
    WHERE VISIBILITY_ID =
      fnd_profile.value('CS_KB_ASSIGNED_SOLUTION_VISIBILITY_LEVEL')
    AND sysdate BETWEEN nvl(Start_Date_Active, sysdate-1)
                  AND nvl(End_Date_Active, sysdate+1);

  begin
    -- Get security.
    Open visibility_csr;
    Fetch visibility_csr Into l_soln_visibility_id;
    Close visibility_csr;
    If l_soln_visibility_id Is Null Then
      l_soln_visibility_id := 0;
    End If;

    l_category_group_id :=
                CS_KB_SECURITY_PVT.Get_Category_Group_Id();
    l_catgrp_vis := '('||TO_CHAR(l_category_group_id) || 'a'
                    ||to_char(l_soln_visibility_id)||' within CATEGORYGROUPS )';
    l_stmt_visibility := CS_KB_SECURITY_PVT.Get_Stmt_Visibility_Position();

    If (p_statement_id_tbl is not null
        and   p_statement_id_tbl.COUNT > 0)
    then
      l_statement_ids := Concat_Ids(p_statement_id_tbl, ' , ');
      l_stmt_ids_exclude := Concat_Ids(p_statement_id_tbl, 'a|a');
      l_statement_ids_cond :=
         '(('||l_statement_ids ||') within RELATEDSTMTS)';
      l_stmt_ids_exclude_cond :=
        '(a'||l_stmt_ids_exclude||'a) within STATEMENTID ';

    end if;

    l_lang_str := '(a'||userenv('LANG')||'a within LANG)';
    l_access_level_filter := '(a'||to_char(l_stmt_visibility)
                  ||'a within ACCESS)';

    If l_statement_ids_cond is not null AND
        l_stmt_ids_exclude_cond is not null
    then
       l_query_str :=
         l_statement_ids_cond ||
         '~ ('||l_stmt_ids_exclude_cond||')';
       l_query_str := '('||l_query_str ||') AND '||
         '('||l_lang_str||' AND '||l_access_level_filter||
         ' AND '||l_catgrp_vis||')*10*10*10*10';

    end if;

    Return l_query_str;
  End Build_Related_Stmt_Text_Query;

-- end 3341248

  -- Build the SR text quert.
  -- Build a text query for cs_incidents_all_tl.text_index column.
  FUNCTION Build_SR_Text_Query
  ( p_string in varchar2,
    p_search_option in number )
  return varchar2
  is
    l_about_query varchar2(32000) := p_string;
    l_keyword_query varchar2(32000) := p_string;
    l_iQuery_str varchar2(32000); -- final intermedia query string
    lenb integer;
    len integer;
  begin

    Return Build_SR_Text_Query(p_string, null, p_search_option);

  end Build_SR_Text_Query;


  -- Build the SR text quert.- 2
  -- Build a text query for cs_incidents_all_tl.text_index column.
  -- The query will use the following sections:  PRODUCT, LANG, and TYPE.
  FUNCTION Build_SR_Text_Query
  ( p_string in varchar2,
    p_item_id in NUMBER,
    p_search_option in number )
  return varchar2
  is
    l_about_query varchar2(32000) := p_string;
    l_keyword_query varchar2(32000) := p_string;
    l_iQuery_str varchar2(32000); -- final intermedia query string
    lenb integer;
    len integer;

    l_filter varchar2(32000);

    Cursor get_system_security_csr is
     select sr_agent_security from CS_SYSTEM_OPTIONS
     where rownum = 1;

    Cursor get_secured_SR_types_csr Is
    SELECT incident_type_id
    FROM cs_sr_type_mapping csmap
    WHERE csmap.responsibility_id = fnd_global.resp_id
    AND  trunc(sysdate)between trunc(nvl(csmap.start_date, sysdate))
    AND  trunc(nvl(csmap.end_date,sysdate));

    l_security_state VARCHAR2(200);
    l_security_str   VARCHAR2(32000);
    l_first          boolean;

    -- 39836966_cursor
    CURSOR Get_Magic_Word_Csr IS
    SELECT fnd_profile.value('CS_KB_SEARCH_NONEXIST_KEYWORD') FROM dual;

    l_magic_word VARCHAR2(255);
    -- 39836966_cursor_eof
  begin

    -- If the Search option chosen is THEME Search or if there is
    -- no search option chosen, then rewrite the raw text query
    -- with the theme search query and concatenate it with a regular
    -- non-theme based rewritten query
    if (p_search_option = CS_KNOWLEDGE_PUB.THEME_BASED or
        p_search_option is null) --DEFAULT
    then
      l_keyword_query :=
        Build_Keyword_Query
         ( p_string => l_keyword_query,
           p_search_option=> null);
      l_about_query :=
        Build_Intermedia_Theme_Query( Escape_Special_Char(l_about_query) );
      l_iQuery_str := '('||l_about_query||' OR '||l_keyword_query||')';
    else
    -- Else just build the standard, non-theme based rewritten query
      l_keyword_query :=
        Build_Keyword_Query
        ( p_string => l_keyword_query,
          p_search_option => p_search_option );

     l_iQuery_str := '( ' || l_keyword_query || ' )';
    end if;

    -- always add language
    l_filter := '((a'||userenv('LANG')||'a) within LANG)';

    if p_item_id is not null then
        l_filter := l_filter ||' & (('||to_char(p_item_id)||') within ITEM)';
    end if;

    -- Check security setup
    Open get_system_security_csr;
    Fetch get_system_security_csr Into l_security_state;
    Close get_system_security_csr;

    -- There are 3 security states:
    -- 'BSTANDARD' = standard security
    -- 'CCUSTOM' = custom security
    -- 'ANONE' = no security
    If l_security_state is not null AND
       l_security_state = 'BSTANDARD' Then
      -- Get a list of SR types linked to the current resp.
      l_first := true;
      for r1 in get_secured_SR_types_csr loop
        if l_first then
          l_first := false;
        else
          l_security_str := l_security_str||'|';
        end if;

        l_security_str := l_security_str ||to_char(r1.incident_type_id);
      end loop;

      if l_security_str is not null then
       l_filter := l_filter ||'&(('||l_security_str||') within SRTYPE)';
      end if;
    End If;

    -- 39836966
    OPEN Get_Magic_Word_Csr;
    FETCH Get_Magic_Word_Csr INTO l_magic_word;
    CLOSE Get_Magic_Word_Csr;

    l_iQuery_str := '(('||l_iQuery_str||')'||'|('''||l_magic_word||'''))';

    -- 39836966_eof

    l_iQuery_str := l_iQuery_str||'&('||l_filter||')*10*10';

    -- Return the rewritten text query criteria
    return l_iQuery_str;

  end Build_SR_Text_Query;
end CS_Knowledge_Pvt;

/
