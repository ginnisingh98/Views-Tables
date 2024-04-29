--------------------------------------------------------
--  DDL for Package FV_BE_XLA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_BE_XLA_PKG" AUTHID CURRENT_USER AS
-- $Header: FVBEXLAS.pls 120.2 2005/09/29 22:14:03 mbarrett noship $

  PROCEDURE BUDGETARY_CONTROL   (p_ledger_id        IN NUMBER
                                ,p_doc_id           IN NUMBER
                                ,p_doc_type         IN VARCHAR2
                                ,p_event_type       IN VARCHAR2
                                ,p_accounting_date  IN DATE
                                ,p_bc_mode          IN VARCHAR2 DEFAULT NULL
                                ,p_calling_sequence IN VARCHAR2
                                ,x_return_status    OUT NOCOPY VARCHAR2
                                ,x_status_code      OUT NOCOPY VARCHAR2);

  Function GET_CCID             (application_short_name  IN  Varchar2
		                ,key_flex_code	         IN  Varchar2
		                ,structure_number	 IN  Number
		                ,validation_date	 IN  Date
		                ,concatenated_segments   IN  Varchar2) Return Number;
END;

 

/
