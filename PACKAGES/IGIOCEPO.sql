--------------------------------------------------------
--  DDL for Package IGIOCEPO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIOCEPO" AUTHID CURRENT_USER AS
-- $Header: igicecbs.pls 115.7 2002/09/10 09:35:02 mhazarik ship $

    PROCEDURE PO_DISTRIBUTION_SPREAD
    ( 	P_PO_HEADER_ID	PO_DISTRIBUTIONS.PO_HEADER_ID%TYPE,
	P_SOB_ID	GL_PERIOD_STATUSES.SET_OF_BOOKS_ID%TYPE
    );

    PROCEDURE ROUND_DISTRIBUTIONS
    ( PARAM_HEADER_ID	PO_DISTRIBUTIONS.PO_HEADER_ID%TYPE
    );

END IGIOCEPO;

 

/
