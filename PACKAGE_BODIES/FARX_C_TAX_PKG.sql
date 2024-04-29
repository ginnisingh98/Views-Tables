--------------------------------------------------------
--  DDL for Package Body FARX_C_TAX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FARX_C_TAX_PKG" as
/* $Header: farxcptb.pls 120.2.12010000.2 2009/07/19 13:49:16 glchen ship $ */

PROCEDURE PROPTAX (
  errbuf out nocopy varchar2,
  retcode out nocopy varchar2,
  argument1	in  varchar2,   -- book
  argument2     in  varchar2  default  null,
  argument3     in  varchar2  default  null,
  argument4     in  varchar2  default  null,
  argument5     in  varchar2  default  null,
  argument6     in  varchar2  default  null,
  argument7     in  varchar2  default  null,
  argument8     in  varchar2  default  null,
  argument9     in  varchar2  default  null,
  argument10    in  varchar2  default  null,
  argument11	in  varchar2  default  null,
  argument12    in  varchar2  default  null,
  argument13    in  varchar2  default  null,
  argument14    in  varchar2  default  null,
  argument15    in  varchar2  default  null,
  argument16    in  varchar2  default  null,
  argument17    in  varchar2  default  null,
  argument18    in  varchar2  default  null,
  argument19    in  varchar2  default  null,
  argument20    in  varchar2  default  null,
  argument21	in  varchar2  default  null,
  argument22    in  varchar2  default  null,
  argument23    in  varchar2  default  null,
  argument24    in  varchar2  default  null,
  argument25    in  varchar2  default  null,
  argument26    in  varchar2  default  null,
  argument27    in  varchar2  default  null,
  argument28    in  varchar2  default  null,
  argument29    in  varchar2  default  null,
  argument30    in  varchar2  default  null,
  argument31	in  varchar2  default  null,
  argument32    in  varchar2  default  null,
  argument33    in  varchar2  default  null,
  argument34    in  varchar2  default  null,
  argument35    in  varchar2  default  null,
  argument36    in  varchar2  default  null,
  argument37    in  varchar2  default  null,
  argument38    in  varchar2  default  null,
  argument39    in  varchar2  default  null,
  argument40    in  varchar2  default  null,
  argument41	in  varchar2  default  null,
  argument42    in  varchar2  default  null,
  argument43    in  varchar2  default  null,
  argument44    in  varchar2  default  null,
  argument45    in  varchar2  default  null,
  argument46    in  varchar2  default  null,
  argument47    in  varchar2  default  null,
  argument48    in  varchar2  default  null,
  argument49    in  varchar2  default  null,
  argument50    in  varchar2  default  null,
  argument51	in  varchar2  default  null,
  argument52    in  varchar2  default  null,
  argument53    in  varchar2  default  null,
  argument54    in  varchar2  default  null,
  argument55    in  varchar2  default  null,
  argument56    in  varchar2  default  null,
  argument57    in  varchar2  default  null,
  argument58    in  varchar2  default  null,
  argument59    in  varchar2  default  null,
  argument60    in  varchar2  default  null,
  argument61	in  varchar2  default  null,
  argument62    in  varchar2  default  null,
  argument63    in  varchar2  default  null,
  argument64    in  varchar2  default  null,
  argument65    in  varchar2  default  null,
  argument66    in  varchar2  default  null,
  argument67    in  varchar2  default  null,
  argument68    in  varchar2  default  null,
  argument69    in  varchar2  default  null,
  argument70    in  varchar2  default  null,
  argument71	in  varchar2  default  null,
  argument72    in  varchar2  default  null,
  argument73    in  varchar2  default  null,
  argument74    in  varchar2  default  null,
  argument75    in  varchar2  default  null,
  argument76    in  varchar2  default  null,
  argument77    in  varchar2  default  null,
  argument78    in  varchar2  default  null,
  argument79    in  varchar2  default  null,
  argument80    in  varchar2  default  null,
  argument81	in  varchar2  default  null,
  argument82    in  varchar2  default  null,
  argument83    in  varchar2  default  null,
  argument84    in  varchar2  default  null,
  argument85    in  varchar2  default  null,
  argument86    in  varchar2  default  null,
  argument87    in  varchar2  default  null,
  argument88    in  varchar2  default  null,
  argument89    in  varchar2  default  null,
  argument90    in  varchar2  default  null,
  argument91	in  varchar2  default  null,
  argument92    in  varchar2  default  null,
  argument93    in  varchar2  default  null,
  argument94    in  varchar2  default  null,
  argument95    in  varchar2  default  null,
  argument96    in  varchar2  default  null,
  argument97    in  varchar2  default  null,
  argument98    in  varchar2  default  null,
  argument99    in  varchar2  default  null,
  argument100   in  varchar2  default  null) is


Cursor c1 is
    Select lookup_code
    From fa_lookups
    Where lookup_type = 'PROPERTY TYPE'
    And meaning = argument10;

  h_property_type varchar2(80);


  h_request_id    number;
  h_user_id       number;
  h_end_date	  date;
  h_date_format   varchar2(25);
  h_end_date_str  varchar2(25);
  h_err_msg       varchar2(2000);

  begin

--  select max(fcr.request_id)
--  into h_request_id
--  from fnd_concurrent_requests fcr, fnd_concurrent_programs fcp
--  where fcr.argument1 = argument1
--  and fcr.argument2 = argument2
--  and fcr.argument3 = argument3
--  and fcr.concurrent_program_id = fcp.concurrent_program_id
--  and fcp.concurrent_program_name = 'RXFAPTAX';

  h_request_id := fnd_global.conc_request_id;
  fnd_profile.get('USER_ID',h_user_id);

--  h_end_date_str := substr(argument3,1,instr(argument3,'_')-1);
--  h_date_format := substr(argument3,instr(argument3,'_')+1);
--  h_end_date :=  to_date(h_end_date_str,h_date_format);

  h_end_date := to_date(argument2, 'YYYY/MM/DD HH24:MI:SS');

  if argument10 is not null then
     open c1;
     fetch c1 into h_property_type;
     if c1%notfound then
        h_property_type := argument10;
     end if;
     close c1;
  end if;

  farx_tax_pkg.property_tax (
	book 		=>	argument1,
 	end_date 	=>	h_end_date,
	segment1	=>	argument3,
	segment2	=>	argument4,
	segment3	=>	argument5,
	segment4	=>	argument6,
	segment5	=>	argument7,
	segment6	=>	argument8,
	segment7	=>	argument9,
	property_type	=>	h_property_type,
	company		=>	argument12,
	cost_center	=>	argument13,
	cost_account	=>	argument14,
	request_id 	=>	h_request_id,
 	user_id 	=>	h_user_id,
	retcode 	=>	retcode,
	errbuf		=>	errbuf);

  retcode := 0;

exception
when others then
  fnd_message.set_name('OFA', 'FA_SHARED_SERVER_ERROR');
  h_err_msg := fnd_message.get;
  fa_rx_conc_mesg_pkg.log(h_err_msg);
  retcode := 2;

  end proptax;

END FARX_C_TAX_PKG;

/