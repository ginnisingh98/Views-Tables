--------------------------------------------------------
--  DDL for Package IGF_SL_ROUNDOFF_DIGITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_ROUNDOFF_DIGITS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFSL14S.pls 115.8 2003/12/04 15:48:15 sjadhav ship $ */

--
-----------------------------------------------------------------
--  Created By : prchandr
--  Created On :06-APR-2001
--  Purpose : Rounding off Logic implemented
--  Known limitations, enhancements or remarks :
--  Change History :
-----------------------------------------------------------------
--  Who           When            What
-----------------------------------------------------------------
--  sjadhav       4-Dec-2003      Removed p_curr_disb_num
-----------------------------------------------------------------
--  sjadhav       3-Dec-2003      Removed fee perct from
--                                cl round off
-----------------------------------------------------------------
--  sjadhav       28-Nov-2003     Use Disb Numbers instead
--                                of % as the % may not total
--                                to 100% all the time
-----------------------------------------------------------------
--

  PROCEDURE gross_fees_roundoff
            (
              p_last_disb_num      IN              NUMBER,
              p_offered_amt        IN              NUMBER,
              p_fee_perct          IN              NUMBER,
              p_disb_gross_amt     IN OUT NOCOPY   NUMBER,
              p_disb_net_amt          OUT NOCOPY   NUMBER,
              p_fee                   OUT NOCOPY   NUMBER
             );


  PROCEDURE cl_gross_fees_roundoff
            (
              p_last_disb_num      IN              NUMBER,
              p_offered_amt        IN              NUMBER,
              p_disb_gross_amt     IN OUT NOCOPY   NUMBER
             );


lp_disb_number   NUMBER;
lp_current_amt   NUMBER(12,2);

END igf_sl_roundoff_digits_pkg;

 

/
