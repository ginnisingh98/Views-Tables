--------------------------------------------------------
--  DDL for Package PON_RESP_SCORES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_RESP_SCORES_PKG" AUTHID CURRENT_USER as
/* $Header: PONSCORES.pls 120.0 2005/06/01 21:21:49 appldev noship $ */
-------------------------------------------------------------------------------
--------------------------  PACKAGE STUB --------------------------------------
-------------------------------------------------------------------------------
procedure get_acceptable_values(p_auction_id 		in number,
				p_line_number 		in number,
				p_attr_seq_number 	in number,
				p_acc_values 		out NOCOPY varchar2,
				p_scores 		out NOCOPY varchar2);

FUNCTION display_db_date_string(p_date_str IN VARCHAR2,
                      p_client_timezone_id IN VARCHAR2,
                      p_server_timezone_id IN VARCHAR2,
                      p_datetime_flag      IN VARCHAR2,
                      p_date_format_mask   IN VARCHAR2)
			RETURN VARCHAR2;

END PON_RESP_SCORES_PKG;

 

/
