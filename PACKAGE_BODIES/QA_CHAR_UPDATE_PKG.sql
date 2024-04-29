--------------------------------------------------------
--  DDL for Package Body QA_CHAR_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_CHAR_UPDATE_PKG" AS
/* $Header: qacharub.pls 120.0 2005/05/24 19:18:07 appldev noship $ */

--
-- FILE NAME
-- qacharub.pls
--
-- PACKAGE NAME
-- QA_CHAR_UPDATE_PKG
--
-- DESCRIPTION
-- This package is used for Updating all instances QA Schema when a value
-- stored for a Collection Element has changed externally.
--
-- This package was primarily created for handling FND User Name Changes
-- Which are propagated to impacted products using a Workflow Business
-- Event Subscription ( oracle.apps.fnd.wf.ds.user.nameChanged ).
--
-- TRACKING BUG
-- 4305107
--
-- HISTORY
-- 12-APR-2005 Sivakumar Kalyanasunderam Created.


    -- Package Name
    g_pkg_name CONSTANT VARCHAR2(30) := 'QA_CHAR_UPDATE_PKG';

    -- Wrapper API which is invoked by the business event subscription
    -- when FND User Name Changes
    FUNCTION Update_User_Name
    (
      p_subscription_guid IN RAW,
      p_event             IN OUT NOCOPY WF_EVENT_T
    ) RETURN VARCHAR2
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'Update_User_Name';
      l_return_status          VARCHAR2(1);
      l_msg_count              NUMBER;
      l_msg_index_out          NUMBER;
      l_msg_data               VARCHAR2(2000);
      l_error_string           VARCHAR2(5000);

      l_event_key              VARCHAR2(1000);
      l_old_user_name          WF_ROLES.name%TYPE;
      l_new_user_name          WF_ROLES.name%TYPE;

    BEGIN

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'ENTERING PROCEDURE'
        );
      END IF;

      -- Get the Event Key
      l_event_key := p_event.GetEventKey();

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'EVENT NAME: ' || p_event.GetEventName() || ' EVENT KEY: ' || l_event_key || ' USER ID: ' || FND_GLOBAL.user_id || ' LOGIN ID: ' || FND_GLOBAL.login_id
        );
      END IF;

      -- Resolve the Event Key into the old and new User Names
      -- The Event Key is of the form NEWUSERNAME:OLDUSERNAME
      l_new_user_name := SUBSTR( l_event_key, 1 , (INSTR( l_event_key, ':', 1, 1 ) -1) );
      l_old_user_name := SUBSTR( l_event_key, (INSTR( l_event_key, ':', 1, 1 ) +1) );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Invoking Update_Element_Value with p_old_value => ' || l_old_user_name || ' and p_new_value => ' || l_new_user_name
        );
      END IF;

      -- Invoke the Core API to Update the Value of User Name for impacted
      -- Elements. ( In this case the "Send Notification To" Element )
      Update_Element_Value
      (
        p_api_version         => 1.0,
        p_init_msg_list       => FND_API.G_TRUE,
        p_commit              => FND_API.G_TRUE,
        p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
        p_char_id             => QA_SS_CONST.send_notification_to,
        p_old_value           => l_old_user_name,
        p_new_value           => l_new_user_name,
        x_return_status       => l_return_status,
        x_msg_count           => l_msg_count,
        x_msg_data            => l_msg_data
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'After Invoking Update_Element_Value. Return Status is: ' || l_return_status
        );
      END IF;

      -- Error Handling
      IF ( l_return_status = FND_API.G_RET_STS_ERROR OR
           l_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN

        -- Get all Error Messages
        FOR I IN 1..l_msg_count LOOP
          FND_MSG_PUB.get
          (
            p_msg_index      => I,
            p_encoded        => FND_API.G_FALSE,
            p_data           => l_msg_data,
            p_msg_index_out  => l_msg_index_out
          );

          l_error_string := l_error_string || I || ': ' || l_msg_data;
        END LOOP;

        IF ( FND_LOG.level_error >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_error,
            g_pkg_name || '.' || l_api_name,
            'User Name Update Failed with Error: ' || l_error_string
          );
        ELSIF ( FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_unexpected,
            g_pkg_name || '.' || l_api_name,
            'User Name Update Failed with Error: ' || l_error_string
          );
        END IF;

        -- Set the Context for the WF Event
        WF_CORE.Context
        (
          g_pkg_name,
          l_api_name,
          p_event.getEventName(),
          p_subscription_guid
        );

        -- Set the Error Info for the WF Event
        WF_EVENT.setErrorInfo( p_event, 'ERROR' );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

        -- Return value expected by WF Event in case of error
        RETURN 'ERROR';

      END IF;

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Exiting Procedure: Success'
        );
      END IF;

      -- Return value expected by WF Event in case of success
      RETURN 'SUCCESS';

    EXCEPTION
      WHEN OTHERS  THEN

        IF ( FND_LOG.level_error >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_error,
            g_pkg_name || '.' || l_api_name,
            'User Name Update Failed with Error: ' || SQLERRM
          );
        ELSIF ( FND_LOG.level_unexpected >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_unexpected,
            g_pkg_name || '.' || l_api_name,
            'User Name Update Failed with Error: ' || SQLERRM
          );
        END IF;

        -- Set the Context for the WF Event
        WF_CORE.Context
        (
          g_pkg_name,
          l_api_name,
          p_event.getEventName(),
          p_subscription_guid
        );

        -- Set the Error Info for the WF Event
        WF_EVENT.setErrorInfo( p_event, 'ERROR' );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

        -- Return value expected by WF Event in case of error
        RETURN 'ERROR';

    END Update_User_Name;

    -- Local procedure for Updating QA Results
    -- This procedure does not update value changes for Hardcoded elements
    -- since the IDs are stored in QA Results in this case.
    PROCEDURE update_results
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2,
      p_commit           IN         BOOLEAN
    )
    IS

      l_api_name      CONSTANT VARCHAR2(30)   := 'update_results';

      TYPE number_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      TYPE result_column_tab IS TABLE OF qa_plan_chars.result_column_name%TYPE
           INDEX BY BINARY_INTEGER;

      l_plan_ids          number_tab;
      l_result_columns    result_column_tab;

      l_index_predicate   VARCHAR2(32767);
      l_dml_string        VARCHAR2(32767);

    BEGIN

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Getting Result Columns for char_id: '|| p_char_id
        );
      END IF;

      -- Get the Result Column Names for Plans containing the given Element
      -- Filter out history plans
      SELECT qpc.plan_id,
             qpc.result_column_name
      BULK COLLECT INTO
             l_plan_ids,
             l_result_columns
      FROM   qa_chars qc,
             qa_plan_chars qpc,
             qa_plans qp
      WHERE  qc.hardcoded_column IS NULL
      AND    qc.char_id = qpc.char_id
      AND    qpc.char_id = p_char_id
      AND    qpc.plan_id = qp.plan_id
      AND    qp.organization_id <> 0
      AND NOT EXISTS
             (
               SELECT 1
               FROM   qa_pc_plan_relationship
               WHERE  data_entry_mode = 4
               AND    child_plan_id = qp.plan_id
             );

      IF ( l_plan_ids.COUNT = 0 ) THEN
        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'No Plans found for char_id: '|| p_char_id
          );
        END IF;

        -- No Plan containing the given Element
        RETURN;
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before calling QA_CHAR_INDEXES_PKG.get_predicate for char_id: '|| p_char_id
        );
      END IF;

      -- Get the Index Predicate for the given element
      -- This would improve performance by using the right index
      QA_CHAR_INDEXES_PKG.get_predicate
      (
        p_char_id   => p_char_id,
        p_alias     => null,
        x_predicate => l_index_predicate
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Index Predicate for char_id: '|| p_char_id || ' is ' || NVL( l_index_predicate, 'NONE' )
        );
      END IF;

      FOR i IN l_plan_ids.FIRST .. l_plan_ids.LAST LOOP

        -- Form the DML String for Updating QA Results
        l_dml_string := 'UPDATE qa_results qr SET ' || l_result_columns(i) || ' = :1 WHERE plan_id = :2 AND ' || NVL( l_index_predicate, l_result_columns(i) ) || ' = :3 ';

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Before updating QA Results with DML: ' || l_dml_string
          );
        END IF;

        -- Perform the Updates
        -- Ignore if there are no records with elements containing the old value
        EXECUTE IMMEDIATE
          l_dml_string
        USING
          p_new_value,
          l_plan_ids(i),
          p_old_value;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows of QA Results with plan_id: ' || l_plan_ids(i) || ' for char_id: ' || p_char_id
          );
        END IF;

        -- Since there a possibility of many rows being updated
        -- we need to commit after processing each plan
        IF ( p_commit ) THEN
          COMMIT WORK;
          SAVEPOINT Update_Element_Value_PKG;
        END IF;

      END LOOP;

    END update_results;

    -- Local procedure to update Plan Elements
    PROCEDURE update_plan_chars
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_plan_chars';
    BEGIN
        UPDATE  QA_PLAN_CHARS
        SET     default_value     = p_new_value
        WHERE   char_id           = p_char_id
        AND     default_value     = p_old_value;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PLAN_CHARS.default_value for char_id: ' || p_char_id
          );
        END IF;
    END update_plan_chars;

    -- Local procedure to update Elements
    PROCEDURE update_chars
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_chars';
    BEGIN
        UPDATE  QA_CHARS
        SET     default_value       = p_new_value
        WHERE   char_id             = p_char_id
        AND     default_value       = p_old_value;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_CHARS.default_value for char_id: ' || p_char_id
          );
        END IF;
    END update_chars;

    -- Local procedure to update Element Action Triggers
    PROCEDURE update_char_action_trig
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_char_action_trig';
    BEGIN
        UPDATE  QA_CHAR_ACTION_TRIGGERS
        SET     low_value_other   = p_new_value
        WHERE   char_id           = p_char_id
        AND     low_value_other   = p_old_value;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_CHAR_ACTION_TRIGGERS.low_value_other for char_id: ' || p_char_id
          );
        END IF;

        UPDATE  QA_CHAR_ACTION_TRIGGERS
        SET     high_value_other  = p_new_value
        WHERE   char_id           = p_char_id
        AND     high_value_other  = p_old_value;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_CHAR_ACTION_TRIGGERS.high_value_other for char_id: ' || p_char_id
          );
        END IF;
    END update_char_action_trig;

    -- Local procedure to update Plan Element Action Triggers
    PROCEDURE update_plan_char_action_trig
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_plan_char_action_trig';
    BEGIN
        UPDATE  QA_PLAN_CHAR_ACTION_TRIGGERS
        SET     low_value_other   = p_new_value
        WHERE   char_id           = p_char_id
        AND     low_value_other   = p_old_value
        AND     plan_id           IN
                (
                  SELECT  DISTINCT plan_id
                  FROM    QA_PLAN_CHARS
                  WHERE   char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PLAN_CHAR_ACTION_TRIGGERS.low_value_other for char_id: ' || p_char_id
          );
        END IF;

        UPDATE  QA_PLAN_CHAR_ACTION_TRIGGERS
        SET     high_value_other  = p_new_value
        WHERE   char_id           = p_char_id
        AND     high_value_other  = p_old_value
        AND     plan_id           IN
                (
                  SELECT  DISTINCT plan_id
                  FROM    QA_PLAN_CHARS
                  WHERE   char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PLAN_CHAR_ACTION_TRIGGERS.high_value_other for char_id: ' || p_char_id
          );
        END IF;
    END update_plan_char_action_trig;

    -- Local procedure to update Plan Collection Triggers
    PROCEDURE update_plan_coll_trig
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_plan_coll_trig';
    BEGIN
        UPDATE  QA_PLAN_COLLECTION_TRIGGERS
        SET     low_value             = p_new_value
        WHERE   collection_trigger_id = p_char_id
        AND     low_value             = p_old_value
        AND     plan_transaction_id   IN
                (
                  SELECT  qpt.plan_transaction_id
                  FROM    QA_PLAN_TRANSACTIONS qpt,
                          QA_PLAN_CHARS qpc
                  WHERE   qpt.plan_id = qpc.plan_id
                  AND     qpc.char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PLAN_COLLECTION_TRIGGERS.low_value for char_id: ' || p_char_id
          );
        END IF;

        UPDATE  QA_PLAN_COLLECTION_TRIGGERS
        SET     high_value            = p_new_value
        WHERE   collection_trigger_id = p_char_id
        AND     high_value            = p_old_value
        AND     plan_transaction_id   IN
                (
                  SELECT  qpt.plan_transaction_id
                  FROM    QA_PLAN_TRANSACTIONS qpt,
                          QA_PLAN_CHARS qpc
                  WHERE   qpt.plan_id = qpc.plan_id
                  AND     qpc.char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PLAN_COLLECTION_TRIGGERS.high_value for char_id: ' || p_char_id
          );
        END IF;
    END update_plan_coll_trig;

    -- Local procedure to update Criteria
    PROCEDURE update_criteria
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_criteria';
    BEGIN
        UPDATE  QA_CRITERIA
        SET     low_value   = p_new_value
        WHERE   char_id     = p_char_id
        AND     low_value   = p_old_value
        AND     criteria_id IN
                (
                  SELECT  qch.criteria_id
                  FROM    QA_CRITERIA_HEADERS qch,
                          QA_PLANS qp,
                          QA_PLAN_CHARS qpc
                  WHERE   qch.organization_id = qp.organization_id
                  AND     qp.plan_id = qpc.plan_id
                  AND     qpc.char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_CRITERIA.low_value for char_id: ' || p_char_id
          );
        END IF;

        UPDATE  QA_CRITERIA
        SET     high_value  = p_new_value
        WHERE   char_id     = p_char_id
        AND     high_value  = p_old_value
        AND     criteria_id IN
                (
                  SELECT  qch.criteria_id
                  FROM    QA_CRITERIA_HEADERS qch,
                          QA_PLANS qp,
                          QA_PLAN_CHARS qpc
                  WHERE   qch.organization_id = qp.organization_id
                  AND     qp.plan_id = qpc.plan_id
                  AND     qpc.char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_CRITERIA.high_value for char_id: ' || p_char_id
          );
        END IF;
    END update_criteria;

    -- Local procedure to update Parent Child Criteria
    PROCEDURE update_pc_criteria
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_pc_criteria';
    BEGIN
        UPDATE  QA_PC_CRITERIA
        SET     low_value   = p_new_value
        WHERE   char_id     = p_char_id
        AND     low_value   = p_old_value
        AND     plan_relationship_id IN
                (
                   SELECT  qppr.plan_relationship_id
                   FROM    QA_PC_PLAN_RELATIONSHIP qppr,
                           QA_PLAN_CHARS qpc
                   WHERE   qppr.parent_plan_id = qpc.plan_id
                   AND     qpc.char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PC_CRITERIA.low_value for char_id: ' || p_char_id
          );
        END IF;

        UPDATE  QA_PC_CRITERIA
        SET     high_value  = p_new_value
        WHERE   char_id     = p_char_id
        AND     high_value  = p_old_value
        AND     plan_relationship_id IN
                (
                   SELECT  qppr.plan_relationship_id
                   FROM    QA_PC_PLAN_RELATIONSHIP qppr,
                           QA_PLAN_CHARS qpc
                   WHERE   qppr.parent_plan_id = qpc.plan_id
                   AND     qpc.char_id = p_char_id
                );

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_PC_CRITERIA.high_value for char_id: ' || p_char_id
          );
        END IF;
    END update_pc_criteria;

    -- Local procedure to update Specifications
    PROCEDURE update_specs
    (
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'update_specs';
    BEGIN
        UPDATE  QA_SPECS
        SET     spec_element_value   = p_new_value
        WHERE   char_id              = p_char_id
        AND     spec_element_value   = p_old_value;

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'Updated ' || SQL%ROWCOUNT || ' Rows for QA_SPECS.spec_element_value for char_id: ' || p_char_id
          );
        END IF;
    END update_specs;

    -- Core API which would accept the element, old value and new value
    -- and update all instances where the old value is stored
    -- with the new value.
    PROCEDURE Update_Element_Value
    (
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2
    )
    IS
      l_api_name      CONSTANT VARCHAR2(30)   := 'Update_Element_Value';
      l_api_version   CONSTANT NUMBER         := 1.0;

      CURSOR plan_cur IS
        SELECT 'Y'
        FROM   QA_PLAN_CHARS qpc,
               QA_PLANS qp
        WHERE  qpc.char_id = p_char_id
        AND    qpc.plan_id = qp.plan_id
        AND    qp.organization_id <> 0;

      l_plans_exist   VARCHAR2(1);
      l_commit        BOOLEAN;

    BEGIN
      l_commit        := FND_API.To_Boolean( NVL(p_commit, FND_API.G_FALSE) );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Entering Procedure for element: ' || p_char_id
        );
      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT Update_Element_Value_PKG;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call
      (
        l_api_version,
        NVL( p_api_version, 1.0 ),
        l_api_name,
        g_pkg_name
      ) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( NVL( p_init_msg_list, FND_API.G_FALSE ) ) THEN
        FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_chars'
        );
      END IF;

      -- Invoke Local procedure to update Elements
      update_chars
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_char_action_trig'
        );
      END IF;

      -- Invoke Local procedure to update Element Action Triggers
      update_char_action_trig
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      -- Check if any Collection Plan is using the given element.
      -- If no Plans found then, further processing is not required
      OPEN  plan_cur;
      FETCH plan_cur INTO l_plans_exist;
      IF ( plan_cur%NOTFOUND ) THEN

        IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_statement,
            g_pkg_name || '.' || l_api_name,
            'No Plans exist using the char_id: ' || p_char_id
          );
        END IF;

        CLOSE plan_cur;

        -- No further processing is required.
        RETURN;
      END IF;

      CLOSE plan_cur;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_plan_chars'
        );
      END IF;

      -- Invoke Local procedure to update Plan Elements
      update_plan_chars
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_plan_char_action_trig'
        );
      END IF;

      -- Invoke Local procedure to update Plan Element Action Triggers
      update_plan_char_action_trig
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_plan_coll_trig'
        );
      END IF;

      -- Invoke Local procedure to update Plan Collection Triggers
      update_plan_coll_trig
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_criteria'
        );
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_pc_criteria'
        );
      END IF;

      -- Invoke Local procedure to update Parent Child Criteria
      update_pc_criteria
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_specs'
        );
      END IF;

      -- Invoke Local procedure to update Specifications
      update_specs
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      -- Invoke Local procedure to update Criteria
      update_criteria
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value
      );

      -- Commit Work at this pont because there will be intermediate
      -- Commits when QA results are updated.
      IF ( l_commit ) THEN
        COMMIT WORK;
        SAVEPOINT Update_Element_Value_PKG;
      END IF;

      IF ( FND_LOG.level_statement >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_statement,
          g_pkg_name || '.' || l_api_name,
          'Before Calling update_results'
        );
      END IF;

      -- Invoke Local procedure to update QA Results
      update_results
      (
        p_char_id          => p_char_id,
        p_old_value        => p_old_value,
        p_new_value        => p_new_value,
        p_commit           => l_commit
      );

      -- Commit (if requested)
      IF ( l_commit ) THEN
        COMMIT WORK;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (
        p_count => x_msg_count,
        p_data  => x_msg_data
      );

      IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
        FND_LOG.string
        (
          FND_LOG.level_procedure,
          g_pkg_name || '.' || l_api_name,
          'Exiting Procedure: Success'
        );
      END IF;

    EXCEPTION

      WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Update_Element_Value_PKG;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Update_Element_Value_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

      WHEN OTHERS THEN
        ROLLBACK TO Update_Element_Value_PKG;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF ( FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR ) ) THEN
          FND_MSG_PUB.Add_Exc_Msg
          (
            p_pkg_name       => g_pkg_name,
            p_procedure_name => l_api_name,
            p_error_text     => SUBSTR(SQLERRM,1,240)
          );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (
          p_count => x_msg_count,
          p_data  => x_msg_data
        );

        IF ( FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level ) THEN
          FND_LOG.string
          (
            FND_LOG.level_procedure,
            g_pkg_name || '.' || l_api_name,
            'Exiting Procedure: Error'
          );
        END IF;

    END Update_Element_Value;

END QA_CHAR_UPDATE_PKG;

/
