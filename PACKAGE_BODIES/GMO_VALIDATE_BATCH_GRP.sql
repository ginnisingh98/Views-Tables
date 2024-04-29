--------------------------------------------------------
--  DDL for Package Body GMO_VALIDATE_BATCH_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMO_VALIDATE_BATCH_GRP" 
/* $Header: GMOBAVAB.pls 120.7 2006/03/27 23:30:17 rahugupt noship $ */
AS

--The package name
G_PKG_NAME           CONSTANT VARCHAR2(30) := 'GMO_VALIDATE_BATCH_GRP';

FUNCTION IS_PIS_PENDING (P_ENTITY_NAME VARCHAR2,
                         P_ENTITY_KEY VARCHAR2,
                         P_INSTRUCTION_TYPE VARCHAR2,
                         x_msg_data IN OUT NOCOPY   VARCHAR2) RETURN BOOLEAN IS

  l_instruction_set_id number;
  l_return_status varchar2(100);
  l_msg_count number;
  l_msg_data varchar2(4000);
  L_TOTAL_INSTRUCTIONS NUMBER;
  L_OPTIONAL_PENDING_INSTR NUMBER;
  L_MANDATORY_PENDING_INSTR NUMBER;
  L_INSTRUCTION_PENDING VARCHAR2(5);
  INSTRUCTION_EXCEPTION EXCEPTION;

BEGIN
       GMO_INSTRUCTION_PVT.HAS_PENDING_INSTRUCTIONS(P_ENTITY_NAME =>P_ENTITY_NAME,
                                                  P_ENTITY_KEY =>P_ENTITY_KEY,
                                                  P_INSTRUCTION_TYPE =>P_INSTRUCTION_TYPE,
                                                  X_INSTRUCTION_PENDING =>L_INSTRUCTION_PENDING,
                                                  X_TOTAL_INSTRUCTIONS => L_TOTAL_INSTRUCTIONS,
                                                  X_OPTIONAL_PENDING_INSTR =>L_OPTIONAL_PENDING_INSTR,
                                                  X_MANDATORY_PENDING_INSTR =>L_MANDATORY_PENDING_INSTR,
                                                  X_RETURN_STATUS =>l_return_status,
                                                  X_MSG_COUNT =>l_msg_count,
                                                  X_MSG_DATA  =>x_msg_data);
     IF(l_return_status<> FND_API.G_RET_STS_SUCCESS ) THEN
       RAISE INSTRUCTION_EXCEPTION;
     END IF;
     IF (L_MANDATORY_PENDING_INSTR > 0) THEN
       return FALSE;
     ELSE
       return TRUE;
     END IF;

EXCEPTION
 WHEN INSTRUCTION_EXCEPTION THEN
     FND_MESSAGE.SET_ENCODED(x_msg_data);
     RAISE INSTRUCTION_EXCEPTION;
END;




-- Start of comments
-- API name             : VALIDATE_BATCH_COMPLIANCE
-- Type                 : Public.

-- Function             : This procedure implements the following:
--                        1. Validates the batch ID or batch step ID. If validation fails it returns an error status.

--                        2. Navigates through the batch hierarchy to identify any pending instructions.
--                           If pending instructions

--                           do exist then an entry is made for the same in the Audit table.
--                        3. Navigates through the batch hierarchy to identify any pending deviations and audits the same.

--                        4. Returns a unique validation ID and a validation status back to the calling program.


-- Pre-reqs             : None.
-- Parameters           :
-- IN                   :P_API_VERSION(Required)      - NUMBER   - Specifies the API version.

--                       P_INIT_MSG_LIST(Optional)    - VARCHAR2 - Specifies if the message list should be initialized.

--                       Default = FND_API.G_FALSE

--                       P_ENTITY_NAME(Required)      - VARCHAR2 - The entity to be validated. It takes only the following values.

--                       - 1. GMO_CONSTANTS_GRP.ENTITY_BATCH for validating a batch

--                       - 2. GMO_CONSTANTS_GRP.ENTITY_OPERATION for validating a batch step.

--                       - If any other value is provided then the API will error out.


PROCEDURE VALIDATE_BATCH_COMPLIANCE
(P_API_VERSION          IN         NUMBER,
 P_INIT_MSG_LIST        IN         VARCHAR2 DEFAULT FND_API.G_FALSE,
 X_RETURN_STATUS        OUT NOCOPY VARCHAR2,
 X_MSG_COUNT            OUT NOCOPY NUMBER,
 X_MSG_DATA             OUT NOCOPY VARCHAR2,
 P_ENTITY_NAME          IN         VARCHAR2,
 P_ENTITY_KEY           IN         VARCHAR2,
 X_VALIDATION_ID        OUT NOCOPY NUMBER,
 X_VALIDATION_STATUS    OUT NOCOPY VARCHAR2) IS

  l_batchstep_id number;
  l_resources varchar2(16);
  l_material_detail_id number;
  l_batchstep_activity_id number;
  l_batchstep_resource_id number;
  l_dispense_id     number;
  l_undispense_id     number;
  l_ncm_count       number;
  l_entity_type     CONSTANT VARCHAR2(30) :='DISPENSE';
  l_entity_name     CONSTANT VARCHAR2(30) :='DISPENSE_ITEM';
  l_rev_disp_type   CONSTANT VARCHAR2(30) :='REVERSE_DISPENSE';

  INSTRUCTIONS_PENDING exception;
  NCM_NOT_CLOSED  exception;
  INSTRUNCTION_EXCEPTION EXCEPTION;
  cursor c_get_steps is
    select batchstep_id
    from gme_batch_steps
    where ((GMO_CONSTANTS_GRP.ENTITY_BATCH = P_ENTITY_NAME AND batch_id = p_entity_key) OR
           (GMO_CONSTANTS_GRP.ENTITY_OPERATION = P_ENTITY_NAME AND batchstep_id = p_entity_key));

  cursor c_get_activities is
    select batchstep_activity_id
    from  gme_batch_step_activities
    where batchstep_id = l_batchstep_id;

  cursor c_get_resources is
    select batchstep_resource_id
    from   gme_batch_step_resources gbsr
    where  batchstep_activity_id = l_batchstep_activity_id;

  cursor c_get_materials is
    select material_detail_id
    from gme_material_details
    where batch_id = p_entity_key;

  cursor c_get_step_materials is
    select material_detail_id
    from gme_batch_step_items
    where batchstep_id = l_batchstep_id;

  CURSOR C_GET_DISPENSES IS
    SELECT Dispense_id
    from gmo_material_dispenses
    WHERE  material_status = 'DISPENSD'
      and  material_detail_id = l_material_detail_id;

  CURSOR C_GET_unDISPENSES IS
    SELECT unDispense_id
    from gmo_material_undispenses
    WHERE  material_status = 'DISPENSD'
      and  material_detail_id = l_material_detail_id;

BEGIN

  -- Process Batch Steps
  open c_get_steps;
  LOOP
    FETCH c_get_steps into l_batchstep_id;
    EXIT WHEN c_get_steps%NOTFOUND;

    -- Check for pending mandatory instructions

    IF NOT IS_PIS_PENDING (P_ENTITY_NAME => GMO_CONSTANTS_GRP.ENTITY_OPERATION,
                         P_ENTITY_KEY => l_batchstep_id,
                         P_INSTRUCTION_TYPE => GMO_CONSTANTS_GRP.VBATCH_INSTRUCTION_TYPE,
                         x_msg_data => x_msg_data )
    THEN
      close c_get_steps;
      RAISE INSTRUCTIONS_PENDING;
    END IF;

    -- Check for NCM

    -- Process Activities

    open c_get_activities;
    LOOP
      FETCH c_get_activities into l_batchstep_activity_id;
      EXIT WHEN c_get_activities%NOTFOUND;

      -- Check for pending mandatory instructions

      IF NOT IS_PIS_PENDING (P_ENTITY_NAME => GMO_CONSTANTS_GRP.ENTITY_ACTIVITY,
                         P_ENTITY_KEY => l_batchstep_activity_id,
                         P_INSTRUCTION_TYPE => GMO_CONSTANTS_GRP.VBATCH_INSTRUCTION_TYPE,
                         x_msg_data => x_msg_data)
      THEN
        close c_get_activities;
        RAISE INSTRUCTIONS_PENDING;
      END IF;
    -- Check for NCM


        -- Process resources

        open c_get_resources;
        LOOP
          FETCH c_get_resources into l_batchstep_resource_id;
          EXIT WHEN c_get_resources%NOTFOUND;

          -- Check for pending mandatory instructions

          IF NOT IS_PIS_PENDING(P_ENTITY_NAME => GMO_CONSTANTS_GRP.ENTITY_RESOURCE,
                             P_ENTITY_KEY => l_batchstep_resource_id,
                             P_INSTRUCTION_TYPE => GMO_CONSTANTS_GRP.VBATCH_INSTRUCTION_TYPE,
                             x_msg_data => x_msg_data)
          THEN
            close c_get_resources;
            RAISE INSTRUCTIONS_PENDING;
          END IF;

           -- Check for NCM
         END LOOP;
         close c_get_resources;
     END LOOP;
     close c_get_activities;
  END LOOP;
  close c_get_steps;

  -- Process material lines
  IF GMO_CONSTANTS_GRP.ENTITY_BATCH = P_ENTITY_NAME THEN
    open c_get_materials;
    LOOP
      FETCH c_get_materials  into l_material_detail_id;
      EXIT WHEN c_get_materials%NOTFOUND;

      -- Check for pending mandatory instructions
      IF NOT IS_PIS_PENDING (P_ENTITY_NAME => GMO_CONSTANTS_GRP.ENTITY_MATERIAL,
                         P_ENTITY_KEY => l_material_detail_id,
                         P_INSTRUCTION_TYPE => GMO_CONSTANTS_GRP.VBATCH_INSTRUCTION_TYPE,
                         x_msg_data => x_msg_data)
      THEN
        close c_get_materials;
        RAISE INSTRUCTIONS_PENDING;
      END IF;
       -- Check for pending PIs of dispense rows
       open C_GET_DISPENSES;
       LOOP
         FETCH C_GET_DISPENSES  into l_dispense_id;
         EXIT WHEN C_GET_DISPENSES%NOTFOUND;
         -- Check for pending mandatory instructions
         IF NOT IS_PIS_PENDING (P_ENTITY_NAME => l_entity_name,
                            P_ENTITY_KEY => l_dispense_id,
                            P_INSTRUCTION_TYPE => l_entity_type,
                            x_msg_data => x_msg_data)
         THEN
           close C_GET_DISPENSES;
           RAISE INSTRUCTIONS_PENDING;
         END IF;
        END LOOP;
       close C_GET_DISPENSES;

       -- Check for pending PIs of undispense rows
       --Bug 5120934: start
       open C_GET_unDISPENSES;
       --Bug 5120934: end
       LOOP
         FETCH C_GET_unDISPENSES  into l_undispense_id;
         EXIT WHEN C_GET_unDISPENSES%NOTFOUND;
         -- Check for pending mandatory instructions
         IF NOT  IS_PIS_PENDING (P_ENTITY_NAME => l_entity_name,
                            P_ENTITY_KEY => l_undispense_id,
                            P_INSTRUCTION_TYPE => l_rev_disp_type,
                            x_msg_data => x_msg_data)
         THEN
           close C_GET_UNDISPENSES;
           RAISE INSTRUCTIONS_PENDING;
         END IF;
        END LOOP;
       close C_GET_UNDISPENSES;

     END LOOP;
     close c_get_materials;

     -- Chenck for NCM
      select count(*) into l_ncm_count
      from qa_results_v
      where PROCESS_BATCH_ID = p_entity_key
        and NONCONFORMANCE_STATUS <> 'CLOSED';
      IF l_ncm_count > 0 THEN
        raise NCM_NOT_CLOSED;
      END IF;

   ELSIF GMO_CONSTANTS_GRP.ENTITY_OPERATION = P_ENTITY_NAME THEN
    l_batchstep_id := p_entity_key;
    open c_get_step_materials;
    LOOP
      FETCH c_get_step_materials into l_material_detail_id;
      EXIT WHEN c_get_step_materials%NOTFOUND;

      -- Check for pending mandatory instructions
      IF NOT IS_PIS_PENDING (P_ENTITY_NAME => GMO_CONSTANTS_GRP.ENTITY_MATERIAL,
                         P_ENTITY_KEY => l_material_detail_id,
                         P_INSTRUCTION_TYPE => GMO_CONSTANTS_GRP.VBATCH_INSTRUCTION_TYPE,
                         x_msg_data => x_msg_data)
      THEN
        close c_get_step_materials;
        RAISE INSTRUCTIONS_PENDING;
      END IF;

       -- Check for pending PIs of dispense rows
       open C_GET_DISPENSES;
       LOOP
         FETCH C_GET_DISPENSES  into l_dispense_id;
         EXIT WHEN C_GET_DISPENSES%NOTFOUND;
         -- Check for pending mandatory instructions
         IF NOT IS_PIS_PENDING (P_ENTITY_NAME => l_entity_name,
                            P_ENTITY_KEY => l_dispense_id,
                            P_INSTRUCTION_TYPE => l_entity_type,
                            x_msg_data => x_msg_data)
         THEN
           close C_GET_DISPENSES;
           RAISE INSTRUCTIONS_PENDING;
         END IF;
        END LOOP;
       close C_GET_DISPENSES;
       -- Check for pending PIs of undispense rows
       --Bug 5120934: start
       open C_GET_unDISPENSES;
       --Bug 5120934: end
       LOOP
         FETCH C_GET_unDISPENSES  into l_undispense_id;
         EXIT WHEN C_GET_unDISPENSES%NOTFOUND;
         -- Check for pending mandatory instructions
         IF IS_PIS_PENDING (P_ENTITY_NAME => l_entity_name,
                            P_ENTITY_KEY => l_undispense_id,
                            P_INSTRUCTION_TYPE => l_rev_disp_type,
                            x_msg_data => x_msg_data)
         THEN
           close C_GET_UNDISPENSES;
           RAISE INSTRUCTIONS_PENDING;
         END IF;
        END LOOP;
       close C_GET_UNDISPENSES;

     END LOOP;
     close c_get_step_materials;

     -- Chenck for NCM
      select count(*) into l_ncm_count
      from qa_results_v
      where PROCESS_BATCHSTEP_ID = p_entity_key
        and NONCONFORMANCE_STATUS <> 'CLOSED';
      IF l_ncm_count > 0 THEN
        raise NCM_NOT_CLOSED;
      END IF;

   END IF;



  X_RETURN_STATUS     := 'S';
  X_VALIDATION_STATUS := 'S';
  X_VALIDATION_ID      := 1000;
EXCEPTION WHEN INSTRUCTIONS_PENDING THEN
  FND_MESSAGE.SET_NAME('GMO','GMO_INSTRUCTION_PENDING');
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
  X_RETURN_STATUS := 'E';
  X_VALIDATION_STATUS := 'E';
  if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_VALIDATE_BATCH_GRP.VALIDATE_BATCH_COMPLIANCE',
                      FALSE
                       );
  end if;
WHEN NCM_NOT_CLOSED THEN
  FND_MESSAGE.SET_NAME('GMO','GMO_NOT_ALL_NCMS_CLOSED');
  FND_MSG_PUB.ADD;
  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
  X_RETURN_STATUS := 'E';
  X_VALIDATION_STATUS := 'E';
  if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_VALIDATE_BATCH_GRP.VALIDATE_BATCH_COMPLIANCE',
                      FALSE
                       );
  end if;
 WHEN  INSTRUNCTION_EXCEPTION THEN
  FND_MSG_PUB.Count_And_Get (p_count => x_msg_count, p_data => x_msg_data);
  X_RETURN_STATUS := 'E';
  X_VALIDATION_STATUS := 'E';
  if (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
      FND_LOG.MESSAGE(FND_LOG.LEVEL_EXCEPTION,
                      'gmo.plsql.GMO_VALIDATE_BATCH_GRP.VALIDATE_BATCH_COMPLIANCE',
                      FALSE
                       );
  end if;
END VALIDATE_BATCH_COMPLIANCE;

END GMO_VALIDATE_BATCH_GRP;

/
