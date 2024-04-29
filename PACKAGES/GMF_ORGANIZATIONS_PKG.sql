--------------------------------------------------------
--  DDL for Package GMF_ORGANIZATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_ORGANIZATIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: GMFPORGS.pls 120.1.12010000.2 2009/08/17 13:38:01 rpatangy ship $ */

  PROCEDURE get_process_organizations(p_Legal_Entity_id  IN  NUMBER,
                                      p_From_Orgn_Code   IN  VARCHAR2,
                                      p_To_Orgn_Code     IN  VARCHAR2,
                                      p_period_id        IN  NUMBER DEFAULT NULL,
                                      x_Row_Count        OUT NOCOPY NUMBER,
                                      x_Return_Status    OUT NOCOPY NUMBER);
END;

/
