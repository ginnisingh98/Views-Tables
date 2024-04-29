--------------------------------------------------------
--  DDL for Package Body JTF_DIAGUNITTEST_QAPACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_DIAGUNITTEST_QAPACKAGE" AS
/* $Header: jtfdiagadptuqa_b.pls 120.2 2005/08/13 01:25:27 minxu noship $ */
  ------------------------------------------------------------
  -- procedure to initialize test datastructures
  -- executeds prior to test run (not currently being called)
  ------------------------------------------------------------
  PROCEDURE init IS
  BEGIN
   -- test writer could insert special setup code here
   null;
  END init;

  ------------------------------------------------------------
  -- procedure to cleanup any  test datastructures that were setup in the init
  --  procedure call executes after test run (not currently being called)
  ------------------------------------------------------------
  PROCEDURE cleanup IS
  BEGIN
   -- test writer could insert special cleanup code here
   NULL;
  END cleanup;

    ------------------------------------------------------------
  -- procedure to report test component name back to framework
  ------------------------------------------------------------

  PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'MathComponent UnitTests';
  END getComponentName;

  ------------------------------------------------------------
  -- procedure to report test description back to framework
  ------------------------------------------------------------
  PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Unit Test Package to display MathComponent Unit tests';
  END getTestDesc;

  ------------------------------------------------------------
  -- procedure to report test name back to framework
  ------------------------------------------------------------
  PROCEDURE getTestName(str OUT NOCOPY VARCHAR2) IS
  BEGIN
    str := 'Math Component';
  END getTestName;


---------------------------------------------------
--  Unit test to test the POWER() API
----------------------------------------------------

  PROCEDURE testPower IS
    expected NUMBER := 1.281212;
    result   NUMBER;
    message  VARCHAR2(512);
  BEGIN
    message := 'The POWER() Execution has resulted in error';
    result := round(power(1.1,2.6),6);
    JTF_DIAGNOSTIC_ADAPTUTIL.assertEquals(message,expected,result);
  END;

  ---------------------------------------------------
  --  Unit test to test the EXP() API
  ----------------------------------------------------

  PROCEDURE testExp IS
    -- expected NUMBER := 14.879732;
    expected NUMBER := 4.879732;
    result   NUMBER;
    message  VARCHAR2(512);
  BEGIN
    message := 'The EXP() Execution has resulted in error';
    result := round(exp(2.7),6);
    JTF_DIAGNOSTIC_ADAPTUTIL.assertEquals(message,expected,result);
  END;
END JTF_DIAGUNITTEST_QAPACKAGE;


/
