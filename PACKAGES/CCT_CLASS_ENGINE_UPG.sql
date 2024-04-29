--------------------------------------------------------
--  DDL for Package CCT_CLASS_ENGINE_UPG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CCT_CLASS_ENGINE_UPG" AUTHID CURRENT_USER as
/* $Header: cctupgcs.pls 120.0 2005/06/02 09:58:31 appldev noship $ */

procedure Upgrade_Class_Schema ;

procedure fix_class_priorities;

procedure Upgrade_Class_BI;

procedure UpgradeIKeys;

END CCT_CLASS_ENGINE_UPG;

 

/
