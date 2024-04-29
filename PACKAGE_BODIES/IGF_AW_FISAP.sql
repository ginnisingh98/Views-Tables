--------------------------------------------------------
--  DDL for Package Body IGF_AW_FISAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FISAP" AS
/* $Header: IGFAW11B.pls 120.1 2006/01/31 03:24:56 veramach noship $ */

PROCEDURE log_messages ( p_msg_name  VARCHAR2 ,
                         p_msg_val   VARCHAR2
                                                   ) IS
  ------------------------------------------------------------------
  --Created by  : pkpatel, Oracle IDC
  --Date created: 01-NOV-2001
  --
  --Purpose: This procedure is private to this package body .
  --         The procedure logs all the parameter values
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------
  BEGIN
    FND_MESSAGE.SET_NAME('IGS','IGS_FI_CAL_BALANCES_LOG');
    FND_MESSAGE.SET_TOKEN('PARAMETER_NAME',p_msg_name);
    FND_MESSAGE.SET_TOKEN('PARAMETER_VAL' ,p_msg_val) ;
    FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
  END log_messages ;

  PROCEDURE aggregate_match(
                             errbuf			OUT NOCOPY		VARCHAR2,
                             retcode			OUT NOCOPY		NUMBER,
                             p_award_year               IN              VARCHAR2,
                             p_sum_type                 IN              VARCHAR2,
                             p_org_id                   IN              NUMBER
                             ) IS
          /*
	  ||  Created By : Prabhat.Patel@Oracle.com
	  ||  Created On : 01-NOV-2001
	  ||  Purpose : This is the driving procedure for the concurrent job
	  ||            'Aggregate Matching'
	  ||  Known limitations, enhancements or remarks :
	  ||  Change History :
	  ||  Who             When            What
	  ||  (reverse chronological order - newest change first)
	  */
          l_ci_cal_type    igs_ca_inst.cal_type%TYPE;
          l_ci_sequence_number  igs_ca_inst.sequence_number%TYPE;
          l_tot_fseog        NUMBER := 0;
          l_tot_match        NUMBER := 0;
          l_total            NUMBER := 0;
          l_fseog_pcntg      NUMBER(5,2) := 0;
          l_match_pcntg      NUMBER(5,2) := 0;
          l_alternate_code  igs_ca_inst.alternate_code%TYPE;

          --Cursor to find the SUM of Amounts for FSEOG funds
          CURSOR   c_fseog_sum(cp_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                               cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE)
          IS
            SELECT SUM (NVL (DECODE (
                            p_sum_type,
                            'PAID', awd.paid_amt,
                            'OFFERED', awd.offered_amt,
                            'ACCEPTED', awd.accepted_amt
                         ),
                         0)) total_fseog
              FROM igf_aw_award_all awd,
                   igf_aw_fund_mast_all fmast,
                   igf_aw_fund_cat_all fcat
             WHERE fcat.fed_fund_code = 'FSEOG'
               AND fmast.ci_cal_type = cp_ci_cal_type
               AND fmast.ci_sequence_number = cp_ci_sequence_number
               AND fmast.fund_code = fcat.fund_code
               AND awd.fund_id = fmast.fund_id;

          --Cursor to find the SUM of Amounts for Matching funds
          CURSOR c_match_sum(cp_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                             cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE)
          IS
            SELECT SUM (NVL (DECODE (
                            p_sum_type,
                            'PAID', awd.paid_amt,
                            'OFFERED', awd.offered_amt,
                            'ACCEPTED', awd.accepted_amt
                         ),
                         0)) total_match
              FROM igf_aw_award_all awd
             WHERE awd.fund_id IN (
                      SELECT fund_id
                        FROM igf_aw_fseog_match
                       WHERE ci_cal_type = cp_ci_cal_type
                         AND ci_sequence_number = cp_ci_sequence_number);

          --Cursor to find the User Parameter Award Year (which is same as Alternate Code)
          CURSOR c_alternate_code(cp_ci_cal_type    igs_ca_inst.cal_type%TYPE,
                                  cp_ci_sequence_number  igs_ca_inst.sequence_number%TYPE)   IS
          SELECT  alternate_code
          FROM    igs_ca_inst
          WHERE   cal_type = cp_ci_cal_type
          AND     sequence_number = cp_ci_sequence_number;

      BEGIN
           retcode := 0 ;
           igf_aw_gen.set_org_id(p_org_id);

           --Cal Type and Sequence Number are retrived from parameter Award Year
           l_ci_cal_type    := LTRIM(RTRIM(SUBSTR(p_award_year,1,10))) ;
           l_ci_sequence_number  := TO_NUMBER(SUBSTR(p_award_year,11)) ;

                           OPEN        c_alternate_code(l_ci_cal_type,l_ci_sequence_number);
                           FETCH      c_alternate_code INTO  l_alternate_code;
                           CLOSE      c_alternate_code;

                           log_messages('Award Year     : ',l_alternate_code);
                           log_messages('Sum Type       : ',p_sum_type);

                           OPEN        c_fseog_sum(l_ci_cal_type,l_ci_sequence_number);
                           FETCH      c_fseog_sum INTO  l_tot_fseog;
                           CLOSE      c_fseog_sum;

                           OPEN        c_match_sum(l_ci_cal_type,l_ci_sequence_number);
                           FETCH      c_match_sum INTO  l_tot_match;
                           CLOSE      c_match_sum;

                           l_total:= NVL(l_tot_fseog,0) + NVL(l_tot_match,0);

                           IF l_total <> 0 THEN
                              l_fseog_pcntg := (NVL(l_tot_fseog,0)/l_total) * 100;
                              l_match_pcntg := (NVL(l_tot_match,0)/l_total) * 100;
                           END IF;

                          FND_MESSAGE.SET_NAME('IGF','IGF_AW_FSEOG_PERCENTAGE');
                          FND_MESSAGE.SET_TOKEN('FSEOG_PCNTG',l_fseog_pcntg);
                          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

                          FND_MESSAGE.SET_NAME('IGF','IGF_AW_MATCH_PERCENTAGE');
                          FND_MESSAGE.SET_TOKEN('MATCH_PCNTG',l_match_pcntg);
                          FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);

        EXCEPTION
                  WHEN OTHERS THEN
                  retcode := 2;
                  errbuf  := FND_MESSAGE.GET_STRING('IGS','IGS_GE_UNHANDLED_EXCEPTION');
                   IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL ;
  END aggregate_match;
END igf_aw_fisap;

/
