--------------------------------------------------------
--  DDL for Package BIM_SET_OF_BOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BIM_SET_OF_BOOKS" AUTHID CURRENT_USER AS
/* $Header: bimsobfs.pls 120.2 2005/09/26 23:45:34 arvikuma noship $*/

default_calender VARCHAR2(240)  :=  fnd_profile.value('AMS_CAMPAIGN_DEFAULT_CALENDER');
month_type       VARCHAR2(240)  :=  fnd_profile.value('BIM_IO_MONTH');
quarter_type     VARCHAR2(240)  :=  fnd_profile.value('BIM_IO_QUARTER');
year_type        VARCHAR2(240)  :=  fnd_profile.value('BIM_IO_YEAR');

PROCEDURE GET_FISCAL_DATA
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    ,x_year                    OUT NOCOPY VARCHAR2
    ,x_quarter                 OUT NOCOPY VARCHAR2
    ,x_month                   OUT NOCOPY VARCHAR2
    ,x_quarter_num             OUT NOCOPY NUMBER
    ,x_month_num               OUT NOCOPY NUMBER
    );

FUNCTION GET_FISCAL_MONTH
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN VARCHAR2;

FUNCTION GET_FISCAL_QTR
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN VARCHAR2;

FUNCTION GET_FISCAL_YEAR
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN VARCHAR2;

FUNCTION GET_FISCAL_ROLL_YEAR_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_MONTH_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_MONTH_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_QTR_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_QTR_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_YEAR_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_YEAR_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_ROLL_YEAR_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_ROLL_YEAR_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_MONTH_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_MONTH_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_QTR_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_QTR_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_YEAR_START
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_PRE_FISCAL_YEAR_END
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN DATE;

FUNCTION GET_FISCAL_QTR_NUM
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN NUMBER;

FUNCTION GET_MONTH_ORDER
   (
    p_month               IN VARCHAR2
    ,p_org_id                  IN  NUMBER
    )RETURN NUMBER;

FUNCTION GET_PRE_PERIOD
( p_name                 IN VARCHAR2
 ,p_type                 IN VARCHAR2
,p_org_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION GET_FISCAL_MONTH_NUM
   (
    p_input_date               IN DATE DEFAULT sysdate
    ,p_org_id                  IN  NUMBER
    )RETURN NUMBER;

FUNCTION GET_QTR_FROM_MONTH
( p_period_name            IN VARCHAR2
,p_org_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION GET_YEAR_FROM_MONTH
( p_period_name            IN VARCHAR2
,p_org_id                  IN  NUMBER
) RETURN VARCHAR2;

FUNCTION GET_YEAR_FROM_QTR
( p_period_name            IN VARCHAR2
,p_org_id                  IN  NUMBER
) RETURN VARCHAR2;


END BIM_SET_OF_BOOKS;

 

/
