--------------------------------------------------------
--  DDL for Package GMI_MO_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMI_MO_PURGE" AUTHID CURRENT_USER AS
 /* $Header: GMIPURGS.pls 115.0 2004/02/23 21:26:39 lswamy noship $ */
Procedure lines(
 errbuf                OUT NOCOPY     VARCHAR2,
 retcode               OUT NOCOPY     VARCHAR2,
 p_organization_id	IN NUMBER    :=NULL,
 p_date_from		IN VARCHAR2  :=NULL,
 p_date_to		IN VARCHAR2  :=NULL,
 p_lines_percommit      IN NUMBER    :=NULL,
 p_purge_option         IN NUMBER);

END GMI_MO_PURGE;

 

/
