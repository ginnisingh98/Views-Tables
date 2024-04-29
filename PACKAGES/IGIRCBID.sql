--------------------------------------------------------
--  DDL for Package IGIRCBID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRCBID" AUTHID CURRENT_USER AS
-- $Header: igircids.pls 120.1.12000000.2 2007/11/08 17:25:31 sguduru noship $
    TYPE ParametersType IS RECORD
    (
        GlDateFrom                DATE,
        GlDateTo                  DATE,
        SetOfBooksId              NUMBER(15),
        CashSetOfBooksId          NUMBER(15),
        UnallocatedRevCcid        NUMBER(15),
        GlPostedDate              DATE,
        UnpostedPostingControlId  ar_posting_control.posting_control_id%TYPE := -3
    );
--
   PROCEDURE Prepare
      ( p_GlDateFrom      IN  DATE
        , p_GlDateTo        IN  DATE
        , p_GlPostedDate    IN  DATE
        );

-- CBR AR Changes
   PROCEDURE Prepare
      ( p_GlDateFrom      IN  DATE
        , p_GlDateTo        IN  DATE
        , p_GlPostedDate    IN  DATE
        , p_SetOfBooksId    IN NUMBER
        , p_CashSetOfBooksId IN NUMBER
        );

--

END;

 

/
