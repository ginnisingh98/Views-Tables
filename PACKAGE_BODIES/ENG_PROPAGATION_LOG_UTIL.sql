--------------------------------------------------------
--  DDL for Package Body ENG_PROPAGATION_LOG_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_PROPAGATION_LOG_UTIL" AS
/*$Header: ENGVPRLB.pls 120.6 2006/01/24 03:46:26 lkasturi noship $ */

---------------------------------------------------------------
--  Global constant holding the package name                 --
---------------------------------------------------------------
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'ENG_PROPAGATION_LOG_UTIL' ;

---------------------------------------------------------------
G_ERROR_CLASSIFICATION_CODE CONSTANT VARCHAR2(10) := 'PROPAGATN';

---------------------------------------------------------------
-- API Return Status       .                                 --
---------------------------------------------------------------
G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_SUCCESS;
G_RET_STS_WARNING       CONSTANT    VARCHAR2(1) :=  'W';
G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_ERROR;
G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  FND_API.G_RET_STS_UNEXP_ERROR;

G_LOG_LEVEL             CONSTANT   NUMBER := TO_NUMBER(FND_PROFILE.Value('AFLOG_LEVEL'));
G_LOG_MODE              VARCHAR2(3);

---------------------------------------------------------------
-- Propagation Log Map Table                                 --
---------------------------------------------------------------
G_Entity_Map_Log_Table  ENG_PROPAGATION_LOG_UTIL.Entity_Map_Log_Tbl_Type;
----------------------------------------------------------
-- Write to Concurrent Log                              --
----------------------------------------------------------
PROCEDURE Developer_Debug (
    p_debug_message     IN            VARCHAR2
) IS
    l_err_msg                        VARCHAR2(240);
BEGIN
    Fnd_File.Put_Line(which => Fnd_File.LOG,
                      buff  => p_debug_message );
    --Fnd_File.New_Line(which => Fnd_File.LOG );
EXCEPTION
WHEN OTHERS THEN
    l_err_msg := SUBSTRB(SQLERRM, 1, 240);
    Fnd_File.Put_Line(which => Fnd_File.LOG,
                      buff  => l_err_msg );
END Developer_Debug;

--========================================================================
-- PROCEDURE  : Log_Initialize   PUBLIC
-- COMMENT   : Initializes the log facility. It should be called from
--             the top level procedure of each concurrent program
--=======================================================================--
PROCEDURE Log_Initialize
IS
BEGIN
    IF G_LOG_LEVEL IS NULL
    THEN
        G_LOG_MODE := 'OFF';
    ELSIF (TO_NUMBER(FND_PROFILE.Value('CONC_REQUEST_ID')) <> 0)
    THEN
        G_LOG_MODE := 'SRS';
    ELSE
         G_LOG_MODE := 'SQL';
    END IF;
END Log_Initialize;


--========================================================================
-- PROCEDURE : Log                        PUBLIC
-- PARAMETERS: p_level                IN  priority of the message - from
--                                        highest to lowest:
--                                          -- G_LOG_ERROR
--                                          -- G_LOG_EXCEPTION
--                                          -- G_LOG_EVENT
--                                          -- G_LOG_PROCEDURE
--                                          -- G_LOG_STATEMENT
--             p_msg                  IN  message to be print on the log
--                                        file
-- COMMENT   : Add an entry to the log
--=======================================================================--
PROCEDURE Debug_Log
( p_priority                    IN  NUMBER
, p_msg                         IN  VARCHAR2
)
IS
BEGIN
    --Developer_Debug(p_debug_message => p_msg);
    --Additional IF clause is added to print log message if Priority is
    --Error or Exception. Bug: 3555234
    IF ((p_priority = G_LOG_ERROR) OR
        (p_priority = G_LOG_EXCEPTION) OR
        (p_priority = G_LOG_PRINT) OR
       ((G_LOG_MODE <> 'OFF') AND (p_priority >= G_LOG_LEVEL)))
    THEN
        IF G_LOG_MODE = 'SQL'
        THEN
            -- SQL*Plus session: uncomment the next line during unit test
            -- DBMS_OUTPUT.put_line(p_msg);
            NULL;
        ELSE
            -- Concurrent request
            Developer_Debug(p_debug_message => p_msg);
        END IF;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    NULL;
END Debug_Log;


----------------------------------------------------------
-- Validate Entity Map Record                           --
----------------------------------------------------------
PROCEDURE Check_Entity_Map_Record (
    p_entity_map_rec   IN OUT NOCOPY Entity_Map_Log_Rec_Type
  , x_return_status    OUT NOCOPY    VARCHAR2
) IS
    l_local_change_id NUMBER;
BEGIN
    Debug_Log(G_LOG_PROCEDURE, 'Check_Entity_Map_Record.Begin');
    x_return_status := G_RET_STS_SUCCESS;
    IF p_entity_map_rec.change_id IS NULL
    THEN
        -- Change id cannot be null
        x_return_status := G_RET_STS_ERROR;
        Debug_Log(G_LOG_STATEMENT, 'p_entity_map_rec.change_id IS NULL x_return_status'|| x_return_status);
    ELSIF p_entity_map_rec.local_organization_id IS NULL
    THEN
        -- Local Org Id cannot be null
        x_return_status := G_RET_STS_ERROR;
        Debug_Log(G_LOG_STATEMENT, 'p_entity_map_rec.local_organization_id IS NULL x_return_status'||x_return_status);
    ELSIF p_entity_map_rec.revised_line_type IS NOT NULL AND p_entity_map_rec.revised_line_id1 IS NULL
    THEN
        -- Dependant params revised_line_type and revised_line_id1
        x_return_status := G_RET_STS_ERROR;
        Debug_Log(G_LOG_STATEMENT, 'p_entity_map_rec.revised line IS NULL x_return_status'|| x_return_status);
    END IF;

    IF x_return_status = G_RET_STS_ERROR
    THEN
        Debug_Log(G_LOG_PROCEDURE, 'Check_Entity_Map_Record.End');
        RETURN;
    END IF;

    BEGIN
        SELECT change_id
        INTO l_local_change_id
        FROM eng_engineering_changes
        WHERE change_id =
            (SELECT object_to_id1
               FROM eng_change_obj_relationships
              WHERE change_id = p_entity_map_rec.change_id
                AND (relationship_code =  'PROPAGATED_TO' OR relationship_code = 'TRANSFERRED_TO')
                AND object_to_name = 'ENG_CHANGE'
                AND object_to_id3 = p_entity_map_rec.local_organization_id);
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
        l_local_change_id := NULL;
    END;

    IF nvl(l_local_change_id, -1) <> nvl(p_entity_map_rec.local_change_id, -1)
    THEN
        -- Local Change Id is incorrect, reset to correct value
        Debug_Log(G_LOG_STATEMENT, 'Value l_local_change_id:'|| l_local_change_id);
        p_entity_map_rec.local_change_id := l_local_change_id;
    END IF;
    Debug_Log(G_LOG_PROCEDURE, 'Check_Entity_Map_Record.End');

END Check_Entity_Map_Record;

----------------------------------------------------------
-- Validate Entity Map Record                           --
----------------------------------------------------------
PROCEDURE Check_Entity_Map_Existance (
    p_change_id                IN NUMBER
  , p_entity_name              IN eng_change_propagation_maps.entity_name%TYPE
  , p_revised_item_sequence_id IN NUMBER := NULL
  , p_revised_line_type        IN eng_change_propagation_maps.revised_line_type%TYPE := NULL
  , p_revised_line_id1         IN eng_change_propagation_maps.revised_line_id1%TYPE := NULL
  , p_revised_line_id2         IN eng_change_propagation_maps.revised_line_id2%TYPE := NULL
  , p_revised_line_id3         IN eng_change_propagation_maps.revised_line_id3%TYPE := NULL
  , p_revised_line_id4         IN eng_change_propagation_maps.revised_line_id4%TYPE := NULL
  , p_revised_line_id5         IN eng_change_propagation_maps.revised_line_id5%TYPE := NULL
  , p_local_organization_id    IN NUMBER
  , x_change_map_id    OUT NOCOPY NUMBER
)
IS
  CURSOR c_check_entity_map IS
  SELECT ecpm.change_propagation_map_id
    FROM eng_change_propagation_maps ecpm
   WHERE ecpm.change_id = p_change_id
     AND ecpm.local_organization_id = p_local_organization_id
     AND ecpm.entity_name = p_entity_name
     AND nvl(ecpm.revised_item_sequence_id, -1) = nvl(p_revised_item_sequence_id, -1)
     AND nvl(ecpm.revised_line_type, '-1') = nvl(p_revised_line_type, '-1')
     AND nvl(ecpm.revised_line_id1, -1) = nvl(p_revised_line_id1, -1)
     AND nvl(ecpm.revised_line_id2, -1) = nvl(p_revised_line_id2, -1)
     AND nvl(ecpm.revised_line_id3, -1) = nvl(p_revised_line_id3, -1)
     AND nvl(ecpm.revised_line_id4, -1) = nvl(p_revised_line_id4, -1)
     AND nvl(ecpm.revised_line_id5, -1) = nvl(p_revised_line_id5, -1);
BEGIN
    -- Initialize Out variable
    x_change_map_id := null;

    -- Query for change_map_id
    OPEN c_check_entity_map;
    FETCH c_check_entity_map INTO x_change_map_id;
    CLOSE c_check_entity_map;

EXCEPTION
WHEN OTHERS THEN
    IF c_check_entity_map%ISOPEN
    THEN
        CLOSE c_check_entity_map;
    END IF;

END Check_Entity_Map_Existance;


PROCEDURE Perform_Writes_For_Entity_Map (
   p_entity_map_rec     IN OUT NOCOPY Entity_Map_Log_Rec_Type
) IS
BEGIN
    Check_Entity_Map_Existance(
        p_change_id                => p_entity_map_rec.change_id
      , p_entity_name              => p_entity_map_rec.entity_name
      , p_revised_item_sequence_id => p_entity_map_rec.revised_item_sequence_id
      , p_revised_line_type        => p_entity_map_rec.revised_line_type
      , p_revised_line_id1         => p_entity_map_rec.revised_line_id1
      , p_revised_line_id2         => p_entity_map_rec.revised_line_id2
      , p_revised_line_id3         => p_entity_map_rec.revised_line_id3
      , p_revised_line_id4         => p_entity_map_rec.revised_line_id4
      , p_revised_line_id5         => p_entity_map_rec.revised_line_id5
      , p_local_organization_id    => p_entity_map_rec.local_organization_id
      , x_change_map_id            => p_entity_map_rec.change_propagation_map_id
     );
    --
    -- If map id is fetched , then update the same record
    -- Insert a new map otherwise
    --
    IF p_entity_map_rec.change_propagation_map_id IS NOT NULL
    THEN
        UPDATE eng_change_propagation_maps
        SET local_change_id           = p_entity_map_rec.local_change_id
          , local_revised_item_sequence_id = p_entity_map_rec.local_revised_item_seq_id
          , local_revised_line_id1    = p_entity_map_rec.local_revised_line_id1
          , local_revised_line_id2    = p_entity_map_rec.local_revised_line_id2
          , local_revised_line_id3    = p_entity_map_rec.local_revised_line_id3
          , local_revised_line_id4    = p_entity_map_rec.local_revised_line_id4
          , local_revised_line_id5    = p_entity_map_rec.local_revised_line_id5
          , entity_action_status      = p_entity_map_rec.entity_action_status
          , creation_date             = SYSDATE
          , created_by                = FND_GLOBAL.USER_ID
          , last_update_date          = SYSDATE
          , last_updated_by           = FND_GLOBAL.USER_ID
          , last_update_login         = FND_GLOBAL.LOGIN_ID
          , program_id                = FND_GLOBAL.CONC_PROGRAM_ID--FND_PROFILE.value('CONC_PROGRAM_ID')
          , program_application_id    = FND_GLOBAL.PROG_APPL_ID--FND_PROFILE.value('PROG_APPL_ID')
          , program_update_date       = SYSDATE
          , request_id                = FND_GLOBAL.CONC_REQUEST_ID--FND_PROFILE.value('CONC_REQUEST_ID')
        WHERE change_propagation_map_id = p_entity_map_rec.change_propagation_map_id;
    ELSE
        SELECT eng_change_propagation_maps_s.nextval
          INTO p_entity_map_rec.change_propagation_map_id
          FROM DUAL;

        INSERT INTO eng_change_propagation_maps(
            change_propagation_map_id
          , change_id
          , revised_item_sequence_id
          , local_change_id
          , local_revised_item_sequence_id
          , local_organization_id
          , program_id
          , program_application_id
          , program_update_date
          , request_id
          , revised_line_type
          , revised_line_id1
          , revised_line_id2
          , revised_line_id3
          , revised_line_id4
          , revised_line_id5
          , local_revised_line_id1
          , local_revised_line_id2
          , local_revised_line_id3
          , local_revised_line_id4
          , local_revised_line_id5
          , entity_name
          , entity_action_status
          , creation_date
          , created_by
          , last_update_date
          , last_updated_by
          , last_update_login
          )
        VALUES(
            p_entity_map_rec.change_propagation_map_id
          , p_entity_map_rec.CHANGE_ID
          , p_entity_map_rec.revised_item_sequence_id
          , p_entity_map_rec.local_change_id
          , p_entity_map_rec.local_revised_item_seq_id
          , p_entity_map_rec.LOCAL_ORGANIZATION_ID
          , FND_GLOBAL.CONC_PROGRAM_ID--FND_PROFILE.value('CONC_PROGRAM_ID')
          , FND_GLOBAL.PROG_APPL_ID--FND_PROFILE.value('PROG_APPL_ID')
          , SYSDATE
          , FND_GLOBAL.CONC_REQUEST_ID--FND_PROFILE.value('CONC_REQUEST_ID')
          , p_entity_map_rec.revised_line_type
          , p_entity_map_rec.revised_line_id1
          , p_entity_map_rec.revised_line_id2
          , p_entity_map_rec.revised_line_id3
          , p_entity_map_rec.revised_line_id4
          , p_entity_map_rec.revised_line_id5
          , p_entity_map_rec.local_revised_line_id1
          , p_entity_map_rec.local_revised_line_id2
          , p_entity_map_rec.local_revised_line_id3
          , p_entity_map_rec.local_revised_line_id4
          , p_entity_map_rec.local_revised_line_id5
          , p_entity_map_rec.ENTITY_NAME
          , p_entity_map_rec.entity_action_status
          , SYSDATE
          , FND_GLOBAL.USER_ID
          , SYSDATE
          , FND_GLOBAL.USER_ID
          , FND_GLOBAL.LOGIN_ID
         );
    END IF;
EXCEPTION
WHEN OTHERS THEN
    null;
    Developer_Debug('Unexpected Error in Perform_Writes_For_Entity_Map'|| SQLERRM);
END Perform_Writes_For_Entity_Map;

----------------------------------------------------------
-- Write to Log Table                                   --
----------------------------------------------------------

PROCEDURE Perform_Writes_For_Log (
   p_entity_map_rec         IN            Entity_Map_Log_Rec_Type
 , p_delete_map_logs        IN            VARCHAR2 := FND_API.G_TRUE
 , x_return_status          IN OUT NOCOPY VARCHAR2
)
IS
  CURSOR c_change_logs (
      cp_change_id     NUMBER
    , cp_local_org_id  NUMBER
    , cp_change_map_id NUMBER)
  IS
  SELECT change_log_id
    FROM eng_change_logs_b
   WHERE change_id = cp_change_id
     AND local_organization_id = cp_local_org_id
     AND log_type_code <> 'INFO'
     AND FND_API.G_TRUE = p_delete_map_logs
     AND change_propagation_map_id = cp_change_map_id;

    l_new_log_id          NUMBER;
    l_val                 VARCHAR2(200);
    l_log_type_code       eng_change_logs_b.log_type_code%TYPE;
BEGIN

    --
    -- Delete Log messages if required.
    -- In future this step may have to be changed to inactivate the old log messages
    -- so as to maintain history
    --
    Debug_Log(G_LOG_PROCEDURE, 'Perform_Writes_For_Log.Begin');

    Debug_Log(G_LOG_STATEMENT, 'Delete Errors for Map p_entity_map_rec.change_propagation_map_id'|| p_entity_map_rec.change_propagation_map_id);
    FOR clog IN c_change_logs( cp_change_id     => p_entity_map_rec.change_id
                             , cp_local_org_id  => p_entity_map_rec.local_organization_id
                             , cp_change_map_id => p_entity_map_rec.change_propagation_map_id)
    LOOP

        Eng_change_logs_pkg.Delete_row (
          X_change_log_id => clog.change_log_id
         );
    END LOOP;

    --
    -- Loop through the specified message list and insert
    -- the messages corresponding to the change_map_id
    --
    FOR i IN 1..p_entity_map_rec.message_list.COUNT
    LOOP
        SELECT eng_change_logs_s.nextval
        INTO l_new_log_id
        FROM dual;
        l_log_type_code := CASE p_entity_map_rec.message_list(i).message_type
                                WHEN 'W' THEN G_LOG_TYPE_WARNING
                                WHEN 'I' THEN G_LOG_TYPE_INFO
                                ELSE G_LOG_TYPE_ERROR END;
        Debug_Log(G_LOG_STATEMENT, 'Log type code:'|| l_log_type_code);
        Debug_Log(G_LOG_STATEMENT, 'Message:'|| p_entity_map_rec.message_list(i).message_text);

        Eng_change_logs_pkg.Insert_row (
            X_rowid                         => l_val
          , X_change_log_id                 => l_new_log_id
          , X_change_id                     => p_entity_map_rec.change_id
          , X_change_line_id                => null
          , X_local_revised_item_sequence_  => p_entity_map_rec.local_revised_item_seq_id
          , X_log_classification_code       => G_ERROR_CLASSIFICATION_CODE
          , X_log_type_code                 => l_log_type_code
          , X_local_change_id               => p_entity_map_rec.local_change_id
          , X_local_change_line_id          => null
          , X_revised_item_sequence_id      => p_entity_map_rec.revised_item_sequence_id
          , X_local_organization_id         => p_entity_map_rec.local_organization_id
          , X_log_text                      => p_entity_map_rec.message_list(i).message_text
          , X_creation_date                 => SYSDATE
          , X_created_by                    => FND_GLOBAL.USER_ID
          , X_last_update_date              => SYSDATE
          , X_last_updated_by               => FND_GLOBAL.USER_ID
          , X_last_update_login             => FND_GLOBAL.LOGIN_ID
          , X_change_propagation_map_id     => p_entity_map_rec.change_propagation_map_id
          );

    END LOOP;  -- End of 1..p_message_list.COUNT
    Debug_Log(G_LOG_PROCEDURE, 'Perform_Writes_For_Log.End');
EXCEPTION
WHEN OTHERS THEN
    null;
    Developer_Debug('Unexpected Error in Perform_Writes_For_Log'|| SQLERRM);
END Perform_Writes_For_Log;


----------------------------------------------------------
-- Propagation messages Logging                         --
----------------------------------------------------------
PROCEDURE Write_Propagation_Log (
    p_entity_map_rec   IN OUT NOCOPY  Entity_Map_Log_Rec_Type
) IS
    l_return_status      VARCHAR2(1);
    l_entity_map_rec     Entity_Map_Log_Rec_Type;

BEGIN
    Debug_Log(G_LOG_PROCEDURE, 'Write_Propagation_Log.Begin');
    Debug_Log(G_LOG_STATEMENT, 'Write_Propagation_Log.Organization_id'|| p_entity_map_rec.local_organization_id);
    Debug_Log(G_LOG_STATEMENT, 'Write_Propagation_Log.Processing Entity'|| nvl(p_entity_map_rec.revised_line_type, p_entity_map_rec.entity_name));

    l_entity_map_rec := p_entity_map_rec;
    -- Check whether the Entity Map Record is Well-formed
    Check_Entity_Map_Record(
        p_entity_map_rec   => l_entity_map_rec
      , x_return_status    => l_return_status
     );

    IF l_return_status = G_RET_STS_ERROR
    THEN
        -- return processing as the entity rec is not well formed
        RETURN;
    END IF;

    Perform_Writes_For_Entity_Map(
        p_entity_map_rec     => l_entity_map_rec
     );

    Perform_Writes_For_Log(
        p_entity_map_rec     => l_entity_map_rec
      , p_delete_map_logs    => FND_API.G_TRUE
      , x_return_status      => l_return_status
     );
    Debug_Log(G_LOG_PROCEDURE, 'Write_Propagation_Log.End');
EXCEPTION
WHEN OTHERS THEN
    null;
    Debug_Log(G_LOG_ERROR, 'Write_Propagation_Log.Unexpected Error'|| SQLERRM);
END Write_Propagation_Log;

PROCEDURE Reset_Entity_Map_Record (
    p_entity_level     IN            NUMBER
  , p_entity_map_rec   IN OUT NOCOPY Entity_Map_Log_Rec_Type
) IS

BEGIN
    --
    -- Always reset change_map_id and entity_action_status
    --
    p_entity_map_rec.change_propagation_map_id := null;
    p_entity_map_rec.entity_action_status := null;

    -- Now set other attributes of the record based on the entity level
    IF p_entity_level = Error_Handler.G_BO_LEVEL
    THEN
        p_entity_map_rec.change_id := null;
    END IF;

    IF p_entity_level <= Error_Handler.G_ECO_LEVEL
    THEN
        p_entity_map_rec.local_change_id := null;
        p_entity_map_rec.local_organization_id := null;
    END IF;

    IF p_entity_level <= Error_Handler.G_RI_LEVEL
    THEN
        p_entity_map_rec.revised_item_sequence_id := null;
        p_entity_map_rec.local_revised_item_seq_id := null;
    END IF;

    IF p_entity_level <= Error_Handler.G_RC_LEVEL
    THEN
        p_entity_map_rec.revised_line_type := null;
        p_entity_map_rec.revised_line_id1 := null;
        p_entity_map_rec.revised_line_id2 := null;
        p_entity_map_rec.revised_line_id3 := null;
        p_entity_map_rec.revised_line_id4 := null;
        p_entity_map_rec.revised_line_id5 := null;
        p_entity_map_rec.local_revised_line_id1 := null;
        p_entity_map_rec.local_revised_line_id2 := null;
        p_entity_map_rec.local_revised_line_id3 := null;
        p_entity_map_rec.local_revised_line_id4 := null;
        p_entity_map_rec.local_revised_line_id5 := null;
    END IF;
    -- Delete message list
    p_entity_map_rec.message_list.DELETE;
END Reset_Entity_Map_Record;

/*********************************************************************
* Procedure     : Initialize
* Parameters    : None
* Purpose       : This procedure will initialize the global message
*                 list and reset the index variables to 0.
*                 User must initialize the message list before using
*                 it.
**********************************************************************/
PROCEDURE Initialize
IS
BEGIN
    G_Entity_Map_Log_Table.DELETE;
END Initialize;

----------------------------------------------------------
-- Propagation messages Logging                         --
----------------------------------------------------------
PROCEDURE Write_Propagation_Log IS

BEGIN

    FOR i IN 1..G_Entity_Map_Log_Table.COUNT
    LOOP
        Write_Propagation_Log(G_Entity_Map_Log_Table(i));
    END LOOP;
    Initialize;

END;

PROCEDURE Add_Entity_Map (
      p_change_id                 IN NUMBER
    , p_revised_item_sequence_id  IN NUMBER := NULL
    , p_revised_line_type         IN eng_change_propagation_maps.revised_line_type%TYPE := NULL
    , p_revised_line_id1          IN eng_change_propagation_maps.revised_line_id1%TYPE := NULL
    , p_revised_line_id2          IN eng_change_propagation_maps.revised_line_id2%TYPE := NULL
    , p_revised_line_id3          IN eng_change_propagation_maps.revised_line_id3%TYPE := NULL
    , p_revised_line_id4          IN eng_change_propagation_maps.revised_line_id4%TYPE := NULL
    , p_revised_line_id5          IN eng_change_propagation_maps.revised_line_id5%TYPE := NULL
    , p_local_organization_id     IN NUMBER
    , p_local_change_id           IN NUMBER := NULL
    , p_local_revised_item_seq_id IN NUMBER := NULL
    , p_local_revised_line_id1    IN eng_change_propagation_maps.local_revised_line_id1%TYPE := NULL
    , p_local_revised_line_id2    IN eng_change_propagation_maps.local_revised_line_id2%TYPE := NULL
    , p_local_revised_line_id3    IN eng_change_propagation_maps.local_revised_line_id3%TYPE := NULL
    , p_local_revised_line_id4    IN eng_change_propagation_maps.local_revised_line_id4%TYPE := NULL
    , p_local_revised_line_id5    IN eng_change_propagation_maps.local_revised_line_id5%TYPE := NULL
    , p_entity_name               IN eng_change_propagation_maps.entity_name%TYPE
    , p_entity_action_status      IN NUMBER
    , p_bo_entity_identifier      IN VARCHAR2
) IS
   l_Nxt_Idx      NUMBER;
   l_message_list Error_Handler.Error_Tbl_Type;
   l_Nxt_Mesg_Cnt NUMBER;
   l_error_table  Error_Handler.Error_Tbl_Type;
BEGIN
    l_Nxt_Idx := G_Entity_Map_Log_Table.COUNT+1;

    G_Entity_Map_Log_Table(l_Nxt_Idx).change_id                 := p_change_id;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_item_sequence_id  := p_revised_item_sequence_id;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_line_type         := p_revised_line_type;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_line_id1          := p_revised_line_id1;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_line_id2          := p_revised_line_id2;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_line_id3          := p_revised_line_id3;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_line_id4          := p_revised_line_id4;
    G_Entity_Map_Log_Table(l_Nxt_Idx).revised_line_id5          := p_revised_line_id5;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_organization_id     := p_local_organization_id;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_change_id           := p_local_change_id;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_revised_item_seq_id := p_local_revised_item_seq_id;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_revised_line_id1    := p_local_revised_line_id1;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_revised_line_id2    := p_local_revised_line_id2;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_revised_line_id3    := p_local_revised_line_id3;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_revised_line_id4    := p_local_revised_line_id4;
    G_Entity_Map_Log_Table(l_Nxt_Idx).local_revised_line_id5    := p_local_revised_line_id5;
    G_Entity_Map_Log_Table(l_Nxt_Idx).entity_name               := p_entity_name;
    G_Entity_Map_Log_Table(l_Nxt_Idx).entity_action_status      := p_entity_action_status;

    Debug_Log(G_LOG_STATEMENT, 'Number of messages'||Error_Handler.Get_Message_Count);
    Debug_Log(G_LOG_STATEMENT, 'p_bo_entity_identifier'||p_bo_entity_identifier);
    Error_Handler.Get_Entity_Message(
        p_entity_id    => p_bo_entity_identifier
      , x_message_list => G_Entity_Map_Log_Table(l_Nxt_Idx).message_list);

    -- Special handling for Revised component level to log all the children messages
    IF p_bo_entity_identifier = 'RC'--Eco_Error_Handler.G_RC_LEVEL--Fixed for bug 4968251
    THEN
        -- Generally, the message count for component will be minimal. So no issues
        l_Nxt_Mesg_Cnt := G_Entity_Map_Log_Table(l_Nxt_Idx).message_list.COUNT+1;
        Error_Handler.Get_Entity_Message(
            p_entity_id    => Eco_Error_Handler.G_RD_LEVEL
          , x_message_list => l_message_list);
        FOR i IN 1..l_message_list.COUNT
        LOOP
            G_Entity_Map_Log_Table(l_Nxt_Idx).message_list(l_Nxt_Mesg_Cnt) := l_message_list(i);
            l_Nxt_Mesg_Cnt := l_Nxt_Mesg_Cnt+1;

        END LOOP;
        l_message_list.delete;
        Error_Handler.Get_Entity_Message(
            p_entity_id    => Eco_Error_Handler.G_SC_LEVEL
          , x_message_list => l_message_list);
        FOR i IN 1..l_message_list.COUNT
        LOOP
            G_Entity_Map_Log_Table(l_Nxt_Idx).message_list(l_Nxt_Mesg_Cnt) := l_message_list(i);
            l_Nxt_Mesg_Cnt := l_Nxt_Mesg_Cnt+1;
        END LOOP;
    END IF;

    /*FOR i IN 1..G_Entity_Map_Log_Table(l_Next_Idx).message_list.COUNT
    LOOP
        Debug_Log(G_LOG_STATEMENT, 'there are messages now p_revised_item_sequence_id'||p_revised_item_sequence_id);
    END LOOP;*/ --For Debugging
    IF p_bo_entity_identifier = 'ECO'
    THEN
        Error_Handler.Get_Message_List( x_message_list  => l_error_table);
        FOR i IN 1..l_error_table.COUNT
        LOOP
          FND_FILE.New_line(which => Fnd_File.LOG );
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Entity Id: '||l_error_table(i).entity_id);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Index: '||l_error_table(i).entity_index);
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Mesg: '||l_error_table(i).message_text);
        END LOOP;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    Debug_Log(G_LOG_ERROR, 'Error occurred in Add_Entity_Map for p_bo_entity_identifier:'||p_bo_entity_identifier||' Error:'||SQLERRM);
END Add_Entity_Map;

PROCEDURE Mark_Component_Change_Transfer (
    p_api_version              IN NUMBER
  , p_init_msg_list            IN VARCHAR2 := FND_API.G_FALSE        --
  , p_commit                   IN VARCHAR2 := FND_API.G_FALSE
  , x_return_status            OUT NOCOPY VARCHAR2                    --
  , x_msg_count                OUT NOCOPY NUMBER                      --
  , x_msg_data                 OUT NOCOPY VARCHAR2                    --
  , p_change_id                IN NUMBER
  , p_revised_item_sequence_id IN NUMBER
  , p_component_sequence_id    IN NUMBER
  , p_local_organization_id    IN NUMBER

) IS
    l_api_name        CONSTANT VARCHAR2(30) := 'Mark_Component_Change_Transfer';
    l_api_version     CONSTANT NUMBER := 1.0;

BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT Mark_Component_Change_Transfer;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version
                                        ,p_api_version
                                        ,l_api_name
                                        ,G_PKG_NAME )
    THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
        FND_MSG_PUB.initialize;
    END IF ;

    Initialize;
    Add_Entity_Map(
        p_change_id                 => p_change_id
      , p_revised_item_sequence_id  => p_revised_item_sequence_id
      , p_revised_line_type         => Eng_Propagation_Log_Util.G_REV_LINE_CMP_CHG
      , p_revised_line_id1          => p_component_sequence_id
      , p_local_organization_id     => p_local_organization_id
      , p_entity_name               => Eng_Propagation_Log_Util.G_ENTITY_REVISED_LINE
      , p_entity_action_status      => 4
      , p_bo_entity_identifier      => 'RC'--Eco_Error_Handler.G_RC_LEVEL
     );
    Write_Propagation_Log;

    -- Standard ending code ------------------------------------------------
    IF FND_API.To_Boolean ( p_commit )
    THEN
        COMMIT WORK;
    END IF;
EXCEPTION
WHEN OTHERS THEN
    ROLLBACK TO Mark_Component_Change_Transfer;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
    THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name );
    END IF;
    FND_MSG_PUB.Count_And_Get(
        p_count   =>  x_msg_count
      , p_data    =>  x_msg_data );

END Mark_Component_Change_Transfer;

FUNCTION Get_Composite_Logs_For_Map (
    p_change_propagation_map_id     IN   NUMBER
) RETURN VARCHAR2 IS
    CURSOR c_get_logs IS
    SELECT eclv.log_text
    FROM eng_change_logs_vl eclv
    WHERE eclv.change_propagation_map_id = p_change_propagation_map_id;
    l_composite_log_text VARCHAR2(20000);
BEGIN
    FOR cgl IN c_get_logs
    LOOP
        l_composite_log_text := l_composite_log_text||'
        '||cgl.log_text;
 -- Added in next line for new line in UI.. do not Indent.
    END LOOP;
    RETURN l_composite_log_text;
EXCEPTION
WHEN OTHERS THEN
    RETURN NULL;
END Get_Composite_Logs_For_Map;

-- bug 4704390
/******************************************************************************
* Procedure   : Get_Propagate_Action_Flag
* Parameters  :   p_conc_request_phase_code IN VARCHAR2
*               , p_entity_action_status    IN NUMBER
*               , p_global_change_id        IN NUMBER
*               , p_local_organization_id   IN NUMBER
*
* Purpose     : This function is used to fetch the propagate action flag to
*               determine if propagation is to be allowed or not for a given
*               header and a local organization.
*      Case 1 : Entity action status is 1 : G_PRP_PRC_STS_SUCCESS
*                 Sub case a: Propagation request has not been submitted
*                             This can happen in case of create new for Copy
*                             Structure process.
*                             In this case the phase code of the request is null
*                 Sub case b: Propagation request has been submitted and completed
*               In these cases , check if there exists new revised items.
*               If Yes, enable repropagation. Otherwise Action is set to success
*      Case 2 : For all other scenarios
*                --------------------------------------------------------------|
*                | Entity Status | Conc Request Phase | Action                 |
*                |---------------|--------------------|------------------------|
*                | Not Success   |    Null            | Propagation Enabled    |
*                | Not Success   |    Completed       | Repropagation Enabled  |
*                | All statuses  |    Other           | Repropagation disabled |
*                |-------------------------------------------------------------|
*******************************************************************************/
FUNCTION Get_Propagate_Action_Flag (
    p_conc_request_phase_code IN VARCHAR2
  , p_entity_action_status    IN NUMBER
  , p_global_change_id        IN NUMBER
  , p_local_organization_id   IN NUMBER
) RETURN VARCHAR2 IS

    CURSOR c_new_revised_items_exist IS
    SELECT count(1)
      FROM eng_revised_items new_ri
     WHERE new_ri.change_id= p_global_change_id -- global change id
       AND NOT EXISTS (
               SELECT 1
                 FROM eng_change_propagation_maps new_ri_map
                WHERE new_ri_map.change_id = new_ri.change_id
                  AND new_ri_map.revised_item_sequence_id = new_ri.revised_item_sequence_id
                  AND new_ri_map.entity_name = 'ENG_REVISED_ITEM'
                  AND new_ri_map.local_organization_id = p_local_organization_id)
       AND ROWNUM <2;

    l_propagate_action_flag VARCHAR2(3);
    l_revised_items_exist   NUMBER;
BEGIN
    l_propagate_action_flag := 'S';
    -- Case 1
    IF ((p_conc_request_phase_code IS NULL OR p_conc_request_phase_code = 'C')
         AND p_entity_action_status = 1)
    THEN
        OPEN c_new_revised_items_exist;
        FETCH c_new_revised_items_exist INTO l_revised_items_exist;
        CLOSE c_new_revised_items_exist;
        IF l_revised_items_exist > 0 -- new revised items exists
        THEN
            l_propagate_action_flag := 'RPE';
        ELSE
            l_propagate_action_flag := 'S';
        END IF;
    ELSE
    -- Case 2: For all other scenarios , need not check for new revsied items
        IF p_conc_request_phase_code IS NULL -- not submitted yet
        THEN
            l_propagate_action_flag := 'PE';
        ELSIF p_conc_request_phase_code = 'C' -- submitted and completed but not successful (Success handled above)
        THEN
            l_propagate_action_flag := 'RPE';
        ELSE  -- if not completed
            l_propagate_action_flag := 'RPD';
        END IF;
    END IF;

    RETURN l_propagate_action_flag;
EXCEPTION
WHEN OTHERS THEN
    IF c_new_revised_items_exist%ISOPEN
    THEN
        CLOSE c_new_revised_items_exist;
    END IF;
    RETURN NULL;
END Get_Propagate_Action_Flag;

END ENG_PROPAGATION_LOG_UTIL;


/
