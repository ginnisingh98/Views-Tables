--------------------------------------------------------
--  DDL for Package Body FII_GL_EXTRACTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_EXTRACTION_UTIL" AS
/* $Header: FIIGLXUB.pls 120.3 2005/08/16 14:19:19 arcdixit noship $ */

	g_debug_flag	varchar2(1)	:=
		nvl( fnd_profile.value( 'FII_DEBUG_MODE' ), 'N' );
	g_state		varchar2(200)	:= null;
	g_errbuf	varchar2(2000)	:= null;
	g_retcode	varchar2(200)	:= null;
	g_exception_msg	varchar2(4000)	:= null;

----------------------------------------
-- procedure load_ccc_mgr
----------------------------------------
PROCEDURE LOAD_CCC_MGR(
    p_retcode out nocopy varchar2
) IS

	l_count number;

BEGIN

	if g_debug_flag = 'Y' then
		FII_MESSAGE.Func_Ent('FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR');
	end if;

	-- set output parameters to no error by default

	p_retcode := 0;

	-- initialize global variables

	g_state := 'Loading fii_ccc_mgr_gt';

	-- real job start here

	select count(*) into l_count from fii_ccc_mgr_gt;

	if l_count > 0 then
		if g_debug_flag = 'Y' then
			fii_util.put_line( 'Detected ' || l_count || ' rows' );
			FII_MESSAGE.Func_Succ('FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR');
		end if;

		return;
	end if;

	if g_debug_flag = 'Y' then
		fii_util.put_line( 'Populating fii_ccc_mgr_gt' );
	end if;

	/*	Table fii_ccc_mgr_gt has a row for each ccc_org_id.
		Column manager is the ID of the current manager of a ccc_org_id.
		If a ccc_org_id doesn't have a current manager, its manager column
		is set to null.
	*/

        --bug 3560006: populate company_id, cost_center_id
        insert	/*+ append parallel(a) */ into fii_ccc_mgr_gt a (manager, ccc_org_id, company_id, cost_center_id)
        select	/*+ use_hash(ccc_tbl,mgr_tbl,org,fv1,fv2) parallel(ccc_tbl) parallel(org) parallel(fv1) parallel(fv2) pq_distribute(fv1 hash,hash) pq_distribute(fv2 hash,hash) */
		to_number (mgr_tbl.org_information2)  manager,
	        ccc_tbl.organization_id               ccc_org_id,
                fv1.flex_value_id                     com_id,
                fv2.flex_value_id                     cc_id
	from	hr_organization_information ccc_tbl,
		( select /*+ parallel(b) */  organization_id, org_information2
		    from hr_organization_information b
		   where org_information_context = 'Organization Name Alias'
		     and nvl( fnd_date.canonical_to_date( org_information3 ),
					 sysdate + 1 ) <= sysdate
		     and nvl( fnd_date.canonical_to_date( org_information4 ),
					 sysdate + 1 ) >= sysdate
		) mgr_tbl,
               hr_organization_information org,
               fnd_flex_values    fv1,
               fnd_flex_values    fv2
	where	ccc_tbl.org_information_context = 'CLASS'
	and	ccc_tbl.org_information1 = 'CC'
	and	ccc_tbl.org_information2 = 'Y'
	and	ccc_tbl.organization_id = mgr_tbl.organization_id (+)
          and org.org_information_context = 'Company Cost Center'
          and org.organization_id   = ccc_tbl.organization_id
          and fv1.flex_value_set_id = org.org_information2
          and fv1.flex_value        = org.org_information3
          and fv2.flex_value_set_id = org.org_information4
          and fv2.flex_value        = org.org_information5;

	l_count := sql%rowcount;

	if g_debug_flag = 'Y' then
		fii_util.put_line( 'Inserted ' || l_count || ' rows' );
		FII_MESSAGE.Func_Succ('FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR');
	end if;

	commit;

EXCEPTION

	when others then

		-- set global variables

		g_errbuf		:= sqlerrm;
		g_retcode		:= -1;
		g_exception_msg	:= g_retcode || ':' || g_errbuf;

		fii_util.put_line( 'Error occured while ' || g_state );
		fii_util.put_line( g_exception_msg );

		-- set output parameters

		p_retcode := g_retcode;

		FII_MESSAGE.Func_Fail('FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR');

		raise;

END LOAD_CCC_MGR;

----------------------------------------
-- function check_missing_ccc_mgr
----------------------------------------
FUNCTION CHECK_MISSING_CCC_MGR RETURN NUMBER IS

	l_retcode varchar2(128);

        -- Bug 3916910. Added distinct and two and conitions for date_to column.
	-- date_to null is also considered because the organizations having null
	-- to date will not be considered as inactive.
	cursor missing_csr is
	select distinct ou.name
	from fii_ccc_mgr_gt gt, hr_all_organization_units ou
	where gt.manager is null
	and gt.ccc_org_id = ou.organization_id
	and (to_date(to_char(date_to,'mm/dd/yyyy'),'mm/dd/yyyy') >= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'mm/dd/yyyy')
	or date_to is null);

	l_count number :=0;

BEGIN

	if g_debug_flag = 'Y' then
		FII_MESSAGE.Func_Ent('FII_GL_EXTRACTION_UTIL.CHECK_MISSING_CCC_MGR');
	end if;

	load_ccc_mgr ( l_retcode );	-- in case fii_ccc_mgr_gt has not been loaded

	for missing_csr_rec in missing_csr loop
	      l_count := l_count +1;

	      IF l_count = 1  THEN
	      	-- We have found some ccc_org_id with missing current manager.
	 	fii_message.write_log( msg_name  => 'FII_MISSING_CCC_MGR',
						   token_num => 0 );

		fii_message.write_log( msg_name  => 'FII_REFER_TO_OUTPUT',
						   token_num => 0 );

		fii_message.write_output( msg_name  => 'FII_MISSING_CCC_MGR',
							  token_num => 0 );

		fii_message.write_output( msg_name  => 'FII_CCC_ORG_LIST',
							  token_num => 0 );
               END IF;

		fii_util.write_output( missing_csr_rec.name );
	end loop;

	if g_debug_flag = 'Y' then
		FII_MESSAGE.Func_Fail('FII_GL_EXTRACTION_UTIL.CHECK_MISSING_CCC_MGR');
	end if;

	return l_count;

END CHECK_MISSING_CCC_MGR;

----------------------------------------
-- PROCEDURE Get_UNASSIGNED_ID
----------------------------------------
PROCEDURE GET_UNASSIGNED_ID(p_UNASSIGNED_ID out nocopy number, p_UNASSIGNED_VSET_ID out nocopy number,
    p_retcode out nocopy varchar2
) IS

BEGIN

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_EXTRACTION_UTIL.GET_UNASSIGNED_ID');
     end if;

     g_state := 'Getting the unassigned id and value set id';

     p_retcode := 0;

     select f1.FLEX_VALUE_SET_ID ,flex_value_id
     INTO  p_UNASSIGNED_VSET_ID, p_UNASSIGNED_ID
     from fnd_flex_value_sets f1 ,fnd_flex_values f2
     where flex_value_set_name = 'Financials Intelligence Internal Value Set'
     and  f1.flex_value_set_id = f2.flex_value_set_id
     and flex_value = 'UNASSIGNED';

     g_state := 'Retreived the unassigned id and value set id ';

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_EXTRACTION_UTIL.GET_UNASSIGNED_ID');
     end if;


     EXCEPTION

	when no_data_found then
                -- set global variables

		g_errbuf		:= sqlerrm;
		g_retcode		:= -1;
		g_exception_msg	:= g_retcode || ':' || g_errbuf;

		fii_util.put_line( 'Error occured while ' || g_state );
		fii_util.put_line( g_exception_msg );

		-- set output parameters
		p_retcode := g_retcode;
		FII_MESSAGE.Func_Fail('FII_GL_EXTRACTION_UTIL.Get_UNASSIGNED_ID');

        when others then
          	-- set global variables

		g_errbuf		:= sqlerrm;
		g_retcode		:= -1;
		g_exception_msg	:= g_retcode || ':' || g_errbuf;

		fii_util.put_line( 'Error occured while ' || g_state );
		fii_util.put_line( g_exception_msg );

		-- set output parameters
		p_retcode := g_retcode;
		FII_MESSAGE.Func_Fail('FII_GL_EXTRACTION_UTIL.Get_UNASSIGNED_ID');

END GET_UNASSIGNED_ID;

END FII_GL_EXTRACTION_UTIL;

/
