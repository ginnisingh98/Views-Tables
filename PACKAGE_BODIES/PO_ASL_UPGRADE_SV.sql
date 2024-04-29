--------------------------------------------------------
--  DDL for Package Body PO_ASL_UPGRADE_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_ASL_UPGRADE_SV" AS
/* $Header: POXA1LUB.pls 115.5 2003/03/27 21:18:11 draising ship $*/

/*===========================================================================

  PROCEDURE NAME:       upgrade_autosource_rules

===========================================================================*/

PROCEDURE upgrade_autosource_rules(
	x_asl_status_id			NUMBER,
	x_usr_upgrade_docs		VARCHAR2
) IS
	x_progress   			VARCHAR2(30) := '';
	x_dummy_count			NUMBER;
	x_autosource_rule_id		NUMBER;
	x_autosource_rule_name  po_autosource_rules.autosource_rule_name%type := '';
	x_item_id			NUMBER;
	x_start_date			DATE;
	x_end_date			DATE;
	x_last_update_date		DATE;
	x_last_update_login		NUMBER;
	x_last_updated_by		NUMBER;
	x_created_by			NUMBER;
	x_creation_date			DATE;
	x_sourcing_rule_id		NUMBER;
	x_assignment_id			NUMBER;
	x_assignment_set_id		NUMBER;
	x_sr_receipt_id			NUMBER;
	x_organization_id		NUMBER;
	x_first_rule			VARCHAR2(1) := '';
	x_upgrade_docs			VARCHAR2(1) := '';
        X_ATTRIBUTE_CATEGORY   po_autosource_vendors.attribute_category%type;
        x_attribute1           po_autosource_vendors.attribute1%type;
        x_attribute2           po_autosource_vendors.attribute2%type;
        x_attribute3           po_autosource_vendors.attribute3%type;
        x_attribute4           po_autosource_vendors.attribute4%type;
        x_attribute5           po_autosource_vendors.attribute5%type;
        x_attribute6           po_autosource_vendors.attribute6%type;
        x_attribute7           po_autosource_vendors.attribute7%type;
        x_attribute8           po_autosource_vendors.attribute8%type;
        x_attribute9           po_autosource_vendors.attribute9%type;
        x_attribute10           po_autosource_vendors.attribute10%type;
        x_attribute11           po_autosource_vendors.attribute11%type;
        x_attribute12           po_autosource_vendors.attribute12%type;
        x_attribute13           po_autosource_vendors.attribute13%type;
        x_attribute14           po_autosource_vendors.attribute14%type;
        x_attribute15           po_autosource_vendors.attribute15%type;

	CURSOR C2 is
	    SELECT DISTINCT ITEM_ID
	    FROM   PO_AUTOSOURCE_RULES;

        CURSOR C1 is
	    SELECT  AUTOSOURCE_RULE_ID,
		    AUTOSOURCE_RULE_NAME,
		    START_DATE,
		    END_DATE,
		    LAST_UPDATE_DATE,
		    LAST_UPDATE_LOGIN,
		    LAST_UPDATED_BY,
		    CREATION_DATE,
		    CREATED_BY,
                    ATTRIBUTE_CATEGORY,
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
	    FROM    PO_AUTOSOURCE_RULES
	    WHERE   ITEM_ID = x_item_id
	    ORDER BY start_date;

 	CURSOR I1 is
	    SELECT  MRP_SOURCING_RULES_S.NEXTVAL
	    FROM    SYS.DUAL;

	CURSOR I2 is
	    SELECT  MRP_SR_RECEIPT_ORG_S.NEXTVAL
	    FROM    SYS.DUAL;

   	CURSOR I3 is
	    SELECT  MRP_SR_ASSIGNMENTS_S.NEXTVAL
	    FROM    SYS.DUAL;

BEGIN

  -- Make sure that user provides a valid value for the input x_usr_upgrade_docs

  IF x_usr_upgrade_docs NOT IN ('NONE', 'CURRENT', 'FUTURE') THEN

	fnd_file.put_line(fnd_file.log,x_usr_upgrade_docs||' is not a valid parameter.');
	return;

  END IF;


  -- The profile option MRP_DEFAULT_ASSIGNMENT_SET specifies the default
  -- assignment set used for PO.  If user has not set this profile option
  -- then terminate the upgrade.

  x_progress := 'SV0-040';
  fnd_profile.get('MRP_DEFAULT_ASSIGNMENT_SET', x_assignment_set_id);

  If x_assignment_set_id IS NULL THEN
      fnd_file.put_line(fnd_file.log, '** ERROR: Please set the following site level profile option');
      fnd_file.put_line(fnd_file.log, '** before proceeding with this upgrade: ');
      fnd_file.put_line(fnd_file.log, '**        MRP: Default Sourcing Assignment Set');
      return;
  END IF;


  -- For each item in po_autosource_rules, determine whether a sourcing
  -- rule has already been assigned to that item.  If so, do not upgrade
  -- the autosource rules for this item.  Otherwise, define a new sourcing
  -- rule for the item and assign it to the item.

  OPEN C2;
  LOOP

    x_progress := '050';
    FETCH C2 into x_item_id;
    EXIT WHEN C2%NOTFOUND;

    x_progress := '060';

/* Bug 1261392
   To increase the perfomance, used the hint mrp_sr_assignments_n3
*/

    SELECT /*+ INDEX(MRP_SR_ASSIGNMENTS MRP_SR_ASSIGNMENTS_N3)*/
            count(*)
    INTO    x_dummy_count
    FROM    mrp_sr_assignments
    WHERE   inventory_item_id = x_item_id
    AND	    assignment_set_id = x_assignment_set_id
    AND     sourcing_rule_type = 1
    AND	    assignment_type = 3;

    IF x_dummy_count > 0 THEN

	-- Another sourcing rule has already been assigned to this item
	-- in the default PO assignment set.  Do not upgrade autosource
        -- rules for this item.
        null;
	fnd_file.put_line(fnd_file.log, 'A sourcing rule has already been assigned to ITEM_ID = '||x_item_id);

    ELSE

      -- Upgrade all autosource rules for the item, regardless of
      -- effectivity.  Use the name of the autosource rule with the earliest
      -- effectivity dates as the name of our new sourcing rule.
      -- X_first_rule is used to identify the earliest autosource rule.

      x_first_rule := 'Y';

      fnd_file.put_line(fnd_file.log, 'Upgrading autosource rules for ITEM_ID = '||x_item_id);

      -- Select all autosource rules for this item.

      OPEN C1;
      LOOP

        x_progress := '080';
        FETCH C1 into x_autosource_rule_id,
		x_autosource_rule_name,
		x_start_date,
		x_end_date,
		x_last_update_date,
		x_last_update_login,
		x_last_updated_by,
		x_creation_date,
		x_created_by,
                  x_ATTRIBUTE_CATEGORY,
                  x_attribute1,
                  x_attribute2,
                  x_attribute3,
                  x_attribute4,
                  x_attribute5,
                  x_attribute6,
                  x_attribute7,
                  x_attribute8,
                  x_attribute9,
                  x_attribute10,
                  x_attribute11,
                  x_attribute12,
                  x_attribute13,
                  x_attribute14,
                  x_attribute15 ;

        EXIT WHEN C1%NOTFOUND;

-- testing:
--x_created_by := 99999;

        IF x_first_rule = 'Y' THEN

            -- Get new sourcing_rule_id and create a new sourcing rule
	    -- for this item.

            x_progress := '090';
            OPEN I1;
            FETCH I1 into x_sourcing_rule_id;
            IF (I1%NOTFOUND) THEN
	        close I1;
	        fnd_file.put_line(fnd_file.log, '** Cannot get sourcing_rule_id');
	        raise NO_DATA_FOUND;
            END IF;
            CLOSE I1;

            -- Insert record into mpr_sourcing_rules

            x_progress := '100';
            fnd_file.put_line(fnd_file.log, 'Creating sourcing rule.  SOURCING_RULE_ID = '||x_sourcing_rule_id);
            fnd_file.put_line(fnd_file.log, 'SOURCING_RULE_NAME = '||x_autosource_rule_name);

            INSERT INTO MRP_SOURCING_RULES(
		sourcing_rule_id,
		sourcing_rule_name,
		status,
		sourcing_rule_type,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		planning_active,
                   ATTRIBUTE_CATEGORY,
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
            ) VALUES (
		x_sourcing_rule_id,
		x_autosource_rule_name,
		1, 			-- status
		1, 			-- sourcing_rule_type (1=SOURCING RULE)
		x_last_update_date,
		x_last_updated_by,
		x_creation_date,
		x_created_by,
		x_last_update_login,
		1, -- planning_active (1=ACTIVE)
                x_ATTRIBUTE_CATEGORY,
                  x_attribute1,
                  x_attribute2,
                  x_attribute3,
                  x_attribute4,
                  x_attribute5,
                  x_attribute6,
                  x_attribute7,
                  x_attribute8,
                  x_attribute9,
                  x_attribute10,
                  x_attribute11,
                  x_attribute12,
                  x_attribute13,
                  x_attribute14,
                  x_attribute15
            );

	    x_first_rule := 'N';

        END IF;

	-- Get new sr_receipt_id and insert into mrp_sr_receipt_org

	OPEN I2;
	FETCH I2 into x_sr_receipt_id;
	IF (I2%NOTFOUND) THEN
	    close I2;
	    fnd_file.put_line(fnd_file.log, '** Cannot get sr_receipt_id');
	    raise NO_DATA_FOUND;
	END IF;
	CLOSE I2;

	x_progress := '110';
        fnd_file.put_line(fnd_file.log, 'Upgrading autosource rule.  AUTOSOURCE_RULE_ID = '||x_autosource_rule_id);

	INSERT INTO MRP_SR_RECEIPT_ORG(
		sr_receipt_id,
		sourcing_rule_id,
		effective_date,
		disable_date,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login
	) VALUES (
		x_sr_receipt_id,
		x_sourcing_rule_id,
		x_start_date,
		x_end_date,
		x_last_update_date,
		x_last_updated_by,
		x_creation_date,
		x_created_by,
		x_last_update_login
	);

	-- x_usr_upgrade_docs is set by user to specify whether source
        -- documents should be upgraded.
	--	'NONE'	  Do not upgrade source documents
	-- 	'CURRENT' Upgrade source documents only for currently
	--		  effective autosource rule
	--	'FUTURE'  Upgrade source documents for all autosource
	--		  rules effective now and in the future

	IF (x_usr_upgrade_docs = 'NONE') THEN
	    x_upgrade_docs := 'N';
	ELSIF (x_usr_upgrade_docs = 'CURRENT') THEN
	    IF (x_start_date <= sysdate and x_end_date > sysdate) THEN
	        x_upgrade_docs := 'Y';
	    ELSE
		x_upgrade_docs := 'N';
	    END IF;
	ELSIF (x_usr_upgrade_docs = 'FUTURE') THEN
	    IF (x_end_date > sysdate) THEN
		x_upgrade_docs := 'Y';
	    ELSE
		x_upgrade_docs := 'N';
	    END IF;
	END IF;

	-- Get all vendors for this sourcing rule from po_autosource_vendors.
	-- For each vendor, create a new record in mrp_sr_source_org.
	-- Also create an ASL entry for the supplier-item relationship if
	-- one does not already exist.

	x_progress := '130';
	po_asl_upgrade_sv2.upgrade_autosource_vendors(
			x_sr_receipt_id,
			x_autosource_rule_id,
			x_item_id,
			x_asl_status_id,
			x_upgrade_docs,
			x_usr_upgrade_docs);

      END LOOP;
      CLOSE C1;

      -- Get assignment_id and assign the new sourcing rule to the
      -- item.  Assignment type is ITEM.

      x_progress := '140';
      OPEN I3;
      FETCH I3 into x_assignment_id;
      IF (I3%NOTFOUND) THEN
	  close I3;
	  fnd_file.put_line(fnd_file.log, '** Cannot get assignment id');
	  raise NO_DATA_FOUND;
      END IF;
      CLOSE I3;

      -- Get organization_id

      x_progress := 'SV1-145';

/*Bug 1776173
  If one item is assigned to multiple inventory organizations and
  each of those of have different master organizations then
  to prevent the following sql from returning too many rows
  added the join to financials system parameters which will ensure
  that only row is returned.
*/
  begin
        select mtl.organization_id
        into x_organization_id
        from mtl_system_items msi, mtl_parameters mtl,
             financials_system_parameters fsp --1776173
        where msi.inventory_item_id = x_item_id
        and   msi.organization_id   = fsp.inventory_organization_id --1776173
        and   msi.organization_id   = mtl.master_organization_id
        and   msi.organization_id   = mtl.organization_id;
 exception
         when no_data_found then
          select mtl.organization_id
        into x_organization_id
        from mtl_system_items msi, mtl_parameters mtl
        where msi.inventory_item_id = x_item_id
        and   msi.organization_id   = mtl.master_organization_id
        and   msi.organization_id   = mtl.organization_id;
       fnd_file.put_line(fnd_file.log, 'In the exception');
end;

      x_progress := '150';
      fnd_file.put_line(fnd_file.log, 'Assigning sourcing rule to item.');

      INSERT INTO MRP_SR_ASSIGNMENTS(
		assignment_id,
		assignment_type,
		sourcing_rule_id,
		sourcing_rule_type,
		assignment_set_id,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		organization_id,
		inventory_item_id
      ) VALUES (
		x_assignment_id,
		3,			-- assignment_type (3=ITEM)
		x_sourcing_rule_id,
		1,			-- sourcing_rule_type (1=SOURCING RULE)
		x_assignment_set_id,
		x_last_update_date,
		x_last_updated_by,
		x_creation_date,
		x_created_by,
		x_last_update_login,
		x_organization_id,
		x_item_id
      );

    END IF;

    --dbms_output.put_line('=============================================================');

  END LOOP;
  CLOSE C2;

  -- Set request_id in po_approved_supplier_list back to null

  UPDATE  po_approved_supplier_list
  SET	  request_id = null
  WHERE   request_id = -99;

  -- Commit the new records

  COMMIT;

EXCEPTION

    WHEN OTHERS THEN
       fnd_file.put_line(fnd_file.log, '** Exception in upgrade_autosource_rules');
       fnd_file.put_line(fnd_file.log, 'x_progress = '||x_progress);
	PO_MESSAGE_S.SQL_ERROR('UPGRADE_SOURCING_RULES', x_progress, sqlcode);
END;

END PO_ASL_UPGRADE_SV;

/
