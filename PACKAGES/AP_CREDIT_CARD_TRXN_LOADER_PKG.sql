--------------------------------------------------------
--  DDL for Package AP_CREDIT_CARD_TRXN_LOADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_CREDIT_CARD_TRXN_LOADER_PKG" AUTHID CURRENT_USER AS
/* $Header: apwcclds.pls 115.2 2002/11/14 22:56:48 kwidjaja ship $ */

PROCEDURE Preformat(errbuf out nocopy varchar2,
               retcode out nocopy number,
               p_indatafilename in varchar2,
               p_outdatafilename in varchar2,
               p_cardbrand in varchar2);

END AP_CREDIT_CARD_TRXN_LOADER_PKG;

 

/
