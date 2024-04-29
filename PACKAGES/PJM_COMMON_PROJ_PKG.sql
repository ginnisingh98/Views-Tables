--------------------------------------------------------
--  DDL for Package PJM_COMMON_PROJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PJM_COMMON_PROJ_PKG" AUTHID CURRENT_USER AS
/* $Header: PJMCMPJS.pls 120.0.12010000.1 2008/07/30 04:23:40 appldev ship $ */


Function Get_Common_Project
( X_Org_Id  IN NUMBER
) Return Number;

Procedure  Set_Common_Project
( X_Org_Id  IN NUMBER  DEFAULT NULL
);


END PJM_COMMON_PROJ_PKG;

/
