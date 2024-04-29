--------------------------------------------------------
--  DDL for Package BIX_SESSION_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIX_SESSION_LOAD_PKG" AUTHID CURRENT_USER AS
/*$Header: bixagtls.pls 115.0 2003/05/15 23:36:04 achanda noship $ */

PROCEDURE  load (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2);

END BIX_SESSION_LOAD_PKG;

 

/
