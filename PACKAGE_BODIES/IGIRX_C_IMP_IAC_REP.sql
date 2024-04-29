--------------------------------------------------------
--  DDL for Package Body IGIRX_C_IMP_IAC_REP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRX_C_IMP_IAC_REP" AS
--  $Header: igiimxcb.pls 120.3.12000000.1 2007/08/01 16:22:20 npandya noship $

 -- global variables
 g_debug_mode     BOOLEAN := FALSE;

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimxcb.igirx_c_imp_iac_rep.';

--===========================FND_LOG.END=====================================


  FUNCTION Trxns_In_Open_Period(p_dist_source_book in VARCHAR2,
                                p_book_type_code in VARCHAR2)
  RETURN BOOLEAN AS

           CURSOR C_Fa_Period_Counter
           IS
           SELECT  max(period_counter)
           from fa_deprn_periods
           where book_type_code=p_dist_source_book;

           CURSOR C_Imp_Period_Counter
           IS
           SELECT period_counter
           FROM igi_imp_iac_controls
           where book_type_code=p_book_type_code;

           CURSOR C_Trxn
       	   IS
           SELECT count(*)
           FROM   fa_transaction_headers ft ,
                  fa_deprn_periods dp
           WHERE  ft.book_type_Code        = p_dist_source_book
           AND    dp.book_type_Code        = p_dist_source_book
           AND    dp.period_close_Date     IS NULL
           AND    ft.date_effective        >= dp.period_open_date ;


       --variables
	    l_fa_period_counter      NUMBER;
       	l_imp_period_counter     NUMBER;
       	l_count                  NUMBER;
	l_path_name VARCHAR2(150):= g_path||'trxns_in_open_period';


       BEGIN

             OPEN C_Fa_Period_Counter;
             FETCH C_Fa_Period_Counter INTO l_fa_period_counter;
             CLOSE C_Fa_Period_Counter;

             OPEN C_Imp_Period_Counter;
             FETCH C_Imp_Period_Counter INTO l_imp_period_counter;
             CLOSE C_Imp_Period_Counter;

         IF (l_imp_period_counter<>l_fa_period_counter)
         THEN
             RETURN FALSE;
         ELSE
        --Check for trxns in open period
            OPEN  c_trxn;
            FETCH c_trxn INTO l_count;
            CLOSE c_trxn;

	         IF l_count>0 THEN
		        RETURN FALSE;
	        ELSE
		        RETURN TRUE;
	            END IF;

         END IF;

    EXCEPTION
            WHEN OTHERS
            THEN
  		igi_iac_debug_pkg.debug_unexpected_msg(p_full_path => l_path_name);
            RETURN FALSE ;
   END ;



 -- ====================================================================
-- PROCEDURE imp:
-- ====================================================================

PROCEDURE imp (
  errbuf	    out nocopy varchar2,
  retcode	    out nocopy number,
  argument1	    in	varchar2,                 -- book_type_code
  argument2         in  varchar2   default  null,  --category_struct_id
  argument3         in  varchar2  default  null,  --category_id
  argument4         in  varchar2  default  null,
  argument5         in  varchar2  default  null,
  argument6         in  varchar2  default  null,
  argument7         in  varchar2  default  null,
  argument8         in  varchar2  default  null,
  argument9         in  varchar2  default  null,
  argument10        in  varchar2  default  null,
  argument11	    in  varchar2  default  null,
  argument12        in  varchar2  default  null,
  argument13        in  varchar2  default  null,
  argument14        in  varchar2  default  null,
  argument15        in  varchar2  default  null,
  argument16        in  varchar2  default  null,
  argument17        in  varchar2  default  null,
  argument18        in  varchar2  default  null,
  argument19        in  varchar2  default  null,
  argument20        in  varchar2  default  null,
  argument21	    in  varchar2  default  null,
  argument22        in  varchar2  default  null,
  argument23        in  varchar2  default  null,
  argument24        in  varchar2  default  null,
  argument25        in  varchar2  default  null,
  argument26        in  varchar2  default  null,
  argument27        in  varchar2  default  null,
  argument28        in  varchar2  default  null,
  argument29        in  varchar2  default  null,
  argument30        in  varchar2  default  null,
  argument31	    in  varchar2  default  null,
  argument32        in  varchar2  default  null,
  argument33        in  varchar2  default  null,
  argument34        in  varchar2  default  null,
  argument35        in  varchar2  default  null,
  argument36        in  varchar2  default  null,
  argument37        in  varchar2  default  null,
  argument38        in  varchar2  default  null,
  argument39        in  varchar2  default  null,
  argument40        in  varchar2  default  null,
  argument41	    in  varchar2  default  null,
  argument42        in  varchar2  default  null,
  argument43        in  varchar2  default  null,
  argument44        in  varchar2  default  null,
  argument45        in  varchar2  default  null,
  argument46        in  varchar2  default  null,
  argument47        in  varchar2  default  null,
  argument48        in  varchar2  default  null,
  argument49        in  varchar2  default  null,
  argument50        in  varchar2  default  null,
  argument51	    in  varchar2  default  null,
  argument52        in  varchar2  default  null,
  argument53        in  varchar2  default  null,
  argument54        in  varchar2  default  null,
  argument55        in  varchar2  default  null,
  argument56        in  varchar2  default  null,
  argument57        in  varchar2  default  null,
  argument58        in  varchar2  default  null,
  argument59        in  varchar2  default  null,
  argument60        in  varchar2  default  null,
  argument61	    in  varchar2  default  null,
  argument62        in  varchar2  default  null,
  argument63        in  varchar2  default  null,
  argument64        in  varchar2  default  null,
  argument65        in  varchar2  default  null,
  argument66        in  varchar2  default  null,
  argument67        in  varchar2  default  null,
  argument68        in  varchar2  default  null,
  argument69        in  varchar2  default  null,
  argument70        in  varchar2  default  null,
  argument71	    in  varchar2  default  null,
  argument72        in  varchar2  default  null,
  argument73        in  varchar2  default  null,
  argument74        in  varchar2  default  null,
  argument75        in  varchar2  default  null,
  argument76        in  varchar2  default  null,
  argument77        in  varchar2  default  null,
  argument78        in  varchar2  default  null,
  argument79        in  varchar2  default  null,
  argument80        in  varchar2  default  null,
  argument81	    in  varchar2  default  null,
  argument82        in  varchar2  default  null,
  argument83        in  varchar2  default  null,
  argument84        in  varchar2  default  null,
  argument85        in  varchar2  default  null,
  argument86        in  varchar2  default  null,
  argument87        in  varchar2  default  null,
  argument88        in  varchar2  default  null,
  argument89        in  varchar2  default  null,
  argument90        in  varchar2  default  null,
  argument91	    in  varchar2  default  null,
  argument92        in  varchar2  default  null,
  argument93        in  varchar2  default  null,
  argument94        in  varchar2  default  null,
  argument95        in  varchar2  default  null,
  argument96        in  varchar2  default  null,
  argument97        in  varchar2  default  null,
  argument98        in  varchar2  default  null,
  argument99        in  varchar2  default  null,
  argument100       in       varchar2 default null) is



  h_request_id          NUMBER := fnd_global.conc_request_id;
  l_dist_source_book    VARCHAR2(15);
  l_path_name VARCHAR2(150) := g_path||'imp';

  BEGIN

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'book_type_code:   '||argument1);

   h_request_id := fnd_global.conc_request_id;

   	SELECT distribution_source_book INTO l_dist_source_book
	FROM fa_book_controls
	WHERE
	book_type_code=argument1;



  IF( NOT Trxns_In_Open_Period(l_dist_source_book,argument1))
      THEN
       fnd_message.set_name ('IGI','IGI_IMP_IAC_TRXNS_IN_OPEN_PERD');
       errbuf := fnd_message.get;
       retcode := 0 ;
       RETURN ;

  ELSE
      igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Before calling inner procedure, request id: '||h_request_id);

   	igirx_imp_iac_rep.imp(
      	 p_book_type_code     => argument1,
      	 p_category_struct_id => to_number(argument2),
       	 p_category_id        => to_number(argument3),
      	 p_request_id 	    => h_request_id,
       	 retcode 	    => retcode,
       	 errbuf 	    => errbuf);
  END IF;

   igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     p_full_path => l_path_name,
		     p_string => 'Reconciliation Implementation Outer wrapper completed successfully');
   retcode := 0;
   errbuf := 'Successful!';

  EXCEPTION
     WHEN OTHERS THEN
          retcode := 2;
  	  FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
  	  FND_MESSAGE.SET_TOKEN('PACKAGE','igirx_c_imp_iac_rep');
  	  FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Reconciliation Implementation outer wrapper did not complete successfully');
  	  igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  			    p_full_path => l_path_name,
		  			    p_remove_from_stack => FALSE);
	  errbuf := FND_MESSAGE.GET;
	  fnd_file.put_line(fnd_file.log, errbuf);
  END imp;

END igirx_c_imp_iac_rep;

/
