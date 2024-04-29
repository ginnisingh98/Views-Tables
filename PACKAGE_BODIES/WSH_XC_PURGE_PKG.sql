--------------------------------------------------------
--  DDL for Package Body WSH_XC_PURGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_XC_PURGE_PKG" AS
/* $Header: WSHXCPRB.pls 115.10 2004/01/19 14:56:03 rahujain ship $ */

--
G_PKG_NAME CONSTANT VARCHAR2(50) := 'WSH_XC_PURGE_PKG';
--
PROCEDURE Purge_Seed_Definition AS
-- -----------------------------------------------------------------------------------------
-- This procedure bumps the sequence number, removes the seeded exception
-- definitions and pushes the customer exception definitions up.
--
-- ------------------------------------------------------------------------------------------


l_sequence	NUMBER := 0;



CURSOR c_exception_definition IS
--Changed for #BUG3330869
	SELECT
--	SELECT
		exception_definition_id,
		update_allowed,
		exception_name,
		description,
		exception_type,
		default_severity,
		exception_handling,
		workflow_item_type,
		workflow_process,
		initiate_workflow,
		attribute_category,
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
		attribute15,
		creation_date,
		created_by,
		last_update_date,
		last_updated_by,
		last_update_login
	FROM WSH_EXCEPTION_DEFINITIONS_VL
	WHERE EXCEPTION_DEFINITION_ID < 1001;




l_definition_rec c_exception_definition%ROWTYPE;

--
l_debug_on BOOLEAN;
--
l_module_name CONSTANT VARCHAR2(100) := 'wsh.plsql.' || G_PKG_NAME || '.' || 'PURGE_SEED_DEFINITION';
--
BEGIN
	-- --------------------------------------------------------------------
	-- check the sequence, if it is less than 5000, consume the sequence
	-- --------------------------------------------------------------------
	--
	l_debug_on := WSH_DEBUG_INTERFACE.g_debug;
	--
	IF l_debug_on IS NULL
	THEN
	    l_debug_on := WSH_DEBUG_SV.is_debug_enabled;
	END IF;
	--
	IF l_debug_on THEN
	    WSH_DEBUG_SV.push(l_module_name);
	END IF;
	--
	LOOP
		SELECT WSH_EXCEPTION_DEFINITIONS_S.nextval INTO l_sequence FROM SYS.DUAL ;
		IF l_sequence > 1000 THEN
			EXIT;
		END IF;
	END LOOP;

	-- delete all the seeded exception

		OPEN c_exception_definition;
		FETCH c_exception_definition INTO l_definition_rec;
		WHILE c_exception_definition%FOUND LOOP
			--
			WSH_XC_UTIL.delete_xc_def_form(l_definition_rec.exception_definition_id);
			IF l_definition_rec.update_allowed ='Y' THEN
				-- customer data
				SELECT WSH_EXCEPTION_DEFINITIONS_S.nextval INTO l_sequence FROM DUAL;
				WSH_XC_UTIL.insert_xc_def_form (
						x_exception_definition_id => l_sequence ,
						p_exception_name	=> l_definition_rec.exception_name,
						p_description	=> l_definition_rec.description,
						p_exception_type=> l_definition_rec.exception_type,
						p_default_severity => l_definition_rec.default_severity,
						p_exception_handling	=> l_definition_rec.exception_handling,
	  					p_workflow_item_type	=> l_definition_rec.workflow_item_type,
	  					p_workflow_process  => l_definition_rec.workflow_process,
						p_initiate_workflow => l_definition_rec.initiate_workflow,
						p_update_allowed 		=> l_definition_rec.update_allowed,
						p_attribute_category => l_definition_rec.attribute_category,
						p_attribute1	=> l_definition_rec.attribute1,
						p_attribute2	=> l_definition_rec.attribute2,
						p_attribute3	=> l_definition_rec.attribute3,
						p_attribute4	=> l_definition_rec.attribute4,
						p_attribute5	=> l_definition_rec.attribute5,
						p_attribute6	=> l_definition_rec.attribute6,
						p_attribute7	=> l_definition_rec.attribute7,
						p_attribute8	=> l_definition_rec.attribute8,
						p_attribute9	=> l_definition_rec.attribute9,
						p_attribute10	=> l_definition_rec.attribute10,
						p_attribute11	=> l_definition_rec.attribute11,
						p_attribute12	=> l_definition_rec.attribute12,
						p_attribute13	=> l_definition_rec.attribute13,
						p_attribute14	=> l_definition_rec.attribute14,
						p_attribute15	=> l_definition_rec.attribute15,
						p_creation_date  		=> l_definition_rec.creation_date,
  						p_created_by       	=> l_definition_rec.created_by,
  						p_last_update_date 	=> l_definition_rec.last_update_date,
  						p_last_updated_by  	=> l_definition_rec.last_updated_by,
  						p_last_update_login	=> l_definition_rec.last_update_login
				);



			END IF;
					FETCH c_exception_definition INTO l_definition_rec;
		END LOOP;
		CLOSE c_exception_definition;
	commit;
        --
        IF l_debug_on THEN
            WSH_DEBUG_SV.pop(l_module_name);
        END IF;
        --
END Purge_Seed_Definition;

END WSH_XC_PURGE_PKG;

/
