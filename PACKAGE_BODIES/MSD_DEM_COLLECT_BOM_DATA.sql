--------------------------------------------------------
--  DDL for Package Body MSD_DEM_COLLECT_BOM_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSD_DEM_COLLECT_BOM_DATA" AS
/* $Header: msddemcbdb.pls 120.1.12010000.5 2009/06/30 10:43:34 sjagathe noship $ */


   /*** CONSTANTS ***/

      /* Bom Item Types */
      C_MODEL          		CONSTANT NUMBER 	:= 1;
      C_OPTION_CLASS   		CONSTANT NUMBER 	:= 2;
      C_PLANNING       		CONSTANT NUMBER 	:= 3;
      C_STANDARD       		CONSTANT NUMBER 	:= 4;
      C_PRODUCT_FAMILY 		CONSTANT NUMBER 	:= 5;

      /* ATO Forecast Control Options */
      C_CONSUME        		CONSTANT NUMBER 	:= 1;
      C_CONSUME_DERIVE 		CONSTANT NUMBER 	:= 2;
      C_NONE           		CONSTANT NUMBER 	:= 3;

      /* MRP Planning Codes */
      C_NO_PLANNING    		CONSTANT NUMBER 	:= 6;

      /* Initialized Variables */
      C_INIT_VARCHAR2  		CONSTANT VARCHAR2(255) := 'init';
      C_INIT_DATE      		CONSTANT DATE          := sysdate;
      C_INIT_NUMBER    		CONSTANT NUMBER        := 0;

   /*** CONSTANTS ***/


   /* Temp Variables */
   tmp1 		VARCHAR2(100);
   tmp2 		NUMBER;
   tmp3 		NUMBER;
   tmp4         DATE;

   /* Option Class Parents Stack*/
   oc_parents          PARENTS;

   /* Model Parents Stack*/
   mo_parents          PARENTS;


   /*** PRIVATE PROCEDURES ***
    *
    * get_bom_item_type
    * get_all_parents
    * debug_line
    *
    *** PRIVATE PROCEDURES  ***/




   /* Determines Bom Type for a given Item
    * Given the following :
    *
    * (1) Instance, (2) Source Org Pk, (3) Source Inventory Item Id
    *
    * Returns: 1 - Model
    *          2 - Option Class
    *          3 - Standard
    *          4 - Planning
    *          5 - Product Family
    *
    */
   PROCEDURE GET_BOM_ITEM_TYPE(
  		p_answer               	IN OUT 	NOCOPY 		NUMBER,
  		p_instance             	IN     			VARCHAR2,
  		p_sr_org_pk            	IN     			VARCHAR2,
  		p_sr_inventory_item_pk 	IN     			VARCHAR2)
      IS
         CURSOR c1 IS
            SELECT bom_item_type
               FROM msc_system_items
               WHERE  sr_instance_id = p_instance
                  AND organization_id = p_sr_org_pk
                  AND inventory_item_id = p_sr_inventory_item_pk
                  AND plan_id = -1;
      BEGIN

         OPEN c1;
         FETCH c1 INTO p_answer;

         IF (c1%NOTFOUND)
         THEN
            p_answer := 0;
         END IF;
         CLOSE c1;

      END GET_BOM_ITEM_TYPE;




   /* Finds all assemblies using a component. This procedure is called when
    * a component is selected and its parent is an option class. When this
    * occurs, the option class's nearest model needs to be found. Therefore,
    * the components grandparents which are the assemblies parents are
    * placed in a stack for further inspection.
    *
    * Model A
    *   |
    *   |--- Option Class A
    *   |            |
    *   |            |--- Option Class A'
    *   |                            |
    *   |                            |--- Component A
    *   |
    * Model B
    *   |
    *   |--- Option Class A
    *   |            |
    *   |            |--- Option Class A'
    *   |                            |
    *   |                            |--- Component A
    * Model C
    *   |
    *   |--- Option Class A'
    *                |
    *                |--- Component A
    *
    *
    * In this case, Component A needs to find Model A, B, C. Option Class A' is an
    * option class, but is used in several places.  The procedure will search
    * the components using Depth First Search (DFS) and append possible parents
    * to the argument parameter.
    *
    *
    * Parameters : 1. p_parents - vector containing all of the assemblies.
    *              2. p_instance - source location
    *              3. p_sr_org_pk - Organization source primary key.
    *              4. p_asmb_ascp_pk - The assembly whose parents we are looking for.
    *              5. p_planning_factor - Planning factor from this assembly
    *              6. p_disable_date - Disable date for assembly and its component
    */
   PROCEDURE GET_ALL_PARENTS (
  		p_parents              IN OUT NOCOPY 		PARENTS,
  		p_instance             IN     			VARCHAR2,
  		p_sr_org_pk            IN     			VARCHAR2,
  		p_asmb_ascp_pk         IN     			VARCHAR2,
  		p_planning_factor      IN     			NUMBER,
  		p_quantity_per         IN     			NUMBER,
  		p_disable_date         IN               DATE)
      IS
         endPos 		NUMBER 		:= p_parents.last;

         CURSOR c1 IS
            SELECT using_assembly_id,
                   planning_factor,
                   decode(mbc.usage_quantity/decode(mbc.usage_quantity,
                                                    null,1,
                                                    0,1,
                                                    abs(mbc.usage_quantity)),
                          1,
                          (mbc.usage_quantity * mbc.Component_Yield_Factor),
                          (mbc.usage_quantity /  mbc.Component_Yield_Factor))
                     * msd_dem_common_utilities.uom_conv(msi.sr_instance_id, msi.uom_code,msi.sr_inventory_item_id) usage_quantity,
                   mbc.disable_date disable_date
            FROM msc_system_items msi,
                 msc_bom_components mbc
            WHERE  msi.plan_id = -1
               AND msi.sr_instance_id = p_instance
               AND msi.organization_id = p_sr_org_pk
               AND msi.inventory_item_id = p_asmb_ascp_pk
               AND mbc.plan_id = -1
               AND mbc.sr_instance_id = p_instance
               AND mbc.organization_id = msi.organization_id
               AND mbc.inventory_item_id = msi.inventory_item_id
               AND (   mbc.optional_component = 1
                    OR msi.ato_forecast_control IN (C_CONSUME ,C_CONSUME_DERIVE));

      BEGIN

        FOR c_token IN c1
        LOOP

           endPos := endPos + 1;

           IF (endPos IS NULL)
           THEN
              msd_dem_common_utilities.log_debug ('msd_dem_collect_bom_data.get_all_parents - endPos is null');
           END IF;

           p_parents(endPos).item_id 		:=  c_token.using_assembly_id;
           p_parents(endPos).planning_factor 	:=  (p_planning_factor * c_token.planning_factor) / 100;
           p_parents(endPos).quantity_per 	:=  p_quantity_per * c_token.usage_quantity;

           IF (c_token.disable_date IS NULL)
           THEN
              p_parents(endPos).disable_date := p_disable_date;
           ELSIF (p_disable_date IS NULL)
           THEN
              p_parents(endPos).disable_date := c_token.disable_date;
           ELSE
              p_parents(endPos).disable_date := LEAST (c_token.disable_date, p_disable_date);
           END IF;

        END LOOP;

      END GET_ALL_PARENTS;




   /*** PUBLIC PROCEDURES ***
    *
    * COLLECT_BOM_DATA
    *
    *** PUBLIC PROCEDURES  ***/




   /*
    *
    */
   PROCEDURE COLLECT_BOM_DATA (
                        errbuf			OUT NOCOPY 	VARCHAR2,
      			retcode			OUT NOCOPY 	VARCHAR2,
      			p_sr_instance_id	IN		NUMBER )
   IS

      p_bom_item_type 		NUMBER 			:= 0;
      p_first_parent  		PARENT_TYPE;
      x_sr_level_pk   		VARCHAR2(255);
      i 			NUMBER 			:= 0;
      compLastIndex 		NUMBER;
      numInsert 		NUMBER 			:= 1;
      numMo 			NUMBER 			:= 1;
      icount 			NUMBER			:= 0;
      x_master_org		NUMBER			:= NULL;

      x_errbuf			VARCHAR2(2000)	:= NULL;
      x_retcode			VARCHAR2(255)	:= NULL;

      /* Create the Collections for looping */
      L_INSTANCE     		VARCHAR2LIST;
      L_ORG_SR_PKS         	VARCHAR2LIST;
      L_ASSEMBLY_ASCP_PKS       NUMBERLIST;
      L_COMPONENT_SR_PKS 	VARCHAR2LIST;
      L_EFFECTIVE_DATES		DATELIST;
      L_DISABLE_DATES      	DATELIST;
      L_QUANTITY_PER       	NUMBERLIST;
      L_PLANNING_FACTOR    	NUMBERLIST;
      L_BILL_SEQUENCE_ID   	NUMBERLIST;
      L_OPTIONAL_FLAG           NUMBERLIST;

      /* Create the Collections needed for Bulk Insert */
      C_INSTANCE     		VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_ORG_PKS			VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_ORG_SR_PKS         	VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_ASSEMBLY_PKS       	VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_ASSEMBLY_SR_PKS    	VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_COMPONENT_PKS  		VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_COMPONENT_SR_PKS 	VARCHAR2LIST 		:= VARCHAR2LIST	(C_INIT_VARCHAR2);
      C_EFFECTIVE_DATES		DATELIST     		:= DATELIST	(C_INIT_DATE);
      C_DISABLE_DATES      	DATELIST     		:= DATELIST	(C_INIT_DATE);
      C_QUANTITY_PER       	NUMBERLIST   		:= NUMBERLIST	(C_INIT_NUMBER);
      C_PLANNING_FACTOR    	NUMBERLIST   		:= NUMBERLIST	(C_INIT_NUMBER);
      C_OPTIONAL_FLAG           NUMBERLIST   		:= NUMBERLIST	(C_INIT_NUMBER);

      /* Cursor to get all the components and their parents */
      CURSOR c1 (p_master_org	IN	NUMBER)
      IS
         SELECT DISTINCT
            mb.sr_instance_id,
            mb.organization_id,
            mbc.using_assembly_id,
            ascp_comp.sr_inventory_item_id,
            mbc.effectivity_date,
            mbc.disable_date,
            decode(mbc.usage_quantity/decode(mbc.usage_quantity,
                                             null,1,
                                             0,1,
                                             abs(mbc.usage_quantity)),
                   1,
                   (mbc.usage_quantity * mbc.Component_Yield_Factor),
                   (mbc.usage_quantity /  mbc.Component_Yield_Factor))
               * msd_dem_common_utilities.uom_conv(ascp_comp.sr_instance_id, ascp_comp.uom_code, ascp_comp.inventory_item_id) usage_quantity,
            mbc.planning_factor,
            mb.bill_sequence_id,
            mbc.optional_component
         FROM msc_boms mb,
              msc_bom_components mbc,
              msc_system_items assemble,
              msc_system_items ascp_comp
         WHERE  mb.plan_id = -1
            AND mb.sr_instance_id = p_sr_instance_id
            AND decode (p_master_org, null, mb.organization_id, p_master_org) = mb.organization_id
            AND mb.alternate_bom_designator is null
            AND mbc.bill_sequence_id = mb.bill_sequence_id
            AND mbc.plan_id = mb.plan_id
            AND mbc.sr_instance_id = mb.sr_instance_id
            AND mbc.organization_id = mb.organization_id
            AND assemble.sr_instance_id = mbc.sr_instance_id
            AND assemble.plan_id = mbc.plan_id
            AND assemble.inventory_item_id = mbc.using_assembly_id
            AND assemble.organization_id = mbc.organization_id
            AND (   assemble.mrp_planning_code <> 6 			-- Exclude non plan ATO, but include PTO
                 OR
                    (    assemble.mrp_planning_code = 6
                     AND assemble.pick_components_flag = 'Y'))
            AND assemble.ato_forecast_control <> 3
            AND (   assemble.bom_item_type <> 4 			-- exclude Standard bom, but include Kit
                 OR
                    (    assemble.bom_item_type = 4
                     AND assemble.pick_components_flag = 'Y'))
            AND ascp_comp.plan_id = mbc.plan_id
            AND ascp_comp.inventory_item_id = mbc.inventory_item_id
            AND ascp_comp.organization_id = mbc.organization_id
            AND ascp_comp.sr_instance_id = mbc.sr_instance_id
            AND ascp_comp.ato_forecast_control = C_CONSUME_DERIVE
            AND ascp_comp.bom_item_type in (C_MODEL,C_STANDARD)
            AND (   ascp_comp.mrp_planning_code <> C_NO_PLANNING
                 OR (    ascp_comp.mrp_planning_code = C_NO_PLANNING
                     AND ascp_comp.pick_components_flag = 'Y'));	-- Support PTO as component


      CURSOR c2(p_instance 	IN NUMBER,
          	p_org_id   	IN NUMBER,
          	p_item_id  	IN NUMBER) IS
         SELECT sr_inventory_item_id
            FROM msc_system_items
            WHERE sr_instance_id = p_instance
               AND plan_id = -1
               AND organization_id = p_org_id
               AND inventory_item_id = p_item_id;


      CURSOR c3 IS
         SELECT sr_instance_id,
                sr_organization_id,
                sr_assembly_item_id,
                sr_component_item_id,
                min(effectivity_date) effectivity_date,
                max(nvl(disable_date, to_date('01-01-4000', 'DD-MM-YYYY'))) disable_date,
                sum(quantity_per) quantity_per,
                (sum(quantity_per) * 100)/(decode (sum (decode (planning_factor, 0, null, quantity_per * 100 /planning_factor)),
                                                   0,1,null,1,
                                                   sum (decode (planning_factor, 0, null, quantity_per * 100 /planning_factor)))) planning_factor,
                min(optional_flag) optional_flag
            FROM
                msd_dem_bom_components
            GROUP BY
                sr_instance_id,
                sr_organization_id,
                sr_assembly_item_id,
                sr_component_item_id
            HAVING count(*) > 1;


   BEGIN

      msd_dem_common_utilities.log_debug ('Entering: msd_dem_collect_bom_data.collect_bom_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;
      /* Log the parameters */
      msd_dem_common_utilities.log_debug (' Instance ID - ' || to_char(p_sr_instance_id));

      /* The procedure should only execute if profile MSD_DEM: Include Dependent Demand is set to yes. */
      IF (fnd_profile.value('MSD_DEM_INCLUDE_DEPENDENT_DEMAND') = 2)
      THEN
         msd_dem_common_utilities.log_message ('In msd_dem_collect_bom_data.collect_bom_data - '
                                                  || 'Profile MSD_DEM: Include Dependent Demand is set to No. '
                                                  || 'Hence no action taken. Exiting Normally.');
         retcode := 0;
         RETURN;
      END IF;

      /* The procedure should only execute if profile MSD_DEM: Calculate Planning Percentage
       * is set to Collect Consume and Derive Options Only. */
      IF (fnd_profile.value('MSD_DEM_PLANNING_PERCENTAGE') <> 2)
      THEN
         msd_dem_common_utilities.log_message ('In msd_dem_collect_bom_data.collect_bom_data - '
                                                  || 'Profile MSD_DEM: Calculate Planning Percentage is not set to Collect Options Only. '
                                                  || 'Hence no action taken. Exiting Normally.');
         retcode := 0;
         RETURN;
      END IF;

      msd_dem_common_utilities.log_message ('Truncating table MSD_DEM_BOM_COMPONENTS');
      msd_dem_query_utilities.truncate_table (
      					errbuf,
      					retcode,
      					'MSD_DEM_BOM_COMPONENTS',
      					2,
      					1);
      IF (retcode = -1)
      THEN
            msd_dem_common_utilities.log_message ('Error(1) in msd_dem_collect_bom_data.collect_bom_data - '
                                                   || 'Error in call to msd_dem_query_utilities.truncate_table');
            msd_dem_common_utilities.log_message(errbuf);
            RETURN;
      END IF;

      IF (to_number(fnd_profile.value('MSD_DEM_EXPLODE_DEMAND_METHOD')) = 2)
      THEN
         x_master_org := msd_dem_common_utilities.get_parameter_value (p_sr_instance_id, 'MSD_DEM_MASTER_ORG');
      END IF;

      msd_dem_common_utilities.log_debug ('Select Valid Components from MSC');
      OPEN c1 (x_master_org);
      FETCH c1 BULK COLLECT INTO
			L_INSTANCE,
			L_ORG_SR_PKS,
			L_ASSEMBLY_ASCP_PKS,
			L_COMPONENT_SR_PKS,
			L_EFFECTIVE_DATES,
			L_DISABLE_DATES,
			L_QUANTITY_PER,
			L_PLANNING_FACTOR,
			L_BILL_SEQUENCE_ID,
			L_OPTIONAL_FLAG;

      IF (c1%ROWCOUNT = 0)
      THEN
         CLOSE c1;
         msd_dem_common_utilities.log_message ('Error(2) in msd_dem_collect_bom_data.collect_bom_data - '
                                               || 'No rows found in c1 cursor');
         retcode := -1;
         RETURN;
      END IF;

      CLOSE c1;

      msd_dem_common_utilities.log_debug ('Begin looping through all components.');

      FOR j IN L_COMPONENT_SR_PKS.FIRST..L_COMPONENT_SR_PKS.LAST
      LOOP

         mo_parents.delete;

         msd_dem_common_utilities.log_debug('Row: ' || icount);
         msd_dem_common_utilities.log_debug('  Instance: ' || icount);
         msd_dem_common_utilities.log_debug('  Organization Sr Pk: ' || L_ORG_SR_PKS(j));
         msd_dem_common_utilities.log_debug('  Assembly        Pk: ' || L_ASSEMBLY_ASCP_PKS(j));
         msd_dem_common_utilities.log_debug('  Component     SrPk: ' || L_COMPONENT_SR_PKS(j));
         msd_dem_common_utilities.log_debug('  Effective     Date: ' || L_EFFECTIVE_DATES(j));
         msd_dem_common_utilities.log_debug('  Bill Sequence   Id: ' || L_BILL_SEQUENCE_ID(j));
         msd_dem_common_utilities.log_debug('  Optional Flag     : ' || L_OPTIONAL_FLAG(j));

         icount := icount + 1;

         get_bom_item_type(
   			p_answer 		=> p_bom_item_type,
  			p_instance 		=> L_INSTANCE(j),
  			p_sr_org_pk 		=> L_ORG_SR_PKS(j),
  			p_sr_inventory_item_pk 	=> L_ASSEMBLY_ASCP_PKS(j));

  	       oc_parents(1).item_id := 0;
           oc_parents(1).planning_factor := 0;
           oc_parents(1).quantity_per := 0;
           oc_parents(1).disable_date := NULL;

           mo_parents(1).item_id := 0;
           mo_parents(1).planning_factor := 0;
           mo_parents(1).quantity_per := 0;
           mo_parents(1).disable_date := NULL;

           IF (p_bom_item_type = C_OPTION_CLASS)
           THEN
              get_all_parents(
        		p_parents  		=> oc_parents,
        		P_instance 		=> L_INSTANCE(j),
        		p_sr_org_pk 		=> L_ORG_SR_PKS(j),
        		p_asmb_ascp_pk 		=> L_ASSEMBLY_ASCP_PKS(j),
        		p_planning_factor 	=> L_PLANNING_FACTOR(j),
        		p_quantity_per 		=> L_QUANTITY_PER(j),
        		p_disable_date      => L_DISABLE_DATES(j) );

              WHILE (oc_parents.count > 0)							-- Start of While Loop1
              LOOP

                 p_bom_item_type := 0;
                 compLastIndex := oc_parents.last;

                 IF compLastIndex IS NULL
                 THEN
                    msd_dem_common_utilities.log_debug('compLastIndex is null in method bom_collections');
                 END IF;

                 get_bom_item_type(
          		p_answer 		=> p_bom_item_type,
          		p_instance 		=> L_INSTANCE(j),
          		p_sr_org_pk 		=> L_ORG_SR_PKS(j),
          		p_sr_inventory_item_pk 	=> oc_parents(compLastIndex).item_id);

                 IF (p_bom_item_type = C_OPTION_CLASS)
                 THEN

                    tmp1 := oc_parents(compLastIndex).item_id;
                    tmp2 := oc_parents(compLastIndex).planning_factor;
                    tmp3 := oc_parents(compLastIndex).quantity_per;
                    tmp4 := oc_parents(compLastIndex).disable_date;

                    oc_parents.delete(compLastIndex);

                    get_all_parents(
            		p_parents 		=> oc_parents,
            		p_instance 		=> L_INSTANCE(j),
            		p_sr_org_pk 		=> L_ORG_SR_PKS(j),
            		p_asmb_ascp_pk 		=> tmp1,
            		p_planning_factor 	=> tmp2,
            		p_quantity_per 		=> tmp3,
            		p_disable_date      => tmp4 );

            	 ELSIF (p_bom_item_type = C_MODEL)
            	 THEN
            	    mo_parents(numMo).item_id 		:= oc_parents(compLastIndex).item_id;
                    mo_parents(numMo).planning_factor 	:= oc_parents(compLastIndex).planning_factor;
                    mo_parents(numMo).quantity_per 	:= oc_parents(compLastIndex).quantity_per;
                    mo_parents(numMo).disable_date  := oc_parents(compLastIndex).disable_date;
                    numMo := numMo + 1;
                    oc_parents.delete(compLastIndex);
                 ELSE
                    oc_parents.delete(compLastIndex);
                 END IF;

              END LOOP;     									-- End of While Loop1

              i := mo_parents.FIRST;  -- get subscript of first element
              WHILE (i IS NOT NULL)								-- Start of While Loop2
              LOOP

                 IF (numInsert > C_INSTANCE.LAST)
                 THEN
         	    C_INSTANCE.extend;
                    C_ORG_SR_PKS.extend;
                    C_ASSEMBLY_SR_PKS.extend;
                    C_COMPONENT_SR_PKS.extend;
                    C_EFFECTIVE_DATES.extend;
                    C_DISABLE_DATES.extend;
                    C_QUANTITY_PER.extend;
                    C_PLANNING_FACTOR.extend;
                    C_OPTIONAL_FLAG.extend;
                 END IF;

                 OPEN c2(L_INSTANCE(j),  to_number(L_ORG_SR_PKS(j)), mo_parents(i).item_id);
                 FETCH c2 INTO x_sr_level_pk;
                 CLOSE c2;

                 IF (    x_sr_level_pk IS NOT NULL
                     AND mo_parents(i).quantity_per <> 0
                     AND mo_parents(i).planning_factor <> 0)
                 THEN

                    IF (numInsert > C_INSTANCE.LAST)
                    THEN
                       C_INSTANCE.extend;
          	       C_ORG_SR_PKS.extend;
          	       C_ASSEMBLY_SR_PKS.extend;
                       C_COMPONENT_SR_PKS.extend;
                       C_EFFECTIVE_DATES.extend;
                       C_DISABLE_DATES.extend;
                       C_QUANTITY_PER.extend;
                       C_PLANNING_FACTOR.extend;
                       C_OPTIONAL_FLAG.extend;
                    END IF;

                    C_INSTANCE(numInsert) 		:= L_INSTANCE(j);
                    C_ORG_SR_PKS(numInsert)		:= L_ORG_SR_PKS(j);
                    C_ASSEMBLY_SR_PKS(numInsert) 	:= x_sr_level_pk;
                    C_COMPONENT_SR_PKS(numInsert) 	:= L_COMPONENT_SR_PKS(j);
                    C_EFFECTIVE_DATES(numInsert)	:= L_EFFECTIVE_DATES(j);
                    C_DISABLE_DATES(numInsert) 		:= mo_parents(i).disable_date;
                    C_QUANTITY_PER(numInsert) 		:= mo_parents(i).quantity_per;
                    C_PLANNING_FACTOR(numInsert) 	:= mo_parents(i).planning_factor;
                    C_OPTIONAL_FLAG(numInsert) 		:= L_OPTIONAL_FLAG(j);

                    numInsert := numInsert + 1;

                 END IF;

                 i := mo_parents.NEXT(i);  -- get subscript of next element

              END LOOP;										-- End of While Loop2

           ELSIF (   p_bom_item_type = C_MODEL
                  OR p_bom_item_type = C_STANDARD )   						/* To bring PTO Kit */
           THEN

              OPEN c2(L_INSTANCE(j),  to_number(L_ORG_SR_PKS(j)), L_ASSEMBLY_ASCP_PKS(j));
              FETCH c2 INTO x_sr_level_pk;
              CLOSE c2;

              IF (x_sr_level_pk IS NOT NULL)
              THEN

                 IF (numInsert > C_INSTANCE.LAST)
                 THEN
                    C_INSTANCE.extend;
                    C_ORG_SR_PKS.extend;
                    C_ASSEMBLY_SR_PKS.extend;
                    C_COMPONENT_SR_PKS.extend;
                    C_EFFECTIVE_DATES.extend;
                    C_DISABLE_DATES.extend;
                    C_QUANTITY_PER.extend;
                    C_PLANNING_FACTOR.extend;
                    C_OPTIONAL_FLAG.extend;
                 END IF;

                 C_INSTANCE(numInsert) 		:= L_INSTANCE(j);
                 C_ORG_SR_PKS(numInsert)	:= L_ORG_SR_PKS(j);
                 C_ASSEMBLY_SR_PKS(numInsert) 	:= x_sr_level_pk;
                 C_COMPONENT_SR_PKS(numInsert) 	:= L_COMPONENT_SR_PKS(j);
                 C_EFFECTIVE_DATES(numInsert)	:= L_EFFECTIVE_DATES(j);
                 C_DISABLE_DATES(numInsert) 	:= L_DISABLE_DATES(j);
                 C_QUANTITY_PER(numInsert) 	:= L_QUANTITY_PER(j);
                 C_PLANNING_FACTOR(numInsert) 	:= L_PLANNING_FACTOR(j);
                 C_OPTIONAL_FLAG(numInsert) 	:= L_OPTIONAL_FLAG(j);

      		 numInsert := numInsert + 1;

              END IF;

           END IF;

      END LOOP;


      IF (C_INSTANCE(1) = C_INIT_VARCHAR2)
      THEN
         msd_dem_common_utilities.log_debug ('There is no data to insert - ' || to_char(C_INSTANCE.LAST));
      ELSE

         -- INSERT THE DATA
         FORALL k IN 1..C_INSTANCE.LAST
            INSERT INTO MSD_DEM_BOM_COMPONENTS (
               sr_instance_id,
               sr_organization_id,
               sr_assembly_item_id,
               sr_component_item_id,
               effectivity_date,
               disable_date,
               quantity_per,
               planning_factor,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               optional_flag)
            VALUES (
               C_INSTANCE(k),
               C_ORG_SR_PKS(k),
               C_ASSEMBLY_SR_PKS(k),
               C_COMPONENT_SR_PKS(k),
               C_EFFECTIVE_DATES(k),
               C_DISABLE_DATES(k),
               C_QUANTITY_PER(k),
               C_PLANNING_FACTOR(k),
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.user_id,
               C_OPTIONAL_FLAG(k) );

            msd_dem_common_utilities.log_debug ('The number of rows inserted is : ' || to_char(numInsert - 1));


         -- Remove the duplicates
         i := 0;
         FOR c_token IN c3
         LOOP

            i := i + 1;
            msd_dem_common_utilities.log_debug (to_char(i) || '. Duplicate - Instance/Organization/Parent/Child - '
                                                || to_char(c_token.sr_instance_id) || '/'
                                                || to_char(c_token.sr_organization_id) || '/'
                                                || to_char(c_token.sr_assembly_item_id) || '/'
                                                || to_char(c_token.sr_component_item_id));

            DELETE FROM MSD_DEM_BOM_COMPONENTS
            WHERE  sr_instance_id = c_token.sr_instance_id
               AND sr_organization_id = c_token.sr_organization_id
               AND sr_assembly_item_id = c_token.sr_assembly_item_id
               AND sr_component_item_id = c_token.sr_component_item_id;

            msd_dem_common_utilities.log_debug ('Number of rows deleted : ' || to_char(SQL%ROWCOUNT));

            INSERT INTO MSD_DEM_BOM_COMPONENTS (
               sr_instance_id,
               sr_organization_id,
               sr_assembly_item_id,
               sr_component_item_id,
               effectivity_date,
               disable_date,
               quantity_per,
               planning_factor,
               creation_date,
               created_by,
               last_update_date,
               last_updated_by,
               last_update_login,
               optional_flag)
            VALUES (
               c_token.sr_instance_id,
               c_token.sr_organization_id,
               c_token.sr_assembly_item_id,
               c_token.sr_component_item_id,
               c_token.effectivity_date,
               decode (c_token.disable_date, to_date('01-01-4000', 'DD-MM-YYYY'), null, c_token.disable_date),
               c_token.quantity_per,
               c_token.planning_factor,
               sysdate,
               fnd_global.user_id,
               sysdate,
               fnd_global.user_id,
               fnd_global.user_id,
               c_token.optional_flag);

            msd_dem_common_utilities.log_debug ('Number of rows inserted : ' || to_char(SQL%ROWCOUNT));

         END LOOP;

         COMMIT;

         -- Analyze the table
         msd_dem_collect_history_data.analyze_table(x_errbuf, x_retcode, 'MSD_DEM_BOM_COMPONENTS');

      END IF;

      msd_dem_common_utilities.log_debug ('Exiting: msd_dem_collect_bom_data.collect_bom_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));

      retcode := 0;

   EXCEPTION
      WHEN OTHERS THEN
         errbuf := substr(SQLERRM,1,150);
         retcode := -1;

         msd_dem_common_utilities.log_message ('Exception(1): msd_dem_collect_bom_data.collect_bom_data - ' || TO_CHAR(systimestamp, 'DD-MON-YYYY HH24:MI:SS'));
         msd_dem_common_utilities.log_message (errbuf);
	 RETURN;

   END COLLECT_BOM_DATA;


END MSD_DEM_COLLECT_BOM_DATA;

/
