--------------------------------------------------------
--  DDL for Package Body PAY_IN_ROUTES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_ROUTES" AS
/* $Header: pyinrout.pkb 120.3 2008/06/03 11:22:39 rsaharay noship $ */

g_package     CONSTANT VARCHAR2(100) := 'pay_in_routes.';
g_debug       BOOLEAN;

g_half_year_start1  CONSTANT VARCHAR2(6) := '01-04-';
g_half_year_start2  CONSTANT VARCHAR2(6) := '01-10-';

g_chalf_year_start1  CONSTANT VARCHAR2(6) := '01-01-';
g_chalf_year_start2  CONSTANT VARCHAR2(6) := '01-07-';


FUNCTION span_start (   p_input_date    DATE
                       ,p_frequency number DEFAULT 1
                       ,p_start_dd_mm VARCHAR2
                    )
RETURN DATE IS
  l_year  NUMBER(4);
  l_month NUMBER(2);
  l_function   VARCHAR(100);
  l_message     VARCHAR2(250);
  l_start DATE;

  --
BEGIN
   l_function := g_package||'span_start';
   pay_in_utils.set_location(g_debug,'Entering: '||l_function,10);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('p_input_date',p_input_date);
      pay_in_utils.trace ('p_frequency',p_frequency);
      pay_in_utils.trace ('p_start_dd_mm',p_start_dd_mm);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;
  -- Get the year component of the input date
   l_year := TO_NUMBER(TO_CHAR(p_input_date,'yyyy'));
  --

  IF p_frequency =1 THEN
    IF p_input_date >= TO_DATE(p_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy') THEN
      l_start := TO_DATE(p_start_dd_mm||TO_CHAR(l_year),'dd-mm-yyyy');
    ELSE
      l_start := TO_DATE(p_start_dd_mm||TO_CHAR(l_year -1),'dd-mm-yyyy');
    END IF;

  ELSIF p_frequency =2 THEN -- For half Yearly Dimension
    l_month :=TO_NUMBER(TO_CHAR(p_input_date,'mm'));
     IF l_month BETWEEN 4 AND 9 THEN
       l_start := TO_DATE(g_half_year_start1||TO_CHAR(l_year),'dd-mm-yyyy');
     ELSIF l_month BETWEEN 10 and 12 THEN
       l_start := TO_DATE(g_half_year_start2||TO_CHAR(l_year),'dd-mm-yyyy');
     ELSE
       l_start := TO_DATE(g_half_year_start2||TO_CHAR(l_year-1),'dd-mm-yyyy');
     END IF;

  ELSIF p_frequency =3 THEN -- For Currency half Yearly Dimension
    l_month :=TO_NUMBER(TO_CHAR(p_input_date,'mm'));
     IF l_month BETWEEN 1 AND 6 THEN
       l_start := TO_DATE(g_chalf_year_start1||TO_CHAR(l_year),'dd-mm-yyyy');
     ELSE
       l_start := TO_DATE(g_chalf_year_start2||TO_CHAR(l_year),'dd-mm-yyyy');
     END IF;
  END IF;

    pay_in_utils.trace('l_month ',l_month);
    pay_in_utils.set_location(g_debug,l_function,20);

    pay_in_utils.trace('l_start ',l_start);
    pay_in_utils.set_location(g_debug,l_function,30);

   IF g_debug THEN
      pay_in_utils.trace ('**************************************************','********************');
      pay_in_utils.trace ('l_start',l_start);
      pay_in_utils.trace ('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_function,30);
   RETURN l_start;
  --
END span_start;
END PAY_IN_ROUTES;

/
