--------------------------------------------------------
--  DDL for Package PER_ORG_BGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_ORG_BGT_PKG" AUTHID CURRENT_USER AS
/* $Header: pebgt02t.pkh 115.0 99/07/17 18:47:14 porting ship $ */
--
-- PROCEDURE GET_MANAGERS: Populate No of managers, manager name and
-- managers employee number within the control block.
-- If no managers then manager name reflects this.
-- If more than one then manager name also reflects this.
-- else if only one manager then the name and emp no is provided.
--
procedure get_managers(X_ORGANIZATION_ID   Number,
                       X_BUSINESS_GROUP_ID Number,
                       X_NO_OF_MANAGERS    IN OUT VARCHAR2,
                       X_MANAGER_NAME      IN OUT VARCHAR2,
                       X_MANAGER_EMP_NO    IN OUT VARCHAR2);
--
END PER_ORG_BGT_PKG;

 

/
