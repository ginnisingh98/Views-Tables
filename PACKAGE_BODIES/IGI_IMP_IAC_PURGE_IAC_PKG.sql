--------------------------------------------------------
--  DDL for Package Body IGI_IMP_IAC_PURGE_IAC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGI_IMP_IAC_PURGE_IAC_PKG" AS
-- $Header: igiimpib.pls 120.11 2007/08/01 10:47:48 npandya ship $

   --===========================FND_LOG.START=====================================

   g_state_level NUMBER	     :=	FND_LOG.LEVEL_STATEMENT;
   g_proc_level  NUMBER	     :=	FND_LOG.LEVEL_PROCEDURE;
   g_event_level NUMBER	     :=	FND_LOG.LEVEL_EVENT;
   g_excep_level NUMBER	     :=	FND_LOG.LEVEL_EXCEPTION;
   g_error_level NUMBER	     :=	FND_LOG.LEVEL_ERROR;
   g_unexp_level NUMBER	     :=	FND_LOG.LEVEL_UNEXPECTED;
   g_path        VARCHAR2(100)  := 'IGI.PLSQL.igiimpib.igi_imp_iac_purge_iac_pkg.';

   --===========================FND_LOG.END=====================================

Procedure  Purge_Iac_Data (
			   errbuf     OUT NOCOPY    VARCHAR2 ,
			   retcode    OUT NOCOPY    NUMBER   ,
			   p_book_type_code  VARCHAR2 ,
			   p_cat_struct_id   NUMBER   ,
			   p_category_id     NUMBER )
   IS

 --    Cursor to fetch the interface control record
	CURSOR c_ctrl IS
        SELECT   *
        FROM   igi_imp_iac_interface_ctrl ic
        WHERE  ic.book_type_code  = p_book_type_code
        AND    ic.category_id     = nvl(p_Category_id,ic.category_id);

--        Cursor to fetch the assets from the interface table
        CURSOR c_txns(cp_book VARCHAR2) IS
        SELECT   'Y'
        FROM      igi_iac_transaction_headers it
        WHERE  it.book_type_code  = cp_book
        AND        it.category_id           = nvl(p_Category_id,it.category_id)
        AND        NOT ( nvl(it.transaction_sub_type,'AA')   = 'IMPLEMENTATION')
        AND        rownum = 1 ;

	l_prd_rec                       igi_iac_types.prd_rec ;
	l_period_counter                NUMBER(15) ;
    l_txns_flag                     VARCHAR2(1) := 'N' ;
    l_corporate_book                VARCHAR2(15) ;
  	l_path_name VARCHAR2(150) := g_path||'purge_iac_data';

	IGI_IMP_PURGE_IAC_EXCEPTION     EXCEPTION ;

    Begin -- procedure purge_iac_data

    	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
		     	p_string => '*************** Starting Purge IAC Data... ******************');

        -- initialise the retcode
        Retcode := 2 ;
        --
        --    Check if the category has already been transferred
        --
      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
		     	p_string => 'Checking if the category has already been transferred ...');

      IF P_category_id is not null Then
        For ctrlrec in c_ctrl loop

                If ctrlrec.transfer_status  <>  'C'  then
                    fnd_message.set_name ('IGI','IGI_IMP_IAC_TRANSFER_NOT_DONE');
              		igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,
		  	    	p_full_path => l_path_name,
		  		    p_remove_from_stack => FALSE);
                    Errbuf := fnd_message.get;
	    	        fnd_file.put_line(fnd_file.log, errbuf);
                    retcode := 2 ;
                    RETURN ;
                end if;

        end loop ;
      End if;


        --Get the period information

        igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		    	 p_full_path => l_path_name,
		     	 p_string => ' Getting the period information ...');
        BEGIN
            SELECT ic.period_counter-1 , ic.corp_book
            INTO   l_period_counter , l_corporate_book
            FROM   igi_imp_iac_controls ic
            WHERE  ic.book_type_code = p_book_type_code ;
        EXCEPTION
            WHEN OTHERS THEN
          		igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     		p_full_path => l_path_name,
		     		p_string => 'Error : Fetching period counter from control '|| sqlerrm);
                fnd_message.set_name ('IGI','IGI_IAC_PURGE_IAC_ERROR');
		fnd_message.set_token('ERROR', sqlerrm);
		fnd_message.set_token('OPERATION', 'fetch period and corporate book info');
                Errbuf := fnd_message.get;
    	        fnd_file.put_line(fnd_file.log, errbuf);
                raise igi_imp_purge_iac_exception ;
          END;

          igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
		     	 p_string => 'Checking if there have been transactions after transfer ...');
         l_txns_flag  := 'N' ;
         For txnrec in c_txns(l_corporate_book) loop
             l_txns_flag  := 'Y' ;
         end loop ;

        If l_txns_flag = 'Y' Then
            fnd_message.set_name ('IGI','IGI_IMP_IAC_TXNS_AFTER_TFR');
      	    igi_iac_debug_pkg.debug_other_msg(p_level => g_state_level,p_full_path => l_path_name,
		  		p_remove_from_stack => FALSE);
            Errbuf := fnd_message.get;
	        fnd_file.put_line(fnd_file.log, errbuf);
            retcode := 2 ;
            RETURN ;
        End If;

    	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
		     	p_string => 'Fetching period Info for counter : '|| l_period_counter );

        IF ( NOT( Igi_Iac_Common_Utils.Get_Period_Info_For_Counter (
                                                l_corporate_book ,
                                                l_period_Counter ,
                                                l_prd_rec
                                                )))
        THEN
                fnd_message.set_name ('IGI','IGI_IAC_PURGE_IAC_ERROR');
		fnd_message.set_token('ERROR', ' ');
		fnd_message.set_token('OPERATION', 'fetch period info for period counter');
          	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  		p_full_path => l_path_name,
		  		p_remove_from_stack => FALSE);
                Errbuf := fnd_message.get;
	            fnd_file.put_line(fnd_file.log, errbuf);
                raise igi_imp_purge_iac_exception ;
       END IF;

      	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_adjustments ...');

        Delete igi_iac_adjustments a
        Where a.book_type_code = l_corporate_book
        and exists  (   select   i.asset_id
                        from     igi_imp_iac_interface I
                        where    i.book_type_code =  p_book_type_code
                        and      i.category_id    =  nvl(p_category_id,i.category_id)
                        and      i.asset_id       =  a.asset_id );

          	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,p_full_path => l_path_name,
		         	p_string => SQL%rowcount || ' rows deleted.');

          	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_det_balances ...');

        Delete from  igi_iac_det_balances d
        Where d.book_type_code  = l_corporate_book
        and exists  (   select   i.asset_id
                        from     igi_imp_iac_interface I
                        where    i.book_type_code =  p_book_type_code
                        and      i.category_id    =  nvl(p_category_id,i.category_id)
                        and      i.asset_id       =  d.asset_id );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_fa_deprn ...');

        Delete from  igi_iac_fa_deprn d
        Where d.book_type_code  = l_corporate_book
        and exists  (   select   i.asset_id
                        from     igi_imp_iac_interface I
                        where    i.book_type_code =  p_book_type_code
                        and      i.category_id    =  nvl(p_category_id,i.category_id)
                        and      i.asset_id       =  d.asset_id );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_asset_balances ...');

        Delete from  igi_iac_asset_balances b
        Where b.book_type_code  = l_corporate_book
        and exists  (   select   i.asset_id
                        from     igi_imp_iac_interface I
                        where    i.book_type_code =  p_book_type_code
                        and      i.category_id    =  nvl(p_category_id,i.category_id)
                        and      i.asset_id       =  b.asset_id );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');


  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_transaction_headers ...');

        Delete from igi_iac_transaction_headers t
        Where t.book_type_code  = l_corporate_book
        and exists  (   select   i.asset_id
                        from     igi_imp_iac_interface I
                        where    i.book_type_code =  p_book_type_code
                        and      i.category_id    =  Nvl(p_category_id,i.category_id)
                        and      i.asset_id       =  t.asset_id );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_revaluations ...');

        Delete igi_iac_revaluations r
        where  r.revaluation_id in ( select c.revaluation_id
                                    from  igi_iac_reval_categories c
                                    where c.book_type_code   =  l_corporate_book
                                    and   category_id        =  nvl(p_category_id,category_id) );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_reval_categories ...');

        Delete igi_iac_reval_categories c
        where  c.book_type_code   =  l_corporate_book
        and    c.category_id      =  nvl(p_category_id,c.category_id) ;

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Deleting igi_iac_revaluatio_rates ...');

        Delete igi_iac_revaluation_rates c
        where  c.book_type_code   =  l_corporate_book
        and    EXISTS ( SELECT a.asset_id
                        FROM   fa_additions a
                        WHERE  a.asset_category_id = nvl(p_category_id,a.asset_category_id)
                        AND    a.asset_id          = c.asset_id );

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows deleted.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Updating igi_imp_iac_interface_ctrl status to Not transferred ...');
        Update igi_imp_iac_interface_ctrl c
        set    c.transfer_status  =  'N'
        where  c.book_type_code   =  p_book_type_code
        and    c.category_id      =  nvl(p_category_id,c.category_id) ;
        IF ( SQL%rowcount = 0 ) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => 'ERROR : Could not set igi_imp_iac_interface_ctrl status to NOT TRANSFERRED');
            fnd_message.set_name ('IGI','IGI_IAC_PURGE_IAC_ERROR');
            fnd_message.set_token('ERROR', 'igi_imp_iac_interface_ctrl table does not contain anyrows for given book and category');
	    fnd_message.set_token('OPERATION', 'update transfer status to Not Transferred');
  	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  		p_full_path => l_path_name,
		  		p_remove_from_stack => FALSE);
            Errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            raise igi_imp_purge_iac_exception ;
        END IF;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows updated.');

  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Updating igi_imp_iac_interface status to Not transferred ...');
        Update igi_imp_iac_interface i
        set    i.transferred_flag  =  'N'
        where  i.book_type_code   =  p_book_type_code
        and    i.category_id      =  nvl(p_category_id,i.category_id) ;
        IF ( SQL%rowcount = 0 ) THEN
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => 'ERROR : Could not set igi_imp_iac_interface status to NOT TRANSFERRED');
            fnd_message.set_name ('IGI','IGI_IAC_PURGE_IAC_ERROR');
            fnd_message.set_token('ERROR', 'igi_imp_iac_interface table does not contain anyrows for given book and category');
	    fnd_message.set_token('OPERATION', 'update transfer flag to N');
  	    igi_iac_debug_pkg.debug_other_msg(p_level => g_error_level,
		  		p_full_path => l_path_name,
		  		p_remove_from_stack => FALSE);
            Errbuf := fnd_message.get;
	    fnd_file.put_line(fnd_file.log, errbuf);
            raise igi_imp_purge_iac_exception ;
        END IF;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => SQL%rowcount || ' rows updated.');


        COMMIT;
  	igi_iac_debug_pkg.debug_other_string(p_level => g_state_level,
		     	p_full_path => l_path_name,
		     	p_string => 'Purge IAC Data Successfully completed.');
        retcode := 0 ;
        RETURN ;

    EXCEPTION
        WHEN igi_imp_purge_iac_exception THEN
            ROLLBACK WORK ;
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_error_level,
		     	p_full_path => l_path_name,
		     	p_string => 'ERROR : Purge IAC Data failed - '|| sqlerrm);
            retcode := 2;
            RETURN ;
        WHEN OTHERS THEN
            ROLLBACK WORK ;
  	    igi_iac_debug_pkg.debug_other_string(p_level => g_unexp_level,
		     	p_full_path => l_path_name,
		    	p_string => 'Unknown Exception : Purge IAC Data failed - '|| sqlerrm);
            fnd_message.set_name ('IGI','IGI_IAC_PURGE_IAC_ERROR');
            fnd_message.set_token('ERROR', sqlerrm);
	    fnd_message.set_token('OPERATION', ' ');
            Errbuf := fnd_message.get;
            retcode := 2;
            RETURN ;
    END; -- end of procedure purge iac data
END;  -- end of package



/
