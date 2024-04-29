--------------------------------------------------------
--  DDL for Package Body INV_CG_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_CG_UPGRADE" AS
/* $Header: INVCGUGB.pls 120.3 2006/03/17 11:47:02 kdong noship $*/

PROCEDURE mydebug(msg IN VARCHAR2) IS
BEGIN
   inv_log_util.trace(msg, 'INVCGUGB', 9);
END mydebug;

PROCEDURE INVMSISB(
		    l_organization_id 	IN  	       NUMBER,
		   USER_NAME            IN           VARCHAR2,
		    PASSWORD            IN           VARCHAR2,
		    x_return_status	  	OUT 	NOCOPY VARCHAR2,
		    x_msg_count       	OUT 	NOCOPY NUMBER,
		    x_msg_data        	OUT 	NOCOPY VARCHAR2) AS


   -- --------------------------------------------------------
   -- Subinventories that do not have a default cost group yet
   -- --------------------------------------------------------


   cursor subinventory_cursor is
   select
     rowid
   , secondary_inventory_name
   , material_account
   , material_overhead_account
   , resource_account
   , overhead_account
   , outside_processing_account
   , expense_account
   , encumbrance_account

   from mtl_secondary_inventories
   where (
	  default_cost_group_id is null AND
          organization_id = l_organization_id
         );
--  l_organization_id 		number; */

   l_secondary_inventory_name   varchar2(10);

   l_material_account           number;
   l_material_overhead_account  number;
   l_resource_account           number;
   l_overhead_account           number;
   l_outside_processing_account number;
   l_expense_account            number;
   l_encumbrance_account        number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_cost_group_id              number;
   l_cost_group_id_tbl 		cstpcgut.cost_group_tbl;
   l_count			number;

   l_return_err			varchar2(280);

   l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data
     INVMSISB';

   l_primary_cost_method        NUMBER;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
   begin
      l_table_name := 'MTL_SECONDARY_INVENTORIES';

      /* Bug 4235102 fix */
      /* If there is atleast one record with a costgroup upgrade not needed */
      BEGIN
	 SELECT default_cost_group_id
	   INTO l_check_cost_group_id
	   FROM
	   mtl_secondary_inventories
	   WHERE
	   organization_id = l_organization_id
	   AND ROWNUM=1;
      EXCEPTION
	 WHEN OTHERS THEN
	    NULL;
      END;

      IF Nvl(l_check_cost_group_id,0 ) > 0 THEN
	 mydebug('INVMSISB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
	 RETURN;
      END IF;
      /* Bug 4235102 fix */

      SELECT primary_cost_method INTO l_primary_cost_method FROM
	mtl_parameters WHERE organization_id = l_organization_id AND ROWNUM <
	2;

      for c1 in subinventory_cursor

	loop


--	/*
--       Load cursor output into local variables
--
--	  l_organization_id 	     := c1.organization_id;
--	*/

	   l_rowid_info                 := c1.ROWID;
	   l_secondary_inventory_name   := c1.secondary_inventory_name;

	   l_material_account           := c1.material_account;
	   l_material_overhead_account  := c1.material_overhead_account;
	   l_resource_account           := c1.resource_account;
	   l_overhead_account           := c1.overhead_account;
	   l_outside_processing_account := c1.outside_processing_account;
	   l_expense_account            := c1.expense_account;
	   l_encumbrance_account        := c1.encumbrance_account;

	   /*
	   dbms_output.put_line('Org:' || to_char(l_organization_id));
	   dbms_output.put_line('Sub:' || l_secondary_inventory_name);

	   dbms_output.put_line('MA:'  || to_char(l_material_account));
	   dbms_output.put_line('MOA:' || to_char(l_material_overhead_account));
	   dbms_output.put_line('RA:'  || to_char(l_resource_account));
	   dbms_output.put_line('OA:'  || to_char(l_overhead_account));
	   dbms_output.put_line('OPA:' || to_char(l_outside_processing_account));
	   dbms_output.put_line('EA:'  || to_char(l_expense_account));
	   dbms_output.put_line('EnA:' || to_char(l_encumbrance_account));
           */

	  /*
          ** See if there is there a cost group with matching accounts
	  */

--       The below if condition is added to set the default cost group id
--	  TO 1 whenever the primary costing method IS other than 1

	  IF l_primary_cost_method = 1 then





	     cstpcgut.get_cost_group(
				     x_return_status     		=> l_return_status
				     , x_msg_count         		=> l_msg_count
				     , x_msg_data          		=> l_msg_data
				     , x_cost_group_id_tbl 		=> l_cost_group_id_tbl
				     , x_count             		=> l_count
				     , p_material_account         	=> l_material_account
				     , p_material_overhead_account  	=> l_material_overhead_account
				     , p_resource_account           	=> l_resource_account
				     , p_overhead_account           	=> l_overhead_account
				     , p_outside_processing_account 	=> l_outside_processing_account
				     , p_expense_account            	=> l_expense_account
				     , p_encumbrance_account        	=> l_encumbrance_account
				     , p_organization_id		=> l_organization_id  --NULL
				     , p_cost_group_type_id          => 3);

	     IF l_return_status = fnd_api.g_ret_sts_error THEN
         	RAISE fnd_api.g_exc_error;
	     END IF ;

	     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		/*
		dbms_output.put_line('Org:' || to_char(l_organization_id));
		dbms_output.put_line('Sub:' || l_secondary_inventory_name);

		dbms_output.put_line('MA:'  || to_char(l_material_account));
		dbms_output.put_line('MOA:' || to_char(l_material_overhead_account));
		dbms_output.put_line('RA:'  || to_char(l_resource_account));
		dbms_output.put_line('OA:'  || to_char(l_overhead_account));
		dbms_output.put_line('OPA:' || to_char(l_outside_processing_account));
		dbms_output.put_line('EA:'  || to_char(l_expense_account));
		dbms_output.put_line('EnA:' || to_char(l_encumbrance_account));
		*/
         	RAISE fnd_api.g_exc_unexpected_error;
	     END IF;

	     /*
	     ** If there is a cost group matching accounts use it else create
	     ** a new one
	     */

	     if (l_count > 0) then
		l_cost_group_id := l_cost_group_id_tbl(1);
	     else
		cstpcgut.create_cost_group(
					   x_return_status     		=> l_return_status
					   , x_msg_count         		=> l_msg_count
					   , x_msg_data          		=> l_msg_data
					   , x_cost_group_id 			=> l_cost_group_id
					   , p_cost_group             		=> NULL
					   , p_material_account         		=> l_material_account
					   , p_material_overhead_account  	=> l_material_overhead_account
					   , p_resource_account           	=> l_resource_account
					   , p_overhead_account           	=> l_overhead_account
					   , p_outside_processing_account 	=> l_outside_processing_account
					   , p_expense_account            	=> l_expense_account
					   , p_encumbrance_account        	=> l_encumbrance_account
					   , p_organization_id			=> l_organization_id  -- NULL
					   , p_cost_group_type_id          	=> 3);

		IF l_return_status = fnd_api.g_ret_sts_error THEN
		   RAISE fnd_api.g_exc_error;
		END IF ;

		IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		   RAISE fnd_api.g_exc_unexpected_error;
		END IF;
	     end if;



	   ELSE

	     l_cost_group_id := 1;

	  END IF;


	  /*
	  ** Stamp default cost group on subinventory record
	  */

	  update mtl_secondary_inventories
	  set default_cost_group_id = l_cost_group_id
	  where organization_id     	= l_organization_id
	  and   secondary_inventory_name 	= l_secondary_inventory_name;

	end loop;

     IF(subinventory_cursor%isopen) THEN CLOSE subinventory_cursor; END IF;
     COMMIT;

   EXCEPTION

     when fnd_api.g_exc_error THEN

	rollback;
	 IF(subinventory_cursor%isopen) THEN CLOSE subinventory_cursor; END IF;
            x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_secondary_inventories default cost group upgrade:'|| l_msg_data;
      INS_ERROR(   p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;
	 IF(subinventory_cursor%isopen) THEN CLOSE subinventory_cursor; END IF;
	     x_return_status := fnd_api.g_ret_sts_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_secondary_inventories default cost group upgrade:'|| l_msg_data;
      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      raise_application_error(-20000,l_return_err);

     when others then
	rollback;
	 IF(subinventory_cursor%isopen) THEN CLOSE subinventory_cursor; END IF;
      x_return_status := fnd_api.g_ret_sts_error ;
      l_return_err := 'mtl_secondary_inventories default cost group upgrade:'||
	substrb(sqlerrm,1,55);
        INS_ERROR(p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      raise_application_error(-20000,l_return_err);

end INVMSISB;


PROCEDURE INVMPSSB(
		  l_organization_id   IN  	NUMBER,
		   p_cost_method	IN	NUMBER,
                  USER_NAME           IN        VARCHAR2,
		  PASSWORD            IN        VARCHAR2,
		  x_return_status     OUT NOCOPY	VARCHAR2,
		  x_msg_count         OUT NOCOPY	NUMBER,
		  x_msg_data          OUT NOCOPY	VARCHAR2) AS

/*
declare

  */

   type period_summary_tbl is table of mtl_period_summary%rowtype
   index by binary_integer;

   /*
   ** --------------------------------------------------------
   ** Org cursor
   ** --------------------------------------------------------
   */
   cursor group_cursor is
      SELECT
--      ROWID,
      acct_period_id
   , inventory_type
   , cost_group_id
   , sum(inventory_value) inventory_value
   from mtl_period_summary
   where organization_id = l_organization_id
   group by
     acct_period_id
   , organization_id
   , inventory_type
   , cost_group_id;

  cursor detail_cursor is
   select
     acct_period_id
   , 1 inventory_type
   , cost_group_id
   , sum(NVL(period_end_unit_cost,0)*NVL(period_end_quantity,0)) inventory_value
   from mtl_per_close_dtls
   where organization_id = l_organization_id
   group by
     acct_period_id
   , organization_id
   , cost_group_id;


   /*
   ** --------------------------------------------------------
   ** Period summary records that do not have a default cost group yet
   ** --------------------------------------------------------
   */
   cursor mps_cursor
   is
   select
     rowid
   , secondary_inventory
   from mtl_period_summary
   where
        (
         cost_group_id is null AND
         organization_id = l_organization_id
        );

   l_rowid                      varchar2(100);

/*  l_organization_id 		number; */

   l_secondary_inventory        varchar2(10);

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_cost_group_id              number;

   l_return_err			varchar2(280);

   l_counter			integer;

   l_date                       DATE;
   l_user_id                    NUMBER;
   l_request_id                 NUMBER;
   l_login_id                   NUMBER;
   l_prog_appl_id               NUMBER;
   l_program_id                 NUMBER;

   l_ps_tbl			period_summary_tbl;
   l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data INVMPSSB';
   l_org_cost_group_id		number := null;
   l_details_updated          boolean := FALSE;
begin
   -- Stamp cost group

   l_table_name := 'mtl_period_summary';
   for c1 in mps_cursor
   loop
	/*
        ** Load cursor output into local variables
        */
        l_rowid  		:= c1.rowid;
        l_rowid_info            := l_rowid;
/*      l_organization_id       := c1.organization_id; */

      	l_secondary_inventory   := c1.secondary_inventory;
        if ( p_cost_method = 2 ) then
	    if ( l_org_cost_group_id is null )then
  	      l_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);
	      l_org_cost_group_id := l_cost_group_id ;
	    else
            l_cost_group_id := l_org_cost_group_id ;
          end if;

	    if (l_cost_group_id > 0) then
                        update mtl_period_summary
                        set cost_group_id = l_cost_group_id
                        where rowid = l_rowid;
			if ( l_details_updated = FALSE ) then
                          update mtl_per_close_dtls
                          set cost_group_id = l_cost_group_id
                          where organization_id = l_organization_id
                          and cost_group_id = 1 ;
                          l_details_updated := TRUE ;
                        end if;

          end if;
        else

          if (l_secondary_inventory is not null) then
		l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id
                                   , p_subinventory     => l_secondary_inventory);

                if (l_cost_group_id > 0) then
                        update mtl_period_summary
                        set cost_group_id = l_cost_group_id
                        where rowid = l_rowid;
                end if;
	    else
	      if ( l_org_cost_group_id is null ) then
		  l_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);
	        l_org_cost_group_id := l_cost_group_id ;
	      else
	        l_cost_group_id := l_org_cost_group_id ;
            end if;

                if (l_cost_group_id > 0) then
                        update mtl_period_summary
                        set cost_group_id = l_cost_group_id
                        where rowid = l_rowid;
                end if;
	    end if;
        end if;
   end loop;

   l_counter := 0;

   l_table_name := 'mtl_period_summary';
 if ( p_cost_method = 1 ) then

   for c2 in group_cursor
   loop
      l_counter := l_counter + 1;

--        l_rowid_info                            :=c2.ROWID;
        l_ps_tbl(l_counter).acct_period_id      := c2.acct_period_id;
        l_ps_tbl(l_counter).organization_id     := l_organization_id; /*c2.organization_id;*/
        l_ps_tbl(l_counter).inventory_type      := c2.inventory_type;
        l_ps_tbl(l_counter).cost_group_id       := c2.cost_group_id;
        l_ps_tbl(l_counter).inventory_value     := c2.inventory_value;
   end loop;

   /*
   ** Delete data. It will be reloaded from memory in just a second
   */
   delete mtl_period_summary WHERE organization_id = l_organization_id;

   select sysdate into l_date from dual;

   l_user_id  := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

   IF l_login_id = -1 THEN
      l_login_id := fnd_global.conc_login_id;
   END IF;

   l_request_id 	:= fnd_global.conc_request_id;
   l_prog_appl_id 	:= fnd_global.prog_appl_id;
   l_program_id 	:= fnd_global.conc_program_id;

   /*
   ** Reload grouped data into table
   */
   for i in 1..l_counter
   loop
	/*
	** Reload grouped data from memory
	*/

	insert into mtl_period_summary(
	  ACCT_PERIOD_ID
        , ORGANIZATION_ID
 	, INVENTORY_TYPE
        , SECONDARY_INVENTORY
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , INVENTORY_VALUE
        , REQUEST_ID
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        , COST_GROUP_ID)
	values(
          l_ps_tbl(i).acct_period_id
        , l_ps_tbl(i).organization_id
        , l_ps_tbl(i).inventory_type
        , NULL
        , l_date
        , l_user_id
        , l_date
        , l_user_id
        , l_login_id
        , l_ps_tbl(i).inventory_value
        , l_request_id
        , l_prog_appl_id
        , l_program_id
        , l_date
        , l_ps_tbl(i).cost_group_id);
   end loop;

   IF(group_cursor%isopen) THEN CLOSE group_cursor; END IF;
   IF(mps_cursor%isopen) THEN CLOSE mps_cursor; END IF;
   COMMIT;
 end if;
if (p_cost_method = 2 ) then

  for c2 in detail_cursor
   loop
      l_counter := l_counter + 1;

        l_ps_tbl(l_counter).acct_period_id      := c2.acct_period_id;
        l_ps_tbl(l_counter).organization_id     := l_organization_id; /*c2.organization_id;*/
        l_ps_tbl(l_counter).inventory_type      := c2.inventory_type;
        l_ps_tbl(l_counter).cost_group_id       := c2.cost_group_id;
        l_ps_tbl(l_counter).inventory_value     := c2.inventory_value;
   end loop;
   delete mtl_period_summary WHERE organization_id = l_organization_id;
   select sysdate into l_date from dual;

   l_user_id  := fnd_global.user_id;
   l_login_id := fnd_global.login_id;

   IF l_login_id = -1 THEN
      l_login_id := fnd_global.conc_login_id;
   END IF;

   l_request_id 	:= fnd_global.conc_request_id;
   l_prog_appl_id 	:= fnd_global.prog_appl_id;
   l_program_id 	:= fnd_global.conc_program_id;

   /*
   ** Reload grouped data into table
   */
   for i in 1..l_counter
   loop
	/*
	** Reload grouped data from memory
	*/

	insert into mtl_period_summary(
	  ACCT_PERIOD_ID
        , ORGANIZATION_ID
 	, INVENTORY_TYPE
        , SECONDARY_INVENTORY
        , LAST_UPDATE_DATE
        , LAST_UPDATED_BY
        , CREATION_DATE
        , CREATED_BY
        , LAST_UPDATE_LOGIN
        , INVENTORY_VALUE
        , REQUEST_ID
        , PROGRAM_APPLICATION_ID
        , PROGRAM_ID
        , PROGRAM_UPDATE_DATE
        , COST_GROUP_ID)
	values(
          l_ps_tbl(i).acct_period_id
        , l_ps_tbl(i).organization_id
        , l_ps_tbl(i).inventory_type
        , NULL
        , l_date
        , l_user_id
        , l_date
        , l_user_id
        , l_login_id
        , l_ps_tbl(i).inventory_value
        , l_request_id
        , l_prog_appl_id
        , l_program_id
        , l_date
        , l_ps_tbl(i).cost_group_id);
   end loop;

   IF(detail_cursor%isopen) THEN CLOSE group_cursor; END IF;
   IF(mps_cursor%isopen) THEN CLOSE mps_cursor; END IF;
   IF(group_cursor%isopen) THEN CLOSE group_cursor; END IF;
   COMMIT;

end if;
exception

     when fnd_api.g_exc_error THEN
	rollback;

	IF(group_cursor%isopen) THEN CLOSE group_cursor; END IF;
        IF(mps_cursor%isopen) THEN CLOSE mps_cursor; END IF;
         x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_period_summary cost group upgrade:'||l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);


      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

	IF(group_cursor%isopen) THEN CLOSE group_cursor; END IF;
        IF(mps_cursor%isopen) THEN CLOSE mps_cursor; END IF;

            x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_period_summary cost group upgrade:'||l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

	IF(group_cursor%isopen) THEN CLOSE group_cursor; END IF;
        IF(mps_cursor%isopen) THEN CLOSE mps_cursor; END IF;

             x_return_status := fnd_api.g_ret_sts_error ;
        /*
        dbms_output.put_line('Org:' || to_char(l_organization_id));
        dbms_output.put_line('Sub:' || l_secondary_inventory);
	  */


	  INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);

      l_return_err := 'mtl_period_summary cost group upgrade:'||
                              substrb(sqlerrm,1,55);
      raise_application_error(-20000,l_return_err);

end INVMPSSB;







-- $Header: INVCGUGB.pls 120.3 2006/03/17 11:47:02 kdong noship $




PROCEDURE INVMPSB(
		  l_organization_id   IN  	NUMBER,
		  USER_NAME           IN        VARCHAR2,
		  PASSWORD            IN        VARCHAR2,
		  x_return_status     OUT NOCOPY	VARCHAR2,
		  x_msg_count         OUT NOCOPY	NUMBER,
		  x_msg_data          OUT NOCOPY	VARCHAR2) AS

--/*
--declare
--  /*
--   ** --------------------------------------------------------
--   ** Organizations that do not have a default cost group yet
--   ** --------------------------------------------------------
--   */
--  */

   cursor org_cursor is
      select
	ROWID
   , material_account
   , material_overhead_account
   , resource_account
   , overhead_account
   , outside_processing_account
   , expense_account
   , encumbrance_account
   , primary_cost_method
   from mtl_parameters
   where (
          default_cost_group_id is null and
          organization_id = l_organization_id
         );

--/*   l_organization_id 		number; */

   l_material_account           number;
   l_material_overhead_account  number;
   l_resource_account           number;
   l_overhead_account           number;
   l_outside_processing_account number;
   l_expense_account            number;
   l_encumbrance_account        number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(540);

   l_cost_group_id              number;
   l_cost_group_id_tbl 		cstpcgut.cost_group_tbl;
   l_count			number;

   l_return_err			varchar2(280);

   l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade organization data
     INVMPSB';
   l_primary_cost_method        NUMBER;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
begin

   l_table_name := 'mtl_parameters';

   /* Bug 4235102 fix */
   /* If there is atleast one record with a costgroup upgrade not needed */
   BEGIN
      SELECT default_cost_group_id
	INTO l_check_cost_group_id
	FROM
	mtl_parameters
	WHERE
	organization_id = l_organization_id
	AND ROWNUM=1;
   EXCEPTION
      WHEN OTHERS THEN
	 NULL;
   END;

   IF Nvl(l_check_cost_group_id,0 ) > 0 THEN
      mydebug('INVMPSB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
      RETURN;
   END IF;
   /* Bug 4235102 fix */

   for c1 in org_cursor
   loop
---/*
--        ** Load cursor output into local variables
--        */
      --/*   	l_organization_id 	     := c1.organization_id; */

       l_rowid_info                  :=c1.ROWID;

   	l_material_account           := c1.material_account;
   	l_material_overhead_account  := c1.material_overhead_account;
   	l_resource_account           := c1.resource_account;
   	l_overhead_account           := c1.overhead_account;
   	l_outside_processing_account := c1.outside_processing_account;
   	l_expense_account            := c1.expense_account;
   	l_encumbrance_account        := c1.encumbrance_account;
	l_primary_cost_method        := c1.primary_cost_method;

        /*
	dbms_output.put_line('Org:' || to_char(l_organization_id));

	dbms_output.put_line('MA:'  || to_char(l_material_account));
	dbms_output.put_line('MOA:' || to_char(l_material_overhead_account));
	dbms_output.put_line('RA:'  || to_char(l_resource_account));
	dbms_output.put_line('OA:'  || to_char(l_overhead_account));
	dbms_output.put_line('OPA:' || to_char(l_outside_processing_account));
	dbms_output.put_line('EA:'  || to_char(l_expense_account));
	dbms_output.put_line('EnA:' || to_char(l_encumbrance_account));
        */


--      ** See if there is there a cost group with matching accounts
--        dbms_output.put_line('before get cost group');

--       The below if condition is added to set the default cost group id
--	  TO 1 whenever the primary costing method IS other than 1

	  IF l_primary_cost_method = 1 then


	    cstpcgut.get_cost_group(
				    x_return_status     		=> l_return_status
				    , x_msg_count         		=> l_msg_count
				    , x_msg_data          		=> l_msg_data
				    , x_cost_group_id_tbl 		=> l_cost_group_id_tbl
				    , x_count             		=> l_count
				    , p_material_account         	=> l_material_account
				    , p_material_overhead_account  	=> l_material_overhead_account
				    , p_resource_account           	=> l_resource_account
				    , p_overhead_account           	=> l_overhead_account
				    , p_outside_processing_account 	=> l_outside_processing_account
				    , p_expense_account            	=> l_expense_account
				    , p_encumbrance_account        	=> l_encumbrance_account
				    , p_organization_id		=> l_organization_id   --NULL
				    , p_cost_group_type_id          => 3);

	    IF l_return_status = fnd_api.g_ret_sts_error THEN
         	RAISE fnd_api.g_exc_error;
	    END IF ;

	    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
		/*
		dbms_output.put_line('Org:' || to_char(l_organization_id));

		dbms_output.put_line('MA:'  || to_char(l_material_account));
		dbms_output.put_line('MOA:' || to_char(l_material_overhead_account));
		dbms_output.put_line('RA:'  || to_char(l_resource_account));
		dbms_output.put_line('OA:'  || to_char(l_overhead_account));
		dbms_output.put_line('OPA:' || to_char(l_outside_processing_account));
		dbms_output.put_line('EA:'  || to_char(l_expense_account));
		dbms_output.put_line('EnA:' || to_char(l_encumbrance_account));
		*/
         	RAISE fnd_api.g_exc_unexpected_error;
	    END IF;


--        ** If there's a cost group matching accounts use it else create
--        ** a new one
--        dbms_output.put_line('before create cost group');
	    if (l_count > 0) then
	       l_cost_group_id := l_cost_group_id_tbl(1);
	     else
	       cstpcgut.create_cost_group(
					  x_return_status     		=> l_return_status
					  , x_msg_count         		=> l_msg_count
					  , x_msg_data          		=> l_msg_data
					  , x_cost_group_id 			=> l_cost_group_id
					  , p_cost_group             		=> NULL
					  , p_material_account         		=> l_material_account
					  , p_material_overhead_account  	=> l_material_overhead_account
					  , p_resource_account           	=> l_resource_account
					  , p_overhead_account           	=> l_overhead_account
					  , p_outside_processing_account 	=> l_outside_processing_account
					  , p_expense_account            	=> l_expense_account
					  , p_encumbrance_account        	=> l_encumbrance_account
					  , p_organization_id			=> l_organization_id
					  , p_cost_group_type_id          	=> 3);

--	  dbms_output.put_line('after create cost group');
	       IF l_return_status = fnd_api.g_ret_sts_error THEN
		  RAISE fnd_api.g_exc_error;
	       END IF ;

	       IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         	RAISE fnd_api.g_exc_unexpected_error;
	       END IF;
	    end if;


	  ELSE

	    l_cost_group_id := 1;

	  END IF;


--        ** Stamp default cost group on org record

--        dbms_output.put_line('before insert ');
--	dbms_output.put_line('cost gr is is' || To_char(l_cost_group_id) );
        update mtl_parameters
        set default_cost_group_id = l_cost_group_id
        where organization_id = l_organization_id;
--	dbms_output.put_line('after insert');
   end loop;

   IF(org_cursor%isopen) THEN CLOSE org_cursor; END IF;

   COMMIT;
exception

     when fnd_api.g_exc_error THEN
	rollback;

	IF(org_cursor%isopen) THEN CLOSE org_cursor; END IF;
         x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => Substr(l_msg_data,1,240),
		   p_proc_name   => l_procedure_name);

--      l_return_err := 'mtl_parameters default cost group upgrade:'|| l_msg_data;

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

	IF(org_cursor%isopen) THEN CLOSE org_cursor; END IF;

         x_return_status := fnd_api.g_ret_sts_error ;


      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

  --    l_return_err := 'mtl_parameters default cost group upgrade:'||l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => Substr(l_msg_data,1,240),
		   p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

	IF(org_cursor%isopen) THEN CLOSE org_cursor; END IF;

         x_return_status := fnd_api.g_ret_sts_error ;
    --  l_return_err := 'mtl_parameters default cost group upgrade:'||
 --	substrb(sqlerrm,1,55);


      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => Substr(l_msg_data,1,240),
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

end INVMPSB;




PROCEDURE INVMOQSB (
		    l_organization_id 	IN  	NUMBER,
		   p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT  NOCOPY VARCHAR2,
		    x_msg_count       	OUT NOCOPY NUMBER,
		    x_msg_data        	OUT  NOCOPY VARCHAR2) AS

--/*
--declare
--   /*
--   ** --------------------------------------------------------
--   ** Org cursor
--   ** --------------------------------------------------------
--   */
--   cursor mp_cursor is
--   select organization_id
--   from mtl_parameters;

--   /*
--   ** --------------------------------------------------------
--   ** On hand records that do not have a default cost group yet
--   ** --------------------------------------------------------
--   */


--  */

   cursor moq_cursor(
     l_organization_id number)
   is
   select
     rowid
   , subinventory_code
   , locator_id
   , project_id
   , task_id
   from mtl_onhand_quantities
   where organization_id = l_organization_id
   and  cost_group_id is null;

--/*
--   l_organization_id 		number;
--  */

   l_rowid                      varchar2(100);
   l_subinventory_code          varchar2(10);
   l_locator_id			number;
   l_project_id			number;
   l_task_id			number;

   v_project_id			number;
   v_task_id			number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_cost_group_id              number;

   l_return_err			varchar2(280);

    l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data INVMOQSB';
   l_cost_method                NUMBER := null ;
   l_org_cost_group_id          NUMBER := NULL;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
begin

--/*
-- for c2 in mp_cursor
-- loop
--   l_organization_id := c2.organization_id;
--  */

   l_table_name           := 'mtl_onhand_quantities';

   /* Bug 4235102 fix */
   /* If there is atleast one record with a costgroup upgrade not needed */
   BEGIN
      SELECT cost_group_id
	INTO l_check_cost_group_id
	FROM
	mtl_onhand_quantities
	WHERE
	organization_id = l_organization_id
	AND ROWNUM=1;
   EXCEPTION
      WHEN OTHERS THEN
	 NULL;
   END;

   IF Nvl(l_check_cost_group_id,0 ) > 0 THEN
      mydebug('INVMOQSB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
      RETURN;
   END IF;
   /* Bug 4235102 fix */


   for c1 in moq_cursor(l_organization_id)
   loop
	/*
        ** Load cursor output into local variables
        */
        l_rowid  		:= c1.rowid;
        l_rowid_info            := l_rowid;

     	l_subinventory_code   	:= c1.subinventory_code;
        l_locator_id		:= c1.locator_id;
        l_project_id		:= c1.project_id;
        l_task_id		:= c1.task_id;

	v_project_id 	:= 0;
	v_task_id 	:= 0;

	/*
	** Check if the locator is tied to a project
	*/
        if (l_locator_id > 0)     and
           (l_project_id is null) and
           (l_task_id is null)    then
                begin
			select
			  to_number(nvl(segment19,'0'))
			, to_number(nvl(segment20,'0'))
			into
			  v_project_id
			, v_task_id
			from mtl_item_locations
			where organization_id       = l_organization_id
			and   inventory_location_id = l_locator_id;
		exception
			when NO_DATA_FOUND then
				v_project_id := 0;
				v_task_id    := 0;
		end;
	end if;

	/*
	** If locator tied to project stamp cost group of project
	** Else stamp cost group of subinventory
	*/
	if (v_project_id > 0) then
             if ( p_cost_method <> 1 ) then
                begin
			select costing_group_id
			into l_cost_group_id
			from pjm_project_parameters
			where project_id      = v_project_id
                	and   organization_id = l_organization_id;

		exception
			when NO_DATA_FOUND then
				l_cost_group_id := 1;
		end;
              else
		l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
	       end if;

		update mtl_onhand_quantities
		set
		  cost_group_id = l_cost_group_id
		, project_id    = v_project_id
		, task_id       = v_task_id
		where rowid = l_rowid;

	else
			   IF ( p_cost_method = 2 ) THEN  /*average costing org */
			         IF ( l_org_cost_group_id IS NULL ) then
				   l_org_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);

				   l_cost_group_id := l_org_cost_group_id ;
				  ELSE
				    l_cost_group_id := l_org_cost_group_id ;
				  END IF;
			    ELSE /* standard costing */
			      l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
			    END IF;

		if (l_cost_group_id > 0) then
			update mtl_onhand_quantities
			set cost_group_id = l_cost_group_id
			where rowid = l_rowid;

		end if;
	end if;
   end loop;

   IF(moq_cursor%isopen) THEN CLOSE moq_cursor; END IF;
   commit;

/*
 end loop;
 */

exception

     when fnd_api.g_exc_error THEN
	rollback;

	 IF(moq_cursor%isopen) THEN CLOSE moq_cursor; END IF;

        x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');


      l_return_err := 'mtl_onhand_quantities cost group upgrade:'|| l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

	 IF(moq_cursor%isopen) THEN CLOSE moq_cursor; END IF;
            x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_onhand_quantities cost group upgrade:'|| l_msg_data;


      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

	 IF(moq_cursor%isopen) THEN CLOSE moq_cursor; END IF;

          x_return_status := fnd_api.g_ret_sts_error ;
	/*
        dbms_output.put_line('Org:' || to_char(l_organization_id));
        dbms_output.put_line('Sub:' || l_subinventory_code);
        dbms_output.put_line('Loc:' || to_char(l_locator_id));
        dbms_output.put_line('Project:' || to_char(v_project_id));
        dbms_output.put_line('Task:' || to_char(v_task_id));
        */


       INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      l_return_err := 'mtl_onhand_quantities cost group upgrade:'||
                              substr(sqlerrm,1,55);
      raise_application_error(-20000,l_return_err);

end INVMOQSB;


PROCEDURE INVMMTSB (
		    l_organization_id 	IN  	NUMBER,
		    p_cost_method	IN	NUMBER,
		    p_open_periods_only	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT  NOCOPY VARCHAR2,
		    x_msg_count       	OUT  NOCOPY NUMBER,
		    x_msg_data        	OUT  NOCOPY VARCHAR2) AS

/* */
--declare
--   /*
--   ** --------------------------------------------------------
--   ** Org cursor
--   ** --------------------------------------------------------
--   */
--   cursor mp_cursor is
--   select organization_id
--   from mtl_parameters;

--   /*
--   ** --------------------------------------------------------
--   ** Transaction records that do not have a default cost group yet
--   ** --------------------------------------------------------
--   */
--  */

/*Bug3768349 --Changed the cursor acct_cursor from org_acct_periods_v to the table org_acct_periods.
              Also removed the condition 'or (rownum<2 and p_open_periods_only<>1)'*/

   cursor acct_cursor(
        l_organization_id number, p_open_periods_only number )
   is
     select period_start_date,
            schedule_close_date
     from org_acct_periods
     where (organization_id = l_organization_id
            and period_start_date <= sysdate and period_close_date is null
            and p_open_periods_only = 1);



   cursor mmt_cursor(
     l_organization_id number,
     l_s_date	date,
     l_e_date	date)
   is
      select
	ROWID
   , transaction_id
   , subinventory_code
   , transfer_organization_id
   , transfer_subinventory
   , project_id
   , to_project_id
   , cost_group_id
   , transfer_cost_group_id
   , transfer_transaction_id
   , transaction_action_id
   , shipment_number
   , inventory_item_id
   from mtl_material_transactions
   where organization_id = l_organization_id
   and transaction_date >= l_s_date
   and transaction_date <= l_e_date
   and transaction_action_id <> 30;

   --bug5073454
   c1 mmt_cursor%ROWTYPE;

   cursor mmt_nodate_cursor(
     l_organization_id number)
   is
      select
	ROWID
   , transaction_id
   , subinventory_code
   , transfer_organization_id
   , transfer_subinventory
   , project_id
   , to_project_id
   , cost_group_id
   , transfer_cost_group_id
   , transfer_transaction_id
   , transaction_action_id
   , shipment_number
   , inventory_item_id
   from mtl_material_transactions
   where organization_id = l_organization_id
   and transaction_action_id <> 30;
   --end5073454


-- and costed_flag <> 'N' and transaction_action_id <> 30;
--   /*
--   ** ---------------------------
--   ** Intransit shipment records
--   ** ---------------------------
--   */
   cursor ms_cursor(
     l_shipment_number 	 varchar2,
     l_organization_id   number,
     l_inventory_item_id number)
   is
   select
     ms.rowid
   , ms.intransit_owning_org_id
   from mtl_supply 		  ms,
        rcv_shipment_headers 	  rsh
   where rsh.shipment_num         = l_shipment_number
   and   ms.shipment_header_id    = rsh.shipment_header_id
   and   ms.supply_type_code      = 'SHIPMENT'
   and   ms.intransit_owning_org_id is not null
   and   ms.item_id               = l_inventory_item_id
   and   ms.from_organization_id  = l_organization_id
   and   NVL(ms.cost_group_id,1) = 1;

--/*
--   l_organization_id 		number;
--  */

   l_transaction_id             number;
   l_subinventory_code          varchar2(10);
   l_transfer_organization_id	number;
   l_transfer_subinventory      varchar2(10);
   l_project_id 		number;
   l_to_project_id 		number;
   l_cost_group_id		number;
   l_transfer_cost_group_id	number;
   l_transfer_transaction_id    number;
   l_transaction_action_id	number;
   l_shipment_number		varchar2(30);
   l_inventory_item_id		number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_return_err			varchar2(280);

   l_ms_rowid			varchar2(100);
   l_intransit_owning_org_id	number;
   l_ms_cost_group_id		number;

   l_cost_group_update		boolean;
   l_transfer_cost_group_update boolean;
   l_date 			varchar2(100);

   l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data INVMMTSB';
   l_org_cost_group_id		number := null ;
   l_s_date			date ;
   l_e_date			date ;
   l_transfer_cost_method	NUMBER;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
   l_dummy                      NUMBER := -1; --bug5073454

begin
   mydebug('sysdate ' ||TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:Mi:SS'));
   mydebug('API time value ' || TO_CHAR(INV_LE_TIMEZONE_PUB.get_le_day_for_inv_org(Sysdate,l_organization_id),'DD-MON-YYYY HH24:Mi:SS'));


/*Bug3768349--Changed the 'for loop' of acct_cursor to normal loop to handle the
               condition if p_open_periods_only <> 1.*/

   open acct_cursor(l_organization_id,p_open_periods_only);
   loop
       if (p_open_periods_only = 1) then
         fetch acct_cursor into l_s_date, l_e_date;
         EXIT when acct_cursor%notfound;

         --bug5073454 use exist to check cost_grp_id existence to replace the original query which
         --using rownum=1 logic. Also break the query for the date condition.
         begin
          select 1
            into l_dummy
            from dual
           where exists (SELECT cost_group_id
                           FROM mtl_material_transactions
                          WHERE organization_id = l_organization_id
                            and cost_group_id is not null
                            and transaction_date >= l_s_date
                            and transaction_date <= l_e_date
                            and transaction_action_id <> 30);
         exception
            when no_data_found then
                 l_dummy :=-999;
         end;
         --endbug5073454

       elsif (p_open_periods_only <> 1) then
        l_s_date := null;
        l_e_date := null;

        --bug5073454
         begin
          select 1
            into l_dummy
            from dual
           where exists (SELECT cost_group_id
                           FROM mtl_material_transactions
                          WHERE organization_id = l_organization_id
                            and cost_group_id is not null
                            and transaction_action_id <> 30);
         exception
            when no_data_found then
                 l_dummy :=-999;
         end;
         --endbug5073454

       end if;

   -- dbms_output.put_line('Org:' || l_organization_id);
       /* Bug 4235102 fix */
       /* If there is atleast one record with a costgroup upgrade not needed */

       IF l_dummy = 1 THEN
	  mydebug('INVMMTSB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
	  RETURN;
       END IF;
       /* Bug 4235102 fix */

       --bug5073454
       if (p_open_periods_only = 1) then
           open mmt_cursor(l_organization_id, l_s_date, l_e_date);
       elsif (p_open_periods_only <> 1) then
           open mmt_nodate_cursor(l_organization_id);
       end if;

       --for c1 in mmt_cursor(l_organization_id, l_s_date, l_e_date)
       loop
       if (p_open_periods_only = 1) then
          fetch mmt_cursor into c1;
          exit when mmt_cursor%notfound;
       elsif (p_open_periods_only <> 1) then
          fetch mmt_nodate_cursor into c1;
          exit when mmt_nodate_cursor%notfound;
       end if;


       -- for c1 in mmt_cursor(l_organization_id, l_s_date, l_e_date)
       -- loop
       --end5073454

	/*
      ** Load cursor output into local variables

	*/

	 l_table_name := 'mtl_material_transactions';

	l_rowid_info               :=c1.ROWID;
        l_transaction_id  	   := c1.transaction_id;
      	l_subinventory_code   	   := c1.subinventory_code;
   	l_transfer_organization_id := c1.transfer_organization_id;
   	l_transfer_subinventory    := c1.transfer_subinventory;
        l_project_id 		   := c1.project_id;
        l_to_project_id            := c1.to_project_id;
   	l_cost_group_id		   := c1.cost_group_id;
   	l_transfer_cost_group_id   := c1.transfer_cost_group_id;
        l_transfer_transaction_id  := c1.transfer_transaction_id;
        l_transaction_action_id	   := c1.transaction_action_id;
        l_shipment_number	   := c1.shipment_number;
        l_inventory_item_id	   := c1.inventory_item_id;

        l_cost_group_update	     := FALSE;
        l_transfer_cost_group_update := FALSE;

	/*
	** If cost group is null and is not a project transcation,
        ** stamp default cost group of subinventory
	*/
	if (l_cost_group_id is null and l_project_id is null) then
	      if ( p_cost_method = 2 ) then
                 if ( l_org_cost_group_id is null ) then
 		   l_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);
		   l_org_cost_group_id := l_cost_group_id ;
		 else
		  l_cost_group_id := l_org_cost_group_id ;
		 end if;
              else
		l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
			  	   , p_subinventory	=> l_subinventory_code);
              end if;
		if (l_cost_group_id > 0) then
        		l_cost_group_update	     := TRUE;
		end if;
	end if;


        if (l_cost_group_id is null and l_project_id is NOT null and p_cost_method = 1) then
	  l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
			  	   , p_subinventory	=> l_subinventory_code);


		if (l_cost_group_id > 0) then
        		l_cost_group_update	     := TRUE;
		end if;
	end if;

	/*
	** If its a transfer transaction and is not a project transaction
        ** stamp default cost group of transfer subinventory
	*/

        if (l_transfer_transaction_id > 0) 	 and
	   (l_transfer_cost_group_id is null) 	 and
	   (l_transfer_organization_id > 0) 	 and
	   (l_transfer_subinventory is not null) and
	   (l_to_project_id is null) then
	     if ( p_cost_method = 2) then
                l_transfer_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_transfer_organization_id);
             else
		l_transfer_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_transfer_organization_id
			  	   , p_subinventory	=> l_transfer_subinventory);
             end if ;
		if (l_transfer_cost_group_id > 0) then
        		l_transfer_cost_group_update := TRUE;
		end if;
	end if;


	if (l_transfer_cost_group_id is null and l_to_project_id is NOT null) then
	  select primary_cost_method into l_transfer_cost_method
	  from mtl_parameters where organization_id = l_transfer_organization_id ;

	  if ( l_transfer_cost_method = 1 ) then
	    l_transfer_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_transfer_organization_id
			  	   , p_subinventory	=> l_transfer_subinventory);
	  end if;

		if (l_transfer_cost_group_id > 0) then
        		l_transfer_cost_group_update	     := TRUE;
		end if;
	end if;


        if (l_cost_group_update	         = TRUE) and
           (l_transfer_cost_group_update = TRUE) then
	        update mtl_material_transactions
		set
                  cost_group_id          = l_cost_group_id
		, transfer_cost_group_id = l_transfer_cost_group_id
		where transaction_id = l_transaction_id;
        elsif (l_cost_group_update	    = TRUE) then
	        update mtl_material_transactions
		set cost_group_id = l_cost_group_id
		where transaction_id = l_transaction_id;
	elsif (l_transfer_cost_group_update = TRUE) then
	        update mtl_material_transactions
		set transfer_cost_group_id = l_transfer_cost_group_id
		where transaction_id = l_transaction_id;
        end if;

        /*
        ** If intransit shipment(action_id =21), we have to update
        ** corresponding record in MTL_SUPPLY too
        */

        if (l_transaction_action_id = 21) and
	  (l_shipment_number is not null) and ( p_cost_method <> 1) THEN

	        l_table_name := 'mmt_supply';

		for c3 in ms_cursor(l_shipment_number,
                                    l_organization_id,
                                    l_inventory_item_id)
                loop
			--
        		-- Load cursor output into local variables
        		--
		        l_ms_rowid	          := c3.rowid;

			l_rowid_info              := l_ms_rowid;
			l_intransit_owning_org_id := c3.intransit_owning_org_id;

			--
			-- If orgs match use cost group of from sub
			-- Else use cost group of intransit owning org
			--
			if l_intransit_owning_org_id = l_organization_id then
			 if ( p_cost_method = 2 ) then
			   if ( l_org_cost_group_id is null ) then
                              l_ms_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);
			      l_org_cost_group_id := l_ms_cost_group_id ;
			   else
			      l_ms_cost_group_id := l_org_cost_group_id ;
			   end if;
			 else
			   l_ms_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
			  	   , p_subinventory	=> l_subinventory_code);
                         end if;
			else
			   l_ms_cost_group_id := inv_sub_cg_util.get_cg_from_org(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_intransit_owning_org_id);
			end if;

			if (l_ms_cost_group_id > 0) then
				update mtl_supply
				set cost_group_id = l_ms_cost_group_id
				where rowid = l_ms_rowid;
			end if;
 		end loop;
	end if;

   end loop;

   IF(mmt_cursor%isopen) THEN CLOSE mmt_cursor; END IF;
   IF(mmt_nodate_cursor%isopen) THEN CLOSE mmt_nodate_cursor; END IF;

   -- To log time and organization
   -- create table mmt_summary(MSG VARCHAR2(1000))
   -- and uncomment next 6 lines

   /*Bug3691888--if p_open_periods_only <> 1 then the outer most loop (acct_cursor) should execute only once.*/
  if p_open_periods_only <> 1 then
   EXIT;
  end if;

 end loop;
 close acct_cursor;


exception

     when fnd_api.g_exc_error THEN
	rollback;

      IF(mmt_cursor%isopen) THEN CLOSE mmt_cursor; END IF;
      IF(mmt_nodate_cursor%isopen) THEN CLOSE mmt_nodate_cursor; END IF;
      IF(ms_cursor%isopen) THEN CLOSE ms_cursor; END IF;
      if(acct_cursor%isopen) then CLOSE acct_cursor; end if;
	    x_return_status := fnd_api.g_ret_sts_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_material_transactions cost group upgrade:'|| l_msg_data;


      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

      IF(mmt_cursor%isopen) THEN CLOSE mmt_cursor; END IF;
      IF(ms_cursor%isopen) THEN CLOSE ms_cursor; END IF;
      if(acct_cursor%isopen) then CLOSE acct_cursor; end if;
	     x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_material_transactions cost group upgrade:'|| l_msg_data;



      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

      IF(mmt_cursor%isopen) THEN CLOSE mmt_cursor; END IF;
      IF(ms_cursor%isopen) THEN CLOSE ms_cursor; END IF;
      if(acct_cursor%isopen) then CLOSE acct_cursor; end if;
         x_return_status := fnd_api.g_ret_sts_error ;
        /*
        dbms_output.put_line('TID:' || to_char(l_transaction_id));
        dbms_output.put_line('Org:' || to_char(l_organization_id));
        dbms_output.put_line('Sub:' || l_subinventory_code);
        */


	INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      l_return_err := 'mtl_material_transactions cost group upgrade:'||
                              substr(sqlerrm,1,55);
      raise_application_error(-20000,l_return_err);


end INVMMTSB;

PROCEDURE INS_ERROR (
		      p_table_name         IN   VARCHAR2,
		      p_ROWID   	   IN  	VARCHAR2,
		      p_org_id             IN   NUMBER,
		      p_error_msg	   IN   VARCHAR2,
                      p_proc_name          IN   VARCHAR2
		    )  AS

l_msg VARCHAR2(300);
BEGIN
l_msg := p_error_msg || ' sql error: ' ||substr(sqlerrm,1,500) ;
   INSERT INTO COST_UPGR_ERROR_TABLE ( table_name, rowid_value, org_id,
				      error_mesg, proc_name)
     VALUES ( p_table_name, p_rowid, p_org_id, substr(l_msg,1,800), p_proc_name);
commit;

END ins_error;


PROCEDURE LAUNCH_UPGRADE(p_open_periods_only	IN	NUMBER default 1) IS
org_id NUMBER;
user_name varchar2(100);
password  varchar2(100);
return_status	VARCHAR2(1);
msg_count       NUMBER;
msg_data        VARCHAR2(240);
l_cost_method	number ;
cursor oid_cursor is select organization_id, primary_cost_method
   from mtl_parameters ;

BEGIN


for c in oid_cursor
loop
  BEGIN
   org_id := c.organization_id;
   l_cost_method := c.primary_cost_method ;

  inv_cg_upgrade.invmsisb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
 if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop ; end if;
 inv_cg_upgrade.invmpsb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
 if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop ; end if;
inv_cg_upgrade.invmoqsb( org_id,
			l_cost_method,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;
/*
if ( p_open_periods_only <> 1 ) then
  inv_cg_upgrade.invmpssb( org_id,
			 l_cost_method,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );

if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;
  end if;
*/
inv_cg_upgrade.invmmtsb( org_id,
			l_cost_method,
			p_open_periods_only,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );

if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;
inv_cg_upgrade.INVMCCESB (
		    org_id,
 		    l_cost_method,
		    USER_NAME,
    		    PASSWORD,
		    return_status,
		    msg_count,
		    msg_data)  ;

if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;
inv_cg_upgrade.INVMPASB  (
		    org_id,
 		    l_cost_method,
		    USER_NAME,
    		    PASSWORD,
		    return_status,
		    msg_count,
		    msg_data)  ;

if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;
inv_cg_upgrade.INVMPITSB (
		    org_id,
 		    l_cost_method,
		    USER_NAME,
    		    PASSWORD,
		    return_status,
		    msg_count,
		    msg_data)  ;


<<continue_loop>>
NULL;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END ;
end loop;

IF ( oid_cursor%isopen) THEN CLOSE oid_cursor ; END IF;



END LAUNCH_UPGRADE ;


-- Adding procedures for updating cycle count replated tables

/* MTL_CYCLE_COUNT_ENTREES */


PROCEDURE INVMCCESB (
		    l_organization_id 	IN  	NUMBER,
		    p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY	VARCHAR2,
		    x_msg_count       	OUT NOCOPY	NUMBER,
		    x_msg_data        	OUT  NOCOPY VARCHAR2) AS

--/*
--declare
--   /*
--   ** --------------------------------------------------------
--   ** Org cursor
--   ** --------------------------------------------------------
--   */
--   cursor mp_cursor is
--   select organization_id
--   from mtl_parameters;

--   /*
--   ** --------------------------------------------------------
--   ** On hand records that do not have a default cost group yet
--   ** --------------------------------------------------------
--   */


--  */

   cursor mcce_cursor(
     l_organization_id number)
   is
   select
     rowid
   , subinventory
   , locator_id
   FROM MTL_CYCLE_COUNT_ENTRIES
   where organization_id = l_organization_id
   and  cost_group_id is null;

--/*
--   l_organization_id 		number;
--  */

   l_rowid                      varchar2(100);
   l_subinventory_code          varchar2(10);
   l_locator_id			number;
   l_project_id			number;
   l_task_id			number;

   v_project_id			number;
   v_task_id			number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_cost_group_id              number;

   l_return_err			varchar2(280);

    l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data INVMOQSB';
   l_cost_method                NUMBER := null ;
   l_org_cost_group_id          NUMBER := NULL;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
begin

--/*
-- for c2 in mp_cursor
-- loop
--   l_organization_id := c2.organization_id;
--  */

   l_table_name           := 'mtl_cycle_count_entries';

   /* Bug 4235102 fix */
   /* If there is atleast one record with a costgroup upgrade not needed */
   BEGIN
      SELECT cost_group_id
	INTO l_check_cost_group_id
	FROM
	MTL_CYCLE_COUNT_ENTRIES
	WHERE
	organization_id = l_organization_id
	AND ROWNUM=1;
   EXCEPTION
      WHEN OTHERS THEN
	    NULL;
   END;

   IF Nvl(l_check_cost_group_id,0 ) > 0 THEN
      mydebug('INVMCCESB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
      RETURN;
   END IF;
   /* Bug 4235102 fix */

   for c1 in mcce_cursor(l_organization_id)
   loop
	/*
        ** Load cursor output into local variables
        */
        l_rowid  		:= c1.rowid;
        l_rowid_info            := l_rowid;

     	l_subinventory_code   	:= c1.subinventory;
        l_locator_id		:= c1.locator_id;
        l_project_id		:= NULL;
        l_task_id		:= NULL;

	v_project_id 	:= 0;
	v_task_id 	:= 0;

	/*
	** Check if the locator is tied to a project
	*/
        if (l_locator_id > 0)     and
           (l_project_id is null) and
           (l_task_id is null)    then
                begin
			select
			  to_number(nvl(segment19,'0'))
			, to_number(nvl(segment20,'0'))
			into
			  v_project_id
			, v_task_id
			from mtl_item_locations
			where organization_id       = l_organization_id
			and   inventory_location_id = l_locator_id;
		exception
			when NO_DATA_FOUND then
				v_project_id := 0;
				v_task_id    := 0;
		end;
	end if;

	/*
	** If locator tied to project stamp cost group of project
	** Else stamp cost group of subinventory
	*/
	if (v_project_id > 0) then
             if ( p_cost_method <> 1 ) then
                begin
			select costing_group_id
			into l_cost_group_id
			from pjm_project_parameters
			where project_id      = v_project_id
                	and   organization_id = l_organization_id;

		exception
			when NO_DATA_FOUND then
				l_cost_group_id := 1;
		end;
              else
		l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
	       end if;

		update mtl_cycle_count_entries
		set
		  cost_group_id = l_cost_group_id
	          where rowid = l_rowid;

	else
			   IF ( p_cost_method = 2 ) THEN  /*average costing org */
			         IF ( l_org_cost_group_id IS NULL ) then
				   l_org_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);

				   l_cost_group_id := l_org_cost_group_id ;
				  ELSE
				    l_cost_group_id := l_org_cost_group_id ;
				  END IF;
			    ELSE /* standard costing */
			      l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
			    END IF;

		if (l_cost_group_id > 0) then
			update mtl_cycle_count_entries
			set cost_group_id = l_cost_group_id
			where rowid = l_rowid;

		end if;
	end if;
   end loop;

   IF(mcce_cursor%isopen) THEN CLOSE mcce_cursor; END IF;
   commit;

/*
 end loop;
 */

exception

     when fnd_api.g_exc_error THEN
	rollback;

	 IF(mcce_cursor%isopen) THEN CLOSE mcce_cursor; END IF;

        x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');


      l_return_err := 'mtl_cycle_count_entries cost group upgrade:'|| l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

	 IF(mcce_cursor%isopen) THEN CLOSE mcce_cursor; END IF;
            x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_cycle_count_entries cost group upgrade:'|| l_msg_data;


      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

	 IF(mcce_cursor%isopen) THEN CLOSE mcce_cursor; END IF;

          x_return_status := fnd_api.g_ret_sts_error ;
	/*
        dbms_output.put_line('Org:' || to_char(l_organization_id));
        dbms_output.put_line('Sub:' || l_subinventory_code);
        dbms_output.put_line('Loc:' || to_char(l_locator_id));
        dbms_output.put_line('Project:' || to_char(v_project_id));
        dbms_output.put_line('Task:' || to_char(v_task_id));
        */


       INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      l_return_err := 'mtl_cycle_count_entries cost group upgrade:'||
                              substr(sqlerrm,1,55);
      raise_application_error(-20000,l_return_err);

end INVMCCESB;






PROCEDURE INVMPASB (
		    l_organization_id 	IN  	NUMBER,
		   p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT  NOCOPY VARCHAR2,
		    x_msg_count       	OUT  NOCOPY NUMBER,
		    x_msg_data        	OUT  NOCOPY VARCHAR2) AS

--/*
--declare
--   /*
--   ** --------------------------------------------------------
--   ** Org cursor
--   ** --------------------------------------------------------
--   */
--   cursor mp_cursor is
--   select organization_id
--   from mtl_parameters;

--   /*
--   ** --------------------------------------------------------
--   ** On hand records that do not have a default cost group yet
--   ** --------------------------------------------------------
--   */


--  */

   cursor mpa_cursor(
     l_organization_id number)
   is
   select
     rowid
   , subinventory_name
   , locator_id
   from mtl_physical_adjustments
   where organization_id = l_organization_id
   and  cost_group_id is null;

--/*
--   l_organization_id 		number;
--  */

   l_rowid                      varchar2(100);
   l_subinventory_code          varchar2(10);
   l_locator_id			number;
   l_project_id			number;
   l_task_id			number;

   v_project_id			number;
   v_task_id			number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_cost_group_id              number;

   l_return_err			varchar2(280);

    l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade physical adjustment data INVMOQSB';
   l_cost_method                NUMBER := null ;
   l_org_cost_group_id          NUMBER := NULL;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
begin

--/*
-- for c2 in mp_cursor
-- loop
--   l_organization_id := c2.organization_id;
--  */

   l_table_name           := 'mtl_physical_adjustments';

   /* Bug 4235102 fix */
   /* If there is atleast one record with a costgroup upgrade not needed */
   BEGIN
      SELECT cost_group_id
	INTO l_check_cost_group_id
	FROM
	mtl_physical_adjustments
	WHERE
	organization_id = l_organization_id
	AND ROWNUM=1;
   EXCEPTION
      WHEN OTHERS THEN
	 NULL;
   END;

   IF Nvl(l_check_cost_group_id,0 ) > 0 THEN
      mydebug('INVMPASB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
      RETURN;
   END IF;
   /* Bug 4235102 fix */

   for c1 in mpa_cursor(l_organization_id)
   loop
	/*
        ** Load cursor output into local variables
        */
        l_rowid  		:= c1.rowid;
        l_rowid_info            := l_rowid;

     	l_subinventory_code   	:= c1.subinventory_name;
        l_locator_id		:= c1.locator_id;
        l_project_id		:= NULL;
        l_task_id		:= NULL;

	v_project_id 	:= 0;
	v_task_id 	:= 0;

	/*
	** Check if the locator is tied to a project
	*/
        if (l_locator_id > 0)     and
           (l_project_id is null) and
           (l_task_id is null)    then
                begin
			select
			  to_number(nvl(segment19,'0'))
			, to_number(nvl(segment20,'0'))
			into
			  v_project_id
			, v_task_id
			from mtl_item_locations
			where organization_id       = l_organization_id
			and   inventory_location_id = l_locator_id;
		exception
			when NO_DATA_FOUND then
				v_project_id := 0;
				v_task_id    := 0;
		end;
	end if;

	/*
	** If locator tied to project stamp cost group of project
	** Else stamp cost group of subinventory
	*/
	if (v_project_id > 0) then
             if ( p_cost_method <> 1 ) then
                begin
			select costing_group_id
			into l_cost_group_id
			from pjm_project_parameters
			where project_id      = v_project_id
                	and   organization_id = l_organization_id;

		exception
			when NO_DATA_FOUND then
				l_cost_group_id := 1;
		end;
              else
		l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
	       end if;

		update mtl_physical_adjustments
		set
		  cost_group_id = l_cost_group_id
		where rowid = l_rowid;

	else
			   IF ( p_cost_method = 2 ) THEN  /*average costing org */
			         IF ( l_org_cost_group_id IS NULL ) then
				   l_org_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);

				   l_cost_group_id := l_org_cost_group_id ;
				  ELSE
				    l_cost_group_id := l_org_cost_group_id ;
				  END IF;
			    ELSE /* standard costing */
			      l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
			    END IF;

		if (l_cost_group_id > 0) then
			update mtl_physical_adjustments
			set cost_group_id = l_cost_group_id
			where rowid = l_rowid;

		end if;
	end if;
   end loop;

   IF(mpa_cursor%isopen) THEN CLOSE mpa_cursor; END IF;
   commit;

/*
 end loop;
 */

exception

     when fnd_api.g_exc_error THEN
	rollback;

	 IF(mpa_cursor%isopen) THEN CLOSE mpa_cursor; END IF;

        x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');


      l_return_err := 'mtl_physical_adjustments cost group upgrade:'|| l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

	 IF(mpa_cursor%isopen) THEN CLOSE mpa_cursor; END IF;
            x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_physical_adjustments cost group upgrade:'|| l_msg_data;


      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

	 IF(mpa_cursor%isopen) THEN CLOSE mpa_cursor; END IF;

          x_return_status := fnd_api.g_ret_sts_error ;
	/*
        dbms_output.put_line('Org:' || to_char(l_organization_id));
        dbms_output.put_line('Sub:' || l_subinventory_code);
        dbms_output.put_line('Loc:' || to_char(l_locator_id));
        dbms_output.put_line('Project:' || to_char(v_project_id));
        dbms_output.put_line('Task:' || to_char(v_task_id));
        */


       INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      l_return_err := 'mtl_physical_adjustments cost group upgrade:'||
                              substr(sqlerrm,1,55);
      raise_application_error(-20000,l_return_err);

end INVMPASB;




PROCEDURE INVMPITSB (
		    l_organization_id 	IN  	NUMBER,
		   p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT  NOCOPY VARCHAR2,
		    x_msg_count       	OUT NOCOPY	NUMBER,
		    x_msg_data        	OUT NOCOPY	VARCHAR2) AS

--/*
--declare
--   /*
--   ** --------------------------------------------------------
--   ** Org cursor
--   ** --------------------------------------------------------
--   */
--   cursor mp_cursor is
--   select organization_id
--   from mtl_parameters;

--   /*
--   ** --------------------------------------------------------
--   ** On hand records that do not have a default cost group yet
--   ** --------------------------------------------------------
--   */


--  */

   cursor mpit_cursor(
     l_organization_id number)
   is
   select
     rowid
   , subinventory
   , locator_id
   from mtl_physical_inventory_tags
   where organization_id = l_organization_id
   and  cost_group_id is null;

--/*
--   l_organization_id 		number;
--  */

   l_rowid                      varchar2(100);
   l_subinventory_code          varchar2(10);
   l_locator_id			number;
   l_project_id			number;
   l_task_id			number;

   v_project_id			number;
   v_task_id			number;

   l_return_status		varchar2(1);
   l_msg_count                  number;
   l_msg_data                   varchar2(240);

   l_cost_group_id              number;

   l_return_err			varchar2(280);

    l_rowid_info                 VARCHAR2(2000);
   l_table_name                 VARCHAR2(300);
   l_procedure_name             VARCHAR2(200):= 'upgrade physical inventory tags INVMPITSB';
   l_cost_method                NUMBER := null ;
   l_org_cost_group_id          NUMBER := NULL;
   l_check_cost_group_id        NUMBER := NULL;/* Bug 4235102 fix */
begin

--/*
-- for c2 in mp_cursor
-- loop
--   l_organization_id := c2.organization_id;
--  */

   l_table_name           := 'mtl_physical_inventory_tags';

   /* Bug 4235102 fix */
   /* If there is atleast one record with a costgroup upgrade not needed */
   BEGIN
      SELECT cost_group_id
	INTO l_check_cost_group_id
	FROM
	mtl_physical_inventory_tags
	WHERE
	organization_id = l_organization_id
	AND ROWNUM=1;
   EXCEPTION
      WHEN OTHERS THEN
	 NULL;
   END;

   IF Nvl(l_check_cost_group_id,0 ) > 0 THEN
      mydebug('INVMPITSB Not running cost group upgrade for organization_id '||l_organization_id||
		 ' as it has atleast one record with costgroup > 0');
      RETURN;
   END IF;
   /* Bug 4235102 fix */

   for c1 in mpit_cursor(l_organization_id)
   loop
	/*
        ** Load cursor output into local variables
        */
        l_rowid  		:= c1.rowid;
        l_rowid_info            := l_rowid;

     	l_subinventory_code   	:= c1.subinventory;
        l_locator_id		:= c1.locator_id;
        l_project_id		:= NULL;
        l_task_id		:= NULL;

	v_project_id 	:= 0;
	v_task_id 	:= 0;

	/*
	** Check if the locator is tied to a project
	*/
        if (l_locator_id > 0)     and
           (l_project_id is null) and
           (l_task_id is null)    then
                begin
			select
			  to_number(nvl(segment19,'0'))
			, to_number(nvl(segment20,'0'))
			into
			  v_project_id
			, v_task_id
			from mtl_item_locations
			where organization_id       = l_organization_id
			and   inventory_location_id = l_locator_id;
		exception
			when NO_DATA_FOUND then
				v_project_id := 0;
				v_task_id    := 0;
		end;
	end if;

	/*
	** If locator tied to project stamp cost group of project
	** Else stamp cost group of subinventory
	*/
	if (v_project_id > 0) then
             if ( p_cost_method <> 1 ) then
                begin
			select costing_group_id
			into l_cost_group_id
			from pjm_project_parameters
			where project_id      = v_project_id
                	and   organization_id = l_organization_id;

		exception
			when NO_DATA_FOUND then
				l_cost_group_id := 1;
		end;
              else
		l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
	       end if;

		update mtl_physical_inventory_tags
		set
		  cost_group_id = l_cost_group_id
		where rowid = l_rowid;

	else
			   IF ( p_cost_method = 2 ) THEN  /*average costing org */
			         IF ( l_org_cost_group_id IS NULL ) then
				   l_org_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);

				   l_cost_group_id := l_org_cost_group_id ;
				  ELSE
				    l_cost_group_id := l_org_cost_group_id ;
				  END IF;
			    ELSE /* standard costing */
			      l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
			    END IF;

		if (l_cost_group_id > 0) then
			update mtl_physical_inventory_tags
			set cost_group_id = l_cost_group_id
			where rowid = l_rowid;

		end if;
	end if;
   end loop;

   IF(mpit_cursor%isopen) THEN CLOSE mpit_cursor; END IF;
   commit;

/*
 end loop;
 */

exception

     when fnd_api.g_exc_error THEN
	rollback;

	 IF(mpit_cursor%isopen) THEN CLOSE mpit_cursor; END IF;

        x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');


      l_return_err := 'mtl_physical_inventory_tags cost group upgrade:'|| l_msg_data;

      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		  p_proc_name   => l_procedure_name);

      raise_application_error(-20000,l_return_err);

     when fnd_api.g_exc_unexpected_error THEN

	rollback;

	 IF(mpit_cursor%isopen) THEN CLOSE mpit_cursor; END IF;
            x_return_status := fnd_api.g_ret_sts_error ;
      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => l_msg_count
           , p_data   => l_msg_data
            );

      l_msg_data := replace(l_msg_data,chr(0),' ');

      l_return_err := 'mtl_physical_inventory_tags cost group upgrade:'|| l_msg_data;


      INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      raise_application_error(-20000,l_return_err);

     when others then
	rollback;

	 IF(mpit_cursor%isopen) THEN CLOSE mpit_cursor; END IF;

          x_return_status := fnd_api.g_ret_sts_error ;
	/*
        dbms_output.put_line('Org:' || to_char(l_organization_id));
        dbms_output.put_line('Sub:' || l_subinventory_code);
        dbms_output.put_line('Loc:' || to_char(l_locator_id));
        dbms_output.put_line('Project:' || to_char(v_project_id));
        dbms_output.put_line('Task:' || to_char(v_task_id));
        */


       INS_ERROR(  p_table_name  => l_table_name,
		   p_ROWID       => l_rowid_info,
		   p_org_id      => l_organization_id,
		   p_error_msg   => l_msg_data,
		   p_proc_name   => l_procedure_name);
      l_return_err := 'mtl_physical_inventory_tags cost group upgrade:'||
                              substr(sqlerrm,1,55);
      raise_application_error(-20000,l_return_err);

end INVMPITSB;

  --      Name: CG_UPGR_FOR_CLOSED_PER_CP
  --
  --      Input parameters: None
  --
  --      Output parameters:
  --                  x_errorbuf  -> Message text buffer
  --                  x_retcode   -> Error Return code
  --
  --      Functions: This API is used in the concurrent program
  --                 'Costgroup upgrade for closed periods'.
  --                 This API inturn calls INV_CG_UPGRADE.LAUNCH_UPGRADE()
  --                 with input parameter 2 to include transactions
  --                 from closed periods for Cost Group Upgrade.

PROCEDURE CG_UPGR_FOR_CLOSED_PER_CP(
                x_errorbuf         OUT NOCOPY VARCHAR2
              , x_retcode          OUT  NOCOPY VARCHAR2) AS
BEGIN
   INV_CG_UPGRADE.LAUNCH_UPGRADE(2);

END CG_UPGR_FOR_CLOSED_PER_CP;


END inv_cg_upgrade;

/
