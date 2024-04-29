--------------------------------------------------------
--  DDL for Package Body WF_LOCAL_SYNCH
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_LOCAL_SYNCH" as
/* $Header: WFLOCALB.pls 120.30.12010000.13 2018/05/18 16:58:19 skandepu ship $ */
------------------------------------------------------------------------------
-- Global Private Variables

  g_wf_schema        VARCHAR2(320);
  g_parallel         NUMBER;
  g_logging          VARCHAR2(10);
  g_BaseLanguage     VARCHAR2(30) := 'AMERICAN';
  g_BaseTerritory    VARCHAR2(30) := 'AMERICA';
  g_temptablespace   VARCHAR2(30);
  g_modulePkg varchar2(100) := 'wf.plsql.WF_LOCAL_SYNCH';
  g_trustedRoles     WF_DIRECTORY.roleTable;
  g_trustTimeStamp   DATE;

------------------------------------------------------------------------------
-- Role variables
--
  g_name               VARCHAR2(320);
  g_displayName        VARCHAR2(360);
  g_origSystem         VARCHAR2(240);
  g_origSystemID       NUMBER;
  g_parentOrigSys      VARCHAR2(240);
  g_parentOrigSysID    NUMBER;
  g_ownerTag           VARCHAR2(50);
  g_oldOrigSystemID    NUMBER;
  g_language           VARCHAR2(30);
  g_territory          VARCHAR2(30);
  g_description        VARCHAR2(1000);
  g_notificationPref   VARCHAR2(8);
  g_emailAddress       VARCHAR2(320);
  g_fax                VARCHAR2(240);
  g_status             VARCHAR2(8);
  g_employeeID         NUMBER;
  g_expDate            DATE;
  g_delete             BOOLEAN;
  g_updateOnly         BOOLEAN;
  g_raiseErrors        BOOLEAN;
  g_overWrite          BOOLEAN;
  g_overWrite_UserRoles BOOLEAN; -- <6817561> this exposes a switch to update
                                 -- standard user/role table columns
  g_oldName            VARCHAR2(320);
  g_ppID               NUMBER;
  g_lastUpdateDate     DATE;
  g_lastUpdatedBy      NUMBER;
  g_creationDate       DATE;
  g_createdBy          NUMBER;
  g_lastUpdateLogin    NUMBER;
  g_attributes         WF_PARAMETER_LIST_T;
  g_source_lang        WF_LOCAL_ROLES.LANGUAGE%TYPE;
------------------------------------------------------------------------------
/*
** seedAttributes - <private>
**
**   This routine opens a parameter list and seeds role variables.
*/
procedure seedAttributes (p_attributes   in wf_parameter_list_t,
                          p_origSystem   in VARCHAR2,
                          p_origSystemID in NUMBER,
                          p_expDate      in DATE) is

  l_sql VARCHAR2(2000);
  l_modulePkg varchar2(240) := g_modulePkg||'.seedAttributes';

begin
-- Log only
-- BINDVAR_SCAN_IGNORE[5]
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                     'Begin seedAttributes(p_attributes '||
                     '(wf_parameter_list_t), '||p_origSystem||', '||
                     to_char(p_origSystemID)||', '||
                     to_char(p_expDate, WF_CORE.canonical_date_mask)||')');

  g_name             := NULL;
  g_displayName      := NULL;
  g_origSystem       := NULL;
  g_origSystemID     := NULL;
  g_parentOrigSys    := NULL;
  g_parentOrigSysID  := NULL;
  g_ownerTag         := NULL;
  g_language         := NULL;
  g_territory        := NULL;
  g_description      := NULL;
  g_notificationPref := NULL;
  g_emailAddress     := NULL;
  g_fax              := NULL;
  g_employeeID       := NULL;
  g_status           := NULL;
  g_expDate          := NULL;
  g_delete           := FALSE;
  g_updateOnly       := FALSE;
  g_raiseErrors      := FALSE;
  g_overWrite        := FALSE;
  g_overWrite_UserRoles := FALSE; -- <6817561>
  g_oldName          := NULL;
  g_ppID             := NULL;
  g_lastUpdateDate   := sysdate;
  g_lastUpdatedBy    := WFA_SEC.user_id;
  g_creationDate     := sysdate;
  g_createdBy        := WFA_SEC.user_id;
  g_lastUpdateLogin  := WFA_SEC.login_id;
  g_Attributes       := wf_parameter_list_t();
  g_source_lang      := sys_context('userenv', 'LANG');


  FOR i in p_attributes.FIRST..p_attributes.LAST loop
   WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Processing parameter: '||p_attributes(i).getName());
   begin
    if (upper(p_attributes(i).getName()) = 'USER_NAME') then
      g_name := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'DISPLAYNAME') then
      g_displayName := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'ORCLWFORIGSYSTEM') then
      g_origSystem := UPPER(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'ORCLWFORIGSYSTEMID') then
      g_origSystemID := to_number(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'ORCLWFPARENTORIGSYS') then
      g_parentOrigSys := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'ORCLWFPARENTORIGSYSID') then
      g_parentOrigSysID := to_number(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'OWNER_TAG') then
      g_ownerTag := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'PREFERREDLANGUAGE') then
      g_language := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'ORCLNLSTERRITORY') then
      g_territory := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'DESCRIPTION') then
      g_description := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) =
                                          'ORCLWORKFLOWNOTIFICATIONPREF') then
      g_notificationPref := upper(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'MAIL') then
      g_emailAddress := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'FACSIMILETELEPHONENUMBER') then
      g_fax := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'ORCLISENABLED') then
      g_status := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'EXPIRATIONDATE') then
      g_expDate := to_date(p_attributes(i).getValue(), WF_ENGINE.Date_Format);

    elsif (upper(p_attributes(i).getName()) = 'PER_PERSON_ID') then
      g_employeeID := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'DELETE') then
      if (upper(p_attributes(i).getValue()) = 'TRUE') then
        g_delete := TRUE;
      end if;

    elsif (upper(p_attributes(i).getName()) = 'UPDATEONLY') then
      if (upper(p_attributes(i).getValue()) = 'TRUE') then
        g_updateOnly := TRUE;
      end if;


    elsif (upper(p_attributes(i).getName()) = 'RAISEERRORS') then
      if (upper(p_attributes(i).getValue()) = 'TRUE') then
        g_raiseErrors := TRUE;

      end if;

    elsif (upper(p_attributes(i).getName()) = 'WFSYNCH_OVERWRITE') then
      if (upper(p_attributes(i).getValue()) = 'TRUE') then
        g_overWrite := TRUE;
      end if;

    elsif (upper(p_attributes(i).getName()) = 'WFSYNCH_OVERWRITE_USERROLES') then
      if (upper(p_attributes(i).getValue()) = 'TRUE') then
        g_overWrite_UserRoles := true;
      end if;

    elsif (upper(p_attributes(i).getName()) = 'OLD_USER_NAME') then
      g_oldName := p_attributes(i).getValue();

    elsif (upper(p_attributes(i).getName()) = 'PERSON_PARTY_ID') then
      g_ppID := to_number(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'LAST_UPDATED_BY') then
      g_lastUpdatedBy := to_number(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'LAST_UPDATE_DATE') then
      g_lastUpdateDate := to_date(p_attributes(i).getValue(),
                                  WF_CORE.canonical_date_mask);

    elsif (upper(p_attributes(i).getName()) = 'LAST_UPDATE_LOGIN') then
      g_lastUpdateLogin := to_number(p_attributes(i).getValue());

    elsif (upper(p_attributes(i).getName()) = 'CREATED_BY') then
      g_createdBy := to_number(p_attributes(i).getValue());


    elsif (upper(p_attributes(i).getName()) = 'CREATION_DATE') then
      g_creationDate := to_date(p_attributes(i).getValue(),
                                WF_CORE.canonical_date_mask);

    elsif (upper(p_attributes(i).getName()) = 'SOURCE_LANG') then
      g_source_lang := upper(p_attributes(i).getValue());
    else
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                       'Parameter: '||p_attributes(i).getName()||
                       'is ignored by seedAttributes.');

      WF_EVENT.addParameterToList(upper(p_attributes(i).getName()),
      p_attributes(i).getValue(),g_attributes);
    end if;




  exception
    when OTHERS then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED, l_modulePkg,
                        'Exception: '||sqlerrm||
                        ' continuing to retrieve attributes.');
      null; --We need to attempt to get all attributes.

  end;

  end loop;

  if (p_expDate is not NULL) then
    --Explicit expiration date parameter will override attribute.
    g_expDate := p_expDate;

  end if;

    --If the expiration date is now or earlier, then we will set inactive.
    --The expirationdate attribute will override the delete attribute.

  if (g_expDate is NOT NULL) then
     if (g_expDate <= sysdate) then
       g_status := 'INACTIVE';
     end if;
     g_delete := FALSE;
  end if;


  if ((g_delete) and (g_expDate is NULL)) then
    --If delete=true then we will set inactive immediately.  However if
    --there is an expiration date, that will override the delete.
    g_expDate    := sysdate;
    g_updateOnly := TRUE;
    g_status     := 'INACTIVE';

  end if;

  --p_origSystem and p_origSystemID will override attribute settings.
  if (p_origSystem is NOT NULL) then
    g_origSystem := p_origSystem;

  end if;

  if (p_origSystemID is NOT NULL) then
    g_origSystemID := p_origSystemID;

  end if;

  if (g_ppID is NOT NULL) then
    g_parentOrigSys := 'HZ_PARTY';
    g_parentOrigSysID := g_ppID;

  elsif ((g_parentOrigSys is NULL) or
         (g_parentOrigSysID is NULL)) then
    if g_employeeID is NOT NULL then -- PER users
       g_parentOrigSys := 'PER';
       g_parentOrigSysID := g_employeeID;
    else
       g_parentOrigSys := g_origSystem;
       g_parentOrigSysID := g_origSystemID;
    end if;

  end if;

  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                     'End seedAttributes(p_attributes '||
                     '(wf_parameter_list_t), '||p_origSystem||', '||
                     to_char(p_origSystemID)||', '||
                     to_char(p_expDate, WF_CORE.canonical_date_mask)||')');

exception
  when OTHERS then
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED, l_modulePkg,
                      'Exception: '||sqlerrm);
    WF_CORE.Context('WF_LOCAL_SYNCH', 'seedAttributes', p_origSystem,
                    to_char(p_origSystemID), to_char(p_expDate,
                                                   WF_CORE.canonical_date_mask));
    raise;


end;

------------------------------------------------------------------------------
/*
** wf_schema - <private>
**
*/
function wf_schema return varchar2 is
begin
  if (g_wf_schema is NULL) then
    g_wf_schema := WF_CORE.Translate('WF_SCHEMA');
  end if;

  return g_wf_schema;

end;


------------------------------------------------------------------------------
/*
** update_entmgr - <private>
**
**   This routine encapsulates the bit that keeps entmgr in the loop
*/
PROCEDURE update_entmgr(p_entity_type      in varchar2,
                        p_entity_key_value in varchar2,
                        p_attributes       in wf_parameter_list_t,
                        p_source           in varchar2) is
  i number;
  l_modulePkg varchar2(240) := g_modulePkg||'.update_entmgr';

begin
  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                     'Begin update_entmgr('|| p_entity_type||', '||
                     p_entity_key_value||', '||
                     'p_attributes (wf_parameter_list_t)'||', '||
                     p_source||')');


  end if;

  if (p_attributes is not null) then
    i := p_attributes.FIRST;
    while (i <= p_attributes.LAST) loop
      wf_entity_mgr.put_attribute_value(p_entity_type,
                                        p_entity_key_value,
                                        p_attributes(i).getName(),
                                        p_attributes(i).getValue());
      i := p_attributes.NEXT(i);
    end loop;
    wf_entity_mgr.process_changes(p_entity_type,
                                  p_entity_key_value,
                                  p_source);
  end if;

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then

     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                     'End update_entmgr('||p_entity_type||', '||
                     p_entity_key_value||', '||
                     'p_attributes(wf_parameter_list_t)'||', '||
                     p_source||')');

  end if;



end;

------------------------------------------------------------------------------
/*
** Create_Stage_Indexes - <private>
**
**   This routine examines the base table provided and creates matching indexes
**   on the stage table.
*/
PROCEDURE Create_Stage_Indexes (p_sourceTable in VARCHAR2,
                              p_targetTable in VARCHAR2) is

  type OwnerList is table of varchar2(30);
  type IndexList is table of varchar2(30);
  type TableList is table of varchar2(30);
  type IndTypList is table of varchar2(8);

  l_owners   OwnerList;
  l_indexes  IndexList;
  l_tables   TableList;
  l_indtypes IndTypList;
  l_modulePkg varchar2(240) := g_modulePkg||'.Create_Stage_Indexes';


  CURSOR stageIndexes (tableOwner varchar2, tableName varchar2,
                       indexOwner varchar2) IS
    SELECT di.OWNER,
           di.index_name,
           di.table_name,
           decode(di.uniqueness, 'UNIQUE', ' UNIQUE ', ' ')
    FROM   dba_indexes di
    WHERE  di.table_owner = tableOwner
    AND    di.owner = indexOwner
    AND    di.table_name = tableName;

  CURSOR stageIndParts (indexOwner varchar2, indexName varchar2) IS
    SELECT dip.tablespace_name,
           dip.ini_trans,
           dip.max_trans,
           dip.initial_extent,
           dip.next_extent,
           dip.min_extent,
           dip.max_extent,
           dip.pct_increase,
           dip.pct_free,
           dip.freelists,
           dip.freelist_groups,
           decode (dip.compression, 'ENABLED', 'COMPRESS', null) compression
    FROM   dba_ind_partitions dip
    WHERE  dip.index_owner = indexOwner
    AND    dip.index_name = indexName
    AND    dip.partition_name = 'WF_LOCAL_ROLES';

  CURSOR indexColumns (indexOwner varchar2, indexName varchar2,
                       tableName varchar2) IS
    SELECT   column_name, column_position
    FROM     dba_ind_columns
    WHERE    index_owner = indexOwner
    AND      index_name = indexName
    AND      table_name = tableName
    ORDER BY column_position;

 ObjectExists    EXCEPTION;
 pragma exception_init(ObjectExists, -955);

 l_columnList VARCHAR2(2000);
 l_columnExpr VARCHAR2(2000);
 l_sql        VARCHAR2(4000);
 l_newindex varchar2(80);
 l_storage VARCHAR2(4000);

begin

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       l_modulePkg,
                       'Begin Create_Stage_Indexes('||p_sourceTable||', '||
                       p_targetTable||')');
  end if;

  --Bulding indexes on stage table as determined by the base table.
  open stageIndexes(wf_schema, p_sourceTable, wf_schema);
  fetch stageIndexes bulk collect into
    l_owners, l_indexes, l_tables, l_indtypes;
  close stageIndexes;

  if (l_owners.COUNT > 0) then
    for i in l_owners.FIRST..l_owners.LAST loop
      for a in stageIndParts(l_owners(i), l_indexes(i)) loop
        if (l_tables(i) = 'WF_USER_ROLE_ASSIGNMENTS') then
          l_newindex := l_owners(i)||'.'||REPLACE(l_indexes(i),
                                                 'USER_ROLE_ASSIGNMENTS',
                                                 'UR_ASSIGNMENTS_STAGE');
        else
         l_newindex := l_owners(i)||'.'||REPLACE(l_indexes(i), 'ROLES',
                                                       'ROLES_STAGE');
        end if;

        l_sql := 'CREATE'||l_indtypes(i)||'INDEX '||l_newindex||' ON '||
                 wf_schema||'.'||p_targetTable||' (';

        l_ColumnList := NULL; --Clear the column list.
        for b in indexColumns (l_owners(i), l_indexes(i), l_tables(i)) loop
          if (b.column_name like 'SYS_%') then --Functional index
            select COLUMN_EXPRESSION
            into   l_ColumnExpr
            from   dba_ind_expressions
            where  INDEX_NAME = l_indexes(i)
            and    INDEX_OWNER = l_owners(i)
            and    COLUMN_POSITION = b.column_position;

            l_ColumnList := l_ColumnList||REPLACE(l_ColumnExpr, '"', '')||', ';
          else
            l_ColumnList := l_ColumnList||b.column_name||', ';
          end if;
        end loop; --Column Loop
        --Need to trim the last comma and close the column list.
        l_columnList := rtrim(l_columnList, ', ');

        l_sql := l_sql||l_columnList||')';

        --Bug 2931877
        --Add the tablespace detail if provided to the storage clause
        if (g_temptablespace is not NULL) then
          l_sql := l_sql||' TABLESPACE '||g_temptablespace||' ';
        end if;

        if (a.initial_extent is not null) then
          l_storage := 'INITIAL '||to_char(a.initial_extent);
        else
          l_storage := '';
        end if;

        if (a.next_extent is not null) then
          l_storage := l_storage||' NEXT '||to_char(a.next_extent);
        end if;

        if (a.min_extent is not null) then
          l_storage := l_storage||' MINEXTENTS '||to_char(a.min_extent);
        end if;

        if (a.max_extent is not null) then
          l_storage := l_storage||' MAXEXTENTS '||to_char(a.max_extent);
        end if;

        if (a.pct_increase is not null) then
          l_storage := l_storage||' PCTINCREASE '||to_char(a.pct_increase);
        end if;

        if ((a.freelist_groups is not null) AND (a.freelists is not null)) then
          l_storage :=l_storage||' FREELIST GROUPS '||to_char(a.freelist_groups);
          l_storage :=l_storage||' FREELISTS '||to_char(a.freelists);
        end if;

        if (l_storage is not null) then
          l_sql := l_sql||' STORAGE ('||l_storage||')';
        end if;

        if (a.pct_free is not null) then
          l_sql := l_sql||' PCTFREE '||to_char(a.pct_free);
        end if;

        if (a.ini_trans is not null) then
          l_sql := l_sql||' INITRANS '||to_char(a.ini_trans);
        end if;

        if (a.max_trans is not null) then
          l_sql := l_sql||' MAXTRANS '||to_char(a.max_trans);
        end if;

        -- Bug 9193984. Compress the index if the base object is compressed.
        l_sql := l_sql||' '||g_logging ||' PARALLEL '||to_char(g_parallel)||
                 ' COMPUTE STATISTICS '||a.compression;

        begin
          execute IMMEDIATE l_sql;

        exception
          when ObjectExists then
            null;
        end;

        if ((g_logging = 'NOLOGGING') or (g_parallel > 1)) then
          execute IMMEDIATE 'alter index '||l_newindex||' LOGGING NOPARALLEL';

        end if;
      end loop; -- IndParts (index partitions) Loop
    end loop; --Index (l_owners index) Loop
  end if; -- (l_owners.COUNT > 0);

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       l_modulePkg,
                       'End Create_Stage_Indexes('||p_sourceTable||', '||
                       p_targetTable||')');
  end if;

exception
  when OTHERS then

    if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED, l_modulePkg,
                      'Exception: '||sqlerrm);

    end if;


    WF_CORE.Context('WF_LOCAL_SYNCH', 'Create_Stage_Indexes',
                     p_sourceTable, p_targetTable);
      raise;

end;

------------------------------------------------------------------------------
/*
** BuildQuery - <private>
**
**   This routine dynamically builds a column and select list based on a
**   comparison of the stage table and the seeding view.
*/
function BuildQuery (p_orig_system  in             VARCHAR2,
                     p_stage_table  in             VARCHAR2,
                     p_seed_view    in             VARCHAR2,
                     p_columnList   in out NOCOPY  VARCHAR2,
                     p_selectList   in out NOCOPY  VARCHAR2) return BOOLEAN is

    l_seedCursor     NUMBER;
    l_seedViewDesc   DBMS_SQL.DESC_TAB;
    l_stageCursor    NUMBER;
    l_stageTableDesc DBMS_SQL.DESC_TAB;
    l_rowCount       NUMBER;
    l_colCount       PLS_INTEGER;
    l_colExists      BOOLEAN;
    l_colName        VARCHAR2(30);
    l_partitionID    NUMBER;
    l_partitionName  VARCHAR2(30);
    l_sql            VARCHAR2(2000);
    l_modulePkg      VARCHAR2(240) := g_modulePkg||'.BuildQuery';

    stageIND         PLS_INTEGER;
    seedIND          PLS_INTEGER;

    noTable          EXCEPTION;
    pragma exception_init(noTable, -942);

  begin
   -- Log only
   -- BINDVAR_SCAN_IGNORE[3]
   WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                     'Begin BuildQuery('||p_orig_system||', '||p_stage_table||
                     ', '||p_seed_view||')');
    --Prepend space to the lists.
    p_columnList := ' ';
    p_selectList := ' ';

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                     'Obtaining the description of the stage table');
    --First we will get a description of the staging table in its current form
    --Open the Stage Cursor
    l_stageCursor := DBMS_SQL.open_cursor;

    --Select one row to get the description.
    -- p_stage_table came from table wf_directory_partitions
    -- also l_sql is not to be run, but to get the columns
    -- BINDVAR_SCAN_IGNORE
    l_sql := 'select * from '||p_stage_table||' where rownum < 2';
    DBMS_SQL.parse(c=>l_stageCursor, statement=>l_sql,
                  language_flag=>DBMS_SQL.native);

    --Obtain the column list
    DBMS_SQL.describe_columns(l_stageCursor, l_colCount, l_stageTableDesc);

    --Close the Stage Cursor
    DBMS_SQL.close_cursor(l_stageCursor);

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                     'Obtaining the description of the seeding view');
    --Now we will get a description of the seeding view in its current form
    --Open the Seed Cursor
    l_seedCursor := DBMS_SQL.open_cursor;

    --Select one row to get the description.
    -- p_seed_view came from table wf_directory_partitions
    -- also l_sql is not to be run, but to get the columns
    -- BINDVAR_SCAN_IGNORE
    l_sql := 'select * from '||p_seed_view||' where rownum < 2';
    DBMS_SQL.parse(c=>l_seedCursor, statement=>l_sql,
                   language_flag=>DBMS_SQL.native);

    --Obtain the column list
    DBMS_SQL.describe_columns(l_seedCursor, l_colCount, l_seedViewDesc);

    --Close the Stage Cursor
    DBMS_SQL.close_cursor(l_seedCursor);

    --Retrieve the partition id.
    select     PARTITION_ID, ORIG_SYSTEM
    into       l_partitionID, l_partitionName
    from       WF_DIRECTORY_PARTITIONS
    where      ORIG_SYSTEM = upper(p_orig_system);

    --We now have two description tables that we can compare and build our
    --column and select lists.  We will also apply the special rules in this api
    --that were in the calling apis.
    --First, we can build the column list from the stage table description.
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                     'Populating p_columnList');
    for l_colCount in l_stageTableDesc.FIRST..l_stageTableDesc.LAST loop
      p_columnList := p_columnList||l_stageTableDesc(l_colCount).COL_NAME||', ';
    end loop;

    --Now we will trim the last comma to end the column list.
    p_columnList := rtrim(p_columnList, ', ');
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                     'p_columnList is: ' ||p_columnList);

    --Populating the select list is more involved.  First we need to see if the
    --seeding view populates the column, then we need to apply any business
    --rules such as controlling the partition_id.
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                     'Populating the select list...');
    <<StageLoop>>
    for stageIND in l_stageTableDesc.FIRST..l_stageTableDesc.LAST loop
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                       'Determing if the seeding view provides column: '||

                  l_stageTableDesc(stageIND).COL_NAME);
      l_colExists := FALSE;
      <<SeedLoop>>
      for seedIND in l_seedViewDesc.FIRST..l_seedViewDesc.LAST loop
        if (l_seedViewDesc(seedIND).col_name =
            l_stageTableDesc(stageIND).col_name) then
          --Our current stage table column is provided by the view so it can be
          --used in our select and insert.
          WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                           'Column found, applying business rules.');
          l_colExists := TRUE;
          l_colName   := l_seedViewDesc(seedIND).COL_NAME;
          exit SeedLoop;
        end if;
      end loop SeedLoop;

      --------------------------------------------------------------------------
      ---  Business Rules Processing   |                                     ---
      ---------------------------------+                                     ---
      ---   For each column we need to consider the business rules we have   ---
      ---   in place.  These rules range from controlling the partition_id   ---
      ---   to handling the situation where the column is not provided by    ---
      ---   the seeding view.  We do duplicate the nullable column rule      ---
      ---   because we split the rules by tables to aid performance.         ---
      --------------------------------------------------------------------------
      if NOT (l_colExists) then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                          'Seeding View does not provide column ['||
                          l_stageTableDesc(stageIND).COL_NAME||
                          '] applying business rules for missing column.');
      end if;

      if ((l_stageTableDesc(stageIND).COL_NAME = 'LANGUAGE') and
          (p_stage_table <> 'WF_LOCAL_ROLES_TL_STAGE')) then
        if (p_orig_system IN ('PER_ROLE', 'ENG_LIST', 'FND_RESP', 'GBX') OR
            NOT l_colExists) then
          p_selectList := (p_selectList||''''||g_BaseLanguage||''''||', ');
        else
          p_selectList := (p_selectList||
                           'nvl(LANGUAGE, '''||g_BaseLanguage||'''), ');
        end if;

      elsif (l_stageTableDesc(stageIND).COL_NAME = 'PARENT_ORIG_SYSTEM') then
        if (NOT l_colExists) then
          if (p_stage_table = 'WF_UR_ASSIGNMENTS_STAGE') then
            p_selectList := (p_selectList||'ROLE_ORIG_SYSTEM, ');
          else
            p_selectList := (p_selectList||'ORIG_SYSTEM, ');
          end if;
        else
          if (p_stage_table = 'WF_UR_ASSIGNMENTS_STAGE') then
            p_selectList := (p_selectList||
                             'nvl(PARENT_ORIG_SYSTEM, ROLE_ORIG_SYSTEM), ');
          else
            p_selectList := (p_selectList||
                             'nvl(PARENT_ORIG_SYSTEM, ORIG_SYSTEM), ');
          end if;
        end if;

      elsif (l_stageTableDesc(stageIND).COL_NAME =
             'PARENT_ORIG_SYSTEM_ID') then
        if (NOT l_colExists) then
          if (p_stage_table = 'WF_UR_ASSIGNMENTS_STAGE') then
            p_selectList := (p_selectList||'ROLE_ORIG_SYSTEM_ID, ');
          else
            p_selectList := (p_selectList||'ORIG_SYSTEM_ID, ');
          end if;
        else
          if (p_stage_table = 'WF_UR_ASSIGNMENTS_STAGE') then
            p_selectList := (p_selectList||
                            'nvl(PARENT_ORIG_SYSTEM_ID, ROLE_ORIG_SYSTEM_ID), ');
          else
            p_selectList := (p_selectList||
                            'nvl(PARENT_ORIG_SYSTEM_ID, ORIG_SYSTEM_ID), ');
          end if;
        end if;

      elsif (l_stageTableDesc(stageIND).COL_NAME = 'TERRITORY') then
        if (p_orig_system IN ('PER_ROLE', 'ENG_LIST', 'FND_RESP', 'GBX') OR
            NOT l_colExists) then
          p_selectList := (p_selectList||''''||g_BaseTerritory||''''||', ');
        else
          p_selectList := (p_selectList||
                           'nvl(TERRITORY, '''||g_BaseTerritory||'''), ');
        end if;

      elsif (l_stageTableDesc(stageIND).COL_NAME = 'USER_FLAG') then
        if ((p_orig_system in ('FND_USR', 'HZ_PARTY') AND l_colExists)) then
          p_selectList := (p_selectList||'USER_FLAG, ');
        else
          p_selectList := (p_selectList||'''N'', ');
        end if;

      elsif (l_stageTableDesc(stageIND).COL_NAME = 'PARTITION_ID') then
        p_selectList := (p_selectList||''''||to_char(l_partitionID)||''', ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'CREATED_BY') and
             (NOT l_colExists)) then
        p_selectList := (p_selectList||to_char(FND_GLOBAL.user_id)||', ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'LAST_UPDATED_BY') and
             (NOT l_colExists)) then
        p_selectList := (p_selectList||to_char(FND_GLOBAL.user_id)||', ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'LAST_UPDATE_LOGIN') and
             (NOT l_colExists)) then
        p_selectList := (p_selectList||to_char(FND_GLOBAL.login_id)||', ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'LAST_UPDATE_DATE') and
             (NOT l_colExists)) then
        p_selectList := (p_selectList||'sysdate, ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'CREATION_DATE') and
             (NOT l_colExists)) then
        p_selectList := (p_selectList||'sysdate, ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'RELATIONSHIP_ID') and
              (NOT l_colExists)) then
           p_selectList := (p_selectList||'-1, ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'ASSIGNING_ROLE') and
                (NOT l_colExists)) then
           p_selectList := (p_selectList||'ROLE_NAME, ');

      elsif ((l_stageTableDesc(stageIND).COL_NAME = 'END_DATE') and
                (NOT l_colExists)) then
           p_selectList := (p_selectList||'EXPIRATION_DATE, ');

  -------------------------------------------
  -- Final Business Rules that take effect --
  -- only if none of the rules above were  --
  -- triggered.                            --
  -------------------------------------------
      elsif (NOT l_colExists) then
        if (l_stageTableDesc(stageIND).COL_NULL_OK) then
          p_selectList := (p_selectList||'NULL, ');
        else
          WF_CORE.Token('COLNAME', l_stageTableDesc(stageIND).COL_NAME);
          WF_CORE.Token('VIEWNAME', p_seed_view);
          WF_CORE.Token('STAGETABLE', p_stage_table);
          WF_CORE.Raise('WFDS_SEED_COLUMN');
        end if;

      else
        p_selectList := (p_selectList||l_colName||', ');
      end if;




    end loop StageLoop;
    --Now we will trim the last comma to end the select list.
    p_selectList := rtrim(p_selectList, ', ');
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                     'p_select list is: '||p_selectList);
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                       'End BuildQuery('||p_orig_system||', '||p_stage_table||
                       ', '||p_seed_view||') [Returning True]');
     return TRUE;
  exception
    when NoTable then
      if (substr(p_seed_view, 1, 3) = 'WF_') then
        WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                         'End BuildQuery('||p_orig_system||', '||p_stage_table||
                         ', '||p_seed_view||') [Returning False]');
        return FALSE;

      else
        WF_CORE.Token('VIEWNAME', p_seed_view);
        WF_CORE.Token('PARTITION_NAME', p_orig_system);
        WF_CORE.Raise('WFDS_BSYNC_VIEW');
      end if;
  end;

/*
** propagate_user - <described in WFLOCALS.pls>
*/
PROCEDURE propagate_user(p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_attributes       in wf_parameter_list_t,
                         p_start_date       in date,
                         p_expiration_date  in date) is

  cursor linked_per_users is
    select user_name from fnd_user
    where  employee_id = p_orig_system_id;

  cursor linked_tca_users is
    select user_name from fnd_user
    where  customer_id = p_orig_system_id;

  cursor fnd_users is
    select user_name from fnd_user
    where  user_id = p_orig_system_id;

  l_partitionID NUMBER;
  l_partitionName varchar2(30);
  l_oldOrigSystemID NUMBER;
  l_status     VARCHAR2(8);

  l_params     WF_PARAMETER_LIST_T;
  l_overWrite varchar2(2) :='N';
  l_overWrite_UserRoles varchar2(2) :='N';
  l_oldLastUpdDate date;
  l_oldLastUpdLogin number;
  l_oldLastUpdBy number;
  l_auxLastUpdDate date;
  l_auxLastUpdLogin number;
  l_auxLastUpdBy number;
  l_modulePkg varchar2(240) := g_modulePkg||'.propagate_user';
  p_aux_start_date date;
  p_aux_exp_date date;

BEGIN

  if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       l_modulePkg,
                       'Begin propagate_user('||p_orig_system||', '||
                       p_orig_system_id||','||
                       'p_attributes(wf_parameter_list_t)'||','||
                       to_char(p_start_date,WF_CORE.canonical_date_mask)||','||
                       to_char(p_expiration_date,WF_CORE.canonical_date_mask)||')');
  end if;

  seedAttributes(p_attributes,
                 p_orig_system,
                 p_orig_system_id,
                 p_expiration_date);

  if (g_overWrite) then -- <6817561>
    l_overWrite :='Y';
  end if;
  if (g_overWrite_UserRoles) then -- <6817561>
    l_overWrite_UserRoles := 'Y';
  end if;
  --
  -- tell entmgr if linked to an FND user
  --
  if (p_orig_system = 'FND_USR') then
    for myuser in fnd_users loop
      wf_local_synch.update_entmgr('USER',
                                   myuser.user_name,
                                   p_attributes,
                                   p_orig_system);
    end loop;
  elsif (p_orig_system = 'PER') then
    for myuser in linked_per_users loop
      wf_local_synch.update_entmgr('USER',
                                   myuser.user_name,
                                   p_attributes,
                                   p_orig_system);
    end loop;
  elsif (p_orig_system = 'HZ_PARTY') then
    for myuser in linked_tca_users loop
      wf_local_synch.update_entmgr('USER',
                                   myuser.user_name,
                                   p_attributes,
                                   p_orig_system);
    end loop;
  end if;

  if ( g_oldName is NOT NULL) then
    WF_DIRECTORY.assignPartition(p_orig_system, l_partitionID,
                                 l_partitionName);
    --We inline update the role and direct user/role then raise the event so
    --the rest of the work can be deferred.
   if (l_partitionID = 1) then

    UPDATE  WF_LOCAL_ROLES
    SET     NAME = g_name
       -- <6817561>
         , LAST_UPDATE_DATE = decode(l_overWrite, 'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWrite, 'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWrite, 'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
--         , CREATED_BY = decode(l_overWrite, 'Y', nvl(g_createdBy, CREATED_BY), CREATED_BY)
--         , CREATION_DATE = decode(l_overWrite, 'Y', nvl(g_creationDate, CREATION_DATE), CREATION_DATE)
       -- </6817561>
    WHERE   NAME = g_oldName
    AND     PARTITION_ID = l_partitionID;

    --Bug 28039550: Update the new user name in WF_LOCAL_ROLES_TL when user name is changed
    UPDATE  WF_LOCAL_ROLES_TL
    SET     NAME = g_name,
            LAST_UPDATE_DATE = decode(l_overWrite, 'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
            LAST_UPDATED_BY = decode(l_overWrite, 'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
            LAST_UPDATE_LOGIN = decode(l_overWrite, 'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
    WHERE   NAME = g_oldName
    AND     PARTITION_ID = l_partitionID;
   else
    UPDATE  WF_LOCAL_ROLES
    SET     NAME = g_name
       -- <6817561>
         , LAST_UPDATE_DATE = decode(l_overWrite, 'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWrite, 'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWrite, 'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
--         , CREATED_BY = decode(l_overWrite, 'Y', nvl(g_createdBy, CREATED_BY), CREATED_BY)
--         , CREATION_DATE = decode(l_overWrite, 'Y', nvl(g_creationDate, CREATION_DATE), CREATION_DATE)
       -- </6817561>
    WHERE   NAME = g_oldName
    AND     PARTITION_ID = l_partitionID
    AND     ORIG_SYSTEM = p_orig_system
    AND     ORIG_SYSTEM_ID = p_orig_system_id;

    --Bug 28039550: Update the new user name in WF_LOCAL_ROLES_TL when user name is changed
    UPDATE  WF_LOCAL_ROLES_TL
    SET     NAME = g_name,
            LAST_UPDATE_DATE = decode(l_overWrite, 'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
            LAST_UPDATED_BY = decode(l_overWrite, 'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
            LAST_UPDATE_LOGIN = decode(l_overWrite, 'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
    WHERE   NAME = g_oldName
    AND     PARTITION_ID = l_partitionID
    AND     ORIG_SYSTEM = p_orig_system
    AND     ORIG_SYSTEM_ID = p_orig_system_id;
   end if;
    --Update the user reference to itself if there is one.
    UPDATE  WF_LOCAL_USER_ROLES
    SET     USER_NAME = g_name,
            ROLE_NAME = g_name
       -- <6817561>
         , LAST_UPDATE_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
--         , CREATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_createdBy, CREATED_BY), CREATED_BY)
--         , CREATION_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_creationDate, CREATION_DATE), CREATION_DATE)
       -- </6817561>
    WHERE   USER_NAME = g_oldName
    AND     ROLE_NAME = g_oldName
    AND     PARTITION_ID = l_partitionID;


    --Update the user/roles
    UPDATE  WF_LOCAL_USER_ROLES
    SET     USER_NAME = g_Name
       -- <6817561>
         , LAST_UPDATE_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
--         , CREATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_createdBy, CREATED_BY), CREATED_BY)
--         , CREATION_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_creationDate, CREATION_DATE), CREATION_DATE)
      -- </6817561>
    WHERE   USER_NAME = g_oldName;

    --Update the user/role assignments

    UPDATE WF_USER_ROLE_ASSIGNMENTS
    SET    USER_NAME=g_name,
           ROLE_NAME=g_name,
           ASSIGNING_ROLE=g_name
       -- <6817561>
         , LAST_UPDATE_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
--         , CREATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_createdBy, CREATED_BY), CREATED_BY)
--         , CREATION_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_creationDate, CREATION_DATE), CREATION_DATE)
      -- </6817561>
    WHERE  ASSIGNING_ROLE=g_oldName
    AND    USER_NAME=g_oldName
    AND    RELATIONSHIP_ID=-1
    AND    PARTITION_ID=l_partitionId;

    UPDATE  WF_USER_ROLE_ASSIGNMENTS
    SET     USER_NAME = g_Name
       -- <6817561>
         , LAST_UPDATE_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
           LAST_UPDATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
--         , CREATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_createdBy, CREATED_BY), CREATED_BY)
--         , CREATION_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_creationDate, CREATION_DATE), CREATION_DATE)
      -- </6817561>
    WHERE   USER_NAME = g_oldName;



    WF_EVENT.AddParameterToList('OLD_USER_NAME', g_oldName, l_params);
    WF_EVENT.AddParameterToList('USER_NAME', g_name, l_params);
    WF_EVENT.AddParameterToList('ORIG_SYSTEM',p_orig_system,l_params);
    WF_EVENT.AddParameterToList('ORIG_SYSTEM_ID',to_char(p_orig_system_id),l_params);
    if(g_attributes.count>0) then
     for i in g_attributes.first..g_attributes.last loop
       WF_EVENT.AddParameterToList(upper(g_attributes(i).getName()),
       g_attributes(i).getValue(),l_params);
     end loop;
    end if;
    WF_EVENT.Raise(p_event_name=>'oracle.apps.fnd.wf.ds.user.nameChanged',
                   p_event_key=>'NameChanged:'||p_orig_system||':'||
                                to_char(p_orig_system_id)||'|'||
                                to_char(SYSDATE, wf_core.canonical_date_mask) ,
                   p_parameters=>l_params);
  end if;

  -- If the calling orig_system is 'FND_USR' and g_employeeID is not null, we
  -- need to check for one of two situations.
  --
  -- First, a new FND_USER might be created with the association to an employee
  -- in the same transaction.
  --
  -- Second, an FND_USER might be updated to be associated with the employee.
  --
  -- If there is an employee id, fnd_usr is required to populate the
  -- employeeID attribute for every call to WF_LOCAL_SYNCH.
  --
  -- If there is no employee associated, then employeeID is null.
  -- The same will hold true for a dis-association, so we will
  -- always need to check for that.
--Case 1: There is an employee ID.
  if ((p_orig_system = 'FND_USR') and
      (g_employeeID is not NULL)) then
    --FND_USR is propagating an employee association.
    --Update the Orig_system and Orig_system id for a PER record.
    g_origSystem := 'PER';
    g_origSystemID := g_employeeID;

    --We first need to make sure that the employee id was not merely changed
    --Such as user SYSADMIN associated to employee 1, is now associated to
    --employee 2.  The way we can detect this is to check for a PER role that
    --has the same username, but a different origSystemID.
    --Attempt to delete any other employee that might be still associated
    --to this user.  Then we will proceed to update/create the user.  Finally
    --we will reassign any user/roles from the previous 'PER' role to the
    --new 'PER' role.
    DELETE from WF_LOCAL_ROLES PARTITION (FND_USR) WR
    WHERE  WR.ORIG_SYSTEM = 'PER'
    AND    WR.NAME = g_name
    AND    WR.ORIG_SYSTEM_ID <> g_employeeID
    Returning WR.ORIG_SYSTEM_ID , last_update_date, last_update_login, last_updated_by
    into l_oldOrigSystemID, l_oldLastUpdDate, l_oldLastUpdLogin, l_oldLastUpdBy -- <6817561>
    ;

    begin
      Select WR.EMAIL_ADDRESS, WR.DISPLAY_NAME, WR.DESCRIPTION,
             WR.STATUS
      into   g_emailAddress, g_displayName, g_description, g_status
      From   WF_LOCAL_ROLES PARTITION (PER_ROLE) WR
      Where  WR.ORIG_SYSTEM = 'PER_ROLE'
      And    WR.ORIG_SYSTEM_ID = g_employeeID;
    exception
      when NO_DATA_FOUND then
        --The PER_ROLE does not yet exist so we will just use the data provided
        --by FND until the HR data is propagated.
        null;
    end;

    begin
      WF_DIRECTORY.SetUserAttr( user_name=>g_name,
                                orig_system=>g_origSystem,
                                orig_system_id=>g_origSystemID,
                                display_name=>g_displayName,
                                description=>g_description,
                                notification_preference=>g_notificationPref,
                                language=>g_language,
                                source_lang=>g_source_lang,
                                territory=>g_territory,
                                email_address=>g_emailAddress,
                                fax=>g_fax,
                                expiration_date=>g_expDate,
                                status=>g_status,
                                start_date=>p_start_date,
                                overWrite=>g_overWrite,
                                parent_orig_system=>g_parentOrigSys,
                                parent_orig_system_id=>g_parentOrigSysID,
                                owner_tag=>g_ownerTag,
                                last_updated_by=>g_lastUpdatedBy,
                                last_update_login=>g_lastUpdateLogin,
                                last_update_date=>g_lastUpdateDate,
                                eventParams=>g_attributes);

    exception
      when OTHERS then
        if (WF_CORE.error_name = 'WF_INVALID_USER') then
          WF_CORE.Clear;
          if NOT (g_delete) then --No reason to create a deleted user.
            l_status           := nvl(g_status,'ACTIVE');

            -- <6817561>
            if (not g_overWrite) then
              -- a potential problem here is that after processing (user create),
              -- Last_update_date < creation_date for the created user. This is
              -- just a consequence of the g_overWrite flag value
              l_auxLastUpdDate := l_oldLastUpdDate;
              l_auxLastUpdLogin := l_oldLastUpdLogin;
              l_auxLastUpdBy:= l_oldLastUpdBy;
            else
              l_auxLastUpdDate := g_lastUpdateDate;
              l_auxLastUpdLogin := g_lastUpdateLogin;
              l_auxLastUpdBy:= g_lastUpdatedBy;
            end if; -- </6817561>
            -- <Bug 8337430>. Save the current role dates for later creation
            select decode(l_overWrite, 'Y', nvl(g_expDate, p_expiration_date), WR.EXPIRATION_DATE),
                   nvl(p_start_date, WR.START_DATE)
            into   p_aux_exp_date, p_aux_start_date
            from   WF_LOCAL_ROLES PARTITION (PER_ROLE) WR
            where  WR.ORIG_SYSTEM_ID = g_employeeID;
            WF_DIRECTORY.CreateUser( name=>g_name,
                                     display_name=>g_displayName,
                                     orig_system=>g_origSystem,
                                     orig_system_id=>g_origSystemID,
                                     language=>g_language,
                                     source_lang=>g_source_lang,
                                     territory=>g_territory,
                                     description=>g_description,
                                     notification_preference=>g_notificationPref,
                                     email_address=>g_emailAddress,
                                     fax=>g_fax,
                                     status=>g_status,
                                     expiration_date=>p_aux_exp_date,
                                     start_date=>p_aux_start_date,
                                     parent_orig_system=>g_parentOrigSys,
                                     parent_orig_system_id=>g_parentOrigSysID,
                                     owner_tag=>g_ownerTag,
                                     created_by=>g_createdBy,
                                     last_updated_by=>l_auxLastUpdBy,
                                     last_update_login=>l_auxLastUpdLogin,
                                     creation_date=>g_creationDate,
                                     last_update_date=>l_auxLastUpdDate);
          end if;
        else
          raise;
        end if;
    end;

    -- We will attempt to delete an FND_USR row, if there is one to
    -- delete then we will need to re-associate any user_roles as well.

    if (g_employeeID is NOT NULL) then
      Delete from WF_LOCAL_ROLES PARTITION (FND_USR) WR
      Where  WR.ORIG_SYSTEM = p_orig_system
      And    WR.ORIG_SYSTEM_ID = p_orig_system_id
      returning last_update_date, last_update_login, last_updated_by
      into l_oldLastUpdDate, l_oldLastUpdLogin, l_oldLastUpdBy -- <6817561>
      ;

    end if;

    if (sql%rowcount > 0) then
      -- If we were able to delete an fnd_user from wf_local_roles then
      -- We can change any wf_local_user_roles over to PER.

      -- We will now reassign all active user/role relationships.
      WF_DIRECTORY.ReassignUserRoles(g_name, p_orig_system,
                                     p_orig_system_id, g_origSystem,
                                     g_origSystemID, g_lastUpdateDate,
                                     g_lastUpdatedBy, g_lastUpdateLogin
                                   , g_overWrite_UserRoles -- <6817561>
                                    );

      -- <6817561> case when we need to keep the std WHO columns old values
      if (not g_overWrite) then

        update wf_local_roles
        set last_update_date = l_oldLastUpdDate,
            last_updated_by = l_oldLastUpdBy,
            last_update_login = l_oldLastUpdLogin
        where name = g_name
        and orig_system = g_origSystem
        and orig_system_id = g_origSystemID;

      end if; -- </6817561>
   elsif (g_overWrite_UserRoles) then -- <6817561> needed to update std WHO columns

     update wf_local_user_roles
     set last_update_date = nvl(g_lastUpdateDate,last_update_date),
         last_updated_by = nvl(g_lastUpdatedBy, last_updated_by),
         last_update_login = nvl(g_lastUpdateLogin, last_update_login)
     where user_name = g_name
     and  user_orig_system=g_origSystem
     and user_orig_system_id= g_origSystemID;

     update wf_user_role_assignments
     set last_update_date = nvl(g_lastUpdateDate,last_update_date),
         last_updated_by = nvl(g_lastUpdatedBy, last_updated_by),
         last_update_login = nvl(g_lastUpdateLogin, last_update_login)
     where user_name = g_name
     and  user_orig_system=g_origSystem
     and user_orig_system_id= g_origSystemID;  -- </6817561>

   end if;

   --We now need to reassign any userRoles that may be associated to
   --an old PER role (This occurs in the case of an FND_USR being
   --switched from one employee to another).
   if (l_oldOrigSystemID is NOT NULL) then
     -- First, we must expire the existing User/Role relationship
     -- from the user to itself.
     /* WF_DIRECTORY.ReassignUserRoles was updated to handle the
        self-references
     begin
       WF_DIRECTORY.SetUserRoleAttr(user_name=>g_name,
                                    role_name=>g_name,
                                    start_date=>to_date(NULL),
                                    end_date=>sysdate,
                                    user_orig_system=>'PER',
                                    user_orig_system_id=>l_oldOrigSystemID,
                                    role_orig_system=>'PER',
                                    role_orig_system_id=>l_oldOrigSystemID,
                                    OverWrite=>FALSE,
                                    last_updated_by=>g_lastUpdatedBy,
                                    last_update_login=>g_lastUpdateLogin,
                                    last_update_date=>g_lastUpdateDate);
     exception
       when OTHERS then
         if (WF_CORE.error_name = 'WF_INVAL_USER_ROLE') then
           null;  --Nothing to expire
         else
           raise;
         end if;
     end;
     */
      -- Now we can reassign any active user/role relationships.
      WF_DIRECTORY.ReassignUserRoles(g_name, g_origSystem,
                                     l_oldOrigSystemID, g_origSystem,
                                     g_origSystemID, g_lastUpdateDate,
                                     g_lastUpdatedBy, g_lastUpdateLogin
                                   , g_overWrite_UserRoles -- <6817561>
                                     );
   end if;

  elsif ((p_orig_system = 'FND_USR') and (g_employeeID is NULL)) then
    -- FND_USR is either propagating a user who is not associated with
    -- an employee or is dis-associating one.  We will check to see if a
    --dis-association has just occured, the PER record will still exist.
    Delete from WF_LOCAL_ROLES PARTITION (FND_USR) WR
    Where  WR.ORIG_SYSTEM = 'PER'
    And    WR.NAME = g_name
    Returning WR.ORIG_SYSTEM_ID, last_update_date, last_update_login, last_updated_by
    into g_employeeID, l_oldLastUpdDate, l_oldLastUpdLogin, l_oldLastUpdBy; -- <6817561>

    if (sql%rowcount > 0) then
      l_status           := nvl(g_status,'ACTIVE');

      -- <6817561>
      if (not g_overWrite) then
              -- again, maybe last_update_date < creation_date after processing
              l_auxLastUpdDate := l_oldLastUpdDate;
              l_auxLastUpdLogin := l_oldLastUpdLogin;
              l_auxLastUpdBy:= l_oldLastUpdBy;
      else
              l_auxLastUpdDate := g_lastUpdateDate;
              l_auxLastUpdLogin := g_lastUpdateLogin;
              l_auxLastUpdBy:= g_lastUpdatedBy;
      end if; -- </6817561>

      WF_DIRECTORY.CreateUser( name=>g_name,
                               display_name=>g_displayName,
                               orig_system=>g_origSystem,
                               orig_system_id=>g_origSystemID,
                               language=>g_language,
                               source_lang=>g_source_lang,
                               territory=>g_territory,
                               description=>g_description,
                               notification_preference=>g_notificationPref,
                               email_address=>g_emailAddress,
                               fax=>g_fax,
                               status=>l_status,
                               expiration_date=>g_expDate,
                               start_date=>p_start_date,
                               parent_orig_system=>g_parentOrigSys,
                               parent_orig_system_id=>g_parentOrigSysID,
                               owner_tag=>g_ownerTag,
                               created_by=>g_createdBy,
                               last_updated_by=>l_auxLastUpdBy,
                               last_update_login=>l_auxLastUpdLogin,
                               creation_date=>g_creationDate,
                               last_update_date=>l_auxLastUpdDate);

      -- Expire the old user/role relationship with itself.
      /* WF_DIRECTORY.ReassignUserRoles was updated to handle the
        self-references
      begin
        WF_DIRECTORY.SetUserRoleAttr(user_name=>g_name,
                                     role_name=>g_name,
                                     end_date=>sysdate,
                                     user_orig_system=>'PER',
                                     user_orig_system_id=>g_employeeID,
                                     role_orig_system=>'PER',
                                     role_orig_system_id=>g_employeeID,
                                     OverWrite=>FALSE,
                                     last_updated_by=>g_lastUpdatedBy,
                                     last_update_login=>g_lastUpdateLogin,
                                     last_update_date=>g_lastUpdateDate);
      exception
        when OTHERS then
          if (WF_CORE.error_name = 'WF_INVAL_USER_ROLE') then
            null;  --Nothing to expire
          else
            raise;
          end if;
      end;
      */
      -- Now we need to update all of the user_roles back to the fnd_user.
      WF_DIRECTORY.ReassignUserRoles(g_name, 'PER', g_employeeID,
                                     p_orig_system, p_orig_system_id,
                                     g_lastUpdateDate, g_lastUpdatedBy,
                                     g_lastUpdateLogin
                                   , g_overWrite_UserRoles -- <6817561>
                                     );

    else
      --FND_USER is propagating a user that is not associated with an employee.
      g_origSystem := p_orig_system;
      g_origSystemID :=  p_orig_system_id;

      begin
        WF_DIRECTORY.SetUserAttr( user_name=>g_name,
                                  orig_system=>g_origSystem,
                                  orig_system_id=>g_origSystemID,
                                  display_name=>g_displayName,
                                  description=>g_description,
                                  notification_preference=>g_notificationPref,
                                  language=>g_language,
                                  source_lang=>g_source_lang,
                                  territory=>g_territory,
                                  email_address=>g_emailAddress,
                                  fax=>g_fax,
                                  expiration_date=>g_expDate,
                                  status=>g_status,
                                  overWrite=>g_overWrite,
                                  start_date=>p_start_date,
                                  parent_orig_system=>g_parentOrigSys,
                                  parent_orig_system_id=>g_parentOrigSysID,
                                  owner_tag=>g_ownerTag,
                                  last_updated_by=>g_lastUpdatedBy,
                                  last_update_login=>g_lastUpdateLogin,
                                  last_update_date=>g_lastUpdateDate,
                                  eventParams=>g_attributes);

      exception
        when OTHERS then
          if (WF_CORE.error_name = 'WF_INVALID_USER') then
            WF_CORE.Clear;
            if NOT (g_delete) then
              l_status           := nvl(g_status,'ACTIVE');

              WF_DIRECTORY.CreateUser( name=>g_name,
                                       display_name=>g_displayName,
                                       orig_system=>g_origSystem,
                                       orig_system_id=>g_origSystemID,
                                       language=>g_language,
                                       source_lang=>g_source_lang,
                                       territory=>g_territory,
                                       description=>g_description,
                                       notification_preference=>
                                                             g_notificationPref,
                                       email_address=>g_emailAddress,
                                       fax=>g_fax,
                                       status=>l_status,
                                       expiration_date=>g_expDate,
                                       start_date=>p_start_date,
                                       parent_orig_system=>g_parentOrigSys,
                                       parent_orig_system_id=>g_parentOrigSysID,
                                       owner_tag=>g_ownerTag,
                                       created_by=>g_createdBy,
                                       last_updated_by=>g_lastUpdatedBy,
                                       last_update_login=>g_lastUpdateLogin,
                                       creation_date=>g_creationDate,
                                       last_update_date=>g_lastUpdateDate );

            end if;
          else
            raise;

          end if;
      end;

      -- <6817561>
      if (g_overWrite_UserRoles) then
        update wf_local_user_roles
        set last_update_date = nvl(g_lastUpdateDate,last_update_date),
            last_updated_by = nvl(g_lastUpdatedBy, last_updated_by),
            last_update_login = nvl(g_lastUpdateLogin, last_update_login)
        where user_name = g_name
        and  user_orig_system=g_origSystem
        and user_orig_system_id= g_origSystemID;

        update wf_user_role_assignments
        set last_update_date = nvl(g_lastUpdateDate,last_update_date),
            last_updated_by = nvl(g_lastUpdatedBy, last_updated_by),
            last_update_login = nvl(g_lastUpdateLogin, last_update_login)
        where user_name = g_name
        and  user_orig_system=g_origSystem
        and user_orig_system_id= g_origSystemID;
      end if;
      -- </6817561>
    end if;
  elsif (p_orig_system = 'HZ_PARTY') then --<rwunderl:2729190> HZ_PARTY
    g_origSystem := p_orig_system;        --persons are now users.
    g_origSystemID := p_orig_system_id;

    begin
      WF_DIRECTORY.SetUserAttr( user_name=>g_name,
                                orig_system=>g_origSystem,
                                orig_system_id=>g_origSystemID,
                                display_name=>g_displayName,
                                description=>g_description,
                                notification_preference=>g_notificationPref,
                                language=>g_language,
                                source_lang=>g_source_lang,
                                territory=>g_territory,
                                email_address=>g_emailAddress,
                                fax=>g_fax,
                                expiration_date=>g_expDate,
                                status=>g_status,
                                overWrite=>g_overWrite,
                                start_date=>p_start_date,
                                parent_orig_system=>g_parentOrigSys,
                                parent_orig_system_id=>g_parentOrigSysID,
                                owner_tag=>g_ownerTag,
                                last_updated_by=>g_lastUpdatedBy,
                                last_update_login=>g_lastUpdateLogin,
                                last_update_date=>g_lastUpdateDate,
                                eventParams=>g_attributes );

    exception
      when OTHERS then
        if (WF_CORE.error_name = 'WF_INVALID_USER') then
          WF_CORE.Clear;
          if NOT (g_delete) then
            l_status           := nvl(g_status,'ACTIVE');

            WF_DIRECTORY.CreateUser( name=>g_name,
                                     display_name=>g_displayName,
                                     orig_system=>g_origSystem,
                                     orig_system_id=>g_origSystemID,
                                     language=>g_language,
                                     source_lang=>g_source_lang,
                                     territory=>g_territory,
                                     description=>g_description,
                                     notification_preference=>
                                                             g_notificationPref,
                                     email_address=>g_emailAddress,
                                     fax=>g_fax,
                                     status=>l_status,
                                     expiration_date=>g_expDate,
                                     start_date=>p_start_date,
                                     parent_orig_system=>g_parentOrigSys,
                                     parent_orig_system_id=>g_parentOrigSysID,
                                     owner_tag=>g_ownerTag,
                                     created_by=>g_createdBy,
                                     last_updated_by=>g_lastUpdatedBy,
                                     last_update_login=>g_lastUpdateLogin,
                                     creation_date=>g_creationDate,
                                     last_update_date=>g_lastUpdateDate  );

          end if;
        else
          raise;
        end if;
    end;

 else --Only FND_USR, and HZ_PARTY can propagate users.
   g_origSystem := p_orig_system;
   g_origSystemID := p_orig_system_id;

   if NOT (g_delete) then
     --Bug 3064439
	 propagate_role(p_orig_system, p_orig_system_id, p_attributes,
                    p_start_date, p_expiration_date);

    end if;
 end if;

 if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       l_modulePkg,
                       'End propagate_user('||p_orig_system||', '||
                       p_orig_system_id||','||
                       'p_attributes(wf_parameter_list_t)'||','||
                       to_char(p_start_date,WF_CORE.canonical_date_mask)||','||
                       to_char(p_expiration_date,WF_CORE.canonical_date_mask)||')');

 end if;


exception
  when OTHERS then
    if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
         WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,  l_modulePkg,
                      'Exception: '||sqlerrm);

    end if;

    if (g_raiseErrors) then

      WF_CORE.Context('WF_LOCAL_SYNCH', 'Propagate_User',
                      p_orig_system, p_orig_system_id);
      raise;

    else
      null;

    end if;

end propagate_user;

------------------------------------------------------------------------------
/*
** propagate_role - <described in WFLOCALS.pls>
*/
PROCEDURE propagate_role(p_orig_system      in varchar2,
                         p_orig_system_id   in number,
                         p_attributes       in wf_parameter_list_t,
                         p_start_date       in date,
                         p_expiration_date  in date) is
  l_status     VARCHAR2(8);
  l_partitionName VARCHAR2(30);
  l_partitionID   NUMBER;
  l_overWrite_UserRoles varchar2(2) :='N';
  l_overWrite varchar2(2) :='N';
  l_modulePkg varchar2(240) := g_modulePkg||'.propagate_role';


  CURSOR perRoles (c_orig_system in VARCHAR2, c_orig_system_id in NUMBER) is
    SELECT WR.NAME, WR.NOTIFICATION_PREFERENCE, WR.LANGUAGE, WR.TERRITORY,
           WR.FAX, WR.START_DATE, WR.EXPIRATION_DATE
    FROM   WF_LOCAL_ROLES PARTITION (FND_USR) WR
    WHERE  ORIG_SYSTEM = c_orig_system
    AND    ORIG_SYSTEM_ID = c_orig_system_id;

begin

 if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       l_modulePkg,
                       'Begin propagate_role('||p_orig_system||', '||
                       p_orig_system_id||','||
                       'p_attributes(wf_parameter_list_t)'||','||
                       to_char(p_start_date,WF_CORE.canonical_date_mask)||','||
                       to_char(p_expiration_date,WF_CORE.canonical_date_mask)||')');

 end if;

  if (g_overWrite) then
    l_overWrite :='Y';
  end if;

  seedAttributes(p_attributes,
                 p_orig_system,
                 p_orig_system_id,
                 p_expiration_date);

  --First check to see if a name change was communicated.
  if ( g_oldName is NOT NULL) then
    WF_DIRECTORY.assignPartition(p_orig_system, l_partitionID,
                                 l_partitionName);

    if (g_overWrite_UserRoles) then -- <6817561>
      l_overWrite_UserRoles := 'Y';
    end if;

    --We will use the partition id where we can to improve performance.
    UPDATE  WF_LOCAL_ROLES
    SET     NAME = g_name
    WHERE   NAME = g_oldName
    AND     PARTITION_ID = l_partitionID
    AND     ORIG_SYSTEM = p_orig_system
    AND     ORIG_SYSTEM_ID = p_orig_system_id;

    --Bug 28039550: Update the new user name in WF_LOCAL_ROLES_TL when user name is changed
    UPDATE  WF_LOCAL_ROLES_TL
    SET     NAME = g_name
    WHERE   NAME = g_oldName
    AND     PARTITION_ID = l_partitionID
    AND     ORIG_SYSTEM = p_orig_system
    AND     ORIG_SYSTEM_ID = p_orig_system_id;

    UPDATE  WF_LOCAL_USER_ROLES
    SET     ROLE_NAME = g_name
            -- <6817561>
          , LAST_UPDATE_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
            LAST_UPDATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
            LAST_UPDATE_LOGIN = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
            -- </6817561>
    WHERE   ROLE_NAME = g_oldName
    AND     ROLE_ORIG_SYSTEM = p_orig_system
    AND     ROLE_ORIG_SYSTEM_ID = p_orig_system_id
    AND     PARTITION_ID = l_partitionID;

    UPDATE  WF_USER_ROLE_ASSIGNMENTS
    SET     ASSIGNING_ROLE = g_name
            -- <6817561>
          , LAST_UPDATE_DATE = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
            LAST_UPDATED_BY = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
            LAST_UPDATE_LOGIN = decode(l_overWrite_UserRoles,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
            -- </6817561>
    WHERE   ASSIGNING_ROLE = g_oldName
    AND     PARTITION_ID = l_partitionID;

    --These tables are not partitioned, but do have fk references and may later
    --be partitioned on one of these partition ids so we are specifying the
    --partition id here.
    UPDATE  WF_ROLE_HIERARCHIES
    SET     SUB_NAME = g_name
    WHERE   SUB_NAME = g_oldName
    AND     PARTITION_ID = l_partitionID;

    UPDATE  WF_ROLE_HIERARCHIES
    SET     SUPER_NAME = g_name
    WHERE   SUPER_NAME = g_oldName
    AND     SUPERIOR_PARTITION_ID = l_partitionID;

    --These statements cannot take advantage of the partitions.
    UPDATE  WF_USER_ROLE_ASSIGNMENTS
    SET     ROLE_NAME = g_name
    WHERE   ROLE_NAME = g_oldName;

    WF_MAINTENANCE.PropagateChangedName(OLDNAME=>g_oldName, NEWNAME=>g_name);
  elsif (g_overWrite_UserRoles) then -- <6817561>
    WF_DIRECTORY.assignPartition(p_orig_system, l_partitionID,
                                 l_partitionName);

    --We will use the partition id where we can to improve performance.
    UPDATE  WF_LOCAL_USER_ROLES
    SET
           LAST_UPDATE_DATE = nvl(g_lastUpdateDate, LAST_UPDATE_DATE),
           LAST_UPDATED_BY = nvl(g_lastUpdatedBy, LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN)
    WHERE   ROLE_NAME = g_name
    AND     ROLE_ORIG_SYSTEM = p_orig_system
    AND     ROLE_ORIG_SYSTEM_ID = p_orig_system_id
    AND     PARTITION_ID = l_partitionID;

    UPDATE  WF_USER_ROLE_ASSIGNMENTS
    SET
           LAST_UPDATE_DATE = nvl(g_lastUpdateDate, LAST_UPDATE_DATE),
           LAST_UPDATED_BY = nvl(g_lastUpdatedBy, LAST_UPDATED_BY),
           LAST_UPDATE_LOGIN = nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN)
    WHERE   ROLE_NAME = g_name
    AND     ROLE_ORIG_SYSTEM = p_orig_system
    AND     ROLE_ORIG_SYSTEM_ID = p_orig_system_id
    AND     PARTITION_ID = l_partitionID;
    -- </6817561>

  end if;

  --Due to the association between employees and users, we have special
  --handling for calls coming from 'PER'.  If 'PER' is inserting a new
  --record (creating an employee), it cannot be associated with a user
  --since the FND User form is responsible for that.  So we will create
  --a 'PER_ROLE' to designate an employee that is not associated with a user.
  --
  --However, if the employee is already associated with a user, then this would
  --be an update call.  We need to preserve the NOTIFICATION_PREFERENCE,
  --LANGUAGE, and TERRITORY since they were defined by FND_USR.  All other
  --information can be changed by 'PER'
  if (p_orig_system = 'PER') then
    --If more than one FND_USR was assigned to the same employee
    --(user ignored warnings) then we may have multiple rows, so we use a
    --cursor to handle a one or many situation.  If there are no PER rows,
    --this portion of the code will naturally not execute.

    -- Bug 8337430. Validate the new employeeID is valid... then
    if (g_employeeID is not null) then
      update WF_LOCAL_ROLES
      set    ORIG_SYSTEM_ID=g_employeeID
      where  ORIG_SYSTEM_ID=p_orig_system_id
      and    ORIG_SYSTEM=p_orig_system;

      -- update the self-references in URA and LUR
      -- For self reference we just need to make sure to use the same 'who' caolumn values
      -- of wf_local_user_roles
      --if (g_overWrite or g_overWrite_UserRoles) then
      update WF_LOCAL_USER_ROLES
      set    ROLE_ORIG_SYSTEM_ID = g_employeeID,
             USER_ORIG_SYSTEM_ID = g_employeeID,
             LAST_UPDATE_DATE    = decode(l_overWrite,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
             LAST_UPDATED_BY     = decode(l_overWrite,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
             LAST_UPDATE_LOGIN   = decode(l_overWrite,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
      where  USER_ORIG_SYSTEM_ID = p_orig_system_id
      and    USER_ORIG_SYSTEM    = p_orig_system
      and    ROLE_ORIG_SYSTEM_ID = p_orig_system_id
      and    ROLE_ORIG_SYSTEM    = p_orig_system;

      update WF_USER_ROLE_ASSIGNMENTS
      set    ROLE_ORIG_SYSTEM_ID = g_employeeID,
             USER_ORIG_SYSTEM_ID = g_employeeID,
             LAST_UPDATE_DATE    = decode(l_overWrite,'Y', nvl(g_lastUpdateDate, LAST_UPDATE_DATE), LAST_UPDATE_DATE),
             LAST_UPDATED_BY     = decode(l_overWrite,'Y', nvl(g_lastUpdatedBy, LAST_UPDATED_BY), LAST_UPDATED_BY),
             LAST_UPDATE_LOGIN   = decode(l_overWrite,'Y', nvl(g_lastUpdateLogin, LAST_UPDATE_LOGIN), LAST_UPDATE_LOGIN)
      where  USER_ORIG_SYSTEM_ID = p_orig_system_id
      and    USER_ORIG_SYSTEM    = p_orig_system
      and    ROLE_ORIG_SYSTEM_ID = p_orig_system_id
      and    ROLE_ORIG_SYSTEM    = p_orig_system;
      -- LUR and URA's 'who' columns are to be the same as those of wf_local_roles.

    end if;
    for perRole in perRoles(p_orig_system, p_orig_system_id) loop

      -- A 'PER' record exists (this employee is associated to at least one
      -- user).  We preserved the NOTIFICATION_PREFERENCE, LANGUAGE and
      -- TERRITORY.  Now we will set the origSystem and the origSystemID.
      -- We also can setg_updateOnly, because we know the record(s) exist(s).

      WF_DIRECTORY.SetUserAttr( user_name=>perRole.NAME,
                                orig_system=>g_origSystem,
                                orig_system_id=>g_origSystemID,
                                display_name=>g_displayName,
                                description=>g_description,
                                notification_preference=>
                                                perRole.NOTIFICATION_PREFERENCE,
                                language=>perRole.LANGUAGE,
                                source_lang=>g_source_lang,
                                territory=>perRole.TERRITORY,
                                email_address=>g_emailAddress,
                                fax=>perRole.FAX,
                                expiration_date=>perRole.EXPIRATION_DATE,
                                status=>g_status,
                                overWrite=>g_overWrite,
                                start_date=>perRole.START_DATE,
                                parent_orig_system=>g_parentOrigSys,
                                parent_orig_system_id=>g_parentOrigSysID,
                                owner_tag=>g_ownerTag,
                                last_updated_by=>g_lastUpdatedBy,
                                last_update_login=>g_lastUpdateLogin,
                                last_update_date=>g_lastUpdateDate   );
      --Since we founde one or more PER records we can set the g_updateOnly flag
      --to true
      g_updateOnly := TRUE;
    end loop;

    -- No matter what the result of the above attempt to update a PER record we
    -- still need to update or create the 'PER_ROLE' record.

    g_origSystem := 'PER_ROLE';
    g_origSystemID := p_orig_system_id;
    g_name := g_origSystem||':'||g_origSystemID;

  end if;

  if (g_updateOnly) then
    begin
      WF_DIRECTORY.SetRoleAttr( role_name=>g_name,
                                orig_system=>g_origSystem,
                                orig_system_id=>g_origSystemID,
                                display_name=>g_displayName,
                                description=>g_description,
                                notification_preference=>g_notificationPref,
                                language=>g_language,
                                source_lang=>g_source_lang,
                                territory=>g_territory,
                                email_address=>g_emailAddress,
                                fax=>g_fax,
                                expiration_date=>g_expDate,
                                status=>g_status,
                                overWrite=>g_overWrite,
                                start_date=>p_start_date,
                                parent_orig_system=>g_parentOrigSys,
                                parent_orig_system_id=>g_parentOrigSysID,
                                owner_tag=>g_ownerTag,
                                last_updated_by=>g_lastUpdatedBy,
                                last_update_login=>g_lastUpdateLogin,
                                last_update_date=>g_lastUpdateDate  );

    exception
      when OTHERS then
        if (WF_CORE.error_name = 'WF_INVALID_ROLE') then
          WF_CORE.Clear;
          g_updateOnly := FALSE;

        else
          raise;

        end if;

    end;
  end if;

  if ((NOT g_delete) AND (NOT g_updateOnly)) then
    begin
      l_status           := nvl(g_status,'ACTIVE');
      WF_DIRECTORY.CreateRole( role_name=>g_name,
                               role_display_name=>g_displayName,
                               orig_system=>g_origSystem,
                               orig_system_id=>g_origSystemID,
                               language=>g_language,
                               source_lang=>g_source_lang,
                               territory=>g_territory,
                               role_description=>g_description,
                               notification_preference=>g_notificationPref,
                               email_address=>g_emailAddress,
                               fax=>g_fax,
                               status=>l_status,
                               expiration_date=>g_expDate,
                               start_date=>p_start_date,
                               parent_orig_system=>g_parentOrigSys,
                               parent_orig_system_id=>g_parentOrigSysID,
                               owner_tag=>g_ownerTag,
                               created_by=>g_createdBy,
                               last_updated_by=>g_lastUpdatedBy,
                               last_update_login=>g_lastUpdateLogin,
                               creation_date=>g_creationDate,
                               last_update_date=>g_lastUpdateDate  );

      --Add this role to the cache of newly created roles.
      if (g_trustedRoles.COUNT = 0) then
      -- Call CreateSession from WF_ROLE_HIERARCHY.AddRelationship
      -- instead of here
      -- g_trustTimeStamp := WF_ROLE_HIERARCHY.CreateSession;
        g_trustedRoles(0) := g_name;
      else
        g_trustedRoles(g_trustedRoles.LAST + 1) := g_name;
      end if;

    exception
      when OTHERS then
        if (WF_CORE.error_name = 'WF_DUP_ROLE') then
          WF_CORE.Clear;
          --Bug 3064439
          --We let the wf_directory take care of nulls
          --We just do update no new value other than the one passed.
          WF_DIRECTORY.SetRoleAttr( role_name=>g_name,
                                    orig_system=>g_origSystem,
                                    orig_system_id=>g_origSystemID,
                                    display_name=>g_displayName,
                                    description=>g_description,
                                    notification_preference=>g_notificationPref,
                                    language=>g_language,
                                    source_lang=>g_source_lang,
                                    territory=>g_territory,
                                    email_address=>g_emailAddress,
                                    fax=>g_fax,
                                    expiration_date=>g_expDate,
                                    status=>g_status,
                                    overWrite=>g_overWrite,
                                    start_date=>p_start_date,
                                    parent_orig_system=>g_parentOrigSys,
                                    parent_orig_system_id=>g_parentOrigSysID,
                                    owner_tag=>g_ownerTag,
                                    last_updated_by=>g_lastUpdatedBy,
                                    last_update_login=>g_lastUpdateLogin,
                                    last_update_date=>g_lastUpdateDate,
                                    eventParams=>g_attributes );

        else
          raise;

        end if;
    end;
  end if;
 if (wf_log_pkg.level_procedure >= fnd_log.g_current_runtime_level) then
     WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE,
                       l_modulePkg,
                       'End propagate_role('||p_orig_system||', '||
                       p_orig_system_id||','||
                       'p_attributes(wf_parameter_list_t)'||','||
                       to_char(p_start_date,WF_CORE.canonical_date_mask)||','||
                       to_char(p_expiration_date,WF_CORE.canonical_date_mask)||')');

 end if;

exception
  when OTHERS then
    if (wf_log_pkg.level_unexpected >= fnd_log.g_current_runtime_level) then
       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_UNEXPECTED,l_modulePkg,
                      'Exception: '||sqlerrm);

    end if;

    if (g_raiseErrors) then

      WF_CORE.Context('WF_LOCAL_SYNCH', 'Propagate_Role',
                      p_orig_system, p_orig_system_id);
      raise;

    else
      null;

    end if;

end;


------------------------------------------------------------------------------
/*
** propagate_user_role - (DEPRECATED) use propagateUserRole()
--Bug 2756776
--Added the p_overwrite IN parameter to allow the user to reset the
--nullable columns . In other propagate APIs we pass this parameter
--in the attribute list.

--Bug 2716191
--Added the p_raiseErrors IN parameter to allow the exception
--to be thrown to the caller. In other propagate APIs we pass this
--parameter in the attribute list.
**
*/

PROCEDURE propagate_user_role(p_user_orig_system      in varchar2,
                              p_user_orig_system_id   in number,
                              p_role_orig_system      in varchar2,
                              p_role_orig_system_id   in number,
                              p_start_date            in date,
                              p_expiration_date       in date,
                              p_overwrite             in boolean,
                              p_raiseErrors           in boolean ) is
  l_roleName     varchar2(320);
  l_userName     varchar2(320);
  l_origSystem   varchar2(30);
  l_origSystemID number;

begin

  SELECT name INTO l_roleName
  FROM   wf_roles
  WHERE  orig_system = p_role_orig_system
  AND    orig_system_id = p_role_orig_system_id;

  begin
   SELECT name INTO l_userName
   FROM   wf_roles
   WHERE  orig_system = p_user_orig_system
   AND    orig_system_id = p_user_orig_system_id;

    l_origSystem := p_user_orig_system;
    l_origSystemID := p_user_orig_system_id;
  exception
    when NO_DATA_FOUND then
      if (p_user_orig_system = 'FND_USR') then --Check for possible PER
        SELECT user_name, employee_id, 'PER'
        INTO   l_userName, l_origSystemID, l_origSystem
        FROM   FND_USER
        WHERE  USER_ID = p_user_orig_system_id;
      end if;
  end;

  begin
    WF_LOCAL_SYNCH.propagateUserRole(p_user_name=>l_userName,
               p_role_name=>l_roleName,
               p_user_orig_system=>l_origSystem,
               p_user_orig_system_id=>l_origSystemID,
               p_role_orig_system=>Propagate_user_role.p_role_orig_system,
               p_role_orig_system_id=>Propagate_user_role.p_role_orig_system_id,
               p_start_date=>Propagate_user_role.p_start_date,
               p_expiration_date=>Propagate_user_role.p_expiration_date,
               p_overwrite=>Propagate_user_role.p_overwrite,
               p_raiseErrors=>Propagate_user_role.p_raiseErrors);
  end;

exception
  when OTHERS then
    if (p_raiseErrors) then
      WF_CORE.Context('WF_LOCAL_SYNCH', 'Propagate_User_Role',
                      p_user_orig_system, p_user_orig_system_id,
                      p_role_orig_system, p_role_orig_system_id);
      raise;

    else
      null;

    end if;

end;

------------------------------------------------------------------------------
/*
** propagateUserRole - Synchronizes the WF_LOCAL_USER_ROLES table.
*/
PROCEDURE propagateUserRole(p_user_name             in varchar2,
                            p_role_name             in varchar2,
                            p_user_orig_system      in varchar2,
                            p_user_orig_system_id   in number,
                            p_role_orig_system      in varchar2,
                            p_role_orig_system_id   in number,
                            p_start_date            in date,
                            p_expiration_date       in date,
                            p_overwrite             in boolean,
                            p_raiseErrors           in boolean,
                            p_parent_orig_system    in varchar2,
                            p_parent_orig_system_id in varchar2,
                            p_ownerTag              in varchar2,
                            p_createdBy             in number,
                            p_lastUpdatedBy         in number,
                            p_lastUpdateLogin       in number,
                            p_creationDate          in date,
                            p_lastUpdateDate        in date,
                            p_assignmentReason      in varchar2,
                            p_UpdateWho             in boolean,
                            p_attributes            in WF_PARAMETER_LIST_T)
  is
    l_uorigSys     VARCHAR2(30);
    l_uorigSysID   NUMBER;
    l_rorigSys     VARCHAR2(30);
    l_rorigSysID   NUMBER;


  begin
    --Need to check if the orig_system info is null.
    if ((p_user_orig_system is NULL) or (p_user_orig_system_id is NULL) or
        (p_role_orig_system is NULL) or (p_role_orig_system_id is NULL)) then
      WF_DIRECTORY.GetRoleOrigSysInfo(p_user_name, l_uorigSys, l_uorigSysID);
      WF_DIRECTORY.GetRoleOrigSysInfo(p_role_name, l_rorigSys, l_rorigSysID);

    else
      l_uorigSys := UPPER(p_user_orig_system);
      l_uorigSysID := UPPER(p_user_orig_system_id);
      l_rorigSys := UPPER(p_role_orig_system);
      l_rorigSysID := UPPER(p_role_orig_system_id);

    end if;


    WF_DIRECTORY.SetUserRoleAttr(user_name=>p_user_name,
                                 role_name=>p_role_name,
                                 start_date=>p_start_date,
                                 end_date=>p_expiration_date,
                                 user_orig_system=>l_uorigSys,
                                 user_orig_system_id=>l_uorigSysID,
                                 role_orig_system=>l_rorigSys,
                                 role_orig_system_id=>l_rorigSysID,
                                 overWrite=>p_overwrite,
                                 parent_orig_system=>p_parent_orig_system,
                                 parent_orig_system_id=>p_parent_orig_system_ID,
                                 owner_tag=>p_ownerTag,
                                 created_by=>p_createdBy,
                                 creation_date=>p_creationDate,
                                 last_updated_by=>p_lastUpdatedBy,
                                 last_update_login=>p_lastUpdateLogin,
                                 last_update_date=>p_lastUpdateDate,
                                 assignment_reason=>p_assignmentReason,
                                 updateWho=>p_UpdateWho,
                                 eventParams=>p_attributes);


  exception
    when OTHERS then
      if (WF_CORE.error_name = 'WF_INVAL_USER_ROLE') then
        WF_CORE.Clear;
        WF_DIRECTORY.CreateUserRole(user_name=>p_user_name,
                                    role_name=>p_role_name,
                                    start_date=>p_start_date,
                                    end_date=>p_expiration_date,
                                    user_orig_system=>l_uorigSys,
                                    user_orig_system_id=>l_uorigSysID,
                                    role_orig_system=>l_rorigSys,
                                    role_orig_system_id=>l_rorigSysID,
                                    parent_orig_system=>p_parent_orig_system,
                                    parent_orig_system_id=>p_parent_orig_system_ID,
                                    owner_tag=>p_ownerTag,
                                    created_by=>p_createdBy,
                                    last_updated_by=>p_lastUpdatedBy,
                                    last_update_login=>p_lastUpdateLogin,
                                    creation_date=>p_creationDate,
                                    last_update_date=>p_lastUpdateDate,
                                    assignment_reason=>p_assignmentReason,
                                    eventParams=>p_attributes );

      else
        raise;

      end if;
  end;

------------------------------------------------------------------------------
/*
** syncUsers - <private>
*/
PROCEDURE syncUsers(p_orig_system in varchar2)
is
begin
  null; --This is obsoleted for syncRoles
end;

------------------------------------------------------------------------------
/*
** syncRolesTL - <private>
** Pass the partition_id and roletlview so as to avoid
** additional queries we have already done in SyncRolesTL
*/
PROCEDURE syncRolesTL(p_orig_system in varchar2,
                      p_partitionID  in number,
                      p_partitionName in varchar2,
                      p_roletlview   in varchar2)
is

  CURSOR dbaIndexes(tabName varchar2,
                    tabOwner varchar2) is
    SELECT INDEX_NAME
    FROM   DBA_INDEXES
    WHERE  TABLE_NAME = tabName
    AND    TABLE_OWNER = tabOwner;


  l_sql           VARCHAR2(2000);
  l_selectList    VARCHAR2(1000);
  l_columnList    VARCHAR2(1000);
  l_storageClause VARCHAR2(2000);
  l_importSuccess BOOLEAN;
  l_modulePkg     VARCHAR2(240) := g_modulePkg||'.syncRolesTL';

begin
  -- Log only
  -- BINDVAR_SCAN_IGNORE[3]
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                    'Begin syncRolesTL('||p_orig_system||', '|| p_partitionid||
                    ', '||p_partitionName||', '||p_roleTLView||')');

  --Truncate the temp table.
  WF_DDL.TruncateTable(TableName=>'WF_LOCAL_ROLES_TL_STAGE',
                       Owner=>wf_schema);

  --Drop indexes from the temp table.
  for c in dbaIndexes('WF_LOCAL_ROLES_TL_STAGE', wf_schema) loop
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Dropping index '||c.INDEX_NAME);
    WF_DDL.DropIndex(IndexName=>c.INDEX_NAME,
                     Owner=>wf_schema,
                     IgnoreNotFound=>TRUE);

  end loop;

  --Enable parallel DML
  execute IMMEDIATE 'alter session enable parallel dml';

  --Alter the session to set the sort_area_size and hash_area_size.
  execute IMMEDIATE 'alter session set sort_area_size=104857600';
  execute IMMEDIATE 'alter session set hash_area_size=204857600';

  begin
  --Select the data from WF_<origSystem>_ROLES_TL and insert into
  --WF_LOCAL_ROLES_TL_STAGE.

    if (BuildQuery (p_orig_system=>syncRolesTL.p_orig_system,
                    p_stage_table=>'WF_LOCAL_ROLES_TL_STAGE',
                    p_seed_view=>syncRolesTL.p_roletlview,
                    p_columnList=>l_columnList,
                    p_selectList=>l_selectList)) then
      -- l_selectList is controlled by us
      -- g_parallel must not be varchar
      -- p_roletlview came from wf_directory_partitions
      -- BINDVAR_SCAN_IGNORE[4]
      if g_logging='LOGGING' then
        l_sql := 'insert ';
      else
        l_sql := 'insert /*+ append parallel(T, '||to_char(g_parallel)||') */';
      end if;
      l_sql := l_sql||' into WF_LOCAL_ROLES_TL_STAGE T ('||
               l_columnList||') select /*+  parallel(R, '||
               to_char(g_parallel)||') */ '||l_selectList||
               ' from '||p_roletlview;

      WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                       'Loading stage table with: '||l_sql);

      -- g_parallel is non-varchar
      -- BINDVAR_SCAN_IGNORE[2]
      execute IMMEDIATE 'alter session force parallel query parallel '||
                         to_char(g_parallel) ;
      execute IMMEDIATE l_sql;
      execute IMMEDIATE 'alter session disable parallel query ' ;
      commit;
      l_importSuccess := TRUE;
    else
      l_importSuccess := FALSE;
    end if;

  exception
    when OTHERS then
      raise;

  end;

  if (l_importSuccess) then
    --Gather Table Statistics
    FND_STATS.Gather_Table_Stats(OWNNAME=>wf_schema,
                                 TABNAME=>'WF_LOCAL_ROLES_TL_STAGE',
                                 PERCENT=>10);

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Creating indexes on stage table.');

    Create_Stage_Indexes (p_sourceTable=>'WF_LOCAL_ROLES_TL',
                        p_targetTable=>'WF_LOCAL_ROLES_TL_STAGE');

    --Get in line to lock the table for partition exchange.
    --BINDVAR_SCAN_IGNORE[1]
    execute IMMEDIATE 'lock table '||wf_schema||'.WF_LOCAL_ROLES_TL '||
                      'in exclusive mode';

    --Partition exchange the temp table into the wf_local_roles table.
    -- wf_schema came from wf_resources
    -- p_partitionName cames from wf_directory_partions
    -- BINDVAR_SCAN_IGNORE[8]
    l_sql := 'ALTER TABLE ' ||wf_schema||'.WF_LOCAL_ROLES_TL ' ||
             'EXCHANGE PARTITION ' || p_partitionName ||
             ' WITH TABLE ' ||wf_schema||
             '.WF_LOCAL_ROLES_TL_STAGE INCLUDING '||
             'INDEXES WITHOUT VALIDATION';

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Exchanging partition with: '||l_sql);
    execute IMMEDIATE l_sql;
    commit;
  end if;
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                    'End syncRolesTL('||p_orig_system||', '|| p_partitionid||
                    ', '||p_partitionName||', '||p_roleTLView||')');
end;
------------------------------------------------------------------------------

/*
** syncRoles - <private>
*/
PROCEDURE syncRoles(p_orig_system in varchar2)
is

  CURSOR dbaIndexes(tabName varchar2,
                    tabOwner varchar2) is
    SELECT INDEX_NAME
    FROM   DBA_INDEXES
    WHERE  TABLE_NAME = tabName
    AND    TABLE_OWNER = tabOwner;

  l_partitionID   NUMBER;
  l_partitionName VARCHAR2(30);
  l_roleView      VARCHAR2(30);
  l_role_tl_view  varchar2(30);

  l_sql           VARCHAR2(2000);
  l_storageClause VARCHAR2(2000);
  l_importSuccess BOOLEAN;

  l_columnList    VARCHAR2(1000);
  l_selectList    VARCHAR2(1000);
  l_modulePkg     VARCHAR2(240) := g_modulePkg||'.syncRoles';

begin
  -- Log only
  -- BINDVAR_SCAN_IGNORE[2]
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                    'Begin syncRoles('||p_orig_system||')');
  --<rwunderl:3109120>
  --If the orig_system is FND_USR we will synch PER_ROLE first.
  if (p_orig_system = 'FND_USR') then
    syncRoles('PER_ROLE');
  end if;

  --Truncate the temp table.
  WF_DDL.TruncateTable(TableName=>'WF_LOCAL_ROLES_STAGE',
                       Owner=>wf_schema);

  --Drop indexes from the temp table.
  for c in dbaIndexes('WF_LOCAL_ROLES_STAGE', wf_schema) loop
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Dropping index '||c.INDEX_NAME);
    WF_DDL.DropIndex(IndexName=>c.INDEX_NAME,
                     Owner=>wf_schema,
                     IgnoreNotFound=>TRUE);

  end loop;

  --Check the partition this orig_system belongs to.
  WF_DIRECTORY.AssignPartition(p_orig_system,
                               l_partitionID, l_partitionName);

  --If we received a partition_id of 0, this p_orig_system cannot be
  --BulkSynched
  if (l_partitionID = 0) then
    WF_CORE.Token('ORIGSYS', p_orig_system);
    WF_CORE.Raise('WF_NOPART_ORIGSYS');

  end if;

  --Retrieve the role and the user/role view names to be used.
  SELECT trim(role_view) , trim(role_tl_view)
  INTO   l_roleView ,l_role_tl_view
  FROM   wf_directory_partitions
  WHERE  partition_id = l_partitionID;
  --Enable parallel DML
  execute IMMEDIATE 'alter session enable parallel dml';

  --Alter the session to set the sort_area_size and hash_area_size.
  execute IMMEDIATE 'alter session set sort_area_size=104857600';
  execute IMMEDIATE 'alter session set hash_area_size=204857600';

  begin
    --Select the data from WF_<origSystem>_ROLES and insert into
    --WF_LOCAL_ROLES_STAGE.
    if (BuildQuery (p_orig_system=>l_partitionName,
                    p_stage_table=>'WF_LOCAL_ROLES_STAGE',
                    p_seed_view=>nvl(l_roleView,
                                     'WF_'||l_partitionName||'_ROLES'),
                    p_columnList=>l_columnList,
                    p_selectList=>l_selectList)) then
      -- g_parallel must not be varchar2
      -- wf_schema came from wf_resources
      -- l_selectList is controlled by us
      -- l_partitionName came from wf_directory_partitions
      -- BINDVAR_SCAN_IGNORE[5]
      if g_logging='LOGGING' then
        l_sql := 'insert ';
      else
        l_sql := 'insert /*+ append parallel(T, '||to_char(g_parallel)||') */';
      end if;
      l_sql := l_sql||' into WF_LOCAL_ROLES_STAGE T '||
                 '('||l_columnList||') select /*+  parallel(R, '||
                 to_char(g_parallel)||') */ '||l_selectList ||' from '||
                 nvl(l_roleView, 'WF_'||l_partitionName||'_ROLES R ' );

       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                         'Loading stage table with: '||l_sql);
        execute IMMEDIATE 'alter session force parallel query parallel '||
                          to_char(g_parallel) ;
        execute IMMEDIATE l_sql;
        execute IMMEDIATE 'alter session disable parallel query ' ;
        commit;
        l_importSuccess := TRUE;
      else
        l_importSuccess := FALSE;
      end if;

  exception
    when OTHERS then
      raise;

  end;

  if (l_importSuccess) then
    --Gather Table Statistics
    FND_STATS.Gather_Table_Stats(OWNNAME=>wf_schema,
                                 TABNAME=>'WF_LOCAL_ROLES_STAGE',
                                 PERCENT=>10);

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Creating indexes on stage table.');

    Create_Stage_Indexes (p_sourceTable=>'WF_LOCAL_ROLES',
                        p_targetTable=>'WF_LOCAL_ROLES_STAGE');

    --Get in line to lock the table for partition exchange.
    --BINDVAR_SCAN_IGNORE[1]
    execute IMMEDIATE 'lock table '||wf_schema||'.WF_LOCAL_ROLES '||
                      'in exclusive mode';
    --Partition exchange the temp table into the wf_local_roles table.
    -- wf_schema came from wf_resources
    -- l_partitionName came from wf_directory_partitions
    -- BINDVAR_SCAN_IGNORE[4]
    l_sql := 'ALTER TABLE ' ||wf_schema||'.WF_LOCAL_ROLES ' ||
             'EXCHANGE PARTITION ' || l_partitionName ||
             ' WITH TABLE ' ||wf_schema|| '.WF_LOCAL_ROLES_STAGE INCLUDING '||
             'INDEXES WITHOUT VALIDATION';
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Exchanging partition with: '||l_sql);
    execute IMMEDIATE l_sql;
    commit;
  end if;

  --If role_tl_view is null it means the MLS is not
  --enabled for this orig_system lets set a global reference as FALSE
  --so that inserts/updates will not operate on _TL tables.
  if (l_role_tl_view is not NULL) then
     --Call SyncRolesTL to synchronise _TL table
     SyncRolesTL(p_orig_system, l_partitionID,l_partitionName,l_role_tl_view);
  end if;

  commit;
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                    'End syncRoles('||p_orig_system||')');
end;


------------------------------------------------------------------------------
/*
** syncUserRoles - <private>
*/
PROCEDURE syncUserRoles(p_orig_system in varchar2)
is
  CURSOR dbaIndexes(tabName varchar2,
                    tabOwner varchar2) is
    SELECT INDEX_NAME
    FROM   DBA_INDEXES
    WHERE  TABLE_NAME = tabName
    AND    TABLE_OWNER = tabOwner;


  l_partitionID   NUMBER;
  l_partitionName VARCHAR2(30);
  l_userRoleView  VARCHAR2(30);
  l_sql           VARCHAR2(2000);
  l_storageClause VARCHAR2(2000);
  l_importSuccess BOOLEAN;
  l_columnList    VARCHAR2(1000);
  l_selectList    VARCHAR2(1000);
  l_modulePkg     VARCHAR2(240) := g_modulePkg||'.syncUserRoles';

begin
  -- Log only
  -- BINDVAR_SCAN_IGNORE[2]
  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                    'Begin syncUserRoles('||p_orig_system||')');

  l_storageClause := ('STORAGE (INITIAL 4K NEXT 512K MINEXTENTS 1 MAXEXTENTS '||
             'UNLIMITED PCTINCREASE 0 FREELIST GROUPS 4 FREELISTS 4) '||
             ' PCTFREE 10 INITRANS 11 MAXTRANS 255 '||g_logging||' PARALLEL '||
             to_char(g_parallel)||' COMPUTE STATISTICS' );

  --Bug 2931877
  --Add the tablespace clause  if its defined.
  if (g_temptablespace is not NULL) then
      l_storageClause := ' TABLESPACE '||g_temptablespace||' '||
                         l_storageClause||' ';
  end if;

  --Truncate the temp table.
  WF_DDL.TruncateTable(TableName=>'WF_LOCAL_USER_ROLES_STAGE',
                       Owner=>wf_schema);

  --Drop indexes from the temp table.
  for c in dbaIndexes('WF_LOCAL_USER_ROLES_STAGE', wf_schema) loop
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Dropping index '||c.INDEX_NAME);
    WF_DDL.DropIndex(IndexName=>c.INDEX_NAME,
                     Owner=>wf_schema,
                     IgnoreNotFound=>TRUE);

  end loop;

  --Truncate the temp table.
  WF_DDL.TruncateTable(TableName=>'WF_UR_ASSIGNMENTS_STAGE',
                       Owner=>wf_schema);

  --Drop indexes from the temp table.
  for c in dbaIndexes('WF_UR_ASSIGNMENTS_STAGE', wf_schema) loop
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Dropping index '||c.INDEX_NAME);
    WF_DDL.DropIndex(IndexName=>c.INDEX_NAME,
                     Owner=>wf_schema,
                     IgnoreNotFound=>TRUE);

  end loop;
  --Check the partition this orig_system belongs to.
  WF_DIRECTORY.AssignPartition(p_orig_system,
                               l_partitionID, l_partitionName);

  --Retrieve the role and the user/role view names to be used.
  SELECT trim(user_role_view)
  INTO   l_userRoleView
  FROM   wf_directory_partitions
  WHERE  partition_id = l_partitionID;

  --Enable parallel DML
  execute IMMEDIATE 'alter session enable parallel dml';

  --Alter the session to set the sort_area_size and hash_area_size.
  execute IMMEDIATE 'alter session set sort_area_size=104857600';
  execute IMMEDIATE 'alter session set hash_area_size=204857600';

  begin
    if (BuildQuery (p_orig_system=>l_partitionName,
                    p_stage_table=>'WF_UR_ASSIGNMENTS_STAGE',
                    p_seed_view=>nvl(l_userRoleView,
                                     'WF_'||l_partitionName||'_UR'),
                    p_columnList=>l_columnList,
                    p_selectList=>l_selectList)) then

      -- g_parallel must be number
      -- wf_schema came from wf_resources
      -- l_columnList came from DBMS_SQL.describe_columns()
      -- l_selectList controlled by us
      -- l_userRoleView came from wf_directory_partitions
      -- l_partitionName came from wf_directory_partitions
      -- BINDVAR_SCAN_IGNORE[5]
      if g_logging='LOGGING' then
        l_sql:='insert ';
      else
        l_sql := 'insert /*+ append parallel(T, '||to_char(g_parallel)||') */';
      end if;
      l_sql:=l_sql||' into WF_UR_ASSIGNMENTS_STAGE T '||
                 '( '||l_columnList||' ) select /*+  parallel(R, '||
                 to_char(g_parallel)||') */ ' ||l_selectList||' from '||
                 nvl(l_userRoleView, 'WF_'||l_partitionName||'_UR R ' );

       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                         'Loading WF_LOCAL_USER_ROLES_STAGE with: '||l_sql);

      -- BINDVAR_SCAN_IGNORE[2]
      execute IMMEDIATE 'alter session force parallel query parallel '||
                        to_char(g_parallel) ;
      execute IMMEDIATE l_sql;
      execute IMMEDIATE 'alter session disable parallel query ' ;
      commit;

      --Now we will load all the direct assignments into the
      --WF_UR_ASSIGNMENTS_STAGE table.
      -- g_parallel must be number
      -- wf_schema came from wf_resources
      -- BINDVAR_SCAN_IGNORE[6]
      if g_logging='LOGGING' then
        l_sql := 'insert ';
      else
        l_sql := 'insert /*+ append parallel(T, '||to_char(g_parallel)||') */';
      end if;
      l_sql:=l_sql||' into WF_LOCAL_USER_ROLES_STAGE T '||
              '( USER_NAME, ROLE_NAME, USER_ORIG_SYSTEM,USER_ORIG_SYSTEM_ID, '||
              'ROLE_ORIG_SYSTEM, ROLE_ORIG_SYSTEM_ID,PARENT_ORIG_SYSTEM, '||
              'PARENT_ORIG_SYSTEM_ID, START_DATE, EXPIRATION_DATE, CREATED_BY,  '||
              'CREATION_DATE,LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, ';
      -- g_parallel must be number
      -- BINDVAR_SCAN_IGNORE[5]
      l_sql := l_sql||'USER_START_DATE, ROLE_START_DATE, '||
               'USER_END_DATE, ROLE_END_DATE, ASSIGNMENT_TYPE, '||
               'PARTITION_ID, ASSIGNMENT_REASON) '||
               'select /*+  parallel(R, '||
               ''''||to_char(g_parallel)||''') */ USER_NAME, ROLE_NAME, ';
      -- wf_schema came from wf_resources
      -- BINDVAR_SCAN_IGNORE[8]
      l_sql := l_sql|| 'USER_ORIG_SYSTEM, USER_ORIG_SYSTEM_ID,  '||
	           'ROLE_ORIG_SYSTEM, ROLE_ORIG_SYSTEM_ID,PARENT_ORIG_SYSTEM, '||
               'PARENT_ORIG_SYSTEM_ID,START_DATE,END_DATE, CREATED_BY, CREATION_DATE, '||
               'LAST_UPDATED_BY,LAST_UPDATE_DATE, LAST_UPDATE_LOGIN, USER_START_DATE, '||
               'ROLE_START_DATE, USER_END_DATE, '||
               'ROLE_END_DATE, ''D'', '||
               ''''||to_char(l_partitionID)||''', ASSIGNMENT_REASON from '||
               'WF_UR_ASSIGNMENTS_STAGE R';

       WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                         'Loading WF_UR_ASSIGNMENTS_STAGE with: '||l_sql);

       execute IMMEDIATE 'alter session force parallel query parallel '||
                          to_char(g_parallel) ;
       execute IMMEDIATE l_sql;
       execute IMMEDIATE 'alter session disable parallel query ' ;
       commit;
       l_importSuccess := TRUE;
      else
        l_importSuccess := FALSE;
      end if;

  exception
    when OTHERS then
      raise;

  end;

  --Under 3542997 we will add the functionality to continue populating the
  --WF_LOCAL_USER_ROLES_STAGE and WF_UR_ASSIGNMENTS_STAGE tables based
  --on the hierarchy.  After 3542997 is complete, orig_systems should be able
  --to both participate in hierarchies and continue to bulk synchronize.
  --At this time, an orig_system that participates in a hierarchy cannot bulk
  --synchronize.

  if (l_importSuccess) then
    --Gather Table Statistics
    FND_STATS.Gather_Table_Stats(OWNNAME=>wf_schema,
                                 TABNAME=>'WF_LOCAL_USER_ROLES_STAGE',
                                 PERCENT=>10);

    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Creating indexes on stage table.');

    Create_Stage_Indexes (p_sourceTable=>'WF_LOCAL_USER_ROLES',
                          p_targetTable=>'WF_LOCAL_USER_ROLES_STAGE');

    FND_STATS.Gather_Table_Stats(OWNNAME=>wf_schema,
                                 TABNAME=>'WF_UR_ASSIGNMENTS_STAGE',
                                 PERCENT=>10);

    Create_Stage_Indexes (p_sourceTable=>'WF_USER_ROLE_ASSIGNMENTS',
                          p_targetTable=>'WF_UR_ASSIGNMENTS_STAGE');

    --Get in line to lock the table for partition exchange.
    --BINDVAR_SCAN_IGNORE[1]
    execute IMMEDIATE 'lock table '||wf_schema||'.WF_LOCAL_USER_ROLES '||
                      'in exclusive mode';
    --Partition exchange the temp table into the wf_local_user_roles table.
    -- wf_schema came from wf_resources
    -- l_partitionName came from wf_directory_partitions
    -- BINDVAR_SCAN_IGNORE[4]
    l_sql := 'ALTER TABLE ' ||wf_schema||'.WF_LOCAL_USER_ROLES ' ||
             'EXCHANGE PARTITION ' || l_partitionName ||
             ' WITH TABLE ' ||wf_schema||
             '.WF_LOCAL_USER_ROLES_STAGE INCLUDING INDEXES WITHOUT VALIDATION';
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Exchanging partition with: '||l_sql);
    execute IMMEDIATE l_sql;
    commit;

    --Get in line to lock the table for partition exchange.
    --BINDVAR_SCAN_IGNORE[1]
    execute IMMEDIATE 'lock table '||wf_schema||'.WF_USER_ROLE_ASSIGNMENTS '||
                      'in exclusive mode';
    --Partition exchange the temp table into the wf_user_role_assignments table.
    l_sql := 'ALTER TABLE ' ||wf_schema||'.WF_USER_ROLE_ASSIGNMENTS ' ||
             'EXCHANGE PARTITION ' || l_partitionName ||
             ' WITH TABLE ' ||wf_schema||'.WF_UR_ASSIGNMENTS_STAGE '||
             'INCLUDING INDEXES WITHOUT VALIDATION';
    WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_STATEMENT, l_modulePkg,
                    'Exchanging partition with: '||l_sql);
    execute IMMEDIATE l_sql;

  end if;
  commit;

  WF_LOG_PKG.String(WF_LOG_PKG.LEVEL_PROCEDURE, l_modulePkg,
                    'End syncUserRoles('||p_orig_system||')');
end;
------------------------------------------------------------------------------
/*
** BulkSynchronization - <described in WFLOCALS.pls>
*/
PROCEDURE BulkSynchronization(p_orig_system in varchar2,
                              p_parallel_processes in number,
                              p_logging in varchar2,
                              p_raiseErrors in boolean,
                              p_temptablespace in varchar2)
is
  DuplicateKeys EXCEPTION;
  pragma exception_init(DuplicateKeys, -1452);

  cursor valid_orig_systems is
    select distinct lookup_code name
    from   fnd_lookup_values
    where  lookup_type = 'FND_WF_ORIG_SYSTEMS'
    and    language    = 'US';

  --Bug 3585554
  l_partitionID   NUMBER;
  l_partitionName VARCHAR2(30);

begin
  if ((p_parallel_processes is NULL) or (p_parallel_processes < 1) or
      (mod(p_parallel_processes, 1) <> 0)) then
    -- Retrieve g_parallel.
    select min(to_number(value))
    into   g_parallel
    from   v$parameter
    where  name in ('parallel_max_servers','cpu_count');
  else
    g_parallel := p_parallel_processes;
  end if;

  if (p_logging in ('NOLOGGING','LOGGING')) then
    g_logging := p_logging;
  else
    g_logging := 'LOGGING';
  end if;

  -- Sanity check on p_temptablespace
  if (p_temptablespace is not null and instr(p_temptablespace,';') = 0) then
    --Bug 2931877
    g_temptablespace := p_temptablespace;
  end if;

  select NLS_LANGUAGE, NLS_TERRITORY
  into   g_BaseLanguage, g_BaseTerritory
  from   FND_LANGUAGES
  where  INSTALLED_FLAG = 'B';

  if (p_orig_system = 'ALL') then
    for origsys in valid_orig_systems loop
    --<rwunderl:3659321>: 'PER' is bulk-synched through 'FND_USR'
      if (origsys.name not in ('ALL', 'PER')) then
        begin
          --<rwunderl:2823630>
          --If the orig system is hierarchy enabled, it cannot bulk synchronize
	  --Move this condition to after checking the assigned partition
	  --Maximum case they will be same
          --Bug 3585554
	  --Check if this orig system is attached to another
	  --one eg : PER to fnd_usr
	  --Checking it will avoid erroring off down the line
	  --when you try to sync and the base orig system is
	  --Hierarchy enabled
          WF_DIRECTORY.AssignPartition(origsys.name,
                               l_partitionID, l_partitionName);
          if NOT (WF_ROLE_HIERARCHY.HierarchyEnabled(l_partitionName)) then
            syncRoles(origsys.name);
            syncUserRoles(origsys.name);
	  end if;


        exception
          when DuplicateKeys then
            if (p_raiseErrors) then
              WF_CORE.Token('P_ORIG_SYSTEM', origsys.name);
              WF_CORE.Raise('WFDS_BULK_DUP_KEYS');
            else
              null;

            end if;

          when OTHERS then
            if (WF_CORE.error_name = 'WF_NOPART_ORIGSYS') then
              WF_CORE.Clear;
              null; --If we do not have a partition for this orig_system we
                    --ignore it and continue to the next.
            else
              if (p_raiseErrors) then
                raise;

              end if;
            end if;
        end;

      end if;
    end loop;
  else
    begin
      --<rwunderl:2823630>
      --If the orig system is hierarchy enabled, it cannot bulk synchronize

      --ie resolve the assigned partition and then check.
      --if NOT (WF_ROLE_HIERARCHY.HierarchyEnabled(p_orig_system)) then

      --Bug 3585554
      --Check if this orig system is attached to another
      --one eg : PER to fnd_usr
      --Checking it will avoid erroring off down the line
      --when you try to sync and the base orig system is
      --Hierarchy enabled
      WF_DIRECTORY.AssignPartition(p_orig_system,
                          l_partitionID, l_partitionName);
      if NOT (WF_ROLE_HIERARCHY.HierarchyEnabled(l_partitionName)) then
         syncRoles(p_orig_system);
         syncUserRoles(p_orig_system);
      else
         WF_CORE.Token('ORIG_SYSTEM', p_orig_system);
         WF_CORE.Raise('WFDS_ORIGSYS_HIERARCHY_ENABLED');
      end if;
    exception
      when DuplicateKeys then
        if (p_raiseErrors) then
          WF_CORE.Token('P_ORIG_SYSTEM', p_orig_system);
          WF_CORE.Raise('WFDS_BULK_DUP_KEYS');
        else
          null;

        end if;

      when OTHERS then
        if (p_raiseErrors) then
          raise;

        else
          null;

        end if;
    end;
  end if;

  g_parallel := 1;
  g_logging := 'LOGGING';

end;
------------------------------------------------------------------------------
/*
** BulkSynchronization_conc - <described in WFLOCALS.pls>
** Bug 2931877
** Added option to chose the tablespace
*/
PROCEDURE BulkSynchronization_conc(errbuf        out NOCOPY  varchar2,
                                   retcode       out NOCOPY  varchar2,
                                   p_orig_system in varchar2,
                                   p_parallel_processes in varchar2,
                                   p_logging in varchar2,
                                   p_temptablespace in varchar2,
                                   p_raiseerrors in varchar2)
is
l_temptablespace  varchar2(30);
l_raiseerrors boolean;
begin
 if ((p_temptablespace is null) OR (p_temptablespace = 'NULL')) then
   l_temptablespace := null;
 else
   --We do not require any validation of tablespace as
   --the LOV restricts the same and validates it beforehand
   l_temptablespace := p_temptablespace;
 end if;

  if(nvl(p_raiseerrors, 'Y') = 'N') then
    l_raiseerrors := FALSE;
  else
    l_raiseerrors := TRUE;
  end if;


 wf_local_synch.BulkSynchronization(p_orig_system,
                                     to_number(p_parallel_processes),
                                     p_logging,
                                     l_raiseerrors,
                                     l_temptablespace);

  retcode := '0';                     -- (successful completion)
  errbuf  := '';

  --<rwunderl:3145844> We need to commit and disable parallel DML so CP won't
  --                   choke.
  commit;
  execute IMMEDIATE 'alter session disable parallel dml';

exception
  when others then
    execute IMMEDIATE 'alter session disable parallel dml';
    if (wf_core.error_name = 'WFDS_ORIGSYS_HIERARCHY_ENABLED') then
      FND_FILE.PUT_LINE(FND_FILE.LOG, sqlerrm);
      retcode := '1';                   -- (warning)
    else
      retcode := '2';                   -- (error)
      errbuf := sqlerrm;
    end if;
    WF_CORE.Clear;
end;


------------------------------------------------------------------------------
/*
** CheckCache - <private>
**
**   Checks to see if a role is in the cache of recently created roles.
** IN
**   p_role_name VARCHAR2
** RETURNS
**   BOOLEAN
*/
FUNCTION CheckCache (p_role_name in VARCHAR2) return boolean
is
  roleIND      PLS_INTEGER;
begin
  if NOT (WF_ROLE_HIERARCHY.validateSession(g_trustTimeStamp)) then
    g_trustedRoles.DELETE;
    return FALSE;
  end if;

  roleIND := g_trustedRoles.FIRST;
  while (roleIND is NOT NULL) loop
    if (g_trustedRoles(roleIND) = p_role_name) then
      return TRUE;
    end if;
    roleIND := g_trustedRoles.NEXT(roleIND);
  end loop;

  --If we did not yet return true, then the name is not in cache, so we
  --return false.
  return FALSE;
end;

------------------------------------------------------------------------------
/*
** DeleteCache - <private>
**
**   Removes a role from the cache of newly created roles.
** IN
**   p_role_name VARCHAR2
*/
PROCEDURE DeleteCache (p_role_name in VARCHAR2)
is
  roleIND PLS_INTEGER;
begin
  roleIND := g_trustedRoles.FIRST;
  while (roleIND is NOT NULL) loop
    if (g_trustedRoles(roleIND) = p_role_name) then
      g_trustedRoles.DELETE(roleIND);
    end if;
    roleIND := g_trustedRoles.NEXT(roleIND);
  end loop;
end;

------------------------------------------------------------------------------
/*
** ValidateUserRoles - Validates and corrects denormalized user and role
**                     information in user/role relationships.
*/
PROCEDURE ValidateUserRoles(p_BatchSize in NUMBER,
                            p_username    in varchar2 default null,
                            p_rolename    in varchar2 default null,
                            p_check_dangling in BOOLEAN,
                            p_check_missing_ura in BOOLEAN,
                            p_UpdateWho in BOOLEAN,
                            p_parallel_processes in number) is
begin
  WF_MAINTENANCE.ValidateUserRoles(p_BatchSize,
                                   p_username,
                                   p_rolename,
                                   p_check_dangling,
                                   p_check_missing_ura,
                                   p_UpdateWho,
                                   p_parallel_processes);
end;

------------------------------------------------------------------------------
/*
** ValidateUserRoles_conc - CM cover routine for ValidateUserRoles()
*/
PROCEDURE ValidateUserRoles_conc(errbuf        out NOCOPY varchar2,
                                 retcode       out NOCOPY varchar2,
                                 p_BatchSize   in varchar2,
                                 p_username    in varchar2 default null,
                                 p_rolename    in varchar2 default null,
                                 p_check_dangling in varchar2,
                                 p_check_missing_ura in varchar2,
                                 p_UpdateWho in varchar2,
                                 p_parallel_processes in number) is

  l_checkDangling BOOLEAN;
  l_checkMissingURA BOOLEAN;
  l_UpdateWho BOOLEAN;
begin

  if(nvl(p_check_missing_ura, 'N') = 'Y') then
    l_checkMissingURA := TRUE;
  else
    l_checkMissingURA := FALSE;
  end if;

  if(nvl(p_check_dangling, 'N') = 'Y') then
    l_checkDangling := TRUE;
  else
    l_checkDangling := FALSE;
  end if;

  if(nvl(p_UpdateWho,'N')='Y') then
    l_UpdateWho := TRUE;
  else
    l_UpdateWho := FALSE;
  end if;

  ValidateUserRoles(to_number(p_BatchSize), p_username, p_rolename, l_checkDangling,
                    l_checkMissingURA,l_UpdateWho, p_parallel_processes);
  retcode := '0'; -- (successful completion)
  errbuf  := '';
exception
  when OTHERS then
      retcode := '2'; -- (error)
      errbuf := sqlerrm;
end;
end WF_LOCAL_SYNCH;

/

  GRANT EXECUTE ON "APPS"."WF_LOCAL_SYNCH" TO "NONAPPS";
