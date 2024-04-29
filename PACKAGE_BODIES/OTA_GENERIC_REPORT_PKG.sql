--------------------------------------------------------
--  DDL for Package Body OTA_GENERIC_REPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_GENERIC_REPORT_PKG" as
/* $Header: otagenrp.pkb 115.0 99/07/16 00:49:31 porting ship $ */


---------------------------------------------------------------------------
--|--------------------< Private Global Definition >----------------------|
---------------------------------------------------------------------------
-- Description:
-- Global package name.

g_package varchar2(50) := 'ota_generic_report_pkg';

--
--
----------------------------------------------------------------------------
--|---------------------< different_currency > ----------------------------|
----------------------------------------------------------------------------
--Description:
-- This function checks to see if the currencies of the totals to be sumed
-- are the same. If they are, the total is calculated.


Function  different_currency (event in  number,
                            tablename in  varchar2
                            ) RETURN Boolean
 IS

--
--
v_currency_code                 varchar2(30);
counter                         number;
--
--
Cursor sel_currency_student is
select distinct
      fl.currency_code
from
      ota_finance_lines fl,
      ota_events e,
      ota_delegate_bookings db
where  db.event_id = event
and db.booking_id  = fl.booking_id;
--
--
Cursor sel_currency_resource_event is
select distinct
      fl.currency_code
from
      ota_finance_lines fl,
      ota_events e,
      ota_resource_bookings rb,
      ota_activity_versions av
where rb.event_id = event
and rb.resource_booking_id  = fl.resource_booking_id;
--
--
BEGIN
--
--
-- For the delegate bookings table
--
IF tablename like 'student' THEN
  --
  counter:=0;
  --
  OPEN sel_currency_student;
  --
  LOOP
  --
    FETCH sel_currency_student INTO
                          v_currency_code;
    --
    EXIT when sel_currency_student%notfound or counter > 1 ;
    --
    counter:=counter+1;
  --
  END LOOP;
  --
  CLOSE sel_currency_student;
   --
   IF counter <= 1  THEN
     --
     RETURN(false);
     --
   ELSIF counter > 1  THEN
     --
     RETURN(true);
     --
   END IF;
   --
   --
--
--
-- For the resource bookings table
--
--
ELSIF tablename like 'resource' THEN
  --
  counter:=0;
  --
  OPEN sel_currency_resource_event;
  --
   LOOP
  --
    FETCH sel_currency_resource_event INTO
                          v_currency_code;
    --
    EXIT when sel_currency_resource_event%notfound or counter > 1;
    --
    counter:=counter+1;
  --
  END LOOP;
  --
  CLOSE sel_currency_resource_event;
   --
   IF counter <= 1  THEN
     --
     RETURN(false);
     --
   ELSIF counter > 1 THEN
     --
     RETURN(true);
     --
   END IF;
   --
--
END IF;

END different_currency;
--

END ota_generic_report_pkg;

/
