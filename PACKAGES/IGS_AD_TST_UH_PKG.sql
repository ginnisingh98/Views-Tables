--------------------------------------------------------
--  DDL for Package IGS_AD_TST_UH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_TST_UH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSADA7S.pls 120.0 2005/06/01 16:10:32 appldev noship $ */

PROCEDURE convert_test_scr_uk
( p_person_id		IN  HZ_PARTIES.PARTY_ID%TYPE,
  p_session_id    	IN  NUMBER
);
--A hook package procedure is the unit of code, which is called when a hook
--point is reached, in the business process logic. The calls to the hook
--package header are hard coded from the main business process procedure.
--The hook package header, procedure name and parameter list should be
--implemented by the developer when the business process is written. The
--hook package headers are shipped with the product just like any other
--server-side package header.The hook package body is NOT written by the
--developer. It is created dynamically at the customer site.

--1.  The user hook procedure will be coded by client and he or she will
--insert values into Interface tables IGS_AD_TSTRST_UK_INT and
--IGS_AD_TSTDTL_UK_INT.
--2.We are providing only Package and Procedure headers, client will
--develop the Package Body dynamically in his or her site.

--===========================CONSTRAINTS===========================

--Client should  not do the following things in the User Hook Procedure
--
--
--1.  Do not Insert or Update records directly into any Oracle Application table.
--Using to do so is not supported by Oracle Corporation.
--2.  Client  must use the Public predefined procedure that OSS provides to insert
--or update records in to OSS tables ( Client can insert directly into IGS_AD_TSTRST_INT
--and IGS_AD_TSTDTL_INT tables)
--3.  Client should not give any explicit Commit or Rollback Statements inside the User Hook
--Procedure Body.
--4.  Client is responsible for the support and upgrade of the procedures that client
--writes that are affected by changes between releases of Oracle Applications.
--
--
--=======Guidelines for  writing User Hook Package Specifications=======
--1.Parameters to the User Hook Procedures must be defined as "IN" parameters,
--in the hook package header. This will ensure that "call package procedures" can
--only access these values in read-only mode. Values cannot be changed and passed
--back into the core product code. Therefore protecting core product logic
--and avoiding the need to validate the attributes twice.
--2.Do NOT specify any parameters as "OUT" or "IN OUT" on the hook package
--procedures. The core product code will not know what to do with any values
--passed back.
--3.PL/SQL Base Data types
--Each attribute should be passed across to the hook package procedure using an
--individual parameter. Only the following PL/SQL base data types are supported:
--VARCHAR2
--NUMBER
--DATE
--BOOLEAN
--LONG
--To provide a simple mapping system of parameters between the hook package
--procedures and the call package procedures. The name of each parameter on
--a call package procedure must exist at all the hook point(s) it is going
--to be called from. Parameter data types must also match exactly.
--Any implicit data type conversions which PL/SQL would normally allow
--are not permitted in user hooks.
--
--4.Parameter Defaults
--DEFAULT values should NOT be defined for any hook package procedure parameter.
--It is point less to assign a DEFAULT because the logic to execute these
--procedures is hard coded. A value is passed across for every parameter,
--so a DEAFULT would not be used.
--
--5.Date fields needs to be populated in the following format for any
--  date field manipulation
-- to_date ( '10-07-2001', 'DD-MM-YYYY')

END IGS_AD_TST_UH_PKG;

 

/
