--------------------------------------------------------
--  DDL for Package HR_KI_UCX_LOAD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_KI_UCX_LOAD_API" AUTHID CURRENT_USER as
/* $Header: hrkiucxl.pkh 120.0 2005/05/31 01:10:43 appldev noship $ */
--
-- Package Variables
--
--

procedure LOAD_ROW
  (
    X_USER_INTERFACE_KEY in VARCHAR2,
    X_UI_CONTEXT_KEY     in VARCHAR2,
    X_LABEL              in VARCHAR2,
    X_LOCATION           in VARCHAR2,
    X_LAST_UPDATE_DATE   in VARCHAR2,
    X_CUSTOM_MODE        in VARCHAR2,
    X_OWNER              in VARCHAR2

   );

END HR_KI_UCX_LOAD_API;

 

/
