--------------------------------------------------------
--  DDL for Package OE_UPG_PC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_UPG_PC" AUTHID CURRENT_USER AS
/* $Header: OEXIUPCS.pls 120.0 2005/06/01 01:38:36 appldev noship $ */

     PROCEDURE Upgrade_insert_condns;
     PROCEDURE Upgrade_insert_scope;

END oe_Upg_pc;

 

/
