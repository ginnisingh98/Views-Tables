--------------------------------------------------------
--  DDL for Package Body JAI_EXCISE_SCRIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JAI_EXCISE_SCRIPTS_PKG" AS
/* $Header: jaiexscr.plb 120.2.12000000.2 2007/10/25 02:31:04 rallamse noship $ */

  gd_date date ;
  gn_exists number ;
  gn_action NUMBER;

  -----------------------------------------GET_PREV_CESS_RG_BAL--------------------------------

  PROCEDURE get_prev_cess_rg_bal( p_organization_id IN NUMBER,
                                  p_location_id     IN NUMBER,
                                  p_register_type   IN VARCHAR2,
                                  p_tax_type        IN VARCHAR2,
                                  p_fin_year        IN OUT NOCOPY NUMBER,
                                  p_slno            IN OUT NOCOPY NUMBER,
                                  p_bal             OUT NOCOPY NUMBER)
  IS

  CURSOR get_rg23_prev_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_23AC_II_TRXS jrg
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = p_register_type
     AND fin_year        = p_fin_year
     AND slno            < p_slno
     AND EXISTS ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type        = 1
                     AND tax_type           = p_tax_type
                     AND source_register_id = jrg.register_id );

  CURSOR get_rg23_prev_fin_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_23AC_II_TRXS jrg
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = p_register_type
     AND fin_year        = p_fin_year - 1
     AND exists ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type        = 1
                     AND tax_type           = p_tax_type
                     AND source_register_id = jrg.register_id );

  CURSOR get_rg23_balance( cp_fin_year NUMBER,cp_slno NUMBER ) IS
  SELECT closing_balance
    FROM JAI_CMN_RG_OTHERS
   WHERE source_type        = 1
     AND tax_type           = p_tax_type
     AND source_register_id = ( SELECT register_id
                                  FROM JAI_CMN_RG_23AC_II_TRXS
                                 WHERE organization_id = p_organization_id
                                   AND location_id     = p_location_id
                                   AND register_type   = p_register_type
                                   AND fin_year        = p_fin_year
                                   AND slno            = cp_slno) ;

  CURSOR get_pla_prev_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_PLA_TRXS jpl
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND fin_year        = p_fin_year
     AND slno            < p_slno
     AND EXISTS ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type        = 2
                     AND tax_type           = p_tax_type
                     AND source_register_id = jpl.register_id );


  CURSOR get_pla_prev_fin_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_PLA_TRXS jpl
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND fin_year        = p_fin_year - 1
     AND EXISTS ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type        = 2
                     AND tax_type           = p_tax_type
                     AND source_register_id = jpl.register_id );

  CURSOR get_pla_balance( cp_fin_year NUMBER,cp_slno NUMBER ) IS
  SELECT closing_balance
   FROM JAI_CMN_RG_OTHERS
   WHERE source_type        = 2
     AND tax_type           = p_tax_type
     AND source_register_id = ( SELECT register_id
                                  FROM JAI_CMN_RG_PLA_TRXS
                                 WHERE organization_id = p_organization_id
                                   AND location_id     = p_location_id
                                   AND fin_year        = p_fin_year
                                   AND slno            = cp_slno );

  ln_slno     NUMBER;

  BEGIN

    IF p_register_type IN ( 'A','C') THEN

      OPEN get_rg23_prev_slno;
      FETCH get_rg23_prev_slno INTO ln_slno;
      CLOSE get_rg23_prev_slno;

      IF ln_slno IS NULL THEN

        OPEN get_rg23_prev_fin_slno;
        FETCH get_rg23_prev_fin_slno INTO ln_slno;
        CLOSE get_rg23_prev_fin_slno;

        p_fin_year := p_fin_year - 1;

      END IF;

      OPEN get_rg23_balance(p_fin_year,ln_slno);
      FETCH get_rg23_balance INTO p_bal;
      CLOSE get_rg23_balance;

    ELSIF p_register_type = 'PLA' THEN

      OPEN get_pla_prev_slno;
      FETCH get_pla_prev_slno INTO ln_slno;
      CLOSE get_pla_prev_slno;

      IF ln_slno IS NULL THEN

        OPEN get_pla_prev_fin_slno;
        FETCH get_pla_prev_fin_slno INTO ln_slno;
        CLOSE get_pla_prev_fin_slno;

        p_fin_year := p_fin_year - 1;

      END IF;

      OPEN  get_pla_balance(p_fin_year,ln_slno);
      FETCH get_pla_balance INTO p_bal;
      CLOSE get_pla_balance;

    END IF;

    p_slno := ln_slno;

  END get_prev_cess_rg_bal;

  -----------------------------------------GET_PREV_CESS_RG_BAL--------------------------------

  -----------------------------------------GET_PREV_RG_BAL--------------------------------

  PROCEDURE get_prev_rg_bal( p_organization_id IN NUMBER,
                                               p_location_id     IN NUMBER,
                                               p_register_type   IN VARCHAR2,
                                               p_fin_year        IN OUT NOCOPY NUMBER,
                                               p_slno            IN OUT NOCOPY NUMBER,
                                               p_bal             OUT NOCOPY NUMBER)
  IS

  CURSOR get_rg23_prev_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_23AC_II_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = p_register_type
     AND fin_year        = p_fin_year
     AND slno            < p_slno ;

  CURSOR get_rg23_prev_fin_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_23AC_II_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = p_register_type
     AND fin_year        = p_fin_year - 1;

  CURSOR get_rg23_balance( cp_fin_year NUMBER,cp_slno NUMBER ) IS
  SELECT closing_balance
    FROM JAI_CMN_RG_23AC_II_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = p_register_type
     AND fin_year        = p_fin_year
     AND slno            = cp_slno ;


  CURSOR get_pla_prev_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_PLA_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND fin_year        = p_fin_year
     AND slno            < p_slno ;

  CURSOR get_pla_prev_fin_slno IS
  SELECT max(slno)
    FROM JAI_CMN_RG_PLA_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND fin_year        = p_fin_year - 1;

  CURSOR get_pla_balance( cp_fin_year NUMBER,cp_slno NUMBER ) IS
  SELECT closing_balance
    FROM JAI_CMN_RG_PLA_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND fin_year        = p_fin_year
     AND slno            = cp_slno ;

  ln_slno     NUMBER;

  BEGIN
    p_bal := 0 ;

    IF p_register_type IN ( 'A','C') THEN

      OPEN get_rg23_prev_slno;
      FETCH get_rg23_prev_slno INTO ln_slno;
      CLOSE get_rg23_prev_slno;

      IF ln_slno IS NULL THEN

        OPEN get_rg23_prev_fin_slno;
        FETCH get_rg23_prev_fin_slno INTO ln_slno;
        CLOSE get_rg23_prev_fin_slno;

        p_fin_year := p_fin_year - 1;

      END IF;

      OPEN get_rg23_balance(p_fin_year,ln_slno);
      FETCH get_rg23_balance INTO p_bal;
      CLOSE get_rg23_balance;

    ELSIF p_register_type = 'PLA' THEN

      OPEN get_pla_prev_slno;
      FETCH get_pla_prev_slno INTO ln_slno;
      CLOSE get_pla_prev_slno;

      IF ln_slno IS NULL THEN

        OPEN get_pla_prev_fin_slno;
        FETCH get_pla_prev_fin_slno INTO ln_slno;
        CLOSE get_pla_prev_fin_slno;

        p_fin_year := p_fin_year - 1;

      END IF;

      OPEN  get_pla_balance(p_fin_year,ln_slno);
      FETCH get_pla_balance INTO p_bal;
      CLOSE get_pla_balance;

    END IF;

    p_slno := ln_slno;

  END get_prev_rg_bal;

  -----------------------------------------GET_PREV_RG_BAL--------------------------------
-----------------------------------------REMOVE_DUP_SLNO--------------------------------

PROCEDURE remove_dup_slno( p_organization_id NUMBER   ,
                           p_location_id     NUMBER   ,
                           p_fin_year        NUMBER   ,
                           p_register_type   VARCHAR2 ,
                           p_slno            NUMBER   ,
                           p_dup_cnt         NUMBER )
IS
ln_cnt  NUMBER;

BEGIN

  IF p_register_type IN ('A','C') THEN

    UPDATE JAI_CMN_RG_23AC_II_TRXS
       SET slno            = slno + p_dup_cnt - 1
     WHERE organization_id = p_organization_id
       AND location_id     = p_location_id
       AND register_type   = p_register_type
       AND fin_year        = p_fin_year
       AND slno            > p_slno;

    UPDATE JAI_CMN_RG_SLNOS
       SET slno              = slno + p_dup_cnt - 1
     WHERE organization_id   = p_organization_id
       AND location_id       = p_location_id
       AND register_type     = p_register_type
       AND current_fin_year  = p_fin_year;

    ln_cnt := 0;
    FOR dup_rec in ( SELECT *
                       FROM JAI_CMN_RG_23AC_II_TRXS
                      WHERE organization_id = p_organization_id
                        AND location_id     = p_location_id
                        AND register_type   = p_register_type
                        AND fin_year        = p_fin_year
                        AND slno            = p_slno
                      ORDER BY register_id ) LOOP


       UPDATE JAI_CMN_RG_23AC_II_TRXS
          SET slno            = slno + ln_cnt
        WHERE register_id     = dup_rec.register_id;

       ln_cnt := ln_cnt + 1;

    END LOOP;

  ELSIF p_register_type = 'PLA' THEN

    UPDATE JAI_CMN_RG_PLA_TRXS
       SET slno            = slno + p_dup_cnt - 1
     WHERE organization_id = p_organization_id
       AND location_id     = p_location_id
       AND fin_year        = p_fin_year
       AND slno            > p_slno;

    UPDATE JAI_CMN_RG_SLNOS
       SET slno              = slno + p_dup_cnt - 1
     WHERE organization_id   = p_organization_id
       AND location_id       = p_location_id
       AND register_type     = p_register_type
       AND current_fin_year  = p_fin_year;


    ln_cnt := 0;
    FOR dup_rec in ( SELECT *
                       FROM JAI_CMN_RG_PLA_TRXS
                      WHERE organization_id = p_organization_id
                        AND location_id     = p_location_id
                        AND fin_year        = p_fin_year
                        AND slno            = p_slno
                      ORDER BY register_id ) LOOP

       UPDATE JAI_CMN_RG_PLA_TRXS
          SET slno            = slno + ln_cnt
        WHERE register_id     = dup_rec.register_id;

       ln_cnt := ln_cnt + 1;

    END LOOP;

  END IF;

END remove_dup_slno;

-----------------------------------------REMOVE_DUP_SLNO--------------------------------

-----------------------------------------UPD_PERIOD_BALANCES--------------------------------

  PROCEDURE upd_period_balances( p_organization_id NUMBER,
                                 p_location_id     NUMBER,
                                 p_register_type   VARCHAR2,
                                 p_start_date      DATE,
                                 p_err_msg         OUT NOCOPY VARCHAR2,
                                 p_ret_code        OUT NOCOPY NUMBER)
  IS
  BEGIN

    DELETE JAI_CMN_RG_PERIOD_BALS
     WHERE organization_id = p_organization_id
       AND location_id     = p_location_id
       AND register_type   = decode(p_register_type,'A','RG23A','C','RG23C')
       AND start_date      >= p_start_date;

    UPDATE JAI_CMN_RG_23AC_II_TRXS
       SET period_balance_id = NULL
     WHERE organization_id        = p_organization_id
       AND location_id            = p_location_id
       AND register_type          = p_register_type
       AND trunc(creation_date)  >= p_start_date;

       jai_cmn_rg_period_bals_pkg.consolidate_balances( p_err_msg,
                                                         p_ret_code ,
                                                         NULL,
                                                         p_register_type,
                                                         trunc(last_day(add_months(sysdate,-1))));

END upd_period_balances;

-----------------------------------------UPD_PERIOD_BALANCES--------------------------------


-----------------------------------------VALIDATE_PERIOD_BALANCES--------------------------------
  PROCEDURE validate_period_balances( p_organization_id NUMBER,
                                      p_location_id     NUMBER,
                                      p_register_type   VARCHAR2,
                                      p_date            DATE)
  IS
  CURSOR cur_get_tot_amt( cp_start_date DATE,cp_end_date DATE ) IS
  SELECT sum(nvl(cr_basic_ed,0)+ nvl(cr_additional_ed,0) + nvl(cr_other_ed,0)
           - nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0)) total_modvat_amount
    FROM JAI_CMN_RG_23AC_II_TRXS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = p_register_type
     AND trunc(creation_date) between cp_start_date and cp_end_date
     AND inventory_item_id <> 0;

  CURSOR cur_get_period_balance( cp_start_date DATE,cp_end_date DATE ) IS
  SELECT closing_balance - opening_balance
    FROM JAI_CMN_RG_PERIOD_BALS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = decode(p_register_type,'A','RG23A','C','RG23C')
     AND start_date      = cp_start_date
     AND end_date        = cp_end_date;


  CURSOR c_total_cess_amount(cp_start_date in date, cp_end_date in date, cp_tax_type in varchar2) IS
  SELECT sum(nvl(b.credit,0) - nvl(b.debit,0)) total_cess
    FROM JAI_CMN_RG_23AC_II_TRXS  a, JAI_CMN_RG_OTHERS b
   WHERE a.organization_id   = p_organization_id
     AND a.location_id       = p_location_id
     AND a.register_type     = p_register_type
     AND trunc(a.creation_date) between cp_start_date and cp_end_date
     AND a.inventory_item_id <> 0
     AND b.source_register_id = a.register_id
     AND b.source_type        = 1
     AND b.tax_type           = cp_tax_type;

  CURSOR cur_get_cess_period_bal(cp_start_date in date, cp_end_date in date) IS
  SELECT exc_edu_cess_cl_bal,
         cvd_edu_cess_cl_bal,
         sh_exc_edu_cess_cl_bal,
         sh_cvd_edu_cess_cl_bal
    FROM JAI_CMN_RG_PERIOD_BALS
   WHERE organization_id = p_organization_id
     AND location_id     = p_location_id
     AND register_type   = decode(p_register_type,'A','RG23A','C','RG23C')
     AND start_date      = cp_start_date
     AND end_date        = cp_end_date;

  ln_prev_cess_cl_bal       NUMBER;
  ln_cess_cl_bal            NUMBER;
  ln_cess_amount            NUMBER;
  r_prev_cess_period_bal    cur_get_cess_period_bal%ROWTYPE;
  r_cess_period_bal         cur_get_cess_period_bal%ROWTYPE;
  lv_tax_type               VARCHAR2(30);

  ld_start_date DATE;
  ld_end_date   DATE;
  ln_tot_amt    NUMBER;
  ln_period_bal NUMBER;
  lv_err_msg    VARCHAR2(4000);
  ln_ret_code   NUMBER;



  BEGIN
    ld_start_date := to_date(01||'-'||to_char(p_date,'MON')||'-'||to_char(p_date,'YYYY'),'DD-MM-YYYY');
    ld_end_date   := last_day(p_date);

    LOOP

      ln_tot_amt    := NULL;
      ln_period_bal := NULL;

      OPEN  cur_get_tot_amt(ld_start_date,ld_end_date);
      FETCH cur_get_tot_amt INTO ln_tot_amt;
      CLOSE cur_get_tot_amt;

      OPEN cur_get_period_balance(ld_start_date,ld_end_date);
      FETCH cur_get_period_balance INTO ln_period_bal;
      IF cur_get_period_balance%NOTFOUND THEN
        exit;
      END IF;
      CLOSE cur_get_period_balance;

      IF ln_tot_amt <> ln_period_bal THEN
        IF gn_action = 3 THEN
          upd_period_balances( p_organization_id => p_organization_id,
                   p_location_id     => p_location_id,
                   p_register_type   => p_register_type,
                   p_start_date      => ld_start_date,
                   p_err_msg         => lv_err_msg,
                   p_ret_code        => ln_ret_code);
        END IF;

         capture_error(  p_organization_id    =>   p_organization_id                            ,
                         p_location_id        =>   p_location_id                                ,
                         p_register_type      =>   p_register_type                              ,
                         p_fin_year           =>   null                                         ,
                         p_opening_balance    =>   null                                         ,
                         p_error_codes        =>   'E01'                                        ,
                         p_slno               =>   null                                         ,
                         p_register_id        =>   null                                         ,
                         p_rowcount           =>   null                                         ,
                         p_tax_type           =>   null                                         ,
                         p_date               =>   null                                         ,
                         p_month              =>   to_char(ld_start_date,'MONTH')               ,
                         p_year               =>   to_number(to_char(ld_start_date,'YYYY'))
                        ) ;
         IF gn_action = 3 THEN
           return;          END IF;

      END IF;


      OPEN  cur_get_cess_period_bal( add_months(ld_start_date,-1),add_months(ld_end_date,-1) );
      FETCH cur_get_cess_period_bal INTO r_prev_cess_period_bal;
      CLOSE cur_get_cess_period_bal;

      OPEN  cur_get_cess_period_bal( ld_start_date,ld_end_date );
      FETCH cur_get_cess_period_bal INTO r_cess_period_bal;
      CLOSE cur_get_cess_period_bal;

      FOR tax in 1..4 LOOP

        ln_prev_cess_cl_bal  := 0;
        ln_cess_cl_bal       := 0;
        ln_cess_amount       := 0;

        IF tax = 1 THEN

			    lv_tax_type         := jai_constants.tax_type_exc_edu_cess   ;
			    ln_prev_cess_cl_bal := nvl(r_prev_cess_period_bal.exc_edu_cess_cl_bal,0);
			    ln_cess_cl_bal      := nvl(r_cess_period_bal.exc_edu_cess_cl_bal,0);

			  ELSIF tax = 2 THEN

			    lv_tax_type         := jai_constants.tax_type_cvd_edu_cess   ;
			    ln_prev_cess_cl_bal := nvl(r_prev_cess_period_bal.cvd_edu_cess_cl_bal,0);
			    ln_cess_cl_bal      := nvl(r_cess_period_bal.cvd_edu_cess_cl_bal,0);

			  ELSIF tax = 3 THEN

			    lv_tax_type         := jai_constants.tax_type_sh_exc_edu_cess;
			    ln_prev_cess_cl_bal := nvl(r_prev_cess_period_bal.sh_exc_edu_cess_cl_bal,0);
			    ln_cess_cl_bal      := nvl(r_cess_period_bal.sh_exc_edu_cess_cl_bal,0);

			  ELSIF tax = 4 THEN

			    lv_tax_type         := jai_constants.tax_type_sh_cvd_edu_cess;
			    ln_prev_cess_cl_bal := nvl(r_prev_cess_period_bal.sh_cvd_edu_cess_cl_bal,0);
			    ln_cess_cl_bal      := nvl(r_cess_period_bal.sh_cvd_edu_cess_cl_bal,0);

        END IF;

        OPEN  c_total_cess_amount( ld_start_date,ld_end_date,lv_tax_type );
        FETCH c_total_cess_amount INTO ln_cess_amount;
        CLOSE c_total_cess_amount;


        IF nvl(ln_cess_amount,0) + nvl(ln_prev_cess_cl_bal,0) <> nvl(ln_cess_cl_bal,0) THEN

          IF gn_action = 3 THEN
						upd_period_balances( p_organization_id => p_organization_id,
																 p_location_id     => p_location_id,
																 p_register_type   => p_register_type,
																 p_start_date      => ld_start_date,
																 p_err_msg         => lv_err_msg,
																 p_ret_code        => ln_ret_code);
					END IF;

					capture_error( p_organization_id    =>   p_organization_id                            ,
												 p_location_id        =>   p_location_id                                ,
												 p_register_type      =>   p_register_type                              ,
												 p_fin_year           =>   null                                         ,
												 p_opening_balance    =>   null                                         ,
												 p_error_codes        =>   'E01'                                        ,
												 p_slno               =>   null                                         ,
												 p_register_id        =>   null                                         ,
												 p_rowcount           =>   null                                         ,
												 p_tax_type           =>   lv_tax_type                                  ,
												 p_date               =>   null                                         ,
												 p_month              =>   to_char(ld_start_date,'MONTH')               ,
												 p_year               =>   to_number(to_char(ld_start_date,'YYYY'))
													) ;
					 IF gn_action = 3 THEN
						 return;
						 END IF;

        END IF;

      END LOOP;

      ld_start_date := to_date(01||'-'||to_char(add_months(ld_start_date,1),'MON')||'-'||to_char(add_months(ld_start_date,1),'YYYY'),'DD-MM-YYYY');
      ld_end_date   := last_day ( ld_start_date );
      exit when ld_start_date > trunc(sysdate);

    END LOOP;

  END validate_period_balances;
  -----------------------------------------VALIDATE_PERIOD_BALANCES--------------------------------
  -----------------------------------------CORR_OTH_BALANCES--------------------------------

  PROCEDURE corr_oth_balances
                                                     (
                                                        p_organization_id  NUMBER,
                                                        p_location_id      NUMBER,
                                                        p_fin_year         NUMBER,
                                                        p_register_type    VARCHAR2,
                                                        p_slno             NUMBER,
                                                        p_tax_type         VARCHAR2,
                                                        p_last_updated_by  NUMBER
                                                     )
  IS
  CURSOR cur_rg23_next_records IS
  SELECT jrg.opening_balance ,
         jrg.closing_balance ,
         nvl(jrg.credit,0) - nvl(jrg.debit,0) transaction_amount,
         jrg.last_updated_by,
         jrg.last_update_date,
         jrg.rg_other_id,
         rg23.slno,
         rg23.organization_id,
         rg23.location_id
    FROM JAI_CMN_RG_OTHERS jrg,
         JAI_CMN_RG_23AC_II_TRXS rg23
   WHERE organization_id    = p_organization_id
     AND location_id        = p_location_id
     AND ((fin_year           = p_fin_year
           AND slno               >= p_slno)
          OR fin_year > p_fin_year )
     AND register_type      = p_register_type
     AND source_type        = 1
     AND source_register    = decode(p_register_type,'A','RG23A_P2','C','RG23C_P2')
     AND tax_type           = p_tax_type
     AND source_register_id = rg23.register_id
   ORDER BY fin_year,slno
   FOR UPDATE OF jrg.opening_balance,
                 jrg.closing_balance,
                 jrg.last_updated_by,
                 jrg.last_update_date;

  CURSOR cur_pla_next_records IS
  SELECT jrg.opening_balance ,
         jrg.closing_balance ,
         nvl(jrg.credit,0) - nvl(jrg.debit,0) transaction_amount,
         jrg.last_updated_by,
         jrg.last_update_date,
         jrg.rg_other_id,
         jpl.slno,
         jpl.organization_id,
         jpl.location_id
    FROM JAI_CMN_RG_OTHERS jrg,
         JAI_CMN_RG_PLA_TRXS jpl
   WHERE source_type        = 2
     and tax_type           = p_tax_type
     and source_register_id = jpl.register_id
     and organization_id    = p_organization_id
     AND location_id        = p_location_id
     AND ((fin_year           = p_fin_year
           AND slno               >= p_slno)
          OR fin_year > p_fin_year )
   ORDER BY fin_year,slno
   FOR UPDATE OF jrg.opening_balance,
                 jrg.closing_balance,
                 jrg.last_updated_by,
                 jrg.last_update_date;

  ln_prev_balance    NUMBER;
  ln_prev_slno       NUMBER;
  ln_fin_year        NUMBER;
  ln_opening_balance NUMBER;
  ln_closing_balance NUMBER;

  BEGIN


    ln_fin_year  := p_fin_year;
    ln_prev_slno := p_slno;

    get_prev_cess_rg_bal( p_organization_id => p_organization_id,
                          p_location_id     => p_location_id,
                          p_register_type   => p_register_type,
                          p_tax_type        => p_tax_type,
                          p_fin_year        => ln_fin_year,
                          p_slno            => ln_prev_slno,
                          p_bal             => ln_prev_balance);

    IF ln_prev_slno IS NULL THEN

      FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error : No previous record exists. Need to fix Manually');
      RETURN;

    END IF;

    IF p_register_type in ('A','C') THEN

      FOR records in cur_rg23_next_records LOOP

        ln_opening_balance := ln_prev_balance;
        ln_closing_balance := ln_opening_balance + records.transaction_amount;

        UPDATE JAI_CMN_RG_OTHERS
           SET opening_balance  = ln_opening_balance,
               closing_balance  = ln_closing_balance,
               last_updated_by  = p_last_updated_by,
               last_update_date = sysdate
         WHERE CURRENT OF cur_rg23_next_records;

        ln_prev_balance := ln_closing_balance;

      END LOOP;

      UPDATE JAI_CMN_RG_OTH_BALANCES
         SET balance          = ln_prev_balance,
             last_updated_by  = p_last_updated_by,
             last_update_date = sysdate
       WHERE org_unit_id  = ( SELECT org_unit_id
                               FROM JAI_CMN_INVENTORY_ORGS
                              WHERE organization_id = p_organization_id
                                AND location_id     = p_location_id )
        AND register_type = decode(p_register_type,'A','RG23A','C','RG23C')
        AND tax_type      = p_tax_type;

    ELSIF p_register_type = 'PLA' THEN

      FOR records in cur_pla_next_records LOOP

        ln_opening_balance := ln_prev_balance;
        ln_closing_balance := ln_opening_balance + records.transaction_amount;

        UPDATE JAI_CMN_RG_OTHERS
           SET opening_balance = ln_opening_balance,
               closing_balance = ln_closing_balance,
               last_updated_by  = p_last_updated_by,
               last_update_date = sysdate
         WHERE CURRENT OF cur_pla_next_records;

        ln_prev_balance := ln_closing_balance;

      END LOOP;

      UPDATE JAI_CMN_RG_OTH_BALANCES
         SET balance          = ln_prev_balance,
             last_updated_by  = p_last_updated_by,
             last_update_date = sysdate
       WHERE org_unit_id = ( SELECT org_unit_id
                               FROM JAI_CMN_INVENTORY_ORGS
                              WHERE organization_id = p_organization_id
                                AND location_id     = p_location_id )
        AND register_type = 'PLA'
        AND tax_type      = p_tax_type;

    END IF;

  END corr_oth_balances;

  -----------------------------------------CORR_OTH_BALANCES--------------------------------

  -----------------------------------------CORR_FINAL_BAL--------------------------------

  PROCEDURE corr_final_bal( p_organization_id NUMBER,
                            p_location_id     NUMBER,
                            p_register_type   VARCHAR2,
                            p_tax_type        VARCHAR2,
                            p_closing_balance NUMBER)
  IS
  BEGIN

    IF p_tax_type IS NULL THEN

      IF p_register_type = 'A' THEN

        UPDATE JAI_CMN_RG_BALANCES
           SET rg23a_balance   = p_closing_balance
         WHERE organization_id = p_organization_id
           AND location_id     = p_location_id
           AND rg23a_balance   <> p_closing_balance;


      ELSIF p_register_type = 'C' THEN

        UPDATE JAI_CMN_RG_BALANCES
           SET rg23c_balance   = p_closing_balance
         WHERE organization_id = p_organization_id
           AND location_id     = p_location_id
           AND rg23a_balance   <> p_closing_balance;

      ELSIF p_register_type = 'PLA' THEN

        UPDATE JAI_CMN_RG_BALANCES
           SET pla_balance   = p_closing_balance
         WHERE organization_id = p_organization_id
           AND location_id     = p_location_id
           AND rg23a_balance   <> p_closing_balance;

       END IF;


        UPDATE JAI_CMN_RG_SLNOS
           SET balance = p_closing_balance
         WHERE organization_id  = p_organization_id
           AND location_id      = p_location_id
           AND register_type    = p_register_type
           AND balance          <> p_closing_balance ;

    ELSE

      UPDATE JAI_CMN_RG_OTH_BALANCES
         SET balance = p_closing_balance
       WHERE org_unit_id  = ( SELECT org_unit_id
                                FROM JAI_CMN_INVENTORY_ORGS
                               WHERE organization_id  = p_organization_id
                                 AND location_id      = p_location_id )
         AND register_type = decode(p_register_type,'A','RG23A','C','RG23C',p_register_type)
         AND tax_type      = p_tax_type
         AND balance       <> p_closing_balance;

     END IF;

END corr_final_bal;
-----------------------------------------CORR_FINAL_BAL--------------------------------

-----------------------------------------CORR_FINAL_SLNO--------------------------------
PROCEDURE corr_final_slno( p_organization_id NUMBER,
                           p_location_id     NUMBER,
                           p_register_type   VARCHAR2,
                           p_slno            NUMBER)
IS
BEGIN

  UPDATE JAI_CMN_RG_SLNOS
     SET slno             = p_slno
   WHERE organization_id  = p_organization_id
     AND location_id      = p_location_id
     AND register_type    = p_register_type
     AND slno             <> p_slno ;

END corr_final_slno;
-----------------------------------------CORR_FINAL_SLNO--------------------------------


-----------------------------------------VALIDATE_RG_OTHERS--------------------------------
  PROCEDURE validate_rg_others ( p_organization_id NUMBER,
																 p_location_id     NUMBER,
																 p_register_type   VARCHAR2,
																 p_date            DATE)
  IS
  CURSOR cur_rg23_next_records( cp_fin_year NUMBER,cp_slno NUMBER,cp_tax_type VARCHAR2) IS
  SELECT jrg.opening_balance ,
         jrg.closing_balance ,
         nvl(jrg.credit,0) - nvl(jrg.debit,0) transaction_amount,
         jrg.last_updated_by,
         jrg.last_update_date,
         jrg.rg_other_id,
         rg23.slno,
         rg23.organization_id,
         rg23.location_id
    FROM JAI_CMN_RG_OTHERS jrg,
         JAI_CMN_RG_23AC_II_TRXS rg23
   WHERE organization_id    = p_organization_id
     AND location_id        = p_location_id
     AND fin_year           = cp_fin_year
     AND register_type      = p_register_type
     AND slno               > nvl(cp_slno,1)
     AND source_type        = 1
     AND source_register    = decode(p_register_type,'A','RG23A_P2','C','RG23C_P2')
     AND tax_type           = cp_tax_type
     AND source_register_id = rg23.register_id
   ORDER BY slno;

  CURSOR cur_pla_next_records(cp_fin_year NUMBER, cp_slno NUMBER,cp_tax_type VARCHAR2) IS
  SELECT jrg.opening_balance ,
         jrg.closing_balance ,
         nvl(jrg.credit,0) - nvl(jrg.debit,0) transaction_amount,
         jrg.last_updated_by,
         jrg.last_update_date,
         jrg.rg_other_id,
         jpl.slno,
         jpl.organization_id,
         jpl.location_id
    FROM JAI_CMN_RG_OTHERS jrg,
         JAI_CMN_RG_PLA_TRXS jpl
   WHERE source_type        = 2
     and tax_type           = cp_tax_type
     and source_register_id = jpl.register_id
     and organization_id    = p_organization_id
     AND location_id        = p_location_id
     AND fin_year           = cp_fin_year
     AND slno               > nvl(cp_slno,1)
   ORDER BY slno;

  CURSOR cur_get_curr_fin_year IS
  SELECT fin_year
    FROM JAI_CMN_FIN_YEARS
   WHERE organization_id = p_organization_id
     AND fin_active_flag = 'Y';

  CURSOR cur_get_fin_year IS
  SELECT fin_year
    FROM JAI_CMN_FIN_YEARS
   WHERE organization_id     = p_organization_id
     AND p_date between fin_year_start_date and fin_year_end_date;

  CURSOR cur_get_rg_slno(cp_fin_year NUMBER,cp_tax_type VARCHAR2,cp_date DATE) IS
  SELECT max(slno),min(slno)
    FROM JAI_CMN_RG_23AC_II_TRXS jrg
   WHERE organization_id       = p_organization_id
     AND location_id           = p_location_id
     AND fin_year              = cp_fin_year
     AND register_type         = p_register_type
     AND trunc(creation_date)  < cp_date
     AND EXISTS ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type = 1
                     AND source_register_id = jrg.register_id
                     AND tax_type           = cp_tax_type );


  CURSOR cur_rg_tax_exists(cp_fin_year NUMBER,cp_tax_type VARCHAR2,cp_date DATE) IS
  SELECT 1
    FROM JAI_CMN_RG_23AC_II_TRXS jrg
   WHERE organization_id       = p_organization_id
     AND location_id           = p_location_id
     AND fin_year              = cp_fin_year
     AND register_type         = p_register_type
     AND trunc(creation_date)  < cp_date
     AND EXISTS ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type = 1
                     AND source_register_id = jrg.register_id
                     AND tax_type           = cp_tax_type );
ln_rg_tax_exists NUMBER;


  CURSOR cur_get_pla_slno(cp_fin_year NUMBER,cp_tax_type VARCHAR2,cp_date DATE) IS
  SELECT max(slno),min(slno)
    FROM JAI_CMN_RG_PLA_TRXS jpl
   WHERE organization_id       = p_organization_id
     AND location_id           = p_location_id
     AND fin_year              = cp_fin_year
     AND trunc(creation_date)  < cp_date
     AND EXISTS ( SELECT 1
                    FROM JAI_CMN_RG_OTHERS
                   WHERE source_type        = 2
                     AND source_register_id = jpl.register_id
                     AND tax_type           = cp_tax_type );

CURSOR cur_pla_tax_exists(cp_fin_year NUMBER,cp_tax_type VARCHAR2,cp_date DATE) IS
SELECT 1
  FROM JAI_CMN_RG_PLA_TRXS jpl
 WHERE organization_id       = p_organization_id
   AND location_id           = p_location_id
   AND fin_year              = cp_fin_year
   AND trunc(creation_date)  < cp_date
   AND EXISTS ( SELECT 1
                  FROM JAI_CMN_RG_OTHERS
                 WHERE source_type        = 2
                   AND source_register_id = jpl.register_id
                   AND tax_type           = cp_tax_type );
ln_pla_tax_exists NUMBER;


  CURSOR get_rg_closing_bal(cp_fin_year NUMBER,cp_slno NUMBER,cp_tax_type VARCHAR2) IS
  SELECT closing_balance
    FROM JAI_CMN_RG_OTHERS
   WHERE source_type = 1
     AND tax_type    = cp_tax_type
     AND source_register_id in ( SELECT register_id
                                   FROM JAI_CMN_RG_23AC_II_TRXS
                                  WHERE organization_id = p_organization_id
                                    AND location_id     = p_location_id
                                    AND register_type   = p_register_type
                                    AND fin_year        = cp_fin_year
                                    AND slno            = nvl(cp_slno,1) );

  CURSOR get_pla_closing_bal(cp_fin_year NUMBER,cp_slno NUMBER,cp_tax_type VARCHAR2) IS
  SELECT closing_balance
    FROM JAI_CMN_RG_OTHERS
   WHERE source_type = 2
     AND tax_type    = cp_tax_type
     AND source_register_id in ( SELECT register_id
                                   FROM JAI_CMN_RG_PLA_TRXS
                                  WHERE organization_id = p_organization_id
                                    AND location_id     = p_location_id
                                    AND fin_year        = cp_fin_year
                                    AND slno            = nvl(cp_slno,1) );

  CURSOR cur_get_final_bal(cp_tax_type VARCHAR2) IS
  SELECT balance
    FROM JAI_CMN_RG_OTH_BALANCES
   WHERE org_unit_id   = ( SELECT org_unit_id
                           FROM JAI_CMN_INVENTORY_ORGS
                          WHERE organization_id = p_organization_id
                            AND location_id     = p_location_id )
     AND register_type = decode(p_register_type,'A','RG23A','C','RG23C',p_register_type)
     AND tax_type      = cp_tax_type;

   ln_rg_prev_slno    NUMBER;
   ln_pla_prev_slno   NUMBER;
   ln_rg_first_slno   NUMBER;
   ln_pla_first_slno  NUMBER;
   ln_prev_balance    NUMBER;
   ln_final_bal       NUMBER;
   ln_fin_year        NUMBER;
   ln_curr_fin_year   NUMBER;
   lv_tax_type        VARCHAR2(50);
   ld_date            DATE;
   ln_final_slno      NUMBER;

  BEGIN

    OPEN  cur_get_curr_fin_year;
		FETCH cur_get_curr_fin_year INTO ln_curr_fin_year;
		CLOSE cur_get_curr_fin_year;

    FOR tax in 1..4 LOOP

			OPEN  cur_get_fin_year;
			FETCH cur_get_fin_year INTO ln_fin_year;
			CLOSE cur_get_fin_year;

      IF tax = 1 THEN

        lv_tax_type := jai_constants.tax_type_exc_edu_cess   ;

      ELSIF tax = 2 THEN

        lv_tax_type := jai_constants.tax_type_cvd_edu_cess   ;

      ELSIF tax = 3 THEN

        lv_tax_type := jai_constants.tax_type_sh_exc_edu_cess;

      ELSIF tax = 4 THEN

        lv_tax_type := jai_constants.tax_type_sh_cvd_edu_cess;

      END IF;

      ld_date          := p_date;

      ln_prev_balance  := NULL;
      ln_rg_prev_slno  := NULL;
      ln_pla_prev_slno := NULL;


      OPEN cur_get_rg_slno(ln_fin_year,lv_tax_type,ld_date);
      FETCH cur_get_rg_slno INTO ln_rg_prev_slno,ln_rg_first_slno;
      CLOSE cur_get_rg_slno;

      OPEN cur_get_pla_slno(ln_fin_year,lv_tax_type,ld_date);
      FETCH cur_get_pla_slno INTO ln_pla_prev_slno,ln_pla_first_slno;
      CLOSE cur_get_pla_slno;

      LOOP

        IF p_register_type in ( 'A','C') and ln_rg_prev_slno IS NOT NULL THEN

          OPEN  get_rg_closing_bal(ln_fin_year,ln_rg_prev_slno,lv_tax_type);
          FETCH get_rg_closing_bal INTO ln_prev_balance;
          CLOSE get_rg_closing_bal;

          FOR rg_rec in cur_rg23_next_records( ln_fin_year,ln_rg_prev_slno,lv_tax_type) LOOP

            IF ln_prev_balance <> rg_rec.opening_balance THEN
               capture_error(  p_organization_id    =>   p_organization_id  ,
                               p_location_id        =>   p_location_id      ,
                               p_register_type      =>   p_register_type    ,
                               p_fin_year           =>   ln_fin_year        ,
                               p_opening_balance    =>   null               ,
                               p_error_codes        =>   'E19'              ,
                               p_slno               =>   rg_rec.slno        ,
                               p_register_id        =>   null               ,
                               p_rowcount           =>   null               ,
                               p_tax_type           =>   lv_tax_type        ,
                               p_date               =>   null               ,
                               p_month              =>   null               ,
                               p_year               =>   null
                              ) ;
              IF gn_action = 3 THEN
                corr_oth_balances
                               (
                                  p_organization_id  => p_organization_id,
                                  p_location_id      => p_location_id,
                                  p_fin_year         => ln_fin_year,
                                  p_register_type    => p_register_type,
                                  p_slno             => rg_rec.slno,
                                  p_tax_type         => lv_tax_type,
                                  p_last_updated_by  => -5451134
                               );
              END IF;

              EXIT;
            END IF;
            IF rg_rec.opening_balance + rg_rec.transaction_amount <> rg_rec.closing_balance THEN
               capture_error(  p_organization_id    =>   p_organization_id  ,
                               p_location_id        =>   p_location_id      ,
                               p_register_type      =>   p_register_type    ,
                               p_fin_year           =>   ln_fin_year        ,
                               p_opening_balance    =>   null               ,
                               p_error_codes        =>   'E08'              ,
                               p_slno               =>   rg_rec.slno        ,
                               p_register_id        =>   null               ,
                               p_rowcount           =>   null               ,
                               p_tax_type           =>   lv_tax_type        ,
                               p_date               =>   null               ,
                               p_month              =>   null               ,
                               p_year               =>   null
                              ) ;
             IF gn_action = 3 THEN
                corr_oth_balances
                               (
                                  p_organization_id  => p_organization_id,
                                  p_location_id      => p_location_id,
                                  p_fin_year         => ln_fin_year,
                                  p_register_type    => p_register_type,
                                  p_slno             => rg_rec.slno,
                                  p_tax_type         => lv_tax_type,
                                  p_last_updated_by  => -5451134
                               );
              return;
              END IF;
            END IF;
            ln_rg_prev_slno := rg_rec.slno;
            ln_prev_balance := rg_rec.closing_balance;
          END LOOP;

        ELSIF p_register_type = 'PLA' AND ln_pla_prev_slno IS NOT NULL THEN

          OPEN  get_rg_closing_bal(ln_fin_year,ln_pla_prev_slno,lv_tax_type);
          FETCH get_rg_closing_bal INTO ln_prev_balance;
          CLOSE get_rg_closing_bal;

          FOR pla_rec in cur_pla_next_records( ln_fin_year,ln_pla_prev_slno,lv_tax_type) LOOP

             IF ln_prev_balance <> pla_rec.opening_balance THEN
               capture_error(  p_organization_id    =>   p_organization_id    ,
                               p_location_id        =>   p_location_id        ,
                               p_register_type      =>   'PLA'                ,
                               p_fin_year           =>   ln_fin_year          ,
                               p_opening_balance    =>   null                 ,
                               p_error_codes        =>   'E19'                ,
                               p_slno               =>   pla_rec.slno         ,
                               p_register_id        =>   null                 ,
                               p_rowcount           =>   null                 ,
                               p_tax_type           =>   lv_tax_type          ,
                               p_date               =>   null                 ,
                               p_month              =>   null                 ,
                               p_year               =>   null
                              ) ;
                IF gn_action = 3 THEN
                  corr_oth_balances
                               (
                                  p_organization_id  => p_organization_id,
                                  p_location_id      => p_location_id,
                                  p_fin_year         => ln_fin_year,
                                  p_register_type    => p_register_type,
                                  p_slno             => pla_rec.slno,
                                  p_tax_type         => lv_tax_type,
                                  p_last_updated_by  => -5451134
                               );
                END IF;
                return;

             END IF;

             IF pla_rec.opening_balance + pla_rec.transaction_amount <> pla_rec.closing_balance THEN
               capture_error(  p_organization_id    =>   p_organization_id  ,
                               p_location_id        =>   p_location_id      ,
                               p_register_type      =>   p_register_type    ,
                               p_fin_year           =>   ln_fin_year        ,
                               p_opening_balance    =>   null               ,
                               p_error_codes        =>   'E08'              ,
                               p_slno               =>   pla_rec.slno        ,
                               p_register_id        =>   null               ,
                               p_rowcount           =>   null               ,
                               p_tax_type           =>   lv_tax_type        ,
                               p_date               =>   null               ,
                               p_month              =>   null               ,
                               p_year               =>   null
                              ) ;
               IF gn_action = 3 THEN
                 corr_oth_balances
                               (
                                  p_organization_id  => p_organization_id,
                                  p_location_id      => p_location_id,
                                  p_fin_year         => ln_fin_year,
                                  p_register_type    => p_register_type,
                                  p_slno             => pla_rec.slno,
                                  p_tax_type         => lv_tax_type,
                                  p_last_updated_by  => -5451134
                               );
                  return;
                END IF;

             END IF;

             ln_pla_prev_slno := pla_rec.slno;
             ln_prev_balance  := pla_rec.closing_balance;

          END LOOP;

        END IF;

        ln_fin_year := ln_fin_year + 1;
        EXIT WHEN ln_fin_year > ln_curr_fin_year ;
        ld_date     := SYSDATE;

				ln_rg_tax_exists := 0;
				OPEN cur_rg_tax_exists(ln_fin_year,lv_tax_type,ld_date);
				FETCH cur_rg_tax_exists INTO ln_rg_tax_exists;
				CLOSE cur_rg_tax_exists;

				IF p_register_type IN ('A','C') AND ln_rg_tax_exists = 0 THEN
					EXIT;
				END IF;

				OPEN cur_get_rg_slno(ln_fin_year,lv_tax_type,ld_date);
				FETCH cur_get_rg_slno INTO ln_rg_prev_slno,ln_rg_first_slno;
				CLOSE cur_get_rg_slno;

				ln_pla_tax_exists := 0;
				OPEN cur_pla_tax_exists(ln_fin_year,lv_tax_type,ld_date);
				FETCH cur_pla_tax_exists INTO ln_pla_tax_exists;
				CLOSE cur_pla_tax_exists;

				IF p_register_type = 'PLA' AND ln_pla_tax_exists = 0 THEN
					EXIT;
				END IF;

				OPEN cur_get_pla_slno(ln_fin_year,lv_tax_type,ld_date);
				FETCH cur_get_pla_slno INTO ln_pla_prev_slno,ln_pla_first_slno;
				CLOSE cur_get_pla_slno;

				OPEN cur_get_rg_slno(ln_fin_year,lv_tax_type,ld_date);
				FETCH cur_get_rg_slno INTO ln_rg_prev_slno,ln_rg_first_slno;
				CLOSE cur_get_rg_slno;

				OPEN cur_get_pla_slno(ln_fin_year,lv_tax_type,ld_date);
				FETCH cur_get_pla_slno INTO ln_pla_prev_slno,ln_pla_first_slno;
				CLOSE cur_get_pla_slno;

				ln_pla_prev_slno := ln_pla_first_slno;
				ln_rg_prev_slno  := ln_rg_first_slno;

      END LOOP;

			OPEN cur_get_final_bal(lv_tax_type);
			FETCH cur_get_final_bal INTO ln_final_bal;
			CLOSE cur_get_final_bal;

			IF ln_prev_balance <> ln_final_bal THEN
				IF p_register_type = 'PLA' THEN
						ln_final_slno := ln_pla_prev_slno ;
				ELSE
					ln_final_slno := ln_rg_prev_slno ;
				END IF;

				if gn_action =  3 then
				 corr_final_bal( p_organization_id =>   p_organization_id  ,
												 p_location_id     =>   p_location_id      ,
												 p_register_type   =>   p_register_type    ,
												 p_tax_type        =>   lv_tax_type        ,
												 p_closing_balance =>   ln_prev_balance   );
				end if ;

				 capture_error(  p_organization_id    =>   p_organization_id  ,
												 p_location_id        =>   p_location_id      ,
												 p_register_type      =>   p_register_type    ,
												 p_fin_year           =>   ln_fin_year        ,
												 p_opening_balance    =>   null               ,
												 p_error_codes        =>   'E06'              ,
												 p_slno               =>   ln_final_slno      ,
												 p_register_id        =>   null               ,
												 p_rowcount           =>   null               ,
												 p_tax_type           =>   lv_tax_type        ,
												 p_date               =>   null               ,
												 p_month              =>   null               ,
												 p_year               =>   null
												) ;

      END IF;
    END LOOP;
  END validate_rg_others ;
 ------------------------------------ VALIDATE_RG_OTHERS ------------------------------------------------
 ------------------------------------ CORR_EXC_BAL ------------------------------------------------

 PROCEDURE corr_exc_bal( p_register_type    VARCHAR2,
                         p_organization_id  NUMBER  ,
                         p_location_id      NUMBER  ,
                         p_slno             NUMBER  ,
                         p_fin_year         NUMBER  ,
                         p_last_updated_by  NUMBER  )
 IS
 CURSOR cur_next_pla_records IS
 SELECT opening_balance,
        closing_balance,
        nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0) -
        nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0) transaction_amount,
        register_id,
        slno
   FROM JAI_CMN_RG_PLA_TRXS
  WHERE organization_id = p_organization_id
    AND location_id     = p_location_id
    AND ((fin_year      = p_fin_year
           AND slno      >= p_slno ) OR
         ( fin_year > p_fin_year ))
  ORDER BY FIN_YEAR,SLNO
    FOR UPDATE ;

 l_apps_short_name CONSTANT VARCHAR2(2) := 'JA';

 CURSOR c_check_addl_cvd
 IS
 SELECT 1
   FROM all_tab_cols
  WHERE table_name = 'JAI_CMN_RG_23AC_II_TRXS'
    AND column_name IN ( 'DR_ADDITIONAL_CVD', 'CR_ADDITIONAL_CVD')
    AND owner = l_apps_short_name ;    /*added by ssawant*/

 ln_prev_balance    NUMBER;
 ln_prev_slno       NUMBER;
 lv_trans_str       VARCHAR2(1000);
 lv_cursor_str      VARCHAR2(4000);
 ln_cvd_exists      NUMBER := 0;
 ln_fin_year        NUMBER;
 ln_opening_balance NUMBER;
 ln_closing_balance NUMBER;
 ln_trans_amt       NUMBER;
 ln_slno            NUMBER;
 ln_register_id     NUMBER;
 type records_ref is ref cursor;
 cur_next_rg_records records_ref;
 BEGIN

   lv_trans_str := 'nvl(cr_basic_ed,0) + nvl(cr_additional_ed,0) + nvl(cr_other_ed,0) -
        nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0)';

   OPEN c_check_addl_cvd ;
   FETCH c_check_addl_cvd INTO ln_cvd_exists ;
   CLOSE c_check_addl_cvd ;

   IF ln_cvd_exists = 1 THEN

     lv_trans_str := lv_trans_str || '+ nvl(CR_ADDITIONAL_CVD,0) - nvl(DR_ADDITIONAL_CVD,0)';

   END IF;
   lv_cursor_str :=  'SELECT '||
                            lv_trans_str||' ,
                            register_id,
                             slno
                       FROM JAI_CMN_RG_23AC_II_TRXS
                      WHERE organization_id ='|| p_organization_id||'
                        AND location_id     ='|| p_location_id||'
                        AND register_type   ='''|| p_register_type||'''
                        AND ((fin_year      ='|| p_fin_year||'
                              AND slno      >='|| p_slno||' ) OR
                              ( fin_year >'|| p_fin_year||' ))
                         ORDER BY fin_year,slno
                     FOR UPDATE ';
   ln_fin_year  := p_fin_year;
   ln_prev_slno := p_slno;

   get_prev_rg_bal( p_organization_id => p_organization_id,
                   p_location_id     => p_location_id,
                   p_register_type   => p_register_type,
                   p_fin_year        => ln_fin_year,
                   p_slno            => ln_prev_slno,
                   p_bal             => ln_prev_balance);

   IF ln_prev_slno IS NULL THEN

     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error : No previous record exists. Need to fix Manually');
     RETURN;

   END IF;


   IF p_register_type IN ('A','C') THEN

     OPEN cur_next_rg_records FOR lv_cursor_str;
     LOOP
       FETCH cur_next_rg_records INTO ln_trans_amt,ln_register_id,ln_slno  ;
       EXIT WHEN cur_next_rg_records%NOTFOUND;
       ln_opening_balance := ln_prev_balance;
       ln_closing_balance := ln_opening_balance + ln_trans_amt;

       UPDATE JAI_CMN_RG_23AC_II_TRXS
          SET opening_balance  = ln_opening_balance,
              closing_balance  = ln_closing_balance,
              last_updated_by  = p_last_updated_by,
              last_update_date = sysdate
        WHERE register_id = ln_register_id;

        ln_prev_balance := ln_closing_balance;

     END LOOP;

     IF p_register_type = 'A' THEN

       UPDATE JAI_CMN_RG_BALANCES
          SET rg23a_balance    = ln_prev_balance,
              last_updated_by  = p_last_updated_by
        WHERE organization_id = p_organization_id
          AND location_id     = p_location_id ;

       UPDATE JAI_CMN_RG_SLNOS
          SET balance         = ln_prev_balance
        WHERE organization_id = p_organization_id
          AND location_id     = p_location_id
          AND register_type   = 'A' ;

      ELSIF p_register_type = 'C' THEN

        UPDATE JAI_CMN_RG_BALANCES
           SET rg23c_balance   = ln_prev_balance
         WHERE organization_id = p_organization_id
           AND location_id     = p_location_id ;

        UPDATE JAI_CMN_RG_SLNOS
           SET balance         = ln_prev_balance
         WHERE organization_id = p_organization_id
           AND location_id     = p_location_id
           AND register_type   = 'C' ;

      END IF;

    ELSIF p_register_type = 'PLA' THEN

      FOR records in cur_next_pla_records LOOP

        ln_opening_balance := ln_prev_balance;
        ln_closing_balance := ln_opening_balance + records.transaction_amount;

        UPDATE JAI_CMN_RG_PLA_TRXS
           SET opening_balance  = ln_opening_balance,
               closing_balance  = ln_closing_balance,
               last_updated_by  = p_last_updated_by,
               last_update_date = sysdate
         WHERE CURRENT OF cur_next_pla_records;

         ln_prev_balance := ln_closing_balance;

      END LOOP;

      UPDATE JAI_CMN_RG_BALANCES
         SET pla_balance     = ln_prev_balance,
             last_updated_by = p_last_updated_by
       WHERE organization_id = p_organization_id
         AND location_id     = p_location_id ;

     UPDATE JAI_CMN_RG_SLNOS
        SET balance         = ln_prev_balance
      WHERE organization_id = p_organization_id
        AND location_id     = p_location_id
        AND register_type   = 'PLA' ;

    END IF;

END corr_exc_bal;

------------------------------------ CORR_EXC_BAL ------------------------------------------------
------------------------------------ UPD_OTH_TAX ------------------------------------------------

PROCEDURE upd_oth_tax( p_register_type   VARCHAR2,
                                         p_register_id     NUMBER )
IS
BEGIN

  IF p_register_type IN ( 'A','C') THEN

    UPDATE JAI_CMN_RG_23AC_II_TRXS
       SET other_tax_credit = ( SELECT sum(credit)
                                  FROM JAI_CMN_RG_OTHERS
                                 WHERE source_type = 1
                                   AND source_register_id = p_register_id ),
           other_tax_debit  = ( SELECT sum(debit)
                                  FROM JAI_CMN_RG_OTHERS
                                 WHERE source_type = 1
                                   AND source_register_id = p_register_id )
     WHERE register_id = p_register_id;

   ELSIF p_register_type = 'PLA' THEN

    UPDATE JAI_CMN_RG_PLA_TRXS
       SET other_tax_credit = ( SELECT sum(credit)
                                  FROM JAI_CMN_RG_OTHERS
                                 WHERE source_type = 2
                                   AND source_register_id = p_register_id ),
           other_tax_debit  = ( SELECT sum(debit)
                                  FROM JAI_CMN_RG_OTHERS
                                 WHERE source_type = 2
                                   AND source_register_id = p_register_id )
     WHERE register_id = p_register_id;

   END IF;

END upd_oth_tax;

------------------------------------ UPD_OTH_TAX ------------------------------------------------

 ------------------------------------ PLA_VALIDATION ------------------------------------------------
  PROCEDURE pla_validation (
                      p_organization_id    IN  JAI_CMN_RG_PLA_TRXS.ORGANIZATION_ID%TYPE ,
                      p_location_id        IN  JAI_CMN_RG_PLA_TRXS.LOCATION_ID%TYPE     ,
                      p_fin_year           IN  JAI_CMN_RG_PLA_TRXS.FIN_YEAR%TYPE
                    )
  IS

    Cursor c_duplicate_slno
    IS
    select slno, count(*) rowcount
    from
      JAI_CMN_RG_PLA_TRXS
    where
      organization_id = p_organization_id and
      location_id     = p_location_id     and
      fin_year        = p_fin_year        and
      trunc(creation_date)    >= gd_date
      group by slno
      having count(*) > 1 ;

    Cursor c_transaction_balance
    is
    select  slno
    from
      JAI_CMN_RG_PLA_TRXS
    where
        closing_balance         <> nvl(opening_balance,0)                                               +
                                   ( nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0) )    -
                                   ( nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0) )    AND
        organization_id         = p_organization_id                                                     AND
        location_id             = p_location_id                                                           AND
        fin_year                = p_fin_year                                                            AND
        trunc(creation_date)    >= gd_date
    ORDER BY
        register_id ;

    Cursor check_balances
    is
    select
                rowid                                                                   ,
                slno                                                                    ,
                organization_id                                                         ,
                location_id                                                             ,
                register_id                                                             ,
                fin_year                                                                ,
                opening_balance                                                         ,
                closing_balance                                                         ,
                nvl(other_tax_credit,other_tax_debit)    rg_other_amt                   ,
                transaction_source_num
        FROM
                JAI_CMN_RG_PLA_TRXS
        WHERE
                organization_id = p_organization_id    AND
                location_id     = p_location_id        AND
                fin_year        = p_fin_year           AND
                trunc(creation_date)    >= gd_date
        ORDER BY
                slno   ;

    cursor  c_get_closing_balance (  cp_organization_id  JAI_CMN_RG_PLA_TRXS.organization_id%type  ,
                                     cp_location_id      JAI_CMN_RG_PLA_TRXS.location_id%type      ,
                                     cp_fin_year         JAI_CMN_RG_PLA_TRXS.fin_year%type     ,
                                     cp_slno             JAI_CMN_RG_PLA_TRXS.slno%type
                                  )
    is
    select
           nvl(closing_balance,0)
    from
           JAI_CMN_RG_PLA_TRXS
    where
           organization_id = cp_organization_id    AND
           location_id     = cp_location_id        AND
           fin_year        = cp_fin_year           AND
           slno            =
              ( select max(slno)
                from
                  JAI_CMN_RG_PLA_TRXS
                where
                  organization_id = cp_organization_id and
                  location_id     = cp_location_id     and
                  fin_year        = cp_fin_year        and
                  slno            < cp_slno
               );

    Cursor c_final_balance_pla (cp_organization_id IN NUMBER,
                                cp_location_id     IN NUMBER,
                                cp_fin_year        IN NUMBER
                               ) IS
    select nvl(closing_balance,0)
    from JAI_CMN_RG_PLA_TRXS
    where organization_id = cp_organization_id
    and   location_id     = cp_location_id
    and   fin_year = cp_fin_year
    and   slno in
                 ( select nvl(max(slno),0)
                   from JAI_CMN_RG_PLA_TRXS
                   where organization_id = cp_organization_id
                   and location_id       = cp_location_id
                   and fin_year          = cp_fin_year
                 );


    ln_closing_balance number ;

    cursor c_rg_others(cp_source_register_id number)
    is
    select nvl(sum(credit), sum(debit))
    from JAI_CMN_RG_OTHERS
    where source_register = 'PLA'
    and   source_register_id = cp_source_register_id
    and   source_type        =  2 ;

    ln_rg_other_amt number ;
    ln_rowcount    number ;
    ln_slno        number ;
    ln_register_id number ;

  BEGIN

    ln_rowcount := null ;

    For rec_slno in c_duplicate_slno
    loop

      if nvl(ln_slno,0) <> 0 then

        if gn_action =  3 then
          remove_dup_slno( p_organization_id =>   p_organization_id    ,
                           p_location_id     =>   p_location_id        ,
                           p_fin_year        =>   p_fin_year           ,
                           p_register_type   =>   'PLA'                ,
                           p_slno            =>   rec_slno.slno   ,
                           p_dup_cnt         =>   rec_slno.rowcount );
        end if ;

        capture_error( p_organization_id    =>   p_organization_id ,
                       p_location_id        =>   p_location_id     ,
                       p_register_type      =>   'PLA'             ,
                       p_fin_year           =>   p_fin_year        ,
                       p_opening_balance    =>   null              ,
                       p_error_codes        =>   'E07'             ,
                       p_slno               =>   rec_slno.slno     ,
                       p_register_id        =>   null              ,
                       p_rowcount           =>   rec_slno.rowcount ,
                       p_tax_type           =>   null              ,
                       p_date               =>   null              ,
                       p_month              =>   null              ,
                       p_year               =>   null
                      ) ;

    end if ;

    end loop ;

    ln_slno        := null ;
    ln_rowcount    := null ;

    open c_transaction_balance ;
    fetch c_transaction_balance into ln_slno ;
    ln_rowcount := c_transaction_balance%ROWCOUNT ;
    close c_transaction_balance ;

    if nvl(ln_slno,0) <> 0 then
      capture_error( p_organization_id    =>   p_organization_id ,
                     p_location_id        =>   p_location_id     ,
                     p_register_type      =>   'PLA'             ,
                     p_fin_year           =>   p_fin_year        ,
                     p_opening_balance    =>   null              ,
                     p_error_codes        =>   'E05'             ,
                     p_slno               =>   ln_slno           ,
                     p_register_id        =>   null              ,
                     p_rowcount           =>   ln_rowcount       ,
                     p_tax_type           =>   null              ,
                     p_date               =>   null              ,
                     p_month              =>   null              ,
                     p_year               =>   null
                    ) ;

      IF gn_action = 3 THEN
        corr_exc_bal( p_register_type    => 'PLA'      ,
                      p_organization_id  => p_organization_id  ,
                      p_location_id      => p_location_id      ,
                      p_slno             => ln_slno             ,
                      p_fin_year         => p_fin_year        ,
                      p_last_updated_by  => -5451134   );
        return ;
      END IF;

      return ;



    end if ;

    FOR rec IN check_balances
    LOOP

      ln_closing_balance := null ;
      open  c_get_closing_balance(rec.organization_id,rec.location_id, rec.fin_year, rec.slno) ;
      fetch c_get_closing_balance into ln_closing_balance ;
      close c_get_closing_balance ;

      if ln_closing_balance is null then
        open  c_final_balance_pla(rec.organization_id,rec.location_id, rec.fin_year-1) ;
        fetch c_final_balance_pla into ln_closing_balance ;
        close c_final_balance_pla ;

        if ln_closing_balance is null then
           ln_closing_balance := 0 ;
        end if ;
      end if ;

      if nvl(rec.opening_balance,0) <>  nvl(ln_closing_balance,0) then
        capture_error( p_organization_id    =>   p_organization_id ,
                       p_location_id        =>   p_location_id     ,
                       p_register_type      =>   'PLA'             ,
                       p_fin_year           =>   p_fin_year        ,
                       p_opening_balance    =>   null              ,
                       p_error_codes        =>   'E04'             ,
                       p_slno               =>   rec.slno          ,
                       p_register_id        =>   rec.register_id   ,
                       p_rowcount           =>   null              ,
                       p_tax_type           =>   null              ,
                       p_date               =>   null              ,
                       p_month              =>   null              ,
                       p_year               =>   null
                      ) ;

        IF gn_action = 3 THEN
          corr_exc_bal( p_register_type    => 'PLA'      ,
                        p_organization_id  => rec.organization_id  ,
                        p_location_id      => rec.location_id      ,
                        p_slno             => rec.slno             ,
                        p_fin_year         => rec.fin_year         ,
                        p_last_updated_by  => -5451134   );
        END IF;

        return ;

      end if;

      ln_rg_other_amt := null ;
      open c_rg_others(rec.register_id) ;
      fetch c_rg_others into ln_rg_other_amt ;
      close c_rg_others ;

      if nvl(ln_rg_other_amt,0) <> nvl(rec.rg_other_amt,0)
      then
        capture_error( p_organization_id    =>   p_organization_id ,
                       p_location_id        =>   p_location_id     ,
                       p_register_type      =>   'PLA'             ,
                       p_fin_year           =>   p_fin_year        ,
                       p_opening_balance    =>   null              ,
                       p_error_codes        =>   'E10'             ,
                       p_slno               =>   null              ,
                       p_register_id        =>   rec.register_id   ,
                       p_rowcount           =>   null              ,
                       p_tax_type           =>   null              ,
                       p_date               =>   null              ,
                       p_month              =>   null              ,
                       p_year               =>   null
                      ) ;

        IF gn_action = 3 THEN

          upd_oth_tax( p_register_type   => 'PLA',
                       p_register_id     => rec.register_id );
        END IF;

      end if ;
    END LOOP ;

  END pla_validation;
  ------------------------------------ PLA_VALIDATION ------------------------------------------------



  ------------------------------------ RG23_PART_II_VALIDATION ------------------------------------------------
  PROCEDURE rg23_part_ii_validation( p_organization_id    IN  JAI_CMN_RG_23AC_II_TRXS.ORGANIZATION_ID%TYPE ,
                              p_location_id        IN  JAI_CMN_RG_23AC_II_TRXS.LOCATION_ID%TYPE     ,
                              p_fin_year           IN  JAI_CMN_RG_23AC_II_TRXS.FIN_YEAR%TYPE        ,
                              p_register_type      IN  JAI_CMN_RG_23AC_II_TRXS.REGISTER_TYPE%TYPE
                             )
  IS

    Cursor c_duplicate_slno
    IS
    select slno , count(*) rowcount
    from
      JAI_CMN_RG_23AC_II_TRXS
    where
      organization_id = p_organization_id and
      location_id     = p_location_id  and
      fin_year        = p_fin_year and
      register_type   = p_register_type and
      trunc(creation_date) >= gd_date
      group by slno
      having count(*) > 1 ;

    Cursor c_transaction_balance
    is
    select  slno
    from
      JAI_CMN_RG_23AC_II_TRXS
    where
        closing_balance         <> nvl(opening_balance,0)                                               +
                                   ( nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0) )    -
                                   ( nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0) )    AND
        register_type           = p_register_type                                                       AND
        organization_id         = p_organization_id                                                     AND
        location_id             = p_location_id                                                           AND
        fin_year                = p_fin_year                                                            AND
        trunc(creation_date)    >= gd_date
    ORDER BY
        register_id ;

    Cursor check_balances
    is
    select
                rowid                                                                   ,
                slno                                                                    ,
                organization_id                                                         ,
                location_id                                                             ,
                register_id                                                             ,
                register_type                                                           ,
                fin_year                                                                ,
                opening_balance                                                         ,
                closing_balance                                                         ,
                nvl(other_tax_credit,other_tax_debit)    rg_other_amt
        FROM
                JAI_CMN_RG_23AC_II_TRXS
        WHERE
                organization_id = p_organization_id    AND
                location_id     = p_location_id        AND
                fin_year        = p_fin_year           AND
                register_type   = p_register_type      AND
                trunc(creation_date)    >= gd_date
        ORDER BY
                organization_id ,
                location_id     ,
                fin_year        ,
                register_type   ,
                slno   ;

    cursor  c_get_closing_balance (  cp_organization_id  JAI_CMN_RG_23AC_II_TRXS.ORGANIZATION_ID%TYPE  ,
                                     cp_location_id      JAI_CMN_RG_23AC_II_TRXS.LOCATION_ID%TYPE      ,
                                     cp_fin_year         JAI_CMN_RG_23AC_II_TRXS.FIN_YEAR%TYPE     ,
                                     cp_register_type    JAI_CMN_RG_23AC_II_TRXS.REGISTER_TYPE%TYPE  ,
                                     cp_slno             JAI_CMN_RG_23AC_II_TRXS.SLNO%TYPE
                                  )
    is
    select
           nvl(closing_balance,0)
    from
           JAI_CMN_RG_23AC_II_TRXS
    where
           organization_id = cp_organization_id    AND
           location_id     = cp_location_id        AND
           fin_year        = cp_fin_year           AND
           register_type   = cp_register_type      AND
           slno            =
                         ( select max(slno)
                           from
                             JAI_CMN_RG_23AC_II_TRXS
                           where
                             organization_id = cp_organization_id and
                             location_id     = cp_location_id     and
                             fin_year        = cp_fin_year        and
                             register_type   = cp_register_type   and
                             slno            < cp_slno  ) ;

    Cursor c_final_balance_rg23(cp_organization_id IN NUMBER,
                                cp_location_id     IN NUMBER,
                                cp_fin_year        IN NUMBER,
                                cp_register_type CHAR) IS
    select nvl(closing_balance,0)
    from JAI_CMN_RG_23AC_II_TRXS
    where organization_id = cp_organization_id
    and   location_id     = cp_location_id
    and   register_type   = cp_register_type
    and   fin_year = cp_fin_year
    and   slno in
                 ( select nvl(max(slno),0)
                   from JAI_CMN_RG_23AC_II_TRXS
                   where organization_id = cp_organization_id
                   and location_id       = cp_location_id
                   and fin_year          = cp_fin_year
                   and register_type     = cp_register_type);

    cursor c_rg_others(cp_source_register_id number , cp_register_type varchar2)
    is
    select nvl(sum(credit), sum(debit))
    from JAI_CMN_RG_OTHERS
    where source_register = decode(cp_register_type,'A','RG23A_P2','C','RG23C_P2')
    and   source_register_id = cp_source_register_id
    and   source_type        =  1 ;

    ln_rg_other_amt number ;
    ln_closing_balance number ;
    ln_rowcount    number ;
    ln_slno        number ;
    ln_register_id number ;


  BEGIN

    ln_rowcount := null ;

    For rec_slno in c_duplicate_slno
    loop
      if nvl(ln_slno,0) <> 0 then
        if gn_action = 3 then
          remove_dup_slno( p_organization_id =>   p_organization_id    ,
                           p_location_id     =>   p_location_id        ,
                           p_fin_year        =>   p_fin_year           ,
                           p_register_type   =>   p_register_type      ,
                           p_slno            =>   rec_slno.slno   ,
                           p_dup_cnt         =>   rec_slno.rowcount );
        end if ;

        capture_error( p_organization_id    =>   p_organization_id ,
                       p_location_id        =>   p_location_id     ,
                       p_register_type      =>   p_register_type   ,
                       p_fin_year           =>   p_fin_year        ,
                       p_opening_balance    =>   null              ,
                       p_error_codes        =>   'E18'             ,
                       p_slno               =>   rec_slno.slno     ,
                       p_register_id        =>   null              ,
                       p_rowcount           =>   rec_slno.rowcount ,
                       p_tax_type           =>   null              ,
                       p_date               =>   null              ,
                       p_month              =>   null              ,
                       p_year               =>   null
                      ) ;

        --return ;
      end if ;
    end loop ;

    ln_slno        := null ;
    ln_rowcount    := null ;


    if nvl(gn_exists,0) =1
    then

     begin
       execute immediate
       '    select  slno
           from
             JAI_CMN_RG_23AC_II_TRXS
           where
               closing_balance         <> nvl(opening_balance,0)                                               +
                                          ( nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0) + nvl(cr_additional_cvd,0))    -
                                          ( nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0) + nvl(dr_additional_cvd,0))    AND
               register_type           = ''' || p_register_type || '''                                                     AND
               organization_id         = ' || p_organization_id  || '                                                    AND
               location_id             = ' || p_location_id      || '                                                     AND
               fin_year                = ' || p_fin_year         || '                                                   AND
               trunc(creation_date)    >= to_date(''' || gd_date || ''',''dd-mon-rrrr'')
               and rownum =1 ORDER BY register_id '
               into ln_register_id ;


        execute immediate
              '    select  count(1)
                  from
                    JAI_CMN_RG_23AC_II_TRXS
                  where
                      closing_balance         <> nvl(opening_balance,0)                                               +
                                                 ( nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0) )    -
                                                 ( nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0) )    AND
                      register_type           = ''' || p_register_type || '''                                                     AND
                      organization_id         = ' || p_organization_id  || '                                                    AND
                      location_id             = ' || p_location_id      || '                                                     AND
                      fin_year                = ' || p_fin_year         || '                                                   AND
                      trunc(creation_date)    >= to_date(''' || gd_date || ''',''dd-mon-rrrr'')
                      and rownum =1 ORDER BY register_id '
                    into ln_rowcount ;

      exception
       when no_data_found then
         null ;
      end ;
    else
      open c_transaction_balance ;
      fetch c_transaction_balance into ln_slno ;
      ln_rowcount := c_transaction_balance%ROWCOUNT ;
      close c_transaction_balance ;
    end if ;

    if nvl(ln_slno,0) <> 0 then
       capture_error(  p_organization_id    =>   p_organization_id ,
                       p_location_id        =>   p_location_id     ,
                       p_register_type      =>   p_register_type   ,
                       p_fin_year           =>   p_fin_year        ,
                       p_opening_balance    =>   null              ,
                       p_error_codes        =>   'E03'             ,
                       p_slno               =>   ln_slno           ,
                       p_register_id        =>   NULL              ,
                       p_rowcount           =>   ln_rowcount       ,
                       p_tax_type           =>   null              ,
                       p_date               =>   null              ,
                       p_month              =>   null              ,
                       p_year               =>   null
                      ) ;


      IF gn_action = 3 THEN
          corr_exc_bal( p_register_type    => p_register_type      ,
                        p_organization_id  => p_organization_id  ,
                        p_location_id      => p_location_id      ,
                        p_slno             => ln_slno             ,
                        p_fin_year         => p_fin_year         ,
                        p_last_updated_by  => -5451134   );
      END IF;



      return ;
    end if ;

    FOR rec IN check_balances
    LOOP
      ln_closing_balance := null ;
      open  c_get_closing_balance(rec.organization_id,rec.location_id, rec.fin_year, rec.register_type, rec.slno) ;
      fetch c_get_closing_balance into ln_closing_balance ;
      close c_get_closing_balance ;

      if ln_closing_balance is null then
        open  c_final_balance_rg23(rec.organization_id,rec.location_id, rec.fin_year-1, rec.register_type) ;
        fetch c_final_balance_rg23 into ln_closing_balance ;
        close c_final_balance_rg23 ;

        if ln_closing_balance is null then
           ln_closing_balance := 0 ;
        end if ;
      end if ;

      if nvl(rec.opening_balance,0) <>  nvl(ln_closing_balance,0) then
           capture_error(  p_organization_id    =>   p_organization_id ,
                           p_location_id        =>   p_location_id     ,
                           p_register_type      =>   p_register_type   ,
                           p_fin_year           =>   p_fin_year        ,
                           p_opening_balance    =>   null              ,
                           p_error_codes        =>   'E02'             ,
                           p_slno               =>   rec.slno          ,
                           p_register_id        =>   rec.register_id   ,
                           p_rowcount           =>   null              ,
                           p_tax_type           =>   null              ,
                           p_date               =>   null              ,
                           p_month              =>   null              ,
                           p_year               =>   null
                          ) ;


        IF gn_action = 3 THEN
          corr_exc_bal( p_register_type    => p_register_type      ,
                        p_organization_id  => p_organization_id  ,
                        p_location_id      => p_location_id      ,
                        p_slno             => rec.slno             ,
                        p_fin_year         => p_fin_year         ,
                        p_last_updated_by  => -5451134   );
        END IF;


        return ;
      end if;

      ln_rg_other_amt := null ;
      open c_rg_others(rec.register_id, rec.register_type) ;
      fetch c_rg_others into ln_rg_other_amt ;
      close c_rg_others ;

      if nvl(ln_rg_other_amt,0) <> nvl(rec.rg_other_amt,0)
      then
         capture_error(  p_organization_id    =>   p_organization_id ,
                         p_location_id        =>   p_location_id     ,
                         p_register_type      =>   p_register_type   ,
                         p_fin_year           =>   p_fin_year        ,
                         p_opening_balance    =>   null              ,
                         p_error_codes        =>   'E09'             ,
                         p_slno               =>   null              ,
                         p_register_id        =>   rec.register_id   ,
                         p_rowcount           =>   null              ,
                         p_tax_type           =>   null              ,
                         p_date               =>   null              ,
                         p_month              =>   null              ,
                         p_year               =>   null
                        ) ;

        IF gn_action = 3 THEN

          upd_oth_tax( p_register_type   => p_register_type,
                       p_register_id     => rec.register_id );
        END IF;


      end if ;
    END LOOP ;

  END rg23_part_ii_validation;
  ------------------------------------ RG23_PART_II_VALIDATION ------------------------------------------------


  ------------------------------------ CAPTURE_ERROR ------------------------------------------------
  /*

    Column list and their related information for the table JAI_TRX_GT

    organization_id  - JAI_INFO_N1
    location_id      - JAI_INFO_N2
    register_type    - JAI_INFO_V1
    fin_yr           - JAI_INFO_N3
    opening_balance  - JAI_INFO_N4
    credit_amount    - JAI_INFO_N5
    debit_amount     - JAI_INFO_N6
    closing_balance  - JAI_INFO_N7
    Status           - JAI_INFO_V2
    error_codes      - JAI_INFO_V3
    slno             - JAI_INFO_N8
    register_id      - JAI_INFO_N9
    rowcount         - JAI_INFO_N10
    tax_type         - JAI_INFO_V4
    date             - JAI_INFO_D1
    month            - JAI_INFO_V5
    year             - JAI_INFO_N11

  */



   PROCEDURE capture_error
                      ( p_organization_id    number,
                        p_location_id        number,
                        p_register_type      varchar2,
                        p_fin_year           number,
                        p_opening_balance    number,
                        p_error_codes        varchar2,
                        p_slno               number,
                        p_register_id        number,
                        p_rowcount           number,
                        p_tax_type           varchar2,
                        p_date               date,
                        p_month              varchar2,
                        p_year               number
                       )
   IS
   BEGIN

    insert into JAI_TRX_GT
    ( JAI_INFO_N1   ,
      JAI_INFO_N2   ,
      JAI_INFO_V1   ,
      JAI_INFO_N3   ,
      JAI_INFO_N4   ,
      JAI_INFO_V3   ,
      JAI_INFO_N8   ,
      JAI_INFO_N9   ,
      JAI_INFO_N10  ,
      JAI_INFO_V4   ,
      JAI_INFO_D1   ,
      JAI_INFO_V5   ,
      JAI_INFO_N11
    )
    values
    ( p_organization_id   ,
      p_location_id       ,
      p_register_type     ,
      p_fin_year          ,
      p_opening_balance   ,
      p_error_codes       ,
      p_slno              ,
      p_register_id       ,
      p_rowcount          ,
      p_tax_type          ,
      p_date              ,
      p_month             ,
      p_year
    ) ;

   END capture_error ;
  ------------------------------------ CAPTURE_ERROR ------------------------------------------------



  -----------------------------------------PROCESS_RG_TRX--------------------------------
  PROCEDURE process_rg_trx
  (    errbuf out nocopy varchar2,
       retcode out nocopy varchar2,
       p_date            VARCHAR2,
       p_organization_id NUMBER ,
       p_location_id     NUMBER ,
       p_register_type   VARCHAR2,
       p_action          NUMBER ,
       p_debug           VARCHAR2 DEFAULT NULL ,
       p_backup          VARCHAR2 DEFAULT NULL
  )

  IS

    Cursor c_rg23_balance( cp_organization_id number,
                           cp_location_id     number,
                           cp_register_type   varchar2 )
    is
    select closing_balance , slno
    from JAI_CMN_RG_23AC_II_TRXS
    where organization_id = cp_organization_id
    and   location_id     = cp_location_id
    and   register_type   = cp_register_type
    order by fin_year desc , slno desc ;

    cursor c_rg_balance( cp_organization_id number,
                         cp_location_id     number,
                         cp_register_type   varchar2 )
    is
    select decode(cp_register_type, 'A', rg23a_balance, 'C', rg23c_balance, 'PLA', pla_balance)
    from JAI_CMN_RG_BALANCES
    where organization_id = cp_organization_id
    and location_id       = cp_location_id ;

    Cursor c_pla_balance(cp_organization_id number,
                         cp_location_id     number)
    is
    select closing_balance, slno
    from JAI_CMN_RG_PLA_TRXS
    where organization_id = cp_organization_id
    and   location_id     = cp_location_id
    order by fin_year desc , slno desc ;

    ln_rg23_balance number ;
    ln_pla_balance   number ;
    ln_rg_balance    number ;

    CURSOR cur_pla_trans_amt(cp_organization_id NUMBER, cp_location_id NUMBER)
    IS
    SELECT sum(nvl(cr_basic_ed,0)+ nvl(cr_additional_ed,0) + nvl(cr_other_ed,0)
             - nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0)) total_modvat_amount
      FROM JAI_CMN_RG_PLA_TRXS
     WHERE organization_id = cp_organization_id
       AND location_id     = cp_location_id;

    ln_pla_trans_amt number ;

    Cursor c_rg_slno_balance( cp_organization_id number,
                              cp_location_id     number,
                              cp_register_type   varchar2
                            )
    is
    select balance , slno
    from JAI_CMN_RG_SLNOS
    where organization_id  = cp_organization_id
    and   location_id      = cp_location_id
    and   register_type    = cp_register_type;

     cursor pla_cons_amt ( cp_organization_id number ,
                           cp_location_id     number ,
                           cp_creation_date   date
                         )
     is
     select
       sum(nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0)) pla_cons_amt ,
       sum(other_tax_credit)  pla_oth_amt
     from JAI_CMN_RG_PLA_TRXS
     where
       transaction_source_num is null and
       organization_id = cp_organization_id and
       location_id     = cp_location_id     and
       trunc(creation_date) = cp_creation_date ;

    l_apps_short_name CONSTANT VARCHAR2(2) := 'JA';

    cursor c_check_addl_cvd
    is
    select 1
    from all_tab_cols
    where
     table_name = 'JAI_CMN_RG_23AC_II_TRXS'
     and column_name IN ( 'DR_ADDITIONAL_CVD', 'CR_ADDITIONAL_CVD')
     AND owner = l_apps_short_name ; /*added by ssawant*/

    cursor  c_get_rg23_open_bal (  cp_organization_id  JAI_CMN_RG_23AC_II_TRXS.ORGANIZATION_ID%TYPE  ,
                                   cp_location_id      JAI_CMN_RG_23AC_II_TRXS.LOCATION_ID%TYPE      ,
                                   cp_register_type    JAI_CMN_RG_23AC_II_TRXS.REGISTER_TYPE%TYPE    ,
                                   cp_date             date
                                )
    is
    select
           nvl(opening_balance,0)
    from
           JAI_CMN_RG_23AC_II_TRXS
    where
           organization_id = cp_organization_id    AND
           location_id     = cp_location_id        AND
           register_type   = cp_register_type      AND
           trunc(creation_date) >= cp_date
           order by fin_year, slno  ;

    cursor  c_get_rg23_tran_amt ( cp_organization_id  JAI_CMN_RG_23AC_II_TRXS.ORGANIZATION_ID%TYPE  ,
                                  cp_location_id      JAI_CMN_RG_23AC_II_TRXS.LOCATION_ID%TYPE      ,
                                  cp_register_type    JAI_CMN_RG_23AC_II_TRXS.REGISTER_TYPE%TYPE    ,
                                  cp_date             date
                               )
    is
    select
            sum(nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0))  credit_amount ,
            sum(nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0))  debit_amount
    from
           JAI_CMN_RG_23AC_II_TRXS
    where
           organization_id = cp_organization_id    AND
           location_id     = cp_location_id        AND
           register_type   = cp_register_type      AND
           trunc(creation_date) >= cp_date  ;

    cursor  c_rg_slno_bal (  cp_organization_id  JAI_CMN_RG_23AC_II_TRXS.ORGANIZATION_ID%TYPE  ,
                             cp_location_id      JAI_CMN_RG_23AC_II_TRXS.LOCATION_ID%TYPE      ,
                             cp_register_type    JAI_CMN_RG_23AC_II_TRXS.REGISTER_TYPE%TYPE
                          )
    is
    select balance
    from JAI_CMN_RG_SLNOS
    where
      organization_id = cp_organization_id    AND
      location_id     = cp_location_id        AND
      register_type   = cp_register_type      ;

    cursor c_err_exists(cp_organization_id number ,
                        cp_location_id     number ,
                        cp_register_type   varchar2
                       )
    is
    select count(1)
    from JAI_TRX_GT
    where
      JAI_INFO_N1  = cp_organization_id and
      JAI_INFO_N2  = cp_location_id     and
      JAI_INFO_V1  = cp_register_type ;

    cursor c_cess_err_exists(cp_organization_id number   ,
                             cp_location_id     number   ,
                             cp_register_type   varchar2 ,
                             cp_tax_type        VARCHAR2
                            )
    is
    select count(1)
    from JAI_TRX_GT
    where
      JAI_INFO_N1  = cp_organization_id AND
      JAI_INFO_N2  = cp_location_id     AND
      JAI_INFO_V1  = cp_register_type   AND
      JAI_INFO_V4  = cp_tax_type;

     Cursor c_get_pla_open_bal( cp_organization_id number,
                                 cp_location_id     number,
                                 cp_date            date
                               )
      is
      SELECT sum(nvl(cr_basic_ed,0)+ nvl(cr_additional_ed,0) + nvl(cr_other_ed,0)
              - nvl(dr_basic_ed,0) - nvl(dr_additional_ed,0) - nvl(dr_other_ed,0)) total_modvat_amount
      FROM JAI_CMN_RG_PLA_TRXS
      WHERE organization_id = cp_organization_id
      AND location_id     = cp_location_id
      and trunc(creation_date) < cp_date ;

     cursor  c_get_pla_tran_amt (  cp_organization_id  JAI_CMN_RG_PLA_TRXS.ORGANIZATION_ID%TYPE  ,
                                   cp_location_id      JAI_CMN_RG_PLA_TRXS.LOCATION_ID%TYPE      ,
                                   cp_date             date
                                 )
         is
     select
             sum(nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0))  credit_amount ,
             sum(nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0))  debit_amount
     from
            JAI_CMN_RG_PLA_TRXS
     where
            organization_id = cp_organization_id    AND
            location_id     = cp_location_id        AND
            trunc(creation_date) >= cp_date  ;

    CURSOR cur_get_fin_year( cp_organization_id NUMBER,
                             cp_date            DATE  ) IS
    SELECT fin_year
      FROM JAI_CMN_FIN_YEARS
     WHERE organization_id     = cp_organization_id
       AND cp_date between fin_year_start_date and fin_year_end_date;

    CURSOR cur_get_rg23_cess_slno( cp_organization_id NUMBER,
                                   cp_location_id     NUMBER,
                                   cp_fin_year        NUMBER,
                                   cp_tax_type        VARCHAR2,
                                   cp_date            DATE) IS
    SELECT max(slno)
      FROM JAI_CMN_RG_23AC_II_TRXS jrg
     WHERE organization_id       = p_organization_id
       AND location_id           = p_location_id
       AND fin_year              = cp_fin_year
       AND register_type         = p_register_type
       AND trunc(creation_date)  < cp_date
       AND EXISTS ( SELECT 1
                      FROM JAI_CMN_RG_OTHERS
                     WHERE source_type = 1
                       AND source_register_id = jrg.register_id
                       AND tax_type           = cp_tax_type );

    CURSOR cur_get_rg23_cess_trans(cp_organization_id NUMBER,
                                   cp_location_id     NUMBER,
                                   cp_date            DATE  ,
                                   cp_tax_type        VARCHAR2)
        IS
    SELECT sum(credit),sum(debit)
      FROM JAI_CMN_RG_OTHERS
     WHERE source_register = decode(p_register_type,'A','RG23A_P2','C','RG23C_P2')
       AND source_register_id in ( SELECT register_id
                                     FROM JAI_CMN_RG_23AC_II_TRXS
                                    WHERE organization_id = cp_organization_id
                                      AND location_id     = cp_location_id
                                      AND register_type   = p_register_type
                                      AND trunc(creation_date) >= cp_date)
       AND tax_type = cp_tax_type;

    CURSOR cur_get_pla_cess_trans(cp_organization_id NUMBER,
                                  cp_location_id     NUMBER,
                                  cp_date            DATE  ,
                                  cp_tax_type        VARCHAR2)
        IS
    SELECT sum(credit),sum(debit)
      FROM JAI_CMN_RG_OTHERS
     WHERE source_register = 'PLA'
       AND source_register_id in ( SELECT register_id
                                     FROM JAI_CMN_RG_PLA_TRXS
                                    WHERE organization_id = cp_organization_id
                                      AND location_id     = cp_location_id
                                      AND trunc(creation_date) >= cp_date)
       AND tax_type = cp_tax_type;


    CURSOR cur_get_pla_cess_slno(cp_organization_id NUMBER   ,
                                 cp_location_id     NUMBER   ,
                                 cp_fin_year        NUMBER   ,
                                 cp_tax_type        VARCHAR2 ,
                                 cp_date            DATE ) IS
    SELECT max(slno)
      FROM JAI_CMN_RG_PLA_TRXS jpl
     WHERE organization_id       = p_organization_id
       AND location_id           = p_location_id
       AND fin_year              = cp_fin_year
       AND trunc(creation_date)  < cp_date
       AND EXISTS ( SELECT 1
                      FROM JAI_CMN_RG_OTHERS
                     WHERE source_type        = 2
                       AND source_register_id = jpl.register_id
                       AND tax_type           = cp_tax_type );

    CURSOR get_rg23_cess_closing_bal(cp_fin_year NUMBER,cp_slno NUMBER,cp_tax_type VARCHAR2) IS
    SELECT closing_balance
      FROM JAI_CMN_RG_OTHERS
     WHERE source_type = 1
       AND tax_type    = cp_tax_type
       AND source_register_id in ( SELECT register_id
                                     FROM JAI_CMN_RG_23AC_II_TRXS
                                    WHERE organization_id = p_organization_id
                                      AND location_id     = p_location_id
                                      AND register_type   = p_register_type
                                      AND fin_year        = cp_fin_year
                                      AND slno            = nvl(cp_slno,1) );

    CURSOR get_pla_cess_closing_bal(cp_fin_year NUMBER,cp_slno NUMBER,cp_tax_type VARCHAR2) IS
    SELECT closing_balance
      FROM JAI_CMN_RG_OTHERS
     WHERE source_type = 2
       AND tax_type    = cp_tax_type
       AND source_register_id in ( SELECT register_id
                                     FROM JAI_CMN_RG_PLA_TRXS
                                    WHERE organization_id = p_organization_id
                                      AND location_id     = p_location_id
                                      AND fin_year        = cp_fin_year
                                      AND slno            = nvl(cp_slno,1) );

    CURSOR cur_get_final_cess_bal(cp_organization_id NUMBER,
                             cp_location_id     NUMBER,
                             cp_tax_type VARCHAR2) IS
    SELECT balance
      FROM JAI_CMN_RG_OTH_BALANCES
     WHERE org_unit_id   = ( SELECT org_unit_id
                             FROM JAI_CMN_INVENTORY_ORGS
                            WHERE organization_id = cp_organization_id
                              AND location_id     = cp_location_id )
       AND register_type = decode(p_register_type,'A','RG23A','C','RG23C',p_register_type)
       AND tax_type      = cp_tax_type;

    ln_rg23_cess_slno      NUMBER;
    ln_pla_cess_slno       NUMBER;
    ln_exc_cess_rg23       NUMBER;
    ln_cvd_cess_rg23       NUMBER;
    ln_sh_exc_cess_rg23    NUMBER;
    ln_sh_cvd_cess_rg23    NUMBER;
    ln_exc_cess_rg23_final NUMBER;
    ln_cvd_cess_rg23_final NUMBER;
    ln_sh_exc_cess_rg23_final NUMBER;
    ln_sh_cvd_cess_rg23_final NUMBER;
    ln_exc_cess_pla        NUMBER;
    ln_cvd_cess_pla        NUMBER;
    ln_sh_exc_cess_pla     NUMBER;
    ln_sh_cvd_cess_pla     NUMBER;
    ln_exc_cess_pla_final  NUMBER;
    ln_cvd_cess_pla_final  NUMBER;
    ln_sh_exc_cess_pla_final  NUMBER;
    ln_sh_cvd_cess_pla_final  NUMBER;
    ln_exc_cess_rg23_cr    NUMBER;
    ln_cvd_cess_rg23_cr    NUMBER;
    ln_sh_exc_cess_rg23_cr NUMBER;
    ln_sh_cvd_cess_rg23_cr NUMBER;
    ln_exc_cess_rg23_dr    NUMBER;
    ln_cvd_cess_rg23_dr    NUMBER;
    ln_sh_exc_cess_rg23_dr NUMBER;
    ln_sh_cvd_cess_rg23_dr NUMBER;
    ln_exc_cess_pla_cr     NUMBER;
    ln_cvd_cess_pla_cr     NUMBER;
    ln_sh_exc_cess_pla_cr  NUMBER;
		ln_sh_cvd_cess_pla_cr  NUMBER;
    ln_exc_cess_pla_dr     NUMBER;
    ln_cvd_cess_pla_dr     NUMBER;
		ln_sh_exc_cess_pla_dr  NUMBER;
    ln_sh_cvd_cess_pla_dr  NUMBER;

    ln_fin_year            NUMBER;

    ln_err_exists number ;
    lv_status                 varchar2(20) ;
    lv_exc_cess_status        varchar2(20) ;
    lv_cvd_cess_status        varchar2(20) ;
    lv_sh_exc_cess_status     varchar2(20) ;
    lv_sh_cvd_cess_status     varchar2(20) ;

    ln_open_bal number;
    ln_credit_amount number;
    ln_debit_amount  number;
    ln_slno_bal      number;
    ln_header        number ;

    ln_pla_cons_amt     number ;
    ln_pla_oth_amt      number ;
    ln_pla_slno         number ;
    ln_rg23_slno        number ;
    ln_rg23_finyr_bal   number ;
    ln_rg_slno_balance  number ;
    ln_rg_slno          number ;
    ln_slno             number ;

    pv_date  DATE DEFAULT fnd_date.canonical_to_date(p_date);

  BEGIN

    FND_FILE.put_line( FND_FILE.log, ' Process RG Trx Inputs. Organization Id:' || p_organization_id ||
                                     ' Location Id :   ' || p_location_id ||
                                     ' Register Type : ' || NVL(p_register_type,'ALL') ||
                                     ' p_date        : ' || pv_date          ||
                                     ' p_action      : ' || p_action        ||
                                     ' p_debug       : ' || p_debug         ||
                                     ' p_backup      : ' || p_backup ) ;

   FND_FILE.put_line( FND_FILE.log, '' ) ;
   FND_FILE.put_line( FND_FILE.log, '' ) ;

    retcode := 0 ;
    gd_date := to_date(pv_date,'DD/MM/RRRR') ;
    gn_action := p_action ;
    gn_exists := null ;

    if p_action = 3 and nvl(p_backup,'N') = 'N' then
      raise_application_error(-20054, ' Pls take a backup of the following tables from JA before you
                                        proceed with the fix : JAI_CMN_RG_23AC_II_TRXS,JAI_CMN_RG_PLA_TRXS ,JAI_CMN_RG_BALANCES ,JAI_CMN_RG_SLNOS ,JAI_CMN_RG_OTHERS ,JAI_CMN_RG_OTH_BALANCES ,JAI_CMN_RG_PERIOD_BALS' ) ;
    end if ;

    open c_check_addl_cvd ;
    fetch c_check_addl_cvd into gn_exists ;
    close c_check_addl_cvd ;

    if (p_register_type is null ) or (p_register_type IN ('A', 'C'))
    then
      -- To verify intra table data
      for rec in ( select
                    distinct organization_id, location_id, fin_year, register_type
                   from JAI_CMN_RG_23AC_II_TRXS
                   where
                     trunc(creation_date) >= pv_date and
                     register_type   = nvl(p_register_type, register_type) and
                     location_id     = nvl(p_location_id , location_id) and
                     organization_id = nvl(p_organization_id, organization_id)
                   order by register_type, organization_id, location_id, fin_year )
      loop

        -- call to validate records in JAI_CMN_RG_23AC_II_TRXS
        rg23_part_ii_validation(  p_organization_id    => rec.organization_id ,
                                  p_location_id        => rec.location_id ,
                                  p_fin_year           => rec.fin_year ,
                                  p_register_type      => rec.register_type
                         ) ;


      end loop ;

      -- To verify inter table data
      for rg23_bal_rec in (  select
                               distinct organization_id, location_id, register_type
                             from JAI_CMN_RG_23AC_II_TRXS
                             where
                               register_type   = nvl(p_register_type, register_type) and
                               organization_id = nvl(p_organization_id, organization_id) and
                               location_id     = nvl(p_location_id , location_id)        and
                               trunc(creation_date) >= pv_date
                             order by register_type, organization_id, location_id )
      loop

        validate_period_balances( p_organization_id  =>  rg23_bal_rec.organization_id,
                                  p_location_id      =>  rg23_bal_rec.location_id,
                                  p_register_type    =>  rg23_bal_rec.register_type,
                                  p_date             =>  pv_date
                                 ) ;

          -- call to validate cess info
          validate_rg_others
                        (    p_organization_id   =>  rg23_bal_rec.organization_id,
                             p_location_id       =>  rg23_bal_rec.location_id,
                             p_register_type     =>  rg23_bal_rec.register_type,
                             p_date              =>  pv_date
                        ) ;


        -- to fetch rg23 last record balance
        ln_rg23_balance := null ;
        ln_rg23_slno      := null ;
        open c_rg23_balance(rg23_bal_rec.organization_id,rg23_bal_rec.location_id, rg23_bal_rec.register_type) ;
        fetch c_rg23_balance into ln_rg23_balance,ln_rg23_slno ;
        close c_rg23_balance ;

        -- code to validate balance in JAI_CMN_RG_BALANCES
        ln_rg_balance  := null ;
        open c_rg_balance(rg23_bal_rec.organization_id,rg23_bal_rec.location_id, rg23_bal_rec.register_type) ;
        fetch c_rg_balance into ln_rg_balance ;
        close c_rg_balance ;

        if nvl(ln_rg_balance,0) <> nvl(ln_rg23_balance,0) then
          if gn_action =  3 then
            corr_final_bal( p_organization_id =>   rg23_bal_rec.organization_id   ,
                            p_location_id     =>   rg23_bal_rec.location_id       ,
                            p_register_type   =>   rg23_bal_rec.register_type     ,
                            p_tax_type        =>   NULL                  ,
                            p_closing_balance =>   ln_rg23_balance      );

          end if ;
           capture_error(  p_organization_id    =>   rg23_bal_rec.organization_id  ,
                           p_location_id        =>   rg23_bal_rec.location_id      ,
                           p_register_type      =>   rg23_bal_rec.register_type    ,
                           p_fin_year           =>   null                          ,
                           p_opening_balance    =>   null                          ,
                           p_error_codes        =>   'E13'                         ,
                           p_slno               =>   null                          ,
                           p_register_id        =>   null                          ,
                           p_rowcount           =>   null                          ,
                           p_tax_type           =>   null                          ,
                           p_date               =>   null                          ,
                           p_month              =>   null                          ,
                           p_year               =>   null
                          ) ;
        end if ;

       -- Code to Validate balance in JAI_CMN_RG_SLNOS
        ln_rg_slno_balance  := null ;
        ln_rg_slno          := null ;
        open c_rg_slno_balance(rg23_bal_rec.organization_id,rg23_bal_rec.location_id, rg23_bal_rec.register_type) ;
        fetch c_rg_slno_balance into ln_rg_slno_balance, ln_rg_slno;
        close c_rg_slno_balance ;

        if nvl(ln_rg23_balance,0) <> nvl(ln_rg_slno_balance,0) or (nvl(ln_rg23_slno,0) <> nvl(ln_rg_slno,0) ) then
          if gn_action =  3 then
            corr_final_bal( p_organization_id =>   rg23_bal_rec.organization_id   ,
                            p_location_id     =>   rg23_bal_rec.location_id       ,
                            p_register_type   =>   rg23_bal_rec.register_type     ,
                            p_tax_type        =>   NULL                  ,
                            p_closing_balance =>   ln_rg23_balance      );

            corr_final_slno( p_organization_id =>   rg23_bal_rec.organization_id   ,
                             p_location_id     =>   rg23_bal_rec.location_id       ,
                             p_register_type   =>   rg23_bal_rec.register_type     ,
                             p_slno            =>   ln_rg23_slno );
          end if ;
           capture_error(  p_organization_id    =>   rg23_bal_rec.organization_id  ,
                           p_location_id        =>   rg23_bal_rec.location_id      ,
                           p_register_type      =>   rg23_bal_rec.register_type    ,
                           p_fin_year           =>   null                          ,
                           p_opening_balance    =>   null                 ,
                           p_error_codes        =>   'E11'                ,
                           p_slno               =>   null                 ,
                           p_register_id        =>   null                 ,
                           p_rowcount           =>   null                 ,
                           p_tax_type           =>   null                 ,
                           p_date               =>   null                 ,
                           p_month              =>   null                 ,
                           p_year               =>   null
                          ) ;
        end if ;

      end loop ;
    end if ;

    if   (p_register_type is null ) or (p_register_type = 'PLA')
    then
      -- To verify intra table data
      for rec in ( select
                    distinct organization_id, location_id, fin_year
                   from JAI_CMN_RG_PLA_TRXS
                   where
                     trunc(creation_date) >= pv_date and
                     location_id     = nvl(p_location_id , location_id) and
                     organization_id = nvl(p_organization_id, organization_id)
                   order by organization_id, location_id, fin_year )
      loop

        pla_validation( p_organization_id    => rec.organization_id ,
                 p_location_id        => rec.location_id ,
                 p_fin_year           => rec.fin_year
               ) ;
      end loop ;

      -- To verify inter table data
      for pla_bal_rec in ( select
                             distinct organization_id, location_id
                           from JAI_CMN_RG_PLA_TRXS
                           where
                             organization_id = nvl(p_organization_id, organization_id) and
                             location_id     = nvl(p_location_id , location_id)         and
                             trunc(creation_date) >= pv_date
                           order by organization_id, location_id
                         )
      loop

        -- call to validate pla cess info
        validate_rg_others
                      (    p_organization_id   =>  pla_bal_rec.organization_id,
                           p_location_id       =>  pla_bal_rec.location_id,
                           p_register_type     =>  'PLA',
                           p_date              =>  pv_date
                      ) ;

        ln_pla_balance := null ;
        ln_pla_slno    := null ;
        open c_pla_balance(pla_bal_rec.organization_id,pla_bal_rec.location_id) ;
        fetch c_pla_balance into ln_pla_balance,ln_pla_slno ;
        close c_pla_balance ;

        ln_rg_balance  := null ;
        open c_rg_balance(pla_bal_rec.organization_id,pla_bal_rec.location_id, 'PLA') ;
        fetch c_rg_balance into ln_rg_balance ;
        close c_rg_balance ;

        if nvl(ln_rg_balance,0) <> nvl(ln_pla_balance,0) then
          if gn_action =  3 then
            corr_final_bal( p_organization_id =>   pla_bal_rec.organization_id   ,
                            p_location_id     =>   pla_bal_rec.location_id       ,
                            p_register_type   =>   'PLA'                         ,
                            p_tax_type        =>   NULL                          ,
                            p_closing_balance =>   ln_pla_balance                );
          end if ;

           capture_error(  p_organization_id    =>   pla_bal_rec.organization_id  ,
                           p_location_id        =>   pla_bal_rec.location_id      ,
                           p_register_type      =>   'PLA'                        ,
                           p_fin_year           =>   null                         ,
                           p_opening_balance    =>   null                         ,
                           p_error_codes        =>   'E14'                        ,
                           p_slno               =>   null                         ,
                           p_register_id        =>   null                         ,
                           p_rowcount           =>   null                         ,
                           p_tax_type           =>   null                         ,
                           p_date               =>   null                         ,
                           p_month              =>   null                         ,
                           p_year               =>   null
                          ) ;
        end if ;

        -- Code to Validate balance in JAI_CMN_RG_SLNOS
        ln_rg_slno_balance  := null ;
        ln_rg_slno          := null ;
        open c_rg_slno_balance(pla_bal_rec.organization_id,pla_bal_rec.location_id, 'PLA') ;
        fetch c_rg_slno_balance into ln_rg_slno_balance, ln_rg_slno;
        close c_rg_slno_balance ;

        if nvl(ln_pla_balance,0) <> nvl(ln_rg_slno_balance,0) or (nvl(ln_pla_slno,0) <> nvl(ln_rg_slno,0) ) then

          if gn_action =  3 then
            corr_final_bal( p_organization_id =>   pla_bal_rec.organization_id   ,
                           p_location_id     =>   pla_bal_rec.location_id       ,
                           p_register_type   =>   'PLA'                         ,
                           p_tax_type        =>   NULL                          ,
                           p_closing_balance =>   ln_pla_balance                );

            corr_final_slno( p_organization_id =>   pla_bal_rec.organization_id   ,
                           p_location_id     =>   pla_bal_rec.location_id       ,
                           p_register_type   =>   'PLA'                         ,
                           p_slno            =>   ln_pla_slno );
          end if ;


           capture_error(  p_organization_id    =>   pla_bal_rec.organization_id  ,
                           p_location_id        =>   pla_bal_rec.location_id      ,
                           p_register_type      =>   'PLA'                ,
                           p_fin_year           =>   null                 ,
                           p_opening_balance    =>   null                 ,
                           p_error_codes        =>   'E11'                ,
                           p_slno               =>   null                 ,
                           p_register_id        =>   null                 ,
                           p_rowcount           =>   null                 ,
                           p_tax_type           =>   null                 ,
                           p_date               =>   null                 ,
                           p_month              =>   null                 ,
                           p_year               =>   null
                          ) ;
        end if ;

        open cur_pla_trans_amt(pla_bal_rec.organization_id,pla_bal_rec.location_id) ;
        fetch cur_pla_trans_amt into ln_pla_trans_amt ;
        close cur_pla_trans_amt ;

        if nvl(ln_rg_balance,0) <> nvl(ln_pla_trans_amt,0) then
           capture_error(  p_organization_id    =>   pla_bal_rec.organization_id  ,
                           p_location_id        =>   pla_bal_rec.location_id      ,
                           p_register_type      =>   'PLA'                        ,
                           p_fin_year           =>   null                         ,
                           p_opening_balance    =>   null                         ,
                           p_error_codes        =>   'E15'                        ,
                           p_slno               =>   null                         ,
                           p_register_id        =>   null                         ,
                           p_rowcount           =>   null                         ,
                           p_tax_type           =>   null                         ,
                           p_date               =>   null                         ,
                           p_month              =>   null                         ,
                           p_year               =>   null
                          ) ;
        end if ;
      end loop ;

    end if ;

    -- check for consolidation
    if p_register_type is null
    then
      For cons_rec in ( select
                          distinct organization_id, location_id
                        from JAI_CMN_RG_23AC_II_TRXS
                        where
                          organization_id = nvl(p_organization_id, organization_id) and
                          location_id     = nvl(p_location_id , location_id)        and
                          trunc(creation_date) >= pv_date
                        order by organization_id, location_id
                      )
      loop

        For rg23_cons_rec in (  select
                                  sum(  nvl(dr_basic_ed,0) +nvl(dr_additional_ed,0) +nvl(dr_other_ed,0) ) rg23_cons_amt ,
                                  sum(other_tax_debit)  rg23_oth_amt,
                                  trunc(creation_date) cons_date
                                from JAI_CMN_RG_23AC_II_TRXS
                                where
                                  transaction_source_num is null and
                                  organization_id = cons_rec.organization_id and
                                  location_id     = cons_rec.location_id     and
                                  trunc(creation_date)   >=  pv_date
                                group by trunc(creation_date)
                              )
        loop
          open  pla_cons_amt(cons_rec.organization_id,cons_rec.location_id , rg23_cons_rec.cons_date) ;
          fetch pla_cons_amt into ln_pla_cons_amt, ln_pla_oth_amt ;
          close pla_cons_amt ;

          if nvl(ln_pla_cons_amt,0) <> nvl(rg23_cons_rec.rg23_cons_amt,0)
          then
           capture_error(  p_organization_id    =>   cons_rec.organization_id  ,
                           p_location_id        =>   cons_rec.location_id      ,
                           p_register_type      =>   null                        ,
                           p_fin_year           =>   null                         ,
                           p_opening_balance    =>   null                         ,
                           p_error_codes        =>   'E16'                        ,
                           p_slno               =>   null                         ,
                           p_register_id        =>   null                         ,
                           p_rowcount           =>   null                         ,
                           p_tax_type           =>   null                         ,
                           p_date               =>   rg23_cons_rec.cons_date      ,
                           p_month              =>   null                         ,
                           p_year               =>   null
                          ) ;
          end if ;

          if nvl(ln_pla_oth_amt,0) <> nvl(rg23_cons_rec.rg23_oth_amt,0)
          then
           capture_error(  p_organization_id    =>   cons_rec.organization_id  ,
                           p_location_id        =>   cons_rec.location_id      ,
                           p_register_type      =>   null                        ,
                           p_fin_year           =>   null                         ,
                           p_opening_balance    =>   null                         ,
                           p_error_codes        =>   'E16'                        ,
                           p_slno               =>   null                         ,
                           p_register_id        =>   null                         ,
                           p_rowcount           =>   null                         ,
                           p_tax_type           =>   null                         ,
                           p_date               =>   rg23_cons_rec.cons_date      ,
                           p_month              =>   null                         ,
                           p_year               =>   null
                          ) ;
          end if ;
        end loop ;
      end loop ;

    end if ;


    -- Code to populate the Log


    if (p_register_type is null ) or (p_register_type IN ('A', 'C'))
    then

      ln_header := 1 ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, '| Organization Id |' || ' Location Id |' ||  ' Register Type |' || '   Tax Type           |
                                        ' || ' Data State |'|| ' Opening Balance |' || 'Credit Amount |' || ' Debit Amount |' || ' Closing Bal(RG) |' || ' Closing Bal(RG Slno) |' || ' Closing Bal(Register) |' ) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '| --------------- |' || ' ----------- |' ||  ' ------------- |' || ' -------------------- |
      ' || '  ------    |'|| ' --------------- |' || '------------- |' || ' ------------ |' || ' --------------- |' || ' -------------------- |' || ' --------------------- |'  ) ;

      for rg23_log_rec in (  select
                               distinct organization_id, location_id, register_type
                             from JAI_CMN_RG_23AC_II_TRXS
                             where
                               register_type   = nvl(p_register_type, register_type) and
                               organization_id = nvl(p_organization_id, organization_id) and
                               location_id     = nvl(p_location_id , location_id)        and
                               trunc(creation_date) >= pv_date
                             order by organization_id, location_id, register_type )
      loop

      ln_open_bal      := null ;
      ln_credit_amount := null ;
      ln_debit_amount  := null ;
      ln_slno_bal      := null ;
      ln_rg23_balance  := null ;
      ln_rg_balance    := null ;
      lv_status        := null ;
      ln_err_exists    := null ;
      ln_rg23_slno     := null ;


      OPEN  cur_get_fin_year( rg23_log_rec.organization_id,pv_date ) ;
      FETCH cur_get_fin_year INTO ln_fin_year;
      CLOSE cur_get_fin_year;

      open c_get_rg23_open_bal(rg23_log_rec.organization_id, rg23_log_rec.location_id, rg23_log_rec.register_type, pv_date) ;
      fetch c_get_rg23_open_bal into ln_open_bal ;
      close c_get_rg23_open_bal ;

      if nvl(gn_exists,0) =1
      then
        execute immediate
        ' select
            sum(nvl(cr_basic_ed,0)+nvl(cr_additional_ed,0)+nvl(cr_other_ed,0) + nvl(cr_additional_cvd,0))  credit_amount ,
            sum(nvl(dr_basic_ed,0)+nvl(dr_additional_ed,0)+nvl(dr_other_ed,0) + nvl(dr_additional_cvd,0))  debit_amount
    from
           JAI_CMN_RG_23AC_II_TRXS
    where
           organization_id = ' || rg23_log_rec.organization_id || ' AND
           location_id     = ' || rg23_log_rec.location_id     || ' AND
           register_type   = ''' || rg23_log_rec.register_type   || ''' AND
           trunc(creation_date) >= ''' ||  pv_date || ''''
           into ln_credit_amount, ln_debit_amount ;
      else
        open c_get_rg23_tran_amt(rg23_log_rec.organization_id, rg23_log_rec.location_id, rg23_log_rec.register_type, pv_date) ;
        fetch c_get_rg23_tran_amt into ln_credit_amount, ln_debit_amount ;
        close c_get_rg23_tran_amt ;
      end if ;

        ln_rg23_cess_slno := NULL;
        OPEN cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year,'EXCISE_EDUCATION_CESS',pv_date);
        FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
        CLOSE cur_get_rg23_cess_slno;

        IF ln_rg23_cess_slno IS NULL THEN

          OPEN  cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year-1,'EXCISE_EDUCATION_CESS',pv_date);
          FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
          CLOSE cur_get_rg23_cess_slno;

          IF ln_rg23_cess_slno IS NULL THEN

            ln_exc_cess_rg23 := 0;

          ELSE

            OPEN get_rg23_cess_closing_bal(ln_fin_year-1,ln_rg23_cess_slno,'EXCISE_EDUCATION_CESS') ;
            FETCH get_rg23_cess_closing_bal INTO ln_exc_cess_rg23;
            CLOSE get_rg23_cess_closing_bal;

          END IF;

        ELSE

          OPEN get_rg23_cess_closing_bal(ln_fin_year,ln_rg23_cess_slno,'EXCISE_EDUCATION_CESS') ;
          FETCH get_rg23_cess_closing_bal INTO ln_exc_cess_rg23;
          CLOSE get_rg23_cess_closing_bal;

        END IF;

        OPEN cur_get_rg23_cess_trans(rg23_log_rec.organization_id,
                                     rg23_log_rec.location_id    ,
                                     pv_date                      ,
                                     'EXCISE_EDUCATION_CESS');
        FETCH cur_get_rg23_cess_trans INTO ln_exc_cess_rg23_cr,ln_exc_cess_rg23_dr;
        CLOSE cur_get_rg23_cess_trans;

        ln_rg23_cess_slno := NULL;
        OPEN cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year,'CVD_EDUCATION_CESS',pv_date);
        FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
        CLOSE cur_get_rg23_cess_slno;

        IF ln_rg23_cess_slno IS NULL THEN

          OPEN  cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year-1,'CVD_EDUCATION_CESS',pv_date);
          FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
          CLOSE cur_get_rg23_cess_slno;

          IF ln_rg23_cess_slno IS NULL THEN

            ln_cvd_cess_rg23 := 0;

          ELSE

            OPEN get_rg23_cess_closing_bal(ln_fin_year-1,ln_rg23_cess_slno,'CVD_EDUCATION_CESS') ;
            FETCH get_rg23_cess_closing_bal INTO ln_cvd_cess_rg23;
            CLOSE get_rg23_cess_closing_bal;

          END IF;

        ELSE

          OPEN get_rg23_cess_closing_bal(ln_fin_year,ln_rg23_cess_slno,'CVD_EDUCATION_CESS') ;
          FETCH get_rg23_cess_closing_bal INTO ln_cvd_cess_rg23;
          CLOSE get_rg23_cess_closing_bal;

        END IF;
        OPEN cur_get_rg23_cess_trans(rg23_log_rec.organization_id,
                                     rg23_log_rec.location_id    ,
                                     pv_date                      ,
                                     'CVD_EDUCATION_CESS');
        FETCH cur_get_rg23_cess_trans INTO ln_cvd_cess_rg23_cr,ln_cvd_cess_rg23_dr;
        CLOSE cur_get_rg23_cess_trans;


        ln_rg23_cess_slno := NULL;
        OPEN cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year,jai_constants.tax_type_sh_exc_edu_cess,pv_date);
        FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
        CLOSE cur_get_rg23_cess_slno;

        IF ln_rg23_cess_slno IS NULL THEN

          OPEN  cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year-1,jai_constants.tax_type_sh_exc_edu_cess,pv_date);
          FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
          CLOSE cur_get_rg23_cess_slno;

          IF ln_rg23_cess_slno IS NULL THEN

            ln_sh_exc_cess_rg23 := 0;

          ELSE

            OPEN get_rg23_cess_closing_bal(ln_fin_year-1,ln_rg23_cess_slno,jai_constants.tax_type_sh_exc_edu_cess) ;
            FETCH get_rg23_cess_closing_bal INTO ln_sh_exc_cess_rg23;
            CLOSE get_rg23_cess_closing_bal;

          END IF;

        ELSE

          OPEN get_rg23_cess_closing_bal(ln_fin_year,ln_rg23_cess_slno,jai_constants.tax_type_sh_exc_edu_cess) ;
          FETCH get_rg23_cess_closing_bal INTO ln_sh_exc_cess_rg23;
          CLOSE get_rg23_cess_closing_bal;

        END IF;

        OPEN cur_get_rg23_cess_trans(rg23_log_rec.organization_id,
                                     rg23_log_rec.location_id    ,
                                     pv_date                      ,
                                     jai_constants.tax_type_sh_exc_edu_cess);
        FETCH cur_get_rg23_cess_trans INTO ln_sh_exc_cess_rg23_cr,ln_sh_exc_cess_rg23_dr;
        CLOSE cur_get_rg23_cess_trans;

        ln_rg23_cess_slno := NULL;
        OPEN cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year,jai_constants.tax_type_sh_cvd_edu_cess,pv_date);
        FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
        CLOSE cur_get_rg23_cess_slno;

        IF ln_rg23_cess_slno IS NULL THEN

          OPEN  cur_get_rg23_cess_slno(rg23_log_rec.organization_id,rg23_log_rec.location_id,ln_fin_year-1,jai_constants.tax_type_sh_cvd_edu_cess,pv_date);
          FETCH cur_get_rg23_cess_slno INTO ln_rg23_cess_slno;
          CLOSE cur_get_rg23_cess_slno;

          IF ln_rg23_cess_slno IS NULL THEN

            ln_exc_cess_rg23 := 0;

          ELSE

            OPEN get_rg23_cess_closing_bal(ln_fin_year-1,ln_rg23_cess_slno,jai_constants.tax_type_sh_cvd_edu_cess) ;
            FETCH get_rg23_cess_closing_bal INTO ln_sh_cvd_cess_rg23;
            CLOSE get_rg23_cess_closing_bal;

          END IF;

        ELSE

          OPEN get_rg23_cess_closing_bal(ln_fin_year,ln_rg23_cess_slno,jai_constants.tax_type_sh_cvd_edu_cess) ;
          FETCH get_rg23_cess_closing_bal INTO ln_sh_cvd_cess_rg23;
          CLOSE get_rg23_cess_closing_bal;

        END IF;

        OPEN cur_get_rg23_cess_trans(rg23_log_rec.organization_id,
                                     rg23_log_rec.location_id    ,
                                     pv_date                      ,
                                     jai_constants.tax_type_sh_cvd_edu_cess);
        FETCH cur_get_rg23_cess_trans INTO ln_sh_cvd_cess_rg23_cr,ln_sh_cvd_cess_rg23_dr;
        CLOSE cur_get_rg23_cess_trans;


      if gn_action IN (1,3) then

        open c_rg_slno_bal(rg23_log_rec.organization_id, rg23_log_rec.location_id, rg23_log_rec.register_type) ;
        fetch c_rg_slno_bal into ln_slno_bal ;
        close c_rg_slno_bal ;

        open c_rg23_balance(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type) ;
        fetch c_rg23_balance into ln_rg23_balance, ln_rg23_slno ;
        close c_rg23_balance ;

        open c_rg_balance(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type) ;
        fetch c_rg_balance into ln_rg_balance ;
        close c_rg_balance ;

        OPEN  cur_get_final_cess_bal(rg23_log_rec.organization_id,rg23_log_rec.location_id,'EXCISE_EDUCATION_CESS');
        FETCH cur_get_final_cess_bal INTO ln_exc_cess_rg23_final;
        CLOSE cur_get_final_cess_bal;

        OPEN  cur_get_final_cess_bal(rg23_log_rec.organization_id,rg23_log_rec.location_id,'CVD_EDUCATION_CESS');
        FETCH cur_get_final_cess_bal INTO ln_cvd_cess_rg23_final;
        CLOSE cur_get_final_cess_bal;


        OPEN  cur_get_final_cess_bal(rg23_log_rec.organization_id,rg23_log_rec.location_id,jai_constants.tax_type_sh_exc_edu_cess);
        FETCH cur_get_final_cess_bal INTO ln_sh_exc_cess_rg23_final;
        CLOSE cur_get_final_cess_bal;

        OPEN  cur_get_final_cess_bal(rg23_log_rec.organization_id,rg23_log_rec.location_id,jai_constants.tax_type_sh_cvd_edu_cess);
        FETCH cur_get_final_cess_bal INTO ln_sh_cvd_cess_rg23_final;
        CLOSE cur_get_final_cess_bal;



        open c_err_exists(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type) ;
        fetch c_err_exists into ln_err_exists ;
        close c_err_exists ;

        if nvl(ln_err_exists,0) = 0 then
           lv_status := 'CONSISTENT' ;
        else
           lv_status := 'INCONSISTENT' ;
        end if ;
        ln_err_exists := NULL;

        open c_cess_err_exists(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type,'EXCISE_EDUCATION_CESS') ;
        fetch c_cess_err_exists into ln_err_exists ;
        close c_cess_err_exists ;

        if nvl(ln_err_exists,0) = 0 then
           lv_exc_cess_status := 'CONSISTENT' ;
        else
           lv_exc_cess_status := 'INCONSISTENT' ;
        end if ;
        ln_err_exists := NULL;

        open c_cess_err_exists(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type,'CVD_EDUCATION_CESS') ;
        fetch c_cess_err_exists into ln_err_exists ;
        close c_cess_err_exists ;

        if nvl(ln_err_exists,0) = 0 then
           lv_cvd_cess_status := 'CONSISTENT' ;
        else
           lv_cvd_cess_status := 'INCONSISTENT' ;
        end if ;

        ln_err_exists := NULL;

        open c_cess_err_exists(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type,jai_constants.tax_type_sh_exc_edu_cess) ;
        fetch c_cess_err_exists into ln_err_exists ;
        close c_cess_err_exists ;

        if nvl(ln_err_exists,0) = 0 then
           lv_sh_exc_cess_status := 'CONSISTENT' ;
        else
           lv_sh_exc_cess_status := 'INCONSISTENT' ;
        end if ;
        ln_err_exists := NULL;

        open c_cess_err_exists(rg23_log_rec.organization_id,rg23_log_rec.location_id, rg23_log_rec.register_type,jai_constants.tax_type_sh_cvd_edu_cess) ;
        fetch c_cess_err_exists into ln_err_exists ;
        close c_cess_err_exists ;

        if nvl(ln_err_exists,0) = 0 then
           lv_sh_cvd_cess_status := 'CONSISTENT' ;
        else
           lv_sh_cvd_cess_status := 'INCONSISTENT' ;
        end if ;

      elsif gn_action = 2 then
          ln_slno_bal     := nvl(ln_open_bal,0) + nvl(ln_credit_amount,0) - nvl(ln_debit_amount,0) ;
          ln_rg23_balance := ln_slno_bal ;
          ln_rg_balance   := ln_slno_bal ;
          ln_exc_cess_rg23_final := nvl(ln_exc_cess_rg23,0) + nvl(ln_exc_cess_rg23_cr,0) - nvl(ln_exc_cess_rg23_dr,0);
          ln_cvd_cess_rg23_final := nvl(ln_cvd_cess_rg23,0) + nvl(ln_cvd_cess_rg23_cr,0) - nvl(ln_cvd_cess_rg23_dr,0);
          lv_status             := 'CONSISTENT' ;
          lv_exc_cess_status    := 'CONSISTENT';
          lv_cvd_cess_status    := 'CONSISTENT';
          lv_sh_exc_cess_status := 'CONSISTENT';
          lv_sh_cvd_cess_status := 'CONSISTENT';
      end if ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(rg23_log_rec.organization_id, 17, ' ')|| '|' || RPAD(rg23_log_rec.location_id, 13, ' ') ||
        '|' || RPAD(rg23_log_rec.register_type, 15, ' ') || '|' || 'Excise                |'|| RPAD(lv_status, 12, ' ') || '|'|| RPAD(nvl(ln_open_bal,0), 17, ' ') || '|' || RPAD(nvl(ln_credit_amount,0), 14, ' ') || '|'
        || RPAD(nvl(ln_debit_amount,0), 14, ' ') || '|' || RPAD(nvl(ln_rg_balance,0), 17, ' ') || '|' || RPAD(nvl(ln_slno_bal,0), 22, ' ') || '|' ||  RPAD(nvl(ln_rg23_balance,0), 23, ' ') || '|' ) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(rg23_log_rec.organization_id, 17, ' ')|| '|' || RPAD(rg23_log_rec.location_id, 13, ' ') ||
        '|' || RPAD(rg23_log_rec.register_type, 15, ' ') || '|' || 'EXCISE_EDUCATION_CESS |'|| RPAD(lv_exc_cess_status, 12, ' ') || '|'||
        RPAD(nvl(ln_exc_cess_rg23,0), 17, ' ') || '|' || RPAD(nvl(ln_exc_cess_rg23_cr,0), 14, ' ') || '|' || RPAD(nvl(ln_exc_cess_rg23_dr,0), 14, ' ') ||
        '|' || RPAD(nvl(ln_exc_cess_rg23_final,0), 17, ' ') || '|' || '                      ' || '|' ||  '                       ' || '|'  ) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(rg23_log_rec.organization_id, 17, ' ')|| '|' || RPAD(rg23_log_rec.location_id, 13, ' ') || '|'
        || RPAD(rg23_log_rec.register_type, 15, ' ') || '|' || 'CVD_EDUCATION_CESS    |'|| RPAD(lv_cvd_cess_status, 12, ' ') || '|'|| RPAD(nvl(ln_cvd_cess_rg23,0), 17, ' ') || '|'
        || RPAD(nvl(ln_cvd_cess_rg23_cr,0), 14, ' ') || '|' || RPAD(nvl(ln_cvd_cess_rg23_dr,0), 14, ' ') || '|' || RPAD(nvl(ln_cvd_cess_rg23_final,0), 17, ' ') || '|'
        || '                      ' || '|' ||  '                       ' || '|'  ) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(rg23_log_rec.organization_id, 17, ' ')|| '|'
        || RPAD(rg23_log_rec.location_id, 13, ' ') || '|' || RPAD(rg23_log_rec.register_type, 15, ' ') || '|' || 'EXCISE_SH_EDU_CESS    |'
        || RPAD(lv_sh_exc_cess_status, 12, ' ') || '|'|| RPAD(nvl(ln_sh_exc_cess_rg23,0), 17, ' ') || '|' || RPAD(nvl(ln_sh_exc_cess_rg23_cr,0), 14, ' ') || '|' || RPAD(nvl(ln_sh_exc_cess_rg23_dr,0), 14, ' ') || '|'
        || RPAD(nvl(ln_sh_exc_cess_rg23_final,0), 17, ' ') || '|' || '                      ' || '|' ||  '                       ' || '|'  ) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(rg23_log_rec.organization_id, 17, ' ')|| '|' || RPAD(rg23_log_rec.location_id, 13, ' ') || '|' || RPAD(rg23_log_rec.register_type, 15, ' ')
        || '|' || 'CVD_SH_EDU_CESS       |'|| RPAD(lv_sh_cvd_cess_status, 12, ' ') || '|'|| RPAD(nvl(ln_sh_cvd_cess_rg23,0), 17, ' ') || '|' || RPAD(nvl(ln_sh_cvd_cess_rg23_cr,0), 14, ' ') || '|'
        || RPAD(nvl(ln_sh_cvd_cess_rg23_dr,0), 14, ' ') || '|' || RPAD(nvl(ln_sh_cvd_cess_rg23_final,0), 17, ' ') || '|' || '                      ' || '|'
        ||  '                       ' || '|'  ) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '----------------------------------------------------------------------
        -----------------------------------------------------------------------------------------
        -------------------------------------------------' ) ;
       end loop ;

   end if ;

   if   (p_register_type is null ) or (p_register_type = 'PLA')
   then

      if nvl(ln_header,0) = 0 then
        FND_FILE.PUT_LINE(FND_FILE.LOG, '| Organization Id |' || ' Location Id |' ||  ' Register Type |' || '     Tax Type        |'|| ' Data State |'|| ' Opening Balance |'
        || 'Credit Amount |' || ' Debit Amount |' || ' Closing Bal(RG) |' || ' Closing Bal(RG Slno) |' || ' Closing Bal(Register) |'  ) ;
        FND_FILE.PUT_LINE(FND_FILE.LOG, '| --------------- |' || ' ----------- |' ||  ' ------------- |' || ' --------------------|'|| '  ------    |'|| ' --------------- |'
        || '------------- |' || ' ------------ |' || ' --------------- |' || ' -------------------- |' || ' --------------------- |' ) ;
      end if ;

      for pla_log_rec in (  select
                               distinct organization_id, location_id
                             from JAI_CMN_RG_PLA_TRXS
                             where
                               organization_id = nvl(p_organization_id, organization_id) and
                               location_id     = nvl(p_location_id , location_id)        and
                               trunc(creation_date) >= pv_date
                             order by organization_id, location_id )
      loop

      ln_open_bal      := null ;
      ln_credit_amount := null ;
      ln_debit_amount  := null ;
      ln_slno_bal      := null ;
      ln_pla_balance   := null ;
      ln_rg_balance    := null ;
      lv_status        := null ;
      ln_err_exists    := null ;
      ln_pla_slno      := null ;

      OPEN  cur_get_fin_year( pla_log_rec.organization_id,pv_date ) ;
      FETCH cur_get_fin_year INTO ln_fin_year;
      CLOSE cur_get_fin_year;

      open c_get_pla_open_bal(pla_log_rec.organization_id, pla_log_rec.location_id, pv_date) ;
      fetch c_get_pla_open_bal into ln_open_bal ;
      close c_get_pla_open_bal ;

      open c_get_pla_tran_amt(pla_log_rec.organization_id, pla_log_rec.location_id, pv_date) ;
      fetch c_get_pla_tran_amt into ln_credit_amount, ln_debit_amount ;
      close c_get_pla_tran_amt ;

      ln_pla_cess_slno := NULL;
      OPEN cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year,'EXCISE_EDUCATION_CESS',pv_date);
      FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
      CLOSE cur_get_pla_cess_slno;

      IF ln_pla_cess_slno IS NULL THEN

        OPEN  cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year-1,'EXCISE_EDUCATION_CESS',pv_date);
        FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
        CLOSE cur_get_pla_cess_slno;

        IF ln_pla_cess_slno IS NULL THEN

          ln_exc_cess_pla := 0;

        ELSE

          OPEN get_pla_cess_closing_bal(ln_fin_year-1,ln_pla_cess_slno,'EXCISE_EDUCATION_CESS') ;
          FETCH get_pla_cess_closing_bal INTO ln_exc_cess_pla;
          CLOSE get_pla_cess_closing_bal;

        END IF;

      ELSE

        OPEN get_pla_cess_closing_bal(ln_fin_year,ln_pla_cess_slno,'EXCISE_EDUCATION_CESS') ;
        FETCH get_pla_cess_closing_bal INTO ln_exc_cess_pla;
        CLOSE get_pla_cess_closing_bal;

      END IF;

			OPEN cur_get_pla_cess_trans(pla_log_rec.organization_id,
																	 pla_log_rec.location_id    ,
																	 pv_date                      ,
																	 'EXCISE_EDUCATION_CESS');
			FETCH cur_get_pla_cess_trans INTO ln_exc_cess_pla_cr,ln_exc_cess_pla_dr;
			CLOSE cur_get_pla_cess_trans;

			ln_pla_cess_slno := NULL;
			OPEN cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year,'CVD_EDUCATION_CESS',pv_date);
			FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
			CLOSE cur_get_pla_cess_slno;

			IF ln_pla_cess_slno IS NULL THEN

				OPEN  cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year-1,'CVD_EDUCATION_CESS',pv_date);
				FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
				CLOSE cur_get_pla_cess_slno;

				IF ln_pla_cess_slno IS NULL THEN

					ln_cvd_cess_pla := 0;

				ELSE

					OPEN get_pla_cess_closing_bal(ln_fin_year-1,ln_pla_cess_slno,'CVD_EDUCATION_CESS') ;
					FETCH get_pla_cess_closing_bal INTO ln_cvd_cess_pla;
					CLOSE get_pla_cess_closing_bal;

				END IF;

      ELSE

				OPEN get_pla_cess_closing_bal(ln_fin_year,ln_pla_cess_slno,'CVD_EDUCATION_CESS') ;
				FETCH get_pla_cess_closing_bal INTO ln_cvd_cess_pla;
				CLOSE get_pla_cess_closing_bal;

			END IF;

			OPEN cur_get_pla_cess_trans(pla_log_rec.organization_id,
			 														pla_log_rec.location_id    ,
			 													  pv_date                      ,
																	'CVD_EDUCATION_CESS');
			FETCH cur_get_pla_cess_trans INTO ln_cvd_cess_pla_cr,ln_cvd_cess_pla_dr;
			CLOSE cur_get_pla_cess_trans;



      ln_pla_cess_slno := NULL;
      OPEN cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year,jai_constants.tax_type_sh_exc_edu_cess,pv_date);
      FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
      CLOSE cur_get_pla_cess_slno;

      IF ln_pla_cess_slno IS NULL THEN

        OPEN  cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year-1,jai_constants.tax_type_sh_exc_edu_cess,pv_date);
        FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
        CLOSE cur_get_pla_cess_slno;

        IF ln_pla_cess_slno IS NULL THEN

          ln_sh_exc_cess_pla := 0;

        ELSE

          OPEN get_pla_cess_closing_bal(ln_fin_year-1,ln_pla_cess_slno,jai_constants.tax_type_sh_exc_edu_cess) ;
          FETCH get_pla_cess_closing_bal INTO ln_sh_exc_cess_pla;
          CLOSE get_pla_cess_closing_bal;

        END IF;

      ELSE

        OPEN get_pla_cess_closing_bal(ln_fin_year,ln_pla_cess_slno,jai_constants.tax_type_sh_exc_edu_cess) ;
        FETCH get_pla_cess_closing_bal INTO ln_sh_exc_cess_pla;
        CLOSE get_pla_cess_closing_bal;

      END IF;

			OPEN cur_get_pla_cess_trans(pla_log_rec.organization_id,
																	 pla_log_rec.location_id    ,
																	 pv_date                      ,
																	 jai_constants.tax_type_sh_exc_edu_cess);
			FETCH cur_get_pla_cess_trans INTO ln_sh_exc_cess_pla_cr,ln_sh_exc_cess_pla_dr;
			CLOSE cur_get_pla_cess_trans;

			ln_pla_cess_slno := NULL;
			OPEN cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year,jai_constants.tax_type_sh_cvd_edu_cess,pv_date);
			FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
			CLOSE cur_get_pla_cess_slno;

			IF ln_pla_cess_slno IS NULL THEN

				OPEN  cur_get_pla_cess_slno(pla_log_rec.organization_id,pla_log_rec.location_id,ln_fin_year-1,jai_constants.tax_type_sh_cvd_edu_cess,pv_date);
				FETCH cur_get_pla_cess_slno INTO ln_pla_cess_slno;
				CLOSE cur_get_pla_cess_slno;

				IF ln_pla_cess_slno IS NULL THEN

					ln_sh_cvd_cess_pla := 0;

				ELSE

					OPEN get_pla_cess_closing_bal(ln_fin_year-1,ln_pla_cess_slno,jai_constants.tax_type_sh_cvd_edu_cess) ;
					FETCH get_pla_cess_closing_bal INTO ln_sh_cvd_cess_pla;
					CLOSE get_pla_cess_closing_bal;

				END IF;

      ELSE

				OPEN get_pla_cess_closing_bal(ln_fin_year,ln_pla_cess_slno,jai_constants.tax_type_sh_cvd_edu_cess) ;
				FETCH get_pla_cess_closing_bal INTO ln_sh_cvd_cess_pla;
				CLOSE get_pla_cess_closing_bal;

			END IF;

			OPEN cur_get_pla_cess_trans(pla_log_rec.organization_id,
			 														pla_log_rec.location_id    ,
			 													  pv_date                      ,
																	jai_constants.tax_type_sh_cvd_edu_cess);
			FETCH cur_get_pla_cess_trans INTO ln_sh_cvd_cess_pla_cr,ln_sh_cvd_cess_pla_dr;
			CLOSE cur_get_pla_cess_trans;



			if gn_action IN (1,3) then
				open c_rg_slno_bal(pla_log_rec.organization_id, pla_log_rec.location_id, 'PLA') ;
				fetch c_rg_slno_bal into ln_slno_bal ;
				close c_rg_slno_bal ;

				open c_pla_balance(pla_log_rec.organization_id,pla_log_rec.location_id) ;
				fetch c_pla_balance into ln_pla_balance, ln_pla_slno ;
				close c_pla_balance ;

				open c_rg_balance(pla_log_rec.organization_id,pla_log_rec.location_id, 'PLA') ;
				fetch c_rg_balance into ln_rg_balance ;
				close c_rg_balance ;

				OPEN  cur_get_final_cess_bal(pla_log_rec.organization_id,pla_log_rec.location_id,'EXCISE_EDUCATION_CESS');
				FETCH cur_get_final_cess_bal INTO ln_exc_cess_pla_final;
				CLOSE cur_get_final_cess_bal;

				OPEN  cur_get_final_cess_bal(pla_log_rec.organization_id,pla_log_rec.location_id,'CVD_EDUCATION_CESS');
				FETCH cur_get_final_cess_bal INTO ln_cvd_cess_pla_final;
				CLOSE cur_get_final_cess_bal;



				OPEN  cur_get_final_cess_bal(pla_log_rec.organization_id,pla_log_rec.location_id,jai_constants.tax_type_sh_exc_edu_cess);
				FETCH cur_get_final_cess_bal INTO ln_sh_exc_cess_pla_final;
				CLOSE cur_get_final_cess_bal;

				OPEN  cur_get_final_cess_bal(pla_log_rec.organization_id,pla_log_rec.location_id,jai_constants.tax_type_sh_cvd_edu_cess);
				FETCH cur_get_final_cess_bal INTO ln_sh_cvd_cess_pla_final;
				CLOSE cur_get_final_cess_bal;



				open c_err_exists(pla_log_rec.organization_id,pla_log_rec.location_id, 'PLA') ;
				fetch c_err_exists into ln_err_exists ;
				close c_err_exists ;

				if nvl(ln_err_exists,0) = 0 then
					 lv_status := 'CONSISTENT' ;
				else
					 lv_status := 'INCONSISTENT' ;
				end if ;
				ln_err_exists := NULL;

				open c_cess_err_exists(pla_log_rec.organization_id,pla_log_rec.location_id, 'PLA','EXCISE_EDUCATION_CESS') ;
				fetch c_cess_err_exists into ln_err_exists ;
				close c_cess_err_exists ;

				if nvl(ln_err_exists,0) = 0 then
					 lv_exc_cess_status := 'CONSISTENT' ;
				else
					 lv_exc_cess_status := 'INCONSISTENT' ;
				end if ;
				ln_err_exists := NULL;

				open c_cess_err_exists(pla_log_rec.organization_id,pla_log_rec.location_id, 'PLA','CVD_EDUCATION_CESS') ;
				fetch c_cess_err_exists into ln_err_exists ;
				close c_cess_err_exists ;

				if nvl(ln_err_exists,0) = 0 then
					 lv_cvd_cess_status := 'CONSISTENT' ;
				else
					 lv_cvd_cess_status := 'INCONSISTENT' ;
				end if ;



				ln_err_exists := NULL;

				open c_cess_err_exists(pla_log_rec.organization_id,pla_log_rec.location_id, 'PLA',jai_constants.tax_type_sh_exc_edu_cess) ;
				fetch c_cess_err_exists into ln_err_exists ;
				close c_cess_err_exists ;

				if nvl(ln_err_exists,0) = 0 then
					 lv_sh_exc_cess_status := 'CONSISTENT' ;
				else
					 lv_sh_exc_cess_status := 'INCONSISTENT' ;
				end if ;
				ln_err_exists := NULL;

				open c_cess_err_exists(pla_log_rec.organization_id,pla_log_rec.location_id, 'PLA',jai_constants.tax_type_sh_cvd_edu_cess) ;
				fetch c_cess_err_exists into ln_err_exists ;
				close c_cess_err_exists ;

				if nvl(ln_err_exists,0) = 0 then
					 lv_sh_cvd_cess_status := 'CONSISTENT' ;
				else
					 lv_sh_cvd_cess_status := 'INCONSISTENT' ;
				end if ;



      elsif gn_action = 2 then
          ln_slno_bal           := nvl(ln_open_bal,0) + nvl(ln_credit_amount,0) - nvl(ln_debit_amount,0) ;
          ln_exc_cess_pla_final := nvl(ln_exc_cess_pla,0) + nvl(ln_exc_cess_pla_cr,0) - nvl(ln_exc_cess_pla_dr,0);
          ln_cvd_cess_pla_final := nvl(ln_cvd_cess_pla,0) + nvl(ln_cvd_cess_pla_cr,0) - nvl(ln_cvd_cess_pla_dr,0);
          ln_pla_balance        := ln_slno_bal ;
          ln_rg_balance         := ln_slno_bal ;
          lv_status             := 'CONSISTENT' ;
          lv_exc_cess_status    := 'CONSISTENT';
          lv_cvd_cess_status    := 'CONSISTENT';
          lv_sh_exc_cess_status := 'CONSISTENT';
          lv_sh_cvd_cess_status := 'CONSISTENT';

      end if ;


      FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(pla_log_rec.organization_id, 17, ' ')||  '|' || RPAD(pla_log_rec.location_id, 13, ' ') || '|' || RPAD('PLA', 15, ' ') || '|' || 'Excise                |'
      || RPAD(lv_status, 12, ' ') || '|' || RPAD(nvl(ln_open_bal,0), 17, ' ') || '|' || RPAD(nvl(ln_credit_amount,0), 14, ' ') || '|' || RPAD(nvl(ln_debit_amount,0), 14, ' ') || '|' || RPAD(nvl(ln_rg_balance,0), 17, ' ') || '|'
      || RPAD(nvl(ln_slno_bal,0), 22, ' ') || '|' ||  RPAD(nvl(ln_pla_balance,0) , 23, ' ') || '|' ) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(pla_log_rec.organization_id, 17, ' ')|| '|' || RPAD(pla_log_rec.location_id, 13, ' ') || '|'  || RPAD('PLA', 15, ' ') || '|' || 'EXCISE_EDUCATION_CESS |'
      || RPAD(lv_exc_cess_status, 12, ' ') || '|'|| RPAD(nvl(ln_exc_cess_pla,0), 17, ' ') || '|' || RPAD(nvl(ln_exc_cess_pla_cr,0), 14, ' ') || '|' || RPAD(nvl(ln_exc_cess_pla_dr,0), 14, ' ') || '|'
      || RPAD(nvl(ln_exc_cess_pla_final,0), 17, ' ') || '|' || '                      ' || '|' ||  '                       ' || '|'  ) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(pla_log_rec.organization_id, 17, ' ')
      || '|' || RPAD(pla_log_rec.location_id, 13, ' ') || '|'  || RPAD('PLA', 15, ' ')
      || '|' || 'CVD_EDUCATION_CESS    |'|| RPAD(lv_cvd_cess_status, 12, ' ') || '|'
      || RPAD(nvl(ln_cvd_cess_pla,0), 17, ' ') || '|'
      || RPAD(nvl(ln_cvd_cess_pla_cr,0), 14, ' ') ||
      '|' || RPAD(nvl(ln_cvd_cess_pla_dr,0), 14, ' ') || '|' || RPAD(nvl(ln_cvd_cess_pla_final,0), 17, ' ') || '|' || '                      ' || '|' ||  '                       ' || '|'  ) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(pla_log_rec.organization_id, 17, ' ')|| '|'
      || RPAD(pla_log_rec.location_id, 13, ' ') || '|'  || RPAD('PLA', 15, ' ') || '|' || 'EXCISE_SH_EDU_CESS    |'|| RPAD(lv_sh_exc_cess_status, 12, ' ') || '|'
      || RPAD(nvl(ln_sh_exc_cess_pla,0), 17, ' ') || '|' || RPAD(nvl(ln_sh_exc_cess_pla_cr,0), 14, ' ') || '|' || RPAD(nvl(ln_sh_exc_cess_pla_dr,0), 14, ' ') ||
      '|' || RPAD(nvl(ln_sh_exc_cess_pla_final,0), 17, ' ') || '|' || '                      ' || '|' ||  '                       ' || '|'  ) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(pla_log_rec.organization_id, 17, ' ')|| '|'
      || RPAD(pla_log_rec.location_id, 13, ' ') || '|'  || RPAD('PLA', 15, ' ') || '|' || 'CVD_SH_EDU_CESS       |'|| RPAD(lv_sh_cvd_cess_status, 12, ' ') || '|'|| RPAD(nvl(ln_sh_cvd_cess_pla,0), 17, ' ') || '|'
      || RPAD(nvl(ln_sh_cvd_cess_pla_cr,0), 14, ' ') || '|' || RPAD(nvl(ln_sh_cvd_cess_pla_dr,0), 14, ' ') || '|' ||
      RPAD(nvl(ln_sh_cvd_cess_pla_final,0), 17, ' ') || '|' || '                      ' || '|' ||  '                       ' || '|'  ) ;
      FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------' ) ;

      end loop ;

   end if ;

   if NVL(p_debug, 'N') = 'Y'
   then

     FND_FILE.PUT_LINE(FND_FILE.LOG, '') ;
     FND_FILE.PUT_LINE(FND_FILE.LOG, '') ;

     FND_FILE.PUT_LINE(FND_FILE.LOG, '| Organization Id |' || ' Location Id |' ||  ' Register Type |' || ' Fin Year |' || 'Error |' || '  Slno  |' || ' Register Id |'
     || ' RowCount |' || '       Tax Type        |' || '   Date   |' || ' Month ' || ' Year '  ) ;
     FND_FILE.PUT_LINE(FND_FILE.LOG, '| --------------- |' || ' ----------- |' ||  ' ------------- |' || ' -------- |' || '----- |' || ' ------ |' || ' ----------- |'
     || ' -------- |' || '       --------        |' || ' -------- |' || ' ----- ' || ' ---- '  ) ;


     for rec in ( select * from JAI_TRX_GT)
     loop

       FND_FILE.PUT_LINE(FND_FILE.LOG, '|' || RPAD(nvl(to_char(rec.JAI_INFO_N1),' '), 17, ' ')|| '|' || RPAD(nvl(to_char(rec.JAI_INFO_N2),' '), 13, ' ') || '|'
       || RPAD(nvl(rec.JAI_INFO_V1,' '), 15, ' ') || '|' || RPAD(nvl(to_char(rec.JAI_INFO_N3),' '), 10, ' ') || '|' || RPAD(nvl(rec.JAI_INFO_V3,' '), 6, ' ') || '|' || RPAD(nvl(to_char(rec.JAI_INFO_N8),' '), 8, ' ')
       || '|' || RPAD(nvl(to_char(rec.JAI_INFO_N9),' '), 13, ' ') || '|' || RPAD(nvl(to_char(rec.JAI_INFO_N10),' '), 10, ' ') || '|'
       ||  RPAD(nvl(rec.JAI_INFO_V4,' '), 23, ' ') || '|' || RPAD(nvl(to_char(rec.JAI_INFO_D1),' '), 10, ' ') || '|' || RPAD(nvl(rec.JAI_INFO_V5,' '), 7, ' ') || '|'
       || RPAD(nvl(to_char(rec.JAI_INFO_N11),' '), 6, ' ')  ) ;

     end loop ;

     FND_FILE.PUT_LINE(FND_FILE.LOG, '') ;
     FND_FILE.PUT_LINE(FND_FILE.LOG, '') ;

     FND_FILE.PUT_LINE(FND_FILE.LOG, ' Error Code Information ' ) ;
     FND_FILE.PUT_LINE(FND_FILE.LOG, ' ---------------------- ' ) ;


      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E01 : Total transaction amount does not equal the Period balance for the MON and Year           ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E02 : RG23 Opening Balance is not equal to closing balance of previous record                   ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E03 : RG23 Closing Balance is not equal to opening balance + Transaction Amount                 ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E04 : PLA Opening Balance is not equal to closing balance of previous record                    ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E05 : PLA Closing Balance is not equal to opening balance + Transaction Amount                  ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E06 : Final balance in JAI_RG_OTH_BALANCE is not equal to Closing Balance of the last record    ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E07 : PLA Duplicate Slno                                                                        ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E08 : JAI_CMN_RG_OTHERS Closing Balance is not equal to Opening Balance + Transaction Amount        ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E09 : RG23 Other Tax Credit/Debit is not equal to the sum of credit/debit in JAI_CMN_RG_OTHERS      ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E10 : PLA  Other Tax Credit/Debit is not equal to the sum of credit/debit in JAI_CMN_RG_OTHERS      ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E11 : RG23 Balance, Slno do not match with JAI_CMN_RG_SLNOS Balance,Slno                           ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E12 : PLA  Balance, Slno do not match with JAI_CMN_RG_SLNOS Balance,Slno                           ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E13 : RG23 Last record Balance does not match with the balance in JAI_CMN_RG_BALANCES             ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E14 : PLA  Last record Balance does not match with the balance in JAI_CMN_RG_BALANCES             ' ) ;

      if gn_action = 1 then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'E15 : PLA  Total Transaction amount  does not match with the balance in JAI_CMN_RG_BALANCES       ' ) ;
      elsif gn_action = 3 then
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'E15 : PLA  Total Transaction amount  does not match with the balance in JAI_CMN_RG_BALANCES. Manual Intervention is required. ' ) ;
      end if ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E16 : The Consolidation Amount for rg23 and pla do not match                                    ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E17 : The Other Tax Consolidation Amount for rg23 and pla do not match                          ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E18 : RG23 Duplicate Slno                                                                       ' ) ;

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'E19 : JAI_CMN_RG_OTHERS Opening Balance is not equal to the  closing balance of the previous record ' ) ;

   end if ;

  exception
    when others then
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : ' || SQLERRM ) ;
     retcode := 2 ;

  END process_rg_trx;
  -----------------------------------------PROCESS_RG_TRX--------------------------------

END jai_excise_scripts_pkg ;

/
