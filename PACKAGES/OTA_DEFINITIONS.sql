--------------------------------------------------------
--  DDL for Package OTA_DEFINITIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_DEFINITIONS" AUTHID CURRENT_USER as
/* $Header: otobk01t.pkh 115.0 99/07/16 00:52:44 porting ship $ */
--
-- |--------------------------------------------------------------------------|
-- |-----------------------< status_usage >-----------------------------------|
-- |--------------------------------------------------------------------------|
--
function status_usage(p_usage_type in varchar2
                     ,p_booking_status_type_id in number)
    return number;
pragma restrict_references (status_usage, WNDS,WNPS,RNDS,RNPS);

end ota_definitions;

 

/
