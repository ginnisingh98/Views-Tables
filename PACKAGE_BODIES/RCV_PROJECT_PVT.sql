--------------------------------------------------------
--  DDL for Package Body RCV_PROJECT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_PROJECT_PVT" AS
/* $Header: RCVVPRJB.pls 115.3 2004/05/11 14:53:16 usethura noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_debug_stmt CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

/**
 * Private Procedure: set_project_task_numbers
 * Modifies: API message list
 * Effects: Retrieves task and project numbers. Appends to API
 *   message list on error.
 */
PROCEDURE set_project_task_numbers
   (p_api_version    IN   NUMBER,
    p_init_msg_list  IN   VARCHAR2,
    p_transaction_id IN NUMBER)
IS

l_api_name CONSTANT VARCHAR2(30) := 'set_project_task_numbers';
l_api_version CONSTANT NUMBER := 1.0;
l_line_location_id	NUMBER;
l_distribution_id	NUMBER;
l_project_id		NUMBER;
l_task_id		NUMBER;

BEGIN
   -- Start standard API initialization
   IF FND_API.to_boolean(p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(l_api_version, p_api_version,
                                       l_api_name, g_pkg_name)
   THEN
        IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
            FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                           '.invoked', 'Api version Incompatible');
	END IF;
        g_transaction_id := null;
	g_project_number := null;
	g_task_number    := null;
   END IF;
   -- End standard API initialization

   IF (g_fnd_debug = 'Y') THEN
     IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                       '.invoked', 'Transaction Id: ' || NVL(TO_CHAR(p_transaction_id),'null'));
     END IF;
   END IF;

   g_transaction_id := p_transaction_id;

   IF g_transaction_id IS NOT NULL THEN
        BEGIN

            SELECT
                PO_LINE_LOCATION_ID,
                PO_DISTRIBUTION_ID
            INTO
                l_line_location_id,
                l_distribution_id
            FROM
                RCV_TRANSACTIONS
            WHERE
                TRANSACTION_ID = p_transaction_id;

            EXCEPTION
		WHEN NO_DATA_FOUND THEN
                  IF (g_fnd_debug = 'Y') THEN
                    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                                       '.invoked', 'Invalid Transaction Id.');
                    END IF;
                  END IF;
		g_project_number := null;
		g_task_number := null;
		g_transaction_id := null;
		return;
	END;

	IF l_distribution_id IS NOT NULL THEN
	BEGIN
             BEGIN
                  IF (g_fnd_debug = 'Y') THEN
                    IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                        FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                                       '.invoked', 'Distribution Id:' || l_distribution_id);
                    END IF;
		  END IF;

                  SELECT
                      pde.SEGMENT1
                  INTO
                      g_project_number
                  FROM
                      PO_DISTRIBUTIONS_ALL pd,
                      PA_PROJECTS_ALL pde
                  WHERE
                      pd.PO_DISTRIBUTION_ID = l_distribution_id
                  AND	pde.PROJECT_ID = pd.PROJECT_ID;

                  EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                           g_project_number := null;
             END;
             BEGIN
                  SELECT
                      pte.TASK_NUMBER
                  INTO
                      g_task_number
                  FROM
                      PO_DISTRIBUTIONS_ALL pd,
                      PA_TASKS pte
                  WHERE
                      pd.PO_DISTRIBUTION_ID = l_distribution_id
                  AND	pte.TASK_ID = pd.TASK_ID;

                  EXCEPTION
                       WHEN NO_DATA_FOUND THEN
                            g_task_number := null;
             END;
	END;
	ELSIF l_line_location_id IS NOT NULL THEN
	BEGIN
                BEGIN
                       IF (g_fnd_debug = 'Y') THEN
                         IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
                             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                                            '.invoked', 'Line Location Id:' || l_line_location_id);
                         END IF;
		       END IF;

                       SELECT
				DISTINCT(pde.SEGMENT1)
                       INTO
				g_project_number
                       FROM
				PO_DISTRIBUTIONS_ALL pd,
				PA_PROJECTS_ALL pde
                       WHERE
				pd.LINE_LOCATION_ID = l_line_location_id
                       AND	pde.PROJECT_ID = pd.PROJECT_ID;

                       EXCEPTION
                       WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.set_name('PO', 'PO_MULTI_DEST_INFO');
                                g_project_number := FND_MESSAGE.get;
                       WHEN NO_DATA_FOUND THEN
				g_project_number := null;
		END;
		BEGIN
                       SELECT
				DISTINCT(pte.TASK_NUMBER)
                       INTO
				g_task_number
                       FROM
				PO_DISTRIBUTIONS_ALL pd,
				PA_TASKS pte
                       WHERE
				pd.LINE_LOCATION_ID = l_line_location_id
                       AND	pte.TASK_ID = pd.TASK_ID;

                       EXCEPTION
                       WHEN TOO_MANY_ROWS THEN
                                FND_MESSAGE.set_name('PO', 'PO_MULTI_DEST_INFO');
                                g_task_number := FND_MESSAGE.get;
                       WHEN NO_DATA_FOUND THEN
				g_task_number	:= null;
		END;
        END;
        ELSE
		/* Certain cases like unordered receipts will not have both
		   line_location_id and distributions_id */
		g_project_number	:= null;
		g_task_number		:= null;
		g_transaction_id	:= p_transaction_id;
        END IF;
   ELSE
        IF (g_fnd_debug = 'Y') THEN
          IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
             FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                            '.invoked', 'ERROR : transaction_id is NULL');
          END IF;
	END IF;
        g_project_number := null;
        g_task_number    := null;
	g_transaction_id := p_transaction_id;
   END IF;
   EXCEPTION
      WHEN OTHERS THEN
        g_project_number := null;
        g_task_number    := null;
	g_transaction_id := p_transaction_id;
END set_project_task_numbers;
END RCV_Project_PVT;

/
