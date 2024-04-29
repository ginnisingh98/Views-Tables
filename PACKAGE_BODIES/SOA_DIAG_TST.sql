--------------------------------------------------------
--  DDL for Package Body SOA_DIAG_TST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."SOA_DIAG_TST" AS
  /* $Header: SOADIAGTSTB.pls 120.0.12010000.2 2009/08/31 09:06:05 akemiset noship $ */
FUNCTION TestFunction
  (
    arg1 VARCHAR2 ,
    arg2 INTEGER,
    arg3 BOOLEAN)
  RETURN NUMBER
IS
BEGIN
  RETURN arg2;
END TestFunction;

PROCEDURE testFunctionCP
  (
    ERRBUF OUT NOCOPY  VARCHAR2,
    RETCODE OUT NOCOPY NUMBER )
IS
BEGIN
  fnd_file.put_line(fnd_file.log, 'soa_diag_cp.testFunction invoked...');
EXCEPTION
WHEN OTHERS THEN
  RETCODE := 2;
  ERRBUF  := SQLCODE||':'||sqlerrm;
  fnd_file.put_line(fnd_file.log, 'soa_diag_cp.testFunction failed ' || SQLCODE||':'||sqlerrm);
END testFunctionCP;

END SOA_DIAG_TST;

/
