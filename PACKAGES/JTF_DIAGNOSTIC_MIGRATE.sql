--------------------------------------------------------
--  DDL for Package JTF_DIAGNOSTIC_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGNOSTIC_MIGRATE" AUTHID CURRENT_USER AS
/* $Header: jtfdiagmigrate_s.pls 115.0 2002/07/12 23:50:02 skhemani noship $ */

  ---------------------------------------------------------------------------
  -- Insert a place holder migration date if none exists in the
  -- jtf_diagnostic_prereq table
  ---------------------------------------------------------------------------

  procedure INSERT_PLACEHOLDER_DATE;

  ---------------------------------------------------------------------------
  -- Update the migration date in the
  -- jtf_diagnostic_prereq table
  ---------------------------------------------------------------------------

  procedure UPDATE_MIGRATION_DATE;

  ---------------------------------------------------------------------------
  -- lock the migration date so that no other thread
  -- can update the date or waits or throws an exception at
  -- the time data is being migrated
  ---------------------------------------------------------------------------

  procedure LOCK_MIGRATION_DATE;

  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  procedure MIGRATE_DB_DIAGNOSTIC_DATA;

  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  procedure MIGRATE_APPS;

  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  PROCEDURE MIGRATE_APP_PREREQS(P_ASN IN VARCHAR2, P_APP_ID IN NUMBER);

  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  PROCEDURE MIGRATE_APP_GROUPS(P_ASN IN VARCHAR2, P_APP_ID IN NUMBER);


  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  PROCEDURE MIGRATE_APP_GROUPS(
  	P_ASN IN VARCHAR2,
  	P_APP_ID IN NUMBER,
  	P_GRPCOUNT IN NUMBER);


  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  PROCEDURE MIGRATE_GROUP_PREREQS(
  			P_ASN IN VARCHAR2,
  			P_GRPNAME IN VARCHAR2,
  			P_APP_ID IN NUMBER);


  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  PROCEDURE MIGRATE_GROUP_TESTS(
  				P_ASN IN VARCHAR2,
  				P_GRPNAME IN VARCHAR2,
  				P_APP_ID IN NUMBER,
  				p_testnum in number);


  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  procedure migrate_test_arguments(
  				p_asn in varchar2,
  				p_grpname in varchar2,
  				p_app_id in number,
  				p_classname in varchar2);

  ---------------------------------------------------------------------------
  --
  ---------------------------------------------------------------------------

  procedure migrate_test_arg_row(
  				v_argument_names IN JTF_VARCHAR2_TABLE_4000,
 				p_asn in varchar2,
 				p_grpname in varchar2,
 				p_classname in varchar2,
 				p_app_id in number,
 				p_rownum in varchar2);




END JTF_DIAGNOSTIC_MIGRATE;


 

/
