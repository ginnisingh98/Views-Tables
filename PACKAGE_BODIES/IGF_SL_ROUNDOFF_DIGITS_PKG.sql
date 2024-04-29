--------------------------------------------------------
--  DDL for Package Body IGF_SL_ROUNDOFF_DIGITS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_ROUNDOFF_DIGITS_PKG" AS
/* $Header: IGFSL14B.pls 115.13 2003/12/04 15:48:14 sjadhav ship $ */

--
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
--  sjadhav       3-Dec-2003      Corrected lp_disb_num additions
-----------------------------------------------------------------
--  sjadhav       28-Nov-2003     Use Disb Numbers instead
--                                of % as the % may not total
--                                to 100% all the time
-----------------------------------------------------------------
-- avenkatr       20-Apr-01       1. Assigned values to the OUT
--                                NOCOPY parameters of procedure
--                                gross_fees_roundoff.
-----------------------------------------------------------------
--

PROCEDURE gross_fees_roundoff ( p_last_disb_num      IN            NUMBER,
                                p_offered_amt        IN            NUMBER,
                                p_fee_perct          IN            NUMBER,
                                p_disb_gross_amt     IN OUT NOCOPY NUMBER,
                                p_disb_net_amt          OUT NOCOPY NUMBER,
                                p_fee                   OUT NOCOPY NUMBER )  IS

BEGIN
--
-- Rounding off Process for Gross Amount. The logic is that
-- if there are n disbursement amounts then the disbursement
-- gross amount for n-1 disb amts is calculated as
-- offered amount by the number of disbursements and the resule
-- is rounded off. Whereas the nth disb amts logic is that
-- rounded off gross amt is multiplied with the no of disbursements
-- and if it greater than offered amt then it is subtracted from the
-- roundedoff disbursement gross amount else it is added with
-- the amount.
--

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','In Param : p_last_disb_num '||p_last_disb_num);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','In Param : p_offered_amt '||p_offered_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','In Param : p_fee_perct '||p_fee_perct);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','In Param : p_disb_gross_amt '||p_disb_gross_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Spec lp_disb_number 1: lp_disb_number '||lp_disb_number);
  END IF;

  lp_disb_number  := NVL(lp_disb_number,0)  + 1;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Spec lp_disb_number 2: lp_disb_number '||lp_disb_number);
  END IF;

  IF lp_disb_number <> p_last_disb_num THEN
    --
    -- Not the last disbursement
    --

    p_disb_gross_amt  := ROUND( p_disb_gross_amt );
    lp_current_amt    := NVL(lp_current_amt,0) + NVL(p_disb_gross_amt,0);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Disb <> Last : p_disb_gross_amt '||p_disb_gross_amt);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Disb <> Last : lp_current_amt '||lp_current_amt);
    END IF;


  ELSE
    --
    -- This is the last disbursement
    --

    p_disb_gross_amt   := NVL(p_offered_amt,0) - NVL(lp_current_amt,0);
    p_disb_gross_amt   := ROUND(p_disb_gross_amt);
    lp_current_amt     := 0;
    lp_disb_number     := 0;

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Disb = Last : p_disb_gross_amt '||p_disb_gross_amt);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Disb = Last : lp_current_amt '||lp_current_amt);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Disb = Last : lp_disb_number '||lp_disb_number);
    END IF;

  END IF;

  p_fee               := TRUNC( NVL(p_disb_gross_amt,0) * ((NVL(p_fee_perct,0))/100));
  p_disb_net_amt      := NVL(p_disb_gross_amt,0) - NVL(p_fee,0);

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Out Param : p_disb_gross_amt '||p_disb_gross_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','OutParam : p_disb_net_amt '||p_disb_net_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.dl_round.debug','Out Param : p_fee '||p_fee);
  END IF;


END gross_fees_roundoff ;



PROCEDURE cl_gross_fees_roundoff ( p_last_disb_num      IN              NUMBER,
                                   p_offered_amt        IN              NUMBER,
                                   p_disb_gross_amt     IN OUT NOCOPY   NUMBER  )  IS

BEGIN

--
-- Rounding off Process for Gross Amount. The logic is that
-- if there are n disbursement amounts then the disbursement
-- gross amount for n-1 disb amts is calculated as
-- offered amount by the number of disbursements and the resule
-- is rounded off. Whereas the nth disb amts logic is that
-- rounded off gross amt is multiplied with the no of disbursements
-- and if it greater than offered amt then it is subtracted from the
-- roundedoff disbursement gross amount else it is added with
-- the amount.
--
  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','In Param : p_last_disb_num '||p_last_disb_num);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','In Param : p_offered_amt '||p_offered_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','In Param : p_disb_gross_amt '||p_disb_gross_amt);
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Spec lp_disb_number 1: lp_disb_number '||lp_disb_number);
  END IF;

  lp_disb_number  := NVL(lp_disb_number,0)  + 1;

  IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
     fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Spec lp_disb_number 2: lp_disb_number '||lp_disb_number);
  END IF;

  IF lp_disb_number <> p_last_disb_num THEN
    --
    -- Not the last disbursement
    --
    p_disb_gross_amt  := ROUND( p_disb_gross_amt );
    lp_current_amt    := NVL(lp_current_amt,0) + NVL(p_disb_gross_amt,0);

    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Disb <> Last : p_disb_gross_amt '||p_disb_gross_amt);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Disb <> Last : lp_current_amt '||lp_current_amt);
    END IF;

  ELSE
    --
    -- This is the last disbursement
    --

    p_disb_gross_amt  := NVL(p_offered_amt,0) - NVL(lp_current_amt,0);
    p_disb_gross_amt  := ROUND(p_disb_gross_amt);
    lp_current_amt    := 0;
    lp_disb_number    := 0;
    IF fnd_log.level_statement >= fnd_log.g_current_runtime_level THEN
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Disb = Last : p_disb_gross_amt '||p_disb_gross_amt);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Disb = Last : lp_current_amt '||lp_current_amt);
       fnd_log.string(fnd_log.level_statement,'igf.plsql.igf_sl_roundoff_digits_pkg.cl_round.debug','Disb = Last : lp_disb_number '||lp_disb_number);
    END IF;

  END IF;

END cl_gross_fees_roundoff ;


END igf_sl_roundoff_digits_pkg;


/
