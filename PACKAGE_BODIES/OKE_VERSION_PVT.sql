--------------------------------------------------------
--  DDL for Package Body OKE_VERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_VERSION_PVT" AS
/* $Header: OKEVVERB.pls 120.2 2006/01/27 16:40:04 ifilimon noship $ */

--
-- Global Declarations
--
g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_version_pvt.';
TYPE TargetRec IS RECORD
( TableName          VARCHAR2(30)
, HistTableName      VARCHAR2(30)
, WhereClause        VARCHAR2(2000)
);

TYPE TargetRecTab IS TABLE OF TargetRec
  INDEX BY BINARY_INTEGER;

WorkList       TargetRecTab;
ListCount      NUMBER;

G_PKG_NAME     VARCHAR2(30) := 'OKE_VERSION_PVT';

--
-- Private Procedures
--
PROCEDURE TimeStamp ( tag VARCHAR2 ) IS
l_api_name                   CONSTANT VARCHAR2(30) := 'TimeStamp';
BEGIN
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name, tag || ' : ' || to_char(sysdate,'YYYY/MM/DD HH24:MI:SS') );
 END IF;

END TimeStamp;


PROCEDURE AddToList
(  p_table_name             IN    VARCHAR2
,  p_hist_table_name        IN    VARCHAR2
,  p_where_clause           IN    VARCHAR2
) IS
BEGIN
  ListCount := ListCount + 1;
  WorkList(ListCount).TableName     := p_table_name;
  WorkList(ListCount).HistTableName := p_hist_table_name;
  WorkList(ListCount).WhereClause   := p_where_clause;
END AddToList;


PROCEDURE Load_Version_List IS
BEGIN
  ListCount := 0;
  AddToList( 'OKE_K_HEADERS' ,           'OKE_K_HEADERS_H' ,          'K_HEADER_ID = :id');
  AddToList( 'OKE_K_LINES' ,             'OKE_K_LINES_H' ,
               'K_LINE_ID IN ( SELECT ID FROM OKC_K_LINES_B WHERE DNZ_CHR_ID = :id)' );
  AddToList( 'OKE_K_DELIVERABLES_B' ,    'OKE_K_DELIVERABLES_BH' ,    'K_HEADER_ID = :id');
  AddToList( 'OKE_K_DELIVERABLES_TL' ,   'OKE_K_DELIVERABLES_TLH' ,   'K_HEADER_ID = :id');
  AddToList( 'OKE_K_FUNDING_SOURCES' ,   'OKE_K_FUNDING_SOURCES_H' ,  'OBJECT_ID = :id');
  AddToList( 'OKE_K_FUND_ALLOCATIONS' ,  'OKE_K_FUND_ALLOCATIONS_H' , 'OBJECT_ID = :id');
  AddToList( 'OKE_K_TERMS' ,             'OKE_K_TERMS_H' ,            'K_HEADER_ID = :id');
  AddToList( 'OKE_K_BILLING_METHODS' ,   'OKE_K_BILLING_METHODS_H' ,  'K_HEADER_ID = :id');
  AddToList( 'OKE_K_STANDARD_NOTES_B' ,  'OKE_K_STANDARD_NOTES_BH' ,  'K_HEADER_ID = :id');
  AddToList( 'OKE_K_STANDARD_NOTES_TL' , 'OKE_K_STANDARD_NOTES_TLH' ,
               'STANDARD_NOTES_ID IN ( SELECT STANDARD_NOTES_ID ' ||
               'FROM OKE_K_STANDARD_NOTES_B WHERE K_HEADER_ID = :id)' );
  AddToList( 'OKE_K_USER_ATTRIBUTES' ,   'OKE_K_USER_ATTRIBUTES_H' ,  'K_HEADER_ID = :id');
END Load_Version_List;


PROCEDURE Load_Restore_List IS
BEGIN
  ListCount := 0;
  --
  -- OKC Tables
  --
  AddToList( 'OKC_K_HEADERS_B' ,          'OKC_K_HEADERS_BH' ,           'ID = :id');
  AddToList( 'OKC_K_HEADERS_TL' ,         'OKC_K_HEADERS_TLH' ,          'ID = :id');
  AddToList( 'OKC_K_LINES_B' ,            'OKC_K_LINES_BH' ,             'DNZ_CHR_ID = :id');
  AddToList( 'OKC_K_LINES_TL' ,           'OKC_K_LINES_TLH' ,
               'ID IN ( SELECT ID FROM OKC_K_LINES_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_ARTICLE_TRANS' ,        'OKC_ARTICLE_TRANS_H' ,        'DNZ_CHR_ID = :id');
  AddToList( 'OKC_CONTACTS' ,             'OKC_CONTACTS_H' ,             'DNZ_CHR_ID = :id');
  AddToList( 'OKC_COVER_TIMES' ,          'OKC_COVER_TIMES_H' ,          'DNZ_CHR_ID = :id');
  AddToList( 'OKC_FUNCTION_EXPR_PARAMS' , 'OKC_FUNCTION_EXPR_PARAMS_H' , 'DNZ_CHR_ID = :id');
  AddToList( 'OKC_GOVERNANCES' ,          'OKC_GOVERNANCES_H' ,          'DNZ_CHR_ID = :id');
  AddToList( 'OKC_K_ITEMS' ,              'OKC_K_ITEMS_H' ,              'DNZ_CHR_ID = :id');
  AddToList( 'OKC_K_PROCESSES' ,          'OKC_K_PROCESSES_H' ,          'CHR_ID = :id');
  AddToList( 'OKC_OUTCOME_ARGUMENTS' ,    'OKC_OUTCOME_ARGUMENTS_H' ,    'DNZ_CHR_ID = :id');
  AddToList( 'OKC_REACT_INTERVALS' ,      'OKC_REACT_INTERVALS_H' ,      'DNZ_CHR_ID = :id');
  AddToList( 'OKC_RG_PARTY_ROLES' ,       'OKC_RG_PARTY_ROLES_H' ,       'DNZ_CHR_ID = :id');
  AddToList( 'OKC_SECTIONS_B' ,           'OKC_SECTIONS_BH' ,            'CHR_ID = :id');
  AddToList( 'OKC_SECTIONS_TL' ,          'OKC_SECTIONS_TLH' ,
               'ID IN ( SELECT ID FROM OKC_SECTIONS_B WHERE CHR_ID = :id )');
  AddToList( 'OKC_SECTION_CONTENTS' ,     'OKC_SECTION_CONTENTS_H' ,
               'SCN_ID IN ( SELECT ID FROM OKC_SECTIONS_B WHERE CHR_ID = :id )');
  AddToList( 'OKC_CONDITION_HEADERS_B' ,  'OKC_CONDITION_HEADERS_BH' ,   'DNZ_CHR_ID = :id');
  AddToList( 'OKC_CONDITION_HEADERS_TL' , 'OKC_CONDITION_HEADERS_TLH' ,
               'ID IN ( SELECT ID FROM OKC_CONDITION_HEADERS_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_CONDITION_LINES_B' ,    'OKC_CONDITION_LINES_BH' ,     'DNZ_CHR_ID = :id');
  AddToList( 'OKC_CONDITION_LINES_TL' ,   'OKC_CONDITION_LINES_TLH' ,
               'ID IN ( SELECT ID FROM OKC_CONDITION_LINES_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_ITEM_PARTYS_B' ,        'OKC_ITEM_PARTYS_BH' ,         'DNZ_CHR_ID = :id');
  AddToList( 'OKC_ITEM_PARTYS_TL' ,       'OKC_ITEM_PARTYS_TLH' ,
               'ID IN ( SELECT ID FROM OKC_ITEM_PARTYS_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_K_ARTICLES_B' ,         'OKC_K_ARTICLES_BH' ,          'DNZ_CHR_ID = :id');
  AddToList( 'OKC_K_ARTICLES_TL' ,        'OKC_K_ARTICLES_TLH' ,
               'ID IN ( SELECT ID FROM OKC_K_ARTICLES_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_K_PARTY_ROLES_B' ,      'OKC_K_PARTY_ROLES_BH' ,       'DNZ_CHR_ID = :id');
  AddToList( 'OKC_K_PARTY_ROLES_TL' ,     'OKC_K_PARTY_ROLES_TLH' ,
               'ID IN ( SELECT ID FROM OKC_K_PARTY_ROLES_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_OUTCOMES_B' ,           'OKC_OUTCOMES_BH' ,            'DNZ_CHR_ID = :id');
  AddToList( 'OKC_OUTCOMES_TL' ,          'OKC_OUTCOMES_TLH' ,
               'ID IN ( SELECT ID FROM OKC_OUTCOMES_B WHERE DNZ_CHR_ID = :id )');
  AddToList( 'OKC_OUTCOME_ARGUMENTS' ,    'OKC_OUTCOME_ARGUMENTS_H' ,    'DNZ_CHR_ID = :id');
  --
  -- OKE Tables
  --
  AddToList( 'OKE_K_HEADERS' ,           'OKE_K_HEADERS_H' ,          'K_HEADER_ID = :id');
  AddToList( 'OKE_K_LINES' ,             'OKE_K_LINES_H' ,
               'K_LINE_ID IN ( SELECT ID FROM OKC_K_LINES_B WHERE DNZ_CHR_ID = :id)' );
  AddToList( 'OKE_K_DELIVERABLES_B' ,    'OKE_K_DELIVERABLES_BH' ,    'K_HEADER_ID = :id');
  AddToList( 'OKE_K_DELIVERABLES_TL' ,   'OKE_K_DELIVERABLES_TLH' ,   'K_HEADER_ID = :id');
  AddToList( 'OKE_K_FUNDING_SOURCES' ,   'OKE_K_FUNDING_SOURCES_H' ,  'OBJECT_ID = :id');
  AddToList( 'OKE_K_FUND_ALLOCATIONS' ,  'OKE_K_FUND_ALLOCATIONS_H' , 'OBJECT_ID = :id');
  AddToList( 'OKE_K_TERMS' ,             'OKE_K_TERMS_H' ,            'K_HEADER_ID = :id');
  AddToList( 'OKE_K_BILLING_METHODS' ,   'OKE_K_BILLING_METHODS_H' ,  'K_HEADER_ID = :id');
  AddToList( 'OKE_K_STANDARD_NOTES_B' ,  'OKE_K_STANDARD_NOTES_BH' ,  'K_HEADER_ID = :id');
  AddToList( 'OKE_K_STANDARD_NOTES_TL' , 'OKE_K_STANDARD_NOTES_TLH' ,
               'STANDARD_NOTES_ID IN ( SELECT STANDARD_NOTES_ID ' ||
               'FROM OKE_K_STANDARD_NOTES_B WHERE K_HEADER_ID = :id)' );
  AddToList( 'OKE_K_USER_ATTRIBUTES' ,   'OKE_K_USER_ATTRIBUTES_H' ,  'K_HEADER_ID = :id');
END Load_Restore_List;


PROCEDURE version_table
(  p_header_id              IN    NUMBER
,  p_table_name             IN    VARCHAR2
,  p_hist_table_name        IN    VARCHAR2
,  p_where_clause           IN    VARCHAR2
,  p_prev_vers_num          IN    NUMBER
) IS

  column_list      VARCHAR2(8000);
  statement        VARCHAR2(20000);
  c                NUMBER;
  row_processed    NUMBER;

  table_not_found  exception;
  l_api_name                   CONSTANT VARCHAR2(30) := 'Version_table';

  cursor c_col is
    -- bug 3720887
    select   column_name, column_id
    from     all_tab_columns tc
    where     (tc.owner,tc.table_name) in  (
      select   us.table_owner,us.synonym_name
      from     user_synonyms      us
      where    us.synonym_name = p_table_name)
    and     tc.column_name  <> 'MAJOR_VERSION'
    and     tc.data_type not in ('LONG', 'LONG RAW')
    and     exists (
      select     1
      from       user_synonyms      us2,
                 all_tab_columns  tc2
      where      us2.synonym_name = p_hist_table_name
      and        tc2.table_name  = us2.synonym_name
      and        tc2.owner        = us2.table_owner
      and        tc2.column_name  = tc.column_name
      )
    order by column_id;

   /*
    select distinct column_name, column_id
    from   all_tab_columns tc
    ,      user_synonyms   us
    where  us.synonym_name = p_table_name
    and    tc.table_name   = us.synonym_name
    and    tc.owner        = us.table_owner
    and    tc.column_name  <> 'MAJOR_VERSION'
    and    tc.data_type not in ('LONG', 'LONG RAW')
    and exists (
      select null
      from   all_tab_columns tc2
      ,      user_synonyms   us2
      where  us2.synonym_name = p_hist_table_name
      and    tc2.table_name   = us2.synonym_name
      and    tc2.owner        = us2.table_owner
      and    tc2.column_name  = tc.column_name
    )
    order by column_id; */

BEGIN

  --
  -- Building the column list based on database data dictionary
  --
  column_list := '';
  c := 0;
  for colrec in c_col loop
    column_list := column_list || colrec.column_name || ' , ';
    c := c + 1;
  end loop;
  if ( c = 0 ) then
    raise table_not_found;
  end if;

  --
  -- Construct the insert statement.  We need to add the extra
  -- column MAJOR_VERSION here.  The value comes from the
  -- input parameter p_prev_vers_num
  --
  statement := 'INSERT INTO ' || p_hist_table_name || ' ( ' ||
               column_list || 'MAJOR_VERSION ) SELECT ' ||
               column_list || ':mv FROM ' || p_table_name ||
               ' WHERE ' || p_where_clause;

  --
  -- Parse, bind and execute the SQL
  --
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, statement, dbms_sql.native);
  dbms_sql.bind_variable(c, 'mv', p_prev_vers_num);
  dbms_sql.bind_variable(c, 'id', p_header_id);
  row_processed := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);


  --
  -- store previous amounts of versions for funding
  --

  IF p_table_name='OKE_K_FUNDING_SOURCES' OR p_table_name='OKE_K_FUND_ALLOCATIONS' THEN
	statement := 'UPDATE '||p_table_name|| ' set PREVIOUS_AMOUNT=AMOUNT WHERE ' ||p_where_clause;
  	c := dbms_sql.open_cursor;
  	dbms_sql.parse(c, statement, dbms_sql.native);
  	dbms_sql.bind_variable(c, 'id', p_header_id);
 	row_processed := dbms_sql.execute(c);
  	dbms_sql.close_cursor(c);
  END IF;




EXCEPTION
  WHEN table_not_found THEN
    NULL;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
      FND_MESSAGE.set_name('OKE','OKE_VERS_SQL_ERROR');
      FND_MESSAGE.set_token('NUM', (-1) * sqlcode);
      FND_MESSAGE.set_token('TABLE', p_table_name);
      FND_MSG_PUB.add;
    END IF;
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,statement);
  END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END version_table;


PROCEDURE restore_table
(  p_api_version	    IN	  NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  p_header_id              IN    NUMBER
,  p_table_name             IN    VARCHAR2
,  p_hist_table_name        IN    VARCHAR2
,  p_where_clause           IN    VARCHAR2
,  p_rstr_from_ver          IN    NUMBER
) IS

  column_list      VARCHAR2(8000);
  statement        VARCHAR2(20000);
  c                NUMBER;
  row_processed    NUMBER;

  table_not_found  exception;

  cursor c_col is
    -- bug 3720887
    select   column_name, column_id
    from     all_tab_columns tc
    where     (tc.owner,tc.table_name) in  (
      select   us.table_owner,us.synonym_name
      from     user_synonyms      us
      where    us.synonym_name = p_table_name)
    and     tc.column_name  <> 'MAJOR_VERSION'
    and     tc.data_type not in ('LONG', 'LONG RAW')
    and     exists (
      select     1
      from       user_synonyms      us2,
                 all_tab_columns  tc2
      where      us2.synonym_name = p_hist_table_name
      and        tc2.table_name  = us2.synonym_name
      and        tc2.owner        = us2.table_owner
      and        tc2.column_name  = tc.column_name
      )
    order by column_id;

    /*
    select distinct column_name, column_id
    from   all_tab_columns tc
    ,      user_synonyms   us
    where  us.synonym_name = p_table_name
    and    tc.table_name   = us.synonym_name
    and    tc.owner        = us.table_owner
    and    tc.column_name  <> 'MAJOR_VERSION'
    and    tc.data_type not in ('LONG', 'LONG RAW')
    and exists (
      select null
      from   all_tab_columns tc2
      ,      user_synonyms   us2
      where  us2.synonym_name = p_hist_table_name
      and    tc2.table_name   = us2.synonym_name
      and    tc2.owner        = us2.table_owner
      and    tc2.column_name  = tc.column_name
    )
    order by column_id;
    */

   l_api_name                   CONSTANT VARCHAR2(30) := 'restore_table';


BEGIN
  --
  -- Building the column list based on database data dictionary
  --
  column_list := '';
  c := 0;
  for colrec in c_col loop
    if ( c = 0 ) then
      column_list := colrec.column_name;
    else
      column_list := column_list || ' , ' || colrec.column_name;
    end if;
    c := c + 1;
  end loop;
  if ( c = 0 ) then
    raise table_not_found;
  end if;



  IF p_table_name<>'OKE_K_FUNDING_SOURCES' AND p_table_name<>'OKE_K_FUND_ALLOCATIONS' THEN

	-- not funding

  --
  -- First, construct the detele statement.
  --
  statement := 'DELETE FROM ' || p_table_name ||
               ' WHERE ' || p_where_clause;

  --
  -- Parse, bind and execute the SQL
  --
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, statement, dbms_sql.native);
  dbms_sql.bind_variable(c, 'id', p_header_id);
  row_processed := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);

  --
  -- Now, construct the insert statement.
  --
  statement := 'INSERT INTO ' || p_table_name || ' ( ' ||
               column_list || ' ) SELECT ' ||
               column_list || ' FROM ' || p_hist_table_name ||
               ' WHERE ' || p_where_clause ||
               ' AND MAJOR_VERSION = :mv';

  --
  -- Parse, bind and execute the SQL
  --
  c := dbms_sql.open_cursor;
  dbms_sql.parse(c, statement, dbms_sql.native);
  dbms_sql.bind_variable(c, 'id', p_header_id);
  dbms_sql.bind_variable(c, 'mv', p_rstr_from_ver);
  row_processed := dbms_sql.execute(c);
  dbms_sql.close_cursor(c);


  --
  -- store previous amounts of versions for funding
  -- COPY ATTRIBUTE BY ATTRIBUTE TO THE OLD ONE


/*
		SOURCES
		|---------------------|
		|current    	      |
		|	 	      |
		|	X-----------| |    	R = source does not exist in history (not_included_allocs)
		|	|   	    | |		Q = source is in history and all allocs in history(included_allocs)
		|   R	Q	Y   | |		?Z = source is in history and not all allocs in history
		|	|	    | |		X = R+Q
		|	|  history  | |
		|	|-----------| |
		|----------------------
*/
  END IF;

/*


  ELSE
	statement := 'UPDATE '||p_table_name|| ' set PREVIOUS_AMOUNT=(SELECT AMOUNT FROM '||
	p_hist_table_name ||' WHERE '||p_where_clause||' AND MAJOR_VERSION = :mv)'
	|| 'WHERE ' ||p_where_clause;
  	c := dbms_sql.open_cursor;
  	dbms_sql.parse(c, statement, dbms_sql.native);
  	dbms_sql.bind_variable(c, 'id', p_header_id);
 	row_processed := dbms_sql.execute(c);
  	dbms_sql.close_cursor(c);
  END IF;
*/


EXCEPTION
  WHEN table_not_found THEN
    NULL;
  WHEN OTHERS THEN
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
      FND_MESSAGE.set_name('OKE','OKE_VERS_SQL_ERROR');
      FND_MESSAGE.set_token('NUM', sqlcode);
      FND_MESSAGE.set_token('TABLE', p_table_name);
      FND_MSG_PUB.add;
    END IF;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,statement);
    END IF;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END restore_table;


--
-- Private Procedures
--
PROCEDURE version_contract
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  p_chr_id                 IN    NUMBER
,  p_chg_request_id	    IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_prev_vers              OUT   NOCOPY NUMBER
,  x_new_vers               OUT   NOCOPY NUMBER
) IS

l_api_name                   CONSTANT VARCHAR2(30) := 'version_contract';
okc_cvmv_rec_in  okc_cvm_pvt.cvmv_rec_type;
okc_cvmv_rec_out okc_cvm_pvt.cvmv_rec_type;
i                NUMBER;
l_return_status  VARCHAR2(1);
progress         NUMBER := 0;

cursor cvmv is
  select kvn.chr_id
  ,      kvn.major_version
  ,      kvn.minor_version
  ,      kvn.object_version_number
  ,      kvn.created_by
  ,      kvn.creation_date
  ,      kvn.last_updated_by
  ,      kvn.last_update_date
  ,      kvn.last_update_login
  FROM   okc_k_vers_numbers kvn
  WHERE  chr_id = p_chr_id;

BEGIN

  TimeStamp('version_contract() <<');

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT version_contract_pvt;

  --
  -- Set API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Check API incompatibility
  --

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --
  -- Get the current version number from OKC
  --
  OPEN cvmv;
  FETCH cvmv INTO okc_cvmv_rec_in.chr_id
             ,    okc_cvmv_rec_in.major_version
             ,    okc_cvmv_rec_in.minor_version
             ,    okc_cvmv_rec_in.object_version_number
             ,    okc_cvmv_rec_in.created_by
             ,    okc_cvmv_rec_in.creation_date
             ,    okc_cvmv_rec_in.last_updated_by
             ,    okc_cvmv_rec_in.last_update_date
             ,    okc_cvmv_rec_in.last_update_login;

  progress := 1;

  IF cvmv%notfound THEN
    CLOSE cvmv;
    ROLLBACK TO version_contract_pvt;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
      FND_MESSAGE.set_name('OKE','OKE_VERS_INVALID_CONTRACT');
      FND_MSG_PUB.add;
    END IF;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;
  CLOSE cvmv;

  progress := 2;

  x_prev_vers := okc_cvmv_rec_in.major_version;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Previous Version = ' || x_prev_vers);
  END IF;

  --
  -- Version OKC side of contract components
  --
  OKC_VERSION_PVT.Version_Contract
                 ( p_api_version   => p_api_version
                 , p_commit        => FND_API.G_FALSE
                 , p_init_msg_list => p_init_msg_list
                 , x_return_status => l_return_status
                 , x_msg_count     => x_msg_count
                 , x_msg_data      => x_msg_data
                 , p_cvmv_rec      => okc_cvmv_rec_in
                 , x_cvmv_rec      => okc_cvmv_rec_out );
  --
  -- If anything happens, abort API
  --

  progress := 3;

  IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    ROLLBACK TO version_contract_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    ROLLBACK TO version_contract_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  progress := 4;

  x_new_vers := okc_cvmv_rec_out.major_version;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'New Version = ' || x_new_vers);
  END IF;

  --
  -- Load OKE Work List
  --
  Load_Version_List;

  progress := 5;

  --
  -- Loop through work list
  --
  i := WorkList.FIRST;
  loop
    TimeStamp('Versioning ' || WorkList(i).TableName);
    version_table( p_chr_id
                 , WorkList(i).TableName
                 , WorkList(i).HistTableName
                 , WorkList(i).WhereClause
                 , x_new_vers );
    exit when ( i = ListCount );
    i := WorkList.NEXT(i);
  end loop;


  progress := 6;

  --
  -- Insert to OKE_K_VERS_NUMBERS_H
  --

	insert into OKE_K_VERS_NUMBERS_H
	(K_HEADER_ID
 	,MAJOR_VERSION
 	,CREATION_DATE
 	,CREATED_BY
 	,LAST_UPDATE_DATE
 	,LAST_UPDATED_BY
 	,LAST_UPDATE_LOGIN
 	,VERSION_REASON_CODE
 	,CHG_REQUEST_ID)
	values
	(p_chr_id
	,x_new_vers
        ,sysdate
	,fnd_global.user_id
	,sysdate
	,fnd_global.user_id
	,fnd_global.login_id
	,p_version_reason_code
	,p_chg_request_id
	);

  progress := 7;

  --
  -- Standard commit check
  --
  IF FND_API.TO_BOOLEAN( p_commit ) THEN
    COMMIT;
  END IF;

  progress := 8;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

  TimeStamp('version_contract() >>');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO version_contract_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO version_contract_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO version_contract_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'VERSION_CONTRACT(' || progress || ')');

    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );


END version_contract;


PROCEDURE restore_contract_version
(  p_api_version            IN    NUMBER
,  p_commit                 IN    VARCHAR2 := FND_API.G_FALSE
,  p_init_msg_list          IN    VARCHAR2 := FND_API.G_FALSE
,  x_msg_count              OUT   NOCOPY NUMBER
,  x_msg_data               OUT   NOCOPY VARCHAR2
,  x_return_status          OUT   NOCOPY VARCHAR2
,  p_chr_id                 IN    NUMBER
,  p_rstr_from_ver          IN    NUMBER
,  p_chg_request_id         IN    NUMBER
,  p_version_reason_code    IN    VARCHAR2
,  x_new_vers               OUT   NOCOPY NUMBER
) IS

  i                NUMBER;
  l_orig_vers_num  NUMBER;
  l_new_vers_num   NUMBER;
  l_return_status  VARCHAR2(1);
  l_source	NUMBER;
  l_alloc	NUMBER;
  l_flag	VARCHAR2(1);
  l_flag_h	VARCHAR2(1);
  l_counter1	NUMBER;
  l_counter2	NUMBER;
  l_counter3	NUMBER;

  p_funding_in_rec		OKE_FUNDING_PUB.FUNDING_REC_IN_TYPE		;
  x_funding_out_rec		OKE_FUNDING_PUB.FUNDING_REC_OUT_TYPE		;
  p_allocation_in_tbl		OKE_FUNDING_PUB.ALLOCATION_IN_TBL_TYPE		;
  p_allocation_in_tbl2		OKE_FUNDING_PUB.ALLOCATION_IN_TBL_TYPE		;
  x_allocation_out_tbl		OKE_FUNDING_PUB.ALLOCATION_OUT_TBL_TYPE		;
  l_agreement_type		VARCHAR2(30) := OKE_API.G_MISS_CHAR		;



BEGIN

  TimeStamp('restore_contract_version() <<');

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT rstr_contract_version_pvt;

  --
  -- Set API return status to success
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_return_status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Check API incompatibility
  --

  --
  -- Initialize the message table if requested.
  --
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;
/* bug#4451971
  --
  -- First version the current state of the contract
  --
  version_contract( p_api_version    => p_api_version
                  , p_commit         => FND_API.G_FALSE
                  , p_init_msg_list  => FND_API.G_FALSE
                  , x_msg_count      => x_msg_count
                  , x_msg_data       => x_msg_data
                  , x_return_status  => l_return_status
                  , p_chr_id         => p_chr_id
		  , p_chg_request_id      =>  p_chg_request_id
		  , p_version_reason_code =>  p_version_reason_code
                  , x_prev_vers      => l_orig_vers_num
                  , x_new_vers       => l_new_vers_num
                  );

  --
  -- If anything happens, abort API
  --
  IF ( l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
    ROLLBACK TO rstr_contract_version_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  ELSIF ( l_return_status = FND_API.G_RET_STS_ERROR ) THEN
    ROLLBACK TO rstr_contract_version_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  x_new_vers := l_new_vers_num;
end of bug#4451971 */
  x_new_vers := l_orig_vers_num;

  --
  -- Load Restore Work List
  --
--  Load_Restore_List;

  --
  -- Loop through work list
  --
/*
  i := WorkList.FIRST;
  loop
    TimeStamp('Restoring ' || WorkList(i).TableName);
    restore_table( p_api_version
		,  p_commit
		,  p_init_msg_list
		,  x_msg_count
		,  x_msg_data
		,  x_return_status
		 , p_chr_id
                 , WorkList(i).TableName
                 , WorkList(i).HistTableName
                 , WorkList(i).WhereClause
                 , p_rstr_from_ver );
    exit when ( i = ListCount );
    i := WorkList.NEXT(i);
  end loop;

*/


  --
  -- Standard commit check
  --
  IF FND_API.TO_BOOLEAN( p_commit ) THEN
    COMMIT;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

  TimeStamp('restore_contract_version() >>');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO rstr_contract_version_pvt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO rstr_contract_version_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    ROLLBACK TO rstr_contract_version_pvt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'RESTORE_CONTRACT_VERSION' );

    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );


END restore_contract_version;

END oke_version_pvt;

/
