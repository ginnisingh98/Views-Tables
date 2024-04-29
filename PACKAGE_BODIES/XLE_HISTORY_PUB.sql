--------------------------------------------------------
--  DDL for Package Body XLE_HISTORY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_HISTORY_PUB" AS
/* $Header: xlehispb.pls 120.8 2006/05/23 05:38:25 apbalakr ship $ */

PROCEDURE get_record_snapshot(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2,
    p_mode VARCHAR2) IS

    -- statement that retrieves the name and type of all the columns from p_table_name
    l_select_col_stmt VARCHAR2(4000);
    -- statement that retrieves a row with PK value p_id from p_table_name
    l_select_val_stmt VARCHAR2(4000);
    l_cursor INTEGER;
    l_column_name DBA_TAB_COLUMNS.column_name%TYPE;
    l_data_type DBA_TAB_COLUMNS.data_type%TYPE;
    l_dummy INTEGER;
    l_index	NUMBER:=1;

BEGIN
    l_cursor := DBMS_SQL.OPEN_CURSOR;
    l_select_col_stmt := 'select column_name, data_type from dba_tab_columns'
        || ' where table_name = :tab_name and owner = ''XLE'' order by column_id';
    l_select_val_stmt := 'select';

    DBMS_SQL.PARSE(l_cursor, l_select_col_stmt, DBMS_SQL.V7);
    DBMS_SQL.BIND_VARIABLE(l_cursor, ':tab_name', p_table_name);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 1, l_column_name, 30);
    DBMS_SQL.DEFINE_COLUMN(l_cursor, 2, l_data_type, 106);

    l_dummy := DBMS_SQL.EXECUTE(l_cursor);

    l_index := 1;

    LOOP
        IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 THEN
            EXIT;
        END IF;

        DBMS_SQL.COLUMN_VALUE(l_cursor, 1, l_column_name);
        DBMS_SQL.COLUMN_VALUE(l_cursor, 2, l_data_type);

        -- some standard columns are not tracked
        IF (l_column_name NOT IN ('CREATED_BY',
                                  'CREATION_DATE',
                                  'LAST_UPDATED_BY',
                                  'LAST_UPDATE_DATE',
                                  'LAST_UPDATE_LOGIN',
                                  'OBJECT_VERSION_NUMBER')) THEN
            IF (p_mode = 'PRE') THEN
                G_VALUE_LIST(l_index).column_name := l_column_name;
                G_VALUE_LIST(l_index).data_type := l_data_type;
            ELSE
                -- in POST mode, only the snapshot of the SAME record is taken
                IF (G_VALUE_LIST(l_index).column_name <> l_column_name)
                THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

            -- handle special first case
            IF (length(l_select_val_stmt) = 6) THEN
                l_select_val_stmt := l_select_val_stmt || ' ';
            ELSE
                l_select_val_stmt := l_select_val_stmt || ', ';
            END IF;

            IF (l_data_type = 'VARCHAR2') THEN
                l_select_val_stmt := l_select_val_stmt || l_column_name;
            ELSIF (l_data_type = 'NUMBER') THEN
                l_select_val_stmt := l_select_val_stmt || 'to_char(' || l_column_name || ')';
            ELSIF (l_data_Type = 'DATE') THEN
                l_select_val_stmt := l_select_val_stmt || 'to_char(' || l_column_Name || ', ''DD-MON-YYYY HH24:MI:SS'')';
            ELSE
                l_select_val_stmt := l_select_val_stmt || l_column_name;
            END IF;
            l_index := l_index + 1;
        END IF;
    END LOOP;
    l_index := G_VALUE_LIST.count;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    IF (length(l_select_val_stmt) > 6) THEN
        l_select_val_stmt := l_select_val_stmt || ' from ' || p_table_name || '
where ';
        l_select_val_stmt := l_select_val_stmt || p_primary_key_name || ' = :p_id';

        l_cursor := DBMS_SQL.OPEN_CURSOR;

        DBMS_SQL.PARSE(l_cursor, l_select_val_stmt, DBMS_SQL.V7);
        DBMS_SQL.BIND_VARIABLE(l_cursor, ':p_id', p_id);

--log_csc_form_debug_message('Shikha','select'||l_select_val_stmt);
--log_csc_form_debug_message('Shikha','cursor'||l_cursor);
        FOR i IN 1..l_index LOOP
            IF (p_mode = 'PRE') THEN
                DBMS_SQL.DEFINE_COLUMN(l_cursor, i, G_VALUE_LIST(i).old_value, 2000);
            ELSE
                DBMS_SQL.DEFINE_COLUMN(l_cursor, i, G_VALUE_LIST(i).new_value, 2000);
            END IF;
        END LOOP;

        l_dummy := DBMS_SQL.EXECUTE(l_cursor);

        IF DBMS_SQL.FETCH_ROWS(l_cursor) = 0 THEN
--log_csc_form_debug_message('Shikha','inside fetch'||l_cursor);
            RAISE NO_DATA_FOUND;
        END IF;

        FOR i IN 1..l_index LOOP
            IF (p_mode = 'PRE') THEN
                DBMS_SQL.COLUMN_VALUE(l_cursor, i, G_VALUE_LIST(i).old_value);
            ELSE
                DBMS_SQL.COLUMN_VALUE(l_cursor, i, G_VALUE_LIST(i).new_value);
            END IF;
        END LOOP;

        DBMS_SQL.CLOSE_CURSOR(l_cursor);
        ELSE
            RAISE FND_API.G_EXC_ERROR;
        END IF;
EXCEPTION
WHEN OTHERS THEN
    DBMS_SQL.CLOSE_CURSOR(l_cursor);
    RAISE;
END get_record_snapshot;

PROCEDURE log_changes(
    p_effective_from DATE,
    p_comment VARCHAR2,
    p_return_status  OUT NOCOPY  VARCHAR2,
    p_error_type     OUT NOCOPY  VARCHAR2) IS

    l_hist_id NUMBER := NULL;
    l_history_id NUMBER := NULL;
    l_flag Varchar2(5):='N';
    l_eff_flag Varchar2(5):='N';
    l_eff varchar2(2000);
    l_eff_from Date;
    l_count Number:=0;
    l_column_name Varchar2(200);

    v_chk varchar2(1):='0';
    v_chk2 varchar2(1):='0';

    l_start_date Date;

    cursor eff_from is
    select effective_from
    from xle_histories
    where  source_id=G_PRIMARY_KEY_ID
    and source_table=G_TABLE_NAME
    and source_column_name=l_column_name
    and effective_to is null;
BEGIN

    FOR i IN 1..G_VALUE_LIST.count LOOP
        IF (G_VALUE_LIST(i).old_value <> G_VALUE_LIST(i).new_value
            OR (G_VALUE_LIST(i).old_value IS NULL AND G_VALUE_LIST(i).new_value
IS NOT NULL)
            OR (G_VALUE_LIST(i).old_value IS NOT NULL AND G_VALUE_LIST(i).new_value IS NULL))
        THEN

            l_count:=l_count+1;
            l_column_name:=G_VALUE_LIST(i).column_name;

           For eff_from_r in eff_from loop
                If p_effective_from<eff_from_r.effective_from then
                  l_eff_flag:='Y';
                End If;
           End loop;

           If G_VALUE_LIST(i).column_name='EFFECTIVE_TO' then
             l_flag:='Y';
           --l_eff:=FND_DATE.CANONICAL_TO_DATE(G_VALUE_LIST(i).new_value);
             l_eff:=G_VALUE_LIST(i).new_value;
           End if;

            v_chk:='0';
            v_chk2:='0';

              begin
                select effective_from into l_start_date
                from  xle_registrations
                where registration_id = G_PRIMARY_KEY_ID
                and rownum < 2;
               exception
                 when NO_DATA_FOUND then
                  l_start_date:=SYSDATE;
               end;


            begin
              select '1' into v_chk
              from xle_histories
              where source_id =G_PRIMARY_KEY_ID
              and source_table=G_TABLE_NAME
              and source_column_name=G_VALUE_LIST(i).column_name
              and rownum <2;
            exception
              when NO_DATA_FOUND THEN

                           XLE_Histories_PKG.Insert_Row(
                  x_history_id => l_hist_id,
                  p_source_table => G_TABLE_NAME,
                  p_source_id => G_PRIMARY_KEY_ID,
                  p_source_column_name => G_VALUE_LIST(i).column_name,
                  p_source_column_value => G_VALUE_LIST(i).old_value,
                  p_effective_from => l_start_date,
                  p_effective_to => p_effective_from,
                  p_comment => 'Creation',
                  p_object_version_number => 1);

            end;


                  delete from xle_histories
                  where source_id=G_PRIMARY_KEY_ID
                  and source_table=G_TABLE_NAME
                  and source_column_name=G_VALUE_LIST(i).column_name
                  and effective_from > nvl(p_effective_from,sysdate);

                  if sql%rowcount > 0 then
                   /*  XLE_Histories_PKG.Insert_Row(
                         x_history_id => l_history_id,
                         p_source_table => G_TABLE_NAME,
                         p_source_id => G_PRIMARY_KEY_ID,
                         p_source_column_name => G_VALUE_LIST(i).column_name,
                         p_source_column_value => G_VALUE_LIST(i).new_value,
                         p_effective_from => l_start_date,
                         p_comment => 'Creation',
                         p_object_version_number => 1);*/

                    v_chk2:='1';

                  end if;

            if (v_chk2='0') then

             update XLE_Histories
             set effective_to=decode(trunc(effective_from),trunc(nvl(p_effective_from,sysdate)),(nvl2(p_effective_from,p_effective_from-(1/86400),sysdate-(1/86400))),nvl(p_effective_from,sysdate)-1)
             where source_id=G_PRIMARY_KEY_ID
             and source_table=G_TABLE_NAME
             and source_column_name=G_VALUE_LIST(i).column_name
             and effective_to is null;

            end if;

             XLE_Histories_PKG.Insert_Row(
                 x_history_id => l_history_id,
                 p_source_table => G_TABLE_NAME,
                 p_source_id => G_PRIMARY_KEY_ID,
                 p_source_column_name => G_VALUE_LIST(i).column_name,
                 p_source_column_value => G_VALUE_LIST(i).new_value,
                 p_effective_from => p_effective_from,
                 p_comment => p_comment,
                 p_object_version_number => 1);



             -- TODO: update the effective_from of the previous record to p_effective_from - 1
        END IF;
    END LOOP;

        If l_flag='Y' then
           update  xle_histories
           SET effective_to =to_date(to_char(to_date(l_eff, 'DD-MON-YYYY HH24:MI:SS'), 'DD-MM-YYYY'), 'DD-MM-YYYY')
           where source_id=G_PRIMARY_KEY_ID
           and source_table=G_TABLE_NAME
           and effective_to is null;

            IF (sql%notfound) THEN
                RAISE no_data_found;
            END IF;
        End if;

         If l_count>1 and l_eff_flag='Y' then
            p_return_status:='E';
            p_error_type := 'DataError';
         ElsIf l_count=1 and l_eff_flag='Y' and v_chk2='0' then
             Delete from xle_histories
             where source_id=G_PRIMARY_KEY_ID
             and source_table=G_TABLE_NAME
             and source_column_name=l_column_name
             and effective_from >  p_effective_from ;
         End If;

EXCEPTION
WHEN OTHERS THEN
    RAISE;

END log_changes;

PROCEDURE log_record_pre(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2) IS
BEGIN
    -- reset the table
    G_VALUE_LIST.delete;
    G_PRIMARY_KEY_NAME := p_primary_key_name;
    G_PRIMARY_KEY_ID := p_id;
    G_TABLE_NAME := p_table_name;
    get_record_snapshot(p_id, p_primary_key_name, p_table_name, 'PRE');
END log_record_pre;

procedure log_record_post(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2,
    p_effective_from DATE,
    p_comment VARCHAR2,
    p_error_type     OUT NOCOPY  VARCHAR2,
    p_return_status  OUT NOCOPY  VARCHAR2) IS

    l_return_status               VARCHAR2(5);
    l_error_type                  VARCHAR2(50);

BEGIN
     -- no pre update snapshot
    IF (G_VALUE_LIST.count = 0) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- invalid table name
    IF (G_TABLE_NAME <> p_table_name) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (G_PRIMARY_KEY_NAME <> p_primary_key_name OR G_PRIMARY_KEY_ID <> p_id) THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    get_record_snapshot(p_id, p_primary_key_name, p_table_name, 'POST');
    log_changes(p_effective_from, p_comment,l_return_status,l_error_type);

    If l_return_status='E' then
            p_error_type := l_error_type;
            p_return_status:=l_return_status;
    End if;

EXCEPTION
WHEN OTHERS THEN
    RAISE;
END log_record_post;

procedure log_record_ins(
    p_id NUMBER,
    p_primary_key_name VARCHAR2,
    p_table_name VARCHAR2,
    p_effective_from DATE,
    p_comment VARCHAR2,
    p_error_type     OUT NOCOPY  VARCHAR2,
    p_return_status  OUT NOCOPY  VARCHAR2
)  IS

    l_return_status               VARCHAR2(5);
    l_error_type                  VARCHAR2(50);

    l_index     NUMBER:=1;

    cursor history is
    select source_column_name
    from xle_history_columns_b;

    l_source_column_name varchar2(2000);
    l_id number;

    l_history_id NUMBER := NULL;
    l_flag Varchar2(5):='N';
    l_eff_flag Varchar2(5):='N';
    l_eff varchar2(2000);
    l_eff_from Date;
    l_count Number:=0;
    l_column_name Varchar2(200);


BEGIN
    G_VALUE_LIST.delete;
    G_PRIMARY_KEY_NAME := p_primary_key_name;
    G_PRIMARY_KEY_ID := p_id;
    G_TABLE_NAME := p_table_name;

    for history_r in history loop

                G_VALUE_LIST(l_index).column_name := history_r.source_column_name;
                l_index := l_index + 1;
    end loop;
begin

               execute immediate
  'select ' ||
                                  G_VALUE_LIST(1).column_name ||','
                               || G_VALUE_LIST(2).column_name ||','
                               || G_VALUE_LIST(3).column_name ||','
                               || G_VALUE_LIST(4).column_name ||','
                               || G_VALUE_LIST(5).column_name ||','
                               || G_VALUE_LIST(6).column_name ||','
                               || G_VALUE_LIST(7).column_name ||','
                               || G_VALUE_LIST(8).column_name ||','
                               || G_VALUE_LIST(9).column_name ||','
                               || G_VALUE_LIST(10).column_name ||','
                               || G_VALUE_LIST(11).column_name ||','
                               || G_VALUE_LIST(12).column_name ||','
                               || G_VALUE_LIST(13).column_name ||','
                               || G_VALUE_LIST(14).column_name ||','
                               || G_VALUE_LIST(15).column_name ||','
                               || G_VALUE_LIST(16).column_name ||','
                               || G_VALUE_LIST(17).column_name ||','
                               || G_VALUE_LIST(18).column_name ||','
                               || G_VALUE_LIST(19).column_name ||','
                               || G_VALUE_LIST(20).column_name ||','
                               || G_VALUE_LIST(21).column_name ||','
                               || G_VALUE_LIST(22).column_name ||','
                               || G_VALUE_LIST(23).column_name ||','
                               || G_VALUE_LIST(24).column_name ||','
                               || G_VALUE_LIST(25).column_name ||','
                               || G_VALUE_LIST(26).column_name ||','
                               || G_VALUE_LIST(27).column_name ||','
                               || G_VALUE_LIST(28).column_name ||','
                               || G_VALUE_LIST(29).column_name ||'
                     from XLE_REGISTRATIONS where REGISTRATION_ID='||p_id

                     INTO         G_VALUE_LIST(1).new_value
                                , G_VALUE_LIST(2).new_value
                                , G_VALUE_LIST(3).new_value
                                , G_VALUE_LIST(4).new_value
                                , G_VALUE_LIST(5).new_value
                                , G_VALUE_LIST(6).new_value
                                , G_VALUE_LIST(7).new_value
                                , G_VALUE_LIST(8).new_value
                                , G_VALUE_LIST(9).new_value
                                , G_VALUE_LIST(10).new_value
                                , G_VALUE_LIST(11).new_value
                                , G_VALUE_LIST(12).new_value
                                , G_VALUE_LIST(13).new_value
                                , G_VALUE_LIST(14).new_value
                                , G_VALUE_LIST(15).new_value
                                , G_VALUE_LIST(16).new_value
                                , G_VALUE_LIST(17).new_value
                                , G_VALUE_LIST(18).new_value
                                , G_VALUE_LIST(19).new_value
                                , G_VALUE_LIST(20).new_value
                                , G_VALUE_LIST(21).new_value
                                , G_VALUE_LIST(22).new_value
                                , G_VALUE_LIST(23).new_value
                                , G_VALUE_LIST(24).new_value
                                , G_VALUE_LIST(25).new_value
                                , G_VALUE_LIST(26).new_value
                                , G_VALUE_LIST(27).new_value
                                , G_VALUE_LIST(28).new_value
                                , G_VALUE_LIST(29).new_value;

Exception

WHEN OTHERS THEN
    RAISE;
end;

    FOR i IN 1..G_VALUE_LIST.count LOOP
        IF G_VALUE_LIST(i).new_value IS NOT NULL THEN
            l_count:=l_count+1;
            l_column_name:=G_VALUE_LIST(i).column_name;

            XLE_Histories_PKG.Insert_Row(
                x_history_id => l_history_id,
                p_source_table => G_TABLE_NAME,
                p_source_id => G_PRIMARY_KEY_ID,
                p_source_column_name => G_VALUE_LIST(i).column_name,
                p_source_column_value => G_VALUE_LIST(i).new_value,
                p_effective_from => p_effective_from,
                p_comment => p_comment,
                p_object_version_number => 1);
        END IF;
    END LOOP;

Exception

WHEN OTHERS THEN
    RAISE;
END log_record_ins;

END XLE_History_PUB;


/
