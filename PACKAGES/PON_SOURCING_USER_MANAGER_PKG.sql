--------------------------------------------------------
--  DDL for Package PON_SOURCING_USER_MANAGER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_SOURCING_USER_MANAGER_PKG" AUTHID CURRENT_USER as
/*$Header: PONSURMS.pls 120.1 2005/07/25 14:53:07 snatu noship $ */

PROCEDURE validate_user_data(
  p_username                        IN VARCHAR2
, X_DUMMY_DATA                      OUT NOCOPY VARCHAR2
, X_EXTRA_INFO                      OUT NOCOPY VARCHAR2
, X_ROW_IN_HR                       OUT NOCOPY VARCHAR2
, X_VENDOR_RELATIONSHIP             OUT NOCOPY VARCHAR2
, X_ENTERPRISE_RELATIONSHIP         OUT NOCOPY VARCHAR2
, x_status                          OUT NOCOPY VARCHAR2
, x_exception_msg                   OUT NOCOPY VARCHAR2
);

END PON_SOURCING_USER_MANAGER_PKG;

 

/
