--------------------------------------------------------
--  DDL for Package Body ARP_PROCESS_ADJUSTMENT1
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_PROCESS_ADJUSTMENT1" AS
/* $Header: ARTEAD1B.pls 115.4 2002/10/23 23:50:48 vahluwal ship $ */

/*===========================================================================+
 | FUNCTION                                                                  |
 |   is_autoadj_candidate						     |
 |                                                                           |
 | DESCRIPTION                                                               |
 |   For an Autoadjustment made to the payment schedule of an Invoice, if the|
 |   Receivable Activity passed as parameter is Tax Inclusive meaning tax    |
 |   code source is 'INVOICE' or 'ACTIVITY' then the charge is tax inclusive |
 |   or the line adjustment to be created is tax inclusive, so the charge or |
 |   line bucket is closed and tax calculated and an adjustment sum of charge|
 |   or line amount including tax is created using the tax remaining amounts |
 |   on the payment schedule or the rate for ACTIVITY tax code.              |
 |                                                    	                     |
 |   A common rate is used to split the amount low and amount high, and the  |
 |   percent low and percent high into tax and line parts which are then     |
 |   compared with the actual line/charge amount and tax amount which sum of |
 |   which is used to create the final adjustment.                           |
 |                                                                           |
 |   If these  charges/line and tax amounts are withing the low and high     |
 |   amount and percent ranges, then the payment schedule is a valid         |
 |   candidate for creation of an autoadjustment.                            |
 |                                                                           |
 | SCOPE - PUBLIC                                                            |
 |                                                                           |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED -                                 |
 |   arpcurr.currround							     |
 |                                                                           |
 | ARGUMENTS  :  IN:                                                         |
 |    p_adj_low_amt                      Autoadjust low amount               |
 |    p_adj_high_amt                     Autoadjust high amount              |
 |    p_adj_low_pct                      Autoadjust low percent              |
 |    p_adj_high_pct                     Autoadjust high percent             |
 |    p_type                             Type of Adjustment (LINE/CHARGES)   |
 |    p_over_apply                       Over application flag for Trx Type  |
 |    p_tax_code_source                  Tax code source based on Activity   |
 |    p_tax_rate                         Actual tax rate when Tax code source|
 |                                       is ACTIVITY                         |
 |    p_line_remaining                   Line amount remaining               |
 |    p_charges_remaining                Line amount remaining               |
 |    p_tax_remaining                    Tax remaining                       |
 |    p_line_original                    Line or Charges amount original     |
 |    p_charges_original                 Line or Charges amount original     |
 |    p_tax_original                     Tax original                        |
 |    p_currency                         Currency                            |
 |                                                                           |
 | OUT        : NONE                                                         |
 |                                                                           |
 | RETURNS    : BOOLEAN   indicating whether payment schedule is             |
 |                        autoadjustment candidate.                          |
 |                                                                           |
 | NOTES: 								     |
 |    Null amounts must not be passed to this function always use an NVL with|
 |    0 when passing amounts and calling this function.                      |
 |    A seperate tax percent low and high parameter is required for Tax      |
 |    Inclusive adjustments, otherwise the maximum percentage over line,     |
 |    charges amount and tax amount high should be entered and a minimum low |
 |    percentage range over line charges amount and tax amount low should be |
 |    entered.                                                               |
 |                                                                           |
 | MODIFICATION HISTORY 						     |
 |     16-MAR-99  Vikram Ahluwalia    Created                                |
 +===========================================================================*/

FUNCTION is_autoadj_candidate(p_adj_low_amt       IN NUMBER   ,
                              p_adj_high_amt      IN NUMBER   ,
                              p_adj_low_pct       IN NUMBER   ,
                              p_adj_high_pct      IN NUMBER   ,
                              p_type              IN VARCHAR2 ,
                              p_over_apply        IN VARCHAR2 ,
                              p_tax_code_source   IN VARCHAR2 ,
                              p_tax_rate          IN NUMBER   ,
                              p_line_remaining    IN NUMBER   ,
                              p_charges_remaining IN NUMBER   ,
                              p_tax_remaining     IN NUMBER   ,
                              p_line_original     IN NUMBER   ,
                              p_charges_original  IN NUMBER   ,
                              p_tax_original      IN NUMBER   ,
                              p_currency          IN VARCHAR2 ) RETURN VARCHAR2 IS
l_adj_low_amt        NUMBER;
l_adj_tax_low_amt    NUMBER;
l_adj_high_amt       NUMBER;
l_adj_tax_high_amt   NUMBER;
l_cal_tax_remaining  NUMBER;
l_adj_low_pct        NUMBER;
l_adj_tax_low_pct    NUMBER;
l_adj_high_pct       NUMBER;
l_adj_tax_high_pct   NUMBER;
l_base_remaining     NUMBER;
l_base_original      NUMBER;
l_accum_tax_rem1     NUMBER;
l_accum_base_rem1    NUMBER;
l_accum_rem1         NUMBER;

BEGIN

 /*---------------------------------------------------------------------+
  |Set the base amounts to be used for processing, for type other than  |
  |Line, Charges a true condition is returned.                          |
  +---------------------------------------------------------------------*/
   IF p_type = 'LINE' THEN
      l_base_remaining := p_line_remaining;
      l_base_original  := p_line_original;
   ELSIF p_type = 'CHARGES' THEN
      l_base_remaining := p_charges_remaining;
      l_base_original  := p_charges_original;
   ELSE
      RETURN('Y');
   END IF;

  /*---------------------------------------------------------------------+
   |Compare tax inclusive adjustment low and high amount for tax code    |
   |source 'INVOICE' or 'ACTIVITY' using tax rate.                       |
   +---------------------------------------------------------------------*/
   IF ((p_adj_low_amt IS NOT NULL) AND (p_adj_high_amt IS NOT NULL)) THEN

      IF p_tax_code_source = 'INVOICE' AND  p_type IN ('LINE','CHARGES') THEN

         IF ((l_base_remaining + p_tax_remaining) = 0)
            OR (l_base_remaining = 0) THEN

             RETURN('N');

         ELSE

            l_adj_tax_low_amt  := arpcurr.currround((p_tax_remaining/(l_base_remaining + p_tax_remaining))
                                                   * p_adj_low_amt, p_currency);

            l_adj_low_amt      := p_adj_low_amt - l_adj_tax_low_amt;

            l_adj_tax_high_amt := arpcurr.currround((p_tax_remaining/(l_base_remaining + p_tax_remaining))
                                                   * p_adj_high_amt, p_currency);

            l_adj_high_amt     := p_adj_high_amt - l_adj_tax_high_amt;

         /*---------------------------------------------------------------------------+
          |Charges/Line amount should be between the charges/line low and high amount |
          |ranges. Tax amount should be between the tax low and high amount ranges.   |
          +---------------------------------------------------------------------------*/
            IF ((l_base_remaining BETWEEN l_adj_low_amt AND l_adj_high_amt)
               AND (p_tax_remaining  BETWEEN l_adj_tax_low_amt AND l_adj_tax_high_amt)) THEN
               RETURN('Y');
            ELSE
               RETURN('N');
            END IF;
         END IF;

      ELSIF ((p_tax_code_source = 'ACTIVITY') AND  (p_type IN ('LINE','CHARGES'))) THEN

            l_cal_tax_remaining := arpcurr.currround(l_base_remaining * p_tax_rate/100, p_currency);

            IF ((l_base_remaining + l_cal_tax_remaining) = 0) THEN
               RETURN('N');
            END IF;

            l_adj_tax_low_amt :=
                arpcurr.currround(p_adj_low_amt *
                                 l_cal_tax_remaining/(l_base_remaining + l_cal_tax_remaining ),
                                 p_currency);

            l_adj_low_amt := p_adj_low_amt - l_adj_tax_low_amt;

            l_adj_tax_high_amt :=
                arpcurr.currround(p_adj_high_amt *
                                 l_cal_tax_remaining/(l_base_remaining + l_cal_tax_remaining ),
                                 p_currency);

            l_adj_high_amt := p_adj_high_amt - l_adj_tax_high_amt;


         /*---------------------------------------------------------------------------+
          |Charges/Line amount should be between the charges/line low and high amount |
          |ranges. Tax amount should be between the tax low and high amount ranges.   |
          |If Overapply not allowed then we should not change sign of tax remaining.  |
          +---------------------------------------------------------------------------*/
            IF ((p_tax_remaining < l_cal_tax_remaining)
                OR ((l_base_remaining NOT BETWEEN l_adj_low_amt AND l_adj_high_amt)
                   AND (l_cal_tax_remaining  NOT BETWEEN l_adj_tax_low_amt AND l_adj_tax_high_amt))) THEN

              RETURN('N');
            ELSE
              RETURN('Y');
            END IF;

      ELSE -- implies p_tax_code_source = 'NONE' or p_type other than line or charges
            RETURN('Y');

      END IF;

   ELSE   --Check percentage range for tax inclusive line or charges adjustment
  /*---------------------------------------------------------------------+
   |Compare tax inclusive adjustment low and high percentage for tax code|
   |source 'INVOICE' or 'ACTIVITY' using tax rate.                       |
   +---------------------------------------------------------------------*/

      IF ((p_tax_code_source = 'INVOICE') AND  (p_type IN ('LINE','CHARGES'))) THEN

         IF (((p_tax_remaining + l_base_remaining) = 0)
              OR (l_base_remaining = 0)
              OR (l_base_original  = 0)) THEN
            RETURN('N');
         END IF;

       /*-------------------------------------------------------------------------------+
        | In reality there should be two percentage ranges one for tax low and high     |
        | and the other for line/charges amount low and high, this is because of the    |
        | fact that their percentage basis are different over the line/charges original |
        | or tax original, the check is done using a combined percent of line plus tax  |
        | remaining over the original line plus tax remaining and evaluated with the    |
        | percentage range which the user enters in the form                            |
        +-------------------------------------------------------------------------------*/
         l_accum_rem1 := ROUND(ABS((l_base_remaining + p_tax_remaining)
                                    /(l_base_original + p_tax_original)) * 100,2);

        IF l_accum_rem1 BETWEEN p_adj_low_pct and p_adj_high_pct THEN
              RETURN('Y');
        ELSE
              RETURN('N');
        END IF;

      ELSIF ((p_tax_code_source = 'ACTIVITY') AND  (p_type IN ('LINE','CHARGES'))) THEN

            l_cal_tax_remaining := arpcurr.currround(l_base_remaining * p_tax_rate/100, p_currency);

            IF (((l_base_remaining + l_cal_tax_remaining) = 0)
                 OR (l_base_original  = 0)
                 OR (sign(p_tax_remaining - l_cal_tax_remaining) NOT IN (0,sign(p_tax_remaining)))
                 OR ((sign(p_tax_remaining - l_cal_tax_remaining) = sign(p_tax_remaining))
                      AND (ABS(p_tax_remaining - l_cal_tax_remaining) > ABS(p_tax_remaining)))) THEN

                  RETURN('N');
            END IF;

       /*---------------------------------------------------------------------------+
        |Charges/Line percent amount should be between the charges/line low and high|
        |percent amount ranges. Tax percent amount should be between the tax low and|
        |high percent amount ranges. Percent calculated using tax amount calculated |
        |using tax rate on Activity on Line amount remaining.                       |
        +---------------------------------------------------------------------------*/
         l_accum_rem1 := ROUND(ABS((l_base_remaining + l_cal_tax_remaining)
                                   /(l_base_original + p_tax_original)) * 100,2);

         IF l_accum_rem1 BETWEEN p_adj_low_pct AND p_adj_high_pct THEN
              RETURN('Y');
         ELSE
              RETURN('N');
         END IF;

      ELSE -- implies p_tax_code_source = 'NONE' or p_type other than line or charges
            RETURN('Y');
      END IF; --end if p_tax_code_source is Invoice construct

   END IF; --end if adj amount low, high is not null

END is_autoadj_candidate;

END ARP_PROCESS_ADJUSTMENT1;

/
