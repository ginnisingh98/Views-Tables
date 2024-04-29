--------------------------------------------------------
--  DDL for Package PER_PERSON_PROFILE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_PERSON_PROFILE" AUTHID CURRENT_USER AS
/* $Header: peppgpbe.pkh 120.0.12010000.2 2008/11/26 12:53:02 srgnanas noship $ */

FUNCTION raise_person_profile_event( p_subscription_guid IN RAW
                              ,p_event IN OUT NOCOPY WF_EVENT_T) RETURN VARCHAR2;
END per_person_profile;

/
