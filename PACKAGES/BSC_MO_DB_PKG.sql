--------------------------------------------------------
--  DDL for Package BSC_MO_DB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MO_DB_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCMODBS.pls 120.3 2005/10/21 09:07:56 arsantha noship $ */
TYPE CurTyp IS REF CURSOR;
PROCEDURE CreateAllTables;
Function GetPeriodColumnName(Periodicity IN NUMBER) RETURN VARCHAR2;
Function GetSubperiodColumnName(Periodicity IN VARCHAR2) RETURN VARCHAR2 ;
PROCEDURE create_tables_spawned(pStripe IN NUMBER) ;

PROCEDURE create_tables_spawned(
            Errbuf         out NOCOPY Varchar2,
            Retcode        out NOCOPY Varchar2,
            pStripe        IN NUMBER,
            pTableName     IN VARCHAR2) ;

PROCEDURE spawn_child_processes;

END BSC_MO_DB_PKG;

 

/
