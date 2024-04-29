--------------------------------------------------------
--  DDL for Package Body AP_WEB_CC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AP_WEB_CC_UPGRADE_PKG" AS
/* $Header: apwccupb.pls 120.0.12010000.4 2009/12/15 12:59:11 meesubra noship $ */


/*
Procedure : Upgrade_Cards
Purpose   : Successful upgrade for a card signifies encryption of a card number,
	    Cardmember Name, and Expiration Date using Oracle Payments api
	    and updating with correct reference of card_reference_id in ap_cards_all.
*/
PROCEDURE Upgrade_Cards
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_worker_id   IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  )
IS
	l_start_rowid     rowid;
	l_end_rowid       rowid;
	x_return_status VARCHAR2(4000);
	x_msg_count NUMBER;
	x_msg_data VARCHAR2(4000);
	p_card_instrument APPS.IBY_FNDCPT_SETUP_PUB.CREDITCARD_REC_TYPE;
	x_instr_id NUMBER;
	x_response APPS.IBY_FNDCPT_COMMON_PUB.RESULT_REC_TYPE;
	l_sqlerr VARCHAR2(255);
	l_user_id  number;

	TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
	TYPE CharList1 IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
	TYPE CharList30 IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;
	TYPE CharList80 IS TABLE OF VARCHAR2(80) INDEX BY BINARY_INTEGER;
	TYPE DateList IS TABLE OF DATE INDEX BY BINARY_INTEGER;

	h_card_id NumberList;
	h_card_number CharList80;
	h_party_id NumberList;
	h_card_program_id NumberList;
	h_card_reference_id NumberList;
	h_cardmember_name CharList80;
	h_card_expiration_date DateList;

	v_instr_id NumberList;
	v_return_status CharList1;

	l_rows_processed  number;
	l_table_owner     varchar2(30) :=  'AP';
	l_batch_size      varchar2(30) :=  x_batch_size;
	l_worker_id       number  := x_worker_id;
	l_num_workers     number  := x_num_workers;
	l_any_rows_to_process boolean;
	l_table_name      varchar2(30) := 'AP_CARDS_ALL';
	l_update_name     varchar2(30) :=  x_script_name || 'UpgCard';

	cursor get_cards (p_start_rowid ROWID, p_end_rowid ROWID)
                        is select  /*+ ROWID (aca) */ card_id, card_number,
				(case when (p.employee_number is not null
					   or p.npw_number is not null) then party_id end) as person_party_id,
                                 card_program_id,
				 card_reference_id,
				 card_expiration_date,
				 cardmember_name
                          from ap_cards_all aca,
                               per_all_people_f p
                          where trunc(sysdate) between p.effective_start_date(+) and p.effective_end_date(+)
                          and aca.employee_id = p.person_id(+)
			  and (card_number is not null
			       or cardmember_name is not null
                               or card_expiration_date is not null)
                          and aca.rowid between p_start_rowid and p_end_rowid;


	BEGIN
		l_rows_processed := 0;

		p_card_instrument.Instrument_Type := 'CREDITCARD';
		p_card_instrument.Info_Only_Flag := 'Y';
		p_card_instrument.Register_Invalid_Card := 'Y';
		l_user_id := nvl(fnd_global.user_id, -1);

		fnd_file.put_line(fnd_file.log,'Begin Upgrade_Cards');

		ad_parallel_updates_pkg.initialize_rowid_range(
		   ad_parallel_updates_pkg.ROWID_RANGE,
		   l_table_owner,
		   l_table_name,
		   l_update_name,
		   l_worker_id,
		   l_num_workers,
		   l_batch_size, 0);

		ad_parallel_updates_pkg.get_rowid_range(
		   l_start_rowid,
		   l_end_rowid,
		   l_any_rows_to_process,
		   l_batch_size,
		   true);

		while (l_any_rows_to_process = true) loop

		open get_cards(l_start_rowid, l_end_rowid);
		fetch get_cards bulk collect into h_card_id, h_card_number, h_party_id, h_card_program_id, h_card_reference_id,
						h_card_expiration_date,h_cardmember_name;
		l_rows_processed := get_cards%ROWCOUNT;

		for i in 1..h_card_id.count loop

		  p_card_instrument.card_number := h_card_number(i);
		  p_card_instrument.Expiration_Date  := h_card_expiration_date(i);
		  p_card_instrument.Card_Holder_Name := h_cardmember_name(i);

		  if (h_card_number(i) IS NOT NULL) then
			iby_fndcpt_setup_pub.card_exists(1.0,NULL,x_return_status, x_msg_count, x_msg_data, null, h_card_number(i),
						   p_card_instrument, x_response);
			-- Added the assignment statements as card_exists api clears out the data
			p_card_instrument.Instrument_Type := 'CREDITCARD';
			p_card_instrument.Info_Only_Flag := 'Y';
			p_card_instrument.Register_Invalid_Card := 'Y';
			p_card_instrument.Expiration_Date  := h_card_expiration_date(i);
			p_card_instrument.Card_Holder_Name := h_cardmember_name(i);
		  else
			x_return_status := '';
			p_card_instrument.card_id := h_card_reference_id(i);
		  end if;

		  if ( x_return_status = 'S' OR h_card_reference_id(i) IS NOT NULL) then
			 v_instr_id(i) :=  p_card_instrument.card_id;
			 iby_fndcpt_setup_pub.update_card(1.0,NULL,'F',x_return_status,x_msg_count,x_msg_data, p_card_instrument,x_response);
			 v_return_status(i) := x_return_status;
		  else
			 p_card_instrument.card_number := h_card_number(i);
			 iby_fndcpt_setup_pub.create_card(1.0,NULL,'F',x_return_status,x_msg_count,x_msg_data, p_card_instrument,x_instr_id,x_response);
			 v_return_status(i) := x_return_status;
			 v_instr_id(i) :=  x_instr_id;
		  end if;

		end loop;

		-- updating cards table
		forall k in 1..h_card_id.count
		update ap_cards_all
			set card_reference_id = v_instr_id(k)
			  , card_number = null
			  , cardmember_name = null
			  , card_expiration_date = null
			  , last_update_date = sysdate
			  , last_updated_by = l_user_id
		where card_id = h_card_id(k)
		and v_return_status(k) = 'S';

		close get_cards;

		ad_parallel_updates_pkg.processed_rowid_range(
		  l_rows_processed,
		  l_end_rowid);

		-- get new range of rowids
		ad_parallel_updates_pkg.get_rowid_range(
		 l_start_rowid,
		 l_end_rowid,
		 l_any_rows_to_process,
		 l_batch_size,
		 FALSE);
		end loop;

	  COMMIT;
  	  x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
	  fnd_file.put_line(fnd_file.log,'End Upgrade_Cards');

	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
		fnd_file.put_line(fnd_file.log,'Error in Upgrade_Cards');
		fnd_file.put_line(fnd_file.log,'ERROR CODE:='||sqlcode);
		fnd_file.put_line(fnd_file.log,'ERROR MESSAGE:='||SUBSTR(sqlerrm,1,150));
		x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
		x_errbuf  := SQLERRM;

  END Upgrade_Cards;

/*
Procedure : Upgrade_Trxns
Purpose   : For the cards which were successfully migrated during R12 and PADSS, update
	          ap_credit_card_trxns_all for those card numbers.
*/
PROCEDURE Upgrade_Trxns
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_worker_id   IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  )
IS
	l_start_rowid     rowid;
	l_end_rowid       rowid;
	l_sqlerr VARCHAR2(255);
	l_user_id  number;

	TYPE NumberList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

	h_trx_id NumberList;
	l_rows_processed  number;
	l_table_owner     varchar2(30) := 'AP';
	l_batch_size      varchar2(30) := x_batch_size;
	l_worker_id       number  := x_worker_id;
	l_num_workers     number  := x_num_workers;
	l_any_rows_to_process boolean;
	l_table_name      varchar2(30) := 'AP_CREDIT_CARD_TRXNS_ALL';
	l_update_name     varchar2(30) := x_script_name || 'UpgTrxn';

	begin
	l_rows_processed := 0;

	l_user_id := nvl(fnd_global.user_id, -1);
	fnd_file.put_line(fnd_file.log,'Begin Upgrade_Trxns');

	ad_parallel_updates_pkg.initialize_rowid_range(
	   ad_parallel_updates_pkg.ROWID_RANGE,
	   l_table_owner,
	   l_table_name,
	   l_update_name,
	   l_worker_id,
	   l_num_workers,
	   l_batch_size, 0);

	ad_parallel_updates_pkg.get_rowid_range(
	   l_start_rowid,
	   l_end_rowid,
	   l_any_rows_to_process,
	   l_batch_size,
	   true);

	while (l_any_rows_to_process = true) loop

	update  /*+ ROWID (aca) */ ap_credit_card_trxns_all aca
	set
	       card_number = null
	     , last_update_date = sysdate
	     , last_updated_by = l_user_id
	where
	card_number is not null
	and card_id is not null
	and card_id > 0
	and aca.rowid between l_start_rowid and l_end_rowid;

	ad_parallel_updates_pkg.processed_rowid_range(
	  l_rows_processed,
	  l_end_rowid);

	-- get new range of rowids
	ad_parallel_updates_pkg.get_rowid_range(
	 l_start_rowid,
	 l_end_rowid,
	 l_any_rows_to_process,
	 l_batch_size,
	 FALSE);

	end loop;

	COMMIT;
	x_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;
	fnd_file.put_line(fnd_file.log,'End Upgrade_Trxns');

	EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
		fnd_file.put_line(fnd_file.log,'Error in Upgrade_Trxns');
		fnd_file.put_line(fnd_file.log,'ERROR CODE:='||sqlcode);
		fnd_file.put_line(fnd_file.log,'ERROR MESSAGE:='||SUBSTR(sqlerrm,1,150));
		x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
		x_errbuf  := SQLERRM;

END Upgrade_Trxns;

/*
Procedure : Upgrade_Trxns_Manager
Purpose   : To initiate the Upgrade_Trxns in a parallel mode
*/
PROCEDURE Upgrade_Trxns_Manager
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  )
IS
BEGIN
	  fnd_file.put_line(fnd_file.log,'Begin Upgrade_Trxns_Manager');
	  AD_CONC_UTILS_PKG.submit_subrequests
	    (X_errbuf => x_errbuf,
	     X_retcode => x_retcode,
	     X_WorkerConc_app_shortname => 'SQLAP',
	     X_WorkerConc_progname => 'APXCCTRXUPG',
	     X_batch_size => x_batch_size,
	     X_Num_Workers => x_num_workers,
	     X_Argument4 => x_script_name
	    );
	  fnd_file.put_line(fnd_file.log,'End Upgrade_Trxns_Manager');
EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
		fnd_file.put_line(fnd_file.log,'Error in Upgrade_Trxns_Manager');
		fnd_file.put_line(fnd_file.log,'ERROR CODE:='||sqlcode);
		fnd_file.put_line(fnd_file.log,'ERROR MESSAGE:='||SUBSTR(sqlerrm,1,150));
		x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
		x_errbuf  := SQLERRM;

END Upgrade_Trxns_Manager;

/*
Procedure : Upgrade_Cards_Manager
Purpose   : To initiate the Upgrade_Cards in a parallel mode
*/

PROCEDURE Upgrade_Cards_Manager
  (x_errbuf      OUT NOCOPY VARCHAR2,
   x_retcode     OUT NOCOPY VARCHAR2,
   x_batch_size  IN NUMBER,
   x_num_workers IN NUMBER,
   x_script_name IN VARCHAR2
  )
  IS
BEGIN
	  fnd_file.put_line(fnd_file.log,'Begin Upgrade_Cards_Manager');
	  AD_CONC_UTILS_PKG.submit_subrequests
	    (X_errbuf => x_errbuf,
	     X_retcode => x_retcode,
	     X_WorkerConc_app_shortname => 'SQLAP',
	     X_WorkerConc_progname => 'APXCCUPG',
	     X_batch_size => x_batch_size,
	     X_Num_Workers => x_num_workers,
	     X_Argument4 => x_script_name
	    );
	  fnd_file.put_line(fnd_file.log,'End Upgrade_Cards_Manager');
EXCEPTION
	  WHEN OTHERS THEN
		ROLLBACK;
		fnd_file.put_line(fnd_file.log,'Error in Upgrade_Cards_Manager');
		fnd_file.put_line(fnd_file.log,'ERROR CODE:='||sqlcode);
		fnd_file.put_line(fnd_file.log,'ERROR MESSAGE:='||SUBSTR(sqlerrm,1,150));
		x_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
		x_errbuf  := SQLERRM;
END Upgrade_Cards_Manager;

END AP_WEB_CC_UPGRADE_PKG;

/
