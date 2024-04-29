--------------------------------------------------------
--  DDL for Package Body ECEPOI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECEPOI" AS
/* $Header: OEPOIB.pls 120.0.12010000.1 2009/08/28 00:59:55 smusanna noship $ */

PROCEDURE Process_POI_Inbound (
	errbuf		    OUT	NOCOPY varchar2,
	retcode		    OUT	NOCOPY varchar2,
	i_file_path         IN  varchar2,
        i_file_name         IN  varchar2,
        i_debug_mode        IN  number,
        i_run_import        IN  varchar2,
        i_num_instances     IN  number default 1,
	i_transaction_type  IN	varchar2,
	i_map_id	    IN  number,
        i_data_file_characterset  IN  varchar2
        )
IS
	i_submit_id		number;
	i_run_id		     number;
	i_map_type		varchar2(40);

      cEnabled                   VARCHAR2(1)          := 'Y';
      ece_transaction_disabled   EXCEPTION;

begin
	ec_debug.enable_debug(i_debug_mode);
	ec_debug.pl(0,'EC','ECE_START_INBOUND','TRANSACTION_TYPE',i_transaction_type);
	ec_debug.push('ECEPOI.PROCESS_POI_INBOUND');
	ec_debug.pl(3,'i_file_path',i_file_path);
	ec_debug.pl(3,'i_file_name',i_file_name);
	ec_debug.pl(3,'i_run_import',i_run_import);
	ec_debug.pl(3,'i_map_id',i_map_id);
	ec_debug.pl(3,'i_debug_mode',i_debug_mode);
	ec_debug.pl(3,'i_num_instances',i_num_instances);
        ec_debug.pl(3,'i_data_file_characterset',i_data_file_characterset);
         /* Check to see if the transaction is enabled. If not, abort */
        fnd_profile.get('ECE_' || i_transaction_type || '_ENABLED',cEnabled);
        IF cEnabled = 'N' THEN
           RAISE ece_transaction_disabled;
        END IF;

	ec_debug.pl(0,'EC','ECE_BEGIN_STAGING','TRANSACTION_TYPE',i_transaction_type);

	select map_type into i_map_type
        from ece_mappings
        where map_id = i_map_id
          and enabled ='Y';

       ec_inbound_stage.g_source_charset := i_data_file_characterset;

	IF i_map_type = 'XML' THEN
           ec_xml_utils.ec_xml_processor_in_generic (
                i_map_id,
                i_run_id,
                i_file_path,
                i_file_name
                );
	ELSE
	   ec_inbound_stage.load_data (
                i_transaction_type,
                i_file_name,
                i_file_path,
                i_map_id,
                i_run_id
                );
        END IF;

	ec_debug.pl(0,'EC','ECE_END_STAGING','TRANSACTION_TYPE',i_transaction_type);

	/**
	Initialize the Stack Table
	**/
	ec_utils.g_stack.DELETE;

	ec_debug.pl(0,'EC','ECE_START_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);
        ece_inbound.process_run_inbound (
                i_transaction_type => i_transaction_type,
                i_run_id => i_run_id
                );

	ec_debug.pl(0,'EC','ECE_FINISH_GENERIC_INBOUND','TRANSACTION_TYPE',i_transaction_type);

	IF i_Run_Import = 'Y' THEN
           i_Submit_ID := fnd_request.submit_request (
            application => 'ONT',
            program     => 'OEOIMP',
	    argument1   => NULL, -- --Operating_unit_id  bug6918092
            argument2   => '6',	-- Order_Source_Id =6 for EDI
            argument3   => '',	-- Order Ref = all
            argument4   => 'INSERT',-- Operation code = INSERT
            argument5   => 'N',	-- Validate_Only = 'N'
            argument6   => '1',	-- Debug Level = 1
            argument7   => i_num_instances -- No. of Instance to run for OIMP
			);

	   ec_debug.pl(0,'EC','ECE_EXECUTE_OPEN_INTERFACE',
			      'TRANSACTION_TYPE',i_transaction_type,
			      'REQUEST_ID',i_Submit_Id);
      	END IF;

	COMMIT;
	retcode := ec_utils.i_ret_code;

	IF ec_mapping_utils.ec_get_trans_upgrade_status(i_transaction_type)  = 'U' THEN
   	   ec_debug.pl(0,'EC','ECE_REC_TRANS_PENDING',NULL);
   	   retcode := 1;
	END IF;

	ec_debug.pl(3,'i_submit_id',i_submit_id);
	ec_debug.pl(3,'retcode',retcode);
	ec_debug.pl(3,'errbuf',errbuf);
	ec_debug.pop('ECEPOI.PROCESS_POI_INBOUND');

	ec_debug.pl(0,'EC','ECE_END_INBOUND','TRANSACTION_TYPE',i_transaction_type);
	ec_debug.disable_debug;

   EXCEPTION
     WHEN ece_transaction_disabled THEN
         ec_debug.pl(0,'EC','ECE_TRANSACTION_DISABLED','TRANSACTION',i_transaction_type);
         retcode := 1;
         ec_debug.disable_debug;
         ROLLBACK WORK;

     WHEN EC_UTILS.PROGRAM_EXIT then
	errbuf := ec_utils.i_errbuf;
	retcode := ec_utils.i_ret_code;
	ece_flatfile_pvt.print_attributes;
	rollback work;
	ec_debug.disable_debug;

     WHEN OTHERS THEN
        ec_debug.pl(0,'EC','ECE_PROGRAM_ERROR','PROGRESS_LEVEL',
			   'ECEPOI.PROCESS_POI_INBOUND');
        ec_debug.pl(0,'EC','ECE_ERROR_MESSAGE','ERROR_MESSAGE',SQLERRM);
	retcode := 2;
	rollback work;
	ece_flatfile_pvt.print_attributes;
	ec_debug.disable_debug;

END PROCESS_POI_INBOUND;

Procedure Concat_Strings(
          String1       IN      VARCHAR2,
          String2       IN      VARCHAR2,
          String3       IN      VARCHAR2,
          OUT_String    OUT NOCOPY     VARCHAR2
          )
IS
Begin

     OUT_String := String1 || String2 ||'.'||String3;

End Concat_Strings;

Procedure Get_Ship_To_Org_Id(
          p_address_id       IN      NUMBER,
          p_customer_id      IN      NUMBER,
          x_ship_to_org_id   OUT  NOCOPY    NUMBER
          )
IS
l_site_use_id   Number;
lcustomer_relations varchar2(1);
l_orgid number;
Begin
 select su.org_id into l_orgid
    from hz_cust_acct_sites st, hz_cust_site_uses_all su
    where    st.cust_acct_site_id = p_address_id
    and      su.cust_acct_site_id = st.cust_acct_site_id
    and su.site_use_code= 'SHIP_TO' and rownum =1;
 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG',l_orgid);
   If nvl(lcustomer_relations ,'N') = 'N' Then
    SELECT site_use_id
    INTO   l_site_use_id
    FROM   oe_ship_to_orgs_v
    WHERE  customer_id = p_customer_id
    AND    address_id  = p_address_id
    AND    status = 'A';
   ELSIF lcustomer_relations = 'Y' THEN
    SELECT site_use_id
    INTO   l_site_use_id
    From   oe_ship_to_orgs_v
    WHERE  address_id  = p_address_id
    AND    status = 'A' AND
    customer_id in (
                    Select p_customer_id from dual
                    union
                    select cust_account_id from
                    hz_cust_acct_relate_all where
                    related_cust_account_id = p_customer_id)
    and rownum = 1;
   END IF;
   x_ship_to_org_id := l_site_use_id;
Exception
        When Others Then
           x_ship_to_org_id := NULL;
End Get_Ship_To_Org_Id;


Procedure Get_Bill_To_Org_Id(
          p_address_id       IN      NUMBER,
          p_customer_id      IN      NUMBER,
          x_bill_to_org_id   OUT NOCOPY     NUMBER
          )
IS
l_site_use_id   Number;
lcustomer_relations varchar2(1);
l_orgid number;
Begin
 select su.org_id into l_orgid
    from hz_cust_acct_sites st, hz_cust_site_uses_all su
    where    st.cust_acct_site_id = p_address_id
    and      su.cust_acct_site_id = st.cust_acct_site_id
    and su.site_use_code= 'BILL_TO' and rownum =1;
 lcustomer_relations := OE_Sys_Parameters.VALUE('CUSTOMER_RELATIONSHIPS_FLAG',l_orgid);
   If nvl(lcustomer_relations ,'N') = 'N' Then
    SELECT site_use_id
    INTO   l_site_use_id
    FROM   oe_invoice_to_orgs_v
    WHERE  customer_id = p_customer_id
    AND    address_id  = p_address_id;
   ELSIF lcustomer_relations = 'Y' THEN
    SELECT site_use_id
    INTO   l_site_use_id
    From   oe_invoice_to_orgs_v
    WHERE  address_id  = p_address_id
    AND
    customer_id in (
                    Select p_customer_id from dual
                    union
                    select cust_account_id from
                    hz_cust_acct_relate_all where
                    related_cust_account_id = p_customer_id)
    and rownum = 1;
   END IF;
   x_bill_to_org_id := l_site_use_id;
Exception
        When Others Then
           x_bill_to_org_id := NULL;
End Get_Bill_To_Org_Id;

-- Fix for the bug 2627330
Procedure Concat_Instructions(
                               String1 IN VARCHAR2,
                               String2 IN VARCHAR2,
                               String3 IN VARCHAR2,
                               String4 IN VARCHAR2,
                               String5 IN VARCHAR2,
                               Concat_String OUT NOCOPY VARCHAR2
                               )
IS
Begin
  Concat_String := String1 || String2 || String3 || String4 || String5;

End Concat_Instructions;
-- Fix ends

FUNCTION EM_Transaction_Type
(   p_txn_code                 IN  VARCHAR2
) RETURN VARCHAR2
IS
  l_transaction_type            VARCHAR2(80);

BEGIN

    IF  p_txn_code IS NULL
    THEN
        RETURN NULL;
    END IF;

    SELECT  MEANING
    INTO    l_transaction_type
    FROM    OE_LOOKUPS
    WHERE   LOOKUP_CODE = p_txn_code
    AND     LOOKUP_TYPE = 'ONT_ELECMSGS_TYPES';

    RETURN l_transaction_type;

EXCEPTION
    WHEN OTHERS THEN
	RETURN NULL;

End EM_Transaction_Type;

PROCEDURE Raise_Event_Hist (
          p_order_source_id         IN     Number,
          p_orig_sys_document_ref   IN     Varchar2,
          p_sold_to_org_id          IN     Number,
          p_transaction_type        IN     Varchar2,
          p_document_id		    IN     Number,
          p_change_sequence         IN     Varchar2,
          p_order_number            IN     Number,
          p_itemtype                IN     Varchar2,
          p_itemkey                 IN     Varchar2,
          p_status                  IN     Varchar2,
          p_message_text            IN     Varchar2,
          p_processing		    IN     Varchar2,
          p_xmlg_party_id           IN     Number,
          p_xmlg_party_site_id      IN     Number,
          p_order_type_id           IN     Number,
          p_header_id               IN     Number,
          p_org_id                  IN     Number,
          x_return_status           OUT NOCOPY    Varchar2
)
IS
   l_eventkey       NUMBER;
   l_message_text   VARCHAR2(2000);
   l_transaction_type VARCHAR2(30) := p_transaction_type;
   l_status         VARCHAR2(240);
   l_processing     VARCHAR2(30) := p_processing;
   l_parameter_list WF_PARAMETER_LIST_T := wf_parameter_list_t();
   l_document_id    NUMBER := p_document_id;
   l_org_id         NUMBER := p_org_id;
   l_order_number   NUMBER := p_order_number;
   l_document_direction VARCHAR2(6);
   l_release_level  VARCHAR2(10);
   l_integ_profile  VARCHAR2(10) := nvl (FND_PROFILE.VALUE ('ONT_EM_INTEG_SOURCES'), 'XML');
   l_order_processed_flag VARCHAR2(1);
BEGIN
   BEGIN
     -- this call is dynamic to prevent dependency issues for customers who
     -- do not have the OE_Code_Control package
     EXECUTE IMMEDIATE 'Begin   :1 := OE_Code_Control.Get_Code_Release_Level; End;'
                 USING out l_release_level;
     IF l_release_level < '110510' THEN
        RETURN;
     END IF;
   EXCEPTION
     WHEN OTHERS THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       RETURN;
   END;

  -- new profile to control which order sources can raise this event
  -- note that by this point, we are already sure that OM is at 11i10
  -- level, therefore the profile has to exist
  IF l_integ_profile = 'XML' THEN
     IF p_order_source_id <> 20 THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
     END IF;
  ELSIF l_integ_profile = 'EDIXML' THEN
     IF p_order_source_id NOT IN (20,6)  THEN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
     END IF;
  END IF;

  EXECUTE IMMEDIATE 'Begin  SELECT OE_XML_MESSAGE_SEQ_S.nextval INTO :1 FROM DUAL; end;'
               USING out l_eventkey;

  IF p_status IS NULL THEN
     IF l_transaction_type IN ('855', '865') THEN
        l_status := 'SUCCESS';
        l_processing := 'OUTBOUND_SENT';
     ELSE
        l_status := 'ACTIVE';
        l_processing := 'INBOUND_IFACE';
     END IF;
  END IF;
  IF l_message_text IS NULL THEN
     IF l_processing = 'INBOUND_IFACE' THEN
        fnd_message.set_name ('ONT', 'OE_OI_IFACE');
     ELSIF l_processing = 'OUTBOUND_SENT' THEN
        fnd_message.set_name ('ONT', 'OE_OA_ACKNOWLEDGMENT_SENT');
     END IF;
     fnd_message.set_token ('TRANSACTION', ECEPOI.EM_Transaction_Type (p_txn_code => l_transaction_type));
     l_message_text := fnd_message.get;
  END IF;
  -----------------------------------------------------------
  -- Non-CLN params
  -----------------------------------------------------------

  wf_event.AddParameterToList(p_name=>          'ORDER_SOURCE_ID',
                              p_value=>           p_order_source_id,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'SOLD_TO_ORG_ID',
                              p_value=>           p_sold_to_org_id,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'PROCESSING_STAGE',
                              p_value=>         l_processing,
                              p_parameterlist=> l_parameter_list);

  IF l_document_id IS NULL THEN
     l_document_id := to_number(l_eventkey); -- reuse the eventkey if necessary
  END IF;

  IF l_transaction_type IN ('855','865') THEN
      wf_event.AddParameterToList(p_name=>          'XMLG_DOCUMENT_ID',
                                p_value=>           l_document_id,
                                p_parameterlist=>   l_parameter_list);
      l_order_processed_flag := 'Y';
  ELSE
      wf_event.AddParameterToList(p_name=>          'XMLG_INTERNAL_CONTROL_NUMBER',
                                p_value=>           l_document_id,
                                p_parameterlist=>   l_parameter_list);
      l_order_processed_flag := 'N';
  END IF;

  wf_event.AddParameterToList(p_name=>          'XMLG_INTERNAL_TXN_TYPE',
                              p_value=>           'ONT',
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'XMLG_INTERNAL_TXN_SUBTYPE',
                              p_value=>           l_transaction_type,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'PARTNER_DOCUMENT_NO',
                              p_value=>           p_orig_sys_document_ref,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'DOCUMENT_NO',
                              p_value=>           l_order_number,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'DOCUMENT_REVISION_NO',
                              p_value=>           p_change_sequence,
                              p_parameterlist=>   l_parameter_list);

  IF l_org_id IS NULL THEN
     SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ',
            NULL, SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
       INTO l_org_id
       FROM DUAL;
  END IF;

  wf_event.AddParameterToList(p_name=>          'ORG_ID',
                              p_value=>           l_org_id,
                              p_parameterlist=>   l_parameter_list);


  wf_event.AddParameterToList(p_name=>          'ONT_DOC_STATUS',
                              p_value=>           l_status,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'MESSAGE_TEXT',
                              p_value=>           l_message_text,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'SUBSCRIBER_LIST',
                              p_value=>           'ONT',
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORDER_TYPE_ID',
                              p_value=>           p_order_type_id,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'HEADER_ID',
                              p_value=>           p_header_id,
                              p_parameterlist=>   l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORDER_PROCESSED_FLAG',
                              p_value=>           l_order_processed_flag,
                              p_parameterlist=>   l_parameter_list);

  wf_event.raise( p_event_name => 'oracle.apps.ont.oi.xml_int.status',
                    p_event_key =>  l_eventkey,
                    p_parameters => l_parameter_list);

  l_parameter_list.delete;

  x_return_status := FND_API.G_RET_STS_SUCCESS ;

EXCEPTION
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Raise_Event_Hist;

PROCEDURE Get_Item_Description
(  p_org_id               IN NUMBER
,  p_item_identifier_type IN VARCHAR2
,  p_inventory_item_id    IN NUMBER
,  p_ordered_item_id      IN NUMBER
,  p_sold_to_org_id       IN NUMBER
,  p_ordered_item         IN VARCHAR2
,  x_item_description     OUT NOCOPY VARCHAR2
) IS
l_organization_id NUMBER;
--
l_item_description   VARCHAR2(240) := null ;

BEGIN
   ec_debug.pl(3,'Entering Get_Item_Description()');
   ec_debug.pl(3,'Item Identifier Type ',p_item_identifier_type);
   ec_debug.pl(3,'Inventory Item ID ',p_inventory_item_id);
   ec_debug.pl(3,'Ordered Item ID ',p_ordered_item_id);
   ec_debug.pl(3,'Sold to Org  ID ',p_sold_to_org_id);
   ec_debug.pl(3,'Org ID ',p_org_id);
   ec_debug.pl(3,'Ordered Item ',p_ordered_item);

  l_organization_id := oe_sys_parameters.value('MASTER_ORGANIZATION_ID', p_org_id);
  ec_debug.pl(3,'Organization ID ',l_organization_ID);

   IF    (p_item_identifier_type) = 'INT' THEN
         SELECT description
         INTO   x_item_description
         FROM   mtl_system_items_vl
         WHERE  inventory_item_id = p_inventory_item_id
         AND    organization_id = l_organization_id;

   ELSIF NVL(p_item_identifier_type,'INT') = 'CUST' THEN
          ec_debug.pl(3,'Ordered Item ID ',p_ordered_item_id);
          ec_debug.pl(3,'Sold to Org  ID ',p_sold_to_org_id);

	SELECT citems.customer_item_desc
	INTO   l_item_description
	FROM   mtl_customer_items citems
	WHERE  citems.customer_item_id = p_ordered_item_id
        AND    citems.customer_id = p_sold_to_org_id;

	IF l_item_description IS NULL THEN
	      SELECT sitems.description
	      INTO   l_item_description
	      FROM   mtl_system_items_vl sitems
	      WHERE  sitems.inventory_item_id = p_inventory_item_id
  	      AND    sitems.organization_id = l_organization_id ;
	END IF ;

	x_item_description := l_item_description ;

   ELSE
/*
     SELECT sitems.description
     INTO   x_item_description
     FROM   mtl_system_items_vl sitems
     WHERE  sitems.inventory_item_id = p_inventory_item_id
     AND    sitems.organization_id = l_organization_id ;
*/
         SELECT NVL(items.description, sitems.description)
         INTO   x_item_description
         FROM   mtl_cross_reference_types types
              , mtl_cross_references items
              , mtl_system_items_vl sitems
         WHERE  types.cross_reference_type = items.cross_reference_type
         AND    items.inventory_item_id = sitems.inventory_item_id
         AND    sitems.organization_id = l_organization_id
         AND    sitems.inventory_item_id = p_inventory_item_id
         AND    items.cross_reference_type = p_item_identifier_type
         AND    items.cross_reference = p_ordered_item -- check that how ordered_item_id can be used
         AND    ROWNUM = 1;

   END IF;
   ec_debug.pl(3,'Item Description is : ',X_ITEM_DESCRIPTION ) ;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
     ec_debug.pl(3,'When no data found then get desc from system items ',SQLERRM);
	begin --bug7554911
		  SELECT sitems.description
		  INTO   x_item_description
		  FROM   mtl_system_items_vl sitems
		  WHERE  sitems.inventory_item_id = p_inventory_item_id
		 AND    sitems.organization_id = l_organization_id ;
	EXCEPTION
		WHEN OTHERS THEN
		oe_debug_pub.add('Unable to get Item Description '||SQLERRM,1);
		NULL;
	  END; --bug7554911
   WHEN OTHERS THEN
     oe_debug_pub.add('Unable to get Item Description '||SQLERRM,1);
     NULL;
END Get_Item_Description;

END ECEPOI;

/
