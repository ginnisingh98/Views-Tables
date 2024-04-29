--------------------------------------------------------
--  DDL for Package WSH_ECE_VIEWS_DEF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_ECE_VIEWS_DEF" AUTHID CURRENT_USER AS
/* $Header: WSHECVWS.pls 120.0.12010000.2 2008/11/21 05:12:21 selsubra ship $ */
function get_cont_area_code(contact_id_in NUMBER) RETURN VARCHAR2;
function get_cont_phone_number RETURN VARCHAR2;

function get_cust_area_code(customer_id_in NUMBER) return VARCHAR2;
function get_cust_phone_number RETURN VARCHAR2;

procedure get_invoice_number(p_delivery_id IN NUMBER,
                             x_invoice_number OUT NOCOPY  NUMBER) ;

procedure get_vehicle_type_code(p_vehicle_org_id IN NUMBER,
                                p_vehicle_item_id IN NUMBER,
                                x_vehicle_type_code OUT NOCOPY  VARCHAR2 ) ;

function get_cust_payment_term(p_payment_term_id NUMBER ) return VARCHAR2;

procedure get_cross_reference(X_INVENTORY_ITEM_ID IN NUMBER,
                              X_ORGANIZATION_ID IN NUMBER,
                              X_CROSS_REFERENCE OUT NOCOPY  VARCHAR2);

procedure update_del_asn_info(X_DELIVERY_ID            IN     NUMBER,
                              X_TIME_STAMP_SEQUENCE_NUMBER        IN OUT NOCOPY  NUMBER,
                              X_TIME_STAMP_DATE        IN OUT NOCOPY  DATE,
                              X_G_TIME_STAMP_SEQUENCE_NUMBER IN OUT NOCOPY  NUMBER,
                              X_G_TIME_STAMP_DATE IN OUT NOCOPY  DATE);

procedure get_location_code(p_location_id IN NUMBER,
                            x_location_code OUT NOCOPY  VARCHAR2 );

cont_phone_number_x VARCHAR2(25);
cust_phone_number_x VARCHAR2(25);

procedure get_location_info (
  p_location_id    IN NUMBER,
  p_delivery_id  	 IN NUMBER,--Bug 7371411
  x_location       OUT NOCOPY VARCHAR2,
  x_edi_loc_code   OUT NOCOPY VARCHAR2,
  x_tp_ref_ext1    OUT NOCOPY VARCHAR2,
  x_tp_ref_ext2    OUT NOCOPY VARCHAR2,
  x_customer_name  OUT NOCOPY VARCHAR2,
  x_address1       OUT NOCOPY VARCHAR2,
  x_address2       OUT NOCOPY VARCHAR2,
  x_address3       OUT NOCOPY VARCHAR2,
  x_address4       OUT NOCOPY VARCHAR2,
  x_city           OUT NOCOPY VARCHAR2,
  x_state          OUT NOCOPY VARCHAR2,
  x_postal_code    OUT NOCOPY VARCHAR2,
  x_country        OUT NOCOPY VARCHAR2,
  x_province       OUT NOCOPY VARCHAR2,
  x_county         OUT NOCOPY VARCHAR2,
  x_address_id     OUT NOCOPY NUMBER,
  x_area_code      OUT NOCOPY VARCHAR2,
  x_phone_number   OUT NOCOPY VARCHAR2);

procedure get_dlvy_location_info (
  p_intmed_ship_to_location_id   IN NUMBER,
  p_pooled_ship_to_location_id   IN NUMBER,
  p_delivery_id 			   IN NUMBER, --Bug 7371411
  x_ist_location                 OUT NOCOPY VARCHAR2,
  x_ist_edi_loc_code             OUT NOCOPY VARCHAR2,
  x_ist_tp_ref_ext1              OUT NOCOPY VARCHAR2,
  x_ist_tp_ref_ext2              OUT NOCOPY VARCHAR2,
  x_ist_customer_name            OUT NOCOPY VARCHAR2,
  x_ist_address1                 OUT NOCOPY VARCHAR2,
  x_ist_address2                 OUT NOCOPY VARCHAR2,
  x_ist_address3                 OUT NOCOPY VARCHAR2,
  x_ist_address4                 OUT NOCOPY VARCHAR2,
  x_ist_city                     OUT NOCOPY VARCHAR2,
  x_ist_state                    OUT NOCOPY VARCHAR2,
  x_ist_postal_code              OUT NOCOPY VARCHAR2,
  x_ist_country                  OUT NOCOPY VARCHAR2,
  x_ist_province                 OUT NOCOPY VARCHAR2,
  x_ist_county                   OUT NOCOPY VARCHAR2,
  x_ist_address_id               OUT NOCOPY NUMBER,
  x_ist_area_code                OUT NOCOPY VARCHAR2,
  x_ist_phone_number             OUT NOCOPY VARCHAR2,
  x_pst_location                 OUT NOCOPY VARCHAR2,
  x_pst_edi_loc_code             OUT NOCOPY VARCHAR2,
  x_pst_tp_ref_ext1              OUT NOCOPY VARCHAR2,
  x_pst_tp_ref_ext2              OUT NOCOPY VARCHAR2,
  x_pst_customer_name            OUT NOCOPY VARCHAR2,
  x_pst_address1                 OUT NOCOPY VARCHAR2,
  x_pst_address2                 OUT NOCOPY VARCHAR2,
  x_pst_address3                 OUT NOCOPY VARCHAR2,
  x_pst_address4                 OUT NOCOPY VARCHAR2,
  x_pst_city                     OUT NOCOPY VARCHAR2,
  x_pst_state                    OUT NOCOPY VARCHAR2,
  x_pst_postal_code              OUT NOCOPY VARCHAR2,
  x_pst_country                  OUT NOCOPY VARCHAR2,
  x_pst_province                 OUT NOCOPY VARCHAR2,
  x_pst_county                   OUT NOCOPY VARCHAR2,
  x_pst_address_id               OUT NOCOPY NUMBER,
  x_pst_area_code                OUT NOCOPY VARCHAR2,
  x_pst_phone_number             OUT NOCOPY VARCHAR2 );

procedure get_dlvy_dest_cont_info (
  p_contact_id                   IN NUMBER,
  x_dest_cont_last_name          OUT NOCOPY VARCHAR2,
  x_dest_cont_first_name         OUT NOCOPY VARCHAR2,
  x_cont_job_title               OUT NOCOPY VARCHAR2 );

END WSH_ECE_VIEWS_DEF;

/
