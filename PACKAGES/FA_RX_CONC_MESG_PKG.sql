--------------------------------------------------------
--  DDL for Package FA_RX_CONC_MESG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_RX_CONC_MESG_PKG" AUTHID CURRENT_USER as
/* $Header: farxmsgs.pls 120.1.12010000.2 2009/07/19 13:42:06 glchen ship $ */


procedure log (
	buff	in	varchar2);


procedure out (
	buff	in	varchar2);

END FA_RX_CONC_MESG_PKG;

/
