--------------------------------------------------------
--  DDL for Package ARRX_C_ADJ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_C_ADJ" AUTHID CURRENT_USER as
/* $Header: ARRXCADS.pls 120.4 2005/10/30 04:25:20 appldev ship $ */

PROCEDURE ADJUSTMENT_REGISTER (
   errbuf                   out NOCOPY  varchar2,
   retcode                  out NOCOPY  varchar2,
   argument1                in   varchar2,               -- reporting level
   argument2                in   varchar2,               -- reporting context
   argument3                in   varchar2,               -- sob_id
   argument4                in   varchar2,               -- coa_id
   argument5                in   varchar2,               -- co_seg_low
   argument6                in   varchar2,               -- co_seg_high
   argument7                in   varchar2,               -- gl_date_from
   argument8                in   varchar2,               -- gl_date_to
   argument9                in   varchar2,               -- currency_type_low
   argument10               in   varchar2,               -- currency_type_high
   argument11               in   varchar2,               -- adj date_low
   argument12               in   varchar2,               -- adj date_high
   argument13               in   varchar2,               -- trx due_date_low
   argument14               in   varchar2,               -- trx due_date_high
   argument15               in   varchar2,               -- trx_type_low
   argument16               in   varchar2,               -- trx_type_high
   argument17               in   varchar2,               -- adj_type_low
   argument18               in   varchar2,               -- adj_type_high
   argument19               in   varchar2,               -- doc seq name
   argument20               in   varchar2,               -- doc seq low
   argument21               in   varchar2,               -- doc seq high
   argument22               in   varchar2  default  'N', -- debug flag
   argument23               in   varchar2  default  'N', -- sql trace
   argument24               in   varchar2  default  null,
   argument25               in   varchar2  default  null,
   argument26               in   varchar2  default  null,
   argument27               in   varchar2  default  null,
   argument28               in   varchar2  default  null,
   argument29               in   varchar2  default  null,
   argument30               in   varchar2  default  null,
   argument31               in   varchar2  default  null,
   argument32               in   varchar2  default  null,
   argument33               in   varchar2  default  null,
   argument34               in   varchar2  default  null,
   argument35               in   varchar2  default  null,
   argument36               in   varchar2  default  null,
   argument37               in   varchar2  default  null,
   argument38               in   varchar2  default  null,
   argument39               in   varchar2  default  null,
   argument40               in   varchar2  default  null,
   argument41               in   varchar2  default  null,
   argument42               in   varchar2  default  null,
   argument43               in   varchar2  default  null,
   argument44               in   varchar2  default  null,
   argument45               in   varchar2  default  null,
   argument46               in   varchar2  default  null,
   argument47               in   varchar2  default  null,
   argument48               in   varchar2  default  null,
   argument49               in   varchar2  default  null,
   argument50               in   varchar2  default  null,
   argument51               in   varchar2  default  null,
   argument52               in   varchar2  default  null,
   argument53               in   varchar2  default  null,
   argument54               in   varchar2  default  null,
   argument55               in   varchar2  default  null,
   argument56               in   varchar2  default  null,
   argument57               in   varchar2  default  null,
   argument58               in   varchar2  default  null,
   argument59               in   varchar2  default  null,
   argument60               in   varchar2  default  null,
   argument61               in   varchar2  default  null,
   argument62               in   varchar2  default  null,
   argument63               in   varchar2  default  null,
   argument64               in   varchar2  default  null,
   argument65               in   varchar2  default  null,
   argument66               in   varchar2  default  null,
   argument67               in   varchar2  default  null,
   argument68               in   varchar2  default  null,
   argument69               in   varchar2  default  null,
   argument70               in   varchar2  default  null,
   argument71               in   varchar2  default  null,
   argument72               in   varchar2  default  null,
   argument73               in   varchar2  default  null,
   argument74               in   varchar2  default  null,
   argument75               in   varchar2  default  null,
   argument76               in   varchar2  default  null,
   argument77               in   varchar2  default  null,
   argument78               in   varchar2  default  null,
   argument79               in   varchar2  default  null,
   argument80               in   varchar2  default  null,
   argument81               in   varchar2  default  null,
   argument82               in   varchar2  default  null,
   argument83               in   varchar2  default  null,
   argument84               in   varchar2  default  null,
   argument85               in   varchar2  default  null,
   argument86               in   varchar2  default  null,
   argument87               in   varchar2  default  null,
   argument88               in   varchar2  default  null,
   argument89               in   varchar2  default  null,
   argument90               in   varchar2  default  null,
   argument91               in   varchar2  default  null,
   argument92               in   varchar2  default  null,
   argument93               in   varchar2  default  null,
   argument94               in   varchar2  default  null,
   argument95               in   varchar2  default  null,
   argument96               in   varchar2  default  null,
   argument97               in   varchar2  default  null,
   argument98               in   varchar2  default  null,
   argument99               in   varchar2  default  null,
   argument100              in   varchar2  default  null);




END ARRX_C_ADJ;

 

/
