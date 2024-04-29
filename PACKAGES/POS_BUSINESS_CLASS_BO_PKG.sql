--------------------------------------------------------
--  DDL for Package POS_BUSINESS_CLASS_BO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."POS_BUSINESS_CLASS_BO_PKG" AUTHID CURRENT_USER AS
    /* $Header: POSSPBUCS.pls 120.0.12010000.2 2010/02/08 14:13:09 ntungare noship $ */

    TYPE r_vendor_buss_rec_type IS RECORD(
	    batch_id                    pos_business_class_int.sdh_batch_id%TYPE,
	    source_system               pos_business_class_int.source_system%TYPE,
	    source_system_reference     pos_business_class_int.source_system_reference%TYPE,
	    vendor_interface_id         pos_business_class_int.vendor_interface_id%TYPE,
	    business_class_interface_id pos_business_class_int.business_class_interface_id%TYPE,
	    --request_id                pos_business_class_int.request_id%TYPE,
	    classification_id		pos_business_class_int.classification_id%TYPE,
	    vendor_id			pos_business_class_int.vendor_id%TYPE,
	    lookup_type		        pos_business_class_int.lookup_type%TYPE,
	    lookup_code		        pos_business_class_int.lookup_code%TYPE,
	    start_date_active		pos_business_class_int.start_date_active%TYPE,
	    end_date_active		pos_business_class_int.end_date_active%TYPE,
	    status	                pos_business_class_int.status%TYPE,
	    ext_attr_1		        pos_business_class_int.ext_attr_1%TYPE,
	    expiration_date		pos_business_class_int.expiration_date%TYPE,
	    certificate_number		pos_business_class_int.certificate_number%TYPE,
	    certifying_agency           pos_business_class_int.certifying_agency%TYPE,
	    class_status                pos_business_class_int.class_status%TYPE,
	    attribute1		        pos_business_class_int.attribute1%TYPE,
	    attribute2			pos_business_class_int.attribute2%TYPE,
	    attribute3			pos_business_class_int.attribute3%TYPE,
	    attribute4			pos_business_class_int.attribute4%TYPE,
	    attribute5			pos_business_class_int.attribute5%TYPE
	    /*,party_id                NUMBER*/
    );

     PROCEDURE get_pos_business_class_bo_tbl(p_api_version           IN NUMBER DEFAULT NULL,
                                            p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                            p_party_id              IN NUMBER,
                                            p_orig_system           IN VARCHAR2,
                                            p_orig_system_reference IN VARCHAR2,
                                            x_pos_bus_class_bo_tbl  OUT NOCOPY pos_business_class_bo_tbl,
                                            x_return_status         OUT NOCOPY VARCHAR2,
                                            x_msg_count             OUT NOCOPY NUMBER,
                                            x_msg_data              OUT NOCOPY VARCHAR2);
     PROCEDURE create_bus_class_attr(p_api_version           IN NUMBER DEFAULT NULL,
                                    p_init_msg_list         IN VARCHAR2 DEFAULT NULL,
                                    p_pos_bus_class_bo      IN pos_business_class_bo_tbl,
                                    p_party_id              IN NUMBER,
                                    p_orig_system           IN VARCHAR2,
                                    p_orig_system_reference IN VARCHAR2,
                                    p_create_update_flag    IN VARCHAR2,
                                    x_return_status         OUT NOCOPY VARCHAR2,
                                    x_msg_count             OUT NOCOPY NUMBER,
                                    x_msg_data              OUT NOCOPY VARCHAR2);

END pos_business_class_bo_pkg;

/
