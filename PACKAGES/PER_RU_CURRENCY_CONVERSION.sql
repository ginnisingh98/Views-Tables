--------------------------------------------------------
--  DDL for Package PER_RU_CURRENCY_CONVERSION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_RU_CURRENCY_CONVERSION" AUTHID CURRENT_USER AS
/* $Header: perucurr.pkh 120.1.12010000.1 2008/10/01 07:14:12 parusia noship $ */
--
--
  PROCEDURE currency_rur_to_rub
             (errbuf                      OUT NOCOPY VARCHAR2
             ,retcode                     OUT NOCOPY NUMBER
             ,p_business_group_id         IN  NUMBER
             ,p_conv_curr_code            IN  VARCHAR2
             );
--
  FUNCTION get_converted_curr_code ( p_business_group_id NUMBER )
    RETURN VARCHAR2;
--
END PER_RU_CURRENCY_CONVERSION ;

/
