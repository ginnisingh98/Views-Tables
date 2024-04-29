--------------------------------------------------------
--  DDL for Package Body CZ_ATP_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_ATP_UTIL" AS
/* $Header: czatpub.pls 120.0 2005/05/25 05:06:46 appldev noship $ */
-- constants

PROCEDURE insert_atp_request (p_inventory_item_id IN NUMBER,
                              p_organization_id IN NUMBER,
  							  p_quantity IN NUMBER,
							  p_atp_group_id IN OUT NOCOPY NUMBER,
							  p_return_status OUT NOCOPY VARCHAR2,
							  p_error_message OUT NOCOPY VARCHAR2,
							  p_sequence_number IN NUMBER,
							  p_atp_rule_id IN NUMBER DEFAULT NULL) IS

  rec_mgav  mtl_group_atps_view%rowtype;
  p_process_flag NUMBER := 1;
  atp_lead_time NUMBER := NULL;
  demand_class VARCHAR2(30) := NULL;
  atp_group_id_exc EXCEPTION;
  no_atp_rule_exc EXCEPTION;
  no_item_exc EXCEPTION;
  no_calendar_org_exc EXCEPTION;

BEGIN

  -- Initialize p_return_status
  p_return_status := G_RET_STS_SUCCESS;

  -- ATP group ID assignment
  IF p_atp_group_id IS NULL THEN
    select MTL_DEMAND_INTERFACE_S.NEXTVAL into p_atp_group_id
      from dual;
  END IF;

  rec_mgav.ATP_GROUP_ID := p_atp_group_id;

  if rec_mgav.ATP_GROUP_ID is null then
    -- cannot proceed with null atp group id
    raise atp_group_id_exc;
  end if;

  -- ATP rule ID selection
  -- if passed in, use it. else find out from item if it has atp rule or else
  -- takes it from organization default. cannot be null

  -- NOTE:  This block always needs to be run, because it selects
  --        primary_uom_code as well as atp_rule_id
  begin
    select atp_rule_id, primary_uom_code
    into
      rec_mgav.atp_rule_id, rec_mgav.uom_code
    from
       mtl_system_items
    where
       inventory_item_id = p_inventory_item_id and
       organization_id = p_organization_id;
  exception
    WHEN NO_DATA_FOUND THEN
      raise no_item_exc;
  end;

  -- if ATP rule was provided, use instead
  if p_atp_rule_id is not null then
    rec_mgav.atp_rule_id := p_atp_rule_id;
  end if;

  -- check if ATP rule ID has been provided or selected from msi table.
  -- if not, take it from mtl parameters by org definition.
  begin
    if rec_mgav.atp_rule_id is null then
        begin
          SELECT r.rule_id
          INTO
            rec_mgav.atp_rule_id
          FROM
            mtl_parameters p, mtl_atp_rules r
          WHERE
            p.default_atp_rule_id = r.rule_id
            AND p.organization_id =  p_organization_id;
        exception
          when NO_DATA_FOUND then
            --No Atp Rule specified
	        raise no_atp_rule_exc;
        end;
    end if;
  exception
    when NO_DATA_FOUND then
	  -- item not found
	  raise no_item_exc;
  end;
  --dbms_output.put_line ('Atp Rule id : ' || to_char (rec_mgav.ATP_RULE_ID) );

  -- retrieve calendar organization ID
  begin
    SELECT MTL.ORGANIZATION_ID
    into rec_mgav.atp_calendar_organization_id
    FROM   HR_ORGANIZATION_UNITS HR, MTL_PARAMETERS MTL
       WHERE  HR.ORGANIZATION_ID = MTL.ORGANIZATION_ID
       AND    MTL.CALENDAR_CODE is not null
       AND    MTL.CALENDAR_EXCEPTION_SET_ID is not null
       AND    MTL.ORGANIZATION_ID = p_organization_id;
    if rec_mgav.atp_calendar_organization_id is null then
	  raise no_calendar_org_exc;
    end if;
  exception
    when NO_DATA_FOUND then
      raise no_calendar_org_exc;
  end;

--dbms_output.put_line ('Calendar org id: ' ||
--       to_char (rec_mgav.atp_calendar_organization_id) );

  INSERT INTO MTL_GROUP_ATPS_VIEW
    (ATP_GROUP_ID,
     ORGANIZATION_ID,
     INVENTORY_ITEM_ID,
     LAST_UPDATE_DATE,
     LAST_UPDATED_BY,
     CREATION_DATE,
     CREATED_BY,
     LAST_UPDATE_LOGIN,
     ATP_RULE_ID,
     REQUEST_QUANTITY,
     REQUEST_PRIMARY_UOM_QUANTITY,
     REQUEST_DATE,
     ATP_LEAD_TIME,
     ATP_CALENDAR_ORGANIZATION_ID,
     AVAILABLE_TO_ATP,
     UOM_CODE,
     DEMAND_CLASS,
     N_COLUMN2
    )
  values
    (
     rec_mgav.ATP_GROUP_ID,
     p_organization_id,
     p_inventory_item_id,
     sysdate,
     -1,
     sysdate,
     -1,
     -1,
     rec_mgav.ATP_RULE_ID,
     p_quantity,
     p_quantity,
     sysdate,
     atp_lead_time,
     rec_mgav.ATP_CALENDAR_ORGANIZATION_ID,
     1,
     rec_mgav.UOM_CODE,
     demand_class,
     p_sequence_number
    );

	-- Q: Should we do the commit, or have it done externally?
	-- A: for now, keep it here, because we're not managing transactions
	--    in "read only" mode
	commit;

EXCEPTION
  WHEN atp_group_id_exc THEN
	p_atp_group_id := null;
	p_error_message := 'ATP group ID could not be assigned';
	p_return_status := G_RET_STS_ERROR;
  WHEN no_atp_rule_exc THEN
	p_atp_group_id := null;
    p_error_message := 'ATP rule could not be determined';
	p_return_status := G_RET_STS_ERROR;
  WHEN no_item_exc THEN
    -- Item not found
	p_atp_group_id := null;
	p_error_message := 'Invalid inventory item id';
    p_return_status := G_RET_STS_ERROR;
  WHEN no_calendar_org_exc THEN
	p_atp_group_id := null;
    p_error_message := 'Calendar org could not be determined';
	p_return_status := G_RET_STS_ERROR;
  WHEN OTHERS THEN
	p_atp_group_id := null;
    p_error_message := 'cz_atp_util.insert_atp_request: ' || SQLERRM;
	p_return_status := G_RET_STS_UNEXP_ERROR;
END insert_atp_request;


PROCEDURE run_atp_check (p_return_status OUT NOCOPY VARCHAR2, p_error_message OUT NOCOPY VARCHAR2,
                         p_atp_group_id IN NUMBER, p_user_id IN NUMBER,
                         p_resp_id IN NUMBER, p_appl_id IN NUMBER,
                         p_timeout IN NUMBER) IS
  no_atp_group_exc EXCEPTION;
  retval NUMBER;
  mgr_outcome varchar2 (30);
  mgr_message varchar2 (240);
BEGIN

  -- Initialize p_return_status
  p_return_status := G_RET_STS_SUCCESS;

  -- Initialize apps environment.
  fnd_global.apps_initialize(p_user_id, p_resp_id, p_appl_id);

  IF p_atp_group_id IS NULL THEN
    raise no_atp_group_exc;
  END IF;

  retval := fnd_transaction.synchronous
              (p_timeout,
			   mgr_outcome,
			   mgr_message,
			   'INV',
			   'INXATP',
			   --   'INXATP GROUP_ID=343499 DETAIL_FLAG=0 MRP_STATUS=1'
			   --   'INXATP GROUP_ID=343499 MRP_STATUS=1'
			   'INXATP GROUP_ID=' || to_char(p_atp_group_id) || ' MRP_STATUS=1'
               );

  if retval = 0 then
    -- success
    --dbms_output.put_line ('Success');
    null;
  elsif retval = 1 then
    -- timeout
    --dbms_output.put_line ('Timed out');
	p_error_message := 'cz_atp_util.run_atp_check timed out';
  elsif retval = 2 then
    -- no manager
    --dbms_output.put_line ('No manager');
	p_error_message := 'cz_atp_util.run_atp_check failed: no manager';
  elsif retval = 3 then
    -- other
    --dbms_output.put_line ('Other Error');
    p_error_message := 'cz_atp_util failed: ' || mgr_outcome || ' '
	                   || mgr_message;
  end if;

EXCEPTION
  WHEN no_atp_group_exc THEN
    p_error_message := 'cz_atp_util.run_atp_check: ATP group ID is required for processing';
	p_return_status := G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_error_message := 'cz_atp_util.run_atp_check: ' || SQLERRM;
	p_return_status := G_RET_STS_UNEXP_ERROR;
END run_atp_check;


PROCEDURE get_atp_result (p_atp_group_id IN NUMBER, p_earliest_atp_date OUT NOCOPY DATE,
                          p_return_status OUT NOCOPY VARCHAR2, p_error_message OUT NOCOPY VARCHAR2,
                          p_sequence_number IN NUMBER) IS
  error_code NUMBER;
  ret_val    number;
  group_available_date DATE;
  no_atp_group_exc EXCEPTION;
BEGIN

  -- Initialize p_return_status
  p_return_status := G_RET_STS_SUCCESS;

  if p_atp_group_id is null then
    raise no_atp_group_exc;
  end if;

  select
      error_code,
      group_available_date,
      earliest_atp_date
  into
      error_code,
      group_available_date,
      p_earliest_atp_date
  from
      MTL_GROUP_ATPS_VIEW
  where
      ATP_GROUP_ID = p_atp_group_id and
      n_column2    = p_sequence_number;

  IF p_earliest_atp_date IS NULL THEN
    IF error_code IS NOT NULL AND error_code <> 0 THEN
	  SELECT meaning INTO p_error_message FROM mfg_lookups
	    WHERE lookup_code = error_code
		AND lookup_type = 'MTL_DEMAND_INTERFACE_ERRORS';
	  p_return_status := G_RET_STS_ERROR;
	ELSIF error_code IS NULL THEN
	  p_error_message := 'cz_atp_util.get_atp_result: MTL_DEMAND_INTERFACE row '
	                     || 'not processed';
	  p_return_status := G_RET_STS_UNEXP_ERROR;
	ELSE
	  p_error_message := 'cz_atp_util.get_atp_result: unknown '
	                     || 'mtl_demand_interface error';
	  p_return_status := G_RET_STS_UNEXP_ERROR;
	END IF;
  END IF;

  -- delete record
  DELETE FROM mtl_group_atps_view WHERE atp_group_id = p_atp_group_id
    AND n_column2 = p_sequence_number;

  -- need to commit here
  commit;

EXCEPTION
  WHEN no_atp_group_exc THEN
    p_error_message := 'cz_atp_util.get_atp_result: ATP group ID is required input';
    p_return_status := G_RET_STS_ERROR;
  WHEN OTHERS THEN
    p_error_message := 'cz_atp_util.get_atp_result: ' || SQLERRM;
	p_return_status := G_RET_STS_UNEXP_ERROR;
END get_atp_result;

END CZ_ATP_UTIL;

/
