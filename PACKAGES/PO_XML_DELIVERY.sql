--------------------------------------------------------
--  DDL for Package PO_XML_DELIVERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_XML_DELIVERY" AUTHID CURRENT_USER AS
/* $Header: POXWXMLS.pls 120.3.12010000.8 2014/04/09 18:13:15 prilamur ship $ */

 /*=======================================================================+
 | FILENAME
 |   POXWXMLS.pls
 |
 | DESCRIPTION
 |   PL/SQL spec for package: PO_XML_DELIVERY
 |
 | NOTES
 | MODIFIED    Created jbalakri (05/03/2001)
 *=====================================================================*/


procedure call_txn_delivery (  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);
procedure set_delivery_data    (  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);
procedure is_partner_setup  (  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);
/* XML Delivery Project, FPG+ */
procedure is_xml_chosen     (  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

/* XML Delivery Project, FPG+ */
procedure xml_time_stamp	(	p_header_id in varchar2,
                                                p_release_id varchar2,
								p_org_id in number,
								p_txn_type in varchar2,
								p_document_type in varchar2);
/* XML Delivery Project, FPG+ */
procedure get_line_requestor(	p_header_id in varchar2,
								p_line_id in varchar2,
								p_release_num in number,
								p_document_type in varchar2,
								p_revision_num in varchar2,
								p_requestor out nocopy varchar2);
/* XML Delivery Project, FPG+ */
procedure get_xml_send_date(	p_header_id in varchar2,
								p_release_id in varchar2,
								p_document_type in varchar2,
								out_date out nocopy date);
/* XML Delivery Project, FPG+ */
function get_max_line_revision(
				p_header_id varchar2,
				p_line_id varchar2,
				p_line_revision_num number,
				p_revision_num number)
				return number;

/* XML Delivery Project, FPG+ */
function get_max_location_revision(	p_header_id varchar2,
									p_line_id varchar2,
									p_location_id varchar2,
									p_location_revision_num number,
									p_revision_num number)
									return number;


procedure get_card_info( p_header_id in varchar2,
		         p_document_type in varchar2,
		         p_release_id in varchar2,
			 p_card_num out nocopy varchar2,
		         p_card_name out nocopy varchar2,
			 p_card_exp_date out nocopy date,
			 p_card_brand out nocopy varchar2);

-- procedure to get the ship_to info in cXML address format.
-- In OAG we've 3 address lines, and cXML has 1 address line.
-- This procedure calls get_shipt_info internally.

/*Modified the signature, bug#6912518*/
procedure get_cxml_shipto_info( p_header_id  in number, p_line_location_id  in number,
                           p_ship_to_location_id in number,
                           p_ECE_TP_LOCATION_CODE out nocopy varchar2,
                           P_SHIP_TO_LOCATION_CODE OUT NOCOPY VARCHAR2,
			   p_ADDRESS_LINE_1 out nocopy varchar2,
                           p_ADDRESS_LINE_2 out nocopy varchar2,
			   p_ADDRESS_LINE_3 out nocopy varchar2,
			   p_TOWN_OR_CITY out nocopy varchar2,
			   p_COUNTRY out nocopy varchar2, p_POSTAL_CODE out nocopy varchar2,
			   p_STATE out nocopy varchar2, p_TELEPHONE_NUMBER_1 out nocopy varchar2,
                           p_TELEPHONE_NUMBER_2 out nocopy varchar2,
                           p_TELEPHONE_NUMBER_3 out nocopy varchar2,
                           p_iso_country_code out nocopy varchar2);

-- procedure to get the ship_to info from hr_lcoations or hz_locations depending upon
-- the given location_id for the po_header_id is drop-ship or not.

procedure get_shipto_info( p_header_id  in number, p_line_location_id  in number,
                           p_ship_to_location_id in number,
                           p_ECE_TP_LOCATION_CODE out nocopy varchar2,
                           P_SHIP_TO_LOCATION_CODE OUT NOCOPY VARCHAR2,
                           p_ADDRESS_LINE_1 out nocopy varchar2, p_ADDRESS_LINE_2 out nocopy varchar2,
			   p_ADDRESS_LINE_3 out nocopy varchar2, p_TOWN_OR_CITY out nocopy varchar2,
			   p_COUNTRY out nocopy varchar2, p_POSTAL_CODE out nocopy varchar2,
			   p_STATE out nocopy varchar2, p_TELEPHONE_NUMBER_1 out nocopy varchar2,
                           p_TELEPHONE_NUMBER_2 out nocopy varchar2, p_TELEPHONE_NUMBER_3 out nocopy varchar2);

procedure setXMLEventKey (  itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out nocopy varchar2);



procedure setwfUserKey (  itemtype        in varchar2,
                          itemkey         in varchar2,
                          actid           in number,
                          funcmode        in varchar2,
                          resultout       out nocopy varchar2);

--sets some session values like session language
procedure initTransaction (p_header_id  in number,
                           p_vendor_id  varchar2,
                           p_vendor_site_id varchar2,
                           transaction_type varchar2 ,
                           transaction_subtype varchar2,
                           p_release_id varchar2 default null, /*parameter1*/
                           p_revision_num  varchar2 default null, /*parameter2*/
                           p_parameter3  varchar2 default null,
                           p_parameter4 varchar2 default null,
                           p_parameter5  varchar2 default NULL,
                           x_initial_nls_context out NOCOPY VARCHAR2 );

--Bug 18536351
PROCEDURE reset_nls_context (p_initial_nls_context VARCHAR2);

--Initializes wf item attributes with the PO information.
Procedure initialize_wf_parameters (
   itemtype  in varchar2,
   itemkey         in varchar2,
   actid           in number,
   funcmode        in varchar2,
   resultout       out nocopy varchar2);


/*
In cXML the deliverto information is provided as
 <DELIVERTO>
QUANTITY: PO_cXML_DELIVERTO_ARCH_V.QUANTITY ||
 NAME: || PO_cXML_DELIVERTO_ARCH_V.REQUESTOR ||
ADDRESS: || PO_cXML_DELIVERTO_ARCH_V.all the address tags
</DELIVERTO>
This is a helper function to concatinate all these values.
*/
Procedure get_cxml_deliverto_info(p_QUANTITY  in number, p_REQUESTOR in varchar2,
                                  p_LOCATION_CODE in varchar2, p_ADDRESS_LINE in varchar2,
                                  p_COUNTRY in varchar2, p_POSTAL_CODE in varchar2,
                                  p_TOWN_OR_CITY in varchar2, p_STATE in varchar2,
                                  p_deliverto out nocopy varchar2);

--Start of the comment
--
-- End of the comment
Procedure get_cxml_header_info (p_tp_id  IN  number,
                                p_tp_site_id  IN number,
                                x_from_domain  OUT nocopy varchar2,
                                x_from_identity OUT nocopy varchar2,
                                x_to_domain    OUT nocopy varchar2,
                                x_to_identity  OUT nocopy varchar2,
                                x_sender_domain OUT nocopy varchar2,
                                x_sender_identity OUT nocopy varchar2,
                                x_sender_sharedsecret OUT nocopy varchar2,
                                x_user_agent  OUT nocopy varchar2,
                                x_deployment_mode OUT nocopy varchar2
                                );


procedure IS_XML_CHN_REQ_SOURCE(itemtype in varchar2,
			        itemkey in varchar2,
    	    		        actid in number,
	    	        	funcmode in varchar2,
				resultout out NOCOPY varchar2);

-- For use in OAG Process/Change PO XML generation
-- bug 46115474
-- populate state, region, county tags of xml based on address style.
-- API called from process, change PO OAG xgms.
PROCEDURE get_oag_shipto_info(
		p_header_id		in number,
 	      p_line_location_id	in number,
 	      p_ship_to_location_id	in number,
 	      p_ECE_TP_LOCATION_CODE	out nocopy varchar2,
 	      p_ADDRESS_LINE_1		out nocopy varchar2,
 	      p_ADDRESS_LINE_2		out nocopy varchar2,
 	      p_ADDRESS_LINE_3		out nocopy varchar2,
 	      p_TOWN_OR_CITY		out nocopy varchar2,
 	      p_COUNTRY			out nocopy varchar2,
 	      P_COUNTY         		out nocopy varchar2,
 	      p_POSTAL_CODE          	out nocopy varchar2,
 	      p_STATE                	out nocopy varchar2,
 	      p_REGION               	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_1   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_2   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_3   	out nocopy varchar2);


PROCEDURE get_oag_header_shipto_info(
		p_header_id		in number,
 	      p_revision_num	in number,
        p_SHIP_TO_LOCATION_CODE	out nocopy varchar2,
 	      p_ECE_TP_LOCATION_CODE	out nocopy varchar2,
 	      p_ADDRESS_LINE_1		out nocopy varchar2,
 	      p_ADDRESS_LINE_2		out nocopy varchar2,
 	      p_ADDRESS_LINE_3		out nocopy varchar2,
 	      p_TOWN_OR_CITY		out nocopy varchar2,
 	      p_COUNTRY			out nocopy varchar2,
 	      P_COUNTY         		out nocopy varchar2,
 	      p_POSTAL_CODE          	out nocopy varchar2,
 	      p_STATE                	out nocopy varchar2,
 	      p_REGION               	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_1   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_2   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_3   	out nocopy varchar2);


PROCEDURE get_oag_deliverto_info(
 	      p_deliver_to_location_id	in number,
 	      p_ECE_TP_LOCATION_CODE	out nocopy varchar2,
        p_deliver_to_location_code	out nocopy varchar2,
 	      p_ADDRESS_LINE_1		out nocopy varchar2,
 	      p_ADDRESS_LINE_2		out nocopy varchar2,
 	      p_ADDRESS_LINE_3		out nocopy varchar2,
 	      p_TOWN_OR_CITY		out nocopy varchar2,
 	      p_COUNTRY			out nocopy varchar2,
 	      P_COUNTY         		out nocopy varchar2,
 	      p_POSTAL_CODE          	out nocopy varchar2,
 	      p_STATE                	out nocopy varchar2,
 	      p_REGION               	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_1   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_2   	out nocopy varchar2,
 	      p_TELEPHONE_NUMBER_3   	out nocopy varchar2);


-- For use in OAG Process/Change PO XML generation
-- bug 46115474
-- populate state, region, county tags of xml based on address style.
-- API called from process, change PO OAG xgms.
-- and from get_oag_shipto
PROCEDURE get_hrloc_address(
	p_location_id	in varchar2,
	addrline1		out NOCOPY VARCHAR2,
	addrline2		out NOCOPY VARCHAR2,
	addrline3		out NOCOPY VARCHAR2,
	city			out NOCOPY VARCHAR2,
	country		out NOCOPY VARCHAR2,
	county		out NOCOPY VARCHAR2,
	postalcode		out NOCOPY VARCHAR2,
	region		out NOCOPY VARCHAR2,
	stateprovn		out NOCOPY VARCHAR2);
procedure set_user_context    (  itemtype        in varchar2,
                               itemkey         in varchar2,
                               actid           in number,
                               funcmode        in varchar2,
                               resultout       out nocopy varchar2);

/*bug#6912518*/
Procedure get_header_shipto_info (p_po_header_id  IN number,
				  p_po_release_id IN number,
				  x_partner_id  out nocopy number,
				  x_partner_id_x out nocopy varchar2,
				  x_address_line_1 out nocopy varchar2,
				  x_address_line_2 out nocopy varchar2,
				  x_address_line_3 out nocopy varchar2,
				  x_city  out nocopy varchar2,
				  x_country  out nocopy varchar2,
				  x_county  out nocopy varchar2,
				  x_postalcode  out nocopy varchar2,
				  x_region out nocopy varchar2,
				  x_stateprovn  out nocopy varchar2,
				  x_telephone_1 out nocopy varchar2,
				  x_telephone_2 out nocopy varchar2,
				  x_telephone_3 out nocopy varchar2
				);


 Procedure get_cxml_header_shipto_info (p_po_header_id  IN number,
				        p_po_release_id IN number,
				        x_address_line_1 out nocopy varchar2,
					x_address_line_2 out nocopy varchar2,
					x_address_line_3 out nocopy varchar2,
				        x_city  out nocopy varchar2,
				        x_country  out nocopy varchar2,
				        x_postalcode  out nocopy varchar2,
				        x_stateprovn  out nocopy varchar2,
				        x_telephone_1 out nocopy varchar2,
				        x_deliverto out nocopy varchar2,
				        x_requestor_email OUT NOCOPY VARCHAR2
				     );
/*bug#6912518*/
PROCEDURE get_cXML_Header_Shipto_Name(p_org_name      in varchar2,
 	                              x_shipto_name out nocopy varchar2);

procedure getSupplierSiteLanguage (p_vendor_id  in varchar2,
                                   p_vendor_site_id in varchar2,
                                   lang_name out nocopy varchar2 );


end  PO_XML_DELIVERY;

/
