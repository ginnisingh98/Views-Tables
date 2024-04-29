--------------------------------------------------------
--  DDL for Package CS_FETCH_ARTXN_INFO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_FETCH_ARTXN_INFO_PKG" AUTHID CURRENT_USER AS
/* $Header: csctfchs.pls 115.2 99/07/16 08:52:29 porting ship $ */


PROCEDURE fetch_trx_information(
                               ERRBUF    OUT   VARCHAR2,
                               RETCODE    OUT   NUMBER
					);


END CS_FETCH_ARTXN_INFO_PKG;


 

/
