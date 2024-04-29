--------------------------------------------------------
--  DDL for Package BIM_LEAD_RG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_LEAD_RG_PKG" AUTHID CURRENT_USER AS
/* $Header: bimldrgs.pls 120.1 2005/06/14 15:21:46 appldev  $*/


PROCEDURE  populate
   (ERRBUF                  OUT NOCOPY VARCHAR2,
    RETCODE                 OUT NOCOPY NUMBER);

END BIM_LEAD_RG_PKG;

 

/
