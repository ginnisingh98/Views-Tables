--------------------------------------------------------
--  DDL for Package BIM_VALIDITY_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_VALIDITY_CHECK" AUTHID CURRENT_USER AS
/* $Header: bimvalcs.pls 120.1 2005/06/06 15:13:33 appldev  $*/

FUNCTION  validate_periods(
   p_input_date               DATE) return VARCHAR2;

FUNCTION  call_currency(
   p_from_currency IN    VARCHAR2) return VARCHAR2;

FUNCTION  validate_currency(
p_start_date IN  DATE
,p_end_date IN  DATE
)  return VARCHAR2;


FUNCTION  validate_campaigns
   (
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    x_period_error          OUT NOCOPY  VARCHAR2,
    x_currency_error        OUT  NOCOPY VARCHAR2
   ) return NUMBER;

FUNCTION  validate_events
   (
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    x_period_error          OUT  NOCOPY VARCHAR2,
    x_currency_error        OUT   NOCOPY VARCHAR2
   ) return NUMBER;

FUNCTION  validate_budgets
   (
    p_start_date            IN   DATE,
    p_end_date              IN   DATE,
    x_period_error          OUT NOCOPY  VARCHAR2,
    x_currency_error        OUT NOCOPY VARCHAR2
   ) return NUMBER;

END BIM_VALIDITY_CHECK;

 

/
