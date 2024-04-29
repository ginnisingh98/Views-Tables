--------------------------------------------------------
--  DDL for Package Body MRP_SOURCING_API_PK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SOURCING_API_PK" AS
    /* $Header: MRPSAPIB.pls 120.2 2006/03/08 04:50:40 davashia noship $ */

p_cutoff_history_days NUMBER := NVL(TO_NUMBER(FND_PROFILE.VALUE('MRP_CUTOFF_HISTORY_DAYS')),9999);
mrdebug                 BOOLEAN             := FALSE;
cutoff_history_date     NUMBER              := to_number(to_char(trunc(SYSDATE),'j')) - p_cutoff_history_days;

FUNCTION    validate_item(
                arg_item_id                 IN          NUMBER,
                arg_org_id                  IN          NUMBER,
                arg_sub_inv                 IN          VARCHAR2 /* Bug 1646303 - changed */
                                                                 /*  datatype to varchar2 */
                                DEFAULT NULL)
            RETURN BOOLEAN IS

            var_stk         VARCHAR2(10);
            var_restrict    NUMBER;
BEGIN

    mrdebug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';
    SELECT  stock_enabled_flag, restrict_subinventories_code
    INTO    var_stk,
            var_restrict
    FROM    mtl_system_items
    WHERE   organization_id = arg_org_id
    AND     inventory_item_id = arg_item_id;

    if var_stk <> 'Y'
    then
        return FALSE;
    end if;

    if arg_sub_inv is not null AND var_restrict = 1
    then
        BEGIN
            SELECT  'Y'
            into    var_stk
            FROM    mtl_item_sub_inventories
            WHERE   organization_id = arg_org_id
            AND     inventory_item_id = arg_item_id
            AND     secondary_inventory = arg_sub_inv;

        EXCEPTION
            WHEN no_data_found THEN
                RETURN FALSE;
        END;
    end if;
    RETURN TRUE;
END validate_item;

FUNCTION    mrp_sourcing(
                arg_mode                    IN          VARCHAR2,
                arg_item_id                 IN          NUMBER,
                arg_commodity_id            IN          NUMBER,
                arg_dest_organization_id    IN          NUMBER,
                arg_dest_subinventory       IN          VARCHAR2,
                arg_autosource_date         IN          DATE,
                arg_vendor_id               OUT  NOCOPY          NUMBER,
                arg_vendor_site_code        OUT  NOCOPY          VARCHAR2,
                arg_source_organization_id  IN OUT  NOCOPY       NUMBER,
                arg_source_subinventory     IN OUT  NOCOPY       VARCHAR2,/* Bug # 1646303 - changed */
                                                                 /* datatype to varchar2 */
                arg_sourcing_rule_id        OUT  NOCOPY          NUMBER,
                arg_error_message           OUT  NOCOPY          VARCHAR2)
            RETURN BOOLEAN IS

            var_set_id          NUMBER;
            var_vendor_id       NUMBER;
            var_site_id         NUMBER;
	        var_new_site_code   po_vendor_sites_all.vendor_site_code%type;
            var_source_org      NUMBER;
            var_alloc_percent   NUMBER;
            var_rank            NUMBER;
            var_sr_id           NUMBER;
            var_source_sub      VARCHAR2(30);

            found_org           BOOLEAN;
            found_ven           BOOLEAN;

            cursor sourcing( p_source_organization_id NUMBER) is
            SELECT  misl.vendor_id,
                    misl.vendor_site_id,
                    misl.source_organization_id,
                    misl.allocation_percent,
                    NVL(misl.rank, 9999),
                    misl.sourcing_rule_id
            FROM    mrp_item_sourcing_levels_v misl
            WHERE   misl.source_type in (1,3)
            and     misl.inventory_item_id = arg_item_id
            and     misl.organization_id = arg_dest_organization_id
            and     misl.assignment_set_id = var_set_id
            and     arg_autosource_date between misl.effective_date and
                    NVL(disable_date, to_date(2634525, 'J'))
            and     PO_ASL_SV.check_asl_action('2_SOURCING',
                    misl.vendor_id, misl.vendor_site_id, arg_item_id, -1
		      , arg_dest_organization_id ) <> 0
	    AND  nvl(nvl(p_source_organization_id,
			  	     misl.source_organization_id), -23453)
                 	= nvl(misl.source_organization_id, -23453)
            ORDER BY misl.sourcing_level ASC,
                    allocation_percent DESC, NVL(misl.rank, 9999) ASC;
BEGIN

        IF arg_source_organization_id IS NOT NULL AND
	  arg_source_subinventory IS NOT NULL THEN
	   RETURN TRUE;
	END IF;


        found_org := FALSE;
        found_ven := FALSE;
        arg_error_message := null;
/*        arg_source_organization_id := null; */
        arg_vendor_id := null;
        arg_vendor_site_code := null;
        mrdebug := FND_PROFILE.VALUE('MRP_DEBUG') = 'Y';

        /*------------------------------------------------------------+
         |  First check the item-sub level if the mode is Inventory   |
         |  or both                                                   |
         +------------------------------------------------------------*/
        if arg_mode = 'INVENTORY' or arg_mode = 'BOTH'
        then
            BEGIN

                select  misi.source_organization_id,
                        misi.source_subinventory
                into    var_source_org,
                        var_source_sub
                from    mtl_item_sub_inventories misi,
                        org_organization_definitions ood,
                        financials_system_parameters fsp
                where   misi.organization_id = arg_dest_organization_id
                and     misi.inventory_item_id = arg_item_id
                and     misi.secondary_inventory = arg_dest_subinventory
		and     misi.organization_id = ood.organization_id
		and     ood.set_of_books_id = fsp.set_of_books_id
		and     ood.operating_unit = fsp.org_id -- bug 4968383
		AND     Nvl(arg_source_organization_id,
			  misi.source_organization_id) = misi.source_organization_id;

            /*--------------------------------------+
             |  Validate the item in the source org |
             +--------------------------------------*/
                if validate_item(arg_item_id, var_source_org, var_source_sub)
                    = TRUE
                then
                    arg_source_organization_id := var_source_org;
                    arg_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    if arg_mode = 'INVENTORY'
                    then
                        RETURN TRUE;
                    end if;
                end if;
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;
        end if;
        /*------------------------------------------------------------+
         |  Then  check the sub level if the mode is Inventory        |
         |  or both                                                   |
         +------------------------------------------------------------*/
        if arg_mode = 'INVENTORY' or arg_mode = 'BOTH'
        then
            BEGIN

                select  msi.source_organization_id,
                        msi.source_subinventory
                into    var_source_org,
                        var_source_sub
                from    mtl_secondary_inventories msi,
                        org_organization_definitions ood,
                        financials_system_parameters fsp
                where   msi.organization_id = arg_dest_organization_id
                and     msi.secondary_inventory_name = arg_dest_subinventory
                and     msi.organization_id = ood.organization_id
		and     ood.set_of_books_id = fsp.set_of_books_id
		and     ood.operating_unit = fsp.org_id -- bug 4968383
		AND     Nvl(arg_source_organization_id,
			  msi.source_organization_id) = msi.source_organization_id;


                /*--------------------------------------+
                 |  Validate the item in the source org |
                 +--------------------------------------*/
                if validate_item(arg_item_id, var_source_org, var_source_sub)
                    = TRUE
                then
                    arg_source_organization_id := var_source_org;
                    arg_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    if arg_mode = 'INVENTORY'
                    then
                        RETURN TRUE;
                    end if;
                end if;
                EXCEPTION
                    WHEN no_data_found THEN
                        NULL;
            END;
        end if;

/* Bug # 1646303 - check the item-org level */

        /*------------------------------------------------------------+
         |  Then  check the item-org level if the mode is Inventory   |
         |  or both                                                   |
         +------------------------------------------------------------*/
        if arg_mode = 'INVENTORY' or arg_mode = 'BOTH'
        then
            BEGIN
        SELECT msi.source_organization_id,
               msi.source_subinventory
                 INTO   var_source_org,
                        var_source_sub
                 FROM   mtl_system_items msi,
                        org_organization_definitions ood,
                        financials_system_parameters fsp
                 WHERE  msi.organization_id = arg_dest_organization_id
                 AND    msi.inventory_item_id  = arg_item_id
                 AND    msi.organization_id = ood.organization_id
                 AND    ood.operating_unit = fsp.org_id -- bug 4968383
                 AND    ood.set_of_books_id = fsp.set_of_books_id;

                /*--------------------------------------+
                 |  Validate the item in the source org |
                 +--------------------------------------*/
                if validate_item(arg_item_id, var_source_org, var_source_sub)
                    = TRUE
                then
                    arg_source_organization_id := var_source_org;
                    arg_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    if arg_mode = 'INVENTORY'
                    then
                        RETURN TRUE;
                    end if;
                end if;
                EXCEPTION
                    WHEN no_data_found THEN
                        NULL;
            END;
        end if;
/* end of item-org check */

/* Bug # 1646303 - check the Org level */

        /*------------------------------------------------------------+
         |  Then  check the Org level if the mode is Inventory        |
         |  or both                                                   |
         +------------------------------------------------------------*/
        if arg_mode = 'INVENTORY' or arg_mode = 'BOTH'
        then
            BEGIN
              SELECT mp.source_organization_id,
                     mp.source_subinventory
              INTO   var_source_org,
                     var_source_sub
              FROM   mtl_parameters mp,
                     org_organization_definitions ood,
                     financials_system_parameters fsp
              WHERE  mp.organization_id  = arg_dest_organization_id
              AND    mp.organization_id = ood.organization_id
              AND    ood.operating_unit = fsp.org_id -- bug 4968383
              AND    ood.set_of_books_id = fsp.set_of_books_id;

            /*--------------------------------------+
             |  Validate the item in the source org |
             +--------------------------------------*/
                if validate_item(arg_item_id, var_source_org, var_source_sub)
                    = TRUE
                then
                    arg_source_organization_id := var_source_org;
                    arg_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    if arg_mode = 'INVENTORY'
                    then
                        RETURN TRUE;
                    end if;
                end if;
            EXCEPTION
                WHEN no_data_found THEN
                    NULL;
            END;
        end if;
/* end of Org check */

        /*-----------------------------------------+
         |  before checking MRP sources get the    |
         |  default assignment set id              |
         +-----------------------------------------*/
        var_set_id :=
            TO_NUMBER(FND_PROFILE.VALUE('MRP_DEFAULT_ASSIGNMENT_SET'));

        if var_set_id is null
        then
            fnd_message.set_name('MRP', 'MRCONC-CANNOT GET PROFILE');
            fnd_message.set_token('PROFILE', 'MRP_DEFAULT_ASSIGNMENT_SET');
            arg_error_message := fnd_message.get;
            return FALSE;
        end if;


        BEGIN
            OPEN sourcing(arg_source_organization_id);

            /*------------------------------------------------+
             |  Loop through all the levels looking for first |
             |  valid source                                  |
             +------------------------------------------------*/
            LOOP FETCH sourcing INTO
                    var_vendor_id,
                    var_site_id,
                    var_source_org,
                    var_alloc_percent,
                    var_rank,
                    var_sr_id;
                EXIT WHEN sourcing%NOTFOUND;

	      var_new_site_code := '-23453' ;
	      if var_vendor_id is not null then
                SELECT  site.vendor_site_code
                INTO    var_new_site_code
                FROM
                        po_vendor_sites_all site,
                        po_vendors ven
                WHERE   NVL(ven.enabled_flag, 'N') = 'Y'
                AND     SYSDATE BETWEEN NVL(ven.start_date_active, SYSDATE -1)
                AND     NVL(ven.end_date_active, sysdate+1)
                AND     SYSDATE < NVL(site.inactive_date, SYSDATE + 1)
                AND     ven.vendor_id = site.vendor_id(+)
                AND     site.vendor_site_id(+)  = var_site_id
                AND     ven.vendor_id  = var_vendor_id ;
              end if;

	      if (var_vendor_id is null or var_new_site_code <> '-23453' or
		  (var_new_site_code is null and var_vendor_id is not null)) then

		 if (found_org = FALSE and
		     (arg_mode = 'INVENTORY' or arg_mode = 'BOTH')
		     and var_source_org is not null)
                then
                    /*--------------------------------------+
                     |  Validate the item in the source org |
                     +--------------------------------------*/
                    if validate_item(arg_item_id, var_source_org) = TRUE
                    then
                        found_org := TRUE;
                        arg_source_organization_id := var_source_org;
                        if (arg_mode = 'INVENTORY')
                        then
                            RETURN TRUE;
                        end if;
                    end if;
                end if;
                if (found_ven = FALSE and
                        (arg_mode = 'VENDOR' or arg_mode = 'BOTH') and
                        var_vendor_id is not null)
                then
                    found_ven := TRUE;
                    arg_vendor_id := var_vendor_id;
                    arg_vendor_site_code := var_new_site_code;
                    if (arg_mode = 'VENDOR')
                    then
                        RETURN TRUE;
                    end if;
                end if;
                if (found_org = TRUE and found_ven = TRUE)
                then
                    return TRUE;
                end if;
              end if;
            END LOOP;
            if (((arg_mode = 'INVENTORY' or arg_mode = 'BOTH') and
                    found_org = FALSE) or
                ((arg_mode = 'VENDOR' or arg_mode = 'BOTH') and
                    found_ven = FALSE))
            then
                fnd_message.set_name('MRP', 'GEN-CANNOT SELECT');
                fnd_message.set_token('SELECT', 'EC_SOURCE', TRUE);
                fnd_message.set_token('ROUTINE', 'MRP_SOURCING', FALSE);
                arg_error_message := fnd_message.get || 'JUNK12';
                RETURN FALSE;
            end if;
            EXCEPTION
                WHEN no_data_found THEN
                    fnd_message.set_name('MRP', 'GEN-NO ROWS SELECTED');
                    fnd_message.set_token('TABLE', 'mrp_sources_v');
                    arg_error_message := fnd_message.get;
                    RETURN FALSE;
        END;
END mrp_sourcing;

FUNCTION    mrp_sourcing(
                arg_mode                    IN          VARCHAR2,
                arg_item_id                 IN          NUMBER,
                arg_commodity_id            IN          NUMBER,
                arg_dest_organization_id    IN          NUMBER,
                arg_dest_subinventory       IN          VARCHAR2,
                arg_autosource_date         IN          DATE,
                arg_vendor_id               OUT  NOCOPY          NUMBER,
                arg_vendor_site_id          OUT  NOCOPY          NUMBER,
                arg_source_organization_id  IN OUT  NOCOPY       NUMBER,
                arg_source_subinventory     IN OUT  NOCOPY       VARCHAR2,
                arg_sourcing_rule_id        OUT  NOCOPY          NUMBER,
                arg_error_message           OUT  NOCOPY          VARCHAR2)
            RETURN BOOLEAN IS
var_vendor_site_code po_vendor_sites_all.vendor_site_code%TYPE;
BEGIN
          if( mrp_sourcing(
                arg_mode                    => arg_mode,
                arg_item_id                 => arg_item_id,
                arg_commodity_id            => arg_commodity_id,
                arg_dest_organization_id    => arg_dest_organization_id,
                arg_dest_subinventory       => arg_dest_subinventory,
                arg_autosource_date         => arg_autosource_date,
                arg_vendor_id               => arg_vendor_id,
                arg_vendor_site_code        => var_vendor_site_code,
                arg_source_organization_id  => arg_source_organization_id,
                arg_source_subinventory     => arg_source_subinventory,
                arg_sourcing_rule_id        => arg_sourcing_rule_id,
                arg_error_message           => arg_error_message))
           THEN
             IF var_vendor_site_code IS NOT NULL THEN
                select  dest_site.vendor_site_id
                into    arg_vendor_site_id
                FROM    org_organization_definitions  oog,
                        po_vendor_sites_all dest_site,
                        po_vendors ven
                WHERE   NVL(ven.enabled_flag, 'N') = 'Y'
                AND     sysdate BETWEEN NVL(ven.start_date_active, sysdate -1)
                AND     NVL(ven.end_date_active, sysdate+1)
                AND     ven.vendor_id  = arg_vendor_id
                AND     dest_site.vendor_id(+) = ven.vendor_id
                AND     dest_site.vendor_site_code(+) = var_vendor_site_code
                AND     nvl(dest_site.org_id,nvl(oog.operating_unit,-1)) =
                                                      nvl(oog.operating_unit,-1)
                AND     oog.organization_id = arg_dest_organization_id;
              END IF;

              return(TRUE);
            else
                arg_vendor_id := NULL;
                return(FALSE);
            end if;

EXCEPTION
                WHEN no_data_found THEN
                    arg_vendor_id := NULL;
                    fnd_message.set_name('MRP', 'GEN-NO ROWS SELECTED');
                    fnd_message.set_token('TABLE', 'mrp_sources_v');
                    arg_error_message := fnd_message.get;
                    RETURN FALSE;
END mrp_sourcing;

/* 	This function checks all sourcing rules to see if
 *	any of them uses the item-supplier combination.
 *	It returns 1 if there are no such sourcing rules
 *	else returns 0
 */

FUNCTION mrp_sourcing_rule_exists
  (
  arg_item_id          IN   NUMBER,
  arg_category_id      IN   NUMBER,
  arg_supplier_id      IN   NUMBER,
  arg_supplier_site_id IN   NUMBER,
  arg_message          OUT  NOCOPY   VARCHAR2
  ) RETURN NUMBER IS

  /* Only one among arg_item_id, arg_category_id will be NOT NULL
   * and one of them will be not null.
   */

  CURSOR sr IS
  SELECT distinct misl.sourcing_rule_name, ml.meaning
  FROM
  mfg_lookups ml,
  mrp_item_sourcing_levels_v misl
  WHERE misl.inventory_item_id = NVL(arg_item_id, misl.inventory_item_id)
  and NVL(misl.category_id,-1) = NVL(arg_category_id, NVL(misl.category_id, -1))
  and misl.vendor_id = arg_supplier_id
  and NVL(misl.vendor_site_id,-1) = NVL(arg_supplier_site_id,-1)
  and sysdate < NVL(misl.disable_date, sysdate + 1)
  and ml.lookup_type = 'MRP_ASSIGNMENT_TYPE'
  and ml.lookup_code = misl.assignment_type;

  x_sourcing_rule_name VARCHAR2(50);
  x_assignment_type    VARCHAR2(80);
  counter              NUMBER;
BEGIN

  OPEN sr;
  counter := 1;

  FND_MESSAGE.SET_NAME('MRP', 'MRP_SUPPLIER_IN_SOURCING_1');
  arg_message := FND_MESSAGE.GET;
  arg_message := arg_message||fnd_global.newline;

  LOOP
     FETCH sr into x_sourcing_rule_name, x_assignment_type;
     EXIT WHEN sr%NOTFOUND;

     IF counter <= 10 THEN
	arg_message := arg_message||' '||x_sourcing_rule_name||' '||x_assignment_type||fnd_global.newline;
     END IF;
     counter := counter + 1;
  END LOOP;

  CLOSE sr;

  IF counter = 1 THEN
	return 1;	-- There are no sourcing_rules found
  END IF;

  FND_MESSAGE.SET_NAME('MRP', 'MRP_SUPPLIER_IN_SOURCING_2');
  fnd_message.set_token('COUNT', counter);
  arg_message := arg_message||' '||FND_MESSAGE.GET;

  return 0;
END mrp_sourcing_rule_exists;


function  mrp_get_sourcing_history(
				   arg_source_org              IN          NUMBER,
				   arg_vendor_id               IN          NUMBER,
				   arg_vendor_site_id          IN          NUMBER,
				   arg_item_id                 IN          NUMBER,
				   arg_org_id                  IN          NUMBER,
				   arg_sourcing_rule_id        IN          NUMBER,
				   arg_start_date              IN OUT  NOCOPY       NUMBER,
				   arg_end_date                IN          NUMBER,
				   arg_err_mesg                OUT  NOCOPY          VARCHAR2)
  return number is
     PRAGMA AUTONOMOUS_TRANSACTION;
     greater_than_plan_date number;
     x_last_calculated_date date;
     x_total_alloc_qty      NUMBER :=0 ;
     x_historical_allocation number := 0;
     arg_end_date1 NUMBER;
     arg_vendor_site_id1 NUMBER;
begin

   arg_err_mesg := NULL;

   select to_date(arg_start_date,'J') - sysdate
     into greater_than_plan_date
     from dual;

   if greater_than_plan_date > 0 then
      return 0;
      -- there will be no history for any sourcing rule with start_date greater than sysdate.
   end if;

   if arg_end_date = NULL_VALUE then
       arg_end_date1 := to_number(to_char(sysdate,'j'));
   else
       arg_end_date1 := arg_end_date;
   end if;

   if arg_vendor_site_id = NULL_VALUE then
       arg_vendor_site_id1 := NULL;
   else
       arg_vendor_site_id1 := arg_vendor_site_id;
   end if;

   if cutoff_history_date > arg_start_date then
            arg_start_date := cutoff_history_date;
   end if;


/** Bug 1921263  : The total historical allocation will be computed everytime
                   (not just the delta as was being done earlier) the plan runs.
                    The historical allocations for items purchased from vendors
                    and internally transferred items will be calculated by PO
                    functions.
***/

   IF (arg_source_org = arg_org_id) THEN

    select NVL(sum(PRIMARY_QUANTITY),0)
	into  x_total_alloc_qty
	from mtl_material_transactions
	where
	inventory_item_id = arg_item_id
	and ORGANIZATION_ID = arg_org_id
	and transaction_action_id in (30, 31, 32 )
	/* WIP scrap, Assembly compl , Assy Return qty is -ve */
	and transaction_date between to_date(arg_start_date,'J')
	and decode(arg_end_date,NULL_VALUE,transaction_date, to_date(arg_end_date,'J'));

      if x_total_alloc_qty < 0 then
	          x_total_alloc_qty := 0;  -- since we take into account returns also.
      end if;

      -- if there is no record then calculate history from start_date of sourcing rule
      -- else calculate from the next day after the date for which it was calculated last time

    ELSIF (arg_source_org <> arg_org_id AND arg_source_org <> NULL_VALUE ) THEN
      -- Transfers


         RCV_GET_DELIVERED_QTY.GET_INTERNAL_DETAILS(arg_source_org, arg_org_id, arg_item_id,
                to_date(arg_start_date,'J'), to_date(arg_end_date1,'J'), x_total_alloc_qty);

    ELSIF arg_vendor_id IS NOT NULL THEN
      -- Note the usage of arg_org_id, we use it only in the case of
      -- transfers and NOT buy from vendor, since we will support only
      -- global ASL. we need to fix this if ever we decide to support
      -- local ASL.


       RCV_GET_DELIVERED_QTY.GET_TRANSACTION_DETAILS(arg_vendor_id, arg_vendor_site_id1, arg_item_id,
                to_date(arg_start_date,'J'), to_date(arg_end_date1, 'J'), x_total_alloc_qty);

   END IF;

      -- delete the previous record for the previous date range in the Sourcing rule.
      -- Here only the previous record is deleted. If a SR is changed for an item, then in the
      -- form we must clean up unnecassary history

    delete from mrp_sourcing_history msh
	where
	msh.inventory_item_id = arg_item_id
	and msh.organization_id = arg_org_id
	and msh.sourcing_rule_id = arg_sourcing_rule_id
	and NVL(msh.source_org_id,-1) = decode(arg_source_org, NULL_VALUE, NVL(msh.source_org_id,-1), arg_source_org)
	and NVL(msh.vendor_id,-1) = decode(arg_vendor_id, NULL_VALUE, NVL(msh.vendor_id,-1), arg_vendor_id)
	and NVL(msh.vendor_site_id,-1) = decode(arg_vendor_site_id, NULL_VALUE, NVL(msh.vendor_site_id,-1), arg_vendor_site_id);

      -- insert a new record
      -- a record is inserted even if the quantity is 0 since we would be better off
      -- next  time if we don't search for those transaction dates.

      -- sourcing_rule_id is there in the table so that if we change the SR, then the history
      -- is recalculated. It is ok if the assignment changes, since history is related to the SR
      -- only. that is y assignment set is not a column.

      insert into mrp_sourcing_history
	(
	 inventory_item_id,
	 organization_id,
	 sourcing_rule_id,
	 source_org_id,
	 vendor_id,
	 vendor_site_id,
	 historical_allocation,
	 last_calculated_date,
	 last_updated_by,
	 last_update_date,
	 creation_date,
	 created_by,
	 last_update_login,
	 request_id,
	 program_application_id,
	 program_id,
	 program_update_date
	 )
	values (
		arg_item_id,
		arg_org_id,
		arg_sourcing_rule_id,
		decode(arg_source_org, NULL_VALUE, NULL, arg_source_org),
		decode(arg_vendor_id, NULL_VALUE, NULL, arg_vendor_id),
		decode(arg_vendor_site_id,NULL_VALUE, NULL, arg_vendor_site_id),
		x_total_alloc_qty,
		sysdate,
		1,
		sysdate,
		sysdate,
		1,
		NULL,
		NULL,
		NULL,
		NULL,
		NULL
		);

   commit;  -- autonomous transaction
   return(x_total_alloc_qty);
exception
   when others then
      arg_err_mesg := substr(sqlerrm,1,100);
      rollback;
      return(0);
end mrp_get_sourcing_history;



FUNCTION    mrp_po_historical_alloc
  (
   arg_source_org              IN          NUMBER,
   arg_vendor_id               IN          NUMBER,
   arg_vendor_site_id          IN          NUMBER,
   arg_item_id                 IN          NUMBER,
   arg_org_id                  IN          NUMBER,
   arg_start_date              IN          DATE,
   arg_end_date                IN          DATE)
  RETURN NUMBER
  IS

     x_total_alloc_qty   NUMBER := 0;
     x_job_alloc_qty     NUMBER := 0;
     x_fs_alloc_qty      NUMBER := 0;
     x_rep_alloc_qty     NUMBER := 0;
BEGIN
   -- This means this is a make in the arg_org_id org

   IF (arg_source_org = arg_org_id) THEN
      SELECT NVL(SUM(NVL(jobs.quantity_completed,0)),0)
        INTO   x_job_alloc_qty
        FROM   wip_discrete_jobs jobs
        WHERE  jobs.primary_item_id = arg_item_id
        AND    jobs.organization_id = arg_org_id
        AND    DECODE(mps_consume_profile_value,
                      1, jobs.mps_scheduled_completion_date,
                      jobs.scheduled_completion_date) between
        arg_start_date and NVL(arg_end_date,
                               Decode(mps_consume_profile_value,
                                      1, jobs.mps_scheduled_completion_date,
                                      jobs.scheduled_completion_date)
                               +1);

      SELECT
        Nvl(SUM(NVL(fs.quantity_completed,0)),0)
        INTO   x_fs_alloc_qty
        FROM   wip_flow_schedules fs
        WHERE  fs.primary_item_id = arg_item_id
        AND    fs.organization_id = arg_org_id
        AND    DECODE(mps_consume_profile_value,
                      1, fs.mps_scheduled_completion_date,
                      fs.scheduled_completion_date) between
        arg_start_date and NVL(arg_end_date,
                               DECODE(mps_consume_profile_value,
                                      1, fs.mps_scheduled_completion_date,
                                      fs.scheduled_completion_date)+1);

      SELECT
        Nvl(SUM(NVL(rep.daily_production_rate * rep.processing_work_days,0)),0)
        INTO   x_rep_alloc_qty
        FROM wip_repetitive_schedules rep,
        wip_repetitive_items wri,
        wip_entities we
        WHERE
        we.organization_id = arg_org_id
        AND    wri.wip_entity_id = we.wip_entity_id
        AND    we.primary_item_id = arg_item_id
        AND    wri.organization_id = we.organization_id
        AND    rep.wip_entity_id = we.wip_entity_id
        AND    rep.organization_id = wri.organization_id
        AND    rep.line_id = wri.line_id
        AND    rep.last_unit_completion_date between
        arg_start_date and NVL(arg_end_date,rep.last_unit_completion_date+1);

      x_total_alloc_qty := x_job_alloc_qty + x_fs_alloc_qty + x_rep_alloc_qty;
  ELSIF (arg_source_org <> arg_org_id AND arg_source_org IS NOT NULL ) THEN
      SELECT NVL(SUM(
                     INV_CONVERT.inv_um_convert
                     (
                      arg_item_id,
                      6,
                      Nvl(rct.quantity,0),
                      NULL,
                      NULL,
                      rsl.unit_of_measure,
                      rsl.primary_unit_of_measure
                      )),0)
        INTO x_total_alloc_qty
        FROM rcv_shipment_lines rsl,
        rcv_transactions rct
        WHERE rct.shipment_line_id = rsl.shipment_line_id
        AND   rct.transaction_type = 'DELIVER'
        AND   rsl.from_organization_id = arg_source_org
        AND   rsl.to_organization_id = arg_org_id
        AND   rsl.item_id = arg_item_id
        AND   rct.transaction_date BETWEEN
              arg_start_date AND NVL(arg_end_date,rct.transaction_date +1);

  ELSIF arg_vendor_id IS NOT NULL THEN
  -- Note the usage of arg_org_id, we use it only in the case of
  -- transfers and NOT buy from vendor, since we will support only
  -- global ASL. we need to fix this if ever we decide to support
  -- local ASL.
      SELECT /*+ use_nl(rct,rsl, poh,pol)
                 INDEX(rct rcv_transactions_n15)
                 INDEX(rsl rcv_shipment_lines_u1)
                 INDEX(poh po_headers_u1)
                 INDEX(rol po_lines_u1) */
       NVL(SUM(
                     INV_CONVERT.inv_um_convert
                     (
                      arg_item_id,
                      6,
                      Nvl(rct.quantity,0),
                      NULL,
                      NULL,
                      rsl.unit_of_measure,
                      rsl.primary_unit_of_measure
                      )),0)
        INTO x_total_alloc_qty
        FROM po_lines_all pol,
        po_headers_all poh,
        rcv_shipment_lines rsl,
        rcv_transactions rct
        WHERE rct.shipment_line_id = rsl.shipment_line_id
        AND   rct.transaction_type = 'DELIVER'
        AND   rsl.po_header_id = poh.po_header_id
        AND   rsl.po_line_id = pol.po_line_id
        AND   poh.vendor_id = arg_vendor_id
        AND   NVL(poh.vendor_site_id,-99) = NVL(arg_vendor_site_id,-99)
        AND   pol.item_id = arg_item_id
        AND   rct.transaction_date between arg_start_date AND
                NVL(arg_end_date,rct.transaction_date +1);
  END IF;
  return(x_total_alloc_qty);
EXCEPTION
  WHEN OTHERS THEN
    return(0);
END mrp_po_historical_alloc;

END MRP_SOURCING_API_PK; -- package

/
