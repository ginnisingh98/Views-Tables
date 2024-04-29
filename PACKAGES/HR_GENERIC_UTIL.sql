--------------------------------------------------------
--  DDL for Package HR_GENERIC_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_GENERIC_UTIL" AUTHID CURRENT_USER AS
/* $Header: pygenutl.pkh 120.1 2005/10/04 06:31:17 rchennur noship $ */

PROCEDURE get_period_dates
            (p_rec_period_start_date IN  DATE
            ,p_period_type           IN  VARCHAR2
            ,p_current_date          IN  DATE
            ,p_period_start_date     OUT NOCOPY DATE
            ,p_period_end_date       OUT NOCOPY DATE);

END hr_generic_util;

 

/
