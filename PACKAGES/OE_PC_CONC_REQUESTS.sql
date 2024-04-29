--------------------------------------------------------
--  DDL for Package OE_PC_CONC_REQUESTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PC_CONC_REQUESTS" AUTHID CURRENT_USER as
/* $Header: OEXPCRQS.pls 120.0 2005/05/31 23:12:18 appldev noship $ */

PROCEDURE Create_Validation_Packages
                (ERRBUF         OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                ,RETCODE        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
                );

END OE_PC_Conc_Requests;

 

/
