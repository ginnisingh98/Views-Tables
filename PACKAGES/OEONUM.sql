--------------------------------------------------------
--  DDL for Package OEONUM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OEONUM" AUTHID CURRENT_USER AS
/* $Header: OEXONUMS.pls 115.1 99/07/16 08:13:55 porting shi $ */


PROCEDURE dummy;

PROCEDURE CreateSource
(
        sequence_name                   IN VARCHAR2,
        cache                           IN NUMBER,
        min_value                       IN NUMBER,
        start_with                      IN NUMBER,
        return_status                   OUT NUMBER
);

PROCEDURE GetCurrentNumber
(
        sequence_name                   IN VARCHAR2,
        returned_sequence               OUT NUMBER,
        return_status                   OUT NUMBER
);

PROCEDURE GetNextNumber
(
        sequence_name                   IN VARCHAR2,
        returned_sequence               OUT NUMBER,
        return_status                   OUT NUMBER
);

PROCEDURE OrderNumberSequence
(
        source_id                       IN NUMBER,
        action                          IN NUMBER,
        cache                           IN NUMBER DEFAULT 100,
        min_value                       IN NUMBER DEFAULT 1,
        start_with                      IN NUMBER DEFAULT 1,
        returned_sequence               OUT NUMBER,
        return_status                   OUT NUMBER
);

PROCEDURE Raise_exception
(
        Routine                         IN VARCHAR2,
        Operation                       IN VARCHAR2,
        Message                         IN VARCHAR2
);


END OEONUM;

 

/
