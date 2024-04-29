--------------------------------------------------------
--  DDL for Package QA_CHAR_UPDATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_CHAR_UPDATE_PKG" AUTHID CURRENT_USER AS
/* $Header: qacharus.pls 120.0 2005/05/24 18:31:42 appldev noship $ */

--
-- FILE NAME
-- qacharus.pls
--
-- PACKAGE NAME
-- QA_CHAR_UPDATE_PKG
--
-- DESCRIPTION
-- This package is used for Updating all instances QA Schema when a value
-- stored for a Collection Element has changed externally.
--
-- This package was primarily created for handling FND User Name Changes
-- Which are propagated to impacted products using a Workflow Business
-- Event Subscription ( oracle.apps.fnd.wf.ds.user.nameChanged ).
--
-- TRACKING BUG
-- 4305107
--
-- HISTORY
-- 12-APR-2005 Sivakumar Kalyanasunderam Created.


    -- Wrapper API which is invoked by the business event subscription
    -- when FND User Name Changes
    FUNCTION Update_User_Name
    (
      p_subscription_guid IN RAW,
      p_event             IN OUT NOCOPY WF_EVENT_T
    ) RETURN VARCHAR2;

    -- Core API which would accept the element, old value and new value
    -- and update all instances where the old value is stored
    -- with the new value.
    PROCEDURE Update_Element_Value
    (
      p_api_version      IN         NUMBER   := NULL,
      p_init_msg_list    IN         VARCHAR2 := NULL,
      p_commit           IN         VARCHAR2 := NULL,
      p_validation_level IN         NUMBER   := NULL,
      p_char_id          IN         NUMBER,
      p_old_value        IN         VARCHAR2,
      p_new_value        IN         VARCHAR2,
      x_return_status    OUT NOCOPY VARCHAR2,
      x_msg_count        OUT NOCOPY NUMBER,
      x_msg_data         OUT NOCOPY VARCHAR2
    );

END QA_CHAR_UPDATE_PKG;

 

/
