--------------------------------------------------------
--  DDL for Package IGIRRPS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGIRRPS" AUTHID CURRENT_USER AS
--  $Header: igirrpss.pls 120.3.12000000.1 2007/08/31 05:53:31 mbremkum ship $

   PROCEDURE    SYNCHRONIZE_DATES ( errbuf            OUT NOCOPY VARCHAR2
                                  , retcode           OUT NOCOPY NUMBER
                                  , p_run_date1       IN VARCHAR2
                                  , p_set_of_books_id in NUMBER
                                  , p_batch_source_id in NUMBER
                                  , p_standing_charge_id in number default null
                                  , p_undo_last_change in varchar2
                                       default 'NO'
                                  );

   FUNCTION  GetNewPrevDate ( pp_standing_charge_id in number
                         , pp_date  in date
                         )
   RETURN DATE ;

   FUNCTION  GetNewNextDate ( pp_standing_charge_id in number
                         , pp_date  in date
                            )
   RETURN DATE ;

   PROCEDURE UpdateStandingCharges
                 (          pp_standing_charge_id  IN NUMBER
                           , pp_generate_sequence IN NUMBER )
      ;


END;

 

/
