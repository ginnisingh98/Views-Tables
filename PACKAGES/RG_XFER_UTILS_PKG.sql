--------------------------------------------------------
--  DDL for Package RG_XFER_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."RG_XFER_UTILS_PKG" AUTHID CURRENT_USER as
/* $Header: rgixutls.pls 120.4 2003/04/29 00:48:07 djogg ship $ */

/*** Variables ***/

FoundError   BOOLEAN;
FoundWarning BOOLEAN;

G_Error   NUMBER;
G_Warning NUMBER;
G_NoCOA   NUMBER;
G_NoError NUMBER;

/* Message Levels */
G_ML_Minimal  NUMBER;
G_ML_Normal   NUMBER;
G_ML_Full     NUMBER;

TYPE ListType IS TABLE OF VARCHAR2(100)
  INDEX BY BINARY_INTEGER;

copy_error EXCEPTION;


/*** Routines ***/

FUNCTION ping_link(LinkName VARCHAR2) RETURN BOOLEAN;

FUNCTION create_link(LinkName VARCHAR2,
                     Username VARCHAR2,
                     Password VARCHAR2,
                     ConnectString VARCHAR2) RETURN NUMBER;

FUNCTION drop_link(LinkName VARCHAR2) RETURN BOOLEAN;

PROCEDURE display_string(
            InputStr VARCHAR2
            );

PROCEDURE display_message(
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN DEFAULT FALSE,
            Token4      VARCHAR2 DEFAULT NULL,
            Token4Val   VARCHAR2 DEFAULT NULL,
            Token4Xlate BOOLEAN DEFAULT FALSE,
            Token5      VARCHAR2 DEFAULT NULL,
            Token5Val   VARCHAR2 DEFAULT NULL,
            Token5Xlate BOOLEAN DEFAULT FALSE
            );

PROCEDURE display_log(
            MsgLevel NUMBER,
            MsgName VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN  DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN  DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN  DEFAULT FALSE,
            Token4      VARCHAR2 DEFAULT NULL,
            Token4Val   VARCHAR2 DEFAULT NULL,
            Token4Xlate BOOLEAN  DEFAULT FALSE
            );

PROCEDURE display_error(
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN  DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN  DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN  DEFAULT FALSE
            );

PROCEDURE display_warning(
            MsgName     VARCHAR2,
            Token1      VARCHAR2 DEFAULT NULL,
            Token1Val   VARCHAR2 DEFAULT NULL,
            Token1Xlate BOOLEAN  DEFAULT FALSE,
            Token2      VARCHAR2 DEFAULT NULL,
            Token2Val   VARCHAR2 DEFAULT NULL,
            Token2Xlate BOOLEAN  DEFAULT FALSE,
            Token3      VARCHAR2 DEFAULT NULL,
            Token3Val   VARCHAR2 DEFAULT NULL,
            Token3Xlate BOOLEAN  DEFAULT FALSE,
            Token4      VARCHAR2 DEFAULT NULL,
            Token4Val   VARCHAR2 DEFAULT NULL,
            Token4Xlate BOOLEAN  DEFAULT FALSE
            );

PROCEDURE display_exception(
            ErrorNum    NUMBER,
            ErrorMsg    VARCHAR2
            );

PROCEDURE init(
            SourceCOAId NUMBER,
            TargetCOAId NUMBER,
            LinkName    VARCHAR2
            );

PROCEDURE insert_into_list(
            ListName  IN OUT NOCOPY ListType,
            ListCount IN OUT NOCOPY BINARY_INTEGER,
            Name      VARCHAR2
            );

FUNCTION search_list(
           ListName  ListType,
           ListCount BINARY_INTEGER,
           Name      VARCHAR2
           ) RETURN BINARY_INTEGER;

PROCEDURE copy_adjust_string(
            TargetStr IN OUT NOCOPY VARCHAR2,
            SourceStr VARCHAR2);

FUNCTION get_source_id(
           TableName     VARCHAR2,
           IdName        VARCHAR2,
           CompName      VARCHAR2,
           WhereClause   VARCHAR2 DEFAULT NULL
           ) RETURN NUMBER;

FUNCTION get_new_id(SequenceName VARCHAR2) RETURN NUMBER;

PROCEDURE insert_rows(
            SQLStmt VARCHAR2,
            Id NUMBER,
            UseCOAId BOOLEAN DEFAULT FALSE,
            UseRowId BOOLEAN DEFAULT FALSE,
            RecRowId ROWID   DEFAULT NULL
            );

PROCEDURE execute_sql_statement(SQLStmt VARCHAR2);

PROCEDURE substitute_tokens(
            InputStr  IN OUT NOCOPY VARCHAR2,
            Token1    VARCHAR2 DEFAULT NULL,
            Token1Val VARCHAR2 DEFAULT NULL,
            Token2    VARCHAR2 DEFAULT NULL,
            Token2Val VARCHAR2 DEFAULT NULL,
            Token3    VARCHAR2 DEFAULT NULL,
            Token3Val VARCHAR2 DEFAULT NULL,
            Token4    VARCHAR2 DEFAULT NULL,
            Token4Val VARCHAR2 DEFAULT NULL,
            Token5    VARCHAR2 DEFAULT NULL,
            Token5Val VARCHAR2 DEFAULT NULL,
            Token6    VARCHAR2 DEFAULT NULL,
            Token6Val VARCHAR2 DEFAULT NULL,
            Token7    VARCHAR2 DEFAULT NULL,
            Token7Val VARCHAR2 DEFAULT NULL,
            Token8    VARCHAR2 DEFAULT NULL,
            Token8Val VARCHAR2 DEFAULT NULL,
            Token9    VARCHAR2 DEFAULT NULL,
            Token9Val VARCHAR2 DEFAULT NULL
            );

FUNCTION check_coa_id(
           TableName   VARCHAR2,
           CompName    VARCHAR2,
           WhereString VARCHAR2 DEFAULT NULL
           ) RETURN NUMBER;

FUNCTION check_target_coa_id(
           TableName   VARCHAR2,
           CompName    VARCHAR2,
           WhereString VARCHAR2 DEFAULT NULL
           ) RETURN NUMBER;

FUNCTION source_component_exists(
           ComponentType VARCHAR2,
           CompName VARCHAR2
           ) RETURN BOOLEAN;

FUNCTION component_exists(SelectString VARCHAR2) RETURN NUMBER;

FUNCTION get_source_ref_object_name(
           MainTableName VARCHAR2,
           RefTableName  VARCHAR2,
           ColumnName    VARCHAR2,
           ColumnValue   VARCHAR2,
           MainIdName    VARCHAR2,
           RefIdName     VARCHAR2,
           CharColumn    BOOLEAN DEFAULT TRUE
           ) RETURN VARCHAR2;

PROCEDURE get_target_id_from_source_id(
            TableName    VARCHAR2,
            NameColumn   VARCHAR2,
            IdColumnName VARCHAR2,
            IdValue      IN OUT NOCOPY NUMBER,
            IdName       IN OUT NOCOPY VARCHAR2
            );

PROCEDURE get_target_ldg_from_source_ldg(
            LedgerId       IN OUT NOCOPY NUMBER,
            LedgerName     IN OUT NOCOPY VARCHAR2,
            LedgerCurrency IN OUT NOCOPY VARCHAR2);

FUNCTION token_from_id(Id NUMBER) RETURN VARCHAR2;

FUNCTION currency_exists(CurrencyCode VARCHAR2) RETURN BOOLEAN;

FUNCTION ro_column_exists(ColumnName VARCHAR2) RETURN BOOLEAN;

FUNCTION get_varchar2(
           SQLString  VARCHAR2,
           ColumnSize NUMBER
           ) RETURN VARCHAR2;

END RG_XFER_UTILS_PKG;

 

/
