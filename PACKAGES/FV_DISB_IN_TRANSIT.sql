--------------------------------------------------------
--  DDL for Package FV_DISB_IN_TRANSIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_DISB_IN_TRANSIT" AUTHID CURRENT_USER AS
-- $Header: FVAPDITS.pls 120.3 2005/10/28 05:23:01 svaithil ship $
   PROCEDURE main(			errbuf		 OUT NOCOPY 		VARCHAR2,
      					retcode      OUT NOCOPY 		VARCHAR2,
      					x_char_treas_conf_id    IN 		VARCHAR2,
      					v_button_name           IN 		VARCHAR2);

   PROCEDURE void(			errbuf		 OUT NOCOPY 	varchar2,
					retcode		 OUT NOCOPY 	varchar2);

   PROCEDURE get_segment_values(	v_gs_ccid 				number);

END fv_disb_in_transit;

 

/
