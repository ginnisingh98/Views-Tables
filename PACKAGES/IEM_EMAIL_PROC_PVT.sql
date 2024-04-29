--------------------------------------------------------
--  DDL for Package IEM_EMAIL_PROC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEM_EMAIL_PROC_PVT" AUTHID CURRENT_USER as
/* $Header: iemmprps.pls 120.1.12010000.7 2009/10/08 22:20:30 siahmed ship $ */

TYPE email_data_type IS RECORD (
          key   varchar2(100),
          value varchar2(500));
TYPE email_data_tbl IS TABLE OF email_data_type
           INDEX BY BINARY_INTEGER;
TYPE email_doc_type IS RECORD (
          doc_id   number,			--Document Id to be send
          type varchar2(1));			-- Sending type I-Insert,A-Attach
TYPE email_doc_tbl IS TABLE OF email_doc_type
           INDEX BY BINARY_INTEGER;
TYPE t_number_table IS TABLE OF NUMBER;
PROCEDURE PROC_EMAILS(ERRBUF OUT NOCOPY 	VARCHAR2,
		   ERRRET OUT NOCOPY 	VARCHAR2,
		   p_api_version_number in number:= 1.0,
 		   p_init_msg_list  IN   VARCHAR2 ,
	    	   p_commit	    IN   VARCHAR2 ,
		   p_count		IN NUMBER
			 	) ;
PROCEDURE iem_logger( l_logmessage in varchar2);
PROCEDURE iem_returned_msg_rec(x_msg_rec  out nocopy iem_rt_preproc_emails%ROWTYPE);

PROCEDURE IEM_CLASSIFICATION_PROC(
				p_email_account_id	in number,
				p_keyval   in iem_route_pub.keyVals_tbl_type,
			x_rt_classification_id	 out nocopy number,
			x_status	 out nocopy varchar2,
		     x_out_text out nocopy  varchar2);

PROCEDURE IEM_ROUTING_PROC(
				p_email_account_id	in number,
				p_keyval   in iem_route_pub.keyVals_tbl_type,
				x_routing_group_id	 out nocopy number,
					x_status	 out nocopy varchar2,
					 x_out_text out nocopy  varchar2);
PROCEDURE IEM_INVOKE_WORKFLOW(p_message_id in number,
						p_source_message_id in number,
  						p_message_size in number,
  						p_sender_name  in varchar2,
  						p_user_name in varchar2,
  						p_domain_name   in varchar2,
  						p_priority     in varchar2,
  						p_message_status in varchar2,
  						p_email_account_id in number,
						x_wfoutval out nocopy varchar2,
               			x_status out nocopy varchar2,
						x_out_text out nocopy varchar2);
 PROCEDURE IEM_GET_MERGEVAL(p_email_account_id in number,
				    p_mailer	in varchar2,
				    p_dflt_sender	in varchar2,
				    p_subject		in varchar2,
				    x_qual_tbl out nocopy  IEM_OUTBOX_PROC_PUB.QualifierRecordList,
				    x_status	out nocopy varchar2,
				    x_out_text	out nocopy varchar2);
PROCEDURE IEM_AUTOACK(p_email_user	in varchar2,
				p_mailer in varchar2,
				p_sender	in varchar2,
				p_subject	in varchar2,
				  p_domain_name	in varchar2,
				  p_document_id in number,
				  p_dflt_sender in varchar2,
				  p_int_id	in number,
				  p_master_account_id 	in number,
				  x_status OUT NOCOPY varchar2,
				  x_out_text OUT NOCOPY varchar2);


PROCEDURE		IEM_SRSTATUS_UPDATE(p_sr_id	in number,
							p_status_id in number,
							p_email_rec in iem_rt_preproc_emails%rowtype,
							x_status  out nocopy varchar2,
							x_out_text out nocopy varchar2);

PROCEDURE IEM_PROC_IH(
				p_type		in varchar2,		-- MEDIA/ACTIVITY/MLCS/INTERACTION
				p_action		in varchar2,		-- ADD/UPDATE/CLOSE
 				p_interaction_rec in       JTF_IH_PUB.interaction_rec_type,
				p_activity_rec     in      JTF_IH_PUB.activity_rec_type,
				p_media_lc_rec in JTF_IH_PUB.media_lc_rec_type,
				p_media_rec	in	JTF_IH_PUB.media_rec_type,
				x_id OUT NOCOPY NUMBER,
				x_status	 out nocopy varchar2,
			     x_out_text out nocopy  varchar2);

PROCEDURE		IEM_WRAPUP(p_interaction_id	in number,
					p_media_id		in number,
					p_milcs_id		in number,
					p_action		in varchar2,
					p_email_rec in iem_rt_preproc_emails%rowtype,
					p_action_id	in number,
					x_out_text		out NOCOPY varchar2,
					x_status  out nocopy varchar2);

PROCEDURE		IEM_AUTOREPLY(p_interaction_id	in number,
					p_media_id		in number,
					p_post_rec		in iem_rt_preproc_emails%rowtype,
					p_doc_tbl		in email_doc_tbl,
					p_subject		in varchar2,
 					P_TAG_KEY_VALUE_TBL in IEM_OUTBOX_PROC_PUB.keyVals_tbl_type,
 					P_CUSTOMER_ID in number,
 					P_RESOURCE_ID in number,
 					p_qualifiers in IEM_OUTBOX_PROC_PUB.QualifierRecordList,
					p_fwd_address in varchar2,
					p_fwd_doc_id in number,
					p_req_type in varchar2,
					x_out_text	 out nocopy varchar2,
					x_status  out nocopy varchar2);

procedure IEM_PROCESS_INTENT(l_email_account_id in number,
					  l_msg_id	in number,
					  l_theme_status	out nocopy varchar2,
					  l_out_text	out nocopy varchar2);

PROCEDURE ReprocessAutoreply(p_api_version_number    IN   NUMBER,
                   p_init_msg_list  IN   VARCHAR2 ,
                   p_commit      IN   VARCHAR2 ,
                   p_media_id in number,
		   		p_interaction_id	in number,
	           	p_customer_id	in number,
	           	p_contact_id	in number,
	           	p_relationship_id	in number,
                   x_return_status    OUT NOCOPY      VARCHAR2,
                   x_msg_count              OUT NOCOPY           NUMBER,
                   x_msg_data OUT NOCOPY      VARCHAR2);
procedure IEM_WF_SPECIFICSEARCH(
    l_msg_id  in number,
    l_email_account_id   in number,
    l_classification_id	in number,
    l_category_id  AMV_SEARCH_PVT.amv_number_varray_type,
    l_repos		in varchar2,
    l_stat    out nocopy varchar2,
    l_out_text	out nocopy varchar2);
procedure IEM_RETURN_ENCRYPTID
	(p_subject	in varchar2,
	x_id		out nocopy varchar2,
	x_Status		out nocopy varchar2);


--added by siahmed for 12.1.3 advanced sr project
  PROCEDURE advanced_sr_processing (
                  p_message_id          IN NUMBER,
                  p_parser_id           IN NUMBER,
                  p_account_type        IN VARCHAR2 DEFAULT NULL,
                  p_default_type_id   IN NUMBER   DEFAULT NULL,
                  p_default_customer_id IN NUMBER   DEFAULT NULL,
                  p_init_msg_list	IN   VARCHAR2 	:= FND_API.G_FALSE,
                  p_commit		IN   VARCHAR2 	:= FND_API.G_FALSE,
                  p_note		IN   VARCHAR2,
                  p_subject             IN   VARCHAR2,
                  p_note_type           IN   VARCHAR2,
                  p_contact_id          IN   NUMBER             := NULL,
                  p_contact_point_id    IN   NUMBER             := NULL,
                  x_return_status	OUT  NOCOPY   VARCHAR2,
                  x_msg_count		OUT  NOCOPY  NUMBER,
                  x_msg_data		OUT  NOCOPY  VARCHAR2,
                  x_request_id          OUT  NOCOPY  NUMBER
                );

  Procedure  getCustomerNumber (
                    p_customer_number IN VARCHAR2   DEFAULT NULL,
	            p_customer_name   IN VARCHAR2 DEFAULT NULL,
		    p_account_number  IN VARCHAR2   DEFAULT NULL,
		    p_customer_phone  IN VARCHAR2 DEFAULT NULL,
 		    p_customer_email  IN VARCHAR2 DEFAULT NULL,
		    p_instance_number IN VARCHAR2   DEFAULT NULL,
		    p_instance_serial_number IN VARCHAR2 DEFAULT NULL,
		    p_incident_site_number   IN VARCHAR2 DEFAULT NULL,
                    --contact related stuff to find customerNumber
		    p_contact_number  IN VARCHAR2 DEFAULT NULL,
 		    p_contact_name    IN VARCHAR2 DEFAULT NULL,
		    p_contact_phone   IN VARCHAR2   DEFAULT NULL,
		    p_contact_email   IN VARCHAR2   DEFAULT NULL,
                    x_customer_id   OUT NOCOPY NUMBER);

   Procedure getAccountNumber(p_account_number   IN VARCHAR2,
                              x_cust_account_id  OUT NOCOPY NUMBER);

   Procedure getCustomerPhone(p_customer_phone     IN VARCHAR2,
                              x_customer_phone_id  OUT NOCOPY NUMBER);

   Procedure getCustomerEmail (p_customer_email VARCHAR2,
                              x_customer_email_id  out NOCOPY number);

   Procedure getInstanceNumber (p_instance_number     IN VARCHAR2,
                               p_cust_account_id      IN NUMBER DEFAULT NULL,
                               x_customer_product_id OUT NOCOPY NUMBER,
                               x_inventory_org_id    OUT NOCOPY NUMBER,
                               x_inventory_item_id   OUT NOCOPY NUMBER);

  Procedure getInstanceSerialNumber (p_instance_serial_number     IN VARCHAR2,
                               p_cust_account_id     IN NUMBER DEFAULT NULL,
                               x_customer_product_id OUT NOCOPY NUMBER,
                               x_inventory_org_id    OUT NOCOPY NUMBER,
                               x_inventory_item_id   OUT NOCOPY NUMBER);

  Procedure getIncidentSiteNumber (p_incident_site_number IN varchar2,
                                   x_incident_location_id out NOCOPY NUMBER);


  Procedure getContactNumber (p_contact_number IN VARCHAR2,
                              p_parser_id      IN NUMBER,
                              p_contact_phone  IN VARCHAR2,
                              p_contact_email IN VARCHAR2,
                              x_contact_party_id  OUT NOCOPY NUMBER,
                              x_contact_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_id  OUT NOCOPY NUMBER);


  Procedure getContactName   (p_contact_name IN VARCHAR2,
                              p_parser_id      IN NUMBER,
                              p_contact_phone  IN VARCHAR2,
                              p_contact_email IN VARCHAR2,
                              x_contact_party_id  OUT NOCOPY NUMBER,
                              x_contact_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_type      OUT NOCOPY VARCHAR2,
                              x_contact_point_id  OUT NOCOPY NUMBER);

 Procedure getContactPhone (p_contact_phone IN VARCHAR2,
                            x_contact_party_id  OUT NOCOPY NUMBER,
                            x_contact_type      OUT NOCOPY VARCHAR2,
                            x_contact_point_type      OUT NOCOPY VARCHAR2,
                            x_contact_point_id  OUT NOCOPY NUMBER);

 Procedure getContactEmail (p_contact_email IN VARCHAR2,
                            x_contact_party_id  OUT NOCOPY NUMBER,
                            x_contact_type      OUT NOCOPY VARCHAR2,
                            x_contact_point_type      OUT NOCOPY VARCHAR2,
                            x_contact_point_id  OUT NOCOPY NUMBER);

  Procedure getInventoryItemName (p_inventory_item_name IN VARCHAR2,
                                  x_inventory_item_id OUT NOCOPY NUMBER,
                                  x_inventory_org_id OUT NOCOPY NUMBER);

  PROCEDURE getServiceRequestType (p_service_request_type IN VARCHAR2,
                                   p_default_type_id      IN NUMBER,
	                           x_type_id              OUT NOCOPY NUMBER);

  Procedure getProblemCode (p_problem_code in VARCHAR2,
                            x_problem_code OUT NOCOPY varchar2);

  Procedure getUrgency (p_urgency    IN VARCHAR2,
  	                x_urgency_id OUT NOCOPY NUMBER);

  Procedure getSiteName(p_site_name      IN  VARCHAR2,
                        x_party_site_id  OUT NOCOPY NUMBER);

  Procedure getExtReference(p_ext_ref               IN VARCHAR2,
                            p_customer_product_id   IN NUMBER,
                            x_ext_ref               OUT NOCOPY VARCHAR2);

  FUNCTION GET_TAG_DATA
    ( p_start_tag   IN VARCHAR2,
      p_END_tag     IN VARCHAR2,
      p_message_id  IN NUMBER
     ) return VARCHAR2;

--end of siahmed 12.1.3 stuff

end IEM_EMAIL_PROC_PVT;

/
