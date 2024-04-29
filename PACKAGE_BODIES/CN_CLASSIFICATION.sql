--------------------------------------------------------
--  DDL for Package Body CN_CLASSIFICATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_CLASSIFICATION" AS
-- $Header: cnclclsb.pls 115.0 99/07/16 07:03:39 porting ship $

--
-- Package Name
--   cn_classification
-- Purpose
--   Package body for classifying transactions, works as a router,
--   calls the actual cn_classification_<org_id> package
-- History
--   12-DEC-96          Xinyang Fan            Created
--   11-Feb-98       Achung   reference CLIENT_INFO need to use SUBSTRB
--



     cached_org_id                integer;
     cached_org_append            varchar2(100);


     PROCEDURE classify_batch ( x_physical_batch_id NUMBER,
			   x_process_audit_id  NUMBER) IS

	   dummy			NUMBER;
	   c			INTEGER;
	   rows_processed	INTEGER;
	   statement		VARCHAR2(1000);

     BEGIN
	c := dbms_sql.open_cursor;

	statement := 'begin cn_classification'||cached_org_append||
	  '.classify_batch(:physical_batch_id,:process_audit_id);'||
	  'end;';

	dbms_sql.parse(c, statement, dbms_sql.native);

	dbms_sql.bind_variable(c,'physical_batch_id', x_physical_batch_id);
	dbms_sql.bind_variable(c,'process_audit_id', x_process_audit_id);

	rows_processed := dbms_sql.execute(c);

	dbms_sql.variable_value(c,'physical_batch_id', dummy);
	dbms_sql.variable_value(c,'process_audit_id', dummy);

	dbms_sql.close_cursor(c);


     END classify_batch;

  BEGIN

     -- cache org_id and org_append

     select
       NVL(TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
                         SUBSTRB(USERENV('CLIENT_INFO'),1,10))),-99)
       into cached_org_id
       from dual;

     if cached_org_id = -99 then
	cached_org_append := '_MINUS99';
      else
	cached_org_append := '_' || cached_org_id;
     end if;

  END cn_classification;

/
