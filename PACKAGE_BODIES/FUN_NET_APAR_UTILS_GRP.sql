--------------------------------------------------------
--  DDL for Package Body FUN_NET_APAR_UTILS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_NET_APAR_UTILS_GRP" AS
/* $Header: funntutilb.pls 120.0.12010000.3 2008/10/29 10:12:26 ychandra noship $ */

PROCEDURE generic_error(routine in varchar2,
			errcode in number,
			errmsg in varchar2) IS
BEGIN
   fnd_message.set_name('FND', 'SQL_PLSQL_ERROR');
   fnd_message.set_token('ROUTINE', routine);
   fnd_message.set_token('ERRNO', errcode);
   fnd_message.set_token('REASON', errmsg);
   IF (FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.MESSAGE(FND_LOG.LEVEL_UNEXPECTED, routine, FALSE);
   END IF;
   /*fnd_message.raise_error; */
END;

/* This Procedure Returns Y if the Netting batch is complete else returns N '.
If there is any system error then return 'E'*/
/*p_invoice_id    - This is an in parameter which holds the invoice_id.*/

FUNCTION Get_Invoice_Netted_status (p_invoice_id IN Number)
    RETURN VARCHAR2
    IS
        l_batch_id Number;
	l_batch_status_code Varchar2(30);
	x_msg_data VARCHAR2(100);
    BEGIN
	if(p_invoice_id IS NOT NULL) then
	   BEGIN
		select batch_id into l_batch_id
		from FUN_NET_AP_INVS_ALL
		where invoice_id=p_invoice_id;
	   EXCEPTION
	        WHEN NO_DATA_FOUND THEN
			RETURN 'N';
		WHEN OTHERS THEN
		       x_msg_data:='Unknown error in Get_Invoice_Netted_status procedure';
       		       generic_error('FUN_NET_APAR_UTILS_GRP.Get_Invoice_Netted_status', sqlcode, sqlerrm || ':' || x_msg_data );
	               RETURN 'E';

	   END;
		    if(l_batch_id IS NOT NULL)  then
				   select batch_status_code into l_batch_status_code
				   from FUN_NET_BATCHES_ALL
				   where batch_id=l_batch_id;
				   if l_batch_status_code='COMPLETE' then
				     RETURN 'Y';
				   else
				     RETURN 'N';
				   end if;
		    else
		      RETURN 'N';
		    end if;
	else
	    RETURN 'N'; -- if p_invoice_id is null
        end if;
	EXCEPTION
	        WHEN OTHERS THEN

		       x_msg_data:='Unknown error in Get_Invoice_Netted_status procedure';
       		       generic_error('FUN_NET_APAR_UTILS_GRP.Get_Invoice_Netted_status', sqlcode, sqlerrm || ':' || x_msg_data );
		       RETURN 'E';
END Get_Invoice_Netted_status;
/* This Procedure Returns batch status and corresponding batch id if the passed invoice_id is valid, else
it returns it returns the appropriate error message */
/*
p_invoice_id    - This is an in parameter which holds the invoice_id.
x_batch_id      - This holds the batch_id of the corresponding invoice_id.
x_batch_status  - This is an out parameter which holds the status of the batch.
x_return_status - This returns S if the procedure call is success else returns E.
x_msg_data      - This hold the error message in case of failure of this procedure call.
*/
   PROCEDURE Get_Netting_Batch_Info(p_invoice_id IN Number,
				    x_batch_id OUT NOCOPY Number,
				    x_batch_status OUT NOCOPY VARCHAR2,
				    x_return_status OUT NOCOPY VARCHAR2,
				    x_msg_data OUT NOCOPY VARCHAR2) AS
   BEGIN
	    if(p_invoice_id IS NOT NULL) then
	            Begin
                          select batch_id into x_batch_id from FUN_NET_AP_INVS_ALL where invoice_id=p_invoice_id;
		    exception
                       when NO_DATA_FOUND then
			       x_return_status:='E'; /* In this case the batch is not netted*/
			       x_msg_data:='Invoice ID was not found in any of the Netting Batch';
			       generic_error('FUN_NET_APAR_UTILS_GRP.Get_Netting_Batch_Info', sqlcode, sqlerrm || ':' || x_msg_data );
		       when OTHERS then
			       x_return_status:='E';
			       x_msg_data:='Unknown error in Get_Netting_Batch_Info procedure';
			       generic_error('FUN_NET_APAR_UTILS_GRP.Get_Netting_Batch_Info', sqlcode, sqlerrm || ':' || x_msg_data );
		    End;
		    if(x_batch_id IS NOT NULL) then
				select batch_status_code into x_batch_status from FUN_NET_BATCHES_ALL where batch_id=x_batch_id;
				x_return_status:='S';
				return;
		    end if;
            else
		   x_return_status:='E';
		   x_msg_data:='Message from FUN_NET_APAR_UTILS_GRP package : Invoice_id is Null';
    	           generic_error('FUN_NET_APAR_UTILS_GRP.Get_Netting_Batch_Info', sqlcode, sqlerrm || ':' || x_msg_data );
		  RETURN;
	    end if;
            exception
                  when OTHERS then
                       x_return_status:='E';
		       x_msg_data:='Unknown error in Get_Netting_Batch_Info procedure';
       		       generic_error('FUN_NET_APAR_UTILS_GRP.Get_Netting_Batch_Info', sqlcode, sqlerrm || ':' || x_msg_data );
end Get_Netting_Batch_Info;
end FUN_NET_APAR_UTILS_GRP;

/
