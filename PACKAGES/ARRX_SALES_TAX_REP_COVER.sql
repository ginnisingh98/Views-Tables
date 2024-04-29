--------------------------------------------------------
--  DDL for Package ARRX_SALES_TAX_REP_COVER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ARRX_SALES_TAX_REP_COVER" AUTHID CURRENT_USER as
/* $Header: ARRXCSTS.pls 115.2 2002/11/15 03:11:50 anukumar ship $ */
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
  argument17       in  varchar2,   -- where_gl_flex7
  argument18       in  varchar2,   -- where_gl_flex8
  argument19       in  varchar2,   -- where_gl_flex9
  argument20       in  varchar2,   -- show_deposit_children
  argument21	   in  varchar2,  -- detail_level L/H
  argument22       in  varchar2,   -- posted_status
  argument23       in  varchar2,   -- show_cms_adjs_outside_date
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
  argument100      in  varchar2  default null);

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
                          return number;

end ARRX_SALES_TAX_REP_COVER;

 

/
