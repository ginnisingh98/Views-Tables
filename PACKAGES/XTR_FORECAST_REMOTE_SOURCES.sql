--------------------------------------------------------
--  DDL for Package XTR_FORECAST_REMOTE_SOURCES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XTR_FORECAST_REMOTE_SOURCES" AUTHID CURRENT_USER AS
/*  $Header: xtrfrmts.pls 115.0 99/07/17 00:31:44 porting ship $ */

FUNCTION Populate_Remote_Amounts
  ( source_view			VARCHAR2,
    db_link			VARCHAR2,
    criteria1			VARCHAR2,
    criteria2			VARCHAR2,
    criteria3			VARCHAR2,
    criteria4			VARCHAR2,
    criteria5			VARCHAR2,
    criteria6			VARCHAR2,
    criteria7			VARCHAR2,
    criteria8			VARCHAR2,
    criteria9			VARCHAR2,
    criteria10			VARCHAR2,
    criteria11			VARCHAR2,
    criteria12			VARCHAR2,
    criteria13			VARCHAR2,
    criteria14			VARCHAR2,
    criteria15			VARCHAR2) RETURN NUMBER;

END XTR_FORECAST_REMOTE_SOURCES;


 

/
