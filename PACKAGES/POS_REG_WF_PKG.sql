--------------------------------------------------------
--  DDL for Package POS_REG_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_REG_WF_PKG" AUTHID CURRENT_USER as
/* $Header: POSREGWS.pls 120.1 2006/06/28 23:03:49 jpasala noship $ */

V_PACKAGE_NAME CONSTANT ALL_OBJECTS.OBJECT_NAME%TYPE := 'POS_REG_WF_PKG';

/*----------------------------------------

  public PROCEDURE LockReg

     Workflow activity function. Lock the registration record to prevent
     spontaneous responses to the same invitation.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if the record is successfully locked.
    COMPLETE:ERROR   - if the record's status has changed when getting the lock

----------------------------------------*/

PROCEDURE LockReg(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE LockApprv

     Workflow activity function. Lock the registration record (to be approved)
     to prevent spontaneous approving process.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if the record is successfully locked.
    COMPLETE:ERROR   - if the record's status has changed when getting the lock

----------------------------------------*/

PROCEDURE LockApprv(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE LockRjct

     Workflow activity function. Lock the registration record (to be rejected)
     to prevent spontaneous rejection.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if the record is successfully locked.
    COMPLETE:ERROR   - if the record's status has changed when getting the lock

----------------------------------------*/

PROCEDURE LockRjct(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE UpdInvTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdInvTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE UpdRegTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdRegTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE UpdApprvTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdApprvTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE UpdRjctTypeKey

     Workflow activity function. Update registration details with the itemtype
     and item key

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE : always return COMPLETE. do not raise errors.

----------------------------------------*/

PROCEDURE UpdRjctTypeKey(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE SetInvItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_INVITED'
     process.
     Following attributes are set:

       * REGISTRANT_LANGUAGE
       * REGISTRANT_EMAIL            * ADHOC_USER_NAME
       * ENTERPRISE_NAME             * REG_PAGE_URL

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetInvItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE SetRegItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_REGISTERED'
     process.
     Following attributes are set:

       * APPROVER_ROLE
       * FIRST_NAME                  * LAST_NAME
       * VENDOR_NAME                 * APPROVAL_PAGE_URL

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetRegItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE SetApprvItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_APPROVED'
     process.
     Following attributes are set:

       * ENTERPRISE_NAME             * LOGON_PAGE_URL
       * CONTACT_EMAIL               * IS_INVITED
       * ADHOC_USER_NAME             * REQUESTED_USER_NAME
       * REGISTRANT_EMAIL            * VENDOR_ID
       * POS_SELECTED                * PON_SELECTED
       * FIRST_NAME                  * LAST_NAME

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetApprvItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE SetRjctItemAttrValues

     Workflow activity function. Set item attribute values in 'USER_REJECTED'
     process.
     Following attributes are set:

       * REGISTRANT_LANGUAGE         * IS_INVITED
       * REGISTRANT_EMAIL            * ADHOC_USER_NAME
       * ENTERPRISE_NAME             * CONTACT_EMAIL

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok.
    COMPLETE:ERROR   - if critical attribute cannot be set.

----------------------------------------*/

PROCEDURE SetRjctItemAttrValues(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE CreateLocalUser

     Workflow activity function. Create a workflow ad-hoc (local) user.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:SUCCESS - if everything is ok
    COMPLETE:ERROR   - if anything wrong

----------------------------------------*/

PROCEDURE CreateLocalUser(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE DeleteLocalUser

     Workflow activity function. Delete a workflow ad-hoc (local) user.

  PARAMS:
    WF Standard API.

  RETURN:
    WF Standard API.

----------------------------------------*/

PROCEDURE DeleteLocalUser(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE CreateUser

     Workflow activity function. Actually create the user in FND_USER.
     Following activities are done:
       * generate random user password
       * insert FND_USER
       * insert TCA
       * assign user responsibility
       * set user security attributes

     Two item attribute values are set:

       * ASSIGNED_USER_NAME                * FIRST_LOGON_KEY

  PARAMS:
    WF Standard API.

  RETURN:
    WF Standard API.

----------------------------------------*/

PROCEDURE CreateUser(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE IsInvited

     Workflow activity function. Check whether the registration is invited.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:Y - if the registration is invited;
    COMPLETE:N - otherwise

----------------------------------------*/

PROCEDURE IsInvited(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE CheckRejectMailSent

     Workflow activity function. Check whether the rejection email has been
     sent or not

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:Y - if the mail has been sent
    COMPLETE:N - otherwise

----------------------------------------*/

PROCEDURE CheckRejectMailSent(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);

/*----------------------------------------

  public PROCEDURE MarkSuccess

     Workflow activity function. Mark the success of this workflow process
     by pushing "success" message.

  PARAMS:
    WF Standard API.

  RETURN:
    WF Standard API.

----------------------------------------*/

PROCEDURE MarkSuccess(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);


/*----------------------------------------

   PROCEDURE check_isp_resp_sec_attr

    This procedure will create iSP securing attributes
    (ICX_SUPPLIER_ORG_ID, ICX_SUPPLIER_SITE_ID, ICX_SUPPLIER_CONTACT_ID)
    for the responsibility, if they are not defined. It will also
    set the default value (-9999) for the securing attributes
    ICX_SUPPLIER_SITE_ID and ICX_SUPPLIER_CONTACT_ID for the responsibility,
    if they are not defined.

  PARAM:
     p_resp_id          IN NUMBER    - responsibility id
     p_resp_appl_id     IN NUMBER    - responsibility application  id

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/

PROCEDURE check_isp_resp_sec_attr
  (p_resp_id      IN NUMBER,
   p_resp_appl_id IN NUMBER);


/*----------------------------------------

  private PROCEDURE check_isp_resp_sec_attr

    Overload check_isp_resp_sec_attr(NUMBER, NUMBER) to take the responsibility
    key.

  PARAM:
     p_resp_key         IN VARCHAR2  - the responsibility key
     p_resp_appl_id     IN NUMBER    - responsibility application  id

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/

PROCEDURE check_isp_resp_sec_attr
  (p_resp_key     IN VARCHAR2,
   p_resp_appl_id IN NUMBER);

/*----------------------------------------

  PROCEDURE AssginResp

    Assgin responsibility to user

  PARAM:
    p_user_id IN NUMBER     - the FND_USER id of the assignee
    p_resp_app_id IN NUMBER - the application id associated with the resp
    p_resp_key IN VARCHAR2  - the responsibility key

  EXCEPTION:
    none. Do not raise exception.

----------------------------------------*/
PROCEDURE AssginResp(
  p_user_id IN NUMBER
, p_resp_app_id IN NUMBER
, p_resp_key IN VARCHAR2
);

/*----------------------------------------

  PROCEDURE SetSecAttr

    Set security atttribute to the user.

  PARAM:
    p_user_id IN NUMBER          - the FND_USER id of the assignee
    p_attribute_code IN VARCHAR2 - the security attribute code
    p_app_id IN NUMBER           - the application id associated with the
				   security code
    p_varchar2_value IN VARCHAR2 - the VARCHAR2 value DEFAULT NULL
    p_date_value IN DATE         - date value DEFAULT NULL
    p_number_value IN NUMBER     - number value DEFAULT NULL

    Note: one of the three values must be NOT NULL.

  EXCEPTION:

    Raise exceptions.

----------------------------------------*/
PROCEDURE SetSecAttr(
  p_user_id IN NUMBER
, p_attribute_code IN VARCHAR2
, p_app_id IN NUMBER
, p_varchar2_value IN VARCHAR2 DEFAULT NULL
, p_date_value IN DATE DEFAULT NULL
, p_number_value IN NUMBER DEFAULT NULL
);

FUNCTION isPasswordChangeable ( username in varchar2) return varchar2;

/*----------------------------------------
function set_initial_password
  set the initial password for osn
  registration request, so the user
  doesn't need to change password at
  first logon
----------------------------------------*/
function set_initial_password(l_reg_id NUMBER)  return varchar2;


/*----------------------------------------

  public PROCEDURE IsOsnRequest

     Workflow activity function. Check whether the registration is invited.

  PARAMS:
    WF Standard API.

  RETURN:
    COMPLETE:Y - if the registration request is from Oracle Supplier Network;
    COMPLETE:N - otherwise

----------------------------------------*/

PROCEDURE IsOsnRequest(
  itemtype IN VARCHAR2
, itemkey IN VARCHAR2
, actid IN NUMBER
, funcmode IN VARCHAR2
, resultout OUT NOCOPY VARCHAR2
);


PROCEDURE set_profile_opt_ext_user
(p_userid in number);

END POS_REG_WF_PKG;

 

/
