--------------------------------------------------------
--  DDL for Package CS_CF_UPG_BUGFIX1_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CF_UPG_BUGFIX1_PKG" AUTHID CURRENT_USER as
/* $Header: cscfupg2s.pls 120.0 2005/06/01 09:54:41 appldev noship $ */


PROCEDURE Main;

PROCEDURE Fix_Regions_BugFix1(p_contextType IN VARCHAR2);

END CS_CF_UPG_BUGFIX1_PKG;

 

/
