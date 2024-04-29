--------------------------------------------------------
--  DDL for Package Body MSD_COLLECT_LEVEL_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_COLLECT_LEVEL_VALUES" AS
/* $Header: msdclvlb.pls 120.4 2006/09/18 05:53:19 sjagathe noship $ */

--v_launched_from    NUMBER   := to_number(NULL); --jarorad

/* Private Procedure */

procedure log_debug( pBUFF  in varchar2)
 is
 begin

         if C_MSC_DEBUG = 'Y' then
            fnd_file.put_line( fnd_file.log, pBUFF);
         else
            null;
            --dbms_output.put_line( pBUFF);
         end if;

 end log_debug;

 PROCEDURE LOG_MESSAGE( pBUFF           IN  VARCHAR2)
 IS
 BEGIN

            FND_FILE.PUT_LINE( FND_FILE.LOG, pBUFF);

 END LOG_MESSAGE;

Procedure  Delete_duplicate(p_instance_id in number, p_dest_table in varchar2);

Procedure Delete_Childless_Parent_All (	errbuf              OUT NOCOPY VARCHAR2,
					retcode             OUT NOCOPY VARCHAR2,
					p_instance          in  VARCHAR2);

Procedure Delete_Childless_Parent (
					errbuf              OUT NOCOPY VARCHAR2,
					retcode             OUT NOCOPY VARCHAR,
					p_instance_id       in number,
					p_level_id          in number);
				--	p_dest_table        in varchar2);   Bug# 4919130 - Always delete childless parents from staging table.



/* Public Procedures */

/* The wrapper program that is called from the concurrent program */
procedure collect_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_collection_type   IN  VARCHAR2,
                        p_collection_var    IN  VARCHAR2) IS
                      --  ,p_launched_from     IN NUMBER DEFAULT NULL) IS   --jarorad



begin
	 retcode := 0 ;

	  --v_launched_from := nvl(p_launched_from,C_DP); --jarorad

        /* Check and push setup parameters if it is not done so previously */
        MSD_PUSH_SETUP_DATA.chk_push_setup(   errbuf,
                                              retcode,
                                              p_instance_id);
        IF (nvl(retcode, 0) <> 0) THEN
           return;
        END IF;


	 IF ( nvl(p_collection_type, MSD_COMMON_UTILITIES.COLLECT_ALL) =
                MSD_COMMON_UTILITIES.COLLECT_ALL ) then

		collect_all_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id);

	 ELSIF ( p_collection_type = MSD_COMMON_UTILITIES.COLLECT_DP ) then

		collect_demand_plan_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_demand_plan_id    => to_number(p_collection_var) );


	elsif ( p_collection_type = MSD_COMMON_UTILITIES.COLLECT_DIMENSION ) then

		collect_dimension_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_dimension_code    => p_collection_var);


	elsif ( p_collection_type = MSD_COMMON_UTILITIES.COLLECT_HIERARCHY ) then

		collect_hierarchy_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_hierarchy_id      => to_number(p_collection_var) );

        elsif ( p_collection_type = MSD_COMMON_UTILITIES.COLLECT_LEVEL ) then

		collect_level_data(
                        errbuf              => errbuf,
                        retcode             => retcode,
                        p_instance_id       => p_instance_id,
                        p_level_id          => to_number(p_collection_var));

	end if ;



        /* Added logic to delete duplicate data */
        Delete_duplicate(p_instance_id, MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE);

        /* Delete duplicate level association from staging table */
        Delete_duplicate_lvl_assoc(errbuf, retcode, p_instance_id);

        /* esubrama - Item Supersession Collection
        msd_item_relationships_pkg.collect_supersession_data (
                                           errbuf => errbuf,
                                           retcode => retcode,
                                           p_instance_id => p_instance_id );
        */

        /* Analyze staging table after collection */
        MSD_ANALYZE_TABLES.analyze_table(null,1);


        /* IF this is one step collection then
           call PULL internally and execute 2 step collection */

        IF (fnd_profile.value('MSD_ONE_STEP_COLLECTION') = 'Y') THEN
            msd_pull_level_values.pull_level_values_data( errbuf => errbuf,
                                                          retcode => retcode,
                                                          p_comp_refresh => 1);
        END IF;

        Commit;

EXCEPTION

	   WHEN others THEN
	      BEGIN
		Delete_duplicate(p_instance_id ,
                                 MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE);
                Delete_duplicate_lvl_assoc(errbuf, retcode, p_instance_id);
		COMMIT;
	      EXCEPTION
		   WHEN others THEN
		      retcode := -1;
		      errbuf := substr(SQLERRM,1,150);
	      END;
	      retcode := -1 ;
	      errbuf := substr(SQLERRM,1,150);


End collect_data ;

procedure collect_level_parent_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_level_id          IN  NUMBER,
                        p_parent_level_id   IN  NUMBER,
			p_update_lvl_table  IN  NUMBER) IS
x_statement VARCHAR2(2000) := NULL ;
x_view_name VARCHAR2(40) := NULL ;
x_dblink  VARCHAR2(128);
x_direct_load_profile  boolean;
x_source_table  VARCHAR2(50) ;
x_dest_table    varchar2(50) ;
v_lvl_type	varchar2(1);
v_dest_ass_table    varchar2(240) ;
v_sql_stmt       varchar2(4000);

/* OPM Comment Rajesh Patangya   */
x_delete_flag   varchar2(1) := 'Y' ;
o_source_table  VARCHAR2(50) := NULL ;
o_dblink         varchar2(128);
o_icode          varchar2(128);
o_retcode        number;
o_instance_type  number;
o_dgmt           number;
o_apps_ver       number;
o_dimension_code  VARCHAR2(10) := 'XXXX' ;


/* DWK  new variable for error report */
p_level_name         VARCHAR2(30);
p_parent_level_name  VARCHAR2(30);
p_hierarchy_name     VARCHAR2(30);

p_seq_num   NUMBER;

/************************************************************************
  Cursor to get distinct relationship view and the corresponding columns
*************************************************************************/
/* DWK  Include hierarchy_id in this cursor.  We need hierarchy_id info
   for reporting error when there is no relationship_view defined */
Cursor 	Relationship (p_level_id in number, p_parent_level_id in number) is
select  distinct
	hierarchy_id,
	relationship_view,
        level_value_column,
        level_value_pk_column,
        nvl(level_value_desc_column,level_value_column) level_value_desc_column,
        parent_value_column,
        parent_value_pk_column,
        nvl(parent_value_desc_column, parent_value_column) parent_value_desc_column
from 	msd_hierarchy_levels
where 	level_id = p_level_id
and    	parent_level_id = p_parent_level_id
and     plan_type is null; --vinekuma

  g_retcode varchar2(5) := '0';

Begin

    log_debug('In procedure COLLECT_LEVEL_PARENT_DATA');

	/***********************************************************
	*	1. Get the DB Link for the Instance ID
	*	2. Get the Profile MSD_ONE_STEP_COLLECTION to find out
	*	   which table to insert into - whether the staging
	*	   table or the fact table
	*	3. Get the view that hold the association and the
	*	   corresponding column names.
	*	4. Set the Save Point and delete the already existing
	*	   data in the level values are the staging table.
	*	5. Insert the new values from the association views
	*	6. Commit
	************************************************************/

        retcode :=0;


        msd_common_utilities.get_db_link(p_instance_id, x_dblink, retcode);
        if (retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting db_link';
                --dbms_output.put_line('Error while getting db_link');
                return;
        end if;


        /* OPM Comment By Rajesh Patangya   */
        msd_common_utilities.get_inst_info(p_instance_id, o_dblink, o_icode,
                o_apps_ver, o_dgmt, o_instance_type, o_retcode)  ;
        if (o_retcode = -1) then
                retcode :=-1;
                errbuf := 'Error while getting instance_info';
                return;
        end if;


        /* DWK  Always 2 step collection */
        x_dest_table := MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE ;
        v_dest_ass_table := MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE;


	/* DWK  Relationship LOOP */
        For Relationship_Rec IN Relationship(p_level_id, p_parent_level_id) LOOP
        log_debug('In Cursor Relationship');

	   /* DWK  Check whether relationship_view is NULL or not.
	      IF NULL then give WARNING message and go to the next cursor.
	      Do not try to translate level values if the relationship_view is NULL */

	   /* DWK   Begining of IF 1 */
	   IF ( Relationship_Rec.relationship_view IS NULL ) THEN

	      log_debug('Error Condition : Relationship View is Null');
	      SELECT hierarchy_name INTO p_hierarchy_name
	      FROM   msd_hierarchies
	      WHERE  hierarchy_id = Relationship_Rec.hierarchy_id
	      AND    plan_type is null; --vinekuma

              p_level_name := MSD_COMMON_UTILITIES.get_level_name(p_level_id);
	      p_parent_level_name := MSD_COMMON_UTILITIES.get_level_name(p_parent_level_id);

	      fnd_file.put_line(fnd_file.log, ' ');
              fnd_file.put_line(fnd_file.log, 'Relationship view is not defined for ' ||
                               'Hierarchy : '|| p_hierarchy_name || '.  (No Data Collected.)');
              fnd_file.put_line(fnd_file.log, '     Level        : ' || p_level_name );
              fnd_file.put_line(fnd_file.log, '     Parent Level : ' || p_parent_level_name );

	   /*  DWK.  IF we have relationship_view name then proceed the following codes */
	   ELSE

               x_source_table := Relationship_Rec.relationship_view || x_dblink ;

	      /* OPM Comment Rajesh Patangya */
              IF (o_instance_type in (2,4) AND o_apps_ver = 3) THEN
                 msd_common_utilities.get_dimension_code (p_level_id,
                                                      o_dimension_code,
                                                      o_retcode );
                 IF (o_retcode = -1) THEN
                       log_debug('Error Condition : Error while getting dimension Code');
                       retcode := -1;
                       errbuf := 'Error while getting dimension code';
                       return;
                 END IF;
              END IF;

              /* For a process 11i instance, call translate to extract   */
              /* process organizations only create source table name     */

              IF (o_dimension_code = 'ORG' and o_instance_type = 2  AND o_apps_ver = 3) THEN
		 o_source_table := REPLACE(x_source_table , 'MSD','GMP') ;
		 x_source_table := o_source_table;

	      END IF;

              log_debug('Calling procedure TRANSLATE_LEVEL_PARENT_VALUE');
              MSD_TRANSLATE_LEVEL_VALUES.translate_level_parent_values(
                        errbuf                     => errbuf,
                        retcode                    => retcode,
                        p_source_table             => x_source_table,
                        p_dest_table               => x_dest_table,
                        p_instance_id              => p_instance_id,
                        p_level_id                 => p_level_id,
                        p_level_value_column       => Relationship_Rec.level_value_column,
                        p_level_value_pk_column    => Relationship_Rec.level_value_pk_column,
                        p_level_value_desc_column  => Relationship_Rec.level_value_desc_column,
                        p_parent_level_id          => p_parent_level_id,
                        p_parent_value_column      => Relationship_Rec.parent_value_column,
                        p_parent_value_pk_column   => Relationship_Rec.parent_value_pk_column,
                        p_parent_value_desc_column => Relationship_Rec.parent_value_desc_column,
			p_update_lvl_table         => p_update_lvl_table,
			/* OPM Comment Rajesh Patangya */
                        p_delete_flag              => x_delete_flag,
                        p_seq_num                  => p_seq_num );
                       -- ,p_launched_from            => v_launched_from);  --jarorad

                --update return code
              IF retcode <> '0' THEN
                 g_retcode := retcode;
              END IF;

	      /* For a discrete process 11i instance, call translate again to extract   */
              /* process organizations only                                         */
	      /* DWK    Beginning of IF 2 */
              IF (o_dimension_code = 'ORG' AND o_instance_type = 4 AND o_apps_ver = 3) THEN
                 o_source_table := REPLACE(x_source_table , 'MSD','GMP') ;
                 x_source_table := o_source_table ;
                 x_delete_flag   := 'N' ;

                 log_debug('Calling procedure TRANSLATE_LEVEL_PARENT_VALUE for process 11i instance, for process orgs ');
                 MSD_TRANSLATE_LEVEL_VALUES.translate_level_parent_values(
                        errbuf                     => errbuf,
                        retcode                    => retcode,
                        p_source_table             => x_source_table,
                        p_dest_table               => x_dest_table,
                        p_instance_id              => p_instance_id,
                        p_level_id                 => p_level_id,
                        p_level_value_column       => Relationship_Rec.level_value_column,
                        p_level_value_pk_column    => Relationship_Rec.level_value_pk_column,
                        p_level_value_desc_column  => Relationship_Rec.level_value_desc_column,
                        p_parent_level_id          => p_parent_level_id,
                        p_parent_value_column      => Relationship_Rec.parent_value_column,
                        p_parent_value_pk_column   => Relationship_Rec.parent_value_pk_column,
                        p_parent_value_desc_column => Relationship_Rec.parent_value_desc_column,
			p_update_lvl_table         => p_update_lvl_table,
			/* OPM Comment Rajesh Patangya */
                        p_delete_flag              => x_delete_flag,
                        p_seq_num                  => p_seq_num );
                       -- ,p_launched_from            => v_launched_from);  --jarorad

		 /* OPM Comment Rajesh Patangya */
		 o_source_table  := NULL ;

                 --update return code
                 IF retcode <> '0' THEN
                   g_retcode := retcode;
                 END IF;

	      END IF;     /* DWK  End of IF 2 */
           END IF;	  /* DWK  End of IF 1 */
	End LOOP ;        /* DWK  End of Relationship LOOP */

        retcode := g_retcode;

        log_debug('Exiting procedure COLLECT_LEVEL_PARENT_DATA');

	exception

	   when others then
	        retcode := -1 ;
                errbuf := substr(SQLERRM,1,150);
--              insert into msd_test values('Error: ' || errbuf) ;

End collect_level_parent_data ;


procedure collect_level_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	    IN  NUMBER,
                        p_level_id          IN  NUMBER ) IS
/* lvl_table needs to be updated only once - this is the indicator */
x_update_lvl_table NUMBER := 1;
g_retcode varchar2(5) := '0';

/******************************************************
  Cursor to get distinct Level, Parent Combinations
******************************************************/
Cursor Level_Parent(p_level_id IN NUMBER) is
select distinct level_id, parent_level_id, level_type_code
from msd_hierarchy_levels_v
where level_id = p_level_id
order by level_type_code, level_id;
Begin

  log_debug('In procedure COLLECT_LEVEL_DATA');
  log_debug('Level ID   :'||p_level_id);


  For Level_Parent_Rec IN Level_Parent(p_level_id) LOOP

	log_debug('Parent Level ID   :'||Level_Parent_Rec.parent_level_id);
	collect_level_parent_data(
		errbuf => errbuf,
		retcode => retcode,
		p_instance_id => p_instance_id,
		p_level_id => p_level_id,
		p_parent_level_id => Level_Parent_Rec.parent_level_id,
		p_update_lvl_table => x_update_lvl_table);

	x_update_lvl_table := 0;

        --update return code
        if retcode <> '0' then
          g_retcode := retcode;
        end if;

  end loop;

  /* zia bug #1610855: Fix parentless children */
  fix_orphans(p_instance_id, p_level_id,
              MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE,
              MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE,
              null);

  /* Bug# 5530511 - Delete_Childless_Parent_All should be called after
   *                the call to fix_orphans
   */
  Delete_Childless_Parent_All (	errbuf, retcode, p_instance_id);

  retcode := g_retcode;

  commit ;

  /* esubrama - Item Supersession Collection */
  if (p_level_id = 1) then

     msd_item_relationships_pkg.collect_supersession_data (
                                           errbuf => errbuf,
                                           retcode => retcode,
                                           p_instance_id => p_instance_id );
  end if;

  log_debug('Exiting procedure COLLECT_LEVEL_DATA');

End collect_level_data ;

procedure collect_hierarchy_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_hierarchy_id      IN  NUMBER) IS
x_level_id NUMBER := 0;
/******************************************************
  Cursor to get Distinct Level Parent Combination in
  a hierarchy
******************************************************/
Cursor Hierarchy_Levels(p_hierarchy_id IN NUMBER) is
select level_id, parent_level_id, level_type_code
from msd_hierarchy_levels_v
where hierarchy_id = p_hierarchy_id
order by level_type_code, level_id;

/* Cursor to get distinct levels in the hierarchy */
Cursor Level_Cursor(p_hierarchy_id IN NUMBER) is
select distinct level_id, level_type_code
from msd_hierarchy_levels_v
where hierarchy_id = p_hierarchy_id
order by level_type_code, level_id;

Cursor hierarcy_dimension(p_hierarchy_id IN NUMBER) is
select distinct OWNING_DIMENSION_CODE
from msd_hierarchy_levels_v
where hierarchy_id = p_hierarchy_id;

l_dim_code varchar(5) := null;
g_retcode varchar2(5) := '0';

Begin

   For Hierarchy_Levels_Rec IN Hierarchy_Levels (p_hierarchy_id) LOOP

      if (x_level_id = Hierarchy_Levels_Rec.level_id) then

         collect_level_parent_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
                p_level_id => Hierarchy_Levels_Rec.level_id,
		p_parent_level_id => Hierarchy_Levels_Rec.parent_level_id,
		p_update_lvl_table => 0);

      else

        collect_level_parent_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
                p_level_id => Hierarchy_Levels_Rec.level_id,
		p_parent_level_id => Hierarchy_Levels_Rec.parent_level_id,
		p_update_lvl_table => 1);

      end if;


      x_level_id := Hierarchy_Levels_Rec.level_id;

      --update return code
      if retcode <> '0' then
         g_retcode := retcode;
      end if;

   end loop ;

   For Level_Rec IN Level_Cursor (p_hierarchy_id) LOOP
      /* zia bug #1610855: Fix parentless children */
      fix_orphans(p_instance_id, Level_Rec.level_id,
                  MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE,
                  MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE,
                  p_hierarchy_id);
   end loop;

  /* Bug# 5530511 - Delete_Childless_Parent_All should be called after
   *                the call to fix_orphans
   */
   Delete_Childless_Parent_ALL ( errbuf, retcode, p_instance_id);



   /* esubrama - Item Supersession Collection */
   open hierarcy_dimension(p_hierarchy_id);
   fetch hierarcy_dimension into l_dim_code;
   close hierarcy_dimension;

   if (l_dim_code = 'PRD') then

      msd_item_relationships_pkg.collect_supersession_data (
                                           errbuf => errbuf,
                                           retcode => retcode,
                                           p_instance_id => p_instance_id );
   end if;

   retcode := g_retcode;

End collect_hierarchy_data ;


procedure collect_dimension_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_dimension_code    IN  VARCHAR2) IS

x_level_id NUMBER := 0;
/******************************************************
  Cursor to get distinct level parent combinations
  in a dimension
******************************************************/
Cursor Dim_Level_Parent(p_dimension_code IN VARCHAR2) is
select distinct level_id, parent_level_id, level_type_code
from msd_hierarchy_levels_v
where owning_dimension_code = p_dimension_code
order by level_type_code, level_id;

/* Cursor to get levels alone */
Cursor Level_Cursor(p_dimension_code IN VARCHAR2) is
select distinct level_id, level_type_code
from msd_hierarchy_levels_v
where owning_dimension_code = p_dimension_code
order by level_type_code, level_id;

g_retcode varchar2(5) := '0';

Begin

   For Dim_Level_Parent_Rec IN Dim_Level_Parent (p_dimension_code) LOOP


      if (x_level_id = Dim_Level_Parent_Rec.level_id) then

         collect_level_parent_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
                p_level_id => Dim_Level_Parent_Rec.level_id,
		p_parent_level_id => Dim_Level_Parent_Rec.parent_level_id,
		p_update_lvl_table => 0);

      else
         collect_level_parent_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
                p_level_id => Dim_Level_Parent_Rec.level_id,
		p_parent_level_id => Dim_Level_Parent_Rec.parent_level_id,
		p_update_lvl_table => 1);

      end if;

      x_level_id := Dim_Level_Parent_Rec.level_id;


       --update return code
       if retcode <> '0' then
          g_retcode := retcode;
       end if;

   end loop ;

   For Level_Rec IN Level_Cursor(p_dimension_code) LOOP

      /* zia bug #1610855: Fix parentless children */
      fix_orphans(p_instance_id, Level_Rec.level_id,
                  MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE,
                  MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE,
                  null);
   end loop;

  /* Bug# 5530511 - Delete_Childless_Parent_All should be called after
   *                the call to fix_orphans
   */
   Delete_Childless_Parent_ALL ( errbuf, retcode, p_instance_id);


      /* esubrama - Item Supersession Collection */
      if (p_dimension_code = 'PRD') then

         msd_item_relationships_pkg.collect_supersession_data (
                                           errbuf => errbuf,
                                           retcode => retcode,
                                           p_instance_id => p_instance_id );
      end if;

   retcode := g_retcode;

End collect_dimension_data ;


procedure collect_dp_dimension_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_demand_plan_id    IN  NUMBER,
                        p_dimension_code    IN  VARCHAR2) IS
/******************************************************
  Cursor to get distinct owning dimensions in a dp dimension
******************************************************/
Cursor Dp_Dim_Dimensions(p_dimension_code IN VARCHAR2) is
select distinct owning_dimension_code
from msd_dp_hierarchies_v
where demand_plan_id = p_demand_plan_id
and   dp_dimension_code = p_dimension_code ;

g_retcode varchar2(5) := '0';

Begin

   For Dp_Dim_Dimensions_Rec IN Dp_Dim_Dimensions (p_dimension_code) LOOP

        collect_dimension_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
                p_dimension_code =>
		    Dp_Dim_Dimensions_Rec.owning_dimension_code);

       --update return code
       if retcode <> '0' then
          g_retcode := retcode;
       end if;

   end loop ;

   retcode := g_retcode;

End collect_dp_dimension_data ;


procedure collect_demand_plan_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_demand_plan_id    IN  NUMBER) IS

/******************************************************
  Cursor to get DP_Dimensions in a demand plan
******************************************************/
Cursor Dp_Dimensions(p_demand_plan_id IN NUMBER) is
select distinct dp_dimension_code
from msd_dp_hierarchies_v
where demand_plan_id = p_demand_plan_id ;

g_retcode varchar2(5) := '0';

Begin

   For Dp_Dimensions_Rec IN Dp_Dimensions (p_demand_plan_id) LOOP

        collect_dp_dimension_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
		p_demand_plan_id => p_demand_plan_id,
                p_dimension_code => Dp_DimensionS_Rec.dp_dimension_code);


       --update return code
       if retcode <> '0' then
          g_retcode := retcode;
       end if;

   end loop ;

   retcode := g_retcode;

End collect_demand_plan_data ;


procedure collect_all_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER) IS
/******************************************************
  Cursor to get ALL Dimensions
******************************************************/
Cursor Dimensions is
select lookup_code
from fnd_lookup_values_vl
where lookup_type = 'MSD_DIMENSIONS' ;

g_retcode varchar2(5) := '0';

Begin

   For Dimensions_Rec IN Dimensions LOOP

        collect_dimension_data(
                errbuf => errbuf,
                retcode => retcode,
                p_instance_id => p_instance_id,
                p_dimension_code => Dimensions_Rec.lookup_code);

       --update return code
       if retcode <> '0' then
          g_retcode := retcode;
       end if;

	/* DWK. Commit for every Dimension, so user can see the progress */
       commit;

   end loop ;

   retcode := g_retcode;

End collect_all_data ;


/**************************************************************
  Procedure to fix parentless level values.

  Should only be called after all level values for a level have
  been inserted in the desination table.
***************************************************************/
procedure fix_orphans(p_instance_id    in number,
                      p_level_id       in number,
                      p_dest_table     in varchar2,
                      p_dest_ass_table in varchar2,
                      p_hierarchy_id   in number) IS

Cursor Parent_Levels(p_lvl_id IN NUMBER) is
select distinct parent_level_id
from msd_hierarchy_levels
where level_id = p_lvl_id
and hierarchy_id = nvl(p_hierarchy_id, hierarchy_id);

v_sql_stmt       varchar2(4000);
v_parent_level_id number;
v_other_pk	VARCHAR2(240);

begin
	   /* zia bug #1610855: Associate parentless
              values with the 'Other' level value at the parent level
	   */

   For Parent_Levels_Rec IN Parent_Levels (p_level_id) LOOP
           /* get pk of 'Other'
	         Note that even though this level value has not yet been inserted
                 into the destination table, it is okay to add an association
                 because the value itself will certainly be added in the next
                 pass over the parent level.
	   */
           v_other_pk := to_char(msd_sr_util.get_null_pk);
           v_parent_level_id :=  Parent_Levels_Rec.parent_level_id;

	   /* Insert association for orphans */
           /* VM Logic : Find orphans using MINUS set between
              records in level_values for Level in consideration and
              records in level_Association for level and parent level in consideration
           */

	   v_sql_stmt := 'insert into ' || p_dest_ass_table || ' (' ||
              'instance, ' ||
              'level_id, ' ||
              'sr_level_pk, ' ||
              'parent_level_id, ' ||
              'sr_parent_level_pk, ' ||
              'last_update_date, ' ||
              'last_updated_by, ' ||
              'creation_date, ' ||
              'created_by ) ' ||
              'select  ''' ||
              p_instance_id ||''', ' ||
              p_level_id || ', ' ||
              'sr_level_pk, ' ||
              v_parent_level_id || ', ''' ||
              v_other_pk || ''', ' ||
              'sysdate, ' ||
              FND_GLOBAL.USER_ID || ', ' ||
              'sysdate, ' ||
              FND_GLOBAL.USER_ID ||
              ' from ' || p_dest_table || ' mlv ' ||
              ' where level_id = ' || p_level_id ||
              '   and instance = ' || p_instance_id ||
              ' minus ' ||
              'select  ''' ||
              p_instance_id ||''', ' ||
              p_level_id || ', ' ||
              'sr_level_pk, ' ||
              v_parent_level_id || ', ''' ||
              v_other_pk || ''', ' ||
              'sysdate, ' ||
              FND_GLOBAL.USER_ID || ', ' ||
              'sysdate, ' ||
              FND_GLOBAL.USER_ID ||
              ' from ' || p_dest_ass_table || ' amlv ' ||
              ' where level_id = ' || p_level_id ||
              '   and instance = ' || p_instance_id ||
              '   and parent_level_id = ' || v_parent_level_id;

 	   -- insert into msd_test values(v_sql_stmt) ;
           EXECUTE IMMEDIATE v_sql_stmt ;
   END LOOP;
END fix_orphans;


FUNCTION get_dest_table return varchar2 IS
  x_direct_load_profile  boolean;
BEGIN
        x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

        if (x_direct_load_profile) then
           return MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE ;
        else
           return MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE ;
        end if;
END get_dest_table;


FUNCTION get_assoc_table return varchar2 IS
  x_direct_load_profile  boolean;
BEGIN
  x_direct_load_profile := (fnd_profile.value('MSD_ONE_STEP_COLLECTION')='Y');

  if (x_direct_load_profile) then
      return MSD_COMMON_UTILITIES.LEVEL_ASSOC_FACT_TABLE ;
  else
      return MSD_COMMON_UTILITIES.LEVEL_ASSOC_STAGING_TABLE;
  end if;
END get_assoc_table;


Procedure  Delete_duplicate(p_instance_id in number, p_dest_table in varchar2) is

lb_FetchComplete  BOOLEAN := FALSE;
ln_rows_to_fetch  Number := nvl(TO_NUMBER(FND_PROFILE.VALUE('MRP_PURGE_BATCH_SIZE')),75000);

 TYPE CharTblTyp IS TABLE OF VARCHAR2(240);
 TYPE NumTblTyp  IS TABLE OF NUMBER;

 lb_level_id              NumTblTyp;
 lb_sr_level_pk           CharTblTyp;
 lb_system_attribute1     CharTblTyp;
 lb_system_attribute2     CharTblTyp;
 lb_dp_enabled_flag       NumTblTyp;

Cursor c_Update_Level_Values
is
select level_id, sr_level_pk,system_attribute1,system_attribute2,dp_enabled_flag
from msd_st_level_values a
where a.instance = p_instance_id
and rowid = ( select max(rowid)
              from msd_st_level_values b
              where a.instance = b.instance
              and a.level_id = b.level_id
              and a.sr_level_pk = b.sr_level_pk
              and b.system_attribute1 is not null);  -- assuming here that if there exist more than one record
                                                     -- with system_attribute1 as not null for same level_value
                                                     -- (i.e same level_id, and sr_level_pk), the the value for
                                                     -- system_attribute1, system_attribute2 and dp_enabled_flag
                                                     -- will be same, in all such records
Begin

/*  BUG# 5383368 - SOP and EOL code cleanup

  -- This piece of code is written as part of SOP Project.We are here populating the all additional
  -- level value attributes collected as part of the SOP.
  -- SOP code changes required to chnage the few hierarchies, whereas certain hierarchies are not got changed
  -- for the level values collected at the same level_id.Now, since delete duplicate code may delete the
  -- record which contains the relevant level_value attributes collected for SOP.


       OPEN  c_Update_Level_Values;
             IF (c_Update_Level_Values%ISOPEN) THEN

                LOOP

                   IF (lb_FetchComplete) THEN
                     EXIT;
                   END IF;

                   FETCH c_Update_Level_Values BULK COLLECT INTO
                                         lb_level_id,
                                         lb_sr_level_pk,
                                         lb_system_attribute1,
                                         lb_system_attribute2,
                                         lb_dp_enabled_flag
                   LIMIT ln_rows_to_fetch;


                   IF (c_Update_Level_Values%NOTFOUND) THEN
                      lb_FetchComplete := TRUE;
                   END IF;


                   if c_Update_Level_Values%ROWCOUNT > 0  then

                         FORALL j IN lb_level_id.FIRST..lb_level_id.LAST
                         update msd_st_level_values
                         set system_attribute1 = lb_system_attribute1(j),
                             system_attribute2 = lb_system_attribute2(j),
                             dp_enabled_flag   = lb_dp_enabled_flag(j)
                         where instance = p_instance_id
                         and   level_id = lb_level_id(j)
                         and   sr_level_pk = lb_sr_level_pk(j)
                         and   system_attribute1 is null;
                         --and   system_attribute2 is null
                         --and   dp_enabled_flag is null ;

                   end if;

                END LOOP;  --LOOP

             END IF;  --IF (c_Update_Level_Values%ISOPEN) THEN
           CLOSE c_Update_Level_Values;

*/

  /* This procedure deletes duplicate records from staging level_values
     Key - Instance + Level_Id  + SR_LEVEL_PK
  */

  if p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE then
    delete from msd_st_level_values a where
    a.instance = p_instance_id and
    rowid <> (select max(rowid) from msd_st_level_values b
              where a.instance = b.instance
              and a.level_id = b.level_id
              and a.sr_level_pk = b.sr_level_pk);
  end if;

End;

Procedure  Delete_duplicate_lvl_assoc( errbuf              OUT NOCOPY VARCHAR2,
                                       retcode             OUT NOCOPY VARCHAR2,
                                       p_instance_id in number) is

cursor c_duplicate is
select level_id, sr_level_pk, parent_level_id
from msd_st_level_associations
where  instance = p_instance_id
group by level_id, sr_level_pk, parent_level_id
having count(*) > 1;

TYPE level_id_tab        is table of msd_st_level_associations.level_id%TYPE;
TYPE sr_level_pk_tab     IS TABLE OF msd_st_level_associations.sr_level_pk%TYPE;

a_child_level_id   level_id_tab;
a_parent_level_id  level_id_tab;
a_sr_level_pk      sr_level_pk_tab;


Begin

  /* This procedure deletes duplicate records from staging level association
     Key - Instance + Child_Level_Id  + SR_LEVEL_PK + Parent_Level_ID
  */

     OPEN  c_duplicate;
     FETCH c_duplicate BULK COLLECT INTO a_child_level_id, a_sr_level_pk, a_parent_level_id ;
     CLOSE c_duplicate;

     IF (a_child_level_id.exists(1)) THEN
        FOR i IN a_child_level_id.FIRST..a_child_level_id.LAST LOOP
           delete from msd_st_level_associations a where
           a.instance = p_instance_id and
           a.level_id = a_child_level_id(i) and
           a.sr_level_pk = a_sr_level_pk(i) and
           a.parent_level_id = a_parent_level_id(i) and
           rowid <> (select rowid from msd_st_level_associations b
                     where b.instance = p_instance_id and
                           b.level_id = a_child_level_id(i) and
                           b.sr_level_pk = a_sr_level_pk(i) and
                           b.parent_level_id = a_parent_level_id(i) and
                           rownum < 2);
        END LOOP;
    END IF;

EXCEPTION
     when others then
                errbuf := substr(SQLERRM,1,150);
                retcode := -1;
                fnd_file.put_line(fnd_file.log, substr(SQLERRM, 1, 1000));


END Delete_duplicate_lvl_assoc;

/*****************************************************************************************
  Procedure Delete_Childless_Parent_ALL

	This procedure will call delete_childless_parent for all level_id and
	instance.

******************************************************************************************/
Procedure Delete_Childless_Parent_ALL (	errbuf              OUT NOCOPY VARCHAR2,
					retcode             OUT NOCOPY VARCHAR2,
					p_instance          in  VARCHAR2) IS

/* Cursor for staging table */
CURSOR c_st_level is
   select distinct a.instance, a.level_id
   from msd_st_level_values a, msd_levels b
   where a.level_id = b.level_id and
   a.instance <> 0 and
   b.level_type_code = 3 and
   a.instance = p_instance;


/* Cursor for fact table */
/* Bug# 4919130 - Always delete childless parents from staging table.
CURSOR c_level is
   select distinct a.instance, a.level_id
   from msd_level_values a, msd_levels b
   where a.level_id = b.level_id and
   a.instance <> 0 and
   b.level_type_code = 3 and
   a.instance = p_instance;

l_dest_table   VARCHAR2(40);
*/


BEGIN

  /* 1 step collection */
  /* Bug# 4919130 - Always delete childless parents from staging table.
  IF (fnd_profile.value('MSD_ONE_STEP_COLLECTION') = 'Y') THEN

     l_dest_table :=  MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE;

     FOR Level_Rec IN c_level LOOP
        Delete_Childless_Parent (	errbuf,
					retcode,
					Level_Rec.instance,
					Level_Rec.level_id,
					l_dest_table);
     END LOOP;
   */
   /* 2 step collection */
   /* Bug# 4919130 - Always delete childless parents from staging table.
   ELSE
     l_dest_table := MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE ;
   */

     FOR Level_Rec IN c_st_level LOOP
        Delete_Childless_Parent (	errbuf,
					retcode,
					Level_Rec.instance,
					Level_Rec.level_id);
				--	l_dest_table);        Bug# 4919130 - Always delete childless parents from staging table.
     END LOOP;
   /* Bug# 4919130 - Always delete childless parents from staging table.
   END IF;
   */


END Delete_Childless_Parent_ALL;





/*****************************************************************************************
  Procedure Delete_Childless_Parent

	This procedure will delete any childless parent level value.
	First, We will determine whether destination talbe is Fact or Staging, then
	Navigate level_value from either (msd_st_level_values or msd_level_values).
	Check whether that level_id exist in level association table as
	parent level id.
	If it does, then navigate next level id, otherwise, delete it.

******************************************************************************************/
Procedure Delete_Childless_Parent (
					errbuf              OUT NOCOPY VARCHAR2,
					retcode             OUT NOCOPY VARCHAR,
					p_instance_id       in number,
					p_level_id          in number) IS
				--	p_dest_table        in varchar2) IS      Bug# 4919130 - Always delete childless parents from staging table.

CURSOR c_childless_parent is
   select level_id, sr_level_pk
   from msd_backup_level_values
   where instance = '-999' and level_pk = -999;

l_count    NUMBER(10) := 0;
l_print_title  BOOLEAN := TRUE;

BEGIN

   /*----------------- Clear msd_backup_level_values table -------------------*/
   delete from msd_backup_level_values
   where instance = '-999' and level_pk = -999;

   /*  For 2 step collection */
   /* Bug# 4919130 - Always delete childless parents from staging table.
   IF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_STAGING_TABLE) THEN
   */

      insert into msd_backup_level_values (instance , level_id, sr_level_pk, level_pk )
                  select '-999' , level_id, sr_level_pk, -999
                  from msd_st_level_values
                  where instance = p_instance_id and level_id = p_level_id
                  minus
                  select '-999' , parent_level_id, sr_parent_level_pk, -999
                  from msd_st_level_associations
                  where instance = p_instance_id and parent_level_id = p_level_id ;

      delete from msd_st_level_values a
      where
        instance = p_instance_id and
        level_id = p_level_id and
	exists (select 1 from msd_backup_level_values b
            where b.instance = '-999' and b.level_id = a.level_id and
            b.sr_level_pk = a.sr_level_pk and level_pk = -999);

   /* For 1 step collection */
   /* Bug# 4919130 - Always delete childless parents from staging table.
   ELSIF (p_dest_table = MSD_COMMON_UTILITIES.LEVEL_VALUES_FACT_TABLE) THEN

      insert into msd_backup_level_values (instance , level_id, sr_level_pk, level_pk )
                  select '-999' , level_id, sr_level_pk, -999
                  from msd_level_values
                  where instance = p_instance_id and level_id = p_level_id
                  minus
                  select '-999' , parent_level_id, sr_parent_level_pk, -999
                 from msd_level_associations
                  where instance = p_instance_id and parent_level_id = p_level_id ;

      delete from msd_level_values a
      where
        instance = p_instance_id and
        level_id = p_level_id and
	exists (select 1 from msd_backup_level_values b
                where b.instance = '-999' and b.level_id = a.level_id and
                b.sr_level_pk = a.sr_level_pk and level_pk = -999);

   END IF;
   */


   /*--------------- Report childless parent to the log file ------------------------*/
   FOR Childless_rec IN c_childless_parent LOOP
      l_count := l_count + 1;

      IF ( l_print_title ) THEN
         fnd_file.put_line(fnd_file.log, ' ');
         fnd_file.put_line(fnd_file.log, 'Following Childless Level Values for Level ID : '||
                                          Childless_rec.level_id || ' were deleted.');
         fnd_file.put_line(fnd_file.log, 'SR Level PK    ' );
         fnd_file.put_line(fnd_file.log, '---------------' );
         l_print_title := FALSE;
      END IF;
      fnd_file.put_line(fnd_file.log, ' ' || Childless_rec.sr_level_pk);

   END LOOP;

   IF (l_count > 0) THEN
      fnd_file.put_line(fnd_file.log, l_count ||' childless level values deleted.' );
   END IF;

   /*------------------------- Clean up msd_backup_level_values table ---------------*/
   delete from msd_backup_level_values
   where level_pk = -999 and instance = '-999';

EXCEPTION
	   when others then
	        retcode := -1 ;
                errbuf := substr(SQLERRM,1,150);
		fnd_file.put_line(fnd_file.log, 'Error in Delete_Childless_Parent.');
                fnd_file.put_line(fnd_file.log,  substr(SQLERRM,1,1000) );

END Delete_Childless_Parent;



END ;

/
