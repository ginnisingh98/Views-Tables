--------------------------------------------------------
--  DDL for Package FEM_SIGNAGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_SIGNAGE_PKG" AUTHID CURRENT_USER AS
-- $Header: fem_signage_utl.pls 120.0 2005/06/06 21:37:40 appldev noship $

PROCEDURE Sign_Ext_Acct_Types  (
   errbuf          OUT NOCOPY VARCHAR2,
   retcode         OUT NOCOPY VARCHAR2
);

END FEM_Signage_Pkg;

 

/
