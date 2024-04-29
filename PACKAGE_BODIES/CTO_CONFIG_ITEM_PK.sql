--------------------------------------------------------
--  DDL for Package Body CTO_CONFIG_ITEM_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CTO_CONFIG_ITEM_PK" as
/* $Header: CTOCITMB.pls 120.19.12010000.8 2010/03/03 08:10:33 abhissri ship $ */

/*----------------------------------------------------------------------------+
| Copyright (c) 1993 Oracle Corporation    Belmont, California, USA
|                       All rights reserved.
|                       Oracle Manufacturing
|
|FILE NAME   : CTOCITMB.pls
|
|DESCRIPTION : Creates new inventory item for CTO orders. Performs
|              the same functions as BOMLDCIB.pls and INVPRCIB.pls
|              for streamlined CTO supported with new OE architecture.
|
|HISTORY     : Created based on BOMLDCIB.pls  and INVPRCIB.pls
|              Created on 09-JUL-1999  by Usha Arora
|              01-31-2000 James Chiu   Modify mandatory components APIs
|	       02-14-2000 Sajani Sheth Code changes for visible demand flag update
|	       02-15-2000 Sajani Sheth Added code to support WIP parameter
|				       "Respond to sales order changes"
|	       06-01-2000 Sajani Sheth Added code to support
|				Multilevel/Multi-org CTO functionality
|              11-06-2000 Kiran Konada Added code to support
|                              Multilevel/Multi-org CTO functionality
|                              of changing visible demand flag IN
|                             BOM_CTO_ORDER_DEMAND table while creation
|                            of Configuration item
|              01/03/2001 Renga Kannan  Removed the raise statements in the
|                                       exception block. This fix is done as
|                                       part of the bug fix #1509712
|              02/02/2001 Renga Kannan  Added code to work for Change order
|                                       In the case of model cancelation delink should not
|                                       check for workflow status. Code is changed on 02/02/2001
|              02/03/2001 Renga Kannan  Modifed the code in delink_item.
|              03/13/2001 Renga Kannan  Added code for the notification part
|                                       This change is part of the Change order project
|              04/04/2001 Renga Kannan  Modified the link_item code for the performance issue.
|                                       This is part of the bug fix # 1690095. The process order call in
|                                       in link_item code is replaced with direct update statement.
|              05/30/2001 Sushant Sawant Modified the load_mandatory_comps and
|                                       load_mandatory_components procedure
|                                       for bug fix 1518894.
|              06-10-2001 SBhaskar     Bugfix 1811007
|                             Added code to calculate weight/volume
|                             of the configuration item in the shipping org.
|	       07-18-2001 Kundan Sarkar Bugfix 1876997 .
|				Add code to improve performance.
|				Modify query to replace an expensive view
|				(wsh_delivery_line_status_v) with its base tables.
|
|              08-24-2001 Sushant Sawant: BUG #1957336
|                             Added a new functionality for preconfigure bom.
|
|              08-31-01    Renga Kannan
|			      Modified the create_item procedure to call
|                             CTO_CUSTOM_LIST_PRICE_PK.get_list_price to calculate
|                             the price list for configuration items.
|                             For More details please look at Procuring config Phse I
|                             Design document.
|
|              09-05-2001 Kundan Sarkar Bugfix 1988939 ( Base Bug 1962820 ).
|				Truncate effectivity_date for correct selection of
|				eligible rows during bom_explosion.
|
|              09-11-2001 Kundan Sarkar Bugfix 1988946 ( Base bug 1968318 ).
|				No longer checking activity_label while selecting
|				activity_status_code of an item.
|
|              09-25-2001 Kundan Sarkar Bugfix 2034342 ( Base bug 1985793 ).
|				Checking greater of sysdate and calendar date while
|				checking for item effectivity so that planning will get
|				components effective till sysdate.
|
|              09-27-2001 Kundan Sarkar Bugfix 2034342 ( Base bug 1998386 ).
|				Passing PRIMARY_QUANTITY_UOM to ATP
|
|              10-02-2001 Kundan Sarkar Bugfix 2041612 ( Base bugs 2034419 and 1997355)
|				Calling MRP API MRP_OM_API_PK to insert the config items
|				line id during linking and delinking of config item.
|
|              10-29-2001 Kundan Sarkar Bugfix 2133816 ( Base bug 2047428 ).
|				Loading Mandatory components even if Top Model ATP components
|				flag is set to 'N'.Christine of Planning team has confirmed
|				that we should honor the ATP components flag of top model and
|				explosion need not take place if the ATP components flag on
|				model is set to 'N'. Fixed the code accordingly .
|
|              Modified on 08-JAN-2002 by Sushant Sawant: BUG #2172057
|                             Added a restriction for numbering method to be used while creating
|				configuration due to preconfigure bom limitation.
|
|              01-28-2002 Kundan Sarkar Bugfix 2202633 ( Base bug 2197842 ).
|					Config item created is not assigned to Purchasing default
|					category and hence cannot be entered in a purchase order.
|
|              01-28-2002 Kundan Sarkar Bugfix 2186114 ( Base bug 2162912 ).
|					In load_mandatory_comps and load_mandatory_components :
|					1) Truncate disable_date to correctly compare it with calendar_date.
|					2) Replace >= with > while comparing disable_date and calendar_date.
|					3) Replace to_date and to_char conversion functions for eff_date and
|					disable_date check since they are compared with calendar_date which
|					does not have timestamp.
|
|              03-08-2002 Sushant Sawant BUG#2234858
|					 Added new functionality for Drop Shipment
|                                        Changed functions link_item
|                                        Changed functions delink_item
|
|
|              03-25-2002 Renga Kannan  Removed the custom API call for list price.
|                                       This custom API will be called as part of List price rollup
|
|
|
|              03/31/2002 Renga Kannan  Bugfix 2288258 : Make the update visible_demand_flag statement more restrictive
					while it is performing update during delink action of ML/MO or BUY Model.
|
|              04/08/2002 Sushant Sawant BugFix 2300006 : Multiple Instantiation Usability Issues.
|                                        This fix will align each configuration next to the model
|                                        it corresponds to.
|
|              04-09-2002 Kundan Sarkar Bugfix 2292466 ( Base bug 2267646 ).
|                                       Added NVL function .
|
|              04-18-2002 Kundan Sarkar Bugfix 2337353 ( Base bug 2157740 ).
|					Copying Base Model attachement to Config item.
|
|
|              05-14-2002 Renga Kannan  Removed the attribute list_price_per_unit
|                                       from copying it to config item in mtl_system_items
|                                       Look at the bug details 2370307
|
|
|              06-03-2002 Sushant Sawant Bugfix 2401654 [duplicate of 2400948
|                                        and bug 2378556 ]
|                                        Changed query in load_mandatory_components
|                                        made changes to get only standard
|                                        mandatory components.
|
|              06-20-2002 Sushant Sawant Bugfix 2420865(a.k.a.BUG2428214)
|                                        get_mandatory_components was fixed to
|                                        handle arrival sets. In case of Arrival Sets
|                                        requested_arrival_date is populated instead of
|                                        requested_ship_date.
|
|              08-29-2002 Kundan Sarkar  Bugfix 2458338 ( Base bug 2395525 ).
|					 Not copying sales and Mktg category set
|					 from base model to config item.
|
|              08-29-2002 Kundan Sarkar  Bugfix 2454401 ( Base bug 2425667 ).
|                                        Infinite Loops in load_mandatory_comps and
|                                        load_mandatory_components during splitting of
|                                        an ATO model within a PTO with Tools - Debug
|                                        set to off.
|
|              08-29-2002 Kundan Sarkar  Bugfix 2541088 ( Base bug 2457514 ).
|					 Config item description picks up model desc.
|					 of base language instead of base and installed
|					 languages.
|
|              09-05-2002 Kundan Sarkar  Bugfix 2547219 ( Base bug 2461574 ).
|                                        Configured items are not inheriting transaction
|                                        defaults subinventory location from the model.
|
|              09-25-2002 Kundan Sarkar  Bugfix 2587307 ( Base bug 2576422 ).
|                                        Configured item weights are incorrect for MLMO
|                                        structure.
|
|              11-27-2002 Kundan Sarkar  Bugfix 2503104
|                                        Passing model's user_item_description to config
|                                        item .
|
|              12-09-2002 Kundan Sarkar  Bugfix 2701338 ( Base bug 2652379 )
|                                        Incorrect numbering sequence of configured items
|                                        in a multi - level structure.
|
|	      12-26-2002  Kiran Konada	bugfix 2727983
|					web_status filed is being copied for configuration item
|					from its base model.This field is a mandatory one for
					inventory from 11.5.9 onwards
|
|
|	     12-31-2002  Kiran Konada	bugfix2730055
|					insert into MTL_ITEM_REVISIONS was changed to MTL_ITEM_REVISIONS_B
|
|
|            01-23-2003 Kundan Sarkar   Bugfix 2503104
|                                       Revert fix as OM will populate user_item_description
|					of config item
|                                       Bugfix 2764811 ( In branch  2745590 )
|					Remove reference on flow schedule when config item
|					is delinked.
|
|            02-03-2003 Kundan Sarkar	Bugfix 2781022 ( In branch 2663450 )
|                                       New custom hook to generate custom item numbers for
|				        pre configured items and autocreated configurations.
|
|					Bugfix 2784045 (  no bug logged for main ...
|					Propagate this fix to main with fix of 2781022 )
|                                       Error in delink configuration when no routing is
|					defined for the model.
|
|
|	     02/04/2003 Kiran Konada
|						Added a new paramter to pass conifg/ato item id
|						to start_work_flow
|						bugfix 2782394
|
|              Modified on 14-FEB-2003  By Kundan Sarkar
|                                         Bugfix 2804321 : Propagating customer bugfix 2774570
|                                         and 2786934 to main.
|
|              Modified on 24-MAR-2003  By Kundan Sarkar
|                                         Bugfix 2867676 : Propagating customer bugfix 2858080
|                                         to main.
|
|              Modified on 14-APR-2003  By Kundan Sarkar
|                                         Bugfix 2904203 : Propagating customer bugfix 2898851
|                                         to main.
|
|              08-JUL-2003 Sushant Sawant Replicated Bugfix 2897132
|                                         (a.k.a. 2913695[actual aru]) to J Main as 3037613
|                                        Fixed bug related to get_mandatory_components
|                                        Following scenarios were addressed
|                                        1) pass correct line id for mandatory components
|                                        2) handle cancel case properly
|                                        3) handle delete case properly (respect params)
|                                        4) handle reschedule case properly
|
|
|              Modified on 14-MAR-2003 By Sushant Sawant
|                                         Decimal-Qty Support for Option Items.
|                                         Replicated 3037613 for mandatory
|                                         components
|                                         ( a.k.a 2913695, 2897132)
|
|              17-JUL-2003 Sushant Sawant Replicated Bugfix 2483920
|                                         using 3056491
|
|              30-DEC-2003 Kiran Konada   Bugfix
|                                         3340844
|                                         inserted value into revision_label
|                                         of mtl_item_revisions_b
|
|                                         3338108
|                                         a)  In 11.5.9 in the dynamic sql part
|                                         of inserting into mtl_item_revisions_b
|                                         we were inserting same revision_id for
|                                         an item in all orgs. Revision_id was a
|                                         null column
|
|                                         As items team has decide to create a
|                                         unique index on it, the revision_id needs
|                                         to be different in each org
|
|                                         b)  where condition for insert into mtl_item_revisions_tl
|                                         is also changed to get the corresponding revisionId
|                                         info from table mtl_item_revisions_b table
|
|                                         c) fixed by sawant
|                                         it is decided to leave blank the uom_code and revision_id
|                                         in mtl_cross_references
|
|              30-DEC-2003 Sushant Sawant Fixed Bug# 3358194
|                                         Weight/Vol calculations were not updated if model has no base uom.
|
|
|               ssawant   15-JAN-04   Bugfix 3379296
|               changes evaluate_atp_attributes for model attribute Y, N scenario.
|
|               KKONADA   02-03-2004   bugfix 2828588
|               Inserted the configuration data into table MTL_ABC_ASSIGNMENTS
|
|
|
|               KKONADA   03-02-2004  front port bugfix#3473737
|
|                                     branch Bugfix 3463999 : Updating config_id in bcol to null
|					  if config is matched.
|
|
|              KKONADA   03-15-2004   Corrected the comments
|                          bug#3340844 was entered for 3338108 at few places , corrected
|                         the error
|
|
|              Kkkonada  03-26-2004  Kiran Konada
|                        Bugfix 3536085
|                        assignment_group_id and inventory_item_id should be unique
|
|
|              Modified on 26-Mar-2004 By Sushant Sawant
|                                         Fixed Bug#3484511
|                                         all queries referencing oe_system_parameters_all
|                                         should be replaced with a function call to oe_sys_parameters.value
|
|
|              Modified on 23-Jun-2006  by Kiran Konada
|                                      Revreted bugfix 3473737, branch fix 3463999
|
|             modified on 01-jul-2004	kiran konada
|                                    	aru 3737772 (for FP 3473737)
|                                       added pconfigid parameter to ATO_WEIGHT_VOL api
|                                       and changed the de_code statment in wt_vol api
|
|
|
|              Modified on 18-APR-2005 By Sushant Sawant
|                                         Fixed Bug#4172300
|                                         Cost in validation org is not copied properly from model to config item.
|
|              Modified on 05-Jul-2005 by Renga Kannan
|                                         Change for MOAC
|                                         As per OM
s recommendation changing the process order Public API call to Group API call
for Link item
|
|
|             Modified on 08-Aug-2005  Kiran Konada
|                                      bug# 4539578
|                                      In R12, mtl_cross_references datamodel has been changed to
|				       mtl_cross_references_b and mtl_cross_references_tl
|
|             Modified on 15-Sep-2005  Renga Kannan
|                                      Made Code changes for ATG Performance
|                                      Project
|
|             Modified on 03-feb-2006  Kiran Konada
|                                      bugfix FP 4861996
|                                      should check if a specific item is present
|                                      in specificy category set
|
|               07-Mar-2006		Kiran Konada
|                                      performance  bug#4905845
|					Removed comments to reduce shared memory
|
+-----------------------------------------------------------------------------*/


PG_DEBUG Number := NVL(FND_PROFILE.value('ONT_DEBUG_LEVEL'), 0);

g_atp_flag varchar2(1) := 'N' ;

TYPE ATTRIB_NAME_TAB_TYPE is table of mtl_item_attributes.attribute_name%type index by binary_integer ;

TYPE CONTROL_LEVEL_TAB_TYPE is table of mtl_item_attributes.control_level%type index by binary_integer ;

    g_attribute_name_tab    ATTRIB_NAME_TAB_TYPE ;
    g_control_level_tab     CONTROL_LEVEL_TAB_TYPE ;


procedure create_preconfigured_item( p_line_id in number
                         , p_model_id       in number
                         , p_config_id       in number
                         , p_lItemType        in varchar2 );


-- bugfix 2706981: forward declaration
FUNCTION check_dup_item(
    pSegment1 	varchar2,
    pSegment2 	varchar2,
    pSegment3 	varchar2,
    pSegment4 	varchar2,
    pSegment5 	varchar2,
    pSegment6 	varchar2,
    pSegment7 	varchar2,
    pSegment8 	varchar2,
    pSegment9 	varchar2,
    pSegment10 	varchar2,
    pSegment11 	varchar2,
    pSegment12 	varchar2,
    pSegment13 	varchar2,
    pSegment14 	varchar2,
    pSegment15 	varchar2,
    pSegment16 	varchar2,
    pSegment17 	varchar2,
    pSegment18 	varchar2,
    pSegment19 	varchar2,
    pSegment20 	varchar2)
RETURN number;

-- bugfix 3026929: forward declaration
PROCEDURE populate_item_revision(pConfigId	number,
				 pModelId	number,
				 pLineId	number,
				 xReturnStatus	OUT NOCOPY varchar2);

--Bugfix 9223554
PROCEDURE update_wt_vol_tbl(p_tbl_type number,
                            p_line_id  number)
is
   l_line_id            number := p_line_id;
   l_ato_line_id        number;
   i                    number;
begin
   IF PG_DEBUG <> 0 THEN
     oe_debug_pub.add('update_wt_vol_tbl: p_tbl_type:' || p_tbl_type);
     oe_debug_pub.add('update_wt_vol_tbl: p_line_id:' || p_line_id);
   END IF;

   if p_tbl_type = 1 then
     --Mark all parents of this line as not eligible for processing.
     loop
        if not g_wt_tbl.exists(l_line_id) then
          g_wt_tbl(l_line_id) := l_line_id;
        end if;

	select parent_ato_line_id, ato_line_id
        into l_line_id, l_ato_line_id
        from bom_cto_order_lines
        where line_id = l_line_id;

        exit when l_line_id = l_ato_line_id;
     end loop;

     --Inserting the top model line in the table.
     if not g_wt_tbl.exists(l_line_id) then
       g_wt_tbl(l_line_id) := l_line_id;
     end if;

     IF PG_DEBUG <> 0 THEN
       i := g_wt_tbl.first;
       while i is not null
       loop
         IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add('update_wt_vol_tbl: Index' || i || ':' || g_wt_tbl(i));
	 END IF;
	 i := g_wt_tbl.next(i);
       end loop;
     END IF;

   elsif p_tbl_type = 2 then
     --Mark all parents of this line as not eligible for processing.
     loop
        if not g_vol_tbl.exists(l_line_id) then
          g_vol_tbl(l_line_id) := l_line_id;
        end if;

	select parent_ato_line_id, ato_line_id
        into l_line_id, l_ato_line_id
        from bom_cto_order_lines
        where line_id = l_line_id;

        exit when l_line_id = l_ato_line_id;
     end loop;

     --Inserting the top model line in the table.
     if not g_vol_tbl.exists(l_line_id) then
       g_vol_tbl(l_line_id) := l_line_id;
     end if;

     IF PG_DEBUG <> 0 THEN
       i := g_vol_tbl.first;
       while i is not null
       loop
         IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add('update_wt_vol_tbl: Index' || i || ':' || g_vol_tbl(i));
	 END IF;
	 i := g_vol_tbl.next(i);
       end loop;
     END IF;
   end if;
end update_wt_vol_tbl;


function get_attribute_control( p_attribute_name in varchar2)
return number
is
v_attribute_name varchar2(100);
begin
   v_attribute_name := UPPER( p_attribute_name );

   for i in 1..g_attribute_name_tab.count
   loop
       if( g_attribute_name_tab(i) = v_attribute_name ) then
           return g_control_level_tab(i);
       end if;

   end loop ;

   return 0;
end get_attribute_control;



function get_atp_flag
return char
is
  v_atp_flag   Varchar2(1);
begin
  v_atp_flag := g_atp_flag;
  g_atp_flag := null;
  return v_atp_flag ;

/*
** g_atp_flag has to be returned in a tricky way to avoid the sql statement from
** using the value before evaluate_atp_attributes call
*/

end get_atp_flag;


function evaluate_atp_attributes( p_atp_flag in mtl_system_items_b.atp_flag%type
                  , p_atp_components_flag in mtl_system_items_b.atp_components_flag%type )
return char
is
v_atp_components_flag   mtl_system_items_b.atp_components_flag%type ;
begin

    /* Note: Although a lot of similarity exists for some combination of flag values
             the results are bound to change based on new functionality/bug fix issues.
             This code will be easier to maintain if the logic appears more like a
             truth table
             The variable g_atp_flag is set to avoid making another call to get the
             value for the second column.
    */

   if( p_atp_flag = 'N' ) then

       if( p_atp_components_flag = 'N' ) then

           g_atp_flag := 'N' ;
           v_atp_components_flag := 'N' ;

       elsif( p_atp_components_flag = 'Y' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'Y' ;

       elsif( p_atp_components_flag = 'R' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'R' ;

       elsif( p_atp_components_flag = 'C' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'C' ;

       end if;

   elsif( p_atp_flag = 'Y') then

       if( p_atp_components_flag = 'N' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'N' ;  -- fixed bug 3379296

       elsif( p_atp_components_flag = 'Y' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'Y' ;

       elsif( p_atp_components_flag = 'R' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'R' ;

       elsif( p_atp_components_flag = 'C' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'C' ;

       end if;



   elsif( p_atp_flag = 'R' ) then

       if( p_atp_components_flag = 'N' ) then

           g_atp_flag := 'N' ;
           v_atp_components_flag := 'N' ;  /* Doubtful please check again */

       elsif( p_atp_components_flag = 'Y' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'Y' ;

       elsif( p_atp_components_flag = 'R' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'R' ;

       elsif( p_atp_components_flag = 'C' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'C' ;

       end if;




   elsif( p_atp_flag = 'C' ) then

       if( p_atp_components_flag = 'N' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'N' ;

       elsif( p_atp_components_flag = 'Y' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'Y' ;

       elsif( p_atp_components_flag = 'R' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'R' ;

       elsif( p_atp_components_flag = 'C' ) then

           g_atp_flag := 'Y' ;
           v_atp_components_flag := 'C' ;

       end if;


  end if ;



 oe_debug_pub.add( ' ************* EVALUATE_ATP_ATTRIBUTES ***  p_atp_flag ' || p_atp_flag
                || ' p_atp_components_flag ' || p_atp_components_flag
                || ' result ' || ' g_atp_flag ' || g_atp_flag
                || ' v_atp_components_flag ' || v_atp_components_flag  , 1 ) ;




  return v_atp_components_flag  ;



end evaluate_atp_attributes ;





function get_cost_group( pOrgId  in number,
                         pLineID in number)
return integer is

l_cst_grp   number;

begin

    /*--------------------------------------------+
        This is a function to get cost_group_id
        for using in insert to cst_quantity_layers
    +---------------------------------------------*/

    select  nvl(costing_group_id,1)
    into    l_cst_grp
    from    pjm_project_parameters ppp
    where   ppp.project_id = ( select  project_id
                               from    oe_order_lines_all ol
                               where   ol.line_id = pLineId )
    and    ppp.organization_id = pOrgId;

    return(l_cst_grp);

exception
    when no_data_found then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('get_cost_group: ' || 'ERROR: Could not fetch the cost_group_id from pjm_project_parameters (NDF)',1);
	END IF;
	return(0);

end get_cost_group;


function get_validation_org ( opunit in number,
                              profile_val in number)
return integer
is

	lValue          fnd_profile_option_values.profile_option_value%type;
	loldvalue       fnd_profile_option_values.profile_option_value%type;
	lValidOrg       number;


  	cursor validation_org is
  	select  distinct POV.profile_option_value
  	from    fnd_profile_options PO	,
          	fnd_profile_option_values POV,
          	fnd_responsibility FR,
          	fnd_profile_options PO2,
          	fnd_profile_option_values POV2
   	where  PO.profile_option_name = 'SO_ORGANIZATION_ID'
   	and    POV.application_id = PO.application_id
   	and    POV.profile_option_id = PO.profile_option_id
   	and    POV.level_id = 10003
   	and    FR.application_id = POV.level_value_application_id
   	and    FR.responsibility_id = POV.level_value
   	and    PO2.profile_option_name = 'ORG_ID'
   	and    POV2.application_id = PO2.application_id
   	and    POV2.profile_option_id = PO2.profile_option_id
   	and    POV2.level_id = 10003
   	and    POV2.profile_option_value = to_char(opunit)
   	and    POV2.level_value_Application_id = 660         -- ONT
   	and    FR.application_id = POV2.level_value_application_id
   	and    FR.responsibility_id = POV2.level_value;

 	multiorg_error      EXCEPTION;

begin

   lOldValue := 0;
   /*------------------------------------------------------+
     Get the site level values for so_organization_id
     for the OE responsibility of operating unit opunit.
     Only one row should be returned. If no row is returned,
     use the profile value (so_organization_id) of this
     responsibility.
   +-------------------------------------------------------*/

   open validation_org;

   fetch validation_org into lvalue;
   lOldValue := lValue;

   while validation_org%found
   loop
       fetch validation_org into lvalue;
       if validation_org%rowcount > 1 then
          if lOldValue <> lvalue then
               raise multiorg_error;
          end if;
       end if;
   end loop;
   if validation_org%rowcount = 0 then
      lValidOrg :=  profile_val;
   else
      lValidOrg := to_number(lOldvalue);
   end if;
   close validation_org;
   return (lValidOrg);

exception
  when others then
     return(0);

end get_validation_org;



function flow_schedule_exists(
         pLineId          in     number    ,
         xErrorMessage    out NOCOPY   varchar2  ,
         xMessageName     out NOCOPY   varchar2  ,
         xTableName       out NOCOPY    varchar2  )
return boolean
is

    lWipEntityId   number;

begin

    select wip_entity_id
    into   lWipEntityId
    from   wip_flow_schedules   wfs,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    where  wfs.demand_source_line   = oel.line_id    --config line id
    and    oel.line_id              = pLineId
    and    oeh.header_id            = oel.header_id
    and    oeh.order_type_id        = ota.transaction_type_id
    and    ota.transaction_type_code='ORDER'
    and    ota.transaction_type_id  = otl.transaction_type_id
    and    oeh.order_number         = mso.segment1
    and    otl.name                 = mso.segment2
    and    otl.language 	    = (select language_code
					from fnd_languages
					where installed_flag = 'B')
    and    mso.sales_order_id       = wfs.demand_source_header_id
    and    oel.inventory_item_id    = wfs.primary_item_id
    and rownum = 1;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('flow_schedule_exists: ' || 'Flow Schedule Exists!', 1);
    END IF;

    return(true);  -- Flow Schedule  exists

exception
    when no_data_found then

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add ('flow_schedule_exists: ' || 'Flow Schedules does not exist ', 1);
         END IF;
         return(false);     -- Flow Schedule does not exist

    when  others then
        xErrorMessage := 'ERROR: Flow Schedule exists for this line, Cannot delink';
        xMessageName  := 'CTO_DELINK_ITEM_ERROR';
        xTableName    := 'WIP_FLOW_SCHEDULES';
        return(false);

end flow_schedule_exists;

----------------------------------------

function work_orders_exist (
         pLineId          in     number    ,
         xErrorMessage    out NOCOPY   varchar2  ,
         xMessageName     out NOCOPY   varchar2  ,
         xTableName       out NOCOPY   varchar2  )
return boolean
is

lReserveId   number;

begin

    select reservation_id
    into   lReserveId
    from   mtl_reservations     mr,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    where  mr.demand_source_line_id = oel.line_id    --config line id
    and    oel.line_id              = pLineId
    and    oeh.header_id            = oel.header_id
    and    oeh.order_type_id        = ota.transaction_type_id
    and    ota.transaction_type_code = 'ORDER'
    and    ota.transaction_type_id  = otl.transaction_type_id
    and    oeh.order_number         = mso.segment1
    and    otl.name                 = mso.segment2
    and    otl.language 	    = (select language_code
					from fnd_languages
					where installed_flag = 'B')
    and    mso.sales_order_id       = mr.demand_source_header_id
    and    mr.demand_source_type_id = decode(oeh.source_document_type_id, 10,
						INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
                                             	INV_RESERVATION_GLOBAL.g_source_type_oe)	--bugfix 1799874
    and    mr.reservation_quantity  > 0
    and supply_source_type_id     = INV_RESERVATION_GLOBAL.g_source_type_wip
    and rownum = 1;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('work_orders_exist: ' || 'Work orders exist! Call wip_holds api', 2);
    END IF;

    return(true);  -- reservation exists

exception
    when no_data_found then

         IF PG_DEBUG <> 0 THEN
         	oe_debug_pub.add ('work_orders_exist: ' || 'Work orders do not exist, do not call wip holds api ', 2);
         END IF;
         return(false);     -- Reservation does not exist

    when  others then
        xErrorMessage := 'ERROR: Failed in work_orders_exist ';
        xMessageName  := 'CTO_DELINK_ITEM_ERROR';
        xTableName    := 'MTL_RESERVATIONS';
       return(false);

end work_orders_exist;



function delink_item (
         pModelLineId     in     number    ,
         pConfigId        in     number    ,
         xErrorMessage    out NOCOPY    varchar2  ,
         xMessageName     out NOCOPY   varchar2  ,
         xTableName       out NOCOPY   varchar2  )
return integer
is

    lStmtNumber    		number;
    lConfigLineId  		number;
    lreserveId     		number;
    lWfStat        		varchar2(80);
    lCancel_flag   		varchar2(1) := 'N';
    lCount         		number;
    l_source_type  		number;

    -- The following flag is added by Renga Kannan on 03/13/2001

    l_resv_flag    		varchar2(1) := 'N';
    pchgtype       		CTO_CHANGE_ORDER_PK.change_table_type;
    l_order_number 		OE_ORDER_HEADERS_ALL.order_number%TYPE;
    l_ml_mo_flag   		varchar2(1) := 'N';

    pAutoUnreserve 		varchar2(1);

    l_return_status           	varchar2(1) := FND_API.G_RET_STS_SUCCESS;
    l_msg_count               	number;
    l_msg_data                	varchar2(2000);
    l_option_line_id	      	number;

    i 				number;
    x				number;
    y				varchar(1);
    z				varchar(30);

    lOrgId			number;
    lSalesOrderId		number;
    lHeaderId			number;
    lSourceCode			varchar2(30);

    l_rsv       		INV_RESERVATION_GLOBAL.mtl_reservation_rec_type;
    l_rsv_id    		number;
    l_dummy_sn  		INV_RESERVATION_GLOBAL.serial_number_tbl_type;
    l_status    		varchar2(1);
    lShipConfirmed		varchar2(10);

    --Begin Bugfix 1997355

    index_counter_delink	number;
    p_config_line_arr_delink	MRP_OM_API_PK.line_id_tbl;
    l_return_status_delink 	varchar2(1);
    vLineId			number;

     --End Bugfix  1997355

     -- begin bugfix 2745590
     lcfm_routing_flag		number;
     lflow_schedule_exist	number;
     -- end bugfix 2745590

    CURSOR reservations IS
        select distinct reservation_id
    	from   mtl_reservations     mr,
           oe_order_lines_all   oel,
           oe_order_headers_all oeh,
           oe_transaction_types_all ota,
           oe_transaction_types_tl  otl,
           mtl_sales_orders     mso
    	where  mr.demand_source_line_id = oel.line_id    --config line id
    	and    oel.line_id              = lConfigLineId
    	and    oeh.header_id            = oel.header_id
    	and    oeh.order_type_id        = ota.transaction_type_id
    	and    ota.transaction_type_code='ORDER'
    	and    ota.transaction_type_id  = otl.transaction_type_id
    	and    oeh.order_number         = mso.segment1
    	and    otl.name                 = mso.segment2
        and    otl.language 	        = (select language_code
	 				from fnd_languages
					where installed_flag = 'B')
    	and    mso.sales_order_id       = mr.demand_source_header_id
        and    mr.demand_source_type_id = decode(oeh.source_document_type_id, 10,
							INV_RESERVATION_GLOBAL.g_source_type_internal_ord,
                                             		INV_RESERVATION_GLOBAL.g_source_type_oe)	--bugfix 1799874
    	and    mr.reservation_quantity  > 0;

   --Begin Bugfix 1997355

   CURSOR delink_lines IS
    	select line_id
    	from oe_order_lines_all
    	where ato_line_id = pModelLineId;

   --End Bugfix 1997355

      v_source_type_code   oe_order_lines_all.source_type_code%type ; /* BUG#2234858 */

      -- Added by Renga Kannan on 05/13/02
      -- for bug fix 2366241

      l_header_id     oe_order_lines_all.header_id%type;

      v_aps_version   number := 0;


      v_model_line_activity    varchar2(100) ;


      v_appl_name  varchar2(200) ;
      v_error_name varchar2(2000) ;

BEGIN

   lShipConfirmed := 'FALSE';



   lStmtNumber := 400;
   -- BUG#2234858
   -- Modified by Sushant Sawant 02/14/2002. The source type for the model
   -- needs to be retrieved to distinguish between drop shipped orders(external)
   -- and regular orders( internal )

   select source_type_code into v_source_type_code
   from   oe_order_lines_all
   where  line_id = pModelLineId ;




   lStmtNumber := 500;
   -- Modified by Renga Kannan 02/03/2001. The condition checking for
   -- Cancelled_flag is removed . because delink is called even in the case of
   -- Cancelled lines.

   select line_id, ship_from_org_id,header_id
   into   lConfigLineId, lOrgId,l_header_id
   from   oe_order_lines_all oel
   where  ato_line_id = pModelLineId
   and    inventory_item_id = pConfigid
   and    item_type_code    = 'CONFIG';

   BEGIN
      --
      -- Do not allow delink if config line is ship confirmed
      -- A shipment line can be in 'open','packed','confirmed','in-transit'
      -- or 'closed' status. Allow delink only if 'OPEN'
      --
      lStmtNumber := 505;

      -- begin bugfix 2001824:
      -- To check if something has been "shipped" , we should check for released_status.
      -- If the released_status is either 'Y' (staged) or 'C' (closed), we should consider
      -- the line as shipped (partial or fully)

      select distinct 'TRUE'
      into   lShipConfirmed
      from   wsh_delivery_details_ob_grp_v wdd -- Added By Renga Kannan on 11/03/03 for wsh data model changes
      where  wdd.source_line_id = lConfigLineId
      and    wdd.source_code = 'OE'
      and    wdd.released_status in ('Y', 'C');		-- Staged [Y], Closed [C]

      if (lShipConfirmed = 'TRUE' ) then
   	IF PG_DEBUG <> 0 THEN
   		oe_debug_pub.add ('delink_item: ' || 'Error : Config Line has been ship confirmed. Can not delink',1);
   	END IF;
	xMessageName    := 'CTO_DELINK_SHIPPING_ERROR';
	raise FND_API.G_EXC_ERROR;
      end if;

   EXCEPTION
   	when no_data_found then
   		IF PG_DEBUG <> 0 THEN
   			oe_debug_pub.add ('delink_item: ' || 'Config Line does not exist in shipping yet. Delink allowed',2);
   		END IF;

   END;
   -- end bugfix 2001824


   lStmtNumber := 510;
   lSourceCode := fnd_profile.value('ONT_SOURCE_CODE');
   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('delink_item: ' || 'lSourceCode is '||lSourceCode, 2);
   END IF;

   --
   -- Get header id, other info for calling Reservation API
   --

   select mso.sales_order_id,
        oel.ship_from_org_id,
	oeh.header_id
   into   lSalesOrderId,	--header id fro rsv api
	  lOrgId, 		--ship from org id
	  lHeaderId		-- header id in oeh, for wip api
   from   oe_order_lines_all oel,
          oe_order_headers_all oeh,
	  oe_transaction_types_tl oet,
          mtl_sales_orders mso,
          mtl_system_items msi
   where  oel.line_id = lConfigLineId
   and    item_type_code = 'CONFIG'
   and    oeh.header_id = oel.header_id
   and    oet.transaction_type_id = oeh.order_type_id
   and    mso.segment1 = to_char(oeh.order_number)
   and    mso.segment2 = oet.name
   and    oet.language = (select language_code
			from fnd_languages
			where installed_flag = 'B')
   and    mso.segment3 = lSourceCode
   and    oel.inventory_item_id = pConfigId
   and    msi.inventory_item_id = oel.inventory_item_id
   and    msi.organization_id = oel.ship_from_org_id
   and    msi.base_item_id is not NULL;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add ('delink_item: ' || 'Before WIP parameter check', 2);

   	oe_debug_pub.add ('delink_item: ' || 'Config Line_id is ' || lConfigLineId, 2);

   	oe_debug_pub.add ('delink_item: ' || 'Config item_id is ' || pConfigId, 2);

   	oe_debug_pub.add ('delink_item: ' || 'org id is ' || lOrgId, 2);

   	oe_debug_pub.add ('delink_item: ' || 'Sales Order id is ' || lSalesOrderId, 2);
   END IF;

   -- begin bugfix 2745590 :  Check for routing flag : 1 = Flow Routing

	lStmtNumber := 511;
	-- 2784045 : Select stmt is enclosed in block to handle exception
   begin
	select 	nvl(cfm_routing_flag, 2)
	into 	lcfm_routing_flag
	from 	bom_operational_routings
	where 	assembly_item_id  = pConfigid
	and 	organization_id  = lOrgId
	and 	alternate_routing_designator is NULL;
   exception
   	 when no_data_found then
              lcfm_routing_flag :=2;
   end;
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('delink_item: Routing flag ( if 1, flow routing ) = '||to_char(lcfm_routing_flag), 2);
        END IF;

	-- Check if flow schedule exist
	-- 2784045 : This 'if' condition is decoupled from flow_sch_exist to make the code more efficient
   if ( lcfm_routing_flag = 1 ) then
	select 	count(*)
	into 	lflow_schedule_exist
	from 	wip_flow_schedules
	where 	demand_source_line = to_char(lConfigLineId)
    	and 	primary_item_id    = pConfigid
    	and 	demand_source_type = 2 ;

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('delink_item: Flow Schedule exist ( if > 0 ) = '||to_char(lflow_schedule_exist), 2);
        END IF;

    	-- Call MRP API unlink_order_line if flow schedule exist and routing is flow_routing
    	-- 2784045 if ( lcfm_routing_flag = 1 ) and ( lflow_schedule_exist > 0 ) then
    	if ( lflow_schedule_exist > 0 ) then
    		MRP_Flow_Schedule_PUB.unlink_order_line
    			(
			p_api_version_number 	=> 1.0,
			x_return_status 	=> l_status,
			x_msg_count         	=> l_msg_count,
			x_msg_data          	=> l_msg_data,
			p_assembly_item_id	=> pConfigid ,
			p_line_id		=> lConfigLineId
			);

		if l_status = FND_API.G_RET_STS_ERROR then
			IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add ('delink_item: ' || 'Error: Failed in MRP_Flow_Schedule_PUB.unlink_order_line with expected error.', 1);
     			END IF;

                        /* Bugfix 2454788 */
			raise FND_API.G_EXC_ERROR;

  		elsif l_status = FND_API.G_RET_STS_UNEXP_ERROR then
  			IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add ('delink_item: ' || 'Error: Failed in MRP_Flow_Schedule_PUB.unlink_order_line with unexpected error.', 1);
     			END IF;
     			xMessageName    := 'CTO_DELINK_ITEM_ERROR';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;

		elsif l_status = fnd_api.g_ret_sts_success then
			IF PG_DEBUG <> 0 THEN
               			oe_debug_pub.add ('delink_item: ' || 'Removed config line reference from flow schedule', 2);
                	END IF;
                	-- Check for l_resv_flag. If it is "N" , set it to "Y" .
    			-- The Flag is set to Yes, so that we can call the notification later.
                        If l_resv_flag = 'N' then
                               	l_resv_flag := 'Y';
                        end if;
		end if;
  	end if;		-- flow_sch > 0
  end if;		-- 2784045 cfm_routing_flag = 1

	-- end bugfix 2745590

   lStmtNumber := 515;

--
-- will allow delink even if flow schedules exist
--


   /*--------------------------------------------------------+
 	Get the Auto Unreserve flag
   +--------------------------------------------------------*/
	--
	-- The auto unreserve flag was being passed by OE in 11.0.
	-- Auto Unrsv flag = 'N' => do not delink
	-- Auto Unrsv flag = 'Y' => perform delink
	-- The flag was always being passed as 'Y', so there is no
	-- purpose of having a flag
	--

	/*----------------------------------+
	   Get the WIP parameter
	   "Respond to sales order changes"
	+-----------------------------------*/
	lStmtNumber := 517;


        /* BUG#2234858 Sushant Added this condition for drop ship project */

        if( v_source_type_code = 'INTERNAL' ) then

	--call wip api if there are no work orders
	if work_orders_exist( lConfigLineId,
         		xErrorMessage,
         		xMessageName,
         		xTableName)
        then
   		IF PG_DEBUG <> 0 THEN
   			oe_debug_pub.add ('delink_item: ' || 'work orders exist', 2);
   		END IF;

                -- Added by Renga Kannan on 03/13/2001
                -- The Flag is to Yes, So that we can call the notification later in this
                -- Function.
                l_resv_flag := 'Y';

		WIP_SO_RESERVATIONS.respond_to_change_order(
				p_org_id	=> lOrgId,
				p_header_id	=> lSalesOrderId,
				p_line_id	=> lConfigLineId,
				x_status	=> l_return_status,
				x_msg_count	=> l_msg_count,
    				x_msg_data	=> l_msg_data);

  		if l_return_status = FND_API.G_RET_STS_ERROR then
     			IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add ('delink_item: ' || 'Error: Failed in wip_so_reservations.respond_to_change_order with expected error.', 1);
     			END IF;

                        /* Bugfix 2454788 */
			raise FND_API.G_EXC_ERROR;

  		elsif l_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
     			IF PG_DEBUG <> 0 THEN
     				oe_debug_pub.add ('delink_item: ' || 'Error: Failed in wip_so_reservations.respond_to_change_order with unexpected error.', 1);
     			END IF;
			xMessageName    := 'CTO_DELINK_ITEM_ERROR';
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
  		end if;

	else
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('delink_item: ' || 'WOS does not exist', 2);
		END IF;
		l_return_status := FND_API.G_RET_STS_SUCCESS;
	end if;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('delink_item: ' || 'Resp to SO changes returned' || l_return_status, 2);

		oe_debug_pub.add ('delink_item: ' || 'Resp to SO changes returned with msg : ' || l_msg_data, 2);
	END IF;

	lStmtNumber := 518;
	if (l_return_status = FND_API.G_RET_STS_SUCCESS) then

		OPEN reservations;
    		LOOP
    			FETCH reservations into l_rsv.reservation_id;
    			EXIT when reservations%NOTFOUND;

			-- call INV delete_reservations API
     			INV_RESERVATION_PUB.delete_reservation
				(
        			p_api_version_number  => 1.0
	      			, p_init_msg_lst      => fnd_api.g_true
	   			, x_return_status     => l_status
	   			, x_msg_count         => l_msg_count
	   			, x_msg_data          => l_msg_data
			   	, p_rsv_rec           => l_rsv
   				, p_serial_number     => l_dummy_sn
				);

			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('delink_item: ' || 'After deleting rsv, rsv_id = '||to_char(l_rsv.reservation_id)||', l_status = '||l_status, 2);
			END IF;
			IF l_status = fnd_api.g_ret_sts_success THEN
				IF PG_DEBUG <> 0 THEN
					oe_debug_pub.add ('delink_item: ' || 'reservations deleted', 2);
				END IF;
                                -- Added by Renga Kannan on 03/13/2001
                                -- The Flag is to Yes, So that we can call the notification later in this
                                -- Function.
                                l_resv_flag := 'Y';

			ELSE
       				IF l_msg_count = 1 THEN
					IF PG_DEBUG <> 0 THEN
						oe_debug_pub.add ('delink_item: ' || 'Error in rsv delete', 1);

						oe_debug_pub.add ('delink_item: ' || 'l_msg_data ='||l_msg_data, 1);
					END IF;

					CLOSE reservations;

					xMessageName    := 'CTO_DELINK_ITEM_ERROR';
					raise FND_API.G_EXC_ERROR;

        			ELSE
  					FOR l_index IN 1..l_msg_count LOOP
					  IF PG_DEBUG <> 0 THEN
					  	oe_debug_pub.add ('delink_item: ' || 'Error in rsv delete', 1);

					  	oe_debug_pub.add ('delink_item: ' || 'l_msg_data ='||l_msg_data, 1);
					  END IF;
   					END LOOP;

					CLOSE reservations;

					xMessageName    := 'CTO_DELINK_ITEM_ERROR';
					raise FND_API.G_EXC_ERROR;
        			END IF;
     			END IF;
    		END LOOP;
    		CLOSE reservations;
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add ('delink_item: ' || 'After reservations cursor loop', 2);
        	END IF;

	end if; /* end check l_return_status */

           -- rkaza. ireq project. 05/13/2005.
           -- Delete any records in req interface for this config line.

           cto_change_order_pk.delete_from_req_interface(
                p_line_id => lConfigLineId,
                p_item_id => pConfigId,
                x_return_status => l_return_status ) ;

           if l_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR then
              raise FND_API.G_EXC_UNEXPECTED_ERROR;
           elsif l_Return_Status = FND_API.G_RET_STS_ERROR then
              raise FND_API.G_EXC_ERROR;
           end if;

        end if ; /* source_type_code = 'INTERNAL' */






                /* BUG#2234858 Sushant added the end if statement for drop ship project */


		--delink

                -- Added by Renga Kannan on 02/02/2001
                -- Before Checking for workflow status for model check if the
                -- the model line is canceled. If canceled we should not check the
                -- work flow status as the status is already modified by OM.

		/*-----------------------------------------+
		Getting the activity status code
		+-----------------------------------------*/
                SELECT  nvl(cancelled_flag,'N')
                INTO    lcancel_flag   --- Reusing the variable
                FROM    OE_ORDER_LINES_ALL
                WHERE   line_id = pModelLineId;

   		lStmtNumber := 520;

                IF lcancel_flag <> 'Y'  THEN
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('delink_item: ' || 'The model line is not cancelled',2);
                   END IF;


                   begin


		   select activity_status
    		   into   lWfStat
    		   from   wf_item_activity_statuses was
    		   where  was.item_type      = 'OEOL'
    		   and    was.item_key       = to_char(pModelLineId)
		   and was.activity_status = 'NOTIFIED'
    		   and    was.process_activity in
			(SELECT wpa.instance_id
			FROM  wf_process_activities wpa
	 		WHERE wpa.activity_name = 'WAIT_FOR_CTO');


                   v_model_line_activity := 'WAIT_FOR_CTO' ;


                   exception
                   when no_data_found then


                        v_aps_version := msc_atp_global.get_aps_version  ;

                        oe_debug_pub.add('link_config: ' || 'APS version::'|| v_aps_version , 2);

                        if( v_aps_version <> 10 ) then

                           raise no_data_found ;

                        else

                            oe_debug_pub.add('link_config: ' || 'Model Line workflow need not be at WAIT_FOR_CTO as APS version::'|| v_aps_version , 2);

                            v_model_line_activity := 'NOT_AT_WAIT_FOR_CTO' ;


                        end if ;

                   when others then

                       raise ;

                  end ;


                ELSE
                   IF PG_DEBUG <> 0 THEN
                   	oe_debug_pub.add('delink_item: ' || 'Model Line is cancelled..',2);
                   END IF;
                END IF;

    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add ('delink_item: ' || 'calling OE_CONFIG_UTIL.delink_config',2);
    		END IF;

    		/*------------------------------------------------------+
       			We are not calling prcess_order api directly because
       			OM needs to differentiate a delink request by this
       			function and a delete line request from form and
       			over-ride or honor security constraints accordingly.
       			That can be done by the private api but not with
       			the public process order api
     		+------------------------------------------------------*/

                lstmtNumber := 523;

                -- This Part of the code is added by Renga Kannan on 03/13/2001
                -- This needs to be passed to the notification
                -- procedure later in this function.

                l_ml_mo_flag := 'Y' ; /* Notifications should be sent for delink configuration in all scenarios */

    		lStmtNumber := 530;





    		OE_CONFIG_UTIL.delink_config(
				p_line_id	=> lConfigLineId,
				x_return_status	=> l_return_status);

    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add ('delink_item: ' || 'oe_config_util.delink_config returned' || l_return_status ,1);
    		END IF;

                IF l_return_status = FND_API.G_RET_STS_ERROR THEN

                  IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('delink_item: ' || 'Expected error in OE_CONFIG_UTIL.delink_config procedure....',3);
                  END IF;

                 /* Bugfix 2454788 */
                  raise FND_API.G_EXC_ERROR;


                ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    			IF PG_DEBUG <> 0 THEN
    				oe_debug_pub.add ('delink_item: ' || 'Unexpected Error in oe_config_util.delink_config.');
    			END IF;

		  	xMessageName    := 'CTO_DELINK_ITEM_ERROR';
                  	raise FND_API.G_EXC_UNEXPECTED_ERROR;

    		END IF;



    		oe_globals.g_cascading_request_logged := TRUE;


                /* BUG#2234858
                **  Need to allow the following functionality for non drop shipped items
                */

                if( v_source_type_code = 'INTERNAL' ) then



    		--
    		-- update visible demand flag to 'Y' for model and options
    		--

    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add ('delink_item: ' || 'delink : visible demand flag : before selecting options ', 2);
    		END IF;

    		lStmtNumber    := 533;

                --- Added by Renga Kannan on 02/02/2001
                --- We have decided not to call process order API to change
                --- Flag setting. Instead we will update the flags in OE_ORDER_LINES_ALL
                --- directly. This decision is taken during change order project.
                --- Updating OE_ORDE_LINES_ALL directly instead of calling Process order
                --- API was recommended by Rajeev Bellamkonda from OM team. Date 02/02/2001


    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add ('delink_item: ' || 'l_ml_mo_flag = '|| l_ml_mo_flag, 2);
    		END IF;



                /* Changes related to Patchset J */
		-- Fixed bug 5470466
		-- We should not update visible demand flag to 'Y' for
		-- unscheduled orders. Added a condition to check
		-- if the line is scheduled or not

                   UPDATE  OE_ORDER_LINES_ALL
                   SET     visible_demand_flag = 'Y'
                   WHERE   ato_line_id = pModelLineId
                   and     header_id = l_header_id
                   and     open_flag = 'Y'
		   and     schedule_status_code is not null; -- 5470466


                end if ; /* source_type_code = 'INTERNAL' */

                /* BUG#2234858 Modified by Sushant for Drop SHip project */





    		lStmtNumber := 540;
                -- What do we do in case of cancellation


                oe_debug_pub.add( 'model line status ' || v_model_line_activity , 1 ) ;




                IF lcancel_flag <> 'Y' and v_model_line_activity = 'WAIT_FOR_CTO'   THEN --- If it is not cancellation
    		   wf_engine.CompleteActivityInternalName('OEOL',
                                                         to_char(pModelLineId),
                                                         'WAIT_FOR_CTO',
                                                         'DE_LINK');
	        END IF;







	--
	-- deleting from bom_cto_order_lines and bom_cto_src_orgs
	-- for this top ato line id
	--

	lStmtNumber := 550;

        /* BUG#2234858 Sushant Modified this code for Drop Ship Project */

        /* Changes for Patchset J
           added reference to package msc_atp_global
           pre-req aru 3111677
        */

        v_aps_version := msc_atp_global.get_aps_version  ;

        if( v_aps_version <> 10) then
		oe_debug_pub.add('delink_item: ' || 'APS version::'|| v_aps_version , 2);

        if( v_source_Type_code = 'INTERNAL') then



        IF lcancel_flag <> 'Y' THEN --- If it is not cancellation

           lStmtNumber := 570;

           --to delete the row corresponding to CID in BCOD table
           delete from bom_cto_order_demand
           where ato_line_id=pModelLineId
           and   inventory_item_id=pConfigId;

           --updating the demand_visible flag to yes in BCOD table CID removal
           lStmtNumber := 580;

           update bom_cto_order_demand
           set demand_visible = 'Y'
           where ato_line_id =pModelLineId;

        END IF;



        end if ;

        else

		oe_debug_pub.add('delink_item: ' || 'APS version::'|| v_aps_version , 2);

        end if; /* reference to get_aps_version */




        /* BUG#2234858 Sushant Modified this code for Drop Ship Project */

        -- The following block of code is added by Renga Kannan on 03/13/2001.
        -- When Customer delinks an config item that needs to be notified to the
        -- Planner if Reservation exists for this item. But this de-link code
        -- Can be get called from the change_order package itself. In this case the
        -- Change order pkg will send the notification. This procedure need not do anything.
        -- This will be accomplished by the following logic. Whenever Delink_function is called
        -- from CTO_CHANGE_ORDER_PK the package variable CHANGE_ORDER_PK_STATE is set to 1. Otherwise
        -- it is defaulted to 0. So in this function we will call the notification only if this
        -- Pkg variable value is zero and l_resv_flag is set to 'Y'. This flag is set to 'Y' in the
        -- Begining part of this function.

        lStmtNumber := 590;

        /* BUG#2234858 Sushant Modified this code for Drop Ship Project
        ** No notifications should be sent for drop shipped items
        */
        IF ( CTO_CHANGE_ORDER_PK.change_order_pk_state = 0
        and ( l_resv_flag = 'Y' or l_ml_mo_flag = 'Y')
        and v_source_type_code = 'INTERNAL' )
        THEN

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('delink_item: ' || 'Delink Action performed, Need to call notification...',2);
           END IF;
           lStmtNumber := 600;
           SELECT Order_number
           INTO   l_order_number
           FROM   OE_ORDER_HEADERS_ALL A,
                  OE_ORDER_LINES_ALL   B
           WHERE  B.line_id = pModelLineId
           AND    A.Header_id  = B.Header_Id;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add('delink_item: ' || 'Calling Notification Pkg',2);

           	oe_debug_pub.add('delink_item: ' || 'Order Number = '||to_char(l_order_number),3);

           	oe_debug_pub.add('delink_item: ' || 'Line id      = '||to_char(pModelLineId),3);
           END IF;

           pchgtype(1).change_type := CTO_CHANGE_ORDER_PK.DELINK_ACTION;
           pchgtype(1).old_value   := null;
           pchgtype(1).new_value   := null;

           lStmtNumber := 610;
           CTO_CHANGE_ORDER_PK.Start_work_flow(
                               porder_no       => l_order_number,
                               pline_no        => pModelLineId,
                               pchgtype        => pchgtype,
                               pmlmo_flag      => l_ml_mo_flag,
			       pConfig_Id      => pConfigId,	 --bugfix 2782394
                               x_return_status => l_return_status,
                               x_msg_count     => l_msg_count,
                               x_msg_data      => l_msg_data);


            IF l_return_status = FND_API.G_RET_STS_ERROR THEN
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('delink_item: ' || 'Expected error in change_notify procedure....',1);
               END IF;


                 /* Bugfix 2454788 */
               raise FND_API.G_EXC_ERROR;

            ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               IF PG_DEBUG <> 0 THEN
               	oe_debug_pub.add('delink_item: ' || 'Unexpected error occurred in change_notify...',1);
               END IF;
	       xMessageName    := 'CTO_DELINK_ITEM_ERROR';
               raise FND_API.G_EXC_UNEXPECTED_ERROR;

            END IF;

        END IF;

        --Begin Bugfix 1997355

        lStmtNumber := 611;

	index_counter_delink := 1;
	OPEN delink_lines;
        /* creating array of lines where ato_line_id = model line id */
	LOOP
		FETCH delink_lines into vLineId;
		EXIT WHEN delink_lines%NOTFOUND;
		p_config_line_arr_delink(index_counter_delink) := vLineId ;
		index_counter_delink := index_counter_delink + 1 ;
	END LOOP;



	/* Since oe_config_util.delink_config deleted lConfigLineId from oe_order_lines_all before
	   opening delink_lines cursor , lConfigLineId needs to be passed explicitely */

	p_config_line_arr_delink(index_counter_delink) := lConfigLineId;
	CLOSE delink_lines;

	MRP_OM_API_PK.MRP_OM_Interface
			(p_line_tbl		=> p_config_line_arr_delink,
			 x_return_status	=> l_return_status_delink);

    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('delink_item: ' || 'Return status from MRP_OM_Interface - Delink: '||l_return_status_delink,2);
    	END IF;

  	if l_return_status_delink = FND_API.G_RET_STS_ERROR then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('delink_item: ' || 'Failed in MRP_OM_API_PK.mrp_om_interface with expected error.', 1);
     		END IF;

                 /* Bugfix 2454788 */

		raise FND_API.G_EXC_ERROR;

  	elsif l_return_status_delink = FND_API.G_RET_STS_UNEXP_ERROR then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('delink_item: ' || 'Failed in MRP_OM_API_PK.mrp_om_interface with unexpected error.', 1);
     		END IF;


		xMessageName    := 'CTO_DELINK_ITEM_ERROR';
		raise FND_API.G_EXC_UNEXPECTED_ERROR;

  	end if;

    	--End Bugfix 1997355

	return(1);

    EXCEPTION

	when NO_DATA_FOUND then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('delink_item: ' || 'ERROR: CTOCITMB delink::ndf::'||to_char(lStmtNumber)||sqlerrm, 1);
		END IF;
                if lStmtNumber = 520 then
                   xMessageName    := 'CTO_DELINK_ITEM_ERROR';
                   xErrorMessage := 'ERROR: CTOCITMB.delink:'||to_char(lStmtNumber)||
                                     ':' || 'WAIT_FOR_CTO activity is not Notified' ;
		else
                   xErrorMessage := 'ERROR: CTOCITMB.delink:'||to_char(lStmtNumber)||
                                   ':' || 'Can not find Config Line';
                   xMessageName    := 'CTO_DELINK_ITEM_ERROR';
		end if;
                return(0);


	when FND_API.G_EXC_ERROR then

             if( xMessageName is null ) then /* xMessageName can be not null in case of CTO_DELINK_SHIPPING_ERROR */
                 /* Bugfix 2454788 */
                 CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lCount,
                  p_msg_data  => xErrorMessage
                );
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink:' || to_char(lStmtNumber)|| xErrorMessage,1);
                END IF;


                /* Bugfix 2454788 */
                /* The current Delink Architecture is dependent on passing the error message in the xMessageName variable.*/

                if( xErrorMessage is not null ) then
                    fnd_message.parse_encoded( xErrorMessage , v_appl_name, v_error_name ) ;


                    IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink: appl_name ' || v_appl_name ,1);
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink: error_name ' || v_error_name ,1);
                    END IF;


                    xErrorMessage := v_error_name;
                    xMessageName := v_error_name;

                else


                    xMessageName := 'CTO_DELINK_ITEM_ERROR' ;
                    IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink: xErrorMessage is null ' ,1);
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink: xMessageName is now ' || xMessageName,1);
                    END IF;


                end if ;

             else
                    IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink: xMessageName was already set ' || xMessageName,1);
                    END IF;
             end if;

             return(0);


	when FND_API.G_EXC_UNEXPECTED_ERROR then
                 CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lCount,
                  p_msg_data  => xErrorMessage
                );
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('delink_item: ' || 'ERROR: CTOCITMB.delink:' || to_char(lStmtNumber)|| xErrorMessage,1);
                END IF;
                return(0);


	when OTHERS then
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('delink_item: ' || 'delink::others::'||sqlerrm, 1);
		END IF;
		xMessageName    := 'CTO_DELINK_ITEM_ERROR';
                xErrorMessage := 'ERROR: CTOCITMB.delink:'||to_char(lStmtNumber)||
                                   ':' || substrb(sqlerrm,1,150);
                 CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lCount,
                  p_msg_data  => xErrorMessage
                );
                return(0);

end delink_item;


function load_mandatory_comps(
         pLineId          in     number,
         pReqDate         in     oe_order_lines_all.schedule_ship_date%type,
         xGrpId           out NOCOPY   number,
         xErrorMessage    out NOCOPY   varchar2  ,
         xMessageName     out NOCOPY   varchar2  ,
         xTableName       out NOCOPY   varchar2  )
return integer
is

	level_number          		number := 0;
	v_max_level_number    		number := 0;
	lStmtNumber           		number := 0;
	lGrpId                		number;
	rowcount              		number := 1;
	proc_error            		exception ;

	v_msi_fixed_lead_time       	mtl_system_items.fixed_lead_time%type ;
	v_msi_variable_lead_time    	mtl_system_items.variable_lead_time%type ;

	/*Bugfix 2047428 */
	latpcompflag            	mtl_system_items.atp_components_flag%type;
	/* End Bugfix 2047428 */

	-- Bugfix 2425667
	lrowcount number;
	-- Bugfix 2425667

	-- 3893281 : New debug cursor and variables
        cursor debug_bet is
        select bet.top_bill_sequence_id,
               bet.bill_sequence_id,
               bet.organization_id,
               bet.sort_order,
               bet.plan_level,
               bet.line_id,
               substrb(msi.concatenated_segments,1,50)
        from   bom_explosion_temp bet,mtl_system_items_kfv msi
        where  bet.group_id = xGrpId
        and    bet.organization_id = msi.organization_id
        and    bet.component_item_id = msi.inventory_item_id;

        d_top_bseq_id           number;
        d_bseq_id               number;
        d_org_id                number;
        d_sort_order            varchar2(240);
        d_plan_level            number;
        d_line_id               number;
        d_item                  varchar2(50);

        -- 3893281

begin

    /*---------------------------------------------------+
       Insert the Model row details from oe_order_lines
       with plan_level =0
       The lines have a common group_id, have line_id reference
       of oe_order_lines. Top_bill_sequence_id and bill_sequence_id
       are not needed however, as they are not null coloumns,
       all rows have model's bill_sequence_id in these fields.
    +----------------------------------------------------*/



        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps: ' || ' load mandatory comps ' ,1);
        END IF;

        if( pReqDate is not null ) then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps: ' || 'parameters passed ' || pLineId || ' date ' || to_char( pReqDate ) ,1);
        END IF;
        else
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps: ' || 'parameters passed date null ' || pLineId  ,1);
        END IF;
        end if ;



     /* Bugfix 2047428 */
    lStmtNumber := 599;
    select      NVL(msi.atp_components_flag,'N')
    into        latpcompflag
    from        mtl_system_items msi , oe_order_lines_all oel
    where       oel.inventory_item_id   =       msi.inventory_item_id
    and         oel.ship_from_org_id    =       msi.organization_id
    and         oel.line_id             =       pLineId
    and         oel.ordered_quantity    >       0;

    If  latpcompflag in  ('N' , 'R' ) then  -- bugfix 3779636
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps: ' || 'Exiting Load Mandatory Comps at model level as ATP Component flag is N or R ',1);               -- bugfix 3779636
        END IF;
        return(1);
    else

     	/* End Bugfix 2047428 */
    	select bom_explosion_temp_s.nextval
    	into   xGrpId
    	from dual;

    	-- bugfix 1902818: Added nvl to oel.component_sequence_id.
    	-- For ATO items, this will be null.

    	lStmtNumber := 600;
	-- Bugfix 1998386 This function multiplies the ordered quantity
        	-- with conversion factor and returns converted quantity
        	-- if the order UOM is different from primary UOM of the item.
        	-- If ordered UOM and primary UOM are same , the function
        	-- returns the ordered quantity.


    	insert into bom_explosion_temp(
        	top_bill_sequence_id,
        	bill_sequence_id,
        	organization_id,
        	sort_order,
        	component_sequence_id,
        	component_item_id,
        	plan_level,
        	extended_quantity,
        	primary_uom_code,		-- 1998386
        	top_item_id,
        	line_id,
        	group_id)
   	select
        	nvl(oel.component_sequence_id,1),       -- Top bill sequence id  --1902818
        	nvl(oel.component_sequence_id,1),       -- Bill_sequence_id	 --1902818
        	oel.ship_from_org_id,
        	2,                               -- Sort Order --BUG no 1288823 modification
        	nvl(oel.component_sequence_id,1), 	--1902818
        	oel.inventory_item_id,
        	0,                               -- Plan level
        	-- 1998386
        	CTO_UTILITY_PK.convert_uom(
			oel.order_quantity_uom,
			msi.primary_uom_code,
			oel.ordered_quantity,
			oel.inventory_item_id),
        	msi.primary_uom_code,
        	oel.inventory_item_id,
        	oel.Line_Id,
        	xGrpId
   	from
        	oe_order_lines_all  oel,
        	mtl_system_items msi
        where oel.line_id        = pLineId
        and oel.inventory_item_id = msi.inventory_item_id
        and oel.ship_from_org_id = msi.organization_id
        and   oel.ordered_quantity > 0;

        if sql%rowcount  =  0 then
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add ('load_mandatory_comps: ' || 'Model Row not found',1);
            END IF;
            raise proc_error;
        end if;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_comps: ' || 'Model Rows : ' || sql%rowcount, 2);
        END IF;

        /*------------------------------------------------+
           Insert all oe_order_lines row for this model
           with corrosponding plan_levels
        +------------------------------------------------*/
        rowcount := 1 ;
        while rowcount > 0 LOOP

            level_number := level_number + 1;

            lStmtNumber := 610;
            insert into bom_explosion_temp(
               top_bill_sequence_id,
               bill_sequence_id,
               organization_id,
               sort_order,
               component_sequence_id,
               component_item_id,
               plan_level,
               extended_quantity,
               primary_uom_code,		-- Bugfix 1998386
               top_item_id,
               line_id,
               group_id)
	   -- 3893281 : Commenting Old SELECT
	   /*
           select
               bet.top_bill_sequence_id,
               bet.bill_sequence_id,
               oel.ship_from_org_id, --changed from org_id,
               2,                    -- BUG no 1288823 modification
               oel.component_sequence_id,
               oel.inventory_item_id,
               level_number,

               -- Bugfix 1998386 This function multiplies the ordered quantity
               -- with conversion factor and returns converted quantity
               -- if the order UOM is different from primary UOM of the item .
               -- If ordered UOM and primary UOM are same,the function
               -- returns the ordered quantity.

               CTO_UTILITY_PK.convert_uom(
			oel.order_quantity_uom,
			msi.primary_uom_code,
			oel.ordered_quantity,
			oel.inventory_item_id),
               msi.primary_uom_code,
               bet.top_item_id,
               oel.line_id,
               xGrpId
           from
                 oe_order_lines_all  oel,
                 bom_explosion_temp  bet,
                 mtl_system_items    msi
	   where oel.ato_line_id   = pLineId
	   and oel.line_id <> pLineId
           and oel.inventory_item_id = msi.inventory_item_id
           and oel.ship_from_org_id = msi.organization_id
           and   oel.ordered_quantity  > 0
           and   nvl(oel.cancelled_flag,'N') <> 'Y'
           and   oel.link_to_line_id   = bet.line_id
           and   oel.item_type_code <> 'CONFIG'
           and   bet.group_id          = xGrpId
           and   bet.plan_level        = level_number -1 ;
	   */
	   select
               bet.top_bill_sequence_id,
               bet.bill_sequence_id,
               oel.ship_from_org_id, --changed from org_id,
               2,                    -- BUG no 1288823 modification
               oel.component_sequence_id,
               oel.inventory_item_id,
               level_number,

               -- Bugfix 1998386 This function multiplies the ordered quantity
               -- with conversion factor and returns converted quantity
               -- if the order UOM is different from primary UOM of the item .
               -- If ordered UOM and primary UOM are same,the function
               -- returns the ordered quantity.

               CTO_UTILITY_PK.convert_uom(
                        oel.order_quantity_uom,
                        msi.primary_uom_code,
                        oel.ordered_quantity,
                        oel.inventory_item_id),
               msi.primary_uom_code,
               bet.top_item_id,
               oel.line_id,
               xGrpId
	   from
                 oe_order_lines_all  oel,
                 bom_explosion_temp  bet,
                 mtl_system_items    msi,
                 bom_bill_of_materials bbm,
                 bom_inventory_components bic
           where oel.ato_line_id   = pLineId
           and   oel.line_id <> pLineId
           and   oel.inventory_item_id = msi.inventory_item_id
           and   oel.ship_from_org_id = msi.organization_id
           and   oel.ordered_quantity  > 0
           and   nvl(oel.cancelled_flag,'N') <> 'Y'
           and   oel.link_to_line_id   = bet.line_id
           and   oel.item_type_code <> 'CONFIG'  /* BUG 2483920 */
           and   bet.group_id          = xGrpId
           and   bet.plan_level        = level_number -1
           and   bet.component_item_id = bbm.assembly_item_id
           and   bet.organization_id = bbm.organization_id
           and   bbm.alternate_bom_designator is null
           and   bbm.common_bill_sequence_id = bic.bill_sequence_id
           and   bic.component_item_id = msi.inventory_item_id
           and   bic.optional = 1
           and   ( msi.bom_item_type in (1,2)
                        OR (msi.bom_item_type = 4 and bic.wip_supply_type = 6 )
                        OR (msi.bom_item_type = 4 and msi.replenish_to_order_flag = 'Y' ));
           -- 3893281
           rowcount := SQL%ROWCOUNT;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add ('load_mandatory_comps: ' || 'Row Count : '   || rowcount, 2);
           END IF;

        END LOOP;

	-- 3893281 following code is to debug BET at this point
           open debug_bet;
           oe_debug_pub.add ('BET picture after Model and its children are inserted ..' ,1);
           loop
           fetch debug_bet
           into d_top_bseq_id,
                d_bseq_id,
                d_org_id,
                d_sort_order,
                d_plan_level,
                d_line_id,
                d_item;
           exit when debug_bet%NOTFOUND;
           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add (' Top Bill Seq id '||d_top_bseq_id|| ' Bill Seq Id '||d_bseq_id
                                  ||' Org '||d_org_id ||' Sort Order '||d_sort_order
                                  || ' Plan level '||d_plan_level||' Line Id '||d_line_id
                                  || ' Item '||d_item,1);
           END IF;
           end loop;
           close debug_bet;
         -- 3893281

         v_max_level_number := level_number ; /* added by sushant to track max level number */

         IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add ('load_mandatory_comps: ' || 'Group_id  : '|| xGrpId, 2);
         END IF;



       /*
       ** BUG no 1288823, new query block added
       */

       begin

       select msi.fixed_lead_time , nvl(msi.variable_lead_time,0)
          into v_msi_fixed_lead_time, v_msi_variable_lead_time
       from mtl_system_items msi , bom_explosion_temp be
       where  be.organization_id   = msi.organization_id
       and   be.component_item_id = msi.inventory_item_id
       and   be.line_id = pLineId
       and   be.group_id = xGrpId;      -- bugfix 1876997

       exception

       when no_data_found then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        return(0);

       when others then
        xErrorMessage := 'ERROR: CTOCITMB:'||to_char(lStmtNumber)||': other error ';
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_comps: ' || 'ERROR: others exception while executing stmt ' ||to_char(lStmtNumber),1);

        	oe_debug_pub.add('load_mandatory_comps: ' || 'ERROR message : '||sqlerrm,1);
        END IF;
        return(0);

       end ;


        /*------------------------------------------------------------+
           Start Explosion of all items copied above.
        +-----------------------------------------------------------*/

        level_number := 0;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_comps: ' || 'Explosion loop' , 2);
        END IF;

        << Explode_loop >>
        LOOP

        lStmtNumber := 620;
	-- Bug 1985793 Selecting greater of sysdate and calendar date
            -- while checking for item effectivity so that planning will get
            -- components effective till sysdate.
	--apps performance bugfix 4905845, sql id 16103327
        insert into bom_explosion_temp(
           top_bill_sequence_id,
           bill_sequence_id,
           organization_id,
           sort_order,
           component_sequence_id,
           component_item_id,
           plan_level,
           extended_quantity,
           primary_uom_code,		-- 1998386
           top_item_id,
           component_quantity,
           check_atp,
           atp_components_flag,
           atp_flag,
           bom_item_type,
           assembly_item_id,
           parent_bom_item_type,
           line_id,
           wip_supply_type,	-- 3254039
           group_id)
      select
           -1 , --  2897132
           bic.bill_sequence_id,
           be.organization_id,
           evaluate_order( msi2.atp_flag, msi2.atp_components_flag , msi2.bom_item_type ) ,  /* BUG # 1518894, 1288823 */
                                 -- 1288823
           bic.component_sequence_id,
           bic.component_item_id,
           level_number + 1,
           be.extended_quantity * bic.component_quantity,
           msi2.primary_uom_code,		-- 1998386
           be.top_item_id,
           bic.component_quantity,
           bic.check_atp,
                  -- 2378556
           msi2.atp_components_flag,
           msi2.atp_flag,
           msi2.bom_item_type,

           bom.assembly_item_id,
           msi.bom_item_type,
           be.line_id ,  -- 2897132
           nvl(bic.wip_supply_type, msi2.wip_supply_type),		-- 3254039 , 3298244
	   xGrpId
       from
           bom_calendar_dates       cal,
           mtl_system_items         msi,         /* PARENT */
           mtl_system_items         msi2,        /* CHILD */
           bom_inventory_components bic,
           eng_revised_items        eri,
           bom_bill_of_materials    bom,
           mtl_parameters           mp,
           bom_explosion_temp       be
       where be.sort_order <> 3  -- 1288823
       and   be.group_id = xGrpId
       and   nvl(be.plan_level,0) = level_number
       and   be.organization_id   = bom.organization_id
       and   be.component_item_id = bom.assembly_item_id
       and   bic.component_quantity <> 0
       and   bic.revised_item_sequence_id = eri.revised_item_sequence_id (+)
       and   bic.component_item_id = msi2.inventory_item_id  -- 1518894
       and   bom.organization_id = msi2.organization_id     -- 1518894
       and   bom.alternate_bom_designator is null
       and   bic.bill_sequence_id = bom.common_bill_sequence_id
       and   be.organization_id   = msi.organization_id
       and   be.component_item_id = msi.inventory_item_id --BUG#2378556
       and   mp.organization_id   = be.organization_id
       and   cal.calendar_code    = mp.calendar_code
       and   cal.exception_set_id = mp.calendar_exception_set_id
       and   cal.calendar_date =
                 ( select c.calendar_date
                   from   bom_calendar_dates C
                   where  C.calendar_code = mp.calendar_code
                   and    c.exception_set_id = mp.calendar_exception_set_id
                   and    C.seq_num =
                      (select c2.prior_seq_num -
                        ceil( nvl( v_msi_fixed_lead_time,0)+
                                 (be.extended_quantity  *
                         v_msi_variable_lead_time ))
                       from bom_calendar_dates c2
                       where c2.calendar_code = mp.calendar_code
                       and   c2.exception_set_id = mp.calendar_exception_set_id
                       and   c2.calendar_date = trunc(pReqDate)
                       )
                  )

            --  2162912
            and	  TRUNC(bic.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)

            and   bic.effectivity_date =
                   (select
                         max(effectivity_date)
                    from bom_inventory_components bic1,
                         eng_revised_items eri
                    where bic1.bill_sequence_id = bic.bill_sequence_id
                    and   bic1.component_item_id = bic.component_item_id
                    and   bic1.revised_item_sequence_id =
                          eri.revised_item_sequence_id (+)
                    and   (decode(bic1.implementation_date, NULL,
                            bic1.old_component_sequence_id,
                            bic1.component_sequence_id) =
                            decode(bic.implementation_date, NULL,
                                   bic.old_component_sequence_id,
                                   bic.component_sequence_id)
                           OR
                           bic1.operation_seq_num = bic.operation_seq_num)

            --  2162912
            and   TRUNC(bic1.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic1.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)
            --  2162912
            and   ( nvl(eri.status_type,6) IN (4,6,7))
            and not exists
                     (select
                          'X'
                      from bom_inventory_components bicn, eng_revised_items eri1
                      where bicn.bill_sequence_id + 0 = bic.bill_sequence_id
                      and   bicn.old_component_sequence_id =
                            bic.component_sequence_id
                      and   bicn.acd_type in (2,3)
                      and   eri1.revised_item_sequence_id = bicn.revised_item_sequence_id
                      and    trunc(bicn.disable_date) <= cal.calendar_date
                      and   ( nvl(eri1.status_type,6) in (4,6,7))
             )
                   )
            and   bic.optional = 2        /* NOT OPTIONAL */
            and   msi2.bom_item_type = 4 /* 2400948 */
                 --  Model or Option Class or ATO ITEM * * BUG#2378556 commented for bug 3314297 mandatory comps should be
                 --  exploded for standard items

            and   msi.pick_components_flag <> 'Y' ;

            -- start bugfix 2425667
            lrowcount := SQL%ROWCOUNT;
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add ('load_mandatory_comps: ' || 'Row Count : '   || lrowcount, 2);
            END IF;
            -- oe_debug_pub.add('Row Count : '   || SQL%ROWCOUNT);
            -- end bugfix 2425667


            /* continue exploding atleast till max level number */
            -- start bugfix 2425667
            -- IF 		SQL%ROWCOUNT = 0
            IF  lrowcount = 0
            -- end bugfix 2425667
            	AND 	level_number >= v_max_level_number THEN
               EXIT Explode_loop;
            END IF;

            level_number := level_number + 1;

        END LOOP;
    END IF; -- bugfix 2047428


    return(1);


exception

    when no_data_found then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        return(0);
    when proc_error then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': Model row not found ';
        return(0);
    when others then	--bugfix 1902818: added others excpn
        xErrorMessage := 'load_mandatory_comps:(others excepn)::'||to_char(lStmtNumber)||'::'||substrb(sqlerrm,1,150);
        return(0);

end load_mandatory_comps;


-- 3779636
function load_mandatory_comps_pds(
         pLineId          in     number,
         pReqDate         in     oe_order_lines_all.schedule_ship_date%type,
         xGrpId           out NOCOPY   number,
         xErrorMessage    out NOCOPY   varchar2  ,
         xMessageName     out NOCOPY   varchar2  ,
         xTableName       out NOCOPY   varchar2  )
return integer
is

	level_number          		number := 0;
	v_max_level_number    		number := 0;
	lStmtNumber           		number := 0;
	lGrpId                		number;
	rowcount              		number := 1;
	proc_error            		exception ;

	v_msi_fixed_lead_time       	mtl_system_items.fixed_lead_time%type ;
	v_msi_variable_lead_time    	mtl_system_items.variable_lead_time%type ;
	latpcompflag            	mtl_system_items.atp_components_flag%type;
	lrowcount 			number;
begin

    /*---------------------------------------------------+
       Insert the Model row details from oe_order_lines
       with plan_level =0
       The lines have a common group_id, have line_id reference
       of oe_order_lines. Top_bill_sequence_id and bill_sequence_id
       are not needed however, as they are not null coloumns,
       all rows have model's bill_sequence_id in these fields.
    +----------------------------------------------------*/



        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps_pds: ' || ' load mandatory comps PDS ' ,1);
        END IF;

        if( pReqDate is not null ) then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'parameters passed ' || pLineId || ' date ' || to_char( pReqDate ) ,1);
        END IF;
        else
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'parameters passed date null ' || pLineId  ,1);
        END IF;
        end if ;

    lStmtNumber := 599;
    select      NVL(msi.atp_components_flag,'N')
    into        latpcompflag
    from        mtl_system_items msi , oe_order_lines_all oel
    where       oel.inventory_item_id   =       msi.inventory_item_id
    and         oel.ship_from_org_id    =       msi.organization_id
    and         oel.line_id             =       pLineId
    and         oel.ordered_quantity    >       0;

    If latpcompflag in ( 'N' , 'R' ) then	-- 3779636
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'Exiting Load Mandatory Comps PDS at model level as ATP Component flag is N or R',1);  -- 3779636
        END IF;
        return(1);
    else

    	select bom_explosion_temp_s.nextval
    	into   xGrpId
    	from dual;


    	lStmtNumber := 600;
    	insert into bom_explosion_temp(
        	top_bill_sequence_id,
        	bill_sequence_id,
        	organization_id,
        	sort_order,
        	component_sequence_id,
        	component_item_id,
        	plan_level,
        	extended_quantity,
        	primary_uom_code,
        	top_item_id,
        	line_id,
        	group_id)
   	select
        	nvl(oel.component_sequence_id,1),
        	nvl(oel.component_sequence_id,1),
        	oel.ship_from_org_id,
        	2,
        	nvl(oel.component_sequence_id,1),
        	oel.inventory_item_id,
        	0,
        	CTO_UTILITY_PK.convert_uom(
			oel.order_quantity_uom,
			msi.primary_uom_code,
			oel.ordered_quantity,
			oel.inventory_item_id),
        	msi.primary_uom_code,
        	oel.inventory_item_id,
        	oel.Line_Id,
        	xGrpId
   	from
        	oe_order_lines_all  oel,
        	mtl_system_items msi
        where oel.line_id        = pLineId
        and oel.inventory_item_id = msi.inventory_item_id
        and oel.ship_from_org_id = msi.organization_id
        and   oel.ordered_quantity > 0;

        if sql%rowcount  =  0 then
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'Model Row not found',1);
            END IF;
            raise proc_error;
        end if;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_comps_pds: ' || 'Model Rows : ' || sql%rowcount, 2);
        END IF;

        /*------------------------------------------------+
           Insert all oe_order_lines row for this model
           with corrosponding plan_levels
        +------------------------------------------------*/
        rowcount := 1 ;
        while rowcount > 0 LOOP

            level_number := level_number + 1;

            lStmtNumber := 610;
            insert into bom_explosion_temp(
               top_bill_sequence_id,
               bill_sequence_id,
               organization_id,
               sort_order,
               component_sequence_id,
               component_item_id,
               plan_level,
               extended_quantity,
               primary_uom_code,
               top_item_id,
               line_id,
               group_id)
           select
               bet.top_bill_sequence_id,
               bet.bill_sequence_id,
               oel.ship_from_org_id,
               2,
               oel.component_sequence_id,
               oel.inventory_item_id,
               level_number,
               CTO_UTILITY_PK.convert_uom(
			oel.order_quantity_uom,
			msi.primary_uom_code,
			oel.ordered_quantity,
			oel.inventory_item_id),
               msi.primary_uom_code,
               bet.top_item_id,
               oel.line_id,
               xGrpId
           from
                 oe_order_lines_all  oel,
                 bom_explosion_temp  bet,
                 mtl_system_items    msi
	   where oel.ato_line_id   = pLineId
	   and oel.line_id <> pLineId
           and oel.inventory_item_id = msi.inventory_item_id
           and oel.ship_from_org_id = msi.organization_id
	   and msi.bom_item_type in ( 1, 2 )   -- only sub-models and option classes
           and   oel.ordered_quantity  > 0
           and   nvl(oel.cancelled_flag,'N') <> 'Y'
           and   oel.link_to_line_id   = bet.line_id
           and   oel.item_type_code <> 'CONFIG'
           and   bet.group_id          = xGrpId
           and   bet.plan_level        = level_number -1 ;

           rowcount := SQL%ROWCOUNT;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'Row Count : '   || rowcount, 2);
           END IF;

        END LOOP;

            v_max_level_number := level_number ;

           IF PG_DEBUG <> 0 THEN
           	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'Group_id  : '|| xGrpId, 2);
           END IF;


       begin

       select msi.fixed_lead_time , nvl(msi.variable_lead_time,0)
          into v_msi_fixed_lead_time, v_msi_variable_lead_time
       from mtl_system_items msi , bom_explosion_temp be
       where  be.organization_id   = msi.organization_id
       and   be.component_item_id = msi.inventory_item_id
       and   be.line_id = pLineId
       and   be.group_id = xGrpId;

       exception

       when no_data_found then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        return(0);

       when others then
        xErrorMessage := 'ERROR: CTOCITMB:'||to_char(lStmtNumber)||': other error ';
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_comps_pds: ' || 'ERROR: others exception while executing stmt ' ||to_char(lStmtNumber),1);

        	oe_debug_pub.add('load_mandatory_comps_pds: ' || 'ERROR message : '||sqlerrm,1);
        END IF;
        return(0);

       end ;


        /*------------------------------------------------------------+
           Start Explosion of all items copied above.
        +-----------------------------------------------------------*/

        level_number := 0;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_comps_pds: ' || 'Explosion loop' , 2);
        END IF;

        << Explode_loop >>
        LOOP

        lStmtNumber := 620;
	--apps perf bug#4905845,sql id 16103462
	--reduce comments to decrease shared memory
        insert into bom_explosion_temp(
           top_bill_sequence_id,
           bill_sequence_id,
           organization_id,
           sort_order,
           component_sequence_id,
           component_item_id,
           plan_level,
           extended_quantity,
           primary_uom_code,
           top_item_id,
           component_quantity,
           check_atp,
           atp_components_flag,
           atp_flag,
           bom_item_type,
           assembly_item_id,
           parent_bom_item_type,
           line_id,
           wip_supply_type,
           group_id)
      select
           -1 ,
           bic.bill_sequence_id,
           be.organization_id,
           evaluate_order( msi2.atp_flag, msi2.atp_components_flag , msi2.bom_item_type ) ,
           bic.component_sequence_id,
           bic.component_item_id,
           level_number + 1,
           be.extended_quantity * bic.component_quantity,
           msi2.primary_uom_code,
           be.top_item_id,
           bic.component_quantity,
           bic.check_atp,
           msi2.atp_components_flag,
           msi2.atp_flag,
           msi2.bom_item_type,
           bom.assembly_item_id,
           msi.bom_item_type,
           be.line_id ,
           nvl(bic.wip_supply_type, msi2.wip_supply_type),
           xGrpId
       from
           bom_calendar_dates       cal,
           mtl_system_items         msi,
           mtl_system_items         msi2,
           bom_inventory_components bic,
           eng_revised_items        eri,
           bom_bill_of_materials    bom,
           mtl_parameters           mp,
           bom_explosion_temp       be
       where be.sort_order <> 3
       and   be.group_id = xGrpId
       and   nvl(be.plan_level,0) = level_number
       and   be.organization_id   = bom.organization_id
       and   be.component_item_id = bom.assembly_item_id
       and   bic.component_quantity <> 0
       and   bic.revised_item_sequence_id = eri.revised_item_sequence_id (+)
       and   bic.component_item_id = msi2.inventory_item_id
       and   bom.organization_id = msi2.organization_id
       and   bom.alternate_bom_designator is null
       and   bic.bill_sequence_id = bom.common_bill_sequence_id
       and   be.organization_id   = msi.organization_id
       and   be.component_item_id = msi.inventory_item_id
       and   mp.organization_id   = be.organization_id
       and   cal.calendar_code    = mp.calendar_code
       and   cal.exception_set_id = mp.calendar_exception_set_id
       and   cal.calendar_date =
                 ( select c.calendar_date
                   from   bom_calendar_dates C
                   where  C.calendar_code = mp.calendar_code
                   and    c.exception_set_id = mp.calendar_exception_set_id
                   and    C.seq_num =
                      (select c2.prior_seq_num -
                        ceil( nvl( v_msi_fixed_lead_time,0)+
                                 (be.extended_quantity  *
                         v_msi_variable_lead_time ))
                       from bom_calendar_dates c2
                       where c2.calendar_code = mp.calendar_code
                       and   c2.exception_set_id = mp.calendar_exception_set_id
                       and   c2.calendar_date = trunc(pReqDate)
                       )
                  )
            and	  TRUNC(bic.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)
            and   bic.effectivity_date =
                   (select
                         max(effectivity_date)
                    from bom_inventory_components bic1,
                         eng_revised_items eri
                    where bic1.bill_sequence_id = bic.bill_sequence_id
                    and   bic1.component_item_id = bic.component_item_id
                    and   bic1.revised_item_sequence_id =
                          eri.revised_item_sequence_id (+)
                    and   (decode(bic1.implementation_date, NULL,
                            bic1.old_component_sequence_id,
                            bic1.component_sequence_id) =
                            decode(bic.implementation_date, NULL,
                                   bic.old_component_sequence_id,
                                   bic.component_sequence_id)
                           OR
                           bic1.operation_seq_num = bic.operation_seq_num)
            and   TRUNC(bic1.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic1.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)
            and   ( nvl(eri.status_type,6) IN (4,6,7))
            and not exists
                     (select
                          'X'
                      from bom_inventory_components bicn, eng_revised_items eri1
                      where bicn.bill_sequence_id + 0 = bic.bill_sequence_id
                      and   bicn.old_component_sequence_id =
                            bic.component_sequence_id
                      and   bicn.acd_type in (2,3)
                      and   eri1.revised_item_sequence_id = bicn.revised_item_sequence_id
                      and    trunc(bicn.disable_date) <= cal.calendar_date
                      and   ( nvl(eri1.status_type,6) in (4,6,7))
             )
                   )
            and   bic.optional = 2
            and   msi2.bom_item_type = 4
	    and   msi.bom_item_type in (1,2) /*Model or Option Class */
	    and   msi.pick_components_flag <> 'Y' ;


            lrowcount := SQL%ROWCOUNT;
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add ('load_mandatory_comps_pds: ' || 'Row Count : '   || lrowcount, 2);
            END IF;




            /* continue exploding atleast till max level number */

            IF  lrowcount = 0
            	AND 	level_number >= v_max_level_number THEN
               EXIT Explode_loop;
            END IF;

            level_number := level_number + 1;

        END LOOP;
    END IF;


    return(1);


exception

    when no_data_found then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        return(0);
    when proc_error then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': Model row not found ';
        return(0);
    when others then	--bugfix 1902818: added others excpn
        xErrorMessage := 'load_mandatory_comps_pds:(others excepn)::'||to_char(lStmtNumber)||'::'||substrb(sqlerrm,1,150);
        return(0);

end load_mandatory_comps_pds;

-- 3779636


function evaluate_order( p_atp_flag mtl_system_items.atp_flag%type
                       , p_atp_comp mtl_system_items.atp_components_flag%type
                       , p_item_type mtl_system_items.bom_item_type%type )
return number
is
begin
   if( p_atp_comp in ( 'C' , 'Y' ) AND p_atp_flag in ( 'R' , 'C')) then
      return 1 ; /* do explode and required */

   elsif( p_atp_comp = 'Y' AND p_atp_flag = 'N' and p_item_type = '4') then
      return 2 ; /* do explode and not required */

   else
      return 3 ; /* do not explode and required */

   end if ;

end evaluate_order ;


function load_mandatory_components(
         p_ship_set             in     MRP_ATP_PUB.ATP_Rec_Typ,
         p_model_index          in     number,
	 pReqDate               in     oe_order_lines_all.schedule_ship_date%type,
         xGrpId                 out NOCOPY   number,
         xErrorMessage          out NOCOPY   varchar2  ,
         xMessageName           out NOCOPY   varchar2  ,
         xTableName             out NOCOPY   varchar2  )
return integer
is

	level_number          		number := 0;
	v_max_level_number          	number := 0;
	lStmtNumber           		number := 0;
	lGrpId                		number;
	lGroupid2             		number;
	rowcount              		number := 1;
	proc_error            		exception ;
	i                     		number;

	v_msi_fixed_lead_time       	mtl_system_items.fixed_lead_time%type ;
	v_msi_variable_lead_time    	mtl_system_items.variable_lead_time%type ;

	/*Bugfix 2047428 */
	latpcompflag            	mtl_system_items.atp_components_flag%type;
	/* End Bugfix 2047428 */

	-- 3893281 : New debug cursor and variables
        cursor debug_bet is
        select bet.top_bill_sequence_id,
               bet.bill_sequence_id,
               bet.organization_id,
               bet.sort_order,
               bet.plan_level,
               bet.line_id,
               substrb(msi.concatenated_segments,1,50)
        from   bom_explosion_temp bet,mtl_system_items_kfv msi
        where  bet.group_id = xGrpId
        and    bet.organization_id = msi.organization_id
        and    bet.component_item_id = msi.inventory_item_id;

        d_top_bseq_id           number;
        d_bseq_id               number;
        d_org_id                number;
        d_sort_order            varchar2(240);
        d_plan_level            number;
        d_line_id               number;
        d_item                  varchar2(50);

        -- 3893281

begin




        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components: ' || ' load mandatory components ' ,1);
        END IF;

         if( pReqDate is not null ) then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components: ' || 'parameters passed index ' || p_model_index || ' date ' || to_char( pReqDate ) ,1);
        END IF;
         else
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components: ' || 'parameters passed index date null ' || p_model_index  ,1);
        END IF;
        end if ;



	/* Bugfix 2047428 */
        lStmtNumber := 599;
        select  NVL(msi.atp_components_flag,'N')
        into    latpcompflag
        from    mtl_system_items msi
        where   msi.inventory_item_id  =  p_ship_set.inventory_item_id(p_model_index)
        and     msi.organization_id    =  p_ship_set.source_organization_id(p_model_index);


    	If latpcompflag in ( 'N'  , 'R' ) then  -- bugfix 3779636
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add ('load_mandatory_components: ' || 'Exiting Load Mandatory Components at model level as ATP Component flag is N or R ',1);    -- bugfix 3779636
        	END IF;
        	return(1);

    	else

     		/* End Bugfix 2047428 */
		select bom_explosion_temp_s.nextval
		into  lGroupid2
		from dual;

        	select bom_explosion_temp_s.nextval
        	into   xGrpId
        	from dual;

    		lStmtNumber := 600;


     		i := p_ship_set.inventory_item_id.FIRST;

     		-- use bom_explosion_temp table to store the ship set for later join
     		while i is not null
     		loop
       			insert into bom_explosion_temp(
		 		top_bill_sequence_id,
		 		bill_sequence_id,
		 		organization_id,
		 		component_item_id,
		 		plan_level,
		 		extended_quantity,
		 		primary_uom_code,		-- Bugfix 1998386
		 		sort_order,
		 		group_id)
		 	-- Bugfix 1998386 Change this to select statement to select
		 	-- primary_uom_code from mtl_system_items.
		 	-- Also CONVERT_UOM function is used to convert
		 	-- p_ship_set.quantity_ordered(i) if the ordered UOM
		 	-- is different from primary UOM.
		 	/*values (
		 		1,
		 		1,
		 		p_ship_set.source_organization_id(i),
		 		p_ship_set.inventory_item_id(i),
		 		1,
		 		p_ship_set.quantity_ordered(i),
		 		2,                -- BUG no 1288823 modification
		 		lGroupid2);*/
		 	select
		 		1,
		 		1,
		 		p_ship_set.source_organization_id(i),
		 		p_ship_set.inventory_item_id(i),
		 		1,
		 		CTO_UTILITY_PK.convert_uom(
						p_ship_set.quantity_uom(i),
						msi.primary_uom_code,
						p_ship_set.quantity_ordered(i),
						p_ship_set.inventory_item_id(i)),
         	 		msi.primary_uom_code,
		 		2,                -- BUG no 1288823 modification
		 		lGroupid2
		 	from mtl_system_items msi
		 	where msi.inventory_item_id = p_ship_set.inventory_item_id(i)
		 	and   msi.organization_id = p_ship_set.source_organization_id(i);

	 		i := p_ship_set.inventory_item_id.NEXT(i);

	 	end loop;



    		-- insert the top model into bom_explosion_temp
    		insert into bom_explosion_temp(
        		top_bill_sequence_id,
        		bill_sequence_id,
        		organization_id,
        		sort_order,
        		component_item_id,
        		plan_level,
        		extended_quantity,
        		primary_uom_code,		-- Bugfix 1998386
        		top_item_id,
        		line_id,
        		group_id)

        	-- Bugfix 1998386 Change this to select statement to
        	-- select primary_uom_code from mtl_system_items.
        	-- Also CONVERT_UOM function is used to convert
        	-- p_ship_set.quantity_ordered(i) if the ordered UOM is
        	-- different from primary UOM.

                	select
		 		1,
		 		1,
		 		p_ship_set.source_organization_id(p_model_index),
		 		2,                -- BUG no 1288823 modification
		 		p_ship_set.inventory_item_id(p_model_index),
		 		0,
		 		CTO_UTILITY_PK.convert_uom(
						p_ship_set.quantity_uom(p_model_index),
						msi.primary_uom_code,
						p_ship_set.quantity_ordered(p_model_index),
						p_ship_set.inventory_item_id(p_model_index)),
         	 		msi.primary_uom_code,
         	 		p_ship_set.inventory_item_id(p_model_index),
		 		1,
		 		xGrpId
		 	from mtl_system_items msi
		 	where msi.inventory_item_id = p_ship_set.inventory_item_id(p_model_index)
		 	and   msi.organization_id = p_ship_set.source_organization_id(p_model_index);


        /*------------------------------------------------+
           Insert all selections for the top model
           with corrosponding plan_levels
        +------------------------------------------------*/
        	rowcount := 1 ;

        	while rowcount > 0
		LOOP

            	level_number := level_number + 1;

            	lStmtNumber := 610;
            	insert into bom_explosion_temp(
               		top_bill_sequence_id,
               		bill_sequence_id,
               		organization_id,
               		sort_order,
               		component_item_id,
               		plan_level,
               		extended_quantity,
               		primary_uom_code,		-- Bugfix 1998386
               		top_item_id,
               		line_id,
               		group_id)
           	select
               		1,
               		1,
               		bet.organization_id,
	       		2,                -- BUG no 1288823 modification
               		bic.component_item_id,
               		level_number,
               		/* bet2.extended_quantity,*/

               		-- Bugfix 1998386 This function multiplies the ordered quantity
               		-- with conversion factor and returns the converted
               		-- quantity if the order UOM is different from primary UOM of the item.
               		-- If ordered UOM and primary UOM are same
               		-- the function returns the ordered quantity.

               		CTO_UTILITY_PK.convert_uom(
					bet2.primary_uom_code,
					msi.primary_uom_code,
					bet2.extended_quantity,
					bic.component_item_id),
               		msi.primary_uom_code,
               		bet.top_item_id,
               		1,
               		xGrpId
           	from
			bom_bill_of_materials    bom,
			bom_inventory_components bic,
			mtl_system_items msi,					-- bugfix 1998386
			bom_explosion_temp  bet,
                 	bom_explosion_temp  bet2        /* ship set */
           	where bet.group_id          = xGrpId
           	and   bet.plan_level        = level_number -1
           	and   bic.component_item_id = msi.inventory_item_id 		-- bugfix 1998386
	   	and   bet.component_item_id = bom.assembly_item_id
	   	and   bet.organization_id   = bom.organization_id
	   	and   bet.organization_id   = msi.organization_id 		-- bugfix 1998386
	   	and   bom.alternate_bom_designator is null
	   	and   bom.common_bill_sequence_id = bic.bill_sequence_id
	   	and   bic.component_item_id = bet2.component_item_id
	   	and   bet2.group_id         = lGroupid2
		-- bugfix 3893281 : Add following filter conditions to get
                -- sub models , option classes , ato items and phantom option items
                and   bic.optional = 1
                and   ( msi.bom_item_type in (1,2)
                        OR (msi.bom_item_type = 4 and bic.wip_supply_type = 6 )
                        OR (msi.bom_item_type = 4 and msi.replenish_to_order_flag = 'Y' ));
                -- end bugfix 3893281

           	rowcount := SQL%ROWCOUNT;

           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add ('load_mandatory_components: ' || 'Row Count : '   || rowcount, 2);
           	END IF;

        	END LOOP;

		-- 3893281 following code is to debug BET at this point
                open debug_bet;
                oe_debug_pub.add ('BET picture after Model and its children are inserted ..' ,1);
                loop
                fetch debug_bet
                into d_top_bseq_id,
                     d_bseq_id,
                     d_org_id,
                     d_sort_order,
                     d_plan_level,
                     d_line_id,
                     d_item;
                exit when debug_bet%NOTFOUND;
                IF PG_DEBUG <> 0 THEN
                     oe_debug_pub.add (' Top Bill Seq id '||d_top_bseq_id|| ' Bill Seq Id '||d_bseq_id
                                  ||' Org '||d_org_id ||' Sort Order '||d_sort_order
                                  || ' Plan level '||d_plan_level||' Line Id '||d_line_id
                                  || ' Item '||d_item,1);
                END IF;
                end loop;
                close debug_bet;
                -- 3893281



        v_max_level_number := level_number ; /* change made by sushant to track max level number */

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components: ' || 'Group_id  : '|| xGrpId, 2);
        END IF;

        delete from bom_explosion_temp
		where group_id = lGroupid2;

       /*
       ** BUG no 1288823, new query block added
       */

       begin
          select msi.fixed_lead_time , nvl(msi.variable_lead_time,0)
          into   v_msi_fixed_lead_time, v_msi_variable_lead_time
          from   mtl_system_items msi , bom_explosion_temp be
          where  be.organization_id   = msi.organization_id
          and    be.component_item_id = msi.inventory_item_id
          and    be.component_item_id = p_ship_set.inventory_item_id(p_model_index);

       exception

          when no_data_found then
        	xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        	return(0);
          when others then
        	xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': other error ';
        	return(0);
       end ;

        /*------------------------------------------------------------+
           Start Explosion of all items copied above.
        +-----------------------------------------------------------*/

        level_number := 0;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_components: ' || 'Explosion loop' , 2);
        END IF;

        << Explode_loop >>
        LOOP

        lStmtNumber := 620;
	-- Bug 1985793 Selecting greater of sysdate and calendar date
            -- while checking for item effectivity so that planning will get
            -- components effective till sysdate.
	--apps performance bug#4905845, sql id 16103671
        insert into bom_explosion_temp(
           top_bill_sequence_id,
           bill_sequence_id,
           organization_id,
           sort_order,
           component_sequence_id,
           component_item_id,
           plan_level,
           extended_quantity,
           primary_uom_code,		--  1998386
           top_item_id,
           component_quantity,
           check_atp,
           atp_components_flag,
           atp_flag,
           bom_item_type,
           assembly_item_id,
           parent_bom_item_type,
           line_id,
           group_id)
      select
           be.top_bill_sequence_id,
           bic.bill_sequence_id,
           be.organization_id,
           evaluate_order( msi2.atp_flag, msi2.atp_components_flag , msi2.bom_item_type ) ,  /* BUG# 1518894 , 1288823  */
           bic.component_sequence_id,
           bic.component_item_id,
           level_number + 1,
           be.extended_quantity * bic.component_quantity,
           msi2.primary_uom_code,
           be.top_item_id,
           bic.component_quantity,
           bic.check_atp,
	        --2378556
           msi2.atp_components_flag,
           msi2.atp_flag,
           msi2.bom_item_type,

           bom.assembly_item_id,
           msi.bom_item_type,
           NULL,
           xGrpId
       from
           bom_calendar_dates       cal,
           mtl_system_items         msi,         /* PARENT */
           mtl_system_items         msi2,         /* CHILD [BUG#1518894] */
           bom_inventory_components bic,
           eng_revised_items        eri,
           bom_bill_of_materials    bom,
           mtl_parameters           mp,
           bom_explosion_temp       be
       where be.sort_order <> 3
       and   be.group_id = xGrpId
       and   nvl(be.plan_level,0) = level_number
       and   be.organization_id   = bom.organization_id
       and   be.component_item_id = bom.assembly_item_id
       and   bic.component_quantity <> 0
       and   bic.revised_item_sequence_id = eri.revised_item_sequence_id (+)
       and   bic.component_item_id = msi2.inventory_item_id  -- 1518894
       and   bom.organization_id = msi2.organization_id      --1518894
       and   be.organization_id   = msi.organization_id
       and   be.component_item_id = msi.inventory_item_id
       and   bom.alternate_bom_designator is null
       and   bic.bill_sequence_id = bom.common_bill_sequence_id
       and   mp.organization_id   = be.organization_id
       and   cal.calendar_code    = mp.calendar_code
       and   cal.exception_set_id = mp.calendar_exception_set_id
       and   cal.calendar_date =
                 ( select c.calendar_date
                   from   bom_calendar_dates C
                   where  C.calendar_code = mp.calendar_code
                   and    c.exception_set_id = mp.calendar_exception_set_id
                   and    C.seq_num =
                      (select c2.prior_seq_num -
                        ceil(nvl(v_msi_fixed_lead_time,0)+
                                 (be.extended_quantity  *
                         nvl(v_msi_variable_lead_time,0)))
                       from bom_calendar_dates c2
                       where c2.calendar_code = mp.calendar_code
                       and   c2.exception_set_id = mp.calendar_exception_set_id
                       and   c2.calendar_date = trunc(pReqDate)
                       )
                  )
              --  2162912
            and	  TRUNC(bic.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)

            and   bic.effectivity_date =
                   (select
                         max(effectivity_date)
                    from bom_inventory_components bic1,
                         eng_revised_items eri
                    where bic1.bill_sequence_id = bic.bill_sequence_id
                    and   bic1.component_item_id = bic.component_item_id
                    and   bic1.revised_item_sequence_id =
                          eri.revised_item_sequence_id (+)
                    and   (decode(bic1.implementation_date, NULL,
                            bic1.old_component_sequence_id,
                            bic1.component_sequence_id) =
                            decode(bic.implementation_date, NULL,
                                   bic.old_component_sequence_id,
                                   bic.component_sequence_id)
                           OR
                           bic1.operation_seq_num = bic.operation_seq_num)
                 --  2162912
            and   TRUNC(bic1.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic1.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)

            and   ( nvl(eri.status_type,6) IN (4,6,7))
            and not exists
                     (select
                          'X'
                      from bom_inventory_components bicn, eng_revised_items eri1
                      where bicn.bill_sequence_id + 0 = bic.bill_sequence_id
                      and   bicn.old_component_sequence_id =
                            bic.component_sequence_id
                      and   bicn.acd_type in (2,3)
                      and   eri1.revised_item_sequence_id =
                              bicn.revised_item_sequence_id
                      and    trunc(bicn.disable_date) <= cal.calendar_date
                      and   ( nvl(eri1.status_type,6) in (4,6,7))
             )
                   )
            and   bic.optional = 2        /* NOT OPTIONAL */
            and   msi2.bom_item_type = 4 /* BUGFIX 2400948 */
                 --  Model or Option Class or ATO ITEM * * BUG#2378556  bug 3314297 mandatory comps should be exploded for
                 --   standard items
            and   msi.pick_components_flag <> 'Y' ;

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('load_mandatory_components: ' || 'Row Count : '   || SQL%ROWCOUNT);
            END IF;

            /* continue exploding atleast till max level number */
            IF SQL%ROWCOUNT = 0 AND level_number >= v_max_level_number THEN
               EXIT Explode_loop;
            END IF;

            level_number := level_number + 1;
        END LOOP;
     END IF;     -- Bugfix 2047428

     return(1);

exception

    when no_data_found then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        return(0);
    when proc_error then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': Model row not found ';
        return(0);
    when others then	--bugfix 1902818: added others excpn
        xErrorMessage := 'load_mandatory_components:(others excepn)::'||to_char(lStmtNumber)||'::'||substrb(sqlerrm,1,150);
        return(0);

end load_mandatory_components;




-- 3779636
function load_mandatory_components_pds(
         p_ship_set             in     MRP_ATP_PUB.ATP_Rec_Typ,
         p_model_index          in     number,
	 pReqDate               in     oe_order_lines_all.schedule_ship_date%type,
         xGrpId                 out NOCOPY   number,
         xErrorMessage          out NOCOPY   varchar2  ,
         xMessageName           out NOCOPY   varchar2  ,
         xTableName             out NOCOPY   varchar2  )
return integer
is

	level_number          		number := 0;
	v_max_level_number          	number := 0;
	lStmtNumber           		number := 0;
	lGrpId                		number;
	lGroupid2             		number;
	rowcount              		number := 1;
	proc_error            		exception ;
	i                     		number;

	v_msi_fixed_lead_time       	mtl_system_items.fixed_lead_time%type ;
	v_msi_variable_lead_time    	mtl_system_items.variable_lead_time%type ;
	latpcompflag            	mtl_system_items.atp_components_flag%type;


begin




        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components_pds: ' || ' load mandatory components PDS ' ,1);
        END IF;

         if( pReqDate is not null ) then
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components_pds: ' || 'parameters passed index ' || p_model_index || ' date ' || to_char( pReqDate ) ,1);
        END IF;
         else
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components_pds: ' || 'parameters passed index date null ' || p_model_index  ,1);
        END IF;
        end if ;


        lStmtNumber := 599;
        select  NVL(msi.atp_components_flag,'N')
        into    latpcompflag
        from    mtl_system_items msi
        where   msi.inventory_item_id  =  p_ship_set.inventory_item_id(p_model_index)
        and     msi.organization_id    =  p_ship_set.source_organization_id(p_model_index);


    	If latpcompflag in ( 'N' , 'R' )  then	-- 3779636
        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add ('load_mandatory_components_pds: ' || 'Exiting Load Mandatory Components at model level as ATP Component flag is N or R',1);	-- 3779636
        	END IF;
        	return(1);

    	else
		select bom_explosion_temp_s.nextval
		into  lGroupid2
		from dual;

        	select bom_explosion_temp_s.nextval
        	into   xGrpId
        	from dual;

    		lStmtNumber := 600;


     		i := p_ship_set.inventory_item_id.FIRST;

     		-- use bom_explosion_temp table to store the ship set for later join
     		while i is not null
     		loop
       			insert into bom_explosion_temp(
		 		top_bill_sequence_id,
		 		bill_sequence_id,
		 		organization_id,
		 		component_item_id,
		 		plan_level,
		 		extended_quantity,
		 		primary_uom_code,
		 		sort_order,
		 		group_id)
		 	select
		 		1,
		 		1,
		 		p_ship_set.source_organization_id(i),
		 		p_ship_set.inventory_item_id(i),
		 		1,
		 		CTO_UTILITY_PK.convert_uom(
						p_ship_set.quantity_uom(i),
						msi.primary_uom_code,
						p_ship_set.quantity_ordered(i),
						p_ship_set.inventory_item_id(i)),
         	 		msi.primary_uom_code,
		 		2,
		 		lGroupid2
		 	from mtl_system_items msi
		 	where msi.inventory_item_id = p_ship_set.inventory_item_id(i)
		 	and   msi.organization_id = p_ship_set.source_organization_id(i);

	 		i := p_ship_set.inventory_item_id.NEXT(i);

	 	end loop;



    		-- insert the top model into bom_explosion_temp
    		insert into bom_explosion_temp(
        		top_bill_sequence_id,
        		bill_sequence_id,
        		organization_id,
        		sort_order,
        		component_item_id,
        		plan_level,
        		extended_quantity,
        		primary_uom_code,
        		top_item_id,
        		line_id,
        		group_id)
                	select
		 		1,
		 		1,
		 		p_ship_set.source_organization_id(p_model_index),
		 		2,                -- BUG no 1288823 modification
		 		p_ship_set.inventory_item_id(p_model_index),
		 		0,
		 		CTO_UTILITY_PK.convert_uom(
						p_ship_set.quantity_uom(p_model_index),
						msi.primary_uom_code,
						p_ship_set.quantity_ordered(p_model_index),
						p_ship_set.inventory_item_id(p_model_index)),
         	 		msi.primary_uom_code,
         	 		p_ship_set.inventory_item_id(p_model_index),
		 		1,
		 		xGrpId
		 	from mtl_system_items msi
		 	where msi.inventory_item_id = p_ship_set.inventory_item_id(p_model_index)
		 	and   msi.organization_id = p_ship_set.source_organization_id(p_model_index);


        /*------------------------------------------------+
           Insert all selections for the top model
           with corrosponding plan_levels
        +------------------------------------------------*/
        	rowcount := 1 ;

        	while rowcount > 0
		LOOP

            	level_number := level_number + 1;

            	lStmtNumber := 610;
            	insert into bom_explosion_temp(
               		top_bill_sequence_id,
               		bill_sequence_id,
               		organization_id,
               		sort_order,
               		component_item_id,
               		plan_level,
               		extended_quantity,
               		primary_uom_code,
               		top_item_id,
               		line_id,
               		group_id)
           	select
               		1,
               		1,
               		bet.organization_id,
	       		2,
               		bic.component_item_id,
               		level_number,
               		CTO_UTILITY_PK.convert_uom(
					bet2.primary_uom_code,
					msi.primary_uom_code,
					bet2.extended_quantity,
					bic.component_item_id),
               		msi.primary_uom_code,
               		bet.top_item_id,
               		1,
               		xGrpId
           	from
			bom_bill_of_materials    bom,
			bom_inventory_components bic,
			mtl_system_items msi,
			bom_explosion_temp  bet,
                 	bom_explosion_temp  bet2
           	where bet.group_id          = xGrpId
           	and   bet.plan_level        = level_number -1
           	and   bic.component_item_id = msi.inventory_item_id
		and   msi.bom_item_type in ( 1, 2 )     /* Only Sub-models and Option Classes */
	   	and   bet.component_item_id = bom.assembly_item_id
	   	and   bet.organization_id   = bom.organization_id
	   	and   bet.organization_id   = msi.organization_id
	   	and   bom.alternate_bom_designator is null
	   	and   bom.common_bill_sequence_id = bic.bill_sequence_id
	   	and   bic.component_item_id = bet2.component_item_id
	   	and   bet2.group_id         = lGroupid2;

           	rowcount := SQL%ROWCOUNT;

           	IF PG_DEBUG <> 0 THEN
           		oe_debug_pub.add ('load_mandatory_components_pds: ' || 'Row Count : '   || rowcount, 2);
           	END IF;

        	END LOOP;



        v_max_level_number := level_number ;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('load_mandatory_components_pds: ' || 'Group_id  : '|| xGrpId, 2);
        END IF;

        delete from bom_explosion_temp
		where group_id = lGroupid2;

       begin
          select msi.fixed_lead_time , nvl(msi.variable_lead_time,0)
          into   v_msi_fixed_lead_time, v_msi_variable_lead_time
          from   mtl_system_items msi , bom_explosion_temp be
          where  be.organization_id   = msi.organization_id
          and    be.component_item_id = msi.inventory_item_id
          and    be.component_item_id = p_ship_set.inventory_item_id(p_model_index);

       exception

          when no_data_found then
        	xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        	return(0);
          when others then
        	xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': other error ';
        	return(0);
       end ;

        /*------------------------------------------------------------+
           Start Explosion of all items copied above.
        +-----------------------------------------------------------*/

        level_number := 0;
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('load_mandatory_components_pds: ' || 'Explosion loop' , 2);
        END IF;

        << Explode_loop >>
        LOOP

        lStmtNumber := 620;
	--appsperf bug#4905845, sql id 16103821
	--removed comments to reduce shared memory
        insert into bom_explosion_temp(
           top_bill_sequence_id,
           bill_sequence_id,
           organization_id,
           sort_order,
           component_sequence_id,
           component_item_id,
           plan_level,
           extended_quantity,
           primary_uom_code,
           top_item_id,
           component_quantity,
           check_atp,
           atp_components_flag,
           atp_flag,
           bom_item_type,
           assembly_item_id,
           parent_bom_item_type,
           line_id,
           group_id)
      select
           be.top_bill_sequence_id,
           bic.bill_sequence_id,
           be.organization_id,
           evaluate_order( msi2.atp_flag, msi2.atp_components_flag , msi2.bom_item_type ) ,
           bic.component_sequence_id,
           bic.component_item_id,
           level_number + 1,
           be.extended_quantity * bic.component_quantity,
           msi2.primary_uom_code,
           be.top_item_id,
           bic.component_quantity,
           bic.check_atp,
           msi2.atp_components_flag,
           msi2.atp_flag,
           msi2.bom_item_type,
           bom.assembly_item_id,
           msi.bom_item_type,
           NULL,
           xGrpId
       from
           bom_calendar_dates       cal,
           mtl_system_items         msi,
           mtl_system_items         msi2,
           bom_inventory_components bic,
           eng_revised_items        eri,
           bom_bill_of_materials    bom,
           mtl_parameters           mp,
           bom_explosion_temp       be
       where be.sort_order <> 3
       and   be.group_id = xGrpId
       and   nvl(be.plan_level,0) = level_number
       and   be.organization_id   = bom.organization_id
       and   be.component_item_id = bom.assembly_item_id
       and   bic.component_quantity <> 0
       and   bic.revised_item_sequence_id = eri.revised_item_sequence_id (+)
       and   bic.component_item_id = msi2.inventory_item_id
       and   bom.organization_id = msi2.organization_id
       and   be.organization_id   = msi.organization_id
       and   be.component_item_id = msi.inventory_item_id
       and   bom.alternate_bom_designator is null
       and   bic.bill_sequence_id = bom.common_bill_sequence_id
       and   mp.organization_id   = be.organization_id
       and   cal.calendar_code    = mp.calendar_code
       and   cal.exception_set_id = mp.calendar_exception_set_id
       and   cal.calendar_date =
                 ( select c.calendar_date
                   from   bom_calendar_dates C
                   where  C.calendar_code = mp.calendar_code
                   and    c.exception_set_id = mp.calendar_exception_set_id
                   and    C.seq_num =
                      (select c2.prior_seq_num -
                        ceil(nvl(v_msi_fixed_lead_time,0)+
                                 (be.extended_quantity  *
                         nvl(v_msi_variable_lead_time,0)))
                       from bom_calendar_dates c2
                       where c2.calendar_code = mp.calendar_code
                       and   c2.exception_set_id = mp.calendar_exception_set_id
                       and   c2.calendar_date = trunc(pReqDate)
                       )
                  )
            and	  TRUNC(bic.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)
            and   bic.effectivity_date =
                   (select
                         max(effectivity_date)
                    from bom_inventory_components bic1,
                         eng_revised_items eri
                    where bic1.bill_sequence_id = bic.bill_sequence_id
                    and   bic1.component_item_id = bic.component_item_id
                    and   bic1.revised_item_sequence_id =
                          eri.revised_item_sequence_id (+)
                    and   (decode(bic1.implementation_date, NULL,
                            bic1.old_component_sequence_id,
                            bic1.component_sequence_id) =
                            decode(bic.implementation_date, NULL,
                                   bic.old_component_sequence_id,
                                   bic.component_sequence_id)
                           OR
                           bic1.operation_seq_num = bic.operation_seq_num)
            and   TRUNC(bic1.effectivity_date) <= greatest(nvl(cal.calendar_date,sysdate),sysdate)
            and   nvl(TRUNC(bic1.disable_date),(nvl(cal.calendar_date,sysdate) + 1)) > nvl(cal.calendar_date,sysdate)
            and   ( nvl(eri.status_type,6) IN (4,6,7))
            and not exists
                     (select
                          'X'
                      from bom_inventory_components bicn, eng_revised_items eri1
                      where bicn.bill_sequence_id + 0 = bic.bill_sequence_id
                      and   bicn.old_component_sequence_id =
                            bic.component_sequence_id
                      and   bicn.acd_type in (2,3)
                      and   eri1.revised_item_sequence_id =
                              bicn.revised_item_sequence_id
                      and    trunc(bicn.disable_date) <= cal.calendar_date
                      and   ( nvl(eri1.status_type,6) in (4,6,7))
             )
                   )
            and   bic.optional = 2
            and   msi2.bom_item_type = 4
	    and   msi.bom_item_type in (1,2) /*Model or Option Class */
	    and   msi.pick_components_flag <> 'Y' ;

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('load_mandatory_components_pds: ' || 'Row Count : '   || SQL%ROWCOUNT);
            END IF;


            IF SQL%ROWCOUNT = 0 AND level_number >= v_max_level_number THEN
               EXIT Explode_loop;
            END IF;

            level_number := level_number + 1;
        END LOOP;
     END IF;

     return(1);

exception

    when no_data_found then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ';
        return(0);
    when proc_error then
        xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': Model row not found ';
        return(0);
    when others then	--bugfix 1902818: added others excpn
        xErrorMessage := 'load_mandatory_components_pds:(others excepn)::'||to_char(lStmtNumber)||'::'||substrb(sqlerrm,1,150);
        return(0);

end load_mandatory_components_pds;

function  Get_Mandatory_Components(
         p_ship_set            in           MRP_ATP_PUB.ATP_Rec_Typ,
	 p_organization_id     in           number,
	 p_inventory_item_id   in           number,
         x_smc_rec             out  NOCOPY  MRP_ATP_PUB.ATP_Rec_Typ,
         xErrorMessage         out  NOCOPY        varchar2,
         xMessageName          out  NOCOPY        varchar2,
         xTableName            out  NOCOPY        varchar2  )
return integer
is

    lStatus     varchar2(1);
    lGrpId      number;
    lLineId     number;
    lAtpLt      number;
    lFixedLt    number;
    lVarLt      number;
    i           number;
    chk         number;
    lStmtNumber number;
	lItem_id    number;
	lOrg_id     number;
	lItem_type  number;
	lModelIndex number;

    proc_error  exception;

	-- query mandatory comps by group id and null line id
    cursor mandatory_comps is
    select component_item_id cid,
           component_sequence_id cseq,
           component_quantity cq,
           extended_quantity  eq,
           primary_uom_code   uom,		-- Bugfix 1998386
           plan_level         pl,
           line_id,                              -- Bugfix 2897132
           wip_supply_type                       -- Bugfix 3254039
    from   bom_explosion_temp be
    where  be.group_id = lGrpId
    and    ( be.line_id  is null or top_bill_sequence_id = -1 ) -- Bugfix 2897132
    and    be.sort_order <> 2 ;
    --BUG 1288823 modification to send restricted components to atp

v_request_date  DATE ;


l_inv_ctp      varchar2(1);   -- bugfix 3779636


begin

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('Get_Mandatory_Components: ' || ' Entered Get Mandatory Components ',1);
   END IF;


   -- Bugfix 3779636

     lStmtNumber := 699;

     l_inv_ctp := fnd_profile.value('INV_CTP');

     IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add('Get_Mandatory_Components: INV_CTP ( 4 = PDS ): ' || l_inv_ctp,1);
     END IF;



     lStmtNumber := 700;



        lModelIndex := 1;

     if ( p_organization_id is null and p_inventory_item_id is null) then
        -- the calling application is OM


         if( p_ship_set.requested_ship_date.exists(lModelIndex)) then

              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('Get_Mandatory_Components: ' || ' requested ship date exists ',1);
              END IF;


              if( p_ship_set.requested_ship_date(lModelIndex) is not null ) then
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('Get_Mandatory_Components: ' || ' requested ship date exists ' || p_ship_set.requested_ship_date(lModelIndex) ,1);
                    END IF;

              else

                     IF PG_DEBUG <> 0 THEN
                     	oe_debug_pub.add('Get_Mandatory_Components: ' || ' requested ship date is null '  ,1);
                     END IF;
              end if ;

         end if ;



         if( p_ship_set.requested_arrival_date.exists(lModelIndex)) then

              IF PG_DEBUG <> 0 THEN
              	oe_debug_pub.add('Get_Mandatory_Components: ' || ' requested arrival date exists ',1);
              END IF;


              if( p_ship_set.requested_arrival_date(lModelIndex) is not null ) then
                    IF PG_DEBUG <> 0 THEN
                    	oe_debug_pub.add('Get_Mandatory_Components: ' || ' requested arrival date exists ' || p_ship_set.requested_arrival_date(lModelIndex) ,1);
                    END IF;

              else

                     IF PG_DEBUG <> 0 THEN
                     	oe_debug_pub.add('Get_Mandatory_Components: ' || ' requested arrival date is null '  ,1);
                     END IF;
              end if ;

         end if ;


         v_request_date := nvl( p_ship_set.requested_ship_date(lModelIndex),
                        p_ship_set.requested_arrival_date(lModelIndex)) ;


         -- Bugfix 2897132
         if( p_ship_set.quantity_ordered(lModelIndex) <> 0 ) then

         -- Bugfix 3779636
            if l_inv_ctp = 4 then

                lStatus := load_mandatory_comps_pds(p_ship_set.identifier(lModelIndex),
                        v_request_date,
                        lGrpId,
                        xErrorMessage,
                        xMessageName,
                        xTableName);
                if lStatus <> 1 then
                   IF PG_DEBUG <> 0 THEN
                        oe_debug_pub.add('Get_Mandatory_Components: ' ||
                              ' Load_mandatory_comps_pds returned with Error ',1);
                   END IF;
                   raise proc_error;
                end if;

             else




	         lStatus := load_mandatory_comps(p_ship_set.identifier(lModelIndex),
			v_request_date,
			lGrpId,
			xErrorMessage,
			xMessageName,
			xTableName);

      	         if lStatus <> 1 then
       		    IF PG_DEBUG <> 0 THEN
       			oe_debug_pub.add('Get_Mandatory_Components: ' || ' Load_mandatory_comps returned with Error ',1);
       		    END IF;

		    raise proc_error;
	         end if;


             end if ;  -- INV_CTP chk

             -- bugfix 3779636



         else


                oe_debug_pub.add(' Load_mandatory_comps returned without processing
                                   as model qty is 0  ',1);
                return 1 ;

         end if;



     else
        -- the calling application is Configurator
        i := p_ship_set.inventory_item_id.FIRST;

	while i is not null
	     	loop
           	-- find the top model record
           	if p_ship_set.source_organization_id(i) = p_organization_id and
			p_ship_set.inventory_item_id(i) = p_inventory_item_id then
			lModelIndex := i;
		      	exit;
		end if;
		i := p_ship_set.inventory_item_id.NEXT(i);
         	end loop;




                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Get_Mandatory_Components: ' || ' will be calling load_mandatory_components ' , 2);
                END IF;

     v_request_date := nvl( p_ship_set.requested_ship_date(lModelIndex),
                        p_ship_set.requested_arrival_date(lModelIndex)) ;


         -- Bugfix 2897132
         if( p_ship_set.quantity_ordered(lModelIndex) <> 0 ) then


         -- Bugfix 3779636
            if l_inv_ctp = 4 then

              IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Get_Mandatory_Components: ' ||
                                 ' now calling load_mandatory_components_pds ' , 2);
              END IF;

              lStatus := load_mandatory_components_pds(p_ship_set,
                                lModelIndex,
                                v_request_date,
                                     lGrpId,
                                     xErrorMessage,
                                     xMessageName,
                                     xTableName);
              IF PG_DEBUG <> 0 THEN
                 oe_debug_pub.add('Get_Mandatory_Components: ' ||
                                         'Returned from load_mandatory_components_pds with '||lStatus, 2);
              END IF;

              if lStatus <> 1 then
                        IF PG_DEBUG <> 0 THEN
                                oe_debug_pub.add('Get_Mandatory_Components: ' ||
                                            ' Load_mandatory_components_pds returned with Error ',1);
                        END IF;
                        raise proc_error;
              end if;

            else




                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Get_Mandatory_Components: ' || ' now calling load_mandatory_components ' , 2);
                END IF;



         	lStatus := load_mandatory_components(p_ship_set,
                                lModelIndex,
				v_request_date,
                                     lGrpId,
                                     xErrorMessage,
                                     xMessageName,
                                     xTableName);
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Get_Mandatory_Components: ' || 'Returned from load_mand_comps with '||lStatus, 2);
		END IF;
         	if lStatus <> 1 then
            		IF PG_DEBUG <> 0 THEN
            			oe_debug_pub.add('Get_Mandatory_Components: ' || ' Load_mandatory_components returned with Error ',1);
            		END IF;
            		raise proc_error;
         	end if;

             end if ;  -- INV_CTP chk

             -- bugfix 3779636




         else


                oe_debug_pub.add(' Load_mandatory_components returned without processing
                                   as model qty is 0  ',1);
                return 1 ;

         end if;


     	end if;

     -- for calculating ATP lead time
	 lOrg_id := p_ship_set.source_organization_id(lModelIndex);
	 lItem_id := p_ship_set.inventory_item_id(lModelIndex);
     select nvl(fixed_lead_time,0),
            nvl(variable_lead_time,0)
     into   lFixedLt,
            lVarLt
     from   mtl_system_items msi
     where  msi.inventory_item_id = lItem_id
     and    msi.organization_id   = lOrg_id;

     lStmtNumber := 710;

     lAtpLt := ceil( lFixedLt + (p_ship_set.Quantity_Ordered(lModelIndex)  * lVarLt));


     select count(*)
     into chk
     from bom_explosion_temp
     where group_id = lGrpId
    and ( Line_id is null or top_bill_sequence_id = -1) ; /* BugFix 2897132 */

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('Get_Mandatory_Components: ' || ' Lines exploded ' || chk, 1);
     END IF;

     lStmtNumber := 730;

     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('Get_Mandatory_Components: ' || 'Going to Print Mandatory Comps ', 1);
     END IF;


     i := 1;
     for nxtrec in mandatory_comps
     loop
                /*-------------------------------------------+
                  Call MRP's API to extend x_smc_rec and copy
                  p_model_rec as default
                *-------------------------------------------*/


                lStmtNumber := 740;
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Get_Mandatory_Components: ' || '        Before calling MRP API::i='||to_char(i),1);
		END IF;
                MRP_ATP_PVT.assign_Atp_input_rec(p_ship_set,
                                                 lModelIndex,
                                                 x_smc_rec,
                                                 lStatus );
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Get_Mandatory_Components: ' || '        MRP API returns with '||lStatus, 2);
		END IF;

                if  lStatus  <> FND_API.G_RET_STS_SUCCESS then
                    xErrorMessage := 'assign_Atp_input_rec returned with Error';
                    raise proc_error;
                end if;

                x_smc_rec.inventory_item_id(i) := nxtrec.cid ;
                x_smc_rec.quantity_ordered(i)  := nxtrec.eq ;
                x_smc_rec.quantity_uom(i)      := nxtrec.uom ;		-- Bugfix 1998386
                x_smc_rec.atp_lead_time(i)     := lAtpLt;

                -- Bugfix 2897132
                if( nxtrec.line_id is not null ) then
                x_smc_rec.identifier(i) := nxtrec.line_id;
                end if ;

                x_smc_rec.attribute_01(i)     := nxtrec.wip_supply_type;	-- bugfix 3254039


                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add('Get_Mandatory_Components: ' ||  'Mand comp ' || i ||
                                  ' inv ' || x_smc_rec.inventory_item_id(i) ||
                                  ' eq ' || x_smc_rec.quantity_ordered(i) ||
                                  ' id ' || x_smc_rec.identifier(i)  ||
                                  ' wip supply type ' || x_smc_rec.attribute_01(i) , 1 ) ;		-- bugfix 3254039

                END IF;




                i := i + 1;
     end loop;


 IF PG_DEBUG <> 0 THEN
 	oe_debug_pub.add ('Get_Mandatory_Components: ' || 'Done Print Mandatory Comps ', 1);
 END IF;


     /*------------------------------------+
        Clean up bom_explosion_temp table
     +------------------------------------*/
     lStmtNumber := 750;

     delete from bom_explosion_temp
     where group_id = lGrpId;

     return(1);

  exception
  when no_data_found then
       xErrorMessage := 'CTOCITMB:'||to_char(lStmtNumber)||': No Data Found ' ;
       return (0);
  when proc_error then
       xErrorMessage := 'CTOCITMB :'|| to_char(lStmtNumber) || ': '  || xErrorMessage;
       return(0);
  when others then
       IF PG_DEBUG <> 0 THEN
       	oe_debug_pub.add ('Get_Mandatory_Components: ' || 'Others exception is get_mand_comp::'||substrb(sqlerrm,1,150));
       END IF;
       return(0);

end Get_Mandatory_Components;



/*-----------------------------------------------------+
  Creates configuration item in mtl_system_items.
  This function does not check the validity of
  data in oe_order_lines. The validity checks
  like 'check that config row does not exists already'
  are implemented in activity wrapper / batch program
+-----------------------------------------------------*/

--- The following procedure is modified by Renga Kannan on 08/31/01
--- While instering the rows into MTL_SYSTEM_ITEMS one new function
--- is called for list_price field. CTO_CUSTOM_LIST_PRICE_PK.get_list_price
--- is called to get the list price thru custom calculation. if it is null then
--- it will be copied from its model list price. This change is doen as part of
--- Procuring config Phase I -- Patchset G

--  We are removing the custom API call as part of patchset H. Instead this API will get called
--  from list price rollup. List price rollup will be called in later part of the program.
--  We don't copy the list price from Patchset H. It will be done by list price rollup program.
--  Fixed by Renga Kannan on 05/14/02


FUNCTION Create_Item(
        pModelId        in      number,
        pLineId         in      number,
        pConfigId       in out NOCOPY     number, /* NOCOPY Project */
	xMsgCount	 out NOCOPY   number,
        xMsgData        out NOCOPY   varchar2,
        p_mode          in     varchar2 default 'AUTOCONFIG' )
RETURN integer
IS

        lCiDel              varchar2(1) ;
        lItemType           varchar2(30);

        lNumberMethod       number ;
        lStmtNumber         number ;
        lFndSize            number ;
        app_col_ind         number ;
        lNextNum            number ;
        lOrderNum           number ;
        lLineNum            number ;
        lDeliveryNum        number ;
        lValidationOrg      number ;
        lTempvar            number ;
        lProfileVal         number ;
        lOpUnit             number ;
	lRcvOrg		    number;

	lReturnStatus	    varchar2(1);

        lConfigSegName      fnd_id_flex_segments.segment_name%type;
        app_column          fnd_id_flex_segments.segment_name%type;
        new_item_num        mtl_system_items.segment1%Type ;

        lCreateRules    varchar2(1);
        lStatus         number;

        type lSegType is table of
        mtl_system_items_interface.segment1%type
        index by binary_integer;

        seg               lSegType      ;

        l_model_tab    oe_order_pub.Line_tbl_type;

        -- Start Bugfix 2157740
	cursor 		c_get_org_id  	is
	select 		msi.organization_id	src_org_id
	from            mtl_system_items msi
	where  		msi.inventory_item_id = pConfigId
	and		not exists
		(SELECT  	'x'
         	 FROM   	FND_ATTACHED_DOCUMENTS
         	 WHERE  	pk1_value   = to_char(msi.organization_id)	-- 2774571
         	 AND		pk2_value   = to_char(msi.inventory_item_id)	-- 2774571
         	 AND    	entity_name = 'MTL_SYSTEM_ITEMS');


	v_src_org_id		mtl_system_items.organization_id%type;
	l_document_id    	Number;


	-- End bugfix 2157740

        /* Sushant removed declaration of lDupItem cursor as it is not used anymore .
            bug 2706981 was used to provide an alternate logic
        */


        v_program_id              bom_cto_order_lines.program_id%type ;
        x_return_status           varchar2(1);

        lOptionNum	    	  number ;		-- 2652379 : new variable
        v_ato_line_id  number ;
        l_ind_cnt number;  --Bugfix 8305535
        sqlcnt    number;  --Bugfix 8305535
BEGIN

	lReturnStatus	:= fnd_api.G_RET_STS_SUCCESS;

        gUserId          := nvl(Fnd_Global.USER_ID, -1);
        gLoginId         := nvl(Fnd_Global.LOGIN_ID, -1);
        lCiDel           := FND_PROFILE.Value('BOM:CONFIG_ITEM_DELIMITER');



       /* BUG #1957336 Change for preconfigure bom by Sushant Sawant */
       /* Added by Sushant for checking preconfigure bom module populated records */
       -- bugfix 2267646 Added nvl

        select NVL(program_id,0) , ato_line_id into v_program_id , v_ato_line_id
          from bom_cto_order_lines where line_id = pLineId ;


       /* BUG #1957336 Change for preconfigure bom by Sushant Sawant */
        /* Changes for patchset J
        if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
        */


        oe_debug_pub.add('Create_Item: ' ||  'p_mode ' || p_mode ,2);

        if( p_mode = 'PRECONFIG' ) then

            lValidationOrg := CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG ;

        else

            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('Create_Item: ' ||  'Before getting validation org',2);
            END IF;

            /*
            BUG:3484511
            ------------------------
            select nvl(master_organization_id,-99)	-- bugfix 2646849: master_organization_id can be 0
            into   lValidationOrg
            from   oe_order_lines_all oel,
              oe_system_parameters_all ospa
            where  oel.line_id = pLineid
            and    nvl(oel.org_id, -1) = nvl(ospa.org_id, -1) --bug 1531691
            and    oel.inventory_item_id = pModelId;
            */



           IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' ||  'Going to fetch Validation Org ' ,2);
           END IF;


           select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
              into lValidationOrg from oe_order_lines_all oel
           where oel.line_id = pLineId ;


        end if ;


        if lVAlidationOrg = -99 then			-- bugfix 2646849
      	 	cto_msg_pub.cto_message('BOM','CTO_VALIDATION_ORG_NOT_SET');
		raise FND_API.G_EXC_ERROR;
        end if;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Create_Item: ' ||  'Validation Org is :' ||  lValidationOrg,2);
        END IF;


	--
	-- If the config item is a matched item, enable the matched item
	-- in all orgs. If it is a new item, create a new item in all orgs
	--

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'config_item_id::'||to_char(pConfigId),2);
	END IF;

        IF (pConfigId is NULL) THEN

		-- config id is not populated in config_item_id
		-- generate a new config item

        	/*--------------------------------------------------+
        	Check to see if the config_segment_name exists in
		bom_parameters for the given organization.
        	BOM_parameters are organization dependent, we will use
        	BOM_parameter settings in the OE validation org.
        	+---------------------------------------------------*/

        	lStmtNumber   := 15;
        	select  config_segment_name,
                	config_number_method_type
        	into    lConfigSegName,
                	lNumberMethod
        	from    bom_parameters
        	where   organization_id = lValidationOrg;


        	if lConfigSegName is NULL then
			cto_msg_pub.cto_message('BOM','CTO_CONFIG_SEGMENT_ERROR');
			raise FND_API.G_EXC_ERROR;
        	end if;

        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add('Create_Item: ' ||  'config Segment is : ' || lConfigSegName,2 );

        		oe_debug_pub.add('Create_Item: ' ||  'Number Method  is : ' || lNumberMethod,2 );
        	END IF;

                /* BUG #2172057 Change for preconfigure bom by Sushant Sawant */
                if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
                    -- 2663450 : Change the NumberMethod only when it is <> 4.
		  if lNumberMethod <> 4 then
                    lNumberMethod := 1 ;
		  end if;

        	    IF PG_DEBUG <> 0 THEN
        	    	oe_debug_pub.add('Create_Item: ' ||  'Number Method  Changed due to preconfigure bom restriction of append with sequence number: ' ||
				lNumberMethod,2 );
        	    END IF;

                end if ;

        	lStmtNumber   := 20;
		-- Bugfix 1736339 : sql%notfound will not be raised in case of SELECT, instead NO_DATA_FOUND
		--	  	    exception is raised.
		--                  Added outer join to the query so that we'll default the maximum_size to 40
		--                  Merged stmt# 40 in the same query.
		--		    Since lConfigSegName is available, we will use this instead of joining bom_parameters.

        	select  nvl(fv.maximum_size,40), fs.application_column_name
        	into    lFndSize, app_column
        	from    -- bom_parameters p,
        		fnd_id_flex_segments fs,
            		fnd_flex_value_sets fv
        	where   --p.organization_id    = lValidationOrg and
 		       fs.id_flex_code      = 'MSTK'
        	and    fs.id_flex_num       = 101
        	and    fs.segment_name      = lConfigSegName		--p.config_segment_name
        	and    fs.application_id    = 401   -- INV
        	and    fs.flex_value_set_id = fv.flex_value_set_id(+);


        	app_col_ind := to_number( substrb(app_column,8,length( app_column) -7 ));

 	       	lStmtNumber   := 30;

       	 	select
                	segment1,
                	segment2,
                	segment3,
                	segment4,
                	segment5,
                	segment6,
                	segment7,
                	segment8,
                	segment9,
                	segment10,
                	segment11,
                	segment12,
                	segment13,
                	segment14,
                	segment15,
                	segment16,
                	segment17,
                	segment18,
                	segment19,
                	segment20
        	into
                	seg(1),
                	seg(2),
                	seg(3),
                	seg(4),
                	seg(5),
                	seg(6),
                	seg(7),
                	seg(8),
                	seg(9),
                	seg(10),
                	seg(11),
                	seg(12),
                	seg(13),
                	seg(14),
                	seg(15),
                	seg(16),
                	seg(17),
                	seg(18),
                	seg(19),
                	seg(20)
        	from   mtl_system_items msi
        	where  inventory_item_id = pModelId
        	and    organization_id   = lValidationOrg;

        	lStmtNumber   := 50;

        	if lNumberMethod = 1 then
                	select mtl_system_items_B_S.nextval
                	into   lNextNum
                	from dual;

			-- bugfix 1933740 : Replaced seg(1) with seg(app_col_ind)

                	select ( substrb(seg(app_col_ind),1, decode(greatest(lFndSize,40),40,lFndSize -1-length(lNextNum),39 - length(lNextNum))) || lCiDel || to_char(lNextNum))
                	into new_item_num
                	from dual;

        	elsif lNumberMethod = 2 then
                	select to_char(mtl_system_items_B_S.nextval)
                	into   new_item_num
                	from dual;

                -- 2652379 : When numbering method is 3 , i.e Replace with order num, line num;
                -- item numbering segment ( Part num , item num , etc. ) is replaced with order
                -- number + line_number + shipment number. For model under model , item number gets
                -- appended with a sequence since child and parent model are having same number
                -- ( i.e. same order# + line# + shipment# ) .  As we select model with plan level
                -- descending to create corresponding config items , the model at lowest level
                -- ( i.e. having highest plan level ) will get order# + line# + shipment# as its
                -- config item number while for all higher level models it will be  seq. appended
                -- ( i.e. order# + line# + shipment# + seq ).
                -- E.g. For an order # 1000 , line# 1 , shipment# 1 a Bill structure like
                --		M1
                --		.. M2
                --		....M3
                -- will get 1000*1*1 for M3 , 1000*1*1*seq1 for M2 and 1000*1*1*seq2 for M1
                -- After this fix , a new column option_number will be appended so that config
                -- items at different plan level will have unique config item number.
                -- Also this will eliminate the need for checking duplicate config items while
                -- traversing the bill as long as option_number is NOT NULL. Under new numbering
                -- scheme , for the above example , config items will have following numbers :
                -- 1000*1*1 for M1 , 1000*1*1*1 for M2 and 1000*1*1*2 for M3
                -- where M1 , being at top level does not have option number , while M2 and M3
                -- have option# 1 and 2 resp.
                -- Also , in this fix decode on lDeliveryNum to check NULL condition is removed
                -- since this column is defined as NOT NULL in database.


        	elsif lNumberMethod = 3 then
                	lStmtNumber   := 60;
                	select oeh.order_number,
                        	oel.line_number,
                        	oel.shipment_number,
                        	oel.option_number 		-- 2652379 : new column
                	into   lOrderNum,
                        	lLineNum,
                        	lDeliveryNum,
                        	lOptionNum			-- 2652379 : new variable
                	from   oe_order_lines_all oel,
                        	oe_order_headers_all oeh
                	where  oel.line_id = pLineId
                	and    oel.header_id = oeh.header_id;

                	-- 2652379 Changed decode
                	/*
                	select decode(lDeliveryNum, NULL, lOrderNum || lCiDel || lLineNum,
                					  lOrderNum || lCiDel || lLineNum || lCiDel|| lDeliveryNum )
                        into new_item_num
                        from dual;
                        */
                	select decode (lOptionNum, NULL, lOrderNum || lCiDel || lLineNum || lCiDel|| lDeliveryNum,
                					 lOrderNum || lCiDel || lLineNum || lCiDel|| lDeliveryNum || lCiDel || lOptionNum )
                	into new_item_num
                	from dual;
                	-- end fix 2652379
        	else
                	/*--------------------------+
                	Call to user Defined Method
                	+--------------------------*/
                	 -- bugfix 2663450: call custom api ..

                        if( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then
                                new_item_num := CTO_CUSTOM_CONFIG_NUMBER.user_item_number
                                        (       model_item_id   =>      pModelId,
                                                model_line_id   =>      NULL,
                                                param1          =>      NULL,
                                                param2          =>      NULL,
                                                param3          =>      NULL,
                                                param4          =>      NULL,
                                                param5          =>      NULL
                                        );
                                IF PG_DEBUG <> 0 THEN
                            	oe_debug_pub.add( 'Precfg case - Custom Item number is  ' || new_item_num ,2 );
                            	END IF;
                        else
                		new_item_num := BOMPCFGI.user_item_number(pLineId);
                		IF PG_DEBUG <> 0 THEN
                			oe_debug_pub.add('Create_Item: ' ||  'Item number is  ' || new_item_num ,2 );
                		END IF;
                	end if;
		end if;  -- End check for number method

        	seg(app_col_ind) := new_item_num;

        	lStmtNumber   := 70;
        	/*-------------------------------------------------+
        	if a item with name new_item_num already exists in
        	table, append it with a sequence_number to make it
        	unique
        	+--------------------------------------------------*/

		-- bugfix 2706981
		-- Replaced the loop (commented below) with function check_dup_item
		-- which dynamically builts the query to check duplicate item names.
		--

		if check_dup_item(seg(1), seg(2), seg(3), seg(4), seg(5),
		                     seg(6), seg(7), seg(8), seg(9), seg(10),
		                     seg(11), seg(12), seg(13), seg(14), seg(15),
		                     seg(16), seg(17), seg(18), seg(19), seg(20)) = 1
                then
                	IF PG_DEBUG <> 0 THEN
                	   oe_debug_pub.add( 'Create_Item: '|| 'generating unique name' ,2 );
			END IF;
                	select to_char(mtl_system_items_B_S.nextval)
                	into lNextNum
                	from dual;
                	seg(app_col_ind) := new_item_num || lCiDel || lNextNum;
		end if;

		/* bugfix 2706981: commented out and replaced with above check_dup_item
		   see above.

        	  for nxt_rec in lDupItem
        	  loop

                	IF PG_DEBUG <> 0 THEN
                		oe_debug_pub.add('Create_Item: ' ||  'generating unique name' ,2 );
                	END IF;
                	select to_char(mtl_system_items_B_S.nextval)
                	into lNextNum
                	from dual;
                	seg(app_col_ind) := new_item_num || lCiDel || lNextNum;
                	exit;
        	  end loop;
		*/

        	IF PG_DEBUG <> 0 THEN
        		oe_debug_pub.add('Create_Item: ' ||  'item numbering segment is '||  app_col_ind ,2 );

        		oe_debug_pub.add('Create_Item: ' ||  'new_item number is  ' || seg(app_col_ind) ,2 );
        	END IF;

        	select to_char(mtl_system_items_b_S.nextval) into pConfigId from dual;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_Item: ' ||  'new pConfigId is '||to_char(pConfigId),2);
		END IF;

	ELSE
		-- config id is populated in config_item_id
		-- use the matched item

		select distinct
			segment1,
			segment2,
                	segment3,
                	segment4,
                	segment5,
                	segment6,
                	segment7,
                	segment8,
                	segment9,
                	segment10,
                	segment11,
                	segment12,
                	segment13,
                	segment14,
                	segment15,
                	segment16,
                	segment17,
                	segment18,
                	segment19,
                	segment20
        	into
                	seg(1),
                	seg(2),
                	seg(3),
                	seg(4),
                	seg(5),
                	seg(6),
                	seg(7),
                	seg(8),
                	seg(9),
                	seg(10),
                	seg(11),
                	seg(12),
                	seg(13),
                	seg(14),
                	seg(15),
                	seg(16),
                	seg(17),
                	seg(18),
                	seg(19),
                	seg(20)
        	from   mtl_system_items msi
        	where  inventory_item_id = pConfigId;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_Item: ' ||  'matched pConfigId is '||to_char(pConfigId),2);
		END IF;

	END IF; -- matched/new item



        -- rkaza. 10/21/2004. bug 3860077. Item type should be null if profile is null.
	lItemType :=  FND_PROFILE.Value('BOM:CONFIG_ITEM_TYPE');

        /*-----------------------------------------------------------+
        Insert a row into the  mtl_system_items table.
        +------------------------------------------------------------*/

        --xTableName := 'MTL_SYSTEM_ITEMS';
        lStmtNumber := 80;

        /* need to add attribute controlled statement for preconfigured item */
        oe_debug_pub.add('Create_Item: ' ||  'p_mode is '||  p_mode ,2);

        if( p_mode = 'AUTOCONFIG' OR pLineId <> v_ato_line_id ) then

        oe_debug_pub.add('Create_Item: ' ||  'came into AUTOCONFIG ' ,2);
/*
tracking_quantity_ind TRACK,
  4  ont_pricing_qty_source PRCQTY, approval_status
*/

        --appsperf bug#	4905845, sql id 16104136
	--decrease comments within sql to max extent to reduce shared memory

        -- Bug 9223457.added additional attribute columns added in 12.1
        -- for mtl_sys_items.pdube

	insert into mtl_system_items_b
                (inventory_item_id,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                summary_flag,
                enabled_flag,
                start_date_active,
                end_date_active,
                description,
                buyer_id,
                accounting_rule_id,
                invoicing_rule_id,
                segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                segment6,
                segment7,
                segment8,
                segment9,
                segment10,
                segment11,
                segment12,
                segment13,
                segment14,
                segment15,
                segment16,
                segment17,
                segment18,
                segment19,
                segment20,
                attribute_category,
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
                attribute16,  -- Bug 9223457
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                purchasing_item_flag,
                shippable_item_flag,
                customer_order_flag,
                internal_order_flag,
                service_item_flag,
                inventory_item_flag,
                eng_item_flag,
                inventory_asset_flag,
                purchasing_enabled_flag,
                customer_order_enabled_flag,
                internal_order_enabled_flag,
                so_transactions_flag,
                mtl_transactions_enabled_flag,
                stock_enabled_flag,
                bom_enabled_flag,
                build_in_wip_flag,
                revision_qty_control_code,
                item_catalog_group_id,
                catalog_status_flag,
                returnable_flag,
                default_shipping_org,
                collateral_flag,
                taxable_flag,
                allow_item_desc_update_flag,
                inspection_required_flag,
                receipt_required_flag,
                market_price,
                hazard_class_id,
                rfq_required_flag,
                qty_rcv_tolerance,
                un_number_id,
                price_tolerance_percent,
                asset_category_id,
                rounding_factor,
                unit_of_issue,
                enforce_ship_to_location_code,
                allow_substitute_receipts_flag,
                allow_unordered_receipts_flag,
                allow_express_delivery_flag,
                days_early_receipt_allowed,
                days_late_receipt_allowed,
                receipt_days_exception_code,
                receiving_routing_id,
                invoice_close_tolerance,
                receive_close_tolerance,
                auto_lot_alpha_prefix,
                start_auto_lot_number,
                lot_control_code,
                shelf_life_code,
                shelf_life_days,
                serial_number_control_code,
                start_auto_serial_number,
                auto_serial_alpha_prefix,
                source_type,
                source_organization_id,
                source_subinventory,
                expense_account,
                encumbrance_account,
                restrict_subinventories_code,
                unit_weight,
                weight_uom_code,
                volume_uom_code,
                unit_volume,
                restrict_locators_code,
                location_control_code,
                shrinkage_rate,
                acceptable_early_days,
                planning_time_fence_code,
                demand_time_fence_code,
                lead_time_lot_size,
                std_lot_size,
                cum_manufacturing_lead_time,
                overrun_percentage,
                acceptable_rate_increase,
                acceptable_rate_decrease,
                cumulative_total_lead_time,
                planning_time_fence_days,
                demand_time_fence_days,
                end_assembly_pegging_flag,
                planning_exception_set,
                bom_item_type,
                pick_components_flag,
                replenish_to_order_flag,
                base_item_id,
                atp_components_flag,
                atp_flag,
                fixed_lead_time,
                variable_lead_time,
                wip_supply_locator_id,
                wip_supply_type,
                wip_supply_subinventory,
                primary_uom_code,
                primary_unit_of_measure,
                allowed_units_lookup_code,
                cost_of_sales_account,
                sales_account,
                default_include_in_rollup_flag,
                inventory_item_status_code,
                inventory_planning_code,
                planner_code,
                planning_make_buy_code,
                fixed_lot_multiplier,
                rounding_control_type,
                carrying_cost,
                postprocessing_lead_time,
                preprocessing_lead_time,
                full_lead_time,
                order_cost,
                mrp_safety_stock_percent,
                mrp_safety_stock_code,
                min_minmax_quantity,
                max_minmax_quantity,
                minimum_order_quantity,
                fixed_order_quantity,
                fixed_days_supply,
                maximum_order_quantity,
                atp_rule_id,
                picking_rule_id,
                reservable_type,
                positive_measurement_error,
                negative_measurement_error,
                engineering_ecn_code,
                engineering_item_id,
                engineering_date,
                service_starting_delay,
                vendor_warranty_flag,
                serviceable_component_flag,
                serviceable_product_flag,
                base_warranty_service_id,
                payment_terms_id,
                preventive_maintenance_flag,
                primary_specialist_id,
                secondary_specialist_id,
                serviceable_item_class_id,
                time_billable_flag,
                material_billable_flag,
                expense_billable_flag,
                prorate_service_flag,
                coverage_schedule_id,
                service_duration_period_code,
                service_duration,
                max_warranty_amount,
                response_time_period_code,
                response_time_value,
                new_revision_code,
                tax_code,
                must_use_approved_vendor_flag,
                safety_stock_bucket_days,
                auto_reduce_mps,
                costing_enabled_flag,
                invoiceable_item_flag,
                invoice_enabled_flag,
                outside_operation_flag,
                outside_operation_uom_type,
                auto_created_config_flag,
                cycle_count_enabled_flag,
                item_type,
                model_config_clause_name,
                ship_model_complete_flag,
                mrp_planning_code,
                repetitive_planning_flag,
                return_inspection_requirement,
                effectivity_control,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
		comms_nl_trackable_flag,               -- bugfix 2200256
		default_so_source_type,
		create_supply_flag,
			-- 2336548
		lot_status_enabled,
		default_lot_status_id,
		serial_status_enabled,
		default_serial_status_id,
		lot_split_enabled,
		lot_merge_enabled,
		bulk_picked_flag,

			-- 2400609
		FINANCING_ALLOWED_FLAG,
 		EAM_ITEM_TYPE ,
 		EAM_ACTIVITY_TYPE_CODE,
 		EAM_ACTIVITY_CAUSE_CODE,
 		EAM_ACT_NOTIFICATION_FLAG,
 		EAM_ACT_SHUTDOWN_STATUS,
 		SUBSTITUTION_WINDOW_CODE,
 		SUBSTITUTION_WINDOW_DAYS,
 		PRODUCT_FAMILY_ITEM_ID,
 		CHECK_SHORTAGES_FLAG,
 		PLANNED_INV_POINT_FLAG,
 		OVER_SHIPMENT_TOLERANCE,
 		UNDER_SHIPMENT_TOLERANCE,
 		OVER_RETURN_TOLERANCE,
 		UNDER_RETURN_TOLERANCE,
 		PURCHASING_TAX_CODE,
 		OVERCOMPLETION_TOLERANCE_TYPE,
 		OVERCOMPLETION_TOLERANCE_VALUE,
 		INVENTORY_CARRY_PENALTY,
 		OPERATION_SLACK_PENALTY,
 		UNIT_LENGTH,
 		UNIT_WIDTH,
 		UNIT_HEIGHT,
 		LOT_TRANSLATE_ENABLED,
 		CONTAINER_ITEM_FLAG,
 		VEHICLE_ITEM_FLAG,
 		DIMENSION_UOM_CODE,
 		SECONDARY_UOM_CODE,
 		MAXIMUM_LOAD_WEIGHT,
 		MINIMUM_FILL_PERCENT,
 		CONTAINER_TYPE_CODE,
 		INTERNAL_VOLUME,
 		EQUIPMENT_TYPE,
 		INDIVISIBLE_FLAG,
 		GLOBAL_ATTRIBUTE_CATEGORY,
 		GLOBAL_ATTRIBUTE1,
 		GLOBAL_ATTRIBUTE2,
 		GLOBAL_ATTRIBUTE3,
 		GLOBAL_ATTRIBUTE4,
 		GLOBAL_ATTRIBUTE5,
 		GLOBAL_ATTRIBUTE6,
 		GLOBAL_ATTRIBUTE7,
 		GLOBAL_ATTRIBUTE8,
 		GLOBAL_ATTRIBUTE9,
 		GLOBAL_ATTRIBUTE10,
		DUAL_UOM_CONTROL,
 		DUAL_UOM_DEVIATION_HIGH,
 		DUAL_UOM_DEVIATION_LOW,
                CONTRACT_ITEM_TYPE_CODE,
 		SUBSCRIPTION_DEPEND_FLAG,
 		SERV_REQ_ENABLED_CODE,
 		SERV_BILLING_ENABLED_FLAG,
 		RELEASE_TIME_FENCE_CODE,	-- 2898851
 		RELEASE_TIME_FENCE_DAYS,	-- 2898851
 		DEFECT_TRACKING_ON_FLAG,        -- 2858080
 		SERV_IMPORTANCE_LEVEL,

	        WEB_STATUS ,  --2727983
                tracking_quantity_ind,   --Attribute for Item in patchset J
                ont_pricing_qty_source,
                approval_status ,
                vmi_minimum_units,
                vmi_minimum_days,
                vmi_maximum_units,
                vmi_maximum_days,
                vmi_fixed_order_quantity,
                so_authorization_flag,
                consigned_flag,
                asn_autoexpire_flag,
                vmi_forecast_type,
                forecast_horizon,
                days_tgt_inv_supply,
                days_tgt_inv_window,
                days_max_inv_supply,
                days_max_inv_window,
                critical_component_flag,
                drp_planned_flag,
                exclude_from_budget_flag,
                convergence,
                continous_transfer,
                divergence,

		--r12 4574899
		lot_divisible_flag,
		grade_control_flag,
		child_lot_flag,
                child_lot_validation_flag,
		copy_lot_attribute_flag,
		parent_child_generation_flag,  --Bugfix 8821149
		lot_substitution_enabled,      --Bugfix 8821149
		recipe_enabled_flag,
                process_quality_enabled_flag,
		process_execution_enabled_flag,
	        process_costing_enabled_flag,
		hazardous_material_flag,
		preposition_point,
		repair_program,
		outsourced_assembly


                )
        select distinct
                pConfigId,
                m.organization_id,
                sysdate,
                gUserId,
                sysdate,
                gUserId,
                gLoginId ,
                m.summary_flag,
                m.enabled_flag,
                m.start_date_active,
                m.end_date_active,
                m.description,
                m.buyer_id,
                m.accounting_rule_id,
                m.invoicing_rule_id,
                seg(1),
                seg(2),
                seg(3),
                seg(4),
                seg(5),
                seg(6),
                seg(7),
                seg(8),
                seg(9),
                seg(10),
                seg(11),
                seg(12),
                seg(13),
                seg(14),
                seg(15),
                seg(16),
                seg(17),
                seg(18),
                seg(19),
                seg(20),
                m.attribute_category,
                m.attribute1,
                m.attribute2,
                m.attribute3,
                m.attribute4,
                m.attribute5,
                m.attribute6,
                m.attribute7,
                m.attribute8,
                m.attribute9,
                m.attribute10,
                m.attribute11,
                m.attribute12,
                m.attribute13,
                m.attribute14,
                m.attribute15,
                m.attribute16,  -- Bug 9223457
                m.attribute17,
                m.attribute18,
                m.attribute19,
                m.attribute20,
                m.attribute21,
                m.attribute22,
                m.attribute23,
                m.attribute24,
                m.attribute25,
                m.attribute26,
                m.attribute27,
                m.attribute28,
                m.attribute29,
                m.attribute30,
                'Y',
                'Y',
                'Y',
                'Y',
                m.service_item_flag,
                'Y',
                m.eng_item_flag,
                m.inventory_asset_flag,
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                'Y',
                m.revision_qty_control_code,
                m.item_catalog_group_id,
                m.catalog_status_flag,
                m.returnable_flag,
                m.default_shipping_org,
                m.collateral_flag,
                m.taxable_flag,
                m.allow_item_desc_update_flag,
                m.inspection_required_flag,
                m.receipt_required_flag,
                m.market_price,
                m.hazard_class_id,
                m.rfq_required_flag,
                m.qty_rcv_tolerance,
                m.un_number_id,
                m.price_tolerance_percent,
                m.asset_category_id,
                m.rounding_factor,
                m.unit_of_issue,
                m.enforce_ship_to_location_code,
                m.allow_substitute_receipts_flag,
                m.allow_unordered_receipts_flag,
                m.allow_express_delivery_flag,
                m.days_early_receipt_allowed,
                m.days_late_receipt_allowed,
                m.receipt_days_exception_code,
                m.receiving_routing_id,
                m.invoice_close_tolerance,
                m.receive_close_tolerance,
                m.auto_lot_alpha_prefix,
                m.start_auto_lot_number,
                m.lot_control_code,
                m.shelf_life_code,
                m.shelf_life_days,
                m.serial_number_control_code,
                m.start_auto_serial_number,
                m.auto_serial_alpha_prefix,
                m.source_type,
                m.source_organization_id,
                m.source_subinventory,
                m.expense_account,
                m.encumbrance_account,
                m.restrict_subinventories_code,
		--  2301167 : we will calculate the unit weight/vol later..
                null,
                null,
                null,
                null,

                m.restrict_locators_code,
                m.location_control_code,
                m.shrinkage_rate,
                m.acceptable_early_days,
                m.planning_time_fence_code,
                m.demand_time_fence_code,
                m.lead_time_lot_size,
                m.std_lot_size,
                m.cum_manufacturing_lead_time,
                m.overrun_percentage,
                m.acceptable_rate_increase,
                m.acceptable_rate_decrease,
                m.cumulative_total_lead_time,
                m.planning_time_fence_days,
                m.demand_time_fence_days,
                m.end_assembly_pegging_flag,
                m.planning_exception_set,
                4,                                 -- BOM_ITEM_TYPE : standard
                'N',
                'Y',
                pModelId,
                evaluate_atp_attributes( m.atp_flag, m.atp_components_flag ),
                get_atp_flag,
                m.fixed_lead_time,
                m.variable_lead_time,
                m.wip_supply_locator_id,
                m.wip_supply_type,
                m.wip_supply_subinventory,
                m.primary_uom_code,
                m.primary_unit_of_measure,
                m.allowed_units_lookup_code,
                m.cost_of_sales_account,
                m.sales_account,
                'Y',
                m.inventory_item_status_code,
                m.inventory_planning_code,
                m.planner_code,
                m.planning_make_buy_code,
                m.fixed_lot_multiplier,
                m.rounding_control_type,
                m.carrying_cost,
                m.postprocessing_lead_time,
                m.preprocessing_lead_time,
                m.full_lead_time,
                m.order_cost,
                m.mrp_safety_stock_percent,
                m.mrp_safety_stock_code,
                m.min_minmax_quantity,
                m.max_minmax_quantity,
                m.minimum_order_quantity,
                m.fixed_order_quantity,
                m.fixed_days_supply,
                m.maximum_order_quantity,
                m.atp_rule_id,
                m.picking_rule_id,
                1,
                m.positive_measurement_error,
                m.negative_measurement_error,
                m.engineering_ecn_code,
                m.engineering_item_id,
                m.engineering_date,
                m.service_starting_delay,
                m.vendor_warranty_flag,
                m.serviceable_component_flag,
                m.serviceable_product_flag,
                m.base_warranty_service_id,
                m.payment_terms_id,
                m.preventive_maintenance_flag,
                m.primary_specialist_id,
                m.secondary_specialist_id,
                m.serviceable_item_class_id,
                m.time_billable_flag,
                m.material_billable_flag,
                m.expense_billable_flag,
                m.prorate_service_flag,
                m.coverage_schedule_id,
                m.service_duration_period_code,
                m.service_duration,
                m.max_warranty_amount,
                m.response_time_period_code,
                m.response_time_value,
                m.new_revision_code,
                m.tax_code,
                m.must_use_approved_vendor_flag,
                m.safety_stock_bucket_days,
                m.auto_reduce_mps,
                m.costing_enabled_flag,
                m.invoiceable_item_flag,             -- 'N' Changed for international dropship
                m.invoice_enabled_flag,              -- 'N' Changed on OM's request
                m.outside_operation_flag,
                m.outside_operation_uom_type,
                'Y',
                m.cycle_count_enabled_flag,
                lItemType,
                m.model_config_clause_name,
                m.ship_model_complete_flag,
                m.mrp_planning_code,                 -- earlier it was always from one org only
                m.repetitive_planning_flag,          -- earlier it was always from one org only
                m.return_inspection_requirement,
                nvl(m.effectivity_control, 1),
                null,
                null,
                null,
                sysdate,
		m.comms_nl_trackable_flag,               --  2200256
		nvl(m.default_so_source_type,'INTERNAL'),
		nvl(m.create_supply_flag, 'Y'),
			-- begin bugfix 2336548
		m.lot_status_enabled,
		m.default_lot_status_id,
		m.serial_status_enabled,
		m.default_serial_status_id,
		m.lot_split_enabled,
		m.lot_merge_enabled,
		m.bulk_picked_flag,
			-- end bugfix 2336548
			-- begin bugfix 2400609
		m.FINANCING_ALLOWED_FLAG,
 		m.EAM_ITEM_TYPE ,
 		m.EAM_ACTIVITY_TYPE_CODE,
 		m.EAM_ACTIVITY_CAUSE_CODE,
 		m.EAM_ACT_NOTIFICATION_FLAG,
 		m.EAM_ACT_SHUTDOWN_STATUS,
 		m.SUBSTITUTION_WINDOW_CODE,
 		m.SUBSTITUTION_WINDOW_DAYS,
 		null, --m.PRODUCT_FAMILY_ITEM_ID, 5385901
 		m.CHECK_SHORTAGES_FLAG,
 		m.PLANNED_INV_POINT_FLAG,
 		m.OVER_SHIPMENT_TOLERANCE,
 		m.UNDER_SHIPMENT_TOLERANCE,
 		m.OVER_RETURN_TOLERANCE,
 		m.UNDER_RETURN_TOLERANCE,
 		m.PURCHASING_TAX_CODE,
 		m.OVERCOMPLETION_TOLERANCE_TYPE,
 		m.OVERCOMPLETION_TOLERANCE_VALUE,
 		m.INVENTORY_CARRY_PENALTY,
 		m.OPERATION_SLACK_PENALTY,
 		m.UNIT_LENGTH,
 		m.UNIT_WIDTH,
 		m.UNIT_HEIGHT,
 		m.LOT_TRANSLATE_ENABLED,
 		m.CONTAINER_ITEM_FLAG,
 		m.VEHICLE_ITEM_FLAG,
 		m.DIMENSION_UOM_CODE,
 		m.SECONDARY_UOM_CODE,
 		m.MAXIMUM_LOAD_WEIGHT,
 		m.MINIMUM_FILL_PERCENT,
 		m.CONTAINER_TYPE_CODE,
 		m.INTERNAL_VOLUME,
 		m.EQUIPMENT_TYPE,
 		m.INDIVISIBLE_FLAG,
 		m.GLOBAL_ATTRIBUTE_CATEGORY,
 		m.GLOBAL_ATTRIBUTE1,
 		m.GLOBAL_ATTRIBUTE2,
 		m.GLOBAL_ATTRIBUTE3,
 		m.GLOBAL_ATTRIBUTE4,
 		m.GLOBAL_ATTRIBUTE5,
 		m.GLOBAL_ATTRIBUTE6,
 		m.GLOBAL_ATTRIBUTE7,
 		m.GLOBAL_ATTRIBUTE8,
 		m.GLOBAL_ATTRIBUTE9,
 		m.GLOBAL_ATTRIBUTE10,
     		m.DUAL_UOM_CONTROL,
 		m.DUAL_UOM_DEVIATION_HIGH,
 		m.DUAL_UOM_DEVIATION_LOW,
                m.CONTRACT_ITEM_TYPE_CODE,
 		m.SUBSCRIPTION_DEPEND_FLAG,
 		m.SERV_REQ_ENABLED_CODE,
 		m.SERV_BILLING_ENABLED_FLAG,
 		m.RELEASE_TIME_FENCE_CODE,	  -- 2898851
 		m.RELEASE_TIME_FENCE_DAYS,	  -- 2898851
 		m.DEFECT_TRACKING_ON_FLAG,        -- 2858080
 		m.SERV_IMPORTANCE_LEVEL,
			 -- end bugfix 2400609
	        m.web_status ,                    --   2727983
                nvl( tracking_quantity_ind , 'P' ),
                nvl( m.ont_pricing_qty_source, 'P') ,
                m.approval_status,
                m.vmi_minimum_units,
                m.vmi_minimum_days,
                m.vmi_maximum_units,
                m.vmi_maximum_days,
                m.vmi_fixed_order_quantity,
                m.so_authorization_flag,
                m.consigned_flag,
                m.asn_autoexpire_flag,
                m.vmi_forecast_type,
                m.forecast_horizon,
                m.days_tgt_inv_supply,
                m.days_tgt_inv_window,
                m.days_max_inv_supply,
                m.days_max_inv_window,
                m.critical_component_flag,
                m.drp_planned_flag,
                m.exclude_from_budget_flag,
                m.convergence,
                m.continous_transfer,
                m.divergence,
		   -- r12,4574899
		nvl(m.lot_divisible_flag, 'N'),  --Bugfix 6343429
		'N',
		/* Bugfix 8821149: Will populate these values from model.
		'N',
	        'N',
		'N',
		*/
		m.child_lot_flag,
		m.child_lot_validation_flag,
		m.copy_lot_attribute_flag,
		m.parent_child_generation_flag,
		m.lot_substitution_enabled,
		-- End Bugfix 8821149
		'N',
		'N',
		'N',
		'N',
		'N',
		'N',
		3,
		2

        from
                mtl_system_items_b  m,               -- Model
                bom_cto_src_orgs        bcso,
                bom_cto_order_lines     bcol
        where  m.inventory_item_id = pModelId
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and bcol.line_id = bcso.line_id
	and m.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from mtl_system_items_b
                where inventory_item_id = pConfigId
                and organization_id = m.organization_id);

        sqlcnt := sql%rowcount; -- Added for bug 8305535

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:mtl_system_items_b',2);

        	oe_debug_pub.add('Create_Item: ' || 'Inserted '||sqlcnt||' rows in mtl_system_items_b',2);
        END IF;
		-- added as part of bugfix 1811007

		 --Start Bugfix 8305535
 	         if ( sqlcnt > 0) then
 	            IF PG_DEBUG <> 0 THEN
 	                 oe_debug_pub.add('Create_Item: ' || 'Going to insert in pl/sql table for project Genesis',2);
 	            END IF;

 	            l_ind_cnt := CTO_MSUTIL_PUB.cfg_tbl_var.count;
 	            CTO_MSUTIL_PUB.cfg_tbl_var(l_ind_cnt + 1) := pConfigId;
 	         end if;
 	         --End Bugfix 8305535



        else

               oe_debug_pub.add('Create_Item: ' || 'going to call create_precon figured item ' || ' line ' || pLineId ||
                 ' Model ' || pModelId ||
                 ' Config ' || pConfigId ||
                 ' item type ' || lItemType  ,2);


            create_preconfigured_item( pLineId, pModelId, pConfigId , lItemType ) ;

        end if;


	-- start bugfix 2157740

	lStmtNumber := 81;

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' ||  'Opening cursor c_get_org_id.. ' ,3);
	END IF;

	BEGIN
	FOR v_get_org_id in c_get_org_id
	LOOP
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Create_Item: ' ||  'Fetched Org Id '|| v_get_org_id.src_org_id,3);
        END IF;
	fnd_attached_documents2_pkg.copy_attachments (
	 			X_from_entity_name 		=>     'MTL_SYSTEM_ITEMS',
                        	X_from_pk1_value 		=>	v_get_org_id.src_org_id,
                        	X_from_pk2_value 		=>	pModelId,
                        	X_from_pk3_value 		=>	NULL,
                        	X_from_pk4_value 		=>	NULL,
                        	X_from_pk5_value 		=>	NULL,
                        	X_to_entity_name 		=>	'MTL_SYSTEM_ITEMS',
                        	X_to_pk1_value 			=>	v_get_org_id.src_org_id,
                        	X_to_pk2_value 			=>	pConfigId,
                        	X_to_pk3_value 			=>	NULL,
                        	X_to_pk4_value 			=>	NULL,
                        	X_to_pk5_value 			=>	NULL,
                        	X_created_by 			=>	fnd_global.USER_ID,
                        	X_last_update_login 		=>	fnd_global.USER_ID,
                        	X_program_application_id 	=>	fnd_global.PROG_APPL_ID,
                        	X_program_id 			=>	fnd_global.CONC_REQUEST_ID,
                        	X_request_id 			=>	fnd_global.USER_ID,
                        	X_automatically_added_flag 	=>	NULL
                        	);
        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add('Create_Item: ' || 'Done copy_attachment ',3);
        END IF;
        END LOOP;
        END;
	-- End bugfix 2157740


        --
        -- Modified the weight/volume calculation logic for supporting MLMO
        --

	-- bugfix 2301167: Added the global status check (gWtStatus and gVolStatus)
	-- This is done to prevent calculation of upper level config's if lower level
	-- configs have errored out.

	--Bugfix 9223554: Will not use these global variables.
	/*
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('Create_Item: ' || 'gWtStatus = '||CTO_CONFIG_ITEM_PK.gWtStatus|| ' and gVolStatus = '||CTO_CONFIG_ITEM_PK.gVolStatus,1);
	END IF;

	if CTO_CONFIG_ITEM_PK.gWtStatus = 0 or		-- 0 means success
	   CTO_CONFIG_ITEM_PK.gVolStatus = 0
	then
	*/

	if ( not g_wt_tbl.exists(pLineId)
	     OR
	     not g_vol_tbl.exists(pLineId)
	   ) then

	-- begin bugfix 1811007

	DECLARE

        	o_weight_uom	MTL_SYSTEM_ITEMS.weight_uom_code%TYPE;
		o_volume_uom	MTL_SYSTEM_ITEMS.weight_uom_code%TYPE;
        	o_weight    	number  := 0;
        	o_volume   	number  := 0;
        	x_status   	number  := 0;
        	lShippingOrg   	number  ;

	BEGIN

		lStmtNumber := 90.1;

		-- Get the weight and volume UOM of the model from the OE:Validation org.

		select i.weight_uom_code, i.volume_uom_code
		into   o_weight_uom, o_volume_uom
		from   mtl_system_items i,
	               bom_cto_order_lines l
		where  l.line_id = pLineId		-- model line id
		and    l.inventory_item_id = i.inventory_item_id
		and    i.organization_id = lValidationOrg;



		-- If weight UOM is not defined for the base model, then we will get the
		-- base UOM of the uom class of the components.
		-- Assumption is that weight of all the options belong to the same class.
		-- Eg. C_OPTION 7 (kg) and C_OPTION 9 (Lbs).

        	IF o_weight_uom IS NULL THEN
	  	     IF PG_DEBUG <> 0 THEN
	  	     	oe_debug_pub.add('Create_Item: ' || '=>Weight UOM is null for the base model.',2);

	  	     	oe_debug_pub.add('Create_Item: ' || '=>Trying to get the base UOM ...',2);
	  	     END IF;

	 	     begin
			select  uom_code
	       		into    o_weight_uom
	       		from    mtl_units_of_measure
	       		where   uom_class = (select uom1.uom_class
			          from   mtl_units_of_measure uom1,
				         mtl_system_items i,
				         bom_cto_order_lines l
			          where  l.parent_ato_line_id = pLineId
						-- mbsk: replaced ato_line_id with parent_ato_line_id
        		          and    l.item_type_code not in ('INCLUDED', 'CONFIG')
			          and    l.inventory_item_id = i.inventory_item_id
			          and    i.organization_id = lValidationOrg
			          and    i.weight_uom_code is not null
			          and    i.weight_uom_code = uom1.uom_code
			          and    rownum = 1 )
	       		and     base_uom_flag = 'Y';
	      	     exception
 	       		when no_data_found then
		     		null;
	      	     end;
		END IF;

		-- If volume UOM is not defined for the base model, then we will get the
		-- base UOM for the uom class of the components.
		-- Assumption is that volume of all the options belong to the same class.
		-- Eg. C_OPTION 7 (cubic meter) and C_OPTION 9 (cubic feet).

       		IF o_volume_uom IS NULL THEN
	  	     IF PG_DEBUG <> 0 THEN
	  	     	oe_debug_pub.add('Create_Item: ' || '=>Volume UOM is null for the base model.',2);

	  	     	oe_debug_pub.add('Create_Item: ' || '=>Trying to get the base UOM ...',2);
	  	     END IF;

	      	     begin
	       		select  uom_code
	       		into    o_volume_uom
	       		from    mtl_units_of_measure
	       		where   uom_class = (select uom1.uom_class
			          from   mtl_units_of_measure uom1,
				         mtl_system_items i,
				         bom_cto_order_lines l
			          where  l.parent_ato_line_id = pLineId
						-- mbsk: replaced ato_line_id with parent_ato_line_id
        		          and    l.item_type_code not in ('INCLUDED', 'CONFIG')
			          and    l.inventory_item_id = i.inventory_item_id
			          and    i.organization_id = lValidationOrg
			          and    i.volume_uom_code is not null
			          and    i.volume_uom_code = uom1.uom_code
			          and    rownum = 1 )
	       		and     base_uom_flag = 'Y';
	      	     exception
 	       		when no_data_found then
		     		null;
	      	     end;
		END IF;



		-- We need to call Ato_Weight_Volume API only once because Weight/Vol will be
		-- calculated on the basis of Shipping Orgn. It will be same for all other organizations.
		-- We will update the wt/vol for other orgs after the IF clause.

		-- If the lower level config's wt or vol was not calculated, then, we should not calculate
		-- the wt or vol for the top level config.


		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_Item: ' || 'Calling Ato_Weight_Volume API with following parameters..',2);

			oe_debug_pub.add('Create_Item: ' || '=>Line Id   : '||pLineId,2);

			oe_debug_pub.add('Create_Item: ' || '=>OE Validn Orgn Id   : '||lValidationOrg,2);

			oe_debug_pub.add('Create_Item: ' || '=>Weight UOM: '||o_weight_uom,2);

			oe_debug_pub.add('Create_Item: ' || '=>Volume UOM: '||o_volume_uom,2);
		END IF;

		Ato_Weight_Volume(
                	p_ato_line_id	=> pLineId,
                	p_orgn_id    	=> lValidationOrg,
                	weight_uom      => o_weight_uom,
                	weight          => o_weight,
                	volume_uom      => o_volume_uom,
                	volume          => o_volume,
                	status          => x_status,
			pConfigId       => pConfigId);--3737772 (FP 3473737)

		if x_status <> 0 then
	   		raise FND_API.G_EXC_ERROR;
		end if;

		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_Item: ' || 'Successfully executed  Ato_Weight_Volume API with following outputs..',2);

			oe_debug_pub.add('Create_Item: ' || '=>Weight : '||o_weight||' '||o_weight_uom,2);

			oe_debug_pub.add('Create_Item: ' || '=>Volume : '||o_volume||' '||o_volume_uom,2);
		END IF;


		-- Update the config's weight and volume.

		--  begin bugfix 2905835: Before updating the weight in other organizations, we will convert
		--  the weight of the config in the model's weight UOM in that organization.

		lStmtNumber := 95;

		-- bugfix 4143695: Update MSI only if the weight UOM is not null.
		-- Added IF clause
		-- bugfix 5623437:
		-- Added "and a.unit_weight is null" condition so that weight/vol is updated
		-- only if it is not already calculated.

		if (o_weight_uom is not null) then
		   update mtl_system_items a
		   set    (unit_weight, weight_uom_code) =
		  	(select CTO_UTILITY_PK.convert_uom(
						o_weight_uom,
						nvl( b.weight_uom_code, o_weight_uom) ,  -- bug# 3358194
						o_weight,
						b.inventory_item_id)
			 	,nvl(b.weight_uom_code, o_weight_uom)  -- bug# 3358194
		   	from   mtl_system_items b
		   	where  b.inventory_item_id = a.base_item_id
		   	and    b.organization_id = a.organization_id)
		   where  a.inventory_item_id = pConfigId
		   and    a.unit_weight is null;   -- bugfix 5623437
		end if;

		if (o_volume_uom is not null) then 		-- begin bugfix 4143695
		   update mtl_system_items a
		   set    (unit_volume, volume_uom_code) =
		  	(select CTO_UTILITY_PK.convert_uom(
						o_volume_uom,
						nvl(b.volume_uom_code, o_volume_uom),  -- bug# 3358194
						o_volume,
						b.inventory_item_id)
			 	,nvl(b.volume_uom_code, o_volume_uom)  -- bug# 3358194
		   	from   mtl_system_items b
		   	where  b.inventory_item_id = a.base_item_id
		   	and    b.organization_id = a.organization_id)
		   where  a.inventory_item_id = pConfigId
    		   and    a.unit_volume is null;			-- bugfix 5623437;
		end if;


		--  end bugfix 2905835

        END;
	end if; 	/* end check CTO_CONFIG_ITEM_PK.gWtStatus */

        -- end bugfix 1811007


       oe_debug_pub.add('Create_Item: ' || 'going to insert:mtl_system_items_tl',2);

        /*----------------------------------------+
        R11.5 MLS
        +----------------------------------------*/

        lStmtNumber := 90;

        insert into mtl_system_items_tl (
                inventory_item_id,
                organization_id,
                language,
                source_lang,
                description,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
                )
        select distinct
                pConfigId,
                m.organization_id,
                l.language_code,
                userenv('LANG'),
                m.description,
                sysdate,
                gUserId,                              --last_updated_by
                sysdate,
                gUserId,                              --created_by
                gLoginId                              --last_update_login
/*
commented for reintroduction of bcso
        from
                mtl_system_items_tl m, 				-- 2457514
                fnd_languages  l
        where  m.inventory_item_id = pModelId
        and  l.installed_flag In ('I', 'B')
        and  l.language_code  = m.language			-- 2457514
        and  NOT EXISTS
                (select NULL
                from  mtl_system_items_tl  t
                where  t.inventory_item_id = pConfigId
                and  t.organization_id = m.organization_id
                and  t.language = m.language );
*/
        from
                -- bugfix 2457514 mtl_system_items_b  m,            -- Model
                mtl_system_items_tl m,                          -- 2457514
                bom_cto_src_orgs bcso,
                fnd_languages  l
        where  m.inventory_item_id = pModelId
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
	and m.organization_id = bcso.organization_id
        and  l.installed_flag In ('I', 'B')
        and  l.language_code  = m.language                      -- 2457514
        and  NOT EXISTS
                (select NULL
                from  mtl_system_items_tl  t
                where  t.inventory_item_id = pConfigId
                and  t.organization_id = m.organization_id
                and  t.language = l.language_code );


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:mtl_system_items_tl',2);
	END IF;





      /*
      **
      ** This section has been moved to CTO_ITEM_PK
      **



        --
        -- create sourcing rules if necessary
        --

	lStmtNumber := 100;

	FOR v_src_rule IN c_copy_src_rules LOOP
                --
                -- call API to copy sourcing rules from model item
                -- to config item
                --
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'Copying src rule for cfg item '||to_char(pConfigId)||' in org '||to_char(v_src_rule.rcv_org_id), 2);
		END IF;
		CTO_UTILITY_PK.Create_Sourcing_Rules(
				pModelItemId	=> pModelId,
				pConfigId	=> pConfigId,
				pRcvOrgId	=> v_src_rule.rcv_org_id,
				x_return_status	=> lReturnStatus,
				x_msg_count	=> xMsgCount,
				x_msg_data	=> xMsgData);

		IF (lReturnStatus = fnd_api.G_RET_STS_ERROR) THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('Create_Item: ' || 'Create_Sourcing_Rules returned with expected error.');
			END IF;
	   		raise FND_API.G_EXC_ERROR;

		ELSIF (lReturnStatus = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
			IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add ('Create_Item: ' || 'Create_Sourcing_Rules returned with unexp error.');
			END IF;
	   		raise FND_API.G_EXC_UNEXPECTED_ERROR;

		END IF;

        END LOOP;


        --
        -- update bom_cto_order_lines with new config item
        --

	lStmtNumber := 120;
        lStatus := CTO_UTILITY_PK.Update_Order_Lines(
                        pLineId		=> pLineId,
                        pModelId	=> pModelId,
                        pConfigId	=> pConfigId);

        IF lStatus <> 1 THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('Create_Item: ' || 'Failed in  Update_Order_Lines function',1);
                END IF;
	    	raise FND_API.G_EXC_ERROR;
        END IF;



        --
        -- update bom_cto_src_orgs with new config item
        --

	lStmtNumber := 130;
        lStatus := CTO_UTILITY_PK.Update_Src_Orgs(
                        pLineId		=> pLineId,
                        pModelId	=> pModelId,
                        pConfigId	=> pConfigId);

        IF lStatus <> 1 THEN
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('Create_Item: ' || 'Failed in  Update_Src_Orgs function',1);
                END IF;
	    	raise FND_API.G_EXC_ERROR;
        END IF;





       */









        --
        -- create item data in related tables
        --

	lStmtNumber := 140;
        lStatus := create_item_data(
                        pModelId,
                        pConfigId,
                        pLineId,
                        p_mode );

        if lStatus <> 1 then
                IF PG_DEBUG <> 0 THEN
                	oe_debug_pub.add ('Create_Item: ' || 'Failed in create_data function',1);
                END IF;
		raise FND_API.G_EXC_ERROR;
        end if;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('Create_Item: ' || 'Success in create_data function',1);
        END IF;

        return(1);

EXCEPTION

        WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item::ndf::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => xMsgCount,
                  p_msg_data  => xMsgData
                );
                return(0);

	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item::exp error::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => xMsgCount,
                  p_msg_data  => xMsgData
                );
                return(0);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item::unexp error::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => xMsgCount,
                  p_msg_data  => xMsgData
                );
                return(0);

        WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item::others::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
                CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => xMsgCount,
                  p_msg_data  => xMsgData
                );
                return(0);

END Create_Item;

--begin bugfix 1811007

PROCEDURE Ato_Weight_Volume(
                p_ato_line_id   IN      NUMBER,
                p_orgn_id       IN      NUMBER,
                weight_uom      IN OUT NOCOPY  VARCHAR2, /* NOCOPY Project */
                weight          OUT NOCOPY    NUMBER,
                volume_uom      IN OUT NOCOPY  VARCHAR2, /* NOCOPY Project */
                volume          OUT NOCOPY    NUMBER,
                status          IN OUT  NOCOPY  NUMBER,  /* NOCOPY Project */
		pConfigId       IN      NUMBER)--3737772 (FP 3473737)
is

  -- The two cursors ato_weight and ato_volume have the
  -- same WHERE clause. The only difference is weight vs. volume.
  -- CTO_UTILITY_PK.convert_uom is a wrapper for INV_CONVERT.inv_um_convert to translate
  -- -9999 (error value) into 0 (no weight/volume).


  -- We need to figure out qty-per and then weight of each component in the shipping org,
  -- and that's why l.ordered_quantity/l_model.ordered_quantity which gives us qty-per.
  -- Weight and Volume calculation is calculated on the basis of Shipping Org.

  -- This API is called for each ATO model in a multi-level ATO configuration starting from the bottom most.
  -- The line-Id passed is the line id of each ATO model.
  -- The weight of the each independent ATO configuration is calculated starting from bottom to determine the
  -- weight of that configuration. This then is added to the next higher level ATO to calculate the weight
  -- of the next higher configuration and so on until the weight of the top model ATO is calculated.

  -- bugfix 2301167: added inventory_item_id in the select list as well as in group by clause.
  -- This will make sure that item specific conversions take precedence over standard conversions.
  -- Also, for inter-class conversions, item-id is required.
  -- Also added "weight_uom_code is not null" and "unit_weight is not null" condition to filter out
  -- items for which these have not been defined.


  CURSOR ato_weight(x_a_line_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_weight, 0) *
                 CTO_UTILITY_PK.convert_uom(l.order_quantity_uom,
                                            msi.primary_uom_code,
                                            Round( ( l.ordered_quantity / l_model.ordered_quantity), 7) ,  /* Support Decimal-Qty for Option Items */
                                            l.inventory_item_id) ) weight,
            msi.weight_uom_code  uom,
	    msi.inventory_item_id
       FROM bom_cto_order_lines  l,
            bom_cto_order_lines  l_model,
            mtl_system_items    msi
      WHERE (l.parent_ato_line_id = x_a_line_id
			-- MLMO:replaced ato_line_id with parent_ato_line_id  and added OR condn
		or
            l.line_id = x_a_line_id)
        --  Bugfix 2576422
	--  joining l_model.line_id to l.parent_ato_line_id so that
	--  qty per will be calculated correctly for multi-level configuration
	--  AND l_model.line_id = l.top_model_line_id
	--  MLMO:replaced x_a_line_id with l.top_model_line_id
	AND l_model.line_id = l.parent_ato_line_id
	-- End bugfix 2576422
	AND l.item_type_code not in ('INCLUDED', 'CONFIG')
        AND msi.inventory_item_id = decode(l.config_item_id, null,l.inventory_item_id,
	                                   --3737772 (FP 3473737)
	                                   pConfigId,l.inventory_item_id, l.config_item_id )
							-- MLMO: added decode/config_item_id condn
        AND msi.organization_id = p_orgn_id
	AND msi.weight_uom_code is not null
	AND nvl(msi.unit_weight, 0) <> 0 	-- bugfix 2905835: changed "is not null" to <> 0
      GROUP BY msi.inventory_item_id,
	       msi.weight_uom_code;



  CURSOR ato_volume(x_a_line_id NUMBER) IS
     SELECT SUM( NVL(msi.unit_volume, 0) *
                 CTO_UTILITY_PK.convert_uom(l.order_quantity_uom,
                                            msi.primary_uom_code,
                                            Round( ( l.ordered_quantity / l_model.ordered_quantity) , 7) , /* Support Decimal-Qty for Option Items */
                                            l.inventory_item_id) ) volume,
            msi.volume_uom_code  uom,
	    msi.inventory_item_id
       FROM bom_cto_order_lines  l,
            bom_cto_order_lines  l_model,
            mtl_system_items    msi
      WHERE (l.parent_ato_line_id = x_a_line_id		-- MLMO: replaced ato_line_id with parent_ato_line_id
		or
            l.line_id = x_a_line_id)
        --  Bugfix 2576422
	--  joining l_model.line_id to l.parent_ato_line_id so that
	--  qty per will be calculated correctly for multi-level configuration
	--  AND l_model.line_id = l.top_model_line_id
	-- MLMO:replaced x_a_line_id with l.top_model_line_id
	AND l_model.line_id = l.parent_ato_line_id
	-- End bugfix 2576422
	AND l.item_type_code not in ('INCLUDED', 'CONFIG')
        AND msi.inventory_item_id = decode(l.config_item_id, null, l.inventory_item_id,
	                                    --3737772 (FP 3473737)
	                                    pConfigId,l.inventory_item_id,l.config_item_id )
							-- MLMO: added decode/config_item_id condn
        AND msi.organization_id = p_orgn_id
	AND msi.volume_uom_code is not null
	AND nvl(msi.unit_volume,0) <> 0		-- bugfix 2905835 : changed "is not null" to <> 0
      GROUP BY msi.inventory_item_id,
	       msi.volume_uom_code;

  lStmtNumber    number := 0;
  lMsgCount	 number;
  lMsgData	 varchar2(2000);
  lweight 	 number := 0;
  lvolume 	 number := 0;


BEGIN

        weight := 0;
        volume := 0;
        status := 0;


    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('Create_Item: ' || 'Inside Ato_Weight_Volume API with p_ato_line_id = '||p_ato_line_id,1);
		oe_debug_pub.add ('Create_Item: ' || 'Inside Ato_Weight_Volume API with pConfigId = '||pConfigId,1);

    	END IF;

	lStmtNumber := 1205;

        -- bugfix 2301167: Calculate the config's wt if the previous calculation of lower level config was
	-- successful. gWtStatus would be set to -1 if calculation was not successful.

	--Bugfix 9223554: Changed the logic.
	--if CTO_CONFIG_ITEM_PK.gWtStatus = 0 then
	if not g_wt_tbl.exists(p_ato_line_id) then

    	   IF PG_DEBUG <> 0 THEN
    	   	oe_debug_pub.add ('Create_Item: ' || '===>weight_uom = '||weight_uom,1);
    	   END IF;

           FOR aw IN ato_weight(p_ato_line_id)
	   loop

    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add ('Create_Item: ' || '===>aw.weight = '||aw.weight||' uom = '||aw.uom||' for item_id '||aw.inventory_item_id,1);
    		END IF;
		-- Bugfix 2301167: Added item_id as a parameter so that item specific conversions take precedence if defined.
		lweight := CTO_UTILITY_PK.convert_uom(
						from_uom	=> aw.uom,
						to_uom		=> weight_uom,
						quantity	=> aw.weight,
						item_id		=> aw.inventory_item_id);
		--Bugfix 9214765: Changing the if condition
		--if lweight = 0 then
		IF PG_DEBUG <> 0 THEN
    		  oe_debug_pub.add ('Create_Item: lweight:' || lweight, 1);
    		END IF;

		if lweight = -99999 then
    			IF PG_DEBUG <> 0 THEN
    				oe_debug_pub.add ('Create_Item: ' || '===>convert_uom returned -99999(error). Not calculating weight. Check if all conversions have been defined.', 1);
    			END IF;
			-- we don't want to update the weight of the config incorrectly, so set it to 0.
			weight := 0;

			-- Also, we shouldn't calculate the wt for the top config since the lower level's config
			-- weight has been updated to 0

			--Bugfix 9223554
		        --CTO_CONFIG_ITEM_PK.gWtStatus := -1;	 -- -1 means error
			update_wt_vol_tbl(p_tbl_type => 1,
			                  p_line_id  => p_ato_line_id);

			exit;
		end if;
                weight := weight + lweight;

          end loop;
        end if;


    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add ('Create_Item: ' || '---------------------',1);
    	END IF;

	lStmtNumber := 1210;

        -- bugfix 2301167: Calculate the config's wt if the previous calculation of lower level config was
	-- successful. gWtStatus would be set to -1 if calculation was not successful.

	--Bugfix 9223554: Changed the logic.
	--if CTO_CONFIG_ITEM_PK.gVolStatus = 0 then
	if not g_vol_tbl.exists(p_ato_line_id) then

    	   IF PG_DEBUG <> 0 THEN
    	   	oe_debug_pub.add ('Create_Item: ' || '===>volume_uom = '||volume_uom,1);
    	   END IF;

           FOR av IN ato_volume(p_ato_line_id)
	   loop
    		IF PG_DEBUG <> 0 THEN
    			oe_debug_pub.add ('Create_Item: ' || '===>av.volume = '||av.volume||' uom = '||av.uom||' for item_id '||av.inventory_item_id,1);
    		END IF;
		-- Bugfix 2301167: Added item_id as a parameter so that item specific conversions take precedence if defined.
		lvolume := CTO_UTILITY_PK.convert_uom(
						from_uom	=> av.uom,
						to_uom		=> volume_uom,
						quantity	=> av.volume,
						item_id		=> av.inventory_item_id);
		--Bugfix 9214765: Changing the if condition
		--if lvolume = 0 then
		IF PG_DEBUG <> 0 THEN
    		  oe_debug_pub.add ('Create_Item: lvolume:' || lvolume, 1);
    		END IF;

		if lvolume = -99999 then
    			IF PG_DEBUG <> 0 THEN
    				oe_debug_pub.add ('Create_Item: ' || '===>convert_uom returned -99999(error). Not calculating volume. Check if all conversions have been defined.', 1);
    			END IF;
			-- we don't want to update the volume of the config incorrectly, so set it to 0.
			volume := 0;

			-- Also, we shouldn't calculate the vol for the top config since the lower level's config
			-- volume has been updated to 0

			--Bugfix 9223554
		        --CTO_CONFIG_ITEM_PK.gVolStatus := -1;	 -- -1 means error
			update_wt_vol_tbl(p_tbl_type => 2,
			                  p_line_id  => p_ato_line_id);

			exit;
		end if;
                volume := volume + lvolume;

           end loop;
	end if;

EXCEPTION
WHEN OTHERS THEN
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('Create_Item: ' || 'ERROR: Ato_Weight_Volume::others::'||to_char(lStmtNumber)||':-'||sqlerrm,1);
    END IF;
    CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
    status := -1;

End Ato_Weight_Volume;

--end bugfix 1811007



FUNCTION Create_Item_Data(
        pModelId         in     number,
        pConfigId        in     number,
        pLineId          in     number,
        p_mode          in     varchar2 default 'AUTOCONFIG' )
return integer
is

   lValidationOrg    number;
   lShipFromOrg	     number;
   lStmtNumber       number;
   l_cost_group_id   number;
   lProfileVal       number;
   lOpUnit           number;
   l_layer_id	     number;
   lMsgCount	     number;
   lMsgData	     varchar2(2000);
   x_err_num	     number;
   x_msg_name	     varchar2(240);
   xReturnStatus     VARCHAR2(1);  --Bugfix 6063990

   -- x_item_rev_seq    number; bugfix 3026929

   multiorg_error    exception;
   v_program_id      bom_cto_order_lines.program_id%type ;

   l_cto_cost_type_id	number;

   lCnt              number;  --Bugfix 6717614

   CURSOR c_layer IS
   select distinct
      MP1.organization_id org_id,
      DECODE(MP1.ORGANIZATION_ID, lShipFromOrg ,l_cost_group_id,1) cost_group_id
/*
commented due to reintroduction of bcso
   from mtl_parameters mp1,
        cst_item_costs c,
        mtl_system_items msi
   where c.organization_id       = mp1.organization_id
   and c.inventory_item_id     = pModelId
   and C.COST_TYPE_ID          =  2     -- Average Costing
   and msi.organization_id = mp1.organization_id
   and MP1.Primary_cost_method = 2     -- Create only in Avg costing org
   and NOT EXISTS
   	(select NULL
        from cst_quantity_layers
        where inventory_item_id = pConfigId
        and organization_id = mp1.organization_id);
*/
   from mtl_parameters mp1,
        mtl_parameters mp2,
        cst_item_costs c,
        bom_cto_src_orgs        bcso
   where c.organization_id       = mp1.organization_id
   and c.inventory_item_id     = pModelId
   and C.COST_TYPE_ID          =  2     -- Average Costing
   and bcso.model_item_id = pModelId
   and bcso.line_id = pLineId
   and MP2.organization_id     = bcso.organization_id
   and ((mp1.organization_id = bcso.organization_id) OR
        (mp1.organization_id = mp2.master_organization_id))
   and MP1.Primary_cost_method = 2     -- Create only in Avg costing org
   and NOT EXISTS
        (select NULL
        from cst_quantity_layers
        where inventory_item_id = pConfigId
        and organization_id = mp1.organization_id);


v_material_cost             cst_item_costs.material_cost%type := 0 ;
v_material_overhead_cost    cst_item_costs.material_overhead_cost%type := 0 ;
v_resource_cost             cst_item_costs.resource_cost%type := 0 ;
v_outside_processing_cost   cst_item_costs.outside_processing_cost%type := 0 ;
v_overhead_cost             cst_item_costs.overhead_cost%type := 0 ;


v_item_cost             cst_item_costs.item_cost%type := 0 ;
v_cto_cost_type_name    cst_cost_types.cost_type%type;
v_item_cost_frozen      cst_item_costs.item_cost%type;  --Bugfix 6363308
l_cost_update           number;                         --Bugfix 6363308

--Bugfix 6363308
CURSOR get_orgs_with_frozen_cost ( p_config_item_id NUMBER)
IS
  SELECT  organization_id
        , item_cost
    FROM  cst_item_costs
    WHERE inventory_item_id = p_config_item_id
    AND   cost_type_id = 1;

v_organization_id NUMBER;
--Bugfix 6363308


 Type number_tbl_type IS TABLE OF number INDEX BY BINARY_INTEGER;


 TYPE cicd_summary_rec_tab is record (
                               cost_organization_id     number_tbl_type,
                               cost_type_id             number_tbl_type,
                               material_cost            number_tbl_type,
                               material_overhead_cost   number_tbl_type,
                               resource_cost            number_tbl_type,
                               outside_processing_cost  number_tbl_type,
                               overhead_cost            number_tbl_type,
                               item_cost                number_tbl_type ) ;




 l_rt_cicd_summary cicd_summary_rec_tab ;

 --kkonada R12
 --for mtl_cross_references_b
 --bug# 4539578

  TYPE org_id			IS TABLE OF mtl_cross_references_b.organization_id%type;
  TYPE cross_reference_type     IS TABLE OF mtl_cross_references_b.cross_reference_type%type;
  TYPE cross_reference          IS TABLE OF mtl_cross_references_b.cross_reference%type;
  TYPE org_independent_flag     IS TABLE OF mtl_cross_references_b.org_independent_flag%type;


  t_organization_id		org_id;
  t_cross_ref_type		cross_reference_type;
  t_cross_ref			cross_reference;
  t_org_independent_flag	org_independent_flag;


BEGIN


        /* added by Sushant to check preconfigure bom populated records */
        select nvl( program_id , 0 ) into v_program_id
          from bom_cto_order_lines
          where line_id = pLineId ;


    	lStmtNumber := 200;

        if ( v_program_id = CTO_UTILITY_PK.PC_BOM_PROGRAM_ID ) then

		lValidationOrg := CTO_UTILITY_PK.PC_BOM_VALIDATION_ORG ;

        else

               /*
                BUG:3484511
                -------------

		select nvl(master_organization_id, -99)		--bugfix 2646849: added nvl.
		into   lValidationOrg
		from   oe_order_lines_all oel,
		       oe_system_parameters_all ospa
       		where  oel.line_id = pLineid
       		and    nvl(oel.org_id, -1) = nvl(ospa.org_id, -1) --bug 1531691
       		and    oel.inventory_item_id = pModelId;
                */


               IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' ||  'Going to fetch Validation Org ' ,2);
               END IF;


              select nvl( oe_sys_parameters.value( 'MASTER_ORGANIZATION_ID' , oel.org_id) , -99)
                into lValidationOrg from oe_order_lines_all oel
               where oel.line_id = pLineId ;


        end if ;


    	IF PG_DEBUG <> 0 THEN
    		oe_debug_pub.add('Create_Item: ' ||  'After getting validation org',2);
    	END IF;

    	if lVAlidationOrg = -99 then				-- bugfix 2646849
      		cto_msg_pub.cto_message('BOM','CTO_VALIDATION_ORG_NOT_SET');
		RAISE FND_API.G_EXC_ERROR;
    	end if;


	/*------------------------------------------+
           Create rows for config items
           in the MTL_PENDING_ITEM_STATUS
        +------------------------------------------*/

        lStmtNumber := 205;

        IF PG_DEBUG <> 0 THEN
        	oe_debug_pub.add ('Create_Item: ' ||  'Validation Org is :' || lValidationOrg ,2);
        END IF;

        insert into MTL_PENDING_ITEM_STATUS (
                inventory_item_id,
                organization_id,
                status_code,
                effective_date,
                pending_flag,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                program_application_id,
                program_id,
                program_update_date,
                request_id)
        select distinct
                pConfigId,
                m.organization_id,
                m.inventory_item_status_code,
                sysdate,
                'N',
                sysdate,
                gUserId,
                sysdate,
                gUserId,
                gLoginId,
                null,
                null,
                sysdate,
                null                    --  req_id
        from   mtl_system_items m,
               bom_cto_src_orgs        bcso
        where  m.inventory_item_id = pModelId
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and m.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from MTL_PENDING_ITEM_STATUS
                where inventory_item_id = pConfigId
                and organization_id = m.organization_id);



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:MTL_PENDING_ITEM_STATUS',2);
	END IF;

        /*-------------------------------------------+
          Insert Item revision information
        +-------------------------------------------*/

        lStmtNumber := 210;

	/* Begin Bugfix 6063990: Commenting out this part as this will no longer be used.
           We will call populate_item_revision procedure directly

	--
	-- bugfix 3026929 : To avoid dependencies with INV/BOM, we made this code change.
	-- We will first try to insert into MIR. If this fails, we will insert into MIR_b and _tl using dynamic stmt.
	-- We need to use dynamic stmt to avoid compilation errors in pre-I instances.
	-- We did not use ALL_OBJECTS since this *may* not accessible from APPS schema.
	-- This change supersedes bugfix 2730055
	--

	DECLARE
		non_key_preserved_error		EXCEPTION;
		PRAGMA exception_init (non_key_preserved_error, -1779);
		xReturnStatus			VARCHAR2(1);
	BEGIN

        insert into mtl_item_revisions
              (inventory_item_id,
               organization_id,
               revision,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               implementation_date,
               effectivity_date
              )
        select distinct
               pConfigId,
               m.organization_id,
               mp1.starting_revision,
               sysdate,
               gUserId,                     -- last_updated_by
               sysdate,
               gUserId,                     -- created_by
               gLoginId,                    -- last_update_login
               sysdate,
               sysdate
        from
                mtl_system_items m,
                bom_cto_src_orgs        bcso,
		mtl_parameters mp1
        where  m.inventory_item_id = pModelId
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and m.organization_id = bcso.organization_id
	and mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                 from MTL_ITEM_REVISIONS
                where inventory_item_id = pConfigId
                and organization_id = m.organization_id);



        IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item_Data: ' || 'after insert:MTL_ITEM_REVISIONS',2);
	END IF;

	EXCEPTION
		when NON_KEY_PRESERVED_ERROR then

        		IF PG_DEBUG <> 0 THEN
			   oe_debug_pub.add('Create_item_data: NON_KEY_PRESERVED_ERROR exception. Hence, calling populate_item_revision.. ',2);
			   oe_debug_pub.add('Create_item_data: NON_KEY_PRESERVED_ERROR exception. model Model ' || pModelId ,2);
			   oe_debug_pub.add('Create_item_data: NON_KEY_PRESERVED_ERROR exception. model Line ' || pLineId ,2);
			   oe_debug_pub.add('Create_item_data: NON_KEY_PRESERVED_ERROR exception. model Config ' || pConfigId ,2);
			END IF;

			populate_item_revision (pConfigId, pModelId, pLineId, xReturnStatus);

			IF (xReturnStatus <> fnd_api.G_RET_STS_SUCCESS) THEN
			   oe_debug_pub.add('Create_item_data : failed in populate_item_revision : '||substrb(sqlerrm,1,60),2);
                           raise FND_API.G_EXC_UNEXPECTED_ERROR;

			ELSE
        		   IF PG_DEBUG <> 0 THEN
				oe_debug_pub.add('Create_item_data: done populate_item_revision successfully.',2);
			   END IF;
			END IF;

		when OTHERS then
			oe_debug_pub.add('Create_item_data: Failed while inserting into MTL_ITEM_REVISIONS: '||substrb(sqlerrm,1,60),2);
			raise FND_API.G_EXC_UNEXPECTED_ERROR;
	END;*/

	 populate_item_revision (pConfigId, pModelId, pLineId, xReturnStatus);  --Bugfix 6063990

        IF (xReturnStatus <> fnd_api.G_RET_STS_SUCCESS) THEN
	  oe_debug_pub.add('Create_item_data : failed in populate_item_revision : '||substrb(sqlerrm,1,60),2);
          raise FND_API.G_EXC_UNEXPECTED_ERROR;

	ELSE
    	  IF PG_DEBUG <> 0 THEN
	    oe_debug_pub.add('Create_item_data: done populate_item_revision successfully.',2);
	  END IF;
	END IF;
        --End Bugfix 6063990.

      	/*----------------------------------------------------------+
         Insert cost records for config items
         The cost organization id is either the organization id
         or the master organization id
      	+----------------------------------------------------------*/


        lStmtNumber := 213;

        /* FIX to avoid rolled up cost of model from being included during cost rollup */
        /* Fix for bug 4172300. cost in validation org is not copied properly from model to config item */

	--apps perf bug#	4905845, sql id 16104498
        select C.organization_id,
               C.cost_type_id,
               nvl(sum(decode( cicd.cost_element_id, 1 , nvl(cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,2 , nvl( cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,3 , nvl( cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,4 , nvl( cicd.item_cost, 0 ) )) , 0 ),
               nvl( sum(decode( cicd.cost_element_id,5 , nvl( cicd.item_cost, 0 ) ))  , 0 )
BULK COLLECT INTO
               l_rt_cicd_summary.cost_organization_id,
               l_rt_cicd_summary.cost_type_id,
               l_rt_cicd_summary.material_cost,
               l_rt_cicd_summary.material_overhead_cost,
               l_rt_cicd_summary.resource_cost,
               l_rt_cicd_summary.outside_processing_cost,
               l_rt_cicd_summary.overhead_cost
        from
                mtl_parameters        MP1,
                cst_item_costs        C,
                cst_item_cost_details CICD,
                mtl_system_items      S --  4172300
        where   S.organization_id   = C.organization_id
        and     S.inventory_item_id = C.inventory_item_id
        and     C.organization_id   = MP1.organization_id
        and     C.inventory_item_id = pModelId
        and     C.inventory_item_id = S.inventory_item_id
        and     C.COST_TYPE_ID  IN ( MP1.primary_cost_method, MP1.avg_rates_cost_type_id)
        and     C.inventory_item_id = CICD.inventory_item_id(+)
        and     C.organization_id  = CICD.organization_id(+)
        and     C.cost_type_id = CICD.cost_type_id(+)
        and     CICD.rollup_source_type(+) = 1      -- User Defined
        --4172300
        and     MP1.organization_id in ( select distinct MP2.cost_organization_id
                                             from mtl_parameters mp2, mtl_parameters mp3, bom_cto_src_orgs bcso
                                            where bcso.model_item_id = pModelId
                                              and bcso.line_id = pLineId
                                              and MP3.organization_id = bcso.organization_id
                                              and ((mp2.organization_id = bcso.organization_id) OR
                                                  (mp2.organization_id = mp3.master_organization_id))
                                         )
        and NOT EXISTS
                (select NULL
                from CST_ITEM_COSTS
                where inventory_item_id = pConfigId
                and organization_id = mp1.cost_organization_id
                and cost_type_id  in (mp1.primary_cost_method, mp1.avg_rates_cost_type_id))
        group by C.organization_id, C.cost_type_id; -- 4172300


        lStmtNumber := 214;



       if( l_rt_cicd_summary.cost_organization_id.count > 0 ) then
           for i in l_rt_cicd_summary.cost_organization_id.first..l_rt_cicd_summary.cost_organization_id.last
           loop

               oe_debug_pub.add( i || ') ' || 'Cost Header Info: ' ||
                         ' cst org ' || l_rt_cicd_summary.cost_organization_id(i) ||
                         ' cst id ' || l_rt_cicd_summary.cost_type_id(i) ||
                         ' m cost ' || l_rt_cicd_summary.material_cost(i) ||
                         ' moh cost ' || l_rt_cicd_summary.material_overhead_cost(i) ||
                         ' rsc cost ' || l_rt_cicd_summary.resource_cost(i) ||
                         ' osp cost ' || l_rt_cicd_summary.outside_processing_cost(i) ||
                         ' ovh cost ' || l_rt_cicd_summary.overhead_cost(i) , 1 );



               l_rt_cicd_summary.item_cost(i) := l_rt_cicd_summary.material_cost(i) + l_rt_cicd_summary.material_overhead_cost(i)
                                        + l_rt_cicd_summary.resource_cost(i) + l_rt_cicd_summary.outside_processing_cost(i)
                                        + l_rt_cicd_summary.overhead_cost(i) ;



               oe_debug_pub.add( ' item cost ' || l_rt_cicd_summary.item_cost(i) , 1 );


            end loop ;


        else


               oe_debug_pub.add( ' no new item cost records for  ' || pConfigId  , 1 );

        end if;

      	/*-------------------------------------------------------+
        Insert a row into the cst_item_costs_table
      	+------------------------------------------------------- */

      	lStmtNumber := 220;

      	insert into CST_ITEM_COSTS
            	(inventory_item_id,
             	organization_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	inventory_asset_flag,
             	lot_size,
             	based_on_rollup_flag,
             	shrinkage_rate,
             	defaulted_flag,
             	cost_update_id,
             	pl_material,
             	pl_material_overhead,
             	pl_resource,
             	pl_outside_processing,
             	pl_overhead,
             	tl_material,
             	tl_material_overhead,
             	tl_resource,
             	tl_outside_processing,
             	tl_overhead,
             	material_cost,
             	material_overhead_cost,
             	resource_cost,
             	outside_processing_cost ,
             	overhead_cost,
             	pl_item_cost,
             	tl_item_cost,
             	item_cost,
             	unburdened_cost ,
             	burden_cost,
             	attribute_category,
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
      	select distinct
		pConfigId,                -- INVENTORY_ITEM_ID
             	mp1.cost_organization_id,
             	c.cost_type_id,
             	sysdate,                  -- last_update_date
             	-1,                       -- last_updated_by
             	sysdate,                  -- creation_date
             	-1,                       -- created_by
             	-1,                       -- last_update_login
             	C.inventory_asset_flag,
             	C.lot_size,
             	C.based_on_rollup_flag,
             	C.shrinkage_rate,
             	C.defaulted_flag,
             	NULL,                     -- cost_update_id
             	0,                        -- C.pl_material,
             	0,                        -- C.pl_material_overhead,
             	0,                        -- C.pl_resource,
             	0,                        -- C.pl_outside_processing,
             	0,                        -- C.pl_overhead,
             	v_material_cost,          -- C.tl_material,
             	v_material_overhead_cost, -- C.tl_material_overhead,
             	v_resource_cost,          -- C.tl_resource,
             	v_outside_processing_cost, -- C.tl_outside_processing,
             	v_overhead_cost,          --C.tl_overhead,
             	v_material_cost,            -- material_cost
             	v_material_overhead_cost,   -- material_overhead_cost
             	v_resource_cost,            -- resource_cost
             	v_outside_processing_cost,  -- outside_processing_cost
             	v_overhead_cost,            -- overhead_cost
             	0,                        -- C.pl_item_cost,
             	v_item_cost,              -- C.tl_item_cost,
             	v_item_cost,              -- C.item_cost,
             	0,                        -- C.unburdened_cost ,
             	v_material_overhead_cost, -- C.burden_cost,  /* check with rixin */
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.ATTRIBUTE12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
        from
                mtl_parameters MP1,
                cst_item_costs C,
                mtl_system_items S,
                bom_cto_src_orgs bcso
        where  S.organization_id   = C.organization_id
        and    S.inventory_item_id = C.inventory_item_id
        and    C.inventory_item_id = pModelId
        and    C.inventory_item_id = S.inventory_item_id
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and    C.cost_type_id  in ( mp1.primary_cost_method, mp1.avg_rates_cost_type_id)
        and    C.organization_id   = MP1.organization_id
	and    mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from CST_ITEM_COSTS
                where inventory_item_id = pConfigId
                and organization_id = mp1.organization_id
                and cost_type_id  in (mp1.primary_cost_method, mp1.avg_rates_cost_type_id));


        --Bugfix 6717614
        lCnt := sql%rowcount;
        --Bugfix 6717614

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || ' config item ' || pConfigId || ' after insert:CST_ITEM_COSTS inserted '|| to_char(lCnt),2);
	END IF;


        if( l_rt_cicd_summary.cost_type_id.count> 0 ) then
        FORALL j IN 1..l_rt_cicd_summary.cost_type_id.last
              UPDATE cst_item_costs
                 set material_cost = l_rt_cicd_summary.material_cost(j),
                     material_overhead_cost = l_rt_cicd_summary.material_overhead_cost(j),
                     resource_cost = l_rt_cicd_summary.resource_cost(j),
                     outside_processing_cost = l_rt_cicd_summary.outside_processing_cost(j),
                     overhead_cost = l_rt_cicd_summary.overhead_cost(j),
                     tl_material = l_rt_cicd_summary.material_cost(j),
                     tl_material_overhead = l_rt_cicd_summary.material_overhead_cost(j),
                     tl_resource = l_rt_cicd_summary.resource_cost(j),
                     tl_outside_processing = l_rt_cicd_summary.outside_processing_cost(j),
                     tl_overhead = l_rt_cicd_summary.overhead_cost(j),
                     tl_item_cost = l_rt_cicd_summary.item_cost(j),
                     item_cost = l_rt_cicd_summary.item_cost(j),
                     burden_cost = l_rt_cicd_summary.material_overhead_cost(j)
              where inventory_item_id = pConfigId
                and organization_id = l_rt_cicd_summary.cost_organization_id(j)
                and cost_type_id = l_rt_cicd_summary.cost_type_id(j) ;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after update:CST_ITEM_COSTS '|| to_char(sql%rowcount),2);
	END IF;
         else

             oe_debug_pub.add( 'No update required to CST_ITEM_COSTS as no new records inserted ' , 1 ) ;

         end if;







	/* For standard costing orgs, we will copy model's user-defined
	cost in Frozen to the config in CTO cost type. */

       /* begin bugfix 4057651, default CTO cost type id = 7 if it does not exist */
        begin

	   select cost_type_id into l_cto_cost_type_id
             from cst_cost_types
            where cost_type = 'CTO' ;

        exception
        when no_data_found then

	   IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || ' no_data_found error CTO cost type id does not exist',2);
		oe_debug_pub.add('Create_Item: ' || ' defaulting CTO cost type id = 7 ',2);
	   END IF;

           l_cto_cost_type_id := 7 ;

           begin
                select cost_type into v_cto_cost_type_name
                  from cst_cost_types
                 where cost_type_id = l_cto_cost_type_id  ;

	         IF PG_DEBUG <> 0 THEN
		    oe_debug_pub.add('Create_Item: ' || ' cost type id =  ' || l_cto_cost_type_id ||
                                     '  has cost_type =  -' || v_cto_cost_type_name  || '- delimiter(-cost-)' ,2);
	          END IF;
           exception
           when no_data_found then
	         IF PG_DEBUG <> 0 THEN
		    oe_debug_pub.add('Create_Item: ' || ' no_data_found error for cost type id = 7 ',2);
	          END IF;
                 cto_msg_pub.cto_message('BOM','CTO_COST_NOT_FOUND');
                 raise  FND_API.G_EXC_ERROR;
           when others then

              raise  FND_API.G_EXC_UNEXPECTED_ERROR;
           end ;

        when others then
           raise  FND_API.G_EXC_UNEXPECTED_ERROR;
        end ;
       /* end bugfix 4057651, default CTO cost type id = 7 if it does not exist */



      	insert into CST_ITEM_COSTS
            	(inventory_item_id,
             	organization_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	inventory_asset_flag,
             	lot_size,
             	based_on_rollup_flag,
             	shrinkage_rate,
             	defaulted_flag,
             	cost_update_id,
             	pl_material,
             	pl_material_overhead,
             	pl_resource,
             	pl_outside_processing,
             	pl_overhead,
             	tl_material,
             	tl_material_overhead,
             	tl_resource,
             	tl_outside_processing,
             	tl_overhead,
             	material_cost,
             	material_overhead_cost,
             	resource_cost,
             	outside_processing_cost ,
             	overhead_cost,
             	pl_item_cost,
             	tl_item_cost,
             	item_cost,
             	unburdened_cost ,
             	burden_cost,
             	attribute_category,
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
      	select distinct
		pConfigId,                -- INVENTORY_ITEM_ID
             	mp1.cost_organization_id,
             	l_cto_cost_type_id, 	  -- CTO cost_type_id,
             	sysdate,                  -- last_update_date
             	-1,                       -- last_updated_by
             	sysdate,                  -- creation_date
             	-1,                       -- created_by
             	-1,                       -- last_update_login
             	C.inventory_asset_flag,
             	C.lot_size,
             	C.based_on_rollup_flag,
             	C.shrinkage_rate,
             	C.defaulted_flag,
             	NULL,                     -- cost_update_id
             	0,                        -- C.pl_material,
             	0,                        -- C.pl_material_overhead,
             	0,                        -- C.pl_resource,
             	0,                        -- C.pl_outside_processing,
             	0,                        -- C.pl_overhead,
             	v_material_cost,          -- C.tl_material,
             	v_material_overhead_cost, -- C.tl_material_overhead,
             	v_resource_cost,          -- C.tl_resource,
             	v_outside_processing_cost, -- C.tl_outside_processing,
             	v_overhead_cost,           -- C.tl_overhead,
             	v_material_cost,           -- material cost
             	v_material_overhead_cost,  -- material overhead cost
             	v_resource_cost,           -- resource cost
             	v_outside_processing_cost, -- outside processing cost
             	v_overhead_cost,           -- overhead cost
             	0,                       -- C.pl_item_cost,
             	v_item_cost,               -- C.tl_item_cost,
             	v_item_cost,               -- total item cost
             	0,                         -- C.unburdened_cost ,
             	v_material_overhead_cost,   -- C.burden_cost,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.ATTRIBUTE12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
        from
                mtl_parameters MP1,
                cst_item_costs C,
                mtl_system_items S,
                bom_cto_src_orgs bcso
        where  S.organization_id   = C.organization_id
        and    S.inventory_item_id = C.inventory_item_id
        and    C.inventory_item_id = pModelId
        and    C.inventory_item_id = S.inventory_item_id
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and    C.cost_type_id  = mp1.primary_cost_method
        and    C.cost_type_id  = 1
        and    C.organization_id   = MP1.organization_id
	and    mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from CST_ITEM_COSTS
                where inventory_item_id = pConfigId
                and organization_id = mp1.organization_id
                and cost_type_id = l_cto_cost_type_id);



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || ' config item ' || pConfigId || ' after insert UD cost into CTO cost type inserted '|| to_char(sql%rowcount),2);

	END IF;


        if( l_rt_cicd_summary.cost_type_id.count > 0 ) then
        FORALL j IN 1..l_rt_cicd_summary.cost_type_id.last
              UPDATE cst_item_costs
                 set material_cost = l_rt_cicd_summary.material_cost(j),
                     material_overhead_cost = l_rt_cicd_summary.material_overhead_cost(j),
                     resource_cost = l_rt_cicd_summary.resource_cost(j),
                     outside_processing_cost = l_rt_cicd_summary.outside_processing_cost(j),
                     overhead_cost = l_rt_cicd_summary.overhead_cost(j),
                     tl_material = l_rt_cicd_summary.material_cost(j),
                     tl_material_overhead = l_rt_cicd_summary.material_overhead_cost(j),
                     tl_resource = l_rt_cicd_summary.resource_cost(j),
                     tl_outside_processing = l_rt_cicd_summary.outside_processing_cost(j),
                     tl_overhead = l_rt_cicd_summary.overhead_cost(j),
                     tl_item_cost = l_rt_cicd_summary.item_cost(j),
                     item_cost = l_rt_cicd_summary.item_cost(j),
                     burden_cost = l_rt_cicd_summary.material_overhead_cost(j)
              where inventory_item_id = pConfigId
                and organization_id = l_rt_cicd_summary.cost_organization_id(j)
                and cost_type_id = l_cto_cost_type_id  ;


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after update:cst_item_costs for CTO cost type  '||to_char(sql%rowcount),2);
	END IF;

         else

             oe_debug_pub.add( 'No update required to CST_ITEM_COSTS for CTO cost type as no new records inserted ' , 1 ) ;

         end if;





      	/*------ ----------------------------------------------+
         Insert rows into the cst_item_cost_details table
      	+-----------------------------------------------------*/

      	lStmtNumber := 230;

      	insert into cst_item_cost_details
            	(inventory_item_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	organization_id,
             	operation_sequence_id,
             	operation_seq_num,
             	department_id,
             	level_type,
             	activity_id,
             	resource_seq_num,
             	resource_id,
             	resource_rate,
             	item_units,
             	activity_units,
             	usage_rate_or_amount,
             	basis_type,
             	basis_resource_id,
             	basis_factor,
             	net_yield_or_shrinkage_factor,
             	item_cost,
             	cost_element_id,
             	rollup_source_type,
             	activity_context,
             	attribute_category,
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
      	select distinct
		pConfigId,                   -- inventory_item_id
             	c.cost_type_id,
             	sysdate,                     -- last_update_date
             	-1,                          -- last_updated_by
             	sysdate,                     -- creation_date
             	-1,                          -- created_by
             	-1,                          -- last_update_login
             	mp1.cost_organization_id,
             	c.operation_sequence_id,
             	c.operation_seq_num,
             	c.department_id,
             	c.level_type,
             	c.activity_id,
             	c.resource_seq_num,
             	c.resource_id,
             	c.resource_rate,
             	c.item_units,
             	c.activity_units,
             	c.usage_rate_or_amount,
             	c.basis_type,
             	c.basis_resource_id,
             	c.basis_factor,
             	c.net_yield_or_shrinkage_factor,
             	c.item_cost,
             	c.cost_element_id,
             	C.rollup_source_type,
             	C.activity_context,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.attribute12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
        from
                mtl_parameters        MP1,
                cst_item_cost_details C,
                mtl_system_items      S,
                bom_cto_src_orgs        bcso
        where   S.organization_id   = C.organization_id
        and     S.inventory_item_id = C.inventory_item_id
        and     bcso.model_item_id = pModelId
        and     bcso.line_id = pLineId
        and     C.organization_id   = MP1.organization_id
        and     C.inventory_item_id = pModelId
        and     C.inventory_item_id = S.inventory_item_id
        and     C.rollup_source_type = 1      -- User Defined
        and     C.COST_TYPE_ID  IN ( MP1.primary_cost_method, MP1.avg_rates_cost_type_id)
	and     mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from cst_item_cost_details
                where inventory_item_id = pConfigId
                and organization_id = mp1.organization_id
                and COST_TYPE_ID  IN (MP1.primary_cost_method, MP1.avg_rates_cost_type_id));



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:cst_item_cost_details inserted '||to_char(sql%rowcount),2);
	END IF;





	/* For standard costing orgs, we will copy model's user-defined
	cost in Frozen to the config in CTO cost type. */

      	insert into cst_item_cost_details
            	(inventory_item_id,
             	cost_type_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	organization_id,
             	operation_sequence_id,
             	operation_seq_num,
             	department_id,
             	level_type,
             	activity_id,
             	resource_seq_num,
             	resource_id,
             	resource_rate,
             	item_units,
             	activity_units,
             	usage_rate_or_amount,
             	basis_type,
             	basis_resource_id,
             	basis_factor,
             	net_yield_or_shrinkage_factor,
             	item_cost,
             	cost_element_id,
             	rollup_source_type,
             	activity_context,
             	attribute_category,
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
      	select distinct
		pConfigId,                   -- inventory_item_id
             	l_cto_cost_type_id, 	     -- CTO cost_type_id,
             	sysdate,                     -- last_update_date
             	-1,                          -- last_updated_by
             	sysdate,                     -- creation_date
             	-1,                          -- created_by
             	-1,                          -- last_update_login
             	mp1.cost_organization_id,
             	c.operation_sequence_id,
             	c.operation_seq_num,
             	c.department_id,
             	c.level_type,
             	c.activity_id,
             	c.resource_seq_num,
             	c.resource_id,
             	c.resource_rate,
             	c.item_units,
             	c.activity_units,
             	c.usage_rate_or_amount,
             	c.basis_type,
             	c.basis_resource_id,
             	c.basis_factor,
             	c.net_yield_or_shrinkage_factor,
             	c.item_cost,
             	c.cost_element_id,
             	C.rollup_source_type,
             	C.activity_context,
             	C.attribute_category,
             	C.attribute1,
             	C.attribute2,
             	C.attribute3,
             	C.attribute4,
             	C.attribute5,
             	C.attribute6,
             	C.attribute7,
             	C.attribute8,
             	C.attribute9,
             	C.attribute10,
             	C.attribute11,
             	C.attribute12,
             	C.attribute13,
             	C.attribute14,
             	C.attribute15
        from
                mtl_parameters        MP1,
                cst_item_cost_details C,
                mtl_system_items      S,
                bom_cto_src_orgs        bcso
        where   S.organization_id   = C.organization_id
        and     S.inventory_item_id = C.inventory_item_id
        and     bcso.model_item_id = pModelId
        and     bcso.line_id = pLineId
        and     C.organization_id   = MP1.organization_id
        and     C.inventory_item_id = pModelId
        and     C.inventory_item_id = S.inventory_item_id
        and     C.rollup_source_type = 1      -- User Defined
        and     C.COST_TYPE_ID = MP1.primary_cost_method
        and     C.cost_type_id = 1
	and     mp1.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from cst_item_cost_details
                where inventory_item_id = pConfigId
                and organization_id = mp1.organization_id
                and COST_TYPE_ID = l_cto_cost_type_id);




	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert UD cost into CICD for CTO cost type inserted '||to_char(sql%rowcount),2);
	END IF;


        --Bugfix 6717614
        if lCnt = 0 then
           IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'No need to populate csc and cec as no new record inserted in cic and cicd',2);
	   END IF;
        else

        --begin Bugfix 6363308
        lStmtNumber := 231;
        IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'going to populate data in csc and cec if frozen cost of config is not zero',2);
	END IF;

        OPEN get_orgs_with_frozen_cost(pconfigId);
           loop

              FETCH get_orgs_with_frozen_cost INTO  v_organization_id
                                                  , v_item_cost_frozen;
              EXIT WHEN get_orgs_with_frozen_cost%NOTFOUND;

              IF PG_DEBUG <> 0 THEN
		        oe_debug_pub.add('Create_Item: ' || 'fetched org '||to_char(v_organization_id),2);
                        oe_debug_pub.add('Create_Item: ' || 'frozen cost for config '||to_char(pConfigId) || 'is: ' || to_char(v_item_cost_frozen),2);
	      END IF;

              IF (v_item_cost_frozen <> 0) THEN

                    lStmtNumber := 232;
                    IF PG_DEBUG <> 0 THEN
		        oe_debug_pub.add('Create_Item: ' || 'Came inside if. v_item_cost_frozen is not zero',2);
                        oe_debug_pub.add('Create_Item: ' || 'Fetching value from sequence',2);
	            END IF;

                    Select cst_lists_s.nextval
                      into l_cost_update
                        From DUAL;

                    lStmtNumber := 233;

                    UPDATE CST_ITEM_COSTS
                      SET cost_update_id = l_cost_update
                      WHERE  ORGANIZATION_ID = v_organization_id
                      AND  INVENTORY_ITEM_ID = pConfigId
                      AND  COST_TYPE_ID = 1;

                    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('Create_Item: ' || 'Updated cost_update_id to value ' || to_char(l_cost_update),2);
                    END IF;

                   lStmtNumber := 234;
                   IF PG_DEBUG <> 0 THEN
        	        oe_debug_pub.add('Create_Item: ' || 'Inserting records in csc and cec',2);
                   END IF;

                   INSERT INTO cst_standard_costs
                           (cost_update_id,
                            organization_id,
                            inventory_item_id,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login,
                            standard_cost_revision_date,
                            standard_cost
                           )
                   SELECT l_cost_update,
                          v_organization_id,
                          pConfigId,
                          SYSDATE,
                          -1,
                          SYSDATE,
                          -1,
                          -1,
                          SYSDATE,
                          NVL(SUM(item_cost),0)
                   FROM cst_item_cost_details
                   WHERE ORGANIZATION_ID = v_organization_id
                   AND  INVENTORY_ITEM_ID = pConfigId
                   AND  COST_TYPE_ID = 1;

                   IF PG_DEBUG <> 0 THEN
        	        oe_debug_pub.add('Create_Item: ' || 'after insert:cst_standard_costs ' || sql%rowcount ,2);
                   END IF;

                   lStmtNumber := 235;

                   INSERT INTO cst_elemental_costs
                           (cost_update_id,
                            organization_id,
                            inventory_item_id,
                            cost_element_id,
                            last_update_date,
                            last_updated_by,
                            creation_date,
                            created_by,
                            last_update_login,
                            standard_cost
                           )
                   SELECT l_cost_update,
                          v_organization_id,
                          pConfigId,
                          cost_element_id,
                          SYSDATE,
                          -1,
                          SYSDATE,
                          -1,
                          -1,
                          NVL(SUM(item_cost),0)
                   FROM cst_item_cost_details
                   WHERE ORGANIZATION_ID = v_organization_id
                   AND  INVENTORY_ITEM_ID = pConfigId
                   AND  COST_TYPE_ID = 1
                   GROUP BY cost_element_id;

                   IF PG_DEBUG <> 0 THEN
        	        oe_debug_pub.add('Create_Item: ' || 'after insert:cst_elemental_costs ' || sql%rowcount ,2);
                   END IF;
                 END IF;  -- v_item_cost_frozen <> 0
           end loop;

           CLOSE get_orgs_with_frozen_cost;
        --End Bugfix 6363308
        end if;  --lCnt = 0


     	/*------------------------------------------------+
          check the following statement
          If the project id is not specified on the line,
          l_cost_group_id should be 1
     	+-------------------------------------------------*/

	lStmtNumber := 240;

	--
	-- Currently, project mfg is not fully supported for ML ATO
	-- Currently, if a project is specified on the model line,
	-- we get the cost group id for this project in the ship-from-org
	-- This may not work correctly for mulit-sourcing, if different
	-- projects are assigned to different orgs.
	--
	select ship_from_org_id
	into lShipFromOrg
	from bom_cto_order_lines bcol
	where line_id = pLineID;

	l_cost_group_id := get_cost_group(lShipFromOrg, pLineID);

	if (l_cost_group_id = 0) then
                l_cost_group_id := 1;
	end if;


     -- Bugfix 1573941 : Added IF condition to check the profile : "CST:Average costing option"
     -- Only when this profile is set to "Inventory and WIP", should the records be inserted in CQL.
     -- 1 = Inventory Only
     -- 2 = Inventory and WIP

	IF ( nvl(fnd_profile.value('CST_AVG_COSTING_OPTION'), '1') = '2' ) THEN
	  FOR v_layer in c_layer
	  LOOP

	  --
	  -- This costing API will insert a row into cst_quantity_layers
	  -- for a unique layer_id and the given parameters.
	  -- It will return 0 if failed, layer_id if succeeded
	  --
	  l_layer_id := cstpaclm.create_layer (
  		i_org_id => v_layer.org_id,
  		i_item_id => pConfigId,
  		i_cost_group_id => v_layer.cost_group_id,
  		i_user_id => gUserId,
  		i_request_id => NULL,
  		i_prog_id => NULL,
  		i_prog_appl_id => NULL,
  		i_txn_id => -1,
  		o_err_num => x_err_num,
  		o_err_code => x_msg_name,
  		o_err_msg => lMsgData
		);

	  IF (l_layer_id = 0) THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_Item: ' || 'CST function create_layer returned with error '||to_char(x_err_num)||', '||x_msg_name||', '||
				lMsgData||'for '||to_char(v_layer.org_id)||', '||to_char(v_layer.cost_group_id),1);
		END IF;
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  ELSE
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add('Create_Item: ' || 'Inserted row into cql for '||to_char(l_layer_id)||', '||to_char(v_layer.org_id)||', '||
				to_char(v_layer.cost_group_id),1);
		END IF;
	  END IF;

	  END LOOP;
	END IF; /* End bugfix 1573941 */

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:cst_quantity_layers ',2);
	END IF;


      	/*--------------------------------------------------------+
        Insert rows into the mtl_desc_elem_val_interface table
        Descriptive elements are not organization controlled
	Using validation org to get values
      	+---------------------------------------------------------*/

      	lStmtNumber := 250;

      	insert into MTL_DESCR_ELEMENT_VALUES
         	(inventory_item_id,
             	element_name,
             	last_update_date,
             	last_updated_by,
             	last_update_login,
             	creation_date,
             	created_by,
             	element_value,
             	default_element_flag,
             	element_sequence,
             	program_application_id,
             	program_id,
             	program_update_date,
             	request_id
            	)
      	select distinct
		pConfigId,                -- Inventory_item_id
             	E.element_name,           -- element_name
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	gLoginId,                 -- last_update_login
             	sysdate,                  -- creation_date
             	gUserId,                  -- created_by
             	D.element_value,          -- element_value
             	E.default_element_flag,   -- default_element_flag
             	E.element_sequence,       -- element_sequence
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	NULL                      -- request_id
      	from   mtl_system_items  s,
             	mtl_descr_element_values D,
             	mtl_descriptive_elements E
      	where  D.inventory_item_id     = S.inventory_item_id
      	and    s.inventory_item_id     = pModelid
      	and    s.organization_id       = lValidationOrg
      	and    E.item_catalog_group_id = S.item_catalog_group_id
      	and    E.element_name          = D.element_name
	and NOT EXISTS
                (select NULL
                from mtl_descr_element_values
                where inventory_item_id = pConfigId
                and organization_id = lValidationOrg);

	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert: MTL_DESCR_ELEMENT_VALUES',2);
	END IF;


      	/*--------------------------------------+
          Insert into mtl_item_categories
      	+--------------------------------------*/

      	lStmtNumber := 260;

        --bugfix  4861996
	--added ic1.category_set_id = ic.category_set_id condition

      	insert into MTL_ITEM_CATEGORIES
            	(inventory_item_id,
            	 category_set_id,
             	category_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
             	)
      	select distinct
             	pConfigId,
             	ic.category_set_id,
             	ic.category_id,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ic.organization_id
        from
                mtl_item_categories ic,
                bom_cto_src_orgs        bcso
        where   ic.inventory_item_id = pModelId                         --bugfix 2706981: swapped the positions
        and     ic.organization_id = bcso.organization_id
        and     bcso.model_item_id = ic.inventory_item_id       --bugfix 2706981: replaced pModelId with col join
        and     bcso.line_id = pLineId                          --                as in bugfix 2215274
        --
        -- bugfix 2619501 (butler mfg):
        -- We will call custom hook to see which category_set needs to be inserted.
        -- If the custom hook returns 1 for a particular category_set_id, then, we will insert that category set.
        -- By default, the custom hook will return 1 for all category sets except sales and mktg category set.
        --
        -- and    ic.category_set_id <> 5       -- bugfix 2395525
        and    CTO_CUSTOM_CATEGORY_PK.Copy_Category (ic.category_set_id , ic.organization_id) = 1
        --
        -- end bugfix 2619501:
        --
        and NOT EXISTS
                (select NULL
                from  MTL_ITEM_CATEGORIES ic1                   -- bugfix 2706981: added alias
                where ic1.inventory_item_id = pConfigId
                and   ic1.organization_id = bcso.organization_id
	        and   ic1.category_set_id = ic.category_set_id
		);







	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert: MTL_ITEM_CATEGORIES',2);
	END IF;

	-- Start Bugfix 2197842

	lStmtNumber := 261;

	insert into MTL_ITEM_CATEGORIES
            	(inventory_item_id,
            	 category_set_id,
             	category_id,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
             	)
         select distinct
             	pConfigId,
             	mcsb.category_set_id,
             	mcsb.default_category_id,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ic.organization_id
        from
                mtl_item_categories             ic,
                mtl_category_sets_b             mcsb,
                mtl_default_category_sets       mdcs,
                bom_cto_src_orgs                bcso
        where   pModelId = ic.inventory_item_id
        and     ic.organization_id = bcso.organization_id
        and     bcso.model_item_id = pModelId
        and     bcso.line_id = pLineId
        and     mcsb.category_set_id = mdcs.category_set_id
        and     mdcs.functional_area_id = 2
        and     NOT EXISTS
                (
                        select NULL
                        from MTL_ITEM_CATEGORIES
                        where inventory_item_id = pConfigId
                        and organization_id = bcso.organization_id
                        and category_set_id = mcsb.category_set_id
                );





	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert: MTL_ITEM_CATEGORIES FOR DEFAULT CATEGORIES',2);
	END IF;

	-- End Bugfix 2197842

      	/*----------------------------------------------------+
        Copy related items into MTL_RELATED_ITEMS table
      	+----------------------------------------------------*/

      	lStmtNumber := 270;

      	insert into MTL_RELATED_ITEMS
           	(
             	inventory_item_id,
             	related_item_id,
             	relationship_type_id,
             	reciprocal_flag,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date,
             	organization_id
            	)
      	select distinct
             	pConfigId,
             	ri.related_item_id,
             	ri.relationship_type_id,
             	ri.reciprocal_flag,
             	sysdate,                  -- last_update_date
             	gUserId,                  -- last_updated_by
             	sysdate,                  --creation_date
             	gUserId,                  -- created_by
             	gLoginId,                 -- last_update_login
             	NULL,                     -- request_id
             	NULL,                     -- program_application_id
             	NULL,                     -- program_id
             	SYSDATE,                  -- program_update_date
             	ri.organization_id
        from  mtl_related_items ri,
                bom_cto_src_orgs        bcso
        where ri.inventory_item_id = pModelId
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and   ri.organization_id   = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from mtl_related_items
                where inventory_item_id = pConfigId
                and organization_id = bcso.organization_id);





	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:mtl_related_items',2);
	END IF;

       	/*--------------------------------------------------+
           Copy substitute inventories
       	+--------------------------------------------------*/

       	lStmtNumber := 280;

       	insert into mtl_item_sub_inventories
           	(
             	inventory_item_id,
             	organization_id,
             	secondary_inventory,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	primary_subinventory_flag ,
             	picking_order,
             	min_minmax_quantity,
             	max_minmax_quantity,
             	inventory_planning_code,
             	fixed_lot_multiple,
             	minimum_order_quantity,
             	maximum_order_quantity,
             	source_type,
             	source_organization_id,
             	source_subinventory,
             	attribute_category,
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
             	request_id,
             	program_application_id ,
             	program_id,
             	program_update_date,
             	encumbrance_account
             	)
       	select distinct
             	pConfigId,
             	isi.ORGANIZATION_ID,
             	isi.SECONDARY_INVENTORY,
             	sysdate,                    -- last_update_date
             	gUserId,                    -- last_updated_by
             	sysdate,                    -- creation_date
             	gUserId,                    -- created_by
             	gLoginId,                   -- last_update_login
             	isi.PRIMARY_SUBINVENTORY_FLAG ,
             	isi.PICKING_ORDER,
             	isi.MIN_MINMAX_QUANTITY,
             	isi.MAX_MINMAX_QUANTITY,
             	isi.INVENTORY_PLANNING_CODE,
             	isi.FIXED_LOT_MULTIPLE,
             	isi.MINIMUM_ORDER_QUANTITY,
             	isi.MAXIMUM_ORDER_QUANTITY,
             	isi.SOURCE_TYPE,
             	isi.SOURCE_ORGANIZATION_ID,
             	isi.SOURCE_SUBINVENTORY,
             	isi.ATTRIBUTE_CATEGORY,
             	isi.ATTRIBUTE1,
             	isi.ATTRIBUTE2,
             	isi.ATTRIBUTE3,
             	isi.ATTRIBUTE4,
             	isi.ATTRIBUTE5,
             	isi.ATTRIBUTE6,
             	isi.ATTRIBUTE7,
             	isi.ATTRIBUTE8,
             	isi.ATTRIBUTE9,
             	isi.ATTRIBUTE10,
             	isi.ATTRIBUTE11,
             	isi.ATTRIBUTE12,
             	isi.ATTRIBUTE13,
             	isi.ATTRIBUTE14,
             	isi.ATTRIBUTE15,
             	NULL,                       -- request_id
             	NULL,                       -- program_application_id
             	NULL,                       -- program_id
             	SYSDATE,                    -- program_update_date
             	isi.ENCUMBRANCE_ACCOUNT
        from
                mtl_item_sub_inventories isi,
                bom_cto_src_orgs        bcso
        where isi.organization_id   = bcso.organization_id
        and   isi.inventory_item_id = pModelId
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and NOT EXISTS
                (select NULL
                from mtl_item_sub_inventories
                where inventory_item_id = pConfigId
                and organization_id = bcso.organization_id);




	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:mtl_item_sub_inventories',2);
	END IF;

       	/*--------------------------------------+
          Copy secondary locators
       	+--------------------------------------*/

       	lStmtNumber := 290;

       	insert into mtl_secondary_locators
           	(
             	inventory_item_id,
             	organization_id,
             	secondary_locator,
             	primary_locator_flag,
             	picking_order,
             	subinventory_code,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date
           	)
       	select distinct
             	pConfigId,
             	sl.organization_id,
             	sl.secondary_locator,
             	sl.primary_locator_flag,
             	sl.picking_order,
             	sl.subinventory_code,
             	sysdate,                     -- last_update_date
             	gUserId,                     -- last_updated_by
             	sysdate,                     -- creation_date
             	gUserId,                     -- created_by
             	gLoginId,                    -- last_update_login
             	NULL,                        -- request_id
             	NULL,                        -- program_application_id
             	NULL,                        -- program_id
             	SYSDATE                      -- program_update_date
        from
                mtl_secondary_locators sl,
                bom_cto_src_orgs        bcso
        where  sl.organization_id = bcso.organization_id
        and   pModelId = sl.inventory_item_id
        and bcso.model_item_id = pModelId
        and bcso.line_id = pLineId
        and NOT EXISTS
                (select NULL
                from mtl_secondary_locators
                where inventory_item_id = pConfigId
                and organization_id = bcso.organization_id);




	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert: mtl_secondary_locators',2);
	END IF;

      	/*----------------------------------------+
            Copy cross references
      	+----------------------------------------*/

      	lStmtNumber := 300;

       --start bugfix 4539578


          SELECT DISTINCT
            		CR.ORGANIZATION_ID
           	       ,CR.CROSS_REFERENCE_TYPE
                       ,CR.CROSS_REFERENCE
            	       ,CR.ORG_INDEPENDENT_FLAG
          BULK COLLECT INTO
	               t_organization_id,
		       t_cross_ref_type,
		       t_cross_ref,
		       t_org_independent_flag
          FROM   MTL_CROSS_REFERENCES_B CR,
                 BOM_CTO_SRC_ORGS       BCSO
          WHERE  (CR.ORGANIZATION_ID = bcso.ORGANIZATION_ID OR  CR.ORGANIZATION_ID IS NULL)
          AND    CR.INVENTORY_ITEM_ID = PMODELID
          AND    BCSO.MODEL_ITEM_ID = PMODELID
          AND    BCSO.LINE_ID = PLINEID
          AND  NOT EXISTS
                 ( SELECT NULL
                   FROM MTL_CROSS_REFERENCES_B
                   WHERE INVENTORY_ITEM_ID = PCONFIGID
                   AND ( ORGANIZATION_ID = bcso.ORGANIZATION_ID  OR ORGANIZATION_ID IS NULL) -- bugfix 1960994: added OR condition
                       );

        IF t_cross_ref_type.count <> 0 THEN

	 FORALL i IN 1..t_cross_ref_type.count
           INSERT INTO MTL_CROSS_REFERENCES_B
                            (
                              INVENTORY_ITEM_ID
                             ,ORGANIZATION_ID
                             ,CROSS_REFERENCE_TYPE
                             ,CROSS_REFERENCE
                             ,ORG_INDEPENDENT_FLAG
                             ,LAST_UPDATE_DATE
                             ,LAST_UPDATED_BY
                             ,CREATION_DATE
                             ,CREATED_BY
                             ,LAST_UPDATE_LOGIN
                             ,REQUEST_ID
                             ,PROGRAM_APPLICATION_ID
                             ,PROGRAM_ID
                             ,PROGRAM_UPDATE_DATE
                             ,SOURCE_SYSTEM_ID
                             ,OBJECT_VERSION_NUMBER
                             ,UOM_CODE
                             ,REVISION_ID
                             ,CROSS_REFERENCE_ID
                             ,EPC_GTIN_SERIAL
                             ,ATTRIBUTE1
                             ,ATTRIBUTE2
                             ,ATTRIBUTE3
                             ,ATTRIBUTE4
                             ,ATTRIBUTE5
                             ,ATTRIBUTE6
                             ,ATTRIBUTE7
                             ,ATTRIBUTE8
                             ,ATTRIBUTE9
                             ,ATTRIBUTE10
                             ,ATTRIBUTE11
                             ,ATTRIBUTE12
                             ,ATTRIBUTE13
                             ,ATTRIBUTE14
                             ,ATTRIBUTE15
                             ,ATTRIBUTE_CATEGORY
                           )
                     VALUES
		        (
                         pConfigId
                        ,t_organization_id(i)
                        ,t_cross_ref_type(i)
  			,t_cross_ref(i)
  			,t_org_independent_flag(i)
  			,SYSDATE
  			,GUSERID
  			,SYSDATE
  			,GUSERID
                        ,GLOGINID
                        ,NULL       --REQUEST_ID
                        ,NULL       --PROGRAM_APPLICATION_ID
  			,NULL       --PROGRAM_ID
  			,SYSDATE    --PROGRAM_UPDATE_DATE
		        ,NULL       --SOURCE_SYSTEM_ID
  			,1          --OBJECT_VERSION_NUMBER
  			,NULL       --UOM_CODE      due to ER#3215422. do not copy uom_code and revision_id attribute for mtl_cross_references
  			,NULL       --REVISION_ID   due to ER#3215422. do not copy uom_code and revision_id attribute for mtl_cross_references
  			,MTL_CROSS_REFERENCES_B_S.NEXTVAL --CROSS_REFERENCE_ID
  			,0          --EPC_GTIN_SERIAL
  			,NULL       --ATTRIBUTE1
  			,NULL       --ATTRIBUTE2
  			,NULL       --ATTRIBUTE3
  			,NULL       --ATTRIBUTE4
  			,NULL       --ATTRIBUTE5
  			,NULL       --ATTRIBUTE6
  			,NULL       --ATTRIBUTE7
 		        ,NULL       --ATTRIBUTE8
 		        ,NULL       --ATTRIBUTE9
  			,NULL       --ATTRIBUTE10
  			,NULL       --ATTRIBUTE11
  			,NULL       --ATTRIBUTE12
  			,NULL       --ATTRIBUTE13
 			,NULL       --ATTRIBUTE14
  			,NULL       --ATTRIBUTE15
  			,NULL       --ATTRIBUTE_CATEGORY
		       );

          IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:mtl_cross_references_b',2);
		oe_debug_pub.add('Create_Item: ' || '# of inserted rows mtl_cross_references_b'||sql%rowcount,2);

	  END IF;

          INSERT INTO mtl_cross_references_tl (
             last_update_login
            ,description
            ,creation_date
            ,created_by
            ,last_update_date
            ,last_updated_by
            ,cross_reference_id
            ,language
            ,source_lang)
         SELECT
            gloginid,
            mtl.description,
            sysdate,
            guserid,
            sysdate,
            guserid,
            mtl_cross.cross_reference_id,
            l.language_code,
            userenv('lang')
         FROM  fnd_languages l,
	       mtl_cross_references_b mtl_cross,
	       mtl_system_items_tl mtl
         WHERE mtl_cross.inventory_item_id = pConfigId
	 AND   mtl_cross.inventory_item_id = mtl.inventory_item_id
	 AND   mtl_cross.organization_id   = mtl.organization_id
         AND   l.language_code  = mtl.language
	 AND   l.installed_flag in ('I', 'B')
         AND  NOT EXISTS  (SELECT null
                           FROM   mtl_cross_references_tl t
                           WHERE  t.cross_reference_id = mtl_cross.cross_reference_id
                           AND    t.language = l.language_code);



	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert:mtl_cross_references_tl',2);
		oe_debug_pub.add('Create_Item: ' || '# of inserted rows mtl_cross_references_tl'||sql%rowcount,2);

	END IF;


	END IF;--cross_reference_type

      --end bugfix 4539578

	-- start bugfix 2461574

	/*--------------------------------------+
          Copy Subinventory Defaults
       	+--------------------------------------*/

       	lStmtNumber := 301;

       	insert into mtl_item_sub_defaults
           	(
             	inventory_item_id,
             	organization_id,
             	subinventory_code,
             	default_type,
             	last_update_date,
             	last_updated_by,
             	creation_date,
             	created_by,
             	last_update_login,
             	request_id,
             	program_application_id,
             	program_id,
             	program_update_date
           	)
       	select distinct
             	pConfigId,
             	sd.organization_id,
               	sd.subinventory_code,
               	sd.default_type,
             	sysdate,                     -- last_update_date
             	gUserId,                     -- last_updated_by
             	sysdate,                     -- creation_date
             	gUserId,                     -- created_by
             	gLoginId,                    -- last_update_login
             	NULL,                        -- request_id
             	NULL,                        -- program_application_id
             	NULL,                        -- program_id
             	SYSDATE                      -- program_update_date
        from
                mtl_item_sub_defaults sd,
                bom_cto_src_orgs        bcso
        where   sd.organization_id = bcso.organization_id
        and     sd.inventory_item_id = pModelId
        and     bcso.model_item_id = pModelId
        and     bcso.line_id = pLineId
        and NOT EXISTS
                (select NULL
                from mtl_item_sub_defaults
                where inventory_item_id = pConfigId
                and organization_id = bcso.organization_id);


	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add('Create_Item: ' || 'after insert: mtl_item_sub_defaults',2);
	END IF;

	-- end 2461574
	-- start 2786934

        /*--------------------------------------+
          Copy Locator Defaults
        +--------------------------------------*/

        lStmtNumber := 302;
        insert into mtl_item_loc_defaults
                (
                inventory_item_id,
                organization_id,
                locator_id,
                default_type,
                subinventory_code,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date
                )
        select distinct
                pConfigId,
                ld.organization_id,
                ld.locator_id,
                ld.default_type,
                ld.subinventory_code,
                sysdate,                     -- last_update_date
                gUserId,                     -- last_updated_by
                sysdate,                     -- creation_date
                gUserId,                     -- created_by
                gLoginId,                    -- last_update_login
                NULL,                        -- request_id
                NULL,                        -- program_application_id
                NULL,                        -- program_id
                SYSDATE                      -- program_update_date
        from
                mtl_item_loc_defaults   ld,
                bom_cto_src_orgs        bcso
        where   ld.organization_id      =       bcso.organization_id
        and     ld.inventory_item_id    =       bcso.model_item_id
        and     bcso.model_item_id      =       pModelId
        and     bcso.line_id            =       pLineId
        and NOT EXISTS
                (select NULL
                from mtl_item_loc_defaults
                where inventory_item_id = pConfigId
                and   organization_id = ld.organization_id);



        IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Create_Item: ' || 'after insert: mtl_item_loc_defaults',2);
        END IF;

        -- end 2786934

	--satrt bugfix 2828588
	--added for 11.5.10 , patchset-J
	lStmtNumber := 310;
        INSERT INTO mtl_abc_assignments
                (
                inventory_item_id,
                assignment_group_id,
                abc_class_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by
                )
        select  pConfigId,
                maa.assignment_group_id,
                maa.abc_class_id,
		sysdate,
		gUserId,
		sysdate,
		gUserId
        FROM  mtl_abc_assignments maa
	WHERE maa.inventory_item_id = pModelId
	--bugfix3536085 not exists condition
	AND   NOT EXISTS
	      (SELECT 'X'
	       FROM mtl_abc_assignments
	       WHERE inventory_item_id = pConfigId
	       AND   assignment_group_id = maa.assignment_group_id );






         IF PG_DEBUG <> 0 THEN

                oe_debug_pub.add('Create_Item: ' || 'inserted '||sql%rowcount||' in mtl_abc_assignments',2);

                oe_debug_pub.add('Create_Item: ' || 'after insert: mtl_abc_assignments',2);
        END IF;

	--end bugfix 2828588

	-- Begin Bugfix 9288619
	/*--------------------------------------+
          Copy Customer Item Cross References
        +--------------------------------------*/

	DECLARE
	   CURSOR cust_id_xref_cur IS
	     SELECT xref.customer_item_id, Max(xref.preference_number) pref_number
	     FROM mtl_customer_item_xrefs xref
	     WHERE customer_item_id IN (
					 SELECT ref1.customer_item_id
					 FROM mtl_customer_item_xrefs ref1
					 WHERE ref1.inventory_item_id = pModelId
				       )
	     GROUP BY customer_item_id;

	BEGIN
	     FOR cust_id_xref_rec IN cust_id_xref_cur LOOP
		IF PG_DEBUG <> 0 THEN
		     oe_debug_pub.add('Create_Item: '||'Customer Item Id:'|| cust_id_xref_rec.customer_item_id, 5);
		     oe_debug_pub.add('Create_Item: '||'Rank:'|| cust_id_xref_rec.pref_number, 5);
		END IF;

		INSERT
		INTO   mtl_customer_item_xrefs
		(
			Customer_Item_Id      ,
			Inventory_Item_Id     ,
			Master_Organization_Id,
			Preference_Number     ,
			Inactive_Flag         ,
			Last_Update_Date      ,
			Last_Updated_By       ,
			Creation_Date         ,
			Created_By            ,
			Last_Update_Login     ,
			Attribute_Category    ,
			Attribute1            ,
			Attribute2            ,
			Attribute3            ,
			Attribute4            ,
			Attribute5            ,
			Attribute6            ,
			Attribute7            ,
			Attribute8            ,
			Attribute9            ,
			Attribute10           ,
			Attribute11           ,
			Attribute12           ,
			Attribute13           ,
			Attribute14           ,
			Attribute15
		)
	        select
		        cust_id_xref_rec.customer_item_id,
			pConfigId                        ,
			xref.Master_Organization_Id      ,
			cust_id_xref_rec.pref_number + 1 ,
			xref.Inactive_Flag               ,
			sysdate                          ,
			gUserId                          ,
			sysdate                          ,
			gUserId                          ,
			gLoginId                         ,
			xref.Attribute_Category          ,
			xref.Attribute1                  ,
			xref.Attribute2                  ,
			xref.Attribute3                  ,
			xref.Attribute4                  ,
			xref.Attribute5                  ,
			xref.Attribute6                  ,
			xref.Attribute7                  ,
			xref.Attribute8                  ,
			xref.Attribute9                  ,
			xref.Attribute10                 ,
			xref.Attribute11                 ,
			xref.Attribute12                 ,
			xref.Attribute13                 ,
			xref.Attribute14                 ,
			xref.Attribute15
		FROM   mtl_customer_item_xrefs xref
		WHERE  inventory_item_id = pModelId
		AND    customer_item_id  = cust_id_xref_rec.customer_item_id
		AND NOT EXISTS ( SELECT 'EXISTS'
				 FROM mtl_customer_item_xrefs ref1
				 WHERE inventory_item_id = pConfigId
				 AND customer_item_id = cust_id_xref_rec.customer_item_id
			       );
	     END LOOP;
	END;

	IF PG_DEBUG <> 0 THEN
	     oe_debug_pub.add('Create_Item: ' || 'after insert: mtl_customer_item_xrefs',2);
        END IF;
	-- End Bugfix 9288619


      	return(1);

  EXCEPTION

	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item_data::ndf::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
                return(0);

	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item_data::exp error::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
                return(0);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'ERROR: create_item_data::unexp error::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
                return(0);


     	WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('Create_Item: ' || 'create_item_data::others::'||to_char(lStmtNumber)||sqlerrm,1);
		END IF;
        	CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => lMsgCount,
                  p_msg_data  => lMsgData
                );
        	return(0);

END create_item_data;


FUNCTION link_item(
         pOrgId          in     number   ,
         pModelId        in     number   ,
         pConfigId       in     number   ,
         pLineId         in     number   ,
         xMsgCount	 out NOCOPY   number,
         xMsgData        out NOCOPY   varchar2)
RETURN integer
is

    lStmtNumber    	      	number;
    lItemName 		      	Varchar2(2000);
    l_model_tab               	oe_order_pub.Line_Tbl_Type;
    l_line_rec                	oe_order_pub.Line_Rec_type;

    l_msg_count               	number;
    l_msg_data                	varchar2(2000);
    l_return_status           	varchar2(1) := FND_API.G_RET_STS_SUCCESS;
    l_header_rec              	oe_order_pub.Header_Rec_Type;
    l_header_val_rec          	oe_order_pub.Header_Val_Rec_Type  ;
    l_Header_Adj_tbl          	oe_order_pub.Header_Adj_Tbl_Type;
    l_Header_Adj_val_tbl      	oe_order_pub.Header_Adj_Val_Tbl_Type;
    l_Header_price_Att_tbl    	oe_order_pub.Header_Price_Att_Tbl_Type;
    l_Header_Adj_Att_tbl      	oe_order_pub.Header_Adj_Att_Tbl_Type;
    l_Header_Adj_Assoc_tbl    	oe_order_pub.Header_Adj_Assoc_Tbl_Type;
    l_Header_Scredit_tbl      	oe_order_pub.Header_Scredit_Tbl_Type;
    l_Header_Scredit_val_tbl  	oe_order_pub.Header_Scredit_Val_Tbl_Type;
    l_line_tbl                	oe_order_pub.Line_Tbl_Type;
    l_line_val_tbl            	oe_order_pub.Line_Val_Tbl_Type;
    l_Line_Adj_tbl            	oe_order_pub.Line_Adj_Tbl_Type;
    l_Line_Adj_val_tbl        	oe_order_pub.Line_Adj_Val_Tbl_Type;
    l_Line_price_Att_tbl      	oe_order_pub.Line_Price_Att_Tbl_Type;
    l_Line_Adj_Att_tbl        	oe_order_pub.Line_Adj_Att_Tbl_Type;
    l_Line_Adj_Assoc_tbl      	oe_order_pub.Line_Adj_Assoc_Tbl_Type;
    l_Line_Scredit_tbl        	oe_order_pub.Line_Scredit_Tbl_Type  ;
    l_Line_Scredit_val_tbl    	oe_order_pub.Line_Scredit_Val_Tbl_Type;
    l_Lot_Serial_tbl          	oe_order_pub.Lot_Serial_Tbl_Type;
    l_Lot_Serial_val_tbl      	oe_order_pub.Lot_Serial_Val_Tbl_Type;
    l_action_request_tbl      	oe_order_pub.Request_Tbl_Type;

    l_config_line_id		number;
    l_config_id                 number;
    lLinkLineId			number;
    l_stat                      number;

    --Begin Bugfix 1997355

    index_counter_link		number;
    p_config_line_arr_link	MRP_OM_API_PK.line_id_tbl;
    l_return_status_link 	varchar2(1);

    --End Bugfix 1997355


    gUserId 			number;
    gLoginId 			number;

    l_upd_line_tbl            	oe_order_pub.Line_Tbl_Type;
    l_upd_line_rec             	oe_order_pub.Line_Rec_type;
    l_option_line_id            number;
    i   			number;
    x   			number;
    y   			varchar(1);
    z   			varchar(30);
    l_vdflag    		varchar(1);
    l_header_id                 oe_order_lines_all.header_id%type;

--
--bugfix 2840801
--
    l_x_hold_result_out		Varchar2(30);
    l_x_hold_return_status	Varchar2(30);
    l_x_error_msg_count		Number;
    l_x_error_msg		Varchar2(2000);
    l_hold_source_rec		OE_Holds_PVT.Hold_Source_REC_type;

    v_schedule_status_code      oe_order_lines_all.schedule_status_code%type ;
    v_booked_flag               oe_order_lines_all.booked_flag%type ;
    v_hold_id                   number ;

BEGIN

   gUserId := nvl(Fnd_Global.USER_ID,-1);
   gLoginId := nvl(Fnd_Global.LOGIN_ID,-1);


    --
    -- check if config item already exists
    --
    IF (CTO_MATCH_AND_RESERVE.config_line_exists(
				p_model_line_id		=> pLineId,
                                x_config_line_id	=> l_config_line_id,
                                x_config_item_id	=> l_config_id)  = TRUE)
    THEN
            IF PG_DEBUG <> 0 THEN
            	oe_debug_pub.add('link_item: ' || 'Config Line Exists, do not link', 1);
            END IF;
            return(1);
    END IF;


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('link_item: ' || 'calling  oe_line_util.query_row , 2');
    END IF;

    Select concatenated_segments
    into   l_model_tab(1).ordered_item
    from   mtl_system_items_b_kfv
    where  inventory_item_id = pConfigId
    and    organization_id   = pOrgId;

    lStmtNumber    := 395;
    l_line_rec := oe_line_util.query_row(pLineId);

   /*-----------------------------------------------------------+
    Setting visible demand flag to 'N' for the selected model and options.
   +-----------------------------------------------------------*/
    --
    -- selecting all rows to be updated into l_upd_line_tbl
    --
    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('link_item: ' || 'link : visible demand flag : before selecting options ', 2);
    END IF;


   /* BUG#2234858 Sushant added this for Drop Ship project
   ** Need to provide this functionality for non drop shipped items only
   */

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('link_item: ' || 'Before visible demand flag souce type code = '||l_line_rec.source_type_code,1);
    END IF;
    if( l_line_rec.source_type_code = 'INTERNAL') then



    lStmtNumber    := 380;

    -- The following update statement is added by Renga Kannan on 04/04/2001.
    -- The previous process order API is replaced with this update statement for performance purpose.


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('link_item: ' || 'Before updating visible demand Flag...',1);

    	oe_debug_pub.add('link_item: ' || ' ATO line id = '||to_char(plineid),1);
    END IF;

    UPDATE OE_ORDER_LINES_ALL
    SET  visible_demand_flag = 'N'
    WHERE ato_line_id = pLineId;

   IF PG_DEBUG <> 0 THEN
   	oe_debug_pub.add('link_item: ' || 'after updating visible demand flag..',1);

   	oe_debug_pub.add('link_item: ' || 'No of rows updated = '||sql%rowcount,1);
   END IF;

    -- End of adition on 04/04/2001

    end if ;
   /* BUG#2234858 Sushant added this for Drop Ship project */

    l_model_tab(1)                        := OE_ORDER_PUB.G_MISS_LINE_REC;
    l_model_tab(1).operation              := OE_Globals.G_OPR_CREATE;
    l_model_tab(1).inventory_item_id      := pConfigId;
    l_model_tab(1).item_type_code         := OE_Globals.G_ITEM_CONFIG;
    l_model_tab(1).ordered_quantity       := l_line_rec.ordered_quantity;
    l_model_tab(1).order_quantity_uom     := l_line_rec.order_quantity_uom;
    l_model_tab(1).ship_from_org_id       := l_line_rec.ship_from_org_id ;
    l_model_tab(1).org_id                 := l_line_rec.org_id ;
    l_model_tab(1).source_type_code       := l_line_rec.source_type_code;
    l_model_tab(1).request_date           := l_line_rec.request_date;
    l_model_tab(1).schedule_status_code   := l_line_rec.schedule_status_code;
    l_model_tab(1).schedule_ship_date     := l_line_rec.schedule_ship_date;


   /* BUG#2234858 Sushant added this for Drop Ship project */
    if( l_line_rec.source_type_code = 'INTERNAL' ) then
    l_model_tab(1).visible_demand_flag    := 'Y';

    else

    l_model_tab(1).visible_demand_flag    := 'N';
    end if ;
   /* BUG#2234858 Sushant added this for Drop Ship project */


    l_model_tab(1).header_id              := l_line_rec.header_id;
/*
 commented as per gayatri
    l_model_tab(1).config_header_id       := l_line_rec.config_header_id;
    l_model_tab(1).config_rev_nbr         := l_line_rec.config_rev_nbr;
*/
    l_model_tab(1).model_group_number     := l_line_rec.model_group_number;
    l_model_tab(1).line_number            := l_line_rec.line_number;
    l_model_tab(1).shipment_number        := l_line_rec.shipment_number;
    l_model_tab(1).link_to_line_id        := l_line_rec.line_id;
    l_model_tab(1).ato_line_id            := l_line_rec.line_id;
    l_model_tab(1).top_model_line_id      := l_line_rec.top_model_line_id;
					--changed to top_model_line_id from line_id to support Pto-ATO models
    l_model_tab(1).component_code         := l_line_rec.component_code || pConfigId;
    l_model_tab(1).option_flag            := 'Y';
    --l_model_tab(1).ordered_item           := lItemName;
    l_model_tab(1).item_identifier_type   := 'INT';   -- Must pass for validation

    l_model_tab(1).change_reason := 'SYSTEM';   -- bug 3854182 for order versioning

/* bugfix 2887782 : copy the context and attribute cols from base model */
    l_model_tab(1).context       :=  l_line_rec.context;
    l_model_tab(1).attribute1    :=  l_line_rec.attribute1;
    l_model_tab(1).attribute2    :=  l_line_rec.attribute2;
    l_model_tab(1).attribute3    :=  l_line_rec.attribute3;
    l_model_tab(1).attribute4    :=  l_line_rec.attribute4;
    l_model_tab(1).attribute5    :=  l_line_rec.attribute5;
    l_model_tab(1).attribute6    :=  l_line_rec.attribute6;
    l_model_tab(1).attribute7    :=  l_line_rec.attribute7;
    l_model_tab(1).attribute8    :=  l_line_rec.attribute8;
    l_model_tab(1).attribute9    :=  l_line_rec.attribute9;
    l_model_tab(1).attribute10   :=  l_line_rec.attribute10;
    l_model_tab(1).attribute11   :=  l_line_rec.attribute11;
    l_model_tab(1).attribute12   :=  l_line_rec.attribute12;
    l_model_tab(1).attribute13   :=  l_line_rec.attribute13;
    l_model_tab(1).attribute14   :=  l_line_rec.attribute14;
    l_model_tab(1).attribute15   :=  l_line_rec.attribute15;
    --Bugfix 6633913: Copying these attributes to config line
    l_model_tab(1).attribute16   :=  l_line_rec.attribute16;
    l_model_tab(1).attribute17   :=  l_line_rec.attribute17;
    l_model_tab(1).attribute18   :=  l_line_rec.attribute18;
    l_model_tab(1).attribute19   :=  l_line_rec.attribute19;
    l_model_tab(1).attribute20   :=  l_line_rec.attribute20;

/*
    l_model_tab(1).option_number            := '0';
    This line commented as per gayatri to fix bug#2300006 to handle usability issues for multiple
    instantiation.
*/
    l_model_tab(1).option_number := l_line_rec.option_number ; /* Fix for BUG#2300006 */

    l_model_tab(1).component_number            := '0';/* Fix for BUG#2300006  added later on 04-16-2002 after talking to gayatri*/



    l_model_tab(1).dep_plan_required_flag := l_line_rec.dep_plan_required_flag;


    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('link_item: ' || 'linking  item ' || l_model_tab(1).ordered_item, 2);
    END IF;

    lStmtNumber    := 400;
    /*
    -- bugfix 2503104: Get the user_item_description information also

    select  nvl(component_code, oel.inventory_item_id) || '-'|| to_char(pConfigId),
            substrb(user_item_Description,1,240)
    into    l_model_tab(1).component_code,
            l_model_tab(1).user_item_description
    from    oe_order_lines_all oel
    where   oel.line_id = pLineId
    and     oel.ship_from_org_id = pOrgId;
    */
    -- bugfix 2503104: Revert this fix as OM will now populate
    -- user_item_description of config item. This will eliminate
    -- any compile time dependency between OM and CTO for this issue.

    select  nvl(component_code, oel.inventory_item_id) || '-'|| to_char(pConfigId)
    into    l_model_tab(1).component_code
    from    oe_order_lines_all oel
    where   oel.line_id = pLineId
    and     oel.ship_from_org_id = pOrgId;

    lStmtNumber    := 410;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('link_item: ' || 'calling  oe_order_grp.Process_order', 2);
    END IF;
    -- Change for MOAC
    -- Changing the public process order API to group API
    oe_order_grp.Process_Order (
       p_api_version_number         =>1.0,
       x_return_status              => l_return_status,
       x_msg_count                  => l_msg_count,
       x_msg_data                   => l_msg_data,
       p_line_tbl                   => l_model_tab,
       x_header_rec                 => l_header_rec,
       x_header_val_rec             => l_header_val_rec,
       x_Header_Adj_tbl             => l_header_Adj_tbl,
       x_Header_Adj_val_tbl         => l_header_Adj_val_tbl,
       x_Header_price_Att_tbl       => l_header_price_att_tbl,
       x_Header_Adj_Att_tbl         => l_header_adj_att_tbl,
       x_Header_Adj_Assoc_tbl       => l_header_adj_Assoc_tbl,
       x_Header_Scredit_tbl         => l_header_Scredit_tbl,
       x_Header_Scredit_val_tbl     => l_header_scredit_val_tbl,
       x_line_tbl                   => l_line_tbl,
       x_line_val_tbl               => l_line_val_tbl,
       x_Line_Adj_tbl               => l_line_adj_tbl,
       x_Line_Adj_val_tbl           => l_line_adj_val_tbl,
       x_Line_price_Att_tbl         => l_line_price_Att_tbl,
       x_Line_Adj_Att_tbl           => l_line_adj_att_tbl,
       x_Line_Adj_Assoc_tbl         => l_line_adj_Assoc_tbl,
       x_Line_Scredit_tbl           => l_line_scredit_tbl,
       x_Line_Scredit_val_tbl       => l_line_scredit_val_tbl,
       x_Lot_Serial_tbl             => l_lot_serial_tbl,
       x_Lot_Serial_val_tbl         => l_lot_serial_val_tbl,
       x_action_request_tbl         => l_action_request_tbl
    );

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('link_item: ' || 'Process_order returned ' || l_return_status, 1);

    	oe_debug_pub.add ('link_item: ' || 'Process_order returned ' || l_msg_data, 2);
    END IF;

    if (l_return_status = FND_API.G_RET_STS_ERROR) then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('link_item: ' || 'Process_order returned expected error :'||l_msg_data,1);
	END IF;
	raise FND_API.G_EXC_ERROR;

    elsif (l_return_status = FND_API.G_RET_STS_ERROR) then
	IF PG_DEBUG <> 0 THEN
		oe_debug_pub.add ('link_item: ' || 'Process_order returned unexpected error :'||l_msg_data,1);
	END IF;
	raise FND_API.G_EXC_UNEXPECTED_ERROR;

    end if;

    oe_globals.g_cascading_request_logged := TRUE;



   /* BUG#2234858 Sushant added this for Drop Ship project */
    if( l_line_rec.source_type_code = 'INTERNAL' ) then




    lStmtNumber    := 420;
    l_stat := chk_model_in_bcod(pLineId);

   --set demand_visible flag in BCOD to 'N' so that only CID demand is visible to
   --planning and not of BOM

    if(l_stat = 1)then





      /* Not Required for Patcshet J */
      /*
      lStmtNumber    := 430;
      update bom_cto_order_demand
      set demand_visible = 'N'
      where ato_line_id =pLineId;

      --adding the CID row to BCOD table

      lStmtNumber    := 440;
      insert into bom_cto_order_demand(
        bcod_line_id,
        oe_line_id,
        ato_line_id,
        inventory_item_id,
        organization_id,
        required_date,
        required_qty,
        order_quantity_uom,
        parent_demand_type,
        header_id,
        forecast_visible,
        demand_visible,
        created_by,
        last_updated_by,
        last_updated_date,
        last_update_login,
        program_application_id,
        program_update_date
       )
      select
         BOM_CTO_ORDER_DEMAND_S1.nextval,
         line_id,
         pLineId,
         pConfigId,
         pOrgId,
         schedule_ship_date,
         ordered_quantity,
         order_quantity_uom,
         1,
         header_id,
         'N',
         'Y',
         gUserId,
         gUserId,
         sysdate,
         gLoginId,
         null,
         sysdate
      from oe_order_lines_all
      where ato_line_id=pLineId
      and   inventory_item_id=pConfigId;

      */

      null ;


  elsif(l_stat =0) then
   -- do nothing
     IF PG_DEBUG <> 0 THEN
     	oe_debug_pub.add ('link_item: ' || 'no model line present in bcod table to create a CID,not an error', 3);
     END IF;

  end if;



  end if ;
   /* BUG#2234858 Sushant added this for Drop Ship project */



    --Begin Bugfix 1997355

    lStmtNumber    := 450;
    select line_id, header_id	-- bugfix 2840801 : added header_id
    into   l_config_line_id, l_header_id
    from   oe_order_lines_all oel
    where  ato_line_id = pLineId
    and    inventory_item_id = pConfigId
    and    item_type_code    = 'CONFIG';

    index_counter_link:= 1;
    p_config_line_arr_link(index_counter_link) := l_config_line_id ;

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add('link_item: ' || 'Start MRP package for link', 1);
    END IF;

    MRP_OM_API_PK.MRP_OM_Interface
		(p_line_tbl		=> p_config_line_arr_link,
		 x_return_status	=> l_return_status_link);

    IF PG_DEBUG <> 0 THEN
    	oe_debug_pub.add ('link_item: ' || 'Return status from MRP_OM_Interface - Link: '||l_return_status_link,2);
    END IF;

    if l_return_status_link = FND_API.G_RET_STS_ERROR then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('link_item: ' || 'Failed in MRP_OM_API_PK.mrp_om_interface with expected error.', 1);
     		END IF;
		raise FND_API.G_EXC_ERROR;

    elsif l_return_status_link = FND_API.G_RET_STS_UNEXP_ERROR then
     		IF PG_DEBUG <> 0 THEN
     			oe_debug_pub.add ('link_item: ' || 'Failed in MRP_OM_API_PK.mrp_om_interface with unexpected error.', 1);
     		END IF;
		raise FND_API.G_EXC_UNEXPECTED_ERROR;
    end if;

    -- End Bugfix 1997355

    --
    -- Begin bugfix 2840801
    -- If any optional components are dropped while creating bill for config item,
    -- we will put a hold on the config-line.
    -- The global variable gApplyHold is set in CTOCBOMB.pls
    --

    if (CTO_CONFIG_BOM_PK.gApplyHold = 'Y') then
     	IF PG_DEBUG <> 0 THEN
	   oe_debug_pub.add ('CTOCITMB:Need to put hold on config line '||l_config_line_id);
	END IF;

	/* Put the config line on Hold. But first, check to see if a hold already exists
           on this line  */

	OE_HOLDS_PUB.Check_Holds (
		 p_api_version 		=> 1.0
		,p_line_id 		=> l_config_line_id
		,x_result_out 		=> l_x_hold_result_out
		,x_return_status 	=> l_x_hold_return_status
		,x_msg_count 		=> l_x_error_msg_count
		,x_msg_data 		=> l_x_error_msg);

        IF (l_x_hold_return_status = FND_API.G_RET_STS_ERROR) THEN
     		IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('CTOCITMB:Failed in Check Holds with expected error.' ,1);
		END IF;
                raise FND_API.G_EXC_ERROR;

        ELSIF (l_x_hold_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     		IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('CTOCITMB:Failed in Check Holds with unexpected error.' ,1);
		END IF;
                raise FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSE
     		IF PG_DEBUG <> 0 THEN
                   oe_debug_pub.add('CTOCITMB:Success in Check Holds.' ,1);
     		END IF;
		if l_x_hold_result_out = FND_API.G_FALSE then



                   select schedule_status_code , booked_flag into v_schedule_Status_code , v_booked_flag
                     from oe_order_lines_all
                    where line_id = pLineId ;



                    if( v_schedule_status_code = 'SCHEDULED' and v_booked_flag = 'Y' ) then

                        v_hold_id := 55 ;

     		        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('CTOCITMB: Going to apply normal hold .' ,1);
     		        END IF;

                    else

                        v_hold_id :=  61 ;    /* New Hold Id for Create Supply Activity Hold , Should be changed from 1063 to 61 after Gayatri gives the script*/

     		        IF PG_DEBUG <> 0 THEN
                           oe_debug_pub.add('CTOCITMB: Going to apply create supply activity hold .' ,1);
     		        END IF;

                    end if;




  		    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('CTOCITMB:Calling OM api to apply hold.' ,1);
     		    END IF;

		    l_hold_source_rec.hold_entity_code   := 'O';
                    l_hold_source_rec.hold_id            := v_hold_id ;
                    l_hold_source_rec.hold_entity_id     := l_header_id;
                    l_hold_source_rec.header_id          := l_header_id;
                    l_hold_source_rec.line_id            := l_config_line_id;

		    OE_Holds_PUB.Apply_Holds (
				   p_api_version        => 1.0
                               ,   p_hold_source_rec    => l_hold_source_rec
                               ,   x_return_status      => l_return_status
                               ,   x_msg_count          => l_msg_count
                               ,   x_msg_data           => l_msg_data);

        	    IF (l_return_status = FND_API.G_RET_STS_ERROR) THEN
     		        IF PG_DEBUG <> 0 THEN
                	   oe_debug_pub.add('CTOCITMB:Failed in Apply Holds with expected error.' ,1);
     		        END IF;
                	raise FND_API.G_EXC_ERROR;

        	    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
     		        IF PG_DEBUG <> 0 THEN
                	   oe_debug_pub.add('CTOCITMB:Failed in Apply Holds with unexpected error.' ,1);
     		        END IF;
                	raise FND_API.G_EXC_UNEXPECTED_ERROR;
		    END IF;

     		    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('CTOCITMB: An Exception Hold applied to config line.' ,1);
     		    END IF;
    		    cto_msg_pub.cto_message('BOM','CTO_ORDER_LINE_EXCPN_HOLD');

		else
     		    IF PG_DEBUG <> 0 THEN
                       oe_debug_pub.add('CTOCITMB: Line is already on Hold.' ,1);
     		    END IF;
		end if;
        END IF;
    end if;
    --
    -- End bugfix 2840801
    --


    return (1);

    EXCEPTION

	WHEN NO_DATA_FOUND THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('link_item: ' || 'ERROR: link_item::ndf::'||to_char(lStmtNumber)||'::'||sqlerrm, 1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => l_Msg_Count,
                  p_msg_data  => l_Msg_Data
                );
		return(0);

	WHEN FND_API.G_EXC_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('link_item: ' || 'ERROR: link_item::exp error::'||to_char(lStmtNumber)||sqlerrm, 1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => l_Msg_Count,
                  p_msg_data  => l_Msg_Data
                );
                return(0);

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('link_item: ' || 'ERROR: link_item::unexp error::'||to_char(lStmtNumber)||sqlerrm, 1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => l_Msg_Count,
                  p_msg_data  => l_Msg_Data
                );
                return(0);

        WHEN OTHERS THEN
		IF PG_DEBUG <> 0 THEN
			oe_debug_pub.add ('link_item: ' || 'ERROR: link_item::others::'||to_char(lStmtNumber)||'::'||sqlerrm, 1);
		END IF;
		CTO_MSG_PUB.Count_And_Get(
                  p_msg_count => l_Msg_Count,
                  p_msg_data  => l_Msg_Data
                );
                return(0);
 END link_item;

/*****************************************************************************
chk_model_in_bcod
bcod implies BOM CTO ORDER DEMAND
 checks if model is there in BOM CTO ORDER DEMAND table before the creation of row for configured item in the BOM CTO ORDER DEMAND table. This function is being called from link_item()function
*****************************************************************************/

FUNCTION chk_model_in_bcod(
                            pLineId in number)
RETURN integer
is
  l_dummy number;
  BEGIN
       select oe_line_id into l_dummy
       from bom_cto_order_demand
       where oe_line_id=pLineId;
       return (1);
  EXCEPTION
   when no_data_found then
      return (0);
END chk_model_in_bcod;


--
-- bugfix 2706981: Created a new API for performance reasons.
-- This API would check if a duplicate item name exists.
-- It returns 1 if duplicate exists. Else, it returns 0.
--

FUNCTION check_dup_item(
    pSegment1 	varchar2,
    pSegment2 	varchar2,
    pSegment3 	varchar2,
    pSegment4 	varchar2,
    pSegment5 	varchar2,
    pSegment6 	varchar2,
    pSegment7 	varchar2,
    pSegment8 	varchar2,
    pSegment9 	varchar2,
    pSegment10 	varchar2,
    pSegment11 	varchar2,
    pSegment12 	varchar2,
    pSegment13 	varchar2,
    pSegment14 	varchar2,
    pSegment15 	varchar2,
    pSegment16 	varchar2,
    pSegment17 	varchar2,
    pSegment18 	varchar2,
    pSegment19 	varchar2,
    pSegment20 	varchar2)
RETURN number is

    sql_str		varchar2(2000);
    lcursor		integer;
    xdummy      	number;
    rows_processed 	number;

BEGIN

    IF PG_DEBUG <> 0 THEN
       oe_debug_pub.add( 'Check_dup_item: '|| 'Checking for duplicate item name.. ' ,2 );
    END IF;

    sql_str := 'select 1 from mtl_system_items msi where 1=1 ';

    if pSegment1 is not null then
	sql_str := sql_str||' and msi.segment1 = :pSegment1';
    end if;

    if pSegment2 is not null then
	sql_str := sql_str||' and msi.segment2 = :pSegment2';
    end if;

    if pSegment3 is not null then
	sql_str := sql_str||' and msi.segment3 = :pSegment3';
    end if;

    if pSegment4 is not null then
	sql_str := sql_str||' and msi.segment4 = :pSegment4';
    end if;

    if pSegment5 is not null then
	sql_str := sql_str||' and msi.segment5 = :pSegment5';
    end if;

    if pSegment6 is not null then
	sql_str := sql_str||' and msi.segment6 = :pSegment6';
    end if;

    if pSegment7 is not null then
	sql_str := sql_str||' and msi.segment7 = :pSegment7';
    end if;

    if pSegment8 is not null then
	sql_str := sql_str||' and msi.segment8 = :pSegment8';
    end if;

    if pSegment9 is not null then
	sql_str := sql_str||' and msi.segment9 = :pSegment9';
    end if;

    if pSegment10 is not null then
	sql_str := sql_str||' and msi.segment10 = :pSegment10';
    end if;

    if pSegment11 is not null then
	sql_str := sql_str||' and msi.segment11 = :pSegment11';
    end if;

    if pSegment12 is not null then
	sql_str := sql_str||' and msi.segment12 = :pSegment12';
    end if;

    if pSegment13 is not null then
	sql_str := sql_str||' and msi.segment13 = :pSegment13';
    end if;

    if pSegment14 is not null then
	sql_str := sql_str||' and msi.segment14 = :pSegment14';
    end if;

    if pSegment15 is not null then
	sql_str := sql_str||' and msi.segment15 = :pSegment15';
    end if;

    if pSegment16 is not null then
	sql_str := sql_str||' and msi.segment16 = :pSegment16';
    end if;

    if pSegment17 is not null then
	sql_str := sql_str||' and msi.segment17 = :pSegment17';
    end if;

    if pSegment18 is not null then
	sql_str := sql_str||' and msi.segment18 = :pSegment18';
    end if;

    if pSegment19 is not null then
	sql_str := sql_str||' and msi.segment19 = :pSegment19';
    end if;

    if pSegment20 is not null then
	sql_str := sql_str||' and msi.segment20 = :pSegment20';
    end if;


    IF PG_DEBUG <> 0 THEN
        oe_debug_pub.add( 'Check_dup_item: '||'sql_str : '||sql_str, 3);
    END IF;

    lcursor := dbms_sql.open_cursor;

    dbms_sql.parse(lcursor, sql_str, dbms_sql.native);

    if pSegment1 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment1', pSegment1);
    end if;
    if pSegment2 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment2', pSegment2);
    end if;
    if pSegment3 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment3', pSegment3);
    end if;
    if pSegment4 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment4', pSegment4);
    end if;
    if pSegment5 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment5', pSegment5);
    end if;
    if pSegment6 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment6', pSegment6);
    end if;
    if pSegment7 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment7', pSegment7);
    end if;
    if pSegment8 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment8', pSegment8);
    end if;
    if pSegment9 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment9', pSegment9);
    end if;
    if pSegment10 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment10', pSegment10);
    end if;
    if pSegment11 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment11', pSegment11);
    end if;
    if pSegment12 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment12', pSegment12);
    end if;
    if pSegment13 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment13', pSegment13);
    end if;
    if pSegment14 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment14', pSegment14);
    end if;
    if pSegment15 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment15', pSegment15);
    end if;
    if pSegment16 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment16', pSegment16);
    end if;
    if pSegment17 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment17', pSegment17);
    end if;
    if pSegment18 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment18', pSegment18);
    end if;
    if pSegment19 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment19', pSegment19);
    end if;
    if pSegment20 is not null then
        dbms_sql.bind_variable(lcursor,'pSegment20', pSegment20);
    end if;

    dbms_sql.define_column(lcursor, 1, xdummy);

    rows_processed := dbms_sql.execute_and_fetch(lcursor);

    dbms_sql.close_cursor(lcursor);

    if rows_processed > 0 then
        IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add( 'Check_dup_item: '||'Duplicate item name found.');
	END IF;
	return 1;
    else
        IF PG_DEBUG <> 0 THEN
           oe_debug_pub.add( 'Check_dup_item: '||'Duplicate item name NOT found.');
        END IF;
	return 0;
    end if;

END check_dup_item;


--
-- bugfix 3026929: local API for dynamic insert.
--

PROCEDURE populate_item_revision(pConfigId	number,
				 pModelId	number,
				 pLineId	number,
				 xReturnStatus	OUT NOCOPY varchar2) is

	--sql_stmt 	varchar2(4000);  Bugfix 6063990
	stmtnum		number;
	x_item_rev_seq	number ;

BEGIN
	xReturnStatus	:= fnd_api.G_RET_STS_SUCCESS;

	stmtnum := 1;

	IF PG_DEBUG <> 0 THEN    --Bugfix 6063990
                oe_debug_pub.add('Inside populate_item_revision');
	END IF;
	--sql_stmt := 'SELECT MTL_ITEM_REVISIONS_B_S.nextval FROM dual';

	--IF PG_DEBUG <> 0 THEN
         --       oe_debug_pub.add(sql_stmt,3);
	--END IF;

	--EXECUTE IMMEDIATE sql_stmt INTO x_item_rev_seq ;

	--IF PG_DEBUG <> 0 THEN
            --    oe_debug_pub.add(' x_item_rev_seq = '|| x_item_rev_seq ,1);

      --  END IF;

--3340844 joing to mp2 and distinct has been removed
	stmtnum := 2;
	/*Bugfix 5851244: As Release 11.5.10 was shipped as one SCM patch,
          we are assuming that customers will always be on ITEMS 11.5.10 data model i.e. they will have tables _B and _TL.
          So changing dynamic sql into static sql */

	--sql_stmt :=
	 insert into mtl_item_revisions_b
              (inventory_item_id,
               organization_id,
               revision,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               implementation_date,
               effectivity_date,
	       OBJECT_VERSION_NUMBER,
	       REVISION_ID,
	       REVISION_LABEL --3340844
              )
        select -- distinct
               	pConfigId,		      --Bugfix 5851244: Removing bind variables to make sql static
               	mp1.organization_id,
                mp1.starting_revision,
                sysdate,
                gUserId,                     -- last_updated_by
                sysdate,
                gUserId,                     -- created_by
                gLoginId,                    -- last_update_login
                sysdate,
                sysdate,
	        1,                           --would be 1 for initial creation of item
	         MTL_ITEM_REVISIONS_B_S.nextval, -- 3338108 --:x_item_rev_seq --revision_id is generated from sequence
               	mp1.starting_revision --3340844
         from
               mtl_parameters mp1,
               mtl_system_items m
        where  m.inventory_item_id = pConfigId
          and  m.organization_id = mp1.organization_id
          and NOT EXISTS
                (select NULL
                from MTL_ITEM_REVISIONS_B
                where inventory_item_id = pConfigId
                and organization_id = mp1.organization_id);



	/*IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(sql_stmt,3);
	END IF;*/   --Bugfix 6063990

	--EXECUTE IMMEDIATE sql_stmt USING pConfigId, gUserId, gUserId, gLoginId, x_item_rev_seq, pModelId, pLineId, pConfigId;
	--EXECUTE IMMEDIATE sql_stmt USING pConfigId, gUserId, gUserId, gLoginId,pModelId, pLineId, pConfigId;
	--EXECUTE IMMEDIATE sql_stmt USING pConfigId, gUserId, gUserId, gLoginId,pConfigId,pConfigId;      Bugfix 6063990

	IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Inserted into mtl_item_revisions_b for item ' || pConfigId || ' rows ' || SQL%ROWCOUNT );
	END IF;



        --insert into _tl table so that item is visible in revisions form
	--for multi-lingual support

	stmtnum := 3;


--sql_stmt :=
	insert into mtl_item_revisions_tl (
                inventory_item_id,
                organization_id,
		revision_id,
                language,
                source_lang,
                description,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login
                )
        select  distinct pConfigId,                   --Bugfix 6063990: Removing bind variables to make sql static
                mp1.organization_id,
		mr.revision_id,
                l.language_code,
                userenv('LANG'),
                m.description,
                sysdate,
                gUserId,                              --last_updated_by
                sysdate,
                gUserId,                              --created_by
                gLoginId                              --last_update_login
        from
                mtl_parameters mp1,
                mtl_system_items_tl m,
                bom_cto_src_orgs bcso,
                fnd_languages  l,
		mtl_item_revisions_b mr, --3338108
                mtl_parameters mp2  --4109427
        where  m.inventory_item_id = pModelId
        and bcso.model_item_id = m.inventory_item_id
        and bcso.line_id = pLineId
        and m.organization_id   = mp1.organization_id
        and mp2.organization_id = bcso.organization_id   --4109427
	and ((mp1.organization_id = bcso.organization_id) --4109427
             or (mp1.organization_id = mp2.master_organization_id))  --4109427
        and  l.installed_flag In ('I', 'B')
        and  l.language_code  = m.language
	and  mr.inventory_item_id = pConfigId  --3338108
	and  mr.organization_id =  mp1.organization_id --3338108
        and  NOT EXISTS
                (select NULL
                from  mtl_item_revisions_tl  t
                where  t.inventory_item_id = pConfigId
                and  t.organization_id = mp1.organization_id
                and  t.revision_id = mr.revision_id   --3338108
                and  t.language = l.language_code );



	/*IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add(sql_stmt,3);
	END IF;*/   --Bugfix 6063990

	--EXECUTE IMMEDIATE sql_stmt USING pConfigId, x_item_rev_seq, gUserId, gUserId, gLoginId, pModelId, pLineId, pConfigId, x_item_rev_seq;

	--EXECUTE IMMEDIATE sql_stmt USING pConfigId,gUserId, gUserId, gLoginId, pModelId, pLineId, pConfigId,pConfigId;   Bugfix 6063990

	IF PG_DEBUG <> 0 THEN
                oe_debug_pub.add('Inserted into mtl_system_items_tl.');
	END IF;

EXCEPTION
	when OTHERS then
		oe_debug_pub.add ('Failed in dynamic query : '||sqlerrm);
		xReturnStatus := fnd_api.G_RET_STS_UNEXP_ERROR;

END populate_item_revision;





procedure create_preconfigured_item( p_line_id in number
                         , p_model_id       in number
                         , p_config_id       in number
                         , p_lItemtype       in varchar2 )
is

	l_ind_cnt number;  --Bugfix 8305535
	sqlcnt1   number;  --Bugfix 8305535

BEGIN

       oe_debug_pub.add( 'Entered Create Preconfigured Item ' , 1 ) ;


       select substr( attribute_name, instr( attribute_name, '.' )+ 1 ) , control_level
       BULK COLLECT
       INTO g_attribute_name_tab, g_control_level_tab
       from mtl_item_attributes
       where control_level = 1 ;


      if( get_attribute_control( 'atp_flag' ) = 1 ) then
          oe_debug_pub.add( 'ATP flag is master controlled ' , 1 );
      else
          oe_debug_pub.add( 'ATP flag is org controlled ' , 1 );

      end if;

      if( get_attribute_control( 'atp_components_flag' ) = 1 ) then
          oe_debug_pub.add( 'ATP components flag is master controlled ' , 1 );
      else
          oe_debug_pub.add( 'ATP components flag is org controlled ' , 1 );

      end if;


      if( get_attribute_control( 'market_price' ) = 1 ) then
          oe_debug_pub.add( 'market_price is master controlled ' , 1 );
      else
          oe_debug_pub.add( 'market_price flag is org controlled ' , 1 );

      end if;




       oe_debug_pub.add( 'Entered Create Preconfigured Item ' , 1 ) ;

        insert into mtl_system_items_b
                (inventory_item_id,
                organization_id,
                last_update_date,
                last_updated_by,
                creation_date,
                created_by,
                last_update_login,
                summary_flag,
                enabled_flag,
                start_date_active,
                end_date_active,
                description,
                buyer_id,
                accounting_rule_id,
                invoicing_rule_id,
                segment1,
                segment2,
                segment3,
                segment4,
                segment5,
                segment6,
                segment7,
                segment8,
                segment9,
                segment10,
                segment11,
                segment12,
                segment13,
                segment14,
                segment15,
                segment16,
                segment17,
                segment18,
                segment19,
                segment20,
                attribute_category,
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
                attribute16,  -- Bug 9223457
                attribute17,
                attribute18,
                attribute19,
                attribute20,
                attribute21,
                attribute22,
                attribute23,
                attribute24,
                attribute25,
                attribute26,
                attribute27,
                attribute28,
                attribute29,
                attribute30,
                purchasing_item_flag,
                shippable_item_flag,
                customer_order_flag,
                internal_order_flag,
                service_item_flag,
                inventory_item_flag,
                eng_item_flag,
                inventory_asset_flag,
                purchasing_enabled_flag,
                customer_order_enabled_flag,
                internal_order_enabled_flag,
                so_transactions_flag,
                mtl_transactions_enabled_flag,
                stock_enabled_flag,
                bom_enabled_flag,
                build_in_wip_flag,
                revision_qty_control_code,
                item_catalog_group_id,
                catalog_status_flag,
                returnable_flag,
                default_shipping_org,
                collateral_flag,
                taxable_flag,
                allow_item_desc_update_flag,
                inspection_required_flag,
                receipt_required_flag,
                market_price,
                hazard_class_id,
                rfq_required_flag,
                qty_rcv_tolerance,
                un_number_id,
                price_tolerance_percent,
                asset_category_id,
                rounding_factor,
                unit_of_issue,
                enforce_ship_to_location_code,
                allow_substitute_receipts_flag,
                allow_unordered_receipts_flag,
                allow_express_delivery_flag,
                days_early_receipt_allowed,
                days_late_receipt_allowed,
                receipt_days_exception_code,
                receiving_routing_id,
                invoice_close_tolerance,
                receive_close_tolerance,
                auto_lot_alpha_prefix,
                start_auto_lot_number,
                lot_control_code,
                shelf_life_code,
                shelf_life_days,
                serial_number_control_code,
                start_auto_serial_number,
                auto_serial_alpha_prefix,
                source_type,
                source_organization_id,
                source_subinventory,
                expense_account,
                encumbrance_account,
                restrict_subinventories_code,
                unit_weight,
                weight_uom_code,
                volume_uom_code,
                unit_volume,
                restrict_locators_code,
                location_control_code,
                shrinkage_rate,
                acceptable_early_days,
                planning_time_fence_code,
                demand_time_fence_code,
                lead_time_lot_size,
                std_lot_size,
                cum_manufacturing_lead_time,
                overrun_percentage,
                acceptable_rate_increase,
                acceptable_rate_decrease,
                cumulative_total_lead_time,
                planning_time_fence_days,
                demand_time_fence_days,
                end_assembly_pegging_flag,
                planning_exception_set,
                bom_item_type,
                pick_components_flag,
                replenish_to_order_flag,
                base_item_id,
                atp_components_flag,
                atp_flag,
                fixed_lead_time,
                variable_lead_time,
                wip_supply_locator_id,
                wip_supply_type,
                wip_supply_subinventory,
                primary_uom_code,
                primary_unit_of_measure,
                allowed_units_lookup_code,
                cost_of_sales_account,
                sales_account,
                default_include_in_rollup_flag,
                inventory_item_status_code,
                inventory_planning_code,
                planner_code,
                planning_make_buy_code,
                fixed_lot_multiplier,
                rounding_control_type,
                carrying_cost,
                postprocessing_lead_time,
                preprocessing_lead_time,
                full_lead_time,
                order_cost,
                mrp_safety_stock_percent,
                mrp_safety_stock_code,
                min_minmax_quantity,
                max_minmax_quantity,
                minimum_order_quantity,
                fixed_order_quantity,
                fixed_days_supply,
                maximum_order_quantity,
                atp_rule_id,
                picking_rule_id,
                reservable_type,
                positive_measurement_error,
                negative_measurement_error,
                engineering_ecn_code,
                engineering_item_id,
                engineering_date,
                service_starting_delay,
                vendor_warranty_flag,
                serviceable_component_flag,
                serviceable_product_flag,
                base_warranty_service_id,
                payment_terms_id,
                preventive_maintenance_flag,
                primary_specialist_id,
                secondary_specialist_id,
                serviceable_item_class_id,
                time_billable_flag,
                material_billable_flag,
                expense_billable_flag,
                prorate_service_flag,
                coverage_schedule_id,
                service_duration_period_code,
                service_duration,
                max_warranty_amount,
                response_time_period_code,
                response_time_value,
                new_revision_code,
                tax_code,
                must_use_approved_vendor_flag,
                safety_stock_bucket_days,
                auto_reduce_mps,
                costing_enabled_flag,
                invoiceable_item_flag,
                invoice_enabled_flag,
                outside_operation_flag,
                outside_operation_uom_type,
                auto_created_config_flag,
                cycle_count_enabled_flag,
                item_type,
                model_config_clause_name,
                ship_model_complete_flag,
                mrp_planning_code,
                repetitive_planning_flag,
                return_inspection_requirement,
                effectivity_control,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
		comms_nl_trackable_flag,               -- bugfix 2200256
		default_so_source_type,
		create_supply_flag,
			-- begin bugfix 2336548
		lot_status_enabled,
		default_lot_status_id,
		serial_status_enabled,
		default_serial_status_id,
		lot_split_enabled,
		lot_merge_enabled,
		bulk_picked_flag,
			-- end bugfix 2336548
			-- begin bugfix 2400609
		FINANCING_ALLOWED_FLAG,
 		EAM_ITEM_TYPE ,
 		EAM_ACTIVITY_TYPE_CODE,
 		EAM_ACTIVITY_CAUSE_CODE,
 		EAM_ACT_NOTIFICATION_FLAG,
 		EAM_ACT_SHUTDOWN_STATUS,
 		SUBSTITUTION_WINDOW_CODE,
 		SUBSTITUTION_WINDOW_DAYS,
 		PRODUCT_FAMILY_ITEM_ID,
 		CHECK_SHORTAGES_FLAG,
 		PLANNED_INV_POINT_FLAG,
 		OVER_SHIPMENT_TOLERANCE,
 		UNDER_SHIPMENT_TOLERANCE,
 		OVER_RETURN_TOLERANCE,
 		UNDER_RETURN_TOLERANCE,
 		PURCHASING_TAX_CODE,
 		OVERCOMPLETION_TOLERANCE_TYPE,
 		OVERCOMPLETION_TOLERANCE_VALUE,
 		INVENTORY_CARRY_PENALTY,
 		OPERATION_SLACK_PENALTY,
 		UNIT_LENGTH,
 		UNIT_WIDTH,
 		UNIT_HEIGHT,
 		LOT_TRANSLATE_ENABLED,
 		CONTAINER_ITEM_FLAG,
 		VEHICLE_ITEM_FLAG,
 		DIMENSION_UOM_CODE,
 		SECONDARY_UOM_CODE,
 		MAXIMUM_LOAD_WEIGHT,
 		MINIMUM_FILL_PERCENT,
 		CONTAINER_TYPE_CODE,
 		INTERNAL_VOLUME,
 		EQUIPMENT_TYPE,
 		INDIVISIBLE_FLAG,
 		GLOBAL_ATTRIBUTE_CATEGORY,
 		GLOBAL_ATTRIBUTE1,
 		GLOBAL_ATTRIBUTE2,
 		GLOBAL_ATTRIBUTE3,
 		GLOBAL_ATTRIBUTE4,
 		GLOBAL_ATTRIBUTE5,
 		GLOBAL_ATTRIBUTE6,
 		GLOBAL_ATTRIBUTE7,
 		GLOBAL_ATTRIBUTE8,
 		GLOBAL_ATTRIBUTE9,
 		GLOBAL_ATTRIBUTE10,
		DUAL_UOM_CONTROL,
 		DUAL_UOM_DEVIATION_HIGH,
 		DUAL_UOM_DEVIATION_LOW,
                CONTRACT_ITEM_TYPE_CODE,
 		SUBSCRIPTION_DEPEND_FLAG,
 		SERV_REQ_ENABLED_CODE,
 		SERV_BILLING_ENABLED_FLAG,
 		RELEASE_TIME_FENCE_CODE,	-- 2898851
 		RELEASE_TIME_FENCE_DAYS,	-- 2898851
 		DEFECT_TRACKING_ON_FLAG,        -- 2858080
 		SERV_IMPORTANCE_LEVEL,
			 -- end bugfix 2400609
	        WEB_STATUS ,   --bugfix 2727983
                tracking_quantity_ind,   /* Additional Attributes for Item in patchset J */
                ont_pricing_qty_source,
                approval_status ,
                vmi_minimum_units,
                vmi_minimum_days,
                vmi_maximum_units,
                vmi_maximum_days,
                vmi_fixed_order_quantity,
                so_authorization_flag,
                consigned_flag,
                asn_autoexpire_flag,
                vmi_forecast_type,
                forecast_horizon,
                days_tgt_inv_supply,
                days_tgt_inv_window,
                days_max_inv_supply,
                days_max_inv_window,
                critical_component_flag,
                drp_planned_flag,
                exclude_from_budget_flag,
                convergence,
                continous_transfer,
                divergence,
			--begin r12,4574899
		lot_divisible_flag,
		grade_control_flag,
		child_lot_flag,
                child_lot_validation_flag,
		copy_lot_attribute_flag,
		parent_child_generation_flag,  --Bugfix 8821149
		lot_substitution_enabled,      --Bugfix 8821149
		recipe_enabled_flag,
                process_quality_enabled_flag,
		process_execution_enabled_flag,
	        process_costing_enabled_flag,
		hazardous_material_flag,
		preposition_point,
		repair_program,
		outsourced_assembly
			-- end rl2,4574899

                )
        select /*+ USE_NL(MP1) */
               distinct
                p_config_id,
                m.organization_id,
                sysdate,
                gUserId,          -- last_updated_by
                sysdate,
                gUserId,          -- created_by
                gLoginId ,        -- last_update_login
                decode( get_attribute_control( 'summary_flag') , 1 , config.summary_flag, m.summary_flag),
                decode( get_attribute_control( 'enabled_flag' ) , 1 , config.enabled_flag , m.enabled_flag),
                decode( get_attribute_control( 'start_date_active'), 1 , config.start_date_active, m.start_date_active) ,
                decode( get_attribute_control( 'end_date_active'), 1 , config.end_date_active, m.end_date_active) ,
                decode( get_attribute_control( 'description' ) , 1 , config.description, m.description) ,
                decode( get_attribute_control( 'buyer_id') , 1 , config.buyer_id, m.buyer_id) ,
                decode( get_attribute_control( 'accounting_rule_id' ) , 1 , config.accounting_rule_id, m.accounting_rule_id) ,
                decode( get_attribute_control( 'invoicing_rule_id' ) , 1 , config.invoicing_rule_id, m.invoicing_rule_id) ,
                config.segment1,
                config.segment2,
                config.segment3,
                config.segment4,
                config.segment5,
                config.segment6,
                config.segment7,
                config.segment8,
                config.segment9,
                config.segment10,
                config.segment11,
                config.segment12,
                config.segment13,
                config.segment14,
                config.segment15,
                config.segment16,
                config.segment17,
                config.segment18,
                config.segment19,
                config.segment20,
                decode( get_attribute_control( 'attribute_category'), 1 , config.attribute_category, m.attribute_category),
                m.attribute1,
                m.attribute2,
                m.attribute3,
                m.attribute4,
                m.attribute5,
                m.attribute6,
                m.attribute7,
                m.attribute8,
                m.attribute9,
                m.attribute10,
                m.attribute11,
                m.attribute12,
                m.attribute13,
                m.attribute14,
                m.attribute15,
                m.attribute16,  -- Bug 9223457
                m.attribute17,
                m.attribute18,
                m.attribute19,
                m.attribute20,
                m.attribute21,
                m.attribute22,
                m.attribute23,
                m.attribute24,
                m.attribute25,
                m.attribute26,
                m.attribute27,
                m.attribute28,
                m.attribute29,
                m.attribute30,
                'Y',		-- purchasing_item_flag,
                'Y',                              -- Shippable Flag
                'Y',            -- CUSTOMER_ORDER_FLAG
                'Y',               -- INTERNAL_ORDER_FLAG
                decode( get_attribute_control( 'service_item_flag' ), 1, config.service_item_flag , m.service_item_flag) ,
                'Y',                              -- INVENTORY_ITEM_FLAG
                decode( get_attribute_control( 'eng_item_flag' ) , 1 , config.eng_item_flag , m.eng_item_flag) ,
                decode( get_attribute_control( 'inventory_asset_flag' ) , 1 , config.inventory_asset_flag , m.inventory_asset_flag) ,
                'Y',		-- purchasing_enabled_flag,
                'Y',            -- CUSTOMER_ORDER_ENABLED_FLAG
                'Y',            -- INTERNAL_ORDER_ENABLED_FLAG
                'Y',                        -- SO_TRANSACTIONS_FLAG
                'Y',                     -- MTL_TRANSACTIONS_ENABLED_FLAG
                'Y',                               -- STOCK_ENABLED_FLAG
                'Y',                               -- BOM_ENABLED_FLAG
                'Y',                               -- BUILD_IN_WIP_FLAG
                decode( get_attribute_control( 'revision_qty_control_code' ) , 1 , config.revision_qty_control_code , m.revision_qty_control_code) ,
                decode( get_attribute_control( 'item_catalog_group_id' ) , 1 , config.item_catalog_group_id, m.item_catalog_group_id) ,  -- check, earlier it was always from mfg org
                decode( get_attribute_control( 'catalog_status_flag' ) , 1 , config.catalog_status_flag, m.catalog_status_flag) ,
                decode( get_attribute_control( 'returnable_flag' ) , 1 , config.returnable_flag, m.returnable_flag) ,
                decode( get_attribute_control( 'default_shipping_org' ) , 1, config.default_shipping_org, m.default_shipping_org),
                decode( get_attribute_control( 'collateral_flag') , 1 , config.collateral_flag , m.collateral_flag) ,
                decode( get_attribute_control( 'taxable_flag' ) , 1 , config.taxable_flag, m.taxable_flag) ,
                decode( get_attribute_control( 'allow_item_desc_update_flag' ) , 1, config.allow_item_desc_update_flag, m.allow_item_desc_update_flag),
                decode( get_attribute_control( 'inspection_required_flag' ), 1 , config.inspection_required_flag , m.inspection_required_flag),
                decode( get_attribute_control( 'receipt_required_flag' ), 1, config.receipt_required_flag, m.receipt_required_flag) ,
                decode( get_attribute_control( 'market_price' ) , 1 , config.market_price, m.market_price) ,
                decode( get_attribute_control( 'hazard_class_id' ), 1 , config.hazard_class_id, m.hazard_class_id),
                decode( get_attribute_control( 'rfq_required_flag'), 1 , config.rfq_required_flag, m.rfq_required_flag),
                decode( get_attribute_control( 'qty_rcv_tolerance'), 1, config.qty_rcv_tolerance, m.qty_rcv_tolerance),
                decode( get_attribute_control( 'un_number_id' ), 1 , config.un_number_id, m.un_number_id),
                decode( get_attribute_control( 'price_tolerance_percent'), 1 , config.price_tolerance_percent, m.price_tolerance_percent) ,
                decode( get_attribute_control( 'asset_category_id') , 1 , config.asset_category_id, m.asset_category_id) ,
                decode( get_attribute_control( 'rounding_factor' ) , 1 , config.rounding_factor, m.rounding_factor) ,
                decode( get_attribute_control( 'unit_of_issue') , 1 , config.unit_of_issue, m.unit_of_issue) ,
                decode( get_attribute_control( 'enforce_ship_to_location_code' ) , 1 , config.enforce_ship_to_location_code , m.enforce_ship_to_location_code),
                decode( get_attribute_control( 'allow_substitute_receipts_flag' ) , 1 , config.allow_substitute_receipts_flag, m.allow_substitute_receipts_flag) ,
                decode( get_attribute_control( 'allow_unordered_receipts_flag' ) , 1 , config.allow_unordered_receipts_flag, m.allow_unordered_receipts_flag) ,
                decode( get_attribute_control( 'allow_express_delivery_flag' ) ,1 , config.allow_express_delivery_flag, m.allow_express_delivery_flag) ,
                decode( get_attribute_control( 'days_early_receipt_allowed') , 1, config.days_early_receipt_allowed, m.days_early_receipt_allowed) ,
                decode( get_attribute_control( 'days_late_receipt_allowed' ) , 1 , config.days_late_receipt_allowed , m.days_late_receipt_allowed) ,
                decode( get_attribute_control( 'receipt_days_exception_code')  , 1 , config.receipt_days_exception_code, m.receipt_days_exception_code) ,
                decode( get_attribute_control( 'receiving_routing_id' ) , 1 , config.receiving_routing_id, m.receiving_routing_id),
                decode( get_attribute_control( 'invoice_close_tolerance'), 1, config.invoice_close_tolerance, m.invoice_close_tolerance) ,
                decode( get_attribute_control( 'receive_close_tolerance') , 1 , config.receive_close_tolerance , m.receive_close_tolerance) ,
                decode( get_attribute_control( 'auto_lot_alpha_prefix') , 1, config.auto_lot_alpha_prefix, m.auto_lot_alpha_prefix) ,
                decode( get_attribute_control( 'start_auto_lot_number') , 1, config.start_auto_lot_number, m.start_auto_lot_number) ,
                decode( get_attribute_control( 'lot_control_code') ,1 , config.lot_control_code, m.lot_control_code) ,
                decode( get_attribute_control( 'shelf_life_code'), 1 , config.shelf_life_code, m.shelf_life_code) ,
                decode( get_attribute_control( 'shelf_life_days') , 1, config.shelf_life_days, m.shelf_life_days) ,
                decode( get_attribute_control( 'serial_number_control_code' ) ,1,  config.serial_number_control_code, m.serial_number_control_code) ,
                decode( get_attribute_control( 'start_auto_serial_number' ) , 1 , config.start_auto_serial_number, m.start_auto_serial_number) ,
                decode( get_attribute_control( 'auto_serial_alpha_prefix') ,1 , config.auto_serial_alpha_prefix, m.auto_serial_alpha_prefix) ,
                decode( get_attribute_control( 'source_type' ) ,1 , config.source_type, m.source_type) ,
                decode( get_attribute_control( 'source_organization_id') , 1 , config.source_organization_id, m.source_organization_id) ,
                decode( get_attribute_control( 'source_subinventory') ,1 , config.source_subinventory, m.source_subinventory) ,
                decode( get_attribute_control( 'expense_account') , 1, config.expense_account, m.expense_account) ,
                decode( get_attribute_control( 'encumbrance_account') , 1 , config.encumbrance_account, m.encumbrance_account) ,
                decode( get_attribute_control( 'restrict_subinventories_code' ) , 1 , config.restrict_subinventories_code, m.restrict_subinventories_code) ,
		-- bugfix 2301167 : we will calculate the unit weight/vol later..
                null,		-- m.unit_weight,
                null,		-- m.weight_uom_code,
                null,		-- m.volume_uom_code,
                null,		-- m.unit_volume,
		-- end bugfix 2301167
                decode( get_attribute_control( 'restrict_locators_code'), 1, config.restrict_locators_code, m.restrict_locators_code) ,
                decode( get_attribute_control( 'location_control_code') , 1 , config.location_control_code, m.location_control_code) ,
                decode( get_attribute_control( 'shrinkage_rate' ) , 1, config.shrinkage_rate, m.shrinkage_rate) ,
                decode( get_attribute_control( 'acceptable_early_days') , 1 , config.acceptable_early_days, m.acceptable_early_days) ,
                decode( get_attribute_control( 'planning_time_fence_code' ) , 1 , config.planning_time_fence_code, m.planning_time_fence_code) ,
                decode( get_attribute_control( 'demand_time_fence_code') , 1 , config.demand_time_fence_code,  m.demand_time_fence_code) ,
                decode( get_attribute_control( 'lead_time_lot_size') ,1, config.lead_time_lot_size, m.lead_time_lot_size) ,
                decode( get_attribute_control( 'std_lot_size' ) , 1, config.std_lot_size, m.std_lot_size) ,
                decode( get_attribute_control( 'cum_manufacturing_lead_time' ) , 1 , config.cum_manufacturing_lead_time, m.cum_manufacturing_lead_time) ,
                decode( get_attribute_control( 'overrun_percentage') , 1, config.overrun_percentage, m.overrun_percentage) ,
                decode( get_attribute_control( 'acceptable_rate_increase'), 1, config.acceptable_rate_increase, m.acceptable_rate_increase) ,
                decode( get_attribute_control( 'acceptable_rate_decrease') , 1 , config.acceptable_rate_decrease, m.acceptable_rate_decrease) ,
                decode( get_attribute_control( 'cumulative_total_lead_time' ) , 1 , config.cumulative_total_lead_time, m.cumulative_total_lead_time) ,
                decode( get_attribute_control( 'planning_time_fence_days' ) , 1, config.planning_time_fence_days, m.planning_time_fence_days) ,
                decode( get_attribute_control( 'demand_time_fence_days') , 1, config.demand_time_fence_days, m.demand_time_fence_days) ,
                decode( get_attribute_control( 'end_assembly_pegging_flag') ,1 , config.end_assembly_pegging_flag , m.end_assembly_pegging_flag) ,
                decode( get_attribute_control( 'planning_exception_set' ) , 1 , config.planning_exception_set, m.planning_exception_set) ,
                4,                                 -- BOM_ITEM_TYPE : standard
                'N',                               -- PICK_COMPONENTS_FLAG
                'Y',                               -- REPLENISH_TO_ORDER_FLAG
                p_model_id,                          -- Base Model ID
                decode( get_attribute_control( 'atp_components_flag') , 1, config.atp_components_flag, evaluate_atp_attributes( m.atp_flag, m.atp_components_flag )) ,
                decode( get_attribute_control( 'atp_flag') , 1, config.atp_flag, get_atp_flag) ,
                decode( get_attribute_control( 'fixed_lead_time') ,1 , config.fixed_lead_time, m.fixed_lead_time) ,
                decode( get_attribute_control( 'variable_lead_time') , 1 , config.variable_lead_time, m.variable_lead_time) ,
                decode( get_attribute_control( 'wip_supply_locator_id' ) , 1, config.wip_supply_locator_id, m.wip_supply_locator_id) ,
                decode( get_attribute_control( 'wip_supply_type' ) , 1 , config.wip_supply_type , m.wip_supply_type) ,
                decode( get_attribute_control( 'wip_supply_subinventory' ) , 1 , config.wip_supply_subinventory, m.wip_supply_subinventory) ,
                decode( get_attribute_control( 'primary_uom_code' ) , 1 , config.primary_uom_code, m.primary_uom_code) ,
                decode( get_attribute_control( 'primary_unit_of_measure' ) , 1 , config.primary_unit_of_measure, m.primary_unit_of_measure) ,
                decode( get_attribute_control( 'allowed_units_lookup_code' ) , 1 , config.allowed_units_lookup_code, m.allowed_units_lookup_code) ,
                decode( get_attribute_control( 'cost_of_sales_account' ) , 1 , config.cost_of_sales_account, m.cost_of_sales_account) ,
                decode( get_attribute_control( 'sales_account' ) , 1, config.sales_account, m.sales_account) ,
                'Y',                        -- DEFAULT_INCLUDE_IN_ROLLUP_FLAG
                decode( get_attribute_control( 'inventory_item_status_code' ) , 1 , config.inventory_item_status_code, m.inventory_item_status_code) ,
                decode( get_attribute_control( 'inventory_planning_code') , 1, config.inventory_planning_code, m.inventory_planning_code) ,
                decode( get_attribute_control( 'planner_code') , 1 , config.planner_code, m.planner_code) ,
                decode( get_attribute_control( 'planning_make_buy_code' ) , 1 , config.planning_make_buy_code, m.planning_make_buy_code) ,
                decode( get_attribute_control( 'fixed_lot_multiplier' ) , 1 , config.fixed_lot_multiplier, m.fixed_lot_multiplier) ,
                decode( get_attribute_control( 'rounding_control_type' ) , 1, config.rounding_control_type, m.rounding_control_type) ,
                decode( get_attribute_control( 'carrying_cost' ) ,1 , config.carrying_cost, m.carrying_cost) ,
                decode( get_attribute_control( 'postprocessing_lead_time') , 1, config.postprocessing_lead_time, m.postprocessing_lead_time) ,
                decode( get_attribute_control( 'preprocessing_lead_time' ) , 1 , config.preprocessing_lead_time, m.preprocessing_lead_time) ,
                decode( get_attribute_control( 'full_lead_time') , 1,  config.full_lead_time, m.full_lead_time) ,
                decode( get_attribute_control( 'order_cost') , 1, config.order_cost, m.order_cost) ,
                decode( get_attribute_control( 'mrp_safety_stock_percent') , 1, config.mrp_safety_stock_percent, m.mrp_safety_stock_percent) ,
                decode( get_attribute_control( 'mrp_safety_stock_code' ) , 1,  config.mrp_safety_stock_code, m.mrp_safety_stock_code) ,
                decode( get_attribute_control( 'min_minmax_quantity' ) , 1, config.min_minmax_quantity, m.min_minmax_quantity) ,
                decode( get_attribute_control( 'max_minmax_quantity' ) , 1 , config.max_minmax_quantity, m.max_minmax_quantity) ,
                decode( get_attribute_control( 'minimum_order_quantity' ) , 1 , config.minimum_order_quantity , m.minimum_order_quantity) ,
                decode( get_attribute_control( 'fixed_order_quantity' ) , 1 , config.fixed_order_quantity, m.fixed_order_quantity) ,
                decode( get_attribute_control( 'fixed_days_supply' ) , 1 , config.fixed_days_supply, m.fixed_days_supply) ,
                decode( get_attribute_control( 'maximum_order_quantity' ) , 1, config.maximum_order_quantity, m.maximum_order_quantity) ,
                decode( get_attribute_control( 'atp_rule_id' ) , 1, config.atp_rule_id, m.atp_rule_id) ,
                decode( get_attribute_control( 'picking_rule_id' ) , 1, config.picking_rule_id, m.picking_rule_id) ,
                1,                                      -- m.reservable_type
                decode( get_attribute_control( 'positive_measurement_error' ) , 1, config.positive_measurement_error, m.positive_measurement_error) ,
                decode( get_attribute_control( 'negative_measurement_error' ) , 1, config.negative_measurement_error, m.negative_measurement_error) ,
                decode( get_attribute_control( 'engineering_ecn_code' ) , 1 , config.engineering_ecn_code, m.engineering_ecn_code) ,
                decode( get_attribute_control( 'engineering_item_id' ) , 1 , config.engineering_item_id, m.engineering_item_id) ,
                decode( get_attribute_control( 'engineering_date' ) , 1, config.engineering_date, m.engineering_date) ,
                decode( get_attribute_control( 'service_starting_delay') , 1 , config.service_starting_delay, m.service_starting_delay) ,
                decode( get_attribute_control( 'vendor_warranty_flag') , 1 , config.vendor_warranty_flag, m.vendor_warranty_flag) ,
                decode( get_attribute_control( 'serviceable_component_flag' ) , 1, config.serviceable_component_flag , m.serviceable_component_flag) ,
                decode( get_attribute_control( 'serviceable_product_flag' ) , 1, config.serviceable_product_flag , m.serviceable_product_flag) ,
                decode( get_attribute_control( 'base_warranty_service_id' ) ,1 , config.base_warranty_service_id, m.base_warranty_service_id) ,
                decode( get_attribute_control( 'payment_terms_id' ) , 1 , config.payment_terms_id, m.payment_terms_id) ,
                decode( get_attribute_control( 'preventive_maintenance_flag') , 1,  config.preventive_maintenance_flag, m.preventive_maintenance_flag) ,
                decode( get_attribute_control( 'primary_specialist_id') , 1 , config.primary_specialist_id, m.primary_specialist_id),
                decode( get_attribute_control( 'secondary_specialist_id') , 1 , config.secondary_specialist_id, m.secondary_specialist_id) ,
                decode( get_attribute_control( 'serviceable_item_class_id') , 1, config.serviceable_item_class_id, m.serviceable_item_class_id) ,
                decode( get_attribute_control( 'time_billable_flag' ) , 1 , config.time_billable_flag, m.time_billable_flag) ,
                decode( get_attribute_control( 'material_billable_flag' ) , 1, config.material_billable_flag, m.material_billable_flag) ,
                decode( get_attribute_control( 'expense_billable_flag' ) , 1 , config.expense_billable_flag , m.expense_billable_flag) ,
                decode( get_attribute_control( 'prorate_service_flag' ) , 1, config.prorate_service_flag, m.prorate_service_flag) ,
                decode( get_attribute_control( 'coverage_schedule_id' ) , 1,  config.coverage_schedule_id, m.coverage_schedule_id) ,
                decode( get_attribute_control( 'service_duration_period_code' ) , 1, config.service_duration_period_code, m.service_duration_period_code) ,
                decode( get_attribute_control( 'service_duration') , 1,  config.service_duration, m.service_duration) ,
                decode( get_attribute_control( 'max_warranty_amount' ) , 1 , config.max_warranty_amount, m.max_warranty_amount) ,
                decode( get_attribute_control( 'response_time_period_code' ) , 1, config.response_time_period_code, m.response_time_period_code) ,
                decode( get_attribute_control( 'response_time_value') , 1, config.response_time_value, m.response_time_value) ,
                decode( get_attribute_control( 'new_revision_code' ) , 1 , config.new_revision_code, m.new_revision_code) ,
                decode( get_attribute_control( 'tax_code') , 1, config.tax_code, m.tax_code) ,
                decode( get_attribute_control( 'must_use_approved_vendor_flag' ) , 1, config.must_use_approved_vendor_flag, m.must_use_approved_vendor_flag) ,
                decode( get_attribute_control( 'safety_stock_bucket_days' ) , 1, config.safety_stock_bucket_days, m.safety_stock_bucket_days) ,
                decode( get_attribute_control( 'auto_reduce_mps') , 1, config.auto_reduce_mps, m.auto_reduce_mps) ,
                decode( get_attribute_control( 'costing_enabled_flag' ) , 1, config.costing_enabled_flag, m.costing_enabled_flag) ,
                decode( get_attribute_control( 'invoiceable_item_flag' ) , 1, config.invoiceable_item_flag, m.invoiceable_item_flag ) ,
                decode( get_attribute_control( 'invoice_enabled_flag' ) , 1 , config.invoice_enabled_flag, m.invoice_enabled_flag ) ,
                decode( get_attribute_control( 'outside_operation_flag') , 1, config.outside_operation_flag, m.outside_operation_flag) ,
                decode( get_attribute_control( 'outside_operation_uom_type' ) , 1, config.outside_operation_uom_type, m.outside_operation_uom_type) ,
                'Y',                                 -- auto created config flag
                decode( get_attribute_control( 'cycle_count_enabled_flag') , 1 , config.cycle_count_enabled_flag, m.cycle_count_enabled_flag) ,
                p_lItemType,
                decode( get_attribute_control( 'model_config_clause_name') ,1 , config.model_config_clause_name, m.model_config_clause_name) ,
                decode( get_attribute_control( 'ship_model_complete_flag') ,1 , config.ship_model_complete_flag, m.ship_model_complete_flag) ,
                decode( get_attribute_control( 'mrp_planning_code' ) , 1 , config.mrp_planning_code, m.mrp_planning_code) ,                 -- earlier it was always from one org only
                decode( get_attribute_control( 'repetitive_planning_flag' ) , 1, config.repetitive_planning_flag, m.repetitive_planning_flag) ,   -- earlier it was always from one org only
                decode( get_attribute_control( 'return_inspection_requirement' ) , 1 , config.return_inspection_requirement, m.return_inspection_requirement) ,
                nvl( decode( get_attribute_control( 'effectivity_control') , 1, config.effectivity_control, m.effectivity_control) , 1),
                null,                               -- req_id
                null,                               -- prg_appid
                null,                               -- prg_id
                sysdate,
		decode( get_attribute_control( 'comms_nl_trackable_flag') , 1, config.comms_nl_trackable_flag, m.comms_nl_trackable_flag) ,               -- bugfix 2200256
		nvl( decode( get_attribute_control( 'default_so_source_type') , 1 , config.default_so_source_type, m.default_so_source_type) ,'INTERNAL'),
		nvl( decode( get_attribute_control( 'create_supply_flag') , 1, config.create_supply_flag, m.create_supply_flag) , 'Y'),
			-- begin bugfix 2336548
		decode( get_attribute_control( 'lot_status_enabled') , 1, config.lot_status_enabled, m.lot_status_enabled) ,
		decode( get_attribute_control( 'default_lot_status_id' ) , 1, config.default_lot_status_id, m.default_lot_status_id) ,
		decode( get_attribute_control( 'serial_status_enabled') , 1, config.serial_status_enabled, m.serial_status_enabled) ,
		decode( get_attribute_control( 'default_serial_status_id') ,1 , config.default_serial_status_id, m.default_serial_status_id) ,
		decode( get_attribute_control( 'lot_split_enabled') , 1, config.lot_split_enabled, m.lot_split_enabled) ,
		decode( get_attribute_control( 'lot_merge_enabled') ,1 , config.lot_merge_enabled, m.lot_merge_enabled) ,
		decode( get_attribute_control( 'bulk_picked_flag' ) , 1 , config.bulk_picked_flag, m.bulk_picked_flag) ,
			-- end bugfix 2336548
			-- begin bugfix 2400609
		decode( get_attribute_control( 'financing_allowed_flag') , 1, config.financing_allowed_flag, m.FINANCING_ALLOWED_FLAG) ,
 		decode( get_attribute_control( 'eam_item_type') , 1 , config.eam_item_type, m.EAM_ITEM_TYPE ) ,
 		decode( get_attribute_control( 'eam_activity_type_code') , 1 , config.eam_activity_type_code, m.EAM_ACTIVITY_TYPE_CODE) ,
 		decode( get_attribute_control( 'eam_activity_cause_code') , 1, config.eam_activity_cause_code, m.EAM_ACTIVITY_CAUSE_CODE) ,
 		decode( get_attribute_control( 'eam_act_notification_flag') , 1, config.eam_act_notification_flag, m.EAM_ACT_NOTIFICATION_FLAG) ,
 		decode( get_attribute_control( 'eam_act_shutdown_status') , 1, config.eam_act_shutdown_status, m.EAM_ACT_SHUTDOWN_STATUS) ,
 		decode( get_attribute_control( 'substitution_window_code') , 1, config.substitution_window_code, m.SUBSTITUTION_WINDOW_CODE) ,
 		decode( get_attribute_control( 'substitution_window_days') , 1, config.substitution_window_days, m.SUBSTITUTION_WINDOW_DAYS) ,
 		null, --5385901 decode( get_attribute_control( 'product_family_item_id') , 1, config.product_family_item_id, m.PRODUCT_FAMILY_ITEM_ID) ,
 		decode( get_attribute_control( 'check_shortages_flag') , 1, config.check_shortages_flag, m.CHECK_SHORTAGES_FLAG) ,
 		decode( get_attribute_control( 'planned_inv_point_flag') , 1, config.planned_inv_point_flag, m.PLANNED_INV_POINT_FLAG) ,
 		decode( get_attribute_control( 'over_shipment_tolerance') , 1, config.over_shipment_tolerance, m.OVER_SHIPMENT_TOLERANCE) ,
 		decode( get_attribute_control( 'under_shipment_tolerance') , 1, config.under_shipment_tolerance, m.UNDER_SHIPMENT_TOLERANCE) ,
 		decode( get_attribute_control( 'over_return_tolerance') , 1, config.over_return_tolerance, m.OVER_RETURN_TOLERANCE) ,
 		decode( get_attribute_control( 'under_return_tolerance') , 1, config.under_return_tolerance, m.UNDER_RETURN_TOLERANCE) ,
 		decode( get_attribute_control( 'purchasing_tax_code') , 1, config.purchasing_tax_code, m.PURCHASING_TAX_CODE) ,
 		decode( get_attribute_control( 'overcompletion_tolerance_type') , 1, config.overcompletion_tolerance_type, m.OVERCOMPLETION_TOLERANCE_TYPE) ,
 		decode( get_attribute_control( 'overcompletion_tolerance_value') , 1, config.overcompletion_tolerance_value, m.OVERCOMPLETION_TOLERANCE_VALUE) ,
 		decode( get_attribute_control( 'inventory_carry_penalty'), 1, config.inventory_carry_penalty, m.INVENTORY_CARRY_PENALTY) ,
 		decode( get_attribute_control( 'operation_slack_penalty') ,1, config.operation_slack_penalty, m.OPERATION_SLACK_PENALTY) ,
 		decode( get_attribute_control( 'unit_length') , 1, config.unit_length, m.UNIT_LENGTH) ,
 		decode( get_attribute_control( 'unit_width' ) , 1, config.unit_width, m.UNIT_WIDTH) ,
 		decode( get_attribute_control( 'unit_height') , 1, config.unit_height, m.UNIT_HEIGHT) ,
 		decode( get_attribute_control( 'lot_translate_enabled') , 1, config.lot_translate_enabled, m.LOT_TRANSLATE_ENABLED) ,
 		decode( get_attribute_control( 'container_item_flag') , 1, config.container_item_flag, m.CONTAINER_ITEM_FLAG) ,
 		decode( get_attribute_control( 'vehicle_item_flag') , 1, config.vehicle_item_flag, m.VEHICLE_ITEM_FLAG) ,
 		decode( get_attribute_control( 'dimension_uom_code') , 1, config.dimension_uom_code, m.DIMENSION_UOM_CODE) ,
 		decode( get_attribute_control( 'secondary_uom_code') , 1, config.secondary_uom_code, m.SECONDARY_UOM_CODE) ,
 		decode( get_attribute_control( 'maximum_load_weight') , 1, config.maximum_load_weight, m.MAXIMUM_LOAD_WEIGHT) ,
 		decode( get_attribute_control( 'minimum_fill_percent') , 1, config.minimum_fill_percent, m.MINIMUM_FILL_PERCENT) ,
 		decode( get_attribute_control( 'container_type_code') , 1, config.container_type_code, m.CONTAINER_TYPE_CODE) ,
 		decode( get_attribute_control( 'internal_volume') , 1, config.internal_volume, m.INTERNAL_VOLUME) ,
 		decode( get_attribute_control( 'equipment_type') , 1,  config.equipment_type , m.EQUIPMENT_TYPE) ,
 		decode( get_attribute_control( 'indivisible_flag') , 1, config.indivisible_flag, m.INDIVISIBLE_FLAG) ,
 		decode( get_attribute_control( 'global_attribute_category'), 1, config.global_attribute_category, m.GLOBAL_ATTRIBUTE_CATEGORY) ,
 		m.GLOBAL_ATTRIBUTE1,
 		m.GLOBAL_ATTRIBUTE2,
 		m.GLOBAL_ATTRIBUTE3,
 		m.GLOBAL_ATTRIBUTE4,
 		m.GLOBAL_ATTRIBUTE5,
 		m.GLOBAL_ATTRIBUTE6,
 		m.GLOBAL_ATTRIBUTE7,
 		m.GLOBAL_ATTRIBUTE8,
 		m.GLOBAL_ATTRIBUTE9,
 		m.GLOBAL_ATTRIBUTE10,
     		decode( get_attribute_control( 'dual_uom_control') , 1, config.dual_uom_control, m.DUAL_UOM_CONTROL) ,
 		decode( get_attribute_control( 'dual_uom_deviation_high') , 1, config.dual_uom_deviation_high, m.DUAL_UOM_DEVIATION_HIGH) ,
 		decode( get_attribute_control( 'dual_uom_deviation_low') , 1, config.dual_uom_deviation_low, m.DUAL_UOM_DEVIATION_LOW) ,
                decode( get_attribute_control( 'contract_item_type_code') , 1, config.contract_item_type_code, m.CONTRACT_ITEM_TYPE_CODE) ,
 		decode( get_attribute_control( 'subscription_depend_flag') , 1 , config.subscription_depend_flag, m.SUBSCRIPTION_DEPEND_FLAG) ,
 		decode( get_attribute_control( 'serv_req_enabled_code' ) , 1, config.serv_req_enabled_code, m.SERV_REQ_ENABLED_CODE) ,
 		decode( get_attribute_control( 'serv_billing_enabled_flag') , 1, config.serv_billing_enabled_flag, m.SERV_BILLING_ENABLED_FLAG) ,
 		decode( get_attribute_control( 'release_time_fence_code') , 1, config.release_time_fence_code, m.RELEASE_TIME_FENCE_CODE) ,
 		decode( get_attribute_control( 'release_time_fence_days' ) ,1, config.release_time_fence_days, m.RELEASE_TIME_FENCE_DAYS) ,
 		decode( get_attribute_control( 'defect_tracking_on_flag') , 1, config.defect_tracking_on_flag, m.DEFECT_TRACKING_ON_FLAG) ,
 		decode( get_attribute_control( 'serv_importance_level'), 1, config.serv_importance_level, m.SERV_IMPORTANCE_LEVEL) ,
	        decode( get_attribute_control( 'web_status') , 1, config.web_status, m.web_status) ,          --  bugfix 2727983
                decode( get_attribute_control( 'tracking_quantity_ind' ) , 1 , config.tracking_quantity_ind, nvl( m.tracking_quantity_ind , 'P' )),
                decode( get_attribute_control( 'ont_pricing_qty_source' ) , 1 , config.ont_pricing_qty_source, nvl( m.ont_pricing_qty_source, 'P')) ,
                decode( get_attribute_control( 'approval_status' ) , 1 , config.approval_status, m.approval_status) ,
                decode( get_attribute_control( 'vmi_minimum_units' ) , 1, config.vmi_minimum_units, m.vmi_minimum_units) ,
                decode( get_attribute_control( 'vmi_minimum_days' ) ,1 , config.vmi_minimum_days, m.vmi_minimum_days) ,
                decode( get_attribute_control( 'vmi_maximum_units' ) , 1 , config.vmi_maximum_units, m.vmi_maximum_units) ,
                decode( get_attribute_control( 'vmi_maximum_days' ) , 1 , config.vmi_maximum_days, m.vmi_maximum_days ) ,
                decode( get_attribute_control( 'vmi_fixed_order_quantity' ) , 1 , config.vmi_fixed_order_quantity, m.vmi_fixed_order_quantity) ,
                decode( get_attribute_control( 'so_authorization_flag' ) , 1, config.so_authorization_flag, m.so_authorization_flag ) ,
                decode( get_attribute_control( 'consigned_flag' ) , 1, config.consigned_flag, m.consigned_flag) ,
                decode( get_attribute_control( 'asn_autoexpire_flag' ) , 1 , config.asn_autoexpire_flag, m.asn_autoexpire_flag ) ,
                decode( get_attribute_control( 'vmi_forecast_type' ) , 1 , config.vmi_forecast_type, m.vmi_forecast_type) ,
                decode( get_attribute_control( 'forecast_horizon' ) , 1, config.forecast_horizon, m.forecast_horizon ) ,
                decode( get_attribute_control( 'days_tgt_inv_supply' ) , 1, config.days_tgt_inv_supply, m.days_tgt_inv_supply ) ,
                decode( get_attribute_control( 'days_tgt_inv_window' ) , 1 , config.days_tgt_inv_window, m.days_tgt_inv_window ) ,
                decode( get_attribute_control( 'days_max_inv_supply' ) , 1, config.days_max_inv_supply, m.days_max_inv_supply ) ,
                decode( get_attribute_control( 'days_max_inv_window' ) , 1 , config.days_max_inv_window, m.days_max_inv_window ) ,
                decode( get_attribute_control( 'critical_component_flag' ) , 1, config.critical_component_flag, m.critical_component_flag) ,
                decode( get_attribute_control( 'drp_planned_flag' ) ,1 , config.drp_planned_flag, m.drp_planned_flag ) ,
                decode( get_attribute_control( 'exclude_from_budget_flag' ) , 1 , config.exclude_from_budget_flag, m.exclude_from_budget_flag) ,
                decode( get_attribute_control( 'convergence' ) , 1 , config.convergence, m.convergence ) ,
                decode( get_attribute_control( 'continous_transfer' ) , 1, config.continous_transfer, m.continous_transfer ) ,
                decode( get_attribute_control( 'divergence' ) , 1 , config.divergence, m.divergence ),
		  --begin r12,4574899
		nvl(m.lot_divisible_flag, 'N'),  --Bugfix 6343429
		'N',
		/* Bugfix 8821149: Will populate these values from model.
		'N',
	        'N',
		'N',
		*/
		decode( get_attribute_control( 'child_lot_flag' ) , 1 , config.child_lot_flag, m.child_lot_flag),
		decode( get_attribute_control( 'child_lot_validation_flag' ) , 1 , config.child_lot_validation_flag, m.child_lot_validation_flag),
		decode( get_attribute_control( 'copy_lot_attribute_flag' ) , 1 , config.copy_lot_attribute_flag, m.copy_lot_attribute_flag),
		decode( get_attribute_control( 'parent_child_generation_flag' ) , 1 , config.parent_child_generation_flag, m.parent_child_generation_flag),
		decode( get_attribute_control( 'lot_substitution_enabled' ) , 1 , config.lot_substitution_enabled, m.lot_substitution_enabled),
		-- End Bugfix 8821149
		'N',
		'N',
		'N',
		'N',
		'N',
		'N',
		3,   --repair_program
		2   --outsourced_assembly
		 --end r12,4574899
        from
                mtl_system_items_b  m,               -- Model
                mtl_system_items_b  config,
                bom_cto_order_lines     bcol,
                bom_cto_src_orgs        bcso
        where  m.inventory_item_id = p_model_id
        and bcso.model_item_id = p_model_id
        and bcso.line_id = p_line_id
        and bcso.line_id = bcol.line_id
        and bcol.config_item_id = config.inventory_item_id
        and config.organization_id = bcol.ship_from_org_id
        and m.organization_id = bcso.organization_id
        and NOT EXISTS
                (select NULL
                from mtl_system_items_b
                where inventory_item_id = p_config_id
                and organization_id = bcso.organization_id);



 	      --Start Bugfix 8305535
 	      sqlcnt1 := sql%rowcount;
 	      if ( sqlcnt1 > 0) then
 	         IF PG_DEBUG <> 0 THEN
 	              oe_debug_pub.add('Create_Item: ' || 'Going to insert in pl/sql table for project Genesis',2);
 	         END IF;
 	              l_ind_cnt := CTO_MSUTIL_PUB.cfg_tbl_var.count;
 	              CTO_MSUTIL_PUB.cfg_tbl_var(l_ind_cnt + 1) := p_config_id;
 	         end if;
 	      --End Bugfix 8305535

exception
when others then
    null ;

end create_preconfigured_item ;





end CTO_CONFIG_ITEM_PK;


/
