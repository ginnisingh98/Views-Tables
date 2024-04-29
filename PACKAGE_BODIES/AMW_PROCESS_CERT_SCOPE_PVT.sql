--------------------------------------------------------
--  DDL for Package Body AMW_PROCESS_CERT_SCOPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMW_PROCESS_CERT_SCOPE_PVT" AS
/* $Header: amwvpcsb.pls 120.1 2005/07/05 18:27:45 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMW_PROCESS_CERT_SCOPE_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================
g_pkg_name    CONSTANT VARCHAR2 (30) := 'AMW_PROCESS_CERT_SCOPE_PVT';
g_file_name   CONSTANT VARCHAR2 (12) := 'amwvpcsb.pls';




PROCEDURE Insert_Process(
    p_level_id       IN NUMBER,
	p_parent_process_id  IN NUMBER,
	p_top_process_id    IN NUMBER,
	p_subsidiary_vs  IN VARCHAR2,
	p_subsidiary_code IN VARCHAR2,
	p_lob_vs          IN VARCHAR2,
	p_lob_code        IN VARCHAR2,
	p_organization_id IN NUMBER,
	p_certification_id IN NUMBER
) IS
       CURSOR c_process IS
           SELECT apv.child_process_id process_id
	   FROM AMW_CURR_APP_HIERARCHY_ORG_V apv
	   WHERE apv.PARENT_PROCESS_ID = p_parent_process_id
	   and apv.child_organization_id = p_organization_id;
BEGIN
    FOR proc_rec IN c_process LOOP
        Insert_Process (p_level_id+1,proc_rec.process_id,p_top_process_id,p_subsidiary_vs,
		                p_subsidiary_code,p_lob_vs,p_lob_code,p_organization_id,p_certification_id);
        INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID)
	SELECT amw_execution_scope_s.nextval,
 	       'PROCESS_CERTIFICATION',
		   p_certification_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   p_level_id,
		   p_subsidiary_vs,
		   p_subsidiary_code,
		   p_lob_vs,
		   p_lob_code,
		   p_organization_id,
		   proc_rec.process_id,
		   p_top_process_id,
		   p_parent_process_id
         FROM DUAL;
    END LOOP;
END Insert_Process;

PROCEDURE Insert_Audit_Units(
    p_api_version_number        IN       NUMBER   := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_certification_id	        IN	     NUMBER,
	x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
)
  IS
       CURSOR c_audit_unit IS
       SELECT audit_v.company_code,audit_v.subsidiary_valueset,
	          audit_v.lob_code,audit_v.lob_valueset,
			  audit_v.organization_id
	   FROM amw_audit_units_v audit_v;

	   CURSOR c_org_process IS
	    SELECT org_v.child_process_id as top_process_id,
	          org_v.child_organization_id as organization_id,
			  audit_v.company_code,audit_v.subsidiary_valueset,
	          audit_v.lob_code,audit_v.lob_valueset
	   FROM   AMW_CURR_APP_HIERARCHY_ORG_V org_v,
	          amw_audit_units_v audit_v
	   where org_v.parent_process_id = -2
	   and audit_v.organization_id = org_v.child_organization_id;
	   l_api_name VARCHAR2(150) := 'Insert_Audit_Units';
BEGIN

	 x_return_status            := fnd_api.g_ret_sts_success;

    SAVEPOINT INSERT_AUDIT_UNITS_PVT;

	delete from AMW_EXECUTION_SCOPE
	       where entity_id = p_certification_id
		   and entity_type = 'PROCESS_CERTIFICATION';


    FOR audit_rec IN c_audit_unit LOOP

        INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID)
	SELECT amw_execution_scope_s.nextval,
 	       'PROCESS_CERTIFICATION',
		   p_certification_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   1,
		   audit_rec.subsidiary_valueset,
		   audit_rec.company_code,
		   null,
		   null,
		   null,
		   null,
		   null,
		   null
         FROM DUAL
		      WHERE not exists (SELECT 'Y'
		           FROM AMW_EXECUTION_SCOPE
		           WHERE entity_type='PROCESS_CERTIFICATION'
		           AND entity_id= p_certification_id
			       AND subsidiary_vs =  audit_rec.subsidiary_valueset
			       AND subsidiary_code= audit_rec.company_code
			       AND level_id=1);


        INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID)
	SELECT amw_execution_scope_s.nextval,
 	       'PROCESS_CERTIFICATION',
		   p_certification_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   2,
		   audit_rec.subsidiary_valueset,
		   audit_rec.company_code,
		   audit_rec.lob_valueset,
		   audit_rec.lob_code,
		   null,
		   null,
		   null,
		   null
         FROM DUAL
		           WHERE not exists (SELECT 'Y'
		           FROM AMW_EXECUTION_SCOPE
		           WHERE entity_type='PROCESS_CERTIFICATION'
		           AND entity_id= p_certification_id
			       AND subsidiary_vs =  audit_rec.subsidiary_valueset
			       AND subsidiary_code= audit_rec.company_code
				   AND lob_vs = audit_rec.lob_valueset
				   AND lob_code = audit_rec.lob_code
			       AND level_id=2);


        INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID)
	SELECT amw_execution_scope_s.nextval,
 	       'PROCESS_CERTIFICATION',
		   p_certification_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   3,
		   audit_rec.subsidiary_valueset,
		   audit_rec.company_code,
		   audit_rec.lob_valueset,
		   audit_rec.lob_code,
		   audit_rec.organization_id,
		   null,
		   null,
		   null
         FROM DUAL
		           WHERE not exists (SELECT 'Y'
		           FROM AMW_EXECUTION_SCOPE
		           WHERE entity_type='PROCESS_CERTIFICATION'
		           AND entity_id= p_certification_id
			       AND subsidiary_vs =  audit_rec.subsidiary_valueset
			       AND subsidiary_code= audit_rec.company_code
				   AND lob_vs = audit_rec.lob_valueset
				   AND lob_code = audit_rec.lob_code
				   AND organization_id = audit_rec.organization_id
			       AND level_id=3);
    END LOOP;

	FOR org_process_rec IN c_org_process LOOP

	      INSERT INTO AMW_EXECUTION_SCOPE (
	       EXECUTION_SCOPE_ID,
		   ENTITY_TYPE,
		   ENTITY_ID,
		   CREATED_BY,
		   CREATION_DATE,
		   LAST_UPDATE_DATE,
		   LAST_UPDATED_BY,
		   LAST_UPDATE_LOGIN,
		   SCOPE_CHANGED_STATUS,
		   LEVEL_ID,
		   SUBSIDIARY_VS,
		   SUBSIDIARY_CODE,
		   LOB_VS,
		   LOB_CODE,
		   ORGANIZATION_ID,
		   PROCESS_ID,
		   TOP_PROCESS_ID,
		   PARENT_PROCESS_ID)
	SELECT amw_execution_scope_s.nextval,
 	       'PROCESS_CERTIFICATION',
		   p_certification_id,
		   FND_GLOBAL.USER_ID,
		   SYSDATE,
		   SYSDATE,
		   FND_GLOBAL.USER_ID,
		   FND_GLOBAL.USER_ID,
		   'C',
		   4,
		   org_process_rec.subsidiary_valueset,
		   org_process_rec.company_code,
		   org_process_rec.lob_valueset,
		   org_process_rec.lob_code,
		   org_process_rec.organization_id,
		   org_process_rec.top_process_id,
		   org_process_rec.top_process_id,
		   -1
         FROM DUAL
		           WHERE not exists (SELECT 'Y'
		           FROM AMW_EXECUTION_SCOPE
		           WHERE entity_type='PROCESS_CERTIFICATION'
		           AND entity_id= p_certification_id
			       AND subsidiary_vs =  org_process_rec.subsidiary_valueset
			       AND subsidiary_code= org_process_rec.company_code
				   AND lob_vs = org_process_rec.lob_valueset
				   AND lob_code = org_process_rec.lob_code
				   AND process_id = org_process_rec.top_process_id
			       AND level_id=4);

	   -- Insert All the processes in the process Hierarchy using the top_process_id's
	      Insert_Process(5,org_process_rec.top_process_id,org_process_rec.top_process_id,org_process_rec.subsidiary_valueset,
		                 org_process_rec.company_code,org_process_rec.lob_valueset,org_process_rec.lob_code,
						 org_process_rec.organization_id,p_certification_id);

        END LOOP;
 EXCEPTION WHEN OTHERS THEN
    rollback to INSERT_AUDIT_UNITS_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Add_Exc_Msg(g_pkg_name, l_api_name);
    FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
END Insert_Audit_Units;

-- Removed the following procedure to fix bug 4474874
-- This procedure is only called in AMW_POPULATE_HIERARCHIES_PVT
-- (amwphierb.pls). amwphierb.pls has been obsolete.
/*
PROCEDURE insert_specific_audit_units(
    p_api_version_number        IN       NUMBER := 1.0,
    p_init_msg_list             IN       VARCHAR2 := FND_API.g_false,
    p_commit                    IN       VARCHAR2 := FND_API.g_false,
    p_validation_level          IN       NUMBER := fnd_api.g_valid_level_full,
    p_certification_id		    IN	     NUMBER,
    p_org_tbl                   IN       AMW_POPULATE_HIERARCHIES_PVT.g_org_tbl%TYPE,
    p_process_tbl               IN       AMW_POPULATE_HIERARCHIES_PVT.g_process_tbl%TYPE,
    x_return_status             OUT      nocopy VARCHAR2,
    x_msg_count                 OUT      nocopy NUMBER,
    x_msg_data                  OUT      nocopy VARCHAR2
) IS

        CURSOR c_audit_unit(p_org_id NUMBER) IS
        SELECT audit_v.company_code,audit_v.subsidiary_valueset,
	          audit_v.lob_code,audit_v.lob_valueset,
	          audit_v.organization_id
        FROM amw_audit_units_v audit_v
        WHERE organization_id = p_org_id;

	    l_api_name VARCHAR2(150) := 'Insert_Specific_Audit_Units';
        l_api_version_number CONSTANT NUMBER       := 1.0;

        TYPE orgprocesstype IS REF CURSOR;
        process_cursor orgprocesstype;

        l_get_processes_query VARCHAR2(32767) :=
           'SELECT org_v.child_process_id as top_process_id,
	           org_v.child_organization_id as organization_id,
    		   audit_v.company_code,
                   audit_v.subsidiary_valueset,
	           audit_v.lob_code,
                   audit_v.lob_valueset
    	   FROM   AMW_CURR_APP_HIERARCHY_ORG_V org_v,
	          amw_audit_units_v audit_v
	   WHERE org_v.parent_process_id = -2
    	   AND audit_v.organization_id = org_v.child_organization_id
           AND audit_v.organization_id =';

       l_extra_query VARCHAR2(32767);
       l_final_query VARCHAR2(32767);

       l_process_id NUMBER;
       l_organization_id NUMBER;
       l_company_code amw_audit_units_v.company_code%TYPE;
       l_subsidiary_valueset amw_audit_units_v.subsidiary_valueset%TYPE;
       l_lob_code amw_audit_units_v.lob_code%TYPE;
       l_lob_valueset amw_audit_units_v.lob_valueset%TYPE;

BEGIN

    SAVEPOINT INSERT_SPEC_AUDIT_UNITS_PVT;

    -- Standard call to check for call compatibility.
	IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
					     p_api_version_number,
					     l_api_name,
					     G_PKG_NAME)
	THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	-- Initialize message list if p_init_msg_list is set to TRUE.
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
		FND_MSG_PUB.initialize;
	END IF;

	-- Initialize API return status to SUCCESS
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	DELETE FROM AMW_EXECUTION_SCOPE
	WHERE entity_id = p_certification_id
	AND entity_type = 'PROCESS_CERTIFICATION';

	FOR each_rec IN 1..p_org_tbl.count
	LOOP

		FOR audit_rec IN c_audit_unit(p_org_tbl(each_rec).org_id)
		LOOP

			INSERT INTO AMW_EXECUTION_SCOPE (
				EXECUTION_SCOPE_ID,
				ENTITY_TYPE,
				ENTITY_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				SCOPE_CHANGED_STATUS,
				LEVEL_ID,
				SUBSIDIARY_VS,
				SUBSIDIARY_CODE,
				LOB_VS,
				LOB_CODE,
				ORGANIZATION_ID,
				PROCESS_ID,
				TOP_PROCESS_ID,
				PARENT_PROCESS_ID)
			SELECT 	amw_execution_scope_s.nextval,
				'PROCESS_CERTIFICATION',
				p_certification_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'C',
				1,
				audit_rec.subsidiary_valueset,
				audit_rec.company_code,
				null,
				null,
				null,
				null,
				null,
				null
			FROM DUAL
			WHERE not exists (SELECT 'Y'
					FROM AMW_EXECUTION_SCOPE
					WHERE entity_type='PROCESS_CERTIFICATION'
					AND entity_id= p_certification_id
					AND subsidiary_vs =  audit_rec.subsidiary_valueset
					AND subsidiary_code= audit_rec.company_code
					AND level_id=1);

			INSERT INTO AMW_EXECUTION_SCOPE (
				EXECUTION_SCOPE_ID,
				ENTITY_TYPE,
				ENTITY_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				SCOPE_CHANGED_STATUS,
				LEVEL_ID,
				SUBSIDIARY_VS,
				SUBSIDIARY_CODE,
				LOB_VS,
				LOB_CODE,
				ORGANIZATION_ID,
				PROCESS_ID,
				TOP_PROCESS_ID,
				PARENT_PROCESS_ID)
			SELECT  amw_execution_scope_s.nextval,
				'PROCESS_CERTIFICATION',
				p_certification_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'C',
				2,
				audit_rec.subsidiary_valueset,
				audit_rec.company_code,
				audit_rec.lob_valueset,
				audit_rec.lob_code,
				null,
				null,
				null,
				null
			FROM DUAL
			WHERE not exists (SELECT 'Y'
					FROM AMW_EXECUTION_SCOPE
					WHERE entity_type='PROCESS_CERTIFICATION'
					AND entity_id= p_certification_id
					AND subsidiary_vs =  audit_rec.subsidiary_valueset
					AND subsidiary_code= audit_rec.company_code
					AND lob_vs = audit_rec.lob_valueset
					AND lob_code = audit_rec.lob_code
					AND level_id=2);

			INSERT INTO AMW_EXECUTION_SCOPE (
				EXECUTION_SCOPE_ID,
				ENTITY_TYPE,
				ENTITY_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				SCOPE_CHANGED_STATUS,
				LEVEL_ID,
				SUBSIDIARY_VS,
				SUBSIDIARY_CODE,
				LOB_VS,
				LOB_CODE,
				ORGANIZATION_ID,
				PROCESS_ID,
				TOP_PROCESS_ID,
				PARENT_PROCESS_ID)
			SELECT  amw_execution_scope_s.nextval,
				'PROCESS_CERTIFICATION',
				p_certification_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'C',
				3,
				audit_rec.subsidiary_valueset,
				audit_rec.company_code,
				audit_rec.lob_valueset,
				audit_rec.lob_code,
				audit_rec.organization_id,
				null,
				null,
				null
			FROM DUAL
			WHERE not exists (SELECT 'Y'
					FROM AMW_EXECUTION_SCOPE
					WHERE entity_type='PROCESS_CERTIFICATION'
					AND entity_id= p_certification_id
					AND subsidiary_vs =  audit_rec.subsidiary_valueset
					AND subsidiary_code= audit_rec.company_code
					AND lob_vs = audit_rec.lob_valueset
					AND lob_code = audit_rec.lob_code
					AND organization_id = audit_rec.organization_id
					AND level_id=3);
		END LOOP; --audit_rec IN c_audit_unit

		IF(p_process_tbl.count > 0)
		THEN
		    l_extra_query := ' AND org_v.child_process_id IN (';
		END IF;

		FOR i IN 1..p_process_tbl.count LOOP
			l_extra_query := l_extra_query || p_process_tbl(i).process_id;
			IF (i = p_process_tbl.count)
			THEN
			    l_extra_query := l_extra_query || ' )';
			ELSE
			    l_extra_query := l_extra_query || ', ';
			END IF;
		END LOOP;

		l_final_query := l_get_processes_query || p_org_tbl(each_rec).org_id || l_extra_query;

		OPEN process_cursor FOR l_final_query;
		LOOP
			FETCH process_cursor INTO l_process_id,
						l_organization_id,
						l_company_code,
						l_subsidiary_valueset,
						l_lob_code,
						l_lob_valueset;
			EXIT WHEN process_cursor%NOTFOUND;

			INSERT INTO AMW_EXECUTION_SCOPE (
				EXECUTION_SCOPE_ID,
				ENTITY_TYPE,
				ENTITY_ID,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATE_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_LOGIN,
				SCOPE_CHANGED_STATUS,
				LEVEL_ID,
				SUBSIDIARY_VS,
				SUBSIDIARY_CODE,
				LOB_VS,
				LOB_CODE,
				ORGANIZATION_ID,
				PROCESS_ID,
				TOP_PROCESS_ID,
				PARENT_PROCESS_ID)
			SELECT amw_execution_scope_s.nextval,
				'PROCESS_CERTIFICATION',
				p_certification_id,
				FND_GLOBAL.USER_ID,
				SYSDATE,
				SYSDATE,
				FND_GLOBAL.USER_ID,
				FND_GLOBAL.USER_ID,
				'C',
				4,
				l_subsidiary_valueset,
				l_company_code,
				l_lob_valueset,
				l_lob_code,
				l_organization_id,
				l_process_id,
				l_process_id,
				-1
			FROM DUAL
			WHERE not exists (SELECT 'Y'
					FROM AMW_EXECUTION_SCOPE
					WHERE entity_type='PROCESS_CERTIFICATION'
					AND entity_id= p_certification_id
					AND subsidiary_vs =  l_subsidiary_valueset
					AND subsidiary_code= l_company_code
					AND lob_vs = l_lob_valueset
					AND lob_code = l_lob_code
					AND process_id = l_process_id
					AND level_id=4);

			-- Insert All the processes in the process Hierarchy using the top_process_id's
			Insert_Process(5,
				       l_process_id,
				       l_process_id,
				       l_subsidiary_valueset,
				       l_company_code,
				       l_lob_valueset,
				       l_lob_code,
				       l_organization_id,
				       p_certification_id);

		END LOOP;
		CLOSE process_cursor;


	END LOOP;--each_rec IN 1..p_org_tbl.count

	EXCEPTION WHEN OTHERS THEN
		rollback to INSERT_SPEC_AUDIT_UNITS_PVT;
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
		FND_MSG_PUB.Count_And_Get(
		p_encoded =>  FND_API.G_FALSE,
		p_count   =>  x_msg_count,
		p_data    =>  x_msg_data);
	END insert_specific_audit_units;
*/

END amw_process_cert_scope_pvt;


/
