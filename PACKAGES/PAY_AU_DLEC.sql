--------------------------------------------------------
--  DDL for Package PAY_AU_DLEC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_DLEC" AUTHID CURRENT_USER AS
/* $Header: pyaudlec.pkh 120.0 2005/05/29 03:04 appldev noship $ */

  ----------------------------------------------------------------------------
  --                                                                        --
  -- Name           : DISPLAY_LE_CHANGE                                     --
  -- Type           : PROCEDURE                                             --
  -- Access         : Private                                               --
  -- Description    : Procedure to display the employees who have had a     --
  --                : change in legal employer in a specified financial     --
  --                  year for AU.                                          --
  --                                                                        --
  -- Parameters     :                                                       --
  --             IN : p_business_group_id    NUMBER                         --
  --                  p_financial_year_end   VARCHAR2                       --
  --            OUT :                                                       --
PROCEDURE display_le_change (  errbuf      OUT NOCOPY VARCHAR2
                              ,retcode     OUT NOCOPY NUMBER
                              ,p_business_group_id    IN NUMBER
                              ,p_financial_year_end   IN NUMBER
                            );

END pay_au_dlec;

 

/
