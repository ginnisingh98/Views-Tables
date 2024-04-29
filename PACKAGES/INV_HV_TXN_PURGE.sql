--------------------------------------------------------
--  DDL for Package INV_HV_TXN_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_HV_TXN_PURGE" AUTHID CURRENT_USER AS
/* $Header: INVHVPGS.pls 115.0 2003/03/10 20:59:17 jsugumar noship $ */

--Return values for x_retcode(standard for concurrent programs)
	RETCODE_SUCCESS  CONSTANT VARCHAR2(1)  := '0';
	RETCODE_WARNING  CONSTANT VARCHAR2(1)  := '1';
	RETCODE_ERROR    CONSTANT VARCHAR2(1)  := '2';


-- Procedure to Purge the transaction tables
   PROCEDURE Txn_Purge( x_errbuf	         OUT NOCOPY VARCHAR2
                        ,x_retcode	      OUT NOCOPY NUMBER
                        ,p_organization_id	IN  NUMBER   := NULL
                        ,p_cut_off_date		IN  VARCHAR2
                       );


END INV_HV_TXN_PURGE;


 

/
