--------------------------------------------------------
--  DDL for Package Body MSD_PULL_LEVEL_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_PULL_LEVEL_VALUES" AS
/* $Header: msdplvlb.pls 120.3 2006/07/12 05:48:40 sjagathe noship $ */

--Constants
   C_YES        CONSTANT NUMBER := 1;
   C_NO         CONSTANT NUMBER := 2;

  -- v_launched_from    NUMBER   := to_number(NULL);    --jarorad

Procedure ins( a in varchar2) is
Begin
/* Enabled for Debugging only
  insert into msd_test values ('VM' || to_char(sysdate, 'hh24:mi') || ' ' || a);
  commit;
*/
  null;
End;

procedure pull_level_values_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_comp_refresh      IN  NUMBER) IS
                       -- ,p_launched_from     IN NUMBER DEFAULT NULL) IS   --jarorad
x_source_table   VARCHAR2(50) := MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE ;
x_dest_table     VARCHAR2(50) := MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE ;
x_instance	VARCHAR2(40) := '';
x_level_id	NUMBER := 0;
v_sql_stmt       varchar2(4000);
g_retcode        varchar2(5) := '0';

l_seq_num      NUMBER := 0;

/* OPM Comment Rajesh Patangya */
x_delete_flag   VARCHAR2(1);

/******************************************************
  Cursor to get distinct Instance, Max Data and Min Date
******************************************************/
/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
/* PBI Fix Bug 3840123. Cursor with order by that included level id
 * failed on 8i environment. Removed order by.
 *
 *
 *    MAINTAIN ORDER OF COLUMNS.
 *
 */

Cursor  Relationship is
select  distinct
	mla.instance,
        ml.level_type_code,
	mla.level_id,
	mla.parent_level_id
from    msd_st_level_associations mla, msd_levels ml
where   mla.level_id = ml.level_id AND
        mla.instance <> '0'
and ml.plan_type is null                                       --vinekuma
/* Bug no 3799518. Enable load of level_org_asscns in legacy load as stand alone */
union
select distinct
       mla.instance,
       ml.level_type_code,
       mla.level_id,
       mla.parent_level_id
  from msd_level_associations mla,
       msd_levels ml
 where mla.level_id = ml.level_id
   and ml.plan_type is null                                     --vinekuma
   and exists (select 1
                 from msd_st_level_org_asscns mlo
                where mla.instance = mlo.instance
                  and mla.level_id = mlo.level_id
                  and mlo.instance <> '0'
                  and rownum < 2);

/* Cursor for level cleanup */
/* DWK. Fix Bug 2220983. Do not include instance = '0' in the cursor */
Cursor  Level_Cursor is
select  distinct
	mla.instance,
	mla.level_id,
        ml.level_type_code
from    msd_st_level_associations mla, msd_levels ml
where   mla.level_id = ml.level_id AND
        mla.instance <> '0' AND
        ml.plan_type is null                                     --vinekuma

order by instance, level_type_code, mla.level_id;

Begin

	retcode :=0;

	-- v_launched_from := nvl(p_launched_from,C_DP);            --jarorad

        IF (nvl(p_comp_refresh, C_YES) = C_NO) THEN
            x_delete_flag := 'N';
        ELSE
            x_delete_flag := 'Y';
        END IF;


        /* DWK  Fetch new seq number for deleted level values */
        SELECT msd.msd_last_refresh_number_s.nextval
        INTO l_seq_num from dual;



        For Relationship_Rec IN Relationship LOOP

	  if (Relationship_Rec.instance = x_instance AND Relationship_Rec.level_id = x_level_id) then

                ins('Going to Translate 1: ' || relationship_rec.level_id || ' ' ||
                     relationship_rec.parent_level_id );


                MSD_TRANSLATE_LEVEL_VALUES.translate_level_parent_values(
                        errbuf              	=> errbuf,
                        retcode             	=> retcode,
                        p_source_table      	=> x_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_instance_id       	=> Relationship_Rec.instance,
                        p_level_id              => Relationship_Rec.level_id,
                        p_level_value_column    => MSD_COMMON_UTILITIES.LEVEL_VALUE_COLUMN,
                        p_level_value_pk_column => MSD_COMMON_UTILITIES.LEVEL_VALUE_PK_COLUMN,
                        p_level_value_desc_column => MSD_COMMON_UTILITIES.LEVEL_VALUE_DESC_COLUMN,
                        p_parent_level_id       => Relationship_Rec.parent_level_id,
                        p_parent_value_column   => MSD_COMMON_UTILITIES.PARENT_LEVEL_VALUE_COLUMN,
                        p_parent_value_pk_column => MSD_COMMON_UTILITIES.PARENT_LEVEL_VALUE_PK_COLUMN,
                        p_parent_value_desc_column => MSD_COMMON_UTILITIES.PARENT_LEVEL_VALUE_DESC_COLUMN,
			p_update_lvl_table	=> 0,
			/* OPM Comment Rajesh Patangya */
                        p_delete_flag           => x_delete_flag,
                        p_seq_num               => l_seq_num
                        --,p_launched_from         => v_launched_from          --jarorad
 			) ;

                --update return code
                if nvl(retcode,'0') <> '0' then
                  g_retcode := retcode;
                end if;

ins('RETCODE ' || retcode || ' ' || Relationship_Rec.level_id || ' ' ||
Relationship_Rec.parent_level_id);
		if (nvl(retcode,0) =  0 ) then

			Delete from msd_st_level_associations
			where   instance = Relationship_Rec.instance
                        and     level_id = Relationship_Rec.level_id
                        and     parent_level_id = Relationship_Rec.parent_level_id ;

		end if ;

		commit ;

	  else


                MSD_TRANSLATE_LEVEL_VALUES.translate_level_parent_values(
                        errbuf              	=> errbuf,
                        retcode             	=> retcode,
                        p_source_table      	=> x_source_table,
                        p_dest_table        	=> x_dest_table,
                        p_instance_id       	=> Relationship_Rec.instance,
                        p_level_id              => Relationship_Rec.level_id,
                        p_level_value_column    => MSD_COMMON_UTILITIES.LEVEL_VALUE_COLUMN,
                        p_level_value_pk_column => MSD_COMMON_UTILITIES.LEVEL_VALUE_PK_COLUMN,
                        p_level_value_desc_column => MSD_COMMON_UTILITIES.LEVEL_VALUE_DESC_COLUMN,
                        p_parent_level_id       => Relationship_Rec.parent_level_id,
                        p_parent_value_column   => MSD_COMMON_UTILITIES.PARENT_LEVEL_VALUE_COLUMN,
                        p_parent_value_pk_column => MSD_COMMON_UTILITIES.PARENT_LEVEL_VALUE_PK_COLUMN,
                        p_parent_value_desc_column => MSD_COMMON_UTILITIES.PARENT_LEVEL_VALUE_DESC_COLUMN,
			p_update_lvl_table	=> 1,
			/* OPM Comment Rajesh Patangya */
                        p_delete_flag           => x_delete_flag,
                        p_seq_num               => l_seq_num
                        --,p_launched_from         => v_launched_from  --jarorad
 			) ;


                -- update return code
                if nvl(retcode,'0') <> '0' then
                  g_retcode := retcode;
                end if;

		if (nvl(retcode,0) = 0 ) then


			Delete 	from msd_st_level_values
			where  	instance = Relationship_Rec.instance
			and	level_id = Relationship_Rec.level_id ;

			Delete from msd_st_level_associations
			where   instance = Relationship_Rec.instance
                        and     level_id = Relationship_Rec.level_id
                        and     parent_level_id = Relationship_Rec.parent_level_id ;

		end if ;
		commit ;

	  end if;

	  x_instance := Relationship_Rec.instance;
	  x_level_id := Relationship_Rec.level_id;

	End Loop ;

        /* DWK. Cleanup deleted level value table after pull */
        msd_translate_level_values.clean_deleted_level_values( errbuf, retcode);

	For Level_Rec IN Level_Cursor LOOP
	   MSD_COLLECT_LEVEL_VALUES.fix_orphans(Level_Rec.instance,
                       Level_Rec.level_id,
                       MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE,
                       MSD_COMMON_UTILITIES.LEVEL_ASSOC_FACT_TABLE,
                       null);
	end loop;


	Delete 	from msd_st_level_values
	where  	level_id in (
		select level_id
		from msd_levels
		where level_type_code = '1'
		and plan_type is null) ;                               --vinekuma


        /* esubrama - Supersession Data pull  */
        msd_item_relationships_pkg.pull_supersession_data (
                                       errbuf => errbuf,
                                       retcode => retcode );


        -- done
        retcode := g_retcode;


        commit;

        /* Added by esubrama */
        MSD_ANALYZE_TABLES.analyze_table(null,2);
        MSD_ANALYZE_TABLES.analyze_table(null,1);

	exception
	  when others then
		errbuf := substr(SQLERRM,1,150);
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));
		retcode := -1 ;


End pull_level_values_data ;


END ;

/
