--------------------------------------------------------
--  DDL for Package PAY_IN_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_ROUTES" AUTHID CURRENT_USER AS
/* $Header: pyinrout.pkh 120.0 2005/05/29 05:53 appldev noship $ */
FUNCTION span_start (   p_input_date    DATE
                    ,   p_frequency  number DEFAULT 1
                    ,   p_start_dd_mm VARCHAR2
                    )
RETURN DATE;
END PAY_IN_ROUTES;

 

/
