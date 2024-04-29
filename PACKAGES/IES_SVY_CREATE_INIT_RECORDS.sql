--------------------------------------------------------
--  DDL for Package IES_SVY_CREATE_INIT_RECORDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_SVY_CREATE_INIT_RECORDS" AUTHID CURRENT_USER AS
/* $Header: iescrirs.pls 120.0 2005/06/03 07:52:51 appldev noship $ */
----------------------------------------------------------------------------------------------------------
-- Procedure
-- Create_Initial_Records

-- PURPOSE
--   Create Initial Records in Summary Tables
--
-- PARAMETERS

-- NOTES
-- created rrsundar 05/03/2000
---------------------------------------------------------------------------------------------------------

PROCEDURE CREATE_INITIAL_RECORDS(
--    errbuf		    OUT VARCHAR2                                     ,
 --   retcode		    OUT NUMBER                                       ,
    p_deployment_id         IN  NUMBER
     );
END; -- Package spec

 

/
