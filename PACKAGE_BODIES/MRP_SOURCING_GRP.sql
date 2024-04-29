--------------------------------------------------------
--  DDL for Package Body MRP_SOURCING_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MRP_SOURCING_GRP" AS
    /* $Header: MRPGSRCB.pls 120.1 2006/03/08 04:52:38 davashia noship $ */

g_pkg_name   CONSTANT VARCHAR2 (30) := 'MRP_Sourcing_GRP';

FUNCTION    validate_item(
                arg_item_id                 IN          NUMBER,
                arg_org_id                  IN          NUMBER,
                arg_sub_inv                 IN          VARCHAR2 DEFAULT NULL)
            RETURN BOOLEAN IS

            var_stk         VARCHAR2(10);
            var_restrict    NUMBER;
BEGIN

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

PROCEDURE    Get_Source(
                p_api_version              IN       NUMBER,
                x_return_status            OUT   NOCOPY   VARCHAR2,
                p_mode                    IN          VARCHAR2,
                p_item_id                 IN          NUMBER,
                p_commodity_id            IN          NUMBER,
                p_dest_organization_id    IN          NUMBER,
                p_dest_subinventory       IN          VARCHAR2,
                p_autosource_date         IN          DATE,
                x_vendor_id               OUT    NOCOPY     NUMBER,
                x_vendor_site_code          OUT    NOCOPY     VARCHAR2,
                x_source_organization_id  IN OUT  NOCOPY    NUMBER,
                x_source_subinventory     IN OUT  NOCOPY    VARCHAR2,
                x_sourcing_rule_id        OUT    NOCOPY     NUMBER,
                x_error_message           OUT    NOCOPY     VARCHAR2)
IS

l_api_name			CONSTANT VARCHAR2(30)	:= 'Get_Source';
l_api_version		CONSTANT NUMBER 		:= 1.0;

            var_set_id          NUMBER;
            var_vendor_id       NUMBER;
            var_site_id         NUMBER;
	        var_new_site_code    VARCHAR2(30);
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
            AND     misl.inventory_item_id = p_item_id
            AND     misl.organization_id = p_dest_organization_id
            AND     misl.assignment_set_id = var_set_id
            AND     p_autosource_date between misl.effective_date AND
                    NVL(disable_date, to_date(2634525, 'J'))
            AND     PO_ASL_SV.check_asl_action('2_SOURCING',
                    misl.vendor_id, misl.vendor_site_id, p_item_id, -1
		      , p_dest_organization_id ) <> 0
	    AND  nvl(nvl(p_source_organization_id,
			  	     misl.source_organization_id), -23453)
                 	= nvl(misl.source_organization_id, -23453)
            ORDER BY misl.sourcing_level ASC,
                    allocation_percent DESC, NVL(misl.rank, 9999) ASC;
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Get_Source_GRP;

      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          g_pkg_name
                                         )
      THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      --  Initialize API return status to success
      x_return_status := fnd_api.g_ret_sts_success;

   IF x_source_organization_id IS NOT NULL AND
	  x_source_subinventory IS NOT NULL THEN
       x_return_status := fnd_api.g_ret_sts_success;
	   RETURN;
	END IF;


        found_org := FALSE;
        found_ven := FALSE;
        x_error_message := NULL;
        x_vendor_id := NULL;
        x_vendor_site_code := NULL;

        /*------------------------------------------------------------+
         |  First check the item-sub level if the mode is Inventory   |
         |  OR both                                                   |
         +------------------------------------------------------------*/
        IF p_mode = 'INVENTORY' OR p_mode = 'BOTH'
        THEN
            BEGIN

                SELECT  misi.source_organization_id,
                        misi.source_subinventory
                INTO    var_source_org,
                        var_source_sub
                FROM    mtl_item_sub_inventories misi,
                        org_organization_definitions ood,
                        financials_system_parameters fsp
                WHERE   misi.organization_id = p_dest_organization_id
                AND     misi.inventory_item_id = p_item_id
                AND     misi.secondary_inventory = p_dest_subinventory
		        AND     misi.organization_id = ood.organization_id
		        AND     ood.set_of_books_id = fsp.set_of_books_id
		        AND     ood.operating_unit = fsp.org_id -- bug 4968383
		        AND     NVL(x_source_organization_id,
			                  misi.source_organization_id) = misi.source_organization_id;

            /*--------------------------------------+
             |  Validate the item in the source org |
             +--------------------------------------*/
                IF validate_item(p_item_id, var_source_org, var_source_sub)
                    = TRUE
                THEN
                    x_source_organization_id := var_source_org;
                    x_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    IF p_mode = 'INVENTORY'
                    THEN
                        x_return_status := fnd_api.g_ret_sts_success;
                        RETURN;
                    END IF;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    NULL;
            END;
        END IF;
        /*------------------------------------------------------------+
         |  THEN  check the sub level if the mode is Inventory        |
         |  OR both                                                   |
         +------------------------------------------------------------*/
        IF p_mode = 'INVENTORY' OR p_mode = 'BOTH'
        THEN
            BEGIN

                SELECT  msi.source_organization_id,
                        msi.source_subinventory
                INTO    var_source_org,
                        var_source_sub
                FROM    mtl_secondary_inventories msi,
                        org_organization_definitions ood,
                        financials_system_parameters fsp
                WHERE   msi.organization_id = p_dest_organization_id
                AND     msi.secondary_inventory_name = p_dest_subinventory
                AND     msi.organization_id = ood.organization_id
		        AND     ood.set_of_books_id = fsp.set_of_books_id
		        AND     ood.operating_unit = fsp.org_id -- bug 4968383
		        AND     NVL(x_source_organization_id,
			             msi.source_organization_id) = msi.source_organization_id;


                /*--------------------------------------+
                 |  Validate the item in the source org |
                 +--------------------------------------*/
                IF validate_item(p_item_id, var_source_org, var_source_sub)
                    = TRUE
                THEN
                    x_source_organization_id := var_source_org;
                    x_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    IF p_mode = 'INVENTORY'
                    THEN
                        x_return_status := fnd_api.g_ret_sts_success;
                        RETURN;
                    END IF;
                END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
            END;
        END IF;


        /*------------------------------------------------------------+
         |  THEN  check the item-org level if the mode is Inventory   |
         |  OR both                                                   |
         +------------------------------------------------------------*/
        IF p_mode = 'INVENTORY' OR p_mode = 'BOTH'
        THEN
            BEGIN
        SELECT msi.source_organization_id,
               msi.source_subinventory
                 INTO   var_source_org,
                        var_source_sub
                 FROM   mtl_system_items msi,
                        org_organization_definitions ood,
                        financials_system_parameters fsp
                 WHERE  msi.organization_id = p_dest_organization_id
                 AND    msi.inventory_item_id  = p_item_id
                 AND    msi.organization_id = ood.organization_id
                 AND    ood.operating_unit = fsp.org_id -- bug 4968383
                 AND    ood.set_of_books_id = fsp.set_of_books_id;

                /*--------------------------------------+
                 |  Validate the item in the source org |
                 +--------------------------------------*/
                IF validate_item(p_item_id, var_source_org, var_source_sub)
                    = TRUE
                THEN
                    x_source_organization_id := var_source_org;
                    x_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    IF p_mode = 'INVENTORY'
                    THEN
                        x_return_status := fnd_api.g_ret_sts_success;
                        RETURN;
                    END IF;
                END IF;
                EXCEPTION
                    WHEN NO_DATA_FOUND THEN
                        NULL;
            END;
        END IF;
/* end of item-org check */

        /*------------------------------------------------------------+
         |  THEN  check the Org level if the mode is Inventory        |
         |  OR both                                                   |
         +------------------------------------------------------------*/
        IF p_mode = 'INVENTORY' OR p_mode = 'BOTH'
        THEN
            BEGIN
              SELECT mp.source_organization_id,
                     mp.source_subinventory
              INTO   var_source_org,
                     var_source_sub
              FROM   mtl_parameters mp,
                     org_organization_definitions ood,
                     financials_system_parameters fsp
              WHERE  mp.organization_id  = p_dest_organization_id
              AND    mp.organization_id = ood.organization_id
              AND    ood.operating_unit = fsp.org_id -- bug 4968383
              AND    ood.set_of_books_id = fsp.set_of_books_id;

            /*--------------------------------------+
             |  Validate the item in the source org |
             +--------------------------------------*/
                IF validate_item(p_item_id, var_source_org, var_source_sub)
                    = TRUE
                THEN
                    x_source_organization_id := var_source_org;
                    x_source_subinventory := var_source_sub;
                    found_org := TRUE;
                    /*---------------------------------------+
                     |  If mode is inventory you are done    |
                     +---------------------------------------*/
                    IF p_mode = 'INVENTORY'
                    THEN
                        x_return_status := fnd_api.g_ret_sts_success;
                        RETURN;
                    END IF;
                END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
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

        IF var_set_id IS NULL
        THEN
            x_return_status := FND_API.G_RET_STS_ERROR ;
            fnd_message.set_name('MRP', 'MRCONC-CANNOT GET PROFILE');
            fnd_message.set_token('PROFILE', 'MRP_DEFAULT_ASSIGNMENT_SET');
            RETURN;
        END IF;


        BEGIN
            OPEN sourcing(x_source_organization_id);

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

	      IF var_vendor_id IS NOT NULL THEN
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
           END IF;

	      IF (var_vendor_id IS NULL OR var_new_site_code <> '-23453' OR
		  (var_new_site_code IS NULL AND var_vendor_id IS NOT NULL)) THEN

		 IF (found_org = FALSE AND
		     (p_mode = 'INVENTORY' OR p_mode = 'BOTH')
		     AND var_source_org IS NOT NULL)
                THEN
                    /*--------------------------------------+
                     |  Validate the item in the source org |
                     +--------------------------------------*/
                    IF validate_item(p_item_id, var_source_org) = TRUE
                    THEN
                        found_org := TRUE;
                        x_source_organization_id := var_source_org;
                        IF (p_mode = 'INVENTORY')
                        THEN
                            x_return_status := fnd_api.g_ret_sts_success;
                            RETURN;
                        END IF;
                    END IF;
                END IF;
                IF (found_ven = FALSE AND
                        (p_mode = 'VENDOR' OR p_mode = 'BOTH')AND
                        var_vendor_id IS NOT NULL)
                THEN
                    found_ven := TRUE;
                    x_vendor_id := var_vendor_id;
                    x_vendor_site_code := var_new_site_code;
                    if (p_mode = 'VENDOR')
                    THEN
                        x_return_status := fnd_api.g_ret_sts_success;
                        RETURN;
                    END IF;
                END IF;
                IF (found_org = TRUE AND found_ven = TRUE)
                THEN
                    x_return_status := fnd_api.g_ret_sts_success;
                    RETURN;
                END IF;
              END IF;
            END LOOP;
            if (((p_mode = 'INVENTORY' OR p_mode = 'BOTH')AND
                    found_org = FALSE) OR
                ((p_mode = 'VENDOR' OR p_mode = 'BOTH')AND
                    found_ven = FALSE))
            THEN
                x_return_status := FND_API.G_RET_STS_ERROR ;
                fnd_message.set_name('MRP', 'GEN-CANNOT SELECT');
                fnd_message.set_token('SELECT', 'EC_SOURCE', TRUE);
                fnd_message.set_token('ROUTINE', 'MRP_SOURCING', FALSE);
                RETURN;
            END IF;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    x_return_status := FND_API.G_RET_STS_ERROR ;
                    fnd_message.set_name('MRP', 'GEN-NO ROWS SELECTED');
                    fnd_message.set_token('TABLE', 'mrp_sources_v');
                    RETURN;
        END;
END Get_Source;

END MRP_Sourcing_GRP;

/
