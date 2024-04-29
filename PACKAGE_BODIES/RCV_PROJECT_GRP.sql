--------------------------------------------------------
--  DDL for Package Body RCV_PROJECT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."RCV_PROJECT_GRP" AS
/* $Header: RCVGPRJB.pls 115.2 2004/05/11 14:53:58 usethura noship $ */

-- Read the profile option that enables/disables the debug log
g_fnd_debug CONSTANT VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_module_prefix CONSTANT VARCHAR2(50) := 'po.plsql.' || g_pkg_name || '.';

/**
 * Public Procedure: get_project_number
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: The API message list.
 * Effects:
 *   Retrieves the project number based on the transaction_id thats passed
 *   Appends to API message list on error, and returns null for project id.
 * Returns:
 *         - Null if No project number exists or if api errors out
 *         - Multiple if multiple project numbers exist
 *         - Project Number if project number exists
 */

FUNCTION get_project_number
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_transaction_id	    IN   NUMBER
   ) RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_project_number';
l_api_version CONSTANT NUMBER := 1.0;
l_project_number	VARCHAR2(25);

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
        return null;
    END IF;
    -- End standard API initialization

    IF (g_fnd_debug = 'Y') THEN
       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                          '.invoked', 'Transaction id: ' || NVL(TO_CHAR(p_transaction_id),'null'));
       END IF;
    END IF;

    -- Check if the transaction_id is null
    IF p_transaction_id IS NULL THEN
        IF (g_fnd_debug = 'Y') THEN
           IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                              '.invoked', 'ERROR : transaction_id is NULL');
           END IF;
        END IF;
        l_project_number := null;
    ELSE
        -- Check to see if the project number has already been set
        IF RCV_Project_PVT.g_transaction_id = p_transaction_id THEN
           l_project_number := RCV_Project_PVT.g_project_number;
        ELSE
           RCV_Project_PVT.set_project_task_numbers
           (
                p_api_version,
                p_init_msg_list,
		p_transaction_id
           );
           l_project_number := RCV_Project_PVT.g_project_number;
	END IF;
    END IF;
    return l_project_number;
EXCEPTION
    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y') THEN
           IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                              '.invoked', 'UNEXPECTED ERROR');
           END IF;
        END IF;
	return null;
END get_project_number;

/**
 * Public Procedure: get_task_number
 * Requires: API message list has been initialized if p_init_msg_list is false.
 * Modifies: The API message list.
 * Effects:
 *   Retrieves the task number based on the transaction_id thats passed
 *   Appends to API message list on error, and returns null for project id.
 * Returns:
 *         - Null if No task number exists or if api errors out
 *         - Multiple if multiple task numbers exist
 *         - Task Number if task number exists
 */

FUNCTION get_task_number
   (p_api_version           IN   NUMBER,
    p_init_msg_list         IN   VARCHAR2,
    p_transaction_id	    IN   NUMBER
   ) RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'get_task_number';
l_api_version CONSTANT NUMBER := 1.0;
l_task_number		VARCHAR2(25);

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
        return null;
    END IF;
    -- End standard API initialization

    IF (g_fnd_debug = 'Y') THEN
       IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
           FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                          '.invoked', 'Transaction id: ' || NVL(TO_CHAR(p_transaction_id),'null'));
       END IF;
    END IF;

    -- Check if the transaction_id is null
    IF p_transaction_id IS NULL THEN
        IF (g_fnd_debug = 'Y') THEN
           IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                              '.invoked', 'ERROR : transaction_id is NULL');
           END IF;
        END IF;
        l_task_number := null;
    ELSE
        -- Check to see if the task number has already been set
        IF RCV_Project_PVT.g_transaction_id = p_transaction_id THEN
           l_task_number := RCV_Project_PVT.g_task_number;
        ELSE
           RCV_Project_PVT.set_project_task_numbers
           (
                p_api_version,
                p_init_msg_list,
		p_transaction_id
           );
           l_task_number := RCV_Project_PVT.g_task_number;
	END IF;
    END IF;
    return l_task_number;
EXCEPTION
    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y') THEN
           IF( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
	       FND_LOG.string(FND_LOG.LEVEL_PROCEDURE, g_module_prefix || l_api_name ||
                              '.invoked', 'UNEXPECTED ERROR');
           END IF;
        END IF;
	return null;
END get_task_number;

END RCV_Project_GRP;

/
