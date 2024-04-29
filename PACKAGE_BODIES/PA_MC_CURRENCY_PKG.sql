--------------------------------------------------------
--  DDL for Package Body PA_MC_CURRENCY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_MC_CURRENCY_PKG" AS
--$Header: PAXMCURB.pls 120.5 2007/12/26 09:34:19 hkansal ship $


    FUNCTION CurrRound( x_amount        IN NUMBER ,
                        x_currency_code IN VARCHAR2 := FunctionalCurrency )
    RETURN NUMBER
    IS
      l_mau           fnd_currencies.minimum_accountable_unit%TYPE;
      l_precision     fnd_currencies.precision%TYPE;

    BEGIN

       SELECT  precision,
               minimum_accountable_unit
       INTO    l_precision,
               l_mau
       FROM    fnd_currencies
       WHERE   currency_code = x_currency_code;

    IF l_mau IS NOT NULL THEN

       IF l_mau < 0.00001 THEN
         RETURN( round(x_amount, 5));
       ELSE
         RETURN( round(x_amount/l_mau) * l_mau );
       END IF;

    ELSIF l_precision IS NOT NULL THEN

       IF l_precision > 5 THEN
         RETURN( round(x_amount, 5));
       ELSE
         RETURN( round(x_amount, l_precision));
       END IF;

    ELSE
         RETURN( round(x_amount, 5));

    END IF;
   EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END CurrRound;
-------------------------------------------------------------

FUNCTION functional_currency(x_org_id IN  NUMBER) RETURN VARCHAR2
IS
currency VARCHAR2(30);
BEGIN

   IF (x_org_id = G_PREV_ORG_ID) THEN

       RETURN (G_PREV_CURRENCY);
   ELSE

      G_PREV_ORG_ID := x_org_id;

      SELECT  gl.currency_code
        INTO    currency
        FROM    gl_sets_of_books gl,
             pa_implementations_all i
       -- WHERE    NVL(i.org_id,-99) = NVL(x_org_id,-99)
	   WHERE   i.org_id  = x_org_id  -- x_org_id also taken from Implementation table.
         AND    i.set_of_books_id = gl.set_of_books_id;

       G_PREV_CURRENCY := currency;
       RETURN (currency);

   END IF;

EXCEPTION WHEN OTHERS THEN
   G_PREV_ORG_ID   := x_org_id;
   G_PREV_CURRENCY := NULL;
   RAISE;

END functional_currency;

-------------------------------------------------------------

FUNCTION set_of_books(x_org_id  IN NUMBER) RETURN NUMBER
IS
sob_id NUMBER;

BEGIN

   IF (x_org_id = G_PREV_ORG_ID2) THEN

      RETURN (G_PREV_SOB_ID);
   ELSE

      G_PREV_ORG_ID2 := x_org_id;

      SELECT set_of_books_id
        INTO sob_id
        FROM pa_implementations_all i
       -- WHERE NVL(i.org_id,-99) = NVL(x_org_id,-99);
       where    i.org_id  = x_org_id ;

      G_PREV_SOB_ID := sob_id;
      RETURN sob_id;

   END IF;

EXCEPTION WHEN OTHERS THEN
  G_PREV_ORG_ID2:= x_org_id;
  G_PREV_SOB_ID := NULL;
  RAISE;

END set_of_books;

-------------------------------------------------------------
FUNCTION  set_of_books RETURN NUMBER
IS
sob_id NUMBER;

	/* This function returns SOB id from pa_implementations
	   Hence, no Org info needed                           */

BEGIN

 SELECT set_of_books_id
 INTO   sob_id
 FROM   pa_implementations;

 RETURN sob_id;

EXCEPTION WHEN OTHERS THEN
  RAISE;

END set_of_books;

-------------------------------------------------------------
FUNCTION  get_mrc_sob_type_code( x_set_of_books_id IN NUMBER )
                                RETURN VARCHAR2
IS
sob_type VARCHAR2(1);
	/* Returns MRC_SOB_TYPE_CODE for the given SOB */

BEGIN

 SELECT mrc_sob_type_code
 INTO   sob_type
 FROM   gl_sets_of_books gl
 WHERE  gl.set_of_books_id = x_set_of_books_id;

 RETURN sob_type;

EXCEPTION WHEN OTHERS THEN
  RAISE;

END get_mrc_sob_type_code;
-------------------------------------------------------------
FUNCTION  get_mrc_sob_type_code RETURN VARCHAR2
IS
sob_type VARCHAR2(1);
	/* Returns MRC_SOB_TYPE_CODE for the SOB from
	   PA_Implementations                         */

BEGIN
 SELECT mrc_sob_type_code
 INTO   sob_type
 FROM   gl_sets_of_books gl,
        pa_implementations imp
 WHERE  gl.set_of_books_id = imp.set_of_books_id;

 RETURN sob_type;

EXCEPTION WHEN OTHERS THEN
  RAISE;

END get_mrc_sob_type_code;

-------------------------------------------------------------
PROCEDURE eiid_details( x_eiid          IN  NUMBER,
                        x_orig_trx      OUT NOCOPY VARCHAR2,
                        x_adj_item      OUT NOCOPY NUMBER,
                        x_linkage       OUT NOCOPY VARCHAR2,
                        x_ei_date       OUT NOCOPY DATE,
--Bug#1078399
--New parameter x_txn_source added in eiid_details() - to be used to
--check whether the EI is an imported-one or not.
                        x_txn_source    OUT NOCOPY VARCHAR2,
                        x_err_stack     IN OUT NOCOPY VARCHAR2,
                        x_err_stage     IN OUT NOCOPY VARCHAR2,
                        x_err_code      OUT NOCOPY NUMBER)

IS
l_old_stack            VARCHAR2(2000);


BEGIN
    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.eiid_details';
    x_err_stage := ' Select from pa_expenditure_items_all';

 SELECT     eia.orig_transaction_reference,
            nvl(eia.adjusted_expenditure_item_id, transferred_from_exp_item_id),
            eia.system_linkage_function,
            eia.expenditure_item_date,
--Bug#1078399
--New parameter x_txn_source added in eiid_details() - to be used to
--check whether the EI is an imported-one or not.
            eia.transaction_source
 INTO       x_orig_trx,
            x_adj_item,
            x_linkage,
            x_ei_date,
--Bug#1078399
            x_txn_source
 FROM       pa_expenditure_items_all eia
 WHERE      eia.expenditure_item_id = x_eiid;

   x_err_stack := l_old_stack;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_err_code := SQLCODE;
      x_orig_trx := Null;
      x_adj_item := Null;
      x_linkage := Null;
      x_ei_date := NUll;
      x_txn_source := Null;
   WHEN OTHERS THEN
      x_orig_trx := Null;
      x_adj_item := Null;
      x_linkage := Null;
      x_ei_date := NUll;
      x_txn_source := Null;
      RAISE;

END eiid_details;

-------------------------------------------------------------
PROCEDURE eiid_details( x_eiid          IN NUMBER,
                        x_orig_trx      OUT NOCOPY VARCHAR2,
                        x_adj_item      OUT NOCOPY NUMBER,
                        x_linkage       OUT NOCOPY VARCHAR2,
                        x_ei_date       OUT NOCOPY DATE,
                        x_err_stack     IN OUT NOCOPY VARCHAR2,
                        x_err_stage     IN OUT NOCOPY VARCHAR2,
                        x_err_code      OUT NOCOPY NUMBER)

IS
l_old_stack            VARCHAR2(2000);


BEGIN
    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.eiid_details';
    x_err_stage := ' Select from pa_expenditure_items_all';

 SELECT     eia.orig_transaction_reference,
            nvl(eia.adjusted_expenditure_item_id, transferred_from_exp_item_id),
            eia.system_linkage_function,
            eia.expenditure_item_date
 INTO       x_orig_trx,
            x_adj_item,
            x_linkage,
            x_ei_date
 FROM       pa_expenditure_items_all eia
 WHERE      eia.expenditure_item_id = x_eiid;

   x_err_stack := l_old_stack;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_err_code := SQLCODE;
      x_orig_trx := Null;
      x_adj_item := Null;
      x_linkage := Null;
      x_ei_date := NUll;
   WHEN OTHERS THEN
      x_orig_trx := Null;
      x_adj_item := Null;
      x_linkage := Null;
      x_ei_date := NUll;
      RAISE;

END eiid_details;

-------------------------------------------------------------

FUNCTION max_cost_line ( x_eiid    IN  NUMBER,
                         x_sob      IN  NUMBER) RETURN NUMBER IS

out_line NUMBER;

BEGIN

   SELECT max(line_num)
   INTO    out_line
   FROM    pa_mc_cost_dist_lines_all
   WHERE  expenditure_item_id = x_eiid
   AND    set_of_books_id = x_sob
   AND    line_type||'' = 'R';

RETURN out_line;

EXCEPTION WHEN OTHERS THEN
 RAISE ;
END max_cost_line;

-------------------------------------------------------------

FUNCTION max_rev_line(x_eiid IN    NUMBER,
                      x_sob  IN    NUMBER) RETURN NUMBER IS

out_line NUMBER;

BEGIN

   SELECT max(line_num)
   INTO    out_line
   FROM    pa_mc_cust_rdl_all
   WHERE  expenditure_item_id = x_eiid
   AND    set_of_books_id = x_sob;


RETURN out_line;

EXCEPTION WHEN OTHERS THEN
 RAISE;
END max_rev_line;

-------------------------------------------------------------

PROCEDURE get_orig_cost_rates( x_adj_item            IN NUMBER,
                               x_line_num            IN NUMBER,
                               x_set_of_books_id     IN NUMBER,
                               x_exchange_rate       OUT NOCOPY NUMBER,
                               x_exchange_date       OUT NOCOPY DATE,
                               x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                               x_err_stack           IN OUT NOCOPY VARCHAR2,
                               x_err_stage           IN OUT NOCOPY VARCHAR2,
                               x_err_code            OUT NOCOPY NUMBER)
IS
l_old_stack            VARCHAR2(2000);


BEGIN
    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_orig_cost_rates';
    x_err_stage := ' Select from pa_mc_cost_dist_lines_all';

    SELECT exchange_rate,
           conversion_date,
           rate_type
    INTO   x_exchange_rate,
           x_exchange_date,
           x_exchange_rate_type
    FROM   pa_mc_cost_dist_lines_all
    WHERE  expenditure_item_id = x_adj_item
    AND    line_num = x_line_num
    AND    set_of_books_id = x_set_of_books_id;

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_code := SQLCODE;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
  WHEN OTHERS THEN
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     RAISE;

END get_orig_cost_rates;

PROCEDURE get_orig_ei_cost_rates( x_exp_item_id      IN NUMBER,
                               x_set_of_books_id     IN NUMBER,
                               x_exchange_rate       OUT NOCOPY NUMBER,
                               x_exchange_date       OUT NOCOPY DATE,
                               x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                               x_err_stack           IN OUT NOCOPY VARCHAR2,
                               x_err_stage           IN OUT NOCOPY VARCHAR2,
                               x_err_code            OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_orig_ei_cost_rates';
    x_err_stage := ' Select from pa_mc_exp_items_all';

    SELECT cost_exchange_rate,
           cost_conversion_date,
           cost_rate_type
    INTO   x_exchange_rate,
           x_exchange_date,
           x_exchange_rate_type
    FROM   pa_mc_exp_items_all
    WHERE  expenditure_item_id = x_exp_item_id
    AND    set_of_books_id = x_set_of_books_id;

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_code := SQLCODE;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
  WHEN OTHERS THEN
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     RAISE;

END get_orig_ei_cost_rates;

-------------------------------------------------------------

PROCEDURE get_cost_amts(x_exp_item_id         IN NUMBER,
                        x_set_of_books_id     IN NUMBER,
                        x_line_num            IN NUMBER,
                        x_amount              OUT NOCOPY NUMBER,
                        x_quantity            OUT NOCOPY NUMBER,
			            x_exchange_rate	      OUT NOCOPY NUMBER,
			            x_exchange_date	      OUT NOCOPY DATE,
			            x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                        x_err_stack           IN OUT NOCOPY VARCHAR2,
                        x_err_stage           IN OUT NOCOPY VARCHAR2,
                        x_err_code            OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_cost_amts';
    x_err_stage := ' Select from pa_mc_cost_dist_lines_all';

    SELECT amount,
           quantity,
	   exchange_rate,
	   conversion_date,
	   rate_type
    INTO   x_amount,
           x_quantity,
	   x_exchange_rate,
	   x_exchange_date,
	   x_exchange_rate_type
    FROM   pa_mc_cost_dist_lines_all
    WHERE  expenditure_item_id = x_exp_item_id
    AND    line_num   = x_line_num
    AND    set_of_books_id = x_set_of_books_id;

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_code := SQLCODE;
     x_amount := Null;
     x_quantity := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
  WHEN OTHERS THEN
     x_amount := Null;
     x_quantity := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     RAISE;

END get_cost_amts;
-------------------------------------------------------------
PROCEDURE get_max_cost_amts(x_exp_item_id         IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_raw_cost            OUT NOCOPY NUMBER,
                            x_burdened_cost       OUT NOCOPY NUMBER,
                            x_exchange_rate	      OUT NOCOPY NUMBER,
                            x_exchange_date	      OUT NOCOPY DATE,
                            x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_max_cost_amts';
    x_err_stage := ' Select from pa_mc_cost_dist_lines_all';
    x_raw_cost := NULL;
    x_burdened_cost := NULL;

    SELECT amount,
           NVL(burdened_cost,0),
           NVL(exchange_rate,0),
           conversion_date,
           rate_type
    INTO   x_raw_cost,
           x_burdened_cost,
           x_exchange_rate,
           x_exchange_date,
           x_exchange_rate_type
    FROM   pa_mc_cost_dist_lines_all
    WHERE  set_of_books_id = x_set_of_books_id
    AND    expenditure_item_id = x_exp_item_id
    AND    line_num   = ( select max(line_num)
			  from PA_COST_DISTRIBUTION_LINES_ALL
			  where expenditure_item_id = x_exp_item_id
			  and   line_type = 'R' );

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_stack := l_old_stack;
     x_err_code := SQLCODE;
     x_raw_cost := Null;
     x_burdened_cost := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
  WHEN OTHERS THEN
     x_raw_cost := Null;
     x_burdened_cost := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     RAISE;

END get_max_cost_amts;
-------------------------------------------------------------
PROCEDURE get_max_crdl_amts(x_exp_item_id         IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_revenue             OUT NOCOPY NUMBER,
                            x_bill_amount         OUT NOCOPY NUMBER,
                            x_exchange_rate	      OUT NOCOPY NUMBER,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_max_crdl_amts';
    x_err_stage := ' Select from pa_mc_cust_rdl_all ';
    x_revenue := NULL;
    x_bill_amount := NULL;

    SELECT SUM(amount),
           SUM(NVL(bill_amount,0)),
           Min(NVL(exchange_rate,0))
    INTO   x_revenue,
           x_bill_amount,
           x_exchange_rate
    FROM   pa_mc_cust_rdl_all
    WHERE  set_of_books_id = x_set_of_books_id
    AND    expenditure_item_id = x_exp_item_id;

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_stack := l_old_stack;
     x_err_code := SQLCODE;
     x_exchange_rate := Null;
  WHEN OTHERS THEN
     x_exchange_rate := Null;
     RAISE;

END get_max_crdl_amts;

-------------------------------------------------------------


PROCEDURE get_orig_rev_rates( x_adj_item             IN NUMBER,
                              x_line_num             IN NUMBER,
                              x_set_of_books_id      IN NUMBER,
                              x_exchange_rate        OUT NOCOPY NUMBER,
                              x_exchange_date        OUT NOCOPY DATE,
                              x_exchange_rate_type   OUT NOCOPY VARCHAR2,
                              x_err_stack            IN OUT NOCOPY VARCHAR2,
                              x_err_stage            IN OUT NOCOPY VARCHAR2,
                              x_err_code             OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_orig_rev_rates';
    x_err_stage := ' Select from pa_mc_cust_rdl_all';

    SELECT exchange_rate,
           conversion_date
    INTO   x_exchange_rate,
           x_exchange_date
    FROM   pa_mc_cust_rdl_all
    WHERE  expenditure_item_id = x_adj_item
    AND    line_num = x_line_num
    AND    set_of_books_id = x_set_of_books_id;

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_code := SQLCODE;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
  WHEN OTHERS THEN
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     RAISE;

END get_orig_rev_rates;
-------------------------------------------------------------

PROCEDURE get_orig_ei_mc_rates( x_adj_exp_item_id    IN NUMBER,
                                x_xfer_exp_item_id   IN NUMBER,
                                x_set_of_books_id    IN NUMBER,
                                x_raw_cost           OUT NOCOPY NUMBER,
                                x_raw_cost_rate      OUT NOCOPY NUMBER,
                                x_burden_cost        OUT NOCOPY NUMBER,
                                x_burden_cost_rate   OUT NOCOPY NUMBER,
                                x_bill_amount        OUT NOCOPY NUMBER,
                                x_bill_rate          OUT NOCOPY NUMBER,
                                x_accrued_revenue    OUT NOCOPY NUMBER,
                                x_accrual_rate       OUT NOCOPY NUMBER,
				                x_transfer_price     OUT NOCOPY NUMBER,
                                x_adjusted_rate      OUT NOCOPY NUMBER,
                                x_exchange_rate      OUT NOCOPY NUMBER,
                                x_exchange_date      OUT NOCOPY DATE,
                                x_exchange_rate_type OUT NOCOPY VARCHAR2,
                                x_err_stack          IN OUT NOCOPY VARCHAR2,
                                x_err_stage          IN OUT NOCOPY VARCHAR2,
                                x_err_code           OUT NOCOPY NUMBER)

IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_orig_ei_mc_rates';
    x_err_stage := ' Select from pa_mc_exp_items_all';

        select RAW_COST,
               RAW_COST_RATE,
               BURDEN_COST,
               BURDEN_COST_RATE,
               BILL_AMOUNT,
               BILL_RATE,
               ACCRUED_REVENUE,
               ACCRUAL_RATE,
	       TRANSFER_PRICE,
               ADJUSTED_RATE,
               COST_EXCHANGE_RATE,
               COST_CONVERSION_DATE,
               COST_RATE_TYPE
        INTO   x_raw_cost,
               x_raw_cost_rate ,
               x_burden_cost,
               x_burden_cost_rate ,
               x_bill_amount,
               x_bill_rate ,
               x_accrued_revenue,
               x_accrual_rate ,
	       x_transfer_price,
               x_adjusted_rate,
               x_exchange_rate,
               x_exchange_date,
               x_exchange_rate_type
        FROM   PA_MC_EXP_ITEMS_ALL
        WHERE  SET_OF_BOOKS_ID = x_set_of_books_id
        AND    EXPENDITURE_ITEM_ID = nvl(x_adj_exp_item_id,x_xfer_exp_item_id);

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_code := SQLCODE;
     x_raw_cost := Null;
     x_raw_cost_rate := Null;
     x_burden_cost := Null;
     x_burden_cost_rate := Null;
     x_bill_amount := Null;
     x_bill_rate := Null;
     x_accrued_revenue := Null;
     x_accrual_rate := Null;
     x_transfer_price := Null;
     x_adjusted_rate := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;

  WHEN OTHERS THEN
     x_raw_cost := Null;
     x_raw_cost_rate := Null;
     x_burden_cost := Null;
     x_burden_cost_rate := Null;
     x_bill_amount := Null;
     x_bill_rate := Null;
     x_accrued_revenue := Null;
     x_accrual_rate := Null;
     x_transfer_price := Null;
     x_adjusted_rate := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     RAISE;

END get_orig_ei_mc_rates;
-------------------------------------------------------------

PROCEDURE get_orig_ei_mc_rates( x_adj_exp_item_id    IN NUMBER,
                                x_xfer_exp_item_id   IN NUMBER,
                                x_set_of_books_id    IN NUMBER,
                                x_raw_cost           OUT NOCOPY NUMBER,
                                x_raw_cost_rate      OUT NOCOPY NUMBER,
                                x_burden_cost        OUT NOCOPY NUMBER,
                                x_burden_cost_rate   OUT NOCOPY NUMBER,
                                x_bill_amount        OUT NOCOPY NUMBER,
                                x_bill_rate          OUT NOCOPY NUMBER,
                                x_accrued_revenue    OUT NOCOPY NUMBER,
                                x_accrual_rate       OUT NOCOPY NUMBER,
				                x_transfer_price     OUT NOCOPY NUMBER,
                                x_adjusted_rate      OUT NOCOPY NUMBER,
                                x_exchange_rate      OUT NOCOPY NUMBER,
                                x_exchange_date      OUT NOCOPY DATE,
                                x_exchange_rate_type OUT NOCOPY VARCHAR2,
				                x_raw_revenue        OUT NOCOPY NUMBER,/*3024103*/
				                x_adj_revenue	     OUT NOCOPY NUMBER,/*3024103*/
				                x_forecast_revenue   OUT NOCOPY NUMBER,/*3024103*/
                                x_err_stack          IN OUT NOCOPY VARCHAR2,
                                x_err_stage          IN OUT NOCOPY VARCHAR2,
                                x_err_code           OUT NOCOPY NUMBER)

IS
l_old_stack            VARCHAR2(2000);

BEGIN
    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_orig_ei_mc_rates';
    x_err_stage := ' Select from pa_mc_exp_items_all';

        select RAW_COST,
               RAW_COST_RATE,
               BURDEN_COST,
               BURDEN_COST_RATE,
               BILL_AMOUNT,
               BILL_RATE,
               ACCRUED_REVENUE,
               ACCRUAL_RATE,
	       TRANSFER_PRICE,
               ADJUSTED_RATE,
               COST_EXCHANGE_RATE,
               COST_CONVERSION_DATE,
               COST_RATE_TYPE,
	       RAW_REVENUE, /*3024103*/
	       ADJUSTED_REVENUE,/*3024103*/
	       FORECAST_REVENUE/*3024103*/
        INTO   x_raw_cost,
               x_raw_cost_rate ,
               x_burden_cost,
               x_burden_cost_rate ,
               x_bill_amount,
               x_bill_rate ,
               x_accrued_revenue,
               x_accrual_rate ,
	       x_transfer_price,
               x_adjusted_rate,
               x_exchange_rate,
               x_exchange_date,
               x_exchange_rate_type,
	       x_raw_revenue,/*3024103*/
               x_adj_revenue,/*3024103*/
               x_forecast_revenue /*3024103*/
        FROM   PA_MC_EXP_ITEMS_ALL
        WHERE  SET_OF_BOOKS_ID = x_set_of_books_id
        AND    EXPENDITURE_ITEM_ID = nvl(x_adj_exp_item_id,x_xfer_exp_item_id);

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
     x_err_code := SQLCODE;
     x_raw_cost := Null;
     x_raw_cost_rate := Null;
     x_burden_cost := Null;
     x_burden_cost_rate := Null;
     x_bill_amount := Null;
     x_bill_rate := Null;
     x_accrued_revenue := Null;
     x_accrual_rate := Null;
     x_transfer_price := Null;
     x_adjusted_rate := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     x_raw_revenue := Null;
     x_adj_revenue := Null;
     x_forecast_revenue := Null;

  WHEN OTHERS THEN
     x_raw_cost := Null;
     x_raw_cost_rate := Null;
     x_burden_cost := Null;
     x_burden_cost_rate := Null;
     x_bill_amount := Null;
     x_bill_rate := Null;
     x_accrued_revenue := Null;
     x_accrual_rate := Null;
     x_transfer_price := Null;
     x_adjusted_rate := Null;
     x_exchange_rate := Null;
     x_exchange_date := Null;
     x_exchange_rate_type := Null;
     x_raw_revenue := Null;
     x_adj_revenue := Null;
     x_forecast_revenue := Null;
     RAISE;

END get_orig_ei_mc_rates;
-------------------------------------------------------------

/* Funding MRC Changes : Adding the New param for Revenue attributes and Invoice conversion attributes */

PROCEDURE get_orig_event_amts(  x_project_id         IN NUMBER,
                                x_event_num          IN NUMBER,
                                x_task_id            IN NUMBER,
                                x_set_of_books_id    IN NUMBER,
                                x_bill_amount        OUT NOCOPY NUMBER,
                                x_revenue_amount     OUT NOCOPY NUMBER,
                                x_rev_rate_type      OUT NOCOPY VARCHAR2,
                                x_rev_exchange_rate  OUT NOCOPY NUMBER,
                                x_rev_exchange_date  OUT NOCOPY DATE,
                                x_inv_exchange_rate  OUT NOCOPY NUMBER,
                                x_inv_exchange_date  OUT NOCOPY DATE,
                                x_err_stack          IN OUT NOCOPY VARCHAR2,
                                x_err_stage          IN OUT NOCOPY VARCHAR2,
                                x_err_code           OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_orig_event_amts';
    x_err_stage := ' Select from pa_mc_events';


/* Funding MRC Changes : Adding the new attributes for the revenue conversion attributes and
                         invoice conversion attributes */


    SELECT rate_type,
           exchange_rate,
           conversion_date,
           projfunc_inv_exchange_rate,
           projfunc_inv_rate_date,
           bill_amount,
           revenue_amount
    INTO   x_rev_rate_type,
           x_rev_exchange_rate,
           x_rev_exchange_date,
           x_inv_exchange_rate,
           x_inv_exchange_date,
           x_bill_amount,
           x_revenue_amount
    FROM   PA_MC_EVENTS
    WHERE  SET_OF_BOOKS_ID  = x_set_of_books_id
    AND    PROJECT_ID       = x_project_id
    AND    EVENT_NUM        = x_event_num
    AND    nvl(TASK_ID,-99) = nvl(x_task_id, -99);

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_err_code := SQLCODE;
    x_bill_amount := Null;
    x_revenue_amount := Null;
    x_rev_rate_type := Null;
    x_rev_exchange_rate := Null;
    x_rev_exchange_date := Null;
    x_inv_exchange_rate := Null;
    x_inv_exchange_date := Null;

  WHEN OTHERS THEN
    x_bill_amount := Null;
    x_revenue_amount := Null;
    x_rev_rate_type := Null;
    x_rev_exchange_rate := Null;
    x_rev_exchange_date := Null;
    x_inv_exchange_rate := Null;
    x_inv_exchange_date := Null;
    RAISE;

END get_orig_event_amts;
-------------------------------------------------------------

PROCEDURE get_imported_rates( x_set_of_books_id      IN NUMBER,
                              x_exp_item_id          IN NUMBER,
                              x_raw_cost             OUT NOCOPY NUMBER,
                              x_raw_cost_rate        OUT NOCOPY NUMBER,
                              x_burden_cost          OUT NOCOPY NUMBER,
                              x_burden_cost_rate     OUT NOCOPY NUMBER,
                              x_exchange_rate        OUT NOCOPY NUMBER,
                              x_exchange_date        OUT NOCOPY DATE,
                              x_exchange_rate_type   OUT NOCOPY VARCHAR2,
                              x_err_stack            IN OUT NOCOPY VARCHAR2,
                              x_err_stage            IN OUT NOCOPY VARCHAR2,
                              x_err_code             OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_imported_rates';
    x_err_stage := ' Select from pa_mc_txn_interface_all';

    SELECT mc.raw_cost,
           mc.raw_cost_rate,
           mc.burdened_cost,
           mc.burdened_cost_rate,
           mc.exchange_rate,
           mc.conversion_date,
           mc.rate_type
    INTO   x_raw_cost,
           x_raw_cost_rate,
           x_burden_cost,
           x_burden_cost_rate,
           x_exchange_rate,
           x_exchange_date,
           x_exchange_rate_type
    FROM   pa_mc_txn_interface_all mc,
           pa_transaction_interface_all txn
    WHERE  mc.txn_interface_id = txn.txn_interface_id
    AND    txn.expenditure_item_id = x_exp_item_id
    AND    mc.set_of_books_id = x_set_of_books_id;

    x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_err_code := SQLCODE;
    x_raw_cost := Null;
    x_raw_cost_rate := Null;
    x_burden_cost := Null;
    x_burden_cost_rate := Null;
    x_exchange_rate := Null;
    x_exchange_date := Null;
    x_exchange_rate_type := Null;

  WHEN OTHERS THEN
    x_raw_cost := Null;
    x_raw_cost_rate := Null;
    x_burden_cost := Null;
    x_burden_cost_rate := Null;
    x_exchange_rate := Null;
    x_exchange_date := Null;
    x_exchange_rate_type := Null;
    RAISE;

END get_imported_rates;
-------------------------------------------------------------



PROCEDURE get_ap_keys( x_eiid          IN NUMBER,
                       x_ref2          OUT NOCOPY VARCHAR2,
                       x_ref3          OUT NOCOPY VARCHAR2,
                       x_err_stack     IN OUT NOCOPY VARCHAR2,
                       x_err_stage     IN OUT NOCOPY VARCHAR2,
                       x_err_code      OUT NOCOPY NUMBER)
IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_ap_keys';
    x_err_stage := ' Select from pa_cost_distribution_lines_all';


     SELECT cdl.system_reference2,
            cdl.system_reference3
     INTO   x_ref2, -- invoice id
            x_ref3 -- line num
     FROM   pa_cost_distribution_lines_all cdl
     WHERE  cdl.expenditure_item_id = x_eiid
     AND    rownum = 1;

     x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_err_code := SQLCODE;
    x_ref2 := Null;
    x_ref3 := Null;
  WHEN OTHERS THEN
    x_ref2 := Null;
    x_ref3 := Null;
    RAISE;

END get_ap_keys;

-------------------------------------------------------------

PROCEDURE get_ap_rate( x_invoice_id          IN NUMBER,
                       x_line_num            IN NUMBER,
                       x_system_reference4   IN VARCHAR2 ,
                       x_transaction_source  IN VARCHAR2 ,
                       x_sob                 IN NUMBER,
                       x_exchange_rate       OUT NOCOPY NUMBER,
                       x_exchange_date       OUT NOCOPY DATE,
                       x_exchange_rate_type  OUT NOCOPY VARCHAR2,
		               x_amount		         OUT NOCOPY NUMBER,
                       x_err_stack           IN OUT NOCOPY VARCHAR2,
                       x_err_stage           IN OUT NOCOPY VARCHAR2,
                       x_err_code            OUT NOCOPY NUMBER)

IS

    l_old_stack            VARCHAR2(2000);
    l_reporting_curr_code  VARCHAR2(5);
    l_amount               NUMBER;
    l_denom_amt_var        NUMBER;
    l_base_amt_var         NUMBER;

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_ap_rate';
    x_err_stage := ' Select from ap_mc_invoice_dists';

-- To get the ap rates logic used : FC:Foreign curr, PC:Pri Curr,Rep:Reporting
-- If foreign curr inv, then ap.amount = FC amount, ap.base_Amount = PC amt
-- and mc.base_amount = Rep Amount, mc.amount = FC or PC amt.
-- and exch rate is from FC to Rep, not from PC to rep.
-- IF FC = Rep Curr, then the mc rec for that rep SOB has
-- mc.amount = FC amount, all other amount and exchange cols are NULL.
-- IF PC inv, then base_amount cols are null in both tables and exch rates
-- on mc recs are correct.


/* added the checks for transaction source and system_refereence4
   in order to process AP VARIANCE amounts */

  IF (x_transaction_source = 'AP VARIANCE' AND x_system_reference4='IPV' ) THEN

     SELECT  mc.exchange_rate, -- Bug3056201
            --  Bug3056201 decode(NVL(ap.BASE_INVOICE_PRICE_VARIANCE,0),0,mc.EXCHANGE_RATE,
            --      (mc.BASE_INVOICE_PRICE_VARIANCE/ap.BASE_INVOICE_PRICE_VARIANCE)) exchange_rate,
            nvl(mc.exchange_date,ap.exchange_date) exchange_date,
            mc.exchange_rate_type,
            nvl(nvl(mc.BASE_INVOICE_PRICE_VARIANCE,
               GL_MC_CURRENCY_PKG.CurrRound(ap.amount_variance * nvl(mc.exchange_rate,1),l_reporting_curr_code)),0) amount,/*Bug 4292891*/
            sob.currency_code
       INTO x_exchange_rate,
            x_exchange_date,
            x_exchange_rate_type,
            x_amount,
            l_reporting_curr_code
       FROM gl_sets_of_books sob,
            ap_mc_invoice_dists  mc,
            ap_invoice_distributions ap
      WHERE ap.invoice_id = x_invoice_id
        AND ap.distribution_line_number = x_line_num
        AND mc.invoice_id = ap.invoice_id
        AND mc.distribution_line_number = ap.distribution_line_number
        AND mc.set_of_books_Id = x_sob
        AND mc.set_of_books_id = sob.set_of_books_id;

/*
     IF nvl(x_amount,0) = 0  THEN
        AP_PA_API_PKG.get_inv_amount_var(x_invoice_id,x_line_num,l_denom_amt_var,l_base_amt_var);
        l_amount := nvl(l_denom_amt_var,0) * nvl(x_exchange_rate,1);
        x_amount := GL_MC_CURRENCY_PKG.CurrRound(l_amount, l_reporting_curr_code);
     END IF;
*/

 ELSIF (x_transaction_source = 'AP VARIANCE' AND x_system_reference4='ERV' ) THEN

     SELECT  /*mc.exchange_rate, Bug3056201 */ /*reverted for bug 3927230 */
              decode(NVL(ap.EXCHANGE_RATE_VARIANCE,0),0,mc.EXCHANGE_RATE,
                  (mc.EXCHANGE_RATE_VARIANCE/ap.EXCHANGE_RATE_VARIANCE)) exchange_rate,
            nvl(mc.exchange_date,ap.exchange_date) exchange_date,
            mc.exchange_rate_type,
            nvl(mc.EXCHANGE_RATE_VARIANCE,0) amount /*bug 4292891*/
       INTO x_exchange_rate,
            x_exchange_date,
            x_exchange_rate_type,
            x_amount
       FROM ap_mc_invoice_dists  mc,
            ap_invoice_distributions ap
      WHERE ap.invoice_id = x_invoice_id
        AND ap.distribution_line_number = x_line_num
        AND mc.invoice_id = ap.invoice_id
        AND mc.distribution_line_number = ap.distribution_line_number
        AND mc.set_of_books_Id = x_sob;

 ELSE

    SELECT   mc.exchange_rate, -- Bug3056201
           --  Bug3056201 decode(NVL(ap.base_amount,0),0,mc.exchange_rate,
	  -- (NVL(mc.base_amount,mc.amount)/ap.base_amount)) exchange_rate,
           NVL(mc.exchange_date,ap.exchange_date) exchange_date,
           mc.exchange_rate_type,
           decode(mc.base_amount,NULL,NVL(mc.amount,0),mc.base_amount) amount /*Bug 4292891 */
      INTO x_exchange_rate,
           x_exchange_date,
           x_exchange_rate_type,
           x_amount
      FROM ap_mc_invoice_dists  mc,
           ap_invoice_distributions ap
     WHERE ap.invoice_id = x_invoice_id
       AND ap.distribution_line_number = x_line_num
       AND mc.invoice_id = ap.invoice_id
       AND mc.distribution_line_number = ap.distribution_line_number
       AND mc.set_of_books_Id = x_sob;

 END IF;
   x_err_stack := l_old_stack;


EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_err_code := SQLCODE;
    x_exchange_rate := Null;
    x_exchange_date := Null;
    x_exchange_rate_type := Null;
    x_amount := Null;

  WHEN OTHERS THEN
    x_exchange_rate := Null;
    x_exchange_date := Null;
    x_exchange_rate_type := Null;
    x_amount := Null;
    RAISE;

END get_ap_rate;

-------------------------------------------------------------

FUNCTION sum_rev_rdl( x_project_id     IN  NUMBER,
                      x_dr_num         IN  NUMBER,
                      x_sob            IN  NUMBER) RETURN NUMBER
IS
 rdl_amt       NUMBER;
 rdl_amt_event NUMBER;
 rdl_amt_sum   NUMBER;

BEGIN

 SELECT  sum(nvl(amount,0))
 INTO rdl_amt
 FROM pa_mc_cust_rdl_all
 WHERE project_id = x_project_id
 AND draft_revenue_num = x_dr_num
 AND set_of_books_id = x_sob;


 SELECT  sum(nvl(amount,0))
 INTO rdl_amt_event
 FROM pa_mc_cust_event_rdl_all
 WHERE  project_id = x_project_id
 AND draft_revenue_num = x_dr_num
 AND set_of_books_id = x_sob;

 rdl_amt_sum := nvl(rdl_amt,0) + nvl(rdl_amt_event,0);

 RETURN nvl(rdl_amt_sum,0);

EXCEPTION WHEN OTHERS THEN
  RAISE;

END sum_rev_rdl;

-------------------------------------------------------------

FUNCTION sum_inv( x_project_id    IN  NUMBER,
                  x_di_num        IN  NUMBER,
                  x_line_num      IN  NUMBER,
                  x_sob           IN  NUMBER) RETURN NUMBER
IS
 inv_amt NUMBER;

BEGIN

 SELECT  sum(nvl(amount,0))
 INTO inv_amt
 FROM pa_mc_draft_inv_items
 WHERE project_id = x_project_id
 AND draft_invoice_num = x_di_num
 AND line_num = x_line_num
 AND set_of_books_id = x_sob;

 RETURN nvl(inv_amt,0);

EXCEPTION
WHEN OTHERS THEN
  RAISE;

END sum_inv;

-------------------------------------------------------------

FUNCTION sum_inv_rdl( x_project_id  IN   NUMBER,
                      x_di_num      IN   NUMBER,
                      x_line_num    IN   NUMBER,
                      x_sob         IN   NUMBER) RETURN NUMBER
IS
 cust_rdl_amt NUMBER;
 ic_rdl_amt   NUMBER;
 rdl_amt      NUMBER;

BEGIN

-- Either the invoice will be a customer invoice or IC invoice
-- so the one of the selects will return a value
--

 SELECT  sum(nvl(bill_amount,0))
 INTO cust_rdl_amt
 FROM pa_mc_cust_rdl_all
 WHERE project_id = x_project_id
 AND draft_invoice_num = x_di_num
 AND draft_invoice_item_line_num = x_line_num
 AND set_of_books_id = x_sob;

 SELECT  sum(nvl(mcdii.bill_amount,0))
 INTO ic_rdl_amt
 FROM pa_mc_draft_inv_details_all mcdii ,
      pa_draft_invoice_details_all dii
 WHERE dii.project_id = x_project_id
 AND dii.draft_invoice_num = x_di_num
 AND dii.draft_invoice_line_num = x_line_num
 AND dii.draft_invoice_detail_id = mcdii.draft_invoice_detail_id
 AND mcdii.set_of_books_id = x_sob;

 rdl_amt := nvl(cust_rdl_amt,0) + nvl(ic_rdl_amt,0);

 RETURN nvl(rdl_amt,0);

EXCEPTION
 WHEN OTHERS THEN
 RAISE;

END sum_inv_rdl;

-------------------------------------------------------------

FUNCTION sum_inv_erdl( x_project_id IN   NUMBER,
                       x_di_num     IN   NUMBER,
                       x_line_num   IN   NUMBER,
                       x_sob        IN   NUMBER) RETURN NUMBER
IS
 rdl_amt NUMBER;

BEGIN

 SELECT  sum(nvl(amount,0))
 INTO    rdl_amt
 FROM    pa_mc_cust_event_rdl_all
 WHERE   project_id = x_project_id
 AND     draft_invoice_num = x_di_num
 AND     draft_invoice_item_line_num = x_line_num
 AND     set_of_books_Id = x_sob;

 RETURN nvl(rdl_amt,0);

EXCEPTION
 WHEN OTHERS THEN
  RAISE;

END sum_inv_erdl;

-------------------------------------------------------------

FUNCTION sum_inv_ev( x_project_id   IN   NUMBER,
                     x_task_id      IN   NUMBER,
                     x_event_num    IN   NUMBER,
                     x_sob          IN   NUMBER) RETURN NUMBER

IS
 rdl_amt NUMBER;

BEGIN

  SELECT  sum(nvl(bill_amount,0))
  INTO    rdl_amt
  FROM    pa_mc_events
  WHERE   project_id = x_project_id
  AND     nvl(task_id,-99) = nvl(x_task_id,-99)
  AND     event_num = x_event_num
  AND     set_of_books_id = x_sob;

  RETURN nvl(rdl_amt,0);

EXCEPTION
  /* IF 0 retuned then trigger to raise error */

  WHEN OTHERS THEN
     RAISE;

END sum_inv_ev;

-------------------------------------------------------------

FUNCTION event_date( x_project_id   IN   NUMBER,
                     x_task_id      IN   NUMBER,
                     x_event_Num    IN   NUMBER) RETURN DATE
IS
   event_date DATE;

BEGIN

 SELECT  completion_date
 INTO    event_date
 FROM    pa_events
 WHERE   project_id = x_project_id
 AND     nvl(task_Id, -99) = nvl(x_task_id, -99)
 AND     event_num = x_event_num;

 RETURN event_date;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
  WHEN OTHERS THEN
    RAISE;
END event_date;

-------------------------------------------------------------

FUNCTION sum_mc_cust_rdl_erdl( x_project_id                   IN   NUMBER,
                               x_draft_revenue_num            IN   NUMBER,
                               x_draft_revenue_item_line_num  IN   NUMBER) RETURN NUMBER

IS
   rdl_amt   NUMBER;
   erdl_amt  NUMBER;
BEGIN

 SELECT  sum(nvl(rdl.amount,0))
 INTO    rdl_amt
 FROM    pa_mc_cust_rdl_all rdl
         -- pa_implementations imp -- Fix for Perf Bug 2695336
 WHERE   rdl.project_id                  = x_project_id
 AND     rdl.draft_revenue_num           = x_draft_revenue_num
 AND     rdl.draft_revenue_item_line_num = x_draft_revenue_item_line_num
 AND     rdl.set_of_books_id             =   NVL(TO_NUMBER( SUBSTRB( USERENV('CLIENT_INFO'), 45,10) ), -99);

 -- Modified below query for bug 6696736
 SELECT  sum(nvl(erdl.amount,0))
 INTO    erdl_amt
 FROM    pa_mc_cust_event_rdl_all erdl,
         pa_cust_event_rdl_all cerdl
         -- pa_implementations imp -- Fix for Perf Bug 2695336
 WHERE   cerdl.project_id                  = x_project_id
 AND     cerdl.draft_revenue_num           = x_draft_revenue_num
 AND     cerdl.draft_revenue_item_line_num = x_draft_revenue_item_line_num
 AND     erdl.set_of_books_id             =  NVL(TO_NUMBER( SUBSTRB( USERENV('CLIENT_INFO'), 45,10) ), -99)
 AND	 cerdl.project_id = erdl.project_id
 AND	 cerdl.event_num = erdl.event_num
 AND	 NVL(cerdl.task_id,-99) = NVL(erdl.task_id,-99)
 AND	 cerdl.line_num = erdl.line_num;


 RETURN (nvl(rdl_amt,0) + nvl(erdl_amt,0));

EXCEPTION WHEN OTHERS THEN
  RAISE;

END sum_mc_cust_rdl_erdl;

-------------------------------------------------------------


FUNCTION orgid(  x_project_id  IN   NUMBER) RETURN NUMBER
IS
  orgid NUMBER;
BEGIN
 SELECT org_id
 INTO   orgid
 FROM   pa_projects_all
 WHERE  project_id = x_project_id;

 RETURN orgid;

EXCEPTION WHEN OTHERS THEN
  RAISE;
END orgid;
-------------------------------------------------------------

FUNCTION get_wo_factor(x_project_id IN   NUMBER,
                       x_di_num     IN   NUMBER,
                       x_di_num_org IN   NUMBER ) RETURN NUMBER
IS
  wo_factor number := 0;
BEGIN
  SELECT (inv.amount/invorg.amount)
  INTO   wo_factor
  FROM   pa_draft_invoice_items invorg,
         pa_draft_invoice_items inv
  WHERE  inv.project_id = x_project_id
  AND    inv.draft_invoice_num = x_di_num
  AND    inv.line_num = 1
  AND    invorg.project_id = inv.project_id
  AND    invorg.draft_invoice_num = x_di_num_org
  AND    invorg.line_num = inv.line_num;

  RETURN (wo_factor);

EXCEPTION
  WHEN NO_DATA_FOUND then
	pa_mc_currency_pkg.raise_error('PA_MRC_WO_FACTOR_ERROR', 'PAMRCDIS:9');

  WHEN OTHERS THEN
        RAISE;
END get_wo_factor;

-------------------------------------------------------------

FUNCTION get_cancel_flag( x_project_id IN   NUMBER,
                          x_di_num     IN   NUMBER ) RETURN VARCHAR2
IS
  cancel_flag VARCHAR2(2);
BEGIN
  SELECT NVL(canceled_flag,'N')
  INTO cancel_flag
  FROM pa_draft_invoices
  WHERE project_id = x_project_id
  AND   draft_invoice_num = x_di_num;

  RETURN cancel_flag;

EXCEPTION
  WHEN NO_DATA_FOUND then
	raise_error('PA_MRC_CANCEL_FLAG_ERROR','PAMRCDIS:8');

  WHEN OTHERS THEN
       RAISE;
END get_cancel_flag;

-------------------------------------------------------------

FUNCTION get_invoice_action RETURN VARCHAR2
IS
BEGIN
   IF NVL(pa_mc_currency_pkg.Invoice_Action,'NONE') = 'CANCEL' then
      RETURN ('Y');
   ELSE RETURN ('N');
   END IF;
END;

-------------------------------------------------------------

FUNCTION get_rtn_amount( x_project_id 	IN  NUMBER,
                         x_di_num       IN  NUMBER,
                         x_rtn_pcnt	IN  NUMBER,
                         x_sob_id       IN  NUMBER ) RETURN NUMBER
IS
   rtn_amount NUMBER := 0;
BEGIN
   SELECT sum(mii.amount)
   INTO rtn_amount
   FROM pa_mc_draft_inv_items mii,
        pa_draft_invoice_items ii
   WHERE ii.project_id = x_project_id
   AND   ii.draft_invoice_num = x_di_num
   AND   ii.invoice_line_type <> 'RETENTION'
   AND   mii.set_of_books_id = x_sob_id
   AND   mii.project_id = x_project_id
   AND   mii.draft_invoice_num = x_di_num
   AND   mii.line_num = ii.line_num;

   RETURN (NVL(rtn_amount,0)*x_rtn_pcnt/100);

EXCEPTION
  /*  If 0 returned, then the trigger should raise error */

  WHEN OTHERS THEN
     RAISE ;
END get_rtn_amount;

-------------------------------------------------------------

PROCEDURE raise_error(x_msg        IN VARCHAR2,
                      x_module     IN VARCHAR2,
                      x_currency   IN VARCHAR2 )
IS

BEGIN
   fnd_message.set_name('PA', x_msg);
   fnd_message.set_token('MODULE', x_module);
   IF (x_currency IS NOT NULL) then
	fnd_message.set_token('CURRENCY', x_currency);
   END IF;
   raise_application_error(-20009,fnd_message.get);

END raise_error;

-------------------------------------------------------------

/*------------------------------ ins_mc_txn_interface_all ----------------------*/
/* This procedure will populate the Pa_mc_txn_interface_all table for a invoice */
/* distribution line pulled over from AP . First it will look for the data in   */
/* the AP MRC sub-table otherwise it will get the rates from GL based on the    */
/* Invoice Date and compute the amounts and populate the pa_mc_txn_interface_all*/
/* table                                                                        */
/*------------------------------------------------------------------------------*/

/* Changed the IN parameter names  and local variables
  from p_vendor_id to p_system_reference1,
   p_invoice_id         to p_system_reference2,
   p_dist_line_num      to p_system_reference3,
   p_invoice_payment_id to p_system_reference4
*/

/*
PROCEDURE ins_mc_txn_interface_all(

   p_vendor_id           IN      NUMBER,
   p_invoice_id          IN      NUMBER,
   p_dist_line_num       IN      NUMBER,
   p_interface_id        IN      NUMBER,
   p_transaction_source  IN      VARCHAR2,
   p_invoice_payment_id  IN      NUMBER DEFAULT NULL) IS
*/

PROCEDURE ins_mc_txn_interface_all(
   p_system_reference1   IN      NUMBER,
   p_system_reference2   IN      NUMBER,
   p_system_reference3   IN      NUMBER,
   p_system_reference4   IN      VARCHAR2 ,
   p_interface_id        IN      NUMBER,
   p_transaction_source  IN      VARCHAR2,
   p_acct_evt_id         IN      NUMBER DEFAULT NULL) --pricing changes, added param p_acct_evt_id

IS


	l_old_stack            VARCHAR2(2000);
	l_err_code             NUMBER;
	l_sob                  NUMBER;
	l_org_id               NUMBER;
	l_txn_raw_cost         NUMBER;
	l_raw_cost             NUMBER;
	l_burdened_cost        NUMBER;
	l_currency             VARCHAR2(30);
	l_txn_interface_id     NUMBER;
	l_exchange_rate        NUMBER;
	l_denominator_rate     NUMBER;
	l_numerator_rate       NUMBER;
	l_exchange_date        DATE;
	l_exchange_rate_type   VARCHAR2(30);

  -- Bug 1131476, creating new variables to pass to get_ap_rate API
	l_ap_exchange_date        DATE;
	l_ap_exchange_rate_type   VARCHAR2(30);
	l_ap_exchange_rate        NUMBER;
	l_result_code          VARCHAR2(15);

  -- Added new variables for get_po_rate API
        l_po_exchange_date        DATE;
        l_po_exchange_rate_type   VARCHAR2(30);
        l_po_exchange_rate        NUMBER;

  --Added for performance changes
    l_rcv_txn_id NUMBER;
    l_po_dist_id NUMBER;
    l_inv_pay_id NUMBER;

BEGIN

  	l_old_stack := PAAPIMP_PKG.G_err_stack;
    	PAAPIMP_PKG.G_err_code  := 0;
    	PAAPIMP_PKG.G_err_stack := PAAPIMP_PKG.G_err_stack||'->PA_MC_CURRENCY_PKG.ins_mc_txn_interface_all';
    	PAAPIMP_PKG.G_err_stage := ' Insert into pa_mc_txn_interface_all';

	PAAPIMP_PKG.write_log(LOG, PAAPIMP_PKG.G_err_stack);
	PAAPIMP_PKG.write_log(LOG, 'Inserting transaction source: '||p_transaction_source||
                        'system_ref2 : ' ||p_system_reference2||
			'system_ref3 : ' ||p_system_reference3 ||
                        'system_ref4:  ' ||p_system_reference4||
			' into pa_mc_txn_interface_all......');

	PAAPIMP_PKG.G_err_stage := 'GET ORG_ID IN INS_MC_TXN_INTERFACE';
    	--select NVL(org_id,-99)
	select org_id
    	into   l_org_id
    	from pa_implementations;

	/**

	PAAPIMP_PKG.G_err_stage := 'CALLING FUNCTIONAL_CURRENCY IN INS_MC_TXN_INTERFACE';
    	l_currency := pa_mc_currency_pkg.functional_currency(l_org_id);
	**/

	PAAPIMP_PKG.G_err_stage := 'CALLING SET_OF_BOOKS IN INS_MC_TXN_INTERFACE';
    	l_sob      := pa_mc_currency_pkg.set_of_books();

        PAAPIMP_PKG.G_err_stage := 'GET TXN_INTERFACE_ID and BURDEN_COST IN INS_MC_TXN_INTERFACE';

   -- change the IF conditions to be based on p_system_refernce4
   -- IF p_invoice_payment_id IS NULL THEN

   IF p_system_reference4 IS NULL  THEN

      PAAPIMP_PKG.write_log (LOG,'getting denom information for invoices  IN INS_MC_TXN_INTERFACE');

      SELECT txn_interface_id,
             denom_burdened_cost,
             denom_raw_cost,
             --removed, should get from MRC table   acct_rate_type,
             --removed, should get from MRC table   acct_exchange_rate,
             denom_currency_code
        into l_txn_interface_id,
             l_burdened_cost,
             l_txn_raw_cost,
             --removed  l_exchange_rate_type,
             --removed  l_exchange_rate,
             l_currency
        from pa_transaction_interface_all
       where interface_id = p_interface_id
         and cdl_system_reference1  = to_char(p_system_reference1)
         and cdl_system_reference2  = to_char(p_system_reference2)
         and cdl_system_reference3  = to_char(p_system_reference3)
         and transaction_source||'' = p_transaction_source;

   --Change IF condition to be based on p_system_reference4
   --ELSIF p_invoice_payment_id IS NOT NULL THEN

   ELSIF p_system_reference4 IS NOT NULL THEN

      PAAPIMP_PKG.write_log (LOG,'getting denom information for non-invoices  IN INS_MC_TXN_INTERFACE');

         SELECT txn_interface_id,
                denom_burdened_cost,
                denom_raw_cost,
                denom_currency_code
           into l_txn_interface_id,
                l_burdened_cost,
                l_txn_raw_cost,
                l_currency
           from pa_transaction_interface_all
          where interface_id = p_interface_id
            and cdl_system_reference1 = to_char(p_system_reference1)
            and cdl_system_reference2 = to_char(p_system_reference2)
            and cdl_system_reference3 = to_char(p_system_reference3)
            and cdl_system_reference4 = p_system_reference4
            and transaction_source||''= p_transaction_source;

   END IF;

   PAAPIMP_PKG.write_log(LOG,'txn interface id is:'||l_txn_interface_id||
                             'denom_burdened_cost is:'||l_burdened_cost||
                             'denom_raw_cost is:'||l_txn_raw_cost||
                             'denom_currency_code is:'||l_currency);


    FOR i IN 1..g_rsob_tab.COUNT

       LOOP

         BEGIN

            --instead of using invoice_payment_id, use system_reference4
            IF (p_system_reference4 IS NULL  or
                p_transaction_source='AP VARIANCE') THEN

               PAAPIMP_PKG.G_err_stage := 'CALLING GET_AP_RATE IN INS_MC_TXN_INTERFACE';

               pa_mc_currency_pkg.get_ap_rate(x_invoice_id         => p_system_reference2,
                                              x_line_num           => p_system_reference3,
                                              x_system_reference4  => p_system_reference4,
                                              x_transaction_source => p_transaction_source,
                                              x_sob                => g_rsob_tab(i).rsob_id,
                                              x_exchange_rate      => l_ap_exchange_rate,
                                              x_exchange_date      => l_ap_exchange_date,
                                              x_exchange_rate_type => l_ap_exchange_rate_type,
                                              x_amount             => l_raw_cost,
                                              x_err_stack          => PAAPIMP_PKG.G_err_stack,
                                              x_err_stage          => PAAPIMP_PKG.G_err_stage,
                                              x_err_code           => l_err_code);

            END IF;

            IF (l_err_code <> 0 AND l_err_code <> -1403 AND l_err_code <> 100)THEN

                pa_mc_currency_pkg.raise_error('PA_MRC_AP_RATES','PAMRCDIS:4',g_rsob_tab(i).rcurrency_code);

            END IF;


            IF (p_system_reference4 IS NOT NULL  AND
                p_transaction_source IN ('PO RECEIPT','PO RECEIPT NRTAX', 'PO RECEIPT PRICE ADJ'
		,'PO RECEIPT NRTAX PRICE ADJ')) THEN -- pricing changes

               PAAPIMP_PKG.G_err_stage := 'CALLING GET_PO_RATE IN INS_MC_TXN_INTERFACE';

               pa_mc_currency_pkg.get_po_rate(x_po_dist_id         => p_system_reference3,
                                              x_rcv_txn_id         => p_system_reference4,
                                              x_transaction_source => p_transaction_source,
                                              x_sob                => g_rsob_tab(i).rsob_id,
                                              x_exchange_rate      => l_po_exchange_rate,
                                              x_exchange_date      => l_po_exchange_date,
                                              x_exchange_rate_type => l_po_exchange_rate_type,
                                              x_amount             => l_raw_cost,
                                              x_err_stack          => PAAPIMP_PKG.G_err_stack,
                                              x_err_stage          => PAAPIMP_PKG.G_err_stage,
                                              x_err_code           => l_err_code,
					      x_acct_evt_id        => p_acct_evt_id);

            END IF;

            IF (l_err_code <> 0 AND l_err_code <> -1403 AND l_err_code <> 100)THEN

                pa_mc_currency_pkg.raise_error('PA_MRC_PO_RATES','PAMRCDIS:4',g_rsob_tab(i).rcurrency_code);

            END IF;

            --instead of using invoice_payment_id, use transaction_source to specify processing AP DISCOUNTS
            IF ( l_err_code = -1403 OR l_err_code = 100 OR p_transaction_source='AP DISCOUNTS')

              THEN -- if no AP MRC rates then get rates from GL based on invoice date

                  PAAPIMP_PKG.G_err_stage := 'GET EXCHANGE_DATE and INVOICE_DATE IN INS_MC_TXN_INTERFACE';
                  PAAPIMP_PKG.write_log(LOG,'getting exchange date for transaction_source:  '||p_transaction_source);
                  PAAPIMP_PKG.write_log(LOG,'sys_ref2 is: '||p_system_reference2||
                                            'sys_ref3 is: '||p_system_reference3||
                                            'sys_ref4 is: '||p_system_reference4);

                 IF (p_system_reference4 IS NULL  OR p_transaction_source = 'AP VARIANCE') THEN

                    SELECT nvl(b.exchange_date,a.invoice_date)
                      INTO l_exchange_date
                      FROM ap_invoices_all a,
                           ap_invoice_distributions_all b
                     WHERE  a.invoice_id               = p_system_reference2
                       AND  a.invoice_id               = b.invoice_id
                       AND  b.distribution_line_number = p_system_reference3;

                 ELSIF p_system_reference4 IS NOT NULL
                   AND p_transaction_source = 'AP DISCOUNTS' THEN

                  --performance change
                  l_inv_pay_id := to_number(p_system_reference4);

                  SELECT nvl(b.exchange_date,a.invoice_date)
                    INTO l_exchange_date
                    FROM ap_invoices_all a,
                         ap_invoice_distributions_all b,
                         ap_invoice_payments c
                   WHERE c.invoice_payment_id           = l_inv_pay_id
                     AND c.invoice_id                   = p_system_reference2
                     AND c.invoice_id                   = b.invoice_id
                     AND a.invoice_id                   = b.invoice_id
                     AND b.distribution_line_number     = p_system_reference3;

                 ELSIF p_system_reference4 IS NOT NULL
                   AND p_transaction_source IN ('PO RECEIPT','PO RECEIPT NRTAX','PO RECEIPT PRICE ADJ'
		   ,'PO RECEIPT NRTAX PRICE ADJ') THEN -- pricing changes

                       --Performance change
                       l_rcv_txn_id := to_number(p_system_reference4);

                       SELECT nvl(a.currency_conversion_date,a.transaction_date)
                         INTO l_exchange_date
                         FROM rcv_transactions a
                        WHERE a.po_distribution_id       = p_system_reference3
                          AND a.transaction_id           = l_rcv_txn_id;

                 END IF;

            PAAPIMP_PKG.write_log(LOG,'primaray set of books id:  '||l_sob||
                          'reporting set of books id: '||g_rsob_tab(i).rsob_id||
                          'exchange date:  '||l_exchange_date||
                          'currency:       '||l_currency||
                          'exchange type:  '||l_exchange_rate_type||
                          'exchange rate:  '||l_exchange_rate);


            PAAPIMP_PKG.G_err_stage := 'CALLING GET_RATE IN INS_MC_TXN_INTERFACE 1';
            gl_mc_currency_pkg.get_rate( p_primary_set_of_books_id   => l_sob,
                                         p_reporting_set_of_books_id => g_rsob_tab(i).rsob_id,
                                         p_trans_date                => l_exchange_date,
                                         p_trans_currency_code       => l_currency,
                                         p_trans_conversion_type     => l_exchange_rate_type,
                                         p_trans_conversion_date     => l_exchange_date,
                                         p_trans_conversion_rate     => l_exchange_rate,
                                         p_application_id            => 275,
                                         p_org_id                    => l_org_id,
                                         p_fa_book_type_code         => NULL,
                                         p_je_source_name            => NULL,
                                         p_je_category_name          => NULL,
                                         p_result_code               => l_result_code,
                                         p_denominator_rate          => l_denominator_rate,
                                         p_numerator_rate            => l_numerator_rate);
              PAAPIMP_PKG.write_log(LOG,'after get rate from GL');

              PAAPIMP_PKG.G_err_stage := 'CALLING CURRROUND IN INS_MC_TXN_INTERFACE PROCEDURE';
              IF (l_exchange_rate_type = 'User') THEN

                  l_burdened_cost  := pa_mc_currency_pkg.CurrRound
	                              ((l_burdened_cost *l_exchange_rate), g_rsob_tab(i).rcurrency_code);

                  l_raw_cost       := pa_mc_currency_pkg.CurrRound
                                      ((l_txn_raw_cost*l_exchange_rate),g_rsob_tab(i).rcurrency_code);

              ELSE

            	l_burdened_cost  := pa_mc_currency_pkg.CurrRound
	                            (((l_burdened_cost/l_denominator_rate)*l_numerator_rate),
                                       g_rsob_tab(i).rcurrency_code);

           	l_raw_cost  := pa_mc_currency_pkg.CurrRound
	                     (((l_txn_raw_cost/l_denominator_rate)*l_numerator_rate),
                           	      g_rsob_tab(i).rcurrency_code);
             END IF;

        ELSE -- rates are found

            /* Getting the conversion rate for burdened cost */

           /* IF p_transaction_source <> 'PO RECEIPT' THEN -- Modified for Bug#3059995 */
           IF p_transaction_source NOT IN ( 'PO RECEIPT','PO RECEIPT NRTAX','PO RECEIPT PRICE ADJ'
		,'PO RECEIPT NRTAX PRICE ADJ') THEN -- pricing changes

              l_exchange_rate_type := l_ap_exchange_rate_type;
              l_exchange_rate      := l_ap_exchange_rate;
              l_exchange_date      := l_ap_exchange_date;

           ELSIF  p_transaction_source IN ( 'PO RECEIPT','PO RECEIPT NRTAX','PO RECEIPT PRICE ADJ'
		,'PO RECEIPT NRTAX PRICE ADJ') THEN

              l_exchange_rate_type := l_po_exchange_rate_type;
              l_exchange_rate      := l_po_exchange_rate;
              l_exchange_date      := l_po_exchange_date;

           END IF;

            PAAPIMP_PKG.G_err_stage := 'CALLING GET_RATE IN INS_MC_TXN_INTERFACE 2';
            gl_mc_currency_pkg.get_rate(p_primary_set_of_books_id   => l_sob,
                                        p_reporting_set_of_books_id => g_rsob_tab(i).rsob_id,
                                        p_trans_date                => l_exchange_date,
                                        p_trans_currency_code       => l_currency,
                                        p_trans_conversion_type     => l_exchange_rate_type,
                                        p_trans_conversion_date     => l_exchange_date,
                                        p_trans_conversion_rate     => l_exchange_rate,
                                        p_application_id            => 275,
                                        p_org_id                    => l_org_id,
                                        p_fa_book_type_code         => NULL,
                                        p_je_source_name            => NULL,
                                        p_je_category_name          => NULL,
                                        p_result_code               => l_result_code,
                                        p_denominator_rate          => l_denominator_rate,
                                        p_numerator_rate            => l_numerator_rate);

               IF (l_exchange_rate_type = 'User') THEN

                   l_burdened_cost  := pa_mc_currency_pkg.CurrRound
                                       ((l_burdened_cost *l_exchange_rate),
                                       g_rsob_tab(i).rcurrency_code);
               ELSE

                   l_burdened_cost  := pa_mc_currency_pkg.CurrRound
                                   (((l_burdened_cost/l_denominator_rate)*l_numerator_rate),
                                       g_rsob_tab(i).rcurrency_code);

               END IF;

        END IF;

        PAAPIMP_PKG.write_log(LOG,'before inserting into pa_mc_txn_interface_all table');

	PAAPIMP_PKG.G_err_stage := 'INSERT RECORD INTO PA_MC_TXN_INTERFACE_ALL';
        PAAPIMP_PKG.write_log(LOG,'insert SOBID:'||g_rsob_tab(i).rsob_id||
                          'insert txn_interface_id:'||l_txn_interface_id||
                          'insert raw_cost:'||l_raw_cost||
                          'exchange rate:'||l_exchange_rate);

       	INSERT INTO pa_mc_txn_interface_all (
          			set_of_books_id    ,
           			txn_interface_id   ,
           			raw_cost           ,
           			raw_cost_rate      ,
           			burdened_cost      ,
           			burdened_cost_rate ,
           			currency_code      ,
           			exchange_rate      ,
           			conversion_date    )
         VALUES (
           	g_rsob_tab(i).rsob_id,
           	l_txn_interface_id              ,
           	l_raw_cost                      ,
           	NULL                            ,
           	l_burdened_cost                 ,
           	NULL                            ,
           	g_rsob_tab(i).rcurrency_code    ,
           	l_exchange_rate                 ,
           	l_exchange_date                 );

      	END;
    END LOOP; -- End of Loop for the cursor c_reporting_sob
    PAAPIMP_PKG.write_log(LOG,'after inserting');

    PAAPIMP_PKG.G_err_stack := l_old_stack;

EXCEPTION
   WHEN OTHERS THEN
	PAAPIMP_PKG.G_err_stack := l_old_stack;
        PAAPIMP_PKG.G_err_code := SQLCODE;
	PAAPIMP_PKG.G_TRANSACTION_STATUS_CODE := 'R';
	PAAPIMP_PKG.G_TRANSACTION_REJECTION_CODE := 'PA_INSERT_MRC_FAILED';
	PAAPIMP_PKG.write_log(LOG, 'Inserting system reference2: ' || to_char(p_system_reference2) ||
            	' system reference3: ' || to_char(p_system_reference3) ||
               	' into pa_mc_txn_interface_all failed in stage: ' || PAAPIMP_PKG.G_err_stage);
	PAAPIMP_PKG.write_log(LOG, substr(SQLERRM, 1, 200));

END ins_mc_txn_interface_all;
-------------------------------------------------------------------------------

PROCEDURE get_ccdl_tp_amts( x_exp_item_id         IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_transfer_price      OUT NOCOPY NUMBER,
                            x_tp_exchange_rate    OUT NOCOPY NUMBER,
                            x_tp_exchange_date    OUT NOCOPY DATE,
                            x_tp_rate_type        OUT NOCOPY VARCHAR2,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER)

IS

    l_old_stack            VARCHAR2(2000);

    Cursor C_TP_REC IS
    SELECT amount,
           acct_tp_exchange_rate,
           acct_tp_rate_date,
           acct_tp_rate_type
    FROM   pa_mc_cc_dist_lines_all
    WHERE  set_of_books_id = x_set_of_books_id
    AND    expenditure_item_id = x_exp_item_id
    AND    line_num   = ( select max(line_num)
			  from PA_CC_DIST_LINES_ALL
			  where expenditure_item_id = x_exp_item_id
			  and   line_type = 'BL' );

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_ccdl_tp_amts';
    x_err_stage := ' Select from pa_mc_cc_dist_lines_all';
    x_transfer_price := NULL;

    open C_TP_REC ;

    fetch C_TP_REC into
           x_transfer_price,
           x_tp_exchange_rate,
           x_tp_exchange_date,
           x_tp_rate_type ;

    close C_TP_REC;

    x_err_stack := l_old_stack;

Exception
   When Others Then
       x_transfer_price := Null;
       x_tp_exchange_rate := Null;
       x_tp_exchange_date := Null;
       x_tp_rate_type := Null;
       x_err_code := sqlcode;
       Raise;

END get_ccdl_tp_amts;
--------------------------------------------------------------------------------

PROCEDURE get_invdtl_tp_amts( x_exp_item_id       IN NUMBER,
                            x_set_of_books_id     IN NUMBER,
                            x_transfer_price      OUT NOCOPY NUMBER,
                            x_tp_exchange_rate    OUT NOCOPY NUMBER,
                            x_tp_exchange_date    OUT NOCOPY DATE,
                            x_tp_rate_type        OUT NOCOPY VARCHAR2,
                            x_err_stack           IN OUT NOCOPY VARCHAR2,
                            x_err_stage           IN OUT NOCOPY VARCHAR2,
                            x_err_code            OUT NOCOPY NUMBER)

IS

    Cursor C_TP_REC IS
    SELECT SUM(bill_amount),
           Min(acct_exchange_rate),
           Min(acct_rate_type),
           Min(acct_rate_date)
    FROM   pa_mc_draft_inv_details_all
    WHERE  set_of_books_id = x_set_of_books_id
    AND    draft_invoice_detail_id in
	   (select draft_invoice_detail_id
	    from pa_draft_invoice_details_all
	    where expenditure_item_id = x_exp_item_id) ;

    l_old_stack    Varchar2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_invdtl_tp_amts';
    x_err_stage := ' Select from pa_mc_draft_inv_details_all';
    x_transfer_price := NULL;

    OPEN C_TP_REC;

    FETCH C_TP_REC
    INTO   x_transfer_price,
           x_tp_exchange_rate,
	   x_tp_rate_type,
	   x_tp_exchange_date ;

    CLOSE C_TP_REC;

   x_err_stack := l_old_stack;

Exception
   When Others Then
        x_transfer_price := Null;
        x_tp_exchange_rate := Null;
        x_tp_exchange_date := Null;
        x_tp_rate_type := Null;
        Raise;

END get_invdtl_tp_amts;


PROCEDURE get_po_rate( x_po_dist_id          IN NUMBER,
                       x_rcv_txn_id          IN VARCHAR2,
                       x_transaction_source  IN VARCHAR2,
                       x_sob                 IN NUMBER,
                       x_exchange_rate       OUT NOCOPY NUMBER,
                       x_exchange_date       OUT NOCOPY DATE,
                       x_exchange_rate_type  OUT NOCOPY VARCHAR2,
                       x_amount              OUT NOCOPY NUMBER,
                       x_err_stack           IN OUT NOCOPY VARCHAR2,
                       x_err_stage           IN OUT NOCOPY VARCHAR2,
                       x_err_code            OUT NOCOPY NUMBER,
		               x_acct_evt_id         IN  NUMBER DEFAULT NULL)
IS

    l_old_stack    VARCHAR2(2000);
    l_rcv_txn_id   NUMBER;

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.get_po_rate';
    x_err_stage := ' Select from rcv_mc_rec_sub_ledger';

    l_rcv_txn_id := to_number(x_rcv_txn_id);

-- To get the  porates logic used : FC:Foreign curr, PC:Pri Curr,Rep:Reporting
-- If foreign curr inv, then po.amount = FC amount, po.base_Amount = PC amt
-- and mc.base_amount = Rep Amount, mc.amount = FC or PC amt.
-- and exch rate is from FC to Rep, not from PC to rep.
-- IF FC = Rep Curr, then the mc rec for that rep SOB has
-- mc.amount = FC amount, all other amount and exchange cols are NULL.
-- IF PC inv, then base_amount cols are null in both tables and exch rates
-- on mc recs are correct.

IF x_transaction_source IN ('PO RECEIPT','PO RECEIPT PRICE ADJ') THEN -- pricing changes, added 'PO RECEIPT PRICE ADJ'

   /* for the amount that we are selecting, we need to see whether the transaction is an
      EXPENSE or RECEIVING transactions. EXPENSE means we take the positive value of dr column
      minus the tax amount while RECEIVNG transaction means it is a return, so we take the
      negative of the cr column plus the tax amount */

   SELECT mcsub.CURRENCY_CONVERSION_RATE exchange_rate,  --Bug#3218750
            -- Bug#3218750 decode(NVL(rcvsub.ACCOUNTED_DR,0),0,mcsub.CURRENCY_CONVERSION_RATE,
           --       (mcsub.ACCOUNTED_DR/rcvsub.accounted_dr )) exchange_rate,
          nvl(mcsub.CURRENCY_CONVERSION_DATE,mctxn.CURRENCY_CONVERSION_DATE) exchange_date,
          nvl(mctxn.CURRENCY_CONVERSION_TYPE,rcvtxn.CURRENCY_CONVERSION_TYPE) excahnge_rate_type,
          decode(rcvtxn.transaction_type,
                 'RETURN TO RECEIVING',(-nvl(mcsub.accounted_cr,0)+nvl(mcsub.accounted_nr_tax,0)),
                 'RETURN TO VENDOR',(-nvl(mcsub.accounted_cr,0)+nvl(mcsub.accounted_nr_tax,0)),
                 (nvl(mcsub.ACCOUNTED_DR,0)-nvl(mcsub.accounted_nr_tax,0))) amount -- Bug 40571541 Added Nvl() clause for accounted_cr or accounted_cr as only one can be populated at a time
     INTO x_exchange_rate,
          x_exchange_date,
          x_exchange_rate_type,
          x_amount
     FROM rcv_transactions rcvtxn,
          rcv_receiving_sub_ledger rcvsub,
          rcv_mc_rec_sub_ledger mcsub,
          rcv_mc_transactions mctxn,
          po_distributions po_dist
    WHERE rcvtxn.transaction_id           = l_rcv_txn_id
      AND rcvtxn.po_distribution_id       = x_po_dist_id
      AND rcvtxn.po_distribution_id       = po_dist.po_distribution_id
      AND po_dist.code_combination_id     = rcvsub.code_combination_id
      AND po_dist.code_combination_id     = mcsub.code_combination_id
      AND rcvsub.actual_flag              = 'A'
      AND mcsub.actual_flag              = 'A'
      AND rcvtxn.transaction_id           = rcvsub.rcv_transaction_id
      AND rcvtxn.transaction_id           = mctxn.transaction_id
      AND rcvtxn.transaction_id           = mcsub.RCV_TRANSACTION_ID
      AND mctxn.SET_OF_BOOKS_ID           = x_sob
      AND mcsub.SET_OF_BOOKS_ID           = x_sob
      AND rcvsub.accounting_event_id      = nvl(x_acct_evt_id, rcvsub.accounting_event_id) -- pricing changes
      AND mcsub.accounting_event_id       = nvl(x_acct_evt_id, mcsub.accounting_event_id); -- pricing changes

ELSIF x_transaction_source IN ('PO RECEIPT NRTAX', 'PO RECEIPT NRTAX PRICE ADJ') THEN -- pricing changes

   /* If it is a tax line, we want to take the positive amount of the tax column if the
      transaction is an 'EXPENSE'. If the transaction is a 'RECEIVING', then we take the
      negative value of the tax column. */

   SELECT mcsub.CURRENCY_CONVERSION_RATE exchange_rate,  --Bug#3218750
          -- Bug#3218750 decode(NVL(rcvsub.ACCOUNTED_DR,0),0,mcsub.CURRENCY_CONVERSION_RATE,
          -- Bug#3218750  (mcsub.ACCOUNTED_DR/rcvsub.accounted_dr)) exchange_rate,
          nvl(mcsub.CURRENCY_CONVERSION_DATE,mctxn.CURRENCY_CONVERSION_DATE) exchange_date,
          nvl(mctxn.CURRENCY_CONVERSION_TYPE,rcvtxn.CURRENCY_CONVERSION_TYPE) excahnge_rate_type,
          decode(rcvtxn.transaction_type,
                 'RETURN TO RECEIVING',nvl(-mcsub.accounted_nr_tax,0),
                 'RETURN TO VENDOR',nvl(-mcsub.accounted_nr_tax,0),
		 nvl(mcsub.accounted_nr_tax,0)) amount /* Bug 4292891 */
     INTO x_exchange_rate,
          x_exchange_date,
          x_exchange_rate_type,
          x_amount
     FROM rcv_transactions rcvtxn,
          rcv_receiving_sub_ledger rcvsub,
          rcv_mc_rec_sub_ledger mcsub,
          rcv_mc_transactions mctxn,
          po_distributions po_dist
    WHERE rcvtxn.transaction_id           = l_rcv_txn_id
      AND rcvtxn.po_distribution_id       = x_po_dist_id
      AND rcvtxn.po_distribution_id       = po_dist.po_distribution_id
      AND po_dist.code_combination_id     = rcvsub.code_combination_id
      AND po_dist.code_combination_id     = mcsub.code_combination_id
      AND rcvsub.actual_flag              = 'A'
      AND mcsub.actual_flag              = 'A'
      AND rcvtxn.transaction_id           = rcvsub.rcv_transaction_id
      AND rcvtxn.transaction_id           = mctxn.transaction_id
      AND rcvtxn.transaction_id           = mcsub.RCV_TRANSACTION_ID
      AND mctxn.SET_OF_BOOKS_ID           = x_sob
      AND mcsub.SET_OF_BOOKS_ID           = x_sob
      AND rcvsub.accounting_event_id      = nvl(x_acct_evt_id, rcvsub.accounting_event_id) -- pricing changes
      AND mcsub.accounting_event_id       = nvl(x_acct_evt_id, mcsub.accounting_event_id); -- pricing changes
END IF;

   x_err_stack := l_old_stack;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_err_code := SQLCODE;
    x_exchange_rate := Null;
    x_exchange_date := Null;
    x_exchange_rate_type := Null;
    x_amount := Null;
  WHEN OTHERS THEN
    x_exchange_rate := Null;
    x_exchange_date := Null;
    x_exchange_rate_type := Null;
    x_amount := Null;
    RAISE;

END get_po_rate;

-------------------------------------------------------------
--History
--  29-APR-03 Vgade Re-Burdening Changes .

-- Description
-- This has been created to return original ei burden cost and the burden delta
-- to the CDL mrc trigger, so that the C and D lines of MRC record will have the
---prorated cost of the delta.
-- Changes
PROCEDURE eiid_details( x_eiid              IN NUMBER,
                        x_orig_trx          OUT NOCOPY VARCHAR2,
                        x_adj_item          OUT NOCOPY NUMBER,
                        x_linkage           OUT NOCOPY VARCHAR2,
                        x_ei_date           OUT NOCOPY DATE,
                        x_txn_source        OUT NOCOPY VARCHAR2,
			            x_ei_burdened_cost  OUT NOCOPY NUMBER,
			            x_ei_burdened_delta OUT NOCOPY NUMBER,
                        x_err_stack         IN OUT NOCOPY VARCHAR2,
                        x_err_stage         IN OUT NOCOPY VARCHAR2,
                        x_err_code          OUT NOCOPY NUMBER)

IS

    l_old_stack            VARCHAR2(2000);

BEGIN

    l_old_stack := x_err_stack;
    x_err_code  := 0;
    x_err_stack := x_err_stack ||'->PA_MC_CURRENCY_PKG.eiid_details';
    x_err_stage := ' Select from pa_expenditure_items_all';

 SELECT     eia.orig_transaction_reference,
            nvl(eia.adjusted_expenditure_item_id, transferred_from_exp_item_id),
            eia.system_linkage_function,
            eia.expenditure_item_date,
            eia.transaction_source,
            eia.burden_cost,
            eia.posted_projfunc_burdened_cost
 INTO       x_orig_trx,
            x_adj_item,
            x_linkage,
            x_ei_date,
            x_txn_source,
            x_ei_burdened_cost,
            x_ei_burdened_delta
 FROM       pa_expenditure_items_all eia
 WHERE      eia.expenditure_item_id = x_eiid;

   x_err_stack := l_old_stack;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_err_code := SQLCODE;
      x_orig_trx := Null;
      x_adj_item := Null;
      x_linkage := Null;
      x_ei_date := Null;
      x_txn_source := Null;
      x_ei_burdened_cost := Null;
      x_ei_burdened_delta := Null;

   WHEN OTHERS THEN
      x_orig_trx := Null;
      x_adj_item := Null;
      x_linkage := Null;
      x_ei_date := Null;
      x_txn_source := Null;
      x_ei_burdened_cost := Null;
      x_ei_burdened_delta := Null;
      RAISE;

END eiid_details;

-------------------------------------------------------------

END PA_MC_CURRENCY_PKG;

/
