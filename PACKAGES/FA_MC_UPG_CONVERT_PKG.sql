--------------------------------------------------------
--  DDL for Package FA_MC_UPG_CONVERT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_MC_UPG_CONVERT_PKG" AUTHID CURRENT_USER AS
/* $Header: faxmcucs.pls 120.2.12010000.2 2009/07/19 10:10:19 glchen ship $  */

   PROCEDURE main_convert(
                        errbuf                  OUT NOCOPY     VARCHAR2,
                        retcode                 OUT NOCOPY     NUMBER,
                        p_book_type_code        IN      VARCHAR2,
                        p_reporting_book        IN      VARCHAR2,
                        p_fixed_conversion      IN      VARCHAR2);

END FA_MC_UPG_CONVERT_PKG;

/
