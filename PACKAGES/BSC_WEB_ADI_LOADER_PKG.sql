--------------------------------------------------------
--  DDL for Package BSC_WEB_ADI_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_WEB_ADI_LOADER_PKG" AUTHID CURRENT_USER AS
/*$Header: BSCWADIS.pls 120.2.12000000.2 2007/06/08 12:39:20 karthmoh ship $*/

/*---------------------------------------------------------------------------
 API to create the WebADI Integrator, an integrator will be created with the
 code = <table_name>_INTG, also creates a Security Rule so that this
 integrator is accessible from PMA <table_name>_SEC
----------------------------------------------------------------------------*/
PROCEDURE CREATE_INTEGRATOR( TABLE_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create the WebADI Interface for each table with interface code =
 <table_name>_INTF, and assigns this interface to an already created Integrator
 for this table( <table_name>_INTG)
----------------------------------------------------------------------------*/
PROCEDURE CREATE_INTERFACE( TABLE_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create the WebADI Interface Columns corresponding to each Column in
 table, plus an additional column as a place holder for the Interface Table
 Name to be displayed in the Excel as the context
----------------------------------------------------------------------------*/
PROCEDURE CREATE_INTERFACE_COLUMNS( TAB_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create metadata about Layouts, Layout Blocks, Layout Columns
 Two Layout blocks are created one for the Context(Interface Table Name) and
 other for the actual table
 Layour code = <table_name>_L
----------------------------------------------------------------------------*/
PROCEDURE CREATE_LAYOUT( TAB_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create Content Metadata for the Integrator.
 COntent code = <table_name>_CNT
----------------------------------------------------------------------------*/
PROCEDURE CREATE_CONTENT( TAB_NAME VARCHAR2, x_errbuf OUT NOCOPY VARCHAR2
, x_retcode OUT NOCOPY VARCHAR2);

/*---------------------------------------------------------------------------
 API to create Mapping Metadata for the Integrator.
 COntent code = <table_name>_MAP
----------------------------------------------------------------------------*/
PROCEDURE CREATE_MAPPING(TAB_NAME VARCHAR2);

/*---------------------------------------------------------------------------
 API to clear all the WebADI metadata for application=BSC and pertaining to
 a particular Interface Table
----------------------------------------------------------------------------*/
PROCEDURE CLEAR_METADATA( TAB_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create all the WebADI metadata for application=BSC and pertaining to
 a particular Interface Table, this api will be called from the JAVA layer
----------------------------------------------------------------------------*/
PROCEDURE Create_Metadata( TAB_NAME VARCHAR2, ERRBUF OUT NOCOPY VARCHAR2,RETCODE OUT NOCOPY VARCHAR2);

/*---------------------------------------------------------------------------
 API to create Query for Duplicate Key Management for the Integrator.
 Query Code = <table_name>_Q
----------------------------------------------------------------------------*/
PROCEDURE CREATE_QUERY( TAB_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create 2 Parameters
 - Rows
 - Duplicate management
----------------------------------------------------------------------------*/
PROCEDURE CREATE_PARAM_DEFN( TAB_NAME VARCHAR2, key_cols NUMBER );

/*---------------------------------------------------------------------------
 API to create a Parameter List
 Parameter List Code = <table_name>_PL
----------------------------------------------------------------------------*/
PROCEDURE CREATE_PARAM_LIST( TAB_NAME VARCHAR2, key_cols NUMBER );

/*---------------------------------------------------------------------------
 API to create a Duplicate Profile
 Parameter List Code = <table_name>_REP / _ERR
----------------------------------------------------------------------------*/
PROCEDURE CREATE_DUP_PROFILE( TAB_NAME VARCHAR2 );

/*---------------------------------------------------------------------------
 API to create a Interface Keys
 Interface Key Code = <table_name>_UK
----------------------------------------------------------------------------*/
FUNCTION CREATE_INTERFACE_KEYS( TAB_NAME VARCHAR2 ) RETURN NUMBER;

FUNCTION get_lookup_value(type VARCHAR2, code VARCHAR2) return varchar2;

/* Not required in Production Mode
PROCEDURE clear_all_metadata;
*/
END BSC_WEB_ADI_LOADER_PKG;


 

/
