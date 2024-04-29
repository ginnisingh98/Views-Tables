--------------------------------------------------------
--  DDL for Package IGIPMSLR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIPMSLR" AUTHID CURRENT_USER AS
-- $Header: igipmsls.pls 115.4 2002/09/20 14:18:26 zazeez ship $

   PROCEDURE Create_MPPSLR_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     );

   PROCEDURE Update_MPPSLR_Details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     );

   PROCEDURE Delete_MPPSLR_details
     ( p_invoice_id in number
     , p_distribution_line_number in number
     );


END; -- Package spec

 

/
