--------------------------------------------------------
--  DDL for Package Body FUN_CONTACTUS_EMAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_CONTACTUS_EMAIL" AS
/* $Header: FUN_CONTACTUS_EMAIL.plb 120.1 2006/05/26 22:55:02 skaneshi noship $ */

-- Internal constants

G_PKG_NAME       CONSTANT VARCHAR2(30)    := 'FUN_CONTACTUS_EMAIL';
G_RETURN_SUCCESS CONSTANT VARCHAR2(1)     := 'S';
G_RETURN_FAIL    CONSTANT VARCHAR2(1)     := 'F';

/*========================================================================
 | PUBLIC PROCEDURE send_notification
 |
 | DESCRIPTION
 |   This procedure sets the workflow attributes and starts the workflow
 |   process for workflow item FUNCNCT.  The workflow process simply sends
 |   a notification.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_request_id          IN Contact Us request Id, workflow key
 |   p_from_role           IN Role name for person submitting the request
 |   p_to_email_address    IN Email address for the help desk analyst
 |   p_problem_summary     IN Problem summary entered by the submitter
 |   p_alternative_contact IN Alternative contact information for the
 |                            submitter
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Apr-2005           SKANESHI          Created
 |
 *=======================================================================*/
PROCEDURE send_notification(p_request_id IN NUMBER,
                            p_from_role IN VARCHAR2,
                            p_to_email_address IN VARCHAR2,
                            p_problem_summary IN VARCHAR2,
                            p_alternative_contact IN VARCHAR2)
IS
 l_text_offset             NUMBER :=0;
 l_text_name_array         wf_engine.nametabtyp;
 l_text_value_array        wf_engine.texttabtyp;

 l_role_name               VARCHAR2(250);
 l_role_display_name       VARCHAR2(250);

 l_display_name            VARCHAR2(250);
 l_email_address           VARCHAR2(250);
 l_notification_preference VARCHAR2(250);
 l_language                VARCHAR2(250);
 l_territory               VARCHAR2(250);

BEGIN

  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME,
                                            'start send_notification');
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME,
      'parameters: p_request_id = ' || p_request_id ||
      ', p_from_role = ' || p_from_role ||
      ', p_to_email_address = ' || p_to_email_address ||
      ', p_problem_summary = ' || p_problem_summary ||
      ', p_alternative_contact = ' || p_alternative_contact);
  end if;

 /*------------------------------------------------------------------+
  | Create a process using the WF definition for sending emails to   |
  | helpdesk analyst                                                 |
  +------------------------------------------------------------------*/
  wf_engine.createprocess('FUNCTUS',
                          p_request_id,
                          'FUN_SEND_EMAIL',
                          '',
                          p_from_role);

 /*------------------------------------------------------------------+
  | Get sender information                                           |
  +------------------------------------------------------------------*/
  wf_directory.getroleinfo(p_from_role,
                           l_display_name,
                           l_email_address,
                           l_notification_preference,
                           l_language,
                           l_territory);

 /*------------------------------------------------------------------+
  | Set attribute values                                             |
  +------------------------------------------------------------------*/
  wf_engine.setitemattrnumber('FUNCTUS', p_request_id,
                              'FUN_REQUEST_ID', p_request_id);

 /*------------------------------------------------------------------+
  | Set the recipient to adhoc role                                  |
  +------------------------------------------------------------------*/
  IF (p_to_email_address IS NOT NULL) THEN
    l_role_name := upper(p_to_email_address);
    l_role_display_name := p_to_email_address;

    IF (Wf_Directory.getRoleDisplayName(l_role_name) IS NULL) THEN
      -- Create adhoc role if does not already exist
      Wf_Directory.CreateAdHocRole(role_name               => l_role_name,
                                   role_display_name       => l_role_display_name,
                                   email_address           => p_to_email_address);
    END IF;

    -- Set role attribute
    l_text_offset := l_text_offset + 1;
    l_text_name_array(l_text_offset) := 'FUN_RECIPIENT';
    l_text_value_array(l_text_offset) := l_role_name;

  end if;

 /*------------------------------+
  | Set the sender information   |
  +------------------------------*/
  l_text_offset := l_text_offset + 1;
  l_text_name_array(l_text_offset) := 'FUN_SENDER';
  l_text_value_array(l_text_offset) := p_from_role;

  l_text_offset := l_text_offset + 1;
  l_text_name_array(l_text_offset) := 'FUN_SENDER_DISPLAY_NAME';
  l_text_value_array(l_text_offset) := l_Display_Name;

  l_text_offset := l_text_offset + 1;
  l_text_name_array(l_text_offset) := 'FUN_SENDER_EMAIL_ADDRESS';
  l_text_value_array(l_text_offset) := l_Email_Address;

  l_text_offset := l_text_offset + 1;
  l_text_name_array(l_text_offset) := 'FUN_PROBLEM_SUMMARY';
  l_text_value_array(l_text_offset) := p_problem_summary;

  l_text_offset := l_text_offset + 1;
  l_text_name_array(l_text_offset) := 'FUN_ALTERNATIVE_CONTACT';
  l_text_value_array(l_text_offset) := p_alternative_contact;

  wf_engine.setitemattrtextarray('FUNCTUS', p_request_id,
                                 l_text_name_array, l_text_value_array);

 /*----------------------------------+
  | Start the notification process   |
  +----------------------------------*/
  wf_engine.startprocess('FUNCTUS',
                         p_request_id);


  if (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME,
                                            'end send_notification');
  end if;

END send_notification;

/*========================================================================
 | PUBLIC PROCEDURE get_user_info
 |
 | DESCRIPTION
 |   This procedure returns the full name and email address for the
 |   FND User with the user_id set to p_user_id.
 |
 | CALLED FROM PROCEDURES/FUNCTIONS (local to this package body)
 |   Called from BC4J.
 |
 | CALLS PROCEDURES/FUNCTIONS (local to this package body)
 |   get_employee_cwk_info
 |   get_customer_info
 |   get_vendor_contact_info
 |
 | RETURNS
 |
 | PARAMETERS
 |   p_user_id          IN  FND user Id
 |   p_full_name        OUT full name
 |   p_email_address    OUT email address
 |   p_return_status    OUT return status.  'S' if found user info, 'F' otherwise.
 |
 | MODIFICATION HISTORY
 | Date                  Author            Description of Changes
 | 22-Apr-2005           SKANESHI          Created
 |
 *=======================================================================*/
PROCEDURE get_user_info(p_user_id IN NUMBER,
                        p_full_name OUT NOCOPY VARCHAR2,
                        p_email_address OUT NOCOPY VARCHAR2,
		        p_return_status OUT NOCOPY VARCHAR2)
IS
  l_user_name     fnd_user.user_name%TYPE;
  l_email_address fnd_user.email_address%TYPE;
  l_employee_id   fnd_user.employee_id%TYPE;
  l_customer_id   fnd_user.customer_id%TYPE;
  l_vendor_id     fnd_user.supplier_id%TYPE;
BEGIN
  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME,
                                            'start get_user_info');
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME,
      'parameters: p_user_id = ' || p_user_id ||
      ', p_full_name = ' || p_full_name ||
      ', p_email_address = ' || p_email_address);
  END IF;

  p_full_name := NULL;
  p_email_address := NULL;
  p_return_status := G_RETURN_FAIL;

  IF (p_user_id = -1) THEN
    RETURN;
  END IF;

  -- Get basic info and user type
  SELECT user_name, email_address, employee_id, customer_id, supplier_id
  INTO   l_user_name, l_email_address, l_employee_id, l_customer_id,
         l_vendor_id
  FROM   fnd_user
  WHERE  user_id = p_user_id
  AND    SYSDATE BETWEEN NVL(start_date, SYSDATE) AND NVL(end_date, SYSDATE);

  IF (l_employee_id IS NOT NULL) THEN
    -- FND user is an employee
    SELECT pwx.full_name full_name, pwx.email_address email_address
    INTO   p_full_name, p_email_address
    FROM   fnd_user fu, per_workforce_current_x pwx
    WHERE  fu.employee_id IS NOT NULL
    AND    fu.employee_id = pwx.person_id
    AND    SYSDATE BETWEEN NVL(fu.start_date, SYSDATE) AND NVL(fu.end_date, SYSDATE)
    AND    fu.user_id = p_user_id;

  ELSIF (l_customer_id IS NOT NULL) THEN
    -- FND User is a customer
    SELECT hp.party_name full_name, hp.email_address email_address
    INTO   p_full_name, p_email_address
    FROM   fnd_user fu, hz_parties hp
    WHERE  fu.customer_id IS NOT NULL
    AND    fu.customer_id = hp.party_id
    AND    fu.user_id = p_user_id;

  ELSIF (l_vendor_id IS NOT NULL) THEN
    -- FND User is a supplier
    SELECT pvc.last_name || ', ' || pvc.first_name full_name, pvc.email_address email_address
    INTO   p_full_name, p_email_address
    FROM   fnd_user fu, po_vendor_contacts pvc
    WHERE  fu.supplier_id IS NOT NULL
    AND    fu.supplier_id = pvc.vendor_contact_id
    AND    NVL(pvc.inactive_date, SYSDATE) >= SYSDATE
    AND    fu.user_id = p_user_id;

  END IF;

  -- Set name to user name if not defined
  IF (p_full_name IS NULL) THEN
    p_full_name := l_user_name;
  END IF;

  -- Use email address defiend in FND User if not set elsewhere
  IF (p_email_address IS NULL) THEN
    p_email_address := l_email_address;
  END IF;
  p_return_status := G_RETURN_SUCCESS;

  IF (FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME,
                                            'end get_user_info');
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    -- Return status initialized to fail
    RETURN;
  WHEN OTHERS THEN
    -- Return status initialized to fail
    RETURN;

END;

END FUN_CONTACTUS_EMAIL;

/
