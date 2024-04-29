--------------------------------------------------------
--  DDL for Package Body MSD_DEM_PROCESS_SALES_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_PROCESS_SALES_DATA" AS -- body
/* $Header: MSDDEMSDB.pls 120.3.12010000.13 2010/03/15 14:41:25 nallkuma ship $ */

NULL_CHAR        CONSTANT VARCHAR2(6) := '-23453';

G_ERROR          CONSTANT   NUMBER := 2;
G_WARNING        CONSTANT   NUMBER := 1;

v_sql_stmt   PLS_INTEGER;
v_debug	     BOOLEAN  := nvl(FND_PROFILE.VALUE('MRP_DEBUG'),'N') = 'Y';

PROCEDURE LOG_MESSAGE(p_error_text IN  VARCHAR2)
IS
BEGIN

    IF fnd_global.conc_request_id > 0  THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, p_error_text);
    END IF;

EXCEPTION
    WHEN OTHERS THEN
      RETURN;
END LOG_MESSAGE;

PROCEDURE LAUNCH( ERRBUF                  OUT NOCOPY VARCHAR2,
	         RETCODE                  OUT NOCOPY NUMBER,
	         p_instance_id            IN  NUMBER )
IS

/* bug#8367504 -- nallkuma
cursor get_schema_name is
select fnd_profile.value('MSD_DEM_SCHEMA')
from dual;
*/

l_schema_name VARCHAR2(100);
l_entity_name VARCHAR2(100);
lv_sql_stmt   VARCHAR2(4000);
lv_error_text VARCHAR2(1000);
l_dest_table  VARCHAR2(100);  -- syenamar    Bug#6459492
l_dem_version number;

cursor c_get_instance_type is
select instance_type
from msc_apps_instances
where instance_id = p_instance_id;

l_instance_type number;

BEGIN

LOG_MESSAGE ('***************** Entered in the procedure - LAUNCH **********');

open c_get_instance_type;
fetch c_get_instance_type into l_instance_type;
close c_get_instance_type;

-- bug#8367471(fp for bug#6087699) nallkuma
if l_instance_type in (1,2,4) then
	msd_dem_push_setup_parameters.push_setup_parameters(ERRBUF, RETCODE, p_instance_id, '-999');
	if retcode = -1 then
			msd_dem_common_utilities.log_message('Push Setup Parameters Failed');
			msd_dem_common_utilities.log_debug('Push Setup Parameters Failed');
			return;
	end if;
else
    /* Calling push_legacy_setup_parameters() procedure in case of pure legacy instance */
    msd_dem_push_setup_parameters.push_legacy_setup_parameters(ERRBUF, RETCODE, p_instance_id);
	if retcode = -1 then
			msd_dem_common_utilities.log_message('Push Legacy Setup Parameters Failed');
			msd_dem_common_utilities.log_debug('Push Legacy Setup Parameters Failed');
			return;
	end if;
end if;


/* bug#8367504 -- nallkuma
open get_schema_name;
fetch get_schema_name into l_schema_name;
close get_schema_name;

if l_schema_name is not null then
 l_schema_name := l_schema_name;
else
 l_schema_name := 'DMTRA_TEMPLATE';
end if;
*/

-- bug#8367504 nallkuma
l_schema_name := substr(msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE')
                          , 1
                          ,	instr(msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE'), '.')-1) ;

LOG_MESSAGE('Fetched the schema name as : '||l_schema_name);

l_dem_version := fnd_profile.value('MSD_DEM_VERSION');

if l_dem_version is null then
LOG_MESSAGE('MSD_DEM_VERSION profile is null.');
return;
end if;


BEGIN

l_entity_name := 'ITEMS';

v_sql_stmt := 01;
lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_item_sr_pk = ( SELECT t2.sr_inventory_item_id '
 ||'                           FROM msc_system_items t2 '
 ||'                           WHERE t2.plan_id         = -1 '
 ||'                           AND   t2.sr_instance_id  =  :p_instance_id '
 ||'                           AND   t2.item_name       = t1.dm_item_code '
 ||'		               AND   t2.organization_id = ( SELECT t3.sr_tp_id '
 ||'						            FROM msc_trading_partners t3 '
 ||'						            WHERE t3.partner_type      = 3 '
 ||'						            AND   t3.organization_code = t1.dm_org_code '
 ||'						            AND   t3.sr_instance_id    =  :p_instance_id '
 ||'	                                              )'
 ||'			     )'
 ||' WHERE NVL(t1.ebs_item_sr_pk,'||''''||NULL_CHAR||''''||') '
 ||'                       =     '||''''||NULL_CHAR||'''';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_instance_id;


EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('An error occured while generating Source Keys for Entity - '||l_entity_name);

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_WARNING;
END;


BEGIN
l_entity_name := 'ORGANIZATIONS';

v_sql_stmt := 02;
lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_org_sr_pk = ( SELECT t2.sr_tp_id '
 ||'                          FROM msc_trading_partners t2 '
 ||'                          WHERE t2.sr_instance_id    = :p_instance_id '
 ||'                          AND   t2.organization_code = t1.dm_org_code '
 ||'                          AND partner_type           = 3 '
 ||'                          AND rownum                 = 1 '
 ||'                         )'
 ||' WHERE NVL(t1.ebs_org_sr_pk,'||''''||NULL_CHAR||''''||') '
 ||'                       =    '||''''||NULL_CHAR||'''';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id;


EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('An error occured while generating Source Keys for Entity - '||l_entity_name);

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_WARNING;
END;


BEGIN
l_entity_name := 'SITES';

v_sql_stmt := 03;
lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_site_sr_pk = ( SELECT t2.sr_tp_site_id '
 ||'                           FROM msc_trading_partners t4, msc_tp_id_lid t5, msc_trading_partner_sites t3, msc_tp_site_id_lid t2 '
 ||'                           WHERE t4.partner_type       = 2 '
 ||'                           AND   t4.partner_name       = substr(t1.dm_site_code,1,instr(t1.dm_site_code,'':'') - 1 ) '
 ||'                           AND   t5.partner_type       = 2 '
 ||'                           AND   t5.sr_instance_id     = ' || to_char(p_instance_id)
 ||'                           AND   t5.tp_id              = t4.partner_id '
 ||'                           AND   nvl(t5.sr_cust_account_number, ''###'') = nvl(substr(t1.dm_site_code, instr(t1.dm_site_code, '':'') + 1, '
 ||                                                         ' instr(t1.dm_site_code, '':'', 1, 2) - instr(t1.dm_site_code, '':'', 1, 1) - 1), ''###'') '
 ||'                           AND   t3.partner_id         = t4.partner_id '
 ||'                           AND   t3.location           = substr(t1.dm_site_code, instr(t1.dm_site_code,'':'',1,2)+1, instr(t1.dm_site_code,'':'',1,3)-instr(t1.dm_site_code,'':'',1,2)-1) '
 ||'                           AND   nvl(t3.operating_unit_name, ''###'') = nvl(substr(t1.dm_site_code , instr(t1.dm_site_code, '':'', 1, 3) + 1, '
 ||'                                 decode (instr(t1.dm_site_code , '':'', 1, 4), 0, length(t1.dm_site_code ) + 1,  instr(t1.dm_site_code , '':'', 1, 4)) - instr(t1.dm_site_code , '':'', 1, 3) - 1), ''###'') ' ;
/* added this code for the bug#6871484 on  22-aug-2008 - nallkuma */
 if l_instance_type in (1,2,4) then
	lv_sql_stmt := lv_sql_stmt ||' AND   t3.tp_site_code       =''SHIP_TO'' ' ;
 end if;

 lv_sql_stmt := lv_sql_stmt ||'AND   t2.tp_site_id         = t3.partner_site_id '
 ||'                           AND   t2.partner_type       = 2 '
 ||'                           AND   t2.sr_instance_id     = :p_instance_id '
 ||'                           AND   nvl(t2.sr_company_id,-1) = -1 '
 ||'                           AND   nvl(t2.sr_cust_acct_id, -1) = nvl(t5.sr_tp_id, -1) '
 ||'                           AND rownum                  = 1 '
 ||'                       )'
 ||' WHERE NVL(t1.ebs_site_sr_pk,'||''''||NULL_CHAR||''''||') '
 ||'                       =     '||''''||NULL_CHAR||'''';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id;

lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_site_sr_pk =  msd_dem_sr_util.get_null_pk '
 ||' WHERE dm_site_code = msd_dem_sr_util.get_null_code';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt;

   IF (msd_dem_common_utilities.is_use_new_site_format <> 0)
THEN

   lv_sql_stmt :=
    ' UPDATE  '||l_schema_name||'.'||'t_src_sales_tmpl  t1 '
    ||' SET t1.dm_site_code =  ''' || to_char(p_instance_id) || '::'' || t1.ebs_site_sr_pk '
    ||' WHERE NVL(ebs_site_sr_pk,0) > 0 ';

         IF v_debug THEN
           LOG_MESSAGE(lv_sql_stmt);
         END IF;

         EXECUTE IMMEDIATE lv_sql_stmt;

END IF;


EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('An error occured while generating Source Keys for Entity - '||l_entity_name);

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_WARNING;
END;



BEGIN
l_entity_name := 'SALES_CHANNELS';

v_sql_stmt := 04;

lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_sales_channel_sr_pk = to_char(msd_dem_sr_util.get_null_pk), t1.ebs_sales_channel_code = msd_dem_sr_util.get_null_code'
 ||' WHERE t1.ebs_sales_channel_code is null';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt;


lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_sales_channel_sr_pk = ( SELECT t2.sales_channel '
 ||'                                    FROM msc_sales_channel t2 '
 ||'                                    WHERE t2.meaning   = t1.ebs_sales_channel_code '
 ||'                                    AND sr_instance_id = :p_instance_id '
 ||'                                    AND rownum         = 1 '
 ||'                                   )'
 ||' WHERE NVL(t1.ebs_sales_channel_sr_pk,'||''''||NULL_CHAR||''''||') '
 ||'                       =              '||''''||NULL_CHAR||'''';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id;



EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('An error occured while generating Source Keys for Entity - '||l_entity_name);

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_WARNING;
END;

BEGIN
l_entity_name := 'DEMAND_CLASSES';

v_sql_stmt := 05;


lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_demand_class_sr_pk = to_char(msd_dem_sr_util.get_null_pk), t1.ebs_demand_class_code = msd_dem_sr_util.get_null_code'
 ||' WHERE t1.ebs_demand_class_code is null';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt;



lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||' t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_demand_class_sr_pk = (  SELECT t2.demand_class '
 ||'                                    FROM msc_demand_classes t2 '
 ||'                                    WHERE t2.meaning   = t1.ebs_demand_class_code '
 ||'                                    AND sr_instance_id = :p_instance_id '
 ||'                                    AND rownum         = 1 '
 ||'                                  )'
 ||' WHERE NVL(t1.ebs_demand_class_sr_pk,'||''''||NULL_CHAR||''''||') '
 ||'                       =             '||''''||NULL_CHAR||'''';



     IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id;


EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('An error occured while generating Source Keys for Entity - '||l_entity_name);

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_WARNING;
END;


BEGIN
l_entity_name := 'BASE MODEL';

v_sql_stmt := 06;
lv_sql_stmt :=
 ' UPDATE  '||l_schema_name||'.'||'t_src_sales_tmpl  t1 '
 ||' SET t1.ebs_base_model_sr_pk = ( SELECT t2.sr_inventory_item_id '
 ||'                           FROM msc_system_items t2 '
 ||'                           WHERE t2.plan_id         = -1 '
 ||'                           AND   t2.sr_instance_id  =  :p_instance_id '
 ||'                           AND   t2.item_name       = t1.ebs_base_model_code '
 ||'		               AND   t2.organization_id = ( SELECT t3.sr_tp_id '
 ||'						            FROM msc_trading_partners t3 '
 ||'						            WHERE t3.partner_type      = 3 '
 ||'						            AND   t3.organization_code = t1.dm_org_code '
 ||'						            AND   t3.sr_instance_id    =  :p_instance_id '
 ||'	                                              )'
 ||'			     )'
 ||' WHERE t1.ebs_base_model_code IS NOT NULL ';

      IF v_debug THEN
        LOG_MESSAGE(lv_sql_stmt);
      END IF;

      EXECUTE IMMEDIATE lv_sql_stmt
              USING     p_instance_id,
                        p_instance_id;


EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('An error occured while generating Source Keys for Entity - '||l_entity_name);

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_WARNING;
END;


commit;

/* Insert dummy rows in the staging table for new items */
msd_dem_common_utilities.log_debug ('Begin Insert dummy rows for new items into the staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

msd_dem_collect_history_data.insert_dummy_rows (
								errbuf,
								retcode,
								'T_SRC_SALES_TMPL',
								p_instance_id);

IF (retcode = 1)
THEN
   msd_dem_common_utilities.log_message ('Warning(1): msd_dem_process_sales_data.launch - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
   msd_dem_common_utilities.log_message ('Error while inserting dummy rows into the sales staging table for new items. ');
END IF;


msd_dem_common_utilities.log_debug ('End Insert dummy rows for new items into the staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));


--Final commit
commit;

/* Get the sales staging table name */  -- syenamar    Bug#6459492
l_dest_table := msd_dem_common_utilities.get_lookup_value('MSD_DEM_DM_STAGING_TABLES','SALES_STAGING_TABLE');

IF (l_dest_table is NULL)
THEN
    RETCODE := -1;
    ERRBUF  := 'Unable to find the sales staging tables.';
    msd_dem_common_utilities.log_message ('MSD_DEM_PROCESS_SALES_DATA.LAUNCH - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
    msd_dem_common_utilities.log_message (ERRBUF);
    RETURN;
END IF;

IF (l_schema_name <> 'MSD' ) then -- BUG#8367504 nallkuma

msd_dem_common_utilities.log_debug ('Begin: Delete from sales staging table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

/* Truncate the sales staging table */
msd_dem_common_utilities.log_debug ('Deleting data from ERR table - ' || l_dest_table ||'_err');
lv_sql_stmt := 'TRUNCATE TABLE ' || l_dest_table ||'_err';
EXECUTE IMMEDIATE lv_sql_stmt;

msd_dem_common_utilities.log_debug ('End: Delete from ERR table - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));  -- syenamar

End if;

LOG_MESSAGE ('***************** Exiting from the procedure - LAUNCH **********');

EXCEPTION
  WHEN OTHERS THEN
      LOG_MESSAGE ('Error generating Source Keys');

      lv_error_text    := substr('MSD_DEM_PROCESS_SALES_DATA.LAUNCH '||'('
                       ||v_sql_stmt||')'|| SQLERRM, 1, 240);
      LOG_MESSAGE(lv_error_text);

      ERRBUF  := lv_error_text;
      RETCODE := G_ERROR;

END LAUNCH;

END MSD_DEM_PROCESS_SALES_DATA;

/
