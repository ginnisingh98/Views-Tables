--------------------------------------------------------
--  DDL for Package Body IGI_IAC_REBASE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IAC_REBASE_PKG" AS
--  $Header: igiiacrb.pls 120.5.12000000.1 2007/08/01 16:13:39 npandya ship $

--===========================FND_LOG.START=====================================

g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiiacrb.igi_iac_rebase_pkg.';

--===========================FND_LOG.END=====================================

   PROCEDURE  do_rebase(
   	errbuf OUT NOCOPY  varchar2 ,
   	retcode OUT NOCOPY  number,
	price_index_id IN  number, --- bug : 2504403 varchar2 changed this to number as now the concurrent process is passing price_index_id ,
	calendar  IN varchar2,
	period_name IN varchar2,
	new_price_index_value IN number)  IS


   /* Cursors Definition */
   /* Cursor to obtain the price_index_id for the given price_index_name */

   Cursor c_get_price_index(p_price_index_name  igi_iac_price_indexes.price_index_name%type) is
   	Select price_index_id from igi_iac_price_indexes where
   	price_index_name = p_price_index_name;


   /* Cursor to obtain cal_price_index_link_id */

   Cursor  c_get_link_id (p_price_index_id  igi_iac_price_indexes.price_index_id%type)  is
   	Select cal_price_index_link_id from igi_iac_cal_price_indexes where
   	calendar_type = calendar and
   	price_index_id = p_price_index_id;


   /* Cursor to obtain the current_price_index_values for all the periods of the calendar */

   Cursor c_get_curr_price_ind_val(p_cal_price_link_id igi_iac_cal_price_indexes.cal_price_index_link_id%type) is
   	Select iciv.*,iciv.rowid from igi_iac_cal_idx_values  iciv where
   	cal_price_index_link_id = p_cal_price_link_id;

   /* Cursor to obtain current price index value for the rebasing  period */

   Cursor c_get_rebase_period(p_link_id igi_iac_cal_idx_values.cal_price_index_link_id%type,
   	                       p_calendar igi_iac_cal_price_indexes.calendar_type%type,
   	                       p_period fa_calendar_periods.period_name%type) is
	  Select  iciv.current_price_index_value from
	  igi_iac_cal_idx_values iciv ,fa_calendar_periods fcp
	 	where  fcp.start_date = iciv.date_from and
                       fcp.end_date = iciv.date_to and
		       fcp.calendar_type = p_calendar and
		       fcp.period_name = p_period and
		       iciv.cal_price_index_link_id = p_link_id;

   /*	Select iciv.current_price_index_value from igi_iac_cal_idx_values iciv , fa_calendar_periods fcp where
   	fcp.calendar_type = calendar and
   	fcp.period_name = period_name and
   	iciv.date_from = fcp.start_date and
   	iciv.date_to = fcp.end_date and
   	cal_price_index_link_id = p_link_id;*/

   /* Cursor for getting the  rows in IGI_IAC_CAL_PRICE_INDEXES for updation using TBH */

   Cursor c_get_cal_price_indexes(p_link_id igi_iac_cal_price_indexes.cal_price_index_link_id%type) is
   	Select icpi.rowid , icpi.* from igi_iac_cal_price_indexes icpi
   	where icpi.cal_price_index_link_id = p_link_id;


   /* Cursor to get the period  name - for display in the log file only */
   Cursor c_get_period_name(l_date_from igi_iac_cal_idx_values.date_from%type,
   			    l_date_to igi_iac_cal_idx_values.date_to%type) is
   	Select fap.period_name from fa_calendar_periods fap
   	where start_date =l_date_from and  end_date = l_date_to and
   	      calendar_type= calendar;

   /* Cursor to get the precision */
   Cursor cur_get_precision(p_sob_id  gl_sets_of_books.set_of_books_id%type) Is
   	select curr.precision
            from fnd_currencies curr, gl_sets_of_books sob
            where curr.currency_code = sob.currency_code
            and  sob.set_of_books_id =  p_sob_id;

   l_link_id                        igi_iac_cal_price_indexes.cal_price_index_link_id%type;
   l_price_index_id                 igi_iac_price_indexes.price_index_id%type;
   l_calendar			    igi_iac_cal_price_indexes.calendar_type%type;
   l_period                         fa_calendar_periods.period_name%type;
   l_default_index_val		    igi_iac_cal_idx_values.current_price_index_value%type default 9999.99;



   /* This stores the current price index value of the period which is passed as the parameter to this concurrent process */
   l_factor_price_index 	    igi_iac_cal_idx_values.current_price_index_value%type;

   /* This stores the current price index value for each period */
   l_current_price_idx_rec 	    c_get_curr_price_ind_val%rowtype;
   l_new_curr_price_idx_val         igi_iac_cal_idx_values.current_price_index_value%type;
   l_period_name_rec                c_get_period_name%rowtype;


   l_cal_price_indexes_rec          c_get_cal_price_indexes%rowtype;

   l_rowcount 			    number;
   l_sob_id			    gl_sets_of_books.set_of_books_id%type;
   l_precision			    number;

   IGI_IAC_INDEX_PERIOD_NOT_FOUND   Exception;
   IGI_IAC_PRICE_INDEX_ZERO	    Exception;
   IGI_IAC_NOT_ENABLED		    Exception;

   Begin
   	/* Check whether the IAC Option is enabled */
   	if NOT igi_gen.is_req_installed('IAC') then
   		raise IGI_IAC_NOT_ENABLED;
     	END IF;

   	/* Check whether  the new price_index_value is zero - raise exception if so */
   	IF (new_price_index_value =0) THEN
   		raise IGI_IAC_PRICE_INDEX_ZERO;
     	END IF;


     	l_calendar:=calendar;
     	l_period:=period_name;

   	/* Get the price_index_id */
   	/*open c_get_price_index(price_index_name);
   	fetch c_get_price_index into l_price_index_id;
   	close c_get_price_index;*/

   	l_price_index_id:=price_index_id;
   	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase' ,' Price index id' ||l_price_index_id);
   	/* Get the cal_price_index_link_id */
   	open c_get_link_id(price_index_id);
   	fetch c_get_link_id into l_link_id;
   	close c_get_link_id;

   	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase',' link id' ||l_link_id);
   	/* Check whether periods of the given calendar are linked to the price index  in the igi_iac_cal_idx_values tables */
   	open c_get_curr_price_ind_val(l_link_id);
   	fetch c_get_curr_price_ind_val into l_current_price_idx_rec;
   	IF (c_get_curr_price_ind_val%NOTFOUND) THEN
   	   	raise IGI_IAC_INDEX_PERIOD_NOT_FOUND;
  	END IF;
   	close c_get_curr_price_ind_val;

   	/* To obtain the current_price_index value of the rebase period */
	open  c_get_rebase_period(l_link_id,l_calendar,l_period);
   	fetch c_get_rebase_period into l_factor_price_index;
   	close c_get_rebase_period;



   	/* Log Messages */
	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','------------------------------------------------');
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','Calendar               : ' || calendar);
--        fnd_file.put_line(fnd_file.log,'Price Index            : ' || price_index_name);
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','Rebase Period          : ' || period_name);
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase' ,'New Price Index value  : ' || new_price_index_value);
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','------------------------------------------------');



        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase' ,'|Period                        |Old    |Current|');
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','|                              |Index  |Index  |');
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','|                              |Value  |Value  |');
        igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','------------------------------------------------');
        /* End of Log Messages */


        /* To get the precision of the functional currency */
        fnd_profile.get('GL_SET_OF_BKS_ID', l_sob_id);
        open cur_get_precision(l_sob_id);
        fetch cur_get_precision into l_precision;
        close cur_get_precision;

   	/* Update the price indexes of all periods of the calendar using the factor */
   	for l_current_price_idx_rec in  c_get_curr_price_ind_val(l_link_id) loop
   		/* Get the period name */
		open c_get_period_name(l_current_price_idx_rec.date_from,l_current_price_idx_rec.date_to);
		fetch c_get_period_name	 into l_period_name_rec;
		close c_get_period_name;
    		IF  ( (l_period_name_rec.period_name <> period_name) and
    		      (l_current_price_idx_rec.current_price_index_value <> l_default_index_val) )  THEN   /* Bug No :2392641 sowsubra */

	   		 l_new_curr_price_idx_val:=
	   		 	new_price_index_value * (l_current_price_idx_rec.current_price_index_value/l_factor_price_index);
	   	/* Display the price index value details in the  log file */
   		igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','|'||rpad(l_period_name_rec.period_name,30,' ')||'|'||rpad(l_current_price_idx_rec.current_price_index_value,7,' ')
		   				||'|'||rpad(l_new_curr_price_idx_val,7,' ')||'|');

	        ELSIF (l_period_name_rec.period_name = period_name) THEN
	        	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','------------------------------------------------');
	        	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase', period_name ||' is  the rebasing period. So no calculation is done .');
	        	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','New price index value = ' || new_price_index_value);
	        	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','------------------------------------------------');
	        	l_new_curr_price_idx_val:= new_price_index_value;

	      /* Bug No :2392641 sowsubra start */
	        ELSIF (l_current_price_idx_rec.current_price_index_value = l_default_index_val)   THEN
	        	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase', l_period_name_rec.period_name ||'has the default price index value  : ' ||
	        			l_default_index_val || '.So No rebase done for this period .');
	        	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','New price index value = ' ||l_default_index_val);
	        	l_new_curr_price_idx_val:=l_default_index_val ;
       	      /* Bug No :2392641 sowsubra  end */
	        END IF;

	        l_new_curr_price_idx_val := round(l_new_curr_price_idx_val,l_precision);



   		/* call to update the igi_iac_cal_idx_values using the TBH */

   		 igi_iac_cal_idx_values_pkg.update_row (
		      x_mode                              => 'R',
		      x_rowid                             => l_current_price_idx_rec.rowid,
		      x_cal_price_index_link_id           => l_current_price_idx_rec.cal_price_index_link_id,
		      x_date_from                         => l_current_price_idx_rec.date_from,
		      x_date_to                           => l_current_price_idx_rec.date_to,
		      x_original_price_index_value        => l_current_price_idx_rec.original_price_index_value,
		      x_current_price_index_value         => l_new_curr_price_idx_val
		    );



	END LOOP;
	igi_iac_debug_pkg.debug_other_string(g_state_level,g_path||'do_rebase','------------------------------------------------');
	open c_get_cal_price_indexes(l_link_id);
	fetch c_get_cal_price_indexes into l_cal_price_indexes_rec;
	close c_get_cal_price_indexes;

	/*Update the igi_iac_cal_price_indexes table to record the rebase period name and price_index details */
	igi_iac_cal_price_indexes_pkg.update_row (
   		   x_mode                              => 'R',
		   x_rowid                             => l_cal_price_indexes_rec.rowid,
		   x_cal_price_index_link_id           => l_cal_price_indexes_rec.cal_price_index_link_id,
	           x_price_index_id                    => l_cal_price_indexes_rec.price_index_id,
		   x_calendar_type                     => l_cal_price_indexes_rec.calendar_type,
     		   x_previous_rebase_period_name       => period_name,
		   x_previous_rebase_date              => trunc(sysdate),
		   x_previous_rebase_index_before      => l_factor_price_index,
		   x_previous_rebase_index_after       => new_price_index_value
	    );


   EXCEPTION
   WHEN IGI_IAC_NOT_ENABLED THEN
       fnd_message.set_name('IGI','IGI_IAC_NOT_INSTALLED');
	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'do_rebase',FALSE);
       Errbuf:=fnd_message.get;
       retcode :=2;
   WHEN IGI_IAC_PRICE_INDEX_ZERO THEN
       FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_rebase_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Error : Price index value 0 cannot be processed ');
	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'do_rebase',FALSE);

       retcode :=2;
       Errbuf := fnd_message.get;
   WHEN ZERO_DIVIDE THEN
   	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_rebase_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Division By Zero ');
	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'do_rebase',FALSE);
       retcode :=2;
       errbuf:= fnd_message.get;
   WHEN IGI_IAC_INDEX_PERIOD_NOT_FOUND THEN
  	FND_MESSAGE.SET_NAME('IGI', 'IGI_IAC_EXCEPTION');
	      FND_MESSAGE.SET_TOKEN('PACKAGE','igi_iac_rebase_pkg');
	      FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE','Price Index not linked to the calendar periods ');
	igi_iac_debug_pkg.debug_other_msg(g_error_level,g_path||'do_rebase',FALSE);
        retcode:=2;
        errbuf:= fnd_message.get;
  END do_rebase;
END igi_iac_rebase_pkg;

/
