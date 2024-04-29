--------------------------------------------------------
--  DDL for Package Body MSD_COLLECT_ORGANIZATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COLLECT_ORGANIZATIONS" AS
/* $Header: msdcorgb.pls 115.2 2002/11/06 23:01:24 pinamati ship $ */


procedure collect_organizations(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER) IS

x_dest_table    varchar2(50) ;
x_retcode 	number;
v_icode		varchar2(4);
v_lang		varchar2(4);
v_dblink	varchar2(128);
v_sql_stmt	varchar2(2000);

Begin


	retcode :=0;

	v_lang := 'US';

        msd_common_utilities.get_db_link(p_instance_id, v_dblink, x_retcode);
        if (x_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                return;
        end if;

	select instance_code
	into v_icode
	from msc_apps_instances
	where instance_id = p_instance_id;

	v_icode := v_icode || ':';

	delete from msc_trading_partners
	where sr_instance_id = p_instance_id;

v_sql_stmt:=
'insert into MSC_TRADING_PARTNERS'
||'  ( PARTNER_ID,'
||'    ORGANIZATION_CODE,'
||'    ORGANIZATION_TYPE,'
||'    SR_TP_ID,'
||'    MASTER_ORGANIZATION,'
||'    SOURCE_ORG_ID,'
||'    PARTNER_TYPE,'
||'    PARTNER_NAME,'
||'    CALENDAR_CODE,'
||'    CALENDAR_EXCEPTION_SET_ID,'
||'    OPERATING_UNIT,'
||'    SR_INSTANCE_ID,'
||'    LAST_UPDATE_DATE,'
||'    LAST_UPDATED_BY,'
||'    CREATION_DATE,'
||'    CREATED_BY)'
||'  select'
||'    msc_trading_partners_s.nextval,'
||'    :v_icode||x.ORGANIZATION_CODE,'
||'    1,'           -- set to discrete as the default value.
||'    x.SR_TP_ID,'
||'    x.MASTER_ORGANIZATION,'
||'    x.SOURCE_ORG_ID,'
||'    x.PARTNER_TYPE,'
||'    :v_icode||x.PARTNER_NAME,'
||'    :v_icode||x.CALENDAR_CODE,'
||'    x.CALENDAR_EXCEPTION_SET_ID,'
||'    x.OPERATING_UNIT,'
||'    :p_instance_id,'
||'    SYSDATE,'
||'    1,'
||'    SYSDATE,'
||'    1'
||'  from MRP_AP_ORGANIZATIONS_V'||v_dblink||' x'
||'  where NVL( x.LANGUAGE, :v_lang)= :v_lang';

EXECUTE IMMEDIATE v_sql_stmt USING v_icode,
                                   v_icode,
                                   v_icode,
                                   p_instance_id,
                                   v_lang,
                                   v_lang;

COMMIT;

	 exception

	  when others then

		errbuf := substr(SQLERRM,1,150);
		retcode := -1 ;


End collect_organizations ;


END MSD_COLLECT_ORGANIZATIONS;

/
