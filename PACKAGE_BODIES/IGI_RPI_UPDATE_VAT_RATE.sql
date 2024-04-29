--------------------------------------------------------
--  DDL for Package Body IGI_RPI_UPDATE_VAT_RATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_RPI_UPDATE_VAT_RATE" AS
-- $Header: igirruvrb.pls 120.0.12010000.1 2010/02/15 09:44:11 gaprasad noship $

  l_state_level CONSTANT NUMBER := FND_LOG.LEVEL_STATEMENT;
  l_proc_level  CONSTANT NUMBER := FND_LOG.LEVEL_PROCEDURE;
  l_event_level CONSTANT NUMBER := FND_LOG.LEVEL_EVENT;
  l_excep_level CONSTANT NUMBER := FND_LOG.LEVEL_EXCEPTION;
  l_error_level CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
  l_unexp_level CONSTANT NUMBER := FND_LOG.LEVEL_UNEXPECTED;

PROCEDURE WriteToLogFile ( pp_msg_level in number,pp_path in varchar2, pp_mesg in varchar2 ) IS
BEGIN

     IF pp_msg_level >=  FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
         fnd_log.string(pp_msg_level, pp_path, pp_mesg );
     END IF;
END;

PROCEDURE output (p_msg IN VARCHAR2) IS
BEGIN

    fnd_file.put_line(fnd_file.output, p_msg);

END output;

PROCEDURE print_header (effective_date in date,old_tax_code varchar2,new_tax_code varchar2) IS
BEGIN

            output ('IGIRRUVR                                      Standing Charges : Preliminary VAT Rate Update Report  		              '||'Date :  '||trunc(SYSDATE));
	      output ('');
            output ('');
            output ('');
            output ('');
            output ('                                          VAT Effective Date : '||effective_date);
            output ('');
            output ('                                          Old VAT Rate : '||rtrim(old_tax_code));
            output ('                                          New VAT Rate : '||rtrim(new_tax_code));
            output ('');
            output ('');
            output ('');
	      output ('            ---------------------------------------------------------------------------------------------------------------------------------------------');
	      output ('               Charge Reference                  Bill Period      Start Date          Next Due Date  		      Description                         ');
	      output ('            ---------------------------------------------------------------------------------------------------------------------------------------------');
            output ('');
            output ('');

END print_header;

PROCEDURE print_footer IS
BEGIN

            output ('');
            output ('');
            output ('');
            output ('');
	    output ('                                           ********************** END OF REPORT *****************************  		                              ');

END print_footer;


FUNCTION tax_name(vat_id NUMBER) RETURN varchar2 IS

l_tax_code varchar2(50);

BEGIN

  SELECT tax_rate_code INTO l_tax_code
  FROM zx_rates_b
  WHERE tax_rate_id = vat_id;

  RETURN l_tax_code;

EXCEPTION
WHEN OTHERS THEN
           WriteToLogFile(l_state_level, 'igi.plsql.igirruvr.Tax_name',
                                         '(Error) Tax Name Procedure');

END tax_name;



PROCEDURE update_vat_rate (  errbuf              OUT NOCOPY VARCHAR2
 	                     , retcode             OUT NOCOPY NUMBER
		               , p_org_id            IN  NUMBER
		               , p_old_vat_id        IN  NUMBER
                       	   , p_new_vat_id        IN  NUMBER
    	                     , p_effective_date    IN  VARCHAR2
 	 	   	 	   , p_mode              IN  VARCHAR2
                          )
IS

  l_request_id            NUMBER;
  l_rec_count             NUMBER;
  l_mesg                  varchar2(200) ;
  l_effective_date        DATE;
  l_rowid                 varchar2(25) ;
  l_old_tax_code          varchar2(50) ;
  l_new_tax_code          varchar2(50) ;
  l_legal_entity_id       NUMBER;

  x_return_status         VARCHAR2(30);

  x_effective_date 	  DATE;
  x_msg_count 		  NUMBER;
  x_msg_data 		  VARCHAR2(100);


/*------------------------------------------------------*
 |       Cursor for Selecting Standing Charges          |
 *------------------------------------------------------*/

CURSOR C_standing_charges ( cp_org_id         in number
                          , cp_effective_date in date )  IS
        SELECT sc.*
        FROM   igi_rpi_standing_charges_all sc
        WHERE  org_id             =  cp_org_id
        AND    upper(sc.status)   = 'ACTIVE'
        AND    sc.START_DATE      <= cp_effective_date
        AND    sc.NEXT_DUE_DATE   >= cp_effective_date;


/*-----------------------------------------------------------------------------------*
 | Cursor for Line Details based on the Selected Standing Charge cursor above		 |
 *-----------------------------------------------------------------------------------*/

CURSOR C_line_details (cp_standing_charge_id  in number
                      ,cp_old_vat_id          in number ) IS
        SELECT ld.*
        FROM   igi_rpi_line_details_all     ld
        WHERE  ld.standing_charge_id          = cp_standing_charge_id
        AND    ld.vat_tax_id                  = cp_old_vat_id;


BEGIN

    l_mesg                := null;
    l_rec_count		  := 0;

    IF p_effective_date IS NOT NULL THEN
	    l_effective_date      :=  to_date(p_effective_date,'YYYY/MM/DD HH24:MI:SS');
    ELSE
	    l_effective_date      :=  SYSDATE;
    END IF;


    IF igi_gen.is_req_installed('RPI') THEN
       null;
    ELSE
       fnd_message.set_name( 'IGI', 'IGI_RPI_IS_DISABLED');
       l_mesg := fnd_message.get;
           WriteToLogFile(l_state_level, 'igi.plsql.igirruvr.update_vat_rate.Msg1',
                                         l_mesg);
       retcode := 2;
       errbuf  := l_mesg;
       RETURN;
    END IF;

           WriteToLogFile(l_state_level, 'igi.plsql.igirruvr.update_vat_rate.Msg2',
                                         'BEGIN Update VAT Rate');


	 l_request_id := FND_GLOBAL.CONC_REQUEST_ID;

 	 l_old_tax_code := tax_name(p_old_vat_id);
 	 l_new_tax_code := tax_name(p_new_vat_id);

		  /* Printing header into the output file */

       print_header(l_effective_date,l_old_tax_code,l_new_tax_code);

    FOR C_standing_charges_rec in C_standing_charges(p_org_id,l_effective_date) LOOP

          FOR C_line_details_rec in C_line_details(C_standing_charges_rec.standing_charge_id,p_old_vat_id) LOOP

                      l_rec_count := l_rec_count + 1;

		  /* Printing records into the output file */


		      output ('             '||rtrim(C_standing_charges_rec.charge_reference)||'                                  '||C_standing_charges_rec.period_name||'          '||
				  C_standing_charges_rec.start_date||'           '||C_standing_charges_rec.next_due_date||'             '||rtrim(substr(C_standing_charges_rec.description,1,30)));


		  /* Inserting into line_details_audit table for audit trail */

			igi_rpi_line_audit_det_all_pkg.insert_row (
	            x_mode                              => 'R',
	            x_rowid                             => l_rowid,
	            x_standing_charge_id                => TO_NUMBER (C_standing_charges_rec.standing_charge_id),
	            x_line_item_id                      => TO_NUMBER (C_line_details_rec.LINE_ITEM_ID),
	            x_charge_item_number                => TO_NUMBER (C_line_details_rec.CHARGE_ITEM_NUMBER),
	            x_item_id                           => TO_NUMBER (C_line_details_rec.ITEM_ID),
	            x_price                             => nvl(C_line_details_rec.REVISED_PRICE,C_line_details_rec.PRICE),
	            x_effective_date                    => nvl(C_line_details_rec.REVISED_EFFECTIVE_DATE,C_line_details_rec.CURRENT_EFFECTIVE_DATE),
	            x_revised_price                     => C_line_details_rec.REVISED_PRICE,
	            x_revised_effective_date            => C_line_details_rec.REVISED_EFFECTIVE_DATE,
	            x_run_id                            => TO_NUMBER (C_line_details_rec.RUN_ID),
	            x_org_id                            => TO_NUMBER (C_line_details_rec.ORG_ID),
		      x_previous_price                    => C_line_details_rec.PRICE,
		      x_previous_effective_date           => C_line_details_rec.CURRENT_EFFECTIVE_DATE,
	            x_old_vat_id                        => p_old_vat_id,
	            x_new_vat_id                        => p_new_vat_id,
	            x_request_id                        => l_request_id
	           );


		  /* Updating new VAT Rate to all charge lines */

	           UPDATE igi_rpi_line_details_all ld  SET
			ld.VAT_TAX_ID = p_new_vat_id
	           WHERE ld.standing_charge_id = C_standing_charges_rec.standing_charge_id
	           AND   ld.line_item_id = C_line_details_rec.line_item_id
	           AND   ld.org_id = p_org_id;


	    END LOOP;   /* C_line_details loop */

    END LOOP;   /* C_standing_charges loop */

	        IF (l_rec_count = 0) THEN

	            output ('                                                          -------- NO DATA FOUND -------');

		  END IF;


       print_footer;

           WriteToLogFile(l_state_level, 'igi.plsql.igirruvr.update_vat_rate.Msg3',
                                         'END (Successful) Update VAT Rate');
    errbuf := null;
    retcode := 0;

		  /* Commit only when the request is run in final mode,rollback in preliminary mode */

	IF p_mode = 'P' THEN
		ROLLBACK;
	END IF;

EXCEPTION WHEN OTHERS THEN

           ROLLBACK;
           WriteToLogFile(l_state_level, 'igi.plsql.igirruvr.update_vat_rate.Msg4',
                                         'END (Error) Update VAT Rate');
   errbuf := SQLERRM;
   retcode := 2;

END update_vat_rate;

END IGI_RPI_UPDATE_VAT_RATE;

/
