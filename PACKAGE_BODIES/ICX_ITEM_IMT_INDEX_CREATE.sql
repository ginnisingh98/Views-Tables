--------------------------------------------------------
--  DDL for Package Body ICX_ITEM_IMT_INDEX_CREATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_ITEM_IMT_INDEX_CREATE" as
/* $Header: ICXIMTXB.pls 115.0 2000/05/02 17:43:41 pkm ship       $ */

type ErrorStackType is table of varchar2(1000) index by binary_integer;
g_error_stack ErrorStackType;

g_exception EXCEPTION;

procedure Debug(p_msg in varchar2) is
begin
--  dbms_output.put_line(p_msg);
    null;
end Debug;

procedure PushError(p_msg in varchar2) is
begin
  if (p_msg is not null) then
    g_error_stack(g_error_stack.COUNT + 1) := p_msg;
  end if;
end PushError;

procedure PrintStackTrace is
  l_index binary_integer;
begin
  if (g_error_stack.COUNT > 0) then
    Debug('### Error Stack');
    l_index := g_error_stack.FIRST;
    while (l_index is not null) loop
      Debug('###   '||g_error_stack(l_index));
      l_index := g_error_stack.NEXT(l_index);
    end loop;
    Debug('### End of Stack');
    g_error_stack.DELETE;
  end if;
end PrintStackTrace;


/*===========================================================================

  PROCEDURE NAME: isOracle8i

==========================================================================*/
  PROCEDURE isOracle8i(oracle8i out varchar2) is

  l_version       varchar2(20);
  l_compatibility varchar2(20);
  l_majorVersion  number;
  l_minorVersion  number;

  BEGIN

    oracle8i := 'N';

    DBMS_UTILITY.DB_VERSION(l_version, l_compatibility);
--    dbms_output.put_line(l_version || ' ' || l_compatibility);
    l_majorVersion := to_number(substr(l_version, 1, instr(l_version, '.')-1));
    l_minorVersion := to_number(substr(l_version, instr(l_version, '.')+1,
                                     instr(l_version, '.')-1));
--    dbms_output.put_line(to_char(l_majorVersion)||'-'||
--                         to_char(l_minorVersion));

    if ((l_majorVersion > 8) or
        (l_majorVersion = 8 and l_minorVersion > 0)) then
      oracle8i := 'Y';
    end if;

  EXCEPTION
    WHEN OTHERS THEN
      oracle8i := 'N';
  END isOracle8i;


/*===========================================================================

  PROCEDURE NAME : rebuild_index

==========================================================================*/
  PROCEDURE rebuild_index is

   l_progress varchar2(10) := '000';
   cursor_name INTEGER;
   ret INTEGER;
   l_8i varchar2(1) := 'N';

   BEGIN

     l_progress := '001';
     isOracle8i(l_8i);
     l_progress := '002';

     if (l_8i = 'Y') then

       l_progress := '002';

       cursor_name := DBMS_SQL.OPEN_CURSOR;

       -- drop the ctx index
       begin
         l_progress := '008';
         DBMS_SQL.PARSE(cursor_name,
           'DROP INDEX ICX.ICX_POR_ITEMS_TL_CTXIDX',
           DBMS_SQL.NATIVE);
         l_progress := '009';
         ret := DBMS_SQL.EXECUTE(cursor_name);

       exception
         when others then Debug('rebuild_index-'||l_progress||' '||SQLERRM);
       end;


       l_progress := '010';

        -- create the index

       DBMS_SQL.PARSE(cursor_name,
          'CREATE INDEX ICX.ICX_POR_ITEMS_TL_CTXIDX ' ||
          ' on ICX_POR_ITEMS_TL(CTX_DESC) ' ||
          ' INDEXTYPE IS ctxsys.context',
          DBMS_SQL.NATIVE);
       l_progress := '011';
       ret := DBMS_SQL.EXECUTE(cursor_name);

       DBMS_SQL.CLOSE_CURSOR(cursor_name);

     end if;

     l_progress := '012';

  exception
    when others then
      PushError('rebuild_index-'||l_progress||' '||SQLERRM);
      raise g_exception;

  end rebuild_index;

END icx_item_imt_index_create;


/
