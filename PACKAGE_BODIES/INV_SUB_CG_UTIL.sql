--------------------------------------------------------
--  DDL for Package Body INV_SUB_CG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_SUB_CG_UTIL" AS
/* $Header: INVSBCGB.pls 120.1 2005/06/15 14:56:29 appldev  $ */

/*
** -------------------------------------------------------------------------
** Function:    validate_cg_update
** Description: Checks if cost group can be updated
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**	       cost group for which the check has to be made
**
** Returns:
**      TRUE if cost group can be updated, else FALSE
**
**      Please use return value to determine if cost group can be updated or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet cost group not be updated
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/
g_pkg_name CONSTANT VARCHAR2(30) := 'INV_SUB_CG_UTIL';

function validate_cg_update (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER) return boolean
  IS

     /*


      --  cursor moq_cursor (v_cost_group_id number)
      --  is
      --  select count(*)
      --  from MTL_ONHAND_QUANTITIES_DETAIL moq
      --	where moq.cost_group_id = v_cost_group_id;

      --	cursor mmt_cursor (v_cost_group_id number)
      -- is
      --select count(*)
      --from mtl_material_transactions mmt
      --where mmt.cost_group_id          = v_cost_group_id
      --  or    mmt.transfer_cost_group_id = v_cost_group_id;


      */

	cursor mmtt_cursor (v_cost_group_id number)
        is
        select count(*)
        from mtl_material_transactions_temp mmtt
	where mmtt.cost_group_id          = v_cost_group_id;

        l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
        l_return_value      boolean 	:= FALSE;

        l_moq_count         number;
        l_mmt_count         number;
        l_mmtt_count        number;
begin
      x_return_status     := fnd_api.g_ret_sts_success;

      --
      -- This shouldn't happen
      --
      if p_cost_group_id is null then
	return FALSE;
      end if;

      --
      -- Check if any row with passed cost group exists in onhand table
      --

      /* c
      --open moq_cursor(p_cost_group_id);
      --fetch moq_cursor into l_moq_count;

      --
      -- If an onhand row exists, return FALSE
      --
      --if (l_moq_count > 0) then
      --  l_return_value := FALSE;
      --else
      --	l_return_value := TRUE;
      --end if;

      --if (l_return_value) then
        --
      	-- Check if any row with passed cost group exists in transactions table
        --
      	--open mmt_cursor(p_cost_group_id);
      	--fetch mmt_cursor into l_mmt_count;

        --
      	-- If a transaction row exists, return FALSE
        --
      	--if (l_mmt_count > 0) then
		--l_return_value := FALSE;
      	--else
		--l_return_value := TRUE;
      	--end if;
      --end if;

      --if (l_return_value) then
        --
      	-- Check if any row with passed cost group exists in pending transactions table
        --


        */



      	open mmtt_cursor(p_cost_group_id);
      	fetch mmtt_cursor into l_mmtt_count;

        --
      	-- If a pending transaction row exists, return FALSE
        --
      	if (l_mmtt_count > 0) then
		l_return_value := FALSE;
      	else
		l_return_value := TRUE;
      	end if;
      --end if;

      -- Close the cursors
      --if moq_cursor%isopen then
	--close moq_cursor;
      --end if;

      --if mmt_cursor%isopen then
	--close mmt_cursor;
      --end if;

      if mmtt_cursor%isopen then
	close mmtt_cursor;
      end if;

      return l_return_value;

exception
   when fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      return FALSE;
      --
   when fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      return FALSE;
      --
   when others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
      THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'validate_cg_update'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      --if moq_cursor%isopen then
      --	close moq_cursor;
      --end if;

      --if mmt_cursor%isopen then
	--close mmt_cursor;
      --end if;

      if mmtt_cursor%isopen then
	close mmtt_cursor;
      end if;

      return FALSE;

end validate_cg_update;

/*
** -------------------------------------------------------------------------
** Function:    validate_cg_delete
** Description: Checks if cost group can be delete
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**	       cost group for which the check has to be made
**
** Returns:
**      TRUE if cost group can be deleted, else FALSE
**
**      Please use return value to determine if cost group can be deleted or not.
**      Do not use x_return_status for this purpose as
**      . x_return_status could be success and yet cost group not be deleted
**      . x_return_status is set to error when an error(such as SQL error)
**        occurs.
** --------------------------------------------------------------------------
*/

function validate_cg_delete (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER
, p_organization_id             IN NUMBER) return boolean
is

   l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
   l_return_value      boolean 	:= FALSE;
   l_cannot_delete     VARCHAR2(1) := 'N';

BEGIN

   x_return_status     := fnd_api.g_ret_sts_success;

   if p_cost_group_id is null then
      return FALSE;
   end if;

   IF p_organization_id IS NULL THEN
      BEGIN
	 SELECT 'Y' INTO l_cannot_delete FROM dual
	   WHERE
	   exists
	   (SELECT organization_id
	    FROM mtl_parameters mp
	    WHERE mp.default_cost_group_id = p_cost_group_id);
      EXCEPTION
	 WHEN no_data_found THEN
	    l_cannot_delete := 'N';
      END;

      IF l_cannot_delete = 'N' THEN
	 BEGIN
	    SELECT 'Y' INTO l_cannot_delete FROM dual
	      WHERE
	      exists
	      (SELECT organization_id
	       FROM mtl_secondary_inventories msi
	       WHERE msi.default_cost_group_id = p_cost_group_id);
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_cannot_delete := 'N';
	 END;
      END IF;

      IF l_cannot_delete = 'N' THEN
         BEGIN
	    SELECT 'Y' INTO l_cannot_delete FROM dual
	      WHERE
	      exists
	      (SELECT organization_id
	       FROM mtl_material_transactions_temp mmtt
	       WHERE
	       (mmtt.cost_group_id  = p_cost_group_id
		OR mmtt.transfer_cost_group_id = p_cost_group_id));
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_cannot_delete := 'N';
	 END;
      END IF;

      IF l_cannot_delete = 'N' THEN
         BEGIN
	    SELECT 'Y' INTO l_cannot_delete FROM dual
	      WHERE
	      exists
	      (SELECT organization_id
	       FROM MTL_ONHAND_QUANTITIES_DETAIL moq
	       WHERE moq.cost_group_id = p_cost_group_id);
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_cannot_delete := 'N';
	 END;
      END IF;

      IF l_cannot_delete = 'N' THEN
	 BEGIN
	    SELECT 'Y' INTO l_cannot_delete FROM dual
	      WHERE
	      exists
	      (SELECT organization_id
	       FROM mtl_material_transactions mmt
	       WHERE
	       (mmt.cost_group_id          = p_cost_group_id
		OR mmt.transfer_cost_group_id = p_cost_group_id));
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_cannot_delete := 'N';
	 END;
      END IF;
    ELSE
	 BEGIN
	    SELECT 'Y' INTO l_cannot_delete FROM dual
	      WHERE
	      exists
	      (SELECT organization_id
	       FROM mtl_parameters mp
	       WHERE mp.default_cost_group_id = p_cost_group_id
	       AND mp.organization_id = p_organization_id);
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_cannot_delete := 'N';
	 END;

	 IF l_cannot_delete = 'N' THEN
            BEGIN
	       SELECT 'Y' INTO l_cannot_delete FROM dual
		 WHERE
		 exists
		 (select organization_id
		  from mtl_secondary_inventories msi
		  where msi.default_cost_group_id = p_cost_group_id
		  AND msi.organization_id = p_organization_id);
	    EXCEPTION
	       WHEN no_data_found THEN
		  l_cannot_delete := 'N';
	    END;
	 END IF;

	 IF l_cannot_delete = 'N' THEN
            BEGIN
	       SELECT 'Y' INTO l_cannot_delete FROM dual
		 WHERE
		 exists
		 (SELECT organization_id
		  FROM mtl_material_transactions_temp mmtt
		  WHERE
		  mmtt.organization_id = p_organization_id AND
		  (mmtt.cost_group_id  = p_cost_group_id
		   OR mmtt.transfer_cost_group_id = p_cost_group_id));
	    EXCEPTION
	       WHEN no_data_found THEN
		  l_cannot_delete := 'N';
	    END;
	 END IF;

	 IF l_cannot_delete = 'N' THEN
            BEGIN
	       SELECT 'Y' INTO l_cannot_delete FROM dual
		 WHERE
		 exists
		 (SELECT organization_id
		  FROM MTL_ONHAND_QUANTITIES_DETAIL moq
		  WHERE moq.cost_group_id = p_cost_group_id
		  AND moq.organization_id = p_organization_id);
	    EXCEPTION
	 WHEN no_data_found THEN
	    l_cannot_delete := 'N';      END;
	 END IF;

	 IF l_cannot_delete = 'N' THEN
            BEGIN
	       SELECT 'Y' INTO l_cannot_delete FROM dual
		 WHERE
		 exists
		 (SELECT organization_id
		  FROM mtl_material_transactions mmt
		  WHERE mmt.organization_id = p_organization_id AND
		  (mmt.cost_group_id          = p_cost_group_id
		   OR mmt.transfer_cost_group_id = p_cost_group_id));
	    EXCEPTION
	       WHEN no_data_found THEN
		  l_cannot_delete := 'N';
	    END;
	 END IF;
   END IF;--If p_organization_id is null

   IF l_cannot_delete = 'Y' THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
   END IF;

EXCEPTION
   when fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
	   );

      return FALSE;
      --
   when fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

      --  Get message count and data
      fnd_msg_pub.count_and_get
	(  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

      return FALSE;
      --
   when others THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error ;
      --
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
	THEN
         fnd_msg_pub.add_exc_msg
           (  g_pkg_name
              , 'validate_cg_update'
              );
      END IF;

      --  Get message count and data
      fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
	     , p_data   => x_msg_data
            );
      return FALSE;
end validate_cg_delete;

/*
** -------------------------------------------------------------------------
** Procedure:   update_sub_accounts
** Description: Updates a given subinventory with a given cost group's accounts
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**             	cost group whose accounts have to be used to update subinventory
**      p_organization_id
**	       	organization to which the to be subinventory belongs
**      p_subinventory
**		subinventory whose accounts have to be synchronized with those
**		of cost group
**
** Returns:
**	none
** --------------------------------------------------------------------------
*/

procedure update_sub_accounts (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER
, p_organization_id             IN  NUMBER
, p_subinventory                IN  VARCHAR2)
is
    l_material_account			number;
    l_material_overhead_account		number;
    l_resource_account			number;
    l_overhead_account			number;
    l_outside_processing_account	number;
    l_expense_account			number;
    l_encumbrance_account		number;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(240);

    l_average_cost_var_account   	number;
    l_payback_mat_var_account    	number;
    l_payback_res_var_account    	number;
    l_payback_osp_var_account   	number;
    l_payback_moh_var_account  		number;
    l_payback_ovh_var_account 		number;

begin
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT upd_sub_sa;

    --
    -- Get the cost group's accounts
    --
    cstpcgut.get_cost_group_accounts(
      x_return_status 		   => l_return_status
    , x_msg_count     		   => l_msg_count
    , x_msg_data      		   => l_msg_data
    , x_material_account  	   => l_material_account
    , x_material_overhead_account  => l_material_overhead_account
    , x_resource_account           => l_resource_account
    , x_overhead_account           => l_overhead_account
    , x_outside_processing_account => l_outside_processing_account
    , x_expense_account            => l_expense_account
    , x_encumbrance_account        => l_encumbrance_account
    , x_average_cost_var_account   => l_average_cost_var_account
    , x_payback_mat_var_account    => l_payback_mat_var_account
    , x_payback_res_var_account    => l_payback_res_var_account
    , x_payback_osp_var_account    => l_payback_osp_var_account
    , x_payback_moh_var_account    => l_payback_moh_var_account
    , x_payback_ovh_var_account    => l_payback_ovh_var_account
    , p_cost_group_id              => p_cost_group_id
    , p_organization_id		   => p_organization_id);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
    END IF ;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Update the subinventory with the cost group's accounts
    --

    update mtl_secondary_inventories
    set
      material_account  	 =  l_material_account
    , material_overhead_account  =  l_material_overhead_account
    , resource_account           =  l_resource_account
    , overhead_account           =  l_overhead_account
    , outside_processing_account =  l_outside_processing_account
    , expense_account            =  l_expense_account
    , encumbrance_account        =  l_encumbrance_account
    where organization_id          = p_organization_id
    and   secondary_inventory_name = p_subinventory;

    x_return_status := l_return_status;

exception
 WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO upd_sub_sa;
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

 WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO upd_sub_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

 WHEN OTHERS THEN
        ROLLBACK TO upd_sub_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'update_sub_accounts'
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

end update_sub_accounts;

/*
** -------------------------------------------------------------------------
** Procedure:   update_org_accounts
** Description: Updates a given organization with a given cost group's accounts
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**             	cost group whose accounts have to be used to update organization
**      p_organization_id
**		organization whose accounts have to be synchronized with those
**		of cost group
**
** Returns:
**	none
** --------------------------------------------------------------------------
*/

procedure update_org_accounts (
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER
, p_organization_id             IN  NUMBER)
is
    l_material_account			number;
    l_material_overhead_account		number;
    l_resource_account			number;
    l_overhead_account			number;
    l_outside_processing_account	number;
    l_expense_account			number;
    l_encumbrance_account		number;

    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count         number;
    l_msg_data          varchar2(240);

    l_average_cost_var_account   	number;
    l_payback_mat_var_account    	number;
    l_payback_res_var_account    	number;
    l_payback_osp_var_account   	number;
    l_payback_moh_var_account  		number;
    l_payback_ovh_var_account 		number;
begin
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT upd_org_sa;

    --
    -- Get the cost group's accounts
    --
    cstpcgut.get_cost_group_accounts(
      x_return_status 		   => l_return_status
    , x_msg_count     		   => l_msg_count
    , x_msg_data      		   => l_msg_data
    , x_material_account  	   => l_material_account
    , x_material_overhead_account  => l_material_overhead_account
    , x_resource_account           => l_resource_account
    , x_overhead_account           => l_overhead_account
    , x_outside_processing_account => l_outside_processing_account
    , x_expense_account            => l_expense_account
    , x_encumbrance_account        => l_encumbrance_account
    , x_average_cost_var_account   => l_average_cost_var_account
    , x_payback_mat_var_account    => l_payback_mat_var_account
    , x_payback_res_var_account    => l_payback_res_var_account
    , x_payback_osp_var_account    => l_payback_osp_var_account
    , x_payback_moh_var_account    => l_payback_moh_var_account
    , x_payback_ovh_var_account    => l_payback_ovh_var_account
    , p_cost_group_id              => p_cost_group_id
    , p_organization_id		   => p_organization_id);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
    END IF ;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    --
    -- Update the organization with the cost group's accounts
    --

    update mtl_parameters
    set
      material_account  	 =  l_material_account
    , material_overhead_account  =  l_material_overhead_account
    , resource_account           =  l_resource_account
    , overhead_account           =  l_overhead_account
    , outside_processing_account =  l_outside_processing_account
    , expense_account            =  l_expense_account
    , encumbrance_account        =  l_encumbrance_account
    where organization_id          = p_organization_id;

    x_return_status := l_return_status;

exception
 WHEN fnd_api.g_exc_error THEN
        ROLLBACK TO upd_org_sa;
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

 WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK TO upd_org_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

 WHEN OTHERS THEN
        ROLLBACK TO upd_org_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'update_org_accounts'
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

end update_org_accounts;

/*
** -------------------------------------------------------------------------
** Procedure:   get_subs_from_cg
** Description: Returns all subinventories that have given cost group as
**    		default cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**	x_sub_tbl
**		table of subinventories that have given cost group as default
**		cost group
**      x_count
**		number of records in x_sub_tbl
** Input:
**      p_cost_group_id
**              cost group to be checked if default cost group in subinventories
**		table
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/

procedure get_subs_from_cg(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_sub_tbl                     OUT NOCOPY inv_sub_cg_util.sub_rec_tbl
, x_count                       OUT NOCOPY NUMBER
, p_cost_group_id               IN  NUMBER)
is
	cursor subinventory_cursor
	is
	select organization_id, secondary_inventory_name
	from mtl_secondary_inventories
	where default_cost_group_id = p_cost_group_id;

        l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
        l_count 	    integer := 0;
begin
    	x_return_status := fnd_api.g_ret_sts_success;

        for c1 in subinventory_cursor
        loop
		l_count := l_count + 1;
		x_sub_tbl(l_count).organization_id := c1.organization_id;
		x_sub_tbl(l_count).subinventory    := c1.secondary_inventory_name;
        end loop;

	x_count := l_count;
exception
 WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_count         := 0;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

 WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_count         := 0;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

  WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_count         := 0;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'get_subs_from_cg'
              );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
end get_subs_from_cg;

/*
** -------------------------------------------------------------------------
** Procedure:   get_orgs_from_cg
** Description: Returns all organizations that have given cost group as
**		default cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
**	x_org_tbl
**		table of organizations that have given cost group as default
**		cost group
**      x_count
**		number of records in x_org_tbl
** Input:
**      p_cost_group_id
**              cost group to be checked if default cost group in organizations
**		table
**
** Returns:
**      none
** --------------------------------------------------------------------------
*/
procedure get_orgs_from_cg(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, x_org_tbl                     OUT NOCOPY inv_sub_cg_util.org_rec_tbl
, x_count                       OUT NOCOPY NUMBER
, p_cost_group_id               IN  NUMBER)
is
	cursor org_cursor
	is
	select organization_id
	from mtl_parameters
	where default_cost_group_id = p_cost_group_id;

        l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
        l_count 	    integer := 0;
begin
    	x_return_status := fnd_api.g_ret_sts_success;

        for c1 in org_cursor
        loop
		l_count := l_count + 1;
		x_org_tbl(l_count).organization_id := c1.organization_id;
        end loop;

	x_count := l_count;
exception
 WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;
        x_count         := 0;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

 WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_count         := 0;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

  WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;
        x_count         := 0;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'get_orgs_from_cg'
            );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );
end get_orgs_from_cg;

/*
** -------------------------------------------------------------------------
** Procedure:   get_cg_from_org
** Description: Returns default cost group of given organization
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_organization_id
**              organization whose default cost group has to be found
**
** Returns:
**      default cost group of organization.
**      0    - no default cost group
**      !(0) - default cost group exists
** --------------------------------------------------------------------------
*/

function get_cg_from_org(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_organization_id             IN  NUMBER) return number
is
  	l_cost_group_id     number      := 0;
begin
        x_return_status     := fnd_api.g_ret_sts_success;

	select nvl(default_cost_group_id,0)
	into l_cost_group_id
	from mtl_parameters
	where organization_id = p_organization_id;

	return l_cost_group_id;
exception
 WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

	return 0;

 WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

	return 0;

  WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'get_cg_from_org'
            );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
	  );

	return 0;
end get_cg_from_org;

/*
** -------------------------------------------------------------------------
** Procedure:   get_cg_from_sub
** Description: Returns default cost group of given subinventory
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_organization_id
		organization to which subinventory belongs
**      p_subinventory
**              subinventory whose default cost group has to be found
**
** Returns:
**      default cost group of subinventory.
**      0    - no default cost group
**      !(0) - default cost group exists
** --------------------------------------------------------------------------
*/

function get_cg_from_sub(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_organization_id             IN  NUMBER
, p_subinventory                IN  VARCHAR2) return number
is
  	l_cost_group_id     number      := 0;
begin
        x_return_status     := fnd_api.g_ret_sts_success;

	select nvl(default_cost_group_id,0)
	into l_cost_group_id
	from mtl_secondary_inventories
	where organization_id          = p_organization_id
        and   secondary_inventory_name = p_subinventory;

	return l_cost_group_id;
exception
 WHEN fnd_api.g_exc_error THEN
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

	return 0;

 WHEN fnd_api.g_exc_unexpected_error THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

	return 0;

  WHEN OTHERS THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'get_cg_from_sub'
            );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
	  );

	return 0;
end get_cg_from_sub;

/*
** -------------------------------------------------------------------------
** Procedure:   find_update_subs_accounts
** Description: For a given cost group, all subinventories that have it as a
**		default cost group are found and their accounts are
**		synchronized with those of the cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**              cost group whose accounts will be used to synchronize with
**              accounts of subinventories that have this cost group as
**		the default cost group
** Returns:
**	none
** --------------------------------------------------------------------------
*/

procedure find_update_subs_accounts(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER)
is
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count		number;
    l_msg_data          varchar2(240);

    l_sub_tbl  	        inv_sub_cg_util.sub_rec_tbl;
    l_count	        number;
begin
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT upd_subs_accs_sa;

    --
    -- Get the subinventories that have the passed cost group as
    -- the default cost group
    --
    inv_sub_cg_util.get_subs_from_cg(
      x_return_status => l_return_status
    , x_msg_count     => l_msg_count
    , x_msg_data      => l_msg_data
    , x_sub_tbl       => l_sub_tbl
    , x_count         => l_count
    , p_cost_group_id => p_cost_group_id);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
    END IF ;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    if (l_count > 0) then
	for i in 1..l_count loop
                --
		-- Synchronize the subinventory accounts with those of the
		-- passed cost group.
		--
		inv_sub_cg_util.update_sub_accounts (
		  x_return_status   => l_return_status
		, x_msg_count       => l_msg_count
                , x_msg_data        => l_msg_data
                , p_cost_group_id   => p_cost_group_id
                , p_organization_id => l_sub_tbl(i).organization_id
                , p_subinventory    => l_sub_tbl(i).subinventory);

    		IF l_return_status = fnd_api.g_ret_sts_error THEN
         		RAISE fnd_api.g_exc_error;
    		END IF ;

    		IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         		RAISE fnd_api.g_exc_unexpected_error;
    		END IF;
	end loop;
    end if;

    x_return_status := l_return_status;
exception
 WHEN fnd_api.g_exc_error THEN
        ROLLBACK to upd_subs_accs_sa;
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

 WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK to upd_subs_accs_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

  WHEN OTHERS THEN
        ROLLBACK to upd_subs_accs_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'find_update_subs_accounts'
            );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

end find_update_subs_accounts;

/*
** -------------------------------------------------------------------------
** Procedure:   find_update_orgs_accounts
** Description: For a given cost group, all organziations that have it as a
**              default cost group are found and their accounts are
**              synchronized with those of the cost group
** Output:
**      x_return_status
**              return status indicating success, error, unexpected error
**      x_msg_count
**              number of messages in message list
**      x_msg_data
**              if the number of messages in message list is 1, contains
**              message text
** Input:
**      p_cost_group_id
**              cost group whose accounts will be used to synchronize with
**              accounts of organziations that have this cost group as
**              the default cost group
** Returns:
**      none
** --------------------------------------------------------------------------
*/
procedure find_update_orgs_accounts(
  x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
, p_cost_group_id               IN  NUMBER)
is
    l_return_status     varchar2(1) := fnd_api.g_ret_sts_success;
    l_msg_count		number;
    l_msg_data          varchar2(240);

    l_org_tbl  	        inv_sub_cg_util.org_rec_tbl;
    l_count	        number;
begin
    x_return_status := fnd_api.g_ret_sts_success;

    SAVEPOINT upd_orgs_accs_sa;

    --
    -- Get the organizations that have the passed cost group as
    -- the default cost group
    --
    inv_sub_cg_util.get_orgs_from_cg(
      x_return_status => l_return_status
    , x_msg_count     => l_msg_count
    , x_msg_data      => l_msg_data
    , x_org_tbl       => l_org_tbl
    , x_count         => l_count
    , p_cost_group_id => p_cost_group_id);

    IF l_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
    END IF ;

    IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    if (l_count > 0) then
	for i in 1..l_count loop
                --
		-- Synchronize the organization accounts with those of the
		-- passed cost group.
		--
		inv_sub_cg_util.update_org_accounts (
		  x_return_status   => l_return_status
		, x_msg_count       => l_msg_count
                , x_msg_data        => l_msg_data
                , p_cost_group_id   => p_cost_group_id
                , p_organization_id => l_org_tbl(i).organization_id);

    		IF l_return_status = fnd_api.g_ret_sts_error THEN
         		RAISE fnd_api.g_exc_error;
    		END IF ;

    		IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
         		RAISE fnd_api.g_exc_unexpected_error;
    		END IF;
	end loop;
    end if;

    x_return_status := l_return_status;
exception
 WHEN fnd_api.g_exc_error THEN
        ROLLBACK to upd_orgs_accs_sa;
        x_return_status := fnd_api.g_ret_sts_error;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count => x_msg_count
           , p_data  => x_msg_data
           );

 WHEN fnd_api.g_exc_unexpected_error THEN
        ROLLBACK to upd_orgs_accs_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

  WHEN OTHERS THEN
        ROLLBACK to upd_orgs_accs_sa;
        x_return_status := fnd_api.g_ret_sts_unexp_error ;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error)
          THEN
           fnd_msg_pub.add_exc_msg
             (  g_pkg_name
              , 'find_update_orgs_accounts'
            );
        END IF;

        --  Get message count and data
        fnd_msg_pub.count_and_get
          (  p_count  => x_msg_count
           , p_data   => x_msg_data
            );

end find_update_orgs_accounts;

end INV_SUB_CG_UTIL;

/
