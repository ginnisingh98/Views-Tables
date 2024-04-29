--------------------------------------------------------
--  DDL for Package IGS_AS_SS_DOC_REQUEST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SS_DOC_REQUEST" AUTHID CURRENT_USER AS
/* $Header: IGSAS45S.pls 120.2 2005/10/19 23:56:43 appldev ship $ */

FUNCTION check_waivers
        (p_person_id NUMBER)  RETURN VARCHAR2;

PROCEDURE Get_Summary_Display_Message
    (P_Person_Id NUMBER,
     P_Hold_Message OUT NOCOPY VARCHAR2,
     P_Hint_Message OUT NOCOPY VARCHAR2,
     P_Request_allowed OUT NOCOPY VARCHAR2,
  P_Transcript_allowed  OUT NOCOPY VARCHAR2,
  P_Encert_Allowed     OUT NOCOPY VARCHAR2,
  p_LifetimeFee_allowed  OUT NOCOPY VARCHAR2);

FUNCTION Get_Item_Details_For_Order
 (P_ORDER_NUMBER NUMBER)   RETURN VARCHAR2  ;

FUNCTION Get_Order_Details_Include_Addr
(P_ITEM_NUMBER NUMBER) RETURN VARCHAR2 ;

--PRAGMA RESTRICT_REFERENCES(Get_Item_Details_For_Order, WNDS, WNPS); msrinivi

FUNCTION Get_Transcript_Fee (
  p_person_id                         IN NUMBER,
  p_document_type                     IN VARCHAR2,
  p_number_of_copies                  IN NUMBER,
  p_include_delivery_fee              IN VARCHAR2 DEFAULT 'Y',
  p_delivery_method_type              IN VARCHAR2 DEFAULT NULL,
  p_item_number                       IN NUMBER DEFAULT NULL
)
RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(Get_Transcript_Fee, WNDS, WNPS);



FUNCTION enrp_get_career_dates(p_person_id IN NUMBER,
                                                  p_course_type IN VARCHAR2)
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES( enrp_get_career_dates, WNDS, WNPS);

PROCEDURE CREATE_INVOICE (p_order_number  IN  NUMBER,
                          p_payment_type  IN VARCHAR2 DEFAULT 'MAKE_PAYMENT',
                          p_invoice_id    OUT NOCOPY NUMBER,
                          p_return_status OUT NOCOPY VARCHAR2,
                          p_msg_count     OUT NOCOPY NUMBER,
                          p_msg_data      OUT NOCOPY VARCHAR2,
                          p_waiver_amount OUT NOCOPY NUMBER);

FUNCTION show_bill_me_later (
  p_person_id                         IN NUMBER
) RETURN VARCHAR2;



PROCEDURE UPDATE_ORDER_FEE
(P_ORDER_NUMBER         NUMBER,
 P_ITEM_NUMBER          NUMBER,
 P_OLD_SUB_DOC_TYPE     VARCHAR2,
 P_OLD_DELIV_TYPE       VARCHAR2,
 P_OLD_NUM_COPIES       VARCHAR2,
 P_NEW_SUB_DOC_TYPE     VARCHAR2,
 P_NEW_DELIV_TYPE       VARCHAR2,
 P_NEW_NUM_COPIES       VARCHAR2,
 P_RETURN_STATUS  OUT NOCOPY    VARCHAR2,
 P_MSG_DATA       OUT NOCOPY    VARCHAR2,
 P_MSG_COUNT      OUT NOCOPY    NUMBER
);


FUNCTION Inst_Is_EDI_Partner(p_Inst_Code VARCHAR2) RETURN VARCHAR2;


FUNCTION Is_All_Progs_allowed RETURN VARCHAR2;


PROCEDURE create_as_application (
                              p_credit_id         IN     igs_fi_applications.credit_id%TYPE,
                              p_invoice_id        IN     igs_fi_applications.invoice_id%TYPE,
                              p_amount_apply      IN     igs_fi_applications.amount_applied%TYPE,
                              p_appl_type         IN     igs_fi_applications.application_type%TYPE,
                              p_appl_hierarchy_id IN     igs_fi_applications.appl_hierarchy_Id%TYPE,
                              p_validation        IN     VARCHAR2,
			      p_application_id    OUT NOCOPY    igs_fi_applications.application_id%TYPE,
                              p_err_msg           OUT NOCOPY    fnd_new_messages.message_name%TYPE,
                              p_status            OUT NOCOPY    VARCHAR2
                                 );


FUNCTION get_prg_st_end_dts(p_person_id NUMBER, p_course_cd VARCHAR2) RETURN VARCHAR2;

PROCEDURE delete_order_and_items(
                                 p_order_number IN igs_as_order_hdr.order_number%TYPE,
                                 p_msg_count    OUT NOCOPY NUMBER,
                                 p_msg_data	OUT NOCOPY VARCHAR2,
                                 p_return_status OUT NOCOPY VARCHAR2
                                );


PROCEDURE Get_Doc_And_Delivery_Fee ( p_person_id              IN  NUMBER,
                                     p_document_type          IN  VARCHAR2,
                                     p_document_sub_type      IN  VARCHAR2,
                                     p_number_of_copies       IN  NUMBER,
                                     p_delivery_method_type   IN  VARCHAR2 DEFAULT NULL,
				     p_document_fee           OUT NOCOPY NUMBER,
				     p_delivery_fee           OUT NOCOPY NUMBER,
				     p_program_on_file	      IN Varchar2 DEFAULT NULL,
				     p_plan_id		      IN OUT NOCOPY Number ,
				     p_item_number            IN NUMBER DEFAULT NULL
                                   );


PROCEDURE Pay_Lifetime_Fees (p_person_id      IN  NUMBER,
                             p_order_number   IN  NUMBER,
			     p_return_status  OUT NOCOPY VARCHAR2,
                             p_msg_data       OUT NOCOPY VARCHAR2,
                             p_msg_count      OUT NOCOPY NUMBER
			     );

PROCEDURE recalc_after_lft_paid (p_person_id      IN  NUMBER,
                                 p_order_number   IN  NUMBER,
        			 p_return_status  OUT NOCOPY VARCHAR2,
                                 p_msg_data       OUT NOCOPY VARCHAR2,
                                 p_msg_count      OUT NOCOPY NUMBER
			      );

PROCEDURE get_as_current_term (
  p_cal_type           OUT NOCOPY    VARCHAR2,
  p_sequence_number    OUT NOCOPY    NUMBER,
  p_description        OUT NOCOPY    VARCHAR2
);

PROCEDURE get_as_next_term (      p_cal_type           OUT NOCOPY    VARCHAR2,
				  p_sequence_number    OUT NOCOPY    NUMBER,
				  p_description        OUT NOCOPY    VARCHAR2
				  );
PROCEDURE get_as_previous_term (  p_cal_type           OUT NOCOPY    VARCHAR2,
				  p_sequence_number    OUT NOCOPY    NUMBER,
				  p_description        OUT NOCOPY    VARCHAR2
				  );
/*
PROCEDURE CALC_DOC_FEE (
				  p_person_id                         IN NUMBER DEFAULT NULL,
				  p_document_type                     IN VARCHAR2 DEFAULT NULL,
				  p_number_of_copies                  IN NUMBER DEFAULT NULL,
				  p_include_delivery_fee              IN VARCHAR2 DEFAULT NULL,
				  p_delivery_method_type              IN VARCHAR2 DEFAULT NULL,
				  p_program_on_file		      IN Varchar2 DEFAULT NULL,
				  p_plan_id			      IN OUT NOCOPY Number ,
				  p_doc_fee			      OUT NOCOPY Varchar2
				);
*/

PROCEDURE Re_calc_doc_fees(
				 p_person_Id IN Number DEFAULT NULL,
				 p_Plan_id   IN Number DEFAULT NULL,
				 p_subs_unsubs IN Varchar2  Default 'U' ,-- Possible values 'U' and 'S'
				 p_admin_person_id  IN  Number DEFAULT NULL, -- The person Id of the admin
				 p_orders_recalc  OUT NOCOPY Varchar2    -- To return  comma seperated List of Order numbers that got recalculated.
				);

PROCEDURE  create_trns_plan_invoice_id (
                                                p_person_id     IN NUMBER,
                                                p_fee_amount    IN NUMBER,
                                                p_invoice_id    OUT NOCOPY NUMBER,
						p_return_status OUT NOCOPY VARCHAR2,
                                                p_msg_count     OUT NOCOPY NUMBER,
                                                p_msg_data      OUT NOCOPY VARCHAR2,
                                                p_waiver_amount OUT NOCOPY NUMBER
					);
PROCEDURE delete_bulk_item
(
  p_item_number   IN NUMBER,
  p_msg_count      OUT NOCOPY NUMBER,
  p_msg_data	   OUT NOCOPY VARCHAR2,
  p_return_status OUT NOCOPY VARCHAR2
);

PROCEDURE place_bulk_order
(
  p_person_ids    IN VARCHAR2,
  p_program_cds   IN VARCHAR2,
  p_prog_vers     IN VARCHAR2,
  p_printer_name  IN VARCHAR2,
  p_schedule_date IN DATE,
  p_action_type   IN VARCHAR2, -- Whether create doc only or create doc and produce docs also
  p_trans_type    IN igs_as_doc_details.document_type%TYPE,
  p_deliv_meth    IN igs_as_doc_details.delivery_method_type%TYPE,
  p_incl_ind      IN VARCHAR2,
  p_num_copies    IN NUMBER,
  p_admin_person_id IN hz_parties.party_id%TYPE,
  p_order_desc    IN igs_as_order_hdr.order_description%TYPE,
  p_purpose       IN igs_as_doc_details.DOC_PURPOSE_CODE%TYPE,
  p_effbuff     OUT NOCOPY VARCHAR2,
  p_Status      OUT NOCOPY VARCHAR2
);

PROCEDURE submit_print_request
(
  p_errbuf          OUT NOCOPY VARCHAR2,
  p_retcode         OUT NOCOPY VARCHAR2,
  p_order_number  IN igs_as_order_hdr.order_number%TYPE,
  p_item_numbers   IN igs_as_doc_details.item_number%TYPE,
  p_printer_name  IN VARCHAR2,
  p_schedule_date IN DATE
);

PROCEDURE produce_docs_ss
(
  p_item_numbers  IN VARCHAR2,
  p_printer_name  IN VARCHAR2,
  p_schedule_date IN DATE,
  p_ret_status    OUT NOCOPY VARCHAR2,
  p_effbuff      OUT NOCOPY VARCHAR2,
  p_req_ids       OUT NOCOPY VARCHAR2
);

PROCEDURE bulk_order_job
(
  errbuf          OUT NOCOPY VARCHAR2,
  retcode         OUT NOCOPY NUMBER,
  p_person_ids    IN VARCHAR2,
  p_program_cds   IN VARCHAR2,
  p_prog_vers     IN VARCHAR2,
  p_printer_name  IN VARCHAR2,
  p_schedule_date IN DATE,
  p_action_type   IN VARCHAR2, -- Whether create doc only or create doc and produce docs also
  p_trans_type    IN igs_as_doc_details.document_type%TYPE,
  p_deliv_meth    IN igs_as_doc_details.delivery_method_type%TYPE,
  p_incl_ind      IN VARCHAR2,
  p_num_copies    IN NUMBER,
  p_admin_person_id IN hz_parties.party_id%TYPE,
  p_order_desc    IN igs_as_order_hdr.order_description%TYPE,
  p_purpose       IN igs_as_doc_details.DOC_PURPOSE_CODE%TYPE
);

FUNCTION get_latest_yop
(
    p_person_id hz_parties.party_id%TYPE,
    p_course_cd igs_ps_ver.course_cd%TYPE
) RETURN VARCHAR2;


FUNCTION is_order_del_alwd( P_ORDER_NUMBER NUMBER)
RETURN VARCHAR2;


END Igs_As_Ss_Doc_Request;

 

/
