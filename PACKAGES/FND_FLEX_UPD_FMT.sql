--------------------------------------------------------
--  DDL for Package FND_FLEX_UPD_FMT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_FLEX_UPD_FMT" AUTHID CURRENT_USER AS
/* $Header: AFFFUPFS.pls 115.0 99/07/16 23:20:08 porting ship $ */

PROCEDURE convert_date(table_name      IN VARCHAR2,
		  column_name     IN VARCHAR2,
		  new_format_type IN VARCHAR2,
		  old_format      IN VARCHAR2 DEFAULT NULL);





END fnd_flex_upd_fmt;

 

/
