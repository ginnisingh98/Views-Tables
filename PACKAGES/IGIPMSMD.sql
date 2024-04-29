--------------------------------------------------------
--  DDL for Package IGIPMSMD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIPMSMD" AUTHID CURRENT_USER AS
-- $Header: igipmmds.pls 115.6 2002/09/20 13:47:52 zazeez ship $

    PROCEDURE Create_MPP_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     , p_accounting_rule_id       in number
     , p_start_date               in date
     , p_duration                 in number
     );

   PROCEDURE Update_MPP_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     , p_accounting_rule_id       in number
     );

   PROCEDURE Delete_MPP_details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     , p_accounting_rule_id       in number
     , p_ignore_mpp_flag          in number
     );


END; -- Package spec

 

/
