--------------------------------------------------------
--  DDL for Package ECX_TP_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_TP_API" AUTHID CURRENT_USER as
-- $Header: ECXTPXAS.pls 115.9 2003/01/14 20:18:04 rdiwan ship $

tp_event_not_raised            exception;

Procedure retrieve_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                x_tp_header_id          OUT NOCOPY Pls_integer,
                                p_party_type            IN  Varchar2,
                                p_party_id              IN  Varchar2,
                                p_party_site_id         IN  Varchar2,
                                x_company_admin_email   OUT NOCOPY Varchar2,
                                x_created_by            OUT NOCOPY Varchar2,
                                x_creation_date         OUT NOCOPY Varchar2,
                                x_last_updated_by       OUT NOCOPY Varchar2,
                                x_last_update_date      OUT NOCOPY Varchar2);

Procedure create_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                x_tp_header_id          OUT NOCOPY Pls_integer,
                                p_party_type            IN  Varchar2,
                                p_party_id              IN  Varchar2,
                                p_party_site_id         IN  Varchar2,
                                p_company_admin_email   IN  Varchar2);

Procedure update_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                p_tp_header_id          IN  Pls_integer,
                                p_company_admin_email   IN  Varchar2);

Procedure delete_trading_partner(
                                x_return_status         OUT NOCOPY Pls_integer,
                                x_msg                   OUT NOCOPY Varchar2,
                                p_tp_header_id          IN  Pls_integer);

/*Bug #2183619, added one additional input parameter for
  source_tp_location_code */

Procedure retrieve_tp_detail(
                        x_return_status                 OUT NOCOPY Pls_integer,
                        x_msg                           OUT NOCOPY Varchar2,
                        x_tp_detail_id                  OUT NOCOPY Pls_integer,
                        p_tp_header_id                  IN         Pls_integer,
                        p_ext_process_id                IN         Pls_integer,
                        x_map_code                      OUT NOCOPY Varchar2,
                        x_connection_type               OUT NOCOPY Varchar2,
                        x_hub_user_id                   OUT NOCOPY Pls_integer,
                        x_protocol_type                 OUT NOCOPY Varchar2,
                        x_protocol_address              OUT NOCOPY Varchar2,
                        x_username                      OUT NOCOPY Varchar2,
                        x_password                      OUT NOCOPY Varchar2,
                        x_routing_id                    OUT NOCOPY Pls_integer,
                        x_source_tp_location_code       OUT NOCOPY Varchar2,
                        x_external_tp_location_code     OUT NOCOPY Varchar2,
                        x_confirmation                  OUT NOCOPY Varchar2,
                        x_created_by                    OUT NOCOPY Varchar2,
                        x_creation_date                 OUT NOCOPY Varchar2,
                        x_last_updated_by               OUT NOCOPY Varchar2,
                        x_last_update_date              OUT NOCOPY Varchar2,
                        p_source_tp_location_code       IN         Varchar2 default null);
--Overloaded procedure

/* Bug #2183619, Added three additional input parameters
   for External Type and Subtype and source_tp_location_code */

Procedure retrieve_tp_detail(
                        x_return_status                 OUT NOCOPY Pls_integer,
                        x_msg                           OUT NOCOPY Varchar2,
                        x_tp_detail_id                  OUT NOCOPY Pls_integer,
                        x_tp_header_id                  OUT NOCOPY Pls_integer,
                        p_party_type                    IN  Varchar2,
                        p_party_id                      IN  Varchar2,
                        p_party_site_id                 IN  Varchar2,
                        p_transaction_type              IN  Varchar2,
                        p_transaction_subtype           IN  Varchar2,
                        p_standard_code                 IN  Varchar2,
                        p_direction                     IN  Varchar2,
                        x_ext_type                      OUT NOCOPY Varchar2,
                        x_ext_subtype                   OUT NOCOPY Varchar2,
                        x_map_code                      OUT NOCOPY Varchar2,
                        x_connection_type               OUT NOCOPY Varchar2,
                        x_hub_user_id                   OUT NOCOPY Pls_integer,
                        x_protocol_type                 OUT NOCOPY Varchar2,
                        x_protocol_address              OUT NOCOPY Varchar2,
                        x_username                      OUT NOCOPY Varchar2,
                        x_password                      OUT NOCOPY Varchar2,
                        x_routing_id                    OUT NOCOPY Pls_integer,
                        x_source_tp_location_code       OUT NOCOPY Varchar2,
                        x_external_tp_location_code     OUT NOCOPY Varchar2,
                        x_confirmation                  OUT NOCOPY Varchar2,
                        x_created_by                    OUT NOCOPY Varchar2,
                        x_creation_date                 OUT NOCOPY Varchar2,
                        x_last_updated_by               OUT NOCOPY Varchar2,
                        x_last_update_date              OUT NOCOPY Varchar2,
                        p_ext_type                IN    Varchar2 default null,
                        p_ext_subtype             IN    Varchar2 default null,
                        p_source_tp_location_code IN    Varchar2 default null);


procedure create_tp_detail(
                x_return_status                 OUT      NOCOPY pls_integer,
                x_msg                           OUT      NOCOPY Varchar2,
                x_tp_detail_id                  OUT      NOCOPY Pls_integer,
                p_tp_header_id                  IN       pls_integer,
                p_ext_process_id                IN       pls_integer,
                p_map_code                      IN       Varchar2,
                p_connection_type               IN       Varchar2,
                p_hub_user_id                   IN       pls_integer,
                p_protocol_type                 IN       Varchar2,
                p_protocol_address              IN       Varchar2,
                p_username                      IN       Varchar2,
                p_password                      IN       Varchar2,
                p_routing_id                    IN       pls_integer,
                p_source_tp_location_code       IN       Varchar2	default null,
                p_external_tp_location_code     IN       Varchar2,
                p_confirmation                  IN       pls_integer);

---Overloaded
/* Bug 2122579 */

/* Bug #2183619, Added two additional input parameters
   for External Type and Subtype */

Procedure create_tp_detail(
 		x_return_status                 OUT      NOCOPY pls_integer,
 		x_msg                           OUT      NOCOPY Varchar2,
 		x_tp_detail_id                  OUT      NOCOPY Pls_integer,
 		x_tp_header_id                  OUT      NOCOPY Pls_integer,
 		p_party_type                    IN       Varchar2,
 		p_party_id                      IN       number,
 		p_party_site_id                 IN       number,
 		p_transaction_type              IN       Varchar2,
 		p_transaction_subtype           IN       Varchar2,
 		p_standard_code                 IN       Varchar2,
 		p_direction                     IN       Varchar2,
 		p_map_code                      IN       Varchar2,
 		p_connection_type               IN       Varchar2,
 		p_hub_user_id                   IN       pls_integer,
 		p_protocol_type                 IN       Varchar2,
 		p_protocol_address              IN       Varchar2,
 		p_username                      IN       Varchar2,
 		p_password                      IN       Varchar2,
 		p_routing_id                    IN       pls_integer,
 		p_source_tp_location_code       IN       Varchar2	default null,
 		p_external_tp_location_code     IN       Varchar2,
 		p_confirmation                  IN       pls_integer,
                p_ext_type                      IN       Varchar2 default null,
                p_ext_subtype                   IN       Varchar2 default null);

Procedure update_tp_detail(
 		x_return_status 		OUT	 NOCOPY pls_integer,
 		x_msg	 			OUT	 NOCOPY Varchar2,
 		p_tp_detail_id			IN	 pls_integer,
 		p_map_code	 		IN	 Varchar2,
 		p_ext_process_id		IN	 pls_integer,
 		p_connection_type		IN	 Varchar2,
 		p_hub_user_id	 		IN	 pls_integer,
 		p_protocol_type	 		IN	 Varchar2,
 		p_protocol_address		IN	 Varchar2,
 		p_username	 		IN	 Varchar2,
 		p_password	 		IN	 Varchar2,
 		p_routing_id	 		IN	 pls_integer,
 		p_source_tp_location_code	IN	 Varchar2	default null,
 		p_external_tp_location_code	IN	 Varchar2,
 		p_confirmation			IN	 pls_integer	 ,
		p_passupd_flag			IN	 varchar2 default 'Y'
		);

Procedure delete_tp_detail( x_return_status	OUT	 NOCOPY pls_integer,
			    x_msg	 	OUT	 NOCOPY Varchar2,
			    p_tp_detail_id	IN	 pls_integer	 );

Procedure raise_tp_event(
                       x_return_status      out NOCOPY pls_integer,
                       x_msg                out NOCOPY varchar2,
                       x_event_name         out NOCOPY varchar2,
                       x_event_key          out NOCOPY number,
                       p_mod_type            in varchar2,
                       p_tp_header_id        in number,
                       p_party_type          in varchar2,
                       p_party_id            in varchar2,
                       p_party_site_id       in varchar2,
                       p_company_email_addr  in varchar2   );
End;

 

/
