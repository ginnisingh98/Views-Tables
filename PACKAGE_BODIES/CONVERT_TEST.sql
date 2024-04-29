--------------------------------------------------------
--  DDL for Package Body CONVERT_TEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CONVERT_TEST" AS
/* $Header: WMSCGUGB.pls 120.1 2005/06/15 14:31:58 appldev  $*/

PROCEDURE INVMSISB(
		    l_organization_id 	IN  	NUMBER,
		   USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	  	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		    x_msg_data        	OUT NOCOPY 	VARCHAR2) AS


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
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data INVMSISB';

begin
   l_table_name := 'MTL_SECONDARY_INVENTORIES';
   for c1 in subinventory_cursor

     loop


--	/*
--       Load cursor output into local variables
--
--	  l_organization_id 	     := c1.organization_id;
--	*/

      l_rowid_info                   := c1.ROWID;
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
   	  , p_material_overhead_account  	=> l_resource_account
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
                  USER_NAME           IN        VARCHAR2,
		  PASSWORD            IN        VARCHAR2,
		  x_return_status     OUT NOCOPY 	VARCHAR2,
		  x_msg_count         OUT NOCOPY 	NUMBER,
		  x_msg_data          OUT NOCOPY 	VARCHAR2) AS

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
		l_cost_group_id := inv_sub_cg_util.get_cg_from_org(
                                     x_return_status    => l_return_status
                                   , x_msg_count        => l_msg_count
                                   , x_msg_data         => l_msg_data
                                   , p_organization_id  => l_organization_id);

                if (l_cost_group_id > 0) then
                        update mtl_period_summary
                        set cost_group_id = l_cost_group_id
                        where rowid = l_rowid;
                end if;
	end if;
   end loop;

   l_counter := 0;

   l_table_name := 'mtl_period_summary';

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







-- $Header: WMSCGUGB.pls 120.1 2005/06/15 14:31:58 appldev  $




PROCEDURE INVMPSB(
		  l_organization_id   IN  	NUMBER,
		  USER_NAME           IN        VARCHAR2,
		  PASSWORD            IN        VARCHAR2,
		  x_return_status     OUT NOCOPY 	VARCHAR2,
		  x_msg_count         OUT NOCOPY 	NUMBER,
		  x_msg_data          OUT NOCOPY 	VARCHAR2) AS

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
   l_procedure_name             VARCHAR2(200):= 'upgrade subinventory data INVMPSB';

begin

   l_table_name := 'mtl_parameters';

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
   	  , p_material_overhead_account  	=> l_resource_account
   	  , p_resource_account           	=> l_resource_account
   	  , p_overhead_account           	=> l_overhead_account
   	  , p_outside_processing_account 	=> l_outside_processing_account
   	  , p_expense_account            	=> l_expense_account
   	  , p_encumbrance_account        	=> l_encumbrance_account
          , p_organization_id			=> l_organization_id  --NULL
          , p_cost_group_type_id          	=> 3);

--	  dbms_output.put_line('after create cost group');
	  IF l_return_status = fnd_api.g_ret_sts_error THEN
         	RAISE fnd_api.g_exc_error;
    	  END IF ;

    	  IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         	RAISE fnd_api.g_exc_unexpected_error;
    	  END IF;
        end if;


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
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		    x_msg_data        	OUT NOCOPY 	VARCHAR2) AS

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

begin

--/*
-- for c2 in mp_cursor
-- loop
--   l_organization_id := c2.organization_id;
--  */

   l_table_name           := 'mtl_onhand_quantities';

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
	** If locator tied to project stamp cost group of project for a
	** average costed org. For a standard costed org should stamp
	** the cost grp id of the sub level along with project id and task id
	** Else stamp cost group of subinventory for a standard costed
	** org and for the org level for a average costed org

	*/
	if (v_project_id > 0) THEN
	   -- should come here only if it is a project enabled org
	   IF ( l_cost_method IS NULL ) THEN
	      SELECT NVL(primary_cost_method,1) INTO l_cost_method
		FROM mtl_parameters WHERE
		organization_id = l_organization_id ;
	   END IF;
	   IF ( l_cost_method = 2 ) THEN  /*average costing org */
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
	    ELSE /* standard costing */
			   l_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
				, p_subinventory	=> l_subinventory_code);
	   END IF;

	   update mtl_onhand_quantities
	     set
	        cost_group_id = l_cost_group_id
	      , project_id    = v_project_id
	      , task_id       = v_task_id
	  where rowid = l_rowid;

	else
			   IF ( l_cost_method IS NULL ) THEN
			      SELECT NVL(primary_cost_method,1) INTO l_cost_method
				FROM mtl_parameters WHERE
				organization_id = l_organization_id ;
			   END IF;
			   IF ( l_cost_method = 2 ) THEN  /*average costing org */
			         IF ( l_org_cost_group_id IS NULL ) then
				   select nvl(default_cost_group_id,0)
				   into l_org_cost_group_id
				   from mtl_parameters
				     where organization_id = l_organization_id;
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
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		    x_msg_data        	OUT NOCOPY 	VARCHAR2) AS

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

   cursor mmt_cursor(
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
   where organization_id = l_organization_id;

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
   and   ms.cost_group_id is null;

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
begin

--/*
-- for c2 in mp_cursor
-- loop
--   l_organization_id := c2.organization_id;

--  */

   -- dbms_output.put_line('Org:' || l_organization_id);


   for c1 in mmt_cursor(l_organization_id)
   loop
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
		l_transfer_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_transfer_organization_id
			  	   , p_subinventory	=> l_transfer_subinventory);

		if (l_transfer_cost_group_id > 0) then
        		l_transfer_cost_group_update := TRUE;
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
	  (l_shipment_number is not null) THEN

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
			   l_ms_cost_group_id := inv_sub_cg_util.get_cg_from_sub(
				     x_return_status	=> l_return_status
                		   , x_msg_count        => l_msg_count
				   , x_msg_data		=> l_msg_data
				   , p_organization_id  => l_organization_id
			  	   , p_subinventory	=> l_subinventory_code);
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

   -- To log time and organization
   -- create table mmt_summary(MSG VARCHAR2(1000))
   -- and uncomment next 6 lines
/*
   select to_char(sysdate, 'DD-MON-YY HH24:MI:SS')
   into l_date from dual;

   insert into mmt_summary values('Org ' ||
   				  to_char(l_organization_id) ||
                                   ':' || l_date);

     commit;

     IF(mmt_cursor%isopen) THEN CLOSE mmt_cursor; END IF;
      IF(ms_cursor%isopen) THEN CLOSE ms_cursor; END IF;
*/

/*
 end loop;
  */

exception

     when fnd_api.g_exc_error THEN
	rollback;

      IF(mmt_cursor%isopen) THEN CLOSE mmt_cursor; END IF;
      IF(ms_cursor%isopen) THEN CLOSE ms_cursor; END IF;

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


PROCEDURE LAUNCH_UPGRADE IS
org_id NUMBER;
user_name varchar2(100);
password  varchar2(100);
return_status	VARCHAR2(1);
msg_count       NUMBER;
msg_data        VARCHAR2(240);
cursor oid_cursor is select organization_id
   from mtl_parameters ;

BEGIN


for c in oid_cursor
loop
  BEGIN
   org_id := c.organization_id;

  convert_test.invmsisb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
 if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop ; end if;
 convert_test.invmpsb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
 if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop ; end if;
convert_test.invmoqsb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;

  convert_test.invmpssb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
if ( return_status = fnd_api.g_ret_sts_error ) then GOTO continue_loop; end if;
convert_test.invmmtsb( org_id,
                        user_name,
                        password,
                        return_status,
                        msg_count,
                        msg_data
                       );
<<continue_loop>>
NULL;
  EXCEPTION
    WHEN OTHERS THEN NULL;
  END ;
end loop;

IF ( oid_cursor%isopen) THEN CLOSE oid_cursor ; END IF;



END LAUNCH_UPGRADE ;




END CONVERT_TEST;

/
