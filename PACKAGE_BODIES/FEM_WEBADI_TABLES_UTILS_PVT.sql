--------------------------------------------------------
--  DDL for Package Body FEM_WEBADI_TABLES_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_WEBADI_TABLES_UTILS_PVT" AS
/* $Header: FEMVADITABUTILB.pls 120.2.12010000.2 2008/09/22 11:01:22 lkiran ship $ */
   --Bug#7423745. Added procs that make entries into TL tables
   --for Integrator, Content and Content Cols.

   procedure ADD_INTEGRATOR_LANGUAGE
   is
   begin
     delete from BNE_INTEGRATORS_TL T
     where not exists
       (select NULL
       from BNE_INTEGRATORS_B B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.INTEGRATOR_CODE = T.INTEGRATOR_CODE
       ) and t.application_id=274 and t.integrator_code not in ('FEM_BALANCES_INTG','FEM_DIM_MEMBER_INTG','FEM_HIERARCHY_INTG');

     update BNE_INTEGRATORS_TL T set (
         USER_NAME,
         UPLOAD_TITLE_BAR,
         UPLOAD_HEADER
       ) = (select
         B.USER_NAME,
         B.UPLOAD_TITLE_BAR,
         B.UPLOAD_HEADER
       from BNE_INTEGRATORS_TL B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.INTEGRATOR_CODE = T.INTEGRATOR_CODE
       and B.LANGUAGE = T.SOURCE_LANG)
     where (
         T.APPLICATION_ID,
         T.INTEGRATOR_CODE,
         T.LANGUAGE
     ) in (select
         SUBT.APPLICATION_ID,
         SUBT.INTEGRATOR_CODE,
         SUBT.LANGUAGE
       from BNE_INTEGRATORS_TL SUBB, BNE_INTEGRATORS_TL SUBT
       where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
       and SUBB.INTEGRATOR_CODE = SUBT.INTEGRATOR_CODE
       and SUBB.LANGUAGE = SUBT.SOURCE_LANG
       and (SUBB.USER_NAME <> SUBT.USER_NAME
         or SUBB.UPLOAD_TITLE_BAR <> SUBT.UPLOAD_TITLE_BAR
         or (SUBB.UPLOAD_TITLE_BAR is null and SUBT.UPLOAD_TITLE_BAR is not null)
         or (SUBB.UPLOAD_TITLE_BAR is not null and SUBT.UPLOAD_TITLE_BAR is null)
         or SUBB.UPLOAD_HEADER <> SUBT.UPLOAD_HEADER
         or (SUBB.UPLOAD_HEADER is null and SUBT.UPLOAD_HEADER is not null)
         or (SUBB.UPLOAD_HEADER is not null and SUBT.UPLOAD_HEADER is null)
     )) and t.application_id = 274 and t.integrator_code not in ('FEM_BALANCES_INTG','FEM_DIM_MEMBER_INTG','FEM_HIERARCHY_INTG') ;

     insert into BNE_INTEGRATORS_TL (
       APPLICATION_ID,
       INTEGRATOR_CODE,
       USER_NAME,
       UPLOAD_HEADER,
       UPLOAD_TITLE_BAR,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LANGUAGE,
       SOURCE_LANG
     ) select
       B.APPLICATION_ID,
       B.INTEGRATOR_CODE,
       B.USER_NAME,
       B.UPLOAD_HEADER,
       B.UPLOAD_TITLE_BAR,
       B.CREATED_BY,
       B.CREATION_DATE,
       B.LAST_UPDATED_BY,
       B.LAST_UPDATE_LOGIN,
       B.LAST_UPDATE_DATE,
       L.LANGUAGE_CODE,
       B.SOURCE_LANG
     from BNE_INTEGRATORS_TL B, FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and B.LANGUAGE = userenv('LANG')
     and not exists
       (select NULL
       from BNE_INTEGRATORS_TL T
       where T.APPLICATION_ID = B.APPLICATION_ID
       and T.INTEGRATOR_CODE = B.INTEGRATOR_CODE
       and T.LANGUAGE = L.LANGUAGE_CODE) and b.application_id=274 and b.integrator_code not in ('FEM_BALANCES_INTG','FEM_DIM_MEMBER_INTG','FEM_HIERARCHY_INTG');
   end ADD_INTEGRATOR_LANGUAGE;


   procedure ADD_CONTENT_LANGUAGE
   is
   begin

       delete from BNE_CONTENTS_TL T
     where not exists
       (select NULL
       from BNE_CONTENTS_B B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.CONTENT_CODE = T.CONTENT_CODE
       ) and t.application_id=274 and t.content_code not in ('FEM_BALANCES_CNT','FEM_DIM_MEMBER_CNT','FEM_HIERARCHY_CNT');

        update BNE_CONTENTS_TL T set (
         USER_NAME
       ) = (select
         B.USER_NAME
       from BNE_CONTENTS_TL B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.CONTENT_CODE = T.CONTENT_CODE
       and B.LANGUAGE = T.SOURCE_LANG)
     where (
         T.APPLICATION_ID,
         T.CONTENT_CODE,
         T.LANGUAGE
     ) in (select
         SUBT.APPLICATION_ID,
         SUBT.CONTENT_CODE,
         SUBT.LANGUAGE
       from BNE_CONTENTS_TL SUBB, BNE_CONTENTS_TL SUBT
       where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
       and SUBB.CONTENT_CODE = SUBT.CONTENT_CODE
       and SUBB.LANGUAGE = SUBT.SOURCE_LANG
       and (SUBB.USER_NAME <> SUBT.USER_NAME))
     and t.application_id=274 and t.content_code not in ('FEM_BALANCES_CNT','FEM_DIM_MEMBER_CNT','FEM_HIERARCHY_CNT');


     insert into BNE_CONTENTS_TL (
       CONTENT_CODE,
       USER_NAME,
       LAST_UPDATE_DATE,
       LAST_UPDATED_BY,
       CREATION_DATE,
       CREATED_BY,
       LAST_UPDATE_LOGIN,
       APPLICATION_ID,
       LANGUAGE,
       SOURCE_LANG
     ) select
       B.CONTENT_CODE,
       B.USER_NAME,
       B.LAST_UPDATE_DATE,
       B.LAST_UPDATED_BY,
       B.CREATION_DATE,
       B.CREATED_BY,
       B.LAST_UPDATE_LOGIN,
       B.APPLICATION_ID,
       L.LANGUAGE_CODE,
       B.SOURCE_LANG
     from BNE_CONTENTS_TL B, FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and B.LANGUAGE = userenv('LANG')
     and not exists
       (select NULL
       from BNE_CONTENTS_TL T
       where T.APPLICATION_ID = B.APPLICATION_ID
       and T.CONTENT_CODE = B.CONTENT_CODE
       and T.LANGUAGE = L.LANGUAGE_CODE) and b.application_id=274 and b.content_code not in ('FEM_BALANCES_CNT','FEM_DIM_MEMBER_CNT','FEM_HIERARCHY_CNT');

   end ADD_CONTENT_LANGUAGE;

   procedure ADD_CONTENT_COLS_LANGUAGE
   is
   begin
     delete from BNE_CONTENT_COLS_TL T
     where not exists
       (select NULL
       from BNE_CONTENT_COLS_B B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.CONTENT_CODE = T.CONTENT_CODE
       and B.SEQUENCE_NUM = T.SEQUENCE_NUM
       ) and t.application_id=274 and t.content_code not in ('FEM_BALANCES_CNT','FEM_DIM_MEMBER_CNT','FEM_HIERARCHY_CNT');

     update BNE_CONTENT_COLS_TL T set (
         USER_NAME
       ) = (select
         B.USER_NAME
       from BNE_CONTENT_COLS_TL B
       where B.APPLICATION_ID = T.APPLICATION_ID
       and B.CONTENT_CODE = T.CONTENT_CODE
       and B.SEQUENCE_NUM = T.SEQUENCE_NUM
       and B.LANGUAGE = T.SOURCE_LANG)
     where (
         T.APPLICATION_ID,
         T.CONTENT_CODE,
         T.SEQUENCE_NUM,
         T.LANGUAGE
     ) in (select
         SUBT.APPLICATION_ID,
         SUBT.CONTENT_CODE,
         SUBT.SEQUENCE_NUM,
         SUBT.LANGUAGE
       from BNE_CONTENT_COLS_TL SUBB, BNE_CONTENT_COLS_TL SUBT
       where SUBB.APPLICATION_ID = SUBT.APPLICATION_ID
       and SUBB.CONTENT_CODE = SUBT.CONTENT_CODE
       and SUBB.SEQUENCE_NUM = SUBT.SEQUENCE_NUM
       and SUBB.LANGUAGE = SUBT.SOURCE_LANG
       and (SUBB.USER_NAME <> SUBT.USER_NAME))
      and t.application_id=274 and t.content_code not in ('FEM_BALANCES_CNT','FEM_DIM_MEMBER_CNT','FEM_HIERARCHY_CNT');

     insert into BNE_CONTENT_COLS_TL (
       APPLICATION_ID,
       CONTENT_CODE,
       SEQUENCE_NUM,
       USER_NAME,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_LOGIN,
       LAST_UPDATE_DATE,
       LANGUAGE,
       SOURCE_LANG
     ) select
       B.APPLICATION_ID,
       B.CONTENT_CODE,
       B.SEQUENCE_NUM,
       B.USER_NAME,
       B.CREATED_BY,
       B.CREATION_DATE,
       B.LAST_UPDATED_BY,
       B.LAST_UPDATE_LOGIN,
       B.LAST_UPDATE_DATE,
       L.LANGUAGE_CODE,
       B.SOURCE_LANG
     from BNE_CONTENT_COLS_TL B, FND_LANGUAGES L
     where L.INSTALLED_FLAG in ('I', 'B')
     and B.LANGUAGE = userenv('LANG')
     and not exists
       (select NULL
       from BNE_CONTENT_COLS_TL T
       where T.APPLICATION_ID = B.APPLICATION_ID
       and T.CONTENT_CODE = B.CONTENT_CODE
       and T.SEQUENCE_NUM = B.SEQUENCE_NUM
       and T.LANGUAGE = L.LANGUAGE_CODE) and b.application_id=274 and b.content_code not in ('FEM_BALANCES_CNT','FEM_DIM_MEMBER_CNT','FEM_HIERARCHY_CNT');
   end ADD_CONTENT_COLS_LANGUAGE;

   -- Bug#7423745. -- End

PROCEDURE POPULATE_METADATA_CP(errbuf OUT NOCOPY VARCHAR2, retcode  OUT NOCOPY NUMBER, P_TABLE_NAME IN VARCHAR2)
IS
l_object_code         varchar2(50);
l_interface_table     varchar2(50);
l_ret_status          varchar2(30);
l_msg_count           number;
l_msg_data            varchar2(30);
BEGIN

 POPULATE_METADATA(P_TABLE_NAME,'F',l_object_code,null,l_ret_status,l_msg_count,l_msg_data);
 if(l_ret_status = FND_API.G_RET_STS_ERROR) then
  retcode :=2;
 end if;

END POPULATE_METADATA_CP;

PROCEDURE POPULATE_METADATA(P_TABLE_NAME IN VARCHAR2,P_MODE IN VARCHAR2, X_OBJECT_CODE OUT NOCOPY VARCHAR2,
                            P_INIT_MSG_LIST IN VARCHAR2,
                            X_RETURN_STATUS OUT NOCOPY VARCHAR2,
                            X_MSG_COUNT OUT NOCOPY NUMBER,
                            X_MSG_DATA OUT NOCOPY VARCHAR2)
IS

l_integrator_exists         varchar2(1)  := null;
l_interface_exists          varchar2(1)  := null;
l_integrator_code           varchar2(50) := P_TABLE_NAME || '_INTG';
l_interface_table           varchar2(50) := null;
l_interface_code            varchar2(50) := null;
l_param_list_code           varchar2(50) := null;
l_order_seq                 number;
l_intf_upl_param_list_code  varchar2(50) := 'FEM_LIST';
l_user_id                   number(15)   := 2; --   (user name : initial setup)
l_intg_upl_param_list_code  varchar2(50) := 'FEM_TABLES_UPL_LIST';
l_intg_imp_param_list_code  varchar2(50) := 'FEM_TABLES_IMP_LIST';
l_table_display_name        varchar2(150);
l_object_code               varchar2(30);
l_object_code_prefix        number       := 1;
l_no_intf_col_map_flag      varchar2(1) := null;
e_normal_mode exception;
e_no_intf_col_map exception;
l_no_map_columns            varchar2(1000);
l_log_string                varchar2(5000);
begin

select display_name into l_table_display_name from fem_tables_vl
where table_name = p_table_name;

l_object_code := p_table_name;

l_interface_code := p_table_name || '_INTF';

------------------------ populating maping for corresponding interface table params
 begin
  select interface_table_name into l_interface_table from fem_tables_b
   where table_name = p_table_name;
  exception
   when NO_DATA_FOUND then null;
  end;

 POPULATE_TABLE_COLUMN_MAPS(l_interface_table);
----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Right now we assume that there won't be any conflict while generating interface/integrator codes are tables having length(tableName) > 20.

   if(length(l_object_code) >20) then
     l_object_code := substr(l_object_code,1,19) || l_object_code_prefix;
     l_integrator_code := l_object_code || '_INTG';
     l_interface_code := l_object_code || '_INTF';
   end if;

 x_object_code := l_object_code;

------------------- Checking if all interface table required columns have entry in FEM_TAB_COLUMNS_B ----------------------------------------------------

  IF FND_API.to_Boolean ( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize ;
  END IF;

  for missing_rec in (select M.interface_column_name interface_column_name
  from FEM_WEBADI_TABLE_COLS_MAPS M
  where M.INTERFACE_TABLE_NAME = l_interface_table
  and M.NULLABLE = 'N'
  and trim(interface_column_name) not in ('CAL_PERIOD_END_DATE','CALP_DIM_GRP_DISPLAY_CODE','CAL_PERIOD_NUMBER','STATUS','LEDGER_DISPLAY_CODE','SOURCE_SYSTEM_DISPLAY_CODE',
  'DATASET_DISPLAY_CODE')
  and not exists (SELECT 1 FROM FEM_TAB_COLUMNS_B T WHERE TABLE_NAME = p_table_name AND T.INTERFACE_COLUMN_NAME = M.INTERFACE_COLUMN_NAME))
  loop
    l_no_map_columns := missing_rec.interface_column_name || ' ,' || l_no_map_columns;
    l_no_intf_col_map_flag := 'Y';
  end loop;

  l_no_map_columns := substr(l_no_map_columns,1,length(l_no_map_columns)-2);

  if (l_no_intf_col_map_flag = 'Y') then
    if(p_mode <> 'N')then
      FND_MESSAGE.SET_NAME('FEM','FEM_ADI_MISSING_MAPPING');
      FND_MESSAGE.SET_TOKEN('COLUMNS',l_no_map_columns);
      l_log_string := FND_MESSAGE.GET;
      fnd_file.put_line(fnd_file.log,l_log_string);
    else
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_MISSING_MAPPING');
     FND_MESSAGE.SET_TOKEN('COLUMNS',l_no_map_columns);
     FND_MSG_PUB.add;
    end if;
   raise e_no_intf_col_map;
  end if;

---------------------- Checking if an integrator is already available for normal mode
 begin
  select 'Y' into l_integrator_exists from dual
   where exists(select integrator_code from bne_integrators_b where
   integrator_code = l_integrator_code);
  exception
   when NO_DATA_FOUND then null;
  end;

 if(l_integrator_exists is not null and p_mode = 'N') then  --- p_mode = 'N' says that its a normal mode and proc got executed from create from spreadsheet.
  raise e_normal_mode;
 end if;

----------------------------------------------------------------------------------------------------------------------------------------------------------
 if(l_integrator_exists is null) then

    ------ The BNE integrator utility function takes object code of only 20 max charecters. As our object code is nothing but the table name so if in case some
    ------ table name has greater than 20 chars so we need to resolve our object_name.

    ----------------------------------------------------------------------------------------------------------------------------------------------------------

    bne_integrator_utils.create_integrator(p_application_id => 274,
                                          p_object_code => l_object_code,
                                          p_integrator_user_name => 'Enterprise Performance Foundation: ' || l_table_display_name || ' Integrator' ,
                                          p_language => USERENV('LANG'),
                                          p_source_language => USERENV('LANG'),
                                          p_user_id => 2,
                                          p_integrator_code => l_integrator_code
                                          );
    -- Bug#7423745
    add_integrator_language;

    update bne_integrators_b
     set upload_param_list_app_id = 274,
     upload_param_list_code = 'FEM_TABLES_UPL_LIST',
     upload_serv_param_list_app_id = 231,
     upload_serv_param_list_code = 'UPL_SERV_INTERF_COLS',
     import_param_list_app_id = 274,
     import_param_list_code = 'FEM_TABLES_IMP_LIST',
     uploader_class = 'oracle.apps.bne.integrator.upload.BneUploader',
     import_type = 1
     where integrator_code = l_integrator_code;

end if;

-------------------- creating an interface if its not available for the P_TABLE_NAME

 begin
  select 'Y' into l_interface_exists from dual
   where exists(select interface_code from bne_interfaces_b where
   interface_code = l_object_code || '_INTF');
  exception
   when NO_DATA_FOUND then null;
  	end;

 if(l_interface_exists is null) then

    SELECT NVL(MAX(UPLOAD_ORDER), 0) + 1
    INTO   l_order_seq
    FROM   BNE_INTERFACES_B
    WHERE  APPLICATION_ID = 274
    AND    INTEGRATOR_APP_ID = 274
    AND    INTEGRATOR_CODE = P_TABLE_NAME || '_INTG';

    IF SQL%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;

  ---- Create the interface in the BNE_INTERFACE_B table

   INSERT INTO BNE_INTERFACES_B
      (APPLICATION_ID,
       INTERFACE_CODE,
       OBJECT_VERSION_NUMBER,
       INTEGRATOR_APP_ID,
       INTEGRATOR_CODE,
       INTERFACE_NAME,
       UPLOAD_TYPE,
       UPLOAD_PARAM_LIST_APP_ID,
       UPLOAD_PARAM_LIST_CODE,
       UPLOAD_ORDER,
       CREATED_BY,
       CREATION_DATE,
       LAST_UPDATED_BY,
       LAST_UPDATE_DATE)
    VALUES
      (274,
       l_interface_code,
       1,
       274,
       l_integrator_code,
       'UPLOAD_FEM_TABLES_INTERFACE',
       2,
       274,
       l_intf_upl_param_list_code,
       NULL,
       l_user_id,
       SYSDATE,
       l_user_id,
       SYSDATE);

  ----- Create the interface in the BNE_INTERFACES_TL table

    INSERT INTO BNE_INTERFACES_TL
      ( APPLICATION_ID,
        INTERFACE_CODE,
        LANGUAGE,
        SOURCE_LANG,
        USER_NAME,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE)
    SELECT 274
    ,      l_interface_code
    ,      T.LANGUAGE
    ,      T.SOURCE_LANG
    ,      SUBSTR(M.MESSAGE_TEXT,0, INSTR(M.MESSAGE_TEXT, 'TABLE_NAME')-2) ||
           T.DISPLAY_NAME ||
           SUBSTR(M.MESSAGE_TEXT,INSTR(M.MESSAGE_TEXT, 'TABLE_NAME')+10)
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      SYSDATE
    FROM   FEM_TABLES_TL T, FND_NEW_MESSAGES M, FND_LANGUAGES L
    WHERE  T.TABLE_NAME = p_table_name
    AND    M.APPLICATION_ID= 274
    AND    M.MESSAGE_NAME = 'FEM_ADI_TABLES_INTERFACE'
    AND    M.LANGUAGE_CODE = T.LANGUAGE
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

 end if;

-------------------- populate/create security,content and mapping when new interface is created
 if(l_interface_exists is null) then

   POPULATE_OTHER_SETUP(l_object_code,p_table_name);

 end if;

-------------------- populating bne_interface_cols tables for common columns

-- if(l_interface_exists is null ) then

   POPULATE_INTERFACE_COMM_COLS(l_interface_code,p_table_name);

-- end if;

------------------- populating bne_interface_cols tables for other columns

   POPULATE_INTERFACE_PARAM_COLS(l_interface_code,p_table_name);

------------------ populating bne_layouts for other columns

   POPULATE_LAYOUT(l_object_code,p_table_name);

--------------------------------------------------------------------------

COMMIT;

EXCEPTION
 --
  WHEN E_NORMAL_MODE THEN
     NULL;
   WHEN E_NO_INTF_COL_MAP THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get ( p_count => x_msg_count,
                                p_data  => x_msg_data );

END POPULATE_METADATA;

PROCEDURE POPULATE_OTHER_SETUP(P_OBJECT_CODE IN VARCHAR2, P_TABLE_NAME IN VARCHAR2)
IS
l_integrator_code     varchar2(50) := p_object_code || '_INTG';
l_interface_code      varchar2(50) := p_object_code || '_INTF';
l_content_code        varchar2(50) := p_object_code || '_CNT';
l_mapping_code        varchar2(50) := p_object_code || '_MAP';
l_security_rule_code  varchar2(50) := p_object_code || '_SR';
l_user_id             number       := 2;
l_table_display_name  varchar2(150) := null;
begin

select display_name into l_table_display_name from fem_tables_vl
where table_name = p_table_name;


---- Create a security rule ---------------------------

BNE_SECURITY_UTILS_PKG.ADD_OBJECT_RULES
( P_APPLICATION_ID => 274,
P_OBJECT_CODE => l_integrator_code,
P_OBJECT_TYPE => 'INTEGRATOR',
P_SECURITY_CODE => l_security_rule_code,
P_SECURITY_TYPE => 'FUNCTION',
P_SECURITY_VALUE => 'FEM_WEBADI_TABLES,BNE_ADI_DEFINE_MAPPING,BNE_TEXT_MAP_DEFINE,BNE_ADI_DEFINE_LAYOUT,BNE_LAYOUT_DEFINITION,BNE_ADI_LOB_MANAGEMENT,BNE_LOB_MANAGEMENT',
P_USER_ID => 2);

---- Update content ----------------------------------
-- We say update content because as an when we create an integrator, a corresponding row is populated in bne_contents_b / tl. This procedure call will simply update some fields
-- for that already populated row. Moreover this makes a new row entry in the bne_content_cols_b / tl.

BNE_CONTENT_UTILS.CREATE_CONTENT_STORED_SQL(
P_APPLICATION_ID => 274,
P_OBJECT_CODE => p_object_code,
P_INTEGRATOR_CODE => l_integrator_code,
P_CONTENT_DESC  => 'Enterprise Performace Foundation: ' || l_table_display_name || ' Content',
P_COL_LIST => 'DISPLAY_NAME',
P_QUERY => 'select display_name from fem_tables_vl where table_name = $PARAM$.table_name',
P_LANGUAGE => USERENV('LANG'),
P_SOURCE_LANGUAGE => USERENV('LANG'),
P_USER_ID => l_user_id,
P_CONTENT_CODE => l_content_code);

-- Bug#7423745
add_content_cols_language;
add_content_language;

update bne_contents_b
set param_list_app_id = 274,
param_list_code = 'FEM_TABLE_DNLD_LIST'
where content_code = l_content_code;

---- Create mapping ---------------------------------

insert into bne_mappings_b(APPLICATION_ID,
MAPPING_CODE,
OBJECT_VERSION_NUMBER,
INTEGRATOR_APP_ID,
INTEGRATOR_CODE,
REPORTING_FLAG,
REPORTING_INTERFACE_APP_ID,
REPORTING_INTERFACE_CODE,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
LAST_UPDATE_DATE)
values
(274,l_mapping_code,1,274,l_integrator_code,'N',NULL,NULL,l_user_id,SYSDATE,l_user_id,0,SYSDATE);

insert into bne_mappings_tl(APPLICATION_ID,
MAPPING_CODE,
LANGUAGE,
SOURCE_LANG,
USER_NAME,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
LAST_UPDATE_DATE)
SELECT 274
    ,      l_mapping_code
    ,      T.LANGUAGE
    ,      T.SOURCE_LANG
    ,      SUBSTR(M.MESSAGE_TEXT,0, INSTR(M.MESSAGE_TEXT, 'TABLE_NAME')-2) ||
           T.DISPLAY_NAME ||
           SUBSTR(M.MESSAGE_TEXT,INSTR(M.MESSAGE_TEXT, 'TABLE_NAME')+10)
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      0
    ,      SYSDATE
    FROM   FEM_TABLES_TL T, FND_NEW_MESSAGES M, FND_LANGUAGES L
    WHERE  T.TABLE_NAME = p_table_name
    AND    M.APPLICATION_ID= 274
    AND    M.MESSAGE_NAME = 'FEM_ADI_TABLES_MAPPING'
    AND    M.LANGUAGE_CODE = T.LANGUAGE
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');


insert into bne_mapping_lines
(APPLICATION_ID,
MAPPING_CODE,
SEQUENCE_NUM,
CONTENT_APP_ID,
CONTENT_CODE,
CONTENT_SEQ_NUM,
INTERFACE_APP_ID,
INTERFACE_CODE,
INTERFACE_SEQ_NUM,
OBJECT_VERSION_NUMBER,
CREATED_BY,
CREATION_DATE,
LAST_UPDATED_BY,
LAST_UPDATE_LOGIN,
LAST_UPDATE_DATE,
DECODE_FLAG)
values
(274,l_mapping_code,1,274,l_content_code,1,274,l_interface_code,1,1,2,SYSDATE,2,0,SYSDATE,'N');

END POPULATE_OTHER_SETUP;

PROCEDURE POPULATE_LAYOUT(P_OBJECT_CODE IN VARCHAR2,P_TABLE_NAME IN VARCHAR2)
IS
l_layout_code      varchar2(50) := p_object_code || '_LAYOUT';
l_layout_exists    varchar2(1);
l_integrator_code  varchar2(50) := p_object_code || '_INTG';
l_header_block_id  BNE_LAYOUT_BLOCKS_B.BLOCK_ID%TYPE;
l_line_block_id    BNE_LAYOUT_BLOCKS_B.BLOCK_ID%TYPE;
l_interface_code   varchar2(50) := p_object_code || '_INTF';
l_sequence_num     number;
l_list_item_num    number;
l_layout_seq       number     := 1;

l_user_id         NUMBER(15)   := 2;
l_login_id        NUMBER       := NVL(Fnd_Global.Login_Id, 0);

begin

 BEGIN
    SELECT 'Y'
    INTO   l_layout_exists
    FROM   BNE_LAYOUTS_B
    WHERE  APPLICATION_ID = 274
    AND    LAYOUT_CODE = l_layout_code;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

 if(l_layout_exists is null) then

  ---------------------------------------------------------------------------
  -- Create Layout in BNE_LAYOUTS_B and BNE_LAYOUTS_TL
  ---------------------------------------------------------------------------
    INSERT INTO BNE_LAYOUTS_B
    ( APPLICATION_ID
    , LAYOUT_CODE
    , OBJECT_VERSION_NUMBER
    , STYLESHEET_APP_ID
    , STYLESHEET_CODE
    , INTEGRATOR_APP_ID
    , INTEGRATOR_CODE
    , STYLE
    , STYLE_CLASS
    , REPORTING_FLAG
    , REPORTING_INTERFACE_APP_ID
    , REPORTING_INTERFACE_CODE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , CREATE_DOC_LIST_APP_ID
    , CREATE_DOC_LIST_CODE
    )
    VALUES
    ( 274
    , l_layout_code
    , 1
    , 231
    , 'DEFAULT'
    , 274
    , l_integrator_code
    , NULL
    , 'BNE_PAGE'
    , 'N'
    , NULL
    , NULL
    , SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    , NULL
    , NULL
    );

    INSERT INTO BNE_LAYOUTS_TL
    ( APPLICATION_ID
    , LAYOUT_CODE
    , USER_NAME
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    , LANGUAGE
    , SOURCE_LANG
    )
    SELECT 274
    ,      l_layout_code
    ,      SUBSTR(M.MESSAGE_TEXT,0, INSTR(M.MESSAGE_TEXT, 'TABLE_NAME')-2) ||
           T.DISPLAY_NAME ||
           SUBSTR(M.MESSAGE_TEXT,INSTR(M.MESSAGE_TEXT, 'TABLE_NAME')+10)
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      T.LANGUAGE
    ,      T.SOURCE_LANG
    FROM   FEM_TABLES_TL T,FND_NEW_MESSAGES M,FND_LANGUAGES L
    WHERE  T.TABLE_NAME = p_table_name
    AND    M.APPLICATION_ID= 274
    AND    M.MESSAGE_NAME = 'FEM_ADI_TABLES_LAYOUT'
    AND    M.LANGUAGE_CODE = T.LANGUAGE
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

  END IF;

  -----------------------------------------------------------------------------
  --  Creaate header block within the layout
  -----------------------------------------------------------------------------

  BEGIN
    SELECT B.BLOCK_ID
    INTO   l_header_block_id
    FROM   BNE_LAYOUT_BLOCKS_B B
    WHERE  B.APPLICATION_ID = 274
    AND    B.LAYOUT_CODE = l_layout_code
    AND    B.LAYOUT_ELEMENT = 'HEADER';
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (l_header_block_id IS NULL) THEN
    ---------------------------------------------------------------------------
    -- Insert a new block into BNE_LAYOUT_BLOCKS_B
    ---------------------------------------------------------------------------

    l_header_block_id := 1;

    INSERT INTO BNE_LAYOUT_BLOCKS_B
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , OBJECT_VERSION_NUMBER
    , PARENT_ID
    , LAYOUT_ELEMENT
    , STYLE_CLASS
    , STYLE
    , ROW_STYLE_CLASS
    , ROW_STYLE
    , COL_STYLE_CLASS
    , COL_STYLE
    , PROMPT_DISPLAYED_FLAG
    , PROMPT_STYLE_CLASS
    , PROMPT_STYLE
    , HINT_DISPLAYED_FLAG
    , HINT_STYLE_CLASS
    , HINT_STYLE
    , ORIENTATION
    , LAYOUT_CONTROL
    , DISPLAY_FLAG
    , BLOCKSIZE
    , MINSIZE
    , MAXSIZE
    , SEQUENCE_NUM
    , PROMPT_COLSPAN
    , HINT_COLSPAN
    , ROW_COLSPAN
    , SUMMARY_STYLE_CLASS
    , SUMMARY_STYLE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    ) VALUES
    ( 274
    , l_layout_code
    , l_header_block_id
    , 1
    , NULL
    , 'HEADER'
    , 'BNE_HEADER'
    , NULL
    , 'BNE_HEADER_ROW'
    , NULL
    , NULL
    , NULL
    , 'Y'
    , 'BNE_HEADER_HEADER'
    , NULL
    , 'Y'
    , 'BNE_HEADER_HINT'
    , NULL
    , 'HORIZONTAL'
    , 'COLUMN_FLOW'
    , 'Y'
    , 1
    , 1
    , 1
    , 10
    , 3
    , 1
    , 2
    , 'BNE_LINES_TOTAL'
    , NULL
    , SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    );

    INSERT INTO BNE_LAYOUT_BLOCKS_TL
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , USER_NAME
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    , LANGUAGE
    , SOURCE_LANG
    )
    SELECT 274
    ,      l_layout_code
    ,      l_header_block_id
    ,      M.MESSAGE_TEXT
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_NEW_MESSAGES M,
           FND_LANGUAGES L
    WHERE  M.MESSAGE_NAME = 'LAY_LB_HEADER'
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

  END IF;

  -----------------------------------------------------------------------------
  -- Creaate line block within the layout
  -----------------------------------------------------------------------------
  BEGIN
    SELECT B.BLOCK_ID
    INTO   l_line_block_id
    FROM   BNE_LAYOUT_BLOCKS_B B
    WHERE  B.APPLICATION_ID = 274
    AND    B.LAYOUT_CODE = l_layout_code
    AND    B.LAYOUT_ELEMENT = 'LINE'
    AND    B.PARENT_ID =
    (
      SELECT BLOCK_ID
      FROM   BNE_LAYOUT_BLOCKS_B
      WHERE  APPLICATION_ID = B.APPLICATION_ID
      AND    LAYOUT_CODE = B.LAYOUT_CODE
      AND    LAYOUT_ELEMENT = 'HEADER'
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
  END;

  IF (l_line_block_id IS NULL) THEN
    ---------------------------------------------------------------------------
    -- Insert Line block into the layout
    ---------------------------------------------------------------------------
    l_line_block_id := 2;

    INSERT INTO BNE_LAYOUT_BLOCKS_B
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , OBJECT_VERSION_NUMBER
    , PARENT_ID
    , LAYOUT_ELEMENT
    , STYLE_CLASS
    , STYLE
    , ROW_STYLE_CLASS
    , ROW_STYLE
    , COL_STYLE_CLASS
    , COL_STYLE
    , PROMPT_DISPLAYED_FLAG
    , PROMPT_STYLE_CLASS
    , PROMPT_STYLE
    , HINT_DISPLAYED_FLAG
    , HINT_STYLE_CLASS
    , HINT_STYLE
    , ORIENTATION
    , LAYOUT_CONTROL
    , DISPLAY_FLAG
    , BLOCKSIZE
    , MINSIZE
    , MAXSIZE
    , SEQUENCE_NUM
    , PROMPT_COLSPAN
    , HINT_COLSPAN
    , ROW_COLSPAN
    , SUMMARY_STYLE_CLASS
    , SUMMARY_STYLE
    , CREATION_DATE
    , CREATED_BY
    , LAST_UPDATE_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    ) VALUES
    ( 274
    , l_layout_code
    , l_line_block_id
    , 1
    , l_header_block_id
    , 'LINE'
    , 'BNE_LINES'
    , NULL
    , 'BNE_LINES_ROW'
    , NULL
    , NULL
    , NULL
    , 'Y'
    , 'BNE_LINES_HEADER'
    , NULL
    , 'Y'
    , 'BNE_LINES_HINT'
    , NULL
    , 'VERTICAL'
    , 'TABLE_FLOW'
    , 'Y'
    , 10
    , 1
    , 1
    , 20
    , NULL
    , NULL
    , NULL
    , 'BNE_LINES_TOTAL'
    , NULL
    , SYSDATE
    , l_user_id
    , SYSDATE
    , l_user_id
    , l_login_id
    );

    INSERT INTO BNE_LAYOUT_BLOCKS_TL
    ( APPLICATION_ID
    , LAYOUT_CODE
    , BLOCK_ID
    , USER_NAME
    , CREATED_BY
    , CREATION_DATE
    , LAST_UPDATED_BY
    , LAST_UPDATE_LOGIN
    , LAST_UPDATE_DATE
    , LANGUAGE
    , SOURCE_LANG
    )
    SELECT 274
    ,      l_layout_code
    ,      l_line_block_id
    ,      M.MESSAGE_TEXT
    ,      l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_NEW_MESSAGES M,
           FND_LANGUAGES L
    WHERE  M.MESSAGE_NAME = 'LAY_LB_LINE'
    AND    M.LANGUAGE_CODE = L.LANGUAGE_CODE
    AND    L.INSTALLED_FLAG IN ('I', 'B');

  END IF;


  -----------------------------------------------------------------------------
  -- Delete and Insert into BNE_LAYOUT_COLS
  -----------------------------------------------------------------------------
  delete from
  bne_layout_cols
  where
  layout_code = l_layout_code;

 for layout_cols in
 (
 select * from bne_interface_cols_b where interface_code = l_interface_code
 and application_id = 274 and interface_col_type = 1 and enabled_flag = 'Y'
 and display_flag = 'Y'
 )
 loop

  INSERT INTO BNE_LAYOUT_COLS
  ( APPLICATION_ID
  , LAYOUT_CODE
  , BLOCK_ID
  , OBJECT_VERSION_NUMBER
  , INTERFACE_APP_ID
  , INTERFACE_CODE
  , INTERFACE_SEQ_NUM
  , SEQUENCE_NUM
  , STYLE
  , STYLE_CLASS
  , HINT_STYLE
  , HINT_STYLE_CLASS
  , PROMPT_STYLE
  , PROMPT_STYLE_CLASS
  , DEFAULT_TYPE
  , DEFAULT_VALUE
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , LAST_UPDATE_DATE
  )
  VALUES(
   274
  ,l_layout_code
  ,decode(layout_cols.interface_col_name,'P_TABLE_NAME',1,'P_LEDGER_DISPLAY_CODE',1,'P_CAL_PERIOD',1,'P_DATASET_CODE',1,'P_SOURCE_SYSTEM_DISPLAY_CODE',1,2)
  ,1
  ,274
  ,l_interface_code
  ,layout_cols.sequence_num
  ,l_layout_seq * 10
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,NULL
  ,l_user_id
  ,SYSDATE
  ,l_user_id
  ,l_login_id
  ,SYSDATE);

   l_layout_seq := l_layout_seq + 1;
   end loop;

  update bne_layout_cols b
  set interface_seq_num = (select sequence_num from bne_interface_cols_b where interface_code = l_interface_code and display_order = b.sequence_num)
  where layout_code = l_layout_code
  and block_id =2;


--------------------------- Populating remaining params from the API into bne_interface_cols_b / tl

  select max(sequence_num) into l_sequence_num from
  bne_interface_cols_b where interface_code = l_interface_code;

 for extra_params in
 (
 select bne_interface_col_name from fem_webadi_table_cols_maps
 where interface_table_name = (select interface_table_name from fem_tables_b where table_name = p_table_name)
 and bne_interface_col_name not in(select interface_col_name from
 bne_interface_cols_b where interface_code = l_interface_code)
 )
 loop

  INSERT INTO BNE_INTERFACE_COLS_B (
          INTERFACE_COL_TYPE,
          INTERFACE_COL_NAME,
          ENABLED_FLAG,
          REQUIRED_FLAG,
          DISPLAY_FLAG,
          READ_ONLY_FLAG,
          NOT_NULL_FLAG,
          SUMMARY_FLAG,
          MAPPING_ENABLED_FLAG,
          DATA_TYPE,
          FIELD_SIZE,
          DEFAULT_TYPE,
          DEFAULT_VALUE,
          SEGMENT_NUMBER,
          GROUP_NAME,
          OA_FLEX_CODE,
          OA_CONCAT_FLEX,
          VAL_TYPE,
          VAL_ID_COL,
          VAL_MEAN_COL,
          VAL_DESC_COL,
          VAL_OBJ_NAME,
          VAL_ADDL_W_C,
          VAL_COMPONENT_APP_ID,
          VAL_COMPONENT_CODE,
          OA_FLEX_NUM,
          OA_FLEX_APPLICATION_ID,
          DISPLAY_ORDER,
          UPLOAD_PARAM_LIST_ITEM_NUM,
          EXPANDED_SQL_QUERY,
          APPLICATION_ID,
          INTERFACE_CODE,
          OBJECT_VERSION_NUMBER,
          SEQUENCE_NUM,
          LOV_TYPE,
          OFFLINE_LOV_ENABLED_FLAG,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          VARIABLE_DATA_TYPE_CLASS
        )
     VALUES
        ( 1,   -- interface col type
           extra_params.bne_interface_col_name, -- interface col name
          'N', -- enabled flag
          'N', -- initially 'N' required flag
          'N', -- display flag 'Y' initially
          'N', -- read only flag
          'N', -- not null flag
          'N', -- summary flag
          'N', -- mapping enabled flag
          2, -- Data Type Varchar for all
          NULL, -- field size
          NULL, -- default type
          NULL, -- default value
          NULL, -- segment number
          NULL, -- group name
          NULL, -- oa flex code
          NULL, -- oa concat flex
          NULL, -- validation type
          NULL, -- val id col
          NULL, -- val mean col
          NULL, -- val desc col
          NULL, -- val object name
          NULL, -- vsl where clause
          NULL, -- val component app id
          NULL, -- val component code
          NULL, -- oa flex num
          NULL, -- oa flex app id
          NULL, -- display order
          TO_NUMBER(SUBSTR(extra_params.bne_interface_col_name, 8)) + 5, -- upload param list item number
          NULL, -- expanded sql query
          274, -- application id
          l_interface_code, -- interface code
          1, -- object version number
          l_sequence_num + 1, -- sequence number (max(seq) +1)
          NULL, -- lov type
          NULL, -- offline enabled lov flag
          SYSDATE, -- creation date
          l_user_id, -- created by
          SYSDATE, -- last updated by
          l_user_id, -- last updated by
          l_login_id, -- last update login
          NULL -- variable data type class
        );

       l_sequence_num := l_sequence_num + 1;

 end loop;

 select max(sequence_num) into l_sequence_num from
 bne_interface_cols_b where interface_code = l_interface_code;

 select (max(UPLOAD_PARAM_LIST_ITEM_NUM) - 5) into l_list_item_num from bne_interface_cols_b
 where interface_code = l_interface_code;

 l_list_item_num := l_list_item_num + 1;
  l_sequence_num := l_sequence_num + 1;

 for l_interface_code_postfix in l_list_item_num..300
 loop

  INSERT INTO BNE_INTERFACE_COLS_B (
          INTERFACE_COL_TYPE,
          INTERFACE_COL_NAME,
          ENABLED_FLAG,
          REQUIRED_FLAG,
          DISPLAY_FLAG,
          READ_ONLY_FLAG,
          NOT_NULL_FLAG,
          SUMMARY_FLAG,
          MAPPING_ENABLED_FLAG,
          DATA_TYPE,
          FIELD_SIZE,
          DEFAULT_TYPE,
          DEFAULT_VALUE,
          SEGMENT_NUMBER,
          GROUP_NAME,
          OA_FLEX_CODE,
          OA_CONCAT_FLEX,
          VAL_TYPE,
          VAL_ID_COL,
          VAL_MEAN_COL,
          VAL_DESC_COL,
          VAL_OBJ_NAME,
          VAL_ADDL_W_C,
          VAL_COMPONENT_APP_ID,
          VAL_COMPONENT_CODE,
          OA_FLEX_NUM,
          OA_FLEX_APPLICATION_ID,
          DISPLAY_ORDER,
          UPLOAD_PARAM_LIST_ITEM_NUM,
          EXPANDED_SQL_QUERY,
          APPLICATION_ID,
          INTERFACE_CODE,
          OBJECT_VERSION_NUMBER,
          SEQUENCE_NUM,
          LOV_TYPE,
          OFFLINE_LOV_ENABLED_FLAG,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          VARIABLE_DATA_TYPE_CLASS
        )
     VALUES
        ( 1,   -- interface col type
           'P_PARAM' || l_list_item_num , -- interface col name
          'N', -- enabled flag
          'N', -- initially 'N' required flag
          'N', -- display flag 'Y' initially
          'N', -- read only flag
          'N', --  not null flag
          'N', -- summary flag
          'N', -- mapping enabled flag
          2, -- Data Type Varchar for all
          NULL, -- field size
          NULL, -- default type
          NULL, -- default value
          NULL, -- segment number
          NULL, -- group name
          NULL, -- oa flex code
          NULL, -- oa concat flex
          NULL, -- validation type
          NULL, -- val id col
          NULL, -- val mean col
          NULL, -- val desc col
          NULL, -- val object name
          NULL, -- vsl where clause
          NULL, -- val component app id
          NULL, -- val component code
          NULL, -- oa flex num
          NULL, -- oa flex app id
          NULL, -- display order
          l_list_item_num + 5, -- upload param list item number
          NULL, -- expanded sql query
          274, -- application id
          l_interface_code, -- interface code
          1, -- object version number
          l_sequence_num, -- sequence number (max(seq) +1)
          NULL, -- lov type
          NULL, -- offline enabled lov flag
          SYSDATE, -- creation date
          l_user_id, -- created by
          SYSDATE, -- last updated by
          l_user_id, -- last updated by
          l_login_id, -- last update login
          NULL -- variable data type class
        );

        l_sequence_num := l_sequence_num + 1;
        l_list_item_num := l_list_item_num + 1;

 end loop;


END POPULATE_LAYOUT;

PROCEDURE POPULATE_INTERFACE_PARAM_COLS(P_INTERFACE_CODE IN VARCHAR2, P_TABLE_NAME IN VARCHAR2)
IS

l_table_name varchar2(50) := p_table_name; --substr(p_interface_code,0,instr(p_interface_code,'INTF')-2);
l_java_val_class varchar2(500) := 'oracle.apps.fem.integrator.tables.validators.FemMemberValidator';
--l_java_group_val_class varchar2(500) := 'oracle.apps.fem.integrator.tables.validators.FemTablesGroupValidator';
l_java_group_val_class varchar2(500) := null;
l_component_code varchar2(50) := 'FEM_DIMENSION_MEMBER';
l_group_name varchar(50) := 'TABLE_GROUP_VALIDATOR';
l_sequence_num number := 7; -- 1 to 6 are already assigned to req cols and grp validator rows
l_segment_num number := 6; -- 1-5 are assigned to req cols and grp validator but table name
l_user_id number := 2;
l_login_id number := NVL(Fnd_Global.Login_Id, 0);
l_interface_table_name varchar2(50);
l_display_order number := 6;

begin

 select interface_table_name into l_interface_table_name from
 fem_tables_b where table_name = l_table_name;

--------- First populating bne_interface_cols  ( 'delete insert' those records for which we have info in fem_tab_columns_b table

-------------------------------  For bne_interface_cols_b

 for new_rec in
 (
  select M.bne_interface_col_name bne_interface_col_name,M.interface_column_name interface_column_name,M.data_type data_type ,M.nullable nullable,
  T.fem_data_type_code fem_data_type,T.column_name column_name
  from
  FEM_WEBADI_TABLE_COLS_MAPS M,FEM_TAB_COLUMNS_B T
  where T.TABLE_NAME = l_table_name
  and M.INTERFACE_TABLE_NAME = l_interface_table_name
  and T.INTERFACE_COLUMN_NAME = M.INTERFACE_COLUMN_NAME
 )

 loop  -- Starting the loop to insert entries one by one


  INSERT INTO BNE_INTERFACE_COLS_B (
          INTERFACE_COL_TYPE,
          INTERFACE_COL_NAME,
          ENABLED_FLAG,
          REQUIRED_FLAG,
          DISPLAY_FLAG,
          READ_ONLY_FLAG,
          NOT_NULL_FLAG,
          SUMMARY_FLAG,
          MAPPING_ENABLED_FLAG,
          DATA_TYPE,
          FIELD_SIZE,
          DEFAULT_TYPE,
          DEFAULT_VALUE,
          SEGMENT_NUMBER,
          GROUP_NAME,
          OA_FLEX_CODE,
          OA_CONCAT_FLEX,
          VAL_TYPE,
          VAL_ID_COL,
          VAL_MEAN_COL,
          VAL_DESC_COL,
          VAL_OBJ_NAME,
          VAL_ADDL_W_C,
          VAL_COMPONENT_APP_ID,
          VAL_COMPONENT_CODE,
          OA_FLEX_NUM,
          OA_FLEX_APPLICATION_ID,
          DISPLAY_ORDER,
          UPLOAD_PARAM_LIST_ITEM_NUM,
          EXPANDED_SQL_QUERY,
          APPLICATION_ID,
          INTERFACE_CODE,
          OBJECT_VERSION_NUMBER,
          SEQUENCE_NUM,
          LOV_TYPE,
          OFFLINE_LOV_ENABLED_FLAG,
          CREATION_DATE,
          CREATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          VARIABLE_DATA_TYPE_CLASS
        )
        VALUES
        ( 1,   -- interface col type
          new_rec.bne_interface_col_name, -- interface col name
          'Y', -- enabled flag
          decode(new_rec.nullable,'Y','N','N','Y','N'), -- initially 'N' required flag
          'Y', -- display flag 'Y' initially
          'N', -- read only flag
          decode(new_rec.nullable,'Y','N','N','Y','N'), -- not null flag
          'N', -- summary flag
          'N',-- mapping enabled flag
          2,  -- decode(new_rec.data_type,'DATE',3,2), -- Data Type Varchar for all
          2000, -- field size
          NULL, -- default type
          NULL, -- default value
          NULL, -- decode(new_rec.nullable,'N',l_segment_num,NULL), -- segment number
          NULL, -- decode(new_rec.nullable,'N','TABLE_GROUP_VALIDATOR',NULL), -- group name
          NULL, -- oa flex code
          NULL, -- oa concat flex
          DECODE(new_rec.fem_data_type, 'DIMENSION', 'JAVA', NULL), -- validation type
          NULL, -- val id col
          NULL, -- val mean col
          NULL, -- val desc col
          DECODE(new_rec.fem_data_type, 'DIMENSION', 'oracle.apps.fem.integrator.tables.validators.FemMemberValidator', NULL), -- val object name
          NULL, -- vsl where clause
          DECODE(new_rec.fem_data_type, 'DIMENSION', 274, NULL), -- val component app id
          DECODE(new_rec.fem_data_type, 'DIMENSION', l_component_code, NULL), -- val component code
          NULL, -- oa flex num
          NULL, -- oa flex app id
          l_sequence_num*10, -- display order
          TO_NUMBER(SUBSTR(new_rec.bne_interface_col_name, 8)) + 5, -- upload param list item number
          NULL, -- expanded sql query
          274, -- application id
          p_interface_code, -- interface code
          1, -- object version number
          l_sequence_num, -- sequence number
          DECODE(new_rec.fem_data_type, 'DIMENSION', 'STANDARD', NULL), -- lov type
          DECODE(new_rec.fem_data_type, 'DIMENSION', 'N', NULL), -- offline enabled lov flag
          SYSDATE, -- creation date
          l_user_id, -- created by
          SYSDATE, -- last updated by
          l_user_id, -- last updated by
          l_login_id, -- last update login
          DECODE(new_rec.DATA_TYPE, 'DATE',
          'oracle.apps.fem.integrator.dimension.validators.FemAttributeDateTypeValidator',
          DECODE(new_rec.DATA_TYPE, 'NUMBER',NULL,
          --'oracle.apps.fem.integrator.dimension.validators.FemAttributeNumericTypeValidator',
          NULL)) -- variable data type class
        );

----------------- For bne_interface_cols_tl

   if(new_rec.fem_data_type = 'DIMENSION') then

     INSERT INTO BNE_INTERFACE_COLS_TL
          (
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          USER_HINT,
          PROMPT_LEFT,
          USER_HELP_TEXT,
          PROMPT_ABOVE,
          INTERFACE_CODE,
          SEQUENCE_NUM,
          APPLICATION_ID,
          LANGUAGE,
          SOURCE_LANG
        )
        SELECT l_user_id
        ,      SYSDATE
        ,      l_user_id
        ,      l_login_id
        ,      SYSDATE
        ,      M.MESSAGE_TEXT
        ,      TL.DISPLAY_NAME
        ,      NULL
        ,      TL.DISPLAY_NAME
        ,      p_interface_code
        ,      l_sequence_num
        ,      274
        ,      L.LANGUAGE_CODE
        ,      TL.SOURCE_LANG
        FROM   FEM_TAB_COLUMNS_B TB
        ,      FEM_TAB_COLUMNS_TL TL
        ,      FND_NEW_MESSAGES M
        ,      FND_LANGUAGES L
        WHERE  L.INSTALLED_FLAG IN ('I', 'B')
        AND    TB.COLUMN_NAME = new_rec.column_name
        AND    TB.TABLE_NAME = l_table_name -- substr(p_interface_code,0,instr(p_interface_code,'_INTF')-1)
        AND    TL.COLUMN_NAME = TB.COLUMN_NAME
        AND    TL.TABLE_NAME = TB.TABLE_NAME
        AND    TB.FEM_DATA_TYPE_CODE = 'DIMENSION'
        AND    TL.LANGUAGE (+) = L.LANGUAGE_CODE
        AND    M.MESSAGE_NAME (+) =
               DECODE(new_rec.fem_data_type,'DIMENSION',DECODE(new_rec.nullable, 'N', 'FEM_ADI_USER_HINT_LOV_REQ', 'FEM_ADI_USER_HINT_LOV'),NULL)
        AND    M.LANGUAGE_CODE (+) = L.LANGUAGE_CODE;

    else

       INSERT INTO BNE_INTERFACE_COLS_TL
          (
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_LOGIN,
          LAST_UPDATE_DATE,
          USER_HINT,
          PROMPT_LEFT,
          USER_HELP_TEXT,
          PROMPT_ABOVE,
          INTERFACE_CODE,
          SEQUENCE_NUM,
          APPLICATION_ID,
          LANGUAGE,
          SOURCE_LANG
        )
        SELECT l_user_id
        ,      SYSDATE
        ,      l_user_id
        ,      l_login_id
        ,      SYSDATE
        ,      M.MESSAGE_TEXT
        ,      TL.DISPLAY_NAME
        ,      NULL
        ,      TL.DISPLAY_NAME
        ,      p_interface_code
        ,      l_sequence_num
        ,      274
        ,      L.LANGUAGE_CODE
        ,      TL.SOURCE_LANG
        FROM   FEM_TAB_COLUMNS_B TB
        ,      FEM_TAB_COLUMNS_TL TL
        ,      FND_NEW_MESSAGES M
        ,      FND_LANGUAGES L
        WHERE  L.INSTALLED_FLAG IN ('I', 'B')
        AND    TB.COLUMN_NAME = new_rec.column_name
        AND    TB.TABLE_NAME = l_table_name -- substr(p_interface_code,0,instr(p_interface_code,'_INTF')-1)
        AND    TL.COLUMN_NAME = TB.COLUMN_NAME
        AND    TL.TABLE_NAME = TB.TABLE_NAME
        AND    TB.FEM_DATA_TYPE_CODE <> 'DIMENSION'
        AND    TL.LANGUAGE (+) = L.LANGUAGE_CODE
        AND    M.MESSAGE_NAME (+)=
               DECODE(new_rec.DATA_TYPE, 'VARCHAR2',
                 DECODE(new_rec.nullable, 'N', 'FEM_ADI_USER_HINT_TEXT_REQ', 'FEM_ADI_USER_HINT_TEXT'),
               DECODE(new_rec.DATA_TYPE, 'NUMBER',
                 DECODE(new_rec.nullable, 'N', 'FEM_ADI_USER_HINT_NUMBER_REQ',  'FEM_ADI_USER_HINT_NUMBER'),
               DECODE(new_rec.DATA_TYPE, 'DATE',
                 DECODE(new_rec.nullable, 'N', 'FEM_ADI_USER_HINT_DATE_REQ', 'FEM_ADI_USER_HINT_DATE'), NULL)))
        AND    M.LANGUAGE_CODE (+)= L.LANGUAGE_CODE;

   end if;

    l_sequence_num := l_sequence_num + 1;

    -- if(new_rec.nullable = 'N') then
       --  l_segment_num := l_segment_num + 1;
    -- end if;

   --if (SQL%NOTFOUND) then
     --     RAISE NO_DATA_FOUND;
       -- end if;

  end loop; -- Ending loop for inseting into bne_interface_cols tables.

   -- A row in the bne_interface_cols_tl only, ensures that the interface column info is fine.
   -- now disable the columns in bne_interface_cols_b for which there is no entry in bne_interface_cols_tl.
   -- and disable any ledger, source_system, cal_period, dataset, cal period number, cal period grp display code, cal period end date.

   update bne_interface_cols_b
   set enabled_flag = 'N',
   display_flag = 'N',
   required_flag = 'N',
   not_null_flag = 'N'
   where
   interface_code = p_interface_code and
   interface_col_name in
   (
   select interface_col_name from bne_interface_cols_b tb,fem_webadi_table_cols_maps m, fem_tab_columns_b b where
   tb.interface_col_name = m.bne_interface_col_name and
   m.interface_table_name = l_interface_table_name and
   tb.interface_code = p_interface_code and
   m.interface_column_name = b.interface_column_name and
   b.table_name = l_table_name and
   (b.dimension_id in (select dimension_id from fem_dimensions_b where dimension_varchar_label in
    ('LEDGER','CAL_PERIOD','DATASET','SOURCE_SYSTEM'))
   or not exists( select interface_col_name from bne_interface_cols_vl tl
   where tl.interface_col_name = tb.interface_col_name and interface_code = p_interface_code) or
   m.interface_column_name in ('CALP_DIM_GRP_DISPLAY_CODE','CAL_PERIOD_NUMBER','CAL_PERIOD_END_DATE'))
   );

-------------- Updating the display order so that required columns are shown first -------------------

  update bne_interface_cols_b
  set display_order = null
  where interface_code = p_interface_code and sequence_num > 6;


   for bne_cols in
   (
   select interface_col_name from bne_interface_cols_vl
   where interface_code = p_interface_code
   and display_flag = 'Y' and enabled_flag = 'Y'
   and sequence_num > 6
   order by not_null_flag desc,upper(prompt_above)
   )

  loop  -- Starting the loop to update entries one by one

   update bne_interface_cols_b
   set display_order = l_display_order * 10
   where interface_code = p_interface_code
   and interface_col_name = bne_cols.interface_col_name;

   l_display_order := l_display_order + 1;

  end loop;
-------------------------------------------------------------------------------------------------------

END POPULATE_INTERFACE_PARAM_COLS;

PROCEDURE POPULATE_INTERFACE_COMM_COLS(P_INTERFACE_CODE IN VARCHAR2, P_TABLE_NAME IN VARCHAR2)
IS

  TYPE l_interface_col_rec IS    RECORD
    ( INTERFACE_COL_NAME         VARCHAR2(30)  ,
      INTERFACE_COL_TYPE         NUMBER(15)    ,
      DISPLAY_FLAG               VARCHAR2(1)   ,
      READ_ONLY_FLAG             VARCHAR2(1)   ,
      MAPPING_ENABLED_FLAG       VARCHAR2(1)   ,
      DATA_TYPE                  NUMBER(15)    ,
      FIELD_SIZE                 NUMBER(15)    ,
      DEFAULT_VALUE              VARCHAR(100)  ,
      DEFAULT_TYPE               VARCHAR2(30)  ,
      SEGMENT_VALUE              NUMBER(15)    ,
      GROUP_NAME                 VARCHAR2(30)  ,
      VAL_TYPE                   VARCHAR2(20)  ,
      VAL_ID_COL                 VARCHAR2(240) ,
      VAL_MEAN_COL               VARCHAR2(240) ,
      VAL_DESC_COL               VARCHAR2(240) ,
      VAL_OBJ_NAME               VARCHAR2(240) ,
      VAL_ADDL_W_C               VARCHAR2(2000),
      VAL_COMPONENT_APP_ID       NUMBER(15)    ,
      VAL_COMPONENT_CODE         VARCHAR2(30)  ,
      DISPLAY_ORDER              NUMBER(15)    ,
      UPLOAD_PARAM_LIST_ITEM_NUM NUMBER(15)    ,
      SEQUENCE_NUM               NUMBER(15)    ,
      LOV_TYPE                   VARCHAR2(30)  ,
      OFFLINE_LOV_ENABLED_FLAG   VARCHAR2(1)   ,
      FND_MESSAGE_NAME           VARCHAR2(30)  ,
      USER_HINT_FND_MESSAGE_NAME VARCHAR2(30)
     );

  TYPE l_interface_cols_typ IS TABLE OF l_interface_col_rec
          INDEX BY BINARY_INTEGER;

  l_interface_cols_tbl           l_interface_cols_typ;
  l_user_id                      NUMBER(15)    := 2; --   (user name : initial setup)
  l_login_id                     NUMBER        := NVL(Fnd_Global.Login_Id, 0);
  l_table_name                   varchar2(50)  := p_table_name; --substr(p_interface_code,0,instr(p_interface_code,'_INTF')-1);
  l_table_display_name           varchar2(150);

begin
 delete from bne_interface_cols_b
 where interface_code = p_interface_code;

 delete from bne_interface_cols_tl
 where interface_code = p_interface_code;

  select display_name into l_table_display_name from fem_tables_vl
  where table_name = l_table_name;

  -----------------------------------------------------------------------------
  -- Set up plsql table for interface column definition
  -----------------------------------------------------------------------------

  -----------------------------------------------------------------------------
  -- Set up for column P_TABLE_NAME
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(1).INTERFACE_COL_NAME         := 'P_TABLE_NAME';
  l_interface_cols_tbl(1).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(1).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(1).READ_ONLY_FLAG             := 'Y';
  l_interface_cols_tbl(1).MAPPING_ENABLED_FLAG       := 'Y';
  l_interface_cols_tbl(1).DATA_TYPE                  := 2; --VARCHAR
  l_interface_cols_tbl(1).FIELD_SIZE                 := 80;
  l_interface_cols_tbl(1).DEFAULT_VALUE              := 'select display_name from fem_tables_vl where table_name = $PARAM$.table_name';
  l_interface_cols_tbl(1).DEFAULT_TYPE               := 'SQL';
  l_interface_cols_tbl(1).SEGMENT_VALUE              := NULL;
  l_interface_cols_tbl(1).GROUP_NAME                 := NULL; -- 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(1).VAL_TYPE                   := NULL;
  l_interface_cols_tbl(1).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(1).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(1).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(1).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(1).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(1).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(1).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(1).DISPLAY_ORDER              := 10; -- sequence_num * 10
  l_interface_cols_tbl(1).UPLOAD_PARAM_LIST_ITEM_NUM := 1;
  l_interface_cols_tbl(1).SEQUENCE_NUM               := 1;
  l_interface_cols_tbl(1).LOV_TYPE                   := NULL;
  l_interface_cols_tbl(1).OFFLINE_LOV_ENABLED_FLAG   := NULL;
  l_interface_cols_tbl(1).FND_MESSAGE_NAME           := 'FEM_ADI_TABLE_NAME';
  l_interface_cols_tbl(1).USER_HINT_FND_MESSAGE_NAME := NULL;

  -----------------------------------------------------------------------------
  -- Set up for column TABLE_GROUP_VALIDATOR
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(2).INTERFACE_COL_NAME         := 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(2).INTERFACE_COL_TYPE         := 2;
  l_interface_cols_tbl(2).DISPLAY_FLAG               := 'N';
  l_interface_cols_tbl(2).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(2).MAPPING_ENABLED_FLAG       := 'N';
  l_interface_cols_tbl(2).DATA_TYPE                  := 2; -- VARCHAR
  l_interface_cols_tbl(2).FIELD_SIZE                 := 1;
  l_interface_cols_tbl(2).DEFAULT_VALUE              := NULL;
  l_interface_cols_tbl(2).DEFAULT_TYPE               := NULL;
  l_interface_cols_tbl(2).SEGMENT_VALUE              := 1;
  l_interface_cols_tbl(2).GROUP_NAME                 := 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(2).VAL_TYPE                   := 'GROUP';
  l_interface_cols_tbl(2).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(2).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(2).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(2).VAL_OBJ_NAME               := NULL;
  l_interface_cols_tbl(2).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(2).VAL_COMPONENT_APP_ID       := NULL;
  l_interface_cols_tbl(2).VAL_COMPONENT_CODE         := NULL;
  l_interface_cols_tbl(2).DISPLAY_ORDER              := NULL;
  l_interface_cols_tbl(2).UPLOAD_PARAM_LIST_ITEM_NUM := NULL;
  l_interface_cols_tbl(2).SEQUENCE_NUM               := 2;
  l_interface_cols_tbl(2).LOV_TYPE                   := 'NONE';
  l_interface_cols_tbl(2).OFFLINE_LOV_ENABLED_FLAG   := 'N';
  l_interface_cols_tbl(2).FND_MESSAGE_NAME           := NULL;
  l_interface_cols_tbl(2).USER_HINT_FND_MESSAGE_NAME := NULL;

  -----------------------------------------------------------------------------
  -- Set up for column P_LEDGER_DISPLAY_CODE
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(3).INTERFACE_COL_NAME         := 'P_LEDGER_DISPLAY_CODE';
  l_interface_cols_tbl(3).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(3).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(3).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(3).MAPPING_ENABLED_FLAG       := 'N';
  l_interface_cols_tbl(3).DATA_TYPE                  := 2;  --VARCHAR
  l_interface_cols_tbl(3).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(3).DEFAULT_VALUE              := NULL;
  l_interface_cols_tbl(3).DEFAULT_TYPE               := NULL;
  l_interface_cols_tbl(3).SEGMENT_VALUE              := 2;
  l_interface_cols_tbl(3).GROUP_NAME                 := NULL; -- 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(3).VAL_TYPE                   := 'TABLE';
  l_interface_cols_tbl(3).VAL_ID_COL                 := 'LEDGER_DISPLAY_CODE';
  l_interface_cols_tbl(3).VAL_MEAN_COL               := 'LEDGER_NAME';
  l_interface_cols_tbl(3).VAL_DESC_COL               := 'DESCRIPTION';
  l_interface_cols_tbl(3).VAL_OBJ_NAME               := 'FEM_LEDGERS_VL';
  l_interface_cols_tbl(3).VAL_ADDL_W_C               := 'ENABLED_FLAG = ''Y'' AND PERSONAL_FLAG = ''N''';
  l_interface_cols_tbl(3).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(3).VAL_COMPONENT_CODE         := 'FEM_LEDGER_CODE';
  l_interface_cols_tbl(3).DISPLAY_ORDER              := 20;
  l_interface_cols_tbl(3).UPLOAD_PARAM_LIST_ITEM_NUM := 2;
  l_interface_cols_tbl(3).SEQUENCE_NUM               := 3;
  l_interface_cols_tbl(3).LOV_TYPE                   := 'STANDARD';
  l_interface_cols_tbl(3).OFFLINE_LOV_ENABLED_FLAG   := 'Y';
  l_interface_cols_tbl(3).FND_MESSAGE_NAME           := 'FEM_ADI_LEDGER_NAME';
  l_interface_cols_tbl(3).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';

  -----------------------------------------------------------------------------
  -- Set up for column P_CAL_PERIOD
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(4).INTERFACE_COL_NAME         := 'P_CAL_PERIOD';
  l_interface_cols_tbl(4).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(4).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(4).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(4).MAPPING_ENABLED_FLAG       := 'N';
  l_interface_cols_tbl(4).DATA_TYPE                  := 2; --VARCHAR
  l_interface_cols_tbl(4).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(4).DEFAULT_VALUE              := NULL;
  l_interface_cols_tbl(4).DEFAULT_TYPE               := NULL;
  l_interface_cols_tbl(4).SEGMENT_VALUE              := 3;
  l_interface_cols_tbl(4).GROUP_NAME                 := NULL; -- 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(4).VAL_TYPE                   := 'JAVA';
  l_interface_cols_tbl(4).VAL_ID_COL                 := NULL;
  l_interface_cols_tbl(4).VAL_MEAN_COL               := NULL;
  l_interface_cols_tbl(4).VAL_DESC_COL               := NULL;
  l_interface_cols_tbl(4).VAL_OBJ_NAME               :=  'oracle.apps.fem.integrator.tables.validators.FemMemberValidator';
  l_interface_cols_tbl(4).VAL_ADDL_W_C               := NULL;
  l_interface_cols_tbl(4).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(4).VAL_COMPONENT_CODE         := 'FEM_DIMENSION_MEMBER';
  l_interface_cols_tbl(4).DISPLAY_ORDER              := 30;
  l_interface_cols_tbl(4).UPLOAD_PARAM_LIST_ITEM_NUM := 3;
  l_interface_cols_tbl(4).SEQUENCE_NUM               := 4;
  l_interface_cols_tbl(4).LOV_TYPE                   := 'STANDARD';
  l_interface_cols_tbl(4).OFFLINE_LOV_ENABLED_FLAG   := 'Y';
  l_interface_cols_tbl(4).FND_MESSAGE_NAME           := 'FEM_ADI_CAL_PERIOD_NAME';
  l_interface_cols_tbl(4).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';

  -----------------------------------------------------------------------------
  -- Set up for column P_DATASET_DISPLAY_CODE
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(5).INTERFACE_COL_NAME         := 'P_DATASET_CODE';
  l_interface_cols_tbl(5).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(5).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(5).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(5).MAPPING_ENABLED_FLAG       := 'N';
  l_interface_cols_tbl(5).DATA_TYPE                  := 2; --VARCHAR
  l_interface_cols_tbl(5).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(5).DEFAULT_VALUE              := NULL;
  l_interface_cols_tbl(5).DEFAULT_TYPE               := NULL;
  l_interface_cols_tbl(5).SEGMENT_VALUE              := 4;
  l_interface_cols_tbl(5).GROUP_NAME                 := NULL; -- 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(5).VAL_TYPE                   := 'TABLE';
  l_interface_cols_tbl(5).VAL_ID_COL                 := 'DATASET_CODE';
  l_interface_cols_tbl(5).VAL_MEAN_COL               := 'DATASET_NAME';
  l_interface_cols_tbl(5).VAL_DESC_COL               := 'DESCRIPTION';
  l_interface_cols_tbl(5).VAL_OBJ_NAME               := 'FEM_DATASETS_VL';
  l_interface_cols_tbl(5).VAL_ADDL_W_C               := 'ENABLED_FLAG = ''Y'' AND PERSONAL_FLAG = ''N''';
  l_interface_cols_tbl(5).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(5).VAL_COMPONENT_CODE         := 'FEM_DATASET';
  l_interface_cols_tbl(5).DISPLAY_ORDER              := 40;
  l_interface_cols_tbl(5).UPLOAD_PARAM_LIST_ITEM_NUM := 4;
  l_interface_cols_tbl(5).SEQUENCE_NUM               := 5;
  l_interface_cols_tbl(5).LOV_TYPE                   := 'STANDARD';
  l_interface_cols_tbl(5).OFFLINE_LOV_ENABLED_FLAG   := 'Y';
  l_interface_cols_tbl(5).FND_MESSAGE_NAME           := 'FEM_ADI_DATASET_NAME';
  l_interface_cols_tbl(5).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';

   -----------------------------------------------------------------------------
  -- Set up for column P_SOURCE_SYSTEM_DISPLAY_CODE
  -----------------------------------------------------------------------------
  l_interface_cols_tbl(6).INTERFACE_COL_NAME         := 'P_SOURCE_SYSTEM_DISPLAY_CODE';
  l_interface_cols_tbl(6).INTERFACE_COL_TYPE         := 1;
  l_interface_cols_tbl(6).DISPLAY_FLAG               := 'Y';
  l_interface_cols_tbl(6).READ_ONLY_FLAG             := 'N';
  l_interface_cols_tbl(6).MAPPING_ENABLED_FLAG       := 'N';
  l_interface_cols_tbl(6).DATA_TYPE                  := 2; --VARCHAR
  l_interface_cols_tbl(6).FIELD_SIZE                 := 150;
  l_interface_cols_tbl(6).DEFAULT_VALUE              := NULL;
  l_interface_cols_tbl(6).DEFAULT_TYPE               := NULL;
  l_interface_cols_tbl(6).SEGMENT_VALUE              := 5;
  l_interface_cols_tbl(6).GROUP_NAME                 := NULL; -- 'TABLE_GROUP_VALIDATOR';
  l_interface_cols_tbl(6).VAL_TYPE                   := 'TABLE';
  l_interface_cols_tbl(6).VAL_ID_COL                 := 'SOURCE_SYSTEM_DISPLAY_CODE';
  l_interface_cols_tbl(6).VAL_MEAN_COL               := 'SOURCE_SYSTEM_NAME';
  l_interface_cols_tbl(6).VAL_DESC_COL               := 'DESCRIPTION';
  l_interface_cols_tbl(6).VAL_OBJ_NAME               := 'FEM_SOURCE_SYSTEMS_VL';
  l_interface_cols_tbl(6).VAL_ADDL_W_C               := 'ENABLED_FLAG = ''Y'' AND PERSONAL_FLAG = ''N''';
  l_interface_cols_tbl(6).VAL_COMPONENT_APP_ID       := 274;
  l_interface_cols_tbl(6).VAL_COMPONENT_CODE         := 'FEM_SOURCE_SYSTEM';
  l_interface_cols_tbl(6).DISPLAY_ORDER              := 50;
  l_interface_cols_tbl(6).UPLOAD_PARAM_LIST_ITEM_NUM := 5;
  l_interface_cols_tbl(6).SEQUENCE_NUM               := 6;
  l_interface_cols_tbl(6).LOV_TYPE                   := 'STANDARD';
  l_interface_cols_tbl(6).OFFLINE_LOV_ENABLED_FLAG   := 'Y';
  l_interface_cols_tbl(6).FND_MESSAGE_NAME           := 'FEM_ADI_SOURCE_SYSTEM_NAME';
  l_interface_cols_tbl(6).USER_HINT_FND_MESSAGE_NAME := 'FEM_ADI_USER_HINT_LOV_REQ';

  -----------------------------------------------------------------------------
  -- Inserting into BNE_INTERFACE_COLS and BNE_INTERFACE_COLS_TL
  -----------------------------------------------------------------------------
  FOR i IN l_interface_cols_tbl.FIRST .. l_interface_cols_tbl.LAST
  LOOP
    INSERT INTO BNE_INTERFACE_COLS_B (
      INTERFACE_COL_TYPE,
      INTERFACE_COL_NAME,
      ENABLED_FLAG,
      REQUIRED_FLAG,
      DISPLAY_FLAG,
      READ_ONLY_FLAG,
      NOT_NULL_FLAG,
      SUMMARY_FLAG,
      MAPPING_ENABLED_FLAG,
      DATA_TYPE,
      FIELD_SIZE,
      DEFAULT_TYPE,
      DEFAULT_VALUE,
      SEGMENT_NUMBER,
      GROUP_NAME,
      OA_FLEX_CODE,
      OA_CONCAT_FLEX,
      VAL_TYPE,
      VAL_ID_COL,
      VAL_MEAN_COL,
      VAL_DESC_COL,
      VAL_OBJ_NAME,
      VAL_ADDL_W_C,
      VAL_COMPONENT_APP_ID,
      VAL_COMPONENT_CODE,
      OA_FLEX_NUM,
      OA_FLEX_APPLICATION_ID,
      DISPLAY_ORDER,
      UPLOAD_PARAM_LIST_ITEM_NUM,
      EXPANDED_SQL_QUERY,
      APPLICATION_ID,
      INTERFACE_CODE,
      OBJECT_VERSION_NUMBER,
      SEQUENCE_NUM,
      LOV_TYPE,
      OFFLINE_LOV_ENABLED_FLAG,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      VARIABLE_DATA_TYPE_CLASS
    )
    VALUES
    ( l_interface_cols_tbl(i).INTERFACE_COL_TYPE,
      l_interface_cols_tbl(i).INTERFACE_COL_NAME,
      'Y',
      decode(l_interface_cols_tbl(i).INTERFACE_COL_TYPE,2,'N','Y'),
      l_interface_cols_tbl(i).DISPLAY_FLAG,
      l_interface_cols_tbl(i).READ_ONLY_FLAG,
      decode(l_interface_cols_tbl(i).INTERFACE_COL_TYPE,2,'N','Y'),
      'N',
      l_interface_cols_tbl(i).MAPPING_ENABLED_FLAG,
      l_interface_cols_tbl(i).DATA_TYPE,
      l_interface_cols_tbl(i).FIELD_SIZE,
      l_interface_cols_tbl(i).DEFAULT_TYPE,
      l_interface_cols_tbl(i).DEFAULT_VALUE,
      l_interface_cols_tbl(i).SEGMENT_VALUE,
      l_interface_cols_tbl(i).GROUP_NAME,
      NULL,
      NULL,
      l_interface_cols_tbl(i).VAL_TYPE,
      l_interface_cols_tbl(i).VAL_ID_COL,
      l_interface_cols_tbl(i).VAL_MEAN_COL,
      l_interface_cols_tbl(i).VAL_DESC_COL,
      l_interface_cols_tbl(i).VAL_OBJ_NAME,
      l_interface_cols_tbl(i).VAL_ADDL_W_C,
      l_interface_cols_tbl(i).VAL_COMPONENT_APP_ID,
      l_interface_cols_tbl(i).VAL_COMPONENT_CODE,
      NULL,
      NULL,
      l_interface_cols_tbl(i).DISPLAY_ORDER,
      l_interface_cols_tbl(i).UPLOAD_PARAM_LIST_ITEM_NUM,
      NULL,
      274,
      p_interface_code,
      1,
      l_interface_cols_tbl(i).SEQUENCE_NUM,
      l_interface_cols_tbl(i).LOV_TYPE,
      l_interface_cols_tbl(i).OFFLINE_LOV_ENABLED_FLAG,
      SYSDATE,
      l_user_id,
      SYSDATE,
      l_user_id,
      l_login_id,
      NULL
    );

    INSERT INTO BNE_INTERFACE_COLS_TL (
      CREATED_BY,
      CREATION_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN,
      LAST_UPDATE_DATE,
      USER_HINT,
      PROMPT_LEFT,
      USER_HELP_TEXT,
      PROMPT_ABOVE,
      INTERFACE_CODE,
      SEQUENCE_NUM,
      APPLICATION_ID,
      LANGUAGE,
      SOURCE_LANG
    )
    SELECT l_user_id
    ,      SYSDATE
    ,      l_user_id
    ,      l_login_id
    ,      SYSDATE
    ,      M2.MESSAGE_TEXT
    ,      M1.MESSAGE_TEXT
    ,      NULL
    ,      M1.MESSAGE_TEXT
    ,      p_interface_code
    ,      l_interface_cols_tbl(i).SEQUENCE_NUM
    ,      274
    ,      L.LANGUAGE_CODE
    ,      USERENV('LANG')
    FROM   FND_NEW_MESSAGES M1,
           FND_NEW_MESSAGES M2,
           FND_LANGUAGES L
    WHERE  L.INSTALLED_FLAG IN ('I', 'B')
    AND    M1.MESSAGE_NAME (+)= l_interface_cols_tbl(i).FND_MESSAGE_NAME
    AND    M1.LANGUAGE_CODE (+)= L.LANGUAGE_CODE
    AND    M2.MESSAGE_NAME (+)= l_interface_cols_tbl(i).USER_HINT_FND_MESSAGE_NAME
    AND    M2.LANGUAGE_CODE (+)= L.LANGUAGE_CODE;

  END LOOP;

END  POPULATE_INTERFACE_COMM_COLS;

PROCEDURE POPULATE_TABLE_COLUMN_MAPS(P_TABLE_NAME IN VARCHAR2)
IS

l_bne_interface_col_name varchar2(50);
l_interface_column_name varchar2(50);
l_map_exists varchar2(1);
l_param_postfix number := 1;
l_nullable varchar2(1);
l_data_type varchar2(20);

cursor CUR_INTF_COLUMNS is
select column_name,data_type,nullable from dba_tab_columns
where owner = (select table_owner from user_synonyms where synonym_name = p_table_name)
and table_name = p_table_name
order by nullable asc,data_type desc,column_name asc;

begin

   begin
    select 'Y' into l_map_exists from dual
    where exists(select interface_table_name from FEM_WEBADI_TABLE_COLS_MAPS where
    interface_table_name = p_table_name);
   exception
    when NO_DATA_FOUND then null;
   end;

if (l_map_exists = 'Y') then
 delete from FEM_WEBADI_TABLE_COLS_MAPS
  where interface_table_name = p_table_name;
end if;

for intf_col_rec in CUR_INTF_COLUMNS
  loop

  l_bne_interface_col_name := 'P_PARAM' || l_param_postfix;
  l_interface_column_name := intf_col_rec.column_name;
  l_nullable := intf_col_rec.nullable;
  l_data_type := intf_col_rec.data_type;

  insert into FEM_WEBADI_TABLE_COLS_MAPS(BNE_INTERFACE_COL_NAME,INTERFACE_TABLE_NAME,INTERFACE_COLUMN_NAME,DATA_TYPE,NULLABLE)
  values(l_bne_interface_col_name,p_table_name,l_interface_column_name,l_data_type,l_nullable);

  l_param_postfix := l_param_postfix + 1;
end loop;

END POPULATE_TABLE_COLUMN_MAPS;

PROCEDURE UPLOAD_FEM_TABLE_INTERFACE(
P_TABLE_NAME VARCHAR2,
P_LEDGER_DISPLAY_CODE VARCHAR2,
P_CAL_PERIOD VARCHAR2,
P_DATASET_DISPLAY_CODE VARCHAR2,
P_SOURCE_SYSTEM_DISPLAY_CODE VARCHAR2,
P_PARAM1 IN VARCHAR2       DEFAULT NULL,
P_PARAM2 IN VARCHAR2       DEFAULT NULL,
P_PARAM3 IN VARCHAR2       DEFAULT NULL,
P_PARAM4 IN VARCHAR2       DEFAULT NULL,
P_PARAM5 IN VARCHAR2       DEFAULT NULL,
P_PARAM6 IN VARCHAR2       DEFAULT NULL,
P_PARAM7 IN VARCHAR2       DEFAULT NULL,
P_PARAM8 IN VARCHAR2       DEFAULT NULL,
P_PARAM9 IN VARCHAR2       DEFAULT NULL,
P_PARAM10 IN VARCHAR2       DEFAULT NULL,
P_PARAM11 IN VARCHAR2       DEFAULT NULL,
P_PARAM12 IN VARCHAR2       DEFAULT NULL,
P_PARAM13 IN VARCHAR2       DEFAULT NULL,
P_PARAM14 IN VARCHAR2       DEFAULT NULL,
P_PARAM15 IN VARCHAR2       DEFAULT NULL,
P_PARAM16 IN VARCHAR2       DEFAULT NULL,
P_PARAM17 IN VARCHAR2       DEFAULT NULL,
P_PARAM18 IN VARCHAR2       DEFAULT NULL,
P_PARAM19 IN VARCHAR2       DEFAULT NULL,
P_PARAM20 IN VARCHAR2       DEFAULT NULL,
P_PARAM21 IN VARCHAR2       DEFAULT NULL,
P_PARAM22 IN VARCHAR2       DEFAULT NULL,
P_PARAM23 IN VARCHAR2       DEFAULT NULL,
P_PARAM24 IN VARCHAR2       DEFAULT NULL,
P_PARAM25 IN VARCHAR2       DEFAULT NULL,
P_PARAM26 IN VARCHAR2       DEFAULT NULL,
P_PARAM27 IN VARCHAR2       DEFAULT NULL,
P_PARAM28 IN VARCHAR2       DEFAULT NULL,
P_PARAM29 IN VARCHAR2       DEFAULT NULL,
P_PARAM30 IN VARCHAR2       DEFAULT NULL,
P_PARAM31 IN VARCHAR2       DEFAULT NULL,
P_PARAM32 IN VARCHAR2       DEFAULT NULL,
P_PARAM33 IN VARCHAR2       DEFAULT NULL,
P_PARAM34 IN VARCHAR2       DEFAULT NULL,
P_PARAM35 IN VARCHAR2       DEFAULT NULL,
P_PARAM36 IN VARCHAR2       DEFAULT NULL,
P_PARAM37 IN VARCHAR2       DEFAULT NULL,
P_PARAM38 IN VARCHAR2       DEFAULT NULL,
P_PARAM39 IN VARCHAR2       DEFAULT NULL,
P_PARAM40 IN VARCHAR2       DEFAULT NULL,
P_PARAM41 IN VARCHAR2       DEFAULT NULL,
P_PARAM42 IN VARCHAR2       DEFAULT NULL,
P_PARAM43 IN VARCHAR2       DEFAULT NULL,
P_PARAM44 IN VARCHAR2       DEFAULT NULL,
P_PARAM45 IN VARCHAR2       DEFAULT NULL,
P_PARAM46 IN VARCHAR2       DEFAULT NULL,
P_PARAM47 IN VARCHAR2       DEFAULT NULL,
P_PARAM48 IN VARCHAR2       DEFAULT NULL,
P_PARAM49 IN VARCHAR2       DEFAULT NULL,
P_PARAM50 IN VARCHAR2       DEFAULT NULL,
P_PARAM51 IN VARCHAR2       DEFAULT NULL,
P_PARAM52 IN VARCHAR2       DEFAULT NULL,
P_PARAM53 IN VARCHAR2       DEFAULT NULL,
P_PARAM54 IN VARCHAR2       DEFAULT NULL,
P_PARAM55 IN VARCHAR2       DEFAULT NULL,
P_PARAM56 IN VARCHAR2       DEFAULT NULL,
P_PARAM57 IN VARCHAR2       DEFAULT NULL,
P_PARAM58 IN VARCHAR2       DEFAULT NULL,
P_PARAM59 IN VARCHAR2       DEFAULT NULL,
P_PARAM60 IN VARCHAR2       DEFAULT NULL,
P_PARAM61 IN VARCHAR2       DEFAULT NULL,
P_PARAM62 IN VARCHAR2       DEFAULT NULL,
P_PARAM63 IN VARCHAR2       DEFAULT NULL,
P_PARAM64 IN VARCHAR2       DEFAULT NULL,
P_PARAM65 IN VARCHAR2       DEFAULT NULL,
P_PARAM66 IN VARCHAR2       DEFAULT NULL,
P_PARAM67 IN VARCHAR2       DEFAULT NULL,
P_PARAM68 IN VARCHAR2       DEFAULT NULL,
P_PARAM69 IN VARCHAR2       DEFAULT NULL,
P_PARAM70 IN VARCHAR2       DEFAULT NULL,
P_PARAM71 IN VARCHAR2       DEFAULT NULL,
P_PARAM72 IN VARCHAR2       DEFAULT NULL,
P_PARAM73 IN VARCHAR2       DEFAULT NULL,
P_PARAM74 IN VARCHAR2       DEFAULT NULL,
P_PARAM75 IN VARCHAR2       DEFAULT NULL,
P_PARAM76 IN VARCHAR2       DEFAULT NULL,
P_PARAM77 IN VARCHAR2       DEFAULT NULL,
P_PARAM78 IN VARCHAR2       DEFAULT NULL,
P_PARAM79 IN VARCHAR2       DEFAULT NULL,
P_PARAM80 IN VARCHAR2       DEFAULT NULL,
P_PARAM81 IN VARCHAR2       DEFAULT NULL,
P_PARAM82 IN VARCHAR2       DEFAULT NULL,
P_PARAM83 IN VARCHAR2       DEFAULT NULL,
P_PARAM84 IN VARCHAR2       DEFAULT NULL,
P_PARAM85 IN VARCHAR2       DEFAULT NULL,
P_PARAM86 IN VARCHAR2       DEFAULT NULL,
P_PARAM87 IN VARCHAR2       DEFAULT NULL,
P_PARAM88 IN VARCHAR2       DEFAULT NULL,
P_PARAM89 IN VARCHAR2       DEFAULT NULL,
P_PARAM90 IN VARCHAR2       DEFAULT NULL,
P_PARAM91 IN VARCHAR2       DEFAULT NULL,
P_PARAM92 IN VARCHAR2       DEFAULT NULL,
P_PARAM93 IN VARCHAR2       DEFAULT NULL,
P_PARAM94 IN VARCHAR2       DEFAULT NULL,
P_PARAM95 IN VARCHAR2       DEFAULT NULL,
P_PARAM96 IN VARCHAR2       DEFAULT NULL,
P_PARAM97 IN VARCHAR2       DEFAULT NULL,
P_PARAM98 IN VARCHAR2       DEFAULT NULL,
P_PARAM99 IN VARCHAR2       DEFAULT NULL,
P_PARAM100 IN VARCHAR2       DEFAULT NULL,
P_PARAM101 IN VARCHAR2       DEFAULT NULL,
P_PARAM102 IN VARCHAR2       DEFAULT NULL,
P_PARAM103 IN VARCHAR2       DEFAULT NULL,
P_PARAM104 IN VARCHAR2       DEFAULT NULL,
P_PARAM105 IN VARCHAR2       DEFAULT NULL,
P_PARAM106 IN VARCHAR2       DEFAULT NULL,
P_PARAM107 IN VARCHAR2       DEFAULT NULL,
P_PARAM108 IN VARCHAR2       DEFAULT NULL,
P_PARAM109 IN VARCHAR2       DEFAULT NULL,
P_PARAM110 IN VARCHAR2       DEFAULT NULL,
P_PARAM111 IN VARCHAR2       DEFAULT NULL,
P_PARAM112 IN VARCHAR2       DEFAULT NULL,
P_PARAM113 IN VARCHAR2       DEFAULT NULL,
P_PARAM114 IN VARCHAR2       DEFAULT NULL,
P_PARAM115 IN VARCHAR2       DEFAULT NULL,
P_PARAM116 IN VARCHAR2       DEFAULT NULL,
P_PARAM117 IN VARCHAR2       DEFAULT NULL,
P_PARAM118 IN VARCHAR2       DEFAULT NULL,
P_PARAM119 IN VARCHAR2       DEFAULT NULL,
P_PARAM120 IN VARCHAR2       DEFAULT NULL,
P_PARAM121 IN VARCHAR2       DEFAULT NULL,
P_PARAM122 IN VARCHAR2       DEFAULT NULL,
P_PARAM123 IN VARCHAR2       DEFAULT NULL,
P_PARAM124 IN VARCHAR2       DEFAULT NULL,
P_PARAM125 IN VARCHAR2       DEFAULT NULL,
P_PARAM126 IN VARCHAR2       DEFAULT NULL,
P_PARAM127 IN VARCHAR2       DEFAULT NULL,
P_PARAM128 IN VARCHAR2       DEFAULT NULL,
P_PARAM129 IN VARCHAR2       DEFAULT NULL,
P_PARAM130 IN VARCHAR2       DEFAULT NULL,
P_PARAM131 IN VARCHAR2       DEFAULT NULL,
P_PARAM132 IN VARCHAR2       DEFAULT NULL,
P_PARAM133 IN VARCHAR2       DEFAULT NULL,
P_PARAM134 IN VARCHAR2       DEFAULT NULL,
P_PARAM135 IN VARCHAR2       DEFAULT NULL,
P_PARAM136 IN VARCHAR2       DEFAULT NULL,
P_PARAM137 IN VARCHAR2       DEFAULT NULL,
P_PARAM138 IN VARCHAR2       DEFAULT NULL,
P_PARAM139 IN VARCHAR2       DEFAULT NULL,
P_PARAM140 IN VARCHAR2       DEFAULT NULL,
P_PARAM141 IN VARCHAR2       DEFAULT NULL,
P_PARAM142 IN VARCHAR2       DEFAULT NULL,
P_PARAM143 IN VARCHAR2       DEFAULT NULL,
P_PARAM144 IN VARCHAR2       DEFAULT NULL,
P_PARAM145 IN VARCHAR2       DEFAULT NULL,
P_PARAM146 IN VARCHAR2       DEFAULT NULL,
P_PARAM147 IN VARCHAR2       DEFAULT NULL,
P_PARAM148 IN VARCHAR2       DEFAULT NULL,
P_PARAM149 IN VARCHAR2       DEFAULT NULL,
P_PARAM150 IN VARCHAR2       DEFAULT NULL,
P_PARAM151 IN VARCHAR2       DEFAULT NULL,
P_PARAM152 IN VARCHAR2       DEFAULT NULL,
P_PARAM153 IN VARCHAR2       DEFAULT NULL,
P_PARAM154 IN VARCHAR2       DEFAULT NULL,
P_PARAM155 IN VARCHAR2       DEFAULT NULL,
P_PARAM156 IN VARCHAR2       DEFAULT NULL,
P_PARAM157 IN VARCHAR2       DEFAULT NULL,
P_PARAM158 IN VARCHAR2       DEFAULT NULL,
P_PARAM159 IN VARCHAR2       DEFAULT NULL,
P_PARAM160 IN VARCHAR2       DEFAULT NULL,
P_PARAM161 IN VARCHAR2       DEFAULT NULL,
P_PARAM162 IN VARCHAR2       DEFAULT NULL,
P_PARAM163 IN VARCHAR2       DEFAULT NULL,
P_PARAM164 IN VARCHAR2       DEFAULT NULL,
P_PARAM165 IN VARCHAR2       DEFAULT NULL,
P_PARAM166 IN VARCHAR2       DEFAULT NULL,
P_PARAM167 IN VARCHAR2       DEFAULT NULL,
P_PARAM168 IN VARCHAR2       DEFAULT NULL,
P_PARAM169 IN VARCHAR2       DEFAULT NULL,
P_PARAM170 IN VARCHAR2       DEFAULT NULL,
P_PARAM171 IN VARCHAR2       DEFAULT NULL,
P_PARAM172 IN VARCHAR2       DEFAULT NULL,
P_PARAM173 IN VARCHAR2       DEFAULT NULL,
P_PARAM174 IN VARCHAR2       DEFAULT NULL,
P_PARAM175 IN VARCHAR2       DEFAULT NULL,
P_PARAM176 IN VARCHAR2       DEFAULT NULL,
P_PARAM177 IN VARCHAR2       DEFAULT NULL,
P_PARAM178 IN VARCHAR2       DEFAULT NULL,
P_PARAM179 IN VARCHAR2       DEFAULT NULL,
P_PARAM180 IN VARCHAR2       DEFAULT NULL,
P_PARAM181 IN VARCHAR2       DEFAULT NULL,
P_PARAM182 IN VARCHAR2       DEFAULT NULL,
P_PARAM183 IN VARCHAR2       DEFAULT NULL,
P_PARAM184 IN VARCHAR2       DEFAULT NULL,
P_PARAM185 IN VARCHAR2       DEFAULT NULL,
P_PARAM186 IN VARCHAR2       DEFAULT NULL,
P_PARAM187 IN VARCHAR2       DEFAULT NULL,
P_PARAM188 IN VARCHAR2       DEFAULT NULL,
P_PARAM189 IN VARCHAR2       DEFAULT NULL,
P_PARAM190 IN VARCHAR2       DEFAULT NULL,
P_PARAM191 IN VARCHAR2       DEFAULT NULL,
P_PARAM192 IN VARCHAR2       DEFAULT NULL,
P_PARAM193 IN VARCHAR2       DEFAULT NULL,
P_PARAM194 IN VARCHAR2       DEFAULT NULL,
P_PARAM195 IN VARCHAR2       DEFAULT NULL,
P_PARAM196 IN VARCHAR2       DEFAULT NULL,
P_PARAM197 IN VARCHAR2       DEFAULT NULL,
P_PARAM198 IN VARCHAR2       DEFAULT NULL,
P_PARAM199 IN VARCHAR2       DEFAULT NULL,
P_PARAM200 IN VARCHAR2       DEFAULT NULL,
P_PARAM201 IN VARCHAR2       DEFAULT NULL,
P_PARAM202 IN VARCHAR2       DEFAULT NULL,
P_PARAM203 IN VARCHAR2       DEFAULT NULL,
P_PARAM204 IN VARCHAR2       DEFAULT NULL,
P_PARAM205 IN VARCHAR2       DEFAULT NULL,
P_PARAM206 IN VARCHAR2       DEFAULT NULL,
P_PARAM207 IN VARCHAR2       DEFAULT NULL,
P_PARAM208 IN VARCHAR2       DEFAULT NULL,
P_PARAM209 IN VARCHAR2       DEFAULT NULL,
P_PARAM210 IN VARCHAR2       DEFAULT NULL,
P_PARAM211 IN VARCHAR2       DEFAULT NULL,
P_PARAM212 IN VARCHAR2       DEFAULT NULL,
P_PARAM213 IN VARCHAR2       DEFAULT NULL,
P_PARAM214 IN VARCHAR2       DEFAULT NULL,
P_PARAM215 IN VARCHAR2       DEFAULT NULL,
P_PARAM216 IN VARCHAR2       DEFAULT NULL,
P_PARAM217 IN VARCHAR2       DEFAULT NULL,
P_PARAM218 IN VARCHAR2       DEFAULT NULL,
P_PARAM219 IN VARCHAR2       DEFAULT NULL,
P_PARAM220 IN VARCHAR2       DEFAULT NULL,
P_PARAM221 IN VARCHAR2       DEFAULT NULL,
P_PARAM222 IN VARCHAR2       DEFAULT NULL,
P_PARAM223 IN VARCHAR2       DEFAULT NULL,
P_PARAM224 IN VARCHAR2       DEFAULT NULL,
P_PARAM225 IN VARCHAR2       DEFAULT NULL,
P_PARAM226 IN VARCHAR2       DEFAULT NULL,
P_PARAM227 IN VARCHAR2       DEFAULT NULL,
P_PARAM228 IN VARCHAR2       DEFAULT NULL,
P_PARAM229 IN VARCHAR2       DEFAULT NULL,
P_PARAM230 IN VARCHAR2       DEFAULT NULL,
P_PARAM231 IN VARCHAR2       DEFAULT NULL,
P_PARAM232 IN VARCHAR2       DEFAULT NULL,
P_PARAM233 IN VARCHAR2       DEFAULT NULL,
P_PARAM234 IN VARCHAR2       DEFAULT NULL,
P_PARAM235 IN VARCHAR2       DEFAULT NULL,
P_PARAM236 IN VARCHAR2       DEFAULT NULL,
P_PARAM237 IN VARCHAR2       DEFAULT NULL,
P_PARAM238 IN VARCHAR2       DEFAULT NULL,
P_PARAM239 IN VARCHAR2       DEFAULT NULL,
P_PARAM240 IN VARCHAR2       DEFAULT NULL,
P_PARAM241 IN VARCHAR2       DEFAULT NULL,
P_PARAM242 IN VARCHAR2       DEFAULT NULL,
P_PARAM243 IN VARCHAR2       DEFAULT NULL,
P_PARAM244 IN VARCHAR2       DEFAULT NULL,
P_PARAM245 IN VARCHAR2       DEFAULT NULL,
P_PARAM246 IN VARCHAR2       DEFAULT NULL,
P_PARAM247 IN VARCHAR2       DEFAULT NULL,
P_PARAM248 IN VARCHAR2       DEFAULT NULL,
P_PARAM249 IN VARCHAR2       DEFAULT NULL,
P_PARAM250 IN VARCHAR2       DEFAULT NULL,
P_PARAM251 IN VARCHAR2       DEFAULT NULL,
P_PARAM252 IN VARCHAR2       DEFAULT NULL,
P_PARAM253 IN VARCHAR2       DEFAULT NULL,
P_PARAM254 IN VARCHAR2       DEFAULT NULL,
P_PARAM255 IN VARCHAR2       DEFAULT NULL,
P_PARAM256 IN VARCHAR2       DEFAULT NULL,
P_PARAM257 IN VARCHAR2       DEFAULT NULL,
P_PARAM258 IN VARCHAR2       DEFAULT NULL,
P_PARAM259 IN VARCHAR2       DEFAULT NULL,
P_PARAM260 IN VARCHAR2       DEFAULT NULL,
P_PARAM261 IN VARCHAR2       DEFAULT NULL,
P_PARAM262 IN VARCHAR2       DEFAULT NULL,
P_PARAM263 IN VARCHAR2       DEFAULT NULL,
P_PARAM264 IN VARCHAR2       DEFAULT NULL,
P_PARAM265 IN VARCHAR2       DEFAULT NULL,
P_PARAM266 IN VARCHAR2       DEFAULT NULL,
P_PARAM267 IN VARCHAR2       DEFAULT NULL,
P_PARAM268 IN VARCHAR2       DEFAULT NULL,
P_PARAM269 IN VARCHAR2       DEFAULT NULL,
P_PARAM270 IN VARCHAR2       DEFAULT NULL,
P_PARAM271 IN VARCHAR2       DEFAULT NULL,
P_PARAM272 IN VARCHAR2       DEFAULT NULL,
P_PARAM273 IN VARCHAR2       DEFAULT NULL,
P_PARAM274 IN VARCHAR2       DEFAULT NULL,
P_PARAM275 IN VARCHAR2       DEFAULT NULL,
P_PARAM276 IN VARCHAR2       DEFAULT NULL,
P_PARAM277 IN VARCHAR2       DEFAULT NULL,
P_PARAM278 IN VARCHAR2       DEFAULT NULL,
P_PARAM279 IN VARCHAR2       DEFAULT NULL,
P_PARAM280 IN VARCHAR2       DEFAULT NULL,
P_PARAM281 IN VARCHAR2       DEFAULT NULL,
P_PARAM282 IN VARCHAR2       DEFAULT NULL,
P_PARAM283 IN VARCHAR2       DEFAULT NULL,
P_PARAM284 IN VARCHAR2       DEFAULT NULL,
P_PARAM285 IN VARCHAR2       DEFAULT NULL,
P_PARAM286 IN VARCHAR2       DEFAULT NULL,
P_PARAM287 IN VARCHAR2       DEFAULT NULL,
P_PARAM288 IN VARCHAR2       DEFAULT NULL,
P_PARAM289 IN VARCHAR2       DEFAULT NULL,
P_PARAM290 IN VARCHAR2       DEFAULT NULL,
P_PARAM291 IN VARCHAR2       DEFAULT NULL,
P_PARAM292 IN VARCHAR2       DEFAULT NULL,
P_PARAM293 IN VARCHAR2       DEFAULT NULL,
P_PARAM294 IN VARCHAR2       DEFAULT NULL,
P_PARAM295 IN VARCHAR2       DEFAULT NULL,
P_PARAM296 IN VARCHAR2       DEFAULT NULL,
P_PARAM297 IN VARCHAR2       DEFAULT NULL,
P_PARAM298 IN VARCHAR2       DEFAULT NULL,
P_PARAM299 IN VARCHAR2       DEFAULT NULL,
P_PARAM300 IN VARCHAR2  DEFAULT NULL)
IS

l_interface_table_name varchar2(50);
l_insert_query long;
l_query_values long;
l_query_columns long;
l_dataset_display_code varchar2(100);
l_cal_period_number number;
l_cal_period_end_date date;
l_cal_grp_display_code varchar2(50);
l_interface_code varchar2(50);
l_count number := 1;
l_param_number number;
l_column_value varchar2(500);
l_table_name varchar2(30);
e_no_table exception;
l_canonical_format varchar2(20);
l_end_date varchar2(20);
l_adi_date_format varchar2(20);
INVALID_NUMBER exception;
pragma exception_init(INVALID_NUMBER,-01722);
l_column_name  varchar2(100);
l_valid_number number;

TYPE l_param_value IS    RECORD
    ( VALUE                      VARCHAR2(500));

  TYPE l_param_values_typ IS TABLE OF l_param_value
          INDEX BY BINARY_INTEGER;

  l_param_values_tbl           l_param_values_typ;

begin

if(p_table_name is null) then
raise e_no_table;
end if;

--------------------------------- Inserting PARAM values in a PLSQL TABLE ----------------------

l_param_values_tbl(1).VALUE :=  P_PARAM1   ;
l_param_values_tbl(2).VALUE :=  P_PARAM2   ;
l_param_values_tbl(3).VALUE :=  P_PARAM3   ;
l_param_values_tbl(4).VALUE :=  P_PARAM4   ;
l_param_values_tbl(5).VALUE :=  P_PARAM5   ;
l_param_values_tbl(6).VALUE :=  P_PARAM6   ;
l_param_values_tbl(7).VALUE :=  P_PARAM7   ;
l_param_values_tbl(8).VALUE :=  P_PARAM8   ;
l_param_values_tbl(9).VALUE :=  P_PARAM9   ;
l_param_values_tbl(10).VALUE := P_PARAM10  ;
l_param_values_tbl(11).VALUE := P_PARAM11  ;
l_param_values_tbl(12).VALUE := P_PARAM12  ;
l_param_values_tbl(13).VALUE := P_PARAM13  ;
l_param_values_tbl(14).VALUE := P_PARAM14  ;
l_param_values_tbl(15).VALUE := P_PARAM15  ;
l_param_values_tbl(16).VALUE := P_PARAM16  ;
l_param_values_tbl(17).VALUE := P_PARAM17  ;
l_param_values_tbl(18).VALUE := P_PARAM18  ;
l_param_values_tbl(19).VALUE := P_PARAM19  ;
l_param_values_tbl(20).VALUE := P_PARAM20  ;
l_param_values_tbl(21).VALUE := P_PARAM21  ;
l_param_values_tbl(22).VALUE := P_PARAM22  ;
l_param_values_tbl(23).VALUE := P_PARAM23  ;
l_param_values_tbl(24).VALUE := P_PARAM24  ;
l_param_values_tbl(25).VALUE := P_PARAM25  ;
l_param_values_tbl(26).VALUE := P_PARAM26  ;
l_param_values_tbl(27).VALUE := P_PARAM27  ;
l_param_values_tbl(28).VALUE := P_PARAM28  ;
l_param_values_tbl(29).VALUE := P_PARAM29  ;
l_param_values_tbl(30).VALUE := P_PARAM30  ;
l_param_values_tbl(31).VALUE := P_PARAM31  ;
l_param_values_tbl(32).VALUE := P_PARAM32  ;
l_param_values_tbl(33).VALUE := P_PARAM33  ;
l_param_values_tbl(34).VALUE := P_PARAM34  ;
l_param_values_tbl(35).VALUE := P_PARAM35  ;
l_param_values_tbl(36).VALUE := P_PARAM36  ;
l_param_values_tbl(37).VALUE := P_PARAM37  ;
l_param_values_tbl(38).VALUE := P_PARAM38  ;
l_param_values_tbl(39).VALUE := P_PARAM39  ;
l_param_values_tbl(40).VALUE := P_PARAM40  ;
l_param_values_tbl(41).VALUE := P_PARAM41  ;
l_param_values_tbl(42).VALUE := P_PARAM42  ;
l_param_values_tbl(43).VALUE := P_PARAM43  ;
l_param_values_tbl(44).VALUE := P_PARAM44  ;
l_param_values_tbl(45).VALUE := P_PARAM45  ;
l_param_values_tbl(46).VALUE := P_PARAM46  ;
l_param_values_tbl(47).VALUE := P_PARAM47  ;
l_param_values_tbl(48).VALUE := P_PARAM48  ;
l_param_values_tbl(49).VALUE := P_PARAM49  ;
l_param_values_tbl(50).VALUE := P_PARAM50  ;
l_param_values_tbl(51).VALUE := P_PARAM51  ;
l_param_values_tbl(52).VALUE := P_PARAM52  ;
l_param_values_tbl(53).VALUE := P_PARAM53  ;
l_param_values_tbl(54).VALUE := P_PARAM54  ;
l_param_values_tbl(55).VALUE := P_PARAM55  ;
l_param_values_tbl(56).VALUE := P_PARAM56  ;
l_param_values_tbl(57).VALUE := P_PARAM57  ;
l_param_values_tbl(58).VALUE := P_PARAM58  ;
l_param_values_tbl(59).VALUE := P_PARAM59  ;
l_param_values_tbl(60).VALUE := P_PARAM60  ;
l_param_values_tbl(61).VALUE := P_PARAM61  ;
l_param_values_tbl(62).VALUE := P_PARAM62  ;
l_param_values_tbl(63).VALUE := P_PARAM63  ;
l_param_values_tbl(64).VALUE := P_PARAM64  ;
l_param_values_tbl(65).VALUE := P_PARAM65  ;
l_param_values_tbl(66).VALUE := P_PARAM66  ;
l_param_values_tbl(67).VALUE := P_PARAM67  ;
l_param_values_tbl(68).VALUE := P_PARAM68  ;
l_param_values_tbl(69).VALUE := P_PARAM69  ;
l_param_values_tbl(70).VALUE := P_PARAM70  ;
l_param_values_tbl(71).VALUE := P_PARAM71  ;
l_param_values_tbl(72).VALUE := P_PARAM72  ;
l_param_values_tbl(73).VALUE := P_PARAM73  ;
l_param_values_tbl(74).VALUE := P_PARAM74  ;
l_param_values_tbl(75).VALUE := P_PARAM75  ;
l_param_values_tbl(76).VALUE := P_PARAM76  ;
l_param_values_tbl(77).VALUE := P_PARAM77  ;
l_param_values_tbl(78).VALUE := P_PARAM78  ;
l_param_values_tbl(79).VALUE := P_PARAM79  ;
l_param_values_tbl(80).VALUE := P_PARAM80  ;
l_param_values_tbl(81).VALUE := P_PARAM81  ;
l_param_values_tbl(82).VALUE := P_PARAM82  ;
l_param_values_tbl(83).VALUE := P_PARAM83  ;
l_param_values_tbl(84).VALUE := P_PARAM84  ;
l_param_values_tbl(85).VALUE := P_PARAM85  ;
l_param_values_tbl(86).VALUE := P_PARAM86  ;
l_param_values_tbl(87).VALUE := P_PARAM87  ;
l_param_values_tbl(88).VALUE := P_PARAM88  ;
l_param_values_tbl(89).VALUE := P_PARAM89  ;
l_param_values_tbl(90).VALUE := P_PARAM90  ;
l_param_values_tbl(91).VALUE := P_PARAM91  ;
l_param_values_tbl(92).VALUE := P_PARAM92  ;
l_param_values_tbl(93).VALUE := P_PARAM93  ;
l_param_values_tbl(94).VALUE := P_PARAM94  ;
l_param_values_tbl(95).VALUE := P_PARAM95  ;
l_param_values_tbl(96).VALUE := P_PARAM96  ;
l_param_values_tbl(97).VALUE := P_PARAM97  ;
l_param_values_tbl(98).VALUE := P_PARAM98  ;
l_param_values_tbl(99).VALUE := P_PARAM99  ;
l_param_values_tbl(100).VALUE :=P_PARAM100 ;
l_param_values_tbl(101).VALUE :=P_PARAM101 ;
l_param_values_tbl(102).VALUE :=P_PARAM102 ;
l_param_values_tbl(103).VALUE :=P_PARAM103 ;
l_param_values_tbl(104).VALUE :=P_PARAM104 ;
l_param_values_tbl(105).VALUE :=P_PARAM105 ;
l_param_values_tbl(106).VALUE :=P_PARAM106 ;
l_param_values_tbl(107).VALUE :=P_PARAM107 ;
l_param_values_tbl(108).VALUE :=P_PARAM108 ;
l_param_values_tbl(109).VALUE :=P_PARAM109 ;
l_param_values_tbl(110).VALUE :=P_PARAM110 ;
l_param_values_tbl(111).VALUE :=P_PARAM111 ;
l_param_values_tbl(112).VALUE :=P_PARAM112 ;
l_param_values_tbl(113).VALUE :=P_PARAM113 ;
l_param_values_tbl(114).VALUE :=P_PARAM114 ;
l_param_values_tbl(115).VALUE :=P_PARAM115 ;
l_param_values_tbl(116).VALUE :=P_PARAM116 ;
l_param_values_tbl(117).VALUE :=P_PARAM117 ;
l_param_values_tbl(118).VALUE :=P_PARAM118 ;
l_param_values_tbl(119).VALUE :=P_PARAM119 ;
l_param_values_tbl(120).VALUE :=P_PARAM120 ;
l_param_values_tbl(121).VALUE :=P_PARAM121 ;
l_param_values_tbl(122).VALUE :=P_PARAM122 ;
l_param_values_tbl(123).VALUE :=P_PARAM123 ;
l_param_values_tbl(124).VALUE :=P_PARAM124 ;
l_param_values_tbl(125).VALUE :=P_PARAM125 ;
l_param_values_tbl(126).VALUE :=P_PARAM126 ;
l_param_values_tbl(127).VALUE :=P_PARAM127 ;
l_param_values_tbl(128).VALUE :=P_PARAM128 ;
l_param_values_tbl(129).VALUE :=P_PARAM129 ;
l_param_values_tbl(130).VALUE :=P_PARAM130 ;
l_param_values_tbl(131).VALUE :=P_PARAM131 ;
l_param_values_tbl(132).VALUE :=P_PARAM132 ;
l_param_values_tbl(133).VALUE :=P_PARAM133 ;
l_param_values_tbl(134).VALUE :=P_PARAM134 ;
l_param_values_tbl(135).VALUE :=P_PARAM135 ;
l_param_values_tbl(136).VALUE :=P_PARAM136 ;
l_param_values_tbl(137).VALUE :=P_PARAM137 ;
l_param_values_tbl(138).VALUE :=P_PARAM138 ;
l_param_values_tbl(139).VALUE :=P_PARAM139 ;
l_param_values_tbl(140).VALUE :=P_PARAM140 ;
l_param_values_tbl(141).VALUE :=P_PARAM141 ;
l_param_values_tbl(142).VALUE :=P_PARAM142 ;
l_param_values_tbl(143).VALUE :=P_PARAM143 ;
l_param_values_tbl(144).VALUE :=P_PARAM144 ;
l_param_values_tbl(145).VALUE :=P_PARAM145 ;
l_param_values_tbl(146).VALUE :=P_PARAM146 ;
l_param_values_tbl(147).VALUE :=P_PARAM147 ;
l_param_values_tbl(148).VALUE :=P_PARAM148 ;
l_param_values_tbl(149).VALUE :=P_PARAM149 ;
l_param_values_tbl(150).VALUE :=P_PARAM150 ;
l_param_values_tbl(151).VALUE :=P_PARAM151 ;
l_param_values_tbl(152).VALUE :=P_PARAM152 ;
l_param_values_tbl(153).VALUE :=P_PARAM153 ;
l_param_values_tbl(154).VALUE :=P_PARAM154 ;
l_param_values_tbl(155).VALUE :=P_PARAM155 ;
l_param_values_tbl(156).VALUE :=P_PARAM156 ;
l_param_values_tbl(157).VALUE :=P_PARAM157 ;
l_param_values_tbl(158).VALUE :=P_PARAM158 ;
l_param_values_tbl(159).VALUE :=P_PARAM159 ;
l_param_values_tbl(160).VALUE :=P_PARAM160 ;
l_param_values_tbl(161).VALUE :=P_PARAM161 ;
l_param_values_tbl(162).VALUE :=P_PARAM162 ;
l_param_values_tbl(163).VALUE :=P_PARAM163 ;
l_param_values_tbl(164).VALUE :=P_PARAM164 ;
l_param_values_tbl(165).VALUE :=P_PARAM165 ;
l_param_values_tbl(166).VALUE :=P_PARAM166 ;
l_param_values_tbl(167).VALUE :=P_PARAM167 ;
l_param_values_tbl(168).VALUE :=P_PARAM168 ;
l_param_values_tbl(169).VALUE :=P_PARAM169 ;
l_param_values_tbl(170).VALUE :=P_PARAM170 ;
l_param_values_tbl(171).VALUE :=P_PARAM171 ;
l_param_values_tbl(172).VALUE :=P_PARAM172 ;
l_param_values_tbl(173).VALUE :=P_PARAM173 ;
l_param_values_tbl(174).VALUE :=P_PARAM174 ;
l_param_values_tbl(175).VALUE :=P_PARAM175 ;
l_param_values_tbl(176).VALUE :=P_PARAM176 ;
l_param_values_tbl(177).VALUE :=P_PARAM177 ;
l_param_values_tbl(178).VALUE :=P_PARAM178 ;
l_param_values_tbl(179).VALUE :=P_PARAM179 ;
l_param_values_tbl(180).VALUE :=P_PARAM180 ;
l_param_values_tbl(181).VALUE :=P_PARAM181 ;
l_param_values_tbl(182).VALUE :=P_PARAM182 ;
l_param_values_tbl(183).VALUE :=P_PARAM183 ;
l_param_values_tbl(184).VALUE :=P_PARAM184 ;
l_param_values_tbl(185).VALUE :=P_PARAM185 ;
l_param_values_tbl(186).VALUE :=P_PARAM186 ;
l_param_values_tbl(187).VALUE :=P_PARAM187 ;
l_param_values_tbl(188).VALUE :=P_PARAM188 ;
l_param_values_tbl(189).VALUE :=P_PARAM189 ;
l_param_values_tbl(190).VALUE :=P_PARAM190 ;
l_param_values_tbl(191).VALUE :=P_PARAM191 ;
l_param_values_tbl(192).VALUE :=P_PARAM192 ;
l_param_values_tbl(193).VALUE :=P_PARAM193 ;
l_param_values_tbl(194).VALUE :=P_PARAM194 ;
l_param_values_tbl(195).VALUE :=P_PARAM195 ;
l_param_values_tbl(196).VALUE :=P_PARAM196 ;
l_param_values_tbl(197).VALUE :=P_PARAM197 ;
l_param_values_tbl(198).VALUE :=P_PARAM198 ;
l_param_values_tbl(199).VALUE :=P_PARAM199 ;
l_param_values_tbl(200).VALUE :=P_PARAM200 ;
l_param_values_tbl(201).VALUE :=P_PARAM201 ;
l_param_values_tbl(202).VALUE :=P_PARAM202 ;
l_param_values_tbl(203).VALUE :=P_PARAM203 ;
l_param_values_tbl(204).VALUE :=P_PARAM204 ;
l_param_values_tbl(205).VALUE :=P_PARAM205 ;
l_param_values_tbl(206).VALUE :=P_PARAM206 ;
l_param_values_tbl(207).VALUE :=P_PARAM207 ;
l_param_values_tbl(208).VALUE :=P_PARAM208 ;
l_param_values_tbl(209).VALUE :=P_PARAM209 ;
l_param_values_tbl(210).VALUE :=P_PARAM210 ;
l_param_values_tbl(211).VALUE :=P_PARAM211 ;
l_param_values_tbl(212).VALUE :=P_PARAM212 ;
l_param_values_tbl(213).VALUE :=P_PARAM213 ;
l_param_values_tbl(214).VALUE :=P_PARAM214 ;
l_param_values_tbl(215).VALUE :=P_PARAM215 ;
l_param_values_tbl(216).VALUE :=P_PARAM216 ;
l_param_values_tbl(217).VALUE :=P_PARAM217 ;
l_param_values_tbl(218).VALUE :=P_PARAM218 ;
l_param_values_tbl(219).VALUE :=P_PARAM219 ;
l_param_values_tbl(220).VALUE :=P_PARAM220 ;
l_param_values_tbl(221).VALUE :=P_PARAM221 ;
l_param_values_tbl(222).VALUE :=P_PARAM222 ;
l_param_values_tbl(223).VALUE :=P_PARAM223 ;
l_param_values_tbl(224).VALUE :=P_PARAM224 ;
l_param_values_tbl(225).VALUE :=P_PARAM225 ;
l_param_values_tbl(226).VALUE :=P_PARAM226 ;
l_param_values_tbl(227).VALUE :=P_PARAM227 ;
l_param_values_tbl(228).VALUE :=P_PARAM228 ;
l_param_values_tbl(229).VALUE :=P_PARAM229 ;
l_param_values_tbl(230).VALUE :=P_PARAM230 ;
l_param_values_tbl(231).VALUE :=P_PARAM231 ;
l_param_values_tbl(232).VALUE :=P_PARAM232 ;
l_param_values_tbl(233).VALUE :=P_PARAM233 ;
l_param_values_tbl(234).VALUE :=P_PARAM234 ;
l_param_values_tbl(235).VALUE :=P_PARAM235 ;
l_param_values_tbl(236).VALUE :=P_PARAM236 ;
l_param_values_tbl(237).VALUE :=P_PARAM237 ;
l_param_values_tbl(238).VALUE :=P_PARAM238 ;
l_param_values_tbl(239).VALUE :=P_PARAM239 ;
l_param_values_tbl(240).VALUE :=P_PARAM240 ;
l_param_values_tbl(241).VALUE :=P_PARAM241 ;
l_param_values_tbl(242).VALUE :=P_PARAM242 ;
l_param_values_tbl(243).VALUE :=P_PARAM243 ;
l_param_values_tbl(244).VALUE :=P_PARAM244 ;
l_param_values_tbl(245).VALUE :=P_PARAM245 ;
l_param_values_tbl(246).VALUE :=P_PARAM246 ;
l_param_values_tbl(247).VALUE :=P_PARAM247 ;
l_param_values_tbl(248).VALUE :=P_PARAM248 ;
l_param_values_tbl(249).VALUE :=P_PARAM249 ;
l_param_values_tbl(250).VALUE :=P_PARAM250 ;
l_param_values_tbl(251).VALUE :=P_PARAM251 ;
l_param_values_tbl(252).VALUE :=P_PARAM252 ;
l_param_values_tbl(253).VALUE :=P_PARAM253 ;
l_param_values_tbl(254).VALUE :=P_PARAM254 ;
l_param_values_tbl(255).VALUE :=P_PARAM255 ;
l_param_values_tbl(256).VALUE :=P_PARAM256 ;
l_param_values_tbl(257).VALUE :=P_PARAM257 ;
l_param_values_tbl(258).VALUE :=P_PARAM258 ;
l_param_values_tbl(259).VALUE :=P_PARAM259 ;
l_param_values_tbl(260).VALUE :=P_PARAM260 ;
l_param_values_tbl(261).VALUE :=P_PARAM261 ;
l_param_values_tbl(262).VALUE :=P_PARAM262 ;
l_param_values_tbl(263).VALUE :=P_PARAM263 ;
l_param_values_tbl(264).VALUE :=P_PARAM264 ;
l_param_values_tbl(265).VALUE :=P_PARAM265 ;
l_param_values_tbl(266).VALUE :=P_PARAM266 ;
l_param_values_tbl(267).VALUE :=P_PARAM267 ;
l_param_values_tbl(268).VALUE :=P_PARAM268 ;
l_param_values_tbl(269).VALUE :=P_PARAM269 ;
l_param_values_tbl(270).VALUE :=P_PARAM270 ;
l_param_values_tbl(271).VALUE :=P_PARAM271 ;
l_param_values_tbl(272).VALUE :=P_PARAM272 ;
l_param_values_tbl(273).VALUE :=P_PARAM273 ;
l_param_values_tbl(274).VALUE :=P_PARAM274 ;
l_param_values_tbl(275).VALUE :=P_PARAM275 ;
l_param_values_tbl(276).VALUE :=P_PARAM276 ;
l_param_values_tbl(277).VALUE :=P_PARAM277 ;
l_param_values_tbl(278).VALUE :=P_PARAM278 ;
l_param_values_tbl(279).VALUE :=P_PARAM279 ;
l_param_values_tbl(280).VALUE :=P_PARAM280 ;
l_param_values_tbl(281).VALUE :=P_PARAM281 ;
l_param_values_tbl(282).VALUE :=P_PARAM282 ;
l_param_values_tbl(283).VALUE :=P_PARAM283 ;
l_param_values_tbl(284).VALUE :=P_PARAM284 ;
l_param_values_tbl(285).VALUE :=P_PARAM285 ;
l_param_values_tbl(286).VALUE :=P_PARAM286 ;
l_param_values_tbl(287).VALUE :=P_PARAM287 ;
l_param_values_tbl(288).VALUE :=P_PARAM288 ;
l_param_values_tbl(289).VALUE :=P_PARAM289 ;
l_param_values_tbl(290).VALUE :=P_PARAM290 ;
l_param_values_tbl(291).VALUE :=P_PARAM291 ;
l_param_values_tbl(292).VALUE :=P_PARAM292 ;
l_param_values_tbl(293).VALUE :=P_PARAM293 ;
l_param_values_tbl(294).VALUE :=P_PARAM294 ;
l_param_values_tbl(295).VALUE :=P_PARAM295 ;
l_param_values_tbl(296).VALUE :=P_PARAM296 ;
l_param_values_tbl(297).VALUE :=P_PARAM297 ;
l_param_values_tbl(298).VALUE :=P_PARAM298 ;
l_param_values_tbl(299).VALUE :=P_PARAM299 ;
l_param_values_tbl(300).VALUE :=P_PARAM300 ;
---------------------------------------- PARAM values inserted -----------------------------


------------------------ Deriving Cal Period End Date -------------------

select date_assign_value into l_cal_period_end_date from fem_cal_periods_attr
where cal_period_id = P_CAL_PERIOD
and attribute_id = (
select a.attribute_id from fem_dim_attributes_b a,fem_dim_attr_versions_b v
where  a.attribute_id = v.attribute_id
and a.attribute_varchar_label = 'CAL_PERIOD_END_DATE'
and v.default_version_flag = 'Y' );

------------------------ Deriving Cal Period Number ---------------------

select number_assign_value into l_cal_period_number from FEM_CAL_PERIODS_ATTR
where cal_period_id = P_CAL_PERIOD
and attribute_id = (
select a.attribute_id from fem_dim_attributes_b a,fem_dim_attr_versions_b v
where  a.attribute_id = v.attribute_id
and a.attribute_varchar_label = 'GL_PERIOD_NUM'
and v.default_version_flag = 'Y' );

----------------------- Deriving Cal Period Grp Display Code ---------------------

select dimension_group_display_code into l_cal_grp_display_code from FEM_DIMENSION_GRPS_B
where dimension_group_id = (select dimension_group_id from fem_cal_periods_b where
cal_period_id = P_CAL_PERIOD);

---------------------- Deriving Dataset Display Code ------------------------

select dataset_display_code into l_dataset_display_code from fem_datasets_b
where dataset_code = P_DATASET_DISPLAY_CODE;

---------------------- Creating dynamic insert query ------------------------
l_canonical_format:= 'RRRR/MM/DD';
l_adi_date_format := FND_PROFILE.VALUE('FEM_INTF_ATTR_DATE_FORMAT_MASK');
l_end_date        := to_char(l_cal_period_end_date,l_canonical_format);

 l_query_columns := '(STATUS,LEDGER_DISPLAY_CODE,DATASET_DISPLAY_CODE,SOURCE_SYSTEM_DISPLAY_CODE,CAL_PERIOD_NUMBER,CAL_PERIOD_END_DATE,CALP_DIM_GRP_DISPLAY_CODE';
 l_query_values := '(' || '''' || 'LOAD' || ''''
|| ',' || '''' || P_LEDGER_DISPLAY_CODE || ''''
|| ',' || '''' || l_dataset_display_code || ''''
|| ',' || '''' || P_SOURCE_SYSTEM_DISPLAY_CODE || ''''
|| ',' || '''' || l_cal_period_number || ''''
|| ',' || 'to_date(' || '''' || l_end_date || '''' || ',' || '''' ||l_canonical_format || '''' || ')'
|| ',' || '''' || l_cal_grp_display_code || '''';

 select table_name into l_table_name from fem_tables_vl
 where display_name = p_table_name;

 select interface_table_name,table_name || '_INTF' into l_interface_table_name,l_interface_code from
 fem_tables_vl where display_name = p_table_name;

-------------------------------------------------------------------------------------------------------------------------
-- For table length with more than 20 chars the integrator/interface code won't be simply table_name || '_INTG' / '_INTF'
-- We need to fetch that interface/integrator code with some other logic. One such logic used here

 if(length(l_table_name)>20) then
  select interface_code into l_interface_code from bne_interfaces_vl where instr(user_name,p_table_name) <>0;
 end if;
------------------------------------------------------------------------------------------------------------------------

 for columns_values in
 (
   select bne_interface_col_name bne_interface_col_name,interface_column_name,data_type from
   fem_webadi_table_cols_maps
   where
   interface_table_name = l_interface_table_name
   and bne_interface_col_name in
   (select interface_col_name from bne_interface_cols_b where
    interface_code = l_interface_code and enabled_flag = 'Y')
 )
 loop

  l_query_columns := l_query_columns || ',' || columns_values.interface_column_name;

  l_param_number := TO_NUMBER(SUBSTR(columns_values.bne_interface_col_name,8));

  l_column_value := l_param_values_tbl(l_param_number).VALUE;

  l_column_name := columns_values.bne_interface_col_name;

  if(l_column_value is null) then
   l_query_values := l_query_values || ',' || 'NULL' ;
 elsif(columns_values.data_type = 'DATE') then
      l_query_values := l_query_values || ',' || 'to_date(' || '''' ||l_column_value || '''' || ',' || '''' || l_adi_date_format || '''' || ')';
  else
   if(columns_values.data_type = 'NUMBER') then
     select to_number(l_column_value) into l_valid_number from dual;
    end if;
    l_query_values := l_query_values || ',' || '''' || l_column_value  || '''';
  end if;

 end loop;

 l_query_columns := l_query_columns || ')';
 l_query_values := l_query_values || ')';

 l_insert_query := 'INSERT INTO ' || l_interface_table_name || l_query_columns || ' VALUES ' || l_query_values;

 execute immediate l_insert_query;

 EXCEPTION
 --
  WHEN DUP_VAL_ON_INDEX THEN
     FND_MESSAGE.SET_NAME('FEM','FEM_ADI_DUPLICATE_ROWS');
     APP_EXCEPTION.Raise_Exception ;

  WHEN INVALID_NUMBER THEN

      select PROMPT_ABOVE into l_column_name from bne_interface_cols_vl where
      interface_code = l_interface_code and interface_col_name = l_column_name;

      FND_MESSAGE.SET_NAME('FEM','FEM_ADI_INVALID_NUMBER');
      FND_MESSAGE.SET_TOKEN('COLUMN_NAME',l_column_name);
      APP_EXCEPTION.Raise_Exception ;


  WHEN E_NO_TABLE THEN
     NULL;

 END UPLOAD_FEM_TABLE_INTERFACE;


PROCEDURE CHECK_VALID_LAYOUT(P_TABLE_NAME IN VARCHAR2, X_VALID_CODE OUT NOCOPY VARCHAR2)
IS

l_total_columns number;
l_intf_table_name varchar2(50);
begin

  begin
   select interface_table_name into l_intf_table_name from fem_tables_b
    where table_name = p_table_name;

   select count(1) into l_total_columns from dba_tab_columns
    where owner = (select table_owner from user_synonyms where synonym_name = l_intf_table_name)
    and table_name = l_intf_table_name;

  exception
   when NO_DATA_FOUND then
     x_valid_code := 'N';
     return;
  end;

  if(l_total_columns > 259) then
    x_valid_code := 'N';
  else
    x_valid_code := 'Y';
end if;

END CHECK_VALID_LAYOUT;

PROCEDURE DELETE_METADATA
IS

begin

delete from bne_security_rules where application_id = 274
and security_code not in ('FEM_BALANCES_SECURITY_RULE');

delete from bne_secured_objects where application_id = 274
and object_code not in ('FEM_BALANCES_INTG');

delete from bne_layouts_b where application_id = 274
and layout_code not in ('FEM_BALANCES_LAYOUT');

delete from bne_layouts_tl where application_id = 274
and layout_code not in ('FEM_BALANCES_LAYOUT');

delete from bne_layout_cols where application_id = 274
and layout_code not in ('FEM_BALANCES_LAYOUT');

delete from bne_layout_blocks_tl where application_id = 274
and layout_code not in ('FEM_BALANCES_LAYOUT');

delete from bne_layout_blocks_b where application_id = 274
and layout_code not in ('FEM_BALANCES_LAYOUT');

delete from bne_content_cols_tl where application_id = 274
and content_code not in ('FEM_BALANCES_CNT');

delete from bne_content_cols_b where application_id = 274
and content_code not in ('FEM_BALANCES_CNT');

delete from bne_contents_tl where application_id = 274
and content_code not in ('FEM_BALANCES_CNT');

delete from bne_contents_b where application_id = 274
and content_code not in ('FEM_BALANCES_CNT');

delete from bne_mapping_lines where application_id = 274
and mapping_code not in ('FEM_BALANCES_MAP');

delete from bne_mappings_tl where application_id = 274
and mapping_code not in ('FEM_BALANCES_MAP');

delete from bne_mappings_b where application_id = 274
and mapping_code not in ('FEM_BALANCES_MAP');

delete from bne_interfaces_b where application_id = 274
and interface_code not in ('FEM_BALANCES_INTF');

delete from bne_interfaces_tl where application_id = 274
and interface_code not in ('FEM_BALANCES_INTF');

delete from bne_interface_cols_b where application_id = 274
and interface_code not in ('FEM_BALANCES_INTF');

delete from bne_interface_cols_tl where application_id = 274
and interface_code not in ('FEM_BALANCES_INTF');

delete from bne_integrators_tl where application_id = 274
and integrator_code not in ('FEM_BALANCES_INTG');

delete from bne_integrators_b where application_id = 274
and integrator_code not in ('FEM_BALANCES_INTG');

delete from bne_stored_sql where application_id = 274
and content_code not in ('FEM_BALANCES_CNT');

commit;

END DELETE_METADATA;


END  FEM_WEBADI_TABLES_UTILS_PVT;


/
