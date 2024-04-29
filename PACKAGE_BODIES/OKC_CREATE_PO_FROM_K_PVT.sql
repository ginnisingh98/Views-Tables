--------------------------------------------------------
--  DDL for Package Body OKC_CREATE_PO_FROM_K_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CREATE_PO_FROM_K_PVT" AS
/* $Header: OKCRKPOB.pls 120.0 2005/05/26 09:30:43 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


-- Local private procedure
------------------------------------------------------------------------------
---------------- Procedure: my_debug -------------------------
------------------------------------------------------------------------------
-- Purpose: Serves to log debug messages in the log file for the
-- concurrent request. Can be changed to print out dbms_output
-- statements if testing locally
--
-- Parameters: As specified below. Currently the level and module are
-- not used
--
-- Out Parameters: None
--
-------------------------------------------------------------------------------
PROCEDURE my_debug( p_msg    IN VARCHAR2,
				p_level  IN NUMBER   DEFAULT 1,
				p_module IN VARCHAR2 DEFAULT 'OKC');



----------------------------------------------------------------------------
--  Global Constants--------------------------------------------------------
----------------------------------------------------------------------------
--  Standard API Constants

G_UNEXPECTED_ERROR              CONSTANT VARCHAR2(30)  := 'OKC_CONTRACTS_UNEXP_ERROR';
G_SQLCODE_TOKEN                 CONSTANT VARCHAR2(07)  := 'SQLCODE';
G_SQLERRM_TOKEN                 CONSTANT VARCHAR2(07)  := 'SQLERRM';
G_PKG_NAME                      CONSTANT VARCHAR2(30)  := 'OKC_CREATE_PO_FROM_K_PVT';
G_PKG_FILENAME                  CONSTANT VARCHAR2(12)  := 'OKCRKPOB.pls';
G_APP_NAME                      CONSTANT VARCHAR2(03)  :=  OKC_API.G_APP_NAME;
G_APP_NAME1                     CONSTANT VARCHAR2(03)  := 'OKC';

G_API_TYPE                      CONSTANT VARCHAR2(08)  := '_PROCESS';
G_SCOPE                         CONSTANT VARCHAR2(04)  := '_PVT';


-- Constants used for defining rules/rule groups
-- Rule group Billing is not being used for Phase I. Rules inside it
-- are placed in PAYMENT. Need to modify for phase II

g_rg_billing                           CONSTANT VARCHAR2(12)  := 'PAYMENT';
g_rg_shipping                          CONSTANT VARCHAR2(12)  := 'OKPSHIPPING';
g_rg_payment                           CONSTANT VARCHAR2(12)  := 'PAYMENT';
g_rg_currency                          CONSTANT VARCHAR2(12)  := 'CURRENCY';
--g_ru_billto                          CONSTANT VARCHAR2(03)  := 'BTO'; --currently not used
g_ru_billto                            CONSTANT VARCHAR2(06)  := 'OKPBTO';
g_ru_shipto                            CONSTANT VARCHAR2(06)  := 'BUYSTO';
g_ru_convert                           CONSTANT VARCHAR2(03)  := 'CVN';
g_ru_payto                             CONSTANT VARCHAR2(03)  := 'PTO';
g_ru_payterms                          CONSTANT VARCHAR2(03)  := 'PTR';

-- Other Constants

g_po_hdr_process_code                  CONSTANT VARCHAR2(12)  := 'PENDING';
g_po_hdr_action                        CONSTANT VARCHAR2(12)  := 'ORIGINAL';
g_po_hdr_document_type_code            CONSTANT VARCHAR2(12)  := 'STANDARD';
g_po_hdr_approval_status               CONSTANT VARCHAR2(12)  := 'APPROVED';
g_po_hdr_interface_source_code         CONSTANT VARCHAR2(03)  := 'OKP';
g_po_hdr_accept_required_flag          CONSTANT VARCHAR2(01)  := 'N';
g_po_hdr_frozen_flag                   CONSTANT VARCHAR2(01)  := 'N';
g_po_hdr_approv_required_flag          CONSTANT VARCHAR2(01)  := 'N';
g_po_ln_shipment_type                  CONSTANT VARCHAR2(08)  := 'STANDARD';
g_po_dis_destination_type_code         CONSTANT VARCHAR2(10)  := 'INVENTORY';

g_sts_signed                           CONSTANT VARCHAR2(06)  := 'SIGNED';
g_sts_active                           CONSTANT VARCHAR2(06)  := 'ACTIVE';

-- Related objects constants

g_crj_rty_code                    CONSTANT VARCHAR2(20)  := 'CONTRACTCREATESPO';
g_crj_chr_jtot_object_code        CONSTANT VARCHAR2(20)  := 'OKX_PO_HEADERS';
g_crj_cle_jtot_object_code        CONSTANT VARCHAR2(20)  := 'OKX_PO_LINES';
----------------------------------------------------------------------------
--  Global Cursors--------------------------------------------------------
----------------------------------------------------------------------------

-- cursor to get contract header information

CURSOR c_chr (b_chr_id NUMBER) IS SELECT
   authoring_org_id
  ,currency_code
  ,date_signed                       approved_date
  ,po_headers_interface_s.NEXTVAL    po_interface_header_id
  ,DECODE(contract_number_modifier, null,
		contract_number,
		contract_number || ' - ' || contract_number_modifier)
                                     contract_number_print -- used to form the
									  -- comments in the PO Header
--  ,po_headers_s.NEXTVAL            po_header_id
FROM okc_k_headers_b
WHERE id = b_chr_id;


-- cursor to get line information for the top lines related to the contract

CURSOR c_top_cle(b_chr_id NUMBER) IS
SELECT
   cle.id          	source_cle_id             -- source for the PO line
  ,cim.object1_id1                            -- item_id
  ,cim.uom_code                               -- uom_code
  ,cim.number_of_items qty                    -- quantity
  ,cle.price_negotiated/cim.number_of_items   -- unit_price
  ,cle.price_unit                             -- list_price_per_unit
  ,trunc(greatest(cle.start_date, sysdate))   need_by_date
                           -- need by date cannot be earlier than sysdate according to a check
                           -- performed in PDOI. Logged bug 2166158 for this
FROM
	okc_k_lines_b		cle,
	okc_statuses_b      sts,
	okc_k_items		    cim
--	jtf_objects_b		jot                   -- (Sangeeta) not necessary to check the source
WHERE
	    cim.cle_id = cle.id
--AND   jot.object_code = cim.jtot_object1_code
AND     sts.code = cle.sts_code
AND	    cle.dnz_chr_id = b_chr_id
AND     sts.code in (g_sts_signed, g_sts_active)  -- only active and signed lines
AND     cle.cle_id IS NULL  -- only top lines
AND     cle.price_level_ind = 'Y'                 -- indicates this is a priced line
AND     cle.item_to_price_yn = 'Y'                -- indicates the item comes from inventory
ORDER BY cle.display_sequence;
----------------------------------------------------------------------------
--  Global Variables--------------------------------------------------------
----------------------------------------------------------------------------

G_USER_ID                 NUMBER;
G_LAST_UPDATE_LOGIN       NUMBER;
G_PROGRAM_ID              NUMBER;
G_PROGRAM_APPLICATION_ID  NUMBER;
G_REQUEST_ID              NUMBER;
g_chr                     c_chr%ROWTYPE;
g_unexp_error             exception;
g_error                   exception;


----------------------------------------------------------------------------
--  Global Type Declarations------------------------------------------------
----------------------------------------------------------------------------

-------------------------------------------------------------------------
-- rule_rec_typ holds the header and lines rules associated to a contract  (Aida change typ to type)
-------------------------------------------------------------------------

TYPE rule_rec_typ IS RECORD
  (
    chr_id                          okc_k_headers_b.id%TYPE
   ,cle_id                          okc_k_lines_b.id%TYPE
   ,object1_id1                     okc_rules_b.object1_id1%TYPE
   ,object1_id2                     okc_rules_b.object1_id2%TYPE
   ,jtot_object1_code               okc_rules_b.jtot_object1_code%TYPE
   ,object2_id1                     okc_rules_b.object2_id1%TYPE
   ,object2_id2                     okc_rules_b.object2_id2%TYPE
   ,jtot_object2_code               okc_rules_b.jtot_object2_code%TYPE
   ,rule_information_category       okc_rules_b.rule_information_category%TYPE
   ,rule_information1               okc_rules_b.rule_information1%TYPE
  );

-------------------------------------------------------------------------
-- po_header_rec_type holds the values that will be inserted in
-- po_headers_interface table
-- interface_header_id - Interface header unique identifier
-- document_type_code  - Document type to be created. In our case Standard PO
-- document_num        - number used to uniquely identify the PO in forms and reports
-- po_header_id        - primary key in po_headers_all table
-- agent_id            - buyer id
-------------------------------------------------------------------------

TYPE po_header_rec_type IS RECORD(
        interface_header_id      po_headers_interface.interface_header_id%type,
        org_id                   okc_k_headers_b.authoring_org_id%type,
        document_type_code       po_headers_interface.document_type_code%type,
        document_num             po_headers_interface.document_num%type,
        po_header_id             po_headers_interface.po_header_id%type,
        currency_code            okc_k_headers_b.currency_code%type,
        rate_type_code           okc_conversion_attribs_v.conversion_type%type,
        rate_date                okc_conversion_attribs_v.conversion_date%type,
        rate                     okc_conversion_attribs_v.conversion_rate%type,
        agent_id                 okx_buyers_v.id1%type,
        vendor_id                okx_vendors_v.id1%type,
        vendor_site_id           okx_vendor_sites_v.id1%type,
        vendor_contact_id        okc_contacts.object1_id1%type,
        ship_to_location_id      okc_rules_b.object1_id1%type,
        bill_to_location_id      okc_rules_b.object1_id1%type,
        terms_id                 okc_rules_b.object1_id1%type,
        freight_terms            okc_rules_b.object1_id1%type,
        approved_date            okc_k_headers_b.date_signed%type,
        ship_to_organization_id  okc_rules_b.object2_id1%type,
	   comments                 varchar2(100)  -- used to form the comments
									   -- with the contract number
        );

-------------------------------------------------------------------------
-- po_lines_rec_type holds the values that will be inserted in
-- po_lines_interface table
-- item_id             - Item unique identifier
-- unit_price          - Unit price for the line
-- list_price_per_unit - List price for the item on the line
-- need_by_date        - Date the goods are needed by
-- interface_line_id   - Interface line unique identifier
-- po_line_id          - primary key in po_lines_all table
-------------------------------------------------------------------------

TYPE po_lines_rec_type IS RECORD(
        source_cle_id              okc_k_lines_b.id%type,
        item_id                    okc_k_items.object1_id1%type,
        uom_code                   okc_k_items.uom_code%type,
        quantity                   okc_k_items.number_of_items%type,
        unit_price                 okc_k_lines_b.price_negotiated%type,
        list_price_per_unit        okc_k_lines_b.price_unit%type,
        need_by_date               okc_k_lines_b.start_date%type,
        interface_line_id          po_lines_interface.interface_line_id%type,
        po_line_id                 po_lines_interface.po_line_id%type,
        interface_header_id        po_headers_interface.interface_header_id%type,
        ship_to_organization_id    okc_rules_b.object1_id1%type,
        ship_to_location_id        okc_rules_b.object1_id1%type,
        terms_id                   okc_rules_b.object1_id1%type,
        freight_terms              okc_rules_b.object1_id1%type
        );

-------------------------------------------------------------------------
-- po_distributions_rec_type holds the values that will be inserted in
-- po_distributions_interface table
-- interface_distribution_id   - Interface line unique identifier
-- interface_line_id           - Unit price for the line
-------------------------------------------------------------------------

TYPE po_distributions_rec_type IS RECORD(
        interface_header_id        po_headers_interface.interface_header_id%type,
        interface_line_id          po_lines_interface.interface_line_id%type,
        interface_distribution_id  po_distributions_interface.interface_distribution_id%type,
        org_id                     okc_k_headers_b.authoring_org_id%type,
        quantity_ordered           okc_k_items.number_of_items%type,
	   charge_account_id          po_distributions_interface.charge_account_id%TYPE
        );


----------------------------------------------------------------------------
-- -- TABLE TYPES-----------------------------------------------------------
----------------------------------------------------------------------------

TYPE po_lines_tab IS TABLE OF po_lines_rec_type INDEX BY BINARY_INTEGER;

TYPE po_distributions_tab IS TABLE OF po_distributions_rec_type INDEX BY BINARY_INTEGER;

TYPE NumberTabTyp IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

TYPE DateTabTyp IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE Char30TabTyp IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;

TYPE Char3TabTyp IS TABLE OF VARCHAR2(3) INDEX BY BINARY_INTEGER;


------------------------------------------------------------------------------
---------------- Procedure: my_debug -------------------------
------------------------------------------------------------------------------
-- Purpose: Serves to log debug messages in the log file for the
-- concurrent request. Can be changed to print out dbms_output
-- statements if testing locally
--
-- Parameters: As specified below. Currently the level and module are
-- not used
--
-- Out Parameters: None
--
-------------------------------------------------------------------------------

PROCEDURE my_debug( p_msg    IN VARCHAR2,
				p_level  IN NUMBER   DEFAULT 1,
				p_module IN VARCHAR2 DEFAULT 'OKC') IS
 BEGIN

    fnd_file.put_line(fnd_file.log, g_pkg_filename ||':'||p_msg);
 -- okc_debug.Log(p_msg,p_level,p_module);
 -- dbms_output.put_line(substr(p_msg,1,240));

END my_debug;


--------------------------------------------------------------------------------
--  Private Procedures ---------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-------------- Procedure: set_notification_msg  --------------------------------
--------------------------------------------------------------------------------
-- Purpose: Sets the notification messages on the stack
--
-- Parameters: See specification below. No special parameters.
--
--------------------------------------------------------------------------------
PROCEDURE set_notification_msg (p_api_version                   IN NUMBER
                    	       ,p_init_msg_list                 IN VARCHAR2
		                   ,p_application_name              IN VARCHAR2
		                   ,p_message_subject               IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		                   ,p_message_body 	                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		                   ,p_message_body_token1 	    IN VARCHAR2
		                   ,p_message_body_token1_value     IN VARCHAR2
		                   ,p_message_body_token2 	    IN VARCHAR2
		                   ,p_message_body_token2_value     IN VARCHAR2
                               ,p_message_body_token3 	    IN VARCHAR2
		                   ,p_message_body_token3_value     IN VARCHAR2
		                   ,x_return_status   	          OUT NOCOPY VARCHAR2) IS

l_init_msg_count        NUMBER:=0;

BEGIN

  my_debug('4000: Entered set_notification_msg', 2);

  my_debug('4010: Initialize Error Message List', 2);

  okc_api.init_msg_list(p_init_msg_list => p_init_msg_list);

  l_init_msg_count:=fnd_msg_pub.count_msg;

  my_debug('4020: Set Notification Messages on the stack', 2);


 -- Checking on subject and body message codes not null

  IF  NVL(p_message_body,OKC_API.G_MISS_CHAR) = OKC_API.G_MISS_CHAR OR
      NVL(p_message_subject,OKC_API.G_MISS_CHAR) = OKC_API.G_MISS_CHAR
  THEN
	OKC_API.set_message(p_app_name	=> p_application_name,
			        p_msg_name	=> 'OKC_K_NO_MSG_NOTIF');

	RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

  ELSE
	IF NVL(p_message_subject,OKC_API.G_MISS_CHAR) <> OKC_API.G_MISS_CHAR
	THEN
		my_debug('4030: Setting subject message on the stack', 2);

		OKC_API.set_message(p_app_name	=> p_application_name
			         ,p_msg_name	=> p_message_subject
				   ,p_token1	=> p_message_body_token1
				   ,p_token1_value => p_message_body_token1_value
                                   ,p_token2	   => p_message_body_token2
				   ,p_token2_value => p_message_body_token2_value
                                   ,p_token3	   => p_message_body_token3
				   ,p_token3_value => p_message_body_token3_value
				   );
	END IF;

	IF NVL(p_message_body,OKC_API.G_MISS_CHAR) <> OKC_API.G_MISS_CHAR
	THEN
		my_debug('4040: Setting body message on the stack', 2);

		OKC_API.set_message(p_app_name	   => p_application_name
			  	   ,p_msg_name	   => p_message_body
				   ,p_token1	   => p_message_body_token1
				   ,p_token1_value => p_message_body_token1_value
				   ,p_token2	   => p_message_body_token2
				   ,p_token2_value => p_message_body_token2_value
                                   ,p_token3	   => p_message_body_token3
				   ,p_token3_value => p_message_body_token3_value
                                   );
	END IF;
  END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  my_debug('4040: Exiting set_notification_msg', 2);


EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKC_API.G_RET_STS_ERROR;

  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME
                       ,G_UNEXPECTED_ERROR
                       ,G_SQLCODE_TOKEN
                       ,SQLCODE
                       ,G_SQLERRM_TOKEN
                       ,SQLERRM);
END set_notification_msg;

--------------------------------------------------------------------------------
-------------- Procedure: notify_buyer  ------------------------------
--------------------------------------------------------------------------------
-- Purpose: Notify the buyer of a purchase order creation
--
-- Parameters: See specification below. No special parameters.
--
--------------------------------------------------------------------------------

    PROCEDURE notify_buyer(p_api_version                    IN NUMBER
                          ,p_init_msg_list                  IN VARCHAR2
                          ,p_application_name               IN VARCHAR2
		       	  ,p_message_subject                IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		       	  ,p_message_body 	            IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE
		       	  ,p_message_body_token1 	      IN VARCHAR2
		       	  ,p_message_body_token1_value      IN VARCHAR2
		       	  ,p_message_body_token2 	      IN VARCHAR2
		       	  ,p_message_body_token2_value      IN VARCHAR2
                          ,p_message_body_token3 	      IN VARCHAR2
		       	  ,p_message_body_token3_value      IN VARCHAR2
		       	  ,p_chr_id                         IN OKC_K_HEADERS_B.ID%TYPE
                          ,x_k_buyer_name                   OUT NOCOPY VARCHAR2
                          ,x_return_status   		      OUT NOCOPY VARCHAR2
                          ,x_msg_count                      OUT NOCOPY NUMBER
                          ,x_msg_data                       OUT NOCOPY VARCHAR2) IS

  -- standard api variables
  l_api_version           CONSTANT NUMBER := 1;
  l_api_name              CONSTANT VARCHAR2(30) := 'notify_buyer';
  lx_return_status        VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  lx_msg_count            NUMBER := 0;
  lx_msg_data             VARCHAR2(2000);
  l_init_msg_count        NUMBER:=0;

  l_notif_flag            VARCHAR2(1):=OKC_API.g_false;
  l_send_notif            VARCHAR2(1):=OKC_API.g_false;
  l_notification_string   VARCHAR2(4000);
  l_k_buyer_name          fnd_user.user_name%TYPE;



BEGIN

  my_debug('5010: Entered notify_buyer', 2);

  my_debug('5010: Initialize error message list', 2);

  okc_api.init_msg_list(p_init_msg_list => p_init_msg_list);

  l_init_msg_count:=fnd_msg_pub.count_msg;


     -- Notify the buyer of a po creation
     -- Call the workflow notification alert */

         SELECT user_name
           INTO l_k_buyer_name
           FROM FND_USER
           WHERE EMPLOYEE_ID = (SELECT cco.object1_id1 agent_id
			    FROM   okc_contacts      cco
			    WHERE  cco.cro_code = 'BUYER'
		            AND    cco.jtot_object1_code = 'OKX_BUYER'
			    AND    cco.dnz_chr_id   = p_chr_id
			    AND    rownum = 1)
	   AND rownum = 1;


           IF SQL%FOUND AND NVL(l_k_buyer_name, okc_api.g_miss_char) <> okc_api.g_miss_char THEN

              my_debug('5020: Buyer name' || l_k_buyer_name , 2);

              l_send_notif := OKC_API.G_TRUE;

	      x_k_buyer_name := l_k_buyer_name;

           ELSE

              l_send_notif := OKC_API.G_FALSE;

              OKC_API.set_message(p_app_name      => g_app_name, --OKC
                                  p_msg_name      => 'OKC_K_NOKBUYER',
                                  p_token1        => 'KNUMBER',
                                  p_token1_value  => p_chr_id);

           END IF;


     IF l_send_notif = OKC_API.g_true THEN

        -- Prepare the procedure to be executed through the
        -- workflow alert system

        -- The construction of the string is based on the parameters passed

       l_notification_string := 'BEGIN OKC_CREATE_PO_FROM_K_PVT.set_notification_msg(' ||
             'p_api_version      =>1'||
            ',p_init_msg_list    =>'||''''||p_init_msg_list||''''||
            ',p_application_name =>'||''''||p_application_name||''''||
            ',p_message_subject  =>'||''''||p_message_subject ||''''||
            ',p_message_body     =>'||''''||p_message_body||'''' ;


        IF NVL(p_message_body_token1, OKC_API.G_MISS_CHAR) <>
               OKC_API.G_MISS_CHAR AND
           NVL(p_message_body_token1_value, OKC_API.G_MISS_CHAR) <>
               OKC_API.G_MISS_CHAR THEN
           l_notification_string := l_notification_string||',p_message_body_token1 =>' ||''''|| p_message_body_token1 ||'''';
           l_notification_string := l_notification_string||',p_message_body_token1_value =>' ||''''|| p_message_body_token1_value ||'''';
        END IF;
        IF NVL(p_message_body_token2, OKC_API.G_MISS_CHAR) <>
               OKC_API.G_MISS_CHAR AND
           NVL(p_message_body_token2_value, OKC_API.G_MISS_CHAR) <>
               OKC_API.G_MISS_CHAR THEN
           l_notification_string := l_notification_string||',p_message_body_token2 =>' ||''''|| p_message_body_token2 ||'''';
           l_notification_string := l_notification_string||',p_message_body_token2_value =>' ||''''|| p_message_body_token2_value ||'''';
        END IF;
        IF NVL(p_message_body_token3, OKC_API.G_MISS_CHAR) <>
               OKC_API.G_MISS_CHAR AND
           NVL(p_message_body_token3_value, OKC_API.G_MISS_CHAR) <>
               OKC_API.G_MISS_CHAR THEN
           l_notification_string := l_notification_string||',p_message_body_token3 =>' ||''''|| p_message_body_token3 ||'''';
           l_notification_string := l_notification_string||',p_message_body_token3_value =>' ||''''|| p_message_body_token3_value ||'''';
        END IF;

        l_notification_string := l_notification_string||',x_return_status   => :1); END;';


        -- Submit the procedure to the workflow alert system once to notify the buyer


		IF NVL(l_k_buyer_name, okc_api.g_miss_char) <> okc_api.g_miss_char THEN


		my_debug('5030: Notify the buyer' , 2);

		my_debug('5040: Call OKC_ASYNC_PUB' , 2);

		my_debug('5050: Notification string = ' || l_notification_string , 2);


        	OKC_ASYNC_PUB.loop_call(p_api_version   => 1,
                                	p_proc          => l_notification_string,
                                	p_s_recipient   => l_k_buyer_name,
                                    p_e_recipient   => l_k_buyer_name,
					      p_contract_id   => p_chr_id,
                                	x_return_status => lx_return_status,
                                	x_msg_count     => lx_msg_count,
                                	x_msg_data      => lx_msg_data
                                	);


		my_debug('5060: End OKC_ASYNC_PUB' , 2);

		my_debug('5070: Return status: ' || lx_return_status, 2);


        	IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR OR
            		lx_return_status = OKC_API.G_RET_STS_ERROR) THEN

           		okc_api.set_message(p_app_name      => g_app_name,
                             	    p_msg_name      => 'OKC_K_BUYER_NOTIFFAILURE',
                            	    p_token1        => 'KBUYER',
                                  p_token1_value  => l_k_buyer_name);

        	END IF;

        	IF (lx_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN

           		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;

        	ELSIF (lx_return_status = OKC_API.G_RET_STS_ERROR) THEN

           		RAISE OKC_API.G_EXCEPTION_ERROR;

        	END IF;

	END IF; -- IF NVL(l_k_buyer_name, okc_api.g_miss_char) <> okc_api.g_miss_char


   END IF; -- IF l_send_notif = OKC_API.g_true THEN

  my_debug('5080: INITIALIZE ERROR MESSAGE OUT NOCOPY VARIABLES' , 2);

  FND_MSG_PUB.Count_And_Get (
               p_count =>      x_msg_count,
               p_data  =>      x_msg_data);

  x_msg_count:=x_msg_count - l_init_msg_count;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;



EXCEPTION
  WHEN OKC_API.G_EXCEPTION_ERROR THEN

    x_return_status := OKC_API.G_RET_STS_ERROR;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
                             ,p_procedure_name => l_api_name
                             ,p_error_text     => 'Encountered error condition'
                             );
    END IF;

    FND_MSG_PUB.Count_And_Get (
                p_count =>      x_msg_count,
                p_data  =>      x_msg_data);
    x_msg_count:=x_msg_count - l_init_msg_count;

  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_msg_pub.add_exc_msg(p_pkg_name       => g_pkg_name
                             ,p_procedure_name => l_api_name
                             ,p_error_text     => 'Encountered unexpected error'
                             );
    END IF;

    FND_MSG_PUB.Count_And_Get (
                p_count =>      x_msg_count,
                p_data  =>      x_msg_data);
    x_msg_count:=x_msg_count - l_init_msg_count;

  WHEN OTHERS THEN
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    OKC_API.set_message(G_APP_NAME
                       ,G_UNEXPECTED_ERROR
                       ,G_SQLCODE_TOKEN
                       ,SQLCODE
                       ,G_SQLERRM_TOKEN
                       ,SQLERRM);

    FND_MSG_PUB.Count_And_Get (
                p_count =>      x_msg_count,
                p_data  =>      x_msg_data);
    x_msg_count:=x_msg_count - l_init_msg_count;

END notify_buyer;

------------------------------------------------------------------------------
------------------- Procedure: get_k_rules --------------------------
------------------------------------------------------------------------------
-- Purpose: Gets the header and lines rules associated to a contract
--
-- In Parameters: p_chr_id	Contract header id
-- 		          p_cle_id	Topline id
--
-- In Out Parameters: px_po_header_rec   Record to hold po header interface data
--                    px_po_lines_rec    Record to hold po line interface data
--
-- Out Parameters: x_return_status  Standard return status
--
-- Note: QA check must ensure that the occurrence of any rule does not happen
-- more than once per header or line.
-------------------------------------------------------------------------------

PROCEDURE get_k_rules(p_chr_id 	         IN  okc_k_headers_b.ID%TYPE,
			          p_cle_id           IN  okc_k_lines_v.id%TYPE,
			          px_po_header_rec   IN OUT NOCOPY po_header_rec_type,
			          px_po_lines_rec    IN OUT NOCOPY po_lines_rec_type,
			          x_return_status    OUT NOCOPY VARCHAR2 ) IS

-- cursor to get rule information related to the Contract

CURSOR c_rules (b_chr_id NUMBER,
		b_cle_id NUMBER) IS SELECT
   rgp.chr_id
  ,rgp.cle_id
  ,rul.object1_id1
  ,rul.object1_id2
  ,rul.jtot_object1_code
  ,rul.object2_id1
  ,rul.object2_id2
  ,rul.jtot_object2_code
  ,rul.rule_information_category
  ,rul.rule_information1
FROM okc_rule_groups_b    rgp
    ,okc_rules_b          rul
WHERE
  rgp.dnz_chr_id         = b_chr_id
AND rul.rgp_id         = rgp.id
AND ((rgp.cle_id IS NULL AND b_cle_id IS NULL) OR
    (b_cle_id IS NOT NULL AND rgp.cle_id = b_cle_id))
AND ((rgp.rgd_code = g_rg_billing  and rul.rule_information_category = g_ru_billto) or
    (rgp.rgd_code = g_rg_shipping and rul.rule_information_category = g_ru_shipto) or
    (rgp.rgd_code = g_rg_payment  and rul.rule_information_category = g_ru_payto) or
    (rgp.rgd_code = g_rg_payment  and rul.rule_information_category = g_ru_payterms) or
    (rgp.rgd_code = g_rg_currency and rul.rule_information_category = g_ru_convert));


-- cursor to get exchange rate information

CURSOR c_conv_type (b_id1 VARCHAR2) IS
SELECT conversion_type,
       conversion_rate,
       conversion_date
FROM   okc_conversion_attribs_v
WHERE  conversion_type = b_id1
AND    dnz_chr_id = p_chr_id;



l_ru_h_nb        NUMBER;        -- count number of rules at header level
l_ru_l_nb        NUMBER;        -- count number of rules at line level



BEGIN

  l_ru_h_nb := 0;
  l_ru_l_nb := 0;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('get_k_rules');
    END IF;

    my_debug('20: Entering get_k_rules', 2);

    x_return_status := OKC_API.G_RET_STS_SUCCESS;


-- rule selection

FOR r_rule IN c_rules(p_chr_id, p_cle_id) LOOP

EXIT WHEN c_rules%NOTFOUND;


  -- rule at header level only

  IF p_cle_id IS NULL THEN

    IF r_rule.rule_information_category = g_ru_payto THEN

	    -- get vendor site id

	    px_po_header_rec.vendor_site_id := r_rule.object1_id1;

        my_debug('40: Rule selected: '||g_ru_payto, 1);

        my_debug('60: Vendor Site Id: '||r_rule.object1_id1, 1);

        l_ru_h_nb:=l_ru_h_nb + 1;

    END IF;

  END IF;


 -- rule at header level only

  IF p_cle_id IS NULL THEN

    IF r_rule.rule_information_category = g_ru_billto THEN

        -- get bill to location id

        px_po_header_rec.bill_to_location_id := r_rule.object1_id1;

        my_debug('80: Rule selected: '|| g_ru_billto, 1);

        my_debug('100: Bill To Location Id: '||r_rule.object1_id1, 1);

        l_ru_h_nb:=l_ru_h_nb + 1;

    END IF;

 END IF;


  -- rule at header level only

   IF p_cle_id IS NULL THEN

     IF r_rule.rule_information_category = g_ru_convert THEN

         -- get rate, rate_type, rate_type_code and rate_date

    	   OPEN c_conv_type(r_rule.object1_id1);
           FETCH c_conv_type INTO px_po_header_rec.rate_type_code,
                                  px_po_header_rec.rate,
                                  px_po_header_rec.rate_date;
           CLOSE c_conv_type;

           my_debug('120: Rule selected: '|| g_ru_convert, 1);

           my_debug('140: Rate type Code: '|| px_po_header_rec.rate_type_code, 1);

           my_debug('160: Rate: '|| px_po_header_rec.rate, 1);

           my_debug('180: Rate date: '|| px_po_header_rec.rate_date, 1);

           l_ru_h_nb:=l_ru_h_nb + 1;

     END IF;

    END IF;


 -- rule at both header and line level

    IF r_rule.rule_information_category = g_ru_payterms THEN

   	    IF p_cle_id IS NULL THEN  -- get header rule

            -- get terms id

            px_po_header_rec.terms_id := r_rule.object1_id1;

            my_debug('200: Rule selected: '|| g_ru_payterms, 1);

            my_debug('220: Terms Id: '|| px_po_header_rec.terms_id, 1);

            l_ru_h_nb:=l_ru_h_nb + 1;

         ELSE

            -- get terms id

   	        px_po_lines_rec.terms_id := nvl(r_rule.object1_id1, px_po_header_rec.terms_id);

            my_debug('240: Rule selected: '|| g_ru_payterms, 1);

            my_debug('260: Terms Id: '|| px_po_lines_rec.terms_id, 1);

            l_ru_l_nb:=l_ru_l_nb + 1;

   	    END IF;

     END IF;


 -- rule at both header and line level

    IF r_rule.rule_information_category = g_ru_shipto THEN

	    IF p_cle_id IS NULL THEN  -- get header rule

    	    -- get ship to location id

            px_po_header_rec.ship_to_location_id  := r_rule.object1_id1;

            px_po_header_rec.ship_to_organization_id  := r_rule.object2_id1;

            my_debug('280: Rule selected: '|| g_ru_shipto, 1);

            my_debug('300: Ship To Location Id  : '|| px_po_header_rec.ship_to_location_id, 1);

    	    l_ru_h_nb:=l_ru_h_nb + 1;

        ELSE

             -- get ship to location id  and ship to organization id

             px_po_lines_rec.ship_to_location_id      := nvl(r_rule.object1_id1,px_po_header_rec.ship_to_location_id);

             px_po_lines_rec.ship_to_organization_id  := nvl(r_rule.object2_id1,px_po_header_rec.ship_to_organization_id);

             my_debug('320: Rule selected: '|| g_ru_shipto, 1);

             my_debug('340: Ship To Location Id  : '|| px_po_lines_rec.ship_to_location_id, 1);

             my_debug('360: Ship To Organization Id  : '|| px_po_lines_rec.ship_to_organization_id, 1);

             l_ru_l_nb:=l_ru_l_nb + 1;


        END IF;

      END IF;


 END LOOP;


    IF p_cle_id IS NULL THEN
        my_debug('380: Rules selection: '||l_ru_h_nb||' rule(s) selected at header level', 1);
    ELSE
        my_debug('400: Rules selection: '||l_ru_l_nb||' rule(s) selected at line level', 1);
    END IF;

    my_debug('420: Exiting get_k_rules', 2);

    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
WHEN OTHERS THEN
             my_debug('440: error'||substr(sqlerrm,1,240));
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            my_debug('460: Exiting get_k_rules', 2);
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

     IF c_rules%ISOPEN THEN
        CLOSE c_rules;
     END IF;

     IF c_conv_type%ISOPEN THEN
        CLOSE c_conv_type;
     END IF;

END get_k_rules;

--------------------------------------------------------------------------------
-------------- Procedure: get_k_info ----------------------------
------------------------------------------------------------------------------------
-- Purpose:             Gets the relevant contract info at header and line
-- level to populate po headers record, po lines table and po distributions table
--
-- In Parameters:       p_chr_id        Contract header id
--
-- Out Parameters:      x_return_status Standard return status
--                      x_po_header_rec Record to hold po header interface data
--                      x_po_lines_tab  Table to hold po lines interface data
--                      x_po_dist_tab   Table to hold po distributions interface data
--------------------------------------------------------------------------------

PROCEDURE get_k_info (p_chr_id        IN  okc_k_headers_b.ID%TYPE
  	                 ,x_return_status OUT NOCOPY VARCHAR2
                     ,x_po_header_rec OUT NOCOPY po_header_rec_type
                     ,x_po_lines_tab  OUT NOCOPY po_lines_tab
                     ,x_po_dist_tab   OUT NOCOPY po_distributions_tab) IS



contract_not_found  exception;
e_exit              exception;
l_idx               pls_integer :=0;     -- generic table index
po_lines_rec        po_lines_rec_type;   -- record to hold po line interface data
po_header_rec       po_header_rec_type;  -- record to hold po header interface data
l_return_status     VARCHAR2(100);       -- standard return status
l_cpr_id            NUMBER;              -- to hold k_party_roles id

BEGIN


-- get contract information

-- get contract header information

   IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation('get_k_info');
   END IF;

   my_debug('480: Entering get_k_info', 2);

   x_return_status := OKC_API.G_RET_STS_SUCCESS;

OPEN c_chr(p_chr_id);

FETCH c_chr INTO g_chr;

  IF c_chr%NOTFOUND THEN
    -- no header is a fatal error
    raise contract_not_found;
    CLOSE c_chr;

  END IF;

CLOSE c_chr;


    x_po_header_rec.org_id                := g_chr.authoring_org_id;
    x_po_header_rec.currency_code         := g_chr.currency_code;
    x_po_header_rec.approved_date         := g_chr.approved_date;
    x_po_header_rec.interface_header_id   := g_chr.po_interface_header_id;

-- The contract number is to be displayed in the comments column of
-- the PO Header. Format it using a message

     fnd_message.set_name('OKC','OKC_PO_CREATED_FROM_K_COMMENT');
     fnd_message.set_token('CONTRACT_NUMBER_PRINT',g_chr.contract_number_print);
     x_po_header_rec.comments    := fnd_message.get;

    my_debug('500: Interface Header Id: '||g_chr.po_interface_header_id, 1);
    my_debug('520: Contract org id:'||g_chr.authoring_org_id, 1);
    my_debug('540: Contract currency code:'||g_chr.currency_code, 1);
    my_debug('560: Contract approved date:'||g_chr.approved_date, 1);


-- select to get agent_id
-- This will probably change for phase II when we derive the buyer from the item

BEGIN

SELECT cco.object1_id1 agent_id
INTO   x_po_header_rec.agent_id
FROM   okc_contacts      cco
WHERE  cco.cro_code = 'BUYER'
AND    cco.jtot_object1_code = 'OKX_BUYER'
AND    cco.dnz_chr_id   = p_chr_id
AND    rownum = 1;                          -- added - just in case there is more than one contact defined

EXCEPTION
  WHEN no_data_found THEN
       my_debug('580: buyer not found', 1);
       raise g_unexp_error;
END;


-- select to get vendor information. QA check will guarantee there will be only one vendor for a contact

BEGIN

SELECT cpr.object1_id1   vendor_id,
       cpr.id
INTO   x_po_header_rec.vendor_id,
       l_cpr_id
FROM okc_k_party_roles_b cpr
WHERE
      cpr.rle_code          = 'VENDOR'
  AND cpr.jtot_object1_code = 'OKX_VENDOR'
  AND cpr.cle_id              IS NULL              -- header level vendors only
  AND cpr.dnz_chr_id        = p_chr_id;

EXCEPTION
   WHEN no_data_found THEN
       my_debug('600: vendor not found', 1);
       raise g_unexp_error;
END;


-- select to get vendor_contact information

BEGIN

SELECT cco.object1_id1  vendor_contact_id
INTO   x_po_header_rec.vendor_contact_id
FROM   okc_contacts     cco
WHERE  cco.cpl_id       = l_cpr_id
AND    cco.dnz_chr_id   = p_chr_id
AND    cco.jtot_object1_code = 'OKX_VCONTACT'
AND    rownum = 1;                             -- added - just in case there is more than one contact defined
EXCEPTION
   WHEN no_data_found THEN
       my_debug('620: vendor contact not found', 1);
END;


-- call get_k_rules to get rules related to this K at the header level


      my_debug('640: Before calling get_k_rules at header level', 1);

      get_k_rules (p_chr_id               => p_chr_id,
                   p_cle_id               => NULL,
                   px_po_header_rec       => x_po_header_rec,
                   px_po_lines_rec        => po_lines_rec,
                   x_return_status        => l_return_status );

       my_debug('660: after calling get_k_rules at header level. Status :'||l_return_status, 1);


       IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
            Raise g_unexp_error;
       ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
            Raise g_error;
       END IF;


-- get contract top lines information


OPEN c_top_cle(p_chr_id);
LOOP
    l_idx := l_idx + 1;

    FETCH c_top_cle
	INTO x_po_lines_tab(l_idx).source_cle_id,
		x_po_lines_tab(l_idx).item_id,
		x_po_lines_tab(l_idx).uom_code,
          x_po_lines_tab(l_idx).quantity,
		x_po_lines_tab(l_idx).unit_price,
		x_po_lines_tab(l_idx).list_price_per_unit,
          x_po_lines_tab(l_idx).need_by_date;

IF c_top_cle%NOTFOUND THEN
	IF l_idx = 1 THEN
      	my_debug('680: contract has no lines', 1);
	END IF;
	EXIT;
END IF;


     x_po_lines_tab(l_idx).interface_header_id := x_po_header_rec.interface_header_id;

     -- making this select separately as I got an error when selecting po_lines_interface_s.NEXTVAL in the c_top_cle cursor above

     SELECT po_lines_interface_s.NEXTVAL
	  INTO x_po_lines_tab(l_idx).interface_line_id
	  FROM dual;

     x_po_dist_tab(l_idx).interface_header_id := x_po_header_rec.interface_header_id;

     x_po_dist_tab(l_idx).interface_line_id := x_po_lines_tab(l_idx).interface_line_id;

     x_po_dist_tab(l_idx).org_id := x_po_header_rec.org_id;

     x_po_dist_tab(l_idx).quantity_ordered := x_po_lines_tab(l_idx).quantity;


-- Select the charge account from Inventory. This is a temporary fix
-- because PDOI currently forces you to give a charge account. Ideally
-- this should be derived by PDOI. Log bug <bugNo>

 BEGIN

   SELECT  expense_account
	INTO  x_po_dist_tab(l_idx).charge_account_id
	FROM  okx_system_items_v
    WHERE  inventory_item_id =  x_po_lines_tab(l_idx).interface_line_id
	 AND  organization_id = SYS_CONTEXT('OKC_CONTEXT','ORGANIZATION_ID');

 EXCEPTION
   WHEN no_data_found
   THEN
-- This is highly temporary for the demo. Ideally the exception should
-- be handled.
	   x_po_dist_tab(l_idx).charge_account_id := 13401;
 END;


     my_debug('700: Contract Line Info:', 1);

     my_debug('720: contract line id:'|| x_po_lines_tab(l_idx).source_cle_id, 1);

     my_debug('740: item id:'|| x_po_lines_tab(l_idx).item_id, 1);

     my_debug('760: uom code:'|| x_po_lines_tab(l_idx).uom_code, 1);

     my_debug('780: quantity:'|| x_po_lines_tab(l_idx).quantity, 1);

     my_debug('800: unit price:'|| x_po_lines_tab(l_idx).unit_price, 1);

     my_debug('820: list price per unit:'|| x_po_lines_tab(l_idx).list_price_per_unit, 1);

     my_debug('840: need by date:'|| x_po_lines_tab(l_idx).need_by_date, 1);

     my_debug('860: Before calling get_k_rules at line level', 1);


-- call get_k_rules to to get rules related to this K at the lines level


     get_k_rules(p_chr_id               => p_chr_id,
                 p_cle_id               =>  x_po_lines_tab(l_idx).source_cle_id,
                 px_po_header_rec       => po_header_rec,
                 px_po_lines_rec        => x_po_lines_tab(l_idx),
                 x_return_status        => l_return_status );



     my_debug('880: after calling get_k_rules at line level. Status :'||l_return_status, 1);

     IF l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR THEN
        Raise g_unexp_error;
     ELSIF l_return_status = OKC_API.G_RET_STS_ERROR THEN
        Raise g_error;
     END IF;


END LOOP;
CLOSE c_top_cle;


    my_debug('900: Exiting get_k_info', 2);
    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
    WHEN contract_not_found THEN

        x_return_status := OKC_API.G_RET_STS_ERROR;
        okc_api.set_message(OKC_API.G_APP_NAME,'OKC_K2O_NOKHDR');
        my_debug('920: Exiting get_k_info', 2);
        IF (l_debug = 'Y') THEN
           okc_debug.Reset_Indentation;
        END IF;

    WHEN g_error THEN

        x_return_status := OKC_API.G_RET_STS_ERROR;

        IF c_chr%ISOPEN THEN
    		 CLOSE c_chr;
	    END IF;

        IF c_top_cle%ISOPEN THEN
	    	 CLOSE c_top_cle;
	    END IF;

       my_debug('940: Exiting get_k_info', 2);
       IF (l_debug = 'Y') THEN
          okc_debug.Reset_Indentation;
       END IF;

     WHEN g_unexp_error THEN

         x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

         IF c_chr%ISOPEN THEN
    		 CLOSE c_chr;
	     END IF;

         IF c_top_cle%ISOPEN THEN
    		 CLOSE c_top_cle;
	     END IF;

         my_debug('960: Exiting get_k_info', 2);
         IF (l_debug = 'Y') THEN
            okc_debug.Reset_Indentation;
         END IF;

      WHEN OTHERS THEN
          my_debug('980: error'||substr(sqlerrm,1,240));
          OKC_API.set_message(p_app_name      => g_app_name,
                              p_msg_name      => g_unexpected_error,
                              p_token1        => g_sqlcode_token,
                              p_token1_value  => sqlcode,
                              p_token2        => g_sqlerrm_token,
                              p_token2_value  => sqlerrm);
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

          IF c_chr%ISOPEN THEN
		     CLOSE c_chr;
	      END IF;

          IF c_top_cle%ISOPEN THEN
		     CLOSE c_top_cle;
	       END IF;

          my_debug('1000: Exiting get_k_info', 2);
          IF (l_debug = 'Y') THEN
             okc_debug.Reset_Indentation;
          END IF;

END get_k_info;

--------------------------------------------------------------------------------
------------- Procedure: insert_po_hdr ---------------------
--------------------------------------------------------------------------------
-- Purpose: Populate purchase order headers interface table and create
-- related objects for the header
--
-- In Parameters:
--                      p_batch_id       Batch id of records to be inserted
--                      p_po_header_rec  Record to hold po header interface data
--
-- Out Parameters:      x_return_status  Standard return status
--                      x_po_header_id   This is a temporary parameter
--                                       that needs to be here because of a
--                                       bug in PO (PDOI does not accept
--                                       po_line_id).  Hence the related objects
--                                       for lines is created with po_header_id
--                                       and line_num.  The po_header_id generated
--                                       in this procedure is passed to the
--                                       insert_po_lines procedure
-----------------------------------------------------------------------------------

PROCEDURE insert_po_hdr(
                            p_chr_id            IN   NUMBER
			   ,p_batch_id          IN   NUMBER
			   ,p_po_header_rec     IN   po_header_rec_type
                           ,x_return_status     OUT NOCOPY VARCHAR2
		          ,x_po_header_id      OUT NOCOPY po_headers_all.po_header_id%TYPE) IS


l_po_null_rec     po_header_rec_type;  -- initialize to null

l_po_header_id    number;   -- Identifier of the PO Header being created

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('insert_po_hdr');
    END IF;

    my_debug('1020: Entering insert_po_hdr', 2);

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    my_debug('1040: Batch id = ' || p_batch_id, 2);

-- Select the PO Header id so that it can be populated in related
-- objects and can be logged
    SELECT po_headers_s.nextval
	 INTO l_po_header_id
	 FROM dual;

    my_debug('1060: po_header_id : ' || l_po_header_id,2);
    x_po_header_id := l_po_header_id;

    INSERT INTO po_headers_interface
    (
        batch_id,
        interface_header_id,
        interface_source_code,
        process_code,
        action,
        org_id,
        document_type_code,
    --  document_num,        -- will not be providing for phase I as the setup in demo env. will be set to manual and numbering is numeric
        po_header_id,
        currency_code,
        rate_type_code,
        rate_date,
        rate,
        agent_id,
        vendor_id,
        vendor_site_id,
        vendor_contact_id,
        ship_to_location_id,
        bill_to_location_id,
        terms_id,
        freight_terms,
        approval_status,
        approved_date,
        acceptance_required_flag,
        frozen_flag,
        approval_required_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date,
        comments
    )
    VALUES
    (
        p_batch_id,                           -- batch_id
        p_po_header_rec.interface_header_id,  -- interface_header_id
        g_po_hdr_interface_source_code,       -- interface_source_code
        g_po_hdr_process_code,                -- process_code
        g_po_hdr_action,                      -- action
        p_po_header_rec.org_id,               -- org_id
        g_po_hdr_document_type_code,          -- document_type_code
 --     p_po_header_rec.document_num,         -- document_num
        l_po_header_id,                       -- po_header_id
        p_po_header_rec.currency_code,        -- currency_code
        p_po_header_rec.rate_type_code,       -- rate_type_code
        p_po_header_rec.rate_date,            -- rate_date
        p_po_header_rec.rate,                 -- rate
        p_po_header_rec.agent_id,             -- agent_id
        p_po_header_rec.vendor_id,            -- vendor_id
        p_po_header_rec.vendor_site_id,       -- vendor_site_id
        p_po_header_rec.vendor_contact_id,    -- vendor_contact_id
        p_po_header_rec.ship_to_location_id,  -- ship_to_location_id
        p_po_header_rec.bill_to_location_id,  -- bill_to_location_id
        p_po_header_rec.terms_id,             -- terms_id
        p_po_header_rec.freight_terms,        -- freight_terms
        g_po_hdr_approval_status,             -- approval_status
        p_po_header_rec.approved_date,        -- approved_date
        g_po_hdr_accept_required_flag,        -- acceptance_required_flag
        g_po_hdr_frozen_flag,                 -- frozen_flag
        g_po_hdr_approv_required_flag,        -- approval_required_flag
        sysdate,                              -- creation_date
        G_USER_ID,                            -- created_by
        sysdate,                              -- last_update_date
        G_USER_ID,                            -- last_updated_by
        G_LAST_UPDATE_LOGIN,                  -- last_update_login
        G_REQUEST_ID,                         -- request_id
        G_PROGRAM_APPLICATION_ID,             -- program_application_id
        G_PROGRAM_ID,                         -- program_id
        sysdate,                              -- program_update_date
        p_po_header_rec.comments              -- comments
    );



-- here create the relationship from the po to the contract
-- Insert record into OKC_K_REL_OBJS to record the link between the
-- Contract header and PO header. Currently, this is a direct insert.

  INSERT  INTO OKC_K_REL_OBJS
  ( id,
    cle_id,
    chr_id,
    rty_code,
    object1_id1,
    object1_id2,
    jtot_object1_code,
    object_version_number,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
  )
  VALUES
  (
    okc_p_util.raw_to_number(sys_guid()) -- id
    ,null                    -- cle_id
    ,p_chr_id                -- chr_id
    ,g_crj_rty_code          -- rty_code
    ,l_po_header_id          -- object1_id1
    ,'#'                     -- object1_id2
    ,g_crj_chr_jtot_object_code  -- jtot_object1_code
    ,1                       -- object_version_number
    ,G_USER_ID               -- created_by
    ,sysdate                 -- creation_date
    ,G_USER_ID               -- last_updated_by
    ,sysdate                 -- last_update_date
    ,g_last_update_login     -- last_update_login
  );


 my_debug('1080: Inserted rows into OKC_K_REL_OBJS for Header: ' || sql%ROWCOUNT , 4);

-- cleanup

   --  p_po_header_rec :=  l_po_null_rec; -- uncomment this line when create relationship from po to contract above is done

   my_debug('1100: Exiting insert_po_hdr', 2);

   IF (l_debug = 'Y') THEN
      okc_debug.Reset_Indentation;
   END IF;

EXCEPTION
WHEN OTHERS THEN
          my_debug('1120: error'||substr(sqlerrm,1,240));
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            my_debug('1140: Exiting insert_po_hdr', 4);
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;


END insert_po_hdr;

--------------------------------------------------------------------------------
------------- Procedure: insert_po_lines ---------------------
--------------------------------------------------------------------------------
-- Purpose: Populate purchase order lines interface table and create
-- related objects for lines
--
-- In Parameters:   p_po_lines_tab   Table to hold po lines interface data
--
-- Out Parameters:  x_return_status  Standard return status
----------------------------------------------------------------------------

PROCEDURE insert_po_lines(p_chr_id         IN  okc_k_headers_b.id%TYPE
					,p_po_lines_tab   IN  po_lines_tab
					,p_po_header_id   IN  po_lines_all.po_header_id%TYPE
                         ,x_return_status  OUT NOCOPY VARCHAR2) IS


-- Declaration of individual elements to avoid ORA-3113 error because
-- FORALL does not allow insert of elements of %rowtype

    ls_freight_terms             Char30TabTyp;
    ls_interface_header_id       NumberTabTyp;
    ls_interface_line_id         NumberTabTyp;
    ls_item_id                   NumberTabTyp;
    ls_line_num                  NumberTabTyp;
    ls_list_price_per_unit       NumberTabTyp;
    ls_need_by_date              DateTabTyp;
    ls_po_line_id                NumberTabTyp;
    ls_quantity                  NumberTabTyp;
    ls_ship_to_location_id       NumberTabTyp;
    ls_ship_to_organization_id   NumberTabTyp;
    ls_source_cle_id             NumberTabTyp;
    ls_unit_price                NumberTabTyp;
    ls_uom_code                  Char3TabTyp;



BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('insert_po_lines');
    END IF;

    my_debug('1160: Entering insert_po_lines', 2);

    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- Map all values into single table arrays to avoid Oracle errors
    -- caused by using rec(i).field

    my_debug('1180: p_po_lines_tab.first = ' || p_po_lines_tab.first, 2);
    my_debug('1200: p_po_lines_tab.last  = ' || p_po_lines_tab.last , 2);

     FOR i IN p_po_lines_tab.first..p_po_lines_tab.last
     LOOP
        ls_interface_header_id(i)        := p_po_lines_tab(i).interface_header_id;
        ls_interface_line_id(i)          := p_po_lines_tab(i).interface_line_id;
 --     ls_po_line_id(i)                 := p_po_lines_tab(i).po_line_id;        -- uncomment if we are able to generate po_line_id upfront

    -- Line number set to sequential number for all records
    -- Need to change this when we introduce multiple shipments for a line
    ls_line_num(i)                   :=  i;

    ls_freight_terms(i)              := p_po_lines_tab(i).freight_terms;
    ls_item_id(i)                    := p_po_lines_tab(i).item_id;
    ls_list_price_per_unit(i)        := p_po_lines_tab(i).list_price_per_unit;
    ls_need_by_date(i)               := p_po_lines_tab(i).need_by_date;
    ls_quantity(i)                   := p_po_lines_tab(i).quantity;
    ls_ship_to_location_id(i)        := p_po_lines_tab(i).ship_to_location_id;
    ls_ship_to_organization_id(i)    := p_po_lines_tab(i).ship_to_organization_id;
    ls_source_cle_id(i)              := p_po_lines_tab(i).source_cle_id;
    ls_unit_price(i)                 := p_po_lines_tab(i).unit_price;
    ls_uom_code(i)                   := p_po_lines_tab(i).uom_code;

    my_debug('1220: i = ' || i,2);
    my_debug('1240: ls_interface_header_id(i) = ' || ls_interface_header_id(i),2);
    my_debug('1260: ls_interface_line_id(i) = ' || ls_interface_line_id(i),2);
    my_debug('1280: ls_line_num(i) = ' || ls_line_num(i),2);
    my_debug('1300: g_po_ln_shipment_type = ' || g_po_ln_shipment_type,2);
    my_debug('1320: ls_item_id(i) = ' || ls_item_id(i),2);
    my_debug('1340: ls_uom_code(i) = ' || ls_uom_code(i),2);
    my_debug('1360: ls_quantity(i) = ' || ls_quantity(i),2);
    my_debug('1380: ls_unit_price(i) = ' || ls_unit_price(i),2);
    my_debug('1400: ls_list_price_per_unit(i) = ' || ls_list_price_per_unit(i),2);
    my_debug('1420: ls_ship_to_organization_id(i) = ' || ls_ship_to_organization_id(i),2);
    my_debug('1440: ls_ship_to_location_id(i) = ' || ls_ship_to_location_id(i),2);
    my_debug('1460: ls_need_by_date(i) = ' || ls_need_by_date(i),2);
    my_debug('1480: ls_freight_terms(i) = ' || ls_freight_terms(i),2);
    my_debug('1500: G_LAST_UPDATE_LOGIN = ' || G_LAST_UPDATE_LOGIN,2);
    my_debug('1520: G_USER_ID  = ' || G_USER_ID,2);
    my_debug('1540: G_REQUEST_ID = ' || G_REQUEST_ID,2);
    my_debug('1560: G_PROGRAM_APPLICATION_ID = ' || G_PROGRAM_APPLICATION_ID,2);
    my_debug('1580: G_PROGRAM_ID = ' || G_PROGRAM_ID,2);

    END LOOP;


    IF p_po_lines_tab.first is not NULL
    THEN
     FORALL i IN p_po_lines_tab.first..p_po_lines_tab.last

        INSERT INTO PO_LINES_INTERFACE
        (
            interface_line_id,
            interface_header_id,
            line_num,
    --      po_line_id,                 -- uncomment if we are able to pass po_line_id
            shipment_type,
            item_id,
            uom_code,
            quantity,
            unit_price,
            list_price_per_unit,
            ship_to_organization_id,
            ship_to_location_id,
            need_by_date,
            freight_terms,
            last_update_date,
            last_updated_by,
            last_update_login,
            creation_date,
            created_by,
            request_id,
            program_application_id,
            program_id,
            program_update_date
        )
        VALUES
        (
            ls_interface_line_id(i),            -- interface_line_id
            ls_interface_header_id(i),          -- interface_header_id
            ls_line_num(i),                     -- line_num
            --null,                             -- po_line_id
            g_po_ln_shipment_type,              -- shipment_type
            ls_item_id(i),                      -- item_id
            ls_uom_code(i),                     -- uom_code
            ls_quantity(i),                     -- quantity
            ls_unit_price(i),                   -- unit_price
            ls_list_price_per_unit(i),          -- list_price_per_unit
            ls_ship_to_organization_id(i),      -- ship_to_organization_id
            ls_ship_to_location_id(i),          -- ship_to_location_id
            ls_need_by_date(i),                 -- need_by_date
            ls_freight_terms(i),                -- freight_terms
            sysdate,                            -- last_update_date
            G_USER_ID,                          -- last_updated_by
            G_LAST_UPDATE_LOGIN,                -- last_update_login
            sysdate,                            -- creation_date
            G_USER_ID,                          -- created_by
            G_REQUEST_ID,                       -- request_id
            G_PROGRAM_APPLICATION_ID,           -- program_application_id
            G_PROGRAM_ID,                       -- program_id
            sysdate                             -- program_update_date
        );


-- Here create the relationship from the po line to the contract line
-- Insert record into OKC_K_REL_OBJS to record the link between the
-- Contract header and PO header. Currently, this is a direct insert.
-- Need to modify this call to pass the entire table once
-- the related objects API has a bulk insert API without validations

-- Normally, we would insert the relationship between cle_id and the
-- po_line_id. However, because of a current bug, PDOI does not accept
-- po_line_id. Hence, the relationship table is populated with
-- po_header_id and line_num and is updated during the final call to
-- this program with the correct po_line_id (after the PO has been
-- created)

 FORALL i IN p_po_lines_tab.first..p_po_lines_tab.last
  INSERT  INTO OKC_K_REL_OBJS
  ( id,
    cle_id,
    chr_id,
    rty_code,
    object1_id1,
    object1_id2,
    jtot_object1_code,
    object_version_number,
    created_by,
    creation_date,
    last_updated_by,
    last_update_date,
    last_update_login
  )
  VALUES
  (
    okc_p_util.raw_to_number(sys_guid()) -- id
    ,ls_source_cle_id(i)     -- cle_id
    ,p_chr_id                -- chr_id
    ,g_crj_rty_code          -- rty_code
    ,p_po_header_id          -- object1_id1 -- see note above
    ,ls_line_num(i)          -- object1_id2 -- see note above
    ,g_crj_cle_jtot_object_code -- jtot_object1_code
    ,1                       -- object_version_number
    ,G_USER_ID               -- created_by
    ,sysdate                 -- creation_date
    ,G_USER_ID               -- last_updated_by
    ,sysdate                 -- last_update_date
    ,g_last_update_login     -- last_update_login
  );
    -- cleanup

    ls_interface_line_id.delete;
    ls_interface_header_id.delete;
    ls_line_num.delete;
    ls_po_line_id.delete;
    ls_item_id.delete;
    ls_uom_code.delete;
    ls_quantity.delete;
    ls_unit_price.delete;
    ls_list_price_per_unit.delete;
    ls_ship_to_organization_id.delete;
    ls_ship_to_location_id.delete;
    ls_need_by_date.delete;
    ls_freight_terms.delete;
    ls_source_cle_id.delete;


    --p_po_lines_tab.delete;  -- uncomment this line when create relationship from po to contract above is done

    END IF;

        my_debug('1560: Exiting insert_po_lines', 2);

        IF (l_debug = 'Y') THEN
           okc_debug.Reset_Indentation;
        END IF;

EXCEPTION
    WHEN OTHERS THEN
        my_debug('1580: error'||substr(sqlerrm,1,240));
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            my_debug('1600: Exiting insert_po_lines', 4);
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;


END insert_po_lines;

--------------------------------------------------------------------------------
------------- Procedure: insert_po_distributions ---------------------
--------------------------------------------------------------------------------
-- Purpose:        Populate purchase order distributions interface table

-- In Parameters:  p_po_dist_tab    Table to hold po distributions interface data

-- Out Parameters: x_return_status  Standard return status
------------------------------------------------------------------------------------

PROCEDURE insert_po_distributions(p_po_dist_tab    IN   po_distributions_tab
     	                         ,x_return_status  OUT NOCOPY VARCHAR2  ) IS

-- Declaration of individual elements to avoid ORA-3113 error because
-- FORALL does not allow insert of elements of %rowtype

   ls_interface_header_id          NumberTabTyp;
   ls_interface_line_id            NumberTabTyp;
   ls_interface_distribution_id    NumberTabTyp;
   ls_org_id                       NumberTabTyp;
   ls_quantity_ordered             NumberTabTyp;
   ls_charge_account_id            NumberTabTyp;


BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('insert_po_distributions');
    END IF;

    my_debug('1620: Entering insert_po_distributions', 2);

    x_return_status := OKC_API.G_RET_STS_SUCCESS;


-- Map all values into single table arrays to avoid Oracle errors
-- caused by using rec(i).field

    FOR i IN p_po_dist_tab.first..p_po_dist_tab.last
    LOOP
        ls_interface_header_id(i)               := p_po_dist_tab(i).interface_header_id;
        ls_interface_line_id(i)                 := p_po_dist_tab(i).interface_line_id;
        ls_interface_distribution_id(i)         := p_po_dist_tab(i).interface_distribution_id;
        ls_org_id(i)                            := p_po_dist_tab(i).org_id;
        ls_quantity_ordered(i)                  := p_po_dist_tab(i).quantity_ordered;
	   ls_charge_account_id(i)                 := p_po_dist_tab(i).charge_account_id;

        my_debug('1640: PO distribution org id:'|| p_po_dist_tab(i).org_id, 1);

        my_debug('1660: PO distribution quantity ordered:'|| p_po_dist_tab(i).quantity_ordered, 1);
        my_debug('1680: PO charge_Account_id  :'|| p_po_dist_tab(i).charge_account_id, 1);

    END LOOP;

    IF p_po_dist_tab.first is not NULL THEN
        FORALL i IN p_po_dist_tab.first..p_po_dist_tab.last

        INSERT INTO PO_DISTRIBUTIONS_INTERFACE
        (
            interface_header_id,
            interface_line_id,
            interface_distribution_id,
            distribution_num,
            org_id,
            quantity_ordered,
            destination_type_code,
            charge_account_id
        )
        VALUES
        (
            ls_interface_header_id(i),             -- interface_header_id
            ls_interface_line_id(i),               -- interface_line_id
            po_distributions_interface_s.NEXTVAL,  -- interface_distribution_id
            1,                                     -- distribution_num
            ls_org_id(i),                          -- org_id
            ls_quantity_ordered(i),                -- quantity_ordered
            g_po_dis_destination_type_code,        -- destination_type_code
            ls_charge_account_id(i)                -- charge_account_id
    );



    -- cleanup

 --   ls_interface_header_id.delete;
 --   ls_interface_line_id.delete;
 --   ls_interface_distribution_id.delete;
 --   ls_distribution_num.delete;

    commit;
    ls_org_id.delete;
    ls_quantity_ordered.delete;


--    p_po_dist_tab.delete;

    my_debug('1700: Exiting insert_po_distributions', 2);

    IF (l_debug = 'Y') THEN
       okc_debug.Reset_Indentation;
    END IF;

END IF;

EXCEPTION
    WHEN OTHERS THEN
          my_debug('1720: error'||substr(sqlerrm,1,240));
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            my_debug('1740: Exiting insert_po_distributions', 4);
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

END insert_po_distributions;


----------------------------------------------------------------------------
--  Public Procedure -------------------------------------------------------
----------------------------------------------------------------------------

--------------------------------------------------------------------------------
------------- Procedure: create_po_from_k  ---------------------
--------------------------------------------------------------------------------
-- Purpose:        Create a purchase order from a contract by populating the po
-- interface tables
--
-- In Parameters:  p_chr_id    Contract header id
--                 p_batch_id  Batch id
--
-- Out Parameters: x_return_status  Standard return status
----------------------------------------------------------------------------------

 PROCEDURE create_po_from_k(p_api_version               IN NUMBER
			         ,p_init_msg_list             IN VARCHAR2
			         ,p_chr_id                    IN okc_k_headers_b.ID%TYPE
                           ,x_return_status            OUT NOCOPY VARCHAR2
			         ,x_msg_count                OUT NOCOPY NUMBER
			         ,x_msg_data                 OUT NOCOPY VARCHAR2) IS

-- standard api variables

l_api_version           CONSTANT NUMBER := 1;
l_api_name              CONSTANT VARCHAR2(30) := 'CREATE_PO_FROM_K';
l_return_status         VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
l_msg_count             NUMBER := 0;
l_msg_data              VARCHAR2(1000);
l_po_header_rec         po_header_rec_type;
l_po_lines_tab          po_lines_tab;
l_po_dist_tab           po_distributions_tab;


-- Batch id for all records created in the interface table
l_batch_id           number;
l_request_id         number;

-- Temporarily required...see notes elsewhere
l_po_header_id       po_headers_all.po_header_id%TYPE;

BEGIN

    G_USER_ID                := FND_GLOBAL.USER_ID;
    G_LAST_UPDATE_LOGIN      := FND_GLOBAL.LOGIN_ID;
    G_PROGRAM_ID             := FND_GLOBAL.CONC_PROGRAM_ID;
    G_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    G_REQUEST_ID             := FND_GLOBAL.CONC_REQUEST_ID;

-- Generate the batch id for the run. All records are inserted into
-- the interface table with this batch_id
-- Max will not return an exception but NULL if no records are there;
-- hence the nvl

  SELECT NVL(MAX(batch_id),0) + 1
    INTO l_batch_id
    FROM po_headers_interface;

  my_debug('1760: Batch Id: ' || l_batch_id, 4);

  my_debug('1760: Contract Id: ' || p_chr_id, 4);

-- include here call to procedure that will validate the contract

-- call procedure to fetch the contract data

 get_k_info(p_chr_id         => p_chr_id
            ,x_return_status => l_return_status
            ,x_po_header_rec => l_po_header_rec
            ,x_po_lines_tab  => l_po_lines_tab
            ,x_po_dist_tab   => l_po_dist_tab);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

-- call procedure to populate purchase order header

insert_po_hdr(
              p_chr_id         => p_chr_id
             ,p_batch_id       => l_batch_id
		     ,p_po_header_rec  => l_po_header_rec
             ,x_return_status  => l_return_status
		     ,x_po_header_id   => l_po_header_id);

  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;


OPEN c_top_cle(p_chr_id);

FETCH c_top_cle
INTO l_po_lines_tab(1).source_cle_id,
	 l_po_lines_tab(1).item_id,
	 l_po_lines_tab(1).uom_code,
     l_po_lines_tab(1).quantity,
	 l_po_lines_tab(1).unit_price,
	 l_po_lines_tab(1).list_price_per_unit,
     l_po_lines_tab(1).need_by_date;


-- call procedure to populate purchase order lines just if the contract has lines

IF c_top_cle%FOUND THEN


	insert_po_lines(p_chr_id         => p_chr_id
			,p_po_lines_tab  => l_po_lines_tab
        		,p_po_header_id  => l_po_header_id
              		,x_return_status => l_return_status);


  	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    		RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;


  	-- call procedure to populate purchase order distributions


	insert_po_distributions(p_po_dist_tab   => l_po_dist_tab
                      		,x_return_status => l_return_status);

  	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    		my_debug('1780: Unexpected error from insert_po_distributions',4);
    		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    		my_debug('1800: Error from insert_po_distributions',4);
    		RAISE OKC_API.G_EXCEPTION_ERROR;
  	END IF;

END IF;

 my_debug('1820: Calling submit_request for PDOI',4);

-- Submit the request to import the records from the interface table.
-- The batch_id generated is passed in to ensure that only those
-- records which were inserted during the earlier phase are imported.

 l_request_id := fnd_request.submit_request(
					  application => 'PO'
					 ,program     => 'POXPOPDOI'
					 ,sub_request => TRUE         -- Indicates that this is a child
											-- of the parent request
					 ,argument1   => null         -- Default buyer
					 ,argument2   => 'Standard'   -- Document type
					 ,argument3   => null         -- Document sub type
					 ,argument4   => 'N'          -- Create or update items
					 ,argument5   => 'N'          -- Create sourcing rules
					 ,argument6   => null         -- Approval status
					 ,argument7   => null         -- Release generation method
					 ,argument8   => l_batch_id   -- Batch Id
					 ,argument9   => null         -- Operating unit
					 );

 my_debug('1840: Finished the call with request id:  ' || l_request_id,4);
-- If the request could not be submitted for some reason, then the
-- request_id is set to 0. Exit with an error if this is the case

 IF l_request_id = 0
 THEN
    my_debug('1860: Error submitting request for PDOI',4);
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;

-- If no errors, set the status of the current request to PAUSED since
-- it is not running at present and so that it frees up resources
-- Also, set request_data to stage2 to indicate that this is the final run

  fnd_conc_global.set_req_globals(conc_status => 'PAUSED',
						    request_data => 'STAGE2');

EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
               my_debug('1880: Exiting create_po_from_k', 4);
               IF (l_debug = 'Y') THEN
                  okc_debug.Reset_Indentation;
               END IF;

         WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
              x_return_status := OKC_API.HANDLE_EXCEPTIONS
                       (l_api_name,
                        G_PKG_NAME,
                       'OKC_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count,
                        x_msg_data,
                        '_PROCESS');
                my_debug('1900: Exiting create_po_from_k', 4);
               IF (l_debug = 'Y') THEN
                  okc_debug.Reset_Indentation;
               END IF;

         WHEN OTHERS THEN
            my_debug('1920: error'||substr(sqlerrm,1,240));
             OKC_API.set_message(p_app_name      => g_app_name,
                                 p_msg_name      => g_unexpected_error,
                                 p_token1        => g_sqlcode_token,
                                 p_token1_value  => sqlcode,
                                 p_token2        => g_sqlerrm_token,
                                 p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
            my_debug('1940: Exiting create_po_from_k', 4);
            IF (l_debug = 'Y') THEN
               okc_debug.Reset_Indentation;
            END IF;

  END create_po_from_k;

--------------------------------------------------------------------------------
-------------- Procedure: tieback_related_objs_from_po  ------------------------
--------------------------------------------------------------------------------
-- Purpose: See specifications (avoid dual maintenance of comments)
--
-- In Parameters:       p_chr_id        Contract header id
--
-- Out Parameters:      Standard
--------------------------------------------------------------------------------

PROCEDURE tieback_related_objs_from_po(
                p_api_version   IN NUMBER
               ,p_init_msg_list IN  VARCHAR2
               ,p_chr_id        IN okc_k_headers_b.id%TYPE
               ,x_po_number     OUT NOCOPY VARCHAR2
               ,x_return_status OUT NOCOPY VARCHAR2
               ,x_msg_count     OUT NOCOPY NUMBER
               ,x_msg_data      OUT NOCOPY VARCHAR2
								) IS

l_msg_data     VARCHAR2(200);
l_po_number    po_headers_all.segment1%TYPE;

-- Keep track of number of rows affected. It is essential to store the
-- SQL*ROWCOUNT value locally after each SQL operation as if we use
-- the variable SQL%ROWCOUNT, there is a chance that it might get
-- overwritten by intermediate function calls. For e.g. if we use
-- sql%rowcount in a debug statement and then examine it, it is
-- possible that the function which prints the debug message has a SQL
-- operation causing the value of SQL%ROWCOUNT to be overwritten

l_sql_rowcount   pls_integer;


BEGIN

   x_return_status  := OKC_API.G_RET_STS_SUCCESS;

   IF (l_debug = 'Y') THEN
      okc_debug.Set_Indentation('tieback_related_objs_from_po');
   END IF;


-- Remove the relationship between the contract header and PO header
-- from related objects if no PO header was created

  my_debug('1960: Attempting delete of hanging header related objects', 4);

  DELETE okc_k_rel_objs  rel
   WHERE rel.chr_id = p_chr_id -- for the current contract
	AND rel.cle_id IS NULL  -- related obj pertains to header
	AND rel.rty_code = g_crj_rty_code -- for PO creation
	AND rel.jtot_object1_code = g_crj_chr_jtot_object_code -- correct jtot object
											    -- for contract header
	AND NOT EXISTS (
	   SELECT null
		FROM po_headers_all poh
	    WHERE rel.object1_id1 = poh.po_header_id
	);

  l_sql_rowcount := SQL%ROWCOUNT;

  my_debug('1980: Related objects hanging headers deleted: ' || l_sql_rowcount, 4);

-- Check the number of related objects deleted by the above statement.
-- If any is deleted (that means no related object was created for the
-- header), then this indicates that the whole PDOI has failed and we
-- need to set the concurrent program status accordingly. Also, print
-- the message in the out file so that the user is made aware of this

  IF l_sql_rowcount > 0
  THEN
     my_debug('2000: *** Fatal Error.  No PO was created **',1);
     fnd_message.set_name('OKC','OKC_PO_NOT_CREATED_BY_PDOI');

     -- Write message to out file
     fnd_file.put_line(fnd_file.output, fnd_message.get);

     -- Set return values
     x_msg_count     := 1;
     x_msg_data      := fnd_message.get;

    -- Clean up all lines since the header was not interfaced

    my_debug('2020: Deleting related object lines', 4);

    DELETE FROM okc_k_rel_objs
     WHERE chr_id = p_chr_id;

    my_debug('2040: Deleted related object lines, count = ' || SQL%ROWCOUNT, 4);


  -- Raise exception to skip further processing and mark the program in
  -- error
    RAISE g_unexp_error;

  END IF; -- if sql%rowcount > 0

-- If there is no header record deleted, this means that the PO was
-- successfully created. Log the PO number in the out file so that the
-- user can easily identify the PO

	SELECT po.segment1
	  INTO l_po_number
	  FROM po_headers_all po
	 WHERE po.po_header_id =
	  ( SELECT object1_id1
		 FROM okc_k_rel_objs rel
          WHERE rel.chr_id            = p_chr_id       -- for the current contract
	       AND rel.cle_id IS NULL                     -- related obj pertains to header
	       AND rel.rty_code          = g_crj_rty_code -- for PO creation
	       AND rel.jtot_object1_code = g_crj_chr_jtot_object_code
										 -- correct jtot object
	   );

-- Get the PO number into a translated message and write this into the
-- out file

	my_debug('2060: PO number created: ' || l_po_number, 4);

     fnd_message.set_name('OKC','OKC_LOG_PO_CREATED_DETAILS');
     fnd_message.set_token('PO_NUMBER', l_po_number);
     fnd_file.put_line(fnd_file.output, fnd_message.get);
     x_po_number := l_po_number;

    -- setting the message twice so Events Engine can get it

    fnd_message.set_name('OKC','OKC_LOG_PO_CREATED_DETAILS');
    fnd_message.set_token('PO_NUMBER', l_po_number);

  my_debug('2080: Attempting delete of hanging line related objects', 1);

-- Remove the relationship between the contract lines and
-- corresponding PO lines from related objects if they were not
-- created. This can happen if there is some error during PDOI

  DELETE okc_k_rel_objs  rel
   WHERE rel.chr_id = p_chr_id  -- for the current contract
	AND rel.cle_id IS NOT NULL -- for line records
	AND rel.rty_code = g_crj_rty_code -- for K-PO records
	AND rel.jtot_object1_code = g_crj_cle_jtot_object_code -- correct jtot object
	AND NOT EXISTS (
	   SELECT null
		FROM po_lines_all pol
		WHERE rel.object1_id1 = pol.po_header_id
		  AND rel.object1_id2 = pol.line_num);

  l_sql_rowcount := SQL%ROWCOUNT;

  my_debug('2100: Related objects hanging lines deleted: ' || l_sql_rowcount, 4);

-- If some rows were deleted, this means that all lines were not
-- transferred over. The user will have to manually correct these
-- lines. Indicate to the main procedure that this is a Warning so
-- that the return status of the Concurrent program can be set to
-- Warning and the user sees this in the View Requests window

  IF l_sql_rowcount > 0
  THEN
     fnd_message.set_name('OKC','OKC_LOG_PO_SOME_LINES_NOT_XFRD');
     l_msg_data      := fnd_message.get;
     x_return_status := OKC_API.G_RET_STS_WARNING;
     x_msg_count     := 1;
     x_msg_data      := l_msg_data;

     fnd_file.put_line(fnd_file.output, l_msg_data);
  END IF;


-- Now that the hanging related objects have been deleted, update the
-- related objects table to reflect the relationship between contract
-- line id and po line id. Currently, during the first pass, the
-- relationship is established between the contract line id and the
-- po_header_id + line_num. Will change in the future if the bug is
-- fixed in PDOI

  my_debug('2110: Updating related objects replacing line num with line id');

  UPDATE okc_k_rel_objs rel
	SET (rel.object1_id1, rel.object1_id2) =
	 (  SELECT pol.po_line_id, '#'
		 FROM po_lines_all pol
		WHERE pol.po_header_id = rel.object1_id1
		  AND pol.line_num     = rel.object1_id2 )
   WHERE chr_id = p_chr_id
	AND rel.rty_code = g_crj_rty_code
	AND rel.cle_id IS NOT NULL;

  l_sql_rowcount := SQL%ROWCOUNT;
  my_debug('2120: Related objects lines updated: ' || l_sql_rowcount, 4);

  IF (l_debug = 'Y') THEN
     okc_debug.Reset_Indentation;
  END IF;

EXCEPTION
 WHEN g_unexp_error
 THEN
     x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	IF (l_debug = 'Y') THEN
   	okc_debug.Reset_Indentation;
	END IF;

END tieback_related_objs_from_po;

END OKC_CREATE_PO_FROM_K_PVT;

/
