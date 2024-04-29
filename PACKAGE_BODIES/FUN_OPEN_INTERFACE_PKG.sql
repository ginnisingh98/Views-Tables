--------------------------------------------------------
--  DDL for Package Body FUN_OPEN_INTERFACE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FUN_OPEN_INTERFACE_PKG" AS
/* $Header: funximpb.pls 120.22.12010000.7 2009/11/17 06:26:05 abhaktha ship $ */

G_DEBUG VARCHAR2(5);

PROCEDURE Print
        (
               P_string                IN      VARCHAR2
        ) IS

  stemp    VARCHAR2(80);
  nlength  NUMBER := 1;

BEGIN
-- print only if  debgu is set on
IF G_DEBUG='Y' THEN
     WHILE(length(P_string) >= nlength)
     LOOP
        stemp := substrb(P_string, nlength, 80);
        fnd_file.put_line(FND_FILE.LOG, stemp);
        nlength := (nlength + 80);
     END LOOP;
END IF;

EXCEPTION
  WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END Print;

PROCEDURE Derive_Batch_Attributes(
	p_initiator_name 	IN  VARCHAR2,
	p_from_le_name 		IN VARCHAR2,
	p_trx_type_name 	IN VARCHAR2,
	x_return_status 	OUT NOCOPY VARCHAR2,
	p_initiator_id 		IN OUT NOCOPY NUMBER,
	p_from_le_id 		IN OUT NOCOPY NUMBER,
	p_from_ledger_id 	IN OUT NOCOPY NUMBER,
	p_trx_type_id 		IN OUT NOCOPY NUMBER,
	p_trx_type_code 	IN OUT NOCOPY VARCHAR2
) IS

l_initiator_id_per_name         fun_interface_batches.initiator_id%type;
l_From_Le_id_per_name           fun_interface_batches.from_le_id%type;
l_From_Le_id_per_initiator_id   fun_interface_batches.from_le_id%type;
l_Trx_type_id_per_name	        fun_interface_batches.trx_type_id%type;
l_Trx_type_id_per_code	        fun_interface_batches.trx_type_id%type;
l_From_Ledger_id_per_le	        fun_interface_batches.from_ledger_id%type;

Cursor c_Init_id_per_name(l_initiator_name IN VARCHAR2) IS
     SELECT p.party_id
     FROM hz_parties p
     WHERE p.party_name = l_initiator_name
     and p.party_type='ORGANIZATION'
     and exists (select u.party_usg_assignment_id from hz_party_usg_assignments u
            where u.party_usage_code = 'INTERCOMPANY_ORG'
            and u.party_id = p.party_id);

Cursor c_Le_Id_per_name(l_From_le_name IN VARCHAR2) IS
    SELECT legal_entity_id
    FROM   xle_firstparty_information_v
    WHERE  name=l_from_le_name;

     /*SELECT hp.party_id
     FROM hz_parties hp, hz_code_assignments hca
     WHERE hp.party_name = l_From_Le_name
    	  and hca.owner_table_name like 'HZ_PARTIES'
    	  and hca.owner_table_id = hp.party_id
    	  and hca.class_code like 'LEGAL_ENTITY'
    	  and hca.class_category like 'LEGAL_FUNCTION';*/

Cursor c_ledger_id(l_from_le_id IN NUMBER)  IS
     SELECT ledger_id
     FROM gl_ledger_le_v
     WHERE legal_entity_id = l_from_le_id
     AND ledger_category_code = 'PRIMARY';

Cursor c_trx_type_id_per_name(l_trx_type_name IN VARCHAR2) IS
   SELECT trx_type_id
    FROM fun_Trx_types_vl
    WHERE trx_type_name = l_Trx_type_name;

Cursor c_trx_type_id_per_code(l_trx_type_code IN VARCHAR2) IS
   SELECT trx_type_id
    FROM fun_Trx_types_vl
    WHERE trx_type_code = l_Trx_type_code;

Cursor c_trx_type_code_per_id(l_trx_type_id IN VARCHAR2) IS
   SELECT trx_type_code
    FROM fun_Trx_types_vl
    WHERE trx_type_id = l_Trx_type_id;

Cursor c_from_le_id (l_party_id IN NUMBER)  IS --3603338 new cursor
   SELECT legal_entity_id
   FROM xle_firstparty_information_v
   WHERE party_id = l_party_id;

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Print('Main Package ~~~'||'Deriving Initiator Id from Initiator Name ');
  fun_trx_entry_util.log_debug(FND_LOG.LEVEL_PROCEDURE,
                               'FUN_OPEN_INTERFACE_PKG.Derive_Batch_Attributes',
                               'Main Package');
  -- Derive Initiator Id from Initiator Name if Initiator Id is not populated

  IF (p_initiator_name is not null) THEN
   --validate initiator name and retrieve initiator id

   open c_init_id_per_name(p_initiator_name);
   fetch c_init_id_per_name into l_initiator_id_per_name;
   If (c_init_id_per_name%notfound) then
   	  Print('Main Package ~~~'||'No Initiator Exists by this name');
   	close c_init_id_per_name;
   	Raise FND_API.G_EXC_ERROR;
    Elsif (c_init_id_per_name%rowcount > 1) then
   		  Print('Main Package ~~~'||'Multiple Parties with the Initiator name given');
   		close c_init_id_per_name;
   		Raise FND_API.G_EXC_ERROR;

    End If;
    close c_init_id_per_name;

   IF (p_initiator_id is not null)  then
          If (p_initiator_id <> l_initiator_id_per_name) then
		  Print('Main Package ~~~'||'Initiator Id and Initiator Name are inconsistent');
		Raise FND_API.G_EXC_ERROR;
          End if;
   Else
   	  p_initiator_id := l_initiator_id_per_name;
   End If;
  END IF;

  Print('Main Package ~~~'||'Deriving From_Le_Id populated from From_Le_Name');
  -- Derive From_Le_Id populated from From_Le_Name.

  IF (p_From_Le_name is not null) THEN
   --validate From_Le name and retrieve From_Le_ id

   open c_le_id_per_name(p_from_le_name);
   fetch c_le_id_per_name into l_from_le_id_per_name;
   If (c_le_id_per_name%notfound) then
   	  Print('Main Package ~~~'||'No Legal Entity Exists by this name');
   	close c_le_id_per_name;
   	Raise FND_API.G_EXC_ERROR;
    Elsif (c_le_id_per_name%rowcount > 1) then
   		  Print('Main Package ~~~'||'Multiple Legal Entities for the name given');
   		close c_le_id_per_name;
   		Raise FND_API.G_EXC_ERROR;
   End If;
   close c_le_id_per_name;

   IF (p_From_Le_id is not null) then
         If (p_From_Le_id <> l_From_Le_id_per_name) then
		  Print('Main Package ~~~'||'From Le Id  and From Le Name are inconsistent');
		  Raise FND_API.G_EXC_ERROR;
          End if;

   Else
   	  p_From_Le_id := l_From_Le_id_per_name;
   End If;
  END IF;

  l_From_Le_id_per_initiator_id := fun_tca_pkg.get_le_id(p_initiator_id);


		  Print('Main Package ~~~'||' Initiator Id '||p_initiator_id);
  /*If ((p_from_le_id is not null) and (l_From_Le_id_per_initiator_id is not null)) then
         If (p_From_Le_id <> l_From_Le_id_per_initiator_id) then
		  Print('Main Package ~~~'||'From Le Id and Initiator Id '||l_from_le_id_per_initiator_id||' are inconsistent');
	--	Raise FND_API.G_EXC_ERROR;
          End if;
  Else */

  If p_from_le_id is null then
      If(l_from_le_id_per_initiator_id is not null) then
     		open c_from_le_id ( l_From_Le_id_per_initiator_id );
      		fetch c_from_le_id into p_From_Le_id ;
    		close c_from_le_id;
	        --p_From_Le_id := l_From_Le_id_per_initiator_id; 3603338 added the above three lines and commented this line out
     End if;
  End If;

  Print('Main Package ~~~'||'Deriving From_Ledger_Id populated from From_Le_Id');
  /* Derive From_Ledger_Id from From Le Id*/
  --3603338 Uncomment ledger_id fetch

  IF (p_From_Le_id is not null) THEN
   --validate From_Le_Id and retrieve From_Ledger_ id

     OPEN  c_ledger_id(p_from_le_id);
     fetch c_ledger_id into l_from_ledger_id_per_le;
     If (c_ledger_id%notfound) then
     	   Print('Main Package ~~~'||'No Primary Ledger attached to the Legal Entity');
     	  close c_ledger_id;
     	  Raise FND_API.G_EXC_ERROR;
     End If;
     close c_ledger_id;
     IF (p_From_Ledger_id is not null)  then
          If (p_From_Ledger_id <> l_From_Ledger_id_per_le) then
		  Print('Main Package ~~~'||'From Ledger Id and From Le Id are inconsistent');
		Raise FND_API.G_EXC_ERROR;
          End if;
     Else
     	  p_From_Ledger_id := l_From_Ledger_id_per_le;
     End If;

  END IF;

  -- Uncomment ledger_id fetch */
  Print('Main Package ~~~'||'Deriving Trx_Type_Id from Trx_Type_Name');
  -- Derive Trx_Type_Id from Trx_Type_Name

  IF (p_Trx_type_name is not null) THEN
   --validate Trx_type name and retrieve Trx_type_ id

     OPEN  c_trx_type_id_per_name(p_trx_type_name);
     fetch c_trx_type_id_per_name into l_Trx_type_id_per_name;
     If (c_trx_type_id_per_name%notfound) then
     	      Print('Main Package ~~~'||'Main Package ~~~'||'No Transaction Type with this name');
     	  close c_trx_type_id_per_name;
     	  Raise FND_API.G_EXC_ERROR;
     End If;
     close c_trx_type_id_per_name;

   IF (p_Trx_type_id is not null) then
          If (p_Trx_type_id <> l_Trx_type_id_per_name) then
		  Print('Main Package ~~~'||'Trx_Type_Id and Trx_Type_Name are inconsistent');
		Raise FND_API.G_EXC_ERROR;
          End if;
   Else
   	  p_Trx_type_id := l_Trx_type_id_per_name;
   End If;
END IF;

  Print('Main Package ~~~'||'Deriving Trx_Type_Code from Trx_Type_Id');
-- Derive Trx_Type_Code from Trx_Type_Id

IF (p_Trx_type_code is not null) THEN
   --validate Trx_type code and retrieve Trx_type_ id

     OPEN  c_trx_type_id_per_code(p_trx_type_code);
     fetch c_trx_type_id_per_code into l_Trx_type_id_per_code;
     If (c_trx_type_id_per_code%notfound) then
     	   Print('Main Package ~~~'||'No Transaction Type with this code');
     	  close c_trx_type_id_per_code;
     	  Raise FND_API.G_EXC_ERROR;
     End If;
     close c_trx_type_id_per_code;
Else

     OPEN  c_trx_type_code_per_id(p_trx_type_id);
     fetch c_trx_type_code_per_id into p_trx_type_code;
     If (c_trx_type_code_per_id%notfound) then
     	    Print('Main Package ~~~'||'No Transaction Type with this Id');
     	  close c_trx_type_code_per_id;
     	  Raise FND_API.G_EXC_ERROR;
     End If;
     close c_trx_type_code_per_id;
END IF;

IF ((p_Trx_type_id is not null) and (l_trx_type_id_per_code is not null)) then
          If (p_Trx_type_id <> l_Trx_type_id_per_code) then
		  Print('Main Package ~~~'||'Trx_Type_Code  and Trx_Type_Id are inconsistent');
		Raise FND_API.G_EXC_ERROR;
          End if;
Else
	If (l_trx_type_id_per_code is not null) then
         	p_Trx_type_id := l_Trx_type_id_per_code;
	End If;
End If;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Derive_Batch_Attributes;


PROCEDURE Derive_Transaction_Attributes(
	p_recipient_name 	IN VARCHAR2,
	p_to_le_name 		IN VARCHAR2,
	x_return_status 	OUT NOCOPY VARCHAR2,
	p_recipient_id 		IN OUT NOCOPY NUMBER,
	p_to_ledger_id 		IN OUT NOCOPY NUMBER,
	p_to_le_id 		IN OUT NOCOPY NUMBER

) IS

l_recipient_id_per_name     fun_interface_headers.recipient_id%type;
l_To_Le_id_per_name         fun_interface_headers.to_le_id%type;
l_To_Le_id_per_recipient_id fun_interface_headers.to_le_id%type;
l_To_Ledger_id_per_le	    fun_interface_headers.to_ledger_id%type;

Cursor c_reci_id_per_name(l_recipient_name IN VARCHAR2) IS
     SELECT p.party_id
     FROM hz_parties p
     WHERE p.party_name = l_recipient_name
     and p.party_type='ORGANIZATION'
     and exists (select u.party_usg_assignment_id from hz_party_usg_assignments u
            where u.party_usage_code = 'INTERCOMPANY_ORG'
            and u.party_id = p.party_id);


Cursor c_Le_Id_per_name(l_to_le_name IN VARCHAR2) IS
    SELECT legal_entity_id
    FROM   xle_firstparty_information_v
    WHERE  name=l_to_le_name;


     /*SELECT hp.party_id
     FROM hz_parties hp, hz_code_assignments hca
     WHERE hp.party_name = l_to_Le_name
    	  and hca.owner_table_name like 'HZ_PARTIES'
    	  and hca.owner_table_id = hp.party_id;
    	  and hca.class_code like 'LEGAL_ENTITY'
    	  and hca.class_category like 'LEGAL_FUNCTION';*/

Cursor c_ledger_id(l_to_le_id IN NUMBER)  IS
     SELECT ledger_id
     FROM gl_ledger_le_v
     WHERE legal_entity_id = l_to_le_id
     AND ledger_category_code = 'PRIMARY';
Cursor c_from_le_id (l_party_id IN NUMBER)  IS --3603338 new cursor
     SELECT legal_entity_id
     FROM xle_firstparty_information_v
     WHERE party_id = l_party_id;

BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

  Print('Main Package ~~~'||'Deriving Recipient Id from Recipient Name');
  fun_trx_entry_util.log_debug(FND_LOG.LEVEL_PROCEDURE,
                               'FUN_OPEN_INTERFACE_PKG.Derive_Transaction_Attributes',
                               'Main Package');
-- Derive Recipient Id from Recipient Name if Recipient Id is not populated

 IF (p_recipient_name is not null) THEN
   --validate recipient name and retrieve recipient id
    open c_reci_id_per_name(p_recipient_name);
    fetch c_reci_id_per_name into l_recipient_id_per_name;
    If (c_reci_id_per_name%notfound) then
   	  Print('Main Package ~~~'||'No Recipient Exists by this name');
   	close c_reci_id_per_name;
   	Raise FND_API.G_EXC_ERROR;
    Elsif (c_reci_id_per_name%rowcount > 1) then
   		  Print('Main Package ~~~'||'Multiple Parties with the Recipient name');
   		close c_reci_id_per_name;
   		Raise FND_API.G_EXC_ERROR;
    End If;
    close c_reci_id_per_name;

     IF (p_recipient_id is not null) then
          If (p_recipient_id <> l_recipient_id_per_name) then
		Print('Recipient Id and Recipient Name are inconsistent');
		Raise FND_API.G_EXC_ERROR;
          End if;
     Else
     	   p_recipient_id := l_recipient_id_per_name;
     End If;
END IF;

  Print('Main Package ~~~'||'Derive To_Le_Id populated from To_Le_Name');
-- Derive To_Le_Id populated from To_Le_Name.

IF (p_To_Le_name is not null) THEN
   --validate To_Le name and retrieve To_Le_ id

   open c_le_id_per_name(p_to_le_name);
   fetch c_le_id_per_name into l_to_le_id_per_name;
   If (c_le_id_per_name%notfound) then
   	  Print('Main Package ~~~'||'No Legal Entity Exists by this name');
   	close c_le_id_per_name;
   	Raise FND_API.G_EXC_ERROR;
    Elsif (c_le_id_per_name%rowcount > 1) then
   		  Print('Main Package ~~~'||'Multiple Legal Entities for the name given');
   		close c_le_id_per_name;
   		Raise FND_API.G_EXC_ERROR;
   End If;
   close c_le_id_per_name;
    IF (p_To_Le_id is not null) then
          If (p_To_Le_id <> l_To_Le_id_per_name) then
		  Print('Main Package ~~~'||'To Le Id and To Le Name are inconsistent');
		Raise FND_API.G_EXC_ERROR;
          End if;
    Else
      	 p_To_Le_id := l_To_Le_id_per_name;
    End If;
END IF;

If p_to_le_id is null
then
     l_To_Le_id_per_recipient_id := fun_tca_pkg.get_le_id(p_recipient_id);

     open c_from_le_id(l_To_Le_id_per_recipient_id) ;
     fetch c_from_le_id into  p_To_Le_id;
     close c_from_le_id ;
End If;

  Print('Main Package ~~~'||'Derive To_Ledger_Id from To_Le_Id');
/* Derive To_Ledger_Id from To_Le_Id*/
--/* Uncomment ledger_id fetch 3603338
IF (p_To_Le_id is not null) THEN
   --validate To_Le_Id and retrieve To_Ledger_ id

     OPEN  c_ledger_id(p_to_le_id);
     fetch c_ledger_id into l_to_ledger_id_per_le;
     If (c_ledger_id%notfound) then
     	  Print('No Primary Ledger attached to the Legal Entity');
     	  close c_ledger_id;
     	  Raise FND_API.G_EXC_ERROR;
     End If;
     close c_ledger_id;

   IF (p_To_Ledger_id is not null) then
         If (p_To_Ledger_id <> l_To_Ledger_id_per_le) then
		Print('To Ledger Id and To Le Id are inconsistent');
		--to be changed Raise FND_API.G_EXC_ERROR;
          End if;
   Else
   	  p_To_Ledger_id := l_To_Ledger_id_per_le;
   End If;
END IF;
--/* Uncomment ledger_id fetch 3603338
EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
	x_return_status := FND_API.G_RET_STS_ERROR;
WHEN OTHERS THEN
    	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Derive_Transaction_Attributes;


PROCEDURE MAIN
(
	p_errbuff  	 		OUT NOCOPY VARCHAR2,
	p_retcode 	 		OUT NOCOPY NUMBER,
	p_source 	 		IN VARCHAR2,
	p_group_id 	 		IN NUMBER,
	p_import_transaction_as_sent 	IN VARCHAR2 ,
	p_rejected_only 		IN VARCHAR2 ,
    p_debug             IN VARCHAR2
)
IS



Cursor c_head(l_batch_id IN NUMBER) is
	Select * from fun_interface_headers
		Where batch_id = l_batch_id;

Cursor c_dist_lines(l_trx_id IN NUMBER) is
	Select * from fun_interface_dist_lines
		Where trx_id = l_trx_id;

Cursor c_batch_dist (l_batch_id IN NUMBER) is
	Select * from fun_interface_batchdists
		Where batch_id = l_batch_id;

Cursor c_inv_flag(c_trx_type_id IN NUMBER ) IS
    Select allow_invoicing_flag
    from fun_trx_types_vl
    where trx_type_id = c_trx_type_id;

Curr_batch		fun_interface_batches%rowtype;
Curr_head 		fun_interface_headers%rowtype;
Curr_dist_line		fun_interface_dist_lines%rowtype;
Curr_batch_dist	fun_interface_batchdists%rowtype;

Overall_status 	varchar2(1);

l_return_status 	varchar2(1);
l_msg_data		varchar2(2000);
l_msg_count		number;


l_parameter_list_out  wf_parameter_list_t default null;

l_event_key                Varchar2(240);

l_batch_rec		FUN_TRX_PUB.FULL_BATCH_REC_TYPE;
l_trx_tbl		FUN_TRX_PUB.FULL_TRX_TBL_TYPE;
l_init_dist_tbl		FUN_TRX_PUB.FULL_INIT_DIST_TBL_TYPE;
l_dist_lines_tbl	FUN_TRX_PUB.FULL_DIST_LINE_TBL_TYPE;

l_count			number;
l_count_lines		number;

l_validation_level	number;

v_request_id		number;

l_reject_allow_flag	varchar2(1);
l_invoice_flag	varchar2(1);
l_exchg_rate_type		varchar2(30);
l_default_currency	varchar2(15);
l_running_total_dr	number;
l_running_total_cr	number;
l_batch_num	        varchar2(20);
l_numbering_type		varchar2(30);
l_batch_count		number;
l_control_date_tbl      fun_seq.control_date_tbl_type;
l_seq_version_id        NUMBER;
l_assignment_id         NUMBER;
l_error_code            VARCHAR2(30);
l_user_id               NUMBER;
l_grantee_key           VARCHAR2(30);

BATCH_NOT_FOUND	Exception;

BEGIN

SELECT hzp.party_id
          INTO l_user_id
          FROM hz_parties hzp,
            fnd_user u,
            per_all_people_f pap,
              (SELECT fnd_global.user_id() AS
            user_id
             FROM dual)
          curr
          WHERE curr.user_id = u.user_id
           AND u.employee_id = pap.person_id
           AND pap.party_id = hzp.party_id;
          l_grantee_key := 'HZ_PARTY:' || to_char(l_user_id);



  --removed default on p_generate_accounting as it is not used
  Print('Main Package ~~~'||'Start of Import Program');

  fun_trx_entry_util.log_debug(FND_LOG.LEVEL_PROCEDURE,
                               'FUN_OPEN_INTERFACE_PKG.Main',
                               'Main Package');
  -- Set the debug flag
  G_DEBUG := p_debug;

  Print('Main Package ~~~'||'Deleting any Rejections from previous failed imports');

-- Bug: 7595873
  /* Delete any rejections from previous failed imports*/
  Delete from fun_interface_rejections ftr
  where ftr.batch_id in(select ftb.batch_id
			from fun_interface_batches ftb
			where ftb.source = p_source
			and ftb.group_id = p_group_id);


  /*Set the Overall Status to get the status of one whole logical transaction*/
  Overall_status := 'A';

  /* If transaction is not Sent then only Minimum Validations are to be performed.
	Set l_validation_level It is sent as parameter to validation api's. Complete Validations are done if it is
	set to full. Minimum Validations are done if it is set to 50.
  */

  If  (nvl(p_import_transaction_as_sent,'N') = 'N') then
	l_validation_level := 50;
  Else
	l_validation_level := FND_API.G_VALID_LEVEL_FULL;
  end if;

  -- Derive reject_allow_flag from System Options

  If(FUN_SYSTEM_OPTIONS_PKG.get_allow_reject = TRUE) THEN
	l_reject_allow_flag  := 'Y';
  Else
	l_reject_allow_flag  := 'N';
  End If;

  SELECT exchg_rate_type, default_currency
  INTO l_exchg_rate_type, l_default_currency
  FROM fun_system_options;

  /*Select Batches for a given Source and Group.*/
  Print('Main Package ~~~'||'Reject Allowed Derived from System Options');
  l_batch_count := 0;

   Print('Main Package ~~~'|| 'Fetch Batches');
FOR curr_batch in (
SELECT * FROM fun_interface_batches
WHERE source = p_source
AND group_id = p_group_id
AND batch_id IN(SELECT DISTINCT fib.batch_id
                   FROM fun_interface_batches fib,
                     hz_parties hzp,
                     fnd_grants fg,
                     fnd_object_instance_sets fois,
                     hz_relationships hzr,
                     hz_org_contacts hc,
                     hz_org_contact_roles hcr
                   WHERE hzp.party_type = 'ORGANIZATION'
                   AND EXISTS
                    (SELECT 1
                     FROM hz_party_usg_assignments hua
                     WHERE hua.party_id = hzp.party_id
                     AND hua.party_usage_code = 'INTERCOMPANY_ORG'
                     AND hua.effective_start_date <= sysdate
                     AND(hua.effective_end_date >= sysdate OR effective_end_date IS NULL))
                  AND fg.parameter1 = to_char(hzp.party_id)
                   AND fg.instance_set_id = fois.instance_set_id
                   AND fois.instance_set_name = 'FUN_TRX_BATCHES_SET'
                   AND hzr.relationship_code = 'CONTACT_OF'
                   AND hzr.relationship_type = 'CONTACT'
                   AND hzr.directional_flag = 'F'
                   AND hzr.subject_table_name = 'HZ_PARTIES'
                   AND hzr.object_table_name = 'HZ_PARTIES'
                   AND hzr.subject_type = 'PERSON'
                   AND hzr.object_id = hzp.party_id
                   AND fg.grantee_key = l_grantee_key
                   AND hzp.party_name = fib.initiator_name
                   AND hc.party_relationship_id = hzr.relationship_id
                   AND hcr.org_contact_id = hc.org_contact_id
                   AND hcr.role_type = 'INTERCOMPANY_CONTACT_FOR'
                   AND hzr.subject_id = l_user_id
                   AND hzr.status = 'A'))
                   LOOP
    l_batch_count := l_batch_count + 1;
    Print('Main Package ~~~'||'Populating Batch Record');

    SELECT numbering_type
    INTO l_numbering_type
    FROM fun_system_options;

    IF l_numbering_type = 'SYS' then
/*      SELECT FUN_SEQ_S1.nextval
      INTO l_batch_num
      FROM dual;
*/
      l_control_date_tbl := fun_seq.control_date_tbl_type();
      l_control_date_tbl.extend(1);
      l_control_date_tbl(1).date_type  := 'CREATION_DATE';
      l_control_date_tbl(1).date_value := sysdate;

      FUN_SEQ.Get_Sequence_Number(
            p_context_type          => 'INTERCOMPANY_BATCH_SOURCE',
            p_context_value         => 'LOCAL',
            p_application_id        => 435,
            p_table_name            => 'FUN_TRX_BATCHES',
            p_event_code            => 'CREATION',
            p_control_attribute_rec => NULL,
            p_control_date_tbl      => l_control_date_tbl,
            p_suppress_error        => 'N',
            x_seq_version_id        => l_seq_version_id,
            x_sequence_number       => l_batch_num,
            x_assignment_id         => l_assignment_id,
            x_error_code            => l_error_code);
    ELSE
      l_batch_num := curr_batch.batch_number;
    END IF;

	l_batch_rec.batch_id 		:= curr_batch.batch_id;
	l_batch_rec.batch_number 	:= l_batch_num;
	l_batch_rec.initiator_id     	:= curr_batch.initiator_id;
	l_batch_rec.from_le_id		:= curr_batch.from_le_id;
	l_batch_rec.from_ledger_id	:= curr_batch.from_ledger_id;
	l_batch_rec.control_total	:= curr_batch.control_total;
	l_batch_rec.currency_code	:= NVL(curr_batch.currency_code, l_default_currency);
	l_batch_rec.exchange_rate_type	:= NVL(curr_batch.exchange_rate_type, l_exchg_rate_type);
	l_batch_rec.status		    := 'NEW';
	l_batch_rec.description		:= curr_batch.description;
	l_batch_rec.trx_type_id		:= curr_batch.trx_type_id;
	l_batch_rec.trx_type_code	:= curr_batch.trx_type_code;
	l_batch_rec.gl_date		    := trunc(curr_batch.gl_date);
	l_batch_rec.batch_date		:= curr_batch.batch_date;
	l_batch_rec.reject_allow_flag	:= l_reject_allow_flag;
	l_batch_rec.from_recurring_batch_id := curr_batch.from_recurring_batch_id;

        l_batch_rec.attribute1          := curr_batch.attribute1;
        l_batch_rec.attribute2          := curr_batch.attribute2;
        l_batch_rec.attribute3          := curr_batch.attribute3;
        l_batch_rec.attribute4          := curr_batch.attribute4;
        l_batch_rec.attribute5          := curr_batch.attribute5;
        l_batch_rec.attribute6          := curr_batch.attribute6;
        l_batch_rec.attribute7          := curr_batch.attribute7;
        l_batch_rec.attribute8          := curr_batch.attribute8;
        l_batch_rec.attribute9          := curr_batch.attribute9;
        l_batch_rec.attribute10          := curr_batch.attribute10;
        l_batch_rec.attribute11          := curr_batch.attribute11;
        l_batch_rec.attribute12          := curr_batch.attribute12;
        l_batch_rec.attribute13          := curr_batch.attribute13;
        l_batch_rec.attribute14          := curr_batch.attribute14;
        l_batch_rec.attribute15          := curr_batch.attribute15;
        l_batch_rec.attribute_category   := curr_batch.attribute_category;
        l_batch_rec.note                 := curr_batch.note;


      --calculate running total for batch from headers
      SELECT nvl(sum(init_amount_dr),0), nvl(sum(init_amount_cr),0)
      INTO l_running_total_dr, l_running_total_cr
      FROM fun_interface_headers
      WHERE batch_id = curr_batch.batch_id;

      l_batch_rec.running_total_dr := l_running_total_dr;
      l_batch_rec.running_total_cr := l_running_total_cr;

    Print('Main Package ~~~'||'Details of batch');
    Print('-----------------------------------------------------');
    Print('           Batch_id'||l_batch_rec.batch_id );
    Print('           Batch Number'||l_batch_rec.batch_number);
    Print('           Initiator Id'||l_batch_rec.initiator_id);
    Print('           From Le Id'||l_batch_rec.from_le_id);
    Print('           Control Total'||l_batch_rec.control_total);

    Print('Main Package ~~~'||' Derive Base Attributes for a Batch ');
    -- Derive Base Attributes for a Batch

    Derive_Batch_Attributes(
	    x_return_status 	=> l_return_status,
    	p_initiator_id 	  	=> l_batch_rec.initiator_id,
    	p_initiator_name	=> curr_batch.initiator_name,
	    p_from_ledger_id	=> l_batch_rec.from_ledger_id,
    	p_from_le_id 		=> l_batch_rec.from_le_id,
	    p_from_le_name 		=> curr_batch.from_le_name,
        p_trx_type_id 		=> l_batch_rec.trx_type_id,
    	p_trx_type_name 	=> curr_batch.trx_type_name,
	    p_trx_type_code 	=> l_batch_rec.trx_type_code
    	);
    Print('Main Package ~~~'||' Update the missing Attributes for a Batch in interface tables');
      Update fun_interface_batches
      set initiator_id=l_batch_rec.initiator_id,
          from_le_id=l_batch_rec.from_le_id,
          from_ledger_id=l_batch_rec.from_ledger_id,
          trx_type_id=l_batch_rec.trx_type_id,
          trx_type_code=l_batch_rec.trx_type_code
      where batch_id=curr_batch.batch_id;

    --Derive Invoicing Rule
    Print('Main Package ~~~'||' Derive Invoicing Flag ');
    open c_inv_flag(l_batch_rec.trx_type_id);
    fetch c_inv_flag into  l_invoice_flag;
    IF c_inv_flag%NOTFOUND THEN
        close c_inv_flag;

        Print('Main Package ~~~'||' Trx type ID'||l_batch_rec.trx_type_id);
        l_return_status:=FND_API.G_RET_STS_ERROR;
    END IF;

    Print('Main Package ~~~'||' Value'||l_invoice_flag||'Return Staus '|| l_return_status);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  RAISE FND_API.G_EXC_ERROR;
    ELSE
      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    End if;
    CLOSE c_inv_flag;


    l_count := 1;
    l_count_lines := 1;
    Print('Main Package ~~~'||' Populate Trx Header Records into l_trx_tbl ');
    -- Populate l_trx_tbl, l_init_dist_tbl, l_dist_lines_tbl;

    OPEN c_head(curr_batch.batch_id);
    LOOP
      FETCH C_HEAD INTO CURR_HEAD;
	  EXIT WHEN C_HEAD%NOTFOUND;
        l_trx_tbl(l_count).trx_id                   := curr_head.trx_id;
        l_trx_tbl(l_count).trx_number               := curr_head.trx_number;
        l_trx_tbl(l_count).recipient_id             := curr_head.recipient_id;
        l_trx_tbl(l_count).to_le_id                 := curr_head.to_le_id;
        l_trx_tbl(l_count).to_ledger_id             := curr_head.to_ledger_id;
        l_trx_tbl(l_count).batch_id                 := curr_head.batch_id;
        l_trx_tbl(l_count).status	                := 'NEW';
        l_trx_tbl(l_count).init_amount_cr           := curr_head.init_amount_cr;
        l_trx_tbl(l_count).init_amount_dr           := curr_head.init_amount_dr;
        l_trx_tbl(l_count).invoice_flag     	    := l_invoice_flag;
        l_trx_tbl(l_count).from_recurring_trx_id    := curr_head.from_recurring_trx_id;
        l_trx_tbl(l_count).initiator_instance_flag   	:= curr_head.initiator_instance_flag;
        l_trx_tbl(l_count).recipient_instance_flag	    := curr_head.recipient_instance_flag;
        l_trx_tbl(l_count).reci_amount_cr           := curr_head.init_amount_dr;
        l_trx_tbl(l_count).reci_amount_dr           := curr_head.init_amount_cr;

        l_trx_tbl(l_count).attribute1 := curr_head.attribute1;
        l_trx_tbl(l_count).attribute2 := curr_head.attribute2;
        l_trx_tbl(l_count).attribute3 := curr_head.attribute3;
        l_trx_tbl(l_count).attribute4 := curr_head.attribute4;
        l_trx_tbl(l_count).attribute5 := curr_head.attribute5;
        l_trx_tbl(l_count).attribute6 := curr_head.attribute6;
        l_trx_tbl(l_count).attribute7 := curr_head.attribute7;
        l_trx_tbl(l_count).attribute8 := curr_head.attribute8;
        l_trx_tbl(l_count).attribute9 := curr_head.attribute9;
        l_trx_tbl(l_count).attribute10 := curr_head.attribute10;
        l_trx_tbl(l_count).attribute11 := curr_head.attribute11;
        l_trx_tbl(l_count).attribute12 := curr_head.attribute12;
        l_trx_tbl(l_count).attribute13 := curr_head.attribute13;
        l_trx_tbl(l_count).attribute14 := curr_head.attribute14;
        l_trx_tbl(l_count).attribute15 := curr_head.attribute15;
        l_trx_tbl(l_count).attribute_category := curr_head.attribute_category;
        l_trx_tbl(l_count).description := curr_head.description;
        l_trx_tbl(l_count).initiator_id := l_batch_rec.initiator_id;



     	-- Derive Base Attributes for a Transaction Header
     	Print('Main Package ~~~'||'Derive Base Attributes for a Transaction Header ');

     	Derive_Transaction_Attributes(
		x_return_status 	=> l_return_status,
		p_recipient_id 	  	=> l_trx_tbl(l_count).recipient_id,
		p_recipient_name	=> curr_head.recipient_name,
		p_to_ledger_id		=> l_trx_tbl(l_count).to_ledger_id,
		p_to_le_id 	    	=> l_trx_tbl(l_count).to_le_id,
		p_to_le_name 		=> curr_head.to_le_name
		);

	Update fun_trx_headers
	set recipient_id=l_trx_tbl(l_count).recipient_id,
	    to_ledger_id=l_trx_tbl(l_count).to_ledger_id,
	    to_le_id=l_trx_tbl(l_count).to_le_id
	    where trx_id=curr_head.trx_id;

      Print('Main Package ~~~'|| 'Return Status from  Transaction Attributes'||l_return_status);

	  IF l_return_status = FND_API.G_RET_STS_ERROR THEN
	  	RAISE FND_API.G_EXC_ERROR;
      ELSE
	 	IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
			RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	  End if;
      Print('Main Package ~~~'||' Populating Dist Lines into l_dist_lines_tbl ');

      OPEN c_dist_lines(curr_head.trx_id);
      LOOP
	FETCH C_DIST_LINES INTO curr_dist_line;
	EXIT WHEN C_DIST_LINES%NOTFOUND;
			l_dist_lines_tbl(l_count_lines).trx_id    	 := curr_dist_line.trx_id;
			l_dist_lines_tbl(l_count_lines).dist_id    	 := curr_dist_line.dist_id;
	       		l_dist_lines_tbl(l_count_lines).party_id    	 := curr_dist_line.party_id;
			l_dist_lines_tbl(l_count_lines).party_type_flag 	 :=curr_dist_line.party_type_flag;
       			l_dist_lines_tbl(l_count_lines).dist_type_flag 	 :=curr_dist_line.dist_type_flag;
			l_dist_lines_tbl(l_count_lines).batch_dist_id	 := curr_dist_line.batch_dist_id;
			l_dist_lines_tbl(l_count_lines).amount_cr 	 := curr_dist_line.amount_cr;
			l_dist_lines_tbl(l_count_lines).amount_dr 	 := curr_dist_line.amount_dr;
			l_dist_lines_tbl(l_count_lines).ccid      	 := curr_dist_line.ccid;

			l_dist_lines_tbl(l_count_lines).description      :=curr_dist_line.description;
 			l_dist_lines_tbl(l_count_lines).attribute1       :=curr_dist_line.attribute1;
 			l_dist_lines_tbl(l_count_lines).attribute2       :=curr_dist_line.attribute2;
 			l_dist_lines_tbl(l_count_lines).attribute3       :=curr_dist_line.attribute3;
 			l_dist_lines_tbl(l_count_lines).attribute4       :=curr_dist_line.attribute4;
 			l_dist_lines_tbl(l_count_lines).attribute5       :=curr_dist_line.attribute5;
 			l_dist_lines_tbl(l_count_lines).attribute6       :=curr_dist_line.attribute6;
 			l_dist_lines_tbl(l_count_lines).attribute7       :=curr_dist_line.attribute7;
 			l_dist_lines_tbl(l_count_lines).attribute8       :=curr_dist_line.attribute8;
 			l_dist_lines_tbl(l_count_lines).attribute9       :=curr_dist_line.attribute9;
 			l_dist_lines_tbl(l_count_lines).attribute10       :=curr_dist_line.attribute10;
 			l_dist_lines_tbl(l_count_lines).attribute11       :=curr_dist_line.attribute11;
 			l_dist_lines_tbl(l_count_lines).attribute12       :=curr_dist_line.attribute12;
 			l_dist_lines_tbl(l_count_lines).attribute13       :=curr_dist_line.attribute13;
 			l_dist_lines_tbl(l_count_lines).attribute14       :=curr_dist_line.attribute14;
 			l_dist_lines_tbl(l_count_lines).attribute15       :=curr_dist_line.attribute15;
 			l_dist_lines_tbl(l_count_lines).attribute_category       :=curr_dist_line.attribute_category;

     		l_count_lines := l_count_lines  + 1;
    	END LOOP; -- DIST_LINES CURSOR

	    CLOSE C_DIST_LINES;
    	l_count := l_count+1;

      END LOOP; -- TRX HEADERS CURSOR
    CLOSE C_HEAD;

    Print('Main Package ~~~'||' Populating  Batch Dist into l_init_dist_tbl');
    /* Populating l_init_dist_tbl */

    l_count_lines := 1;

      OPEN c_batch_dist(curr_batch.batch_id);
      LOOP
      	FETCH C_BATCH_DIST INTO CURR_BATCH_DIST;
	    EXIT WHEN C_BATCH_DIST %NOTFOUND;
            l_init_dist_tbl(l_count_lines).batch_dist_id	:= curr_batch_dist.batch_dist_id;
            l_init_dist_tbl(l_count_lines).line_number	    := curr_batch_dist.line_number;
      		l_init_dist_tbl(l_count_lines).batch_id         := curr_batch_dist.batch_id;
       		l_init_dist_tbl(l_count_lines).ccid             := curr_batch_dist.ccid;
       		l_init_dist_tbl(l_count_lines).amount_cr 	    := curr_batch_dist.amount_cr;
       		l_init_dist_tbl(l_count_lines).amount_dr	    := curr_batch_dist.amount_dr;


                l_init_dist_tbl(l_count_lines).attribute1           :=curr_batch_dist.attribute1;
                l_init_dist_tbl(l_count_lines).attribute2           :=curr_batch_dist.attribute2;
                l_init_dist_tbl(l_count_lines).attribute3           :=curr_batch_dist.attribute3;
                l_init_dist_tbl(l_count_lines).attribute4           :=curr_batch_dist.attribute4;
                l_init_dist_tbl(l_count_lines).attribute5           :=curr_batch_dist.attribute5;
                l_init_dist_tbl(l_count_lines).attribute6           :=curr_batch_dist.attribute6;
                l_init_dist_tbl(l_count_lines).attribute7           :=curr_batch_dist.attribute7;
                l_init_dist_tbl(l_count_lines).attribute8           :=curr_batch_dist.attribute8;
                l_init_dist_tbl(l_count_lines).attribute9           :=curr_batch_dist.attribute9;
                l_init_dist_tbl(l_count_lines).attribute10           :=curr_batch_dist.attribute10;
                l_init_dist_tbl(l_count_lines).attribute11           :=curr_batch_dist.attribute11;
                l_init_dist_tbl(l_count_lines).attribute12           :=curr_batch_dist.attribute12;
                l_init_dist_tbl(l_count_lines).attribute13           :=curr_batch_dist.attribute13;
                l_init_dist_tbl(l_count_lines).attribute14           :=curr_batch_dist.attribute14;
                l_init_dist_tbl(l_count_lines).attribute15           :=curr_batch_dist.attribute15;

                l_init_dist_tbl(l_count_lines).attribute_category           :=curr_batch_dist.attribute_category;


            l_count_lines := l_count_lines+1;

       END LOOP; -- BATCH DIST CURSOR
      CLOSE C_BATCH_DIST;
      Print('Main Package ~~~'||' Call the Public API to Validate and Insert Intercompany Transactions');
      ----Call the Public API to Validate and Insert Transactions (Batches,Headers,Lines and Distributions).

      FUN_TRX_PUB.CREATE_BATCH(
    	p_api_version 	 	=> 1.0,
	    p_init_msg_list 	=> FND_API.G_TRUE,
    	p_validation_level 	=> l_validation_level,
    	x_return_status 	=> l_return_status,
	    x_msg_count    		=> l_msg_count,
    	x_msg_data      	=> l_msg_data,
    	p_sent			=> nvl(p_import_transaction_as_sent,'N'),
    	p_calling_sequence	=> 'Intercompany Import Program',
    	p_insert		=> FND_API.G_TRUE,
    	p_batch_rec		=> l_batch_rec,
    	p_trx_tbl		=> l_trx_tbl,
    	p_init_dist_tbl		=> l_init_dist_tbl,
	    p_dist_lines_tbl	=> l_dist_lines_tbl,
        p_debug             =>p_debug
	  );
      Print('Main Package ~~~'||'Validation and Insertion Complete with Status' || l_return_status);
      /* If l_return_status is Unexpected - Raise Unexpected Error*/

      IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      Print('Main Package ~~~ Raise batch.send Business Event');
      /* 	Raise a Business Event (Send)	*/

      If l_return_status = FND_API.G_RET_STS_SUCCESS then
          Overall_Status := 'A';
          commit work;
      else
          Overall_Status := 'R';
      end if; ---- Overall Status is Accepted

      /*Set Import_status_code of Batch with Overall Status; */
      UPDATE fun_interface_batches set import_status_code = Overall_Status
       Where batch_id = curr_batch.batch_id;

      l_trx_tbl.delete;
      l_init_dist_tbl.delete;
      l_dist_lines_tbl.delete;
    END LOOP; -- BATCHES CURSOR



    IF l_batch_count = 0 then
      raise BATCH_NOT_FOUND;
    END If;

    /* Call the Report with the parameters - Source, Group, p_rejected_only */
    Print('Main Package ~~~'||'Invoking the Import Execution Report');
	v_request_id := FND_REQUEST.SUBMIT_REQUEST('FUN',
                                         'FUNIMPER',
                                         '',
                                         '',
                                         FALSE,
					 p_group_id,
					 nvl(p_rejected_only,'Y'),
					 p_source
					 );

   /*update control table with the request id */

   update fun_interface_controls
   set request_id = v_request_id,
       date_processed = sysdate
   where source = p_source
   and group_id = p_group_id;


  p_errbuff  := NULL;
  p_retcode := 0;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
	IF c_head%ISOPEN Then
	    Close c_head;
        END IF;
	IF c_dist_lines%ISOPEN Then
	    Close c_dist_lines;
	END IF;

	IF c_batch_dist %ISOPEN Then
	    Close c_batch_dist;
	END IF;
	p_errbuff  := 'FND_API.G_EXC_ERROR';
	p_retcode := 2;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

  IF c_head%ISOPEN Then
	    Close c_head;
        END IF;

	IF c_dist_lines%ISOPEN Then
	    Close c_dist_lines;
	END IF;

	IF c_batch_dist %ISOPEN Then
	    Close c_batch_dist;
	END IF;

	p_errbuff  := 'FND_API.G_EXC_UNEXPECTED_ERROR';
	p_retcode := 2;

  WHEN BATCH_NOT_FOUND THEN

	p_errbuff := 'ERROR: Combination of Source and Group ID not found in Interface Table or user does not have acess to initiator for any batch in the group.';
	p_retcode := 2;

  WHEN OTHERS THEN

	IF c_head%ISOPEN Then
	    Close c_head;
        END IF;
	IF c_dist_lines%ISOPEN Then
	    Close c_dist_lines;
	END IF;

	IF c_batch_dist%ISOPEN Then
	    Close c_batch_dist;
	END IF;

	p_errbuff  :=SQLERRM;
	p_retcode := 2;

END; --- Main Procedure


---Procedure to Purge Accepted Records from the Interface Tables

PROCEDURE Purge_Interface_Table
        (
               p_source               IN      VARCHAR2,
               p_group_id	      IN     VARCHAR2
        ) IS

l_count number;

BEGIN

  Delete from fun_interface_dist_lines where
		Trx_id in (select trx_id from fun_interface_headers where
		batch_id in (select batch_id from fun_interface_batches where
		source = p_source and group_id = p_group_id and import_status_code = 'A')) ;

  Delete from fun_interface_batchdists where
		batch_id in (select batch_id from fun_interface_batches where
		source = p_source and group_id = p_group_id and import_status_code = 'A');

  Delete from fun_interface_headers where
		Batch_id in (select batch_id from fun_interface_batches where
		source  = p_source and group_id = p_group_id and import_status_code = 'A');

  Delete from fun_interface_batches where
		source  = p_source and group_id = p_group_id
		and import_status_code = 'A';

-- Bug: 7595873
  select count(*) into l_count
  from fun_interface_rejections ftr
  where ftr.batch_id in(select ftb.batch_id
			from fun_interface_batches ftb
			where ftb.source = p_source
			and ftb.group_id = p_group_id);

  if l_count = 0 then
	Delete from fun_interface_controls where source = p_source
			and group_id = p_group_id;
  end if;

EXCEPTION

WHEN OTHERS THEN
    APP_EXCEPTION.RAISE_EXCEPTION;
END Purge_Interface_Table;


    PROCEDURE purge_interface_tables(p_batch_id IN NUMBER) IS

    BEGIN
-- porcedure called to purge the rejected Data only.
      DELETE FROM fun_interface_dist_lines
      WHERE trx_id IN
        (SELECT trx_id
         FROM fun_interface_headers
         WHERE batch_id = p_batch_id)
      ;

      DELETE FROM fun_interface_batchdists
      WHERE batch_id = p_batch_id;

      DELETE FROM fun_interface_headers
      WHERE batch_id = p_batch_id;

      DELETE FROM fun_interface_batches
      WHERE batch_id = p_batch_id
       AND import_status_code = 'R';

      DELETE FROM fun_interface_rejections
      where batch_id=p_batch_id;

    EXCEPTION

    WHEN others THEN
      app_exception.raise_exception;

    END purge_interface_tables;

    PROCEDURE clob_to_file(p_xml_clob IN CLOB) IS

    l_clob_size NUMBER;
    l_offset NUMBER;
    l_chunk_size INTEGER;
    l_chunk VARCHAR2(32767);
    l_log_module VARCHAR2(240);

    BEGIN
-- Procedure to write teh xml data from clob to file.
      l_clob_size := dbms_lob.getlength(p_xml_clob);

      IF(l_clob_size = 0) THEN
        RETURN;
      END IF;

      l_offset := 1;
      l_chunk_size := 3000;

      WHILE(l_clob_size > 0)
      LOOP
        l_chunk := dbms_lob.SUBSTR(p_xml_clob,   l_chunk_size,   l_offset);
        fnd_file.put(which => fnd_file.OUTPUT,   buff => l_chunk);

        l_clob_size := l_clob_size -l_chunk_size;
        l_offset := l_offset + l_chunk_size;
      END LOOP;

      fnd_file.new_line(fnd_file.OUTPUT,   1);

    EXCEPTION
    WHEN others THEN
      app_exception.raise_exception;

    END clob_to_file;

    PROCEDURE put_starttag(tag_name IN VARCHAR2) IS
    BEGIN
-- putting the start tag for the xml data
      fnd_file.PUT_LINE(fnd_file.OUTPUT,   '<' || tag_name || '>');
      --fnd_file.new_line(fnd_file.output,1);

      EXCEPTION

      WHEN others THEN
        app_exception.raise_exception;

      END;

      PROCEDURE put_endtag(tag_name IN VARCHAR2) IS
      BEGIN
-- putting the end tag for the xml data
        fnd_file.PUT_LINE(fnd_file.OUTPUT,   '</' || tag_name || '>');
        --fnd_file.new_line(fnd_file.output,1);

        EXCEPTION

        WHEN others THEN
          app_exception.raise_exception;

        END;

        PROCEDURE put_element(tag_name IN VARCHAR2,   VALUE IN VARCHAR2) IS
        BEGIN
-- putting the start tag +element+end tag for the xml data
          fnd_file.put(fnd_file.OUTPUT,   '<' || tag_name || '>');
          fnd_file.put(fnd_file.OUTPUT,   '<![CDATA[');
          fnd_file.put(fnd_file.OUTPUT,   VALUE);
          fnd_file.put(fnd_file.OUTPUT,   ']]>');
          fnd_file.PUT_LINE(fnd_file.OUTPUT,   '</' || tag_name || '>');

        EXCEPTION

        WHEN others THEN
          app_exception.raise_exception;

        END;

        PROCEDURE import_data_purge(errbuf OUT nocopy VARCHAR2,   retcode OUT nocopy NUMBER,   p_source IN VARCHAR2,   p_group_id IN NUMBER DEFAULT NULL,   p_review_required IN VARCHAR2) IS

        l_qryctx dbms_xmlgen.ctxhandle;
        l_result_clob CLOB;
        l_current_calling_sequence VARCHAR2(2000);
        l_debug_info VARCHAR2(200);

        l_report_name VARCHAR2(80) := 'Intercompany Import Data Purge Report';
        l_curr_batch_count NUMBER;
        l_batch_count NUMBER;
        l_total_batch_count NUMBER;
        l_trx_count NUMBER;
        l_temp_batch_count NUMBER;
        l_temp_trx_count NUMBER;
        l_encoding VARCHAR2(20);
        l_grantee_key VARCHAR2(80);
        l_user_id NUMBER;

        BEGIN
--This procedure selects the batches for purging and calls the purge api.
          l_current_calling_sequence := 'FUN_OPEN_INTERFACE_PKG.import_data_purge';
          l_debug_info := 'Group id info..';

          l_total_batch_count := 0;
-- xml encoding data fetch
          SELECT tag
          INTO l_encoding
          FROM fnd_lookup_values
          WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
           AND lookup_code =
            (SELECT VALUE
             FROM v$nls_parameters
             WHERE parameter = 'NLS_CHARACTERSET')
          AND LANGUAGE = 'US';
          --setting the bind variables
          SELECT hzp.party_id
          INTO l_user_id
          FROM hz_parties hzp,
            fnd_user u,
            per_all_people_f pap,
              (SELECT fnd_global.user_id() AS
            user_id
             FROM dual)
          curr
          WHERE curr.user_id = u.user_id
           AND u.employee_id = pap.person_id
           AND pap.party_id = hzp.party_id;
          l_grantee_key := 'HZ_PARTY:' || to_char(l_user_id);

          --xml header tags
          put_starttag('?xml version="1.0" encoding="' || l_encoding || '"?');
          put_starttag('PURGE_REJECTED_INTERCOMPANY_TRANSACTIONS_REPORT');
          put_starttag('PROGRAM_PARAMETERS');
          put_element('BATCH_SOURCE',   p_source);
          put_element('GROUP_ID',   p_group_id);
          put_element('REVIEW_FLAG',   p_review_required);
          put_endtag('PROGRAM_PARAMETERS');

          l_debug_info := 'Select Group ids and Batches...';

          put_starttag('GROUP_ID_SET');

          --grouping by group_id
          FOR rec IN
            (SELECT DISTINCT group_id
             FROM fun_interface_batches
             WHERE source = p_source
             AND(decode(p_group_id,    NULL,    1,    group_id)) =(decode(p_group_id,    NULL,    1,    p_group_id))
             AND import_status_code = 'R')
          LOOP
            l_batch_count := 0;
            put_starttag('GROUP_ID_RECORD');

            put_element('GROUP_ID',   rec.group_id);

            --grouping by the currency_code
            FOR rec2 IN
              (SELECT DISTINCT currency_code
               FROM fun_interface_batches
               WHERE group_id = rec.group_id
               AND import_status_code = 'R')
            LOOP
              put_starttag('CURRENCY_CODE_RECORD');
              l_curr_batch_count := 0;
              put_element('CURRENCY_CODE',   rec2.currency_code);

              --grouping by the Legal Entity Name
              FOR rec3 IN
                (SELECT DISTINCT from_le_name
                 FROM fun_interface_batches
                 WHERE group_id = rec.group_id
                 AND currency_code = rec2.currency_code
                 AND import_status_code = 'R')
              LOOP
                put_starttag('FROM_LE_NAME_RECORD');

                put_element('FROM_LE_NAME',   rec3.from_le_name);
                put_element('GROUP_ID',   rec.group_id);

                --Batch Record generation
                l_qryctx := dbms_xmlgen.newcontext('SELECT FIB.GROUP_ID GROUP_ID,
       FIB.CURRENCY_CODE CURRENCY_CODE,
       FIB.FROM_LE_NAME FROM_LE_NAME,
       FIB.FROM_LE_ID FROM_LE_ID,
       FIB.INITIATOR_NAME INITIATOR_NAME,
       FIB.INITIATOR_ID INITIATOR_ID,
       FIB.BATCH_NUMBER BATCH_NUMBER,
       FIB.BATCH_DATE BATCH_DATE,
       FIH.RECIPIENT_NAME RECIPIENT_NAME,
       DECODE(FIH.INIT_AMOUNT_CR,NULL,0,FIH.INIT_AMOUNT_CR) INIT_AMOUNT_CR,
       DECODE(FIH.INIT_AMOUNT_DR,NULL,0,FIH.INIT_AMOUNT_DR) INIT_AMOUNT_DR
     FROM FUN_INTERFACE_BATCHES FIB,
     FUN_INTERFACE_HEADERS FIH,
     HZ_PARTIES HZP,
     FND_GRANTS FG,
     FND_OBJECT_INSTANCE_SETS FOIS,
     HZ_RELATIONSHIPS HZR,
     HZ_ORG_CONTACTS HC,
     HZ_ORG_CONTACT_ROLES HCR
     WHERE FIB.BATCH_ID=FIH.BATCH_ID
       AND FIB.GROUP_ID=:GROUP_ID
       AND FIB.IMPORT_STATUS_CODE=''R''
       AND FIB.CURRENCY_CODE=:CURRENCY_CODE
       AND FIB.FROM_LE_NAME=:FROM_LE_NAME
       AND HZP.PARTY_TYPE = ''ORGANIZATION''
  AND EXISTS
  (SELECT 1
   FROM HZ_PARTY_USG_ASSIGNMENTS HUA
   WHERE HUA.PARTY_ID = HZP.PARTY_ID
   AND HUA.PARTY_USAGE_CODE = ''INTERCOMPANY_ORG''
   AND HUA.EFFECTIVE_START_DATE <= SYSDATE
   AND(HUA.EFFECTIVE_END_DATE >= SYSDATE OR EFFECTIVE_END_DATE IS NULL))
AND FG.PARAMETER1 = TO_CHAR(HZP.PARTY_ID)
 AND FG.INSTANCE_SET_ID = FOIS.INSTANCE_SET_ID
 AND FOIS.INSTANCE_SET_NAME = ''FUN_TRX_BATCHES_SET''
 AND FG.GRANTEE_KEY = :GRANTEE_KEY
 AND HZR.RELATIONSHIP_CODE = ''CONTACT_OF''
 AND HZR.RELATIONSHIP_TYPE = ''CONTACT''
 AND HZR.DIRECTIONAL_FLAG = ''F''
 AND HZR.SUBJECT_TABLE_NAME = ''HZ_PARTIES''
 AND HZR.OBJECT_TABLE_NAME = ''HZ_PARTIES''
 AND HZR.SUBJECT_TYPE = ''PERSON''
AND  HZR.OBJECT_ID=HZP.PARTY_ID
AND HZP.PARTY_NAME = FIB.INITIATOR_NAME
 AND HC.PARTY_RELATIONSHIP_ID = HZR.RELATIONSHIP_ID
 AND HCR.ORG_CONTACT_ID = HC.ORG_CONTACT_ID
 AND HCR.ROLE_TYPE = ''INTERCOMPANY_CONTACT_FOR''
 AND HZR.SUBJECT_ID = :SUBJECT_ID
 AND HZR.STATUS = ''A''');

                dbms_xmlgen.setrowsettag(l_qryctx,   'BATCH_SET');
                dbms_xmlgen.setrowtag(l_qryctx,   'BATCH_RECORD');
                dbms_xmlgen.setbindvalue(l_qryctx,   'GROUP_ID',   rec.group_id);
                dbms_xmlgen.setbindvalue(l_qryctx,   'CURRENCY_CODE',   rec2.currency_code);
                dbms_xmlgen.setbindvalue(l_qryctx,   'FROM_LE_NAME',   rec3.from_le_name);
                dbms_xmlgen.setbindvalue(l_qryctx,   'GRANTEE_KEY',   l_grantee_key);
                dbms_xmlgen.setbindvalue(l_qryctx,   'SUBJECT_ID',   l_user_id);
                l_result_clob := dbms_xmlgen.getxml(l_qryctx);
                l_result_clob := SUBSTR(l_result_clob,   instr(l_result_clob,   '>') + 1);
                dbms_xmlgen.closecontext(l_qryctx);
                clob_to_file(l_result_clob);
                l_temp_batch_count := 0;

                --selecting teh batches to be purged.
                FOR rec4 IN
                  (SELECT DISTINCT fib.batch_id
                   FROM fun_interface_batches fib,
                     hz_parties hzp,
                     fnd_grants fg,
                     fnd_object_instance_sets fois,
                     hz_relationships hzr,
                     hz_org_contacts hc,
                     hz_org_contact_roles hcr
                   WHERE fib.group_id = rec.group_id
                   AND fib.import_status_code = 'R'
                   AND fib.currency_code = rec2.currency_code
                   AND fib.from_le_name = rec3.from_le_name
                   AND hzp.party_type = 'ORGANIZATION'
                   AND EXISTS
                    (SELECT 1
                     FROM hz_party_usg_assignments hua
                     WHERE hua.party_id = hzp.party_id
                     AND hua.party_usage_code = 'INTERCOMPANY_ORG'
                     AND hua.effective_start_date <= sysdate
                     AND(hua.effective_end_date >= sysdate OR effective_end_date IS NULL))
                  AND fg.parameter1 = to_char(hzp.party_id)
                   AND fg.instance_set_id = fois.instance_set_id
                   AND fois.instance_set_name = 'FUN_TRX_BATCHES_SET'
                   AND fg.grantee_key = l_grantee_key
                   AND hzr.relationship_code = 'CONTACT_OF'
                   AND hzr.relationship_type = 'CONTACT'
                   AND hzr.directional_flag = 'F'
                   AND hzr.subject_table_name = 'HZ_PARTIES'
                   AND hzr.object_table_name = 'HZ_PARTIES'
                   AND hzr.subject_type = 'PERSON'
                   AND hzr.object_id = hzp.party_id
                   AND hzp.party_name = fib.initiator_name
                   AND hc.party_relationship_id = hzr.relationship_id
                   AND hcr.org_contact_id = hc.org_contact_id
                   AND hcr.role_type = 'INTERCOMPANY_CONTACT_FOR'
                   AND hzr.subject_id = l_user_id
                   AND hzr.status = 'A')
                LOOP
                  l_temp_batch_count := l_temp_batch_count + 1;

                  IF(p_review_required = 'N') THEN
                    purge_interface_tables(rec4.batch_id);
                  END IF;

                END LOOP;

                l_curr_batch_count := l_curr_batch_count + l_temp_batch_count;
                put_element('LE_BATCH_COUNT',   l_temp_batch_count);
                put_endtag('FROM_LE_NAME_RECORD');

              END LOOP;

              put_element('CURR_BATCH_COUNT',   l_curr_batch_count);
              put_endtag('CURRENCY_CODE_RECORD');
              l_batch_count := l_batch_count + l_curr_batch_count;
            END LOOP;

            put_element('GROUP_BATCH_COUNT',   l_batch_count);
            put_endtag('GROUP_ID_RECORD');
            l_total_batch_count := l_total_batch_count + l_batch_count;

            IF (l_batch_count > 0) and(p_review_required='N') THEN

              DELETE FROM fun_interface_controls
              WHERE source = p_source
               AND group_id = rec.group_id;
            END IF;

          END LOOP;

          put_element('TOTAL_BATCH_COUNT',   l_total_batch_count);
          put_endtag('GROUP_ID_SET');

          put_endtag('PURGE_REJECTED_INTERCOMPANY_TRANSACTIONS_REPORT');

        EXCEPTION

        WHEN others THEN
          fun_util.log_conc_unexp(l_current_calling_sequence,   sqlerrm);
          app_exception.raise_exception;

        END import_data_purge;

END FUN_OPEN_INTERFACE_PKG;

/
