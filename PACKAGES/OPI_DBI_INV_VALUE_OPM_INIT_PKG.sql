--------------------------------------------------------
--  DDL for Package OPI_DBI_INV_VALUE_OPM_INIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OPI_DBI_INV_VALUE_OPM_INIT_PKG" AUTHID CURRENT_USER AS
/*$Header: OPIDIPIS.pls 115.1 2003/04/29 22:11:04 warwu noship $ */

-- ---------------------------------------------------------
--  PROCEDURES
-- ---------------------------------------------------------

   PROCEDURE Run_OPM_First_ETL
   (
       errbuf in out NOCOPY varchar2,
       retcode in out NOCOPY varchar2
   );

-- ---------------------------------------------------------
--  FUNCTIONS
-- ---------------------------------------------------------


End OPI_DBI_INV_VALUE_OPM_INIT_PKG;

 

/
