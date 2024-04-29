--------------------------------------------------------
--  DDL for Package QP_ITEMGROUP_UPG_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QP_ITEMGROUP_UPG_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: QPXVUIGS.pls 120.0 2005/06/02 00:42:31 appldev noship $ */

--GLOBAL Constant holding the package name

G_PKG_NAME		    CONSTANT  VARCHAR2(30) := 'QP_ITEMGROUP_UPG_UTIL_PVT';

PROCEDURE Upgrade_Item_Groups;

END QP_ITEMGROUP_UPG_UTIL_PVT;

 

/
