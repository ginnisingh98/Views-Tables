--------------------------------------------------------
--  DDL for Package Body IBE_SEARCH_SETUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_SEARCH_SETUP_PVT" AS
   /* $Header: IBEVCSIB.pls 120.5.12010000.4 2017/07/04 05:45:42 amaheshw ship $ */
  /*===========================================================================+
 |               Copyright (c) 2000, 2017 Oracle Corporation                       |
 |                  Redwood Shores, California, USA                          |
 |                       All rights reserved.                                |
 +===========================================================================+
 |   File name                                                               |
 |             IBEVCSIB.pls                                                  |
 |             Body file for the iStore Search Insert Concurrent Program     |
 |             Modification is not recommended.                              |
 |                                                                           |
 |   Description                                                             |
 |                                                                           |
 |                                                                           |
 |   SYTONG - bug fix 2550147 -- change the query to check if index exists   |
 |   SYTONG - bug fix 2926852 -- use bulk fetch and insert                   |
 |   abhandar - bug fix 3168087 -catalog search performance                  |
 |   madesai - bug fix 3871664 - GSCC warning fix - remove apps reference    |
 |   madesai - bug fix 4585787 - Remove KOREAN_LEXER for 10Gr12              |
 |   madesai - bug fix 4674288 -explicitly remove korean lobs lexer          |
 |   mgiridha - bug 6924793    - changes to FP 11510 bug 6777665             |
 |   amahsehw - bug 12980419 - UNABLE TO SEARCH PRODUCT USING PRODUCT NUMBER |
 |   amaheshw - bug 13473483/13252575 -- Changed  Fuzzy score to 1           |
 |   amaheshw - bug 25971230 - See bug 25971230 update 04/28/17 02:51 am     |
 |___________________________________________________________________________|*/

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ibe_search_setup_pvt';
G_FETCH_LIMIT CONSTANT NUMBER := 1000;

-- for the test harness
G_TEST_FLAG_ON boolean := false;
G_TEST_SEARCH_WEB_STATUS VARCHAR2(30) := null;
G_TEST_SEARCH_CATEGORY_SET VARCHAR2(30) := null;



FUNCTION WriteToLob(param1	IN	VARCHAR2,
				param2	IN	VARCHAR2,
				param3	IN	VARCHAR2)
RETURN CLOB IS

lob_loc	CLOB;
buffer	VARCHAR2(32000);
amount	BINARY_INTEGER;
pos		INTEGER;


BEGIN
	/* Create Temporary Lob */
	DBMS_LOB.CREATETEMPORARY(lob_loc,TRUE);
	/* Open the Lob for read write */
     DBMS_LOB.OPEN(lob_loc,DBMS_LOB.LOB_READWRITE);

	buffer := param1 ||' '|| param2 ||' '|| param3;
	amount := length(buffer);
	pos := 1;


	/* Write to the Lob */
	DBMS_LOB.WRITE(lob_loc,amount,pos,buffer);

     /*Close Lob */
	DBMS_LOB.CLOSE(lob_loc);

	RETURN lob_loc;

END;

procedure Test_Search_Move_Data(testno  IN  NUMBER,
                                errbuf  OUT NOCOPY VARCHAR2,
								retcode OUT NOCOPY NUMBER)

is  --{

	l_test_search_web_status varchar2(30) := null;
	l_test_search_category_set varchar2(30) := null;
	l_errbuf varchar2(300);
	l_retcode number;

	begin --{

	/*
       Test Scenarios
       ~~~~~~~~~~~~~~
       CASE     SEARCH_CATEGORY_SET   WEB_STATUS
       ----     -------------------   ---------
        1            null              ALL
		2            null              PUBLISHED/null
        3            null              PUBLISHED_UNPUBLISHED
        4            27                ALL
        5            27                PUBLISHED/null
        6            27                PUBLISHED_UNPUBLISHED

		27 is the current profile value of IBE_SEARCH_CATEGORY_SET
		'NULL' is used to denote null in the test cases
	*/

		G_TEST_FLAG_ON := true;


		if (testno = 1)                         --Case 1
		then
			G_TEST_SEARCH_WEB_STATUS := 'ALL';
			G_TEST_SEARCH_CATEGORY_SET := null;

		elsif (testno = 2)                      --Case 2
		then
			G_TEST_SEARCH_WEB_STATUS := 'PUBLISHED';
			G_TEST_SEARCH_CATEGORY_SET := null;

		elsif (testno = 3)                      --Case 3
		then
			G_TEST_SEARCH_WEB_STATUS := 'PUBLISHED_UNPUBLISHED';
			G_TEST_SEARCH_CATEGORY_SET := null;

		elsif (testno = 4)                       --Case 4
		then
			G_TEST_SEARCH_WEB_STATUS := 'ALL';
			G_TEST_SEARCH_CATEGORY_SET := 27;

		elsif (testno = 5)                       --Case 5
		then
			G_TEST_SEARCH_WEB_STATUS := 'PUBLISHED';
			G_TEST_SEARCH_CATEGORY_SET := 27;

		elsif (testno = 6)                      --Case 6
		then
			G_TEST_SEARCH_WEB_STATUS := 'PUBLISHED_UNPUBLISHED';
			G_TEST_SEARCH_CATEGORY_SET := 27;

		end if;


		ibe_search_setup_pvt.search_move_data(l_errbuf,l_retcode);

	end Test_Search_Move_Data; --}
--}

procedure Search_Move_Data(
	errbuf	OUT	NOCOPY VARCHAR2,
	retcode OUT	NOCOPY NUMBER
) is

        l_search_category_set varchar2(30);
        l_search_web_status VARCHAR2(30);
        l_use_category_search VARCHAR2(30);
        l_use_fuzzy_search    VARCHAR2(30);
        l_fuzzy_count         NUMBER            :=  0 ;
        l_index_exists        NUMBER            :=  0 ;
        l_create_fuzzy_index1 VARCHAR2(1000);
        l_create_fuzzy_index2 VARCHAR2(1000) ;
        l_create_fuzzy_index  VARCHAR2(1000);
        l_create_index1        VARCHAR2(1000);
        l_create_index2        VARCHAR2(1000) ;
        l_create_index        VARCHAR2(1000) ;
        l_base_language       VARCHAR2(30);

        cursor old_multi_lexer is select pre_name from ctxsys.ctx_preferences
                            where  pre_name = 'IBE_GLOBAL_LEXER';

        cursor old_sub_lexers is select pre_name from ctxsys.ctx_preferences
                           where  pre_name like 'IBE_LOBS__LEXER';
        -- sytong, bug fix 2926852

     -- TYPE searchCurType IS REF CURSOR;
     -- search_insert_cur searchCurType;

      l_status_AppInfo          varchar2(300) ;
	  l_industry_AppInfo        varchar2(300) ;
	  l_oracle_schema_AppInfo   varchar2(300) ;
	  l_application_short_name  varchar2(300) ;
	  l_trunc_tab			    varchar2(50);

	  l_db_version NUMBER := null;
       l_db_version_str VARCHAR2(100) := null;
       l_compatibility VARCHAR2(100) := null;
--Added by amahsehw - bug 12980419 - UNABLE TO SEARCH PRODUCT USING PRODUCT NUMBER
       l_return_app_info			boolean;

begin

--get application_short_name
select application_short_name
into   l_application_short_name
from   fnd_application
where  application_id = 671 ;

l_return_app_info := fnd_installation.get_app_info(l_application_short_name,
						   l_status_AppInfo          ,
						   l_industry_AppInfo        ,
					      l_oracle_schema_AppInfo   );


/*
  w
  p
  added to check for intermedia index before trying to drop it as otherwise script will fail
*/
--  sytong, bug fix 2550147

        l_search_category_set :='';
        l_search_web_status := 'PUBLISHED';
        l_use_category_search := 'N ';
        l_use_fuzzy_search := 'N';
/*
  Added by amahsehw - bug 12980419 - UNABLE TO SEARCH PRODUCT USING PRODUCT NUMBER.
  Index creation was susscessful if schema name is prefixed e.g. IBE.ibe_ct_imedia_search
        l_create_fuzzy_index1   := 'create index IBE_CT_IMEDIA_SEARCH_IM on ibe_ct_imedia_search(INDEXED_SEARCH) indextype is ctxsys.context  ' ;
*/
        l_create_fuzzy_index1   := 'create index IBE_CT_IMEDIA_SEARCH_IM on '||l_oracle_schema_AppInfo||'.ibe_ct_imedia_search(INDEXED_SEARCH) indextype is ctxsys.context  ' ;

        l_create_fuzzy_index2  := ' parameters ('' lexer ibe_global_lexer language column  language  Wordlist IBE_STEM_FUZZY_PREF '') PARALLEL ' ;
        l_create_fuzzy_index  := l_create_fuzzy_index1 || l_create_fuzzy_index2 ;
/*
  Added by amahsehw - bug 12980419 - UNABLE TO SEARCH PRODUCT USING PRODUCT NUMBER.
  Index creation was susscessful if schema name is prefixed e.g. IBE.ibe_ct_imedia_search
        l_create_index1  := 'create index IBE_CT_IMEDIA_SEARCH_IM on ibe_ct_imedia_search(INDEXED_SEARCH) indextype is ctxsys.context ' ;
*/
        l_create_index1  := 'create index IBE_CT_IMEDIA_SEARCH_IM on '||l_oracle_schema_AppInfo||'.ibe_ct_imedia_search(INDEXED_SEARCH) indextype is ctxsys.context ' ;

        l_create_index2   := ' parameters('' lexer ibe_global_lexer language column  language '') PARALLEL ' ;
        l_create_index     := l_create_index1 || l_create_index2 ;
        l_base_language    := ' ';


 select count(*)
 into l_index_exists
 from user_indexes
 where index_name = 'IBE_CT_IMEDIA_SEARCH_IM';


   DBMS_UTILITY.db_version(l_db_version_str, l_compatibility);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' DB VErsion ='||l_db_version_str);

  If (l_db_version_str is null) Then
          l_db_version := 8;
  Else
         l_db_version := to_number(substr(l_db_version_str, 1,(instr(l_db_version_str,'.'))-1));

  End If;

if(l_index_exists > 0 )
then

  FND_FILE.PUT_LINE(FND_FILE.LOG,' Intermedia index exists , dropping intermedia index  ');
  ------dbms_output.put_line(' Intermedia index exists , dropping intermedia index  ');
  execute immediate 'drop index IBE_CT_IMEDIA_SEARCH_IM force';
end if ;

FND_FILE.PUT_LINE(FND_FILE.LOG,' deleting data from Search table ');
--dbms_output.put_line(' deleting data from Search table ');

/* Added by amahsehw - bug 12980419 - UNABLE TO SEARCH PRODUCT USING PRODUCT NUMBER
--truncatapplication_short_name
select application_short_name
into   l_application_short_name
from   fnd_application
where  application_id = 671 ;

if (fnd_installation.get_app_info(l_application_short_name,
						   l_status_AppInfo          ,
						   l_industry_AppInfo        ,
					      l_oracle_schema_AppInfo   )) then
*/

if (l_return_app_info) then
--execute immediate 'truncate table ibe_ct_imedia_search';
l_trunc_tab := 'truncate table '||l_oracle_schema_AppInfo||'.ibe_ct_imedia_search';
 execute immediate l_trunc_tab;
commit;
end if;

----dbms_output.put_line(' Populating search table IBE_CT_IMEDIA_SEARCH');

FND_FILE.PUT_LINE(FND_FILE.LOG,' Populating search table IBE_CT_IMEDIA_SEARCH');
FND_FILE.PUT_LINE(FND_FILE.LOG,' This may take a while depending on how many rows');
FND_FILE.PUT_LINE(FND_FILE.LOG,' you have in mtl_system_items_tl table');

l_use_category_search := FND_PROFILE.VALUE_specific('IBE_USE_CATEGORY_SEARCH',671,0,671);

/* Profile for fuzzy search is defaulted to 'No' so if found to be null
   it is set to 'No' in the next line
*/

l_use_fuzzy_search := FND_PROFILE.VALUE_specific('IBE_FUZZY_SEARCH',671,0,671);

if(l_use_fuzzy_search is null )
then
  l_use_fuzzy_search := 'N' ;
end if ;

FND_FILE.PUT_LINE(FND_FILE.LOG,' IBE_USE_CATEGORY_SEARCH = ' || l_use_category_search );
FND_FILE.PUT_LINE(FND_FILE.LOG,' IBE_FUZZY_SEARCH        = ' || l_use_fuzzy_search    );

--Get Search Category Set profile IBE_SEARCH_CATEGORY_SET;
if (G_TEST_FLAG_ON) --{
then
	l_search_category_set := G_TEST_SEARCH_CATEGORY_SET;
else
	l_search_category_set := FND_PROFILE.VALUE_specific('IBE_SEARCH_CATEGORY_SET',671,0,671);
end if; --}

--Get product status profile IBE_SEARCH_WEB_STATUS;
if (G_TEST_FLAG_ON)
then
	l_search_web_status := G_TEST_SEARCH_WEB_STATUS;
else
	l_search_web_status := FND_PROFILE.VALUE_specific('IBE_SEARCH_WEB_STATUS',671,0,671);
end if; --}

FND_FILE.PUT_LINE(FND_FILE.LOG,' IBE_SEARCH_CATEGORY_SET = ' || l_search_category_set);
FND_FILE.PUT_LINE(FND_FILE.LOG,' IBE_SEARCH_WEB_STATUS = ' || l_search_web_status);

-----------


If (l_search_category_set is null and l_search_web_status='ALL')
 Then --{

    INSERT /*+ APPEND */ INTO IBE_CT_IMEDIA_SEARCH(
     IBE_CT_IMEDIA_SEARCH_ID,OBJECT_VERSION_NUMBER,
     CREATED_BY,CREATION_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,CATEGORY_ID,
     ORGANIZATION_ID,CATEGORY_SET_ID,
     INVENTORY_ITEM_ID,LANGUAGE,
     DESCRIPTION,LONG_DESCRIPTION,
     INDEXED_SEARCH,WEB_STATUS,
     SECURITY_GROUP_ID)
   (SELECT /*+ PARALLEL(C) PARALLEL(B) PARALLEL(A.MTL_SYSTEM_ITEMS_B) */
    ibe_ct_imedia_search_s1.nextval,
    1,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.user_id,
    SYSDATE,
    FND_GLOBAL.conc_login_id,
    c.CATEGORY_ID,
    b.ORGANIZATION_ID,
    c.CATEGORY_SET_ID,--bug 6924793
    b.INVENTORY_ITEM_ID,
    b.LANGUAGE,
    b.DESCRIPTION,
    b.LONG_DESCRIPTION,
    ibe_search_setup_pvt.WriteToLob(b.DESCRIPTION,b.LONG_DESCRIPTION,a.concatenated_segments),
    a.web_status,
    null
   FROM mtl_system_items_b_kfv a ,mtl_system_items_tl b , mtl_item_categories c
   WHERE b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID and
         b.organization_id  = c.organization_id and
         c.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID and
         c.organization_id  = a.organization_id and
         exists (select 1
                 from oe_system_parameters_all osp
                 where osp.master_organization_id = b.organization_id));

Elsif (l_search_category_set is null and
      (l_search_web_status='PUBLISHED' or l_search_web_status is null))
  Then

	INSERT /*+ APPEND */ INTO IBE_CT_IMEDIA_SEARCH(
     IBE_CT_IMEDIA_SEARCH_ID,OBJECT_VERSION_NUMBER,
     CREATED_BY,CREATION_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,CATEGORY_ID,
     ORGANIZATION_ID,CATEGORY_SET_ID,
     INVENTORY_ITEM_ID,LANGUAGE,
     DESCRIPTION,LONG_DESCRIPTION,
     INDEXED_SEARCH,WEB_STATUS,
     SECURITY_GROUP_ID)
     (SELECT /*+ PARALLEL(C) PARALLEL(B) PARALLEL(A.MTL_SYSTEM_ITEMS_B) */
       ibe_ct_imedia_search_s1.nextval,
       1,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.conc_login_id,
       c.CATEGORY_ID,
       b.ORGANIZATION_ID,
       c.CATEGORY_SET_ID,
       b.INVENTORY_ITEM_ID,
       b.LANGUAGE,
       b.DESCRIPTION,
       b.LONG_DESCRIPTION,
       ibe_search_setup_pvt.WriteToLob(b.DESCRIPTION,b.LONG_DESCRIPTION,a.concatenated_segments),
	   a.web_status,
       null
       FROM  mtl_system_items_b_kfv a,mtl_system_items_tl b,mtl_item_categories c
       WHERE b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID and b.organization_id   = c.organization_id
         and c.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID and c.organization_id   = a.organization_id
         and exists ( select 1
                   from oe_system_parameters_all osp
                where osp.master_organization_id = b.organization_id)
         and a.web_status='PUBLISHED');


Elsif (l_search_category_set is null and l_search_web_status='PUBLISHED_UNPUBLISHED')
 Then

	INSERT /*+ APPEND */ INTO IBE_CT_IMEDIA_SEARCH(
     IBE_CT_IMEDIA_SEARCH_ID,OBJECT_VERSION_NUMBER,
     CREATED_BY,CREATION_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,CATEGORY_ID,
     ORGANIZATION_ID,CATEGORY_SET_ID,
     INVENTORY_ITEM_ID,LANGUAGE,
     DESCRIPTION,LONG_DESCRIPTION,
     INDEXED_SEARCH,WEB_STATUS,
     SECURITY_GROUP_ID)
     (SELECT  /*+ PARALLEL(C) PARALLEL(B) PARALLEL(A.MTL_SYSTEM_ITEMS_B) */
       ibe_ct_imedia_search_s1.nextval,
       1,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.conc_login_id,
       c.CATEGORY_ID,
       b.ORGANIZATION_ID,
       c.CATEGORY_SET_ID,
       b.INVENTORY_ITEM_ID,
       b.LANGUAGE,
       b.DESCRIPTION,
       b.LONG_DESCRIPTION,
       ibe_search_setup_pvt.WriteToLob(b.DESCRIPTION,b.LONG_DESCRIPTION,a.concatenated_segments),
       a.web_status,
       null
       FROM  mtl_system_items_b_kfv a ,mtl_system_items_tl b , mtl_item_categories c
       WHERE b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID and b.organization_id   = c.organization_id
         and c.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID and c.organization_id   = a.organization_id
         and exists ( select 1
                   from oe_system_parameters_all osp
                where osp.master_organization_id = b.organization_id)
         and a.web_status in ('PUBLISHED','UNPUBLISHED'));


Elsif (l_search_category_set is not null and l_search_web_status='ALL')
 Then

	INSERT /*+ APPEND */ INTO IBE_CT_IMEDIA_SEARCH(
     IBE_CT_IMEDIA_SEARCH_ID,OBJECT_VERSION_NUMBER,
     CREATED_BY,CREATION_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,CATEGORY_ID,
     ORGANIZATION_ID,CATEGORY_SET_ID,
     INVENTORY_ITEM_ID,LANGUAGE,
     DESCRIPTION,LONG_DESCRIPTION,
     INDEXED_SEARCH,WEB_STATUS,
     SECURITY_GROUP_ID)
     (SELECT /*+ PARALLEL(C) PARALLEL(B) PARALLEL(A.MTL_SYSTEM_ITEMS_B) */
       ibe_ct_imedia_search_s1.nextval,
       1,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.user_id,
       SYSDATE,
       FND_GLOBAL.conc_login_id,
       c.CATEGORY_ID,
       b.ORGANIZATION_ID,
       c.CATEGORY_SET_ID,
       b.INVENTORY_ITEM_ID,
       b.LANGUAGE,
       b.DESCRIPTION,
       b.LONG_DESCRIPTION,
       ibe_search_setup_pvt.WriteToLob(b.DESCRIPTION,b.LONG_DESCRIPTION,a.concatenated_segments),
       a.web_status,
	   null
     FROM mtl_system_items_b_kfv a ,mtl_system_items_tl b , mtl_item_categories c
     WHERE b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID and b.organization_id   = c.organization_id
       and c.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID and c.organization_id   = a.organization_id
       and exists (select 1
                   from oe_system_parameters_all osp
                   where osp.master_organization_id = b.organization_id)
       and c.category_set_id = l_search_category_set);

Elsif (l_search_category_set is not null and
      (l_search_web_status='PUBLISHED' OR l_search_web_status is null))
  Then

	INSERT /*+ APPEND */ INTO IBE_CT_IMEDIA_SEARCH(
     IBE_CT_IMEDIA_SEARCH_ID,OBJECT_VERSION_NUMBER,
     CREATED_BY,CREATION_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,CATEGORY_ID,
     ORGANIZATION_ID,CATEGORY_SET_ID,
     INVENTORY_ITEM_ID,LANGUAGE,
     DESCRIPTION,LONG_DESCRIPTION,
     INDEXED_SEARCH,WEB_STATUS,
     SECURITY_GROUP_ID)
   (SELECT /*+ PARALLEL(C) PARALLEL(B) PARALLEL(A.MTL_SYSTEM_ITEMS_B) */
     ibe_ct_imedia_search_s1.nextval,
      1,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.user_id,
      SYSDATE,
      FND_GLOBAL.conc_login_id,
      c.CATEGORY_ID,
      b.ORGANIZATION_ID,
      c.CATEGORY_SET_ID,
      b.INVENTORY_ITEM_ID,
      b.LANGUAGE,
      b.DESCRIPTION,
      b.LONG_DESCRIPTION,
      ibe_search_setup_pvt.WriteToLob(b.DESCRIPTION,b.LONG_DESCRIPTION,a.concatenated_segments),
      a.web_status,
	  null
     FROM  mtl_system_items_b_kfv a ,mtl_system_items_tl b , mtl_item_categories c
     WHERE b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID and b.organization_id   = c.organization_id
       and c.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID and c.organization_id   = a.organization_id
       and exists (select 1
                   from oe_system_parameters_all osp
                   where osp.master_organization_id = b.organization_id)
       and c.category_set_id = l_search_category_set
       and a.web_status = 'PUBLISHED');


Elsif (l_search_category_set is not null and l_search_web_status= 'PUBLISHED_UNPUBLISHED')
 Then

	INSERT /*+ APPEND */ INTO IBE_CT_IMEDIA_SEARCH(
     IBE_CT_IMEDIA_SEARCH_ID,OBJECT_VERSION_NUMBER,
     CREATED_BY,CREATION_DATE,
     LAST_UPDATED_BY,LAST_UPDATE_DATE,
     LAST_UPDATE_LOGIN,CATEGORY_ID,
     ORGANIZATION_ID,CATEGORY_SET_ID,
     INVENTORY_ITEM_ID,LANGUAGE,
     DESCRIPTION,LONG_DESCRIPTION,
     INDEXED_SEARCH,WEB_STATUS,
     SECURITY_GROUP_ID)
   (SELECT /*+ PARALLEL(C) PARALLEL(B) PARALLEL(A.MTL_SYSTEM_ITEMS_B) */
     ibe_ct_imedia_search_s1.nextval,
     1,
     FND_GLOBAL.user_id,
     SYSDATE,
     FND_GLOBAL.user_id,
     SYSDATE,
     FND_GLOBAL.conc_login_id,
     c.CATEGORY_ID,
     b.ORGANIZATION_ID,
     c.CATEGORY_SET_ID,
     b.INVENTORY_ITEM_ID,
     b.LANGUAGE,
     b.DESCRIPTION,
     b.LONG_DESCRIPTION,
     ibe_search_setup_pvt.WriteToLob(b.DESCRIPTION,b.LONG_DESCRIPTION,a.concatenated_segments),
     a.web_status,
     null
    FROM mtl_system_items_b_kfv a ,mtl_system_items_tl b , mtl_item_categories c
    WHERE b.INVENTORY_ITEM_ID = c.INVENTORY_ITEM_ID and b.organization_id   = c.organization_id
      and c.INVENTORY_ITEM_ID = a.INVENTORY_ITEM_ID and c.organization_id   = a.organization_id
      and exists (select 1
                  from oe_system_parameters_all osp
                  where osp.master_organization_id = b.organization_id)
      and c.category_set_id = l_search_category_set
      and a.web_status IN ('PUBLISHED', 'UNPUBLISHED'));

End if; --}

  commit;

/*----------------------------------------------------------------------
-- Create the multi lexer preference and its constituent components --
----------------------------------------------------------------------*/

for dropit in old_multi_lexer loop
    ctx_ddl.drop_preference('IBE_GLOBAL_LEXER');
end loop;

for dropit in old_sub_lexers loop
   ctx_ddl.drop_preference(dropit.pre_name);
end loop;

FND_FILE.PUT_LINE(FND_FILE.LOG,' Creating GLobal Lexer  ');

ctx_ddl.create_preference('ibe_global_lexer','multi_lexer');

ctx_ddl.create_preference('ibe_lobs_blexer', 'basic_lexer');
ctx_ddl.create_preference('ibe_lobs_clexer', 'chinese_vgram_lexer');
ctx_ddl.create_preference('ibe_lobs_jlexer', 'japanese_vgram_lexer');

  /* bug fix 4585787 */
  If l_db_version > 8 Then
    -- bug 4674288 - 10gR2 compatibility issue force explicit KOREAN_LEXER drop
    -- since it will not show in the CTX_PREFERENCES post 10gR2 upgrade.
      if ( l_db_version  >= 10 ) then
       begin
           ctx_ddl.drop_preference('IBE_LOBS_KLEXER');
           exception
            --  We need to try the drop, no worries if it is not there ...
           when others then null;
        end;
	  end if;

         ctx_ddl.create_preference('ibe_lobs_klexer', 'korean_morph_lexer');

  else
          ctx_ddl.create_preference('ibe_lobs_klexer', 'korean_lexer');
  end if;

ctx_ddl.add_sub_lexer('ibe_global_lexer', 'JA',      'ibe_lobs_jlexer');
ctx_ddl.add_sub_lexer('ibe_global_lexer', 'KO',      'ibe_lobs_klexer');
ctx_ddl.add_sub_lexer('ibe_global_lexer', 'ZHS',     'ibe_lobs_clexer');
ctx_ddl.add_sub_lexer('ibe_global_lexer', 'ZHT',     'ibe_lobs_clexer');
ctx_ddl.add_sub_lexer('ibe_global_lexer', 'default', 'ibe_lobs_blexer');

/*----------------end of mulit lexer ------------ */


/* --------------------------------------------------------------------------
If Fuzzy search profile is on the create the fuzzy preference and then use that
   in the index creation . if the option is OFF then create the intermedia index
   without the fuzzy preference
   --------------------------------------------------------------------------
*/

if(l_use_FUZZY_search = 'Y')
then


      /* Checking if Preference exists before trying to drop it
     */

     select count(*) into l_fuzzy_count
     from CTX_PREFERENCES
     where
      pre_name = 'IBE_STEM_FUZZY_PREF' ;


     if(l_fuzzy_count = 1 )
     then
       Ctx_Ddl.Drop_Preference('IBE_STEM_FUZZY_PREF');
       FND_FILE.PUT_LINE(FND_FILE.LOG,' Dropped existing IBE_STEM_FUZZY_PREF preference  ');
     end if ;

     Ctx_Ddl.Create_Preference('IBE_STEM_FUZZY_PREF', 'BASIC_WORDLIST');
     /* Changed from l_base_language to 'AUTO' to support muliple languages fuzzy 06/07/01
     */
     ctx_ddl.set_attribute('IBE_STEM_FUZZY_PREF','FUZZY_MATCH','AUTO');
     --ctx_ddl.set_attribute('IBE_STEM_FUZZY_PREF','FUZZY_SCORE','0');
	ctx_ddl.set_attribute('IBE_STEM_FUZZY_PREF','FUZZY_SCORE','1');
     ctx_ddl.set_attribute('IBE_STEM_FUZZY_PREF','FUZZY_NUMRESULTS','5000');
     ctx_ddl.set_attribute('IBE_STEM_FUZZY_PREF','STEMMER','AUTO');




     FND_FILE.PUT_LINE(FND_FILE.LOG,' Creating intermedia index on IBE_CT_IMEDIA_SEARCH table with fuzzy ');
     FND_FILE.PUT_LINE(FND_FILE.LOG,'This may take a while ');
     execute immediate l_create_fuzzy_index;
    --perf
      execute immediate 'ALTER INDEX IBE_CT_IMEDIA_SEARCH_IM NOPARALLEL' ;

else
  FND_FILE.PUT_LINE(FND_FILE.LOG,' Creating intermedia index on IBE_CT_IMEDIA_SEARCH table');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'This may take a while ');

  execute immediate l_create_index;
      --perf
  execute immediate 'ALTER INDEX IBE_CT_IMEDIA_SEARCH_IM NOPARALLEL' ;

end if;



FND_FILE.PUT_LINE(FND_FILE.LOG,'Intermedia Index created , procedure completed sucessfully');
----dbms_output.put_line('Intermedia Index created , procedure completed sucessfully');
end Search_Move_Data;

end ibe_search_setup_pvt ;


/
