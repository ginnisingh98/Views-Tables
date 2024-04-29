--------------------------------------------------------
--  DDL for Package Body CSTPPCIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPPCIC" AS
/* $Header: CSTPCICB.pls 120.0 2005/05/25 03:49:36 appldev noship $ */

FUNCTION get_uom_conv_rate(
        i_item_id          IN      NUMBER,
        i_from_org_id     IN      NUMBER,
        i_to_org_id    IN      NUMBER)
RETURN NUMBER IS

-- Local variables

l_conv_rate NUMBER := 1;
o_from_uom VARCHAR2(25);
o_to_uom VARCHAR2(25);
o_rate NUMBER := 1;
o_err_num NUMBER ;
o_err_code VARCHAR2(240) ;
o_err_msg VARCHAR2(240) ;

BEGIN

  CSTPAVCP.get_snd_rcv_uom(i_item_id,
			 i_from_org_id,
			 i_to_org_id,
			 o_from_uom,
			 o_to_uom,
			 o_err_num,
			 o_err_code,
			 o_err_msg);

  inv_convert.inv_um_conversion(o_from_uom,
	     	              o_to_uom,
			      i_item_id,
			      o_rate);

  RETURN (o_rate);

END; /* End of get_uom_conv_rate */

/*---------------------------------------------------------------------------*
|  PUBLIC PROCEDURE                                                          |
|       copy_item_period_cost                                                |
|                                                                            |
|  p_copy_option:							     |
|             1:  Merge and update                                           |
|             2:  New cost only                                              |
|             3:  remove and replace                                         |
|  p_range:								     |
|             1:  All items                                                  |
|             2:  Specific Item                                              |
|             5:  Category Items                                             |
|                                                                            |
|  This procedure defaults the following values:                             |
|                                                                            |
|  CST_ITEM_COSTS.defaulted_flag = 2 (Do not use default cost controls)      |
|  CST_ITEM_COSTS.cost_update_id = NULL				             |
|  CST_ITEM_COSTS.based_on_rollup_flag = 1			             |
|  CST_ITEM_COST_DETAILS.basis_factor = 1			             |
|  CST_ITEM_COST_DETAILS.rollup_source_type = 1(User defined)                |
|                                                                            |
*----------------------------------------------------------------------------*/
PROCEDURE copy_item_period_cost(
   errbuf                  OUT   NOCOPY   VARCHAR2,
   retcode                 OUT   NOCOPY   NUMBER,
	p_legal_entity		      IN	            NUMBER,
	p_from_cost_type_id	   IN	            NUMBER,
	p_from_cost_group_id	   IN	            NUMBER,
	p_period_id		         IN	            NUMBER,
	p_to_org_id		         IN	            NUMBER,
 	p_to_cost_type_id    	IN	            NUMBER,
   p_material 		         IN	            NUMBER,
   p_material_overhead 	   IN	            NUMBER,
   p_resource 		         IN	            NUMBER,
   p_outside_processing 	IN	            NUMBER,
   p_overhead 		         IN	            NUMBER,
	p_copy_option		      IN	            NUMBER,
	p_range 		            IN	            NUMBER,
	p_item_dummy		      IN	            NUMBER,
	p_category_dummy	      IN	            NUMBER,
	p_specific_item_id	   IN	            NUMBER,
	p_category_set_id	      IN	            NUMBER,
 	p_category_validate_flag IN            VARCHAR2,
   p_category_structure    IN             NUMBER,
   p_category_id           IN             NUMBER,
   p_last_updated_by       IN             NUMBER,
   p_full_validate         IN             NUMBER)

IS

-- Local PL/SQL variable
--

cst_fail_uomconvert   	EXCEPTION;
cst_fail_parameters	EXCEPTION;
conc_status		BOOLEAN;
l_row_count		NUMBER;
l_stmt_num		NUMBER;
l_valid         	NUMBER;
l_master_org_id		NUMBER;
l_program_id    	NUMBER;
l_prog_appl_id    	NUMBER;
l_login_id		NUMBER;
l_request_id    	NUMBER;
l_user_id		NUMBER;
l_grp_id                NUMBER;


l_err_num       	NUMBER;
l_err_code      	VARCHAR2(240);
l_err_msg       	VARCHAR2(240);

--fptr    utl_file.file_type; --debug

/* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */
l_process_enabled_flag  mtl_parameters.process_enabled_flag%TYPE;
l_organization_code     mtl_parameters.organization_code%TYPE;
/* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

BEGIN

   /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 Start */
   BEGIN
      SELECT   nvl(process_enabled_flag,'N')
               , organization_code
      INTO     l_process_enabled_flag
               , l_organization_code
      FROM     mtl_parameters
      WHERE    organization_id = p_to_org_id;

      IF nvl(l_process_enabled_flag,'N') = 'Y' THEN
         l_err_num := 30001;
         fnd_message.set_name('GMF', 'GMF_PROCESS_ORG_ERROR');
         fnd_message.set_token('ORGCODE', l_organization_code);
         l_err_msg := FND_MESSAGE.Get;
         l_err_msg := substrb('CSTPPCIC : ' || l_err_msg,1,240);
         CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
         fnd_file.put_line(fnd_file.log,l_err_msg);
         RETURN;
      END IF;

   EXCEPTION
      WHEN no_data_found THEN
         l_process_enabled_flag := 'N';
         l_organization_code := NULL;
   END;
   /* Skip Process Organizations Cost Manager Changes - Anand Thiyagarajan - 26-Oct-2004 End */

--fptr:=utl_file.fopen('/sqlcom/log/dmt11irw','pcc.log','W'); --debug
--utl_file.put_line(fptr,'testing');

   ----------------------------------------------------------------------------
   -- Initializing Variables
   ----------------------------------------------------------------------------
   l_user_id     := 0;
   l_program_id  := 0;
   l_err_num     := 0;
   l_request_id  := 0;
   l_err_code    := '';
   l_err_msg     := '';

   ----------------------------------------------------------------------------
   -- retrieving concurrent program information
   ----------------------------------------------------------------------------
   l_stmt_num :=  10;


   l_request_id      := FND_GLOBAL.conc_request_id;
   l_prog_appl_id    := FND_GLOBAL.prog_appl_id;
   l_user_id         := FND_GLOBAL.user_id;
   l_program_id      := FND_GLOBAL.conc_program_id;
   l_login_id        := FND_GLOBAL.conc_login_id;

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Global Variables... ');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'request_id... '||to_char(l_request_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'prog_appl_id... '||to_char(l_prog_appl_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_user_id... '||to_char(l_user_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_program_id... '||to_char(l_program_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_login_id... '||to_char(l_login_id));

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Arguments... ');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Legal Entity: '|| TO_CHAR(p_legal_entity));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'From Cost Type: '
					|| TO_CHAR(p_from_cost_type_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'From Cost Group: '
					|| TO_CHAR(p_from_cost_group_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Period: ' || TO_CHAR(p_period_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'To Organization: ' || TO_CHAR(p_to_org_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'To Cost Type: '
					|| TO_CHAR(p_to_cost_type_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Material Subelement: '
					|| TO_CHAR(p_material));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Material Overhead Subelement: '
					|| TO_CHAR(p_material_overhead));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Resource Subelement: '
					|| TO_CHAR(p_resource));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Outside Processing Subelement: '
					|| TO_CHAR(p_outside_processing));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Overhead Subelement: '
					|| TO_CHAR(p_overhead));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Copy Option: ' || TO_CHAR(p_copy_option));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Range: ' || TO_CHAR(p_range));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Item Dummy: ' || TO_CHAR(p_item_dummy));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Dummy: '
					|| TO_CHAR(p_category_dummy));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Specific Item: '
					|| TO_CHAR(p_specific_item_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Set: '
					|| TO_CHAR(p_category_set_id));

   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Validate Flag: '
					|| p_category_validate_flag);
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Structure: '
					|| TO_CHAR(p_category_structure));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category: '
					|| TO_CHAR(p_category_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Last Updated by: '
					|| TO_CHAR(p_last_updated_by));
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Full Validate: '
					|| TO_CHAR(p_full_validate));


   IF p_full_validate = 1 THEN

   ----------------------------------------------------------------------------
   -- Validating the parameters passed. This is not required if the call
   -- is from the concurrent program, but will be required if it is called
   -- as standalone.
   ----------------------------------------------------------------------------


     l_valid    := 0;

     --   Validate the Legal Entity.

     l_stmt_num :=  21;

     SELECT  1
     INTO l_valid
     FROM cst_le_cost_types
     WHERE  legal_entity = p_legal_entity;

l_valid := 0;

--   Validate From Cost Type

      l_stmt_num :=  22;


select 1
into l_valid
from cst_cost_types cct
where cost_type_id = p_from_cost_type_id
and cost_type_id in
(select distinct clct.cost_type_id
 from cst_le_cost_types clct
 where clct.legal_entity = p_legal_entity
)
and nvl(cct.disable_date, sysdate+1) > sysdate;

l_valid := 0;


--   Validate From Cost Group

      l_stmt_num :=  23;


select 1
into l_valid
from dual
where p_from_cost_group_id in
(select distinct cost_group
 from cst_cost_groups
 where legal_entity = p_legal_entity
)
and exists
       (select 1
        from cst_pac_periods cpp
        where legal_entity = p_legal_entity
        and cost_type_id = p_from_cost_type_id
        and cpp.pac_period_id in
                (select cppp.pac_period_id
                 from cst_pac_process_phases cppp
                 where cppp.cost_group_id = p_from_cost_group_id
                 and cppp.pac_period_id = cpp.pac_period_id
                 and process_phase = 5
                 and process_status = 4
                )
       );


l_valid := 0;


--   Validate From Period

      l_stmt_num :=  24;


select 1
into l_valid
from dual
where p_period_id in
(select distinct pac_period_id
 from cst_pac_process_phases
 where cost_group_id = p_from_cost_group_id
 and process_phase = 5
 and process_status = 4
);


l_valid := 0;


--   Validate To Organization

      l_stmt_num :=  25;


select 1
into l_valid
from dual
where p_to_org_id in
(
   (select distinct CCGA.organization_id
    from cst_cost_group_assignments CCGA
    where CCGA.cost_group_id = p_from_cost_group_id
   )
   UNION
   (select distinct CCG.organization_id
    from cst_cost_groups CCG
    where CCG.cost_group_id = p_from_cost_group_id
   )
);


l_valid := 0;

--   Validate To Cost Type

      l_stmt_num :=  26;


select 1
into l_valid
from dual
where p_to_cost_type_id in
                   (select distinct cost_type_id
                    from cst_cost_types
                    where organization_id =  p_to_org_id
                    and cost_type_id not in (1,2,3)
                    and nvl(allow_updates_flag,1) = 1
                    and nvl(disable_date, sysdate+1) > sysdate
                   )
and p_to_cost_type_id not in
                   (select distinct cost_type_id
                    from cst_le_cost_types
                   );

l_valid := 0;


--   Validate To Material Subelement

      l_stmt_num :=  27;


select 1
into l_valid
from dual
where p_material in
               (select resource_id
                from bom_resources
                where organization_id = p_to_org_id
                and cost_element_id = 1
                and default_basis_type = 1
                and nvl(disable_date, sysdate+1) > sysdate
                and nvl(allow_costs_flag,1) = 1
               );


l_valid := 0;


--   Validate To Material Overhead Subelement


      l_stmt_num :=  28;


select 1
into l_valid
from dual
where p_material_overhead in
               (select resource_id
                from bom_resources
                where organization_id = p_to_org_id
                and cost_element_id = 2
                and default_basis_type = 1
                and nvl(disable_date, sysdate+1) > sysdate
                and nvl(allow_costs_flag,1) = 1
               );

l_valid := 0;


--   Validate To Resource Subelement

      l_stmt_num :=  29;


select 1
into l_valid
from dual
where p_resource in
               (select resource_id
                from bom_resources
                where organization_id = p_to_org_id
                and cost_element_id = 3
                and default_basis_type = 1
                and nvl(disable_date, sysdate+1) > sysdate
                and nvl(allow_costs_flag,1) = 1
               );

l_valid := 0;


--   Validate To Outside Processing Subelement


      l_stmt_num :=  30;


select 1
into l_valid
from dual
where p_outside_processing in
               (select resource_id
                from bom_resources
                where organization_id = p_to_org_id
                and cost_element_id = 4
                and default_basis_type = 1
                and nvl(disable_date, sysdate+1) > sysdate
                and nvl(allow_costs_flag,1) = 1
               );

l_valid := 0;


--   Validate To Overhead Subelement

      l_stmt_num :=  31;


select 1
into l_valid
from dual
where p_overhead in
               (select resource_id
                from bom_resources
                where organization_id = p_to_org_id
                and cost_element_id = 5
                and default_basis_type = 1
                and nvl(disable_date, sysdate+1) > sysdate
                and nvl(allow_costs_flag,1) = 1
               );

l_valid := 0;

-- what about validating categories/category_set ????

--   Validate Copy Option

      l_stmt_num :=  32;


select 1
into l_valid
from dual
where p_copy_option in (1,2,3);

l_valid := 0;


--   Validate Range

      l_stmt_num :=  33;


select 1
into l_valid
from dual
where p_range in (1,2,5);


IF  (l_valid <> 1) THEN
	RAISE CST_FAIL_PARAMETERS;
END IF;


END IF; -- check for p_validate



   ----------------------------------------------------------------------------
   -- Get the item master organization
   ----------------------------------------------------------------------------

   l_stmt_num := 0;

   SELECT organization_id
   INTO   l_master_org_id
   FROM   cst_cost_groups ccg
   WHERE  ccg.cost_group_id = p_from_cost_group_id;

   FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Master Org: ' || TO_CHAR(l_master_org_id));
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

   IF p_copy_option = 1 THEN


      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Merge and Update Costs');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

      --------------------------------------------------------------------------
      --  Merge and update existing costs
      --  Logic:
      -- * Copy the based_on_rollup_flag for the p_to_cost_type_id items in CIC
      --   to cst_item_costs_interface
      -- * Delete the p_to_cost_type_id items in CIC, CICD, only if they also
      --   have p_from_cost_type_id.
      -- * Items get their  p_to_cost_type_id costs from p_from_cost_type_id.
      --   The based_on_rollup_flag is copied from CICI
      -- * Items that did not have p_from_cost_type_id are left untouched.
      --------------------------------------------------------------------------



      --------------------------------------------------------------------------
      -- step 1> Deleting existing cost information from CICD
      --         for the p_to_cost_type_id, p_to_org_id, item
      --------------------------------------------------------------------------

      l_stmt_num :=  35;


      DELETE cst_item_cost_details CICD
      WHERE CICD.cost_type_id    = p_to_cost_type_id
      AND   CICD.organization_id = p_to_org_id
      AND (p_range = 1
                OR
          (p_range = 2 AND CICD.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CICD.inventory_item_id
                   AND    p_range               = 5)
           )
      AND EXISTS
          (SELECT NULL
           FROM   cst_pac_item_cost_details cpicd,
                  cst_pac_item_costs cpic
	   WHERE  cpicd.cost_layer_id      = cpic.cost_layer_id
	   AND    cpic.cost_group_id       = p_from_cost_group_id
	   AND    cpic.pac_period_id       = p_period_id
	   AND    cpic.inventory_item_id   = cicd.inventory_item_id);


      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows deleted from CICD');

      --------------------------------------------------------------------------
      -- step 2> Copying rollup flags, then Deleting existing cost information from CIC
      --         for the p_to_cost_type_id, p_to_org_id, item
      --------------------------------------------------------------------------

      l_stmt_num :=  37;

      l_grp_id := 0;

      SELECT CST_LISTS_S.NEXTVAL INTO l_grp_id
      FROM dual;

      INSERT INTO cst_item_costs_interface
      (     inventory_item_id
      ,     cost_type_id
      ,     based_on_rollup_flag
      ,     group_id
      )
      SELECT
   	    inventory_item_id
      ,     p_to_cost_type_id
      ,     based_on_rollup_flag
      ,     l_grp_id
      FROM cst_item_costs CIC
      WHERE CIC.cost_type_id = p_to_cost_type_id
      AND   CIC.organization_id = p_to_org_id
      AND (p_range = 1
                OR
          (p_range = 2 AND CIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CIC.inventory_item_id
                   AND    p_range               = 5)
           )
      AND EXISTS
          (SELECT NULL
           FROM   cst_pac_item_costs cpic
	   WHERE  cpic.cost_group_id = p_from_cost_group_id
           AND    cpic.pac_period_id = p_period_id
           AND    cpic.inventory_item_id = cic.inventory_item_id);

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rollup Flags backed up from CIC to CICI');

      l_stmt_num :=  40;


      DELETE cst_item_costs CIC
      WHERE CIC.cost_type_id    = p_to_cost_type_id
      AND   CIC.organization_id = p_to_org_id
      AND (p_range = 1
                OR
          (p_range = 2 AND CIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CIC.inventory_item_id
                   AND    p_range               = 5)
           )
      AND EXISTS
          (SELECT NULL
           FROM   cst_pac_item_costs cpic
	   WHERE  cpic.cost_group_id = p_from_cost_group_id
           AND    cpic.pac_period_id = p_period_id
           AND    cpic.inventory_item_id = cic.inventory_item_id);

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows deleted from CIC');


      --------------------------------------------------------------------------
      -- step 3> Inserting costs from CPIC
      --         to the costs for p_to_org_id, p_to_cost_type_id, item in CIC
      --         and removing backed up rollup flags from cst_item_costs_interface
      --------------------------------------------------------------------------


      l_stmt_num :=  50;


      INSERT INTO cst_item_costs
      (     inventory_item_id
      ,     organization_id
      ,     cost_type_id
      ,     last_update_date
      ,     last_updated_by
      ,     creation_date
      ,     created_by
      ,     last_update_login
      ,     inventory_asset_flag
      ,     lot_size
      ,     based_on_rollup_flag
      ,     shrinkage_rate
      ,     defaulted_flag
      ,     cost_update_id
      ,     pl_material
      ,     pl_material_overhead
      ,     pl_resource
      ,     pl_outside_processing
      ,     pl_overhead
      ,     tl_material
      ,     tl_material_overhead
      ,     tl_resource
      ,     tl_outside_processing
      ,     tl_overhead
      ,     material_cost
      ,     material_overhead_cost
      ,     resource_cost
      ,     outside_processing_cost
      ,     overhead_cost
      ,     pl_item_cost
      ,     tl_item_cost
      ,     item_cost
      ,     unburdened_cost
      ,     burden_cost
      ,     request_id
      ,     program_application_id
      ,     program_id
      ,     program_update_date
      )
      SELECT
            CPIC.inventory_item_id
      ,     p_to_org_id
      ,     p_to_cost_type_id
      ,     SYSDATE
      ,     l_user_id
      ,     SYSDATE
      ,     l_user_id
      ,     l_login_id				-- last update login
      ,     decode(MSI.inventory_asset_flag , 'Y', 1, 2)
      ,     nvl(MSI.std_lot_size,1)
      ,     nvl(BORF.based_on_rollup_flag, nvl(dBORF.based_on_rollup_flag,1)) -- set the borf to pre-existing value/default
      ,     nvl(MSI.shrinkage_rate , 0)
      ,     2    			-- defaulted_flag
      ,     NULL 			-- cost_update_id
      ,     CPIC.pl_material
      ,     CPIC.pl_material_overhead
      ,     CPIC.pl_resource
      ,     CPIC.pl_outside_processing
      ,     CPIC.pl_overhead
      ,     CPIC.tl_material
      ,     CPIC.tl_material_overhead
      ,     CPIC.tl_resource
      ,     CPIC.tl_outside_processing
      ,     CPIC.tl_overhead
      ,     CPIC.material_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.material_overhead_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.resource_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.outside_processing_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.overhead_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.pl_item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.tl_item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.unburdened_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.burden_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     l_request_id
      ,     702
      ,     l_program_id
      ,     SYSDATE
      FROM cst_pac_item_costs CPIC,
           mtl_system_items MSI,
           (SELECT inventory_item_id, based_on_rollup_flag
            FROM cst_item_costs_interface
            WHERE group_id = l_grp_id) BORF, -- based_on_rollup_flag backed up from destination cost type
           (SELECT cic.inventory_item_id, cic.based_on_rollup_flag
            FROM cst_cost_types cct, cst_item_costs cic
            WHERE cic.organization_id = p_to_org_id
            AND cct.cost_type_id = p_to_cost_type_id
            AND cic.cost_type_id = cct.default_cost_type_id) dBORF -- based_on_rollup_flag from default cost type
      WHERE CPIC.pac_period_id = p_period_id
      AND   CPIC.cost_group_id = p_from_cost_group_id
      AND   CPIC.inventory_item_id = MSI.inventory_item_id
      AND   MSI.organization_id = p_to_org_id
      AND   BORF.inventory_item_id(+) = CPIC.inventory_item_id
      AND   dBORF.inventory_item_id(+) = CPIC.inventory_item_id
      AND   (p_range = 1
                OR
            (p_range = 2 AND CPIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CPIC.inventory_item_id
                   AND    p_range               = 5)
             );

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows Inserted into CIC');

      l_stmt_num :=  55;

      DELETE cst_item_costs_interface
      WHERE group_id = l_grp_id;

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
                                        ||' Backup Rows deleted from CICI');

      --------------------------------------------------------------------------
      -- step 4> Getting costs from CPICD having the cost_layer_id
      --         as used above in CPIC and inserting
      --         to the costs for p_to_org_id, p_to_cost_type_id, item in CICD
      --------------------------------------------------------------------------

      l_stmt_num :=  60;


      INSERT INTO cst_item_cost_details
      (     inventory_item_id
      ,     organization_id
      ,     cost_type_id
      ,     last_update_date
      ,     last_updated_by
      ,     creation_date
      ,     created_by
      ,     last_update_login
      ,     level_type
      ,     resource_id
      ,     usage_rate_or_amount
      ,     basis_type
      ,     basis_resource_id
      ,     basis_factor
      ,     net_yield_or_shrinkage_factor
      ,     item_cost
      ,     cost_element_id
      ,     rollup_source_type
      ,     request_id
      ,     program_application_id
      ,     program_id
      ,     program_update_date
      )
      SELECT
            CPIC.inventory_item_id
      ,     p_to_org_id
      ,     p_to_cost_type_id
      ,     SYSDATE
      ,     l_user_id
      ,     SYSDATE
      ,     l_user_id
      ,     l_login_id
      ,     CPICD.level_type
      ,     decode(CPICD.cost_element_id,   	-- resource id
                   1, p_material,
                   2, p_material_overhead,
                   3, p_resource,
                   4, p_outside_processing,
                   5, p_overhead)
      ,     CPICD.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)  --usage_rate
      ,     1
      ,     NULL   				-- Basis resource_id
      ,     1      				-- basis_factor
      ,     1      				-- net_yield_or_shrinkage_factor
      ,     CPICD.item_cost *
			get_uom_conv_rate(CPIC.inventory_item_id,
					  l_master_org_id,
					  p_to_org_id)
      ,     CPICD.cost_element_id
      ,     1	    				-- rollup_source_type
      ,     l_request_id
      ,     702
      ,     l_program_id
      ,     SYSDATE
      FROM  cst_pac_item_costs CPIC,
            cst_pac_item_cost_details CPICD,
            mtl_system_items MSI               -- Bug 2570867 - joined with MSI to select only to_org items
      WHERE CPIC.pac_period_id = p_period_id
      AND   CPIC.cost_group_id = p_from_cost_group_id
      AND   CPIC.cost_layer_id = CPICD.cost_layer_id
      AND   MSI.inventory_item_id = CPIC.inventory_item_id
      AND   MSI.organization_id = p_to_org_id
      AND   (p_range = 1
                OR
            (p_range = 2 AND CPIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CPIC.inventory_item_id
                   AND    p_range               = 5)
             );

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows Inserted into CICD: ');


   END IF;   -- If p_copy_option


   IF p_copy_option = 2 THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Insert New Cost Information Only');

      --------------------------------------------------------------------------
      -- New Cost Information Only
      -- Logic:
      --* If Items already have a p_to_cost_type_id, then do not
      --  touch those items.
      --* All other Items get their  p_to_cost_type_id costs
      --  from p_from_cost_type_id.
      --------------------------------------------------------------------------

      --------------------------------------------------------------------------
      -- step 1> Inserting costs from CPIC
      --         to the costs for p_to_org_id, p_to_cost_type_id, item in CIC
      --------------------------------------------------------------------------


      l_stmt_num :=  70;


      INSERT INTO cst_item_costs
      (     inventory_item_id
      ,     organization_id
      ,     cost_type_id
      ,     last_update_date
      ,     last_updated_by
      ,     creation_date
      ,     created_by
      ,     last_update_login
      ,     inventory_asset_flag
      ,     lot_size
      ,     based_on_rollup_flag
      ,     shrinkage_rate
      ,     defaulted_flag
      ,     cost_update_id
      ,     pl_material
      ,     pl_material_overhead
      ,     pl_resource
      ,     pl_outside_processing
      ,     pl_overhead
      ,     tl_material
      ,     tl_material_overhead
      ,     tl_resource
      ,     tl_outside_processing
      ,     tl_overhead
      ,     material_cost
      ,     material_overhead_cost
      ,     resource_cost
      ,     outside_processing_cost
      ,     overhead_cost
      ,     pl_item_cost
      ,     tl_item_cost
      ,     item_cost
      ,     unburdened_cost
      ,     burden_cost
      ,     request_id
      ,     program_application_id
      ,     program_id
      ,     program_update_date
      )
      SELECT
            CPIC.inventory_item_id
      ,     p_to_org_id
      ,     p_to_cost_type_id
      ,     SYSDATE
      ,     l_user_id
      ,     SYSDATE
      ,     l_user_id
      ,     l_login_id
      ,     decode(MSI.inventory_asset_flag,'Y',1,2)
      ,     nvl(MSI.std_lot_size,1)
      ,     nvl(dBORF.based_on_rollup_flag,1) -- default the borf to 1 if not in default cost type
      ,     nvl(MSI.shrinkage_rate,0)
      ,     2				-- defaulted flag
      ,     NULL                        -- cost update id
      ,     CPIC.pl_material
      ,     CPIC.pl_material_overhead
      ,     CPIC.pl_resource
      ,     CPIC.pl_outside_processing
      ,     CPIC.pl_overhead
      ,     CPIC.tl_material
      ,     CPIC.tl_material_overhead
      ,     CPIC.tl_resource
      ,     CPIC.tl_outside_processing
      ,     CPIC.tl_overhead
      ,     CPIC.material_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.material_overhead_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.resource_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.outside_processing_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.overhead_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.pl_item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.tl_item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.unburdened_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.burden_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)

      ,     l_request_id
      ,     702
      ,     l_program_id
      ,     SYSDATE
      FROM cst_pac_item_costs CPIC,
           mtl_system_items MSI,
           (SELECT cic.inventory_item_id, based_on_rollup_flag
            FROM cst_cost_types cct, cst_item_costs cic
            WHERE cic.organization_id = p_to_org_id
            AND cct.cost_type_id = p_to_cost_type_id
            AND cic.cost_type_id = cct.default_cost_type_id) dBORF -- based_on_rollup_flag from default cost type

      WHERE CPIC.pac_period_id = p_period_id
      AND   CPIC.cost_group_id = p_from_cost_group_id
      AND   CPIC.inventory_item_id = MSI.inventory_item_id
      AND   MSI.organization_id = p_to_org_id
      AND   dBORF.inventory_item_id(+) = CPIC.inventory_item_id
      AND   (p_range = 1
                OR
            (p_range = 2 AND CPIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CPIC.inventory_item_id
                   AND    p_range               = 5)
             )
     AND NOT EXISTS
          (SELECT 'x'
           FROM  cst_item_costs       CIC
           WHERE CIC.cost_type_id      = p_to_cost_type_id
           AND   CIC.organization_id   = p_to_org_id
           AND   CIC.inventory_item_id = CPIC.inventory_item_id);

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows Inserted into CIC');



      --------------------------------------------------------------------------
      -- step 2> Getting costs from CPICD having the cost_layer_id
      --         as used above in CPIC and inserting
      --         to the costs for p_to_org_id, p_to_cost_type_id, item in CICD
      --------------------------------------------------------------------------


      l_stmt_num :=  80;


      INSERT INTO cst_item_cost_details
      (     inventory_item_id
      ,     organization_id
      ,     cost_type_id
      ,     last_update_date
      ,     last_updated_by
      ,     creation_date
      ,     created_by
      ,     last_update_login
      ,     level_type
      ,     resource_id
      ,     usage_rate_or_amount
      ,     basis_type
      ,     basis_resource_id
      ,     basis_factor
      ,     net_yield_or_shrinkage_factor
      ,     item_cost
      ,     cost_element_id
      ,     rollup_source_type
      ,     request_id
      ,     program_application_id
      ,     program_id
      ,     program_update_date
      )
      SELECT
            CPIC.inventory_item_id
      ,     p_to_org_id
      ,     p_to_cost_type_id
      ,     SYSDATE
      ,     l_user_id
      ,     SYSDATE
      ,     l_user_id
      ,     l_login_id
      ,     CPICD.level_type
      ,     decode(CPICD.cost_element_id,       -- resource id
                   1, p_material,
                   2, p_material_overhead,
                   3, p_resource,
                   4, p_outside_processing,
                   5, p_overhead)
      ,     CPICD.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)  --usage_rate
      ,     1					-- basis_type
      ,     NULL				-- basis_resource_id
      ,     1					-- basis_factor
      ,     1 					-- net_yield_or_shrinkage_factor
      ,     CPICD.item_cost*
			    get_uom_conv_rate(CPIC.inventory_item_id,
					      l_master_org_id,
					      p_to_org_id)
      ,     CPICD.cost_element_id
      ,     1	    -- rollup_source_type
      ,     l_request_id
      ,     702
      ,     l_program_id
      ,     SYSDATE
      FROM  cst_pac_item_costs CPIC,
            cst_pac_item_cost_details CPICD,
            mtl_system_items MSI               -- Bug 2570867 - joined with MSI to select only to_org items
      WHERE CPIC.pac_period_id = p_period_id
      AND   CPIC.cost_group_id = p_from_cost_group_id
      AND   CPIC.cost_layer_id = CPICD.cost_layer_id
      AND   MSI.inventory_item_id = CPIC.inventory_item_id
      AND   MSI.organization_id = p_to_org_id
      AND   (p_range = 1
                OR
            (p_range = 2 AND CPIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CPIC.inventory_item_id
                   AND    p_range               = 5)
             )
-- Bug 2619991 - Commented out this NOT EXISTS check.
-- Statment 70 already makes this check and then inserts to CIC, so this always fails.
/*
      AND NOT EXISTS
          (SELECT 'x'
           FROM  cst_item_costs       CIC
           WHERE CIC.cost_type_id      = p_to_cost_type_id
           AND   CIC.organization_id   = p_to_org_id
           AND   CIC.inventory_item_id = CPIC.inventory_item_id)
*/
      AND NOT EXISTS
          (SELECT 'x'
           FROM  cst_item_cost_details CICD
           WHERE CICD.cost_type_id      = p_to_cost_type_id
           AND   CICD.organization_id   = p_to_org_id
           AND   CICD.inventory_item_id = CPIC.inventory_item_id);

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows Inserted into CICD');

   END IF;   -- If p_copy_option = 2


   IF p_copy_option = 3 THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Remove and Replace Cost Information');
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

      --------------------------------------------------------------------------
      --Remove and replace all cost information
      -- Logic:
      --  * Copy the based_on_rollup_flag for the p_to_cost_type_id items in CIC
      --    to cst_item_costs_interface
      --  * Delete the p_to_cost_type_id items in CIC, CICD.
      --  * Items get their  p_to_cost_type_id costs from p_from_cost_type_id.
      --    The based_on_rollup_flag is copied from CICI for items that had rows
      --------------------------------------------------------------------------


      --------------------------------------------------------------------------
      -- step 1> Deleting existing cost information from CICD
      --         for the p_to_cost_type_id, p_to_org_id, item
      --------------------------------------------------------------------------

      l_stmt_num :=  90;


      DELETE cst_item_cost_details CICD
      WHERE CICD.cost_type_id    = p_to_cost_type_id
      AND   CICD.organization_id = p_to_org_id
      AND (p_range = 1
                OR
          (p_range = 2 AND CICD.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CICD.inventory_item_id
                   AND    p_range               = 5)
           );

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows deleted from CICD');


      --------------------------------------------------------------------------
      -- step 2> Copying rollup flags, then Deleting existing cost information from CIC
      --         for the p_to_cost_type_id, p_to_org_id, item
      --------------------------------------------------------------------------

      l_stmt_num := 95;

      l_grp_id := 0;

      SELECT CST_LISTS_S.NEXTVAL INTO l_grp_id
      FROM dual;

      INSERT INTO cst_item_costs_interface
      (     inventory_item_id
      ,     cost_type_id
      ,     based_on_rollup_flag
      ,     group_id
      )
      SELECT
   	    inventory_item_id
      ,     p_to_cost_type_id
      ,     based_on_rollup_flag
      ,     l_grp_id
      FROM cst_item_costs CIC
      WHERE CIC.cost_type_id = p_to_cost_type_id
      AND   CIC.organization_id = p_to_org_id
      AND (p_range = 1
                OR
          (p_range = 2 AND CIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CIC.inventory_item_id
                   AND    p_range               = 5)
           )
      AND EXISTS
          (SELECT NULL
           FROM   cst_pac_item_costs cpic
	   WHERE  cpic.cost_group_id = p_from_cost_group_id
           AND    cpic.pac_period_id = p_period_id
           AND    cpic.inventory_item_id = cic.inventory_item_id);

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rollup Flags backed up from CIC to CICI');


      l_stmt_num :=  100;


      DELETE cst_item_costs CIC
      WHERE CIC.cost_type_id    = p_to_cost_type_id
      AND   CIC.organization_id = p_to_org_id
      AND (p_range = 1
                OR
          (p_range = 2 AND CIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CIC.inventory_item_id
                   AND    p_range               = 5)
           );

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows deleted from CIC');


      --------------------------------------------------------------------------
      -- step 3> Inserting costs from CPIC
      --         to the costs for p_to_org_id, p_to_cost_type_id, item in CIC
      --         and removing backed up rollup flags from cst_item_costs_interface
      --------------------------------------------------------------------------


      l_stmt_num :=  110;


      INSERT INTO cst_item_costs
      (     inventory_item_id
      ,     organization_id
      ,     cost_type_id
      ,     last_update_date
      ,     last_updated_by
      ,     creation_date
      ,     created_by
      ,     last_update_login
      ,     inventory_asset_flag
      ,     lot_size
      ,     based_on_rollup_flag
      ,     shrinkage_rate
      ,     defaulted_flag
      ,     cost_update_id
      ,     pl_material
      ,     pl_material_overhead
      ,     pl_resource
      ,     pl_outside_processing
      ,     pl_overhead
      ,     tl_material
      ,     tl_material_overhead
      ,     tl_resource
      ,     tl_outside_processing
      ,     tl_overhead
      ,     material_cost
      ,     material_overhead_cost
      ,     resource_cost
      ,     outside_processing_cost
      ,     overhead_cost
      ,     pl_item_cost
      ,     tl_item_cost
      ,     item_cost
      ,     unburdened_cost
      ,     burden_cost
      ,     request_id
      ,     program_application_id
      ,     program_id
      ,     program_update_date
      )
      SELECT
            CPIC.inventory_item_id
      ,     p_to_org_id
      ,     p_to_cost_type_id
      ,     SYSDATE
      ,     l_user_id
      ,     SYSDATE
      ,     l_user_id
      ,     l_login_id
      ,     decode(MSI.inventory_asset_flag, 'Y', 1, 2) --inventory_asset_flag
      ,     nvl(MSI.std_lot_size,1)
      ,     nvl(BORF.based_on_rollup_flag, nvl(dBORF.based_on_rollup_flag,1)) -- set the borf to pre-existing value/default
      ,     nvl(MSI.shrinkage_rate,0)
      ,     2					-- defaulted_flag
      ,     NULL				-- cost_update_id
      ,     CPIC.pl_material
      ,     CPIC.pl_material_overhead
      ,     CPIC.pl_resource
      ,     CPIC.pl_outside_processing
      ,     CPIC.pl_overhead
      ,     CPIC.tl_material
      ,     CPIC.tl_material_overhead
      ,     CPIC.tl_resource
      ,     CPIC.tl_outside_processing
      ,     CPIC.tl_overhead
      ,     CPIC.material_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.material_overhead_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.resource_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.outside_processing_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.overhead_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.pl_item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.tl_item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.unburdened_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPIC.burden_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     l_request_id
      ,     702
      ,     l_program_id
      ,     SYSDATE
      FROM cst_pac_item_costs CPIC,
           mtl_system_items MSI,
           (SELECT inventory_item_id, based_on_rollup_flag
            FROM cst_item_costs_interface
            WHERE group_id = l_grp_id) BORF, -- based_on_rollup_flag backed up from destination cost type
           (SELECT cic.inventory_item_id, cic.based_on_rollup_flag
            FROM cst_cost_types cct, cst_item_costs cic
            WHERE cic.organization_id = p_to_org_id
            AND cct.cost_type_id = p_to_cost_type_id
            AND cic.cost_type_id = cct.default_cost_type_id) dBORF -- based_on_rollup_flag from default cost type
      WHERE CPIC.pac_period_id = p_period_id
      AND   CPIC.cost_group_id = p_from_cost_group_id
      AND   CPIC.inventory_item_id = MSI.inventory_item_id
      AND   MSI.organization_id = p_to_org_id
      AND   BORF.inventory_item_id(+) = CPIC.inventory_item_id
      AND   dBORF.inventory_item_id(+) = CPIC.inventory_item_id
      AND   (p_range = 1
                OR
            (p_range = 2 AND CPIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CPIC.inventory_item_id
                   AND    p_range               = 5)
             );

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows Inserted into CIC');

      l_stmt_num :=  115;

      DELETE cst_item_costs_interface
      WHERE group_id = l_grp_id;

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
                                        ||' Backup Rows deleted from CICI');

      --------------------------------------------------------------------------
      -- step 4> Getting costs from CPICD having the cost_layer_id
      --         as used above in CPIC and inserting
      --         to the costs for p_to_org_id, p_to_cost_type_id, item in CICD
      --------------------------------------------------------------------------


      l_stmt_num :=  120;


      INSERT INTO cst_item_cost_details
      (     inventory_item_id
      ,     organization_id
      ,     cost_type_id
      ,     last_update_date
      ,     last_updated_by
      ,     creation_date
      ,     created_by
      ,     last_update_login
      ,     level_type
      ,     resource_id
      ,     usage_rate_or_amount
      ,     basis_type
      ,     basis_resource_id
      ,     basis_factor
      ,     net_yield_or_shrinkage_factor
      ,     item_cost
      ,     cost_element_id
      ,     rollup_source_type
      ,     request_id
      ,     program_application_id
      ,     program_id
      ,     program_update_date
      )
      SELECT
            CPIC.inventory_item_id
      ,     p_to_org_id
      ,     p_to_cost_type_id
      ,     SYSDATE
      ,     l_user_id
      ,     SYSDATE
      ,     l_user_id
      ,     l_login_id
      ,     CPICD.level_type
      ,     decode(CPICD.cost_element_id,   -- For resource id
                   1, p_material,
                   2, p_material_overhead,
                   3, p_resource,
                   4, p_outside_processing,
                   5, p_overhead)
      ,     CPICD.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)  --usage_rate
      ,     1				-- basis_type
      ,     NULL 			-- basis_resource_id
      ,     1				-- basis_factor
      ,     1  				-- net_yield_or_shrinkage_factor
      ,     CPICD.item_cost *
				get_uom_conv_rate(CPIC.inventory_item_id,
						  l_master_org_id,
						  p_to_org_id)
      ,     CPICD.cost_element_id
      ,     1	    -- rollup_source_type
      ,     l_request_id
      ,     702
      ,     l_program_id
      ,     SYSDATE
      FROM  cst_pac_item_costs CPIC,
            cst_pac_item_cost_details CPICD,
            mtl_system_items MSI               -- Bug 2570867 - joined with MSI to select only to_org items
      WHERE CPIC.pac_period_id = p_period_id
      AND   CPIC.cost_group_id = p_from_cost_group_id
      AND   CPIC.cost_layer_id = CPICD.cost_layer_id
      AND   MSI.inventory_item_id = CPIC.inventory_item_id
      AND   MSI.organization_id = p_to_org_id
      AND   (p_range = 1
                OR
            (p_range = 2 AND CPIC.inventory_item_id = p_specific_item_id)
                OR
             EXISTS
                  (SELECT NULL
                   FROM   mtl_item_categories   MIC
                   WHERE  MIC.organization_id   = l_master_org_id
                   AND    MIC.category_id       = p_category_id
                   AND    MIC.category_set_id   = p_category_set_id
                   AND    MIC.inventory_item_id = CPIC.inventory_item_id
                   AND    p_range               = 5)
             );

      l_row_count := 0;
      l_row_count := SQL%ROWCOUNT;

      FND_FILE.PUT_LINE(FND_FILE.LOG, TO_CHAR(l_row_count)
					||' Rows Inserted into CICD');


   END IF;   --  If p_copy_option = 3

   COMMIT;


EXCEPTION

   WHEN cst_fail_uomconvert THEN

        l_err_num := 30001;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_FAIL_UOMCONVERT');

        l_err_msg := FND_MESSAGE.Get;
        l_err_msg := substrb('CSTPPCIC.copy_item_period_cost('|| to_char(l_stmt_num)|| ')' || ' : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg,1,240);

        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
        fnd_file.put_line(fnd_file.log,l_err_msg);

   WHEN cst_fail_parameters THEN

        l_err_num := 30001;
        l_err_code := SQLCODE;
        FND_MESSAGE.set_name('BOM', 'CST_FAIL_PARAMETERS');

        l_err_msg := FND_MESSAGE.Get;
        l_err_msg := substrb('CSTPPCIC.copy_item_period_cost('|| to_char(l_stmt_num)|| ')' || ' : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg,1,240);

        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
        fnd_file.put_line(fnd_file.log,l_err_msg);

   WHEN OTHERS THEN

        l_err_num := 30001;
        l_err_code := SQLCODE;
        l_err_msg  := TO_CHAR(l_stmt_num)||SUBSTR(SQLERRM,1,220);
        FND_MESSAGE.set_name('BOM', 'CST_PAC_INVALID_LE');
        l_err_msg := FND_MESSAGE.Get;
        l_err_msg := substrb('CSTPPCIC.copy_item_period_cost('|| to_char(l_stmt_num)|| ')' || ' : (' || to_char(l_err_num) || '):'|| l_err_code ||' : '||l_err_msg,1,240);

        CONC_STATUS := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',l_err_msg);
        fnd_file.put_line(fnd_file.log,l_err_msg);

END copy_item_period_cost;

END CSTPPCIC;

/
