--------------------------------------------------------
--  DDL for Package Body AHL_ENIGMA_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_ENIGMA_UTIL_PKG" AS
/* $Header: AHLUENGB.pls 120.0.12010000.1 2008/11/05 14:22:23 sathapli noship $ */

l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;

G_PKG_NAME 	CONSTANT 	VARCHAR2(30) 	:= 'AHL_ENIGMA_UTIL_PKG';

  ----------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: get_enigma_url_params
	--  Function				: Returns the Model of MC header, ATA Code of the position , Tail Number of the
   --                        unit, User Name , User lang and Doc Id
	--  get_enigma_url_params Parameters:
   --       p_object_type           : Indicates whether the call is from MC or UC context
   --			p_primary_object_id     : Incase of MC this will be the Relationship Id, For UC this will be the
   --                                 instance Id
	--			p_secondary_object_id   : Incase of MC this will be null, incase of UC if p_primary_object_id if
   --                                 is null this will be
   --                                 uc header id
   --       x_model                 : The model of the corresponding MC
   --       x_ata_code              : The ATA Code of the corresponding position
   --       x_tail_number           : The tail number of the corresponding UC
   --       x_user_name             : The User logged in
   --       x_user_lang             : The User lang
   --       x_doc_id                : The Doc Id
	--  End of Comments.
	---------------------------------------------------------------------------------------------------------
PROCEDURE get_enigma_url_params(
         p_object_type              IN    VARCHAR2,
         p_primary_object_id        IN    NUMBER,
         p_secondary_object_id      IN    NUMBER,
         x_model                    OUT   NOCOPY VARCHAR2,
         x_ata_code                 OUT   NOCOPY VARCHAR2,
         x_tail_number              OUT   NOCOPY VARCHAR2,
         x_user_name                OUT   NOCOPY VARCHAR2,
         x_user_lang                OUT   NOCOPY VARCHAR2,
         x_doc_id                   OUT   NOCOPY VARCHAR2
   )
   IS

      l_api_name      CONSTANT      VARCHAR2(25) := 'get_enigma_url_params';

      CURSOR get_model_and_ata_csr(c_relationship_id NUMBER) IS
         SELECT   model_code,
                  ata_code
         FROM     ahl_mc_headers_b hdr,
                  ahl_mc_relationships rel
         WHERE    rel.relationship_id = c_relationship_id
         AND      rel.mc_header_id = hdr.mc_header_id;

      CURSOR get_model_and_tail_csr(c_uc_header_id NUMBER) IS
         SELECT   uc.name,model_code
         FROM     ahl_unit_config_headers uc,ahl_mc_headers_b mc
         WHERE    uc.master_config_id = mc.mc_header_id
         AND      unit_config_header_id = c_uc_header_id;

      CURSOR get_user_and_lang IS
         SELECT   FND_GLOBAL.USER_NAME,
                  userenv('LANG')
         FROM     dual;

      CURSOR get_doc_id (c_workorder_id NUMBER)IS
         SELECT   enigma_doc_id
         FROM     ahl_workorders wo,ahl_routes_b rt
         WHERE    wo.workorder_id = c_workorder_id
         AND      wo.route_id  = rt.route_id;

      CURSOR get_wo_model_tail_csr (c_workorder NUMBER)
      IS
         SELECT  model_code, UCH.name, NVL(TSK.INSTANCE_ID,VST.ITEM_INSTANCE_ID)
         FROM    ahl_workorders AWO,
                 ahl_visits_b VST,
                 ahl_visit_tasks_b TSK,
                 ahl_unit_config_headers UCH,
                 ahl_mc_headers_b MCH
         WHERE   AWO.VISIT_TASK_ID=TSK.VISIT_TASK_ID
         AND     VST.VISIT_ID = TSK.VISIT_ID
         AND     AHL_UTIL_UC_PKG.GET_UC_HEADER_ID(NVL(TSK.INSTANCE_ID,VST.ITEM_INSTANCE_ID)) =  UCH.unit_config_header_id
         AND     MCH.mc_header_id = UCH.master_config_id
         AND     workorder_id = c_workorder;

      CURSOR c_get_route_details(c_route_id NUMBER)
      IS
         SELECT   enigma_doc_id,model_code
         FROM     ahl_routes_b
         WHERE    route_id = c_route_id;

      p_relationship_id          NUMBER;
      l_instance_id              NUMBER;
      l_rel_id                   NUMBER;

   BEGIN
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Entered');
      END IF;

      -- log the input
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'p_primary_object_id:' || p_primary_object_id);
         fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'p_secondary_object_id:'||p_secondary_object_id);
         fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'p_object_type:'||p_object_type);
      END IF;


      -- Object Type is MC and the object id is relationship id
      IF (p_object_type = 'MC') THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Object Type is MC');
         END IF;

         OPEN  get_model_and_ata_csr(p_primary_object_id);
         FETCH get_model_and_ata_csr  INTO x_model,x_ata_code;
         CLOSE get_model_and_ata_csr;

         x_tail_number  := '';
         x_doc_id       := replace(x_ata_code,'-');
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Model->' || x_model);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'ATA Code->' || x_ata_code);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Tail Number->' || x_tail_number);
         END IF;

      -- SATHAPLI::Enigma code changes, 19-Sep-2008 - UC handling is done in the class AhlEnigmaDocHelper itself.
      /*
      -- object type is UC
      ELSIF (p_object_type = 'UC') THEN
         -- Use instance id to get the details
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Object Type is UC');
         END IF;
         IF (p_primary_object_id IS NOT NULL AND p_primary_object_id <> 0) THEN
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Instance ID will be used to get the details');
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'p_primary_object_id->' || p_primary_object_id);
            END IF;
            x_tail_number := AHL_UTIL_UC_PKG.get_unit_name(p_primary_object_id);
            p_relationship_id := AHL_UTIL_UC_PKG.Map_Instance_to_RelID(p_primary_object_id);
            OPEN  get_model_and_ata_csr(p_relationship_id);
            FETCH get_model_and_ata_csr INTO x_model,x_ata_code;
            CLOSE get_model_and_ata_csr;
            x_doc_id := replace(x_ata_code,'-');
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Relationship Id->' || p_relationship_id);
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Model->' || x_model);
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'ATA Code->' || x_ata_code);
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Tail Number->' || x_tail_number);
            END IF;
         ELSE
         -- There is no instance at this node, which means we will have to show the details for the complete UC
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Node has no instance,UC header id will be used');
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'p_secondary_object_id->' || p_secondary_object_id);
            END IF;
            --x_doc_id := replace(x_ata_code,'-');
						--*******************************
						--mpothuku changed on 29-Dec-06
						--For now if the instance is not present, we represent the ATA Code as 11, we essentially need to retrieve the
						--relationship_id in this case as well. But we are planning to do this at a later point
						x_doc_id := 11;
            OPEN get_model_and_tail_csr(p_secondary_object_id);
            FETCH get_model_and_tail_csr INTO x_tail_number,x_model;
            CLOSE get_model_and_tail_csr;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Model->' || x_model);
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'ATA Code->' || x_ata_code);
               fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Tail Number->' || x_tail_number);
            END IF;
         END IF;
         */

      ELSIF (p_object_type = 'WO') THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Object Type is WO');
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Workorder Id is ->' || p_primary_object_id);
         END IF;

         -- get the doc id
         OPEN get_doc_id(p_primary_object_id);
         FETCH get_doc_id INTO x_doc_id;
         IF get_doc_id%NOTFOUND THEN
            x_doc_id := NULL;
         END IF;
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Document Id is->' || x_doc_id);
         END IF;

         -- get the model
         OPEN get_wo_model_tail_csr(p_primary_object_id);
         FETCH get_wo_model_tail_csr INTO x_model,x_tail_number,l_instance_id;
         IF get_wo_model_tail_csr%NOTFOUND THEN
            x_model := NULL;
            x_tail_number := NULL;
            l_instance_id := NULL;
         END IF;
         IF l_instance_id IS NOT NULL THEN
            l_rel_id := AHL_UTIL_UC_PKG.Map_Instance_to_RelID(l_instance_id);
            OPEN  get_model_and_ata_csr(l_rel_id);
            FETCH get_model_and_ata_csr  INTO x_model,x_ata_code;
            CLOSE get_model_and_ata_csr;
         END IF;
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'x_model ->' || x_doc_id);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'x_tail_number ->' || x_tail_number);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'l_instance_id ->' || l_instance_id);
         END IF;

      ELSIF (p_object_type = 'WO_MC_DOC') THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Object Type is WO');
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Workorder Id is ->' || p_primary_object_id);
         END IF;

         -- get the model
         OPEN get_wo_model_tail_csr(p_primary_object_id);
         FETCH get_wo_model_tail_csr INTO x_model,x_tail_number,l_instance_id;
         IF get_wo_model_tail_csr%NOTFOUND THEN
            x_model := NULL;
            x_tail_number := NULL;
            l_instance_id := NULL;
         END IF;
         IF l_instance_id IS NOT NULL THEN
            l_rel_id := AHL_UTIL_UC_PKG.Map_Instance_to_RelID(l_instance_id);
            OPEN  get_model_and_ata_csr(l_rel_id);
            FETCH get_model_and_ata_csr  INTO x_model,x_ata_code;
            CLOSE get_model_and_ata_csr;
         END IF;

         x_doc_id := replace(x_ata_code,'-');

         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'x_model ->' || x_model);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'x_doc_id ->' || x_doc_id);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'l_rel_id ->' || l_rel_id);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'x_tail_number ->' || x_tail_number);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'l_instance_id ->' || l_instance_id);
         END IF;

      ELSIF (p_object_type = 'RT') THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Object Type is RT');
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Route Id is ->' || p_primary_object_id);
         END IF;
         OPEN  c_get_route_details(p_primary_object_id);
         FETCH c_get_route_details INTO x_doc_id,x_model;
         CLOSE c_get_route_details;
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Doc Id is:' || x_doc_id);
            fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'Model is :' || x_model);
         END IF;
      END IF;

      OPEN get_user_and_lang;
      FETCH get_user_and_lang INTO x_user_name,x_user_lang;
      CLOSE get_user_and_lang;
      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'user name->' || x_user_name);
         fnd_log.string(fnd_log.level_statement,'ahl.plsql.'||G_PKG_NAME||'.'||l_api_name,'user lang->' || x_user_lang);
      END IF;
   END get_enigma_url_params;


  ----------------------------------------------------------------------------------------------------------
	-- Declare Procedures --
	---------------------------------------------------------------------------------------------------------
	-- Start of Comments --
	--  Procedure name		: is_task_card_enabled
	--  Function				: Returns a boolean, depending on which task card icon is shown
	--  get_enigma_url_params Parameters:
   --             p_workorder_id       :     Workorder Id
   --  End of Comments.
	---------------------------------------------------------------------------------------------------------
FUNCTION IS_TASK_CARD_ENABLED (
                  p_workorder_id   IN    NUMBER)
RETURN VARCHAR2 IS
   l_doc_id                VARCHAR2(80);
   l_show_task_card        VARCHAR2(1) := 'Y';
   l_dont_show_task_card   VARCHAR2(1) := 'N';
   l_amm_doc_avail         VARCHAR2(80);
BEGIN
   l_doc_id    := NULL;
   BEGIN
      SELECT   enigma_doc_id
      INTO     l_doc_id
      FROM     ahl_routes_b RT,ahl_workorders WO
      WHERE    WO.workorder_id = p_workorder_id
      AND      WO.route_id = RT.route_id;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RETURN l_dont_show_task_card;
      WHEN OTHERS THEN
         RETURN l_dont_show_task_card;
   END;

   IF l_doc_id IS NULL THEN
      RETURN l_dont_show_task_card;
   END IF;

   SELECT trim(fnd_profile.value('AHL_ENIGMA_AMM_DOC_AVLBL')) INTO l_amm_doc_avail FROM dual;
   IF l_amm_doc_avail = 'Y' THEN
      RETURN l_show_task_card;
   ELSE
      RETURN
         l_dont_show_task_card;
   END IF;
END;
END AHL_ENIGMA_UTIL_PKG;

/
