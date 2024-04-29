--------------------------------------------------------
--  DDL for Package Body CZ_BOM_CONFIG_EXPLOSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_BOM_CONFIG_EXPLOSIONS_PKG" as
/* $Header: BOMCZCBB.pls 120.5.12010000.3 2009/04/08 17:15:13 abhissri ship $ */


/*
+=======================================================================+
| Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA |
|                       All rights reserved.                            |
+=======================================================================+
| NAME
|               BOMCZCBB.pls
|
| DESCRIPTION	: CZ_BOM_CONFIG_EXPLOSIONS_PKG, will insert mandatory
|		  and optional components of a selected configuration
|		  into BOM Tables.
| PARAMETERS
|
| NOTES
|
| MODIFIED (MM/DD/YY)
|
|       09/03/99	Rahul Chitko	Initial Creation
|	12/22/99	Rahul Chitko	The BOM_INS_MODEL_Mandatory procedure is
|				        changed to insert Mandatory items and
|					also the option items chosen for a
|					configuration. This procedure was
|					modified to also inherit the op-seq's
|					based on a profile option.
|
|              Modified on 24-AUG-2001 by Sushant Sawant: BUG #1957336
|                                         Added a new functionality for preconfi
gure bom.
|              Modified on 15-OCT-2001 by Sushant Sawant: BUG#2048023
|                                         Fixed matched_item_id variable in
|                                         perform_match procedure.
|
|              Modified on 18-OCT-2001 by Sushant Sawant: BUG#2048023
|                                         Fixed perform_match logic
|                                         loop is continued for all models
|
|
|              Modified on 19-NOV-2001 By Renga Kannan : Modified the sequence
|                                                        add a new sequence called
|                                                        BOM_CTO_ORDER_LINES_S1
|                                                        this sequence generates -ve nos
|                                                        This is because now, BCOL table
|                                                        is used for pre-config bom functionality
|                                                        We don't want any +ve seq, so that it won't
|                                                        converge with line_id field. There is a dependecy
|                                                        with bmobmsc.odf version 115.37
|
|              Modified on 10-APR-2002 By Sushant Sawant: Fixed BUG 2310435 and BUG 2312199
|                                         BUG 2310435 CUSTOMER BUG is similar to 2312199 INTERNAL BUG
|                                         The process_configurator_data code was dependent on the
|                                         parent_config_item_id being populated in the
|                                         cz_config_details_v table. This dependency has been
|                                         removed and the code has been changed to properly
|                                         identify the top model and the relationships to the
|                                         appropriate components.This bug was identified as a
|                                         common bom issue at agilent, however it is generic
|                                         in nature as CZ has started populating this field
|                                         randomly.
|
|              Modified on 23-APR-2002 By Sushant Sawant:
|                                         schedule_Ship_date populated as sysdate
|                                         instead of trunc(sysdate). This was causing
|                                         issues related to bom and routings if they
|                                         were created on the same day.
|
|              Modified on 15-MAY-2002 By Sushant Sawant:
|                                          Fixed bug 2372939
|                                          Error Message not propagated properly
|                                          from other cto routines to front end.
|
|
|             Modified on 17-JUL-2002 By  Kiran Konada
|                                         Fixed bug 2457660
|                                         changed the cursor C1 to pick quantity from CZ table rather than BIC
|                                         changed the debug message to print p_cz_config_hdr_id
|
|              Modified on 09-SEP-2002 By Kundan Sarkar:
|                                         Fixed bug 2550121 ( Customer bug 2394597 )
|                                         Preconfiguration fails when pre-config item is created
|                                         without any catalog group id but its base model has an
|                                         item catalog attached to it.
|

|
|              Modified on 21-APR-2004 By Sushant Sawant
|                                         Front Port for bug 3262450
|					  Instead of hard coding UOM , we need to get base model's
|					  UOM for pre-config item.
|
|
|
|
|              Modified on 21-APR-2004 By Sushant Sawant
|                                         Fixed bug 3285539. The Front Port bug 3262450 has been revisited.
|
|************************************************************************
|Following changes were pulled in while overloading old BOM_INS_MODEL_AND_MANDAT
ORY for backward compatibility.
|
|
|       03/12/02        Refai Farook    Changes to the operation sequence number
 inheritance.
|                                       Inheritance should occur from the near p
arent which has valid op.seq
|       03/26/02        Refai Farook    Operation sequence number inheritance lo
gic has been changed
|       03/27/02        Refai Farook    Club component quantitites will be using
 rowid to identify the unique
|                                       row from bom_explosion_temp
|
|************************************************************************
|
|
|
|              Modified on 26-DEC-2002 by Sushant Sawant: BUG #2726217
|                                         Replicated Overloading Changes to main
|
|              Modified on 28-JAN-2003 by Sushant Sawant: BUG #2756186
|                                         Added additional out parameter
|                                         x_routing_exists to create_preconfig_item_ml
|                                         to indicate whether routing already
|                                         exists for the preconfigured item.
|
|              Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items.

+=======================================================================
*/


  TYPE bcol_tbl_type is table of bom_cto_order_lines%rowtype INDEX by BINARY_INTEGER ;

  PROCEDURE INSERT_INTO_BCOL (
      p_bcol_tab  bcol_tbl_type
  );

  procedure populate_link_to_line_id(
     p_bcol_tab   in out NOCOPY bcol_tbl_type
  ) ;

 PROCEDURE populate_parent_ato
 ( p_t_bcol  in out NOCOPY bcol_tbl_type,
  p_bcol_line_id in       bom_cto_order_lines.line_id%type );

 PROCEDURE populate_plan_level
 ( p_t_bcol  in out NOCOPY bcol_tbl_type );

 procedure contiguous_to_sparse_bcol(
  p_t_bcol  in out NOCOPY bcol_tbl_type
 );

 procedure sparse_to_contiguous_bcol(
  p_t_bcol  in out NOCOPY bcol_tbl_type
 );

  procedure process_configurator_data ( p_group_id IN NUMBER,
                                        p_bill_sequence_id IN NUMBER,
                                        p_top_bill_sequence_id IN NUMBER,
                                        p_top_predefined_item_id IN NUMBER,
                                        p_validation_org_id IN NUMBER,
                                        p_current_org_id IN NUMBER,
					p_cz_config_hdr_id	IN NUMBER,
					p_cz_config_rev_num	IN NUMBER,
                                        x_top_ato_line_id OUT NOCOPY NUMBER,
                                        x_top_matched_item_id OUT NOCOPY NUMBER,
                                        x_match_profile_on    OUT NOCOPY VARCHAR2,
                                        x_match_found         OUT NOCOPY VARCHAR2,
                                        x_message  IN OUT NOCOPY VARCHAR2
  );

/*
  procedure create_preconfig_item_ml(
     p_use_matched_item     in varchar2,
     p_match_profile_on     in varchar2,
     p_top_predefined_item_id      in number,
     p_top_ato_line_id       in  bom_cto_order_lines.ato_line_id%type,
     x_bill_sequence_id      out number,
     x_mlmo_item_created     out varchar2
  ) ;

*/

  procedure perform_match(
     p_ato_line_id           in  bom_cto_order_lines.ato_line_id%type ,
     x_match_found           out NOCOPY varchar2,
     x_matching_config_id    out NOCOPY number,
     x_error_message         out NOCOPY VARCHAR2,
     x_message_name          out NOCOPY varchar2
  );




  PROCEDURE Insert_Row(X_Rowid                   IN OUT NOCOPY VARCHAR2,
		       x_bill_sequence_id		NUMBER := NULL,
                       X_Top_Bill_Sequence_Id           NUMBER,
                       X_Organization_Id                NUMBER,
                       X_Group_Id                       NUMBER,
                       X_Effectivity_Date               DATE,
                       X_Sort_Order                     VARCHAR2,
                       X_Select_Flag                    VARCHAR2,
                       X_Select_Quantity                NUMBER,
                       X_Session_Id                     NUMBER,
                       X_Context                        VARCHAR2,
                       X_Attribute1                     VARCHAR2,
                       X_Attribute2                     VARCHAR2,
                       X_Attribute3                     VARCHAR2,
                       X_Attribute4                     VARCHAR2,
                       X_Attribute5                     VARCHAR2,
                       X_Attribute6                     VARCHAR2,
                       X_Attribute7                     VARCHAR2,
                       X_Attribute8                     VARCHAR2,
                       X_Attribute9                     VARCHAR2,
                       X_Attribute10                    VARCHAR2,
                       X_Attribute11                    VARCHAR2,
                       X_Attribute12                    VARCHAR2,
                       X_Attribute13                    VARCHAR2,
                       X_Attribute14                    VARCHAR2,
                       X_Attribute15                    VARCHAR2
  ) IS
    CURSOR C IS SELECT rowid FROM BOM_CONFIG_EXPLOSIONS
                 WHERE group_id = X_Group_Id
                 AND   sort_order = X_Sort_Order;

   BEGIN

	--
	-- The cursor cfgdetv executing in CZLDCFGR.pld will pass the top_sequence and sort_order
	-- values to this procedure and only the Option Classes and the option selected from the
	-- option classes will be inserted into BOM_INVENTORY_COMPONENTS when this statement
	-- executes.
	--
     INSERT INTO BOM_INVENTORY_COMPONENTS
    (
      bill_sequence_id,
      component_sequence_id,
      component_item_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      component_quantity,
      component_yield_factor,
      planning_factor,
      quantity_related,
      include_in_cost_rollup,
      so_basis,
      optional,
      mutually_exclusive_options,
      check_atp,
      shipping_allowed,
      required_to_ship,
      required_for_revenue,
      include_on_ship_docs,
      include_on_bill_docs,
      low_quantity,
      high_quantity,
      pick_components,
      bom_item_type,
      operation_seq_num,
      item_num,
      effectivity_date,
      disable_date,
      implementation_date,
      wip_supply_type
    )
      SELECT
      x_bill_sequence_id,
      BOM_INVENTORY_COMPONENTS_S.NEXTVAL,
      be.component_item_id,
      be.creation_date,
      be.created_by,
      be.last_update_date,
      be.last_updated_by,
      be.attribute1,
      be.attribute2,
      be.attribute3,
      be.attribute4,
      be.attribute5,
      be.attribute6,
      be.attribute7,
      be.attribute8,
      be.attribute9,
      be.attribute10,
      be.attribute11,
      be.attribute12,
      be.attribute13,
      be.attribute14,
      be.attribute15,
      round( be.component_quantity,7 ), /* Support Decimal Qty for Option Items */
      bic.component_yield_factor,
      bic.planning_factor,
      bic.quantity_related,
      bic.include_in_cost_rollup,
      be.so_basis,
      be.optional,
      be.mutually_exclusive_options,
      be.check_atp,
      be.shipping_allowed,
      be.required_to_ship,
      be.required_for_revenue,
      be.include_on_ship_docs,
      be.include_on_bill_docs,
      be.low_quantity,
      be.high_quantity,
      be.pick_components,
      be.bom_item_type,
      be.operation_seq_num,
      be.item_num,
      be.effectivity_date,
      be.disable_date,
      be.implementation_date,
      bic.wip_supply_type
     FROM  BOM_EXPLOSIONS be,
	   bom_inventory_components bic
     WHERE be.TOP_BILL_SEQUENCE_ID = X_Top_Bill_Sequence_Id
     AND   be.ORGANIZATION_ID      = X_Organization_Id
     AND   be.EXPLOSION_TYPE       = 'OPTIONAL'
     AND   be.SORT_ORDER           = X_Sort_Order
     AND   be.EFFECTIVITY_DATE     <= X_Effectivity_Date
     AND   be.DISABLE_DATE         >  X_Effectivity_Date
     AND   bic.component_sequence_id = be.component_sequence_id;

   /*
    OPEN C;
    FETCH C INTO X_Rowid;
    if (C%NOTFOUND) then
      CLOSE C;
      Raise NO_DATA_FOUND;
    end if;
    CLOSE C;
   */

   IF SQL%ROWCOUNT = 0
   THEN
	RAISE NO_DATA_FOUND;
   END IF;

  END Insert_Row;


   /****************************************************************************************
   * Procedure	: Transfer_Comps
   * Parameters : Bill Sequence ID
   * Purpose	: Will transfer components for a chosen configuration from the temp table to
   *		  production table and will also clean up the temporary table.
   *
   *****************************************************************************************/
   Procedure Transfer_Comps
   (  p_bill_sequence_id IN NUMBER)
   IS
   BEGIN

-- dbms_output.put_line('Within Transfer of Components . . . ');

	INSERT INTO BOM_INVENTORY_COMPONENTS
	(
	bill_sequence_id,
	component_sequence_id,
	component_item_id,
	creation_date,
	created_by,
	last_update_date,
	last_updated_by,
	attribute1,
	attribute2,
	attribute3,
	attribute4,
	attribute5,
	attribute6,
	attribute7,
	attribute8,
	attribute9,
	attribute10,
	attribute11,
	attribute12,
	attribute13,
	attribute14,
	attribute15,
	component_quantity,
	component_yield_factor,
	planning_factor,
	quantity_related,
	include_in_cost_rollup,
	so_basis,
	optional,
	mutually_exclusive_options,
	check_atp,
	shipping_allowed,
	required_to_ship,
	required_for_revenue,
	include_on_ship_docs,
	include_on_bill_docs,
	low_quantity,
	high_quantity,
	pick_components,
	bom_item_type,
	operation_seq_num,
	item_num,
	effectivity_date,
	disable_date,
	implementation_date,
	wip_supply_type,
        From_End_Item_Unit_Number,
        To_End_Item_Unit_Number
	)
	SELECT
	bill_sequence_id,
	BOM_INVENTORY_COMPONENTS_S.nextval,
	be.Component_Item_Id,
	SYSDATE,
	1,
	SYSDATE,
	1,
	be.Attribute1,
	be.Attribute2,
	be.Attribute3,
	be.Attribute4,
	be.Attribute5,
	be.Attribute6,
	be.Attribute7,
	be.Attribute8,
	be.Attribute9,
	be.Attribute10,
	be.Attribute11,
	be.Attribute12,
	be.Attribute13,
	be.Attribute14,
	be.Attribute15,
	round( be.Component_Quantity, 7 ), /* Support Decimal-Qty for Option Items */
	1, /* Component Yield*/
	be.planning_factor,   /*Component Planning factor */
	NVL(to_number(be.so_transactions_flag),2),   /* used for Quantity Related  */
	be.include_in_rollup_flag,   /* Include in Cost Rollup */
	be.so_basis, /* SO Basis */
	be.optional, /* Optional */
	be.mutually_exclusive_options, /*Mutually_Exclusive_Options */
	be.check_atp,  /*Check_ATP*/
	2, /*Shipping Allowed */
	2, /*Required to ship */
	2, /*Required_For_Revenue*/
	2, /*Include on Ship Docs */
	2, /*Include_On_Bill_Docs */
	be.Low_Quantity,
	be.High_Quantity,
	DECODE(be.pick_components_flag, 'Y', 1, 2), /* Pick_Components */
	be.Bom_Item_Type,
	be.operation_seq_num, /*Operation Sequence Num */
	be.item_num, /*Item_Num */
	SYSDATE,
	be.disable_date, /*Disable_Date*/
	SYSDATE, /* Implementation Date */
	be.wip_supply_type, /* wip_supply_type */
	substr(be.pricing_attribute1,1,30), /* Used for From_Unit_Number */
	substr(be.pricing_attribute2,1,30) /* Used for  To_Unit_Number */
   FROM bom_explosion_temp be
  WHERE be.bill_sequence_id = p_Bill_Sequence_id;

-- dbms_output.put_line('Transfer Complete . . .No. Of Comps Transfered: ' || sql%rowcount);

   EXCEPTION
	WHEN OTHERS THEN
		-- dbms_output.put_line('Exception when transferring comps ' ||
		--	SQLERRM);
		null;
   END Transfer_Comps;

   /*****************************************************************************************
    * Procedure	: Club_Component_Quantities (Local)
    * Parameters: Bill Sequence ID
    * Purpose	: Will go through the components and consolidate components with the same
    *		  component item ID and operation sequence. The component quantities for all
    *		  such components will be added and only one record will be kept and the rest
    *		  will be deleted.
    ****************************************************************************************/
   Procedure Club_Component_Quantities
   (  p_bill_sequence_id 	NUMBER )
   IS
        CURSOR c_Club_Comps IS
        SELECT  bet.bill_sequence_id
              , bet.component_item_id
              , bet.operation_seq_num
              , bet.component_sequence_id
              , round( bet.component_quantity, 7 ) component_quantity /* Support Decimal-Qty for Option Items */
              , rowid                  /* Sushant added on 19-Aug-2002 */
          FROM bom_explosion_temp bet
         WHERE bill_sequence_id = p_bill_sequence_id
      ORDER BY bet.bill_sequence_id,
               bet.component_item_id,
               bet.operation_seq_num;

	l_component_item_id	NUMBER := NULL;
	l_operation_seq_num	NUMBER := NULL;
	l_component_seq_id	NUMBER := NULL;
	l_quantity		NUMBER := NULL;
        l_rowid                 VARCHAR2(50); /* Added by Sushant on 19-Aug-2002*/

	cursor bill_list is
	select component_item_id, operation_seq_num, component_sequence_id
	  from bom_explosion_temp
	 where bill_sequence_id = p_bill_sequence_id
	 order by component_item_id;
   BEGIN

	FOR c_components IN c_Club_Comps
	LOOP
		IF l_component_item_id = c_components.component_item_id AND
		   l_operation_seq_num = c_components.operation_seq_num
		THEN
			l_quantity := l_quantity +  c_components.component_quantity;
-- dbms_output.put_line('Found ' || l_component_item_id);

			-- And then delete the component
			DELETE FROM Bom_Explosion_Temp
                        WHERE rowid = c_components.rowid; /* changed by Sushant on 19-AUG-2002 */
/*
                       WHERE component_sequence_id = c_components.component_sequence_id
                         AND bill_sequence_id      = p_bill_sequence_id;
*/

-- dbms_output.put_line('deleted ' || c_components.component_sequence_id);

		END IF;

		IF l_component_item_id <> c_components.component_item_id OR
                   l_operation_seq_num <> c_components.operation_seq_num
		THEN

			-- Update the Component and then reset the local variables
			UPDATE BOM_EXPLOSION_TEMP
			   SET component_quantity = l_quantity
                        WHERE rowid = l_rowid; /* Changed by Sushant on 19-Aug-2002 */
/*
                         WHERE component_sequence_id = l_component_seq_id;
*/

			l_component_item_id := c_components.component_item_id;
                        l_operation_seq_num := c_components.operation_seq_num;
			l_component_seq_id  := c_components.component_sequence_id;
-- dbms_output.put_line('Comp Seq: ' || l_component_seq_id);

			l_quantity 	    := c_components.component_quantity;
                        l_rowid             := c_components.rowid; /* Added by Sushant on 19-Aug-2002 */

		END IF;

		IF l_component_item_id IS NULL AND
                   l_operation_seq_num IS NULL
                THEN
-- dbms_output.put_line('null so assigning ');

                        l_component_item_id := c_components.component_item_id;
                        l_operation_seq_num := c_components.operation_seq_num;
                        l_quantity 	    := c_components.component_quantity;
                        l_component_seq_id  := c_components.component_sequence_id;
-- dbms_output.put_line('l_comp_id assigned: ' || l_component_item_id);
                        l_rowid             := c_components.rowid;/* Added by Sushant on 19-Aug-2002 */


                END IF;



	END LOOP;		/* Changed by Sushant on 20-Aug-2002 */

 /* Update the last component which will be left out in the loop */
/* Added by Sushant on 19-Aug-2002 */
        UPDATE BOM_EXPLOSION_TEMP
         SET component_quantity = l_quantity
         WHERE rowid = l_rowid;


   END Club_Component_Quantities;

  /************************************************************************************
   * Procedure	: Set_Op_Seq (Local)
   * Parameters : Organization_Id
   *		  Component_item_id
   *		  Operation Sequence Number
   * Purpose	: Recursively traverse down the tree of option classes and set the op-seq
   *		  for any components from the option class that are chosen for a configuration
   *************************************************************************************/
  PROCEDURE Set_Op_Seq
	   (  p_organization_id	   IN  NUMBER
	    , p_component_item_id  IN  NUMBER
	    , p_operation_seq_num  IN  NUMBER
	   )
  IS
	CURSOR c_oc_comps IS
	SELECT  bic.bill_sequence_id
	      , bic.component_sequence_id
	      , bic.operation_seq_num
	      , bic.component_item_id
	  FROM bom_inventory_components bic,
	       bom_bill_of_materials bom
	 WHERE -- bic.operation_seq_num = 1 AND  /* Changed by Sushant on 19-Aug-2002*/
               bic.bill_sequence_id  = DECODE(bom.common_bill_sequence_id, NULL,
					      bom.bill_sequence_id, bom.common_bill_sequence_id)
	   AND bom.assembly_item_id = p_component_item_id
	   AND bom.organization_id  = p_organization_id
	   AND bom.alternate_bom_designator IS NULL;

       l_operation_seq_num NUMBER; /* Added by Sushant on 19-Aug-2002 */

  BEGIN

		FOR c_comps_of_options IN c_oc_comps
		LOOP

			-- When it is identified that this component has a bill
			-- the process must look at its children and assign the right
			-- operation sequences


-- dbms_output.put_line('Checking if any components of ' || c_comps_of_options.component_item_id || ' are bill themselves . . . ');

                IF c_comps_of_options.operation_seq_num <> 1 THEN
                  l_operation_seq_num := c_comps_of_options.operation_seq_num;
                ELSE
                  l_operation_seq_num := p_operation_seq_num;
                END IF;


			Set_Op_Seq
			(  p_organization_id	=> p_organization_id
			 , p_component_item_id	=> c_comps_of_options.component_item_id
			 , p_operation_seq_num	=> p_operation_seq_num
			 );

                     IF c_comps_of_options.operation_seq_num = 1 THEN /* Added by sushant on 19-Aug-2002 */
			BEGIN
				UPDATE bom_explosion_temp
                                   SET operation_seq_num = l_operation_seq_num /* Changed by Sushant on 19-Aug-2002 */
			         WHERE component_sequence_id =
						c_comps_of_options.component_sequence_id;


--dbms_output.put_line('Updated ' || SQL%ROWCOUNT || ' rows for seq:' || c_comps_of_options.component_sequence_id);
				EXCEPTION
				   WHEN NO_DATA_FOUND THEN
					null;
					-- This exception only means that a component under this
					-- OC was not selected for the configured bill
			END;
                    END IF; /* Added by Sushant on 19-Aug-2002 */
		END LOOP;

  END Set_Op_Seq;


  /*******************************************************************************************
  ** Procedure	: BOM_INS_MODEL_AND_MANDATORY
  ** Parameters : Group_Id
  **		  Bill_Sequence_Id
  **		  Cz_Config_Hdr_Id
  **		  Cz_Config_Rev_Num
  ** Purpose	: This procedure will be called when the configurator Applet Returns after the
  **		  user has Chosen a Configuration and hit Done. This procedure take the options
  **		  the user has chosen and the option classes that those options belong to and insert
  **		  them in a temporary table. Then it will take all the mandatory components that
  **		  are associated with the option classes from which a user has chosen atleast 1
  **		  Option and insert the data in a temporary table.
  **		  Once the required data is gathered under one group id, the process will check if
  **		  the Profile "BOM:CONFIG_INHERIT_OP_SEQ" is set.If YES then the procedure will
  ** 		  loop through the option classes and assign the operation sequence to its children
  **		  if the children have an op_seq of 1. This process will recursively loop through
  **		  its children and perform the operation sequence inheritance for all the children.
  **		  Once the records have been assigned the proper op-seq's the process will then
  **		  proceed to consolidate the components. Components quantities for components with
  **		  the same op-seq and component_item_id will be added and only 1 record for that
  **		  combination will exist and the duplicates will be deleted. The final data will be
  **		  moved from the temporary table to the production table and the data in the temp
  **		  table will be cleaned up.
  ********************************************************************************************/

  PROCEDURE BOM_INS_MODEL_AND_MANDATORY(p_group_id IN NUMBER,
                                        p_bill_sequence_id IN NUMBER,
                                        p_top_bill_sequence_id IN NUMBER,
                                        p_top_predefined_item_id IN NUMBER,
                                        p_validation_org_id  IN NUMBER,
                                        p_current_org_id  IN NUMBER,
					p_cz_config_hdr_id	IN NUMBER,
					p_cz_config_rev_num	IN NUMBER,
                                        x_top_ato_line_id  OUT NOCOPY NUMBER,
                                        x_top_matched_item_id  OUT NOCOPY NUMBER,
                                        x_match_profile_on  OUT NOCOPY VARCHAR2,
                                        x_match_found  OUT NOCOPY VARCHAR2,
                                        x_message  IN OUT NOCOPY VARCHAR2) IS

  BEGIN

       /* Temporary fix, might need assembly item id for which the bill is being
 configured */

      /* BUG #1957336 Temporary change for preconfigure bom by Sushant Sawant */

      -- insert into my_debug_messages values ( ' header_id ' || to_char( p_cz_config_hdr_id ) ) ;
     CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' ,  ' header_id ' || to_char( p_cz_config_hdr_id ) ) ;

       CTO_UTILITY_PK.PC_BOM_BILL_SEQUENCE_ID := p_bill_sequence_id ;
       CTO_UTILITY_PK.PC_BOM_TOP_BILL_SEQUENCE_ID := p_top_bill_sequence_id ;
       CTO_UTILITY_PK.PC_BOM_CURRENT_ORG := p_current_org_id ;



      /* BUG #1957336 Temporary change for preconfigure bom by Sushant Sawant */
       --insert into my_debug_messages values( ' bill_sequence_id ' || to_char( p_bill_sequence_id ) || ' top_bill_sequence_id ' || to_char( p_top_bill_sequence_id ) ) ;

      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' bill_sequence_id ' || to_char( p_bill_sequence_id ) || ' top_bill_sequence_id ' || to_char( p_top_bill_sequence_id ) ) ;


       -- insert into my_debug_messages values( ' validation_org ' || to_char( p_validation_org_id) || ' current org ' || to_char( p_current_org_id ) ) ;
      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' validation_org ' || to_char( p_validation_org_id) || ' current org ' || to_char( p_current_org_id ) ) ;



        if( p_top_predefined_item_id is not null ) then
       -- insert into my_debug_messages values( ' predefined_item_id ' || to_char( p_top_predefined_item_id )  ) ;
      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' predefined_item_id ' || to_char( p_top_predefined_item_id )  ) ;

          null ;
       else
          -- insert into my_debug_messages values ( ' predefined_item_id is null ' ) ;
         CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' predefined_item_id is null ' ) ;

          null ;

       end if ;





        process_configurator_data( p_group_id ,
                                   p_bill_sequence_id ,
                                   p_top_bill_sequence_id ,
                                   p_top_predefined_item_id ,
                                   p_validation_org_id,
                                   p_current_org_id,
                                   p_cz_config_hdr_id,
                                   p_cz_config_rev_num,
                                   x_top_ato_line_id ,
                                   x_top_matched_item_id ,
                                   x_match_profile_on ,
                                   x_match_found ,
                                   x_message
        ) ;


       -- insert into my_debug_messages values( ' top_ato_line_id ' || to_char( x_top_ato_line_id )  ) ;
       -- insert into my_debug_messages values( ' top_matched_item_id ' || to_char( x_top_matched_item_id )  ) ;

       -- insert into my_debug_messages values( ' match_profile_on ' || x_match_profile_on  ) ;


      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' top_ato_line_id ' || to_char( x_top_ato_line_id )  ) ;
      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' top_matched_item_id ' || to_char( x_top_matched_item_id )  ) ;

      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'BOM_INS_MODEL' , ' match_profile_on ' || x_match_profile_on  ) ;

       return ;



  END BOM_INS_MODEL_AND_MANDATORY ;







  procedure process_configurator_data ( p_group_id IN NUMBER,
                                        p_bill_sequence_id IN NUMBER,
                                        p_top_bill_sequence_id IN NUMBER,
                                        p_top_predefined_item_id IN NUMBER,
                                        p_validation_org_id    IN NUMBER,
                                        p_current_org_id       IN NUMBER,
					p_cz_config_hdr_id     IN NUMBER,
					p_cz_config_rev_num    IN NUMBER,
                                        x_top_ato_line_id     OUT NOCOPY NUMBER,
                                        x_top_matched_item_id OUT NOCOPY NUMBER,
                                        x_match_profile_on    OUT NOCOPY VARCHAR2,
                                        x_match_found         OUT NOCOPY VARCHAR2,
                                        x_message  IN OUT NOCOPY VARCHAR2)
  IS

   TYPE config_data_rec_type is RECORD (
          line_id                NUMBER ,
          config_item_id         cz_config_details_v.config_item_id%type,
          config_hdr_id          cz_config_details_v.config_hdr_id%type,
          parent_config_item_id  cz_config_details_v.parent_config_item_id%type,
          inventory_item_id      cz_config_details_v.inventory_item_id%type,
          component_code         cz_config_details_v.component_code%type,
          segment1               mtl_system_items.segment1%type,
          component_item_id      bom_inventory_components.component_item_id%type,
          component_sequence_id  bom_inventory_components.component_sequence_id%type,
          bom_item_type          bom_inventory_components.bom_item_type%type,
          wip_supply_type        bom_inventory_components.wip_supply_type%type,
          component_quantity     bom_inventory_components.component_quantity%type,
          config_orgs            mtl_system_items.config_orgs%type,
          config_match           mtl_system_items.config_match%type,
	  uom_code	         cz_config_details_v.uom_code%type --bugfix 4605114
   ) ;

  TYPE config_data_tbl_type is table of config_data_rec_type INDEX by BINARY_INTEGER ;


  config_data_tab          config_data_tbl_type ;

  bcol_tab                 bcol_tbl_type ;

  bcol_index               NUMBER := 0 ;

  gUserID         number       ;
  gLoginId        number       ;


  CURSOR C1 IS
   select
          config_item_id ,
          parent_config_item_id,
          cz.inventory_item_id ,
          cz.component_code,
          msi.segment1,
          bic.component_item_id,
          nvl( bic.component_sequence_id , p_top_bill_sequence_id ) ,
          bic.bom_item_type,
          bic.wip_supply_type,
          --bic.component_quantity
          cz.quantity,                 --bugfix 2457660
          msi.config_orgs,
          msi.config_match,
	  cz.uom_code    --bugfix 4605114
   from   cz_config_details_v cz ,
          bom_inventory_components bic,
          mtl_system_items msi
   where  bic.component_sequence_id(+) = cz.component_sequence_id
    AND   msi.inventory_item_id = cz.inventory_item_id
    AND   cz.config_hdr_id  = p_cz_config_hdr_id
    AND   cz.config_rev_nbr = p_cz_config_rev_num
    AND   msi.organization_id = p_validation_org_id ;
    /* order by parent_config_item_id desc ; */


  v_step                varchar2(20) ;
  config_index          number := 0 ;
  v_ato_line_id          number ;
  v_validation_org_id  number := 204 ; /* Temporary fix for validation org */
  lMatchProfile         varchar2(10) ;

 l_custom_match_profile varchar2(10);

  v_perform_match       varchar2(1) ;

  -- x_match_found         varchar2(1);
  x_error_message       varchar2(1000) ;
  x_message_name        varchar2(1000) ;

  v_sqlcode             number ;
  v_sqlerrm             varchar2(2000 );

  v_top_model_item_id   number ;
  v_top_model_index number ;


  v_sysdate    DATE ;

 v_match_flag_tab     CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE ;
 v_sparse_tab         CTO_MATCH_CONFIG.MATCH_FLAG_TBL_TYPE ;

 i number ;
 x_return_status varchar2(1) ;
x_msg_count      number;
x_msg_data       varchar2(100);



  v_ck_line_id    number ;
  v_ck_ato_line_id   number ;
  v_ck_inventory_item_id number ;
  v_ck_config_item_id number ;
  v_ck_perform_match varchar2(10) ;


v_order_quantity_uom  varchar2(3) ; -- Bugfix 3262450 New variable

--bugfix 4440577
  TYPE parent_cfg_id_rec_type is RECORD( pcfg_id number --parent config item id
                                        );
  TYPE parent_cfg_id_tbl_type IS TABLE OF parent_cfg_id_rec_type INDEX by BINARY_INTEGER ;


  TYPE line_id_rec_type  is RECORD( line_id number
                                  );
  -- Begin Bugfix 7446162
  -- TYPE line_id_tbl_type IS TABLE OF line_id_rec_type INDEX by BINARY_INTEGER ;
  TYPE line_id_tbl_type IS TABLE OF line_id_rec_type INDEX by long ;
  -- End Bugfix 7446162

  tab_pci  parent_cfg_id_tbl_type; --table of CZ parent cfg id's sparse indexed by line_id
  tab_li   line_id_tbl_type;      --table of line id's sparse indexed by CZ cfg id's
--end 4440577


  BEGIN

      v_step := 'Step 1 ' ;


      v_sysdate := sysdate ;

      -- insert into my_debug_messages values ( ' came into process_configurator ' ) ;
     CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' came into process_configurator ' ) ;

     CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' latest changes as of 10-APR-2002 in process_configurator ' ) ;



      gUserId          := nvl(Fnd_Global.USER_ID, -1);
      gLoginId         := nvl(Fnd_Global.LOGIN_ID, -1);

      v_step := 'Step 2 ' ;

      lMatchProfile := FND_PROFILE.Value('BOM:MATCH_CONFIG');

      v_step := 'Step 3 ' ;

      /* Temporary statement needs to be fixed */
      CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG := p_validation_org_id ;

      v_step := 'Step 5 ' ;

      if( lMatchProfile = 1 ) then

             CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' Match is ON ' ) ;

             v_perform_match := 'Y'  ;
             x_match_profile_on := 'Y'  ;
      else
             CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' Match is OFF ' ) ;
             v_perform_match := 'N'  ;
             x_match_profile_on := 'N'  ;
      end if ;

      /* Temporary Statement v_perform_match := 'Y'  ;*/


      v_step := 'Step 8 ' ;

         /* BUGFIX FOR BUG#2310435 */
         select assembly_item_id
           into v_top_model_item_id
           from bom_bill_of_materials
           where bill_sequence_id = p_top_bill_sequence_id ;



      v_step := 'Step 10 ' ;

      open c1 ;

      WHILE(TRUE)
      LOOP

         config_index := config_data_tab.count + 1 ;

         fetch c1 into config_data_tab(config_index).config_item_id,
                       config_data_tab(config_index).parent_config_item_id,
                       config_data_tab(config_index).inventory_item_id,
                       config_data_tab(config_index).component_code,
                       config_data_tab(config_index).segment1,
                       config_data_tab(config_index).component_item_id,
                       config_data_tab(config_index).component_sequence_id,
                       config_data_tab(config_index).bom_item_type,
                       config_data_tab(config_index).wip_supply_type,
                       config_data_tab(config_index).component_quantity,
                       config_data_tab(config_index).config_orgs,
                       config_data_tab(config_index).config_match,
		       config_data_tab(config_index).uom_code; 	--4605114

         exit when c1%notfound ;


              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'cz_c_d '
               ||  ' hdr  '|| p_cz_config_hdr_id --bugfix2457660
               ||  ' itm ' || to_char( config_data_tab(config_index).config_item_id)
               ||  ' pci ' || to_char( config_data_tab(config_index).parent_config_item_id )
               ||  ' iid ' || to_char( config_data_tab(config_index).inventory_item_id )
               ||  ' ccd ' || config_data_tab(config_index).component_code
               ||  ' csd ' || to_char( config_data_tab(config_index).component_sequence_id )
               ||  ' bit ' || to_char( config_data_tab(config_index).bom_item_type )
               ||  ' wst ' || to_char( config_data_tab(config_index).wip_supply_type )
               ||  ' qty ' || to_char( config_data_tab(config_index).component_quantity)
               ||  ' behavior  ' || config_data_tab(config_index).config_orgs
               ||  ' match  ' || config_data_tab(config_index).config_match
	       ||  ' uom ' || config_data_tab(config_index).uom_code ) ;--bugfix 4605114




      END LOOP ;

      close c1 ;



      v_step := 'Step 12 ' ;





      v_step := 'Step 13 ' ;

      for i in 1..config_data_tab.count
      loop
         bcol_index := bcol_tab.count + 1 ;

         --multiplied by -1 to generate -ve sequnnce 'kkonada'
         -- Modified by Renga Kannan on 11/19/01
         -- Created a new sequence for Bom_cto_order_lines table
         -- Generate the line_id column with this new sequence
         -- This seqence will be a -ve sequence by itself.
         -- The -ve seq is used to avoid converging with om line_id
         -- IN the case of Bcol generation for Sales order
         -- Line_id is populated with Oe_line_id


         select bom_cto_order_lines_s1.nextval
           into bcol_tab(bcol_index).line_id
           from dual ;
         /* Temporary Fix, Need a new sequence for bom_cto_order_lines */

/*
         bcol_tab(bcol_index).header_id             := config_data_tab(1).parent_config_item_id ;
*/



         /* BUGFIX FOR BUG#2310435 */
         if( config_data_tab(i).inventory_item_id = v_top_model_item_id ) then
             v_top_model_index := i ;
         end if ;



         /* BUGFIX FOR BUG#2310435 */
         bcol_tab(bcol_index).header_id             := config_data_tab(1).config_hdr_id ;



         /* BUGFIX FOR BUG#2310435 */

/*
         bcol_tab(bcol_index).ato_line_id           := bcol_tab(1).line_id;
         bcol_tab(bcol_index).top_model_line_id     := bcol_tab(1).line_id ;
*/


         bcol_tab(bcol_index).inventory_item_id     := config_data_tab(i).inventory_item_id ;
         bcol_tab(bcol_index).component_code        := config_data_tab(i).component_code ;
         bcol_tab(bcol_index).component_sequence_id := config_data_tab(i).component_sequence_id ;
         bcol_tab(bcol_index).wip_supply_type       := config_data_tab(i).wip_supply_type ;

/*
         if( bcol_tab(bcol_index).line_id = bcol_tab(bcol_index).ato_line_id ) then
             bcol_tab(bcol_index).ordered_quantity      := 1 ;
             bcol_tab(bcol_index).bom_item_type         := '1' ;
             bcol_tab(bcol_index).plan_level            := 1 ;
             bcol_tab(bcol_index).component_code        := config_data_tab(i).inventory_item_id;
         else
             bcol_tab(bcol_index).ordered_quantity      := config_data_tab(i).component_quantity ;
             bcol_tab(bcol_index).bom_item_type         := config_data_tab(i).bom_item_type ;
         end if;

*/

         bcol_tab(bcol_index).ordered_quantity      := config_data_tab(i).component_quantity ;
         bcol_tab(bcol_index).bom_item_type         := config_data_tab(i).bom_item_type ;






         bcol_tab(bcol_index).order_quantity_uom     := config_data_tab(i).uom_code ; --4605114




         bcol_tab(bcol_index).schedule_ship_date    := v_sysdate ;
         bcol_tab(bcol_index).ship_from_org_id      := p_current_org_id  ;

         l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');


         if( lMatchProfile = 1 ) then
           if( l_custom_match_profile = 2 ) then
               bcol_tab(bcol_index).perform_match := nvl( config_data_tab(i).config_match , 'Y' ) ;
           else
               bcol_tab(bcol_index).perform_match := nvl( config_data_tab(i).config_match , 'C' ) ;
           end if;
         else
           bcol_tab(bcol_index).perform_match := 'N'  ;
         end if;


         bcol_tab(bcol_index).config_creation := nvl( config_data_tab(i).config_orgs , 1 )  ;
         bcol_tab(bcol_index).option_specific       := 'N' ;
         bcol_tab(bcol_index).reuse_config := 'N' ;






         /* audit columns */
         bcol_tab(bcol_index).creation_date         := sysdate ;
         bcol_tab(bcol_index).created_by            := gUserId ;
         bcol_tab(bcol_index).last_update_date      := sysdate ;
         bcol_tab(bcol_index).last_updated_by       := gUserId ;
         bcol_tab(bcol_index).program_id            := CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ;

         --bugfix 4440577
	 --tab_pci index by line_id and store cz parent config_id
	 tab_pci(bcol_tab(bcol_index).line_id).pcfg_id :=
	                        config_data_tab(i).parent_config_item_id;
         --bugfix 4440577
	 --tab_li index cz config item id and store bcol line id
	 tab_li(config_data_tab(i).config_item_id).line_id :=
	                          bcol_tab(bcol_index).line_id;



      end loop ;


      v_step := 'Step 14 ' ;
      /* BUGFIX FOR BUG#2310435 */

      for myindex in bcol_tab.first..bcol_tab.last
      loop

         bcol_tab(myindex).ato_line_id           := bcol_tab(v_top_model_index).line_id;
         bcol_tab(myindex).top_model_line_id     := bcol_tab(v_top_model_index).line_id ;

         if( bcol_tab(myindex).line_id = bcol_tab(v_top_model_index).ato_line_id ) then
             bcol_tab(myindex).ordered_quantity      := 1 ;
             bcol_tab(myindex).bom_item_type         := '1' ;
             bcol_tab(myindex).plan_level            := 1 ;
             bcol_tab(myindex).component_code        := config_data_tab(v_top_model_index).inventory_item_id;

         end if;

	 --populate link_to_line_id
	 --bugfix 4440577
	 if ( bcol_tab(myindex).line_id = bcol_tab(v_top_model_index).ato_line_id ) then
	      bcol_tab(myindex).link_to_line_id := null;
	 else
	    bcol_tab(myindex).link_to_line_id :=
	    tab_li( tab_pci(bcol_tab(myindex).line_id).pcfg_id).line_id;


	 end if;
	 --end 4440577


      end loop ;


      v_step := 'Step 15 ' ;
      --commented call to link_2_line_id as part of fix4440577
      --populate_link_to_line_id( bcol_tab) ;


      v_step := 'Step 16 ' ;

      v_ato_line_id := bcol_tab(v_top_model_index).line_id ;

      x_top_ato_line_id := v_ato_line_id ;


      v_step := 'Step 20 ' ;

      contiguous_to_sparse_bcol( bcol_tab ) ;

      v_step := 'Step 25 ' ;
      populate_plan_level(bcol_tab ) ;

      v_step := 'Step 30 ' ;

      populate_parent_ato(bcol_tab , v_ato_line_id ) ;


      v_step := 'Step 31 ' ;


    /*
    ** CHECK FOR INVALID MODEL SETUP
    **
    */


    i := bcol_tab.first ;
    while i is not null
    loop
          if( bcol_tab(i).bom_item_type = 1 and nvl(bcol_tab(i).wip_supply_type, 1 ) <> 6 and bcol_tab(i).config_creation in (1, 2) ) then

             if( bcol_tab(bcol_tab(i).parent_ato_line_id).config_creation = 3) then

                    oe_debug_pub.add('populate_bcol: ' || 'INVALID MODEL SETUP exists for line id  '  || bcol_tab(i).line_id
                                                       || ' model item ' || bcol_tab(i).inventory_item_id
                                                       || ' item type ' || bcol_tab(i).config_creation
                                      , 1 );
                    oe_debug_pub.add('populate_bcol: ' || ' parent line id  '  || bcol_tab(bcol_tab(i).parent_ato_line_id).line_id
                                                       || ' parent model item ' || bcol_tab(bcol_tab(i).parent_ato_line_id).inventory_item_id
                                                       || ' parent item type ' || bcol_tab(bcol_tab(i).parent_ato_line_id).config_creation
                                      , 1 );



                 x_message := 'CTO_INVALID_MODEL_SETUP' ;

                 cto_msg_pub.cto_message('BOM','CTO_INVALID_MODEL_SETUP');
                 raise FND_API.G_EXC_ERROR;

             end if;

          end if ;


          i := bcol_tab.next(i) ;

    end loop ;





    /*
    **  CALL TRANSFORMED MATCH ATTRIBUTES PENDING
    ** PENDING WORK!!!!
    */

    if( lMatchProfile = 1 ) then
         oe_debug_pub.add('populate_bcol: ' ||  ' preparing information for v_match_flag_tab ' , 3 );
         i :=bcol_tab.first ;

         while i is not null
         loop

             if( bcol_tab(i).bom_item_type = 1 and nvl( bcol_tab(i).wip_supply_type , 1 )  <> 6 ) then
                 v_match_flag_tab(v_match_flag_tab.count + 1).line_id := bcol_tab(i).line_id ;
                 v_match_flag_tab(v_match_flag_tab.count ).parent_ato_line_id := bcol_tab(i).parent_ato_line_id ;
                 v_match_flag_tab(v_match_flag_tab.count ).ato_line_id := bcol_tab(i).ato_line_id ;
                 v_match_flag_tab(v_match_flag_tab.count ).match_flag := bcol_tab(i).perform_match ;

             end if;

             i := bcol_tab.next(i) ;

         end loop ;


         oe_debug_pub.add('populate_bcol: ' ||  ' going to call cto_match_config.evaluate_n_pop_match_flag ' , 3 );

         cto_match_config.evaluate_n_pop_match_flag( p_match_flag_tab  => v_match_flag_tab
                                              , x_sparse_tab => v_sparse_tab
                                              , x_return_status => x_return_status
                                              , x_msg_count => x_msg_count
                                              , x_msg_data => x_msg_data );





         oe_debug_pub.add('populate_bcol: ' ||  ' populating match flag from results ' , 3 );

         i := v_sparse_tab.first ;

         while i is not null
         loop

             bcol_tab(i).perform_match := v_sparse_tab(i).match_flag ;

             oe_debug_pub.add('populate_bcol: ' ||  i || ' match set to '  || bcol_tab(i).perform_match , 3 );



             if( bcol_tab(i).line_id = bcol_tab(i).ato_line_id ) then
         oe_debug_pub.add('populate_bcol: ' ||  ' v_perform_match before ' || v_perform_match , 3 );
                 v_perform_match := bcol_tab(i).perform_match ;
                 x_match_profile_on := bcol_tab(i).perform_match ;

         oe_debug_pub.add('populate_bcol: ' ||  ' v_perform_match after ' || v_perform_match , 3 );

             end if ;
             i := v_sparse_tab.next(i) ;

         end loop ;

         oe_debug_pub.add('populate_bcol: ' ||  ' done populating match flag from results ' , 3 );


    else

         oe_debug_pub.add('populate_bcol: ' ||  ' will not be calling cto_match_config.evaluate_n_pop_match_flag ' , 3 );

    end if ;





      v_step := 'Step 40 ' ;

      insert_into_bcol( bcol_tab ) ;


      v_step := 'Step 45 ' ;
      if( v_perform_match = 'Y' ) then

          CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'Calling CTOMCFGB perform_match ' ) ;
          CTO_MATCH_CONFIG.perform_match( v_ato_line_id ,
                     x_return_status ,
                     x_msg_count,
                     x_msg_data
                    ) ;

              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'done CTOMCFGB perform_match ' ) ;


          select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
             perform_match , config_item_id   into x_match_found , x_top_matched_item_id
             from bom_cto_order_lines_gt
           where line_id = v_ato_line_id ;

              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'CTOMCFGB perform_match result ' || x_match_found  ) ;


           if( x_match_found = 'Y' ) then
               -- insert into my_debug_messages values ( 'Top Model Match Success ' ) ;
              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'Top Model Match Success ' ) ;
              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'Top Match '|| to_char( x_top_matched_item_id )  ) ;

               null ;

           end if ;

      end if ;

      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'copying bcolgt to bcol ' ) ;


      CTO_UTILITY_PK.copy_bcolgt_bcol( v_ato_line_id , x_return_status, x_msg_count, x_msg_data ) ;


       select line_id, ato_line_id, inventory_item_id, config_item_id , perform_match
       into  v_ck_line_id, v_ck_ato_line_id, v_ck_inventory_item_id,
             v_ck_config_item_id, v_ck_perform_match
       from bom_cto_order_lines
       where line_id = v_ato_line_id ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' BCOL INFO ' || v_ck_line_id)  ;


       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' line_id ' || v_ck_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' ato_line_id ' || v_ck_ato_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' inventory_item_id ' || v_ck_inventory_item_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' config_item_id ' || v_ck_config_item_id )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' perform_match ' || v_ck_perform_match )  ;







      CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , 'Done Sucessfully ' ) ;

  exception
           when others then
                  V_SQLCODE := SQLCODE ;
                  V_SQLERRM := SQLERRM ;


                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' came into exception at step ' || v_step ) ;
                 CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' exception in process configurator SQL ' || to_char( V_SQLCODE ) ) ;

                 CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'PROCESS_CONFIGURATOR_DATA' , ' exception in process configurator SQL ' || V_SQLERRM  ) ;


  END process_configurator_data ;


  /* Patchset J signature */
  procedure create_preconfig_item_ml(
     p_use_matched_item     in varchar2,
     p_match_profile_on     in varchar2,
     p_top_predefined_item_id      in number,
     p_top_matched_item_id      in number,
     p_top_ato_line_id       in  bom_cto_order_lines.ato_line_id%type,
     p_current_org_id        in number ,
     x_bill_sequence_id      out NOCOPY number,
     x_mlmo_item_created     out NOCOPY varchar2,
     x_routing_exists        out NOCOPY varchar2,
     x_return_status         out NOCOPY varchar2,
     x_msg_count             out NOCOPY number,
     x_msg_data              out NOCOPY varchar2,
     x_t_dropped_items         out NOCOPY CTO_CONFIG_BOM_PK.t_dropped_item_type
  )
  IS
  v_step                varchar2(20) ;
  begin

       v_step := 'Step 1 ' ;

       create_preconfig_item_ml( p_use_matched_item => p_use_matched_item
                               , p_match_profile_on => p_match_profile_on
                               , p_top_predefined_item_id => p_top_predefined_item_id
                               , p_top_matched_item_id    => p_top_matched_item_id
                               , p_top_ato_line_id        => p_top_ato_line_id
                               , p_current_org_id         => p_current_org_id
                               , x_bill_sequence_id       => x_bill_sequence_id
                               , x_mlmo_item_created      => x_mlmo_item_created
                               , x_routing_exists         => x_routing_exists
                               , x_return_status          => x_return_status
                               , x_msg_count              => x_msg_count
                               , x_msg_data               => x_msg_data ) ;

       v_step := 'Step 10 ' ;



                if x_return_status = FND_API.G_RET_STS_ERROR then

                      oe_debug_pub.add ('Create_Preconfig_Item_ML:New: ' ||
                                        'Failed in create_preconfig_item_ml with expected error.', 1);

        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                           ':NEW: failed in create_preconfig_item_ml ' || x_msg_data ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ':NEW: failed in create_preconfig_item_ml at step ' || to_char( x_msg_count) ) ;
		 CTO_CONFIG_BOM_PK.get_dropped_components( x_t_dropped_items ) ; -- Fp bug 5485452
                   raise FND_API.G_EXC_ERROR;

                elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then

                      oe_debug_pub.add ('Create_Preconfig_Item_ML:New: ' ||
                                        'Failed in create_preconfig_item_ml with unexpected error.', 1);

                   raise FND_API.G_EXC_UNEXPECTED_ERROR;
                end if;



       v_step := 'Step 15 ' ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                          ':NEW: going to call dropped components ' ) ;

       v_step := 'Step 20 ' ;

       CTO_CONFIG_BOM_PK.get_dropped_components( x_t_dropped_items ) ;


       v_step := 'Step 30 ' ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                          ':NEW: done dropped components ' ) ;

   exception
   when FND_API.G_EXC_ERROR then
        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                           ':NEW: came into expected exception create_preconfig_item_ml at step ' || v_step ) ;

        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                           ':NEW: came into expected exception create_preconfig_item_ml at step ' || x_msg_data ) ;
        x_return_status := FND_API.G_RET_STS_ERROR;

        CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );





   when FND_API.G_EXC_UNEXPECTED_ERROR then
        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                           ':NEW: came into unexpected exception create_preconfig_item_ml at step ' || v_step ) ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );


   when OTHERS then
        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' ,
                                           ':NEW: came into others exception create_preconfig_item_ml at step ' || v_step ) ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


        CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );


  end create_preconfig_item_ml ;



  procedure create_preconfig_item_ml(
     p_use_matched_item     in varchar2,
     p_match_profile_on     in varchar2,
     p_top_predefined_item_id      in number,
     p_top_matched_item_id      in number,
     p_top_ato_line_id       in  bom_cto_order_lines.ato_line_id%type,
     p_current_org_id        in number ,
     x_bill_sequence_id      out NOCOPY number,
     x_mlmo_item_created     out NOCOPY varchar2,
     x_routing_exists        out NOCOPY varchar2,
     x_return_status         out NOCOPY varchar2,
     x_msg_count             out NOCOPY number,
     x_msg_data              out NOCOPY varchar2
  )
  IS
  lStatus       integer ;
  XReturnStatus varchar2(1) ;
  XMsgCount     number ;
  XMsgData      varchar2(1000) ;
  v_step        varchar2(100) ;
  v_flow_calc   number ;
  v_ship_from_org_id number ;


  l_x_error_msg varchar2(200 ) ;
  l_x_msg_name  varchar2(200) ;

  lPerformMatch  varchar2(1) ;
       cursor c_can_configurations is
       select line_id, inventory_item_id , parent_ato_line_id , perform_match
       from   bom_cto_order_lines
       where  bom_item_type = '1'
       and    ato_line_id = p_top_ato_line_id
       and    nvl(wip_supply_type,0) <> 6
       order by plan_level desc;

  gUserId          number ;
  gLoginId         number  ;

  v_appl_name      varchar2(20) ;
  v_error_name      varchar2(20) ;

   -- start fix 2394597
  l_top_model_id        number;
  lprogram_id           number;
  lconfig_item_id       number;
  lValidationOrg        number;
  licg_id               number;
   -- end fix 2394597


  MATCHED_ITEM_BOM_NOT_FOUND exception  ;

  v_ck_line_id    number ;
  v_ck_ato_line_id   number ;
  v_ck_inventory_item_id number ;
  v_ck_config_item_id number ;
  v_ck_perform_match varchar2(10) ;


  v_dropped_count number := 0 ;

  begin

       gUserId  := nvl(Fnd_Global.USER_ID, -1) ;
       gLoginId := nvl(Fnd_Global.LOGIN_ID, -1);

       x_msg_data := null ;


        v_step := 'Step 1 ' ;

        -- insert into my_debug_messages values ( ' came into create_preconfig_item_ml ') ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into create_preconfig_item_ml ') ;



       select line_id, ato_line_id, inventory_item_id, config_item_id , perform_match
       into  v_ck_line_id, v_ck_ato_line_id, v_ck_inventory_item_id,
             v_ck_config_item_id, v_ck_perform_match
       from bom_cto_order_lines
       where line_id = p_top_ato_line_id ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' line_id ' || v_ck_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' ato_line_id ' || v_ck_ato_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' inventory_item_id ' || v_ck_inventory_item_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' config_item_id ' || v_ck_config_item_id )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' perform_match ' || v_ck_perform_match )  ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' use_matched_item ' || p_use_matched_item )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' top_predefined_item_id ' || p_top_predefined_item_id )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' top_matched_item_id ' || p_top_matched_item_id )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' p_match_profile_on ' || p_match_profile_on )  ;



       if( p_use_matched_item = 'N' and p_match_profile_on = 'Y' ) then

        -- insert into my_debug_messages values ( ' user has not opted to use matched item') ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' user has not opted to use matched item') ;

           update bom_cto_order_lines set config_item_id = p_top_predefined_item_id
            , perform_match = 'U'  where line_id =  p_top_ato_line_id ;

           update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
              bom_cto_order_lines_gt
              set config_item_id = p_top_predefined_item_id
            , perform_match = 'U'
              where line_id =  p_top_ato_line_id ;



        elsif( p_use_matched_item = 'N' ) then


           update bom_cto_order_lines set config_item_id = p_top_predefined_item_id
            , perform_match = 'N'  where line_id =  p_top_ato_line_id ;

           update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
              bom_cto_order_lines_gt
              set config_item_id = p_top_predefined_item_id
            , perform_match = 'N'
            where line_id =  p_top_ato_line_id ;




        else

           -- insert into my_debug_messages values ( ' user has opted to use matched item') ;
           CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' user has opted to use matched item') ;

           null ;


       end if;

        v_step := 'Step 5 ' ;

        -- insert into my_debug_messages values ( ' going to call populate_src_orgs ') ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' going to call populate_src_orgs ') ;

        -- insert into my_debug_messages values ( ' going to call populate_src_orgs ' || to_char( p_top_ato_line_id ) ) ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' going to call populate_src_orgs ' || to_char( p_top_ato_line_id ) ) ;




/*
        lStatus := CTO_MSUTIL_PUB.Populate_Src_Orgs(p_top_ato_line_id,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , x_msg_data  ) ;
       FND_MESSAGE.parse_encoded( x_msg_data, v_appl_name, v_error_name ) ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML '  , v_appl_name || ' err ' || v_error_name ) ;

       if( x_return_status = FND_API.G_RET_STS_ERROR ) then


            RAISE FND_API.G_EXC_ERROR;


        elsif( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        end if ;


        -- insert into my_debug_messages values ( ' returned from populate_src_orgs ') ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' returned from populate_src_orgs ') ;


*/




       -- start 2394597

        v_step := 'Step 9  ' ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' copying model catalog group id from validation org ') ;

       oe_debug_pub.add ('Getting top model item id.. ', 1) ;

       -- Following statement will select top model item id.
       -- Since only one row is expected to be returned this is implemented
       -- as SELECT statement  instead of using a CURSOR for multi-row

        select inventory_item_id , nvl(program_id,0) ,config_item_id
        into l_top_model_id,lprogram_id,lconfig_item_id
        from bom_cto_order_lines
	where line_id=p_top_ato_line_id ;

	oe_debug_pub.add ('Top Model Id : '||to_char(l_top_model_id)||' Program_id : '||to_char(lprogram_id)||' Config Item Id : '||to_char(lconfig_item_id), 2);


  	oe_debug_pub.add ('Getting Validation Org.. ', 1) ;


        if lprogram_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID then
                lValidationOrg := CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG ;
        end if;


        oe_debug_pub.add ('Validation Org : '||to_char(lValidationOrg), 2) ;

        -- Following statement will select item_catalog_grp_id
        -- of top model item id in validation org.

        select nvl(item_catalog_group_id,0)
        into licg_id
        from mtl_system_items
        where inventory_item_id = l_top_model_id
        and organization_id = lValidationOrg;

        oe_debug_pub.add ('Item Catalog Group Id : '||to_char(licg_id), 2) ;

        -- If the model item has catalog , that catalog group id
        -- is copied to preconfig item in all org

        if licg_id  <> 0 then
        update mtl_system_items
        set item_catalog_group_id = licg_id
        where inventory_item_id = lconfig_item_id
        and nvl(item_catalog_group_id,0) = 0;  --Bugfix 6043798
        oe_debug_pub.add ('Updated catalog group id of preconfig item ' , 2) ;
        end if;

        -- end fix 2394597



        v_step := 'Step 10  ' ;

       /*
       lStatus := CTO_ITEM_PK.create_all_items( p_top_ato_line_id ,XReturnStatus, XMsgCount, XMsgData ) ;
        */






       select line_id, ato_line_id, inventory_item_id, config_item_id , perform_match
       into  v_ck_line_id, v_ck_ato_line_id, v_ck_inventory_item_id,
             v_ck_config_item_id, v_ck_perform_match
       from bom_cto_order_lines
       where line_id = p_top_ato_line_id ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' BEFORE ITEM CHECK BCOL ' || v_ck_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' line_id ' || v_ck_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' ato_line_id ' || v_ck_ato_line_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' inventory_item_id ' || v_ck_inventory_item_id)  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' config_item_id ' || v_ck_config_item_id )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' perform_match ' || v_ck_perform_match )  ;

       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' use_matched_item ' || p_use_matched_item )  ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' top_predefined_item_id ' || p_top_predefined_item_id )  ;
         v_step := 'Step 11  ' ; -- Added as a part of bug 8305535











       lStatus := CTO_ITEM_PK.Create_And_Link_Item(p_top_ato_line_id,
                              xReturnStatus ,
                              xMsgCount ,
                              xMsgData  ,
                              'PRECONFIG' ) ;



                IF lStatus <> 1 then
                   oe_debug_pub.add ('Create_All_Items returned with 0', 1) ;
                   oe_debug_pub.add ('Create_All_Items returned with 0' || xMsgData , 1) ;
                   oe_debug_pub.add ('Create_All_Items returned with 0' || to_char(xMsgCount) , 1) ;

                   x_msg_count := xMsgCount ;
                   x_msg_data  := xMsgData ;

                   -- cto_msg_pub.cto_message('BOM','CTO_CREATE_ITEM_ERROR');

                   raise FND_API.G_EXC_ERROR;

                end if;



        -- insert into my_debug_messages values ( ' returned from CTO_ITEM_PK.create_all_items ') ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' returned from CTO_ITEM_PK.create_all_items ') ;



       v_step := 'Step 15  ' ;

       begin

           x_routing_exists := 'N'  ;

           v_step := 'Step 16  ' ;

           select 'Y' into x_routing_exists
             from dual
             where EXISTS (
                      select routing_sequence_id
                      from bom_operational_routings bor, bom_cto_src_orgs bcso
                      where bor.assembly_item_id = bcso.config_item_id
                        and bor.organization_id = bcso.organization_id
                        and bor.alternate_routing_designator is null
                        and bcso.line_id = p_top_ato_line_id
                        and bcso.create_bom = 'Y'
                     )  ;


       exception
          when no_data_found then
            x_routing_exists := 'N' ;

          when others then

              cto_wip_workflow_api_pk.cto_debug( 'CREATE_PRECONFIG_ITEM_ML' ,
                                     ' error in checking if routing exists ') ;

              raise fnd_api.g_exc_unexpected_error ;
       end ;





   v_dropped_count := CTO_CONFIG_BOM_PK.get_dit_count   ;

       cto_wip_workflow_api_pk.cto_debug('CTO_PRECONFIG_ITEM_ML' ,  ' dropped count ' || to_char(v_dropped_count) );


   if( v_dropped_count > 0 )  then
         cto_config_bom_pk.reset_dropped_components ;
   end if ;


   v_dropped_count := CTO_CONFIG_BOM_PK.get_dit_count   ;


       cto_wip_workflow_api_pk.cto_debug('CTO_PRECONFIG_ITEM_ML' ,  ' dropped count ' || to_char(v_dropped_count) );




        v_step := 'Step 20  ' ;


       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' before create bom error message ' || x_msg_data ) ;

       CTO_BOM_RTG_PK.create_all_boms_and_routings( p_top_ato_line_id,
                                v_flow_calc,
                                x_return_status,
                                x_msg_count,
                                x_msg_data);

        v_step := 'Step 21  ' ;


        -- insert into my_debug_messages values( ' error message ' || x_msg_data ) ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' error message ' || x_msg_data ) ;

        v_step := 'Step 22  ' ;

       if( x_return_status = FND_API.G_RET_STS_ERROR ) then
            RAISE FND_API.G_EXC_ERROR ;
        elsif( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) then
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR ;
        end if ;

        -- insert into my_debug_messages values ( ' returned from create_all_boms_and_routings ') ;
       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' returned from create_all_boms_and_routings ') ;


        v_step := 'Step 30  ' ;



        if( p_match_profile_on = 'Y' and p_use_matched_item = 'N' ) then


             if( p_top_matched_item_id is not null ) then


        v_step := 'Step 32  ' ;
                 delete from bom_ato_configurations where config_item_id =
                        p_top_matched_item_id ;

        v_step := 'Step 33  ' ;

                 -- insert into my_debug_messages values( ' delete top matched item id from bom_ato_configurations for  item ' || to_char( p_top_matched_item_id ) ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' delete top matched item id from bom_ato_configurations for  item ' || to_char( p_top_matched_item_id ) ) ;


             end if ;



/*
        for lNextRec in c_can_configurations
        loop

        v_step := 'Step 34  ' ;

           -- insert into my_debug_messages values ( ' fetched ' || to_char(lNextRec.line_id) ) ;
          CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' fetched ' || to_char(lNextRec.line_id) ) ;

        v_step := 'Step 34b  ' ;

           select perform_match
           into   lPerformMatch
           from   bom_cto_order_lines
           where  line_id = lNextRec.line_id;


           if( lPerformMatch = 'N' ) then

        v_step := 'Step 35  ' ;
               lStatus := CTO_MATCH_CONFIG.can_configurations(
                                          lNextRec.line_id,
                                          0,
                                          0,
                                          0,
                                          gUserId,
                                          gLoginId,
                                          l_x_error_msg,
                                          l_x_msg_name);


                   -- insert into my_debug_messages values ( ' canned configuration ' || to_char( lNextRec.line_id ) ) ;
                  CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' canned configuration ' || to_char( lNextRec.line_id ) ) ;

               oe_debug_pub.add(
                  'Returned from canning in stmt num 110 with status '
                  || to_char(lStatus), 1);

               if (lStatus <> 1) then


                    v_step := 'Step 40  ' ;

                    raise fnd_api.g_exc_unexpected_error;

               end if; -- end lStatus <> 1




          end if ; * if lPerformMatch *
        end loop ;
*/


        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' canning has been outsourced to CTO_ITEM_PK ' ) ;



        end if ; /* match_profile_on */


        v_step := 'Step 45  ' ;

       if( p_use_matched_item = 'Y' and p_match_profile_on = 'Y' ) then


          begin

           select bill_sequence_id into x_bill_sequence_id
             from bom_bill_of_materials
             where assembly_item_id = p_top_matched_item_id
               and organization_id = p_current_org_id ;

          exception
          when no_data_found then
               raise MATCHED_ITEM_BOM_NOT_FOUND ;

          when others then
               raise;

          end;



        v_step := 'Step 47  ' ;

         -- insert into my_debug_messages values( 'matched bill_sequence_id is ' || to_char( x_bill_sequence_id ) ) ;
        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , 'matched bill_sequence_id is ' || to_char( x_bill_sequence_id ) ) ;

       end if ;


        v_step := 'Step 50  ' ;


        begin



        select decode( count(*) , 0 , 'N' , 'Y' ) into x_mlmo_item_created
          from bom_cto_src_orgs
         where organization_id <> nvl(rcv_org_id, organization_id)
           and top_model_line_id = p_top_ato_line_id  ;



        v_step := 'Step 55  ' ;

         -- insert into my_debug_messages values ( ' mlmo item has been created ' ||  x_mlmo_item_created  );
        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' mlmo item has been created ' ||  x_mlmo_item_created  );

        exception
         when no_data_found then

        v_step := 'Step 56  ' ;
               x_mlmo_item_created := 'N' ;
         -- insert into my_debug_messages values ( ' mlmo item has not been created ' );
        CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' mlmo item has not been created ' );

         when others then
               raise ;

         end ;






        v_step := 'Step 60  ' ;

        delete from bom_cto_order_lines
        where ato_line_id =  p_top_ato_line_id ;

         CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' deleted bcol ' || to_char(sql%rowcount)) ;

        delete from bom_cto_src_orgs_b
        where top_model_line_id = p_top_ato_line_id ;

         CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' deleted bcso_b ' || to_char(sql%rowcount)) ;



       CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' exiting create_preconfig_item_ml ') ;



        -- This is a wrapper API to call PLM team's to sync up item media index
        -- With out this sync up the item cannot be searched in Simple item search page
        -- Bug 6033399 (FP 6034006)
        CTO_MSUTIL_PUB.syncup_item_media_index;
 	 --Start Bugfix 8305535
 	 --calling RAISE EVENT to push items into seibel
 	 CTO_MSUTIL_PUB.Raise_event_for_seibel;
 	 --End Bugfix 8305535
  exception

   when MATCHED_ITEM_BOM_NOT_FOUND then

        x_return_status := FND_API.G_RET_STS_ERROR;
        x_msg_data := 'CTO_MATCHED_BOM_NOT_FOUND'  ;

                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );





   when FND_API.G_EXC_ERROR then
                 -- insert into my_debug_messages values ( ' came into expected exception create_preconfig_item_ml at step ' || v_step ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into expected exception create_preconfig_item_ml at step ' || v_step ) ;

                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into expected exception create_preconfig_item_ml at step ' || x_msg_data ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into expected exception create_preconfig_item_ml at step ' || to_char( x_msg_count) ) ;


        x_return_status := FND_API.G_RET_STS_ERROR;

                CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );

                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into expected exception create_preconfig_item_ml at step ' || x_msg_data ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into expected exception create_preconfig_item_ml at step ' || to_char( x_msg_count) ) ;



--        x_msg_data := FND_MESSAGE.GET ;

   when FND_API.G_EXC_UNEXPECTED_ERROR then
                 -- insert into my_debug_messages values ( ' came into unexpected exception create_preconfig_item_ml at step ' || v_step ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into unexpected exception create_preconfig_item_ml at step ' || v_step ) ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

               CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );


   when OTHERS then
                 -- insert into my_debug_messages values ( ' came into others exception create_preconfig_item_ml at step ' || v_step ) ;
                CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( 'CREATE_PRECONFIG_ITEM_ML' , ' came into others exception create_preconfig_item_ml at step ' || v_step ) ;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;


               CTO_MSG_PUB.Count_And_Get
                        (p_msg_count => x_msg_count
                        ,p_msg_data  => x_msg_data
                        );



  end create_preconfig_item_ml ;




 procedure contiguous_to_sparse_bcol(
  p_t_bcol  in out NOCOPY bcol_tbl_type
 )
 is
 p_t_sparse_bcol  bcol_tbl_type ;
v_line_id       number ;

 begin
      for i in 1..p_t_bcol.count
      loop
         p_t_sparse_bcol(i) := p_t_bcol(i) ;
      end loop ;

      p_t_bcol.delete ;

      for i in 1..p_t_sparse_bcol.count
      loop
         p_t_bcol(p_t_sparse_bcol(i).line_id) := p_t_sparse_bcol(i) ;

         v_line_id := p_t_sparse_bcol(i).line_id ;

         -- insert into my_debug_messages values ( 'p_t_sparse' || to_char( v_line_id ) ) ;
      end loop ;



 end contiguous_to_sparse_bcol ;



 procedure sparse_to_contiguous_bcol(
  p_t_bcol  in out NOCOPY bcol_tbl_type
 )
 is
 p_t_plain_bcol  bcol_tbl_type ;
 i   number ;
v_line_id number ;
 begin
     i := p_t_bcol.first ;

     while i is not null
     loop
         p_t_plain_bcol(p_t_plain_bcol.count + 1 ) := p_t_bcol(i) ;
         i := p_t_bcol.next(i) ;

         v_line_id := p_t_plain_bcol(p_t_plain_bcol.count).line_id  ;

         -- insert into my_debug_messages values ( 'p_t_plain ' || to_char( v_line_id ) ) ;

     end loop ;

     p_t_bcol.delete ;

      for i in 1..p_t_plain_bcol.count
      loop
         p_t_bcol(i) := p_t_plain_bcol(i) ;
      end loop ;



 end sparse_to_contiguous_bcol ;



 PROCEDURE populate_parent_ato
 ( p_t_bcol  in out NOCOPY bcol_tbl_type,
  p_bcol_line_id in       bom_cto_order_lines.line_id%type )
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 v_prev_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 i             number := 0 ;

 begin

    /*
    ** Strategy: Resolve parent_ato for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the end of the table ( POP implmentation [LIFO] )
    */

        v_step := 'Step C1' ;

    i := p_t_bcol.first ;


    /*  for i in 1..p_t_bcol.last commented for bug 1728383 */

    while i is not null
    loop

       if( p_t_bcol.exists(i)  ) then

          v_src_point := i ;
          /* please note, here it stores the index which is the same as line_id due to sparse array*/

          /*
          ** resolve parent ato line id for item.
          */
        v_step := 'Step C2' ;

          while( p_t_bcol.exists(v_src_point) )
          loop

             v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
             /* store each unresolved item in its heirarchy */

             v_prev_src_point := v_src_point ;

             v_src_point := p_t_bcol(v_src_point).link_to_line_id ;




             if( v_src_point is null or v_prev_src_point = p_bcol_line_id ) then
                 v_src_point := v_prev_src_point ;

                 /* break if pto is on top of top level ato or
                    the current lineid is top level phantom ato
                 */

                 exit ;
             end if ;
             if( p_t_bcol(v_src_point).bom_item_type = '1' AND
                 p_t_bcol(v_src_point).ato_line_id is not null AND
                 nvl( p_t_bcol(v_src_point).wip_supply_type , 0 ) <> '6' ) then

                   exit ;
                  /* break if non phantom ato parent found */
             end if ;



          end loop ;

          j := v_raw_line_id.count ; /* total number of items to be resolved */

        v_step := 'Step C3' ;

          while( j >= 1 )
          loop

             p_t_bcol(v_raw_line_id(j)).parent_ato_line_id := v_src_point ;

             j := j -1 ;

          end loop ;

          v_raw_line_id.delete ; /* remove all elements as they have been resolved */

       end if ;



       i := p_t_bcol.next(i) ;  /* added for bug 1728383 for performance */


    end loop ;

 exception
           when others then
                 -- insert into my_debug_messages values ( ' came into parent_ato exception at step ' || v_step ) ;
            null ;
 end populate_parent_ato ;






 PROCEDURE populate_plan_level
 ( p_t_bcol  in out NOCOPY bcol_tbl_type )
 is
 TYPE TABNUM is TABLE of NUMBER index by binary_integer ;
 v_raw_line_id TABNUM ;
 v_src_point   number ;
 j             number ;
 v_step        VARCHAR2(10) ;
 i             number := 0 ;

 begin

    /*
    ** Strategy: Resolve plan_level for each line item by setting it to 1 + plan_level of parent.
    ** use the link_to_line_id column to get to the parent. if parents plan_level is not yet
    ** resolved, go to its immediate ancestor recursively till you find a line item with
    ** plan_level set( Top level plan level is always set to zero ). When coming out of recursion
    ** set the plan_level of any ancestors that havent been resolved yet.
    ** Implementation: As Pl/Sql does not support Stack built-in-datatype, an equivalent behavior
    ** can be achieved by storing items in a table( PUSH implementation) and retrieving them from
    ** the end of the table ( POP implmentation [LIFO] )
    */

        v_step := 'Step B1' ;

    i := p_t_bcol.first ;



    /*   for i in 1..p_t_bcol.last commented for bug 1728383 */


    while i is not null
    loop

       if( p_t_bcol.exists(i)  ) then

          v_src_point := i ;


          /*
          ** resolve plan level for item only if not yet resolved
          */

          while( p_t_bcol(v_src_point).plan_level is null )
          loop

             v_raw_line_id(v_raw_line_id.count + 1 ) := v_src_point  ;
             /* store each unresolved item in its heirarchy */

             v_src_point := p_t_bcol(v_src_point).link_to_line_id ;

          end loop ;

        v_step := 'Step B2' ;

          j := v_raw_line_id.count ; /* total number of items to be resolved */

          while( j >= 1 )
          loop

             p_t_bcol(v_raw_line_id(j)).plan_level := p_t_bcol(v_src_point).plan_level + 1;

             v_src_point := v_raw_line_id(j) ;

             j := j -1 ;
          end loop ;

          v_raw_line_id.delete ; /* remove all elements as they have been resolved */

       end if ;



       i := p_t_bcol.next(i) ;  /* added for bug 1728383 for performance */


    end loop ;

 exception
      when others then
                 -- insert into my_debug_messages values ( ' came into plan_level exception at step ' || v_step ) ;
                 null ;

 end populate_plan_level ;



  procedure insert_into_bcol (
      p_bcol_tab bcol_tbl_type
  )
  IS
  v_step number := 0 ;
  v_sqlcode number := 0 ;
  i   number ;
  BEGIN

              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( ' came into  insert into bcol: ' , 1 ) ;




      if( p_bcol_tab.count = 0 )  then
          return ;
      end if ;

      i := p_bcol_tab.first ;

      while i is not null
      loop

              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( ' insert into bcol: ' ||
                          ' line_id ' || p_bcol_tab(i).line_id ||
                          ' parent line_id ' || p_bcol_tab(i).parent_ato_line_id ||
                          ' qty ' || p_bcol_tab(i).ordered_quantity ,  1) ;

              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( ' insert into bcol: ' ||
                          ' line_id ' || p_bcol_tab(i).line_id ||
                          ' parent line_id ' || p_bcol_tab(i).parent_ato_line_id ||
                          ' parent qty ' || p_bcol_tab(p_bcol_tab(i).parent_ato_line_id ).ordered_quantity ,  1) ;
         v_step := i ;

         Insert into bom_cto_order_lines_gt(
                     HEADER_ID ,
                     LINE_ID ,
                     LINK_TO_LINE_ID ,
                     ATO_LINE_ID ,
                     PARENT_ATO_LINE_ID ,
                     TOP_MODEL_LINE_ID ,
                     PLAN_LEVEL ,
                     WIP_SUPPLY_TYPE ,
                     PERFORM_MATCH ,
                     BOM_ITEM_TYPE ,
                     COMPONENT_CODE ,
                     COMPONENT_SEQUENCE_ID ,
                     CONFIG_ITEM_ID ,
                     INVENTORY_ITEM_ID ,
                     ITEM_TYPE_CODE ,
                     BATCH_ID ,
                     ORDERED_QUANTITY ,
                     ORDER_QUANTITY_UOM ,
                     SCHEDULE_SHIP_DATE ,
                     SHIP_FROM_ORG_ID ,
                     LAST_UPDATE_DATE ,
                     LAST_UPDATED_BY ,
                     CREATION_DATE ,
                     CREATED_BY ,
                     LAST_UPDATE_LOGIN ,
                     REQUEST_ID ,
                     PROGRAM_APPLICATION_ID ,
                     PROGRAM_ID ,
                     PROGRAM_UPDATE_DATE ,
                     qty_per_parent_model,
                     option_specific ,
                     reuse_config ,
                     config_creation )
          VALUES (
                     nvl( p_bcol_tab(i).header_id , 1 ) ,
                     p_bcol_tab(i).line_id,
                     p_bcol_tab(i).link_to_line_id,
                     p_bcol_tab(i).ato_line_id,
                     p_bcol_tab(i).parent_ato_line_id,
                     nvl( p_bcol_tab(i).top_model_line_id,1 ),
                     p_bcol_tab(i).plan_level,
                     p_bcol_tab(i).wip_supply_type,
                     p_bcol_tab(i).perform_match,
                     p_bcol_tab(i).bom_item_type,
                     p_bcol_tab(i).component_code,
                     p_bcol_tab(i).component_sequence_id,
                     p_bcol_tab(i).config_item_id,
                     p_bcol_tab(i).inventory_item_id,
                     nvl( p_bcol_tab(i).item_type_code, decode( p_bcol_tab(i).line_id, p_bcol_tab(i).ato_line_id , 'MODEL' , decode( p_bcol_tab(i).bom_item_type , '4' , 'OPTION' , 'CLASS' ) )),
                     p_bcol_tab(i).batch_id,
                     p_bcol_tab(i).ordered_quantity,
                     p_bcol_tab(i).order_quantity_uom,
                     p_bcol_tab(i).schedule_ship_date,
                     p_bcol_tab(i).ship_from_org_id,
                     p_bcol_tab(i).last_update_date,
                     p_bcol_tab(i).last_updated_by,
                     p_bcol_tab(i).creation_date,
                     p_bcol_tab(i).created_by ,
                     p_bcol_tab(i).last_update_login ,
                     p_bcol_tab(i).request_id ,
                     p_bcol_tab(i).program_application_id ,
                     p_bcol_tab(i).program_id ,
                     p_bcol_tab(i).program_update_date ,
                     p_bcol_tab(i).ordered_quantity / p_bcol_tab(p_bcol_Tab(i).parent_ato_line_id).ordered_quantity ,
                     p_bcol_tab(i).option_specific  ,
                     p_bcol_tab(i).reuse_config,
                     p_bcol_tab(i).config_creation ) ;

              CTO_WIP_WORKFLOW_API_PK.CTO_DEBUG( ' insert into bcol: ' ||
                          ' line_id ' || p_bcol_tab(i).line_id ||
                          ' parent line_id ' || p_bcol_tab(i).parent_ato_line_id ||
                          ' ato line_id ' || p_bcol_tab(i).ato_line_id ||
                          ' bom_item_type ' || nvl( p_bcol_tab(i).bom_item_type, -7)  ||
                          ' wip_supply_type ' || nvl( p_bcol_tab(i).wip_supply_type , -7) ||
                          ' config_item_id ' || nvl( p_bcol_tab(i).config_item_id , -7) ||
                          ' count ' || SQL%ROWCOUNT , 2);


         i:= p_bcol_tab.next(i) ;

      end loop ;

   exception
         when others then
                  V_SQLCODE := SQLCODE ;
                  cto_wip_workflow_api_pk.cto_debug( ' exception in bcol_gt at step ' || to_char( v_step  )   , 1  ) ;
                  cto_wip_workflow_api_pk.cto_debug( ' exception in bcol_gt at step ' || V_SQLCODE  , 1 )   ;
   END INSERT_INTO_BCOL ;



  /*
  ** This procedure requires the parameter passed in to be populated with line_id
  ** and component_code without which the intended functionality is not guaranteed
  */
  procedure populate_link_to_line_id(
     p_bcol_tab   in out NOCOPY bcol_tbl_type
  )
  is
  TYPE varchar2_1000_tbl_type is table of varchar2(1000 ) index by binary_integer ;
  v_parent_code_tab varchar2_1000_tbl_type ;
  v_loc             number :=0 ;
  begin


     for i in 1..p_bcol_tab.count
     loop

        v_loc := instr(p_bcol_tab(i).component_code , '-' , -1 )  ;

        if( v_loc = 0 ) then
            v_parent_code_tab(i) := null ;
        else
            v_parent_code_tab(i ) := substr( p_bcol_tab(i).component_code , 1 , v_loc - 1  ) ;
        end if ;

        p_bcol_tab(i).link_to_line_id := null ; /* clear existing data as top model needs null*/
     end loop;


     for i in 1..v_parent_code_tab.count
     loop

        for j in 1..p_bcol_tab.count
        loop
           if( v_parent_code_tab(i) = p_bcol_tab(j).component_code ) then
               p_bcol_tab(i).link_to_line_id := p_bcol_tab(j).line_id ;
               exit ;
           end if ;
        end loop ;

     end loop ;



  end populate_link_to_line_id;




  procedure perform_match(
     p_ato_line_id           in  bom_cto_order_lines.ato_line_id%type ,
     x_match_found           out NOCOPY varchar2,
     x_matching_config_id    out NOCOPY number,
     x_error_message         out NOCOPY VARCHAR2,
     x_message_name          out NOCOPY varchar2
  )
  is
l_stmt_num       number := 0;
l_cfm_value      number;
l_config_line_id number;
l_tree_id        integer;
l_return_status  varchar2(1);
l_x_error_msg_count    number;
l_x_error_msg          varchar2(240);
l_x_error_msg_name     varchar2(30);
l_x_table_name   varchar2(30);
l_match_profile  varchar2(10);
l_org_id         number;
l_model_id       number;
l_primary_uom_code     varchar(3);
l_x_config_id    number;
l_top_model_line_id number;

l_x_qoh          number;
l_x_rqoh         number;
l_x_qs           number;
l_x_qr           number;
l_x_att          number;
l_active_activity varchar2(30);
l_x_bill_seq_id  number;
l_status         integer;

l_perform_match  varchar2(1) ;

x_return_status  varchar2(1);
x_msg_count      number;
x_msg_data       varchar2(100);

PROCESS_ERROR      EXCEPTION;


  cursor c_model_lines is
       select line_id, parent_ato_line_id
       from   bom_cto_order_lines
       where  bom_item_type = '1'
       and    ato_line_id = p_ato_line_id
       and    nvl(wip_supply_type,0) <> 6
       order by plan_level desc;

  v_sqlcode               number ;
 l_custom_match_profile varchar2(10);
  begin

        l_stmt_num := 1;

        x_match_found := 'N' ;

        l_custom_match_profile := FND_PROFILE.Value('BOM:CUSTOM_MATCH');

        l_stmt_num := 5;

        /* for each model */

        for l_next_rec in c_model_lines loop

           l_x_config_id := NULL;



           select /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
            perform_match into l_perform_match
            from  bom_cto_order_lines_gt
           where  line_id = l_next_rec.line_id ;



          if( l_perform_match = 'N' ) then

             begin

                 update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                 bom_cto_order_lines_gt set perform_match = 'N'
                 where perform_match = 'Y'
                   and line_id = l_next_rec.parent_ato_line_id ;

             exception
                when no_data_found then
                     null ;

             end ;

             x_match_found := 'N' ;

             x_matching_config_id := NULL ; /* fix for bug#2048023. */



          else

              if ( l_custom_match_profile = 2) then
                   l_stmt_num := 10;
                   oe_debug_pub.add('Standard Match.', 1);
                   l_status := cto_match_config.check_config_match(
                                          l_next_rec.line_id,
                                          l_x_config_id,
                                          l_x_error_msg,
                                          l_x_error_msg_name);

              elsif (l_custom_match_profile = 1) then
                   l_stmt_num := 15;
                   l_status := CTO_CUSTOM_MATCH_PK.find_matching_config(
                                          l_next_rec.line_id,
                                          l_x_config_id,
                                          l_x_error_msg,
                                          l_x_error_msg_name,
                                          l_x_table_name);
              end if;

              l_stmt_num := 20;

              if (l_status = 0) then
                  oe_debug_pub.add('Failed in Check Config Match for line id '
                                || to_char(l_next_rec.line_id), 1);

                  raise PROCESS_ERROR;

              end if;


              l_stmt_num := 25;


              if (l_status = 1 and l_x_config_id is NULL) then
                  l_stmt_num := 30;

                  x_message_name := 'CTO_MR_NO_MATCH';
                  x_error_message := 'No matching configurations for line '
                                   || to_char(l_next_rec.line_id);
                  l_stmt_num := 137;

                  -- insert into my_debug_messages values ( 'No Match found' ) ;
                  x_match_found := 'N' ;

                  x_matching_config_id := NULL ; /* fix for bug#2048023. */

                  /* fix for bug#2048023.
                     This variable has to be initialized to null as it was not
                     null for a lower level match in the perform match loop.
                  */


                  /* update the perform match column to 'N' so that this item is canned */
                  begin
                       update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                       bom_cto_order_lines_gt
                       set    perform_match = 'N'
                       where  line_id = l_next_rec.line_id
                       and    perform_match = 'Y';

                  exception
                     when no_data_found then
                       null ;

                  end ;



                  /* update the perform match column to 'N' so that no match
                     is attempted against its parent and it is canned
                  */

                  begin
                       update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                       bom_cto_order_lines_gt
                       set    perform_match = 'N'
                       where  line_id = l_next_rec.parent_ato_line_id
                       and    perform_match = 'Y';

                  exception
                     when no_data_found then
                       null ;

                  end ;




              elsif (l_status = 1 and l_x_config_id is not null) then

                  l_stmt_num := 35;

                  /*
                    oe_debug_pub.add('Match for line id '
                                || to_char(l_next_rec.line_id)
                                || ' is ' || to_char(l_x_config_id) ,1);
                  */

                  update /*+ INDEX (BOM_CTO_ORDER_LINES_GT BOM_CTO_ORDER_LINES_GT_U1) */
                     bom_cto_order_lines_gt
                     set config_item_id = l_x_config_id
                   where  line_id = l_next_rec.line_id;

                  l_stmt_num := 40 ;

                  x_matching_config_id := l_x_config_id ;

                  x_match_found := 'Y' ;


                  l_stmt_num := 45 ;

                  -- insert into my_debug_messages values ( 'Match found' ) ;
                  -- insert into my_debug_messages values ( 'Matched Item '  ||  to_char(x_matching_config_id  ) ) ;

              end if;


           end if ; /* if perform_match = 'N' */


        end loop;


  exception
      when others then
                  V_SQLCODE := SQLCODE ;
                  -- insert into my_debug_messages values ( ' exception in match at step ' || to_char( l_stmt_num ) ) ;
                  -- insert into my_debug_messages values ( ' exception in match SQL ' || to_char( V_SQLCODE ) ) ;

  end perform_match ;

/* Copied this procedure as it is from BOMCZCBB.pls 115.9.1155.7 version */
  /*******************************************************************************************
  ** Procedure	: BOM_INS_MODEL_AND_MANDATORY
  ** Parameters : Group_Id
  **		  Bill_Sequence_Id
  **		  Cz_Config_Hdr_Id
  **		  Cz_Config_Rev_Num
  ** Purpose	: This procedure will be called when the configurator Applet Returns after the
  **		  user has Chosen a Configuration and hit Done. This procedure take the options
  **		  the user has chosen and the option classes that those options belong to and insert
  **		  them in a temporary table. Then it will take all the mandatory components that
  **		  are associated with the option classes from which a user has chosen atleast 1
  **		  Option and insert the data in a temporary table.
  **		  Once the required data is gathered under one group id, the process will check if
  **		  the Profile "BOM:CONFIG_INHERIT_OP_SEQ" is set.If YES then the procedure will
  ** 		  loop through the option classes and assign the operation sequence to its children
  **		  if the children have an op_seq of 1. This process will recursively loop through
  **		  its children and perform the operation sequence inheritance for all the children.
  **		  Once the records have been assigned the proper op-seq's the process will then
  **		  proceed to consolidate the components. Components quantities for components with
  **		  the same op-seq and component_item_id will be added and only 1 record for that
  **		  combination will exist and the duplicates will be deleted. The final data will be
  **		  moved from the temporary table to the production table and the data in the temp
  **		  table will be cleaned up.
  ********************************************************************************************/
  PROCEDURE BOM_INS_MODEL_AND_MANDATORY(x_group_id IN NUMBER,
                                        x_bill_sequence_id IN NUMBER,
                                        x_top_bill_sequence_id IN NUMBER,
					x_cz_config_hdr_id	IN NUMBER,
					x_cz_config_rev_num	IN NUMBER,
                                        x_message  IN OUT NOCOPY VARCHAR2) IS
     X_Stmt_Num  	  NUMBER;
     X_Return_Val 	  NUMBER;
     X_err_message 	  VARCHAR2(2000);
     l_op_seq_profile 	  NUMBER := 0;
     l_bill_sequence_id   NUMBER;
     l_organization_id    NUMBER;

     /* Cursor will select the options that the user had chosen from the option classes
	on the Model
      */

     CURSOR cz_options_chosen IS
     SELECT bic.bill_sequence_id,
            x_top_bill_sequence_id top_bill_sequence_id,
            bic.operation_seq_num,
            bic.component_item_id,
            bic.last_update_date,
            bic.last_updated_by,
            bic.creation_date,
            bic.created_by,
            bic.item_num,
            round( to_number(cz.quantity), 7) component_quantity, /* Support Decimal-Qty for Option Items */
            bic.component_yield_factor,
            bic.effectivity_date,
            bic.implementation_date,
            bic.planning_factor,
            bic.quantity_related,
            bic.so_basis,
            bic.optional,
            bic.mutually_exclusive_options,
            bic.include_in_cost_rollup,
            bic.check_atp,
            bic.required_to_ship,
            bic.required_for_revenue,
            bic.include_on_ship_docs,
            bic.include_on_bill_docs,
            bic.low_quantity,
            bic.high_quantity,
            bic.wip_supply_type,
            bic.pick_components,
            bic.bom_item_type,
            bic.component_sequence_id,
            bic.From_End_Item_Unit_Number,
            bic.To_End_Item_Unit_Number,
	    bic.attribute_category,
	    bic.attribute1,
	    bic.attribute2,
	    bic.attribute3,
	    bic.attribute4,
	    bic.attribute5,
	    bic.attribute6,
	    bic.attribute7,
	    bic.attribute8,
	    bic.attribute9,
	    bic.attribute10,
	    bic.attribute11,
	    bic.attribute12,
	    bic.attribute13,
	    bic.attribute14,
	    bic.attribute15,
            cz.component_code
       FROM bom_inventory_components bic
          , cz_config_details_v cz
      WHERE bic.bom_item_type NOT IN('1', '2')
	AND bic.component_sequence_id = cz.component_sequence_id
	AND cz.config_hdr_id = x_cz_config_hdr_id
	AND cz.config_rev_nbr = x_cz_config_rev_num;

     /* Mandatory Components for the all the options classes in which user has chosen
        atleast 1 option (this is used when the operation sequence inheritance is OFF)
     */
     CURSOR c_cz_required_items IS
     SELECT bic.bill_sequence_id,
	    x_top_bill_sequence_id,
	    bic.operation_seq_num,
            bic.component_item_id,
            bic.last_update_date,
            bic.last_updated_by,
            bic.creation_date,
            bic.created_by,
            bic.item_num,
            round( (bic.component_quantity * to_number(cz.quantity)), 7) component_quantity, /* Support Decimal-Qty for Option Items */
            bic.component_yield_factor,
            bic.effectivity_date,
            bic.implementation_date,
            bic.planning_factor,
            bic.quantity_related,
            bic.so_basis,
            bic.optional,
            bic.mutually_exclusive_options,
            bic.include_in_cost_rollup,
            bic.check_atp,
            bic.required_to_ship,
            bic.required_for_revenue,
            bic.include_on_ship_docs,
            bic.include_on_bill_docs,
            bic.low_quantity,
            bic.high_quantity,
            bic.wip_supply_type,
            bic.pick_components,
            bic.bom_item_type,
	    bic.component_sequence_id,
	    bic.From_End_Item_Unit_Number,
    	    bic.To_End_Item_Unit_Number,
            bic.attribute_category,
            bic.attribute1,
            bic.attribute2,
            bic.attribute3,
            bic.attribute4,
            bic.attribute5,
            bic.attribute6,
            bic.attribute7,
            bic.attribute8,
            bic.attribute9,
            bic.attribute10,
            bic.attribute11,
            bic.attribute12,
            bic.attribute13,
            bic.attribute14,
            bic.attribute15
       FROM bom_inventory_components bic
	  , bom_inventory_components mod_oc
	  , bom_bill_of_materials bom
          , cz_config_details_v cz
      WHERE cz.config_hdr_id = x_cz_config_hdr_id
	AND cz.config_rev_nbr = x_cz_config_rev_num
        AND mod_oc.component_sequence_id = cz.component_sequence_id
	AND mod_oc.bom_item_type IN (1,2)
	AND bom.assembly_item_id = mod_oc.component_item_id
	AND bom.organization_id = cz.organization_id
	AND bom.alternate_bom_designator IS NULL
        AND bic.bill_sequence_id = DECODE(bom.common_bill_sequence_id, bom.bill_sequence_id,
					  bom.bill_sequence_id, bom.common_bill_sequence_id
					  )
        AND bic.optional = 2
        AND bic.bom_item_type NOT IN (1,2)
        AND bic.effectivity_date     <= SYSDATE
        AND nvl(bic.disable_date,SYSDATE+1) >  SYSDATE;

     /* Mandatory Components for the all the options classes in which user has chosen
        atleast 1 option (this is used for operation sequence inheritance from the parent)
        Additional table used here is bom_explosion_temp and the join to cz_config_details_v
        has been made using the component_code
     */

     CURSOR c_cz_req_items_with_Inherit IS
     SELECT bic.bill_sequence_id,
	    x_top_bill_sequence_id,
	    bic.operation_seq_num,
	    bet.operation_seq_num parent_operation_seq_num,
            bic.component_item_id,
            bic.last_update_date,
            bic.last_updated_by,
            bic.creation_date,
            bic.created_by,
            bic.item_num,
            round( (bic.component_quantity * to_number(cz.quantity)) , 7) component_quantity, /* Support Decimal-Qty for Option Items */
            bic.component_yield_factor,
            bic.effectivity_date,
            bic.implementation_date,
            bic.planning_factor,
            bic.quantity_related,
            bic.so_basis,
            bic.optional,
            bic.mutually_exclusive_options,
            bic.include_in_cost_rollup,
            bic.check_atp,
            bic.required_to_ship,
            bic.required_for_revenue,
            bic.include_on_ship_docs,
            bic.include_on_bill_docs,
            bic.low_quantity,
            bic.high_quantity,
            bic.wip_supply_type,
            bic.pick_components,
            bic.bom_item_type,
	    bic.component_sequence_id,
	    bic.From_End_Item_Unit_Number,
    	    bic.To_End_Item_Unit_Number,
            bic.attribute_category,
            bic.attribute1,
            bic.attribute2,
            bic.attribute3,
            bic.attribute4,
            bic.attribute5,
            bic.attribute6,
            bic.attribute7,
            bic.attribute8,
            bic.attribute9,
            bic.attribute10,
            bic.attribute11,
            bic.attribute12,
            bic.attribute13,
            bic.attribute14,
            bic.attribute15
       FROM bom_inventory_components bic
	  , bom_inventory_components mod_oc
	  , bom_bill_of_materials bom
          , cz_config_details_v cz
          , bom_explosion_temp bet
      WHERE cz.config_hdr_id = x_cz_config_hdr_id
	AND cz.config_rev_nbr = x_cz_config_rev_num
        AND cz.component_code = bet.component_code
        AND mod_oc.component_sequence_id = cz.component_sequence_id
	AND mod_oc.bom_item_type IN (1,2)
	AND bom.assembly_item_id = mod_oc.component_item_id
	AND bom.organization_id = cz.organization_id
	AND bom.alternate_bom_designator IS NULL
        AND bic.bill_sequence_id = DECODE(bom.common_bill_sequence_id, bom.bill_sequence_id,
					  bom.bill_sequence_id, bom.common_bill_sequence_id
					  )
        AND bic.optional = 2
        AND bic.bom_item_type NOT IN (1,2)
        AND bic.effectivity_date     <= SYSDATE
        AND nvl(bic.disable_date,SYSDATE+1) >  SYSDATE;

      /* Components in the temp table with valid component code . Component code will be available
         for the records that are from cz_config_details_v (i.e all the option classes for the
         configured item and all the choosen options) */

      CURSOR c_Comps_With_ComponentCode IS
      SELECT * from bom_explosion_temp WHERE component_code IS NOT NULL
       ORDER BY component_code;

      /* Option classes that are under the top model */

      CURSOR c_Options_of_Model IS
      SELECT   bic.component_sequence_id
	     , bic.component_item_id
	     , bic.operation_seq_num
	     , cz.organization_id
	FROM bom_inventory_components bic,
	     cz_config_details_v cz
       WHERE cz.component_sequence_id = bic.component_sequence_id
	 AND bic.bom_item_type IN (1,2)
	 AND bic.bill_sequence_id = l_bill_sequence_id
	 AND cz.config_hdr_id = x_cz_config_hdr_id
	 AND cz.config_rev_nbr = x_cz_config_rev_num;


    	CURSOR c_Club_Comps IS
        SELECT  bet.bill_sequence_id
	      , bet.component_item_id
	      , bet.operation_seq_num
	      , bet.component_sequence_id
          FROM bom_explosion_temp bet
         WHERE bill_sequence_id = x_bill_sequence_id
      ORDER BY bet.bill_sequence_id,
               bet.component_item_id,
               bet.operation_seq_num,
               bet.component_sequence_id;


  BEGIN

	--
	-- Check if the Top Model being defined is using some model as common. If it is then
	-- we need to use the bill_sequence_id of the other model when find the bill structure
	--

	SELECT 	DECODE(common_bill_sequence_id, x_top_bill_sequence_id,
		       bill_sequence_id, common_bill_sequence_id
		      ),
	        DECODE(nvl(common_organization_id, organization_id), organization_id,
                               organization_id, common_organization_id)
	  INTO l_bill_sequence_id,
	       l_organization_id
	  FROM bom_bill_of_materials
	 WHERE bill_sequence_id = x_top_bill_sequence_id;

     X_Stmt_Num := 10;

    /* Flush the temp table before starting the process */

    DELETE from bom_explosion_temp;

    /* Insert Model */

    INSERT INTO BOM_INVENTORY_COMPONENTS
    (
      bill_sequence_id,
      component_sequence_id,
      component_item_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      component_quantity,
      component_yield_factor,
      planning_factor,
      quantity_related,
      include_in_cost_rollup,
      so_basis,
      optional,
      mutually_exclusive_options,
      check_atp,
      shipping_allowed,
      required_to_ship,
      required_for_revenue,
      include_on_ship_docs,
      include_on_bill_docs,
      low_quantity,
      high_quantity,
      pick_components,
      bom_item_type,
      operation_seq_num,
      item_num,
      effectivity_date,
      disable_date,
      implementation_date,
      wip_supply_type
    )
    SELECT  x_bill_sequence_id,
              BOM_INVENTORY_COMPONENTS_S.nextval,
              be.Component_Item_Id,
              SYSDATE,
              1,
              SYSDATE,
              1,
              be.Attribute1,
              be.Attribute2,
              be.Attribute3,
              be.Attribute4,
              be.Attribute5,
              be.Attribute6,
              be.Attribute7,
              be.Attribute8,
              be.Attribute9,
              be.Attribute10,
              be.Attribute11,
              be.Attribute12,
              be.Attribute13,
              be.Attribute14,
              be.Attribute15,
              round( be.Component_Quantity, 7 ), /* Support Decimal-Qty for Option Items */
	      1, /* Component Yield*/
	      100,   /*Component Planning factor */
	      2,   /* Quantity Related */
	      2,   /* Include in Cost Rollup */
              2, /* SO Basis */
              1, /* Optional */
              2, /*Mutually_Exclusive_Options */
              2,  /*Check_ATP*/
              2, /*Shipping Allowed */
              2, /*Required to ship */
              2, /*Required_For_Revenue*/
              2, /*Include on Ship Docs */
              2, /*Include_On_Bill_Docs */
              be.Low_Quantity,
              be.High_Quantity,
              1, /* Pick_Components */
              be.Bom_Item_Type,
              1, /*Operation Sequence Num */
              1, /*Item_Num */
              SYSDATE,
              NULL /*Disable_Date*/,
	      SYSDATE, /* Implementation Date */
	      6 /* wip_supply_type */
    FROM  bom_explosions be
    WHERE be.top_bill_sequence_id = X_top_Bill_Sequence_id
    AND   be.explosion_type = 'OPTIONAL'
    AND   be.effectivity_date     <= SYSDATE
    AND   nvl(be.disable_date,SYSDATE+1) >  SYSDATE
    AND   be.plan_level = 0;

    /* Insert the Mandatory Components of the Model */

    INSERT INTO BOM_EXPLOSION_TEMP
    ( top_bill_sequence_id,
      organization_id,
      plan_level,
      sort_order,
      bill_sequence_id,
      component_sequence_id,
      component_item_id,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      component_quantity,
      component_yield_factor,
      planning_factor,
      include_in_rollup_flag,
      so_transactions_flag, /* Used for Quantity Related */
      so_basis,
      optional,
      mutually_exclusive_options,
      check_atp,
      shipping_allowed,
      required_to_ship,
      required_for_revenue,
      include_on_ship_docs,
      include_on_bill_docs,
      low_quantity,
      high_quantity,
      pick_components,
      bom_item_type,
      operation_seq_num,
      item_num,
      effectivity_date,
      disable_date,
      implementation_date,
      wip_supply_type,
      pricing_attribute1, /** used for from unit item number **/
      pricing_attribute2 /** used for to unit item number **/
    )
    SELECT x_top_bill_sequence_id,
	   l_organization_id,   -- resolved at the begining
	   1,  /*Plan Level */
	   '1', /* Sort Order */
	   x_bill_sequence_id,
           component_sequence_id,
           Component_Item_Id,
           Attribute1,
           Attribute2,
           Attribute3,
           Attribute4,
           Attribute5,
           Attribute6,
           Attribute7,
           Attribute8,
           Attribute9,
           Attribute10,
           Attribute11,
           Attribute12,
           Attribute13,
           Attribute14,
           Attribute15,
           Component_Quantity,
           component_yield_factor,
           planning_factor,   /*Component Planning factor */
           include_in_cost_rollup,   /* Include in Cost Rollup */
	   NVL(to_char(quantity_related),'2'),
           so_basis, /* SO Basis */
           optional, /* Optional */
           Mutually_Exclusive_Options, /*Mutually_Exclusive_Options */
           check_atp,  /*Check_ATP*/
           shipping_allowed, /*Shipping Allowed */
           required_to_ship, /*Required to ship */
           required_for_revenue, /*Required_For_Revenue*/
           include_on_ship_docs, /*Include on Ship Docs */
           include_on_bill_docs, /*Include_On_Bill_Docs */
           Low_Quantity,
           High_Quantity,
           pick_components, /* Pick_Components */
           Bom_Item_Type,
           operation_seq_num, /*Operation Sequence Num */
           item_num, /*Item_Num */
           effectivity_date,
           disable_date, /*Disable_Date*/
           implementation_date, /* Implementation Date */
           wip_supply_type,/* wip_supply_type */
	   from_end_item_unit_number,
	   to_end_item_unit_number
    FROM  bom_inventory_components
    WHERE bill_sequence_id = l_Bill_Sequence_id  -- Sequence_id resolved at the begining
    AND   effectivity_date     <= SYSDATE
    AND   nvl(disable_date,SYSDATE+1) >  SYSDATE
    AND   optional = 2
    AND   bom_item_type NOT IN (1,2);

    X_Stmt_num := 19;

    /* Insert the Option Classes from which user has chosen atleast one option item along with
       the component code*/

    INSERT INTO BOM_EXPLOSION_TEMP
    ( top_bill_sequence_id,
      organization_id,
      plan_level,
      sort_order,
      bill_sequence_id,
      component_sequence_id,
      component_item_id,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      component_quantity,
      component_yield_factor,
      planning_factor,
      include_in_rollup_flag,
      so_transactions_flag, /* Used for Quantity Related */
      so_basis,
      optional,
      mutually_exclusive_options,
      check_atp,
      shipping_allowed,
      required_to_ship,
      required_for_revenue,
      include_on_ship_docs,
      include_on_bill_docs,
      low_quantity,
      high_quantity,
      pick_components,
      bom_item_type,
      operation_seq_num,
      item_num,
      effectivity_date,
      disable_date,
      implementation_date,
      wip_supply_type,
      pricing_attribute1, /** used for from unit item number **/
      pricing_attribute2, /** used for to unit item number **/
      component_code
    )
    SELECT x_top_bill_sequence_id,
           l_organization_id,   -- resolved at the begining
           1,  /*Plan Level */
           '1', /* Sort Order */
           x_bill_sequence_id,
           bic.component_sequence_id,
           bic.Component_Item_Id,
           Attribute1,
           Attribute2,
           Attribute3,
           Attribute4,
           Attribute5,
           Attribute6,
           Attribute7,
           Attribute8,
           Attribute9,
           Attribute10,
           Attribute11,
           Attribute12,
           Attribute13,
           Attribute14,
           Attribute15,
           --Component_Quantity,
           round( cz.quantity,7), /* Support Decimal-Qty for option items */
           component_yield_factor,
           planning_factor,   /*Component Planning factor */
           include_in_cost_rollup,   /* Include in Cost Rollup */
           NVL(to_char(quantity_related),'2'),
           so_basis, /* SO Basis */
           optional, /* Optional */
           Mutually_Exclusive_Options, /*Mutually_Exclusive_Options */
           check_atp,  /*Check_ATP*/
           shipping_allowed, /*Shipping Allowed */
           required_to_ship, /*Required to ship */
           required_for_revenue, /*Required_For_Revenue*/
           include_on_ship_docs, /*Include on Ship Docs */
           include_on_bill_docs, /*Include_On_Bill_Docs */
           Low_Quantity,
           High_Quantity,
           pick_components, /* Pick_Components */
           bic.Bom_Item_Type,
           operation_seq_num, /*Operation Sequence Num */
           item_num, /*Item_Num */
           effectivity_date,
           disable_date, /*Disable_Date*/
           implementation_date, /* Implementation Date */
           wip_supply_type,/* wip_supply_type */
           from_end_item_unit_number,
           to_end_item_unit_number,
           cz.component_code
    FROM  bom_inventory_components bic,
	  cz_config_details_v cz
    WHERE bic.component_sequence_id = cz.component_sequence_id
    AND   bic.bom_item_type IN (1,2) /* Model, Option Classes */
    AND   cz.config_hdr_id  = x_cz_config_hdr_id
    AND   cz.config_rev_nbr = x_cz_config_rev_num;

    X_Stmt_Num := 20;

    /** Check if the BOM:CONFIG_INHERIT_OP_SEQ is Set **/

     l_op_seq_profile := FND_PROFILE.Value('BOM:CONFIG_INHERIT_OP_SEQ');

    /* Insert Mandatory Components for the options selected  if inheritance is OFF */

    IF l_op_seq_profile <> 1 THEN

      FOR cz_mandatory_items IN c_cz_required_items
      LOOP
      	INSERT INTO bom_explosion_temp(
	      top_bill_sequence_id,
	      organization_id,
	      plan_level,
	      sort_order,
              operation_seq_num,
              component_item_id,
              item_num,
              component_quantity,
              component_yield_factor,
              effectivity_date,
              implementation_date,
              planning_factor,
              so_transactions_flag, /** used for quantity_related **/
              so_basis,
              optional,
              mutually_exclusive_options,
              include_in_rollup_flag,
              check_atp,
              required_to_ship,
              required_for_revenue,
              include_on_ship_docs,
              include_on_bill_docs,
              low_quantity,
              high_quantity,
              component_sequence_id,
              bill_sequence_id,
              wip_supply_type,
              pick_components,
              bom_item_type,
	      pricing_attribute1, /** Used for From_End_Item_Unit_Number **/
              pricing_attribute2, /** Used for To_End_Item_Unit_Number **/
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
	     )
      VALUES
	    (  x_top_bill_sequence_id
	     , l_organization_id
	     , 1  /* Plan Level */
	     , '1' /* Sort Order */
	     , cz_mandatory_items.OPERATION_SEQ_NUM
             , cz_mandatory_items.COMPONENT_ITEM_ID
             , Decode(cz_mandatory_items.item_num, NULL,
		     1, cz_mandatory_items.ITEM_NUM)
             , round( cz_mandatory_items.COMPONENT_QUANTITY , 7) /* Support Decimal-Qty for Option Items */
             , cz_mandatory_items.component_yield_factor /* component_yield_factor */
             , cz_mandatory_items.EFFECTIVITY_DATE
             , cz_mandatory_items.IMPLEMENTATION_DATE
             , 100 /* planning_factor */
             , '2' /* quantity_related */
             , cz_mandatory_items.SO_BASIS
             , cz_mandatory_items.OPTIONAL
             , cz_mandatory_items.MUTUALLY_EXCLUSIVE_OPTIONS
             , cz_mandatory_items.include_in_cost_rollup
             , cz_mandatory_items.CHECK_ATP
             , cz_mandatory_items.REQUIRED_TO_SHIP
             , cz_mandatory_items.REQUIRED_FOR_REVENUE
             , cz_mandatory_items.INCLUDE_ON_SHIP_DOCS
             , cz_mandatory_items.INCLUDE_ON_BILL_DOCS
             , cz_mandatory_items.LOW_QUANTITY
             , cz_mandatory_items.HIGH_QUANTITY
             , cz_mandatory_items.component_sequence_id
             , X_BILL_SEQUENCE_ID
             , decode(cz_mandatory_items.bom_item_type, 2, 6, 1, 6,
                      nvl(cz_mandatory_items.wip_supply_type,1)) /* wip_supply_type */
             , cz_mandatory_items.PICK_COMPONENTS
             , cz_mandatory_items.BOM_ITEM_TYPE
	     , cz_mandatory_items.From_End_Item_Unit_Number
    	     , cz_mandatory_items.To_End_Item_Unit_Number
             , cz_mandatory_items.attribute1
             , cz_mandatory_items.attribute2
             , cz_mandatory_items.attribute3
             , cz_mandatory_items.attribute4
             , cz_mandatory_items.attribute5
             , cz_mandatory_items.attribute6
             , cz_mandatory_items.attribute7
             , cz_mandatory_items.attribute8
             , cz_mandatory_items.attribute9
             , cz_mandatory_items.attribute10
             , cz_mandatory_items.attribute11
             , cz_mandatory_items.attribute12
             , cz_mandatory_items.attribute13
             , cz_mandatory_items.attribute14
             , cz_mandatory_items.attribute15
	    );

	END LOOP;

      END IF;


      /* Insert  all the selected Options along with the component code */

      FOR cz_options IN cz_options_chosen
      LOOP
        INSERT INTO bom_explosion_temp(
	      top_bill_sequence_id,
	      organization_id,
	      plan_level,
	      sort_order,
              operation_seq_num,
              component_item_id,
              item_num,
              component_quantity,
              component_yield_factor,
              effectivity_date,
              implementation_date,
              planning_factor,
              so_transactions_flag,
              so_basis,
              optional,
              mutually_exclusive_options,
              include_in_rollup_flag,
              check_atp,
              required_to_ship,
              required_for_revenue,
              include_on_ship_docs,
              include_on_bill_docs,
              low_quantity,
              high_quantity,
              component_sequence_id,
              bill_sequence_id,
              wip_supply_type,
              pick_components,
              bom_item_type,
              pricing_attribute1, /** Used for From_End_Item_Unit_Number **/
              pricing_attribute2, /** Used for To_End_Item_Unit_Number **/
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15,
              component_code
             )
      VALUES
            (  x_top_bill_sequence_id
	     , l_organization_id
	     , 1 /* Plan Level */
	     , '1' /* Sort Order */
	     , cz_options.OPERATION_SEQ_NUM
             , cz_options.COMPONENT_ITEM_ID
             , Decode(cz_options.item_num, NULL,
                     1, cz_options.ITEM_NUM)
             , cz_options.COMPONENT_QUANTITY
             , cz_options.component_yield_factor /* component_yield_factor */
             , cz_options.EFFECTIVITY_DATE
             , cz_options.IMPLEMENTATION_DATE
             , 100 /* planning_factor */
             , '2' /* quantity_related */
             , cz_options.SO_BASIS
             , cz_options.OPTIONAL
             , cz_options.MUTUALLY_EXCLUSIVE_OPTIONS
             , cz_options.include_in_cost_rollup
             , cz_options.CHECK_ATP
             , cz_options.REQUIRED_TO_SHIP
             , cz_options.REQUIRED_FOR_REVENUE
             , cz_options.INCLUDE_ON_SHIP_DOCS
             , cz_options.INCLUDE_ON_BILL_DOCS
             , cz_options.LOW_QUANTITY
             , cz_options.HIGH_QUANTITY
             , cz_options.component_sequence_id
             , X_BILL_SEQUENCE_ID
             , decode(cz_options.bom_item_type, 2, 6, 1, 6,
                   nvl(cz_options.wip_supply_type,1)) /* wip_supply_type */
             , cz_options.PICK_COMPONENTS
             , cz_options.BOM_ITEM_TYPE
             , cz_options.From_End_Item_Unit_Number
             , cz_options.To_End_Item_Unit_Number
             , cz_options.attribute1
             , cz_options.attribute2
             , cz_options.attribute3
             , cz_options.attribute4
             , cz_options.attribute5
             , cz_options.attribute6
             , cz_options.attribute7
             , cz_options.attribute8
             , cz_options.attribute9
             , cz_options.attribute10
             , cz_options.attribute11
             , cz_options.attribute12
             , cz_options.attribute13
             , cz_options.attribute14
             , cz_options.attribute15
             , cz_options.component_code
            );

        END LOOP;


        /** Finished inserting the chosen options **/

        /* Proceed to operation sequence number inheritance.

           Inheritance will be performed for the following
           1. All option classes choosen for the config item (this does not include the option classes
              that are directly under the top model. Those should already have the valid op.seq number.
              Inheritance starts from the second level. First level components under the top model
              will always have the op.seq number.)

           2. All the choosen options

           The above two are identified by a valid value for the component_code.

           3. Mandatory components that are directly under the model will already have the op.seq number

           4. At this point we have not yet inserted the mandatory components for the choosen options of this
              config item if the inherit op.seq is ON. They will be inserted along with the inherited value.

        */

        IF l_op_seq_profile = 1
        THEN

          FOR r1 IN c_Comps_With_ComponentCode
          LOOP

            IF r1.operation_seq_num = 1 AND Instr(r1.component_code,'-',1,2) <> 0
            /* If operation seq number is 1 and the component is not the first level comp. under the top model */
            THEN
              /* Get the op.seq number from it's immediate parent */
              UPDATE bom_explosion_temp btemp
               SET btemp.operation_seq_num = (SELECT operation_seq_num FROM
                        bom_explosion_temp WHERE component_code =
                        substr(btemp.component_code,1,to_number(instr(btemp.component_code,'-',-1,1))-1))
               WHERE component_code = r1.component_code;
            END IF;

          END LOOP;

        END IF;

      /* Insert Mandatory Components for the choosen options along with inherited value*/

      IF l_op_seq_profile = 1 THEN

        FOR cz_mandatory_items IN c_cz_req_items_with_Inherit
        LOOP
          INSERT INTO bom_explosion_temp(
	      top_bill_sequence_id,
	      organization_id,
	      plan_level,
	      sort_order,
              operation_seq_num,
              component_item_id,
              item_num,
              component_quantity,
              component_yield_factor,
              effectivity_date,
              implementation_date,
              planning_factor,
              so_transactions_flag, /** used for quantity_related **/
              so_basis,
              optional,
              mutually_exclusive_options,
              include_in_rollup_flag,
              check_atp,
              required_to_ship,
              required_for_revenue,
              include_on_ship_docs,
              include_on_bill_docs,
              low_quantity,
              high_quantity,
              component_sequence_id,
              bill_sequence_id,
              wip_supply_type,
              pick_components,
              bom_item_type,
	      pricing_attribute1, /** Used for From_End_Item_Unit_Number **/
              pricing_attribute2, /** Used for To_End_Item_Unit_Number **/
              attribute1,
              attribute2,
              attribute3,
              attribute4,
              attribute5,
              attribute6,
              attribute7,
              attribute8,
              attribute9,
              attribute10,
              attribute11,
              attribute12,
              attribute13,
              attribute14,
              attribute15
	     )
        VALUES
	    (  x_top_bill_sequence_id
	     , l_organization_id
	     , 1  /* Plan Level */
	     , '1' /* Sort Order */
             , decode(cz_mandatory_items.OPERATION_SEQ_NUM,1,
                     cz_mandatory_items.PARENT_OPERATION_SEQ_NUM,cz_mandatory_items.OPERATION_SEQ_NUM)
             , cz_mandatory_items.COMPONENT_ITEM_ID
             , Decode(cz_mandatory_items.item_num, NULL,
		     1, cz_mandatory_items.ITEM_NUM)
             , cz_mandatory_items.COMPONENT_QUANTITY
             , cz_mandatory_items.component_yield_factor /* component_yield_factor */
             , cz_mandatory_items.EFFECTIVITY_DATE
             , cz_mandatory_items.IMPLEMENTATION_DATE
             , 100 /* planning_factor */
             , '2' /* quantity_related */
             , cz_mandatory_items.SO_BASIS
             , cz_mandatory_items.OPTIONAL
             , cz_mandatory_items.MUTUALLY_EXCLUSIVE_OPTIONS
             , cz_mandatory_items.include_in_cost_rollup
             , cz_mandatory_items.CHECK_ATP
             , cz_mandatory_items.REQUIRED_TO_SHIP
             , cz_mandatory_items.REQUIRED_FOR_REVENUE
             , cz_mandatory_items.INCLUDE_ON_SHIP_DOCS
             , cz_mandatory_items.INCLUDE_ON_BILL_DOCS
             , cz_mandatory_items.LOW_QUANTITY
             , cz_mandatory_items.HIGH_QUANTITY
             , cz_mandatory_items.component_sequence_id
             , X_BILL_SEQUENCE_ID
             , decode(cz_mandatory_items.bom_item_type, 2, 6, 1, 6,
                      nvl(cz_mandatory_items.wip_supply_type,1)) /* wip_supply_type */
             , cz_mandatory_items.PICK_COMPONENTS
             , cz_mandatory_items.BOM_ITEM_TYPE
	     , cz_mandatory_items.From_End_Item_Unit_Number
    	     , cz_mandatory_items.To_End_Item_Unit_Number
             , cz_mandatory_items.attribute1
             , cz_mandatory_items.attribute2
             , cz_mandatory_items.attribute3
             , cz_mandatory_items.attribute4
             , cz_mandatory_items.attribute5
             , cz_mandatory_items.attribute6
             , cz_mandatory_items.attribute7
             , cz_mandatory_items.attribute8
             , cz_mandatory_items.attribute9
             , cz_mandatory_items.attribute10
             , cz_mandatory_items.attribute11
             , cz_mandatory_items.attribute12
             , cz_mandatory_items.attribute13
             , cz_mandatory_items.attribute14
             , cz_mandatory_items.attribute15
	    );

	END LOOP;

      END IF;

      /*
	l_op_seq_profile := FND_PROFILE.Value('BOM:CONFIG_INHERIT_OP_SEQ');

	IF l_op_seq_profile = 1
	THEN
		-- Call procedure to inherit operation sequences

		FOR c_model_options IN c_Options_of_Model
		LOOP
			-- for each option/model under the base model for which atleast one
			--   option is chosen, drill down the tree and set the op-seq
			Set_Op_Seq
			(  p_organization_id	=> c_model_options.organization_id
			 , p_component_item_id	=> c_model_options.component_item_id
			 , p_operation_seq_num	=> c_model_options.operation_seq_num
			 );
		END LOOP;
	END IF;
      */

	/** Once the operation inheritance is complete, then consolidate the components
	*** based on the same component_item_id and operation_seq_num
	**/

	Club_Component_Quantities
	(  p_bill_sequence_id => x_bill_sequence_id );

	Transfer_Comps
	(  p_bill_sequence_id => x_bill_sequence_id );

       /* Flush the temp table after the process */

        DELETE from bom_explosion_temp;

        IF (X_Return_Val <> 0 ) THEN
          return;
        END IF;
        -- Commit;
  EXCEPTION
    WHEN OTHERS THEN
       DELETE from bom_explosion_temp;
       x_message := 'BOM_CONFIG_EXPLOSIONS_PKG.Insert_Mandatory_Components('
            || to_char(X_Stmt_Num) || '):';
       FND_MESSAGE.Set_Name('BOM','CZ_PLSQL_ERROR');
       FND_MESSAGE.Set_Token('PACKAGE',x_message);
       FND_MESSAGE.Set_Token('ORA_ERROR',SQLCODE);
       FND_MESSAGE.Set_Token('ORA_TEXT',substr(SQLERRM,1,100));
       x_message := FND_MESSAGE.Get;
       return;
  END BOM_INS_MODEL_AND_MANDATORY;



END CZ_BOM_CONFIG_EXPLOSIONS_PKG;

/
