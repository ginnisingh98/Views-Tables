--------------------------------------------------------
--  DDL for Package EAM_ASSET_NUM_IMPORT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_NUM_IMPORT_PUB" AUTHID CURRENT_USER AS
/* $Header: EAMPANIS.pls 120.0.12000000.1 2007/01/16 09:42:43 appldev ship $*/



PROCEDURE import_asset_numbers(
  errbuf                      OUT NOCOPY     VARCHAR2,
  retcode                     OUT NOCOPY     NUMBER,
  p_interface_group_id        IN      NUMBER,
  p_purge_option              IN      VARCHAR2 default 'N'
);
END  EAM_ASSET_NUM_IMPORT_PUB;

 

/
