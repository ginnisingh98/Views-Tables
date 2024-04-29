--------------------------------------------------------
--  DDL for Package Body EAM_WL_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_WL_UTIL_PKG" as
/* $Header: EAMWLUTB.pls 120.1 2005/07/12 07:59:16 mkishore noship $ */


FUNCTION get_item_description( p_item_id NUMBER, p_organization_id NUMBER)
                             return VARCHAR2 IS
   l_description  MTL_SYSTEM_ITEMS.DESCRIPTION%TYPE ;
   CURSOR get_description IS
      SELECT msi.description
      FROM   mtl_system_items msi, mtl_parameters mp
      WHERE  msi.inventory_item_id = p_item_id
      AND    msi.organization_id = mp.organization_id
      AND    mp.maint_organization_id = p_organization_id ;
BEGIN
    OPEN get_description ;
    FETCH get_description INTO l_description ;
    CLOSE get_description;

     RETURN l_description;
END get_item_description;

FUNCTION get_concatenated_segments( p_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT msi.concatenated_segments
	FROM   mtl_system_items_kfv msi, mtl_parameters mp
        WHERE  msi.inventory_item_id = p_item_id
        AND    msi.organization_id = mp.organization_id
        AND    mp.maint_organization_id = p_organization_id ;

	l_concatenated_segments mtl_system_items_kfv.concatenated_segments%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_concatenated_segments;
	CLOSE get_value;

	RETURN l_concatenated_segments;
END get_concatenated_segments;

FUNCTION get_translatable_value(p_lookup_code NUMBER, p_lookup_type VARCHAR2) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT meaning
	FROM mfg_lookups
	WHERE lookup_code = p_lookup_code
	AND lookup_type = p_lookup_type;

	l_meaning mfg_lookups.meaning%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_meaning;
	CLOSE get_value;

	RETURN l_meaning;
END get_translatable_value;

FUNCTION get_department_code(p_department_id NUMBER, p_organization_id NUMBER ) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT department_code
	FROM   bom_departments
	WHERE  organization_id = p_organization_id
        AND    department_id = p_department_id;

	l_department_code bom_departments.department_code%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_department_code;
	CLOSE get_value;

	RETURN l_department_code;
END get_department_code;

FUNCTION get_wip_entity_name( p_wip_entity_id NUMBER) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT wip_entity_name
	FROM   wip_entities
	WHERE  wip_entity_id = p_wip_entity_id;

	l_description wip_entities.wip_entity_name%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_description;
	CLOSE get_value;

	RETURN l_description;
END get_wip_entity_name;

FUNCTION get_wo_status( p_wip_entity_id NUMBER) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT status_type
	FROM   wip_discrete_jobs
	WHERE  wip_entity_id = p_wip_entity_id;

	l_status_type wip_discrete_jobs.status_type%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_status_type;
	CLOSE get_value;

	RETURN l_status_type;
END get_wo_status;

FUNCTION Is_Stock_Enable( p_inventory_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT NVL(stock_enabled_flag,'N')
	FROM   mtl_system_items msi, mtl_parameters mp
	WHERE msi.inventory_item_id = p_inventory_item_id
	AND msi.organization_id = mp.organization_id
        AND    mp.maint_organization_id = p_organization_id ;

	l_flag mtl_system_items.stock_enabled_flag%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_flag;
	CLOSE get_value;

	RETURN l_flag;

END Is_Stock_Enable;



FUNCTION get_serial_description( p_serial_number VARCHAR2, p_item_id NUMBER, p_organization_id NUMBER) RETURN VARCHAR2
IS
	CURSOR get_value IS
	SELECT cii.instance_description
	FROM   csi_item_instances cii, mtl_parameters mp
	WHERE cii.serial_number = p_serial_number
	AND cii.inventory_item_id = p_item_id
	AND cii.last_vld_organization_id = mp.organization_id
        AND mp.maint_organization_id = p_organization_id;

	l_description mtl_serial_numbers.descriptive_text%TYPE;
BEGIN
	OPEN get_value;
	FETCH get_value INTO l_description;
	CLOSE get_value;

	RETURN l_description;
END get_serial_description;

FUNCTION get_instance_count( p_operation_seq_num NUMBER,
			     p_wip_entity_id NUMBER,
			     p_organization_id NUMBER,
			     p_resource_type NUMBER) RETURN VARCHAR2
IS
	CURSOR get_count IS
	SELECT count(*)
	FROM   wip_op_resource_instances wori,
	       wip_operation_resources wor,
	       bom_resources br
	WHERE wor.wip_entity_id = wori.wip_entity_id
        AND  wor.organization_id = wori.organization_id
        AND  wor.operation_seq_num = wori.operation_seq_num
        AND  wor.resource_seq_num = wori.resource_seq_num
        AND  br.resource_id = wor.resource_id
        AND  br.resource_type = p_resource_type		-- (1=Man)/(2=Machine)
	AND  wori.operation_seq_num  = p_operation_seq_num
	AND   wori.wip_entity_id = p_wip_entity_id
	AND wori.organization_id = p_organization_id;

	l_count NUMBER;
BEGIN
	OPEN get_count;
	FETCH get_count INTO l_count;
	CLOSE get_count;

	RETURN l_count;
END get_instance_count;

FUNCTION get_wip_job_sequence return NUMBER IS
   l_job_sequence_number  NUMBER ;
BEGIN
    SELECT wip_job_number_s.nextval
      INTO l_job_sequence_number
      FROM DUAL;

     RETURN l_job_sequence_number;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
     RETURN -1;
END get_wip_job_sequence;

FUNCTION  isESignatureRequired( p_transaction_name IN VARCHAR2)	return VARCHAR2
IS
   l_return_status VARCHAR2(255);
   l_msg_count     NUMBER;
   l_msg_data      VARCHAR2(2000);
   l_intputvar_values_tbl     EDR_STANDARD_PUB.InputVar_Values_tbl_type;
BEGIN
	IF nvl(fnd_profile.value('EDR_ERES_ENABLED'), 'N') = 'N' THEN
		RETURN 'N';
	END IF;

	EDR_STANDARD_PUB.GET_AMERULE_VARIABLEVALUES (
        p_api_version       => 1.0,
        p_init_msg_list     => FND_API.G_FALSE,
        x_return_status     => l_return_status,
        x_msg_count         => l_msg_count,
        x_msg_data          => l_msg_data,
        p_transaction_id  => p_transaction_name,
        p_ameRule_id       => -1,
        p_ameRule_name     => NULL,
        x_inputVar_values_tbl   => l_intputvar_values_tbl );

	IF l_return_status = 'S' THEN
		FOR i IN  l_intputvar_values_tbl.FIRST ..  l_intputvar_values_tbl.LAST LOOP
			IF l_intputvar_values_tbl(i).input_name = 'ESIG_REQUIRED' THEN
				IF l_intputvar_values_tbl(i).input_value = 'Y' THEN
					RETURN 'Y';
				END IF;
			END IF;
		END LOOP;
	END IF;
	RETURN 'N';
END isESignatureRequired;

END EAM_WL_UTIL_PKG;

/
