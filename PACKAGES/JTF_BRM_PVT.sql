--------------------------------------------------------
--  DDL for Package JTF_BRM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_BRM_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvbrms.pls 120.3 2005/07/05 07:44:59 abraina ship $ */
/*#
 * Bussiness Rule Monitor (BRM) API that intergrates with WF to run BRM
 * @rep:scope private
 * @rep:product JTA
 * @rep:displayname JTF BRM Private API
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_BUSINESS_RULE
 */

-----------------------------------------------------------------------------
--
-- PROCEDURE selector
--
-- Selector function for the Business Rule Monitor.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - name of Workflow process to run
--
/*#
 * Selector function for the Business Rule Monitor.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - Name of Workflow process to run
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Selector
 */
PROCEDURE selector(
    itemtype  IN     VARCHAR2,
    itemkey   IN     VARCHAR2,
    actid     IN     NUMBER,
    funcmode  IN     VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- FUNCTION init_monitor
--
-- Create an instance of the Business Rule Monitor, initialize it, and
-- start the instance.  Return TRUE if successful; otherwise return FALSE.
--
-- IN
--   itemkey     - key of the current item
--   uom_type    - unit of measure type for timer interval
--   uom_code    - unit of measure code for timer interval
--   timer_units - number of units for timer interval
-- OUT
--   TRUE        - success
--   FALSE       - failure
--
/*#
 * Create an instance of the Business Rule Monitor, initialize it, and
 * start the instance.  Return TRUE if successful; otherwise return FALSE.
 * @param itemkey - Key of the current item
 * @param uom_type - Unit of measure type for timer interval
 * @param uom_code - Unit of measure code for timer interval
 * @param timer_units - Number of units for timer interval
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Initialize Monitor
 */
FUNCTION init_monitor(
    itemkey       IN NUMBER,
    uom_type      IN VARCHAR2,
    uom_code      IN VARCHAR2,
    timer_units   IN NUMBER)
    RETURN BOOLEAN;
-----------------------------------------------------------------------------
--
-- PROCEDURE start_monitor
--
-- Set the START command and PROCESS_ID item attributes and update the
-- record in the JTF_BRM_PARAMETERS table to indicate the start of the
-- Business Rule Monitor.  The WORKFLOW_PROCESS_ID is set to be the same
-- as the itemkey.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:No error
--               COMPLETE:Non-critical error
--               COMPLETE:Critical error
--
/*#
 * Set the START command and PROCESS_ID item attributes and update the
 * record in the JTF_BRM_PARAMETERS table to indicate the start of the
 * Business Rule Monitor.  The WORKFLOW_PROCESS_ID is set to be the same
 * as the itemkey.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Monitor
 */
PROCEDURE start_monitor(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- PROCEDURE calculate_interval
--
-- Calculate the timer interval for the Business Rule Monitor.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:No error
--               COMPLETE:Non-critical error
--               COMPLETE:Critical error
--
/*#
 * Calculate the timer interval for the Business Rule Monitor.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Interval
 */
PROCEDURE calculate_interval(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- PROCEDURE process_rules
--
-- Get the active business rules and process them.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:No error
--               COMPLETE:Non-critical error
--               COMPLETE:Critical error
--
/*#
 * Get the active business rules and process them.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Process Rules
 */
PROCEDURE process_rules(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- PROCEDURE check_interval
--
-- Check the difference between the timer interval and the actual interval
-- needed to process the current set of active business rules.  A negative
-- difference stops the Business Rule Monitor so that the timer interval can
-- be increased.  No difference or a positive difference sets the time to
-- wait before the next set of rules is processed.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:No error
--               COMPLETE:Non-critical error
--               COMPLETE:Critical error
--
/*#
 * Check the difference between the timer interval and the actual interval
 * needed to process the current set of active business rules.  A negative
 * difference stops the Business Rule Monitor so that the timer interval can
 * be increased.  No difference or a positive difference sets the time to
 * wait before the next set of rules is processed.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Interval
 */
PROCEDURE check_interval(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- PROCEDURE get_brm_command
--
-- Get the current Business Rule Monitor command.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:No error
--               COMPLETE:Non-critical error
--               COMPLETE:Critical error
--
/*#
 * Get the current Business Rule Monitor command.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get BRM Command
 */
PROCEDURE get_brm_command(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- PROCEDURE stop_monitor
--
-- Check if there is a request to stop the Business Rule Monitor.
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:True
--               COMPLETE:False
--
/*#
 * Check if there is a request to stop the Business Rule Monitor.
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Stop Monitor
 */
PROCEDURE stop_monitor(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------
--
-- PROCEDURE commit_wf
--
-- commits all runtime WF-data for the complete scan cycle and resets the
-- wf_savepoint. This will prevent the rollback segments from growing to
-- rediculous size
--
-- IN
--   itemtype  - type of the current item
--   itemkey   - key of the current item
--   actid     - process activity instance id
--   funcmode  - function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
-- OUT
--   result    - activity has completed with the indicated result:
--
--               COMPLETE:True
--               COMPLETE:False
--
/*#
 * Commits all runtime WF-data for the complete scan cycle and resets the
 * wf_savepoint. This will prevent the rollback segments from growing to
 * rediculous size
 * @param itemtype - Type of the current item
 * @param itemkey - Key of the current item
 * @param actid - Process activity instance id
 * @param funcmode - Function execution mode ('RUN', 'CANCEL', 'TIMEOUT')
 * @param result - activity has completed with the indicated result:
 *                 COMPLETE:No error
 *                 COMPLETE:Non-critical error
 *                 COMPLETE:Critical error
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Commit WF
 */
PROCEDURE commit_wf(
    itemtype  IN VARCHAR2,
    itemkey   IN VARCHAR2,
    actid     IN NUMBER,
    funcmode  IN VARCHAR2,
    result    IN OUT NOCOPY VARCHAR2);
-----------------------------------------------------------------------------

END JTF_BRM_PVT;

 

/
