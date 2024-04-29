--------------------------------------------------------
--  DDL for Package FII_CHANGE_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FII_CHANGE_LOG_PKG" AUTHID CURRENT_USER as
/*$Header: FIIFLOGS.pls 120.1 2005/10/30 05:14:10 appldev ship $*/

procedure update_change_log(p_log_item 		in varchar2,
                            p_item_value 	in varchar2,
			    x_status  		out nocopy varchar2,
                            x_message_count 	out nocopy number,
                            x_error_message 	out nocopy varchar2);

procedure set_recollection_for_fii(x_status 		out nocopy varchar2,
                                   x_message_count 	out nocopy number,
                                   x_error_message 	out nocopy varchar2);

procedure add_change_log_item(p_log_item 		in varchar2,
                              p_item_value 	    in varchar2,
			                  x_status  		out nocopy varchar2,
                              x_message_count 	out nocopy number,
                              x_error_message 	out nocopy varchar2);

end FII_CHANGE_LOG_PKG;

 

/
