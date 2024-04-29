--------------------------------------------------------
--  DDL for Package Body ASG_CUSTOM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASG_CUSTOM_PVT" as
/* $Header: asgvcstb.pls 120.1 2005/08/12 02:59:09 saradhak noship $ */

  /** CONSTANTS */

  LOG_LEVEL        CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
--  LOG_LEVEL        CONSTANT NUMBER       := 6;
  B_TAB_NAME       VARCHAR2(30);
  COL_TYPE         VARCHAR2(30);
  LAST_COL_NUM          NUMBER;
  IS_BLOB_INCLUDED  VARCHAR2(1);
  LAST_COL_NAME    VARCHAR2(30);
  APPS_SCHEMA_NAME varchar2(4) := 'APPS';
--  ***********************************************
--      procedure Customize_pub_item
--      we assume the default pub item piv created
--      per standard as follows:
--       For example, pub item name :sample_custom
--         base table name : sample_custom
--         acc  table name : sample_custom_acc
--         base table name : having 30 columns
--      After customization:
--         1: save the base table info under parent_table column.
--         2: base_table_name changed to p_base_table_name
--         3. customer should populate acc table using sample_custom_acc
--         4. acc table structure :
--              access_id, user_id, attribute1,..attributek
--            attribute1 to attributek constitutes the PK columns.
--  ***********************************************

  PROCEDURE customize_pub_item
  (
   p_api_version_number         IN      NUMBER,
   p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
   p_pub_item_name       IN VARCHAR2,
   p_base_table_name     IN VARCHAR2,
   p_primary_key_columns IN VARCHAR2,
   p_data_columns        IN VARCHAR2,
   p_additional_filter   IN VARCHAR2,
   x_msg_count           OUT NOCOPY NUMBER,
   x_return_status       OUT NOCOPY VARCHAR2,
   x_error_message       OUT NOCOPY VARCHAR2
   )
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Customize_pub_item';
l_api_version_number    CONSTANT NUMBER       := 1.0;
l_table_exists           NUMBER := 0;
l_piv_name              Varchar2(30);
l_base_table_name       varchar2(30);
l_acc_table_name        varchar2(30);
l_column             varchar2(30);
l_pk_num                number;
l_pk_columns            varchar2(2000);
l_col_num               PLS_INTEGER;
l_pk_length             PLS_INTEGER;
curr_pos                PLS_INTEGER :=1;
l_pk_list               varchar2(2000);
l_count                 PLS_INTEGER;
l_new_query             varchar2(4000);
l_parent_table          varchar2(30);
l_custom_flag           varchar2(1);
l_cols_count            number;
l_acc_count             number;
l_cmd                   varchar2(2000);
c_type                  varchar2(30);
 BEGIN

   B_TAB_NAME := p_base_table_name;
   log ('base table name = '||b_tab_name);

   -- Standard Start of API savepoint
   SAVEPOINT customize_pub_item_PVT;
   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      fND_MSG_PUB.initialize;
   end if;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- ***************************
   -- A few items to check for
   -- 0. check if the item is customable
   -- 1. input p_base_table_name exists
   -- 2. p_primary_key_columns are matched with the pub item
   -- 3. check if this pub item is previously customed

   -- Any other parameters will be stored as NULL
   -- when they are passed in with no values
   -- ***************************

   -- ****************
   -- p_base_table_name check
   -- ****************
/*
    if p_base_table_name is NOT NULL
    then
      select count(object_name)
      into l_table_exists
      from all_objects
      where object_name = p_base_table_name
       and object_type in ('TABLE','VIEW');

      if l_table_exists = 0
      then
          -- this table does not exist
        log(p_base_table_name || ' does not exists!');
        fnd_message.set_name('ASG','TABLE_NOT EXISTS');
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;
      end if;
     else
*/
     if (p_base_table_name is NULL)
     then
        log('p_base_table_name Should not be NULL!');
        fnd_message.set_name('ASG','NO BASE TABLE NAME');
        fnd_msg_pub.Add;
        raise FND_API.G_EXC_ERROR;
   end if;


   -- ****************
   -- check if the pub item is ready to custom
   -- ****************
      select nvl(custom, 'N')
      into l_custom_flag
      from asg_pub
      where pub_id = ( select pub_name from asg_pub_item
                       where item_id = p_pub_item_name);
      if (l_custom_flag <> 'Y')
      then
          -- the custom flag is not Y
        log(p_pub_item_name || ' is not for the customization!');
        fnd_message.set_name('ASG','PUB ITEM NOT CUSTOMABLE');
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;
      end if;

   -- *****************
   -- check if primary_key_column input is null
   -- ****************
   if p_primary_key_columns is NULL
   then
      log( 'p_primary_key_columns Should not be NULL!');
      fnd_message.set_name('ASG','NULL PK COLUMNS');
      fnd_msg_pub.Add;
      raise FND_API.G_EXC_ERROR;
   end if;

  -- ******************
  -- check if the pub item is the right one to do this
  -- only if the pk columns matches with the custom one
  -- *****************


  select base_object_name ,primary_key_column, access_name, parent_table
  into l_piv_name, l_pk_columns, l_acc_table_name,l_parent_table
  from asg_pub_item
  where item_id = p_pub_item_name;

  l_pk_num := find_num_pkcols(l_pk_columns);
  l_col_num := find_num_pkcols(p_data_columns);
  LAST_COL_NUM := l_pk_num + l_col_num;
  if (l_pk_num <> find_num_pkcols(p_primary_key_columns))
  then
       log (' The Primary Keys  number does not match with the pub item');
       fnd_message.set_name('ASG','PK number _NOT matched');
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;
  end if;


 -- ***********
 --  check if the pub item is customed already
 -- *********
   l_cmd := 'select count(*) from '||l_acc_table_name;


   if (l_parent_table is not null)
   then
    execute immediate l_cmd into l_acc_count;
    if (l_parent_table <> p_base_table_name AND l_acc_count <> 0)
    then
         log (' The pub item base table cannot be changed while there is
                record existing in the acc table!');
         fnd_message.set_name('ASG','RECORDS EXISTING IN ACC TABLE');
         fnd_msg_pub.Add;
         raise FND_API.G_EXC_ERROR;
    END IF;
   END IF;



  -- *******************
  -- recreate PIV
  -- *******************

  l_new_query := ' select acc.access_id ';
  log(l_new_query);
  l_new_query := l_new_query ||generate_query(p_primary_key_columns,
                                            1);
					      log(l_new_query);
  l_new_query := l_new_query ||generate_query(p_data_columns,l_pk_num+1);

  -- get the number of the columns in piv
  select count(*) into l_cols_count
  from all_tab_columns
  where table_name = l_piv_name
    and owner=APPS_SCHEMA_NAME;

--     and owner = (select owner
--              from  all_tab_columns
--              where table_name =  l_piv_name
--                    and rownum=1);

  log('total number of the column in the base view:'||to_char(l_cols_count));

  if (IS_BLOB_INCLUDED <>'Y') THEN
   if (l_pk_num + l_col_num < l_cols_count -1 ) then
     l_count := l_pk_num + l_col_num;
     while (l_count < l_cols_count -1 ) LOOP
       l_new_query := l_new_query ||', NULL ATTRIBUTE'
           ||to_char(l_count+1);
       l_count := l_count + 1;

     END LOOP;
   end if;
 Else
    -- IF (IS_BLOB_INCLUDED ='Y') THEN
    -- check to make sure the input put item is the right one
    select data_type into c_type
    from all_tab_columns
    where table_name = l_piv_name
    and column_name = 'ATTRIBUTE'||to_char(l_cols_count-1)
    and rownum = 1 and owner=APPS_SCHEMA_NAME;
    if (c_type <> 'BLOB') then
     log('The publication item does not contain the BLOB column.'||
         ' Please chose the right'
         ||' publication item to custom.');
     raise FND_API.G_EXC_ERROR;
    end if;

   if (l_pk_num + l_col_num < l_cols_count -1 ) then
     l_count := l_pk_num + l_col_num;
     while (l_count < l_cols_count -1 ) LOOP
       l_new_query := l_new_query ||', NULL ATTRIBUTE'
           ||to_char(l_count);
       l_count := l_count + 1;

     END LOOP;
     l_new_query := l_new_query ||','||LAST_COL_NAME||' ATTRIBUTE'
          ||to_char(l_count);
   else
    -- the last col actually has not included yet
         l_new_query := l_new_query ||','||LAST_COL_NAME||' ATTRIBUTE'
          ||to_char(l_cols_count-1);
   end if;

  END IF;

  l_new_query := l_new_query || ' from '||p_base_table_name||', '||
                 l_acc_table_name||' acc ';
  log(l_new_query);
  l_new_query := l_new_query ||
               ' where acc.user_id = asg_base.get_user_id  '||
               generate_where (p_primary_key_columns);

  if p_additional_filter is NOT NULL
  then
    l_new_query := l_new_query || ' and '||p_additional_filter;
  end if ;

    l_new_query := 'create or replace view '||l_piv_name ||
                   ' as '||l_new_query;

  log ('Recreating the PIV view .');
  x_return_status := exec_cmd (l_new_query);
  log ('Recreated the PIV view .');

  -- **************
  -- update asg_pub_item
  -- **************
   log('update the asg_pub_item table.');
   update asg_pub_item
   set parent_table  = p_base_table_name,
       last_update_date = sysdate
   where item_id = P_pub_item_name;
   commit;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to customize_pub_item_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_MSG_PUB.Count_And_Get
      (
         p_count                => x_msg_count,
         p_data                 => x_error_message
      );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to customize_pub_item_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Count_And_Get
      (
         p_count                => x_msg_count,
         p_data                 => x_error_message
      );
  WHEN OTHERS THEN
      Rollback to customize_pub_item_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      if FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      then
         FND_MSG_PUB.Add_Exc_Msg
         (
            G_PKG_NAME,
            l_api_name,
            sqlerrm
         );
      end if;
      FND_MSG_PUB.Count_And_Get
      (
         p_count                => x_msg_count,
         p_data                 => x_error_message
      );


 END  customize_pub_item ;

FUNCTION exec_cmd (pCmd in varchar2)
RETURN varchar2
IS
begin
    log (pCmd);
    execute immediate pCmd;

    RETURN FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   when OTHERS then
    fnd_message.set_name('ASG','SQL COMMAND FAIL!');
    fnd_msg_pub.Add;
   log ( substr(sqlerrm, 1, 200));
   Raise;
   RETURN  FND_API.G_RET_STS_ERROR;
end;

FUNCTION  generate_where (collist in varchar2)
RETURN VARCHAR2
IS

l_col varchar2(30);
l_new_query varchar2(2000) := '';
l_collist varchar2(2000);
l_num PLS_INTEGER := 1;
l_type_col varchar2(2000);
BEGIN

  l_collist := collist;
  while ( instr(l_collist, ',',1) <> 0) LOOP
    l_col := substr(l_collist, 1, instr(l_collist,',')-1);
    l_col := ltrim(l_col,' ');
    l_col := rtrim(l_col,' ');
    l_type_col := get_col(l_col);
    l_new_query := l_new_query ||
          ' and '||l_type_col||
        ' = acc.ATTRIBUTE'||to_char(l_num);

    l_collist := substr(l_collist, instr(l_collist,',')+1);
    l_num := l_num +1;
  END LOOP;
  l_collist := ltrim(l_collist, ' ');
  l_collist := rtrim(l_collist, ' ');
  if (length(l_collist) <> 0)
  then
     l_type_col := get_col(l_collist);
     l_new_query := l_new_query ||
        ' and '||l_type_col||
        ' = acc.ATTRIBUTE'||to_char(l_num);
  END IF;
   log('generate where clause: '||l_new_query);
   return l_new_query;

END;

FUNCTION get_col (col varchar2)
RETURN VARCHAR2
IS
l_type varchar2(30);
l_col  varchar2(2000);

BEGIN
 select data_type into l_type
 from all_tab_columns
 where table_name = B_TAB_NAME
  and column_name = col
  and rownum = 1 and owner=APPS_SCHEMA_NAME;

  COL_TYPE := l_type;
  if (l_type = 'NUMBER' ) then
      l_col := 'to_char('||B_TAB_NAME||'.'||col||
        ') ';
   elsif (l_type = 'DATE') then
     l_col :=
          'to_char('||B_TAB_NAME||'.'||col||
        ', ''dd-mm-yyyy hh24:mi:ss'')';
   else
      l_col :=
          B_TAB_NAME||'.'||col;
   end if;
 log (l_col);
 return l_col;
END;


FUNCTION  generate_query (collist in varchar2, cnt in number)
RETURN VARCHAR2
IS
l_CNT PLS_INTEGER ;
l_col varchar2(30);
l_new_query varchar2(2000):= ' ';
l_collist varchar2(2000);
l_type_col   varchar2(2000);
l_dml   varchar2(2000);
l_tmp varchar2(2000);

BEGIN
  l_cnt := cnt;
  l_collist := collist;
  log(collist);

  while ( instr(l_collist,fnd_global.local_chr(10),1)<>0) LOOP
      l_collist := substr(l_collist, 1, instr(l_collist,fnd_global.local_chr(10))-1)
      ||substr(l_collist, instr(l_collist,fnd_global.local_chr(10))+1);
  end loop;

  while ( instr(l_collist, ',',1) <> 0) LOOP
    l_col := substr(l_collist, 1, instr(l_collist,',')-1);
    log('col:'||l_col);
    l_col := ltrim(l_col,' ');
    l_col := rtrim(l_col,' ');

    l_type_col := get_col(l_col);

    IF  (COL_TYPE <> 'BLOB')  THEN
        l_new_query := l_new_query ||
          ', '||l_type_col
              ||' attribute'
              ||to_char(l_cnt);
    ELSIF ((l_cnt <>  LAST_COL_NUM ) AND (COL_TYPE = 'BLOB') ) THEN
        log('Exception: BLOB type Column must be the last column!');
        RAISE FND_API.G_EXC_ERROR;
    ELSIF ((l_cnt = LAST_COL_NUM ) AND (COL_TYPE = 'BLOB') ) THEN
     LAST_COL_NAME := l_type_col;
     IS_BLOB_INCLUDED := 'Y';
    END IF;


    l_collist := substr(l_collist, instr(l_collist,',')+1);
    l_cnt := l_cnt +1;
  END LOOP;
  l_collist := ltrim(l_collist, ' ');
  l_collist := rtrim(l_collist, ' ');

  if (length(l_collist)<> 0)
  then
    l_type_col := get_col(l_collist);
    IF (COL_TYPE <> 'BLOB') THEN
        l_new_query := l_new_query ||
            ', '||l_type_col
                ||' attribute'
                ||to_char(l_cnt);
    ELSIF ((l_cnt <>  LAST_COL_NUM ) AND (COL_TYPE = 'BLOB') ) THEN
        log('Exception: BLOB type Column must be the last column!');
        RAISE FND_API.G_EXC_ERROR;
    ELSIF ((l_cnt = LAST_COL_NUM ) AND (COL_TYPE = 'BLOB') ) THEN
     IS_BLOB_INCLUDED := 'Y';
     LAST_COL_NAME := l_type_col;
    END IF;
  END IF;
   log ('generate the query: '||l_new_query);
   return l_new_query;

END;

FUNCTION find_num_pkcols (pkcolumns in varchar2)
RETURN number
IS
num_pkcols PLS_INTEGER :=1;
pkcol_length PLS_INTEGER;
curr_position PLS_INTEGER :=1;
BEGIN
  pkcol_length := length(pkcolumns);
  IF pkcol_length = 0 THEN
    RETURN 0;
  END IF;
  WHILE curr_position < pkcol_length LOOP
    curr_position := INSTR(pkcolumns, ',', curr_position);
    IF curr_position = 0 THEN
      EXIT;
    ELSE
      curr_position := curr_position + 1;
      num_pkcols := num_pkcols +1;
    END IF;
  END LOOP;

  RETURN num_pkcols;
END find_num_pkcols;

-- make sure to check the boolean to return varchar2
  PROCEDURE mark_dirty (
               p_api_version_number         IN      NUMBER,
               p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
               p_pub_item         IN VARCHAR2,
               p_accessList       IN asg_download.access_list,
               p_userid_list      IN asg_download.user_list,
               p_dmlList          IN asg_download.dml_list,
               p_timestamp        IN DATE,
               x_return_status       OUT NOCOPY VARCHAR2
                        )
  IS

  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY1' ;
  l_ret boolean;

  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty1;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_ret := asg_download.mark_dirty(p_pub_item,
                                    p_accessList,
                                    p_userid_list,
                                    p_dmlList,
                                    p_timestamp);
   if (l_ret = TRUE )
   then
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status := FND_API.G_RET_STS_ERROR;
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty1;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty1;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;

  PROCEDURE mark_dirty (
               p_api_version_number         IN      NUMBER,
               p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
               p_pub_item         IN VARCHAR2,
               p_accessList       IN asg_download.access_list,
               p_userid_list      IN asg_download.user_list,
               p_dml_type         IN CHAR,
               p_timestamp        IN DATE,
               x_return_status    OUT NOCOPY VARCHAR2
	   	     )
  IS

  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY2' ;
  l_ret boolean;

  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty2;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;
   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_ret := asg_download.mark_dirty(p_pub_item,
                                    p_accessList,
                                    p_userid_list,
                                    p_dml_type,
                                    p_timestamp);
   if (l_ret = TRUE )
   then
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty2;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty2;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;



  PROCEDURE mark_dirty (
               p_api_version_number         IN      NUMBER,
               p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
               p_pub_item         IN VARCHAR2,
               p_accessid         IN NUMBER,
               p_userid           IN NUMBER,
               p_dml              IN CHAR,
               p_timestamp        IN DATE,
               x_return_status    OUT NOCOPY VARCHAR2
		     )

  IS
  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY3';
   l_ret boolean;

  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty3;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_ret := asg_download.mark_dirty(p_pub_item,
                                    p_accessid,
                                    p_userid,
                                    p_dml,
                                    p_timestamp);
   if (l_ret = TRUE )
   then
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty3;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty3;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty3;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;


  PROCEDURE mark_dirty (
              p_api_version_number         IN      NUMBER,
              p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
              p_pub_item         IN VARCHAR2,
              p_accessid         IN NUMBER,
              p_userid           IN NUMBER,
              p_dml              IN CHAR,
              p_timestamp        IN DATE,
              p_pkvalues         IN asg_download.pk_list,
              x_return_status    OUT NOCOPY VARCHAR2
		     )

  IS
  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY4';
  l_ret boolean;

  BEGIN

      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty4;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_ret := asg_download.mark_dirty(p_pub_item,
                                    p_accessid,
                                    p_userid,
                                    p_dml,
                                    p_timestamp,
                                    p_pkvalues);
   if (l_ret = TRUE )
   then
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;



EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty4;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty4;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty4;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;


  PROCEDURE mark_dirty (
               p_api_version_number         IN      NUMBER,
               p_init_msg_list              IN      VARCHAR2 :=FND_API.G_FALSE,
               p_pub_item         IN VARCHAR2,
               p_accessList       IN asg_download.access_list,
               p_userid_list      IN asg_download.user_list,
               p_dml_type         IN CHAR,
               p_timestamp        IN DATE,
               p_bulk_flag        IN BOOLEAN,
               x_return_status    OUT NOCOPY VARCHAR2
		     ) IS
  l_ret boolean;
  l_api_version_number    CONSTANT NUMBER       := 1.0;
  l_api_name              CONSTANT VARCHAR2(30) := 'MARK_DIRTY5';
  BEGIN
      -- Standard Start of API savepoint
   SAVEPOINT mark_dirty5;

   -- Standard call to check for call compatibility.
   if NOT FND_API.Compatible_API_Call
   (
        l_api_version_number,
        p_api_version_number,
        l_api_name,
        G_PKG_NAME
   )
   then
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
   end if;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   if FND_API.to_Boolean( p_init_msg_list)
   then
      FND_MSG_PUB.initialize;
   end if;

   -- Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_ret := asg_download.mark_dirty(p_pub_item,
                                    p_accessList,
                                    p_userid_list,
                                    p_dml_type,
                                    p_timestamp,
				    p_bulk_flag);
   if (l_ret = TRUE )
   then
     x_return_status := FND_API.G_RET_STS_SUCCESS;
   else
     x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;


EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
      Rollback to mark_dirty5;
      x_return_status := FND_API.G_RET_STS_ERROR;

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      Rollback to mark_dirty5;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
      Rollback to mark_dirty5;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

  END ;


  /* Log Routine */
  PROCEDURE log (p_mesg VARCHAR2 ) IS
   l_dml VARCHAR2(2000);

  BEGIN
      asg_helper.log(p_mesg, 'asg_custom_pvt', LOG_LEVEL);
  END log;

END ASG_CUSTOM_PVT;

/
