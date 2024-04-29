--------------------------------------------------------
--  DDL for Package IGP_USER_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_USER_GEN_001" AUTHID CURRENT_USER AS
  /* $Header: IGSPUSAS.pls 120.0 2005/06/01 22:11:05 appldev noship $ */

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
                               p_mail_address IN VARCHAR2);

PROCEDURE  check_action(itemtype IN VARCHAR2,
                        itemkey  IN VARCHAR2,
                        actid    IN NUMBER,
                        funcmode IN VARCHAR2,
                        resultout OUT NOCOPY VARCHAR2);

END igp_user_gen_001;

 

/
