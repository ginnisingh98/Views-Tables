--------------------------------------------------------
--  DDL for Package OPI_UOM_WH_PUSH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_UOM_WH_PUSH_PKG" AUTHID CURRENT_USER AS
/* $Header: OPIUOMPS.pls 115.1 2002/04/29 15:24:16 pkm ship     $ */

Procedure pushToSource(p_object_name IN VARCHAR2);
Function isInstanceRunning(p_mode IN NUMBER, p_db_link IN VARCHAR2, p_instance IN VARCHAR2) RETURN BOOLEAN;

End OPI_UOM_WH_PUSH_PKG;

 

/
