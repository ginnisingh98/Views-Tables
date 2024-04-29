--------------------------------------------------------
--  DDL for Package Body MTL_ONLINE_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_ONLINE_TRANSACTION_PUB" AS
/* $Header: INVTXNB.pls 120.0 2005/05/25 05:37:17 appldev noship $ */


  FUNCTION process_online(p_transaction_header_id IN NUMBER,
                p_timeout in number default NULL,
                p_error_code OUT NOCOPY VARCHAR2,
                p_error_explanation OUT NOCOPY VARCHAR2
                )
  RETURN BOOLEAN
  IS
     p_success boolean := TRUE;
		 p_retval number;
     l_transaction_header_id number;
     l_return_status varchar(2);
     l_msg_cnt number;
     l_msg_data varchar2(241);
     l_trans_count number;
			l_mti_cnt number;
			l_mmtt_cnt number;
			l_dbgfile varchar2(240) := 'invtmonl.log';
			l_dbgdir  varchar2(240);

    l_debug number := NVL(FND_PROFILE.VALUE('INV_DEBUG_TRACE'),0);
  BEGIN

     l_transaction_header_id := p_transaction_header_id;

			/*
			 * Lock all the rows corresponding to this batch so that
			 * the Background manager does not pick it up
			 */
       UPDATE MTL_TRANSACTIONS_INTERFACE
        SET LOCK_FLAG = 1
       WHERE PROCESS_FLAG = 1
        AND TRANSACTION_HEADER_ID = l_transaction_header_id;
       COMMIT;

     -- call to process transactions online
     /*    p_success := inv_tm.launch
         (
          program  => 'INXTCW',
          args     => to_char(l_transaction_header_id),
          timeout  => NVL(p_timeout,120),
          rc_field  => NULL); */

     -- calling process_transactions() with p_commit = true as otherwise
     -- error-codes stamped on MTI could get rolled back.
     p_retval := INV_TXN_MANAGER_PUB.process_Transactions(p_api_version => 1,
          p_init_msg_list    => fnd_api.g_false     ,
          p_commit           => fnd_api.g_true     ,
          p_validation_level => fnd_api.g_valid_level_full  ,
          x_return_status => l_return_status,
          x_msg_count  => l_msg_cnt,
          x_msg_data   => l_msg_data,
          x_trans_count   => l_trans_count,
          p_table	   => 1,
          p_header_id => l_transaction_header_id);

     -- BUG 2709500 / 2718486 - added commit and changed p_commit above to false
     COMMIT;

     -- no need to unlock the records in the interface tables
     -- as the underlying code has done just that.
     -- no need to set the error_code and error_explaination
     -- either as underlying code also has done that.
     if(p_retval <> 0) THEN
        p_success := false;
        select error_code, error_explanation
          into p_error_code, p_error_explanation
        from mtl_transactions_interface
        where transaction_header_id = l_transaction_header_id
          and rownum = 1;

        IF (l_debug = 1) THEN
           inv_log_util.trace('Error from INV worker : error_code : '||
            p_error_code||', err_expl :'||p_error_explanation,'INVTXNB',1);
        END IF;

     end if;

     return p_success;

  EXCEPTION
     -- the underlying code should have provided enough error message
     -- in the stack. we need not add any additional messages

     WHEN NO_DATA_FOUND THEN
        p_error_code := ' ';
        p_error_explanation := 'No Errors';
        RETURN TRUE;
     WHEN TOO_MANY_ROWS THEN
	--        dbms_output.put_line('Please specify the correct transaction header');
        p_error_explanation:=  fnd_message.get;
     --	p_error_explanation:= 'Please specify the correct transaction header';
        RETURN false;
     WHEN OTHERS THEN
        --commented for testing        ROLLBACK;
        RETURN FALSE;

  END;

END;

/
