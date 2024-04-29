--------------------------------------------------------
--  DDL for Package HR_KI_HNM_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_HNM_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkihnml.pkh 115.0 2004/01/11 21:22:15 vkarandi noship $ */
--
-- Package Variables
--
--

procedure LOAD_ROW
  (
   X_HIERARCHY_KEY      in VARCHAR2,
   X_TOPIC_KEY          in VARCHAR2,
   X_USER_INTERFACE_KEY in VARCHAR2,
   X_LAST_UPDATE_DATE   in VARCHAR2,
   X_CUSTOM_MODE        in VARCHAR2,
   X_OWNER              in VARCHAR2
   );

END HR_KI_HNM_LOAD_API;

 

/
