--------------------------------------------------------
--  DDL for Package Body CS_SR_EXTATTRIBUTES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_SR_EXTATTRIBUTES_PVT" AS
/* $Header: csvextb.pls 120.39.12010000.6 2010/06/16 06:07:24 sanjrao ship $ */

-- =============================================================================
--                         Package variables and cursors
-- =============================================================================

   G_FILE_NAME                    CONSTANT  VARCHAR2(12)  := 'CSVEXTB.pls';
   G_PKG_NAME                     CONSTANT  VARCHAR2(30)  := 'CS_SR_EXTATTRIBUTES_PVT';
   G_APP_NAME                     CONSTANT  VARCHAR2(3)   := 'CS';
   G_PKG_NAME_TOKEN               CONSTANT  VARCHAR2(8)   := 'PKG_NAME';
   G_API_NAME_TOKEN               CONSTANT  VARCHAR2(8)   := 'API_NAME';
   G_PROC_NAME_TOKEN              CONSTANT  VARCHAR2(9)   := 'PROC_NAME';
   G_SQL_ERR_MSG_TOKEN            CONSTANT  VARCHAR2(11)  := 'SQL_ERR_MSG';


   G_USER_ID                      NUMBER  :=  FND_GLOBAL.User_Id;
   G_LOGIN_ID                     NUMBER  :=  FND_GLOBAL.Conc_Login_Id;


   G_TRUE                         CONSTANT  VARCHAR2(1) := 'T'; -- FND_API.G_TRUE;
   G_FALSE                        CONSTANT  VARCHAR2(1) := 'F'; -- FND_API.G_FALSE;

--===========================================================
-- Declaration of Private Procedures and functions
--===========================================================
PROCEDURE delete_old_context
( p_pk_column_1         IN         NUMBER
, p_context             IN         NUMBER
, x_failed_row_id_list  OUT NOCOPY VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_errorcode           OUT NOCOPY NUMBER
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Attr_Group_Metadata (
        p_attr_group_id                 IN          NUMBER
       ,x_application_id                OUT NOCOPY  NUMBER
       ,x_attr_group_type               OUT NOCOPY  VARCHAR2
       ,x_attr_group_name               OUT NOCOPY  VARCHAR2
);


PROCEDURE Get_Attr_Metadata (
        p_row_identifier                IN          NUMBER
       ,p_application_id                IN          NUMBER
       ,p_attr_group_type               IN          VARCHAR2
       ,p_attr_group_name               IN          VARCHAR2
       ,p_ext_attr_tbl                  IN  OUT NOCOPY     CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
);

FUNCTION IS_ROW_VALID(
                 p_incident_id          IN           NUMBER
                ,p_context              IN           NUMBER
                ,p_attr_group_id        IN           NUMBER
                ,x_msg_data             OUT NOCOPY VARCHAR2
                ,x_msg_count            OUT NOCOPY NUMBER
                ,x_return_status        OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

FUNCTION IS_ATTR_GROUP_MULTI_ROW(
                                 p_attr_group_id IN NUMBER
                                ,x_msg_data             OUT NOCOPY VARCHAR2
                                ,x_msg_count            OUT NOCOPY NUMBER
                                ,x_return_status        OUT NOCOPY VARCHAR2)
RETURN VARCHAR2;

PROCEDURE GET_MULTI_ROW_UNIQUE_KEY(p_attr_group_name IN VARCHAR2
                                  ,p_attr_group_type IN VARCHAR2
                                  ,p_application_id IN NUMBER
                                  ,x_attr_name OUT NOCOPY VARCHAR2
                                  ,x_database_column OUT NOCOPY VARCHAR2);


PROCEDURE populate_sr_ext_attr_audit_rec(
          p_incident_id        IN NUMBER
         ,p_context            IN NUMBER
         ,p_attr_group_id      IN  NUMBER
         ,p_row_id             IN NUMBER
         ,p_ext_attr_tbl       IN CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
         ,p_sr_audit_rec_table IN OUT NOCOPY Ext_Attr_Audit_Tbl_Type
         ,x_rec_found          OUT NOCOPY VARCHAR2
         );

PROCEDURE populate_pr_ext_attr_audit_rec(
          p_incident_id        IN NUMBER
         ,p_party_id           IN NUMBER
         ,p_contact_type       IN VARCHAR2
         ,p_party_role_code    IN VARCHAR2
         ,p_context            IN VARCHAR2
         ,p_attr_group_id      IN NUMBER
         ,p_row_id             IN NUMBER
         ,p_ext_attr_tbl       IN CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
         ,p_sr_audit_rec_table IN OUT NOCOPY Ext_Attr_Audit_Tbl_Type
         ,x_rec_found      OUT NOCOPY VARCHAR2
         );


PROCEDURE check_sr_context_change(
          p_incident_id     IN NUMBER
         ,p_context         IN NUMBER
         ,x_context_changed OUT NOCOPY VARCHAR2
         ,x_db_incident_id  OUT NOCOPY NUMBER
         ,x_db_context      OUT NOCOPY NUMBER

);

PROCEDURE INIT_AUDIT_REC(p_count NUMBER,
                         p_audit_rec IN OUT NOCOPY Ext_Attr_Audit_Tbl_Type);

PROCEDURE Log_EXT_PVT_Parameters (
          p_ext_attr_grp_tbl   IN CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
         ,p_ext_attr_tbl       IN CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE );

-- -----------------------------------------------------------------------------
-- Procedure Name : Log_EGO_EXT_Parameters
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    : Procedure to LOG the in parameters of PVT SR Ext Attrs procedures
--
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 11/08/05 mviswana   Created
-- -----------------------------------------------------------------------------
PROCEDURE Log_EGO_Ext_PVT_Parameters(
                p_ext_attr_grp_tbl        IN     EGO_USER_ATTR_ROW_TABLE
               ,p_ext_attr_tbl            IN     EGO_USER_ATTR_DATA_TABLE) ;


-- =============================================================================
-- Private Functions
-- ============================================================================
FUNCTION IS_ROW_VALID(p_incident_id   IN         NUMBER
                     ,p_context       IN         NUMBER
                     ,p_attr_group_id IN         NUMBER
                     ,x_msg_data      OUT NOCOPY VARCHAR2
                     ,x_msg_count     OUT NOCOPY NUMBER
                     ,x_return_status OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Cursor to check if extension row really exists

Cursor c_check_ext_row IS

  SELECT count(*)
    FROM cs_incidents_ext
   WHERE incident_id = p_incident_id
     AND context = p_context
     AND attr_group_id = p_attr_group_id;

l_exists_flag VARCHAR2(1) := 'N';
l_count       NUMBER      := 0;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

 OPEN c_check_ext_row;
 FETCH c_check_ext_row into l_count;
 CLOSE c_check_ext_row;

 IF l_count > 0 THEN
   l_exists_flag := 'Y';
 ELSE
   l_exists_flag := 'N';
 END IF;

 RETURN l_exists_flag;

EXCEPTION

      WHEN OTHERS THEN


        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN l_exists_flag;

END IS_ROW_VALID;



-- =============================================================================
-- Private Functions
-- ============================================================================
FUNCTION IS_ATTR_GROUP_MULTI_ROW(
                                 p_attr_group_id IN NUMBER
                                ,x_msg_data             OUT NOCOPY VARCHAR2
                                ,x_msg_count            OUT NOCOPY NUMBER
                                ,x_return_status        OUT NOCOPY VARCHAR2)
RETURN VARCHAR2
IS

--Cursor to check if attr group is multi row enabled
Cursor c_is_multi_row IS
select multi_row_code
  from ego_attr_groups_v
 where attr_group_id = p_attr_group_id;

l_multi_row_code VARCHAR2(1) := 'N';


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN c_is_multi_row;
   FETCH c_is_multi_row INTO l_multi_row_code;
   CLOSE c_is_multi_row;


 RETURN l_multi_row_code;

EXCEPTION

      WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RETURN l_multi_row_code;

END IS_ATTR_GROUP_MULTI_ROW;

-- =============================================================================
--                 Private Procedures
-- =============================================================================


-- -----------------------------------------------------------------------------
--  API Name:       Process_SR_Ext_Attrs
--
--  Description:
--    Process passed-in User-Defined Attrs data for
--    the Service Request whose Primary Keys are passed in
-- Modification History
-- Date     Name     Description
---------- -------- ------------------------------------------------------------
-- 09/23/05 smisra  Passed g_false for p_coomit
--                  used x_return_status instead of l_return_status after
--                  EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data call because
--                  this procedure returns the status into x_return_status
--                  variable
--                  Added commit at the end of the procedure.
-- 09/23/05 smisra  called delete_old_context when context is changed before
--                  inserting data for new context.
--                  Put existing code to delete old context under comment. That
--                  code can be review later by owner of the file.
-- 05/19/06 klou    Fix bug 5230846 - when an invalid object name is passsed,
--                  we should return an error.
--                  Fix bug 4230846 - errors in DELETE operation.
-- -----------------------------------------------------------------------------

PROCEDURE Process_SR_Ext_Attrs(
        p_api_version      	        IN   NUMBER
       ,p_init_msg_list    	        IN   VARCHAR2 	:= FND_API.G_FALSE
       ,p_commit           	        IN   VARCHAR2 	:= FND_API.G_FALSE
       ,p_incident_id                   IN   NUMBER
       ,p_ext_attr_grp_tbl              IN   CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
       ,p_ext_attr_tbl                  IN   CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
       ,p_modified_by                   IN   NUMBER := FND_GLOBAL.USER_ID
       ,p_modified_on                   IN   DATE := SYSDATE
       ,x_failed_row_id_list            OUT  NOCOPY VARCHAR2
       ,x_return_status                 OUT  NOCOPY VARCHAR2
       ,x_errorcode                     OUT  NOCOPY NUMBER
       ,x_msg_count                     OUT  NOCOPY NUMBER
       ,x_msg_data                      OUT  NOCOPY VARCHAR2
)IS

l_user_attr_data_table        EGO_USER_ATTR_DATA_TABLE;
l_user_attr_row_table         EGO_USER_ATTR_ROW_TABLE;
l_pk_name_value_pair          EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_user_privileges_on_object   EGO_VARCHAR_TBL_TYPE;
l_failed_row_id_list          VARCHAR2(4000);
l_return_status               VARCHAR2(1);
l_errorcode                   NUMBER;
l_msg_count                   NUMBER;
l_msg_data                    VARCHAR2(4000);
l_ext_attr_tbl                CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE;
l_application_id              NUMBER;
l_attr_group_type             VARCHAR2(30);
l_attr_group_name             VARCHAR2(30);
l_old_context                 VARCHAR2(1000);
l_pk_index                    NUMBER := 1;
l_incident_id                 VARCHAR2(30);

l_count                       NUMBER;
l_valid_check                 VARCHAR2(1);

l_old_Ext_Attr_Audit_table    Ext_Attr_Audit_Tbl_Type;
l_new_Ext_Attr_Audit_table    Ext_Attr_Audit_Tbl_Type;
l_new_audit_count             NUMBER;
l_old_audit_count             NUMBER;
l_rec_found                   VARCHAR2(1);
l_cont_chg_on_update          VARCHAR2(1);
l_db_incident_id              NUMBER;
l_db_sr_context               NUMBER;
l_db_attr_group               NUMBER;

l_pk_col_1                    NUMBER;
l_pk_col_2                    NUMBER;
l_pk_col_3                    VARCHAR2(30);
l_pk_col_4                    VARCHAR2(30);
l_context                     NUMBER;
l_attr_group_id               NUMBER;
l_composite_key               VARCHAR2(2000);

l_api_version   constant number       := 1.0;
l_api_name      constant varchar2(30) := 'Process_SR_Ext_Attrs';
l_api_name_full constant varchar2(61) := g_pkg_name || '.' || l_api_name;
l_log_module    constant varchar2(255) := 'cs.plsql.' || l_api_name_full || '.';


CURSOR c_check_sr_pk_col_1(p_pk_col_1 IN NUMBER)IS
SELECT incident_id
      ,incident_type_id
 FROM  cs_incidents_all_b
WHERE  incident_id = p_pk_col_1;

CURSOR c_check_pr_pk_cols( p_pk_col_1 IN NUMBER
                          ,p_pk_col_2 IN NUMBER
                          ,p_pk_col_3 IN VARCHAR2
                          ,p_pk_col_4 IN VARCHAR2) IS
SELECT incident_id
      ,party_id
      ,contact_type
      ,party_role_code
  FROM cs_hz_sr_contact_points
 WHERE incident_id = p_pk_col_1
   AND party_id = p_pk_col_2
   AND contact_type = p_pk_col_3
   AND party_role_code = p_pk_col_4;


Cursor c_get_attr_grp_id (p_attr_group_app_id IN NUMBER
                         ,p_attr_group_type IN VARCHAR2
                         ,p_attr_group_name IN VARCHAR2)IS

SELECT attr_group_id
  FROM ego_attr_groups_v
 WHERE application_id = p_attr_group_app_id
   AND attr_group_type = p_attr_group_type
   AND attr_group_name = p_attr_group_name;


Cursor c_get_old_context_value(p_incident_id IN NUMBER
                            ,p_context IN NUMBER) IS

select incident_id, context, attr_group_id
  from cs_incidents_ext
where incident_id = p_incident_id
  and context = p_context;


BEGIN

--Standard start of API savepoint
SAVEPOINT CS_EXTENSIBILITY_PVT;

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version,
                                    p_api_version,
                                    l_api_name,
                                    G_PKG_NAME) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
  FND_MSG_PUB.initialize;
END IF;

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

--DBMS_OUTPUT.PUT_LINE('In Process_User_Ext_Attrs');
--DBMS_OUTPUT.PUT_LINE('p_ext_attr_grp_tbl.COUNT'||p_ext_attr_grp_tbl.COUNT);

---------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );


 -- --------------------------------------------------------------------------
 -- This procedure Logs the extensible attributes table.
 -- --------------------------------------------------------------------------
    Log_EXT_PVT_Parameters
    ( p_ext_attr_grp_tbl   => p_ext_attr_grp_tbl
     ,p_ext_attr_tbl       => p_ext_attr_tbl
    );

 END IF;


--Assign the record count in the attribute group table to l_count
l_count := p_ext_attr_grp_tbl.COUNT;


IF p_ext_attr_grp_tbl.COUNT > 0 THEN

    --DBMS_OUTPUT.PUT_LINE('first Row: '||p_ext_attr_grp_tbl.first);
    --DBMS_OUTPUT.PUT_LINE('Last  Row: '||p_ext_attr_grp_tbl.last);

FOR i IN p_ext_attr_grp_tbl.FIRST..p_ext_attr_grp_tbl.LAST LOOP

  IF p_ext_attr_grp_tbl(i).object_name = 'CS_SERVICE_REQUEST' THEN

    --DBMS_OUTPUT.PUT_LINE('object_name is CS_SERVICE_REQUEST');
    --DBMS_OUTPUT.PUT_LINE('l_context'||p_ext_attr_grp_tbl(i).context);
    --DBMS_OUTPUT.PUT_LINE('l_old_context'||l_old_context);
    --DBMS_OUTPUT.PUT_LINE('Loop index: '||i);
    --DBMS_OUTPUT.PUT_LINE('Row: '||p_ext_attr_grp_tbl(i).row_identifier);

    IF p_ext_attr_grp_tbl(i).context <> l_old_context  AND
       l_old_context IS NOT NULL THEN

       -- Added FND_LOG
       IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	  FND_LOG.String
	  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	  , 'Transaction has two contexts.  First Context :'
	  || l_old_context
	  );
       END IF;

      --DBMS_OUTPUT.PUT_LINE('In here');

      IF l_cont_chg_on_update = 'Y'
      THEN

        -- Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
	  FND_LOG.String
	  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	  , 'The context for the Service Request has Changed :'
	  || l_cont_chg_on_update
	  );
	END IF;

        delete_old_context
        ( p_pk_column_1         => l_db_incident_id
        , p_context             => l_db_sr_context
        , x_failed_row_id_list  => x_failed_row_id_list
        , x_return_status       => x_return_status
        , x_errorcode           => x_errorcode
        , x_msg_count           => x_msg_count
        , x_msg_data            => x_msg_data
        );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

        -- Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'Information for old context deleted'
	    );
	END IF;

      END IF; -- l_cont_chg_on_update = 'Y'

        -- Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
	  THEN
	    FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'Calling PLM API to process first context'
	    );
	END IF;
      --context has changed
      --call PLM and insert the data so far
      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data(
                              p_api_version                   => 1
                             ,p_object_name                   => 'CS_SERVICE_REQUEST'
                             ,p_attributes_row_table          => l_user_attr_row_table
                             ,p_attributes_data_table         => l_user_attr_data_table
                             ,p_pk_column_name_value_pairs    => l_pk_name_value_pair
                             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
                             ,p_user_privileges_on_object     => l_user_privileges_on_object
                             ,p_entity_id                     => NULL
                             ,p_entity_index                  => NULL
                             ,p_entity_code                   => NULL
                             ,p_debug_level                   => 0
                             ,p_init_error_handler            => FND_API.G_TRUE
                             ,p_write_to_concurrent_log       => FND_API.G_TRUE
                             ,p_init_fnd_msg_list             => FND_API.G_FALSE
                             ,p_log_errors                    => FND_API.G_TRUE
                             ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
                             ,p_commit                        => FND_API.G_FALSE
                             ,x_failed_row_id_list            => x_failed_row_id_list
                             ,x_return_status                 => x_return_status
                             ,x_errorcode                     => x_errorcode
                             ,x_msg_count                     => x_msg_count
                             ,x_msg_data                      => x_msg_data );



      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
        FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'After processing first context: PLM status :' ||
           x_return_status
	);
      END IF;

      -- populate the new audit record with what is structure
      -- MAYA need to add
      For i IN 1..l_new_Ext_Attr_Audit_table.COUNT LOOP
        populate_sr_ext_attr_audit_rec(
                 p_incident_id        => l_new_Ext_Attr_Audit_table(i).pk_column_1
                ,p_context            => l_new_Ext_Attr_Audit_table(i).context
                ,p_attr_group_id      => l_new_Ext_Attr_Audit_table(i).attr_group_id
                ,p_row_id             => l_new_Ext_Attr_Audit_table(i).row_identifier
                ,p_ext_attr_tbl       => p_ext_attr_tbl
                ,p_sr_audit_rec_table => l_new_Ext_Attr_Audit_table
                ,x_rec_found          => l_rec_found);

        IF l_rec_found = 'N' THEN
          --raise error
          FND_MESSAGE.Set_Name('CS', 'CS_API_POP_SR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;

      --Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
        FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'Calling Audit API to audit the first context :'
         );
      END IF;

      --call the create audit procedure
      Create_Ext_Attr_Audit(
             P_SR_EA_new_Audit_rec_table    => l_new_Ext_Attr_Audit_table
            ,P_SR_EA_old_Audit_rec_table    => l_old_Ext_Attr_Audit_table
            ,p_object_name                  => 'CS_SERVICE_REQUEST'
            ,p_modified_by                  => p_modified_by
            ,p_modified_on                  => p_modified_on
            ,x_return_status                => x_return_status
            ,x_msg_count                    => x_msg_count
            ,x_msg_data                     => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        --raise error
        FND_MESSAGE.Set_Name('CS', 'CS_API_POP_SR_EXT_ATTR_WARN');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
        FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'After auditing first context: Audit status :' ||
           x_return_status
	);
      END IF;

      --Clear the old audit record structure for the new context
      l_old_Ext_Attr_Audit_table.DELETE;

      --Clear the new audit structure for the new context
      l_new_Ext_Attr_Audit_table.DELETE;

    END IF; -- of populating data for old context


    -- initialize the new audit rec count
    l_new_audit_count := l_new_Ext_Attr_Audit_table.COUNT + 1;

    --Need to make sure that all the primary key identifiers and the unqie composite key identifiers are passed
    --For 'CS_SERVICE_REQUEST' this is pk_col_1, context, attr_group_id.


    /**********************
      Pk_column_1 validation
    ***********************/

    --Check If pk_column_1 is passed
    IF p_ext_attr_grp_tbl(i).pk_column_1 IS NULL THEN
      --raise error
      CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                             p_token_an	=> l_api_name_full
                            ,p_token_mp	=> 'PK_COLUMN_1');
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      --pk_col_1 passed
      --Validate the pk_column_1 that is coming in
      OPEN c_check_sr_pk_col_1(to_number(p_ext_attr_grp_tbl(i).pk_column_1));
      FETCH c_check_sr_pk_col_1 INTO l_pk_col_1, l_context;
      CLOSE c_check_sr_pk_col_1;

      IF l_pk_col_1 IS NULL THEN
         CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an => l_api_name_full
                              ,p_token_v  => p_ext_attr_grp_tbl(i).pk_column_1
                              ,p_token_p  => 'PK_COLUMN_1');
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_context IS NULL THEN
         CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an => l_api_name_full
                              ,p_token_v  => p_ext_attr_grp_tbl(i).context
                              ,p_token_p  => 'CONTEXT');
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      --DBMS_OUTPUT.PUT_LINE ('Pass pk1 validation');

      -- If no error then
      --Need to pass the incident_id to the ego object.
      --populating the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing primary key to PLM
      l_pk_name_value_pair := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INCIDENT_ID', p_ext_attr_grp_tbl(i).pk_column_1));

      --populate the new audit record simultanoeosly while populating the EGO record structure.
      l_new_Ext_Attr_Audit_table(l_new_audit_count).pk_column_1 := p_ext_attr_grp_tbl(i).pk_column_1;

      --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table.pk_column_1'||l_new_Ext_Attr_Audit_table(l_new_audit_count).pk_column_1);

      --Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
        FND_LOG.String
	( FND_LOG.level_procedure , L_LOG_MODULE || ''
	, 'Primary Key Validation for Service Request Extensible Attributes successful :'
         );
      END IF;

    END IF; --end of p_ext_attr_grp_tbl(i).pk_column_1 is null


    /**********************
      Context validation
    ***********************/

    --Check if context is passed

    --DBMS_OUTPUT.PUT_LINE('p_ext_attr_grp_tbl(i).context'||p_ext_attr_grp_tbl(i).context);
    IF p_ext_attr_grp_tbl(i).context IS NULL THEN
      --raise error
      CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'CONTEXT');
      RAISE FND_API.G_EXC_ERROR;

    ELSE
      --context is passed
      --Check the context for the validated incident.
      --DBMS_OUTPUT.PUT_LINE('context passed');
      --DBMS_OUTPUT.PUT_LINE('l_context'||l_context);
      IF p_ext_attr_grp_tbl(i).context <> l_context AND
        p_ext_attr_grp_tbl(i).context <> '-1'  THEN
        --raise error
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an => l_api_name_full
                              ,p_token_v  => p_ext_attr_grp_tbl(i).context
                              ,p_token_p  => 'CONTEXT');
        RAISE FND_API.G_EXC_ERROR;

      ELSE
        --DBMS_OUTPUT.PUT_LINE('In else of context validation');
        --context matches
        --populate the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing the context.
        l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('CONTEXT', p_ext_attr_grp_tbl(i).context));

        --populate the new audit record for context.
        l_new_Ext_Attr_Audit_table(l_new_audit_count).context := p_ext_attr_grp_tbl(i).context;

        --DBMS_OUTPUT.PUT_LINE('Context matches'||l_new_Ext_Attr_Audit_table(l_new_audit_count).context);

        --Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
          FND_LOG.String
	  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	  , 'Context Validation for Service Request Extensible Attributes successful :'
          );
        END IF;

      END IF;
    END IF; -- end of p_ext_attr_grp_tbl(i).context is null

    /*************************
      Attribute Group validation
    **************************/
    --Instanciate a new EGO_USER_ATTR_ROW_OBJ or clear out the existing one for the old context
    --

    IF p_ext_attr_grp_tbl(i).context <> l_old_context  AND
       l_old_context IS NOT NULL THEN
      IF (l_user_attr_row_table IS NULL) THEN
        l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
        --DBMS_OUTPUT.PUT_LINE('instanciated');
      ELSE
        l_user_attr_row_table.DELETE();
        --DBMS_OUTPUT.PUT_LINE('deleted');
      END IF;
    ELSE
      IF (l_user_attr_row_table IS NULL) THEN
        l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
      END IF;
    END IF;

    --Extend the object and start adding values
    --DBMS_OUTPUT.PUT_LINE('attr group'||p_ext_attr_grp_tbl(i).attr_group_id);

    l_user_attr_row_table.EXTEND();

    IF p_ext_attr_grp_tbl(i).operation = 'CREATE' THEN
      IF p_ext_attr_grp_tbl(i).attr_group_id IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('ATtr group if not null');
        --assign to l_attr_group_id
        l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;

--        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
  --                                                           NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);

        l_user_attr_row_table(l_user_attr_row_table.LAST) :=
        EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object( p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                            NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);

        --DBMS_OUTPUT.PUT_LINE('added to riw table count is'||l_user_attr_row_table.COUNT);


      ELSIF p_ext_attr_grp_tbl(i).attr_group_app_id IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_type IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_name IS NOT NULL THEN

   --     l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,NULL,
     --                                                        p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
       --                                                     'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);

        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,NULL,
                                                             p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
                                                            'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);

        IF p_ext_attr_grp_tbl(i).attr_group_id IS NULL THEN
          -- then need to derive that for passing to populate_sr_ext_attr_audit_rec to get the old audit record
          OPEN c_get_attr_grp_id (p_ext_attr_grp_tbl(i).attr_group_app_id
                                 ,p_ext_attr_grp_tbl(i).attr_group_type
                                 ,p_ext_attr_grp_tbl(i).attr_group_name);
          FETCH c_get_attr_grp_id INTO l_attr_group_id;
          CLOSE c_get_attr_grp_id;
        ELSE
          l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;
        END IF;
      ELSE
        --Attr Group Information is null
        -- Raise Error
        CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'ATTR_GROUP_ID');
        RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- populate the new audit record for attr_group_id.
      l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

      --populate the row_identifier
      l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

      --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);

      --make sure that you create a corrosponding record in the old audit record structure
      -- initialize the new audit rec count
      l_old_audit_count := l_old_Ext_Attr_Audit_table.COUNT + 1;
      l_old_Ext_Attr_Audit_table(l_old_audit_count) := null;

    ELSIF p_ext_attr_grp_tbl(i).operation = 'UPDATE' THEN
      IF p_ext_attr_grp_tbl(i).attr_group_id IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('operation is update and attr_group_id is not null');

        l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;

        --Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
          FND_LOG.String
	  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	  , 'Operation is UPDATE - populate the audit structure :'
          );
        END IF;

        --populate the audit record structure for the current record in the database
        populate_sr_ext_attr_audit_rec(
          p_incident_id        => p_incident_id
         ,p_context            => p_ext_attr_grp_tbl(i).context
         ,p_attr_group_id      => p_ext_attr_grp_tbl(i).attr_group_id
         ,p_row_id             => p_ext_attr_grp_tbl(i).row_identifier
         ,p_ext_attr_tbl       => p_ext_attr_tbl
         ,p_sr_audit_rec_table => l_old_Ext_Attr_Audit_table
         ,x_rec_found          => l_rec_found
         );

        --Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
          FND_LOG.String
	  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	  , 'Status of record found for audit :' ||
          l_rec_found
          );
        END IF;
        --DBMS_OUTPUT.PUT_LINE('l_old_Ext_Attr_Audit_table.COUNT'||l_old_Ext_Attr_Audit_table.COUNT);


        IF l_rec_found = 'N' THEN
           -- call check_sr_context_change to check if context has changed during the update
           -- operation

           --Added FND_LOG
          IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
            FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'Record not found for audit checking if context is changed for Service Request :'
            );
          END IF;
           check_sr_context_change(
                   p_incident_id     => p_ext_attr_grp_tbl(i).pk_column_1
                  ,p_context         => p_ext_attr_grp_tbl(i).context
                  ,x_context_changed => l_cont_chg_on_update
                  ,x_db_incident_id  => l_db_incident_id
                  ,x_db_context      => l_db_sr_context);

           --Added FND_LOG
           IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
             FND_LOG.String
	     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	     , 'Status of contect change check :' ||
              l_cont_chg_on_update
             );
           END IF;


           --Added FND_LOG
           IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
             FND_LOG.String
	     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	     , 'Database Service Request identifier :' ||
              l_db_incident_id
             );
           END IF;

           --Added FND_LOG
           IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
             FND_LOG.String
	     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	     , 'Database context :' ||
              l_db_sr_context
             );
           END IF;

            --DBMS_OUTPUT.PUT_LINE('l_cont_chg_on_update'||l_cont_chg_on_update);
            --DBMS_OUTPUT.PUT_LINE('l_db_incident_id'||l_db_incident_id);
            --DBMS_OUTPUT.PUT_LINE('l_db_sr_context'||l_db_sr_context);
            --DBMS_OUTPUT.PUT_LINE('l_db_attr_group'||l_db_attr_group);

        END IF; -- end of l_rec_found


        IF l_cont_chg_on_update = 'Y' THEN
          --treat this record as a 'CREATE'

          --Added FND_LOG
          IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level  THEN
            FND_LOG.String
	    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
	    , 'Context has changed on Service  :'
            );
          END IF;

--          l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
  --                                                             NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);
l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                      NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);
          -- populate the new audit record for attr_group_id.
          l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

          --populate the row_identifier
          l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

          --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);

          --make sure that you create a corrosponding record in the old audit record structure
          -- initialize the old audit rec count
          l_old_audit_count := l_old_Ext_Attr_Audit_table.COUNT + 1;
          l_old_Ext_Attr_Audit_table(l_old_audit_count) := null;

        ELSE
          --treat this record as a 'UPDATE'
         -- l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
           --                                                    NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);
l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                      NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);

          -- populate the new audit record for attr_group_id.
          l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

          --populate the row_identifier
          l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

          --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);
         END IF;


      ELSIF p_ext_attr_grp_tbl(i).attr_group_app_id IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_type IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_name IS NOT NULL THEN

        -- then need to derive that for passing to populate_sr_ext_attr_audit_rec to get the old audit record
        IF p_ext_attr_grp_tbl(i).attr_group_id IS NULL THEN
          OPEN c_get_attr_grp_id (p_ext_attr_grp_tbl(i).attr_group_app_id
                                 ,p_ext_attr_grp_tbl(i).attr_group_type
                                 ,p_ext_attr_grp_tbl(i).attr_group_name);
          FETCH c_get_attr_grp_id INTO l_attr_group_id;
          CLOSE c_get_attr_grp_id;
        ELSE
          l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;
        END IF;

        --populate the audit record structure for the current record in the database
        populate_sr_ext_attr_audit_rec(
          p_incident_id        => p_incident_id
         ,p_context            => p_ext_attr_grp_tbl(i).context
         ,p_attr_group_id      => l_attr_group_id
         ,p_row_id             => p_ext_attr_grp_tbl(i).row_identifier
         ,p_ext_attr_tbl       => p_ext_attr_tbl
         ,p_sr_audit_rec_table => l_old_Ext_Attr_Audit_table
         ,x_rec_found          => l_rec_found
         );

        --DBMS_OUTPUT.PUT_LINE('l_old_Ext_Attr_Audit_table.COUNT'||l_old_Ext_Attr_Audit_table.COUNT);


        IF l_rec_found = 'N' THEN
           -- call check_sr_context_change to check if context has changed during the update
           -- operation
           check_sr_context_change(
                   p_incident_id     => p_ext_attr_grp_tbl(i).pk_column_1
                  ,p_context         => p_ext_attr_grp_tbl(i).context
                  ,x_context_changed => l_cont_chg_on_update
                  ,x_db_incident_id  => l_db_incident_id
                  ,x_db_context      => l_db_sr_context);

            --DBMS_OUTPUT.PUT_LINE('l_cont_chg_on_update'||l_cont_chg_on_update);
            --DBMS_OUTPUT.PUT_LINE('l_db_incident_id'||l_db_incident_id);
            --DBMS_OUTPUT.PUT_LINE('l_db_sr_context'||l_db_sr_context);
            --DBMS_OUTPUT.PUT_LINE('l_db_attr_group'||l_db_attr_group);

        END IF; -- end of l_rec_found

         IF l_cont_chg_on_update = 'Y' THEN
          --treat this record as a 'CREATE'

  --        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,NULL,
    --                                                           p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
      --                                                         'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);

        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,NULL,
                                                             p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
                                                            'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);
          -- populate the new audit record for attr_group_id.
          l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

          --populate the row_identifier
          l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

          --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);

          --make sure that you create a corrosponding record in the old audit record structure
          -- initialize the old audit rec count
          l_old_audit_count := l_old_Ext_Attr_Audit_table.COUNT + 1;
          l_old_Ext_Attr_Audit_table(l_old_audit_count) := null;

        ELSE
          --treat this record as a 'UPDATE'
       --   l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,NULL,
         --                                                      p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
           --                                                    'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);

        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,NULL,
                                                             p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
                                                            'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);


          -- populate the new audit record for attr_group_id.
          l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

          --populate the row_identifier
          l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

          --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);
         END IF;

      ELSE
        --Attr Group Information is null
        -- Raise Error
        CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'ATTR_GROUP_ID');
        RAISE FND_API.G_EXC_ERROR;

      END IF;

    ELSIF p_ext_attr_grp_tbl(i).operation = 'DELETE' THEN

      -- 5230517
      IF p_ext_attr_grp_tbl(i).attr_group_id IS NULL THEN
        CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'ATTR_GROUP_ID');
        RAISE FND_API.G_EXC_ERROR;

      END IF;
      -- 5230517_eof

      --check to see if the row being deleted really exists
      l_valid_check := IS_ROW_VALID(p_incident_id   => p_ext_attr_grp_tbl(i).pk_column_1
                                   ,p_context       => p_ext_attr_grp_tbl(i).context
                                   ,p_attr_group_id => p_ext_attr_grp_tbl(i).attr_group_id
                                   ,x_msg_data      => l_msg_data
                                   ,x_msg_count     => l_msg_count
                                   ,x_return_status => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check = 'Y' THEN
      --  l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
        --                                                     NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);

l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                               NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);
     -- 5230517: do not think UI needs this. Should let PLM throw exceptions.
    /*
      ELSE
        --This has been added for the UI
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        RETURN;
      */
      END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Successfully added to table');

    /**************************
       Attribute Validation
    **************************/


    IF p_ext_attr_tbl.COUNT > 0 THEN

      --DBMS_OUTPUT.PUT_LINE('p_ext_attr_tbl.COUNT'||p_ext_attr_tbl.COUNT);

      --pass the entire attribute data to a local table which can be used for manipulation
      l_ext_attr_tbl := p_ext_attr_tbl;

      IF p_ext_attr_grp_tbl(i).mapping_req = 'Y' THEN
        --need to get the metadata definition dor attributes defined for attribute group
        --Call Procedure Get_Attr_Group_Metadata

        --DBMS_OUTPUT.PUT_LINE('Calling Attr Grp Metadata');
        Get_Attr_Group_Metadata(
                 p_attr_group_id   => p_ext_attr_grp_tbl(i).attr_group_id
                ,x_application_id  => l_application_id
                ,x_attr_group_type => l_attr_group_type
                ,x_attr_group_name => l_attr_group_name);

        IF l_application_id IS NOT NULL AND
           l_attr_group_type IS NOT NULL AND
           l_attr_group_name IS NOT NULL THEN


          --get the Attribute Metadata defined for this Attribute Group.
	  Get_Attr_Metadata(
                   p_row_identifier  => p_ext_attr_grp_tbl(i).row_identifier
                  ,p_application_id  => l_application_id
                  ,p_attr_group_type => l_attr_group_type
                  ,p_attr_group_name => l_attr_group_name
                  ,p_ext_attr_tbl    => l_ext_attr_tbl);

        END IF; -- end if of l_application_id IS NULL ..
      END IF; -- end if of IF p_ext_attr_grp_tbl(i).mapping_req = 'Y'

      --Get the attributes relevant to the attribute group and prepare to pass it to PLM
      -- Instanciate a new EGO_USER_ATTR_DATA_TABLE or clear out the existing one --
      IF p_ext_attr_grp_tbl(i).context <> l_old_context  AND
        l_old_context IS NOT NULL THEN
        IF (l_user_attr_data_table IS NULL) THEN
          l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
        ELSE
          l_user_attr_data_table.DELETE();
        END IF;
      ELSE
        IF (l_user_attr_data_table IS NULL) THEN
          l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
        END IF;
      END IF;

      FOR j IN l_ext_attr_tbl.FIRST .. l_ext_attr_tbl.LAST  LOOP
        IF p_ext_attr_grp_tbl(i).row_identifier = l_ext_attr_tbl(j).row_identifier THEN
          l_user_attr_data_table.EXTEND();
          l_user_attr_data_table(l_user_attr_data_table.LAST) := EGO_USER_ATTR_DATA_OBJ(l_ext_attr_tbl(j).row_identifier, l_ext_attr_tbl(j).attr_name,
                                                                 l_ext_attr_tbl(j).attr_value_str,l_ext_attr_tbl(j).attr_value_num,
                                                                 l_ext_attr_tbl(j).attr_value_date,l_ext_attr_tbl(j).attr_value_display, NULL, NULL);
        END IF;
      END LOOP;

      --DBMS_OUTPUT.PUT_LINE('l_user_attr_data_table.COUNT'||l_user_attr_data_table.COUNT);

    ELSE
      l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
    END IF;  -- count > 1

    --set the old context
    l_old_context := p_ext_attr_grp_tbl(i).context;

    --DBMS_OUTPUT.PUT_LINE('l_old_context'||l_old_context);


    /*************************************
      Call PLM API If last record
    **************************************/

    IF i = l_count THEN
      --DBMS_OUTPUT.PUT_LINE('on last record');
      IF l_cont_chg_on_update = 'Y'
      THEN
        delete_old_context
        ( p_pk_column_1         => l_db_incident_id
        , p_context             => l_db_sr_context
        , x_failed_row_id_list  => x_failed_row_id_list
        , x_return_status       => x_return_status
        , x_errorcode           => x_errorcode
        , x_msg_count           => x_msg_count
        , x_msg_data            => x_msg_data
        );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF; -- l_cont_chg_on_update = 'Y'
      --on last record
      --DBMS_OUTPUT.PUT_LINE('count of l_user_attr_row_table'||l_user_attr_row_table.COUNT);
      --DBMS_OUTPUT.PUT_LINE('count of l_user_attr_data_table'||l_user_attr_data_table.COUNT);
      --DBMS_OUTPUT.PUT_LINE('count of l_pk_name_value_pair'||l_pk_name_value_pair.COUNT);
      --DBMS_OUTPUT.PUT_LINE('count of l_class_code_name_value_pairs'||l_class_code_name_value_pairs.COUNT);

      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data(
                              p_api_version                   => 1
                             ,p_object_name                   => 'CS_SERVICE_REQUEST'
                             ,p_attributes_row_table          => l_user_attr_row_table
                             ,p_attributes_data_table         => l_user_attr_data_table
                             ,p_pk_column_name_value_pairs    => l_pk_name_value_pair
                             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
                             ,p_user_privileges_on_object     => l_user_privileges_on_object
                             ,p_entity_id                     => NULL
                             ,p_entity_index                  => NULL
                             ,p_entity_code                   => NULL
                             ,p_debug_level                   => 0
                             ,p_init_error_handler            => FND_API.G_TRUE
                             ,p_write_to_concurrent_log       => FND_API.G_TRUE
                             ,p_init_fnd_msg_list             => FND_API.G_FALSE
                             ,p_log_errors                    => FND_API.G_TRUE
                             ,p_add_errors_to_fnd_stack       => FND_API.G_TRUE
                             ,p_commit                        => FND_API.G_FALSE
                             ,x_failed_row_id_list            => x_failed_row_id_list
                             ,x_return_status                 => x_return_status
                             ,x_errorcode                     => x_errorcode
                             ,x_msg_count                     => x_msg_count
                             ,x_msg_data                      => x_msg_data );

      --DBMS_OUTPUT.PUT_LINE('x_return_status'||x_return_status);
      --DBMS_OUTPUT.PUT_LINE('x_failed_row_id_list'||x_failed_row_id_list);
      --DBMS_OUTPUT.PUT_LINE('x_msg_data'||x_msg_data);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --DBMS_OUTPUT.PUT_LINE('Calling populate_sr_ext_attr_audit_rec');  --executed


      -- populate the new audit record with what is structure
      -- MAYA need to add
      -- DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table'||l_new_Ext_Attr_Audit_table.COUNT); --executed

     -- Fix bug 5230517
     -- Audit only in CREATE and UPDATE operations
     IF p_ext_attr_grp_tbl(i).operation <> 'DELETE' THEN
       For i IN 1..l_new_Ext_Attr_Audit_table.COUNT LOOP

        --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table(i).pk_column_1'||l_new_Ext_Attr_Audit_table(i).pk_column_1); --executed
        --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table(i).context'||l_new_Ext_Attr_Audit_table(i).context);         --executed
        --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table(i).attr_group_id'||l_new_Ext_Attr_Audit_table(i).attr_group_id); --executed
        --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table(i).row_identifier'||l_new_Ext_Attr_Audit_table(i).row_identifier); --executed
        --DBMS_OUTPUT.PUT_LINE('calling populate_sr_ext_attr_audit_rec'); --executed

        populate_sr_ext_attr_audit_rec(
                   p_incident_id        => l_new_Ext_Attr_Audit_table(i).pk_column_1
                  ,p_context            => l_new_Ext_Attr_Audit_table(i).context
                  ,p_attr_group_id      => l_new_Ext_Attr_Audit_table(i).attr_group_id
                  ,p_row_id             => l_new_Ext_Attr_Audit_table(i).row_identifier
                  ,p_ext_attr_tbl       => p_ext_attr_tbl
                  ,p_sr_audit_rec_table => l_new_Ext_Attr_Audit_table
                  ,x_rec_found          => l_rec_found);

        --DBMS_OUTPUT.PUT_LINE('l_rec_found'||l_rec_found);


        IF l_rec_found = 'N' THEN
          --raise error
          FND_MESSAGE.Set_Name('CS', 'CS_API_POP_SR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;

      --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table'||l_new_Ext_Attr_Audit_table.COUNT);

      --call the create audit procedure
      Create_Ext_Attr_Audit(
                   P_SR_EA_new_Audit_rec_table    => l_new_Ext_Attr_Audit_table
                  ,P_SR_EA_old_Audit_rec_table    => l_old_Ext_Attr_Audit_table
                  ,p_object_name                  => 'CS_SERVICE_REQUEST'
                  ,p_modified_by                  => p_modified_by
                  ,p_modified_on                  => p_modified_on
                  ,x_return_status                => x_return_status
                  ,x_msg_count                    => x_msg_count
                  ,x_msg_data                     => x_msg_data);

    END IF; -- end bug 5230517 fix.

      IF l_cont_chg_on_update = 'Y' THEN
      /*************************************************************
        --Need to clear the EGO structures
        l_pk_name_value_pair.DELETE();
        l_class_code_name_value_pairs.DELETE();
        l_user_attr_row_table.DELETE();
        l_count := 0;

        --DBMS_OUTPUT.PUT_LINE('In context change logic');

        --get all the values in the database for the old context
        FOR v_get_old_context_value IN c_get_old_context_value(l_db_incident_id,
                                                               l_db_sr_context) LOOP
          --DBMS_OUTPUT.PUT_LINE('v_get_old_context_value.incident_id'||v_get_old_context_value.incident_id);
          --DBMS_OUTPUT.PUT_LINE('v_get_old_context_value.context'||v_get_old_context_value.context);
          --DBMS_OUTPUT.PUT_LINE('v_get_old_context_value.attr_group_id'||v_get_old_context_value.attr_group_id);

          l_count := l_count + 1;
          --set the primary key identifiers to pass to PLM
          --populating the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing primary key to PLM
          l_pk_name_value_pair := EGO_COL_NAME_VALUE_PAIR_ARRAY
                                 (EGO_COL_NAME_VALUE_PAIR_OBJ('INCIDENT_ID', v_get_old_context_value.incident_id));

          --set the context to pass to PLM only SR_TYPE_ID
          --populate the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing the context.
          l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
                                          (EGO_COL_NAME_VALUE_PAIR_OBJ('CONTEXT', v_get_old_context_value.context));

          --Instanciate a new EGO_USER_ATTR_ROW_OBJ (only once)
          IF (l_user_attr_row_table IS NULL) THEN
            l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
          END IF;

          --Extend the object to add value it it
          l_user_attr_row_table.EXTEND();
--          l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(l_count,v_get_old_context_value.attr_group_id,
  --                                                               NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);

l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(l_count,v_get_old_context_value.attr_group_id,
                                                              NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);

        END LOOP;
        -- Instantiate the attribute table once
        l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();

        --DBMS_OUTPUT.PUT_LINE('Calling to delete data, user attr row table count:'|| l_user_attr_row_table.count);

        --Call PLM for deleting the old data
        EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data(
                                p_api_version                   =>  1
                               ,p_object_name                   =>  'CS_SERVICE_REQUEST'
                               ,p_attributes_row_table          =>  l_user_attr_row_table
                               ,p_attributes_data_table         =>  l_user_attr_data_table
                               ,p_pk_column_name_value_pairs    =>  l_pk_name_value_pair
                               ,p_class_code_name_value_pairs   =>  l_class_code_name_value_pairs
                               ,p_user_privileges_on_object     =>  l_user_privileges_on_object
                               ,p_entity_id                     =>  NULL
                               ,p_entity_index                  =>  NULL
                               ,p_entity_code                   =>  NULL
                               ,p_debug_level                   =>  0
                               ,p_init_error_handler            =>  FND_API.G_TRUE
                               ,p_write_to_concurrent_log       =>  FND_API.G_TRUE
                               ,p_init_fnd_msg_list             =>  FND_API.G_FALSE
                               ,p_log_errors                    =>  FND_API.G_TRUE
                               ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE
                               ,p_commit                        =>  FND_API.G_FALSE
                               ,x_failed_row_id_list            =>  x_failed_row_id_list
                               ,x_return_status                 =>  x_return_status
                               ,x_errorcode                     =>  x_errorcode
                               ,x_msg_count                     =>  x_msg_count
                               ,x_msg_data                      =>  x_msg_data );

      *****************************************************/
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


        --Clear the old audit record structure for the new context
        l_old_Ext_Attr_Audit_table.DELETE;

        --Clear the new audit structure for the new context
        l_new_Ext_Attr_Audit_table.DELETE;
      END IF;
    END IF;
/***********************PARTY ROLE IMPLEMENTATION ******************************/

  ELSIF p_ext_attr_grp_tbl(i).object_name = 'CS_PARTY_ROLE' THEN
    IF p_ext_attr_grp_tbl(i).context <> l_old_context  AND
      l_old_context IS NOT NULL THEN

      --DBMS_OUTPUT.PUT_LINE('In here');
      --DBMS_OUTPUT.PUT_LINE('context changed');
      --context has changed
      --call PLM and insert the data so far

      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data(
                              p_api_version                   => 1
                             ,p_object_name                   => 'CS_PARTY_ROLE'
                             ,p_attributes_row_table          => l_user_attr_row_table
                             ,p_attributes_data_table         => l_user_attr_data_table
                             ,p_pk_column_name_value_pairs    => l_pk_name_value_pair
                             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
                             ,p_user_privileges_on_object     => l_user_privileges_on_object
                             ,p_entity_id                     =>  NULL
                             ,p_entity_index                  =>  NULL
                             ,p_entity_code                   =>  NULL
                             ,p_debug_level                   =>  0
                             ,p_init_error_handler            =>  FND_API.G_TRUE
                             ,p_write_to_concurrent_log       =>  FND_API.G_TRUE
                             ,p_init_fnd_msg_list             =>  FND_API.G_FALSE
                             ,p_log_errors                    =>  FND_API.G_TRUE
                             ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE
                             ,p_commit                        =>  FND_API.G_FALSE
                             ,x_failed_row_id_list            => x_failed_row_id_list
                             ,x_return_status                 => x_return_status
                             ,x_errorcode                     => x_errorcode
                             ,x_msg_count                     => x_msg_count
                             ,x_msg_data                      => x_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --reset the old_context to null;
      --NOT SURE IF THIS IS NEEDED

      -- populate the new audit record with what is structure
      -- MAYA need to add
      --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table.COUNT'||l_new_Ext_Attr_Audit_table.COUNT);

      For i IN 1..l_new_Ext_Attr_Audit_table.COUNT LOOP
        populate_pr_ext_attr_audit_rec(
                 p_incident_id        => to_number(l_new_Ext_Attr_Audit_table(i).pk_column_1)
                ,p_party_id           => to_number(l_new_Ext_Attr_Audit_table(i).pk_column_2)
                ,p_contact_type       => l_new_Ext_Attr_Audit_table(i).pk_column_3
                ,p_party_role_code    => l_new_Ext_Attr_Audit_table(i).pk_column_4
                ,p_context            => l_new_Ext_Attr_Audit_table(i).context
                ,p_attr_group_id      => l_new_Ext_Attr_Audit_table(i).attr_group_id
                ,p_row_id             => l_new_Ext_Attr_Audit_table(i).row_identifier
                ,p_ext_attr_tbl       => p_ext_attr_tbl
                ,p_sr_audit_rec_table => l_new_Ext_Attr_Audit_table
                ,x_rec_found          => l_rec_found);

        IF l_rec_found = 'N' THEN
          --raise error
          FND_MESSAGE.Set_Name('CS', 'CS_API_POP_PR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;

      --call the create audit procedure
      Create_Ext_Attr_Audit(
                 P_SR_EA_new_Audit_rec_table    => l_new_Ext_Attr_Audit_table
                ,P_SR_EA_old_Audit_rec_table    => l_old_Ext_Attr_Audit_table
                ,p_object_name                  => 'CS_PARTY_ROLE'
                ,p_modified_by                  => p_modified_by
                ,p_modified_on                  => p_modified_on
                ,x_return_status                => x_return_status
                ,x_msg_count                    => x_msg_count
                ,x_msg_data                     => x_msg_data);



      --Clear the old audit record structure for the new context
      l_old_Ext_Attr_Audit_table.DELETE;

      --Clear the new audit structure for the new context
      l_new_Ext_Attr_Audit_table.DELETE;

    END IF; -- of populating data for old context

    --DBMS_OUTPUT.PUT_LINE('In PR Implementation');

    -- initialize the new audit rec count
    l_new_audit_count := l_new_Ext_Attr_Audit_table.COUNT + 1;

    /*********************************************************
        pk_column_1 pk_column2, pk_column3, pk_column4 validation
    **********************************************************/

    --DBMS_OUTPUT.PUT_LINE('IN PK VALIDATION');
    --Check If composite primary key identifiers are passed
    IF p_ext_attr_grp_tbl(i).pk_column_1 IS NULL OR
      p_ext_attr_grp_tbl(i).pk_column_2 IS NULL OR
      p_ext_attr_grp_tbl(i).pk_column_3 IS NULL OR
      p_ext_attr_grp_tbl(i).pk_column_4 IS NULL THEN
      --raise error
      CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                             p_token_an	=> l_api_name_full
                            ,p_token_mp	=> 'PARTY_ROLE_COMPOSITE_KEY');
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --DBMS_OUTPUT.PUT_LINE('validating the primary key');
      --composite key passed
      --Validate the composite key that is coming in
      OPEN c_check_pr_pk_cols( to_number(p_ext_attr_grp_tbl(i).pk_column_1)
                              ,to_number(p_ext_attr_grp_tbl(i).pk_column_2)
                              ,p_ext_attr_grp_tbl(i).pk_column_3
                              ,p_ext_attr_grp_tbl(i).pk_column_4);
      FETCH c_check_pr_pk_cols  INTO l_pk_col_1, l_pk_col_2, l_pk_col_3, l_pk_col_4;
      CLOSE c_check_pr_pk_cols;

      --DBMS_OUTPUT.PUT_LINE('validating the primary key successful');

      IF l_pk_col_1 IS NULL OR
         l_pk_col_2 IS NULL OR
         l_pk_col_3 IS NULL OR
         l_pk_col_4 IS NULL THEN
         --raise error
         l_composite_key := p_ext_attr_grp_tbl(i).pk_column_1||' , '||p_ext_attr_grp_tbl(i).pk_column_2||
                            ' , '||p_ext_attr_grp_tbl(i).pk_column_3||' , '||p_ext_attr_grp_tbl(i).pk_column_4;

         CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an => l_api_name_full
                              ,p_token_v  => l_composite_key
                              ,p_token_p  => 'COMPOSITE_KEY');
         RAISE FND_API.G_EXC_ERROR;

      END IF;

      -- If no error then
      --Need to set the composite primary key for the party role implementation.
      --populating the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing primary key to PLM

      l_pk_name_value_pair := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INCIDENT_ID', p_ext_attr_grp_tbl(i).pk_column_1),
                              EGO_COL_NAME_VALUE_PAIR_OBJ('PARTY_ID', p_ext_attr_grp_tbl(i).pk_column_2),
                              EGO_COL_NAME_VALUE_PAIR_OBJ('CONTACT_TYPE', p_ext_attr_grp_tbl(i).pk_column_3),
                              EGO_COL_NAME_VALUE_PAIR_OBJ('PARTY_ROLE_CODE', p_ext_attr_grp_tbl(i).pk_column_4));

      --DBMS_OUTPUT.PUT_LINE('populated the EGO_COL_NAME_VALUE_PAIR_ARRAY');
      --populate the new audit record simultanoeosly while populating the EGO record structure.
      l_new_Ext_Attr_Audit_table(l_new_audit_count).pk_column_1 := p_ext_attr_grp_tbl(i).pk_column_1;
      l_new_Ext_Attr_Audit_table(l_new_audit_count).pk_column_2 := p_ext_attr_grp_tbl(i).pk_column_2;
      l_new_Ext_Attr_Audit_table(l_new_audit_count).pk_column_3 := p_ext_attr_grp_tbl(i).pk_column_3;
      l_new_Ext_Attr_Audit_table(l_new_audit_count).pk_column_4 := p_ext_attr_grp_tbl(i).pk_column_4;


      --DBMS_OUTPUT.PUT_LINE('populated the l_new_Ext_Attr_Audit_table');
    END IF; --end of pk cols validation

    /**********************
       Context validation
    ***********************/

    --DBMS_OUTPUT.PUT_LINE('validating context');
    --Check if context is passed
    IF p_ext_attr_grp_tbl(i).context IS NULL THEN
      --raise error
      CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                             p_token_an	=> l_api_name_full
                            ,p_token_mp	=> 'PARTY CONTEXT');
      RAISE FND_API.G_EXC_ERROR;
    ELSE
      --DBMS_OUTPUT.PUT_LINE('context passed');
      --context is passed
      --Check the context for the validated incident.
      IF p_ext_attr_grp_tbl(i).context <> p_ext_attr_grp_tbl(i).pk_column_4 THEN
        --raise error
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an => l_api_name_full
                              ,p_token_v  => p_ext_attr_grp_tbl(i).context
                              ,p_token_p  => 'PARTY CONTEXT');
        RAISE FND_API.G_EXC_ERROR;
      ELSE

        --DBMS_OUTPUT.PUT_LINE('context matches');
        --context matches
        --populate the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing the context.
        l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('CONTEXT', p_ext_attr_grp_tbl(i).context));

        --DBMS_OUTPUT.PUT_LINE('populated EGO_COL_NAME_VALUE_PAIR_ARRAY');

        --populate the new audit record for context.
        l_new_Ext_Attr_Audit_table(l_new_audit_count).context := p_ext_attr_grp_tbl(i).context;

        --DBMS_OUTPUT.PUT_LINE('populated l_new_Ext_Attr_Audit_table');

      END IF;
    END IF; -- end of p_ext_attr_grp_tbl(i).context is null

    /*************************
        Attribute Group validation
    **************************/
    IF p_ext_attr_grp_tbl(i).context <> l_old_context  AND
      l_old_context IS NOT NULL THEN
      IF (l_user_attr_row_table IS NULL) THEN
        l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
        --DBMS_OUTPUT.PUT_LINE('instanciated');
      ELSE
        l_user_attr_row_table.DELETE();
        --DBMS_OUTPUT.PUT_LINE('deleted');
      END IF;
    ELSE
      IF (l_user_attr_row_table IS NULL) THEN
        l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
      END IF;
    END IF;

    --Extend the object and start adding values
    l_user_attr_row_table.EXTEND();

    IF p_ext_attr_grp_tbl(i).operation = 'CREATE' THEN
      IF p_ext_attr_grp_tbl(i).attr_group_id IS NOT NULL THEN

        l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;
--        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
  --                                                           NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);
l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                             NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);
        --DBMS_OUTPUT.PUT_LINE('populated EGO_USER_ATTR_ROW_OBJ');

        l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;

      ELSIF p_ext_attr_grp_tbl(i).attr_group_app_id IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_type IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_name IS NOT NULL THEN

---        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,NULL,
   ---                                                          p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
      ---                                                      'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);

l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,NULL,
                                                             p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
                                                            'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_CREATE_MODE);
        IF p_ext_attr_grp_tbl(i).attr_group_id IS NULL THEN
          -- then need to derive that for passing to populate_sr_ext_attr_audit_rec to get the old audit record
          OPEN c_get_attr_grp_id (p_ext_attr_grp_tbl(i).attr_group_app_id
                                 ,p_ext_attr_grp_tbl(i).attr_group_type
                                 ,p_ext_attr_grp_tbl(i).attr_group_name);
          FETCH c_get_attr_grp_id INTO l_attr_group_id;
          CLOSE c_get_attr_grp_id;
        ELSE
          l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;
        END IF;
      ELSE
        -- Raise Error
        --Attr Group Information is null
        CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'ATTR_GROUP_ID');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- populate the new audit record for attr_group_id.
      l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

      --populate the row_identifier
      l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

      --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);

      --make sure that you create a corrosponding record in the old audit record structure
      -- initialize the new audit rec count

      l_old_audit_count := l_old_Ext_Attr_Audit_table.COUNT + 1;
      l_old_Ext_Attr_Audit_table(l_old_audit_count) := null;

    ELSIF p_ext_attr_grp_tbl(i).operation = 'UPDATE' THEN

      --DBMS_OUTPUT.PUT_LINE('Operation is UPDATE');

      IF p_ext_attr_grp_tbl(i).attr_group_id IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('Calling populate pr ext attr audit');

        l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;

        --populate the audit record structure for the current record in the database
        populate_pr_ext_attr_audit_rec(
                  p_incident_id        => to_number(p_ext_attr_grp_tbl(i).pk_column_1)
                 ,p_party_id           => to_number(p_ext_attr_grp_tbl(i).pk_column_2)
                 ,p_contact_type       => p_ext_attr_grp_tbl(i).pk_column_3
                 ,p_party_role_code    => p_ext_attr_grp_tbl(i).pk_column_4
                 ,p_context            => p_ext_attr_grp_tbl(i).context
                 ,p_attr_group_id      => p_ext_attr_grp_tbl(i).attr_group_id
                 ,p_row_id             => p_ext_attr_grp_tbl(i).row_identifier
                 ,p_ext_attr_tbl       => p_ext_attr_tbl
                 ,p_sr_audit_rec_table => l_old_Ext_Attr_Audit_table
                 ,x_rec_found          => l_rec_found
             );


        --DBMS_OUTPUT.PUT_LINE(' l_rec_found'||l_rec_found);

        IF l_rec_found = 'N' THEN
          -- call check_sr_context_change to check if context has changed during the update
          -- operation
          -- Raise error
          FND_MESSAGE.Set_Name('CS', 'CS_API_POP_PR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

        ELSE
          --treat this record as a 'UPDATE'
--          l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
  --                                                             NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);

l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                             NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);
        END IF;


        --DBMS_OUTPUT.PUT_LINE('audit attr value is'||l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id);

      ELSIF p_ext_attr_grp_tbl(i).attr_group_app_id IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_type IS NOT NULL AND
            p_ext_attr_grp_tbl(i).attr_group_name IS NOT NULL THEN


        -- then need to derive that for passing to populate_sr_ext_attr_audit_rec to get the old audit record
        IF p_ext_attr_grp_tbl(i).attr_group_id IS NULL THEN
          OPEN c_get_attr_grp_id (p_ext_attr_grp_tbl(i).attr_group_app_id
                                 ,p_ext_attr_grp_tbl(i).attr_group_type
                                 ,p_ext_attr_grp_tbl(i).attr_group_name);
          FETCH c_get_attr_grp_id INTO l_attr_group_id;
          CLOSE c_get_attr_grp_id;
        ELSE
          l_attr_group_id := p_ext_attr_grp_tbl(i).attr_group_id;
        END IF;


        --populate the audit record structure for the current record in the database
        populate_pr_ext_attr_audit_rec(
                  p_incident_id        => to_number(p_ext_attr_grp_tbl(i).pk_column_1)
                 ,p_party_id           => to_number(p_ext_attr_grp_tbl(i).pk_column_2)
                 ,p_contact_type       => p_ext_attr_grp_tbl(i).pk_column_3
                 ,p_party_role_code    => p_ext_attr_grp_tbl(i).pk_column_4
                 ,p_context            => p_ext_attr_grp_tbl(i).context
                 ,p_attr_group_id      => p_ext_attr_grp_tbl(i).attr_group_id
                 ,p_row_id             => p_ext_attr_grp_tbl(i).row_identifier
                 ,p_ext_attr_tbl       => p_ext_attr_tbl
                 ,p_sr_audit_rec_table => l_old_Ext_Attr_Audit_table
                 ,x_rec_found          => l_rec_found
             );

        IF l_rec_found = 'N' THEN
                -- call check_sr_context_change to check if context has changed during the update
                -- operation
                -- Raise error
          FND_MESSAGE.Set_Name('CS', 'CS_API_POP_PR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;

        ELSE
          --treat this record as a 'UPDATE'
--          l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,NULL,
  --                                                             p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
    --                                                          'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);
l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,NULL,
                                                               p_ext_attr_grp_tbl(i).attr_group_app_id,p_ext_attr_grp_tbl(i).attr_group_type,p_ext_attr_grp_tbl(i).attr_group_name,
                                                     'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_UPDATE_MODE);
        END IF;

      ELSE
        -- Raise Error
        -- MAYA NEED TO ADD
        --Attr Group Information is null
        CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'ATTR_GROUP_ID');
        RAISE FND_API.G_EXC_ERROR;
      END IF;

       -- populate the new audit record for attr_group_id.
        l_new_Ext_Attr_Audit_table(l_new_audit_count).attr_group_id := l_attr_group_id;

        --populate the row_identifier
        l_new_Ext_Attr_Audit_table(l_new_audit_count).row_identifier := p_ext_attr_grp_tbl(i).row_identifier;

    ELSIF p_ext_attr_grp_tbl(i).operation = 'DELETE' THEN

      -- 5230517
      IF p_ext_attr_grp_tbl(i).attr_group_id IS NULL THEN
        CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                               p_token_an	=> l_api_name_full
                              ,p_token_mp	=> 'ATTR_GROUP_ID');
        RAISE FND_API.G_EXC_ERROR;

      END IF;
      -- 5230517_eof

      --check to see if the row being deleted really exists
      l_valid_check := IS_ROW_VALID(p_incident_id   => p_ext_attr_grp_tbl(i).pk_column_1
                                   ,p_context       => p_ext_attr_grp_tbl(i).context
                                   ,p_attr_group_id => p_ext_attr_grp_tbl(i).attr_group_id
                                   ,x_msg_data      => l_msg_data
                                   ,x_msg_count     => l_msg_count
                                   ,x_return_status => l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF l_valid_check = 'Y' THEN
--        l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
  --                                                             NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);
l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(p_ext_attr_grp_tbl(i).row_identifier,p_ext_attr_grp_tbl(i).attr_group_id,
                                                       NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);

    -- 5230517 => should not eat the exception. Do nothing and let PLM throw exception.
    /*
      ELSE
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        RETURN;
     */

      END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Attr validation');

    --pass the entire attribute data to a local table which can be used for manipulation
    l_ext_attr_tbl := p_ext_attr_tbl;

    IF p_ext_attr_grp_tbl(i).mapping_req = 'Y' THEN
      --need to get the metadata definition dor attributes defined for attribute group
      --Call Procedure Get_Attr_Group_Metadata

      --DBMS_OUTPUT.PUT_LINE('Calling Attr Grp Metadata');
      Get_Attr_Group_Metadata(
                     p_attr_group_id   => p_ext_attr_grp_tbl(i).attr_group_id
                    ,x_application_id  => l_application_id
                    ,x_attr_group_type => l_attr_group_type
                    ,x_attr_group_name => l_attr_group_name);

      IF l_application_id IS NOT NULL AND
         l_attr_group_type IS NOT NULL AND
         l_attr_group_name IS NOT NULL THEN

        --get the Attribute Metadata defined for this Attribute Group.
	Get_Attr_Metadata(
                 p_row_identifier  => p_ext_attr_grp_tbl(i).row_identifier
                ,p_application_id  => l_application_id
                ,p_attr_group_type => l_attr_group_type
                ,p_attr_group_name => l_attr_group_name
                ,p_ext_attr_tbl    => l_ext_attr_tbl
                );

      END IF; -- end if of l_application_id IS NULL ..

    END IF; -- end if of IF p_ext_attr_grp_tbl(i).mapping_req = 'Y'


    --Get the attributes relevant to the attribute group and prepare to pass it to PLM
    -- Instanciate a new EGO_USER_ATTR_DATA_TABLE or clear out the existing one --
    IF p_ext_attr_grp_tbl(i).context <> l_old_context  AND
      l_old_context IS NOT NULL THEN
      IF (l_user_attr_data_table IS NULL) THEN
        l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
      ELSE
        l_user_attr_data_table.DELETE();
      END IF;
    ELSE
      IF (l_user_attr_data_table IS NULL) THEN
        l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();
      END IF;
    END IF;

    --DBMS_OUTPUT.PUT_LINE('Instanciated AAttr object');

    FOR j IN l_ext_attr_tbl.FIRST .. l_ext_attr_tbl.LAST
    LOOP
      IF p_ext_attr_grp_tbl(i).row_identifier = l_ext_attr_tbl(j).row_identifier THEN
        l_user_attr_data_table.EXTEND();
        l_user_attr_data_table(l_user_attr_data_table.LAST) := EGO_USER_ATTR_DATA_OBJ(l_ext_attr_tbl(j).row_identifier, l_ext_attr_tbl(j).attr_name,
                                                               l_ext_attr_tbl(j).attr_value_str,l_ext_attr_tbl(j).attr_value_num,
                                                               l_ext_attr_tbl(j).attr_value_date,
                                                               l_ext_attr_tbl(j).ATTR_VALUE_DISPLAY, NULL, NULL);

        --DBMS_OUTPUT.PUT_LINE('populated EGO_USER_ATTR_DATA_OBJ');
      END IF;

    END LOOP;

    --set the old context
    l_old_context := p_ext_attr_grp_tbl(i).context;

    --DBMS_OUTPUT.PUT_LINE('Old context'||l_old_context);

    IF i = l_count THEN
      --DBMS_OUTPUT.PUT_LINE('i in l_count');
      --on last record
      EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data(
                              p_api_version                   => 1
                             ,p_object_name                   => 'CS_PARTY_ROLE'
                             ,p_attributes_row_table          => l_user_attr_row_table
                             ,p_attributes_data_table         => l_user_attr_data_table
                             ,p_pk_column_name_value_pairs    => l_pk_name_value_pair
                             ,p_class_code_name_value_pairs   => l_class_code_name_value_pairs
                             ,p_user_privileges_on_object     => l_user_privileges_on_object
                             ,p_entity_id                     =>  NULL
                             ,p_entity_index                  =>  NULL
                             ,p_entity_code                   =>  NULL
                             ,p_debug_level                   =>  0
                             ,p_init_error_handler            =>  FND_API.G_TRUE
                             ,p_write_to_concurrent_log       =>  FND_API.G_TRUE
                             ,p_init_fnd_msg_list             =>  FND_API.G_FALSE
                             ,p_log_errors                    =>  FND_API.G_TRUE
                             ,p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE
                             ,p_commit                        =>  FND_API.G_FALSE
                             ,x_failed_row_id_list            => x_failed_row_id_list
                             ,x_return_status                 => x_return_status
                             ,x_errorcode                     => x_errorcode
                             ,x_msg_count                     => x_msg_count
                             ,x_msg_data                      => x_msg_data );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.Set_Name('CS', 'CS_API_PROC_SR_EXT_ATTR_WARN');
        FND_MSG_PUB.Add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;


    -- Fix bug 5230517
     -- Audit only in CREATE and UPDATE operations
     IF p_ext_attr_grp_tbl(i).operation <> 'DELETE' THEN
      For i IN 1..l_new_Ext_Attr_Audit_table.COUNT LOOP
        populate_pr_ext_attr_audit_rec(
                         p_incident_id        => to_number(l_new_Ext_Attr_Audit_table(i).pk_column_1)
                        ,p_party_id           => to_number(l_new_Ext_Attr_Audit_table(i).pk_column_2)
                        ,p_contact_type       => l_new_Ext_Attr_Audit_table(i).pk_column_3
                        ,p_party_role_code    => l_new_Ext_Attr_Audit_table(i).pk_column_4
                        ,p_context            => l_new_Ext_Attr_Audit_table(i).context
                        ,p_attr_group_id      => l_new_Ext_Attr_Audit_table(i).attr_group_id
                        ,p_row_id             => l_new_Ext_Attr_Audit_table(i).row_identifier
                        ,p_ext_attr_tbl       => p_ext_attr_tbl
                        ,p_sr_audit_rec_table => l_new_Ext_Attr_Audit_table
                        ,x_rec_found          => l_rec_found);

        IF l_rec_found = 'N' THEN
          --raise error
          FND_MESSAGE.Set_Name('CS', 'CS_API_POP_PR_EXT_ATTR_WARN');
          FND_MSG_PUB.Add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;

      --DBMS_OUTPUT.PUT_LINE('populated PR');
      --DBMS_OUTPUT.PUT_LINE('l_new_Ext_Attr_Audit_table'||l_new_Ext_Attr_Audit_table.COUNT);

      --call the create audit procedure
      Create_Ext_Attr_Audit(
                     P_SR_EA_new_Audit_rec_table    => l_new_Ext_Attr_Audit_table
                    ,P_SR_EA_old_Audit_rec_table    => l_old_Ext_Attr_Audit_table
                    ,p_object_name                  => 'CS_PARTY_ROLE'
                    ,p_modified_by                  => p_modified_by
                    ,p_modified_on                  => p_modified_on
                    ,x_return_status                => x_return_status
                    ,x_msg_count                    => x_msg_count
                    ,x_msg_data                     => x_msg_data);

            --DBMS_OUTPUT.PUT_LINE('after calling Create_Ext_Attr_Audit');
     END IF; -- bug fix 5230517_eof
    END IF;  -- l_count_if_eof

    --5230846
   ELSE -- if not CS_SERVICE_REQUEST and CS_PARTY_ROLE
        CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                               p_token_an => l_api_name_full
                              ,p_token_v  => p_ext_attr_grp_tbl(i).object_name
                              ,p_token_p  => 'OBJECT_NAME');
        RAISE FND_API.G_EXC_ERROR;
   END IF; -- object name check eof
 END LOOP;

ELSE

  --DBMS_OUTPUT.PUT_LINE('returning');
  RETURN;

END IF;
IF FND_API.To_Boolean(p_commit)
 THEN
  COMMIT WORK;
END IF;

EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO CS_EXTENSIBILITY_PVT;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO CS_EXTENSIBILITY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN OTHERS THEN
    ROLLBACK TO CS_EXTENSIBILITY_PVT;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

END Process_SR_Ext_Attrs;


PROCEDURE Get_Attr_Group_Metadata (
        p_attr_group_id                 IN          NUMBER
       ,x_application_id                OUT NOCOPY  NUMBER
       ,x_attr_group_type               OUT NOCOPY  VARCHAR2
       ,x_attr_group_name               OUT NOCOPY  VARCHAR2
)IS
Cursor c_get_attr_group_cur(p_attr_group_id IN NUMBER) IS
select application_id,
       attr_group_type,
       attr_group_name
  from ego_attr_groups_v
 where attr_group_id = p_attr_group_id;

BEGIN

OPEN  c_get_attr_group_cur(p_attr_group_id);
FETCH c_get_attr_group_cur INTO x_application_id, x_attr_group_type,x_attr_group_name ;
CLOSE c_get_attr_group_cur;

EXCEPTION

      WHEN OTHERS THEN
        null;
        --FND_MESSAGE.SET_NAME(G_APP_NAME);
        --FND_MESSAGE.SET_TOKEN(token => G_PROC_NAME_TOKEN, value => l_prog_name);
        --FND_MESSAGE.SET_TOKEN(token => G_SQLCODE_TOKEN, value => SQLCODE);
        --FND_MESSAGE.SET_TOKEN(token => G_SQLERRM_TOKEN, value => SQLERRM);
        --FND_MSG_PUB.add;

END Get_Attr_Group_Metadata;

PROCEDURE Get_Attr_Metadata (
        p_row_identifier                IN          NUMBER
       ,p_application_id                IN          NUMBER
       ,p_attr_group_type               IN          VARCHAR2
       ,p_attr_group_name               IN          VARCHAR2
       ,p_ext_attr_tbl                  IN  OUT     NOCOPY  CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE) IS

CURSOR c_get_attr_cur IS
SELECT  database_column, attr_name
  FROM  ego_attrs_v
 WHERE  application_id  = p_application_id
   AND  attr_group_type = p_attr_group_type
   AND  attr_group_name = p_attr_group_name;

TYPE attr_rec_type IS RECORD (database_column VARCHAR2(30), attr_name VARCHAR2(30));
TYPE attr_tbl_type IS TABLE OF attr_rec_type INDEX BY BINARY_INTEGER;
l_attr_tbl attr_tbl_type;

i           BINARY_INTEGER := 0;

BEGIN

IF p_ext_attr_tbl.COUNT = 0 THEN
  --DBMS_OUTPUT.PUT_LINE('NO ROWS FOUND IN EXT ATTR TABLE');
  -- RAISE ERROR;
  null;
END IF;

FOR l_attr_rec IN c_get_attr_cur LOOP
  l_attr_tbl(i).database_column := l_attr_rec.database_column;
  l_attr_tbl(i).attr_name       := l_attr_rec.attr_name;
  i := i + 1;
END LOOP;

FOR i IN p_ext_attr_tbl.FIRST .. p_ext_attr_tbl.LAST LOOP

  IF p_ext_attr_tbl.EXISTS(i) THEN

    IF p_ext_attr_tbl(i).row_identifier = p_row_identifier THEN

      IF p_ext_attr_tbl(i).column_name IS NULL THEN
        --DBMS_OUTPUT.PUT_LINE('COLUMN_NAME value not specified in P_EXT_ATTR_TBL row '||i);
        --raise error
        null;
      ELSE

        FOR j IN l_attr_tbl.FIRST .. l_attr_tbl.LAST LOOP

          IF l_attr_tbl(j).database_column = p_ext_attr_tbl(i).column_name THEN

            p_ext_attr_tbl(i).attr_name  := l_attr_tbl(j).attr_name;
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END IF;
  END IF;
  END LOOP;
END Get_Attr_Metadata;


PROCEDURE populate_pr_ext_attr_audit_rec(
          p_incident_id        IN NUMBER
         ,p_party_id           IN NUMBER
         ,p_contact_type       IN VARCHAR2
         ,p_party_role_code    IN VARCHAR2
         ,p_context            IN VARCHAR2
         ,p_attr_group_id      IN NUMBER
         ,p_row_id             IN NUMBER
         ,p_ext_attr_tbl       IN CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
         ,p_sr_audit_rec_table IN OUT NOCOPY Ext_Attr_Audit_Tbl_Type
         ,x_rec_found      OUT NOCOPY VARCHAR2
         ) IS


Cursor c_get_ext_attr_db_rec IS
select * from cs_sr_contacts_ext
where incident_id = p_incident_id
  and party_id = p_party_id
  and contact_type = p_contact_type
  and party_role_code = p_party_role_code
  and context = p_context
  and attr_group_id  = p_attr_group_id;

Cursor c_is_multi_row IS
select multi_row_code
  from ego_attr_groups_v
 where attr_group_id = p_attr_group_id;

Cursor c_get_unique_key (p_application_id IN NUMBER,
                         p_attr_group_name IN VARCHAR2,
                         p_attr_group_type IN VARCHAR2
                         ) IS
select attr_name, database_column
  from ego_attrs_v
where attr_group_name = p_attr_group_name
  and attr_group_type = p_attr_group_type
  and application_id =  p_application_id
  and unique_key_flag = 'Y';


i NUMBER := 0;
l_old_Ext_Attr_Audit_Tbl  Ext_Attr_Audit_Tbl_Type;
l_multi_row_code VARCHAR2(1);
l_attribute_name VARCHAR2(30);
l_database_column_name VARCHAR2(30);
l_application_id NUMBER;
l_attr_group_type VARCHAR2(30);
l_attr_group_name VARCHAR2(80);
l_unique_value_str VARCHAR2(4000);
L_unique_value_num NUMBER;
l_unique_value_date DATE;
l_unique_value_uom VARCHAR2(3);

l_sql VARCHAR2(4000);
g_newline varchar2(8) := fnd_global.newline;
l_cs_sr_contacts_ext_rec cs_sr_contacts_ext%ROWTYPE;


v_get_ext_attr_db_rec c_get_ext_attr_db_rec%ROWTYPE;

l_count NUMBER := 0;

l_create_new_record VARCHAR2(1) := 'N';
l_audit_table_empty VARCHAR2(1) := 'N';

p_col_1 NUMBER        := p_incident_id;
p_col_2 NUMBER        := p_party_id;
p_col_3 VARCHAR2(50)  := p_contact_type;
p_col_4 VARCHAR2(50)  := p_party_role_code;
p_col_5 VARCHAR2(30)  := p_context;
p_col_6 NUMBER        := p_attr_group_id;
p_col_7 VARCHAR2(150);
p_use_col7_flag VARCHAR2(1) := 'N';


BEGIN

--get the correct count of the records in the audit table
--DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.COUNT);

l_count := p_sr_audit_rec_table.COUNT;

IF p_attr_group_id IS NOT NULL AND
  p_incident_id IS NOT NULL AND
  p_party_id IS NOT NULL AND
  p_contact_type IS NOT NULL AND
  p_party_role_code IS NOT NULL AND
  p_context IS NOT NULL THEN

  --DBMS_OUTPUT.PUT_LINE('All parameters passed');

  --check if attribute group is multi_row_enabled
  OPEN c_is_multi_row;
  FETCH c_is_multi_row INTO l_multi_row_code;
  CLOSE c_is_multi_row;

  --DBMS_OUTPUT.PUT_LINE('Multi-Row flag is :'||l_multi_row_code); --executed

  IF l_multi_row_code = 'Y' then

    --DBMS_OUTPUT.PUT_LINE('In Multi-Row of PR');

    -- first get the attribute_group_name, attribute_group_type and application_id
    -- for this attribute_group_id
    Get_Attr_Group_Metadata (
              p_attr_group_id                => p_attr_group_id
             ,x_application_id               => l_application_id
             ,x_attr_group_type              => l_attr_group_type
             ,x_attr_group_name              => l_attr_group_name
              );

    --DBMS_OUTPUT.PUT_LINE('l_application_id'||l_application_id);
    --DBMS_OUTPUT.PUT_LINE('l_attr_group_type'||l_attr_group_type);
    --DBMS_OUTPUT.PUT_LINE('l_attr_group_name'||l_attr_group_name);

    IF l_application_id IS NOT NULL AND
      l_attr_group_type IS NOT NULL AND
      l_attr_group_name IS NOT NULL THEN

      --DBMS_OUTPUT.PUT_LINE('Trikey is not null');
      --DBMS_OUTPUT.PUT_LINE('calling unique key logic');

      --get the unique attribute maintained for this multi-row attribute group
      OPEN c_get_unique_key (l_application_id
                            ,l_attr_group_name
                            ,l_attr_group_type);
      FETCH c_get_unique_key into l_attribute_name, l_database_column_name;
      CLOSE c_get_unique_key;

      --DBMS_OUTPUT.PUT_LINE('l_attribute_name'||l_attribute_name);
      --DBMS_OUTPUT.PUT_LINE('l_database_column_name'||l_database_column_name);

      IF l_attribute_name IS NOT NULL THEN

        --DBMS_OUTPUT.PUT_LINE('l_attribute_name is not null');

        --traverse through the p_ext_attr_tbl and
        --get the value for the unique attribute group
        --this code assumes that the unique attribute is non-updateable
        --DBMS_OUTPUT.PUT_LINE('p_ext_attr_tbl.COUNT'||p_ext_attr_tbl.COUNT);

        FOR i IN 1..p_ext_attr_tbl.COUNT LOOP

          --DBMS_OUTPUT.PUT_LINE('row_identifier'||p_row_id);
          --DBMS_OUTPUT.PUT_LINE('p_ext_attr_tbl(i).row_identifier'||p_ext_attr_tbl(i).row_identifier);

          --DBMS_OUTPUT.PUT_LINE('l_attribute_name'||l_attribute_name);
          --DBMS_OUTPUT.PUT_LINE('p_ext_attr_tbl(i).attr_name'||p_ext_attr_tbl(i).attr_name);

          --DBMS_OUTPUT.PUT_LINE('column_name'||l_database_column_name);
          --DBMS_OUTPUT.PUT_LINE('p_ext_attr_tbl(i).column_name'||p_ext_attr_tbl(i).column_name);


          IF p_ext_attr_tbl(i).row_identifier = p_row_id AND
             p_ext_attr_tbl(i).attr_name = l_attribute_name OR
             p_ext_attr_tbl(i).column_name = l_database_column_name THEN
             --match found
             --get the unique value.  However the unique value may be a string
             --date, character, or uom so we have to check all possible combinations.
            --DBMS_OUTPUT.PUT_LINE('attr_value_str' || p_ext_attr_tbl(i).attr_value_str);
            --DBMS_OUTPUT.PUT_LINE('attr_value_num' || p_ext_attr_tbl(i).attr_value_num);
            --DBMS_OUTPUT.PUT_LINE('finding the unique attr');

            l_sql := 'SELECT * FROM CS_SR_CONTACTS_EXT WHERE INCIDENT_ID = :p_col_1';
            l_sql := l_sql||g_newline ||'AND PARTY_ID = :p_col_2';
            l_sql := l_sql||g_newline||'AND CONTACT_TYPE = :p_col_3';
            l_sql := l_sql||g_newline||'AND PARTY_ROLE_CODE = :p_col4';
            l_sql := l_sql||g_newline||'AND CONTEXT = :p_col_5';
            l_sql := l_sql||g_newline||' AND ATTR_GROUP_ID = :p_col_6';

            --DBMS_OUTPUT.PUT_LINE('l_sql'||l_sql);

            p_use_col7_flag :='N';

            IF p_ext_attr_tbl(i).attr_value_str IS NOT NULL Then
              --unique value is a string
              l_unique_value_str := p_ext_attr_tbl(i).attr_value_str;
              --dynamically build a cusrsor and get value from the database;
              --assisgn the value to the record structure

               l_sql := l_sql||g_newline;
			l_sql := l_sql||g_newline ||' AND '||l_database_column_name||' = :p_col7';
			p_col_7 := l_unique_value_str;
			p_use_col7_flag := 'Y';

--             l_sql := l_sql||' and '||l_database_column_name||' = '||l_unique_value_str;

            ELSIF p_ext_attr_tbl(i).attr_value_num IS NOT NULL Then
              l_unique_value_num := p_ext_attr_tbl(i).attr_value_num;
              --dynamically build a cusrsor and get value from the database;
              --assisgn the value to the record structure

              --DBMS_OUTPUT.PUT_LINE('attr_value_num is not null');
              --DBMS_OUTPUT.PUT_LINE('l_database_column_name'||l_database_column_name);
              --DBMS_OUTPUT.PUT_LINE('l_unique_value_num'||l_unique_value_num);

              l_sql := l_sql||g_newline;
		    l_sql := l_sql||' AND '||l_database_column_name||' = '||' = :p_col7';
              p_col_7 := l_unique_value_num;
              p_use_col7_flag := 'Y';

--              l_sql := l_sql||' and '||l_database_column_name||' = '||l_unique_value_num;

            ELSIF p_ext_attr_tbl(i).attr_value_date IS NOT NULL Then
              l_unique_value_date := p_ext_attr_tbl(i).attr_value_date;

		     l_sql := l_sql||g_newline;
               l_sql := l_sql||' AND '||l_database_column_name||' = '||' = :p_col7';
               p_col_7 := l_unique_value_date;
               p_use_col7_flag := 'Y';

--              l_sql := l_sql||' and '||l_database_column_name||' = '||l_unique_value_date;
            ELSE
              IF p_ext_attr_tbl(i).attr_unit_of_measure IS NOT NULL then
                l_unique_value_uom := p_ext_attr_tbl(i).attr_unit_of_measure;

                l_sql := l_sql||g_newline;
		 	 l_sql := l_sql||' AND '||l_database_column_name||' = '||' = :p_col7';
		 	 p_col_7 := l_unique_value_uom;
			 p_use_col7_flag := 'Y';

--                l_sql := l_sql||' and '||l_database_column_name||' = '||l_unique_value_uom;
              END IF;
            END IF;
            EXIT;
          END IF; -- end if of row_identifier, l_attribute_name, l_database_name not null
        END LOOP;-- end of loop

        BEGIN

	     IF p_use_col7_flag ='Y' THEN
		   EXECUTE IMMEDIATE l_sql INTO l_cs_sr_contacts_ext_rec
		           USING p_col_1, p_col_2, p_col_3, p_col_4, p_col_5, p_col_6,p_col_7;
		ELSE
             EXECUTE IMMEDIATE l_sql INTO l_cs_sr_contacts_ext_rec
		           USING p_col_1, p_col_2, p_col_3, p_col_4, p_col_5, p_col_6;
		END IF;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_rec_found := 'N';
        END;

        --Check l_cs_sr_contacts_ext_rec if record exists
        --DBMS_OUTPUT.PUT_LINE('populated the sql');
        --DBMS_OUTPUT.PUT_LINE('Extension_Id '||l_cs_sr_contacts_ext_rec.extension_id);

        IF l_cs_sr_contacts_ext_rec.extension_id IS NOT NULL THEN
          -- Record exists
          x_rec_found := 'Y';
          -- pass the value from the cursor variable to the audit table
          -- pass the value from the cursor variable to the l_old_Ext_Attr_Audit_Rec table
          --DBMS_OUTPUT.PUT_LINE('Record Exists');

          -- loop through the audit table passed in and see if you can find the record
          -- this is for a 'CREATE' situation

          --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.COUNT);

          IF p_sr_audit_rec_table.COUNT > 0 THEN

            --DBMS_OUTPUT.PUT_LINE('In loooop');
            FOR i IN 1.. p_sr_audit_rec_table.COUNT LOOP
              IF p_sr_audit_rec_table(i).pk_column_1 = p_incident_id AND
                 p_sr_audit_rec_table(i).pk_column_2 = p_party_id AND
                 p_sr_audit_rec_table(i).pk_column_3 = p_contact_type AND
                 p_sr_audit_rec_table(i).pk_column_4 = p_party_role_code AND
                 p_sr_audit_rec_table(i).context = p_context AND
                 p_sr_audit_rec_table(i).attr_group_id = p_attr_group_id AND
                 p_sr_audit_rec_table(i).row_identifier = p_row_id THEN

                IF p_sr_audit_rec_table(i).extension_id IS NULL THEN
                  l_create_new_record := 'N';
                  --DBMS_OUTPUT.PUT_LINE('l_create_new_record'||l_create_new_record);
                  --DBMS_OUTPUT.PUT_LINE('Match found for audit record');

                  p_sr_audit_rec_table(i).extension_id      := l_cs_sr_contacts_ext_rec.extension_id;
                  p_sr_audit_rec_table(i).pk_column_1       := p_incident_id;
                  p_sr_audit_rec_table(i).pk_column_2       := p_party_id;
                  p_sr_audit_rec_table(i).pk_column_3       := p_contact_type;
                  p_sr_audit_rec_table(i).pk_column_4       := p_party_role_code;
                  p_sr_audit_rec_table(i).pk_column_5       := null;
                  p_sr_audit_rec_table(i).CONTEXT           := p_context;
                  p_sr_audit_rec_table(i).ATTR_GROUP_ID     := p_attr_group_id;
                  p_sr_audit_rec_table(i).C_EXT_ATTR1       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR1;
                  p_sr_audit_rec_table(i).C_EXT_ATTR2       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR2;
                  p_sr_audit_rec_table(i).C_EXT_ATTR3       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR3;
                  p_sr_audit_rec_table(i).C_EXT_ATTR4       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR4;
                  p_sr_audit_rec_table(i).C_EXT_ATTR5       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR5;
                  p_sr_audit_rec_table(i).C_EXT_ATTR6       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR6;
                  p_sr_audit_rec_table(i).C_EXT_ATTR7       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR7;
                  p_sr_audit_rec_table(i).C_EXT_ATTR8       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR8;
                  p_sr_audit_rec_table(i).C_EXT_ATTR9       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR9;
                  p_sr_audit_rec_table(i).C_EXT_ATTR10      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR10;
                  p_sr_audit_rec_table(i).C_EXT_ATTR11      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR11;
                  p_sr_audit_rec_table(i).C_EXT_ATTR12      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR12;
                  p_sr_audit_rec_table(i).C_EXT_ATTR13      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR13;
                  p_sr_audit_rec_table(i).C_EXT_ATTR14      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR14;
                  p_sr_audit_rec_table(i).C_EXT_ATTR15      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR15;
                  p_sr_audit_rec_table(i).C_EXT_ATTR16      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR16;
                  p_sr_audit_rec_table(i).C_EXT_ATTR17      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR17;
                  p_sr_audit_rec_table(i).C_EXT_ATTR18      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR18;
                  p_sr_audit_rec_table(i).C_EXT_ATTR19      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR19;                           p_sr_audit_rec_table(i).C_EXT_ATTR20      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR20;
                  p_sr_audit_rec_table(i).C_EXT_ATTR21      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR21;
                  p_sr_audit_rec_table(i).C_EXT_ATTR22      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR22;
                  p_sr_audit_rec_table(i).C_EXT_ATTR23      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR23;
                  p_sr_audit_rec_table(i).C_EXT_ATTR24      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR24;
                  p_sr_audit_rec_table(i).C_EXT_ATTR25      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR25;
                  p_sr_audit_rec_table(i).C_EXT_ATTR26      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR26;
                  p_sr_audit_rec_table(i).C_EXT_ATTR27      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR27;
                  p_sr_audit_rec_table(i).C_EXT_ATTR28      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR28;
                  p_sr_audit_rec_table(i).C_EXT_ATTR29      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR29;
                  p_sr_audit_rec_table(i).C_EXT_ATTR30      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR30;
                  p_sr_audit_rec_table(i).C_EXT_ATTR31      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR31;
                  p_sr_audit_rec_table(i).C_EXT_ATTR32      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR32;
                  p_sr_audit_rec_table(i).C_EXT_ATTR33      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR33;
                  p_sr_audit_rec_table(i).C_EXT_ATTR34      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR34;
                  p_sr_audit_rec_table(i).C_EXT_ATTR35      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR35;
                  p_sr_audit_rec_table(i).C_EXT_ATTR36      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR36;
                  p_sr_audit_rec_table(i).C_EXT_ATTR37      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR37;
                  p_sr_audit_rec_table(i).C_EXT_ATTR38      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR38;
                  p_sr_audit_rec_table(i).C_EXT_ATTR39      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR38;
                  p_sr_audit_rec_table(i).C_EXT_ATTR40      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR40;
                  p_sr_audit_rec_table(i).C_EXT_ATTR41      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR41;
                  p_sr_audit_rec_table(i).C_EXT_ATTR42      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR42;
                  p_sr_audit_rec_table(i).C_EXT_ATTR43      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR43;
                  p_sr_audit_rec_table(i).C_EXT_ATTR44      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR44;
                  p_sr_audit_rec_table(i).C_EXT_ATTR45      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR45;
                  p_sr_audit_rec_table(i).C_EXT_ATTR46      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR46;
                  p_sr_audit_rec_table(i).C_EXT_ATTR47      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR47;
                  p_sr_audit_rec_table(i).C_EXT_ATTR48      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR48;
                  p_sr_audit_rec_table(i).C_EXT_ATTR49      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR49;
                  p_sr_audit_rec_table(i).C_EXT_ATTR50      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR50;
                  p_sr_audit_rec_table(i).N_EXT_ATTR1       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR1;
                  p_sr_audit_rec_table(i).N_EXT_ATTR2       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR2;
                  p_sr_audit_rec_table(i).N_EXT_ATTR3       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR3;
                  p_sr_audit_rec_table(i).N_EXT_ATTR4       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR4;
                  p_sr_audit_rec_table(i).N_EXT_ATTR5       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR5;
                  p_sr_audit_rec_table(i).N_EXT_ATTR6       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR6;
                  p_sr_audit_rec_table(i).N_EXT_ATTR7       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR7;
                  p_sr_audit_rec_table(i).N_EXT_ATTR8       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR8;
                  p_sr_audit_rec_table(i).N_EXT_ATTR9       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR9;
                  p_sr_audit_rec_table(i).N_EXT_ATTR10      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR10;
                  p_sr_audit_rec_table(i).N_EXT_ATTR11      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR11;
                  p_sr_audit_rec_table(i).N_EXT_ATTR12      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR12;
                  p_sr_audit_rec_table(i).N_EXT_ATTR13      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR13;
                  p_sr_audit_rec_table(i).N_EXT_ATTR14      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR14;
                  p_sr_audit_rec_table(i).N_EXT_ATTR15      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR15;
                           p_sr_audit_rec_table(i).N_EXT_ATTR16      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR16;
                           p_sr_audit_rec_table(i).N_EXT_ATTR17      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR17;
                           p_sr_audit_rec_table(i).N_EXT_ATTR18      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR18;
                           p_sr_audit_rec_table(i).N_EXT_ATTR19      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR19;
                           p_sr_audit_rec_table(i).N_EXT_ATTR20      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR20;
                           p_sr_audit_rec_table(i).N_EXT_ATTR21      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR21;
                           p_sr_audit_rec_table(i).N_EXT_ATTR22      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR22;
                           p_sr_audit_rec_table(i).N_EXT_ATTR23      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR23;
                           p_sr_audit_rec_table(i).N_EXT_ATTR24      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR24;
                           p_sr_audit_rec_table(i).N_EXT_ATTR25      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR25;
                           p_sr_audit_rec_table(i).D_EXT_ATTR1       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR1;
                           p_sr_audit_rec_table(i).D_EXT_ATTR2       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR2;
                           p_sr_audit_rec_table(i).D_EXT_ATTR3       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR3;
                           p_sr_audit_rec_table(i).D_EXT_ATTR4       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR4;
                           p_sr_audit_rec_table(i).D_EXT_ATTR5       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR5;
                           p_sr_audit_rec_table(i).D_EXT_ATTR6       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR6;
                           p_sr_audit_rec_table(i).D_EXT_ATTR7       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR7;
                           p_sr_audit_rec_table(i).D_EXT_ATTR8       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR8;
                           p_sr_audit_rec_table(i).D_EXT_ATTR9       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR9;
                           p_sr_audit_rec_table(i).D_EXT_ATTR10      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR10;
                           p_sr_audit_rec_table(i).D_EXT_ATTR11      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR11;
                           p_sr_audit_rec_table(i).D_EXT_ATTR12      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR12;
                           p_sr_audit_rec_table(i).D_EXT_ATTR13      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR13;
                           p_sr_audit_rec_table(i).D_EXT_ATTR14      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR14;
                           p_sr_audit_rec_table(i).D_EXT_ATTR15      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR15;
                           p_sr_audit_rec_table(i).D_EXT_ATTR16      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR16;
                           p_sr_audit_rec_table(i).D_EXT_ATTR17      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR17;
                           p_sr_audit_rec_table(i).D_EXT_ATTR18      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR18;
                           p_sr_audit_rec_table(i).D_EXT_ATTR19      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR19;
                           p_sr_audit_rec_table(i).D_EXT_ATTR20      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR20;
                           p_sr_audit_rec_table(i).D_EXT_ATTR21      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR21;
                           p_sr_audit_rec_table(i).D_EXT_ATTR22      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR22;
                           p_sr_audit_rec_table(i).D_EXT_ATTR23      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR23;
                           p_sr_audit_rec_table(i).D_EXT_ATTR24      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR24;
                           p_sr_audit_rec_table(i).D_EXT_ATTR25      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR25;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR1     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR1;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR2     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR2;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR3     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR3;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR4     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR4;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR5     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR5;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR6     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR6;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR7     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR7;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR8     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR8;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR9     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR9;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR10    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR10;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR11    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR11;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR12    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR12;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR13    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR13;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR14    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR14;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR15    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR15;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR16    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR16;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR17    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR17;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR18    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR18;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR19    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR19;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR20    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR20;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR21    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR21;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR22    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR22;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR23    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR23;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR24    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR24;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR25    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR25;

                           -- need to exit;
                           EXIT;

                          END IF;

                ELSE
                   l_create_new_record := 'Y';
                END IF;
              END LOOP;

              --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.count);
            ELSE
              l_audit_table_empty := 'Y';
            END IF;





            --DBMS_OUTPUT.PUT_LINE('l_create_new_rec'||l_create_new_record);
            --DBMS_OUTPUT.PUT_LINE('l_audit_table_empty'||l_audit_table_empty);

              IF l_create_new_record = 'Y'  OR
                 l_audit_table_empty = 'Y' THEN


                  l_count := l_count + 1;
                    p_sr_audit_rec_table (l_count).extension_id      := l_cs_sr_contacts_ext_rec.extension_id;
                    p_sr_audit_rec_table (l_count).pk_column_1       := l_cs_sr_contacts_ext_rec.incident_id;
                    p_sr_audit_rec_table (l_count).pk_column_2       := l_cs_sr_contacts_ext_rec.party_id;
                    p_sr_audit_rec_table (l_count).pk_column_3       := l_cs_sr_contacts_ext_rec.contact_type;
                    p_sr_audit_rec_table (l_count).pk_column_4       := l_cs_sr_contacts_ext_rec.party_role_code;
                    p_sr_audit_rec_table (l_count).CONTEXT           := l_cs_sr_contacts_ext_rec.context;
                    p_sr_audit_rec_table (l_count).ATTR_GROUP_ID     := l_cs_sr_contacts_ext_rec.attr_group_id;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR1       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR2       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR3       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR4       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR5       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR6       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR7       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR8       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR9       := l_cs_sr_contacts_ext_rec.C_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR10      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR11      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR12      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR13      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR14      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR15      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR16      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR17      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR18      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR19      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR20      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR21      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR22      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR23      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR24      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR25      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR25;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR26      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR26;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR27      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR27;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR28      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR28;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR29      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR29;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR30      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR30;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR31      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR31;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR32      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR32;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR33      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR33;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR34      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR34;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR35      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR35;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR36      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR36;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR37      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR37;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR38      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR38;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR39      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR38;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR40      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR40;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR41      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR41;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR42      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR42;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR43      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR43;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR44      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR44;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR45      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR45;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR46      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR46;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR47      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR47;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR48      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR48;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR49      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR49;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR50      := l_cs_sr_contacts_ext_rec.C_EXT_ATTR50;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR1       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR2       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR3       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR4       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR5       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR6       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR7       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR8       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR9       := l_cs_sr_contacts_ext_rec.N_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR10      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR11      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR12      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR13      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR14      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR15      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR16      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR17      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR18      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR19      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR20      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR21      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR22      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR23      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR24      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR25      := l_cs_sr_contacts_ext_rec.N_EXT_ATTR25;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR1       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR2       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR3       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR4       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR5       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR6       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR7       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR8       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR9       := l_cs_sr_contacts_ext_rec.D_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR10      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR11      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR12      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR13      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR14      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR15      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR16      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR17      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR18      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR19      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR20      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR21      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR22      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR23      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR24      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR25      := l_cs_sr_contacts_ext_rec.D_EXT_ATTR25;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR1     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR2     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR3     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR4     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR5     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR6     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR7     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR8     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR9     := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR10    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR11    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR12    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR13    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR14    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR15    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR16    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR17    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR18    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR19    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR20    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR21    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR22    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR23    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR24    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR25    := l_cs_sr_contacts_ext_rec.UOM_EXT_ATTR25;

                  END IF;
                ELSE
                    -- Record does not exists
                    x_rec_found := 'N';
                    RETURN;
                    --DBMS_OUTPUT.PUT_LINE('Record does not exist');
                END IF;

            END IF; -- end of if attribute name is not null
          END IF; -- end of if app id, attr_group_type, attr_group_name is not null


      ELSE
        -- l_multi_row_code = 'N'
        -- get the current record in the database for the unique key combination

          --DBMS_OUTPUT.PUT_LINE('not multi-row');

          OPEN c_get_ext_attr_db_rec;
          FETCH c_get_ext_attr_db_rec INTO v_get_ext_attr_db_rec;
          IF c_get_ext_attr_db_rec%NOTFOUND THEN
            -- Record does not exists
            x_rec_found := 'N';

          ELSE
            -- Record exists
            x_rec_found := 'Y';

            -- loop through the audit table passed in and see if you can find the record
            -- this is for a 'CREATE' situation

            --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.COUNT);

            IF p_sr_audit_rec_table.COUNT > 0 THEN

              --DBMS_OUTPUT.PUT_LINE('In loooop');

              FOR i IN 1.. p_sr_audit_rec_table.COUNT LOOP
                IF p_sr_audit_rec_table(i).pk_column_1 = p_incident_id AND
                   p_sr_audit_rec_table(i).pk_column_2 = p_party_id AND
                   p_sr_audit_rec_table(i).pk_column_3 = p_contact_type AND
                   p_sr_audit_rec_table(i).pk_column_4 = p_party_role_code AND
                   p_sr_audit_rec_table(i).context = p_context AND
                   p_sr_audit_rec_table(i).attr_group_id = p_attr_group_id AND
                   p_sr_audit_rec_table(i).row_identifier = p_row_id THEN

                   l_create_new_record := 'N';

                   --DBMS_OUTPUT.PUT_LINE('Match found for audit record');
                   --DBMS_OUTPUT.PUT_LINE('l_create_new_record'||l_create_new_record);

                   p_sr_audit_rec_table(i).extension_id      := v_get_ext_attr_db_rec.extension_id;
                   p_sr_audit_rec_table(i).pk_column_1       := p_incident_id;
                   p_sr_audit_rec_table(i).pk_column_2       := p_party_id;
                   p_sr_audit_rec_table(i).pk_column_3       := p_contact_type;
                   p_sr_audit_rec_table(i).pk_column_4       := p_party_role_code;
                   p_sr_audit_rec_table(i).pk_column_5       := null;
                   p_sr_audit_rec_table(i).CONTEXT           := p_context;
                   p_sr_audit_rec_table(i).ATTR_GROUP_ID     := p_attr_group_id;
                   p_sr_audit_rec_table(i).C_EXT_ATTR1       := v_get_ext_attr_db_rec.C_EXT_ATTR1;
                   p_sr_audit_rec_table(i).C_EXT_ATTR2       := v_get_ext_attr_db_rec.C_EXT_ATTR2;
                   p_sr_audit_rec_table(i).C_EXT_ATTR3       := v_get_ext_attr_db_rec.C_EXT_ATTR3;
                   p_sr_audit_rec_table(i).C_EXT_ATTR4       := v_get_ext_attr_db_rec.C_EXT_ATTR4;
                   p_sr_audit_rec_table(i).C_EXT_ATTR5       := v_get_ext_attr_db_rec.C_EXT_ATTR5;
                   p_sr_audit_rec_table(i).C_EXT_ATTR6       := v_get_ext_attr_db_rec.C_EXT_ATTR6;
                   p_sr_audit_rec_table(i).C_EXT_ATTR7       := v_get_ext_attr_db_rec.C_EXT_ATTR7;
                   p_sr_audit_rec_table(i).C_EXT_ATTR8       := v_get_ext_attr_db_rec.C_EXT_ATTR8;
                   p_sr_audit_rec_table(i).C_EXT_ATTR9       := v_get_ext_attr_db_rec.C_EXT_ATTR9;
                   p_sr_audit_rec_table(i).C_EXT_ATTR10      := v_get_ext_attr_db_rec.C_EXT_ATTR10;
                   p_sr_audit_rec_table(i).C_EXT_ATTR11      := v_get_ext_attr_db_rec.C_EXT_ATTR11;
                   p_sr_audit_rec_table(i).C_EXT_ATTR12      := v_get_ext_attr_db_rec.C_EXT_ATTR12;
                   p_sr_audit_rec_table(i).C_EXT_ATTR13      := v_get_ext_attr_db_rec.C_EXT_ATTR13;
                   p_sr_audit_rec_table(i).C_EXT_ATTR14      := v_get_ext_attr_db_rec.C_EXT_ATTR14;
                   p_sr_audit_rec_table(i).C_EXT_ATTR15      := v_get_ext_attr_db_rec.C_EXT_ATTR15;
                   p_sr_audit_rec_table(i).C_EXT_ATTR16      := v_get_ext_attr_db_rec.C_EXT_ATTR16;
                   p_sr_audit_rec_table(i).C_EXT_ATTR17      := v_get_ext_attr_db_rec.C_EXT_ATTR17;
                   p_sr_audit_rec_table(i).C_EXT_ATTR18      := v_get_ext_attr_db_rec.C_EXT_ATTR18;
                   p_sr_audit_rec_table(i).C_EXT_ATTR19      := v_get_ext_attr_db_rec.C_EXT_ATTR19;
                   p_sr_audit_rec_table(i).C_EXT_ATTR20      := v_get_ext_attr_db_rec.C_EXT_ATTR20;
                   p_sr_audit_rec_table(i).C_EXT_ATTR21      := v_get_ext_attr_db_rec.C_EXT_ATTR21;
                   p_sr_audit_rec_table(i).C_EXT_ATTR22      := v_get_ext_attr_db_rec.C_EXT_ATTR22;
                   p_sr_audit_rec_table(i).C_EXT_ATTR23      := v_get_ext_attr_db_rec.C_EXT_ATTR23;
                   p_sr_audit_rec_table(i).C_EXT_ATTR24      := v_get_ext_attr_db_rec.C_EXT_ATTR24;
                   p_sr_audit_rec_table(i).C_EXT_ATTR25      := v_get_ext_attr_db_rec.C_EXT_ATTR25;
                   p_sr_audit_rec_table(i).C_EXT_ATTR26      := v_get_ext_attr_db_rec.C_EXT_ATTR26;
                   p_sr_audit_rec_table(i).C_EXT_ATTR27      := v_get_ext_attr_db_rec.C_EXT_ATTR27;
                   p_sr_audit_rec_table(i).C_EXT_ATTR28      := v_get_ext_attr_db_rec.C_EXT_ATTR28;
                   p_sr_audit_rec_table(i).C_EXT_ATTR29      := v_get_ext_attr_db_rec.C_EXT_ATTR29;
                   p_sr_audit_rec_table(i).C_EXT_ATTR30      := v_get_ext_attr_db_rec.C_EXT_ATTR30;
                   p_sr_audit_rec_table(i).C_EXT_ATTR31      := v_get_ext_attr_db_rec.C_EXT_ATTR31;
                   p_sr_audit_rec_table(i).C_EXT_ATTR32      := v_get_ext_attr_db_rec.C_EXT_ATTR32;
                   p_sr_audit_rec_table(i).C_EXT_ATTR33      := v_get_ext_attr_db_rec.C_EXT_ATTR33;
                   p_sr_audit_rec_table(i).C_EXT_ATTR34      := v_get_ext_attr_db_rec.C_EXT_ATTR34;
                   p_sr_audit_rec_table(i).C_EXT_ATTR35      := v_get_ext_attr_db_rec.C_EXT_ATTR35;
                   p_sr_audit_rec_table(i).C_EXT_ATTR36      := v_get_ext_attr_db_rec.C_EXT_ATTR36;
                   p_sr_audit_rec_table(i).C_EXT_ATTR37      := v_get_ext_attr_db_rec.C_EXT_ATTR37;
                   p_sr_audit_rec_table(i).C_EXT_ATTR38      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
                   p_sr_audit_rec_table(i).C_EXT_ATTR39      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
                   p_sr_audit_rec_table(i).C_EXT_ATTR40      := v_get_ext_attr_db_rec.C_EXT_ATTR40;
                   p_sr_audit_rec_table(i).C_EXT_ATTR41      := v_get_ext_attr_db_rec.C_EXT_ATTR41;
                   p_sr_audit_rec_table(i).C_EXT_ATTR42      := v_get_ext_attr_db_rec.C_EXT_ATTR42;
                   p_sr_audit_rec_table(i).C_EXT_ATTR43      := v_get_ext_attr_db_rec.C_EXT_ATTR43;
                   p_sr_audit_rec_table(i).C_EXT_ATTR44      := v_get_ext_attr_db_rec.C_EXT_ATTR44;
                   p_sr_audit_rec_table(i).C_EXT_ATTR45      := v_get_ext_attr_db_rec.C_EXT_ATTR45;
                   p_sr_audit_rec_table(i).C_EXT_ATTR46      := v_get_ext_attr_db_rec.C_EXT_ATTR46;
                   p_sr_audit_rec_table(i).C_EXT_ATTR47      := v_get_ext_attr_db_rec.C_EXT_ATTR47;
                   p_sr_audit_rec_table(i).C_EXT_ATTR48      := v_get_ext_attr_db_rec.C_EXT_ATTR48;
                   p_sr_audit_rec_table(i).C_EXT_ATTR49      := v_get_ext_attr_db_rec.C_EXT_ATTR49;
                   p_sr_audit_rec_table(i).C_EXT_ATTR50      := v_get_ext_attr_db_rec.C_EXT_ATTR50;
                   p_sr_audit_rec_table(i).N_EXT_ATTR1       := v_get_ext_attr_db_rec.N_EXT_ATTR1;
                   p_sr_audit_rec_table(i).N_EXT_ATTR2       := v_get_ext_attr_db_rec.N_EXT_ATTR2;
                   p_sr_audit_rec_table(i).N_EXT_ATTR3       := v_get_ext_attr_db_rec.N_EXT_ATTR3;
                   p_sr_audit_rec_table(i).N_EXT_ATTR4       := v_get_ext_attr_db_rec.N_EXT_ATTR4;
                   p_sr_audit_rec_table(i).N_EXT_ATTR5       := v_get_ext_attr_db_rec.N_EXT_ATTR5;
                   p_sr_audit_rec_table(i).N_EXT_ATTR6       := v_get_ext_attr_db_rec.N_EXT_ATTR6;
                   p_sr_audit_rec_table(i).N_EXT_ATTR7       := v_get_ext_attr_db_rec.N_EXT_ATTR7;
                   p_sr_audit_rec_table(i).N_EXT_ATTR8       := v_get_ext_attr_db_rec.N_EXT_ATTR8;
                   p_sr_audit_rec_table(i).N_EXT_ATTR9       := v_get_ext_attr_db_rec.N_EXT_ATTR9;
                   p_sr_audit_rec_table(i).N_EXT_ATTR10      := v_get_ext_attr_db_rec.N_EXT_ATTR10;
                   p_sr_audit_rec_table(i).N_EXT_ATTR11      := v_get_ext_attr_db_rec.N_EXT_ATTR11;
                   p_sr_audit_rec_table(i).N_EXT_ATTR12      := v_get_ext_attr_db_rec.N_EXT_ATTR12;
                   p_sr_audit_rec_table(i).N_EXT_ATTR13      := v_get_ext_attr_db_rec.N_EXT_ATTR13;
                   p_sr_audit_rec_table(i).N_EXT_ATTR14      := v_get_ext_attr_db_rec.N_EXT_ATTR14;
                   p_sr_audit_rec_table(i).N_EXT_ATTR15      := v_get_ext_attr_db_rec.N_EXT_ATTR15;
                   p_sr_audit_rec_table(i).N_EXT_ATTR16      := v_get_ext_attr_db_rec.N_EXT_ATTR16;
                   p_sr_audit_rec_table(i).N_EXT_ATTR17      := v_get_ext_attr_db_rec.N_EXT_ATTR17;
                   p_sr_audit_rec_table(i).N_EXT_ATTR18      := v_get_ext_attr_db_rec.N_EXT_ATTR18;
                   p_sr_audit_rec_table(i).N_EXT_ATTR19      := v_get_ext_attr_db_rec.N_EXT_ATTR19;
                   p_sr_audit_rec_table(i).N_EXT_ATTR20      := v_get_ext_attr_db_rec.N_EXT_ATTR20;
                   p_sr_audit_rec_table(i).N_EXT_ATTR21      := v_get_ext_attr_db_rec.N_EXT_ATTR21;
                   p_sr_audit_rec_table(i).N_EXT_ATTR22      := v_get_ext_attr_db_rec.N_EXT_ATTR22;
                   p_sr_audit_rec_table(i).N_EXT_ATTR23      := v_get_ext_attr_db_rec.N_EXT_ATTR23;
                   p_sr_audit_rec_table(i).N_EXT_ATTR24      := v_get_ext_attr_db_rec.N_EXT_ATTR24;
                   p_sr_audit_rec_table(i).N_EXT_ATTR25      := v_get_ext_attr_db_rec.N_EXT_ATTR25;
                   p_sr_audit_rec_table(i).D_EXT_ATTR1       := v_get_ext_attr_db_rec.D_EXT_ATTR1;
                   p_sr_audit_rec_table(i).D_EXT_ATTR2       := v_get_ext_attr_db_rec.D_EXT_ATTR2;
                   p_sr_audit_rec_table(i).D_EXT_ATTR3       := v_get_ext_attr_db_rec.D_EXT_ATTR3;
                   p_sr_audit_rec_table(i).D_EXT_ATTR4       := v_get_ext_attr_db_rec.D_EXT_ATTR4;
                   p_sr_audit_rec_table(i).D_EXT_ATTR5       := v_get_ext_attr_db_rec.D_EXT_ATTR5;
                   p_sr_audit_rec_table(i).D_EXT_ATTR6       := v_get_ext_attr_db_rec.D_EXT_ATTR6;
                   p_sr_audit_rec_table(i).D_EXT_ATTR7       := v_get_ext_attr_db_rec.D_EXT_ATTR7;
                   p_sr_audit_rec_table(i).D_EXT_ATTR8       := v_get_ext_attr_db_rec.D_EXT_ATTR8;
                   p_sr_audit_rec_table(i).D_EXT_ATTR9       := v_get_ext_attr_db_rec.D_EXT_ATTR9;
                   p_sr_audit_rec_table(i).D_EXT_ATTR10      := v_get_ext_attr_db_rec.D_EXT_ATTR10;
                   p_sr_audit_rec_table(i).D_EXT_ATTR11      := v_get_ext_attr_db_rec.D_EXT_ATTR11;
                   p_sr_audit_rec_table(i).D_EXT_ATTR12      := v_get_ext_attr_db_rec.D_EXT_ATTR12;
                   p_sr_audit_rec_table(i).D_EXT_ATTR13      := v_get_ext_attr_db_rec.D_EXT_ATTR13;
                   p_sr_audit_rec_table(i).D_EXT_ATTR14      := v_get_ext_attr_db_rec.D_EXT_ATTR14;
                   p_sr_audit_rec_table(i).D_EXT_ATTR15      := v_get_ext_attr_db_rec.D_EXT_ATTR15;
                   p_sr_audit_rec_table(i).D_EXT_ATTR16      := v_get_ext_attr_db_rec.D_EXT_ATTR16;
                   p_sr_audit_rec_table(i).D_EXT_ATTR17      := v_get_ext_attr_db_rec.D_EXT_ATTR17;
                   p_sr_audit_rec_table(i).D_EXT_ATTR18      := v_get_ext_attr_db_rec.D_EXT_ATTR18;
                   p_sr_audit_rec_table(i).D_EXT_ATTR19      := v_get_ext_attr_db_rec.D_EXT_ATTR19;
                   p_sr_audit_rec_table(i).D_EXT_ATTR20      := v_get_ext_attr_db_rec.D_EXT_ATTR20;
                   p_sr_audit_rec_table(i).D_EXT_ATTR21      := v_get_ext_attr_db_rec.D_EXT_ATTR21;
                   p_sr_audit_rec_table(i).D_EXT_ATTR22      := v_get_ext_attr_db_rec.D_EXT_ATTR22;
                   p_sr_audit_rec_table(i).D_EXT_ATTR23      := v_get_ext_attr_db_rec.D_EXT_ATTR23;
                   p_sr_audit_rec_table(i).D_EXT_ATTR24      := v_get_ext_attr_db_rec.D_EXT_ATTR24;
                   p_sr_audit_rec_table(i).D_EXT_ATTR25      := v_get_ext_attr_db_rec.D_EXT_ATTR25;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR1     := v_get_ext_attr_db_rec.UOM_EXT_ATTR1;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR2     := v_get_ext_attr_db_rec.UOM_EXT_ATTR2;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR3     := v_get_ext_attr_db_rec.UOM_EXT_ATTR3;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR4     := v_get_ext_attr_db_rec.UOM_EXT_ATTR4;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR5     := v_get_ext_attr_db_rec.UOM_EXT_ATTR5;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR6     := v_get_ext_attr_db_rec.UOM_EXT_ATTR6;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR7     := v_get_ext_attr_db_rec.UOM_EXT_ATTR7;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR8     := v_get_ext_attr_db_rec.UOM_EXT_ATTR8;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR9     := v_get_ext_attr_db_rec.UOM_EXT_ATTR9;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR10    := v_get_ext_attr_db_rec.UOM_EXT_ATTR10;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR11    := v_get_ext_attr_db_rec.UOM_EXT_ATTR11;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR12    := v_get_ext_attr_db_rec.UOM_EXT_ATTR12;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR13    := v_get_ext_attr_db_rec.UOM_EXT_ATTR13;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR14    := v_get_ext_attr_db_rec.UOM_EXT_ATTR14;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR15    := v_get_ext_attr_db_rec.UOM_EXT_ATTR15;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR16    := v_get_ext_attr_db_rec.UOM_EXT_ATTR16;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR17    := v_get_ext_attr_db_rec.UOM_EXT_ATTR17;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR18    := v_get_ext_attr_db_rec.UOM_EXT_ATTR18;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR19    := v_get_ext_attr_db_rec.UOM_EXT_ATTR19;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR20    := v_get_ext_attr_db_rec.UOM_EXT_ATTR20;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR21    := v_get_ext_attr_db_rec.UOM_EXT_ATTR21;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR22    := v_get_ext_attr_db_rec.UOM_EXT_ATTR22;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR23    := v_get_ext_attr_db_rec.UOM_EXT_ATTR23;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR24    := v_get_ext_attr_db_rec.UOM_EXT_ATTR24;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR25    := v_get_ext_attr_db_rec.UOM_EXT_ATTR25;

                ELSE
                   l_create_new_record := 'Y';
                END IF;
              END LOOP;

              --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.count);
            ELSE
              l_audit_table_empty := 'Y';
            END IF;

            --DBMS_OUTPUT.PUT_LINE('l_create_new_rec'||l_create_new_record);
            --DBMS_OUTPUT.PUT_LINE('l_audit_table_empty'||l_audit_table_empty);

            IF l_create_new_record = 'Y'  OR
               l_audit_table_empty = 'Y' THEN

            l_count := l_count + 1;

            --DBMS_OUTPUT.PUT_LINE('extension_id'||v_get_ext_attr_db_rec.extension_id);
            --DBMS_OUTPUT.PUT_LINE('pk_column_1'||v_get_ext_attr_db_rec.incident_id);
            --DBMS_OUTPUT.PUT_LINE('CONTEXT'||v_get_ext_attr_db_rec.context);
            --DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_ID'||v_get_ext_attr_db_rec.attr_group_id);
            --DBMS_OUTPUT.PUT_LINE('C_EXT_ATTR1'||v_get_ext_attr_db_rec.C_EXT_ATTR1);

            p_sr_audit_rec_table(l_count).extension_id      := v_get_ext_attr_db_rec.extension_id;
            p_sr_audit_rec_table(l_count).pk_column_1       := v_get_ext_attr_db_rec.incident_id;
            p_sr_audit_rec_table(l_count).pk_column_2       := v_get_ext_attr_db_rec.party_id;
            p_sr_audit_rec_table(l_count).pk_column_3       := v_get_ext_attr_db_rec.contact_type;
            p_sr_audit_rec_table(l_count).pk_column_4       := v_get_ext_attr_db_rec.party_role_code;
            p_sr_audit_rec_table(l_count).pk_column_5       := null;
            p_sr_audit_rec_table(l_count).CONTEXT           := v_get_ext_attr_db_rec.context;
            p_sr_audit_rec_table(l_count).ATTR_GROUP_ID     := v_get_ext_attr_db_rec.attr_group_id;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR1       := v_get_ext_attr_db_rec.C_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR2       := v_get_ext_attr_db_rec.C_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR3       := v_get_ext_attr_db_rec.C_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR4       := v_get_ext_attr_db_rec.C_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR5       := v_get_ext_attr_db_rec.C_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR6       := v_get_ext_attr_db_rec.C_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR7       := v_get_ext_attr_db_rec.C_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR8       := v_get_ext_attr_db_rec.C_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR9       := v_get_ext_attr_db_rec.C_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR10      := v_get_ext_attr_db_rec.C_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR11      := v_get_ext_attr_db_rec.C_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR12      := v_get_ext_attr_db_rec.C_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR13      := v_get_ext_attr_db_rec.C_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR14      := v_get_ext_attr_db_rec.C_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR15      := v_get_ext_attr_db_rec.C_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR16      := v_get_ext_attr_db_rec.C_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR17      := v_get_ext_attr_db_rec.C_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR18      := v_get_ext_attr_db_rec.C_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR19      := v_get_ext_attr_db_rec.C_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR20      := v_get_ext_attr_db_rec.C_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR21      := v_get_ext_attr_db_rec.C_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR22      := v_get_ext_attr_db_rec.C_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR23      := v_get_ext_attr_db_rec.C_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR24      := v_get_ext_attr_db_rec.C_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR25      := v_get_ext_attr_db_rec.C_EXT_ATTR25;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR26      := v_get_ext_attr_db_rec.C_EXT_ATTR26;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR27      := v_get_ext_attr_db_rec.C_EXT_ATTR27;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR28      := v_get_ext_attr_db_rec.C_EXT_ATTR28;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR29      := v_get_ext_attr_db_rec.C_EXT_ATTR29;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR30      := v_get_ext_attr_db_rec.C_EXT_ATTR30;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR31      := v_get_ext_attr_db_rec.C_EXT_ATTR31;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR32      := v_get_ext_attr_db_rec.C_EXT_ATTR32;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR33      := v_get_ext_attr_db_rec.C_EXT_ATTR33;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR34      := v_get_ext_attr_db_rec.C_EXT_ATTR34;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR35      := v_get_ext_attr_db_rec.C_EXT_ATTR35;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR36      := v_get_ext_attr_db_rec.C_EXT_ATTR36;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR37      := v_get_ext_attr_db_rec.C_EXT_ATTR37;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR38      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR39      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR40      := v_get_ext_attr_db_rec.C_EXT_ATTR40;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR41      := v_get_ext_attr_db_rec.C_EXT_ATTR41;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR42      := v_get_ext_attr_db_rec.C_EXT_ATTR42;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR43      := v_get_ext_attr_db_rec.C_EXT_ATTR43;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR44      := v_get_ext_attr_db_rec.C_EXT_ATTR44;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR45      := v_get_ext_attr_db_rec.C_EXT_ATTR45;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR46      := v_get_ext_attr_db_rec.C_EXT_ATTR46;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR47      := v_get_ext_attr_db_rec.C_EXT_ATTR47;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR48      := v_get_ext_attr_db_rec.C_EXT_ATTR48;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR49      := v_get_ext_attr_db_rec.C_EXT_ATTR49;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR50      := v_get_ext_attr_db_rec.C_EXT_ATTR50;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR1       := v_get_ext_attr_db_rec.N_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR2       := v_get_ext_attr_db_rec.N_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR3       := v_get_ext_attr_db_rec.N_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR4       := v_get_ext_attr_db_rec.N_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR5       := v_get_ext_attr_db_rec.N_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR6       := v_get_ext_attr_db_rec.N_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR7       := v_get_ext_attr_db_rec.N_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR8       := v_get_ext_attr_db_rec.N_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR9       := v_get_ext_attr_db_rec.N_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR10      := v_get_ext_attr_db_rec.N_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR11      := v_get_ext_attr_db_rec.N_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR12      := v_get_ext_attr_db_rec.N_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR13      := v_get_ext_attr_db_rec.N_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR14      := v_get_ext_attr_db_rec.N_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR15      := v_get_ext_attr_db_rec.N_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR16      := v_get_ext_attr_db_rec.N_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR17      := v_get_ext_attr_db_rec.N_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR18      := v_get_ext_attr_db_rec.N_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR19      := v_get_ext_attr_db_rec.N_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR20      := v_get_ext_attr_db_rec.N_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR21      := v_get_ext_attr_db_rec.N_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR22      := v_get_ext_attr_db_rec.N_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR23      := v_get_ext_attr_db_rec.N_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR24      := v_get_ext_attr_db_rec.N_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR25      := v_get_ext_attr_db_rec.N_EXT_ATTR25;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR1       := v_get_ext_attr_db_rec.D_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR2       := v_get_ext_attr_db_rec.D_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR3       := v_get_ext_attr_db_rec.D_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR4       := v_get_ext_attr_db_rec.D_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR5       := v_get_ext_attr_db_rec.D_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR6       := v_get_ext_attr_db_rec.D_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR7       := v_get_ext_attr_db_rec.D_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR8       := v_get_ext_attr_db_rec.D_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR9       := v_get_ext_attr_db_rec.D_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR10      := v_get_ext_attr_db_rec.D_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR11      := v_get_ext_attr_db_rec.D_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR12      := v_get_ext_attr_db_rec.D_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR13      := v_get_ext_attr_db_rec.D_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR14      := v_get_ext_attr_db_rec.D_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR15      := v_get_ext_attr_db_rec.D_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR16      := v_get_ext_attr_db_rec.D_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR17      := v_get_ext_attr_db_rec.D_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR18      := v_get_ext_attr_db_rec.D_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR19      := v_get_ext_attr_db_rec.D_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR20      := v_get_ext_attr_db_rec.D_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR21      := v_get_ext_attr_db_rec.D_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR22      := v_get_ext_attr_db_rec.D_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR23      := v_get_ext_attr_db_rec.D_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR24      := v_get_ext_attr_db_rec.D_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR25      := v_get_ext_attr_db_rec.D_EXT_ATTR25;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR1     := v_get_ext_attr_db_rec.UOM_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR2     := v_get_ext_attr_db_rec.UOM_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR3     := v_get_ext_attr_db_rec.UOM_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR4     := v_get_ext_attr_db_rec.UOM_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR5     := v_get_ext_attr_db_rec.UOM_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR6     := v_get_ext_attr_db_rec.UOM_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR7     := v_get_ext_attr_db_rec.UOM_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR8     := v_get_ext_attr_db_rec.UOM_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR9     := v_get_ext_attr_db_rec.UOM_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR10    := v_get_ext_attr_db_rec.UOM_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR11    := v_get_ext_attr_db_rec.UOM_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR12    := v_get_ext_attr_db_rec.UOM_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR13    := v_get_ext_attr_db_rec.UOM_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR14    := v_get_ext_attr_db_rec.UOM_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR15    := v_get_ext_attr_db_rec.UOM_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR16    := v_get_ext_attr_db_rec.UOM_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR17    := v_get_ext_attr_db_rec.UOM_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR18    := v_get_ext_attr_db_rec.UOM_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR19    := v_get_ext_attr_db_rec.UOM_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR20    := v_get_ext_attr_db_rec.UOM_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR21    := v_get_ext_attr_db_rec.UOM_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR22    := v_get_ext_attr_db_rec.UOM_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR23    := v_get_ext_attr_db_rec.UOM_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR24    := v_get_ext_attr_db_rec.UOM_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR25    := v_get_ext_attr_db_rec.UOM_EXT_ATTR25;
           END IF;

          END IF;
          CLOSE c_get_ext_attr_db_rec;
          --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.count);

     END IF;
 END IF;
END populate_pr_ext_attr_audit_rec;

PROCEDURE populate_sr_ext_attr_audit_rec(
          p_incident_id        IN NUMBER
         ,p_context            IN NUMBER
         ,p_attr_group_id      IN  NUMBER
         ,p_row_id             IN NUMBER
         ,p_ext_attr_tbl       IN CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
         ,p_sr_audit_rec_table IN OUT NOCOPY Ext_Attr_Audit_Tbl_Type
         ,x_rec_found      OUT NOCOPY VARCHAR2
         ) IS


Cursor c_get_ext_attr_db_rec IS
select * from cs_incidents_ext
where incident_id = p_incident_id
  and context = p_context
  and attr_group_id  = p_attr_group_id;

Cursor c_is_multi_row IS
select multi_row_code
  from ego_attr_groups_v
 where attr_group_id = p_attr_group_id;

Cursor c_get_unique_key (p_application_id IN NUMBER,
                         p_attr_group_name IN VARCHAR2,
                         p_attr_group_type IN VARCHAR2
                         ) IS
select attr_name, database_column
  from ego_attrs_v
where attr_group_name = p_attr_group_name
  and attr_group_type = p_attr_group_type
  and application_id =  p_application_id
  and unique_key_flag = 'Y';



i NUMBER := 0;
l_old_Ext_Attr_Audit_Tbl  Ext_Attr_Audit_Tbl_Type;
l_multi_row_code VARCHAR2(1);
l_attribute_name VARCHAR2(30);
l_database_column_name VARCHAR2(30);
l_application_id NUMBER;
l_attr_group_type VARCHAR2(30);
l_attr_group_name VARCHAR2(80);
l_unique_value_str VARCHAR2(4000);
L_unique_value_num NUMBER;
l_unique_value_date DATE;
l_unique_value_uom VARCHAR2(3);

l_sql VARCHAR2(2000) := 'SELECT * FROM CS_INCIDENTS_EXT WHERE INCIDENT_ID = :P_INCIDENT_ID AND CONTEXT = :P_CONTEXT AND ATTR_GROUP_ID = :P_ATTR_GROUP_ID';
l_cs_incidents_ext_rec cs_incidents_ext%ROWTYPE;

v_get_ext_attr_db_rec c_get_ext_attr_db_rec%ROWTYPE;

l_count NUMBER := 0;

l_create_new_record VARCHAR2(1) := 'N';
l_audit_table_empty VARCHAR2(1) := 'N';
BEGIN

   --get the correct count of the records in the audit table
   --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.COUNT); --executed

   l_count := p_sr_audit_rec_table.COUNT;

   IF p_attr_group_id IS NOT NULL AND
      p_incident_id IS NOT NULL AND
      p_context IS NOT NULL THEN

      -- check if attribute group is multi_row_enabled
      OPEN c_is_multi_row;
      FETCH c_is_multi_row INTO l_multi_row_code;
      CLOSE c_is_multi_row;

      --DBMS_OUTPUT.PUT_LINE('Multi-Row flag is :'||l_multi_row_code); --executed


      IF l_multi_row_code = 'Y' then

         --DBMS_OUTPUT.PUT_LINE('In multi row logic');
         --DBMS_OUTPUT.PUT_LINE('Calling Get_Attr_Group_Metadata ');

         -- first get the attribute_group_name, attribute_group_type and application_id
         -- for this attribute_group_id
         Get_Attr_Group_Metadata (
                   p_attr_group_id                => p_attr_group_id
                  ,x_application_id               => l_application_id
                  ,x_attr_group_type              => l_attr_group_type
                  ,x_attr_group_name              => l_attr_group_name
         );

         --DBMS_OUTPUT.PUT_LINE('l_application_id'||l_application_id);
         --DBMS_OUTPUT.PUT_LINE('l_attr_group_type'||l_attr_group_type);
         --DBMS_OUTPUT.PUT_LINE('l_attr_group_name'||l_attr_group_name);

         IF l_application_id IS NOT NULL AND
            l_attr_group_type IS NOT NULL AND
            l_attr_group_name IS NOT NULL THEN

            --DBMS_OUTPUT.PUT_LINE('Getting unique key');

            --get the unique attribute maintained for this multi-row attribute group
            OPEN c_get_unique_key (l_application_id
                                  ,l_attr_group_name
                                  ,l_attr_group_type);
            FETCH c_get_unique_key into l_attribute_name, l_database_column_name;
            CLOSE c_get_unique_key;

            IF l_attribute_name IS NOT NULL THEN

               --DBMS_OUTPUT.PUT_LINE('l_attribute_name'||l_attribute_name);
               --DBMS_OUTPUT.PUT_LINE('l_database_column_name'||l_database_column_name);

               --traverse through the p_ext_attr_tbl and
               --get the value for the unique attribute group
               --this code assumes that the unique attribute is non-updateable
               FOR i IN 1..p_ext_attr_tbl.COUNT LOOP

                 IF  p_ext_attr_tbl(i).row_identifier = p_row_id AND
                     p_ext_attr_tbl(i).attr_name = l_attribute_name OR
                     p_ext_attr_tbl(i).column_name = l_database_column_name THEN

                     --match found
                     --get the unique value.  However the unique value may be a string
                     --date, character, or uom so we have to check all possible combinations.

                     --DBMS_OUTPUT.PUT_LINE('match found');

                     IF p_ext_attr_tbl(i).attr_value_str IS NOT NULL Then
                       --unique value is a string
                       l_unique_value_str := p_ext_attr_tbl(i).attr_value_str;
                       --dynamically build a cusrsor and get value from the database;
                       --assisgn the value to the record structure

                       l_sql := l_sql||'and '||l_database_column_name||' = '||l_unique_value_str;

                     ELSIF p_ext_attr_tbl(i).attr_value_num IS NOT NULL Then
                        l_unique_value_num := p_ext_attr_tbl(i).attr_value_num;
                       --dynamically build a cusrsor and get value from the database;
                       --assisgn the value to the record structure

                       --DBMS_OUTPUT.PUT_LINE('p_ext_attr_tbl(i).attr_value_num'||p_ext_attr_tbl(i).attr_value_num);

                       l_sql := l_sql||' and '||l_database_column_name||' = '||l_unique_value_num;

                       --DBMS_OUTPUT.PUT_LINE('l_sql'||l_sql);

                     ELSIF p_ext_attr_tbl(i).attr_value_date IS NOT NULL Then
                        l_unique_value_date := p_ext_attr_tbl(i).attr_value_date;

                        l_sql := l_sql||'and '||l_database_column_name||' = '||l_unique_value_date;
                     ELSE
                        IF p_ext_attr_tbl(i).attr_unit_of_measure IS NOT NULL then
                          l_unique_value_uom := p_ext_attr_tbl(i).attr_unit_of_measure;

                          l_sql := l_sql||'and '||l_database_column_name||' = '||l_unique_value_uom;
                        END IF;
                     END IF;

                    --DBMS_OUTPUT.PUT_LINE('executing sql');

                    EXIT;
                  END IF; -- end if of row_identifier, l_attribute_name, l_database_name not null
                END LOOP;-- end of loop

                BEGIN

                  EXECUTE IMMEDIATE l_sql INTO l_cs_incidents_ext_rec using p_incident_id, p_context, p_attr_group_id;
                  --DBMS_OUTPUT.PUT_LINE('executed sql');
                EXCEPTION
                  WHEN NO_DATA_FOUND THEN
                    x_rec_found := 'N';
                END;

              --Check l_cs_incidents_ext_rec if record exists

              IF l_cs_incidents_ext_rec.extension_id IS NOT NULL THEN

                    -- Record exists
                    x_rec_found := 'Y';
                    -- pass the value from the cursor variable to the l_old_Ext_Attr_Audit_Rec table
                    --DBMS_OUTPUT.PUT_LINE('Record Exists');

                    -- loop through the audit table passed in and see if you can find the record
                    -- this is for a 'CREATE' situation

                    --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.COUNT);

                    IF p_sr_audit_rec_table.COUNT > 0 THEN

                      --DBMS_OUTPUT.PUT_LINE('In loooop');
                      FOR i IN 1.. p_sr_audit_rec_table.COUNT LOOP
                        IF p_sr_audit_rec_table(i).pk_column_1 = p_incident_id AND
                           p_sr_audit_rec_table(i).context = p_context AND
                           p_sr_audit_rec_table(i).attr_group_id = p_attr_group_id AND
                           p_sr_audit_rec_table(i).row_identifier = p_row_id THEN

                           IF p_sr_audit_rec_table(i).extension_id IS NULL THEN

                           l_create_new_record := 'N';

                           --DBMS_OUTPUT.PUT_LINE('l_create_new_record'||l_create_new_record);
                           --DBMS_OUTPUT.PUT_LINE('Match found for audit record');

                           p_sr_audit_rec_table(i).extension_id      := l_cs_incidents_ext_rec.extension_id;
                           p_sr_audit_rec_table(i).pk_column_1       := p_incident_id;
                           p_sr_audit_rec_table(i).pk_column_2       := null;
                           p_sr_audit_rec_table(i).pk_column_3       := null;
                           p_sr_audit_rec_table(i).pk_column_4       := null;
                           p_sr_audit_rec_table(i).pk_column_5       := null;
                           p_sr_audit_rec_table(i).CONTEXT           := p_context;
                           p_sr_audit_rec_table(i).ATTR_GROUP_ID     := p_attr_group_id;
                           p_sr_audit_rec_table(i).C_EXT_ATTR1       := l_cs_incidents_ext_rec.C_EXT_ATTR1;
                           p_sr_audit_rec_table(i).C_EXT_ATTR2       := l_cs_incidents_ext_rec.C_EXT_ATTR2;
                           p_sr_audit_rec_table(i).C_EXT_ATTR3       := l_cs_incidents_ext_rec.C_EXT_ATTR3;
                           p_sr_audit_rec_table(i).C_EXT_ATTR4       := l_cs_incidents_ext_rec.C_EXT_ATTR4;
                           p_sr_audit_rec_table(i).C_EXT_ATTR5       := l_cs_incidents_ext_rec.C_EXT_ATTR5;
                           p_sr_audit_rec_table(i).C_EXT_ATTR6       := l_cs_incidents_ext_rec.C_EXT_ATTR6;
                           p_sr_audit_rec_table(i).C_EXT_ATTR7       := l_cs_incidents_ext_rec.C_EXT_ATTR7;
                           p_sr_audit_rec_table(i).C_EXT_ATTR8       := l_cs_incidents_ext_rec.C_EXT_ATTR8;
                           p_sr_audit_rec_table(i).C_EXT_ATTR9       := l_cs_incidents_ext_rec.C_EXT_ATTR9;
                           p_sr_audit_rec_table(i).C_EXT_ATTR10      := l_cs_incidents_ext_rec.C_EXT_ATTR10;
                           p_sr_audit_rec_table(i).C_EXT_ATTR11      := l_cs_incidents_ext_rec.C_EXT_ATTR11;
                           p_sr_audit_rec_table(i).C_EXT_ATTR12      := l_cs_incidents_ext_rec.C_EXT_ATTR12;
                           p_sr_audit_rec_table(i).C_EXT_ATTR13      := l_cs_incidents_ext_rec.C_EXT_ATTR13;
                           p_sr_audit_rec_table(i).C_EXT_ATTR14      := l_cs_incidents_ext_rec.C_EXT_ATTR14;
                           p_sr_audit_rec_table(i).C_EXT_ATTR15      := l_cs_incidents_ext_rec.C_EXT_ATTR15;
                           p_sr_audit_rec_table(i).C_EXT_ATTR16      := l_cs_incidents_ext_rec.C_EXT_ATTR16;
                           p_sr_audit_rec_table(i).C_EXT_ATTR17      := l_cs_incidents_ext_rec.C_EXT_ATTR17;
                           p_sr_audit_rec_table(i).C_EXT_ATTR18      := l_cs_incidents_ext_rec.C_EXT_ATTR18;
                           p_sr_audit_rec_table(i).C_EXT_ATTR19      := l_cs_incidents_ext_rec.C_EXT_ATTR19;
                           p_sr_audit_rec_table(i).C_EXT_ATTR20      := l_cs_incidents_ext_rec.C_EXT_ATTR20;
                           p_sr_audit_rec_table(i).C_EXT_ATTR21      := l_cs_incidents_ext_rec.C_EXT_ATTR21;
                           p_sr_audit_rec_table(i).C_EXT_ATTR22      := l_cs_incidents_ext_rec.C_EXT_ATTR22;
                           p_sr_audit_rec_table(i).C_EXT_ATTR23      := l_cs_incidents_ext_rec.C_EXT_ATTR23;
                           p_sr_audit_rec_table(i).C_EXT_ATTR24      := l_cs_incidents_ext_rec.C_EXT_ATTR24;
                           p_sr_audit_rec_table(i).C_EXT_ATTR25      := l_cs_incidents_ext_rec.C_EXT_ATTR25;
                           p_sr_audit_rec_table(i).C_EXT_ATTR26      := l_cs_incidents_ext_rec.C_EXT_ATTR26;
                           p_sr_audit_rec_table(i).C_EXT_ATTR27      := l_cs_incidents_ext_rec.C_EXT_ATTR27;
                           p_sr_audit_rec_table(i).C_EXT_ATTR28      := l_cs_incidents_ext_rec.C_EXT_ATTR28;
                           p_sr_audit_rec_table(i).C_EXT_ATTR29      := l_cs_incidents_ext_rec.C_EXT_ATTR29;
                           p_sr_audit_rec_table(i).C_EXT_ATTR30      := l_cs_incidents_ext_rec.C_EXT_ATTR30;
                           p_sr_audit_rec_table(i).C_EXT_ATTR31      := l_cs_incidents_ext_rec.C_EXT_ATTR31;
                           p_sr_audit_rec_table(i).C_EXT_ATTR32      := l_cs_incidents_ext_rec.C_EXT_ATTR32;
                           p_sr_audit_rec_table(i).C_EXT_ATTR33      := l_cs_incidents_ext_rec.C_EXT_ATTR33;
                           p_sr_audit_rec_table(i).C_EXT_ATTR34      := l_cs_incidents_ext_rec.C_EXT_ATTR34;
                           p_sr_audit_rec_table(i).C_EXT_ATTR35      := l_cs_incidents_ext_rec.C_EXT_ATTR35;
                           p_sr_audit_rec_table(i).C_EXT_ATTR36      := l_cs_incidents_ext_rec.C_EXT_ATTR36;
                           p_sr_audit_rec_table(i).C_EXT_ATTR37      := l_cs_incidents_ext_rec.C_EXT_ATTR37;
                           p_sr_audit_rec_table(i).C_EXT_ATTR38      := l_cs_incidents_ext_rec.C_EXT_ATTR38;
                           p_sr_audit_rec_table(i).C_EXT_ATTR39      := l_cs_incidents_ext_rec.C_EXT_ATTR38;
                           p_sr_audit_rec_table(i).C_EXT_ATTR40      := l_cs_incidents_ext_rec.C_EXT_ATTR40;
                           p_sr_audit_rec_table(i).C_EXT_ATTR41      := l_cs_incidents_ext_rec.C_EXT_ATTR41;
                           p_sr_audit_rec_table(i).C_EXT_ATTR42      := l_cs_incidents_ext_rec.C_EXT_ATTR42;
                           p_sr_audit_rec_table(i).C_EXT_ATTR43      := l_cs_incidents_ext_rec.C_EXT_ATTR43;
                           p_sr_audit_rec_table(i).C_EXT_ATTR44      := l_cs_incidents_ext_rec.C_EXT_ATTR44;
                           p_sr_audit_rec_table(i).C_EXT_ATTR45      := l_cs_incidents_ext_rec.C_EXT_ATTR45;
                           p_sr_audit_rec_table(i).C_EXT_ATTR46      := l_cs_incidents_ext_rec.C_EXT_ATTR46;
                           p_sr_audit_rec_table(i).C_EXT_ATTR47      := l_cs_incidents_ext_rec.C_EXT_ATTR47;
                           p_sr_audit_rec_table(i).C_EXT_ATTR48      := l_cs_incidents_ext_rec.C_EXT_ATTR48;
                           p_sr_audit_rec_table(i).C_EXT_ATTR49      := l_cs_incidents_ext_rec.C_EXT_ATTR49;
                           p_sr_audit_rec_table(i).C_EXT_ATTR50      := l_cs_incidents_ext_rec.C_EXT_ATTR50;
                           p_sr_audit_rec_table(i).N_EXT_ATTR1       := l_cs_incidents_ext_rec.N_EXT_ATTR1;
                           p_sr_audit_rec_table(i).N_EXT_ATTR2       := l_cs_incidents_ext_rec.N_EXT_ATTR2;
                           p_sr_audit_rec_table(i).N_EXT_ATTR3       := l_cs_incidents_ext_rec.N_EXT_ATTR3;
                           p_sr_audit_rec_table(i).N_EXT_ATTR4       := l_cs_incidents_ext_rec.N_EXT_ATTR4;
                           p_sr_audit_rec_table(i).N_EXT_ATTR5       := l_cs_incidents_ext_rec.N_EXT_ATTR5;
                           p_sr_audit_rec_table(i).N_EXT_ATTR6       := l_cs_incidents_ext_rec.N_EXT_ATTR6;
                           p_sr_audit_rec_table(i).N_EXT_ATTR7       := l_cs_incidents_ext_rec.N_EXT_ATTR7;
                           p_sr_audit_rec_table(i).N_EXT_ATTR8       := l_cs_incidents_ext_rec.N_EXT_ATTR8;
                           p_sr_audit_rec_table(i).N_EXT_ATTR9       := l_cs_incidents_ext_rec.N_EXT_ATTR9;
                           p_sr_audit_rec_table(i).N_EXT_ATTR10      := l_cs_incidents_ext_rec.N_EXT_ATTR10;
                           p_sr_audit_rec_table(i).N_EXT_ATTR11      := l_cs_incidents_ext_rec.N_EXT_ATTR11;
                           p_sr_audit_rec_table(i).N_EXT_ATTR12      := l_cs_incidents_ext_rec.N_EXT_ATTR12;
                           p_sr_audit_rec_table(i).N_EXT_ATTR13      := l_cs_incidents_ext_rec.N_EXT_ATTR13;
                           p_sr_audit_rec_table(i).N_EXT_ATTR14      := l_cs_incidents_ext_rec.N_EXT_ATTR14;
                           p_sr_audit_rec_table(i).N_EXT_ATTR15      := l_cs_incidents_ext_rec.N_EXT_ATTR15;
                           p_sr_audit_rec_table(i).N_EXT_ATTR16      := l_cs_incidents_ext_rec.N_EXT_ATTR16;
                           p_sr_audit_rec_table(i).N_EXT_ATTR17      := l_cs_incidents_ext_rec.N_EXT_ATTR17;
                           p_sr_audit_rec_table(i).N_EXT_ATTR18      := l_cs_incidents_ext_rec.N_EXT_ATTR18;
                           p_sr_audit_rec_table(i).N_EXT_ATTR19      := l_cs_incidents_ext_rec.N_EXT_ATTR19;
                           p_sr_audit_rec_table(i).N_EXT_ATTR20      := l_cs_incidents_ext_rec.N_EXT_ATTR20;
                           p_sr_audit_rec_table(i).N_EXT_ATTR21      := l_cs_incidents_ext_rec.N_EXT_ATTR21;
                           p_sr_audit_rec_table(i).N_EXT_ATTR22      := l_cs_incidents_ext_rec.N_EXT_ATTR22;
                           p_sr_audit_rec_table(i).N_EXT_ATTR23      := l_cs_incidents_ext_rec.N_EXT_ATTR23;
                           p_sr_audit_rec_table(i).N_EXT_ATTR24      := l_cs_incidents_ext_rec.N_EXT_ATTR24;
                           p_sr_audit_rec_table(i).N_EXT_ATTR25      := l_cs_incidents_ext_rec.N_EXT_ATTR25;
                           p_sr_audit_rec_table(i).D_EXT_ATTR1       := l_cs_incidents_ext_rec.D_EXT_ATTR1;
                           p_sr_audit_rec_table(i).D_EXT_ATTR2       := l_cs_incidents_ext_rec.D_EXT_ATTR2;
                           p_sr_audit_rec_table(i).D_EXT_ATTR3       := l_cs_incidents_ext_rec.D_EXT_ATTR3;
                           p_sr_audit_rec_table(i).D_EXT_ATTR4       := l_cs_incidents_ext_rec.D_EXT_ATTR4;
                           p_sr_audit_rec_table(i).D_EXT_ATTR5       := l_cs_incidents_ext_rec.D_EXT_ATTR5;
                           p_sr_audit_rec_table(i).D_EXT_ATTR6       := l_cs_incidents_ext_rec.D_EXT_ATTR6;
                           p_sr_audit_rec_table(i).D_EXT_ATTR7       := l_cs_incidents_ext_rec.D_EXT_ATTR7;
                           p_sr_audit_rec_table(i).D_EXT_ATTR8       := l_cs_incidents_ext_rec.D_EXT_ATTR8;
                           p_sr_audit_rec_table(i).D_EXT_ATTR9       := l_cs_incidents_ext_rec.D_EXT_ATTR9;
                           p_sr_audit_rec_table(i).D_EXT_ATTR10      := l_cs_incidents_ext_rec.D_EXT_ATTR10;
                           p_sr_audit_rec_table(i).D_EXT_ATTR11      := l_cs_incidents_ext_rec.D_EXT_ATTR11;
                           p_sr_audit_rec_table(i).D_EXT_ATTR12      := l_cs_incidents_ext_rec.D_EXT_ATTR12;
                           p_sr_audit_rec_table(i).D_EXT_ATTR13      := l_cs_incidents_ext_rec.D_EXT_ATTR13;
                           p_sr_audit_rec_table(i).D_EXT_ATTR14      := l_cs_incidents_ext_rec.D_EXT_ATTR14;
                           p_sr_audit_rec_table(i).D_EXT_ATTR15      := l_cs_incidents_ext_rec.D_EXT_ATTR15;
                           p_sr_audit_rec_table(i).D_EXT_ATTR16      := l_cs_incidents_ext_rec.D_EXT_ATTR16;
                           p_sr_audit_rec_table(i).D_EXT_ATTR17      := l_cs_incidents_ext_rec.D_EXT_ATTR17;
                           p_sr_audit_rec_table(i).D_EXT_ATTR18      := l_cs_incidents_ext_rec.D_EXT_ATTR18;
                           p_sr_audit_rec_table(i).D_EXT_ATTR19      := l_cs_incidents_ext_rec.D_EXT_ATTR19;
                           p_sr_audit_rec_table(i).D_EXT_ATTR20      := l_cs_incidents_ext_rec.D_EXT_ATTR20;
                           p_sr_audit_rec_table(i).D_EXT_ATTR21      := l_cs_incidents_ext_rec.D_EXT_ATTR21;
                           p_sr_audit_rec_table(i).D_EXT_ATTR22      := l_cs_incidents_ext_rec.D_EXT_ATTR22;
                           p_sr_audit_rec_table(i).D_EXT_ATTR23      := l_cs_incidents_ext_rec.D_EXT_ATTR23;
                           p_sr_audit_rec_table(i).D_EXT_ATTR24      := l_cs_incidents_ext_rec.D_EXT_ATTR24;
                           p_sr_audit_rec_table(i).D_EXT_ATTR25      := l_cs_incidents_ext_rec.D_EXT_ATTR25;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR1     := l_cs_incidents_ext_rec.UOM_EXT_ATTR1;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR2     := l_cs_incidents_ext_rec.UOM_EXT_ATTR2;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR3     := l_cs_incidents_ext_rec.UOM_EXT_ATTR3;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR4     := l_cs_incidents_ext_rec.UOM_EXT_ATTR4;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR5     := l_cs_incidents_ext_rec.UOM_EXT_ATTR5;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR6     := l_cs_incidents_ext_rec.UOM_EXT_ATTR6;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR7     := l_cs_incidents_ext_rec.UOM_EXT_ATTR7;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR8     := l_cs_incidents_ext_rec.UOM_EXT_ATTR8;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR9     := l_cs_incidents_ext_rec.UOM_EXT_ATTR9;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR10    := l_cs_incidents_ext_rec.UOM_EXT_ATTR10;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR11    := l_cs_incidents_ext_rec.UOM_EXT_ATTR11;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR12    := l_cs_incidents_ext_rec.UOM_EXT_ATTR12;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR13    := l_cs_incidents_ext_rec.UOM_EXT_ATTR13;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR14    := l_cs_incidents_ext_rec.UOM_EXT_ATTR14;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR15    := l_cs_incidents_ext_rec.UOM_EXT_ATTR15;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR16    := l_cs_incidents_ext_rec.UOM_EXT_ATTR16;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR17    := l_cs_incidents_ext_rec.UOM_EXT_ATTR17;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR18    := l_cs_incidents_ext_rec.UOM_EXT_ATTR18;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR19    := l_cs_incidents_ext_rec.UOM_EXT_ATTR19;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR20    := l_cs_incidents_ext_rec.UOM_EXT_ATTR20;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR21    := l_cs_incidents_ext_rec.UOM_EXT_ATTR21;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR22    := l_cs_incidents_ext_rec.UOM_EXT_ATTR22;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR23    := l_cs_incidents_ext_rec.UOM_EXT_ATTR23;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR24    := l_cs_incidents_ext_rec.UOM_EXT_ATTR24;
                           p_sr_audit_rec_table(i).UOM_EXT_ATTR25    := l_cs_incidents_ext_rec.UOM_EXT_ATTR25;

                           -- need to exit;
                           EXIT;

                          END IF;

                ELSE
                   l_create_new_record := 'Y';
                END IF;
              END LOOP;

              --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.count);
            ELSE
              l_audit_table_empty := 'Y';
            END IF;

            --DBMS_OUTPUT.PUT_LINE('l_create_new_rec'||l_create_new_record);
            --DBMS_OUTPUT.PUT_LINE('l_audit_table_empty'||l_audit_table_empty);



               IF l_create_new_record = 'Y'  OR
                  l_audit_table_empty = 'Y' THEN

                    l_count := l_count + 1;
                    p_sr_audit_rec_table (l_count).extension_id     := l_cs_incidents_ext_rec.extension_id;
                    p_sr_audit_rec_table (l_count).pk_column_1      := l_cs_incidents_ext_rec.incident_id;
                    p_sr_audit_rec_table (l_count).pk_column_2      := null;
                    p_sr_audit_rec_table (l_count).pk_column_3      := null;
                    p_sr_audit_rec_table (l_count).pk_column_4      := null;
                    p_sr_audit_rec_table (l_count).CONTEXT          := l_cs_incidents_ext_rec.context;
                    p_sr_audit_rec_table (l_count).ATTR_GROUP_ID    := l_cs_incidents_ext_rec.attr_group_id;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR1      := l_cs_incidents_ext_rec.C_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR2      := l_cs_incidents_ext_rec.C_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR3      := l_cs_incidents_ext_rec.C_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR4      := l_cs_incidents_ext_rec.C_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR5      := l_cs_incidents_ext_rec.C_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR6      := l_cs_incidents_ext_rec.C_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR7      := l_cs_incidents_ext_rec.C_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR8      := l_cs_incidents_ext_rec.C_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR9      := l_cs_incidents_ext_rec.C_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR10      := l_cs_incidents_ext_rec.C_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR11      := l_cs_incidents_ext_rec.C_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR12      := l_cs_incidents_ext_rec.C_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR13      := l_cs_incidents_ext_rec.C_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR14      := l_cs_incidents_ext_rec.C_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR15      := l_cs_incidents_ext_rec.C_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR16      := l_cs_incidents_ext_rec.C_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR17      := l_cs_incidents_ext_rec.C_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR18      := l_cs_incidents_ext_rec.C_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR19      := l_cs_incidents_ext_rec.C_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR20      := l_cs_incidents_ext_rec.C_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR21      := l_cs_incidents_ext_rec.C_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR22      := l_cs_incidents_ext_rec.C_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR23      := l_cs_incidents_ext_rec.C_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR24      := l_cs_incidents_ext_rec.C_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR25      := l_cs_incidents_ext_rec.C_EXT_ATTR25;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR26      := l_cs_incidents_ext_rec.C_EXT_ATTR26;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR27      := l_cs_incidents_ext_rec.C_EXT_ATTR27;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR28      := l_cs_incidents_ext_rec.C_EXT_ATTR28;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR29      := l_cs_incidents_ext_rec.C_EXT_ATTR29;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR30      := l_cs_incidents_ext_rec.C_EXT_ATTR30;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR31      := l_cs_incidents_ext_rec.C_EXT_ATTR31;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR32      := l_cs_incidents_ext_rec.C_EXT_ATTR32;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR33      := l_cs_incidents_ext_rec.C_EXT_ATTR33;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR34      := l_cs_incidents_ext_rec.C_EXT_ATTR34;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR35      := l_cs_incidents_ext_rec.C_EXT_ATTR35;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR36      := l_cs_incidents_ext_rec.C_EXT_ATTR36;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR37      := l_cs_incidents_ext_rec.C_EXT_ATTR37;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR38      := l_cs_incidents_ext_rec.C_EXT_ATTR38;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR39      := l_cs_incidents_ext_rec.C_EXT_ATTR38;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR40      := l_cs_incidents_ext_rec.C_EXT_ATTR40;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR41      := l_cs_incidents_ext_rec.C_EXT_ATTR41;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR42      := l_cs_incidents_ext_rec.C_EXT_ATTR42;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR43      := l_cs_incidents_ext_rec.C_EXT_ATTR43;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR44      := l_cs_incidents_ext_rec.C_EXT_ATTR44;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR45      := l_cs_incidents_ext_rec.C_EXT_ATTR45;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR46      := l_cs_incidents_ext_rec.C_EXT_ATTR46;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR47      := l_cs_incidents_ext_rec.C_EXT_ATTR47;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR48      := l_cs_incidents_ext_rec.C_EXT_ATTR48;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR49      := l_cs_incidents_ext_rec.C_EXT_ATTR49;
                    p_sr_audit_rec_table (l_count).C_EXT_ATTR50      := l_cs_incidents_ext_rec.C_EXT_ATTR50;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR1       := l_cs_incidents_ext_rec.N_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR2       := l_cs_incidents_ext_rec.N_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR3       := l_cs_incidents_ext_rec.N_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR4       := l_cs_incidents_ext_rec.N_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR5       := l_cs_incidents_ext_rec.N_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR6       := l_cs_incidents_ext_rec.N_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR7       := l_cs_incidents_ext_rec.N_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR8       := l_cs_incidents_ext_rec.N_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR9       := l_cs_incidents_ext_rec.N_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR10      := l_cs_incidents_ext_rec.N_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR11      := l_cs_incidents_ext_rec.N_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR12      := l_cs_incidents_ext_rec.N_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR13      := l_cs_incidents_ext_rec.N_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR14      := l_cs_incidents_ext_rec.N_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR15      := l_cs_incidents_ext_rec.N_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR16      := l_cs_incidents_ext_rec.N_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR17      := l_cs_incidents_ext_rec.N_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR18      := l_cs_incidents_ext_rec.N_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR19      := l_cs_incidents_ext_rec.N_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR20      := l_cs_incidents_ext_rec.N_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR21      := l_cs_incidents_ext_rec.N_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR22      := l_cs_incidents_ext_rec.N_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR23      := l_cs_incidents_ext_rec.N_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR24      := l_cs_incidents_ext_rec.N_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).N_EXT_ATTR25      := l_cs_incidents_ext_rec.N_EXT_ATTR25;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR1       := l_cs_incidents_ext_rec.D_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR2       := l_cs_incidents_ext_rec.D_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR3       := l_cs_incidents_ext_rec.D_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR4       := l_cs_incidents_ext_rec.D_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR5       := l_cs_incidents_ext_rec.D_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR6       := l_cs_incidents_ext_rec.D_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR7       := l_cs_incidents_ext_rec.D_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR8       := l_cs_incidents_ext_rec.D_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR9       := l_cs_incidents_ext_rec.D_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR10      := l_cs_incidents_ext_rec.D_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR11      := l_cs_incidents_ext_rec.D_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR12      := l_cs_incidents_ext_rec.D_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR13      := l_cs_incidents_ext_rec.D_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR14      := l_cs_incidents_ext_rec.D_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR15      := l_cs_incidents_ext_rec.D_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR16      := l_cs_incidents_ext_rec.D_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR17      := l_cs_incidents_ext_rec.D_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR18      := l_cs_incidents_ext_rec.D_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR19      := l_cs_incidents_ext_rec.D_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR20      := l_cs_incidents_ext_rec.D_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR21      := l_cs_incidents_ext_rec.D_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR22      := l_cs_incidents_ext_rec.D_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR23      := l_cs_incidents_ext_rec.D_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR24      := l_cs_incidents_ext_rec.D_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).D_EXT_ATTR25      := l_cs_incidents_ext_rec.D_EXT_ATTR25;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR1     := l_cs_incidents_ext_rec.UOM_EXT_ATTR1;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR2     := l_cs_incidents_ext_rec.UOM_EXT_ATTR2;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR3     := l_cs_incidents_ext_rec.UOM_EXT_ATTR3;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR4     := l_cs_incidents_ext_rec.UOM_EXT_ATTR4;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR5     := l_cs_incidents_ext_rec.UOM_EXT_ATTR5;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR6     := l_cs_incidents_ext_rec.UOM_EXT_ATTR6;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR7     := l_cs_incidents_ext_rec.UOM_EXT_ATTR7;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR8     := l_cs_incidents_ext_rec.UOM_EXT_ATTR8;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR9     := l_cs_incidents_ext_rec.UOM_EXT_ATTR9;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR10    := l_cs_incidents_ext_rec.UOM_EXT_ATTR10;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR11    := l_cs_incidents_ext_rec.UOM_EXT_ATTR11;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR12    := l_cs_incidents_ext_rec.UOM_EXT_ATTR12;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR13    := l_cs_incidents_ext_rec.UOM_EXT_ATTR13;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR14    := l_cs_incidents_ext_rec.UOM_EXT_ATTR14;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR15    := l_cs_incidents_ext_rec.UOM_EXT_ATTR15;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR16    := l_cs_incidents_ext_rec.UOM_EXT_ATTR16;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR17    := l_cs_incidents_ext_rec.UOM_EXT_ATTR17;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR18    := l_cs_incidents_ext_rec.UOM_EXT_ATTR18;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR19    := l_cs_incidents_ext_rec.UOM_EXT_ATTR19;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR20    := l_cs_incidents_ext_rec.UOM_EXT_ATTR20;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR21    := l_cs_incidents_ext_rec.UOM_EXT_ATTR21;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR22    := l_cs_incidents_ext_rec.UOM_EXT_ATTR22;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR23    := l_cs_incidents_ext_rec.UOM_EXT_ATTR23;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR24    := l_cs_incidents_ext_rec.UOM_EXT_ATTR24;
                    p_sr_audit_rec_table (l_count).UOM_EXT_ATTR25    := l_cs_incidents_ext_rec.UOM_EXT_ATTR25;

                   END IF;
                ELSE
                    -- Record does not exists
                    x_rec_found := 'N';
                    RETURN;
                END IF;

            END IF; -- end of if attribute name is not null
          END IF; -- end of if app id, attr_group_type, attr_group_name is not null


      ELSE
        -- l_multi_row_code = 'N'
        -- get the current record in the database for the unique key combination

          --DBMS_OUTPUT.PUT_LINE('not multi-row');

          OPEN c_get_ext_attr_db_rec;
          FETCH c_get_ext_attr_db_rec INTO v_get_ext_attr_db_rec;
          IF c_get_ext_attr_db_rec%NOTFOUND THEN
            -- Record does not exists
            x_rec_found := 'N';

          ELSE
            -- Record exists
            x_rec_found := 'Y';

            -- loop through the audit table passed in and see if you can find the record
            -- this is for a 'CREATE' situation

            --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.COUNT);

            IF p_sr_audit_rec_table.COUNT > 0 THEN

              --DBMS_OUTPUT.PUT_LINE('In loooop');
              FOR i IN 1.. p_sr_audit_rec_table.COUNT LOOP
                IF p_sr_audit_rec_table(i).pk_column_1 = p_incident_id AND
                   p_sr_audit_rec_table(i).context = p_context AND
                   p_sr_audit_rec_table(i).attr_group_id = p_attr_group_id AND
                   p_sr_audit_rec_table(i).row_identifier = p_row_id THEN

                   l_create_new_record := 'N';

                   --DBMS_OUTPUT.PUT_LINE('Match found for audit record');

                   p_sr_audit_rec_table(i).extension_id      := v_get_ext_attr_db_rec.extension_id;
                   p_sr_audit_rec_table(i).pk_column_1       := p_incident_id;
                   p_sr_audit_rec_table(i).pk_column_2       := null;
                   p_sr_audit_rec_table(i).pk_column_3       := null;
                   p_sr_audit_rec_table(i).pk_column_4       := null;
                   p_sr_audit_rec_table(i).pk_column_5       := null;
                   p_sr_audit_rec_table(i).CONTEXT           := p_context;
                   p_sr_audit_rec_table(i).ATTR_GROUP_ID     := p_attr_group_id;
                   p_sr_audit_rec_table(i).C_EXT_ATTR1       := v_get_ext_attr_db_rec.C_EXT_ATTR1;
                   p_sr_audit_rec_table(i).C_EXT_ATTR2       := v_get_ext_attr_db_rec.C_EXT_ATTR2;
                   --DBMS_OUTPUT.PUT_LINE('v_get_ext_attr_db_rec.C_EXT_ATTR2'||v_get_ext_attr_db_rec.C_EXT_ATTR2);

                   p_sr_audit_rec_table(i).C_EXT_ATTR3       := v_get_ext_attr_db_rec.C_EXT_ATTR3;
                   p_sr_audit_rec_table(i).C_EXT_ATTR4       := v_get_ext_attr_db_rec.C_EXT_ATTR4;
                   p_sr_audit_rec_table(i).C_EXT_ATTR5       := v_get_ext_attr_db_rec.C_EXT_ATTR5;
                   p_sr_audit_rec_table(i).C_EXT_ATTR6       := v_get_ext_attr_db_rec.C_EXT_ATTR6;
                   p_sr_audit_rec_table(i).C_EXT_ATTR7       := v_get_ext_attr_db_rec.C_EXT_ATTR7;
                   p_sr_audit_rec_table(i).C_EXT_ATTR8       := v_get_ext_attr_db_rec.C_EXT_ATTR8;
                   p_sr_audit_rec_table(i).C_EXT_ATTR9       := v_get_ext_attr_db_rec.C_EXT_ATTR9;
                   p_sr_audit_rec_table(i).C_EXT_ATTR10      := v_get_ext_attr_db_rec.C_EXT_ATTR10;
                   p_sr_audit_rec_table(i).C_EXT_ATTR11      := v_get_ext_attr_db_rec.C_EXT_ATTR11;
                   p_sr_audit_rec_table(i).C_EXT_ATTR12      := v_get_ext_attr_db_rec.C_EXT_ATTR12;
                   p_sr_audit_rec_table(i).C_EXT_ATTR13      := v_get_ext_attr_db_rec.C_EXT_ATTR13;
                   p_sr_audit_rec_table(i).C_EXT_ATTR14      := v_get_ext_attr_db_rec.C_EXT_ATTR14;
                   p_sr_audit_rec_table(i).C_EXT_ATTR15      := v_get_ext_attr_db_rec.C_EXT_ATTR15;
                   p_sr_audit_rec_table(i).C_EXT_ATTR16      := v_get_ext_attr_db_rec.C_EXT_ATTR16;
                   p_sr_audit_rec_table(i).C_EXT_ATTR17      := v_get_ext_attr_db_rec.C_EXT_ATTR17;
                   p_sr_audit_rec_table(i).C_EXT_ATTR18      := v_get_ext_attr_db_rec.C_EXT_ATTR18;
                   p_sr_audit_rec_table(i).C_EXT_ATTR19      := v_get_ext_attr_db_rec.C_EXT_ATTR19;
                   p_sr_audit_rec_table(i).C_EXT_ATTR20      := v_get_ext_attr_db_rec.C_EXT_ATTR20;
                   p_sr_audit_rec_table(i).C_EXT_ATTR21      := v_get_ext_attr_db_rec.C_EXT_ATTR21;
                   p_sr_audit_rec_table(i).C_EXT_ATTR22      := v_get_ext_attr_db_rec.C_EXT_ATTR22;
                   p_sr_audit_rec_table(i).C_EXT_ATTR23      := v_get_ext_attr_db_rec.C_EXT_ATTR23;
                   p_sr_audit_rec_table(i).C_EXT_ATTR24      := v_get_ext_attr_db_rec.C_EXT_ATTR24;
                   p_sr_audit_rec_table(i).C_EXT_ATTR25      := v_get_ext_attr_db_rec.C_EXT_ATTR25;
                   p_sr_audit_rec_table(i).C_EXT_ATTR26      := v_get_ext_attr_db_rec.C_EXT_ATTR26;
                   p_sr_audit_rec_table(i).C_EXT_ATTR27      := v_get_ext_attr_db_rec.C_EXT_ATTR27;
                   p_sr_audit_rec_table(i).C_EXT_ATTR28      := v_get_ext_attr_db_rec.C_EXT_ATTR28;
                   p_sr_audit_rec_table(i).C_EXT_ATTR29      := v_get_ext_attr_db_rec.C_EXT_ATTR29;
                   p_sr_audit_rec_table(i).C_EXT_ATTR30      := v_get_ext_attr_db_rec.C_EXT_ATTR30;
                   p_sr_audit_rec_table(i).C_EXT_ATTR31      := v_get_ext_attr_db_rec.C_EXT_ATTR31;
                   p_sr_audit_rec_table(i).C_EXT_ATTR32      := v_get_ext_attr_db_rec.C_EXT_ATTR32;
                   p_sr_audit_rec_table(i).C_EXT_ATTR33      := v_get_ext_attr_db_rec.C_EXT_ATTR33;
                   p_sr_audit_rec_table(i).C_EXT_ATTR34      := v_get_ext_attr_db_rec.C_EXT_ATTR34;
                   p_sr_audit_rec_table(i).C_EXT_ATTR35      := v_get_ext_attr_db_rec.C_EXT_ATTR35;
                   p_sr_audit_rec_table(i).C_EXT_ATTR36      := v_get_ext_attr_db_rec.C_EXT_ATTR36;
                   p_sr_audit_rec_table(i).C_EXT_ATTR37      := v_get_ext_attr_db_rec.C_EXT_ATTR37;
                   p_sr_audit_rec_table(i).C_EXT_ATTR38      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
                   p_sr_audit_rec_table(i).C_EXT_ATTR39      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
                   p_sr_audit_rec_table(i).C_EXT_ATTR40      := v_get_ext_attr_db_rec.C_EXT_ATTR40;
                   p_sr_audit_rec_table(i).C_EXT_ATTR41      := v_get_ext_attr_db_rec.C_EXT_ATTR41;
                   p_sr_audit_rec_table(i).C_EXT_ATTR42      := v_get_ext_attr_db_rec.C_EXT_ATTR42;
                   p_sr_audit_rec_table(i).C_EXT_ATTR43      := v_get_ext_attr_db_rec.C_EXT_ATTR43;
                   p_sr_audit_rec_table(i).C_EXT_ATTR44      := v_get_ext_attr_db_rec.C_EXT_ATTR44;
                   p_sr_audit_rec_table(i).C_EXT_ATTR45      := v_get_ext_attr_db_rec.C_EXT_ATTR45;
                   p_sr_audit_rec_table(i).C_EXT_ATTR46      := v_get_ext_attr_db_rec.C_EXT_ATTR46;
                   p_sr_audit_rec_table(i).C_EXT_ATTR47      := v_get_ext_attr_db_rec.C_EXT_ATTR47;
                   p_sr_audit_rec_table(i).C_EXT_ATTR48      := v_get_ext_attr_db_rec.C_EXT_ATTR48;
                   p_sr_audit_rec_table(i).C_EXT_ATTR49      := v_get_ext_attr_db_rec.C_EXT_ATTR49;
                   p_sr_audit_rec_table(i).C_EXT_ATTR50      := v_get_ext_attr_db_rec.C_EXT_ATTR50;
                   p_sr_audit_rec_table(i).N_EXT_ATTR1       := v_get_ext_attr_db_rec.N_EXT_ATTR1;
                   p_sr_audit_rec_table(i).N_EXT_ATTR2       := v_get_ext_attr_db_rec.N_EXT_ATTR2;
                   p_sr_audit_rec_table(i).N_EXT_ATTR3       := v_get_ext_attr_db_rec.N_EXT_ATTR3;
                   p_sr_audit_rec_table(i).N_EXT_ATTR4       := v_get_ext_attr_db_rec.N_EXT_ATTR4;
                   p_sr_audit_rec_table(i).N_EXT_ATTR5       := v_get_ext_attr_db_rec.N_EXT_ATTR5;
                   p_sr_audit_rec_table(i).N_EXT_ATTR6       := v_get_ext_attr_db_rec.N_EXT_ATTR6;
                   p_sr_audit_rec_table(i).N_EXT_ATTR7       := v_get_ext_attr_db_rec.N_EXT_ATTR7;
                   p_sr_audit_rec_table(i).N_EXT_ATTR8       := v_get_ext_attr_db_rec.N_EXT_ATTR8;
                   p_sr_audit_rec_table(i).N_EXT_ATTR9       := v_get_ext_attr_db_rec.N_EXT_ATTR9;
                   p_sr_audit_rec_table(i).N_EXT_ATTR10      := v_get_ext_attr_db_rec.N_EXT_ATTR10;
                   p_sr_audit_rec_table(i).N_EXT_ATTR11      := v_get_ext_attr_db_rec.N_EXT_ATTR11;
                   p_sr_audit_rec_table(i).N_EXT_ATTR12      := v_get_ext_attr_db_rec.N_EXT_ATTR12;
                   p_sr_audit_rec_table(i).N_EXT_ATTR13      := v_get_ext_attr_db_rec.N_EXT_ATTR13;
                   p_sr_audit_rec_table(i).N_EXT_ATTR14      := v_get_ext_attr_db_rec.N_EXT_ATTR14;
                   p_sr_audit_rec_table(i).N_EXT_ATTR15      := v_get_ext_attr_db_rec.N_EXT_ATTR15;
                   p_sr_audit_rec_table(i).N_EXT_ATTR16      := v_get_ext_attr_db_rec.N_EXT_ATTR16;
                   p_sr_audit_rec_table(i).N_EXT_ATTR17      := v_get_ext_attr_db_rec.N_EXT_ATTR17;
                   p_sr_audit_rec_table(i).N_EXT_ATTR18      := v_get_ext_attr_db_rec.N_EXT_ATTR18;
                   p_sr_audit_rec_table(i).N_EXT_ATTR19      := v_get_ext_attr_db_rec.N_EXT_ATTR19;
                   p_sr_audit_rec_table(i).N_EXT_ATTR20      := v_get_ext_attr_db_rec.N_EXT_ATTR20;
                   p_sr_audit_rec_table(i).N_EXT_ATTR21      := v_get_ext_attr_db_rec.N_EXT_ATTR21;
                   p_sr_audit_rec_table(i).N_EXT_ATTR22      := v_get_ext_attr_db_rec.N_EXT_ATTR22;
                   p_sr_audit_rec_table(i).N_EXT_ATTR23      := v_get_ext_attr_db_rec.N_EXT_ATTR23;
                   p_sr_audit_rec_table(i).N_EXT_ATTR24      := v_get_ext_attr_db_rec.N_EXT_ATTR24;
                   p_sr_audit_rec_table(i).N_EXT_ATTR25      := v_get_ext_attr_db_rec.N_EXT_ATTR25;
                   p_sr_audit_rec_table(i).D_EXT_ATTR1       := v_get_ext_attr_db_rec.D_EXT_ATTR1;
                   p_sr_audit_rec_table(i).D_EXT_ATTR2       := v_get_ext_attr_db_rec.D_EXT_ATTR2;
                   p_sr_audit_rec_table(i).D_EXT_ATTR3       := v_get_ext_attr_db_rec.D_EXT_ATTR3;
                   p_sr_audit_rec_table(i).D_EXT_ATTR4       := v_get_ext_attr_db_rec.D_EXT_ATTR4;
                   p_sr_audit_rec_table(i).D_EXT_ATTR5       := v_get_ext_attr_db_rec.D_EXT_ATTR5;
                   p_sr_audit_rec_table(i).D_EXT_ATTR6       := v_get_ext_attr_db_rec.D_EXT_ATTR6;
                   p_sr_audit_rec_table(i).D_EXT_ATTR7       := v_get_ext_attr_db_rec.D_EXT_ATTR7;
                   p_sr_audit_rec_table(i).D_EXT_ATTR8       := v_get_ext_attr_db_rec.D_EXT_ATTR8;
                   p_sr_audit_rec_table(i).D_EXT_ATTR9       := v_get_ext_attr_db_rec.D_EXT_ATTR9;
                   p_sr_audit_rec_table(i).D_EXT_ATTR10      := v_get_ext_attr_db_rec.D_EXT_ATTR10;
                   p_sr_audit_rec_table(i).D_EXT_ATTR11      := v_get_ext_attr_db_rec.D_EXT_ATTR11;
                   p_sr_audit_rec_table(i).D_EXT_ATTR12      := v_get_ext_attr_db_rec.D_EXT_ATTR12;
                   p_sr_audit_rec_table(i).D_EXT_ATTR13      := v_get_ext_attr_db_rec.D_EXT_ATTR13;
                   p_sr_audit_rec_table(i).D_EXT_ATTR14      := v_get_ext_attr_db_rec.D_EXT_ATTR14;
                   p_sr_audit_rec_table(i).D_EXT_ATTR15      := v_get_ext_attr_db_rec.D_EXT_ATTR15;
                   p_sr_audit_rec_table(i).D_EXT_ATTR16      := v_get_ext_attr_db_rec.D_EXT_ATTR16;
                   p_sr_audit_rec_table(i).D_EXT_ATTR17      := v_get_ext_attr_db_rec.D_EXT_ATTR17;
                   p_sr_audit_rec_table(i).D_EXT_ATTR18      := v_get_ext_attr_db_rec.D_EXT_ATTR18;
                   p_sr_audit_rec_table(i).D_EXT_ATTR19      := v_get_ext_attr_db_rec.D_EXT_ATTR19;
                   p_sr_audit_rec_table(i).D_EXT_ATTR20      := v_get_ext_attr_db_rec.D_EXT_ATTR20;
                   p_sr_audit_rec_table(i).D_EXT_ATTR21      := v_get_ext_attr_db_rec.D_EXT_ATTR21;
                   p_sr_audit_rec_table(i).D_EXT_ATTR22      := v_get_ext_attr_db_rec.D_EXT_ATTR22;
                   p_sr_audit_rec_table(i).D_EXT_ATTR23      := v_get_ext_attr_db_rec.D_EXT_ATTR23;
                   p_sr_audit_rec_table(i).D_EXT_ATTR24      := v_get_ext_attr_db_rec.D_EXT_ATTR24;
                   p_sr_audit_rec_table(i).D_EXT_ATTR25      := v_get_ext_attr_db_rec.D_EXT_ATTR25;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR1     := v_get_ext_attr_db_rec.UOM_EXT_ATTR1;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR2     := v_get_ext_attr_db_rec.UOM_EXT_ATTR2;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR3     := v_get_ext_attr_db_rec.UOM_EXT_ATTR3;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR4     := v_get_ext_attr_db_rec.UOM_EXT_ATTR4;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR5     := v_get_ext_attr_db_rec.UOM_EXT_ATTR5;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR6     := v_get_ext_attr_db_rec.UOM_EXT_ATTR6;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR7     := v_get_ext_attr_db_rec.UOM_EXT_ATTR7;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR8     := v_get_ext_attr_db_rec.UOM_EXT_ATTR8;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR9     := v_get_ext_attr_db_rec.UOM_EXT_ATTR9;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR10    := v_get_ext_attr_db_rec.UOM_EXT_ATTR10;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR11    := v_get_ext_attr_db_rec.UOM_EXT_ATTR11;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR12    := v_get_ext_attr_db_rec.UOM_EXT_ATTR12;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR13    := v_get_ext_attr_db_rec.UOM_EXT_ATTR13;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR14    := v_get_ext_attr_db_rec.UOM_EXT_ATTR14;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR15    := v_get_ext_attr_db_rec.UOM_EXT_ATTR15;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR16    := v_get_ext_attr_db_rec.UOM_EXT_ATTR16;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR17    := v_get_ext_attr_db_rec.UOM_EXT_ATTR17;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR18    := v_get_ext_attr_db_rec.UOM_EXT_ATTR18;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR19    := v_get_ext_attr_db_rec.UOM_EXT_ATTR19;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR20    := v_get_ext_attr_db_rec.UOM_EXT_ATTR20;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR21    := v_get_ext_attr_db_rec.UOM_EXT_ATTR21;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR22    := v_get_ext_attr_db_rec.UOM_EXT_ATTR22;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR23    := v_get_ext_attr_db_rec.UOM_EXT_ATTR23;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR24    := v_get_ext_attr_db_rec.UOM_EXT_ATTR24;
                   p_sr_audit_rec_table(i).UOM_EXT_ATTR25    := v_get_ext_attr_db_rec.UOM_EXT_ATTR25;

                ELSE
                   l_create_new_record := 'Y';
                END IF;
              END LOOP;

              --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.count);
            ELSE
              l_audit_table_empty := 'Y';
            END IF;

            --DBMS_OUTPUT.PUT_LINE('l_create_new_rec'||l_create_new_record);
            --DBMS_OUTPUT.PUT_LINE('l_audit_table_empty'||l_audit_table_empty);

            IF l_create_new_record = 'Y'  OR
               l_audit_table_empty = 'Y' THEN

            l_count := l_count + 1;

            --DBMS_OUTPUT.PUT_LINE('extension_id'||v_get_ext_attr_db_rec.extension_id);
            --DBMS_OUTPUT.PUT_LINE('pk_column_1'||v_get_ext_attr_db_rec.incident_id);
            --DBMS_OUTPUT.PUT_LINE('CONTEXT'||v_get_ext_attr_db_rec.context);
            --DBMS_OUTPUT.PUT_LINE('ATTR_GROUP_ID'||v_get_ext_attr_db_rec.attr_group_id);
            --DBMS_OUTPUT.PUT_LINE('C_EXT_ATTR1'||v_get_ext_attr_db_rec.C_EXT_ATTR1);

            p_sr_audit_rec_table(l_count).extension_id      := v_get_ext_attr_db_rec.extension_id;
            p_sr_audit_rec_table(l_count).pk_column_1       := v_get_ext_attr_db_rec.incident_id;
            p_sr_audit_rec_table(l_count).pk_column_2       := null;
            p_sr_audit_rec_table(l_count).pk_column_3       := null;
            p_sr_audit_rec_table(l_count).pk_column_4       := null;
            p_sr_audit_rec_table(l_count).pk_column_5       := null;
            p_sr_audit_rec_table(l_count).CONTEXT           := v_get_ext_attr_db_rec.context;
            p_sr_audit_rec_table(l_count).ATTR_GROUP_ID     := v_get_ext_attr_db_rec.attr_group_id;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR1       := v_get_ext_attr_db_rec.C_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR2       := v_get_ext_attr_db_rec.C_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR3       := v_get_ext_attr_db_rec.C_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR4       := v_get_ext_attr_db_rec.C_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR5       := v_get_ext_attr_db_rec.C_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR6       := v_get_ext_attr_db_rec.C_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR7       := v_get_ext_attr_db_rec.C_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR8       := v_get_ext_attr_db_rec.C_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR9       := v_get_ext_attr_db_rec.C_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR10      := v_get_ext_attr_db_rec.C_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR11      := v_get_ext_attr_db_rec.C_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR12      := v_get_ext_attr_db_rec.C_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR13      := v_get_ext_attr_db_rec.C_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR14      := v_get_ext_attr_db_rec.C_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR15      := v_get_ext_attr_db_rec.C_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR16      := v_get_ext_attr_db_rec.C_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR17      := v_get_ext_attr_db_rec.C_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR18      := v_get_ext_attr_db_rec.C_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR19      := v_get_ext_attr_db_rec.C_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR20      := v_get_ext_attr_db_rec.C_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR21      := v_get_ext_attr_db_rec.C_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR22      := v_get_ext_attr_db_rec.C_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR23      := v_get_ext_attr_db_rec.C_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR24      := v_get_ext_attr_db_rec.C_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR25      := v_get_ext_attr_db_rec.C_EXT_ATTR25;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR26      := v_get_ext_attr_db_rec.C_EXT_ATTR26;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR27      := v_get_ext_attr_db_rec.C_EXT_ATTR27;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR28      := v_get_ext_attr_db_rec.C_EXT_ATTR28;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR29      := v_get_ext_attr_db_rec.C_EXT_ATTR29;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR30      := v_get_ext_attr_db_rec.C_EXT_ATTR30;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR31      := v_get_ext_attr_db_rec.C_EXT_ATTR31;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR32      := v_get_ext_attr_db_rec.C_EXT_ATTR32;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR33      := v_get_ext_attr_db_rec.C_EXT_ATTR33;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR34      := v_get_ext_attr_db_rec.C_EXT_ATTR34;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR35      := v_get_ext_attr_db_rec.C_EXT_ATTR35;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR36      := v_get_ext_attr_db_rec.C_EXT_ATTR36;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR37      := v_get_ext_attr_db_rec.C_EXT_ATTR37;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR38      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR39      := v_get_ext_attr_db_rec.C_EXT_ATTR38;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR40      := v_get_ext_attr_db_rec.C_EXT_ATTR40;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR41      := v_get_ext_attr_db_rec.C_EXT_ATTR41;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR42      := v_get_ext_attr_db_rec.C_EXT_ATTR42;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR43      := v_get_ext_attr_db_rec.C_EXT_ATTR43;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR44      := v_get_ext_attr_db_rec.C_EXT_ATTR44;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR45      := v_get_ext_attr_db_rec.C_EXT_ATTR45;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR46      := v_get_ext_attr_db_rec.C_EXT_ATTR46;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR47      := v_get_ext_attr_db_rec.C_EXT_ATTR47;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR48      := v_get_ext_attr_db_rec.C_EXT_ATTR48;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR49      := v_get_ext_attr_db_rec.C_EXT_ATTR49;
            p_sr_audit_rec_table(l_count).C_EXT_ATTR50      := v_get_ext_attr_db_rec.C_EXT_ATTR50;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR1       := v_get_ext_attr_db_rec.N_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR2       := v_get_ext_attr_db_rec.N_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR3       := v_get_ext_attr_db_rec.N_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR4       := v_get_ext_attr_db_rec.N_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR5       := v_get_ext_attr_db_rec.N_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR6       := v_get_ext_attr_db_rec.N_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR7       := v_get_ext_attr_db_rec.N_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR8       := v_get_ext_attr_db_rec.N_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR9       := v_get_ext_attr_db_rec.N_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR10      := v_get_ext_attr_db_rec.N_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR11      := v_get_ext_attr_db_rec.N_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR12      := v_get_ext_attr_db_rec.N_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR13      := v_get_ext_attr_db_rec.N_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR14      := v_get_ext_attr_db_rec.N_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR15      := v_get_ext_attr_db_rec.N_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR16      := v_get_ext_attr_db_rec.N_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR17      := v_get_ext_attr_db_rec.N_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR18      := v_get_ext_attr_db_rec.N_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR19      := v_get_ext_attr_db_rec.N_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR20      := v_get_ext_attr_db_rec.N_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR21      := v_get_ext_attr_db_rec.N_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR22      := v_get_ext_attr_db_rec.N_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR23      := v_get_ext_attr_db_rec.N_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR24      := v_get_ext_attr_db_rec.N_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).N_EXT_ATTR25      := v_get_ext_attr_db_rec.N_EXT_ATTR25;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR1       := v_get_ext_attr_db_rec.D_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR2       := v_get_ext_attr_db_rec.D_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR3       := v_get_ext_attr_db_rec.D_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR4       := v_get_ext_attr_db_rec.D_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR5       := v_get_ext_attr_db_rec.D_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR6       := v_get_ext_attr_db_rec.D_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR7       := v_get_ext_attr_db_rec.D_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR8       := v_get_ext_attr_db_rec.D_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR9       := v_get_ext_attr_db_rec.D_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR10      := v_get_ext_attr_db_rec.D_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR11      := v_get_ext_attr_db_rec.D_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR12      := v_get_ext_attr_db_rec.D_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR13      := v_get_ext_attr_db_rec.D_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR14      := v_get_ext_attr_db_rec.D_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR15      := v_get_ext_attr_db_rec.D_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR16      := v_get_ext_attr_db_rec.D_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR17      := v_get_ext_attr_db_rec.D_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR18      := v_get_ext_attr_db_rec.D_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR19      := v_get_ext_attr_db_rec.D_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR20      := v_get_ext_attr_db_rec.D_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR21      := v_get_ext_attr_db_rec.D_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR22      := v_get_ext_attr_db_rec.D_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR23      := v_get_ext_attr_db_rec.D_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR24      := v_get_ext_attr_db_rec.D_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).D_EXT_ATTR25      := v_get_ext_attr_db_rec.D_EXT_ATTR25;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR1     := v_get_ext_attr_db_rec.UOM_EXT_ATTR1;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR2     := v_get_ext_attr_db_rec.UOM_EXT_ATTR2;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR3     := v_get_ext_attr_db_rec.UOM_EXT_ATTR3;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR4     := v_get_ext_attr_db_rec.UOM_EXT_ATTR4;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR5     := v_get_ext_attr_db_rec.UOM_EXT_ATTR5;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR6     := v_get_ext_attr_db_rec.UOM_EXT_ATTR6;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR7     := v_get_ext_attr_db_rec.UOM_EXT_ATTR7;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR8     := v_get_ext_attr_db_rec.UOM_EXT_ATTR8;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR9     := v_get_ext_attr_db_rec.UOM_EXT_ATTR9;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR10    := v_get_ext_attr_db_rec.UOM_EXT_ATTR10;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR11    := v_get_ext_attr_db_rec.UOM_EXT_ATTR11;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR12    := v_get_ext_attr_db_rec.UOM_EXT_ATTR12;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR13    := v_get_ext_attr_db_rec.UOM_EXT_ATTR13;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR14    := v_get_ext_attr_db_rec.UOM_EXT_ATTR14;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR15    := v_get_ext_attr_db_rec.UOM_EXT_ATTR15;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR16    := v_get_ext_attr_db_rec.UOM_EXT_ATTR16;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR17    := v_get_ext_attr_db_rec.UOM_EXT_ATTR17;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR18    := v_get_ext_attr_db_rec.UOM_EXT_ATTR18;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR19    := v_get_ext_attr_db_rec.UOM_EXT_ATTR19;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR20    := v_get_ext_attr_db_rec.UOM_EXT_ATTR20;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR21    := v_get_ext_attr_db_rec.UOM_EXT_ATTR21;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR22    := v_get_ext_attr_db_rec.UOM_EXT_ATTR22;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR23    := v_get_ext_attr_db_rec.UOM_EXT_ATTR23;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR24    := v_get_ext_attr_db_rec.UOM_EXT_ATTR24;
            p_sr_audit_rec_table(l_count).UOM_EXT_ATTR25    := v_get_ext_attr_db_rec.UOM_EXT_ATTR25;
           END IF;

          END IF;
          CLOSE c_get_ext_attr_db_rec;
          --DBMS_OUTPUT.PUT_LINE('p_sr_audit_rec_table.COUNT'||p_sr_audit_rec_table.count);

     END IF;
 END IF;

EXCEPTION

  WHEN OTHERS THEN
  null;
END;


PROCEDURE check_sr_context_change(
          p_incident_id     IN NUMBER
         ,p_context         IN NUMBER
         ,x_context_changed OUT NOCOPY VARCHAR2
         ,x_db_incident_id  OUT NOCOPY NUMBER
         ,x_db_context      OUT NOCOPY NUMBER

) IS

Cursor c_check_context IS
select context, incident_id from cs_incidents_ext
where incident_id = p_incident_id and
context NOT IN (select lookup_code
                from cs_lookups
               where lookup_type = 'CS_SR_EXT_ALL_REQ_TYPES'
                )
and rownum = 1;

BEGIN

  --DBMS_OUTPUT.PUT_LINE('In check_sr_context_change');

  IF p_incident_id IS NOT NULL THEN
     -- get all the lines in the extension table for the SR
     -- make sure that you are not checking the global context
     -- make sure that the SR type has not changed
     -- If SR type has changed then mark the old SR as delete
     --
     FOR v_check_context in c_check_context LOOP
       IF v_check_context.context <> p_context THEN
         --set the x_context_changed flag to 'Y'
         x_context_changed := 'Y';

         --set all out parameters
         x_db_incident_id := v_check_context.incident_id;
         x_db_context     := v_check_context.context;

         EXIT;
       ELSE
          --context matched
         x_context_changed := 'N';

         --set all out parameters
         x_db_incident_id := v_check_context.incident_id;
         x_db_context     := v_check_context.context;

        END IF;
     END LOOP;

     --DBMS_OUTPUT.PUT_LINE('x_context_changed'||x_context_changed);
   END IF;

END;


PROCEDURE Get_SR_Ext_Attrs
(p_api_version   	     IN           NUMBER
,p_init_msg_list             IN           VARCHAR2   := FND_API.G_FALSE
,p_commit                    IN           VARCHAR2   := FND_API.G_FALSE
,p_incident_id               IN           NUMBER
,p_object_name               IN           VARCHAR2
,x_ext_attr_grp_tbl          OUT  NOCOPY  CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
,x_ext_attr_tbl              OUT  NOCOPY  CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
,x_return_status             OUT  NOCOPY  VARCHAR2
,x_msg_count                 OUT  NOCOPY  NUMBER
,x_msg_data                  OUT  NOCOPY  VARCHAR2) IS


CURSOR c_check_incident_id IS
SELECT incident_id
  FROM  cs_incidents_all_b
 WHERE  incident_id = p_incident_id;

-- Fix for bug 8714809 by selecting only unique record from extensible table to
-- avoid duplicacy when multi row records are created.  Sanjana Rao, 05-aug-2009

cursor c_get_sr_ext_attr(p_incident_id IN NUMBER) IS
SELECT distinct attr_group_id
  FROM cs_incidents_ext
 WHERE incident_id = p_incident_id;


cursor c_get_pr_ext_attr(p_incident_id IN NUMBER) IS
SELECT distinct attr_group_id,party_id,contact_type,party_role_code
  FROM cs_sr_contacts_ext
 WHERE incident_id = p_incident_id;

CURSOR c_get_attr(p_application_id IN NUMBER
                 ,p_attr_group_type IN VARCHAR2
                 ,p_attr_group_name IN VARCHAR2)IS
  SELECT  APPLICATION_ID,
          ATTR_GROUP_TYPE,
          ATTR_GROUP_NAME,
          attr_name,
          attr_display_name,
          database_column
    FROM  ego_attrs_v
   WHERE application_id  = p_application_id
     AND attr_group_type = p_attr_group_type
     AND attr_group_name = p_attr_group_name
     AND enabled_flag = 'Y'
     order by sequence;

Cursor c_get_attr_group_disp_name(p_attr_group_id IN NUMBER) IS
    select ATTR_GROUP_DISP_NAME
      from ego_attr_groups_v
     where attr_group_id = p_attr_group_id;

Cursor c_get_sr_pks(p_ext_id IN NUMBER)IS
  SELECT incident_id, context
    FROM cs_incidents_ext
   WHERE extension_id = p_ext_id;

Cursor c_get_pr_pks(p_ext_id IN NUMBER)IS
  SELECT incident_id, party_id, contact_type, party_role_code, context
    FROM cs_sr_contacts_ext
   WHERE extension_id = p_ext_id;


l_pk_col_name_value_pair        EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_attr_group_request_table      EGO_ATTR_GROUP_REQUEST_TABLE;
l_attributes_row_table          EGO_USER_ATTR_ROW_TABLE;
l_attributes_data_table         EGO_USER_ATTR_DATA_TABLE;
l_user_privileges_on_object     EGO_VARCHAR_TBL_TYPE;
l_return_status                 VARCHAR2(1);
l_errorcode                     NUMBER;
l_msg_count                     NUMBER;
l_msg_data                      VARCHAR2(4000);
l_msg                           VARCHAR2(4000);
l_errm                          VARCHAR2(4000);
l_attr                          VARCHAR2(1000);

l_application_id NUMBER;
l_attr_group_type VARCHAR2(30);
l_attr_group_name VARCHAR2(80);
l_first boolean;
l_internal_name_str VARCHAR2(2000) := '';
l_count NUMBER := 0;
l_count_1 NUMBER := 0;


l_api_version   constant number       := 1.0;
l_api_name      constant varchar2(30) := 'Get_SR_Ext_Attrs';
l_api_name_full constant varchar2(61) := g_pkg_name || '.' || l_api_name;
l_log_module    constant varchar2(255) := 'cs.plsql.' || l_api_name_full || '.';

l_incident_id NUMBER;
l_party_id NUMBER;
l_contact_type VARCHAR2(30);
l_party_role_code VARCHAR2(30);
l_context NUMBER;
l_pr_context VARCHAR2(30);

l_record_exists VARCHAR2(1) := 'N';
--
--This table will hold the extended attributes information
--
TYPE EXT_ATTRIBUTE_REC IS RECORD
( APPLICATION_ID    NUMBER
 ,ATTR_GROUP_TYPE   VARCHAR2(30)
 ,ATTR_GROUP_NAME   VARCHAR2(30)
 ,ATTR_DISPLAY_NAME VARCHAR2(80)
 ,ATTR_NAME         VARCHAR2(30)
 ,DATABASE_COLUMN   VARCHAR2(30));

TYPE EXT_ATTRIBUTE_TBL IS TABLE OF EXT_ATTRIBUTE_REC INDEX BY BINARY_INTEGER;
l_ext_attr_tbl EXT_ATTRIBUTE_TBL;


BEGIN

SAVEPOINT Get_SR_Ext_Attrs;

--DBMS_OUTPUT.PUT_LINE('In Get_SR API');

-- Standard call to check for call compatibility.
IF NOT FND_API.Compatible_API_Call (l_api_version,
                                    p_api_version,
                                    l_api_name,
                                    G_PKG_NAME) THEN
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Initialize message list if p_init_msg_list is set to TRUE.
IF FND_API.to_Boolean(p_init_msg_list) THEN
  FND_MSG_PUB.initialize;
END IF;

-- Initialize API return status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

---------------------- FND Logging -----------------------------------
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
  THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || 'start'
    , 'Inside ' || L_API_NAME_FULL || ', called with parameters below:'
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_api_version:' || p_api_version
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_init_msg_list:' || p_init_msg_list
    );
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_commit:' || p_commit
    );

    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_incident_id:' || p_commit
    );

    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_incident_id:' || p_incident_id
    );

    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'p_object_name:' || p_object_name
    );

  END IF;

--DBMS_OUTPUT.PUT_LINE('Validating incident_id');
--validate the incident_id passed
IF p_incident_id IS NOT NULL THEN
  --p_incident_id is passed
  --Validate the pk_column_1 that is coming in
  OPEN c_check_incident_id;
  FETCH c_check_incident_id INTO l_incident_id;
  CLOSE c_check_incident_id;

  IF l_incident_id IS NULL THEN
    --raise error
    CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg(
                           p_token_an => l_api_name_full
                          ,p_token_v  => p_incident_id
                          ,p_token_p  => 'P_INCIDENT_ID');
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --DBMS_OUTPUT.PUT_LINE ('Pass pk1 validation');

ELSE
  --raise error
  CS_ServiceRequest_UTIL.Add_Missing_Param_Msg(
                         p_token_an	=> l_api_name_full
                        ,p_token_mp	=> 'P_INCIDENT_ID');
  RAISE FND_API.G_EXC_ERROR;

END IF;

-- Added FND_LOG
IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
  FND_LOG.String
  ( FND_LOG.level_procedure , L_LOG_MODULE || ''
  , 'Incident Passed is Valid :'
    || p_incident_id
  );
END IF;

IF  p_object_name = 'CS_SERVICE_REQUEST' THEN


  --DBMS_OUTPUT.PUT_LINE('object is CS_SR');

  FOR v_get_sr_ext_attr IN c_get_sr_ext_attr(p_incident_id) LOOP

    --set l_record_exists to 'y'
    l_record_exists := 'Y';

    -- Added FND_LOG
    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'Service Request Extensible Attributes exist for Incident passed :'
       );
    END IF;

    --populate the primary key array
    l_pk_col_name_value_pair := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INCIDENT_ID', to_char(p_incident_id)));

    --DBMS_OUTPUT.PUT_LINE('populated pk array');

    --get the attribute group information
    IF v_get_sr_ext_attr.attr_group_id IS NOT NULL then
      --get the attribute group type name and appl id
      Get_Attr_Group_Metadata(
               p_attr_group_id   => v_get_sr_ext_attr.attr_group_id
              ,x_application_id  => l_application_id
              ,x_attr_group_type => l_attr_group_type
              ,x_attr_group_name => l_attr_group_name);

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'Attribute Group Metadata -> Application ID :'
         || l_application_id
         );
      END IF;

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'Attribute Group Metadata -> Attribute Group Type  :'
         || l_attr_group_type
         );
      END IF;

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'Attribute Group Metadata -> Attribute Group Name  :'
         || l_attr_group_name
         );
      END IF;

      --DBMS_OUTPUT.PUT_LINE('Got Attr Metadata');


      --get attribute metadata for the attribute group
      IF l_application_id IS NOT NULL AND
         l_attr_group_type IS NOT NULL AND
         l_attr_group_name IS NOT NULL THEN


        FOR v_get_attr in c_get_attr(l_application_id
                                    ,l_attr_group_type
                                    ,l_attr_group_name)
        LOOP

          l_count := l_count + 1;
          l_ext_attr_tbl(l_count).application_id := v_get_attr.application_id;
          l_ext_attr_tbl(l_count).attr_group_type := v_get_attr.attr_group_type;
          l_ext_attr_tbl(l_count).attr_group_name := v_get_attr.attr_group_name;
          l_ext_attr_tbl(l_count).attr_name := v_get_attr.attr_name;
          l_ext_attr_tbl(l_count).attr_display_name := v_get_attr.attr_display_name;
          l_ext_attr_tbl(l_count).database_column := v_get_attr.database_column;


        END LOOP;

        --DBMS_OUTPUT.PUT_LINE('populated att table');
        l_first  := true;
        l_internal_name_str := '';

        FOR i in l_ext_attr_tbl.first..l_ext_attr_tbl.last LOOP

          IF  l_ext_attr_tbl(i).attr_group_name = l_attr_group_name THEN
            IF l_first = true then
                l_first := false;
            ELSE
                l_internal_name_str  := l_internal_name_str || ',';
            END IF;

            l_internal_name_str := l_internal_name_str || l_ext_attr_tbl(i).attr_name;
          END IF;

        END LOOP;

        --DBMS_OUTPUT.PUT_LINE('constructed string');
        --DBMS_OUTPUT.PUT_LINE('constructed string: '||l_internal_name_str);

        -- Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
          FND_LOG.String
          ( FND_LOG.level_procedure , L_LOG_MODULE || ''
          , 'Attribute String to Pass to PLM  :'
           || l_internal_name_str
          );
        END IF;


      ELSE
        -- Raise error
        --composite key missing
        FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_EXTATTR_COMP_KEY_REQ');
        FND_MESSAGE.SET_TOKEN('API_NAME', l_api_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF; -- composite key end if


      --populate the attribute group request table to pass to PLM
      IF (l_attr_group_request_table IS NULL) THEN
        l_attr_group_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
      END IF;

      --DBMS_OUTPUT.PUT_LINE('Initialized PLM Obj');
      --Extend the object to add value it it
      l_attr_group_request_table.EXTEND();
--      l_attr_group_request_table(l_attr_group_request_table.LAST) := EGO_ATTR_GROUP_REQUEST_OBJ
  ---                                                                   (v_get_sr_ext_attr.attr_group_id, l_application_id,
     ---                                                                 l_attr_group_type,l_attr_group_name,'GENERIC_LEVEL', NULL, NULL, l_internal_name_str);
l_attr_group_request_table(l_attr_group_request_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Request_Obj(v_get_sr_ext_attr.attr_group_id, l_application_id,
                                                                         l_attr_group_type,l_attr_group_name,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, l_internal_name_str);
      --DBMS_OUTPUT.PUT_LINE('Extended PLM Onj');
      --DBMS_OUTPUT.PUT_LINE('l_attr_group_request_table'||l_attr_group_request_table.COUNT);

    ELSE
      --attribute group is null
      --raise error
      FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_EXT_ATTR_GROUP_REQ');
      FND_MESSAGE.SET_TOKEN('API_NAME', l_api_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
    END IF; --v_get_sr_ext_attr.attr_group_id IS NOT NULL

  END LOOP;

  IF l_record_exists <> 'Y' THEN
    --no count for that incident was found in the table
    --do not call PLM

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'No Service Request Extensible Attributes data exists for this Incident'
        );
      END IF;
    RETURN;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('Calling PLM API');
  --intialize the user_privs_on_object
  l_user_privileges_on_object := EGO_VARCHAR_TBL_TYPE();
  l_user_privileges_on_object.EXTEND();
  --Call PLM Get_User_Attrs_Data API

   -- Added FND_LOG
   IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
     FND_LOG.String
     ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'Calling PLM Get User Attrs Data API'
     );
   END IF;



  EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
                          p_api_version => 1.0
                         ,p_object_name => 'CS_SERVICE_REQUEST'
                         ,p_pk_column_name_value_pairs => l_pk_col_name_value_pair
                         ,p_attr_group_request_table   => l_attr_group_request_table
                         ,p_user_privileges_on_object  => l_user_privileges_on_object
                         ,p_entity_id                  => NULL
                         ,p_entity_index               => NULL
                         ,p_entity_code                => NULL
                         ,p_debug_level                => 3
                         ,p_init_error_handler         => NULL
                         ,p_init_fnd_msg_list          => p_init_msg_list
                         ,p_add_errors_to_fnd_stack    => NULL
                         ,p_commit                     => p_commit
                         ,x_attributes_row_table       => l_attributes_row_table
                         ,x_attributes_data_table      => l_attributes_data_table
                         ,x_return_status              => x_return_status
                         ,x_errorcode                  => l_errorcode
                         ,x_msg_count                  => x_msg_count
                         ,x_msg_data                   => x_msg_data  );

  --DBMS_OUTPUT.PUT_LINE( 'x_msg_data'||x_msg_data);

  -- Added FND_LOG
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'PLM get User Attrs Data return status  :'
     || x_return_status
    );
  END IF;

    -- Added FND_LOG
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'PLM get User Attrs Data msg data  :'
     || x_msg_data
    );
  END IF;


  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_GET_SR_EXT_ATTR_WARNING');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --populate the out parameters with the value returned from PLM
  --initialize counter := 0
  l_count := 0;
  l_count_1 := 0;

  --DBMS_OUTPUT.PUT_LINE('l_attributes_row_table'||l_attributes_row_table.COUNT);
  --DBMS_OUTPUT.PUT_LINE('l_attributes_data_table'||l_attributes_data_table.COUNT);

  IF l_attributes_row_table.COUNT > 0 THEN
    FOR i IN l_attributes_row_table.FIRST .. l_attributes_row_table.LAST LOOP

      IF l_attributes_row_table.EXISTS(i) THEN

        l_count := l_count + 1;

        x_ext_attr_grp_tbl(l_count).row_identifier    := l_attributes_row_table(i).row_identifier;


        --get the pks for the extension id
        OPEN c_get_sr_pks(p_ext_id => x_ext_attr_grp_tbl(l_count).row_identifier);
        FETCH c_get_sr_pks into l_incident_id, l_context;
        CLOSE c_get_sr_pks;

        IF l_incident_id IS NULL THEN
          x_ext_attr_grp_tbl(l_count).pk_column_1       := null;
        ELSE
          x_ext_attr_grp_tbl(l_count).pk_column_1       := l_incident_id;
        END IF;

        x_ext_attr_grp_tbl(l_count).pk_column_2       := null;
        x_ext_attr_grp_tbl(l_count).pk_column_3       := null;
        x_ext_attr_grp_tbl(l_count).pk_column_4       := null;
        x_ext_attr_grp_tbl(l_count).pk_column_5       := null;

        IF l_context IS NULL THEN
          x_ext_attr_grp_tbl(l_count).context         := null;
        ELSE
          x_ext_attr_grp_tbl(l_count).context         := to_char(l_context);
        END IF;

        x_ext_attr_grp_tbl(l_count).object_name       := 'CS_SERVICE_REQUEST';
        x_ext_attr_grp_tbl(l_count).attr_group_id     := l_attributes_row_table(i).attr_group_id;
        x_ext_attr_grp_tbl(l_count).attr_group_app_id := l_attributes_row_table(i).attr_group_app_id;
        x_ext_attr_grp_tbl(l_count).attr_group_type   := l_attributes_row_table(i).attr_group_type;
        x_ext_attr_grp_tbl(l_count).attr_group_name   := l_attributes_row_table(i).attr_group_name;
        x_ext_attr_grp_tbl(l_count).mapping_req       := 'N';
        x_ext_attr_grp_tbl(l_count).operation         := 'GET';


        --get the dislay name for the attribute group

        OPEN c_get_attr_group_disp_name(x_ext_attr_grp_tbl(l_count).attr_group_id);
        FETCH c_get_attr_group_disp_name INTO x_ext_attr_grp_tbl(l_count).attr_group_disp_name;
        CLOSE c_get_attr_group_disp_name;

        --DBMS_OUTPUT.PUT_LINE('x_ext_attr_grp_tbl(l_count).row_identifier'||x_ext_attr_grp_tbl(l_count).row_identifier);
        --DBMS_OUTPUT.PUT_LINE('x_ext_attr_grp_tbl(l_count).attr_group_disp_name'||x_ext_attr_grp_tbl(l_count).attr_group_disp_name);

        -- loop through the attributes table and then populate the attributes record for the attribute group

        --DBMS_OUTPUT.PUT_LINE('l_attributes_data_table.COUNT'||l_attributes_data_table.COUNT);

        FOR j IN l_attributes_data_table.FIRST .. l_attributes_data_table.LAST LOOP

          IF l_attributes_data_table.EXISTS(j) THEN

            IF l_attributes_row_table(i).row_identifier = l_attributes_data_table(j).row_identifier THEN

              l_count_1 := l_count_1 + 1;

              -- match found populate the out parameter for the attribute table
              x_ext_attr_tbl(l_count_1).row_identifier := l_attributes_data_table(j).row_identifier;
              x_ext_attr_tbl(l_count_1).attr_name := l_attributes_data_table(j).attr_name;
              x_ext_attr_tbl(l_count_1).attr_value_str := l_attributes_data_table(j).attr_value_str;
              x_ext_attr_tbl(l_count_1).attr_value_num := l_attributes_data_table(j).attr_value_num;
              x_ext_attr_tbl(l_count_1).attr_value_date := l_attributes_data_table(j).attr_value_date;
              x_ext_attr_tbl(l_count_1).attr_value_display := l_attributes_data_table(j).attr_disp_value;
              x_ext_attr_tbl(l_count_1).attr_unit_of_measure := l_attributes_data_table(j).attr_unit_of_measure;

              --DBMS_OUTPUT.PUT_LINE('x_ext_attr_tbl(l_count_1).row_identifier'||x_ext_attr_tbl(l_count_1).row_identifier);
              --DBMS_OUTPUT.PUT_LINE('x_ext_attr_tbl(l_count_1).attr_name'||x_ext_attr_tbl(l_count_1).attr_name);

              --get the database column_name and display name for the attribute
              FOR k IN l_ext_attr_tbl.FIRST .. l_ext_attr_tbl.LAST LOOP

                IF l_ext_attr_tbl.EXISTS(k) THEN

                  IF l_attributes_row_table(i).attr_group_app_id  = l_ext_attr_tbl(k).application_id AND
                     l_attributes_row_table(i).attr_group_type = l_ext_attr_tbl(k).attr_group_type  AND
                     l_attributes_row_table(i).attr_group_name = l_ext_attr_tbl(k).attr_group_name AND
                     l_attributes_data_table(j).attr_name      = l_ext_attr_tbl(k).attr_name THEN

                    x_ext_attr_tbl(l_count_1).column_name := l_ext_attr_tbl(k).database_column;
                    x_ext_attr_tbl(l_count_1).attr_disp_name := l_ext_attr_tbl(k).attr_display_name;

                    --DBMS_OUTPUT.PUT_LINE('x_ext_attr_tbl(l_count_1).attr_disp_name'||x_ext_attr_tbl(l_count_1).attr_disp_name);
                    --DBMS_OUTPUT.PUT_LINE(' x_ext_attr_tbl(l_count_1).column_name'|| x_ext_attr_tbl(l_count_1).column_name);
                  END IF;
                END IF;
              END LOOP;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END LOOP;

    --DBMS_OUTPUT.PUT_LINE('x_ext_attr_tbl.COUNT'||x_ext_attr_tbl.count);
    --DBMS_OUTPUT.PUT_LINE('x_ext_attr_grp_tbl.COUNT'||x_ext_attr_grp_tbl.COUNT);


  END IF ; -- l_attributes_row_table.COUNT IS NOT NULL


ELSIF p_object_name = 'CS_PARTY_ROLE' THEN

  FOR v_get_pr_ext_attr IN c_get_pr_ext_attr(p_incident_id) LOOP

    --set l_record_exists to 'y'
    l_record_exists := 'Y';

    -- Added FND_LOG
    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'Party Role Extensible Attributes exist for Incident passed :'
       );
    END IF;

    --populate the primary key array
    l_pk_col_name_value_pair := EGO_COL_NAME_VALUE_PAIR_ARRAY(EGO_COL_NAME_VALUE_PAIR_OBJ('INCIDENT_ID', to_char(p_incident_id)),
                                EGO_COL_NAME_VALUE_PAIR_OBJ('PARTY_ID', to_char(v_get_pr_ext_attr.party_id)),
                                EGO_COL_NAME_VALUE_PAIR_OBJ('CONTACT_TYPE', v_get_pr_ext_attr.contact_type),
                                EGO_COL_NAME_VALUE_PAIR_OBJ('PARTY_ROLE_CODE', v_get_pr_ext_attr.party_role_code));

    --get the attribute group information
    IF v_get_pr_ext_attr.attr_group_id IS NOT NULL then
      --get the attribute group type name and appl id
      Get_Attr_Group_Metadata(
               p_attr_group_id   => v_get_pr_ext_attr.attr_group_id
              ,x_application_id  => l_application_id
              ,x_attr_group_type => l_attr_group_type
              ,x_attr_group_name => l_attr_group_name);

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'Attribute Group Metadata -> Application ID :'
         || l_application_id
         );
      END IF;

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'Attribute Group Metadata -> Attribute Group Type  :'
         || l_attr_group_type
         );
      END IF;

      -- Added FND_LOG
      IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
        FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
        , 'Attribute Group Metadata -> Attribute Group Name  :'
         || l_attr_group_name
         );
      END IF;


      --get attribute metadata for the attribute group
      IF l_application_id IS NOT NULL AND
         l_attr_group_type IS NOT NULL AND
         l_attr_group_name IS NOT NULL THEN


        FOR v_get_attr in c_get_attr(l_application_id
                                    ,l_attr_group_type
                                    ,l_attr_group_name) LOOP

          l_count := l_count + 1;
          l_ext_attr_tbl(l_count).application_id := v_get_attr.application_id;
          l_ext_attr_tbl(l_count).attr_group_type := v_get_attr.attr_group_type;
          l_ext_attr_tbl(l_count).attr_group_name := v_get_attr.attr_group_name;
          l_ext_attr_tbl(l_count).attr_name := v_get_attr.attr_name;
          l_ext_attr_tbl(l_count).attr_display_name := v_get_attr.attr_display_name;
          l_ext_attr_tbl(l_count).database_column := v_get_attr.database_column;

        END LOOP;

        l_first  := true;
        l_internal_name_str := '';

        FOR i in l_ext_attr_tbl.first..l_ext_attr_tbl.last LOOP

          IF l_first = true then
            l_first := false;
          ELSE
            l_internal_name_str  := l_internal_name_str || ',';
          END IF;

          l_internal_name_str := l_internal_name_str || l_ext_attr_tbl(i).attr_name;

        END LOOP;

        -- Added FND_LOG
        IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
          FND_LOG.String
          ( FND_LOG.level_procedure , L_LOG_MODULE || ''
          , 'Attribute String to Pass to PLM  :'
           || l_internal_name_str
          );
        END IF;


      ELSE
        -- Raise error
        --composite key missing
        -- MAYA need to add
        FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_EXTATTR_COMP_KEY_REQ');
        FND_MESSAGE.SET_TOKEN('API_NAME', l_api_name);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF; -- composite key end if


      --populate the attribute group request table to pass to PLM
      IF (l_attr_group_request_table IS NULL) THEN
        l_attr_group_request_table := EGO_ATTR_GROUP_REQUEST_TABLE();
      END IF;


      --Extend the object to add value it it
--      l_attr_group_request_table.EXTEND();
  --    l_attr_group_request_table(l_attr_group_request_table.LAST) := EGO_ATTR_GROUP_REQUEST_OBJ
    --                                                                (v_get_pr_ext_attr.attr_group_id, l_application_id,
      --                                                               l_attr_group_type,l_attr_group_name,'PARTY_ROLE_LEVEL', NULL, NULL, l_internal_name_str);
      l_attr_group_request_table(l_attr_group_request_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Request_Obj
                                                                      (v_get_pr_ext_attr.attr_group_id, l_application_id,
                                                                       l_attr_group_type,l_attr_group_name,'PARTY_ROLE_LEVEL', NULL, NULL,NULL,NULL,NULL, l_internal_name_str);
    ELSE
      --attribute group is null
      --raise error
      FND_MESSAGE.SET_NAME('CS', 'CS_API_SR_EXT_ATTR_GROUP_REQ');
      FND_MESSAGE.SET_TOKEN('API_NAME', l_api_name);
      FND_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;

    END IF; --v_get_pr_ext_attr.attr_group_id IS NOT NULL

  END LOOP;

  IF l_record_exists <> 'Y' THEN
    --no count for that incident was found in the table
    --do not call PLM
     -- Added FND_LOG
    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'No Party Role Extensible Attributes exist for Incident passed :'
       );
    END IF;
    RETURN;
  END IF;

   -- Added FND_LOG
    IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
      FND_LOG.String
      ( FND_LOG.level_procedure , L_LOG_MODULE || ''
     , 'Calling PLM Get User Attrs Data API :'
       );
    END IF;

  --Call PLM Get_User_Attrs_Data API
  EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
                          p_api_version => 1.0
                         ,p_object_name => 'CS_PARTY_ROLE'
                         ,p_pk_column_name_value_pairs => l_pk_col_name_value_pair
                         ,p_attr_group_request_table   => l_attr_group_request_table
                         ,p_user_privileges_on_object  => NULL
                         ,p_entity_id                  => NULL
                         ,p_entity_index               => NULL
                         ,p_entity_code                => NULL
                         ,p_debug_level                => 3
                         ,p_init_error_handler         => NULL
                         ,p_init_fnd_msg_list          => p_init_msg_list
                         ,p_add_errors_to_fnd_stack    => NULL
                         ,p_commit                     => p_commit
                         ,x_attributes_row_table       => l_attributes_row_table
                         ,x_attributes_data_table      => l_attributes_data_table
                         ,x_return_status              => x_return_status
                         ,x_errorcode                  => l_errorcode
                         ,x_msg_count                  => x_msg_count
                         ,x_msg_data                   => x_msg_data);

  -- Added FND_LOG
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'PLM get User Attrs Data return status  :'
     || x_return_status
    );
  END IF;

    -- Added FND_LOG
  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
    FND_LOG.String
    ( FND_LOG.level_procedure , L_LOG_MODULE || ''
    , 'PLM get User Attrs Data msg data  :'
     || x_msg_data
    );
  END IF;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_GET_SR_EXT_ATTR_WARNING');
    FND_MSG_PUB.Add;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --populate the out parameters with the value returned from PLM
  --initialize counter := 0
  l_count := 0;
  l_count_1 := 0;

   IF l_attributes_row_table.COUNT > 0 THEN
    FOR i IN l_attributes_row_table.FIRST .. l_attributes_row_table.LAST LOOP

      IF l_attributes_row_table.EXISTS(i) THEN

      l_count := l_count + 1;
      x_ext_attr_grp_tbl(l_count).row_identifier := l_attributes_row_table(i).row_identifier;

      --get the pks for the extension id
      OPEN c_get_pr_pks(p_ext_id =>x_ext_attr_grp_tbl(l_count).row_identifier);
      FETCH c_get_pr_pks into l_incident_id, l_party_id, l_contact_type, l_party_role_code, l_pr_context;
      CLOSE c_get_pr_pks;

      IF l_incident_id IS NULL THEN
        x_ext_attr_grp_tbl(l_count).pk_column_1       := null;
      ELSE
        x_ext_attr_grp_tbl(l_count).pk_column_1       := l_incident_id;
      END IF;

      IF l_party_id IS NULL THEN
        x_ext_attr_grp_tbl(l_count).pk_column_2       := null;
      ELSE
        x_ext_attr_grp_tbl(l_count).pk_column_2       := l_party_id;
      END IF;

      IF l_contact_type IS NULL THEN
        x_ext_attr_grp_tbl(l_count).pk_column_3       := null;
      ELSE
        x_ext_attr_grp_tbl(l_count).pk_column_3       := l_contact_type;
      END IF;

      IF l_party_role_code IS NULL THEN
        x_ext_attr_grp_tbl(l_count).pk_column_4       := null;
      ELSE
        x_ext_attr_grp_tbl(l_count).pk_column_4       := l_party_role_code;
      END IF;

      x_ext_attr_grp_tbl(l_count).pk_column_5       := null;

      IF l_pr_context IS NULL THEN
        x_ext_attr_grp_tbl(l_count).context         := null;
      ELSE
        x_ext_attr_grp_tbl(l_count).context         := l_pr_context;
      END IF;

      x_ext_attr_grp_tbl(l_count).attr_group_id     := l_attributes_row_table(i).attr_group_id;
      x_ext_attr_grp_tbl(l_count).attr_group_app_id := l_attributes_row_table(i).attr_group_app_id;
      x_ext_attr_grp_tbl(l_count).attr_group_type   := l_attributes_row_table(i).attr_group_type;
      x_ext_attr_grp_tbl(l_count).attr_group_name   := l_attributes_row_table(i).attr_group_name;
      x_ext_attr_grp_tbl(l_count).mapping_req       := 'N';
      x_ext_attr_grp_tbl(l_count).operation         := 'GET';

      --get the dislay name for the attribute group
      OPEN c_get_attr_group_disp_name(x_ext_attr_grp_tbl(l_count).attr_group_id);
      FETCH c_get_attr_group_disp_name INTO x_ext_attr_grp_tbl(l_count).attr_group_disp_name;
      CLOSE c_get_attr_group_disp_name;

      -- loop through the attributes table and then populate the attributes record for the attribute group
      FOR j IN l_attributes_data_table.FIRST .. l_attributes_data_table.LAST LOOP

        IF l_attributes_data_table.EXISTS(j) THEN


          IF l_attributes_row_table(i).row_identifier = l_attributes_data_table(j).row_identifier THEN
            l_count_1 := l_count_1 + 1;
            -- match found populate the out parameter for the attribute table
            x_ext_attr_tbl(l_count_1).row_identifier := l_attributes_data_table(j).row_identifier;
            x_ext_attr_tbl(l_count_1).attr_name := l_attributes_data_table(j).attr_name;
            x_ext_attr_tbl(l_count_1).attr_value_str := l_attributes_data_table(j).attr_value_str;
            x_ext_attr_tbl(l_count_1).attr_value_num := l_attributes_data_table(j).attr_value_num;
            x_ext_attr_tbl(l_count_1).attr_value_date := l_attributes_data_table(j).attr_value_date;
            x_ext_attr_tbl(l_count_1).attr_value_display := l_attributes_data_table(j).attr_disp_value;
            x_ext_attr_tbl(l_count_1).attr_unit_of_measure := l_attributes_data_table(j).attr_unit_of_measure;



          --get the database column_name and display name for the attribute
           FOR k IN l_ext_attr_tbl.FIRST .. l_ext_attr_tbl.LAST LOOP

             IF l_ext_attr_tbl.EXISTS(k) THEN

               IF l_attributes_row_table(i).attr_group_app_id  = l_ext_attr_tbl(k).application_id AND
                 l_attributes_row_table(i).attr_group_type = l_ext_attr_tbl(k).attr_group_type  AND
                 l_attributes_row_table(i).attr_group_name = l_ext_attr_tbl(k).attr_group_name AND
                 l_attributes_data_table(j).attr_name      = l_ext_attr_tbl(k).attr_name THEN

                 x_ext_attr_tbl(l_count_1).column_name := l_ext_attr_tbl(k).database_column;
                 x_ext_attr_tbl(l_count_1).attr_disp_name := l_ext_attr_tbl(k).attr_display_name;

               END IF;
              END IF;
             END LOOP;
            END IF;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF ; -- l_attributes_row_table.COUNT IS NOT NULL

END IF;

 ---------------------- FND Logging -----------------------------------
IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level
THEN

   -- --------------------------------------------------------------------------
   -- This procedure Logs the extensible attributes table.
   -- --------------------------------------------------------------------------
   Log_EXT_PVT_Parameters
   ( p_ext_attr_grp_tbl   => x_ext_attr_grp_tbl
    ,p_ext_attr_tbl       => x_ext_attr_tbl
    );

   Log_EGO_Ext_PVT_Parameters(
                p_ext_attr_grp_tbl => l_attributes_row_table
               ,p_ext_attr_tbl     => l_attributes_data_table);

END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      ( p_count => x_msg_count,
        p_data  => x_msg_data
      );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.Set_Name('CS', 'CS_GET_SR_EXT_ATTR_FAIL');
    FND_MESSAGE.Set_Token('API_NAME', L_API_NAME_FULL);
    FND_MESSAGE.Set_Token('ERROR', SQLERRM);
    FND_MSG_PUB.ADD;

END;

PROCEDURE Create_Ext_Attr_Audit(
        p_sr_ea_new_audit_rec_table    IN   Ext_Attr_Audit_Tbl_Type
       ,p_sr_ea_old_audit_rec_table    IN   Ext_Attr_Audit_Tbl_Type
       ,p_object_name                  IN   VARCHAR2
       ,p_modified_by                  IN   NUMBER := FND_GLOBAL.USER_ID
       ,p_modified_on                  IN   DATE := SYSDATE
       ,x_return_status                OUT  NOCOPY VARCHAR2
       ,x_msg_count                    OUT  NOCOPY NUMBER
       ,x_msg_data                     OUT  NOCOPY VARCHAR2
)  IS

l_is_multi_row VARCHAR2(1);

Cursor c_sr_get_ext_id(p_incident_id IN NUMBER,
                       p_context IN NUMBER,
                       p_attr_group_id IN NUMBER) IS
select extension_id from cs_incidents_ext
where incident_id = p_incident_id
  and context = p_context
  and attr_group_id  = p_attr_group_id;


cursor c_get_sr_multi_row_ext_id (p_incident_id IN NUMBER
                                 ,p_context IN NUMBER
                                 ,p_attr_group_id IN NUMBER) IS

SELECT extension_id
  FROM cs_incidents_ext
 WHERE incident_id = p_incident_id
   AND context = p_context
   AND attr_group_id = p_attr_group_id
   AND extension_id NOT IN (SELECT extension_id
                              FROM cs_incidents_ext_audit
                             WHERE incident_id = p_incident_id
                               AND context = p_context
                               AND attr_group_id = p_attr_group_id);

Cursor c_pr_get_ext_id(p_incident_id IN NUMBER,
                       p_party_id IN NUMBER,
                       p_contact_type IN VARCHAR2,
                       p_party_role_code IN VARCHAR2,
                       p_context IN VARCHAR2,
                       p_attr_group_id IN NUMBER) IS
select extension_id
 from  cs_sr_contacts_ext
where incident_id = p_incident_id
  and party_id = p_party_id
  and contact_type = p_contact_type
  and party_role_code = p_party_role_code
  and context = p_context
  and attr_group_id  = p_attr_group_id;


cursor c_get_pr_multi_row_ext_id (p_incident_id IN NUMBER,
                                  p_party_id IN NUMBER,
                                  p_contact_type IN VARCHAR2,
                                  p_party_role_code IN VARCHAR2,
                                  p_context IN VARCHAR2,
                                  p_attr_group_id IN NUMBER) IS

select extension_id
 from  cs_sr_contacts_ext
where incident_id = p_incident_id
  and party_id = p_party_id
  and contact_type = p_contact_type
  and party_role_code = p_party_role_code
  and context = p_context
  and attr_group_id  = p_attr_group_id
   AND extension_id NOT IN (SELECT extension_id
                              FROM cs_sr_contacts_ext_audit
                             where incident_id = p_incident_id
                               and party_id = p_party_id
                               and contact_type = p_contact_type
                               and party_role_code = p_party_role_code
                               and context = p_context
                               and attr_group_id  = p_attr_group_id);

l_sr_ea_new_audit_rec_table Ext_Attr_Audit_Tbl_Type;
l_sr_ea_old_audit_rec_table Ext_Attr_Audit_Tbl_Type;

l_pr_ea_new_audit_rec_table Ext_Attr_Audit_Tbl_Type;
l_pr_ea_old_audit_rec_table Ext_Attr_Audit_Tbl_Type;



BEGIN

  IF p_object_name = 'CS_SERVICE_REQUEST' THEN

    /*************New Audit Table Check***********/

    IF p_sr_ea_new_audit_rec_table.COUNT > 0 THEN

      -- pass the incoming record to
      l_sr_ea_new_audit_rec_table := p_sr_ea_new_audit_rec_table;

      --check if record had extension_id and
      --all the primary key identifiers before calling audit
      FOR i IN 1..l_sr_ea_new_audit_rec_table.COUNT LOOP
        IF l_sr_ea_new_audit_rec_table(i).extension_id IS NULL OR
           l_sr_ea_new_audit_rec_table(i).extension_id < 0 THEN
          IF l_sr_ea_new_audit_rec_table(i).pk_column_1 IS NOT NULL AND
             l_sr_ea_new_audit_rec_table(i).context IS NOT NULL AND
             l_sr_ea_new_audit_rec_table(i).attr_group_id IS NOT NULL THEN

             -- check if attribute group is multi row
             l_is_multi_row := IS_ATTR_GROUP_MULTI_ROW(
                                 p_attr_group_id   =>     l_sr_ea_new_audit_rec_table(i).attr_group_id
                                ,x_msg_data        =>     x_msg_data
                                ,x_msg_count       =>     x_msg_count
                                ,x_return_status   =>     x_return_status);

             -- If l_is_multi_row = 'Y' then get
             IF l_is_multi_row = 'Y' THEN

                -- only one row should be found as the UI will only send one record at a time
                OPEN c_get_sr_multi_row_ext_id(l_sr_ea_new_audit_rec_table(i).pk_column_1
                                                                          ,l_sr_ea_new_audit_rec_table(i).context
                                                                          ,l_sr_ea_new_audit_rec_table(i).attr_group_id);
                FETCH c_get_sr_multi_row_ext_id into l_sr_ea_new_audit_rec_table(i).extension_id;
                IF c_get_sr_multi_row_ext_id%NOTFOUND THEN
                  RETURN;
                END IF;
                CLOSE c_get_sr_multi_row_ext_id;

             ELSE

               -- l_is_multi_row = 'N'
               -- populate the all the records in the new record
                OPEN c_sr_get_ext_id(l_sr_ea_new_audit_rec_table(i).pk_column_1
                                    ,l_sr_ea_new_audit_rec_table(i).context
                                    ,l_sr_ea_new_audit_rec_table(i).attr_group_id) ;
                FETCH c_sr_get_ext_id INTO l_sr_ea_new_audit_rec_table(i).extension_id ;
                IF c_sr_get_ext_id%NOTFOUND THEN
                  RETURN;
                END IF;
                CLOSE c_sr_get_ext_id;


             END IF; --multi_row check

          ELSE

            --composite key not passed
            --raise error
            --MAYA
            null;

          END IF; -- If composite key is null;
        END IF; -- p_sr_ea_new_audit_rec_table(i).extension_id IS NULL
     END LOOP;
   END IF; -- p_sr_ea_new_audit_rec_table.COUNT > 0

   IF p_sr_ea_old_audit_rec_table.COUNT > 0 THEN

      -- pass the incoming record to
      l_sr_ea_old_audit_rec_table := p_sr_ea_old_audit_rec_table;

   ELSE
      INIT_AUDIT_REC(p_count => p_sr_ea_new_audit_rec_table.COUNT
                    ,p_audit_rec => l_sr_ea_old_audit_rec_table);
   END IF; -- p_sr_ea_old_audit_rec_table.COUNT > 0

   -- call the audit API
   insert_sr_row
           ( P_NEW_ext_attrs         => l_sr_ea_new_audit_rec_table
           , P_OLD_ext_attrs         => l_sr_ea_old_audit_rec_table
           , P_MODIFIED_BY           => p_modified_by
           , P_MODIFIED_ON           => p_modified_on
           , X_RETURN_STATUS         => X_RETURN_STATUS
           , X_MSG_COUNT             => X_MSG_COUNT
           , X_MSG_DATA              => X_MSG_DATA
            ) ;

  ELSIF p_object_name = 'CS_PARTY_ROLE' THEN
    IF p_sr_ea_new_audit_rec_table.COUNT > 0 THEN
      -- pass the incoming record to
      l_pr_ea_new_audit_rec_table := p_sr_ea_new_audit_rec_table;

      --DBMS_OUTPUT.PUT_LINE('In party role create audit');

      --check if record had extension_id and
      --all the primary key identifiers before calling audit
      FOR i IN 1..l_pr_ea_new_audit_rec_table.COUNT LOOP
         IF l_pr_ea_new_audit_rec_table(i).extension_id IS NULL OR
            l_pr_ea_new_audit_rec_table(i).extension_id < 0 THEN
          IF l_pr_ea_new_audit_rec_table(i).pk_column_1 IS NOT NULL AND
             l_pr_ea_new_audit_rec_table(i).pk_column_2 IS NOT NULL AND
             l_pr_ea_new_audit_rec_table(i).pk_column_3 IS NOT NULL AND
             l_pr_ea_new_audit_rec_table(i).pk_column_4 IS NOT NULL AND
             l_pr_ea_new_audit_rec_table(i).context IS NOT NULL AND
             l_pr_ea_new_audit_rec_table(i).attr_group_id IS NOT NULL THEN

             -- check if attribute group is multi row
             l_is_multi_row := IS_ATTR_GROUP_MULTI_ROW(
                                 p_attr_group_id   =>     l_pr_ea_new_audit_rec_table(i).attr_group_id
                                ,x_msg_data        =>     x_msg_data
                                ,x_msg_count       =>     x_msg_count
                                ,x_return_status   =>     x_return_status);

             -- If l_is_multi_row = 'Y' then get
             IF l_is_multi_row = 'Y' THEN

                -- only one row should be found as the UI will only send one record at a time
                OPEN c_get_pr_multi_row_ext_id(to_number(l_pr_ea_new_audit_rec_table(i).pk_column_1)
                                              ,to_number(l_pr_ea_new_audit_rec_table(i).pk_column_2)
                                              ,l_pr_ea_new_audit_rec_table(i).pk_column_3
                                              ,l_pr_ea_new_audit_rec_table(i).pk_column_4
                                              ,l_pr_ea_new_audit_rec_table(i).context
                                              ,l_pr_ea_new_audit_rec_table(i).attr_group_id);

                FETCH c_get_pr_multi_row_ext_id into l_pr_ea_new_audit_rec_table(i).extension_id;
                CLOSE c_get_pr_multi_row_ext_id;

             ELSE

               -- l_is_multi_row = 'N'
               -- populate the all the records in the new record
                OPEN c_pr_get_ext_id(to_number(l_pr_ea_new_audit_rec_table(i).pk_column_1)
                                    ,to_number(l_pr_ea_new_audit_rec_table(i).pk_column_2)
                                    ,l_pr_ea_new_audit_rec_table(i).pk_column_3
                                    ,l_pr_ea_new_audit_rec_table(i).pk_column_4
                                    ,l_pr_ea_new_audit_rec_table(i).context
                                    ,l_pr_ea_new_audit_rec_table(i).attr_group_id) ;
                FETCH c_pr_get_ext_id INTO l_pr_ea_new_audit_rec_table(i).extension_id ;
                CLOSE c_pr_get_ext_id;


             END IF; --multi_row check

          ELSE

            --composite key not passed
            --raise error
            --MAYA
            null;

          END IF; -- If composite key is null;
        END IF; -- p_pr_ea_new_audit_rec_table(i).extension_id IS NULL

      END LOOP;
    END IF; -- p_sr_ea_new_audit_rec_table.COUNT > 0

    --DBMS_OUTPUT.PUT_LINE('Done checking extension id');

    IF p_sr_ea_old_audit_rec_table.COUNT > 0 THEN
      -- pass the incoming record to
      --DBMS_OUTPUT.PUT_LINE('p_sr_ea_old_audit_rec_table.COUNT'||p_sr_ea_old_audit_rec_table.COUNT);

      l_pr_ea_old_audit_rec_table := p_sr_ea_old_audit_rec_table;

    ELSE
      -- call the INIT AUDIT REC
      INIT_AUDIT_REC(p_count => p_sr_ea_new_audit_rec_table.COUNT
                    ,p_audit_rec => l_pr_ea_old_audit_rec_table);

    END IF; -- p_sr_ea_old_audit_rec_table.COUNT > 0

    --DBMS_OUTPUT.PUT_LINE('Done checking old rec');

    --DBMS_OUTPUT.PUT_LINE('Calling Insert PR Row');
    --DBMS_OUTPUT.PUT_LINE('l_pr_ea_new_audit_rec_table.COUNT'||l_pr_ea_new_audit_rec_table.COUNT);
    --DBMS_OUTPUT.PUT_LINE('l_pr_ea_old_audit_rec_table.COUNT'||l_pr_ea_old_audit_rec_table.COUNT);

    -- call the audit API
    insert_pr_row
           ( P_NEW_ext_attrs         => l_pr_ea_new_audit_rec_table
           , P_OLD_ext_attrs         => l_pr_ea_old_audit_rec_table
           , P_MODIFIED_BY           => p_modified_by
           , P_MODIFIED_ON           => p_modified_on
           , X_RETURN_STATUS         => X_RETURN_STATUS
           , X_MSG_COUNT             => X_MSG_COUNT
           , X_MSG_DATA              => X_MSG_DATA
            );

  END IF; --object is 'CS_SERVICE_REQUEST' or 'CS_PARTY_ROLE' --MAY NOT BE NEEDED


END;

Procedure Merge_Ext_Attrs_Details
        (p_ext_attr_grp_tbl          IN           CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
        ,p_ext_attr_tbl              IN           CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE
        ,x_ext_grp_attr_tbl          OUT  NOCOPY  EXT_GRP_ATTR_TBL_TYPE
        ,x_return_status             OUT  NOCOPY  VARCHAR2
        ,x_msg_count                 OUT  NOCOPY  NUMBER
        ,x_msg_data                  OUT  NOCOPY  VARCHAR2) IS

q NUMBER := 1;

BEGIN

-- Loop throught the group table to get the group details..

   FOR i IN 1..p_ext_attr_grp_tbl.COUNT
       LOOP
           -- Loop through the attr table to get all the attributes for the parent group
           -- using the row identifier.
           FOR j IN 1..p_ext_attr_tbl.COUNT
               LOOP
                  -- Assign the values to the merged table structure

                  IF p_ext_attr_grp_tbl(i).ROW_IDENTIFIER = p_ext_attr_tbl(j).ROW_IDENTIFIER THEN
                     x_ext_grp_attr_tbl(q).ROW_IDENTIFIER       := p_ext_attr_grp_tbl(i).ROW_IDENTIFIER;
                     x_ext_grp_attr_tbl(q).ATTR_GROUP_ID        := p_ext_attr_grp_tbl(i).ATTR_GROUP_ID;
                     x_ext_grp_attr_tbl(q).ATTR_GROUP_TYPE      := p_ext_attr_grp_tbl(i).ATTR_GROUP_TYPE;
                     x_ext_grp_attr_tbl(q).ATTR_GROUP_NAME      := p_ext_attr_grp_tbl(i).ATTR_GROUP_NAME;
                     x_ext_grp_attr_tbl(q).ATTR_GROUP_DISP_NAME := p_ext_attr_grp_tbl(i).ATTR_GROUP_DISP_NAME;
                     x_ext_grp_attr_tbl(q).COLUMN_NAME          := p_ext_attr_tbl(j).COLUMN_NAME;
                     x_ext_grp_attr_tbl(q).ATTR_NAME            := p_ext_attr_tbl(j).ATTR_NAME;
                     x_ext_grp_attr_tbl(q).ATTR_VALUE_STR       := p_ext_attr_tbl(j).ATTR_VALUE_STR;
                     x_ext_grp_attr_tbl(q).ATTR_VALUE_NUM       := p_ext_attr_tbl(j).ATTR_VALUE_NUM;
                     x_ext_grp_attr_tbl(q).ATTR_VALUE_DATE      := p_ext_attr_tbl(j).ATTR_VALUE_DATE;
                     x_ext_grp_attr_tbl(q).ATTR_VALUE_DISPLAY   := p_ext_attr_tbl(j).ATTR_VALUE_DISPLAY;

                     q := q + 1;
                  END IF ;
               END LOOP;
       END LOOP;
EXCEPTION
     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          FND_MSG_PUB.Count_And_Get
                (p_count => x_msg_count,
                 p_data  => x_msg_data);

END Merge_Ext_Attrs_Details;



--------------------------------------------------------------------------------
-- Procedure Name : insert_sr_row
-- Parameters     :
-- IN             : p_new_ext_attrs  Table New ext attr values
--                : p_old_ext_attrs  Table old Ext attr values
--                : p_modified_by    Identity of user creationg/modifying
--                                   Ext attrs
--                : p_modified_on    Date of Ext Attr creation/update
-- OUT            : x_return_status  Status of procedure return
--                : x_msg_count      Number of error messages
--                : x_msg_data       Error description
--
--
-- Description    : Procedure to create audit of SR extensible attributes.
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 05/05/05 pkesani  Created
-- 08/08/05 smisra   Modified insert statement and used pk values for
--                   incident id
--------------------------------------------------------------------------------
PROCEDURE insert_sr_row
( P_NEW_ext_attrs         IN Ext_Attr_Audit_Tbl_Type
, P_OLD_ext_attrs         IN Ext_Attr_Audit_Tbl_Type
, P_MODIFIED_BY           IN NUMBER
, P_MODIFIED_ON           IN DATE
, X_RETURN_STATUS        OUT NOCOPY VARCHAR2
, X_MSG_COUNT            OUT NOCOPY NUMBER
, X_MSG_DATA             OUT NOCOPY VARCHAR2
)  IS
l_table_index            NUMBER;
l_ext_audit_id           NUMBER;
l_last_updated_by         NUMBER;
l_last_update_date       DATE;
l_last_update_login      NUMBER;
l_modified_by            NUMBER;
l_modified_on            DATE;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_api_name      CONSTANT VARCHAR2(30) := 'insert_sr_row';
l_api_name_full CONSTANT VARCHAR2(61) := 'CS_SR_EXTATTRIBUTES_PVT'||'.'||l_api_name;
l_incident_id   number;
BEGIN
  x_return_status     := FND_API.G_RET_STS_SUCCESS;
  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_date  := SYSDATE;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;

  IF  P_MODIFIED_BY IS NULL THEN
    l_modified_by := FND_GLOBAL.USER_ID;
  ELSE
    l_modified_by := P_MODIFIED_BY;
  END IF;

  IF  P_MODIFIED_ON IS NULL THEN
    l_modified_on := SYSDATE;
  ELSE
    l_modified_on := P_MODIFIED_ON;
  END IF;

  --DBMS_OUTPUT.PUT_LINE('Before insert');
  IF P_NEW_ext_attrs.count = 0 OR P_OLD_ext_attrs.count = 0 THEN
    RETURN;
  ELSE
    FOR l_table_index in P_NEW_ext_attrs.FIRST..P_NEW_ext_attrs.LAST LOOP

IF P_NEW_ext_attrs.exists(l_table_index) THEN

-- Update the cs header table whenver an extensible attribute is created
-- Fix by Sanjana Rao 08-jan-2010 for bug 9125600
If nvl(l_incident_id,-1)<>to_number(P_new_ext_attrs(l_table_index).pk_column_1) then
   l_incident_id:=to_number(P_new_ext_attrs(l_table_index).pk_column_1);
		update cs_incidents_all_b
		set last_update_date=l_modified_on,
		last_updated_by=l_modified_by,
		last_update_login=l_last_update_login
		where incident_id=l_incident_id;
end if;

      SELECT CS_INCIDENTS_EXT_AUDIT_S.NEXTVAL INTO l_ext_audit_id FROM dual;
  --DBMS_OUTPUT.PUT_LINE('inside for loop:' || to_char(l_ext_audit_id));

--DBMS_OUTPUT.PUT_LINE('P_new_ext_attrs(l_table_index).C_ext_attr1 '||P_new_ext_attrs(l_table_index).C_ext_attr1);
--DBMS_OUTPUT.PUT_LINE('P_new_ext_attrs(l_table_index).C_ext_attr2 '||P_new_ext_attrs(l_table_index).C_ext_attr2);
--DBMS_OUTPUT.PUT_LINE('P_new_ext_attrs(l_table_index).C_ext_attr3 '||P_new_ext_attrs(l_table_index).C_ext_attr3);
--DBMS_OUTPUT.PUT_LINE('P_new_ext_attrs(l_table_index).C_ext_attr4 '||P_new_ext_attrs(l_table_index).C_ext_attr4);

      INSERT INTO CS_INCIDENTS_EXT_AUDIT
      ( AUDIT_EXTENSION_ID
      , EXTENSION_ID
      , INCIDENT_ID
      , CONTEXT
      , ATTR_GROUP_ID
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , C_EXT_ATTR1
      , C_EXT_ATTR2
      , C_EXT_ATTR3
      , C_EXT_ATTR4
      , C_EXT_ATTR5
      , C_EXT_ATTR6
      , C_EXT_ATTR7
      , C_EXT_ATTR8
      , C_EXT_ATTR9
      , C_EXT_ATTR10
      , C_EXT_ATTR11
      , C_EXT_ATTR12
      , C_EXT_ATTR13
      , C_EXT_ATTR14
      , C_EXT_ATTR15
      , C_EXT_ATTR16
      , C_EXT_ATTR17
      , C_EXT_ATTR18
      , C_EXT_ATTR19
      , C_EXT_ATTR20
      , C_EXT_ATTR21
      , C_EXT_ATTR22
      , C_EXT_ATTR23
      , C_EXT_ATTR24
      , C_EXT_ATTR25
      , C_EXT_ATTR26
      , C_EXT_ATTR27
      , C_EXT_ATTR28
      , C_EXT_ATTR29
      , C_EXT_ATTR30
      , C_EXT_ATTR31
      , C_EXT_ATTR32
      , C_EXT_ATTR33
      , C_EXT_ATTR34
      , C_EXT_ATTR35
      , C_EXT_ATTR36
      , C_EXT_ATTR37
      , C_EXT_ATTR38
      , C_EXT_ATTR39
      , C_EXT_ATTR40
      , C_EXT_ATTR41
      , C_EXT_ATTR42
      , C_EXT_ATTR43
      , C_EXT_ATTR44
      , C_EXT_ATTR45
      , C_EXT_ATTR46
      , C_EXT_ATTR47
      , C_EXT_ATTR48
      , C_EXT_ATTR49
      , C_EXT_ATTR50
      , OLD_C_EXT_ATTR1
      , OLD_C_EXT_ATTR2
      , OLD_C_EXT_ATTR3
      , OLD_C_EXT_ATTR4
      , OLD_C_EXT_ATTR5
      , OLD_C_EXT_ATTR6
      , OLD_C_EXT_ATTR7
      , OLD_C_EXT_ATTR8
      , OLD_C_EXT_ATTR9
      , OLD_C_EXT_ATTR10
      , OLD_C_EXT_ATTR11
      , OLD_C_EXT_ATTR12
      , OLD_C_EXT_ATTR13
      , OLD_C_EXT_ATTR14
      , OLD_C_EXT_ATTR15
      , OLD_C_EXT_ATTR16
      , OLD_C_EXT_ATTR17
      , OLD_C_EXT_ATTR18
      , OLD_C_EXT_ATTR19
      , OLD_C_EXT_ATTR20
      , OLD_C_EXT_ATTR21
      , OLD_C_EXT_ATTR22
      , OLD_C_EXT_ATTR23
      , OLD_C_EXT_ATTR24
      , OLD_C_EXT_ATTR25
      , OLD_C_EXT_ATTR26
      , OLD_C_EXT_ATTR27
      , OLD_C_EXT_ATTR28
      , OLD_C_EXT_ATTR29
      , OLD_C_EXT_ATTR30
      , OLD_C_EXT_ATTR31
      , OLD_C_EXT_ATTR32
      , OLD_C_EXT_ATTR33
      , OLD_C_EXT_ATTR34
      , OLD_C_EXT_ATTR35
      , OLD_C_EXT_ATTR36
      , OLD_C_EXT_ATTR37
      , OLD_C_EXT_ATTR38
      , OLD_C_EXT_ATTR39
      , OLD_C_EXT_ATTR40
      , OLD_C_EXT_ATTR41
      , OLD_C_EXT_ATTR42
      , OLD_C_EXT_ATTR43
      , OLD_C_EXT_ATTR44
      , OLD_C_EXT_ATTR45
      , OLD_C_EXT_ATTR46
      , OLD_C_EXT_ATTR47
      , OLD_C_EXT_ATTR48
      , OLD_C_EXT_ATTR49
      , OLD_C_EXT_ATTR50
      , N_EXT_ATTR1
      , N_EXT_ATTR2
      , N_EXT_ATTR3
      , N_EXT_ATTR4
      , N_EXT_ATTR5
      , N_EXT_ATTR6
      , N_EXT_ATTR7
      , N_EXT_ATTR8
      , N_EXT_ATTR9
      , N_EXT_ATTR10
      , N_EXT_ATTR11
      , N_EXT_ATTR12
      , N_EXT_ATTR13
      , N_EXT_ATTR14
      , N_EXT_ATTR15
      , N_EXT_ATTR16
      , N_EXT_ATTR17
      , N_EXT_ATTR18
      , N_EXT_ATTR19
      , N_EXT_ATTR20
      , N_EXT_ATTR21
      , N_EXT_ATTR22
      , N_EXT_ATTR23
      , N_EXT_ATTR24
      , N_EXT_ATTR25
      , OLD_N_EXT_ATTR1
      , OLD_N_EXT_ATTR2
      , OLD_N_EXT_ATTR3
      , OLD_N_EXT_ATTR4
      , OLD_N_EXT_ATTR5
      , OLD_N_EXT_ATTR6
      , OLD_N_EXT_ATTR7
      , OLD_N_EXT_ATTR8
      , OLD_N_EXT_ATTR9
      , OLD_N_EXT_ATTR10
      , OLD_N_EXT_ATTR11
      , OLD_N_EXT_ATTR12
      , OLD_N_EXT_ATTR13
      , OLD_N_EXT_ATTR14
      , OLD_N_EXT_ATTR15
      , OLD_N_EXT_ATTR16
      , OLD_N_EXT_ATTR17
      , OLD_N_EXT_ATTR18
      , OLD_N_EXT_ATTR19
      , OLD_N_EXT_ATTR20
      , OLD_N_EXT_ATTR21
      , OLD_N_EXT_ATTR22
      , OLD_N_EXT_ATTR23
      , OLD_N_EXT_ATTR24
      , OLD_N_EXT_ATTR25
      , D_EXT_ATTR1
      , D_EXT_ATTR2
      , D_EXT_ATTR3
      , D_EXT_ATTR4
      , D_EXT_ATTR5
      , D_EXT_ATTR6
      , D_EXT_ATTR7
      , D_EXT_ATTR8
      , D_EXT_ATTR9
      , D_EXT_ATTR10
      , D_EXT_ATTR11
      , D_EXT_ATTR12
      , D_EXT_ATTR13
      , D_EXT_ATTR14
      , D_EXT_ATTR15
      , D_EXT_ATTR16
      , D_EXT_ATTR17
      , D_EXT_ATTR18
      , D_EXT_ATTR19
      , D_EXT_ATTR20
      , D_EXT_ATTR21
      , D_EXT_ATTR22
      , D_EXT_ATTR23
      , D_EXT_ATTR24
      , D_EXT_ATTR25
      , OLD_D_EXT_ATTR1
      , OLD_D_EXT_ATTR2
      , OLD_D_EXT_ATTR3
      , OLD_D_EXT_ATTR4
      , OLD_D_EXT_ATTR5
      , OLD_D_EXT_ATTR6
      , OLD_D_EXT_ATTR7
      , OLD_D_EXT_ATTR8
      , OLD_D_EXT_ATTR9
      , OLD_D_EXT_ATTR10
      , OLD_D_EXT_ATTR11
      , OLD_D_EXT_ATTR12
      , OLD_D_EXT_ATTR13
      , OLD_D_EXT_ATTR14
      , OLD_D_EXT_ATTR15
      , OLD_D_EXT_ATTR16
      , OLD_D_EXT_ATTR17
      , OLD_D_EXT_ATTR18
      , OLD_D_EXT_ATTR19
      , OLD_D_EXT_ATTR20
      , OLD_D_EXT_ATTR21
      , OLD_D_EXT_ATTR22
      , OLD_D_EXT_ATTR23
      , OLD_D_EXT_ATTR24
      , OLD_D_EXT_ATTR25
      , UOM_EXT_ATTR1
      , UOM_EXT_ATTR2
      , UOM_EXT_ATTR3
      , UOM_EXT_ATTR4
      , UOM_EXT_ATTR5
      , UOM_EXT_ATTR6
      , UOM_EXT_ATTR7
      , UOM_EXT_ATTR8
      , UOM_EXT_ATTR9
      , UOM_EXT_ATTR10
      , UOM_EXT_ATTR11
      , UOM_EXT_ATTR12
      , UOM_EXT_ATTR13
      , UOM_EXT_ATTR14
      , UOM_EXT_ATTR15
      , UOM_EXT_ATTR16
      , UOM_EXT_ATTR17
      , UOM_EXT_ATTR18
      , UOM_EXT_ATTR19
      , UOM_EXT_ATTR20
      , UOM_EXT_ATTR21
      , UOM_EXT_ATTR22
      , UOM_EXT_ATTR23
      , UOM_EXT_ATTR24
      , UOM_EXT_ATTR25
      , OLD_UOM_EXT_ATTR1
      , OLD_UOM_EXT_ATTR2
      , OLD_UOM_EXT_ATTR3
      , OLD_UOM_EXT_ATTR4
      , OLD_UOM_EXT_ATTR5
      , OLD_UOM_EXT_ATTR6
      , OLD_UOM_EXT_ATTR7
      , OLD_UOM_EXT_ATTR8
      , OLD_UOM_EXT_ATTR9
      , OLD_UOM_EXT_ATTR10
      , OLD_UOM_EXT_ATTR11
      , OLD_UOM_EXT_ATTR12
      , OLD_UOM_EXT_ATTR13
      , OLD_UOM_EXT_ATTR14
      , OLD_UOM_EXT_ATTR15
      , OLD_UOM_EXT_ATTR16
      , OLD_UOM_EXT_ATTR17
      , OLD_UOM_EXT_ATTR18
      , OLD_UOM_EXT_ATTR19
      , OLD_UOM_EXT_ATTR20
      , OLD_UOM_EXT_ATTR21
      , OLD_UOM_EXT_ATTR22
      , OLD_UOM_EXT_ATTR23
      , OLD_UOM_EXT_ATTR24
      , OLD_UOM_EXT_ATTR25
      , EXT_ATTR_MODIFIED_ON
      , EXT_ATTR_MODIFIED_BY
      )
      VALUES
      ( l_ext_audit_id
      , p_new_ext_attrs(l_table_index).extension_ID
      , to_number(P_new_ext_attrs(l_table_index).pk_column_1)
      , P_new_ext_attrs(l_table_index).context
      , P_new_ext_attrs(l_table_index).attr_group_id
      , l_last_update_date
      , l_last_updated_by
      , l_last_update_date
      , l_last_updated_by
      , l_last_update_login
      , P_new_ext_attrs(l_table_index).C_ext_attr1
      , P_new_ext_attrs(l_table_index).C_ext_attr2
      , P_new_ext_attrs(l_table_index).C_ext_attr3
      , P_new_ext_attrs(l_table_index).C_ext_attr4
      , P_new_ext_attrs(l_table_index).C_ext_attr5
      , P_new_ext_attrs(l_table_index).C_ext_attr6
      , P_new_ext_attrs(l_table_index).C_ext_attr7
      , P_new_ext_attrs(l_table_index).C_ext_attr8
      , P_new_ext_attrs(l_table_index).C_ext_attr9
      , P_new_ext_attrs(l_table_index).C_ext_attr10
      , P_new_ext_attrs(l_table_index).C_ext_attr11
      , P_new_ext_attrs(l_table_index).C_ext_attr12
      , P_new_ext_attrs(l_table_index).C_ext_attr13
      , P_new_ext_attrs(l_table_index).C_ext_attr14
      , P_new_ext_attrs(l_table_index).C_ext_attr15
      , P_new_ext_attrs(l_table_index).C_ext_attr16
      , P_new_ext_attrs(l_table_index).C_ext_attr17
      , P_new_ext_attrs(l_table_index).C_ext_attr18
      , P_new_ext_attrs(l_table_index).C_ext_attr19
      , P_new_ext_attrs(l_table_index).C_ext_attr20
      , P_new_ext_attrs(l_table_index).C_ext_attr21
      , P_new_ext_attrs(l_table_index).C_ext_attr22
      , P_new_ext_attrs(l_table_index).C_ext_attr23
      , P_new_ext_attrs(l_table_index).C_ext_attr24
      , P_new_ext_attrs(l_table_index).C_ext_attr25
      , P_new_ext_attrs(l_table_index).C_ext_attr26
      , P_new_ext_attrs(l_table_index).C_ext_attr27
      , P_new_ext_attrs(l_table_index).C_ext_attr28
      , P_new_ext_attrs(l_table_index).C_ext_attr29
      , P_new_ext_attrs(l_table_index).C_ext_attr30
      , P_new_ext_attrs(l_table_index).C_ext_attr31
      , P_new_ext_attrs(l_table_index).C_ext_attr32
      , P_new_ext_attrs(l_table_index).C_ext_attr33
      , P_new_ext_attrs(l_table_index).C_ext_attr34
      , P_new_ext_attrs(l_table_index).C_ext_attr35
      , P_new_ext_attrs(l_table_index).C_ext_attr36
      , P_new_ext_attrs(l_table_index).C_ext_attr37
      , P_new_ext_attrs(l_table_index).C_ext_attr38
      , P_new_ext_attrs(l_table_index).C_ext_attr39
      , P_new_ext_attrs(l_table_index).C_ext_attr40
      , P_new_ext_attrs(l_table_index).C_ext_attr41
      , P_new_ext_attrs(l_table_index).C_ext_attr42
      , P_new_ext_attrs(l_table_index).C_ext_attr43
      , P_new_ext_attrs(l_table_index).C_ext_attr44
      , P_new_ext_attrs(l_table_index).C_ext_attr45
      , P_new_ext_attrs(l_table_index).C_ext_attr46
      , P_new_ext_attrs(l_table_index).C_ext_attr47
      , P_new_ext_attrs(l_table_index).C_ext_attr48
      , P_new_ext_attrs(l_table_index).C_ext_attr49
      , P_new_ext_attrs(l_table_index).C_ext_attr50
      , P_old_ext_attrs(l_table_index).C_ext_attr1
      , P_old_ext_attrs(l_table_index).C_ext_attr2
      , P_old_ext_attrs(l_table_index).C_ext_attr3
      , P_old_ext_attrs(l_table_index).C_ext_attr4
      , P_old_ext_attrs(l_table_index).C_ext_attr5
      , P_old_ext_attrs(l_table_index).C_ext_attr6
      , P_old_ext_attrs(l_table_index).C_ext_attr7
      , P_old_ext_attrs(l_table_index).C_ext_attr8
      , P_old_ext_attrs(l_table_index).C_ext_attr9
      , P_old_ext_attrs(l_table_index).C_ext_attr10
      , P_old_ext_attrs(l_table_index).C_ext_attr11
      , P_old_ext_attrs(l_table_index).C_ext_attr12
      , P_old_ext_attrs(l_table_index).C_ext_attr13
      , P_old_ext_attrs(l_table_index).C_ext_attr14
      , P_old_ext_attrs(l_table_index).C_ext_attr15
      , P_old_ext_attrs(l_table_index).C_ext_attr16
      , P_old_ext_attrs(l_table_index).C_ext_attr17
      , P_old_ext_attrs(l_table_index).C_ext_attr18
      , P_old_ext_attrs(l_table_index).C_ext_attr19
      , P_old_ext_attrs(l_table_index).C_ext_attr20
      , P_old_ext_attrs(l_table_index).C_ext_attr21
      , P_old_ext_attrs(l_table_index).C_ext_attr22
      , P_old_ext_attrs(l_table_index).C_ext_attr23
      , P_old_ext_attrs(l_table_index).C_ext_attr24
      , P_old_ext_attrs(l_table_index).C_ext_attr25
      , P_old_ext_attrs(l_table_index).C_ext_attr26
      , P_old_ext_attrs(l_table_index).C_ext_attr27
      , P_old_ext_attrs(l_table_index).C_ext_attr28
      , P_old_ext_attrs(l_table_index).C_ext_attr29
      , P_old_ext_attrs(l_table_index).C_ext_attr30
      , P_old_ext_attrs(l_table_index).C_ext_attr31
      , P_old_ext_attrs(l_table_index).C_ext_attr32
      , P_old_ext_attrs(l_table_index).C_ext_attr33
      , P_old_ext_attrs(l_table_index).C_ext_attr34
      , P_old_ext_attrs(l_table_index).C_ext_attr35
      , P_old_ext_attrs(l_table_index).C_ext_attr36
      , P_old_ext_attrs(l_table_index).C_ext_attr37
      , P_old_ext_attrs(l_table_index).C_ext_attr38
      , P_old_ext_attrs(l_table_index).C_ext_attr39
      , P_old_ext_attrs(l_table_index).C_ext_attr40
      , P_old_ext_attrs(l_table_index).C_ext_attr41
      , P_old_ext_attrs(l_table_index).C_ext_attr42
      , P_old_ext_attrs(l_table_index).C_ext_attr43
      , P_old_ext_attrs(l_table_index).C_ext_attr44
      , P_old_ext_attrs(l_table_index).C_ext_attr45
      , P_old_ext_attrs(l_table_index).C_ext_attr46
      , P_old_ext_attrs(l_table_index).C_ext_attr47
      , P_old_ext_attrs(l_table_index).C_ext_attr48
      , P_old_ext_attrs(l_table_index).C_ext_attr49
      , P_old_ext_attrs(l_table_index).C_ext_attr50
      , P_new_ext_attrs(l_table_index).N_ext_attr1
      , P_new_ext_attrs(l_table_index).N_ext_attr2
      , P_new_ext_attrs(l_table_index).N_ext_attr3
      , P_new_ext_attrs(l_table_index).N_ext_attr4
      , P_new_ext_attrs(l_table_index).N_ext_attr5
      , P_new_ext_attrs(l_table_index).N_ext_attr6
      , P_new_ext_attrs(l_table_index).N_ext_attr7
      , P_new_ext_attrs(l_table_index).N_ext_attr8
      , P_new_ext_attrs(l_table_index).N_ext_attr9
      , P_new_ext_attrs(l_table_index).N_ext_attr10
      , P_new_ext_attrs(l_table_index).N_ext_attr11
      , P_new_ext_attrs(l_table_index).N_ext_attr12
      , P_new_ext_attrs(l_table_index).N_ext_attr13
      , P_new_ext_attrs(l_table_index).N_ext_attr14
      , P_new_ext_attrs(l_table_index).N_ext_attr15
      , P_new_ext_attrs(l_table_index).N_ext_attr16
      , P_new_ext_attrs(l_table_index).N_ext_attr17
      , P_new_ext_attrs(l_table_index).N_ext_attr18
      , P_new_ext_attrs(l_table_index).N_ext_attr19
      , P_new_ext_attrs(l_table_index).N_ext_attr20
      , P_new_ext_attrs(l_table_index).N_ext_attr21
      , P_new_ext_attrs(l_table_index).N_ext_attr22
      , P_new_ext_attrs(l_table_index).N_ext_attr23
      , P_new_ext_attrs(l_table_index).N_ext_attr24
      , P_new_ext_attrs(l_table_index).N_ext_attr25
      , P_old_ext_attrs(l_table_index).N_ext_attr1
      , P_old_ext_attrs(l_table_index).N_ext_attr2
      , P_old_ext_attrs(l_table_index).N_ext_attr3
      , P_old_ext_attrs(l_table_index).N_ext_attr4
      , P_old_ext_attrs(l_table_index).N_ext_attr5
      , P_old_ext_attrs(l_table_index).N_ext_attr6
      , P_old_ext_attrs(l_table_index).N_ext_attr7
      , P_old_ext_attrs(l_table_index).N_ext_attr8
      , P_old_ext_attrs(l_table_index).N_ext_attr9
      , P_old_ext_attrs(l_table_index).N_ext_attr10
      , P_old_ext_attrs(l_table_index).N_ext_attr11
      , P_old_ext_attrs(l_table_index).N_ext_attr12
      , P_old_ext_attrs(l_table_index).N_ext_attr13
      , P_old_ext_attrs(l_table_index).N_ext_attr14
      , P_old_ext_attrs(l_table_index).N_ext_attr15
      , P_old_ext_attrs(l_table_index).N_ext_attr16
      , P_old_ext_attrs(l_table_index).N_ext_attr17
      , P_old_ext_attrs(l_table_index).N_ext_attr18
      , P_old_ext_attrs(l_table_index).N_ext_attr19
      , P_old_ext_attrs(l_table_index).N_ext_attr20
      , P_old_ext_attrs(l_table_index).N_ext_attr21
      , P_old_ext_attrs(l_table_index).N_ext_attr22
      , P_old_ext_attrs(l_table_index).N_ext_attr23
      , P_old_ext_attrs(l_table_index).N_ext_attr24
      , P_old_ext_attrs(l_table_index).N_ext_attr25
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR1
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR2
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR3
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR4
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR5
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR6
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR7
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR8
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR9
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR10
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR11
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR12
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR13
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR14
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR15
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR16
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR17
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR18
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR19
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR20
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR21
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR22
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR23
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR24
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR25
      , P_old_ext_attrs(l_table_index).D_ext_attr1
      , P_old_ext_attrs(l_table_index).D_ext_attr2
      , P_old_ext_attrs(l_table_index).D_ext_attr3
      , P_old_ext_attrs(l_table_index).D_ext_attr4
      , P_old_ext_attrs(l_table_index).D_ext_attr5
      , P_old_ext_attrs(l_table_index).D_ext_attr6
      , P_old_ext_attrs(l_table_index).D_ext_attr7
      , P_old_ext_attrs(l_table_index).D_ext_attr8
      , P_old_ext_attrs(l_table_index).D_ext_attr9
      , P_old_ext_attrs(l_table_index).D_ext_attr10
      , P_old_ext_attrs(l_table_index).D_ext_attr11
      , P_old_ext_attrs(l_table_index).D_ext_attr12
      , P_old_ext_attrs(l_table_index).D_ext_attr13
      , P_old_ext_attrs(l_table_index).D_ext_attr14
      , P_old_ext_attrs(l_table_index).D_ext_attr15
      , P_old_ext_attrs(l_table_index).D_ext_attr16
      , P_old_ext_attrs(l_table_index).D_ext_attr17
      , P_old_ext_attrs(l_table_index).D_ext_attr18
      , P_old_ext_attrs(l_table_index).D_ext_attr19
      , P_old_ext_attrs(l_table_index).D_ext_attr20
      , P_old_ext_attrs(l_table_index).D_ext_attr21
      , P_old_ext_attrs(l_table_index).D_ext_attr22
      , P_old_ext_attrs(l_table_index).D_ext_attr23
      , P_old_ext_attrs(l_table_index).D_ext_attr24
      , P_old_ext_attrs(l_table_index).D_ext_attr25
      , P_new_ext_attrs(l_table_index).UOM_ext_attr1
      , P_new_ext_attrs(l_table_index).UOM_ext_attr2
      , P_new_ext_attrs(l_table_index).UOM_ext_attr3
      , P_new_ext_attrs(l_table_index).UOM_ext_attr4
      , P_new_ext_attrs(l_table_index).UOM_ext_attr5
      , P_new_ext_attrs(l_table_index).UOM_ext_attr6
      , P_new_ext_attrs(l_table_index).UOM_ext_attr7
      , P_new_ext_attrs(l_table_index).UOM_ext_attr8
      , P_new_ext_attrs(l_table_index).UOM_ext_attr9
      , P_new_ext_attrs(l_table_index).UOM_ext_attr10
      , P_new_ext_attrs(l_table_index).UOM_ext_attr11
      , P_new_ext_attrs(l_table_index).UOM_ext_attr12
      , P_new_ext_attrs(l_table_index).UOM_ext_attr13
      , P_new_ext_attrs(l_table_index).UOM_ext_attr14
      , P_new_ext_attrs(l_table_index).UOM_ext_attr15
      , P_new_ext_attrs(l_table_index).UOM_ext_attr16
      , P_new_ext_attrs(l_table_index).UOM_ext_attr17
      , P_new_ext_attrs(l_table_index).UOM_ext_attr18
      , P_new_ext_attrs(l_table_index).UOM_ext_attr19
      , P_new_ext_attrs(l_table_index).UOM_ext_attr20
      , P_new_ext_attrs(l_table_index).UOM_ext_attr21
      , P_new_ext_attrs(l_table_index).UOM_ext_attr22
      , P_new_ext_attrs(l_table_index).UOM_ext_attr23
      , P_new_ext_attrs(l_table_index).UOM_ext_attr24
      , P_new_ext_attrs(l_table_index).UOM_ext_attr25
      , P_old_ext_attrs(l_table_index).UOM_ext_attr1
      , P_old_ext_attrs(l_table_index).UOM_ext_attr2
      , P_old_ext_attrs(l_table_index).UOM_ext_attr3
      , P_old_ext_attrs(l_table_index).UOM_ext_attr4
      , P_old_ext_attrs(l_table_index).UOM_ext_attr5
      , P_old_ext_attrs(l_table_index).UOM_ext_attr6
      , P_old_ext_attrs(l_table_index).UOM_ext_attr7
      , P_old_ext_attrs(l_table_index).UOM_ext_attr8
      , P_old_ext_attrs(l_table_index).UOM_ext_attr9
      , P_old_ext_attrs(l_table_index).UOM_ext_attr10
      , P_old_ext_attrs(l_table_index).UOM_ext_attr11
      , P_old_ext_attrs(l_table_index).UOM_ext_attr12
      , P_old_ext_attrs(l_table_index).UOM_ext_attr13
      , P_old_ext_attrs(l_table_index).UOM_ext_attr14
      , P_old_ext_attrs(l_table_index).UOM_ext_attr15
      , P_old_ext_attrs(l_table_index).UOM_ext_attr16
      , P_old_ext_attrs(l_table_index).UOM_ext_attr17
      , P_old_ext_attrs(l_table_index).UOM_ext_attr18
      , P_old_ext_attrs(l_table_index).UOM_ext_attr19
      , P_old_ext_attrs(l_table_index).UOM_ext_attr20
      , P_old_ext_attrs(l_table_index).UOM_ext_attr21
      , P_old_ext_attrs(l_table_index).UOM_ext_attr22
      , P_old_ext_attrs(l_table_index).UOM_ext_attr23
      , P_old_ext_attrs(l_table_index).UOM_ext_attr24
      , P_old_ext_attrs(l_table_index).UOM_ext_attr25
      , l_modified_on
      , l_modified_by
      );

  --DBMS_OUTPUT.PUT_LINE('inside for loop after insert ');
END IF;
    END LOOP;

  END IF ;    -- no records in the table.


EXCEPTION
  WHEN OTHERS THEN
    --DBMS_OUTPUT.PUT_LINE('when other ..');
    --DBMS_OUTPUT.PUT_LINE(substr(SQLERRM,1,200));
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token('P_TEXT','cs_sr_ext_attr_data_pvt.insert_sr_row'||'-'||substr(SQLERRM,1,200));
    FND_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END insert_sr_row;


--------------------------------------------------------------------------------
-- Procedure Name : insert_pr_row
-- Parameters     :
-- IN             : p_new_ext_attrs  Table New ext attr values
--                : p_old_ext_attrs  Table old Ext attr values
--                : p_modified_by    Identity of user creationg/modifying
--                                   Ext attrs
--                : p_modified_on    Date of Ext Attr creation/update
-- OUT            : x_return_status  Status of procedure return
--                : x_msg_count      Number of error messages
--                : x_msg_data       Error description
--
-- Description    : Procedure to create audit of party role extensible attributes.
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 05/05/05 pkesani  Created
-- 08/08/05 smisra   Modified insert statement and used pk values for
--                   incident id, party id, party type and party role
--------------------------------------------------------------------------------
PROCEDURE insert_pr_row
( P_NEW_ext_attrs         IN Ext_Attr_Audit_Tbl_Type
, P_OLD_ext_attrs         IN Ext_Attr_Audit_Tbl_Type
, P_MODIFIED_BY           IN NUMBER
, P_MODIFIED_ON           IN DATE
, X_RETURN_STATUS        OUT NOCOPY VARCHAR2
, X_MSG_COUNT            OUT NOCOPY NUMBER
, X_MSG_DATA             OUT NOCOPY VARCHAR2
)  IS
l_table_index            NUMBER;
l_ext_audit_id           NUMBER;
l_last_updated_by        NUMBER;
l_last_update_date       DATE;
l_last_update_login      NUMBER;
l_modified_by            NUMBER;
l_modified_on            DATE;
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(2000);
l_api_name      CONSTANT VARCHAR2(30) := 'insert_pr_row';
l_api_name_full CONSTANT VARCHAR2(61) := 'CS_SR_EXTATTRIBUTES_PVT'||'.'||l_api_name;
l_incident_id  number;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;


  l_last_updated_by := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;
  l_last_update_date := SYSDATE;

  IF  P_MODIFIED_BY IS NULL THEN
    l_modified_by := FND_GLOBAL.USER_ID;
  ELSE
    l_modified_by := P_MODIFIED_BY;
  END IF;

  IF  P_MODIFIED_ON IS NULL THEN
    l_modified_on := SYSDATE;
  ELSE
    l_modified_on := P_MODIFIED_ON;
  END IF;

  IF P_NEW_ext_attrs.count = 0 OR P_OLD_ext_attrs.count = 0 THEN
    RETURN;
  ELSE
    FOR l_table_index in P_NEW_ext_attrs.FIRST..P_NEW_ext_attrs.LAST LOOP

-- Update the cs header table whenver an extensible attribute is created
-- Fix by Sanjana Rao , 08-jan-2010 for bug 9125600
If nvl(l_incident_id,-1)<>to_number(P_new_ext_attrs(l_table_index).pk_column_1) then
   l_incident_id:=to_number(P_new_ext_attrs(l_table_index).pk_column_1);
		update cs_incidents_all_b
		set last_update_date=l_modified_on,
		last_updated_by=l_modified_by,
		last_update_login=l_last_update_login
		where incident_id=l_incident_id;
end if;

      SELECT CS_SR_CONTACTS_EXT_AUDIT_S.NEXTVAL INTO l_ext_audit_id FROM dual;
  --DBMS_OUTPUT.PUT_LINE('inside for loop:' || to_char(l_ext_audit_id));

  --DBMS_OUTPUT.PUT_LINE('P_new_ext_attrs(l_table_index).extension_ID'||P_new_ext_attrs(l_table_index).extension_ID);

      INSERT INTO CS_SR_CONTACTS_EXT_AUDIT
      ( AUDIT_EXTENSION_ID
      , EXTENSION_ID
      , INCIDENT_ID
      , CONTEXT
      , ATTR_GROUP_ID
      , CREATION_DATE
      , CREATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_LOGIN
      , C_EXT_ATTR1
      , C_EXT_ATTR2
      , C_EXT_ATTR3
      , C_EXT_ATTR4
      , C_EXT_ATTR5
      , C_EXT_ATTR6
      , C_EXT_ATTR7
      , C_EXT_ATTR8
      , C_EXT_ATTR9
      , C_EXT_ATTR10
      , C_EXT_ATTR11
      , C_EXT_ATTR12
      , C_EXT_ATTR13
      , C_EXT_ATTR14
      , C_EXT_ATTR15
      , C_EXT_ATTR16
      , C_EXT_ATTR17
      , C_EXT_ATTR18
      , C_EXT_ATTR19
      , C_EXT_ATTR20
      , C_EXT_ATTR21
      , C_EXT_ATTR22
      , C_EXT_ATTR23
      , C_EXT_ATTR24
      , C_EXT_ATTR25
      , C_EXT_ATTR26
      , C_EXT_ATTR27
      , C_EXT_ATTR28
      , C_EXT_ATTR29
      , C_EXT_ATTR30
      , C_EXT_ATTR31
      , C_EXT_ATTR32
      , C_EXT_ATTR33
      , C_EXT_ATTR34
      , C_EXT_ATTR35
      , C_EXT_ATTR36
      , C_EXT_ATTR37
      , C_EXT_ATTR38
      , C_EXT_ATTR39
      , C_EXT_ATTR40
      , C_EXT_ATTR41
      , C_EXT_ATTR42
      , C_EXT_ATTR43
      , C_EXT_ATTR44
      , C_EXT_ATTR45
      , C_EXT_ATTR46
      , C_EXT_ATTR47
      , C_EXT_ATTR48
      , C_EXT_ATTR49
      , C_EXT_ATTR50
      , OLD_C_EXT_ATTR1
      , OLD_C_EXT_ATTR2
      , OLD_C_EXT_ATTR3
      , OLD_C_EXT_ATTR4
      , OLD_C_EXT_ATTR5
      , OLD_C_EXT_ATTR6
      , OLD_C_EXT_ATTR7
      , OLD_C_EXT_ATTR8
      , OLD_C_EXT_ATTR9
      , OLD_C_EXT_ATTR10
      , OLD_C_EXT_ATTR11
      , OLD_C_EXT_ATTR12
      , OLD_C_EXT_ATTR13
      , OLD_C_EXT_ATTR14
      , OLD_C_EXT_ATTR15
      , OLD_C_EXT_ATTR16
      , OLD_C_EXT_ATTR17
      , OLD_C_EXT_ATTR18
      , OLD_C_EXT_ATTR19
      , OLD_C_EXT_ATTR20
      , OLD_C_EXT_ATTR21
      , OLD_C_EXT_ATTR22
      , OLD_C_EXT_ATTR23
      , OLD_C_EXT_ATTR24
      , OLD_C_EXT_ATTR25
      , OLD_C_EXT_ATTR26
      , OLD_C_EXT_ATTR27
      , OLD_C_EXT_ATTR28
      , OLD_C_EXT_ATTR29
      , OLD_C_EXT_ATTR30
      , OLD_C_EXT_ATTR31
      , OLD_C_EXT_ATTR32
      , OLD_C_EXT_ATTR33
      , OLD_C_EXT_ATTR34
      , OLD_C_EXT_ATTR35
      , OLD_C_EXT_ATTR36
      , OLD_C_EXT_ATTR37
      , OLD_C_EXT_ATTR38
      , OLD_C_EXT_ATTR39
      , OLD_C_EXT_ATTR40
      , OLD_C_EXT_ATTR41
      , OLD_C_EXT_ATTR42
      , OLD_C_EXT_ATTR43
      , OLD_C_EXT_ATTR44
      , OLD_C_EXT_ATTR45
      , OLD_C_EXT_ATTR46
      , OLD_C_EXT_ATTR47
      , OLD_C_EXT_ATTR48
      , OLD_C_EXT_ATTR49
      , OLD_C_EXT_ATTR50
      , N_EXT_ATTR1
      , N_EXT_ATTR2
      , N_EXT_ATTR3
      , N_EXT_ATTR4
      , N_EXT_ATTR5
      , N_EXT_ATTR6
      , N_EXT_ATTR7
      , N_EXT_ATTR8
      , N_EXT_ATTR9
      , N_EXT_ATTR10
      , N_EXT_ATTR11
      , N_EXT_ATTR12
      , N_EXT_ATTR13
      , N_EXT_ATTR14
      , N_EXT_ATTR15
      , N_EXT_ATTR16
      , N_EXT_ATTR17
      , N_EXT_ATTR18
      , N_EXT_ATTR19
      , N_EXT_ATTR20
      , N_EXT_ATTR21
      , N_EXT_ATTR22
      , N_EXT_ATTR23
      , N_EXT_ATTR24
      , N_EXT_ATTR25
      , OLD_N_EXT_ATTR1
      , OLD_N_EXT_ATTR2
      , OLD_N_EXT_ATTR3
      , OLD_N_EXT_ATTR4
      , OLD_N_EXT_ATTR5
      , OLD_N_EXT_ATTR6
      , OLD_N_EXT_ATTR7
      , OLD_N_EXT_ATTR8
      , OLD_N_EXT_ATTR9
      , OLD_N_EXT_ATTR10
      , OLD_N_EXT_ATTR11
      , OLD_N_EXT_ATTR12
      , OLD_N_EXT_ATTR13
      , OLD_N_EXT_ATTR14
      , OLD_N_EXT_ATTR15
      , OLD_N_EXT_ATTR16
      , OLD_N_EXT_ATTR17
      , OLD_N_EXT_ATTR18
      , OLD_N_EXT_ATTR19
      , OLD_N_EXT_ATTR20
      , OLD_N_EXT_ATTR21
      , OLD_N_EXT_ATTR22
      , OLD_N_EXT_ATTR23
      , OLD_N_EXT_ATTR24
      , OLD_N_EXT_ATTR25
      , D_EXT_ATTR1
      , D_EXT_ATTR2
      , D_EXT_ATTR3
      , D_EXT_ATTR4
      , D_EXT_ATTR5
      , D_EXT_ATTR6
      , D_EXT_ATTR7
      , D_EXT_ATTR8
      , D_EXT_ATTR9
      , D_EXT_ATTR10
      , D_EXT_ATTR11
      , D_EXT_ATTR12
      , D_EXT_ATTR13
      , D_EXT_ATTR14
      , D_EXT_ATTR15
      , D_EXT_ATTR16
      , D_EXT_ATTR17
      , D_EXT_ATTR18
      , D_EXT_ATTR19
      , D_EXT_ATTR20
      , D_EXT_ATTR21
      , D_EXT_ATTR22
      , D_EXT_ATTR23
      , D_EXT_ATTR24
      , D_EXT_ATTR25
      , OLD_D_EXT_ATTR1
      , OLD_D_EXT_ATTR2
      , OLD_D_EXT_ATTR3
      , OLD_D_EXT_ATTR4
      , OLD_D_EXT_ATTR5
      , OLD_D_EXT_ATTR6
      , OLD_D_EXT_ATTR7
      , OLD_D_EXT_ATTR8
      , OLD_D_EXT_ATTR9
      , OLD_D_EXT_ATTR10
      , OLD_D_EXT_ATTR11
      , OLD_D_EXT_ATTR12
      , OLD_D_EXT_ATTR13
      , OLD_D_EXT_ATTR14
      , OLD_D_EXT_ATTR15
      , OLD_D_EXT_ATTR16
      , OLD_D_EXT_ATTR17
      , OLD_D_EXT_ATTR18
      , OLD_D_EXT_ATTR19
      , OLD_D_EXT_ATTR20
      , OLD_D_EXT_ATTR21
      , OLD_D_EXT_ATTR22
      , OLD_D_EXT_ATTR23
      , OLD_D_EXT_ATTR24
      , OLD_D_EXT_ATTR25
      , UOM_EXT_ATTR1
      , UOM_EXT_ATTR2
      , UOM_EXT_ATTR3
      , UOM_EXT_ATTR4
      , UOM_EXT_ATTR5
      , UOM_EXT_ATTR6
      , UOM_EXT_ATTR7
      , UOM_EXT_ATTR8
      , UOM_EXT_ATTR9
      , UOM_EXT_ATTR10
      , UOM_EXT_ATTR11
      , UOM_EXT_ATTR12
      , UOM_EXT_ATTR13
      , UOM_EXT_ATTR14
      , UOM_EXT_ATTR15
      , UOM_EXT_ATTR16
      , UOM_EXT_ATTR17
      , UOM_EXT_ATTR18
      , UOM_EXT_ATTR19
      , UOM_EXT_ATTR20
      , UOM_EXT_ATTR21
      , UOM_EXT_ATTR22
      , UOM_EXT_ATTR23
      , UOM_EXT_ATTR24
      , UOM_EXT_ATTR25
      , OLD_UOM_EXT_ATTR1
      , OLD_UOM_EXT_ATTR2
      , OLD_UOM_EXT_ATTR3
      , OLD_UOM_EXT_ATTR4
      , OLD_UOM_EXT_ATTR5
      , OLD_UOM_EXT_ATTR6
      , OLD_UOM_EXT_ATTR7
      , OLD_UOM_EXT_ATTR8
      , OLD_UOM_EXT_ATTR9
      , OLD_UOM_EXT_ATTR10
      , OLD_UOM_EXT_ATTR11
      , OLD_UOM_EXT_ATTR12
      , OLD_UOM_EXT_ATTR13
      , OLD_UOM_EXT_ATTR14
      , OLD_UOM_EXT_ATTR15
      , OLD_UOM_EXT_ATTR16
      , OLD_UOM_EXT_ATTR17
      , OLD_UOM_EXT_ATTR18
      , OLD_UOM_EXT_ATTR19
      , OLD_UOM_EXT_ATTR20
      , OLD_UOM_EXT_ATTR21
      , OLD_UOM_EXT_ATTR22
      , OLD_UOM_EXT_ATTR23
      , OLD_UOM_EXT_ATTR24
      , OLD_UOM_EXT_ATTR25
      , PARTY_ID
      , OLD_PARTY_ID
      , CONTACT_TYPE
      , PARTY_ROLE_CODE
      , EXT_ATTR_MODIFIED_ON
      , EXT_ATTR_MODIFIED_BY
      )
      VALUES
      ( l_ext_audit_id
      , P_new_ext_attrs(l_table_index).extension_ID
      , TO_NUMBER(p_new_ext_attrs(l_table_index).pk_column_1)
      , P_new_ext_attrs(l_table_index).context
      , P_new_ext_attrs(l_table_index).attr_group_id
      , l_last_update_date
      , l_last_updated_by
      , l_last_update_date
      , l_last_updated_by
      , l_last_update_login
      , P_new_ext_attrs(l_table_index).C_ext_attr1
      , P_new_ext_attrs(l_table_index).C_ext_attr2
      , P_new_ext_attrs(l_table_index).C_ext_attr3
      , P_new_ext_attrs(l_table_index).C_ext_attr4
      , P_new_ext_attrs(l_table_index).C_ext_attr5
      , P_new_ext_attrs(l_table_index).C_ext_attr6
      , P_new_ext_attrs(l_table_index).C_ext_attr7
      , P_new_ext_attrs(l_table_index).C_ext_attr8
      , P_new_ext_attrs(l_table_index).C_ext_attr9
      , P_new_ext_attrs(l_table_index).C_ext_attr10
      , P_new_ext_attrs(l_table_index).C_ext_attr11
      , P_new_ext_attrs(l_table_index).C_ext_attr12
      , P_new_ext_attrs(l_table_index).C_ext_attr13
      , P_new_ext_attrs(l_table_index).C_ext_attr14
      , P_new_ext_attrs(l_table_index).C_ext_attr15
      , P_new_ext_attrs(l_table_index).C_ext_attr16
      , P_new_ext_attrs(l_table_index).C_ext_attr17
      , P_new_ext_attrs(l_table_index).C_ext_attr18
      , P_new_ext_attrs(l_table_index).C_ext_attr19
      , P_new_ext_attrs(l_table_index).C_ext_attr20
      , P_new_ext_attrs(l_table_index).C_ext_attr21
      , P_new_ext_attrs(l_table_index).C_ext_attr22
      , P_new_ext_attrs(l_table_index).C_ext_attr23
      , P_new_ext_attrs(l_table_index).C_ext_attr24
      , P_new_ext_attrs(l_table_index).C_ext_attr25
      , P_new_ext_attrs(l_table_index).C_ext_attr26
      , P_new_ext_attrs(l_table_index).C_ext_attr27
      , P_new_ext_attrs(l_table_index).C_ext_attr28
      , P_new_ext_attrs(l_table_index).C_ext_attr29
      , P_new_ext_attrs(l_table_index).C_ext_attr30
      , P_new_ext_attrs(l_table_index).C_ext_attr31
      , P_new_ext_attrs(l_table_index).C_ext_attr32
      , P_new_ext_attrs(l_table_index).C_ext_attr33
      , P_new_ext_attrs(l_table_index).C_ext_attr34
      , P_new_ext_attrs(l_table_index).C_ext_attr35
      , P_new_ext_attrs(l_table_index).C_ext_attr36
      , P_new_ext_attrs(l_table_index).C_ext_attr37
      , P_new_ext_attrs(l_table_index).C_ext_attr38
      , P_new_ext_attrs(l_table_index).C_ext_attr39
      , P_new_ext_attrs(l_table_index).C_ext_attr40
      , P_new_ext_attrs(l_table_index).C_ext_attr41
      , P_new_ext_attrs(l_table_index).C_ext_attr42
      , P_new_ext_attrs(l_table_index).C_ext_attr43
      , P_new_ext_attrs(l_table_index).C_ext_attr44
      , P_new_ext_attrs(l_table_index).C_ext_attr45
      , P_new_ext_attrs(l_table_index).C_ext_attr46
      , P_new_ext_attrs(l_table_index).C_ext_attr47
      , P_new_ext_attrs(l_table_index).C_ext_attr48
      , P_new_ext_attrs(l_table_index).C_ext_attr49
      , P_new_ext_attrs(l_table_index).C_ext_attr50
      , P_old_ext_attrs(l_table_index).C_ext_attr1
      , P_old_ext_attrs(l_table_index).C_ext_attr2
      , P_old_ext_attrs(l_table_index).C_ext_attr3
      , P_old_ext_attrs(l_table_index).C_ext_attr4
      , P_old_ext_attrs(l_table_index).C_ext_attr5
      , P_old_ext_attrs(l_table_index).C_ext_attr6
      , P_old_ext_attrs(l_table_index).C_ext_attr7
      , P_old_ext_attrs(l_table_index).C_ext_attr8
      , P_old_ext_attrs(l_table_index).C_ext_attr9
      , P_old_ext_attrs(l_table_index).C_ext_attr10
      , P_old_ext_attrs(l_table_index).C_ext_attr11
      , P_old_ext_attrs(l_table_index).C_ext_attr12
      , P_old_ext_attrs(l_table_index).C_ext_attr13
      , P_old_ext_attrs(l_table_index).C_ext_attr14
      , P_old_ext_attrs(l_table_index).C_ext_attr15
      , P_old_ext_attrs(l_table_index).C_ext_attr16
      , P_old_ext_attrs(l_table_index).C_ext_attr17
      , P_old_ext_attrs(l_table_index).C_ext_attr18
      , P_old_ext_attrs(l_table_index).C_ext_attr19
      , P_old_ext_attrs(l_table_index).C_ext_attr20
      , P_old_ext_attrs(l_table_index).C_ext_attr21
      , P_old_ext_attrs(l_table_index).C_ext_attr22
      , P_old_ext_attrs(l_table_index).C_ext_attr23
      , P_old_ext_attrs(l_table_index).C_ext_attr24
      , P_old_ext_attrs(l_table_index).C_ext_attr25
      , P_old_ext_attrs(l_table_index).C_ext_attr26
      , P_old_ext_attrs(l_table_index).C_ext_attr27
      , P_old_ext_attrs(l_table_index).C_ext_attr28
      , P_old_ext_attrs(l_table_index).C_ext_attr29
      , P_old_ext_attrs(l_table_index).C_ext_attr30
      , P_old_ext_attrs(l_table_index).C_ext_attr31
      , P_old_ext_attrs(l_table_index).C_ext_attr32
      , P_old_ext_attrs(l_table_index).C_ext_attr33
      , P_old_ext_attrs(l_table_index).C_ext_attr34
      , P_old_ext_attrs(l_table_index).C_ext_attr35
      , P_old_ext_attrs(l_table_index).C_ext_attr36
      , P_old_ext_attrs(l_table_index).C_ext_attr37
      , P_old_ext_attrs(l_table_index).C_ext_attr38
      , P_old_ext_attrs(l_table_index).C_ext_attr39
      , P_old_ext_attrs(l_table_index).C_ext_attr40
      , P_old_ext_attrs(l_table_index).C_ext_attr41
      , P_old_ext_attrs(l_table_index).C_ext_attr42
      , P_old_ext_attrs(l_table_index).C_ext_attr43
      , P_old_ext_attrs(l_table_index).C_ext_attr44
      , P_old_ext_attrs(l_table_index).C_ext_attr45
      , P_old_ext_attrs(l_table_index).C_ext_attr46
      , P_old_ext_attrs(l_table_index).C_ext_attr47
      , P_old_ext_attrs(l_table_index).C_ext_attr48
      , P_old_ext_attrs(l_table_index).C_ext_attr49
      , P_old_ext_attrs(l_table_index).C_ext_attr50
      , P_new_ext_attrs(l_table_index).N_ext_attr1
      , P_new_ext_attrs(l_table_index).N_ext_attr2
      , P_new_ext_attrs(l_table_index).N_ext_attr3
      , P_new_ext_attrs(l_table_index).N_ext_attr4
      , P_new_ext_attrs(l_table_index).N_ext_attr5
      , P_new_ext_attrs(l_table_index).N_ext_attr6
      , P_new_ext_attrs(l_table_index).N_ext_attr7
      , P_new_ext_attrs(l_table_index).N_ext_attr8
      , P_new_ext_attrs(l_table_index).N_ext_attr9
      , P_new_ext_attrs(l_table_index).N_ext_attr10
      , P_new_ext_attrs(l_table_index).N_ext_attr11
      , P_new_ext_attrs(l_table_index).N_ext_attr12
      , P_new_ext_attrs(l_table_index).N_ext_attr13
      , P_new_ext_attrs(l_table_index).N_ext_attr14
      , P_new_ext_attrs(l_table_index).N_ext_attr15
      , P_new_ext_attrs(l_table_index).N_ext_attr16
      , P_new_ext_attrs(l_table_index).N_ext_attr17
      , P_new_ext_attrs(l_table_index).N_ext_attr18
      , P_new_ext_attrs(l_table_index).N_ext_attr19
      , P_new_ext_attrs(l_table_index).N_ext_attr20
      , P_new_ext_attrs(l_table_index).N_ext_attr21
      , P_new_ext_attrs(l_table_index).N_ext_attr22
      , P_new_ext_attrs(l_table_index).N_ext_attr23
      , P_new_ext_attrs(l_table_index).N_ext_attr24
      , P_new_ext_attrs(l_table_index).N_ext_attr25
      , P_old_ext_attrs(l_table_index).N_ext_attr1
      , P_old_ext_attrs(l_table_index).N_ext_attr2
      , P_old_ext_attrs(l_table_index).N_ext_attr3
      , P_old_ext_attrs(l_table_index).N_ext_attr4
      , P_old_ext_attrs(l_table_index).N_ext_attr5
      , P_old_ext_attrs(l_table_index).N_ext_attr6
      , P_old_ext_attrs(l_table_index).N_ext_attr7
      , P_old_ext_attrs(l_table_index).N_ext_attr8
      , P_old_ext_attrs(l_table_index).N_ext_attr9
      , P_old_ext_attrs(l_table_index).N_ext_attr10
      , P_old_ext_attrs(l_table_index).N_ext_attr11
      , P_old_ext_attrs(l_table_index).N_ext_attr12
      , P_old_ext_attrs(l_table_index).N_ext_attr13
      , P_old_ext_attrs(l_table_index).N_ext_attr14
      , P_old_ext_attrs(l_table_index).N_ext_attr15
      , P_old_ext_attrs(l_table_index).N_ext_attr16
      , P_old_ext_attrs(l_table_index).N_ext_attr17
      , P_old_ext_attrs(l_table_index).N_ext_attr18
      , P_old_ext_attrs(l_table_index).N_ext_attr19
      , P_old_ext_attrs(l_table_index).N_ext_attr20
      , P_old_ext_attrs(l_table_index).N_ext_attr21
      , P_old_ext_attrs(l_table_index).N_ext_attr22
      , P_old_ext_attrs(l_table_index).N_ext_attr23
      , P_old_ext_attrs(l_table_index).N_ext_attr24
      , P_old_ext_attrs(l_table_index).N_ext_attr25
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR1
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR2
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR3
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR4
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR5
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR6
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR7
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR8
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR9
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR10
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR11
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR12
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR13
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR14
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR15
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR16
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR17
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR18
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR19
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR20
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR21
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR22
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR23
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR24
      , P_new_ext_attrs(l_table_index).D_EXT_ATTR25
      , P_old_ext_attrs(l_table_index).D_ext_attr1
      , P_old_ext_attrs(l_table_index).D_ext_attr2
      , P_old_ext_attrs(l_table_index).D_ext_attr3
      , P_old_ext_attrs(l_table_index).D_ext_attr4
      , P_old_ext_attrs(l_table_index).D_ext_attr5
      , P_old_ext_attrs(l_table_index).D_ext_attr6
      , P_old_ext_attrs(l_table_index).D_ext_attr7
      , P_old_ext_attrs(l_table_index).D_ext_attr8
      , P_old_ext_attrs(l_table_index).D_ext_attr9
      , P_old_ext_attrs(l_table_index).D_ext_attr10
      , P_old_ext_attrs(l_table_index).D_ext_attr11
      , P_old_ext_attrs(l_table_index).D_ext_attr12
      , P_old_ext_attrs(l_table_index).D_ext_attr13
      , P_old_ext_attrs(l_table_index).D_ext_attr14
      , P_old_ext_attrs(l_table_index).D_ext_attr15
      , P_old_ext_attrs(l_table_index).D_ext_attr16
      , P_old_ext_attrs(l_table_index).D_ext_attr17
      , P_old_ext_attrs(l_table_index).D_ext_attr18
      , P_old_ext_attrs(l_table_index).D_ext_attr19
      , P_old_ext_attrs(l_table_index).D_ext_attr20
      , P_old_ext_attrs(l_table_index).D_ext_attr21
      , P_old_ext_attrs(l_table_index).D_ext_attr22
      , P_old_ext_attrs(l_table_index).D_ext_attr23
      , P_old_ext_attrs(l_table_index).D_ext_attr24
      , P_old_ext_attrs(l_table_index).D_ext_attr25
      , P_new_ext_attrs(l_table_index).UOM_ext_attr1
      , P_new_ext_attrs(l_table_index).UOM_ext_attr2
      , P_new_ext_attrs(l_table_index).UOM_ext_attr3
      , P_new_ext_attrs(l_table_index).UOM_ext_attr4
      , P_new_ext_attrs(l_table_index).UOM_ext_attr5
      , P_new_ext_attrs(l_table_index).UOM_ext_attr6
      , P_new_ext_attrs(l_table_index).UOM_ext_attr7
      , P_new_ext_attrs(l_table_index).UOM_ext_attr8
      , P_new_ext_attrs(l_table_index).UOM_ext_attr9
      , P_new_ext_attrs(l_table_index).UOM_ext_attr10
      , P_new_ext_attrs(l_table_index).UOM_ext_attr11
      , P_new_ext_attrs(l_table_index).UOM_ext_attr12
      , P_new_ext_attrs(l_table_index).UOM_ext_attr13
      , P_new_ext_attrs(l_table_index).UOM_ext_attr14
      , P_new_ext_attrs(l_table_index).UOM_ext_attr15
      , P_new_ext_attrs(l_table_index).UOM_ext_attr16
      , P_new_ext_attrs(l_table_index).UOM_ext_attr17
      , P_new_ext_attrs(l_table_index).UOM_ext_attr18
      , P_new_ext_attrs(l_table_index).UOM_ext_attr19
      , P_new_ext_attrs(l_table_index).UOM_ext_attr20
      , P_new_ext_attrs(l_table_index).UOM_ext_attr21
      , P_new_ext_attrs(l_table_index).UOM_ext_attr22
      , P_new_ext_attrs(l_table_index).UOM_ext_attr23
      , P_new_ext_attrs(l_table_index).UOM_ext_attr24
      , P_new_ext_attrs(l_table_index).UOM_ext_attr25
      , P_old_ext_attrs(l_table_index).UOM_ext_attr1
      , P_old_ext_attrs(l_table_index).UOM_ext_attr2
      , P_old_ext_attrs(l_table_index).UOM_ext_attr3
      , P_old_ext_attrs(l_table_index).UOM_ext_attr4
      , P_old_ext_attrs(l_table_index).UOM_ext_attr5
      , P_old_ext_attrs(l_table_index).UOM_ext_attr6
      , P_old_ext_attrs(l_table_index).UOM_ext_attr7
      , P_old_ext_attrs(l_table_index).UOM_ext_attr8
      , P_old_ext_attrs(l_table_index).UOM_ext_attr9
      , P_old_ext_attrs(l_table_index).UOM_ext_attr10
      , P_old_ext_attrs(l_table_index).UOM_ext_attr11
      , P_old_ext_attrs(l_table_index).UOM_ext_attr12
      , P_old_ext_attrs(l_table_index).UOM_ext_attr13
      , P_old_ext_attrs(l_table_index).UOM_ext_attr14
      , P_old_ext_attrs(l_table_index).UOM_ext_attr15
      , P_old_ext_attrs(l_table_index).UOM_ext_attr16
      , P_old_ext_attrs(l_table_index).UOM_ext_attr17
      , P_old_ext_attrs(l_table_index).UOM_ext_attr18
      , P_old_ext_attrs(l_table_index).UOM_ext_attr19
      , P_old_ext_attrs(l_table_index).UOM_ext_attr20
      , P_old_ext_attrs(l_table_index).UOM_ext_attr21
      , P_old_ext_attrs(l_table_index).UOM_ext_attr22
      , P_old_ext_attrs(l_table_index).UOM_ext_attr23
      , P_old_ext_attrs(l_table_index).UOM_ext_attr24
      , P_old_ext_attrs(l_table_index).UOM_ext_attr25
      , TO_NUMBER(P_new_ext_attrs(l_table_index).pk_column_2)
      , TO_NUMBER(P_old_ext_attrs(l_table_index).pk_column_2)
      , P_new_ext_attrs(l_table_index).pk_column_3
      , P_new_ext_attrs(l_table_index).pk_column_4
      , l_modified_on
      , l_modified_by
      );

    END LOOP;

  END IF ;    -- no records in the table.


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MESSAGE.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    FND_MESSAGE.set_token('P_TEXT','cs_sr_ext_attr_data_pvt.insert_sr_row'||'-'||substr(SQLERRM,1,200));
    FND_MSG_PUB.ADD;
    FND_MSG_PUB.Count_And_Get
    ( p_count => x_msg_count
    , p_data  => x_msg_data
    );

END insert_pr_row;

PROCEDURE GET_MULTI_ROW_UNIQUE_KEY(p_attr_group_name IN VARCHAR2
                                  ,p_attr_group_type IN VARCHAR2
                                  ,p_application_id IN NUMBER
                                  ,x_attr_name OUT NOCOPY VARCHAR2
                                  ,x_database_column OUT NOCOPY VARCHAR2) IS

Cursor c_get_unique_key (p_attr_group_name IN NUMBER,
                         p_attr_group_type IN NUMBER,
                         p_application_id IN NUMBER) IS
select attr_name, database_column
  from ego_attrs_v
where attr_group_name = p_attr_group_name
  and attr_group_type = p_attr_group_type
  and application_id =  p_application_id
  and unique_key_flag = 'Y';

BEGIN

OPEN c_get_unique_key (p_attr_group_name
                      ,p_attr_group_type
                      ,p_application_id);
FETCH c_get_unique_key INTO x_attr_name, x_database_column;
CLOSE c_get_unique_key;

EXCEPTION

WHEN OTHERS THEN
  --MAYA NEED TO CODE
  null;

END GET_MULTI_ROW_UNIQUE_KEY;

PROCEDURE INIT_AUDIT_REC(p_count IN NUMBER,
        p_audit_rec IN OUT NOCOPY Ext_Attr_Audit_Tbl_Type) IS


BEGIN

FOR i IN 1 .. p_count LOOP

  p_audit_rec(i) := NULL;

END LOOP;

END INIT_AUDIT_REC;


-- -----------------------------------------------------------------------------
-- Procedure Name : Log_EGO_EXT_Parameters
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    : Procedure to LOG the in parameters of PVT SR Ext Attrs procedures
--
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 11/08/05 mviswana   Created
-- -----------------------------------------------------------------------------
PROCEDURE Log_EGO_Ext_PVT_Parameters(
                p_ext_attr_grp_tbl        IN     EGO_USER_ATTR_ROW_TABLE
               ,p_ext_attr_tbl            IN     EGO_USER_ATTR_DATA_TABLE)

IS

  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Get_SR_Ext_Attrs';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_attr_grp_index     BINARY_INTEGER;
  l_attr_index         BINARY_INTEGER;

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN
    -- For Attribute Group
    l_attr_grp_index := p_ext_attr_grp_tbl.FIRST;
    WHILE l_attr_grp_index IS NOT NULL LOOP

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'row_identifier             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).row_identifier
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_id             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).ATTR_GROUP_ID
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_app_id             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).ATTR_GROUP_APP_ID
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_type             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).ATTR_GROUP_TYPE
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_name              	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).ATTR_GROUP_NAME
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'data_level_1	             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).DATA_LEVEL_1
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'data_level_2	             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).DATA_LEVEL_2
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'data_level_3	             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).DATA_LEVEL_3
        );

	FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'transaction_type	             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).TRANSACTION_TYPE
        );

    END LOOP;

    l_attr_index := p_ext_attr_tbl.FIRST;
    WHILE l_attr_index IS NOT NULL LOOP

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'row_identifier             	:' || p_ext_attr_tbl(l_attr_index).row_identifier
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_name             	:' || p_ext_attr_tbl(l_attr_index).ATTR_NAME
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_str             	:' || p_ext_attr_tbl(l_attr_index).ATTR_VALUE_STR
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_num             	:' || p_ext_attr_tbl(l_attr_index).ATTR_VALUE_NUM
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_date             	:' || p_ext_attr_tbl(l_attr_index).ATTR_VALUE_DATE
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_display             	:' || p_ext_attr_tbl(l_attr_index).ATTR_DISP_VALUE
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_uom		            	:' || p_ext_attr_tbl(l_attr_index).ATTR_UNIT_OF_MEASURE
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_row_id		            	:' || p_ext_attr_tbl(l_attr_index).USER_ROW_IDENTIFIER
        );

    END LOOP;

  END IF;
END;


-- -----------------------------------------------------------------------------
-- Procedure Name : Log_EXT_PVT_Parameters
-- Parameters     :
-- IN             :
-- OUT            :
--
-- Description    : Procedure to LOG the in parameters of PVT SR Ext Attrs procedures
--
--
-- Modification History:
-- Date     Name     Desc
-- -------- -------- -----------------------------------------------------------
-- 11/08/05 mviswana   Created
-- -----------------------------------------------------------------------------
PROCEDURE Log_EXT_PVT_Parameters (
          p_ext_attr_grp_tbl   IN CS_ServiceRequest_PUB.EXT_ATTR_GRP_TBL_TYPE
         ,p_ext_attr_tbl       IN CS_ServiceRequest_PUB.EXT_ATTR_TBL_TYPE )
IS

  l_api_name	       CONSTANT	VARCHAR2(30)	:= 'Process_SR_Ext_Attrs';
  l_api_name_full      CONSTANT	VARCHAR2(61)	:= G_PKG_NAME||'.'||l_api_name;
  l_log_module         CONSTANT VARCHAR2(255)   := 'cs.plsql.' || l_api_name_full || '.';
  l_attr_grp_index     BINARY_INTEGER;
  l_attr_index         BINARY_INTEGER;

BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level THEN

    -- For Attribute Group
    l_attr_grp_index := p_ext_attr_grp_tbl.FIRST;
    WHILE l_attr_grp_index IS NOT NULL LOOP

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'row_identifier             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).row_identifier
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'pk_column_1             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).pk_column_1
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'pk_column_2             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).pk_column_2
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'pk_column_3             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).pk_column_3
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'pk_column_4             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).pk_column_4
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'pk_column_5             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).pk_column_5
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'context             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).context
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'object_name             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).object_name
        );

      FND_LOG.String
        ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_id             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).attr_group_id
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_app_id             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).attr_group_app_id
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_type             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).attr_group_type
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_name             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).attr_group_name
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_group_disp_name             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).attr_group_disp_name
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'mapping_req             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).mapping_req
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'operation             	:' ||  p_ext_attr_grp_tbl(l_attr_grp_index).operation
        );
      l_attr_grp_index := p_ext_attr_grp_tbl.NEXT(l_attr_grp_index);
    END LOOP;

    -- For Attribute
    l_attr_index := p_ext_attr_tbl.FIRST;
    WHILE l_attr_index IS NOT NULL LOOP

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'row_identifier             	:' || p_ext_attr_tbl(l_attr_index).row_identifier
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'column_name             	:' || p_ext_attr_tbl(l_attr_index).column_name
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_name             	:' || p_ext_attr_tbl(l_attr_index).attr_name
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_disp_name             	:' || p_ext_attr_tbl(l_attr_index).attr_disp_name
        );


      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_str             	:' || p_ext_attr_tbl(l_attr_index).attr_value_str
        );

      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_num             	:' || p_ext_attr_tbl(l_attr_index).attr_value_num
        );


      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_date             	:' || p_ext_attr_tbl(l_attr_index).attr_value_date
        );


      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_value_display             	:' || p_ext_attr_tbl(l_attr_index).attr_value_display
        );


      FND_LOG.String
         ( FND_LOG.level_procedure , L_LOG_MODULE || ''
         , 'attr_unit_of_measure             	:' || p_ext_attr_tbl(l_attr_index).attr_unit_of_measure
        );

      l_attr_index := p_ext_attr_tbl.NEXT(l_attr_index);

    END LOOP;
  END IF;


END;
-- -----------------------------------------------------------------------------
-- Procedure Name : delete_old_context
-- Parameter      :
-- IN             : p_pk_column_1        primary key column # 1
--                : p_context            Extensible attribute context. This is
--                                       value of context being overwritten
-- OUT            : x_return_status      Indicates success or error condition
--                                       encountered by the procedure
--                : x_msg_data           Error message
--                : x_msg_count          Number of error messages
--                : x_errorcode          Error code returned by PLM API
--                : x_failed_row_id_list List of row identifers that failed
--                  PLM processing
-- Description    : This procedure takes incident id and Extensible attribute
--                  context and deletes extensible attribute record
--
-- Modification History
-- Date     Name     Description
-- -------- -------- -----------------------------------------------------------
-- 09/29/05 smisra   Created
-- -------- -------- -----------------------------------------------------------
PROCEDURE delete_old_context
( p_pk_column_1         IN         NUMBER
, p_context             IN         NUMBER
, x_failed_row_id_list  OUT NOCOPY VARCHAR2
, x_return_status       OUT NOCOPY VARCHAR2
, x_errorcode           OUT NOCOPY NUMBER
, x_msg_count           OUT NOCOPY NUMBER
, x_msg_data            OUT NOCOPY VARCHAR2
) IS
--
l_pk_name_value_pair          EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_class_code_name_value_pairs EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_user_privileges_on_object   EGO_VARCHAR_TBL_TYPE;
l_user_attr_data_table        EGO_USER_ATTR_DATA_TABLE;
l_user_attr_row_table         EGO_USER_ATTR_ROW_TABLE;
l_count                       NUMBER;
--
CURSOR c_get_old_context_value
( p_incident_id IN NUMBER
, p_context     IN NUMBER
) IS
SELECT
 attr_group_id
FROM   cs_incidents_ext
WHERE incident_id = p_incident_id
  AND context     = p_context
;
--
BEGIN
  l_count := 0;

  --DBMS_OUTPUT.PUT_LINE('Delete Old Context');

  --get all the values in the database for the old context
  FOR v_get_old_context_value IN c_get_old_context_value
                                 ( p_pk_column_1
                                 , p_context
                                 )
  LOOP
    --DBMS_OUTPUT.PUT_LINE('v_get_old_context_value.attr_group_id'||v_get_old_context_value.attr_group_id);

    l_count := l_count + 1;
    --set the primary key identifiers to pass to PLM
    --populating the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing primary key to PLM
    l_pk_name_value_pair := EGO_COL_NAME_VALUE_PAIR_ARRAY
                            ( EGO_COL_NAME_VALUE_PAIR_OBJ
                              ( 'INCIDENT_ID'
                              , p_pk_column_1
                              )
                            );

    --set the context to pass to PLM only SR_TYPE_ID
    --populate the EGO_COL_NAME_VALUE_PAIR_ARRAY Array for passing the context.
    l_class_code_name_value_pairs := EGO_COL_NAME_VALUE_PAIR_ARRAY
                                     ( EGO_COL_NAME_VALUE_PAIR_OBJ
                                       ( 'CONTEXT'
                                       , p_context
                                       )
                                     );

          --Instanciate a new EGO_USER_ATTR_ROW_OBJ (only once)
    IF l_user_attr_row_table IS NULL
    THEN
      l_user_attr_row_table := EGO_USER_ATTR_ROW_TABLE();
    END IF;

    --Extend the object to add value it it
    l_user_attr_row_table.EXTEND();
/*
    l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTR_ROW_OBJ
                                                         ( l_count
                                                         , v_get_old_context_value.attr_group_id
                                                         , NULL
                                                         , NULL
                                                         , NULL
                                                         , 'GENERIC_LEVEL'
                                                         , NULL
                                                         , NULL
                                                         , EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE
                                                         );
  */

l_user_attr_row_table(l_user_attr_row_table.LAST) := EGO_USER_ATTRS_DATA_PUB.Build_Attr_Group_Row_Object(l_count, v_get_old_context_value.attr_group_id,
                                                NULL,NULL,NULL,'GENERIC_LEVEL', NULL, NULL,NULL,NULL,NULL, EGO_USER_ATTRS_DATA_PVT.G_DELETE_MODE);
  END LOOP;
  -- Instantiate the attribute table once
  l_user_attr_data_table := EGO_USER_ATTR_DATA_TABLE();

  --DBMS_OUTPUT.PUT_LINE('Calling to delete data, user attr row table count:'|| l_user_attr_row_table.count);

  --Call PLM for deleting the old data
  EGO_USER_ATTRS_DATA_PUB.Process_User_Attrs_Data
  ( p_api_version                   =>  1
  , p_object_name                   =>  'CS_SERVICE_REQUEST'
  , p_attributes_row_table          =>  l_user_attr_row_table
  , p_attributes_data_table         =>  l_user_attr_data_table
  , p_pk_column_name_value_pairs    =>  l_pk_name_value_pair
  , p_class_code_name_value_pairs   =>  l_class_code_name_value_pairs
  , p_user_privileges_on_object     =>  l_user_privileges_on_object
  , p_entity_id                     =>  NULL
  , p_entity_index                  =>  NULL
  , p_entity_code                   =>  NULL
  , p_debug_level                   =>  3
  , p_init_error_handler            =>  FND_API.G_TRUE
  , p_write_to_concurrent_log       =>  FND_API.G_TRUE
  , p_init_fnd_msg_list             =>  FND_API.G_FALSE
  , p_log_errors                    =>  FND_API.G_TRUE
  , p_add_errors_to_fnd_stack       =>  FND_API.G_TRUE
  , p_commit                        =>  FND_API.G_FALSE
  , x_failed_row_id_list            =>  x_failed_row_id_list
  , x_return_status                 =>  x_return_status
  , x_errorcode                     =>  x_errorcode
  , x_msg_count                     =>  x_msg_count
  , x_msg_data                      =>  x_msg_data
  );

--
EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;




-------------------------------------------------------------------------------
-- Procedure Name : Populate_Ext_Attr_Audit_Tbl
-- Parameters     :
-- IN             : P_EXTENSION_ID
-- OUT            : X_EXT_ATTRS_TBL
--
-- Description : Procedure to populate ext. attr. audit table structure for a given extension_id.
--
-- Modification History:
-- Date     Name     Desc
-------- -------- --------------------------------------------------------------
-- 11/21/2005   spusegao Created
--------------------------------------------------------------------------------
PROCEDURE Populate_Ext_Attr_Audit_Tbl
( P_EXTENSION_ID    IN        NUMBER
, X_EXT_ATTRS_TBL  OUT NOCOPY Ext_Attr_Audit_Tbl_Type
, X_RETURN_STATUS  OUT NOCOPY VARCHAR2
, X_MSG_COUNT      OUT NOCOPY NUMBER
, X_MSG_DATA       OUT NOCOPY VARCHAR2) IS

-- Cursor to get the ext.attrs. details for the passed extension_id.

   CURSOR c_get_ext_attrs IS
   SELECT *
     FROM cs_sr_contacts_EXT
    WHERE extension_Id = p_extension_id;

   i   NUMBER := 0 ;

BEGIN
    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    -- Get all the ext attrs records for passed extension_id

       FOR c_get_ext_attrs_rec IN c_get_ext_attrs
           LOOP
            i := 1 ;

            X_EXT_ATTRS_TBL(i).EXTENSION_ID             := c_get_ext_attrs_rec.EXTENSION_ID   ;
            X_EXT_ATTRS_TBL(i).PK_COLUMN_1              := c_get_ext_attrs_rec.INCIDENT_ID    ;
            X_EXT_ATTRS_TBL(i).PK_COLUMN_2              := c_get_ext_attrs_rec.PARTY_ID       ;
            X_EXT_ATTRS_TBL(i).PK_COLUMN_3              := c_get_ext_attrs_rec.CONTACT_TYPE   ;
            X_EXT_ATTRS_TBL(i).PK_COLUMN_4              := c_get_ext_attrs_rec.PARTY_ROLE_CODE;
            X_EXT_ATTRS_TBL(i).CONTEXT                  := c_get_ext_attrs_rec.CONTEXT        ;
            X_EXT_ATTRS_TBL(i).ATTR_GROUP_ID            := c_get_ext_attrs_rec.ATTR_GROUP_ID  ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR1              := c_get_ext_attrs_rec.C_EXT_ATTR1   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR2              := c_get_ext_attrs_rec.C_EXT_ATTR2   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR3              := c_get_ext_attrs_rec.C_EXT_ATTR3   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR4              := c_get_ext_attrs_rec.C_EXT_ATTR4   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR5              := c_get_ext_attrs_rec.C_EXT_ATTR5   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR6              := c_get_ext_attrs_rec.C_EXT_ATTR6   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR7              := c_get_ext_attrs_rec.C_EXT_ATTR7   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR8              := c_get_ext_attrs_rec.C_EXT_ATTR8   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR9              := c_get_ext_attrs_rec.C_EXT_ATTR9   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR10             := c_get_ext_attrs_rec.C_EXT_ATTR10  ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR11             := c_get_ext_attrs_rec.C_EXT_ATTR11   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR12             := c_get_ext_attrs_rec.C_EXT_ATTR12   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR13             := c_get_ext_attrs_rec.C_EXT_ATTR13   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR14             := c_get_ext_attrs_rec.C_EXT_ATTR14   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR15             := c_get_ext_attrs_rec.C_EXT_ATTR15   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR16             := c_get_ext_attrs_rec.C_EXT_ATTR16   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR17             := c_get_ext_attrs_rec.C_EXT_ATTR17   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR18             := c_get_ext_attrs_rec.C_EXT_ATTR18   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR19             := c_get_ext_attrs_rec.C_EXT_ATTR19   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR20             := c_get_ext_attrs_rec.C_EXT_ATTR20   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR21             := c_get_ext_attrs_rec.C_EXT_ATTR21   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR22             := c_get_ext_attrs_rec.C_EXT_ATTR22   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR23             := c_get_ext_attrs_rec.C_EXT_ATTR23   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR24             := c_get_ext_attrs_rec.C_EXT_ATTR24   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR25             := c_get_ext_attrs_rec.C_EXT_ATTR25   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR26             := c_get_ext_attrs_rec.C_EXT_ATTR26   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR27             := c_get_ext_attrs_rec.C_EXT_ATTR27   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR28             := c_get_ext_attrs_rec.C_EXT_ATTR28   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR29             := c_get_ext_attrs_rec.C_EXT_ATTR29   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR30             := c_get_ext_attrs_rec.C_EXT_ATTR30   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR31             := c_get_ext_attrs_rec.C_EXT_ATTR31   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR32             := c_get_ext_attrs_rec.C_EXT_ATTR32   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR33             := c_get_ext_attrs_rec.C_EXT_ATTR33   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR34             := c_get_ext_attrs_rec.C_EXT_ATTR34   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR35             := c_get_ext_attrs_rec.C_EXT_ATTR35   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR36             := c_get_ext_attrs_rec.C_EXT_ATTR36   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR37             := c_get_ext_attrs_rec.C_EXT_ATTR37   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR38             := c_get_ext_attrs_rec.C_EXT_ATTR38   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR39             := c_get_ext_attrs_rec.C_EXT_ATTR39   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR40             := c_get_ext_attrs_rec.C_EXT_ATTR40   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR41             := c_get_ext_attrs_rec.C_EXT_ATTR41   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR42             := c_get_ext_attrs_rec.C_EXT_ATTR42   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR43             := c_get_ext_attrs_rec.C_EXT_ATTR43   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR44             := c_get_ext_attrs_rec.C_EXT_ATTR44   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR45             := c_get_ext_attrs_rec.C_EXT_ATTR45   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR46             := c_get_ext_attrs_rec.C_EXT_ATTR46   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR47             := c_get_ext_attrs_rec.C_EXT_ATTR47   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR48             := c_get_ext_attrs_rec.C_EXT_ATTR48   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR49             := c_get_ext_attrs_rec.C_EXT_ATTR49   ;
            X_EXT_ATTRS_TBL(i).C_EXT_ATTR50             := c_get_ext_attrs_rec.C_EXT_ATTR50   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR1              := c_get_ext_attrs_rec.N_EXT_ATTR1    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR2              := c_get_ext_attrs_rec.N_EXT_ATTR2    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR3              := c_get_ext_attrs_rec.N_EXT_ATTR3    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR4              := c_get_ext_attrs_rec.N_EXT_ATTR4    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR5              := c_get_ext_attrs_rec.N_EXT_ATTR5    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR6              := c_get_ext_attrs_rec.N_EXT_ATTR6    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR7              := c_get_ext_attrs_rec.N_EXT_ATTR7    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR8              := c_get_ext_attrs_rec.N_EXT_ATTR8    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR9              := c_get_ext_attrs_rec.N_EXT_ATTR9    ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR10             := c_get_ext_attrs_rec.N_EXT_ATTR10   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR11             := c_get_ext_attrs_rec.N_EXT_ATTR11   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR12             := c_get_ext_attrs_rec.N_EXT_ATTR12   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR13             := c_get_ext_attrs_rec.N_EXT_ATTR13   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR14             := c_get_ext_attrs_rec.N_EXT_ATTR14   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR15             := c_get_ext_attrs_rec.N_EXT_ATTR15   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR16             := c_get_ext_attrs_rec.N_EXT_ATTR16   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR17             := c_get_ext_attrs_rec.N_EXT_ATTR17   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR18             := c_get_ext_attrs_rec.N_EXT_ATTR18   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR19             := c_get_ext_attrs_rec.N_EXT_ATTR19   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR20             := c_get_ext_attrs_rec.N_EXT_ATTR20   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR21             := c_get_ext_attrs_rec.N_EXT_ATTR21   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR22             := c_get_ext_attrs_rec.N_EXT_ATTR22   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR23             := c_get_ext_attrs_rec.N_EXT_ATTR23   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR24             := c_get_ext_attrs_rec.N_EXT_ATTR24   ;
            X_EXT_ATTRS_TBL(i).N_EXT_ATTR25             := c_get_ext_attrs_rec.N_EXT_ATTR25   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR1              := c_get_ext_attrs_rec.D_EXT_ATTR1    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR2              := c_get_ext_attrs_rec.D_EXT_ATTR2    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR3              := c_get_ext_attrs_rec.D_EXT_ATTR3    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR4              := c_get_ext_attrs_rec.D_EXT_ATTR4    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR5              := c_get_ext_attrs_rec.D_EXT_ATTR5    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR6              := c_get_ext_attrs_rec.D_EXT_ATTR6    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR7              := c_get_ext_attrs_rec.D_EXT_ATTR7    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR8              := c_get_ext_attrs_rec.D_EXT_ATTR8    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR9              := c_get_ext_attrs_rec.D_EXT_ATTR9    ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR10             := c_get_ext_attrs_rec.D_EXT_ATTR10   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR11             := c_get_ext_attrs_rec.D_EXT_ATTR11   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR12             := c_get_ext_attrs_rec.D_EXT_ATTR12   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR13             := c_get_ext_attrs_rec.D_EXT_ATTR13   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR14             := c_get_ext_attrs_rec.D_EXT_ATTR14   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR15             := c_get_ext_attrs_rec.D_EXT_ATTR15   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR16             := c_get_ext_attrs_rec.D_EXT_ATTR16   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR17             := c_get_ext_attrs_rec.D_EXT_ATTR17   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR18             := c_get_ext_attrs_rec.D_EXT_ATTR18   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR19             := c_get_ext_attrs_rec.D_EXT_ATTR19   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR20             := c_get_ext_attrs_rec.D_EXT_ATTR20   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR21             := c_get_ext_attrs_rec.D_EXT_ATTR21   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR22             := c_get_ext_attrs_rec.D_EXT_ATTR22   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR23             := c_get_ext_attrs_rec.D_EXT_ATTR23   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR24             := c_get_ext_attrs_rec.D_EXT_ATTR24   ;
            X_EXT_ATTRS_TBL(i).D_EXT_ATTR25             := c_get_ext_attrs_rec.D_EXT_ATTR25   ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR1            := c_get_ext_attrs_rec.UOM_EXT_ATTR1  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR2            := c_get_ext_attrs_rec.UOM_EXT_ATTR2  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR3            := c_get_ext_attrs_rec.UOM_EXT_ATTR3  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR4            := c_get_ext_attrs_rec.UOM_EXT_ATTR4  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR5            := c_get_ext_attrs_rec.UOM_EXT_ATTR5  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR6            := c_get_ext_attrs_rec.UOM_EXT_ATTR6  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR7            := c_get_ext_attrs_rec.UOM_EXT_ATTR7  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR8            := c_get_ext_attrs_rec.UOM_EXT_ATTR8  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR9            := c_get_ext_attrs_rec.UOM_EXT_ATTR9  ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR10           := c_get_ext_attrs_rec.UOM_EXT_ATTR10 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR11           := c_get_ext_attrs_rec.UOM_EXT_ATTR11 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR12           := c_get_ext_attrs_rec.UOM_EXT_ATTR12 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR13           := c_get_ext_attrs_rec.UOM_EXT_ATTR13 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR14           := c_get_ext_attrs_rec.UOM_EXT_ATTR14 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR15           := c_get_ext_attrs_rec.UOM_EXT_ATTR15 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR16           := c_get_ext_attrs_rec.UOM_EXT_ATTR16 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR17           := c_get_ext_attrs_rec.UOM_EXT_ATTR17 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR18           := c_get_ext_attrs_rec.UOM_EXT_ATTR18 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR19           := c_get_ext_attrs_rec.UOM_EXT_ATTR19 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR20           := c_get_ext_attrs_rec.UOM_EXT_ATTR20 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR21           := c_get_ext_attrs_rec.UOM_EXT_ATTR21 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR22           := c_get_ext_attrs_rec.UOM_EXT_ATTR22 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR23           := c_get_ext_attrs_rec.UOM_EXT_ATTR23 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR24           := c_get_ext_attrs_rec.UOM_EXT_ATTR24 ;
            X_EXT_ATTRS_TBL(i).UOM_EXT_ATTR25           := c_get_ext_attrs_rec.UOM_EXT_ATTR25 ;

            i := i + 1 ;

           END LOOP;

EXCEPTION
     WHEN no_data_found THEN
          CS_ServiceRequest_UTIL.Add_Invalid_Argument_Msg
              (p_token_an     => 'Populate_Ext_Attr_Audit_Tbl',
	       p_token_v      => TO_CHAR(P_EXTENSION_ID),
	       p_token_p      => 'P_EXTENSION_ID' ,
               p_table_name   => 'CS_SR_CONTACTX_EXT',
               p_column_name  => 'EXTENSION_ID');

          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Populate_Ext_Attr_Audit_Tbl;

END CS_SR_EXTATTRIBUTES_PVT;

/
