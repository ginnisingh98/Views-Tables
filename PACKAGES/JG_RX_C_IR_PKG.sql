--------------------------------------------------------
--  DDL for Package JG_RX_C_IR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JG_RX_C_IR_PKG" AUTHID CURRENT_USER AS
/* $Header: jgrxcirs.pls 120.2 2003/01/21 07:06:06 hsugimot ship $ */
PROCEDURE ap_rx_invoice_reg (
  errbuf		out nocopy varchar2,
  retcode		out nocopy number,
  argument1		in  varchar2, -- Set of book id
  argument2		in  varchar2  default  null,	-- Batch id
  argument3		in  varchar2  default  null,	-- Entery person id
  argument4		in  varchar2  default  null,	-- First entered date
  argument5		in  varchar2  default  null,	-- Last entered date
  argument6		in  varchar2  default  null,	-- Accounting period
  argument7		in  varchar2,	-- Cancelled invoices only
  argument8		in  varchar2, 	-- Unapproved Invoices only
  argument9		in  varchar2  default  null, 	-- Invoice type
  argument10		in  varchar2  default  null, 	-- Debug
  argument11		in  varchar2  default  null,
  argument12		in  varchar2  default  null,
  argument13		in  varchar2  default  null,
  argument14		in  varchar2  default  null,
  argument15		in  varchar2  default  null,
  argument16		in  varchar2  default  null,
  argument17		in  varchar2  default  null,
  argument18		in  varchar2  default  null,
  argument19		in  varchar2  default  null,
  argument20		in  varchar2  default  null,
  argument21		in  varchar2  default  null,
  argument22		in  varchar2  default  null,
  argument23		in  varchar2  default  null,
  argument24		in  varchar2  default  null,
  argument25		in  varchar2  default  null,
  argument26		in  varchar2  default  null,
  argument27		in  varchar2  default  null,
  argument28		in  varchar2  default  null,
  argument29		in  varchar2  default  null,
  argument30		in  varchar2  default  null,
  argument31		in  varchar2  default  null,
  argument32		in  varchar2  default  null,
  argument33		in  varchar2  default  null,
  argument34		in  varchar2  default  null,
  argument35		in  varchar2  default  null,
  argument36		in  varchar2  default  null,
  argument37		in  varchar2  default  null,
  argument38		in  varchar2  default  null,
  argument39		in  varchar2  default  null,
  argument40		in  varchar2  default  null,
  argument41		in  varchar2  default  null,
  argument42		in  varchar2  default  null,
  argument43		in  varchar2  default  null,
  argument44		in  varchar2  default  null,
  argument45		in  varchar2  default  null,
  argument46		in  varchar2  default  null,
  argument47		in  varchar2  default  null,
  argument48		in  varchar2  default  null,
  argument49		in  varchar2  default  null,
  argument50		in  varchar2  default  null,
  argument51		in  varchar2  default  null,
  argument52		in  varchar2  default  null,
  argument53		in  varchar2  default  null,
  argument54		in  varchar2  default  null,
  argument55		in  varchar2  default  null,
  argument56		in  varchar2  default  null,
  argument57		in  varchar2  default  null,
  argument58		in  varchar2  default  null,
  argument59		in  varchar2  default  null,
  argument60		in  varchar2  default  null,
  argument61		in  varchar2  default  null,
  argument62		in  varchar2  default  null,
  argument63		in  varchar2  default  null,
  argument64		in  varchar2  default  null,
  argument65		in  varchar2  default  null,
  argument66		in  varchar2  default  null,
  argument67		in  varchar2  default  null,
  argument68		in  varchar2  default  null,
  argument69		in  varchar2  default  null,
  argument70		in  varchar2  default  null,
  argument71		in  varchar2  default  null,
  argument72		in  varchar2  default  null,
  argument73		in  varchar2  default  null,
  argument74		in  varchar2  default  null,
  argument75		in  varchar2  default  null,
  argument76		in  varchar2  default  null,
  argument77		in  varchar2  default  null,
  argument78		in  varchar2  default  null,
  argument79		in  varchar2  default  null,
  argument80		in  varchar2  default  null,
  argument81		in  varchar2  default  null,
  argument82		in  varchar2  default  null,
  argument83		in  varchar2  default  null,
  argument84		in  varchar2  default  null,
  argument85		in  varchar2  default  null,
  argument86		in  varchar2  default  null,
  argument87		in  varchar2  default  null,
  argument88		in  varchar2  default  null,
  argument89		in  varchar2  default  null,
  argument90		in  varchar2  default  null,
  argument91		in  varchar2  default  null,
  argument92		in  varchar2  default  null,
  argument93		in  varchar2  default  null,
  argument94		in  varchar2  default  null,
  argument95		in  varchar2  default  null,
  argument96		in  varchar2  default  null,
  argument97		in  varchar2  default  null,
  argument98		in  varchar2  default  null,
  argument99		in  varchar2  default  null,
  argument100           in  varchar2  default  null);

PROCEDURE ap_rx_invoice_reg_dtl (
  errbuf		out nocopy varchar2,
  retcode		out nocopy number,
  argument1		in  varchar2,	-- Set of book id
  argument2		in  varchar2,	-- Chart of Account id
  argument3		in  varchar2,	-- Line or Invoice
  argument4		in  varchar2,	-- Account date low
  argument5		in  varchar2,	-- Account date high
  argument6		in  varchar2  default  null,	-- Batch id
  argument7		in  varchar2  default  null, 	-- Invoice Type
  argument8		in  varchar2  default  null, 	-- Entred person id
  argument9		in  varchar2  default  null,	-- Document sequence id
  argument10		in  varchar2  default  null,	-- Document sequence value low
  argument11		in  varchar2  default  null,    -- Document sequence value high
  argument12		in  varchar2  default  null,	-- Supplier name low
  argument13		in  varchar2  default  null,	-- Supplier name high
  argument14		in  varchar2  default  null,	-- Liability account low
  argument15		in  varchar2  default  null,	-- Liability account high
  argument16		in  varchar2  default  null,	-- Distribution account low
  argument17		in  varchar2  default  null,	-- Distribution account high
  argument18		in  varchar2  default  null,	-- Invoice currency code
  argument19		in  varchar2  default  null,	-- Distribution amount low
  argument20		in  varchar2  default  null,	-- Distribution amount high
  argument21		in  varchar2  default  null,	-- Debug
  argument22		in  varchar2  default  null,
  argument23		in  varchar2  default  null,
  argument24		in  varchar2  default  null,
  argument25		in  varchar2  default  null,
  argument26		in  varchar2  default  null,
  argument27		in  varchar2  default  null,
  argument28		in  varchar2  default  null,
  argument29		in  varchar2  default  null,
  argument30		in  varchar2  default  null,
  argument31		in  varchar2  default  null,
  argument32		in  varchar2  default  null,
  argument33		in  varchar2  default  null,
  argument34		in  varchar2  default  null,
  argument35		in  varchar2  default  null,
  argument36		in  varchar2  default  null,
  argument37		in  varchar2  default  null,
  argument38		in  varchar2  default  null,
  argument39		in  varchar2  default  null,
  argument40		in  varchar2  default  null,
  argument41		in  varchar2  default  null,
  argument42		in  varchar2  default  null,
  argument43		in  varchar2  default  null,
  argument44		in  varchar2  default  null,
  argument45		in  varchar2  default  null,
  argument46		in  varchar2  default  null,
  argument47		in  varchar2  default  null,
  argument48		in  varchar2  default  null,
  argument49		in  varchar2  default  null,
  argument50		in  varchar2  default  null,
  argument51		in  varchar2  default  null,
  argument52		in  varchar2  default  null,
  argument53		in  varchar2  default  null,
  argument54		in  varchar2  default  null,
  argument55		in  varchar2  default  null,
  argument56		in  varchar2  default  null,
  argument57		in  varchar2  default  null,
  argument58		in  varchar2  default  null,
  argument59		in  varchar2  default  null,
  argument60		in  varchar2  default  null,
  argument61		in  varchar2  default  null,
  argument62		in  varchar2  default  null,
  argument63		in  varchar2  default  null,
  argument64		in  varchar2  default  null,
  argument65		in  varchar2  default  null,
  argument66		in  varchar2  default  null,
  argument67		in  varchar2  default  null,
  argument68		in  varchar2  default  null,
  argument69		in  varchar2  default  null,
  argument70		in  varchar2  default  null,
  argument71		in  varchar2  default  null,
  argument72		in  varchar2  default  null,
  argument73		in  varchar2  default  null,
  argument74		in  varchar2  default  null,
  argument75		in  varchar2  default  null,
  argument76		in  varchar2  default  null,
  argument77		in  varchar2  default  null,
  argument78		in  varchar2  default  null,
  argument79		in  varchar2  default  null,
  argument80		in  varchar2  default  null,
  argument81		in  varchar2  default  null,
  argument82		in  varchar2  default  null,
  argument83		in  varchar2  default  null,
  argument84		in  varchar2  default  null,
  argument85		in  varchar2  default  null,
  argument86		in  varchar2  default  null,
  argument87		in  varchar2  default  null,
  argument88		in  varchar2  default  null,
  argument89		in  varchar2  default  null,
  argument90		in  varchar2  default  null,
  argument91		in  varchar2  default  null,
  argument92		in  varchar2  default  null,
  argument93		in  varchar2  default  null,
  argument94		in  varchar2  default  null,
  argument95		in  varchar2  default  null,
  argument96		in  varchar2  default  null,
  argument97		in  varchar2  default  null,
  argument98		in  varchar2  default  null,
  argument99		in  varchar2  default  null,
  argument100           in  varchar2  default  null);

END JG_RX_C_IR_PKG;

 

/
