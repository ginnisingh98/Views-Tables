--------------------------------------------------------
--  DDL for Package POR_HISTORY_FEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POR_HISTORY_FEED_PKG" AUTHID CURRENT_USER AS
/* $Header: PORHSFDS.pls 115.3 2002/11/18 22:47:03 dhli ship $ */
---------------------------------------------------------------------------------------
-- Parameters are passed to the Main Program in order to specify the set of PO records
-- to retrieve.  All the parameters are mandatory and are user-entered. They are validated
--in the Concurrent Manager before being passed to the program.
---------------------------------------------------------------------------------------

PROCEDURE Main (
   ERRBUF               OUT NOCOPY VARCHAR2,
   RETCODE              OUT NOCOPY VARCHAR2,  --this is NOT a number!
   i_card_brand          IN VARCHAR2,
   i_card_issuer_id      IN NUMBER,
   i_card_issuer_site_id IN NUMBER,
   i_from_date_time      IN VARCHAR2,
   i_to_date_time        IN VARCHAR2,
   i_output_filename     IN VARCHAR2
   );


END POR_History_Feed_Pkg;  --package

 

/
