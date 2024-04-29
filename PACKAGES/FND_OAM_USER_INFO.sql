--------------------------------------------------------
--  DDL for Package FND_OAM_USER_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_OAM_USER_INFO" AUTHID CURRENT_USER AS
/* $Header: AFOAMUIS.pls 120.2 2005/10/20 12:30:51 ilawler noship $ */
-------------------------------------------------------------------------------

  -- Name
  --   get_contact_info
  --
  -- Purpose
  --   Returns the contact information of a user
  --
  -- Input Arguments
  --   p_username - User name.
  --
  -- Output Arguments
  --   full_name - Full name of the person
  --   phone     - Phone number
  --   email     - Email address
  --   fax       - Fax number
  --   user_guid - User_guid
  --
  PROCEDURE get_contact_info
    (p_username IN VARCHAR2,
     full_name  OUT NOCOPY VARCHAR2,
     phone      OUT NOCOPY VARCHAR2,
     email      OUT NOCOPY VARCHAR2,
     fax        OUT NOCOPY VARCHAR2,
     user_guid OUT  NOCOPY VARCHAR2);

  --
  -- Return PARTY_ID given EMPLOYEE_ID
  --
  function GET_PARTY_ID(P_EMPLOYEE_ID in number) return number;

  --
  -- Given PARTY_ID return PARTY_NAME, PARTY_TYPE
  --
  procedure HZ_PARTY_ID_TO_NAME(P_PARTY_ID in number,
                                P_PARTY_NAME out nocopy varchar2,
                                P_PARTY_TYPE out nocopy varchar2);

  --
  -- Given PARTY_NAME return PARTY_ID, PARTY_TYPE
  --
  procedure HZ_PARTY_NAME_TO_ID(P_PARTY_NAME in varchar2,
                                P_PARTY_ID OUT NOCOPY number,
                                P_PARTY_TYPE out nocopy varchar2);

  --
  -- Get organization party ID given customer party ID
  --
  function GET_ORGANIZATION_ID(P_CUSTOMER_ID in number) return number;

END fnd_oam_user_info;

 

/
