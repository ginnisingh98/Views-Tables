--------------------------------------------------------
--  DDL for Package ORACLEON
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ORACLEON" AUTHID CURRENT_USER as
/* $Header: ICXONXS.pls 120.0 2005/10/07 12:17:20 gjimenez noship $ */

type display is table of varchar2(240)
        index by binary_integer;

procedure IC(Z in varchar2);

procedure IC(Y      in      varchar2        default null,
            a_1     in      varchar2        default null,
            a_2     in      varchar2        default null,
            a_3     in      varchar2        default null,
            a_4     in      varchar2        default null,
            a_5     in      varchar2        default null,
            c_1     in      varchar2        default null,
            c_2     in      varchar2        default null,
            c_3     in      varchar2        default null,
            c_4     in      varchar2        default null,
            c_5     in      varchar2        default null,
            i_1     in      varchar2        default null,
            i_2     in      varchar2        default null,
            i_3     in      varchar2        default null,
            i_4     in      varchar2        default null,
            i_5     in      varchar2        default null,
	    o       in      varchar2	    default 'AND',
	    m       in      varchar2        default null,
            p_start_row in  varchar2        default null,
            p_end_row   in  varchar2        default null,
            p_where     in  varchar2        default null,
            p_hidden    in  varchar2        default null);

procedure IC(X in varchar2);

procedure Find(X in varchar2);

procedure FindForm(X in varchar2);

procedure DisplayWhere(X in varchar2);

procedure csv(S in varchar2);

procedure getPages(c_flow_appl_id in number,
		   c_flow_code in varchar2,
		   c_page_appl_id in number,
		   c_page_code in varchar2,
		   c_level in number,
		   c_displayed in out NOCOPY display);

procedure getRegions(c_flow_appl_id in number,
                     c_flow_code in varchar2,
                     c_page_appl_id in number,
                     c_page_code in varchar2,
                     c_level in number,
                     c_displayed in out NOCOPY display);

end OracleON;

 

/
