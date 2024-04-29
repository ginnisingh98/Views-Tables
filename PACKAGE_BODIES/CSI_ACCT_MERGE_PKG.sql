--------------------------------------------------------
--  DDL for Package Body CSI_ACCT_MERGE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSI_ACCT_MERGE_PKG" AS
/* $Header: csiatmgb.pls 120.4.12010000.2 2009/08/05 13:00:21 jgootyag ship $ */
PROCEDURE write_to_cr_log ( p_message IN VARCHAR2);

PROCEDURE MERGE( req_id       	IN NUMBER,
                 set_num      	IN NUMBER,
                 process_mode 	IN VARCHAR2) IS

   error_str		VARCHAR2(3);
   no_of_rows      	NUMBER;
BEGIN

   arp_message.set_line('CSI_ACCT_MERGE_PKG.MERGE()+');
/*
   error_str	:= '001';
   write_to_cr_log( ' Processing Item Instances Merge ' );
   CSI_ITEM_INSTANCES_MERGE(req_id, set_num, process_mode);
   write_to_cr_log( ' Ending process for Item Instances All ' );

   error_str	:= '002';
   write_to_cr_log( ' Processing Systems All Merge ' );
   CSI_SYSTEMS_B_MERGE(req_id, set_num, process_mode);
   write_to_cr_log( ' Ending process for Systems All ' );

   error_str	:= '003';
   write_to_cr_log( ' Processing IP Accounts Merge ' );
   CSI_IP_ACCOUNTS_MERGE(req_id, set_num, process_mode);
   write_to_cr_log( ' Ending process for IP Accounts Merge ' );

   error_str	:= '004';
   write_to_cr_log( ' Processing Party Accounts Merge ' );
   CSI_T_PARTY_ACCOUNTS_MERGE(req_id, set_num, process_mode);
   write_to_cr_log( ' Ending process for Party Accounts ' );

   error_str	:= '005';
   write_to_cr_log( ' Processing CSI Transaction Systems Merge ' );
   CSI_T_TXN_SYSTEMS_MERGE(req_id, set_num, process_mode);
   write_to_cr_log( ' Ending process for CSI Transaction Systems Merge ' );
*/

   arp_message.set_line('CSI_ACCT_MERGE_PKG.MERGE()-');

EXCEPTION
   WHEN OTHERS THEN
      arp_message.set_line( 'CSI_ACCT_MERGE_PKG.MERGE()-');
      RAISE;
END MERGE;

PROCEDURE csi_item_instances_merge( req_id   		IN NUMBER,
                                    set_num   		IN NUMBER,
                                    process_mode 	IN VARCHAR2 ) IS
BEGIN
   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_ITEM_INSTANCES_MERGE()+');
   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_ITEM_INSTANCES_MERGE()-');
EXCEPTION
   WHEN OTHERS THEN
      arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_ITEM_INSTANCES_MERGE()');
      RAISE;
END CSI_ITEM_INSTANCES_MERGE;

PROCEDURE csi_ip_accounts_merge( req_id   	IN NUMBER,
                                 set_num   	IN NUMBER,
                                 process_mode 	IN VARCHAR2 ) IS

   error_str				     VARCHAR2(3);
   no_of_rows            		NUMBER;
   v_transaction_type_id 		NUMBER;
   v_transaction_id      		NUMBER;
   v_transaction_exists			VARCHAR2(1)	:= 'N';
   v_instance_party_history_id  	NUMBER;
   v_ip_account_history_id		NUMBER;
   v_party_source_table 		     VARCHAR2(30) 	:= 'HZ_PARTIES';
   v_source_transaction_type 		VARCHAR2(30) 	:= 'ACCT_MERGE';
   l_profile_val 			     VARCHAR2(30);
   l_count 				     NUMBER;
   l_last_fetch 			     BOOLEAN 	     := FALSE;
   l_veto_reason                   VARCHAR2(255)  := 'During Account Merge, old Account Id exists in Installed Base History tables. This table stores the history of all the accounts for an item instance and hence cannot be deleted.';
   TYPE FLAG_LIST IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
   vetoed_list		FLAG_LIST;

   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
        RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;

   MERGE_HEADER_ID_LIST 	MERGE_HEADER_ID_LIST_TYPE;

 TYPE CUSTOMER_SITE_ID_LIST_TYPE IS TABLE OF
        RA_CUSTOMER_MERGES.CUSTOMER_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   INSTALL_CUSTOMER_SITE_ID_LIST 	CUSTOMER_SITE_ID_LIST_TYPE;

   TYPE IP_ACCOUNT_ID_LIST_TYPE IS TABLE OF
        CSI_IP_ACCOUNTS.IP_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

   PRIMARY_KEY_ID_LIST 		IP_ACCOUNT_ID_LIST_TYPE;

   TYPE PARTY_ACCT_ID_LIST_TYPE IS TABLE OF
        CSI_IP_ACCOUNTS.PARTY_ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL1_ORIG_LIST 		PARTY_ACCT_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST 		PARTY_ACCT_ID_LIST_TYPE;

   TYPE INSTANCE_PARTY_ID_LIST_TYPE IS TABLE OF
        CSI_I_PARTIES.INSTANCE_PARTY_ID%TYPE
        INDEX BY BINARY_INTEGER;

   INSTANCE_PARTY_ID_LIST 	INSTANCE_PARTY_ID_LIST_TYPE;

   TYPE INSTANCE_ID_LIST_TYPE IS TABLE OF
        CSI_ITEM_INSTANCES.INSTANCE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   INSTANCE_ID_LIST             INSTANCE_ID_LIST_TYPE;

   TYPE BILL_TO_ADDRESS_LIST_TYPE IS TABLE OF
        CSI_IP_ACCOUNTS.BILL_TO_ADDRESS%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL2_ORIG_LIST 		BILL_TO_ADDRESS_LIST_TYPE;
   NUM_COL2_NEW_LIST 		BILL_TO_ADDRESS_LIST_TYPE;

   TYPE SHIP_TO_ADDRESS_LIST_TYPE IS TABLE OF
        CSI_IP_ACCOUNTS.SHIP_TO_ADDRESS%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL3_ORIG_LIST 		SHIP_TO_ADDRESS_LIST_TYPE;
   NUM_COL3_NEW_LIST 		SHIP_TO_ADDRESS_LIST_TYPE;

   TYPE LOCATION_ID_LIST_TYPE IS TABLE OF
        CSI_ITEM_INSTANCES.LOCATION_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL4_ORIG_LIST 		LOCATION_ID_LIST_TYPE;
   NUM_COL4_NEW_LIST 		LOCATION_ID_LIST_TYPE;


   TYPE INSTALL_LOCATION_ID_LIST_TYPE IS TABLE OF
        CSI_ITEM_INSTANCES.INSTALL_LOCATION_ID%TYPE
        INDEX BY BINARY_INTEGER;


   NUM_COL5_ORIG_LIST 		INSTALL_LOCATION_ID_LIST_TYPE;
   NUM_COL5_NEW_LIST 		INSTALL_LOCATION_ID_LIST_TYPE;

   TYPE CUST_ACCT_SITE_ID_LIST_TYPE IS TABLE OF
        HZ_CUST_ACCT_SITES_ALL .CUST_ACCT_SITE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL6_ORIG_LIST 		CUST_ACCT_SITE_ID_LIST_TYPE;
   NUM_COL6_NEW_LIST 		CUST_ACCT_SITE_ID_LIST_TYPE;


   CURSOR merged_records IS
   SELECT DISTINCT
          m.CUSTOMER_MERGE_HEADER_ID ,
	     yt.IP_ACCOUNT_ID        ,
	     yt.PARTY_ACCOUNT_ID     ,
	     yt.BILL_TO_ADDRESS      ,
	     yt.SHIP_TO_ADDRESS      ,
          cip.INSTANCE_PARTY_ID      ,
          cip.INSTANCE_ID
   FROM   CSI_IP_ACCOUNTS    yt,
          CSI_I_PARTIES      cip,
          CSI_ITEM_INSTANCES cii,
	     RA_CUSTOMER_MERGES m
   WHERE  ( yt.PARTY_ACCOUNT_ID	= m.DUPLICATE_ID 	OR
	       yt.BILL_TO_ADDRESS 	= m.DUPLICATE_SITE_ID 	OR
	       yt.SHIP_TO_ADDRESS 	= m.DUPLICATE_SITE_ID )
   AND    yt.instance_party_id 	= cip.instance_party_id
   AND    ( yt.active_end_date     is null OR
            yt.active_end_date     > sysdate )
   AND    cip.instance_id          = cii.instance_id
   AND    ( cii.active_end_date    is null OR
            cii.active_end_date    > sysdate )
-- TODO : the next line needs to be uncommented
   AND    m.process_flag 	= 'N'
   AND    m.request_id 		= req_id
   AND    m.set_number 		= set_num;

   l_return_status              varchar2(1) := fnd_api.g_ret_sts_success;
   l_msg_count                  NUMBER;
   l_msg_data                   VARCHAR2(2000);

   -- Variables for 'GET ITEM INSTANCE DETAILS' API call

   l_g_instance_rec             csi_datastructures_pub.instance_header_rec;
   l_g_ph_tbl                   csi_datastructures_pub.party_header_tbl;
   l_g_pah_tbl                  csi_datastructures_pub.party_account_header_tbl;
   l_g_ouh_tbl                  csi_datastructures_pub.org_units_header_tbl;
   l_g_pa_tbl                   csi_datastructures_pub.pricing_attribs_tbl;
   l_g_eav_tbl                  csi_datastructures_pub.extend_attrib_values_tbl;
   l_g_ea_tbl                   csi_datastructures_pub.extend_attrib_tbl;
   l_g_iah_tbl                  csi_datastructures_pub.instance_asset_header_tbl;
   l_g_time_stamp               date;

   -- Variables for 'UPDATE ITEM INSTANCE' API call

   p_u_instance_rec		       csi_datastructures_pub.instance_rec;
   p_u_ext_attrib_values_tbl    csi_datastructures_pub.extend_attrib_values_tbl;
   p_u_party_tbl                csi_datastructures_pub.party_tbl;
   p_u_party_account_tbl        csi_datastructures_pub.party_account_tbl;
   p_u_pricing_attrib_tbl       csi_datastructures_pub.pricing_attribs_tbl;
   p_u_org_assignments_tbl      csi_datastructures_pub.organization_units_tbl;
   p_u_asset_assignment_tbl     csi_datastructures_pub.instance_asset_tbl;
   p_txn_rec                    csi_datastructures_pub.transaction_rec;
   x_instance_id_lst            csi_datastructures_pub.id_tbl;

   -- local
   l_merge_excep                EXCEPTION;
   l_install_location_type_code   VARCHAR2(30);
   l_location_type_code           VARCHAR2(30);
   l_install_customer_site_id     NUMBER;
   l_party_site_id                NUMBER;
   l_party_id                     NUMBER;
   l_party_account_id		  NUMBER;
   l_bill_to_address		  NUMBER;
   l_ship_to_address		  NUMBER;
   l_acct_idx			  NUMBER;
   l_pty_idx			  NUMBER;
   l_to_party_id		  NUMBER;
   l_num_of_acct_records 	  NUMBER;
   l_acct_rec_index      	  NUMBER;
   l_owner_update 		  VARCHAR2(1);
   l_address_only_upd 		  VARCHAR2(1);
   l_instance_party_id          NUMBER;
   l_old_acct                   NUMBER;
   l_pty_with_diff_accts        VARCHAR2(1);
   I				            NUMBER;
   J				            NUMBER;
   K				            NUMBER;
   l_msg_ctr                    NUMBER;
   l_msg_dummy                  NUMBER;
   l_msg_string			  VARCHAR2(256);
   l_prof_reltype_code		  VARCHAR2(30);
   l_from_customer_id		  NUMBER;
   l_is_vetoed				  VARCHAR2(1);

BEGIN  -- {1

   error_str 	:= '001';
   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_IP_ACCOUNTS_MERGE()+');

   IF (process_mode = 'LOCK') THEN -- {2

      error_str 	:= '002';
      write_to_cr_log( 'Locking the csi_ip_accounts table' );

      arp_message.set_name('AR','AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME','CSI_IP_ACCOUNTS',FALSE);

      OPEN  merged_records;
      CLOSE merged_records;

      write_to_cr_log( 'Done Locking the csi_ip_accounts table' );

   ELSE  -- }  2 {

      l_msg_string := 'CSI:Processing';
      write_to_cr_log( l_msg_string );

      error_str 	:= '003';
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSI_IP_ACCOUNTS',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);

      error_str 	:= '004';
      l_profile_val        :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');
      l_prof_reltype_code  :=  FND_PROFILE.VALUE('CSI_PARTY_ACCT_MERGE');
      IF l_prof_reltype_code IS NULL THEN
         l_prof_reltype_code := 'SHIP_TO';
      END IF;

	 -- Initialize vetoed_list
	 vetoed_list.delete;

      -- Process merge records
      OPEN merged_records;
      LOOP -- { 3

         l_msg_string := 'CSI:merged_records cursor...';
         write_to_cr_log( l_msg_string );
         -- Fetch all the eligible merge records
         FETCH merged_records BULK COLLECT INTO
               MERGE_HEADER_ID_LIST 	,
               PRIMARY_KEY_ID_LIST  	,
               NUM_COL1_ORIG_LIST 	,
               NUM_COL2_ORIG_LIST 	,
               NUM_COL3_ORIG_LIST 	,
               INSTANCE_PARTY_ID_LIST 	,
               INSTANCE_ID_LIST
	    LIMIT 1000;

         IF merged_records%NOTFOUND THEN -- { 4
            l_last_fetch := TRUE;
         END IF; -- } 4

         IF MERGE_HEADER_ID_LIST.COUNT = 0 AND l_last_fetch THEN -- { 5
            EXIT;
         END IF; -- } 5

         -- Get the corresponding 'merge to' ids
         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP -- { 6

                     write_to_cr_log( to_char(i) || ' orig1 orig2 orig3 : '||
                          to_char(NUM_COL1_ORIG_LIST(I)) || '<>' ||
                          to_char(NUM_COL2_ORIG_LIST(I)) || '<>' ||
                          to_char(NUM_COL3_ORIG_LIST(I)) );

            NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
            NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
            NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
			INSTALL_CUSTOMER_SITE_ID_LIST(I):= NULL;
			NUM_COL4_ORIG_LIST(I):= NULL;
            NUM_COL4_NEW_LIST(I):= NULL;
            NUM_COL5_ORIG_LIST(I):= NULL;
            NUM_COL5_NEW_LIST(I):= NULL;
            NUM_COL6_ORIG_LIST(I):= NULL;
            NUM_COL6_NEW_LIST(I):= NULL;

           BEGIN

	    SELECT CUSTOMER_SITE_ID INTO l_install_customer_site_id
            FROM RA_CUSTOMER_MERGES
            WHERE CUSTOMER_MERGE_HEADER_ID=MERGE_HEADER_ID_LIST(I)
             AND  CUSTOMER_SITE_CODE='INSTALL_AT' ;

	     EXCEPTION
	        WHEN NO_DATA_FOUND THEN
		  l_install_customer_site_id:= null;

             END;

	 IF l_install_customer_site_id IS NOT NULL THEN

	    INSTALL_CUSTOMER_SITE_ID_LIST(I):= HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(l_install_customer_site_id);
	 --END IF;



     --Added for Bug 6978155(FP for bug 6839035)

	    SELECT INSTALL_LOCATION_TYPE_CODE,INSTALL_LOCATION_ID,LOCATION_TYPE_CODE,LOCATION_ID
	    INTO l_install_location_type_code,NUM_COL5_ORIG_LIST(I),l_location_type_code,NUM_COL4_ORIG_LIST(I)
	    FROM CSI_ITEM_INSTANCES WHERE INSTANCE_ID=INSTANCE_ID_LIST(I);

      IF NUM_COL5_ORIG_LIST(I) IS NOT NULL THEN

	    IF l_install_location_type_code = 'HZ_PARTY_SITES' THEN


		    SELECT CUST_ACCT_SITE_ID
		    INTO NUM_COL6_NEW_LIST(I) FROM hz_cust_site_uses_all
		    WHERE SITE_USE_ID=  INSTALL_CUSTOMER_SITE_ID_LIST(I);

		    SELECT PARTY_SITE_ID INTO NUM_COL5_NEW_LIST(I)
		    FROM HZ_CUST_ACCT_SITES_ALL
		    WHERE CUST_ACCT_SITE_ID= NUM_COL6_NEW_LIST(I);

		    IF l_location_type_code = 'HZ_PARTY_SITES' THEN

                        NUM_COL4_NEW_LIST(I):= NUM_COL5_NEW_LIST(I);

		    ELSIF l_location_type_code = 'HZ_LOCATIONS' THEN

                        SELECT LOCATION_ID INTO  NUM_COL4_NEW_LIST(I)
		        FROM HZ_PARTY_SITES
		        WHERE PARTY_SITE_ID = NUM_COL5_NEW_LIST(I);

                    END IF;

	     ELSIF l_install_location_type_code = 'HZ_LOCATIONS' THEN

	           SELECT CUST_ACCT_SITE_ID
		    INTO NUM_COL6_NEW_LIST(I) FROM hz_cust_site_uses_all
		    WHERE SITE_USE_ID=  INSTALL_CUSTOMER_SITE_ID_LIST(I);

		    SELECT PARTY_SITE_ID INTO l_party_site_id
		    FROM HZ_CUST_ACCT_SITES_ALL
		    WHERE CUST_ACCT_SITE_ID= NUM_COL6_NEW_LIST(I);

		    IF l_location_type_code = 'HZ_PARTY_SITES' THEN

                NUM_COL4_NEW_LIST(I):= l_party_site_id;

			    SELECT LOCATION_ID INTO NUM_COL5_NEW_LIST(I)
			    FROM HZ_PARTY_SITES
			    WHERE PARTY_SITE_ID = l_party_site_id;

		    ELSIF l_location_type_code = 'HZ_LOCATIONS' THEN

       		    SELECT LOCATION_ID,LOCATION_ID
		        INTO  NUM_COL5_NEW_LIST(I), NUM_COL4_NEW_LIST(I)
		        FROM HZ_PARTY_SITES
	            WHERE PARTY_SITE_ID = l_party_site_id;

	        END IF;

         END IF;
       END IF;

     END IF;


                     write_to_cr_log( to_char(i) || '.new1  new2  new3  : '||
                           to_char(NUM_COL1_NEW_LIST(I)) || '<>' ||
                           to_char(NUM_COL2_NEW_LIST(I)) || '<>' ||
                           to_char(NUM_COL3_NEW_LIST(I)) );

         END LOOP; -- } 6




         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN -- { 7
            error_str 	:= '005';

            -- Log the data into TCA 'customer merge log'
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            INSERT INTO HZ_CUSTOMER_MERGE_LOG
            (
               MERGE_LOG_ID ,
               TABLE_NAME ,
               MERGE_HEADER_ID ,
               PRIMARY_KEY_ID ,
               NUM_COL1_ORIG ,
               NUM_COL1_NEW ,
               NUM_COL2_ORIG ,
               NUM_COL2_NEW ,
               NUM_COL3_ORIG ,
               NUM_COL3_NEW ,
               ACTION_FLAG ,
               REQUEST_ID ,
               CREATED_BY ,
               CREATION_DATE ,
               LAST_UPDATE_LOGIN ,
               LAST_UPDATE_DATE ,
               LAST_UPDATED_BY
            )
            VALUES
            (
               HZ_CUSTOMER_MERGE_LOG_s.nextval ,
               'CSI_IP_ACCOUNTS' ,
               MERGE_HEADER_ID_LIST(I) ,
               PRIMARY_KEY_ID_LIST(I) ,
               NUM_COL1_ORIG_LIST(I) ,
               NUM_COL1_NEW_LIST(I) ,
               NUM_COL2_ORIG_LIST(I ),
               NUM_COL2_NEW_LIST(I) ,
               NUM_COL3_ORIG_LIST(I) ,
               NUM_COL3_NEW_LIST(I) ,
               'U' ,
               req_id ,
               hz_utility_pub.CREATED_BY ,
               hz_utility_pub.CREATION_DATE ,
               hz_utility_pub.LAST_UPDATE_LOGIN ,
               hz_utility_pub.LAST_UPDATE_DATE ,
               hz_utility_pub.LAST_UPDATED_BY
            );
         END IF; -- } 7

         -- build the transaction record, if this is the first time
         IF nvl(p_txn_rec.transaction_id, fnd_api.g_miss_num) = fnd_api.g_miss_num Then -- { 8
            --
            -- Check if there is a transaction record created by any other csi routine
            -- If so use that id otherwise initialize the txn_rec attributes
            --
            BEGIN
              SELECT transaction_id
              INTO   v_transaction_id
              FROM   csi_transactions
              WHERE  source_line_ref_id = req_id
              AND    source_line_ref    = set_num;

              p_txn_rec.transaction_id := v_transaction_id;

            EXCEPTION
              WHEN no_data_found THEN

                error_str 	:= '006';
                SELECT transaction_type_id
                INTO   v_transaction_type_id
                FROM   csi_txn_types
                WHERE  source_transaction_type = v_source_transaction_type;

                error_str 	:= '007';
                p_txn_rec.transaction_date         := sysdate;
                p_txn_rec.source_transaction_date  := sysdate;
                p_txn_rec.transaction_type_id      := v_transaction_type_id;
                p_txn_rec.source_line_ref_id       := req_id;
                p_txn_rec.source_line_ref          := set_num;
            END;

         END IF; -- } 8

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP -- {

            l_msg_string := 'CSI:------->processing next record from the cursor...';
            write_to_cr_log( l_msg_string );
            -- Get the account_id from csi_ip_accounts
            error_str 	:= '008';
            SELECT party_account_id, bill_to_address, ship_to_address
            INTO   l_party_account_id, l_bill_to_address, l_ship_to_address
            FROM   csi_ip_accounts
            WHERE  ip_account_id = PRIMARY_KEY_ID_LIST(I);

            l_msg_string := 'CSI : primary_key_id_list(i), l_party_account_Id , l_bill_to_address, l_ship_to_address :'
                                      || to_char(primary_key_id_list(i))  || '<>'
                                      || to_char(l_party_account_id)      || '<>'
                                      || to_char(l_bill_to_address)       || '<>'
                                      || to_char(l_ship_to_address)  ;
            write_to_cr_log( l_msg_string );

            l_msg_string := 'CSI :                  num_col1_new_list(i), new_col2_new_list(i), num_col3_new_list(i) :      '
                                      || to_char(NUM_COL1_NEW_LIST(i))     || '<>'
                                      || to_char(NUM_COL2_NEW_LIST(i))     || '<>'
                                      || to_char(NUM_COL3_NEW_LIST(i)) ;
            write_to_cr_log( l_msg_string );

            IF ( l_party_account_id <> NUM_COL1_NEW_LIST(I) OR
                 l_bill_to_address  <> NUM_COL2_NEW_LIST(I) OR
                 l_ship_to_address  <> NUM_COL3_NEW_LIST(I) ) THEN -- {

	       -- Initialize the tables
               p_u_ext_attrib_values_tbl.delete;
               p_u_party_tbl.delete;
               p_u_party_account_tbl.delete;
               p_u_pricing_attrib_tbl.delete;
               p_u_org_assignments_tbl.delete;
               p_u_asset_assignment_tbl.delete;

               error_str 	:= '009';
               l_g_instance_rec.instance_id := INSTANCE_ID_LIST(I);
               l_msg_string := 'Before get call for instance ' || to_char(l_g_instance_rec.instance_id);
               write_to_cr_log( l_msg_string );

               csi_item_instance_pub.get_item_instance_details(
                     p_api_version           => 1.0,
                     p_commit                => fnd_api.g_false,
                     p_init_msg_list         => fnd_api.g_true,
                     p_validation_level      => fnd_api.g_valid_level_full,
                     p_instance_rec          => l_g_instance_rec,
                     p_get_parties           => fnd_api.g_true,
                     p_party_header_tbl      => l_g_ph_tbl,
                     p_get_accounts          => fnd_api.g_true,
                     p_account_header_tbl    => l_g_pah_tbl,
                     p_get_org_assignments   => fnd_api.g_false,
                     p_org_header_tbl        => l_g_ouh_tbl,
                     p_get_pricing_attribs   => fnd_api.g_false,
                     p_pricing_attrib_tbl    => l_g_pa_tbl,
                     p_get_ext_attribs       => fnd_api.g_false,
                     p_ext_attrib_tbl        => l_g_eav_tbl,
                     p_ext_attrib_def_tbl    => l_g_ea_tbl,
                     p_get_asset_assignments => fnd_api.g_false,
                     p_asset_header_tbl      => l_g_iah_tbl,
                     p_time_stamp            => l_g_time_stamp,
                     x_return_status         => l_return_status,
                     x_msg_count             => l_msg_count,
                     x_msg_data              => l_msg_data);

               l_msg_string := 'Return status from get : '|| l_return_status;
               write_to_cr_log( l_msg_string );

               IF ( l_return_status <> 'S' ) Then
                  write_to_cr_log( 'Msg Count : '||to_char(l_msg_count));
                  FOR l_msg_ctr in 1..l_msg_count  LOOP
                     fnd_msg_pub.get ( l_msg_ctr, FND_API.G_FALSE, l_msg_data, l_msg_dummy );
                     write_to_cr_log( 'Msg : '|| to_char(l_msg_ctr) || ' ' || l_msg_data );
                  END LOOP;
               END IF;

               l_msg_string := 'CSI: Party and Account Records for Inst. : '        ||
                               to_char( l_g_ph_tbl.count  )                || ' : ' ||
                               to_char( l_g_pah_tbl.count ) ;
               write_to_cr_log( l_msg_string );

               -- Get the to_party_id
               error_str 	:= '010';
               SELECT party_id
               INTO   l_to_party_id
               FROM   hz_cust_accounts
               WHERE  cust_account_id = NUM_COL1_NEW_LIST(I);

               -- process the instance party account records
               error_str 	:= '011';

               l_pty_idx  := 0;
               l_acct_idx := 0;

               FOR J in 1..l_g_ph_tbl.count LOOP   -- { party table loop
                  l_instance_party_id 	:= l_g_ph_tbl(J).instance_party_id;

                  IF l_g_ph_tbl(J).party_source_table = 'HZ_PARTIES' THEN -- { party_source is HZ_PARTIES

                     -- Get the number of account records
                     error_str                    := '012';
                     l_num_of_acct_records        := 0;
                     l_acct_rec_index             := 0;
                     l_owner_update               := 'N';
                     l_address_only_upd           := 'N';
                     l_old_acct                   := NULL;
                     l_pty_with_diff_accts        := 'N';

                     error_str                    := '013';
                     FOR K in 1..l_g_pah_tbl.count LOOP -- { K Loop to parse the account records

                        IF ( l_g_pah_tbl(K).instance_party_id = l_instance_party_id AND
                             l_g_pah_tbl(K).active_end_date   IS NULL ) THEN  -- { accounts for the same party
                           l_num_of_acct_records := l_num_of_acct_records + 1;
                           l_acct_rec_index      := K;
/*
                           IF l_g_pah_tbl(K).active_end_date IS NULL THEN

                              IF l_old_acct IS NULL THEN
                                 l_old_acct     := l_g_pah_tbl(K).party_account_id;
                              ELSE
                                 IF l_pty_with_diff_accts = 'N' AND
                                    l_old_acct <> l_g_pah_tbl(K).party_account_id THEN
                                    l_pty_with_diff_accts := 'Y';
                                    l_msg_string := 'CSI: pty with diff accts : '||
                                                          to_char( l_old_acct )  || ' : ' ||
                                                          to_char( l_g_pah_tbl(K).party_account_id ) ;
                                    write_to_cr_log( l_msg_string );
                                 END IF;
                              END IF;

                           END IF;
*/

                           IF ( NUM_COL1_ORIG_LIST(I)                 <> NUM_COL1_NEW_LIST(I) AND
                                l_g_pah_tbl(K).party_account_id       = NUM_COL1_ORIG_LIST(I) AND
                                l_g_pah_tbl(K).relationship_type_code = 'OWNER' ) THEN

                              l_owner_update := 'Y';

                           ELSIF ( ( l_g_pah_tbl(K).bill_to_address = NUM_COL2_ORIG_LIST(I) AND
                                     NUM_COL2_ORIG_LIST(I)          <> NUM_COL2_NEW_LIST(I) ) OR
                                   ( l_g_pah_tbl(K).ship_to_address = NUM_COL3_ORIG_LIST(I) AND
                                     NUM_COL3_ORIG_LIST(I)          <> NUM_COL3_NEW_LIST(I) ) ) THEN

                              l_address_only_upd := 'Y';

                           END IF;

                        END IF; -- } accounts for the same party

                     END LOOP; -- } K Loop to parse the account records

                     l_msg_string :=
                     'CSI: inst_party_id, no_of_acct, acct_rec_idx, pty_with_diff_Acct, l_add_upd, l_owner_upd ' ||
                                  to_char(l_instance_party_id)                                || ' : '||
                                  to_char(l_num_of_acct_records)                              || ' : '||
                                  to_char(l_acct_rec_index)                                   || ' : '||
                                  l_pty_with_diff_accts                                       || ' : '||
                                  l_address_only_upd                                          || ' : '||
                                  l_owner_update  ;
                     write_to_cr_log( l_msg_string );

                     error_str                    := '014';
                     IF l_address_only_upd = 'Y' THEN -- { if address_only_upd is true
                           -- Same Party record
                           -- move the account record to update table with changed values
                           error_str                    := '015';
                           l_pty_idx := l_pty_idx + 1;
                           p_u_party_tbl(l_pty_idx).instance_party_id      := l_g_ph_tbl(J).instance_party_id;
                           p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                           p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                           p_u_party_tbl(l_pty_idx).party_id               := l_g_ph_tbl(J).party_id;
                           p_u_party_tbl(l_pty_idx).relationship_type_code := l_g_ph_tbl(J).relationship_type_code;
                           p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                           p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                           p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                           p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                           p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                           p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                           p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                           p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                           p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                           p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                           p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                           p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                           p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                           p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                           p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                           p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                           p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                           p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                           p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                           p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                           p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                           p_u_party_tbl(l_pty_idx).primary_flag           := l_g_ph_tbl(J).primary_flag;
                           p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                           p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                           -- move the account record to update table
                           l_acct_idx := l_acct_idx + 1;
                           p_u_party_account_tbl(l_acct_idx).ip_account_id          := l_g_pah_tbl(l_acct_rec_index).ip_account_id;
                           p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx;
                           p_u_party_account_tbl(l_acct_idx).instance_party_id      := l_g_pah_tbl(l_acct_rec_index).instance_party_id;
                           IF l_g_pah_tbl(l_acct_rec_index).party_account_id = NUM_COL1_ORIG_LIST(I) THEN
                              p_u_party_account_tbl(l_acct_idx).party_account_id := NUM_COL1_NEW_LIST(I);
     			      p_u_party_tbl(l_pty_idx).party_id               := l_to_party_id;--fix for bug 4284460
                           ELSE
                              p_u_party_account_tbl(l_acct_idx).party_account_id := l_g_pah_tbl(l_acct_rec_index).party_account_id;
                           END IF;

                           IF l_g_pah_tbl(l_acct_rec_index).bill_to_address = NUM_COL2_ORIG_LIST(I) THEN
                              p_u_party_account_tbl(l_acct_idx).bill_to_address  := NUM_COL2_NEW_LIST(I);
                           ELSE
                              p_u_party_account_tbl(l_acct_idx).bill_to_address  := l_g_pah_tbl(l_acct_rec_index).bill_to_address;
                           END IF;

                           IF l_g_pah_tbl(l_acct_rec_index).ship_to_address = NUM_COL3_ORIG_LIST(I) THEN
                              p_u_party_account_tbl(l_acct_idx).ship_to_address  := NUM_COL3_NEW_LIST(I);
                           ELSE
                              p_u_party_account_tbl(l_acct_idx).ship_to_address  := l_g_pah_tbl(l_acct_rec_index).ship_to_address;
                           END IF;

                           p_u_party_account_tbl(l_acct_idx).relationship_type_code := l_g_pah_tbl(l_acct_rec_index).relationship_type_code;
                           p_u_party_account_tbl(l_acct_idx).active_start_date      := FND_API.G_MISS_DATE;
                           p_u_party_account_tbl(l_acct_idx).active_end_date        := FND_API.G_MISS_DATE;
                           p_u_party_account_tbl(l_acct_idx).context                := l_g_pah_tbl(l_acct_rec_index).context;
                           p_u_party_account_tbl(l_acct_idx).attribute1             := l_g_pah_tbl(l_acct_rec_index).attribute1;
                           p_u_party_account_tbl(l_acct_idx).attribute2             := l_g_pah_tbl(l_acct_rec_index).attribute2;
                           p_u_party_account_tbl(l_acct_idx).attribute3             := l_g_pah_tbl(l_acct_rec_index).attribute3;
                           p_u_party_account_tbl(l_acct_idx).attribute4             := l_g_pah_tbl(l_acct_rec_index).attribute4;
                           p_u_party_account_tbl(l_acct_idx).attribute5             := l_g_pah_tbl(l_acct_rec_index).attribute5;
                           p_u_party_account_tbl(l_acct_idx).attribute6             := l_g_pah_tbl(l_acct_rec_index).attribute6;
                           p_u_party_account_tbl(l_acct_idx).attribute7             := l_g_pah_tbl(l_acct_rec_index).attribute7;
                           p_u_party_account_tbl(l_acct_idx).attribute8             := l_g_pah_tbl(l_acct_rec_index).attribute8;
                           p_u_party_account_tbl(l_acct_idx).attribute9             := l_g_pah_tbl(l_acct_rec_index).attribute9;
                           p_u_party_account_tbl(l_acct_idx).attribute10            := l_g_pah_tbl(l_acct_rec_index).attribute10;
                           p_u_party_account_tbl(l_acct_idx).attribute11            := l_g_pah_tbl(l_acct_rec_index).attribute11;
                           p_u_party_account_tbl(l_acct_idx).attribute12            := l_g_pah_tbl(l_acct_rec_index).attribute12;
                           p_u_party_account_tbl(l_acct_idx).attribute13            := l_g_pah_tbl(l_acct_rec_index).attribute13;
                           p_u_party_account_tbl(l_acct_idx).attribute14            := l_g_pah_tbl(l_acct_rec_index).attribute14;
                           p_u_party_account_tbl(l_acct_idx).attribute15            := l_g_pah_tbl(l_acct_rec_index).attribute15;
                           p_u_party_account_tbl(l_acct_idx).object_version_number  := l_g_pah_tbl(l_acct_rec_index).object_version_number;
                           p_u_party_account_tbl(l_acct_idx).call_contracts         := FND_API.G_FALSE;
                     ELSE -- } address_only  { Otherwise
                     IF ( l_num_of_acct_records = 1 ) THEN    -- { if one record for the party
                        -- IF ( l_acct_rec_index > 0 ) THEN  --  if account index is known
                        IF ( l_acct_rec_index > 0 ) AND
                           ( l_g_pah_tbl(l_acct_rec_index).party_account_id = NUM_COL1_ORIG_LIST(I) )
                           THEN  -- { if account index is known and it needs to be modified then
                           -- move the party record to update table with l_to_party_id
                           -- move the account record to update table with changed values

                           -- move the party record to update table
                           error_str                    := '015';
                           l_pty_idx := l_pty_idx + 1;
                           p_u_party_tbl(l_pty_idx).instance_party_id      := l_g_ph_tbl(J).instance_party_id;
                           p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                           p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                           p_u_party_tbl(l_pty_idx).party_id               := l_g_ph_tbl(J).party_id; --Fix for Bug 4284460
                           p_u_party_tbl(l_pty_idx).relationship_type_code := l_g_ph_tbl(J).relationship_type_code;
                           p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                           p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                           p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                           p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                           p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                           p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                           p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                           p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                           p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                           p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                           p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                           p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                           p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                           p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                           p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                           p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                           p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                           p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                           p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                           p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                           p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                           p_u_party_tbl(l_pty_idx).primary_flag           := l_g_ph_tbl(J).primary_flag;
                           p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                           p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                           -- move the account record to update table
                           l_acct_idx := l_acct_idx + 1;
                           p_u_party_account_tbl(l_acct_idx).ip_account_id          := l_g_pah_tbl(l_acct_rec_index).ip_account_id;
                           p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx;
                           p_u_party_account_tbl(l_acct_idx).instance_party_id      := l_g_pah_tbl(l_acct_rec_index).instance_party_id;
                           IF l_g_pah_tbl(l_acct_rec_index).party_account_id = NUM_COL1_ORIG_LIST(I) THEN
                              p_u_party_account_tbl(l_acct_idx).party_account_id := NUM_COL1_NEW_LIST(I);
			      p_u_party_tbl(l_pty_idx).party_id			 := l_to_party_id; --Fix for Bug 4284460
                           ELSE
                              p_u_party_account_tbl(l_acct_idx).party_account_id := l_g_pah_tbl(l_acct_rec_index).party_account_id;
                           END IF;

                           IF l_g_pah_tbl(l_acct_rec_index).bill_to_address = NUM_COL2_ORIG_LIST(I) THEN
                              p_u_party_account_tbl(l_acct_idx).bill_to_address  := NUM_COL2_NEW_LIST(I);
                           ELSE
                              p_u_party_account_tbl(l_acct_idx).bill_to_address  := l_g_pah_tbl(l_acct_rec_index).bill_to_address;
                           END IF;

                           IF l_g_pah_tbl(l_acct_rec_index).ship_to_address = NUM_COL3_ORIG_LIST(I) THEN
                              p_u_party_account_tbl(l_acct_idx).ship_to_address  := NUM_COL3_NEW_LIST(I);
                           ELSE
                              p_u_party_account_tbl(l_acct_idx).ship_to_address  := l_g_pah_tbl(l_acct_rec_index).ship_to_address;
                           END IF;

                           p_u_party_account_tbl(l_acct_idx).relationship_type_code := l_g_pah_tbl(l_acct_rec_index).relationship_type_code;
                           p_u_party_account_tbl(l_acct_idx).active_start_date      := FND_API.G_MISS_DATE;
                           p_u_party_account_tbl(l_acct_idx).active_end_date        := FND_API.G_MISS_DATE;
                           p_u_party_account_tbl(l_acct_idx).context                := l_g_pah_tbl(l_acct_rec_index).context;
                           p_u_party_account_tbl(l_acct_idx).attribute1             := l_g_pah_tbl(l_acct_rec_index).attribute1;
                           p_u_party_account_tbl(l_acct_idx).attribute2             := l_g_pah_tbl(l_acct_rec_index).attribute2;
                           p_u_party_account_tbl(l_acct_idx).attribute3             := l_g_pah_tbl(l_acct_rec_index).attribute3;
                           p_u_party_account_tbl(l_acct_idx).attribute4             := l_g_pah_tbl(l_acct_rec_index).attribute4;
                           p_u_party_account_tbl(l_acct_idx).attribute5             := l_g_pah_tbl(l_acct_rec_index).attribute5;
                           p_u_party_account_tbl(l_acct_idx).attribute6             := l_g_pah_tbl(l_acct_rec_index).attribute6;
                           p_u_party_account_tbl(l_acct_idx).attribute7             := l_g_pah_tbl(l_acct_rec_index).attribute7;
                           p_u_party_account_tbl(l_acct_idx).attribute8             := l_g_pah_tbl(l_acct_rec_index).attribute8;
                           p_u_party_account_tbl(l_acct_idx).attribute9             := l_g_pah_tbl(l_acct_rec_index).attribute9;
                           p_u_party_account_tbl(l_acct_idx).attribute10            := l_g_pah_tbl(l_acct_rec_index).attribute10;
                           p_u_party_account_tbl(l_acct_idx).attribute11            := l_g_pah_tbl(l_acct_rec_index).attribute11;
                           p_u_party_account_tbl(l_acct_idx).attribute12            := l_g_pah_tbl(l_acct_rec_index).attribute12;
                           p_u_party_account_tbl(l_acct_idx).attribute13            := l_g_pah_tbl(l_acct_rec_index).attribute13;
                           p_u_party_account_tbl(l_acct_idx).attribute14            := l_g_pah_tbl(l_acct_rec_index).attribute14;
                           p_u_party_account_tbl(l_acct_idx).attribute15            := l_g_pah_tbl(l_acct_rec_index).attribute15;
                           p_u_party_account_tbl(l_acct_idx).object_version_number  := l_g_pah_tbl(l_acct_rec_index).object_version_number;
                           p_u_party_account_tbl(l_acct_idx).call_contracts         := FND_API.G_FALSE;

                        END IF;  -- } if account index is known and account needs to be modified
                     ELSIF  ( l_num_of_acct_records > 1 ) THEN -- } account records = 1 { account records for party > 1
                        IF l_owner_update = 'Y' THEN  -- { l_owner_update is 'Y'
                           IF l_pty_with_diff_accts = 'Y' THEN  -- { l_pty_with_diff_accts 1
                              -- move owner party record with the l_to_party_id
                              -- create a new party record with previous party_id
                              -- loop
                              --    if account is to be changed
                              --       set the instance_party_id from the l_g_ph record
                              --    else
                              --       set the instance_party_id to the newly created one
                              --    end if
                              --    move the account record
                              -- end loop

                              -- move the party record with l_to_party_id
                              error_str                    := '016';
                              l_pty_idx := l_pty_idx + 1;
                              p_u_party_tbl(l_pty_idx).instance_party_id      := l_g_ph_tbl(J).instance_party_id;
                              p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                              p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                              p_u_party_tbl(l_pty_idx).party_id               := l_to_party_id;
                              p_u_party_tbl(l_pty_idx).relationship_type_code := l_g_ph_tbl(J).relationship_type_code;
                              p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                              p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                              p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                              p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                              p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                              p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                              p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                              p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                              p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                              p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                              p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                              p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                              p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                              p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                              p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                              p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                              p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                              p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                              p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                              p_u_party_tbl(l_pty_idx).primary_flag           := l_g_ph_tbl(J).primary_flag;
                              p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                              p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                              --   create new party record with l_g_ph_tbl party_id
                              l_pty_idx := l_pty_idx + 1;
                              p_u_party_tbl(l_pty_idx).instance_party_id      := FND_API.G_MISS_NUM;
                              p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                              p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                              p_u_party_tbl(l_pty_idx).party_id               := l_g_ph_tbl(J).party_id;
                              p_u_party_tbl(l_pty_idx).relationship_type_code := l_prof_reltype_code;
                              p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                              p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                              p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                              p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                              p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                              p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                              p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                              p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                              p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                              p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                              p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                              p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                              p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                              p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                              p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                              p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                              p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                              p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                              p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                              p_u_party_tbl(l_pty_idx).primary_flag           := 'N';
                              p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                              p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                              FOR K in 1..l_g_pah_tbl.count LOOP -- { K Loop
                                 IF ( l_g_pah_tbl(K).instance_party_id = l_instance_party_id AND
                                      l_g_pah_tbl(K).active_end_date   IS NULL ) THEN  -- { accounts for the same party
                                    -- move the account record to update table
                                    l_acct_idx := l_acct_idx + 1;
                                    p_u_party_account_tbl(l_acct_idx).ip_account_id          := l_g_pah_tbl(K).ip_account_id;

                                    IF ( l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) OR
                                         l_g_pah_tbl(K).bill_to_address  = NUM_COL2_ORIG_LIST(I) OR
                                         l_g_pah_tbl(K).ship_to_address  = NUM_COL3_ORIG_LIST(I) ) THEN -- { if the record needs update
                                       p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx-1;
                                       p_u_party_account_tbl(l_acct_idx).instance_party_id      := l_g_pah_tbl(K).instance_party_id;
                                    ELSE -- } if record needs update { if record needs no update
                                       p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx;
                                       p_u_party_account_tbl(l_acct_idx).instance_party_id      := FND_API.G_MISS_NUM;
                                    END IF; -- } if the record needs no update

                                    IF l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := NUM_COL1_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := l_g_pah_tbl(K).party_account_id;
                                    END IF;

                                    IF l_g_pah_tbl(K).bill_to_address = NUM_COL2_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := NUM_COL2_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := l_g_pah_tbl(K).bill_to_address;
                                    END IF;

                                    IF l_g_pah_tbl(K).ship_to_address = NUM_COL3_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := NUM_COL3_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := l_g_pah_tbl(K).ship_to_address;
                                    END IF;

                                    p_u_party_account_tbl(l_acct_idx).relationship_type_code := l_g_pah_tbl(K).relationship_type_code;
                                    p_u_party_account_tbl(l_acct_idx).active_start_date      := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).active_end_date        := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).context                := l_g_pah_tbl(K).context;
                                    p_u_party_account_tbl(l_acct_idx).attribute1             := l_g_pah_tbl(K).attribute1;
                                    p_u_party_account_tbl(l_acct_idx).attribute2             := l_g_pah_tbl(K).attribute2;
                                    p_u_party_account_tbl(l_acct_idx).attribute3             := l_g_pah_tbl(K).attribute3;
                                    p_u_party_account_tbl(l_acct_idx).attribute4             := l_g_pah_tbl(K).attribute4;
                                    p_u_party_account_tbl(l_acct_idx).attribute5             := l_g_pah_tbl(K).attribute5;
                                    p_u_party_account_tbl(l_acct_idx).attribute6             := l_g_pah_tbl(K).attribute6;
                                    p_u_party_account_tbl(l_acct_idx).attribute7             := l_g_pah_tbl(K).attribute7;
                                    p_u_party_account_tbl(l_acct_idx).attribute8             := l_g_pah_tbl(K).attribute8;
                                    p_u_party_account_tbl(l_acct_idx).attribute9             := l_g_pah_tbl(K).attribute9;
                                    p_u_party_account_tbl(l_acct_idx).attribute10            := l_g_pah_tbl(K).attribute10;
                                    p_u_party_account_tbl(l_acct_idx).attribute11            := l_g_pah_tbl(K).attribute11;
                                    p_u_party_account_tbl(l_acct_idx).attribute12            := l_g_pah_tbl(K).attribute12;
                                    p_u_party_account_tbl(l_acct_idx).attribute13            := l_g_pah_tbl(K).attribute13;
                                    p_u_party_account_tbl(l_acct_idx).attribute14            := l_g_pah_tbl(K).attribute14;
                                    p_u_party_account_tbl(l_acct_idx).attribute15            := l_g_pah_tbl(K).attribute15;
                                    p_u_party_account_tbl(l_acct_idx).object_version_number  := l_g_pah_tbl(K).object_version_number;
                                    p_u_party_account_tbl(l_acct_idx).call_contracts         := FND_API.G_FALSE;
                                 END IF; -- } accounts for the same party
                              END LOOP;  -- } K Loop

                           ELSE  -- } l_pty_with_diff_accts = 'Y' 1 { l_pty_with_diff_accts = 'N' 1
                              -- move the party record to update table
                              error_str                    := '017';
                              l_pty_idx := l_pty_idx + 1;
                              p_u_party_tbl(l_pty_idx).instance_party_id      := l_g_ph_tbl(J).instance_party_id;
                              p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                              p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                              p_u_party_tbl(l_pty_idx).party_id               := l_g_ph_tbl(J).party_id; --Fix for Bug 4284460
                              p_u_party_tbl(l_pty_idx).relationship_type_code := l_g_ph_tbl(J).relationship_type_code;
                              p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                              p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                              p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                              p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                              p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                              p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                              p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                              p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                              p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                              p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                              p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                              p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                              p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                              p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                              p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                              p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                              p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                              p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                              p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                              p_u_party_tbl(l_pty_idx).primary_flag           := l_g_ph_tbl(J).primary_flag;
                              p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                              p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                              FOR K in 1..l_g_pah_tbl.count LOOP -- { K Loop
                                 IF ( l_g_pah_tbl(K).instance_party_id = l_instance_party_id AND
                                      l_g_pah_tbl(K).active_end_date   IS NULL  AND
				      --Fix for Bug 4284460
				      (l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) OR
				      l_g_pah_tbl(K).bill_to_address = NUM_COL2_ORIG_LIST(I) OR    -- { accounts for the same party
				      l_g_pah_tbl(K).ship_to_address = NUM_COL3_ORIG_LIST(I))) THEN  -- { accounts for the same party
                                    -- move the account record to update table
                                    l_acct_idx := l_acct_idx + 1;
                                    p_u_party_account_tbl(l_acct_idx).ip_account_id          := l_g_pah_tbl(K).ip_account_id;
                                    p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx;
                                    p_u_party_account_tbl(l_acct_idx).instance_party_id      := l_g_pah_tbl(K).instance_party_id;
                                    IF l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := NUM_COL1_NEW_LIST(I);
       	                               p_u_party_tbl(l_pty_idx).party_id                  := l_to_party_id; --Fix for Bug 4284460
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := l_g_pah_tbl(K).party_account_id;
                                    END IF;

                                    IF l_g_pah_tbl(K).bill_to_address = NUM_COL2_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := NUM_COL2_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := l_g_pah_tbl(K).bill_to_address;
                                    END IF;

                                    IF l_g_pah_tbl(K).ship_to_address = NUM_COL3_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := NUM_COL3_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := l_g_pah_tbl(K).ship_to_address;
                                    END IF;

                                    p_u_party_account_tbl(l_acct_idx).relationship_type_code := l_g_pah_tbl(K).relationship_type_code;
                                    p_u_party_account_tbl(l_acct_idx).active_start_date      := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).active_end_date        := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).context                := l_g_pah_tbl(K).context;
                                    p_u_party_account_tbl(l_acct_idx).attribute1             := l_g_pah_tbl(K).attribute1;
                                    p_u_party_account_tbl(l_acct_idx).attribute2             := l_g_pah_tbl(K).attribute2;
                                    p_u_party_account_tbl(l_acct_idx).attribute3             := l_g_pah_tbl(K).attribute3;
                                    p_u_party_account_tbl(l_acct_idx).attribute4             := l_g_pah_tbl(K).attribute4;
                                    p_u_party_account_tbl(l_acct_idx).attribute5             := l_g_pah_tbl(K).attribute5;
                                    p_u_party_account_tbl(l_acct_idx).attribute6             := l_g_pah_tbl(K).attribute6;
                                    p_u_party_account_tbl(l_acct_idx).attribute7             := l_g_pah_tbl(K).attribute7;
                                    p_u_party_account_tbl(l_acct_idx).attribute8             := l_g_pah_tbl(K).attribute8;
                                    p_u_party_account_tbl(l_acct_idx).attribute9             := l_g_pah_tbl(K).attribute9;
                                    p_u_party_account_tbl(l_acct_idx).attribute10            := l_g_pah_tbl(K).attribute10;
                                    p_u_party_account_tbl(l_acct_idx).attribute11            := l_g_pah_tbl(K).attribute11;
                                    p_u_party_account_tbl(l_acct_idx).attribute12            := l_g_pah_tbl(K).attribute12;
                                    p_u_party_account_tbl(l_acct_idx).attribute13            := l_g_pah_tbl(K).attribute13;
                                    p_u_party_account_tbl(l_acct_idx).attribute14            := l_g_pah_tbl(K).attribute14;
                                    p_u_party_account_tbl(l_acct_idx).attribute15            := l_g_pah_tbl(K).attribute15;
                                    p_u_party_account_tbl(l_acct_idx).object_version_number  := l_g_pah_tbl(K).object_version_number;
                                    p_u_party_account_tbl(l_acct_idx).call_contracts         := FND_API.G_FALSE;
                                 END IF; -- } accounts for the same party
                              END LOOP;  -- } K Loop
                           END IF;   -- } l_pty_with_diff_accts 1
                        ELSE  -- } l_owner_update = 'Y' {  l_owner_update = 'N'
                           --
                           -- if l_pty_with_diff_accts then
                           --   move pty record as is
                           --   create new party record with l_to_party
                           --   loop
                           --     if account is to be updated
                           --        use the new party record index
                           --     else
                           --        use the old party record index
                           --     end if
                           --     move acct record
                           --   end loop
                           -- else
                           --   move pty record with new l_to_party
                           --   loop
                           --      move acct records with updated account_ids
                           --   end loop
                           -- end if;
                           --
                           IF ( l_pty_with_diff_accts = 'Y' ) THEN -- { l_pty_with_diff_accts = 'Y'
                              --   move pty record as is
                              error_str                    := '018';
                              l_pty_idx := l_pty_idx + 1;
                              p_u_party_tbl(l_pty_idx).instance_party_id      := l_g_ph_tbl(J).instance_party_id;
                              p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                              p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                              p_u_party_tbl(l_pty_idx).party_id               := l_g_ph_tbl(J).party_id;
                              p_u_party_tbl(l_pty_idx).relationship_type_code := l_g_ph_tbl(J).relationship_type_code;
                              p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                              p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                              p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                              p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                              p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                              p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                              p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                              p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                              p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                              p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                              p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                              p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                              p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                              p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                              p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                              p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                              p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                              p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                              p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                              p_u_party_tbl(l_pty_idx).primary_flag           := l_g_ph_tbl(J).primary_flag;
                              p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                              p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                              --   create new party record with l_to_party
                              l_pty_idx := l_pty_idx + 1;
                              p_u_party_tbl(l_pty_idx).instance_party_id      := FND_API.G_MISS_NUM;
                              p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                              p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                              p_u_party_tbl(l_pty_idx).party_id               := l_to_party_id;
                              p_u_party_tbl(l_pty_idx).relationship_type_code := l_prof_reltype_code;
                              p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                              p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                              p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                              p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                              p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                              p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                              p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                              p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                              p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                              p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                              p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                              p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                              p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                              p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                              p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                              p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                              p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                              p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                              p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                              p_u_party_tbl(l_pty_idx).primary_flag           := 'N';
                              p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                              p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                              FOR K in 1..l_g_pah_tbl.count LOOP -- { K Loop
                                 IF ( l_g_pah_tbl(K).instance_party_id = l_instance_party_id AND
                                      l_g_pah_tbl(K).active_end_date   IS NULL ) THEN  -- { accounts for the same party
                                    -- move the account record to update table
                                    l_acct_idx := l_acct_idx + 1;
                                    p_u_party_account_tbl(l_acct_idx).ip_account_id          := l_g_pah_tbl(K).ip_account_id;

                                    IF ( l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) OR
                                         l_g_pah_tbl(K).bill_to_address  = NUM_COL2_ORIG_LIST(I) OR
                                         l_g_pah_tbl(K).ship_to_address  = NUM_COL3_ORIG_LIST(I) ) THEN -- { if the record needs update
                                       p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx;
                                       p_u_party_account_tbl(l_acct_idx).instance_party_id      := FND_API.G_MISS_NUM;
                                    ELSE -- } if record needs update { if record needs no update
                                       p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx-1;
                                       p_u_party_account_tbl(l_acct_idx).instance_party_id      := l_g_pah_tbl(K).instance_party_id;
                                    END IF; -- } if the record needs no update

                                    IF l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := NUM_COL1_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := l_g_pah_tbl(K).party_account_id;
                                    END IF;

                                    IF l_g_pah_tbl(K).bill_to_address = NUM_COL2_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := NUM_COL2_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := l_g_pah_tbl(K).bill_to_address;
                                    END IF;

                                    IF l_g_pah_tbl(K).ship_to_address = NUM_COL3_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := NUM_COL3_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := l_g_pah_tbl(K).ship_to_address;
                                    END IF;

                                    p_u_party_account_tbl(l_acct_idx).relationship_type_code := l_g_pah_tbl(K).relationship_type_code;
                                    p_u_party_account_tbl(l_acct_idx).active_start_date      := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).active_end_date        := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).context                := l_g_pah_tbl(K).context;
                                    p_u_party_account_tbl(l_acct_idx).attribute1             := l_g_pah_tbl(K).attribute1;
                                    p_u_party_account_tbl(l_acct_idx).attribute2             := l_g_pah_tbl(K).attribute2;
                                    p_u_party_account_tbl(l_acct_idx).attribute3             := l_g_pah_tbl(K).attribute3;
                                    p_u_party_account_tbl(l_acct_idx).attribute4             := l_g_pah_tbl(K).attribute4;
                                    p_u_party_account_tbl(l_acct_idx).attribute5             := l_g_pah_tbl(K).attribute5;
                                    p_u_party_account_tbl(l_acct_idx).attribute6             := l_g_pah_tbl(K).attribute6;
                                    p_u_party_account_tbl(l_acct_idx).attribute7             := l_g_pah_tbl(K).attribute7;
                                    p_u_party_account_tbl(l_acct_idx).attribute8             := l_g_pah_tbl(K).attribute8;
                                    p_u_party_account_tbl(l_acct_idx).attribute9             := l_g_pah_tbl(K).attribute9;
                                    p_u_party_account_tbl(l_acct_idx).attribute10            := l_g_pah_tbl(K).attribute10;
                                    p_u_party_account_tbl(l_acct_idx).attribute11            := l_g_pah_tbl(K).attribute11;
                                    p_u_party_account_tbl(l_acct_idx).attribute12            := l_g_pah_tbl(K).attribute12;
                                    p_u_party_account_tbl(l_acct_idx).attribute13            := l_g_pah_tbl(K).attribute13;
                                    p_u_party_account_tbl(l_acct_idx).attribute14            := l_g_pah_tbl(K).attribute14;
                                    p_u_party_account_tbl(l_acct_idx).attribute15            := l_g_pah_tbl(K).attribute15;
                                    p_u_party_account_tbl(l_acct_idx).object_version_number  := l_g_pah_tbl(K).object_version_number;
                                    p_u_party_account_tbl(l_acct_idx).call_contracts         := FND_API.G_FALSE;
                                 END IF; -- } accounts for the same party
                              END LOOP;  -- } K Loop

                           ELSE -- } l_pty_with_diff_accts = 'Y' { l_pty_with_diff_accts = 'N'
                              -- move the party record to update table
                              error_str                    := '019';
                              l_pty_idx := l_pty_idx + 1;
                              p_u_party_tbl(l_pty_idx).instance_party_id      := l_g_ph_tbl(J).instance_party_id;
                              p_u_party_tbl(l_pty_idx).instance_id            := l_g_ph_tbl(J).instance_id;
                              p_u_party_tbl(l_pty_idx).party_source_table     := l_g_ph_tbl(J).party_source_table;
                              p_u_party_tbl(l_pty_idx).party_id               := l_g_ph_tbl(J).party_id; --Fix for Bug 4284460
                              p_u_party_tbl(l_pty_idx).relationship_type_code := l_g_ph_tbl(J).relationship_type_code;
                              p_u_party_tbl(l_pty_idx).contact_flag           := l_g_ph_tbl(J).contact_flag;
                              p_u_party_tbl(l_pty_idx).contact_ip_id          := l_g_ph_tbl(J).contact_ip_id;
                              p_u_party_tbl(l_pty_idx).active_start_date      := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).active_end_date        := FND_API.G_MISS_DATE;
                              p_u_party_tbl(l_pty_idx).context                := l_g_ph_tbl(J).context;
                              p_u_party_tbl(l_pty_idx).attribute1             := l_g_ph_tbl(J).attribute1;
                              p_u_party_tbl(l_pty_idx).attribute2             := l_g_ph_tbl(J).attribute2;
                              p_u_party_tbl(l_pty_idx).attribute3             := l_g_ph_tbl(J).attribute3;
                              p_u_party_tbl(l_pty_idx).attribute4             := l_g_ph_tbl(J).attribute4;
                              p_u_party_tbl(l_pty_idx).attribute5             := l_g_ph_tbl(J).attribute5;
                              p_u_party_tbl(l_pty_idx).attribute6             := l_g_ph_tbl(J).attribute6;
                              p_u_party_tbl(l_pty_idx).attribute7             := l_g_ph_tbl(J).attribute7;
                              p_u_party_tbl(l_pty_idx).attribute8             := l_g_ph_tbl(J).attribute8;
                              p_u_party_tbl(l_pty_idx).attribute9             := l_g_ph_tbl(J).attribute9;
                              p_u_party_tbl(l_pty_idx).attribute10            := l_g_ph_tbl(J).attribute10;
                              p_u_party_tbl(l_pty_idx).attribute11            := l_g_ph_tbl(J).attribute11;
                              p_u_party_tbl(l_pty_idx).attribute12            := l_g_ph_tbl(J).attribute12;
                              p_u_party_tbl(l_pty_idx).attribute13            := l_g_ph_tbl(J).attribute13;
                              p_u_party_tbl(l_pty_idx).attribute14            := l_g_ph_tbl(J).attribute14;
                              p_u_party_tbl(l_pty_idx).attribute15            := l_g_ph_tbl(J).attribute15;
                              p_u_party_tbl(l_pty_idx).object_version_number  := l_g_ph_tbl(J).object_version_number;
                              p_u_party_tbl(l_pty_idx).primary_flag           := l_g_ph_tbl(J).primary_flag;
                              p_u_party_tbl(l_pty_idx).preferred_flag         := l_g_ph_tbl(J).preferred_flag;
                              p_u_party_tbl(l_pty_idx).call_contracts         := FND_API.G_FALSE;

                              FOR K in 1..l_g_pah_tbl.count LOOP -- { K Loop
                                 IF ( l_g_pah_tbl(K).instance_party_id = l_instance_party_id AND
                                      l_g_pah_tbl(K).active_end_date  IS NULL ) THEN  -- { accounts for the same party
                                    -- move the account record to update table
                                    l_acct_idx := l_acct_idx + 1;
                                    p_u_party_account_tbl(l_acct_idx).ip_account_id          := l_g_pah_tbl(K).ip_account_id;
                                    p_u_party_account_tbl(l_acct_idx).parent_tbl_index       := l_pty_idx;
                                    p_u_party_account_tbl(l_acct_idx).instance_party_id      := l_g_pah_tbl(K).instance_party_id;
                                    IF l_g_pah_tbl(K).party_account_id = NUM_COL1_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := NUM_COL1_NEW_LIST(I);
				       p_u_party_tbl(l_pty_idx).party_id               := l_to_party_id;--fix for bug 4284460
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).party_account_id := l_g_pah_tbl(K).party_account_id;
                                    END IF;

                                    IF l_g_pah_tbl(K).bill_to_address = NUM_COL2_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := NUM_COL2_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).bill_to_address  := l_g_pah_tbl(K).bill_to_address;
                                    END IF;

                                    IF l_g_pah_tbl(K).ship_to_address = NUM_COL3_ORIG_LIST(I) THEN
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := NUM_COL3_NEW_LIST(I);
                                    ELSE
                                       p_u_party_account_tbl(l_acct_idx).ship_to_address  := l_g_pah_tbl(K).ship_to_address;
                                    END IF;

                                    p_u_party_account_tbl(l_acct_idx).relationship_type_code := l_g_pah_tbl(K).relationship_type_code;
                                    p_u_party_account_tbl(l_acct_idx).active_start_date      := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).active_end_date        := FND_API.G_MISS_DATE;
                                    p_u_party_account_tbl(l_acct_idx).context                := l_g_pah_tbl(K).context;
                                    p_u_party_account_tbl(l_acct_idx).attribute1             := l_g_pah_tbl(K).attribute1;
                                    p_u_party_account_tbl(l_acct_idx).attribute2             := l_g_pah_tbl(K).attribute2;
                                    p_u_party_account_tbl(l_acct_idx).attribute3             := l_g_pah_tbl(K).attribute3;
                                    p_u_party_account_tbl(l_acct_idx).attribute4             := l_g_pah_tbl(K).attribute4;
                                    p_u_party_account_tbl(l_acct_idx).attribute5             := l_g_pah_tbl(K).attribute5;
                                    p_u_party_account_tbl(l_acct_idx).attribute6             := l_g_pah_tbl(K).attribute6;
                                    p_u_party_account_tbl(l_acct_idx).attribute7             := l_g_pah_tbl(K).attribute7;
                                    p_u_party_account_tbl(l_acct_idx).attribute8             := l_g_pah_tbl(K).attribute8;
                                    p_u_party_account_tbl(l_acct_idx).attribute9             := l_g_pah_tbl(K).attribute9;
                                    p_u_party_account_tbl(l_acct_idx).attribute10            := l_g_pah_tbl(K).attribute10;
                                    p_u_party_account_tbl(l_acct_idx).attribute11            := l_g_pah_tbl(K).attribute11;
                                    p_u_party_account_tbl(l_acct_idx).attribute12            := l_g_pah_tbl(K).attribute12;
                                    p_u_party_account_tbl(l_acct_idx).attribute13            := l_g_pah_tbl(K).attribute13;
                                    p_u_party_account_tbl(l_acct_idx).attribute14            := l_g_pah_tbl(K).attribute14;
                                    p_u_party_account_tbl(l_acct_idx).attribute15            := l_g_pah_tbl(K).attribute15;
                                    p_u_party_account_tbl(l_acct_idx).object_version_number  := l_g_pah_tbl(K).object_version_number;
                                    p_u_party_account_tbl(l_acct_idx).call_contracts         := FND_API.G_FALSE;
                                 END IF; -- } accounts for the same party
                              END LOOP;  -- } K Loop
                           END IF; -- } l_pty_with_diff_accts = 'N'
                        END IF; -- } l_owner_update = 'N'
                     END IF;  -- } Account records  for party > 1
                     END IF; -- } Not Address only
                  END IF; -- } for party_source table HZ_PARTIES
               END LOOP;  -- } J Loop

               -- Set the instance_rec for the update call
               error_str := '021';
               p_u_instance_rec.instance_id          	:= INSTANCE_ID_LIST(I);
               p_u_instance_rec.object_version_number 	:= l_g_instance_rec.object_version_number;


	       IF  NUM_COL5_NEW_LIST(I) IS NOT NULL AND NUM_COL4_NEW_LIST(I) IS NOT NULL THEN

	         p_u_instance_rec.install_location_id     := NUM_COL5_NEW_LIST(I);
	         p_u_instance_rec.location_id             := NUM_COL4_NEW_LIST(I);

           END IF;


               --
               write_to_cr_log( 'CSI:Party and Account Records for update call : ' ||
                                     to_char(p_u_party_tbl.count)            || ' : ' ||
                                     to_char(p_u_party_account_tbl.count) );

               -- Now update the instance with all new data
               error_str := '022';
               csi_item_instance_pub.update_item_instance(
                     p_api_version              => 1.0,
                     p_commit                   => fnd_api.g_false,
                     p_init_msg_list            => fnd_api.g_true,
                     p_validation_level         => fnd_api.g_valid_level_full,
                     p_instance_rec             => p_u_instance_rec,
                     p_ext_attrib_values_tbl    => p_u_ext_attrib_values_tbl,
                     p_party_tbl                => p_u_party_tbl,
                     p_account_tbl              => p_u_party_account_tbl,
                     p_pricing_attrib_tbl       => p_u_pricing_attrib_tbl,
                     p_org_assignments_tbl      => p_u_org_assignments_tbl,
                     p_asset_assignment_tbl     => p_u_asset_assignment_tbl,
                     p_txn_rec                  => p_txn_rec,
                     x_instance_id_lst          => x_instance_id_lst,
                     x_return_status            => l_return_status,
                     x_msg_count                => l_msg_count,
                     x_msg_data                 => l_msg_data);
               write_to_cr_log( 'return status :'||l_return_status);

               ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
                ARP_MESSAGE.SET_TOKEN('TABLE_NAME','return_status'||l_return_status,FALSE);
               IF l_return_status <> 'S' Then
			   write_to_cr_log( 'Msg Count : '||to_char(l_msg_count));
			   FOR l_msg_ctr in 1..l_msg_count  LOOP
                     fnd_msg_pub.get ( l_msg_ctr, FND_API.G_FALSE, l_msg_data, l_msg_dummy );
			      write_to_cr_log( 'Msg : '|| to_char(l_msg_ctr) || ' ' || l_msg_data );
			   END LOOP;
                  RAISE l_merge_excep;
               END IF;
	       	       /*   ***commented veto delete for bug 5897064**
			--
			--  Veto the delete as the history information still exists.
			--
			l_from_customer_id := num_col1_orig_list(I);
			BEGIN
			   l_is_vetoed := vetoed_list( l_from_customer_id );
               EXCEPTION
			   WHEN no_data_found THEN
				 BEGIN
                        ARP_CMERGE_MASTER.veto_delete
                        (
                           req_id            =>        req_id,
                           set_num           =>        set_num,
                           from_customer_id  =>        l_from_customer_id,
                           veto_reason       =>        l_veto_reason
                        );
				    vetoed_list( l_from_customer_id ) := 'Y';
				 END;
              END; */
            END IF; -- } Party account id retrieved is not already updated

         END LOOP; -- } I Loop

         l_count := l_count + SQL%ROWCOUNT;
         IF l_last_fetch THEN -- { 17
            EXIT;
         END IF;  -- } 17

      END LOOP; -- } 3    merge records Loop

      CLOSE merged_records;

      arp_message.set_name('CSI','CSI_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
      arp_message.set_line( 'Done with the update of CSI_IP_ACCOUNTS' );
   END IF; -- } 2

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_IP_ACCOUNTS_MERGE()-');

EXCEPTION
   WHEN OTHERS THEN
	 CLOSE merged_records;
	 l_msg_data := error_str || '-' || l_msg_data;
      arp_message.set_error('CRM_MERGE.CUSTOMER_PRODUCTS_MERGE', l_msg_data);
      RAISE;
END csi_ip_accounts_merge; -- } 1

PROCEDURE csi_systems_b_merge(req_id   IN NUMBER,
                            set_num   IN NUMBER,
                            process_mode IN VARCHAR2) IS

   error_str 				VARCHAR2(3);
   no_of_rows             	NUMBER;
   l_system_audit_id      	NUMBER;
   v_transaction_type_id  	NUMBER;
   v_transaction_id      	NUMBER;
   l_profile_val 		VARCHAR2(30);
   v_transaction_exists		VARCHAR2(1)	:= 'N';
   v_source_transaction_type 	VARCHAR2(30) 	:= 'ACCT_MERGE';
   l_last_fetch 		BOOLEAN 	:= FALSE;
   l_count 			NUMBER;

   l_msg_string			VARCHAR2(256);
   v_transaction_cnt		NUMBER;

   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
        RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;

   MERGE_HEADER_ID_LIST 	MERGE_HEADER_ID_LIST_TYPE;

   TYPE SYSTEM_ID_LIST_TYPE IS TABLE OF
        CSI_SYSTEMS_B.SYSTEM_ID%TYPE
        INDEX BY BINARY_INTEGER;

   PRIMARY_KEY_ID_LIST 		SYSTEM_ID_LIST_TYPE;

   TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
        CSI_SYSTEMS_B.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL1_ORIG_LIST 		CUSTOMER_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST 		CUSTOMER_ID_LIST_TYPE;

   TYPE BILL_TO_SITE_USE_ID_LIST_TYPE IS TABLE OF
        CSI_SYSTEMS_B.BILL_TO_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL2_ORIG_LIST 		BILL_TO_SITE_USE_ID_LIST_TYPE;
   NUM_COL2_NEW_LIST 		BILL_TO_SITE_USE_ID_LIST_TYPE;

   TYPE SHIP_TO_SITE_USE_ID_LIST_TYPE IS TABLE OF
        CSI_SYSTEMS_B.SHIP_TO_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL3_ORIG_LIST 		SHIP_TO_SITE_USE_ID_LIST_TYPE;
   NUM_COL3_NEW_LIST 		SHIP_TO_SITE_USE_ID_LIST_TYPE;

   CURSOR merged_records IS
   SELECT distinct
          CUSTOMER_MERGE_HEADER_ID ,
          yt.SYSTEM_ID ,
          yt.CUSTOMER_ID ,
          yt.BILL_TO_SITE_USE_ID ,
          yt.SHIP_TO_SITE_USE_ID
   FROM   CSI_SYSTEMS_B yt,
          RA_CUSTOMER_MERGES m
   WHERE  ( yt.CUSTOMER_ID         = m.DUPLICATE_ID 	OR
            yt.BILL_TO_SITE_USE_ID = m.DUPLICATE_SITE_ID   OR
            yt.SHIP_TO_SITE_USE_ID = m.DUPLICATE_SITE_ID )
     AND    m.process_flag         = 'N'
     AND    m.request_id           = req_id
     AND    m.set_number           = set_num;

   I							NUMBER;
   v_system_history_id			NUMBER;
BEGIN

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_SYSTEMS_B_MERGE()+');

   IF (process_mode = 'LOCK') THEN

      write_to_cr_log( 'CSI : csi_systems_b_merge...' || process_mode ) ;

      write_to_cr_log( 'Locking the csi_systems_b table' );
      arp_message.set_name('AR','AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME','CSI_SYSTEMS_B',FALSE);

      OPEN  merged_records;
      CLOSE merged_records;

      write_to_cr_log( 'Done Locking the csi_systems_b table' );

   ELSE

      write_to_cr_log( 'CSI : csi_systems_b_merge.....' || process_mode );

      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSI_SYSTEMS_B',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;

      LOOP  -- { Merged records Loop

         FETCH merged_records BULK COLLECT INTO
            MERGE_HEADER_ID_LIST ,
            PRIMARY_KEY_ID_LIST ,
            NUM_COL1_ORIG_LIST ,
            NUM_COL2_ORIG_LIST ,
            NUM_COL3_ORIG_LIST
         LIMIT 1000;

         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            EXIT;
         END IF;

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP

            write_to_cr_log( to_char(i) || 'system :  orig1 orig2 orig3 : '||
                        to_char(NUM_COL1_ORIG_LIST(I)) || '<>' ||
                        to_char(NUM_COL2_ORIG_LIST(I)) || '<>' ||
                        to_char(NUM_COL3_ORIG_LIST(I)) );

            NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
            NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
            NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));

            write_to_cr_log( to_char(i) || '.new1  new2  new3  : '||
                        to_char(NUM_COL1_NEW_LIST(I)) || '<>' ||
                        to_char(NUM_COL2_NEW_LIST(I)) || '<>' ||
                        to_char(NUM_COL3_NEW_LIST(I)) );

         END LOOP;

         write_to_cr_log( 'CSI : Before Audit check ');

         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN  -- { profile value if

            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
               INSERT INTO HZ_CUSTOMER_MERGE_LOG
               (
                  MERGE_LOG_ID ,
                  TABLE_NAME ,
                  MERGE_HEADER_ID ,
                  PRIMARY_KEY_ID ,
                  NUM_COL1_ORIG ,
                  NUM_COL1_NEW ,
                  NUM_COL2_ORIG ,
                  NUM_COL2_NEW ,
                  NUM_COL3_ORIG ,
                  NUM_COL3_NEW ,
                  ACTION_FLAG ,
                  REQUEST_ID ,
                  CREATED_BY ,
                  CREATION_DATE ,
                  LAST_UPDATE_LOGIN ,
                  LAST_UPDATE_DATE ,
                  LAST_UPDATED_BY
               )
               VALUES
               (
                  HZ_CUSTOMER_MERGE_LOG_s.nextval ,
                  'CSI_SYSTEMS_B' ,
                  MERGE_HEADER_ID_LIST(I) ,
                  PRIMARY_KEY_ID_LIST(I) ,
                  NUM_COL1_ORIG_LIST(I) ,
                  NUM_COL1_NEW_LIST(I) ,
                  NUM_COL2_ORIG_LIST(I ),
                  NUM_COL2_NEW_LIST(I) ,
                  NUM_COL3_ORIG_LIST(I) ,
                  NUM_COL3_NEW_LIST(I) ,
                  'U' ,
                  req_id ,
                  hz_utility_pub.CREATED_BY ,
                  hz_utility_pub.CREATION_DATE ,
                  hz_utility_pub.LAST_UPDATE_LOGIN ,
                  hz_utility_pub.LAST_UPDATE_DATE ,
                  hz_utility_pub.LAST_UPDATED_BY
               );

         END IF;   -- } profile value if

         write_to_cr_log( 'CSI : Before Update Loop check ');

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP -- { I Loop
            UPDATE CSI_SYSTEMS_B yt
            SET    CUSTOMER_ID             = NUM_COL1_NEW_LIST(I) ,
                   BILL_TO_SITE_USE_ID     = NUM_COL2_NEW_LIST(I) ,
                   SHIP_TO_SITE_USE_ID     = NUM_COL3_NEW_LIST(I) ,
                   LAST_UPDATE_DATE        = SYSDATE ,
                   last_updated_by         = arp_standard.profile.user_id ,
                   last_update_login       = arp_standard.profile.last_update_login ,
                   REQUEST_ID              = req_id ,
                   PROGRAM_APPLICATION_ID  = arp_standard.profile.program_application_id ,
                   PROGRAM_ID              = arp_standard.profile.program_id ,
                   PROGRAM_UPDATE_DATE     = SYSDATE
            WHERE  SYSTEM_ID = PRIMARY_KEY_ID_LIST(I);

            /*------
            Check for a transaction record and if not found create one

              If transaction_inserted_flag = 'N' then
                1.1 if a transaction does not exist
                    create a transaction
                1.2 set the transaction_inserted_flag = 'Y'
            ------*/
            SELECT count(*)
            INTO   v_transaction_cnt
            FROM   csi_transactions
            WHERE  source_line_ref_id = req_id
            AND    source_line_ref    = set_num;

            write_to_cr_log( 'CSI : Transaction record count for '
                                       || to_char(req_id)  || '.'
                                       || to_char(set_num) || '.'
                                       || to_char(v_transaction_cnt) );

            IF v_transaction_exists = 'N' Then -- { transaction exists is no
	          BEGIN  -- { select csi_transaction
                  error_str 	:= '005';
                  SELECT transaction_id
                  INTO   v_transaction_id
                  FROM   csi_transactions
                  WHERE  source_line_ref_id = req_id
                  AND    source_line_ref    = set_num;

                  v_transaction_exists := 'Y';

                  write_to_cr_log( 'CSI : Transaction record found.');

               EXCEPTION
                  WHEN no_data_found THEN
                  BEGIN  -- { insert csi_transaction
                     error_str 	:= '006';

                     write_to_cr_log( 'CSI : Transaction record NOT found.');

                     SELECT count(*)
                     INTO   v_transaction_cnt
                     FROM   csi_txn_types
                     WHERE  source_transaction_type = v_source_transaction_type;

                     write_to_cr_log( 'CSI : Transaction type record count '|| to_char(v_transaction_cnt) );

                     SELECT transaction_type_id
                     INTO   v_transaction_type_id
                     FROM   csi_txn_types
                     WHERE  source_transaction_type = v_source_transaction_type;

                     write_to_cr_log( 'CSI : Transaction type record id ' || to_char(v_transaction_type_id) );

                     error_str 	:= '007';
		     SELECT csi_transactions_s.nextval
		     INTO   v_transaction_id
		     FROM   dual;

                     write_to_cr_log( 'CSI : Transaction id from sequence ' || to_char(v_transaction_id) );

                     error_str 	:= '008';
                     INSERT INTO csi_transactions
                     (
                        transaction_id ,
                        transaction_date ,
                        source_transaction_date ,
                        transaction_type_id ,
                        source_line_ref_id ,
                        source_line_ref ,
                        created_by ,
                        creation_date ,
                        last_updated_by ,
                        last_update_date ,
                        last_update_login ,
                        object_version_number
                     )
                     VALUES
                     (
                        v_transaction_id ,
                        sysdate ,
                        sysdate ,
                        v_transaction_type_id ,
                        req_id ,
                        set_num ,
                        arp_standard.profile.user_id ,
                        sysdate ,
                        arp_standard.profile.user_id ,
                        sysdate ,
                        arp_standard.profile.last_update_login ,
                        1
                     );

                     v_transaction_exists := 'Y';

                     write_to_cr_log( 'CSI : Transaction record created ' );

                  END;  -- } end insert csi_transaction
               END;  -- } end select csi_transaction
            END IF;  -- } transaction exists is no

            BEGIN  -- { Update systems history

               SELECT count(*)
               INTO   v_transaction_cnt
               FROM   csi_systems_h
               WHERE  transaction_id = v_transaction_id
               AND    system_id = PRIMARY_KEY_ID_LIST(I);

               write_to_cr_log( 'CSI : Transaction history record count '|| to_char(v_transaction_cnt) );

               error_str 	:= '009';
               SELECT system_history_id
               INTO   v_system_history_id
               FROM   csi_systems_h
               WHERE  transaction_id = v_transaction_id
               AND    system_id = PRIMARY_KEY_ID_LIST(I);

               write_to_cr_log( 'CSI : Transaction history record id '|| to_char(v_system_history_id) );

               error_str 	:= '010';
               UPDATE csi_systems_h
               SET    old_customer_id         = NUM_COL1_ORIG_LIST(I) ,
                      new_customer_id	 	 = NUM_COL1_NEW_LIST(I) ,
                      old_bill_to_site_use_id = NUM_COL2_ORIG_LIST(I) ,
                      new_bill_to_site_use_id = NUM_COL2_NEW_LIST(I) ,
                      old_ship_to_site_use_id = NUM_COL3_ORIG_LIST(I) ,
                      new_ship_to_site_use_id = NUM_COL3_NEW_LIST(I) ,
                      object_version_number   = object_version_number + 1
               WHERE  system_history_id 	 = v_system_history_id ;

               write_to_cr_log( 'CSI : updated system history record ' );

            EXCEPTION
               WHEN no_data_found THEN
               BEGIN	--{ Insert systems history

                  write_to_cr_log( 'CSI : No system history record found ' );

                  error_str 	:= '011';
                  INSERT INTO csi_systems_h
                  (
                     system_history_id ,
                     system_id ,
                     transaction_id ,
                     old_customer_id ,
                     new_customer_id ,
                     old_bill_to_site_use_id ,
                     new_bill_to_site_use_id ,
                     old_ship_to_site_use_id ,
                     new_ship_to_site_use_id ,
                     full_dump_flag ,
                     created_by ,
                     creation_date ,
                     last_updated_by ,
                     last_update_date ,
                     last_update_login ,
                     object_version_number
                  )
                  VALUES
                  (
                     csi_systems_h_s.nextval ,
                     PRIMARY_KEY_ID_LIST(I) ,
                     v_transaction_id ,
                     NUM_COL1_ORIG_LIST(I) ,
                     NUM_COL1_NEW_LIST(I) ,
                     NUM_COL2_ORIG_LIST(I) ,
                     NUM_COL2_NEW_LIST(I) ,
                     NUM_COL3_ORIG_LIST(I) ,
                     NUM_COL3_NEW_LIST(I) ,
                     'N',
                     arp_standard.profile.user_id ,
                     sysdate ,
                     arp_standard.profile.user_id ,
                     sysdate ,
                     arp_standard.profile.last_update_login ,
                     1
                  );
                  write_to_cr_log( 'CSI : inserted system history record ' );
               END;  -- } Insert systems history
            END; -- } Update Systems history
         END LOOP; -- } I Loop

         l_count := l_count + SQL%ROWCOUNT;

         IF l_last_fetch THEN
            EXIT;
         END IF;

         no_of_rows := sql%rowcount;
         arp_message.set_token('NUM_ROWS',to_char(no_of_rows));
         arp_message.set_line( 'Done with the insert of systems history' );

      END LOOP;  -- } End merged records loop

      CLOSE merged_records;

   END IF;

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_SYSTEMS_B_MERGE()-');

EXCEPTION
   WHEN OTHERS THEN
      arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_SYSTEMS_B_MERGE()-');
      CLOSE merged_records;
      raise;
END csi_systems_b_merge;

PROCEDURE csi_t_party_accounts_merge( req_id   		IN NUMBER,
                                      set_num   	IN NUMBER,
                                      process_mode 	IN VARCHAR2 ) IS

   error_str		VARCHAR2(3);
   no_of_rows      	NUMBER;
   l_profile_val 	VARCHAR2(30);
   l_last_fetch 	BOOLEAN 	:= FALSE;
   l_count 		NUMBER;

   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
        RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;

   MERGE_HEADER_ID_LIST 	MERGE_HEADER_ID_LIST_TYPE;

   TYPE TXN_ACCT_DETAIL_ID_LIST_TYPE IS TABLE OF
        CSI_T_PARTY_ACCOUNTS.TXN_ACCOUNT_DETAIL_ID%TYPE
        INDEX BY BINARY_INTEGER;

   PRIMARY_KEY_ID_LIST 		TXN_ACCT_DETAIL_ID_LIST_TYPE;

   TYPE ACCOUNT_ID_LIST_TYPE IS TABLE OF
        CSI_T_PARTY_ACCOUNTS.ACCOUNT_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL1_ORIG_LIST 		ACCOUNT_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST 		ACCOUNT_ID_LIST_TYPE;

   TYPE BILL_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
        CSI_T_PARTY_ACCOUNTS.BILL_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL2_ORIG_LIST 		BILL_TO_ADDRESS_ID_LIST_TYPE;
   NUM_COL2_NEW_LIST 		BILL_TO_ADDRESS_ID_LIST_TYPE;

   TYPE SHIP_TO_ADDRESS_ID_LIST_TYPE IS TABLE OF
        CSI_T_PARTY_ACCOUNTS.SHIP_TO_ADDRESS_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL3_ORIG_LIST 		SHIP_TO_ADDRESS_ID_LIST_TYPE;
   NUM_COL3_NEW_LIST 		SHIP_TO_ADDRESS_ID_LIST_TYPE;

   CURSOR merged_records IS
   SELECT distinct CUSTOMER_MERGE_HEADER_ID ,
	  TXN_ACCOUNT_DETAIL_ID ,
	  ACCOUNT_ID ,
	  BILL_TO_ADDRESS_ID ,
	  SHIP_TO_ADDRESS_ID
   FROM   CSI_T_PARTY_ACCOUNTS yt,
	  RA_CUSTOMER_MERGES m
   WHERE  ( yt.ACCOUNT_ID 		= m.DUPLICATE_ID 	OR
	    yt.BILL_TO_ADDRESS_ID 	= m.DUPLICATE_SITE_ID 	OR
	    yt.SHIP_TO_ADDRESS_ID  	= m.DUPLICATE_SITE_ID )
   AND    m.process_flag 	= 'N'
   AND    m.request_id 		= req_id
   AND    m.set_number 		= set_num;

BEGIN

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_T_PARTY_ACCOUNTS_MERGE()+');

   IF (process_mode = 'LOCK') THEN

      write_to_cr_log( 'Locking the csi_t_party_accounts' );

      arp_message.set_name('AR','AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME','CSI_T_PARTY_ACCOUNTS',FALSE);

      OPEN merged_records;
      CLOSE merged_records;

      write_to_cr_log( 'Done Locking the csi_t_party_accounts' );
   ELSE
      write_to_cr_log( 'Starting to update the csi_t_party_accounts' );

      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSI_T_PARTY_ACCOUNTS',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;

      LOOP
         FETCH merged_records BULK COLLECT INTO
         	MERGE_HEADER_ID_LIST ,
		PRIMARY_KEY_ID_LIST ,
		NUM_COL1_ORIG_LIST ,
		NUM_COL2_ORIG_LIST ,
		NUM_COL3_ORIG_LIST
         LIMIT 1000;

         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
           EXIT;
         END IF;

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
            NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
            NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
            NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
         END LOOP;

         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
               INSERT INTO HZ_CUSTOMER_MERGE_LOG
               (
                  MERGE_LOG_ID ,
                  TABLE_NAME ,
                  MERGE_HEADER_ID ,
                  PRIMARY_KEY_ID ,
                  NUM_COL1_ORIG ,
                  NUM_COL1_NEW ,
                  NUM_COL2_ORIG ,
                  NUM_COL2_NEW ,
                  NUM_COL3_ORIG ,
                  NUM_COL3_NEW ,
                  ACTION_FLAG ,
                  REQUEST_ID ,
                  CREATED_BY ,
                  CREATION_DATE ,
                  LAST_UPDATE_LOGIN ,
                  LAST_UPDATE_DATE ,
                  LAST_UPDATED_BY
               )
               VALUES
               (
                  HZ_CUSTOMER_MERGE_LOG_s.nextval ,
                  'CSI_T_PARTY_ACCOUNTS' ,
                  MERGE_HEADER_ID_LIST(I) ,
                  PRIMARY_KEY_ID_LIST(I) ,
                  NUM_COL1_ORIG_LIST(I) ,
                  NUM_COL1_NEW_LIST(I) ,
                  NUM_COL2_ORIG_LIST(I) ,
                  NUM_COL2_NEW_LIST(I) ,
                  NUM_COL3_ORIG_LIST(I) ,
                  NUM_COL3_NEW_LIST(I) ,
                  'U' ,
                  req_id ,
                  hz_utility_pub.CREATED_BY ,
                  hz_utility_pub.CREATION_DATE ,
                  hz_utility_pub.LAST_UPDATE_LOGIN ,
                  hz_utility_pub.LAST_UPDATE_DATE ,
                  hz_utility_pub.LAST_UPDATED_BY
               );
         END IF;

         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            UPDATE CSI_T_PARTY_ACCOUNTS yt
            SET    ACCOUNT_ID 			= NUM_COL1_NEW_LIST(I) ,
		   BILL_TO_ADDRESS_ID 		= NUM_COL2_NEW_LIST(I) ,
		   SHIP_TO_ADDRESS_ID 		= NUM_COL3_NEW_LIST(I) ,
		   LAST_UPDATE_DATE 		= SYSDATE ,
		   last_updated_by 		= arp_standard.profile.user_id ,
		   last_update_login 		= arp_standard.profile.last_update_login ,
		   REQUEST_ID 			= req_id ,
		   PROGRAM_APPLICATION_ID 	= arp_standard.profile.program_application_id ,
		   PROGRAM_ID 			= arp_standard.profile.program_id ,
		   PROGRAM_UPDATE_DATE 		= SYSDATE
            WHERE  TXN_ACCOUNT_DETAIL_ID 	= PRIMARY_KEY_ID_LIST(I);

         l_count := l_count + SQL%ROWCOUNT;

         IF l_last_fetch THEN
            EXIT;
         END IF;

      END LOOP;

      CLOSE merged_records;

      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
      arp_message.set_line( 'Done with the update of csi_t_party_accounts' );

   END IF;

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_T_PARTY_ACCOUNTS_MERGE()-');

EXCEPTION
   WHEN OTHERS THEN
      arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_T_PARTY_ACCOUNTS_MERGE()-');
      CLOSE merged_records;
      raise;
END csi_t_party_accounts_merge;

PROCEDURE csi_t_txn_systems_merge( req_id   	IN NUMBER,
                                   set_num   	IN NUMBER,
                                   process_mode IN VARCHAR2) IS

   error_str		VARCHAR2(3);
   no_of_rows      	NUMBER;
   l_profile_val 	VARCHAR2(30);
   l_last_fetch 	BOOLEAN 	:= FALSE;
   l_count 		NUMBER;

   TYPE MERGE_HEADER_ID_LIST_TYPE IS TABLE OF
        RA_CUSTOMER_MERGE_HEADERS.CUSTOMER_MERGE_HEADER_ID%TYPE
        INDEX BY BINARY_INTEGER;

   MERGE_HEADER_ID_LIST 	MERGE_HEADER_ID_LIST_TYPE;

   TYPE TRXN_SYSTEM_ID_LIST_TYPE IS TABLE OF
        CSI_T_TXN_SYSTEMS.TRANSACTION_SYSTEM_ID%TYPE
        INDEX BY BINARY_INTEGER;

   PRIMARY_KEY_ID_LIST 		TRXN_SYSTEM_ID_LIST_TYPE;

   TYPE CUSTOMER_ID_LIST_TYPE IS TABLE OF
        CSI_T_TXN_SYSTEMS.CUSTOMER_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL1_ORIG_LIST 		CUSTOMER_ID_LIST_TYPE;
   NUM_COL1_NEW_LIST 		CUSTOMER_ID_LIST_TYPE;

   TYPE BILL_TO_SITE_USE_ID_LIST_TYPE IS TABLE OF
        CSI_T_TXN_SYSTEMS.BILL_TO_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL2_ORIG_LIST 		BILL_TO_SITE_USE_ID_LIST_TYPE;
   NUM_COL2_NEW_LIST 		BILL_TO_SITE_USE_ID_LIST_TYPE;

   TYPE SHIP_TO_SITE_USE_ID_LIST_TYPE IS TABLE OF
        CSI_T_TXN_SYSTEMS.SHIP_TO_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL3_ORIG_LIST 		SHIP_TO_SITE_USE_ID_LIST_TYPE;
   NUM_COL3_NEW_LIST 		SHIP_TO_SITE_USE_ID_LIST_TYPE;

   TYPE INSTALL_SITE_USE_ID_LIST_TYPE IS TABLE OF
        CSI_T_TXN_SYSTEMS.INSTALL_SITE_USE_ID%TYPE
        INDEX BY BINARY_INTEGER;

   NUM_COL4_ORIG_LIST 		INSTALL_SITE_USE_ID_LIST_TYPE;
   NUM_COL4_NEW_LIST 		INSTALL_SITE_USE_ID_LIST_TYPE;

   CURSOR merged_records IS
   SELECT distinct CUSTOMER_MERGE_HEADER_ID ,
	  yt.TRANSACTION_SYSTEM_ID ,
	  yt.CUSTOMER_ID ,
	  yt.BILL_TO_SITE_USE_ID ,
	  yt.SHIP_TO_SITE_USE_ID ,
	  yt.INSTALL_SITE_USE_ID
   FROM   CSI_T_TXN_SYSTEMS yt,
	  RA_CUSTOMER_MERGES m
   WHERE  ( yt.CUSTOMER_ID 		= m.DUPLICATE_ID 	OR
	    yt.BILL_TO_SITE_USE_ID 	= m.DUPLICATE_SITE_ID 	OR
	    yt.SHIP_TO_SITE_USE_ID 	= m.DUPLICATE_SITE_ID   OR
	    yt.INSTALL_SITE_USE_ID 	= m.DUPLICATE_SITE_ID )
   AND    m.process_flag 	= 'N'
   AND    m.request_id 		= req_id
   AND    m.set_number 		= set_num;

BEGIN

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_T_TXN_SYSTEMS_MERGE()+');

   IF (process_mode = 'LOCK') THEN
      write_to_cr_log( 'Locking the CSI_T_TXN_SYSTEMS table' );

      arp_message.set_name('AR','AR_LOCKING_TABLE');
      arp_message.set_token('TABLE_NAME','CSI_T_TXN_SYSTEMS',FALSE);

      OPEN merged_records;
      CLOSE merged_records;

      write_to_cr_log( 'Done Locking the CSI_T_TXN_SYSTEMS table' );
   ELSE
      ARP_MESSAGE.SET_NAME('AR','AR_UPDATING_TABLE');
      ARP_MESSAGE.SET_TOKEN('TABLE_NAME','CSI_T_TXN_SYSTEMS',FALSE);
      HZ_ACCT_MERGE_UTIL.load_set(set_num, req_id);
      l_profile_val :=  FND_PROFILE.VALUE('HZ_AUDIT_ACCT_MERGE');

      OPEN merged_records;

      LOOP
         FETCH merged_records BULK COLLECT INTO
		MERGE_HEADER_ID_LIST ,
		PRIMARY_KEY_ID_LIST ,
		NUM_COL1_ORIG_LIST ,
		NUM_COL2_ORIG_LIST ,
		NUM_COL3_ORIG_LIST ,
	        NUM_COL4_ORIG_LIST
         LIMIT 1000;

         IF merged_records%NOTFOUND THEN
            l_last_fetch := TRUE;
         END IF;

         IF MERGE_HEADER_ID_LIST.COUNT = 0 and l_last_fetch then
            EXIT;
         END IF;

         FOR I in 1..MERGE_HEADER_ID_LIST.COUNT LOOP
            NUM_COL1_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_ACCOUNT(NUM_COL1_ORIG_LIST(I));
            NUM_COL2_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL2_ORIG_LIST(I));
            NUM_COL3_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL3_ORIG_LIST(I));
            NUM_COL4_NEW_LIST(I) := HZ_ACCT_MERGE_UTIL.GETDUP_SITE_USE(NUM_COL4_ORIG_LIST(I));
         END LOOP;

         IF l_profile_val IS NOT NULL AND l_profile_val = 'Y' THEN
            FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
               INSERT INTO HZ_CUSTOMER_MERGE_LOG (
                  MERGE_LOG_ID,
                 TABLE_NAME,
                 MERGE_HEADER_ID,
                 PRIMARY_KEY_ID,
                 NUM_COL1_ORIG,
                 NUM_COL1_NEW,
                 NUM_COL2_ORIG,
                 NUM_COL2_NEW,
                 NUM_COL3_ORIG,
                 NUM_COL3_NEW,
                 NUM_COL4_ORIG,
                 NUM_COL4_NEW,
                 ACTION_FLAG,
                 REQUEST_ID,
                 CREATED_BY,
                 CREATION_DATE,
                 LAST_UPDATE_LOGIN,
                 LAST_UPDATE_DATE,
                 LAST_UPDATED_BY)
              VALUES (
                 HZ_CUSTOMER_MERGE_LOG_s.nextval,
                 'CSI_T_TXN_SYSTEMS',
                 MERGE_HEADER_ID_LIST(I),
                 PRIMARY_KEY_ID_LIST(I),
                 NUM_COL1_ORIG_LIST(I),
                 NUM_COL1_NEW_LIST(I),
                 NUM_COL2_ORIG_LIST(I),
                 NUM_COL2_NEW_LIST(I),
                 NUM_COL3_ORIG_LIST(I),
                 NUM_COL3_NEW_LIST(I),
                 NUM_COL4_ORIG_LIST(I),
                 NUM_COL4_NEW_LIST(I),
                 'U',
                 req_id,
                 hz_utility_pub.CREATED_BY,
                 hz_utility_pub.CREATION_DATE,
                 hz_utility_pub.LAST_UPDATE_LOGIN,
                 hz_utility_pub.LAST_UPDATE_DATE,
                 hz_utility_pub.LAST_UPDATED_BY );
         END IF;

         FORALL I in 1..MERGE_HEADER_ID_LIST.COUNT
            UPDATE CSI_T_TXN_SYSTEMS yt
            SET    CUSTOMER_ID 			= NUM_COL1_NEW_LIST(I) ,
		   BILL_TO_SITE_USE_ID 		= NUM_COL2_NEW_LIST(I) ,
		   SHIP_TO_SITE_USE_ID 		= NUM_COL3_NEW_LIST(I) ,
		   INSTALL_SITE_USE_ID 		= NUM_COL4_NEW_LIST(I) ,
		   LAST_UPDATE_DATE 		= SYSDATE ,
		   last_updated_by 		= arp_standard.profile.user_id ,
		   last_update_login 		= arp_standard.profile.last_update_login ,
		   REQUEST_ID 			= req_id ,
		   PROGRAM_APPLICATION_ID 	= arp_standard.profile.program_application_id ,
		   PROGRAM_ID 			= arp_standard.profile.program_id ,
		   PROGRAM_UPDATE_DATE 		= SYSDATE
            WHERE  TRANSACTION_SYSTEM_ID 	= PRIMARY_KEY_ID_LIST(I);

         l_count := l_count + SQL%ROWCOUNT;
         IF l_last_fetch THEN
            EXIT;
         END IF;

      END LOOP;

      CLOSE merged_records;

      arp_message.set_name('AR','AR_ROWS_UPDATED');
      arp_message.set_token('NUM_ROWS',to_char(l_count));
      arp_message.set_line( 'Done with the update of CSI_T_TXN_SYSTEMS' );

   END IF;

   arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_T_TXN_SYSTEMS_MERGE()-');

EXCEPTION
   WHEN OTHERS THEN
      arp_message.set_line('CSI_ACCT_MERGE_PKG.CSI_T_TXN_SYSTEMS_MERGE()-');
      CLOSE merged_records;
      raise;
END csi_t_txn_systems_merge;

PROCEDURE write_to_cr_log ( p_message IN VARCHAR2) IS
BEGIN
   IF csi_acct_merge_pkg.g_debug_on > 0 THEN
      arp_message.set_line( p_message );
   END IF;
END write_to_cr_log;

END CSI_ACCT_MERGE_PKG;

/
