--------------------------------------------------------
--  DDL for Package Body JL_ZZ_AP_EXT_AWT_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_ZZ_AP_EXT_AWT_UTIL" AS
/*$Header: jlzzpwub.pls 120.3 2006/08/03 06:33:27 dbetanco ship $ */

 pg_file_name               VARCHAR2(100)     := NULL ;
 pg_path_name               VARCHAR2(100)     := NULL ;
 pg_fp                      utl_file.file_type       ;
 pg_debug_flag              CHAR(1)           := 'N' ;
 pg_user_name               VARCHAR2(100)     := NULL;
 pg_user_id                 NUMBER            := NULL;
 l_line                     varchar2(1999) ;
 pg_debug_level             NUMBER ;

/* ---------------------------------------------------------------------*
 |Public Procedure                                                       |
 |      debug        Write the text message  in log file                 |
 |                   if the debug is set "Yes".                          |
 | Description       This procedure will generate the standard debug     |
 |                   information in to the log file.User can open the    |
 |                   log file <user name.log> at specified location.     |
 |                                                                       |
 | Requires                                                              |
 |      p_line       The line of debug messages that will be writen      |
 |                   in the log file.                                    |
 | Exception Raised                                                      |
 |                                                                       |
 | Known Bugs                                                            |
 |                                                                       |
 | Notes                                                                 |
 |                                                                       |
 | History                                                               |
 |                                                                       |
 *-----------------------------------------------------------------------*/
PROCEDURE debug(
  p_line   IN VARCHAR2
)   IS

  p_module_name VARCHAR2(50);
  g_log_statement_level   NUMBER;
  g_current_runtime_level number;
  g_level_event           CONSTANT  NUMBER := FND_LOG.LEVEL_EVENT;
  g_level_exception       CONSTANT  NUMBER := FND_LOG.LEVEL_EXCEPTION;
  g_level_unexpected      CONSTANT  NUMBER := FND_LOG.LEVEL_UNEXPECTED;

BEGIN
  p_module_name  := 'JL:Extended Withholding';
  g_log_statement_level    := FND_LOG.LEVEL_STATEMENT;
  pg_debug_level :=FND_LOG.LEVEL_PROCEDURE;
  g_current_runtime_level:=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;

/*
   IF  ( pg_debug_level >=  g_current_runtime_level) THEN
       IF lengthb(p_line) > 1999 THEN
          l_line := substrb(p_line,1,1999) ;
       ELSE
          l_line := p_line ;
       END IF;

       fnd_log.string(
              LOG_LEVEL => pg_debug_level,
              MODULE => p_module_name,
              MESSAGE => l_line);
  END IF;
*/


  IF  ( g_log_statement_level >=  g_current_runtime_level) THEN
       IF lengthb(p_line) > 1999 THEN
          l_line := substrb(p_line,1,1999) ;
       ELSE
          l_line := p_line ;
       END IF;

       fnd_log.string(
              LOG_LEVEL => g_log_statement_level,
              MODULE => p_module_name,
              MESSAGE => l_line);
  END IF;

EXCEPTION
       WHEN  others THEN
         IF (g_level_unexpected >= g_current_runtime_level ) THEN
           fnd_log.string(
              LOG_LEVEL => FND_LOG.LEVEL_UNEXPECTED,
              MODULE => p_module_name,
              MESSAGE => 'Unexpected Error When Logging Debug Messages.');
         END IF;


END  debug;


/**************************************************************************
 *                                                                        *
 * Name       : Print_Tax_Names                                           *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/

PROCEDURE Print_Tax_Names (P_Tab_Payment_Wh  IN JL_ZZ_AP_WITHHOLDING_PKG.Tab_Withholding)
IS
    tab   JL_ZZ_AP_WITHHOLDING_PKG.Tab_Withholding := P_Tab_Payment_Wh;
    pos   Number;


BEGIN
  IF tab.count > 0 THEN
    JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
    JL_ZZ_AP_EXT_AWT_UTIL.Debug('*** Data From a Tab Withholding ***');

    FOR pos IN 1 .. tab.COUNT LOOP
     JL_ZZ_AP_EXT_AWT_UTIL.Debug(' POSITION = '        || to_char(pos));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Invoice ID: '     || to_char(tab(pos).invoice_id));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Distr.Line: '      || to_char(tab(pos).invoice_distribution_id));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   AWT Type Code: '   || tab(pos).awt_type_code);
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Jurisdiction: '   || tab(pos).jurisdiction_type);
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Tax ID: '         || to_char(tab(pos).tax_id));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Tax Name: '        || tab(pos).tax_name);
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Tax Code Comb. ID: '   || to_char(tab(pos).tax_code_combination_id));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   AWT Period Type: '     || tab(pos).awt_period_type);
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Tax Rate ID: '         || to_char(tab(pos).rate_id));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Line Amount: '         || to_char(tab(pos).line_amount));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Taxable Base Amount: ' || to_char(tab(pos).taxable_base_amount));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Revised Base Amount: ' || to_char(tab(pos).revised_tax_base_amount));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Withheld Amount: '     || to_char(tab(pos).withheld_amount));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Prorated Amount: '     || to_char(tab(pos).prorated_amount));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Invoice_Pay_Id : '     || to_char(tab(pos).invoice_payment_id));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Payment_Num : '        || to_char(tab(pos).payment_num));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Applicable Flag: '     || tab(pos).applicable_flag);
     JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Exemption Amount: '    || to_char(tab(pos).exemption_amount));
     JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
    END LOOP;
    JL_ZZ_AP_EXT_AWT_UTIL.Debug('*** END Tab Withholding ***');
    JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
  END IF;
END Print_Tax_Names;

/**************************************************************************
 *                                                                        *
 * Name       : Print_tab_all_wh                                          *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/

PROCEDURE Print_tab_all_wh (P_tab_all_wh  IN JL_ZZ_AP_WITHHOLDING_PKG.Tab_All_Withholding)
IS
    tab   JL_ZZ_AP_WITHHOLDING_PKG.Tab_All_Withholding := P_tab_all_wh;
    pos   Number;


BEGIN
  IF tab.count > 0 THEN
    JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
    JL_ZZ_AP_EXT_AWT_UTIL.Debug('* Data From a Tab ALL Withholding * ');

    FOR pos IN 1 .. tab.COUNT LOOP
       JL_ZZ_AP_EXT_AWT_UTIL.Debug(' POSITION = '        || to_char(pos));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Invoice ID: '     || to_char(tab(pos).invoice_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Distr.Line: '     || to_char(tab(pos).invoice_distribution_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   AWT Type Code: '  || tab(pos).awt_type_code);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Jurisdiction: '   || tab(pos).jurisdiction_type);
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Prorated Amount: '  || to_char(tab(pos).prorated_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
    END LOOP;

    JL_ZZ_AP_EXT_AWT_UTIL.Debug('* END Tab ALL Withholding * ');
    JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');

  END IF;

END Print_tab_all_wh;

/**************************************************************************
 *                                                                        *
 * Name       : Print_tab_amounts                                         *
 * Purpose    : This procedure shows all the elements of the PL/SQL table *
 *              (just for debug purposes)                                 *
 *                                                                        *
 **************************************************************************/

PROCEDURE Print_tab_amounts (P_tab_Amounts IN JL_AR_AP_WITHHOLDING_PKG.Tab_Amounts)

IS
    tab   JL_AR_AP_WITHHOLDING_PKG.Tab_Amounts := P_tab_Amounts;
    pos   Number;


BEGIN
  IF tab.count > 0 THEN
    JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
    JL_ZZ_AP_EXT_AWT_UTIL.Debug('** Data From a Tab Amounts **');

    FOR pos IN 1 .. tab.COUNT LOOP
       JL_ZZ_AP_EXT_AWT_UTIL.Debug(' POSITION = '      || to_char(pos));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Invoice ID: '   || to_char(tab(pos).invoice_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Distr.Line: '   || to_char(tab(pos).invoice_distribution_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Amount: '              || to_char(tab(pos).amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Tax_inclusive_amount: '|| to_char(tab(pos).tax_inclusive_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Payment_amount: '      || to_char(tab(pos).payment_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Taxable_base_amount: ' || to_char(tab(pos).taxable_base_amount));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Prorated_tax_incl_amt: ' || to_char(tab(pos).prorated_tax_incl_amt));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Invoice_payment_id: '  || to_char(tab(pos).invoice_payment_id));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug('   Invoice_payment_num: '  || to_char(tab(pos).invoice_payment_num));
       JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');
    END LOOP;

    JL_ZZ_AP_EXT_AWT_UTIL.Debug('** END Tab Amounts **');
    JL_ZZ_AP_EXT_AWT_UTIL.Debug(' ');

  END IF;

END Print_tab_amounts;

PROCEDURE initialize  IS
BEGIN


     pg_file_name   := NULL ;
     pg_path_name   := NULL ;
     pg_debug_flag  := 'N' ;
     pg_user_name   := NULL;


     FND_PROFILE.GET('EXT_AWT_DEBUG_FLAG',pg_debug_flag) ;
     FND_PROFILE.GET('EXT_AWT_DEBUG_FILE_LOCATION',pg_path_name);


     IF  pg_user_name is NULL  THEN

            FND_PROFILE.GET('USERNAME', pg_user_name);

            IF pg_user_name IS NULL THEN
                  pg_user_name := 'DEFAULT';
            END IF;

     END IF;

     IF   pg_debug_flag ='Y'    THEN

          pg_path_name := pg_path_name ;

          pg_file_name  :=  pg_user_name ||'.log' ;
          pg_fp         := utl_file.fopen(pg_path_name, pg_file_name, 'W') ;

          -- Header File
          Debug('*========================================================*');
          Debug(' ');
          Debug('         JL EXTENDED WIHTHHOLDING DEBUG FILE');
          Debug(' ');
          Debug('Profiles used to generate the output file: ');
          Debug('1. Extended Withholding: Debug Flag');
          Debug('2. Extended Withholding: Debug File Directory');
          Debug(' ');
          Debug('File shows: ');
          Debug('1. Pleace from the procedure/function is called by the symbol (==> Procedure Name)');
          Debug('2. Procedure/Function Parameters');
          Debug('3. Cursors fetched values');
          Debug('4. PLSQL Tables there are three tables: ');
          Debug('         4.1.  Tab Withholding ');
          Debug('         4.2.  Tab ALL Withholding ');
          Debug('         4.3.  Tab Amounts ');
          Debug('5. Sequence Steps');
          Debug('*========================================================*');
          Debug(' ');

     END IF;

EXCEPTION

     WHEN  utl_file.invalid_path THEN
          FND_MESSAGE.SET_NAME('JL','JL_ZZ_AP_AWT_LOG_INVALID_PATH');
          FND_MESSAGE.SET_TOKEN('PATH_NAME',pg_path_name );
          app_exception.raise_exception ;

     WHEN  others THEN
          null;

END;


/*------------------ Package Constructor --------------------------------*/

BEGIN

         initialize;

END JL_ZZ_AP_EXT_AWT_UTIL ;

/
