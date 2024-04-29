--------------------------------------------------------
--  DDL for Package CAC_VIEW_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CAC_VIEW_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: cacvcwss.pls 120.1 2006/02/17 05:32:26 sankgupt noship $ */

PROCEDURE StartSubscription
/*******************************************************************************
** Start of comments
**  Procedure   : StartSubscription
**  Description : Given the group and requestor information this API
**                will start subscription workflows for all admins
**                of the group
**  Parameters  :
**      name                 direction  type     required?
**      ----                 ---------  ----     ---------
**      p_api_version        IN         NUMBER   required
**      p_init_msg_list      IN         VARCHAR2 optional
**      p_commit             IN         VARCHAR2 optional
**      x_return_status         OUT  NOCOPY   VARCHAR2 optional
**      x_msg_count             OUT  NOCOPY   NUMBER   required
**      x_msg_data              OUT  NOCOPY   VARCHAR2 required
**      p_CALENDAR_REQUESTOR IN         NUMBER   required
**      p_GROUP_ID           IN         NUMBER   required
**      p_GROUP_NAME         IN         VARCHAR2 required
**      p_GROUP_DESCRIPTION  IN         VARCHAR2 required
**  Notes :
**
** End of comments
*******************************************************************************/
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit             IN     VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_CALENDAR_REQUESTOR IN     NUMBER   -- Resource ID of the Subscriber
, p_GROUP_ID           IN     NUMBER   -- Resource ID of Group Calendar
, p_GROUP_NAME         IN     VARCHAR2 -- Name of the Group Calendar
, p_GROUP_DESCRIPTION  IN     VARCHAR2 -- Description of the Group Calendar
);

PROCEDURE StartRequest
/*******************************************************************************
** Start of comments
**  Procedure   : StartRequest
**  Description : Given the group and requestor information this API will start
**                a workflow that will send the request to the
**                JTF_CALENDAR_ADMIN
**  Parameters  :
**      name                direction  type     required?
**      ----                ---------  ----     ---------
**      p_api_version       IN         NUMBER   required
**      p_init_msg_list     IN         VARCHAR2 optional
**      p_commit            IN         VARCHAR2 optional
**      x_return_status        OUT     NOCOPY VARCHAR2 optional
**      x_msg_count            OUT     NOCOPY NUMBER   required
**      x_msg_data             OUT     NOCOPY VARCHAR2 required
**      p_REQUESTOR         IN         NUMBER   required
**      p_GROUP_ID          IN         NUMBER   optional
**      p_GROUP_NAME        IN         VARCHAR2 required
**      p_GROUP_DESCRIPTION IN         VARCHAR2 required
**      p_PUBLIC_FLAG       IN         VARCHAR2 required
**  Notes :
**    1)
**
** End of comments
*******************************************************************************/
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit             IN     VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_CALENDAR_REQUESTOR IN     NUMBER   -- Resource ID of the Requestor
, p_GROUP_ID           IN     NUMBER   -- Resource ID of Group if known
, p_GROUP_NAME         IN     VARCHAR2 -- (Suggested) Name of the Group Calendar
, p_GROUP_DESCRIPTION  IN     VARCHAR2 -- (Suggested) Description of the Group Calendar
, p_PUBLIC             IN     VARCHAR2 -- Public Calendar flag
);

PROCEDURE StartInvite
/*******************************************************************************
** Start of comments
**  Procedure   : StartInviteWF
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitor (p_INVITOR) this procedure will
**                send notifications to all the attendees of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     NOCOPY VARCHAR2 optional
**      x_msg_count           OUT     NOCOPY NUMBER   required
**      x_msg_data            OUT     NOCOPY VARCHAR2 required
**      p_INVITOR          IN         NUMBER   required
**      p_TaskID           IN         NUMBER   required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit        IN     VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_INVITOR       IN     NUMBER   -- Resource ID of Invitor
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
);

PROCEDURE StartInviteResource
/*******************************************************************************
** Start of comments
**  Procedure   : StartInvite
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitee (p_INVITEE) this procedure will
**                send notification to the paticular attendee of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_INVITEE          IN         NUMBER   required
**      p_INVITEE_TYPE     IN         VARCHAR2 required
**      p_INVITOR          IN         NUMBER   required
**      p_TaskID           IN         NUMBER   required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2  DEFAULT fnd_api.g_false
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITEE       IN     NUMBER   -- Resource ID of Invitee
, p_INVITEE_TYPE  IN     VARCHAR2 --Resource Type of the INVITEE
, p_INVITOR       IN     NUMBER   -- Resource ID of Invitor
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
);

PROCEDURE UpdateInvitation
/*******************************************************************************
** Start of comments
**  Procedure   : UpdateInvitation
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitor (p_INVITOR) this procedure will
**                respond to the notifications from the attendees of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout          OUT        VARCHAR2 required
**
** End of comments
*******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
);


PROCEDURE DetermineWFRole
/*******************************************************************************
** Start of comments
**  Procedure   : DetermineWFRole
**  Description : Work out the WF role for the given resource.
**                Used to implement the 'Determine WF Role' function in the
**                'CACVWSWF.Send Invitation' workflow.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT    NOCOPY  VARCHAR2 required
**
**  Notes :
**    1) Expects WF item attributes 'RESOURCE_ID' and 'RESOURCE_TYPE' to be
**       available to this procedure.
**    2) This procedure should only be used within Workflow
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
);

PROCEDURE ProcessSubscription
/*******************************************************************************
** Start of comments
**  Procedure   : ProcessSubscribtion
**  Description : Creates a grant for a group calendar
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT  NOCOPY   VARCHAR2 required
**
**  Notes :
**    1) This procedure should only be used within Workflow
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
);

PROCEDURE ProcessRequest
/*******************************************************************************
** Start of comments
**  Procedure   : ProcessRequest
**  Description : If required this function creates resource group, resource
**                usage and or grants in order to create a group or public
**                calendar
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT  NOCOPY   VARCHAR2 required
**
**  Notes :
**    1) This procedure should only be used within Workflow
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
);
PROCEDURE ProcessInvitation
/*******************************************************************************
** Start of comments
**  Procedure   : ProcessInvitation
**  Description : Given the
**  Parameters  :
**      name                direction  type     required?
**      ----                ---------  ----     ---------
**      p_api_version       IN         NUMBER   required
**      p_init_msg_list     IN         VARCHAR2 optional
**      p_commit            IN         VARCHAR2 optional
**      x_return_status        OUT  NOCOPY   VARCHAR2 optional
**      x_msg_count            OUT  NOCOPY   NUMBER   required
**      x_msg_data             OUT  NOCOPY   VARCHAR2 required
**      p_task_assignment_id   IN      NUMBER   required
**      p_resource_type        IN      VARCHAR2 required
**      p_resource_id          IN      NUMBER   required
**      p_assignment_status_id IN      NUMBER   required
**  Notes :
**    1) Created for ER 2219647
**
** End of comments
*******************************************************************************/
( p_api_version        IN     NUMBER
, p_init_msg_list      IN     VARCHAR2
, p_commit             IN     VARCHAR2
, x_return_status      OUT    NOCOPY	VARCHAR2
, x_msg_count          OUT    NOCOPY	NUMBER
, x_msg_data           OUT    NOCOPY	VARCHAR2
, p_task_assignment_id IN     NUMBER
, p_resource_type      IN     VARCHAR2
, p_resource_id        IN     NUMBER
, p_assignment_status_id IN NUMBER
);

PROCEDURE GetInvitationStatus
/*******************************************************************************
** Start of comments
**  Procedure   : GetInvitationStatus
**  Description : Set the attributes for the invitation status and determine which
**                notification to send
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     NOCOPY VARCHAR2 required
**
**  Notes :
**    1) Expects WF item attributes 'ASSIGNMENT_STATUS_ID' to be available to this procedure.
**    2) This procedure should only be used within Workflow
**    3) Created for 2219647
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout  OUT    NOCOPY	VARCHAR2
);



PROCEDURE StartReminders
/*******************************************************************************
** Start of comments
**  Procedure   : StartReminder
**  Description : Given the task ID of the appointment (p_TaskID) and the
**                Resource ID of the invitor (p_INVITOR) this procedure will
**                start WF reminders for all the attendees of the appointment.
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT  NOCOPY   VARCHAR2 optional
**      x_msg_count           OUT  NOCOPY   NUMBER   required
**      x_msg_data            OUT  NOCOPY   VARCHAR2 required
**      p_INVITOR          IN         NUMBER   required
**      p_TaskID           IN         NUMBER   required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit        IN     VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_INVITOR       IN     NUMBER   -- Resource ID of Invitor
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
, p_RemindDate    IN     DATE     -- Date/Time the reminder needs to be send
);

PROCEDURE SendReminders
/*******************************************************************************
** Start of comments
**  Procedure   : SendReminders
**  Description :
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT     NOCOPY VARCHAR2 required
**
**  Notes :
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
);

PROCEDURE UpdateReminders
/*******************************************************************************
** Start of comments
**  Procedure   : UpdateReminders
**  Description : Given the task ID and a new reminder date this procedure will
**                update all the reminders for the appointment, should only be
**                called if the reminder me or start date has changed
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT  NOCOPY    VARCHAR2 optional
**      x_msg_count           OUT  NOCOPY    NUMBER   required
**      x_msg_data            OUT  NOCOPY    VARCHAR2 required
**      p_TaskID           IN         NUMBER   required
**      p_RemindDate       IN         DATE     required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2 DEFAULT fnd_api.g_false
, p_commit        IN     VARCHAR2
, x_return_status    OUT NOCOPY VARCHAR2
, x_msg_count        OUT NOCOPY NUMBER
, x_msg_data         OUT NOCOPY VARCHAR2
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
, p_RemindDate    IN     DATE     -- NEW Date/Time the reminder needs to be send
);

PROCEDURE GetRepeatingRule
/*******************************************************************************
** Start of comments
**  Procedure   : GetRepeatingRule
**  Description : Set the attributes for the repeating rule and determine which
**                notification to send
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      itemtype           IN         VARCHAR2 required
**      itemkey            IN         VARCHAR2 required
**      actid              IN         NUMBER   required
**      funcmode           IN         VARCHAR2 required
**      resultout             OUT NOCOPY    VARCHAR2 required
**
**  Notes :
**    1) Expects WF item attributes 'TASK_ID' to be available to this procedure.
**    2) This procedure should only be used within Workflow
**
** End of comments
******************************************************************************/
( itemtype   IN     VARCHAR2
, itemkey    IN     VARCHAR2
, actid      IN     NUMBER
, funcmode   IN     VARCHAR2
, resultout     OUT NOCOPY VARCHAR2
);

PROCEDURE UpdateAttendee
/*******************************************************************************
** Start of comments
**  Procedure   : UpdateReminders
**  Description : Given the task ID and a new reminder date this procedure will
**                update all the reminders for the appointment, should only be
**                called if the reminder me or start date has changed
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_TaskID           IN         NUMBER   required
**      p_RemindDate       IN         DATE     required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITEE       IN     NUMBER   -- Resource ID of Invitee
, p_INVITEE_TYPE  IN     VARCHAR2 --Resource Type of the INVITEE
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
);

PROCEDURE DeleteAttendee
/*******************************************************************************
** Start of comments
**  Procedure   : DeleteAttendee
**  Description : Given the task ID and the Invitee id this procedure will
**                send reminders to attendees if the appointment is deleted
**
**  Parameters  :
**      name               direction  type     required?
**      ----               ---------  ----     ---------
**      p_api_version      IN         NUMBER   required
**      p_init_msg_list    IN         VARCHAR2 optional
**      p_commit           IN         VARCHAR2 optional
**      x_return_status       OUT     VARCHAR2 optional
**      x_msg_count           OUT     NUMBER   required
**      x_msg_data            OUT     VARCHAR2 required
**      p_TaskID           IN         NUMBER   required
**      p_RemindDate       IN         DATE     required
**      p_INVITEE          IN         NUMBER   required
**      p_INVITEE_TYPE     IN         VARCHAR2 required
**  Notes :
**    1) If an invitee does not exist in the WF directory a notification will
**       be send to the invitor saying that the invitation was not send.
**    2) Currently invitations are only send to employees
**    3) The WFs won't be started until a commmit is done.
**
** End of comments
*******************************************************************************/
( p_api_version   IN     NUMBER
, p_init_msg_list IN     VARCHAR2
, p_commit        IN     VARCHAR2
, x_return_status OUT    NOCOPY	VARCHAR2
, x_msg_count     OUT    NOCOPY	NUMBER
, x_msg_data      OUT    NOCOPY	VARCHAR2
, p_INVITEE       IN     NUMBER   -- Resource ID of Invitee
, p_INVITEE_TYPE  IN     VARCHAR2 --Resource Type of the INVITEE
, p_TaskID        IN     NUMBER   -- Task ID of the appointment
);

END CAC_VIEW_WF_PVT;

 

/
