--------------------------------------------------------
--  DDL for Package IGC_UPGRADE_DATA_R12
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_UPGRADE_DATA_R12" AUTHID CURRENT_USER AS
/*$Header: IGCUPGDS.pls 120.9 2008/02/26 13:49:28 mbremkum noship $ */

PROCEDURE Validate_Setup_and_Migrate (  errbuf    OUT NOCOPY  VARCHAR2,
          retcode   OUT NOCOPY  VARCHAR2,
          p_balance_type    IN VARCHAR2,
          p_mode    IN VARCHAR2,
          p_fiscal_year IN NUMBER);

END  IGC_UPGRADE_DATA_R12;


/
