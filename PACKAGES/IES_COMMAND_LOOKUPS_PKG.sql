--------------------------------------------------------
--  DDL for Package IES_COMMAND_LOOKUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_COMMAND_LOOKUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: iescmdls.pls 115.2 2003/01/06 20:41:03 appldev noship $ */
  TYPE CHOICE IS RECORD(VALUE VARCHAR2(2000), DISPLAY_VALUE VARCHAR2(2000));
END IES_COMMAND_LOOKUPS_PKG; -- Package spec

 

/
