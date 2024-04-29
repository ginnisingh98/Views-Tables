--------------------------------------------------------
--  DDL for Package Body IGIRRGPP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGIRRGPP" AS
-- $Header: igirrgpb.pls 120.6.12000000.1 2007/08/31 05:53:13 mbremkum ship $

  l_debug_level number:=FND_LOG.G_CURRENT_RUNTIME_LEVEL;

  l_state_level number:=FND_LOG.LEVEL_STATEMENT;
  l_proc_level number:=FND_LOG.LEVEL_PROCEDURE;
  l_event_level number:=FND_LOG.LEVEL_EVENT;
  l_excep_level number:=FND_LOG.LEVEL_EXCEPTION;
  l_error_level number:=FND_LOG.LEVEL_ERROR;
  l_unexp_level number:=FND_LOG.LEVEL_UNEXPECTED;

--Commenting out WriteToLogFile as fnd_logging to be used bug 3199481 (Start)
/*
PROCEDURE WriteToLogFile(pp_mesg in varchar2) IS
 IsDebugMode BOOLEAN := TRUE;
BEGIN
	IF IsDebugMode THEN
		fnd_file.put_line(FND_FILE.LOG,pp_mesg);
	ELSE
		null;
	END IF;
END WriteToLogFile;
*/
--Commenting out WriteToLogFile as fnd_logging to be used bug 3199481 (End)

PROCEDURE CreateLines ( pp_run_id                 in number
                      , pp_item_code_from         in varchar2
                      , pp_item_code_to           in varchar2
                      , pp_amount                 in number
                      , pp_percentage_amount      in number
                      , pp_incr_decr_flag         in varchar2
                      , pp_update_effective_date  in date
                      , pp_creation_date          in date
                      , pp_created_by             in number
                      , pp_last_update_date       in date
                      , pp_last_updated_by        in number
                      , pp_last_update_login      in number
                      , pp_option_flag            in varchar2
                      )
                     IS

      CURSOR c_rpi_charge_lines_d Is
      SELECT pp_run_id 			run_id,
             standing_charge_id,
             line_item_id,
             item_id,
             price,
	     org_id,			/*MOAC Impact*/
             current_effective_date 	effective_date,
             pp_amount            	change_amount,
             pp_percentage_amount 	change_percent,
             pp_incr_decr_flag    	incr_decr_flag,
             pp_update_effective_date 	update_effective_date,
             revised_price,
             revised_effective_date,
             null 			updated_price,
             null 			select_flag,
             pp_creation_date       	creation_date,
             pp_created_by          	created_by,
             pp_last_update_date    	last_update_date,
             pp_last_updated_by     	last_updated_by,
             pp_last_update_login   	last_update_login
      FROM   igi_rpi_line_details lines
      WHERE  exists ( select item_id
                          from   igi_rpi_items items
                          where  item_code >= pp_item_code_from
                          AND    item_code <= pp_item_code_to
                          AND    items.item_id = lines.item_id
                        )
      AND    exists
             ( select 'x'
               from   igi_rpi_standing_charges charges
               where  lines.standing_charge_id = charges.standing_charge_id
               and    set_of_books_id = ( select set_of_books_id from ar_system_parameters )
             )
      AND    exists
             ( select  'x'
               from    igi_rpi_items items
               where   decode(sign(trunc(nvl(lines.revised_effective_date, (pp_update_effective_date + 1)))
                       - trunc(pp_update_effective_date)),1, lines.price, lines.revised_price)
                       = decode(sign(trunc(nvl(items.revised_price_eff_date, (pp_update_effective_date + 1)))
                         - trunc(pp_update_effective_date)),1, items.price, items.revised_price)
             );

      CURSOR c_rpi_charge_lines_a Is
      SELECT pp_run_id                  run_id,
             standing_charge_id,
             line_item_id,
             item_id,
             price,
    	     org_id,			/*MOAC Impact*/
             current_effective_date 	effective_date,
             pp_amount            	change_amount,
             pp_percentage_amount 	change_percent,
	     pp_incr_decr_flag  	incr_decr_flag,
	     pp_update_effective_date 	update_effective_date,
             revised_price,
             revised_effective_date,
             null 			updated_price,
             null 			select_flag,
             pp_creation_date       	creation_date,
             pp_created_by          	created_by,
             pp_last_update_date    	last_update_date,
             pp_last_updated_by     	last_updated_by,
             pp_last_update_login   	last_update_login
      FROM   igi_rpi_line_details lines
      WHERE  exists ( select item_id
                          from   igi_rpi_items items
                          where  item_code >= pp_item_code_from
                          AND    item_code <= pp_item_code_to
                          AND    items.item_id = lines.item_id
                        )
      AND    exists
             ( select 'x'
               from   igi_rpi_standing_charges charges
               where  lines.standing_charge_id = charges.standing_charge_id
               and    set_of_books_id = ( select set_of_books_id from ar_system_parameters )
             )
      ;

   CURSOR c_rpi_items Is
      SELECT pp_run_id 			run_id,
             item_code,
             item_id,
             price,
             org_id,			/*Added for MOAC Impact*/
             price_effective_date 	effective_date,
             pp_amount  		change_amount,
             pp_percentage_amount 	change_percent,
             pp_incr_decr_flag    	incr_decr_flag,
             pp_update_effective_date   update_effective_date,
             revised_price,
             revised_price_eff_date 	revised_effective_date,
             null 			updated_price,
             null 			select_flag,
             pp_creation_date       	creation_date,
             pp_created_by          	created_by,
             pp_last_update_date    	last_update_date,
             pp_last_updated_by     	last_updated_by,
             pp_last_update_login   	last_update_login
      FROM   igi_rpi_items
      where  item_code >= pp_item_code_from
      AND    item_code <= pp_item_code_to
      AND    set_of_books_id =
            ( select set_of_books_id from ar_system_parameters )
      ;

      lv_updated_price   igi_rpi_update_lines.updated_price%TYPE;
      lv_select_flag     igi_rpi_update_lines.select_flag%TYPE;
      lv_mesg    VARCHAR2(200);
BEGIN

/*
-- Update the item templates now
*/

 IF igi_gen.is_req_installed('RPI') THEN
    NULL;
 ELSE
    fnd_message.set_name('IGI','IGI_RPI_IS_DISABLED');
    lv_mesg := fnd_message.get;
    --Bug 3199481 (start)
    If (l_unexp_level >= l_debug_level) then
       FND_LOG.MESSAGE(l_unexp_level,'igi.plsql.igirrgpp.createlines.Msg1',FALSE);
    End if;
    --Bug 3199481 (end)
    raise_application_error ( -20000, lv_mesg);
    return;
  END IF;

  FOR l_items in c_rpi_items LOOP

      lv_updated_price := null;
      lv_select_flag   := 'Y';

	IF (l_items.change_amount is not NULL) THEN
		IF (l_items.revised_effective_date is not NULL AND l_items.revised_effective_date < l_items.update_effective_date) THEN
			IF l_items.incr_decr_flag = 'Y' THEN
				lv_updated_price := l_items.revised_price + l_items.change_amount;
			ELSE
				lv_updated_price := l_items.revised_price - l_items.change_amount;
			END IF;
		ELSIF (l_items.revised_effective_date is NULL AND l_items.effective_date < l_items.update_effective_date) THEN
			IF(l_items.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_items.price + l_items.change_amount;
			ELSE
				lv_updated_price := l_items.price - l_items.change_amount;
			END IF;
		END IF;
	ELSIF (l_items.change_percent is not NULL) THEN
		IF (l_items.revised_effective_date is not NULL AND l_items.revised_effective_date < l_items.update_effective_date) THEN
			IF(l_items.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_items.revised_price *(100+ l_items.change_percent)/100;
			ELSE
				lv_updated_price := l_items.revised_price *( 100 - l_items.change_percent)/100;
			END IF;
		ELSIF (l_items.revised_effective_date is NULL AND l_items.effective_date < l_items.update_effective_date) THEN
			IF(l_items.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_items.price *(100+ l_items.change_percent)/100;
			ELSE
				lv_updated_price := l_items.price *( 100 - l_items.change_percent)/100;
			END IF;
		END IF;
	END IF;

	IF ((lv_updated_price is not NULL) AND (lv_updated_price >= 0)) THEN
	/* Added ORG_ID in the insert statement*/
	       insert into igi_rpi_update_lines
	        (  run_id, item_id, price, effective_date,
	           revised_price,   revised_effective_date,
	           updated_price, select_flag,
	           creation_date, created_by, last_update_date,
	           last_updated_by, last_update_login, org_id
	        )
	        values ( l_items.run_id, l_items.item_id, l_items.price, l_items.effective_date,
	           l_items.revised_price, l_items.revised_effective_date,
	           lv_updated_price, lv_select_flag,
	           l_items.creation_date, l_items.created_by, l_items.last_update_date,
	           l_items.last_updated_by, l_items.last_update_login, l_items.org_id );
	END IF;

  END LOOP;

/*
-- If option flag is 'All', update the ALL the existing standing charge line information
-- also.
*/

  if pp_option_flag = 'A' then

     FOR  l_details in c_rpi_charge_lines_a LOOP

      lv_updated_price := null;
      lv_select_flag   := 'Y';

	IF (l_details.change_amount is not NULL) THEN
		IF (l_details.revised_effective_date is not NULL AND l_details.revised_effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.revised_price + l_details.change_amount;
			ELSE
				lv_updated_price := l_details.revised_price - l_details.change_amount;
			END IF;
		ELSIF (l_details.revised_effective_date is NULL AND l_details.effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.price + l_details.change_amount;
			ELSE
				lv_updated_price := l_details.price - l_details.change_amount;
			END IF;
		END IF;
	ELSIF (l_details.change_percent is not NULL) THEN
		IF (l_details.revised_effective_date is not NULL AND l_details.revised_effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.revised_price * (100 + l_details.change_percent)/100;
			ELSE
				lv_updated_price := l_details.revised_price * (100 - l_details.change_percent)/100;
			END IF;
		ELSIF (l_details.revised_effective_date is NULL AND l_details.effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.price * (100 + l_details.change_percent)/100;
			ELSE
				lv_updated_price := l_details.price * (100 - l_details.change_percent)/100;
			END IF;
		END IF;
	END IF;

	IF ((lv_updated_price is not NULL) AND (lv_updated_price >= 0)) THEN

	/*R12 uptake Added ORG_ID for MOAC Impact Bug No 5905216*/

	      insert into igi_rpi_update_lines
	        (run_id, standing_charge_id, line_item_id, item_id, price, effective_date,
	        revised_price, revised_effective_date,
	        updated_price, select_flag,
	        creation_date, created_by, last_update_date, last_updated_by,
	        last_update_login, org_id)
	      values ( l_details.run_id, l_details.standing_charge_id, l_details.line_item_id,
	               l_details.item_id, l_details.price, l_details.effective_date,
	               l_details.revised_price, l_details.revised_effective_date,
	               lv_updated_price, lv_select_flag,
	               l_details.creation_date, l_details.created_by,
	               l_details.last_update_date, l_details.last_updated_by,
	               l_details.last_update_login, l_details.org_id );
	END IF;

     END LOOP;

   elsif pp_option_flag = 'D' then

 /*
 -- this update updates the standing charges whose defaulted price is not yet modified
 */

     FOR  l_details in c_rpi_charge_lines_d LOOP

      lv_updated_price := null;
      lv_select_flag   := 'Y';

	IF (l_details.change_amount is not NULL) THEN
		IF (l_details.revised_effective_date is not NULL AND l_details.revised_effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.revised_price + l_details.change_amount;
			ELSE
				lv_updated_price := l_details.revised_price - l_details.change_amount;
			END IF;
		ELSIF (l_details.revised_effective_date is NULL AND l_details.effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.price + l_details.change_amount;
			ELSE
				lv_updated_price := l_details.price - l_details.change_amount;
			END IF;
		END IF;
	ELSIF (l_details.change_percent is not NULL) THEN
		IF (l_details.revised_effective_date is not NULL AND l_details.revised_effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.revised_price * (100 + l_details.change_percent)/100;
			ELSE
				lv_updated_price := l_details.revised_price * (100 - l_details.change_percent)/100;
			END IF;
		ELSIF (l_details.revised_effective_date is NULL AND l_details.effective_date < l_details.update_effective_date) THEN
			IF(l_details.incr_decr_flag = 'Y') THEN
				lv_updated_price := l_details.price * (100 + l_details.change_percent)/100;
			ELSE
				lv_updated_price := l_details.price * (100 - l_details.change_percent)/100;
			END IF;
		END IF;
	END IF;

	IF ((lv_updated_price is not NULL) AND (lv_updated_price >= 0)) THEN

	/*R12 Uptake Added ORG_ID for MOAC Impact bug No 5905216*/

	      insert into igi_rpi_update_lines
	        (run_id, standing_charge_id, line_item_id, item_id, price, effective_date,
	        revised_price, revised_effective_date,
	        updated_price, select_flag,
	        creation_date, created_by, last_update_date, last_updated_by,
	        last_update_login, org_id)
	      values ( l_details.run_id, l_details.standing_charge_id, l_details.line_item_id,
	               l_details.item_id, l_details.price, l_details.effective_date,
	               l_details.revised_price, l_details.revised_effective_date,
	               lv_updated_price, lv_select_flag,
	               l_details.creation_date, l_details.created_by,
	               l_details.last_update_date, l_details.last_updated_by,
	               l_details.last_update_login, l_details.org_id );
	END IF;

     END LOOP;

  END IF;

EXCEPTION WHEN OTHERS THEN
          raise_application_error (-20000, SQLERRM );

END;

PROCEDURE UpdatePrice  (pp_run_id in number ) IS

    Cursor C_rul (cp_run_id in number) IS
        SELECT item_id,
        	standing_charge_id,
        	line_item_id,
                price,
                effective_date,
                revised_effective_date,
                revised_price,
                updated_price,
                previous_price,
                previous_effective_date,
                last_updated_by,
                last_update_login
        FROM   igi_rpi_update_lines_all  /*MOAC Impact Bug No 5905216*/
        WHERE  run_id = cp_run_id
         and   UPPER(select_flag) = UPPER('y') ;

   CURSOR c_ruh IS
        SELECT  rowid row_id,
        	run_id,
        	item_id_from,
        	item_id_to,
        	effective_date,
        	option_flag,
        	amount,
        	percentage_amount,
        	status,
		org_id
        FROM    igi_rpi_update_hdr_all  /*MOAC Impact Bug No 5905216*/
        WHERE   run_id = pp_run_id ;

    CURSOR c_charge_item_number(p_standing_charge_id igi_rpi_line_details.standing_charge_id%TYPE,
    				p_line_item_id igi_rpi_line_details.line_item_id%TYPE) IS
    	SELECT charge_item_number
    		FROM igi_rpi_line_details
    		WHERE line_item_id = p_line_item_id
    		AND standing_charge_id = p_standing_charge_id;

--   l_org_id 	VARCHAR2(15);	/*MOAC Impact Bug No 5905216*/
   l_org_id	NUMBER;
   l_rowid	VARCHAR2(25) := NULL;
   l_charge_item_number igi_rpi_line_details.charge_item_number%TYPE;

BEGIN

    --WriteToLogFile('Start of Processing of records for Update');
    -- bug 3199481, start block
    IF (l_state_level >= l_debug_level) THEN
        FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.updateprice.Msg1',
                                      'Start of Processing of records for Update');
    END IF;
    -- bug 3199481, end block

    FOR l_ruh IN c_ruh LOOP

	/*Bug No 5905216 MOAC Impact. Set policy Context*/
	mo_global.set_policy_context('S',l_ruh.org_id);
	l_org_id := l_ruh.org_id;
	--WriteToLogFile('Updating status of Update Header to ERROR');
        -- bug 3199481, start block
        IF (l_state_level >= l_debug_level) THEN
           FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg2',
                                         'Updating status of Update Header to ERROR');
        END IF;
        -- bug 3199481, end block
        update igi_rpi_update_hdr
        set    status = 'ERROR'
        where rowid = l_ruh.row_id ;

        FOR l_rul IN c_rul ( l_ruh.run_id ) LOOP

/*Bug No 5905216. Do not get ORG_ID from FND_PROFILE*/
--        	fnd_profile.get('ORG_ID',l_org_id);

		--WriteToLogFile('Item Id :'|| to_char(l_rul.item_id));
		--WriteToLogFile('Standing Charge Id :'|| to_char(l_rul.Standing_charge_id));
		--WriteToLogFile('Update Effective Date :'|| to_char(l_ruh.effective_date));
		--WriteToLogFile('Revised Price :'|| to_char(l_rul.revised_price));
		--WriteToLogFile('Revised Effective Date :'||to_char(l_rul.revised_effective_date));

                -- bug 3199481, start block
                IF (l_state_level >= l_debug_level) THEN
                    FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg3',
                                                  'Item Id :'|| to_char(l_rul.item_id));
                    FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg4',
                                                  'Standing Charge Id :'|| to_char(l_rul.Standing_charge_id));
                    FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg5',
                                                  'Update Effective Date :'|| to_char(l_ruh.effective_date));
                    FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg6',
                                                  'Revised Price :'|| to_char(l_rul.revised_price));
                    FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg7',
                                                  'Revised Effective Date :'||to_char(l_rul.revised_effective_date));
                END IF;
                -- bug 3199481, end block

		IF (l_rul.standing_charge_id is NULL) THEN
			IF (l_rul.revised_price is NULL) THEN
				--WriteToLogFile('Updating revised price of Charge Item');
                                 -- bug 3199481, start block
                                 IF (l_state_level >= l_debug_level) THEN
                                     FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg8',
                                                                   'Updating revised price of Charge Item');
                                 END IF;
                                 -- bug 3199481, end block
				update igi_rpi_items
				set revised_price 		= l_rul.updated_price,
				    revised_price_eff_date 	= l_ruh.effective_date,
				    last_update_date 		= sysdate,
				    last_updated_by 		= l_rul.last_updated_by,
				    last_update_login 		= l_rul.last_update_login
				where item_id 			= l_rul.item_id;

			ELSIF (l_ruh.effective_date > l_rul.revised_effective_date) THEN
				--WriteToLogFile('Inserting record into audit table');
                                 -- bug 3199481, start block
                                 IF (l_state_level >= l_debug_level) THEN
                                     FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg9',
                                                                   'Inserting record into audit table');
                                 END IF;
                                 -- bug 3199481, end block
				igi_rpi_audit_items_all_pkg.insert_row( X_rowid 	=> l_rowid,
									X_item_id 	=> l_rul.item_id,
									X_price		=> l_rul.price,
									X_effective_date => l_rul.effective_date,
									X_revised_effective_date => l_rul.revised_effective_date,
									X_revised_price => l_rul.revised_price,
									X_run_id	=> l_ruh.run_id,
									/*X_org_id	=> to_number(l_org_id));*/	/*Bug No 5905216*/
									X_org_id	=> l_org_id);

				--WriteToLogFile('Updating revised price of Charge Item');
                                 -- bug 3199481, start block
                                 IF (l_state_level >= l_debug_level) THEN
                                     FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg10',
                                                                   'Updating revised price of Charge Item');
                                 END IF;
                                 -- bug 3199481, end block
				update igi_rpi_items
				set price			= l_rul.revised_price,
				    price_effective_date	= l_rul.revised_effective_date,
				    revised_price 		= l_rul.updated_price,
				    revised_price_eff_date 	= l_ruh.effective_date,
				    last_update_date 		= sysdate,
				    last_updated_by 		= l_rul.last_updated_by,
				    last_update_login 		= l_rul.last_update_login
				where item_id 			= l_rul.item_id;
			END IF;
		ELSE
			--WriteToLogFile('Updating revised price of Standing Charge Line Item');
                        -- bug 3199481, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg11',
                                                          'Updating revised price of Standing Charge Line Item');
                        END IF;
                        -- bug 3199481, end block
			update igi_rpi_line_details
			set revised_price 		= l_rul.updated_price,
			    revised_effective_date	= l_ruh.effective_date,
			    last_update_date		= sysdate,
			    last_updated_by		= l_rul.last_updated_by,
			    last_update_login		= l_rul.last_update_login
			where item_id = l_rul.item_id
			and   line_item_id = l_rul.line_item_id
			and   standing_charge_id = l_rul.standing_charge_id;

			open c_charge_item_number(l_rul.standing_charge_id, l_rul.line_item_id);
			fetch c_charge_item_number into l_charge_item_number;
			close c_charge_item_number;

			l_rowid := NULL;
			--WriteToLogFile('Insert record into Line Item Price Audit table with the run id');
                        -- bug 3199481, start block
                        IF (l_state_level >= l_debug_level) THEN
                            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg12',
                                                          'Insert record into Line Item Price Audit table with the run id');
                        END IF;
                        -- bug 3199481, end block
			igi_rpi_line_audit_det_all_pkg.insert_row( X_rowid	=> l_rowid,
								   X_standing_charge_id => l_rul.standing_charge_id,
								   X_line_item_id 	=> l_rul.line_item_id,
								   X_charge_item_number => l_charge_item_number,
								   X_item_id		=> l_rul.item_id,
								   X_price		=> l_rul.price,
								   X_effective_date	=> l_rul.effective_date,
								   X_revised_price	=> l_rul.revised_price,
								   X_revised_effective_date => l_rul.revised_effective_date,
								   X_run_id 		=> l_ruh.run_id,
								   X_org_id		=> to_number(l_org_id),
								   X_previous_price	=> l_rul.previous_price,
								   X_previous_effective_date => l_rul.previous_effective_date);

		END IF;

        END LOOP;

	--WriteToLogFile('Updating status of Update Header to COMPLETED');
        -- bug 3199481, start block
        IF (l_state_level >= l_debug_level) THEN
            FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg13',
                                          'Updating status of Update Header to COMPLETED');
        END IF;
        -- bug 3199481, end block
        update igi_rpi_update_hdr
        set    status = 'COMPLETED'
        where  run_id = l_ruh.run_id ;

    END LOOP;
    -- bug 3199481, start block
    IF (l_state_level >= l_debug_level) THEN
       FND_LOG.STRING(l_state_level, 'igi.plsql.igirrgpp.update_price.Msg14',
                                     'End of processing of Items for Price update');
    END IF;
    -- bug 3199481, end block
    --WriteToLogFile('End of processing of Items for Price update');

END UpdatePrice;

PROCEDURE UpdatePriceCP (
                         errbuf  out NOCOPY   varchar2
                        ,retcode out NOCOPY  number
                        ,pp_run_id in number
                        )
IS
BEGIN

   UpdatePrice ( pp_run_id ) ;

   retcode := 0;
   errbuf  := null;
   commit;
EXCEPTION WHEN OTHERS THEN
      retcode := 2;
      errbuf  := SQLERRM;
      rollback;
END UpdatePriceCP;

END;

/
