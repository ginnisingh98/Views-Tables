--------------------------------------------------------
--  DDL for Package JTF_ESCWFACTIVITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_ESCWFACTIVITY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvewas.pls 120.2 2005/07/05 07:45:27 abraina ship $ */
/*#
 * This is the private interface to the JTF Escalation Management.
 * This Interface is used for all Workflow related activities.
 *
 * @rep:scope private
 * @rep:product JTF
 * @rep:lifecycle active
 * @rep:displayname Escalation Management
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY JTA_ESCALATION
*/

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Create_NotifTask
--  Description : Call Task Manager API to create task for potential
--                escalation notification purposes
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype             IN         VARCHAR2 required
--      itemkey              IN         VARCHAR2 required
--      actid                IN         NUMBER   required
--      funcmode             IN         VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
/*#
* Creates task for potential escalation notification purposes
*
* @param itemtype the type of the workflow item
* @param itemkey the key of the workflow item
* @param actid the activity id
* @param funcmode the mode of activity - run / complete / cancel
* @param resultout the parameter the returns the status of the event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Create Notification Task
* @rep:compatibility S
*/
PROCEDURE Create_NotifTask
  ( itemtype  IN     VARCHAR2
  , itemkey   IN     VARCHAR2
  , actid     IN     NUMBER
  , funcmode  IN     VARCHAR2
  , resultout    OUT NOCOPY VARCHAR2
  );

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Create_EscTask
--  Description : Call Task Manager API to create escalation task
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype             IN         VARCHAR2 required
--      itemkey              IN         VARCHAR2 required
--      actid                IN         NUMBER   required
--      funcmode             IN         VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
/*#
* Creates Escalation Task
*
* @param itemtype the type of the workflow item
* @param itemkey the key of the workflow item
* @param actid the activity id
* @param funcmode the mode of activity - run / complete / cancel
* @param resultout the parameter the returns the status of the event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Create Escalation Task
* @rep:compatibility S
*/
PROCEDURE Create_EscTask
  ( itemtype  IN     VARCHAR2
  , itemkey   IN     VARCHAR2
  , actid     IN     NUMBER
  , funcmode  IN     VARCHAR2
  , resultout    OUT NOCOPY VARCHAR2
  );

----------------------------------------------------------------------------
-- Start of comments
--  Procedure   : Get_NotifPerson
--  Description : Work out who is to be notified regarding the escalation
--  Parameters  :
--      name                 direction  type     required?
--      ----                 ---------  ----     ---------
--      itemtype             IN         VARCHAR2 required
--      itemkey              IN         VARCHAR2 required
--      actid                IN         NUMBER   required
--      funcmode             IN         VARCHAR2 required
--      resultout               OUT     VARCHAR2
--
--  Notes :
--
-- End of comments
----------------------------------------------------------------------------
/*#
* Gets the Notification Person
*
* @param itemtype the type of the workflow item
* @param itemkey the key of the workflow item
* @param actid the activity id
* @param funcmode the mode of activity - run / complete / cancel
* @param resultout the parameter the returns the status of the event
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Get Notification Person
* @rep:compatibility S
*/
PROCEDURE Get_NotifPerson
  ( itemtype  IN     VARCHAR2
  , itemkey   IN     VARCHAR2
  , actid     IN     NUMBER
  , funcmode  IN     VARCHAR2
  , resultout    OUT NOCOPY VARCHAR2
  );

END JTF_EscWFActivity_PVT;

 

/
