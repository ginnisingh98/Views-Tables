--------------------------------------------------------
--  DDL for Package IGIRRGPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRRGPP" AUTHID CURRENT_USER AS
-- $Header: igirrgps.pls 120.3.12000000.1 2007/08/31 05:53:16 mbremkum ship $

   PROCEDURE UpdatePriceCP ( errbuf out NOCOPY varchar2, retcode out NOCOPY number ,pp_run_id in number);

   PROCEDURE CreateLines
                      ( pp_run_id                 in number
                      , pp_item_code_from         in varchar2
                      , pp_item_code_to           in varchar2
                      , pp_amount                 in number
                      , pp_percentage_amount      in number
                      , pp_incr_decr_flag         in varchar2
                      , pp_update_effective_date  in date
                      , pp_creation_date          in date
                      , pp_created_by             in number
                      , pp_last_update_date       in date
                      , pp_last_updated_by        in number
                      , pp_last_update_login      in number
                      , pp_option_flag            in varchar2
                      ) ;



END; -- Package spec

 

/
