--------------------------------------------------------
--  DDL for Package Body GMF_VIB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_VIB" AS
/*  $Header: GMFVIBB.pls 120.2.12010000.6 2010/04/05 19:56:52 rpatangy ship $ */

g_pkg_name VARCHAR2(30) := 'GMF_VIB';
g_debug    VARCHAR2 (5)  := fnd_profile.VALUE ('AFLOG_LEVEL');

--+==========================================================================+
--|  Global Comments
--+==========================================================================+
--| HISTORY                                                                  |
--|   jgogna - created                                                       |
--|   rseshadr 01-May-2006   bug 5190115 - handle nulls in cost_alloc for    |
--|     products.  Fixed typo in resource reversal exception bloc.           |
--|                                                                          |
--|   vchukkap 21-Sep-2006   bug 5491419 - batch requirements are not getting|
--|     created for closed batches during migration. Only creating for       |
--|     batches with status: wip or completed (2 and 3). Included status 4.    |
--|                                                                          |
--|   umoogala 21-Oct-2006   bug 5607069 -                                   |
--|      Issue 1) Material and Resources reversals layers were not getting   |
--|               consumed.                                                  |
--|               Fixed code to allocate reversals only if its original      |
--|               layer is consumed by this product, while creating VIB dtls.|
--|      Issue 2) Material and Resources reversals layers were not getting   |
--|               properly apportioned in the finalization layers.           |
--|               Fix is same as above:                                      |
--|               Fixed code to allocate reversals only if its original      |
--|               layer is consumed by this product, while creating VIB dtls.|
--|   Pramod B.H 25-Aug-2008  Bug 6125370 - While releasing a batch, additional|
--|     check is performed to verify if the batch contains at least one      |
--|     product line with both non-zero planned qty and non-zero cost        |
--|     allocation factor. If no such product line exists then the process   |
--|     will raise an error and will stop the batch release activity.
--+==========================================================================+

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Batch_Requirements                                             |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create_Batch_Requirement                                              |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|   jgogna - created                                                       |
--|   rseshadr 01-May-2006   bug 5190115 - handle nulls in cost_alloc for    |
--|     products.  Fixed typo in resource reversal exception bloc.           |
--|                                                                          |
--|   vchukkap 21-Sep-2006   bug 5491419 - batch requirements are not getting|
--|     created for closed batches during migration. Only creating for       |
--|     batches with status: wip or completed (2 and 3). Included status 4.    |
--+==========================================================================+
*/
PROCEDURE Create_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

l_count		PLS_INTEGER;
l_api_name	VARCHAR2(30) := 'Create_Batch_Requirements';
BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	-- Check if the Batch requirements already exist
	BEGIN
		l_count := 0;
		SELECT count(*)
		INTO l_count
		FROM gmf_batch_requirements
		WHERE batch_id = p_batch_id AND
			delete_mark = 0;

		IF l_count > 0 THEN
			dbms_output.put_line ('Batch requirement already exist for the batch');
			x_return_status := FND_API.G_RET_STS_SUCCESS;
			FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_REQ_EXISTS');
			FND_MSG_PUB.Add;
			RETURN;
		END IF;
	END;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('calling Create_Temp_Batch_Requirements');
	END IF;

	Create_Temp_Batch_Requirements (
		p_api_version,
		p_init_msg_list,
		p_batch_id,
		x_return_status,
		x_msg_count,
		x_msg_data);

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('after Create_Temp_Batch_Requirements status/msg: ' || x_return_status ||'/'||x_msg_data);
	END IF;


	IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

		-- Copy the temp table to the actual table
		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('inserting into req table from gtmp table');
		END IF;

		INSERT INTO gmf_batch_requirements(
			vib_id,
			batch_id,
			product_item_id,
			prod_material_detail_id,
			ingredient_item_id,
			ing_material_detail_id,
			resources,
			batchstep_resource_id,
			derived_cost_alloc,
			required_doc_qty,
			delete_mark,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			requirement_id,
			organization_id,
			vib_profile_value)
		SELECT
			NULL,
			batch_id,
			product_item_id,
			prod_material_detail_id,
			ingredient_item_id,
			ing_material_detail_id,
			resources,
			batchstep_resource_id,
			derived_cost_alloc,
			required_doc_qty,
			delete_mark,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			requirement_id,
			organization_id,
			vib_profile_value
		FROM gmf_batch_requirements_gtmp
		WHERE batch_id = p_batch_id;

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
		END IF;
	END IF;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Create_Batch_Requirements;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Update_Batch_Requirements                                             |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Update_Batch_Requirements                                             |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
*/
PROCEDURE Update_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

l_count		PLS_INTEGER;
l_api_name	VARCHAR2(30) := 'Update_Batch_Requirements';
BEGIN

  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('calling Create_Temp_Batch_Requirements');
	END IF;

	Create_Temp_Batch_Requirements (
		p_api_version,
		p_init_msg_list,
		p_batch_id,
		x_return_status,
		x_msg_count,
		x_msg_data);

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('after Create_Temp_Batch_Requirements status/msg: ' || x_return_status ||'/'||x_msg_data);
	END IF;

	IF (x_return_status = FND_API.G_RET_STS_SUCCESS) THEN

		UPDATE gmf_batch_requirements
		SET    delete_mark = 1
		WHERE
			batch_id = p_batch_id;


		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('inserting into req table from gtmp');
		END IF;

		INSERT INTO gmf_batch_requirements(
			vib_id,
			batch_id,
			product_item_id,
			prod_material_detail_id,
			ingredient_item_id,
			ing_material_detail_id,
			resources,
			batchstep_resource_id,
			derived_cost_alloc,
			required_doc_qty,
			delete_mark,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			requirement_id,
			organization_id,
			vib_profile_value)
		SELECT
			NULL,
			batch_id,
			product_item_id,
			prod_material_detail_id,
			ingredient_item_id,
			ing_material_detail_id,
			resources,
			batchstep_resource_id,
			derived_cost_alloc,
			required_doc_qty,
			delete_mark,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			requirement_id,
			organization_id,
			vib_profile_value
		FROM gmf_batch_requirements_gtmp;

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
		END IF;
	END IF;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END Update_Batch_Requirements;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Delete_Batch_Requirements                                             |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Delete_Batch_Requirements                                             |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
*/
PROCEDURE Delete_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

l_batch_status 	gme_batch_header.batch_status%TYPE;
l_api_name	VARCHAR2(30) := 'Delete_Batch_Requirements';
BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	-- Validate batch_id
	BEGIN
		SELECT batch_status
		INTO l_batch_status
		FROM gme_batch_header
		WHERE batch_id = p_batch_id;

		IF l_batch_status <> 1 THEN
			x_return_status := FND_API.G_RET_STS_ERROR ;
			dbms_output.put_line ('Batch is not in PENDING Status');
			FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_NOT_PENDING');
			FND_MSG_PUB.Add;
			RETURN;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			FND_MESSAGE.SET_NAME('GMF', 'G_RET_STS_UNEXP_ERROR');
			FND_MSG_PUB.Add;
			RAISE;
	END;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('deleting batch reqs');
	END IF;

	UPDATE gmf_batch_requirements
	SET    delete_mark = 1
	WHERE
		batch_id = p_batch_id AND
		delete_mark = 0;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows deleted');
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_Temp_Batch_Requirements                                        |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create_Temp_Batch_Requirements                                        |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|   rseshadr 01-May-2006 Bug 5190115 - use nvl for cost_alloc as some prod |
--|     rows can have null alloc value                                       |
--|                                                                          |
--|   vchukkap 21-Sep-2006   bug 5491419 - batch requirements are not getting|
--|     created for closed batches during migration. Only creating for       |
--|     batches with status: wip or completed (2 and 3). Included status 4.    |
--|                                                                          |
--|   Pramod B.H 25-Aug-2008  Bug 6125370 - While releasing a batch, additional|
--|     check is performed to verify if the batch contains at least one      |
--|     product line with both non-zero planned qty and non-zero cost        |
--|     allocation factor. If no such product line exists then the process   |
--|     will raise an error and will stop the batch release activity.        |
--+==========================================================================+
*/
PROCEDURE Create_Temp_Batch_Requirements
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

l_count	PLS_INTEGER; /* Bug 6125370. */
l_gmf_asg_cons_yld_step_lvl	VARCHAR2(30);  /* Bug 8531915 */

CURSOR c_batch_products (c_batch_id	NUMBER) IS
SELECT m.material_detail_id, m.inventory_item_id as item_id, m.organization_id,
	decode(m.plan_qty, 0, nvl(m.wip_plan_qty,0), m.plan_qty) prod_plan_qty,
	m.cost_alloc, s.batchstep_id
FROM gme_material_details m, gme_batch_step_items s
WHERE m.batch_id = c_batch_id AND
	m.line_type = 1 AND
	m.material_detail_id = s.material_detail_id and
	decode(m.plan_qty, 0, m.wip_plan_qty, m.plan_qty) <> 0 and
	nvl(m.cost_alloc,0) <> 0;

CURSOR c_step_dependencies (c_batch_id	NUMBER,  c_batchstep_id NUMBER) IS
 SELECT dep_step_id
FROM GME_BATCH_STEP_DEPENDENCIES
WHERE batch_id = c_batch_id
  AND l_gmf_asg_cons_yld_step_lvl = 'N'
START WITH batchstep_id = c_batchstep_id
CONNECT BY PRIOR dep_step_id = batchstep_id
UNION
SELECT c_batchstep_id dep_step_id FROM DUAL;

CURSOR c_total_prod_alloc (c_batch_id  NUMBER) IS
SELECT ing_material_detail_id, batchstep_resource_id,
	SUM(derived_cost_alloc) total_prod_alloc
FROM gmf_batch_requirements_gtmp
WHERE batch_id = c_batch_id
GROUP BY ing_material_detail_id, batchstep_resource_id;


l_batch_status 	gme_batch_header.batch_status%TYPE;
l_use_item_step_dep	VARCHAR2(30);
l_vib_profile_value	VARCHAR2(30);
l_api_name		VARCHAR2(30) := 'Create_Temp_Batch_Requirements';
BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	-- Validate batch_id
	BEGIN
		SELECT batch_status
		INTO l_batch_status
		FROM gme_batch_header
		WHERE batch_id = p_batch_id;

		/* Bug 5491419. Added status 4.
		IF l_batch_status not in (2, 3) THEN
		*/
		/* Bug 9441550 . Added status -1.  */
		IF l_batch_status not in (-1,2, 3, 4) THEN
			-- x_return_status := FND_API.G_RET_STS_ERROR ;
			dbms_output.put_line ('Batch is not in WIP/Cert/Close Status');
			-- FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_NOT_WIP');
			-- FND_MSG_PUB.Add;
			x_return_status := FND_API.G_RET_STS_SUCCESS ;
			RETURN;
		END IF;

                /* Bug 6125370 - Start: Validate product lines*/
                l_count := 0;
		SELECT count(*)
		INTO l_count
                FROM gme_material_details m
		WHERE m.batch_id = p_batch_id AND
		m.line_type = 1 AND
		decode(m.plan_qty, 0, m.wip_plan_qty, m.plan_qty) <> 0 AND
		nvl(m.cost_alloc,0) <> 0;

		IF l_count = 0 THEN
			x_return_status := FND_API.G_RET_STS_ERROR;
			FND_MESSAGE.SET_NAME('GMF', 'GMF_INVALID_BATCH');
			FND_MSG_PUB.Add;
			RETURN;
		END IF;
                /* Bug 6125370 - End */
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			dbms_output.put_line ('Invalid Batch ID');
			FND_MESSAGE.SET_NAME('GMF', 'G_RET_STS_UNEXP_ERROR');
			FND_MSG_PUB.Add;
			RAISE;
	END;

	l_use_item_step_dep := fnd_profile.value ('GMF_USE_ITEM_STEP_DEPENDENCIES');
	IF (l_use_item_step_dep IS NULL) THEN
		l_use_item_step_dep := 'N';
	END IF;

	l_vib_profile_value := fnd_profile.value ('GMF_USE_VIB_FOR_ACOST');
	IF (l_vib_profile_value IS NULL) THEN
		l_vib_profile_value := 'N';
	END IF;

	gme_debug.put_line ('profiles. step_dep: ' || l_use_item_step_dep || ' vib: ' || l_vib_profile_value);

	-- Delete the temp table first
	DELETE from gmf_batch_requirements_gtmp;

	-- Get all products and step association
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('Get all products and step association');
	END IF;

	IF l_use_item_step_dep = 'Y' THEN

	        -- Bug 8531915 Use profile GMF_ASG_CONS_YLD_STEP_LVL
	        l_gmf_asg_cons_yld_step_lvl := fnd_profile.value ('GMF_ASG_CONS_YLD_STEP_LVL');
	        IF (l_gmf_asg_cons_yld_step_lvl IS NULL) THEN
		    l_gmf_asg_cons_yld_step_lvl := 'N';
	        END IF;

		FOR p IN c_batch_products(p_batch_id)
		LOOP
			-- Get all dependant steps for the product step
			FOR ds IN c_step_dependencies (p_batch_id,  p.batchstep_id)
			LOOP
				-- insert records into the batch requirements table
				INSERT INTO gmf_batch_requirements_gtmp(
					vib_id,
					batch_id,
					product_item_id,
					prod_material_detail_id,
					ingredient_item_id,
					ing_material_detail_id,
					resources,
					batchstep_resource_id,
					derived_cost_alloc,
					required_doc_qty,
					delete_mark,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
					requirement_id,
					organization_id,
					vib_profile_value)
				SELECT
					NULL,
					p_batch_id,
					p.item_id,
					p.material_detail_id,
					m.inventory_item_id,
					m.material_detail_id,
					NULL,
					NULL,
					p.cost_alloc,
					p.cost_alloc * ( decode(m.plan_qty, 0, nvl(m.wip_plan_qty,0), m.plan_qty) /
							p.prod_plan_qty),
					0,
					-1,
					sysdate,
					-1,
					sysdate,
					NULL,
					gmf_vib_id_s.nextval,
					p.organization_id,
					l_vib_profile_value
				FROM gme_batch_step_items s,
					gme_material_details m
				WHERE batchstep_id = ds.dep_step_id AND
					s.material_detail_id = m.material_detail_id AND
					m.line_type <> 1;

				INSERT INTO gmf_batch_requirements_gtmp(
					vib_id,
					batch_id,
					product_item_id,
					prod_material_detail_id,
					ingredient_item_id,
					ing_material_detail_id,
					resources,
					batchstep_resource_id,
					derived_cost_alloc,
					required_doc_qty,
					delete_mark,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
					requirement_id,
					organization_id,
					vib_profile_value)
				SELECT
					NULL,
					p_batch_id,
					p.item_id,
					p.material_detail_id,
					NULL,
					NULL,
					m.resources,
					m.batchstep_resource_id,
					p.cost_alloc,
					p.cost_alloc * ( nvl(m.plan_rsrc_usage,0) / p.prod_plan_qty),
					0,
					-1,
					sysdate,
					-1,
					sysdate,
					NULL,
					gmf_vib_id_s.nextval,
					p.organization_id,
					l_vib_profile_value
				FROM gme_batch_step_resources m
				WHERE batchstep_id = ds.dep_step_id;

			END LOOP;
		END LOOP;
	END IF;

	-- Now insert any remaining ing/res which was not used for any product
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('Now insert any remaining ingredients which was not used for any product...');
	END IF;

	INSERT INTO gmf_batch_requirements_gtmp(
		vib_id,
		batch_id,
		product_item_id,
		prod_material_detail_id,
		ingredient_item_id,
		ing_material_detail_id,
		resources,
		batchstep_resource_id,
		derived_cost_alloc,
		required_doc_qty,
		delete_mark,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		requirement_id,
		organization_id,
		vib_profile_value)
	SELECT
		NULL,
		p_batch_id,
		p.inventory_item_id,
		p.material_detail_id,
		i.inventory_item_id,
		i.material_detail_id,
		NULL,
		NULL,
		p.cost_alloc,
		p.cost_alloc * ( decode(i.plan_qty, 0, nvl(i.wip_plan_qty,0), i.plan_qty) /
				 decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty)),
		0,
		-1,
		sysdate,
		-1,
		sysdate,
		NULL,
		gmf_vib_id_s.nextval,
		p.organization_id,
		l_vib_profile_value
	FROM gme_material_details p, gme_material_details i
	WHERE
		p.batch_id = p_batch_id AND
		i.batch_id = p_batch_id AND
		p.line_type = 1 AND
		decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty) <> 0 AND
		nvl(p.cost_alloc,0) <> 0 AND
		i.line_type <> 1 AND
		i.material_detail_id NOT IN (
			SELECT nvl(ing_material_detail_id, -99)
			FROM gmf_batch_requirements_gtmp f
			WHERE
				batch_id = p_batch_id );

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	  gme_debug.put_line ('Now insert any remaining resources which was not used for any product...');
	END IF;


	INSERT INTO gmf_batch_requirements_gtmp(
		vib_id,
		batch_id,
		product_item_id,
		prod_material_detail_id,
		ingredient_item_id,
		ing_material_detail_id,
		resources,
		batchstep_resource_id,
		derived_cost_alloc,
		required_doc_qty,
		delete_mark,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		requirement_id,
		organization_id,
		vib_profile_value)
	SELECT
		NULL,
		p_batch_id,
		p.inventory_item_id,
		p.material_detail_id,
		NULL,
		NULL,
		r.resources,
		r.batchstep_resource_id,
		p.cost_alloc,
		p.cost_alloc * ( nvl(r.plan_rsrc_usage,0) /
				 decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty)),
		0,
		-1,
		sysdate,
		-1,
		sysdate,
		NULL,
		gmf_vib_id_s.nextval,
		p.organization_id,
		l_vib_profile_value
	FROM gme_material_details p, gme_batch_step_resources r
	WHERE
		p.batch_id = p_batch_id AND
		r.batch_id = p_batch_id AND
		p.line_type = 1 AND
		decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty) <> 0 AND
		nvl(p.cost_alloc,0) <> 0 AND
		r.batchstep_resource_id NOT IN (
			SELECT nvl(batchstep_resource_id, -99)
			FROM gmf_batch_requirements_gtmp f
			WHERE
				batch_id = p_batch_id );

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	END IF;

	-- Now insert any product that may have been missed out
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('Now insert any product that may have been missed out...');
	END IF;

	INSERT INTO gmf_batch_requirements_gtmp(
		vib_id,
		batch_id,
		product_item_id,
		prod_material_detail_id,
		ingredient_item_id,
		ing_material_detail_id,
		resources,
		batchstep_resource_id,
		derived_cost_alloc,
		required_doc_qty,
		delete_mark,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		requirement_id,
		organization_id,
		vib_profile_value)
	SELECT
		NULL,
		p_batch_id,
		p.inventory_item_id,
		p.material_detail_id,
		i.inventory_item_id,
		i.material_detail_id,
		NULL,
		NULL,
		p.cost_alloc,
		p.cost_alloc * ( decode(i.plan_qty, 0, nvl(i.wip_plan_qty,0), i.plan_qty) /
				 decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty)),
		0,
		-1,
		sysdate,
		-1,
		sysdate,
		NULL,
		gmf_vib_id_s.nextval,
		p.organization_id,
		l_vib_profile_value
	FROM gme_material_details p, gme_material_details i
	WHERE
		p.batch_id = p_batch_id AND
		i.batch_id = p_batch_id AND
		p.line_type = 1 AND
		decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty) <> 0 AND
		nvl(p.cost_alloc,0) <> 0 AND
		i.line_type <> 1 AND
		p.material_detail_id NOT IN (
			SELECT prod_material_detail_id
			FROM gmf_batch_requirements_gtmp f
			WHERE
				batch_id = p_batch_id );
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	END IF;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('inserting remaining resources');
	END IF;
	INSERT INTO gmf_batch_requirements_gtmp(
		vib_id,
		batch_id,
		product_item_id,
		prod_material_detail_id,
		ingredient_item_id,
		ing_material_detail_id,
		resources,
		batchstep_resource_id,
		derived_cost_alloc,
		required_doc_qty,
		delete_mark,
		created_by,
		creation_date,
		last_updated_by,
		last_update_date,
		last_update_login,
		requirement_id,
		organization_id,
		vib_profile_value)
	SELECT
		NULL,
		p_batch_id,
		p.inventory_item_id,
		p.material_detail_id,
		NULL,
		NULL,
		r.resources,
		r.batchstep_resource_id,
		p.cost_alloc,
		p.cost_alloc * ( nvl(r.plan_rsrc_usage,0) /
				 decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty)),
		0,
		-1,
		sysdate,
		-1,
		sysdate,
		NULL,
		gmf_vib_id_s.nextval,
		p.organization_id,
		l_vib_profile_value
	FROM gme_material_details p, gme_batch_step_resources r
	WHERE
		p.batch_id = p_batch_id AND
		r.batch_id = p_batch_id AND
		p.line_type = 1 AND
		decode(p.plan_qty, 0, p.wip_plan_qty, p.plan_qty) <> 0 AND
		nvl(p.cost_alloc,0) <> 0 AND
		p.material_detail_id NOT IN (
			SELECT prod_material_detail_id
			FROM gmf_batch_requirements_gtmp f
			WHERE
				batch_id = p_batch_id );

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	END IF;


	-- Now update the derived cost alloc and required doc qty
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('Now updating the derived cost alloc and required doc qty ...');
	END IF;

	FOR i IN c_total_prod_alloc(p_batch_id) LOOP
	BEGIN
		UPDATE gmf_batch_requirements_gtmp
		SET 	derived_cost_alloc = derived_cost_alloc/i.total_prod_alloc,
			required_doc_qty = required_doc_qty/i.total_prod_alloc
		WHERE
			batch_id = p_batch_id AND
			nvl(ing_material_detail_id, -1) = nvl(i.ing_material_detail_id,-1) AND
			nvl(batchstep_resource_id, -1) = nvl(i.batchstep_resource_id,-1) AND
			delete_mark = 0;
	        dbms_output.put_line( sql%rowcount || ' rows inserted');
	EXCEPTION
		WHEN OTHERS THEN
			dbms_output.put_line ('Error updating batch requirements');
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			RAISE;
	END;
	END LOOP;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('Done updating the derived cost alloc and required doc qty ...');
	END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
End Create_Temp_Batch_Requirements;


/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Create_VIB_Details                                                    |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Create_VIB_Details                                                    |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|   rseshadr 01-May-2006 Bug 5190115 - e_invalid_rsrc_reversal was raised  |
--|     but the catch block did not handle this exception                    |
--|                                                                          |
--|   umoogala 21-Oct-2006   bug 5607069 -                                   |
--|      Issue 1) Material and Resources reversals layers were not getting   |
--|               consumed.                                                  |
--|               Fixed code to allocate reversals only if its original      |
--|               layer is consumed by this product, while creating VIB dtls.|
--|      Issue 2) Material and Resources reversals layers were not getting   |
--|               properly apportioned in the finalization layers.           |
--|               Fix is same as above:                                      |
--|               Fixed code to allocate reversals only if its original      |
--|               layer is consumed by this product, while creating VIB dtls.|
--| pmarada 22-Aug-2007 Bug 6312166. Currently we are not inserting records  |
--|              in VIB when reverse the batch. as part of this fix we are   |
--|              going to insert records in VIB for reversal of bacth        |
--+==========================================================================+
*/
PROCEDURE Create_VIB_Details
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_tran_rec      IN          GMF_LAYERS.trans_rec_type,
  p_layer_rec     IN          gmf_incoming_material_layers%ROWTYPE,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2
) IS

CURSOR c_batch_req IS
SELECT *
FROM gmf_batch_requirements
WHERE
	batch_id = p_tran_rec.transaction_source_id AND
	prod_material_detail_id = p_tran_rec.trx_source_line_id AND
	delete_mark = 0;

CURSOR c_orig_mtl_vib IS
SELECT v.consume_layer_id, v.consume_layer_date, v.line_type, v.requirement_id, v.consume_ib_doc_qty,
       v.consume_ib_pri_qty,
       decode (tp.transaction_id2, NULL, ol.layer_id, ol2.layer_id) c_layer_id,
       decode (tp.transaction_id2, NULL, v.consume_layer_date, t2.transaction_date) c_trans_date,
       decode (tp.transaction_id2, NULL, ol.remaining_ib_doc_qty, ol2.remaining_ib_doc_qty) remaining_ib_doc_qty,
       decode (tp.transaction_id2, NULL, ol.layer_doc_qty, ol2.layer_doc_qty) layer_doc_qty,
       decode (tp.transaction_id2, NULL, 'N', 'Y') c_rev_layer,
       decode (tp.transaction_id2, NULL, ol.ROWID, ol2.ROWID) c_rowid
FROM gmf_batch_vib_details v,
        gmf_incoming_material_layers il,
        gmf_outgoing_material_layers ol,
        mtl_material_transactions t,
        gme_transaction_pairs tp,
        gmf_outgoing_material_layers ol2,
        mtl_material_transactions t2
WHERE
        il.mmt_transaction_id = p_tran_rec.reverse_id AND -- incoming layer of reversed prod yield
        -- Bug 6312166. il.mmt_transaction_id = p_tran_rec.transaction_id AND -- incoming layer of reversed prod yield
        nvl(il.lot_number, 'x')  = nvl(p_tran_rec.lot_number, 'x') AND
        -- Bug 6312166. il.lot_number (+) = p_tran_rec.lot_number AND
        v.prod_layer_id = il.layer_id AND                -- VIB details of above reversed layer
        v.line_type <> 0 AND                             -- material only
        ol.layer_id (+) = v.consume_layer_id AND         -- getting consumption layer for above reversed prod yield
        t.transaction_id (+) = ol.mmt_transaction_id AND -- getting txn for above consumption layer
        --
        -- below 4 lines, get the above ingredient reversals, if any
        --
        tp.transaction_id1 (+) = t.transaction_id AND
        tp.pair_type(+) = 1 AND
        ol2.mmt_transaction_id (+) = tp.transaction_id2 AND
        t2.transaction_id (+) = ol2.mmt_transaction_id
;


CURSOR c_orig_rsrc_vib IS
SELECT v.consume_layer_id, v.consume_layer_date, v.line_type, v.requirement_id, v.consume_ib_doc_qty,
       v.consume_ib_pri_qty, decode (t.reverse_id, NULL, ol.layer_id, ol2.layer_id) c_layer_id,
       decode (t.reverse_id, NULL, v.consume_layer_date, t2.trans_date) c_trans_date,
       decode (t.reverse_id, NULL, ol.remaining_ib_doc_qty, ol2.remaining_ib_doc_qty) remaining_ib_doc_qty,
       decode (t.reverse_id, NULL, ol.layer_doc_qty, ol2.layer_doc_qty) layer_doc_qty,
       decode (t.reverse_id, NULL, 'N', 'Y') c_rev_layer,
       decode (t.reverse_id, NULL, ol.ROWID, ol2.ROWID) c_rowid
FROM gmf_batch_vib_details v,
        gmf_incoming_material_layers il,
        gmf_resource_layers ol,
        gme_resource_txns t,
        gmf_resource_layers ol2,
        gme_resource_txns t2
WHERE
        il.mmt_transaction_id = p_tran_rec.reverse_id AND
        nvl(il.lot_number, '@@@') = nvl(p_tran_rec.lot_number, '@@@') AND
        v.prod_layer_id = il.layer_id AND
        v.line_type = 0 AND -- resource only
        v.consume_layer_id = ol.layer_id (+) AND
        ol.poc_trans_id = t.poc_trans_id (+) AND
        t.reverse_id = ol2.poc_trans_id (+) AND
        ol2.poc_trans_id = t2.poc_trans_id (+);

/* Bug 8219507 removed mtln from query */

CURSOR c_ing_layers (p_ing_material_detail_id	NUMBER) IS
SELECT mmt.inventory_item_id, mmt.organization_id, /* mtln.lot_number, */ mmt.primary_quantity, msi.primary_uom_code,
       mmt.transaction_date, md.line_type, tp.transaction_id2 as reverse_id, l.ROWID, l.*
FROM gmf_outgoing_material_layers l,
	mtl_material_transactions mmt,
        mtl_system_items_b msi,
        gme_material_details md,
        gme_transaction_pairs tp
WHERE
	mmt.transaction_source_type_id = 5 AND
	mmt.transaction_source_id =  p_tran_rec.transaction_source_id AND
	mmt.trx_source_line_id    =  p_ing_material_detail_id AND
	l.mmt_transaction_id      =  mmt.transaction_id AND
	l.delete_mark             =  0 AND
	l.remaining_ib_doc_qty    <> 0 AND
        msi.inventory_item_id     =  mmt.inventory_item_id AND
        msi.organization_id       =  mmt.organization_id AND
        md.material_detail_id     =  p_ing_material_detail_id AND
        tp.transaction_id1(+)     =  mmt.transaction_id AND
        tp.pair_type(+)           =  1
ORDER BY mmt.transaction_date;

CURSOR c_ing_layers_cnt (p_ing_material_detail_id	NUMBER) IS -- Bug 8472152 Added cursor
SELECT count(*)
FROM gmf_outgoing_material_layers l,
	mtl_material_transactions mmt,
        mtl_system_items_b msi,
        gme_material_details md,
        gme_transaction_pairs tp
WHERE
	mmt.transaction_source_type_id = 5 AND
	mmt.transaction_source_id =  p_tran_rec.transaction_source_id AND
	mmt.trx_source_line_id    =  p_ing_material_detail_id AND
	l.mmt_transaction_id      =  mmt.transaction_id AND
	l.delete_mark             =  0 AND
	l.remaining_ib_doc_qty    <> 0 AND
        msi.inventory_item_id     =  mmt.inventory_item_id AND
        msi.organization_id       =  mmt.organization_id AND
        md.material_detail_id     =  p_ing_material_detail_id AND
        tp.transaction_id1(+)     =  mmt.transaction_id AND
        tp.pair_type(+)           =  1
ORDER BY mmt.transaction_date;


CURSOR c_rsrc_layers (p_batchstep_resource_id	NUMBER) IS
SELECT p.resource_usage, p.trans_qty_um as trans_um, p.trans_date, p.line_type, p.reverse_id, p.organization_id, l.ROWID, l.*
FROM gmf_resource_layers l, gme_resource_txns p
WHERE
	p.doc_type = 'PROD' AND
	p.doc_id = p_tran_rec.transaction_source_id AND
	p.line_id = p_batchstep_resource_id AND
	p.completed_ind = 1 AND
	p.delete_mark = 0 AND
	l.poc_trans_id = p.poc_trans_id and
	l.delete_mark = 0 and
	l.remaining_ib_doc_qty <> 0
ORDER BY p.trans_date;

l_required_ib_doc_qty		NUMBER;
l_remaining_ib_doc_qty		NUMBER;
l_consume_ib_doc_qty		NUMBER;
l_consume_ib_pri_qty		NUMBER;
l_rev_consume_ib_doc_qty	NUMBER;
l_cur_consume_ib_doc_qty	NUMBER;
l_prev_consume_ib_doc_qty	NUMBER;
l_doc_um			VARCHAR2(4);
l_line_type			PLS_INTEGER;
l_item_um			VARCHAR2(4);
l_use_vib			VARCHAR2(30);
l_count				PLS_INTEGER;
l_orig_layer_consumption_qty NUMBER; -- Bug 5607069
l_ing_count			NUMBER; --  Bug 8472152
l_curr_cnt			NUMBER; --  Bug 8472152


e_vib_complete			EXCEPTION;
e_invalid_consumption		EXCEPTION;
e_invalid_mtl_reversal		EXCEPTION;
e_invalid_rsrc_reversal		EXCEPTION;
e_rsrc_invalid_consumption	EXCEPTION;

l_api_name	VARCHAR2(30) := 'Create_VIB_Details';

BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	-- Validate that the VIB details do not exist already
	SELECT count(*)
	INTO l_count
	FROM gmf_batch_vib_details
	WHERE
		prod_layer_id = p_layer_rec.layer_id;

	IF l_count > 0 THEN
		x_return_status := FND_API.G_RET_STS_ERROR ;
		x_msg_data := 'VIB Details already exist';
		dbms_output.put_line ('VIB Details already exist');
		FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_VIB_EXIST');
		FND_MSG_PUB.Add;
		RETURN;
	END IF;

	l_use_vib := FND_PROFILE.VALUE ('GMF_USE_VIB_FOR_ACOST');
	IF l_use_vib IS NULL THEN
		l_use_vib := 'N';
	END IF;

	gme_debug.put_line ('Profile...Use VIB = '||l_use_vib);


	-- If this is a product reversal, reverse the VIB layers.
	IF p_tran_rec.primary_quantity < 0 and p_tran_rec.reverse_id IS NOT NULL THEN

		IF g_debug <= gme_debug.g_log_procedure THEN
		  gme_debug.put_line ('product reversal, reverse the VIB layers');
		END IF;

		IF g_debug <= gme_debug.g_log_procedure THEN
		  gme_debug.put_line ('now reversing material vib layers');
		END IF;

		FOR v IN c_orig_mtl_vib LOOP
		BEGIN
			-- For No VIB, the ingredient reversals may already have been consumed
			-- by a previous prod yield. In that case, do not reverse anymore.:w
			IF l_use_vib = 'N' and v.c_rev_layer = 'Y' and
			    v.layer_doc_qty <> v.remaining_ib_doc_qty
			THEN

				SELECT count (1)
				INTO l_count
				FROM gmf_batch_vib_details vib,
					gmf_batch_requirements r
				WHERE
					r.batch_id = p_tran_rec.transaction_source_id AND
					r.prod_material_detail_id = p_tran_rec.trx_source_line_id AND
					vib.requirement_id = r.requirement_id AND
					vib.consume_layer_id = v.c_layer_id;

				IF l_count > 0 THEN
					IF g_debug <= gme_debug.g_log_statement THEN
					  gme_debug.put_line ('No VIB, the ingredient reversals may already have ' ||
					  			'been consumed by a previous prod yield. do not reverse anymore.');
					END IF;

					RAISE e_invalid_mtl_reversal;
				END IF;
			END IF;

			-- Insert VIB reversals
			INSERT INTO gmf_batch_vib_details(
				prod_layer_id,
				prod_layer_pri_qty,
				consume_layer_id,
				consume_layer_date,
				line_type,
				vib_id,
				finalize_ind,
				consume_ib_doc_qty,
				consume_ib_pri_qty,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				requirement_id)
			VALUES(
				p_layer_rec.layer_id,
				p_tran_rec.primary_quantity,
				v.c_layer_id,
				v.c_trans_date,
				v.line_type,
				NULL,
				0,
				-v.consume_ib_doc_qty,
				-v.consume_ib_pri_qty,
				p_tran_rec.created_by,
				sysdate,
				p_tran_rec.last_updated_by,
				sysdate,
				p_tran_rec.last_update_login,
				v.requirement_id);

			UPDATE gmf_outgoing_material_layers
			SET remaining_ib_doc_qty = remaining_ib_doc_qty + v.consume_ib_doc_qty
			WHERE
				ROWID = v.c_rowid;

		EXCEPTION
			WHEN e_invalid_mtl_reversal THEN
				NULL; -- Skip to next row
		END;
		END LOOP;

		IF g_debug <= gme_debug.g_log_procedure THEN
		  gme_debug.put_line ('now reversing resource vib layers');
		END IF;

		FOR v IN c_orig_rsrc_vib LOOP
		BEGIN
			-- For No VIB, the resource reversals may already have been consumed
			-- by a previous prod yield. In that case, do not reverse anymore.:w
			IF l_use_vib = 'N' and v.c_rev_layer = 'Y' and
			    v.layer_doc_qty <> v.remaining_ib_doc_qty
			THEN

				SELECT count (1)
				INTO l_count
				FROM gmf_batch_vib_details vib,
					gmf_batch_requirements r
				WHERE
					r.batch_id = p_tran_rec.transaction_source_id AND
					r.prod_material_detail_id = p_tran_rec.trx_source_line_id AND
					vib.requirement_id = r.requirement_id AND
					vib.consume_layer_id = v.c_layer_id;

				IF l_count > 0 THEN
					IF g_debug <= gme_debug.g_log_statement THEN
					  gme_debug.put_line ('No VIB, the resource reversals may already have ' ||
					  			'been consumed by a previous prod yield. do not reverse anymore.');
					END IF;

					RAISE e_invalid_rsrc_reversal;
				END IF;
			END IF;

			-- Insert VIB reversals
			INSERT INTO gmf_batch_vib_details(
				prod_layer_id,
				prod_layer_pri_qty,
				consume_layer_id,
				consume_layer_date,
				line_type,
				vib_id,
				finalize_ind,
				consume_ib_doc_qty,
				consume_ib_pri_qty,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				requirement_id)
			VALUES(
				p_layer_rec.layer_id,
				p_tran_rec.primary_quantity,
				v.c_layer_id,
				v.c_trans_date,
				v.line_type,
				NULL,
				0,
				-v.consume_ib_doc_qty,
				-v.consume_ib_pri_qty,
				p_tran_rec.created_by,
				sysdate,
				p_tran_rec.last_updated_by,
				sysdate,
				p_tran_rec.last_update_login,
				v.requirement_id);

			UPDATE gmf_resource_layers
			SET remaining_ib_doc_qty = remaining_ib_doc_qty + v.consume_ib_doc_qty
			WHERE
				ROWID = v.c_rowid;

		EXCEPTION
			WHEN e_invalid_rsrc_reversal THEN
				NULL; -- Skip to next row
		END;
		END LOOP;
		RETURN; -- Done with the reversal
	END IF;

	-- For regular yields follow the following logic.
	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('regular product yield');
	END IF;


	-- Go through the batch requirement rows for this product and insert
	-- the VIB details in the vib table.
	FOR req IN c_batch_req LOOP
	BEGIN
		l_required_ib_doc_qty := p_layer_rec.layer_doc_qty * req.required_doc_qty;

		-- If the VIB details are for ingredient or by-product
		IF req.ing_material_detail_id IS NOT NULL THEN
			-- select ingredient layers that can be consumed for the
			-- IB qty

			IF g_debug <= gme_debug.g_log_statement THEN
			  gme_debug.put_line ('processing ingredient or by-product to create vib details');
			END IF;

			-- Loop for all layers of an ingredient PK Bug 8472152

                        OPEN c_ing_layers_cnt(req.ing_material_detail_id);
                        FETCH c_ing_layers_cnt INTO l_ing_count;
                        CLOSE c_ing_layers_cnt;

                        l_curr_cnt := 0;

			FOR ing in c_ing_layers(req.ing_material_detail_id) LOOP
			BEGIN
                                l_curr_cnt := l_curr_cnt + 1; -- Bug 8472152
				IF g_debug <= gme_debug.g_log_statement THEN
				  gme_debug.put_line ('consuming ing/byProd layer. matl_dtl_id: ' || req.ing_material_detail_id ||
				  			' consume layer_id: ' ||ing.layer_id );
				END IF;

				IF l_use_vib = 'Y' THEN
					l_remaining_ib_doc_qty := ing.remaining_ib_doc_qty;

					IF l_required_ib_doc_qty = 0 THEN
						RAISE e_vib_complete;
					END IF;
	                                -- Bug 8472152 Remaining quantity could be negative No exception
				/*	IF  l_remaining_ib_doc_qty <= 0 THEN
						RAISE e_invalid_consumption;
					END IF;

					IF l_remaining_ib_doc_qty >= l_required_ib_doc_qty THEN
						l_consume_ib_doc_qty := l_required_ib_doc_qty;
					ELSE
						l_consume_ib_doc_qty := l_remaining_ib_doc_qty;
					END IF;

					l_remaining_ib_doc_qty := l_remaining_ib_doc_qty - l_consume_ib_doc_qty;
					l_required_ib_doc_qty := l_required_ib_doc_qty - l_consume_ib_doc_qty;  */

					-- Bug 8472152 modified  Code should do following
				        -- 1) Available for record > required  then use required
				        -- 2) Available for record < required and more records present then use what is available.
				        -- 3) If last record use all that is required.

				        IF ((l_remaining_ib_doc_qty >= l_required_ib_doc_qty) OR (l_ing_count = l_curr_cnt)) THEN
				           l_consume_ib_doc_qty := l_required_ib_doc_qty;
				        ELSE
				           l_consume_ib_doc_qty := l_remaining_ib_doc_qty;
				        END IF;

					l_remaining_ib_doc_qty := l_remaining_ib_doc_qty - l_consume_ib_doc_qty;
					l_required_ib_doc_qty := l_required_ib_doc_qty - l_consume_ib_doc_qty;


				ELSE
					IF ing.remaining_ib_doc_qty = 0 THEN
						RAISE e_invalid_consumption;
					END IF;

					l_consume_ib_doc_qty := ing.layer_doc_qty * req.derived_cost_alloc;
					-- Get the quantity already consumed from this player for the product.
					-- If the entire quantity is remaining, no need to check.
					IF ing.layer_doc_qty <> ing.remaining_ib_doc_qty THEN
						SELECT nvl(sum (consume_ib_doc_qty), 0)
						INTO l_prev_consume_ib_doc_qty
						FROM gmf_batch_vib_details v,
							gmf_batch_requirements r
						WHERE
							r.batch_id = p_tran_rec.transaction_source_id AND
							r.prod_material_detail_id = p_tran_rec.trx_source_line_id AND
							v.requirement_id = r.requirement_id AND
							v.consume_layer_id = ing.layer_id;

						--
						-- Bug 5607069: If this is the reversal layer, then see whether original
						-- reversed layerd is consumed by this product or not.
						-- If consumed, then consume from this reversal layer to nullify the effect of it.
						-- If not consumed, then don't consume from this reversal layer.
						--
						IF ing.reverse_id IS NOT NULL
						THEN
						  SELECT nvl(sum (consume_ib_doc_qty), 0)
						  INTO l_orig_layer_consumption_qty
						  FROM gmf_outgoing_material_layers ol,
						       gmf_batch_vib_details v,
						       gmf_batch_requirements r
						  WHERE
						  	ol.mmt_transaction_id = ing.reverse_id AND
						  	v.consume_layer_id = ol.layer_id AND
						  	r.batch_id = p_tran_rec.transaction_source_id AND
						  	r.prod_material_detail_id = p_tran_rec.trx_source_line_id AND
						  	v.requirement_id = r.requirement_id ;

						  IF l_orig_layer_consumption_qty = 0
						  THEN
							-- Do not consume from this reversal layers, as its original
							-- layer is not consumed by this product.
							RAISE e_rsrc_invalid_consumption;
						  END IF;

						END IF;
						-- End bug 5607069

						l_consume_ib_doc_qty := l_consume_ib_doc_qty - l_prev_consume_ib_doc_qty;
						IF ABS(l_consume_ib_doc_qty) > ABS(ing.remaining_ib_doc_qty) THEN
							l_consume_ib_doc_qty := ing.remaining_ib_doc_qty;
						END IF;

						IF l_consume_ib_doc_qty = 0 THEN
							-- Previous consumption have already consumed this products share
							RAISE e_invalid_consumption;
						END IF;
					END IF;

					l_remaining_ib_doc_qty := ing.remaining_ib_doc_qty - l_consume_ib_doc_qty;
				END IF;

				-- Convert the l_consume_ib_doc_qty to primary UOM
				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => ing.inventory_item_id
					  , PRECISION     => 5
					  , ORGANIZATION_ID => ing.organization_id
					  , LOT_NUMBER     => ing.lot_number
					  , FROM_QUANTITY => l_consume_ib_doc_qty
					  , FROM_UNIT     => ing.layer_doc_um
					  , TO_UNIT       => ing.primary_uom_code
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);

				INSERT INTO gmf_batch_vib_details(
					prod_layer_id,
					prod_layer_pri_qty,
					consume_layer_id,
					consume_layer_date,
					line_type,
					vib_id,
					finalize_ind,
					consume_ib_doc_qty,
					consume_ib_pri_qty,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
					requirement_id)
				VALUES(
					p_layer_rec.layer_id,
					p_tran_rec.primary_quantity,
					ing.layer_id,
					ing.transaction_date,
					ing.line_type,
					NULL,
					0,
					l_consume_ib_doc_qty,
					l_consume_ib_pri_qty,
					p_tran_rec.created_by,
					sysdate,
					p_tran_rec.last_updated_by,
					sysdate,
					p_tran_rec.last_update_login,
					req.requirement_id);

				UPDATE gmf_outgoing_material_layers
				SET remaining_ib_doc_qty = l_remaining_ib_doc_qty
				WHERE
					ROWID = ing.ROWID;
			EXCEPTION
				WHEN e_invalid_consumption THEN
					NULL; -- Skip to next row
			END;
			END LOOP;
		END IF;

		-- IF the VIB details are for a resource
		IF req.batchstep_resource_id IS NOT NULL THEN
			-- select ingredient layers that can be consumed for the
			-- IB qty
			IF g_debug <= gme_debug.g_log_statement THEN
			  gme_debug.put_line ('processing ingredient or by-product to create vib details');
			END IF;

			FOR rsrc IN c_rsrc_layers(req.batchstep_resource_id) LOOP
			BEGIN
				IF l_use_vib = 'Y' THEN
					l_remaining_ib_doc_qty := rsrc.remaining_ib_doc_qty;

					IF l_required_ib_doc_qty = 0 THEN
						RAISE e_vib_complete;
					END IF;

					-- insert a row in the VIB detail table
					IF  l_remaining_ib_doc_qty = 0 THEN
						RAISE e_rsrc_invalid_consumption;
					END IF;

					-- If both required and remaining are -ve, they work in reverse fashion
					IF l_remaining_ib_doc_qty >= l_required_ib_doc_qty THEN
						l_consume_ib_doc_qty := l_required_ib_doc_qty;
					ELSE
						l_consume_ib_doc_qty := l_remaining_ib_doc_qty;
					END IF;
					l_remaining_ib_doc_qty := l_remaining_ib_doc_qty - l_consume_ib_doc_qty;
					l_required_ib_doc_qty := l_required_ib_doc_qty - l_consume_ib_doc_qty;
				ELSE
					IF rsrc.remaining_ib_doc_qty = 0 THEN
						RAISE e_rsrc_invalid_consumption;
					END IF;

					l_consume_ib_doc_qty := rsrc.layer_doc_qty * req.derived_cost_alloc;
					-- Get the quantity already consumed from this player for the product.
					-- If the entire quantity is remaining, no need to check.
					IF rsrc.layer_doc_qty <> rsrc.remaining_ib_doc_qty THEN
						SELECT nvl(sum (consume_ib_doc_qty), 0)
						INTO l_prev_consume_ib_doc_qty
						FROM gmf_batch_vib_details v,
							gmf_batch_requirements r
						WHERE
							r.batch_id = p_tran_rec.transaction_source_id AND
							r.prod_material_detail_id = p_tran_rec.trx_source_line_id AND
							v.requirement_id = r.requirement_id AND
							v.consume_layer_id = rsrc.layer_id;

						--
						-- Bug 5607069: If this is the reversal layer, then see whether original
						-- reversed layerd is consumed by this product or not.
						-- If consumed, then consume from this reversal layer to nullify the effect of it.
						-- If not consumed, then don't consume from this reversal layer.
						--
						IF rsrc.reverse_id IS NOT NULL
						THEN
						  SELECT nvl(sum (consume_ib_doc_qty), 0)
						  INTO l_orig_layer_consumption_qty
						  FROM gmf_resource_layers rl,
						       gmf_batch_vib_details v,
						       gmf_batch_requirements r
						  WHERE
						  	rl.poc_trans_id = rsrc.reverse_id AND
						  	v.consume_layer_id = rl.layer_id AND
						  	r.batch_id = p_tran_rec.transaction_source_id AND
						  	r.prod_material_detail_id = p_tran_rec.trx_source_line_id AND
						  	v.requirement_id = r.requirement_id ;

						  IF l_orig_layer_consumption_qty = 0
						  THEN
							-- Do not consume from this reversal layers, as its original
							-- layer is not consumed by this product.
							RAISE e_rsrc_invalid_consumption;
						  END IF;

						END IF;
						-- End bug 5607069


						l_consume_ib_doc_qty := l_consume_ib_doc_qty - l_prev_consume_ib_doc_qty;
						--
						-- Bug 5607069: synching material and resource layer code
						--
						IF ABS(l_consume_ib_doc_qty) > ABS(rsrc.remaining_ib_doc_qty) THEN
							l_consume_ib_doc_qty := rsrc.remaining_ib_doc_qty;
						END IF;
						-- End bug 5607069

						--
						-- Bug 5607069: synching material and resource layer code
						--
						-- IF l_consume_ib_doc_qty <= 0 THEN
						--
						IF l_consume_ib_doc_qty = 0 THEN
							-- Previous consumption have already consumed this products share
							RAISE e_rsrc_invalid_consumption;
						END IF;
					END IF;

					l_remaining_ib_doc_qty := rsrc.remaining_ib_doc_qty - l_consume_ib_doc_qty;
				END IF;

				-- Convert the l_consume_ib_doc_qty to primary UOM
				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => 0
					  , PRECISION     => 5
					  , ORGANIZATION_ID => rsrc.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_consume_ib_doc_qty
					  , FROM_UNIT     => rsrc.layer_doc_um
					  , TO_UNIT       => rsrc.trans_um
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);


				INSERT INTO gmf_batch_vib_details(
					prod_layer_id,
					prod_layer_pri_qty,
					consume_layer_id,
					consume_layer_date,
					line_type,
					vib_id,
					finalize_ind,
					consume_ib_doc_qty,
					consume_ib_pri_qty,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
					requirement_id)
				VALUES(
					p_layer_rec.layer_id,
					p_tran_rec.primary_quantity,
					rsrc.layer_id,
					rsrc.trans_date,
					rsrc.line_type,
					NULL,
					0,
					l_consume_ib_doc_qty,
					l_consume_ib_pri_qty,
					p_tran_rec.created_by,
					sysdate,
					p_tran_rec.last_updated_by,
					sysdate,
					p_tran_rec.last_update_login,
					req.requirement_id );

				UPDATE gmf_resource_layers
				SET remaining_ib_doc_qty = l_remaining_ib_doc_qty
				WHERE
					ROWID = rsrc.ROWID;
			EXCEPTION
				WHEN e_rsrc_invalid_consumption THEN
					NULL; -- Skip to next row
			END;
			END LOOP;

		END IF;

		-- There is still some IB quantity not consumed, insert a NULL layer consumption.
		IF l_use_vib = 'Y' and l_required_ib_doc_qty <> 0 THEN

			IF g_debug <= gme_debug.g_log_statement THEN
			  gme_debug.put_line ('inserting NULL consumption layer for matl_dtl_id: ' || req.ing_material_detail_id);
			END IF;

			l_consume_ib_pri_qty := 0;
			IF req.ing_material_detail_id IS NOT NULL THEN

				SELECT m.dtl_um, m.line_type, i.primary_uom_code
				INTO l_doc_um, l_line_type, l_item_um
				FROM gme_material_details m, mtl_system_items_b i
				WHERE
					m.batch_id =  req.batch_id AND
					m.material_detail_id = req.ing_material_detail_id AND
					i.inventory_item_id = m.inventory_item_id AND
					i.organization_id = m.organization_id;

				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => req.ingredient_item_id
					  , PRECISION     => 5
					  , ORGANIZATION_ID => req.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_required_ib_doc_qty
					  , FROM_UNIT     => l_doc_um
					  , TO_UNIT       => l_item_um
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);

			ELSE
				SELECT m.usage_um, 0, r.std_usage_uom  -- Bug 8472152 changed from usage_uom, std_usage_uom
				INTO l_doc_um, l_line_type, l_item_um
				FROM gme_batch_step_resources m, cr_rsrc_mst_b r
				WHERE
					m.batch_id =  req.batch_id AND
					m.batchstep_resource_id = req.batchstep_resource_id AND
					m.resources = r.resources;

				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => 0
					  , PRECISION     => 5
					  , ORGANIZATION_ID => req.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_required_ib_doc_qty
					  , FROM_UNIT     => l_doc_um
					  , TO_UNIT       => l_item_um
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);


			END IF;

			INSERT INTO gmf_batch_vib_details(
				prod_layer_id,
				prod_layer_pri_qty,
				consume_layer_id,
				consume_layer_date,
				line_type,
				vib_id,
				finalize_ind,
				consume_ib_doc_qty,
				consume_ib_pri_qty,
				created_by,
				creation_date,
				last_updated_by,
				last_update_date,
				last_update_login,
				requirement_id)
			VALUES(
				p_layer_rec.layer_id,
				p_tran_rec.primary_quantity,
				NULL,
				p_tran_rec.transaction_date,
				l_line_type,
				NULL,
				0,
				l_required_ib_doc_qty,
				l_consume_ib_pri_qty,
				p_tran_rec.created_by,
				sysdate,
				p_tran_rec.last_updated_by,
				sysdate,
				p_tran_rec.last_update_login,
				req.requirement_id);
		END IF;
	EXCEPTION
		WHEN e_vib_complete THEN
			NULL;
	END;
	END LOOP; -- c_batch_req

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Finalize_VIB_Details                                                  |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Finalize_VIB_Details                                                  |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--|   umoogala 21-Oct-2006   bug 5607069 -                                   |
--|      Issue 1) Material and Resources reversals layers were not getting   |
--|               consumed.                                                  |
--|               Fixed code to allocate reversals only if its original      |
--|               layer is consumed by this product, while creating VIB dtls.|
--|      Issue 2) Material and Resources reversals layers were not getting   |
--|               properly apportioned in the finalization layers.           |
--|               Fix is same as above:                                      |
--|               Fixed code to allocate reversals only if its original      |
--|               layer is consumed by this product, while creating VIB dtls.|
--+==========================================================================+
*/
PROCEDURE Finalize_VIB_Details
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

CURSOR c_batch_req IS
SELECT *
FROM gmf_batch_requirements
WHERE
	batch_id = p_batch_id AND
	delete_mark = 0
ORDER BY prod_material_detail_id;

CURSOR c_null_consume_layers IS
SELECT v.*, l.layer_doc_qty, l.layer_doc_um, l.mmt_transaction_id, l.lot_number, l.mmt_organization_id
FROM gmf_batch_vib_details v,
	gmf_batch_requirements r,
	gmf_incoming_material_layers l
WHERE
	r.batch_id = p_batch_id AND
	v.requirement_id = r.requirement_id AND
	l.layer_id = v.prod_layer_id AND
	v.finalize_ind = 0 AND
	v.consume_layer_id IS NULL
ORDER BY v.prod_layer_id
;

/* Bug 8219507 removed mtln from query */

CURSOR c_last_prod_yield (p_prod_material_detail_id	NUMBER) IS
SELECT l.*, t.primary_quantity,
       t.inventory_item_id -- Bug 5607069
FROM	gmf_incoming_material_layers l,
	mtl_material_transactions t
WHERE
	t.trx_source_line_id         = p_prod_material_detail_id AND
	t.transaction_source_id      = p_batch_id AND
	t.transaction_source_type_id = 5 AND
        l.mmt_transaction_id         = t.transaction_id AND
	l.pseudo_layer_id            IS NULL AND
	not exists (select 'x' from gme_transaction_pairs tp
			where transaction_id1 = t.transaction_id and tp.pair_type = 1)
ORDER BY l.creation_date DESC;

/* Bug 8219507 removed mtln from query */

CURSOR c_remaining_ing_layers (p_ing_material_detail_id	NUMBER) IS
SELECT l.layer_id, l.layer_doc_um, l.remaining_ib_doc_qty, t.inventory_item_id, t.transaction_date,
	NULL lot_number, md.line_type, t.primary_quantity, msi.primary_uom_code, l.ROWID, tp.transaction_id2 as reverse_id,
	l.layer_doc_qty
FROM gmf_outgoing_material_layers l, mtl_material_transactions t,
	gme_material_details md,
	mtl_system_items_b msi, gme_transaction_pairs tp
WHERE
	t.trx_source_line_id    = p_ing_material_detail_id AND
	t.transaction_source_id = p_batch_id AND
	t.transaction_source_type_id = 5 AND
        l.mmt_transaction_id    = t.transaction_id AND
	l.remaining_ib_doc_qty <> 0 AND
	l.delete_mark           = 0 AND
	md.material_detail_id    = p_ing_material_detail_id AND
	msi.inventory_item_id    = t.inventory_item_id AND
	msi.organization_id      = t.organization_id AND
	tp.transaction_id1(+)    = t.transaction_id
;

CURSOR c_remaining_rsrc_layers (p_batchstep_resource_id	NUMBER) IS
SELECT l.layer_id, l.layer_doc_um, l.remaining_ib_doc_qty, t.line_type, t.trans_date,
	t.resource_usage, t.trans_qty_um trans_um, l.ROWID, t.reverse_id, l.layer_doc_qty
FROM gmf_resource_layers l,
	gme_resource_txns t
WHERE
	l.poc_trans_id = t.poc_trans_id AND
	t.line_id = p_batchstep_resource_id AND
	l.remaining_ib_doc_qty <> 0 and
	l.delete_mark = 0;

CURSOR c_finalize_layer_consumption IS
SELECT v.consume_layer_id, v.line_type, sum(v.consume_ib_doc_qty) consume_ib_doc_qty
FROM
	gmf_batch_vib_details v,
	gmf_batch_requirements r
WHERE
	r.batch_id = p_batch_id AND
	v.requirement_id = r.requirement_id AND
	v.finalize_ind = 1 AND
	v.consume_layer_id IS NOT NULL
GROUP BY v.consume_layer_id, v.line_type;

l_batch_status 			gme_batch_header.batch_status%TYPE;
prev_prod_material_detail_id	NUMBER;
l_total_cost_alloc		NUMBER;
l_pseudo_prod_layer_id		NUMBER;
l_last_prod_layer		c_last_prod_yield%ROWTYPE;
l_batch_close_date		DATE;
l_consume_ib_doc_qty 		NUMBER;
l_consume_ib_pri_qty 		NUMBER;
l_remaining_ib_doc_qty 		NUMBER;
l_user_id			NUMBER;
l_count				PLS_INTEGER;
--
-- Bug 5607069: Following 4 variables added
l_use_vib			VARCHAR2(30);
l_orig_layer_consumption_qty NUMBER;
e_invalid_consumption		EXCEPTION;
l_prev_consume_ib_doc_qty	NUMBER;

l_api_name	VARCHAR2(30) := 'Finalize_VIB_Details';

l_prev_prod_layer_id            NUMBER;

BEGIN
  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	-- Validate batch_id
	BEGIN
		SELECT batch_status, last_updated_by, batch_close_date
		INTO l_batch_status, l_user_id, l_batch_close_date
		FROM gme_batch_header
		WHERE batch_id = p_batch_id;

		IF l_batch_status <> 4 THEN
			x_return_status := FND_API.G_RET_STS_ERROR ;
			--dbms_output.put_line ('Batch is not in CLOSE Status');
			FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_NOT_CLOSE');
			FND_MSG_PUB.Add;
			RETURN;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			FND_MESSAGE.SET_NAME('GMF', 'G_RET_STS_UNEXP_ERROR');
			FND_MSG_PUB.Add;
			RAISE;
	END;

	-- Check if he VIB details already exist for this batch
	BEGIN
		SELECT count(*)
		INTO l_count
		FROM gmf_batch_vib_details v,
			gmf_batch_requirements r
		WHERE
			r.batch_id = p_batch_id AND
			r.requirement_id = v.requirement_id and
			v.finalize_ind = 1;

		IF l_count > 0 THEN
			x_return_status := FND_API.G_RET_STS_ERROR ;
			--dbms_output.put_line ('VIB details already exist for this batch');
			FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_FINAL_VIB_EXIST');
			FND_MSG_PUB.Add;
			RETURN;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			FND_MESSAGE.SET_NAME('GMF', 'G_RET_STS_UNEXP_ERROR');
			FND_MSG_PUB.Add;
			RAISE;
	END;


	l_use_vib := FND_PROFILE.VALUE ('GMF_USE_VIB_FOR_ACOST');
	IF l_use_vib IS NULL THEN
		l_use_vib := 'N';
	END IF;

	gme_debug.put_line ('Use VIB = ' || l_use_vib );
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('reversing out all NULL consumptions layers, if any');
	END IF;


	-- reverse out all NULL consumption layers
	FOR n IN c_null_consume_layers LOOP

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('NULL consumption layer found for prod layer/txn/lot: ' ||
		    n.prod_layer_id ||'/'||n.mmt_transaction_id||'/'||n.lot_number ||
		    ' requirement_id for NULL consumption layer: ' || n.requirement_id);
		END IF;

	BEGIN

		-- Create a pseudo product layer in the gmf_incoming_material_layers table.
		SELECT gmf_layer_id_s.nextval INTO l_pseudo_prod_layer_id FROM DUAL;


		INSERT INTO gmf_incoming_material_layers(
			layer_id,
			mmt_transaction_id,
			mmt_organization_id,
			lot_number,
			layer_doc_qty,
			layer_doc_um,
			layer_date,
			pseudo_layer_id,
			final_cost_ind,
			gl_posted_ind,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			accounted_flag)
		VALUES(
			l_pseudo_prod_layer_id,
			n.mmt_transaction_id,
			n.mmt_organization_id,
			n.lot_number,
			n.layer_doc_qty,
			n.layer_doc_um,
			l_batch_close_date,
			n.prod_layer_id,
			0,
			0,
			l_user_id,
			sysdate,
			l_user_id,
			sysdate,
			NULL,
			'N');

		-- Create a VIB layer for the pseudo product layer reversing the original VIB row
		INSERT INTO gmf_batch_vib_details(
			prod_layer_id,
			prod_layer_pri_qty,
			consume_layer_id,
			consume_layer_date,
			line_type,
			vib_id,
			finalize_ind,
			consume_ib_doc_qty,
			consume_ib_pri_qty,
			created_by,
			creation_date,
			last_updated_by,
			last_update_date,
			last_update_login,
			requirement_id)
		VALUES(
			l_pseudo_prod_layer_id,
			n.prod_layer_pri_qty,
			NULL,
			n.consume_layer_date,
			n.line_type,
			NULL,
			1,
			-n.consume_ib_doc_qty,
			-n.consume_ib_pri_qty,
			l_user_id,
			sysdate,
			l_user_id,
			sysdate,
			NULL,
			n.requirement_id);


	END;
	END LOOP;

	-- going thru the requirement details

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('looping thru all the requirements to create finalization layers');
	END IF;

	prev_prod_material_detail_id := -99;
	FOR req IN c_batch_req LOOP
	BEGIN

		IF g_debug <= gme_debug.g_log_statement THEN
		  gme_debug.put_line ('Processing prod_material_detail_id: ' || req.prod_material_detail_id ||
		    ' ing_material_detail_id/batchstep_resource_id: ' || req.ing_material_detail_id||
		    '/'||req.batchstep_resource_id);
		END IF;

		-- Get the last yield for the product
		IF (prev_prod_material_detail_id <> req.prod_material_detail_id) THEN
			l_last_prod_layer.layer_id := NULL;
			OPEN c_last_prod_yield(req.prod_material_detail_id);
			FETCH c_last_prod_yield INTO l_last_prod_layer;
			CLOSE c_last_prod_yield;
			prev_prod_material_detail_id := req.prod_material_detail_id;
			l_pseudo_prod_layer_id := NULL;
		END IF;

		-- Get any remaining ingredients layers for this requirement row.
		IF (l_last_prod_layer.layer_id IS NOT NULL AND req.ing_material_detail_id IS NOT NULL) THEN

			FOR ing IN c_remaining_ing_layers (req.ing_material_detail_id) LOOP
			BEGIN

				IF g_debug <= gme_debug.g_log_statement THEN
				  gme_debug.put_line ('processing remaining ingredients layers...');
				END IF;

				--
				-- Bug 5607069: When using Actuals:
				-- before consuming remaining qty, see whether it is already
				-- got consumed from this layer or not. If yes, then don't consume again
				--
				IF l_use_vib = 'N'
				THEN
					SELECT nvl(sum (consume_ib_doc_qty), 0)
					INTO l_prev_consume_ib_doc_qty
					FROM gmf_batch_vib_details v,
					     gmf_incoming_material_layers il,
					     mtl_material_transactions mmt
					WHERE
						v.requirement_id               = req.requirement_id AND
						v.consume_layer_id             = ing.layer_id AND
						il.layer_id                    = v.prod_layer_id AND
						mmt.transaction_id             = il.mmt_transaction_id AND
						mmt.transaction_source_type_id = 5 AND
						mmt.inventory_item_id          = req.product_item_id AND
						mmt.organization_id = req.organization_id
					;

					IF (l_prev_consume_ib_doc_qty <> 0)
					THEN
						-- Do not consume from this layer, as it is already
						-- consumed
						RAISE e_invalid_consumption ;
					END IF;


					--
					-- Bug 5607069: If this is the reversal layer, then see whether original
					-- reversed layer is consumed by this product or not.
					-- If consumed, then consume from this reversal layer to nullify the effect of it.
					-- If not consumed, then don't consume from this reversal layer.
					--

					IF ing.reverse_id IS NOT NULL
					THEN
					  SELECT nvl(sum (consume_ib_doc_qty), 0)
					  INTO l_orig_layer_consumption_qty
					  FROM gmf_outgoing_material_layers ol,
					       gmf_batch_vib_details v,
					       gmf_incoming_material_layers il,
					       mtl_material_transactions mmt
					  WHERE
					  	ol.mmt_transaction_id          = ing.reverse_id AND
					  	ol.lot_number                  = ing.lot_number AND
					  	v.consume_layer_id             = ol.layer_id AND
					  	v.requirement_id               = req.requirement_id AND
						il.layer_id                    = v.prod_layer_id AND
						mmt.transaction_id             = il.mmt_transaction_id AND
						mmt.transaction_source_type_id = 5 AND
						mmt.inventory_item_id          = req.product_item_id AND
						mmt.organization_id            = req.organization_id
					  ;


					  IF (l_orig_layer_consumption_qty = 0)
					  THEN
						-- Do not consume from this reversal layers, as its original
						-- layer is not consumed by this product.
						RAISE e_invalid_consumption ;
					  END IF;

					END IF;

				END IF;
				-- End bug 5607069

				IF l_pseudo_prod_layer_id IS NULL THEN
					-- Create a pseudo product layer in the gmf_incoming_material_layers table.
					SELECT gmf_layer_id_s.nextval INTO l_pseudo_prod_layer_id FROM DUAL;

					INSERT INTO gmf_incoming_material_layers(
						layer_id,
						mmt_transaction_id,
						mmt_organization_id,
						lot_number,
						layer_doc_qty,
						layer_doc_um,
						layer_date,
						pseudo_layer_id,
						final_cost_ind,
						gl_posted_ind,
						created_by,
						creation_date,
						last_updated_by,
						last_update_date,
						last_update_login,
						accounted_flag)
					VALUES(
						l_pseudo_prod_layer_id,
						l_last_prod_layer.mmt_transaction_id,
						l_last_prod_layer.mmt_organization_id,
						l_last_prod_layer.lot_number,
						l_last_prod_layer.layer_doc_qty,
						l_last_prod_layer.layer_doc_um,
						l_batch_close_date,
						l_last_prod_layer.layer_id,
						0,
						0,
						l_user_id,
						sysdate,
						l_user_id,
						sysdate,
						NULL,
						'N');
				END IF;

				--
				-- Bug 5607069
				--
				IF l_use_vib = 'N'
				THEN
				  l_consume_ib_doc_qty := ing.layer_doc_qty * req.derived_cost_alloc;
				ELSE
				  l_consume_ib_doc_qty := ing.remaining_ib_doc_qty * req.derived_cost_alloc;
				END IF;
				-- Bug 5607069

				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => ing.inventory_item_id
					  , PRECISION     => 5
					  , ORGANIZATION_ID => req.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_consume_ib_doc_qty
					  , FROM_UNIT     => ing.layer_doc_um
					  , TO_UNIT       => ing.primary_uom_code
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);


				l_remaining_ib_doc_qty := ing.remaining_ib_doc_qty - l_consume_ib_doc_qty;

				INSERT INTO gmf_batch_vib_details(
					prod_layer_id,
					prod_layer_pri_qty,
					consume_layer_id,
					consume_layer_date,
					line_type,
					vib_id,
					finalize_ind,
					consume_ib_doc_qty,
					consume_ib_pri_qty,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
					requirement_id)
				VALUES(
					l_pseudo_prod_layer_id,
					l_last_prod_layer.primary_quantity,
					ing.layer_id,
					ing.transaction_date,
					ing.line_type,
					NULL,
					1,
					l_consume_ib_doc_qty,
					l_consume_ib_pri_qty,
					l_user_id,
					sysdate,
					l_user_id,
					sysdate,
					NULL,
					req.requirement_id);


			--
			-- Bug 5607069: Added exception block.
			--
			EXCEPTION
				WHEN e_invalid_consumption THEN
					NULL; -- Skip to next row
			END;
			END LOOP;
		END IF;

		--
		-- Now doing for resources
		--
		IF (l_last_prod_layer.layer_id IS NOT NULL AND req.batchstep_resource_id IS NOT NULL) THEN
			FOR rsrc IN c_remaining_rsrc_layers (req.batchstep_resource_id) LOOP
			BEGIN

				IF g_debug <= gme_debug.g_log_statement THEN
				  gme_debug.put_line ('processing remaining resource layers...');
				END IF;


				--
				-- Bug 5607069: When using Actuals:
				-- before consuming remaining qty, see whether it is already
				-- got consumed from this layer or not. If yes, then don't consume again
				--
				IF l_use_vib = 'N'
				THEN
					SELECT nvl(sum (consume_ib_doc_qty), 0)
					INTO l_prev_consume_ib_doc_qty
					FROM gmf_batch_vib_details v,
					     gmf_incoming_material_layers il,
					     mtl_material_transactions mmt
					WHERE
						v.requirement_id      = req.requirement_id AND
						v.consume_layer_id    = rsrc.layer_id AND
						il.layer_id           = v.prod_layer_id AND
						mmt.transaction_id    = il.mmt_transaction_id AND
						mmt.inventory_item_id = req.product_item_id AND
						mmt.organization_id   = req.organization_id AND
						mmt.transaction_source_type_id = 5
					;

					IF (l_prev_consume_ib_doc_qty <> 0)
					THEN
						-- Do not consume from this layer, as it is already
						-- consumed
						RAISE e_invalid_consumption ;
					END IF;


					--
					-- Bug 5607069: If this is the reversal layer, then see whether original
					-- reversed layer is consumed by this product or not.
					-- If consumed, then consume from this reversal layer to nullify the effect of it.
					-- If not consumed, then don't consume from this reversal layer.
					--
					IF rsrc.reverse_id IS NOT NULL
					THEN
					  SELECT nvl(sum (consume_ib_doc_qty), 0)
					  INTO l_orig_layer_consumption_qty
					  FROM gmf_resource_layers rl,
					       gmf_batch_vib_details v,
					       gmf_incoming_material_layers il,
					       mtl_material_transactions mmt
					  WHERE
					  	rl.poc_trans_id       = rsrc.reverse_id AND
					  	v.consume_layer_id    = rl.layer_id AND
					  	v.requirement_id      = req.requirement_id AND
						il.layer_id           = v.prod_layer_id AND
						mmt.transaction_id    = il.mmt_transaction_id AND
						mmt.inventory_item_id = req.product_item_id AND
						mmt.organization_id   = req.organization_id AND
						mmt.transaction_source_type_id = 5
					  ;

					  IF (l_orig_layer_consumption_qty = 0)
					  THEN
						-- Do not consume from this reversal layers, as its original
						-- layer is not consumed by this product.
						RAISE e_invalid_consumption ;
					  END IF;

					END IF;

				END IF;
				-- End bug 5607069

				IF l_pseudo_prod_layer_id IS NULL THEN
					-- Create a pseudo product layer in the gmf_incoming_material_layers table.
					-- Bug 6887598 mmt_organization_id should not be NULL
					SELECT gmf_layer_id_s.nextval INTO l_pseudo_prod_layer_id FROM DUAL;
					INSERT INTO gmf_incoming_material_layers(
						layer_id,
						mmt_transaction_id,
						mmt_organization_id,    -- B6887598
						lot_number,
						layer_doc_qty,
						layer_doc_um,
						layer_date,
						pseudo_layer_id,
						final_cost_ind,
						gl_posted_ind,
						created_by,
						creation_date,
						last_updated_by,
						last_update_date,
						last_update_login,
						accounted_flag)
					VALUES(
						l_pseudo_prod_layer_id,
						l_last_prod_layer.mmt_transaction_id,
						l_last_prod_layer.mmt_organization_id, -- B6887598
						l_last_prod_layer.lot_number,
						l_last_prod_layer.layer_doc_qty,
						l_last_prod_layer.layer_doc_um,
						l_batch_close_date,
						l_last_prod_layer.layer_id,
						0,
						0,
						l_user_id,
						sysdate,
						l_user_id,
						sysdate,
						NULL,
						'N');
				END IF;
				--
				-- Bug 5607069
				--
				IF l_use_vib = 'N'
				THEN
				  l_consume_ib_doc_qty := rsrc.layer_doc_qty * req.derived_cost_alloc;
				ELSE
				  l_consume_ib_doc_qty := rsrc.remaining_ib_doc_qty * req.derived_cost_alloc;
				END IF;

				l_consume_ib_pri_qty :=
					INV_CONVERT.INV_UM_CONVERT(
					    ITEM_ID       => 0
					  , PRECISION     => 5
					  , ORGANIZATION_ID => req.organization_id
					  , LOT_NUMBER     => NULL
					  , FROM_QUANTITY => l_consume_ib_doc_qty
					  , FROM_UNIT     => rsrc.layer_doc_um
					  , TO_UNIT       => rsrc.trans_um
					  , FROM_NAME     => NULL
					  , TO_NAME       => NULL
					);


				l_remaining_ib_doc_qty := rsrc.remaining_ib_doc_qty - l_consume_ib_doc_qty;
				INSERT INTO gmf_batch_vib_details(
					prod_layer_id,
					prod_layer_pri_qty,
					consume_layer_id,
					consume_layer_date,
					line_type,
					vib_id,
					finalize_ind,
					consume_ib_doc_qty,
					consume_ib_pri_qty,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login,
					requirement_id)
				VALUES(
					l_pseudo_prod_layer_id,
					l_last_prod_layer.primary_quantity,
					rsrc.layer_id,
					rsrc.trans_date,
					rsrc.line_type,
					NULL,
					1,
					l_consume_ib_doc_qty,
					l_consume_ib_pri_qty,
					l_user_id,
					sysdate,
					l_user_id,
					sysdate,
					NULL,
					req.requirement_id);

			--
			-- Bug 5607069: Added exception block.
			--
			EXCEPTION
				WHEN e_invalid_consumption THEN
					NULL; -- Skip to next row
			END;
			END LOOP;
		END IF;
	END;
	END LOOP;

	-- Now update the remaining_ib_doc_qty based upon the finalized layers.
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('Now update the remaining_ib_doc_qty based upon the finalized layers');
	END IF;

	FOR c IN c_finalize_layer_consumption LOOP
	BEGIN
		IF c.line_type = 0 THEN
			UPDATE gmf_resource_layers
			SET remaining_ib_doc_qty = remaining_ib_doc_qty - c.consume_ib_doc_qty
			WHERE
				layer_id = c.consume_layer_id;
		ELSE
			UPDATE gmf_outgoing_material_layers
			SET remaining_ib_doc_qty = remaining_ib_doc_qty - c.consume_ib_doc_qty
			WHERE
				layer_id = c.consume_layer_id;
		END IF;
	END;
	END LOOP;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;

/*
--+==========================================================================+
--| PROCEDURE NAME                                                           |
--|    Revert_Finalization                                                   |
--|                                                                          |
--| TYPE                                                                     |
--|    Public                                                                |
--|                                                                          |
--| USAGE                                                                    |
--|    Revert_Finalization                                                   |
--|                                                                          |
--| DESCRIPTION                                                              |
--|                                                                          |
--| PARAMETERS                                                               |
--|                                                                          |
--| RETURNS                                                                  |
--|    None                                                                  |
--|                                                                          |
--| HISTORY                                                                  |
--|                                                                          |
--+==========================================================================+
*/
PROCEDURE Revert_Finalization
( p_api_version   IN          NUMBER,
  p_init_msg_list IN          VARCHAR2 := FND_API.G_FALSE,
  p_batch_id      IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2) IS

CURSOR c_finalize_rows IS
SELECT v.ROWID, v.consume_ib_doc_qty, v.consume_layer_id, v.line_type
FROM gmf_batch_vib_details v, gmf_batch_requirements r
WHERE
	r.batch_id = p_batch_id and
	r.requirement_id = v.requirement_id and
	v.finalize_ind = 1 and
	v.consume_layer_id IS NOT NULL;

l_batch_status	PLS_INTEGER;
l_api_name	VARCHAR2(30) := 'Revert_Finalization';
BEGIN

  	x_return_status := FND_API.G_RET_STS_SUCCESS ;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Entering api ' || g_pkg_name || '.' || l_api_name);
	END IF;

	-- Validate batch_id
	BEGIN
		SELECT batch_status
		INTO l_batch_status
		FROM gme_batch_header
		WHERE batch_id = p_batch_id;

		IF l_batch_status = 4 THEN
			x_return_status := FND_API.G_RET_STS_ERROR ;
			--dbms_output.put_line ('Cannot revert finalization of a closed batch ');
			FND_MESSAGE.SET_NAME('GMF', 'GMF_BATCH_CLOSED');
			FND_MSG_PUB.Add;
			RETURN;
		END IF;
	EXCEPTION
		WHEN OTHERS THEN
			x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
			FND_MESSAGE.SET_NAME('GMF', 'G_RET_STS_UNEXP_ERROR');
			FND_MSG_PUB.Add;
			RAISE;
	END;

	-- Delete all rows from gmf_incoming_material_layers which are used in
	-- gmf_batch_vib_details with finalize_ind = 1
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('deleting pseudo layers...');
	END IF;

	DELETE from gmf_incoming_material_layers
	WHERE
		pseudo_layer_id IS NOT NULL AND
		layer_id in (
			SELECT prod_layer_id
			FROM gmf_batch_vib_details v,
				gmf_batch_requirements r
			WHERE
				r.batch_id = p_batch_id AND
				r.requirement_id = v.requirement_id AND
				v.finalize_ind = 1);

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	END IF;


	-- Delete all rows from the gmf_batch_vib_details with finalize_ind = 1
	-- and the comsume_layer_id is NULL.
	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('now deleting NULL finalized consumption layers');
	END IF;

	DELETE from gmf_batch_vib_details
	WHERE
		finalize_ind = 1 and
		consume_layer_id IS NULL and
		requirement_id in (
			SELECT requirement_id
			FROM gmf_batch_requirements
			WHERE
				Batch_id = p_batch_id);

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line (sql%ROWCOUNT || ' rows inserted');
	END IF;

	IF g_debug <= gme_debug.g_log_statement THEN
	  gme_debug.put_line ('now deleting regular finalized consumption layers. Also, updating remaining qty in outgoing layers table.');
	END IF;

	FOR f IN c_finalize_rows LOOP
	BEGIN
		-- Update the layers material, resource remaining_doc_qty
		IF f.line_type = 0 THEN
			UPDATE gmf_resource_layers
			SET remaining_ib_doc_qty = remaining_ib_doc_qty + f.consume_ib_doc_qty
			WHERE
				layer_id = f.consume_layer_id;
		ELSE
			UPDATE gmf_outgoing_material_layers
			SET remaining_ib_doc_qty = remaining_ib_doc_qty + f.consume_ib_doc_qty
			WHERE
				layer_id = f.consume_layer_id;
		END IF;

		-- Delete the row from the gmf_batch_vib_detail table.
		DELETE from gmf_batch_vib_details
		WHERE
			ROWID = f.ROWID;

	END;
	END LOOP;

	x_return_status := FND_API.G_RET_STS_SUCCESS;

	IF g_debug <= gme_debug.g_log_procedure THEN
	  gme_debug.put_line ('Exiting api ' || g_pkg_name || '.' || l_api_name);
	END IF;

EXCEPTION
	WHEN OTHERS THEN
	  	gme_debug.put_line ('Exiting api (thru when others) ' || g_pkg_name || '.' || l_api_name);
		FND_MESSAGE.SET_NAME('GMI','GMF_SQL_ERROR');
		FND_MESSAGE.SET_TOKEN('ERRCODE',SQLCODE);
		FND_MESSAGE.SET_TOKEN('ERRM',SQLERRM);
		FND_MSG_PUB.Add;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;

/*
PROCEDURE allocate_ingredients
(
  p_ac_proc_id    IN          NUMBER,
  x_return_status OUT NOCOPY  VARCHAR2,
  x_msg_count     OUT NOCOPY  NUMBER,
  x_msg_data      OUT NOCOPY  VARCHAR2
)
IS

  CURSOR get_latest_yield (
    p_co_code     VARCHAR2,
    p_start_date  DATE,
    p_end_date    DATE
  )
  IS
    SELECT layer_id, trans_id, layer_doc_qty, layer_doc_um, layer_date, pseudo_layer_id,
    		final_cost_ind, gl_posted_ind
    FROM (
    	SELECT
    		il.layer_id, il.trans_id, il.layer_doc_qty, il.layer_doc_um, il.layer_date, il.pseudo_layer_id,
    		il.final_cost_ind, il.gl_posted_ind,
    		hdr.batch_id,
            RANK() OVER(partition by hdr.batch_id ORDER BY hdr.batch_id, il.layer_date desc, il.layer_id desc) layer_rank
    	FROM
    		gme_batch_header hdr,
    		sy_orgn_mst orgn,
    		gmf_incoming_material_layers il,
    		ic_tran_pnd pnd
    	WHERE
    		il.layer_date        >= p_start_date
    	AND	il.layer_date        <= p_end_date
    	AND 	il.trans_id          IS NOT NULL
    	AND 	pnd.trans_id         = il.trans_id
    	AND 	orgn.co_code         = p_co_code
    	AND 	hdr.plant_code       = orgn.orgn_code
    	AND 	hdr.batch_id         = pnd.doc_id
    	AND     hdr.batch_status <> 4
    ) a
    WHERE a.layer_rank = 1
      and a.layer_id = 9
    ORDER BY batch_id, layer_date desc
  ;

  l_co_code       cm_cldr_hdr.co_code%TYPE;
  l_start_date    DATE;
  l_end_date      DATE;

  l_layer_rec     gmf_incoming_material_layers%ROWTYPE;
  l_trans_rec     ic_tran_pnd%ROWTYPE;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS ; --xxxremove

  SELECT hdr.co_code, dtl.start_date, dtl.end_date
    INTO l_co_code, l_start_date, l_end_date
    FROM cm_acpr_ctl acpr, cm_cldr_dtl dtl, cm_cldr_hdr hdr
   WHERE acpr.acproc_id      = p_ac_proc_id
     AND hdr.calendar_code   = acpr.calendar_code
     AND hdr.cost_mthd_code  = acpr.cost_mthd_code
     AND hdr.calendar_code   = dtl.calendar_code
     AND dtl.period_code     = acpr.period_code
  ;

  OPEN get_latest_yield(l_co_code, l_start_date, l_end_date);
  LOOP
    FETCH get_latest_yield
     INTO l_layer_rec.layer_id, l_layer_rec.trans_id,
          l_layer_rec.layer_doc_qty, l_layer_rec.layer_doc_um,
	  l_layer_rec.layer_date, l_layer_rec.pseudo_layer_id,
          l_layer_rec.final_cost_ind, l_layer_rec.gl_posted_ind;

    EXIT WHEN get_latest_yield%NOTFOUND;

    SELECT pnd.*
      INTO l_trans_rec
      FROM mtl_material_transactions pnd
     WHERE transaction_id = l_layer_rec.trans_id
    ;

    dbms_output.put_line('processing layer_id: ' || l_layer_rec.layer_id);


    -- Now generate the VIB details for this product transaction.
    GMF_VIB.Create_VIB_Details (
      1.0,
      FND_API.G_TRUE,
      l_trans_rec,
      l_layer_rec,
      x_return_status,
      x_msg_count,
      x_msg_data,
      3
    );

  END LOOP;

  CLOSE get_latest_yield;

END allocate_ingredients;
*/

END GMF_VIB;

/
