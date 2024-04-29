--------------------------------------------------------
--  DDL for Package OTA_REPROCESS_CLASSIC_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OTA_REPROCESS_CLASSIC_UPGRADE" AUTHID CURRENT_USER as
/* $Header: otreprocclsupg.pkh 115.0 2004/04/06 06:28:24 arkashya noship $ */
    -- List processes
    procedure upgrade_request(aSqlerrm      IN OUT NOCOPY  VARCHAR2,
                              aSqlcode      IN OUT NOCOPY  number);
    function get_next_upgrade_id return number;
    function get_ota_schema return varchar2;
end    OTA_REPROCESS_CLASSIC_UPGRADE;

 

/
