--------------------------------------------------------
--  DDL for Package MSC_DRP_SRC_ALLOC_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_DRP_SRC_ALLOC_RULES" AUTHID CURRENT_USER AS
/* $Header: MSCALOCS.pls 120.0 2005/10/26 12:40 rawasthi noship $ */

PROCEDURE MISSING_SRC_ALLOC_RULES (
                                          errbuf        OUT NOCOPY VARCHAR2,
                                          retcode       OUT NOCOPY VARCHAR2,
                                          p_instance_id IN  number,
					  p_assignment_set IN VARCHAR2,
					  p_validation IN NUMBER
					  );
END MSC_DRP_SRC_ALLOC_RULES;

 

/
