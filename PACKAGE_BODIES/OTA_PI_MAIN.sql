--------------------------------------------------------
--  DDL for Package Body OTA_PI_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OTA_PI_MAIN" AS
/* $Header: otpimain.pkb 120.2 2005/10/31 05:40:08 hwinsor noship $ */

PROCEDURE def_bg_data (errbuf out NOCOPY varchar2
                      ,retcode out NOCOPY number
                      ,p_business_group_id IN NUMBER DEFAULT NULL) IS
begin
  --
  ota_fr_2483_data.load_bg_measurement_types(p_business_group_id);
  --
  errbuf := '';
  retcode := 0;
exception
  when others then
    retcode := sqlcode;
    errbuf := sqlerrm;
end def_bg_data;
--
end OTA_PI_MAIN;

/
