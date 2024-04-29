--------------------------------------------------------
--  DDL for Package PA_RATE_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RATE_ATTR_PKG" AUTHID CURRENT_USER AS
/* $Header: PARATTRS.pls 120.0 2005/06/03 13:29:04 appldev noship $ */
procedure RATE_ATTR_UPGRD(
  P_BUDGET_VER_TBL            IN   SYSTEM.PA_NUM_TBL_TYPE,
  X_RETURN_STATUS             OUT  NOCOPY VARCHAR2,
  X_MSG_COUNT                 OUT  NOCOPY NUMBER,
  X_MSG_DATA                  OUT  NOCOPY VARCHAR2);
end PA_RATE_ATTR_PKG;

 

/
