--------------------------------------------------------
--  DDL for Package Body CS_SR_DELETE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_DELETE_UTIL" AS
/* $Header: csvsrdlb.pls 120.10 2008/01/24 10:51:53 nveerara ship $ */

--------------------------------------------------------------------------------
-- Package level definitions
--------------------------------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'CS_SR_DELETE_UTIL';

TYPE t_number_tbl       IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE t_date_tbl         IS TABLE OF DATE          INDEX BY BINARY_INTEGER;
TYPE t_string_tbl       IS TABLE OF VARCHAR2(3)   INDEX BY BINARY_INTEGER;
TYPE t_long_string_tbl  IS TABLE OF VARCHAR2(256) INDEX BY BINARY_INTEGER;

PROCEDURE Delete_Contacts
(
  p_api_version_number        IN         NUMBER := 1.0
, p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE
, p_commit                    IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type               IN         VARCHAR2
, p_processing_set_id         IN         NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Audit_Records
(
  p_api_version_number        IN         NUMBER := 1.0
, p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE
, p_commit                    IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type               IN         VARCHAR2
, p_processing_set_id         IN         NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE Delete_Sr_Attributes
(
  p_api_version_number        IN         NUMBER := 1.0
, p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE
, p_commit                    IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type               IN         VARCHAR2
, p_processing_set_id         IN         NUMBER
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Purgeaudit_Records
(
  p_api_version_number        IN         NUMBER := 1.0
, p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE
, p_commit                    IN         VARCHAR2 := FND_API.G_FALSE
, p_purge_set_id              IN         NUMBER
, p_incident_id_tbl           IN         t_number_tbl
, p_incident_number_tbl       IN         t_long_string_tbl
, p_incident_type_id_tbl      IN         t_number_tbl
, p_customer_id_tbl           IN         t_number_tbl
, p_inv_organization_id_tbl   IN         t_number_tbl
, p_inventory_item_id_tbl     IN         t_number_tbl
, p_customer_product_id_tbl   IN         t_number_tbl
, p_inc_creation_date_tbl     IN         t_date_tbl
, p_inc_last_update_date_tbl  IN         t_date_tbl
, p_incident_id_tl_tbl        IN         t_number_tbl
, p_language_tbl              IN         t_string_tbl
, p_source_lang_tbl           IN         t_string_tbl
, p_summary_tbl               IN         t_long_string_tbl
, x_return_status             OUT NOCOPY VARCHAR2
, x_msg_count                 OUT NOCOPY NUMBER
, x_msg_data                  OUT NOCOPY VARCHAR2
);

PROCEDURE Check_User_Termination;

--------------------------------------------------------------------------------



--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_SR_VALIDATIONS
--
--  Parameters (other than standard ones)
--  IN
--    p_object_type                   :   Type of object for which this
--                                        procedure is being called. (Here it
--                                        will be 'SR')
--    p_processing_set_id             :   Id that helps the API in identifying
--                                        the set of SRs for which the child
--                                        objects have to be deleted.
--    p_purge_source_with_open_task   :   Indicates whether the SRs containing
--                                        OPEN non field service tasks should
--                                        be purged or not
--  Description
--      This API physically removes the SRs and all its child objects after
--      performing validations wherever required. This is a wrapper which
--      delegates the work to another helper API named
--      cs_sr_delete_util.delete_servicerequest
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This API physically removes the SRs and all its child objects after
 * performing validations wherever required. This is a wrapper which delegates
 * the work to another helper API named cs_sr_delete_util.delete_servicerequest
 * @param p_object_type Type of object for which this procedure is being called.
 * (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child objects have to be deleted.
 * @param p_purge_source_with_open_task Indicates whether the SRs containing
 * OPEN non field service tasks should be purged or not
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Service Request Delete Validations
 */
PROCEDURE Delete_Sr_Validations
(
  p_api_version_number          IN         NUMBER := 1.0
, p_init_msg_list               IN         VARCHAR2 := FND_API.G_FALSE
, p_commit                      IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type                 IN         VARCHAR2
, p_processing_set_id           IN         NUMBER
, p_purge_source_with_open_task IN         VARCHAR2
, x_return_status               OUT NOCOPY VARCHAR2
, x_msg_count                   OUT NOCOPY NUMBER
, x_msg_data                    OUT NOCOPY VARCHAR2
)
IS
--------------------------------------------------------------------------------

L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'DELETE_SR_VALIDATIONS';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

x_msg_index_out NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_purge_source_with_open_task:' || p_purge_source_with_open_task
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_object_type:' || p_object_type
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'p_processing_set_id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_purge_source_with_open_task IS NULL
  OR NVL(p_purge_source_with_open_task, 'X') NOT IN ('Y', 'N')
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'p_purge_source_with_open_task_invalid'
      , 'p_purge_source_with_open_task value is invalid.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_purge_source_with_open_task');
    FND_MESSAGE.Set_Token
    (
      'CURRVAL'
    , NVL
      (
        p_purge_source_with_open_task
      , 'NULL'
      )
    );
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'field_service_valid_start'
      , 'calling the Field Service validation API '
        || 'csf_maintain_grp.validate_fieldserviceobjects'
      );
    END IF ;

    -- The following procedure call checks if the field service tasks linked to
    -- an SR are deletable. The result of this validation is reflected in the
    -- purge_status column of the global temp table.

    CSF_MAINTAIN_GRP.Validate_FieldServiceObjects
    (
      p_api_version       => '1.0'
    , p_init_msg_list     => FND_API.G_FALSE
    , p_commit            => FND_API.G_FALSE
    , p_processing_set_id => p_processing_set_id
    , p_object_type       => p_object_type
    , x_return_status     => x_return_status
    , x_msg_count         => x_msg_count
    , x_msg_data          => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'field_service_valid_end'
      , 'returned from Field Service validation API with status '
        || x_return_status
      );
    END IF;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'charges_valid_start'
      , 'calling the Charges validation API '
        || 'cs_charge_details_pvt.purge_chg_validations'
      );
    END IF ;

    -- The following procedure call checks if the charge lines linked to
    -- an SR are deletable. The result of this validation is reflected in the
    -- purge_status column of the global temp table.

    CS_CHARGE_DETAILS_PVT.Purge_Chg_Validations
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'charges_valid_end'
      , 'returned from Charges validation API with status ' || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'task_valid_start'
      , 'calling the Tasks validation API cac_task_purge_pub.validate_tasks'
      );
    END IF ;

    -- The following procedure call checks if the non-field service Tasks linked
    -- to an SR are deletable. The result of this validation is reflected in the
    -- purge_status column of the global temp table.

    CAC_TASK_PURGE_PUB.Validate_Tasks
    (
      p_api_version                 => '1.0'
    , p_init_msg_list               => FND_API.G_FALSE
    , p_commit                      => FND_API.G_FALSE
    , p_processing_set_id           => p_processing_set_id
    , p_object_type                 => p_object_type
    , p_purge_source_with_open_task => p_purge_source_with_open_task
    , x_return_status               => x_return_status
    , x_msg_count                   => x_msg_count
    , x_msg_data                    => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'task_valid_end'
      , 'returned from Tasks validation API with status ' || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
        FOR
          i IN 1..x_msg_count
        LOOP
          FND_MSG_PUB.Get
          (
            p_msg_index     => i
          , p_encoded       => 'F'
          , p_data          => x_msg_data
          , p_msg_index_out => x_msg_index_out
          );
          fnd_log.string
          (
            fnd_log.level_unexpected
          , L_LOG_MODULE || 'unexpected_error'
          , 'Error encountered is : ' || x_msg_data || ' [Index:'
            || x_msg_index_out || ']'
          );
        END LOOP;
      END IF ;
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_DEL_VAL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Delete_Sr_Validations;

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_SERVICEREQUEST
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type               :   Type of object for which this procedure
--                                      is being called. (Here it will be 'SR')
--      p_processing_set_id         :   Id that helps the API in identifying the
--                                      set of SRs for which the child objects
--                                      have to be deleted.
--      p_purge_set_id              :   Id that helps identify a set of SRs that
--                                      were purged in a single batch. This can
--                                      be passed as NULL if the SR Delete API
--                                      is called separately. In that case, the
--                                      purge_set_id will be generated in this
--                                      procedure.
--      p_audit_required            :   Indicates if audit information has to be
--                                      generated after purging the service
--                                      requests
--  Description
--      This API physically removes the SRs and all its child objects after
--      performing validations wherever required. This procedure calls the
--      delete APIs for deleting child objects and directly deletes the rows
--      in the tables cs_incidents_all_b and tl.
--      This procedure also updates the staging table with the errors generated
--      while performing validations on SRs with all child objects so that
--      a log of these errors can be generated at the end of the purge process.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This API physically removes the SRs and all its child objects after
 * performing validations wherever required. This procedure calls the delete
 * APIs for deleting child objects and directly deletes the rows in the tables
 * cs_incidents_all_b and tl. This procedure also updates the staging table
 * with the errors generated while performing validations on SRs with all child
 * objects so that a log of these errors can be generated at the end of the
 * purge process.
 * @param p_object_type Type of object for which this procedure is being
 * called. (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child objects have to be deleted.
 * @param p_purge_set_id Id that helps identify a set of SRs that were purged
 * in a single batch. This can be passed as NULL if the SR Delete API is called
 * separately. In that case, the purge_set_id will be generated in this
 * procedure.
 * @param p_audit_required Indicates if audit information has to be generated
 * after purging the service requests
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Delete Service Request Helper Procedure
 */
PROCEDURE Delete_ServiceRequest
(
  p_api_version_number IN         NUMBER := 1.0
, p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE
, p_commit             IN         VARCHAR2 := FND_API.G_FALSE
, p_purge_set_id       IN         NUMBER
, p_processing_set_id  IN         NUMBER
, p_object_type        IN         VARCHAR2
, p_audit_required     IN         VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER := 1.0;
L_API_NAME      CONSTANT VARCHAR2 (30) := 'DELETE_SERVICEREQUEST';
L_API_NAME_FULL CONSTANT VARCHAR2 (61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

x_msg_index_out            NUMBER;

l_purge_set_id             NUMBER := p_purge_set_id;
l_row_count                NUMBER;

l_incident_id_tbl          t_number_tbl;
l_incident_number_tbl      t_long_string_tbl;
l_incident_type_id_tbl     t_number_tbl;
l_customer_id_tbl          t_number_tbl;
l_inv_organization_id_tbl  t_number_tbl;
l_inventory_item_id_tbl    t_number_tbl;
l_customer_product_id_tbl  t_number_tbl;
l_inc_creation_date_tbl    t_date_tbl;
l_inc_last_update_date_tbl t_date_tbl;
l_incident_id_status_tbl   t_number_tbl;
l_purge_error_message_tbl  t_long_string_tbl;
l_incident_id_tl_tbl       t_number_tbl;
l_language_tbl             t_string_tbl;
l_source_lang_tbl          t_string_tbl;
l_summary_tbl              t_long_string_tbl;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 6'
    , 'p_purge_set_id:' || p_purge_set_id
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 7'
    , 'p_audit_required:' || p_audit_required
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF
    FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Parameter Validations:
  ------------------------------------------------------------------------------

  IF  p_audit_required IS NULL
  OR  NVL(p_audit_required, 'X') NOT IN ('Y', 'N')
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
          fnd_log.level_unexpected
      , L_LOG_MODULE || 'audit_required_invalid'
      , 'p_audit_required has to be Y/N.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_audit_required');
    FND_MESSAGE.Set_Token('CURRVAL', p_audit_required);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF NVL(p_object_type, 'X') <> 'SR'
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'object_type_invalid'
      , 'p_object_type has to be SR.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_object_type');
    FND_MESSAGE.Set_Token('CURRVAL', p_object_type);
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ---

  IF p_processing_set_id IS NULL
  THEN
    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'proc_set_id_invalid'
      , 'Processing Set Id should not be NULL.'
      );
    END IF ;

    FND_MESSAGE.Set_Name('CS', 'CS_SR_PARAM_VALUE_ERROR');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('PARAM', 'p_processing_set_id');
    FND_MESSAGE.Set_Token('CURRVAL', NVL(to_char(p_processing_set_id),'NULL'));
    FND_MSG_PUB.ADD;

    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  -- If the purge_set_id is null it means that this code is
  -- not called from the purge concurrent program but from
  -- some other consumer of the delete API. Hence generating
  -- a new purge_set_id before deleting the SR and child data.

  IF l_purge_set_id IS NULL
  THEN
    SELECT
      cs_incidents_purge_set_s.NEXTVAL
    INTO
      l_purge_set_id
    FROM
      dual
    WHERE
      ROWNUM = 1;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'gen_purge_set_id'
      , 'Generated a new purge_set_id ' || l_purge_set_id
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'field_service_purge_start'
      , 'calling the Field Service purge API '
        || 'csf_maintain_grp.purge_fieldserviceobjects'
      );
    END IF ;

    -- This procedure deletes all the field service tasks that are related to
    -- SRs that are available in the global temp table with purge status NULL.

    CSF_MAINTAIN_GRP.Purge_FieldServiceObjects
    (
      p_api_version        => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'field_service_purge_end'
      , 'returned from Field Service purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'charges_purge_start'
      , 'calling the Charges purge API '
        || 'cs_charge_details_pvt.purge_charges'
      );
    END IF ;

    -- This procedure deletes all the charge lines that are related to
    -- SRs that are available in the global temp table with purge status NULL.

    CS_CHARGE_DETAILS_PVT.Purge_Charges
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'charges_purge_end'
      , 'returned from Charges purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---


--Added for 12.1 Service Costing

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'cost_purge_start'
      , 'calling the Cost purge API '
        || 'cs_cost_details_pvt.purge_cost'
      );
    END IF ;




 -- This procedure deletes all the charge lines that are related to
    -- SRs that are available in the global temp table with purge status NULL.

    CS_COST_DETAILS_PVT.Purge_Cost
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );


 IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'cost_purge_end'
      , 'returned from cost purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;






  ---

  Check_User_Termination;

  ---


  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'messages_purge_start'
      , 'calling the Messages purge API cs_messages_pkg.delete_message'
      );
    END IF ;

    -- This procedure deletes all the messages that are related to
    -- SRs that are available in the global temp table with purge status NULL.

    CS_MESSAGES_PKG.Delete_Message
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'messages_purge_end'
      , 'returned from Messages purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'contacts_purge_start'
      , 'calling the Contacts purge API '
        || 'cs_sr_delete_util.delete_contacts'
      );
    END IF ;

    -- This procedure deletes all the contacts related to SRs present in the
    -- global temp table with purge status NULL, and also the contact audit
    -- information, party role extended attributes and party role extended
    -- attributes audit information related to the contacts.

    CS_SR_DELETE_UTIL.Delete_Contacts
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'contacts_purge_end'
      , 'returned from Contacts purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'sr_attr_purge_start'
      , 'calling the SR Extended Attribs purge API '
        || 'cs_sr_delete_util.delete_sr_attributes'
      );
    END IF ;

    -- This procedure deletes all the extended attributes related to SRs
    -- present in the global temp table with purge status NULL and also the
    -- audit information related to the extended attributes.

    CS_SR_DELETE_UTIL.Delete_Sr_Attributes
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'sr_attr_purge_end'
      , 'returned from SR Extended Attribs purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'sr_audit_purge_start'
      , 'calling the SR Audit purge API '
        || 'cs_sr_delete_util.delete_audit_records'
      );
    END IF ;

    -- This procedure deletes all the audit information related to SRs
    -- present in the global temp table with purge status NULL

    CS_SR_DELETE_UTIL.Delete_Audit_Records
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'sr_audit_purge_end'
      , 'returned from SR Audit purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'sr_link_purge_start'
      , 'calling the SR Links purge API '
        || 'cs_incidentlinks_pvt.delete_incidentlink'
      );
    END IF ;

    -- This procedure deletes all the SR links related to SRs present in the
    -- global temp table with purge status NULL

    CS_INCIDENTLINKS_PVT.Delete_IncidentLink
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'sr_link_purge_end'
      , 'returned from SR Links purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'km_link_purge_start'
      , 'calling the KM Links purge API '
        || 'cs_knowledge_grp.purge_knowledge_links'
      );
    END IF ;

    -- This procedure deletes all the KM solution links related to SRs
    -- present in the global temp table with purge status NULL

    CS_KNOWLEDGE_GRP.Purge_Knowledge_Links
    (
      p_api_version        => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'km_link_purge_end'
      , 'returned from KM Links purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'notes_purge_start'
      , 'calling the Notes purge API cac_note_purge_pub.purge_notes'
      );
    END IF ;

    -- This procedure deletes all the notes related to SRs present in the
    -- global temp table with purge status NULL

    CAC_NOTE_PURGE_PUB.Purge_Notes
    (
      p_api_version        => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'notes_purge_end'
      , 'returned from Notes purge API with status ' || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'task_purge_start'
      , 'calling the Tasks purge API cac_task_purge_pub.purge_task'
      );
    END IF ;

    -- This procedure deletes all the non-field service tasks related
    -- to SRs present in the global temp table with purge status NULL

    CAC_TASK_PURGE_PUB.Purge_Tasks
    (
      p_api_version        => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'task_purge_end'
      , 'returned from Tasks purge API with status ' || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'work_item_purge_start'
      , 'calling the UWQ Work Items purge API ieu_wr_pub.purge_wr_item'
      );
    END IF ;

    -- This procedure deletes all the UWQ work items related
    -- to SRs present in the global temp table with purge status NULL

    IEU_WR_PUB.Purge_Wr_Item
    (
      p_api_version_number => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'work_item_purge_end'
      , 'returned from UWQ Work Items purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'interaction_purge_start'
      , 'calling the Interactions purge API '
        || 'jtf_ih_purge.p_delete_interactions'
      );
    END IF ;

    -- This procedure deletes all the interactions and activities related
    -- to SRs present in the global temp table with purge status NULL

    JTF_IH_PURGE.P_Delete_Interactions
    (
      p_api_version        => '1.0'
    , p_init_msg_list      => FND_API.G_FALSE
    , p_commit             => FND_API.G_FALSE
    , p_processing_set_id  => p_processing_set_id
    , p_object_type        => p_object_type
    , x_return_status      => x_return_status
    , x_msg_count          => x_msg_count
    , x_msg_data           => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'interaction_purge_end'
      , 'returned from Interactions purge API with status '
        || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_srid_for_attach_del_start'
      , 'Collecting all the Incident_ids into a pl/sql table to '
        || 'delete attachments, one at a time'
      );
    END IF ;

    -- The following query collects all the incident ids for which attachments
    -- need to be deleted, into a pl/sql table since, in R12, FND does not have
    -- an API that can delete attachments in bulk.

    SELECT
        object_id
    BULK COLLECT INTO
        l_incident_id_tbl
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S';

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'get_srid_for_attach_del_end'
        , 'After collecting all the Incident_ids into a pl/sql table '
          || l_row_count || ' rows'
        );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF l_incident_id_tbl.COUNT > 0
    THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'attachment_purge_start'
        , 'calling the Attachments purge API '
          || 'fnd_attached_documents2_pkg.delete_attachments'
        );
      END IF ;

      -- This procedure deletes all the attachments related
      -- to SRs present in the global temp table with purge status NULL
      -- NOTE: THIS PROCEDURE DELETES ATTACHMENTS ONE AT A TIME.

      FOR j in l_incident_id_tbl.FIRST..l_incident_id_tbl.LAST
      LOOP
        FND_ATTACHED_DOCUMENTS2_PKG.Delete_Attachments
        (
          x_entity_name              => 'CS_INCIDENTS'
        , x_pk1_value                => l_incident_id_tbl(j)
        , x_pk2_value                => null
        , x_pk3_value                => null
        , x_pk4_value                => null
        , x_pk5_value                => null
        , x_delete_document_flag     => 'Y'
        , x_automatically_added_flag => null
        );
      END LOOP;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'attachment_purge_end'
        , 'returned from Attachments purge API with status '
          || x_return_status
        );
      END IF ;
    ELSIF l_incident_id_tbl.COUNT <= 0
    THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'attachment_purge_err'
        , 'while calling Attachments purge API l_incident_id_tbl has '
          || l_incident_id_tbl.COUNT || ' rows'
        );
      END IF ;
    END IF;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF  p_audit_required = 'Y'
  AND x_return_status = FND_API.G_RET_STS_SUCCESS

  -- If audit information is required as per profile option
  -- CS_SR_PURGE_AUDIT_REQUIRED, then proceed further

  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_srbinfo_for_audit_start'
      , 'Collecting information that has to be written to the '
        || 'CS_INCIDENTS_PURGE_AUDIT_B table'
      );
    END IF ;

    -- Collect all the information from the cs_incidents_all_b
    -- table that needs to be entered in the purge audit table

    SELECT
      incident_number
    , incident_type_id
    , customer_id
    , inv_organization_id
    , inventory_item_id
    , customer_product_id
    , creation_date
    , last_update_date
    BULK COLLECT INTO
      l_incident_number_tbl
    , l_incident_type_id_tbl
    , l_customer_id_tbl
    , l_inv_organization_id_tbl
    , l_inventory_item_id_tbl
    , l_customer_product_id_tbl
    , l_inc_creation_date_tbl
    , l_inc_last_update_date_tbl
    FROM
      cs_incidents_all_b c
    , jtf_object_purge_param_tmp j
    WHERE
        j.object_type = 'SR'
    AND j.object_id = c.incident_id
    AND NVL
        (
          j.purge_status
        , 'S'
        ) = 'S'
    AND j.processing_set_id = p_processing_set_id;

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_srbinfo_for_audit_end'
      , 'After collecting information that has to be written to the '
        || 'CS_INCIDENTS_PURGE_AUDIT_B table ' || l_row_count || ' rows'
      );
    END IF ;

    ---

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_srtlinfo_for_audit_start'
      , 'Collecting information that has to be written to the '
        || 'CS_INCIDENTS_PURGE_AUDIT_TL table'
      );
    END IF ;

    -- Collect all the information from the cs_incidents_all_tl
    -- table that needs to be entered in the purge audit table

    SELECT
      incident_id
    , language
    , source_lang
    , summary
    BULK COLLECT INTO
      l_incident_id_tl_tbl
    , l_language_tbl
    , l_source_lang_tbl
    , l_summary_tbl
    FROM
      cs_incidents_all_tl c
    , jtf_object_purge_param_tmp j
    WHERE
        j.object_type = 'SR'
    AND j.object_id = c.incident_id
    AND NVL
        (
          j.purge_status
        , 'S'
        ) = 'S'
    AND j.processing_set_id = p_processing_set_id;

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_srtlinfo_for_audit_end'
      , 'After collecting information that has to be written to the '
        || 'CS_INCIDENTS_PURGE_AUDIT_TL table ' || l_row_count || ' rows'
      );
    END IF ;
  ELSIF p_audit_required <> 'Y'
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'purge_audit_not_reqd'
      , 'Not collecting audit information since p_audit_required is '
        || p_audit_required || '. Would be done if Y.'
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_data_for_staging_start'
      , 'Collecting information that has to be written to the '
        || 'CS_INCIDENTS_PURGE_STAGING table'
      );
    END IF ;

    -- Collect all the information from the global temp table
    -- table that needs to be entered in the staging table
    -- so that log can be generated at the end of the purge
    -- process from the purge concurrent program

    SELECT
      object_id
    , purge_error_message
    BULK COLLECT INTO
      l_incident_id_status_tbl
    , l_purge_error_message_tbl
    FROM
      jtf_object_purge_param_tmp j
    WHERE
        j.object_type = 'SR'
    AND NVL
        (
          j.purge_status
        , 'S'
        ) = 'E'
    AND j.processing_set_id = p_processing_set_id;

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'get_data_for_staging_end'
      , 'After collecting information that has to be written to the '
        || 'CS_INCIDENTS_PURGE_STAGING table ' || l_row_count || ' rows'
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'del_srtl_start'
      , 'Deleting rows from table CS_INCIDENTS_ALL_TL'
      );
    END IF ;

    -- Delete all the translatable attributes of the
    -- service request from the table

    DELETE /*+ index(t) */ cs_incidents_all_tl t
    WHERE
      incident_id IN
      (
        SELECT /*+ no_unnest no_semijoin cardinality(10) */
            object_id
        FROM
            jtf_object_purge_param_tmp
        WHERE
            object_type         = 'SR'
        AND p_processing_set_id = processing_set_id
        AND NVL
            (
                purge_status
            ,   'S'
            ) = 'S'
      );

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'del_srtl_end'
      , 'After deleting rows from table CS_INCIDENTS_ALL_TL ' || l_row_count
        || ' rows'
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'del_srb_start'
      , 'Deleting rows from table CS_INCIDENTS_ALL_B'
      );
    END IF ;

    -- Delete all the attributes of the
    -- service request from the table

    DELETE /*+ index(b) */ cs_incidents_all_b b
    WHERE
      incident_id IN
      (
        SELECT /*+ no_unnest no_semijoin cardinality(10) */
          object_id
        FROM
          jtf_object_purge_param_tmp
        WHERE
            object_type         = 'SR'
        AND p_processing_set_id = processing_set_id
        AND NVL
            (
              purge_status
            , 'S'
            ) = 'S'
      );

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'del_srb_end'
      , 'After deleting rows from table CS_INCIDENTS_ALL_B ' || l_row_count
        || ' rows'
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF l_incident_id_status_tbl.COUNT > 0

      -- If there are any SRs with purge_status E indicating
      -- error while validation, the status of these SRs is
      -- updated back to the Staging Table to facilitate
      -- generation of concurrent request output file.

    THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'write_staging_start'
        , 'Updating purge status into table CS_INCIDENTS_PURGE_STAGING'
        );
      END IF ;

      -- Updating the staging table to indicate the SRs that failed during purge
      -- due to validations against child objects.

      FORALL j IN l_incident_id_status_tbl.FIRST..l_incident_id_status_tbl.LAST
        UPDATE cs_incidents_purge_staging
        SET
          purge_status = 'E'
        , purge_error_message = l_purge_error_message_tbl(j)
        WHERE
          incident_id = l_incident_id_status_tbl(j);

      l_row_count := SQL%ROWCOUNT;

      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'write_staging_end'
        , 'After updating purge status into table CS_INCIDENTS_PURGE_STAGING '
          || l_row_count || ' rows'
        );
      END IF ;
    ELSIF l_incident_id_status_tbl.COUNT <= 0
    THEN
      IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_statement
        , L_LOG_MODULE || 'write_staging_norows'
        , 'While updating purge status into table CS_INCIDENTS_PURGE_STAGING '
          || 'l_incident_id_status_tbl had ' || l_incident_id_status_tbl.COUNT
          || ' rows'
        );
      END IF ;
    END IF;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'write_staging_success_start'
      , 'Updating rows processed successfully with purge status = S'
      );
    END IF ;

    -- Setting all the rows in the staging table
    -- belonging to this batch which were processed
    -- successfully to purge_status 'S' to be able
    -- to differentiate these rows from the ones
    -- that were not yet processed.

    UPDATE cs_incidents_purge_staging
    SET
        purge_status = 'S'
    WHERE
        incident_id IN
        (
        SELECT
            object_id
        FROM
            jtf_object_purge_param_tmp j
        WHERE
            j.object_type = 'SR'
        AND NVL
            (
                j.purge_status
            ,   'S'
            ) = 'S'
        AND j.processing_set_id = p_processing_set_id
        );
    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'write_staging_success_end'
      , 'After updating rows processed successfully with '
        || 'purge status = S ' || l_row_count
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  AND p_audit_required = 'Y'

    -- If audit information is required as per profile option
    -- CS_SR_PURGE_AUDIT_REQUIRED, then proceed further

  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'purge_audit_create_start'
      , 'Calling the procedure CREATE_PURGEAUDIT_RECORDS to create purge '
        || 'audit information'
      );
    END IF ;

    -- This procedure takes as input all the data that needs to be captured
    -- in the purge audit tables and staging table. Data of all SRs that were
    -- successfully purged are entered in the audit tables. For the SRs for
    -- which purge failed, the staging table is updated with the purge error
    -- message and purge status.

    Create_Purgeaudit_Records
    (
      p_api_version_number       => '1.0'
    , p_init_msg_list            => FND_API.G_FALSE
    , p_commit                   => FND_API.G_FALSE
    , p_purge_set_id             => l_purge_set_id
    , p_incident_id_tbl          => l_incident_id_tbl
    , p_incident_number_tbl      => l_incident_number_tbl
    , p_incident_type_id_tbl     => l_incident_type_id_tbl
    , p_customer_id_tbl          => l_customer_id_tbl
    , p_inv_organization_id_tbl  => l_inv_organization_id_tbl
    , p_inventory_item_id_tbl    => l_inventory_item_id_tbl
    , p_customer_product_id_tbl  => l_customer_product_id_tbl
    , p_inc_creation_date_tbl    => l_inc_creation_date_tbl
    , p_inc_last_update_date_tbl => l_inc_last_update_date_tbl
    , p_incident_id_tl_tbl       => l_incident_id_tl_tbl
    , p_language_tbl             => l_language_tbl
    , p_source_lang_tbl          => l_source_lang_tbl
    , p_summary_tbl              => l_summary_tbl
    , x_return_status            => x_return_status
    , x_msg_count                => x_msg_count
    , x_msg_data                 => x_msg_data
    );

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'purge_audit_create_end'
      , 'After calling the procedure CREATE_PURGEAUDIT_RECORDS. '
        || 'Returned with status ' || x_return_status
      );
    END IF ;
  END IF;

  ---

  Check_User_Termination;

  ---

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );

      x_msg_count := FND_MSG_PUB.Count_Msg;

      IF x_msg_count > 0
      THEN
          FOR
            i IN 1..x_msg_count
          LOOP
            FND_MSG_PUB.Get
            (
              p_msg_index     => i
            , p_encoded       => 'F'
            , p_data          => x_msg_data
            , p_msg_index_out => x_msg_index_out
            );
            fnd_log.string
            (
              fnd_log.level_unexpected
            , L_LOG_MODULE || 'unexpected_error'
            , 'Error encountered is : ' || x_msg_data || ' [Index:'
              || x_msg_index_out || ']'
            );
          END LOOP;
      END IF ;
    END IF ;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;

END Delete_ServiceRequest;

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_CONTACTS
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure delets all the contacts, related to an SR present in the
--      global temp table with purge status NULL along with contact audit
--      information, party role extended attributes and party role extended
--      attribute audit information
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure delets all the contacts, related to an SR present in the
 * global temp table with purge status NULL along with contact audit
 * information, party role extended attributes and party role extended
 * attribute audit information
 * @param p_object_type Type of object for which this procedure is being called.
 * (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child objects have to be deleted.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Delete Contacts
 */
PROCEDURE Delete_Contacts
(
  p_api_version_number IN         NUMBER := 1.0
, p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE
, p_commit             IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN         VARCHAR2
, p_processing_set_id  IN         NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'DELETE_CONTACTS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count              NUMBER := 0;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF
    FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_ext_aud_start'
    , 'Deleting data from table CS_SR_CONTACTS_EXT_AUDIT'
    );
  END IF ;

  -- The following statement deletes the audit information captured for
  -- the translatable Party role extended attributes related to SRs in the
  -- global temp table with purge status NULL.

  DELETE /*+ index(a) */ cs_sr_contacts_ext_audit a
  WHERE
    incident_id IN
    (
      SELECT /*+ unnest no_semijoin cardinality(10) */
          object_id
      FROM
          jtf_object_purge_param_tmp
      WHERE
          object_type = 'SR'
      AND p_processing_set_id = processing_set_id
      AND NVL
          (
            purge_status
          , 'S'
          ) = 'S'
    );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_ext_aud_end'
    , 'After deleting data from table CS_SR_CONTACTS_EXT_AUDIT '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_ext_start'
    , 'Deleting data from table CS_SR_CONTACTS_EXT_TL'
    );
  END IF ;

  -- This statement deletes all the translatable extended attributes attached
  -- to contacts that are linked to an SR that is available in the global
  -- temp table with purge status NULL.

  DELETE /*+ index(e) */ cs_sr_contacts_ext_tl e
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_ext_end'
    , 'After deleting data from table CS_SR_CONTACTS_EXT_TL '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_ext_start'
    , 'Deleting data from table CS_SR_CONTACTS_EXT'
    );
  END IF ;

  -- This statement deletes all the translatable extended attributes attached
  -- to contacts that are linked to an SR that is available in the global
  -- temp table with purge status NULL.

  DELETE /*+ index(e) */ cs_sr_contacts_ext e
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_ext_end'
    , 'After deleting data from table CS_SR_CONTACTS_EXT '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_point_aud_start'
    , 'Deleting data from table CS_HZ_SR_CONTACT_PNTS_AUDIT'
    );
  END IF ;

  -- This statement deletes all the audit info attached to contacts
  -- that are linked to an SR that is available in the global temp table
  -- with purge status NULL.

  DELETE /*+ index(a) */ cs_hz_sr_contact_pnts_audit a
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_point_aud_end'
    , 'After deleting data from table CS_HZ_SR_CONTACT_PNTS_AUDIT '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_point_start'
    , 'Deleting data from table CS_HZ_SR_CONTACT_POINTS'
    );
  END IF ;

  -- This statement deletes all the contacts that are linked to an
  -- SR that is available in the global temp table with purge status NULL.

  DELETE /*+ index(c) */ cs_hz_sr_contact_points c
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );
  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_cont_point_end'
    , 'After deleting data from table CS_HZ_SR_CONTACT_POINTS '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_CONT_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;

END Delete_Contacts;

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_AUDIT_RECORDS
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure deletes all the audit information related to SRs that are
--      present in the global temp table with purge status NULL.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure deletes all the audit information related to SRs that are
 * present in the global temp table with purge status NULL.
 * @param p_object_type Type of object for which this procedure is being called.
 * (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child objects have to be deleted.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Delete Audit Requests
 */
PROCEDURE Delete_Audit_Records
(
  p_api_version_number IN         NUMBER := 1.0
, p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE
, p_commit             IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN         VARCHAR2
, p_processing_set_id  IN         NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'DELETE_AUDIT_RECORDS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count      NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF
    FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_sraudit_tl_start'
    , 'Deleting data from table CS_INCIDENTS_AUDIT_TL'
    );
  END IF ;

  -- Deleting rows from the audit TL table for the
  -- SRs in the global temp table with purge status NULL

  DELETE /*+ index(t) */ cs_incidents_audit_tl t
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_sraudit_tl_end'
    , 'After deleting data from table CS_INCIDENTS_AUDIT_TL '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_sraudit_b_start'
    , 'Deleting data from table CS_INCIDENTS_AUDIT_B'
    );
  END IF ;

  -- Deleting rows from the audit table for the
  -- SRs in the global temp table with purge status NULL

  DELETE /*+ index(b) */ cs_incidents_audit_b b
  WHERE incident_id IN
  (
    SELECT /*+ unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'del_sraudit_b_end'
    , 'After deleting data from table CS_INCIDENTS_AUDIT_B '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_AUDIT_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Delete_Audit_Records;

--------------------------------------------------------------------------------
--  Procedure Name            :   DELETE_SR_ATTRIBUTES
--
--  Parameters (other than standard ones)
--  IN
--      p_object_type         :   Type of object for which this procedure is
--                                being called. (Here it will be 'SR')
--      p_processing_set_id   :   Id that helps the API in identifying the
--                                set of SRs for which the child objects have
--                                to be deleted.
--
--  Description
--      This procedure deletes all the extended attributes and CIC attributes
--      associated with the SRs present in the global temp table with purge
--      status NULL along with the audit information captured for the extended
--      attributes.
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure deletes all the extended attributes and CIC attributes
 * associated with the SRs present in the global temp table with purge status
 * NULL along with the audit information captured for the extended attributes.
 * @param p_object_type Type of object for which this procedure is being called.
 * (Here it will be 'SR')
 * @param p_processing_set_id Id that helps the API in identifying the set of
 * SRs for which the child objects have to be deleted.
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Delete Service Request Attributes
 */
PROCEDURE Delete_Sr_Attributes
(
  p_api_version_number IN         NUMBER
, p_init_msg_list      IN         VARCHAR2 := FND_API.G_FALSE
, p_commit             IN         VARCHAR2 := FND_API.G_FALSE
, p_object_type        IN         VARCHAR2
, p_processing_set_id  IN         NUMBER
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'DELETE_SR_ATTRIBUTES';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_row_count      NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_object_type:' || p_object_type
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 5'
    , 'p_processing_set_id:' || p_processing_set_id
    );
  END IF ;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF
    FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'cug_attr_tl_del_start'
    , 'Deleting data from table CUG_INCIDNT_ATTR_VALS_TL'
    );
  END IF ;

  -- The following statement deletes all the translatable CIC attributes that
  -- are linked to the SRs in the global temp table with purge_status NULL

  DELETE /*+ index(t) */ cug_incidnt_attr_vals_tl t
  WHERE incidnt_attr_val_id IN
  (
    SELECT /*+ no_unnest no_semijoin leading(j) use_concat cardinality(10) */
        c.incidnt_attr_val_id
    FROM
        jtf_object_purge_param_tmp j
    , cug_incidnt_attr_vals_b c
    WHERE
        j.object_type = 'SR'
    AND p_processing_set_id = j.processing_set_id
    AND NVL(j.purge_status, 'S') = 'S'
    AND c.incident_id = j.object_id
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'cug_attr_tl_del_end'
    , 'After deleting data from table CUG_INCIDNT_ATTR_VALS_TL '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'cug_attr_b_del_start'
    , 'Deleting data from table CUG_INCIDNT_ATTR_VALS_B'
    );
  END IF ;

  -- The following statement deletes all the CIC attributes that are
  -- linked to the SRs in the global temp table with purge_status NULL

  DELETE /*+ index(b) */ cug_incidnt_attr_vals_b b
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'cug_attr_b_del_end'
    , 'After deleting data from table CUG_INCIDNT_ATTR_VALS_B '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'sr_ext_attr_aud_del_start'
    , 'Deleting data from table CS_INCIDENTS_EXT_AUDIT'
    );
  END IF ;

  -- The following statement deletes all the audit information captured for
  -- the translatable extended attributes linked to SRs in the global temp
  -- table with purge_status NULL

  DELETE /*+ index(a) */ cs_incidents_ext_audit a
  WHERE audit_extension_id IN
  (
    SELECT /*+ unnest no_semijoin leading(j) use_nl(c) cardinality(10) */
        audit_extension_id
    FROM
        jtf_object_purge_param_tmp j
    , cs_incidents_ext_audit c
    WHERE
        j.object_type = 'SR'
    AND p_processing_set_id = j.processing_set_id
    AND NVL(j.purge_status, 'S') = 'S'
    AND c.incident_id = j.object_id
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'sr_ext_attr_aud_del_end'
    , 'After deleting data from table CS_INCIDENTS_EXT_AUDIT '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'sr_ext_attr_del_start'
    , 'Deleting data from table CS_INCIDENTS_EXT_TL'
    );
  END IF ;

  -- The following statement deletes all the translatable extended attributes
  -- that are linked to the SRs present in the global temp table with purge
  -- status NULL

  DELETE /*+ index(e) */ cs_incidents_ext_tl e
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'sr_ext_attr_del_end'
    , 'After deleting data from table CS_INCIDENTS_EXT_TL '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'sr_ext_attr_del_start'
    , 'Deleting data from table CS_INCIDENTS_EXT'
    );
  END IF ;

  -- The following statement deletes all the translatable extended attributes
  -- that are linked to the SRs present in the global temp table with purge
  -- status NULL

  DELETE /*+ index(e) */ cs_incidents_ext e
  WHERE incident_id IN
  (
    SELECT /*+ no_unnest no_semijoin cardinality(10) */
        object_id
    FROM
        jtf_object_purge_param_tmp
    WHERE
        object_type = 'SR'
    AND p_processing_set_id = processing_set_id
    AND NVL(purge_status, 'S') = 'S'
  );

  l_row_count := SQL%ROWCOUNT;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_statement
    , L_LOG_MODULE || 'sr_ext_attr_del_end'
    , 'After deleting data from table CS_INCIDENTS_EXT '
      || l_row_count || ' rows'
    );
  END IF ;

  ---

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_ATTR_VAL_DEL_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Delete_Sr_Attributes;

--------------------------------------------------------------------------------
--  Procedure Name            :   CREATE_PURGEAUDIT_RECORDS
--
--  Parameters (other than standard ones)
--  IN
--      p_purge_set_id              :   Id that helps the API in identifying the
--                                      set of SRs for which the child objects
--                                      have to be deleted.
--      p_incident_id_tbl           :   pl/sql table containing all the SR ids
--                                      that have been purged successfully
--      p_incident_number_tbl       :   pl/sql table containing all the SR
--                                      numbers that have been purged
--                                      successfully
--      p_incident_type_id_tbl      :   pl/sql table containing type ids of all
--                                      the SRs that have been purged
--                                      successfully
--      p_customer_id_tbl           :   pl/sql table containing customer ids of
--                                      all the SRs that have been purged
--                                      successfully
--      p_inv_organization_id_tbl   :   pl/sql table containing org ids of all
--                                      the SRs that have been purged
--                                      successfully
--      p_inventory_item_id_tbl     :   pl/sql table containing item ids of all
--                                      the SRs that have been purged
--                                      successfully
--      p_customer_product_id_tbl   :   pl/sql table containing instance ids of
--                                      all the SRs that have been purged
--                                      successfully
--      p_inc_creation_date_tbl     :   pl/sql table containing creation dates
--                                      of all the SRs that have been purged
--                                      successfully
--      p_inc_last_update_date_tbl  :   pl/sql table containing last update
--                                      dates ids of all the SRs that have been
--                                      purged successfully
--      p_incident_id_tl_tbl        :   pl/sql table containing SRs ids (as
--                                      in TL table) of all the SRs that have
--                                      been purged successfully
--      p_language_tbl              :   pl/sql table containing language of all
--                                      the SRs that have been purged
--                                      successfully
--      p_source_lang_tbl           :   pl/sql table containing source lang of
--                                      all the SRs that have been purged
--                                      successfully
--      p_summary_tbl               :   pl/sql table containing summary of all
--                                      the SRs that have been purged
--                                      successfully
--
--  Description
--      This procedure creates rows in the purge audit table to preserve the
--      basic information related to the SRs that were purged using the SR
--      purge concurrent program. It is called from the DeleteServiceRequest
--      procedure with pl/sql tables containing all the data that need to
--      be preserved.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure creates rows in the purge audit table to preserve the basic
 * information related to the SRs that were purged using the SR purge concurrent
 * program. It is called from the DeleteServiceRequest procedure with pl/sql
 * tables containing all the data that need to be preserved.
 * @param p_purge_set_id Id that helps the API in identifying the set of SRs
 * for which the child objects have to be deleted.
 * @param p_incident_id_tbl pl/sql table containing all the SR ids that have
 * been purged successfully
 * @param p_incident_number_tbl pl/sql table containing all the SR numbers that
 * have been purged successfully
 * @param p_incident_type_id_tbl pl/sql table containing type ids of all the
 * SRs that have been purged successfully
 * @param p_customer_id_tbl pl/sql table containing customer ids of all the
 * SRs that have been purged successfully
 * @param p_inv_organization_id_tbl pl/sql table containing org ids of all the
 * SRs that have been purged successfully
 * @param p_inventory_item_id_tbl pl/sql table containing item ids of all the
 * SRs that have been purged successfully
 * @param p_customer_product_id_tbl pl/sql table containing instance ids of
 * all the SRs that have been purged successfully
 * @param p_inc_creation_date_tbl pl/sql table containing creation dates of
 * all the SRs that have been purged successfully
 * @param p_inc_last_update_date_tbl pl/sql table containing last update
 * dates ids of all the SRs that have been purged successfully
 * @param p_incident_id_tl_tbl pl/sql table containing SRs ids (as in TL
 * table) of all the SRs that have been purged successfully
 * @param p_language_tbl pl/sql table containing language of all the SRs
 * that have been purged successfully
 * @param p_source_lang_tbl pl/sql table containing source lang of all the SRs
 * that have been purged successfully
 * @param p_summary_tbl pl/sql table containing summary of all the SRs
 * that have been purged successfully
 * @rep:scope internal
 * @rep:product CS
 * @rep:displayname Create Purge Audit Records
 */
PROCEDURE Create_Purgeaudit_Records
(
  p_api_version_number       IN          NUMBER := 1.0
, p_init_msg_list            IN          VARCHAR2 := FND_API.G_FALSE
, p_commit                   IN          VARCHAR2 := FND_API.G_FALSE
, p_purge_set_id             IN          NUMBER
, p_incident_id_tbl          IN          t_number_tbl
, p_incident_number_tbl      IN          t_long_string_tbl
, p_incident_type_id_tbl     IN          t_number_tbl
, p_customer_id_tbl          IN          t_number_tbl
, p_inv_organization_id_tbl  IN          t_number_tbl
, p_inventory_item_id_tbl    IN          t_number_tbl
, p_customer_product_id_tbl  IN          t_number_tbl
, p_inc_creation_date_tbl    IN          t_date_tbl
, p_inc_last_update_date_tbl IN          t_date_tbl
, p_incident_id_tl_tbl       IN          t_number_tbl
, p_language_tbl             IN          t_string_tbl
, p_source_lang_tbl          IN          t_string_tbl
, p_summary_tbl              IN          t_long_string_tbl
, x_return_status            OUT  NOCOPY VARCHAR2
, x_msg_count                OUT  NOCOPY NUMBER
, x_msg_data                 OUT  NOCOPY VARCHAR2
)
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER       := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30) := 'CREATE_PURGEAUDIT_RECORDS';
L_API_NAME_FULL CONSTANT VARCHAR2(61) := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_user_id       NUMBER;
l_login_id      NUMBER;

l_row_count     NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 1'
    , 'p_api_version_number:' || p_api_version_number
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 2'
    , 'p_init_msg_list:' || p_init_msg_list
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 3'
    , 'p_commit:' || p_commit
    );
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'param 4'
    , 'p_purge_set_id' || p_purge_set_id
    );
  END IF ;

  l_user_id  := fnd_global.user_id;
  l_login_id := fnd_global.login_id;

  IF NOT FND_API.Compatible_API_Call
  (
    L_API_VERSION
  , p_api_version_number
  , L_API_NAME
  , G_PKG_NAME
  )
  THEN
    FND_MSG_PUB.Count_And_Get
    (
      p_count => x_msg_count
    , p_data  => x_msg_data
    );
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF ;

  IF FND_API.to_Boolean(p_init_msg_list)
  THEN
    FND_MSG_PUB.initialize;
  END IF ;

  ------------------------------------------------------------------------------
  -- Actual Logic starts below:
  ------------------------------------------------------------------------------

  IF p_incident_id_tbl.COUNT > 0
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'ins_purge_aud_b_start'
      , 'Inserting data into table CS_INCIDENTS_PURGE_AUDIT_B'
      );
    END IF ;

    -- Inserting information relating to purged SRs into the audit base table

    FORALL j IN p_incident_id_tbl.FIRST..p_incident_id_tbl.LAST
      INSERT INTO cs_incidents_purge_audit_b
      (
        purge_id
      , incident_id
      , incident_number
      , incident_type_id
      , customer_id
      , inv_organization_id
      , inventory_item_id
      , customer_product_id
      , inc_creation_date
      , inc_last_update_date
      , purged_date
      , purged_by
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      )
      VALUES
      (
        p_purge_set_id
      , p_incident_id_tbl(j)
      , p_incident_number_tbl(j)
      , p_incident_type_id_tbl(j)
      , p_customer_id_tbl(j)
      , p_inv_organization_id_tbl(j)
      , p_inventory_item_id_tbl(j)
      , p_customer_product_id_tbl(j)
      , p_inc_creation_date_tbl(j)
      , p_inc_last_update_date_tbl(j)
      , SYSDATE
      , l_user_id
      , SYSDATE
      , l_user_id
      , SYSDATE
      , l_user_id
      , l_login_id
      );

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
        fnd_log.string
            (
              fnd_log.level_statement
            , L_LOG_MODULE || 'ins_purge_aud_b_end'
            , 'After inserting data into table CS_INCIDENTS_PURGE_AUDIT_B '
              || l_row_count || ' rows'
            );
    END IF ;
  ELSIF p_incident_id_tbl.COUNT <= 0
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
        fnd_log.string
            (
              fnd_log.level_statement
            , L_LOG_MODULE || 'ins_purge_aud_b_err'
            , 'While inserting data into table CS_INCIDENTS_PURGE_AUDIT_B '
              || 'p_incident_id_tbl had ' || p_incident_id_tbl.COUNT || ' rows'
            );
    END IF ;
  END IF;

  IF p_incident_id_tl_tbl.COUNT > 0
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'ins_purge_aud_tl_start'
      , 'Inserting data into table CS_INCIDENTS_PURGE_AUDIT_TL'
      );
    END IF ;

    -- Inserting translatable information relating to
    -- purged SRs into the audit base table

    FORALL j IN p_incident_id_tl_tbl.FIRST..p_incident_id_tl_tbl.LAST
      INSERT INTO cs_incidents_purge_audit_tl
      (
        purge_id
      , incident_id
      , language
      , source_lang
      , summary
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      )
      VALUES
      (
        p_purge_set_id
      , p_incident_id_tl_tbl(j)
      , p_language_tbl(j)
      , p_source_lang_tbl(j)
      , p_summary_tbl(j)
      , SYSDATE
      , l_user_id
      , SYSDATE
      , l_user_id
      , l_login_id
      );

    l_row_count := SQL%ROWCOUNT;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'ins_purge_aud_tl_end'
      , 'After inserting data into table CS_INCIDENTS_PURGE_AUDIT_TL '
        || l_row_count || ' rows'
      );
    END IF ;
  ELSIF p_incident_id_tl_tbl.COUNT <= 0
  THEN
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_statement
      , L_LOG_MODULE || 'ins_purge_aud_tl_err'
      , 'While inserting data into table CS_INCIDENTS_PURGE_AUDIT_TL '
        || 'p_incident_id_tl_tbl had ' || p_incident_id_tl_tbl.COUNT || ' rows'
      );
    END IF ;
  END IF;

  IF fnd_log.level_procedure >= fnd_log.g_current_runtime_level
  THEN
    fnd_log.string
    (
      fnd_log.level_procedure
    , L_LOG_MODULE || 'end'
    , 'Completed work in ' || L_API_NAME_FULL || ' with return status '
      || x_return_status
    );
  END IF ;

EXCEPTION

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'unexpected_error'
      , 'Inside WHEN FND_API.G_EXC_UNEXPECTED_ERROR of ' || L_API_NAME_FULL
      );
    END IF ;

	WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_SR_PRG_CRT_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

    IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
    THEN
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , 'Inside WHEN OTHERS of ' || L_API_NAME_FULL || '. Oracle Error was:'
      );
      fnd_log.string
      (
        fnd_log.level_unexpected
      , L_LOG_MODULE || 'when_others'
      , SQLERRM
      );
    END IF ;
END Create_Purgeaudit_Records;
--------------------------------------------------------------------------------
--  Procedure Name            :   CHECK_USER_TERMINATION
--
--  Parameters (other than standard ones)
--      NONE.
--
--  Description
--      This procedure is called before performing any step during the purge
--      process so that if the user requests a termination of the purge process
--      for some reason, the process should end gracefully.
--
--  HISTORY
--
----------------+------------+--------------------------------------------------
--  DATE        | UPDATED BY | Change Description
----------------+------------+--------------------------------------------------
--  2-Aug_2005  | varnaray   | Created
--              |            |
----------------+------------+--------------------------------------------------
/*#
 * This procedure is called before performing any step during the purge process
 * so that if the user requests a termination of the purge process for some
 * reason, the process should end gracefully.
 */
PROCEDURE Check_User_Termination
IS
--------------------------------------------------------------------------------
L_API_VERSION   CONSTANT NUMBER        := 1.0;
L_API_NAME      CONSTANT VARCHAR2(30)  := 'CHECK_USER_TERMINATION';
L_API_NAME_FULL CONSTANT VARCHAR2(61)  := G_PKG_NAME || '.' || L_API_NAME;
L_LOG_MODULE    CONSTANT VARCHAR2(255) := 'cs.plsql.' || L_API_NAME_FULL || '.';

l_request_id    NUMBER;
l_phase         VARCHAR2(100);
l_status        VARCHAR2(100);
l_dev_phase     VARCHAR2(100);
l_dev_status    VARCHAR2(100);
l_message       VARCHAR2(500);

BEGIN
  l_request_id := fnd_global.conc_request_id;

  IF l_request_id <> -1

    -- The check for user termination is only
    -- required if the SR Delete Helper is called
    -- from a concurrent program. If l_request_id
    -- is -1, it means that the procedure is not
    -- called from a concurrent program. Hence the
    -- check for user termination may not be required.

  THEN
    IF fnd_concurrent.get_request_status
    (
      request_id => l_request_id
    , phase      => l_phase
    , status     => l_status
    , dev_phase  => l_dev_phase
    , dev_status => l_dev_status
    , message    => l_message
    )
    THEN
      IF  l_dev_status = 'TERMINATING'
      AND l_dev_phase  = 'RUNNING'
      OR  l_dev_status = 'TERMINATED'
      AND l_dev_phase  = 'COMPLETE'

      -- If the user terminates the concurrent request
      -- raise an exception and add a message to the stack

      THEN
        IF fnd_log.level_statement >= fnd_log.g_current_runtime_level
        THEN
          fnd_log.string
          (
            fnd_log.level_statement
          , L_LOG_MODULE || 'conc_req_user_stop'
          , 'This concurrent request is in status ' || l_dev_status
              || ' and phase ' || l_dev_phase
          );
        END IF ;

        FND_MESSAGE.Set_Name('CS', 'CS_SR_USER_STOPPED');
        FND_MSG_PUB.ADD;

        -- Setting the request_data to 'T'
        -- indicating that the request has
        -- been terminated by the user

        fnd_conc_global.set_req_globals
        (
          request_data => 'T'
        );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    ELSE
      -- if fnd_concurrent.get_request_status failed...

      IF fnd_log.level_unexpected >= fnd_log.g_current_runtime_level
      THEN
        fnd_log.string
        (
          fnd_log.level_unexpected
        , L_LOG_MODULE || 'conc_req_status_fail'
        , 'Failed while getting the status of this request'
        );
      END IF ;
    END IF;
  END IF;
END Check_User_Termination;
--------------------------------------------------------------------------------
END cs_sr_delete_util;

/
