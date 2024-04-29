--------------------------------------------------------
--  DDL for Package Body ZX_C_JX_EXTRACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ZX_C_JX_EXTRACT" AS
/*$Header: zxrxcjxextpb.pls 120.2 2005/07/08 02:30:59 apai noship $*/

  --Parameter for holding conc request ID
  p_request_id            NUMBER ;

/* +=======================================================+
   | START of RXi Procedures                               |
   |=======================================================|
   |                                                       |
   | Each procedure will have a heading file which lists   |
   | all the parameters passed to that report detaling     |
   | what the paramters correspond to                      |
   +=======================================================+  */

/* +=======================================================+
   |            Czech Export Tax Report (ZXRXCZEX)         |
   |=======================================================|
   |                                                       |
   | reporting level = '1000' (SOB)                        |
   | reporting context = argument1                         |
   | register type   = 'TAX'                               |
   | tax class       = 'O' -- Output/AR                    |
   | summary level   = 'TRANSACTION'                       |
   | posting status  = 'POSTED'                            |
   | p_matrix_report = 'Y'                                 |
   | product         = 'AR'                                |
   | tax code category  = 'JE.CZ.ARXSUVAT.TAX_ORIGIN'      |
   | tax code att1      = 'E'                              |
   | tax code type low  =  argument2                       |
   | tax code type high =  argument2                       |
   | argument1       = Set of Books ID                     |
   | argument2       = Tax Code Type                       |
   | argument3       = GL Date From                        |
   | argument4       = GL Date To                          |
   | argument5       = Tax Date From                       |
   | argument6       = Tax Date To                         |
   |                                                       |
   | Notes :         This is a normal select RXi report    |
   |                                                       |
   | History:        10-AUG-99 mbickley, Created           |
   |                                                       |
   +=======================================================+  */

PROCEDURE POPULATE_CZ_TAX(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2,
  argument2         IN  VARCHAR2,
  argument3         IN  VARCHAR2,
  argument4         IN  VARCHAR2,
  argument5         IN  VARCHAR2,
  argument6         IN  VARCHAR2,
  argument7         IN  VARCHAR2,
  argument8         IN  VARCHAR2,
  argument9         IN  VARCHAR2,
  argument10        IN  VARCHAR2,
  argument11        IN  VARCHAR2,
  argument12        IN  VARCHAR2,
  argument13        IN  VARCHAR2,
  argument14        IN  VARCHAR2,
  argument15        IN  VARCHAR2,
  argument16        IN  VARCHAR2,
  argument17        IN  VARCHAR2,
  argument18        IN  VARCHAR2,
  argument19        IN  VARCHAR2,
  argument20        IN  VARCHAR2,
  argument21        IN  VARCHAR2,
  argument22        IN  VARCHAR2,
  argument23        IN  VARCHAR2,
  argument24        IN  VARCHAR2,
  argument25        IN  VARCHAR2,
  argument26        IN  VARCHAR2,
  argument27        IN  VARCHAR2,
  argument28        IN  VARCHAR2,
  argument29        IN  VARCHAR2,
  argument30        IN  VARCHAR2,
  argument31        IN  VARCHAR2,
  argument32        IN  VARCHAR2,
  argument33        IN  VARCHAR2,
  argument34        IN  VARCHAR2,
  argument35        IN  VARCHAR2,
  argument36        IN  VARCHAR2,
  argument37        IN  VARCHAR2,
  argument38        IN  VARCHAR2,
  argument39        IN  VARCHAR2,
  argument40        IN  VARCHAR2,
  argument41        IN  VARCHAR2,
  argument42        IN  VARCHAR2,
  argument43        IN  VARCHAR2,
  argument44        IN  VARCHAR2,
  argument45        IN  VARCHAR2,
  argument46        IN  VARCHAR2,
  argument47        IN  VARCHAR2,
  argument48        IN  VARCHAR2,
  argument49        IN  VARCHAR2,
  argument50        IN  VARCHAR2,
  argument51        IN  VARCHAR2,
  argument52        IN  VARCHAR2,
  argument53        IN  VARCHAR2,
  argument54        IN  VARCHAR2,
  argument55        IN  VARCHAR2,
  argument56        IN  VARCHAR2,
  argument57        IN  VARCHAR2,
  argument58        IN  VARCHAR2,
  argument59        IN  VARCHAR2,
  argument60        IN  VARCHAR2,
  argument61        IN  VARCHAR2,
  argument62        IN  VARCHAR2,
  argument63        IN  VARCHAR2,
  argument64        IN  VARCHAR2,
  argument65        IN  VARCHAR2,
  argument66        IN  VARCHAR2,
  argument67        IN  VARCHAR2,
  argument68        IN  VARCHAR2,
  argument69        IN  VARCHAR2,
  argument70        IN  VARCHAR2,
  argument71        IN  VARCHAR2,
  argument72        IN  VARCHAR2,
  argument73        IN  VARCHAR2,
  argument74        IN  VARCHAR2,
  argument75        IN  VARCHAR2,
  argument76        IN  VARCHAR2,
  argument77        IN  VARCHAR2,
  argument78        IN  VARCHAR2,
  argument79        IN  VARCHAR2,
  argument80        IN  VARCHAR2,
  argument81        IN  VARCHAR2,
  argument82        IN  VARCHAR2,
  argument83        IN  VARCHAR2,
  argument84        IN  VARCHAR2,
  argument85        IN  VARCHAR2,
  argument86        IN  VARCHAR2,
  argument87        IN  VARCHAR2,
  argument88        IN  VARCHAR2,
  argument89        IN  VARCHAR2,
  argument90        IN  VARCHAR2,
  argument91        IN  VARCHAR2,
  argument92        IN  VARCHAR2,
  argument93        IN  VARCHAR2,
  argument94        IN  VARCHAR2,
  argument95        IN  VARCHAR2,
  argument96        IN  VARCHAR2,
  argument97        IN  VARCHAR2,
  argument98        IN  VARCHAR2,
  argument99        IN  VARCHAR2,
  argument100       IN  VARCHAR2)
IS

trl_exception   EXCEPTION;

BEGIN

  --Get request ID
  p_request_id := fnd_global.conc_request_id;

  --Call the Tax Extract procedure mapping parameters
  zx_extract_pkg.populate_tax_data (
    p_request_id                  => p_request_id
   ,p_retcode                     => retcode
   ,p_errbuf                      => errbuf
   ,p_reporting_level             => 1000
   ,p_reporting_context           => to_number(argument1)
   ,p_register_type               => 'TAX'
--apai **  ,p_tax_class                   => 'O'
   ,p_summary_level               => 'TRANSACTION'
   ,p_posting_status              => 'POSTED'
   ,p_gl_date_low	          => to_date(argument3, 'YYYY/MM/DD HH24:MI:SS')
   ,p_gl_date_high                => to_date(argument4, 'YYYY/MM/DD HH24:MI:SS')
--apai ** check with Kripa  ,p_gbl_tax_date_low            => to_date(argument5, 'YYYY/MM/DD HH24:MI:SS')
--apai ** check with Kripa  ,p_gbl_tax_date_high           => to_date(argument6, 'YYYY/MM/DD HH24:MI:SS')
--apai ** check with Kripa  ,p_gdf_ar_tax_codes_category   => 'JE.CZ.ARXSUVAT.TAX_ORIGIN'
--apai ** check with Kripa  ,p_gdf_ar_tax_codes_att1       => 'E'
--apai ** check with Kripa  ,p_tax_code_type_low           => argument2
--apai ** check with Kripa  ,p_tax_code_type_high          => argument2
   ,p_product                     => 'AR'
   );


IF retcode = 2 THEN
   raise trl_exception;
END IF;

EXCEPTION
  WHEN trl_exception THEN
    RAISE_APPLICATION_ERROR (-20010, 'Tax Extract call has failed');
    RAISE;

  WHEN others THEN
    RAISE;

END POPULATE_CZ_TAX;


/* +==========================================================================+
   |      Thai Output Tax Summary Report (RXZXPTOT)                           |
   |==========================================================================|
   |                                                                          |
   | register_type   = 'TAX'                                                  |
   | tax_class       = 'O'                                                    |
   | summary_level   = 'TRANSACTION'                                          |
   | posting_status  = 'POSTED'                                               |
   | matrix_report   = 'N'                                                    |
   | argument1       = product                                                |
   | argument2       = reporting_level                                        |
   | argument3       = reporting_context                                      |
   | argument4       = gl_period_name_low                                     |
   | argument5       = gl_period_name_high                                    |
   | argument6       = tax_code_type                                          |
   | argument7       = tax_code                                               |
   | argument8       = debug_flag                                             |
   | argument9       = sql_trace                                              |
   |                                                                          |
   | History                                                                  |
   |   10/14/1999  S. Okuda  Created.                                         |
   |                                                                          |
   +=======================================================================+ */
PROCEDURE POPULATE_TH_TAX(
  errbuf            OUT NOCOPY VARCHAR2,
  retcode           OUT NOCOPY VARCHAR2,
  argument1         IN  VARCHAR2,
  argument2         IN  VARCHAR2,
  argument3         IN  VARCHAR2,
  argument4         IN  VARCHAR2,
  argument5         IN  VARCHAR2,
  argument6         IN  VARCHAR2,
  argument7         IN  VARCHAR2,
  argument8         IN  VARCHAR2,
  argument9         IN  VARCHAR2,
  argument10        IN  VARCHAR2,
  argument11        IN  VARCHAR2,
  argument12        IN  VARCHAR2,
  argument13        IN  VARCHAR2,
  argument14        IN  VARCHAR2,
  argument15        IN  VARCHAR2,
  argument16        IN  VARCHAR2,
  argument17        IN  VARCHAR2,
  argument18        IN  VARCHAR2,
  argument19        IN  VARCHAR2,
  argument20        IN  VARCHAR2,
  argument21        IN  VARCHAR2,
  argument22        IN  VARCHAR2,
  argument23        IN  VARCHAR2,
  argument24        IN  VARCHAR2,
  argument25        IN  VARCHAR2,
  argument26        IN  VARCHAR2,
  argument27        IN  VARCHAR2,
  argument28        IN  VARCHAR2,
  argument29        IN  VARCHAR2,
  argument30        IN  VARCHAR2,
  argument31        IN  VARCHAR2,
  argument32        IN  VARCHAR2,
  argument33        IN  VARCHAR2,
  argument34        IN  VARCHAR2,
  argument35        IN  VARCHAR2,
  argument36        IN  VARCHAR2,
  argument37        IN  VARCHAR2,
  argument38        IN  VARCHAR2,
  argument39        IN  VARCHAR2,
  argument40        IN  VARCHAR2,
  argument41        IN  VARCHAR2,
  argument42        IN  VARCHAR2,
  argument43        IN  VARCHAR2,
  argument44        IN  VARCHAR2,
  argument45        IN  VARCHAR2,
  argument46        IN  VARCHAR2,
  argument47        IN  VARCHAR2,
  argument48        IN  VARCHAR2,
  argument49        IN  VARCHAR2,
  argument50        IN  VARCHAR2,
  argument51        IN  VARCHAR2,
  argument52        IN  VARCHAR2,
  argument53        IN  VARCHAR2,
  argument54        IN  VARCHAR2,
  argument55        IN  VARCHAR2,
  argument56        IN  VARCHAR2,
  argument57        IN  VARCHAR2,
  argument58        IN  VARCHAR2,
  argument59        IN  VARCHAR2,
  argument60        IN  VARCHAR2,
  argument61        IN  VARCHAR2,
  argument62        IN  VARCHAR2,
  argument63        IN  VARCHAR2,
  argument64        IN  VARCHAR2,
  argument65        IN  VARCHAR2,
  argument66        IN  VARCHAR2,
  argument67        IN  VARCHAR2,
  argument68        IN  VARCHAR2,
  argument69        IN  VARCHAR2,
  argument70        IN  VARCHAR2,
  argument71        IN  VARCHAR2,
  argument72        IN  VARCHAR2,
  argument73        IN  VARCHAR2,
  argument74        IN  VARCHAR2,
  argument75        IN  VARCHAR2,
  argument76        IN  VARCHAR2,
  argument77        IN  VARCHAR2,
  argument78        IN  VARCHAR2,
  argument79        IN  VARCHAR2,
  argument80        IN  VARCHAR2,
  argument81        IN  VARCHAR2,
  argument82        IN  VARCHAR2,
  argument83        IN  VARCHAR2,
  argument84        IN  VARCHAR2,
  argument85        IN  VARCHAR2,
  argument86        IN  VARCHAR2,
  argument87        IN  VARCHAR2,
  argument88        IN  VARCHAR2,
  argument89        IN  VARCHAR2,
  argument90        IN  VARCHAR2,
  argument91        IN  VARCHAR2,
  argument92        IN  VARCHAR2,
  argument93        IN  VARCHAR2,
  argument94        IN  VARCHAR2,
  argument95        IN  VARCHAR2,
  argument96        IN  VARCHAR2,
  argument97        IN  VARCHAR2,
  argument98        IN  VARCHAR2,
  argument99        IN  VARCHAR2,
  argument100       IN  VARCHAR2)
IS
  v_product                        VARCHAR2(50);
  v_reporting_level                VARCHAR2(50);
  v_reporting_context              NUMBER;
  v_gl_period_name_low             VARCHAR2(50);
  v_gl_period_name_high            VARCHAR2(50);
  v_tax_code_type                  VARCHAR2(50);
  v_tax_code                       VARCHAR2(50);
  debug_flag                       VARCHAR2(1);
  sql_trace                        VARCHAR2(1);
  v_request_id                     NUMBER;
  v_tax_regime_code                VARCHAR2(30);
  v_tax                            VARCHAR2(30);
  v_tax_jurisdiction               VARCHAR2(30);
  v_tax_status_code                VARCHAR2(30);


BEGIN
  v_product                          := argument1;
  v_reporting_level                  := argument2;
  v_reporting_context                := to_number(argument3);
  v_gl_period_name_low               := argument4;
  v_gl_period_name_high              := argument5;
  v_tax_code_type                    := argument6;
  /* apai */
  v_tax_regime_code                  := argument7;
  v_tax                              := argument8;
  v_tax_jurisdiction                 := argument9;
  v_tax_status_code                  := argument10;
  /* ** */
  v_tax_code                         := argument11;
  debug_flag                         := upper(substrb(argument12,1,1));
  sql_trace                          := upper(substrb(argument13,1,1));
  v_request_id                       := fnd_global.conc_request_id;

  --
  -- SQL Trace and Debug Flags are optional.
  --

  -- SQL trace calls commented as ATG mandate
    -- IF sql_trace = 'Y' THEN
    --  fa_rx_util_pkg.enable_trace;
    -- END IF;

  IF debug_flag = 'Y' THEN
    fa_rx_util_pkg.enable_debug;
  END IF;

  --
  -- Run the Tax Extract
  --
  zx_extract_pkg.populate_tax_data(
        p_register_type                   =>  'TAX',
        p_reporting_level                 =>  v_reporting_level,
        p_reporting_context               =>  v_reporting_context,
        p_gl_period_name_low              =>  v_gl_period_name_low,
        p_gl_period_name_high             =>  v_gl_period_name_high,
        p_tax_type_code_low               =>  v_tax_code_type,
        p_tax_type_code_high              =>  v_tax_code_type,
        /* apai */
        p_tax_regime_code                 =>  v_tax_regime_code,
        p_tax                             =>  v_tax,
        p_tax_jurisdiction_code           =>  v_tax_jurisdiction,
        p_tax_status_code                 =>  v_tax_status_code,
        /* ** */
        p_tax_rate_code_low               =>  v_tax_code,
        p_tax_rate_code_high              =>  v_tax_code,
--apai **       p_tax_class                       =>  'O',
        p_summary_level                   =>  'TRANSACTION',
        p_product                         =>  v_product,
        p_posting_status                  =>  'POSTED',
        p_matrix_report                   =>  'N',
        p_retcode                         =>  retcode,
        p_errbuf                          =>  errbuf,
        p_request_id                      =>  v_request_id
  );

  --
  -- Now Disable the SQL Trace and Debug Flags if enabled.
  --

  -- SQL trace calls commented as ATG mandate
    -- IF sql_trace = 'Y' THEN
    --  fa_rx_util_pkg.disable_trace;
    -- END IF;

  IF debug_flag = 'Y' THEN
    fa_rx_util_pkg.disable_debug;
  END IF;


END POPULATE_TH_TAX;

END ZX_C_JX_EXTRACT;

/
