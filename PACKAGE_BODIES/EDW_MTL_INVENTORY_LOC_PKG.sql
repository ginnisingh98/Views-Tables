--------------------------------------------------------
--  DDL for Package Body EDW_MTL_INVENTORY_LOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MTL_INVENTORY_LOC_PKG" AS
/* $Header: OPIILFKB.pls 120.1 2005/06/08 05:31:38 appldev  $  */

	FUNCTION get_locator_fk (p_inventory_location_id IN NUMBER, p_organization_id IN NUMBER, p_subinventory_code IN VARCHAR2) RETURN VARCHAR2 IS
		v_locator_fk	VARCHAR2(240) := 'NA_EDW';
                v_instance_code edw_local_instance.instance_code%TYPE;
                v_organization_code mtl_parameters.organization_code%TYPE;
	BEGIN

                SELECT instance_code INTO v_instance_code
                FROM edw_local_instance;

                IF p_organization_id IS NULL THEN
                   RETURN 'NA_EDW';
                ELSE
                   SELECT mp.organization_code INTO v_organization_code
                   FROM   mtl_parameters mp
                   WHERE mp.organization_id = p_organization_id;
		   IF (p_inventory_location_id IS NOT null and p_inventory_location_id<>0) THEN
		       RETURN(p_inventory_location_id ||'-'||v_organization_code||'-'||v_instance_code);
		   ELSIF  (p_subinventory_code IS NOT NULL) THEN
                       RETURN(p_subinventory_code||'-'||v_organization_code||'-'||v_instance_code||'-SUBI');
	           ELSE
                       RETURN(v_organization_code||'-'||v_instance_code||'-PLNT');
                   END IF;
                END IF;

         EXCEPTION
            WHEN no_data_found THEN
		RETURN('NA_EDW');
	    WHEN others THEN
		RETURN('Invalid '||to_char(p_inventory_location_id));
	END get_locator_fk;

	FUNCTION get_locator_fk (p_inventory_location_id IN NUMBER,
                               p_organization_id IN NUMBER,
                               p_subinventory_code IN VARCHAR2,
                               p_whse_loct_ctl IN NUMBER,
                               P_item_loct_ctl IN NUMBER,
                               p_location_code IN VARCHAR2,
                               p_organization_code IN VARCHAR2,
                               p_instance_code  IN VARCHAR2) RETURN VARCHAR2 IS
        v_locator_fk	VARCHAR2(240) := 'NA_EDW';
      BEGIN
        IF p_organization_id IS NULL THEN
           RETURN 'NA_EDW';
        ELSIF p_location_code IS NULL THEN
          IF  (p_subinventory_code IS NOT NULL) THEN
              RETURN(p_subinventory_code||'-'||p_organization_code||'-'||p_instance_code||'-SUBI');
	    ELSE
              RETURN(p_organization_code||'-'||p_instance_code||'-PLNT');
          END IF;
        ELSIF p_location_code IS NOT NULL THEN
          IF    P_item_loct_ctl * P_whse_loct_ctl  =  1
          THEN
            RETURN(p_inventory_location_id ||'-'||p_organization_code||'-'||p_instance_code);
          ELSIF P_item_loct_ctl * P_whse_loct_ctl  =  0
          THEN
            RETURN(p_location_code ||'-'||p_organization_code||'-OPMNL-'||p_instance_code);
          ELSE
            RETURN(p_location_code ||'-'||p_organization_code||'-OPMNV-'||p_instance_code);
          END IF;
        ELSE
           RETURN 'NA_EDW';
        END IF;
	END get_locator_fk;

	FUNCTION get_stock_room_fk (p_secondary_inventory_name IN VARCHAR2,  p_organization_id IN NUMBER) RETURN VARCHAR2 IS
	   v_instance_code edw_local_instance.instance_code%TYPE;
	   v_organization_code mtl_parameters.organization_code%TYPE;
	BEGIN

	   SELECT instance_code INTO v_instance_code
	     FROM edw_local_instance;

	   IF p_organization_id IS NULL THEN
	      RETURN 'NA_EDW';
	    ELSE
	      SELECT mp.organization_code INTO v_organization_code
		FROM   mtl_parameters mp
		WHERE mp.organization_id = p_organization_id;

	      IF  (p_secondary_inventory_name IS NOT NULL) THEN
                       RETURN(p_secondary_inventory_name ||'-'||v_organization_code||'-'||v_instance_code||'-SUBI');
	       ELSE
		 RETURN(v_organization_code||'-'||v_instance_code||'-PLNT');
	      END IF;
	   END IF;

	EXCEPTION WHEN others THEN
	   RETURN('Invalid '||p_secondary_inventory_name);
	END get_stock_room_fk;
END;

/
