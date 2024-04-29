--------------------------------------------------------
--  DDL for Package Body ARRX_SALES_TAX_REP_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARRX_SALES_TAX_REP_COVER" as
/* $Header: ARRXCSTB.pls 115.4 2003/10/10 14:27:23 mraymond ship $ */
PG_DEBUG varchar2(1) := NVL(FND_PROFILE.value('AFLOG_ENABLED'), 'N');

PROCEDURE AR_SALES_TAX (
  errbuf	   out NOCOPY	varchar2,
  retcode	   out NOCOPY	number,
  argument1	   in  number,    -- chart_of_accounts
  argument2        in  varchar2,  -- trx_date_low
  argument3        in  varchar2,  -- trx_date_high
  argument4        in  varchar2,  -- gl_date_low
  argument5        in  varchar2,  -- gl_date_high
  argument6        in  varchar2,  -- state_low
  argument7        in  varchar2,  -- state_high
  argument8        in  varchar2,  -- currency_low
  argument9        in  varchar2,  -- currency_high
  argument10       in  varchar2,  -- exemption_status
  argument11	   in  varchar2,  -- where_gl_flex1
  argument12       in  varchar2,  -- where_gl_flex2
  argument13       in  varchar2,  -- where_gl_flex3
  argument14       in  varchar2,  -- where_gl_flex4
  argument15       in  varchar2,  -- where_gl_flex5
  argument16       in  varchar2,  -- where_gl_flex6
  argument17       in  varchar2,  -- where_gl_flex7
  argument18       in  varchar2,  -- where_gl_flex8
  argument19       in  varchar2,  -- where_gl_flex9
  argument20       in  varchar2,  -- show_deposit_children
  argument21	   in  varchar2,  -- detail_level L/H
  argument22       in  varchar2,  -- posted_status
  argument23       in  varchar2,  -- show_cms_adjs_outside_date
  argument24       in  varchar2  default  null, -- request_id
  argument25       in  varchar2  default  null, -- user_id
  argument26       in  varchar2  default  null,
  argument27       in  varchar2  default  null,
  argument28       in  varchar2  default  null,
  argument29       in  varchar2  default  null,
  argument30       in  varchar2  default  null,
  argument31	   in  varchar2  default  null,
  argument32       in  varchar2  default  null,
  argument33       in  varchar2  default  null,
  argument34       in  varchar2  default  null,
  argument35       in  varchar2  default  null,
  argument36       in  varchar2  default  null,
  argument37       in  varchar2  default  null,
  argument38       in  varchar2  default  null,
  argument39       in  varchar2  default  null,
  argument40       in  varchar2  default  null,
  argument41	   in  varchar2  default  null,
  argument42       in  varchar2  default  null,
  argument43       in  varchar2  default  null,
  argument44       in  varchar2  default  null,
  argument45       in  varchar2  default  null,
  argument46       in  varchar2  default  null,
  argument47       in  varchar2  default  null,
  argument48       in  varchar2  default  null,
  argument49       in  varchar2  default  null,
  argument50       in  varchar2  default  null,
  argument51	   in  varchar2  default  null,
  argument52       in  varchar2  default  null,
  argument53       in  varchar2  default  null,
  argument54       in  varchar2  default  null,
  argument55       in  varchar2  default  null,
  argument56       in  varchar2  default  null,
  argument57       in  varchar2  default  null,
  argument58       in  varchar2  default  null,
  argument59       in  varchar2  default  null,
  argument60       in  varchar2  default  null,
  argument61	   in  varchar2  default  null,
  argument62       in  varchar2  default  null,
  argument63       in  varchar2  default  null,
  argument64       in  varchar2  default  null,
  argument65       in  varchar2  default  null,
  argument66       in  varchar2  default  null,
  argument67       in  varchar2  default  null,
  argument68       in  varchar2  default  null,
  argument69       in  varchar2  default  null,
  argument70       in  varchar2  default  null,
  argument71	   in  varchar2  default  null,
  argument72       in  varchar2  default  null,
  argument73       in  varchar2  default  null,
  argument74       in  varchar2  default  null,
  argument75       in  varchar2  default  null,
  argument76       in  varchar2  default  null,
  argument77       in  varchar2  default  null,
  argument78       in  varchar2  default  null,
  argument79       in  varchar2  default  null,
  argument80       in  varchar2  default  null,
  argument81	   in  varchar2  default  null,
  argument82       in  varchar2  default  null,
  argument83       in  varchar2  default  null,
  argument84       in  varchar2  default  null,
  argument85       in  varchar2  default  null,
  argument86       in  varchar2  default  null,
  argument87       in  varchar2  default  null,
  argument88       in  varchar2  default  null,
  argument89       in  varchar2  default  null,
  argument90       in  varchar2  default  null,
  argument91	   in  varchar2  default  null,
  argument92       in  varchar2  default  null,
  argument93       in  varchar2  default  null,
  argument94       in  varchar2  default  null,
  argument95       in  varchar2  default  null,
  argument96       in  varchar2  default  null,
  argument97       in  varchar2  default  null,
  argument98       in  varchar2  default  null,
  argument99       in  varchar2  default  null,
  argument100      in  varchar2  default null) is

h_request_id		number;
h_user_id 	   	number;
h_trx_low		date;
h_dateformat_2 	varchar2(25);
h_dateformat_3 	varchar2(25);
h_dateformat_4 	varchar2(25);
h_dateformat_5 	varchar2(25);
h_trx_low_datestr	varchar2(25);
h_trx_high		date;
h_trx_high_datestr	varchar2(25);
h_gl_low		date;
h_gl_low_datestr	varchar2(25);
h_gl_high		date;
h_gl_high_datestr	varchar2(25);
h_where_gl_flex  varchar2(2000);
h_lp_gltax_where  varchar2(2000);
h_dummy  varchar2(2000);

begin
-- get the request id
   h_request_id := fnd_global.conc_request_id;

-- data conversions
   h_user_id := to_number(argument18);

   if substr(argument2,1,instr(argument2,'_')-1) is null then
	 h_trx_low_datestr := argument2;
   else
	h_trx_low_datestr  := substr(argument2,1,instr(argument2,'_')-1);
   end if;


   if substr(argument3,1,instr(argument3,'_')-1) is null then
	 h_trx_high_datestr := argument3;
   else
   	 h_trx_high_datestr := substr(argument3,1,instr(argument3,'_')-1);
   end if;


   if substr(argument4,1,instr(argument4,'_')-1) is null then
	 h_gl_low_datestr := argument4;
   else
   	 h_gl_low_datestr   := substr(argument4,1,instr(argument4,'_')-1);
   end if;

   if substr(argument5,1,instr(argument5,'_')-1) is null then
	 h_gl_high_datestr := argument5;
   else
   	 h_gl_high_datestr  := substr(argument5,1,instr(argument5,'_')-1);
   end if;

   if substr(argument2,instr(argument2,'_')+1) = argument2 then
	 h_dateformat_2 := 'DD-MON-YYYY';
   else
	 h_dateformat_2 := substr(argument2,instr(argument2,'_')+1);
   end if;

   if substr(argument3,instr(argument3,'_')+1) = argument3 then
	 h_dateformat_3 := 'DD-MON-YYYY';
   else
	 h_dateformat_3 := substr(argument3,instr(argument3,'_')+1);
   end if;

   if substr(argument4,instr(argument4,'_')+1) = argument4 then
	 h_dateformat_4:= 'DD-MON-YYYY';
   else
	 h_dateformat_4 := substr(argument4,instr(argument4,'_')+1);
   end if;

   if substr(argument5,instr(argument5,'_')+1) = argument5 then
	 h_dateformat_5 := 'DD-MON-YYYY';
   else
	 h_dateformat_5 := substr(argument5,instr(argument5,'_')+1);
   end if;

   h_trx_low  := to_date(h_trx_low_datestr,h_dateformat_2);
   h_trx_high := to_date(h_trx_high_datestr,h_dateformat_3);
   h_gl_low   := to_date(h_gl_low_datestr,h_dateformat_4);
   h_gl_high  := to_date(h_gl_high_datestr,h_dateformat_5);

   -- build accounting flexfield where clauses
    h_where_gl_flex :=  argument11||argument12||argument13||
			argument14||argument15||argument16||
			argument17||argument18||argument19;

   h_dummy := replace(h_where_gl_flex,'BETWEEN','(+) BETWEEN');
   h_lp_gltax_where := replace(h_dummy,'CC.','GLTAX.');

-- call inner procedure

  arrx_sales_tax_rep.sales_tax_rpt (
	chart_of_accounts_id => argument1,
	trx_date_low => h_trx_low,
	trx_date_high => h_trx_high,
	gl_date_low => h_gl_low,
	gl_date_high => h_gl_high,
	state_low => argument6,
	state_high => argument7,
	currency_low => argument8,
	currency_high => argument9,
	exemption_status => argument10,
	lp_gltax_where => h_lp_gltax_where,
	where_gl_flex => h_where_gl_flex,
	show_deposit_children => argument20,
	detail_level => argument21,
	posted_status => argument22,
	show_cms_adjs_outside_date => argument23,
        request_id => h_request_id,
    	user_id => h_user_id,
        retcode => retcode,
    	errbuf => errbuf
    	);
 commit;

end AR_SALES_TAX;

FUNCTION CALL_SUBMIT_REQUEST(application IN varchar2 default NULL,
                          program     IN varchar2 default NULL,
                          description IN varchar2 default NULL,
                          start_time  IN varchar2 default NULL,
                          sub_request IN boolean  default FALSE,
                          argument1   IN varchar2 default NULL,
                          argument2   IN varchar2 default NULL,
                          argument3   IN varchar2 default NULL,
                          argument4   IN varchar2 default NULL,
                          argument5   IN varchar2 default NULL,
                          argument6   IN varchar2 default NULL,
                          argument7   IN varchar2 default NULL,
                          argument8   IN varchar2 default NULL,
                          argument9   IN varchar2 default NULL,
                          argument10  IN varchar2 default NULL,
                          argument11  IN varchar2 default NULL,
                          argument12  IN varchar2 default NULL,
                          argument13  IN varchar2 default NULL,
                          argument14  IN varchar2 default NULL,
                          argument15  IN varchar2 default NULL,
                          argument16  IN varchar2 default NULL,
                          argument17  IN varchar2 default NULL,
                          argument18  IN varchar2 default NULL,
                          argument19  IN varchar2 default NULL,
                          argument20  IN varchar2 default NULL,
                          argument21  IN varchar2 default NULL,
                          argument22  IN varchar2 default NULL,
                          argument23  IN varchar2 default NULL)
                          RETURN NUMBER IS
l_request_id     NUMBER :=0;
BEGIN
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARRX_SALES_TAX_REP_COVER.CALL_SUBMIT_REQUEST()+');
  END IF;
  l_request_id := FND_REQUEST.SUBMIT_REQUEST(
                          application, program, description, start_time,
                          sub_request, argument1, argument2, argument3,
                          argument4, argument5, argument6, argument7,
                          argument8, argument9, argument10, argument11,
                          argument12, argument13, argument14, argument15,
                          argument16, argument17, argument18, argument19,
                          argument20, argument21, argument22, argument23);
  IF PG_DEBUG in ('Y', 'C') THEN
     arp_util.debug('ARRX_SALES_TAX_REP_COVER.CALL_SUBMIT_REQUEST('||to_char(l_request_id)||')-');
  END IF;
  return l_request_id;
EXCEPTION
  WHEN OTHERS THEN
    IF PG_DEBUG in ('Y', 'C') THEN
       arp_util.debug('CALL_SUBMIT_REQUEST: ' || 'Error calling FND_REQUEST.SUBMIT_REQUEST.');
       arp_util.debug('CALL_SUBMIT_REQUEST: ' || SQLERRM);
    END IF;
    RAISE;
END CALL_SUBMIT_REQUEST;

end ARRX_SALES_TAX_REP_COVER;

/
