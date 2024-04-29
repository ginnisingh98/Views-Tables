--------------------------------------------------------
--  DDL for Package PON_SOURCING_OPENAPI_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_SOURCING_OPENAPI_GRP" AUTHID CURRENT_USER AS
/* $Header: PONRNBAS.pls 120.5 2006/03/06 11:40:21 sssahai noship $ */

g_header_rec           pon_auc_headers_interface%ROWTYPE;

PROCEDURE create_draft_neg_interface (p_interface_id NUMBER,
				      x_document_number OUT NOCOPY NUMBER,
				      x_document_url OUT NOCOPY VARCHAR2,
				      x_result OUT NOCOPY VARCHAR2,
				      x_error_code OUT NOCOPY VARCHAR2,
				      x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE create_draft_neg_interface (p_interface_id NUMBER,
                    x_document_number OUT NOCOPY NUMBER,
                    x_document_url OUT NOCOPY VARCHAR2,
                    x_concurrent_program_started OUT NOCOPY VARCHAR2,
                    x_request_id OUT NOCOPY NUMBER,
                    x_result OUT NOCOPY VARCHAR2,
                    x_error_code OUT NOCOPY VARCHAR2,
                    x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE val_auc_headers_interface(p_interface_id NUMBER,
				    x_error_code  OUT NOCOPY VARCHAR2,
				    x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE val_auc_items_interface(p_interface_id NUMBER,
				  x_error_code OUT NOCOPY VARCHAR2,
				  x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE val_auc_shipments_interface(p_interface_id NUMBER,
				      x_error_code OUT NOCOPY VARCHAR2,
				      x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE val_attachments_interface(p_interface_id NUMBER,
				    x_error_code OUT NOCOPY VARCHAR2,
				    x_error_message OUT NOCOPY VARCHAR2);

PROCEDURE get_trading_partner_info (p_vendor_id NUMBER,
				   x_trading_partner_id OUT NOCOPY NUMBER,
				   x_trading_partner_name OUT NOCOPY VARCHAR2,
				   x_trading_partner_contact_id OUT NOCOPY VARCHAR2,
				   x_trading_partner_contact_name OUT NOCOPY VARCHAR2,
				   x_error_code OUT NOCOPY VARCHAR2,
				   x_error_message OUT NOCOPY varchar2);

PROCEDURE purge_interface_table(p_interface_id IN NUMBER,
				x_result OUT NOCOPY VARCHAR2,
				x_error_code OUT NOCOPY VARCHAR2,
				x_error_message OUT NOCOPY VARCHAR2
				);

-------------------------------------------------------------------------------
--  This procedure determines if CPA outcome from rfq feature is enabled  or not.
-- x_cpa_enabled
--  Y  if creation of CPA from sourcing is enabled
--  N  if creation of CPA from sourcing is disabled.
-------------------------------------------------------------------------------

PROCEDURE is_cpa_integration_enabled
            (p_api_version               IN VARCHAR2
            ,p_init_msg_list             IN VARCHAR2
            ,x_return_status             OUT NOCOPY VARCHAR2
            ,x_msg_count                 OUT NOCOPY NUMBER
            ,x_msg_data                  OUT NOCOPY VARCHAR2
            ,x_cpa_enabled               OUT NOCOPY VARCHAR2);

PROCEDURE get_display_line_number(
                p_api_version           IN NUMBER,
                p_init_msg_list         IN VARCHAR2,
                p_auction_header_id     IN NUMBER,
                p_auction_line_number   IN NUMBER,
                x_display_line_number   OUT NOCOPY VARCHAR2,
                x_return_status         OUT NOCOPY VARCHAR2,
                x_msg_count             OUT NOCOPY NUMBER,
                x_msg_data              OUT NOCOPY VARCHAR2);


--PROCEDURE FOR RENEGOTIATING SUPER LARGE NEGOTIATIONS
--This procedure will be called by the concurrent
--manager. This inturn calls the create_draft_neg_interface_pvt
--procedure with p_is_conc_call = 'Y'


PROCEDURE PON_RENEG_SUPER_LARGE_NEG  (
          EFFBUF           OUT NOCOPY VARCHAR2,
          RETCODE          OUT NOCOPY VARCHAR2,
          p_interface_id    IN NUMBER,
          p_auction_header_id IN NUMBER,
          p_user_name IN VARCHAR2);



END PON_SOURCING_OPENAPI_GRP;

 

/
