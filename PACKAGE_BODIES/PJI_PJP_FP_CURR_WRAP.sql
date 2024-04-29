--------------------------------------------------------
--  DDL for Package Body PJI_PJP_FP_CURR_WRAP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_PJP_FP_CURR_WRAP" AS
/* $Header: PJIPUT2B.pls 120.3 2006/03/08 00:15:11 appldev noship $ */

/* Notes to developer:
    Rename
     1. pji_fp_xbs_accum_f_2 to pji_fp_xbs_accum_f.
     2. pji_fp_xbs_accum_f_1 to pji_fp_aggr_pjp1_tmp.
     3. Remove all references to dblink on pjdev115.
*/

g_package_name VARCHAR2(100) := 'PJI_PJP_FP_CURR_WRAP';

-----------------------------------------------------------------------
----- Misc apis.. wrappers for apis to be provided by Shane -----------
-----------------------------------------------------------------------

function GET_GLOBAL1_CURR_CODE RETURN VARCHAR2 IS
BEGIN
  RETURN PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
END;


function GET_GLOBAL2_CURR_CODE RETURN VARCHAR2 IS
BEGIN
  RETURN PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;
END;


function GET_GLOBAL_RATE_PRIMARY(p_FROM_currency_code VARCHAR2, p_exchange_date date)
return NUMBER IS
BEGIN
  RETURN PJI_UTILS.get_global_rate_primary(
      p_from_currency_code  => p_FROM_currency_code,
      p_exchange_date       => p_exchange_date
  );
END;


function GET_MAU_PRIMARY return NUMBER IS
BEGIN
  RETURN PJI_UTILS.GET_MAU_PRIMARY;
END;


function GET_GLOBAL_RATE_SECONDARY (p_FROM_currency_code VARCHAR2, p_exchange_date DATE)
return NUMBER IS
BEGIN
  RETURN PJI_UTILS.get_global_rate_secondary(
      p_from_currency_code  => p_FROM_currency_code,
      p_exchange_date       => p_exchange_date
  );
END;


function GET_MAU_SECONDARY return NUMBER IS
BEGIN
  RETURN PJI_UTILS.GET_MAU_SECONDARY;
END;


function GET_RATE(p_FROM_currency_code VARCHAR2, p_to_currency_code VARCHAR2, p_exchange_date date) return NUMBER IS
BEGIN
  RETURN 0.01;
END;


function GET_MAU (p_currency_code VARCHAR2) return NUMBER IS
BEGIN
  RETURN 0.01;
END;


FUNCTION GET_WORKER_ID RETURN NUMBER IS
  l_worker_id NUMBER;
  l_return_status VARCHAR2(100) := NULL;
BEGIN

     INIT_ERR_STACK
     ( p_package_name   => g_package_name
     , x_return_status  => l_return_status );

  BEGIN
    l_worker_id := PJI_PJP_EXTRACTION_UTILS.GET_WORKER_ID;
  EXCEPTION
  WHEN OTHERS
    THEN l_worker_id := 1;
  END;

  RETURN l_worker_id;

EXCEPTION
  WHEN OTHERS THEN
    EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'get_ent_dates_info'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE get_ent_dates_info (
   x_global_start_date      OUT NOCOPY  DATE
 , x_ent_start_period_id    OUT NOCOPY  NUMBER
 , x_ent_start_period_name  OUT NOCOPY  VARCHAR2
 , x_ent_start_date         OUT NOCOPY  DATE
 , x_ent_END_date           OUT NOCOPY  DATE
 , x_global_start_J         OUT NOCOPY  VARCHAR2
 , x_ent_start_J            OUT NOCOPY  VARCHAR2
 , x_ent_END_J              OUT NOCOPY  VARCHAR2
) IS
  l_return_status VARCHAR2(100) := NULL;
BEGIN

     INIT_ERR_STACK
     ( p_package_name   => g_package_name
     , x_return_status  => l_return_status );

     x_global_start_date := pji_utils.GET_EXTRACTION_START_DATE;
          -- TO_DATE(PJI_UTILS.GET_PARAMETER('GLOBAL_START_DATE') , PJI_FM_SUM_MAIN.g_date_mask);

     BEGIN
       SELECT ent_period_id,name,start_date,END_date
       INTO   x_ent_start_period_id, x_ent_start_period_name, x_ent_start_date, x_ent_END_date
       FROM   pji_time_ent_period
       WHERE  x_global_start_date BETWEEN start_date AND END_date;
     EXCEPTION
       WHEN NO_DATA_FOUND THEN
         x_ent_start_period_id := NULL;
         x_ent_start_period_name := NULL;
         x_ent_start_date := NULL;
         x_ent_END_date := NULL;
     END;

     x_global_start_J    := to_char(x_global_start_date,'J');
     x_ent_start_J       := to_char(x_ent_start_date,'J');
     x_ent_END_J         := to_char(x_ent_END_date,'J');

EXCEPTION
  WHEN OTHERS THEN
    EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'get_ent_dates_info'
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE get_global_currency_info (
   x_currency_conversion_rule OUT NOCOPY  VARCHAR2
 , x_prorating_format         OUT NOCOPY  VARCHAR2
 , x_global1_currency_code    OUT NOCOPY  VARCHAR2
 , x_global2_currency_code    OUT NOCOPY  VARCHAR2
 , x_global1_currency_mau     OUT NOCOPY  NUMBER
 , x_global2_currency_mau     OUT NOCOPY  NUMBER ) IS

  l_return_status VARCHAR2(100) := NULL;

BEGIN

   INIT_ERR_STACK
   ( p_package_name   => g_package_name
   , x_return_status  => l_return_status );


   BEGIN
     x_global1_currency_mau  := GET_MAU_PRIMARY;
     x_global2_currency_mau  := GET_MAU_SECONDARY;
   EXCEPTION
     WHEN OTHERS THEN
       EXCP_HANDLER
       ( p_package_name   => g_package_name
       , p_procedure_name => 'get_global_currency_mau '
       , x_return_status  => l_return_status ) ;
       RAISE;
   END;

   BEGIN
     SELECT DECODE (planamt_alloc_method
                  , 'PERIOD_START', 'S'
                  , 'PERIOD_END',   'E'
  	  	      , 'DAILY',        'D'
                  , 'X')
     INTO   x_prorating_format
     FROM   pji_system_settings;

     IF (x_prorating_format = 'X') THEN
       fnd_message.set_name('PJI', 'PJI_PLNAMTALLOC_MISSING');
       dbms_standard.raise_application_error(-20000, fnd_message.get);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       fnd_message.set_name('PJI', 'PJI_PLNAMTALLOC_MISSING');
       dbms_standard.raise_application_error(-20000, fnd_message.get);
   END;


   BEGIN
     SELECT DECODE ( planamt_conv_date
                   , 'FIRST_DAY', 'S'
    		       , 'LAST_DAY', 'E'
                   , 'X')
     INTO   x_currency_conversion_rule
     FROM   pji_system_settings;

     IF (x_currency_conversion_rule = 'X') THEN
       fnd_message.set_name('PJI', 'PJI_PLNAMTCONV_MISSING');
       dbms_standard.raise_application_error(-20000, fnd_message.get);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       fnd_message.set_name('PJI', 'PJI_PLNAMTCONV_MISSING');
       dbms_standard.raise_application_error(-20000, fnd_message.get);
   END;


   BEGIN
     x_global1_currency_code       := PJI_UTILS.GET_GLOBAL_PRIMARY_CURRENCY;
     x_global2_currency_code       := PJI_UTILS.GET_GLOBAL_SECONDARY_CURRENCY;
   EXCEPTION
     WHEN OTHERS THEN RAISE;
   END;

EXCEPTION
  WHEN OTHERS THEN
    EXCP_HANDLER
    ( p_package_name   => g_package_name
    , p_procedure_name => 'get_global_currency_info '
    , x_return_status  => l_return_status ) ;

    RAISE;
END;


PROCEDURE PRINT_TIME(p_tag IN VARCHAR2) IS
  l_tag VARCHAR2(500) := p_tag || ' ' || to_char(sysdate, 'HH:MI:SS' ) || ' sid ' || userenv('SESSIONID') ;
BEGIN
  -- dbms_output.put_line(l_tag);
  -- hr_utility.trace(l_tag);
  PJI_UTILS.WRITE2LOG(p_msg => l_tag);
EXCEPTION
  WHEN OTHERS THEN
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => g_package_name ,
                             p_procedure_name => 'PRINT_TIME');
    NULL;
END;


PROCEDURE EXCP_HANDLER
( p_context        IN  VARCHAR2 := 'ERR'
, p_package_name   IN  VARCHAR2 := NULL
, p_procedure_name IN  VARCHAR2 := NULL
-- , x_processing_code OUT NOCOPY  VARCHAR2
, x_return_status  OUT NOCOPY  VARCHAR2) IS
BEGIN

  IF ( p_context = 'ERR' ) THEN
    print_time('Error in pkg ' || p_package_name || ' procedure ' || p_procedure_name || ' is: ' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    -- x_processing_code := FND_API.G_RET_STS_UNEXP_ERROR;
    -- pa_debug.RESET_ERR_STACK;
    FND_MSG_PUB.add_exc_msg( p_pkg_name       => p_package_name ,
                             p_procedure_name => p_procedure_name);
  ELSIF ( p_context = 'START' ) THEN
    pa_debug.RESET_ERR_STACK;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    -- x_processing_code := FND_API.G_RET_STS_SUCCESS;
    print_time('Start... ' || p_package_name || ' procedure ' || p_procedure_name );
  ELSE
    NULL;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;


PROCEDURE INIT_ERR_STACK
( p_package_name   IN  VARCHAR2 := NULL
, x_return_status  OUT NOCOPY  VARCHAR2) IS
BEGIN

    -- print_time('Entering pkg ' || p_package_name || ' procedure ' || p_procedure_name || ' is: ' || SQLERRM );
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    pa_debug.RESET_ERR_STACK;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END;


PROCEDURE SET_TABLE_STATS(
    p_own_name  IN VARCHAR2
  , p_tab_name  IN VARCHAR2
  , p_num_rows  IN NUMBER
  , p_num_blks  IN NUMBER
  , p_avg_r_len IN NUMBER
) IS

  l_own_name   VARCHAR2(10) := NULL;
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  /*
  print_time('p_own_name '  || p_own_name);
  print_time('p_tab_name '  || p_tab_name);
  print_time('p_num_rows '  || p_num_rows);
  print_time('p_num_blks '  || p_num_blks);
  print_time('p_avg_r_len ' || p_avg_r_len);
  */

  SELECT NVL(p_own_name, PJI_UTILS.GET_PJI_SCHEMA_NAME)
  INTO   l_own_name
  FROM   DUAL;

  -- print_time('l_own_name ' || l_own_name);

  FND_STATS.SET_TABLE_STATS (
    ownname    => l_own_name
  , tabname    => UPPER(p_tab_name)
  , numrows    => p_num_Rows
  , numblks    => p_num_blks
  , avgrlen    => p_Avg_r_len
  );

  COMMIT;

END;


END PJI_PJP_FP_CURR_WRAP;

/
