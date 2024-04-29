--------------------------------------------------------
--  DDL for Package OTA_FR_2483_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_FR_2483_DATA" AUTHID CURRENT_USER as
/* $Header: otfr248d.pkh 120.1.12010000.1 2008/07/28 13:14:54 appldev ship $  */
--
--   This package delivers the measurement types required to run the
--   2483 report. It will be run from a concurrent program passing
--   the business group id parameter.
--
procedure load_bg_measurement_types(p_business_group_id number);
END ota_fr_2483_data;

/
