--------------------------------------------------------
--  DDL for Package Body IGP_USER_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGP_USER_GEN_001" AS
/* $Header: IGSPUSAB.pls 120.0 2005/06/01 20:36:01 appldev noship $ */

  /***********************************************************************************************
    Created By     :  SMVK
    Date Created By:  12-Feb-2004
    Purpose        :  This package provides the facility to create adhoc user with the specified email id.
                      Also add the adhoc user to adhoc role.

    Known limitations,enhancements,remarks:
    Change History (in reverse chronological order)
    Who         When            What
  ********************************************************************************************** */

  PROCEDURE create_role( p_adhoc_role IN OUT NOCOPY VARCHAR2,
                       p_role_dsp IN OUT NOCOPY VARCHAR2,
                       p_adhoc_user IN OUT NOCOPY VARCHAR2,
                       p_user_dsp IN OUT NOCOPY VARCHAR2,
                       p_mail_address IN VARCHAR2) AS

  BEGIN
    Wf_Directory.CreateAdHocRole (
        role_name         => p_adhoc_role,
        role_display_name => p_role_dsp
    );


    Wf_Directory.CreateAdHocUser(
         name              => p_adhoc_user,
         display_name      => p_user_dsp,
         email_address     => p_mail_address
    );


    Wf_Directory.AddUsersToAdHocRole (
         role_name  => p_adhoc_role,
         role_users => p_adhoc_user
    );


  END create_role;

  PROCEDURE  check_action(itemtype IN VARCHAR2,
                          itemkey  IN VARCHAR2,
                          actid    IN NUMBER,
                          funcmode IN VARCHAR2,
                          resultout OUT NOCOPY VARCHAR2)
   AS
    /*
    ||  Created By : vijrajag
    ||  Created On : 1/28/2004
    ||  Purpose : Checks the p_action and returns the lookup code for lookup type action.
    ||  Known limitations, enhancements or remarks :
    ||  Change History :
    ||  Who             When            What
    ||  (reverse chronological order - newest change first)
    */

       l_action            VARCHAR2(30);
       l_url               VARCHAR2(2000);

  BEGIN

   l_action    := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_ACTION');
   l_url       := Wf_Engine.GetItemAttrText(itemtype,itemkey,'P_URL');
   l_url       := '<a href='||l_url||'>'||l_url||'</a>';
   wf_engine.SetItemAttrText(itemtype,itemkey,'P_URL', l_url);
      IF (l_action = 'NEW' ) THEN resultout := 'COMPLETE:NEW';
      ELSIF  (l_action='UPDATE')THEN resultout := 'COMPLETE:UPDATE';
      ELSIF (l_action='RESEND') THEN resultout := 'COMPLETE:RESEND';
      END IF;

  EXCEPTION
    WHEN others THEN
      NULL;
  END CHECK_ACTION;

END igp_user_gen_001;

/
