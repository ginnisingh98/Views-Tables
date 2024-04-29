--------------------------------------------------------
--  DDL for Package Body ECX_INBOUND_TRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_INBOUND_TRIG" as
-- $Header: ECXINBTB.pls 120.18.12010000.3 2009/08/14 11:19:02 nandral ship $

l_procedure          PLS_INTEGER := ecx_debug.g_procedure;
l_statement          PLS_INTEGER := ecx_debug.g_statement;
l_unexpected         PLS_INTEGER := ecx_debug.g_unexpected;
l_procedureEnabled   boolean     := ecx_debug.g_procedureEnabled;
l_statementEnabled   boolean     := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  boolean     := ecx_debug.g_unexpectedEnabled;

TYPE attribute_rec is RECORD
(
attribute_name           varchar2(256),
element_tag_name         varchar2(256),
value               	 varchar2(4000)
);

TYPE    attr_tbl is TABLE of attribute_rec index by BINARY_INTEGER;
/** Define the local variable for storing the attributes with the values **/
i_attr_rec	attr_tbl;


function is_routing_supported
   (
   p_map_id           IN   pls_integer
   ) return boolean is

   l_tar_obj_type  Varchar2(200);
   i_method_name   varchar2(2000):='ecx_inbound_trig.is_routing_supported';

begin
   SELECT object_type
   INTO   l_tar_obj_type
   FROM   ecx_objects
   WHERE  map_id = p_map_id
   AND    object_id = 2;

   if (l_tar_obj_type = 'DB') then
      return false;
   else
      return true;
   end if;

exception
  when others then
     ecx_debug.setErrorInfo(2, 30,
               SQLERRM||' - ECX_INBOUND_TRIG.IS_ROUTING_SUPPORTED');
     if(l_unexpectedEnabled) then
        --ecx_debug.log(l_statement, ecx_utils.i_errbuf, i_method_name);
        ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
     end if;
     raise ecx_utils.program_exit;
end is_routing_supported;


procedure get_element_value
	(
	i_doc		IN	   xmlDOM.DOMDocument,
	i_element	IN	   varchar2,
	i_value		OUT NOCOPY varchar2
	)
is


i_method_name   varchar2(2000) := 'ecx_inbound_trig.get_element_value';
nl	xmlDOM.DOMNodeList := null;
n	pls_integer;
pnode	xmlDOM.DOMNode;
cnode	xmlDOM.DOMNode;
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_doc',i_doc.id,i_method_name);
  ecx_debug.log(l_statement,'i_element',i_element,i_method_name);
end if;
	nl := xmlDOM.getElementsByTagName(i_doc,i_element);

        if (not xmlDOM.isNull(nl))
        then
	   n := xmlDOM.getLength(nl);
	   if n > 0
	   then
	      pnode := xmlDOM.item(nl,0);
	      cnode := xmlDOM.getFirstChild(pnode);
              if (not xmlDOM.isNull(cnode))
              then
    		 i_value := xmlDOM.getNodeValue(cnode);
              end if;
	   end if;
        end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_value',i_value,i_method_name);
end if;
if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;
exception
when others then
        ecx_debug.setErrorInfo(2,30,
                             SQLERRM ||' - ECX_INBOUND_TRIG.GET_ELEMENT_VALUE');
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
	end if;
	raise ecx_utils.program_exit;
end get_element_value;

procedure getAttributes
	(
	i_standard_code		in	varchar2,
	i_doc			IN	xmlDOM.DOMDocument,
        i_standard_type         in      varchar2
	)
is

i_method_name   varchar2(2000) := 'ecx_inbound_trig.get_element_value';
	cursor 	get_attributes
	(
	p_standard_code		IN	varchar2,
	p_standard_type		IN	varchar2
	)
	is
	select	attribute_name,
		element_tag_name
	from	ecx_standard_attributes esa,
        	ecx_standards es
	where	es.standard_code = p_standard_code
	and     es.standard_type = nvl(p_standard_type, 'XML')
	and     esa.standard_id = es.standard_id;

i_string	varchar2(2000) := ' update ecx_doclogs set ';

i_value		varchar2(2000);

i_single	varchar2(3):= '''';
begin
if (l_procedureEnabled) then
 ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_standard_code',i_standard_code,i_method_name);
end if;

if i_standard_code is null
then
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	return;
end if;
/** Initialize the attr table **/
i_attr_rec.DELETE;

/** Get all the Attributes and capture the value **/
for c1 in get_Attributes(p_standard_code=>i_standard_code, p_standard_type =>i_standard_type)
loop
	if ( c1.attribute_name is not null and c1.element_tag_name is not null)
	then
		i_attr_rec(i_attr_rec.COUNT + 1).attribute_name := c1.attribute_name;
		i_attr_rec(i_attr_rec.COUNT).element_tag_name := c1.element_tag_name;

		/** Search for the attribute in the XML File **/
		get_element_value(i_doc,c1.element_tag_name,i_attr_rec(i_attr_rec.COUNT).value);
		if(l_statementEnabled) then
                  ecx_debug.log(l_statement,i_attr_rec(i_attr_rec.COUNT).attribute_name,
		               i_attr_rec(i_attr_rec.COUNT).value,i_method_name);
	        end if;
		i_string := i_string ||' '||i_attr_rec(i_attr_rec.COUNT).attribute_name || ' = '||
			i_single||i_attr_rec(i_attr_rec.COUNT).value || i_single||' ,';
	end if;
end loop;

/** remove the last , and put the statement for the where clause **/
i_string := substr(i_string,1,length(i_string)-1);
i_string := i_string || ' where msgid = '||i_single||ecx_utils.g_msgid||i_single;

if i_attr_rec.count > 0
then
	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'i_string',i_string,i_method_name);
	end if;
	execute immediate i_string;
end if;
if (l_procedureEnabled) then
 ecx_debug.pop(i_method_name);
end if;
exception
when others then
     ecx_debug.setErrorInfo(2,30,SQLERRM ||' - ECX_INBOUND_TRIG.getAttributes');
     if(l_unexpectedEnabled) then
        --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
        ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
     end if;
     raise ecx_utils.program_exit;
end getAttributes;

/**
  For BES - removed send_error
**/

procedure parsepayload
	(
	i_payload	IN	CLOB
	)
is

i_method_name   varchar2(2000) := 'ecx_inbound_trig.parsepayload';
begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
	xmlparser.parseCLOB(ecx_utils.g_parser,i_payload);
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
-- Put All DOM Parser Exceptions Here.
when	xmlDOM.INDEX_SIZE_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.DOMSTRING_SIZE_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.HIERARCHY_REQUEST_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.WRONG_DOCUMENT_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.INVALID_CHARACTER_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.NO_DATA_ALLOWED_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.No_MODIFICATION_ALLOWED_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.NOT_FOUND_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.NOT_SUPPORTED_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when	xmlDOM.INUSE_ATTRIBUTE_ERR then
        ecx_debug.setErrorInfo(1,20,SQLERRM);
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when 	others then
        ecx_debug.setErrorInfo(1,20,SQLERRM||' - ECX_INBOUND_TRIG.PARSEPAYLOAD ');
	if(l_unexpectedEnabled) then
          --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end parsepayload;


/**
 Writes the XML from the CLOB to the file system
**/
procedure writeXMLToFile
	(
	i_xmldoc	IN OUT NOCOPY CLOB
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.writexmltofile';
i_logdir    varchar2(200);

attachment_id pls_integer;
ctemp              varchar2(32767);
clength            pls_integer;
offset            pls_integer := 1;
g_varmaxlength     pls_integer := 1999;
g_instlmode         VARCHAR2(100);

begin
        g_instlmode := wf_core.translate('WF_INSTALL');
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   dbms_lob.createtemporary(i_xmldoc, TRUE,DBMS_LOB.SESSION);
   dbms_lob.trim(i_xmldoc, 0);
   xmlDOM.writetoCLOB(ecx_utils.g_xmldoc,i_xmldoc);

   -- write XML to FS if debug > 0
   if (l_statementEnabled)
   then
	IF g_instlmode = 'EMBEDDED' THEN
		fnd_message.set_name('ecx', 'XML File for logging');
		attachment_id := fnd_log.message_with_attachment(fnd_log.level_statement, substr(ecx_debug.g_aflog_module_name,1,length(ecx_debug.g_aflog_module_name)-4)||'.xml', TRUE);
		if(attachment_id <> -1 AND i_xmldoc is not null) then
		       clength := dbms_lob.getlength(i_xmldoc);
		       while  clength >= offset LOOP
			     ctemp :=  dbms_lob.substr(i_xmldoc,g_varmaxlength,offset);
			     fnd_log_attachment.writeln(attachment_id, ctemp);
			     offset := offset + g_varmaxlength;
		       End Loop;
			fnd_log_attachment.close(attachment_id);
		end if;
	ELSE
	       xmlDOM.writetofile(ecx_utils.g_xmldoc,
		      ecx_utils.g_logdir||ecx_utils.getFileSeparator()||
		      substr(ecx_utils.g_logfile, 1,
		      length(ecx_utils.g_logfile)-4) ||'.xml');
	END IF;
   end if;


  if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
  end if;
end writeXMLToFile;


procedure processXMLData
  (
   i_map_id                IN          pls_integer,
   i_payload               IN          clob,
   i_header_id             IN          pls_integer,
   i_rcv_tp_id             IN          pls_integer,
   i_message_standard      IN          varchar2,
   i_xmldoc                OUT  NOCOPY CLOB,
   i_message_type          IN          varchar2
  )
is

   i_method_name   varchar2(2000) := 'ecx_inbound_trig.processxmldata';
   i_doc        xmlDOM.DOMDocument;
   l_same_map   Boolean;
   l_parseXML   boolean;

begin
   if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
   end if;
   if(l_statementEnabled) then
     ecx_debug.log(l_statement,'ecx_utils.g_map_id',ecx_utils.g_map_id,i_method_name);
     ecx_debug.log(l_statement,'i_map_id',i_map_id,i_method_name);
     ecx_debug.log(l_statement,'i_header_id',i_header_id,i_method_name);
     ecx_debug.log(l_statement,'i_rcv_tp_id',i_rcv_tp_id,i_method_name);
     ecx_debug.log(l_statement,'i_message_standard',i_message_standard,i_method_name);
   end if;
   -- Set the Transaction direction
   ecx_utils.g_rec_tp_id := i_rcv_tp_id;
   ecx_utils.g_direction := 'IN';
   ecx_utils.initialize (i_map_id,l_same_map);
   ecx_utils.g_source := ecx_utils.g_empty_source;
   ecx_utils.g_target := ecx_utils.g_empty_target;

   if (not ecx_utils.dom_printing) then
      ecx_inbound_new.process_xml_doc (i_payload, i_map_id, i_xmldoc, l_parseXML);
   else
      /** Parse the Payload and handle any errors **/
      begin
         parsepayload(i_payload);
      exception
      when others then
           raise ecx_utils.program_exit;
      end;

      i_doc := xmlparser.getDocument(ecx_utils.g_parser);

      /** Assign it to the Global XML Document **/
      ecx_utils.g_xmldoc := xmlDOM.makeNode(i_doc);

      /** Get all the attributes in a generic way for a given standard and save in ecx_doclogs**/
      getAttributes (
              i_message_standard,
              i_doc,
              i_message_type
      );

      ecx_inbound.process_xml_doc (i_doc,i_map_id, i_header_id, i_rcv_tp_id,
                                   i_xmldoc, l_parseXML);
   end if;

 /* bug 8718549 , commented free parser code as it was done twice in this procedure
   xmlparser.freeparser(ecx_utils.g_parser);
   if(ecx_utils.dom_printing = false and ecx_utils.structure_printing = true) -- xmltoxml different dtds.
   then
   xmlparser.freeparser(ecx_utils.g_inb_parser);
   end if;  */

   if (ecx_utils.dom_printing or (ecx_utils.structure_printing and l_parseXML)) then
     if(l_statementEnabled) then
          ecx_debug.log(l_statement,'XML is validated by the parser.',i_method_name);
     end if;
      writeXMLToFile(i_xmldoc);

       begin
         if not xmlDOM.isNull(ecx_utils.g_xmldoc) then
               xmlDOM.freeDocument(xmlDOM.makeDocument(ecx_utils.g_xmldoc));
         end if;
       exception
          when others then
             null;
       end;
   else
      if(l_statementEnabled) then
          ecx_debug.log(l_statement,'XML is not validated by the parser.',i_method_name);
      end if;
   end if;
--for bug 5609625
  xmlparser.freeparser(ecx_utils.g_parser);
   if(ecx_utils.dom_printing = false and ecx_utils.structure_printing = true) -- xmltoxml different dtds.
  then
   xmlparser.freeparser(ecx_utils.g_inb_parser);
  end if;
---end of 5609625

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
   end if;

exception
when 	ecx_utils.program_exit then
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	if(l_unexpectedEnabled) then
           ecx_debug.log(l_unexpected,'Clean-up last_printed',i_method_name);
	end if;
	ecx_print_local.last_printed := -1;

        begin
          if not xmlDOM.isNull(ecx_utils.g_xmldoc) then
                xmlDOM.freeDocument(xmlDOM.makeDocument(ecx_utils.g_xmldoc));
          end if;
        exception
           when others then
              null;
        end;
	raise ecx_utils.program_exit;

when 	others then
        ecx_debug.setErrorInfo(1,20,SQLERRM||' - ECX_INBOUND_TRIG.processXMLData ');
	if(l_unexpectedEnabled) then
		--ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
		ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
		ecx_debug.log(l_unexpected,'Clean-up last_printed',i_method_name);
	end if;
	ecx_print_local.last_printed := -1;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;

        begin
          if not xmlDOM.isNull(ecx_utils.g_xmldoc) then
                xmlDOM.freeDocument(xmlDOM.makeDocument(ecx_utils.g_xmldoc));
          end if;
        exception
           when others then
              null;
        end;
	raise ecx_utils.program_exit;
end processXMLData;

procedure validate_message
	(
        m_msgid                 IN      raw,
	m_message_standard	IN	varchar2,
	m_ext_type		in	varchar2,
	m_ext_subtype		in	varchar2,
	m_party_ext_code	IN	varchar2,
	m_document_number	IN	varchar2,
	m_routing_ext_code	IN	varchar2,
	m_payload		IN	clob,
        m_message_type          IN      varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.validate_message';
i_map_id			pls_integer;
o_ret_code			pls_integer;
o_ret_msg			varchar2(2000);
i_dtd_id			pls_integer;
i_rcv_tp_id			pls_integer;
o_payload			CLOB	default	null;
l_same_map              	Boolean;
i_routing_id			pls_integer;
i_rcv_detail_id			pls_integer;
i_header_id			pls_integer;
i_int_transaction_type		varchar2(200);
i_int_transaction_subtype	varchar2(200);
i_out_msgid                     raw(16);
i_confirmation			pls_integer;
-- i_node_type                     pls_integer;
i_map_type                      pls_integer := 0;

/** trading partner variables **/
p_party_id			number;
p_party_site_id			number;
p_org_id			pls_integer;
p_admin_email			varchar2(256);
retcode				pls_integer;
retmsg				varchar2(2000);

cursor c_tp_details
	(
	p_ext_type		IN	varchar2,
	p_ext_subtype		IN	varchar2,
	p_party_ext_code	in	varchar2,
	p_message_standard	in	varchar2,
	p_message_type          in      varchar2
	)
is
select  etd.map_id 		map_id,
	etd.routing_id 		routing_id,
	etd.tp_header_id	tp_header_id,
	etd.confirmation	confirmation
from    ecx_tp_details etd,
	ecx_ext_processes eep,
	ecx_standards es
where   etd.source_tp_location_code 	= p_party_ext_code
and	eep.ext_type			= p_ext_type
and	eep.ext_subtype 		= p_ext_subtype
and     eep.ext_process_id 		= etd.ext_process_id
and	eep.standard_id			= es.standard_id
and	es.standard_code		= p_message_standard
and     es.standard_type                = nvl(p_message_type, 'XML')
and	eep.direction 			= 'IN';

cursor get_routing_for_extcode
	(
	p_ext_type		IN	varchar2,
	p_ext_subtype		IN	varchar2,
	p_party_ext_code	in	varchar2,
	p_message_standard	in	varchar2,
	p_message_type          in      varchar2
	)
is
select  etd.tp_header_id	tp_header_id,
	etd.tp_detail_id	tp_detail_id
from    ecx_tp_details etd,
	ecx_ext_processes eep,
	ecx_standards es
where   etd.source_tp_location_code 	= p_party_ext_code
and	eep.ext_type			= p_ext_type
and	eep.ext_subtype 		= p_ext_subtype
and     eep.ext_process_id 		= etd.ext_process_id
and	eep.standard_id			= es.standard_id
and	es.standard_code		= p_message_standard
and     es.standard_type                = nvl(p_message_type, 'XML')
and	eep.direction 			= 'OUT';

cursor get_receiver_tp_id
	(
	p_routing_id	IN	pls_integer
	) is
select	tp_header_id
from	ecx_tp_details
where	tp_detail_id = p_routing_id;

begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'m_message_standard',m_message_standard,i_method_name);
  ecx_debug.log(l_statement,'m_ext_type',m_ext_type,i_method_name);
  ecx_debug.log(l_statement,'m_ext_subtype',m_ext_subtype,i_method_name);
  ecx_debug.log(l_statement,'m_party_ext_code',m_party_ext_code,i_method_name);
  ecx_debug.log(l_statement,'m_document_number',m_document_number,i_method_name);
  ecx_debug.log(l_statement,'m_routing_ext_code',m_routing_ext_code,i_method_name);
end if;
ecx_utils.i_ret_code :=0;
ecx_utils.i_errbuf :=null;
--MLS
ecx_utils.i_errparams := null;
ecx_utils.g_ret_code := 0;

--Check whether the Document has been enabled in the Exchange Server.
--If yes get the Map Id.
open 	c_tp_details ( m_ext_type, m_ext_subtype,m_party_ext_code,m_message_standard, m_message_type);
fetch 	c_tp_details
into 	i_map_id,
	i_routing_id,
	i_header_id,
	i_confirmation;

	if c_tp_details%NOTFOUND
	then
                ecx_debug.setErrorInfo(1,30,'ECX_TRANACTION_NOT_ENABLED',
                                            'p_ext_type',
                                             m_ext_type,
                                             'p_ext_subtype',
                                             m_ext_subtype,
                                             'p_party_ext_code',
                                             m_party_ext_code);

		if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'ECX','ECX_TRANACTION_NOT_ENABLED',
		                      i_method_name,
                                     'p_ext_type',
                                      m_ext_type,
                                     'p_ext_subtype',
                                      m_ext_subtype,
                                     'p_party_ext_code',
                                      m_party_ext_code);
		end if;

		close c_tp_details;
		raise ecx_utils.program_exit;
	end if;

close c_tp_details;
-- Set the Sender's tp_id
ecx_utils.g_snd_tp_id := i_header_id;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_map_id',i_map_id,i_method_name);
  ecx_debug.log(l_statement,'i_routing_id',i_routing_id,i_method_name);
  ecx_debug.log(l_statement,'i_header_id',i_header_id,i_method_name);
  ecx_debug.log(l_statement,'i_confirmation',i_confirmation,i_method_name);
end if;

        if (i_routing_id is not null or m_routing_ext_code is not null) then           if not (is_routing_supported(i_map_id)) then
              ecx_debug.setErrorInfo(2, 25, 'ECX_ROUTING_NOT_SUPPORTED');
              raise ecx_utils.program_exit;
           end if;
        end if;

	--Call the Send and Receive TP Id api's over here
	--Pass through transaction Type , Document Number , Sender's Tp Id.
	--i_transaction_type,i_document_number,i_snd_tp_id

	--- Check whether routing enabled or not, if yes , is it static otherwise dynamic
        if i_routing_id is not null
	then
		if m_routing_ext_code is not null
		then
				if(l_statementEnabled) then
                           ecx_debug.log(l_statement,'Dynamic Routing1',m_routing_ext_code,i_method_name);
			end if;
                      open 	get_routing_for_extcode ( m_ext_type,m_ext_subtype,m_routing_ext_code,m_message_standard, m_message_type);
			fetch 	get_routing_for_extcode
			into	i_rcv_tp_id,i_routing_id;

				if get_routing_for_extcode%NOTFOUND
				then
                                      ecx_debug.setErrorInfo(1,30,
                                            'ECX_DYN_ROUTING_NOT_ENABLED',
                                            'p_ext_type',
                                             m_ext_type,
                                             'p_ext_subtype',
                                             m_ext_subtype,
                                             'p_party_ext_code',
                                             m_party_ext_code);

                                     if(l_statementEnabled) then
                                           ecx_debug.log(l_statement,'ECX',
                                                  'ECX_DYN_ROUTING_NOT_ENABLED',
						   i_method_name,
                                                  'p_ext_type',
                                                  m_ext_type,
                                                  'p_ext_subtype',
                                                  m_ext_subtype,
                                                  'p_party_ext_code',
                                                  m_party_ext_code);
				    end if;

					close get_routing_for_extcode;
					raise ecx_utils.program_exit;
				end if;

			close get_routing_for_extcode;

		else
			open 	get_receiver_tp_id (i_routing_id);
			fetch 	get_receiver_tp_id into i_rcv_tp_id;

				if get_receiver_tp_id%NOTFOUND
				then
                                   ecx_debug.setErrorInfo(1,30,
                                            'ECX_STATIC_ROUTING_NOT_ENABLED',
                                            'p_ext_type',
                                             m_ext_type,
                                             'p_ext_subtype',
                                             m_ext_subtype,
                                             'p_party_ext_code',
                                             m_party_ext_code);

                                   if(l_statementEnabled) then
                                     ecx_debug.log(l_statement,'ECX',
                                            'ECX_STATIC_ROUTING_NOT_ENABLED',
					      i_method_name,
                                             'p_ext_type',
                                             m_ext_type,
                                             'p_ext_subtype',
                                             m_ext_subtype,
                                             'p_party_ext_code',
                                             m_party_ext_code);
			            end if;


					close get_receiver_tp_id;
					raise ecx_utils.program_exit;
				end if;
			close  	get_receiver_tp_id;
			if(l_statementEnabled) then
                           ecx_debug.log(l_statement,'Static Routing',i_method_name);
			end if;

		end if;
		ecx_utils.g_rec_tp_id := i_rcv_tp_id;
		if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'Receiver Tp Id ',i_rcv_tp_id,i_method_name);
		end if;

	else
		--- Check for m_routing_ext_code if not null then use it

		if m_routing_ext_code is not null
		then
			if(l_statementEnabled) then
                           ecx_debug.log(l_statement,'Dynamic Routing2',m_routing_ext_code,i_method_name);
			end if;
			open 	get_routing_for_extcode ( m_ext_type,m_ext_subtype,m_routing_ext_code,m_message_standard, m_message_type);
			fetch 	get_routing_for_extcode
			into	i_rcv_tp_id,i_routing_id;

				if get_routing_for_extcode%NOTFOUND
				then
                                        ecx_debug.setErrorInfo(1,30,
                                            'ECX_DYN_ROUTING_NOT_ENABLED',
                                            'p_ext_type',
                                             m_ext_type,
                                             'p_ext_subtype',
                                             m_ext_subtype,
                                             'p_party_ext_code',
                                             m_party_ext_code);

                                        if(l_statementEnabled) then
                                           ecx_debug.log(l_statement,'ECX',
                                                 'ECX_DYN_ROUTING_NOT_ENABLED',
						  i_method_name,
                                                  'p_ext_type',
                                                  m_ext_type,
                                                  'p_ext_subtype',
                                                  m_ext_subtype,
                                                  'p_party_ext_code',
                                                  m_party_ext_code);
				         end if;

					close get_routing_for_extcode;
					raise ecx_utils.program_exit;
				end if;
			close get_routing_for_extcode;
		else
                        -- if neither static nor dynamic routing is specified.
			select count(1) into i_map_type
			from ecx_objects
			where object_type <> 'DB' and map_id = i_map_id;

			if (i_map_type = 2) then
				-- Only if map is xml to xml or dtd to dtd type
				-- Give warning message.
				ecx_utils.g_ret_code := 1;
				if(l_statementEnabled) then
					ecx_debug.log(l_statement,'ecx_utils.g_ret_code',' 1',i_method_name);
				end if;
			end if;
		end if;
        end if;

        -- need to set the g_routing_id here, so that it would set it
        -- for both dynamic and static routing.
        ecx_utils.g_routing_id := i_routing_id;
        if(l_statementEnabled) then
            ecx_debug.log(l_statement,'ecx_utils.g_routing_id',ecx_utils.g_routing_id,
	                 i_method_name);
	end if;

	/**
	Since we have the sender tp_id , we can call the senders_tp_info  and populate the org_id
	**/
	if ( ecx_utils.g_snd_tp_id is not null )
	then
            null;
		ecx_trading_partner_pvt.get_tp_info
			(
			ecx_utils.g_snd_tp_id,
			p_party_id,
			p_party_site_id,
			ecx_utils.g_org_id,
			p_admin_email,
			retcode,
			retmsg
			);
	end if;


   	if(l_statementEnabled) then
            ecx_debug.log(l_statement,'ECX','ECX_START_INBOUND',i_method_name, 'TRANSACTION_TYPE', m_ext_type);
	end if;
	processXMLData
		(
		i_map_id,
		m_payload,
		i_header_id,
		i_rcv_tp_id,
		m_message_standard,
		o_payload,
                m_message_type
		);
	if(l_statementEnabled) then
            ecx_debug.log(l_statement, 'ECX', 'ECX_END_INBOUND',i_method_name, 'TRANSACTION_TYPE', m_ext_type);
	end if;

	savepoint save_xml_doc;

       --If it is a pass through transaction , then put the Message on the Outbound Queue
        if i_routing_id is not null
        then
                if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'Routing Enqueued for MSGID : '|| m_msgid,i_method_name);
		end if;
                put_on_outbound
                (
                o_payload,
                m_document_number,
                i_routing_id,
                m_msgid
                );

        else
                if(l_statementEnabled) then
                 ecx_debug.log(l_statement,'Update doclogs for Msg Id : ' , m_msgid,i_method_name);
		end if;
                ecx_errorlog.update_log_document
                (
                 m_msgid,
                 null,
                 'Inbound processing complete.',
                 ecx_utils.g_logfile,
                 null
                );
        end if;

   if o_payload is not null
   then
   	dbms_lob.freetemporary (o_payload);
   end if;
if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;
exception
when 	ecx_utils.program_exit then
	--ecx_utils.g_map_id := -1;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;

	if o_payload is not null
	then
        	dbms_lob.freetemporary (o_payload);
	end if;
	raise ecx_utils.program_exit;
when 	others then
	--ecx_utils.g_map_id := -1;
        ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_INBOUND_TRIG.VALIDATE_MESSAGE ');
	if(l_unexpectedEnabled) then
            --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;

	if o_payload is not null
	then
        	dbms_lob.freetemporary (o_payload);
	end if;
        if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
end validate_message;


procedure getmsg_from_queue
	(
	i_queue_name	IN	   varchar2,
	i_msgid		OUT NOCOPY RAW
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.getmsg_from_queue';
v_message		system.ecxmsg;
v_dequeueoptions	dbms_aq.dequeue_options_t;
v_messageproperties	dbms_aq.message_properties_t;
c_nummessages		CONSTANT INTEGER :=1;
e_qtimeout		exception;
pragma			exception_init(e_qtimeout,-25228);
l_retcode               pls_integer := 0;
l_retmsg                Varchar2(200) := null;

begin
if (l_procedureEnabled) then
   ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_queue_name',i_queue_name,i_method_name);
end if;

v_dequeueoptions.navigation := dbms_aq.FIRST_MESSAGE;
v_dequeueoptions.dequeue_mode := dbms_aq.BROWSE;
for i in 1..c_nummessages
loop
	v_dequeueoptions.wait:=dbms_aq.NO_WAIT;

	dbms_aq.dequeue
		(
		queue_name=>i_queue_name,
		dequeue_options=>v_dequeueoptions,
		message_properties=>v_messageproperties,
		payload=>v_message,
		msgid=> i_msgid
		);

	--Retrieve the Message Attributes

        if(l_statementEnabled) then
	  ecx_debug.log(l_statement,'Message Standard',v_message.message_standard,i_method_name);
	  ecx_debug.log(l_statement,'Message Type',v_message.message_type,i_method_name);
	  ecx_debug.log(l_statement,'Transaction Type',v_message.transaction_type,i_method_name);
	  ecx_debug.log(l_statement,'Transaction Sub Type',v_message.transaction_subtype,i_method_name);
	  ecx_debug.log(l_statement,'Party Id',v_message.partyid,i_method_name);
	  ecx_debug.log(l_statement,'party Site Id',v_message.party_site_id,i_method_name);
	  ecx_debug.log(l_statement,'party type',v_message.party_type,i_method_name);
	  ecx_debug.log(l_statement,'protocol_type ',v_message.protocol_type,i_method_name);
	  ecx_debug.log(l_statement,'Protocol  Address ',v_message.protocol_address,i_method_name);
	  ecx_debug.log(l_statement,'Username ',v_message.username,i_method_name);
	  ecx_debug.log(l_statement,'Password ',v_message.password,i_method_name);
        end if;
	begin
             ecx_errorlog.log_document (
                l_retcode,
                l_retmsg,
		i_msgid,
		v_message.message_type,
		v_message.message_standard,
		v_message.transaction_type,
		v_message.transaction_subtype,
		v_message.document_number,
		v_message.partyid,
		v_message.party_site_id,
		v_message.party_type,
		v_message.protocol_type,
		v_message.protocol_address,
		v_message.username,
		v_message.password,
		v_message.attribute1,
		v_message.attribute2,
		v_message.attribute3,
		v_message.attribute4,
		v_message.attribute5,
		v_message.payload,
                null
		);

            if (l_retcode = 1) then
              if(l_unexpectedEnabled) then
                ecx_debug.log(l_unexpected, l_retmsg,i_method_name);
              end if;
            elsif (l_retcode >= 2 ) then
              if(l_unexpectedEnabled) then
                ecx_debug.log(l_unexpected,l_retmsg,i_method_name);
              end if;
               raise ecx_utils.program_exit;
            end if;
        end;
	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'MessageId', i_msgid,i_method_name);
	end if;

end loop;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_msgid',i_msgid,i_method_name);
end if;
if (l_procedureEnabled) then
    ecx_debug.pop(i_method_name);
end if;
exception
when ecx_utils.program_exit then
	raise;
when others then
        ecx_debug.setErrorInfo(2,30,SQLERRM||' - ECX_INBOUND_TRIG.GETMSG_FROM_QUEUE');
	 if(l_unexpectedEnabled) then
            --ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
          ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        raise ecx_utils.program_exit;
end getmsg_from_queue;


procedure put_on_outbound
	(
	i_xmldoc		IN OUT	NOCOPY CLOB,
	i_document_number	IN	       varchar2,
	i_tp_detail_id		IN	       pls_integer,
        i_msgid                 IN             raw
	)
	is


i_method_name   varchar2(2000) := 'ecx_inbound_trig.put_on_outbound';
e_qtimeout              exception;

i_out_msgid             raw(16);
i_standard_type		varchar2(20);
i_standard_code		varchar2(20);
i_ext_type		varchar2(200);
i_ext_subtype		varchar2(200);
i_source_code		varchar2(200);
i_destination_code	varchar2(200);
i_destination_type	varchar2(200);
i_destination_address	ecx_tp_details.protocol_address%TYPE;
i_username		varchar2(200);
i_password		varchar2(500);
i_hub_user_id		number	DEFAULT 0;
pragma                  exception_init(e_qtimeout,-25228);
i_event                 wf_event_t;
i_from_agt              wf_agent_t := wf_agent_t(NULL, NULL);
i_system                varchar2(200);
i_int_type              varchar2(200);
i_int_subtype           varchar2(200);
i_party_id              number;
i_party_site_id         number;
i_party_type            varchar2(200);

begin

if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_document_number',i_document_number,i_method_name);
  ecx_debug.log(l_statement,'i_tp_detail_id',i_tp_detail_id,i_method_name);
end if;

	begin
		select	es.standard_type		standard_type,
			es.standard_code		standard_code,
			source_tp_location_code 	source,
			external_tp_location_code 	destination,
			protocol_type,
                	protocol_address,
			username,
			password,
			hub_user_id,
			eep.ext_type	ext_type,
			eep.ext_subtype	ext_subtype,
                        et.transaction_type,
                        et.transaction_subtype,
                        eth.party_id,
                        eth.party_site_id,
                        eth.party_type
        	into    i_standard_type,
			i_standard_code,
			i_source_code,
			i_destination_code,
			i_destination_type,
                	i_destination_address,
			i_username,
			i_password,
			i_hub_user_id,
			i_ext_type,
			i_ext_subtype,
                        i_int_type,
                        i_int_subtype,
                        i_party_id,
                        i_party_site_id,
                        i_party_type
		from 	ecx_tp_details 		etd,
			ecx_ext_processes 	eep,
			ecx_standards		es,
                        ecx_transactions        et,
                        ecx_tp_headers          eth
        	where   etd.tp_detail_id = i_tp_detail_id
		and	es.standard_id = eep.standard_id
		and	eep.ext_process_id = etd.ext_process_id
                and     eep.transaction_id = et.transaction_id
                and     eep.direction = 'OUT'
                and     etd.tp_header_id = eth.tp_header_id;
	exception
	when others then
                ecx_debug.setErrorInfo(1,25,'ECX_NO_UNIQUE_TP_SETUP');
		raise ecx_utils.program_exit;
	end;

	if i_hub_user_id is not null
	then
		begin
			select	hub_entity_code,
				protocol_type,
				protocol_address,
				username,
				password
			into	i_source_code,
				i_destination_type,
                		i_destination_address,
				i_username,
				i_password
			from	ecx_hubs eh,
				ecx_hub_users ehu
			where	eh.hub_id = ehu.hub_id
			and	ehu.hub_user_id = i_hub_user_id;
		exception
		when others then
                      ecx_debug.setErrorInfo(1,25,'ECX_DELIVERY_HUB_NOT_SETUP');
	              raise ecx_utils.program_exit;
		end;
	end if;

	if i_destination_address is null
	then
                ecx_debug.setErrorInfo(1,25,'ECX_PROTOCOL_ADDR_NULL',
                                             'p_tp_location_code', i_source_code,
                                             'p_transaction_type', i_ext_type,
                                             'p_transaction_subtype', i_ext_subtype,
                                             'p_standard', i_standard_code);

		raise ecx_utils.program_exit;
	end if;
        if (l_statementEnabled) then
          ecx_debug.log(l_statement,'i_standard_type',i_standard_type,i_method_name);
          ecx_debug.log(l_statement,'i_standard_code',i_standard_code,i_method_name);
          ecx_debug.log(l_statement,'i_ext_type',i_ext_type,i_method_name);
          ecx_debug.log(l_statement,'i_ext_subtype',i_ext_subtype,i_method_name);
          ecx_debug.log(l_statement,'i_int_type', i_int_type,i_method_name);
          ecx_debug.log(l_statement,'i_int_subtype', i_int_subtype,i_method_name);
          ecx_debug.log(l_statement,'i_source_code',i_source_code,i_method_name);
          ecx_debug.log(l_statement,'i_destination_code',i_destination_code,i_method_name);
          ecx_debug.log(l_statement,'i_destination_type',i_destination_type,i_method_name);
          ecx_debug.log(l_statement,'i_destination_address',i_destination_address,i_method_name);
          ecx_debug.log(l_statement,'i_username',i_username,i_method_name);
          ecx_debug.log(l_statement,'i_party_id',i_party_id,i_method_name);
          ecx_debug.log(l_statement,'i_party_site_id', i_party_site_id,i_method_name);
          ecx_debug.log(l_statement,'i_party_type', i_party_type,i_method_name);
        end if;
        -- call ecx_out_wf_qh.enqueue with the correct parameters
        wf_event_t.initialize(i_event);
        i_event.addParameterToList('PARTY_TYPE', i_party_type);
        i_event.addParameterToList('PARTYID', i_party_id);
        i_event.addParameterToList('PARTY_SITE_ID', i_source_code);
        -- added this for passthrough logging purposes in ecx_out_wf_qh
        i_event.addParameterToList('INT_PARTY_SITE_ID', i_party_site_id);
        i_event.addParameterToList('DOCUMENT_NUMBER', i_document_number);
        i_event.addParameterToList('MESSAGE_TYPE', i_standard_type);
        i_event.addParameterToList('MESSAGE_STANDARD', i_standard_code);
        i_event.addParameterToList('TRANSACTION_TYPE', i_ext_type);
        i_event.addParameterToList('TRANSACTION_SUBTYPE', i_ext_subtype);
        i_event.addParameterToList('INT_TRANSACTION_TYPE', i_int_type);
        i_event.addParameterToList('INT_TRANSACTION_SUBTYPE', i_int_subtype);
        i_event.addParameterToList('PROTOCOL_TYPE', i_destination_type);
        i_event.addParameterToList('PROTOCOL_ADDRESS', i_destination_address);
        i_event.addParameterToList('USERNAME', i_username);
        i_event.addParameterToList('PASSWORD', i_password);
        i_event.addParameterToList('ATTRIBUTE1', ecx_utils.g_company_name);
        i_event.addParameterToList('ATTRIBUTE2', null);
        i_event.addParameterToList('ATTRIBUTE3', i_destination_code);
        i_event.addParameterToList('ATTRIBUTE4', null);
        i_event.addParameterToList('ATTRIBUTE5', null);
        i_event.addParameterToList('DIRECTION', ecx_utils.g_direction);
        i_event.addParameterToList('LOGFILE', ecx_utils.g_logfile);
        i_event.addParameterToList('ECX_MSG_ID', i_msgid);

        i_event.event_data := i_xmldoc;

        -- set the from agent
        select  name
        into    i_system
        from    wf_systems
        where   guid = wf_core.translate('WF_SYSTEM_GUID');

        i_from_agt.setname('ECX_OUTBOUND');
        i_from_agt.setsystem(i_system);

        i_event.setFromAgent(i_from_agt);

        if(l_statementEnabled) then
          ecx_debug.log(l_statement,'Calling WF_EVENT.Send for Enqueue',i_method_name);
        end if;
        wf_event.send(i_event);
        ecx_errorlog.outbound_log(i_event);

        i_out_msgid := ecx_out_wf_qh.msgid;

        -- check the retcode and retmsg. This should be populated here only
        -- in the case of dup val index when inserting in doclogs (since no
        -- exception is raised in this case)
        if (ecx_out_wf_qh.retmsg is not null) then
           --ecx_utils.error_type := 30;
           --ecx_utils.i_ret_code := ecx_out_wf_qh.retcode;
           --ecx_utils.i_errbuf := ecx_out_wf_qh.retmsg;
          ecx_debug.setErrorInfo(ecx_out_wf_qh.retcode,30,ecx_out_wf_qh.retmsg);
           if(l_statementEnabled) then
            ecx_debug.log(l_statement,ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                ecx_utils.i_errparams),i_method_name); -- MLS
	   end if;
        end if;

if(l_statementEnabled) then
    ecx_debug.log(l_statement,'Routed MsgId',i_out_msgid,i_method_name);
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
WHEN ECX_UTILS.PROGRAM_EXIT THEN
	--dbms_lob.freetemporary(i_xmldoc);
	if (l_procedureEnabled) then
           ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when others then
	--dbms_lob.freetemporary(i_xmldoc);
        if (ecx_out_wf_qh.retmsg is null AND ecx_out_wf_qh.retcode = 0)
        then
                ecx_debug.setErrorInfo(2,30,SQLERRM || ' - ECX_INBOUND_TRIG.PUT_ON_OUTBOUND');
        else
                --ecx_utils.i_ret_code := ecx_out_wf_qh.retcode;
                --ecx_utils.i_errbuf := ecx_out_wf_qh.retmsg;
                  ecx_debug.setErrorInfo(ecx_out_wf_qh.retcode,30,ecx_out_wf_qh.retmsg);
        end if;
        --ecx_utils.error_type := 30;
	if(l_unexpectedEnabled) then
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                ecx_utils.i_errparams),i_method_name); -- MLS
	end if;
	raise ecx_utils.program_exit;
end put_on_outbound;

/**
 Old put_on_outbound - pre BES integration
 Present for backward compatibility
**/

procedure put_on_outbound
	(
	i_xmldoc		IN OUT NOCOPY CLOB,
	i_document_number	IN	      varchar2,
	i_tp_detail_id		IN	      pls_integer
	)
	is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.put_on_outbound';
v_message               system.ecxmsg;
v_enqueueoptions        dbms_aq.enqueue_options_t;
v_messageproperties     dbms_aq.message_properties_t;
i_msgid                 raw(16);
c_nummessages           CONSTANT INTEGER :=1;
e_qtimeout              exception;

i_standard_type		varchar2(20);
i_standard_code		varchar2(20);
i_ext_type		varchar2(200);
i_ext_subtype		varchar2(200);
i_source_code		varchar2(200);
i_destination_code	varchar2(200);
i_destination_type	varchar2(200);
i_destination_address ecx_tp_details.protocol_address%TYPE;
i_username		varchar2(200);
i_password		varchar2(500);
m_password		varchar2(500);
i_hub_user_id		number;
i_party_type            varchar2(30) := null;
o_retcode		pls_integer;
o_retmsg		varchar2(2000);
pragma                  exception_init(e_qtimeout,-25228);
l_retcode               pls_integer := 0;
l_retmsg                Varchar2(200) := null;

begin
if (l_procedureEnabled) then
  ecx_debug.push(i_method_name);
end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_document_number',i_document_number,i_method_name);
  ecx_debug.log(l_statement,'i_tp_detail_id',i_tp_detail_id,i_method_name);
end if;

	begin
		select	es.standard_type		standard_type,
			es.standard_code		standard_code,
			source_tp_location_code 	source,
			external_tp_location_code 	destination,
			protocol_type,
                	protocol_address,
			username,
			password,
			hub_user_id,
			eep.ext_type	ext_type,
                        eep.ext_subtype ext_subtype
        	into    i_standard_type,
			i_standard_code,
			i_source_code,
			i_destination_code,
			i_destination_type,
                	i_destination_address,
			i_username,
			i_password,
			i_hub_user_id,
			i_ext_type,
			i_ext_subtype
		from 	ecx_tp_details 		etd,
			ecx_ext_processes 	eep,
			ecx_standards		es
        	where   etd.tp_detail_id = i_tp_detail_id
		and	es.standard_id = eep.standard_id
		and	eep.ext_process_id = etd.ext_process_id;

	exception
	when others then
                ecx_debug.setErrorInfo(1,25,'ECX_NO_UNIQUE_TP_SETUP');
		raise ecx_utils.program_exit;
	end;

	if i_hub_user_id is not null
	then
		begin
			select	hub_entity_code,
				protocol_type,
				protocol_address,
				username,
				password
			into	i_source_code,
				i_destination_type,
                		i_destination_address,
				i_username,
				i_password
			from	ecx_hubs eh,
				ecx_hub_users ehu
			where	eh.hub_id = ehu.hub_id
			and	ehu.hub_user_id =  i_hub_user_id;

		exception
		when others then
                    ecx_debug.setErrorInfo(1,25,'ECX_DELIVERY_HUB_NOT_SETUP');
		    if(l_unexpectedEnabled) then
                      ecx_debug.log(l_unexpected,'ERROR', SQLERRM,i_method_name);
		    end if;
		    raise ecx_utils.program_exit;
		end;
	end if;


	if i_destination_address is null
	then
                ecx_debug.setErrorInfo(1,25,'ECX_PROTOCOL_ADDR_NULL',
                                             'p_tp_location_code', i_source_code,
                                             'p_transaction_type', i_ext_type,
                                             'p_transaction_subtype', i_ext_subtype,
                                             'p_standard', i_standard_code);
		raise ecx_utils.program_exit;
	end if;

	ecx_obfuscate.ecx_data_encrypt
		(
		i_password,
		'D',
		m_password,
		o_retcode,
		o_retmsg
		);

	if (o_retcode > 0)
	then
		--ecx_utils.i_ret_code := o_retcode;
	        --ecx_utils.i_errbuf := o_retmsg;
		--ecx_utils.error_type := 30;
                ecx_debug.setErrorInfo(o_retcode,30,o_retmsg);
		raise ecx_utils.program_exit;
	end if;
if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_standard_type',i_standard_type,i_method_name);
  ecx_debug.log(l_statement,'i_standard_code',i_standard_code,i_method_name);
  ecx_debug.log(l_statement,'i_ext_type',i_ext_type,i_method_name);
  ecx_debug.log(l_statement,'i_ext_subtype',i_ext_subtype,i_method_name);
  ecx_debug.log(l_statement,'i_source_code',i_source_code,i_method_name);
  ecx_debug.log(l_statement,'i_destination_code',i_destination_code,i_method_name);
  ecx_debug.log(l_statement,'i_destination_type',i_destination_type,i_method_name);
  ecx_debug.log(l_statement,'i_destination_address',i_destination_address,i_method_name);
  ecx_debug.log(l_statement,'i_username',i_username,i_method_name);
end if;
--ecx_debug.log(3,'i_password',i_password);

		v_message:=system.ecxmsg
		 (
		 i_standard_type,
		 i_standard_code,
		 i_ext_type,
		 i_ext_subtype,
		 i_document_number,
		 null,
		 i_source_code,
		 null,
		 i_destination_type,
		 i_destination_address,
		 i_username,
		 m_password,
		 i_xmldoc,
		 ecx_utils.g_company_name,
		 null,
		 i_destination_code,
		 null,
		 null
		);

        begin
           select party_type
           into   i_party_type
           from   ecx_tp_headers eth,
                  ecx_tp_details etd
           where  eth.tp_header_id = etd.tp_header_id
           and    etd.tp_detail_id = i_tp_detail_id;
        exception
        when others then
                ecx_debug.setErrorInfo(1,30, SQLERRM);
                raise ecx_utils.program_exit;
        end;

        v_message.party_type := i_party_type;

	v_messageproperties.correlation := 'OXTA';
		 -- Enqueue
		 dbms_aq.enqueue
		 (
		 queue_name=>'ECX_OUTBOUND',
		 enqueue_options=>v_enqueueoptions,
		 message_properties=>v_messageproperties,
		 payload=>v_message,
		 msgid=>i_msgid
		 );

	--Keep a log of the Outgoing Messages
        begin
             ecx_errorlog.log_document (
                l_retcode,
                l_retmsg,
                i_msgid,
                v_message.message_type,
                v_message.message_standard,
                v_message.transaction_type,
                v_message.transaction_subtype,
                v_message.document_number,
                v_message.partyid,
                v_message.party_site_id,
                v_message.party_type,
                v_message.protocol_type,
                v_message.protocol_address,
                v_message.username,
                v_message.password,
                v_message.attribute1,
                v_message.attribute2,
                v_message.attribute3,
                v_message.attribute4,
                v_message.attribute5,
                v_message.payload,
                null,
                null,
                'OUT'
                );

            if (l_retcode = 1) then
               if(l_unexpectedEnabled) then
                  ecx_debug.log(l_unexpected, l_retmsg,i_method_name);
	       end if;
            elsif (l_retcode >= 2 ) then
               if(l_unexpectedEnabled) then
                  ecx_debug.log(l_unexpected, l_retmsg,i_method_name);
	       end if;
               raise ecx_utils.program_exit;
            end if;
        end;

        -- maintain attachment mappings if this is a passthrough case
        ecx_attachment.remap_attachments(i_msgid);

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'Routed MsgId',i_msgid,i_method_name);
end if;
if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
exception
WHEN ECX_UTILS.PROGRAM_EXIT THEN
	i_hub_user_id := null;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	raise ecx_utils.program_exit;
when others then
	i_hub_user_id := null;
        ecx_debug.setErrorInfo(2,30, SQLERRM|| ' - ECX_INBOUND_TRIG.PUT_ON_OUTBOUND');
        if(l_unexpectedEnabled) then
		--ecx_debug.log(l_statement,ecx_utils.i_errbuf,i_method_name);
		ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
	raise ecx_utils.program_exit;
end put_on_outbound;

--This is for Internal testing and Debugging Only. Takes the Message
--off from the given Queue in the Browse Mode and processes it.

procedure processmsg_from_queue
	(
	i_queue_name		IN	varchar2,
	i_debug_level		IN	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.processmsg_from_queue';
v_msgid			raw(16);
i_logdir		varchar2(200);
i_trigger_id		pls_integer;

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
fnd_profile.get('AFLOG_ENABLED',logging_enabled);
fnd_profile.get('AFLOG_MODULE',module);
if ecx_debug.g_v_module_name is null then
 ecx_debug.module_enabled;
end if;

if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
OR module='%')
AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
	ecx_logging_enabled := true;
end if;
-- /logging enabled

IF (ecx_logging_enabled ) THEN
	ecx_utils.getLogDirectory;
	ecx_debug.enable_debug_new(i_debug_level,ecx_utils.g_logdir, 'IN'||i_queue_name||'.log', 'in.'||i_queue_name||'.log');
END IF;

/* Assign local variables with the ecx_debug global variables*/
l_procedure          := ecx_debug.g_procedure;
l_statement          := ecx_debug.g_statement;
l_unexpected         := ecx_debug.g_unexpected;
l_procedureEnabled   := ecx_debug.g_procedureEnabled;
l_statementEnabled   := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_queue_name',i_queue_name,i_method_name);
  ecx_debug.log(l_statement,'i_debug_level',i_debug_level,i_method_name);
end if;

		getmsg_from_queue(i_queue_name,v_msgid);

		--validate_message( v_msgid, i_debug_level,i_trigger_id);

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;

exception
when ecx_utils.program_exit then
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
when others then
        ecx_utils.i_errbuf := SQLERRM || ' - ECX_INBOUND_TRIG.PROCESSMSG_FROM_QUEUE';
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
end processmsg_from_queue;


procedure processmsg_from_table
	(
	i_msgid			IN	RAW,
	i_debug_level		IN	pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.processmsg_from_table';
i_logdir		varchar2(200);
i_trigger_id		pls_integer;

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
fnd_profile.get('AFLOG_ENABLED',logging_enabled);
fnd_profile.get('AFLOG_MODULE',module);

if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
OR module='%')
AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
	ecx_logging_enabled := true;
end if;
-- /logging enabled

IF (ecx_logging_enabled ) THEN
	--get the Log directory from the Profile Option.
	ecx_utils.getLogDirectory;
	ecx_debug.enable_debug_new(i_debug_level, ecx_utils.g_logdir, 'IN' ||i_msgid||'.log', 'in.'||i_msgid||'.log');
END IF;

/* Assign local variables with the ecx_debug global variables*/
l_procedure          := ecx_debug.g_procedure;
l_statement          := ecx_debug.g_statement;
l_unexpected         := ecx_debug.g_unexpected;
l_procedureEnabled   := ecx_debug.g_procedureEnabled;
l_statementEnabled   := ecx_debug.g_statementEnabled;
l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

if (l_procedureEnabled) then
     ecx_debug.push(i_method_name);
end if;

if(l_statementEnabled) then
  ecx_debug.log(l_statement,'i_msgid',i_msgid,i_method_name);
  ecx_debug.log(l_statement,'i_debug_level',i_debug_level,i_method_name);
end if;

		--validate_message( i_msgid, i_debug_level,i_trigger_id);

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;

exception
when ecx_utils.program_exit then
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

when others then
        ecx_utils.i_errbuf := SQLERRM || ' - ECX_INBOUND_TRIG.PROCESSMSG_FROM_TABLE';
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
end processmsg_from_table;

/** New wrap validate message for use with BES
    Removed AUTONOMOUS_TRANSACTION, commit and rollback
**/
procedure wrap_validate_message
        (
        i_msgid                 IN      RAW,
        i_debug_level           IN      pls_integer
        )
is
g_instlmode         VARCHAR2(100);
i_method_name   varchar2(2000) := 'ecx_inbound_trig.wrap_validate_message';
i_logdir                varchar2(200);
i_logfile               varchar2(200);
msg_not_found           exception;

m_transaction_type      varchar2(200);
m_transaction_subtype   varchar2(200);
m_message_standard      varchar2(200);
m_message_type          varchar2(200);
m_document_number       varchar2(200);
m_routing_ext_code      varchar2(200);
m_party_ext_code        varchar2(200);
m_payload               CLOB;
m_internal_control_number       pls_integer;

cursor get_run_s
is
select  ecx_output_runs_s.NEXTVAL
from    dual;

cursor  get_msg
(
p_msgid                 in      raw
)
is
select  message_standard,
        message_type,
        transaction_type,
        transaction_subtype,
        party_site_id,
        payload,
        document_number,
        attribute3,
        internal_control_number
from    ecx_doclogs
where   msgid = p_msgid
for update;
p_aflog_module_name         VARCHAR2(2000) ;

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin

        open    get_msg (i_msgid);
        fetch   get_msg
        into    m_message_standard,
                m_message_type,
                m_transaction_type,
                m_transaction_subtype,
                m_party_ext_code,
                m_payload,
                m_document_number,
                m_routing_ext_code,
                m_internal_control_number;

         if get_msg%NOTFOUND
        then
                close get_msg;
                raise msg_not_found;
        end if;

        close get_msg;
ecx_utils.g_direction := 'IN';
ecx_utils.g_logfile :=null;
ecx_debug.g_v_module_name :='ecx.plsql.';
        ecx_utils.g_transaction_type := m_transaction_type;
        ecx_utils.g_transaction_subtype := m_transaction_subtype;
        ecx_utils.g_msgid := i_msgid;
begin
                select  standard_id
                into    ecx_utils.g_standard_id
                from    ecx_standards
                where   standard_code = m_message_standard
                and     standard_type = nvl(m_message_type, 'XML');
                if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'Standard id',ecx_utils.g_standard_id,i_method_name);
                end if;
          exception
        when others then
                ecx_debug.setErrorInfo(1,30,'ECX_UNSUPPORTED_STANDARD');
                raise ecx_utils.program_exit;
        end;
ecx_debug.module_enabled;
 g_instlmode := wf_core.translate('WF_INSTALL');

  if(g_instlmode = 'EMBEDDED')
  THEN
    fnd_profile.get('AFLOG_ENABLED',logging_enabled);
    fnd_profile.get('AFLOG_MODULE',module);
     if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
     AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
     OR module='%')
       AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
      ecx_logging_enabled := true;
    end if;
  elsif(g_instlmode = 'STANDALONE')
  then
    if (i_debug_level > 0) then
      ecx_logging_enabled := true;
    end if;
  end if;
	IF (ecx_logging_enabled ) THEN
		/**
		Fetch the Run Id for the Transaction
		**/
		open    get_run_s;
		fetch   get_run_s
		into    ecx_utils.g_run_id;
		close   get_run_s;

		--get the Log directory from the Profile Option.
		ecx_utils.getLogDirectory;

		i_logfile := substr(m_message_standard,1,10)||'IN'||substr(m_transaction_type,1,20)||substr(m_transaction_subtype,1,20)||ecx_utils.g_run_id||'.log';

		p_aflog_module_name := '';
		IF (m_message_standard is not null) THEN
			p_aflog_module_name := p_aflog_module_name||m_message_standard||'.';
		END IF;
		p_aflog_module_name := p_aflog_module_name || 'in.';
		IF (m_transaction_type is not null) THEN
			p_aflog_module_name := p_aflog_module_name||m_transaction_type||'.';
		END IF;
		IF (m_transaction_subtype is not null) THEN
			p_aflog_module_name := p_aflog_module_name||m_transaction_subtype||'.';
		END IF;
		IF (ecx_utils.g_run_id is not null) THEN
			p_aflog_module_name := p_aflog_module_name||ecx_utils.g_run_id;
		END IF;
		p_aflog_module_name := p_aflog_module_name||'.log';

		ecx_debug.enable_debug_new(i_debug_level,ecx_utils.g_logdir,i_logfile, p_aflog_module_name);
	END IF;

        /* Assign local variables with the ecx_debug global variables*/
	l_procedure          := ecx_debug.g_procedure;
	l_statement          := ecx_debug.g_statement;
	l_unexpected         := ecx_debug.g_unexpected;
	l_procedureEnabled   := ecx_debug.g_procedureEnabled;
	l_statementEnabled   := ecx_debug.g_statementEnabled;
	l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

	if (l_procedureEnabled) then
		ecx_debug.push(i_method_name);
	end if;

        if(l_statementEnabled) then
         ecx_debug.log(l_statement,'i_msgid',i_msgid,i_method_name);
         ecx_debug.log(l_statement,'i_debug_level',i_debug_level,i_method_name);
	end if;
        ecx_utils.g_document_id :=m_internal_control_number;

	IF (ecx_logging_enabled and g_instlmode = 'STANDALONE') THEN
		ecx_utils.g_logfile :=i_logfile;
	END IF;

	/*ecx_utils.g_direction := 'IN';

        ecx_utils.g_transaction_type := m_transaction_type;
        ecx_utils.g_transaction_subtype := m_transaction_subtype;
        ecx_utils.g_msgid := i_msgid;*/

        /*begin
                select  standard_id
                into    ecx_utils.g_standard_id
                from    ecx_standards
                where   standard_code = m_message_standard
                and     standard_type = nvl(m_message_type, 'XML');
                if(l_statementEnabled) then
                  ecx_debug.log(l_statement,'Standard id',ecx_utils.g_standard_id,i_method_name);
		end if;
          exception
        when others then
                ecx_debug.setErrorInfo(1,30,'ECX_UNSUPPORTED_STANDARD');
                raise ecx_utils.program_exit;
        enid;*/
        validate_message
                (
                i_msgid,
                m_message_standard,
                m_transaction_type,
                m_transaction_subtype,
                m_party_ext_code,
                m_document_number,
                m_routing_ext_code,
                m_payload,
                m_message_type
                );

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;

exception
when ecx_utils.program_exit then
	--ecx_utils.g_map_id := -1;
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        raise;
when msg_not_found then
	--ecx_utils.g_map_id := -1;
        ecx_debug.setErrorInfo(1,30,'ECX_MSGID_NOT_FOUND',
                                    'p_msgid',
                                    i_msgid);
        close get_msg;
        raise;
when others then
	--ecx_utils.g_map_id := -1;
        ecx_debug.setErrorInfo(2,30,SQLERRM || ' - ECX_INBOUND_TRIG.WRAP_VALIDATE_MESSAGE');
         if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
        if (l_procedureEnabled) then
            ecx_debug.pop(i_method_name);
        end if;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

        raise;
end wrap_validate_message;

/**
  Old wrap validate message - pre BES integration.
  Present for backward compatibility.
**/
procedure wrap_validate_message
	(
	i_msgid			IN	   RAW,
	i_debug_level		IN	   pls_integer,
	i_trigger_id		OUT NOCOPY pls_integer
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.wrap_validate_message';
i_logdir		varchar2(200);
i_logfile		varchar2(200);
PRAGMA          	AUTONOMOUS_TRANSACTION;
msg_not_found		exception;

m_transaction_type	varchar2(200);
m_transaction_subtype	varchar2(200);
m_message_standard	varchar2(200);
m_message_type          varchar2(200);
m_document_number	varchar2(200);
m_routing_ext_code	varchar2(200);
m_party_ext_code	varchar2(200);
m_payload		CLOB;
m_internal_control_number	pls_integer;

cursor get_run_s
is
select  ecx_output_runs_s.NEXTVAL
from    dual;


cursor 	get_msg
(
p_msgid			in	raw
)
is
select	message_standard,
        message_type,
	transaction_type,
	transaction_subtype,
	party_site_id,
	payload,
	document_number,
	attribute3,
	internal_control_number
from	ecx_doclogs
where	msgid = p_msgid
for update;
p_aflog_module_name         VARCHAR2(2000) ;

-- logging enabled
ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
ecx_utils.g_logfile :=null;
ecx_debug.g_v_module_name :='ecx.plsql.';
fnd_profile.get('AFLOG_ENABLED',logging_enabled);
fnd_profile.get('AFLOG_MODULE',module);
if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
OR module='%')
AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
	ecx_logging_enabled := true;
end if;
-- /logging enabled

	open 	get_msg (i_msgid);
	fetch 	get_msg
	into 	m_message_standard,
                m_message_type,
		m_transaction_type,
		m_transaction_subtype,
		m_party_ext_code,
		m_payload,
		m_document_number,
		m_routing_ext_code,
		m_internal_control_number;

	if get_msg%NOTFOUND
	then
		close get_msg;
		raise msg_not_found;
	end if;

	close get_msg;

	IF (ecx_logging_enabled ) THEN
		/**
		Fetch the Run Id for the Transaction
		**/
		open    get_run_s;
		fetch   get_run_s
		into    ecx_utils.g_run_id;
		close   get_run_s;

		--get the Log directory from the Profile Option.
		ecx_utils.getLogDirectory;

		i_logfile := m_message_standard||'IN'||m_transaction_type||m_transaction_subtype||ecx_utils.g_run_id||'.log';

		p_aflog_module_name := '';
		IF (m_message_standard is not null) THEN
			p_aflog_module_name := p_aflog_module_name||m_message_standard||'.';
		END IF;
		p_aflog_module_name := p_aflog_module_name || 'in.';
		IF (m_transaction_type is not null) THEN
			p_aflog_module_name := p_aflog_module_name||m_transaction_type||'.';
		END IF;
		IF (m_transaction_subtype is not null) THEN
			p_aflog_module_name := p_aflog_module_name||m_transaction_subtype||'.';
		END IF;
		IF (ecx_utils.g_run_id is not null) THEN
			p_aflog_module_name := p_aflog_module_name||ecx_utils.g_run_id;
		END IF;
		p_aflog_module_name := p_aflog_module_name||'.log';

		ecx_debug.enable_debug_new(i_debug_level,ecx_utils.g_logdir,i_logfile, p_aflog_module_name);
	END IF;

        /* Assign local variables with the ecx_debug global variables*/
        l_procedure          := ecx_debug.g_procedure;
        l_statement          := ecx_debug.g_statement;
        l_unexpected         := ecx_debug.g_unexpected;
        l_procedureEnabled   := ecx_debug.g_procedureEnabled;
        l_statementEnabled   := ecx_debug.g_statementEnabled;
        l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

	if (l_procedureEnabled) then
          ecx_debug.push(i_method_name);
        end if;

	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'i_msgid',i_msgid,i_method_name);
          ecx_debug.log(l_statement,'i_debug_level',i_debug_level,i_method_name);
	end if;
	ecx_utils.g_document_id :=m_internal_control_number;

	IF (ecx_logging_enabled ) THEN
		ecx_utils.g_logfile :=i_logfile;
	END IF;

	ecx_utils.g_direction := 'IN';

	ecx_utils.g_transaction_type := m_transaction_type;
	ecx_utils.g_transaction_subtype := m_transaction_subtype;
	ecx_utils.g_msgid := i_msgid;

	begin
		select	standard_id
		into	ecx_utils.g_standard_id
		from	ecx_standards
		where	standard_code = m_message_standard
                and     standard_type = nvl(m_message_type, 'XML');
		if(l_statementEnabled) then
                   ecx_debug.log(l_statement,'Standard id',ecx_utils.g_standard_id,i_method_name);
		end if;
	exception
	when others then
                ecx_debug.setErrorInfo(1,30,'ECX_UNSUPPORTED_STANDARD');
		raise ecx_utils.program_exit;
	end;

	validate_message
		(
                i_msgid,
		m_message_standard,
		m_transaction_type,
		m_transaction_subtype,
		m_party_ext_code,
		m_document_number,
		m_routing_ext_code,
		m_payload,
                m_message_type
		);

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;
IF (ecx_logging_enabled ) THEN
	ecx_debug.print_log;
	ecx_debug.disable_debug;
END IF;

commit;
exception
when ecx_utils.program_exit then
	--ecx_utils.g_map_id := -1;
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
	rollback;
when msg_not_found then
	--ecx_utils.g_map_id := -1;
        ecx_debug.setErrorInfo(1,30,'ECX_MSGID_NOT_FOUND',
                              'p_msgid',
                               i_msgid);
	close get_msg;
	rollback;
when others then
	--ecx_utils.g_map_id := -1;
        ecx_debug.setErrorInfo(2,30,SQLERRM || ' - ECX_INBOUND_TRIG.WRAP_VALIDATE_MESSAGE');
        if(l_unexpectedEnabled) then
            --ecx_debug.log(l_unexpected,ecx_utils.i_errbuf,i_method_name);
            ecx_debug.log(l_unexpected,ecx_debug.getMessage(ecx_utils.i_errbuf,ecx_utils.i_errparams),i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;

	rollback;
end wrap_validate_message;

procedure processXML
	(
	i_map_code              IN         varchar2,
	i_payload		IN	   CLOB,
	i_debug_level           IN         pls_integer,
	i_ret_code		OUT NOCOPY pls_integer,
	i_errbuf		OUT NOCOPY varchar2,
	i_log_file		OUT NOCOPY varchar2,
	o_payload		OUT NOCOPY CLOB,
        i_message_standard      IN         varchar2,
        i_message_type          IN         varchar2
	)
is
i_method_name   varchar2(2000) := 'ecx_inbound_trig.processxml';
i_logdir		varchar2(200);
i_logfile		varchar2(200);
i_map_id		pls_integer;
g_instlmode         VARCHAR2(100);

cursor get_run_s
is
select  ecx_output_runs_s.NEXTVAL
from    dual;

ecx_logging_enabled boolean := false;
logging_enabled varchar2(20);
module varchar2(2000);

begin
  g_instlmode := wf_core.translate('WF_INSTALL');

  if(g_instlmode = 'EMBEDDED')
  THEN
    fnd_profile.get('AFLOG_ENABLED',logging_enabled);
    fnd_profile.get('AFLOG_MODULE',module);
	if(logging_enabled = 'Y' AND ((lower(module) like 'ecx%'
	AND instr(lower(ecx_debug.g_v_module_name),rtrim(lower(module),'%'))> 0)
	OR module='%')
        AND FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_UNEXPECTED) then
	ecx_logging_enabled := true;
       end if;
  elsif(g_instlmode = 'STANDALONE')
  then
    if (i_debug_level > 0) then
      ecx_logging_enabled := true;
    end if;
  end if;

  IF (ecx_logging_enabled ) THEN
	/**
	Fetch the Run Id for the Transaction
	**/
	open    get_run_s;
	fetch   get_run_s
	into    ecx_utils.g_run_id;
	close   get_run_s;

	--get the Log directory from the Profile Option.
	ecx_utils.getLogDirectory;
	i_logfile := 'IN'||ecx_utils.g_run_id||'.log';
	END IF;

	IF g_instlmode = 'EMBEDDED' THEN
		IF (ecx_logging_enabled ) THEN
			i_log_file := ecx_debug.g_sqlprefix || 'in.'||ecx_utils.g_run_id||'.log';
		ELSE
			i_log_file := 'Please ensure that FND-Logging is enabled for module '||ecx_debug.g_sqlprefix||'%';
		END IF;
	ELSE
		IF (ecx_logging_enabled ) THEN
			i_log_file := ecx_utils.g_logdir||'/'||i_logfile;
		ELSE
			i_log_file := 'Please ensure that logging is enabled';
		END IF;
	END IF;

	IF (ecx_logging_enabled ) THEN
		ecx_debug.enable_debug_new(i_debug_level,ecx_utils.g_logdir,i_logfile, 'in.'||ecx_utils.g_run_id||'.log');
	END IF;

        /* Assign local variables with the ecx_debug global variables*/
        l_procedure          := ecx_debug.g_procedure;
        l_statement          := ecx_debug.g_statement;
        l_unexpected         := ecx_debug.g_unexpected;
        l_procedureEnabled   := ecx_debug.g_procedureEnabled;
        l_statementEnabled   := ecx_debug.g_statementEnabled;
        l_unexpectedEnabled  := ecx_debug.g_unexpectedEnabled;

	if (l_procedureEnabled) then
	  ecx_debug.push(i_method_name);
	end if;

	if(l_statementEnabled) then
          ecx_debug.log(l_statement,'i_map_code',i_map_code,i_method_name);
	  ecx_debug.log(l_statement,'i_debug_level',i_debug_level,i_method_name);
	end if;

	IF (ecx_logging_enabled ) THEN
		ecx_utils.g_logfile :=i_logfile;
	END IF;
	ecx_utils.g_direction := 'IN';

	begin
		select	map_id
		into	i_map_id
		from	ecx_mappings
		where	map_code = i_map_code;
	exception
	when others then
                ecx_debug.setErrorInfo(2,30,'ECX_MAP_NOT_FOUND',
                              'MAP_CODE',
                               i_map_code);
		raise ecx_utils.program_exit;
	end;

        begin
                select  standard_id
                into    ecx_utils.g_standard_id
                from    ecx_standards
                where   standard_code = i_message_standard
                and     standard_type = nvl(i_message_type, 'XML');
		if(l_statementEnabled) then
			ecx_debug.log(l_statement,'Standard id',ecx_utils.g_standard_id,i_method_name);
		end if;
        exception
        when others then
                ecx_debug.setErrorInfo(1,30,'ECX_UNSUPPORTED_STANDARD');
                raise ecx_utils.program_exit;
        end;

	processXMLData
   		(
		i_map_id,
		i_payload,
		null,
		null,
		i_message_standard,
		o_payload,
                i_message_type
   		);

--ecx_utils.i_ret_code :=0;
--ecx_utils.i_errbuf := 'XML Document Successfully processed';
ecx_debug.setErrorInfo(0,10,'ECX_DOCUMENT_PROCESSED');

if(ecx_utils.i_ret_code = 0 ) then
  if(l_statementEnabled) then
  ecx_debug.log(l_statement, 'Ret Code',ecx_utils.i_ret_code,i_method_name);
  ecx_debug.log(l_statement, 'Ret Msg ',ecx_utils.i_errbuf,i_method_name);
  end if;
else
if(l_unexpectedEnabled) then
  ecx_debug.log(l_unexpected, 'Ret Code',ecx_utils.i_ret_code,i_method_name);
  ecx_debug.log(l_unexpected, 'Ret Msg ',ecx_utils.i_errbuf,i_method_name);
end if;
end if;

if (l_procedureEnabled) then
  ecx_debug.pop(i_method_name);
end if;

IF (ecx_logging_enabled ) THEN
  ecx_debug.print_log;
  ecx_debug.disable_debug;
END IF;

i_ret_code := ecx_utils.i_ret_code;
i_errbuf := ecx_utils.i_errbuf;

exception
when ecx_utils.program_exit then
	--dbms_lob.freetemporary(o_payload);
	--ecx_utils.g_map_id := -1;
	if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'Ret Code',ecx_utils.i_ret_code,i_method_name);
          ecx_debug.log(l_unexpected, 'Ret Msg ',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams),i_method_name);
	end if;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
	i_ret_code := ecx_utils.i_ret_code;
        i_errbuf := ecx_utils.i_errbuf;

when others then
	--dbms_lob.freetemporary(o_payload);
	--ecx_utils.g_map_id := -1;
        ecx_debug.setErrorInfo(2,30,SQLERRM || ' - ECX_INBOUND_TRIG.WRAP_VALIDATE_MESSAGE');
        if(l_unexpectedEnabled) then
          ecx_debug.log(l_unexpected,'Ret Code',ecx_utils.i_ret_code,i_method_name);
          ecx_debug.log(l_unexpected, 'Ret Msg ',ecx_debug.getMessage(ecx_utils.i_errbuf,
                                                        ecx_utils.i_errparams),i_method_name);
	end if;
	if (l_procedureEnabled) then
          ecx_debug.pop(i_method_name);
        end if;
	IF (ecx_logging_enabled ) THEN
		ecx_debug.print_log;
		ecx_debug.disable_debug;
	END IF;
	i_ret_code := ecx_utils.i_ret_code;
	i_errbuf := ecx_utils.i_errbuf;
end processXML;


procedure reprocess
         (
           i_msgid                 IN          RAW,
           i_debug_level           IN          pls_integer,
           i_trigger_id            OUT NOCOPY  number,
           i_retcode               OUT NOCOPY  pls_integer,
           i_errbuf                OUT NOCOPY  varchar2
         )
is
i_process_id raw(16);
cursor c_ecx_trigger_id
is
select ecx_trigger_id_s.NEXTVAL
  from dual;

begin
  /* open c_ecx_trigger_id;
   fetch c_ecx_trigger_id into i_trigger_id;
   close c_ecx_trigger_id;*/
   ecx_debug.setErrorInfo(10,10,'ECX_REPROCESSING_MESSAGE');
/*   ecx_errorlog.inbound_trigger
                (
                  i_trigger_id,
                  i_msgid,
                  null,
                  ecx_utils.i_ret_code,
                  ecx_utils.i_errbuf
                 );

*/

   begin
          ecx_inbound_trig.wrap_validate_message
                         (
                               i_msgid,
                               i_debug_level
                         );

          ecx_debug.setErrorInfo(0,10,'ECX_MESSAGE_REPROCESSED');
	   select process_id into i_process_id from ecx_inbound_logs where msgid=i_msgid;
	  if(i_process_id is null) -- means TP setup wrong. Message never got into transaction queue.
	  then
	  return;
	  end if;
          ecx_errorlog.inbound_engine(i_process_id,ecx_utils.i_ret_code,
                                              ecx_utils.i_errbuf);
	  ecx_utils.g_logfile := null;
   exception
       when others then

            select process_id into i_process_id from ecx_inbound_logs where msgid=i_msgid; -- fix for bug 7609421 / 8629681
            ecx_errorlog.inbound_engine(i_process_id,ecx_utils.i_ret_code, ecx_utils.i_errbuf,ecx_utils.i_errparams);
            i_retcode := ecx_utils.i_ret_code;
            i_errbuf := ecx_utils.i_errbuf;
	    ecx_utils.g_logfile := null;
   end;

--Changed for MLS
ecx_debug.setErrorInfo(0,10,'ECX_MESSAGE_REPROCESSED');
i_retcode := ecx_utils.i_ret_code;
i_errbuf  := ecx_utils.i_errbuf;
exception
 when others then
   i_retcode := ecx_utils.i_ret_code;
   i_errbuf := ecx_utils.i_errbuf;
   raise;
end reprocess;

end ecx_inbound_trig;

/
