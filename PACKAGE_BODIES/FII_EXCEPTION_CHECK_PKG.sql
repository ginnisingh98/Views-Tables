--------------------------------------------------------
--  DDL for Package Body FII_EXCEPTION_CHECK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EXCEPTION_CHECK_PKG" AS
/* $Header: FIIGLECB.pls 120.1 2005/10/30 05:13:20 appldev noship $ */

	g_debug_flag varchar2(1) :=
		nvl( fnd_profile.value( 'FII_DEBUG_MODE' ), 'N' );

----------------------------------------
-- function check_slg_setup
----------------------------------------
FUNCTION check_slg_setup RETURN NUMBER IS

	l_count number;

BEGIN

        if g_debug_flag = 'Y' then
                FII_MESSAGE.Func_Ent('FII_EXCEPTION_CHECK_PKG.check_slg_setup');
        end if;

	select count( distinct ledger_id ) into l_count
	from fii_slg_assignments slga, fii_source_ledger_groups fslg
	where slga.source_ledger_group_id = fslg.source_ledger_group_id
	and fslg.usage_code = 'DBI';

	if l_count > 0 then

		if g_debug_flag = 'Y' then
			FII_MESSAGE.Func_Succ('FII_EXCEPTION_CHECK_PKG.check_slg_setup');
		end if;

		return 0;
	end if;

	-- No source ledger(s) setup for DBI

	fii_message.write_log( msg_name  => 'FII_NO_SLG_SETUP',
							  token_num => 0 );

	fii_message.write_output( msg_name  => 'FII_NO_SLG_SETUP',
							  token_num => 0 );

	if g_debug_flag = 'Y' then
		FII_MESSAGE.Func_Fail('FII_EXCEPTION_CHECK_PKG.check_slg_setup');
	end if;

	return 1;

END check_slg_setup;

FUNCTION detect_unmapped_local_vs( p_dim_short_name VARCHAR2 ) RETURN NUMBER IS

	l_master_vs_id NUMBER(15);

	cursor missing_csr is
	select
		fvs.flex_value_set_name vs_name,
		ifs.id_flex_structure_name coa_name
	from ( select distinct sas.chart_of_accounts_id
	       from fii_slg_assignments sas,
	            fii_source_ledger_groups slg
	       where slg.usage_code = 'DBI'
	       and slg.source_ledger_group_id = sas.source_ledger_group_id
	     ) coa_list,
		 fii_dim_mapping_rules dmr,
		 fnd_flex_value_sets fvs,
		 fnd_id_flex_structures_v ifs
	where coa_list.chart_of_accounts_id = dmr.chart_of_accounts_id
	and dmr.dimension_short_name = p_dim_short_name
	--
	-- Column dmr.status_code is not used by FC and LOB
	--
	-- and dmr.status_code = 'C'
	--
	and not exists (
	    select 1
	    from fii_dim_norm_hierarchy dnh
	    where dnh.parent_flex_value_set_id = l_master_vs_id
	    and dnh.child_flex_value_set_id = dmr.flex_value_set_id1
	    and rownum = 1
	)
	and dmr.flex_value_set_id1 = fvs.flex_value_set_id
	and dmr.chart_of_accounts_id = ifs.id_flex_num
	and ifs.application_id = 101
	and ifs.id_flex_code = 'GL#'
	and ifs.enabled_flag = 'Y';

	l_missing_cnt NUMBER := 0;

BEGIN

	if g_debug_flag = 'Y' then
		fii_message.func_ent(
			'FII_EXCEPTION_CHECK_PKG.detect_unmapped_local_vs');
	end if;

	begin
		select master_value_set_id
		into l_master_vs_id
		from fii_financial_dimensions
		where dimension_short_name = p_dim_short_name;
	exception
		when no_data_found then
			fii_util.write_log(
				'No master_value_set_id found for ' || p_dim_short_name );
			raise;
		when others then
			raise;
	end;

	for missing_csr_rec in missing_csr loop

		l_missing_cnt := l_missing_cnt + 1;

		if l_missing_cnt = 1 then
			fii_message.write_log(    msg_name  => 'FII_UNMAPPED_LOCAL_VS',
								      token_num => 0 );
			fii_message.write_log(    msg_name  => 'FII_REFER_TO_OUTPUT',
								      token_num => 0 );
			fii_message.write_output( msg_name  => 'FII_UNMAPPED_LOCAL_VS',
									  token_num => 0 );
			fii_message.write_output( msg_name  => 'FII_UNMAPPED_LVS_LIST',
									  token_num => 0 );
		end if;

		fii_util.write_output( missing_csr_rec.vs_name || '    ' ||
							   missing_csr_rec.coa_name );
	end loop;

	if g_debug_flag = 'Y' then
		fii_message.func_succ(
			'FII_EXCEPTION_CHECK_PKG.detect_unmapped_local_vs');
	end if;

	return l_missing_cnt;

EXCEPTION

	when others then
		fii_util.write_log(
			'Exception in detect_unmapped_local_vs: ' || sqlerrm );
		fii_message.func_fail(
			'FII_EXCEPTION_CHECK_PKG.detect_unmapped_local_vs');
		return -1;

END detect_unmapped_local_vs;

END FII_EXCEPTION_CHECK_PKG;

/
