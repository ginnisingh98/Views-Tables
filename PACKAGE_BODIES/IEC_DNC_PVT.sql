--------------------------------------------------------
--  DDL for Package Body IEC_DNC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_DNC_PVT" AS
/* $Header: IECVDNCB.pls 115.15 2003/10/03 15:22:32 koswartz ship $ */

PROCEDURE IS_CALLABLE
  (P_SOURCE_ID        IN            NUMBER
  ,P_VIEW_NAME        IN            VARCHAR2
  ,P_LIST_ENTRY_ID    IN            NUMBER
  ,P_LIST_HEADER_ID   IN            NUMBER
  ,P_RETURNS_ID       IN            NUMBER
  ,X_CALLABLE_FLAG    IN OUT NOCOPY VARCHAR2
  )
IS

  work_cursor FETCH_CURSOR;

  l_rlse_stmt VARCHAR2(4000);
  l_contact_restriction_type HZ_CONTACT_PREFERENCES.CONTACT_LEVEL_TABLE%TYPE;
  l_counter NUMBER := 0;
  l_dont_use NUMBER := 0;
  l_record_id NUMBER := 0;

BEGIN

  Begin

   -- Build the sql statement.
   X_CALLABLE_FLAG := 'Y';

   l_rlse_stmt := 'select /*+ index ( HZ_CONTACT_PREFERENCES, HZ_CONTACT_PREFERENCES_N1 ) */ /*+ index ( AMS_LIST_ENTRIES, AMS_LIST_ENTRIES_N6 ) */ b.contact_level_table '
                || ' from ams_list_entries a, hz_contact_preferences b, iec_g_return_entries c '
                || ' where c.returns_id = :returnId '
                || ' and c.list_entry_id = a.list_entry_id '
                || ' and c.list_header_id = a.list_header_id '
                || ' and nvl( b.preference_code, ''DO'') = ''DO_NOT'' '
                || ' and ( '
                || '   ( b.contact_level_table_id = nvl(a.party_id, -1 ) and b.contact_level_table = ''HZ_PARTIES'' ) '
                || '   or '
                || '   ( b.contact_level_table_id = c.CONTACT_POINT_ID and b.contact_level_table = ''HZ_CONTACT_POINTS'' ) '
                || ' ) '
                || ' and ( nvl( b.contact_type, ''CALL'' ) = ''CALL'' '
                || ' OR  b.contact_type = ''ALL'' )'
                || ' and ( '
                || '       ( nvl(b.preference_start_date, sysdate - 1) < sysdate '
                || '       and nvl( b.preference_end_date, sysdate + 1 ) > sysdate ) '
                || ' ) ';


   open work_cursor for l_rlse_stmt USING P_RETURNS_ID;
   loop
      fetch work_cursor into l_contact_restriction_type;

      exit WHEN work_cursor%NOTFOUND;
      X_CALLABLE_FLAG := 'N';

   end loop;

   CLOSE work_cursor;

   IF X_CALLABLE_FLAG = 'N'
   THEN
      iec_returns_util_pvt.update_entry( P_RETURNS_ID
                                       , -1
                                       , to_char(null)
                                       , to_char(null)
                                       , to_char(null)
                                       , 31
                                       , 0
                                       , 0
                                       , 'N');

     END IF;

  Exception
    WHEN NO_DATA_FOUND THEN
      -- dbms_output.put_line( 'IEC_DNC_PVT:IS_CALLABLE: No data found.. All are callable per HZ_CONTACT_PREFERENCES..' );
      null;
  End;

  return;

END IS_CALLABLE;


END IEC_DNC_PVT;

/
