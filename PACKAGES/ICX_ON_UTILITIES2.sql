--------------------------------------------------------
--  DDL for Package ICX_ON_UTILITIES2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_ON_UTILITIES2" AUTHID CURRENT_USER as
/* $Header: ICXONVS.pls 120.0 2005/10/07 12:17:01 gjimenez noship $ */

procedure displaySetIcons(p_language_code in varchar2,
                          p_packproc in varchar2,
                          p_start_row in number,
                          p_stop_row in number,
                          p_encrypted_where in number,
                          p_query_set in number,
                          p_row_count in number,
                          p_top in boolean default TRUE,
			  p_jsproc in varchar2 default null,
			  p_hidden in varchar2 default null,
			  p_update in boolean default FALSE,
			  p_target in varchar2 default null);

procedure displayRegion(p_region_rec_id in number);

procedure printPLSQLtables;

end icx_on_utilities2;

 

/
