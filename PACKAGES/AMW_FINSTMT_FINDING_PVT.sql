--------------------------------------------------------
--  DDL for Package AMW_FINSTMT_FINDING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_FINSTMT_FINDING_PVT" AUTHID CURRENT_USER AS
/* $Header: amwffins.pls 120.0 2005/05/31 20:59:29 appldev noship $ */

  PROCEDURE POPULATE_FINSTMT_FINDINGS(errbuf  OUT NOCOPY VARCHAR2,
                      retcode OUT NOCOPY VARCHAR2,
                      p_certification_id IN NUMBER);

PROCEDURE Populate_Fin_Summary(p_certification_id IN NUMBER);



END AMW_FINSTMT_FINDING_PVT;

 

/
