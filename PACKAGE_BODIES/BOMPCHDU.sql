--------------------------------------------------------
--  DDL for Package Body BOMPCHDU
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPCHDU" as
/* $Header: BOMCHDUB.pls 115.3 99/07/16 05:11:38 porting shi $ */
/*============================================================================+
|  Copyright (c) 1993 Oracle Corporation    Belmont, California, USA          |
|                        All rights reserved.                                 |
|                        Oracle Manufacturing                                 |
+=============================================================================+
|									      |
| FILE NAME   : BOMCHDUB.pls						      |
| DESCRIPTION :								      |
|               This file creates packaged functions that check for matching  |
|		configurations.						      |
|									      |
|		BOMPCHDU.is_base_demand_row -- Checks whether a given row in  |
|		mtl_demand has already been found to be a duplicate.	      |
|									      |
|		BOMPCHDU.bomfchdu_check_dupl_config -- Checks through each    |
|		row in mtl_demand which has been marked to be processed.      |
|		Depending on profile settings, it may call a custom function  |
|		for pre-existing configurations or use the matching function  |
|		from match and reserve.  Then, it does an in batch match on   |
|		the configurations.					      |
|									      |
|		BOMPCHDU.existing_dupl_match -- for a given demand_id, it     |
|		searches BOM ATO Configurations for a matching configuration. |
|									      |
|		BOMPCHDU.check_dupl_batch_match -- for a given demand_id, it  |
|		checks the other rows to be processed whether any has an      |
|		identical configuration.  If any of the other rows are 	      |
|		identical, their dupl_config_demand_id or dupl_config_item_id |
|		is updated accordingly.					      |
|									      |
|									      |
| HISTORY     :  							      |
|               06/13/93  Chung Wei Lee  Initial version		      |
|		08/16/93  Chung Wei Lee	 Added more comments		      |
|		08/23/93  Chung Wei Lee  Added codes to check dup new config  |
|		11/08/93  Randy Roupp    Added sql_stmt_num logic             |
|		11/09/93  Randy Roupp    Changed is_base_demand_row function  |
|		01/14/94  Nagaraj        Handle the case if d1.primary_uom_   |
|					 quantity is zero		      |
|               02/21/94  Manish Modi    Moved bomfcdec_ch_du_ext_config to   |
|                                        BOMPCEDC.			      |
|		11/01/95  Edward Lee	 Re-wrote package to use a matching   |
|					 function similar to the one in       |
|					 BOMPMCFG which drives off of so_lines|
|					 Also added a check for existing      |
|					 configurations in BOM ATO Configs.   |
=============================================================================*/

function is_base_demand_row(
        input_demand_id  in      number,
        error_message   out     VARCHAR2,   /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2,   /* 30 bytes to hold returned name*/
        table_name      out     VARCHAR2    /* 30 bytes to hold returned tbl */
        )
return integer
is
	l_demand_count  number;
	l_dup_demand_id   number;
	l_dup_item_id	number;
        sql_stmt_num    number;
begin
	/*
	** Check  whether the passed demand row is a duplicated demand row
	** for other demand row/rows already
	*/
        sql_stmt_num := 30;
	select duplicated_config_demand_id, duplicated_config_item_id into
		l_dup_demand_id, l_dup_item_id
	from mtl_demand
	where demand_id = input_demand_id
	and config_group_id = USERENV('SESSIONID')
        and config_status = 20
	and rownum = 1;       /* demand_id is a duplicated_config_demand_id
                                       for an active demand row */
	 if (l_dup_demand_id is null and l_dup_item_id is null) then
                return(1); /* need to continue duplicate check */
        else
                return(0); /* no need continuing duplicate check */
        end if;
exception
	when NO_DATA_FOUND THEN
		return(0);
	when OTHERS THEN
        	error_message := 'ibdr:' || to_char(sql_stmt_num) || ':' ||
                                  substrb(sqlerrm,1,150);
                message_name := 'BOM_ATO_PROCESS_ERROR';
                table_name := 'MTL_DEMAND';

	        return(2);    /* Error condition */

end;


function bomfchdu_check_dupl_config (
        error_message   out     VARCHAR2,
        message_name    out     VARCHAR2,
        table_name      out     VARCHAR2,
	nobatch		in	number	default 0
        )
return integer
is
        sql_stmt_num     number;
	/*
	** Declare cursor for fetching demand lines to be checked
	*/
	CURSOR cc IS
		select demand_id, demand_source_line
		from mtl_demand D,
		     mtl_sales_orders S
		where D.config_group_id = USERENV('SESSIONID')
		and D.duplicated_config_item_id is NULL
		and D.demand_source_header_id = S.sales_order_id
		order by S.segment1 desc,D.user_line_num desc;

	l_demand_id		number;
	l_demand_source_line	number;
	l_config_item_id	number;
	status			number;
	CK_EXT_ERROR		exception;
	CK_NEW_ERROR		exception;
	CK_MR_ERROR		exception;
	match_profile		VARCHAR2(100);
	message			VARCHAR2(100);

begin
	sql_stmt_num := 5;

/*
       select nvl(substr(profile_option_value,1,30),'0') into match_profile
        from fnd_profile_option_values val,fnd_profile_options op
        where op.profile_option_name = 'BOM:CHECK_DUPL_CONFIG'
        and   val.level_id = 10001
        and   val.profile_option_id = op.profile_option_id;
*/

        match_profile:=FND_PROFILE.Value('BOM:CHECK_DUPL_CONFIG');

	message_name := 'Just about to open cursor.';
	sql_stmt_num :=6;
	open cc;
	/*
	** Loop through all the processing demand records
	** 	Check for an existing matching configuration
	**	Check for matching configuration demand
	*/
	loop
		sql_stmt_num :=7;
		fetch cc into l_demand_id,l_demand_source_line;
		exit when (cc%notfound);
		/*
		** Search whether this row has already been found
		** to be a duplicate
		*/
	sql_stmt_num :=8;
	status := BOMPCHDU.is_base_demand_row(
			l_demand_id,
			error_message,
			message_name,
			table_name);
			/* Proceed only if dupl_config_item_id and */
			/* dupl_config_demand_id still null.       */
	if (status = 1) then
		sql_stmt_num :=9;
		if (match_profile = '1') then
		/*
		** Keep old hook to check for for existing
		** Configurations in Item/BOM/Rtg tables
		** '1' = CHECK_DUPL_CONFIG is YES, so use customer hook
		*/

		    status := BOMPCEDC.bomfcdec_ch_du_ext_config(
				l_demand_id,
				l_config_item_id,
				error_message,
				message_name,
				table_name);
		     if (status = 1) then
		           if (l_config_item_id is not NULL) then
                                sql_stmt_num := 10;
			        update mtl_demand
			        set duplicated_config_item_id= l_config_item_id
			        where demand_id = l_demand_id;
		           end if;  /* end of if config_item is not NULL */
		      else
			   raise CK_NEW_ERROR;  /* if status not 1 */
		      end if;  /* end of if status = 1 */
	  	  else    /* if match_profile is NOT 'YES' */
		      if (match_profile = '3') then

			         /*  Match_profile = '3' means
				 **  Match and Reserve, so use new
				 **  existing_dupl_match to check for existing
				 **  configuration in BAC */

			   status := BOMPCHDU.existing_dupl_match(
				l_demand_id,
				l_config_item_id,
				error_message,
                        	message_name,
                        	table_name);
			    if (status <> 1) then
				 raise CK_MR_ERROR;  /* if status not 1 */
			    end if;  /* status = 1 */

			end if;  /* match_profile = MATCH and  RESERVE = 1 */

		    end if;  /* on the local_profile_check */
			/*
			** Now, we check the other orders in this
			** batch, and set their fuplicate_config_id
			** if they match.
			*/
		   sql_stmt_num :=21;
		   if (nobatch=0) then
		     status := BOMPCHDU.check_dupl_batch_match(
			l_demand_id,
			l_config_item_id,
			l_demand_source_line,
			error_message,
                       	message_name,
                       	table_name);
		   end if;
	else
		status:=1;  /* if not base demand row, reset */
	end if;  /* on the base_demand_row */
	end loop;
	close cc;

	return(1);
exception
	when CK_EXT_ERROR then
			return (status);
	when CK_MR_ERROR then
			return (status);
	when CK_NEW_ERROR then
			return (status);
	when OTHERS then
			status := sql_stmt_num;   /*sqlcode;  */
	        error_message := 'bcdc:' || to_char(sql_stmt_num) || ':' ||
                                  substrb(sqlerrm,1,150);
        	table_name := 'MTL_DEMAND';
		return (status);

end;



function existing_dupl_match (
	input_demand_id in	number,
	dupl_item_id  	out	number,
        error_message   out     VARCHAR2,
        message_name    out     VARCHAR2,
        table_name      out     VARCHAR2
        )
return integer
is
stmt_num	   number;
cfm_value          number;
match_results	   number;
my_match	   number;
NO_MODEL_FOUND        EXCEPTION;
begin
	/*
	** This function searches
        ** for an existing configuration that meets the requirements
	** of orders being processed in this run of Create Configuration
        ** cfm_routing_flag indicates the type of routing used to create
        ** existing configurations. Matching configurations must have
        ** same values of cfm_routing_flag
        */

	select NVL(cfm_routing_flag,0) into cfm_value
        from   mtl_demand md,
              bom_operational_routings bor
        where  md.inventory_item_id = bor.assembly_item_id(+)
        and    md.organization_id   = bor.organization_id(+)
        and    bor.alternate_routing_designator(+)  is NULL
        and    md.demand_id         = input_demand_id;



	stmt_num :=60;
	update mtl_demand m
	set m.duplicated_config_item_id = (
	select BAC1.config_item_id
	  from BOM_ATO_CONFIGURATIONS BAC1, /* the duplicate  */
	       so_lines_all solp, /* Parent of ATO Model if any */
	       so_lines_all sol1, /* processing     */
	       mtl_system_items msi,
               bom_operational_routings bor,
	       bom_parameters bp
	  where BAC1.base_model_id = sol1.inventory_item_id
	  and   BAC1.organization_id = sol1.warehouse_id
	  and   BAC1.component_item_id = sol1.inventory_item_id
	  and   bp.organization_id = BAC1.organization_id
          and   NVL(BAC1.cfm_routing_flag,0) = cfm_value
	  and   solp.line_id = nvl(sol1.link_to_line_id,sol1.line_id)
	  and   msi.organization_id = BAC1.organization_id
	  and   msi.inventory_item_id = BAC1.config_item_id
	  and   msi.inventory_item_status_code <> bp.bom_delete_status_code
	  and   not exists (select 'X'
		    from so_lines_all sol5 /* current */
		    where sol5.ato_line_id = sol1.line_id
		    and sol5.ordered_quantity > nvl(sol5.cancelled_quantity,0)
		    and   sol5.inventory_item_id not in
		   (select BAC2.component_item_id
		    from BOM_ATO_CONFIGURATIONS BAC2 /* duplicates */
		    where BAC2.config_item_id = BAC1.config_item_id
		    and   BAC2.component_item_id <> BAC1.component_item_id
		    and   BAC2.component_item_id = sol5.inventory_item_id
		    and   BAC2.component_code =
			decode(sol1.link_to_line_id,NULL,sol5.component_code,
			  substrb(sol5.component_code,
				lengthb(solp.component_code)+2))
	            and   BAC2.COMPONENT_QUANTITY =
	             ((sol5.ordered_quantity-nvl(sol5.cancelled_quantity,0))/
		     (sol1.ordered_quantity-nvl(sol1.cancelled_quantity,0)))
		    )
			    )
	  and exists(select 'X'
                 from BOM_ATO_CONFIGURATIONS BAC3  /* duplicates */
                 where BAC3.config_item_id = BAC1.config_item_id
                 and   BAC3.component_item_id <> BAC1.component_item_id
                 having count(*) = (select count (*)
                    from so_lines_all sol7  /* processing  */
                    where sol7.ato_line_id = sol1.line_id
                    and   sol7.ordered_quantity>nvl(sol7.cancelled_quantity,0)
                   		     )
	           )
          and    sol1.line_id = m.demand_source_line
	  and    rownum = 1
			                        )
	  where m.demand_id = input_demand_id
	  and   m.config_group_id = USERENV('SESSIONID')
	  and   m.demand_type = 1
	  and   m.duplicated_config_item_id is NULL;



	select duplicated_config_item_id into match_results
		from mtl_demand
		where config_group_id = USERENV('SESSIONID')
		and demand_id = input_demand_id;
		  /* **** is this REALLY necessary? just updated it*** */

	if (match_results is not null) then
		stmt_num := 70;
		update bom_ato_configurations
		set last_referenced_date = SYSDATE
		where config_item_id = match_results;

	end if;

	dupl_item_id := match_results;
	return (1);

exception
	when NO_MODEL_FOUND THEN
	error_message := 'BOMPCHDU' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'MTL_DEMAND';
	return (0);

	when NO_DATA_FOUND THEN

	return(0);
	when OTHERS THEN

	error_message := 'BOMPCHDU' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'SO_LINES_ALL';
	return(0);
end;


function check_dupl_batch_match (
	input_demand_id in	number,
	dupl_item_id    	number,
	copy_line_id	in	number,
        error_message   out     VARCHAR2,  /* 70 bytes to hold returned msg */
        message_name    out     VARCHAR2, /* 30 bytes to hold returned name */
        table_name      out     VARCHAR2  /* 30 bytes to hold returned tbl */
	)
return integer
is
stmt_num	   number;
dupl_demand_id	   number;
temp_item_id	   number;
NO_MODEL_FOUND        EXCEPTION;
begin
	temp_item_id := dupl_item_id;
	if (dupl_item_id is null) then
		temp_item_id := NULL;
		dupl_demand_id := input_demand_id;
	end if;

	temp_item_id := dupl_item_id;
	stmt_num :=100;

        update mtl_demand m
          set m.duplicated_config_item_id = temp_item_id,
	      m.duplicated_config_demand_id = dupl_demand_id
	  where m.config_group_id = USERENV('SESSIONID')
	        and m.demand_id in (
	  select m1.demand_id
	  from  so_lines_all soldp, /* parent of duplicate */
		so_lines_all solp,  /* parent of other lines */
	 	so_lines_all sol1,  /* processing other lines */
		so_lines_all sold,   /* current -- duplicate */
		mtl_demand m1
	  where sol1.line_id=m1.demand_source_line
	  and  	m1.config_group_id = USERENV('SESSIONID')
	  and	m1.demand_id <> input_demand_id
	  and   sold.line_id = copy_line_id
	  and  	sold.inventory_item_id = sol1.inventory_item_id +0
	  and   sold.warehouse_id = sol1.warehouse_id
	  and   solp.line_id = nvl(sol1.link_to_line_id,sol1.line_id)
  	  and   soldp.line_id = nvl(sold.link_to_line_id,sold.line_id)
	  and   m1.config_status = 20
	  and   m1.duplicated_config_item_id is null
	  and   m1.duplicated_config_demand_id is null
          and exists(select 'X'
                 from so_lines_all sold3  /* duplicates */
                 where sold3.ato_line_id = sold.line_id
                 and  sold3.ordered_quantity>nvl(sold3.cancelled_quantity,0)
                 having count(*) = (select count (*)
                    from so_lines_all sol7  /* processing  */
                    where sol7.ato_line_id = sol1.line_id
                    and   sol7.ordered_quantity>nvl(sol7.cancelled_quantity,0)
                   )
                        )
	   and   not exists (select 'X'
		    from so_lines_all sol5 /* current */
		    where sol5.ato_line_id = sol1.line_id
		    and sol5.ordered_quantity > nvl(sol5.cancelled_quantity,0)
		    and   sol5.inventory_item_id not in
		   (select sold2.inventory_item_id
		    from so_lines_all sold2   /* duplicates */
		    where sold2.ato_line_id = sold.line_id
		    and sold2.component_code = sol5.component_code
		    and decode(sold.link_to_line_id,NULL,sold2.component_code,
			  substrb(sold2.component_code,
				lengthb(soldp.component_code)+2)) =
			decode(sol1.link_to_line_id,NULL,sol5.component_code,
			  substrb(sol5.component_code,
				lengthb(solp.component_code)+2))
	             and
		     ((sold2.ordered_quantity-nvl(sold2.cancelled_quantity,0))/(sold.ordered_quantity-nvl(sold.cancelled_quantity,0))) =
	             ((sol5.ordered_quantity-nvl(sol5.cancelled_quantity,0))/
		     (sol1.ordered_quantity-nvl(sol1.cancelled_quantity,0)))

		    )
			   )
	);
        return (1);

exception
	when NO_MODEL_FOUND THEN

	error_message := 'BOMPCHDU:' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'MTL_DEMAND';
	return (0);

	when NO_DATA_FOUND THEN

	return(0);
	when OTHERS THEN

	error_message := 'BOMPCHDU' || to_char(stmt_num) || ':' ||
                         substrb(sqlerrm,1,150);
        message_name := 'BOM_ATO_PROCESS_ERROR';
        table_name := 'SO_LINES_ALL';
	return(0);
end;



end BOMPCHDU;

/
