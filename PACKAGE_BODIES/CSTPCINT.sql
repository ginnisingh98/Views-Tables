--------------------------------------------------------
--  DDL for Package Body CSTPCINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSTPCINT" AS
/* $Header: CSTPCINB.pls 120.2.12000000.2 2007/05/11 22:50:12 hyu ship $ */

FUNCTION update_interface(
        i_group_id IN NUMBER,
        error_msg OUT NOCOPY VARCHAR2
        ) RETURN INTEGER IS

location NUMBER(2) := 1;

BEGIN

	/*
	 * Resolve all ORGANIZATION_CODE in CST_ITEM_COSTS_INTERFACE.
	 * This must be done first, before the following updates.
	 *
	 */
	UPDATE CST_ITEM_COSTS_INTERFACE CICI
	SET
	CICI.ORGANIZATION_ID = (
          SELECT MP.ORGANIZATION_ID
          FROM MTL_PARAMETERS MP
          WHERE MP.ORGANIZATION_CODE = CICI.ORGANIZATION_CODE
        )
	WHERE CICI.GROUP_ID = i_group_id;

        /*
         * Resolve all INVENTORY_ITEM_ID and COST_TYPE_ID in
	 * CST_ITEM_COSTS_INTERFACE.
         *
         * This must be done after the ORGANIZATION_ID is resolved.
         */
	location := 2;

	/*
	 * Only resolve inventory_item_id if it is null. This
	 * is because MIF.ITEM_NUMBER is a concatnation of segments
	 * and there are no good indices to use. Therefore the performance
	 * of the following update statement is BAD.
	 */

	UPDATE CST_ITEM_COSTS_INTERFACE CICI
        SET
	INVENTORY_ITEM_ID = (
                SELECT MIF.ITEM_ID
                FROM MTL_ITEM_FLEXFIELDS MIF
		WHERE MIF.ORGANIZATION_ID = CICI.ORGANIZATION_ID
		AND MIF.ITEM_NUMBER = CICI.INVENTORY_ITEM
	)
	WHERE CICI.GROUP_ID = i_group_id
        AND CICI.INVENTORY_ITEM_ID IS NULL;

	UPDATE CST_ITEM_COSTS_INTERFACE CICI
        SET
	COST_TYPE_ID = (
                SELECT CCT.COST_TYPE_ID
                FROM CST_COST_TYPES CCT
                WHERE NVL( ORGANIZATION_ID, CICI.ORGANIZATION_ID)
			= CICI.ORGANIZATION_ID
                AND CCT.COST_TYPE = CICI.COST_TYPE
	)
	WHERE CICI.GROUP_ID = i_group_id;

        /*
         * Resolve all ORGANIZATION_CODE in CST_ITEM_CST_DTLS_INTERFACE.
         * This must be done first, before the following updates.
         *
         */
	location := 3;

        UPDATE CST_ITEM_CST_DTLS_INTERFACE CICDI
        SET
        CICDI.ORGANIZATION_ID = (
          SELECT MP.ORGANIZATION_ID
          FROM MTL_PARAMETERS MP
          WHERE MP.ORGANIZATION_CODE = CICDI.ORGANIZATION_CODE
	)
	WHERE CICDI.GROUP_ID = i_group_id;

        /*
         * Resolve all INVENTORY_ITEM_ID, COST_TYPE_ID, DEPARTMENT_ID,
	 * ACTIVITY_ID, RESOURCE_ID, BASIS_RESOURCE_ID, and COST_ELEMENT_ID
         * in CST_ITEM_CST_DTLS_INTERFACE.
         *
         * This must be done after the ORGANIZATION_ID is resolved.
         */
	location := 4;

	/*
	 * Only resolve inventory_item_id if it is null. This
	 * is because MIF.ITEM_NUMBER is a concatnation of segments
	 * and there are no good indices to use. Therefore the performance
	 * of the following update statement is BAD.
	 */

	UPDATE CST_ITEM_CST_DTLS_INTERFACE CICDI
        SET
        INVENTORY_ITEM_ID = (
                SELECT MIF.ITEM_ID
		FROM MTL_ITEM_FLEXFIELDS MIF
                WHERE MIF.ORGANIZATION_ID = CICDI.ORGANIZATION_ID
                AND MIF.ITEM_NUMBER = CICDI.INVENTORY_ITEM
        )
        WHERE CICDI.GROUP_ID = i_group_id
        AND CICDI.INVENTORY_ITEM_ID IS NULL;

	UPDATE CST_ITEM_CST_DTLS_INTERFACE CICDI
        SET
        COST_TYPE_ID = (
                SELECT CCT.COST_TYPE_ID
                FROM CST_COST_TYPES CCT
                WHERE NVL( ORGANIZATION_ID, CICDI.ORGANIZATION_ID)
                        = CICDI.ORGANIZATION_ID
                AND CCT.COST_TYPE = CICDI.COST_TYPE
        ),
	DEPARTMENT_ID = (
                SELECT BD.DEPARTMENT_ID
                FROM BOM_DEPARTMENTS BD
                WHERE BD.ORGANIZATION_ID = CICDI.ORGANIZATION_ID
                AND BD.DEPARTMENT_CODE = CICDI.DEPARTMENT
	),
	ACTIVITY_ID = (
                SELECT CA.ACTIVITY_ID
		FROM CST_ACTIVITIES CA
                WHERE NVL(CA.ORGANIZATION_ID,CICDI.ORGANIZATION_ID) =
                                                   CICDI.ORGANIZATION_ID
                AND CA.ACTIVITY = CICDI.ACTIVITY
	),
        /* Bug 5443502: for resource_id and basis_resource_id, added join with cost_element_id */
	RESOURCE_ID = (
		SELECT BR.RESOURCE_ID
		FROM BOM_RESOURCES BR
		WHERE BR.RESOURCE_CODE = CICDI.RESOURCE_CODE
		AND BR.ORGANIZATION_ID = CICDI.ORGANIZATION_ID
                AND BR.COST_ELEMENT_ID = CICDI.COST_ELEMENT_ID
	),
	BASIS_RESOURCE_ID = (
                SELECT BR.RESOURCE_ID
                FROM BOM_RESOURCES BR
                WHERE BR.RESOURCE_CODE = CICDI.BASIS_RESOURCE_CODE
                AND BR.ORGANIZATION_ID = CICDI.ORGANIZATION_ID
                AND BR.COST_ELEMENT_ID = CICDI.COST_ELEMENT_ID
	),
	COST_ELEMENT_ID = (
                SELECT CCE.COST_ELEMENT_ID
                FROM CST_COST_ELEMENTS CCE
                WHERE CCE.COST_ELEMENT = CICDI.COST_ELEMENT
	)
        WHERE CICDI.GROUP_ID = i_group_id;



  RETURN( 0 ); /* No Error */

EXCEPTION
    WHEN NO_DATA_FOUND THEN
	RETURN( 0 );
    WHEN OTHERS THEN
        ROLLBACK;
        error_msg         := 'update_interface(' || location || '):' || SQLERRM(100);
        RETURN( SQLCODE );

END update_interface;

FUNCTION validate_interface(
        i_group_id          IN NUMBER,
        i_to_org_id         IN NUMBER,
        error_msg       OUT NOCOPY VARCHAR2
        ) RETURN INTEGER IS
rows_found NUMBER;
l_to_wsm_flag NUMBER;
BEGIN

rows_found := 0;

       /* If destination organization is not wsm enabled, then leave yielded cost as null */
        select count(*)
        into l_to_wsm_flag
        from mtl_parameters mp,wsm_parameters wsm
        where wsm.organization_id = i_to_org_id
        and mp.organization_id = wsm.organization_id
        and UPPER(mp.wsm_enabled_flag) = 'Y';

        if (l_to_wsm_flag <= 0) then
             update cst_item_cst_dtls_interface
             set yielded_cost = null
             where organization_id = i_to_org_id
             and group_id = i_group_id
             and yielded_cost is not null;
        end if;



	/*
	 * CHECK RESOURCE_ID
	 */
	INSERT into cst_interface_errors (
		inventory_item,
		entity_code,
		error_type,
		group_id
	)
	SELECT
		inventory_item,
		resource_code,
		DECODE(cost_element_id,
		       3,1,
		       5,5),
		i_group_id
	FROM cst_item_cst_dtls_interface CICDI
	WHERE CICDI.group_id = i_group_id
	AND CICDI.resource_code IS NOT NULL
	AND CICDI.resource_id IS NULL
	UNION
	SELECT
		INVENTORY_ITEM,
		ACTIVITY,
		2,
		i_group_id
	FROM CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE CICDI.GROUP_ID = i_group_id
	AND CICDI.ACTIVITY_ID IS NULL
	AND CICDI.ACTIVITY IS NOT NULL;

	rows_found := rows_found + SQL%ROWCOUNT;

        insert into cst_interface_errors (
                inventory_item,
                entity_code,
                error_type,
                group_id
        )
        select  inventory_item,
                resource_code,
                6,
                i_group_id
        from cst_item_cst_dtls_interface cicdi
        where cicdi.group_id = i_group_id
        /* TL Material Overhead needs to have Subelement specified */
        and cicdi.resource_code is null
        and (cicdi.cost_element_id = 2 and cicdi.level_type = 1);

        rows_found := rows_found + SQL%ROWCOUNT;

	INSERT into cst_interface_errors (
		inventory_item,
		entity_code,
		error_type,
		group_id
	)
	SELECT
		INVENTORY_ITEM,
		DEPARTMENT,
		3,
		i_group_id
	FROM CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE CICDI.GROUP_ID = i_group_id
	AND CICDI.DEPARTMENT_ID IS NULL
	AND CICDI.DEPARTMENT IS NOT NULL
	UNION
	SELECT
		INVENTORY_ITEM,
		BASIS_RESOURCE_CODE,
		4,
		i_group_id
	FROM CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE CICDI.GROUP_ID = i_group_id
	AND CICDI.BASIS_RESOURCE_ID IS NULL
	AND CICDI.BASIS_RESOURCE_CODE IS NOT NULL;

	rows_found := rows_found + SQL%ROWCOUNT;

	INSERT into cst_interface_errors (
		inventory_item,
		entity_code,
		error_type,
		group_id
	)
	SELECT
		INVENTORY_ITEM,
		COST_ELEMENT,
		5,
		i_group_id
	FROM CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE CICDI.GROUP_ID = i_group_id
	AND CICDI.COST_ELEMENT_ID IS NULL
	AND CICDI.COST_ELEMENT IS NOT NULL;

	rows_found := rows_found + SQL%ROWCOUNT;

	IF  (rows_found <> 0) THEN
		RETURN(1); /* Invalid */
	ELSE
		RETURN(0); /* Valid */
	END IF;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        error_msg         := 'validate_interface:' || SQLERRM(100);
        RETURN( SQLCODE );

END validate_interface;


FUNCTION insert_to_dest(
        i_group_id	IN NUMBER,
        i_user_id	IN NUMBER,
	i_request_id	IN NUMBER,
	i_prog_applid	IN NUMBER,
	i_prog_id	IN NUMBER,
	i_rowcount	OUT NOCOPY NUMBER,
        error_msg       OUT NOCOPY VARCHAR2
) RETURN INTEGER IS

location	NUMBER := 0;

BEGIN

	location := 0;

	INSERT INTO CST_ITEM_COSTS (
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID,
		COST_TYPE_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		INVENTORY_ASSET_FLAG,
		LOT_SIZE,
		BASED_ON_ROLLUP_FLAG,
		SHRINKAGE_RATE,
		DEFAULTED_FLAG,
		COST_UPDATE_ID,
		PL_MATERIAL,
		PL_MATERIAL_OVERHEAD,
		PL_RESOURCE,
		PL_OUTSIDE_PROCESSING,
		PL_OVERHEAD,
		TL_MATERIAL,
		TL_MATERIAL_OVERHEAD,
		TL_RESOURCE,
		TL_OUTSIDE_PROCESSING,
		TL_OVERHEAD,
		MATERIAL_COST,
		MATERIAL_OVERHEAD_COST,
		RESOURCE_COST,
		OUTSIDE_PROCESSING_COST,
		OVERHEAD_COST,
		PL_ITEM_COST,
		TL_ITEM_COST,
		ITEM_COST,
		UNBURDENED_COST,
		BURDEN_COST,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE
	) SELECT
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID,
		COST_TYPE_ID,
		SYSDATE,
		i_user_id,
		SYSDATE,
		i_user_id,
		-1,
		INVENTORY_ASSET_FLAG,
		LOT_SIZE,
		BASED_ON_ROLLUP_FLAG,
		SHRINKAGE_RATE,
		DEFAULTED_FLAG,
		COST_UPDATE_ID,
		PL_MATERIAL,
		PL_MATERIAL_OVERHEAD,
		PL_RESOURCE,
		PL_OUTSIDE_PROCESSING,
		PL_OVERHEAD,
		TL_MATERIAL,
		TL_MATERIAL_OVERHEAD,
		TL_RESOURCE,
		TL_OUTSIDE_PROCESSING,
		TL_OVERHEAD,
		MATERIAL_COST,
		MATERIAL_OVERHEAD_COST,
		RESOURCE_COST,
		OUTSIDE_PROCESSING_COST,
		OVERHEAD_COST,
		PL_ITEM_COST,
		TL_ITEM_COST,
		ITEM_COST,
		UNBURDENED_COST,
		BURDEN_COST,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		i_request_id,
		i_prog_applid,
		i_prog_id,
		SYSDATE
	FROM	CST_ITEM_COSTS_INTERFACE CICI
	WHERE	CICI.GROUP_ID = i_group_id;

	i_rowcount := SQL%ROWCOUNT;

	location := 1;

	INSERT INTO CST_ITEM_COST_DETAILS (
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID,
		COST_TYPE_ID,
		LAST_UPDATE_DATE,
		LAST_UPDATED_BY,
		CREATION_DATE,
		CREATED_BY,
		LAST_UPDATE_LOGIN,
		OPERATION_SEQUENCE_ID,
		OPERATION_SEQ_NUM,
		DEPARTMENT_ID,
		LEVEL_TYPE,
		ACTIVITY_ID,
		RESOURCE_SEQ_NUM,
		RESOURCE_ID,
		RESOURCE_RATE,
		ITEM_UNITS,
		ACTIVITY_UNITS,
		USAGE_RATE_OR_AMOUNT,
		BASIS_TYPE,
		BASIS_RESOURCE_ID,
		BASIS_FACTOR,
		NET_YIELD_OR_SHRINKAGE_FACTOR,
		ITEM_COST,
		COST_ELEMENT_ID,
		ROLLUP_SOURCE_TYPE,
		ACTIVITY_CONTEXT,
		REQUEST_ID,
		PROGRAM_APPLICATION_ID,
		PROGRAM_ID,
		PROGRAM_UPDATE_DATE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		--bug5839929
		YIELDED_COST
	) SELECT
		INVENTORY_ITEM_ID,
		ORGANIZATION_ID,
		COST_TYPE_ID,
		SYSDATE,
		i_user_id,
		SYSDATE,
		i_user_id,
		NULL,
		OPERATION_SEQUENCE_ID,
		OPERATION_SEQ_NUM,
		DEPARTMENT_ID,
		LEVEL_TYPE,
		ACTIVITY_ID,
		RESOURCE_SEQ_NUM,
		RESOURCE_ID,
		RESOURCE_RATE,
		ITEM_UNITS,
		ACTIVITY_UNITS,
		USAGE_RATE_OR_AMOUNT,
		BASIS_TYPE,
		BASIS_RESOURCE_ID,
		BASIS_FACTOR,
		NET_YIELD_OR_SHRINKAGE_FACTOR,
		ITEM_COST,
		COST_ELEMENT_ID,
		ROLLUP_SOURCE_TYPE,
		ACTIVITY_CONTEXT,
		i_request_id,
		i_prog_applid,
		i_prog_id,
		SYSDATE,
		ATTRIBUTE_CATEGORY,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		--bug5839929
		YIELDED_COST
	FROM	CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE	CICDI.GROUP_ID = i_group_id;


	RETURN( 0 ); /* No Error */

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        error_msg := 'insert_to_dest(' || location ||'): ' || SQLERRM(100);
        RETURN( SQLCODE );

END insert_to_dest;

FUNCTION delete_from_interface(
        i_group_id	IN NUMBER,
        error_msg	OUT NOCOPY VARCHAR2
) RETURN INTEGER IS

location	NUMBER := 0;

BEGIN

	location := 0;

	DELETE FROM CST_ITEM_COSTS_INTERFACE CICI
	WHERE CICI.GROUP_ID = i_group_id;

	location := 1;

	DELETE FROM CST_ITEM_CST_DTLS_INTERFACE CICDI
	WHERE CICDI.GROUP_ID = i_group_id;

	RETURN( 0 ); /* No Error */

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        error_msg := 'delete_from_interface(' || location || '): ' ||
		SQLERRM(100);
        RETURN( SQLCODE );

END delete_from_interface;

FUNCTION copy_to_dest(
        i_group_id	 	IN NUMBER,
        i_from_org_id		IN NUMBER,
    	i_to_org_id		IN NUMBER,
	i_from_cost_type	IN NUMBER,
	i_to_cost_type		IN NUMBER,
        i_summary_option	IN NUMBER,
        i_mtl_subelement        IN NUMBER,
        i_moh_subelement	IN NUMBER,
        i_res_subelement	IN NUMBER,
        i_osp_subelement        IN NUMBER,
        i_ovh_subelement        IN NUMBER,
        i_conv_type             IN VARCHAR2,
        i_exact_copy_flag       IN VARCHAR2,
        i_user_id	 	IN NUMBER,
	i_request_id	 	IN NUMBER,
	i_prog_applid	 	IN NUMBER,
	i_prog_id	 	IN NUMBER,
	i_rowcount	 	OUT NOCOPY NUMBER,
        error_msg        	OUT NOCOPY VARCHAR2
) RETURN INTEGER IS

result		NUMBER;
l_msg_count     NUMBER := 0;
l_return_status VARCHAR2(1) := fnd_api.g_ret_sts_success;
l_msg_data 	VARCHAR2(240) := '';

BEGIN

 result := 0;

 if (i_summary_option < 4) then
        fnd_file.put_line(fnd_file.log,'calling processInterface ...');
        fnd_file.put_line(fnd_file.log,'summary option = ' || to_char(i_summary_option));
 	CST_SubElements_PVT.processInterface
	      (	p_api_version		=>	1.0,
		x_return_status		=>	l_return_status,
                x_msg_count		=>	l_msg_count,
                x_msg_data		=>	l_msg_data,
		p_group_id		=>	i_group_id,
		p_from_organization_id	=>	i_from_org_id,
		p_to_organization_id	=>	i_to_org_id,
		p_from_cost_type_id	=>	i_from_cost_type,
		p_to_cost_type_id	=>	i_to_cost_type,
		p_summary_option	=>	i_summary_option,
		p_mtl_subelement	=>	i_mtl_subelement,
		p_moh_subelement	=>	i_moh_subelement,
		p_res_subelement	=>	i_res_subelement,
		p_osp_subelement	=>	i_osp_subelement,
		p_ovh_subelement	=>	i_ovh_subelement,
		p_conv_type		=>	i_conv_type,
                p_exact_copy_flag       =>      i_exact_copy_flag );


         /**** Write the messages to the log file ****/

  CST_Utility_PUB.writeLogMessages (
                    p_api_version => 1.0,
                    p_msg_count => l_msg_count,
                    p_msg_data  => l_msg_data,
                    x_return_status => l_return_status );

  end if;

 result := cstpcint.update_interface( i_group_id, error_msg );
 if (result <> 0)
 then
     return(result);
 end if;

 result := cstpcint.validate_interface( i_group_id, i_to_org_id,error_msg );
 if (result <> 0)
 then
     return(result);
 end if;


 result := cstpcint.insert_to_dest(i_group_id,
				   i_user_id,
				   i_request_id,
				   i_prog_applid,
				   i_prog_id,
				   i_rowcount,
				   error_msg );

 if (result <> 0)
 then
     return(result);
 end if;

 result := cstpcint.delete_from_interface( i_group_id, error_msg );
 if (result <> 0)
 then
     return(result);
 end if;

 return( 0 );

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        error_msg := 'copy_to_dest:' || SQLERRM(100);
        RETURN( SQLCODE );

END copy_to_dest;

END CSTPCINT; /* end package body */

/
