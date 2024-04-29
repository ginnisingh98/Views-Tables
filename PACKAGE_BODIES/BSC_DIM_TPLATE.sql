--------------------------------------------------------
--  DDL for Package Body BSC_DIM_TPLATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_DIM_TPLATE" AS
/* $Header: BSCUDIMB.pls 120.0 2005/06/01 16:56:48 appldev noship $ */

G_Pro_Tbl       BSC_TEMPLATE.Project_Tbl_Type;
G_DF_Tbl        BSC_TEMPLATE.Dfamily_Tbl_Type;
G_DC_Tbl        BSC_TEMPLATE.Proj_Dim_Cols_Tbl_Type;


l_num_acct_type         number := 3;
l_num_account           number := 6;
l_num_project           number := 12;

/*===========================================================================+
|
|   Name:          Create_Dimensions
|
|   Description:   To create Accout dimension for P/L KPI
|
|   History:
|       02-APR-1999   Alex Yang             Created.
|    12/22/1999   Henry Camacho Modified to Model 4.0
+============================================================================*/

Function Create_Dimensions
Return Boolean
Is
    l_acct_type     BSC_DIM_TPLATE.Acct_Type_Tbl_Type;
    l_account       BSC_DIM_TPLATE.Acct_Tbl_Type;

    l_system_type       varchar2(60);
    is_cross_template   boolean;

    l_code          number;
    l_code_name     varchar2(30); -- ADRAO Changed to VARCHAR2(30)
    l_project_count     number(3);

    l_count         number;
    l_cursor        number;
        l_ignore        number;
    l_sql_stmt      varchar2(2000);
    l_debug_stmt        varchar2(2000);

    l_num_of_levels number;
    l_num_of_family number;
    l_object_type      varchar2(30);
Begin
  l_project_count:=0;
  l_count:=0;
  l_debug_stmt:='DEBUG: ';
  l_object_type:= 'BSC_D_TYPE_OF_ACCOUNT';
  is_cross_template:=FALSE;
  l_acct_type(0).code  := 0;    l_acct_type(0).name := 'ALL';
  l_acct_type(1).code  := 1;    l_acct_type(1).name := 'Incomes';
  l_acct_type(2).code  := 2;    l_acct_type(2).name := 'Expenses';
  l_acct_type(3).code  := 3;    l_acct_type(3).name := 'Profit';

  l_account(0).code       := 0;
  l_account(0).name      := 'ALL';
  l_account(0).acct_type := 0;
  l_account(0).position  := 0;

  l_account(1).code       := 1;
  l_account(1).name      := 'Sales';
  l_account(1).acct_type := 1;
  l_account(1).position  := 1;

  l_account(2).code       := 2;
  l_account(2).name      := 'Cost of Sales';
  l_account(2).acct_type := 2;
  l_account(2).position  := 2;

  l_account(3).code       := 3;
  l_account(3).name      := 'Other Incomes';
  l_account(3).acct_type := 1;
  l_account(3).position  := 3;

  l_account(4).code       := 4;
  l_account(4).name      := 'Payroll Exp.';
  l_account(4).acct_type := 2;
  l_account(4).position  := 4;

  l_account(5).code       := 5;
  l_account(5).name      := 'Other Expenses';
  l_account(5).acct_type := 2;
  l_account(5).position  := 5;

  l_account(6).code       := 6;
  l_account(6).name      := 'Net Profit';
  l_account(6).acct_type := 3;
  l_account(6).position  := 6;


  -- check template type (Tab or Cross)
  Select PROPERTY_VALUE
  Into   l_system_type
  From   BSC_SYS_INIT
  Where  PROPERTY_CODE = 'MODEL_TYPE';

  if (l_system_type = '1') then
     Is_cross_template := TRUE;
  end if;

  -- create Account Type dimension table
  l_object_type := 'BSC_D_TYPE_OF_ACCOUNT';
  Select count(*)
  Into   l_count
  From   USER_OBJECTS
  Where  OBJECT_NAME = l_object_type;

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_D_TYPE_OF_ACCOUNT';
      l_debug_stmt := l_sql_stmt;

     BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_D_TYPE_OF_ACCOUNT');
  end if;

  l_sql_stmt := 'Create Table BSC_D_TYPE_OF_ACCOUNT ('  ||
                   'CODE           Number   NOT NULL,'||
                   'LANGUAGE       Varchar2(4)   NOT NULL,'||
                   'SOURCE_LANG    Varchar2(4)   NOT NULL,'||
                   'USER_CODE      Varchar2(5), ' ||
                   'NAME       Varchar2(20))'||
                   ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type)||
                   ' '||BSC_APPS.bsc_storage_clause;

  l_debug_stmt := l_sql_stmt;

  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_D_TYPE_OF_ACCOUNT');


  l_sql_stmt := 'CREATE UNIQUE INDEX BSC_D_TYPE_OF_ACCOUNT_U1 ON BSC_D_TYPE_OF_ACCOUNT (CODE,LANGUAGE)'||
                ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type)||
                ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;
 BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_index,
                'BSC_D_TYPE_OF_ACCOUNT_U1');

 --  Create View
  l_sql_stmt := 'Create or replace view BSC_D_2_VL AS ('  ||
        ' SELECT CODE,'||
        ' USER_CODE,'||
        ' NAME'||
        ' FROM BSC_D_TYPE_OF_ACCOUNT '||
        ' WHERE LANGUAGE = userenv(''LANG''))';

  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_view,
                'BSC_D_2_VL');

 --  Create Input table
  l_object_type := 'BSC_DI_2';
  Select count(*)
  Into   l_count
  From   USER_OBJECTS
  Where  OBJECT_NAME = l_object_type;

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_DI_2';
      l_debug_stmt := l_sql_stmt;

     BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_DI_2');
  end if;

  l_sql_stmt := 'Create Table BSC_DI_2 ('  ||
                   'USER_CODE      Varchar2(5), ' ||
                   'NAME       Varchar2(20))'||
                   ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_table_tbs_type)||
                   ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;

  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_DI_2');

  l_sql_stmt := 'CREATE UNIQUE INDEX BSC_DI_2_U1 ON BSC_DI_2 (USER_CODE)'||
                ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_index_tbs_type)||
                ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_index,
                'BSC_DI_2_U1');


  -- create Account dimension table

  l_object_type := 'BSC_D_ACCOUNT';
  Select count(*)
  Into   l_count
  From   USER_OBJECTS
  Where  OBJECT_NAME = l_object_type;

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_D_ACCOUNT';
      l_debug_stmt := l_sql_stmt;

     BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_D_ACCOUNT');
  end if;

  l_sql_stmt := 'Create Table BSC_D_ACCOUNT ( ' ||
                    'CODE  Number NOT NULL,' ||
                    'LANGUAGE       Varchar2(4)   NOT NULL,'||
                    'SOURCE_LANG    Varchar2(4)   NOT NULL,'||
                    'USER_CODE Varchar2(5), '  ||
                    'NAME   Varchar2(20), ' ||
                    'Typ_of_Acc_Code Number, '    ||
                    'Typ_of_Acc_Code_Usr Varchar2(5), '  ||
                    'Position Number(2))'||
                    ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type)||
                    ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;

  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_D_ACCOUNT');

  l_sql_stmt := 'CREATE UNIQUE INDEX BSC_D_ACCOUNT_U1 ON BSC_D_ACCOUNT (CODE,LANGUAGE)'||
                ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type)||
                ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;
 BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_index,
                'BSC_D_ACCOUNT_U1');
 --  Create View
  l_sql_stmt := 'Create or replace view BSC_D_0_VL AS ('  ||
        ' SELECT CODE,'||
        ' USER_CODE,'||
        ' NAME,'||
        ' Typ_of_Acc_Code,'||
        ' Typ_of_Acc_Code_Usr,'||
        ' Position'||
        ' FROM BSC_D_ACCOUNT '||
        ' WHERE LANGUAGE = userenv(''LANG''))';

  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_view,
                'BSC_D_0_VL');

 --  Create Input table
  l_object_type := 'BSC_DI_0' ;
  Select count(*)
  Into   l_count
  From   USER_OBJECTS
  Where  OBJECT_NAME = l_object_type ;

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_DI_0';
      l_debug_stmt := l_sql_stmt;

     BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_DI_0');
  end if;

  l_sql_stmt := 'Create Table BSC_DI_0 ('  ||
                   'USER_CODE      Varchar2(5), ' ||
                   'NAME       Varchar2(20), '||
                   'Typ_of_Acc_Code_Usr Varchar2(5),'||
                   'Position Number(2))'||
                   ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_table_tbs_type)||
                   ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;

  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_DI_0');

  l_sql_stmt := 'CREATE UNIQUE INDEX BSC_DI_0_U1 ON BSC_DI_0 (USER_CODE)'||
                ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_index_tbs_type)||
                ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_index,
                'BSC_DI_0_U1');


  -- create Subaccount Type dimension table

  l_object_type := 'BSC_D_SUBACCOUNT' ;
  Select count(*)
  Into   l_count
  From   USER_OBJECTS
  Where  OBJECT_NAME = l_object_type ;

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_D_SUBACCOUNT';
      l_debug_stmt := l_sql_stmt;

      BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_D_SUBACCOUNT');
  end if;

  l_sql_stmt := 'Create Table BSC_D_SUBACCOUNT ( ' ||
                   'CODE    Number NOT NULL,' ||
                   'LANGUAGE       Varchar2(4)   NOT NULL,'||
                   'SOURCE_LANG    Varchar2(4)   NOT NULL,'||
                   'USER_CODE Varchar2(5), '  ||
                   'NAME Varchar2(20), ' ||
                   'Account_Code Number, '    ||
                   'Account_Code_Usr Varchar2(5))'||
                   ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type)||
                   ' '||BSC_APPS.bsc_storage_clause;

  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_D_SUBACCOUNT');

  l_sql_stmt := 'CREATE UNIQUE INDEX BSC_D_SUBACCOUNT_U1 ON BSC_D_SUBACCOUNT (CODE,LANGUAGE)'||
                ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type)||
                ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;

  BSC_APPS.DO_DDL(l_sql_stmt,
        ad_ddl.create_index,
                'BSC_D_SUBACCOUNT_U1');

 --  Create View
  l_sql_stmt := 'Create or replace view BSC_D_1_VL AS ('  ||
        ' SELECT CODE,'||
        ' USER_CODE,'||
        ' NAME,'||
        ' Account_Code ,'||
        ' Account_Code_Usr'||
        ' FROM BSC_D_SUBACCOUNT '||
        ' WHERE LANGUAGE = userenv(''LANG''))';

  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_view,
                'BSC_D_1_VL');

 --  Create Input table

  l_object_type := 'BSC_DI_1' ;
  Select count(*)
  Into   l_count
  From   USER_OBJECTS
  Where  OBJECT_NAME = l_object_type;

  if (l_count <> 0) then
      l_sql_stmt := 'Drop Table BSC_DI_1';
      l_debug_stmt := l_sql_stmt;

     BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_DI_1');
  end if;

  l_sql_stmt := 'Create Table BSC_DI_1 ('  ||
                   'USER_CODE      Varchar2(5), ' ||
                   'NAME       Varchar2(20), '||
                   'Account_Code_Usr Varchar2(5))'||
                   ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_table_tbs_type)||
                   ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;

  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_DI_1');

  l_sql_stmt := 'CREATE UNIQUE INDEX BSC_DI_1_U1 ON BSC_DI_1 (USER_CODE)'||
                ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_index_tbs_type)||
                ' '||BSC_APPS.bsc_storage_clause;
  l_debug_stmt := l_sql_stmt;
  BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_index,
                'BSC_DI_1_U1');

  if (is_cross_template) then

      l_object_type := 'BSC_D_PROJECT' ;
      Select count(*)
      Into   l_project_count
      From   USER_OBJECTS
      Where  OBJECT_NAME = l_object_type;

      if (l_project_count <> 0) then
          l_sql_stmt := 'Drop Table BSC_D_PROJECT';
          l_debug_stmt := l_sql_stmt;
       BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.drop_table,
                'BSC_D_PROJECT');

      end if;

      -- create Project dimension table

      l_sql_stmt := 'Create Table BSC_D_PROJECT (' ||
            'CODE      NUMBER   NOT NULL,'     ||
                    'LANGUAGE       Varchar2(4)   NOT NULL,'||
                    'SOURCE_LANG    Varchar2(4)   NOT NULL,'||
            'USER_CODE  VARCHAR2(5),'   ||
            'NAME     VARCHAR2(20))'||
            ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_table_tbs_type)||
            ' '||BSC_APPS.bsc_storage_clause;

      l_debug_stmt := l_sql_stmt;
      BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_table,
                'BSC_D_PROJECT');

      l_sql_stmt := 'CREATE UNIQUE INDEX BSC_D_PROJECT_U1 ON BSC_D_PROJECT (CODE,LANGUAGE)'||
                    ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.dimension_index_tbs_type)||
                    ' '||BSC_APPS.bsc_storage_clause;
      l_debug_stmt := l_sql_stmt;
      BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_index,
                'BSC_D_PROJECT_U1');
     --  Create View
      l_sql_stmt := 'Create or replace view BSC_D_3_VL AS ('  ||
        ' SELECT CODE,'||
        ' USER_CODE,'||
        ' NAME'||
        ' FROM BSC_D_PROJECT '||
        ' WHERE LANGUAGE = userenv(''LANG''))';

      l_debug_stmt := l_sql_stmt;
      BSC_APPS.DO_DDL(l_sql_stmt,
                ad_ddl.create_view,
                'BSC_D_3_VL');
     --  Create Input table
      l_object_type := 'BSC_DI_3' ;
      Select count(*)
      Into   l_count
      From   USER_OBJECTS
      Where  OBJECT_NAME = l_object_type;

      if (l_count <> 0) then
          l_sql_stmt := 'Drop Table BSC_DI_3';
          l_debug_stmt := l_sql_stmt;

         BSC_APPS.DO_DDL(l_sql_stmt,
                    ad_ddl.drop_table,
                    'BSC_DI_1');
      end if;

      l_sql_stmt := 'Create Table BSC_DI_3 ('  ||
                       'USER_CODE      Varchar2(5), ' ||
                       'NAME       Varchar2(20))'||
                        ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_table_tbs_type)||
                        ' '||BSC_APPS.bsc_storage_clause;

      l_debug_stmt := l_sql_stmt;

      BSC_APPS.DO_DDL(l_sql_stmt,
                    ad_ddl.create_table,
                    'BSC_DI_1');

      l_sql_stmt := 'CREATE UNIQUE INDEX BSC_DI_3_U1 ON BSC_DI_3 (USER_CODE)'||
                    ' TABLESPACE '||BSC_APPS.Get_Tablespace_Name(BSC_APPS.input_index_tbs_type)||
                    ' '||BSC_APPS.bsc_storage_clause;
      l_debug_stmt := l_sql_stmt;
      BSC_APPS.DO_DDL(l_sql_stmt,
                    ad_ddl.create_index,
                    'BSC_DI_3_U1');


      -- populating Project dimension value

     For i_project In 0 .. (l_num_project)
     Loop
       l_code := i_project;

       if l_code = 0 then
         l_code_name := 'ALL';
       else
         l_code_name := 'Project ' || to_char(l_code);
       end if;

--       l_sql_stmt := 'Insert Into BSC_D_PROJECT (CODE, USER_CODE, NAME) Values ( ' ||
--         to_char(l_code) || ',  ' || to_char(l_code) || ', '
--         || '''' || l_code_name  || ''')';

       l_sql_stmt := 'Insert Into BSC_D_PROJECT  (CODE, USER_CODE, NAME,LANGUAGE,SOURCE_LANG) Values ( '||
                   ' SELECT '||to_char(l_code) ||' AS CODE,' ||
                    'to_char('||to_char(l_code)||') AS USER_CODE, ' ||
                    ' ' || l_code_name|| ' AS NAME, ' ||
            ' LNG.LANGUAGE_CODE AS LANGUAGE,USERENV(''LANG'') AS SOURCE_LANG '||
            ' FROM DUAL , ' ||
            ' FND_LANGUAGES LNG ';
    l_sql_stmt := l_sql_stmt || ' AND LNG.INSTALLED_FLAG IN (''I'',''B'')';


       l_debug_stmt := l_sql_stmt;
       l_cursor := DBMS_SQL.Open_Cursor;
       DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
       l_ignore := DBMS_SQL.Execute(l_cursor);
       DBMS_SQL.Close_Cursor(l_cursor);
    End Loop;

  end if;  -- is_cross_template


  -- Insert records into BSC_D_TYPE_OF_ACCOUNT

  For i_acct_type In 0 .. (l_num_acct_type)
  Loop
    -- FEM_ALIAS translation
    l_sql_stmt := 'INSERT INTO  BSC_D_TYPE_OF_ACCOUNT ' ||
               ' (CODE,LANGUAGE,SOURCE_LANG,USER_CODE,NAME) ' ||
                   ' SELECT '||l_acct_type(i_acct_type).code||' AS CODE,' ||
            ' LNG.LANGUAGE_CODE AS LANGUAGE,USERENV(''LANG'') AS SOURCE_LANG,'||
                    'to_char('||l_acct_type(i_acct_type).code||') AS USER_CODE, ' ||
                    ' SUBSTRB(FEM_ALIAS.MEANING,1,20) AS NAME ' ||
            ' FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALIAS, ' ||
            '      FND_LANGUAGES LNG ';
    -- To get ALL from commun
        if l_acct_type(i_acct_type).code = 0 then
        l_sql_stmt := l_sql_stmt || ' WHERE FEM_ALIAS.LOOKUP_TYPE =''BSC_UI_COMMON'' AND FEM_ALIAS.LOOKUP_CODE = ''ALL''';
    else
        l_sql_stmt := l_sql_stmt || ' WHERE FEM_ALIAS.LOOKUP_TYPE =''BSC_TPLATE_TAB_ACC_TYPE_ITEMS'' AND FEM_ALIAS.LOOKUP_CODE = '''||l_acct_type(i_acct_type).code||'''';
    end if;
    -- Only for current language

        l_sql_stmt := l_sql_stmt || ' AND FEM_ALIAS.LANGUAGE =userenv(''LANG'')';
    l_sql_stmt := l_sql_stmt || ' AND LNG.INSTALLED_FLAG IN (''I'',''B'')';

    l_debug_stmt := l_sql_stmt;
    l_cursor := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
    l_ignore := DBMS_SQL.Execute(l_cursor);
    DBMS_SQL.Close_Cursor(l_cursor);

  End Loop;

  -- Insert records into BSC_D_ACCOUNT and BSC_D_SUBACCOUNT

  For i_acct_ind In 0 .. (l_num_account)
  Loop

    -- FEM_ALIAS translation
    l_sql_stmt := 'INSERT INTO  BSC_D_ACCOUNT ' ||
               '(CODE,LANGUAGE,SOURCE_LANG,USER_CODE,NAME,TYP_OF_ACC_CODE,TYP_OF_ACC_CODE_USR,POSITION) ' ||
                   ' SELECT '||l_account(i_acct_ind).code||' AS CODE, '||
            ' LNG.LANGUAGE_CODE AS LANGUAGE,USERENV(''LANG'') AS SOURCE_LANG,'||
                    'to_char('||l_account(i_acct_ind).code||') AS USER_CODE, '||
                    'SUBSTRB(FEM_ALIAS.MEANING,1,20) AS NAME,'||
            l_account(i_acct_ind).acct_type||' AS TYP_OF_ACC_CODE, '||
            l_account(i_acct_ind).acct_type||' AS TYP_OF_ACC_CODE_USR, '||
            l_account(i_acct_ind).position ||' AS POSITION '||
            'FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALIAS,'||
            '      FND_LANGUAGES LNG ';
    -- To get ALL from commun
        if l_account(i_acct_ind).code = 0 then
        l_sql_stmt :=l_sql_stmt || ' WHERE FEM_ALIAS.LOOKUP_TYPE =''BSC_UI_COMMON'' AND
                  FEM_ALIAS.LOOKUP_CODE = ''ALL''';
    else
        l_sql_stmt :=l_sql_stmt || ' WHERE FEM_ALIAS.LOOKUP_TYPE =''BSC_TPLATE_TAB_ACC_ITEMS'' AND
                  FEM_ALIAS.LOOKUP_CODE = '''||l_account(i_acct_ind).code||'''';
    end if;
    -- Only for current language
        l_sql_stmt := l_sql_stmt || ' AND FEM_ALIAS.LANGUAGE =userenv(''LANG'')';
    l_sql_stmt := l_sql_stmt || ' AND LNG.INSTALLED_FLAG IN (''I'',''B'')';

    l_debug_stmt := l_sql_stmt;
    l_cursor := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
    l_ignore := DBMS_SQL.Execute(l_cursor);
    DBMS_SQL.Close_Cursor(l_cursor);

    -- FEM_ALIAS translation -Same itemns from maccount
    l_sql_stmt := 'INSERT INTO  BSC_D_SUBACCOUNT ' ||
               ' (CODE,LANGUAGE,SOURCE_LANG,USER_CODE,NAME,ACCOUNT_CODE,ACCOUNT_CODE_USR) ' ||
                   ' SELECT '||l_account(i_acct_ind).code||' AS CODE, ' ||
            ' LNG.LANGUAGE_CODE AS LANGUAGE,USERENV(''LANG'') AS SOURCE_LANG,'||
                       ' to_char('||l_account(i_acct_ind).code||') AS USER_CODE,' ||
                    ' SUBSTRB(FEM_ALIAS.MEANING,1,20) AS NAME, '||
            l_account(i_acct_ind).code||' AS ACCOUNT_CODE, '||
            l_account(i_acct_ind).code||' AS ACCOUNT_CODE_USR'||
            ' FROM '||BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALIAS, ' ||
            '      FND_LANGUAGES LNG ';
    -- To get ALL from commun
        if l_account(i_acct_ind).code = 0 then
        l_sql_stmt :=l_sql_stmt || ' WHERE FEM_ALIAS.LOOKUP_TYPE =''BSC_UI_COMMON'' AND
                  FEM_ALIAS.LOOKUP_CODE = ''ALL''';
    else
        l_sql_stmt :=l_sql_stmt || ' WHERE FEM_ALIAS.LOOKUP_TYPE =''BSC_TPLATE_TAB_ACC_ITEMS'' AND
                  FEM_ALIAS.LOOKUP_CODE = '''||l_account(i_acct_ind).code||'''';
    end if;
    -- Only for current language
        l_sql_stmt := l_sql_stmt || ' AND FEM_ALIAS.LANGUAGE =userenv(''LANG'')';
    l_sql_stmt := l_sql_stmt || ' AND LNG.INSTALLED_FLAG IN (''I'',''B'')';


    l_debug_stmt := l_sql_stmt;
    l_cursor := DBMS_SQL.Open_Cursor;
    DBMS_SQL.Parse(l_cursor, l_sql_stmt, DBMS_SQL.native);
    l_ignore := DBMS_SQL.Execute(l_cursor);
    DBMS_SQL.Close_Cursor(l_cursor);

  End Loop;  -- i_acct_ind

  --
  -- Configure Dimensions
  --

  G_Pro_Tbl.Delete;
  G_DF_Tbl.Delete;
  G_DC_Tbl.Delete;

  -- define Account dimension levels
--2828685
  G_Pro_Tbl(0).Dim_level_id   := 2;
  G_Pro_Tbl(0).Table_name  := 'BSC_D_TYPE_OF_ACCOUNT';
  G_Pro_Tbl(0).Table_Type    := 1;
  G_Pro_Tbl(0).Level_pk_col  := 'TYP_OF_ACC_CODE';
  G_Pro_Tbl(0).Abbreviation  := 'TyOfAc';
  G_Pro_Tbl(0).Value_Order   := 2;
  G_Pro_Tbl(0).Comp_Order    := 0;
  G_Pro_Tbl(0).Custom_Group  := 0;
  G_Pro_Tbl(0).Name      := 'Account Type';
  G_Pro_Tbl(0).Help      := 'Account Types';
  G_Pro_Tbl(0).Caption_Tot   := 'ALL';
  G_Pro_Tbl(0).Caption_Com   := 'COMPARISON';
  G_Pro_Tbl(0).parent_level  := NULL;
  G_Pro_Tbl(0).fk_field      := NULL;
  G_Pro_Tbl(0).rel_type      := NULL;
  G_Pro_Tbl(0).direct_rel    := NULL;
  G_Pro_Tbl(0).Level_View_Name := 'BSC_D_2_VL';

  G_Pro_Tbl(1).Dim_level_id   := 0;
  G_Pro_Tbl(1).Table_name  := 'BSC_D_ACCOUNT';
  G_Pro_Tbl(1).Table_Type    := 1;
  G_Pro_Tbl(1).Level_pk_col  := 'ACCOUNT_CODE';
  G_Pro_Tbl(1).Abbreviation  := 'Accnt';
  G_Pro_Tbl(1).Value_Order   := 1;
  G_Pro_Tbl(1).Comp_Order    := 0;
  G_Pro_Tbl(1).Custom_Group  := 0;
  G_Pro_Tbl(1).Name      := 'Account';
  G_Pro_Tbl(1).Help      := 'Accounts';
  G_Pro_Tbl(1).Caption_Tot   := 'ALL';
  G_Pro_Tbl(1).Caption_Com   := 'COMPARISON';
  G_Pro_Tbl(1).parent_level  := 2;
  G_Pro_Tbl(1).fk_field      := 'TYP_OF_ACC_CODE';
  G_Pro_Tbl(1).rel_type      := 1;
  G_Pro_Tbl(1).direct_rel    := 1;
  G_Pro_Tbl(1).Level_View_Name := 'BSC_D_0_VL';

  G_Pro_Tbl(2).Dim_level_id   := 1;
  G_Pro_Tbl(2).Table_name  := 'BSC_D_SUBACCOUNT';
  G_Pro_Tbl(2).Table_Type    := 1;
  G_Pro_Tbl(2).Level_pk_col  := 'SUBACCOUNT_CODE';
  G_Pro_Tbl(2).Abbreviation  := 'Sbccn';
  G_Pro_Tbl(2).Value_Order   := 0;
  G_Pro_Tbl(2).Comp_Order    := 0;
  G_Pro_Tbl(2).Custom_Group  := 0;
  G_Pro_Tbl(2).Name      := 'Sub-Account';
  G_Pro_Tbl(2).Help      := 'Sub-Accounts';
  G_Pro_Tbl(2).Caption_Tot   := 'ALL';
  G_Pro_Tbl(2).Caption_Com   := 'COMPARISON';
  G_Pro_Tbl(2).parent_level  := 0;
  G_Pro_Tbl(2).fk_field      := 'ACCOUNT_CODE';
  G_Pro_Tbl(2).rel_type      := 1;
  G_Pro_Tbl(2).direct_rel    := 1;
  G_Pro_Tbl(2).Level_View_Name := 'BSC_D_1_VL';

  G_Pro_Tbl(3).Dim_level_id   := 3;
  G_Pro_Tbl(3).Table_name  := 'BSC_D_PROJECT';
  G_Pro_Tbl(3).Table_Type    := 1;
  G_Pro_Tbl(3).Level_pk_col  := 'PROJECT_CODE';
  G_Pro_Tbl(3).Abbreviation  := 'Prjct';
  G_Pro_Tbl(3).Value_Order   := 0;
  G_Pro_Tbl(3).Comp_Order    := 0;
  G_Pro_Tbl(3).Custom_Group  := 0;
  G_Pro_Tbl(3).Name      := 'Project';
  G_Pro_Tbl(3).Help      := 'Strategic Projects';
  G_Pro_Tbl(3).Caption_Tot   := 'ALL';
  G_Pro_Tbl(3).Caption_Com   := 'COMPARISON';
  G_Pro_Tbl(3).parent_level  := NULL;
  G_Pro_Tbl(3).fk_field      := NULL;
  G_Pro_Tbl(3).rel_type      := NULL;
  G_Pro_Tbl(3).direct_rel    := NULL;
  G_Pro_Tbl(3).Level_View_Name := 'BSC_D_3_VL';

-- 2828685 Synch the BSC_SYS_DIM_LEVELS_B


  ----Define Dimension Columns
  G_DC_Tbl(0).Dim_level_id  := -1;
  G_DC_Tbl(0).Column_Name   := 'CODE';
  G_DC_Tbl(0).Column_Type   := 'P';

  G_DC_Tbl(1).Dim_level_id  := -1;
  G_DC_Tbl(1).Column_Name   := 'USER_CODE';
  G_DC_Tbl(1).Column_Type   := 'U';

  G_DC_Tbl(2).Dim_level_id  := -1;
  G_DC_Tbl(2).Column_Name   := 'NAME';
  G_DC_Tbl(2).Column_Type   := 'D';

  G_DC_Tbl(3).Dim_level_id  := 0;
  G_DC_Tbl(3).Column_Name   := 'TYP_OF_ACC_CODE';
  G_DC_Tbl(3).Column_Type   := 'F';

  G_DC_Tbl(4).Dim_level_id  := 0;
  G_DC_Tbl(4).Column_Name   := 'TYP_OF_ACC_CODE_USR';
  G_DC_Tbl(4).Column_Type   := 'F';

  G_DC_Tbl(5).Dim_level_id  := 0;
  G_DC_Tbl(5).Column_Name   := 'POSITION';
  G_DC_Tbl(5).Column_Type   := 'A';

  G_DC_Tbl(6).Dim_level_id  := 1;
  G_DC_Tbl(6).Column_Name   := 'ACCOUNT_CODE';
  G_DC_Tbl(6).Column_Type   := 'F';

  G_DC_Tbl(7).Dim_level_id  := 1;
  G_DC_Tbl(7).Column_Name   := 'ACCOUNT_CODE_USR';
  G_DC_Tbl(7).Column_Type   := 'F';



  -- define dimension family

  G_DF_Tbl(0).Dim_group_id   := 1;
  G_DF_Tbl(0).Name       := 'Dgrp Account';
  G_DF_Tbl(0).Dim_level_id   := 0;
  G_DF_Tbl(0).Dim_level_idx  := 1;
  G_DF_Tbl(0).Total          := -1;
  G_DF_Tbl(0).Comparison     := -1;
  G_DF_Tbl(0).filter_col     := NULL;
  G_DF_Tbl(0).filter_val     := 0;
  G_DF_Tbl(0).default_val    := 'C';
  G_DF_Tbl(0).default_type   := 0;
  G_DF_Tbl(0).Parent_Total   := 2;
  G_DF_Tbl(0).No_items       := 0;

  G_DF_Tbl(1).Dim_group_id   := 2;
  G_DF_Tbl(1).Name       := 'Dgrp SubAcct';
  G_DF_Tbl(1).Dim_level_id   := 1;
  G_DF_Tbl(1).Dim_level_idx  := 1;
  G_DF_Tbl(1).Total          := -1;
  G_DF_Tbl(1).Comparison     := -1;
  G_DF_Tbl(1).filter_col     := NULL;
  G_DF_Tbl(1).filter_val     := 0;
  G_DF_Tbl(1).default_val    := 'T';
  G_DF_Tbl(1).default_type   := 0;
  G_DF_Tbl(1).Parent_Total   := 2;
  G_DF_Tbl(1).No_items       := 0;

  G_DF_Tbl(2).Dim_group_id   := 3;
  G_DF_Tbl(2).Name       := 'Dgrp Acct Type';
  G_DF_Tbl(2).Dim_level_id   := 2;
  G_DF_Tbl(2).Dim_level_idx  := 1;
  G_DF_Tbl(2).Total          := -1;
  G_DF_Tbl(2).Comparison     := -1;
  G_DF_Tbl(2).filter_col     := NULL;
  G_DF_Tbl(2).filter_val     := 0;
  G_DF_Tbl(2).default_val    := 'T';
  G_DF_Tbl(2).default_type   := 0;
  G_DF_Tbl(2).Parent_Total   := 2;
  G_DF_Tbl(2).No_items       := 0;

  -- Project dimension family

  G_DF_Tbl(3).Dim_group_id   := 4;
  G_DF_Tbl(3).Name       := 'Dgrp Project';
  G_DF_Tbl(3).Dim_level_id   := 3;
  G_DF_Tbl(3).Dim_level_idx  := 1;
  G_DF_Tbl(3).Total          := -1;
  G_DF_Tbl(3).Comparison     := -1;
  G_DF_Tbl(3).filter_col     := NULL;
  G_DF_Tbl(3).filter_val     := 0;
  G_DF_Tbl(3).default_val    := 'C';
  G_DF_Tbl(3).default_type   := 0;
  G_DF_Tbl(3).Parent_Total   := 2;
  G_DF_Tbl(3).No_items       := 0;




  if (is_cross_template) then
    l_num_of_levels := 4;
    l_num_of_family := 4;
  else
    l_num_of_levels := 3;
    l_num_of_family := 3;
  end if;

  if (NOT define_dim_relations(l_num_of_levels, l_num_of_family)) then
    l_debug_stmt := bsc_apps.get_message('BSC_ERROR_CONFIG_DIM');
    Raise BSC_DIM_ERROR;
  end if;

  Return(TRUE);

EXCEPTION
    WHEN BSC_DIM_ERROR THEN
    BSC_MESSAGE.Add(
        X_Message => l_debug_stmt,
        X_Source  => 'bsc_dim_tplate.create_dimensions',
        X_Mode    => 'I');

    Return(FALSE);

    WHEN OTHERS THEN
    BSC_MESSAGE.Add(
        X_Message => SQLERRM,
        X_Source => 'bsc_dim_tplate.create_dimensions',
        X_Mode => 'I');

    BSC_MESSAGE.Add(
        X_Message => l_debug_stmt,
        X_Source  => 'bsc_dim_tplate.create_dimensions',
        x_type    => 3,
        X_Mode    => 'I');

    Return(FALSE);

End Create_Dimensions;


/*===========================================================================+
|
|   Name:          Define_Dim_Relations
|
|   Description:   To configue dimension family and relation
|
|   Parameters:
|   x_num_of_levels     number of dimension levels
|   x_num_of_family     number of dimension families
|
|   History:
|       02-APR-1999   Alex Yang             Created.
|    12/22/1999   Henry Camacho Modified to Model 4.0
+============================================================================*/
Function Define_Dim_Relations(
        x_num_of_levels     IN  Number,
        x_num_of_family     IN  Number
) Return Boolean
Is
    l_debug_stmt        varchar2(2000);
    x_num_of_columns    Number;
    i_dimension_col     Number;
    l_sql           varchar2(32700);
Begin

  x_num_of_columns := 8;

  For i_dimension In 0 .. (x_num_of_levels -1)
  Loop

    l_debug_stmt := 'Insert Into BSC_SYS_DIM_LEVELS_B, Dim_level_id=' ||
            to_char(G_Pro_Tbl(i_dimension).Dim_level_id);
--2828685 ADD WHO COLUMNS
    Insert Into BSC_SYS_DIM_LEVELS_B (
    DIM_LEVEL_ID,
    LEVEL_TABLE_NAME,
    TABLE_TYPE,
    LEVEL_PK_COL,
    ABBREVIATION,
    VALUE_ORDER_BY,
    COMP_ORDER_BY,
    CUSTOM_GROUP,
    USER_KEY_SIZE,
    DISP_KEY_SIZE,
        EDW_FLAG,
    LEVEL_VIEW_NAME,
    CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE
)
    Values (
    G_Pro_Tbl(i_dimension).Dim_level_id,
    G_Pro_Tbl(i_dimension).Table_name,
    G_Pro_Tbl(i_dimension).Table_Type,
    G_Pro_Tbl(i_dimension).Level_pk_col,
    G_Pro_Tbl(i_dimension).abbreviation,
    G_Pro_Tbl(i_dimension).Value_Order,
    G_Pro_Tbl(i_dimension).Comp_Order,
    G_Pro_Tbl(i_dimension).Custom_Group,
    5, 20, 0,
    G_Pro_Tbl(i_dimension).Level_View_Name,
1,SYSDATE,1,SYSDATE
    );

    l_debug_stmt := 'Insert Into BSC_SYS_DIM_LEVELS_TL, Dim_level_id=' ||
            to_char(G_Pro_Tbl(i_dimension).Dim_level_id);
    --FEM translation
    l_sql := 'INSERT INTO BSC_SYS_DIM_LEVELS_TL '||
        ' (DIM_LEVEL_ID,LANGUAGE,SOURCE_LANG,NAME,HELP,TOTAL_DISP_NAME,COMP_DISP_NAME) '||
            'SELECT '||
                G_Pro_Tbl(i_dimension).Dim_level_id||' AS DIM_LEVEL_ID, '||
            'FEM_DIM.LANGUAGE AS LANGUAGE, '||
            'FEM_DIM.SOURCE_LANG AS SOURCE_LANG, '||
            'SUBSTR(FEM_DIM.MEANING,1,30) AS NAME, '||
            'SUBSTR(FEM_DIM.MEANING,1,80) AS HELP, '||
            'SUBSTR(FEM_ALL.MEANING,1,15) AS TOTAL_DISP_NAME, '||
            'SUBSTR(FEM_COMP.MEANING,1,15) AS COMP_DISP_NAME '||
        'FROM '||
                        BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_DIM, '||
            BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALL, '||
            BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_COMP '||
        'WHERE '||
            'FEM_DIM.LOOKUP_TYPE =''BSC_TPLATE_TAB_DIM_LEVEL_NAME'' AND '||
                'FEM_DIM.LOOKUP_CODE = '''||G_Pro_Tbl(i_dimension).Dim_level_id||''' AND '||
                'FEM_ALL.LOOKUP_TYPE =''BSC_UI_COMMON'' AND '||
                'FEM_ALL.LOOKUP_CODE = ''ALL'' AND '||
                'FEM_COMP.LOOKUP_TYPE =''BSC_UI_COMMON'' AND '||
                'FEM_COMP.LOOKUP_CODE = ''COMPARISON'' AND '||
                'FEM_DIM.LANGUAGE = FEM_ALL.LANGUAGE AND '||
                'FEM_COMP.LANGUAGE = FEM_ALL.LANGUAGE';
    BSC_APPS.Execute_Immediate(l_sql);

    l_debug_stmt := 'Insert Into BSC_SYS_DIM_LEVEL_COLS, Dim_level_id=' ||
            to_char(G_Pro_Tbl(i_dimension).Dim_level_id);


    For i_dimension_col In 0 .. (x_num_of_columns -1) LOOP
       IF G_DC_Tbl(i_dimension_col).Dim_level_id = -1 THEN
            Insert Into BSC_SYS_DIM_LEVEL_COLS (
            DIM_LEVEL_ID,
            COLUMN_NAME,
            COLUMN_TYPE)
            Values (
            G_Pro_Tbl(i_dimension).Dim_level_id,
            G_DC_Tbl(i_dimension_col).Column_Name,
            G_DC_Tbl(i_dimension_col).Column_Type
            );
       ELSE
           IF G_DC_Tbl(i_dimension_col).Dim_level_id = G_Pro_Tbl(i_dimension).Dim_level_id THEN
            Insert Into BSC_SYS_DIM_LEVEL_COLS (
            DIM_LEVEL_ID,
            COLUMN_NAME,
            COLUMN_TYPE)
            Values (
            G_Pro_Tbl(i_dimension).Dim_level_id,
            G_DC_Tbl(i_dimension_col).Column_Name,
            G_DC_Tbl(i_dimension_col).Column_Type
            );
        END IF;
     END IF;

    End loop;



    if (G_Pro_Tbl(i_dimension).parent_level is NOT NULL) then

        l_debug_stmt := 'Insert Into BSC_SYS_DIM_LEVEL_RELS, Dim_level_id=' ||
            to_char(G_Pro_Tbl(i_dimension).Dim_level_id);

        Insert Into BSC_SYS_DIM_LEVEL_RELS (
        DIM_LEVEL_ID,
        RELATION_COL,
        PARENT_DIM_LEVEL_ID,
        RELATION_TYPE,
        DIRECT_RELATION )
    Values (
        G_Pro_Tbl(i_dimension).Dim_level_id,
        G_Pro_Tbl(i_dimension).fk_field,     -- relation_field
        G_Pro_Tbl(i_dimension).parent_level, -- parent_entity_code
        G_Pro_Tbl(i_dimension).rel_type,     -- relation_type
        G_Pro_Tbl(i_dimension).direct_rel    -- direct_relation
    );

    end if;

    l_debug_stmt := 'Insert Into BSC_DB_TABLES_RELS, Dim_level_id=' ||
            to_char(G_Pro_Tbl(i_dimension).Dim_level_id);
    Insert Into BSC_DB_TABLES_RELS (
    TABLE_NAME,
    SOURCE_TABLE_NAME)
    Values (
    G_Pro_Tbl(i_dimension).Table_name,
    'BSC_DI_' || G_Pro_Tbl(i_dimension).Dim_level_id
    );

    l_debug_stmt := 'Insert Into BSC_DB_TABLES, Dim_level_id=' ||
            to_char(G_Pro_Tbl(i_dimension).Dim_level_id);
    Insert Into BSC_DB_TABLES (
    TABLE_NAME,
    TABLE_TYPE,
    PERIODICITY_ID,
    SOURCE_DATA_TYPE,
    SOURCE_FILE_NAME)
    Values (
    'BSC_DI_' || G_Pro_Tbl(i_dimension).Dim_level_id,
    2,
    0,
    0,
    NULL
    );


  End Loop; -- dimension level loop


  For i_dem_family In 0 .. (x_num_of_family -1)
  Loop

    l_debug_stmt := 'Insert Into MPROJ_DRILLS_FAMILIES,Dim_group_id=' ||
            to_char(G_DF_Tbl(i_dem_family).Dim_group_id);

    -- FEM translation
--2828685 ADD WHO COLUMNS
    l_sql := 'INSERT INTO BSC_SYS_DIM_GROUPS_TL '||
        ' (DIM_GROUP_ID,LANGUAGE,SOURCE_LANG,NAME,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE) ' ||
        'SELECT '||
            G_DF_Tbl(i_dem_family).Dim_group_id||' AS DIM_GROUP_ID, '||
            'FEM_ALIAS.LANGUAGE AS LANGUAGE, '||
            'FEM_ALIAS.SOURCE_LANG AS SOURCE_LANG, '||
            'SUBSTR(FEM_ALIAS.MEANING,1,15) AS NAME '||
            ',1,SYSDATE,1,SYSDATE '||
        'FROM '||
            BSC_TEMPLATE.LOOKUP_VALUES_TABLE||' FEM_ALIAS '||
        'WHERE '||
            'FEM_ALIAS.LOOKUP_TYPE = ''BSC_TPLATE_TAB_DIM_GROUP_NAME'' AND '||
                'FEM_ALIAS.LOOKUP_CODE = '''||G_DF_Tbl(i_dem_family).Dim_group_id||'''';
    BSC_APPS.Execute_Immediate(l_sql);

    l_debug_stmt := 'Insert Into BSC_SYS_DIM_LEVELS_BY_GROUP, ' ||
    ' Dim_group_id=' || to_char(G_DF_Tbl(i_dem_family).Dim_group_id) ||
        ', Dim_level_id=' || to_char(G_DF_Tbl(i_dem_family).Dim_level_id);

    Insert Into BSC_SYS_DIM_LEVELS_BY_GROUP (
    DIM_GROUP_ID,
    DIM_LEVEL_ID,
    DIM_LEVEL_INDEX,
    TOTAL_FLAG,
    COMPARISON_FLAG,
    FILTER_COLUMN,
    FILTER_VALUE,
    DEFAULT_VALUE,
    DEFAULT_TYPE,
    PARENT_IN_TOTAL,
    NO_ITEMS )
    Values (
    G_DF_Tbl(i_dem_family).Dim_group_id,     -- family_code
    G_DF_Tbl(i_dem_family).Dim_level_id,    -- entity_code
    G_DF_Tbl(i_dem_family).Dim_level_idx,       -- order_r
    G_DF_Tbl(i_dem_family).Total,       -- total
    G_DF_Tbl(i_dem_family).Comparison,  -- comparison
    G_DF_Tbl(i_dem_family).Filter_col,  -- condition_field
    G_DF_Tbl(i_dem_family).Filter_val,  -- condition_value
    G_DF_Tbl(i_dem_family).Default_val,     -- init
    G_DF_Tbl(i_dem_family).Default_type,    -- init_type
    G_DF_Tbl(i_dem_family).Parent_Total,    -- status_whn_parnt_is_total
    G_DF_Tbl(i_dem_family).No_items     -- hide_if_no_items
    );

  End Loop; -- dimension family loop

  Return(TRUE);

EXCEPTION

    WHEN OTHERS THEN
    BSC_MESSAGE.Add(
        X_Message => SQLERRM,
        X_Source => 'bsc_dim_tplate.define_dim_relations',
        X_Mode => 'I');

    BSC_MESSAGE.Add(
        X_Message => l_debug_stmt,
        X_Source  => 'bsc_template.create_crx_template',
        x_type    => 3,
        X_Mode    => 'I');

    Return(FALSE);

End Define_Dim_Relations;


END BSC_DIM_TPLATE;

/
