--------------------------------------------------------
--  DDL for Package IGI_RPI_UPDATE_VAT_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_RPI_UPDATE_VAT_RATE" AUTHID CURRENT_USER AS
-- $Header: igirruvrs.pls 120.0.12010000.1 2010/02/15 09:41:48 vensubra noship $

PROCEDURE update_vat_rate (  errbuf            OUT  NOCOPY   VARCHAR2
                           , retcode           OUT  NOCOPY   NUMBER
				   , p_org_id          IN   NUMBER
				   , p_old_vat_id      IN   NUMBER
                       	   , p_new_vat_id      IN   NUMBER
				   , p_effective_date  IN   VARCHAR2 DEFAULT SYSDATE
				   , p_mode	   	     IN   VARCHAR2
                          );

END IGI_RPI_UPDATE_VAT_RATE;

/
